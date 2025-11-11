*&---------------------------------------------------------------------*
*& Report  /ZAK/ANALITIKA_SZLA_CORR
*&
*&---------------------------------------------------------------------*
*& The program populates the joint account ID based on the selection
*&---------------------------------------------------------------------*
REPORT  /ZAK/BSET_CORR  MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& TABLES                                                             *
*&---------------------------------------------------------------------*
*++S4HANA#01.
*TABLES: /ZAK/BSET.
DATA GS_/ZAK/BSET TYPE /ZAK/BSET.
*--S4HANA#01.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                  *
*      Internal table     -   (I_xxx...)                              *
*      FORM parameter     -   ($xxxx...)                              *
*      Constant           -   (C_xxx...)                              *
*      Parameter variable -   (P_xxx...)                              *
*      Selection option   -   (S_xxx...)                              *
*      Ranges             -   (R_xxx...)                              *
*      Global variables   -   (V_xxx...)                              *
*      Local variables    -   (L_xxx...)                              *
*      Work area          -   (W_xxx...)                              *
*      Type               -   (T_xxx...)                              *
*      Macros             -   (M_xxx...)                              *
*      Field-symbol       -   (FS_xxx...)                             *
*      Method             -   (METH_xxx...)                           *
*      Object             -   (O_xxx...)                              *
*      Class              -   (CL_xxx...)                             *
*      Event              -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*MACRO definition for range population
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                          INITIAL SIZE 0.
DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.

DATA I_/ZAK/BSET TYPE STANDARD TABLE OF /ZAK/BSET.
DATA W_/ZAK/BSET TYPE /ZAK/BSET.


*


*DATA I_/ZAK/ANAL_C1 TYPE STANDARD TABLE OF /ZAK/ANAL_C1
*                          INITIAL SIZE 0.
*DATA W_/ZAK/ANAL_C1 TYPE /ZAK/ANAL_C1.
*
DATA:
  LT_RET  TYPE TABLE OF BAPIRET2,
  LO_ALV  TYPE REF TO CL_SALV_TABLE,
  LO_COLS TYPE REF TO CL_SALV_COLUMNS,
  LO_FUNC TYPE REF TO CL_SALV_FUNCTIONS_LIST.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
  PARAMETER P_BUKRS LIKE /ZAK/BSET-BUKRS OBLIGATORY.
*++S4HANA#01.
*SELECT-OPTIONS S_BELNR  FOR /ZAK/BSET-BELNR.
*SELECT-OPTIONS S_GJAHR  FOR /ZAK/BSET-GJAHR.
  SELECT-OPTIONS S_BELNR  FOR GS_/ZAK/BSET-BELNR.
  SELECT-OPTIONS S_GJAHR  FOR GS_/ZAK/BSET-GJAHR.
*--S4HANA#01.

  PARAMETER P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL01.
*
**&---------------------------------------------------------------------*
** INITALIZATION
**&---------------------------------------------------------------------*
*INITIALIZATION.
*
*  M_DEF S_BTYPE 'I' 'EQ' '0665' SPACE.
*  M_DEF S_BTYPE 'I' 'EQ' '0765' SPACE.
*++1765 #19.
INITIALIZATION.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
  ENDIF.
*--1765 #19.
**&---------------------------------------------------------------------*
** AT SELECTION-SCREEN OUTPUT
**&---------------------------------------------------------------------*
*AT SELECTION-SCREEN OUTPUT.
*
**  Set screen attributes
*  PERFORM SET_SCREEN_ATTRIBUTES.
*
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Data processing
  PERFORM PROCESS_DATA.
  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I000 WITH 'Nincs a szelekciónak megfelelő adat!'.
*   & & & &
  ENDIF.

  IF P_TEST IS INITIAL.
    PERFORM PRODUCTIVE_RUN.
  ENDIF.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*ALV
  CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV
                          CHANGING  T_TABLE = I_/ZAK/ANALITIKA ).
  LO_COLS = LO_ALV->GET_COLUMNS( ).
  LO_COLS->SET_OPTIMIZE( ).
  LO_FUNC  = LO_ALV->GET_FUNCTIONS( ).
  LO_FUNC->SET_ALL( ABAP_TRUE ).
  LO_ALV->DISPLAY( ).


*
*
**&---------------------------------------------------------------------*
**&      Form  SET_SCREEN_ATTRIBUTES
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM SET_SCREEN_ATTRIBUTES .
*
*  LOOP AT SCREEN.
*    IF SCREEN-GROUP1 = 'DIS'.
*      SCREEN-INPUT = 0.
*      SCREEN-OUTPUT = 1.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.                    " SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .
  DATA LW_/ZAK/BSET TYPE /ZAK/BSET.
  DATA L_FLAG TYPE /ZAK/FLAG.

*/ZAK/BSET selection
*++S4HANA#01.
*  SELECT * INTO LW_/ZAK/BSET
*           FROM /ZAK/BSET
*          WHERE BUKRS EQ P_BUKRS
*            AND BELNR IN S_BELNR
*            AND GJAHR IN S_GJAHR
*            AND ZINDEX NE ''.
*    IF  LW_/ZAK/BSET-BUPER NE LW_/ZAK/BSET-ADODAT(6).
*      APPEND LW_/ZAK/BSET TO I_/ZAK/BSET.
*    ENDIF.
*  ENDSELECT.
  TYPES: BEGIN OF TS_/ZAK/BEVALLI_NEW,
           FLAG   LIKE L_FLAG,
           BUKRS  TYPE /ZAK/BEVALLI-BUKRS,
           BTYPE  TYPE /ZAK/BEVALLI-BTYPE,
           GJAHR  TYPE /ZAK/BEVALLI-GJAHR,
           MONAT  TYPE /ZAK/BEVALLI-MONAT,
           ZINDEX TYPE /ZAK/BEVALLI-ZINDEX,
         END OF TS_/ZAK/BEVALLI_NEW.
  DATA: LT_/ZAK/BEVALLI_NEW TYPE HASHED TABLE OF TS_/ZAK/BEVALLI_NEW
    WITH UNIQUE KEY BUKRS BTYPE GJAHR MONAT ZINDEX.
  SELECT * APPENDING TABLE I_/ZAK/BSET FROM /ZAK/BSET
          WHERE BUKRS EQ P_BUKRS
            AND BELNR IN S_BELNR
            AND GJAHR IN S_GJAHR
            AND ZINDEX NE ''
            AND BUPER NE LW_/ZAK/BSET-ADODAT(6).
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
           FOR ALL ENTRIES IN I_/ZAK/BSET
          WHERE BUKRS      = I_/ZAK/BSET-BUKRS
            AND BSEG_GJAHR = I_/ZAK/BSET-GJAHR
            AND BSEG_BELNR = I_/ZAK/BSET-BELNR
            AND BSEG_BUZEI = I_/ZAK/BSET-BUZEI
*++S4HANA#01.
          ORDER BY PRIMARY KEY.
*--S4HANA#01.

*++S4HANA#01.
  IF NOT I_/ZAK/ANALITIKA[] IS INITIAL.
    DATA(LT_W_/ZAK/ANALITIKA_DRV) = I_/ZAK/ANALITIKA[].
    SORT LT_W_/ZAK/ANALITIKA_DRV BY BUKRS BTYPE GJAHR MONAT ZINDEX.
    DELETE ADJACENT DUPLICATES FROM LT_W_/ZAK/ANALITIKA_DRV
      COMPARING BUKRS BTYPE GJAHR MONAT ZINDEX.
    SELECT FLAG BUKRS BTYPE GJAHR MONAT ZINDEX
      FROM /ZAK/BEVALLI
      INTO CORRESPONDING FIELDS OF TABLE LT_/ZAK/BEVALLI_NEW
      FOR ALL ENTRIES IN LT_W_/ZAK/ANALITIKA_DRV
      WHERE BUKRS EQ LT_W_/ZAK/ANALITIKA_DRV-BUKRS
      AND   BTYPE EQ LT_W_/ZAK/ANALITIKA_DRV-BTYPE
      AND   GJAHR EQ LT_W_/ZAK/ANALITIKA_DRV-GJAHR
      AND   MONAT EQ LT_W_/ZAK/ANALITIKA_DRV-MONAT
      AND   ZINDEX EQ LT_W_/ZAK/ANALITIKA_DRV-ZINDEX.
    FREE LT_W_/ZAK/ANALITIKA_DRV[].
  ENDIF.
*--S4HANA#01.

  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*   BEVALLI check
*++S4HANA#01.
*    SELECT SINGLE FLAG INTO L_FLAG
*                       FROM /ZAK/BEVALLI
*                      WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
*                        AND BTYPE EQ W_/ZAK/ANALITIKA-BTYPE
*                        AND GJAHR EQ W_/ZAK/ANALITIKA-GJAHR
*                        AND MONAT EQ W_/ZAK/ANALITIKA-MONAT
*                        AND ZINDEX EQ W_/ZAK/ANALITIKA-ZINDEX.
    ASSIGN LT_/ZAK/BEVALLI_NEW[
       BUKRS = W_/ZAK/ANALITIKA-BUKRS
       BTYPE = W_/ZAK/ANALITIKA-BTYPE
       GJAHR = W_/ZAK/ANALITIKA-GJAHR
       MONAT = W_/ZAK/ANALITIKA-MONAT
       ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
    ] TO FIELD-SYMBOL(<LS_/ZAK/BEVALLI_NEW>).
    IF SY-SUBRC = 0.
      L_FLAG = <LS_/ZAK/BEVALLI_NEW>-FLAG.
    ENDIF.
*--S4HANA#01.
    IF L_FLAG EQ 'X'.
      DELETE I_/ZAK/ANALITIKA.
      CONTINUE.
    ENDIF.

    W_/ZAK/ANALITIKA-BSZNUM = '999'.
    MULTIPLY W_/ZAK/ANALITIKA-DMBTR BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-LWBAS BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-FWBAS BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-LWSTE BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-FWSTE BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-HWBTR BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-FWBTR BY -1.
    MULTIPLY W_/ZAK/ANALITIKA-FIELD_N BY -1.
    MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA.
  ENDLOOP.
*++S4HANA#01.
  FREE LT_/ZAK/BEVALLI_NEW[].
*--S4HANA#01.

ENDFORM. " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  PRODUCTIVE_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRODUCTIVE_RUN .

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
*    The database does not contain a record that can be processed!
    EXIT.
  ENDIF.

*  Always run it in test mode first
  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = P_BUKRS
*     I_BTYPE     = P_BTYPE
      I_BTYPART   = 'AFA'
      I_BSZNUM    = '999'
*     I_PACK      =
      I_GEN       = 'X'
      I_TEST      = 'X'
*     I_FILE      =
    TABLES
      I_ANALITIKA = I_/ZAK/ANALITIKA
      E_RETURN    = LI_RETURN.

*   Handle messages
  IF NOT LI_RETURN[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = LI_RETURN.
  ENDIF.

*  If this is not a test run then check for errors
  LOOP AT LI_RETURN INTO LW_RETURN WHERE TYPE CA 'EA'.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    MESSAGE E062.
*     Data upload is not possible!
  ENDIF.

*    If it is not running in the background
  IF NOT LI_RETURN[] IS INITIAL AND SY-BATCH IS INITIAL.
*    Load texts
    MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
    MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                         TO L_DIAGNOSETEXT1.
    MOVE 'Folytatja  feldolgozást?'(003)
                                         TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp - E09324753 - Gábor Balázs (Ness) - 12.07.2016
*++S4HANA#01.
**    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
**      EXPORTING
**        DEFAULTOPTION  = 'N'
**        DIAGNOSETEXT1  = L_DIAGNOSETEXT1
***       DIAGNOSETEXT2  = ' '
***       DIAGNOSETEXT3  = ' '
**        TEXTLINE1      = L_TEXTLINE1
***       TEXTLINE2      = ' '
**        TITEL          = L_TITLE
**        START_COLUMN   = 25
**        START_ROW      = 6
***       CANCEL_DISPLAY = 'X'
**      IMPORTING
**        ANSWER         = L_ANSWER.
*    DATA L_QUESTION TYPE STRING.
*
*    CONCATENATE L_DIAGNOSETEXT1
*                L_TEXTLINE1
*                INTO L_QUESTION SEPARATED BY SPACE.
*    CALL FUNCTION 'POPUP_TO_CONFIRM'
*      EXPORTING
*        TITLEBAR       = L_TITLE
**       DIAGNOSE_OBJECT             = ' '
*        TEXT_QUESTION  = L_QUESTION
**       TEXT_BUTTON_1  = 'Ja'(001)
**       ICON_BUTTON_1  = ' '
**       TEXT_BUTTON_2  = 'Nein'(002)
**       ICON_BUTTON_2  = ' '
*        DEFAULT_BUTTON = '2'
**       DISPLAY_CANCEL_BUTTON       = 'X'
**       USERDEFINED_F1_HELP         = ' '
*        START_COLUMN   = 25
*        START_ROW      = 6
**       POPUP_TYPE     =
*      IMPORTING
*        ANSWER         = L_ANSWER.
*    IF L_ANSWER EQ '1'.
*      MOVE 'J' TO L_ANSWER.
*    ENDIF.

    DATA: LV_W_TEXT_QUESTION_0(400) TYPE C.
    CONCATENATE
      L_DIAGNOSETEXT1
      L_TEXTLINE1
      INTO LV_W_TEXT_QUESTION_0 SEPARATED BY SPACE IN CHARACTER MODE.

    DATA: LV_W_DEFAULT_BUTTON_0(1) TYPE C.
    LV_W_DEFAULT_BUTTON_0 = 'N'.
    IF LV_W_DEFAULT_BUTTON_0 = 'Y' OR LV_W_DEFAULT_BUTTON_0 = 'J'.
      LV_W_DEFAULT_BUTTON_0 = '1'.
    ELSEIF LV_W_DEFAULT_BUTTON_0 = 'N'.
      LV_W_DEFAULT_BUTTON_0 = '2'.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR       = L_TITLE
        TEXT_QUESTION  = LV_W_TEXT_QUESTION_0
        DEFAULT_BUTTON = LV_W_DEFAULT_BUTTON_0
        START_COLUMN   = 25
        START_ROW      = 6
      IMPORTING
        ANSWER         = L_ANSWER
      EXCEPTIONS
        TEXT_NOT_FOUND = 1.
    CASE SY-SUBRC.
      WHEN 1.
* IMPLEMENT ME
    ENDCASE.

    IF L_ANSWER = '1'.
      L_ANSWER = 'J'.
    ELSEIF L_ANSWER = '2'.
      L_ANSWER = 'N'.
    ENDIF.
*--S4HANA#01.
*--MOL_UPG_ChangeImp - E09324753 - Gábor Balázs (Ness) - 12.07.2016
*    Otherwise continue
  ELSE.
    MOVE 'J' TO L_ANSWER.
  ENDIF.

*    Proceed with the database update
  IF L_ANSWER EQ 'J'.
*      Update data
    CALL FUNCTION '/ZAK/UPDATE'
      EXPORTING
        I_BUKRS     = P_BUKRS
*       I_BTYPE     = P_BTYPE
        I_BTYPART   = 'AFA'
        I_BSZNUM    = '999'
*       I_PACK      =
        I_GEN       = 'X'
        I_TEST      = ''
*       I_FILE      =
      TABLES
        I_ANALITIKA = I_/ZAK/ANALITIKA
        E_RETURN    = LI_RETURN.
  ENDIF.

  LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET.
*   /ZAK/BSET update:
    UPDATE /ZAK/BSET SET ZINDEX = ''
                  WHERE BUKRS EQ W_/ZAK/BSET-BUKRS
                    AND BELNR EQ W_/ZAK/BSET-BELNR
                    AND GJAHR EQ W_/ZAK/BSET-GJAHR
                    AND BUZEI EQ W_/ZAK/BSET-BUZEI.
  ENDLOOP.

  COMMIT WORK AND WAIT.
  MESSAGE I216.
* Data changes saved!

ENDFORM.                    " PRODUCTIVE_RUN
