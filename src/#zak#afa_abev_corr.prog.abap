*&---------------------------------------------------------------------*
*& Report  /ZAK/ZAK_ANALATIKA_CORR
*&
*&---------------------------------------------------------------------*
*& A program a közösségi adószám mezőt tölti ki a szállító alapján
*& A program többször is futtatható mivel a már kitöltött adatokat
*& nem írja felül.
*&---------------------------------------------------------------------*
REPORT  /ZAK/AFA_ABEV_CORR MESSAGE-ID /ZAK/ZAK.



*Szelekció:
* PAREMEZTER: BUKRS, BTYPE, GJAHR, MONAT,
* SELECT_OPTIONS:   ZINDEX,
*                   MWSKZ, KTOSL
*
*  rossz            ABEVAZ
*  jó               ABEVAZ


* Leválogatni az /ZAK/ANALITIKA
* Képezni egy sort ellenkező előjellel a rossz ABEV-en
* Képezni egy sort azonos előjellel a jó ABEV-en
* /ZAK/UPDATE-el felvinni.



*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.


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
*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.


DATA I_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA OCCURS 0 WITH HEADER LINE.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
PARAMETERS P_BTYPE LIKE /ZAK/ANALITIKA-BTYPE OBLIGATORY.
PARAMETERS P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                                      DEFAULT 'AFA'
                                              OBLIGATORY.
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BSZNUM_SH
                          OBLIGATORY.

PARAMETERS P_GJAHR LIKE /ZAK/ANALITIKA-GJAHR OBLIGATORY.
PARAMETERS P_MONAT LIKE /ZAK/ANALITIKA-MONAT OBLIGATORY.
SELECT-OPTIONS S_INDEX FOR /ZAK/ANALITIKA-ZINDEX.
SELECT-OPTIONS S_MWSKZ FOR /ZAK/ANALITIKA-MWSKZ.
SELECT-OPTIONS S_KTOSL FOR /ZAK/ANALITIKA-KTOSL.
SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-B02.
PARAMETERS P_ABEVR LIKE /ZAK/ANALITIKA-ABEVAZ OBLIGATORY.
PARAMETERS P_ABEVJ LIKE /ZAK/ANALITIKA-ABEVAZ OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL02.

SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-B03.
PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL03.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
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

*  Képernyő attribútomok beállítása
  PERFORM SET_SCREEN_ATTRIBUTES.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Adatok feldolgozása
  PERFORM PROCESS_DATA.

  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.

*  Teszt vagy éles futás, adatbázis módosítás, stb.
  PERFORM INS_DATA USING P_TEST.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM GRID_DISPLAY.

*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA.

  DATA LW_/ZAK/ANALITIKA_1 LIKE /ZAK/ANALITIKA.
  DATA LW_/ZAK/ANALITIKA_2 LIKE /ZAK/ANALITIKA.
  DATA LI_/ZAK/ANALITIKA_2 LIKE /ZAK/ANALITIKA OCCURS 0 WITH HEADER LINE.

  DEFINE LM_MULTIPLY.
    MULTIPLY LW_/ZAK/ANALITIKA_1-&1 BY -1.
  END-OF-DEFINITION.

* Adatok leválogatása
  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX IN S_INDEX
            AND ABEVAZ EQ P_ABEVR
            AND BSZNUM EQ P_BSZNUM
            AND MWSKZ IN S_MWSKZ
            AND KTOSL IN S_KTOSL.

  LOOP AT I_/ZAK/ANALITIKA INTO LW_/ZAK/ANALITIKA_1.
    LW_/ZAK/ANALITIKA_2 = LW_/ZAK/ANALITIKA_1.
    LW_/ZAK/ANALITIKA_2-ABEVAZ = P_ABEVJ.
    LM_MULTIPLY: LWBAS, FWBAS, LWSTE, FWSTE,
                 HWBTR, FWBTR, FIELD_N.
    MODIFY I_/ZAK/ANALITIKA FROM LW_/ZAK/ANALITIKA_1.
    APPEND LW_/ZAK/ANALITIKA_2 TO LI_/ZAK/ANALITIKA_2.
  ENDLOOP.

  APPEND LINES OF  LI_/ZAK/ANALITIKA_2 TO I_/ZAK/ANALITIKA.


ENDFORM.                    " PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  ins_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INS_DATA USING $TESZT.

  DATA LI_RETURN TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0.
  DATA LW_RETURN TYPE BAPIRET2.

  DATA L_TEXTLINE1(80).
  DATA L_TEXTLINE2(80).
  DATA L_DIAGNOSETEXT1(80).
  DATA L_DIAGNOSETEXT2(80).
  DATA L_DIAGNOSETEXT3(80).
  DATA L_TITLE(40).
  DATA L_TABIX LIKE SY-TABIX.

  DATA L_ANSWER.

  DATA L_PACK LIKE /ZAK/ANALITIKA-PACK.

*++0002 BG 2007.06.19
  DATA L_BUPER TYPE BUPER.
*--0002 BG 2007.06.19


  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.

*  Először mindig tesztben futtatjuk
  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = P_BUKRS
*     I_BTYPE     = P_BTYPE
      I_BTYPART   = P_BTYPAR
      I_BSZNUM    = P_BSZNUM
*     I_PACK      =
      I_GEN       = 'X'
      I_TEST      = 'X'
*     I_FILE      =
    TABLES
      I_ANALITIKA = I_/ZAK/ANALITIKA
      E_RETURN    = LI_RETURN.

*   Üzenetek kezelése
  IF NOT LI_RETURN[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = LI_RETURN.
  ENDIF.

*  Ha nem teszt futás, akkor ellenőrizzük van ERROR
  IF NOT $TESZT IS INITIAL.
    LOOP AT LI_RETURN INTO LW_RETURN WHERE TYPE CA 'EA'.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      MESSAGE E062.
*     Adatfeltöltés nem lehetséges!
    ENDIF.
  ENDIF.

*  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról,
  IF $TESZT IS INITIAL.
*    Ha nem háttérben fut
    IF NOT LI_RETURN[] IS INITIAL AND SY-BATCH IS INITIAL.
*    Szövegek betöltése
      MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
      MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                           TO L_DIAGNOSETEXT1.
      MOVE 'Folytatja  feldolgozást?'(003)
                                           TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*        EXPORTING
*          DEFAULTOPTION        = 'N'
*          DIAGNOSETEXT1        = L_DIAGNOSETEXT1
**          DIAGNOSETEXT2        = ' '
**          DIAGNOSETEXT3        = ' '
*          TEXTLINE1            = L_TEXTLINE1
**          TEXTLINE2            = ' '
*          TITEL                = L_TITLE
*          START_COLUMN         = 25
*          START_ROW            = 6
**        CANCEL_DISPLAY       = 'X'
*          IMPORTING
*          ANSWER               = L_ANSWER
*                .
      DATA L_QUESTION TYPE STRING.

      CONCATENATE L_DIAGNOSETEXT1
                  L_TEXTLINE1
                  INTO L_QUESTION SEPARATED BY SPACE.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR       = L_TITLE
*         DIAGNOSE_OBJECT             = ' '
          TEXT_QUESTION  = L_QUESTION
*         TEXT_BUTTON_1  = 'Ja'(001)
*         ICON_BUTTON_1  = ' '
*         TEXT_BUTTON_2  = 'Nein'(002)
*         ICON_BUTTON_2  = ' '
          DEFAULT_BUTTON = '2'
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
          START_COLUMN   = 25
          START_ROW      = 6
*         POPUP_TYPE     =
        IMPORTING
          ANSWER         = L_ANSWER.
      IF L_ANSWER EQ '1'.
        MOVE 'J' TO L_ANSWER.
      ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*    Egyébként mehet
    ELSE.
      MOVE 'J' TO L_ANSWER.
    ENDIF.

*    Mehet az adatbázis módosítása
    IF L_ANSWER EQ 'J'.
*      Adatok módosítása
      CALL FUNCTION '/ZAK/UPDATE'
        EXPORTING
          I_BUKRS     = P_BUKRS
*         I_BTYPE     = P_BTYPE
          I_BTYPART   = P_BTYPAR
          I_BSZNUM    = P_BSZNUM
*         I_PACK      =
          I_GEN       = 'X'
          I_TEST      = $TESZT
*         I_FILE      =
        TABLES
          I_ANALITIKA = I_/ZAK/ANALITIKA
          E_RETURN    = LI_RETURN.
    ENDIF.
  ENDIF.
ENDFORM.                    " ins_data
*&---------------------------------------------------------------------*
*&      Form  GRID_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GRID_DISPLAY .
  DATA LI_FIELDCAT   TYPE LVC_T_FCAT.
  DATA L_LAYOUT      TYPE LVC_S_LAYO.
  DATA L_VARIANT     TYPE DISVARIANT.


* Mezőkatalógus összeállítása
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LI_FIELDCAT.

  L_LAYOUT-CWIDTH_OPT = 'X'.
  L_LAYOUT-SEL_MODE = 'A'.

  CLEAR L_VARIANT.
  L_VARIANT-REPORT = SY-REPID.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER =
*     I_BUFFER_ACTIVE    =
      I_CALLBACK_PROGRAM = '/ZAK/AFA_ABEV_CORR'
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   = ' '
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      IS_LAYOUT_LVC      = L_LAYOUT
      IT_FIELDCAT_LVC    = LI_FIELDCAT
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS_LVC             =
*     IT_SORT_LVC        =
*     IT_FILTER_LVC      =
*     IT_HYPERLINK       =
*     IS_SEL_HIDE        =
      I_DEFAULT          = 'X'
      I_SAVE             = 'A'
      IS_VARIANT         = L_VARIANT
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
*     IS_PRINT_LVC       =
*     IS_REPREP_ID_LVC   =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  =
*     I_HTML_HEIGHT_END  =
*     IT_EXCEPT_QINFO_LVC               =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB           = I_/ZAK/ANALITIKA
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " GRID_DISPLAY
