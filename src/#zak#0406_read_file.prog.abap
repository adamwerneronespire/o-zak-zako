*&---------------------------------------------------------------------*
*& Report  /ZAK/0406_READ_FILE
*&
*&---------------------------------------------------------------------*
*& Program: ÁFA 04 és 06-os lapok kezdeti feltöltése
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/0406_READ_FILE MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: A program egy excel fájl alapján az utolsó lezárt
*& időszakhoz betölti az adatokat a /ZAK/ANALITIKA táblába
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor
*& Létrehozás dátuma : 2007.06.01
*& Funkc.spec.készítő:
*& SAP modul neve    : ADO
*& Program  típus    : Report
*& SAP verzió        : 5.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS
*& ----   ----------   ----------     ---------------------- -----------
*&
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE: /ZAK/READ_TOP.
INCLUDE EXCEL__C.
INCLUDE <ICON>.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.
*ALV közös rutinok
INCLUDE /ZAK/ALV_LIST_FORMS.


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_CLASS        TYPE DD02L-TABCLASS VALUE 'INTTAB',
           C_A            TYPE C VALUE 'A',
* analitika adatszerkezet
           C_ANALITIKA    LIKE /ZAK/BEVALLD-STRNAME VALUE '/ZAK/ANALITIKA',
* file típusok
           C_FILE_XLS(2)  TYPE C VALUE   '02',
           C_FILE_TXT(2)  TYPE C VALUE   '01',
           C_FILE_XML(2)  TYPE C VALUE   '03',
           C_FILE_SAP(2)  TYPE C VALUE   '04',
* excel betöltéshez
           C_END_ROW      TYPE I VALUE '65536',
           C_BEGIN_ROW    TYPE I VALUE    '1',
* maximális sorok száma
           C_MAX_XLS_LINE TYPE SY-TABIX VALUE 5000.




*&---------------------------------------------------------------------*
*& BELSŐ TÁBLÁK  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
TABLES: T001.

DATA: I_XLS      TYPE STANDARD TABLE OF ALSMEX_TABLINE
                                                    INITIAL SIZE 0,
      I_DD03P    TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0,
      I_MAIN_STR TYPE STANDARD TABLE OF DD03P       INITIAL SIZE 0.


*Hiba adaszerkezet tábla
DATA: I_HIBA LIKE /ZAK/ADAT_HIBA  OCCURS 0.
DATA: W_HIBA LIKE /ZAK/ADAT_HIBA.

DATA: I_LINE TYPE STANDARD TABLE OF /ZAK/LINE        INITIAL SIZE 0.
DATA: I_OUTTAB LIKE /ZAK/ANALITIKA OCCURS 0.
DATA: W_OUTTAB LIKE /ZAK/ANALITIKA.

*IDŐSZAKok kezelése
*++S4HANA#01.
*DATA: BEGIN OF I_BTYPE OCCURS 0,
*      BTYPE TYPE /ZAK/BTYPE,
*      GJAHR TYPE GJAHR,
*      MONAT TYPE MONAT,
*      ZINDEX TYPE /ZAK/INDEX,
*      END OF I_BTYPE.
*DATA  W_BTYPE LIKE I_BTYPE.
TYPES: BEGIN OF TS_I_BTYPE ,
         BTYPE  TYPE /ZAK/BTYPE,
         GJAHR  TYPE GJAHR,
         MONAT  TYPE MONAT,
         ZINDEX TYPE /ZAK/INDEX,
       END OF TS_I_BTYPE .
TYPES TT_I_BTYPE TYPE STANDARD TABLE OF TS_I_BTYPE .
DATA: GS_I_BTYPE TYPE TS_I_BTYPE.
DATA: GT_I_BTYPE TYPE TT_I_BTYPE.
DATA  W_BTYPE TYPE TS_I_BTYPE.
*--S4HANA#01.

*GUI státuszok tíltásához
TYPES: BEGIN OF STAB_TYPE,
         FCODE LIKE RSMPE-FUNC,
       END OF STAB_TYPE.

DATA: S_TAB  TYPE STANDARD TABLE OF STAB_TYPE WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      W_STAB TYPE STAB_TYPE.


*HIBALISTA ALV változók:
* Fejléc adatok
DATA: GTE_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
* Lista layout beállítások
DATA: GSE_LAYOUT           TYPE SLIS_LAYOUT_ALV.
* Események (pl: TOP-OF-PAGE)
DATA: GTE_EVENTS           TYPE SLIS_T_EVENT.
* Nyomtatás vezérlés
DATA: GSE_PRINT TYPE SLIS_PRINT_ALV.
* Mező katalógus
DATA: GTE_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      GSE_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

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
DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
      V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.

* excel betöltéshez
DATA: V_BEGIN_COL TYPE I,
      V_END_COL   TYPE I.

* struktúra ellenőrzése
DATA: W_DD02L TYPE DD02L.
* excel betöltéshez
DATA: W_XLS      TYPE ALSMEX_TABLINE,
      W_DD03P    TYPE DD03P,
      W_MAIN_STR TYPE DD03P,
      WA_DD03P   TYPE DD03P,
      W_LINE     TYPE /ZAK/LINE.


DATA: V_XLS_LINE TYPE SY-TABIX VALUE 5000.

DATA: V_WNUM(30) TYPE N.

*Makró definiálása státusz töltéséhez
DEFINE M_STATUS.
  MOVE &1 TO W_STAB-FCODE.
  APPEND W_STAB TO S_TAB.
END-OF-DEFINITION.

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
    PARAMETERS: P_BTART  LIKE /ZAK/BEVALL-BTYPART DEFAULT 'AFA'
                              MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-A03.
    PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE
*++BG 2008.03.28
*                         DEFAULT '0765'
*                         MODIF ID DIS
                              OBLIGATORY
*--BG 2008.03.28
                              .
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID OUT.
  SELECTION-SCREEN END OF LINE.


  SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
    PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BEVD
                                                       OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK B02.

  SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-B03.
    PARAMETERS: P_FDIR  LIKE FC03TAB-PL00_FILE          OBLIGATORY,
*++S4HANA#01.
*                P_HEAD  AS CHECKBOX DEFAULT 'X',
*                P_TESZT AS CHECKBOX DEFAULT 'X'.
                P_HEAD  TYPE C AS CHECKBOX DEFAULT 'X',
                P_TESZT TYPE C AS CHECKBOX DEFAULT 'X'.
*--S4HANA#01.
  SELECTION-SCREEN END OF BLOCK B03.

SELECTION-SCREEN END OF BLOCK B01.


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

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIF_SCREEN.

AT SELECTION-SCREEN.
* megnevezések
  PERFORM FIELD_DESCRIPT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FDIR.
  PERFORM FILENAME_GET.



*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.
*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                P_BTART
                                C_ACTVT_01.
* bevallás fajta meghatározása
  PERFORM READ_BEVALL USING P_BUKRS
                            P_BTYPE.

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
  PERFORM GET_ANALITIKA_STUC USING C_ANALITIKA.


* Adatszolgáltatás fájl formátuma alapján meghívom a betöltő funkciókat
  CASE V_TYPE.
    WHEN C_FILE_XLS.
*
      PERFORM PROCESS_IND USING TEXT-P00.

      V_BEGIN_COL = 1.
*      a hibák a I_HIBA táblában!
      CALL FUNCTION '/ZAK/XLS'
        EXPORTING
          FILENAME                = P_FDIR
          I_BEGIN_COL             = V_BEGIN_COL
          I_BEGIN_ROW             = C_BEGIN_ROW
          I_END_COL               = V_END_COL
          I_END_ROW               = C_END_ROW
          I_STRNAME               = V_STRNAME
          I_BUKRS                 = P_BUKRS
*         I_CDV                   = P_CDV
          I_HEAD                  = P_HEAD
        TABLES
          INTERN                  = I_XLS
          CHECK_TAB               = I_DD03P   "adatszerkezet
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
* Tételszám vizsgálat, itt csak a max. konstansban meghatározott
* tételszám tölthető be!
*++S4HANA#01.
*        DESCRIBE TABLE I_LINE LINES V_XLS_LINE.
        V_XLS_LINE = LINES( I_LINE ).
*--S4HANA#01.
        IF V_XLS_LINE > C_MAX_XLS_LINE.
          MESSAGE I207 WITH V_XLS_LINE C_MAX_XLS_LINE.
*A megadott fájl sorok száma (&), nagyobb a max.megengedettnél (&)!
          EXIT.
        ENDIF.
* alv lista belső tábla kitöltés I_OUTTAB
        PERFORM FILL_DATATAB USING I_XLS[]
                                   I_DD03P[]
                                   I_MAIN_STR[]
                                   I_/ZAK/BEVALLC[]
                                   I_LINE[]
                                   V_STRNAME
*++S4HANA#01.
*                                   I_BTYPE[].
                          CHANGING GT_I_BTYPE[].
*--S4HANA#01.
        CHECK NOT I_OUTTAB[] IS INITIAL.
*       Utolsó lezárt időszakok meghatározása
*++S4HANA#01.
*        LOOP AT I_BTYPE INTO W_BTYPE.
        LOOP AT GT_I_BTYPE INTO W_BTYPE.
*--S4HANA#01.
          SELECT MAX( ZINDEX ) INTO W_BTYPE-ZINDEX
                               FROM /ZAK/BEVALLI
                              WHERE BUKRS EQ P_BUKRS
                                AND BTYPE EQ W_BTYPE-BTYPE
                                AND GJAHR EQ W_BTYPE-GJAHR
                                AND MONAT EQ W_BTYPE-MONAT
                                AND FLAG  EQ 'Z'.
          IF NOT W_BTYPE-ZINDEX IS INITIAL.
*++S4HANA#01.
*            MODIFY I_BTYPE FROM W_BTYPE TRANSPORTING ZINDEX.
            MODIFY GT_I_BTYPE FROM W_BTYPE TRANSPORTING ZINDEX.
*--S4HANA#01.
          ELSE.
            CLEAR W_HIBA.
            W_HIBA-/ZAK/ATTRIB   = 'Bevallás időszak'(020).
            CONCATENATE P_BUKRS W_BTYPE-BTYPE W_BTYPE-GJAHR
                        W_BTYPE-MONAT INTO W_HIBA-/ZAK/F_VALUE
                        SEPARATED BY '/'.
            W_HIBA-ZA_HIBA      =
            'Hiba az utolsó lezárt index meghatározásánál!'(024).
            APPEND W_HIBA TO I_HIBA.

*            MESSAGE E222 WITH P_BUKRS W_BTYPE-BTYPE W_BTYPE-GJAHR
*                              W_BTYPE-MONAT.
**           Hiba az utolsó lezárt időszak meghatározásánál! (&/&/&/&)
          ENDIF.
        ENDLOOP.
*       IDŐSZAKok visszaírása
*++S4HANA#01.
*        LOOP AT I_BTYPE INTO W_BTYPE.
        LOOP AT GT_I_BTYPE INTO W_BTYPE.
*--S4HANA#01.
          LOOP AT I_OUTTAB INTO W_OUTTAB WHERE BTYPE EQ W_BTYPE-BTYPE
                                           AND GJAHR EQ W_BTYPE-GJAHR
                                           AND MONAT EQ W_BTYPE-MONAT.
            MOVE W_BTYPE-ZINDEX TO W_OUTTAB-ZINDEX.
            MODIFY I_OUTTAB FROM W_OUTTAB TRANSPORTING ZINDEX.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
  ENDCASE.

*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF NOT I_HIBA[] IS INITIAL.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
      EXPORTING
        TITEL     = 'Figyelem'(019)
        TEXTLINE1 = 'Létezik Hibanapló! Éles futás nem lehetséges!'(018).
  ELSE.
    M_STATUS 'ERROR_LIST'.
*   Éles futás adatbázis módosítás
    IF P_TESZT IS INITIAL.
      INSERT /ZAK/ANALITIKA FROM TABLE I_OUTTAB ACCEPTING DUPLICATE KEYS.
      COMMIT WORK AND WAIT.
      IF SY-SUBRC EQ 0.
        MESSAGE I223.
*       Az adatok mentése sikeresen megtörtént!
      ELSE.
        MESSAGE E209.
*       Hiba az adatbázis módosításkor!
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM ALV_LIST TABLES  I_OUTTAB
                   USING  'I_OUTTAB'.


*&---------------------------------------------------------------------*
*&      Form  modif_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_SCREEN.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'OUT'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " modif_screen

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
*++S4HANA#01.
*    SELECT SINGLE *  FROM T001
    SELECT SINGLE *  FROM T001 INTO T001
*--S4HANA#01.
          WHERE BUKRS = P_BUKRS.
    P_BUTXT = T001-BUTXT.
  ENDIF.

  IF NOT P_BTYPE IS INITIAL.
*++S4HANA#01.
*    SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
*        WHERE LANGU = SY-LANGU
*          AND BUKRS = P_BUKRS
*          AND BTYPE = P_BTYPE.
    SELECT BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT UP TO 1 ROWS
    WHERE LANGU = SY-LANGU
      AND BUKRS = P_BUKRS
      AND BTYPE = P_BTYPE
    ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.
  ENDIF.


ENDFORM.                    " field_descript

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

  DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.

  L_FILTER = '*.XLS'.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*++S4HANA#01.

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

*--S4HANA#01.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

  CHECK SY-SUBRC EQ 0.
ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  read_cust_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_CUST_TABLE USING    $BUKRS  LIKE T001-BUKRS
                              $BTYPE  LIKE /ZAK/BEVALL-BTYPE
                              $BSZNUM LIKE /ZAK/BEVALLD-BSZNUM.

* Adatszerkezet-mezző összerendelés meghatározása
*++S4HANA#01.
*  SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
*                            WHERE BTYPE EQ $BTYPE AND
*                                  BSZNUM EQ $BSZNUM.
  SELECT @SPACE FROM /ZAK/BEVALLC
                            WHERE BTYPE EQ @$BTYPE AND
                                  BSZNUM EQ @$BSZNUM INTO
                                    TABLE @i_/ZAK/BEVALLC.
*--S4HANA#01.
  IF SY-SUBRC NE 0.
    MESSAGE E010 WITH $BUKRS $BTYPE .
  ENDIF.
*

ENDFORM.                    " read_cust_table

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
*++S4HANA#01.
*  SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
*                       WHERE BUKRS EQ $BUKRS AND
*                             BTYPE EQ $BTYPE.
  SELECT * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL UP TO 1 ROWS
                       WHERE BUKRS EQ $BUKRS AND
                             BTYPE EQ $BTYPE
                       ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.
ENDFORM.                    " READ_BEVALL

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

  CLEAR: W_/ZAK/BEVALLD.
* Adatszerkezet meghatározás
  SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
                  WHERE BUKRS  EQ $BUKRS AND
                  BTYPE  EQ $BTYPE AND
                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
    MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
  ELSE.
    IF W_/ZAK/BEVALLD-FILETYPE EQ '04'.
* SAP adatszolgáltatást jelenleg nem engedélyezett !
      MESSAGE E006.
    ENDIF.

*++2007.01.11 BG (FMC)
    IF NOT W_/ZAK/BEVALLD-XSPEC IS INITIAL.
      MESSAGE E205 WITH $BSZNUM.
*   & adatszolgáltatás speciálisra van beállítva! (/ZAK/BEVALLD)
    ENDIF.
*--2007.01.11 BG (FMC)

    $STRNAME = W_/ZAK/BEVALLD-STRNAME.
    $TYPE    = W_/ZAK/BEVALLD-FILETYPE.

* XML formátumnál nem kell struktúra
    IF  W_/ZAK/BEVALLD-FILETYPE NE '03'.
* Adatszerkezet meglétének ellenörzése!
*++S4HANA#01.
*      SELECT SINGLE * INTO W_DD02L FROM DD02L
*                      WHERE TABNAME  EQ W_/ZAK/BEVALLD-STRNAME AND
*                            AS4LOCAL EQ C_A AND
*                            TABCLASS EQ C_CLASS.
      SELECT * INTO W_DD02L FROM DD02L UP TO 1 ROWS
                WHERE TABNAME  EQ W_/ZAK/BEVALLD-STRNAME AND
                      AS4LOCAL EQ C_A AND
                      TABCLASS EQ C_CLASS
                ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.
* aktivált?
      IF SY-SUBRC NE 0.
        MESSAGE E050 WITH W_/ZAK/BEVALLD-STRNAME .
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_bevalld

*&---------------------------------------------------------------------*
*&      Form  check_fieldtyp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_STRNAME  text
*      <--P_V_BEGIN_XLS  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_FIELDTYP USING    $STRNAME
*                    CHANGING $V_END_COL.
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
* COMPTYPE = 'S' includ sor ezért nem vesszük figyelembe
  DELETE I_DD03P WHERE COMPTYPE = 'S'.
  LOOP AT I_DD03P INTO W_DD03P.
    W_DD03P-POSITION = SY-TABIX.
    MODIFY I_DD03P FROM W_DD03P TRANSPORTING POSITION.
  ENDLOOP.
ENDFORM.                    " check_fieldtyp

*&---------------------------------------------------------------------*
*&      Form  GET_ANALITIKA_STUC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_ANALITIKA  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_ANALITIKA_STUC USING  $ANALITIKA.
*
*  REFRESH: I_MAIN_STR.
FORM GET_ANALITIKA_STUC USING  $ANALITIKA TYPE /ZAK/BEVALLD-STRNAME.

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

ENDFORM.                    " GET_ANALITIKA_STUC

*&---------------------------------------------------------------------
*
*&      Form  process_ind
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM PROCESS_IND USING $TEXT.
FORM PROCESS_IND USING $TEXT TYPE CLIKE.
*--S4HANA#01.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE       = 0
      TEXT = $TEXT.

ENDFORM.                    " process_ind


*&---------------------------------------------------------------------*
*&      Form  FILL_DATATAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_XLS  text
*      -->P_I_DD03P  text
*      -->P_V_STRNAME  text
*----------------------------------------------------------------------*
FORM FILL_DATATAB USING    $I_XLS     LIKE I_XLS[]
                           $I_DD03P   LIKE I_DD03P[]
                           $I_MAIN_STR LIKE I_MAIN_STR[] "analitika str
                           $I_BEVALLC LIKE I_/ZAK/BEVALLC[]
                           $I_LINE    LIKE I_LINE[]
*++S4HANA#01.
*                           $V_STRNAME
*                           $I_BTYPE   LIKE I_BTYPE[].
                           $V_STRNAME TYPE /ZAK/BEVALLD-STRNAME
                  CHANGING $I_BTYPE   TYPE TT_I_BTYPE.
*--S4HANA#01.

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
*++2007.01.11 BG (FMC)
  DATA  L_DATE LIKE SY-DATUM.
  DATA  L_BTYPE_VER.
*--2007.01.11 BG (FMC)

  CLEAR V_TAB.
  CONCATENATE 'W_' $V_STRNAME INTO V_TAB.
  ASSIGN (V_TAB) TO <F2>.

*

*++2007.01.11 BG (FMC)
  CLEAR L_BTYPE_VER.
*--2007.01.11 BG (FMC)

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
      AT NEW ROW.
* analitika mezők megfeleltetése az adatszerkezetnek!
* Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát
        PERFORM MOVE_CORR USING  $I_XLS[]
                                 $I_DD03P[]
                                 $I_MAIN_STR[]
                                 W_LINE
                                 W_XLS-ROW
                        CHANGING W_OUTTAB .

        CLEAR COUNT.
* csak az ABEV azonosítóval kapcsolt mezőket dolgozom fel!
        W_OUTTAB-BUKRS   = P_BUKRS.
        W_OUTTAB-BSZNUM  = P_BSZNUM.
        W_OUTTAB-LAPSZ   = C_LAPSZ.
        W_OUTTAB-ABEVAZ  = C_ABEVAZ_DUMMY.
        W_OUTTAB-WAERS   = T001-WAERS.
        W_OUTTAB-FWAERS  = T001-WAERS.
        W_OUTTAB-GJAHR   = L_DATUM(4).
        W_OUTTAB-MONAT   = L_DATUM+4(2).
        W_OUTTAB-ZINDEX  = '000'.
*       Feltöltés azonosító feltöltése
        CONCATENATE SY-DATUM '0406M'(017) INTO W_OUTTAB-PACK
                                     SEPARATED BY '_'.
*       BTYPE ellenőrzése
        L_DATE(4)   = W_OUTTAB-GJAHR.
        L_DATE+4(2) = W_OUTTAB-MONAT.
        L_DATE+6(2) = '01'.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
          EXPORTING
            DAY_IN            = L_DATE
          IMPORTING
            LAST_DAY_OF_MONTH = L_DATE
          EXCEPTIONS
            DAY_IN_NO_DATE    = 1
            OTHERS            = 2.
        IF SY-SUBRC <> 0.
          CLEAR W_HIBA.
          W_HIBA-/ZAK/ATTRIB   = 'Dátum'(023).
          W_HIBA-/ZAK/F_VALUE  =  L_DATE.
          W_HIBA-ZA_HIBA      =
          'Hiba a hónap utolsó nap meghatározásánál!'(024).
          APPEND W_HIBA TO I_HIBA.
        ELSE.
*++S4HANA#01.
*          SELECT SINGLE BTYPE INTO W_OUTTAB-BTYPE
*                   FROM /ZAK/BEVALL
*                  WHERE BUKRS EQ P_BUKRS
*                    AND ( DATBI GE L_DATE
*                    AND   DATAB LE L_DATE )
*                    AND BTYPART EQ P_BTART.
          SELECT BTYPE INTO W_OUTTAB-BTYPE
            FROM /ZAK/BEVALL UP TO 1 ROWS
             WHERE BUKRS EQ P_BUKRS
              AND ( DATBI GE L_DATE
              AND   DATAB LE L_DATE )
              AND BTYPART EQ P_BTART
            ORDER BY PRIMARY KEY.
          ENDSELECT.
*--S4HANA#01.
          IF SY-SUBRC NE 0.
            CLEAR W_HIBA.
            W_HIBA-/ZAK/ATTRIB   = 'Bevallás típus'(025).
            W_HIBA-/ZAK/F_VALUE  =  P_BTART.
            CONCATENATE TEXT-026 L_DATE INTO W_HIBA-ZA_HIBA
                                        SEPARATED BY SPACE.
            APPEND W_HIBA TO I_HIBA.
          ENDIF.
        ENDIF.

        APPEND W_OUTTAB TO I_OUTTAB.
*       IDŐSZAKok kezelése
        CLEAR W_BTYPE.
        MOVE W_OUTTAB-BTYPE TO W_BTYPE-BTYPE.
        MOVE W_OUTTAB-GJAHR TO W_BTYPE-GJAHR.
        MOVE W_OUTTAB-MONAT TO W_BTYPE-MONAT.
        COLLECT W_BTYPE INTO $I_BTYPE.
        CLEAR  W_OUTTAB.
      ENDAT.
    ENDIF.
  ENDLOOP.
* item beállítása
  SORT I_OUTTAB BY BUKRS BTYPE GJAHR MONAT
                   ZINDEX ABEVAZ ADOAZON.

  IF NOT I_OUTTAB[] IS INITIAL.
    CLEAR L_ITEM.
    LOOP AT I_OUTTAB INTO W_OUTTAB.
      ADD 1 TO L_ITEM.
      W_OUTTAB-ITEM = L_ITEM.
      MODIFY I_OUTTAB FROM W_OUTTAB TRANSPORTING ITEM.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " FILL_DATATAB


*&---------------------------------------------------------------------*
*&      Form  MOVE_CORR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_XLS[]  text
*      -->P_$I_DD03P[]  text
*      -->P_$I_MAIN_STR[]  text
*      -->P_$I_LINE[]  text
*      <--P_W_OUTTAB  text
*----------------------------------------------------------------------*
FORM MOVE_CORR USING    $XLS       LIKE I_XLS[]
                        $DD03P     LIKE I_DD03P[]
                        $MAIN_STR  LIKE I_MAIN_STR[]
                        $LINE      LIKE /ZAK/LINE
*++S4HANA#01.
*                        $ROW
                        $ROW TYPE ALSMEX_TABLINE-ROW
*--S4HANA#01.
               CHANGING $W_OUTTAB  TYPE /ZAK/ANALITIKA.

  DATA: WA_XLS TYPE ALSMEX_TABLINE.
  DATA  L_ELOJEL.

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
*       Értékmezők kezelése 'HUF' miatt
        IF WA_DD03P-INTTYPE EQ 'P'.
          CLEAR L_ELOJEL.
          IF <F1> < 0.
            <F1> = ABS( <F1> ).
            MOVE '-' TO L_ELOJEL.
          ENDIF.

          CALL FUNCTION 'Z_2_CONVERT_STRING_TO_PACKED'
            EXPORTING
              I_AMOUNT        = <F1>
              I_CURRENCY_CODE = T001-WAERS
            IMPORTING
              E_AMOUNT        = <F1>
*           EXCEPTIONS
*             NOT_NUMERIC     = 1
*             OTHERS          = 2
            .
          IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
          IF L_ELOJEL EQ '-'.
            MULTIPLY <F1> BY -1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " MOVE_CORR

*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM ALV_LIST  TABLES   $TAB
*                USING   $TAB_NAME.
FORM ALV_LIST  TABLES   $TAB STRUCTURE /ZAK/ANALITIKA
                USING   $TAB_NAME TYPE CLIKE.
*--S4HANA#01.

*ALV lista init
  PERFORM COMMON_ALV_LIST_INIT USING SY-TITLE
                                     $TAB_NAME
                                     '/ZAK/0406_READ_FILE'.

*ALV lista
  PERFORM COMMON_ALV_GRID_DISPLAY TABLES $TAB
                                  USING  $TAB_NAME
                                         'STATUS_SET'
                                         'USER_COMMAND'.

ENDFORM.                    " LIST_SPOOL

*&---------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM END_OF_LIST.

ENDFORM.                    " END_OF_LIST

*---------------------------------------------------------------------*
*       FORM STATUS_SET                                               *
*---------------------------------------------------------------------*
*       ALV lista státus beállítása - dinamikus hívás !               *
*---------------------------------------------------------------------*
*  -->  EXTAB                                                         *
*---------------------------------------------------------------------*
FORM STATUS_SET USING EXTAB TYPE SLIS_T_EXTAB.

  SET PF-STATUS 'STANDARD' EXCLUDING S_TAB.

ENDFORM.   "FORM STATUS_SET

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ALV lista hívja - Dinamikus hívással !!
*---------------------------------------------------------------------*
*  -->  RF_UCOMM                                                      *
*  -->  SELFIELD                                                      *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING $UCOMM    LIKE SY-UCOMM
                        $SELFIELD TYPE SLIS_SELFIELD.
  CASE $UCOMM.
    WHEN 'ERROR_LIST'.
* ALV lista meghívása adatok megjelenítése
      PERFORM ALV_ERROR_LIST_DATA TABLES  I_HIBA
                                  USING  'I_HIBA'
                                         'HIBALISTA'.

  ENDCASE.

ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  alv_list_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ATKONYV  text
*      -->P_0157   text
*      -->P_0158   text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM ALV_ERROR_LIST_DATA TABLES   $TAB
*                         USING    $TAB_NAME
*                                  $TEXT.
FORM ALV_ERROR_LIST_DATA TABLES   $TAB STRUCTURE /ZAK/ADAT_HIBA
                         USING    $TAB_NAME TYPE CLIKE
                                  $TEXT TYPE CLIKE.
*--S4HANA#01.


* Lista értékek inicializálása, feltöltése
  L_REPID = SY-REPID.
  CLEAR: GTE_LIST_TOP_OF_PAGE[],
         GSE_LAYOUT,
         GTE_EVENTS[],
         GSE_PRINT,
         GTE_FIELDCAT[].

** Lista fejléc
*  PERFORM COMMON_LIST_TOP_BUILD   USING GTE_LIST_TOP_OF_PAGE[]
*                                        $TEXT.
* Layout
  PERFORM COMMON_GS_LAYOUT_BUILD  USING GSE_LAYOUT.
* Események definiálása (top-of-page)
* PERFORM COMMON_EVENTTAB_BUILD USING GTE_EVENTS[].
* Nyomtatás beállítások
  PERFORM COMMON_GS_PRINT_BUILD USING GSE_PRINT.
* Mező katalógus
  PERFORM COMMON_GS_FIELD_CATALOG USING GTE_FIELDCAT[]
                                        $TAB_NAME
                                        '/ZAK/0406_READ_FILE'.


**Fieldkatalógus átalakítása
*  PERFORM COMMON_OWN_ERROR_FIELDCAT USING GTE_FIELDCAT[].

**Színmeghatározása miatt
*  GSE_LAYOUT-INFO_FIELDNAME = 'COLOR'.

* ABAP/4 List Viewer hívása
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = L_REPID
      I_STRUCTURE_NAME         = $TAB_NAME
      IS_LAYOUT                = GSE_LAYOUT
      IT_FIELDCAT              = GTE_FIELDCAT[]
      I_CALLBACK_PF_STATUS_SET = 'STATUS_SET_ERROR'
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_ERROR'
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        = GT_SP_GROUP[]
*     IT_SORT                  = GT_SORT[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     i_default                = g_default
*     I_SAVE                   = 'X' "variánsok mentése
*                                           "lehetséges
*     IS_VARIANT               = G_VARIANT
      IT_EVENTS                = GTE_EVENTS[]
*     IT_EVENT_EXIT            =
      IS_PRINT                 = GSE_PRINT
      I_SCREEN_START_COLUMN    = 2
      I_SCREEN_START_LINE      = 2
      I_SCREEN_END_COLUMN      = 120
      I_SCREEN_END_LINE        = 25
*      IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
    TABLES
      T_OUTTAB                 = $TAB.


ENDFORM.                    " alv_list_data

*---------------------------------------------------------------------*
*       FORM STATUS_SET                                               *
*---------------------------------------------------------------------*
*       ALV lista státus beállítása - dinamikus hívás !               *
*---------------------------------------------------------------------*
*  -->  EXTAB                                                         *
*---------------------------------------------------------------------*
FORM STATUS_SET_ERROR USING EXTAB TYPE SLIS_T_EXTAB.

  SET PF-STATUS 'ERROR'.

ENDFORM.   "FORM STATUS_SET

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ALV lista hívja - Dinamikus hívással !!
*---------------------------------------------------------------------*
*  -->  RF_UCOMM                                                      *
*  -->  SELFIELD                                                      *
*---------------------------------------------------------------------*
FORM USER_COMMAND_ERROR USING $UCOMM    LIKE SY-UCOMM
                              $SELFIELD TYPE SLIS_SELFIELD.


ENDFORM.                    "USER_COMMAND_ERRO
