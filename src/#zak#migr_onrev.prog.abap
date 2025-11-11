*&---------------------------------------------------------------------*
*& Program: Migrációs program önrevízióhoz - státuszok kezelése
*&---------------------------------------------------------------------*
REPORT /ZAK/MIGR_ONREV MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: Migrációs program önrevízióhoz - státuszok kezelése
*&---------------------------------------------------------------------*
*& Szerző            : Cserhegyi Tímea - fmc
*& Létrehozás dátuma : 2006.04.05
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
*& 0001   2006/05/27   Cserhegyi T.  CL_GUI_FRONTEND_SERVICES
*&                                   cseréje hagyományosra
*& 0002   2007/05/09   Balázs G.     Általánosítás, hogy ne csak ÁFA
*&                                   migrációhoz lehessen használni.
*&---------------------------------------------------------------------*
*++S4HANA#01.
DATA: L_SUBRC TYPE SY-SUBRC.
*--S4HANA#01.
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/READ_TOP.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
* file típusok
CONSTANTS: C_FILE_XLS(2) TYPE C VALUE   '02',
           C_FILE_TXT(2) TYPE C VALUE   '01',
           C_FILE_XML(2) TYPE C VALUE   '03',
           C_FILE_SAP(2) TYPE C VALUE   '04',
           C_CLASS       TYPE DD02L-TABCLASS VALUE 'INTTAB',
           C_A(1)        TYPE C VALUE   'A',
           C_END_ROW     TYPE I VALUE '65536',
           C_BEGIN_ROW   TYPE I VALUE    '1'.

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

TYPES: BEGIN OF /ZAK/ZAK_MIGR,
         OFLAG(1) TYPE C,
         DATUM(8) TYPE C,
       END OF /ZAK/ZAK_MIGR.


DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
      V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.

DATA: V_BEGIN_COL TYPE I,
      V_END_COL   TYPE I.


DATA: I_XLS      TYPE STANDARD TABLE OF ALSMEX_TABLINE
                                                    INITIAL SIZE 0,
      I_DD03P    TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0,
      I_MAIN_STR TYPE STANDARD TABLE OF DD03P       INITIAL SIZE 0.

DATA: I_OUTTAB    TYPE STANDARD TABLE OF /ZAK/MIGRACI01 INITIAL SIZE 0,
      I_OUTTAB_EX TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.

* Hiba adaszerkezet tábla
DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
DATA: I_LINE TYPE STANDARD TABLE OF /ZAK/LINE            INITIAL SIZE 0.



* excel betöltéshez
DATA: W_XLS      TYPE ALSMEX_TABLINE,
      W_DD03P    TYPE DD03P,
      W_MAIN_STR TYPE DD03P,
      WA_DD03P   TYPE DD03P,
      W_LINE     TYPE /ZAK/LINE.



DATA: W_OUTTAB  TYPE /ZAK/MIGRACI01,
      W_BEVALLI TYPE /ZAK/BEVALLI,
      W_ELSO    TYPE /ZAK/BEVALLI.
* adatszerkezet hiba
DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.


* ALV kezelési változók
DATA: V_OK_CODE          LIKE SY-UCOMM,
      V_SAVE_OK          LIKE SY-UCOMM,
      V_REPID            LIKE SY-REPID,
      V_CONTAINER        TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_GRID             TYPE REF TO CL_GUI_ALV_GRID,
      V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT         TYPE LVC_T_FCAT,
      V_LAYOUT           TYPE LVC_S_LAYO,
      V_VARIANT          TYPE DISVARIANT.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-101.
    PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS
                              VALUE CHECK
                              OBLIGATORY MEMORY ID BUK.
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-102 FOR FIELD P_BTYPE.
    PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE OBLIGATORY
*++0002 BG 2007.05.09
                               MEMORY ID /ZAK/ZBTY.
*--0002 BG 2007.05.09
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-T02.
    PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*++0002 BG 2007.05.09
*                         MATCHCODE OBJECT /ZAK/BEVD
                              OBLIGATORY.
*--0002 BG 2007.05.09
  SELECTION-SCREEN END OF BLOCK B02.


  SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-T03.
    PARAMETERS: P_FDIR LIKE FC03TAB-PL00_FILE,
*++0002 BG 2007.05.16
                P_HEAD AS CHECKBOX DEFAULT 'X',
*--0002 BG 2007.05.16
                P_TEST AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK B03.

SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*++0002 BG 2007.05.09
* P_BTYPE = '0665'.
*--0002 BG 2007.05.09

  PERFORM READ_ADDITIONALS.
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

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_ATTRIBUTES.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  SET PARAMETER ID 'BUK' FIELD P_BUKRS.
  PERFORM READ_ADDITIONALS.
  PERFORM CHECK_PARAMS.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FDIR.
  PERFORM FILENAME_GET.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

*  Bevallás fajta meghatározása
  PERFORM READ_BEVALL USING P_BUKRS
                            P_BTYPE.

*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                W_/ZAK/BEVALL-BTYPART
                                C_ACTVT_01.

* vezérlő táblák olvasása
  PERFORM READ_CUST_TABLE USING P_BUKRS
                                P_BTYPE
                                P_BSZNUM.

  CLEAR: V_TYPE,V_STRNAME.
* Adatszerkezet meghatározás és meglétének ellenörzése
  PERFORM CHECK_BEVALLD USING P_BUKRS
                              P_BTYPE
                              P_BSZNUM
                     CHANGING V_TYPE
                              V_STRNAME.



* Adatszerkezethez tartozó mező ellenörzések, és
* az oszlopok számának meghatározása.
  PERFORM CHECK_FIELDTYP USING    V_STRNAME
                         CHANGING V_END_COL.


* Analitika tábla szerkezet
  PERFORM GET_ANALITIKA_STRUCT USING '/ZAK/ANALITIKA'.

* Adatszerkezet-mező összerendelés meghatározása
* Csak ABEV azonosítóval rendelkező mezőket dolgozunk fel!
  PERFORM CHECK_BEVALLC USING P_BUKRS
                              P_BTYPE
                              V_STRNAME
                              P_BSZNUM.


* Adatszolgáltatás fájl formátuma alapján meghívom a betöltő funkciókat
  CASE V_TYPE.
    WHEN C_FILE_XLS.
*
      V_BEGIN_COL = 1.
* a hibák a I_HIBA táblában!
      CALL FUNCTION '/ZAK/XLS'
        EXPORTING
          FILENAME                = P_FDIR
          I_BEGIN_COL             = V_BEGIN_COL
          I_BEGIN_ROW             = C_BEGIN_ROW
          I_END_COL               = V_END_COL
          I_END_ROW               = C_END_ROW
          I_STRNAME               = V_STRNAME
          I_BUKRS                 = P_BUKRS
*++0002 BG 2007.05.16
          I_HEAD                  = P_HEAD
*--0002 BG 2007.05.16
        TABLES
          INTERN                  = I_XLS
          CHECK_TAB               = I_DD03P  "adatszerkezet
          E_HIBA                  = I_HIBA
          I_LINE                  = I_LINE
        EXCEPTIONS
          INCONSISTENT_PARAMETERS = 1
          UPLOAD_OLE              = 2
          FILE_OPEN_ERROR         = 3
          INVALID_TYPE            = 4
          CONVERSION_ERROR        = 5
          OTHERS                  = 6.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
* Belső tábla kitöltés I_OUTTAB
        PERFORM FILL_DATATAB USING I_XLS[]
                                   I_DD03P[]
                                   I_MAIN_STR[]
                                   I_/ZAK/BEVALLC[]
                                   I_LINE[]
                                   V_STRNAME.
        CHECK NOT I_OUTTAB[] IS INITIAL.
      ENDIF.



    WHEN C_FILE_TXT.
      CALL FUNCTION '/ZAK/TXT'
        EXPORTING
          FILENAME                = P_FDIR
          I_STRNAME               = V_STRNAME
          I_BUKRS                 = P_BUKRS
*++0002 BG 2007.05.16
          I_HEAD                  = P_HEAD
*--0002 BG 2007.05.16
        TABLES
          INTERN                  = I_XLS
          CHECK_TAB               = I_DD03P
          E_HIBA                  = I_HIBA
          I_LINE                  = I_LINE
        EXCEPTIONS
          CONVERSION_ERROR        = 1
          FILE_OPEN_ERROR         = 2
          FILE_READ_ERROR         = 3
          INVALID_TYPE            = 4
          GUI_REFUSE_FILETRANSFER = 5
          OTHERS                  = 6.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
* Belső tábla kitöltés I_OUTTAB
        PERFORM FILL_DATATAB USING I_XLS[]
                                   I_DD03P[]
                                   I_MAIN_STR[]
                                   I_/ZAK/BEVALLC[]
                                   I_LINE[]
                                   V_STRNAME.
        CHECK NOT I_OUTTAB[] IS INITIAL.

      ENDIF.
    WHEN C_FILE_XML.

*      CALL FUNCTION '/ZAK/XML'
*           EXPORTING
*                FILENAME                = P_FDIR
*                I_STRNAME               = V_STRNAME
*                I_BUKRS                 = P_BUKRS
*                I_BTYPE                 = P_BTYPE
*                I_BSZNUM                = P_BSZNUM
*           TABLES
*                INTERN                  = I_XLS
*                CHECK_TAB               = I_DD03P
*                E_HIBA                  = I_HIBA
*                I_LINE                  = I_LINE
*                I_/ZAK/ANALITIKA         = I_OUTTAB
*           EXCEPTIONS
*                INCONSISTENT_PARAMETERS = 1
*                UPLOAD_OLE              = 2
*                FILE_OPEN_ERROR         = 3
*                INVALID_TYPE            = 4
*                CONVERSION_ERROR        = 5
*                OTHERS                  = 6.
*      IF SY-SUBRC <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
    WHEN C_FILE_SAP.
  ENDCASE.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  IF P_TEST = C_X.
    PERFORM LIST_DISPLAY.
  ELSE.
    PERFORM UPDATE_STATUS.
    PERFORM LIST_DISPLAY.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  READ_ADDITIONALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS.
* Vállalat megnevezése
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.


    IF NOT P_BTYPE IS INITIAL.
*++S4HANA#01.
*      SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
*          WHERE LANGU = SY-LANGU
*            AND BUKRS = P_BUKRS
*            AND BTYPE = P_BTYPE.
      SELECT BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT UP TO 1 ROWS
        WHERE LANGU = SY-LANGU
          AND BUKRS = P_BUKRS
          AND BTYPE = P_BTYPE
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.
    ENDIF.

  ENDIF.

ENDFORM.                    " READ_ADDITIONALS
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
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

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
" CHECK_SEL_SCREEN
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
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
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    EXPORTING
**       WINDOW_TITLE
*       DEFAULT_EXTENSION = L_FILTER
*      DEFAULT_FILENAME  = 'C:\Temp'
**       FILE_FILTER       = ',*.*,*.*.'
*       FILE_FILTER       = L_FILTER "'*.CSV'
**       INIT_DIRECTORY    = ' '
**       MULTISELECTION
*    CHANGING
*      FILE_TABLE        = LT_FILE
*      RC                = L_RC
*    EXCEPTIONS
*      FILE_OPEN_DIALOG_FAILED = 1
*      CNTL_ERROR              = 2.


*  CHECK SY-SUBRC IS INITIAL AND L_RC NE -1.
*  READ TABLE LT_FILE INDEX 1 INTO P_FDIR.
*
*  CHECK SY-SUBRC EQ 0.
*++S4HANA#01.
*  DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
**--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
**  CALL FUNCTION 'WS_FILENAME_GET'
**     EXPORTING  DEF_FILENAME     =  L_FILTER
***               def_path         =
**                MASK             =  L_MASK
**                MODE             = 'O'
**                TITLE            =  SY-TITLE
**     IMPORTING  FILENAME         =  P_FDIR
***               RC               =  DUMMY
**     EXCEPTIONS INV_WINSYS       =  04
**                NO_BATCH         =  08
**                SELECTION_CANCEL =  12
**                SELECTION_ERROR  =  16.
*  DATA L_EXTENSION TYPE STRING.
*  DATA L_TITLE     TYPE STRING.
*  DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.
*
*  L_TITLE = SY-TITLE.
*  L_EXTENSION = L_MASK.
*
*  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
*    EXPORTING
*      WINDOW_TITLE = L_TITLE
**     DEFAULT_EXTENSION = L_EXTENSION
**     DEFAULT_FILE_NAME =
**     WITH_ENCODING     =
*      FILE_FILTER  = L_FILTER
**     INITIAL_DIRECTORY =
*    IMPORTING
**     FILENAME     = L_FILE
**     PATH         =
*      FULLPATH     = L_FULLPATH
**     USER_ACTION  =
**     FILE_ENCODING     =
*    .
*  P_FDIR = L_FULLPATH.
  DATA: L_MASK   TYPE C LENGTH 20 VALUE ',*.*  ,*.*.'.


  DATA: LT_FILE_TABLE_0     TYPE FILETABLE,
        LS_W_FILE_TABLE_0   LIKE LINE OF LT_FILE_TABLE_0,
        LV_W_RC_0           TYPE I,
        LV_W_TITLE_0        TYPE STRING,
        LV_W_SYSUBRC_TEMP_0 TYPE SY-SUBRC.

  DATA: LV_W_DEFAULT_FILENAME_0 TYPE STRING.
  LV_W_DEFAULT_FILENAME_0 = L_FILTER.

  LV_W_TITLE_0 = SY-TITLE.

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
    P_FDIR = LS_W_FILE_TABLE_0-FILENAME.
  ENDIF.

  SY-SUBRC = LV_W_SYSUBRC_TEMP_0.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

  CHECK SY-SUBRC EQ 0.
* -- 0001 CST 2006.05.27

ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  CHECK_PARAMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PARAMS.
  DATA: LV_ACTIVE TYPE ABAP_BOOL,
        LV_STRING TYPE STRING.

* Vállalat + Bevallás típus
  IF NOT P_BUKRS IS INITIAL AND
     NOT P_BTYPE IS INITIAL.

*++S4HANA#01.
*    SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
*                        WHERE BUKRS EQ P_BUKRS AND
*                              BTYPE EQ P_BTYPE .
    SELECT * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL UP TO 1 ROWS
                        WHERE BUKRS EQ P_BUKRS AND
                              BTYPE EQ P_BTYPE
                        ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.
    IF SY-SUBRC NE 0.
      MESSAGE E010(/ZAK/ZAK) WITH P_BUKRS P_BTYPE .
    ENDIF.

  ENDIF.

* Adatszolgáltatás
  IF P_BSZNUM IS INITIAL.
    MESSAGE E161(/ZAK/ZAK) WITH P_BUKRS P_BTYPE .
  ENDIF.

* Adatszerkezet meghatározás és meglétének ellenörzése
  PERFORM CHECK_BEVALLD USING P_BUKRS
                              P_BTYPE
                              P_BSZNUM
                     CHANGING V_TYPE
                              V_STRNAME.


* Összes adatszolgáltatás
  PERFORM GET_BEVALLD   USING P_BUKRS
                              P_BTYPE.

* ++ 0001 CST 2006.05.27
*  LV_STRING = P_FDIR.
*  CLEAR LV_ACTIVE.

*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
*    EXPORTING
*      FILE            = LV_STRING
*    RECEIVING
*      RESULT          = LV_ACTIVE
*    EXCEPTIONS
*      CNTL_ERROR      = 1
*      ERROR_NO_GUI    = 2
*      WRONG_PARAMETER = 3
*      OTHERS          = 4.
*  IF SY-SUBRC <> 0.
*    MESSAGE E004(/zak/zak) WITH P_FDIR.
*  ENDIF.
*  IF LV_ACTIVE NE 'X'.
*    MESSAGE E004(/zak/zak) WITH P_FDIR.
*  ENDIF.
  DATA: L_RET.
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*  CALL FUNCTION 'WS_QUERY'
*    EXPORTING
*      QUERY    = 'FL'
*      FILENAME = P_FDIR
*    IMPORTING
*      RETURN   = L_RET.
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

  CONDENSE L_RET NO-GAPS.
  IF L_RET EQ SPACE.
*   A megadott fájlt (&) nem lehet megnyitni!
    MESSAGE E004(/ZAK/ZAK) WITH P_FDIR.
  ENDIF.

* -- 0001 CST 2006.05.27
ENDFORM.                    " CHECK_PARAMS
*&---------------------------------------------------------------------*
*&      Form  CHECK_BEVALLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      <--P_V_TYPE  text
*      <--P_V_STRNAME  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_BEVALLD USING    $BUKRS LIKE T001-BUKRS
*                            $BTYPE LIKE /ZAK/BEVALLD-BTYPE
*                            $BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                   CHANGING $TYPE LIKE /ZAK/BEVALLD-FILETYPE
*                            $STRNAME LIKE /ZAK/BEVALLD-STRNAME.
FORM CHECK_BEVALLD USING    $BUKRS TYPE T001-BUKRS
                            $BTYPE TYPE /ZAK/BEVALLD-BTYPE
                            $BSZNUM TYPE /ZAK/BEVALLD-BSZNUM
                   CHANGING $TYPE TYPE /ZAK/BEVALLD-FILETYPE
                            $STRNAME TYPE /ZAK/BEVALLD-STRNAME.
*--S4HANA#01.

  DATA: W_DD02L TYPE DD02L.

  CLEAR: W_/ZAK/BEVALLD.
* Adatszerkezet meghatározás
  SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
                  WHERE BUKRS  EQ $BUKRS AND
                  BTYPE  EQ $BTYPE AND
                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
    MESSAGE E011(/ZAK/ZAK) WITH $BUKRS $BTYPE $BSZNUM.
  ELSE.
    IF W_/ZAK/BEVALLD-FILETYPE EQ '04'.
* SAP adatszolgáltatást jelenleg nem engedélyezett !
      MESSAGE E006(/ZAK/ZAK).
    ENDIF.
* Adatszerkezet meglétének ellenörzése!
*++S4HANA#01.
*    SELECT SINGLE * INTO W_DD02L FROM DD02L
*                    WHERE TABNAME  EQ W_/ZAK/BEVALLD-STRNAME AND
*                          AS4LOCAL EQ C_A AND
*                          TABCLASS EQ C_CLASS.
    SELECT SINGLE @SPACE FROM DD02L
                WHERE TABNAME  EQ @W_/ZAK/BEVALLD-STRNAME AND
                      AS4LOCAL EQ @C_A AND
                      TABCLASS EQ @C_CLASS INTO @W_DD02L.
*--S4HANA#01.
* aktivált?
    IF SY-SUBRC NE 0.
      MESSAGE E050(/ZAK/ZAK) WITH W_/ZAK/BEVALLD-STRNAME .
    ELSE.
      $STRNAME = W_/ZAK/BEVALLD-STRNAME.
      $TYPE    = W_/ZAK/BEVALLD-FILETYPE.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_BEVALLD
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM READ_BEVALL USING    $BUKRS
*                          $BTYPE.
FORM READ_BEVALL USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                          $BTYPE TYPE /ZAK/BEVALL-BTYPE.
*--S4HANA#01.
* egy bevallás típus csak egy bevallás fajtához tartozhat, így
* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni!
  SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
                       WHERE BUKRS EQ $BUKRS AND
                             BTYPE EQ $BTYPE
*++S4HANA#01.
                       ORDER BY PRIMARY KEY.
*--S4HANA#01.
  ENDSELECT.
ENDFORM.                    " READ_BEVALL
*&---------------------------------------------------------------------*
*&      Form  READ_CUST_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*----------------------------------------------------------------------*
FORM READ_CUST_TABLE USING    $BUKRS  LIKE T001-BUKRS
                              $BTYPE  LIKE /ZAK/BEVALL-BTYPE
                              $BSZNUM LIKE /ZAK/BEVALLD-BSZNUM.
* Bevallás adatszolgáltatás feltöltések  !
  SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
                            WHERE BUKRS  EQ $BUKRS AND
                                  BTYPE  EQ $BTYPE AND
                                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
*   MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
  ENDIF.

* Adatszerkezet-mező összerendelés meghatározása
*++S4HANA#01.
*  SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
*                            WHERE BTYPE EQ $BTYPE AND
*                                  BSZNUM EQ $BSZNUM.
  SELECT @SPACE FROM /ZAK/BEVALLC
                            WHERE BTYPE EQ @$BTYPE AND
                                  BSZNUM EQ @$BSZNUM INTO TABLE @I_/ZAK/BEVALLC.
*--S4HANA#01.
  IF SY-SUBRC NE 0.
*     MESSAGE E010 WITH $BUKRS $BTYPE .
  ENDIF.
ENDFORM.                    " READ_CUST_TABLE
*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELDTYP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_STRNAME  text
*      <--P_V_END_COL  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_FIELDTYP USING    $STRNAME
*                    CHANGING $V_END_COL.
*
*  REFRESH: I_DD03P.
FORM CHECK_FIELDTYP USING    $STRNAME TYPE /ZAK/BEVALLD-STRNAME
                    CHANGING $V_END_COL LIKE V_END_COL.

  CLEAR: I_DD03P[].
*--S4HANA#01.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      NAME          = $STRNAME
*     STATE         = 'A'
      LANGU         = SY-LANGU
    TABLES
      DD03P_TAB     = I_DD03P
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  $V_END_COL = SY-TFILL.

ENDFORM.                    " CHECK_FIELDTYP
*&---------------------------------------------------------------------*
*&      Form  GET_ANALITIKA_STRUCT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0244   text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_ANALITIKA_STRUCT USING  $ANALITIKA.
FORM GET_ANALITIKA_STRUCT USING  $ANALITIKA TYPE CLIKE..
*--S4HANA#01.
  DATA: I_MAIN_STR TYPE STANDARD TABLE OF DD03P INITIAL SIZE 0.

*++S4HANA#01.
*  REFRESH: I_MAIN_STR.
  CLEAR: I_MAIN_STR[].
*--S4HANA#01.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      NAME          = $ANALITIKA
      LANGU         = SY-LANGU
    TABLES
      DD03P_TAB     = I_MAIN_STR
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " GET_ANALITIKA_STRUCT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BEVALLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_BEVALLC USING    $BUKRS
*                            $BTYPE
*                            $STRNAME
*                            $BSZNUM.
FORM CHECK_BEVALLC USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                            $BTYPE TYPE /ZAK/BEVALL-BTYPE
                            $STRNAME TYPE /ZAK/BEVALLD-STRNAME
                            $BSZNUM TYPE /ZAK/BEVALLD-BSZNUM.
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
                            WHERE BTYPE   EQ $BTYPE AND
                                  BSZNUM  EQ $BSZNUM AND
                                  SZTABLE EQ $STRNAME.
  IF SY-SUBRC NE 0.
*     MESSAGE E010 WITH $BUKRS $BTYPE .
  ENDIF.
ENDFORM.                    " CHECK_BEVALLC
*&---------------------------------------------------------------------*
*&      Form  FILL_DATATAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_XLS[]  text
*      -->P_I_DD03P[]  text
*      -->P_I_MAIN_STR[]  text
*      -->P_I_/ZAK/BEVALLC[]  text
*      -->P_I_LINE[]  text
*      -->P_V_STRNAME  text
*----------------------------------------------------------------------*
FORM FILL_DATATAB USING    $I_XLS     LIKE I_XLS[]
                           $I_DD03P   LIKE I_DD03P[]
                           $I_MAIN_STR LIKE I_MAIN_STR[] "analitika str
                           $I_BEVALLC LIKE I_/ZAK/BEVALLC[]
                           $I_LINE    LIKE I_LINE[]
*++S4HANA#01.
*                           $V_STRNAME.
                           $V_STRNAME TYPE /ZAK/BEVALLD-STRNAME..
*--S4HANA#01.
  DATA: V_WAERS LIKE T001-WAERS.
  DATA: V_WNUM(30) TYPE N.

  DATA: G_TABIX    LIKE SY-TABIX,
        L_ADOAZON  LIKE /ZAK/ANALITIKA-ADOAZON,
        L_BELNR    LIKE /ZAK/ANALITIKA-BSEG_BELNR,
        L_HKONT    LIKE /ZAK/ANALITIKA-HKONT,
        L_KOSTL    LIKE /ZAK/ANALITIKA-KOSTL,
        L_AUFNR    LIKE /ZAK/ANALITIKA-AUFNR,
        L_ITEM     LIKE /ZAK/ANALITIKA-ITEM,
        L_DATUM(6) TYPE C,
        L_INDX(3)  TYPE N.
  DATA COUNT TYPE I.


  CLEAR V_TAB.
  CONCATENATE 'W_' $V_STRNAME INTO V_TAB.
  ASSIGN (V_TAB) TO <F2>.

*
  LOOP AT $I_XLS INTO W_XLS.
    IF NOT W_XLS-VALUE IS INITIAL.
      READ TABLE $I_DD03P INTO W_DD03P
                          WITH KEY POSITION = W_XLS-COL.

      IF W_DD03P-FIELDNAME EQ 'DATUM'.
        CLEAR L_DATUM.
        CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
          EXPORTING
            INPUT      = W_XLS-VALUE
            NO_MESSAGE = 'X'
          IMPORTING
            OUTPUT     = L_DATUM.
*         L_DATUM = W_XLS-VALUE.
      ENDIF.
      READ TABLE I_LINE INTO W_LINE INDEX W_XLS-ROW.
      IF SY-SUBRC EQ 0.
        <F2> = W_LINE.
      ENDIF.


      IF W_DD03P-FIELDNAME EQ 'MTYPE'.
        W_OUTTAB-MTYPE = W_XLS-VALUE.
        TRANSLATE W_OUTTAB-MTYPE TO UPPER CASE.
      ENDIF.

      AT NEW ROW.
        CLEAR W_OUTTAB.
      ENDAT.


      AT END OF ROW.


        LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.

          W_OUTTAB-BUKRS  = P_BUKRS.
          W_OUTTAB-BTYPE  = P_BTYPE.
          W_OUTTAB-BSZNUM = W_/ZAK/BEVALLD-BSZNUM.
          W_OUTTAB-ZINDEX = '000'.
          CLEAR W_OUTTAB-PACK .
          W_OUTTAB-GJAHR = L_DATUM+0(4).
          W_OUTTAB-MONAT = L_DATUM+4(2).
          W_OUTTAB-ATEXT = TEXT-A01.

          W_OUTTAB-LIGHT = 2.
*++0002 BG 2007.05.16
*         APPEND W_OUTTAB TO I_OUTTAB.
          COLLECT W_OUTTAB INTO I_OUTTAB.
*--0002 BG 2007.05.16
        ENDLOOP.
      ENDAT.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " FILL_DATATAB
*&---------------------------------------------------------------------*
*&      Form  MOVE_CORR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_XLS[]  text
*      -->P_$I_DD03P[]  text
*      -->P_$I_MAIN_STR[]  text
*      -->P_W_LINE  text
*      -->P_W_XLS_ROW  text
*      <--P_W_OUTTAB  text
*----------------------------------------------------------------------*
FORM MOVE_CORR USING    $XLS       LIKE I_XLS[]
                        $DD03P     LIKE I_DD03P[]
                        $MAIN_STR  LIKE I_MAIN_STR[]
                        $LINE      LIKE /ZAK/LINE
                        $ROW
               CHANGING $W_OUTTAB  TYPE /ZAK/ANALITIKA.

  DATA: WA_XLS TYPE ALSMEX_TABLINE.
  CLEAR WA_XLS.
* analitika mezők megfeleltetése az adatszerkezetnek!
* Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát
  LOOP AT $MAIN_STR INTO W_MAIN_STR.
    READ TABLE $DD03P INTO WA_DD03P
                      WITH KEY FIELDNAME = W_MAIN_STR-FIELDNAME .
    IF SY-SUBRC EQ 0.
      READ TABLE $XLS INTO WA_XLS
                     WITH KEY ROW  = $ROW
                              COL = WA_DD03P-POSITION.
      IF SY-SUBRC EQ 0.
        CLEAR V_TAB_FIELD.
        CONCATENATE '$W_OUTTAB' '-' W_MAIN_STR-FIELDNAME
        INTO V_TAB_FIELD.
        ASSIGN (V_TAB_FIELD) TO <F1>.
        MOVE WA_XLS-VALUE TO <F1>.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " MOVE_CORR
*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  CALL SCREEN 9000.
ENDFORM.                    " list_display
*&---------------------------------------------------------------------*
*&      Module  pbo_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_9000 OUTPUT.
  PERFORM SET_STATUS.

  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_OUTTAB[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.

ENDMODULE.                 " pbo_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_STATUS.
  SET PF-STATUS 'MAIN9000'.
  SET TITLEBAR 'MAIN9000'.
ENDFORM.                    " SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING PT_OUTTAB   LIKE I_OUTTAB[]
                                  PT_FIELDCAT TYPE LVC_T_FCAT
                                  PS_LAYOUT   TYPE LVC_S_LAYO
                                  PS_VARIANT  TYPE DISVARIANT.

  DATA: I_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER.

* Mezőkatalógus összeállítása
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING PT_FIELDCAT.

* Funkciók kizárása
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

  PS_LAYOUT-CWIDTH_OPT = C_X.
  PS_LAYOUT-EXCP_FNAME = 'LIGHT'.
* allow to select multiple lines
*  PS_LAYOUT-SEL_MODE = 'A'.


  CLEAR PS_VARIANT.
  PS_VARIANT-REPORT = V_REPID.

  SORT I_OUTTAB.

  CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT      = PS_VARIANT
      I_SAVE          = 'A'
      I_DEFAULT       = C_X
      IS_LAYOUT       = PS_LAYOUT
    CHANGING
      IT_FIELDCATALOG = PT_FIELDCAT
      IT_OUTTAB       = PT_OUTTAB.

ENDFORM.                    " CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_DYNNR  text
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT USING    P_DYNNR     LIKE SYST-DYNNR
                    CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/MIGRACI01'
      I_BYPASSING_BUFFER = C_X
    CHANGING
      CT_FIELDCAT        = PT_FIELDCAT.


ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  pai_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_9000 INPUT.
*++S4HANA#01.
*  DATA: L_SUBRC LIKE SY-SUBRC.
*--S4HANA#01.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.

* Vissza
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

* Kilépés
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.

    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " PAI_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM.
  LEAVE PROGRAM.
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  update_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_STATUS.
  DATA: L_OUTTAB LIKE W_OUTTAB.
  DATA: L_STAMP LIKE  TZONREF-TSTAMPS.

*++0002 BG 2007.05.16
  DATA: L_HEAD_DATA(80).
  DATA: L_HEAD_DATA_SAVE LIKE L_HEAD_DATA.
*--0002 BG 2007.05.16

  SORT I_OUTTAB.
  LOOP AT I_OUTTAB INTO W_OUTTAB.
    L_OUTTAB = W_OUTTAB.

    CHECK L_OUTTAB-MTYPE = C_X.
*++0002 BG 2007.05.16
*    AT NEW ZINDEX.
    CLEAR L_HEAD_DATA.
    CONCATENATE W_OUTTAB-BUKRS
                W_OUTTAB-BTYPE
                W_OUTTAB-GJAHR
                W_OUTTAB-MONAT
                W_OUTTAB-ZINDEX INTO L_HEAD_DATA.

    IF L_HEAD_DATA NE L_HEAD_DATA_SAVE.
*--0002 BG 2007.05.16

      CLEAR W_/ZAK/BEVALLI.
      MOVE-CORRESPONDING L_OUTTAB TO W_/ZAK/BEVALLI.

      IF L_OUTTAB-MTYPE = C_X.
        W_/ZAK/BEVALLI-FLAG = 'Z'.
      ELSE.
        W_/ZAK/BEVALLI-FLAG = 'F'.
      ENDIF.

      W_/ZAK/BEVALLI-DATUM = SY-DATUM.
      W_/ZAK/BEVALLI-UZEIT = SY-UZEIT.
      W_/ZAK/BEVALLI-UNAME = SY-UNAME.

      INSERT INTO /ZAK/BEVALLI VALUES W_/ZAK/BEVALLI.
      IF SY-SUBRC = 0.
        W_OUTTAB = L_OUTTAB.
        W_OUTTAB-LIGHT = 3.
        W_OUTTAB-ATEXT = TEXT-A02.
      ELSE.
        W_OUTTAB = L_OUTTAB.
        W_OUTTAB-LIGHT = 3.
        W_OUTTAB-ATEXT = TEXT-A03.
      ENDIF.
      MODIFY I_OUTTAB FROM W_OUTTAB.
*++0002 BG 2007.05.16
      MOVE L_HEAD_DATA TO L_HEAD_DATA_SAVE.
    ENDIF.
*   ENDAT.
*--0002 BG 2007.05.16

    CLEAR W_/ZAK/BEVALLSZ.
    MOVE-CORRESPONDING W_OUTTAB TO W_/ZAK/BEVALLSZ.

    IF W_OUTTAB-MTYPE = C_X.
      W_/ZAK/BEVALLSZ-FLAG = 'Z'.
    ELSE.
      W_/ZAK/BEVALLSZ-FLAG = 'F'.
    ENDIF.

    W_/ZAK/BEVALLSZ-DATUM = SY-DATUM.
    W_/ZAK/BEVALLSZ-UZEIT = SY-UZEIT.
    W_/ZAK/BEVALLSZ-UNAME = SY-UNAME.

    CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
      EXPORTING
        I_DATLO     = SY-DATLO
        I_TIMLO     = SY-TIMLO
      IMPORTING
        E_TIMESTAMP = L_STAMP.

    W_/ZAK/BEVALLSZ-LARUN = L_STAMP.

    INSERT INTO /ZAK/BEVALLSZ VALUES W_/ZAK/BEVALLSZ.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.
* Listára csak a BEVALLI rekordok kellenek.
  DELETE I_OUTTAB WHERE LIGHT EQ 2.

  LOOP AT I_OUTTAB INTO W_OUTTAB.
    CLEAR W_OUTTAB-BSZNUM.
    MODIFY I_OUTTAB FROM W_OUTTAB.
  ENDLOOP.

ENDFORM.                    " update_status
*&---------------------------------------------------------------------*
*&      Form  get_bevalld
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_BEVALLD USING    $BUKRS
*                          $BTYPE.
*  REFRESH I_/ZAK/BEVALLD.
FORM GET_BEVALLD USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                          $BTYPE TYPE /ZAK/BEVALL-BTYPE.

  CLEAR I_/ZAK/BEVALLD[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLD FROM /ZAK/BEVALLD
     WHERE BUKRS = $BUKRS
       AND BTYPE = $BTYPE.
ENDFORM.                    " get_bevalld
