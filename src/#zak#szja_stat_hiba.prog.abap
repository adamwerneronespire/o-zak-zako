*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Program: SAP analytics statistics error investigation
*&---------------------------------------------------------------------*
REPORT /ZAK/SZJA_STAT_HIBA MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: Based on the conditions entered on the selection
*& screen, the program filters the records from the SAP /ZAK/ANALITIKA
*& table that were not marked as statistical records during upload.
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2007.02.01
*& Functional spec by: ________
*& SAP module name   : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION       TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx
*&                                   xxxxxxx xxxxxxx xxxxxxx
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& TABLES                                                               *
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.


DATA: BEGIN OF I_SUM_DATA OCCURS 0,
      BUKRS   LIKE /ZAK/ANALITIKA-BUKRS,
      BTYPE   LIKE /ZAK/ANALITIKA-BTYPE,
      GJAHR   LIKE /ZAK/ANALITIKA-GJAHR,
      MONAT   LIKE /ZAK/ANALITIKA-MONAT,
      ABEVAZ  LIKE /ZAK/ANALITIKA-ABEVAZ,
      ADOAZON LIKE /ZAK/ANALITIKA-ADOAZON,
      BSZNUM  LIKE /ZAK/ANALITIKA-BSZNUM,
      LAPSZ   LIKE /ZAK/ANALITIKA-LAPSZ,
      INT     TYPE I,
      END OF I_SUM_DATA.


*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Constant            -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Ranges              -   (R_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Type                -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Method              -   (METH_xxx...)                           *
*      Object              -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*

RANGES R_BSZNUM FOR /ZAK/ANALITIKA-BSZNUM.


*MACRO definition for filling a range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.


DATA V_SUBRC LIKE SY-SUBRC.
DATA V_REPID LIKE SY-REPID.


* ALV handling variables
DATA: V_OK_CODE LIKE SY-UCOMM,
      V_SAVE_OK LIKE SY-UCOMM,
      V_CONTAINER   TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT   TYPE LVC_T_FCAT,
      V_LAYOUT     TYPE LVC_S_LAYO,
      V_VARIANT    TYPE DISVARIANT,
      V_GRID   TYPE REF TO CL_GUI_ALV_GRID.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
PARAMETERS P_BUKRS  LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                       OBLIGATORY MEMORY ID BUK.

PARAMETERS P_BTYPE  LIKE /ZAK/ANALITIKA-BTYPE OBLIGATORY.

PARAMETERS P_GJAHR  LIKE /ZAK/ANALITIKA-GJAHR OBLIGATORY.

SELECT-OPTIONS S_MONAT FOR /ZAK/ANALITIKA-MONAT OBLIGATORY.

SELECT-OPTIONS S_ADOAZ FOR /ZAK/ANALITIKA-ADOAZON.

SELECT-OPTIONS S_ABEVAZ FOR /ZAK/ANALITIKA-ABEVAZ.

SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.

*Initial filling of ABEVAZ
  M_DEF S_ABEVAZ 'E' 'EQ' 'DUMMY' SPACE.
  M_DEF S_ABEVAZ 'E' 'BT' 'A0000000000000000'
                          'AZZZZZZZZZZZZZZZZ'.
*++1765 #19.
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

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Data provision identifiers that are complete
  PERFORM GET_BSZNUM.

* Analytics selection
  PERFORM GET_SEL_ANALITIKA.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

*  No list is created in the background.
  IF SY-BATCH IS INITIAL.
    PERFORM LIST_DISPLAY.
  ENDIF.



*&---------------------------------------------------------------------*
*&      Form  GET_BSZNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BSZNUM.

  DATA L_BSZNUM TYPE /ZAK/BSZNUM.

  MOVE SY-REPID TO V_REPID.


  SELECT BSZNUM INTO L_BSZNUM
                FROM /ZAK/BEVALLD
               WHERE BUKRS EQ P_BUKRS
                 AND BTYPE EQ P_BTYPE
                 AND XFULL EQ 'X'.
    M_DEF R_BSZNUM 'I' 'EQ' L_BSZNUM SPACE.
  ENDSELECT.

ENDFORM.                    " GET_BSZNUM
*&---------------------------------------------------------------------*
*&      Form  GET_SEL_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SEL_ANALITIKA.

  DATA LW_ANALITIKA LIKE /ZAK/ANALITIKA.


  SELECT * INTO LW_ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS   EQ P_BUKRS
            AND BTYPE   EQ P_BTYPE
            AND GJAHR   EQ P_GJAHR
            AND MONAT   IN S_MONAT
            AND ABEVAZ  IN S_ABEVAZ
            AND ADOAZON IN S_ADOAZ
            AND BSZNUM  IN R_BSZNUM.

    IF LW_ANALITIKA-STAPO NE 'X'.
      CLEAR I_SUM_DATA.
      MOVE-CORRESPONDING LW_ANALITIKA TO I_SUM_DATA.
      I_SUM_DATA-INT = 1.
      COLLECT I_SUM_DATA.
    ENDIF.

  ENDSELECT.

  DELETE I_SUM_DATA WHERE INT = 1.

  IF NOT I_SUM_DATA[] IS INITIAL.

    SELECT * INTO TABLE I_/ZAK/ANALITIKA
             FROM /ZAK/ANALITIKA
             FOR ALL ENTRIES IN I_SUM_DATA
           WHERE BUKRS   = I_SUM_DATA-BUKRS
             AND GJAHR   = I_SUM_DATA-GJAHR
             AND MONAT   = I_SUM_DATA-MONAT
             AND ABEVAZ  = I_SUM_DATA-ABEVAZ
             AND ADOAZON = I_SUM_DATA-ADOAZON
             AND BSZNUM  = I_SUM_DATA-BSZNUM
             AND LAPSZ   = I_SUM_DATA-LAPSZ.

    DELETE I_/ZAK/ANALITIKA WHERE STAPO = 'X'.
  ENDIF.

ENDFORM.                    " GET_SEL_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.

  CALL SCREEN 9000.

ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  PERFORM SET_STATUS.


  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_/ZAK/ANALITIKA[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.

ENDMODULE.                 " STATUS_9000  OUTPUT
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
  SET TITLEBAR  'MAIN9000'.

ENDFORM.                    " SET_STATUS

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
FORM CREATE_AND_INIT_ALV CHANGING $I_/ZAK/ANALITIKA LIKE
                                                   I_/ZAK/ANALITIKA[]
                                  $FIELDCAT TYPE LVC_T_FCAT
                                  $LAYOUT   TYPE LVC_S_LAYO
                                  $VARIANT  TYPE DISVARIANT.

  DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
         EXPORTING CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
         EXPORTING I_PARENT = V_CUSTOM_CONTAINER.

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
       EXPORTING IS_VARIANT            = $VARIANT
                 I_SAVE                = 'A'
                 I_DEFAULT             = 'X'
                 IS_LAYOUT             = $LAYOUT
                 IT_TOOLBAR_EXCLUDING  = LI_EXCLUDE
       CHANGING  IT_FIELDCATALOG       = $FIELDCAT
                 IT_OUTTAB             = $I_/ZAK/ANALITIKA.

*   CREATE OBJECT v_event_receiver.
*   SET HANDLER v_event_receiver->handle_toolbar       FOR v_grid.
*   SET HANDLER v_event_receiver->handle_double_click  FOR v_grid.
*   SET HANDLER v_event_receiver->handle_user_command  FOR v_grid.
*
** raise event TOOLBAR:
*   CALL METHOD v_grid->set_toolbar_interactive.

ENDFORM.                    " create_and_init_alv

*&---------------------------------------------------------------------
*
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
      PERFORM EXIT_PROGRAM.

    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9000  INPUT

*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM.
  LEAVE TO SCREEN 0.
ENDFORM.                    " exit_program


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
              I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
              I_BYPASSING_BUFFER = 'X'
         CHANGING
              CT_FIELDCAT        = $FIELDCAT.

    LOOP AT $FIELDCAT INTO S_FCAT.
*       IF  S_FCAT-FIELDNAME = 'ADOAZON'  OR
*           S_FCAT-FIELDNAME = 'XMANU'    OR
*           S_FCAT-FIELDNAME = 'XDEFT'    OR
*           S_FCAT-FIELDNAME = 'VORSTOR'  OR
*           S_FCAT-FIELDNAME = 'STAPO'    OR
*           S_FCAT-FIELDNAME = 'DMBTR'    OR
*           S_FCAT-FIELDNAME = 'KOSTL'    OR
*           S_FCAT-FIELDNAME = 'ZCOMMENT' OR
*           S_FCAT-FIELDNAME = 'BOOK'     OR
*           S_FCAT-FIELDNAME = 'KMONAT'   OR
*           S_FCAT-FIELDNAME = 'AUFNR'.
*         S_FCAT-NO_OUT = 'X'.
*         MODIFY $FIELDCAT FROM S_FCAT.
*       ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " build_fieldcat
