*&---------------------------------------------------------------------*
*& Program: Migrációs program ÁFA bevállás
*&---------------------------------------------------------------------*
REPORT /ZAK/MT_MIGR_AFA .

*&---------------------------------------------------------------------*
*& Funkció leírás: Migrációs program önrevízióhoz - státuszok kezelése
*&---------------------------------------------------------------------*
*& Szerző            : Kukely Anna
*& Létrehozás dátuma : 2006.10.30
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
*& 0001   2006.10.30   Kukely Anna      létrehozás
*&
*&---------------------------------------------------------------------*

INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/READ_TOP.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
*TABLES: ZAD_HRHAVI_TH.
*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
* file típusok
CONSTANTS:  C_FILE_XLS(2) TYPE C VALUE   '02',
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
DATA: BEGIN OF T_/ZAK/ZAKAFA3  OCCURS 0.               "
        INCLUDE STRUCTURE /ZAK/AFA_003_KI.
DATA: ZINDEX LIKE /ZAK/BEVALLO-ZINDEX.
DATA: END OF T_/ZAK/ZAKAFA3.

DATA: BEGIN OF T_HIBA  OCCURS 0,
        EV          LIKE /ZAK/BEVALLO-GJAHR,
        HO          LIKE /ZAK/BEVALLO-MONAT,
        ZINDEX      LIKE /ZAK/BEVALLO-ZINDEX,
        ABEVAZ      LIKE /ZAK/BEVALLO-ABEVAZ,
        FIELD_N(20),
      END OF T_HIBA.

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
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLSZ-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-102 FOR FIELD P_BTYPE.
PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLSZ-BTYPE OBLIGATORY DEFAULT '0665'.

SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-T02.
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
                          MATCHCODE OBJECT /ZAK/BEVD DEFAULT '003'.
SELECTION-SCREEN  SKIP 1.
SELECT-OPTIONS: S_EV  FOR /ZAK/BEVALLO-GJAHR.
SELECT-OPTIONS: S_HO  FOR /ZAK/BEVALLO-MONAT.

SELECTION-SCREEN END OF BLOCK B02.


SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-T03.
PARAMETERS: P_FDIR LIKE FC03TAB-PL00_FILE,
            P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK B03.

SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
  P_BTYPE = '0665'.
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
  PERFORM READ_BEVALLO USING P_BUKRS
                             P_BTYPE
                             S_EV
                             S_HO.

*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                W_/ZAK/BEVALL-BTYPART
                                C_ACTVT_01.

* vezérlő táblák olvasása
  PERFORM READ_CUST_TABLE USING P_BUKRS
                                P_BTYPE
                                P_BSZNUM.

  CLEAR: V_TYPE,V_STRNAME.

END-OF-SELECTION.
  PERFORM  FILL_DATATAB .
  IF P_TEST = C_X.
    PERFORM MAKE_ALV.
  ELSE.
    PERFORM MAKE_FILE.
    IF NOT T_HIBA[]  IS INITIAL.
      PERFORM MAKE_ERR_LIST.
    ENDIF.
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
      SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
          WHERE LANGU = SY-LANGU
            AND BUKRS = P_BUKRS
            AND BTYPE = P_BTYPE.
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

  DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*  CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING  DEF_FILENAME     =  L_FILTER
**               def_path         =
*                MASK             =  L_MASK
*                MODE             = 'O'
*                TITLE            =  SY-TITLE
*     IMPORTING  FILENAME         =  P_FDIR
**               RC               =  DUMMY
*     EXCEPTIONS INV_WINSYS       =  04
*                NO_BATCH         =  08
*                SELECTION_CANCEL =  12
*                SELECTION_ERROR  =  16.
  DATA L_EXTENSION TYPE STRING.
  DATA L_TITLE     TYPE STRING.
  DATA L_FILE      TYPE STRING.
  DATA L_FULLPATH  TYPE STRING.

  L_TITLE = SY-TITLE.
  L_EXTENSION = L_MASK.

  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      WINDOW_TITLE      = L_TITLE
*     DEFAULT_EXTENSION = L_EXTENSION
*     DEFAULT_FILE_NAME =
*     WITH_ENCODING     =
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    IMPORTING
*     FILENAME          = L_FILE
*     PATH              =
      FULLPATH          = L_FULLPATH
*     USER_ACTION       =
*     FILE_ENCODING     =
    .
  P_FDIR = L_FULLPATH.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

  CHECK SY-SUBRC EQ 0.
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

    SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
                        WHERE BUKRS EQ P_BUKRS AND
                              BTYPE EQ P_BTYPE .
    IF SY-SUBRC NE 0.
      MESSAGE E010(/ZAK/ZAK) WITH P_BUKRS P_BTYPE .
    ENDIF.

  ENDIF.
* Adatszolgáltatás
  IF P_BSZNUM IS INITIAL.
    MESSAGE E161(/ZAK/ZAK) WITH P_BUKRS P_BTYPE .
  ENDIF.
ENDFORM.                    " CHECK_PARAMS
*----------------------------------------------------------------------*
FORM READ_BEVALLO USING    $BUKRS
                           $BTYPE
                           $EV
                           $HO.

* egy bevallás típus csak egy bevallás fajtához tartozhat, így
* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni!
  SELECT  * INTO W_/ZAK/BEVALLO FROM /ZAK/BEVALLO
                       WHERE BUKRS EQ $BUKRS AND
                            BTYPE EQ $BTYPE
                            AND GJAHR IN S_EV
                            AND MONAT IN S_HO
                            ORDER BY ZINDEX  DESCENDING   .
    APPEND W_/ZAK/BEVALLO TO  I_/ZAK/BEVALLO.
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
  SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
                            WHERE BTYPE EQ $BTYPE AND
                                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
*     MESSAGE E010 WITH $BUKRS $BTYPE .
  ENDIF.
ENDFORM.                    " READ_CUST_TABLE
*----------------------------------------------------------------------*
FORM FILL_DATATAB .
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
        L_INDX(3)  TYPE N,
        L_INDXG(3) TYPE N,
        L_EV(4),
        L_HO(2),
        L_FLAG.
  CLEAR L_FLAG.
  DATA COUNT TYPE I.
  SORT I_/ZAK/BEVALLO  BY  GJAHR  MONAT  ZINDEX DESCENDING .
  LOOP AT I_/ZAK/BEVALLO  INTO W_/ZAK/BEVALLO.
    IF L_FLAG  IS INITIAL.
      L_INDX = W_/ZAK/BEVALLO-ZINDEX.
      L_FLAG = 'X'.
    ENDIF.
    IF  L_INDX  = W_/ZAK/BEVALLO-ZINDEX.
      READ TABLE I_/ZAK/BEVALLC  INTO W_/ZAK/BEVALLC
                         WITH KEY BTYPE = P_BTYPE
                                  BSZNUM = P_BSZNUM
                                  ABEVAZ =  W_/ZAK/BEVALLO-ABEVAZ.
      IF SY-SUBRC <> 0 .
        IF NOT  W_/ZAK/BEVALLO-FIELD_N IS INITIAL.
          T_HIBA-EV = W_/ZAK/BEVALLO-GJAHR.
          T_HIBA-HO = W_/ZAK/BEVALLO-MONAT.
          T_HIBA-ZINDEX  = W_/ZAK/BEVALLO-ZINDEX.
          T_HIBA-ABEVAZ  = W_/ZAK/BEVALLO-ABEVAZ.
          IF NOT  W_/ZAK/BEVALLO-FIELD_N < 0.
            WRITE W_/ZAK/BEVALLO-FIELD_N TO T_HIBA-FIELD_N
            CURRENCY 'HUF' NO-GROUPING.
          ELSE.
            W_/ZAK/BEVALLO-FIELD_N = W_/ZAK/BEVALLO-FIELD_N * -1.
            WRITE W_/ZAK/BEVALLO-FIELD_N TO T_HIBA-FIELD_N
            CURRENCY 'HUF' NO-GROUPING.
            CONCATENATE '-' T_HIBA-FIELD_N INTO T_HIBA-FIELD_N.
          ENDIF.

          APPEND T_HIBA.
        ENDIF.
      ELSE.
        CLEAR V_TAB.
        CONCATENATE 'T_/ZAK/ZAKAFA3-' W_/ZAK/BEVALLC-SZFIELD  INTO V_TAB.
        ASSIGN (V_TAB) TO <F2>.
        IF NOT  W_/ZAK/BEVALLO-FIELD_N < 0.
          WRITE W_/ZAK/BEVALLO-FIELD_N   TO  <F2>
                    CURRENCY 'HUF' NO-GROUPING.
        ELSE.
          WRITE W_/ZAK/BEVALLO-FIELD_N   TO  <F2>
                    CURRENCY 'HUF' NO-GROUPING.
          <F2> = <F2> * -1.
          SHIFT <F2> LEFT  DELETING LEADING SPACE.
*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
*          SHIFT <F2> LEFT  DELETING LEADING 0.
          SHIFT <F2> LEFT  DELETING LEADING '0'.
*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
          CONCATENATE '-' <F2> INTO <F2>.
        ENDIF.
        T_/ZAK/ZAKAFA3-ZINDEX = W_/ZAK/BEVALLO-ZINDEX.
        CONCATENATE  W_/ZAK/BEVALLO-GJAHR
           W_/ZAK/BEVALLO-MONAT INTO  T_/ZAK/ZAKAFA3-DATUM .
        IF W_/ZAK/BEVALLO-ZINDEX = '000'.
        ELSE.
          T_/ZAK/ZAKAFA3-MTYPE  = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
    AT END OF MONAT .
      APPEND T_/ZAK/ZAKAFA3.
      CLEAR T_/ZAK/ZAKAFA3.
      L_FLAG = ' '.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " FILL_DATATAB
*---------------------------------------------------------------------*
*       FORM MAKE_ALV_CO                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MAKE_ALV.
  DATA: L_TABIX LIKE SY-TABIX,
        N       TYPE I.
  DATA: GS_LAYOUT           TYPE SLIS_LAYOUT_ALV.
* ALV
  DATA: L_REPID LIKE SY-REPID
      , T_FCAT TYPE SLIS_T_FIELDCAT_ALV
      , L_LAYOUT TYPE SLIS_LAYOUT_ALV
      , L_SORT TYPE SLIS_SORTINFO_ALV
      , L_EVENTS TYPE SLIS_ALV_EVENT
      , L_FCAT TYPE SLIS_FIELDCAT_ALV  " fejsor T_FCAT-hoz
      .
  FIELD-SYMBOLS: <FCAT> TYPE SLIS_FIELDCAT_ALV.
  L_REPID = SY-REPID.
* Mező katalógus
  DATA: L_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
  FIELD-SYMBOLS: <FC> TYPE SLIS_FIELDCAT_ALV.
  DATA: GT_FIELDCAT5     TYPE SLIS_T_FIELDCAT_ALV.
  IF NOT  T_HIBA[] IS INITIAL.
    MESSAGE I199(/ZAK/ZAK).
  ENDIF.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = L_REPID
      I_INTERNAL_TABNAME     = 'T_/ZAK/ZAKAFA3'
*     I_STRUCTURE_NAME       = '/ZAK/AFA_003'
      I_INCLNAME             = L_REPID
    CHANGING
      CT_FIELDCAT            = GT_FIELDCAT5
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  GS_LAYOUT-ZEBRA               = 'X'."Csíkozott sorok
  GS_LAYOUT-COLWIDTH_OPTIMIZE   = 'X'."Oszlopok optimalizálása
  GS_LAYOUT-GET_SELINFOS = ''. " olvassa be a szelekciókat
  LOOP AT GT_FIELDCAT5 ASSIGNING <FC>.
    <FC>-SELTEXT_S = <FC>-FIELDNAME.
    <FC>-SELTEXT_M = <FC>-FIELDNAME.
    <FC>-SELTEXT_L = <FC>-FIELDNAME.
    MODIFY TABLE GT_FIELDCAT5 FROM <FC>.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = 'X'
      I_CALLBACK_PROGRAM       = L_REPID
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND4'
      I_CALLBACK_PF_STATUS_SET = 'STATUS_SET'
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT5
      I_SAVE                   = 'A'
*     IT_SORT                  = GT_SORT_2
*     IT_EVENTS                = GT_EVENTS_2
    TABLES
      T_OUTTAB                 = T_/ZAK/ZAKAFA3
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " make_alv
*---------------------------------------------------------------------*
*       FORM STATUS_SET                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  EXTAB                                                         *
*---------------------------------------------------------------------*
FORM STATUS_SET USING EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " STATUS_SET
*---------------------------------------------------------------------*
*       FORM USER_COMMAND4                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RF_UCOMM                                                      *
*  -->  SELFIELD                                                      *
*---------------------------------------------------------------------*
FORM USER_COMMAND4 USING RF_UCOMM LIKE SY-UCOMM
                        SELFIELD TYPE SLIS_SELFIELD.
  DATA: ANSWER.
  DATA: L_SZAM LIKE SY-TABIX,   "Könyvelendő rec szamolása
        L_PC   LIKE SY-TABIX.      " Profit Cent. számolása
  DATA: RET_CODE LIKE SY-SUBRC.
  IF RF_UCOMM EQ 'CHECK_ELL'.
    PERFORM MAKE_ERR_LIST.
  ENDIF.
ENDFORM.                " AT_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  MAKE_ERR_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_ERR_LIST.
  DATA: L_TABIX LIKE SY-TABIX,
        N       TYPE I.
  DATA: GS_LAYOUT           TYPE SLIS_LAYOUT_ALV.
* ALV
  DATA: L_REPID LIKE SY-REPID
      , T_FCAT TYPE SLIS_T_FIELDCAT_ALV
      , L_LAYOUT TYPE SLIS_LAYOUT_ALV
      , L_SORT TYPE SLIS_SORTINFO_ALV
      , L_EVENTS TYPE SLIS_ALV_EVENT
      , L_FCAT TYPE SLIS_FIELDCAT_ALV  " fejsor T_FCAT-hoz
      .
  FIELD-SYMBOLS: <FCAT> TYPE SLIS_FIELDCAT_ALV.
  L_REPID = SY-REPID.
* Mező katalógus
  DATA: L_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
  FIELD-SYMBOLS: <FC> TYPE SLIS_FIELDCAT_ALV.
  DATA: GT_FIELDCAT9     TYPE SLIS_T_FIELDCAT_ALV.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = L_REPID
      I_INTERNAL_TABNAME     = 'T_HIBA'
*     I_STRUCTURE_NAME       =
*     I_CLIENT_NEVER_DISPLAY = 'X'
      I_INCLNAME             = L_REPID
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      CT_FIELDCAT            = GT_FIELDCAT9
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  GS_LAYOUT-ZEBRA               = 'X'."Csíkozott sorok
  GS_LAYOUT-COLWIDTH_OPTIMIZE   = 'X'."Oszlopok optimalizálása
  GS_LAYOUT-GET_SELINFOS = ''. " olvassa be a szelekciókat

  READ TABLE GT_FIELDCAT9 WITH KEY FIELDNAME = 'FIELD_N'
                                 ASSIGNING <FC>.
  IF SY-SUBRC = 0.
    <FC>-SELTEXT_S = 'Összeg' .
    <FC>-SELTEXT_M = 'Összeg' .
    <FC>-SELTEXT_L = 'Összeg' .
    MODIFY TABLE GT_FIELDCAT9 FROM <FC>.
  ENDIF.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK        = 'X'
      I_CALLBACK_PROGRAM       = L_REPID
*     I_CALLBACK_USER_COMMAND  = 'USER_COMMAND7'
      I_CALLBACK_PF_STATUS_SET = 'STATUS_SET7'
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT9
      I_SAVE                   = 'A'
*     IT_SORT                  = GT_SORT_2
*     IT_EVENTS                = GT_EVENTS_2
    TABLES
      T_OUTTAB                 = T_HIBA
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " MAKE_ERR_LIST
*---------------------------------------------------------------------*
*       FORM STATUS_SET7                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  EXTAB                                                         *
*---------------------------------------------------------------------*
FORM STATUS_SET7 USING EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_7'.
ENDFORM.                    " STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  make_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_FILE.
  DATA: FILE_M LIKE  RLGRAP-FILENAME.
  DATA:  L_TEXT1   LIKE RLGRAP-FILENAME,
         L_TEXT2   LIKE RLGRAP-FILENAME,
         L_HUF(20), L_SZAM(6).
  CONCATENATE P_FDIR'\' P_BUKRS '_'   S_EV-LOW '_' S_HO-LOW '.xls'
  INTO FILE_M.
*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
*  CALL FUNCTION 'WS_DOWNLOAD'
*       EXPORTING
*            FILENAME                = FILE_M
**            FILETYPE                = 'ASC'
*             FILETYPE                = 'DAT'
*       TABLES
*            DATA_TAB                = T_/ZAK/ZAKAFA3
*       EXCEPTIONS
*            FILE_OPEN_ERROR         = 1
*            FILE_WRITE_ERROR        = 2
*            INVALID_FILESIZE        = 3
*            INVALID_TYPE            = 4
*            NO_BATCH                = 5
*            UNKNOWN_ERROR           = 6
*            INVALID_TABLE_WIDTH     = 7
*            GUI_REFUSE_FILETRANSFER = 8
*            CUSTOMER_ERROR          = 9
*            OTHERS                  = 10.
  DATA L_FILENAME_STRING TYPE STRING.

  MOVE FILE_M TO L_FILENAME_STRING.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME                = L_FILENAME_STRING
      FILETYPE                = 'DAT'
*     FIELDNAMES              = I_FIELDS[]
    CHANGING
      DATA_TAB                = T_/ZAK/ZAKAFA3[]
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      NOT_SUPPORTED_BY_GUI    = 22
      ERROR_NO_GUI            = 23
      OTHERS                  = 24.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
  IF SY-SUBRC <> 0.
    MESSAGE I175(/ZAK/ZAK) WITH FILE_M.
  ELSE.
    MESSAGE I009(/ZAK/ZAK) WITH FILE_M.
  ENDIF.


ENDFORM.                    " make_file
