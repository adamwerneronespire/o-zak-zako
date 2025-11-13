*&---------------------------------------------------------------------*
*& Program: SZJA XML migráció
*&---------------------------------------------------------------------*
REPORT /ZAK/MIGR_SZJA_READ MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: __________________
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor
*& Létrehozás dátuma : 2018.12.06
*& Funkc.spec.készítő: Balázs Gábor
*& SAP modul neve    : ADO
*& Program  típus    : ________
*& SAP verzió        : ________
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS
*& ----   ----------   ----------     ---------------------- -----------
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE: /ZAK/READ_TOP.
INCLUDE EXCEL__C.
INCLUDE <ICON>.
*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: BKPF,
        T001,
        DD02L.
*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.
*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_CLASS       TYPE DD02L-TABCLASS VALUE 'INTTAB',
           C_A           TYPE C VALUE 'A',
* file típusok
           C_FILE_XLS(2) TYPE C VALUE   '02',
           C_FILE_TXT(2) TYPE C VALUE   '01',
           C_FILE_XML(2) TYPE C VALUE   '03',
           C_FILE_SAP(2) TYPE C VALUE   '04',
*++PTGSZLAA 2014.03.04 BG (Ness)
           C_FILE_CSV(2) TYPE C VALUE   '05',
*--PTGSZLAA 2014.03.04 BG (Ness)
* excel betöltéshez
           C_END_ROW     TYPE I VALUE '65536',
           C_BEGIN_ROW   TYPE I VALUE    '1',
* file ellenörzése
           C_FILE_X(1)   TYPE C VALUE    'X',
* analitika adatszerkezet
           C_ANALITIKA   LIKE /ZAK/BEVALLD-STRNAME VALUE '/ZAK/ANALITIKA'.
*++BG 2007.02.12
*++1565 #10.
* CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 5000.
CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 9000.
*--1565 #10.
*--BG 2007.02.12
*++PTGSZLAA #01. 2014.03.03
CONSTANTS: C_PTGSZLAA  TYPE /ZAK/BTYPE VALUE 'PTGSZLAA'.
*--PTGSZLAA #01. 2014.03.03
*++1865 #10.
CONSTANTS: C_PTGSZLAH  TYPE /ZAK/BTYPE VALUE 'PTGSZLAH'.
*--1865 #10.
*type: begin of line
*&---------------------------------------------------------------------*
*& Munkaterület  (W_XXX..)                                           *
*&---------------------------------------------------------------------*
* struktúra ellenőrzése
DATA: W_DD02L TYPE DD02L.
* excel betöltéshez
DATA: W_XLS      TYPE ALSMEX_TABLINE,
      W_DD03P    TYPE DD03P,
      W_MAIN_STR TYPE DD03P,
      WA_DD03P   TYPE DD03P,
      W_LINE     TYPE /ZAK/LINE.
DATA: W_OUTTAB  TYPE /ZAK/ANALITIKA,
      W_BEVALLI TYPE /ZAK/BEVALLI,
      W_ELSO    TYPE /ZAK/BEVALLI.
* adatszerkezet hiba
DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.
DATA: BEGIN OF GT_OUTTAB OCCURS 0.
    INCLUDE STRUCTURE /ZAK/ANALITIKA.
DATA: LIGHT TYPE C.
DATA: END OF GT_OUTTAB.
DATA: G_LIGHTS_NAME TYPE LVC_CIFNM VALUE 'LIGHT'.
* message
DATA: W_MESSAGE TYPE BAPIRET2.
*&---------------------------------------------------------------------*
*& BELSŐ TÁBLÁK  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
DATA: I_XLS      TYPE STANDARD TABLE OF ALSMEX_TABLINE
                                                      INITIAL SIZE 0,
      I_DD03P    TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0,
      I_MAIN_STR TYPE STANDARD TABLE OF DD03P       INITIAL SIZE 0.
DATA: I_OUTTAB    TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
      I_OUTTAB_EX TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
* bevallási időszakok
DATA: I_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0,
      I_ELSO    TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0.
* Hiba adaszerkezet tábla
DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
DATA: I_LINE TYPE STANDARD TABLE OF /ZAK/LINE            INITIAL SIZE 0.
* message
DATA: E_MESSAGE TYPE STANDARD TABLE OF BAPIRET2     INITIAL SIZE 0.
*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Globális változók   -   (V_xxx...)                              *
*      Munkaterület        -   (W_xxx...)                              *
*      Típus               -   (T_xxx...)                              *
*      Makrók              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Osztály             -   (CL_xxx...)                             *
*      Esemény             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA: V_WRBTR       LIKE BSEG-WRBTR,
      V_WRBTR_C(16).
DATA: V_DATUM      LIKE SY-DATUM,
      V_DATUMC(10) TYPE C.
DATA: V_TABIX LIKE SY-TABIX,
      V_SUBRC LIKE SY-SUBRC.
* változók
DATA: V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.
* szelekciós képernyő
DATA: V_BUTXT   LIKE T001-BUTXT.
DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
      V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.
* excel betöltéshez
DATA: V_BEGIN_COL TYPE I,
      V_END_COL   TYPE I.
* képernyőre
DATA: V_SCR1(70) TYPE C,
      V_SCR2(70) TYPE C,
      V_SCR3(70) TYPE C,
      V_SCR4(70) TYPE C.
* ALV kezelési változók
DATA: V_OK_CODE           LIKE SY-UCOMM,
      V_SAVE_OK           LIKE SY-UCOMM,
      V_REPID             LIKE SY-REPID,
      V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CONTAINER2        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',
      V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
      V_GRID2             TYPE REF TO CL_GUI_ALV_GRID,
      V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      V_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT          TYPE LVC_T_FCAT,
      I_FIELDCAT2         TYPE LVC_T_FCAT,
      V_LAYOUT            TYPE LVC_S_LAYO,
      V_LAYOUT2           TYPE LVC_S_LAYO,
      V_VARIANT           TYPE DISVARIANT,
      V_VARIANT2          TYPE DISVARIANT,
      V_TOOLBAR           TYPE STB_BUTTON,
      V_DYNDOC_ID         TYPE REF TO CL_DD_DOCUMENT,
*      V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
*      V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER,
      V_STRUC             TYPE DD02L-TABNAME.
* popup üzenethez
DATA: V_TEXT1(40) TYPE C,
      V_TEXT2(40) TYPE C,
      V_TITEL     TYPE C,
      V_ANSWER.
* file ellenörzése
DATA: LV_ACTIVE TYPE ABAP_BOOL.
DATA: V_WNUM(30) TYPE N,
      V_WAERS    LIKE T001-WAERS.
*++BG 2007.02.12
DATA: V_XLS_LINE TYPE SY-TABIX VALUE 5000.
*--BG 2007.02.12
* field symbol
FIELD-SYMBOLS <FS> TYPE ANY.
*++0002 BG 2007.07.02
RANGES R_ADOAZON FOR /ZAK/ANALITIKA-ADOAZON.
*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-sign,
        &3      TO &1-option,
        &4      TO &1-low,
        &5      TO &1-high.
  COLLECT &1.
END-OF-DEFINITION.
*--0002 BG 2007.07.02
*&---------------------------------------------------------------------*
*& PARAMÉTEREK  (P_XXXXXXX..)                                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SZELEKT-OPCIÓK (S_XXXXXXX..)                                        *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-A01.
PARAMETERS: P_BUKRS LIKE /ZAK/BEVALL-BUKRS
*                         T001-BUKRS
                         VALUE CHECK
                         OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID OUT.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-A02.
PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE OBLIGATORY.
*                         MATCHCODE OBJECT /ZAK/BEV
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID OUT.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BEVD
                                                   NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK B02.
SELECTION-SCREEN BEGIN OF BLOCK B04 WITH FRAME TITLE TEXT-B04.
PARAMETERS: P_NORM  DEFAULT 'X' NO-DISPLAY,
            P_ISMET NO-DISPLAY,
            P_PACK  LIKE /ZAK/BEVALLP-PACK
                       MATCHCODE OBJECT /ZAK/PACK NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK B04.
SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-B03.
PARAMETERS: P_PREZ DEFAULT 'X' NO-DISPLAY,
            P_APPL NO-DISPLAY.
PARAMETERS: P_FDIR  LIKE FC03TAB-PL00_FILE          OBLIGATORY,
* PARAMETERS: P_FDIR(255) TYPE C                    OBLIGATORY
*                                                   LOWER CASE,
*MEMORY ID GPF
*++BG 2006/07/07
            P_HEAD  DEFAULT 'X' NO-DISPLAY,
*--BG 2006/07/07
            P_TESZT AS CHECKBOX DEFAULT 'X',
            P_ALV   AS CHECKBOX,
            P_XML   AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK B03.
PARAMETERS: P_CDV NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK B01.

*===================================================================
*-----------------------------------------------------------------------
*       INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
* megnevezések
  PERFORM FIELD_DESCRIPT.
*++1765 #19.
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
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN.
* megnevezések
  PERFORM FIELD_DESCRIPT.
  PERFORM CHECK_PARAMS .
*++BG 2006/08/31
*  Fájl névben vállalat kód ellenőrzés
  PERFORM CHECK_BUKRS_FILENAME.
*--BG 2006/08/31
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FDIR.
*++PTGSZLAA 2014.03.04 BG (Ness)
*   IF NOT P_PREZ IS INITIAL.
*--PTGSZLAA 2014.03.04 BG (Ness)
  PERFORM FILENAME_GET.
*++PTGSZLAA 2014.03.04 BG (Ness)
*   ELSEIF NOT P_APPL IS INITIAL.
*     PERFORM FILENAME_GET_APPL.
*   ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
AT SELECTION-SCREEN ON BLOCK B04.
**  Blokk ellenőrzése
*   PERFORM VER_BLOCK_B04 USING P_NORM
*                               P_ISMET
*                               P_PACK.
* Választó kapcsoló ellenörzése !
*AT SELECTION-SCREEN ON RADIOBUTTON GROUP R01.
************************************************************************
* AT SELECTION-SCREEN output
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIF_SCREEN.


************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

* bevallás fajta meghatározása
  PERFORM READ_BEVALL USING P_BUKRS
                            P_BTYPE.
* XML upload
  CALL FUNCTION '/ZAK/XML'
    EXPORTING
      FILENAME        = P_FDIR
      I_BUKRS         = P_BUKRS
      I_BTYPE         = P_BTYPE
      I_BSZNUM        = P_BSZNUM
    TABLES
      T_/ZAK/ANALITIKA = I_OUTTAB
      T_HIBA          = I_HIBA
    EXCEPTIONS
      ERROR_OPEN_FILE = 1
      ERROR_XML       = 2
      EMPTY_FILE      = 3
      OTHERS          = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM MOD_DATA.

  PERFORM UPD_DATA USING P_TESZT.

************************************************************************
* END-OF-SELECTION
***********************************************************************
END-OF-SELECTION.

  PERFORM ALV_LIST.

*&---------------------------------------------------------------------*
*&      Form  field_descript
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_DESCRIPT.
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE *  FROM T001
          WHERE BUKRS = P_BUKRS.
    P_BUTXT = T001-BUTXT.
*++1765 #18.
*     V_WAERS = T001-WAERS.
    SELECT SINGLE WAERS INTO V_WAERS
                        FROM T005
                       WHERE LAND1 EQ T001-LAND1.
*--1765 #18.
  ENDIF.
  IF NOT P_BTYPE IS INITIAL.
    SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
        WHERE LANGU = SY-LANGU
          AND BUKRS = P_BUKRS
          AND BTYPE = P_BTYPE.
  ENDIF.
*   IF NOT P_BPART IS INITIAL.
*     SELECT SINGLE DDTEXT INTO P_BTTEXT FROM DD07T
*        WHERE DOMNAME = '/ZAK/BTYPART'
*          AND DDLANGUAGE = SY-LANGU
*          AND DOMVALUE_L = P_BPART.
*   ENDIF.
ENDFORM.                    " field_descript
*&---------------------------------------------------------------------*
*&      Form  check_params
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PARAMS.
  DATA:
    LV_FILENAME TYPE LOCALFILE,
    LV_SUBRC    LIKE SY-SUBRC,
    LV_FULLNAME TYPE LOCALFILE,
    LV_STRING   TYPE STRING.
*++1765 #32.
**++0001 2007.01.03 BG (FMC)
*   CALL FUNCTION '/ZAK/USER_DEFAULT'
*     EXPORTING
*       USERS      = SY-UNAME
*     EXCEPTIONS
*       ERROR_DATF = 1
*       OTHERS     = 2.
*   IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
**--0001 2007.01.03 BG (FMC)
*--1765 #32.
  IF NOT P_BUKRS IS INITIAL AND
     NOT P_BTYPE IS INITIAL.
    SELECT SINGLE BTYPE INTO V_BTYPE FROM /ZAK/BEVALL
                        WHERE BUKRS EQ P_BUKRS AND
                              BTYPE EQ P_BTYPE .
    IF SY-SUBRC NE 0.
      MESSAGE E010 WITH P_BUKRS P_BTYPE .
    ENDIF.
    CLEAR: W_/ZAK/BEVALLD.
    IF NOT P_ISMET IS INITIAL AND
       NOT P_PACK IS INITIAL AND
       NOT P_BSZNUM IS INITIAL.
      SELECT SINGLE * FROM /ZAK/BEVALLSZ
             WHERE BUKRS  EQ P_BUKRS AND
                   BTYPE  EQ P_BTYPE AND
                   BSZNUM EQ P_BSZNUM AND
                   PACK   EQ P_PACK.
      IF SY-SUBRC NE 0.
        MESSAGE E067 WITH P_PACK P_BSZNUM..
      ENDIF.
    ENDIF.
  ENDIF.
* Adatszerkezet meghatározás és meglétének ellenörzése
  PERFORM CHECK_BEVALLD USING P_BUKRS
                              P_BTYPE
                              P_BSZNUM
                     CHANGING V_TYPE
                              V_STRNAME.
* ++ 0001 CST 2006.05.27
*   LV_STRING = P_FDIR.
*   CLEAR LV_ACTIVE.
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
*     EXPORTING
*       FILE            = LV_STRING
*     RECEIVING
*       RESULT          = LV_ACTIVE
*     EXCEPTIONS
*       CNTL_ERROR      = 1
*       ERROR_NO_GUI    = 2
*       WRONG_PARAMETER = 3
*       OTHERS          = 4.
*   IF SY-SUBRC <> 0.
*     MESSAGE E004 WITH P_FDIR.
*   ENDIF.
*   IF LV_ACTIVE NE C_FILE_X.
*     MESSAGE E004 WITH P_FDIR.
*   ENDIF.
  DATA: L_RET.
*++PTGSZLAA 2014.03.04 BG (Ness)
  IF NOT P_PREZ IS INITIAL.
*--PTGSZLAA 2014.03.04 BG (Ness)
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*     CALL FUNCTION 'WS_QUERY'
*       EXPORTING
*         QUERY    = 'FL'
*         FILENAME = P_FDIR
*       IMPORTING
*         RETURN   = L_RET.
    DATA L_FILE TYPE STRING.
    DATA L_RESULT TYPE C.
    MOVE P_FDIR TO L_FILE.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
      EXPORTING
        FILE            = L_FILE
      RECEIVING
        RESULT          = L_RESULT
      EXCEPTIONS
        CNTL_ERROR      = 1
        ERROR_NO_GUI    = 2
        WRONG_PARAMETER = 3
        OTHERS          = 4.
    MOVE L_RESULT TO L_RET.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*++PTGSZLAA 2014.03.04 BG (Ness)
  ELSEIF NOT P_APPL IS INITIAL.
    OPEN DATASET P_FDIR FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF SY-SUBRC NE 0.
      CLEAR L_RET.
    ELSE.
      L_RET = 'T'.
      CLOSE DATASET P_FDIR.
    ENDIF.
  ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
  CONDENSE L_RET NO-GAPS.
  IF L_RET EQ SPACE.
*   A megadott fájlt (&) nem lehet megnyitni!
    MESSAGE E004(/ZAK/ZAK) WITH P_FDIR.
  ENDIF.
* -- 0001 CST 2006.05.27
ENDFORM.                    " check_params
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BUKRS_FILENAME.
  DATA: BEGIN OF L_SPLIT OCCURS 0,
          LINE(80),
        END OF L_SPLIT.
  DATA  L_LINES TYPE I.
  DATA  L_LENGTH TYPE I.
*  Feldaraboljuk a fájl elérést.
  SPLIT P_FDIR AT '\' INTO TABLE L_SPLIT.
*  Az utolsó lesz a fájl név.
  DESCRIBE TABLE L_SPLIT LINES L_LINES.
  READ TABLE L_SPLIT INDEX L_LINES.
*  Meghatározzuk a vállalat hosszát
  L_LENGTH = STRLEN( P_BUKRS ).
*  Ha a fáhjl név nem a vállalat kóddal kezdődik:
  IF L_SPLIT-LINE(L_LENGTH) NE P_BUKRS.
    MESSAGE E194 WITH P_BUKRS.
*   Helytelen fájl! A fájl név nem a vállalat kóddal kezdődik! (&1)
  ENDIF.
ENDFORM.                    " CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*&      Form  filename_get
*&---------------------------------------------------------------------*
*       Elérési útvonal bevitele
*----------------------------------------------------------------------*
FORM FILENAME_GET.
  DATA:
*    L_MASK(20),
    L_FNAM(8),
    L_INX(3),
    L_RC       TYPE I,
    L_FILENAME LIKE P_FDIR,
    LT_FILE    TYPE FILETABLE,
    L_MULTISEL TYPE I,
    L_FILTER   TYPE STRING.
  CASE W_/ZAK/BEVALLD-FILETYPE.
    WHEN C_FILE_XLS.
      L_FILTER = '*.XLS'.
    WHEN C_FILE_TXT.
      L_FILTER = '*.TXT'.
    WHEN C_FILE_XML.
      L_FILTER = '*.XML'.
    WHEN C_FILE_SAP.
  ENDCASE.
* ++ 0001 CST 2006.05.27
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*     EXPORTING
**       WINDOW_TITLE
*        DEFAULT_EXTENSION = L_FILTER
*       DEFAULT_FILENAME  = 'C:\Temp'
**       FILE_FILTER       = ',*.*,*.*.'
*        FILE_FILTER       = L_FILTER "'*.CSV'
**       INIT_DIRECTORY    = ' '
**       MULTISELECTION
*     CHANGING
*       FILE_TABLE        = LT_FILE
*       RC                = L_RC
*     EXCEPTIONS
*       FILE_OPEN_DIALOG_FAILED = 1
*       CNTL_ERROR              = 2.
*
*   CHECK SY-SUBRC IS INITIAL AND L_RC NE -1.
*   READ TABLE LT_FILE INDEX 1 INTO P_FDIR.
* -- 0001 CST 2006.05.27
  DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*   CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING
*       DEF_FILENAME     = L_FILTER
**      def_path         =
*       MASK             = L_MASK
*       MODE             = 'O'
*       TITLE            = SY-TITLE
*     IMPORTING
*       FILENAME         = P_FDIR
**      RC               =  DUMMY
*     EXCEPTIONS
*       INV_WINSYS       = 04
*       NO_BATCH         = 08
*       SELECTION_CANCEL = 12
*       SELECTION_ERROR  = 16.
  DATA L_EXTENSION TYPE STRING.
  DATA L_TITLE     TYPE STRING.
  DATA L_FILE      TYPE STRING.
  DATA L_FULLPATH  TYPE STRING.
  L_TITLE = SY-TITLE.
  L_EXTENSION = L_MASK.
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      WINDOW_TITLE = L_TITLE
*     DEFAULT_EXTENSION = L_EXTENSION
*     DEFAULT_FILE_NAME =
*     WITH_ENCODING     =
      FILE_FILTER  = L_FILTER
*     INITIAL_DIRECTORY =
    IMPORTING
*     FILENAME     = L_FILE
*     PATH         =
      FULLPATH     = L_FULLPATH
*     USER_ACTION  =
*     FILE_ENCODING     =
    .
  P_FDIR = L_FULLPATH.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
  CHECK SY-SUBRC EQ 0.
ENDFORM.                    " FILENAME_GET
*   SORT I_SZJA001 BY DATUM.
*   LOOP AT I_SZJA001 INTO W_SZJA001.
*     AT END OF DATUM.
*       W_BEVALLI-DATUM = W_SZJA001-DATUM.
*       APPEND W_BEVALLI TO I_BEVALLI.
*
*       SELECT * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*          WHERE BUKRS = P_BUKRS AND
*                BTYPE = P_BTYPE AND
*                GJAHR = W_SZJA001-DATUM(4) AND
*                MONAT = W_SZJA001-DATUM+4(2).
*       ENDSELECT.
*       IF SY-SUBRC NE 0.
*         W_ELSO-DATUM = W_SZJA001-DATUM.
*         APPEND W_ELSO TO I_ELSO.
*       ENDIF.
*       SELECT * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
*          WHERE BUKRS = P_BUKRS AND
*                BTYPE = P_BTYPE AND
*                BSZNUM = P_BSZNUM AND
*                GJAHR = W_SZJA001-DATUM(4) AND
*                MONAT = W_SZJA001-DATUM+4(2).
*
*         IF     W_/ZAK/BEVALLI-FLAG EQ 'X'.
*           V_TEXT1 = TEXT-017.
*           V_TEXT2 = TEXT-018.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*
*         ELSEIF W_/ZAK/BEVALLI-FLAG EQ 'Z'.
*           V_TEXT1 = TEXT-019.
*           V_TEXT2 = TEXT-018.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*
*         ELSEIF W_/ZAK/BEVALLI-FLAG EQ 'B'.
*           V_TEXT1 = TEXT-020.
*           V_TEXT2 = TEXT-016.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*
*         ELSEIF W_/ZAK/BEVALLI-ZINDEX NE '000'.
*           V_TEXT1 = TEXT-015.
*           V_TEXT2 = TEXT-016.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*         ENDIF.
*       ENDSELECT.
*     ENDAT.
*   ENDLOOP.
*&---------------------------------------------------------------------*
*&      Form  check_bevalld
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      -->P_P_TYPE    text
*      -->P_P_SRNAME  text
*----------------------------------------------------------------------*
FORM CHECK_BEVALLD USING    $BUKRS LIKE T001-BUKRS
                            $BTYPE LIKE /ZAK/BEVALLD-BTYPE
                            $BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
                   CHANGING $TYPE LIKE /ZAK/BEVALLD-FILETYPE
                            $STRNAME LIKE /ZAK/BEVALLD-STRNAME.
*  CLEAR: W_/ZAK/BEVALLD.
** Adatszerkezet meghatározás
*  SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
*                  WHERE BUKRS  EQ $BUKRS AND
*                  BTYPE  EQ $BTYPE AND
*                  BSZNUM EQ $BSZNUM.
*  IF SY-SUBRC NE 0.
*    MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
*  ELSE.
*    IF W_/ZAK/BEVALLD-FILETYPE EQ '04'.
** SAP adatszolgáltatást jelenleg nem engedélyezett !
*      MESSAGE E006.
*    ENDIF.
**++2007.01.11 BG (FMC)
*    IF NOT W_/ZAK/BEVALLD-XSPEC IS INITIAL.
*      MESSAGE E205 WITH $BSZNUM.
**   & adatszolgáltatás speciálisra van beállítva! (/ZAK/BEVALLD)
*    ENDIF.
**--2007.01.11 BG (FMC)
*    $STRNAME = W_/ZAK/BEVALLD-STRNAME.
*    $TYPE    = W_/ZAK/BEVALLD-FILETYPE.
** XML formátumnál nem kell struktúra
*    IF  W_/ZAK/BEVALLD-FILETYPE NE '03'.
** Adatszerkezet meglétének ellenörzése!
*      SELECT SINGLE * INTO W_DD02L FROM DD02L
*                      WHERE TABNAME  EQ W_/ZAK/BEVALLD-STRNAME AND
*                            AS4LOCAL EQ C_A AND
*                            TABCLASS EQ C_CLASS.
** aktivált?
*      IF SY-SUBRC NE 0.
*        MESSAGE E050 WITH W_/ZAK/BEVALLD-STRNAME .
*      ENDIF.
*    ENDIF.
*  ENDIF.
ENDFORM.                    " check_bevalld

*&---------------------------------------------------------------------*
*&      Form  modif_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_SCREEN.
  IF NOT P_NORM IS INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'DIS'.
        SCREEN-INPUT = 0.
        SCREEN-OUTPUT = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF NOT P_ISMET IS INITIAL .
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'DIS'.
        SCREEN-INPUT = 1.
        SCREEN-OUTPUT = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'OUT'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " modif_screen
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_BEVALL USING    $BUKRS
                          $BTYPE.
* egy bevallás típus csak egy bevallás fajtához tartozhat, így
* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni!
  SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
                       WHERE BUKRS EQ $BUKRS AND
                             BTYPE EQ $BTYPE.
ENDFORM.                    " READ_BEVALL
*&---------------------------------------------------------------------*
*&      Form  ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_LIST .

  DATA:
    LT_RET  TYPE TABLE OF BAPIRET2,
    LO_ALV  TYPE REF TO CL_SALV_TABLE,
    LO_COLS TYPE REF TO CL_SALV_COLUMNS,
    LO_FUNC TYPE REF TO CL_SALV_FUNCTIONS_LIST.
  .....

  CHECK NOT P_ALV IS INITIAL AND SY-BATCH IS INITIAL.

  CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV  CHANGING T_TABLE = I_OUTTAB ).
  LO_COLS = LO_ALV->GET_COLUMNS( ).
  LO_COLS->SET_OPTIMIZE( ).
  LO_FUNC  = LO_ALV->GET_FUNCTIONS( ).
  LO_FUNC->SET_ALL( ABAP_TRUE ).
  LO_ALV->DISPLAY( ).


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TESZT  text
*----------------------------------------------------------------------*
FORM UPD_DATA  USING    $TESZT.

  DATA LW_/ZAK/MIGR_ANAL TYPE /ZAK/MIGR_ANAL.
  RANGES LR_ABEVAZ FOR /ZAK/MIGR_ANAL-ABEVAZ.

  CHECK $TESZT IS INITIAL.

  IF NOT P_XML IS INITIAL.
    LOOP AT I_OUTTAB INTO W_OUTTAB WHERE NOT ADOAZON IS INITIAL.
      IF LW_/ZAK/MIGR_ANAL IS INITIAL.
        MOVE-CORRESPONDING W_OUTTAB TO LW_/ZAK/MIGR_ANAL.
      ENDIF.
      M_DEF R_ADOAZON 'I' 'EQ' W_OUTTAB-ADOAZON ''.
    ENDLOOP.
    IF NOT R_ADOAZON[] IS INITIAL.
      M_DEF LR_ABEVAZ 'I' 'CP' 'M*' ''.
      DELETE FROM /ZAK/MIGR_ANAL WHERE BUKRS EQ LW_/ZAK/MIGR_ANAL-BUKRS
                             AND BTYPE EQ LW_/ZAK/MIGR_ANAL-BTYPE
                             AND GJAHR EQ LW_/ZAK/MIGR_ANAL-GJAHR
                             AND MONAT EQ LW_/ZAK/MIGR_ANAL-MONAT
                             AND ABEVAZ IN LR_ABEVAZ
                             AND ADOAZON IN R_ADOAZON.
    ENDIF.
  ENDIF.

  MODIFY /ZAK/MIGR_ANAL FROM TABLE I_OUTTAB.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE I216.
*   Adatmódosítások elmentve!
  ELSE.
    ROLLBACK WORK.
    MESSAGE E000 WITH 'Hiba a mentésnél!' SY-SUBRC.
*   & & & &
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MOD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOD_DATA .

  FIELD-SYMBOLS <DATA> TYPE /ZAK/ANALITIKA.

  LOOP AT I_OUTTAB ASSIGNING <DATA>.
    CLEAR <DATA>-ITEM.
  ENDLOOP.


ENDFORM.
