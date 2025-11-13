*&---------------------------------------------------------------------*
*& Program: Data file creator, viewer, manual posting program
*&---------------------------------------------------------------------*
 REPORT /ZAK/MAIN_VIEW MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: data file creator, viewer, manual posting program
*&---------------------------------------------------------------------*
*& Author            : Cserhegyi Tímea - fmc
*& Creation date     : 2006.01.05
*& Functional spec by: ________
*& SAP modul neve    : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of the modified lines)
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION      TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES xxxxxxxxxx
*&                                   replaced with the classical one
*&        2006/11/29   Balázs G.     Self-audit handling change
*& 0002   2007.01.03   Balázs G.     CL_GUI_FRONTEND_SERVICES reverted
*& 0003   2007.03.27   Balázs G.     Application quality handling
*& 0004   2007.05.25   Balázs G.     For the ABEV identifiers flagged in
*&                                   BEVALLB-ACTREAD only the postings
*&                                   that arrived for the current period
*&                                   must be considered, not the totals
*& 0005   2007.07.10   Balázs G.     When handling application quality,
*&                                   search for data only in the current
*&                                   period.
*& 0006   2007.07.23   Balázs G.     Due date determination based on the
*&                                   production calendar
*& 0007   2008.02.14   Balázs G.     Warning if there is another return
*&                                   type in the period
*&---------------------------------------------------------------------*


 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE /ZAK/MAIN_TOP.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
 TABLES: /ZAK/ANALITIKA_S,
         CSKS,
         AUFK.
*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
 CONSTANTS: C_CLOSED_Z(1) TYPE C VALUE 'Z',
            C_CLOSED_X(1) TYPE C VALUE 'X',
            C_NUM         TYPE C VALUE 'N',
            C_CHAR        TYPE C VALUE 'C'.

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
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
* Normal
 DATA:
   I_OUTTAB  TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
   I_OUTTABS TYPE HASHED  TABLE OF /ZAK/BEVALLALV
*       I_OUTTABS TYPE SORTED   TABLE OF /ZAK/BEVALLALV
                                   WITH UNIQUE DEFAULT KEY
*                                                   BUKRS
*                                                   BTYPE
*                                                   GJAHR
*                                                   MONAT
*                                                   ZINDEX
*                                                   ABEVAZ
*                                                   ADOAZON
*                                                   LAPSZ
                                            INITIAL SIZE 0,

   W_OUTTAB  TYPE /ZAK/BEVALLALV.
* Employee data
 DATA: I_OUTTAB_D TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB_D TYPE /ZAK/BEVALLALV.
 DATA: I_OUTTAB_L TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB_L TYPE /ZAK/BEVALLALV.

* Tax identification numbers
 DATA: BEGIN OF I_ADOAZON OCCURS 0,
         ADOAZON TYPE /ZAK/ADOAZON,
       END OF I_ADOAZON.


* Converted
 DATA: I_OUTTAB_C TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB_C TYPE /ZAK/BEVALLALV.

 DATA: BEGIN OF I_OUTTAB2 OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
         DATA: CELLTAB TYPE LVC_T_STYL.
 DATA: END OF I_OUTTAB2.

 DATA: W_OUTTAB2 LIKE I_OUTTAB2.
 DATA: W_OUTTAB3 TYPE /ZAK/ANALITIKA.

 DATA: BEGIN OF W_FILE,
         LINE(20),
         OP(1),
         VAL(100),
       END OF W_FILE.


 DATA: BEGIN OF I_FILE OCCURS 0,
         LINE(50),
       END OF I_FILE.

 DATA: V_COUNTER TYPE I.

* ALV handling variables
 DATA: V_OK_CODE           LIKE SY-UCOMM,
       V_SAVE_OK           LIKE SY-UCOMM,
       V_REPID             LIKE SY-REPID,
       V_ANSWER,
       V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
       V_CONTAINER2        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',
       V_CONTAINER3        TYPE SCRFNAME VALUE '/ZAK/ZAK_9002',
       V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
       V_GRID2             TYPE REF TO CL_GUI_ALV_GRID,
       V_GRID3             TYPE REF TO CL_GUI_ALV_GRID,
       V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       V_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       V_CUSTOM_CONTAINER3 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

       I_FIELDCAT          TYPE LVC_T_FCAT,
       I_FIELDCAT2         TYPE LVC_T_FCAT,

       V_LAYOUT            TYPE LVC_S_LAYO,
       V_LAYOUT2           TYPE LVC_S_LAYO,

       V_VARIANT           TYPE DISVARIANT,
       V_VARIANT2          TYPE DISVARIANT,

       V_TOOLBAR           TYPE STB_BUTTON,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER3   TYPE REF TO LCL_EVENT_RECEIVER.

 DATA: X_SAVE,  "for parameter I_SAVE: modus for saving a layout
       X_LAYOUT TYPE DISVARIANT,
       G_EXIT   TYPE C.  "is set if the user has aborted a layout popup

 DATA: DEF_LAYOUT  TYPE DISVARIANT,     "default layout
       DEFAULT     TYPE C VALUE ' ',
       SPEC_LAYOUT TYPE DISVARIANT.

 DATA: V_LAST_DATE  TYPE DATUM,
       V_DISP_BTYPE TYPE /ZAK/BTYPE.

 DATA: V_I     TYPE I,
       V_DYNNR LIKE SY-DYNNR.

*++0003 BG 2007.03.27
 DATA: BEGIN OF I_ALKMIN OCCURS 0,
         BSZNUM  TYPE /ZAK/BSZNUM,
         ADOAZON TYPE /ZAK/ADOAZON,
         ABEVAZ  TYPE /ZAK/ABEVAZ,
         VALUE   TYPE NUMC2,
         LAPSZ   TYPE /ZAK/LAPSZ,
       END OF I_ALKMIN.
*--0003 BG 2007.03.27


* Macro definition for filling range
 DEFINE M_DEF.
   MOVE: &2      TO &1-sign,
         &3      TO &1-option,
         &4      TO &1-low,
         &5      TO &1-high.
   APPEND &1.
 END-OF-DEFINITION.

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


 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-103 FOR FIELD P_BTART.
 PARAMETERS: P_BTART LIKE /ZAK/BEVALL-BTYPART DEFAULT C_BTYPART_SZJA
                                             OBLIGATORY.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BTTEXT(40) TYPE C MODIF ID DIS.
 SELECTION-SCREEN END OF LINE.


 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-102 FOR FIELD P_BTYPE.
 PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLSZ-BTYPE NO-DISPLAY.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
 SELECTION-SCREEN END OF LINE.
 SELECTION-SCREEN: END OF BLOCK BL01.


 SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.


* PARAMETERS:
*             P_N(1) TYPE C NO-DISPLAY,
*             P_O(1) TYPE C NO-DISPLAY,
*             P_M(1) TYPE C NO-DISPLAY.

 SELECTION-SCREEN: END OF BLOCK BL02.


 SELECT-OPTIONS: S_GJAHR FOR /ZAK/BEVALLSZ-GJAHR  NO-DISPLAY.
 SELECT-OPTIONS: S_MONAT FOR /ZAK/BEVALLSZ-MONAT  NO-DISPLAY.
 SELECT-OPTIONS: S_INDEX FOR /ZAK/BEVALLSZ-ZINDEX NO-DISPLAY.



* SUBSCREEN 1
 SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
 SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
 PARAMETERS: P_N(1) TYPE C NO-DISPLAY.

 SELECT-OPTIONS: S_GJAHR1 FOR /ZAK/BEVALLSZ-GJAHR  NO INTERVALS
                      NO-EXTENSION,
                 S_MONAT1 FOR /ZAK/BEVALLSZ-MONAT  NO INTERVALS
                      NO-EXTENSION,
                 S_INDEX1 FOR /ZAK/BEVALLSZ-ZINDEX NO INTERVALS
                      NO-EXTENSION.
 SELECTION-SCREEN END OF BLOCK B1.
 SELECTION-SCREEN END OF SCREEN 100.


* SUBSCREEN 2
 SELECTION-SCREEN BEGIN OF SCREEN 200 AS SUBSCREEN.
 SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
 PARAMETERS: P_O(1) TYPE C NO-DISPLAY.
 SELECT-OPTIONS: S_GJAHR2 FOR /ZAK/BEVALLSZ-GJAHR  NO INTERVALS
                      NO-EXTENSION,
                 S_MONAT2 FOR /ZAK/BEVALLSZ-MONAT  NO INTERVALS
                      NO-EXTENSION,
                 S_INDEX2 FOR /ZAK/BEVALLSZ-ZINDEX NO INTERVALS
                      NO-EXTENSION.
*++BG 2006/07/19
 PARAMETERS: P_ESDAT LIKE SY-DATUM.
*--BG 2006/07/19
 SELECTION-SCREEN END OF BLOCK B2.
 PARAMETERS: P_CUM AS CHECKBOX DEFAULT 'X' MODIF ID DIS.
 SELECTION-SCREEN END OF SCREEN 200.

* SUBSCREEN 3
 SELECTION-SCREEN BEGIN OF SCREEN 300 AS SUBSCREEN.
 SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME.
 PARAMETERS: P_M(1) TYPE C NO-DISPLAY.

 SELECT-OPTIONS: S_GJAHR3 FOR /ZAK/BEVALLSZ-GJAHR  NO INTERVALS
                      NO-EXTENSION,
                 S_MONAT3 FOR /ZAK/BEVALLSZ-MONAT  NO INTERVALS
                      NO-EXTENSION,
                 S_INDEX3 FOR /ZAK/BEVALLSZ-ZINDEX NO INTERVALS
                      NO-EXTENSION.
 SELECTION-SCREEN END OF BLOCK B3.
 PARAMETERS: P_CUM3 AS CHECKBOX.
 SELECTION-SCREEN END OF SCREEN 300.

* STANDARD SELECTION SCREEN
 SELECTION-SCREEN: BEGIN OF TABBED BLOCK MYTAB FOR 6 LINES,
                   TAB (20) BUTTON1 USER-COMMAND PUSH1,
                   TAB (20) BUTTON2 USER-COMMAND PUSH2,
                   TAB (20) BUTTON3 USER-COMMAND PUSH3,
                   END OF BLOCK MYTAB.



 SELECTION-SCREEN: BEGIN OF BLOCK BL09 WITH FRAME TITLE TEXT-T09.
 PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
 SELECTION-SCREEN: END   OF BLOCK BL09.


 RANGES: R_MONAT FOR S_MONAT-LOW.

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
     CLEAR V_TOOLBAR.
     MOVE 3 TO V_TOOLBAR-BUTN_TYPE.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
     CLEAR V_TOOLBAR.
     MOVE '/ZAK/ZAK_MAN' TO V_TOOLBAR-FUNCTION.
     MOVE ICON_CREATE TO V_TOOLBAR-ICON.
     MOVE 'Manuális tétel rögzítése'(to3) TO V_TOOLBAR-QUICKINFO.
     MOVE 'Manuális tétel'(to4) TO V_TOOLBAR-TEXT.
     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
     IF P_M = C_X.
       MOVE C_X TO V_TOOLBAR-DISABLED.
     ELSE.
       MOVE SPACE TO V_TOOLBAR-DISABLED.
     ENDIF.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


* append a separator to normal toolbar
     CLEAR V_TOOLBAR.
     MOVE 3 TO V_TOOLBAR-BUTN_TYPE.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
     CLEAR V_TOOLBAR.
     MOVE '/ZAK/ZAK_ANA' TO V_TOOLBAR-FUNCTION.
     MOVE ICON_DISPLAY TO V_TOOLBAR-ICON.
     MOVE 'Analitika megjelenítése'(to1)
          TO V_TOOLBAR-QUICKINFO.
     MOVE 'Analitika megjelenítése'(to2) TO V_TOOLBAR-TEXT.
     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
     MOVE SPACE TO V_TOOLBAR-DISABLED.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

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

     DATA: I_ROWS TYPE LVC_T_ROW,
           W_ROWS TYPE LVC_S_ROW,
           S_OUT  TYPE /ZAK/BEVALLALV.
     DATA: I_ANA TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
           W_ANA TYPE /ZAK/ANALITIKA.

     CASE E_UCOMM.
* Display analytics
       WHEN '/ZAK/ZAK_ANA'.

         IF SY-DYNNR = '9000'.

           CLEAR:   W_OUTTAB2.
           REFRESH: I_OUTTAB2.

           CALL METHOD V_GRID->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
*           IF SY-TFILL <> 1.
*             MESSAGE I018.
*           ENDIF.


             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                       WHERE BTYPE = S_OUT-BTYPE
                         AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Analitikus sor?
*               IF W_/ZAK/BEVALLB-COLLECT = C_X.
*                 MESSAGE I081(/ZAK/ZAK).
*                 CONTINUE.
*               ENDIF.

                 CHECK W_/ZAK/BEVALLB-COLLECT = SPACE.

                 IF W_/ZAK/BEVALLB-ASZKOT = C_X.

*               SELECT * INTO TABLE I_OUTTAB2 FROM /ZAK/ANALITIKA
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                       AND ZINDEX  IN S_INDEX
                       AND ABEVAZ  = S_OUT-ABEVAZ
                       AND ADOAZON = S_OUT-ADOAZON.

                 ELSE.
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                       AND ZINDEX  IN S_INDEX
                       AND ABEVAZ  = S_OUT-ABEVAZ.
*                  AND ADOAZON = S_OUT-ADOAZON.

                 ENDIF.
               ENDIF.
             ENDLOOP.
           ENDIF.
         ELSEIF SY-DYNNR = '9002'.

           CLEAR:   W_OUTTAB2.
           REFRESH: I_OUTTAB2.

           CALL METHOD V_GRID3->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
*           IF SY-TFILL <> 1.
*             MESSAGE I018.
*           ENDIF.


             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB_L INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                         WHERE BTYPE = S_OUT-BTYPE
                           AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Analitikus sor?
*               IF W_/ZAK/BEVALLB-COLLECT = C_X.
*                 MESSAGE I081(/ZAK/ZAK).
*                 CONTINUE.
*               ENDIF.

                 CHECK W_/ZAK/BEVALLB-COLLECT = SPACE.

                 IF W_/ZAK/BEVALLB-ASZKOT = C_X.

*               SELECT * INTO TABLE I_OUTTAB2 FROM /ZAK/ANALITIKA
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                       AND ZINDEX  IN S_INDEX
                       AND ABEVAZ  = S_OUT-ABEVAZ
                       AND ADOAZON = S_OUT-ADOAZON.

                 ELSE.
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                       AND ZINDEX  IN S_INDEX
                       AND ABEVAZ  = S_OUT-ABEVAZ.
*                  AND ADOAZON = S_OUT-ADOAZON.

                 ENDIF.
               ENDIF.
             ENDLOOP.
           ELSE.


           ENDIF.
         ENDIF.

         DATA:  LT_CELLTAB TYPE LVC_T_STYL.
         DATA:  L_INDEX LIKE SY-TABIX.
* Field settings
         LOOP AT I_ANA INTO W_ANA.

           L_INDEX = SY-TABIX.

           MOVE-CORRESPONDING W_ANA TO W_OUTTAB2.
           APPEND W_OUTTAB2 TO I_OUTTAB2.

* Read row settings
           READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
              WITH KEY BTYPE = W_OUTTAB2-BTYPE
                       ABEVAZ = W_OUTTAB2-ABEVAZ.
           IF SY-SUBRC NE 0.
             CLEAR W_/ZAK/BEVALLB.
             SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                 WHERE BTYPE = W_OUTTAB2-BTYPE
                   AND ABEVAZ = W_OUTTAB2-ABEVAZ.
             INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
           ENDIF.

* Setting CELLTAB
           CLEAR: LT_CELLTAB,   W_OUTTAB2-CELLTAB.
           REFRESH: LT_CELLTAB, W_OUTTAB2-CELLTAB.



           IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.
             PERFORM FILL_CELLTAB USING 'RW'
                                  CHANGING LT_CELLTAB.

           ELSE.
             PERFORM FILL_CELLTAB USING 'RO'
                                  CHANGING LT_CELLTAB.

           ENDIF.


           INSERT LINES OF LT_CELLTAB INTO TABLE W_OUTTAB2-CELLTAB.
           MODIFY I_OUTTAB2 FROM W_OUTTAB2 INDEX L_INDEX.  "#EC CI_NOORDER

         ENDLOOP.


         CALL SCREEN 9001.


* Manual posting
       WHEN '/ZAK/ZAK_MAN'.

         IF SY-DYNNR = '9000'.
           CALL METHOD V_GRID->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
             IF SY-TFILL <> 1.
               MESSAGE I018.
             ENDIF.

             CHECK SY-TFILL = 1.

             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                       WHERE BTYPE = S_OUT-BTYPE
                         AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Row manually changeable?
                 IF W_/ZAK/BEVALLB-MANUAL <> C_X.
                   MESSAGE I043(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.

* Tax number is mandatory
                 IF W_/ZAK/BEVALLB-ASZKOT = C_X AND
                    S_OUT-ADOAZON = SPACE.
                   MESSAGE I106(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.


                 IF W_/ZAK/BEVALLB-FIELDTYPE = C_NUM.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-ORIG_VALUE = /ZAK/ANALITIKA_S-FIELD_N.
                   CLEAR /ZAK/ANALITIKA_S-FIELD_N.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.
                   CALL SCREEN 9100.
                 ELSE.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.

                   CALL SCREEN 9200.
                 ENDIF.
               ENDIF.
             ENDLOOP.
           ENDIF.

         ELSEIF SY-DYNNR = '9002'.
           CALL METHOD V_GRID3->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
             IF SY-TFILL <> 1.
               MESSAGE I018.
             ENDIF.

             CHECK SY-TFILL = 1.

             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB_L INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                       WHERE BTYPE = S_OUT-BTYPE
                         AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Row manually changeable?
                 IF W_/ZAK/BEVALLB-MANUAL <> C_X.
                   MESSAGE I043(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.

* Tax number is mandatory
                 IF W_/ZAK/BEVALLB-ASZKOT = C_X AND
                    S_OUT-ADOAZON = SPACE.
                   MESSAGE I106(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.


                 IF W_/ZAK/BEVALLB-FIELDTYPE = C_NUM.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-ORIG_VALUE = /ZAK/ANALITIKA_S-FIELD_N.
                   CLEAR /ZAK/ANALITIKA_S-FIELD_N.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.
                   CALL SCREEN 9100.
                 ELSE.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.

                   CALL SCREEN 9200.
                 ENDIF.
               ENDIF.
             ENDLOOP.
           ENDIF.


         ELSE.

         ENDIF.

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

     DATA: T_/ZAK/ANALITIKA  TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
           LT_/ZAK/ANALITIKA TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
           L_/ZAK/ANALITIKA  TYPE /ZAK/ANALITIKA,
           W_RETURN         TYPE BAPIRET2.

     ERROR_IN_DATA = SPACE.
* semantic checks

     LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD.
       CASE LS_GOOD-FIELDNAME.
* check if column XDEFT of this row was changed
         WHEN 'XDEFT'.
* Get new cell value to check it.
           CALL METHOD ER_DATA_CHANGED->GET_CELL_VALUE
             EXPORTING
               I_ROW_ID    = LS_GOOD-ROW_ID
               I_FIELDNAME = LS_GOOD-FIELDNAME
             IMPORTING
               E_VALUE     = L_XDEFT.
           READ TABLE I_OUTTAB2 INTO W_OUTTAB2 INDEX LS_GOOD-ROW_ID.
           IF SY-SUBRC = 0.
             W_OUTTAB2-XDEFT = L_XDEFT.

* Update
             CLEAR W_OUTTAB2-ZINDEX.
             CLEAR W_OUTTAB3.
             MOVE-CORRESPONDING W_OUTTAB2 TO W_OUTTAB3.
             APPEND W_OUTTAB3 TO T_/ZAK/ANALITIKA.
           ENDIF.


       ENDCASE.
     ENDLOOP.


     IF NOT T_/ZAK/ANALITIKA[] IS INITIAL.
       PERFORM CALL_UPDATE TABLES I_RETURN
                                  T_/ZAK/ANALITIKA
                           USING  W_OUTTAB2-BUKRS
                                  W_OUTTAB2-BTYPE
                                  W_OUTTAB2-BSZNUM
*                                 W_OUTTAB2-PACK
                                  SPACE
                                  SPACE
                                  SPACE.


       READ TABLE I_RETURN INTO W_RETURN WITH KEY TYPE = 'E'.
       IF SY-SUBRC <> 0.

         LOOP AT T_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.

           READ TABLE I_OUTTAB2 INTO W_OUTTAB2 WITH KEY
                BUKRS = W_/ZAK/ANALITIKA-BUKRS
                BTYPE = W_/ZAK/ANALITIKA-BTYPE
                GJAHR = W_/ZAK/ANALITIKA-GJAHR
                MONAT = W_/ZAK/ANALITIKA-MONAT
                ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                ADOAZON = W_/ZAK/ANALITIKA-ADOAZON
                BSZNUM = W_/ZAK/ANALITIKA-BSZNUM
                PACK   = W_/ZAK/ANALITIKA-PACK
                ITEM   = W_/ZAK/ANALITIKA-ITEM.
           IF SY-SUBRC = 0.
             W_OUTTAB2-XDEFT = W_/ZAK/ANALITIKA-XDEFT.
             MODIFY I_OUTTAB2 FROM W_OUTTAB2 INDEX SY-TABIX.
           ENDIF.

         ENDLOOP.


         READ TABLE T_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
            WITH KEY XDEFT = C_X.
         IF SY-SUBRC = 0.

           IF V_DYNNR <> '9002'.

             READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                 BUKRS = W_/ZAK/ANALITIKA-BUKRS
                 BTYPE = W_/ZAK/ANALITIKA-BTYPE
                 GJAHR = W_/ZAK/ANALITIKA-GJAHR
                 MONAT = W_/ZAK/ANALITIKA-MONAT
                 ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                 ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                 ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
             IF SY-SUBRC = 0.
               W_OUTTAB-FIELD_C = W_/ZAK/ANALITIKA-FIELD_C.
               MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
             ENDIF.

           ELSE.
             READ TABLE I_OUTTAB_L INTO W_OUTTAB WITH KEY
                 BUKRS = W_/ZAK/ANALITIKA-BUKRS
                 BTYPE = W_/ZAK/ANALITIKA-BTYPE
                 GJAHR = W_/ZAK/ANALITIKA-GJAHR
                 MONAT = W_/ZAK/ANALITIKA-MONAT
                 ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                 ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                 ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
             IF SY-SUBRC = 0.
               W_OUTTAB-FIELD_C = W_/ZAK/ANALITIKA-FIELD_C.
               MODIFY I_OUTTAB_L FROM W_OUTTAB INDEX SY-TABIX.
             ENDIF.

           ENDIF.
         ENDIF.
       ENDIF.

     ENDIF.


     CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.
     CALL METHOD V_GRID2->REFRESH_TABLE_DISPLAY.
     IF V_DYNNR = '9002'.
       CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
     ENDIF.

     REFRESH I_RETURN.

   ENDMETHOD.                    "HANDLE_DATA_CHANGED

 ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.

   BUTTON1 = TEXT-010.
   BUTTON2 = TEXT-020.
   BUTTON3 = TEXT-030.
   P_N = C_X.
   CLEAR: P_O, P_M.
   MYTAB-ACTIVETAB = 'BUTTON1'.
   MYTAB-PROG = SY-REPID.
   MYTAB-DYNNR = 100.

   GET PARAMETER ID 'BUK' FIELD P_BUKRS.
   V_REPID = SY-REPID.
   PERFORM READ_ADDITIONALS.
*++1765 #19.
* Authorization check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2265 #02.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/MAIN_VIEW_NEW'.
*--2265 #02.
*++1865 #03.
*  IF SY-SUBRC NE 0.
   IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
     MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
   ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN OUTPUT.


   PERFORM SET_SCREEN_ATTRIBUTES.
* The default layout is fetched the first time the PBO of the
* selection screen is called.
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
       DEFAULT = C_X.
     ENDIF.
   ENDIF.                             "default IS INITIAL


   PERFORM CONV_INDEX CHANGING S_INDEX1-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX2-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX3-LOW.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.

   SET PARAMETER ID 'BUK' FIELD P_BUKRS.

   CASE SY-DYNNR.
     WHEN 1000.
       CASE SY-UCOMM.
         WHEN 'PUSH1'.
           MYTAB-DYNNR = 100.
           MYTAB-ACTIVETAB = 'BUTTON1'.

           P_N = C_X.
           CLEAR: P_O, P_M.
           REFRESH: S_GJAHR2, S_MONAT2, S_INDEX2.
           REFRESH: S_GJAHR3, S_MONAT3, S_INDEX3.

         WHEN 'PUSH2'.
           MYTAB-DYNNR = 200.
           MYTAB-ACTIVETAB = 'BUTTON2'.

           P_O = C_X.
           CLEAR: P_N, P_M.
           REFRESH: S_GJAHR1, S_MONAT1, S_INDEX1.
           REFRESH: S_GJAHR3, S_MONAT3, S_INDEX3.

         WHEN 'PUSH3'.
           MYTAB-DYNNR = 300.
           MYTAB-ACTIVETAB = 'BUTTON3'.

           P_M = C_X.
           CLEAR: P_N, P_O.
           REFRESH: S_GJAHR1, S_MONAT1, S_INDEX1.
           REFRESH: S_GJAHR2, S_MONAT2, S_INDEX2.

       ENDCASE.
   ENDCASE.


   PERFORM CONV_INDEX CHANGING S_INDEX1-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX2-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX3-LOW.

   PERFORM CHECK_LAYOUT.
   PERFORM READ_ADDITIONALS.
*++2508 #10.
*   PERFORM CHECK_SEL_SCREEN.
*--2508 #10.
*  PERFORM CHECK_DATA USING 'S'.

 AT SELECTION-SCREEN ON P_BTART.

   PERFORM CHECK_BTART USING P_BTART.


 AT SELECTION-SCREEN ON BLOCK B1.
*++2508 #10.
   PERFORM CONV_INDEX CHANGING S_INDEX1-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX2-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX3-LOW.
   PERFORM CHECK_SEL_SCREEN.
*--2508 #10.
   PERFORM CHECK_DATA USING 'S'.
*++2508 #10.
   PERFORM CHECK_NAV_ELL USING P_BUKRS
                               P_BTART
                               S_GJAHR-LOW
                               S_MONAT-LOW.

 AT SELECTION-SCREEN ON BLOCK B2.
   PERFORM CONV_INDEX CHANGING S_INDEX1-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX2-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX3-LOW.
   PERFORM CHECK_SEL_SCREEN.
   PERFORM CHECK_DATA USING 'S'.
   PERFORM CHECK_NAV_ELL USING P_BUKRS
                               P_BTART
                               S_GJAHR-LOW
                               S_MONAT-LOW.
*--2508 #10.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_INDEX1-LOW.
   PERFORM SUB_F4_ON_INDEX USING '1'.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_INDEX2-LOW.
   PERFORM SUB_F4_ON_INDEX USING '2'.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_INDEX3-LOW.
   PERFORM SUB_F4_ON_INDEX USING '3'.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
   PERFORM SUB_F4_ON_VARI.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.

*  Authorization check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTART
                                 C_ACTVT_01.


* Normal, self-audit, display: populate S_ selections
   PERFORM FILL_S_RANGES.


   CHECK NOT S_GJAHR IS INITIAL AND
         NOT S_MONAT IS INITIAL AND
         NOT S_INDEX IS INITIAL.


* Determine return type
   PERFORM GET_BTYPE USING P_BUKRS
                           P_BTART
                           S_GJAHR-LOW
                           S_MONAT-LOW
                     CHANGING P_BTYPE.


* Set lock
   PERFORM ENQUEUE_PERIOD.


* Determine last day of the return
   PERFORM GET_LAST_DAY_OF_PERIOD USING S_GJAHR-LOW
                                        S_MONAT-LOW
                                   CHANGING V_LAST_DATE.

* General data of the return
   PERFORM READ_BEVALL  USING P_BUKRS
                              P_BTART
                              P_BTYPE
                              V_LAST_DATE.

*  Read the data structure of the return
   PERFORM READ_BEVALLB USING P_BUKRS
                              P_BTYPE.


*  Analitika
   PERFORM READ_ANALITIKA.

*++BG 2006.10.11 BG
*Not needed for SZJA (Kiss Márta, Lehel Attila)
   V_DISP_BTYPE = P_BTYPE.
** Popup: if there is a newer BTYPE
*   PERFORM POPUP_BTYPE_SEL CHANGING V_DISP_BTYPE.
*   IF V_DISP_BTYPE <> P_BTYPE.
**    Process indicator
*     PERFORM PROCESS_IND USING TEXT-P02.
*
*     PERFORM BTYPE_CONVERSION
*                              TABLES I_OUTTAB
*                              USING  P_BUKRS
*                                     P_BTYPE
*                                     V_DISP_BTYPE.
*   ENDIF.
*--BG 2006.10.11 BG

*  Calculate total rows
   IF P_M <> C_X.
*    Process indicator
     PERFORM PROCESS_IND USING TEXT-P02.
     PERFORM CALL_EXIT.
   ENDIF.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
 END-OF-SELECTION.
* Process indicator
   PERFORM PROCESS_IND USING TEXT-P03.

*  If not running in batch list
   IF SY-BATCH IS INITIAL.
     PERFORM LIST_DISPLAY.
*  BEVALLO update batch run
   ELSE.
     PERFORM BATCH_BEVALLO_UPDATE.
   ENDIF.


************************************************************************
* ALPROGRAMOK
************************************************************************

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


* Name of the return category
     IF NOT P_BTART IS INITIAL.
       SELECT DDTEXT UP TO 1 ROWS INTO P_BTTEXT FROM DD07T
          WHERE DOMNAME = '/ZAK/BTYPART'
            AND DDLANGUAGE = SY-LANGU
            AND DOMVALUE_L = P_BTART.
       ENDSELECT.
** Name of the return type
*     IF NOT P_BTYPE IS INITIAL.
*       SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
*          WHERE LANGU = SY-LANGU
*            AND BTYPE = P_BTYPE.


* VAT type returns self-audit cumulative
       IF P_O = C_X.
         SELECT * UP TO 1 ROWS FROM /ZAK/BEVALL INTO W_/ZAK/BEVALL
           WHERE    BUKRS = P_BUKRS
             AND    BTYPE = P_BTYPE.
         ENDSELECT.
         IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_AFA.
           P_CUM = C_X.
*         ELSE.
*           CLEAR P_CUM.
         ENDIF.

       ENDIF.

*     ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    " read_additionals
*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LIST_DISPLAY.

   CHECK NOT S_GJAHR IS INITIAL AND
        NOT S_MONAT IS INITIAL AND
        NOT S_INDEX IS INITIAL.

   IF P_BTART NE C_BTYPART_SZJA.
     CALL SCREEN 9000.
   ELSE.
*    The initial values are not needed 2006.05.26 /KM optimization
*     DELETE I_OUTTAB WHERE FIELD_C IS INITIAL
*                       AND FIELD_N IS INITIAL.

     LOOP AT I_OUTTAB INTO W_OUTTAB WHERE ABEVAZ+0(1) NE 'A'.
*++ BG 2007.06.22
       CLEAR W_OUTTAB_D.
*-- BG 2007.06.22
       MOVE-CORRESPONDING W_OUTTAB TO W_OUTTAB_D.
       APPEND W_OUTTAB_D TO I_OUTTAB_D.
       DELETE I_OUTTAB.
     ENDLOOP.

     CALL SCREEN 9000.
   ENDIF.
 ENDFORM.                    " list_display
*&---------------------------------------------------------------------*
*&      Module  PBO_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO_9000 OUTPUT.
   PERFORM SET_STATUS.

   IF V_CUSTOM_CONTAINER IS INITIAL.
     V_DYNNR = SY-DYNNR.
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
     REFRESH TAB.
* Normal
     IF P_N = C_X.
       CLEAR TAB.

       IF P_BTART NE C_BTYPART_SZJA.
         MOVE '/ZAK/ZAK_DOL' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.

       SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
       SET TITLEBAR 'MAIN9000'.
* Self-audit
     ELSEIF P_O = C_X.
       CLEAR TAB.

       IF P_BTART NE C_BTYPART_SZJA.
         MOVE '/ZAK/ZAK_DOL' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.

       SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
       SET TITLEBAR 'MAIN9000'.


* Display
     ELSE.

       CLEAR TAB.
       MOVE '/ZAK/ZAK_TXT' TO WA_TAB-FCODE.
       APPEND WA_TAB TO TAB.

       IF P_BTART NE C_BTYPART_SZJA.
         MOVE '/ZAK/ZAK_DOL' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.


       SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
       SET TITLEBAR 'MAIN9000'.
     ENDIF.

   ELSEIF SY-DYNNR = '9002'.

     CLEAR TAB.
     MOVE '/ZAK/ZAK_DOL' TO WA_TAB-FCODE.
     APPEND WA_TAB TO TAB.

     MOVE '/ZAK/ZAK_TXT' TO WA_TAB-FCODE.
     APPEND WA_TAB TO TAB.

     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR 'MAIN9002'.

   ELSE.
     REFRESH TAB.
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

* Exclude functions
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

   PS_LAYOUT-CWIDTH_OPT = C_X.
* allow to select multiple lines
   PS_LAYOUT-SEL_MODE = 'A'.


   CLEAR PS_VARIANT.
   PS_VARIANT-REPORT = V_REPID.

   IF NOT SPEC_LAYOUT IS INITIAL.
     MOVE-CORRESPONDING SPEC_LAYOUT TO PS_VARIANT.
   ELSEIF NOT DEF_LAYOUT IS INITIAL.
     MOVE-CORRESPONDING DEF_LAYOUT TO PS_VARIANT.
   ELSE.
   ENDIF.



   SORT I_OUTTAB.

   CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT           = PS_VARIANT
       I_SAVE               = 'A'
       I_DEFAULT            = C_X
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


   IF P_DYNNR = '9000' OR P_DYNNR = '9002'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/BEVALLALV'
         I_BYPASSING_BUFFER = C_X
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.


     LOOP AT PT_FIELDCAT INTO S_FCAT.

       IF S_FCAT-FIELDNAME = 'ROUND' OR
          S_FCAT-FIELDNAME = 'FIELD_NR' OR
          S_FCAT-FIELDNAME = 'FIELD_NRK'.
         S_FCAT-NO_OUT = C_X.
         S_FCAT-NO_ZERO = C_X.
       ELSEIF S_FCAT-FIELDNAME = 'FIELD_N'.
         S_FCAT-NO_ZERO = C_X.
       ENDIF.

*++BG 2006/11/29
       IF S_FCAT-FIELDNAME = 'FIELD_ON'   OR
          S_FCAT-FIELDNAME = 'FIELD_ONR'  OR
          S_FCAT-FIELDNAME = 'FIELD_ONRK' OR
          S_FCAT-FIELDNAME = 'OFLAG'.
         S_FCAT-NO_OUT = C_X.
       ENDIF.
*--BG 2006/11/29


       MODIFY PT_FIELDCAT FROM S_FCAT.

     ENDLOOP.

   ELSE.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
         I_BYPASSING_BUFFER = C_X
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.


     LOOP AT PT_FIELDCAT INTO S_FCAT.
       IF S_FCAT-FIELDNAME = 'BSEG_GJAHR' OR
          S_FCAT-FIELDNAME = 'BSEG_BELNR' OR
          S_FCAT-FIELDNAME = 'BSEG_BUZEI' OR
          S_FCAT-FIELDNAME = 'AUFNR'      OR
          S_FCAT-FIELDNAME = 'KOSTL'      OR
          S_FCAT-FIELDNAME = 'HKONT'      OR
          S_FCAT-FIELDNAME = 'PRCTR'.

         S_FCAT-HOTSPOT = C_X.
       ENDIF.

* Character row? Different field catalog!
* Editable field: XDEFT - radio button
       IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.
         IF S_FCAT-FIELDNAME = 'XDEFT' .
           S_FCAT-CHECKBOX = C_X.
         ENDIF.
       ENDIF.

       MODIFY PT_FIELDCAT FROM S_FCAT.

     ENDLOOP.

   ENDIF.

 ENDFORM.                    " build_fieldcat
*&---------------------------------------------------------------------*
*&      Module  PAI_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PAI_9000 INPUT.
   DATA: L_SUBRC LIKE SY-SUBRC.

   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.

* Request employee
     WHEN '/ZAK/ZAK_DOL'.
       CALL SCREEN 9900 STARTING AT 40 8.

* Return creator
     WHEN '/ZAK/ZAK_TXT'.

* Status check
* Normal return
* If all data provisions are not available it cannot start
       PERFORM CHECK_DATA USING 'D'.


* Conversion by data structure
* Append employee records
       PERFORM COPY_OUTTAB.


       PERFORM FILL_NORMAL_LINES CHANGING V_COUNTER.
       PERFORM FILL_STANDARD_LINES.

       IF NOT I_FILE[] IS INITIAL.
         PERFORM DOWNLOAD_FILE CHANGING L_SUBRC.
       ENDIF.

* Write /ZAK/BEVALLO
       IF L_SUBRC = 0.
         PERFORM UPDATE_BEVALLO  TABLES   I_OUTTAB_C
                                 CHANGING L_SUBRC.

* Update status /ZAK/BEVALLSZ
         IF L_SUBRC = 0.
           PERFORM STATUS_UPDATE.
         ENDIF.
       ENDIF.

*++BG 2007.05.09 Does not exit the list
*       IF SY-TCODE+0(1) = 'Z'.
*         LEAVE TO TRANSACTION SY-TCODE.
*       ELSE.
*         LEAVE PROGRAM.
*       ENDIF.
*--BG 2007.05.09

* Vissza
     WHEN 'BACK'.

       P_N = C_X.
       CLEAR: P_O, P_M.
       PERFORM CLEAR_ALL.

       IF SY-TCODE+0(1) = 'Z'.
         LEAVE TO TRANSACTION SY-TCODE.
       ELSE.
         LEAVE PROGRAM.
       ENDIF.

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
*&      Form  check_sel_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_SEL_SCREEN.

   CLEAR:   S_GJAHR, S_MONAT, S_INDEX.
   REFRESH: S_GJAHR, S_MONAT, S_INDEX.


* Normal, self-audit, display: populate S_ selections
   PERFORM FILL_S_RANGES.


   READ TABLE S_GJAHR INDEX 1.
   READ TABLE S_MONAT INDEX 1.
   READ TABLE S_INDEX INDEX 1.

* Determine return type
   CHECK NOT S_GJAHR IS INITIAL AND
         NOT S_MONAT IS INITIAL.
   PERFORM GET_BTYPE USING P_BUKRS
                           P_BTART
                           S_GJAHR-LOW
                           S_MONAT-LOW
                     CHANGING P_BTYPE.


* Determine last day of the return
   PERFORM GET_LAST_DAY_OF_PERIOD USING S_GJAHR-LOW
                                        S_MONAT-LOW
                                   CHANGING V_LAST_DATE.

* /ZAK/BEVALL
   PERFORM READ_BEVALL USING P_BUKRS
                             P_BTART
                             P_BTYPE
                             V_LAST_DATE.

* ...quarterly
   IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
     CASE S_MONAT-LOW.
       WHEN '01' OR '02' OR '03'.
         IF S_MONAT-LOW NE '03'.
           MESSAGE W063 WITH P_BUKRS P_BTYPE '03'.
         ENDIF.
       WHEN '04' OR '05' OR '06'.
         IF S_MONAT-LOW NE '06'.
           MESSAGE W063 WITH P_BUKRS P_BTYPE '06'.
         ENDIF.
       WHEN '07' OR '08' OR '09'.
         IF S_MONAT-LOW NE '09'.
           MESSAGE W063 WITH P_BUKRS P_BTYPE '09'.
         ENDIF.
       WHEN '10' OR '11' OR '12'.
         IF S_MONAT-LOW NE '12'.
           MESSAGE W063 WITH P_BUKRS P_BTYPE '12'.
         ENDIF.
     ENDCASE.
* ...annual
   ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
     IF S_MONAT-LOW NE '12'.
       MESSAGE W064 WITH P_BUKRS P_BTYPE '12'.
     ENDIF.
   ELSE.
   ENDIF.


   IF NOT S_GJAHR-LOW IS INITIAL AND
      NOT S_MONAT-LOW IS INITIAL AND
      S_INDEX-LOW IS INITIAL.

     CLEAR W_/ZAK/BEVALLI.
     SELECT * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS = P_BUKRS AND
              BTYPE = P_BTYPE AND
              GJAHR = S_GJAHR-LOW AND
              MONAT = S_MONAT-LOW.
       IF P_N = C_X.
         CHECK W_/ZAK/BEVALLI-FLAG NE C_CLOSED_X AND
               W_/ZAK/BEVALLI-FLAG NE C_CLOSED_Z AND
               W_/ZAK/BEVALLI-ZINDEX = '000'.
       ENDIF.

       IF P_O = C_X.
         CHECK W_/ZAK/BEVALLI-FLAG NE C_CLOSED_X AND
               W_/ZAK/BEVALLI-FLAG NE C_CLOSED_Z AND
               W_/ZAK/BEVALLI-ZINDEX NE '000'.
       ENDIF.

       IF P_M = C_X.
         CHECK W_/ZAK/BEVALLI-FLAG EQ C_CLOSED_X OR
               W_/ZAK/BEVALLI-FLAG EQ C_CLOSED_Z.
       ENDIF.
     ENDSELECT.


     S_INDEX-LOW = W_/ZAK/BEVALLI-ZINDEX.
*    PERFORM DYNP_UPDATE.

   ENDIF.


* Is there data for the specified period?
   IF P_M = SPACE.

     IF NOT S_GJAHR-LOW IS INITIAL AND
        NOT S_MONAT-LOW IS INITIAL AND
        NOT S_INDEX-LOW IS INITIAL.

       CLEAR W_/ZAK/BEVALLI.
       SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
          WHERE BUKRS = P_BUKRS AND
                BTYPE = P_BTYPE AND
                GJAHR = S_GJAHR-LOW AND
                MONAT = S_MONAT-LOW AND
                ZINDEX = S_INDEX-HIGH.

       IF SY-SUBRC NE 0.

         MESSAGE W013 WITH S_GJAHR-LOW S_MONAT-LOW S_INDEX-HIGH.

       ELSE.
         IF P_N = C_X.
           IF W_/ZAK/BEVALLI-FLAG EQ C_CLOSED_X OR
              W_/ZAK/BEVALLI-FLAG EQ C_CLOSED_Z OR
              W_/ZAK/BEVALLI-ZINDEX NE '000'.
             MESSAGE E015.
           ENDIF.
         ENDIF.

         IF P_O = C_X.
           IF W_/ZAK/BEVALLI-FLAG EQ C_CLOSED_X OR
              W_/ZAK/BEVALLI-FLAG EQ C_CLOSED_Z.
             MESSAGE E016.
           ENDIF.


           IF W_/ZAK/BEVALLI-ZINDEX EQ '000'.
             MESSAGE E113.
           ENDIF.

         ENDIF.

         IF P_M = C_X.
           IF W_/ZAK/BEVALLI-FLAG NE C_CLOSED_X AND
              W_/ZAK/BEVALLI-FLAG NE C_CLOSED_Z.
             MESSAGE E017.
           ENDIF.
         ENDIF.


       ENDIF.
     ENDIF.
   ENDIF.


* For self-audit: prerequisite that 000 is closed
   IF P_O = C_X.
     CLEAR W_/ZAK/BEVALLI.
     SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS = P_BUKRS AND
              BTYPE = P_BTYPE AND
              GJAHR = S_GJAHR-LOW AND
              MONAT = S_MONAT-LOW AND
              ZINDEX = '000'.

     IF SY-SUBRC = 0.

       IF W_/ZAK/BEVALLI-FLAG NE C_CLOSED_Z AND
          W_/ZAK/BEVALLI-FLAG NE C_CLOSED_X.
         MESSAGE E105(/ZAK/ZAK) WITH W_/ZAK/BEVALLI-BUKRS
                                W_/ZAK/BEVALLI-BTYPE
                                W_/ZAK/BEVALLI-GJAHR
                                W_/ZAK/BEVALLI-MONAT.
       ENDIF.
     ENDIF.


* only the currently open sequence number can be written or, if none is open, only
* the sequence number one greater than the last closed
     IF W_/ZAK/BEVALLI-FLAG = C_CLOSED_X.
       MESSAGE E189(/ZAK/ZAK).
     ENDIF.

     CHECK W_/ZAK/BEVALLI-FLAG NE C_CLOSED_X.

     DATA: L_INDEX(3) TYPE N.

     CLEAR W_/ZAK/BEVALLI.
     SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
        WHERE BUKRS = P_BUKRS AND
              BTYPE = P_BTYPE AND
              GJAHR = S_GJAHR-LOW AND
              MONAT = S_MONAT-LOW AND
              ZINDEX <> '000'     AND
              FLAG  NE C_CLOSED_Z        AND
              FLAG  NE C_X
              ORDER BY ZINDEX DESCENDING.

     IF SY-SUBRC = 0.

       READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
          INDEX 1.
       IF SY-SUBRC = 0.
         IF S_INDEX-HIGH NE W_/ZAK/BEVALLI-ZINDEX.
           MESSAGE E150(/ZAK/ZAK) WITH S_GJAHR-LOW
                                  S_MONAT-LOW
                                  W_/ZAK/BEVALLI-ZINDEX.
         ENDIF.
       ENDIF.
     ELSE.
       SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
          WHERE BUKRS = P_BUKRS AND
                BTYPE = P_BTYPE AND
                GJAHR = S_GJAHR-LOW AND
                MONAT = S_MONAT-LOW AND
                ( FLAG  = C_CLOSED_Z OR
                  FLAG  = C_CLOSED_X )
                ORDER BY ZINDEX DESCENDING.

       IF SY-SUBRC = 0.

         READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
            INDEX 1.
         IF SY-SUBRC = 0.

           W_/ZAK/BEVALLI-ZINDEX = W_/ZAK/BEVALLI-ZINDEX + 1.
           L_INDEX = W_/ZAK/BEVALLI-ZINDEX.
           IF S_INDEX-HIGH NE L_INDEX.
             MESSAGE E151(/ZAK/ZAK) WITH S_GJAHR-LOW
                                    S_MONAT-LOW
                                    L_INDEX.
           ENDIF.

         ENDIF.
       ENDIF.
     ENDIF.
*++BG 2006/07/19
*  Due date entry validation
     IF P_ESDAT IS INITIAL.
       MESSAGE E191(/ZAK/ZAK).
*     Please provide the due date value on the selection!
*++0006 BG 2007.07.23
*    Due date conversion
     ELSE.
       PERFORM GET_WORK_DAY USING P_ESDAT.
*--0006 BG 2007.07.23
     ENDIF.
*--BG 2006/07/19
   ENDIF.


 ENDFORM.                    " check_sel_screen
*&---------------------------------------------------------------------*
*&      Form  read_bevallb
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM READ_BEVALLB USING    $BUKRS
                            $BTYPE.
   REFRESH I_/ZAK/BEVALLB.

   SELECT * INTO TABLE I_/ZAK/BEVALLB FROM /ZAK/BEVALLB
       WHERE BTYPE = $BTYPE.

 ENDFORM.                    " read_bevallb
*&---------------------------------------------------------------------*
*&      Form  read_analitika
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM READ_ANALITIKA.
   DATA: L_COUNTER TYPE I.
   DATA: L_OUTTAB  LIKE W_OUTTAB.

   DATA: LI_/ZAK/BEVALLBA   TYPE STANDARD TABLE OF /ZAK/BEVALLB
                                INITIAL SIZE 0.
   DATA: LI_/ZAK/BEVALLBM   TYPE STANDARD TABLE OF /ZAK/BEVALLB
                                INITIAL SIZE 0.
   DATA: LI_/ZAK/BEVALLBT   TYPE STANDARD TABLE OF /ZAK/BEVALLB
                                INITIAL SIZE 0.


   DATA L_INDEX LIKE SY-TABIX.
*  Tax ID + sheet number
   DATA: BEGIN OF L_ADOAZON_SAVE,
           ADOAZON  LIKE /ZAK/ANALITIKA-ADOAZON,
           LAPSZ    LIKE /ZAK/ANALITIKA-LAPSZ,
           ABEV3(3) TYPE C,
         END OF L_ADOAZON_SAVE.


   DATA L_ADOAZON_LAPSZ LIKE L_ADOAZON_SAVE.
   DATA L_FIRST.
*  DATA L_SUBRC LIKE SY-SUBRC.


*++0004 BG 2007.05.25
   RANGES LR_ACTREAD_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.
*--0004 BG 2007.05.25

*++0007 BG 2008.02.14
   RANGES LR_BTYPE FOR /ZAK/BEVALL-BTYPE.
*--0007 BG 2008.02.14
*++2308 #09.
   DATA LI_ANALITIKA_TAO TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
*--2308 #09.
   REFRESH: I_/ZAK/ANALITIKA,
            I_OUTTAB.

* E - Annual
   IF W_/ZAK/BEVALL-BIDOSZ = 'E'.
     REFRESH R_MONAT.
     CLEAR R_MONAT.

     R_MONAT-SIGN   = 'I'.
     R_MONAT-OPTION = 'BT'.
     R_MONAT-LOW    = '01'.
     R_MONAT-HIGH   = '12'.
     APPEND R_MONAT.
   ENDIF.

* H - Havi
   IF W_/ZAK/BEVALL-BIDOSZ = 'H'.
     REFRESH R_MONAT.
     CLEAR R_MONAT.

     R_MONAT-SIGN   = 'I'.
     R_MONAT-OPTION = 'BT'.
     R_MONAT-LOW    = S_MONAT-LOW.
     R_MONAT-HIGH   = S_MONAT-LOW.
     APPEND R_MONAT.
   ENDIF.


* N - Quarterly
   IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
     REFRESH R_MONAT.
     CLEAR R_MONAT.

     R_MONAT-SIGN   = 'I'.
     R_MONAT-OPTION = 'BT'.

     IF S_MONAT-LOW <= '03'.
       R_MONAT-LOW    = '01'.
       R_MONAT-HIGH   = '03'.
       APPEND R_MONAT.
     ENDIF.

     IF S_MONAT-LOW > '03' AND
        S_MONAT-LOW <= '06'.
       R_MONAT-LOW    = '04'.
       R_MONAT-HIGH   = '06'.
       APPEND R_MONAT.
     ENDIF.

     IF S_MONAT-LOW > '06' AND
        S_MONAT-LOW <= '09'.
       R_MONAT-LOW    = '07'.
       R_MONAT-HIGH   = '09'.
       APPEND R_MONAT.
     ENDIF.

     IF S_MONAT-LOW > '09' AND
        S_MONAT-LOW <= '12'.
       R_MONAT-LOW    = '10'.
       R_MONAT-HIGH   = '12'.
       APPEND R_MONAT.
     ENDIF.

   ENDIF.

   IF P_M <> C_X.

*     IF P_BTART = C_BTYPART_SZJA.
*
*       SELECT ADOAZON INTO TABLE I_ADOAZON FROM /ZAK/ANALITIKA
*          WHERE BUKRS  = P_BUKRS
*            AND BTYPE  = P_BTYPE
*            AND GJAHR  = S_GJAHR-LOW
*            AND MONAT  IN R_MONAT
*            AND ZINDEX IN S_INDEX.
*
*       SORT I_ADOAZON.
**      No empty record needed
*       DELETE I_ADOAZON WHERE ADOAZON IS INITIAL.
*       DELETE ADJACENT DUPLICATES FROM I_ADOAZON.
*     ENDIF.


*++0007 BG 2008.02.14
*    Determine the return types belonging to the return category
     CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
       EXPORTING
         I_BUKRS   = P_BUKRS
         I_BTYPART = P_BTART
       TABLES
         T_BTYPE   = LR_BTYPE
*        T_/ZAK/BEVALL       =
*      EXCEPTIONS
*        ERROR_BTYPE        = 1
*        OTHERS    = 2
       .

     DELETE LR_BTYPE WHERE LOW = P_BTYPE.

     IF NOT LR_BTYPE[] IS INITIAL.
       SELECT COUNT( * )
                  FROM /ZAK/ANALITIKA
                   WHERE BUKRS  = P_BUKRS
                     AND BTYPE  IN LR_BTYPE
                     AND GJAHR  = S_GJAHR-LOW
                     AND MONAT  IN R_MONAT
                     AND ZINDEX IN S_INDEX.

       IF SY-SUBRC EQ 0.
         MESSAGE I254 WITH P_BTYPE.
*       The analytics contains an item that differs from the & return type!
       ENDIF.
     ENDIF.
*--0007 BG 2008.02.14


     SELECT * INTO TABLE I_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
        WHERE BUKRS  = P_BUKRS
          AND BTYPE  = P_BTYPE
          AND GJAHR  = S_GJAHR-LOW
          AND MONAT  IN R_MONAT
*          and zindex = s_index-low.
          AND ZINDEX IN S_INDEX.

     SORT I_/ZAK/BEVALLB BY BTYPE ABEVAZ.

*++BG 2007/02/08
     SELECT COUNT( * ) FROM /ZAK/NOSTAPO
                      WHERE BUKRS  EQ P_BUKRS
                        AND BTYPE  EQ P_BTYPE
                        AND MONAT  EQ S_MONAT1-LOW
                        AND ZINDEX EQ S_INDEX1-LOW.
     IF SY-SUBRC NE 0.
       DELETE I_/ZAK/ANALITIKA WHERE STAPO = C_X.
     ENDIF.
*--BG 2007/02/08

*++0004 BG 2007.05.25
*    Collect and process ABEV identifiers read for the current period
     LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB WHERE NOT ACTREAD IS INITIAL.
       M_DEF LR_ACTREAD_ABEVAZ 'I' 'EQ' W_/ZAK/BEVALLB-ABEVAZ SPACE.
     ENDLOOP.
*    For H-monthly data service
*++2108 #15.
*     IF NOT LR_ACTREAD_ABEVAZ[] IS INITIAL AND W_/ZAK/BEVALL-BIDOSZ = 'H'.
     IF NOT LR_ACTREAD_ABEVAZ[] IS INITIAL AND W_/ZAK/BEVALL-BIDOSZ CA 'EH'.
*--2108 #15.
       READ TABLE S_INDEX INDEX 1.
       DELETE  I_/ZAK/ANALITIKA WHERE ABEVAZ IN LR_ACTREAD_ABEVAZ
                                 AND ZINDEX NE S_INDEX-HIGH.
     ENDIF.
*--0004 BG 2007.05.25

*++0003 BG 2007.03.27
*    Process indicator
     PERFORM PROCESS_IND USING TEXT-P05.
*    Application quality
     PERFORM CALL_ALKMIN_PROCESS.
*--0003 BG 2007.03.27

* Process indicator
     PERFORM PROCESS_IND USING TEXT-P01.



     SORT I_/ZAK/ANALITIKA BY ADOAZON LAPSZ ABEVAZ.

*     LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB.
*       CLEAR W_OUTTAB.
*       CLEAR L_COUNTER.

     LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB.
*    ABEVs without tax ID
       IF W_/ZAK/BEVALLB-ASZKOT = SPACE.
         APPEND W_/ZAK/BEVALLB TO LI_/ZAK/BEVALLBA.
*    ABEVs with tax ID
       ELSE.
*        Due to optimized loading we only fill those
*        that have a calculation or transfer
         IF NOT W_/ZAK/BEVALLB-COLLECT    IS INITIAL OR
            NOT W_/ZAK/BEVALLB-SUM_ABEVAZ IS INITIAL OR
            NOT W_/ZAK/BEVALLB-GET_ABEVAZ IS INITIAL.
           APPEND W_/ZAK/BEVALLB TO LI_/ZAK/BEVALLBM.
         ENDIF.
       ENDIF.
     ENDLOOP.


*    Load aggregated data
     LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                          WHERE NOT ASZKOT IS INITIAL
                           AND  NOT SUM_ABEVAZ IS INITIAL.
       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                                WITH KEY
                                BTYPE  = W_/ZAK/BEVALLB-BTYPE
                                ABEVAZ = W_/ZAK/BEVALLB-SUM_ABEVAZ
                                BINARY SEARCH.
       IF SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEVAZ(1) NE 'A'.
         APPEND W_/ZAK/BEVALLB TO LI_/ZAK/BEVALLBM.
       ENDIF.
     ENDLOOP.

*    Load transfers
     LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                          WHERE NOT ASZKOT IS INITIAL
                           AND  NOT GET_ABEVAZ IS INITIAL.
       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                                WITH KEY
                                BTYPE  = W_/ZAK/BEVALLB-BTYPE
                                ABEVAZ = W_/ZAK/BEVALLB-GET_ABEVAZ
                                BINARY SEARCH.
       IF SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEVAZ(1) NE 'A'.
         APPEND W_/ZAK/BEVALLB TO LI_/ZAK/BEVALLBM.
       ENDIF.
     ENDLOOP.



     SORT LI_/ZAK/BEVALLBA.
     DELETE ADJACENT DUPLICATES FROM LI_/ZAK/BEVALLBA.
     SORT LI_/ZAK/BEVALLBM.
     DELETE ADJACENT DUPLICATES FROM LI_/ZAK/BEVALLBM.


     SORT LI_/ZAK/BEVALLBA BY BTYPE ABEVAZ.
     SORT LI_/ZAK/BEVALLBM BY BTYPE ABEVAZ.

     PERFORM PROCESS_IND USING TEXT-P02.

     CLEAR L_INDEX.

*    Read the first record
     READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA INDEX 1.
     IF W_/ZAK/ANALITIKA-ADOAZON IS INITIAL OR
        W_/ZAK/ANALITIKA-ABEVAZ(1) EQ 'A'.
       LI_/ZAK/BEVALLBT[] = LI_/ZAK/BEVALLBA[].
     ELSE.
       LI_/ZAK/BEVALLBT[] = LI_/ZAK/BEVALLBM[].
     ENDIF.
     MOVE W_/ZAK/ANALITIKA-ADOAZON TO L_ADOAZON_SAVE-ADOAZON.
     MOVE W_/ZAK/ANALITIKA-LAPSZ   TO L_ADOAZON_SAVE-LAPSZ.
     MOVE W_/ZAK/ANALITIKA-ABEVAZ(3) TO L_ADOAZON_SAVE-ABEV3.


     LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*            WHERE STAPO NE C_X.
*            AND ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
       PERFORM PROCESS_IND_ITEM USING '10000'
                                       L_INDEX
                                       TEXT-P02.
*++2308 #09.
*      Collect TAO records
       IF P_BTART EQ C_BTYPART_TAO AND  W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_DUMMY.
         APPEND W_/ZAK/ANALITIKA TO LI_ANALITIKA_TAO.
       ENDIF.
*--2308 #09.
*      Tax ID + sheet number
       MOVE W_/ZAK/ANALITIKA-ADOAZON TO   L_ADOAZON_LAPSZ-ADOAZON.
       MOVE W_/ZAK/ANALITIKA-LAPSZ   TO   L_ADOAZON_LAPSZ-LAPSZ.
       MOVE W_/ZAK/ANALITIKA-ABEVAZ(3) TO L_ADOAZON_LAPSZ-ABEV3.

*      IF L_ADOAZON_SAVE NE W_/ZAK/ANALITIKA-ADOAZON.
       IF L_ADOAZON_SAVE NE L_ADOAZON_LAPSZ.
*        Extension
         PERFORM APPEND_ABEVAZ TABLES LI_/ZAK/BEVALLBT
                               USING  L_ADOAZON_SAVE-ABEV3
                                      L_ADOAZON_SAVE-LAPSZ
                                      L_ADOAZON_SAVE-ADOAZON
                                      SPACE. "csak ABEV3 alapján

         IF W_/ZAK/ANALITIKA-ADOAZON IS INITIAL OR
            W_/ZAK/ANALITIKA-ABEVAZ(1) EQ 'A'.

           DELETE LI_/ZAK/BEVALLBA
                WHERE ABEVAZ(3) EQ L_ADOAZON_SAVE-ABEV3.

           LI_/ZAK/BEVALLBT[] = LI_/ZAK/BEVALLBA[].
*           Create 'A' sheets only once.
         ELSE.
*          If items remain to be processed this can occur when
*          it first changes from 'A' to 'M'
           IF NOT LI_/ZAK/BEVALLBA[] IS INITIAL.
             LI_/ZAK/BEVALLBT[] = LI_/ZAK/BEVALLBA[].
*            Extend to each record
             PERFORM APPEND_ABEVAZ TABLES LI_/ZAK/BEVALLBT
                                   USING  L_ADOAZON_SAVE-ABEV3 "ABEV3
                                          L_ADOAZON_SAVE-LAPSZ
                                          L_ADOAZON_SAVE-ADOAZON
                                          'ALL'. "Mindegyik kell
             FREE LI_/ZAK/BEVALLBA.
           ENDIF.
           LI_/ZAK/BEVALLBT[] = LI_/ZAK/BEVALLBM[].
         ENDIF.

         MOVE W_/ZAK/ANALITIKA-ADOAZON TO L_ADOAZON_SAVE-ADOAZON.
         MOVE W_/ZAK/ANALITIKA-LAPSZ   TO L_ADOAZON_SAVE-LAPSZ.
         MOVE W_/ZAK/ANALITIKA-ABEVAZ(3) TO L_ADOAZON_SAVE-ABEV3.

       ENDIF.

*      Collect tax IDs for self-audit items
       IF W_/ZAK/ANALITIKA-ZINDEX NE '000' AND
          NOT W_/ZAK/ANALITIKA-ADOAZON IS INITIAL AND
          W_/ZAK/ANALITIKA-ZINDEX EQ S_INDEX2-LOW.
         MOVE W_/ZAK/ANALITIKA-ADOAZON TO W_/ZAK/ONR_ADOAZON-ADOAZON.
         COLLECT W_/ZAK/ONR_ADOAZON INTO I_/ZAK/ONR_ADOAZON.
       ENDIF.

       CLEAR W_OUTTAB.

       READ TABLE LI_/ZAK/BEVALLBT INTO W_/ZAK/BEVALLB
                        WITH KEY BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                                 ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                                 BINARY SEARCH.
*      If found delete it
       IF SY-SUBRC EQ 0.
         DELETE LI_/ZAK/BEVALLBT INDEX SY-TABIX.
*      If missing read it from the original
       ELSE.
         READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                          WITH KEY BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                                   ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                                   BINARY SEARCH.

       ENDIF.

*      If it is tax exempt but a tax number is filled we skip it
*      figyelembe
       IF W_/ZAK/BEVALLB-ASZKOT  IS INITIAL AND
          NOT W_/ZAK/ANALITIKA-ADOAZON IS INITIAL.
         CLEAR W_/ZAK/ANALITIKA-ADOAZON.
       ENDIF.

*       PERFORM PROCESS_IND USING TEXT-P02.

*        CHECK W_/ZAK/ANALITIKA-ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
*        CHECK W_/ZAK/ANALITIKA-STAPO NE C_X.

       READ TABLE S_INDEX INDEX 1.
       W_/ZAK/ANALITIKA-ZINDEX = S_INDEX-HIGH.

       READ TABLE R_MONAT INDEX 1.
       W_/ZAK/ANALITIKA-MONAT = R_MONAT-HIGH.
       L_COUNTER = L_COUNTER + 1.

       IF W_/ZAK/BEVALLB-ASZKOT = SPACE.
         CLEAR W_/ZAK/ANALITIKA-ADOAZON.
       ENDIF.

* Karakteres
       IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.

*         READ TABLE I_OUTTABS INTO L_OUTTAB WITH KEY
*              BUKRS = W_/ZAK/ANALITIKA-BUKRS
*              BTYPE = W_/ZAK/ANALITIKA-BTYPE
*              GJAHR = W_/ZAK/ANALITIKA-GJAHR
*              MONAT = W_/ZAK/ANALITIKA-MONAT
*              ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
*              ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
*              ADOAZON = W_/ZAK/ANALITIKA-ADOAZON
*              LAPSZ  = W_/ZAK/ANALITIKA-LAPSZ
**             BINARY SEARCH
*              .
** If this key does not exist yet - save it
*         IF SY-SUBRC NE 0.

* Self-audit - due date
         IF P_O = C_X AND
            P_CUM = C_X AND
            W_/ZAK/BEVALLB-ESDAT_FLAG = C_X.
           CHECK W_/ZAK/ANALITIKA-ZINDEX = S_INDEX-HIGH.
         ENDIF.

         MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
         MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
         W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
         W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

         SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
           FROM  /ZAK/BEVALLBT
                WHERE  LANGU   = SY-LANGU
                AND    BTYPE   = W_OUTTAB-BTYPE
                AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

         W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.


         COLLECT W_OUTTAB INTO I_OUTTABS.

** Already exists with this key
**   No default text is handled for SZJA because there is no manual
*POSTING
*         ELSE.
*** This is the default text - I am modifying the saved one
*           IF NOT W_/ZAK/ANALITIKA-XDEFT IS INITIAL.
*             READ TABLE I_OUTTABS INTO W_OUTTAB WITH KEY
*                  BUKRS = W_/ZAK/ANALITIKA-BUKRS
*                  BTYPE = W_/ZAK/ANALITIKA-BTYPE
*                  GJAHR = W_/ZAK/ANALITIKA-GJAHR
*                  MONAT = W_/ZAK/ANALITIKA-MONAT
*                  ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
*                  ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
*                  ADOAZON = W_/ZAK/ANALITIKA-ADOAZON
**                 BINARY SEARCH
*                  .
*             IF SY-SUBRC = 0.
*               MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
*               MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
*               W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
*               W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
*
*               SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
*                 FROM  /ZAK/BEVALLBT
*                      WHERE  LANGU   = SY-LANGU
*                      AND    BTYPE   = W_OUTTAB-BTYPE
*                      AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
*
*               W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
*
*               DELETE I_OUTTABS INDEX SY-TABIX.
**               MODIFY I_OUTTABS FROM W_OUTTAB.
*               INSERT W_OUTTAB INTO I_OUTTABS INDEX SY-TABIX.
*             ENDIF.
*           ENDIF.
*         ENDIF.
* Numerikus
       ELSE.

         MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
         MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
*        If the field is calculated and analytics posts something
*        then delete it
         IF NOT W_/ZAK/BEVALLB-COLLECT IS INITIAL AND
            NOT W_OUTTAB-FIELD_N IS INITIAL.
           CLEAR W_OUTTAB-FIELD_N.
         ENDIF.

         W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
         W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

         SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
           FROM  /ZAK/BEVALLBT
                WHERE  LANGU   = SY-LANGU
                AND    BTYPE   = W_OUTTAB-BTYPE
                AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

         W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
         COLLECT W_OUTTAB INTO I_OUTTABS.
       ENDIF.

       DELETE I_/ZAK/ANALITIKA.

     ENDLOOP.


*    If the last record is 'A'
     IF W_/ZAK/ANALITIKA-ABEVAZ(1) EQ 'A' OR
*++BG 2006/08/09
        W_/ZAK/ANALITIKA-ABEVAZ EQ 'DUMMY'.
*--BG 2006/08/09
*    Extension
       PERFORM APPEND_ABEVAZ TABLES LI_/ZAK/BEVALLBT
                             USING  L_ADOAZON_SAVE-ABEV3
                                    L_ADOAZON_SAVE-LAPSZ
                                    L_ADOAZON_SAVE-ADOAZON
                                    'ALL'.  "csak ABEV3 alapján
     ELSE.
*    Extension
       PERFORM APPEND_ABEVAZ TABLES LI_/ZAK/BEVALLBT
                             USING  L_ADOAZON_SAVE-ABEV3
                                    L_ADOAZON_SAVE-LAPSZ
                                    L_ADOAZON_SAVE-ADOAZON
                                    SPACE.  "csak ABEV3 alapján

     ENDIF.


*++ HASHED ALGORITMUS
     SORT I_OUTTABS BY BUKRS BTYPE MONAT ZINDEX ABEVAZ ADOAZON LAPSZ
                       FIELD_C DESCENDING FIELD_N.

     DELETE ADJACENT DUPLICATES FROM I_OUTTABS COMPARING BUKRS
                                                         BTYPE
                                                         GJAHR
                                                         MONAT
                                                         ZINDEX
                                                         ABEVAZ
                                                         ADOAZON
                                                         LAPSZ.
*-- HASHED ALGORITMUS

     FREE I_/ZAK/ANALITIKA.

     I_OUTTAB[] = I_OUTTABS[].

     FREE I_OUTTABS.


     PERFORM PROCESS_IND USING TEXT-P02.

*     IF L_COUNTER = 0.

     FREE: LI_/ZAK/BEVALLBA, LI_/ZAK/BEVALLBM, LI_/ZAK/BEVALLBT.

     DATA: L_ROUND(20) TYPE C.
     PERFORM PROCESS_IND USING TEXT-P02.

     CLEAR L_INDEX.

     SORT I_/ZAK/BEVALLB BY BTYPE ABEVAZ.

     LOOP AT I_OUTTAB INTO W_OUTTAB.

       PERFORM PROCESS_IND_ITEM USING '100000'
                                      L_INDEX
                                      TEXT-P02.

* Total conversions

       CLEAR L_ROUND.

       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = W_OUTTAB-BTYPE
                   ABEVAZ = W_OUTTAB-ABEVAZ
                   BINARY SEARCH.

       IF SY-SUBRC = 0.
*++BG 2006/07/19
*        The due date must be taken from the selection for self-audit
         IF P_O = C_X AND W_/ZAK/BEVALLB-ESDAT_FLAG = C_X.
           MOVE P_ESDAT TO W_OUTTAB-FIELD_C.
         ENDIF.
*--BG 2006/07/19

*      Numerikus
         IF  W_/ZAK/BEVALLB-FIELDTYPE EQ 'N'.

           W_OUTTAB-ROUND = W_/ZAK/BEVALLB-ROUND.
*       if not w_/zak/bevallb-round is initial.
           WRITE W_OUTTAB-FIELD_N TO L_ROUND
               ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.


           REPLACE ',' WITH '.' INTO L_ROUND.
           W_OUTTAB-FIELD_NR = L_ROUND.

           W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
                                ( 10 ** W_/ZAK/BEVALLB-ROUND ).
*       endif.

*      Karakteres
         ELSE.
           CLEAR W_OUTTAB-WAERS.
         ENDIF.

         MODIFY I_OUTTAB FROM W_OUTTAB.

       ENDIF.
     ENDLOOP.
   ELSE.
     PERFORM PROCESS_IND USING TEXT-P02.

* Display closed period
     DATA: V_INDEX LIKE SY-TABIX.

     SELECT * INTO CORRESPONDING FIELDS OF TABLE I_OUTTAB
        FROM  /ZAK/BEVALLO
            WHERE  BUKRS    = P_BUKRS
            AND    BTYPE    = P_BTYPE
            AND    GJAHR    = S_GJAHR-LOW
            AND    MONAT    = S_MONAT-LOW
            AND    ZINDEX   = S_INDEX-HIGH.

     CLEAR L_INDEX.

     LOOP AT I_OUTTAB INTO W_OUTTAB.

       PERFORM PROCESS_IND_ITEM USING '100000'
                                       L_INDEX
                                       TEXT-P02.

       V_INDEX = SY-TABIX.

       SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
         FROM  /ZAK/BEVALLBT
              WHERE  LANGU   = SY-LANGU
              AND    BTYPE   = W_OUTTAB-BTYPE
              AND    ABEVAZ  = W_OUTTAB-ABEVAZ.


       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = W_OUTTAB-BTYPE
                   ABEVAZ = W_OUTTAB-ABEVAZ.
       IF SY-SUBRC = 0.
         MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
       ENDIF.

       MODIFY I_OUTTAB FROM W_OUTTAB INDEX V_INDEX.

     ENDLOOP.

   ENDIF.

   SORT I_OUTTAB.
   DELETE ADJACENT DUPLICATES FROM I_OUTTAB.
*++2308 #09.
   DATA LW_ANALITIKA TYPE /ZAK/ANALITIKA.
   DATA L_LAPSZ TYPE /ZAK/LAPSZ.
   DATA L_LAPSZ_SAVE TYPE /ZAK/LAPSZ.
   DATA L_SORSZ TYPE NUMC2.
   DATA L_MAX_SORSZ TYPE NUMC2.
   DATA L_SORINDEX TYPE /ZAK/SORINDEX.
   DATA L_SUBRC LIKE SY-SUBRC.
*  Collect tax IDs
   RANGES LR_LAPSZ FOR /ZAK/ANALITIKA-LAPSZ.

   DEFINE LM_GET_ABEV_TO_INDEX.
     CONCATENATE &1 &2 INTO l_sorindex.
     READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
           WITH KEY sorindex  = l_sorindex
                    nylapazon = &4.
     IF sy-subrc EQ 0.
       CLEAR &3.
       MOVE-CORRESPONDING w_/zak/bevallb TO w_outtab.
       w_outtab-bukrs  = p_bukrs.
       w_outtab-gjahr  = s_gjahr-low.
       w_outtab-monat  = r_monat-high.
       w_outtab-zindex = s_index-high.
       w_outtab-btype_disp  = w_outtab-btype.
       w_outtab-abevaz_disp = w_outtab-abevaz.
       w_outtab-waers  = c_huf.
       SELECT SINGLE abevtext INTO w_outtab-abevtext
         FROM  /zak/bevallbt
              WHERE  langu   = sy-langu
              AND    btype   = w_outtab-btype
              AND    abevaz  = w_outtab-abevaz.
       w_outtab-abevtext_disp = w_outtab-abevtext.
     ELSE.
       MOVE sy-subrc TO &3.
     ENDIF.
   END-OF-DEFINITION.

*  Process TAO
   IF P_BTART EQ C_BTYPART_TAO.
     LOOP AT LI_ANALITIKA_TAO INTO W_/ZAK/ANALITIKA.
       M_DEF LR_LAPSZ 'I' 'EQ' W_/ZAK/ANALITIKA-LAPSZ ''.
     ENDLOOP.
*++2308 #11.
     SORT LR_LAPSZ.
     DELETE ADJACENT DUPLICATES FROM LR_LAPSZ.
*--2308 #11.
*++2308 #12.
*     IF SY-SUBRC EQ 0.
     IF NOT LR_LAPSZ[] IS INITIAL.
*--2308 #12.
       CLEAR L_MAX_SORSZ.
*      Determine the largest row index
       LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                            WHERE NOT SORINDEX IS INITIAL
                              AND NYLAPAZON EQ C_BTYPART_TAO.

         IF W_/ZAK/BEVALLB-SORINDEX(2) > L_MAX_SORSZ.
           MOVE W_/ZAK/BEVALLB-SORINDEX(2) TO L_MAX_SORSZ.
         ENDIF.
       ENDLOOP.
       IF SY-SUBRC NE 0.
         MESSAGE E221 WITH P_BTART.
*        There is no "Row / column identifier" setting for the & return category!
       ENDIF.
*      Processing per tax ID
       SORT LR_LAPSZ.
       LOOP AT LR_LAPSZ.
*++2308 #11.
*         L_LAPSZ = 1.
         L_LAPSZ = LR_LAPSZ-LOW.
*--2308 #11.
         L_SORSZ = 1.
         CLEAR L_LAPSZ_SAVE.
         LOOP AT LI_ANALITIKA_TAO INTO LW_ANALITIKA WHERE LAPSZ EQ LR_LAPSZ-LOW.
*          Load data
           CLEAR W_OUTTAB.
           IF L_SORSZ > L_MAX_SORSZ.
             ADD 1 TO L_LAPSZ.
             L_SORSZ = 1.
           ENDIF.
           IF L_LAPSZ NE L_LAPSZ_SAVE.
*          B) Indicate to which ATP-01 sheet number it is related....
             READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                         WITH KEY ABEVAZ  = LW_ANALITIKA-FIELD_C.
             IF SY-SUBRC EQ 0.
               MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
               W_OUTTAB-BUKRS  = P_BUKRS.
               W_OUTTAB-GJAHR  = S_GJAHR-LOW.
               W_OUTTAB-MONAT  = R_MONAT-HIGH.
               W_OUTTAB-ZINDEX = S_INDEX-HIGH.
               W_OUTTAB-ADOAZON = LW_ANALITIKA-ADOAZON.
               W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
               W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
               W_OUTTAB-WAERS  = C_HUF.
               SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
                 FROM  /ZAK/BEVALLBT
                      WHERE  LANGU   = SY-LANGU
                      AND    BTYPE   = W_OUTTAB-BTYPE
                      AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
               W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
               MOVE LW_ANALITIKA-LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA-LAPSZ TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
             L_LAPSZ_SAVE = L_LAPSZ.
           ENDIF.
*          C/a Name of the related company involved in the transaction
           LM_GET_ABEV_TO_INDEX L_SORSZ 'A' L_SUBRC C_BTYPART_TAO.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA-ZCOMMENT TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*          C/b tax number
           LM_GET_ABEV_TO_INDEX L_SORSZ 'B' L_SUBRC C_BTYPART_TAO.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*          C/c Country
           LM_GET_ABEV_TO_INDEX L_SORSZ 'C' L_SUBRC C_BTYPART_TAO.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA-SZLATIP TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*          C/d Foreign tax number
           LM_GET_ABEV_TO_INDEX L_SORSZ 'D' L_SUBRC C_BTYPART_TAO.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA-STCEG TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*          C/e Net amount
           LM_GET_ABEV_TO_INDEX L_SORSZ 'E' L_SUBRC C_BTYPART_TAO.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA-LWBAS   TO W_OUTTAB-FIELD_N.
             MOVE LW_ANALITIKA-WAERS   TO W_OUTTAB-WAERS.
*++2308 #11.
             PERFORM CALC_FIELD_NRK(/ZAK/MAIN_VIEW) USING W_OUTTAB-FIELD_N
                                                         W_/ZAK/BEVALLB-ROUND
                                                         C_HUF
                                                CHANGING W_OUTTAB-FIELD_NR
                                                         W_OUTTAB-FIELD_NRK.
*--2308 #11.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*          C/f Tax base
           LM_GET_ABEV_TO_INDEX L_SORSZ 'F' L_SUBRC C_BTYPART_TAO.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA-ADOAZON TO W_OUTTAB-ADOAZON.
*++2308 #13.
*             MOVE LW_ANALITIKA-LWSTE   TO W_OUTTAB-FIELD_N.
             IF LW_ANALITIKA-LWSTE IS INITIAL.
               MOVE '0'   TO W_OUTTAB-FIELD_C.
             ELSE.
               MOVE LW_ANALITIKA-LWSTE   TO W_OUTTAB-FIELD_N.
             ENDIF.
*--2308 #13.
             MOVE LW_ANALITIKA-WAERS   TO W_OUTTAB-WAERS.
*++2308 #11.
*++2308 #13.
             IF NOT LW_ANALITIKA-LWSTE IS INITIAL.
               PERFORM CALC_FIELD_NRK(/ZAK/MAIN_VIEW) USING W_OUTTAB-FIELD_N
                                                           W_/ZAK/BEVALLB-ROUND
                                                           C_HUF
                                                  CHANGING W_OUTTAB-FIELD_NR
                                                           W_OUTTAB-FIELD_NRK.
             ENDIF.
*--2308 #13.
*--2308 #11.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
           ADD 1 TO L_SORSZ.
         ENDLOOP.
       ENDLOOP.
     ENDIF.
     SORT I_OUTTAB.
   ENDIF.
*--2308 #09.
 ENDFORM.                    " read_analitika
*&---------------------------------------------------------------------*
*&      Form  sub_f4_on_index
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_INDEX_LOW  text
*----------------------------------------------------------------------*
 FORM SUB_F4_ON_INDEX USING    $SH_TYPE.

   DATA: L_SHLPNAME TYPE SHLPNAME.
   DATA: T_RETURN_TAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

   IF $SH_TYPE = '1'.
     L_SHLPNAME = '/ZAK/INDEX_1'.
   ELSEIF $SH_TYPE = '2'.
     L_SHLPNAME = '/ZAK/INDEX_2'.
   ELSE.
     L_SHLPNAME = '/ZAK/INDEX_3'.
   ENDIF.


   CLEAR: S_GJAHR1-LOW,
          S_MONAT1-LOW,
          S_INDEX1-LOW.

   CLEAR: S_GJAHR2-LOW,
          S_MONAT2-LOW,
          S_INDEX2-LOW.

   CLEAR: S_GJAHR3-LOW,
          S_MONAT3-LOW,
          S_INDEX3-LOW.

   REFRESH: S_GJAHR1,
            S_MONAT1,
            S_INDEX1.

   REFRESH: S_GJAHR2,
            S_MONAT2,
            S_INDEX2.

   REFRESH: S_GJAHR3,
            S_MONAT3,
            S_INDEX3.

   CALL FUNCTION '/ZAK/F4IF_FIELD_VALUE_REQUEST'
     EXPORTING
       TABNAME           = SPACE
       FIELDNAME         = SPACE
       SEARCHHELP        = L_SHLPNAME
       CALLBACK_PROGRAM  = V_REPID
       CALLBACK_FORM     = 'SET_FIELDS_F4'
     TABLES
       RETURN_TAB        = T_RETURN_TAB
     EXCEPTIONS
       FIELD_NOT_FOUND   = 1
       NO_HELP_FOR_FIELD = 2
       INCONSISTENT_HELP = 3
       NO_VALUES_FOUND   = 4
       OTHERS            = 5.
   IF SY-SUBRC = 0.

     LOOP AT T_RETURN_TAB.
       CASE T_RETURN_TAB-FIELDNAME.
         WHEN 'GJAHR'.
           CASE $SH_TYPE.
             WHEN '1'.
               S_GJAHR1-LOW = T_RETURN_TAB-FIELDVAL.
             WHEN '2'.
               S_GJAHR2-LOW = T_RETURN_TAB-FIELDVAL.
             WHEN '3'.
               S_GJAHR3-LOW = T_RETURN_TAB-FIELDVAL.
           ENDCASE.
         WHEN 'MONAT'.
           CASE $SH_TYPE.
             WHEN '1'.
               S_MONAT1-LOW = T_RETURN_TAB-FIELDVAL.
             WHEN '2'.
               S_MONAT2-LOW = T_RETURN_TAB-FIELDVAL.
             WHEN '3'.
               S_MONAT3-LOW = T_RETURN_TAB-FIELDVAL.
           ENDCASE.

         WHEN 'ZINDEX'.
           CASE $SH_TYPE.
             WHEN '1'.
               S_INDEX1-LOW = T_RETURN_TAB-FIELDVAL.
             WHEN '2'.
               S_INDEX2-LOW = T_RETURN_TAB-FIELDVAL.
             WHEN '3'.
               S_INDEX3-LOW = T_RETURN_TAB-FIELDVAL.
           ENDCASE.

       ENDCASE.
     ENDLOOP.

     PERFORM DYNP_UPDATE USING $SH_TYPE.

   ENDIF.

 ENDFORM.                    " sub_f4_on_index
*&---------------------------------------------------------------------*
*&      Form  DYNP_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DYNP_UPDATE USING $SH_TYPE.
   DATA: I_DYNPREAD TYPE TABLE OF DYNPREAD INITIAL SIZE 0.
   DATA: W_DYNPREAD TYPE DYNPREAD.


   CASE $SH_TYPE.

     WHEN '1'.
       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_GJAHR1-LOW'.
       W_DYNPREAD-FIELDVALUE = S_GJAHR1-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_MONAT1-LOW'.
       W_DYNPREAD-FIELDVALUE = S_MONAT1-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_INDEX1-LOW'.
       W_DYNPREAD-FIELDVALUE = S_INDEX1-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

     WHEN '2'.
       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_GJAHR2-LOW'.
       W_DYNPREAD-FIELDVALUE = S_GJAHR2-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_MONAT2-LOW'.
       W_DYNPREAD-FIELDVALUE = S_MONAT2-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_INDEX2-LOW'.
       W_DYNPREAD-FIELDVALUE = S_INDEX2-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

     WHEN '3'.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_GJAHR3-LOW'.
       W_DYNPREAD-FIELDVALUE = S_GJAHR3-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_MONAT3-LOW'.
       W_DYNPREAD-FIELDVALUE = S_MONAT3-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.

       CLEAR W_DYNPREAD.
       W_DYNPREAD-FIELDNAME = 'S_INDEX3-LOW'.
       W_DYNPREAD-FIELDVALUE = S_INDEX3-LOW.
       APPEND W_DYNPREAD TO I_DYNPREAD.


   ENDCASE.


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

 ENDFORM.                    " d9000_event_double_click
*&---------------------------------------------------------------------*
*&      Form  d9000_event_hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
 FORM D9001_EVENT_HOTSPOT_CLICK USING E_ROW_ID    TYPE LVC_S_ROW
                                      E_COLUMN_ID TYPE LVC_S_COL.
   DATA: S_OUT   LIKE I_OUTTAB2,
         V_KOKRS TYPE KOKRS.

   READ TABLE I_OUTTAB2 INTO S_OUT INDEX E_ROW_ID.
   IF SY-SUBRC = 0.

     CASE E_COLUMN_ID.
       WHEN 'BSEG_GJAHR' OR
            'BSEG_BELNR' OR
            'BSEG_BUZEI'.

         IF NOT S_OUT-BSEG_GJAHR IS INITIAL AND
            NOT S_OUT-BSEG_BELNR IS INITIAL AND
            NOT S_OUT-BSEG_BUZEI IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'GJR' FIELD S_OUT-BSEG_GJAHR.
           SET PARAMETER ID 'BLN' FIELD S_OUT-BSEG_BELNR.

           CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
         ENDIF.
       WHEN 'KOSTL'.
         IF NOT S_OUT-KOSTL IS INITIAL.
           SELECT SINGLE KOKRS INTO V_KOKRS
              FROM TKA02
              WHERE BUKRS = S_OUT-BUKRS AND
                    GSBER = SPACE.

           SET PARAMETER ID 'CAC' FIELD V_KOKRS.
           SET PARAMETER ID 'KOS' FIELD S_OUT-KOSTL.

           CALL TRANSACTION 'KS03' AND SKIP FIRST SCREEN.
         ENDIF.
       WHEN 'AUFNR'.
         IF NOT S_OUT-AUFNR IS INITIAL.
           SELECT SINGLE KOKRS INTO V_KOKRS
              FROM TKA02
              WHERE BUKRS = S_OUT-BUKRS AND
                    GSBER = SPACE.

           SET PARAMETER ID 'CAC' FIELD V_KOKRS.
           SET PARAMETER ID 'ANR' FIELD S_OUT-AUFNR.

           CALL TRANSACTION 'KS03' AND SKIP FIRST SCREEN.

         ENDIF.

       WHEN 'HKONT'.
         IF NOT S_OUT-HKONT IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'SAK' FIELD S_OUT-HKONT.

           CALL TRANSACTION 'FS00' AND SKIP FIRST SCREEN.

         ENDIF.

       WHEN 'PRCTR'.
         IF NOT S_OUT-PRCTR IS INITIAL.

           SELECT SINGLE KOKRS INTO V_KOKRS
              FROM TKA02
              WHERE BUKRS = S_OUT-BUKRS AND
                    GSBER = SPACE.

           SET PARAMETER ID 'CAC' FIELD V_KOKRS.
           SET PARAMETER ID 'PRC' FIELD S_OUT-PRCTR.

           CALL TRANSACTION 'KE53' AND SKIP FIRST SCREEN.

         ENDIF.

     ENDCASE.
   ENDIF.

 ENDFORM.                    " d9001_event_hotspot_click
*&---------------------------------------------------------------------*
*&      Module  pbo_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO_9001 OUTPUT.
   PERFORM SET_STATUS.

   IF V_CUSTOM_CONTAINER2 IS INITIAL.
     PERFORM CREATE_AND_INIT_ALV2 CHANGING I_OUTTAB2[]
                                           I_FIELDCAT2
                                           V_LAYOUT2
                                           V_VARIANT2.
   ELSE.
     CALL METHOD V_GRID2->REFRESH_TABLE_DISPLAY.
   ENDIF.

 ENDMODULE.                 " pbo_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB2[]  text
*      <--P_I_FIELDCAT2  text
*      <--P_V_LAYOUT2  text
*      <--P_V_VARIANT2  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV2 CHANGING PT_OUTTAB  LIKE I_OUTTAB2[]
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
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING PT_FIELDCAT.
*
* Exclude functions
   PERFORM EXCLUDE_TB_FUNCTIONS CHANGING I_EXCLUDE.

   PS_LAYOUT-CWIDTH_OPT = C_X.
* allow to select multiple lines
   PS_LAYOUT-SEL_MODE = 'B'.

   PS_LAYOUT-STYLEFNAME = 'CELLTAB'.


   CLEAR PS_VARIANT.
   PS_VARIANT-REPORT = V_REPID.



   CALL METHOD V_GRID2->SET_READY_FOR_INPUT
     EXPORTING
       I_READY_FOR_INPUT = 1.

   CALL METHOD V_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT           = PS_VARIANT
       I_SAVE               = 'A'
       I_DEFAULT            = C_X
       IS_LAYOUT            = PS_LAYOUT
       IT_TOOLBAR_EXCLUDING = I_EXCLUDE
     CHANGING
       IT_FIELDCATALOG      = PT_FIELDCAT
       IT_OUTTAB            = PT_OUTTAB.


   CALL METHOD V_GRID2->REGISTER_EDIT_EVENT
     EXPORTING
       I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

   CALL METHOD V_GRID2->REGISTER_EDIT_EVENT
     EXPORTING
       I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

   CREATE OBJECT V_EVENT_RECEIVER2.

   SET HANDLER V_EVENT_RECEIVER2->HANDLE_HOTSPOT_CLICK  FOR V_GRID2.
   SET HANDLER V_EVENT_RECEIVER2->HANDLE_DATA_CHANGED   FOR V_GRID2.
   SET HANDLER V_EVENT_RECEIVER2->HANDLE_USER_COMMAND   FOR V_GRID2.

 ENDFORM.                    " create_and_init_alv2
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
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9100 OUTPUT.
   SET PF-STATUS 'S_9100'.
   SET TITLEBAR 'S91'.

 ENDMODULE.                 " STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE INIT_9100 OUTPUT.
   PERFORM INIT_9100.
 ENDMODULE.                 " init_9100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  init_9100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INIT_9100.
* Read descriptions

* Company
   SELECT SINGLE BUTXT INTO /ZAK/ANALITIKA_S-BUTXT FROM  T001
          WHERE  BUKRS  = /ZAK/ANALITIKA_S-BUKRS.

* Return type
   SELECT BTEXT UP TO 1 ROWS INTO /ZAK/ANALITIKA_S-BTEXT
       FROM  /ZAK/BEVALLT
          WHERE  LANGU  = SY-LANGU
          AND    BTYPE  = /ZAK/ANALITIKA_S-BTYPE.
   ENDSELECT.

* ABEV identifier
   SELECT SINGLE ABEVTEXT INTO /ZAK/ANALITIKA_S-ABEVTEXT FROM  /ZAK/BEVALLBT
                                                 WHERE  LANGU   = SY-LANGU
                                    AND    BTYPE   = /ZAK/ANALITIKA_S-BTYPE
                                   AND    ABEVAZ  = /ZAK/ANALITIKA_S-ABEVAZ.


* Data service
   SELECT SINGLE SZTEXT INTO /ZAK/ANALITIKA_S-SZTEXT FROM  /ZAK/BEVALLDT
          WHERE  LANGU   = SY-LANGU
          AND    BUKRS   = /ZAK/ANALITIKA_S-BUKRS
          AND    BTYPE   = /ZAK/ANALITIKA_S-BTYPE
          AND    BSZNUM  = /ZAK/ANALITIKA_S-BSZNUM.


 ENDFORM.                                                   " init_9100
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9100 INPUT.


   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.

   CASE V_SAVE_OK.
     WHEN 'SAVE'.

* Confirmation: are you sure you will save?
       PERFORM ARE_U_SURE CHANGING V_ANSWER.
       CHECK V_ANSWER = '1'.

       PERFORM GET_NEXT_ITEM USING /ZAK/ANALITIKA_S
                             CHANGING /ZAK/ANALITIKA.
       IF NOT /ZAK/ANALITIKA IS INITIAL.
         PERFORM SAVE_ITEM.
*        perform read_analitika.

         IF V_DYNNR = '9002'.
           CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
         ELSE.
           CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.
         ENDIF.

       ENDIF.
       SET SCREEN 0.
       LEAVE SCREEN.


     WHEN 'BACK'.
* Confirmation: Exit without saving?
       PERFORM LOSS_OF_DATA CHANGING V_ANSWER.
       CHECK V_ANSWER = 'J'.

       SET SCREEN 0.
       LEAVE SCREEN.


   ENDCASE.

 ENDMODULE.                 " USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_sum  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_SUM INPUT.
   /ZAK/ANALITIKA_S-NEW_VALUE  = /ZAK/ANALITIKA_S-FIELD_N.
   IF /ZAK/ANALITIKA_S-STAPO NE C_X.
     /ZAK/ANALITIKA_S-SUM_VALUE = /ZAK/ANALITIKA_S-ORIG_VALUE +
                                 /ZAK/ANALITIKA_S-NEW_VALUE.
   ENDIF.

 ENDMODULE.                 " set_sum  INPUT
*&---------------------------------------------------------------------*
*&      Form  get_next_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/ZAK/ANALITIKA_S  text
*      <--P_/ZAK/ANALITIKA  text
*----------------------------------------------------------------------*
 FORM GET_NEXT_ITEM USING    /ZAK/ANALITIKA_S TYPE /ZAK/ANALITIKA_S
                    CHANGING /ZAK/ANALITIKA   TYPE /ZAK/ANALITIKA.

   DATA: L_ITEM LIKE /ZAK/ANALITIKA-ITEM.

   CLEAR /ZAK/ANALITIKA.

* Last item number
   SELECT MAX( ITEM ) INTO L_ITEM FROM /ZAK/ANALITIKA
      WHERE BUKRS   = /ZAK/ANALITIKA_S-BUKRS
        AND BTYPE   = /ZAK/ANALITIKA_S-BTYPE
        AND GJAHR   = /ZAK/ANALITIKA_S-GJAHR
        AND MONAT   = /ZAK/ANALITIKA_S-MONAT
        AND ZINDEX  = /ZAK/ANALITIKA_S-ZINDEX
        AND ABEVAZ  = /ZAK/ANALITIKA_S-ABEVAZ
        AND ADOAZON = /ZAK/ANALITIKA_S-ADOAZON
        AND BSZNUM  = /ZAK/ANALITIKA_S-BSZNUM
        AND PACK    = /ZAK/ANALITIKA_S-PACK.
   L_ITEM = L_ITEM + 1.

   MOVE-CORRESPONDING /ZAK/ANALITIKA_S TO /ZAK/ANALITIKA.
   /ZAK/ANALITIKA-XMANU = C_X.
   /ZAK/ANALITIKA-ITEM  = L_ITEM.

 ENDFORM.                    " get_next_item
*&---------------------------------------------------------------------*
*&      Form  save_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_ITEM.
   DATA: T_/ZAK/ANALITIKA  TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
         LT_/ZAK/ANALITIKA TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
         L_/ZAK/ANALITIKA  TYPE /ZAK/ANALITIKA,
         W_RETURN         TYPE BAPIRET2.

   DATA: L_ROUND(20) TYPE C.

   REFRESH T_/ZAK/ANALITIKA.
* New item
   CLEAR /ZAK/ANALITIKA-ZINDEX.
   APPEND /ZAK/ANALITIKA TO T_/ZAK/ANALITIKA.


   CLEAR W_/ZAK/BEVALLB.
   READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
      WITH KEY BTYPE = /ZAK/ANALITIKA-BTYPE
               ABEVAZ = /ZAK/ANALITIKA-ABEVAZ.
   IF SY-SUBRC NE 0.
     CLEAR W_/ZAK/BEVALLB.
     SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
         WHERE BTYPE = /ZAK/ANALITIKA-BTYPE
           AND ABEVAZ = /ZAK/ANALITIKA-ABEVAZ.
     INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
   ENDIF.


   IF W_/ZAK/BEVALLB-FIELDTYPE = C_NUM.
* Numeric specialties
* Create a reversal item for the next period with opposite sign
     IF NOT /ZAK/ANALITIKA-VORSTOR IS INITIAL.
       MOVE-CORRESPONDING /ZAK/ANALITIKA TO W_/ZAK/ANALITIKA.
       W_/ZAK/ANALITIKA-FIELD_N = W_/ZAK/ANALITIKA-FIELD_N * ( -1 ).
* Next period
       IF W_/ZAK/ANALITIKA-MONAT < 12.
         W_/ZAK/ANALITIKA-MONAT = W_/ZAK/ANALITIKA-MONAT + 1.
       ELSE.
         W_/ZAK/ANALITIKA-MONAT = 1.
         W_/ZAK/ANALITIKA-GJAHR = W_/ZAK/ANALITIKA-GJAHR + 1.
       ENDIF.

       MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO /ZAK/ANALITIKA.
       CLEAR W_/ZAK/ANALITIKA-ZINDEX.
       APPEND W_/ZAK/ANALITIKA TO T_/ZAK/ANALITIKA.

     ENDIF.
   ELSE.
* Character specialties

* Date






* Special handling of XDEFT - if it is set here in the manual item,
* then this field must be cleared from all others.
     IF NOT /ZAK/ANALITIKA-XDEFT IS INITIAL.

       SELECT * INTO TABLE LT_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
         WHERE BUKRS = /ZAK/ANALITIKA-BUKRS
           AND BTYPE = /ZAK/ANALITIKA-BTYPE
           AND GJAHR = /ZAK/ANALITIKA-GJAHR
           AND MONAT = /ZAK/ANALITIKA-MONAT
           AND ZINDEX = S_INDEX-HIGH
           AND ABEVAZ = /ZAK/ANALITIKA-ABEVAZ
           AND ADOAZON = /ZAK/ANALITIKA-ADOAZON
           AND XDEFT   = C_X
           AND ITEM <> /ZAK/ANALITIKA-ITEM.


       LOOP AT LT_/ZAK/ANALITIKA INTO L_/ZAK/ANALITIKA.
         L_/ZAK/ANALITIKA-XDEFT = SPACE.
         MODIFY LT_/ZAK/ANALITIKA FROM L_/ZAK/ANALITIKA.
       ENDLOOP.
       APPEND LINES OF LT_/ZAK/ANALITIKA TO T_/ZAK/ANALITIKA.
     ENDIF.
   ENDIF.


   IF NOT T_/ZAK/ANALITIKA[] IS INITIAL.
     PERFORM CALL_UPDATE TABLES I_RETURN
                                T_/ZAK/ANALITIKA
                         USING  /ZAK/ANALITIKA-BUKRS
                                /ZAK/ANALITIKA-BTYPE
                                /ZAK/ANALITIKA-BSZNUM
*                               /ZAK/ANALITIKA-PACK
                                SPACE
                                SPACE
                                SPACE.

     LOOP AT T_/ZAK/ANALITIKA INTO /ZAK/ANALITIKA.

       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE   = /ZAK/ANALITIKA-BTYPE
                   ABEVAZ  = /ZAK/ANALITIKA-ABEVAZ.
       IF SY-SUBRC = 0.
* Update I_OUTTAB if there is no error message in I_RETURN

         READ TABLE I_RETURN INTO W_RETURN WITH KEY TYPE = 'E'.
         IF SY-SUBRC <> 0.

* Karakteres
           IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.
             IF NOT /ZAK/ANALITIKA-XDEFT IS INITIAL.

               IF V_DYNNR <> '9002'.
                 READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                      BUKRS = /ZAK/ANALITIKA-BUKRS
                      BTYPE = /ZAK/ANALITIKA-BTYPE
                      GJAHR = /ZAK/ANALITIKA-GJAHR
                      MONAT = /ZAK/ANALITIKA-MONAT
                      ZINDEX = /ZAK/ANALITIKA-ZINDEX
                      ABEVAZ = /ZAK/ANALITIKA-ABEVAZ
                      ADOAZON = /ZAK/ANALITIKA-ADOAZON.
                 IF SY-SUBRC = 0.
                   MOVE-CORRESPONDING /ZAK/ANALITIKA TO W_OUTTAB.
                   MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
                 ENDIF.
               ELSE.
                 READ TABLE I_OUTTAB_L INTO W_OUTTAB WITH KEY
                      BUKRS = /ZAK/ANALITIKA-BUKRS
                      BTYPE = /ZAK/ANALITIKA-BTYPE
                      GJAHR = /ZAK/ANALITIKA-GJAHR
                      MONAT = /ZAK/ANALITIKA-MONAT
                      ZINDEX = /ZAK/ANALITIKA-ZINDEX
                      ABEVAZ = /ZAK/ANALITIKA-ABEVAZ
                      ADOAZON = /ZAK/ANALITIKA-ADOAZON.
                 IF SY-SUBRC = 0.
                   MOVE-CORRESPONDING /ZAK/ANALITIKA TO W_OUTTAB.
                   MODIFY I_OUTTAB_L FROM W_OUTTAB INDEX SY-TABIX.
                 ENDIF.

               ENDIF.
             ENDIF.
* Numerikus
           ELSE.
             CHECK /ZAK/ANALITIKA-STAPO NE C_X.


             IF V_DYNNR <> '9002'.
               READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                    BUKRS = /ZAK/ANALITIKA-BUKRS
                    BTYPE = /ZAK/ANALITIKA-BTYPE
                    GJAHR = /ZAK/ANALITIKA-GJAHR
                    MONAT = /ZAK/ANALITIKA-MONAT
                    ZINDEX = /ZAK/ANALITIKA-ZINDEX
                    ABEVAZ = /ZAK/ANALITIKA-ABEVAZ
                    ADOAZON = /ZAK/ANALITIKA-ADOAZON.
               IF SY-SUBRC = 0.
                 MOVE-CORRESPONDING /ZAK/ANALITIKA TO W_OUTTAB.

                 W_OUTTAB-ROUND = W_/ZAK/BEVALLB-ROUND.
*       if not w_/zak/bevallb-round is initial.
                 WRITE W_OUTTAB-FIELD_N TO L_ROUND
                     ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.


*                 REPLACE ',' WITH '.' INTO L_ROUND.
*                 W_OUTTAB-FIELD_NR = L_ROUND.
*
*                 W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
*                                      ( 10 ** W_/ZAK/BEVALLB-ROUND ).
*

                 COLLECT W_OUTTAB INTO I_OUTTAB.
               ENDIF.

* ++ CST 2006.07.19
* Rounding
               READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                    BUKRS = /ZAK/ANALITIKA-BUKRS
                    BTYPE = /ZAK/ANALITIKA-BTYPE
                    GJAHR = /ZAK/ANALITIKA-GJAHR
                    MONAT = /ZAK/ANALITIKA-MONAT
                    ZINDEX = /ZAK/ANALITIKA-ZINDEX
                    ABEVAZ = /ZAK/ANALITIKA-ABEVAZ
                    ADOAZON = /ZAK/ANALITIKA-ADOAZON.
               IF SY-SUBRC = 0.
                 WRITE W_OUTTAB-FIELD_N TO L_ROUND
                     ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.

                 REPLACE ',' WITH '.' INTO L_ROUND.
                 W_OUTTAB-FIELD_NR = L_ROUND.

                 W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
                                      ( 10 ** W_/ZAK/BEVALLB-ROUND ).


                 MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
               ENDIF.

* --CST 2006.07.19


             ELSE.
               READ TABLE I_OUTTAB_L INTO W_OUTTAB WITH KEY
                    BUKRS = /ZAK/ANALITIKA-BUKRS
                    BTYPE = /ZAK/ANALITIKA-BTYPE
                    GJAHR = /ZAK/ANALITIKA-GJAHR
                    MONAT = /ZAK/ANALITIKA-MONAT
                    ZINDEX = /ZAK/ANALITIKA-ZINDEX
                    ABEVAZ = /ZAK/ANALITIKA-ABEVAZ
                    ADOAZON = /ZAK/ANALITIKA-ADOAZON.
               IF SY-SUBRC = 0.
                 MOVE-CORRESPONDING /ZAK/ANALITIKA TO W_OUTTAB.

                 W_OUTTAB-ROUND = W_/ZAK/BEVALLB-ROUND.
*       if not w_/zak/bevallb-round is initial.
                 WRITE W_OUTTAB-FIELD_N TO L_ROUND
                     ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.


                 REPLACE ',' WITH '.' INTO L_ROUND.
                 W_OUTTAB-FIELD_NR = L_ROUND.

                 W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
                                      ( 10 ** W_/ZAK/BEVALLB-ROUND ).


                 COLLECT W_OUTTAB INTO I_OUTTAB_L.
               ENDIF.

             ENDIF.

           ENDIF.

         ENDIF.
       ENDIF.
     ENDLOOP.

   ENDIF.

* Repeated aggregation - for total fields
   IF P_M <> C_X.
     PERFORM CALL_EXIT.
   ENDIF.

* If the return was already downloaded > reset status
   SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
      WHERE BUKRS = P_BUKRS
        AND BTYPE = P_BTYPE
        AND GJAHR = S_GJAHR-LOW
        AND MONAT = S_MONAT-LOW
        AND ZINDEX = S_INDEX-HIGH
        AND FLAG = 'T'.

   IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
     LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ.

       UPDATE /ZAK/BEVALLSZ SET FLAG = 'F'
          WHERE BUKRS  = W_/ZAK/BEVALLSZ-BUKRS
            AND BTYPE  = W_/ZAK/BEVALLSZ-BTYPE
            AND BSZNUM = W_/ZAK/BEVALLSZ-BSZNUM
            AND GJAHR  = W_/ZAK/BEVALLSZ-GJAHR
            AND MONAT  = W_/ZAK/BEVALLSZ-MONAT
            AND ZINDEX = W_/ZAK/BEVALLSZ-ZINDEX
            AND PACK   = W_/ZAK/BEVALLSZ-PACK.
       IF SY-SUBRC = 0.
         COMMIT WORK.
       ENDIF.

     ENDLOOP.
   ENDIF.

   REFRESH I_RETURN.
 ENDFORM.                    " save_item
*&---------------------------------------------------------------------*
*&      Module  STATUS_9200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9200 OUTPUT.
   SET PF-STATUS 'S_9200'.
   SET TITLEBAR 'S92'.
 ENDMODULE.                 " STATUS_9200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_9200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE INIT_9200 OUTPUT.
   PERFORM INIT_9200.
 ENDMODULE.                 " init_9200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  init_9200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INIT_9200.
* Read descriptions

* Company
   SELECT SINGLE BUTXT INTO /ZAK/ANALITIKA_S-BUTXT FROM  T001
          WHERE  BUKRS  = /ZAK/ANALITIKA_S-BUKRS.

* Return type
   SELECT BTEXT UP TO 1 ROWS INTO /ZAK/ANALITIKA_S-BTEXT
       FROM  /ZAK/BEVALLT
          WHERE  LANGU  = SY-LANGU
          AND    BTYPE  = /ZAK/ANALITIKA_S-BTYPE.
   ENDSELECT.

* ABEV identifier
   SELECT SINGLE ABEVTEXT INTO /ZAK/ANALITIKA_S-ABEVTEXT FROM  /ZAK/BEVALLBT
                                                 WHERE  LANGU   = SY-LANGU
                                    AND    BTYPE   = /ZAK/ANALITIKA_S-BTYPE
                                   AND    ABEVAZ  = /ZAK/ANALITIKA_S-ABEVAZ.


* Data service
   SELECT SINGLE SZTEXT INTO /ZAK/ANALITIKA_S-SZTEXT FROM  /ZAK/BEVALLDT
          WHERE  LANGU   = SY-LANGU
          AND    BUKRS   = /ZAK/ANALITIKA_S-BUKRS
          AND    BTYPE   = /ZAK/ANALITIKA_S-BTYPE
          AND    BSZNUM  = /ZAK/ANALITIKA_S-BSZNUM.

   IF V_FIRST = SPACE.
     CLEAR /ZAK/ANALITIKA_S-FIELD_C.
     V_FIRST = C_X.
   ENDIF.

 ENDFORM.                                                   " init_9200
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9200 INPUT.

   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.

   CASE V_SAVE_OK.
     WHEN 'SAVE'.

* Confirmation: are you sure you will save?
       PERFORM ARE_U_SURE CHANGING V_ANSWER.
       CHECK V_ANSWER = '1'.

       PERFORM GET_NEXT_ITEM USING /ZAK/ANALITIKA_S
                             CHANGING /ZAK/ANALITIKA.
       IF NOT /ZAK/ANALITIKA IS INITIAL.
         PERFORM SAVE_ITEM.

*         perform read_analitika.

         IF V_DYNNR = '9002'.
           CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
         ELSE.
           CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY.
         ENDIF.

       ENDIF.

       SET SCREEN 0.
       LEAVE SCREEN.

     WHEN 'BACK'.
* Confirmation: Exit without saving?
       PERFORM LOSS_OF_DATA CHANGING V_ANSWER.
       CHECK V_ANSWER = 'J'.


       SET SCREEN 0.
       LEAVE SCREEN.
   ENDCASE.

 ENDMODULE.                 " USER_COMMAND_9200  INPUT
*&---------------------------------------------------------------------*
*&      Form  get_last_day_of_peeriod
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_GJAHR_LOW  text
*      -->P_S_MONAT_LOW  text
*      <--P_V_LAST_DATE  text
*----------------------------------------------------------------------*
 FORM GET_LAST_DAY_OF_PERIOD USING    $GJAHR
                                      $MONAT
                              CHANGING V_LAST_DATE.

   DATA: L_DATE1 TYPE DATUM,
         L_DATE2 TYPE DATUM.

   CLEAR V_LAST_DATE.


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



 ENDFORM.                    " get_last_day_of_period
*&---------------------------------------------------------------------*
*&      Form  read_bevall
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_V_LAST_DATE  text
*----------------------------------------------------------------------*
 FORM READ_BEVALL USING    P_BUKRS
                           P_BTART
                           P_BTYPE
                           V_LAST_DATE TYPE D.

   CLEAR W_/ZAK/BEVALL.
   SELECT * INTO TABLE I_/ZAK/BEVALL FROM  /ZAK/BEVALL
       WHERE     BUKRS  = P_BUKRS
          AND    BTYPART = P_BTART
          AND    DATBI  >= V_LAST_DATE.


   READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
      WITH KEY BUKRS = P_BUKRS
               BTYPE = P_BTYPE.

 ENDFORM.                    " read_bevall
*&---------------------------------------------------------------------*
*&      Form  call_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_RETURN  text
*      -->P_T_/ZAK/ANALITIKA  text
*      -->P_W_/ZAK/ANALITIKA_BUKRS  text
*      -->P_W_/ZAK/ANALITIKA_BTYPE  text
*      -->P_W_/ZAK/ANALITIKA_BSZNUM  text
*      -->P_W_/ZAK/ANALITIKA_PACK  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*----------------------------------------------------------------------*
 FORM CALL_UPDATE TABLES   I_RETURN STRUCTURE BAPIRET2
                           T_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                  USING    P_BUKRS   TYPE BUKRS
                           P_BTYPE   TYPE /ZAK/BTYPE
                           P_BSZNUM  TYPE /ZAK/BSZNUM
                           P_PACK    TYPE /ZAK/PACK
                           P_GEN     TYPE CHAR01
                           P_TEST    TYPE CHAR01.


   CALL FUNCTION '/ZAK/UPDATE'
     EXPORTING
       I_BUKRS     = P_BUKRS
       I_BTYPE     = P_BTYPE
*      I_BTYPART   =
       I_BSZNUM    = P_BSZNUM
       I_PACK      = P_PACK
       I_GEN       = P_GEN
       I_TEST      = P_TEST
*      I_FILE      =
     TABLES
       I_ANALITIKA = T_/ZAK/ANALITIKA
       E_RETURN    = I_RETURN.



   IF NOT I_RETURN[] IS INITIAL.

     CALL FUNCTION '/ZAK/MESSAGE_SHOW'
       TABLES
         T_RETURN = I_RETURN.

   ENDIF.


 ENDFORM.                    " call_update
*&---------------------------------------------------------------------*
*&      Form  check_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_DATA USING P_FLAG.
* Data service validation
   DATA: V_EXIT.

   CHECK NOT S_GJAHR IS INITIAL AND
         NOT S_MONAT IS INITIAL AND
         NOT S_INDEX IS INITIAL.


* Required data services
   SELECT * INTO TABLE I_/ZAK/BEVALLD
     FROM /ZAK/BEVALLD
      WHERE BUKRS = P_BUKRS
        AND BTYPE = P_BTYPE
        AND XSPEC = SPACE.


   IF P_FLAG = 'S'.   " Szelekciós képen ellenőrzés


     IF P_N EQ C_X.
       IF NOT I_/ZAK/BEVALLD[] IS INITIAL.
         CLEAR V_EXIT.
         LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.

           SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM  /ZAK/BEVALLSZ
               WHERE  BUKRS   = W_/ZAK/BEVALLD-BUKRS
               AND    BTYPE   = W_/ZAK/BEVALLD-BTYPE
               AND    BSZNUM  = W_/ZAK/BEVALLD-BSZNUM
               AND    GJAHR   = S_GJAHR-LOW
               AND    MONAT   = S_MONAT-LOW
               AND    ZINDEX  = S_INDEX-HIGH.

           IF SY-SUBRC = 0.

* Checks
* 1. Are all data services in F/E status

             LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
               WHERE FLAG <> 'F'
                 AND FLAG <> 'E'
                 AND FLAG <> 'B'.

               IF P_N = C_X.
                 IF W_/ZAK/BEVALLSZ-FLAG = 'T'.
                   MESSAGE W045(/ZAK/ZAK).
                   V_EXIT = C_X.
                   EXIT.
                 ELSE.
                   MESSAGE W041(/ZAK/ZAK).
                   V_EXIT = C_X.
                   EXIT.
                 ENDIF.
               ENDIF.

             ENDLOOP.

           ELSE.
             MESSAGE W041(/ZAK/ZAK).
             V_EXIT = C_X.
             EXIT.
           ENDIF.

           IF V_EXIT = C_X.
             EXIT.
           ENDIF.
         ENDLOOP.

       ENDIF.

     ENDIF.
   ELSE.            " Letöltéskor

     IF P_N EQ C_X.
       IF NOT I_/ZAK/BEVALLD[] IS INITIAL.
         LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.

           SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM  /ZAK/BEVALLSZ
               WHERE  BUKRS   = W_/ZAK/BEVALLD-BUKRS
               AND    BTYPE   = W_/ZAK/BEVALLD-BTYPE
               AND    BSZNUM  = W_/ZAK/BEVALLD-BSZNUM
               AND    GJAHR   = S_GJAHR-LOW
               AND    MONAT   = S_MONAT-LOW
               AND    ZINDEX  = S_INDEX-HIGH.
           IF SY-SUBRC = 0.
* Checks
* 1. Are all data services in F/E status
             LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
               WHERE FLAG <> 'F'
                 AND FLAG <> 'E'
                 AND FLAG <> 'B'.

               IF P_N = C_X.
                 IF W_/ZAK/BEVALLSZ-FLAG = 'T'.
                   MESSAGE W045(/ZAK/ZAK).
                   V_EXIT = C_X.
                   EXIT.
                 ELSE.
                   MESSAGE E041(/ZAK/ZAK).
                   V_EXIT = C_X.
                   EXIT.
                 ENDIF.
               ENDIF.


               IF V_EXIT = C_X.
                 EXIT.
               ENDIF.

             ENDLOOP.

           ELSE.
             MESSAGE W041(/ZAK/ZAK).
             V_EXIT = C_X.
             EXIT.

           ENDIF.

           IF V_EXIT = C_X.
             EXIT.
           ENDIF.

         ENDLOOP.


       ENDIF.
     ENDIF.

   ENDIF.

 ENDFORM.                    " check_data
*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_EXCLUDE  text
*----------------------------------------------------------------------*
 FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

   DATA LS_EXCLUDE TYPE UI_FUNC.

   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.
   LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
   APPEND LS_EXCLUDE TO PT_EXCLUDE.

 ENDFORM.                    " exclude_tb_functions
*&---------------------------------------------------------------------*
*&      Form  fill_standard_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILL_STANDARD_LINES.

* Form rows
* 1. sor
   CLEAR W_FILE.
   W_FILE-LINE = '$ny_azon'.
   W_FILE-OP   = '='.

*----- VAT
   IF P_BTART = C_BTYPART_AFA.
     IF P_N = C_X.
       W_FILE-VAL  = V_DISP_BTYPE.
     ELSEIF P_O = C_X.
       CONCATENATE V_DISP_BTYPE+0(2) '310' INTO W_FILE-VAL.
     ELSE.
     ENDIF.
*---- Other
   ELSE.
     W_FILE-VAL  = V_DISP_BTYPE.
   ENDIF.

   CONCATENATE W_FILE-LINE
               W_FILE-OP
               W_FILE-VAL
               INTO I_FILE-LINE.
   INSERT I_FILE INDEX 1.

* 2. sor
   V_COUNTER = V_COUNTER + 4.  " A standard sorokat is számolni kell

   CLEAR W_FILE.
   W_FILE-LINE = '$sorok_száma'.
   W_FILE-OP   = '='.
   WRITE V_COUNTER TO W_FILE-VAL LEFT-JUSTIFIED.

   CONCATENATE W_FILE-LINE
               W_FILE-OP
               W_FILE-VAL
               INTO I_FILE-LINE.
   INSERT I_FILE INDEX 2.

* 3. sor
   CLEAR W_FILE.
   W_FILE-LINE = '$d_lapok_száma'.
   W_FILE-OP   = '='.
   W_FILE-VAL  = '0'.

   CONCATENATE W_FILE-LINE
               W_FILE-OP
               W_FILE-VAL
               INTO I_FILE-LINE.
   INSERT I_FILE INDEX 3.

* 4. sor
   CLEAR W_FILE.
   W_FILE-LINE = '$info'.
   W_FILE-OP   = '='.
   W_FILE-VAL  = TEXT-INF.

   CONCATENATE W_FILE-LINE
               W_FILE-OP
               W_FILE-VAL
               INTO I_FILE-LINE.
   INSERT I_FILE INDEX 4.

 ENDFORM.                    " fill_standard_lines
*&---------------------------------------------------------------------*
*&      Form  fill_normal_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILL_NORMAL_LINES CHANGING V_COUNTER.
   DATA:
   LT_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.

   DATA LW_OUTTAB TYPE /ZAK/BEVALLALV.

   LOOP AT I_OUTTAB_C INTO W_OUTTAB_C.

     READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_OUTTAB_C-BTYPE
                ABEVAZ = W_OUTTAB_C-ABEVAZ.

* Do not download summary rows
     IF SY-SUBRC = 0.
       IF W_/ZAK/BEVALLB-ABEV_NO = C_X.
         CONTINUE.
       ENDIF.

* Check - due date - for self-audit
*       IF P_O = C_X.
       IF W_/ZAK/BEVALLB-ESDAT_FLAG = C_X.
         IF W_OUTTAB_C-FIELD_C IS INITIAL AND P_O = C_X.
           MESSAGE E158(/ZAK/ZAK) WITH W_OUTTAB_C-ABEVAZ.
           EXIT.
*          ELSE.
* Read back from analytics where it originated - which index
* the value
*             REFRESH LT_/ZAK/ANALITIKA.
*             SELECT * INTO TABLE LT_/ZAK/ANALITIKA
*                 FROM /ZAK/ANALITIKA
*                  WHERE BUKRS  = W_OUTTAB_C-BUKRS
*                    AND BTYPE  = W_OUTTAB_C-BTYPE
*                    AND GJAHR  = W_OUTTAB_C-GJAHR
*                    AND MONAT  = W_OUTTAB_C-MONAT
*                    AND ABEVAZ = W_OUTTAB_C-ABEVAZ
*                    AND XDEFT  = 'X'.
*
*             READ TABLE LT_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
*                WITH KEY ZINDEX = W_OUTTAB_C-ZINDEX
**               TRANSPORTING NO FIELDS
*                .
*
*             IF SY-SUBRC NE 0.
*               MESSAGE E158(/ZAK/ZAK) WITH W_OUTTAB_C-ABEVAZ.
*               EXIT.
*             ENDIF.
         ELSEIF NOT W_OUTTAB_C-FIELD_C IS INITIAL AND P_N = C_X.
           DELETE I_OUTTAB_C.
           CONTINUE.
         ENDIF.
       ENDIF.
*       ENDIF.

* Identifiers with empty values are not needed either
       IF W_OUTTAB_C-FIELD_NR IS INITIAL AND
          W_OUTTAB_C-FIELD_C IS INITIAL.
         CONTINUE.
       ENDIF.


       V_COUNTER = V_COUNTER + 1.


* Form rows
       DATA: L_TEXT(20).

       CLEAR W_FILE.
       W_FILE-LINE = W_OUTTAB_C-ABEVAZ.
       W_FILE-OP   = '='.

       IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.
         W_FILE-VAL  = W_OUTTAB_C-FIELD_C.
       ELSE.

         IF W_OUTTAB_C-FIELD_NR < 0.
           WRITE W_OUTTAB_C-FIELD_NR TO W_FILE-VAL
                                    CURRENCY W_OUTTAB_C-WAERS
                                    LEFT-JUSTIFIED NO-GROUPING
                       USING EDIT MASK 'V_____________________________'.

         ELSE.
           WRITE W_OUTTAB_C-FIELD_NR TO W_FILE-VAL
                                    CURRENCY W_OUTTAB_C-WAERS
                                    LEFT-JUSTIFIED NO-GROUPING.
         ENDIF.
       ENDIF.

       CONCATENATE W_FILE-LINE
                   W_FILE-OP
                   W_FILE-VAL
                   INTO I_FILE-LINE.
       APPEND I_FILE.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " fill_normal_lines
*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE CHANGING L_SUBRC.
   DATA: L_DEF_FILENAME TYPE STRING,
*++0002 2007.01.03 BG (FMC)
         L_FILENAME     TYPE STRING,
*        L_FILENAME LIKE RLGRAP-FILENAME,
*--0002 2007.01.03 BG (FMC)
         L_FILTER       TYPE STRING,
         L_PATH         TYPE STRING,
         L_FULLPATH     TYPE STRING,
         L_ACTION       TYPE I.

   L_SUBRC = 4.

   CONCATENATE P_BUKRS V_DISP_BTYPE S_GJAHR-LOW S_MONAT-LOW S_INDEX-HIGH
                                                     INTO L_DEF_FILENAME
                                                        SEPARATED BY '_'.

   IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_TARS OR
      W_/ZAK/BEVALL-BTYPART = C_BTYPART_UCS.
     CONCATENATE L_DEF_FILENAME '.TXT' INTO L_DEF_FILENAME.
     L_FILTER = '*.TXT'.

   ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_SZJA
*++BG 2012.01.17
       OR W_/ZAK/BEVALL-BTYPART = C_BTYPART_KULF
*--BG 2012.01.17
*++2108 #09.
       OR W_/ZAK/BEVALL-BTYPART = C_BTYPART_KATA
*--2108 #09.
*++2308 #09.
      OR W_/ZAK/BEVALL-BTYPART = C_BTYPART_TAO.
*++2308 #09.
     CONCATENATE L_DEF_FILENAME '.XML' INTO L_DEF_FILENAME.
     L_FILTER = '*.XML'.

   ELSE.
     CONCATENATE L_DEF_FILENAME '.IMP' INTO L_DEF_FILENAME.
     L_FILTER = '*.IMP'.
   ENDIF.
*++ 0001 CST 2006.05.27
   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
     EXPORTING
*      WINDOW_TITLE      =
*      DEFAULT_EXTENSION = '*.*'
       DEFAULT_FILE_NAME = L_DEF_FILENAME
       FILE_FILTER       = L_FILTER
*      INITIAL_DIRECTORY =
     CHANGING
       FILENAME          = L_FILENAME
       PATH              = L_PATH
       FULLPATH          = L_FULLPATH
       USER_ACTION       = L_ACTION
     EXCEPTIONS
       CNTL_ERROR        = 1
       ERROR_NO_GUI      = 2
       OTHERS            = 3.


*   DATA: L_MASK(20)   TYPE C VALUE ',*.xls  ,*.xls.'.
*   DATA: L_CANCEL.
*
*   CALL FUNCTION 'WS_FILENAME_GET'
*      EXPORTING
*                 DEF_FILENAME     =  L_FILTER
*                 DEF_PATH         =  L_DEF_FILENAME
*                 MASK             =  L_MASK
*                 MODE             = 'S'
*                 TITLE            =  SY-TITLE
*      IMPORTING  FILENAME         =  L_FILENAME
**                RC               =  l_rc
*      EXCEPTIONS INV_WINSYS       =  04
*                 NO_BATCH         =  08
*                 SELECTION_CANCEL =  12
*                 SELECTION_ERROR  =  16.

* -- 0001  CST 2006.05.27
   IF SY-SUBRC = 0.

     L_FULLPATH = L_FILENAME.
* Save pushbutton.
     CHECK L_ACTION = 0.
* Kontrollok
     IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_TARS OR
        W_/ZAK/BEVALL-BTYPART = C_BTYPART_UCS.

       PERFORM CALL_DOWNLOAD CHANGING  L_FULLPATH
                                       L_SUBRC.

* SZJA
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_SZJA.
       PERFORM CALL_DOWNLOAD_XML CHANGING  L_FULLPATH
                                           L_SUBRC.

*++BG 2012.01.17
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_KULF.

       PERFORM CALL_DOWNLOAD_KULF CHANGING  L_FULLPATH
                                            L_SUBRC.
*--BG 2012.01.17
*++2108 #09.
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_KATA.

       PERFORM CALL_DOWNLOAD_KATA CHANGING  L_FULLPATH
                                            L_SUBRC.
*--2108 #09.
*++2308 #09.
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_TAO.

       PERFORM CALL_DOWNLOAD_TAO  CHANGING  L_FULLPATH
                                            L_SUBRC.
*--2308 #09.
* VAT and other
     ELSE.
*++0002 2007.01.03 BG (FMC)
* ++ 0001  CST 2006.05.27
       CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
         EXPORTING
           FILENAME                = L_FULLPATH
         CHANGING
           DATA_TAB                = I_FILE[]
         EXCEPTIONS
           FILE_WRITE_ERROR        = 1
           NO_BATCH                = 2
           GUI_REFUSE_FILETRANSFER = 3
           INVALID_TYPE            = 4
           NO_AUTHORITY            = 5
           UNKNOWN_ERROR           = 6
           HEADER_NOT_ALLOWED      = 7
           SEPARATOR_NOT_ALLOWED   = 8
           FILESIZE_NOT_ALLOWED    = 9
           HEADER_TOO_LONG         = 10
           DP_ERROR_CREATE         = 11
           DP_ERROR_SEND           = 12
           DP_ERROR_WRITE          = 13
           UNKNOWN_DP_ERROR        = 14
           ACCESS_DENIED           = 15
           DP_OUT_OF_MEMORY        = 16
           DISK_FULL               = 17
           DP_TIMEOUT              = 18
           FILE_NOT_FOUND          = 19
           DATAPROVIDER_EXCEPTION  = 20
           CONTROL_FLUSH_ERROR     = 21
           OTHERS                  = 22.

       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
         MESSAGE I009(/ZAK/ZAK) WITH L_FILENAME.
         L_SUBRC = 0.
       ENDIF.

*       CALL FUNCTION 'DOWNLOAD'
*            EXPORTING
*                 FILENAME                = L_FILENAME
*                 FILETYPE                = 'ASC'
**                FILEMASK_ALL            = 'X'
*                 FILETYPE_NO_CHANGE      = 'X'
**                FILEMASK_ALL            = ' '
*                 FILETYPE_NO_SHOW        = 'X'
*            IMPORTING
*                 CANCEL                  = L_CANCEL
*            TABLES
*                 DATA_TAB                = I_FILE[]
**           FIELDNAMES              =
*            EXCEPTIONS
*                 INVALID_FILESIZE        = 1
*                 INVALID_TABLE_WIDTH     = 2
*                 INVALID_TYPE            = 3
*                 NO_BATCH                = 4
*                 UNKNOWN_ERROR           = 5
*                 GUI_REFUSE_FILETRANSFER = 6
*                 CUSTOMER_ERROR          = 7
*                 OTHERS                  = 8.
*
*       IF SY-SUBRC <> 0 OR L_CANCEL = 'X' OR L_CANCEL = 'x'.
*         L_SUBRC = 4.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*
*       ELSE.
*         MESSAGE I009(/ZAK/ZAK) WITH L_FILENAME.
*         L_SUBRC = 0.
*
*       ENDIF.
* -- 0001  CST 2006.05.27
*++0002 2007.01.03 BG (FMC)

     ENDIF.
   ENDIF.
 ENDFORM.                    " download_file
*&---------------------------------------------------------------------*
*&      Form  update_bevallo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
 FORM UPDATE_BEVALLO  TABLES   $I_OUTTAB STRUCTURE /ZAK/BEVALLALV
                      CHANGING L_SUBRC.
   DATA: L_COUNT_ERROR TYPE I.

   L_COUNT_ERROR = 0.
   L_SUBRC = 4.

* Process indicator
   PERFORM PROCESS_IND USING TEXT-P04.

* Delete any previous save
   DELETE FROM /ZAK/BEVALLO
      WHERE BUKRS = P_BUKRS     AND
            BTYPE = P_BTYPE     AND
            GJAHR = S_GJAHR-LOW AND
*           MONAT = S_MONAT-LOW AND
            MONAT IN R_MONAT    AND
            ZINDEX = S_INDEX-HIGH.

   IF SY-SUBRC = 0.
     COMMIT WORK.
   ENDIF.


*   LOOP AT I_OUTTAB_C INTO W_OUTTAB_C.
*     MOVE-CORRESPONDING W_OUTTAB_C TO /ZAK/BEVALLO.
*     /ZAK/BEVALLO-ZINDEX = S_INDEX-HIGH.
*     INSERT /ZAK/BEVALLO.
*     IF SY-SUBRC = 0.
*       COMMIT WORK.
*     ELSE.
*       L_COUNT_ERROR = L_COUNT_ERROR + 1.
*     ENDIF.
*   ENDLOOP.
* Process indicator
   PERFORM PROCESS_IND USING TEXT-P04.

   REFRESH I_/ZAK/BEVALLO.
   LOOP AT  $I_OUTTAB INTO W_OUTTAB_C.
     CLEAR W_/ZAK/BEVALLO.
     MOVE-CORRESPONDING W_OUTTAB_C TO W_/ZAK/BEVALLO.
     W_/ZAK/BEVALLO-ZINDEX = S_INDEX-HIGH.
     APPEND W_/ZAK/BEVALLO TO I_/ZAK/BEVALLO.
     DELETE $I_OUTTAB.
   ENDLOOP.
   FREE $I_OUTTAB.

*  Process indicator
   PERFORM PROCESS_IND USING TEXT-P04.

*  Delete duplicates by key
   SORT I_/ZAK/BEVALLO.
   DELETE ADJACENT DUPLICATES FROM I_/ZAK/BEVALLO COMPARING
                                   BUKRS
                                   BTYPE
                                   GJAHR
                                   MONAT
                                   ZINDEX
                                   ABEVAZ
                                   ADOAZON
                                   LAPSZ.
*  Process indicator
   PERFORM PROCESS_IND USING TEXT-P04.

   INSERT /ZAK/BEVALLO FROM TABLE I_/ZAK/BEVALLO.
   IF SY-SUBRC = 0.
     COMMIT WORK.
   ELSE.
     L_COUNT_ERROR = L_COUNT_ERROR + 1.
   ENDIF.
   FREE I_/ZAK/BEVALLO.

   IF L_COUNT_ERROR > 0.

*    Process indicator
     PERFORM PROCESS_IND USING TEXT-P04.

     DELETE FROM /ZAK/BEVALLO
       WHERE BUKRS = P_BUKRS     AND
             BTYPE = P_BTYPE     AND
             GJAHR = S_GJAHR-LOW AND
*            MONAT = S_MONAT-LOW AND
             MONAT IN R_MONAT    AND
             ZINDEX = S_INDEX-HIGH.
     IF SY-SUBRC = 0.
       COMMIT WORK.
     ENDIF.
     L_SUBRC = 4.
   ELSE.
     L_SUBRC = 0.
   ENDIF.
 ENDFORM.                    " update_bevallo
*&---------------------------------------------------------------------*
*&      Form  status_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM STATUS_UPDATE.
* /ZAK/BEVALLSZ

   UPDATE /ZAK/BEVALLSZ SET FLAG = 'T'
                           DATUM = SY-DATUM
                           UZEIT = SY-UZEIT
                           UNAME = SY-UNAME
      WHERE BUKRS = P_BUKRS
        AND BTYPE = P_BTYPE
        AND GJAHR = S_GJAHR-LOW
        AND MONAT IN R_MONAT
        AND ZINDEX = S_INDEX-HIGH.

   IF SY-SUBRC = 0.
     COMMIT WORK.
   ENDIF.

* /ZAK/BEVALLI
   UPDATE /ZAK/BEVALLI SET FLAG = 'T'
                          DWNDT = SY-DATUM
                          DATUM = SY-DATUM
                          UZEIT = SY-UZEIT
                          UNAME = SY-UNAME
      WHERE BUKRS = P_BUKRS
        AND BTYPE = P_BTYPE
        AND GJAHR = S_GJAHR-LOW
        AND MONAT IN R_MONAT
        AND ZINDEX = S_INDEX-HIGH.

   IF SY-SUBRC = 0.
     COMMIT WORK.
   ENDIF.

 ENDFORM.                    " status_update
*&---------------------------------------------------------------------*
*&      Form  call_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_EXIT.
   IF V_DYNNR = '9002'.

     CALL FUNCTION '/ZAK/MAIN_EXIT_NEW'
       EXPORTING
         I_BUKRS   = P_BUKRS
         I_BTYPE   = P_BTYPE
         I_GJAHR   = S_GJAHR-LOW
         I_MONAT   = S_MONAT-LOW
         I_INDEX   = S_INDEX-HIGH
       TABLES
         T_BEVALLO = I_OUTTAB_L
         T_ADOAZON = I_/ZAK/ONR_ADOAZON.

   ELSE.
*++2108 #05.
     CALL FUNCTION '/ZAK/KATA_EXIT'
       EXPORTING
         I_BUKRS         = P_BUKRS
         I_BTYPE         = P_BTYPE
         I_GJAHR         = S_GJAHR-LOW
         I_MONAT         = S_MONAT-LOW
         I_INDEX         = S_INDEX-HIGH
       TABLES
         T_BEVALLO       = I_OUTTAB
*++2108 #19.
         T_ONREV_ADOAZON = I_/ZAK/ONR_ADOAZON.
*--2108 #19.
*--2108 #05.
     CALL FUNCTION '/ZAK/MAIN_EXIT_NEW'
       EXPORTING
         I_BUKRS   = P_BUKRS
         I_BTYPE   = P_BTYPE
         I_GJAHR   = S_GJAHR-LOW
         I_MONAT   = S_MONAT-LOW
         I_INDEX   = S_INDEX-HIGH
       TABLES
         T_BEVALLO = I_OUTTAB
         T_ADOAZON = I_/ZAK/ONR_ADOAZON.
   ENDIF.
 ENDFORM.                    " call_exit

*&---------------------------------------------------------------------*
*&      Form SET_FIELDS_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_FIELDS_F4   TABLES RECORD_TAB    STRUCTURE SEAHLPRES
                      CHANGING        SHLP TYPE      SHLP_DESCR_T
                               CALLCONTROL LIKE      DDSHF4CTRL.

   DATA: I_BTYPES TYPE /ZAK/T_BTYPE.
   DATA: W_BTYPES TYPE /ZAK/BTYPE.
   DATA: LS_SELOPT TYPE DDSHSELOPT.

   LS_SELOPT-SHLPFIELD = 'BUKRS'.
   LS_SELOPT-SIGN      = 'I'.
   LS_SELOPT-OPTION    = 'EQ'.
   LS_SELOPT-LOW       = P_BUKRS.
   APPEND LS_SELOPT TO SHLP-SELOPT.


   PERFORM GET_BTYPES TABLES I_BTYPES
                      USING P_BUKRS
                            P_BTART .

   SORT I_BTYPES DESCENDING.
   LOOP AT I_BTYPES INTO W_BTYPES.
     CLEAR LS_SELOPT.
     LS_SELOPT-SHLPFIELD = 'BTYPE'.
     LS_SELOPT-SIGN      = 'I'.
     LS_SELOPT-OPTION    = 'EQ'.
     LS_SELOPT-LOW       = W_BTYPES.
     APPEND LS_SELOPT TO SHLP-SELOPT.
   ENDLOOP.


 ENDFORM.                    "SET_FIELDS_F4
*&---------------------------------------------------------------------*
*&      Form  call_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
 FORM CALL_DOWNLOAD  CHANGING L_FULLPATH
                              L_SUBRC.


   CALL FUNCTION '/ZAK/KONT_FILE_DOWNLOAD'
     TABLES
       T_/ZAK/BEVALLALV    = I_OUTTAB_C[]
     CHANGING
       I_FILE               = L_FULLPATH
     EXCEPTIONS
       ERROR_CUST_FILE_DATA = 1
       ERROR_T001Z          = 2
       ERROR_FILE_DOWNLOAD  = 3
       OTHERS               = 4.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     L_SUBRC = 4.
   ELSE.
     L_SUBRC = 0.
     MESSAGE I009(/ZAK/ZAK) WITH L_FULLPATH.
   ENDIF.


 ENDFORM.                    " call_download
*&---------------------------------------------------------------------*
*&      Form  enqueue_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ENQUEUE_PERIOD.

   CALL FUNCTION 'ENQUEUE_/ZAK/EBEVALLSZ'
     EXPORTING
       MODE_/ZAK/BEVALLSZ = C_X
       BUKRS             = P_BUKRS
       BTYPE             = P_BTYPE
       GJAHR             = S_GJAHR-LOW
       MONAT             = S_MONAT-LOW
       ZINDEX            = S_INDEX-HIGH
     EXCEPTIONS
       FOREIGN_LOCK      = 1
       SYSTEM_FAILURE    = 2
       OTHERS            = 3.

   IF SY-SUBRC <> 0.
     MESSAGE W099(/ZAK/ZAK) WITH P_BUKRS P_BTYPE.
     SET SCREEN 0.
     LEAVE SCREEN.
   ENDIF.

 ENDFORM.                    " enqueue_period
*&---------------------------------------------------------------------*
*&      Form  fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0854   text
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
 FORM FILL_CELLTAB USING VALUE(P_MODE)
                   CHANGING PT_CELLTAB TYPE LVC_T_STYL.

   DATA: LS_CELLTAB TYPE LVC_S_STYL,
         L_MODE     TYPE RAW4.
* Column 'XDEFT' is editable when character

   IF P_MODE EQ 'RW'.
     L_MODE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
   ELSE. "p_mode eq 'RO'
     L_MODE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
   ENDIF.


* Set fields
   DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

   CALL FUNCTION 'DD_GET_DD03P_ALL'
     EXPORTING
       LANGU         = SYST-LANGU
       TABNAME       = '/ZAK/ANALITIKA'
     TABLES
       A_DD03P_TAB   = I_DD03P
       N_DD03P_TAB   = I_DD03P_2
     EXCEPTIONS
       ILLEGAL_VALUE = 1
       OTHERS        = 2.

   CHECK SY-SUBRC = 0.

   LOOP AT I_DD03P.

     IF I_DD03P-FIELDNAME NE 'XDEFT'.
       LS_CELLTAB-FIELDNAME = I_DD03P-FIELDNAME.
       LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
       INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
     ELSE.
       LS_CELLTAB-FIELDNAME = 'XDEFT'.
       LS_CELLTAB-STYLE = L_MODE.
       INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " fill_celltab
*&---------------------------------------------------------------------*
*&      Form  get_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTART  text
*      -->P_S_GJAHR_LOW  text
*      -->P_S_MONAT_LOW  text
*      <--P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM GET_BTYPE USING    $BUKRS
                         $BTYPART
                         $GJAHR
                         $MONAT
                CHANGING $BTYPE.

   CLEAR $BTYPE.

   CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
     EXPORTING
       I_BUKRS     = $BUKRS
       I_BTYPART   = $BTYPART
       I_GJAHR     = $GJAHR
       I_MONAT     = $MONAT
     IMPORTING
       E_BTYPE     = $BTYPE
     EXCEPTIONS
       ERROR_MONAT = 1
       ERROR_BTYPE = 2
       OTHERS      = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " get_btype
*&---------------------------------------------------------------------*
*&      Form  fill_s_ranges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILL_S_RANGES.
   IF P_N = C_X.
     S_GJAHR[] = S_GJAHR1[].
     S_MONAT[] = S_MONAT1[].
*    s_index[] = s_index1[].

     IF S_INDEX1-LOW IS INITIAL.
       S_INDEX1-LOW = '000'.
     ENDIF.

     REFRESH S_INDEX.
     S_INDEX-SIGN   = 'I'.
     S_INDEX-OPTION = 'BT'.
     S_INDEX-LOW    = S_INDEX1-LOW.
     S_INDEX-HIGH   = S_INDEX1-LOW.
     APPEND S_INDEX.

   ELSEIF P_O = C_X.
     S_GJAHR[] = S_GJAHR2[].
     S_MONAT[] = S_MONAT2[].
*    s_index[] = s_index2[].

     READ TABLE S_INDEX2 INDEX 1.

     IF P_CUM = C_X.
       REFRESH S_INDEX.
       S_INDEX-SIGN   = 'I'.
       S_INDEX-OPTION = 'BT'.
       S_INDEX-LOW    = '000'.
       S_INDEX-HIGH   = S_INDEX2-LOW.
       APPEND S_INDEX.
     ELSE.
       REFRESH S_INDEX.
       S_INDEX-SIGN   = 'I'.
       S_INDEX-OPTION = 'BT'.
       S_INDEX-LOW    = S_INDEX2-LOW.
       S_INDEX-HIGH   = S_INDEX2-LOW.
       APPEND S_INDEX.
     ENDIF.

   ELSE.
     S_GJAHR[] = S_GJAHR3[].
     S_MONAT[] = S_MONAT3[].
*     S_INDEX[] = S_INDEX3[].

     READ TABLE S_INDEX3 INDEX 1.

     IF P_CUM3 = C_X.
       REFRESH S_INDEX.
       S_INDEX-SIGN   = 'I'.
       S_INDEX-OPTION = 'BT'.
       S_INDEX-LOW    = '000'.
       S_INDEX-HIGH   = S_INDEX3-LOW.
       APPEND S_INDEX.
     ELSE.
       REFRESH S_INDEX.
       S_INDEX-SIGN   = 'I'.
       S_INDEX-OPTION = 'BT'.
       S_INDEX-LOW    = S_INDEX3-LOW.
       S_INDEX-HIGH   = S_INDEX3-LOW.
       APPEND S_INDEX.
     ENDIF.

   ENDIF.

 ENDFORM.                    " fill_s_ranges
*&---------------------------------------------------------------------*
*&      Form  get_btypes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BTYPES  text
*      -->P_P_BUKRS  text
*      -->P_P_BTART  text
*----------------------------------------------------------------------*
 FORM GET_BTYPES TABLES   I_BTYPES TYPE /ZAK/T_BTYPE
                 USING    $BUKRS
                          $BTYPART.

   REFRESH I_BTYPES.

   CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART_M'
     EXPORTING
       I_BUKRS     = $BUKRS
       I_BTYPART   = $BTYPART
*      I_GJAHR     =
*      I_MONAT     =
* IMPORTING
*      E_BTYPE     =
     TABLES
       T_BTYPES    = I_BTYPES
     EXCEPTIONS
       ERROR_MONAT = 1
       ERROR_BTYPE = 2
       OTHERS      = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " get_btypes
*&---------------------------------------------------------------------*
*&      Form  popup_btype_sel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM POPUP_BTYPE_SEL CHANGING $DISP_BTYPE.

   DATA: L_DATUM  TYPE DATUM.
   DATA: V_BEVALL TYPE /ZAK/BEVALL.
   DATA: I_POPUP  TYPE STANDARD TABLE OF /ZAK/BEVALL INITIAL SIZE 0.
   DATA: V_ANSWER TYPE C.
   DATA: T_SPOPLI LIKE SPOPLI OCCURS 0 WITH HEADER LINE.


   L_DATUM = W_/ZAK/BEVALL-DATBI.

   CLEAR $DISP_BTYPE.
* Check: is it newer
   LOOP AT I_/ZAK/BEVALL INTO V_BEVALL.
     IF V_BEVALL-DATBI >= L_DATUM.
       APPEND V_BEVALL TO I_POPUP.
     ENDIF.
   ENDLOOP.

* Popup only required if there are multiple options
   DESCRIBE TABLE I_POPUP LINES SY-TFILL.
   IF SY-TFILL > 1.

     LOOP AT I_POPUP INTO V_BEVALL.
       CLEAR T_SPOPLI.
       T_SPOPLI-VAROPTION = V_BEVALL-BTYPE.
       APPEND T_SPOPLI.
     ENDLOOP.

     CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
       EXPORTING
*        CURSORLINE         = 1
*        MARK_FLAG          = ' '
         MARK_MAX           = 1
         START_COL          = 15
         START_ROW          = 10
         TEXTLINE1          = TEXT-T10
*        TEXTLINE2          = ' '
*        TEXTLINE3          = ' '
         TITEL              = TEXT-T11
*        DISPLAY_ONLY       = ' '
       IMPORTING
         ANSWER             = V_ANSWER
       TABLES
         T_SPOPLI           = T_SPOPLI
       EXCEPTIONS
         NOT_ENOUGH_ANSWERS = 1
         TOO_MUCH_ANSWERS   = 2
         TOO_MUCH_MARKS     = 3
         OTHERS             = 4.

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

     IF V_ANSWER <> 'A'.

       READ TABLE T_SPOPLI WITH KEY SELFLAG = C_X.
       IF SY-SUBRC = 0.
         $DISP_BTYPE = T_SPOPLI-VAROPTION.
       ELSE.
         $DISP_BTYPE = P_BTYPE.
       ENDIF.
     ELSE.
       $DISP_BTYPE = P_BTYPE.
     ENDIF.


   ELSE.
     $DISP_BTYPE = P_BTYPE.
   ENDIF.


 ENDFORM.                    " popup_btype_sel
*&---------------------------------------------------------------------*
*&      Form  btype_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB  text
*      -->P_P_BTYPE  text
*      -->P_V_DISP_BTYPE  text
*----------------------------------------------------------------------*
 FORM BTYPE_CONVERSION
                       TABLES   I_OUTTAB STRUCTURE /ZAK/BEVALLALV
                       USING    $BUKRS
                                $BTYPE
                                $DISP_BTYPE.

   CALL FUNCTION '/ZAK/BTYPE_CONVERSION'
     EXPORTING
       I_BUKRS          = $BUKRS
       I_BTYPE_FROM     = $BTYPE
       I_BTYPE_TO       = $DISP_BTYPE
     TABLES
       T_BEVALLO        = I_OUTTAB
     EXCEPTIONS
       CONVERSION_ERROR = 1
       OTHERS           = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " btype_conversion
*&---------------------------------------------------------------------*
*&      Form  copy_outtab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM COPY_OUTTAB.

   CLEAR   W_OUTTAB_C.
   REFRESH I_OUTTAB_C.


* Conversion
   LOOP AT I_OUTTAB INTO W_OUTTAB.

     MOVE-CORRESPONDING W_OUTTAB TO W_OUTTAB_C.

     IF ( W_OUTTAB_C-BTYPE_DISP  NE W_OUTTAB_C-BTYPE
      OR W_OUTTAB_C-ABEVAZ_DISP NE W_OUTTAB_C-ABEVAZ ).
       W_OUTTAB_C-BTYPE  = W_OUTTAB_C-BTYPE_DISP.
       W_OUTTAB_C-ABEVAZ = W_OUTTAB_C-ABEVAZ_DISP.
     ENDIF.

     COLLECT W_OUTTAB_C INTO I_OUTTAB_C.
   ENDLOOP.


* Append employee data
   IF P_BTART = C_BTYPART_SZJA.
     LOOP AT I_OUTTAB_D INTO W_OUTTAB_D.
       MOVE-CORRESPONDING W_OUTTAB_D TO W_OUTTAB_C.
       COLLECT W_OUTTAB_C INTO I_OUTTAB_C.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " copy_outtab
*&---------------------------------------------------------------------*
*&      Module  check_kostl  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_KOSTL INPUT.
   PERFORM CHECK_KOSTL.
 ENDMODULE.                 " check_kostl  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_kostl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_KOSTL.
   IF NOT /ZAK/ANALITIKA_S-KOSTL IS INITIAL.

     SELECT * UP TO 1 ROWS INTO CSKS FROM  CSKS
            WHERE  KOSTL  = /ZAK/ANALITIKA_S-KOSTL.
     ENDSELECT.


     IF SY-SUBRC NE 0.
       MESSAGE E122(/ZAK/ZAK) WITH /ZAK/ANALITIKA_S-KOSTL.
     ENDIF.
   ENDIF.
 ENDFORM.                    " check_kostl
*&---------------------------------------------------------------------*
*&      Module  check_aufnr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_AUFNR INPUT.
   PERFORM CHECK_AUFNR.
 ENDMODULE.                 " check_aufnr  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_aufnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_AUFNR.
   IF NOT /ZAK/ANALITIKA_S-AUFNR IS INITIAL.

     SELECT SINGLE * INTO AUFK FROM  AUFK
            WHERE  AUFNR  = /ZAK/ANALITIKA_S-AUFNR.
     IF SY-SUBRC NE 0.
       MESSAGE E122(/ZAK/ZAK) WITH /ZAK/ANALITIKA_S-AUFNR.
     ENDIF.
   ENDIF.

 ENDFORM.                    " check_aufnr
*&---------------------------------------------------------------------*
*&      Module  check_prctr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_PRCTR INPUT.
   PERFORM CHECK_PRCTR.
 ENDMODULE.                 " check_prctr  INPUT
*&---------------------------------------------------------------------*
*&      Form  check_prctr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_PRCTR.
   IF NOT /ZAK/ANALITIKA_S-PRCTR IS INITIAL.

     CALL FUNCTION 'KE_PROFIT_CENTER_CHECK'
       EXPORTING
         BUKRS                 = /ZAK/ANALITIKA_S-BUKRS
*        DATUM                 = '00000000'
*        DATUM_BIS             = '00000000'
         PRCTR                 = /ZAK/ANALITIKA_S-PRCTR
*        TEST_KOKRS            = ' '
*        READ_TEXT             = C_X
*        TEST                  = ' '
*  IMPORTING
*        BUKRS_JV              =
*        DATBI                 =
*        ETYPE                 =
*        KOKRS                 =
*        KTEXT                 =
*        RECID                 =
*        REGIO                 =
*        RETURN_CODE           =
*        TXJCD                 =
*        VNAME                 =
*        LTEXT                 =
       EXCEPTIONS
         NOT_FOUND             = 1
         NOT_DEFINED_FOR_DATE  = 2
         NO_KOKRS_FOR_BUKRS    = 3
         PARAMETER_MISMATCH    = 4
         PRCTR_LOCKED          = 5
         NOT_DEFINED_FOR_BUKRS = 6
         OTHERS                = 7.

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.


   ENDIF.
 ENDFORM.                    " check_prctr
*&---------------------------------------------------------------------*
*&      Form  sub_f4_on_vari
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SUB_F4_ON_VARI.
   X_SAVE = 'A'.
   CLEAR X_LAYOUT.
   MOVE V_REPID TO X_LAYOUT-REPORT.


   CALL FUNCTION 'LVC_VARIANT_F4'
     EXPORTING
       IS_VARIANT = X_LAYOUT
       I_SAVE     = X_SAVE
     IMPORTING
       E_EXIT     = G_EXIT
       ES_VARIANT = SPEC_LAYOUT
     EXCEPTIONS
       NOT_FOUND  = 1
       OTHERS     = 2.
   IF SY-SUBRC NE 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     IF G_EXIT NE C_X.
* set name of layout on selection screen
       P_VARI    = SPEC_LAYOUT-VARIANT.
     ENDIF.
   ENDIF.

 ENDFORM.                    " sub_f4_on_vari
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
*&      Form  check_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_DATE.
   DATA: L_LEN     TYPE I,
         L_STR(10) TYPE C,
         L_DATE    TYPE D.

   CHECK W_/ZAK/BEVALLB-ESDAT_FLAG = C_X.

* Length cannot be greater than 10
   L_LEN = STRLEN( /ZAK/ANALITIKA_S-FIELD_C ).
   IF L_LEN > 10.
     MESSAGE E159(/ZAK/ZAK).
   ENDIF.

* Convert entered string to date
   L_STR = /ZAK/ANALITIKA_S-FIELD_C.
   CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
     EXPORTING
       INPUT  = L_STR
     IMPORTING
       OUTPUT = L_DATE.

   IF NOT L_DATE IS INITIAL.
     /ZAK/ANALITIKA_S-FIELD_C = L_DATE.
   ENDIF.

 ENDFORM.                    " check_date
*&---------------------------------------------------------------------*
*&      Module  check_date  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_DATE INPUT.
   PERFORM CHECK_DATE.
 ENDMODULE.                 " check_date  INPUT
*&---------------------------------------------------------------------*
*&      Form  conv_index
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_INDEX1_LOW  text
*----------------------------------------------------------------------*
 FORM CONV_INDEX CHANGING $IND.

   DATA: L_INDEX(3) TYPE N.

   IF NOT $IND IS INITIAL.
     L_INDEX = $IND.
     $IND = L_INDEX.
   ENDIF.


 ENDFORM.                    " conv_index
*&---------------------------------------------------------------------*
*&      Form  clear_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLEAR_ALL.

   REFRESH: S_INDEX,
            S_GJAHR1, S_GJAHR2, S_GJAHR3,
            S_MONAT1, S_MONAT2, S_MONAT3,
            S_INDEX1, S_INDEX2, S_INDEX3.

   CLEAR: S_INDEX,
            S_GJAHR1, S_GJAHR2, S_GJAHR3,
            S_MONAT1, S_MONAT2, S_MONAT3,
            S_INDEX1, S_INDEX2, S_INDEX3.


 ENDFORM.                    " clear_all
*&---------------------------------------------------------------------*
*&      Form  call_download_xml
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_DOWNLOAD_XML CHANGING $FULLPATH
                                 $SUBRC.

   DATA: L_FILENAME TYPE STRING.

   L_FILENAME = $FULLPATH.

*++1408 #01.
   IF W_/ZAK/BEVALL-STRANS IS INITIAL.
*--1408 #01.
     CALL FUNCTION '/ZAK/XML_FILE_DOWNLOAD'
       EXPORTING
         I_FILE            = L_FILENAME
*++BG 2006/09/29
         I_GJAHR           = S_GJAHR-LOW
         I_MONAT           = S_MONAT-LOW
*--BG 2006/09/29
       TABLES
         T_/ZAK/BEVALLALV = I_OUTTAB_C[]
       EXCEPTIONS
         ERROR_DOWNLOAD    = 1
*++BG 2006/09/29
         ERROR_IMP_PAR     = 2
*--BG 2006/09/29
         OTHERS            = 3.
*++1408 #01.
   ELSE.
*      Create XML
     CALL FUNCTION '/ZAK/SZJA_XML_DOWNLOAD'
       EXPORTING
         I_FILE            = L_FILENAME
*        I_GJAHR           =
*        I_MONAT           =
       TABLES
         T_/ZAK/BEVALLALV = I_OUTTAB_C
       EXCEPTIONS
         ERROR             = 1
         ERROR_DOWNLOAD    = 2
         OTHERS            = 3.
   ENDIF.
*--1408 #01.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     MESSAGE E175(/zak/zak) with $fullpath.
     $SUBRC = 4.
   ELSE.
     $SUBRC = 0.
     MESSAGE I009(/ZAK/ZAK) WITH $FULLPATH.
   ENDIF.

 ENDFORM.                    " call_download_xml
*&---------------------------------------------------------------------*
*&      Module  STATUS_9900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9900 OUTPUT.
   SET PF-STATUS 'MAIN_9900'.
   SET TITLEBAR 'T01'.

 ENDMODULE.                 " STATUS_9900  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9900 INPUT.
   CASE V_OK_CODE.
     WHEN 'BUT_OK'.
       PERFORM GET_DATA_9900.
   ENDCASE.
 ENDMODULE.                 " USER_COMMAND_9900  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_9900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE SET_9900 OUTPUT.
   PERFORM SET_9900.
 ENDMODULE.                 " set_9900  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  set_9900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_9900.

   READ TABLE I_OUTTAB INTO W_OUTTAB INDEX 1.
   CHECK SY-SUBRC = 0.

   /ZAK/ANALITIKA-BUKRS = P_BUKRS.
   /ZAK/ANALITIKA-BTYPE = P_BTYPE.
   /ZAK/ANALITIKA-GJAHR = W_OUTTAB-GJAHR.
   /ZAK/ANALITIKA-MONAT = W_OUTTAB-MONAT.
   /ZAK/ANALITIKA-ZINDEX = W_OUTTAB-ZINDEX.

 ENDFORM.                                                   " set_9900
*&---------------------------------------------------------------------*
*&      Module  user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND INPUT.
   CASE V_OK_CODE.
     WHEN 'BUT_CANC'.
       SET SCREEN 0.
       LEAVE SCREEN.
   ENDCASE.

 ENDMODULE.                 " user_command  INPUT
*&---------------------------------------------------------------------*
*&      Form  get_data_9900
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_DATA_9900.
   REFRESH I_OUTTAB_L.

   IF /ZAK/ANALITIKA-ADOAZON IS INITIAL.
     MESSAGE I176(/ZAK/ZAK).
   ELSE.
     LOOP AT I_OUTTAB_D INTO W_OUTTAB_D
        WHERE ADOAZON = /ZAK/ANALITIKA-ADOAZON.
       MOVE-CORRESPONDING W_OUTTAB_D TO W_OUTTAB_L.
       APPEND W_OUTTAB_L TO I_OUTTAB_L.
     ENDLOOP.

     CALL SCREEN 9002.
   ENDIF.
 ENDFORM.                    " get_data_9900
*&---------------------------------------------------------------------*
*&      Module  pbo_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO_9002 OUTPUT.
   PERFORM SET_STATUS.

   IF V_CUSTOM_CONTAINER3 IS INITIAL.
     V_DYNNR = SY-DYNNR.
     PERFORM CREATE_AND_INIT_ALV3 CHANGING I_OUTTAB_L[]
                                           I_FIELDCAT
                                           V_LAYOUT
                                           V_VARIANT.
   ELSE.
     CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
   ENDIF.

 ENDMODULE.                 " pbo_9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB_L[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV3 CHANGING PT_OUTTAB  LIKE I_OUTTAB[]
                                    PT_FIELDCAT TYPE LVC_T_FCAT
                                    PS_LAYOUT   TYPE LVC_S_LAYO
                                    PS_VARIANT  TYPE DISVARIANT.

   DATA: I_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER3
     EXPORTING
       CONTAINER_NAME = V_CONTAINER3.
   CREATE OBJECT V_GRID3
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER3.

* Build field catalog
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING PT_FIELDCAT.
*
* Exclude functions
   PERFORM EXCLUDE_TB_FUNCTIONS CHANGING I_EXCLUDE.

   PS_LAYOUT-CWIDTH_OPT = C_X.
* allow to select multiple lines
   PS_LAYOUT-SEL_MODE = 'A'.

   CLEAR PS_VARIANT.
   PS_VARIANT-REPORT = V_REPID.

   IF NOT SPEC_LAYOUT IS INITIAL.
     MOVE-CORRESPONDING SPEC_LAYOUT TO PS_VARIANT.
   ELSEIF NOT DEF_LAYOUT IS INITIAL.
     MOVE-CORRESPONDING DEF_LAYOUT TO PS_VARIANT.
   ELSE.
   ENDIF.

   CALL METHOD V_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT           = PS_VARIANT
       I_SAVE               = 'A'
       I_DEFAULT            = C_X
       IS_LAYOUT            = PS_LAYOUT
       IT_TOOLBAR_EXCLUDING = I_EXCLUDE
     CHANGING
       IT_FIELDCATALOG      = PT_FIELDCAT
       IT_OUTTAB            = PT_OUTTAB.


   CREATE OBJECT V_EVENT_RECEIVER3.

   SET HANDLER V_EVENT_RECEIVER3->HANDLE_HOTSPOT_CLICK  FOR V_GRID3.
   SET HANDLER V_EVENT_RECEIVER3->HANDLE_DATA_CHANGED   FOR V_GRID3.
   SET HANDLER V_EVENT_RECEIVER3->HANDLE_USER_COMMAND   FOR V_GRID3.


   SET HANDLER V_EVENT_RECEIVER3->HANDLE_TOOLBAR       FOR V_GRID3.
* raise event TOOLBAR:
   CALL METHOD V_GRID3->SET_TOOLBAR_INTERACTIVE.

 ENDFORM.                    " CREATE_AND_INIT_ALV3
*&---------------------------------------------------------------------*
*&      Form  process_ind
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM PROCESS_IND USING $TEXT.
   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
*      PERCENTAGE       = 0
       TEXT = $TEXT.

 ENDFORM.                    " process_ind
*&---------------------------------------------------------------------*
*&      Form  process_ind_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_INDEX  text
*----------------------------------------------------------------------*
 FORM PROCESS_IND_ITEM USING   $VALUE
                               $INDEX
                               $TEXT.
*  only when running in dialog
   CHECK SY-BATCH IS INITIAL.
   ADD 1 TO $INDEX.
   IF $INDEX EQ $VALUE.
     PERFORM PROCESS_IND USING $TEXT.
     CLEAR $INDEX.
     COMMIT WORK.
   ENDIF.

 ENDFORM.                    " process_ind_item
*&---------------------------------------------------------------------*
*&      Form  BATCH_BEVALLO_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM BATCH_BEVALLO_UPDATE.

   PERFORM UPDATE_BEVALLO  TABLES   I_OUTTAB
                           CHANGING L_SUBRC.


 ENDFORM.                    " BATCH_BEVALLO_UPDATE
*&---------------------------------------------------------------------*
*&      Form  CHECK_COLL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLB  text
*      -->P_L_SUBRC  text
*----------------------------------------------------------------------*
 FORM CHECK_COLL_DATA USING    $BEVALLB STRUCTURE /ZAK/BEVALLB
                               $SUBRC.

   DATA LW_/ZAK/BEVALLB LIKE /ZAK/BEVALLB.

*  Create 'A' identifiers
   IF $BEVALLB-ABEVAZ(1) = 'A'.
     CLEAR $SUBRC.
     EXIT.
   ELSE.
*  The record is not needed for now
     MOVE 4 TO $SUBRC.
   ENDIF.

*The record is only needed if calculated, transferred or aggregated
   READ TABLE I_/ZAK/BEVALLB INTO LW_/ZAK/BEVALLB
                           WITH KEY BTYPE  = $BEVALLB-BTYPE
                                    ABEVAZ = $BEVALLB-ABEVAZ
                                    BINARY SEARCH.
   IF SY-SUBRC EQ 0.
* If calculated or the total or transfer field is filled then it is needed
     IF NOT LW_/ZAK/BEVALLB-COLLECT IS INITIAL OR
        NOT LW_/ZAK/BEVALLB-SUM_ABEVAZ IS INITIAL OR
        NOT LW_/ZAK/BEVALLB-GET_ABEVAZ IS INITIAL.
       CLEAR $SUBRC.
     ENDIF.
* If it has not been approved yet check whether it appears in the aggregated or calculated
* field
     IF NOT $SUBRC IS INITIAL.
       READ TABLE I_/ZAK/BEVALLB INTO LW_/ZAK/BEVALLB
                                WITH KEY BTYPE      = $BEVALLB-BTYPE
                                         SUM_ABEVAZ = $BEVALLB-ABEVAZ.
       IF SY-SUBRC EQ 0.
         CLEAR $SUBRC.
       ENDIF.

       IF NOT $SUBRC IS INITIAL.
         READ TABLE I_/ZAK/BEVALLB INTO LW_/ZAK/BEVALLB
                                  WITH KEY BTYPE      = $BEVALLB-BTYPE
                                           GET_ABEVAZ = $BEVALLB-ABEVAZ.
         IF SY-SUBRC EQ 0.
           CLEAR $SUBRC.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    " CHECK_COLL_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_BTART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BTART  text
*----------------------------------------------------------------------*
 FORM CHECK_BTART USING   $BTART.
*++BG 2012.01.17
*   IF $BTART NE C_BTYPART_SZJA.
   IF $BTART NE C_BTYPART_SZJA AND $BTART NE C_BTYPART_KULF
*++2108 #09.
      AND $BTART NE C_BTYPART_KATA
*--2108 #09.
*++2308 #09.
      AND $BTART NE C_BTYPART_TAO.
*--2308 #09.
*--BG 2012.01.17
     MESSAGE E177 WITH C_BTYPART_SZJA.
*   This program can only prepare & type returns!
   ENDIF.

 ENDFORM.                    " CHECK_BTART
*&---------------------------------------------------------------------*
*&      Form  APPEND_ABEVAZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_/ZAK/BEVALLBT  text
*      -->P_L_ADOAZON_SAVE_ABEV3  text
*      -->P_L_ADOAZON_SAVE_LAPSZ  text
*      -->P_L_ADOAZON_SAVE_ADOAZON  text
*----------------------------------------------------------------------*
 FORM APPEND_ABEVAZ TABLES   LI_/ZAK/BEVALLBT STRUCTURE /ZAK/BEVALLB
                    USING    L_ADOAZON_SAVE_ABEV3
                             L_ADOAZON_SAVE_LAPSZ
                             L_ADOAZON_SAVE_ADOAZON
                             $FIELD.

*++2308 #11.
   IF P_BTART EQ C_BTYPART_TAO.
     L_ADOAZON_SAVE_LAPSZ = '0001'.
   ENDIF.
*--2308 #11.

   LOOP AT LI_/ZAK/BEVALLBT INTO W_/ZAK/BEVALLB.
**          Check whether it needs to be created
*           PERFORM CHECK_COLL_DATA USING W_/ZAK/BEVALLB
*                                         L_SUBRC.
*    Ha minden rekordot fel kell dolgozni.
     IF $FIELD = 'ALL'.
       L_ADOAZON_SAVE_ABEV3 = W_/ZAK/BEVALLB-ABEVAZ(3).
     ENDIF.

     IF L_ADOAZON_SAVE_ABEV3 EQ W_/ZAK/BEVALLB-ABEVAZ(3).

       IF W_/ZAK/BEVALLB-ASZKOT = 'X'.
         CLEAR W_OUTTAB.
         MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
         W_OUTTAB-BUKRS  = P_BUKRS.
         W_OUTTAB-GJAHR  = S_GJAHR-LOW.
         W_OUTTAB-MONAT  = R_MONAT-HIGH.
         W_OUTTAB-ZINDEX = S_INDEX-HIGH.
         W_OUTTAB-WAERS  = C_HUF.
*        W_OUTTAB-LAPSZ  = C_LAPSZ.
         W_OUTTAB-LAPSZ  = L_ADOAZON_SAVE_LAPSZ.
         W_OUTTAB-ADOAZON = L_ADOAZON_SAVE_ADOAZON.
         W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
         W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

         SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
           FROM  /ZAK/BEVALLBT
                WHERE  LANGU   = SY-LANGU
                AND    BTYPE   = W_OUTTAB-BTYPE
                AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

         W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.

         IF NOT W_/ZAK/ANALITIKA-ADOAZON IS INITIAL.
           COLLECT W_OUTTAB INTO I_OUTTABS.
         ENDIF.

       ELSE.
         CLEAR W_OUTTAB.
         MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
         W_OUTTAB-BUKRS  = P_BUKRS.
         W_OUTTAB-GJAHR  = S_GJAHR-LOW.
         W_OUTTAB-MONAT  = R_MONAT-HIGH.
         W_OUTTAB-ZINDEX = S_INDEX-HIGH.
         W_OUTTAB-WAERS  = C_HUF.
*        W_OUTTAB-LAPSZ  = C_LAPSZ.
         W_OUTTAB-LAPSZ  = L_ADOAZON_SAVE_LAPSZ.
         W_OUTTAB-ADOAZON = SPACE.
         W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
         W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

         SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
           FROM  /ZAK/BEVALLBT
                WHERE  LANGU   = SY-LANGU
                AND    BTYPE   = W_OUTTAB-BTYPE
                AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

         W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.

         COLLECT W_OUTTAB INTO I_OUTTABS.
       ENDIF.
*++BG 2006/08/09
       DELETE LI_/ZAK/BEVALLBT.
*--BG 2006/08/09
     ENDIF.
*++BG 2006/08/09
*     DELETE LI_/ZAK/BEVALLBT.
*--BG 2006/08/09
   ENDLOOP.

 ENDFORM.                    " APPEND_ABEVAZ
*&---------------------------------------------------------------------*
*&      Form  are_u_sure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_ANSWER  text
*----------------------------------------------------------------------*
 FORM ARE_U_SURE CHANGING P_ANSWER.

   CLEAR P_ANSWER.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
*      TITLEBAR       = ' '
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION  = 'Menti a rögzített adatokat?'(900)
*      TEXT_BUTTON_1  = 'Ja'(001)
*      ICON_BUTTON_1  = ' '
*      TEXT_BUTTON_2  = 'Nein'(002)
*      ICON_BUTTON_2  = ' '
*      DEFAULT_BUTTON = '1'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
*      START_COLUMN   = 25
*      START_ROW      = 6
*      POPUP_TYPE     =
     IMPORTING
       ANSWER         = P_ANSWER
*  TABLES
*      PARAMETER      =
     EXCEPTIONS
       TEXT_NOT_FOUND = 1
       OTHERS         = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " are_u_sure
*&---------------------------------------------------------------------*
*&      Form  loss_of_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_ANSWER  text
*----------------------------------------------------------------------*
 FORM LOSS_OF_DATA CHANGING P_ANSWER.

   CLEAR P_ANSWER.
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*   CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
*     EXPORTING
*       TEXTLINE1           = 'Folytatja?'(901)
**   TEXTLINE2           = ' '
*       TITEL               = 'Confirmation'(902)
**   START_COLUMN        = 25
**   START_ROW           = 6
*       DEFAULTOPTION       = 'N'
*     IMPORTING
*       ANSWER              = P_ANSWER.
   DATA L_QUESTION TYPE STRING.

   CONCATENATE 'Adatok elvesznek!' 'Folytatja?'(901) INTO L_QUESTION SEPARATED BY SPACE.
*
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR              = 'Megerősítés'(902)
*      DIAGNOSE_OBJECT       = ' '
       TEXT_QUESTION         = L_QUESTION
*      TEXT_BUTTON_1         = 'Ja'(001)
*      ICON_BUTTON_1         = ' '
*      TEXT_BUTTON_2         = 'Nein'(002)
*      ICON_BUTTON_2         = ' '
       DEFAULT_BUTTON        = '2'
       DISPLAY_CANCEL_BUTTON = ' '
*      USERDEFINED_F1_HELP   = ' '
       START_COLUMN          = 25
       START_ROW             = 6
*      POPUP_TYPE            =
*      IV_QUICKINFO_BUTTON_1 = ' '
*      IV_QUICKINFO_BUTTON_2 = ' '
     IMPORTING
       ANSWER                = P_ANSWER
*   TABLES
*      PARAMETER             =
*   EXCEPTIONS
*      TEXT_NOT_FOUND        = 1
*      OTHERS                = 2
     .
   IF P_ANSWER EQ '1'.
     P_ANSWER = 'J'.
   ELSE.
     P_ANSWER = 'N'.
   ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

 ENDFORM.                    " loss_of_data
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE EXIT INPUT.
   SET SCREEN 0.
   LEAVE SCREEN.
 ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_ALK_MIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALKMIN  text
*      -->P_W_/ZAK/ANALITIKA  text
*      -->P_W_/ZAK/ANALITIKA_FIELD_C  text
*----------------------------------------------------------------------*
 FORM GET_ALK_MIN  TABLES   $I_ALKMIN      STRUCTURE  I_ALKMIN
                   USING    $/ZAK/ANALITIKA STRUCTURE  /ZAK/ANALITIKA
                            $VALUE.

   CLEAR $I_ALKMIN.

   MOVE $/ZAK/ANALITIKA-BSZNUM  TO $I_ALKMIN-BSZNUM.
   MOVE $/ZAK/ANALITIKA-ABEVAZ  TO $I_ALKMIN-ABEVAZ.
   MOVE $/ZAK/ANALITIKA-ADOAZON TO $I_ALKMIN-ADOAZON.
   MOVE $VALUE TO $I_ALKMIN-VALUE.
   MOVE $/ZAK/ANALITIKA-LAPSZ   TO $I_ALKMIN-LAPSZ.
   COLLECT $I_ALKMIN.

 ENDFORM.                    " GET_ALK_MIN
*&---------------------------------------------------------------------*
*&      Form  CALL_ALKMIN_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_ALKMIN_PROCESS .

*  Master data
   DATA: BEGIN OF LI_ALK OCCURS 0,
           ABEVAZ    TYPE /ZAK/ABEVAZ,
           ABEV_LOW  TYPE /ZAK/ABEVAZ,
           ABEV_HIGH TYPE /ZAK/ABEVAZ,
         END OF LI_ALK.

*  Postings by tax ID
   DATA: BEGIN OF LI_DATA OCCURS 0,
           BSZNUM  TYPE /ZAK/BSZNUM,
           ADOAZON TYPE /ZAK/ADOAZON,
         END OF LI_DATA.

*  Last application quality and sheet number per tax ID
   DATA: BEGIN OF LI_ADOAZON_LAST OCCURS 0,
           ADOAZON TYPE /ZAK/ADOAZON,
           ABEVAZ  TYPE /ZAK/ABEVAZ,
           VALUE   TYPE NUMC2,
           LAPSZ   TYPE /ZAK/LAPSZ,
         END OF LI_ADOAZON_LAST.

   RANGES LR_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.

   DATA L_TABIX LIKE SY-TABIX.

   DATA LW_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA.

   DATA L_ABEV_LOW TYPE /ZAK/ABEVAZ.

*  Determine the ABEV identifiers, if none then exit,
   LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB WHERE NOT ALKMIN IS INITIAL.
     CLEAR LI_ALK.
     MOVE W_/ZAK/BEVALLB-ABEVAZ TO LI_ALK-ABEVAZ.
     MOVE W_/ZAK/BEVALLB-ABEVAZ TO LI_ALK-ABEV_LOW.
*    CONCATENATE W_/ZAK/BEVALLB-ABEVAZ 'AA' INTO LI_ALK-ABEV_LOW.
     CONCATENATE W_/ZAK/BEVALLB-ABEVAZ(3) 'ZZZZZZZ' INTO LI_ALK-ABEV_HIGH.
     APPEND LI_ALK.
   ENDLOOP.

   SORT LI_ALK.

   CHECK NOT LI_ALK[] IS INITIAL.

   REFRESH LI_DATA.
*  Check whether there is data in the range
   LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
                            WHERE ( NOT FIELD_C IS INITIAL OR
                                    NOT FIELD_N IS INITIAL ) AND
*++0005 BG 2007.07.10
                                    ZINDEX EQ S_INDEX-HIGH.
*--0005 BG 2007.07.10

     LOOP AT LI_ALK.
*      Fill ranges for APPLICATION QUALITY:
       REFRESH LR_ABEVAZ.
       M_DEF LR_ABEVAZ 'I' 'BT' LI_ALK-ABEV_LOW LI_ALK-ABEV_HIGH.

       CHECK  W_/ZAK/ANALITIKA-ABEVAZ IN LR_ABEVAZ.

*      Collect data
       IF W_/ZAK/ANALITIKA-ABEVAZ EQ LI_ALK-ABEVAZ.
         PERFORM GET_ALK_MIN TABLES I_ALKMIN
                             USING  W_/ZAK/ANALITIKA
                                    W_/ZAK/ANALITIKA-FIELD_C.
       ENDIF.

       CLEAR LI_DATA.
       MOVE W_/ZAK/ANALITIKA-BSZNUM  TO LI_DATA-BSZNUM.
       MOVE W_/ZAK/ANALITIKA-ADOAZON TO LI_DATA-ADOAZON.
       COLLECT LI_DATA.

     ENDLOOP.

   ENDLOOP.


   SORT I_ALKMIN.
   DELETE ADJACENT DUPLICATES FROM I_ALKMIN.

*  Check whether the data is present
   IF NOT LI_DATA[] IS INITIAL.
     LOOP AT LI_DATA.
       READ TABLE I_ALKMIN WITH KEY BSZNUM  = LI_DATA-BSZNUM
                                    ADOAZON = LI_DATA-ADOAZON
                                    ABEVAZ  = LI_ALK-ABEVAZ
                                    BINARY SEARCH.
       IF SY-SUBRC NE 0.
         CLEAR I_ALKMIN.
         MOVE LI_DATA-BSZNUM  TO I_ALKMIN-BSZNUM.
         MOVE LI_DATA-ADOAZON TO I_ALKMIN-ADOAZON.
         MOVE LI_ALK-ABEVAZ   TO I_ALKMIN-ABEVAZ.
         APPEND I_ALKMIN. SORT I_ALKMIN.
       ENDIF.
     ENDLOOP.
   ENDIF.


*  Determine application quality and sheet number
   LOOP AT I_ALKMIN.
*  Determine the last one
     READ TABLE LI_ADOAZON_LAST WITH KEY ADOAZON = I_ALKMIN-ADOAZON
                                         ABEVAZ  = I_ALKMIN-ABEVAZ
                                         BINARY SEARCH.
     IF SY-SUBRC NE 0.
       CLEAR LI_ADOAZON_LAST.
       MOVE I_ALKMIN-ADOAZON TO LI_ADOAZON_LAST-ADOAZON.
       MOVE I_ALKMIN-ABEVAZ  TO LI_ADOAZON_LAST-ABEVAZ.
       IF I_ALKMIN-BSZNUM EQ '001'.
         MOVE I_ALKMIN-VALUE TO LI_ADOAZON_LAST-VALUE.
         MOVE I_ALKMIN-LAPSZ TO LI_ADOAZON_LAST-LAPSZ.
       ELSE.
         MOVE 1 TO LI_ADOAZON_LAST-VALUE.
         MOVE 1 TO LI_ADOAZON_LAST-LAPSZ.
       ENDIF.
       APPEND LI_ADOAZON_LAST. SORT LI_ADOAZON_LAST BY ADOAZON ABEVAZ.
     ELSE.
       MOVE SY-TABIX TO L_TABIX.
       ADD 1 TO LI_ADOAZON_LAST-VALUE.
       ADD 1 TO LI_ADOAZON_LAST-LAPSZ.
       MODIFY LI_ADOAZON_LAST INDEX L_TABIX
              TRANSPORTING VALUE LAPSZ.
     ENDIF.
     IF I_ALKMIN-BSZNUM NE '001'.
       I_ALKMIN-VALUE = LI_ADOAZON_LAST-VALUE.
       I_ALKMIN-LAPSZ = LI_ADOAZON_LAST-LAPSZ.
       MODIFY I_ALKMIN TRANSPORTING VALUE LAPSZ.
     ENDIF.
   ENDLOOP.

   SORT I_/ZAK/ANALITIKA BY BSZNUM ADOAZON ABEVAZ.

*++BG 2007.06.11
*  HR data service is not handled
   LOOP AT I_ALKMIN WHERE BSZNUM NE '001'.
*--BG 2007.06.11
*   Determine the ABEV of the application quality
     READ TABLE I_/ZAK/ANALITIKA INTO LW_/ZAK/ANALITIKA
               WITH KEY BSZNUM  = I_ALKMIN-BSZNUM
                        ADOAZON = I_ALKMIN-ADOAZON
                        ABEVAZ  = I_ALKMIN-ABEVAZ
                        BINARY SEARCH.
     IF SY-SUBRC EQ 0.
       MOVE SY-TABIX TO L_TABIX.
       MOVE I_ALKMIN-VALUE TO LW_/ZAK/ANALITIKA-FIELD_C.
       MODIFY I_/ZAK/ANALITIKA FROM LW_/ZAK/ANALITIKA INDEX L_TABIX
                              TRANSPORTING FIELD_C.
*++0003 BG 2007.05.09
*     ELSE.
     ELSEIF NOT I_ALKMIN-LAPSZ IS INITIAL.
*--0002 BG 2007.05.09
       READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA INDEX 1.
       CLEAR LW_/ZAK/ANALITIKA.
       MOVE W_/ZAK/ANALITIKA-MANDT TO LW_/ZAK/ANALITIKA-MANDT.
       MOVE W_/ZAK/ANALITIKA-BUKRS TO LW_/ZAK/ANALITIKA-BUKRS.
       MOVE W_/ZAK/ANALITIKA-BTYPE TO LW_/ZAK/ANALITIKA-BTYPE.
       MOVE W_/ZAK/ANALITIKA-GJAHR TO LW_/ZAK/ANALITIKA-GJAHR.
       MOVE W_/ZAK/ANALITIKA-MONAT TO LW_/ZAK/ANALITIKA-MONAT.
       MOVE W_/ZAK/ANALITIKA-ZINDEX TO LW_/ZAK/ANALITIKA-ZINDEX.
       MOVE I_ALKMIN-BSZNUM  TO LW_/ZAK/ANALITIKA-BSZNUM.
       MOVE I_ALKMIN-ABEVAZ  TO LW_/ZAK/ANALITIKA-ABEVAZ.
       MOVE I_ALKMIN-ADOAZON TO LW_/ZAK/ANALITIKA-ADOAZON.
       MOVE I_ALKMIN-LAPSZ   TO LW_/ZAK/ANALITIKA-LAPSZ.
       MOVE I_ALKMIN-VALUE   TO LW_/ZAK/ANALITIKA-FIELD_C.
       APPEND LW_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
       SORT I_/ZAK/ANALITIKA BY BSZNUM ADOAZON ABEVAZ.
     ENDIF.
   ENDLOOP.

*  Write back the sheet number and application quality
   LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
                            WHERE  ( NOT FIELD_C IS INITIAL OR
                                     NOT FIELD_N IS INITIAL )
*++BG 2007.06.11
*  HR data service is not overwritten because there may be
*  multiple dynamic sheet numbers within a data service
                              AND  BSZNUM NE '001'.
*++BG 2007.06.11

     LOOP AT LI_ALK.
       REFRESH LR_ABEVAZ.
       CONCATENATE LI_ALK-ABEV_LOW(4) '0000' INTO L_ABEV_LOW.
       M_DEF LR_ABEVAZ 'I' 'BT' L_ABEV_LOW LI_ALK-ABEV_HIGH.
       CHECK  W_/ZAK/ANALITIKA-ABEVAZ IN LR_ABEVAZ.
*      Determine the current application quality and sheet number
       READ TABLE I_ALKMIN WITH KEY BSZNUM  = W_/ZAK/ANALITIKA-BSZNUM
                                    ADOAZON = W_/ZAK/ANALITIKA-ADOAZON
                                    ABEVAZ  = LI_ALK-ABEVAZ
                                    BINARY SEARCH.
       IF SY-SUBRC EQ 0.
         MOVE I_ALKMIN-LAPSZ TO W_/ZAK/ANALITIKA-LAPSZ.
         MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA
                                TRANSPORTING LAPSZ FIELD_C.
       ENDIF.
     ENDLOOP.
   ENDLOOP.

   FREE: LI_ALK, LI_DATA, LI_ADOAZON_LAST, I_ALKMIN.

 ENDFORM.                    " CALL_ALKMIN_PROCESS
*&---------------------------------------------------------------------*
*&      Form  GET_WORK_DAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ESDAT  text
*----------------------------------------------------------------------*
 FORM GET_WORK_DAY  USING    $DATUM.

   DATA L_DATUM LIKE SY-DATUM.

   CALL FUNCTION 'BKK_GET_NEXT_WORKDAY'
     EXPORTING
       I_DATE         = $DATUM
       I_CALENDAR1    = C_CALID
*      I_CALENDAR2    =
     IMPORTING
       E_WORKDAY      = L_DATUM
     EXCEPTIONS
       CALENDAR_ERROR = 1
       OTHERS         = 2.
   IF SY-SUBRC <> 0.
     MESSAGE E226 WITH $DATUM.
*    Error when converting the due date to the next working day!(&)
   ENDIF.

   IF L_DATUM NE $DATUM.
     MOVE L_DATUM TO $DATUM.
     MESSAGE I225.
*   Due date converted to the next working day!
   ENDIF.

 ENDFORM.                    " GET_WORK_DAY

*&---------------------------------------------------------------------*
*&      Form  call_download_kulf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_DOWNLOAD_KULF CHANGING $FULLPATH
                                  $SUBRC.

   DATA: L_FILENAME TYPE STRING.

   L_FILENAME = $FULLPATH.

   CALL FUNCTION '/ZAK/KULF_FILE_DOWNLOAD'
     EXPORTING
       I_FILE            = L_FILENAME
       I_GJAHR           = S_GJAHR-LOW
       I_MONAT           = S_MONAT-LOW
     TABLES
       T_/ZAK/BEVALLALV = I_OUTTAB_C[]
     EXCEPTIONS
       ERROR_DOWNLOAD    = 1
       ERROR_IMP_PAR     = 2
       OTHERS            = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     MESSAGE E175(/zak/zak) with $fullpath.
     $SUBRC = 4.
   ELSE.
     $SUBRC = 0.
     MESSAGE I009(/ZAK/ZAK) WITH $FULLPATH.
   ENDIF.

 ENDFORM.                    " call_download_kulf
*++2108 #09.
*&---------------------------------------------------------------------*
*&      Form  call_download_kulf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_DOWNLOAD_KATA CHANGING $FULLPATH
                                  $SUBRC.

   DATA: L_FILENAME TYPE STRING.

   L_FILENAME = $FULLPATH.

   CALL FUNCTION '/ZAK/KATA_FILE_DOWNLOAD'
     EXPORTING
       I_FILE            = L_FILENAME
       I_GJAHR           = S_GJAHR-LOW
       I_MONAT           = S_MONAT-LOW
     TABLES
       T_/ZAK/BEVALLALV = I_OUTTAB_C[]
     EXCEPTIONS
       ERROR_DOWNLOAD    = 1
       ERROR_IMP_PAR     = 2
       OTHERS            = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     MESSAGE E175(/zak/zak) with $fullpath.
     $SUBRC = 4.
   ELSE.
     $SUBRC = 0.
     MESSAGE I009(/ZAK/ZAK) WITH $FULLPATH.
   ENDIF.

 ENDFORM.                    " call_download_kulf
*--2108 #09.
*++2308 #09.
*&---------------------------------------------------------------------*
*&      Form  CALL_DOWNLOAD_TAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_FULLPATH  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
 FORM CALL_DOWNLOAD_TAO  CHANGING $FULLPATH
                                  $SUBRC.

   DATA: L_FILENAME TYPE STRING.

   L_FILENAME = $FULLPATH.

   CALL FUNCTION '/ZAK/TAO_FILE_DOWNLOAD'
     EXPORTING
       I_FILE            = L_FILENAME
       I_GJAHR           = S_GJAHR-LOW
       I_MONAT           = S_MONAT-LOW
     TABLES
       T_/ZAK/BEVALLALV = I_OUTTAB_C[]
     EXCEPTIONS
       ERROR_DOWNLOAD    = 1
       ERROR_IMP_PAR     = 2
       OTHERS            = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     MESSAGE E175(/zak/zak) with $fullpath.
     $SUBRC = 4.
   ELSE.
     $SUBRC = 0.
     MESSAGE I009(/ZAK/ZAK) WITH $FULLPATH.
   ENDIF.

 ENDFORM.
*--2308 #09.
*++2508 #10.
*&---------------------------------------------------------------------*
*&      Form  CHECK_NAV_ELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_NAV_ELL USING $BUKRS
                          $BTART
                          $GJAHR
                          $MONAT.

   SELECT SINGLE COUNT( * )
            FROM /ZAK/NAV_ELL
           WHERE BUKRS   EQ $BUKRS
             AND BTYPART EQ $BTART
             AND GJAHR   EQ $GJAHR
             AND MONAT_FROM LE $MONAT
             AND MONAT_TO   GE $MONAT.
   IF SY-SUBRC EQ 0.
     MESSAGE I375(/ZAK/ZAK) DISPLAY LIKE 'W'.
*   There is currently a NAV audit in progress for the given period!
   ENDIF.

 ENDFORM.
*--2508 #10.
