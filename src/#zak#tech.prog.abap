*&---------------------------------------------------------------------*
*& Program: Configuring technical data related to the tax return,
*&          managing statuses
*&---------------------------------------------------------------------*
 REPORT /ZAK/TECH MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: Based on the conditions specified on the selection screen
*& the program extracts data from SAP documents and stores them in
*& /ZAK/ANALITIKA.
*&---------------------------------------------------------------------*
*& Author: Károly Dénes - FMC
*& Creation date: 26.01.2006
*& Func.spec.maker: ________
*& SAP module name : ADO
*& Program type: Report
*& SAP version : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (The number of the OSS note must be written at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION       TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001 2008/04/07 Balázs G. ONYB selection can be deleted
*& 0002 14.09.2011 Balázs G. Group company management
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
 TABLES: BKPF,
         /ZAK/ANALITIKA_S,
         T001,
         DD02L.

*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
 TYPE-POOLS: SLIS.
*&---------------------------------------------------------------------*
*& CONSTANTS (C_XXXXXXX..) *
*&---------------------------------------------------------------------*
 CONSTANTS: C_CLASS       TYPE DD02L-TABCLASS VALUE 'INTTAB',
            C_A           TYPE C VALUE 'A',
* file types
            C_FILE_XLS(2) TYPE C VALUE   '02',
            C_FILE_TXT(2) TYPE C VALUE   '01',
            C_FILE_XML(2) TYPE C VALUE   '03',
            C_FILE_SAP(2) TYPE C VALUE   '04',
* excel for loading
            C_END_ROW     TYPE I VALUE '65536',
            C_BEGIN_ROW   TYPE I VALUE    '1',
* file check
            C_FILE_X(1)   TYPE C VALUE    'X'.
*
*           C_KOTEL       TYPE /ZAK/KOTEL VALUE 'K',
*           C_KOTEL_T     TYPE /ZAK/KOTEL VALUE 'T'
*++PTGSZLAA #04. 2014.04.28
 CONSTANTS C_PTGSZLAA TYPE /ZAK/BTYPE VALUE 'PTGSZLAA'.
*--PTGSZLAA #04. 2014.04.28

*&---------------------------------------------------------------------*
*& Workspace (W_XXX..) *
*&---------------------------------------------------------------------*
* structure control
 DATA: W_DD02L TYPE DD02L.
* excel for loading
 DATA: W_XLS   TYPE ALSMEX_TABLINE,
       W_DD03P TYPE DD03P,
       W_LINE  TYPE LINE.

 DATA: W_OUTTAB  TYPE /ZAK/ANALITIKA,
       W_BEVALLI TYPE /ZAK/BEVALLI,
       W_ELSO    TYPE /ZAK/BEVALLI,
       W_SZJA001 TYPE /ZAK/SZJA_001.
* message
 DATA:  W_MESSAGE  TYPE BAPIRET2.

* data structure error
 DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.


 DATA: BEGIN OF GT_OUTTAB OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
         DATA: LIGHT TYPE C.
 DATA: END OF GT_OUTTAB.
 DATA: G_LIGHTS_NAME TYPE LVC_CIFNM VALUE 'LIGHT'.
*&---------------------------------------------------------------------*
*& INTERNAL TABLES (I_XXXXXXX..) *
*& BEGIN OF I_TAB OCCURS .... *
*&              .....                                                  *
*& END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
 DATA: I_XLS   TYPE STANDARD TABLE OF ALSMEX_TABLINE
                                                     INITIAL SIZE 0,
       I_DD03P TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0.

 DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
* reporting periods
 DATA: I_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0,
       I_ELSO    TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0.
* Error data structure table
 DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
* data structures
 DATA: I_SZJA001 TYPE STANDARD TABLE OF /ZAK/SZJA_001 INITIAL SIZE 0.

 DATA: I_LINE TYPE STANDARD TABLE OF LINE            INITIAL SIZE 0.

 DATA: E_MESSAGE TYPE STANDARD TABLE OF BAPIRET2     INITIAL SIZE 0.
*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Series (Range) - (R_xxx...) *
*      Global variables - (V_xxx...) *
*      Work area - (W_xxx...) *
*      Type - (T_xxx...) *
*      Macros - (M_xxx...) *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class - (CL_xxx...) *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
 DATA: V_WRBTR       LIKE BSEG-WRBTR,
       V_WRBTR_C(16).

 DATA: V_DATUM      LIKE SY-DATUM,
       V_DATUMC(10) TYPE C.

 DATA: V_TABIX LIKE SY-TABIX,
       V_SUBRC LIKE SY-SUBRC.
*++ BG 2006.03.28
 DATA: V_TABNAME TYPE TABNAME.
*-- BG 2006.03.28

* variables
 DATA: V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.
 DATA: V_LAST_DATE TYPE DATUM.

* selection screen
 DATA: V_BUTXT   LIKE T001-BUTXT.

 DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
       V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.
* excel for loading
 DATA: V_BEGIN_COL TYPE I,
       V_END_COL   TYPE I.
* screen
 DATA: V_SCR1(70) TYPE C,
       V_SCR2(70) TYPE C,
       V_SCR3(70) TYPE C,
       V_SCR4(70) TYPE C.
* ALV treatment variables
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
       V_DYNDOC_ID         TYPE REF TO CL_DD_DOCUMENT,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER,
       V_STRUC             TYPE DD02L-TABNAME.
* for a popup message
 DATA: V_TEXT1(40) TYPE C,
       V_TEXT2(40) TYPE C,
       V_TITEL     TYPE C,
       V_ANSWER,
       V_OK.
* file check
 DATA: LV_ACTIVE TYPE ABAP_BOOL.
* dynpro fields
 DATA: RADIO1(1) TYPE C,
       RADIO2(1) TYPE C.
* company, business type designation
 DATA: F_BUTXT LIKE T001-BUTXT,
       F_BTEXT LIKE /ZAK/ANALITIKA_S-BTEXT,
       C_BUTXT LIKE T001-BUTXT,
       C_BTEXT LIKE /ZAK/ANALITIKA_S-BTEXT.
* date on the copy screen
 DATA: V_DATBI(20) TYPE C,
       V_DATBI_T   LIKE /ZAK/BEVALL-DATBI,
       V_DATAB(20) TYPE C,
       V_DATAB_T   LIKE /ZAK/BEVALL-DATAB.
* released obligation
 DATA: V_FULL(1) TYPE C.

*++0002 BG 2011.09.20
 DATA V_BUKCS_FLAG TYPE XFELD.     "Group company relevant flag
 DATA V_BUKCS      TYPE /ZAK/BUKCS. "Group company

 DATA I_BUKRS TYPE STANDARD TABLE OF /ZAK/AFACS_BUKRS INITIAL SIZE 0
                                                     WITH HEADER LINE.
 RANGES R_BUKRS FOR /ZAK/AFACS_BUKRS-BUKRS.

 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   COLLECT &1.
 END-OF-DEFINITION.

*--0002 BG 2011.09.20


*&---------------------------------------------------------------------*
*& PARAMETERS  (P_XXXXXXX..)                                            *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SELECT-OPTIONS (S_XXXXXXX..)                                         *
*&---------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.

 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-A01.
*++1665 #03.
* PARAMETERS: P_BUKRS  LIKE T001-BUKRS OBLIGATORY.
 PARAMETERS: P_BUKRS  LIKE T001-BUKRS OBLIGATORY MEMORY ID BUK.
*--1665 #03.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID OUT.
 SELECTION-SCREEN END OF LINE.

 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-A03.
 PARAMETERS: P_BPART  LIKE /ZAK/BEVALL-BTYPART .
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BTTEXT(40) TYPE C MODIF ID OUT.
 SELECTION-SCREEN END OF LINE.

 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-A02.
 PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE .
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID OUT.
 SELECTION-SCREEN END OF LINE.



 SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
 PARAMETERS: P_ELENG RADIOBUTTON GROUP RA01 DEFAULT 'X'
                         USER-COMMAND ENTER,
             P_NYOMT RADIOBUTTON GROUP RA01,
             P_APEH  RADIOBUTTON GROUP RA01,
             P_PACK  RADIOBUTTON GROUP RA01,
             P_MASOL RADIOBUTTON GROUP RA01,
             P_DELE  RADIOBUTTON GROUP RA01.
*             P_TESZT AS CHECKBOX DEFAULT 'X'.
 SELECTION-SCREEN END OF BLOCK B02.
 SELECTION-SCREEN END OF BLOCK B01.

 RANGES: R_MONAT FOR /ZAK/ANALITIKA-MONAT.

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


     CLASS-METHODS:
       HANDLE_TOOLBAR
                   FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
         IMPORTING E_OBJECT E_INTERACTIVE,

       HANDLE_USER_COMMAND
                   FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
         IMPORTING E_UCOMM.

   PRIVATE SECTION.

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
 CLASS  LCL_EVENT_RECEIVER IMPLEMENTATION.

   METHOD HANDLE_TOOLBAR.
* append a separator to normal toolbar
     CLEAR V_TOOLBAR.
     MOVE 1 TO V_TOOLBAR-BUTN_TYPE.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* append a menut o switch between detail levels.
     CLEAR V_TOOLBAR.
     MOVE '/ZAK/HIBA' TO V_TOOLBAR-FUNCTION.
* --> This function code is evaluated in 'handle_menu_button'
     MOVE ICON_DISPLAY TO V_TOOLBAR-ICON.
     MOVE 'Hibanapló' TO V_TOOLBAR-QUICKINFO.
     MOVE 'Hibanapló' TO V_TOOLBAR-TEXT.
     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
     MOVE SPACE TO V_TOOLBAR-DISABLED.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
   ENDMETHOD.                    "HANDLE_TOOLBAR

*-------------------------------------------------------------------
   METHOD HANDLE_USER_COMMAND.
* § 3.In event handler method for event USER_COMMAND: Query your
*   function codes defined in step 2 and react accordingly.

     DATA: I_ROWS TYPE LVC_T_ROW,
           W_ROWS TYPE LVC_S_ROW,
           S_OUT  TYPE /ZAK/ANALITIKA.

     CASE E_UCOMM.
* Display analytics
       WHEN '/ZAK/HIBA'.
         IF I_HIBA[] IS INITIAL.
           MESSAGE I005 .
         ELSE.
           CALL SCREEN 9001.
         ENDIF.
     ENDCASE.
   ENDMETHOD.                           "handle_user_command
**-----------------------------------------------------------------
*
 ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================



*-----------------------------------------------------------------------
*       INITIALIZATION
*-----------------------------------------------------------------------
 INITIALIZATION.
* designations
   PERFORM FIELD_DESCRIPT.
*++1765 #19.
* Eligibility check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2265 #02.
*                  ID 'TCD'  FIELD SY-TCODE.
                   ID 'TCD'  FIELD '/ZAK/TECH'.
*--2265 #02.
*++1865 #03.
*  IF SY-SUBRC NE 0.
   IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
     MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
   ENDIF.
*--1765 #19.

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
 AT SELECTION-SCREEN.
* designations
   PERFORM FIELD_DESCRIPT.
   PERFORM CHECK_SEL_SCREEN.
* Check selector switch!
 AT SELECTION-SCREEN ON RADIOBUTTON GROUP RA01.
* declaration type, declaration type is mandatory
   PERFORM CHECK_BTYPE_BPART.
************************************************************************
* AT SELECTION-SCREEN output
************************************************************************
 AT SELECTION-SCREEN OUTPUT.
   PERFORM MODIF_SCREEN.

************************************************************************
* START-OF-SELECTION
************************************************************************
 START-OF-SELECTION.
* Eligibility check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BPART
                                 C_ACTVT_01.
* General declaration data
   PERFORM READ_BEVALL USING P_BUKRS
                             P_BTYPE.
* Declaration data service setting
   PERFORM READ_BEVALLC USING P_BUKRS
                              P_BTYPE.
* Declaration data service data
   PERFORM READ_BEVALLD USING P_BUKRS
                              P_BTYPE.
* Declaration form data
   PERFORM READ_BEVALLB USING P_BTYPE.
* tax codes table
   PERFORM READ_ADONEM USING P_BUKRS.
*++0002 BG 2011.09.20
*  Group company definition
   PERFORM GET_CS_BUKRS TABLES I_BUKRS
                               R_BUKRS
                         USING P_BUKRS
                               V_BUKCS_FLAG
                               V_BUKCS
                               P_BTYPE.
*--0002 BG 2011.09.20

************************************************************************
* END-OF-SELECTION
************************************************************************
 END-OF-SELECTION.

* released obligation
   IF NOT P_ELENG IS INITIAL.
     PERFORM CALL_9003.
* copying declaration data
   ELSEIF NOT P_MASOL IS INITIAL.
*++0002 BG 2011.09.20
     IF NOT V_BUKCS IS INITIAL.
       MESSAGE I297 WITH V_BUKCS.
       EXIT.
*   This function is only allowed for group companies (&)!
     ELSE.
       PERFORM CALL_9000.
     ENDIF.
* Print closure
   ELSEIF NOT P_NYOMT IS INITIAL.
*++1565 #03.
**++0002 BG 2011.09.20
*     IF NOT V_BUKCS IS INITIAL.
*       MESSAGE I297 WITH V_BUKCS.
*       EXIT.
** This function is only allowed for group companies (&)!
*     ELSE.
**--0002 BG 2011.09.20
*--1565 #03.
     PERFORM CALL_9001.
*++1565 #03.
**++0002 BG 2011.09.20
*     ENDIF.
**--0002 BG 2011.09.20
*--1565 #03.
* Period audited by APEH
   ELSEIF NOT P_APEH IS INITIAL .
*++1565 #03.
**++0002 BG 2011.09.20
*     IF NOT V_BUKCS IS INITIAL.
*       MESSAGE I297 WITH V_BUKCS.
*       EXIT.
** This function is only allowed for group companies (&)!
*     ELSE.
**--0002 BG 2011.09.20
*--1565 #03.
     PERFORM CALL_POPUP CHANGING V_OK.
     IF NOT V_OK IS INITIAL.
       CALL SCREEN 9002.
     ENDIF.
*++1565 #03.
**++0002 BG 2011.09.20
*   ENDIF.
**--0002 BG 2011.09.20
*--1565 #03.
* Delete printout
   ELSEIF NOT P_DELE IS INITIAL.
*++1565 #03.
**++0002 BG 2011.09.20
*     IF NOT V_BUKCS_FLAG IS INITIAL.
*       MESSAGE I296.
** This function is not allowed at group companies!
*     ELSE.
**--0002 BG 2011.09.20
*--1565 #03.
     PERFORM CALL_POPUP CHANGING V_OK.
     IF NOT V_OK IS INITIAL.
       PERFORM DELETE_CUST_TABLE.
     ENDIF.
*++1565 #03.
*     ENDIF.
*--1565 #03.
* Delete upload ID
   ELSEIF NOT P_PACK IS INITIAL.
*++1565 #03.
**++0002 BG 2011.09.20
*   IF NOT V_BUKCS_FLAG IS INITIAL.
*     MESSAGE I296.
** This function is not allowed at group companies!
*   ELSE.
**--0002 BG 2011.09.20
*--1565 #03.
     PERFORM CALL_9004.
*++1565 #03.
**++0002 BG 2011.09.20
*   ENDIF.
**--0002 BG 2011.09.20
*--1565 #03.

   ENDIF.

************************************************************************
* ALPROGRAMOK
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  FIELD_DESCRIPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FIELD_DESCRIPT.
   IF NOT P_BUKRS IS INITIAL.
     SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
                         WHERE BUKRS = P_BUKRS.
   ENDIF.

   IF NOT P_BTYPE IS INITIAL.
     SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
         WHERE LANGU = SY-LANGU
           AND BUKRS = P_BUKRS
           AND BTYPE = P_BTYPE.
   ENDIF.
   IF NOT P_BPART IS INITIAL.
     SELECT SINGLE DDTEXT INTO P_BTTEXT FROM DD07T
        WHERE DOMNAME = '/ZAK/BTYPART'
          AND DDLANGUAGE = SY-LANGU
          AND DOMVALUE_L = P_BPART.
   ENDIF.
 ENDFORM.                    " FIELD_DESCRIPT
*
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
*& Module pbo9000 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9000 OUTPUT.
   PERFORM SET_STATUS.
 ENDMODULE.                 " pbo9000  OUTPUT
*&---------------------------------------------------------------------*
*& Module pbo9010 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9010 OUTPUT.

 ENDMODULE.                 " pbo9010  OUTPUT
*&---------------------------------------------------------------------*
*& Module pai9010 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PAI9010 INPUT.

 ENDMODULE.                 " pai9010  INPUT
*&---------------------------------------------------------------------*
*& Module mod_screen OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE MOD_SCREEN OUTPUT.

 ENDMODULE.                 " mod_screen  OUTPUT
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
* copying
   IF SY-DYNNR = '9000'.
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9000'.
   ELSEIF SY-DYNNR EQ '9001'.
* form closure
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9001'.
   ELSEIF SY-DYNNR EQ '9002'.
* form closure
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9002'.
   ELSEIF SY-DYNNR EQ '9003'.
* form closure
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9003'.
   ELSEIF SY-DYNNR EQ '9004'.
* delete upload ID
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9004'.
   ELSEIF SY-DYNNR EQ '9005'.
* cancellation of form
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9005'.
   ENDIF.
 ENDFORM.                    " set_status
*&---------------------------------------------------------------------*
*& Module set_dynp9000 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_DYNP9000 OUTPUT.
   PERFORM SET9000_FIELDS.
 ENDMODULE.                 " set_dynp9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  set9000_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET9000_FIELDS.
***********************************************************- source
   PERFORM SET_BUTXT_BTEXT.
******************************************************* goal
* Company name
   SELECT SINGLE BUTXT INTO C_BUTXT FROM  T001
          WHERE  BUKRS  = /ZAK/BEVALL-BUKRS.

* Declaration type designation
   SELECT SINGLE BTEXT INTO C_BTEXT FROM  /ZAK/BEVALLT
          WHERE  LANGU  = SY-LANGU
          AND    BTYPE  = /ZAK/BEVALL-BTYPE.
* valid period of declaration type!
   IF V_DATBI_T IS INITIAL.
     SELECT SINGLE DATBI DATAB INTO (V_DATBI_T ,V_DATAB_T)
            FROM /ZAK/BEVALL
            WHERE BUKRS EQ P_BUKRS AND
                  BTYPE EQ P_BTYPE AND
                  DATBI >= SY-DATUM AND
                  DATAB <= SY-DATUM.
   ELSE.
     SELECT SINGLE DATBI DATAB INTO (V_DATBI_T, V_DATAB_T)
            FROM /ZAK/BEVALL
            WHERE BUKRS EQ P_BUKRS AND
                  BTYPE EQ P_BTYPE AND
                  DATBI = V_DATBI_T.

   ENDIF.
 ENDFORM.                    " set9000_fields
*&---------------------------------------------------------------------*
*& Form read_declare
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM READ_BEVALL USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                           $BTYPE LIKE /ZAK/BEVALL-BTYPE.
   REFRESH I_/ZAK/BEVALL.

   SELECT * INTO TABLE I_/ZAK/BEVALL FROM /ZAK/BEVALL
       WHERE BUKRS EQ $BUKRS AND
             BTYPE EQ $BTYPE.

   REFRESH I_/ZAK/BEVALLT.

   SELECT * INTO TABLE I_/ZAK/BEVALLT FROM /ZAK/BEVALLT
       WHERE BUKRS EQ $BUKRS AND
             BTYPE EQ $BTYPE.

 ENDFORM.                    " read_bevallb
*&---------------------------------------------------------------------*
*& Form read_devallc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM READ_BEVALLC USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                            $BTYPE LIKE /ZAK/BEVALL-BTYPE.
   REFRESH I_/ZAK/BEVALLC.

   SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
       WHERE BTYPE EQ $BTYPE.

 ENDFORM.                    " read_bevallc
*&---------------------------------------------------------------------*
*& Form read_declare
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM READ_BEVALLD USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                            $BTYPE LIKE /ZAK/BEVALL-BTYPE.
   REFRESH I_/ZAK/BEVALLD.

   SELECT * INTO TABLE I_/ZAK/BEVALLD FROM /ZAK/BEVALLD
       WHERE BUKRS EQ $BUKRS AND
             BTYPE EQ $BTYPE.

   REFRESH I_/ZAK/BEVALLDT.

   SELECT * INTO TABLE I_/ZAK/BEVALLDT FROM /ZAK/BEVALLDT
       WHERE BUKRS EQ $BUKRS AND
             BTYPE EQ $BTYPE.

 ENDFORM.                    " read_bevalld
*&---------------------------------------------------------------------*
*&      Form  call_9000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_9000.
   CALL SCREEN 9000.
 ENDFORM.                                                   " call_9000
*&---------------------------------------------------------------------*
*& Module check_inp INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_INP INPUT.
* check the target data when copying!
   PERFORM COPY_CHECK.
 ENDMODULE.                 " check_inp  INPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_9000 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9000 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'COPY'.
* check the content of admit boards!
       PERFORM COPY_CHECK.
* declaration custom tables update
*++ BG 2006.03.28
*       CLEAR V_TABIX.
*       PERFORM BEVALL_UPD CHANGING V_TABIX.
*       IF V_TABIX IS INITIAL.
*         MESSAGE I072.
*       ELSE.
**         message
*       ENDIF.
       CLEAR V_TABNAME.
       PERFORM BEVALL_UPD CHANGING V_TABNAME.
       IF V_TABNAME IS INITIAL.
         MESSAGE I072.
       ELSE.
         MESSAGE I153 WITH V_TABNAME.
*        Error & table copying! Copy complete!
       ENDIF.
*-- BG 2006.03.28

       SET SCREEN 0.
       LEAVE SCREEN.
   ENDCASE.
 ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_9001 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9001 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'LOCK'.
       PERFORM LOCK_BEVALLI USING 'Z' 'T'
                            CHANGING V_TABIX.

       SET SCREEN 0.
       LEAVE SCREEN.
     WHEN OTHERS.
   ENDCASE.
 ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9002 OUTPUT.
* PBO controlled by APEH
   PERFORM SET_STATUS.
 ENDMODULE.                 " STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_9002 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9002 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'LOCKM'.
       PERFORM CALL_POPUP CHANGING V_OK.
       IF NOT V_OK IS INITIAL.
         PERFORM LOCK_BEVALLIX USING 'X'
                               CHANGING V_TABIX.
         SET SCREEN 0.
         LEAVE SCREEN.
       ENDIF.
     WHEN OTHERS.
   ENDCASE.
 ENDMODULE.                 " USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*&      Form  call_9001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_9001.
   CALL SCREEN 9001.
 ENDFORM.                                                   " call_9001
*&---------------------------------------------------------------------*
*&      Form  copy_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM COPY_CHECK.
   IF NOT /ZAK/BEVALL-BUKRS IS INITIAL AND
      NOT /ZAK/BEVALL-BTYPE IS INITIAL.
* General declaration data
     CLEAR W_/ZAK/BEVALL.
     SELECT SINGLE *  INTO W_/ZAK/BEVALL FROM  /ZAK/BEVALL
         WHERE     BUKRS EQ /ZAK/BEVALL-BUKRS AND
                   BTYPE EQ /ZAK/BEVALL-BTYPE .
     IF SY-SUBRC EQ 0.
       SET CURSOR FIELD /ZAK/BEVALL-BTYPE.
       MESSAGE E046(/ZAK/ZAK) .
     ENDIF.
* Declaration data service data
     CLEAR W_/ZAK/BEVALLD.
     SELECT SINGLE *  INTO W_/ZAK/BEVALLD FROM  /ZAK/BEVALLD
         WHERE     BUKRS EQ /ZAK/BEVALL-BUKRS AND
                   BTYPE EQ /ZAK/BEVALL-BTYPE .
     IF SY-SUBRC EQ 0.
       SET CURSOR FIELD /ZAK/BEVALL-BTYPE.
       MESSAGE E046(/ZAK/ZAK) .
     ENDIF.
* Declaration data service setting
     CLEAR W_/ZAK/BEVALLC.
     SELECT SINGLE *  INTO W_/ZAK/BEVALLC FROM  /ZAK/BEVALLC
         WHERE BTYPE EQ /ZAK/BEVALL-BTYPE .
     IF SY-SUBRC EQ 0.
       SET CURSOR FIELD /ZAK/BEVALL-BTYPE.
       MESSAGE E046(/ZAK/ZAK) .
     ENDIF.
* Declaration form data
*     CLEAR W_/ZAK/ADMITTED.
*     SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
*         WHERE BTYPE EQ /ZAK/BEVALL-BTYPE .
*     IF SY-SUBRC NE 0.
*       MESSAGE E046(/ZAK/ZAK) .
*     ENDIF.
   ENDIF.
   IF NOT /ZAK/BEVALL-BUKRS IS INITIAL.
     SELECT SINGLE * FROM T001 WHERE BUKRS EQ /ZAK/BEVALL-BUKRS.
     IF SY-SUBRC NE 0.
       MESSAGE E068 WITH /ZAK/BEVALL-BUKRS.
     ENDIF.
   ENDIF.
   IF  /ZAK/BEVALL-DATBI < /ZAK/BEVALL-DATAB.
     SET CURSOR FIELD /ZAK/BEVALL-DATBI.
     MESSAGE E071.
   ENDIF.
 ENDFORM.                    " copy_check
*&---------------------------------------------------------------------*
*& Form declare_upd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM BEVALL_UPD CHANGING
*++ BG 2006.03.28
*                         $TABIX LIKE SY-TABIX.
                          $TABNAME.
*-- BG 2006.03.28
   DATA: W_UPD_BEVALL   LIKE /ZAK/BEVALL,
         W_UPD_BEVALLT  LIKE /ZAK/BEVALLT,
         W_UPD_BEVALLC  LIKE /ZAK/BEVALLC,
         W_UPD_BEVALLD  LIKE /ZAK/BEVALLD,
         W_UPD_BEVALLDT LIKE /ZAK/BEVALLDT,
         W_UPD_BEVALLB  LIKE /ZAK/BEVALLB,
         W_UPD_BEVALLBT LIKE /ZAK/BEVALLBT.

*++ BG 2006.03.28
   DATA W_UPD_SZJA_CUST LIKE /ZAK/SZJA_CUST.
   DATA W_UPD_BEVALLDEF LIKE /ZAK/BEVALLDEF.
   DATA W_UPD_AFA_CUST  LIKE /ZAK/AFA_CUST.
   DATA W_UPD_AFA_ATV   LIKE /ZAK/AFA_ATV.
   DATA W_UPD_SZJA_ABEV LIKE /ZAK/SZJA_ABEV.

*   CLEAR $TABIX.
   CLEAR $TABNAME.
*-- BG 2006.03.28

* update admits
   SELECT *  INTO W_UPD_BEVALL FROM /ZAK/BEVALL
   WHERE BUKRS EQ P_BUKRS AND
         BTYPE EQ P_BTYPE AND
         DATBI EQ V_DATBI_T.
     W_UPD_BEVALL-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_BEVALL-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_BEVALL-DATBI = /ZAK/BEVALL-DATBI.
     W_UPD_BEVALL-DATAB = /ZAK/BEVALL-DATAB.
     W_UPD_BEVALL-DATUM = SY-DATUM.
     W_UPD_BEVALL-UZEIT = SY-UZEIT.
     W_UPD_BEVALL-UNAME = SY-UNAME.

     INSERT INTO /ZAK/BEVALL VALUES W_UPD_BEVALL.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALL'.
*-- BG 2006.03.28
     ENDIF.
   ENDSELECT.
* message
*   PERFORM MESSAGE_HANDLING USING '/ZAK/ZAK' 'I' '072'
*                                '/ZAK/ADMIT'
*                                SY-MSGV2
*                                SY-MSGV3
*                                SY-MSGV4 .

* update admitted
   SELECT *  INTO W_UPD_BEVALLT FROM /ZAK/BEVALLT
   WHERE LANGU EQ SY-LANGU AND
         BUKRS EQ P_BUKRS AND
         BTYPE EQ P_BTYPE AND
         DATBI EQ V_DATBI_T.
     W_UPD_BEVALLT-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_BEVALLT-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_BEVALLT-DATBI = /ZAK/BEVALL-DATBI.
     INSERT INTO /ZAK/BEVALLT VALUES W_UPD_BEVALLT.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALLT'.
*-- BG 2006.03.28
     ENDIF.
   ENDSELECT.

* update declaration
   LOOP AT I_/ZAK/BEVALLC INTO W_UPD_BEVALLC.
*     W_UPD_BEVALLC-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_BEVALLC-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_BEVALLC-DATUM = SY-DATUM.
     W_UPD_BEVALLC-UZEIT = SY-UZEIT.
     W_UPD_BEVALLC-UNAME = SY-UNAME.
     INSERT INTO /ZAK/BEVALLC VALUES W_UPD_BEVALLC.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALLC'.
*-- BG 2006.03.28
     ENDIF.
   ENDLOOP.

* update confess
   LOOP AT I_/ZAK/BEVALLD INTO W_UPD_BEVALLD.
     W_UPD_BEVALLD-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_BEVALLD-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_BEVALLD-DATUM = SY-DATUM.
     W_UPD_BEVALLD-UZEIT = SY-UZEIT.
     W_UPD_BEVALLD-UNAME = SY-UNAME.
     INSERT INTO /ZAK/BEVALLD VALUES W_UPD_BEVALLD.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALLD'.
*-- BG 2006.03.28
     ENDIF.
   ENDLOOP.

* update admitted
   LOOP AT I_/ZAK/BEVALLDT INTO W_UPD_BEVALLDT.
     W_UPD_BEVALLDT-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_BEVALLDT-BTYPE = /ZAK/BEVALL-BTYPE.
     INSERT INTO /ZAK/BEVALLDT VALUES W_UPD_BEVALLDT.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALLDT'.
*-- BG 2006.03.28
     ENDIF.
   ENDLOOP.

* UPDATE DECLARE
   LOOP AT I_/ZAK/BEVALLB INTO W_UPD_BEVALLB.
*     SELECT SINGLE * FROM /ZAK/DEVALLB
*     WHERE BTYPE EQ /ZAK/BEVALL-BTYPE.
*     IF SY-SUBRC EQ 0.
*       EXIT.
*     ENDIF.
     W_UPD_BEVALLB-BTYPE = /ZAK/BEVALL-BTYPE.
     INSERT INTO /ZAK/BEVALLB VALUES W_UPD_BEVALLB.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALLB'.
*-- BG 2006.03.28
     ENDIF.
   ENDLOOP.

* update admitted
   LOOP AT I_/ZAK/BEVALLBT INTO W_UPD_BEVALLBT.
*     SELECT SINGLE * FROM /ZAK/DEVALLB
*     WHERE BTYPE EQ /ZAK/BEVALL-BTYPE.
*     IF SY-SUBRC EQ 0.
*       EXIT.
*     ENDIF.
     W_UPD_BEVALLBT-BTYPE = /ZAK/BEVALL-BTYPE.
     INSERT INTO /ZAK/BEVALLBT VALUES W_UPD_BEVALLBT.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
*++ BG 2006.03.28
*      $TABIX = $TABIX + 1.
       $TABNAME = '/ZAK/BEVALLBT'.
*-- BG 2006.03.28
     ENDIF.
   ENDLOOP.

*++ BG 2006.03.28
*  Copying SZJA CUST
   SELECT *  INTO W_UPD_SZJA_CUST FROM /ZAK/SZJA_CUST
   WHERE BUKRS EQ P_BUKRS AND
         BTYPE EQ P_BTYPE.
     W_UPD_SZJA_CUST-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_SZJA_CUST-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_SZJA_CUST-DATUM = SY-DATUM.
     W_UPD_SZJA_CUST-UZEIT = SY-UZEIT.
     W_UPD_SZJA_CUST-UNAME = SY-UNAME.
     INSERT INTO /ZAK/SZJA_CUST VALUES W_UPD_SZJA_CUST.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
       $TABNAME = '/ZAK/SZJA_CUST'.
     ENDIF.
   ENDSELECT.

*++ BG 2006.04.20
*  Copy /ZAK/SZJA_ABEV
   SELECT * INTO W_UPD_SZJA_ABEV FROM /ZAK/SZJA_ABEV
   WHERE BUKRS EQ P_BUKRS
     AND BTYPE EQ P_BTYPE.
     W_UPD_SZJA_ABEV-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_SZJA_ABEV-BTYPE = /ZAK/BEVALL-BTYPE.
     INSERT INTO /ZAK/SZJA_ABEV VALUES W_UPD_SZJA_ABEV.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
       $TABNAME = '/ZAK/SZJA_ABEV'.
     ENDIF.
   ENDSELECT.
*-- BG 2006.04.20

*  Printout default values
   SELECT *  INTO W_UPD_BEVALLDEF FROM /ZAK/BEVALLDEF
   WHERE BUKRS EQ P_BUKRS AND
         BTYPE EQ P_BTYPE.
     W_UPD_BEVALLDEF-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_BEVALLDEF-BTYPE = /ZAK/BEVALL-BTYPE.
     INSERT INTO /ZAK/BEVALLDEF VALUES W_UPD_BEVALLDEF.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
       $TABNAME = '/ZAK/BEVALLDEF'.
     ENDIF.
   ENDSELECT.

*  VAT settings
   SELECT *  INTO W_UPD_AFA_CUST FROM /ZAK/AFA_CUST
   WHERE BTYPE EQ P_BTYPE.
     W_UPD_AFA_CUST-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_AFA_CUST-DATUM = SY-DATUM.
     W_UPD_AFA_CUST-UZEIT = SY-UZEIT.
     W_UPD_AFA_CUST-UNAME = SY-UNAME.
     INSERT INTO /ZAK/AFA_CUST VALUES W_UPD_AFA_CUST.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
       $TABNAME = '/ZAK/AFA_CUST'.
     ENDIF.
   ENDSELECT.

*  Setting up VAT ABEV identification transfers (advance payment).
   SELECT *  INTO W_UPD_AFA_ATV FROM /ZAK/AFA_ATV
   WHERE BUKRS EQ P_BUKRS AND
         BTYPE EQ P_BTYPE.
     W_UPD_AFA_ATV-BUKRS = /ZAK/BEVALL-BUKRS.
     W_UPD_AFA_ATV-BTYPE = /ZAK/BEVALL-BTYPE.
     W_UPD_AFA_ATV-DATUM = SY-DATUM.
     W_UPD_AFA_ATV-UZEIT = SY-UZEIT.
     W_UPD_AFA_ATV-UNAME = SY-UNAME.
     INSERT INTO /ZAK/AFA_ATV VALUES W_UPD_AFA_ATV.
     IF SY-SUBRC EQ 0.
*       COMMIT WORK.
     ELSE.
       $TABNAME = '/ZAK/AFA_ATV'.
     ENDIF.
   ENDSELECT.

*-- BG 2006.03.28

*++ BG 2006.03.28
   IF $TABNAME IS INITIAL.
     COMMIT WORK.
   ELSE.
     ROLLBACK WORK.
   ENDIF.
*-- BG 2006.03.28

 ENDFORM.                    " bevall_upd
*&---------------------------------------------------------------------*
*& Module check_month INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_MONAT INPUT.
*++PTGSZLAA #04. 2014.04.28
   PERFORM CHECK_MONAT.
*   IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '16'.
*     MESSAGE E020.
** Please enter the value of the period between 01-16!
*   ENDIF.
** is there already a tax return for the given period?
*   CLEAR W_/ZAK/ADMIT.
** /ZAK/ADMIT
*   CLEAR:V_LAST_DATE, W_/ZAK/ADVALL.
** Determination of the last day of declaration
*   PERFORM GET_LAST_DAY_OF_PERIOD USING /ZAK/ANALITIKA-GJAHR
*                                        /ZAK/ANALYTICS-MONAT
*                                   CHANGING V_LAST_DATE.
*
*   SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
*       WHERE     BUKRS  = P_BUKRS
*          AND    BTYPE  = P_BTYPE
*          AND    DATBI  >= V_LAST_DATE.
*   ENDSELECT.
** ...quarterly
*   IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
*     CASE /ZAK/ANALITIKA-MONAT.
*       WHEN '01' OR '02' OR '03'.
*         PERFORM SET_RANGES USING '01'
*                                  '03'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '03'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '03'.
*         ENDIF.
*       WHEN '04' OR '05' OR '06'.
*         PERFORM SET_RANGES USING '04'
*                                  '06'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '06'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '06'.
*         ENDIF.
*       WHEN '07' OR '08' OR '09'.
*         PERFORM SET_RANGES USING '07'
*                                  '09'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '09'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '09'.
*         ENDIF.
*
*       WHEN '10' OR '11' OR '12'.
*         PERFORM SET_RANGES USING '10'
*                                  '12'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '12'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '12'.
*         ENDIF.
*     ENDCASE.
** ...annual
*   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
*     PERFORM SET_RANGES USING '01'
*                              '12'
*                              /ZAK/ANALYTICS-MONAT.
*     IF /ZAK/ANALITIKA-MONAT NE '12'.
*       MESSAGE E064 WITH P_BUKRS P_BTYPE '12'.
*     ENDIF.
** ...monthly
*   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'H'.
*     PERFORM SET_RANGES USING '01'
*                              '01'
*                              /ZAK/ANALYTICS-MONAT.
*   ENDIF.
*--PTGSZLAA #04. 28/04/2014

* normal declaration
   IF NOT RADIO1 IS INITIAL.
     SELECT SINGLE * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
            WHERE  BUKRS EQ P_BUKRS AND
                   BTYPE EQ P_BTYPE AND
                   GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                   MONAT EQ /ZAK/ANALITIKA-MONAT AND
                   ZINDEX EQ '000' AND
                   FLAG   EQ 'Z' .
     IF SY-SUBRC EQ 0.
*normal is already closed.
       MESSAGE E108 WITH /ZAK/ANALITIKA-GJAHR
                         /ZAK/ANALITIKA-MONAT
                         'normál'.
     ENDIF.
     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS EQ P_BUKRS AND
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
              MONAT IN R_MONAT AND
              ZINDEX EQ '000' AND
              FLAG   EQ 'T' .
     IF SY-SUBRC NE 0.
* APEH file creation has already been run, but there are new ones uploaded
* entries
       SELECT SINGLE * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
              WHERE  BUKRS EQ P_BUKRS AND
                     BTYPE EQ P_BTYPE AND
                     GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                     MONAT IN R_MONAT AND
                     ZINDEX EQ '000' AND
                     FLAG   EQ 'T' .
       IF SY-SUBRC EQ 0.
*Please run the APEH file creation program.
         MESSAGE E086 .
       ELSE.
         MESSAGE E048 WITH /ZAK/ANALITIKA-GJAHR
                           /ZAK/ANALITIKA-MONAT.
       ENDIF.
     ENDIF.

* self-audited declaration
   ELSE.
     SELECT * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
     UP TO 1 ROWS
        WHERE ( BUKRS EQ P_BUKRS AND
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
              MONAT IN R_MONAT AND
              ZINDEX NE '000' )
              AND
              ( BUKRS EQ P_BUKRS AND
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
              MONAT IN R_MONAT AND
              ZINDEX NE '999'  )
              ORDER BY ZINDEX DESCENDING.
     ENDSELECT.
     IF SY-SUBRC NE 0.
       MESSAGE E066 WITH /ZAK/ANALITIKA-GJAHR
                         /ZAK/ANALITIKA-MONAT.
     ELSE.
       IF W_/ZAK/BEVALLI-FLAG NE 'T'.
* APEH file creation has already been run, but there are new ones uploaded
* entries
         SELECT * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
         UP TO 1 ROWS
                WHERE  BUKRS EQ P_BUKRS AND
                       BTYPE EQ P_BTYPE AND
                       GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                       MONAT EQ /ZAK/ANALITIKA-MONAT AND
                       ZINDEX NE '000' AND
                       FLAG   EQ 'T'
                       ORDER BY ZINDEX DESCENDING.
         ENDSELECT.
         IF SY-SUBRC EQ 0.
*Please run the APEH file creation program.
           MESSAGE E086 .
         ELSE.
           MESSAGE E049 WITH /ZAK/ANALITIKA-GJAHR
                             /ZAK/ANALITIKA-MONAT.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.
   IF SY-SUBRC NE 0.
     MESSAGE E047 WITH /ZAK/ANALITIKA-GJAHR
                       /ZAK/ANALITIKA-MONAT.
   ENDIF.


 ENDMODULE.                 " check_monat  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_sel_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_SEL_SCREEN.

* Do you already have a confession?
   IF NOT P_MASOL IS INITIAL.
*     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*        WHERE BUKRS = P_BUKRS AND
*              BTYPE = P_BTYPE.
*     IF SY-SUBRC NE 0.
*       MESSAGE E051 WITH P_BUKRS P_BTYPE.
*     ENDIF.
   ENDIF.

* form closure
   IF NOT P_NYOMT IS INITIAL.
*     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*        WHERE BUKRS = P_BUKRS AND
*              BTYPE = P_BTYPE AND
*              FLAG = 'T'.
*     IF SY-SUBRC NE 0.
*       MESSAGE E053 WITH P_BUKRS P_BTYPE.
*     ENDIF.
   ENDIF.

* apeh checked
   IF NOT P_APEH IS INITIAL AND
      NOT P_BTYPE IS INITIAL.
     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS = P_BUKRS AND
              BTYPE = P_BTYPE AND
              FLAG  = 'Z' .
* did apeh file creation run?
     IF SY-SUBRC NE 0.
       MESSAGE E052 WITH P_BUKRS P_BTYPE.
     ENDIF.
   ENDIF.

* copying
   IF NOT P_MASOL IS INITIAL.

   ENDIF.
* released obligation
   IF NOT P_ELENG IS INITIAL.
*     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*        WHERE BUKRS = P_BUKRS AND
*              BTYPE = P_BTYPE AND
*              zindex = '000' and
*              FLAG  = ' ' .
** did apeh file creation run?
*     IF SY-SUBRC NE 0.
*       MESSAGE E066 WITH P_BUKRS P_BTYPE.
*     ENDIF.
   ENDIF.

* Form cancellation
   IF NOT P_DELE IS INITIAL AND
      NOT P_BTYPE IS INITIAL.
     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS = P_BUKRS AND
              BTYPE = P_BTYPE.
*              FLAG EQ 'X'.
* is the form ready?
     IF SY-SUBRC EQ 0.
       MESSAGE E095 WITH P_BUKRS P_BTYPE.
     ENDIF.
   ENDIF.


   IF NOT P_BUKRS IS INITIAL.
     SELECT SINGLE * FROM T001 WHERE BUKRS EQ P_BUKRS.
     IF SY-SUBRC NE 0.
       MESSAGE E068 WITH P_BUKRS.
     ENDIF.
   ENDIF.
* checking the declaration type
   IF NOT P_BTYPE IS INITIAL AND
      NOT P_BUKRS IS INITIAL.
     SELECT SINGLE * FROM /ZAK/BEVALL
            WHERE BUKRS EQ P_BUKRS AND
                  BTYPE EQ P_BTYPE.
     IF SY-SUBRC NE 0.
       MESSAGE E069 WITH P_BUKRS P_BTYPE.
     ENDIF.
   ENDIF.
* declaration type or declaration type is mandatory!
   IF P_BTYPE IS INITIAL AND
      P_BPART IS INITIAL.
     MESSAGE E119 .
   ENDIF.
* prerequisite for technical functions!
   IF P_ELENG NE SPACE OR
      P_NYOMT NE SPACE OR
      P_APEH  NE SPACE.

   ELSEIF P_PACK  NE SPACE OR
          P_MASOL NE SPACE OR
          P_DELE  NE SPACE.
* the function can only be used if the declaration type is filled in!
     IF P_BTYPE IS INITIAL.
       MESSAGE E121.
     ENDIF.
   ENDIF.

* company, declaration type, declaration type matching
   IF NOT P_BTYPE IS INITIAL AND
      NOT P_BPART IS INITIAL AND
      NOT P_BUKRS IS INITIAL.
     SELECT SINGLE * FROM /ZAK/BEVALL
            WHERE BUKRS EQ P_BUKRS AND
                  BTYPE EQ P_BTYPE AND
                  BTYPART EQ P_BPART.
     IF SY-SUBRC NE 0.
       MESSAGE E124 WITH P_BUKRS P_BTYPE P_BPART.
     ENDIF.
   ENDIF.


 ENDFORM.                    " check_sel_screen
*&---------------------------------------------------------------------*
*& Form lock_bevalli
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1088   text
*----------------------------------------------------------------------*
 FORM LOCK_BEVALLI USING    $FLAG LIKE /ZAK/BEVALLI-FLAG
                            $FLAG2 LIKE /ZAK/BEVALLI-FLAG
                   CHANGING $TABIX LIKE SY-TABIX.

   DATA: G_ERROR LIKE SY-SUBRC.
   DATA: W_UPD_BEVALLI  LIKE /ZAK/BEVALLI,
         W_UPD_BEVALLSZ LIKE /ZAK/BEVALLSZ.
* due date determination

   DATA: L_DATUM    LIKE SY-DATUM,
         L_DATC(10) TYPE C.


   CLEAR $TABIX.
   IF NOT RADIO1 IS INITIAL.
     REFRESH I_/ZAK/BEVALLI.
* locked?
     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS EQ P_BUKRS AND
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
              MONAT EQ /ZAK/ANALITIKA-MONAT AND
              ZINDEX EQ '000' AND
              FLAG   EQ $FLAG.
     IF SY-SUBRC EQ 0.
       MESSAGE E055 WITH /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT.
     ENDIF.
     REFRESH: I_/ZAK/BEVALLI.
     SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*++0002 BG 2011.09.20
*        WHERE BUKRS EQ P_BUKRS AND
        WHERE BUKRS IN R_BUKRS AND
*--0002 BG 2011.09.20
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
*              MONAT EQ /ZAK/ANALITIKA-MONAT AND
              MONAT IN R_MONAT AND
              ZINDEX EQ '000' AND
              FLAG  IN ('E','T').
   ELSE.
*++0002 BG 2011.09.20
*     SELECT * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*     UP TO 1 ROWS
*     WHERE BUKRS EQ P_BUKRS AND
*           BTYPE EQ P_BTYPE AND
*           GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
*           MONAT EQ /ZAK/ANALITIKA-MONAT AND
*           ZINDEX NE '000' AND
*           FLAG EQ 'T' "$FLAG
*           ORDER BY ZINDEX DESCENDING.
*     ENDSELECT.
*--0002 BG 2011.09.20
*     IF SY-SUBRC EQ 0.
*       MESSAGE E056 WITH /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT.
*     ENDIF.

     REFRESH I_/ZAK/BEVALLI.
     SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*++0002 BG 2011.09.20
*        WHERE BUKRS EQ P_BUKRS AND
        WHERE BUKRS IN R_BUKRS AND
*--0002 BG 2011.09.20
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
*              MONAT EQ /ZAK/ANALITIKA-MONAT AND
              MONAT IN R_MONAT AND
              ZINDEX NE '000' AND
              FLAG IN ('E','T').
   ENDIF.
*++0002 BG 2011.09.27
*  For group companies, we check the status of all normal companies
   IF NOT V_BUKCS_FLAG IS INITIAL.
     READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
          WITH KEY BUKRS = P_BUKRS.
     LOOP AT I_BUKRS.
       READ TABLE I_/ZAK/BEVALLI TRANSPORTING NO FIELDS
          WITH KEY BUKRS = I_BUKRS-BUKRS.
*      No data will be created
       IF SY-SUBRC NE 0.
         W_/ZAK/BEVALLI-BUKRS = I_BUKRS-BUKRS.
         APPEND W_/ZAK/BEVALLI TO I_/ZAK/BEVALLI.
       ENDIF.
     ENDLOOP.
   ENDIF.
*--0002 BG 2011.09.27
   SORT I_/ZAK/BEVALLI BY BUKRS BTYPE GJAHR MONAT ZINDEX.

* /zak/adv
* Determination of the last day of declaration
   PERFORM GET_LAST_DAY_OF_PERIOD USING /ZAK/ANALITIKA-GJAHR
                                        /ZAK/ANALITIKA-MONAT
*++PTGSZLAA #04. 2014.04.28
                                        /ZAK/ANALITIKA-BTYPE
*--PTGSZLAA #04. 2014.04.28
                                   CHANGING V_LAST_DATE.

   LOOP AT I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
   WHERE DATBI >= V_LAST_DATE.
     EXIT.
   ENDLOOP.

* /zak/you confess
   REFRESH: I_/ZAK/BEVALLSZ.
   SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
   FOR ALL ENTRIES IN I_/ZAK/BEVALLI
          WHERE  BUKRS EQ I_/ZAK/BEVALLI-BUKRS AND
                 BTYPE EQ I_/ZAK/BEVALLI-BTYPE AND
                 GJAHR EQ I_/ZAK/BEVALLI-GJAHR AND
*                 MONAT EQ I_/ZAK/BEVALLI-MONAT AND
                 MONAT IN R_MONAT AND
                 ZINDEX EQ I_/ZAK/BEVALLI-ZINDEX AND
*++BG 2006/03/30
                 FLAG  IN ('E','T','B').
*--BG 2006/03/30
* checking other data provision (not necessary for self-audit)
   IF NOT RADIO1 IS INITIAL.
     LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD
                           WHERE XSPEC EQ SPACE .
       READ TABLE I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
*++0002 2011.11.30 BG (Ness)
         WITH KEY  BUKRS  = P_BUKRS
*--0002 2011.11.30 BG (Ness)
                   BSZNUM = W_/ZAK/BEVALLD-BSZNUM.

       IF SY-SUBRC NE 0.
*++ BG 2006/03/30
*++0002 2011.11.30 BG (Ness)
         MESSAGE E102 WITH I_BUKRS-BUKRS
*--0002 2011.11.30 BG (Ness)
                           /ZAK/ANALITIKA-GJAHR
                           /ZAK/ANALITIKA-MONAT
                           W_/ZAK/BEVALLD-BSZNUM.
*-- BG 2006/03/30
         EXIT.
       ENDIF.
     ENDLOOP.
   ENDIF.

*++0002 BG 2011.09.27
** For group companies, we check the status of all normal companies
*   IF NOT V_BUKCS_FLAG IS INITIAL.
*     LOOP AT I_/ZAK/DEVALLSZ INTO W_/ZAK/DEVALLSZ
*                           WHERE BUKRS EQ P_BUKRS.
*       LOOP AT I_BUKRS.
*         READ TABLE I_/ZAK/BEVALLSZ TRANSPORTING NO FIELDS
*                           WITH KEY BUKRS  = I_BUKRS-BUKRS
*                                    BSZNUM = W_/ZAK/BEVALLSZ-BSZNUM.
**         Create it
*         IF SY-SUBRC NE 0.
*           W_/ZAK/BEVALLSZ-BUKRS = I_BUKRS-BUKRS.
*           APPEND W_/ZAK/RECLAIM TO I_/ZAK/RECLAIM.
*         ENDIF.
*       ENDLOOP.
*     ENDLOOP.
*   ENDIF.

*++0002 2011.11.30 BG (Ness)
   READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
                          WITH KEY BUKRS = P_BUKRS.
*--0002 2011.11.30 BG (Ness)
* all data services, for all periods
   PERFORM FULL_PERIOD USING
                       I_/ZAK/BEVALLI[]
                       I_/ZAK/BEVALLSZ[]
                       I_/ZAK/BEVALLD[]
                       R_MONAT
                       /ZAK/ANALITIKA-GJAHR
                       W_/ZAK/BEVALLI-ZINDEX.

** /zak/bevalli status
*   IF NOT I_/ZAK/BEVALLI[] IS INITIAL.
*     LOOP AT I_/ZAK/BEVALLI INTO W_UPD_BEVALLI.
*       W_UPD_DEVALLI-FLAG = $FLAG.
*       W_UPD_BEVALLI-DATE = SY-DATE.
*       W_UPD_BEVALLI-UZEIT = SY-UZEIT.
*       W_UPD_BEVALLI-UNAME = SY-UNAME.
*
*       SELECT SINGLE * FROM /ZAK/BEVALLI
*     WHERE BUKRS EQ W_UPD_BEVALLI-BUKRS AND
*           BTYPE EQ W_UPD_BEVALLI-BTYPE AND
*           GJAHR EQ W_UPD_BEVALLI-GJAHR AND
*           MONAT EQ W_UPD_BEVALLI-MONAT AND
*           ZINDEX EQ W_UPD_BEVALLI-ZINDEX.
*       IF SY-SUBRC EQ 0.
*         UPDATE /ZAK/BEVALLI FROM W_UPD_BEVALLI.
*       ELSE.
*         INSERT INTO /ZAK/BEVALLI VALUES W_UPD_BEVALLI.
*       ENDIF.
*       IF SY-SUBRC EQ 0.
*         COMMIT WORK.
*       ELSE.
*         $TABIX = $TABIX + 1.
*       ENDIF.
*     ENDLOOP.
*   ENDIF.
** /zak/devalsz status
*   IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
*     LOOP AT I_/ZAK/BEVALLSZ INTO W_UPD_BEVALLSZ
*                           .
*       SELECT SINGLE * FROM /ZAK/DEVALLSZ
*     WHERE BUKRS EQ W_UPD_BEVALLSZ-BUKRS AND
*           BTYPE EQ W_UPD_BEVALLSZ-BTYPE AND
*           BSZNUM EQ W_UPD_BEVALLSZ-BSZNUM AND
*           GJAHR EQ W_UPD_BEVALLSZ-GJAHR AND
*           MONAT EQ W_UPD_BEVALLSZ-MONAT AND
*           ZINDEX EQ W_UPD_BEVALLSZ-ZINDEX AND
*           PACK EQ W_UPD_BEVALLSZ-PACK.
*       IF SY-SUBRC EQ 0.
*         DELETE /ZAK/ADMISSION
*       ELSE.
*         CLEAR W_UPD_BEVALLSZ-PACK.
*       ENDIF.
*       W_UPD_BEVALLSZ-FLAG = $FLAG.
*       W_UPD_BEVALLSZ-DATE = SY-DATE.
*       W_UPD_BEVALLSZ-UZEIT = SY-UZEIT.
*       W_UPD_BEVALLSZ-UNAME = SY-UNAME.
*       PERFORM SET_LARUN CHANGING W_UPD_BEVALLSZ-LARUN.
*       INSERT INTO /ZAK/BEVALLSZ VALUES W_UPD_BEVALLSZ.
*       IF SY-SUBRC EQ 0.
*         COMMIT WORK.
*       ELSE.
*         $TABIX = $TABIX + 1.
*       ENDIF.
*     ENDLOOP.
*   ENDIF.

   CLEAR G_ERROR.
* CST: Conveyance management
   IF P_BPART = C_BTYPART_ATV.

     SELECT * INTO TABLE I_/ZAK/BEVALLO FROM /ZAK/BEVALLO
     FOR ALL ENTRIES IN I_/ZAK/BEVALLI
*++0002 BG 2011.09.20
*        WHERE BUKRS EQ I_/ZAK/BEVALLI-BUKRS AND
        WHERE BUKRS EQ P_BUKRS AND
*--0002 BG 2011.09.20
              BTYPE EQ I_/ZAK/BEVALLI-BTYPE AND
              GJAHR EQ I_/ZAK/BEVALLI-GJAHR AND
              MONAT EQ I_/ZAK/BEVALLI-MONAT AND
              ZINDEX EQ I_/ZAK/BEVALLI-ZINDEX.

     IF NOT I_/ZAK/BEVALLO[] IS INITIAL.
* Excel accounting posting
       READ TABLE I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO INDEX 1.
       IF SY-SUBRC = 0.
         CALL FUNCTION '/ZAK/ATV_BOOK_EXCEL'
           EXPORTING
             I_BUKRS         = P_BUKRS
             I_BTYPE         = P_BTYPE
             I_GJAHR         = W_/ZAK/BEVALLO-GJAHR
             I_MONAT         = W_/ZAK/BEVALLO-MONAT
             I_INDEX         = W_/ZAK/BEVALLO-ZINDEX
           TABLES
             T_BEVALLO       = I_/ZAK/BEVALLO
           EXCEPTIONS
             DATA_MISMATCH   = 1
             DOWNLOAD_FAILED = 2
             OTHERS          = 3.

         IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           G_ERROR = 4.
         ENDIF.
       ENDIF.
* It should only be posted if the file has been successfully downloaded
*++FI20070222
       IF G_ERROR = 0.
*--FI20070222

* Tax current account posting
         READ TABLE I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO INDEX 1.
         IF SY-SUBRC = 0.
           CALL FUNCTION '/ZAK/ATV_POST_ADONSZA'
             EXPORTING
               I_BUKRS       = P_BUKRS
               I_BTYPE       = P_BTYPE
               I_GJAHR       = W_/ZAK/BEVALLO-GJAHR
               I_MONAT       = W_/ZAK/BEVALLO-MONAT
               I_INDEX       = W_/ZAK/BEVALLO-ZINDEX
             TABLES
               T_BEVALLO     = I_/ZAK/BEVALLO
             EXCEPTIONS
               DATA_MISMATCH = 1
               UPDATE_ERROR  = 2
               OTHERS        = 3.

           IF SY-SUBRC <> 0.
             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

             G_ERROR = 4.
           ENDIF.
         ENDIF.
*++FI20070222
       ENDIF. "There was no mistake
*--FI20070222

     ENDIF.



     IF G_ERROR EQ 0.
       MESSAGE I077 WITH /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT.
     ENDIF.
*++PTGSZLAA #01. 2014.03.03
*   ELSE.
   ELSEIF P_BPART NE C_BTYPART_PTG.
*--PTGSZLAA #01. 2014.03.03

*++0002 BG 2011.09.20
     LOOP AT I_BUKRS.
       READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
            WITH KEY BUKRS = I_BUKRS-BUKRS.
       CHECK SY-SUBRC EQ 0.
** also fills in the obligation by tax type in the /ZAK/ADONSZA table
** A new document number must be defined for each obligation
*     SELECT * INTO TABLE I_/ZAK/BEVALLO FROM /ZAK/BEVALLO
*     FOR ALL ENTRIES IN I_/ZAK/BEVALLI
*        WHERE BUKRS EQ I_/ZAK/BEVALLI-BUKRS AND
*              BTYPE EQ I_/ZAK/BEVALLI-BTYPE AND
*              GJAHR EQ I_/ZAK/BEVALLI-GJAHR AND
*              MONAT EQ I_/ZAK/BEVALLI-MONAT AND
*              ZINDEX EQ I_/ZAK/BEVALLI-ZINDEX.
       REFRESH I_/ZAK/BEVALLO.
       SELECT * INTO TABLE I_/ZAK/BEVALLO FROM /ZAK/BEVALLO
          WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS AND
                BTYPE EQ W_/ZAK/BEVALLI-BTYPE AND
                GJAHR EQ W_/ZAK/BEVALLI-GJAHR AND
*++2012.02.12 BG
*                MONAT EQ W_/ZAK/BEVALLI-MONAT AND
                MONAT IN R_MONAT AND
*--2012.02.12 BG
                ZINDEX EQ W_/ZAK/BEVALLI-ZINDEX.
*--0002 BG 2011.09.20

*++ BG 2006/04/05

** due date determination based on abev identifier!
*       SELECT * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
*        WHERE BTYPE EQ P_BTYPE AND
*              ESDAT_FLAG NE SPACE.
*         READ TABLE I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO
*         WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
*         IF SY-SUBRC EQ 0.
*           CLEAR L_DATC.
*           WRITE W_/ZAK/BEVALLO-FIELD_C TO L_DATC.
*           EXIT.
*         ENDIF.
*       ENDSELECT.
*       SORT I_/ZAK/BEVALLO BY ABEVAZ.
*       LOOP AT I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO
*               WHERE NOT FIELD_NRK IS INITIAL.
** Gender assigned to ABEV identifier!
*         LOOP AT I_/ZAK/DEVALLB INTO W_/ZAK/DEVALLB
*                WHERE ABEVAZ EQ W_/ZAK/BEVALLO-ABEVAZ AND
*                      ADONEM NE SPACE.
*           IF L_DATC IS INITIAL .
*             READ TABLE I_/ZAK/ADONEM INTO W_/ZAK/ADONEM
*                WITH KEY ADONEM = W_/ZAK/DEVALLB-ADONEM.
*             IF SY-SUBRC EQ 0 AND
*                NOT W_/ZAK/ADONEM-FIZHAT IS INITIAL.
*               CLEAR L_DATUM.
** this is basically how we calculate the due date!???????
*               W_/ZAK/VALUE-MONAT = W_/ZAK/VALUE-MONAT + 1.
*               CONCATENATE W_/ZAK/BEVALLO-GJAHR
*                           W_/ZAK/BEVALLO-MONAT
*                           '01'
*                           INTO L_DATUM.
*               L_DATUM = L_DATUM + W_/ZAK/ADONEM-FIZHAT.
*               W_/ZAK/BEVALLO-MONAT = W_/ZAK/BEVALLO-MONAT - 1 .
*               W_/ZAK/ADONSZA-ESDAT = L_DATUM.
*             ENDIF.
*           ELSE.
*             CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
*                  EXPORTING
*                       INPUT  = L_DATC
*                  IMPORTING
*                       OUTPUT = W_/ZAK/ADONSZA-ESDAT.
**           CONCATENATE L_DATC+0(4) L_DATC+5(2) L_DATC+8(2)
**           INTO W_/ZAK/ADONSZA-ESDAT.
*           ENDIF.
** receipt number range
*           CALL FUNCTION '/ZAK/NEW_BELNR'
*                EXPORTING
*                     I_BUKRS = W_/ZAK/BEVALLO-BUKRS
*                IMPORTING
*                     E_BELNR          = W_/ZAK/ADONSZA-BELNR
*                EXCEPTIONS
*                     ERROR_GET_NUMBER = 1
*                     OTHERS           = 2.
*           IF SY-SUBRC <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*           ENDIF.
*
*           W_/ZAK/ADONSZA-BUKRS = W_/ZAK/BEVALLO-BUKRS.
*           W_/ZAK/ADONSZA-GJAHR = W_/ZAK/BEVALLO-GJAHR.
*           W_/ZAK/ADONSZA-ADONEM = W_/ZAK/DEVALLB-ADONEM.
*           W_/ZAK/DONATE-BTYPE = W_/ZAK/BEVALLO-BTYPE.
*           W_/ZAK/DONATION-MONAT = W_/ZAK/CLAIM-MONAT.
*           W_/ZAK/DONOR-ZINDEX = W_/ZAK/BEVALLO-ZINDEX.
*           IF W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_ATV.
*             W_/ZAK/ADONSZA-KOTEL  = C_KOTEL_T.
*           ELSE.
*             W_/ZAK/ADONSZA-KOTEL  = C_KOTEL.
*           ENDIF.
**         W_/ZAK/ADONSZA-ESDA =
*           W_/ZAK/ADONSZA-WRBTR = W_/ZAK/BEVALLO-FIELD_NRK.
*           W_/ZAK/ADONSZA-WAERS = W_/ZAK/BEVALLO-WAERS.
*           W_/ZAK/ADONSZA-DATUM =  SY-DATUM.
*           W_/ZAK/ADONSZA-UZEIT =  SY-UZEIT.
*           W_/ZAK/ADONSZA-UNAME =  SY-UNAME.
*           INSERT INTO /ZAK/ADONSZA VALUES W_/ZAK/ADONSZA.
*           CLEAR W_/ZAK/ADONSZA.
*         ENDLOOP.
*       ENDLOOP.

       IF NOT I_/ZAK/BEVALLO[] IS INITIAL.

*++ BG 2006/03/30
         CALL FUNCTION '/ZAK/ONELL_BOOK_EXCEL'
*        EXPORTING
*          I_BUKRS                   =
*          I_BTYPE                   =
*          I_GJAHR                   =
*          I_MONAT                   =
*          I_INDEX                   =
           TABLES
             T_BEVALLO           = I_/ZAK/BEVALLO
           EXCEPTIONS
             DATA_MISMATCH       = 1
             ERROR_ONELL_BOOK    = 2
             ERROR_DOWNLOAD_FILE = 3
*++BG 2008.04.16
             ERROR_CHANGE_BUKRS  = 4
*--BG 2008.04.16
             OTHERS              = 5.
         IF SY-SUBRC <> 0.
           CASE SY-SUBRC.
             WHEN 2.
               MESSAGE I154.
*      Self-check allowance accounting setting error! File not created!
               G_ERROR = 4.
             WHEN 3.
               MESSAGE I155.
*      Self-check allowance accounting file creation error!
               G_ERROR = 4.
*++BG 2008.04.16
             WHEN 4.
               MESSAGE E231 WITH '&'.
*   Error in defining & company rotation! (/ZAK/ROTATE_BUKRS_OUTPU
*--BG 2008.04.16
           ENDCASE .
         ENDIF.
*-- BG 2006/03/30
ENHANCEMENT-POINT /ZAK/ZAK_MOL_TECH SPOTS /ZAK/TECH_ES .

*++FI20070222
*      It should only be posted if the file has been downloaded without errors
         IF G_ERROR = 0.
           READ TABLE I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO INDEX 1.

*++BG 07.01.2008 VAT rationing, posting of accounting
           IF P_BPART = C_BTYPART_AFA.
             CALL FUNCTION '/ZAK/AFAR_BOOK_EXCEL'
               EXPORTING
*++0002 BG 2011.09.20
*                I_BUKRS = W_/ZAK/BEVALLO-BUKRS
                 I_BUKRS             = I_BUKRS-BUKRS
*--0002 BG 2011.09.20
                 I_BTYPE             = W_/ZAK/BEVALLO-BTYPE
                 I_GJAHR             = W_/ZAK/BEVALLO-GJAHR
                 I_MONAT             = W_/ZAK/BEVALLO-MONAT
                 I_INDEX             = W_/ZAK/BEVALLO-ZINDEX
               EXCEPTIONS
                 MISSING_INPUT       = 1
                 ERROR_AFAR_BOOK     = 2
                 ERROR_DOWNLOAD_FILE = 3
                 EMPTY_FILE          = 4
                 ERROR_DATUM         = 5
                 OTHERS              = 6.
             IF SY-SUBRC <> 0.
               MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
               MOVE SY-SUBRC TO G_ERROR.
             ENDIF.
           ENDIF.
*--BG 2008.01.07 VAT rationing accounting
           IF G_ERROR = 0.
             CALL FUNCTION '/ZAK/POST_ADONSZA'
               EXPORTING
*++0002 BG 2011.09.20
*                I_BUKRS = W_/ZAK/BEVALLO-BUKRS
                 I_BUKRS       = I_BUKRS-BUKRS
*--0002 BG 2011.09.20
                 I_BTYPE       = W_/ZAK/BEVALLO-BTYPE
                 I_GJAHR       = W_/ZAK/BEVALLO-GJAHR
                 I_MONAT       = W_/ZAK/BEVALLO-MONAT
                 I_INDEX       = W_/ZAK/BEVALLO-ZINDEX
               TABLES
                 T_BEVALLO     = I_/ZAK/BEVALLO
               EXCEPTIONS
                 DATA_MISMATCH = 1
                 OTHER_ERROR   = 2
                 OTHERS        = 3.
             IF SY-SUBRC <> 0.
               MESSAGE E160 WITH SY-SUBRC.
*        Serious error in the accounting of tax current account items! (&)
               G_ERROR = 4.
             ENDIF.
*-- BG 2006/04/05
           ENDIF.
         ENDIF. " G_error = 0

*++0002 BG 2011.09.20
*       IF G_ERROR = 0.
*         MESSAGE I077 WITH /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT.
*       ENDIF.
*--0002 BG 2011.09.20
       ENDIF.
*++0002 BG 2011.09.20
       IF NOT G_ERROR IS INITIAL.
         EXIT.
       ENDIF.
     ENDLOOP.
*--0002 BG 2011.09.20
   ENDIF.

* ++CST 06.04.2006: If an error occurred in the tax current account posting
*       Status cannot be changed...
   IF G_ERROR = 0.
*++0002 BG 2011.09.20
     MESSAGE I077 WITH /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT.
*--0002 BG 2011.09.20
* /zak/bevalli status
     IF NOT I_/ZAK/BEVALLI[] IS INITIAL.
       LOOP AT I_/ZAK/BEVALLI INTO W_UPD_BEVALLI.
         W_UPD_BEVALLI-FLAG  = $FLAG.
         W_UPD_BEVALLI-DATUM = SY-DATUM.
         W_UPD_BEVALLI-UZEIT = SY-UZEIT.
         W_UPD_BEVALLI-UNAME = SY-UNAME.

         SELECT SINGLE * FROM /ZAK/BEVALLI
       WHERE BUKRS EQ W_UPD_BEVALLI-BUKRS AND
             BTYPE EQ W_UPD_BEVALLI-BTYPE AND
             GJAHR EQ W_UPD_BEVALLI-GJAHR AND
             MONAT EQ W_UPD_BEVALLI-MONAT AND
             ZINDEX EQ W_UPD_BEVALLI-ZINDEX.
         IF SY-SUBRC EQ 0.
           UPDATE /ZAK/BEVALLI FROM W_UPD_BEVALLI.
         ELSE.
           INSERT INTO /ZAK/BEVALLI VALUES W_UPD_BEVALLI.
         ENDIF.
         IF SY-SUBRC EQ 0.
           COMMIT WORK.
         ELSE.
           $TABIX = $TABIX + 1.
         ENDIF.
       ENDLOOP.
     ENDIF.
* /zak/devalsz status
     IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
       LOOP AT I_/ZAK/BEVALLSZ INTO W_UPD_BEVALLSZ
                             .
         SELECT SINGLE * FROM /ZAK/BEVALLSZ
       WHERE BUKRS EQ W_UPD_BEVALLSZ-BUKRS AND
             BTYPE EQ W_UPD_BEVALLSZ-BTYPE AND
             BSZNUM EQ W_UPD_BEVALLSZ-BSZNUM AND
             GJAHR EQ W_UPD_BEVALLSZ-GJAHR AND
             MONAT EQ W_UPD_BEVALLSZ-MONAT AND
             ZINDEX EQ W_UPD_BEVALLSZ-ZINDEX AND
             PACK   EQ W_UPD_BEVALLSZ-PACK.
         IF SY-SUBRC EQ 0.
           DELETE /ZAK/BEVALLSZ.
         ELSE.
           CLEAR W_UPD_BEVALLSZ-PACK.
         ENDIF.
         W_UPD_BEVALLSZ-FLAG = $FLAG.
         W_UPD_BEVALLSZ-DATUM = SY-DATUM.
         W_UPD_BEVALLSZ-UZEIT = SY-UZEIT.
         W_UPD_BEVALLSZ-UNAME = SY-UNAME.
         PERFORM SET_LARUN CHANGING W_UPD_BEVALLSZ-LARUN.
         INSERT INTO /ZAK/BEVALLSZ VALUES W_UPD_BEVALLSZ.
         IF SY-SUBRC EQ 0.
           COMMIT WORK.
         ELSE.
           $TABIX = $TABIX + 1.
         ENDIF.
       ENDLOOP.
     ENDIF.
ENHANCEMENT-POINT /ZAK/TECH_TELEKOM_1 SPOTS /ZAK/TECH_ES .

ENDIF.
* --CST 2006.06.04

 ENDFORM.                    " lock_bevalli
*&---------------------------------------------------------------------*
*& Module CHECK_MONAT_9002 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_MONAT_9002 INPUT.
*++PTGSZLAA #04. 2014.04.28
   PERFORM CHECK_MONAT.
*   IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '16'.
*     MESSAGE E020.
** Please enter the value of the period between 01-16!
*   ENDIF.
*   CLEAR W_/ZAK/ADMIT.
** Determination of the last day of declaration
*   PERFORM GET_LAST_DAY_OF_PERIOD USING /ZAK/ANALITIKA-GJAHR
*                                        /ZAK/ANALYTICS-MONAT
*                                   CHANGING V_LAST_DATE.
*
*   SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
*       WHERE     BUKRS  = P_BUKRS
*          AND    BTYPE  = P_BTYPE
*          AND    DATBI  >= V_LAST_DATE.
*   ENDSELECT.
** ...quarterly
*   IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
*     CASE /ZAK/ANALITIKA-MONAT.
*       WHEN '01' OR '02' OR '03'.
*         PERFORM SET_RANGES USING '01'
*                                  '03'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '03'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '03'.
*         ENDIF.
*       WHEN '04' OR '05' OR '06'.
*         PERFORM SET_RANGES USING '04'
*                                  '06'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '06'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '06'.
*         ENDIF.
*       WHEN '07' OR '08' OR '09'.
*         PERFORM SET_RANGES USING '07'
*                                  '09'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '09'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '09'.
*         ENDIF.
*
*       WHEN '10' OR '11' OR '12'.
*         PERFORM SET_RANGES USING '10'
*                                  '12'
*                                  /ZAK/ANALYTICS-MONAT.
*         IF /ZAK/ANALITIKA-MONAT NE '12'.
*           MESSAGE E063 WITH P_BUKRS P_BTYPE '12'.
*         ENDIF.
*     ENDCASE.
** ...annual
*   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
*     PERFORM SET_RANGES USING '01'
*                              '12'
*                              /ZAK/ANALYTICS-MONAT.
*     IF /ZAK/ANALITIKA-MONAT NE '12'.
*       MESSAGE E064 WITH P_BUKRS P_BTYPE '12'.
*     ENDIF.
** ...monthly
*   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'H'.
*     PERFORM SET_RANGES USING '01'
*                              '01'
*                              /ZAK/ANALYTICS-MONAT.
*   ENDIF.
*--PTGSZLAA #04. 2014.04.28
* confession
   SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
      WHERE BUKRS EQ P_BUKRS AND
            BTYPE EQ P_BTYPE AND
            GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
            MONAT IN R_MONAT AND
            ZINDEX NE '999' AND
            FLAG  EQ 'Z'.
   IF SY-SUBRC NE 0.
     MESSAGE E057 WITH /ZAK/ANALITIKA-GJAHR
                       /ZAK/ANALITIKA-MONAT.
   ENDIF.

   SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
      WHERE BUKRS EQ P_BUKRS AND
            BTYPE EQ P_BTYPE AND
            GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
            MONAT IN R_MONAT AND
            ZINDEX NE '999' AND
            FLAG  EQ 'X'.
   IF SY-SUBRC EQ 0.
     MESSAGE E058 WITH /ZAK/ANALITIKA-GJAHR
                       /ZAK/ANALITIKA-MONAT.
   ENDIF.

   SELECT SINGLE * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
      WHERE BUKRS EQ P_BUKRS AND
            BTYPE EQ P_BTYPE AND
            GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
            MONAT IN R_MONAT AND
            ZINDEX NE '999' AND
            FLAG  NE 'Z'.
   IF SY-SUBRC EQ 0.
     MESSAGE E163 WITH /ZAK/ANALITIKA-GJAHR
                       W_/ZAK/BEVALLSZ-MONAT.
   ENDIF.

 ENDMODULE.                 " CHECK_MONAT_9002  INPUT
*&---------------------------------------------------------------------*
*& Form LOCK_BEVALLIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1137   text
*      <--P_V_TABIX text
*----------------------------------------------------------------------*
 FORM LOCK_BEVALLIX USING    $FLAG LIKE /ZAK/BEVALLI-FLAG
                    CHANGING $TABIX LIKE SY-TABIX.

   DATA: W_UPD_BEVALLI  LIKE /ZAK/BEVALLI,
         W_UPD_BEVALLSZ LIKE /ZAK/BEVALLSZ.
   CLEAR $TABIX.

   REFRESH: I_/ZAK/BEVALLI,I_/ZAK/BEVALLSZ.
* locked?
   SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*++0002 BG 2011.09.20
*      WHERE BUKRS EQ P_BUKRS AND
      WHERE BUKRS IN R_BUKRS AND
*--0002 BG 2011.09.20
            BTYPE EQ P_BTYPE AND
            GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
            MONAT IN R_MONAT AND
            ZINDEX NE '999' AND
            FLAG  EQ 'Z'.

*   IF SY-SUBRC ne 0.
*     MESSAGE E058 WITH /ZAK/ANALITIKA_S-GJAHR /ZAK/ANALITIKA_S-MONAT.
*   ENDIF.

   IF NOT I_/ZAK/BEVALLI[] IS INITIAL.
     SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
           FOR ALL ENTRIES IN I_/ZAK/BEVALLI
         WHERE  BUKRS EQ I_/ZAK/BEVALLI-BUKRS AND
                BTYPE EQ I_/ZAK/BEVALLI-BTYPE AND
                GJAHR EQ I_/ZAK/BEVALLI-GJAHR AND
                MONAT IN R_MONAT AND
                ZINDEX EQ I_/ZAK/BEVALLI-ZINDEX AND
                FLAG   EQ 'Z' .

     LOOP AT I_/ZAK/BEVALLI INTO W_UPD_BEVALLI.
       W_UPD_BEVALLI-FLAG = $FLAG.
       W_UPD_BEVALLI-DATUM = SY-DATUM.
       W_UPD_BEVALLI-UZEIT = SY-UZEIT.
       W_UPD_BEVALLI-UNAME = SY-UNAME.
       UPDATE /ZAK/BEVALLI FROM W_UPD_BEVALLI.
       IF SY-SUBRC EQ 0.
         COMMIT WORK.
       ELSE.
         $TABIX = $TABIX + 1.
       ENDIF.
     ENDLOOP.
* /zak/devalsz status
     IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
       LOOP AT I_/ZAK/BEVALLSZ INTO W_UPD_BEVALLSZ
                             WHERE ZINDEX NE '999'.
         SELECT SINGLE * FROM /ZAK/BEVALLSZ
       WHERE BUKRS EQ W_UPD_BEVALLSZ-BUKRS AND
             BTYPE EQ W_UPD_BEVALLSZ-BTYPE AND
             BSZNUM EQ W_UPD_BEVALLSZ-BSZNUM AND
             GJAHR EQ W_UPD_BEVALLSZ-GJAHR AND
             MONAT EQ W_UPD_BEVALLSZ-MONAT AND
             ZINDEX EQ W_UPD_BEVALLSZ-ZINDEX AND
             PACK   EQ W_UPD_BEVALLSZ-PACK.
         IF SY-SUBRC EQ 0.
           DELETE /ZAK/BEVALLSZ.
         ENDIF.
         CLEAR W_UPD_BEVALLSZ-PACK.
         W_UPD_BEVALLSZ-FLAG = $FLAG.
         W_UPD_BEVALLSZ-DATUM = SY-DATUM.
         W_UPD_BEVALLSZ-UZEIT = SY-UZEIT.
         W_UPD_BEVALLSZ-UNAME = SY-UNAME.
         PERFORM SET_LARUN CHANGING W_UPD_BEVALLSZ-LARUN.
         INSERT INTO /ZAK/BEVALLSZ VALUES W_UPD_BEVALLSZ.
         IF SY-SUBRC EQ 0.
           COMMIT WORK.
         ELSE.
           $TABIX = $TABIX + 1.
         ENDIF.
       ENDLOOP.
     ENDIF.
   ENDIF.
 ENDFORM.                    " LOCK_BEVALLIX
*&---------------------------------------------------------------------*
*& Module user_command_9003 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9003 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   IF V_FULL IS INITIAL.
     IF /ZAK/ANALITIKA-BSZNUM IS INITIAL.
       MESSAGE E055(00).
     ENDIF.
   ENDIF.
   CASE V_SAVE_OK.
     WHEN 'ELENG'.
       CLEAR V_TABIX.
       PERFORM LOCK_BEVALLSZ CHANGING V_TABIX.
*++2008 #04.
*       IF V_TABIX IS INITIAL.
       IF NOT V_TABIX IS INITIAL.
*--2008 #04.
         MESSAGE I073 WITH /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT.
       ELSE.
*         message
       ENDIF.
       SET SCREEN 0.
       LEAVE SCREEN.
     WHEN 'FULL'.
       PERFORM MODIF_DYNP .
     WHEN OTHERS.
   ENDCASE.

*++PTGSZLAA #04. 2014.04.28
   IF P_BTYPE EQ C_PTGSZLAA.
     IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '52'.
       MESSAGE E402.
*   Please enter the value of the period between 01-52!
     ENDIF.
   ELSE.
     IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '16'.
       MESSAGE E020.
*   Please enter the value of the period between 01-16!
     ENDIF.
   ENDIF.
*   IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '16'.
*     MESSAGE E020.
** Please enter the value of the period between 01-16!
*   ELSE.
*--PTGSZLAA #04. 2014.04.28
* /ZAK/ADMITTED
   CLEAR: V_LAST_DATE, W_/ZAK/BEVALL.
* Determination of the last day of declaration
   PERFORM GET_LAST_DAY_OF_PERIOD USING /ZAK/ANALITIKA-GJAHR
                                        /ZAK/ANALITIKA-MONAT
*++PTGSZLAA #04. 2014.04.28
                                        /ZAK/ANALITIKA-BTYPE
*--PTGSZLAA #04. 2014.04.28
                                   CHANGING V_LAST_DATE.

   SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL FROM  /ZAK/BEVALL
       WHERE     BUKRS  = P_BUKRS
          AND    BTYPE  = P_BTYPE
          AND    DATBI  >= V_LAST_DATE.
   ENDSELECT.

* ...quarterly
   IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
     CASE /ZAK/ANALITIKA-MONAT.
       WHEN '01' OR '02' OR '03'.
         IF /ZAK/ANALITIKA-MONAT NE '03'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '03'.
         ENDIF.
       WHEN '04' OR '05' OR '06'.
         IF /ZAK/ANALITIKA-MONAT NE '06'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '06'.
         ENDIF.
       WHEN '07' OR '08' OR '09'.
         IF /ZAK/ANALITIKA-MONAT NE '09'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '09'.
         ENDIF.
       WHEN '10' OR '11' OR '12'.
         IF /ZAK/ANALITIKA-MONAT NE '12'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '12'.
         ENDIF.
     ENDCASE.
* ...annual
   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
     IF /ZAK/ANALITIKA-MONAT NE '12'.
       MESSAGE E064 WITH P_BUKRS P_BTYPE '12'.
     ENDIF.
   ENDIF.
*++PTGSZLAA #04. 2014.04.28
*   ENDIF.
*--PTGSZLAA #04. 2014.04.28
* /zak/confess
   IF V_FULL IS INITIAL.
     SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
        WHERE BUKRS EQ P_BUKRS AND
              BTYPE EQ P_BTYPE AND
              BSZNUM EQ /ZAK/ANALITIKA-BSZNUM.

     IF SY-SUBRC NE 0.
       MESSAGE E059 WITH /ZAK/ANALITIKA-BSZNUM.
     ENDIF.
   ENDIF.
   CLEAR W_/ZAK/BEVALLSZ.
* confession
   SELECT SINGLE * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
      WHERE BUKRS EQ P_BUKRS AND
            BTYPE EQ P_BTYPE AND
            BSZNUM EQ /ZAK/ANALITIKA-BSZNUM AND
            GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
            MONAT EQ /ZAK/ANALITIKA-MONAT AND
            FLAG  NE 'E'.
   IF SY-SUBRC EQ 0.
     MESSAGE E060 WITH /ZAK/ANALITIKA-GJAHR
                       /ZAK/ANALITIKA-MONAT.
   ENDIF.

   SELECT SINGLE * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
      WHERE BUKRS EQ P_BUKRS AND
            BTYPE EQ P_BTYPE AND
            BSZNUM EQ /ZAK/ANALITIKA-BSZNUM AND
            GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
            MONAT EQ /ZAK/ANALITIKA-MONAT AND
            ZINDEX NE '999' AND
            FLAG   EQ 'E'.
   IF SY-SUBRC EQ 0.
     MESSAGE E061 WITH /ZAK/ANALITIKA-GJAHR
                       /ZAK/ANALITIKA-MONAT.
   ENDIF.


 ENDMODULE.                 " user_command_9003  INPUT
*&---------------------------------------------------------------------*
*& Form LOCK_REF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_TABIX text
*----------------------------------------------------------------------*
 FORM LOCK_BEVALLSZ CHANGING $TABIX LIKE SY-TABIX.

   DATA: W_UPD_BEVALLSZ LIKE /ZAK/BEVALLSZ,
         W_UPD_BEVALLI  LIKE /ZAK/BEVALLI,
         L_STAMP        LIKE  TZONREF-TSTAMPS,
         L_UPDATE .

   REFRESH: I_/ZAK/BEVALLSZ.
   CLEAR: L_UPDATE.
*++2008 #04.
   DATA   L_ZINDEX TYPE NUMC3.
   RANGES LR_FLAG_O FOR /ZAK/BEVALLI-FLAG.
   RANGES LR_FLAG_Z FOR /ZAK/BEVALLI-FLAG.

   DEFINE LM_GET_ZINDEX.
*      Open status
     SELECT SINGLE MAX( ZINDEX ) INTO /ZAK/ANALITIKA-ZINDEX
                                 FROM /ZAK/BEVALLI
                         WHERE BUKRS EQ &1 AND
                               BTYPE EQ P_BTYPE AND
                               GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                               MONAT EQ /ZAK/ANALITIKA-MONAT AND
                                FLAG IN LR_FLAG_O.
*      If not, we look for the locked ones
     IF /ZAK/ANALITIKA-ZINDEX IS INITIAL.
       SELECT SINGLE MAX( ZINDEX ) INTO /ZAK/ANALITIKA-ZINDEX
                                   FROM /ZAK/BEVALLI
                           WHERE BUKRS EQ &1 AND
                                 BTYPE EQ P_BTYPE AND
                                 GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                                 MONAT EQ /ZAK/ANALITIKA-MONAT AND
                                  FLAG IN LR_FLAG_Z.
*        There is the next period you need
       IF NOT /ZAK/ANALITIKA-ZINDEX IS INITIAL.
         L_ZINDEX = /ZAK/ANALITIKA-ZINDEX.
         ADD 1 TO L_ZINDEX.
         /ZAK/ANALITIKA-ZINDEX =  L_ZINDEX.
*        If not, then 000
       ELSE.
         /ZAK/ANALITIKA-ZINDEX = '000'.
       ENDIF.
     ENDIF.
   END-OF-DEFINITION.


*  We determine the last open period!
   M_DEF LR_FLAG_O 'E' 'EQ' 'Z' ''.
   M_DEF LR_FLAG_O 'E' 'EQ' 'X' ''.
   M_DEF LR_FLAG_Z 'I' 'EQ' 'Z' ''.
   M_DEF LR_FLAG_Z 'I' 'EQ' 'X' ''.
*--2008 #04.

   IF NOT V_FULL IS INITIAL.
* all data provision should be a released obligation, if not given
* up analytics
* outer join is required !!!
     SELECT * INTO TABLE I_/ZAK/BEVALLD FROM /ZAK/BEVALLD
*++0002 BG 2011.09.20
*       WHERE BUKRS EQ P_BUKRS AND
       WHERE BUKRS IN R_BUKRS AND
*--0002 BG 2011.09.20
             BTYPE EQ P_BTYPE.

     LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.
*++2008 #04.
       LM_GET_ZINDEX W_/ZAK/BEVALLD-BUKRS.
*--2008 #04.
       SELECT SINGLE * FROM /ZAK/BEVALLSZ
*++0002 BG 2011.09.20
*        WHERE BUKRS EQ P_BUKRS AND
        WHERE BUKRS EQ W_/ZAK/BEVALLD-BUKRS AND
*--0002 BG 2011.09.20
              BTYPE EQ P_BTYPE AND
              BSZNUM EQ W_/ZAK/BEVALLD-BSZNUM AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
              MONAT EQ /ZAK/ANALITIKA-MONAT AND
*++ E09324753 20200213
              ZINDEX EQ /ZAK/ANALITIKA-ZINDEX.
*-- E09324753 20200213
       IF SY-SUBRC NE 0.
* no upload for data service!
* /zak/bavalsz insert
         CLEAR W_UPD_BEVALLSZ.
*++0002 BG 2011.09.20
*         W_UPD_BEVALLSZ-BUKRS = P_BUKRS.
         W_UPD_BEVALLSZ-BUKRS = W_/ZAK/BEVALLD-BUKRS.
*--0002 BG 2011.09.20
         W_UPD_BEVALLSZ-BTYPE = P_BTYPE.
         W_UPD_BEVALLSZ-BSZNUM = W_/ZAK/BEVALLD-BSZNUM.
         W_UPD_BEVALLSZ-FLAG = 'E'.
         W_UPD_BEVALLSZ-GJAHR = /ZAK/ANALITIKA-GJAHR.
         W_UPD_BEVALLSZ-MONAT = /ZAK/ANALITIKA-MONAT.
*++2008 #04.
*         W_UPD_BEVALLSZ-ZINDEX = '000'.
         W_UPD_BEVALLSZ-ZINDEX = /ZAK/ANALITIKA-ZINDEX.
*--2008 #04.
         CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
           EXPORTING
             I_DATLO     = SY-DATLO
             I_TIMLO     = SY-TIMLO
           IMPORTING
             E_TIMESTAMP = L_STAMP.
         W_UPD_BEVALLSZ-LARUN = L_STAMP.
         W_UPD_BEVALLSZ-DATUM = SY-DATUM.
         W_UPD_BEVALLSZ-UZEIT = SY-UZEIT.
         W_UPD_BEVALLSZ-UNAME = SY-UNAME.
         INSERT INTO /ZAK/BEVALLSZ VALUES W_UPD_BEVALLSZ.
         IF SY-SUBRC EQ 0.
           COMMIT WORK.
*++2008 #04.
*         ELSE.
*--2008 #04.
           $TABIX = $TABIX + 1.
         ENDIF.
         IF L_UPDATE IS INITIAL.
           L_UPDATE = 'X'.
*++0002 BG 2011.09.20
*           W_UPD_BEVALLI-BUKRS = P_BUKRS.
           W_UPD_BEVALLI-BUKRS = W_/ZAK/BEVALLD-BUKRS.
*--0002 BG 2011.09.20
           W_UPD_BEVALLI-BTYPE = P_BTYPE.
           W_UPD_BEVALLI-FLAG = 'E'.
           W_UPD_BEVALLI-GJAHR = /ZAK/ANALITIKA-GJAHR.
           W_UPD_BEVALLI-MONAT = /ZAK/ANALITIKA-MONAT.
*++2008 #04.
*           W_UPD_BEVALLI-ZINDEX = '000'.
           W_UPD_BEVALLI-ZINDEX = /ZAK/ANALITIKA-ZINDEX.
*--2008 #04.
           W_UPD_BEVALLI-DATUM = SY-DATUM.
           W_UPD_BEVALLI-UZEIT = SY-UZEIT.
           W_UPD_BEVALLI-UNAME = SY-UNAME.
           INSERT INTO /ZAK/BEVALLI VALUES W_UPD_BEVALLI.
           IF SY-SUBRC EQ 0.
             COMMIT WORK.
*++2008 #04.
*         ELSE.
*--2008 #04.
             $TABIX = $TABIX + 1.
           ENDIF.
         ENDIF.
       ENDIF.
     ENDLOOP.

   ELSE.

*++0002 BG 2011.09.20
     LOOP AT I_BUKRS.
*++2008 #04.
       LM_GET_ZINDEX I_BUKRS-BUKRS.
*--2008 #04.
* there was already a return for the period
       SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
*++0002 BG 2011.09.20
*        WHERE BUKRS EQ P_BUKRS AND
          WHERE BUKRS EQ I_BUKRS-BUKRS AND
*--0002 BG 2011.09.20
                BTYPE EQ P_BTYPE AND
                BSZNUM EQ /ZAK/ANALITIKA-BSZNUM AND
                GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                MONAT EQ /ZAK/ANALITIKA-MONAT AND
*++ E09324753 20200213
                ZINDEX EQ /ZAK/ANALITIKA-ZINDEX AND
*-- E09324753 20200213
                FLAG   NE 'E'.

       IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
         MESSAGE E060 WITH /ZAK/ANALITIKA-GJAHR
                           /ZAK/ANALITIKA-MONAT.
       ELSE.
         CLEAR W_UPD_BEVALLSZ.
*++0002 BG 2011.09.20
*       W_UPD_BEVALLSZ-BUKRS = P_BUKRS.
         W_UPD_BEVALLSZ-BUKRS = I_BUKRS-BUKRS.
*--0002 BG 2011.09.20
         W_UPD_BEVALLSZ-BTYPE = P_BTYPE.
         W_UPD_BEVALLSZ-BSZNUM = /ZAK/ANALITIKA-BSZNUM.
         W_UPD_BEVALLSZ-FLAG = 'E'.
         W_UPD_BEVALLSZ-GJAHR = /ZAK/ANALITIKA-GJAHR.
         W_UPD_BEVALLSZ-MONAT = /ZAK/ANALITIKA-MONAT.
*++2008 #04.
*         W_UPD_BEVALLSZ-ZINDEX = '000'.
         W_UPD_BEVALLSZ-ZINDEX = /ZAK/ANALITIKA-ZINDEX.
*--2008 #04.
         CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
           EXPORTING
             I_DATLO     = SY-DATLO
             I_TIMLO     = SY-TIMLO
           IMPORTING
             E_TIMESTAMP = L_STAMP.
         W_UPD_BEVALLSZ-LARUN = L_STAMP.
         W_UPD_BEVALLSZ-DATUM = SY-DATUM.
         W_UPD_BEVALLSZ-UZEIT = SY-UZEIT.
         W_UPD_BEVALLSZ-UNAME = SY-UNAME.
         INSERT INTO /ZAK/BEVALLSZ VALUES W_UPD_BEVALLSZ.
         IF SY-SUBRC EQ 0.
           COMMIT WORK.
*++2008 #04.
*         ELSE.
*--2008 #04.
           $TABIX = $TABIX + 1.
         ENDIF.
       ENDIF.
*++0002 BG 2011.09.20
*     W_UPD_BEVALLI-BUKRS = P_BUKRS.
       W_UPD_BEVALLI-BUKRS = I_BUKRS-BUKRS.
*--0002 BG 2011.09.20
       W_UPD_BEVALLI-BTYPE = P_BTYPE.
       W_UPD_BEVALLI-FLAG = 'E'.
       W_UPD_BEVALLI-GJAHR = /ZAK/ANALITIKA-GJAHR.
       W_UPD_BEVALLI-MONAT = /ZAK/ANALITIKA-MONAT.
*++2008 #04.
*       W_UPD_BEVALLI-ZINDEX = '000'.
       W_UPD_BEVALLI-ZINDEX = /ZAK/ANALITIKA-ZINDEX.
*--2008 #04.
       W_UPD_BEVALLI-DATUM = SY-DATUM.
       W_UPD_BEVALLI-UZEIT = SY-UZEIT.
       W_UPD_BEVALLI-UNAME = SY-UNAME.
       INSERT INTO /ZAK/BEVALLI VALUES W_UPD_BEVALLI.
       IF SY-SUBRC EQ 0.
         COMMIT WORK.
*++2008 #04.
*         ELSE.
*--2008 #04.
         $TABIX = $TABIX + 1.
       ENDIF.
*++0002 BG 2011.09.20
     ENDLOOP.
*--0002 BG 2011.09.20
   ENDIF.
 ENDFORM.                    " LOCK_BEVALLsz
*&---------------------------------------------------------------------*
*&      Form  call_9003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_9003.
   CALL SCREEN 9003.
 ENDFORM.                                                   " call_9003
*&---------------------------------------------------------------------*
*& Form READ_BEVALLB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
 FORM READ_BEVALLB USING    $BTYPE LIKE /ZAK/BEVALL-BTYPE.
   REFRESH I_/ZAK/BEVALLB.

   SELECT * INTO TABLE I_/ZAK/BEVALLB FROM /ZAK/BEVALLB
       WHERE BTYPE EQ $BTYPE.

   REFRESH I_/ZAK/BEVALLBT.

   SELECT * INTO TABLE I_/ZAK/BEVALLBT FROM /ZAK/BEVALLBT
       WHERE BTYPE EQ $BTYPE .
 ENDFORM.                    " READ_BEVALLB
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_DAY_OF_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/ZAK/ANALITIKA_S_GJAHR  text
*      -->P_/ZAK/ANALITIKA_S_MONAT  text
*      <--P_V_LAST_DATE  text
*----------------------------------------------------------------------*
 FORM GET_LAST_DAY_OF_PERIOD USING     $GJAHR
                                       $MONAT
*++PTGSZLAA #04. 2014.04.28
                                       $BTYPE
*--PTGSZLAA #04. 2014.04.28
                               CHANGING V_LAST_DATE.

   DATA: L_DATE1 TYPE DATUM,
         L_DATE2 TYPE DATUM.

*++PTGSZLAA #04. 2014.04.28
   DATA: L_WEEK TYPE KWEEK.
*--PTGSZLAA #04. 2014.04.28

   CLEAR V_LAST_DATE.
*++PTGSZLAA #04. 2014.04.28
   IF $BTYPE EQ C_PTGSZLAA.
     CONCATENATE $GJAHR $MONAT INTO L_WEEK.
     CALL FUNCTION 'WEEK_GET_FIRST_DAY'
       EXPORTING
         WEEK = L_WEEK
       IMPORTING
         DATE = V_LAST_DATE
*      EXCEPTIONS
*        WEEK_INVALID       = 1
*        OTHERS             = 2
       .
     IF SY-SUBRC <> 0.
       CLEAR V_LAST_DATE.
     ELSE.
       ADD 6 TO V_LAST_DATE.
     ENDIF.
   ELSE.
*--PTGSZLAA #04. 2014.04.28
     CONCATENATE $GJAHR $MONAT '01' INTO L_DATE1.

     CALL FUNCTION 'LAST_DAY_OF_MONTHS' "#EC CI_USAGE_OK[2296016]
       EXPORTING
         DAY_IN            = L_DATE1
       IMPORTING
         LAST_DAY_OF_MONTH = L_DATE2
       EXCEPTIONS
         DAY_IN_NO_DATE    = 1
         OTHERS            = 2.

     IF SY-SUBRC = 0.
       V_LAST_DATE = L_DATE2.
     ENDIF.
*++PTGSZLAA #04. 2014.04.28
   ENDIF.
*--PTGSZLAA #04. 2014.04.28
 ENDFORM.                    " GET_LAST_DAY_OF_PERIOD
*&---------------------------------------------------------------------*
*& Module SET_DYNP9001 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_DYNP9001 OUTPUT.

   PERFORM SET_BUTXT_BTEXT.

 ENDMODULE.                 " SET_DYNP9001  OUTPUT
*&---------------------------------------------------------------------*
*& Module SET_DYNP9003 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_DYNP9003 OUTPUT.

   PERFORM SET_BUTXT_BTEXT.

 ENDMODULE.                 " SET_DYNP9003  OUTPUT
*&---------------------------------------------------------------------*
*& Module pbo9001 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9001 OUTPUT.
   PERFORM SET_STATUS.
 ENDMODULE.                 " pbo9001  OUTPUT
*&---------------------------------------------------------------------*
*& Module pbo9002 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9002 OUTPUT.
   PERFORM SET_STATUS.
 ENDMODULE.                 " pbo9002  OUTPUT
*&---------------------------------------------------------------------*
*& Module SET_DYNP9002 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_DYNP9002 OUTPUT.
   PERFORM SET_BUTXT_BTEXT.
 ENDMODULE.                 " SET_DYNP9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  set_butxt_btext
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_BUTXT_BTEXT.

   /ZAK/ANALITIKA-BUKRS = P_BUKRS.
   /ZAK/ANALITIKA-BTYPE = P_BTYPE.
* Company name
   SELECT SINGLE BUTXT INTO F_BUTXT FROM  T001
          WHERE  BUKRS  = P_BUKRS.

* Declaration type designation
   SELECT SINGLE BTEXT INTO F_BTEXT FROM  /ZAK/BEVALLT
          WHERE  LANGU  = SY-LANGU
          AND    BTYPE  = P_BTYPE.
 ENDFORM.                    " set_butxt_btext
*&---------------------------------------------------------------------*
*& Module pbo9003 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9003 OUTPUT.
   PERFORM SET_STATUS.
 ENDMODULE.                 " pbo9003  OUTPUT
*&---------------------------------------------------------------------*
*& Module SET_V_DATAB_T INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_V_DATAB_T INPUT.

   SELECT SINGLE DATAB FROM /ZAK/BEVALL INTO V_DATAB_T
          WHERE BUKRS EQ P_BUKRS AND
                BTYPE EQ P_BTYPE AND
                DATBI EQ V_DATBI_T.
   IF SY-SUBRC NE 0.
     MESSAGE E070 .
   ENDIF.
 ENDMODULE.                 " SET_V_DATAB_T  INPUT
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_HANDLING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1487   text
*      -->P_1488   text
*      -->P_1489   text
*      -->P_1490   text
*      -->P_SY_MSGV2  text
*      -->P_SY_MSGV3  text
*      -->P_SY_MSGV4  text
*----------------------------------------------------------------------*
 FORM MESSAGE_HANDLING USING    $MSGTY
                              $MSGID
                              $MSGNO
                              $MSGV1
                              $MSGV2
                              $MSGV3
                              $MSGV4.
   DATA: L_MESSG LIKE MESSAGE.

   W_MESSAGE-TYPE       = $MSGID.
   W_MESSAGE-ID         = $MSGTY.
   W_MESSAGE-NUMBER     = $MSGNO.
   W_MESSAGE-MESSAGE_V1 = $MSGV1.
   W_MESSAGE-MESSAGE_V2 = $MSGV2.
   W_MESSAGE-MESSAGE_V3 = $MSGV3.
   W_MESSAGE-MESSAGE_V4 = $MSGV4.
   APPEND W_MESSAGE TO E_MESSAGE.
 ENDFORM.                    " MESSAGE_HANDLING
*&---------------------------------------------------------------------*
*& Module PBO9004 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9004 OUTPUT.
   PERFORM SET_STATUS.
 ENDMODULE.                 " PBO9004  OUTPUT
*&---------------------------------------------------------------------*
*& Module SET_DYNP9004 OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_DYNP9004 OUTPUT.

   /ZAK/BEVALLP-BUKRS = P_BUKRS.
* Company name
   SELECT SINGLE BUTXT INTO F_BUTXT FROM  T001
          WHERE  BUKRS  = P_BUKRS.

 ENDMODULE.                 " SET_DYNP9004  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  delete_pack
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_TABIX text
*----------------------------------------------------------------------*
 FORM DELETE_PACK CHANGING $TABIX LIKE SY-TABIX.

   DATA L_TEXTLINE1(80).
   DATA L_TEXTLINE2(80).
   DATA L_DIAGNOSETEXT1(80).
   DATA L_DIAGNOSETEXT2(80).
   DATA L_DIAGNOSETEXT3(80).
   DATA L_TITLE(40).
   DATA L_ANSWER.

   REFRESH: I_/ZAK/BEVALLSZ,
            I_/ZAK/BEVALLI.

   LOOP AT E_MESSAGE INTO W_MESSAGE WHERE TYPE CA 'EA'.
   ENDLOOP.
   IF SY-SUBRC EQ 0.
     MESSAGE E079.
*     Data upload is not possible!
   ENDIF.
   IF NOT E_MESSAGE[] IS INITIAL.
*    Loading texts
     MOVE 'Törlés folytatása'(001) TO L_TITLE.
     MOVE 'Ellenörzésnél előfordultak figyelmeztető üzenetek'(002)
                                          TO L_DIAGNOSETEXT1.
     MOVE 'Folytatja a feldolgozást?'(003)
                                          TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*     CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*       EXPORTING
*         DEFAULTOPTION = 'N'
*         DIAGNOSETEXT1 = L_DIAGNOSETEXT1
*         TEXTLINE1     = L_TEXTLINE1
*         TITEL         = L_TITLE
*         START_COLUMN  = 25
*         START_ROW     = 6
*       IMPORTING
*         ANSWER        = L_ANSWER.
     DATA L_QUESTION TYPE STRING.

     CONCATENATE L_DIAGNOSETEXT1
                 L_TEXTLINE1
                 INTO L_QUESTION SEPARATED BY SPACE.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR       = L_TITLE
*        DIAGNOSE_OBJECT             = ' '
         TEXT_QUESTION  = L_QUESTION
*        TEXT_BUTTON_1  = 'Ja'(001)
*        ICON_BUTTON_1  = ' '
*        TEXT_BUTTON_2  = 'Nein'(002)
*        ICON_BUTTON_2  = ' '
         DEFAULT_BUTTON = '2'
*        DISPLAY_CANCEL_BUTTON       = 'X'
*        USERDEFINED_F1_HELP         = ' '
         START_COLUMN   = 25
         START_ROW      = 6
*        POPUP_TYPE     =
       IMPORTING
         ANSWER         = L_ANSWER.
     IF L_ANSWER EQ '1'.
       MOVE 'J' TO L_ANSWER.
     ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.1
*    You can go anyway
   ELSE.
     MOVE 'J' TO L_ANSWER.
   ENDIF.
*    You can delete the database
   IF L_ANSWER EQ 'J'.
* /zak/devallp deletion code should be 'X'
     SELECT SINGLE * INTO W_/ZAK/BEVALLP FROM  /ZAK/BEVALLP
     WHERE BUKRS EQ P_BUKRS AND
           PACK  EQ /ZAK/BEVALLP-PACK.
     IF SY-SUBRC EQ 0.
*++1765 #01.
*       W_/ZAK/ENVALLP-DATE = SY-DATE.
*       W_/ZAK/BEVALLP-UZEIT = SY-UZEIT.
*       W_/ZAK/BEVALLP-UNAME = SY-UNAME.
       W_/ZAK/BEVALLP-DELDATE = SY-DATUM.
       W_/ZAK/BEVALLP-DELTIME = SY-UZEIT.
       W_/ZAK/BEVALLP-DELUSER = SY-UNAME.
*--1765 #01.
       W_/ZAK/BEVALLP-XLOEK = 'X'.
       MODIFY /ZAK/BEVALLP FROM W_/ZAK/BEVALLP.
     ENDIF.
ENHANCEMENT-POINT /ZAK/TECH_MOL_01 SPOTS /ZAK/TECH_ES .

* the statistical flag modification, only full data provision
* possible with repetition.
     SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
     WHERE BUKRS  EQ P_BUKRS AND
           BTYPE  EQ P_BTYPE AND
           BSZNUM EQ W_/ZAK/BEVALLSZ-BSZNUM AND
           XFULL  EQ 'X'.
     IF SY-SUBRC EQ 0.
* He admits. When uploading to self-rev., it is the same as the previous index
* tax service and tax number items as statistical items
* must be marked.
       CALL FUNCTION '/ZAK/STAPO_EXIT'
         EXPORTING
           I_BUKRS = P_BUKRS
           I_BTYPE = P_BTYPE
           I_PACK  = /ZAK/BEVALLP-PACK.
*          TABLES
*               T_ANALYTICS = I_ANALYTICS[].
     ENDIF.
* Declaration data service cancellations
     SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
*++2165 #07.
*        WHERE BUKRS EQ P_BUKRS AND
        WHERE
*--2165 #07.
              PACK  EQ /ZAK/BEVALLP-PACK.
* Declaration analytics cancellations
     SELECT * INTO TABLE I_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
*++2165 #07.
*        WHERE BUKRS EQ P_BUKRS AND
        WHERE
*--2165 #07.
              PACK  EQ /ZAK/BEVALLP-PACK.
*++BG 2006/05/29
*     LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*       DELETE /ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA.
*     ENDLOOP.
     DELETE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
*--BG 2006/05/29
*++1365 #16.
*++2165 #07.
*     DELETE FROM /ZAK/AFA_SZLA WHERE BUKRS EQ P_BUKRS
*                                AND PACK EQ /ZAK/BEVALLP-PACK.
     DELETE FROM /ZAK/AFA_SZLA WHERE  PACK  EQ /ZAK/BEVALLP-PACK.
*--2165 #07.
*--1365 #16.
ENHANCEMENT-POINT /ZAK/TECH_TELENOR_01 SPOTS /ZAK/TECH_ES .

     IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
* the /zak/bevalli table flag must be set to empty
       SORT I_/ZAK/BEVALLSZ BY BUKRS BTYPE GJAHR MONAT.
       SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
       FOR ALL ENTRIES IN I_/ZAK/BEVALLSZ
       WHERE BUKRS EQ I_/ZAK/BEVALLSZ-BUKRS AND
             BTYPE EQ I_/ZAK/BEVALLSZ-BTYPE AND
             GJAHR EQ I_/ZAK/BEVALLSZ-GJAHR AND
             MONAT EQ I_/ZAK/BEVALLSZ-MONAT AND
             ZINDEX EQ I_/ZAK/BEVALLSZ-ZINDEX.

       LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ.
         DELETE /ZAK/BEVALLSZ FROM W_/ZAK/BEVALLSZ.
         DELETE I_/ZAK/BEVALLSZ.
       ENDLOOP.

*++BG 2010/01/08
*      You have to go through the BEVALLI posts, because it is not certain
*      an upload ID is only valid for one period!!!
       LOOP AT I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
*       READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI INDEX 1.
*       IF SY-SUBRC EQ 0.
*Define a new status if there is a record then 'F' if there is not
*we delete it
         SELECT COUNT( * ) FROM /ZAK/BEVALLSZ
                          WHERE BUKRS = W_/ZAK/BEVALLI-BUKRS
                            AND BTYPE = W_/ZAK/BEVALLI-BTYPE
                            AND GJAHR = W_/ZAK/BEVALLI-GJAHR
                            AND MONAT = W_/ZAK/BEVALLI-MONAT
                            AND ZINDEX = W_/ZAK/BEVALLI-ZINDEX.
         IF SY-SUBRC EQ 0.
           MOVE 'F' TO W_/ZAK/BEVALLI-FLAG.
           CLEAR W_/ZAK/BEVALLI-DWNDT.
           W_/ZAK/BEVALLI-DATUM = SY-DATUM.
           W_/ZAK/BEVALLI-UZEIT = SY-UZEIT.
           W_/ZAK/BEVALLI-UNAME = SY-UNAME.
           MODIFY /ZAK/BEVALLI FROM W_/ZAK/BEVALLI.
*        There is no record, we will delete the line
         ELSE.
*          DELETE /ZAK/BEVALLI FROM TABLE I_/ZAK/BEVALLI.
           DELETE /ZAK/BEVALLI FROM W_/ZAK/BEVALLI.
         ENDIF.
       ENDLOOP.
*      ENDIF.
*--BG 2010/01/08
     ENDIF.
*--BG 2006/06/23

*++1665 #16.
ENHANCEMENT-POINT /ZAK/ZAK_ZF_TECH_01 SPOTS /ZAK/TECH_ES .
*--1665 #16.

*++0001 2008.04.07  BG (FMC)
     READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL INDEX 1.
     IF W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_ONYB.
       REFRESH I_/ZAK/ANALITIKA.
       SELECT * INTO TABLE I_/ZAK/ANALITIKA
                FROM /ZAK/ANALITIKA
*++2165 #07.
*               WHERE BUKRS EQ P_BUKRS
*                 AND ONYB_PACK EQ /ZAK/BEVALLP-PACK
               WHERE
                     ONYB_PACK EQ /ZAK/BEVALLP-PACK
*--2165 #07.
                 AND ONYBF EQ 'X'.
       CLEAR: W_/ZAK/ANALITIKA-ONYB_PACK,
              W_/ZAK/ANALITIKA-ONYBF.
       MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA
              TRANSPORTING ONYBF ONYB_PACK
              WHERE BUKRS EQ P_BUKRS.
       UPDATE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
     ENDIF.
*--0001 2008.04.07  BG (FMC)
     MESSAGE I080 WITH /ZAK/BEVALLP-PACK.
   ENDIF.


 ENDFORM.                    " delete_pack
*&---------------------------------------------------------------------*
*&      Form  CALL_9004
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_9004.
   CALL SCREEN 9004.
 ENDFORM.                                                   " CALL_9004
*&---------------------------------------------------------------------*
*& Module user_command_9004 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9004 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'DELE'.
       PERFORM CHECK_PACK.
       PERFORM DELETE_PACK CHANGING V_TABIX.
       SET SCREEN 0.
       LEAVE SCREEN.
     WHEN OTHERS.
   ENDCASE.
 ENDMODULE.                 " user_command_9004  INPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'EXIT'.
       SET SCREEN 0.
       LEAVE SCREEN.

     WHEN 'BACK'.
       SET SCREEN 0.
       LEAVE SCREEN.
   ENDCASE.
 ENDMODULE.                 " USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Form  popup
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM POPUP.

   DATA: L_ANSWER,
         L_TEXT(40) TYPE C.

   CONCATENATE 'Szeretné a' /ZAK/BEVALLP-PACK 'adatait'
   INTO L_TEXT SEPARATED BY SPACE.
*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*     EXPORTING
*       DEFAULTOPTION = 'N'
*       TEXTLINE1     = L_TEXT
*       TEXTLINE2     = TEXT-002
*       TITEL         = TEXT-003
*       START_COLUMN  = 40
*       START_ROW     = 6
**      CANCEL_DISPLAY = 'X'
*     IMPORTING
*       ANSWER        = L_ANSWER.
   DATA L_QUESTION TYPE STRING.

   CONCATENATE L_TEXT TEXT-002 INTO L_QUESTION SEPARATED BY SPACE.
*
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR       = TEXT-003
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION  = L_QUESTION
*      TEXT_BUTTON_1  = 'Ja'(001)
*      ICON_BUTTON_1  = ' '
*      TEXT_BUTTON_2  = 'Nein'(002)
*      ICON_BUTTON_2  = ' '
       DEFAULT_BUTTON = '2'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
       START_COLUMN   = 40
       START_ROW      = 6
*      POPUP_TYPE     =
*      IV_QUICKINFO_BUTTON_1       = ' '
*      IV_QUICKINFO_BUTTON_2       = ' '
     IMPORTING
       ANSWER         = L_ANSWER
*   TABLES
*      PARAMETER      =
*   EXCEPTIONS
*      TEXT_NOT_FOUND = 1
*      OTHERS         = 2
     .
   IF L_ANSWER EQ '1'.
     L_ANSWER = 'J'.
   ELSE.
     L_ANSWER = 'N'.
   ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 2016.07.12

 ENDFORM.                    " popup
*&---------------------------------------------------------------------*
*& Module CHECK_PACK9004 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_PACK9004 INPUT.
   PERFORM CHECK_PACK.
 ENDMODULE.                 " CHECK_PACK9004  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_pack
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_PACK.
   DATA: I_BEVALLSZ TYPE STANDARD TABLE OF /ZAK/BEVALLSZ  INITIAL SIZE 0.
   REFRESH: E_MESSAGE,I_BEVALLSZ,I_/ZAK/BEVALLD.

* Check /zak/bevallp
   SELECT SINGLE * INTO W_/ZAK/BEVALLP FROM  /ZAK/BEVALLP
   WHERE BUKRS EQ P_BUKRS AND
         PACK  EQ /ZAK/BEVALLP-PACK.

   IF SY-SUBRC NE 0.
     MESSAGE E074 WITH /ZAK/BEVALLP-BUKRS /ZAK/BEVALLP-PACK.
   ENDIF.

*++1665 #16.
   IF NOT W_/ZAK/BEVALLP-ALOADED IS INITIAL.
     MESSAGE E363 WITH /ZAK/BEVALLP-PACK.
*   & package has been transferred to another system, please delete it there first!
   ENDIF.
*--1665 #16.

* confession
   SELECT * INTO TABLE I_BEVALLSZ FROM /ZAK/BEVALLSZ
*++2165 #07.
*      WHERE BUKRS EQ P_BUKRS AND
      WHERE
*--2165 #07.
            PACK  EQ /ZAK/BEVALLP-PACK.

* Deletion of the uploaded data should not be performed on a package that
* whose data service identifier in BEVALLSZ is a
* BEVALLD contains the program /ZAK/AFA_SAP_SEL.
*++0004 BG 2007.04.04
* or contains the program /ZAK/ONYB_SAP_SEL.
*--0004 BG 2007.04.04
*++2010.06.04 BG
* or /ZAK/ZAK_UREP_AP_SEL
*--2010.06.04 BG


   IF NOT I_BEVALLSZ[] IS INITIAL.
     SELECT * INTO TABLE I_/ZAK/BEVALLD FROM /ZAK/BEVALLD
     FOR ALL ENTRIES IN I_BEVALLSZ
     WHERE BUKRS EQ I_BEVALLSZ-BUKRS AND
           BTYPE EQ I_BEVALLSZ-BTYPE AND
           BSZNUM EQ I_BEVALLSZ-BSZNUM AND
*++0004 BG 2007.04.04
*++0001 2008.04.07  BG (FMC)
*         ( PROGRAMM EQ C_PROG_AFA OR
*           PROGRAMM EQ C_PROG_ONYB ).
*++2010.06.04 BG
          ( PROGRAMM EQ C_PROG_AFA OR
            PROGRAMM EQ C_PROG_UREP ).
*--2010.06.04 BG
*--0001 2008.04.07  BG (FMC)
     IF SY-DBCNT > 0.
       MESSAGE E169 WITH /ZAK/BEVALLP-BUKRS /ZAK/BEVALLP-PACK.
     ENDIF.
   ENDIF.
   LOOP AT I_BEVALLSZ INTO W_/ZAK/BEVALLSZ.
     IF W_/ZAK/BEVALLSZ-FLAG EQ 'T'.
       PERFORM MESSAGE_HANDLING USING '/ZAK/ZAK' 'W' '075'
                                    W_/ZAK/BEVALLSZ-GJAHR
                                    W_/ZAK/BEVALLSZ-MONAT
                                    SY-MSGV3
                                    SY-MSGV4 .
     ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'B'.
       PERFORM MESSAGE_HANDLING USING '/ZAK/ZAK' 'W' '076'
                                    W_/ZAK/BEVALLSZ-GJAHR
                                    W_/ZAK/BEVALLSZ-MONAT
                                    SY-MSGV3
                                    SY-MSGV4 .
     ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'Z'.
       PERFORM MESSAGE_HANDLING USING '/ZAK/ZAK' 'E' '077'
                                    W_/ZAK/BEVALLSZ-GJAHR
                                    W_/ZAK/BEVALLSZ-MONAT
                                    SY-MSGV3
                                    SY-MSGV4 .

     ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'X'.
       PERFORM MESSAGE_HANDLING USING '/ZAK/ZAK' 'E' '078'
                                    W_/ZAK/BEVALLSZ-GJAHR
                                    W_/ZAK/BEVALLSZ-MONAT
                                    SY-MSGV3
                                    SY-MSGV4 .
     ENDIF.
   ENDLOOP.
   SORT E_MESSAGE BY TYPE ID NUMBER MESSAGE_V1 MESSAGE_V2.
   DELETE ADJACENT DUPLICATES FROM E_MESSAGE
       COMPARING TYPE ID NUMBER MESSAGE_V1 MESSAGE_V2.
*   Manage messages
   IF NOT E_MESSAGE[] IS INITIAL.
     CALL FUNCTION '/ZAK/MESSAGE_SHOW'
       TABLES
         T_RETURN = E_MESSAGE.
   ENDIF.
 ENDFORM.                    " check_pack
*&---------------------------------------------------------------------*
*&      Form  modif_dynp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MODIF_DYNP.
   LOOP AT SCREEN.
     IF SCREEN-GROUP1 = 'DIS'.
       IF NOT V_FULL IS INITIAL.
         SCREEN-INPUT = 0.
         SCREEN-ACTIVE = 0.
       ELSE.
         SCREEN-INPUT = 1.
       ENDIF.
       MODIFY SCREEN.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " modif_dynp
*&---------------------------------------------------------------------*
*&      Form  READ_ADONEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
 FORM READ_ADONEM USING  $BUKRS LIKE /ZAK/BEVALL-BUKRS.

   REFRESH I_/ZAK/ADONEM.

   SELECT * INTO TABLE I_/ZAK/ADONEM FROM /ZAK/ADONEM
       WHERE BUKRS EQ $BUKRS.
 ENDFORM.                    " READ_ADONEM
*&---------------------------------------------------------------------*
*&      Form  call_popup
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_POPUP CHANGING $OK.

   DATA L_TEXTLINE1(80).
   DATA L_TEXTLINE2(80).
   DATA L_DIAGNOSETEXT1(100).
   DATA L_DIAGNOSETEXT2(80).
   DATA L_DIAGNOSETEXT3(80).
   DATA L_TITLE(40).
   DATA L_ANSWER.
   CLEAR $OK.
   IF P_DELE IS INITIAL.
*    Loading texts
     MOVE 'Feldolgozás folytatása' TO L_TITLE.
*'Sets a period controlled by APEH, the function does not
* revocable'
     MOVE TEXT-010 TO L_DIAGNOSETEXT1.
   ELSE.
*    Loading texts
     MOVE 'Feldolgozás folytatása' TO L_TITLE.
*'Sets a period controlled by APEH, the function does not
* revocable'
     MOVE TEXT-011 TO L_DIAGNOSETEXT1.
   ENDIF.
   MOVE 'Biztos, hogy végrehajtja?'
                                        TO L_TEXTLINE1.

   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR       = L_TITLE
*      DIAGNOSE_OBJECT = ' '
       TEXT_QUESTION  = L_DIAGNOSETEXT1
       TEXT_BUTTON_1  = 'Végrehajt'
*      ICON_BUTTON_1  = ' '
       TEXT_BUTTON_2  = 'Mégse'
*      ICON_BUTTON_2  = ' '
       DEFAULT_BUTTON = '2'
     IMPORTING
       ANSWER         = L_ANSWER.
   .

   IF L_ANSWER EQ '1'.
     $OK = 'X'.
   ENDIF.
 ENDFORM.                    " call_popup
*&---------------------------------------------------------------------*
*& Form DELETE_CUST_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DELETE_CUST_TABLE.
   IF NOT I_/ZAK/BEVALL[] IS INITIAL.
     DELETE /ZAK/BEVALL FROM TABLE I_/ZAK/BEVALL.
   ENDIF.
   IF NOT I_/ZAK/BEVALLT[] IS INITIAL.
     DELETE /ZAK/BEVALLT FROM TABLE I_/ZAK/BEVALLT.
   ENDIF.
   IF NOT I_/ZAK/BEVALLD[] IS INITIAL.
     DELETE /ZAK/BEVALLD FROM TABLE I_/ZAK/BEVALLD.
   ENDIF.
   IF NOT I_/ZAK/BEVALLDT[] IS INITIAL.
     DELETE /ZAK/BEVALLDT FROM TABLE I_/ZAK/BEVALLDT.
   ENDIF.
   IF NOT I_/ZAK/BEVALLC[] IS INITIAL.
     DELETE /ZAK/BEVALLC FROM TABLE I_/ZAK/BEVALLC.
   ENDIF.
   IF NOT I_/ZAK/BEVALLB[] IS INITIAL.
     DELETE /ZAK/BEVALLB FROM TABLE I_/ZAK/BEVALLB.
   ENDIF.
   IF NOT I_/ZAK/BEVALLBT[] IS INITIAL.
     DELETE /ZAK/BEVALLBT FROM TABLE I_/ZAK/BEVALLBT.
   ENDIF.
*++ BG 2006.03.28
*  Delete SZJA_CUST
   DELETE FROM /ZAK/SZJA_CUST WHERE BUKRS EQ P_BUKRS
                               AND BTYPE EQ P_BTYPE.
*  Delete BEVALLDEF
   DELETE FROM /ZAK/BEVALLDEF WHERE BUKRS EQ P_BUKRS
                               AND BTYPE EQ P_BTYPE.
*  Delete AFA_CUST
   DELETE FROM /ZAK/AFA_CUST  WHERE BTYPE EQ P_BTYPE.
*  Delete AFA_ATV
   DELETE FROM /ZAK/AFA_ATV   WHERE BUKRS EQ P_BUKRS
                               AND BTYPE EQ P_BTYPE.
*-- BG 2006.03.28

   MESSAGE I096 WITH P_BUKRS P_BTYPE .
 ENDFORM.                    " DELETE_CUST_TABLE
*&---------------------------------------------------------------------*
*&      Form  set_ranges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2013   text
*      -->P_2014   text
*----------------------------------------------------------------------*
 FORM SET_RANGES USING    $TOL
                          $IG
                          $ANALITIKA_MON.

   REFRESH R_MONAT.
   R_MONAT-SIGN   = 'I'.
   IF $TOL = $IG.
     R_MONAT-OPTION = 'EQ'.
     R_MONAT-LOW    = $ANALITIKA_MON.
     R_MONAT-HIGH   = $ANALITIKA_MON.
   ELSE.
     R_MONAT-OPTION = 'BT'.
     R_MONAT-LOW    = $TOL.
     R_MONAT-HIGH   = $IG.
   ENDIF.
   APPEND R_MONAT.
 ENDFORM.                    " set_ranges
*&---------------------------------------------------------------------*
*&      Form  FULL_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_MONAT  text
*      -->P_I_/ZAK/BEVALLI[] text
*      -->P_I_/ZAK/BEVALLSZ[] text
*----------------------------------------------------------------------*
 FORM FULL_PERIOD USING    $/ZAK/BEVALLI  LIKE I_/ZAK/BEVALLI
                           $/ZAK/BEVALLSZ LIKE I_/ZAK/BEVALLSZ
                           $/ZAK/BEVALLD  LIKE I_/ZAK/BEVALLD
                           $MONAT
                           $GJAHR
                           $ZINDEX LIKE W_/ZAK/BEVALLI-ZINDEX.

   DATA: L_NUM   LIKE W_/ZAK/BEVALLSZ-MONAT,
         L_INDEX LIKE W_/ZAK/BEVALLI-ZINDEX.

* reporting periods
   DATA: SET_BEVI  TYPE STANDARD TABLE OF /ZAK/BEVALLI    INITIAL SIZE 0,
         SET_BEVSZ TYPE STANDARD TABLE OF /ZAK/BEVALLSZ  INITIAL SIZE 0.

   REFRESH: SET_BEVI,SET_BEVSZ.

*++0002 BG 2011.09.20

   L_INDEX = $ZINDEX.

   LOOP AT I_BUKRS.
*     CLEAR: L_NUM,L_INDEX.
*     L_INDEX = $ZINDEX.
     CLEAR: L_NUM.
*     SORT $/ZAK/BEVALLI BY GJAHR MONAT ZINDEX DESCENDING.
*--0002 BG 2011.09.20
     LOOP AT $/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.
       DO 12 TIMES.
         L_NUM = R_MONAT-LOW + SY-INDEX - 1.
         IF L_NUM > R_MONAT-HIGH.
           CLEAR: L_NUM.
           EXIT.
         ENDIF.
         CLEAR: W_/ZAK/BEVALLSZ,W_/ZAK/BEVALLI.
         READ TABLE $/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
*++0002 BG 2011.09.20
*                  WITH KEY BSZNUM = W_/ZAK/BEVALLD-BSZNUM
                    WITH KEY  BUKRS = I_BUKRS-BUKRS
                    BSZNUM = W_/ZAK/BEVALLD-BSZNUM
*--0002 BG 2011.09.20
                    GJAHR = $GJAHR
                    MONAT = L_NUM.
         IF SY-SUBRC NE 0.
* there is no declaration for the data provision period, so I close it!
           MOVE-CORRESPONDING W_/ZAK/BEVALLD TO W_/ZAK/BEVALLSZ.
*++0002 2011.11.30 BG (Ness)
           W_/ZAK/BEVALLSZ-BUKRS = I_BUKRS-BUKRS.
*--0002 2011.11.30 BG (Ness)
           W_/ZAK/BEVALLSZ-ZINDEX = L_INDEX.
           W_/ZAK/BEVALLSZ-MONAT = L_NUM.
           W_/ZAK/BEVALLSZ-GJAHR = $GJAHR.
*++0002 2011.11.30 BG (Ness)
*           MOVE-CORRESPONDING W_/ZAK/BEVALLSZ TO W_/ZAK/BEVALLI.
*--0002 2011.11.30 BG (Ness)
           APPEND W_/ZAK/BEVALLSZ TO SET_BEVSZ.
*++0002 2011.11.30 BG (Ness)
*           APPEND W_/ZAK/BEVALLI TO SET_BEVI.
*--0002 2011.11.30 BG (Ness)
         ENDIF.
*++2365 #03.
         READ TABLE $/ZAK/BEVALLI TRANSPORTING NO FIELDS WITH KEY BUKRS  = I_BUKRS-BUKRS
                                                                 GJAHR  = $GJAHR
                                                                 MONAT  = L_NUM.
         IF SY-SUBRC NE 0.
           CLEAR W_/ZAK/BEVALLI.
           MOVE-CORRESPONDING W_/ZAK/BEVALLD TO W_/ZAK/BEVALLI.
           W_/ZAK/BEVALLI-BUKRS = I_BUKRS-BUKRS.
           W_/ZAK/BEVALLI-ZINDEX = L_INDEX.
           W_/ZAK/BEVALLI-MONAT = L_NUM.
           W_/ZAK/BEVALLI-GJAHR = $GJAHR.
           APPEND W_/ZAK/BEVALLI TO SET_BEVI.
         ENDIF.
*--2365 #03.
       ENDDO.
     ENDLOOP.
*++0002 BG 2011.09.20
   ENDLOOP.
*--0002 BG 2011.09.20

*++BG 2006/06/27
*  No need to upload!!!
*   APPEND LINES OF SET_BEVI TO $/ZAK/BEVALLI.
*--BG 2006/06/27
*++2365 #03.
   IF NOT SET_BEVSZ[] IS INITIAL.
*--2365 #03.
     APPEND LINES OF SET_BEVSZ TO $/ZAK/BEVALLSZ.
*++2365 #03.
   ENDIF.
   IF NOT SET_BEVI[] IS INITIAL.
     APPEND LINES OF SET_BEVI TO $/ZAK/BEVALLI.
   ENDIF.
   SORT $/ZAK/BEVALLI.
*--2365 #03.

*++0002 2011.11.30 BG (Ness)
   SORT $/ZAK/BEVALLSZ.
*--0002 2011.11.30 BG (Ness)

*++BG 2006/06/27
*  This is also unnecessary...
*   SORT $/ZAK/BEVALLI BY BUKRS BTYPE GJAHR MONAT.
*   DELETE ADJACENT DUPLICATES FROM $/ZAK/BEVALLI
*                         COMPARING BUKRS BTYPE GJAHR MONAT.
*--BG 2006/06/27

 ENDFORM.                    " FULL_PERIOD
*&---------------------------------------------------------------------*
*&      Form  SET_LARUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_W_UPD_BEVALLSZ_LARUN text
*----------------------------------------------------------------------*
 FORM SET_LARUN CHANGING $LARUN.
   DATA: L_STAMP LIKE  TZONREF-TSTAMPS.
   CLEAR L_STAMP.
* Last run time - timestamp /ZAK/BEVALLSZ-LARUN
   CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
     EXPORTING
       I_DATLO     = SY-DATLO
       I_TIMLO     = SY-TIMLO
     IMPORTING
       E_TIMESTAMP = L_STAMP.
   $LARUN = L_STAMP.
 ENDFORM.                    " SET_LARUN
*&---------------------------------------------------------------------*
*& Module check_bpart INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_BPART INPUT.
* I define the type of declaration for declaration type!
   IF NOT P_BTYPE IS INITIAL AND
          P_BPART IS INITIAL.
     PERFORM SET_BPART USING    P_BUKRS
                                P_BTYPE
                       CHANGING P_BPART.
   ENDIF.
   PERFORM GET_BTYPE USING  P_BUKRS
                            P_BPART
                            P_BTYPE
                            /ZAK/ANALITIKA-MONAT
                            /ZAK/ANALITIKA-GJAHR.

*   PERFORM DYNP_UPDATE USING '/ZAK/ANALITIKA-BTYPE'
*                             P_BTYPE.
 ENDMODULE.                 " check_bpart  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BPART  text
*      -->P_/ZAK/ANALITIKA_BTYPE  text
*      -->P_/ZAK/ANALITIKA_MONAT  text
*      -->P_/ZAK/ANALITIKA_GJAHR  text
*----------------------------------------------------------------------*
 FORM GET_BTYPE USING    $BUKRS
                         $BPART
                         $BTYPE
                         $MONAT
                         $GJAHR .

   DATA: L_BTYPE         TYPE /ZAK/BTYPE,
         L_TEXTLINE1(80),
         L_TEXTLINE2(80).

   CLEAR L_BTYPE.
   CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
     EXPORTING
       I_BUKRS     = $BUKRS
       I_BTYPART   = $BPART
       I_GJAHR     = $GJAHR
       I_MONAT     = $MONAT
     IMPORTING
       E_BTYPE     = L_BTYPE
     EXCEPTIONS
       ERROR_MONAT = 1
       ERROR_BTYPE = 2
       OTHERS      = 3.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   IF L_BTYPE NE $BTYPE.
     MOVE TEXT-012 TO L_TEXTLINE1.

     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
       EXPORTING
*        TITEL     = ' '
         TEXTLINE1 = L_TEXTLINE1
         TEXTLINE2 = L_TEXTLINE2
*        START_COLUMN = 25
*        START_ROW = 6
       .
     $BTYPE = L_BTYPE.

* I am updating the control tables because the btype has changed!
* General declaration data
     PERFORM READ_BEVALL USING $BUKRS
                               $BTYPE.
* Declaration data service setting
     PERFORM READ_BEVALLC USING $BUKRS
                                $BTYPE.
* Declaration data service data
     PERFORM READ_BEVALLD USING $BUKRS
                                $BTYPE.
* Declaration form data
     PERFORM READ_BEVALLB USING $BTYPE.
   ENDIF.
 ENDFORM.                    " GET_BTYPE
*&---------------------------------------------------------------------*
*&      Form  CHECK_BTYPE_BPART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_BTYPE_BPART.

 ENDFORM.                    " CHECK_BTYPE_BPART
*&---------------------------------------------------------------------*
*&      Form  SET_BPART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      <--P_P_BPART  text
*----------------------------------------------------------------------*
 FORM SET_BPART USING    $BUKRS
                         $BTYPE
                CHANGING $BPART.
   SELECT SINGLE BTYPART INTO $BPART FROM /ZAK/BEVALL
          WHERE BUKRS EQ $BUKRS AND
                BTYPE EQ $BTYPE.
 ENDFORM.                    " SET_BPART
*&---------------------------------------------------------------------*
*& Module CHECK_ANALYTICS INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_ANALITIKA INPUT.

* normal declaration
   IF NOT RADIO1 IS INITIAL.
     SELECT SINGLE * INTO W_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
            WHERE  BUKRS EQ P_BUKRS AND
                   BTYPE EQ P_BTYPE AND
                   GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
                   MONAT IN R_MONAT AND
                   ZINDEX EQ '000' AND
                   BOOK   EQ 'M' .
     IF SY-SUBRC EQ 0.
       MESSAGE E129 WITH /ZAK/ANALITIKA-GJAHR
                         /ZAK/ANALITIKA-MONAT.
     ENDIF.

* self-audited declaration
   ELSE.
     SELECT * INTO W_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
     UP TO 1 ROWS
        WHERE BUKRS EQ P_BUKRS AND
              BTYPE EQ P_BTYPE AND
              GJAHR EQ /ZAK/ANALITIKA-GJAHR AND
              MONAT IN R_MONAT AND
              ZINDEX NE '000' AND
              BOOK   EQ 'M'
              ORDER BY ZINDEX DESCENDING.
     ENDSELECT.
     IF SY-SUBRC EQ 0.
       MESSAGE E129 WITH /ZAK/ANALITIKA-GJAHR
                         /ZAK/ANALITIKA-MONAT.
     ENDIF.
   ENDIF.
ENHANCEMENT-POINT /ZAK/KATA_BOOK SPOTS /ZAK/TECH_ES .

 ENDMODULE.                 " CHECK_ANALITIKA  INPUT
*&---------------------------------------------------------------------*
*&      Form  DYNP_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIELDNAME  text
*      -->P_FIELDVALUE  text
*----------------------------------------------------------------------*
 FORM DYNP_UPDATE USING    $NAME
                           $VALUE.

   DATA: I_DYNPREAD TYPE TABLE OF DYNPREAD INITIAL SIZE 0.
   DATA: W_DYNPREAD TYPE DYNPREAD.

   CLEAR W_DYNPREAD.REFRESH I_DYNPREAD.

   W_DYNPREAD-FIELDNAME  = $NAME.
   W_DYNPREAD-FIELDVALUE = $VALUE.
   APPEND W_DYNPREAD TO I_DYNPREAD.

   CALL FUNCTION 'DYNP_VALUES_UPDATE'
     EXPORTING
       DYNAME               = SY-CPROG
       DYNUMB               = SY-DYNNR
     TABLES
       DYNPFIELDS           = I_DYNPREAD
     EXCEPTIONS
       INVALID_ABAPWORKAREA = 1
       INVALID_DYNPROFIELD  = 2
       INVALID_DYNPRONAME   = 3
       INVALID_DYNPRONUMMER = 4
       INVALID_REQUEST      = 5
       NO_FIELDDESCRIPTION  = 6
       UNDEFIND_ERROR       = 7
       OTHERS               = 8.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " DYNP_UPDATE
*++PTGSZLAA #04. 2014.04.28
*&---------------------------------------------------------------------*
*&      Form  CHECK_MONAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_MONAT .
   IF P_BTYPE EQ C_PTGSZLAA.
     IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '52'.
       MESSAGE E402.
*   Please enter the value of the period between 01-52!
     ENDIF.
   ELSE.
     IF NOT /ZAK/ANALITIKA-MONAT BETWEEN '01' AND '16'.
       MESSAGE E020.
*   Please enter the value of the period between 01-16!
     ENDIF.
   ENDIF.
* is there already a return for the given period?
   CLEAR W_/ZAK/BEVALLI.
* /ZAK/ADMITTED
   CLEAR:V_LAST_DATE, W_/ZAK/BEVALL.
* Determination of the last day of declaration

   PERFORM GET_LAST_DAY_OF_PERIOD USING /ZAK/ANALITIKA-GJAHR
                                        /ZAK/ANALITIKA-MONAT
*++PTGSZLAA #04. 2014.04.28
                                        /ZAK/ANALITIKA-BTYPE
*--PTGSZLAA #04. 2014.04.28
                                   CHANGING V_LAST_DATE.

   SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL FROM  /ZAK/BEVALL
       WHERE     BUKRS  = P_BUKRS
          AND    BTYPE  = P_BTYPE
          AND    DATBI  >= V_LAST_DATE.
   ENDSELECT.
* ...quarterly
   IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
     CASE /ZAK/ANALITIKA-MONAT.
       WHEN '01' OR '02' OR '03'.
         PERFORM SET_RANGES USING '01'
                                  '03'
                                  /ZAK/ANALITIKA-MONAT.
         IF /ZAK/ANALITIKA-MONAT NE '03'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '03'.
         ENDIF.
       WHEN '04' OR '05' OR '06'.
         PERFORM SET_RANGES USING '04'
                                  '06'
                                  /ZAK/ANALITIKA-MONAT.
         IF /ZAK/ANALITIKA-MONAT NE '06'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '06'.
         ENDIF.
       WHEN '07' OR '08' OR '09'.
         PERFORM SET_RANGES USING '07'
                                  '09'
                                  /ZAK/ANALITIKA-MONAT.
         IF /ZAK/ANALITIKA-MONAT NE '09'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '09'.
         ENDIF.

       WHEN '10' OR '11' OR '12'.
         PERFORM SET_RANGES USING '10'
                                  '12'
                                  /ZAK/ANALITIKA-MONAT.
         IF /ZAK/ANALITIKA-MONAT NE '12'.
           MESSAGE E063 WITH P_BUKRS P_BTYPE '12'.
         ENDIF.
     ENDCASE.
* ...annual
   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
     PERFORM SET_RANGES USING '01'
                              '12'
                              /ZAK/ANALITIKA-MONAT.
     IF /ZAK/ANALITIKA-MONAT NE '12'.
       MESSAGE E064 WITH P_BUKRS P_BTYPE '12'.
     ENDIF.
* ...havi
   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'H'.
     PERFORM SET_RANGES USING '01'
                              '01'
                              /ZAK/ANALITIKA-MONAT.
*++PTGSZLAA #04. 2014.04.28
   ELSEIF  W_/ZAK/BEVALL-BIDOSZ = 'W'.
     PERFORM SET_RANGES USING '01'
                              '01'
                              /ZAK/ANALITIKA-MONAT.
*--PTGSZLAA #04. 2014.04.28
*++2365 #03.
   ELSEIF  W_/ZAK/BEVALL-BIDOSZ = 'S'.
     PERFORM SET_RANGES USING W_/ZAK/BEVALL-DATAB+4(2)
                              W_/ZAK/BEVALL-DATBI+4(2)
                              /ZAK/ANALITIKA-MONAT.
*--2365 #03.
   ENDIF.

 ENDFORM.                    " CHECK_MONAT
*--PTGSZLAA #04. 28/04/2014

*&---------------------------------------------------------------------*
*&      Form  GET_CS_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_BUKCS_FLAG  text
*      -->P_I_BUKRS  text
*----------------------------------------------------------------------*
 FORM GET_CS_BUKRS TABLES   $I_BUKRS STRUCTURE /ZAK/AFACS_BUKRS
                            $R_BUKRS STRUCTURE RANGE_C4
                   USING    $BUKRS
                            $BUKCS_FLAG
                            $BUKCS
                            $BTYPE.

   DATA L_DATUM LIKE SY-DATUM.


   SELECT SINGLE MAX( DATBI ) INTO L_DATUM
                       FROM /ZAK/BEVALL
                      WHERE BUKRS EQ $BUKRS
                        AND BTYPE EQ $BTYPE.

   CALL FUNCTION '/ZAK/GET_BUKRS_FROM_BUKCS'
     EXPORTING
       I_BUKCS      = $BUKRS
       I_BTYPE      = $BTYPE
       I_DATUM      = L_DATUM
     IMPORTING
       E_BUKCS_FLAG = $BUKCS_FLAG
     TABLES
       T_BUKRS      = $I_BUKRS.

* We also upload the group company
   $I_BUKRS-BUKRS = $BUKRS.
   APPEND $I_BUKRS.

*Upload Range:
   LOOP AT $I_BUKRS.
     M_DEF $R_BUKRS 'I' 'EQ' $I_BUKRS-BUKRS SPACE.
   ENDLOOP.

*We define the group company
   CALL FUNCTION '/ZAK/GET_AFCS'
     EXPORTING
       I_BUKRS = $BUKRS
       I_BTYPE = $BTYPE
       I_DATUM = L_DATUM
     IMPORTING
       E_BUKCS = $BUKCS
* TABLES
*      T_BUKRS =
     .

 ENDFORM.                    " GET_CS_BUKRS
*++1565 #03.
*&---------------------------------------------------------------------*
*& Module CHECK_BUKCS INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_BUKCS INPUT.

   PERFORM CHECK_BUKCS USING  /ZAK/ANALITIKA-GJAHR
                              /ZAK/ANALITIKA-MONAT.

 ENDMODULE.                 " CHECK_BUKCS  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/ZAK/ANALITIKA_GJAHR  text
*      -->P_/ZAK/ANALITIKA_MONAT  text
*----------------------------------------------------------------------*
 FORM CHECK_BUKCS  USING    $GJAHR
                            $MONAT.

   DATA L_DATUM TYPE DATUM.

   CONCATENATE $GJAHR $MONAT '01' INTO L_DATUM.

*  We define the group company
   CALL FUNCTION '/ZAK/GET_AFCS'
     EXPORTING
       I_BUKRS = P_BUKRS
       I_BTYPE = P_BTYPE
       I_DATUM = L_DATUM
     IMPORTING
       E_BUKCS = V_BUKCS
*   TABLES
*      T_BUKRS =
     .
   IF NOT V_BUKCS IS INITIAL.
     MESSAGE E297 WITH V_BUKCS.
   ENDIF.

 ENDFORM.                    " CHECK_BUKCS
*--1565 #03.
*++2465 #03.
*&---------------------------------------------------------------------*
*& Module GET_BUKCS INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE GET_BUKCS INPUT.

   DATA L_DATUM LIKE SY-DATUM.
   DATA LI_BUKRS TYPE STANDARD TABLE OF /ZAK/AFACS_BUKRS INITIAL SIZE 0
                                                       WITH HEADER LINE.
   DATA LW_BUKRS TYPE /ZAK/AFACS_BUKRS.
   DATA L_BTYPE TYPE /ZAK/BTYPE.

   CONCATENATE /ZAK/ANALITIKA-GJAHR /ZAK/ANALITIKA-MONAT '01' INTO L_DATUM.

   IF P_BTYPE IS INITIAL.
     SELECT SINGLE BTYPE INTO L_BTYPE
                         FROM /ZAK/BEVALL
                        WHERE BUKRS EQ P_BUKRS
                          AND DATBI GE L_DATUM
                          AND DATAB LE L_DATUM
                          AND BTYPART EQ P_BPART.
   ELSE.
     L_BTYPE = P_BTYPE.
   ENDIF.


   CALL FUNCTION '/ZAK/GET_BUKRS_FROM_BUKCS'
     EXPORTING
       I_BUKCS = P_BUKRS
       I_BTYPE = L_BTYPE
       I_DATUM = L_DATUM
*    IMPORTING
*      E_BUKCS_FLAG       =
     TABLES
       T_BUKRS = LI_BUKRS.

* let's check if he is in the group in the given period!
   LOOP AT  LI_BUKRS INTO LW_BUKRS.
     READ TABLE I_BUKRS TRANSPORTING NO FIELDS WITH KEY BUKRS = LW_BUKRS.
     IF SY-SUBRC NE 0.
       APPEND LW_BUKRS TO I_BUKRS.
       SORT I_BUKRS.
       M_DEF R_BUKRS 'I' 'EQ' LW_BUKRS-BUKRS ''.
     ENDIF.
   ENDLOOP.

 ENDMODULE.
*--2465 #03.
