*&---------------------------------------------------------------------*
*& Program: verification and execution program for transferring the return
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_SZLA_NONEED MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: The program based on the conditions specified in the selection
*& displays (or modifies in production) using a remote RFC call
*& the returns that can be received or it lists what has already been received.
*&---------------------------------------------------------------------*
*& Author            : Bana G. Peter - Ness
*& Created on        : 2014.09.04
*& Functional spec by: ________
*& SAP module        :
*& Program  type     : Report
*& SAP version        :
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (write the OSS note number at the end of each modified line)*
*&
*& LOG# DATE MODIFIER DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*& 0001 2014.09.04 Bana G. Peter Initialized version
*& 0002 09/08/2014 Bana G. Peter Add live plant
*&---------------------------------------------------------------------*
*++S4HANA#01.
DATA L_SAVE_OK TYPE OK.
*--S4HANA#01.
INCLUDE /ZAK/COMMON_STRUCT.

CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.

*&---------------------------------------------------------------------*
*& Simple sleep basics
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Type Declarations
*&---------------------------------------------------------------------*
TYPES: TY_DATA TYPE TABLE OF /ZAK/AFA_SZLA.

INCLUDE /ZAK/ALV_GRID_ALAP.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/AFA_SZLA.
*&---------------------------------------------------------------------*
*  PROGRAM VARIABLES *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Constants           -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Ranges              -   (R_xxx...)                              *
*      Global variables - (G_xxx...) *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Types               -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methods             -   (METH_xxx...)                           *
*      Object              -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA G_SUBRC TYPE SYSUBRC.

DATA G_ANSWER.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Company.
  PARAMETERS: P_BUKRS     LIKE /ZAK/AFA_SZLA-BUKRS VALUE CHECK OBLIGATORY.
*++2065 #05.
* Tax ID
  SELECT-OPTIONS S_ADOAZ  FOR  /ZAK/AFA_SZLA-ADOAZON.
*--2065 #05.
* Year
  SELECT-OPTIONS S_GJAHR  FOR  /ZAK/AFA_SZLA-GJAHR.
* Month
  SELECT-OPTIONS S_MONAT  FOR  /ZAK/AFA_SZLA-MONAT.
* Index
  SELECT-OPTIONS S_ZINDEX FOR  /ZAK/AFA_SZLA-ZINDEX.
* Package
  SELECT-OPTIONS S_PACK   FOR  /ZAK/AFA_SZLA-PACK.
* Evidence
  SELECT-OPTIONS S_BELNR  FOR  /ZAK/AFA_SZLA-BSEG_BELNR.
* Joint account identifier
  SELECT-OPTIONS S_SZA    FOR  /ZAK/AFA_SZLA-SZAMLASZA.
* Account ID
  SELECT-OPTIONS S_SZ     FOR  /ZAK/AFA_SZLA-SZAMLASZ.
* History Account ID
  SELECT-OPTIONS S_SZE    FOR  /ZAK/AFA_SZLA-SZAMLASZE.
* Account type
  SELECT-OPTIONS S_SZT    FOR  /ZAK/AFA_SZLA-SZLATIP.

SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Eligibility check
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
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*Definition of data
*++S4HANA#01.
*  PERFORM GET_DATA USING G_SUBRC.
  PERFORM GET_DATA CHANGING G_SUBRC.
*--S4HANA#01.
  IF NOT G_SUBRC IS INITIAL.
    MESSAGE I141.
*   There is no analytics record matching the condition!
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  IF NOT GT_DATA IS INITIAL.
    GT_DATA_TMP[] = GT_DATA[].
    CALL SCREEN 9000.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM HANDLE_HOTSPOT_CLICK  USING    UV_COLUMN_NAME
*                                    UV_ROW_INDEX.
FORM HANDLE_HOTSPOT_CLICK  USING    UV_COLUMN_NAME TYPE LVC_S_COL
                                    UV_ROW_INDEX TYPE LVC_S_ROW-INDEX.
*--S4HANA#01.

** example implementation of hotspot click
*  CASE uv_column_name.
*    WHEN 'EBELN'.
*      READ TABLE gt_data INTO gs_data INDEX uv_row_index.
*      IF sy-subrc EQ 0.
*        ASSIGN COMPONENT uv_column_name OF STRUCTURE gs_data TO <fs_any>.
*        IF sy-subrc EQ 0.
*          SET PARAMETER ID 'BES' FIELD gs_data-ebeln.
*          CALL TRANSACTION 'ME23' AND SKIP FIRST SCREEN.
*        ENDIF.
*
*      ENDIF.
*
*  ENDCASE.
ENDFORM.                    " HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM HANDLE_BUTTON_CLICK  USING    UV_COLUMN_NAME
*                                   UV_ROW_INDEX.
FORM HANDLE_BUTTON_CLICK  USING    UV_COLUMN_NAME TYPE LVC_S_COL-FIELDNAME
                                   UV_ROW_INDEX TYPE LVC_S_ROID-ROW_ID.
*--S4HANA#01.
ENDFORM.                    " HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM HANDLE_DOUBLE_CLICK  USING UV_COLUMN_NAME
*                                UV_ROW_INDEX.
FORM HANDLE_DOUBLE_CLICK  USING UV_COLUMN_NAME TYPE LVC_S_COL-FIELDNAME
                                UV_ROW_INDEX TYPE LVC_S_ROID-ROW_ID.
*--S4HANA#01.

ENDFORM.                    " HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
FORM GET_SELECTED_ROWS  USING    UO_ALV TYPE REF TO CL_GUI_ALV_GRID
                        CHANGING CT_ROWS TYPE LVC_T_ROID.

  DATA LW_ROWS TYPE LVC_S_ROID.
  DATA LW_DATA TYPE /ZAK/AFA_SZLA.
  DATA LS_STABLE TYPE LVC_S_STBL.

  FREE: CT_ROWS.
* get selected rows
  CALL METHOD UO_ALV->GET_SELECTED_ROWS
    IMPORTING
*     et_index_rows =
      ET_ROW_NO = CT_ROWS.

  LOOP AT CT_ROWS INTO LW_ROWS.
    READ TABLE GT_DATA INDEX LW_ROWS-ROW_ID INTO LW_DATA.
    LW_DATA-NONEED = 'X'.
    MODIFY GT_DATA FROM LW_DATA INDEX LW_ROWS-ROW_ID TRANSPORTING NONEED.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    MESSAGE W186.
*   Please select the row or rows to be processed!
  ELSE.
*    get position
    LS_STABLE-ROW = 'X'.
    LS_STABLE-COL = 'X'.

    CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
  ENDIF.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_UNSELECTED_ROWS
*&---------------------------------------------------------------------*
FORM GET_UNSELECTED_ROWS  USING    UO_ALV TYPE REF TO CL_GUI_ALV_GRID
                        CHANGING CT_ROWS TYPE LVC_T_ROID.

  DATA LW_ROWS TYPE LVC_S_ROID.
  DATA LW_DATA TYPE /ZAK/AFA_SZLA.
  DATA LS_STABLE TYPE LVC_S_STBL.

  FREE: CT_ROWS.
* get selected rows
  CALL METHOD UO_ALV->GET_SELECTED_ROWS
    IMPORTING
*     et_index_rows =
      ET_ROW_NO = CT_ROWS.

  LOOP AT CT_ROWS INTO LW_ROWS.
    READ TABLE GT_DATA INDEX LW_ROWS-ROW_ID INTO LW_DATA.
    CLEAR LW_DATA-NONEED.
    MODIFY GT_DATA FROM LW_DATA INDEX LW_ROWS-ROW_ID TRANSPORTING NONEED.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    MESSAGE W186.
*   Please select the row or rows to be processed!
  ELSE.
*    get position
    LS_STABLE-ROW = 'X'.
    LS_STABLE-COL = 'X'.

    CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.
  ENDIF.

ENDFORM.                    " GET_UNSELECTED_ROWS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SHOW_SELECTED_ROWS
*&---------------------------------------------------------------------*
FORM SHOW_SELECTED_ROWS  USING    UT_ROWS TYPE LVC_T_ROID.

*  DATA: lv_rows TYPE i.
*
*  lv_rows = lines( ut_rows ).
*  MESSAGE i001(00) WITH 'Number of rows selected: ' lv_rows.

ENDFORM.                    " SHOW_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_DATA USING $SUBRC.
FORM GET_DATA CHANGING $SUBRC TYPE SYSUBRC.
*--S4HANA#01.

  CLEAR $SUBRC.

  SELECT * INTO TABLE GT_DATA
           FROM /ZAK/AFA_SZLA
          WHERE BUKRS      EQ P_BUKRS
*++2065 #05.
            AND ADOAZON    IN S_ADOAZ
*--2065 #05.
            AND GJAHR      IN S_GJAHR
            AND MONAT      IN S_MONAT
            AND ZINDEX     IN S_ZINDEX
            AND PACK       IN S_PACK
            AND BSEG_BELNR IN S_BELNR
            AND SZAMLASZA  IN S_SZA
            AND SZAMLASZ   IN S_SZ
            AND SZAMLASZE  IN S_SZE
            AND SZLATIP    IN S_SZT
*++S4HANA#01.
          ORDER BY PRIMARY KEY.
*--S4HANA#01.
*            AND NONEED     NE 'X'.
  IF NOT SY-SUBRC IS INITIAL.
    MOVE SY-SUBRC TO $SUBRC.
  ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR  '9000'.
ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_ALV_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_ALV_9000 OUTPUT.
  IF NOT GO_CONT IS BOUND.
* not background running
    IF CL_GUI_ALV_GRID=>OFFLINE( ) EQ ABAP_FALSE.
      CREATE OBJECT GO_CONT
        EXPORTING
          CONTAINER_NAME              = 'CONT1'
        EXCEPTIONS
          CNTL_ERROR                  = 1
          CNTL_SYSTEM_ERROR           = 2
          CREATE_ERROR                = 3
          LIFETIME_ERROR              = 4
          LIFETIME_DYNPRO_DYNPRO_LINK = 5
          OTHERS                      = 6.
      IF SY-SUBRC <> 0.
      ENDIF.
      IF NOT GO_ALV IS BOUND.
        CREATE OBJECT GO_ALV
          EXPORTING
            I_PARENT          = GO_CONT
          EXCEPTIONS
            ERROR_CNTL_CREATE = 1
            ERROR_CNTL_INIT   = 2
            ERROR_CNTL_LINK   = 3
            ERROR_DP_CREATE   = 4
            OTHERS            = 5.
        IF SY-SUBRC <> 0.
        ENDIF.
      ENDIF.
    ELSE.
* background running
      CREATE OBJECT GO_ALV
        EXPORTING
          I_PARENT          = GO_BACKCONT
        EXCEPTIONS
          ERROR_CNTL_CREATE = 1
          ERROR_CNTL_INIT   = 2
          ERROR_CNTL_LINK   = 3
          ERROR_DP_CREATE   = 4
          OTHERS            = 5.
      IF SY-SUBRC <> 0.
      ENDIF.

    ENDIF.
* fieldcatalog generation
    M_CREATE_FCAT '/ZAK/AFA_SZLA' GT_FCAT.
* Convert to checkbox
    M_CHECKBOX 'NONEED'.

* turning it into a hotspot
*    m_hotspot gt_fcat 'EBELN'.

* zebra and optimal field width
    M_TYPICAL_LAYO GS_LAYO.

* modifiability setting
*    m_modify_field gt_fcat 'ERNAM' 'EDIT' 'X'.
* event handler instantiation
    CREATE OBJECT GO_EVT.

* hotspot event registration
    SET HANDLER GO_EVT->HANDLE_HOTSPOT_CLICK FOR GO_ALV.

    SET HANDLER GO_EVT->HANDLE_BUTTON_CLICK FOR GO_ALV.

* saveable layouts
    GS_VARI-REPORT    = SY-CPROG.
    GS_VARI-USERNAME  = SY-UNAME.

* selectable lines
    GS_LAYO-SEL_MODE = 'A'.


* modifiability setting
    CALL METHOD GO_ALV->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.
    IF GV_MOD IS INITIAL.
      CALL METHOD GO_ALV->SET_READY_FOR_INPUT
        EXPORTING
          I_READY_FOR_INPUT = 0.
    ELSE.
      CALL METHOD GO_ALV->SET_READY_FOR_INPUT
        EXPORTING
          I_READY_FOR_INPUT = 1.
    ENDIF.
* display
    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = GS_VARI
        I_SAVE                        = 'U' "user-level layout save
*       i_default                     = 'X'
        IS_LAYOUT                     = GS_LAYO
      CHANGING
        IT_OUTTAB                     = GT_DATA
        IT_FIELDCATALOG               = GT_FCAT
*       it_sort                       =
*       it_filter                     =
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.
    IF SY-SUBRC <> 0.
    ENDIF.


  ELSE.
    IF GO_ALV IS BOUND.

* modifiability setting
      IF GV_MOD IS INITIAL.
        CALL METHOD GO_ALV->SET_READY_FOR_INPUT
          EXPORTING
            I_READY_FOR_INPUT = 0.
      ELSE.
        CALL METHOD GO_ALV->SET_READY_FOR_INPUT
          EXPORTING
            I_READY_FOR_INPUT = 1.
      ENDIF.

      CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY
        EXCEPTIONS
          FINISHED = 1
          OTHERS   = 2.
      IF SY-SUBRC <> 0.
      ENDIF.

    ENDIF.
  ENDIF.
ENDMODULE.                 " INIT_ALV_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

*++S4HANA#01.
*  PERFORM CHECK_SAVE USING G_ANSWER.
  PERFORM CHECK_SAVE CHANGING G_ANSWER.
*--S4HANA#01.

  PERFORM EXIT USING G_ANSWER.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
*++S4HANA#01.
*  DATA L_SAVE_OK TYPE OK.
*--S4HANA#01.

  L_SAVE_OK = GV_OK_9000.
  CLEAR GV_OK_9000.

  CASE L_SAVE_OK.
    WHEN 'BACK'.
*++S4HANA#01.
*      PERFORM CHECK_SAVE USING G_ANSWER.
      PERFORM CHECK_SAVE CHANGING G_ANSWER.
*--S4HANA#01.
      PERFORM EXIT USING G_ANSWER.
    WHEN 'NONEED'.
      PERFORM GET_SELECTED_ROWS USING    GO_ALV
                                CHANGING GT_ROWS.
    WHEN 'NEED'.
      PERFORM GET_UNSELECTED_ROWS USING    GO_ALV
                                  CHANGING GT_ROWS.

    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
      PERFORM EXIT USING G_ANSWER.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_SAVE USING $ANSWER.
FORM CHECK_SAVE CHANGING $ANSWER LIKE G_ANSWER.
*--S4HANA#01.
  IF GT_DATA_TMP[] NE GT_DATA[].
    CLEAR $ANSWER.
*++MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12
*    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
*      EXPORTING
*        TEXTLINE1 = 'Continue?'(901)
**      TEXTLINE2     = ' '
*        TITLE = 'Confirmation'(902)
**      START_COLUMN  = 25
**      START_ROW     = 6
*        DEFAULTOPTION = 'N'
*      IMPORTING
*        ANSWER        = $ANSWER.
    DATA L_QUESTION TYPE STRING.

    CONCATENATE 'Adatok elvesznek!' 'Folytatja?'(901) INTO L_QUESTION SEPARATED BY SPACE.
*
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Megerősítés'(902)
*       DIAGNOSE_OBJECT       = ' '
        TEXT_QUESTION         = L_QUESTION
*       TEXT_BUTTON_1         = 'Ja'(001)
*       ICON_BUTTON_1         = ' '
*       TEXT_BUTTON_2         = 'Nein'(002)
*       ICON_BUTTON_2         = ' '
        DEFAULT_BUTTON        = '2'
        DISPLAY_CANCEL_BUTTON = ' '
*       USERDEFINED_F1_HELP   = ' '
        START_COLUMN          = 25
        START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        ANSWER                = $ANSWER
*   TABLES
*       PARAMETER             =
*   EXCEPTIONS
*       TEXT_NOT_FOUND        = 1
*       OTHERS                = 2
      .
    IF $ANSWER EQ '1'.
      $ANSWER = 'J'.
    ELSE.
      $ANSWER = 'N'.
    ENDIF.
*--MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12

  ENDIF.
ENDFORM.                    " CHECK_SAVE
*&---------------------------------------------------------------------*
*&      Form  EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ANSWER  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM EXIT  USING    $ANSWER.
FORM EXIT  USING    $ANSWER LIKE G_ANSWER.
*--S4HANA#01.

  IF $ANSWER NE 'N'.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.                    " EXIT
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .

  MODIFY /ZAK/AFA_SZLA FROM TABLE GT_DATA.
  COMMIT WORK AND WAIT.
  MESSAGE I223.
  CLEAR G_ANSWER.
* The data has been saved successfully!
  PERFORM EXIT USING G_ANSWER.

ENDFORM.                    " SAVE_DATA
