*&---------------------------------------------------------------------*
*& Program: ÁFA XML fájl letöltése
*&---------------------------------------------------------------------*
REPORT /ZAK/AFA_XML_DOWNLOAD .
*&---------------------------------------------------------------------*
*& Funkció leírás: A program az ÁFA bevallás XML fájlt állítja elő a
*& /ZAK/BEVALLO tábla alapján
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - Ness
*& Létrehozás dátuma : 2013.07.21
*& Funkc.spec.készítő: ________
*& SAP modul neve    : /ZAK/ZAKO
*& Program  típus    : Riport
*& SAP verzió        : 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES xxxxxxxxxx
*&                                   cseréje hagyományosra
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
*++1465 #18.
TYPE-POOLS: SHLP.
*--1465 #18.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
*++S4HANA#01.
*TABLES: D020S, /ZAK/XMLDOWNLOAD.
DATA GS_D020S TYPE D020S.
DATA GS_/ZAK/XMLDOWNLOAD TYPE /ZAK/XMLDOWNLOAD.
*--S4HANA#01.


DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
      W_OUTTAB TYPE /ZAK/BEVALLALV.



*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
*      Belső tábla         -   (I_xxx...)                              *
*      FORM paraméter      -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Paraméter változó   -   (P_xxx...)                              *
*      Szelekciós opció    -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Globális változók   -   (V_xxx...)                              *
*      Lokális változók    -   (L_xxx...)                              *
*      Munkaterület        -   (W_xxx...)                              *
*      Típus               -   (T_xxx...)                              *
*      Makrók              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Osztály             -   (CL_xxx...)                             *
*      Esemény             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA V_SUBRC LIKE SY-SUBRC.



*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
  PARAMETERS: P_BUKRS  LIKE /ZAK/XMLDOWNLOAD-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.

  PARAMETERS: P_BTART LIKE /ZAK/XMLDOWNLOAD-BTYPART DEFAULT 'AFA' MODIF
  ID DIS.

  PARAMETERS: P_BTYPE  LIKE /ZAK/XMLDOWNLOAD-BTYPE NO-DISPLAY.

SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.

*++S4HANA#01.
*  SELECT-OPTIONS: S_GJAHR1 FOR /ZAK/XMLDOWNLOAD-GJAHR  NO INTERVALS
*                       NO-EXTENSION
*                       OBLIGATORY,
*                  S_MONAT1 FOR /ZAK/XMLDOWNLOAD-MONAT  NO INTERVALS
*                       NO-EXTENSION
*                       OBLIGATORY,
*                  S_INDEX1 FOR /ZAK/XMLDOWNLOAD-ZINDEX NO INTERVALS
*                       NO-EXTENSION
*                       OBLIGATORY.
  SELECT-OPTIONS: S_GJAHR1 FOR GS_/ZAK/XMLDOWNLOAD-GJAHR  NO INTERVALS
                       NO-EXTENSION
                       OBLIGATORY,
                  S_MONAT1 FOR GS_/ZAK/XMLDOWNLOAD-MONAT  NO INTERVALS
                       NO-EXTENSION
                       OBLIGATORY,
                  S_INDEX1 FOR GS_/ZAK/XMLDOWNLOAD-ZINDEX NO INTERVALS
                       NO-EXTENSION
                       OBLIGATORY.
*--S4HANA#01.

SELECTION-SCREEN: END OF BLOCK BL02.


SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-T03.
  PARAMETERS P_FILE LIKE FC03TAB-PL00_FILE OBLIGATORY.

SELECTION-SCREEN: END OF BLOCK BL03.
*++1765 #19.
INITIALIZATION.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   Önnek nincs jogosultsága a program futtatásához!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_ATTRIBUTES.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM FILENAME_GET.
*++1465 #18.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_INDEX1-LOW.
  PERFORM SUB_F4_ON_INDEX USING '1'.

*--1465 #18.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                P_BTART
                                C_ACTVT_01.

* Bevallás típus meghatározása
  PERFORM GET_BTYPE USING P_BUKRS
                          P_BTART
                          S_GJAHR1-LOW
                          S_MONAT1-LOW
                    CHANGING P_BTYPE.

* Adatbázis szelekció
*++S4HANA#01.
*  PERFORM SEL_DATA USING V_SUBRC.
  PERFORM SEL_DATA CHANGING V_SUBRC.
*--S4HANA#01.
  IF NOT V_SUBRC IS INITIAL.
    EXIT.
  ENDIF.

* Esedékességi dátum kihagyása normál időszaknál
  PERFORM DEL_ESDAT USING P_BUKRS
                          P_BTYPE
                          S_GJAHR1-LOW
                          S_MONAT1-LOW
                          S_INDEX1-LOW.


* XML fájl létrehozás
*++S4HANA#01.
*  PERFORM CALL_DOWNLOAD_XML USING V_SUBRC.
  PERFORM CALL_DOWNLOAD_XML CHANGING V_SUBRC.
*--S4HANA#01.

* Státusz állítás
  IF V_SUBRC IS INITIAL.
    PERFORM STATUS_UPDATE.
  ENDIF.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  set_screen_attributes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES.


  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " set_screen_attributes

*&---------------------------------------------------------------------*
*&      Form  filename_get
*&---------------------------------------------------------------------*
*       Elérési útvonal bevitele
*----------------------------------------------------------------------*
FORM FILENAME_GET.

  DATA: L_DEF_FILENAME TYPE STRING,
        L_FILENAME     TYPE STRING,
        L_FILTER       TYPE STRING,
        L_PATH         TYPE STRING,
*      L_FULLPATH TYPE STRING,
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*        L_FULLPATH     LIKE RLGRAP-FILENAME,
        L_FULLPATH     TYPE STRING,
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
        L_ACTION       TYPE I.


* Értékek leolvasása dynpro-ról
  DATA: BEGIN OF DYNP_VALUE_TAB OCCURS 0.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END   OF DYNP_VALUE_TAB.

*++S4HANA#01.
*  MOVE: SY-REPID TO D020S-PROG,
*        SY-DYNNR TO D020S-DNUM.
  MOVE: SY-REPID TO GS_D020S-PROG,
        SY-DYNNR TO GS_D020S-DNUM.
*--S4HANA#01.

  MOVE: 'P_BUKRS' TO DYNP_VALUE_TAB-FIELDNAME.
  APPEND DYNP_VALUE_TAB.
  MOVE: 'P_BTART' TO DYNP_VALUE_TAB-FIELDNAME.
  APPEND DYNP_VALUE_TAB.
  MOVE: 'S_GJAHR1-LOW' TO DYNP_VALUE_TAB-FIELDNAME.
  APPEND DYNP_VALUE_TAB.
  MOVE: 'S_MONAT1-LOW' TO DYNP_VALUE_TAB-FIELDNAME.
  APPEND DYNP_VALUE_TAB.
  MOVE: 'S_INDEX1-LOW' TO DYNP_VALUE_TAB-FIELDNAME.
  APPEND DYNP_VALUE_TAB.


* Dynpróról az éretékek leolvasása
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
*++S4HANA#01.
*     DYNAME               = D020S-PROG
*     DYNUMB               = D020S-DNUM
      DYNAME               = GS_D020S-PROG
      DYNUMB               = GS_D020S-DNUM
*--S4HANA#01.
    TABLES
      DYNPFIELDS           = DYNP_VALUE_TAB
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 04
      INVALID_DYNPROFIELD  = 08
      INVALID_DYNPRONAME   = 12
      INVALID_DYNPRONUMMER = 16
      INVALID_REQUEST      = 20
      NO_FIELDDESCRIPTION  = 24
      UNDEFIND_ERROR       = 28.
* Értékek visszaírása a változókba
  READ TABLE DYNP_VALUE_TAB INDEX 1.
  MOVE: DYNP_VALUE_TAB-FIELDVALUE TO P_BUKRS.
  READ TABLE DYNP_VALUE_TAB INDEX 2.
  MOVE: DYNP_VALUE_TAB-FIELDVALUE TO P_BTART.
  READ TABLE DYNP_VALUE_TAB INDEX 3.
  MOVE: DYNP_VALUE_TAB-FIELDVALUE TO S_GJAHR1-LOW.
  READ TABLE DYNP_VALUE_TAB INDEX 4.
  MOVE: DYNP_VALUE_TAB-FIELDVALUE TO S_MONAT1-LOW.
  READ TABLE DYNP_VALUE_TAB INDEX 5.
  MOVE: DYNP_VALUE_TAB-FIELDVALUE TO S_INDEX1-LOW.

  CONCATENATE P_BUKRS P_BTART S_GJAHR1-LOW S_MONAT1-LOW S_INDEX1-LOW
                                                    INTO L_DEF_FILENAME
                                                       SEPARATED BY '_'.

  CONCATENATE L_DEF_FILENAME '.XML' INTO L_DEF_FILENAME.
  L_FILTER = '*.XML'.


* ++ 0001 CST 2006.05.27
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
*     EXPORTING
**       WINDOW_TITLE      =
**       DEFAULT_EXTENSION = '*.*'
*       DEFAULT_FILE_NAME = L_DEF_FILENAME
*       FILE_FILTER       = L_FILTER
**       INITIAL_DIRECTORY =
*    CHANGING
*      FILENAME          = L_FILENAME
*      PATH              = L_PATH
*      FULLPATH          = L_FULLPATH
*      USER_ACTION       = L_ACTION
*    EXCEPTIONS
*      CNTL_ERROR        = 1
*      ERROR_NO_GUI      = 2
*      OTHERS            = 3.
*
*  IF SY-SUBRC = 0.
*
*    P_FILE = L_FULLPATH.
*
*  ENDIF.


  DATA: L_MASK(20)   TYPE C VALUE ',*.xml  ,*.*.'.
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*++S4HANA#01.
**  CALL FUNCTION 'WS_FILENAME_GET'
**    EXPORTING
**      DEF_FILENAME     = L_DEF_FILENAME
***     DEF_PATH         =  L_DEF_FILENAME
**      MASK             = L_MASK
**      MODE             = 'S'
***     title            =
**    IMPORTING
**      FILENAME         = L_FULLPATH
***     RC               =  DUMMY
**    EXCEPTIONS
**      INV_WINSYS       = 04
**      NO_BATCH         = 08
**      SELECTION_CANCEL = 12
**      SELECTION_ERROR  = 16.
*  DATA L_EXTENSION TYPE STRING.
*  DATA L_TITLE     TYPE STRING.
*  DATA L_FILE      TYPE STRING.
**  DATA L_FULLPATH  TYPE STRING.
*
*  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
*    EXPORTING
*      WINDOW_TITLE      = 'Output fájl'
**     DEFAULT_EXTENSION =
**++1765 #07.
*      DEFAULT_FILE_NAME = L_DEF_FILENAME
**--1765 #07.
**     WITH_ENCODING     =
*      FILE_FILTER       = '*.XML'
**     INITIAL_DIRECTORY =
**     DEFAULT_ENCODING  =
*    IMPORTING
**     FILENAME          =
**     PATH              =
*      FULLPATH          = L_FULLPATH
**     USER_ACTION       =
**     FILE_ENCODING     =
*    .
  DATA: LT_FILE_TABLE_0     TYPE FILETABLE,
        LS_W_FILE_TABLE_0   LIKE LINE OF LT_FILE_TABLE_0,
        LV_W_RC_0           TYPE I,
        LV_W_TITLE_0        TYPE STRING,
        LV_W_SYSUBRC_TEMP_0 TYPE SY-SUBRC.

  DATA: LV_W_DEFAULT_FILENAME_0 TYPE STRING.
  LV_W_DEFAULT_FILENAME_0 = L_DEF_FILENAME.

  DATA: LV_W_MODE_0(1) TYPE C.
  LV_W_MODE_0 = 'S'.
  IF LV_W_MODE_0 = 'S'.
    LV_W_TITLE_0 = 'Save As'.                               "#EC NOTEXT
  ELSE.
    LV_W_TITLE_0 = 'Open'.                                  "#EC NOTEXT
  ENDIF.

  DATA: LV_W_FILE_FILTER_0 TYPE STRING.
  LV_W_FILE_FILTER_0 = L_MASK.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE     = LV_W_TITLE_0
      DEFAULT_FILENAME = LV_W_DEFAULT_FILENAME_0
      FILE_FILTER      = LV_W_FILE_FILTER_0
      WITH_ENCODING    = ABAP_FALSE
      MULTISELECTION   = SPACE
    CHANGING
      FILE_TABLE       = LT_FILE_TABLE_0
      RC               = LV_W_RC_0
    EXCEPTIONS
      OTHERS           = 4.
  LV_W_SYSUBRC_TEMP_0 = SY-SUBRC.

  READ TABLE LT_FILE_TABLE_0 INTO LS_W_FILE_TABLE_0 INDEX 1.
  IF SY-SUBRC = 0.
    L_FULLPATH = LS_W_FILE_TABLE_0-FILENAME.
  ENDIF.

  SY-SUBRC = LV_W_SYSUBRC_TEMP_0.
*--S4HANA#01.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

  CHECK SY-SUBRC EQ 0.
  P_FILE = L_FULLPATH.
* -- 0001 CST 2006.05.27
ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  sel_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM SEL_DATA USING $SUBRC.
FORM SEL_DATA CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

  CLEAR $SUBRC.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE I_OUTTAB
           FROM /ZAK/BEVALLO
          WHERE BUKRS  EQ P_BUKRS
            AND BTYPE  EQ P_BTYPE
            AND GJAHR  EQ S_GJAHR1-LOW
            AND MONAT  EQ S_MONAT1-LOW
            AND ZINDEX EQ S_INDEX1-LOW
*++S4HANA#01.
    ORDER BY PRIMARY KEY.
*--S4HANA#01.

  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
    MESSAGE I031(/ZAK/ZAK).
*   Adatbázis nem tartalmaz feldolgozható rekordot!
  ENDIF.

ENDFORM.                    " sel_data

*&---------------------------------------------------------------------*
*&      Form  get_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTART  text
*      -->P_S_GJAHR_LOW  text
*      -->P_S_MONAT_LOW  text
*      <--P_P_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_BTYPE USING    $BUKRS
*                        $BTYPART
*                        $GJAHR
*                        $MONAT
*               CHANGING $BTYPE.
FORM GET_BTYPE USING    $BUKRS TYPE /ZAK/XMLDOWNLOAD-BUKRS
                        $BTYPART TYPE /ZAK/XMLDOWNLOAD-BTYPART
                        $GJAHR TYPE /ZAK/XMLDOWNLOAD-GJAHR
                        $MONAT TYPE /ZAK/XMLDOWNLOAD-MONAT
               CHANGING $BTYPE TYPE /ZAK/XMLDOWNLOAD-BTYPE.
*--S4HANA#01.

  CLEAR $BTYPE.

  CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
    EXPORTING
      I_BUKRS     = $BUKRS
      I_BTYPART   = $BTYPART
      I_GJAHR     = $GJAHR
      I_MONAT     = $MONAT
    IMPORTING
      E_BTYPE     = $BTYPE
    EXCEPTIONS
      ERROR_MONAT = 1
      ERROR_BTYPE = 2
      OTHERS      = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " get_btype
*&---------------------------------------------------------------------*
*&      Form  CALL_DOWNLOAD_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CALL_DOWNLOAD_XML USING    $SUBRC.
FORM CALL_DOWNLOAD_XML CHANGING    $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.


  DATA: L_FILENAME TYPE STRING.

  CLEAR $SUBRC.

  L_FILENAME = P_FILE.

* XML készítés
  CALL FUNCTION '/ZAK/AFA_XML_DOWNLOAD'
    EXPORTING
      I_FILE            = L_FILENAME
*     I_GJAHR           =
*     I_MONAT           =
    TABLES
      T_/ZAK/BEVALLALV = I_OUTTAB
    EXCEPTIONS
      ERROR             = 1
      ERROR_DOWNLOAD    = 2
      OTHERS            = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
    $SUBRC = SY-SUBRC.
    MESSAGE E352(/ZAK/ZAK) WITH SY-SUBRC.
*        Hiba az XML konvertálásnál! (&)
  ELSE.
    MESSAGE I009(/ZAK/ZAK) WITH L_FILENAME.
    $SUBRC = 0.
  ENDIF.

ENDFORM.                    " CALL_DOWNLOAD_XML
*&---------------------------------------------------------------------*
*&      Form  STATUS_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM STATUS_UPDATE.

*++BG 2006/07/19
* Meghatározzuk a jelenlegi státuszt, mibel lezárt vagy APEH
* által ellenőrzött időszakra már nem kell státusz állítás
*++S4HANA#01.
*  SELECT SINGLE * INTO W_/ZAK/BEVALLI
  SELECT SINGLE FLAG INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALLI
*--S4HANA#01.
          FROM  /ZAK/BEVALLI
         WHERE  BUKRS EQ P_BUKRS
          AND   BTYPE EQ P_BTYPE
          AND   GJAHR EQ S_GJAHR1-LOW
          AND   MONAT EQ S_MONAT1-LOW
          AND   ZINDEX EQ S_INDEX1-LOW.

  CHECK W_/ZAK/BEVALLI-FLAG NA 'ZX'.
*--BG 2006/07/19

* /ZAK/BEVALLSZ
  UPDATE /ZAK/BEVALLSZ SET FLAG = 'T'
                          DATUM = SY-DATUM
                          UZEIT = SY-UZEIT
                          UNAME = SY-UNAME
     WHERE BUKRS  = P_BUKRS
       AND BTYPE  = P_BTYPE
       AND GJAHR  = S_GJAHR1-LOW
       AND MONAT  = S_MONAT1-LOW
       AND ZINDEX = S_INDEX1-LOW.

  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

* /ZAK/BEVALLI
  UPDATE /ZAK/BEVALLI SET FLAG = 'T'
                         DWNDT = SY-DATUM
                         DATUM = SY-DATUM
                         UZEIT = SY-UZEIT
                         UNAME = SY-UNAME
     WHERE BUKRS  = P_BUKRS
       AND BTYPE  = P_BTYPE
       AND GJAHR  = S_GJAHR1-LOW
       AND MONAT  = S_MONAT1-LOW
       AND ZINDEX = S_INDEX1-LOW.

  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " STATUS_UPDATE
*&---------------------------------------------------------------------*
*&      Form  DEL_ESDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_S_GJAHR1_LOW  text
*      -->P_S_MONAT1_LOW  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM DEL_ESDAT USING    $BUKRS
*                        $BTYPE
*                        $GJAHR
*                        $MONAT
*                        $INDEX.
FORM DEL_ESDAT USING    $BUKRS TYPE /ZAK/XMLDOWNLOAD-BUKRS
                        $BTYPE TYPE /ZAK/XMLDOWNLOAD-BTYPE
                        $GJAHR TYPE /ZAK/XMLDOWNLOAD-GJAHR
                        $MONAT TYPE /ZAK/XMLDOWNLOAD-MONAT
                        $INDEX TYPE /ZAK/XMLDOWNLOAD-ZINDEX.
*--S4HANA#01.

  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.


*Csak normál időszaknál
  CHECK $INDEX EQ '000'.

*Meghatározzuk az esedékesség dátum abev azonosítót
*++S4HANA#01.
*  SELECT SINGLE ABEVAZ INTO L_ABEVAZ
*                       FROM /ZAK/BEVALLB
*                      WHERE BTYPE       = $BTYPE
*                       AND  ESDAT_FLAG  = C_X.
  SELECT ABEVAZ INTO L_ABEVAZ
                       FROM /ZAK/BEVALLB UP TO 1 ROWS
                      WHERE BTYPE       = $BTYPE
                       AND  ESDAT_FLAG  = C_X
                      ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.
  IF SY-SUBRC EQ 0.
    DELETE I_OUTTAB WHERE ABEVAZ EQ L_ABEVAZ.
  ENDIF.


ENDFORM.                    " DEL_ESDAT
*++1465 #18.
*&---------------------------------------------------------------------*
*&      Form  sub_f4_on_index
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_INDEX_LOW  text
*----------------------------------------------------------------------*
FORM SUB_F4_ON_INDEX USING    $SH_TYPE.

  DATA: L_SHLPNAME TYPE SHLPNAME.
  DATA: T_RETURN_TAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA: LI_DYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD INITIAL SIZE 0 WITH HEADER LINE.


  IF $SH_TYPE = '1'.
    L_SHLPNAME = '/ZAK/INDEX_1'.
  ELSEIF $SH_TYPE = '2'.
    L_SHLPNAME = '/ZAK/INDEX_2'.
  ELSE.
    L_SHLPNAME = '/ZAK/INDEX_3'.
  ENDIF.


  CLEAR: S_GJAHR1-LOW,
         S_MONAT1-LOW,
         S_INDEX1-LOW.

*   CLEAR: S_GJAHR2-LOW,
*          S_MONAT2-LOW,
*          S_INDEX2-LOW.
*
*   CLEAR: S_GJAHR3-LOW,
*          S_MONAT3-LOW,
*          S_INDEX3-LOW.

  REFRESH: S_GJAHR1,
           S_MONAT1,
           S_INDEX1.

*   REFRESH: S_GJAHR2,
*            S_MONAT2,
*            S_INDEX2.
*
*   REFRESH: S_GJAHR3,
*            S_MONAT3,
*            S_INDEX3.

  MOVE: 'P_BUKRS' TO LI_DYNPFIELDS-FIELDNAME.
  APPEND LI_DYNPFIELDS.
  MOVE: 'P_BTART' TO LI_DYNPFIELDS-FIELDNAME.
  APPEND LI_DYNPFIELDS.

* Értékek leolvasása DYNPRO-ról:
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
*     TRANSLATE_TO_UPPER   = ' '
*     REQUEST              = ' '
*     PERFORM_CONVERSION_EXITS             = ' '
*     PERFORM_INPUT_CONVERSION             = ' '
*     DETERMINE_LOOP_INDEX = ' '
*     START_SEARCH_IN_CURRENT_SCREEN       = ' '
*     START_SEARCH_IN_MAIN_SCREEN          = ' '
*     START_SEARCH_IN_STACKED_SCREEN       = ' '
*     START_SEARCH_ON_SCR_STACKPOS         = ' '
*     SEARCH_OWN_SUBSCREENS_FIRST          = ' '
*     SEARCHPATH_OF_SUBSCREEN_AREAS        = ' '
    TABLES
      DYNPFIELDS           = LI_DYNPFIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.
  READ TABLE LI_DYNPFIELDS WITH KEY FIELDNAME = 'P_BUKRS'.
  IF SY-SUBRC EQ 0.
    P_BUKRS = LI_DYNPFIELDS-FIELDVALUE.
  ENDIF.

  READ TABLE LI_DYNPFIELDS WITH KEY FIELDNAME = 'P_BTART'.
  IF SY-SUBRC EQ 0.
    P_BTART = LI_DYNPFIELDS-FIELDVALUE.
  ENDIF.

  CALL FUNCTION '/ZAK/F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = SPACE
      FIELDNAME         = SPACE
      SEARCHHELP        = L_SHLPNAME
      CALLBACK_PROGRAM  = SY-REPID
      CALLBACK_FORM     = 'SET_FIELDS_F4'
    TABLES
      RETURN_TAB        = T_RETURN_TAB
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.
  IF SY-SUBRC = 0.

    LOOP AT T_RETURN_TAB.
      CASE T_RETURN_TAB-FIELDNAME.
        WHEN 'GJAHR'.
          CASE $SH_TYPE.
            WHEN '1'.
              S_GJAHR1-LOW = T_RETURN_TAB-FIELDVAL.
*             WHEN '2'.
*               S_GJAHR2-LOW = T_RETURN_TAB-FIELDVAL.
*             WHEN '3'.
*               S_GJAHR3-LOW = T_RETURN_TAB-FIELDVAL.
          ENDCASE.
        WHEN 'MONAT'.
          CASE $SH_TYPE.
            WHEN '1'.
              S_MONAT1-LOW = T_RETURN_TAB-FIELDVAL.
*             WHEN '2'.
*               S_MONAT2-LOW = T_RETURN_TAB-FIELDVAL.
*             WHEN '3'.
*               S_MONAT3-LOW = T_RETURN_TAB-FIELDVAL.
          ENDCASE.

        WHEN 'ZINDEX'.
          CASE $SH_TYPE.
            WHEN '1'.
              S_INDEX1-LOW = T_RETURN_TAB-FIELDVAL.
*             WHEN '2'.
*               S_INDEX2-LOW = T_RETURN_TAB-FIELDVAL.
*             WHEN '3'.
*               S_INDEX3-LOW = T_RETURN_TAB-FIELDVAL.
          ENDCASE.

      ENDCASE.
    ENDLOOP.

    PERFORM DYNP_UPDATE USING $SH_TYPE.

  ENDIF.

ENDFORM.                    " sub_f4_on_index
*&---------------------------------------------------------------------*
*&      Form  DYNP_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DYNP_UPDATE USING $SH_TYPE.
  DATA: I_DYNPREAD TYPE TABLE OF DYNPREAD INITIAL SIZE 0.
  DATA: W_DYNPREAD TYPE DYNPREAD.


  CASE $SH_TYPE.

    WHEN '1'.
      CLEAR W_DYNPREAD.
      W_DYNPREAD-FIELDNAME = 'S_GJAHR1-LOW'.
      W_DYNPREAD-FIELDVALUE = S_GJAHR1-LOW.
      APPEND W_DYNPREAD TO I_DYNPREAD.

      CLEAR W_DYNPREAD.
      W_DYNPREAD-FIELDNAME = 'S_MONAT1-LOW'.
      W_DYNPREAD-FIELDVALUE = S_MONAT1-LOW.
      APPEND W_DYNPREAD TO I_DYNPREAD.

      CLEAR W_DYNPREAD.
      W_DYNPREAD-FIELDNAME = 'S_INDEX1-LOW'.
      W_DYNPREAD-FIELDVALUE = S_INDEX1-LOW.
      APPEND W_DYNPREAD TO I_DYNPREAD.

*     WHEN '2'.
*       CLEAR W_DYNPREAD.
*       W_DYNPREAD-FIELDNAME = 'S_GJAHR2-LOW'.
*       W_DYNPREAD-FIELDVALUE = S_GJAHR2-LOW.
*       APPEND W_DYNPREAD TO I_DYNPREAD.
*
*       CLEAR W_DYNPREAD.
*       W_DYNPREAD-FIELDNAME = 'S_MONAT2-LOW'.
*       W_DYNPREAD-FIELDVALUE = S_MONAT2-LOW.
*       APPEND W_DYNPREAD TO I_DYNPREAD.
*
*       CLEAR W_DYNPREAD.
*       W_DYNPREAD-FIELDNAME = 'S_INDEX2-LOW'.
*       W_DYNPREAD-FIELDVALUE = S_INDEX2-LOW.
*       APPEND W_DYNPREAD TO I_DYNPREAD.
*
*     WHEN '3'.
*
*       CLEAR W_DYNPREAD.
*       W_DYNPREAD-FIELDNAME = 'S_GJAHR3-LOW'.
*       W_DYNPREAD-FIELDVALUE = S_GJAHR3-LOW.
*       APPEND W_DYNPREAD TO I_DYNPREAD.
*
*       CLEAR W_DYNPREAD.
*       W_DYNPREAD-FIELDNAME = 'S_MONAT3-LOW'.
*       W_DYNPREAD-FIELDVALUE = S_MONAT3-LOW.
*       APPEND W_DYNPREAD TO I_DYNPREAD.
*
*       CLEAR W_DYNPREAD.
*       W_DYNPREAD-FIELDNAME = 'S_INDEX3-LOW'.
*       W_DYNPREAD-FIELDVALUE = S_INDEX3-LOW.
*       APPEND W_DYNPREAD TO I_DYNPREAD.


  ENDCASE.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = I_DYNPREAD
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DYNP_UPDATE
*&---------------------------------------------------------------------*
*&      Form SET_FIELDS_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELDS_F4   TABLES RECORD_TAB    STRUCTURE SEAHLPRES
                     CHANGING        SHLP TYPE      SHLP_DESCR_T
                              CALLCONTROL LIKE      DDSHF4CTRL.

  DATA: I_BTYPES TYPE /ZAK/T_BTYPE.
  DATA: W_BTYPES TYPE /ZAK/BTYPE.
  DATA: LS_SELOPT TYPE DDSHSELOPT.

  LS_SELOPT-SHLPFIELD = 'BUKRS'.
  LS_SELOPT-SIGN      = 'I'.
  LS_SELOPT-OPTION    = 'EQ'.
  LS_SELOPT-LOW       = P_BUKRS.
  APPEND LS_SELOPT TO SHLP-SELOPT.

  PERFORM GET_BTYPES TABLES I_BTYPES
                     USING P_BUKRS
                           P_BTART.

  SORT I_BTYPES DESCENDING.
  LOOP AT I_BTYPES INTO W_BTYPES.
    CLEAR LS_SELOPT.
    LS_SELOPT-SHLPFIELD = 'BTYPE'.
    LS_SELOPT-SIGN      = 'I'.
    LS_SELOPT-OPTION    = 'EQ'.
    LS_SELOPT-LOW       = W_BTYPES.
    APPEND LS_SELOPT TO SHLP-SELOPT.
  ENDLOOP.


ENDFORM.                    "SET_FIELDS_F4
*&---------------------------------------------------------------------*
*&      Form  get_btypes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BTYPES  text
*      -->P_P_BUKRS  text
*      -->P_P_BTART  text
*----------------------------------------------------------------------*
FORM GET_BTYPES TABLES   I_BTYPES TYPE /ZAK/T_BTYPE
                USING    $BUKRS
                         $BTYPART.

  REFRESH I_BTYPES.

  CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART_M'
    EXPORTING
      I_BUKRS     = $BUKRS
      I_BTYPART   = $BTYPART
*     I_GJAHR     =
*     I_MONAT     =
*   IMPORTING
*     E_BTYPE     =
    TABLES
      T_BTYPES    = I_BTYPES
    EXCEPTIONS
      ERROR_MONAT = 1
      ERROR_BTYPE = 2
      OTHERS      = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " get_btypes
*--1465 #18.
