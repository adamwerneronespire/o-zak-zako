*&---------------------------------------------------------------------*
*& Report /ZAK/KATA_SAP_SEL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /ZAK/KATA_SAP_SEL MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Based on the criteria entered on the selection,
*& the program filters the data from the SAP documents and stores them
*& in /ZAK/KATA_SEL.
*&---------------------------------------------------------------------*
*& Author             : Balázs Gábor
*& Creation date      : 2021.02.17
*& Functional spec by : ________
*& SAP module name    : /ZAK/ZAKO
*& Program type       : Report
*& SAP version        :
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*&                                   modification
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.

*Macro definition for populating a range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
*& TABLES                                                               *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table        -   (I_xxx...)                             *
*      FORM parameter        -   ($xxxx...)                             *
*      Constant              -   (C_xxx...)                             *
*      Parameter variable    -   (P_xxx...)                             *
*      Selection option      -   (S_xxx...)                             *
*      Ranges                -   (R_xxx...)                             *
*      Global variables      -   (V_xxx...)                             *
*      Local variables       -   (L_xxx...)                             *
*      Work area             -   (W_xxx...)                             *
*      Type                  -   (T_xxx...)                             *
*      Macros                -   (M_xxx...)                             *
*      Field-symbol          -   (FS_xxx...)                            *
*      Method                -   (METH_xxx...)                          *
*      Object                -   (O_xxx...)                             *
*      Class                 -   (CL_xxx...)                            *
*      Event                 -   (E_xxx...)                             *
*&---------------------------------------------------------------------*
DATA V_BUKRS TYPE BUKRS.
DATA V_MESSAGE TYPE XFELD.
DATA V_MESSAGE_ERR TYPE XFELD.

RANGES R_PACK FOR /ZAK/ANALITIKA-PACK.
DATA I_/ZAK/AFA_CUST TYPE STANDARD TABLE OF /ZAK/AFA_CUST INITIAL SIZE 0.
DATA I_/ZAK/KATA_SEL TYPE STANDARD TABLE OF /ZAK/KATA_SEL INITIAL SIZE 0.

DATA V_LAST_DATE TYPE SY-DATUM.
DATA V_SUBRC LIKE SY-SUBRC.

DATA V_REPID LIKE SY-REPID.

* Variables for ALV handling
DATA: V_OK_CODE          LIKE SY-UCOMM,
      V_SAVE_OK          LIKE SY-UCOMM,
      V_CONTAINER        TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT         TYPE LVC_T_FCAT,
      V_LAYOUT           TYPE LVC_S_LAYO,
      V_VARIANT          TYPE DISVARIANT,
      V_GRID             TYPE REF TO CL_GUI_ALV_GRID.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Company.
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
* Return type.
PARAMETERS:  P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                                      DEFAULT C_BTYPART_AFA
                                              OBLIGATORY.
* Year
PARAMETERS P_GJAHR TYPE GJAHR DEFAULT SY-DATUM(4) OBLIGATORY.
*Month
PARAMETERS P_MONAT TYPE MONAT OBLIGATORY.
*Test run
PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++2265 #02.
* Authorization check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
                   ID 'TCD'  FIELD '/ZAK/KATA_SAP_SEL'.
*--2265 #02.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_SELECTION.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*  Company rotation
  PERFORM ROTATE_BUKRS_OUTPUT USING  P_BUKRS
                                     V_BUKRS.
*  Authorization check
  PERFORM AUTHORITY_CHECK USING V_BUKRS
                                P_BTYPAR
                                C_ACTVT_01.
* Last day of the month:
  PERFORM GET_LAST_DATE CHANGING V_LAST_DATE.

* Determining package identifiers
  PERFORM GET_PACK TABLES R_PACK.
  IF R_PACK[] IS INITIAL.
    MESSAGE I141.
*   No analytic record matches the criteria!
    EXIT.
  ENDIF.
*  Loading KATA settings
  PERFORM GET_KATA_CUST USING V_SUBRC.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE E315.
*   Error while determining the KATA settings!
  ENDIF.

* Filtering analytic records
  PERFORM GET_ANALITIKA.

* Test or productive run, database modification, etc.
  PERFORM INS_DATA USING P_TEST.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

*  No list is created in the background.
  IF SY-BATCH IS INITIAL.
    PERFORM LIST_DISPLAY.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_BUKRS  text
*----------------------------------------------------------------------*
FORM ROTATE_BUKRS_OUTPUT  USING   $BUKRS
                                  $BUKRS_OUTPUT.

  CLEAR $BUKRS_OUTPUT.

  CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
    EXPORTING
      I_AD_BUKRS    = $BUKRS
    IMPORTING
      E_FI_BUKRS    = $BUKRS_OUTPUT
    EXCEPTIONS
      MISSING_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E231 WITH $BUKRS.
*      Error determining company rotation! (/ZAK/ROTATE_BUKRS_OUTPUT)
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_PACK  text
*----------------------------------------------------------------------*
FORM GET_PACK  TABLES   $R_PACK STRUCTURE R_PACK.

  DATA L_PACK TYPE /ZAK/PACK.

*Collecting packages
  SELECT /ZAK/BEVALLP~PACK INTO @L_PACK
                          FROM /ZAK/BEVALL
                          LEFT OUTER JOIN /ZAK/BEVALLSZ
                            ON /ZAK/BEVALLSZ~BUKRS EQ /ZAK/BEVALL~BUKRS
                           AND /ZAK/BEVALLSZ~BTYPE EQ /ZAK/BEVALL~BTYPE
                          LEFT OUTER JOIN /ZAK/BEVALLP
                            ON /ZAK/BEVALLP~PACK EQ /ZAK/BEVALLSZ~PACK
                          WHERE /ZAK/BEVALL~BUKRS EQ @P_BUKRS
                            AND /ZAK/BEVALL~BTYPART EQ @P_BTYPAR
                            AND /ZAK/BEVALL~DATBI GE @V_LAST_DATE
                            AND /ZAK/BEVALL~DATAB LE @V_LAST_DATE
                            AND /ZAK/BEVALLSZ~GJAHR EQ @P_GJAHR
                            AND /ZAK/BEVALLSZ~MONAT EQ @P_MONAT
                            AND /ZAK/BEVALLP~XLOEK EQ ''
                            AND /ZAK/BEVALLP~KATA EQ ''.
    M_DEF $R_PACK 'I' 'EQ' L_PACK ''.
  ENDSELECT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_LAST_DATE  text
*----------------------------------------------------------------------*
FORM GET_LAST_DATE  CHANGING $LAST_DATE.

  CONCATENATE P_GJAHR P_MONAT '01' INTO $LAST_DATE.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'    "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = $LAST_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = $LAST_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

  IF SY-SUBRC <> 0.
    CLEAR $LAST_DATE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTION .

  IF NOT P_MONAT BETWEEN 01 AND 12.
    MESSAGE E213.
*   Please specify the month between 01 and 12!
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ANALITIKA .

  DATA LW_KATA_SEL TYPE /ZAK/KATA_SEL.
  DATA LI_KATA_SUM TYPE STANDARD TABLE OF /ZAK/KATA_SELSUM INITIAL SIZE 0.
  DATA LW_KATA_SUM TYPE /ZAK/KATA_SELSUM.

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND PACK  IN R_PACK.

  IF SY-SUBRC NE 0.
    MESSAGE I141.
*   No analytic record matches the criteria!
    EXIT.
  ENDIF.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  SORT I_/ZAK/AFA_CUST BY BTYPE ABEVAZ MWSKZ KTOSL.

  LOOP AT I_/ZAK/ANALITIKA INTO DATA(LW_ANALITIKA).
    READ TABLE I_/ZAK/AFA_CUST INTO DATA(LW_KATA_CUST)
                               WITH KEY BTYPE = LW_ANALITIKA-BTYPE
                                        ABEVAZ = LW_ANALITIKA-ABEVAZ
                                        MWSKZ = LW_ANALITIKA-MWSKZ
                                        KTOSL = LW_ANALITIKA-KTOSL
                                        BINARY SEARCH.

*   Even without an operation sequence
    IF SY-SUBRC NE 0.
      READ TABLE I_/ZAK/AFA_CUST INTO LW_KATA_CUST
                                WITH KEY BTYPE = LW_ANALITIKA-BTYPE
                                         ABEVAZ = LW_ANALITIKA-ABEVAZ
                                         MWSKZ = LW_ANALITIKA-MWSKZ
                                         KTOSL = ''
                                         BINARY SEARCH.
    ENDIF.
*   We select only the base amount
    CHECK SY-SUBRC EQ 0 AND LW_KATA_CUST-ATYPE EQ C_ATYPE_A.
    CLEAR LW_KATA_SEL.
    MOVE-CORRESPONDING LW_ANALITIKA TO LW_KATA_SEL.
    IF LW_KATA_SEL-BUDAT IS INITIAL.
      IF P_TEST IS INITIAL.
        MESSAGE E282 WITH LW_KATA_SEL-BUKRS LW_KATA_SEL-BSEG_GJAHR LW_KATA_SEL-BSEG_BELNR.
*       Unable to determine processing period! & & & &
      ELSE.
        MESSAGE I282 WITH LW_KATA_SEL-BUKRS LW_KATA_SEL-BSEG_GJAHR LW_KATA_SEL-BSEG_BELNR DISPLAY LIKE 'W'.
*       Unable to determine processing period! & & & &
      ENDIF.
    ENDIF.
*   Build the PERIOD from BUDAT
    LW_KATA_SEL-GJAHR = LW_KATA_SEL-BUDAT(4).
    LW_KATA_SEL-MONAT = LW_KATA_SEL-BUDAT+4(2).
*   The tax number comes from STCD1
    IF LW_ANALITIKA-STCD1 IS INITIAL.
*     MESSAGE E316 WITH LW_KATA_SEL-BUKRS LW_KATA_SEL-BSEG_GJAHR LW_KATA_SEL-BSEG_BELNR.
*     Tax number empty & & & &!
      PERFORM MESSAGE_STORE USING '/ZAK/ZAK'
                                  'E'
                                  '316'
                                  LW_KATA_SEL-BUKRS
                                  LW_KATA_SEL-BSEG_GJAHR
                                  LW_KATA_SEL-BSEG_BELNR
                                  SPACE.
    ELSE.
      LW_KATA_SEL-ADOAZON =  LW_ANALITIKA-STCD1.
    ENDIF.
    APPEND LW_KATA_SEL TO I_/ZAK/KATA_SEL.
    MOVE-CORRESPONDING LW_KATA_SEL TO LW_KATA_SUM.
    COLLECT LW_KATA_SUM INTO LI_KATA_SUM.
  ENDLOOP.

  LOOP AT LI_KATA_SUM INTO LW_KATA_SUM.
*   Check address data
    SELECT SINGLE COUNT( * ) FROM /ZAK/MGCIM
                            WHERE ADOAZON EQ LW_KATA_SUM-ADOAZON.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_STORE USING '/ZAK/ZAK'
                                  'E'
                                  '258'
                                  LW_KATA_SUM-ADOAZON
                                  SPACE
                                  SPACE
                                  SPACE.
    ENDIF.
  ENDLOOP.

  IF NOT V_MESSAGE IS INITIAL AND NOT P_TEST IS INITIAL.
    MESSAGE I317 DISPLAY LIKE 'W'.
*   Messages occurred during processing!
    PERFORM MESSAGE_SHOW.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_KATA_CUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_KATA_CUST  USING $SUBRC.

  CLEAR $SUBRC.
  SELECT * INTO TABLE I_/ZAK/AFA_CUST
           FROM /ZAK/AFA_CUST
          WHERE KATA EQ 'X'.                            "#EC CI_NOWHERE
  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TESZT  text
*----------------------------------------------------------------------*
FORM INS_DATA  USING   $TEST.

  CHECK $TEST IS INITIAL.
  IF NOT V_MESSAGE_ERR IS INITIAL.
    MESSAGE I262 DISPLAY LIKE 'E'.
*   Productive run cannot start due to errors!
    PERFORM MESSAGE_SHOW.
    EXIT.
  ENDIF.
* Data
  MODIFY /ZAK/KATA_SEL FROM TABLE I_/ZAK/KATA_SEL.
* Package
  UPDATE /ZAK/BEVALLP SET KATA = 'X'
               WHERE PACK IN R_PACK.
  COMMIT WORK AND WAIT.
  IF SY-SUBRC EQ 0.
    MESSAGE S216.
*   Data changes saved!
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .
  CALL SCREEN 9000.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  DATA FCODE TYPE TABLE OF SY-UCOMM.

  IF V_MESSAGE IS INITIAL.
    APPEND 'SHOWMESS' TO FCODE.
  ENDIF.

  SET PF-STATUS '9000' EXCLUDING FCODE.
  IF P_TEST IS INITIAL.
    SET TITLEBAR '9000'.
  ELSE.
    SET TITLEBAR '9000T'.
  ENDIF.

  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_/ZAK/KATA_SEL[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.

ENDMODULE.

*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING $I_TAB LIKE   I_/ZAK/KATA_SEL[]
                                  $FIELDCAT TYPE LVC_T_FCAT
                                  $LAYOUT   TYPE LVC_S_LAYO
                                  $VARIANT  TYPE DISVARIANT.

  DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER.

* Building the field catalog
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING $FIELDCAT.

* Excluding functions
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

  $LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
  $LAYOUT-SEL_MODE = 'A'.


  CLEAR $VARIANT.
  $VARIANT-REPORT = V_REPID.


  CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = $VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = 'X'
      IS_LAYOUT            = $LAYOUT
      IT_TOOLBAR_EXCLUDING = LI_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = $FIELDCAT
      IT_OUTTAB            = $I_TAB.

*   CREATE OBJECT v_event_receiver.
*   SET HANDLER v_event_receiver->handle_toolbar       FOR v_grid.
*   SET HANDLER v_event_receiver->handle_double_click  FOR v_grid.
*   SET HANDLER v_event_receiver->handle_user_command  FOR v_grid.
*
** raise event TOOLBAR:
*   CALL METHOD v_grid->set_toolbar_interactive.

ENDFORM.                    " create_and_init_alv
*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT USING    $DYNNR    LIKE SYST-DYNNR
                    CHANGING $FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.


  IF $DYNNR = '9000'.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = '/ZAK/KATA_SEL'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = $FIELDCAT.

    LOOP AT $FIELDCAT INTO S_FCAT.
      IF  S_FCAT-FIELDNAME = 'POSID'  OR
          S_FCAT-FIELDNAME = 'NONEED'    OR
          S_FCAT-FIELDNAME = 'PROCESS'.
        S_FCAT-NO_OUT = 'X'.
        MODIFY $FIELDCAT FROM S_FCAT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " build_fieldcat
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.
* Exit
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      PERFORM EXIT_PROGRAM USING P_TEST.
    WHEN 'SHOWMESS'.
      PERFORM MESSAGE_SHOW.
    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM USING $TESZT.
  IF $TESZT IS INITIAL.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_STORE
*&---------------------------------------------------------------------*
*       Passing the message to the message collector
*----------------------------------------------------------------------*
*      -->$MSGID     text
*      -->$MSGTY     text
*      -->$MSGNO     text
*      -->$MSGV1     text
*      -->$MSGV2     text
*      -->$MSGV3     text
*      -->$MSGV4     text
*----------------------------------------------------------------------*
FORM MESSAGE_STORE USING    $MSGID
                            $MSGTY
                            $MSGNO
                            $MSGV1
                            $MSGV2
                            $MSGV3
                            $MSGV4.

  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      ARBGB                  = $MSGID
      MSGTY                  = $MSGTY
      MSGV1                  = $MSGV1
      MSGV2                  = $MSGV2
      MSGV3                  = $MSGV3
      MSGV4                  = $MSGV4
      TXTNR                  = $MSGNO
    EXCEPTIONS
      MESSAGE_TYPE_NOT_VALID = 01
      NOT_ACTIVE             = 02.

  IF V_MESSAGE IS INITIAL.
    MOVE 'X' TO V_MESSAGE.
  ENDIF.
  IF $MSGTY CA 'AEX' AND V_MESSAGE_ERR IS INITIAL.
    MOVE 'X' TO V_MESSAGE_ERR.
  ENDIF.

ENDFORM.                               " MESSAGE_STORE
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_SHOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MESSAGE_SHOW .

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      I_USE_GRID = 'X'.

ENDFORM.
