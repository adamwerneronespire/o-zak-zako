*&---------------------------------------------------------------------*
*& Program: Tax current account - item entry and transfer summary
*&---------------------------------------------------------------------*
REPORT /ZAK/ADON_BOOK  MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Tax current account - item entry and transfer summary program
*&
*&---------------------------------------------------------------------*
*& Author            : Cserhegyi Timea - FMC
*& Created on        : 2006.02.22
*& Functional spec by: ________
*& SAP module        : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (write the OSS note number at the end of each modified line)*
*&
*& LOG#     DATE        CHANGED BY           DESCRIPTION        TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2006/05/27   Cserhegyi T.  Replace CL_GUI_FRONTEND_SERVICES
*&                                   with the classic upload.
*& 0002   2006/09/22   Balazs G.     Grouping must be driven by BTYPART
*&                                   instead of BTYPE.
*& 0003   2007/07/23   Balazs G.     For VAT also consider the AFAO types.
*&
*& 0004   2009/01/14   Balazs G.     Map company segments.
*& 0005   2010/04/20   Balazs G.     Extend the note with the cash-desk flag.
*&---------------------------------------------------------------------*

*++S4HANA#01.
DATA: L_SUBRC TYPE SY-SUBRC.
*--S4HANA#01.
INCLUDE /ZAK/COMMON_STRUCT.

CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.


*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
*++0004 2008.01.14 BG
CONSTANTS C_SEGM_SEP VALUE '#'.
*--0004 2008.01.14 BG

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Types               -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*


DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/ADONSZA_ALV INITIAL SIZE 0,
      W_OUTTAB TYPE /ZAK/ADONSZA_ALV.

* File data structure
*++ FI 20070118
*TYPES: T_FILE TYPE /ZAK/ADONSZA_OUT.
TYPES: T_FILE TYPE /ZAK/ADONSZOUTN.
*-- FI 20070118
DATA: I_FILE TYPE STANDARD TABLE OF T_FILE INITIAL SIZE 0,
      W_FILE TYPE T_FILE.


* ALV control variables
DATA: V_OK_CODE          LIKE SY-UCOMM,
      V_SAVE_OK          LIKE SY-UCOMM,
      V_REPID            LIKE SY-REPID,
      V_CONTAINER        TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_GRID             TYPE REF TO CL_GUI_ALV_GRID,
      V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT         TYPE LVC_T_FCAT,
      V_LAYOUT           TYPE LVC_S_LAYO,
      V_VARIANT          TYPE DISVARIANT,
      V_TOOLBAR          TYPE STB_BUTTON,
      V_EVENT_RECEIVER   TYPE REF TO LCL_EVENT_RECEIVER.


*++BG 2006/06/23
DATA V_MODIFY_INDEX  LIKE SY-TABIX.
*--BG 2006/06/23

*++BG 2006/07/19
*Create a range to collect the BTYPE values of the selected documents
RANGES R_BTYPE FOR /ZAK/ADONSZA-BTYPE.

*Macro definition for filling the range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.
*--BG 2006/07/19
*++0004 2008.01.14 BG
DATA V_SEGMENT TYPE FB_SEGMENT.
*--0004 2008.01.14 BG

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

SELECTION-SCREEN: END OF BLOCK BL01.


****************************************************************
* LOCAL CLASSES: Definition
****************************************************************
*===============================================================
* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition:
* ~~~~~~~~~~~
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.

    METHODS:

      HANDLE_DOUBLE_CLICK
        FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW
                  E_COLUMN
                  ES_ROW_NO.

*      handle_hotspot_click
*         FOR EVENT hotspot_click OF cl_gui_alv_grid
*             IMPORTING e_row_id
*                       e_column_id
*                       es_row_no,


  PRIVATE SECTION.
    DATA: ERROR_IN_DATA TYPE C.
ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*
* lcl_event_receiver (Definition)
*===============================================================

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class lcl_event_receiver (Implementation)
*
*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

*---------------------------------------------------------------------*
*       METHOD double_click                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
  METHOD HANDLE_DOUBLE_CLICK.
*     PERFORM d9000_event_double_click USING e_row
*                                            e_column.
  ENDMETHOD.     "double_click


*---------------------------------------------------------------------*
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*   METHOD handle_hotspot_click.

*     if sy-dynnr = '9000'.
*       PERFORM d9001_event_hotspot_click USING e_row_id
*                                               e_column_id.

*     endif.
*   ENDMETHOD.                    "hotspot_click



  "handle_user_command
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
  V_REPID = SY-REPID.
  PERFORM READ_ADDITIONALS.
*++1765 #19.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You are not authorized to run the program!
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

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM READ_DATA.
*++0004 2008.01.14 BG
* Assign the company segment
  CALL FUNCTION '/ZAK/GET_SEGM_FOR_BUKRS'
    EXPORTING
      I_BUKRS   = P_BUKRS
    IMPORTING
      E_SEGMENT = V_SEGMENT.
*--0004 2008.01.14 BG
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM LIST_DISPLAY.


*&---------------------------------------------------------------------*
*&      Form  read_additionals
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS.
* Company description
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.
  ENDIF.
ENDFORM.                    " read_additionals
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
*&      Form  read_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_DATA.

*++S4HANA#01.
*  REFRESH I_/ZAK/ADONSZA.
*  REFRESH I_OUTTAB.
  CLEAR I_/ZAK/ADONSZA[].
  CLEAR I_OUTTAB[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/ADONSZA
    FROM /ZAK/ADONSZA
    WHERE BUKRS = P_BUKRS AND
          KOTEL = 'K'     AND
          BELNR_K = '          '.


  LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA.
    MOVE-CORRESPONDING W_/ZAK/ADONSZA TO W_OUTTAB.

*++0002 BG 2006.09.22
*   Determine the return type
    CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
      EXPORTING
        I_BUKRS       = W_/ZAK/ADONSZA-BUKRS
        I_BTYPE       = W_/ZAK/ADONSZA-BTYPE
      IMPORTING
        E_BTYPART     = W_OUTTAB-BTYPART
      EXCEPTIONS
        ERROR_IMP_PAR = 1
        OTHERS        = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
*--0002 BG 2006.09.22

*++BG 2006.12.20
*  For VAT we do not distinguish self-revision:
    IF W_OUTTAB-BTYPART(3) EQ C_BTYPART_AFA.
      W_OUTTAB-BTYPART = C_BTYPART_AFA.
    ENDIF.
*--BG 2006.12.20

* Tax type description
    SELECT SINGLE ADONEM_TXT INTO W_OUTTAB-ADONEM_TXT FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = W_OUTTAB-BUKRS
           AND    ADONEM  = W_OUTTAB-ADONEM.


    COLLECT W_OUTTAB INTO I_OUTTAB.
  ENDLOOP.

ENDFORM.                    " read_data
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
*&      Module  PBO_9000  OUTPUT
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

ENDMODULE.                 " PBO_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_STATUS.
  TYPES: BEGIN OF TAB_TYPE,
           FCODE LIKE RSMPE-FUNC,
         END OF TAB_TYPE.

  DATA: TAB    TYPE STANDARD TABLE OF TAB_TYPE WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
        WA_TAB TYPE TAB_TYPE.

  IF SY-DYNNR = '9000'.
    SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
    SET TITLEBAR 'MAIN9000'.

  ELSEIF SY-DYNNR = '9001'.
    SET PF-STATUS 'MAIN9001' EXCLUDING TAB.
    SET TITLEBAR 'MAIN9001'.

  ELSEIF SY-DYNNR = '9002'.
    SET PF-STATUS 'MAIN9002' EXCLUDING TAB.
    SET TITLEBAR 'MAIN9002'.
  ENDIF.

ENDFORM.                    " set_status
*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
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

* Build field catalog
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING PT_FIELDCAT.

* Excluding functions
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

  PS_LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
  PS_LAYOUT-SEL_MODE = 'A'.


  CLEAR PS_VARIANT.
  PS_VARIANT-REPORT = V_REPID.


  CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = PS_VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = 'X'
      IS_LAYOUT            = PS_LAYOUT
      IT_TOOLBAR_EXCLUDING = I_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = PT_FIELDCAT
      IT_OUTTAB            = PT_OUTTAB.

  CREATE OBJECT V_EVENT_RECEIVER.
  SET HANDLER V_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK  FOR V_GRID.

ENDFORM.                    " create_and_init_alv
*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT USING    P_DYNNR     LIKE SYST-DYNNR
                    CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA LW_FIELDCAT TYPE LVC_S_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/ADONSZA_ALV'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = PT_FIELDCAT.

*++BG 2006/06/23
*Set the checkbox on field ZLOCK
  LOOP AT PT_FIELDCAT INTO LW_FIELDCAT.
    IF LW_FIELDCAT-FIELDNAME = 'ZLOCK'.
      LW_FIELDCAT-CHECKBOX  = 'X'.
    ENDIF.
    MODIFY PT_FIELDCAT FROM LW_FIELDCAT.
  ENDLOOP.
*--BG 2006/06/23

ENDFORM.                    " build_fieldcat
*&---------------------------------------------------------------------*
*&      Module  PAI_9000  INPUT
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

* Manual entry
    WHEN '/ZAK/ZAK_MAN'.
      CLEAR /ZAK/ADONSZA.
      CALL SCREEN 9001.

* Generate transfer summary
    WHEN '/ZAK/ZAK_TXT'.

      PERFORM PROCESS_SELECTED_LINES.

*++BG 2006/06/23
    WHEN '/ZAK/ZAK_MOD'.

      PERFORM MODIFY_SELECTED_LINES.
*--BG 2006/06/23

* Vissza
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

* Exit
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
*&      Module  pbo_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_9001 OUTPUT.
  PERFORM SET_STATUS.
  PERFORM INIT_FIELDS.
ENDMODULE.                 " pbo_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pai_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_9001 INPUT.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.

* Manual entry
    WHEN 'SAVE'.
      PERFORM GET_NUMBER_NEXT USING '01'
                                    /ZAK/ADONSZA-BUKRS
                                    /ZAK/ADONSZA-GJAHR
                              CHANGING /ZAK/ADONSZA-BELNR.

      IF NOT /ZAK/ADONSZA-BELNR IS INITIAL.

        INSERT /ZAK/ADONSZA.
        IF SY-SUBRC = 0.
          COMMIT WORK.
*++BG 2006/06/23
*          MOVE-CORRESPONDING /ZAK/ADONSZA TO W_OUTTAB.
*          MOVE /ZAK/ADONEMT-ADONEM_TXT TO W_OUTTAB-ADONEM_TXT.
*          CHECK /ZAK/ADONSZA-KOTEL = 'K'.
*          COLLECT W_OUTTAB INTO I_OUTTAB.
          IF /ZAK/ADONSZA-KOTEL = 'K'.
            MOVE-CORRESPONDING /ZAK/ADONSZA TO W_OUTTAB.
*++BG 2012.06.27
            CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
              EXPORTING
                I_BUKRS   = /ZAK/ADONSZA-BUKRS
                I_BTYPE   = /ZAK/ADONSZA-BTYPE
              IMPORTING
                E_BTYPART = W_OUTTAB-BTYPART.
*--BG 2012.06.27
            MOVE /ZAK/ADONEMT-ADONEM_TXT TO W_OUTTAB-ADONEM_TXT.
            COLLECT W_OUTTAB INTO I_OUTTAB.
          ENDIF.

          MESSAGE I094(/ZAK/ZAK) WITH /ZAK/ADONSZA-BUKRS
                                 /ZAK/ADONSZA-GJAHR
                                 /ZAK/ADONSZA-BELNR.

          CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.

          SET SCREEN 0.
          LEAVE SCREEN.
        ELSE.
          MESSAGE A188 WITH SY-SUBRC.
*       Error while saving the item! (/ZAK/ADONSZA error code: &)
*--BG 2006/06/23
        ENDIF.
      ENDIF.
* Vissza
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
*     do nothing
  ENDCASE.


ENDMODULE.                 " pai_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  init_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_FIELDS.

  /ZAK/ADONSZA-BUKRS = P_BUKRS.
  /ZAK/ADONSZA-BELNR = '$000000001'.

  IF /ZAK/ADONSZA-BUDAT IS INITIAL.
    /ZAK/ADONSZA-BUDAT = SY-DATUM.
  ENDIF.

  IF NOT /ZAK/ADONSZA-BUDAT IS INITIAL.
    /ZAK/ADONSZA-GJAHR = /ZAK/ADONSZA-BUDAT+0(4).
  ENDIF.

  /ZAK/ADONSZA-BSZNUM = '999'.
*++S4HANA#01.
*  SELECT SINGLE SZTEXT INTO /ZAK/BEVALLDT-SZTEXT
*     FROM /ZAK/BEVALLDT
*     WHERE LANGU = SY-LANGU
*       AND BUKRS = /ZAK/ADONSZA-BUKRS
*       AND BSZNUM = /ZAK/ADONSZA-BSZNUM.
  SELECT SZTEXT INTO /ZAK/BEVALLDT-SZTEXT
   FROM /ZAK/BEVALLDT UP TO 1 ROWS
   WHERE LANGU = SY-LANGU
     AND BUKRS = /ZAK/ADONSZA-BUKRS
     AND BSZNUM = /ZAK/ADONSZA-BSZNUM
   ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.


  /ZAK/ADONSZA-WAERS = 'HUF'.

  /ZAK/ADONSZA-DATUM = SY-DATUM.
  /ZAK/ADONSZA-UZEIT = SY-UZEIT.
  /ZAK/ADONSZA-UNAME = SY-UNAME.
ENDFORM.                    " init_fields
*&---------------------------------------------------------------------*
*&      Module  exit_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_9001 INPUT.
  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.

* Exit
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.

    WHEN OTHERS.
*     do nothing
  ENDCASE.



ENDMODULE.                 " exit_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_budat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BUDAT.
  IF /ZAK/ADONSZA-BUDAT IS INITIAL.
    MESSAGE E087(/ZAK/ZAK).
  ELSE.
    /ZAK/ADONSZA-GJAHR = /ZAK/ADONSZA-BUDAT+0(4).
  ENDIF.


ENDFORM.                    " check_budat
*&---------------------------------------------------------------------*
*&      Form  check_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BTYPE.
  IF /ZAK/ADONSZA-BTYPE IS INITIAL.
    MESSAGE E184(/ZAK/ZAK).
  ELSE.
*++S4HANA#01.
*    SELECT SINGLE * INTO W_/ZAK/BEVALL FROM  /ZAK/BEVALL
*           WHERE  BUKRS   = /ZAK/ADONSZA-BUKRS
*           AND    BTYPE   = /ZAK/ADONSZA-BTYPE
*           AND    DATBI  >= /ZAK/ADONSZA-BUDAT
*           AND    DATAB  <= /ZAK/ADONSZA-BUDAT.
    SELECT SINGLE @SPACE FROM  /ZAK/BEVALL
       WHERE  BUKRS   = @/ZAK/ADONSZA-BUKRS
       AND    BTYPE   = @/ZAK/ADONSZA-BTYPE
       AND    DATBI  >= @/ZAK/ADONSZA-BUDAT
       AND    DATAB  <= @/ZAK/ADONSZA-BUDAT INTO @W_/ZAK/BEVALL.
*--S4HANA#01.
    IF SY-SUBRC <> 0.
      MESSAGE E185(/ZAK/ZAK) WITH /ZAK/ADONSZA-BTYPE /ZAK/ADONSZA-BUDAT.
    ENDIF.

*++S4HANA#01.
*    SELECT SINGLE BTEXT INTO /ZAK/BEVALLT-BTEXT
*       FROM  /ZAK/BEVALLT
*           WHERE  LANGU   = SY-LANGU
*           AND    BUKRS   = /ZAK/ADONSZA-BUKRS
*           AND    BTYPE   = /ZAK/ADONSZA-BTYPE.
    SELECT BTEXT INTO /ZAK/BEVALLT-BTEXT
       FROM  /ZAK/BEVALLT UP TO 1 ROWS
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = /ZAK/ADONSZA-BUKRS
           AND    BTYPE   = /ZAK/ADONSZA-BTYPE
           ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.

  ENDIF.
ENDFORM.                    " check_btype

*&---------------------------------------------------------------------*
*&      Form  check_adonem
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ADONEM.
  IF /ZAK/ADONSZA-ADONEM IS INITIAL.
    MESSAGE E088(/ZAK/ZAK).
  ELSE.
    SELECT SINGLE * INTO W_/ZAK/ADONEM FROM  /ZAK/ADONEM
           WHERE  BUKRS   = /ZAK/ADONSZA-BUKRS
           AND    ADONEM  = /ZAK/ADONSZA-ADONEM.
    IF SY-SUBRC <> 0.
      MESSAGE E090(/ZAK/ZAK) WITH /ZAK/ADONSZA-BUKRS /ZAK/ADONSZA-ADONEM.
    ENDIF.

    SELECT SINGLE ADONEM_TXT INTO /ZAK/ADONEMT-ADONEM_TXT
       FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = /ZAK/ADONSZA-BUKRS
           AND    ADONEM  = /ZAK/ADONSZA-ADONEM.

  ENDIF.
ENDFORM.                    " check_adonem
*&---------------------------------------------------------------------*
*&      Module  check_budat  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BUDAT INPUT.
  PERFORM CHECK_BUDAT.
ENDMODULE.                 " check_budat  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_btype  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BTYPE INPUT.
  PERFORM CHECK_BTYPE.
ENDMODULE.                 " check_btype  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_adonem  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ADONEM INPUT.
  PERFORM CHECK_ADONEM.
ENDMODULE.                 " check_adonem  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_esdat  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_ESDAT INPUT.
  PERFORM CHECK_ESDAT.
ENDMODULE.                 " check_esdat  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_esdat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ESDAT.
  IF /ZAK/ADONSZA-ESDAT IS INITIAL.
    MESSAGE E091(/ZAK/ZAK).
  ENDIF.
ENDFORM.                    " check_esdat
*&---------------------------------------------------------------------*
*&      Module  check_wrbtr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_WRBTR INPUT.
  PERFORM CHECK_WRBTR.
ENDMODULE.                 " check_wrbtr  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_wrbtr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_WRBTR.
  IF /ZAK/ADONSZA-WRBTR IS INITIAL.
    MESSAGE E092(/ZAK/ZAK).
  ENDIF.
ENDFORM.                    " check_wrbtr
*&---------------------------------------------------------------------*
*&      Form  get_number_next
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0565   text
*      -->P_/ZAK/ADONSZA_BUKRS  text
*      -->P_/ZAK/ADONSZA_GJAHR  text
*      <--P_/ZAK/ADONSZA_BELNR  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_NUMBER_NEXT USING    $01
*                              $BUKRS
*                              $GJAHR
*                     CHANGING $BELNR.
FORM GET_NUMBER_NEXT USING    $01 TYPE CLIKE
                              $BUKRS TYPE /ZAK/ADONSZA-BUKRS
                              $GJAHR TYPE /ZAK/ADONSZA-GJAHR
                     CHANGING $BELNR TYPE /ZAK/ADONSZA-BELNR.
*--S4HANA#01.
  DATA: L_NR LIKE INRI-NRRANGENR.

  L_NR = $01.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = L_NR
      OBJECT                  = '/ZAK/BELNR'
      QUANTITY                = '1'
      SUBOBJECT               = $BUKRS
      TOYEAR                  = $GJAHR
      IGNORE_BUFFER           = 'X'
    IMPORTING
      NUMBER                  = $BELNR
*     QUANTITY                =
*     RETURNCODE              =
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " get_number_next
*&---------------------------------------------------------------------*
*&      Module  modify_wrbtr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_WRBTR INPUT.

ENDMODULE.                 " modify_wrbtr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_kotel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_KOTEL INPUT.
  PERFORM CHECK_KOTEL.
ENDMODULE.                 " check_kotel  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_kotel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_KOTEL.
  IF /ZAK/ADONSZA-KOTEL IS INITIAL.
    MESSAGE E093(/ZAK/ZAK).
  ELSE.
    IF /ZAK/ADONSZA-KOTEL = 'K'.
      IF /ZAK/ADONSZA-WRBTR > 0.
*        /zak/adonsza-wrbtr = /zak/adonsza-wrbtr * ( -1 ).
        MESSAGE W103(/ZAK/ZAK).
      ENDIF.
    ELSE.
      IF /ZAK/ADONSZA-WRBTR < 0.
*        /zak/adonsza-wrbtr = /zak/adonsza-wrbtr * ( -1 ).
        MESSAGE W104(/ZAK/ZAK).
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_kotel
*&---------------------------------------------------------------------*
*&      Form  process_selected_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_SELECTED_LINES.

  DATA: I_ROWS TYPE LVC_T_ROW,
        W_ROWS TYPE LVC_S_ROW,
        S_OUT  TYPE /ZAK/ADONSZA_ALV.

  DATA: I_FILE_MAIN      TYPE TABLE OF /ZAK/ADONSZAFILE.
  DATA: W_FILE_MAIN      TYPE /ZAK/ADONSZAFILE.

*++S4HANA#01.
*  DATA: BEGIN OF I_DONE OCCURS 0,
*          BUKRS TYPE BUKRS,
*          ESDAT TYPE DATUM,
*        END OF I_DONE.
  TYPES: BEGIN OF TS_I_DONE ,
           BUKRS TYPE BUKRS,
           ESDAT TYPE DATUM,
         END OF TS_I_DONE .
  TYPES TT_I_DONE TYPE STANDARD TABLE OF TS_I_DONE .
  DATA: LS_I_DONE TYPE TS_I_DONE.
  DATA: LT_I_DONE TYPE TT_I_DONE.
*--S4HANA#01.

  DATA: V_BELNR_K LIKE /ZAK/ADONSZA-BELNR_K.
*++1565 #06.
  DATA: V_GJAHR_K LIKE /ZAK/ADONSZA-GJAHR_K.
*--1565 #06.
*++0002 BG 2006.09.22
  DATA LT_BTYPES TYPE /ZAK/T_BTYPE.
  DATA LW_BTYPES TYPE /ZAK/BTYPE.
*--0002 BG 2006.09.22
*++0004 2008.01.14 BG
  DATA L_SEGM(3).
  DATA L_LENGTH TYPE I.
*--0004 2008.01.14 BG

*++0003 BG 2007.07.23
  DEFINE LM_GET_BTYPE.
    REFRESH LT_BTYPES.
    CLEAR   LT_BTYPES.
*   Determine the types for the document category
    CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART_M'
      EXPORTING
        I_BUKRS           = &1
        I_BTYPART         = &2
*         I_GJAHR           =
*         I_MONAT           =
*       IMPORTING
*         E_BTYPE           =
      TABLES
        T_BTYPES          = LT_BTYPES
      EXCEPTIONS
        ERROR_MONAT       = 1
        ERROR_BTYPE       = 2
        OTHERS            = 3
              .
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      LOOP AT LT_BTYPES INTO LW_BTYPES.
        M_DEF R_BTYPE 'I' 'EQ' LW_BTYPES SPACE.
      ENDLOOP.
    ENDIF.
  END-OF-DEFINITION.
*--0003 BG 2007.07.23


  CLEAR W_FILE.
*++S4HANA#01.
*  REFRESH I_FILE.
  CLEAR I_FILE[].
*--S4HANA#01.

  CALL METHOD V_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = I_ROWS.

*++BG 2006/07/19
* Collect the BTYPE values that were selected
* because otherwise only the tax type and the due
* date would determine the reference, which was not correct
*--S4HANA#01.
*  REFRESH R_BTYPE.
  CLEAR R_BTYPE[].
*--S4HANA#01.
  CLEAR   R_BTYPE.
*--BG 2006/07/19

  LOOP AT I_ROWS INTO W_ROWS.
    READ TABLE I_OUTTAB INTO S_OUT INDEX W_ROWS-INDEX.
    IF SY-SUBRC = 0.
*++BG 2006/06/20
      IF S_OUT-WRBTR < 0 OR NOT S_OUT-ZLOCK IS INITIAL.
        MESSAGE E183.
      ENDIF.
*--BG 2006/06/20
      CLEAR W_FILE_MAIN.
      MOVE-CORRESPONDING S_OUT TO W_FILE_MAIN.
      APPEND W_FILE_MAIN TO I_FILE_MAIN.
*++0003 BG 2007.07.23
*++0002 BG 2006.09.22
*++BG 2006/07/19
*     M_DEF R_BTYPE 'I' 'EQ' S_OUT-BTYPE SPACE.

      LM_GET_BTYPE S_OUT-BUKRS S_OUT-BTYPART.
*     For VAT types the self-revision is also required:
      IF S_OUT-BTYPART EQ C_BTYPART_AFA.
        LM_GET_BTYPE S_OUT-BUKRS C_BTYPART_AFAO.
      ENDIF.
*--BG 2006/07/19
*--0002 BG 2006.09.22
*--0003 BG 2007.07.23
    ELSE.
      M_DEF R_BTYPE 'I' 'EQ' SPACE SPACE.
    ENDIF.
  ENDLOOP.

*++0002 BG 2006.09.22
* Sort the RANGE
  SORT R_BTYPE.
  DELETE ADJACENT DUPLICATES FROM R_BTYPE.
*--0002 BG 2006.09.22

* Create file
  DATA: L_COUNTER TYPE I.


  LOOP AT I_FILE_MAIN INTO W_FILE_MAIN.


*++0005 2010.04.20 Balazs Gabor (Ness)
    CLEAR: W_/ZAK/ADONEM, W_/ZAK/ADONEMT.
*--0005 2010.04.20 Balazs Gabor (Ness)

    SELECT SINGLE * INTO W_/ZAK/ADONEM FROM /ZAK/ADONEM
      WHERE BUKRS  = W_FILE_MAIN-BUKRS
        AND ADONEM = W_FILE_MAIN-ADONEM.
*++0005 2010.04.20 Balazs Gabor (Ness)
*   Tax type description
    SELECT SINGLE * INTO W_/ZAK/ADONEMT FROM /ZAK/ADONEMT
      WHERE LANGU  = SY-LANGU
        AND BUKRS  = W_FILE_MAIN-BUKRS
        AND ADONEM = W_FILE_MAIN-ADONEM.
*--0005 2010.04.20 Balazs Gabor (Ness)

    AT NEW ADONEM.
      L_COUNTER = L_COUNTER + 1.
    ENDAT.
** File
*++ FI 20070118
*    W_FILE-SORSZAM    = L_COUNTER.
*    W_FILE-ADONEM_TXT = W_FILE_MAIN-ADONEM_TXT.
*-- FI 20070118


    W_FILE-LIFNR      = W_/ZAK/ADONEM-LIFNR.
    CONCATENATE W_/ZAK/ADONEM-BANKL W_/ZAK/ADONEM-BANKN
      INTO W_FILE-BANKSZAMLA SEPARATED BY '-'.
*++ FI 20070118
*++ FI 20070212
    CLEAR :W_FILE-NAME1.
    IF W_/ZAK/ADONEM-LIFNR IS NOT INITIAL.
*-- FI 20070212
*++0005 2010.04.20 Balazs Gabor (Ness)
*     Populate leading zeros:
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = W_/ZAK/ADONEM-LIFNR
        IMPORTING
          OUTPUT = W_/ZAK/ADONEM-LIFNR.
*--0005 2010.04.20 Balazs Gabor (Ness)

      SELECT SINGLE NAME1 FROM LFA1
                          INTO W_FILE-NAME1
                          WHERE LIFNR = W_/ZAK/ADONEM-LIFNR.
    ENDIF. "  FI 20070212
*-- FI 20070118

    IF W_FILE_MAIN-WRBTR < 0.
      W_FILE_MAIN-WRBTR =  W_FILE_MAIN-WRBTR * ( -1 ).
    ENDIF.

    WRITE  W_FILE_MAIN-WRBTR TO W_FILE-OSSZEG
         CURRENCY W_FILE_MAIN-WAERS
         NO-GROUPING.

    W_FILE-SAKNR      = W_/ZAK/ADONEM-SAKNR.

    SELECT SINGLE PAVAL INTO W_FILE-KOZLEMENY
       FROM T001Z
       WHERE BUKRS = W_FILE_MAIN-BUKRS
         AND PARTY = 'YHRASZ'.

*++0005 2010.04.20 Balazs Gabor (Ness)
    CONCATENATE W_FILE-KOZLEMENY
                W_/ZAK/ADONEMT-ADONEM_TXT
                INTO W_FILE-KOZLEMENY
                SEPARATED BY SPACE.
*--0005 2010.04.20 Balazs Gabor (Ness)

*++ FI 20070118
*    W_FILE-GJAHR      = W_FILE_MAIN-ESDAT+0(4).
*-- FI 20070118




*++0004 2008.01.14 BG "Deleted on: 2009.04.02"
*                               at the request of Ilona Kis
**  If a segment exists then append it to the note.
*    IF NOT V_SEGMENT IS INITIAL.
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*        EXPORTING
*          INPUT  = V_SEGMENT
*        IMPORTING
*          OUTPUT = L_SEGM.
**   If it is a single character long then it still fits:
*      L_LENGTH = STRLEN( L_SEGM ).
*      IF L_LENGTH EQ 1.
*        CONCATENATE C_SEGM_SEP L_SEGM C_SEGM_SEP INTO L_SEGM.
*        CONCATENATE W_FILE-KOZLEMENY(14) L_SEGM INTO W_FILE-KOZLEMENY
*                                         SEPARATED BY SPACE.
*      ENDIF.
*    ENDIF.
*--0004 2008.01.14 BG


    APPEND  W_FILE TO I_FILE.


    AT END OF ESDAT.
      PERFORM DOWNLOAD_FILE USING   W_FILE_MAIN-BUKRS
                                    W_FILE_MAIN-ESDAT
                            CHANGING L_SUBRC.



* Download succeeded for the given BUKRS/ESDAT combination
      IF L_SUBRC = 0.
*++S4HANA#01.
*        CLEAR I_DONE.
*        I_DONE-BUKRS = W_FILE_MAIN-BUKRS.
*        I_DONE-ESDAT = W_FILE_MAIN-ESDAT.
*        APPEND I_DONE.
        CLEAR LS_I_DONE.
        LS_I_DONE-BUKRS = W_FILE_MAIN-BUKRS.
        LS_I_DONE-ESDAT = W_FILE_MAIN-ESDAT.
        APPEND LS_I_DONE TO LT_I_DONE.
*--S4HANA#01.
      ENDIF.


      CLEAR W_FILE.
*++S4HANA#01.
*      REFRESH I_FILE.
      CLEAR I_FILE[].
*--S4HANA#01.

      CLEAR L_COUNTER.

    ENDAT.

  ENDLOOP.



*++S4HANA#01.
*  LOOP AT I_DONE.
  LOOP AT LT_I_DONE INTO LS_I_DONE.
*--S4HANA#01.

    LOOP AT I_FILE_MAIN INTO W_FILE_MAIN
*++S4HANA#01.
*       WHERE BUKRS = I_DONE-BUKRS AND
*             ESDAT = I_DONE-ESDAT.
       WHERE BUKRS = LS_I_DONE-BUKRS AND
             ESDAT = LS_I_DONE-ESDAT.
*--S4HANA#01.



* Create new document
      CLEAR W_/ZAK/ADONSZA.
      W_/ZAK/ADONSZA-BUKRS  = W_FILE_MAIN-BUKRS.
      W_/ZAK/ADONSZA-ADONEM = W_FILE_MAIN-ADONEM.
      W_/ZAK/ADONSZA-BUDAT  = SY-DATUM.
      W_/ZAK/ADONSZA-GJAHR  = SY-DATUM+0(4).

      PERFORM GET_NUMBER_NEXT USING '01'
                                    W_/ZAK/ADONSZA-BUKRS
                                    W_/ZAK/ADONSZA-GJAHR
                              CHANGING W_/ZAK/ADONSZA-BELNR.

      W_/ZAK/ADONSZA-ESDAT = W_FILE_MAIN-ESDAT.
      W_/ZAK/ADONSZA-KOTEL = 'T'.
      W_/ZAK/ADONSZA-BELNR_K = W_/ZAK/ADONSZA-BELNR.

      W_/ZAK/ADONSZA-BSZNUM = '999'.

      W_/ZAK/ADONSZA-WRBTR  = W_FILE_MAIN-WRBTR * ( -1 ).
      W_/ZAK/ADONSZA-WAERS  = W_FILE_MAIN-WAERS.


      W_/ZAK/ADONSZA-DATUM = SY-DATUM.
      W_/ZAK/ADONSZA-UZEIT = SY-UZEIT.
      W_/ZAK/ADONSZA-UNAME = SY-UNAME.


      /ZAK/ADONSZA = W_/ZAK/ADONSZA.
      INSERT /ZAK/ADONSZA.
      IF SY-SUBRC = 0.
        COMMIT WORK.

        V_BELNR_K = W_/ZAK/ADONSZA-BELNR.
*++1565 #06.
        V_GJAHR_K = W_/ZAK/ADONSZA-GJAHR.
*--1565 #06.
        PERFORM SET_REFERENCES USING W_/ZAK/ADONSZA-BUKRS
                                     W_/ZAK/ADONSZA-ADONEM
                                     W_/ZAK/ADONSZA-ESDAT
                                     V_BELNR_K
*++1565 #06.
                                     V_GJAHR_K.
*--1565 #06.
      ELSE.
        CLEAR V_BELNR_K.
      ENDIF.
    ENDLOOP.
  ENDLOOP.


* Refresh list
  PERFORM READ_DATA.
  CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.

ENDFORM.                    " process_selected_lines
*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM DOWNLOAD_FILE USING    L_BUKRS
*                            L_ESDAT
*                   CHANGING L_SUBRC.
FORM DOWNLOAD_FILE USING    L_BUKRS TYPE /ZAK/ADONSZAFILE-BUKRS
                            L_ESDAT TYPE /ZAK/ADONSZAFILE-ESDAT
                   CHANGING L_SUBRC TYPE SY-SUBRC.

  DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
        L_CANCEL(1).

  DATA: BEGIN OF I_FIELDS OCCURS 10,
          NAME(40),
        END OF I_FIELDS.

  DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
  DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

*++0001 2007.01.03 BG (FMC)
*++ BG 2006.04.20
  DATA: L_FILENAME TYPE STRING,
        L_FILTER   TYPE STRING,
        L_PATH     TYPE STRING,
        L_FULLPATH TYPE STRING,
        L_ACTION   TYPE I.
  DATA:  L_FILENAME_DOWN LIKE RLGRAP-FILENAME.
*  DATA:  L_RC.
*-- BG 2006.04.20
*--0001 2007.01.03 BG (FMC)

*++S4HANA#01.
  DATA LV_FILENAME TYPE STRING.
  DATA LV_PATH TYPE STRING.
  DATA LV_DEFAULT_FILENAME TYPE STRING.
  DATA LV_FULLPATH TYPE STRING.
  DATA LV_USER_ACTION TYPE I.
  DATA LV_RC TYPE I.
  DATA LV_FILE_FILTER TYPE STRING.
*--S4HANA#01.

  L_SUBRC = 0.

  CONCATENATE L_BUKRS L_ESDAT INTO L_DEF_FILENAME
    SEPARATED BY '_'.
  CONCATENATE L_DEF_FILENAME '.XLS' INTO L_DEF_FILENAME.

* Read data structure
  CALL FUNCTION 'DD_GET_DD03P_ALL'
    EXPORTING
      LANGU         = SYST-LANGU
*++ FI 20070118
*     TABNAME       = '/ZAK/ADONSZA_OUT'
      TABNAME       = '/ZAK/ADONSZOUTN'
*-- FI 20070118
    TABLES
      A_DD03P_TAB   = I_DD03P
      N_DD03P_TAB   = I_DD03P_2
    EXCEPTIONS
      ILLEGAL_VALUE = 1
      OTHERS        = 2.

  IF SY-SUBRC = 0.

*++S4HANA#01.
*    LOOP AT I_DD03P.
*      I_FIELDS-NAME = I_DD03P-REPTEXT.
*      APPEND I_FIELDS.
*    ENDLOOP.
    LOOP AT I_DD03P INTO I_DD03P.
      I_FIELDS-NAME = I_DD03P-REPTEXT.
      APPEND I_FIELDS TO I_FIELDS.
    ENDLOOP.
*--S4HANA#01.

  ENDIF.

*++ BG 2006.04.20 Path determination
  MOVE L_DEF_FILENAME TO L_FILENAME.

* ++ 0001 CST 2006.05.27
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
*     WINDOW_TITLE      =
*     DEFAULT_EXTENSION = '*.*'
      DEFAULT_FILE_NAME = L_FILENAME
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    CHANGING
      FILENAME          = L_FILENAME
      PATH              = L_PATH
      FULLPATH          = L_FULLPATH
      USER_ACTION       = L_ACTION
    EXCEPTIONS
      CNTL_ERROR        = 1
      ERROR_NO_GUI      = 2
      OTHERS            = 3.

  L_SUBRC = SY-SUBRC.
  CHECK L_SUBRC = 0.

  MOVE L_FULLPATH TO L_DEF_FILENAME.
*-- BG 2006.04.20


*  DATA: L_MASK(20)   TYPE C VALUE ',*.xls  ,*.xls.'.
*
*  CALL FUNCTION 'WS_FILENAME_GET'
*       EXPORTING
*            DEF_FILENAME     = '*.xls'
*            DEF_PATH         = L_DEF_FILENAME
*            MASK             = L_MASK
*            MODE             = 'S'
*            TITLE            = SY-TITLE
*       IMPORTING
*            FILENAME         = L_FILENAME
*            RC               = L_RC
*       EXCEPTIONS
*            INV_WINSYS       = 04
*            NO_BATCH         = 08
*            SELECTION_CANCEL = 12
*            SELECTION_ERROR  = 16.
*
* -- 0001 CST 2006.05.27

  MOVE L_FILENAME TO L_FILENAME_DOWN.

*++MOL_UPG_UCCHECK Forgo Istvan (NESS) 2016.06.28
*++S4HANA#01.
**  CALL FUNCTION 'DOWNLOAD'
**       EXPORTING
**            FILENAME                = L_FILENAME_DOWN
**            FILETYPE                = 'DAT'
***           FILEMASK_ALL            = 'X'
**            FILETYPE_NO_CHANGE      = 'X'
***           FILEMASK_ALL            = ' '
**            FILETYPE_NO_SHOW        = 'X'
**       IMPORTING
**            CANCEL                  = L_CANCEL
**       TABLES
**            DATA_TAB                = I_FILE[]
**            FIELDNAMES              = I_FIELDS
**       EXCEPTIONS
**            INVALID_FILESIZE        = 1
**            INVALID_TABLE_WIDTH     = 2
**            INVALID_TYPE            = 3
**            NO_BATCH                = 4
**            UNKNOWN_ERROR           = 5
**            GUI_REFUSE_FILETRANSFER = 6
**            CUSTOMER_ERROR          = 7
**            OTHERS                  = 8.
*  DATA L_FILENAME_STRING TYPE STRING.
*
*  MOVE L_FILENAME_DOWN TO L_FILENAME_STRING.
*
*
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
*    EXPORTING
*      FILENAME                = L_FILENAME_STRING
**++1865 #18.
**     FILETYPE                = 'DAT'
*      FILETYPE                = 'DBF'
**--1865 #18.
*      FIELDNAMES              = I_FIELDS[]
*    CHANGING
*      DATA_TAB                = I_FILE[]
*    EXCEPTIONS
*      FILE_WRITE_ERROR        = 1
*      NO_BATCH                = 2
*      GUI_REFUSE_FILETRANSFER = 3
*      INVALID_TYPE            = 4
*      NO_AUTHORITY            = 5
*      UNKNOWN_ERROR           = 6
*      HEADER_NOT_ALLOWED      = 7
*      SEPARATOR_NOT_ALLOWED   = 8
*      FILESIZE_NOT_ALLOWED    = 9
*      HEADER_TOO_LONG         = 10
*      DP_ERROR_CREATE         = 11
*      DP_ERROR_SEND           = 12
*      DP_ERROR_WRITE          = 13
*      UNKNOWN_DP_ERROR        = 14
*      ACCESS_DENIED           = 15
*      DP_OUT_OF_MEMORY        = 16
*      DISK_FULL               = 17
*      DP_TIMEOUT              = 18
*      FILE_NOT_FOUND          = 19
*      DATAPROVIDER_EXCEPTION  = 20
*      CONTROL_FLUSH_ERROR     = 21
*      NOT_SUPPORTED_BY_GUI    = 22
*      ERROR_NO_GUI            = 23
*      OTHERS                  = 24.
*
*
**  IF SY-SUBRC <> 0 OR L_CANCEL = 'X' OR L_CANCEL = 'x'.
*  IF SY-SUBRC <> 0 .
  LV_DEFAULT_FILENAME = L_FILENAME_DOWN.
  CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
    EXPORTING
      FULL_NAME     = LV_DEFAULT_FILENAME
    IMPORTING
      STRIPPED_NAME = LV_FILENAME
      FILE_PATH     = LV_PATH
    EXCEPTIONS
      X_ERROR       = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      DEFAULT_FILE_NAME = LV_FILENAME
      INITIAL_DIRECTORY = LV_PATH
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
      USER_ACTION       = LV_USER_ACTION.
  CHECK LV_USER_ACTION EQ 0.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME   = LV_FULLPATH
      FILETYPE   = 'DAT'
      FIELDNAMES = I_FIELDS[]
    CHANGING
      DATA_TAB   = I_FILE[]
    EXCEPTIONS
      OTHERS     = 1.
  IF SY-SUBRC <> 0 OR L_CANCEL = 'X' OR L_CANCEL = 'x'.
*--S4HANA#01.
*--MOL_UPG_UCCHECK Forgo Istvan (NESS) 2016.06.28
    L_SUBRC = 4.
  ENDIF.

ENDFORM.                    " download_file
*&---------------------------------------------------------------------*
*&      Form  set_references
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_GJAHR  text
*      -->P_BELNR  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM SET_REFERENCES USING    P_BUKRS
*                             P_ADONEM
*                             P_ESDAT
*                             P_BELNR_K
**++1565 #06.
*                             P_GJAHR_K.
**--1565 #06.
FORM SET_REFERENCES USING    P_BUKRS TYPE /ZAK/ADONSZA-BUKRS
                             P_ADONEM TYPE /ZAK/ADONSZA-ADONEM
                             P_ESDAT TYPE /ZAK/ADONSZA-ESDAT
                             P_BELNR_K TYPE /ZAK/ADONSZA-BELNR_K
                             P_GJAHR_K TYPE /ZAK/ADONSZA-GJAHR_K.
*--S4HANA#01.
* Save reference
  SELECT * INTO TABLE I_/ZAK/ADONSZA FROM /ZAK/ADONSZA
      WHERE BUKRS  = P_BUKRS
        AND ADONEM = P_ADONEM
*++BG 2006/07/19
        AND BTYPE  IN R_BTYPE
*--BG 2006/07/19
        AND ESDAT  = P_ESDAT
        AND KOTEL  = 'K'
        AND BELNR_K = SPACE
*++BG 2007/07/23
        AND ZLOCK  NE 'X'
*--BG 2007/07/23
        .

  LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA.

    UPDATE /ZAK/ADONSZA SET BUDAT = SY-DATUM
                           BELNR_K = P_BELNR_K
*++1565 #06.
                           GJAHR_K = P_GJAHR_K
*--1565 #06.
           WHERE BUKRS = W_/ZAK/ADONSZA-BUKRS
             AND GJAHR = W_/ZAK/ADONSZA-GJAHR
             AND BELNR = W_/ZAK/ADONSZA-BELNR.

    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " set_references
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9002 OUTPUT.

  PERFORM SET_STATUS.


ENDMODULE.                 " STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_9002 INPUT.
  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.
* Exit
    WHEN 'EXIT'.

      PERFORM LEAVE_SCREEN_9002.

    WHEN OTHERS.
*     do nothing
  ENDCASE.


ENDMODULE.                 " EXIT_9002  INPUT
*&---------------------------------------------------------------------*
*&      Form  LEAVE_SCREEN_9002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LEAVE_SCREEN_9002.

*++S4HANA#01.
*  DATA L_ANSWER.
  DATA L_ANSWER TYPE C.
*--S4HANA#01.

* Determine changes
  IF W_/ZAK/ADONSZA_ALV NE /ZAK/ADONSZA_ALV.
*++MOL_UPG_ChangeImp - E09324753 - Balazs Gabor (Ness) - 2016.07.12
*++S4HANA#01.
**    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
**      EXPORTING
**        TEXTLINE1     = 'Data was not saved!'
**        TEXTLINE2     = 'Exit without saving?'
**        TITLE         = 'Data changed'
**        START_COLUMN  = 25
**        START_ROW     = 6
**        DEFAULTOPTION = 'N'
**      IMPORTING
**        ANSWER        = L_ANSWER.
*    DATA L_QUESTION TYPE STRING.
*
*    CONCATENATE 'Data was not saved!' 'Exit without saving?' INTO L_QUESTION SEPARATED BY SPACE.
**
*    CALL FUNCTION 'POPUP_TO_CONFIRM'
*      EXPORTING
*        TITLEBAR              = 'Data changed'
**       DIAGNOSE_OBJECT       = ' '
*        TEXT_QUESTION         = L_QUESTION
**       TEXT_BUTTON_1         = 'Ja'(001)
**       ICON_BUTTON_1         = ' '
**       TEXT_BUTTON_2         = 'Nein'(002)
**       ICON_BUTTON_2         = ' '
*        DEFAULT_BUTTON        = '2'
*        DISPLAY_CANCEL_BUTTON = ' '
**       USERDEFINED_F1_HELP   = ' '
*        START_COLUMN          = 25
*        START_ROW             = 6
**       POPUP_TYPE            =
**       IV_QUICKINFO_BUTTON_1 = ' '
**       IV_QUICKINFO_BUTTON_2 = ' '
*      IMPORTING
*        ANSWER                = L_ANSWER
**   TABLES
**       PARAMETER             =
**   EXCEPTIONS
**       TEXT_NOT_FOUND        = 1
**       OTHERS                = 2
*      .
*    IF L_ANSWER EQ '1'.
*      L_ANSWER = 'J'.
*    ELSE.
*      L_ANSWER = 'N'.
*    ENDIF.
    DATA: LV_W_TEXT_QUESTION_0(400) TYPE C.
    CONCATENATE
       'Adatok nem lettek elmentve!'
       'Kilép mentés nélkül?'
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
        TITLEBAR              = 'Adatok változtak'
        TEXT_QUESTION         = LV_W_TEXT_QUESTION_0
        DIAGNOSE_OBJECT       = 'CACS_CONFIRM_LOSS_OF_DATA'
        DEFAULT_BUTTON        = LV_W_DEFAULT_BUTTON_0
        DISPLAY_CANCEL_BUTTON = ' '
        START_COLUMN          = 25
        START_ROW             = 6
        POPUP_TYPE            = 'ICON_MESSAGE_WARNING'
      IMPORTING
        ANSWER                = L_ANSWER
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1.
    CASE SY-SUBRC.
      WHEN 1.
* IMPLEMENT ME
    ENDCASE.
    CASE L_ANSWER.
      WHEN '1'.
        L_ANSWER = 'J'.
      WHEN '2'.
        L_ANSWER = 'N'.
    ENDCASE.
*--S4HANA#01.
*--MOL_UPG_ChangeImp - E09324753 - Balazs Gabor (Ness) - 2016.07.12

    CHECK L_ANSWER EQ 'J'.

  ENDIF.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.                    " LEAVE_SCREEN_9002
*&---------------------------------------------------------------------*
*&      Form  modify_selected_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SELECTED_LINES.

  DATA: LI_ROWS TYPE LVC_T_ROW,
        LW_ROWS TYPE LVC_S_ROW.
  DATA  L_LINE LIKE SY-TABIX.


  CLEAR /ZAK/ADONSZA_ALV.

  CALL METHOD V_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LI_ROWS.

*++S4HANA#01.
*  DESCRIBE TABLE LI_ROWS LINES L_LINE.
  L_LINE = LINES( LI_ROWS ).
*--S4HANA#01.

  IF L_LINE IS INITIAL.
    MESSAGE I186.
*   Please select the row to be processed!
    EXIT.
  ELSEIF L_LINE NE 1.
    MESSAGE E187.
*   Please select only one row!
    EXIT.
  ENDIF.

  CLEAR V_MODIFY_INDEX.

  READ TABLE LI_ROWS INTO LW_ROWS INDEX 1.

  READ TABLE I_OUTTAB INTO /ZAK/ADONSZA_ALV INDEX LW_ROWS-INDEX.

  MOVE LW_ROWS-INDEX TO V_MODIFY_INDEX.

* Based on this we compare whether processing has happened
  MOVE /ZAK/ADONSZA_ALV  TO W_/ZAK/ADONSZA_ALV.

  CALL SCREEN 9002 STARTING AT 5  5
                   ENDING   AT 60 10.

  CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.

ENDFORM.                    " modify_selected_lines
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9002 INPUT.
  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.
* Exit
    WHEN 'EXIT'.
      PERFORM LEAVE_SCREEN_9002.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA_9002.

    WHEN OTHERS.
*     do nothing
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_9002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA_9002.

* Modify and aggregate data
  READ TABLE I_OUTTAB INTO W_OUTTAB INDEX V_MODIFY_INDEX.
  DELETE I_OUTTAB INDEX V_MODIFY_INDEX.

  MOVE /ZAK/ADONSZA_ALV-ESDAT TO W_OUTTAB-ESDAT.
  MOVE /ZAK/ADONSZA_ALV-ZLOCK TO W_OUTTAB-ZLOCK.

  COLLECT W_OUTTAB INTO I_OUTTAB.

  MOVE /ZAK/ADONSZA_ALV TO W_/ZAK/ADONSZA_ALV.

  PERFORM LEAVE_SCREEN_9002.

ENDFORM.                    " SAVE_DATA_9002
