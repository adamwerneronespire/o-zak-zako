*&---------------------------------------------------------------------*
*& Program: Áfa bevallás fõkönyv egyeztetõ lista
*----------------------------------------------------------------------*
 REPORT /ZAK/AFA_IDEGYEZTETO MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás:
*&---------------------------------------------------------------------*
*& Szerzõ            : Dénes Károly
*& Létrehozás dátuma : 2006.02.07
*& Funkc.spec.készítõ: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2007/01/31   Balázs G.     Szelekció optimalizálás
*& 0002   2007/10/15   Balázs G.     INDEX kitöltése:
*& 0003   2008/03/31   Balázs G.     Árfolyamkülönbözet tételek leválog.
*& 0004   2009/11/18   Faragó l.     Performancia
*& 0005   2010/01/22   Balázs G.     Adatok mentése, feld. mentett ad.
*&---------------------------------------------------------------------*

 INCLUDE /ZAK/AFA_TOP.
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
 CONSTANTS:
   C_RLDNR LIKE GLT0-RLDNR VALUE '00',
   C_RRCTY LIKE GLT0-RRCTY VALUE '0',
   C_RVERS LIKE GLT0-RVERS VALUE '001',
   C_KOART LIKE BSEG-KOART VALUE 'K',
   C_H     LIKE BSEG-SHKZG VALUE 'H',
   C_S     LIKE BSEG-SHKZG VALUE 'S'.

*++0002 BG 2007.11.21
 CONSTANTS: C_DUM_IND(3) VALUE 'DUM'.
*--0002 BG 2007.11.21

*++0003 BG 2008/03/31
*Árfolyam különbözet tételekhez
 CONSTANTS: C_BKPF_TCODE TYPE TCODE VALUE 'FB41'.
 CONSTANTS: C_BKPF_GRPID TYPE GRPID_BKPF VALUE 'AFA_ARF_KUL'.
*--0003 BG 2008/03/31

*&---------------------------------------------------------------------*
*& BELSÕ TÁBLÁK  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
 TYPES: BEGIN OF T_BSEG_V,
          GJAHR LIKE BSEG-GJAHR,
          HKONT LIKE BSEG-HKONT,
          BUKRS LIKE BSEG-BUKRS,
          BELNR LIKE BSEG-BELNR,
          BUZEI LIKE BSEG-BUZEI,
          KOART LIKE BSEG-KOART,
          SHKZG LIKE BSEG-SHKZG,
          DMBTR LIKE BSEG-DMBTR,
          MONAT LIKE BKPF-MONAT,
          BUPER LIKE /ZAK/BSET-BUPER,
        END OF T_BSEG_V.

*++0001 BG 2007/01/31
 TYPES: BEGIN OF T_BSIS_V,
          GJAHR   LIKE BSIS-GJAHR,
          HKONT   LIKE BSIS-HKONT,
          BUKRS   LIKE BSIS-BUKRS,
          BELNR   LIKE BSIS-BELNR,
          BUZEI   LIKE BSIS-BUZEI,
          SHKZG   LIKE BSIS-SHKZG,
          DMBTR   LIKE BSIS-DMBTR,
          MONAT   LIKE BSIS-MONAT,
          BUPER   LIKE /ZAK/BSET-BUPER,
*++0002 BG 2007.11.21
          MWSKZ   LIKE BSIS-MWSKZ,
          ZINDEX  LIKE /ZAK/BSET-ZINDEX,
*--0002 BG 2007.11.21
*++1665 #07.
          BUDAT   TYPE BUDAT,
          BLDAT   TYPE BLDAT,
          CPUDT   TYPE CPUDT,
          VATDATE TYPE VATDATE,
          XBLNR   TYPE XBLNR,
          USNAME  TYPE UNAME,
*--1665 #07.
*++1765 #23.
          DMBE2   TYPE DMBE2,
          HWAE2   TYPE HWAE2,
*--1765 #23.
*++2465 #04.
          LWSTE   TYPE LWSTE_BSET,
          CWAER   TYPE WAERS,
*--2465 #04.
        END OF T_BSIS_V.
*--0001 BG 2007/01/31

 TYPES: BEGIN OF T_BSIS_A.
          INCLUDE TYPE T_BSIS_V.
          TYPES: BKTXT TYPE BKTXT,
        END OF T_BSIS_A.


 DATA: W_BSEG_V TYPE T_BSEG_V.

 DATA: I_BSEG_V TYPE T_BSEG_V OCCURS 0. "INITIAL SIZE 0.

*++0001 BG 2007/01/31
 DATA  W_BSIS_V TYPE T_BSIS_V.

 DATA  I_BSIS_V TYPE T_BSIS_V OCCURS 0.
*--0001 BG 2007/01/31

*++0003 BG 2008/03/31
 DATA  W_BSIS_A TYPE T_BSIS_A.
 DATA  I_BSIS_A TYPE T_BSIS_A OCCURS 0.
*--0003 BG 2008/03/31
*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
*      Belsõ tábla         -   (I_xxx...)                              *
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


 DATA: V_COUNTER TYPE I.

* ALV kezelési változók
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

       V_PRINT             TYPE LVC_S_PRNT,

       V_TOOLBAR           TYPE STB_BUTTON,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER.
* vállalat
 DATA: F_BUTXT    LIKE T001-BUTXT,
       V_MON_HIGH LIKE BKPF-MONAT,
       V_DAT_LOW  LIKE /ZAK/BSET-BUPER,
       V_DAT_HIGH LIKE /ZAK/BSET-BUPER.

*
 DATA: L_NUM(2) TYPE N.

 DATA: V_LAST_DATE TYPE DATUM.
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
*++0005 2010.01.22 BG
*SELECT-OPTIONS: S_HKONT FOR BSEG-HKONT              OBLIGATORY.
 SELECT-OPTIONS: S_HKONT FOR BSEG-HKONT.
*--0005 2010.01.22 BG

* periódus
 SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-T03.
 PARAMETERS:     P_GJAHR LIKE BKPF-GJAHR.
 SELECT-OPTIONS: S_MONAT FOR BKPF-MONAT NO-EXTENSION DEFAULT '01'.
 PARAMETERS:     P_PERI RADIOBUTTON GROUP R01 USER-COMMAND PERI
                                                     DEFAULT 'X',
* idõs/zak/zak
                 P_IDO  RADIOBUTTON GROUP R01.
 SELECT-OPTIONS: S_DATUM FOR /ZAK/BSET-BUPER NO-EXTENSION.
 SELECTION-SCREEN: END OF BLOCK BL03.
 SELECTION-SCREEN: END OF BLOCK BL01.

*++0005 2010.01.22 BG
 SELECTION-SCREEN: BEGIN OF BLOCK BL04 WITH FRAME TITLE TEXT-T02.
 PARAMETERS P_LOAD AS CHECKBOX.
 SELECTION-SCREEN: END OF BLOCK BL04.

 SELECTION-SCREEN: BEGIN OF BLOCK BL05 WITH FRAME TITLE TEXT-T03.
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(79) TEXT-104.
 SELECTION-SCREEN END OF LINE.
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(79) TEXT-105.
 SELECTION-SCREEN END OF LINE.
 PARAMETERS P_SAVE AS CHECKBOX.
 SELECTION-SCREEN: END OF BLOCK BL05.
*--0005 2010.01.22 BG

 RANGES: R_MONAT FOR S_MONAT-LOW,
         R_BUPER FOR /ZAK/BSET-BUPER.

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
**
*     CLEAR V_TOOLBAR.
*     MOVE '/ZAK/ZAK_MAN' TO V_TOOLBAR-FUNCTION.
*     MOVE ICON_CREATE TO V_TOOLBAR-ICON.
*     MOVE 'Lista'(TO3) TO V_TOOLBAR-QUICKINFO.
*     MOVE 'Lista'(TO4) TO V_TOOLBAR-TEXT.
*     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
*     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
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
* § 3.In event handler method for event USER_COMMAND: Query your
*   function codes defined in step 2 and react accordingly.

     DATA: I_ROWS TYPE LVC_T_ROW,
           W_ROWS TYPE LVC_S_ROW,
           S_OUT  TYPE /ZAK/EGYEZTETALV.

     CASE E_UCOMM.
* Tételek megjelenítése!
       WHEN 'BSEG'.
         CALL SCREEN 9001.
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
*++1765 #19.
* Jogosultság vizsgálat
   AUTHORITY-CHECK OBJECT 'S_TCODE'
*                  ID 'TCD'  FIELD SY-TCODE.
                   ID 'TCD'  FIELD '/ZAK/IDEGYEZTETO'.
*++1865 #03.
*  IF SY-SUBRC NE 0.
   IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
     MESSAGE E152(/ZAK/ZAK).
*   Önnek nincs jogosultsága a program futtatásához!
   ENDIF.
*--1765 #19.
************************************************************************
* AT SELECTION-SCREEN output
************************************************************************
 AT SELECTION-SCREEN OUTPUT.
   PERFORM MODIF_SCREEN.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
   SET PARAMETER ID 'BUK' FIELD P_BUKRS.
   PERFORM FIELD_DESCRIPT.
   PERFORM CHECK_MONAT.
*++0005 2010.01.22 BG
   PERFORM CHECK_HKONT.
*--0005 2010.01.22 BG

 AT SELECTION-SCREEN ON BLOCK BL03.
   PERFORM VER_BLOCK_BL03 USING P_PERI
                                P_IDO.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.

   V_REPID = SY-REPID.

*  Jogosultság vizsgálat
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 C_BTYPART_AFA
                                 C_ACTVT_01.

*++0005 2010.01.22 BG
   IF P_LOAD IS INITIAL.
*--0005 2010.01.22 BG

     PERFORM SET_RANGES .
* szelekció
*++0001 BG 2007/01/31
*  PERFORM SEL_BKPF_BSEG.
     PERFORM SEL_BSIS_BSET.
*  ALV listához tábla feltöltése!
*   PERFORM FILL_OUTTAB USING I_OUTTAB_I[]
*                             I_BSEG_V[]
*                             I_BKPF[]
*                             I_/ZAK/BSET[].
*++1765 #23.
     PERFORM FILL_OTHER_FIELDS USING  P_BUKRS
                                      I_BSIS_V[].
*--1765 #23.

     PERFORM FILL_OUTTAB_NEW USING I_OUTTAB_I[]
                                   I_BSIS_V[]
                                   I_/ZAK/BSET[]
*++0003 BG 2008/03/31
                                   I_BSIS_A[]
*--0003 BG 2008/03/31
                                   .
*--0001 BG 2007/01/31

*++1765 #23.
**++1665 #07.
*     PERFORM FILL_OTHER_FIELDS USING  P_BUKRS
*                                      I_BSIS_V[].
**--1665 #07.
*--1765 #23.

*++0005 2010.01.22 BG
*    Adatok mentése
     PERFORM SAVE_DATA USING I_OUTTAB_I[]
                             I_BSIS_V[]
                             P_BUKRS
                             P_SAVE.
   ELSE.
*    Adatok beolvasása
     PERFORM LOAD_DATA USING I_OUTTAB_I[]
                             I_BSIS_V[]
                             P_BUKRS .

     IF I_OUTTAB_I[] IS INITIAL.
       MESSAGE I289 WITH '&'.
*      Nem áll rendelkezésre menetett adat & vállalatra!
       EXIT.
     ENDIF.
   ENDIF.
*--0005 2010.01.22 BG
*++1665 #11.
   PERFORM FILL_LOG USING  P_BUKRS
                           I_OUTTAB_I[].
*--1665 #11.


************************************************************************
* ALPROGRAMOK
************************************************************************
 END-OF-SELECTION.
   PERFORM ALV_LIST.

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
     SELECT SINGLE *  FROM T001
           WHERE BUKRS = P_BUKRS.
     P_BUTXT = T001-BUTXT.
   ENDIF.

 ENDFORM.                    " field_descript
*****************************
*&---------------------------------------------------------------------*
*&      Form  ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ALV_LIST.
*++0005 2010.01.22 BG
   CHECK SY-BATCH IS INITIAL.
*--0005 2010.01.22 BG
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
   DATA: L_NAME(20) TYPE C,
         W_RETURN   LIKE BAPIRET2.
   IF V_CUSTOM_CONTAINER IS INITIAL.
* az adatszerkezet SAP-os struktúrája a /ZAK/BEVALLD-strname táblából
* kell venni
     PERFORM CREATE_AND_INIT_ALV CHANGING I_OUTTAB_I[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT
                                          V_PRINT.
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
     WHEN '/ZAK/HIBA'.
       SET PF-STATUS 'MAIN9001' .
       SET TITLEBAR 'MAIN9001'.
       CALL SCREEN 9001.
* Vissza
     WHEN 'BACK'.
       SET SCREEN 0.
       LEAVE SCREEN.
* Kilépés
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
         WA_TAB TYPE TAB_TYPE.
* analitika struktúra megjelenítés
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
*      <--P_I_OUTTAB_i[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV CHANGING  PT_OUTTAB LIKE I_OUTTAB_I[]
                                    PT_FIELDCAT TYPE LVC_T_FCAT
                                    PS_LAYOUT   TYPE LVC_S_LAYO
                                    PS_VARIANT  TYPE DISVARIANT
                                    PS_PRINT    TYPE LVC_S_PRNT.

   DATA: I_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER
     EXPORTING
       CONTAINER_NAME = V_CONTAINER.
   CREATE OBJECT V_GRID
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER.

* Mezõkatalógus összeállítása
   PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                          CHANGING PT_FIELDCAT.

   PS_LAYOUT-CWIDTH_OPT = 'X'.
   PS_LAYOUT-SEL_MODE = 'A'.

   CLEAR PS_VARIANT.
   PS_VARIANT-REPORT = V_REPID.

   CLEAR PS_PRINT.
   PS_PRINT-RESERVELNS = 3.
   PS_PRINT-PRNTSELINF = 'X'.

   CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT      = PS_VARIANT
       IS_PRINT        = PS_PRINT
       I_SAVE          = 'A'
       I_DEFAULT       = 'X'
       IS_LAYOUT       = PS_LAYOUT
*      IT_TOOLBAR_EXCLUDING = I_EXCLUDE
     CHANGING
       IT_FIELDCATALOG = PT_FIELDCAT
       IT_OUTTAB       = PT_OUTTAB.

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

* /ZAK/ANALITIKA tábla
   IF P_DYNNR = '9000'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/EGYEZTALV_I'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.


   ELSE.
* tétel tábla
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/IDTETEL_ALV'
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
     PERFORM CREATE_AND_INIT_ALV2 CHANGING I_ITEM_I[]
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
 FORM CREATE_AND_INIT_ALV2 CHANGING  PT_ITEM  LIKE I_ITEM_I[]
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

* Mezõkatalógus összeállítása
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING PT_FIELDCAT.

* Funkciók kizárása
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

*++0002 BG 2007.10.15
   RANGES LR_BELNR FOR /ZAK/BSET-BELNR.
*--0002 BG 2007.10.15

   IF SY-DYNNR EQ '9000' AND
      NOT E_ROW IS INITIAL.
     SET PF-STATUS 'MAIN9001' .
     SET TITLEBAR 'MAIN9001'.
* a kijelölt sorhoz tartozó bizonylatok megjelenítése
     READ TABLE I_OUTTAB_I INTO W_OUTTAB_I INDEX E_ROW.
     IF SY-SUBRC EQ 0.
*++0001 BG 2007/01/31
** bizonylat tábla feltöltése
*       SORT I_BSEG_V BY HKONT GJAHR MONAT BUPER.
*       REFRESH I_ITEM_I.
*       LOOP AT I_BSEG_V INTO W_BSEG_V
*               WHERE GJAHR EQ W_OUTTAB_I-GJAHR AND
*                     MONAT EQ W_OUTTAB_I-MONAT AND
*                     BUPER EQ W_OUTTAB_I-BUPER.
** elõjel
**         IF W_BSEG_V-SHKZG EQ C_H .
**           W_BSEG_V-DMBTR = W_BSEG_V-DMBTR * -1 .
**         ENDIF.
*
**     KOART EQ C_KOART .
*         MOVE-CORRESPONDING W_BSEG_V TO W_ITEM_I.
*         W_ITEM_I-WAERS = T001-WAERS.
**         READ TABLE I_BKPF INTO W_BKPF
**              WITH KEY BUKRS = P_BUKRS
**                       BELNR = W_BSEG_V-BELNR
**                       GJAHR = W_BSEG_V-GJAHR.
**         READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
**                             WITH KEY BUKRS = W_BSEG_V-BUKRS
**                                      BELNR = W_BSEG_V-BELNR
**                                      GJAHR = W_BSEG_V-GJAHR.
**         IF SY-SUBRC EQ 0.
**           W_ITEM-BUPER = W_/ZAK/BSET-BUPER.
**         ENDIF.
*         APPEND W_ITEM_I TO I_ITEM_I.
*         CLEAR W_ITEM_I.
*       ENDLOOP.
*++0002 BG 2007.10.15
*       REFRESH LR_BELNR.
*       LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET
*                                    WHERE BUPER  EQ W_OUTTAB_I-BUPER
*                                      AND ZINDEX EQ W_OUTTAB_I-ZINDEX.
*         M_DEF LR_BELNR 'I' 'EQ' W_/ZAK/BSET-BELNR SPACE.
*       ENDLOOP.
*--0002 BG 2007.10.15


       SORT I_BSIS_V BY HKONT GJAHR MONAT BUPER.
       REFRESH I_ITEM_I.
       LOOP AT I_BSIS_V INTO W_BSIS_V
               WHERE GJAHR EQ W_OUTTAB_I-GJAHR AND
                     MONAT EQ W_OUTTAB_I-MONAT AND
                     BUPER EQ W_OUTTAB_I-BUPER
*++0002 BG 2007.10.15
*                AND BELNR IN LR_BELNR
                 AND ZINDEX EQ W_OUTTAB_I-ZINDEX.
*--0002 BG 2007.10.15

         MOVE-CORRESPONDING W_BSIS_V TO W_ITEM_I.
*++0002 BG 2007.10.24
         MOVE W_OUTTAB_I-ZINDEX TO W_ITEM_I-ZINDEX.
*--0002 BG 2007.10.24
         W_ITEM_I-WAERS = T001-WAERS.
         APPEND W_ITEM_I TO I_ITEM_I.
         CLEAR W_ITEM_I.
       ENDLOOP.
*--0001 BG 2007/01/31
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

   READ TABLE I_ITEM_I INTO W_ITEM_I INDEX E_ROW_ID.
   IF SY-SUBRC = 0.

     CASE E_COLUMN_ID.
       WHEN 'GJAHR' OR
            'BELNR' OR
            'BUZEI'.

         IF NOT W_ITEM_I-GJAHR IS INITIAL AND
            NOT W_ITEM_I-BELNR IS INITIAL AND
            NOT W_ITEM_I-BUZEI IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD P_BUKRS.
           SET PARAMETER ID 'GJR' FIELD W_ITEM_I-GJAHR.
           SET PARAMETER ID 'BLN' FIELD W_ITEM_I-BELNR.

           CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
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
     IF NOT P_IDO IS INITIAL.
       IF SCREEN-NAME = 'S_DATUM-LOW' OR
          SCREEN-NAME = 'S_DATUM-HIGH'.
         SCREEN-INPUT = 1.
         SCREEN-OUTPUT = 1.
       ELSEIF SCREEN-NAME = 'S_MONAT-LOW' OR
              SCREEN-NAME = 'S_MONAT-HIGH' OR
              SCREEN-NAME = 'P_GJAHR'.
         SCREEN-INPUT = 0.
         SCREEN-OUTPUT = 1.
       ENDIF.
     ELSE.
       IF SCREEN-NAME = 'S_DATUM-LOW' OR
          SCREEN-NAME = 'S_DATUM-HIGH'.
         SCREEN-INPUT = 0.
         SCREEN-OUTPUT = 1.
       ELSEIF SCREEN-NAME = 'S_MONAT-LOW' OR
              SCREEN-NAME = 'S_MONAT-HIGH' OR
              SCREEN-NAME = 'P_GJAHR'.
         SCREEN-INPUT = 1.
         SCREEN-OUTPUT = 1.
       ENDIF.
     ENDIF.
     IF SCREEN-GROUP1 = 'OUT'.
       SCREEN-INPUT = 0.
       SCREEN-OUTPUT = 1.
       SCREEN-DISPLAY_3D = 0.
     ENDIF.
     MODIFY SCREEN.
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
   IF NOT P_PERI IS INITIAL.
     IF NOT S_MONAT-LOW BETWEEN '01' AND '16' AND P_LOAD IS INITIAL.
       MESSAGE E020.
*   Kérem a periódus értékét 01-16 között adja meg!
     ENDIF.
     IF S_MONAT-HIGH > 16 AND P_LOAD IS INITIAL.
       MESSAGE E020.
     ENDIF.
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

   CONCATENATE P_GJAHR S_MONAT-LOW INTO R_BUPER-LOW.
   IF NOT S_MONAT-HIGH IS INITIAL.
     CONCATENATE P_GJAHR S_MONAT-HIGH INTO R_BUPER-HIGH.
   ENDIF.
   R_BUPER-SIGN   = S_MONAT-SIGN.
   R_BUPER-OPTION = S_MONAT-OPTION.
   APPEND R_BUPER.

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
   IF NOT P_IDO IS INITIAL.
* idõs/zak/zak szerinti keresés
     SELECT * INTO TABLE I_/ZAK/BSET FROM /ZAK/BSET
               WHERE BUKRS EQ P_BUKRS AND
                     BUPER IN S_DATUM.
     IF NOT I_/ZAK/BSET IS INITIAL .
       SELECT * INTO TABLE I_BKPF FROM BKPF
                FOR ALL ENTRIES IN I_/ZAK/BSET
                WHERE BUKRS EQ I_/ZAK/BSET-BUKRS AND
                      BELNR EQ I_/ZAK/BSET-BELNR AND
                      GJAHR EQ I_/ZAK/BSET-GJAHR.

       IF NOT I_BKPF[] IS INITIAL.
* Bizonylatszegmens: könyvelés
         SELECT
                GJAHR
                HKONT
                BUKRS
                BELNR
                BUZEI
                KOART
                SHKZG
                DMBTR
                INTO TABLE I_BSEG_V FROM BSEG
                FOR ALL ENTRIES IN I_BKPF
                WHERE BUKRS EQ I_BKPF-BUKRS AND
                      BELNR EQ I_BKPF-BELNR AND
                      GJAHR EQ I_BKPF-GJAHR AND
                      HKONT IN S_HKONT.            "#EC CI_DB_OPERATION_OK[2431747]
       ENDIF.
     ENDIF.
   ELSE.
* periódus szerinti keresés
     SELECT * INTO TABLE I_BKPF FROM BKPF
              WHERE BUKRS EQ P_BUKRS AND
                    GJAHR EQ P_GJAHR AND
                    MONAT IN S_MONAT.
     IF NOT I_BKPF[] IS INITIAL.
* Bizonylatszegmens: könyvelés
       SELECT
              GJAHR
              HKONT
              BUKRS
              BELNR
              BUZEI
              KOART
              SHKZG
              DMBTR
              INTO TABLE I_BSEG_V FROM BSEG
              FOR ALL ENTRIES IN I_BKPF
              WHERE BUKRS EQ I_BKPF-BUKRS AND
                    BELNR EQ I_BKPF-BELNR AND
                    GJAHR EQ I_BKPF-GJAHR AND
                    HKONT IN S_HKONT.               "#EC CI_DB_OPERATION_OK[2431747]
*Bizonylatszegmens: adóadatok 2
       IF NOT I_BSEG_V IS INITIAL .
         SELECT * INTO TABLE I_/ZAK/BSET FROM /ZAK/BSET
                   FOR ALL ENTRIES IN I_BSEG_V
                   WHERE BUKRS EQ I_BSEG_V-BUKRS AND
                         BELNR EQ I_BSEG_V-BELNR AND
                         GJAHR EQ I_BSEG_V-GJAHR.
*                       BUZEI EQ I_BSEG_V-BUZEI.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " SEL_BKPF_BSEG
*&---------------------------------------------------------------------*
*&      Form  FILL_OUTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB_i[]  text
*      -->P_I_BSEG_V[]  text
*      -->P_I_BKPF[]  text
*      -->P_I_/ZAK/BSET[]  text
*----------------------------------------------------------------------*
 FORM FILL_OUTTAB USING   $OUTTAB LIKE I_OUTTAB_I[]
                          $BSEG_V LIKE I_BSEG_V[]
                          $BKPF   LIKE I_BKPF[]
                          $BSET   LIKE I_/ZAK/BSET[].

   DATA: L_HKONT     LIKE BSEG-HKONT,
         L_UPDATE(1) TYPE C,
         L_TABIX     LIKE SY-TABIX.

   SORT $BSEG_V BY HKONT.
   SORT $BKPF BY GJAHR MONAT BELNR.
   LOOP AT $BKPF INTO W_BKPF.
     MOVE-CORRESPONDING W_BKPF TO W_OUTTAB_I.
     LOOP AT $BSEG_V INTO W_BSEG_V WHERE BUKRS EQ W_BKPF-BUKRS AND
                                         BELNR EQ W_BKPF-BELNR AND
                                         GJAHR EQ W_BKPF-GJAHR.
       L_TABIX = SY-TABIX.
* elõjel
       IF W_BSEG_V-SHKZG EQ C_H .
         W_BSEG_V-DMBTR = W_BSEG_V-DMBTR * -1 .
       ENDIF.
       READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
                             WITH KEY BUKRS = W_BSEG_V-BUKRS
                                      BELNR = W_BSEG_V-BELNR
                                      GJAHR = W_BSEG_V-GJAHR.
       IF SY-SUBRC EQ 0.
         W_OUTTAB_I-BUPER = W_/ZAK/BSET-BUPER.
         W_BSEG_V-BUPER = W_/ZAK/BSET-BUPER.
       ELSE.
         CLEAR W_OUTTAB_I-BUPER.
       ENDIF.
* normál
       W_OUTTAB_I-DMBTR = W_BSEG_V-DMBTR.
       W_OUTTAB_I-WAERS = T001-WAERS.
*         W_OUTTAB-HKONT      = W_BSEG_V-HKONT.
       COLLECT W_OUTTAB_I INTO $OUTTAB.
* bseg idõs/zak/zak - periódus összerendelés
       W_BSEG_V-MONAT = W_BKPF-MONAT.
       MODIFY $BSEG_V FROM W_BSEG_V INDEX L_TABIX.
     ENDLOOP.
     CLEAR: L_UPDATE, W_OUTTAB_I.
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
   IF V_MON_HIGH IS INITIAL.
     V_MON_HIGH = S_MONAT-LOW.
   ENDIF.

   V_DAT_LOW  = S_DATUM-LOW.
   V_DAT_HIGH = S_DATUM-HIGH.
   IF V_DAT_HIGH IS INITIAL.
     V_DAT_HIGH = V_DAT_LOW.
   ENDIF.

   IF P_IDO = 'X'.
     LOOP AT SCREEN.
       IF SCREEN-NAME = 'BKPF-GJAHR' OR
          SCREEN-NAME = 'BKPF-MONAT' OR
          SCREEN-NAME = 'V_MON_HIGH' OR
          SCREEN-NAME = '1'.
         SCREEN-INVISIBLE = 1.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ELSE.
     LOOP AT SCREEN.
       IF SCREEN-NAME = 'V_DAT_LOW' OR
          SCREEN-NAME = 'V_DAT_HIGH' OR
          SCREEN-NAME = '2'.
         SCREEN-INVISIBLE = 1.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " SET9000_FIELDS
*&---------------------------------------------------------------------*
*&      Form  VER_BLOCK_Bl03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PERI  text
*      -->P_P_IDO  text
*----------------------------------------------------------------------*
 FORM VER_BLOCK_BL03 USING    $PERI
                              $IDO.
*   IF NOT $PERI IS INITIAL AND
*      P_GJAHR IS INITIAL AND
*      S_MONAT IS INITIAL.
*     MESSAGE E116.
*   ENDIF.

*   IF NOT $IDO IS INITIAL AND
*          S_DATUM IS INITIAL.
*     MESSAGE E117.
*   ENDIF.
   IF NOT $PERI IS INITIAL.
     CLEAR: S_DATUM-LOW,S_DATUM-HIGH.
   ELSE.
     CLEAR: P_GJAHR,S_MONAT-LOW,S_MONAT-HIGH.
*     REFRESH:S_MONAT.
   ENDIF.
 ENDFORM.                    " VER_BLOCK_Bl03
*&---------------------------------------------------------------------*
*&      Form  SEL_BSIS_BSET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SEL_BSIS_BSET.
*++0003 BG 2008/03/31
   DATA: BEGIN OF LW_BSIS_BKPF.
           INCLUDE TYPE T_BSIS_A.
           DATA: TCODE TYPE TCODE,
           GRPID TYPE GRPID_BKPF,
         END OF LW_BSIS_BKPF.
*V004+
*   DEFINE LM_SEL_ARF.
*     SELECT &1~GJAHR
*            &1~HKONT
*            &1~BELNR
*            &1~BUZEI
*            &1~SHKZG
*            &1~DMBTR
*            &1~MONAT
*            &1~MWSKZ
*            BKPF~BKTXT
*            BKPF~TCODE
*            BKPF~GRPID
*            INTO CORRESPONDING FIELDS OF LW_BSIS_BKPF
*            FROM &1 INNER JOIN BKPF
*                   ON BKPF~BUKRS = &1~BUKRS
*                  AND BKPF~BELNR = &1~BELNR
*                  AND BKPF~GJAHR = &1~GJAHR
*            WHERE &1~BUKRS =  P_BUKRS
*              AND &1~HKONT IN S_HKONT.
*       IF LW_BSIS_BKPF-TCODE EQ C_BKPF_TCODE AND
*          LW_BSIS_BKPF-GRPID EQ C_BKPF_GRPID.
*         CLEAR W_BSIS_A.
*         MOVE-CORRESPONDING LW_BSIS_BKPF TO W_BSIS_A.
*         APPEND W_BSIS_A TO I_BSIS_A.
*       ENDIF.
*     ENDSELECT.
*   END-OF-DEFINITION.

*(nem volt jó - így is a BSIS-tól indult, HINTS-et sem vette figyelembe)
   DEFINE LM_SEL_ARF.
     SELECT BKPF~GJAHR
            &1~HKONT
            BKPF~BELNR
            &1~BUZEI
            &1~SHKZG
            &1~DMBTR
            BKPF~MONAT
            &1~MWSKZ
            BKPF~BKTXT

            APPENDING CORRESPONDING FIELDS OF TABLE I_BSIS_A
            FROM BKPF
            JOIN &1  ON  &1~BUKRS = BKPF~BUKRS
                     AND &1~BELNR = BKPF~BELNR
                     AND &1~GJAHR = BKPF~GJAHR
            WHERE BKPF~BUKRS =  P_BUKRS
              AND TCODE = C_BKPF_TCODE
              AND GRPID EQ C_BKPF_GRPID
              AND &1~HKONT IN S_HKONT
            %_HINTS ORACLE 'LEADING(BKPF)' ORACLE 'FULL(BKPF)'
                .
   END-OF-DEFINITION.
*V004-
*--0003 BG 2008/03/31

   IF NOT P_IDO IS INITIAL.
* idõs/zak/zak szerinti keresés
     SELECT * INTO TABLE I_/ZAK/BSET FROM /ZAK/BSET
               WHERE BUKRS EQ P_BUKRS AND
                     BUPER IN S_DATUM.
     IF NOT I_/ZAK/BSET IS INITIAL .
*      Bizonylatszegmens: könyvelés
       SELECT * INTO CORRESPONDING FIELDS OF TABLE I_BSIS_V
                FROM BSIS
                 FOR ALL ENTRIES IN I_/ZAK/BSET
               WHERE BUKRS EQ I_/ZAK/BSET-BUKRS
                 AND BELNR EQ I_/ZAK/BSET-BELNR
                 AND GJAHR EQ I_/ZAK/BSET-GJAHR
                 AND HKONT IN S_HKONT.
*++BG 2007.04.19
*++BG 2007.07.02
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE I_BSIS_V
       SELECT * APPENDING CORRESPONDING FIELDS OF TABLE I_BSIS_V
*--BG 2007.07.02
                FROM BSAS
                 FOR ALL ENTRIES IN I_/ZAK/BSET
               WHERE BUKRS EQ I_/ZAK/BSET-BUKRS
                 AND BELNR EQ I_/ZAK/BSET-BELNR
                 AND GJAHR EQ I_/ZAK/BSET-GJAHR
                 AND HKONT IN S_HKONT.
       SORT I_BSIS_V.
       DELETE ADJACENT DUPLICATES FROM I_BSIS_V.
*--BG 2007.04.19
     ENDIF.
   ELSE.
* periódus szerinti keresés
     SELECT * INTO CORRESPONDING FIELDS OF TABLE I_BSIS_V
              FROM BSIS
             WHERE BUKRS EQ P_BUKRS
               AND GJAHR EQ P_GJAHR
               AND MONAT IN S_MONAT
               AND HKONT IN S_HKONT.
*++BG 2007.04.19
*++BG 2007.07.02
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE I_BSIS_V
     SELECT * APPENDING CORRESPONDING FIELDS OF TABLE I_BSIS_V
*--BG 2007.07.02
              FROM BSAS
             WHERE BUKRS EQ P_BUKRS
               AND GJAHR EQ P_GJAHR
               AND MONAT IN S_MONAT
               AND HKONT IN S_HKONT.
     SORT I_BSIS_V.
     DELETE ADJACENT DUPLICATES FROM I_BSIS_V.
*--BG 2007.04.19
     IF NOT   I_BSIS_V IS INITIAL.
       SELECT * INTO TABLE I_/ZAK/BSET FROM /ZAK/BSET
                 FOR ALL ENTRIES IN I_BSIS_V
                 WHERE BUKRS EQ I_BSIS_V-BUKRS AND
                       BELNR EQ I_BSIS_V-BELNR AND
                       GJAHR EQ I_BSIS_V-GJAHR.
     ENDIF.
   ENDIF.


*++2565 #05.
**++0003 BG 2008/03/31
**  Árfolyam különbözet tételek leválogatása
**V004+
**   LM_SEL_ARF BSIS.
**   LM_SEL_ARF BSAS.
*   DATA: BEGIN OF LT_BKPF7 OCCURS 0
*       ,   BUKRS TYPE BKPF-BUKRS
*       ,   BELNR TYPE BKPF-BELNR
*       ,   GJAHR TYPE BKPF-GJAHR
*       ,   BKTXT TYPE BKPF-BKTXT
*       , END OF LT_BKPF7
*       .
*   SELECT BUKRS BELNR GJAHR BKTXT
*     INTO TABLE LT_BKPF7 FROM BKPF
*    WHERE TCODE = C_BKPF_TCODE
*      AND GRPID = C_BKPF_GRPID
**     AND BUKRS = P_BUKRS
*        .
*   DELETE LT_BKPF7 WHERE BUKRS <> P_BUKRS.
*   SORT LT_BKPF7 BY BELNR GJAHR.
*
*   LOOP AT LT_BKPF7.
*     W_BSIS_A-BELNR = LT_BKPF7-BELNR.
*     W_BSIS_A-GJAHR = LT_BKPF7-GJAHR.
*     W_BSIS_A-BKTXT = LT_BKPF7-BKTXT.
*     SELECT BUZEI HKONT SHKZG DMBTR MWSKZ
*       FROM BSIS INTO CORRESPONDING FIELDS OF W_BSIS_A
*      WHERE BUKRS = P_BUKRS
*        AND BELNR = LT_BKPF7-BELNR AND GJAHR = LT_BKPF7-GJAHR
*        AND HKONT IN S_HKONT.
*       APPEND W_BSIS_A TO I_BSIS_A.
*     ENDSELECT.
*     IF SY-SUBRC <> 0.
*       SELECT BUZEI HKONT SHKZG DMBTR MONAT MWSKZ
*         FROM BSIS INTO CORRESPONDING FIELDS OF W_BSIS_A
*        WHERE BUKRS = P_BUKRS
*          AND BELNR = LT_BKPF7-BELNR AND GJAHR = LT_BKPF7-GJAHR
*          AND HKONT IN S_HKONT.
*         APPEND W_BSIS_A TO I_BSIS_A.
*       ENDSELECT.
*     ENDIF.
*   ENDLOOP.
*   FREE LT_BKPF7.
**V004-
*
**V004+
**   SORT I_BSIS_A.
**   DELETE ADJACENT DUPLICATES FROM I_BSIS_A.
*   SORT I_BSIS_A BY BKTXT GJAHR BELNR BUZEI.
*   DELETE ADJACENT DUPLICATES FROM I_BSIS_A
*     COMPARING BKTXT GJAHR BELNR BUZEI.
**V004-
*
**--0003 BG 2008/03/31
*--2565 #02.


 ENDFORM.                    " SEL_BSIS_BSET
*&---------------------------------------------------------------------*
*&      Form  FILL_OUTTAB_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB_I[]  text
*      -->P_I_BSIS_V[]  text
*      -->P_I_/ZAK/BSET[]  text
*----------------------------------------------------------------------*
 FORM FILL_OUTTAB_NEW USING    $OUTTAB LIKE I_OUTTAB_I[]
                               $BSIS_V LIKE I_BSIS_V[]
                               $BSET   LIKE I_/ZAK/BSET[]
*++0003 BG 2008/03/31
                               $BSIS_A LIKE I_BSIS_A[]
*--0003 BG 2008/03/31
                               .


   DATA: L_HKONT     LIKE BSIS-HKONT,
         L_UPDATE(1) TYPE C,
         L_TABIX     LIKE SY-TABIX.
*++0003 BG 2008/03/31
   DATA  L_BKTXT TYPE BKTXT.
   DATA  LI_BSIS_V TYPE T_BSIS_V OCCURS 0.

*--0003 BG 2008/03/31

*++0002 BG 2007.11.21
   DATA LI_/ZAK/AFA_CUST LIKE /ZAK/AFA_CUST OCCURS 0 WITH HEADER LINE.
   DATA L_FOUND.
   DATA L_GJAHR TYPE GJAHR.
   DATA L_MONAT TYPE MONAT.
   DATA L_BTYPE TYPE /ZAK/BTYPE.
*++2465 #04.
   DATA L_CWAER TYPE WAERS.
*--2465 #04.

   DEFINE LM_GET_MWSKZ.
     CLEAR &2.
     L_GJAHR = &1-BUPER(4).
     L_MONAT = &1-BUPER+4(2).
*    Meghatározzuk a típust
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = &1-BUKRS
         I_BTYPART   = C_BTYPART_AFA
         I_GJAHR     = L_GJAHR
         I_MONAT     = L_MONAT
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

     READ TABLE LI_/ZAK/AFA_CUST
           WITH KEY  BTYPE = L_BTYPE
                     MWSKZ = &3
                     BINARY SEARCH.
     IF SY-SUBRC EQ 0.
       MOVE 'X' TO &2.
     ENDIF.
   END-OF-DEFINITION.

*  Beolvassuk az ÁFA cust táblát.
   SELECT * INTO TABLE LI_/ZAK/AFA_CUST                  "#EC CI_NOWHERE
            FROM /ZAK/AFA_CUST.
   SORT LI_/ZAK/AFA_CUST.
*--0002 BG 2007.11.21

*++2465 #04.
   SELECT SINGLE WAERS INTO L_CWAER
                       FROM T005
                      WHERE LAND1 EQ T001-LAND1.
*--2465 #04.

   SORT $BSIS_V BY GJAHR MONAT BELNR HKONT.

   LOOP AT $BSIS_V INTO W_BSIS_V.

     CLEAR W_OUTTAB_I.
*++2465 #04.
     SELECT SINGLE LWSTE INTO W_BSIS_V-LWSTE
                         FROM BSET
                        WHERE BUKRS EQ W_BSIS_V-BUKRS
                          AND GJAHR EQ W_BSIS_V-GJAHR
                          AND BELNR EQ W_BSIS_V-BELNR
*++2565 #05.
*                          AND MWSKZ EQ W_BSIS_V-MWSKZ.
                          AND MWSKZ EQ W_BSIS_V-MWSKZ
                          AND HKONT EQ W_BSIS_V-HKONT.
*--2565 #05.
     IF SY-SUBRC EQ 0.
       W_BSIS_V-CWAER = L_CWAER.
     ENDIF.
*--2465 #04.
*    elõjel
     IF W_BSIS_V-SHKZG EQ C_H .
       W_BSIS_V-DMBTR = W_BSIS_V-DMBTR * -1 .
*++1765 #23.
       W_BSIS_V-DMBE2 = W_BSIS_V-DMBE2 * -1 .
*--1765 #23.
*++2465 #04.
       W_BSIS_V-LWSTE = W_BSIS_V-LWSTE * -1.
*--2465 #04.
     ENDIF.
     MOVE-CORRESPONDING W_BSIS_V TO W_OUTTAB_I.

     READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
                           WITH KEY BUKRS = W_BSIS_V-BUKRS
                                    BELNR = W_BSIS_V-BELNR
                                    GJAHR = W_BSIS_V-GJAHR.
     IF SY-SUBRC EQ 0.
*++0002 BG 2007.11.21
       LM_GET_MWSKZ W_/ZAK/BSET L_FOUND W_BSIS_V-MWSKZ.
*      Benne van az ÁFA kód a beállító táblában
       IF NOT L_FOUND IS INITIAL.
*        Megkeressük a nem DUM-os indexet
         LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET
                           WHERE BUKRS = W_BSIS_V-BUKRS
                             AND BELNR = W_BSIS_V-BELNR
                             AND GJAHR = W_BSIS_V-GJAHR
                             AND ZINDEX NE C_DUM_IND.
           EXIT.
         ENDLOOP.
         W_OUTTAB_I-BUPER  = W_/ZAK/BSET-BUPER.
         W_OUTTAB_I-ZINDEX = W_/ZAK/BSET-ZINDEX.
*      Nincs benne az áfa kód a beállító táblában
       ELSE.
         W_OUTTAB_I-ZINDEX = C_DUM_IND.
         W_OUTTAB_I-BUPER  = W_/ZAK/BSET-BUPER.
       ENDIF.
     ELSE.
       CLEAR W_OUTTAB_I-BUPER.
     ENDIF.

     W_BSIS_V-BUPER  = W_OUTTAB_I-BUPER.
     W_BSIS_V-ZINDEX = W_OUTTAB_I-ZINDEX.
*--0002 BG 2007.11.21
     W_OUTTAB_I-WAERS = T001-WAERS.
     COLLECT W_OUTTAB_I INTO $OUTTAB.

     MODIFY $BSIS_V FROM W_BSIS_V.

*++0003 BG 2008/03/31
*    Árfolyam különbözet tételek szelektálása
     CONCATENATE W_BSIS_V-BELNR W_BSIS_V-BUKRS W_BSIS_V-GJAHR
                 INTO L_BKTXT SEPARATED BY '/'.

*V004+
*    LOOP AT $BSIS_A INTO W_BSIS_A WHERE BKTXT EQ L_BKTXT.
     READ TABLE $BSIS_A TRANSPORTING NO FIELDS
       WITH KEY BKTXT = L_BKTXT BINARY SEARCH.
     CHECK SY-SUBRC = 0.
     LOOP AT $BSIS_A INTO W_BSIS_A FROM SY-TABIX.
       IF W_BSIS_A-BKTXT <> L_BKTXT. EXIT. ENDIF.
*V004-
*    elõjel
       IF W_BSIS_A-SHKZG EQ C_H .
         W_BSIS_A-DMBTR = W_BSIS_A-DMBTR * -1 .
*++1765 #23.
         W_BSIS_A-DMBE2 = W_BSIS_A-DMBE2 * -1 .
*--1765 #23.
       ENDIF.
       MOVE-CORRESPONDING W_BSIS_A TO W_OUTTAB_I.
       W_OUTTAB_I-BUPER  = W_BSIS_V-BUPER.
       W_OUTTAB_I-ZINDEX = W_BSIS_V-ZINDEX.
       COLLECT W_OUTTAB_I INTO $OUTTAB.
       MOVE-CORRESPONDING W_BSIS_A TO W_BSIS_V.
       W_BSIS_V-BUPER  = W_OUTTAB_I-BUPER.
       W_BSIS_V-ZINDEX = W_OUTTAB_I-ZINDEX.
       CLEAR W_BSIS_V-MWSKZ.
       APPEND W_BSIS_V TO LI_BSIS_V.
       DELETE $BSIS_A.
     ENDLOOP.
*--0003 BG 2008/03/31
   ENDLOOP.

*++0003 BG 2008/03/31
   IF NOT LI_BSIS_V[] IS INITIAL.
     APPEND LINES OF LI_BSIS_V TO $BSIS_V.
     SORT $BSIS_V BY GJAHR MONAT BELNR HKONT.
   ENDIF.
*--0003 BG 2008/03/31

 ENDFORM.                    " FILL_OUTTAB_NE
*&---------------------------------------------------------------------*
*&      Form  CHECK_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_HKONT .

   IF P_LOAD IS INITIAL AND S_HKONT[] IS INITIAL.
     MESSAGE E288.
*   Kérem adjon meg fõkönyvi számlát a szelekción!
   ENDIF.

 ENDFORM.                    " CHECK_HKONT
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB_I[]  text
*      -->P_I_BSIS_V[]  text
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
 FORM SAVE_DATA  USING    $OUTTAB LIKE I_OUTTAB_I[]
                          $BSIS_V LIKE I_BSIS_V[]
                          $BUKRS
                          $SAVE.

   DATA LI_EGYEZT_SAVE  LIKE /ZAK/EGYEZT_SAVE OCCURS 0 WITH HEADER LINE.
   DATA LI_EGYBSIS_SAVE LIKE /ZAK/EGYBSISSAVE OCCURS 0 WITH HEADER LINE.

   CHECK NOT $SAVE IS INITIAL.

*  Adatok törlése
   DELETE FROM /ZAK/EGYEZT_SAVE WHERE BUKRS EQ $BUKRS.

*  Adatok mentése
   LOOP AT $OUTTAB INTO W_OUTTAB_I.
     CLEAR LI_EGYEZT_SAVE.
     MOVE-CORRESPONDING W_OUTTAB_I TO LI_EGYEZT_SAVE.
     MOVE $BUKRS TO LI_EGYEZT_SAVE-BUKRS.
     MOVE SY-TABIX TO LI_EGYEZT_SAVE-ITEM.
     APPEND LI_EGYEZT_SAVE.
   ENDLOOP.

   MODIFY /ZAK/EGYEZT_SAVE FROM TABLE LI_EGYEZT_SAVE.

   DELETE FROM /ZAK/EGYBSISSAVE WHERE BUKRS EQ $BUKRS.

   LOOP AT $BSIS_V INTO W_BSIS_V.
     CLEAR LI_EGYBSIS_SAVE.
     MOVE-CORRESPONDING W_BSIS_V TO LI_EGYBSIS_SAVE.
     APPEND LI_EGYBSIS_SAVE.
   ENDLOOP.

   MODIFY /ZAK/EGYBSISSAVE FROM TABLE LI_EGYBSIS_SAVE .

   COMMIT WORK.

 ENDFORM.                    " SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  LOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB_I[]  text
*      -->P_I_BSIS_V[]  text
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
 FORM LOAD_DATA  USING     $OUTTAB LIKE I_OUTTAB_I[]
                           $BSIS_V LIKE I_BSIS_V[]
                           $BUKRS.

   DATA LI_EGYEZT_SAVE  LIKE /ZAK/EGYEZT_SAVE OCCURS 0 WITH HEADER LINE.
   DATA LI_EGYBSIS_SAVE LIKE /ZAK/EGYBSISSAVE OCCURS 0 WITH HEADER LINE.

   SELECT * INTO TABLE LI_EGYEZT_SAVE
            FROM /ZAK/EGYEZT_SAVE
           WHERE BUKRS EQ $BUKRS.

   LOOP AT LI_EGYEZT_SAVE.
     CLEAR W_OUTTAB_I.
     MOVE-CORRESPONDING LI_EGYEZT_SAVE TO W_OUTTAB_I.
     APPEND W_OUTTAB_I TO $OUTTAB.
   ENDLOOP.

   IF NOT LI_EGYEZT_SAVE[] IS INITIAL.
     SELECT * INTO TABLE LI_EGYBSIS_SAVE
              FROM /ZAK/EGYBSISSAVE
             WHERE BUKRS EQ $BUKRS.
     LOOP AT LI_EGYBSIS_SAVE.
       CLEAR W_BSIS_V.
       MOVE-CORRESPONDING LI_EGYBSIS_SAVE TO W_BSIS_V.
       APPEND W_BSIS_V TO $BSIS_V.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " LOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  FILL_OTHER_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BSIS_V[]  text
*----------------------------------------------------------------------*
 FORM FILL_OTHER_FIELDS  USING    $BUKRS
                                  $BSIS_V LIKE I_BSIS_V[].


*  BKPF kiegészítés
   LOOP AT $BSIS_V INTO W_BSIS_V.
     SELECT SINGLE BUDAT
                   BLDAT
                   CPUDT
                   VATDATE
                   XBLNR
                   USNAM
*++1765 #23.
                   HWAE2
*--1765 #23.
                          INTO (W_BSIS_V-BUDAT,
                                W_BSIS_V-BLDAT,
                                W_BSIS_V-CPUDT,
                                W_BSIS_V-VATDATE,
                                W_BSIS_V-XBLNR,
                                W_BSIS_V-USNAME,
*++1765 #23.
                                W_BSIS_V-HWAE2)
*--1765 #23.
              FROM BKPF
             WHERE BUKRS EQ $BUKRS
               AND BELNR EQ W_BSIS_V-BELNR
               AND GJAHR EQ W_BSIS_V-GJAHR.
     IF SY-SUBRC EQ 0.
       MODIFY $BSIS_V FROM W_BSIS_V.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " FILL_OTHER_FIELDS
*&---------------------------------------------------------------------*
*&      Form  FILL_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_OUTTAB_I[]  text
*----------------------------------------------------------------------*
 FORM FILL_LOG  USING   $BUKRS
                        $I_OUTTAB_I LIKE I_OUTTAB_I[].

   DATA LI_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI.
   DATA LW_BEVALLI TYPE /ZAK/BEVALLI.
   DATA LW_OUTTAB_I TYPE /ZAK/EGYEZTALV_I.
   DATA L_BTYPE TYPE /ZAK/BTYPE.


   LOOP AT $I_OUTTAB_I INTO LW_OUTTAB_I.
     CLEAR LW_BEVALLI.
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = $BUKRS
         I_BTYPART   = C_BTYPART_AFA
         I_GJAHR     = LW_OUTTAB_I-BUPER(4)
         I_MONAT     = LW_OUTTAB_I-BUPER+4(2)
       IMPORTING
         E_BTYPE     = L_BTYPE
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
     IF SY-SUBRC EQ 0.
       READ TABLE LI_BEVALLI INTO LW_BEVALLI
                         WITH KEY  BUKRS = $BUKRS
                                   BTYPE = L_BTYPE
                                   GJAHR = LW_OUTTAB_I-BUPER(4)
                                   MONAT = LW_OUTTAB_I-BUPER+4(2)
                                   ZINDEX = LW_OUTTAB_I-ZINDEX.
       IF SY-SUBRC NE 0.
         SELECT SINGLE * INTO  LW_BEVALLI
                  FROM  /ZAK/BEVALLI
                  WHERE  BUKRS = $BUKRS AND
                         BTYPE = L_BTYPE AND
                         GJAHR = LW_OUTTAB_I-BUPER(4) AND
                         MONAT = LW_OUTTAB_I-BUPER+4(2) AND
                         ZINDEX = LW_OUTTAB_I-ZINDEX.
         APPEND LW_BEVALLI TO LI_BEVALLI.
         SORT LI_BEVALLI.
       ENDIF.
       LW_OUTTAB_I-FLAG = LW_BEVALLI-FLAG.
       MODIFY $I_OUTTAB_I FROM LW_OUTTAB_I TRANSPORTING FLAG.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " FILL_LOG
