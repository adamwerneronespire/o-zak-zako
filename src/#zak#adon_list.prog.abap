*&---------------------------------------------------------------------*
*& Program: Tax current account - list program
*&---------------------------------------------------------------------*
REPORT /ZAK/ADON_LIST  MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Tax current account - list
*&---------------------------------------------------------------------*
*& Author            : Cserhegyi Timea - FMC
*& Created on        : 2006.03.01
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
*& 0001   2007/05/17   Balazs G.     Process multiple selected rows during locking
*&
*&---------------------------------------------------------------------*

*++S4HANA#01.
DATA: L_SUBRC TYPE SY-SUBRC.
*--S4HANA#01.
INCLUDE /ZAK/COMMON_STRUCT.


*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*


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


DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/ADONSZAALV2 INITIAL SIZE 0,
      W_OUTTAB TYPE /ZAK/ADONSZAALV2.


* ALV handling variables
DATA: V_OK_CODE          LIKE SY-UCOMM,
      V_SAVE_OK          LIKE SY-UCOMM,
      V_REPID            LIKE SY-REPID,
      V_CONTAINER        TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_GRID             TYPE REF TO CL_GUI_ALV_GRID,
      V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT         TYPE LVC_T_FCAT,
      V_LAYOUT           TYPE LVC_S_LAYO,
      V_VARIANT          TYPE DISVARIANT.

*++S4HANA#01.
*DATA: X_SAVE,
DATA: X_SAVE   TYPE C,
*--S4HANA#01.
      X_LAYOUT TYPE DISVARIANT,
      V_EXIT   TYPE C.

DATA: DEF_LAYOUT  TYPE DISVARIANT,     "default layout
      DEFAULT     TYPE C VALUE ' ',
      SPEC_LAYOUT TYPE DISVARIANT.

*++BG 2006/07/07
DATA V_MODIFY_INDEX  LIKE SY-TABIX.
*--BG 2006/07/07


*++0001 BG 2007.05.17
DATA: I_ROWS TYPE LVC_T_ROW,
      W_ROWS TYPE LVC_S_ROW.
*--0001 BG 2007.05.17

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


SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
  SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME.
    SELECT-OPTIONS: S_BELNR   FOR /ZAK/ADONSZA-BELNR,
                    S_GJAHR   FOR /ZAK/ADONSZA-GJAHR.
  SELECTION-SCREEN: END OF BLOCK BL03.

  SELECT-OPTIONS: S_ADONEM  FOR /ZAK/ADONSZA-ADONEM.

  SELECTION-SCREEN: BEGIN OF BLOCK BL04 WITH FRAME.
    SELECT-OPTIONS: S_BTYPE   FOR /ZAK/ADONSZA-BTYPE,
                    S_MONAT   FOR /ZAK/ADONSZA-MONAT,
                    S_ZINDEX  FOR /ZAK/ADONSZA-ZINDEX,
                    S_BSZNUM  FOR /ZAK/ADONSZA-BSZNUM.
  SELECTION-SCREEN: END OF BLOCK BL04.

  SELECT-OPTIONS: S_KOTEL   FOR /ZAK/ADONSZA-KOTEL,
                  S_ESDAT   FOR /ZAK/ADONSZA-ESDAT,
                  S_BUDAT   FOR /ZAK/ADONSZA-BUDAT,
                  S_WAERS   FOR /ZAK/ADONSZA-WAERS,
                  S_BELNRK  FOR /ZAK/ADONSZA-BELNR_K.

  SELECTION-SCREEN: BEGIN OF BLOCK BL05 WITH FRAME.
    SELECT-OPTIONS: S_DATUM   FOR /ZAK/ADONSZA-DATUM,
                    S_UNAME   FOR /ZAK/ADONSZA-UNAME.
  SELECTION-SCREEN: END OF BLOCK BL05.

SELECTION-SCREEN: END OF BLOCK BL02.


SELECTION-SCREEN: BEGIN OF BLOCK BL06 WITH FRAME.
  PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN: END OF BLOCK BL06.

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
*   You are not authorized to run this program!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_ATTRIBUTES.
  PERFORM SET_LAYOUT.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  SET PARAMETER ID 'BUK' FIELD P_BUKRS.
  PERFORM READ_ADDITIONALS.
  PERFORM CHECK_LAYOUT.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN on value-request
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM GET_F4_LAYOUT.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM READ_DATA.


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
* Company name
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

  SELECT * INTO TABLE I_/ZAK/ADONSZA FROM  /ZAK/ADONSZA
         WHERE  BUKRS    = P_BUKRS
         AND    BELNR    IN S_BELNR
         AND    GJAHR    IN S_GJAHR
         AND    ADONEM   IN S_ADONEM
         AND    BTYPE    IN S_BTYPE
         AND    MONAT    IN S_MONAT
         AND    ZINDEX   IN S_ZINDEX
         AND    BSZNUM   IN S_BSZNUM
         AND    KOTEL    IN S_KOTEL
         AND    ESDAT    IN S_ESDAT
         AND    BUDAT    IN S_BUDAT
         AND    WAERS    IN S_WAERS
         AND    BELNR_K  IN S_BELNRK
         AND    DATUM    IN S_DATUM
         AND    UNAME    IN S_UNAME.


  LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA.
    MOVE-CORRESPONDING W_/ZAK/ADONSZA TO W_OUTTAB.


* Tax type name
    CLEAR W_OUTTAB-ADONEM_TXT.
    SELECT SINGLE ADONEM_TXT INTO W_OUTTAB-ADONEM_TXT FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = W_OUTTAB-BUKRS
           AND    ADONEM  = W_OUTTAB-ADONEM.

* Tax return type name
    CLEAR W_OUTTAB-BTEXT.
*++S4HANA#01.
*    SELECT SINGLE BTEXT INTO W_OUTTAB-BTEXT FROM  /ZAK/BEVALLT
*           WHERE  LANGU   = SY-LANGU
*           AND    BUKRS   = W_OUTTAB-BUKRS
*           AND    BTYPE   = W_OUTTAB-BTYPE.
    SELECT BTEXT INTO W_OUTTAB-BTEXT FROM  /ZAK/BEVALLT UP TO 1 ROWS
       WHERE  LANGU   = SY-LANGU
       AND    BUKRS   = W_OUTTAB-BUKRS
       AND    BTYPE   = W_OUTTAB-BTYPE
       ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.


* Obligation / fulfillment columns
    IF W_OUTTAB-KOTEL = 'K'.
      W_OUTTAB-K_WRBTR = W_OUTTAB-WRBTR.
      W_OUTTAB-T_WRBTR = 0.
    ENDIF.
    IF W_OUTTAB-KOTEL = 'T'.
      W_OUTTAB-K_WRBTR = 0.
      W_OUTTAB-T_WRBTR = W_OUTTAB-WRBTR.
    ENDIF.

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

  IF NOT SPEC_LAYOUT IS INITIAL.
    MOVE-CORRESPONDING SPEC_LAYOUT TO PS_VARIANT.
  ELSEIF NOT DEF_LAYOUT IS INITIAL.
    MOVE-CORRESPONDING DEF_LAYOUT TO PS_VARIANT.
*++S4HANA#01.
*  ELSE.
*--S4HANA#01.
  ENDIF.


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
      I_STRUCTURE_NAME   = '/ZAK/ADONSZAALV2'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = PT_FIELDCAT.


*++BG 2006/07/07
* Set checkbox on field ZLOCK
  LOOP AT PT_FIELDCAT INTO LW_FIELDCAT.
    IF LW_FIELDCAT-FIELDNAME = 'ZLOCK'.
      LW_FIELDCAT-CHECKBOX  = 'X'.
    ENDIF.
    MODIFY PT_FIELDCAT FROM LW_FIELDCAT.
  ENDLOOP.
*--BG 2006/07/07


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


* Vissza
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

* Exit
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.

*++BG 2006/07/07
    WHEN '/ZAK/ZAK_MOD'.

      PERFORM MODIFY_SELECTED_LINES.
*--BG 2006/07/07

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
*&      Form  set_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_LAYOUT.
* If a default layout exist, its identification
* is saved in 'def_layout'.
*
  IF DEFAULT = ' '.
    CLEAR DEF_LAYOUT.
    MOVE V_REPID TO DEF_LAYOUT-REPORT.
    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
      EXPORTING
        I_SAVE     = X_SAVE
      CHANGING
        CS_VARIANT = DEF_LAYOUT
      EXCEPTIONS
        NOT_FOUND  = 2.
    IF SY-SUBRC = 2.
      EXIT.
    ELSE.
      P_VARI = DEF_LAYOUT-VARIANT.
      DEFAULT = 'X'.
    ENDIF.
  ENDIF.                             "default IS INITIAL

ENDFORM.                    " set_layout
*&---------------------------------------------------------------------*
*&      Form  check_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_LAYOUT.
* test if specified layout exist
  CLEAR SPEC_LAYOUT.

  IF NOT P_VARI IS INITIAL.

    MOVE P_VARI  TO SPEC_LAYOUT-VARIANT.
    MOVE V_REPID TO SPEC_LAYOUT-REPORT.

    X_SAVE = 'A'.

    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        I_SAVE        = X_SAVE
      CHANGING
        CS_VARIANT    = SPEC_LAYOUT
      EXCEPTIONS
        WRONG_INPUT   = 1
        NOT_FOUND     = 2
        PROGRAM_ERROR = 3
        OTHERS        = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDFORM.                    " check_layout
*&---------------------------------------------------------------------*
*&      Form  get_f4_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_F4_LAYOUT.
* popup F4 help to select a layout

  CLEAR X_LAYOUT.
  MOVE V_REPID TO X_LAYOUT-REPORT.

  X_SAVE = 'A'.
  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      IS_VARIANT = X_LAYOUT
      I_SAVE     = X_SAVE
    IMPORTING
      E_EXIT     = V_EXIT
      ES_VARIANT = SPEC_LAYOUT
    EXCEPTIONS
      NOT_FOUND  = 1
      OTHERS     = 2.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF V_EXIT NE 'X'.
* set name of layout on selection screen
      P_VARI    = SPEC_LAYOUT-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_f4_layout
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SELECTED_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SELECTED_LINES.

*++0001 BG 2007.05.17
*  DATA: LI_ROWS TYPE LVC_T_ROW,
*        LW_ROWS TYPE LVC_S_ROW.
*++S4HANA#01.
*  DATA L_EXIT.
  DATA L_EXIT TYPE C.
*--S4HANA#01.
  DATA LW_OUTTAB TYPE /ZAK/ADONSZAALV2.

*--0001 BG 2007.05.17

  DATA  L_LINE LIKE SY-TABIX.


  CLEAR /ZAK/ADONSZA_ALV.

*++0001 BG 2007.05.17
*++S4HANA#01.
*  REFRESH I_ROWS.
  CLEAR I_ROWS[].
*--S4HANA#01.
  CLEAR:  W_ROWS, L_EXIT, LW_OUTTAB.
*--0001 BG 2007.05.17

  CALL METHOD V_GRID->GET_SELECTED_ROWS
    IMPORTING
*++0001 BG 2007.05.17
*     ET_INDEX_ROWS = LI_ROWS.
      ET_INDEX_ROWS = I_ROWS.
*--0001 BG 2007.05.17

*++0001 BG 2007.05.17
* DESCRIBE TABLE LI_ROWS LINES L_LINE.
*++S4HANA#01.
*  DESCRIBE TABLE I_ROWS LINES L_LINE.
  L_LINE = LINES( I_ROWS ).
*--S4HANA#01.
*--0001 BG 2007.05.17


  IF L_LINE IS INITIAL.
    MESSAGE I186.
*   Please select the row or rows to be processed!
    EXIT.

*++0001 BG 2007.05.17
*  ELSEIF L_LINE NE 1.
*    MESSAGE E187.
**   Please select only one row!
*    EXIT.
*--0001 BG 2007.05.17
  ENDIF.

*++0001 BG 2007.05.17
*  CLEAR V_MODIFY_INDEX.
*
*  READ TABLE LI_ROWS INTO LW_ROWS INDEX 1.
*
*  READ TABLE I_OUTTAB INTO W_OUTTAB INDEX LW_ROWS-INDEX.
*
** If BELNR_K is filled you can no longer change it.
*  IF NOT W_OUTTAB-BELNR_K IS INITIAL.
*    MESSAGE I190.
**   The document is financially cleared and can no longer be changed!
*    EXIT.
*  ENDIF.
*
*  MOVE-CORRESPONDING W_OUTTAB TO /ZAK/ADONSZA_ALV.
*
*  MOVE LW_ROWS-INDEX TO V_MODIFY_INDEX.
*
** This is how we compare whether processing has already happened
*  MOVE /ZAK/ADONSZA_ALV  TO W_/ZAK/ADONSZA_ALV.

*  Read through the selected records:
  LOOP AT  I_ROWS INTO W_ROWS.
    READ TABLE I_OUTTAB INTO W_OUTTAB INDEX W_ROWS-INDEX.
    IF NOT W_OUTTAB-BELNR_K IS INITIAL.
      MESSAGE I190.
      MOVE C_X TO L_EXIT.
*     The selection contains a financially cleared document that can no longer be changed!
      EXIT.
    ENDIF.
*   The due date and lock flag must match in every record
    IF LW_OUTTAB IS INITIAL.
      LW_OUTTAB = W_OUTTAB.
    ELSE.
      IF LW_OUTTAB-ESDAT NE W_OUTTAB-ESDAT OR
         LW_OUTTAB-ZLOCK NE W_OUTTAB-ZLOCK.
        MESSAGE I218.
*        The due date or lock flag value differs in the selected items!
        MOVE C_X TO L_EXIT.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF NOT L_EXIT IS INITIAL.
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING LW_OUTTAB TO /ZAK/ADONSZA_ALV.

* This is how we compare whether processing has already happened
  MOVE /ZAK/ADONSZA_ALV  TO W_/ZAK/ADONSZA_ALV.
*--0001 BG 2007.05.17


  CALL SCREEN 9002 STARTING AT 5  5
                   ENDING   AT 60 10.

  CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.

*++BG 2007.05.08
* We set the row index.
  CALL METHOD V_GRID->SET_SELECTED_ROWS
    EXPORTING
*--0001 BG 2007.05.17
*     IT_INDEX_ROWS = LI_ROWS.
      IT_INDEX_ROWS = I_ROWS.
*--BG 2007.05.08

ENDFORM.                    " MODIFY_SELECTED_LINES
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9002 OUTPUT.

  PERFORM SET_STATUS.

ENDMODULE.                 " STATUS_9002  OUTPUT
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
*&      Form  SAVE_DATA_9002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA_9002.

*++BG 2008.03.26
** Modify data and aggregate totals
*  READ TABLE I_OUTTAB INTO W_OUTTAB INDEX V_MODIFY_INDEX.
*
  GET TIME.
*
*  MOVE /ZAK/ADONSZA_ALV-ESDAT TO W_OUTTAB-ESDAT.
*  MOVE /ZAK/ADONSZA_ALV-ZLOCK TO W_OUTTAB-ZLOCK.
*  MOVE SY-DATUM  TO W_OUTTAB-DATUM.
*  MOVE SY-UZEIT  TO W_OUTTAB-UZEIT.
*  MOVE SY-UNAME  TO W_OUTTAB-UNAME.

*--BG 2008.03.26


*++0001 BG 2007.05.17
  LOOP AT I_ROWS INTO W_ROWS.

*--BG 2008.03.26
    READ TABLE I_OUTTAB INTO W_OUTTAB INDEX W_ROWS-INDEX.
    MOVE /ZAK/ADONSZA_ALV-ESDAT TO W_OUTTAB-ESDAT.
    MOVE /ZAK/ADONSZA_ALV-ZLOCK TO W_OUTTAB-ZLOCK.
    MOVE SY-DATUM  TO W_OUTTAB-DATUM.
    MOVE SY-UZEIT  TO W_OUTTAB-UZEIT.
    MOVE SY-UNAME  TO W_OUTTAB-UNAME.
*++BG 2008.03.26

*   MODIFY I_OUTTAB FROM W_OUTTAB INDEX V_MODIFY_INDEX.
    MODIFY I_OUTTAB FROM W_OUTTAB INDEX W_ROWS-INDEX.
*--0001 BG 2007.05.17

* Modify /ZAK/ADONSZA
    UPDATE /ZAK/ADONSZA SET  ESDAT  = W_OUTTAB-ESDAT
                            ZLOCK  = W_OUTTAB-ZLOCK
                            DATUM  = W_OUTTAB-DATUM
                            UZEIT  = W_OUTTAB-UZEIT
                            UNAME  = W_OUTTAB-UNAME
                WHERE  BUKRS       = W_OUTTAB-BUKRS
                  AND  BELNR       = W_OUTTAB-BELNR
                  AND  GJAHR       = W_OUTTAB-GJAHR.
    COMMIT WORK.
  ENDLOOP.

  MOVE /ZAK/ADONSZA_ALV TO W_/ZAK/ADONSZA_ALV.

  PERFORM LEAVE_SCREEN_9002.

ENDFORM.                    " SAVE_DATA_900

