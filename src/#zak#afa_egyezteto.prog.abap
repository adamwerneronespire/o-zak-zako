*&---------------------------------------------------------------------*
*& Program: VAT return vs. general ledger reconciliation list
*----------------------------------------------------------------------*
 REPORT /ZAK/AFA_EGYEZTETO MESSAGE-ID /ZAK/ZAK LINE-SIZE 255
                                         LINE-COUNT 65.
*&---------------------------------------------------------------------*
*& Function description:
*&---------------------------------------------------------------------*
*& Author            : Denes Karoly
*& Created on        : 2006.02.07
*& Functional spec by: ________
*& SAP module        : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (write the OSS note number at the end of each modified line)*
*&
*& LOG#     DATE        CHANGED BY                 DESCRIPTION
*& ----   ----------   ----------    -----------------------------------
*& 0001   2008/11/05   Balazs G.     Additional fields on the detail screen,
*&                                   implement saved list,
*&                                   select all
*&---------------------------------------------------------------------*
*++S4HANA#01.
 DATA: L_NAME   TYPE C LENGTH 20,
       W_RETURN TYPE BAPIRET2.
*--S4HANA#01.

 INCLUDE /ZAK/AFA_TOP.
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.


*& CONSTANTS  (C_XXXXXXX..)                                           *
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
 CONSTANTS:
   C_RLDNR LIKE GLT0-RLDNR VALUE '00',
   C_RRCTY LIKE GLT0-RRCTY VALUE '0',
   C_RVERS LIKE GLT0-RVERS VALUE '001',
   C_KOART LIKE BSEG-KOART VALUE 'K',
   C_H     LIKE BSEG-SHKZG VALUE 'H',
   C_S     LIKE BSEG-SHKZG VALUE 'S'.


*& INTERNAL TABLES  (I_XXXXXXX..)                                         *
*& INTERNAL TABLES  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
 TYPES: BEGIN OF T_BSEG_V,
          HKONT LIKE BSEG-HKONT,
          BUKRS LIKE BSEG-BUKRS,
          BELNR LIKE BSEG-BELNR,
          GJAHR LIKE BSEG-GJAHR,
          BUZEI LIKE BSEG-BUZEI,
          KOART LIKE BSEG-KOART,
          SHKZG LIKE BSEG-SHKZG,
          DMBTR LIKE BSEG-DMBTR,
*++0001 2008.11.05 Balazs Gabor (Fmc)
          MWSKZ LIKE BSEG-MWSKZ,
          KTOSL LIKE BSEG-KTOSL,
          LIFNR LIKE BSEG-LIFNR,
          KUNNR LIKE BSEG-KUNNR,
*--0001 2008.11.05 Balazs Gabor (Fmc)
        END OF T_BSEG_V.

 DATA: W_BSEG_V TYPE T_BSEG_V.

*++S4HANA#01.
* DATA: I_BSEG_V TYPE T_BSEG_V OCCURS 0. "INITIAL SIZE 0.
 DATA: GT_I_BSEG_V TYPE STANDARD TABLE OF T_BSEG_V . "INITIAL SIZE 0.
*--S4HANA#01.
*& PROGRAM VARIABLES                                                    *
*& PROGRAM VARIABLES                                                    *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Types               -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Class               -   (CL_xxx...)                             *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*


 DATA: V_COUNTER TYPE I.
* ALV handling variables
* ALV handling variables
 DATA: V_OK_CODE           LIKE SY-UCOMM,
       V_SAVE_OK           LIKE SY-UCOMM,
       V_REPID             LIKE SY-REPID,
       V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
       V_CONTAINER2        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',

       V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
       V_GRID2             TYPE REF TO CL_GUI_ALV_GRID,

       V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       V_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

       I_FIELDCAT          TYPE LVC_T_FCAT,
       I_FIELDCAT2         TYPE LVC_T_FCAT,

       V_LAYOUT            TYPE LVC_S_LAYO,
       V_LAYOUT2           TYPE LVC_S_LAYO,

       V_VARIANT           TYPE DISVARIANT,
       V_VARIANT2          TYPE DISVARIANT,

       V_TOOLBAR           TYPE STB_BUTTON,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER.
* Company
* Company
 DATA: F_BUTXT    LIKE T001-BUTXT,
       V_MON_HIGH LIKE BKPF-MONAT.
*
 DATA: L_NUM(2) TYPE N.

 DATA: V_LAST_DATE TYPE DATUM.

*++0001 2008.11.05 Balazs Gabor (Fmc)
 RANGES R_HKONT FOR /ZAK/EGYEZTETALV-HKONT.

 DATA I_/ZAK/EGY_FEJ TYPE STANDARD TABLE OF /ZAK/EGY_FEJ INITIAL SIZE 0.
 DATA I_/ZAK/EGY_TETEL TYPE STANDARD TABLE OF /ZAK/EGY_TETEL INITIAL SIZE 0.
 DATA W_/ZAK/EGY_FEJ TYPE /ZAK/EGY_FEJ.
 DATA W_/ZAK/EGY_TETEL TYPE /ZAK/EGY_TETEL.
 DATA V_SUBRC LIKE SY-SUBRC.
 DATA V_TEXT(10).

*++S4HANA#01.
* DATA: BEGIN OF I_BTYPE OCCURS 0,
*         GJAHR TYPE GJAHR,
*         MONAT TYPE MONAT,
*         BTYPE TYPE /ZAK/BTYPE,
*       END OF I_BTYPE.
 TYPES: BEGIN OF TS_I_BTYPE ,
          GJAHR TYPE GJAHR,
          MONAT TYPE MONAT,
          BTYPE TYPE /ZAK/BTYPE,
        END OF TS_I_BTYPE .
 TYPES TT_I_BTYPE TYPE STANDARD TABLE OF TS_I_BTYPE .
 DATA: GS_I_BTYPE TYPE TS_I_BTYPE.
 DATA: GT_I_BTYPE TYPE TT_I_BTYPE.
*--S4HANA#01.
*--0001 2008.11.05 Balazs Gabor (Fmc)
*++1865 #14.
 DATA V_WAERS TYPE WAERS.
*--1865 #14.
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
 SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-A01.
     PARAMETERS: P_BUKRS  LIKE T001-BUKRS VALUE CHECK DEFAULT 'MA01'
                               OBLIGATORY MEMORY ID BUK.
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID OUT.
   SELECTION-SCREEN END OF LINE.

   SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-T03.
     SELECT-OPTIONS: S_HKONT FOR BSEG-HKONT              OBLIGATORY.
     PARAMETERS:     P_GJAHR LIKE BKPF-GJAHR             OBLIGATORY.
     SELECT-OPTIONS: S_MONAT FOR BKPF-MONAT NO-EXTENSION OBLIGATORY.
   SELECTION-SCREEN: END OF BLOCK BL03.
 SELECTION-SCREEN: END OF BLOCK BL01.

*++0001 2008.11.05 Balazs Gabor (Fmc)
 SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
   PARAMETERS P_LOAD AS CHECKBOX.
 SELECTION-SCREEN: END OF BLOCK BL02.
*--0001 2008.11.05 Balazs Gabor (Fmc)


*++S4HANA#01.
* RANGES: R_MONAT FOR S_MONAT-LOW,
*         R_BUPER FOR /ZAK/BSET-BUPER.
 TYPES TT_MONAT LIKE RANGE OF S_MONAT-LOW.
 DATA GT_MONAT TYPE TT_MONAT.
 DATA GS_MONAT TYPE LINE OF TT_MONAT.
 TYPES TT_BUPER TYPE RANGE OF /ZAK/BSET-BUPER.
 DATA GT_BUPER TYPE TT_BUPER.
 DATA GS_BUPER TYPE LINE OF TT_BUPER.
*--S4HANA#01.


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
       HANDLE_DATA_CHANGED
         FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
         IMPORTING ER_DATA_CHANGED.

     CLASS-METHODS:
       HANDLE_TOOLBAR
         FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
         IMPORTING E_OBJECT E_INTERACTIVE,


       HANDLE_DOUBLE_CLICK
         FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW
                   E_COLUMN
                   ES_ROW_NO,

       HANDLE_HOTSPOT_CLICK
         FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW_ID
                   E_COLUMN_ID
                   ES_ROW_NO,

       HANDLE_USER_COMMAND
         FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
         IMPORTING E_UCOMM.



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

   METHOD HANDLE_TOOLBAR.

* append a separator to normal toolbar
*     CLEAR V_TOOLBAR.
*     MOVE 3 TO V_TOOLBAR-BUTN_TYPE.
*     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*++0001 2008.11.05 Balazs Gabor (Fmc)
     CLEAR V_TOOLBAR.
     MOVE 'DETAIL' TO V_TOOLBAR-FUNCTION.
     MOVE ICON_DETAIL TO V_TOOLBAR-ICON.
     MOVE 'Részletek'(TO4) TO V_TOOLBAR-QUICKINFO.
     MOVE 'Részletek'(TO4) TO V_TOOLBAR-TEXT.
     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*--0001 2008.11.05 Balazs Gabor (Fmc)
   ENDMETHOD.                    "HANDLE_TOOLBAR



*---------------------------------------------------------------------*
*       METHOD double_click                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_DOUBLE_CLICK.
     PERFORM D9000_EVENT_DOUBLE_CLICK USING E_ROW
                                            E_COLUMN.
   ENDMETHOD.     "double_click


*---------------------------------------------------------------------*
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_HOTSPOT_CLICK.

     IF SY-DYNNR = '9000'.

     ELSEIF SY-DYNNR = '9001'.
       PERFORM D9001_EVENT_HOTSPOT_CLICK USING E_ROW_ID
                                               E_COLUMN_ID.

     ENDIF.
   ENDMETHOD.                    "hotspot_click



*---------------------------------------------------------------------*
*       METHOD handle_user_command                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_USER_COMMAND.
* Sec. 3. In event handler method for event USER_COMMAND: Query your
*   function codes defined in step 2 and react accordingly.

     DATA: I_ROWS TYPE LVC_T_ROW,
           W_ROWS TYPE LVC_S_ROW,
           S_OUT  TYPE /ZAK/EGYEZTETALV.

* Display items!
* Display items!
       WHEN 'BSEG'.
         CALL SCREEN 9001.
* Display details
* Display details
       WHEN 'DETAIL'.
         PERFORM VIEW_DETAIL.
*--0001 2008.11.05 Balazs Gabor (Fmc)
     ENDCASE.
   ENDMETHOD.                           "handle_user_command
*---------------------------------------------------------------------*
*       METHOD handle_data_changed                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_DATA_CHANGED.

     DATA: LS_GOOD TYPE LVC_S_MODI.
     DATA: L_XDEFT,
           L_COUNTER TYPE I.

   ENDMETHOD.                    "HANDLE_DATA_CHANGED

 ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.
   GET PARAMETER ID 'BUK' FIELD P_BUKRS.
   PERFORM FIELD_DESCRIPT.
* Authorization check
* Authorization check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2165 #03.
*                   ID 'TCD'  FIELD SY-TCODE.
                   ID 'TCD'  FIELD '/ZAK/AFA_EGYEZTETO'.
*--2165 #03.
*++1865 #03.
*  IF SY-SUBRC NE 0.
   IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
*   You are not authorized to run the program!
*   You are not authorized to run the program!
   ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
   SET PARAMETER ID 'BUK' FIELD P_BUKRS.
   PERFORM FIELD_DESCRIPT.
   PERFORM CHECK_MONAT.

************************************************************************
* AT SELECTION-SCREEN output
************************************************************************
 AT SELECTION-SCREEN OUTPUT.
   PERFORM MODIF_SCREEN.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*  Authorization check
*  Authorization check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 C_BTYPART_AFA
                                 C_ACTVT_01.

   PERFORM SET_RANGES .
*++0001 2008.11.05 Balazs Gabor (Fmc)
   IF P_LOAD IS INITIAL.
*--0001 2008.11.05 Balázs Gábor (Fmc)
*  Selection
     PERFORM SEL_BKPF_BSEG.
*  Populate table for the ALV list!
*++S4HANA#01.
*     PERFORM FILL_OUTTAB USING I_OUTTAB[]
*                               I_BSEG_V[]
*                               I_BKPF[]
*                               I_/ZAK/BSET[].
     PERFORM FILL_OUTTAB USING I_BKPF[]
                               I_/ZAK/BSET[]
                      CHANGING I_OUTTAB[]
                               GT_I_BSEG_V[].
*--S4HANA#01.
*++0001 2008.11.05 Balazs Gabor (Fmc)
     PERFORM FILL_ITEM_ALL.
   ELSE.
*++S4HANA#01.
*     PERFORM LOAD_DATA USING V_SUBRC.
     PERFORM LOAD_DATA CHANGING V_SUBRC.
*--S4HANA#01.
     IF NOT V_SUBRC IS INITIAL.
       CONCATENATE S_MONAT-LOW S_MONAT-HIGH INTO V_TEXT
                   SEPARATED BY '-'.
*      No saved data available for company & year & month!
*      No saved data available for company & year & month!
       EXIT.
     ENDIF.
   ENDIF.
*--0001 2008.11.05 Balazs Gabor (Fmc)


*  If background run and no saved processing
*  Save the data.
*  Save the data.
   PERFORM SAVE_DATA.
*++0001 2008.11.05 Balazs Gabor (Fmc)

************************************************************************
* ALPROGRAMOK
************************************************************************
 END-OF-SELECTION.
*++0001 2008.11.05 Balazs Gabor (Fmc)
   IF SY-BATCH IS INITIAL.
*--0001 2008.11.05 Balazs Gabor (Fmc)
     PERFORM ALV_LIST.
*++0001 2008.11.05 Balazs Gabor (Fmc)
   ELSE.
     PERFORM GRID_DISPLAY.
   ENDIF.
*--0001 2008.11.05 Balazs Gabor (Fmc)


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
*     SELECT SINGLE *  FROM T001
     SELECT SINGLE *  FROM T001 INTO T001
*--S4HANA#01.
           WHERE BUKRS = P_BUKRS.
     P_BUTXT = T001-BUTXT.
*++1865 #14.
     SELECT SINGLE WAERS INTO V_WAERS
                         FROM T005
                        WHERE LAND1 EQ T001-LAND1.
*--1865 #14.
   ENDIF.

 ENDFORM.                    " field_descript
*****************************
 DEFINE PRO_MONAT.
   IF &1 IN S_MONAT.
     IF GLT0-DRCRK = 'S'.
       W_OUTTAB-/ZAK/EGYENLEG = W_OUTTAB-/ZAK/EGYENLEG + W_GLTO-HSL&1.
     ELSE.
       W_OUTTAB-/ZAK/EGYENLEG = W_OUTTAB-/ZAK/EGYENLEG + W_GLTO-HSL&1.
     ENDIF.
   ENDIF.
 END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ALV_LIST.
* ALV lista
   CALL SCREEN 9000.
 ENDFORM.                    " ALV_LIST

*&---------------------------------------------------------------------*
*&      Module  PBO9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9000 OUTPUT.
   PERFORM SET_STATUS.
*++S4HANA#01.
*   DATA: L_NAME(20) TYPE C,
*         W_RETURN   LIKE BAPIRET2.
*--S4HANA#01.
* The SAP data structure comes from table /ZAK/BEVALLD-STRNAME
* The SAP data structure comes from table /ZAK/BEVALLD-STRNAME
* kell venni
     PERFORM CREATE_AND_INIT_ALV CHANGING I_OUTTAB[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT.
   ENDIF.

 ENDMODULE.                 " PBO9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PAI9000 INPUT.

   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
*++2165 #02.
*     WHEN '/ZAK/HIBA'.
*       SET PF-STATUS 'MAIN9001' .
*       SET TITLEBAR 'MAIN9001'.
*       CALL SCREEN 9001.
*--2165 #02.
* Vissza
     WHEN 'BACK'.
       SET SCREEN 0.
* Exit
* Exit
     WHEN 'EXIT'.
       PERFORM EXIT_PROGRAM.

     WHEN OTHERS.
*     do nothing
   ENDCASE.

 ENDMODULE.                 " PAI9000  INPUT
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
* Display analytics structure
* Display analytics structure
   IF SY-DYNNR = '9000'.
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN'.
   ELSE.
     SET PF-STATUS 'MAIN9001' EXCLUDING TAB.
     SET TITLEBAR 'MAIN9001'.
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
 FORM CREATE_AND_INIT_ALV CHANGING  PT_OUTTAB LIKE I_OUTTAB[]
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
* Build field catalog
   PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                          CHANGING PT_FIELDCAT.

   PS_LAYOUT-CWIDTH_OPT = 'X'.
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
   SET HANDLER V_EVENT_RECEIVER->HANDLE_TOOLBAR       FOR V_GRID.
   SET HANDLER V_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK  FOR V_GRID.
   SET HANDLER V_EVENT_RECEIVER->HANDLE_USER_COMMAND  FOR V_GRID.

* raise event TOOLBAR:
   CALL METHOD V_GRID->SET_TOOLBAR_INTERACTIVE.

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

   DATA: S_FCAT TYPE LVC_S_FCAT.
* /ZAK/ANALITIKA table
* /ZAK/ANALITIKA table
   IF P_DYNNR = '9000'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/EGYEZTETALV'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.


* Item table
* Item table
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/EGYTETELALV'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.

     LOOP AT PT_FIELDCAT INTO S_FCAT.
       IF S_FCAT-FIELDNAME = 'GJAHR' OR
          S_FCAT-FIELDNAME = 'BELNR' OR
          S_FCAT-FIELDNAME = 'BUZEI'.
         S_FCAT-HOTSPOT = 'X'.
         MODIFY PT_FIELDCAT FROM S_FCAT.
       ENDIF.
     ENDLOOP.

   ENDIF.
 ENDFORM.                    " build_fieldcat
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

   IF V_CUSTOM_CONTAINER2 IS INITIAL.
     PERFORM CREATE_AND_INIT_ALV2 CHANGING I_ITEM[]
                                           I_FIELDCAT2
                                           V_LAYOUT2
                                           V_VARIANT2.
   ELSE.
     CALL METHOD V_GRID2->REFRESH_TABLE_DISPLAY.
   ENDIF.
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

* Vissza
     WHEN 'BACK'.
       SET SCREEN 0.
       LEAVE SCREEN.

     WHEN OTHERS.
*     do nothing
   ENDCASE.


 ENDMODULE.                 " pai_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_HIBA[]  text
*      <--P_I_FIELDCAT2  text
*      <--P_V_LAYOUT2  text
*      <--P_V_VARIANT2  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV2 CHANGING  PT_ITEM  LIKE I_ITEM[]
                                     PT_FIELDCAT TYPE LVC_T_FCAT
                                     PS_LAYOUT   TYPE LVC_S_LAYO
                                     PS_VARIANT  TYPE DISVARIANT.

   DATA: I_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER2
     EXPORTING
       CONTAINER_NAME = V_CONTAINER2.
   CREATE OBJECT V_GRID2
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER2.
* Build field catalog
* Build field catalog
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING PT_FIELDCAT.
* Excluding functions
* Excluding functions
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

   PS_LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
   PS_LAYOUT-SEL_MODE = 'B'.


   CLEAR PS_VARIANT.
   PS_VARIANT-REPORT = V_REPID.

   CALL METHOD V_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT           = PS_VARIANT
       I_SAVE               = 'A'
       I_DEFAULT            = 'X'
       IS_LAYOUT            = PS_LAYOUT
       IT_TOOLBAR_EXCLUDING = I_EXCLUDE
     CHANGING
       IT_FIELDCATALOG      = PT_FIELDCAT
       IT_OUTTAB            = PT_ITEM.

   CREATE OBJECT V_EVENT_RECEIVER2.
*   SET HANDLER V_EVENT_RECEIVER2->HANDLE_DOUBLE_CLICK  FOR V_GRID2.
   SET HANDLER V_EVENT_RECEIVER2->HANDLE_HOTSPOT_CLICK FOR V_GRID2.
   SET HANDLER V_EVENT_RECEIVER2->HANDLE_USER_COMMAND  FOR V_GRID2.
* raise event TOOLBAR:
*   CALL METHOD V_GRID->SET_TOOLBAR_INTERACTIVE.

 ENDFORM.                    " CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*&      Form  d9000_event_double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
 FORM D9000_EVENT_DOUBLE_CLICK USING    E_ROW    TYPE LVC_S_ROW
                                        E_COLUMN TYPE LVC_S_COL.
   IF SY-DYNNR EQ '9000' AND
      NOT E_ROW IS INITIAL.
     SET PF-STATUS 'MAIN9001' .
     SET TITLEBAR 'MAIN9001'.
*++0001 2008.11.05 Balazs Gabor (Fmc)
*++S4HANA#01.
*     REFRESH R_HKONT.
     CLEAR R_HKONT[].
*--S4HANA#01.
*--0001 2008.11.05 Balazs Gabor (Fmc)
* Display the documents for the selected row
* Display the documents for the selected row
     READ TABLE I_OUTTAB INTO W_OUTTAB INDEX E_ROW.
     IF SY-SUBRC EQ 0.
*++0001 2008.11.05 Balazs Gabor (Fmc)
       M_DEF R_HKONT 'I' 'EQ' W_OUTTAB-HKONT SPACE.
** Populate the document table
** Populate the document table
*       REFRESH I_ITEM.
*       LOOP AT I_BSEG_V INTO W_BSEG_V
** Sign
** Sign
*         IF W_BSEG_V-SHKZG EQ C_H .
*           W_BSEG_V-DMBTR = W_BSEG_V-DMBTR * -1 .
*         ENDIF.
*
**     KOART EQ C_KOART .
*         MOVE-CORRESPONDING W_BSEG_V TO W_ITEM.
*         W_ITEM-WAERS = 'HUF'. "csak teszt !!!!!!!!!
*         READ TABLE I_BKPF INTO W_BKPF
*              WITH KEY BUKRS = P_BUKRS
*                       BELNR = W_BSEG_V-BELNR
*                       GJAHR = W_BSEG_V-GJAHR.
*         IF SY-SUBRC EQ 0.
*           W_ITEM-BUDAT = W_BKPF-BUDAT.
*           W_ITEM-BLDAT = W_BKPF-BLDAT.
*         ENDIF.
*         READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
*                             WITH KEY BUKRS = W_BSEG_V-BUKRS
*                                      BELNR = W_BSEG_V-BELNR.
**                                      BUZEI = W_BSEG_V-BUZEI.
*         IF SY-SUBRC EQ 0.
*           W_ITEM-BUPER = W_/ZAK/BSET-BUPER.
*         ENDIF.
*         APPEND W_ITEM TO I_ITEM.
*         CLEAR W_ITEM.
*       ENDLOOP.
*--0001 2008.11.05 Balazs Gabor (Fmc)
     ENDIF.
     CALL SCREEN 9001.

   ENDIF.
 ENDFORM.                    " d9000_event_double_click
*&---------------------------------------------------------------------*
*&      Form  D9001_EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
 FORM D9001_EVENT_HOTSPOT_CLICK USING E_ROW_ID    TYPE LVC_S_ROW
                                      E_COLUMN_ID TYPE LVC_S_COL.
   DATA: S_OUT   TYPE /ZAK/EGYTETELALV,
         V_KOKRS TYPE KOKRS.

   READ TABLE I_ITEM INTO W_ITEM INDEX E_ROW_ID.
   IF SY-SUBRC = 0.

     CASE E_COLUMN_ID.
       WHEN 'GJAHR' OR
            'BELNR' OR
            'BUZEI'.

         IF NOT W_ITEM-GJAHR IS INITIAL AND
            NOT W_ITEM-BELNR IS INITIAL AND
            NOT W_ITEM-BUZEI IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD P_BUKRS.
           SET PARAMETER ID 'GJR' FIELD W_ITEM-GJAHR.
           SET PARAMETER ID 'BLN' FIELD W_ITEM-BELNR.
*++2165 #02.
           CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
             EXPORTING
               TCODE  = 'FB03'
             EXCEPTIONS
               OK     = 1
               NOT_OK = 2
               OTHERS = 3.
*++2565 #07.
*           IF SY-SUBRC <> 0.
           IF SY-SUBRC <> 1.
*--2565 #07.
* Implement suitable error handling here
*           No authorization for transaction &
*           No authorization for transaction &
           ELSE.
*--2165 #02.
             CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
*++2165 #02.
           ENDIF.
*--2165 #02.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " d9001_event_hotspot_click

*&---------------------------------------------------------------------*
*&      Form  MODIF_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MODIF_SCREEN.
   LOOP AT SCREEN.
     IF SCREEN-GROUP1 = 'OUT'.
       SCREEN-INPUT = 0.
       SCREEN-OUTPUT = 1.
       SCREEN-DISPLAY_3D = 0.
       MODIFY SCREEN.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " MODIF_SCREEN
*&---------------------------------------------------------------------*
*&      Form  check_monat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_MONAT.

   IF NOT S_MONAT-LOW BETWEEN '01' AND '16'.
*   Please enter the period between 01 and 16!
*   Please enter the period between 01 and 16!
   ENDIF.
   IF S_MONAT-HIGH > 16.
     MESSAGE E020.
   ENDIF.
 ENDFORM.                    " check_monat
*&---------------------------------------------------------------------*
*&      Form  set_ranges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_RANGES.

*++S4HANA#01.
*   CONCATENATE P_GJAHR S_MONAT-LOW INTO R_BUPER-LOW.
   CONCATENATE P_GJAHR S_MONAT-LOW INTO GS_BUPER-LOW.
*--S4HANA#01.
   IF NOT S_MONAT-HIGH IS INITIAL.
*++S4HANA#01.
*     CONCATENATE P_GJAHR S_MONAT-HIGH INTO R_BUPER-HIGH.
     CONCATENATE P_GJAHR S_MONAT-HIGH INTO GS_BUPER-HIGH.
*--S4HANA#01.
   ENDIF.
*++S4HANA#01.
*   R_BUPER-SIGN   = S_MONAT-SIGN.
*   R_BUPER-OPTION = S_MONAT-OPTION.
*   APPEND R_BUPER.
   GS_BUPER-SIGN   = S_MONAT-SIGN.
   GS_BUPER-OPTION = S_MONAT-OPTION.
   APPEND GS_BUPER TO GT_BUPER.
*--S4HANA#01.

   IF S_MONAT-HIGH IS INITIAL.
     S_MONAT-HIGH = S_MONAT-LOW.
   ENDIF.
 ENDFORM.                    " set_ranges
*&---------------------------------------------------------------------*
*&      Form  SEL_BKPF_BSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SEL_BKPF_BSEG.
*++0001 2008.11.05 Balazs Gabor (Fmc)
*++S4HANA#01.
*   DATA LI_BSEG LIKE BSEG OCCURS 0.
*   DATA LW_BSEG LIKE BSEG.
   TYPES: BEGIN OF TS_LI_BSEG_SEL,
            UMSKZ TYPE BSEG-UMSKZ,
            KUNNR TYPE BSEG-KUNNR,
            LIFNR TYPE BSEG-LIFNR,
          END OF TS_LI_BSEG_SEL.
   DATA LT_LI_BSEG TYPE STANDARD TABLE OF
     TS_LI_BSEG_SEL .
   DATA LW_BSEG TYPE TS_LI_BSEG_SEL.
*--S4HANA#01.
*--0001 2008.11.05 Balazs Gabor (Fmc)

*++S4HANA#01.
   DATA: LV_RLDNR1    TYPE RLDNR,
         LT_BSEG      TYPE TABLE OF BSEG,
         LT_BSEG_TEMP TYPE STANDARD TABLE OF T_BSEG_V.
   DATA LT_FAGL_BSEG_TMP TYPE FAGL_T_BSEG.
*--S4HANA#01.
* Index 001 exists
* Index 001 exists
*++S4HANA#01.
*   SELECT * INTO TABLE I_BKPF FROM BKPF
   SELECT BUKRS BELNR GJAHR BLDAT BUDAT INTO CORRESPONDING
     FIELDS OF TABLE I_BKPF FROM BKPF
*--S4HANA#01.
               WHERE BUKRS EQ P_BUKRS AND
                     GJAHR EQ P_GJAHR AND
                     MONAT IN S_MONAT.
* Document segment: posting
* Document segment: posting
*++S4HANA#01.
*     SELECT
     SELECT     "#EC CI_DB_OPERATION_OK[2431747]
*--S4HANA#01.
            HKONT
            BUKRS
            BELNR
            GJAHR
            BUZEI
            KOART
            SHKZG
            DMBTR
*++0001 2008.11.05 Balazs Gabor (Fmc)
            MWSKZ
            KTOSL
*--0001 2008.11.05 Balazs Gabor (Fmc)
*++S4HANA#01.
*            INTO TABLE I_BSEG_V FROM BSEG
            INTO TABLE GT_I_BSEG_V FROM BSEG
*++S4HANA#01.
            FOR ALL ENTRIES IN I_BKPF
            WHERE BUKRS EQ I_BKPF-BUKRS AND
                  BELNR EQ I_BKPF-BELNR AND
                  GJAHR EQ I_BKPF-GJAHR AND
                  HKONT IN S_HKONT.
*++S4HANA#01.
     CALL FUNCTION 'FAGL_GET_LEADING_LEDGER'
       IMPORTING
         E_RLDNR       = LV_RLDNR1
       EXCEPTIONS
         NOT_FOUND     = 1
         MORE_THAN_ONE = 2
         OTHERS        = 3.

     LOOP AT I_BKPF INTO DATA(LS_BKPF).
       CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
         EXPORTING
           I_RLDNR   = LV_RLDNR1
           I_BUKRS   = LS_BKPF-BUKRS
           I_BELNR   = LS_BKPF-BELNR
           I_GJAHR   = LS_BKPF-GJAHR
         IMPORTING
           ET_BSEG   = LT_BSEG
         EXCEPTIONS
           NOT_FOUND = 1
           OTHERS    = 2.

       IF LT_BSEG IS NOT INITIAL.
         DELETE LT_BSEG WHERE HKONT NOT IN S_HKONT.
         IF SY-SUBRC = 0.
           LT_BSEG_TEMP[] = CORRESPONDING #( LT_BSEG[] ).
           APPEND LINES OF LT_BSEG_TEMP TO GT_I_BSEG_V.
           CLEAR: LT_BSEG[], LT_BSEG_TEMP[].
         ENDIF.
       ENDIF.
     ENDLOOP.
*--S4HANA#01.
*Document segment: tax data 2
*Document segment: tax data 2
*++S4HANA#01.
*     IF NOT I_BSEG_V IS INITIAL .
     IF NOT GT_I_BSEG_V IS INITIAL .
*--S4HANA#01.
       SELECT * INTO TABLE I_/ZAK/BSET FROM /ZAK/BSET
*++S4HANA#01.
*                 FOR ALL ENTRIES IN I_BSEG_V
*                 WHERE BUKRS EQ I_BSEG_V-BUKRS AND
*                       BELNR EQ I_BSEG_V-BELNR AND
*                       GJAHR EQ I_BSEG_V-GJAHR.
                  FOR ALL ENTRIES IN GT_I_BSEG_V
                  WHERE BUKRS EQ GT_I_BSEG_V-BUKRS AND
                        BELNR EQ GT_I_BSEG_V-BELNR AND
                        GJAHR EQ GT_I_BSEG_V-GJAHR.
*--S4HANA#01.
*                       BUZEI EQ I_BSEG_V-BUZEI.
     ENDIF.
* Totals data from the GL master
* Totals data from the GL master
   SELECT * INTO TABLE I_GLT0 FROM GLT0
            WHERE RLDNR EQ C_RLDNR AND
                  RRCTY EQ C_RRCTY AND
                  RVERS EQ C_RVERS AND
                  BUKRS EQ P_BUKRS AND
                  RYEAR EQ P_GJAHR AND
                  RACCT IN S_HKONT.

*++0001 2008.11.05 Balazs Gabor (Fmc)
*++S4HANA#01.
*   SORT I_BSEG_V BY BUKRS BELNR GJAHR.
   SORT GT_I_BSEG_V BY BUKRS BELNR GJAHR.
* Determine vendor and customer codes
* Determine vendor and customer codes
*   Check whether the record exists.
*   Check whether the record exists.
*++S4HANA#01.
*     READ TABLE I_BSEG_V TRANSPORTING NO FIELDS
     READ TABLE GT_I_BSEG_V TRANSPORTING NO FIELDS
*--S4HANA#01.
        WITH KEY BUKRS = W_BKPF-BUKRS
                 BELNR = W_BKPF-BELNR
                 GJAHR = W_BKPF-GJAHR
                 BINARY SEARCH.
     IF SY-SUBRC EQ 0.
*++S4HANA#01.
*       REFRESH LI_BSEG.
       CLEAR LT_LI_BSEG[].
*--S4HANA#01.
       CLEAR   W_BSEG_V.
*++S4HANA#01.
*       SELECT * INTO TABLE LI_BSEG
*                FROM BSEG
*               WHERE BUKRS EQ W_BKPF-BUKRS
*                 AND BELNR EQ W_BKPF-BELNR
*                 AND GJAHR EQ W_BKPF-GJAHR.
       CL_FAGL_EMU_CVRT_SERVICES=>GET_LEADING_LEDGER(
        IMPORTING
          ED_RLDNR = DATA(LV_RLDNR)
        EXCEPTIONS
          ERROR  = 4
          OTHERS = 4 ).

       IF SY-SUBRC = 0.
         CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
           EXPORTING
             I_RLDNR   = LV_RLDNR
             I_BUKRS   = W_BKPF-BUKRS
             I_BELNR   = W_BKPF-BELNR
             I_GJAHR   = W_BKPF-GJAHR
           IMPORTING
             ET_BSEG   = LT_FAGL_BSEG_TMP
           EXCEPTIONS
             NOT_FOUND = 4
             OTHERS    = 4.

         IF SY-SUBRC = 0.
           SORT LT_FAGL_BSEG_TMP BY BUZEI.
           LT_LI_BSEG = CORRESPONDING #( LT_FAGL_BSEG_TMP
             MAPPING UMSKZ = UMSKZ KUNNR = KUNNR LIFNR =
               LIFNR
             EXCEPT * ).
           FREE LT_FAGL_BSEG_TMP.
         ELSE.
           CLEAR LT_LI_BSEG.
         ENDIF.
       ENDIF.
*      Find vendor
*      Find vendor
*++S4HANA#01.
*       LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL
       LOOP AT LT_LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL
*--S4HANA#01.
                                     AND NOT UMSKZ IS INITIAL.
         MOVE LW_BSEG-LIFNR TO W_BSEG_V-LIFNR.
         EXIT.
       ENDLOOP.
       IF SY-SUBRC NE 0.
*++S4HANA#01.
*         LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL.
         LOOP AT LT_LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL.
*--S4HANA#01.
           MOVE LW_BSEG-LIFNR TO W_BSEG_V-LIFNR.
           EXIT.
         ENDLOOP.
*      Find customer
*      Find customer
*++S4HANA#01.
*       LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL
       LOOP AT LT_LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL
*--S4HANA#01.
                                     AND NOT UMSKZ IS INITIAL.
         MOVE LW_BSEG-KUNNR TO W_BSEG_V-KUNNR.
         EXIT.
       ENDLOOP.
       IF SY-SUBRC NE 0.
*++S4HANA#01.
*         LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL.
         LOOP AT LT_LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL.
*--S4HANA#01.
           MOVE LW_BSEG-KUNNR TO W_BSEG_V-KUNNR.
           EXIT.
         ENDLOOP.
*      Write back vendor and customer
*      Write back vendor and customer
*++S4HANA#01.
*       MODIFY I_BSEG_V FROM W_BSEG_V TRANSPORTING LIFNR KUNNR
       MODIFY GT_I_BSEG_V FROM W_BSEG_V TRANSPORTING LIFNR KUNNR
*--S4HANA#01.
                     WHERE BUKRS = W_BKPF-BUKRS
                       AND BELNR = W_BKPF-BELNR
                       AND GJAHR = W_BKPF-GJAHR.
     ENDIF.
   ENDLOOP.
*--0001 2008.11.05 Balazs Gabor (Fmc)


 ENDFORM.                    " SEL_BKPF_BSEG
*&---------------------------------------------------------------------*
*&      Form  FILL_OUTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB[]  text
*      -->P_I_BSEG_V[]  text
*      -->P_I_BKPF[]  text
*      -->P_I_/ZAK/BSET[]  text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM FILL_OUTTAB USING   $OUTTAB LIKE I_OUTTAB[]
*                          $BSEG_V LIKE I_BSEG_V[]
*                          $BKPF   LIKE I_BKPF[]
*                          $BSET   LIKE I_/ZAK/BSET[].
 FORM FILL_OUTTAB USING  $BKPF   LIKE I_BKPF[]
                         $BSET   LIKE I_/ZAK/BSET[]
                CHANGING $OUTTAB LIKE I_OUTTAB[]
                         $BSEG_V LIKE GT_I_BSEG_V[].
*--S4HANA#01.

   DATA: L_HKONT     LIKE BSEG-HKONT,
         L_UPDATE(1) TYPE C.

   SORT $BSEG_V BY HKONT.

* Sign
* Sign
     AT END OF HKONT.
       L_UPDATE = 'X'.
     ENDAT.
     IF W_BSEG_V-SHKZG EQ C_H .
       W_BSEG_V-DMBTR = W_BSEG_V-DMBTR * -1 .
     ENDIF.
     READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
                           WITH KEY BUKRS = W_BSEG_V-BUKRS
                                    BELNR = W_BSEG_V-BELNR.
*                                    BUZEI = W_BSEG_V-BUZEI.
     IF SY-SUBRC EQ 0.
*++S4HANA#01.
*       IF W_/ZAK/BSET-BUPER IN R_BUPER.
       IF W_/ZAK/BSET-BUPER IN GT_BUPER.
* Normal
* Normal
         W_OUTTAB-/ZAK/NORMAL = W_OUTTAB-/ZAK/NORMAL + W_BSEG_V-DMBTR.
*++S4HANA#01.
*       ELSEIF W_/ZAK/BSET-BUPER < R_BUPER-LOW.
       ELSEIF W_/ZAK/BSET-BUPER < GS_BUPER-LOW.
* Self-revision
* Self-revision
         W_OUTTAB-/ZAK/ONREV = W_OUTTAB-/ZAK/ONREV + W_BSEG_V-DMBTR.
*++S4HANA#01.
*       ELSEIF W_/ZAK/BSET-BUPER > R_BUPER-LOW.
       ELSEIF W_/ZAK/BSET-BUPER > GS_BUPER-LOW.
* Not part of the return
* Not part of the return
         W_OUTTAB-/ZAK/JOVO = W_OUTTAB-/ZAK/JOVO + W_BSEG_V-DMBTR.
       ENDIF.
* Not part of the return
* Not part of the return
       W_OUTTAB-/ZAK/JOVO = W_OUTTAB-/ZAK/JOVO + W_BSEG_V-DMBTR.
     ENDIF.
     W_OUTTAB-/ZAK/SZAMIT = W_OUTTAB-/ZAK/SZAMIT + W_BSEG_V-DMBTR.
*++1865 #14.
*     W_OUTTAB-WAERS      = 'HUF'. " csak teszthez
     W_OUTTAB-WAERS      = V_WAERS.
*--1865 #14.
     W_OUTTAB-HKONT      = W_BSEG_V-HKONT.
* Monthly G/L balance from table GLT0
* Monthly G/L balance from table GLT0
       LOOP AT I_GLT0 INTO W_GLTO
            WHERE RYEAR EQ P_GJAHR AND
                  RACCT EQ W_BSEG_V-HKONT.
* define
*           L_NUM = L_NUM + 1.
*           IF L_NUM >= S_MONAT-LOW
*           AND L_NUM <= S_MONAT-HIGH.
         PRO_MONAT 01 .
         PRO_MONAT 02 .
         PRO_MONAT 03 .
         PRO_MONAT 04 .
         PRO_MONAT 05 .
         PRO_MONAT 06 .
         PRO_MONAT 07 .
         PRO_MONAT 08 .
         PRO_MONAT 09 .
         PRO_MONAT 10 .
         PRO_MONAT 11 .
         PRO_MONAT 12 .
         PRO_MONAT 13 .
         PRO_MONAT 14 .
         PRO_MONAT 15 .
         PRO_MONAT 16 .
*           ELSE.
*             CLEAR L_NUM.
*             EXIT.
*           ENDIF.
       ENDLOOP.
       W_OUTTAB-/ZAK/ELTERES = W_OUTTAB-/ZAK/SZAMIT -
                              W_OUTTAB-/ZAK/EGYENLEG.
       APPEND W_OUTTAB TO $OUTTAB.
       CLEAR: L_UPDATE, W_OUTTAB.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " FILL_OUTTAB
*&---------------------------------------------------------------------*
*&      Module  set_dynp9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_DYNP9000 OUTPUT.
   PERFORM SET9000_FIELDS.
 ENDMODULE.                 " set_dynp9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET9000_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET9000_FIELDS.
   F_BUTXT = P_BUTXT .
   T001-BUKRS = P_BUKRS.
   BKPF-GJAHR = P_GJAHR.
   BKPF-MONAT = S_MONAT-LOW.
   V_MON_HIGH = S_MONAT-HIGH.
 ENDFORM.                    " SET9000_FIELDS
*&---------------------------------------------------------------------*
*&      Form  VIEW_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VIEW_DETAIL .

   DATA: LI_ROWS TYPE LVC_T_ROW,
         LW_ROWS TYPE LVC_S_ROW.

   CALL METHOD V_GRID->GET_SELECTED_ROWS
     IMPORTING
       ET_INDEX_ROWS = LI_ROWS.
   DATA  L_LINE LIKE SY-TABIX.

*++S4HANA#01.
*   DESCRIBE TABLE LI_ROWS LINES L_LINE.
   L_LINE = LINES( LI_ROWS ).
*--S4HANA#01.

   IF L_LINE IS INITIAL.
*    Please select the row to process!
*    Please select the row to process!
     EXIT.
   ENDIF.

*++S4HANA#01.
*   REFRESH: R_HKONT.
   CLEAR: R_HKONT[].
*  Process the selected rows
*  Process the selected rows
   LOOP AT LI_ROWS INTO LW_ROWS.
     READ TABLE I_OUTTAB INTO W_OUTTAB INDEX LW_ROWS-INDEX.
     IF SY-SUBRC EQ 0.
       M_DEF R_HKONT 'I' 'EQ' W_OUTTAB-HKONT SPACE.
     ENDIF.
   ENDLOOP.
   IF SY-SUBRC EQ 0.
     PERFORM GET_ITEM_FOR_ALL.
   ENDIF.
   CALL SCREEN 9001.

 ENDFORM.                    " VIEW_DETAIL
*&---------------------------------------------------------------------*
*&      Form  fill_item_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILL_ITEM_ALL .

*++S4HANA#01.
*   REFRESH I_ITEM_ALL.
   CLEAR I_ITEM_ALL[].
*--S4HANA#01.

   SORT I_/ZAK/BSET BY BUKRS BELNR.

*    Populate the document table
*    Populate the document table
*++S4HANA#01.
*     LOOP AT I_BSEG_V INTO W_BSEG_V
     LOOP AT GT_I_BSEG_V INTO W_BSEG_V
*--S4HANA#01.
*      Sign
*      Sign
       IF W_BSEG_V-SHKZG EQ C_H .
         W_BSEG_V-DMBTR = W_BSEG_V-DMBTR * -1 .
       ENDIF.

       MOVE-CORRESPONDING W_BSEG_V TO W_ITEM.
*++1865 #14.
*       W_ITEM-WAERS = T001-WAERS.
       W_ITEM-WAERS = V_WAERS.
*--1865 #14.
       READ TABLE I_BKPF INTO W_BKPF
            WITH KEY BUKRS = P_BUKRS
                     BELNR = W_BSEG_V-BELNR
                     GJAHR = W_BSEG_V-GJAHR.
       IF SY-SUBRC EQ 0.
         W_ITEM-BUDAT = W_BKPF-BUDAT.
         W_ITEM-BLDAT = W_BKPF-BLDAT.
       ENDIF.
       READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
                           WITH KEY BUKRS = W_BSEG_V-BUKRS
                                    BELNR = W_BSEG_V-BELNR
*                                   BUZEI = W_BSEG_V-BUZEI
                                    BINARY SEARCH.
       IF SY-SUBRC EQ 0.
         W_ITEM-BUPER = W_/ZAK/BSET-BUPER.
*      Determine the tax date
*      Determine the tax date
*       SELECT SINGLE ADODAT INTO W_ITEM-ADODAT
*                            FROM ZMT_AD001_BKPF
*                           WHERE BUKRS = P_BUKRS
*                             AND BELNR = W_BSEG_V-BELNR
*                             AND GJAHR = W_BSEG_V-GJAHR.
       IF SY-SUBRC NE 0 OR W_ITEM-ADODAT IS INITIAL.
         MOVE W_ITEM-BLDAT TO W_ITEM-ADODAT.
*      VAT code
*      VAT code
*      Vendor code
*      Vendor code
*      Customer code
*      Customer code
*      Determine the ABEV code if a period exists
*      Determine the ABEV code if a period exists
*++S4HANA#01.
*       PERFORM GET_ABEVAZ USING  I_BTYPE
*                                 W_BSEG_V
*                                 W_ITEM
*                                 P_BUKRS.
       PERFORM GET_ABEVAZ USING  GS_I_BTYPE
                                 W_BSEG_V
                                 P_BUKRS
                        CHANGING W_ITEM.
*--S4HANA#01.
       APPEND W_ITEM TO I_ITEM_ALL.
       CLEAR W_ITEM.
     ENDLOOP.
   ENDLOOP.
 ENDFORM.                    " fill_item_all
*&---------------------------------------------------------------------*
*&      Form  GET_ITEM_FOR_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_ITEM_FOR_ALL .

*++S4HANA#01.
*   REFRESH I_ITEM.
   CLEAR I_ITEM[].
*--S4HANA#01.

   LOOP AT I_ITEM_ALL INTO W_ITEM WHERE HKONT IN R_HKONT.
     APPEND W_ITEM TO I_ITEM.
   ENDLOOP.

 ENDFORM.                    " GET_ITEM_FOR_ALL
*&---------------------------------------------------------------------*
*&      Form  GET_ABEVAZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BSEG_V  text
*      -->P_W_ITEM  text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM GET_ABEVAZ   USING   $I_BTYPE  LIKE I_BTYPE
*                           $W_BSEG_V TYPE T_BSEG_V
*                           $W_ITEM   TYPE /ZAK/EGYTETELALV
*                           $BUKRS.
 FORM GET_ABEVAZ   USING  $I_BTYPE  TYPE TS_I_BTYPE
                          $W_BSEG_V TYPE T_BSEG_V
                          $BUKRS TYPE T001-BUKRS
                 CHANGING $W_ITEM   TYPE /ZAK/EGYTETELALV.
*--S4HANA#01.

   DATA L_GJAHR TYPE GJAHR.
   DATA L_MONAT TYPE MONAT.
   DATA L_BTYPE TYPE /ZAK/BTYPE.
*++S4HANA#01.
*   DATA: BEGIN OF LI_ABEVS OCCURS 0,
*           ABEVAZ   TYPE /ZAK/ABEVAZ,
*           FOSOR    TYPE /ZAK/AFA_FOSOR,
*           ABEVTEXT TYPE /ZAK/ABEVTEXT,
*         END OF LI_ABEVS.
   TYPES: BEGIN OF TS_LI_ABEVS ,
            ABEVAZ   TYPE /ZAK/ABEVAZ,
            FOSOR    TYPE /ZAK/AFA_FOSOR,
            ABEVTEXT TYPE /ZAK/ABEVTEXT,
          END OF TS_LI_ABEVS .
   TYPES TT_LI_ABEVS TYPE STANDARD TABLE OF TS_LI_ABEVS .
   DATA: LS_LI_ABEVS TYPE TS_LI_ABEVS.
   DATA: LT_LI_ABEVS TYPE TT_LI_ABEVS.
*--S4HANA#01.
*  If a period is provided
*  If a period is provided
   CHECK NOT $W_ITEM-BUPER IS INITIAL.

*++S4HANA#01.
*   REFRESH LI_ABEVS.
   CLEAR LT_LI_ABEVS[].
*--S4HANA#01.


   L_GJAHR = $W_ITEM-BUPER(4).
   L_MONAT = $W_ITEM-BUPER+4(2).

*++S4HANA#01.
*   READ TABLE I_BTYPE WITH KEY GJAHR = L_GJAHR
   READ TABLE GT_I_BTYPE INTO GS_I_BTYPE WITH KEY GJAHR = L_GJAHR
*--S4HANA#01.
                                 MONAT = L_MONAT
                                 BINARY SEARCH.
*  Determine BTYPE
*  Determine BTYPE
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = $BUKRS
         I_BTYPART   = C_BTYPART_AFA
         I_GJAHR     = L_GJAHR
         I_MONAT     = L_MONAT
       IMPORTING
         E_BTYPE     = L_BTYPE
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
     IF SY-SUBRC NE 0.
       EXIT.
     ELSE.
*++S4HANA#01.
*       I_BTYPE-GJAHR = L_GJAHR.
*       I_BTYPE-MONAT = L_MONAT.
*       I_BTYPE-BTYPE = L_BTYPE.
*       APPEND I_BTYPE. SORT I_BTYPE.
       GS_I_BTYPE-GJAHR = L_GJAHR.
       GS_I_BTYPE-MONAT = L_MONAT.
       GS_I_BTYPE-BTYPE = L_BTYPE.
       APPEND GS_I_BTYPE TO GT_I_BTYPE. SORT GT_I_BTYPE.
*--S4HANA#01.
     ENDIF.
   ELSE.
*++S4HANA#01.
*     L_BTYPE = I_BTYPE-BTYPE.
     L_BTYPE = GS_I_BTYPE-BTYPE.
*--S4HANA#01.
   ENDIF.
*    Read VAT customer settings based on KTOSL
*    Read VAT customer settings based on KTOSL
     SELECT  /ZAK/AFA_CUST~ABEVAZ
             /ZAK/BEVALLB~FOSOR
             /ZAK/BEVALLBT~ABEVTEXT
*++S4HANA#01.
*              INTO CORRESPONDING FIELDS OF TABLE LI_ABEVS
              INTO CORRESPONDING FIELDS OF TABLE LT_LI_ABEVS
*--S4HANA#01.
              FROM /ZAK/AFA_CUST LEFT OUTER JOIN /ZAK/BEVALLB
                ON /ZAK/BEVALLB~BTYPE  = /ZAK/AFA_CUST~BTYPE
               AND /ZAK/BEVALLB~ABEVAZ = /ZAK/AFA_CUST~ABEVAZ
               LEFT OUTER JOIN /ZAK/BEVALLBT
                ON /ZAK/BEVALLBT~LANGU = SY-LANGU
               AND /ZAK/BEVALLBT~BTYPE  = /ZAK/AFA_CUST~BTYPE
               AND /ZAK/BEVALLBT~ABEVAZ = /ZAK/AFA_CUST~ABEVAZ
             WHERE /ZAK/AFA_CUST~BTYPE EQ L_BTYPE
               AND /ZAK/AFA_CUST~MWSKZ EQ $W_BSEG_V-MWSKZ
               AND /ZAK/AFA_CUST~KTOSL EQ $W_BSEG_V-KTOSL
               AND /ZAK/AFA_CUST~ATYPE EQ C_ATYPE_B.
*    Read VAT customer settings without KTOSL
*    Read VAT customer settings without KTOSL
       SELECT  /ZAK/AFA_CUST~ABEVAZ
               /ZAK/BEVALLB~FOSOR
               /ZAK/BEVALLBT~ABEVTEXT
*++S4HANA#01.
*                INTO CORRESPONDING FIELDS OF TABLE LI_ABEVS
                INTO CORRESPONDING FIELDS OF TABLE LT_LI_ABEVS
*--S4HANA#01.
                FROM /ZAK/AFA_CUST LEFT OUTER JOIN /ZAK/BEVALLB
                  ON /ZAK/BEVALLB~BTYPE  = /ZAK/AFA_CUST~BTYPE
                 AND /ZAK/BEVALLB~ABEVAZ = /ZAK/AFA_CUST~ABEVAZ
                 LEFT OUTER JOIN /ZAK/BEVALLBT
                  ON /ZAK/BEVALLBT~LANGU = SY-LANGU
                 AND /ZAK/BEVALLBT~BTYPE  = /ZAK/AFA_CUST~BTYPE
                 AND /ZAK/BEVALLBT~ABEVAZ = /ZAK/AFA_CUST~ABEVAZ
               WHERE /ZAK/AFA_CUST~BTYPE EQ L_BTYPE
                 AND /ZAK/AFA_CUST~MWSKZ EQ $W_BSEG_V-MWSKZ
                 AND /ZAK/AFA_CUST~ATYPE EQ C_ATYPE_B.
     ENDIF.
*++S4HANA#01.
*     READ TABLE LI_ABEVS WITH KEY FOSOR = 'X'.
     READ TABLE LT_LI_ABEVS INTO LS_LI_ABEVS WITH KEY FOSOR = 'X'.
*--S4HANA#01.
     IF SY-SUBRC EQ 0.
*++S4HANA#01.
*       MOVE LI_ABEVS-ABEVAZ   TO $W_ITEM-ABEVAZ.
*       MOVE LI_ABEVS-ABEVTEXT TO $W_ITEM-ABEVTEXT.
       MOVE LS_LI_ABEVS-ABEVAZ   TO $W_ITEM-ABEVAZ.
       MOVE LS_LI_ABEVS-ABEVTEXT TO $W_ITEM-ABEVTEXT.
*--S4HANA#01.
     ENDIF.
   ENDIF.
 ENDFORM.                    " GET_ABEVAZ
*&---------------------------------------------------------------------*
*&      Form  GRID_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GRID_DISPLAY .
* Build field catalog
* Build field catalog
   PERFORM BUILD_FIELDCAT USING    '9000'
                          CHANGING I_FIELDCAT.

   V_LAYOUT-CWIDTH_OPT = 'X'.
   V_LAYOUT-SEL_MODE = 'A'.

   CLEAR V_VARIANT.
   V_VARIANT-REPORT = V_REPID.

   CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
     EXPORTING
*      I_INTERFACE_CHECK      = ' '
*      I_BYPASSING_BUFFER     =
*      I_BUFFER_ACTIVE        =
       I_CALLBACK_PROGRAM     = '/ZAK/AFA_EGYEZTETO'
*      I_CALLBACK_PF_STATUS_SET          = ' '
*      I_CALLBACK_USER_COMMAND           = ' '
       I_CALLBACK_TOP_OF_PAGE = 'TOP_OF_PAGE'
*      I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*      I_CALLBACK_HTML_END_OF_LIST       = ' '
*      I_STRUCTURE_NAME       = ' '
*      I_BACKGROUND_ID        = ' '
*      I_GRID_TITLE           =
*      I_GRID_SETTINGS        =
       IS_LAYOUT_LVC          = V_LAYOUT
       IT_FIELDCAT_LVC        = I_FIELDCAT
*      IT_EXCLUDING           =
*      IT_SPECIAL_GROUPS_LVC  =
*      IT_SORT_LVC            =
*      IT_FILTER_LVC          =
*      IT_HYPERLINK           =
*      IS_SEL_HIDE            =
       I_DEFAULT              = 'X'
       I_SAVE                 = 'A'
       IS_VARIANT             = V_VARIANT
*      IT_EVENTS              =
*      IT_EVENT_EXIT          =
*      IS_PRINT_LVC           =
*      IS_REPREP_ID_LVC       =
*      I_SCREEN_START_COLUMN  = 0
*      I_SCREEN_START_LINE    = 0
*      I_SCREEN_END_COLUMN    = 0
*      I_SCREEN_END_LINE      = 0
*      I_HTML_HEIGHT_TOP      =
*      I_HTML_HEIGHT_END      =
*      IT_EXCEPT_QINFO_LVC    =
*      IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*      E_EXIT_CAUSED_BY_CALLER           =
*      ES_EXIT_CAUSED_BY_USER =
     TABLES
       T_OUTTAB               = I_OUTTAB
     EXCEPTIONS
       PROGRAM_ERROR          = 1
       OTHERS                 = 2.
   IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " GRID_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TOP_OF_PAGE .
* Header data
* Header data
   DATA: LI_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
   DATA: L_LINE TYPE SLIS_LISTHEADER.
* Provide header
* Provide header
   CLEAR L_LINE.
   L_LINE-TYP  = 'H'.
   WRITE 'ÁFA egyeztető lista'(021) TO L_LINE-INFO CENTERED.
   APPEND L_LINE TO LI_LIST_TOP_OF_PAGE.
   CLEAR L_LINE.
   L_LINE-TYP  = 'S'.
   L_LINE-KEY  = 'Oldal:'(025).
   WRITE SY-PAGNO TO L_LINE-INFO RIGHT-JUSTIFIED.
   APPEND L_LINE TO LI_LIST_TOP_OF_PAGE.
   CLEAR L_LINE.
   L_LINE-TYP  = 'S'.
   L_LINE-KEY  = 'Vállalat:'(022).
   L_LINE-INFO =  P_BUKRS.
   APPEND L_LINE TO LI_LIST_TOP_OF_PAGE.
   CLEAR L_LINE.
   L_LINE-TYP  = 'S'.
   L_LINE-KEY  = 'Év:'(023).
   L_LINE-INFO =  P_GJAHR.
   APPEND L_LINE TO LI_LIST_TOP_OF_PAGE.
   CLEAR L_LINE.
   L_LINE-TYP  = 'S'.
   L_LINE-KEY  = 'Hónap:'(024).
   IF S_MONAT-HIGH IS INITIAL.
     L_LINE-INFO =  S_MONAT-LOW.
   ELSE.
     CONCATENATE S_MONAT-LOW S_MONAT-HIGH INTO L_LINE-INFO
                                     SEPARATED BY '-'.
   ENDIF.
   APPEND L_LINE TO LI_LIST_TOP_OF_PAGE.
   L_LINE-TYP  = 'S'.
   L_LINE-KEY  = 'Készült:'(026).
   CONCATENATE SY-DATUM SY-UZEIT SY-UNAME INTO L_LINE-INFO
                                 SEPARATED BY '/'.
   APPEND L_LINE TO LI_LIST_TOP_OF_PAGE.

   CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
     EXPORTING
       IT_LIST_COMMENTARY = LI_LIST_TOP_OF_PAGE.


 ENDFORM.                    " top_of_page
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_DATA .

   CHECK NOT SY-BATCH IS INITIAL AND P_LOAD IS INITIAL.

   DELETE FROM /ZAK/EGY_FEJ WHERE BUKRS = P_BUKRS.
   DELETE FROM /ZAK/EGY_TETEL WHERE BUKRS = P_BUKRS.

   LOOP AT I_OUTTAB INTO W_OUTTAB.
     CLEAR W_/ZAK/EGY_FEJ.
     MOVE-CORRESPONDING W_OUTTAB TO W_/ZAK/EGY_FEJ.
     MOVE P_BUKRS TO W_/ZAK/EGY_FEJ-BUKRS.
     MOVE P_GJAHR TO W_/ZAK/EGY_FEJ-GJAHR.
     MOVE S_MONAT-LOW  TO W_/ZAK/EGY_FEJ-MONAT_FROM.
     MOVE S_MONAT-HIGH TO W_/ZAK/EGY_FEJ-MONAT_TO.
     MOVE SY-TABIX TO W_/ZAK/EGY_FEJ-TETEL.
     APPEND W_/ZAK/EGY_FEJ TO I_/ZAK/EGY_FEJ.
   ENDLOOP.

   LOOP AT I_ITEM_ALL INTO W_ITEM.
     CLEAR W_/ZAK/EGY_TETEL.
     MOVE-CORRESPONDING W_ITEM TO W_/ZAK/EGY_TETEL.
     MOVE P_BUKRS TO W_/ZAK/EGY_TETEL-BUKRS.
     MOVE P_GJAHR TO W_/ZAK/EGY_TETEL-FJAHR.
     MOVE S_MONAT-LOW  TO W_/ZAK/EGY_TETEL-MONAT_FROM.
     MOVE S_MONAT-HIGH TO W_/ZAK/EGY_TETEL-MONAT_TO.
     MOVE SY-TABIX TO W_/ZAK/EGY_TETEL-TETEL.
     APPEND W_/ZAK/EGY_TETEL TO I_/ZAK/EGY_TETEL.
   ENDLOOP.

   INSERT  /ZAK/EGY_FEJ   FROM TABLE I_/ZAK/EGY_FEJ.
   INSERT  /ZAK/EGY_TETEL FROM TABLE I_/ZAK/EGY_TETEL.

   COMMIT WORK AND WAIT.

   FREE: I_/ZAK/EGY_FEJ, I_/ZAK/EGY_TETEL.

 ENDFORM.                    " SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  LOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM LOAD_DATA USING $SUBRC.
 FORM LOAD_DATA CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

   CLEAR $SUBRC.
   SELECT * INTO TABLE I_/ZAK/EGY_FEJ
            FROM /ZAK/EGY_FEJ
           WHERE BUKRS EQ P_BUKRS
             AND GJAHR EQ P_GJAHR
             AND MONAT_FROM EQ S_MONAT-LOW
             AND MONAT_TO   EQ S_MONAT-HIGH.
   IF SY-SUBRC NE 0.
     MOVE SY-SUBRC TO $SUBRC.
     EXIT.
   ENDIF.

   SELECT * INTO TABLE I_/ZAK/EGY_TETEL
            FROM /ZAK/EGY_TETEL
           WHERE BUKRS EQ P_BUKRS
             AND FJAHR EQ P_GJAHR
             AND MONAT_FROM EQ S_MONAT-LOW
             AND MONAT_TO   EQ S_MONAT-HIGH.

   LOOP AT I_/ZAK/EGY_FEJ INTO W_/ZAK/EGY_FEJ.
     MOVE-CORRESPONDING W_/ZAK/EGY_FEJ TO W_OUTTAB.
     APPEND W_OUTTAB TO I_OUTTAB.
   ENDLOOP.

   LOOP AT I_/ZAK/EGY_TETEL INTO W_/ZAK/EGY_TETEL.
     MOVE-CORRESPONDING W_/ZAK/EGY_TETEL TO W_ITEM.
     APPEND W_ITEM TO I_ITEM_ALL.
   ENDLOOP.

   FREE: I_/ZAK/EGY_FEJ, I_/ZAK/EGY_TETEL.

 ENDFORM.                    " LOAD_DATA
