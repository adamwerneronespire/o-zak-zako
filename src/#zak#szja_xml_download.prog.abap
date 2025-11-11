*&---------------------------------------------------------------------*
*& Program: SZJA XML fájl letöltése
*&---------------------------------------------------------------------*
REPORT /ZAK/SZJA_XML_DOWNLOAD .
*&---------------------------------------------------------------------*
*& Funkció leírás: A program az SZJA bevallás XML fájlt állítja elő a
*& /ZAK/BEVALLO tábla alapján
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - fmc
*& Létrehozás dátuma : 2006.05.26
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
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


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: D020S, /ZAK/XMLDOWNLOAD.


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

PARAMETERS: P_BTART LIKE /ZAK/XMLDOWNLOAD-BTYPART DEFAULT 'SZJA' MODIF
ID DIS.

PARAMETERS: P_BTYPE  LIKE /ZAK/XMLDOWNLOAD-BTYPE NO-DISPLAY.

SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.

SELECT-OPTIONS: S_GJAHR1 FOR /ZAK/XMLDOWNLOAD-GJAHR  NO INTERVALS
                     NO-EXTENSION
                     OBLIGATORY,
                S_MONAT1 FOR /ZAK/XMLDOWNLOAD-MONAT  NO INTERVALS
                     NO-EXTENSION
                     OBLIGATORY,
                S_INDEX1 FOR /ZAK/XMLDOWNLOAD-ZINDEX NO INTERVALS
                     NO-EXTENSION
                     OBLIGATORY.

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
  PERFORM SEL_DATA USING V_SUBRC.
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
  PERFORM CALL_DOWNLOAD_XML USING V_SUBRC.

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
       L_FILENAME TYPE STRING,
       L_FILTER   TYPE STRING,
       L_PATH     TYPE STRING,
*      L_FULLPATH TYPE STRING,
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*       L_FULLPATH LIKE RLGRAP-FILENAME,
        L_FULLPATH     TYPE STRING,
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
       L_ACTION   TYPE I.


* Értékek leolvasása dynpro-ról
  DATA: BEGIN OF DYNP_VALUE_TAB OCCURS 0.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END   OF DYNP_VALUE_TAB.

  MOVE: SY-REPID TO D020S-PROG,
        SY-DYNNR TO D020S-DNUM.

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
            DYNAME               = D020S-PROG
            DYNUMB               = D020S-DNUM
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
*  CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING
*                DEF_FILENAME     =  L_DEF_FILENAME
**               DEF_PATH         =  L_DEF_FILENAME
*                MASK             =  L_MASK
*                MODE             = 'S'
**               title            =
*     IMPORTING  FILENAME         =  L_FULLPATH
**               RC               =  DUMMY
*     EXCEPTIONS INV_WINSYS       =  04
*                NO_BATCH         =  08
*                SELECTION_CANCEL =  12
*                SELECTION_ERROR  =  16.
  DATA L_EXTENSION TYPE STRING.
  DATA L_TITLE     TYPE STRING.
  DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.

  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      WINDOW_TITLE      = 'XML fájl'
*     DEFAULT_EXTENSION =
      DEFAULT_FILE_NAME = L_DEF_FILENAME
*     WITH_ENCODING     =
      FILE_FILTER       = '*.XML'
*     INITIAL_DIRECTORY =
*     DEFAULT_ENCODING  =
    IMPORTING
*     FILENAME          =
*     PATH              =
      FULLPATH          = L_FULLPATH
*     USER_ACTION       =
*     FILE_ENCODING     =
    .
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
FORM SEL_DATA USING $SUBRC.

  CLEAR $SUBRC.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE I_OUTTAB
           FROM /ZAK/BEVALLO
          WHERE BUKRS  EQ P_BUKRS
            AND BTYPE  EQ P_BTYPE
            AND GJAHR  EQ S_GJAHR1-LOW
            AND MONAT  EQ S_MONAT1-LOW
            AND ZINDEX EQ S_INDEX1-LOW.

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
FORM GET_BTYPE USING    $BUKRS
                        $BTYPART
                        $GJAHR
                        $MONAT
               CHANGING $BTYPE.

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
FORM CALL_DOWNLOAD_XML USING    $SUBRC.


  DATA: L_FILENAME TYPE STRING.

  CLEAR $SUBRC.

*++1408 #04. 2014.05.09
  SELECT SINGLE * INTO w_/zak/bevall
                  FROM /zak/bevall
                 WHERE bukrs EQ p_bukrs
                   AND btype EQ p_btype.
*--1408 #04. 2014.05.09


  L_FILENAME = P_FILE.

*++1408 #04. 2014.05.09
  IF NOT w_/zak/bevall-strans IS INITIAL.
*      XML készítés
    CALL FUNCTION '/ZAK/SZJA_XML_DOWNLOAD'
      EXPORTING
        i_file            = l_filename
*          I_GJAHR           =
*          I_MONAT           =
      TABLES
        t_/zak/bevallalv = i_outtab
      EXCEPTIONS
        error             = 1
        error_download    = 2
        OTHERS            = 3.
  ELSE.
*--1408 #04. 2014.05.09

  CALL FUNCTION '/ZAK/XML_FILE_DOWNLOAD'
       EXPORTING
            I_FILE            = L_FILENAME
*++BG 2006/09/29
            I_GJAHR           = S_GJAHR1-LOW
            I_MONAT           = S_MONAT1-LOW
*--BG 2006/09/29
       TABLES
            T_/ZAK/BEVALLALV = I_OUTTAB[]
       EXCEPTIONS
            ERROR_DOWNLOAD    = 1
*++BG 2006/09/29
            ERROR_IMP_PAR     = 2
*--BG 2006/09/29
            OTHERS            = 3.
*++1408 #04. 2014.05.09
  ENDIF.
*--1408 #04. 2014.05.09

  IF SY-SUBRC <> 0.
    $SUBRC = 4.
    MESSAGE E175(/ZAK/ZAK) WITH P_FILE.
*   Hiba a & fájl letöltésénél.
  ELSE.
    $SUBRC = 0.
    MESSAGE I009(/ZAK/ZAK) WITH P_FILE.
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
  SELECT SINGLE * INTO W_/ZAK/BEVALLI
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
FORM DEL_ESDAT USING    $BUKRS
                        $BTYPE
                        $GJAHR
                        $MONAT
                        $INDEX.

  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.


*Csak normál időszaknál
  CHECK $INDEX EQ '000'.

*Meghatározzuk az esedékesség dátum abev azonosítót
  SELECT SINGLE ABEVAZ INTO L_ABEVAZ
                       FROM /ZAK/BEVALLB
                      WHERE BTYPE       = $BTYPE
                       AND  ESDAT_FLAG  = C_X.
  IF SY-SUBRC EQ 0.
    DELETE I_OUTTAB WHERE ABEVAZ EQ L_ABEVAZ.
  ENDIF.


ENDFORM.                    " DEL_ESDAT
