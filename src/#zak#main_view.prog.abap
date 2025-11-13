*&---------------------------------------------------------------------*
*& Program: Data file creation, display, manual recording program
*&---------------------------------------------------------------------*
 REPORT /ZAK/MAIN_VIEW MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Data file creator, display, manual recorder
*& program
*&---------------------------------------------------------------------*
*& Author : Tímea Cserhegyi - fmc
*& Creation date: 05.01.2006
*& Func.spec.maker: ________
*& SAP module name    : ADO
*& Program type: Report
*& SAP version : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (The number of the OSS note must be written at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER      DESCRIPTION                 TRANSPORT
*& ----   ----------   ----------    -----------------------     -----------
*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES    xxxxxxxxxx
*&                                   replaced with the classic version
*& 0002   2007.01.03   Balázs G.     CL_GUI_FRONTEND_SERVICES restored
*& 0003   2007.01.31   Balázs G.     Due date population
*& 0004   2007.04.04   Balázs G.     Summary report update for ONYB
*& 0005   2007.05.30   Balázs G.     Handling VAT 04 and 06 sheets
*& 0006   2007.07.02   Balázs G.     VAT base validation
*& 0007   2007.07.23   Balázs G.     Due date calculation based on the
*&                                   production calendar
*& 0008   2007.08.06   Balázs G.     VAT amount verification
*& 0009   2007.12.17   Balázs G.     VAT proportionality handling
*& 0010   2008.02.14   Balázs G.     Warning if another return type
*&                                   exists in the period
*& 0011   2008.03.28   Balázs G.     Determining proportional values for
*&                                   detail rows
*& 0012   2008.04.02   Balázs G.     Extending the summary report for
*&                                   ONYB (vendors, customers)
*& 0013   2008.09.01   Balázs G.     Fix previous-period collection for
*&                                   annual proportionality
*& 0014   2008.09.08   Balázs G.     Adjust previous-period ABEV
*&                                   proportionality and posting logic
*& 0015   2009.02.02   Balázs G.     Incorporate VAT 0965 changes
*& 0016   2011.09.14   Balázs G.     Group company handling
*& 0017   2012.02.07   Balázs G.     Manual entry allowed for other periods
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE /ZAK/MAIN_TOP.
* INCLUDE /ZAK/MAIN_TOP.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.
*&---------------------------------------------------------------------*
*& TABLES *
*&---------------------------------------------------------------------*
 TABLES: /ZAK/ANALITIKA_S,
         CSKS,
         AUFK.
*++0017 BG 2012.02.07
 TABLES: /ZAK/ANAL_MS.
*--0017 BG 2012.02.07
*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
 CONSTANTS: C_CLOSED_Z(1) TYPE C VALUE 'Z',
            C_CLOSED_X(1) TYPE C VALUE 'X',
            C_NUM         TYPE C VALUE 'N',
            C_CHAR        TYPE C VALUE 'C'.
*++0015 0965 2009.02.02 BG
 CONSTANTS: C_0865  TYPE /ZAK/BTYPE VALUE '0865'.
 CONSTANTS: C_0965  TYPE /ZAK/BTYPE VALUE '0965'.
*--0015 0965 2009.02.02 BG
*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES *
*      Internal table - (I_xxx...) *
*      FORM parameter - ($xxxx...) *
*      Constant            -   (C_xxx...)                              *
*      Parameter variable - (P_xxx...) *
*      Selection option - (S_xxx...) *
*      Series (Range) - (R_xxx...) *
*      Global variables - (V_xxx...) *
*      Local variables - (L_xxx...) *
*      Work area - (W_xxx...) *
*      Type - (T_xxx...) *
*      Macros - (M_xxx...) *
*      Field-symbol        -   (FS_xxx...)                             *
*      Method              -   (METH_xxx...)                           *
*      Object              -   (O_xxx...)                              *
*      Class - (CL_xxx...) *
*      Event - (E_xxx...) *
*&---------------------------------------------------------------------*
* Normal
 DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB TYPE /ZAK/BEVALLALV.
* Employee data
 DATA: I_OUTTAB_D TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB_D TYPE /ZAK/BEVALLALV.
 DATA: I_OUTTAB_L TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB_L TYPE /ZAK/BEVALLALV.
* Tax identifiers
 DATA: BEGIN OF I_ADOAZON OCCURS 0,
         ADOAZON TYPE /ZAK/ADOAZON,
       END OF I_ADOAZON.
* Converted
 DATA: I_OUTTAB_C TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
       W_OUTTAB_C TYPE /ZAK/BEVALLALV.
 DATA: BEGIN OF I_OUTTAB2 OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
 DATA:   CELLTAB TYPE LVC_T_STYL.
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
*++0004 BG 2007.04.04
 DATA  V_LAPSZ TYPE I.
*--0004 BG 2007.04.04
*++0005 BG 2007.05.30
 DATA  V_NYLAPAZON TYPE /ZAK/NYLAPAZON.
*--0005 BG 2007.05.30
* ALV treatment variables
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
*++0004 BG 2007.04.26
*MACRO definition for range upload
 DEFINE M_DEF.
   MOVE: &2      TO &1-sign,
         &3      TO &1-option,
         &4      TO &1-low,
         &5      TO &1-high.
   COLLECT &1.
 END-OF-DEFINITION.
*--0004 BG 2007.04.26
*++0008 BG 2007.08.06
 DATA V_ERROR.
*--0008 BG 2007.08.06
*++0009 BG 2007.12.17
 DATA W_/ZAK/BNYLAP LIKE /ZAK/BNYLAP.
*--0009 BG 2007.12.17
*++0012 BG 2008.04.02
 TYPES: BEGIN OF T_NYLAPAZON,
          NYLAPAZON TYPE /ZAK/NYLAPAZON,
          LAPSZ     TYPE I,
        END OF T_NYLAPAZON.
 DATA I_NYLAPAZON TYPE STANDARD TABLE OF T_NYLAPAZON INITIAL SIZE 0.
 DATA W_NYLAPAZON TYPE T_NYLAPAZON.
*--0012 BG 2008.04.02
*++0016 BG 2011.09.14
 DATA V_BUKCS TYPE XFELD. "Group company relevant flag
 DATA: I_BUKRS TYPE STANDARD TABLE OF /ZAK/AFACS_BUKRS INITIAL SIZE 0
                                                      WITH HEADER LINE.
 RANGES R_BUKRS FOR /ZAK/AFACS_BUKRS-BUKRS.
*--0016 BG 2011.09.14
*++1365 22.01.2013 Balázs Gábor (Ness)
*++1365 #21.
* DATA i_afa_szla_sum TYPE STANDARD TABLE OF /zak/afa_szlasum .
 DATA I_AFA_SZLA_SUM TYPE SORTED TABLE OF /ZAK/AFA_SZLASUM
                     WITH NON-UNIQUE KEY BUKRS ADOAZON SZAMLASZA
                                         SZAMLASZ SZAMLASZE NYLAPAZON.
*--1365 #21.
 DATA W_AFA_SZLA_SUM TYPE /ZAK/AFA_SZLASUM.
*--1365 22.01.2013 Balázs Gábor (Ness)
*++2065 #06.
 DATA V_VIEW TYPE XFELD.
*--2065 #06.
*++2165 #10.
 DATA W_/ZAK/START TYPE /ZAK/START.
*--2165 #10.
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
*++0004 BG 2007.04.04
     PARAMETERS: P_BTART LIKE /ZAK/BEVALL-BTYPART OBLIGATORY.
*PARAMETERS: P_BTART TYPE /ZAK/BTYPART OBLIGATORY VALUE CHECK.
*--0004 BG 2007.04.04
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_BTTEXT(40) TYPE C MODIF ID DIS.
   SELECTION-SCREEN END OF LINE.
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-102 FOR FIELD P_BTYPE.
     PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLSZ-BTYPE NO-DISPLAY.
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
   SELECTION-SCREEN END OF LINE.
*++1365 #21.
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-104 FOR FIELD P_OMREL.
     PARAMETERS: P_OMREL LIKE /ZAK/BEVALL-OMREL DEFAULT 'X'.
   SELECTION-SCREEN END OF LINE.
*--1365 #21.
*++1765 #07.
   PARAMETERS P_MIGR TYPE XFELD NO-DISPLAY.
*--1765 #07.
   PARAMETERS: P_N(1) TYPE C NO-DISPLAY,
               P_O(1) TYPE C NO-DISPLAY,
               P_M(1) TYPE C NO-DISPLAY.
   SELECT-OPTIONS: S_GJAHR FOR /ZAK/BEVALLSZ-GJAHR  NO-DISPLAY.
   SELECT-OPTIONS: S_MONAT FOR /ZAK/BEVALLSZ-MONAT  NO-DISPLAY.
   SELECT-OPTIONS: S_INDEX FOR /ZAK/BEVALLSZ-ZINDEX NO-DISPLAY.
 SELECTION-SCREEN: END OF BLOCK BL01.
* SUBSCREEN 1
 SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
   SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
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
     SELECT-OPTIONS: S_GJAHR2 FOR /ZAK/BEVALLSZ-GJAHR  NO INTERVALS
                          NO-EXTENSION,
                     S_MONAT2 FOR /ZAK/BEVALLSZ-MONAT  NO INTERVALS
                          NO-EXTENSION,
                     S_INDEX2 FOR /ZAK/BEVALLSZ-ZINDEX NO INTERVALS
                          NO-EXTENSION.
*++0003 BG 2007.01.31
     PARAMETERS: P_ESDAT LIKE SY-DATUM.
*--0003 BG 2007.01.31
   SELECTION-SCREEN END OF BLOCK B2.
   PARAMETERS: P_CUM AS CHECKBOX.
 SELECTION-SCREEN END OF SCREEN 200.
* SUBSCREEN 3
 SELECTION-SCREEN BEGIN OF SCREEN 300 AS SUBSCREEN.
   SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME.
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
 INCLUDE /ZAK/MAIN_VIEW_LOCAL_CLASS.
* INCLUDE /ZAK/MAIN_VIEW_LOCAL_CLASS.

*++2365 #03.
 DATA: V_OK_9901           LIKE SY-UCOMM.
*Special period management
 SELECTION-SCREEN BEGIN OF SCREEN 0101 AS SUBSCREEN.
   SELECTION-SCREEN BEGIN OF BLOCK BL101 WITH FRAME.
     SELECT-OPTIONS S_SPECM FOR R_MONAT-LOW OBLIGATORY NO-EXTENSION
                                            MODIF ID DIS.
   SELECTION-SCREEN: END   OF BLOCK BL101.
 SELECTION-SCREEN END OF SCREEN 0101.
*--2365 #03.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.
   BUTTON1 = TEXT-010.
   BUTTON2 = TEXT-020.
   BUTTON3 = TEXT-030.
   MYTAB-PROG = SY-REPID.
   MYTAB-DYNNR = 100.
   MYTAB-ACTIVETAB = 'BUTTON1'.
   P_N = C_X.
   CLEAR: P_O, P_M.
   GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*++0004 BG 2007.04.04
*  GET PARAMETER ID '/ZAK/ZBTY'  FIELD P_BTART.
   GET PARAMETER ID '/ZAK/ZBTR'  FIELD P_BTART.
*--0004 BG 2007.04.04
   V_REPID = SY-REPID.
   PERFORM READ_ADDITIONALS.
*++2012.01.06 BG
*  We will upload the date of administration
   P_ESDAT = SY-DATUM.
*--2012.01.06 BG
*++1765 #19.
* Eligibility check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2165 #03.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/MAIN_VIEW'.
*--2165 #03.
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
*++0004 BG 2007.04.04
*  SET PARAMETER ID '/ZAK/ZBTY' FIELD P_BTART.
   SET PARAMETER ID '/ZAK/ZBTR' FIELD P_BTART.
*--0004 BG 2007.04.04
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
*++2565 #04.
*   PERFORM CHECK_SEL_SCREEN.
**  PERFORM CHECK_DATA USING 'S'.
**++1865 #11.
** AT SELECTION-SCREEN ON P_BTART.
**--1865 #11.
*   PERFORM CHECK_BTART USING P_BTART.
**++1865 #11.
** AT SELECTION-SCREEN ON BLOCK B1.
**--1865 #11.
*   PERFORM CHECK_DATA USING 'S'.
 AT SELECTION-SCREEN ON P_BTART.
   PERFORM CHECK_BTART USING P_BTART.

 AT SELECTION-SCREEN ON BLOCK B1.
   PERFORM CONV_INDEX CHANGING S_INDEX1-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX2-LOW.
   PERFORM CONV_INDEX CHANGING S_INDEX3-LOW.
   PERFORM CHECK_SEL_SCREEN.
   PERFORM CHECK_DATA USING 'S'.
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
*--2565 #04.
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
* Normal, self-revision, display: Upload S_ selections
   PERFORM FILL_S_RANGES.
   CHECK NOT S_GJAHR IS INITIAL AND
         NOT S_MONAT IS INITIAL AND
         NOT S_INDEX IS INITIAL.
* Definition of declaration type
   PERFORM GET_BTYPE USING P_BUKRS
                           P_BTART
                           S_GJAHR-LOW
                           S_MONAT-LOW
                     CHANGING P_BTYPE.
* Determination of the last day of declaration
   PERFORM GET_LAST_DAY_OF_PERIOD USING S_GJAHR-LOW
                                        S_MONAT-LOW
*++PTGSZLAA #01. 2014.03.03
*++PTGSZLAH #01. 2015.01.16
*                                        P_BTART
                                        P_BTYPE
*--PTGSZLAH #01. 2015.01.16
*--PTGSZLAA #01. 2014.03.03
                                   CHANGING V_LAST_DATE.
*++0016 BG 2011.09.14
*  Group company definition
   PERFORM GET_CS_BUKRS TABLES I_BUKRS
                               R_BUKRS
                         USING P_BUKRS
                               V_BUKCS
                               P_BTYPE
                               V_LAST_DATE.
*--0016 BG 2011.09.14
*  Eligibility check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTART
                                 C_ACTVT_01.
* Lock setting
   PERFORM ENQUEUE_PERIOD.
* General declaration data
   PERFORM READ_BEVALL  USING P_BUKRS
                              P_BTART
                              P_BTYPE
                              V_LAST_DATE.
*  Reading the data structure of the declaration
   PERFORM READ_BEVALLB USING P_BUKRS
                              P_BTYPE.
* Process indicator
   DO.
     PERFORM PROCESS_IND USING TEXT-P01.
     IF V_I = 1.
       EXIT.
     ENDIF.
*  Analytics
     PERFORM READ_ANALITIKA.
     V_I = V_I + 1.
   ENDDO.
*++0015 0965 2009.02.02 BG
* VAT is not required from 0965 as it has been converted to 0865,
* and then the display will always be its own type.
   V_DISP_BTYPE = P_BTYPE.
** Popup: if there is another BYTPE
*   PERFORM POPUP_BTYPE_SEL CHANGING V_DISP_BTYPE.
*   IF V_DISP_BTYPE <> P_BTYPE.
*     PERFORM BTYPE_CONVERSION TABLES I_OUTTAB
*                              USING  P_BUKRS
*                                     P_BTYPE
*                                     V_DISP_BTYPE.
*   ENDIF.
*--0015 0965 2009.02.02 BG
*++0009 BG 2007.12.17
   IF P_BTART EQ C_BTYPART_AFA.
     PERFORM AFA_ARANY.
   ENDIF.
*--0009 BG 2007.12.17
*  Calculation of sum rows
   IF P_M <> C_X.
     PERFORM CALL_EXIT.
   ENDIF.
*++0008 BG 2007.08.06
   IF P_BTART EQ C_BTYPART_AFA.
*    Call for verification
     PERFORM CHECK_AFA USING    SPACE    "AUTO generation
                       CHANGING V_ERROR.
     IF V_ERROR IS INITIAL.
       MESSAGE I229.
*    VAT amounts are consistent!
     ENDIF.
   ENDIF.
*--0008 BG 2007.08.06
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
 END-OF-SELECTION.
* Process indicator
   PERFORM PROCESS_IND USING TEXT-P03.
*++1365 #21.
   IF SY-BATCH IS INITIAL.
*--1365 #21.
     PERFORM LIST_DISPLAY.
*++1365 #21.
*  BEVALLO update batch run
   ELSE.
     PERFORM BATCH_BEVALLO_UPDATE.
   ENDIF.
*--1365 #21.
************************************************************************
* SUBROUTINES
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
* Name of declaration type
     IF NOT P_BTART IS INITIAL.
       SELECT DDTEXT UP TO 1 ROWS INTO P_BTTEXT FROM DD07T
          WHERE DOMNAME = '/ZAK/BTYPART'
            AND DDLANGUAGE = SY-LANGU
            AND DOMVALUE_L = P_BTART.
       ENDSELECT.
** Name of declaration type
*     IF NOT P_BTYPE IS INITIAL.
*       SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
*          WHERE LANGU = SY-LANGU
*            AND BTYPE = P_BTYPE.
* Self-revision of VAT-type returns has been accumulated
       IF P_O = C_X.
         SELECT * UP TO 1 ROWS FROM /ZAK/BEVALL INTO W_/ZAK/BEVALL
           WHERE    BUKRS = P_BUKRS
             AND    BTYPE = P_BTYPE.
         ENDSELECT.
         IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_AFA.
*++PTGSZLAA #01. 2014.03.03
*            OR W_/ZAK/BEVALL-BTYPART = C_BTYPART_PTG.
*--PTGSZLAA #01. 2014.03.03
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
     LOOP AT I_OUTTAB INTO W_OUTTAB WHERE ABEVAZ+0(1) NE 'A'.
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
*++BG 2009.11.26
   DATA LS_STABLE TYPE LVC_S_STBL.
*--BG 2009.11.26
   PERFORM SET_STATUS.
   IF V_CUSTOM_CONTAINER IS INITIAL.
     V_DYNNR = SY-DYNNR.
     PERFORM CREATE_AND_INIT_ALV CHANGING I_OUTTAB[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT.
*++BG 2009.11.26
   ELSE.
*    get position
     LS_STABLE-ROW = 'X'.
     LS_STABLE-COL = 'X'.
     CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY
       EXPORTING
         IS_STABLE = LS_STABLE.
*--BG 2009.11.26
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
*++2065 #06.
   CLEAR V_VIEW.
*--2065 #06.
   IF SY-DYNNR = '9000'.
     REFRESH TAB.
* Normal
     IF P_N = C_X.
       CLEAR TAB.
       IF P_BTART NE C_BTYPART_SZJA.
         MOVE '/ZAK/ZAK_DOL' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.
*++0008 BG 2007.08.06
*      If it is not VAT, you do not need the check button
       IF P_BTART NE C_BTYPART_AFA.
         MOVE 'CHK_AFA' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.
*--0008 BG 2007.08.06
       SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
       SET TITLEBAR 'MAIN9000'.
* Self-revision
     ELSEIF P_O = C_X.
       CLEAR TAB.
       IF P_BTART NE C_BTYPART_SZJA.
         MOVE '/ZAK/ZAK_DOL' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.
*++0008 BG 2007.08.06
*      If it is not VAT, you do not need the check button
       IF P_BTART NE C_BTYPART_AFA.
         MOVE 'CHK_AFA' TO WA_TAB-FCODE.
         APPEND WA_TAB TO TAB.
       ENDIF.
*--0008 BG 2007.08.06
       SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
       SET TITLEBAR 'MAIN9000'.
* Display
     ELSE.
       CLEAR TAB.
*++2065 #06.
*       MOVE '/ZAK/ZAK_TXT' TO WA_TAB-FCODE.
*       APPEND WA_TAB TO TAB.
       MOVE 'X' TO V_VIEW.
*--2065 #06.
*++0008 BG 2007.08.06
*      You don't need the check button for display
       MOVE 'CHK_AFA' TO WA_TAB-FCODE.
       APPEND WA_TAB TO TAB.
*--0008 BG 2007.08.06
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
* Compilation of a field catalog
   PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                          CHANGING PT_FIELDCAT.
* Exclusion of functions
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
       ENDIF.
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
* Character line? The field catalog is different!
* Editable field: XDEFT - radio-button
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
*++0008 BG 2007.08.06
   DATA  L_ERROR.
*--0008 BG 2007.08.06
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
* Request a worker
     WHEN '/ZAK/ZAK_DOL'.
       CALL SCREEN 9900 STARTING AT 40 8.
* Declaration maker
     WHEN '/ZAK/ZAK_TXT'.
* Status check
* Normal declaration
* If you do not have all the data services, you cannot start them
       PERFORM CHECK_DATA USING 'D'.
* Conversion according to data structure
* Add employee records
       PERFORM COPY_OUTTAB.
       PERFORM FILL_NORMAL_LINES CHANGING V_COUNTER.
       PERFORM FILL_STANDARD_LINES.
       IF NOT I_FILE[] IS INITIAL.
         PERFORM DOWNLOAD_FILE CHANGING L_SUBRC.
       ENDIF.
* Writing /ZAK/BEVALLO
*++2065 #06.
*       IF L_SUBRC = 0.
       IF L_SUBRC = 0 AND V_VIEW IS INITIAL.
*--2065 #06.
*++1365 #21.
*         PERFORM UPDATE_BEVALLO CHANGING L_SUBRC.
         PERFORM UPDATE_BEVALLO  TABLES   I_OUTTAB
                                 CHANGING L_SUBRC.
*--1365 #21.
* Update status /ZAK/BEVALLSZ
         IF L_SUBRC = 0.
           PERFORM STATUS_UPDATE.
         ENDIF.
       ENDIF.
*++BG 2007.05.08
*We don't leave, we stay on the list
*       IF SY-TCODE+0(1) = 'Z'.
*         LEAVE TO TRANSACTION SY-TCODE.
*       ELSE.
*         LEAVE PROGRAM.
*       ENDIF.
*--BG 2007.05.08
*++0008 BG 2007.08.06
* Verification of VAT amounts
     WHEN 'CHK_AFA'.
       PERFORM CHECK_AFA  USING   'X'     "AUTO-GEN
                         CHANGING L_ERROR.
       IF L_ERROR IS INITIAL.
         MESSAGE I229.
*        VAT amounts are consistent!
       ENDIF.
*--0008 BG 2007.08.06
* Back
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
* Normal, self-revision, display: Upload S_ selections
   PERFORM FILL_S_RANGES.
   READ TABLE S_GJAHR INDEX 1.
   READ TABLE S_MONAT INDEX 1.
   READ TABLE S_INDEX INDEX 1.
* Definition of declaration type
   CHECK NOT S_GJAHR IS INITIAL AND
         NOT S_MONAT IS INITIAL.
   PERFORM GET_BTYPE USING P_BUKRS
                           P_BTART
                           S_GJAHR-LOW
                           S_MONAT-LOW
                     CHANGING P_BTYPE.
* Determination of the last day of declaration
   PERFORM GET_LAST_DAY_OF_PERIOD USING S_GJAHR-LOW
                                        S_MONAT-LOW
*++PTGSZLAA #01. 2014.03.03
*++PTGSZLAH #01. 2015.01.16
*                                        P_BTART
                                        P_BTYPE
*--PTGSZLAH #01. 2015.01.16
*--PTGSZLAA #01. 2014.03.03
                                   CHANGING V_LAST_DATE.
* /ZAK/BEVALL
   PERFORM READ_BEVALL USING P_BUKRS
                             P_BTART
                             P_BTYPE
                             V_LAST_DATE.
* ...four years old
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
* ...years old
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
* For self-revision: the prerequisite is that 000 is closed
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
* only the currently open serial number can be written, or - if there is no open one - only
* serial number one higher than the last closed one
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
              FLAG  NE C_CLOSED_Z AND
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
*++0003 BG 2007.01.31
*++0004 BG 2007.05.22
*  Check due date completion
*    IF P_ESDAT IS INITIAL.
     IF P_ESDAT IS INITIAL AND ( P_BTART NE C_BTYPART_ONYB AND
                                 P_BTART NE C_BTYPART_ATV ).
*--0004 BG 2007.05.22
       MESSAGE E191(/ZAK/ZAK).
*     Please enter the value of the due date in the selection!
*++0007 BG 2007.07.23
*    Due date conversion
     ELSE.
       PERFORM GET_WORK_DAY USING P_ESDAT.
*--0007 BG 2007.07.23
     ENDIF.
*--0003 BG 2007.01.31
   ENDIF.
*++2365 #03.
   DATA   L_DATUM_LOW  TYPE SY-DATUM.
   DATA   L_DATUM_HIGH TYPE SY-DATUM.
   DEFINE LM_GET_DATUM.
     IF NOT &1 IS INITIAL.
      &2(4)   = s_gjahr-low.
      &2+4(2) = &1.
      &2+6(2) = &3.
     ENDIF.
   END-OF-DEFINITION.
*  Only if the value is filled
   IF NOT  S_SPECM-LOW IS INITIAL.

     IF  ( NOT S_SPECM-LOW  IS INITIAL AND S_SPECM-LOW NOT BETWEEN '01' AND '12' ) OR
         ( NOT S_SPECM-HIGH IS INITIAL AND S_SPECM-HIGH NOT BETWEEN '01' AND '12' ).
       MESSAGE E213(/ZAK/ZAK).
*   Please enter the month between 01 and 12!
     ENDIF.

     IF NOT S_SPECM-LOW  IS INITIAL AND S_SPECM-HIGH IS INITIAL.
       S_SPECM-HIGH = S_SPECM-LOW.
     ENDIF.
     LM_GET_DATUM S_SPECM-LOW  L_DATUM_LOW  '01'.
     LM_GET_DATUM S_SPECM-HIGH L_DATUM_HIGH '01'.
     IF NOT L_DATUM_HIGH IS INITIAL.
       CALL FUNCTION 'LAST_DAY_OF_MONTHS' "#EC CI_USAGE_OK[2296016]
         EXPORTING
           DAY_IN            = L_DATUM_HIGH
         IMPORTING
           LAST_DAY_OF_MONTH = L_DATUM_HIGH
         EXCEPTIONS
           DAY_IN_NO_DATE    = 1
           OTHERS            = 2.
       IF SY-SUBRC NE 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ENDIF.
     ENDIF.
     SELECT COUNT(*) FROM /ZAK/BEVALL
                    WHERE BUKRS EQ P_BUKRS
                      AND BTYPE EQ P_BTYPE
                      AND ( ( DATAB LE L_DATUM_LOW
                               AND DATBI GE L_DATUM_LOW ) OR
                            ( DATAB LE L_DATUM_HIGH
                               AND DATBI GE L_DATUM_HIGH ) )
                      AND BIDOSZ NE 'S'.
     IF SY-SUBRC EQ 0.
       MESSAGE E374(/ZAK/ZAK).
* Based on the settings, a special period cannot be selected for this period!
     ENDIF.
   ENDIF.
*--2365 #03.

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
   DATA: O_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
*++0004 BG 2007.04.04
   DATA: BEGIN OF LI_ONYB OCCURS 0,
           LAND      TYPE CHAR2,
           ADOSZ     TYPE CHAR15,
*++1465 #09.
           ROUND     TYPE /ZAK/ROUND,
*--1465 #09.
           FIELD_N   TYPE /ZAK/FIELDN,
*++1365 #24.
           FIELD_NR  TYPE /ZAK/FIELDNR,
           FIELD_NRK TYPE /ZAK/FIELDNRK,
*--1365 #24.
           HSZU      TYPE /ZAK/HSZU,
*++0012 BG 2008.04.02
           NYLAPAZON TYPE /ZAK/NYLAPAZON,
*--0012 BG 2008.04.02
*++0004 BG 2007.04.19
           OFLAG,
*--0004 BG 2007.04.19
         END OF LI_ONYB.
*++0005 BG 2007.05.30
*  ++ BG 2007.09.25
*   DATA LI_ANALITIKA_0406 LIKE /ZAK/ANALITIKA OCCURS 0.
*   DATA LW_ANALITIKA_0406 LIKE /ZAK/ANALITIKA.
   DATA LI_ANALITIKA_0406 LIKE /ZAK/ANAL_0406 OCCURS 0.
*++1565 #01.
   DATA LI_ANALITIKA_0406_TMP LIKE /ZAK/ANAL_0406 OCCURS 0.
*--1565 #01.
   DATA LW_ANALITIKA_0406 LIKE /ZAK/ANAL_0406.
*  -- BG 2007.09.25
*   DATA LW_/ZAK/BNYLAP LIKE /ZAK/BNYLAP.
*--0005 BG 2007.05.30
*++PTGSZLAA #01. 2014.03.03
   DATA LI_ANALITIKA_PTG LIKE /ZAK/ANAL_PTG OCCURS 0.
   DATA LW_ANALITIKA_PTG LIKE /ZAK/ANAL_PTG.
   DATA LW_ADDR1_VAL     LIKE ADDR1_VAL.
   DATA L_STRING         TYPE STRING.
   DATA L_STRING_SAVE    TYPE STRING.
*--PTGSZLAA #01. 2014.03.03
*++0004 BG 2007.04.19
   DATA LW_ONYB LIKE LI_ONYB.
   DATA L_INDEX TYPE /ZAK/INDEX.
   RANGES LR_INDEX FOR /ZAK/ANALITIKA-ZINDEX.
   DATA L_TABIX LIKE SY-TABIX.
   DATA LW_ONYB_LAST LIKE LI_ONYB.
   DATA L_ADOAZON TYPE /ZAK/ADOAZON.
*--0004 BG 2007.04.19
   DATA L_LAPSZ TYPE /ZAK/LAPSZ.
   DATA L_LAPSZ_SAVE TYPE /ZAK/LAPSZ.
   DATA L_SORSZ TYPE NUMC2.
   DATA L_MAX_SORSZ TYPE NUMC2.
   DATA L_SORINDEX TYPE /ZAK/SORINDEX.
   DATA L_SUBRC LIKE SY-SUBRC.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_RG_01 SPOTS /ZAK/MAIN_ES STATIC .
*++0016 BG 2011.12.08
   DATA LI_ANALITIKA_INDEX LIKE /ZAK/ANALITIKA OCCURS 0.
*--0016 BG 2011.12.08
*++1765 #16.
*  Processing of VAT 07.08 sheets
   TYPES: BEGIN OF LT_NYLAPAZON,
            NYLAPAZON TYPE /ZAK/NYLAPAZON,
          END OF LT_NYLAPAZON.
   DATA LT_NYLAPAZON TYPE STANDARD TABLE OF LT_NYLAPAZON INITIAL SIZE 0 WITH HEADER LINE.
*--1765 #16.
   DEFINE M_GET_ABEV_TO_INDEX.
     CONCATENATE &1 &2 INTO l_sorindex.
     READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
*++0012 BG 2008.04.02
           WITH KEY  nylapazon = w_nylapazon-nylapazon
*--0012 BG 2008.04.02
                     sorindex  = l_sorindex.
     IF sy-subrc EQ 0.
       CLEAR &3.
       MOVE-CORRESPONDING w_/zak/bevallb TO w_outtab.
       w_outtab-bukrs  = p_bukrs.
       w_outtab-gjahr  = s_gjahr-low.
       w_outtab-monat  = r_monat-high.
       w_outtab-zindex = s_index-high.
       CONCATENATE &4-land &4-adosz INTO w_outtab-adoazon.
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
*++0005 BG 2007.05.30
   DEFINE M_GET_ABEV_TO_INDEX_0406.
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
*--0005 BG 2007.05.30
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_RG_02 SPOTS /ZAK/MAIN_ES STATIC .
*++PTGSZLAA #01. 2014.03.03
   DEFINE M_GET_PTG_ABEV_TO_OUTTAB.
     IF NOT &1 IS INITIAL AND NOT &2 IS INITIAL.
       CONCATENATE &1 &2 INTO l_sorindex.
       READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
             WITH KEY sorindex  = l_sorindex
                      nylapazon = &4.
     ELSE.
       READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
             WITH KEY abevaz  = &5.
     ENDIF.
     IF sy-subrc EQ 0.
       CLEAR &3.
       MOVE-CORRESPONDING w_/zak/bevallb TO w_outtab.
       w_outtab-bukrs  = p_bukrs.
       w_outtab-gjahr  = s_gjahr-low.
       w_outtab-monat  = r_monat-high.
       w_outtab-zindex = s_index-high.
       w_outtab-btype_disp  = w_outtab-btype.
       w_outtab-abevaz_disp = w_outtab-abevaz.
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
*--PTGSZLAA #01. 2014.03.03
   CLEAR V_LAPSZ.
*--0004 BG 2007.04.04
*++0005 BG 2007.05.30
   CLEAR V_NYLAPAZON.
*--0005 BG 2007.05.30
*++0010 BG 2008.02.14
   RANGES LR_BTYPE FOR /ZAK/BEVALL-BTYPE.
*--0010 BG 2008.02.14
   REFRESH: I_/ZAK/ANALITIKA,
            I_OUTTAB.
* E - Year old
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
*++PTGSZLAA #01. 2014.03.03
* W - Heti
   IF W_/ZAK/BEVALL-BIDOSZ = 'W'.
     REFRESH R_MONAT.
     CLEAR R_MONAT.
     R_MONAT-SIGN   = 'I'.
     R_MONAT-OPTION = 'BT'.
     R_MONAT-LOW    = S_MONAT-LOW.
     R_MONAT-HIGH   = S_MONAT-LOW.
     APPEND R_MONAT.

   ENDIF.
*--PTGSZLAA #01. 2014.03.03
*++2365 #03.
*  Specifying a special period
   IF W_/ZAK/BEVALL-BIDOSZ = 'S'.
     CALL SCREEN 9901 STARTING AT 5 5 ENDING AT 75 10.
     R_MONAT[] = S_SPECM[].
     IF R_MONAT[] IS INITIAL.
       MESSAGE I373 DISPLAY LIKE 'E'.
*      Special period is not suitable!
       PERFORM EXIT_PROGRAM.
     ELSE.
       READ TABLE R_MONAT INDEX 1.
     ENDIF.
   ENDIF.
*--2365 #03.
   IF P_M <> C_X.
*++0004 BG 2007.04.04
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
*       DELETE ADJACENT DUPLICATES FROM I_ADOAZON.
*     ENDIF.
*--0004 BG 2007.04.04
*++0010 BG 2008.02.14
*    We define the declaration types belonging to the Declaration type
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
*++0016 BG 2011.09.14
*                   WHERE BUKRS  = P_BUKRS
                   WHERE BUKRS  IN R_BUKRS
*--0016 BG 2011.09.14
                     AND BTYPE  IN LR_BTYPE
                     AND GJAHR  = S_GJAHR-LOW
                     AND MONAT  IN R_MONAT
                     AND ZINDEX IN S_INDEX
*++1665 #03.
                     AND NONEED EQ ''.
*++1665 #03.
       IF SY-SUBRC EQ 0.
         MESSAGE I254 WITH P_BTYPE.
*       The analytics contains an item different from the declaration type!
       ENDIF.
     ENDIF.
*--0010 BG 2008.02.14
     SELECT * INTO TABLE I_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
*++0016 BG 2011.09.14
*        WHERE BUKRS  = P_BUKRS
        WHERE BUKRS  IN R_BUKRS
*--0016 BG 2011.09.14
          AND BTYPE  = P_BTYPE
          AND GJAHR  = S_GJAHR-LOW
          AND MONAT  IN R_MONAT
*         and zindex = s_index-low.
          AND ZINDEX IN S_INDEX
*++1765 #08.
          AND NONEED EQ ''.
*--1765 #08.
*++0016 BG 2011.09.14
* In the case of a group company, it is a company code exchange and serial number update
* for the current period.
     IF NOT V_BUKCS IS INITIAL.
       REFRESH LI_ANALITIKA_INDEX.
       READ TABLE S_INDEX INDEX 1.
       LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
         MOVE W_/ZAK/ANALITIKA-BUKRS TO W_/ZAK/ANALITIKA-FI_BUKRS.
         MOVE P_BUKRS TO W_/ZAK/ANALITIKA-BUKRS.
         MOVE SY-TABIX TO W_/ZAK/ANALITIKA-ITEM.
         MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA.
       ENDLOOP.
* Delete analytics
       DELETE FROM /ZAK/ANALITIKA
             WHERE BUKRS  EQ P_BUKRS
               AND BTYPE  = P_BTYPE
               AND GJAHR  = S_GJAHR-LOW
               AND MONAT  IN R_MONAT
               AND ZINDEX IN S_INDEX.
*      Creating analytics
       MODIFY /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
       GET TIME.
*      Set statuses to uploaded
       UPDATE /ZAK/BEVALLI SET FLAG = 'F'
                              DATUM = SY-DATUM
                              UZEIT = SY-UZEIT
                              UNAME = SY-UNAME
                      WHERE BUKRS  EQ P_BUKRS
                        AND BTYPE  = P_BTYPE
                        AND GJAHR  = S_GJAHR-LOW
                        AND MONAT  IN R_MONAT
                        AND ZINDEX = S_INDEX-HIGH.
       UPDATE /ZAK/BEVALLSZ SET FLAG = 'F'
                              DATUM = SY-DATUM
                              UZEIT = SY-UZEIT
                              UNAME = SY-UNAME
                      WHERE BUKRS  EQ P_BUKRS
                        AND BTYPE  = P_BTYPE
                        AND GJAHR  = S_GJAHR-LOW
                        AND MONAT  IN R_MONAT
                        AND ZINDEX = S_INDEX-HIGH.
       COMMIT WORK AND WAIT.
       FREE LI_ANALITIKA_INDEX.
     ENDIF.
*--0016 BG 2011.09.14
*++0004 BG 2007.04.04
*++PTGSZLAA #01. 2014.03.03
*     IF P_BTART NE C_BTYPART_ONYB.
     IF P_BTART EQ C_BTYPART_AFA.
*--PTGSZLAA #01. 2014.03.03
*--0004 BG 2007.04.04
       LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
*++0005 BG 2007.05.30
*++1365 #21.
*                            WHERE abevaz NOT c_abevaz_dummy.
                            WHERE ABEVAZ(5) NE C_ABEVAZ_DUMMY.
*--1365 #21.
*--0005 BG 2007.05.30
         CLEAR W_OUTTAB.
         CLEAR L_COUNTER.
         LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
               WHERE ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
                 AND STAPO NE C_X.
           O_/ZAK/ANALITIKA = W_/ZAK/ANALITIKA.
           PERFORM PROCESS_IND USING TEXT-P02.
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
*          Karakteres
           IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.
             READ TABLE I_OUTTAB INTO L_OUTTAB WITH KEY
                  BUKRS = W_/ZAK/ANALITIKA-BUKRS
                  BTYPE = W_/ZAK/ANALITIKA-BTYPE
                  GJAHR = W_/ZAK/ANALITIKA-GJAHR
                  MONAT = W_/ZAK/ANALITIKA-MONAT
                  ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                  ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                  ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
*            If you don't have this key yet - I went down
             IF SY-SUBRC NE 0.
*              Self-revision - due date
               IF P_O = 'X' AND
                  P_CUM = 'X' AND
                  W_/ZAK/BEVALLB-ESDAT_FLAG = 'X'.
                 IF O_/ZAK/ANALITIKA-ZINDEX <> S_INDEX-HIGH.
                   CLEAR W_/ZAK/ANALITIKA-FIELD_C.
                 ENDIF.
               ENDIF.
               MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
               MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
*++1465 #04.
               W_OUTTAB-WAERS = C_HUF.
*--1465 #04.
               W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
               W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
               SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
                 FROM  /ZAK/BEVALLBT
                      WHERE  LANGU   = SY-LANGU
                      AND    BTYPE   = W_OUTTAB-BTYPE
                      AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
               W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
               COLLECT W_OUTTAB INTO I_OUTTAB.
*            I already have such a key
             ELSE.
*              This is the default text - I will modify the saved one
               IF NOT W_/ZAK/ANALITIKA-XDEFT IS INITIAL.
                 READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                      BUKRS = W_/ZAK/ANALITIKA-BUKRS
                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
                      MONAT = W_/ZAK/ANALITIKA-MONAT
                      ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                      ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                      ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
                 IF SY-SUBRC = 0.
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
                   MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
                 ENDIF.
               ENDIF.
             ENDIF.
*          Numerikus
           ELSE.
             MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
             MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
*++1465 #04.
             W_OUTTAB-WAERS = C_HUF.
*--1465 #04.
             W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
             W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
             SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
               FROM  /ZAK/BEVALLBT
                    WHERE  LANGU   = SY-LANGU
                    AND    BTYPE   = W_OUTTAB-BTYPE
                    AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
             W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
             COLLECT W_OUTTAB INTO I_OUTTAB.
           ENDIF.
         ENDLOOP.
         IF L_COUNTER = 0.
           IF P_BTART = C_BTYPART_SZJA.
             IF W_/ZAK/BEVALLB-ASZKOT = 'X'.
               LOOP AT I_ADOAZON.
                 MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
                 W_OUTTAB-BUKRS  = P_BUKRS.
                 W_OUTTAB-GJAHR  = S_GJAHR-LOW.
                 W_OUTTAB-MONAT  = R_MONAT-HIGH.
                 W_OUTTAB-ZINDEX = S_INDEX-HIGH.
                 W_OUTTAB-WAERS  = C_HUF.
                 W_OUTTAB-LAPSZ  = C_LAPSZ.
                 W_OUTTAB-ADOAZON = I_ADOAZON-ADOAZON.
                 W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
                 W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
                 SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
                   FROM  /ZAK/BEVALLBT
                        WHERE  LANGU   = SY-LANGU
                        AND    BTYPE   = W_OUTTAB-BTYPE
                        AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
                 W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
                 COLLECT W_OUTTAB INTO I_OUTTAB.
               ENDLOOP.
             ELSE.
               MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
               W_OUTTAB-BUKRS  = P_BUKRS.
               W_OUTTAB-GJAHR  = S_GJAHR-LOW.
               W_OUTTAB-MONAT  = R_MONAT-HIGH.
               W_OUTTAB-ZINDEX = S_INDEX-HIGH.
               W_OUTTAB-WAERS  = C_HUF.
               W_OUTTAB-LAPSZ  = C_LAPSZ.
               W_OUTTAB-ADOAZON = SPACE.
               W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
               W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
               SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
                 FROM  /ZAK/BEVALLBT
                      WHERE  LANGU   = SY-LANGU
                      AND    BTYPE   = W_OUTTAB-BTYPE
                      AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
               W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
               COLLECT W_OUTTAB INTO I_OUTTAB.
             ENDIF.
           ELSE.
*++0005 BG 2007.05.30
*           In the case of VAT, if the row/column is filled in, it is not necessary
             IF P_BTART EQ C_BTYPART_AFA
                AND ( ( NOT W_/ZAK/BEVALLB-SORINDEX IS INITIAL
                        AND W_/ZAK/BEVALLB-SORINDEX NE '0') OR
*++1365 22.01.2013 Balázs Gábor (Ness)
                    (  NOT W_/ZAK/BEVALLB-ASZKOT IS INITIAL ) ).
*--1365 22.01.2013 Balázs Gábor (Ness)
               CONTINUE.
             ENDIF.
*--0005 BG 2007.05.30
             MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
             W_OUTTAB-BUKRS  = P_BUKRS.
             W_OUTTAB-GJAHR  = S_GJAHR-LOW.
             W_OUTTAB-MONAT  = R_MONAT-HIGH.
             W_OUTTAB-ZINDEX = S_INDEX-HIGH.
             W_OUTTAB-WAERS  = C_HUF.
             W_OUTTAB-LAPSZ  = C_LAPSZ.
             W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
             W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
             SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
               FROM  /ZAK/BEVALLBT
                    WHERE  LANGU   = SY-LANGU
                    AND    BTYPE   = W_OUTTAB-BTYPE
                    AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
             W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
             COLLECT W_OUTTAB INTO I_OUTTAB.
           ENDIF.
         ENDIF.
       ENDLOOP.
*++0005 BG 2007.05.30
*      Processing of VAT type 04, 06
       IF P_BTART EQ C_BTYPART_AFA.
         REFRESH LI_ANALITIKA_0406.
         LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
               WHERE ABEVAZ = C_ABEVAZ_DUMMY.
           CLEAR LW_ANALITIKA_0406.
*++0005 BG 2007.09.25
*          MOVE W_/ZAK/ANALITIKA TO LW_ANALITIKA_0406.
           MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO LW_ANALITIKA_0406.
*--0005 BG 2007.09.25
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_ZF_02 SPOTS /ZAK/MAIN_ES .
*          PERIODS
           READ TABLE S_INDEX INDEX 1.
           LW_ANALITIKA_0406-ZINDEX = S_INDEX-HIGH.
           READ TABLE R_MONAT INDEX 1.
           LW_ANALITIKA_0406-MONAT = R_MONAT-HIGH.
           COLLECT LW_ANALITIKA_0406 INTO LI_ANALITIKA_0406.
         ENDLOOP.
*++0005 BG 2007.09.25
         DELETE LI_ANALITIKA_0406 WHERE LWSTE IS INITIAL
                                    AND FWSTE IS INITIAL
                                    AND LWBAS IS INITIAL
                                    AND FWBAS IS INITIAL.
*--0005 BG 2007.09.25
*        We determine which setting belongs to the last day
         IF NOT LI_ANALITIKA_0406[] IS INITIAL.
           SELECT  * INTO W_/ZAK/BNYLAP
                     UP TO 1 ROWS
                     FROM /ZAK/BNYLAP
                    WHERE BUKRS   EQ P_BUKRS
                      AND BTYPART EQ P_BTART
                      AND DATBI   GE V_LAST_DATE
                      AND DATAB   LE V_LAST_DATE.
           ENDSELECT.
           IF SY-SUBRC NE 0.
             MESSAGE E220 WITH P_BUKRS P_BTART V_LAST_DATE.
*There is no setting in the /ZAK/BNYLAP table! (Company: &, type: &, date:
*&).
           ELSE.
             MOVE W_/ZAK/BNYLAP-NYLAPAZON TO V_NYLAPAZON.
           ENDIF.
*++1565 #01.
*          If it is not projectable, then XBLNR does not need to be taken into account
*          when summarizing
           IF W_/ZAK/BNYLAP-VPOPKI IS INITIAL.
             LI_ANALITIKA_0406_TMP[] = LI_ANALITIKA_0406[].
             FREE LI_ANALITIKA_0406.
             LOOP AT  LI_ANALITIKA_0406_TMP INTO LW_ANALITIKA_0406.
               CLEAR LW_ANALITIKA_0406-XBLNR.
               COLLECT LW_ANALITIKA_0406 INTO LI_ANALITIKA_0406.
             ENDLOOP.
             FREE LI_ANALITIKA_0406_TMP.
             DELETE LI_ANALITIKA_0406 WHERE LWSTE IS INITIAL
                                        AND FWSTE IS INITIAL
                                        AND LWBAS IS INITIAL
                                        AND FWBAS IS INITIAL.
           ENDIF.
*--1565 #01.
*        We define the largest row index
           LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                                WHERE NOT SORINDEX IS INITIAL
                                  AND NYLAPAZON EQ
                                  W_/ZAK/BNYLAP-NYLAPAZON.
             IF W_/ZAK/BEVALLB-SORINDEX(2) > L_MAX_SORSZ.
               MOVE W_/ZAK/BEVALLB-SORINDEX(2) TO L_MAX_SORSZ.
             ENDIF.
           ENDLOOP.
           IF SY-SUBRC NE 0.
             MESSAGE E221 WITH P_BTART.
*There is no "Row / column identifier" setting for the & declaration type!
           ENDIF.
*        Upload data
           CLEAR W_OUTTAB.
           L_LAPSZ = 1.
           L_SORSZ = 1.
*        If there is data, processing
           LOOP AT LI_ANALITIKA_0406 INTO LW_ANALITIKA_0406.
             IF L_SORSZ > L_MAX_SORSZ.
               ADD 1 TO L_LAPSZ.
               L_SORSZ = 1.
             ENDIF.
*          Filling in the customs decision number
             M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'A' L_SUBRC
             W_/ZAK/BNYLAP-NYLAPAZON.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
               MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Loading page 04
*++0965 2009.02.23 BG
*            From 0965, you cannot treat 04 or 06 as a constant because
*            has changed, therefore a flag marking VPOP has been introduced
*            for treatment imposed by
*            IF W_/ZAK/BNYLAP-NYLAPAZON EQ C_NYLAPAZON_04.
             IF NOT W_/ZAK/BNYLAP-VPOPKI IS INITIAL.
*--0965 2009.02.23 BG
*            Date of notification of customs decision
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'B' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-BLDAT TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*            Amount of tax payable
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'C' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-LWSTE TO W_OUTTAB-FIELD_N.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*            Payment receipt number
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'D' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-XBLNR TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*            Date of payment
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'E' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-AUGDT TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*            Amount of tax paid
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'F' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-FWSTE TO W_OUTTAB-FIELD_N.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*          Loading page 06
*++0965 2009.02.23 BG
*            ELSEIF W_/ZAK/BNYLAP-NYLAPAZON EQ C_NYLAPAZON_06.
             ELSE. "W_/ZAK/BNYLAP-VPOPKI is initial
*--0965 2009.02.23 BG
*            Date of notification of customs decision
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'B' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-BLDAT TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*            Customs value included in the customs decision
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'C' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-LWBAS TO W_OUTTAB-FIELD_N.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*            Amount increasing the customs value
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'D' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE LW_ANALITIKA_0406-ADOAZON TO W_OUTTAB-ADOAZON.
                 MOVE LW_ANALITIKA_0406-FWBAS TO W_OUTTAB-FIELD_N.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
             ENDIF.
             ADD 1 TO L_SORSZ.
           ENDLOOP.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_RG_03 SPOTS /ZAK/MAIN_ES .
           MOVE L_LAPSZ TO V_LAPSZ.
         ENDIF.
*++1365 10.01.2013 Balázs Gábor (Ness)
*      A summary report is relevant
*++1365 #21.
*         IF NOT w_/zak/bevall-omrel IS INITIAL.
         IF NOT W_/ZAK/BEVALL-OMREL IS INITIAL AND
            NOT P_OMREL IS INITIAL.
*--1365 #21.
*          Summarization of account numbers Formation of M records
           PERFORM SUM_GEN_OMREL  USING C_ABEVAZ_DUMMY_R
                                        C_ABEVAZ_DUMMY_M
                                        W_/ZAK/BEVALL-BTYPE
                                        W_/ZAK/BEVALL-OLWSTE.
*          Processing of ABEV identifiers
           PERFORM GET_OMREL_PROC USING C_ABEVAZ_DUMMY_M
                                        C_NYLAPAZON_M01.
           PERFORM GET_OMREL_PROC USING C_ABEVAZ_DUMMY_M
                                        C_NYLAPAZON_M01_K.
           .
           PERFORM GET_OMREL_PROC USING C_ABEVAZ_DUMMY_M
                                        C_NYLAPAZON_M02.
           PERFORM GET_OMREL_PROC USING C_ABEVAZ_DUMMY_M
                                        C_NYLAPAZON_M02_K.
         ENDIF.
*++1765 #16.
*        Processing of VAT 07.08 sheets
*        We determine what cards there are and process them in order:
         LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA WHERE ABEVAZ EQ C_ABEVAZ_DUMMY_0708.
           CLEAR LT_NYLAPAZON.
           LT_NYLAPAZON-NYLAPAZON = W_/ZAK/ANALITIKA-NYLAPAZON.
           COLLECT LT_NYLAPAZON.
         ENDLOOP.
*        Processing
         IF SY-SUBRC EQ 0.
           SORT LT_NYLAPAZON.
           LOOP AT LT_NYLAPAZON.
*            We define the largest row index
             LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                                  WHERE NOT SORINDEX IS INITIAL
                                    AND NYLAPAZON EQ
                                    LT_NYLAPAZON-NYLAPAZON.
               IF W_/ZAK/BEVALLB-SORINDEX(2) > L_MAX_SORSZ.
                 MOVE W_/ZAK/BEVALLB-SORINDEX(2) TO L_MAX_SORSZ.
               ENDIF.
             ENDLOOP.
             IF SY-SUBRC NE 0.
               MESSAGE E221 WITH P_BTART.
*              There is no "Row / column identifier" setting for the & declaration type!
             ENDIF.
*            Upload data
             CLEAR W_OUTTAB.
             L_LAPSZ = 1.
             L_SORSZ = 1.
             LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA WHERE ABEVAZ EQ C_ABEVAZ_DUMMY_0708
                                                            AND NYLAPAZON EQ LT_NYLAPAZON-NYLAPAZON.
               IF L_SORSZ > L_MAX_SORSZ.
                 ADD 1 TO L_LAPSZ.
                 L_SORSZ = 1.
               ENDIF.
*              Entering the customer's tax number
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'A' L_SUBRC LT_NYLAPAZON-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE W_/ZAK/ANALITIKA-STCD1 TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*              Completion date
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'B' L_SUBRC LT_NYLAPAZON-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE W_/ZAK/ANALITIKA-BLDAT TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*              Product name
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'C' L_SUBRC LT_NYLAPAZON-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 SELECT SINGLE VNAME INTO W_OUTTAB-FIELD_C
                                     FROM /ZAK/AFA_VAMTT
                                    WHERE LANGU EQ SY-LANGU
*++1765 #17.
*                                      AND VMSZA EQ W_/ZAK/ANALITIKA-POSID.
                                      AND VMSZA EQ W_/ZAK/ANALITIKA-VMSZA.
*--1765 #17.
                 IF SY-SUBRC NE 0.
                   MESSAGE E365 WITH W_/ZAK/ANALITIKA-VMSZA.
*                    & customs tariff number cannot be named!
                 ENDIF.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*              Customs tariff number
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'D' L_SUBRC LT_NYLAPAZON-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
*++1765 #17.
*                 MOVE W_/ZAK/ANALITIKA-POSID TO W_OUTTAB-FIELD_C.
                 MOVE W_/ZAK/ANALITIKA-VMSZA TO W_OUTTAB-FIELD_C.
*--1765 #17.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*              Quantity
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'E' L_SUBRC LT_NYLAPAZON-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE W_/ZAK/ANALITIKA-FIELD_C TO W_OUTTAB-FIELD_C.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
*              Tax base
               M_GET_ABEV_TO_INDEX_0406 L_SORSZ 'F' L_SUBRC LT_NYLAPAZON-NYLAPAZON.
               IF L_SUBRC IS INITIAL.
                 MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
                 MOVE W_/ZAK/ANALITIKA-LWBAS TO W_OUTTAB-FIELD_N.
                 APPEND W_OUTTAB TO I_OUTTAB.
                 CLEAR W_OUTTAB.
               ENDIF.
               ADD 1 TO L_SORSZ.
             ENDLOOP.
           ENDLOOP.
         ENDIF.
*--1765 #16.
       ENDIF.
*--0005 BG 2007.05.30
*--1365 10.01.2013 Balázs Gábor (Ness)
*++0004 BG 2007.04.04
*++PTGSZLAA #01. 2014.03.03
*     ELSE. "C_BTYPART_ONYB
     ELSEIF P_BTART EQ C_BTYPART_ONYB.
*--PTGSZLAA #01. 2014.03.03
*      Collection of data into own structure.
       LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
                         WHERE NOT FIELD_N IS INITIAL.
         CLEAR LI_ONYB.
         MOVE W_/ZAK/ANALITIKA-ADOAZON(2)    TO LI_ONYB-LAND.
         MOVE W_/ZAK/ANALITIKA-ADOAZON+2(15) TO LI_ONYB-ADOSZ.
         MOVE W_/ZAK/ANALITIKA-FIELD_N       TO LI_ONYB-FIELD_N.
*++1365 #24.
         READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                   WITH KEY BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                            ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ.
         IF SY-SUBRC EQ 0.
*++1465 #09.
*           PERFORM CALC_FIELD_NRK USING W_/ZAK/ANALITIKA-FIELD_N
*                                        W_/ZAK/BEVALLB-ROUND
**++1465 #04.
**                                        W_/ZAK/ANALITIKA-WAERS
*                                        C_HUF
**--1465 #04.
*                               CHANGING LI_ONYB-FIELD_NR
*                                        LI_ONYB-FIELD_NRK.
           LI_ONYB-ROUND = W_/ZAK/BEVALLB-ROUND.
*--1465 #09.
         ENDIF.
*--1365 #24.
         MOVE W_/ZAK/ANALITIKA-HSZU          TO LI_ONYB-HSZU.
*++0012 BG 2008.04.02
         MOVE W_/ZAK/ANALITIKA-NYLAPAZON     TO LI_ONYB-NYLAPAZON.
*--0012 BG 2008.04.02
         COLLECT LI_ONYB.
       ENDLOOP.
*++0004 BG 2007.10.10
*++1465 #09.
       LOOP AT LI_ONYB.
         PERFORM CALC_FIELD_NRK USING LI_ONYB-FIELD_N
                                      LI_ONYB-ROUND
                                      C_HUF
                             CHANGING LI_ONYB-FIELD_NR
                                      LI_ONYB-FIELD_NRK.
         MODIFY LI_ONYB TRANSPORTING FIELD_NR FIELD_NRK.
       ENDLOOP.
*--1465 #09.
*++1365 #24.
*      DELETE LI_ONYB WHERE FIELD_N IS INITIAL.
       DELETE LI_ONYB WHERE FIELD_NRK IS INITIAL.
*--1365 #24.
*--0004 BG 2007.10.10
       SORT LI_ONYB.
*      Self-revision management
       IF NOT P_O IS INITIAL.
         L_INDEX = S_INDEX-LOW.
*        Upload Range
         SUBTRACT 1 FROM L_INDEX.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = L_INDEX
           IMPORTING
             OUTPUT = L_INDEX.
         REFRESH LR_INDEX.
*        We search for values ​​from 000 to the current index-1
*        in analytics.
         M_DEF LR_INDEX 'I' 'BT' '000' L_INDEX.
*        Search for data in previous indexes
         LOOP AT LI_ONYB.
           MOVE SY-TABIX TO L_TABIX.
*          Training of ADOAZON
           CONCATENATE LI_ONYB-LAND LI_ONYB-ADOSZ INTO L_ADOAZON.
*          Management of values ​​in previous periods
           CLEAR: W_/ZAK/ANALITIKA, LW_ONYB_LAST.
           SELECT *   INTO W_/ZAK/ANALITIKA
                           FROM /ZAK/ANALITIKA
                          WHERE BUKRS    = P_BUKRS
                             AND BTYPE   = P_BTYPE
                             AND GJAHR   = S_GJAHR-LOW
                             AND MONAT   IN R_MONAT
                             AND ZINDEX  IN LR_INDEX
                             AND ADOAZON EQ L_ADOAZON
                             AND HSZU    EQ LI_ONYB-HSZU
*++0012 BG 2008.04.02
                             AND NYLAPAZON EQ LI_ONYB-NYLAPAZON
*--0012 BG 2008.04.02
                             .
             MOVE W_/ZAK/ANALITIKA-ADOAZON(2)    TO LW_ONYB_LAST-LAND.
             MOVE W_/ZAK/ANALITIKA-ADOAZON+2(15) TO LW_ONYB_LAST-ADOSZ.
             ADD  W_/ZAK/ANALITIKA-FIELD_N       TO LW_ONYB_LAST-FIELD_N.
             MOVE W_/ZAK/ANALITIKA-HSZU          TO LW_ONYB_LAST-HSZU.
*++0012 BG 2008.04.02
             MOVE W_/ZAK/ANALITIKA-NYLAPAZON     TO
             LW_ONYB_LAST-NYLAPAZON.
*--0012 BG 2008.04.02
           ENDSELECT.
           IF SY-SUBRC EQ 0.
*            Record found, must be deleted
             MOVE 'T' TO LW_ONYB_LAST-OFLAG.
*We add it to the current index so it doesn't take it into account again
             ADD  LW_ONYB_LAST-FIELD_N TO LI_ONYB-FIELD_N.
*++0004 BG 2007.05.24
*            SUBTRACT 1 FROM L_TABIX.
*--0004 BG 2007.05.24
             IF L_TABIX IS INITIAL.
               MOVE 1 TO L_TABIX.
             ENDIF.
*             INSERT LW_ONYB_LAST INTO LI_ONYB INDEX L_TABIX.
*             MOVE 'U' TO LI_ONYB-OFLAG.
*             MODIFY LI_ONYB TRANSPORTING FIELD_N OFLAG.
*++2009.12.07 BG
             IF NOT LW_ONYB_LAST-FIELD_N IS INITIAL.
*--2009.12.07 BG
               INSERT LW_ONYB_LAST INTO LI_ONYB INDEX L_TABIX.
*++2009.12.07 BG
             ENDIF.
*--2009.12.07 BG
*++2009.12.07 BG
             IF NOT LI_ONYB-FIELD_N IS INITIAL.
*--2009.12.07 BG
               MOVE 'U' TO LI_ONYB-OFLAG.
               MODIFY LI_ONYB TRANSPORTING FIELD_N OFLAG.
*++2009.12.07 BG
             ELSE.
               DELETE LI_ONYB.
             ENDIF.
*--2009.12.07 BG
           ELSE.
*            There is no data in the previous periods, we are changing the flag
             MOVE 'U' TO LI_ONYB-OFLAG.
             MODIFY LI_ONYB TRANSPORTING OFLAG.
*++0004 BG 2007.05.24
*            EXIT.
*--0004 BG 2007.05.24
           ENDIF.
         ENDLOOP.
         SORT LI_ONYB.
       ENDIF.
*--0004 BG 2007.04.19
*++0012 BG 2008.04.02
*      We determine how many FLAPS exist in /ZAK/BEVALLB
*      and read them through
       LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                            WHERE NOT NYLAPAZON IS INITIAL.
         MOVE W_/ZAK/BEVALLB-NYLAPAZON TO W_NYLAPAZON-NYLAPAZON.
         COLLECT W_NYLAPAZON INTO I_NYLAPAZON.
       ENDLOOP.
       IF I_NYLAPAZON[] IS INITIAL.
         MESSAGE E267 WITH P_BTART.
*There is no form sheet identification setting for the & declaration type!
       ENDIF.
*--0012 BG 2008.04.02
*++0012 BG 2008.04.02
*      Processing sheet per ID
       LOOP AT I_NYLAPAZON INTO W_NYLAPAZON.
         CLEAR L_MAX_SORSZ.
*--0012 BG 2008.04.02
*      We define the largest row index
         LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
*++0012 BG 2008.04.02
                              WHERE NYLAPAZON = W_NYLAPAZON-NYLAPAZON
*--0012 BG 2008.04.02
                                AND NOT SORINDEX IS INITIAL.
           IF W_/ZAK/BEVALLB-SORINDEX(2) > L_MAX_SORSZ.
             MOVE W_/ZAK/BEVALLB-SORINDEX(2) TO L_MAX_SORSZ.
           ENDIF.
         ENDLOOP.
         IF SY-SUBRC NE 0.
           MESSAGE E221 WITH P_BTART.
*        There is no "Row / column identifier" setting for the & declaration type!
         ENDIF.
*      Upload data
         CLEAR W_OUTTAB.
         L_LAPSZ = 1.
         L_SORSZ = 1.
*++0012 BG 2008.04.02
*        LOOP AT LI_ONYB.
         LOOP AT LI_ONYB WHERE NYLAPAZON = W_NYLAPAZON-NYLAPAZON.
*--0012 BG 2008.04.02
           IF L_SORSZ > L_MAX_SORSZ.
             ADD 1 TO L_LAPSZ.
             L_SORSZ = 1.
           ENDIF.
*        Loading country code
           M_GET_ABEV_TO_INDEX L_SORSZ 'A' L_SUBRC LI_ONYB.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LI_ONYB-LAND TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Loading a tax number
           M_GET_ABEV_TO_INDEX L_SORSZ 'B' L_SUBRC LI_ONYB.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LI_ONYB-ADOSZ TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Charge amount
           M_GET_ABEV_TO_INDEX L_SORSZ 'C' L_SUBRC LI_ONYB.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LI_ONYB-FIELD_N TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Loading a triangle deal
           M_GET_ABEV_TO_INDEX L_SORSZ 'D' L_SUBRC LI_ONYB.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LI_ONYB-HSZU TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Loading self-revision flag
           IF NOT P_O IS INITIAL.
             M_GET_ABEV_TO_INDEX L_SORSZ 'E' L_SUBRC LI_ONYB.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LI_ONYB-OFLAG TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
           ENDIF.
*++0004 BG 2007.05.24
*        Charging reason for correction
           IF NOT P_O IS INITIAL.
             M_GET_ABEV_TO_INDEX L_SORSZ 'G' L_SUBRC LI_ONYB.
             IF L_SUBRC IS INITIAL AND LI_ONYB-OFLAG EQ 'T'.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE C_X TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
           ENDIF.
*--0004 BG 2007.05.24
           ADD 1 TO L_SORSZ.
*++0004 BG 2007.05.24
           CLEAR W_OUTTAB.
*--0004 BG 2007.05.24
         ENDLOOP.
         W_NYLAPAZON-LAPSZ = L_LAPSZ.
         MODIFY I_NYLAPAZON FROM W_NYLAPAZON TRANSPORTING LAPSZ.
*++0012 BG 2008.04.02
       ENDLOOP.
*--0012 BG 2008.04.02
*++0012 BG 2008.04.02
*       L_LAPSZ_SAVE = L_LAPSZ.
*       MOVE L_LAPSZ TO V_LAPSZ.
*--0012 BG 2008.04.02
*      Adding character fields
       LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                            WHERE FIELDTYPE = 'C'
                              AND SORINDEX IS INITIAL.
*++0012 BG 2008.04.02
*        L_LAPSZ = L_LAPSZ_SAVE.
*--0012 BG 2008.04.02
         MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
         W_OUTTAB-BUKRS  = P_BUKRS.
         W_OUTTAB-GJAHR  = S_GJAHR-LOW.
         W_OUTTAB-MONAT  = R_MONAT-HIGH.
         W_OUTTAB-ZINDEX = S_INDEX-HIGH.
         W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
         W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
         W_OUTTAB-WAERS  = C_HUF.
         SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
           FROM  /ZAK/BEVALLBT
                WHERE  LANGU   = SY-LANGU
                AND    BTYPE   = W_OUTTAB-BTYPE
                AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
         W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
*++0012 BG 2008.04.02
*         DO.
*           IF L_LAPSZ IS INITIAL.
*             EXIT.
*           ENDIF.
*--0012 BG 2008.04.02
         W_OUTTAB-LAPSZ = 1.
         APPEND W_OUTTAB TO I_OUTTAB.
*++0012 BG 2008.04.02
*           SUBTRACT 1 FROM L_LAPSZ.
*         ENDDO.
*--0012 BG 2008.04.02
       ENDLOOP.
*++PTGSZLAA #01. 2014.03.03
     ELSEIF P_BTART EQ C_BTYPART_PTG.
*      We create A-s ABEV identifiers!
       LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                            WHERE ABEVAZ(1) EQ 'A'.
         CLEAR W_OUTTAB.
         CLEAR L_COUNTER.
         MOVE-CORRESPONDING W_/ZAK/BEVALLB TO W_OUTTAB.
         W_OUTTAB-BUKRS  = P_BUKRS.
         W_OUTTAB-GJAHR  = S_GJAHR-LOW.
         W_OUTTAB-MONAT  = R_MONAT-HIGH.
         W_OUTTAB-ZINDEX = S_INDEX-HIGH.
         W_OUTTAB-WAERS  = C_HUF.
         W_OUTTAB-LAPSZ  = C_LAPSZ.
         W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
         W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.
         SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
           FROM  /ZAK/BEVALLBT
                WHERE  LANGU   = SY-LANGU
                AND    BTYPE   = W_OUTTAB-BTYPE
                AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
         W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
         COLLECT W_OUTTAB INTO I_OUTTAB.
       ENDLOOP.
       REFRESH LI_ANALITIKA_PTG.
       LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
             WHERE ABEVAZ = C_ABEVAZ_DUMMY.
         CLEAR LW_ANALITIKA_PTG.
         MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO LW_ANALITIKA_PTG.
*++PTGSZLAA #02. 2014.03.05
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_01 SPOTS /ZAK/MAIN_ES .
*++PTGSZLAH #02. 2015.01.30
ENHANCEMENT-POINT YAK_MAIN_PENZT_03 SPOTS /ZAK/MAIN_ES .
*--PTGSZLAH #02. 2015.01.30
*        Determination of cash collection location
         PERFORM GET_ADDR_DATA USING  LW_ANALITIKA_PTG-XBLNR
                                      LW_ANALITIKA_PTG-LIFKUN
                                      LW_ADDR1_VAL
                                      L_SUBRC.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_05 SPOTS /ZAK/MAIN_ES .
*++PTGSZLAH #02. 2015.01.30
ENHANCEMENT-POINT YAK_MAIN_PENZT_04 SPOTS /ZAK/MAIN_ES .
*--PTGSZLAH #02. 2015.01.30
         IF L_SUBRC NE 0.
           MESSAGE E401 WITH LW_ANALITIKA_PTG-LIFKUN.
*            & checkout location does not exist!
         ENDIF.
*--PTGSZLAA #02. 2014.03.05
*        PERIODS
         READ TABLE S_INDEX INDEX 1.
         LW_ANALITIKA_PTG-ZINDEX = S_INDEX-HIGH.
         READ TABLE R_MONAT INDEX 1.
         LW_ANALITIKA_PTG-MONAT = R_MONAT-HIGH.
         COLLECT LW_ANALITIKA_PTG INTO LI_ANALITIKA_PTG.
       ENDLOOP.
       DELETE LI_ANALITIKA_PTG WHERE FWSTE IS INITIAL
                                 AND FWBTR IS INITIAL.
       SORT LI_ANALITIKA_PTG BY LIFKUN SZAMLAKELT.
*      We determine which setting belongs to the last day
       IF NOT LI_ANALITIKA_PTG[] IS INITIAL.
         SELECT  * INTO W_/ZAK/BNYLAP
                   UP TO 1 ROWS
                   FROM /ZAK/BNYLAP
                  WHERE BUKRS   EQ P_BUKRS
                    AND BTYPART EQ P_BTART
                    AND DATBI   GE V_LAST_DATE
                    AND DATAB   LE V_LAST_DATE.
         ENDSELECT.
         IF SY-SUBRC NE 0.
           MESSAGE E220 WITH P_BUKRS P_BTART V_LAST_DATE.
*There is no setting in the /ZAK/BNYLAP table! (Company: &, type: &, date:
*&).
         ELSE.
           MOVE W_/ZAK/BNYLAP-NYLAPAZON TO V_NYLAPAZON.
         ENDIF.
*        We define the largest row index
         LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                              WHERE NOT SORINDEX IS INITIAL
                                AND NYLAPAZON EQ
                                W_/ZAK/BNYLAP-NYLAPAZON.
           IF W_/ZAK/BEVALLB-SORINDEX(2) > L_MAX_SORSZ.
             MOVE W_/ZAK/BEVALLB-SORINDEX(2) TO L_MAX_SORSZ.
           ENDIF.
         ENDLOOP.
         IF SY-SUBRC NE 0.
           MESSAGE E221 WITH P_BTART.
*There is no "Row / column identifier" setting for the & declaration type!
         ENDIF.
*        Upload data
         CLEAR W_OUTTAB.
         L_LAPSZ = 1.
         L_SORSZ = 1.
         CLEAR L_STRING_SAVE.
*        If there is data, processing
         LOOP AT LI_ANALITIKA_PTG INTO LW_ANALITIKA_PTG.
*          Monitoring cash location or account changes
           CONCATENATE LW_ANALITIKA_PTG-LIFKUN
                       LW_ANALITIKA_PTG-SZAMLAKELT
                  INTO L_STRING.
           IF NOT L_STRING_SAVE IS INITIAL AND
              L_STRING_SAVE NE L_STRING.
             ADD 1 TO L_LAPSZ.
             L_SORSZ = 1.
           ENDIF.
           IF L_SORSZ > L_MAX_SORSZ.
             ADD 1 TO L_LAPSZ.
             L_SORSZ = 1.
           ENDIF.
*++PTGSZLAA #02. 2014.03.05
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_02 SPOTS /ZAK/MAIN_ES .
*++PTGSZLAH #02. 2015.01.30
ENHANCEMENT-POINT YAK_MAIN_PENZT_01 SPOTS /ZAK/MAIN_ES .
*--PTGSZLAH #02. 2015.01.30
*        Determination of cash collection location
           PERFORM GET_ADDR_DATA USING  LW_ANALITIKA_PTG-XBLNR
                                        LW_ANALITIKA_PTG-LIFKUN
                                        LW_ADDR1_VAL
                                        L_SUBRC.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_06 SPOTS /ZAK/MAIN_ES .
*++PTGSZLAH #02. 2015.01.30
ENHANCEMENT-POINT YAK_MAIN_PENZT_02 SPOTS /ZAK/MAIN_ES .
*--PTGSZLAH #02. 2015.01.30
           IF L_SUBRC NE 0.
             MESSAGE E401 WITH LW_ANALITIKA_PTG-LIFKUN.
*            & checkout location does not exist!
           ENDIF.
*--PTGSZLAA #02. 2014.03.05
*++PTGSZLAH #01. 2015.01.16
           IF P_BTYPE EQ C_BTYPE_PTGSZLAA.
*--PTGSZLAH #01. 2015.01.16
*          Cash pick-up point name M0BB001A
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB001A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-NAME1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Invoice issue date
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB002A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZAMLAKELT TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Postal code of cash collection location
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB005A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-POST_CODE1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          City of cash collection
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB006A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-CITY1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Name of public area of ​​cash collection location
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB008A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-STREET TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          The nature of the cash collection place as a public area
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB009A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-HOUSE_NUM2 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash pick-up location house number
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB010A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-HOUSE_NUM1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk building
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB011A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-BUILDING TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk stairwell
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB012A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-HOUSE_NUM3 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk floor
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB013A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-FLOOR TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk door
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB014A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-ROOMNUMBER TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Account number
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'A' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZAMLASZ TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Account type
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'B' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZLATIP TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          History account number
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'C' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZAMLASZE TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Buyer's tax identification number
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'D' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
*++PTGSZLAA #02. 2014.03.05
*             MOVE LW_ANALITIKA_PTG-XBLNR TO W_OUTTAB-FIELD_C.
               MOVE LW_ANALITIKA_PTG-STCD1 TO W_OUTTAB-FIELD_C.
*--PTGSZLAA #02. 2014.03.05
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Customer name
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'E' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-ZKUNNAME TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Buyer's address
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'F' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-ZKUNADRS TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          VAT amount
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'G' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-WAERS.
               MOVE LW_ANALITIKA_PTG-FWSTE TO W_OUTTAB-FIELD_N.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Currency
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'H' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-WAERS.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Gross amount
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'I' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-WAERS.
               MOVE LW_ANALITIKA_PTG-FWBTR TO W_OUTTAB-FIELD_N.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
             CONCATENATE LW_ANALITIKA_PTG-LIFKUN
                         LW_ANALITIKA_PTG-SZAMLAKELT
                    INTO L_STRING_SAVE.
             ADD 1 TO L_SORSZ.
*++PTGSZLAH #01. 2015.01.16
           ELSEIF P_BTYPE EQ C_BTYPE_PTGSZLAH.
*          Invoice issue date
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB001A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZAMLAKELT TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash pick-up location name
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB005A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-NAME1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Postal code of cash collection location
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB007A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-POST_CODE1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          City of cash collection
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB008A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-CITY1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Name of public area of ​​cash collection location
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB009A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-STREET TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          The nature of the cash collection place as a public area
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB010A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-HOUSE_NUM2 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash pick-up location house number
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB011A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-HOUSE_NUM1 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk building
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB012A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-BUILDING TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk stairwell
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB013A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-HOUSE_NUM3 TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk floor
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB014A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-FLOOR TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Cash desk door
             M_GET_PTG_ABEV_TO_OUTTAB SPACE SPACE L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON 'M0BB015A'.
             IF SY-SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ADDR1_VAL-ROOMNUMBER TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Account number
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'A' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZAMLASZ TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Account type
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'B' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZLATIP TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          History account number
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'C' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-SZAMLASZE TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
** Buyer's tax identification number
*             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'D' L_SUBRC
*               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
*             IF L_SUBRC IS INITIAL.
*               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
**             MOVE LW_ANALITIKA_PTG-XBLNR TO W_OUTTAB-FIELD_C.
*               MOVE LW_ANALITIKA_PTG-STCD1 TO W_OUTTAB-FIELD_C.
*               APPEND W_OUTTAB TO I_OUTTAB.
*               CLEAR W_OUTTAB.
*             ENDIF.
*          Customer name
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'D' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-ZKUNNAME TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Buyer's address
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'E' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-ZKUNADRS TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Currency
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'F' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-WAERS.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-FIELD_C.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
*          Gross amount
             M_GET_PTG_ABEV_TO_OUTTAB L_SORSZ 'G' L_SUBRC
               W_/ZAK/BNYLAP-NYLAPAZON SPACE.
             IF L_SUBRC IS INITIAL.
               MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
               MOVE LW_ANALITIKA_PTG-FWAERS TO W_OUTTAB-WAERS.
               MOVE LW_ANALITIKA_PTG-FWBTR TO W_OUTTAB-FIELD_N.
               APPEND W_OUTTAB TO I_OUTTAB.
               CLEAR W_OUTTAB.
             ENDIF.
             CONCATENATE LW_ANALITIKA_PTG-LIFKUN
                         LW_ANALITIKA_PTG-SZAMLAKELT
                    INTO L_STRING_SAVE.
             ADD 1 TO L_SORSZ.
           ENDIF.
*--PTGSZLAH #01. 2015.01.16
         ENDLOOP.
         MOVE L_LAPSZ TO V_LAPSZ.
       ENDIF.
*--PTGSZLAA #01. 2014.03.03
     ENDIF. "C_BTYPART_ONYB
*--0004 BG 2007.04.04
     DATA: L_ROUND(20) TYPE C.
     PERFORM PROCESS_IND USING TEXT-P03.
     LOOP AT I_OUTTAB INTO W_OUTTAB.
* Amount conversions
       CLEAR L_ROUND.
       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = W_OUTTAB-BTYPE
                   ABEVAZ = W_OUTTAB-ABEVAZ.
       IF SY-SUBRC = 0.
         W_OUTTAB-ROUND = W_/ZAK/BEVALLB-ROUND.
*++1465 #04.
**       if not w_/zak/bevallb-round is initial.
*         WRITE W_OUTTAB-FIELD_N TO L_ROUND
*             ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.
*
*
*         REPLACE ',' WITH '.' INTO L_ROUND.
*         W_OUTTAB-FIELD_NR = L_ROUND.
*
*         W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
*                              ( 10 ** W_/ZAK/BEVALLB-ROUND ).
**       endif.
         PERFORM CALC_FIELD_NRK USING W_OUTTAB-FIELD_N
                                    W_OUTTAB-ROUND
                                    C_HUF
                           CHANGING W_OUTTAB-FIELD_NR
                                    W_OUTTAB-FIELD_NRK.
*--1465 #04.
*++0003 BG 2007.01.31
*        The due date must be taken from the selection for self-revision
         IF P_O = C_X AND W_/ZAK/BEVALLB-ESDAT_FLAG = C_X.
           MOVE P_ESDAT TO W_OUTTAB-FIELD_C.
         ENDIF.
*--0003 BG 2007.01.31
         MODIFY I_OUTTAB FROM W_OUTTAB.
       ENDIF.
     ENDLOOP.
   ELSE.
* Show closed period
     DATA: V_INDEX LIKE SY-TABIX.
     SELECT * INTO CORRESPONDING FIELDS OF TABLE I_OUTTAB
        FROM  /ZAK/BEVALLO
            WHERE  BUKRS    = P_BUKRS
            AND    BTYPE    = P_BTYPE
            AND    GJAHR    = S_GJAHR-LOW
            AND    MONAT    = S_MONAT-LOW
            AND    ZINDEX   = S_INDEX-HIGH.
     LOOP AT I_OUTTAB INTO W_OUTTAB.
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
*++0016 BG 2011.09.26
*           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'BUK' FIELD S_OUT-FI_BUKRS.
*--0016 BG 2011.09.26
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
*++0016 BG 2011.09.26
*           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'BUK' FIELD S_OUT-FI_BUKRS.
*--0016 BG 2011.09.26
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
*++1665 #10.
   DATA: S_FCAT TYPE LVC_S_FCAT.
*--1665 #10.
   CREATE OBJECT V_CUSTOM_CONTAINER2
     EXPORTING
       CONTAINER_NAME = V_CONTAINER2.
   CREATE OBJECT V_GRID2
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER2.
* Assemble field catalog
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING PT_FIELDCAT.
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
*++1665 #10.
*      I_READY_FOR_INPUT = 1.
       I_READY_FOR_INPUT = 0.
*--1665 #10.
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
* Back
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
   SELECT SINGLE ABEVTEXT INTO /ZAK/ANALITIKA_S-ABEVTEXT FROM
   /ZAK/BEVALLBT
                                                 WHERE  LANGU   =
                                                 SY-LANGU
                                    AND    BTYPE   =
                                    /ZAK/ANALITIKA_S-BTYPE
                                   AND    ABEVAZ  =
                                   /ZAK/ANALITIKA_S-ABEVAZ.
* Data supply
   SELECT SINGLE SZTEXT INTO /ZAK/ANALITIKA_S-SZTEXT FROM  /ZAK/BEVALLDT
          WHERE  LANGU   = SY-LANGU
          AND    BUKRS   = /ZAK/ANALITIKA_S-BUKRS
          AND    BTYPE   = /ZAK/ANALITIKA_S-BTYPE
          AND    BSZNUM  = /ZAK/ANALITIKA_S-BSZNUM.
*++0017 BG 2012.02.07
*Load data for counter-entry posting
   IF /ZAK/ANAL_MS IS INITIAL.
     MOVE-CORRESPONDING /ZAK/ANALITIKA_S TO /ZAK/ANAL_MS.
   ENDIF.
*--0017 BG 2012.02.07
 ENDFORM.                                                   " init_9100
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9100 INPUT.
*++0017 BG 2012.02.07
   DATA: L_ITEM LIKE /ZAK/ANALITIKA-ITEM.
   DEFINE LM_NEXT_ITEM.
     CLEAR /zak/analitika.
* Last item number
     SELECT MAX( item ) INTO l_item FROM /zak/analitika
        WHERE bukrs   = &1-bukrs
          AND btype   = &1-btype
          AND gjahr   = &1-gjahr
          AND monat   = &1-monat
          AND zindex  = &1-zindex
          AND abevaz  = &1-abevaz
          AND adoazon = &1-adoazon
          AND bsznum  = &1-bsznum
          AND pack    = &1-pack.
     l_item = l_item + 1.
     MOVE-CORRESPONDING &1 TO /zak/analitika.
     /zak/analitika-xmanu = c_x.
     /zak/analitika-item  = l_item.
   END-OF-DEFINITION.
*--0017 BG 2012.02.07
*++BG 2009.11.26
*  get position
   LS_STABLE-ROW = 'X'.
   LS_STABLE-COL = 'X'.
*--BG 2009.11.26
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'SAVE'.
*++0008 BG 2007.08.06
* Confirmation: are you sure you want to save?
       PERFORM ARE_U_SURE  USING 'Menti a rögzített adatokat?'(900)
*--0008 BG 2007.08.06
                         CHANGING V_ANSWER.
       CHECK V_ANSWER = '1'.
*++0017 BG 2012.02.07
*       PERFORM GET_NEXT_ITEM USING /ZAK/ANALITIKA_S
*                             CHANGING /ZAK/ANALITIKA.
       LM_NEXT_ITEM /ZAK/ANALITIKA_S.
*--0017 BG 2012.02.07
       IF NOT /ZAK/ANALITIKA IS INITIAL.
         PERFORM SAVE_ITEM.
*        perform read_analitika.
         IF V_DYNNR = '9002'.
           CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
         ELSE.
           CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY
*++BG 2009.11.26
             EXPORTING
               IS_STABLE = LS_STABLE.
*--BG 2009.11.26
         ENDIF.
       ENDIF.
*++0017 BG 2012.02.07
*   Posting the counter-entry
       IF NOT /ZAK/ANAL_MS-MSFLAG IS INITIAL.
         LM_NEXT_ITEM /ZAK/ANAL_MS.
         /ZAK/ANALITIKA-FIELD_N  = -1 * /ZAK/ANALITIKA_S-FIELD_N.
         /ZAK/ANALITIKA-ZCOMMENT = /ZAK/ANALITIKA_S-ZCOMMENT.
         IF NOT /ZAK/ANALITIKA IS INITIAL.
           PERFORM SAVE_ITEM_MS.
         ENDIF.
       ENDIF.
*--0017 BG 2012.02.07
       SET SCREEN 0.
       LEAVE SCREEN.
     WHEN 'BACK'.
* Confirmation: exit without saving?
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
*++1465 #08.
   DATA  L_TABIX LIKE SY-TABIX.
*--1465 #08.
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
* Numeric specifics
* Create reversal item for next period with opposite sign
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
* Character-specific behavior
* Date
* Special handling of XDEFT - if it was set in the manual item here,
* then this field must be cleared from all the others.
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
*++1465 #14.
                 PERFORM CALC_FIELD_NRK USING W_OUTTAB-FIELD_N
                                            W_/ZAK/BEVALLB-ROUND
                                            C_HUF
                                   CHANGING W_OUTTAB-FIELD_NR
                                            W_OUTTAB-FIELD_NRK.
*--1465 #14.
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
*++1465 #08.
                 L_TABIX = SY-TABIX.
*--1465 #08.
*++1465 #04.
*                 WRITE W_OUTTAB-FIELD_N TO L_ROUND
*                     ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.
*
*                 REPLACE ',' WITH '.' INTO L_ROUND.
*                 W_OUTTAB-FIELD_NR = L_ROUND.
*
*                 W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
*                                      ( 10 ** W_/ZAK/BEVALLB-ROUND ).
                 PERFORM CALC_FIELD_NRK USING W_OUTTAB-FIELD_N
                                            W_/ZAK/BEVALLB-ROUND
                                            C_HUF
                                   CHANGING W_OUTTAB-FIELD_NR
                                            W_OUTTAB-FIELD_NRK.
*--1465 #04.
*++1465 #08.
*                 MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
                 MODIFY I_OUTTAB FROM W_OUTTAB INDEX L_TABIX.
*--1465 #08.
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
*++1465 #04.
**       if not w_/zak/bevallb-round is initial.
*                 WRITE W_OUTTAB-FIELD_N TO L_ROUND
*                     ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.
*
*
*                 REPLACE ',' WITH '.' INTO L_ROUND.
*                 W_OUTTAB-FIELD_NR = L_ROUND.
*
*                 W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
*                                      ( 10 ** W_/ZAK/BEVALLB-ROUND ).
                 PERFORM CALC_FIELD_NRK USING W_OUTTAB-FIELD_N
                                            W_OUTTAB-ROUND
                                            C_HUF
                                   CHANGING W_OUTTAB-FIELD_NR
                                            W_OUTTAB-FIELD_NRK.
*--1465 #04.
                 COLLECT W_OUTTAB INTO I_OUTTAB_L.
               ENDIF.
             ENDIF.
           ENDIF.
         ENDIF.
       ENDIF.
     ENDLOOP.
   ENDIF.
* Recalculate totals for sum fields
   IF P_M <> C_X.
     PERFORM CALL_EXIT.
   ENDIF.
* If the return was already downloaded > reset the status
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
   SELECT SINGLE ABEVTEXT INTO /ZAK/ANALITIKA_S-ABEVTEXT FROM
   /ZAK/BEVALLBT
                                                 WHERE  LANGU   =
                                                 SY-LANGU
                                    AND    BTYPE   =
                                    /ZAK/ANALITIKA_S-BTYPE
                                   AND    ABEVAZ  =
                                   /ZAK/ANALITIKA_S-ABEVAZ.
* Data supply
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
*++BG 2009.11.26
*    get position
   LS_STABLE-ROW = 'X'.
   LS_STABLE-COL = 'X'.
*--BG 2009.11.26
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'SAVE'.
* Confirmation: are you sure you want to save?
*++0008 BG 2007.08.06
       PERFORM ARE_U_SURE USING 'Menti a rögzített adatokat?'(900)
*--0008 BG 2007.08.06
                       CHANGING V_ANSWER.
       CHECK V_ANSWER = '1'.
       PERFORM GET_NEXT_ITEM USING /ZAK/ANALITIKA_S
                             CHANGING /ZAK/ANALITIKA.
       IF NOT /ZAK/ANALITIKA IS INITIAL.
         PERFORM SAVE_ITEM.
*         perform read_analitika.
         IF V_DYNNR = '9002'.
           CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
         ELSE.
           CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY
*++BG 2009.11.26
             EXPORTING
               IS_STABLE = LS_STABLE.
*--BG 2009.11.26
         ENDIF.
       ENDIF.
       SET SCREEN 0.
       LEAVE SCREEN.
     WHEN 'BACK'.
* Confirmation: exit without saving?
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
*++PTGSZLAA #01. 2014.03.03
*++PTGSZLAH #01. 2015.01.16
*                                        P_BTART
                                      $BTYPE
*--PTGSZLAH #01. 2015.01.16
*--PTGSZLAA #01. 2014.03.03
                              CHANGING V_LAST_DATE.
   DATA: L_DATE1 TYPE DATUM,
         L_DATE2 TYPE DATUM.
*++PTGSZLAA #01. 2014.03.03
   DATA: L_WEEK TYPE KWEEK.
*--PTGSZLAA #01. 2014.03.03
   CLEAR V_LAST_DATE.
*++PTGSZLAA #01. 2014.03.03
*++PTGSZLAH #01. 2015.01.16
*   IF $BTART EQ C_BTYPART_PTG.
   IF $BTYPE EQ C_BTYPE_PTGSZLAA.
*--PTGSZLAH #01. 2015.01.16
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
*--PTGSZLAA #01. 2014.03.03
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
*++PTGSZLAA #01. 2014.03.03
   ENDIF.
*--PTGSZLAA #01. 2014.03.03
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
*++1865 #14.
*   SELECT * INTO TABLE I_/ZAK/BEVALL FROM  /ZAK/BEVALL
*       WHERE     BUKRS  = P_BUKRS
*          AND    BTYPART = P_BTART
*          AND    DATBI  >= V_LAST_DATE.
*   READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
*      WITH KEY BUKRS = P_BUKRS
*               BTYPE = P_BTYPE.
   SELECT SINGLE * INTO W_/ZAK/BEVALL
                   FROM /ZAK/BEVALL
        WHERE    BUKRS  = P_BUKRS
          AND    BTYPE  = P_BTYPE
          AND    DATBI  >= V_LAST_DATE
          AND    DATAB  <= V_LAST_DATE.
*--1865 #14.
*++2165 #10.
   CLEAR W_/ZAK/START.
   SELECT SINGLE * INTO W_/ZAK/START
                   FROM /ZAK/START
                  WHERE BUKRS EQ P_BUKRS.
*--2165 #10.
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
* Check data supply
   DATA: V_EXIT.
   CHECK NOT S_GJAHR IS INITIAL AND
         NOT S_MONAT IS INITIAL AND
         NOT S_INDEX IS INITIAL.
* Required data supplies
   SELECT * INTO TABLE I_/ZAK/BEVALLD
     FROM /ZAK/BEVALLD
      WHERE BUKRS = P_BUKRS
        AND BTYPE = P_BTYPE
        AND XSPEC = SPACE.
   IF P_FLAG = 'S'.   " Check on selection screen
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
* 1. Are all data supplies in F/E status
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
   ELSE.            " During download
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
* 1. Are all data supplies in F/E status
             LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
               WHERE FLAG <> 'F'
                 AND FLAG <> 'E'
                 AND FLAG <> 'B'.
               IF P_N = C_X.
                 IF W_/ZAK/BEVALLSZ-FLAG = 'T'.
                   MESSAGE W045(/ZAK/ZAK).
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
*++0004 BG 2007.04.04
   DATA L_TEXT(10).
*--0004 BG 2007.04.04
* Form lines
* 1. sor
   CLEAR W_FILE.
   W_FILE-LINE = '$ny_azon'.
   W_FILE-OP   = '='.
*----- VAT
*++0015 0965 2009.02.02 BG
*  IF P_BTART = C_BTYPART_AFA.
   IF P_BTART = C_BTYPART_AFA AND P_BTYPE = C_0865.
*--0015 0965 2009.02.02 BG
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
*++0004 BG 2007.04.04
*++0005 BG 2007.05.30
*  IF P_BTART NE C_BTYPART_ONYB.
   IF  P_BTART NE C_BTYPART_ONYB  AND  V_NYLAPAZON IS INITIAL.
*--0005 BG 2007.05.30
*--0004 BG 2007.04.04
* 2. sor
     V_COUNTER = V_COUNTER + 4.  " Standard lines must also be counted
*++0004 BG 2007.04.04
   ELSE.
*++0012 BG 2008.04.02
     IF P_BTART EQ C_BTYPART_AFA.
       V_COUNTER = V_COUNTER + 5.  " Standard lines must also be counted
     ELSEIF P_BTART EQ C_BTYPART_ONYB.
       V_COUNTER = V_COUNTER + 6.  " Standard lines must also be counted
     ENDIF.
*--0012 BG 2008.04.02
   ENDIF.
*--0004 BG 2007.04.04
   CLEAR W_FILE.
   W_FILE-LINE = '$sorok_száma'.
   W_FILE-OP   = '='.
   WRITE V_COUNTER TO W_FILE-VAL LEFT-JUSTIFIED
                                 NO-GROUPING.    "2010.03.18 BG (Ness)
   CONCATENATE W_FILE-LINE
               W_FILE-OP
               W_FILE-VAL
               INTO I_FILE-LINE.
   INSERT I_FILE INDEX 2.
*++0004 BG 2007.04.04
*++0005 BG 2007.05.30
*  IF P_BTART NE C_BTYPART_ONYB.
   IF P_BTART NE C_BTYPART_ONYB AND V_NYLAPAZON IS INITIAL.
*--0005 BG 2007.05.30
*--0004 BG 2007.04.04
* 3. SOR
     CLEAR W_FILE.
     W_FILE-LINE = '$d_lapok_száma'.
     W_FILE-OP   = '='.
     W_FILE-VAL  = '0'.
*++0004 BG 2007.04.04
   ELSE.
* 3. SOR
     CLEAR W_FILE.
     W_FILE-LINE = '$d_lapok_száma'.
     W_FILE-OP   = '='.
*++0012 BG 2008.04.02
     IF P_BTART EQ C_BTYPART_AFA.
       W_FILE-VAL  = '1'.
     ELSEIF P_BTART EQ C_BTYPART_ONYB.
       W_FILE-VAL  = '2'.
     ENDIF.
*--0012 BG 2008.04.02
   ENDIF.
*--0004 BG 2007.04.04
   CONCATENATE W_FILE-LINE
               W_FILE-OP
               W_FILE-VAL
               INTO I_FILE-LINE.
   INSERT I_FILE INDEX 3.
*++0004 BG 2007.04.04
*++0005 BG 2007.05.30
*  IF P_BTART NE C_BTYPART_ONYB.
   IF P_BTART NE C_BTYPART_ONYB AND V_NYLAPAZON IS INITIAL.
*--0005 BG 2007.05.30
*--0004 BG 2007.04.04
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
*++0004 BG 2007.04.04
   ELSE.
* 4. sor
     CLEAR W_FILE.
     W_FILE-LINE = '$d_lap1'.
     W_FILE-OP   = '='.
*++0012 BG 2008.04.02
     IF P_BTART EQ C_BTYPART_ONYB.
       READ TABLE I_NYLAPAZON INTO W_NYLAPAZON
            WITH KEY NYLAPAZON = '01'.
       MOVE W_NYLAPAZON-LAPSZ TO L_TEXT.
     ELSEIF P_BTART EQ C_BTYPART_AFA.
       MOVE V_LAPSZ TO L_TEXT.
     ENDIF.
*--0012 BG 2008.04.02
     CONDENSE L_TEXT.
*++0005 BG 2007.05.30
     IF P_BTART EQ C_BTYPART_ONYB.
*--0005 BG 2007.05.30
       CONCATENATE V_DISP_BTYPE '-' '01' ',' L_TEXT INTO W_FILE-VAL.
*++0005 BG 2007.05.30
     ELSEIF P_BTART EQ C_BTYPART_AFA AND NOT  V_NYLAPAZON IS INITIAL.
       CONCATENATE V_NYLAPAZON L_TEXT INTO W_FILE-VAL SEPARATED BY ','.
     ENDIF.
*--0005 BG 2007.05.30
     CONCATENATE W_FILE-LINE
                 W_FILE-OP
                 W_FILE-VAL
                 INTO I_FILE-LINE.
     INSERT I_FILE INDEX 4.
*++0012 BG 2008.04.02
     IF P_BTART EQ C_BTYPART_ONYB.
* 5. sor
       CLEAR W_FILE.
       W_FILE-LINE = '$d_lap2'.
       W_FILE-OP   = '='.
       READ TABLE I_NYLAPAZON INTO W_NYLAPAZON
            WITH KEY NYLAPAZON = '02'.
       MOVE W_NYLAPAZON-LAPSZ TO L_TEXT.
*    MOVE V_LAPSZ TO L_TEXT.
       CONDENSE L_TEXT.
       CONCATENATE V_DISP_BTYPE '-' '02' ',' L_TEXT INTO W_FILE-VAL.
       CONCATENATE W_FILE-LINE
                   W_FILE-OP
                   W_FILE-VAL
                   INTO I_FILE-LINE.
       INSERT I_FILE INDEX 5.
* 6. sor
       CLEAR W_FILE.
       W_FILE-LINE = '$info'.
       W_FILE-OP   = '='.
       W_FILE-VAL  = TEXT-INF.
       CONCATENATE W_FILE-LINE
                   W_FILE-OP
                   W_FILE-VAL
                   INTO I_FILE-LINE.
       INSERT I_FILE INDEX 6.
     ELSE.
* 5. sor
       CLEAR W_FILE.
       W_FILE-LINE = '$info'.
       W_FILE-OP   = '='.
       W_FILE-VAL  = TEXT-INF.
       CONCATENATE W_FILE-LINE
                   W_FILE-OP
                   W_FILE-VAL
                   INTO I_FILE-LINE.
       INSERT I_FILE INDEX 5.
     ENDIF.
*--0012 BG 2008.04.02
   ENDIF.
*--0004 BG 2007.04.04
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
*++BG 2007.02.16
   DATA LI_/ZAK/BEVALLB_SAVE TYPE STANDARD TABLE OF /ZAK/BEVALLB INITIAL
   SIZE 0.
*++0004 BG 2007.04.04
   DATA L_LAPSZ TYPE I.
*--0004 BG 2007.04.04
*++0005 BG 2007.06.12
   REFRESH I_FILE. CLEAR W_FILE. CLEAR V_COUNTER.
*--0005 BG 2007.06.12
*  BEVALLB must follow the display if it differs
   READ TABLE I_OUTTAB_C INTO W_OUTTAB_C INDEX 1.
   IF W_OUTTAB_C-BTYPE NE W_OUTTAB_C-BTYPE_DISP.
     LI_/ZAK/BEVALLB_SAVE[] = I_/ZAK/BEVALLB[].
     REFRESH I_/ZAK/BEVALLB.
     SELECT * INTO TABLE I_/ZAK/BEVALLB
              FROM /ZAK/BEVALLB
             WHERE BTYPE = W_OUTTAB_C-BTYPE_DISP.
   ENDIF.
*--BG 2007.02.16
   LOOP AT I_OUTTAB_C INTO W_OUTTAB_C.
*++BG 2007.02.16
*     READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
*       WITH KEY BTYPE  = W_OUTTAB_C-BTYPE
*                ABEVAZ = W_OUTTAB_C-ABEVAZ.
     READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_OUTTAB_C-BTYPE_DISP
                ABEVAZ = W_OUTTAB_C-ABEVAZ_DISP.
*--BG 2007.02.16
* Summary rows must not be downloaded
     IF SY-SUBRC = 0.
       IF W_/ZAK/BEVALLB-ABEV_NO = C_X.
         CONTINUE.
       ENDIF.
* Check due date during self-revision
       IF P_O = C_X.
         IF W_/ZAK/BEVALLB-ESDAT_FLAG = C_X.
*++BG 2007.02.16
*Loaded from the selection screen.
           W_OUTTAB_C-FIELD_C = P_ESDAT.
*           IF W_OUTTAB_C-FIELD_C IS INITIAL.
*             MESSAGE E158(/ZAK/ZAK) WITH W_OUTTAB_C-ABEVAZ.
*             EXIT.
*
*           ELSE.
** Need to read back from analytics to know from which index it originates
** the value
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
*                WITH KEY ZINDEX = W_OUTTAB_C-ZINDEX.
**++BG 2006/05/29
** Due to warning error!!!!
**               TRANSPORTING NO FIELDS.
**--BG 2006/05/29
*             IF SY-SUBRC NE 0.
*               MESSAGE E158(/ZAK/ZAK) WITH W_OUTTAB_C-ABEVAZ.
*               EXIT.
*             ENDIF.
*
*           ENDIF.
*--BG 2007.02.16
         ENDIF.
       ENDIF.
* Identifiers with empty values are not needed either
*++BG 2009.05.18
*       IF W_OUTTAB_C-FIELD_NR IS INITIAL AND
*          W_OUTTAB_C-FIELD_C IS INITIAL.
       IF ( W_OUTTAB_C-FIELD_NR  IS INITIAL AND
            W_OUTTAB_C-NULL_FLAG IS INITIAL )
          AND W_OUTTAB_C-FIELD_C IS INITIAL.
*--BG 2009.05.18
         CONTINUE.
       ENDIF.
       V_COUNTER = V_COUNTER + 1.
* Form lines
       DATA: L_TEXT(20).
       CLEAR W_FILE.
*++0004 BG 2007.04.04
       MOVE W_OUTTAB_C-LAPSZ TO L_LAPSZ.
       MOVE L_LAPSZ TO L_TEXT.
       CONDENSE L_TEXT.
*++0005 BG 2007.05.30
*       IF P_BTART EQ C_BTYPART_ONYB AND
*          NOT W_/ZAK/BEVALLB-SORINDEX IS INITIAL.
       IF  NOT W_/ZAK/BEVALLB-SORINDEX IS INITIAL AND
       W_/ZAK/BEVALLB-SORINDEX NE '0'
*++ BG 2007.08.31
           AND P_BTART NE C_BTYPART_ATV.
*-- BG 2007.08.31
*--0005 BG 2007.05.30
         CONCATENATE W_OUTTAB_C-ABEVAZ_DISP
                     '['
                      L_TEXT
                     ']' INTO W_FILE-LINE.
       ELSE.
*--0004 BG 2007.04.04
*++BG 2007.02.16
*      W_FILE-LINE = W_OUTTAB_C-ABEVAZ.
         W_FILE-LINE = W_OUTTAB_C-ABEVAZ_DISP.
*--BG 2007.02.16
*++0004 BG 2007.04.04
       ENDIF.
       CLEAR L_TEXT.
*--0004 BG 2007.04.04
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
*++BG 2007.02.16
   IF NOT LI_/ZAK/BEVALLB_SAVE[] IS INITIAL.
     I_/ZAK/BEVALLB[] = LI_/ZAK/BEVALLB_SAVE[].
     FREE LI_/ZAK/BEVALLB_SAVE.
   ENDIF.
*--BG 2007.02.16
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
*++0001 2007.01.03 BG (FMC)
*        L_FILENAME LIKE RLGRAP-FILENAME,
         L_FILENAME     TYPE STRING,
*--0001 2007.01.03 BG (FMC)
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
   ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_SZJA.
     CONCATENATE L_DEF_FILENAME '.XML' INTO L_DEF_FILENAME.
     L_FILTER = '*.XML'.
*++1365 2013.01.10 Balázs Gábor (Ness)
   ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_AFA AND NOT
   W_/ZAK/BEVALL-OMREL IS INITIAL.
     CONCATENATE L_DEF_FILENAME '.XML' INTO L_DEF_FILENAME.
     L_FILTER = '*.XML'.
*--1365 2013.01.10 Balázs Gábor (Ness)
*++14A60 #01. 2014.02.04 Balázs Gábor (Ness)
   ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_ONYB AND NOT
   W_/ZAK/BEVALL-STRANS IS INITIAL.
     CONCATENATE L_DEF_FILENAME '.XML' INTO L_DEF_FILENAME.
     L_FILTER = '*.XML'.
*--14A60 #01. 2014.02.04 Balázs Gábor (Ness)
*++PTGSZLAA #01. 2014.03.03
   ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_PTG AND NOT
   W_/ZAK/BEVALL-STRANS IS INITIAL.
     CONCATENATE L_DEF_FILENAME '.XML' INTO L_DEF_FILENAME.
     L_FILTER = '*.XML'.
*--PTGSZLAA #01. 2014.03.03
   ELSE.
     CONCATENATE L_DEF_FILENAME '.IMP' INTO L_DEF_FILENAME.
     L_FILTER = '*.IMP'.
   ENDIF.
* ++ 0001 CST 2006.05.27
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
*++1665 #01.
*     L_FULLPATH = L_FILENAME.
*++1665 #01.
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
*++1365 2013.01.10 Balázs Gábor (Ness)
* VAT XML
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_AFA AND
        NOT W_/ZAK/BEVALL-OMREL IS INITIAL.
*      Create XML
       CALL FUNCTION '/ZAK/AFA_XML_DOWNLOAD'
         EXPORTING
           I_FILE            = L_FULLPATH
*          I_GJAHR           =
*          I_MONAT           =
         TABLES
           T_/ZAK/BEVALLALV = I_OUTTAB_C
         EXCEPTIONS
           ERROR             = 1
           ERROR_DOWNLOAD    = 2
           OTHERS            = 3.
       IF SY-SUBRC <> 0.
* Implement suitable error handling here
         L_SUBRC = SY-SUBRC.
         MESSAGE E352(/ZAK/ZAK) WITH SY-SUBRC.
*        Error during XML conversion! (&)
       ELSE.
         MESSAGE I009(/ZAK/ZAK) WITH L_FILENAME.
         L_SUBRC = 0.
       ENDIF.
*--1365 2013.01.10 Balázs Gábor (Ness)
*++14A60 #01. 2014.02.04 Balázs Gábor (Ness)
*   ONYB XML
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_ONYB AND
        NOT W_/ZAK/BEVALL-STRANS IS INITIAL.
*      Create XML
       CALL FUNCTION '/ZAK/ONYB_XML_DOWNLOAD'
         EXPORTING
           I_FILE            = L_FULLPATH
*          I_GJAHR           =
*          I_MONAT           =
         TABLES
           T_/ZAK/BEVALLALV = I_OUTTAB_C
         EXCEPTIONS
           ERROR             = 1
           ERROR_DOWNLOAD    = 2
           OTHERS            = 3.
       IF SY-SUBRC <> 0.
* Implement suitable error handling here
         L_SUBRC = SY-SUBRC.
         MESSAGE E352(/ZAK/ZAK) WITH SY-SUBRC.
*        Error during XML conversion! (&)
       ELSE.
         MESSAGE I009(/ZAK/ZAK) WITH L_FILENAME.
         L_SUBRC = 0.
       ENDIF.
*--14A60 #01. 2014.02.04 Balázs Gábor (Ness)
*++PTGSZLAA #01. 2014.03.03
*  PTG XML
     ELSEIF W_/ZAK/BEVALL-BTYPART = C_BTYPART_PTG AND
        NOT W_/ZAK/BEVALL-STRANS IS INITIAL.
*      Create XML
       CALL FUNCTION '/ZAK/PTG_XML_DOWNLOAD'
         EXPORTING
           I_FILE            = L_FULLPATH
*          I_GJAHR           =
*          I_MONAT           =
         TABLES
           T_/ZAK/BEVALLALV = I_OUTTAB_C
         EXCEPTIONS
           ERROR             = 1
           ERROR_DOWNLOAD    = 2
           OTHERS            = 3.
       IF SY-SUBRC <> 0.
* Implement suitable error handling here
         L_SUBRC = SY-SUBRC.
         MESSAGE E352(/ZAK/ZAK) WITH SY-SUBRC.
*        Error during XML conversion! (&)
       ELSE.
         MESSAGE I009(/ZAK/ZAK) WITH L_FILENAME.
         L_SUBRC = 0.
       ENDIF.
*--PTGSZLAA #01. 2014.03.03
     ELSE.
*++0002 2007.01.03 BG (FMC)
* ++ 0001  CST 2006.05.27
       CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
         EXPORTING
           FILENAME                = L_FULLPATH
*++1765 #12.
           CODEPAGE                = '1404'
*--1765 #12.
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
**           FILEMASK_ALL            = 'X'
*                 FILETYPE_NO_CHANGE      = 'X'
**           FILEMASK_ALL            = ' '
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
*--0002 2007.01.03 BG (FMC)
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
*++1365 #21.
*FORM UPDATE_BEVALLO CHANGING L_SUBRC.
 FORM UPDATE_BEVALLO  TABLES  $I_OUTTAB STRUCTURE /ZAK/BEVALLALV
                      CHANGING L_SUBRC.
*--1365 #21.
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
*++1365 #21.
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
*++1365 #23.
*     DELETE $I_OUTTAB.
*--1365 #23.
   ENDLOOP.
*++1365 #23.
*   FREE $I_OUTTAB.
*--1365 #23.
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
*--1365 #21.
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
*++1365 #21.
   DATA LI_AFA_SZLA_SUM TYPE STANDARD TABLE OF /ZAK/AFA_SZLASUM .
*--1365 #21.
   IF V_DYNNR = '9002'.
     CALL FUNCTION '/ZAK/MAIN_EXIT'
       EXPORTING
         I_BUKRS   = P_BUKRS
         I_BTYPE   = P_BTYPE
         I_GJAHR   = S_GJAHR-LOW
         I_MONAT   = S_MONAT-LOW
         I_INDEX   = S_INDEX-HIGH
       TABLES
         T_BEVALLO = I_OUTTAB_L.
   ELSE.
*++1365 #21.
     LI_AFA_SZLA_SUM[] = I_AFA_SZLA_SUM[].
     FREE I_AFA_SZLA_SUM.
*--1365 #21.
     CALL FUNCTION '/ZAK/MAIN_EXIT'
       EXPORTING
         I_BUKRS        = P_BUKRS
         I_BTYPE        = P_BTYPE
         I_GJAHR        = S_GJAHR-LOW
         I_MONAT        = S_MONAT-LOW
         I_INDEX        = S_INDEX-HIGH
       TABLES
         T_BEVALLO      = I_OUTTAB
*++1365 2013.01.22 Balázs Gábor (Ness)
         T_ADOAZON      = I_ADOAZON
*++1365 #21.
*        t_afa_szla_sum = i_afa_szla_sum
         T_AFA_SZLA_SUM = LI_AFA_SZLA_SUM.
     I_AFA_SZLA_SUM[] = LI_AFA_SZLA_SUM[].
     FREE LI_AFA_SZLA_SUM.
*--1365 #21.
*--1365 2013.01.22 Balázs Gábor (Ness)
     .
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
* 'XDEFT' column is editable if it is character-based
   IF P_MODE EQ 'RW'.
     L_MODE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
   ELSE. "p_mode eq 'RO'
     L_MODE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
   ENDIF.
* Configure fields
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
*++1465 #01. 2014.01.16 Required for background run because otherwise
*                  the INDEX parameter is not taken over
     READ TABLE S_INDEX2 INDEX 1.
*--1465 #01. 2014.01.16
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
*++1465 #01. 2014.01.16 Required for background run because otherwise
*                  the INDEX parameter is not taken over
     READ TABLE S_INDEX3 INDEX 1.
*--1465 #01. 2014.01.16
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
* Check whether it is newer
   LOOP AT I_/ZAK/BEVALL INTO V_BEVALL.
     IF V_BEVALL-DATBI >= L_DATUM.
       APPEND V_BEVALL TO I_POPUP.
     ENDIF.
   ENDLOOP.
* Popup is only needed if there are multiple options
   DESCRIBE TABLE I_POPUP LINES SY-TFILL.
   IF SY-TFILL > 1.
     LOOP AT I_POPUP INTO V_BEVALL.
       CLEAR T_SPOPLI.
       T_SPOPLI-VAROPTION = V_BEVALL-BTYPE.
*++BG 2007.08.06
*  We aggregate with COLLECT because if we split a type
*  into two parts then the popup appears with the same
*  type.
*      APPEND T_SPOPLI.
       COLLECT T_SPOPLI.
*--BG 2007.08.06
     ENDLOOP.
*++BG 2007.08.06
     DESCRIBE TABLE T_SPOPLI LINES SY-TFILL.
     IF SY-TFILL > 1.
*--BG 2007.08.06
       CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
         EXPORTING
*          CURSORLINE         = 1
*          MARK_FLAG          = ' '
           MARK_MAX           = 1
           START_COL          = 15
           START_ROW          = 10
           TEXTLINE1          = TEXT-T10
*          TEXTLINE2          = ' '
*          TEXTLINE3          = ' '
           TITEL              = TEXT-T11
*          DISPLAY_ONLY       = ' '
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
 FORM BTYPE_CONVERSION TABLES   I_OUTTAB STRUCTURE /ZAK/BEVALLALV
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
*++BG 2007.02.16
*     IF  W_OUTTAB_C-BTYPE_DISP  NE W_OUTTAB_C-BTYPE
*      OR W_OUTTAB_C-ABEVAZ_DISP NE W_OUTTAB_C-ABEVAZ.
*       W_OUTTAB_C-BTYPE  = W_OUTTAB_C-BTYPE_DISP.
*       W_OUTTAB_C-ABEVAZ = W_OUTTAB_C-ABEVAZ_DISP.
*
*     ENDIF.
*--BG 2007.02.16
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
*              and  kokrs  = 'MA01'.
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
* Convert the entered string to a date
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
* Assemble field catalog
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
*++1365 #21.
*   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*     EXPORTING
**      PERCENTAGE = 0
*       text       = $text.
*++2165 #10.
*   IF SY-BATCH IS INITIAL.
   IF SY-BATCH IS INITIAL AND W_/ZAK/START-NODIALOG IS INITIAL.
*--2165 #10.
     CALL FUNCTION 'TH_REDISPATCH'.
   ENDIF.
*--1365 #21.
 ENDFORM.                    " process_ind
*&---------------------------------------------------------------------*
*&      Form  CHECK_BTART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BTART  text
*----------------------------------------------------------------------*
 FORM CHECK_BTART USING  $BTART.
*++0004 BG 2007.04.04
   DATA L_VALUE TYPE DOMVALUE_L.
*--0004 BG 2007.04.04
   IF $BTART EQ C_BTYPART_SZJA.
     MESSAGE E178 WITH C_BTYPART_SZJA.
*   Returns of type & cannot be prepared with this program!
*++0004 BG 2007.04.04
   ELSE.
     MOVE $BTART TO L_VALUE.
     CALL FUNCTION '/IBS/RB_DOMAIN_GET_VALUE'
       EXPORTING
         I_DNAME    = '/ZAK/BTYPART'
         I_DLANGU   = 'H'
         I_DVALUE   = L_VALUE
*      IMPORTING
*        E_DD07V_WA =
       EXCEPTIONS
         DATA_ERROR = 1
         OTHERS     = 2.
     IF SY-SUBRC <> 0.
       MESSAGE E214.
*   Please enter a valid value!
     ENDIF.
*--0004 BG 2007.04.04
   ENDIF.
 ENDFORM.                    " CHECK_BTART
*&---------------------------------------------------------------------*
*&      Form  are_u_sure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_ANSWER  text
*----------------------------------------------------------------------*
*++0008 BG 2007.08.06
 FORM ARE_U_SURE  USING  P_TEXT
*--0008 BG 2007.08.06
                CHANGING P_ANSWER.
   CLEAR P_ANSWER.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
*      TITLEBAR       = ' '
*      DIAGNOSE_OBJECT             = ' '
*++0008 BG 2007.08.06
*      TEXT_QUESTION  = 'Menti a rögzített adatokat?'(900)
       TEXT_QUESTION  = P_TEXT
*--0008 BG 2007.08.06
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
*++MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12
*   CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
*     EXPORTING
*       TEXTLINE1     = 'Folytatja?'(901)
**      TEXTLINE2     = ' '
*       TITEL         = 'Megerősítés'(902)
**      START_COLUMN  = 25
**      START_ROW     = 6
*       DEFAULTOPTION = 'N'
*     IMPORTING
*       ANSWER        = P_ANSWER.
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
*--MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12
 ENDFORM.                    " loss_of_data
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE EXIT INPUT.
   SET SCREEN 0.
   LEAVE SCREEN.
 ENDMODULE.                 " exit  INPUT
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
*    Error during conversion of the due date to the next working day! (&)
   ENDIF.
   IF L_DATUM NE $DATUM.
     MOVE L_DATUM TO $DATUM.
     MESSAGE I225.
*   Due date converted to the next working day!
   ENDIF.
 ENDFORM.                    " GET_WORK_DAY
*&---------------------------------------------------------------------*
*&      Form  CHECK_AFA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_AFA USING    $AUTOGEN
                CHANGING $ERROR.
*  Function element for VAT verification
   DATA LI_DATA LIKE /ZAK/AFALAPVERIF.
   DATA L_CORR(40) TYPE C.
   DATA L_SEND_MESSAGE.
*  We collect the items to be posted here
   DATA LI_ANALITIKA_S LIKE /ZAK/ANALITIKA_S OCCURS 0 WITH HEADER LINE.
*  Header row for the items to be posted
   DATA LW_OUTTAB TYPE /ZAK/BEVALLALV..
*++BG 2009.11.26
   DATA LS_STABLE TYPE LVC_S_STBL.
*  get position
   LS_STABLE-ROW = 'X'.
   LS_STABLE-COL = 'X'.
*--BG 2009.11.26
   DATA L_ANSWER.
*  Reading OUTTAB
   DEFINE LM_READ_OUTTAB.
     CLEAR w_outtab.
     READ TABLE i_outtab INTO w_outtab
                         WITH KEY bukrs  = p_bukrs
                             btype_disp  = v_disp_btype
*                                 GJAHR  = S_GJAHR-LOW
*                                 MONAT  = S_MONAT-LOW
*                                 ZINDEX = S_INDEX-HIGH
                             abevaz_disp = &1.
     IF sy-subrc EQ 0.
*++BG 2007.09.10
*      MOVE W_OUTTAB-FIELD_NRK TO &2.
       MOVE w_outtab-field_nrk TO &2.
       MOVE w_outtab-round TO &3.
     ENDIF.
   END-OF-DEFINITION.
   CLEAR $ERROR.
   REFRESH I_/ZAK/AFA_ALAP.
   CLEAR L_SEND_MESSAGE.
   CALL FUNCTION 'MESSAGES_INITIALIZE'.
   CLEAR L_ANSWER.
*  Read the assignment table:
   SELECT * INTO TABLE I_/ZAK/AFA_ALAP
            FROM /ZAK/AFA_ALAP
           WHERE BTYPE EQ V_DISP_BTYPE.
   CHECK SY-SUBRC EQ 0.
*  Validation based on the assignment table
   LOOP AT I_/ZAK/AFA_ALAP INTO W_/ZAK/AFA_ALAP.
     CLEAR LI_DATA.
     CLEAR LW_OUTTAB.
*    Determine the tax base
     LM_READ_OUTTAB W_/ZAK/AFA_ALAP-ABEVAZ_ALAP
                    LI_DATA-LWBAS
                    LI_DATA-ROUND.
*    Save the data just in case
     MOVE W_OUTTAB TO LW_OUTTAB.
*    Determine the tax amount
     LM_READ_OUTTAB W_/ZAK/AFA_ALAP-ABEVAZ_AFA
                    LI_DATA-LWSTE
                    LI_DATA-ROUND.
*    VAT
     MOVE W_/ZAK/AFA_ALAP-AFA TO LI_DATA-KBETR.
*    Only check if there are values
     CHECK NOT LI_DATA-LWBAS IS INITIAL AND
           NOT LI_DATA-LWSTE IS INITIAL.
*    Currency
     MOVE C_HUF TO LI_DATA-WAERS.
*    Validation
     CALL FUNCTION '/ZAK/AFA_ALAP_VERIFY'
       EXPORTING
         I_DATA           = LI_DATA
       CHANGING
         E_DATA           = LI_DATA
       EXCEPTIONS
         ERROR_INPUT_DATA = 1
         OTHERS           = 2.
     IF SY-SUBRC <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       MESSAGE I227.
*      Hiba az ÁFA összeg ellenőrzés funkciónál! (/ZAK/AFA_ALAP_VERIFY)
       EXIT.
     ELSE.
       IF NOT LI_DATA-LWBAS_CORR IS INITIAL.
         CLEAR LI_ANALITIKA_S.
         MOVE-CORRESPONDING LW_OUTTAB TO LI_ANALITIKA_S.
         LI_ANALITIKA_S-ORIG_VALUE = LI_ANALITIKA_S-FIELD_N.
         LI_ANALITIKA_S-FIELD_N = LI_DATA-LWBAS_CORR.
         LI_ANALITIKA_S-NEW_VALUE = LI_ANALITIKA_S-FIELD_N.
         IF LI_ANALITIKA_S-STAPO NE C_X.
           LI_ANALITIKA_S-SUM_VALUE = LI_ANALITIKA_S-ORIG_VALUE +
                                       LI_ANALITIKA_S-NEW_VALUE.
         ENDIF.
         LI_ANALITIKA_S-BSZNUM = '999'.
         LI_ANALITIKA_S-LAPSZ = C_LAPSZ.
         IF LI_ANALITIKA_S-WAERS IS INITIAL.
           LI_ANALITIKA_S-WAERS = C_HUF.
         ENDIF.
         LI_ANALITIKA_S-ZCOMMENT = 'ÁFA alap kerekítés korrekció'(904).
         APPEND LI_ANALITIKA_S.
         CLEAR L_CORR.
         WRITE LI_DATA-LWBAS_CORR CURRENCY LI_DATA-WAERS
               TO L_CORR.
         MOVE 'X' TO L_SEND_MESSAGE.
         PERFORM MESSAGE_STORE USING '/ZAK/ZAK'
                                     'W'
                                     '228'
                                     W_/ZAK/AFA_ALAP-ABEVAZ_ALAP
                                     L_CORR
                                     SPACE
                                     SPACE.
       ENDIF.
     ENDIF.
   ENDLOOP.
   IF NOT L_SEND_MESSAGE IS INITIAL.
     MOVE C_X TO $ERROR.
*    Üzenetek megjelenítése
     CALL FUNCTION 'MESSAGES_SHOW'
       EXPORTING
         I_USE_GRID = 'X'.
     IF NOT $AUTOGEN IS INITIAL.
*    Kérdés a tételek automatikus generálásáról
*    Kívánja automatikusan generálni a korrekciókat?
       PERFORM ARE_U_SURE   USING TEXT-903
                         CHANGING L_ANSWER.
       CHECK L_ANSWER = '1'.
*++1765 #31.
       IF NOT V_BUKCS IS INITIAL.
         MESSAGE I295 WITH P_BUKRS.
*        & csoport vállalatnál nem megengedett a manuális rögzítés!
         EXIT.
       ENDIF.
*--1765 #31.
       V_DYNNR = SY-DYNNR.
       LOOP AT LI_ANALITIKA_S.
         PERFORM GET_NEXT_ITEM USING LI_ANALITIKA_S
                            CHANGING /ZAK/ANALITIKA.
         IF NOT /ZAK/ANALITIKA IS INITIAL.
           PERFORM SAVE_ITEM.
           CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY
*++BG 2009.11.26
             EXPORTING
               IS_STABLE = LS_STABLE.
*--BG 2009.11.26
         ENDIF.
       ENDLOOP.
     ENDIF.
   ENDIF.
 ENDFORM.                    " CHECK_AFA
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_STORE
*&---------------------------------------------------------------------*
*       Üzenet átadása üzenetgyűjtőnek
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
 ENDFORM.                               " MESSAGE_STORE
*&---------------------------------------------------------------------*
*&      Form  AFA_ARANY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/ANALITIKA  text
*      -->P_I_OUTTAB  text
*----------------------------------------------------------------------*
 FORM AFA_ARANY .
   DATA L_FIRST_DATE LIKE SY-DATUM.
*  ANALITIKA ABEV összesenek
   TYPES: BEGIN OF LT_ANALITIKA_ABEVS,
            ABEVAZ     TYPE /ZAK/ABEVAZ,
            FIELD_N    TYPE WERTV10,
            ARANY_FLAG TYPE /ZAK/ARANY_FLAG,
          END OF LT_ANALITIKA_ABEVS.
*  ANALITIKA ABEV összesenek aktuális
   TYPES: BEGIN OF LT_ANALITIKA_ABEVS_A,
            ABEVAZ     TYPE /ZAK/ABEVAZ,
            HKONT      TYPE HKONT,
            FIELD_N    TYPE WERTV10,
            WAERS      TYPE WAERS,
            ARANY_FLAG TYPE /ZAK/ARANY_FLAG,
            BOOK_N     TYPE WERTV10,
          END OF LT_ANALITIKA_ABEVS_A.
*  ANALITIKA ABEV összesenek SUMMA:
   DATA LI_ANALITIKA_ABEVS   TYPE LT_ANALITIKA_ABEVS OCCURS 0 WITH
   HEADER LINE.
*  ANALITIKA ABEV összesenek feldolgozott hónap (aktuális):
   DATA LI_ANALITIKA_ABEVS_A TYPE LT_ANALITIKA_ABEVS_A OCCURS 0 WITH
   HEADER LINE.
*  BEVALLO ABEV összesenek:
   DATA: BEGIN OF LI_BEVALLO_ABEVS OCCURS 0,
           ABEVAZ  TYPE /ZAK/ABEVAZ,
           FIELD_N TYPE WERTV10,
         END OF LI_BEVALLO_ABEVS.
*  ÁFA kódok:
   TYPES: BEGIN OF LT_MWSKZ,
            MWSKZ TYPE MWSKZ,
            KTOSL TYPE KTOSL_007B,
          END OF LT_MWSKZ.
   DATA: LI_MWSKZ TYPE LT_MWSKZ OCCURS 0 WITH HEADER LINE.
*  Szükséges összes ABEV ÁFA_CUST-ból
   RANGES LR_ABEVAZ_ALL FOR /ZAK/ANALITIKA-ABEVAZ.
*  Szükséges összes ABEV ANALITIKÁHOZ
   RANGES LR_ABEVAZ FOR /ZAK/ANALITIKA-ABEVAZ.
*  Szükséges Bejövő ABEV BEVALLO-hoz
   RANGES LR_ABEVAZ_B FOR /ZAK/ANALITIKA-ABEVAZ.
*  Szükséges Bejövő ABEVek BEVALLO-hoz aminek van szumma azonosítója
   RANGES LR_ABEVAZ_BS FOR /ZAK/ANALITIKA-ABEVAZ.
*  Szükséges VPOP összesen sor beszúrása a 04 vagy 06-os lapra.
   DATA L_VPOP_SUM.
*  Arányosított ÁFA kódok
   DATA LI_MWSKZ_A TYPE LT_MWSKZ OCCURS 0 WITH HEADER LINE.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_07 SPOTS /ZAK/MAIN_ES STATIC .
*++1565 #04.
   DATA L_FI_BUKRS      TYPE /ZAK/FI_BUKRS.
*--1565 #04.
*  Szükséges BTYPE-ok
   RANGES LR_BTYPE  FOR /ZAK/BEVALL-BTYPE.
   DATA LI_/ZAK/BEVALL LIKE /ZAK/BEVALL OCCURS 0 WITH HEADER LINE.
   DATA LW_AFA_CUST LIKE /ZAK/AFA_CUST.
   DATA LI_AFA_CUST LIKE /ZAK/AFA_CUST OCCURS 0 WITH HEADER LINE.
   DATA L_PREV_MONAT TYPE MONAT.
*++BG 2008.04.21
   RANGES LR_PREV_MONAT FOR /ZAK/ANALITIKA-MONAT.
*--BG 2008.04.21
   DATA L_MONAT TYPE MONAT.
   DATA L_OUTTAB_INDEX LIKE SY-TABIX.
   DATA L_BTYPE TYPE /ZAK/BTYPE.
   DATA L_MWSKZ TYPE MWSKZ.
   DATA L_KTOSL TYPE KTOSL_007B.
   DATA L_FLAG.
   DATA L_STGRP TYPE STGRP_007B.
   DATA L_AFA_IRANY.
*  Év, hónap, index:
   DATA: BEGIN OF LI_IDSZ OCCURS 0,
           GJAHR  TYPE GJAHR,
           MONAT  TYPE MONAT,
           ZINDEX TYPE /ZAK/INDEX,
         END OF LI_IDSZ.
*  Főkönyvi feladás számításához:
   DATA: L_FIELD_N   TYPE /ZAK/FIELDN,
         L_FIELD_NR  TYPE /ZAK/FIELDNR,
         L_FIELD_NRK TYPE /ZAK/FIELDNRK.
*  Összesen
   DATA: L_FIELD_NS   TYPE /ZAK/FIELDN.
   DATA: L_FIELD_NX   TYPE /ZAK/FIELDN.
*  Különbség
   DATA: L_FIELD_ND   TYPE /ZAK/FIELDN.
   DATA  L_ATYPE      TYPE /ZAK/ATYPE.
*++1065 2010.02.15 BG
*  Törlendő ABEV kódok, mivel forgatva lettek:
   RANGES LR_ABEVAZ_DEL FOR  /ZAK/ANALITIKA-ABEVAZ.
   DATA   L_ABEVAZ_SAVE LIKE /ZAK/ANALITIKA-ABEVAZ.
*--1065 2010.02.15 BG
   DEFINE LM_READ_ARANY_OUTTAB.
*++BG 2008.02.19
     CLEAR w_outtab.
*--BG 2008.02.19
     READ TABLE i_outtab INTO w_outtab
          WITH KEY abevaz = &1.
     IF sy-subrc EQ 0.
       MOVE sy-tabix TO l_outtab_index.
       READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
            WITH KEY abevaz = &1.
     ENDIF.
   END-OF-DEFINITION.
   DEFINE LM_READ_ANALITIKA_ABEVS.
*++BG 2008.02.19
     CLEAR li_analitika_abevs.
*--BG 2008.02.19
     READ TABLE li_analitika_abevs
          WITH KEY abevaz      = &1
                   arany_flag  = &2.
   END-OF-DEFINITION.
   DEFINE LM_READ_BEVALLO_ABEVS.
*++BG 2008.02.19
     CLEAR li_bevallo_abevs.
*--BG 2008.02.19
     READ TABLE li_bevallo_abevs
          WITH KEY abevaz      = &1.
   END-OF-DEFINITION.
   DEFINE LM_GET_ARANY_ABEV_MWSKZ.
*++1565 #04.
     IF v_form_inact IS INITIAL.
*--1565 #04.
       CLEAR: &3, &6.
*++1065 2010.02.15 BG
       MOVE &2 TO l_abevaz_save.
*--1065 2010.02.15 BG
*++1665 #09.
*    Beolvassuk az ÁFA kód jellemzőit
       READ TABLE li_afa_cust
             WITH KEY btype =  &1
                      mwskz =  &4
                      ktosl =  &5
                      abevaz = &2
*                     BINARY SEARCH
                      .
*      Olvassuk KTOSL nélkül
       IF sy-subrc NE 0.
         READ TABLE li_afa_cust
               WITH KEY btype =  &1
                        mwskz =  &4
                        ktosl =  ''
                        abevaz = &2
*                       BINARY SEARCH
                        .
       ENDIF.
*--1665 #09.
*    Ha benne van az Arányosított abev-ekben akkor nem kell forgatni
       READ TABLE i_/zak/afa_arabev INTO w_/zak/afa_arabev
                  WITH KEY abevaz = &2.
       IF sy-subrc NE 0.
*++1665 #09.
**    Beolvassuk az ÁFA kód jellemzőit
*         READ TABLE LI_AFA_CUST
*               WITH KEY BTYPE =  &1
*                        MWSKZ =  &4
*                        KTOSL =  &5
*                        ABEVAZ = &2
**                     BINARY SEARCH
*                        .
**      Olvassuk KTOSL nélkül
*         IF SY-SUBRC NE 0.
*           READ TABLE LI_AFA_CUST
*                 WITH KEY BTYPE =  &1
*                          MWSKZ =  &4
*                          KTOSL =  ''
*                          ABEVAZ = &2
**                       BINARY SEARCH
*                          .
*         ENDIF.
*--1665 #09.
*      Alap
         IF li_afa_cust-atype EQ c_atype_a.
           READ TABLE i_/zak/afa_arabev INTO w_/zak/afa_arabev
                WITH KEY btype = &1
                         atype = c_atype_a
*++1065 2010.02.04 BG
*                       VPOPF = ''.
                         aranyf = '0'.
*--1065 2010.02.04 BG
           IF sy-subrc EQ 0.
             &6 = c_atype_a.
*++1665 #09.
*             &2 = W_/ZAK/AFA_ARABEV-ABEVAZ.
*--1665 #09.
             READ TABLE li_mwskz_a TRANSPORTING NO FIELDS
                       WITH KEY mwskz = &4
                                ktosl = &5
                                BINARY SEARCH.
*          Arányosított
             IF sy-subrc EQ 0.
               &3 = c_x.
*          Nem arányosított
             ELSE.
*++1065 2010.02.15 BG
*          Olvassuk KTOSL nélkül is
               READ TABLE li_mwskz_a TRANSPORTING NO FIELDS
                         WITH KEY mwskz = &4
                                  BINARY SEARCH.
               IF sy-subrc EQ 0.
                 &3 = c_x.
               ELSE.
*--1065 2010.02.15 BG
                 CLEAR &3.
               ENDIF.
             ENDIF.
           ELSE.
*++1665 #07.
*           MESSAGE E244 WITH &1.
* Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók!
             CLEAR &3.
*--1665 #07.
           ENDIF.
         ELSEIF li_afa_cust-atype EQ c_atype_b.
           READ TABLE i_/zak/afa_arabev INTO w_/zak/afa_arabev
                WITH KEY btype = &1
                         atype = c_atype_b
*++1065 2010.02.04 BG
*                      VPOPF = ''.
                        aranyf = '0'.
*--1065 2010.02.04 BG
           IF sy-subrc EQ 0.
             &6 = c_atype_b.
*--1665 #09.
*             &2 = W_/ZAK/AFA_ARABEV-ABEVAZ.
*--1665 #09.
             READ TABLE li_mwskz_a TRANSPORTING NO FIELDS
                       WITH KEY mwskz = &4
                                ktosl = &5
                                BINARY SEARCH.
*          Arányosított
             IF sy-subrc EQ 0.
               &3 = c_x.
*          Nem arányosított
             ELSE.
*++1065 2010.02.15 BG
*          Olvassuk KTOSL nélkül is
               READ TABLE li_mwskz_a TRANSPORTING NO FIELDS
                         WITH KEY mwskz = &4
                                  BINARY SEARCH.
               IF sy-subrc EQ 0.
                 &3 = c_x.
               ELSE.
                 CLEAR &3.
*--1065 2010.02.15 BG
               ENDIF.
             ENDIF.
           ELSE.
*++1665 #07.
*           MESSAGE E244 WITH &1.
* Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók!
             CLEAR &3.
*--1665 #07.
           ENDIF.
         ENDIF.
*    Arányosított ABEV azonosítón van
       ELSE.
*++1665 #09.
*        Ha részben arányosít
         IF &8 EQ c_artype_r AND li_afa_cust-atype EQ c_atype_b.
           READ TABLE li_mwskz_a TRANSPORTING NO FIELDS
                     WITH KEY mwskz = &4
                              ktosl = &5
                              BINARY SEARCH.
*          Arányosított
           IF sy-subrc EQ 0.
             &3 = c_x.
*            Nem arányosított
           ELSE.
*              Olvassuk KTOSL nélkül is
             READ TABLE li_mwskz_a TRANSPORTING NO FIELDS
                       WITH KEY mwskz = &4
                                BINARY SEARCH.
             IF sy-subrc EQ 0.
               &3 = c_x.
             ELSE.
               CLEAR &3.
             ENDIF.
           ENDIF.
         ELSE.
*--1665 #09.
           &3 = c_x.
           &6 = w_/zak/afa_arabev-atype.
*++1665 #09.
         ENDIF.
*--1665 #09.
       ENDIF.
*++1065 2010.02.15 BG
*    Forgott az ABEV kód
       IF &2 NE l_abevaz_save AND &3 EQ c_x.
         m_def &7 'I' 'EQ' l_abevaz_save space.
       ENDIF.
*--1065 2010.02.15 BG
*++1565 #04.
     ENDIF.
     CLEAR v_form_inact.
*--1565 #04.
   END-OF-DEFINITION.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_08 SPOTS /ZAK/MAIN_ES .
   DEFINE LM_GET_ARANY_ABEV_ABEVAZ.
*    Ha benne van az Arányosított abev-ekben akkor nem kell forgatni
     READ TABLE i_/zak/afa_arabev TRANSPORTING NO FIELDS
                WITH KEY abevaz = &2.
     IF sy-subrc NE 0.
*      Beolvassuk az ÁFA kód jellemzőit
       READ TABLE li_afa_cust
             WITH KEY btype =  &1
                      abevaz = &2.
*      Alap
       IF li_afa_cust-atype EQ c_atype_a.
         READ TABLE i_/zak/afa_arabev INTO w_/zak/afa_arabev
              WITH KEY btype = &1
                       atype = c_atype_a
*++1065 2010.02.04 BG
*                     VPOPF = ''.
                       aranyf = '0'.
*--1065 2010.02.04 BG
         IF sy-subrc EQ 0.
*++1665 #09.
*           &2 = W_/ZAK/AFA_ARABEV-ABEVAZ.
*--1665 #09.
         ELSE.
           MESSAGE e244 WITH &1.
* Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók!
         ENDIF.
       ELSEIF  li_afa_cust-atype EQ c_atype_b.
         READ TABLE i_/zak/afa_arabev INTO w_/zak/afa_arabev
              WITH KEY btype = &1
                       atype = c_atype_b
*++1065 2010.02.04 BG
*                     VPOPF = ''.
                       aranyf = '0'.
*--1065 2010.02.04 BG
         IF sy-subrc EQ 0.
*++1665 #09.
*           &2 = W_/ZAK/AFA_ARABEV-ABEVAZ.
*--1665 #09.
         ELSE.
           MESSAGE e244 WITH &1.
* Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók!
         ENDIF.
       ENDIF.
     ENDIF.
   END-OF-DEFINITION.
   DEFINE LM_GET_ARANY.
     CLEAR l_field_n.
*    Arány megahatározása
     w_outtab-field_n = ( li_analitika_abevs-field_n *
                          w_/zak/afa_arany-arany / 100 ).
*++0014 2008.09.08 BG
*    El kell tárolni mert a főkönyvi feladáshoz kell:
     l_field_n = li_analitika_abevs-field_n - w_outtab-field_n.
*--0014 2008.09.08 BG
*    Nem arányosított rész hozzáadása
*++1665 #08.
*     LM_READ_ANALITIKA_ABEVS W_/ZAK/AFA_ARABEV-ABEVAZ ''.
     lm_read_analitika_abevs &1 &2.
*--1665 #08.
     IF sy-subrc EQ 0.
       ADD li_analitika_abevs-field_n TO w_outtab-field_n.
     ENDIF.
*++1665 #15.
*     W_OUTTAB-FIELD_N = W_OUTTAB-FIELD_N - LI_BEVALLO_ABEVS-FIELD_N.
*--1665 #15.
*++0014 2008.09.08 BG
*    El kell tárolni mert a főkönyvi feladáshoz kell:
*    MOVE W_OUTTAB-FIELD_N TO L_FIELD_N.
*--0014 2008.09.08 BG
     PERFORM calc_field_nrk USING l_field_n
                                  w_/zak/bevallb-round
                                  w_outtab-waers
                         CHANGING l_field_nr
                                  l_field_nrk.
*++1665 #08.
**    Az összeg kiszámítás után a normál részt le kell vonni mert az
**    más sorokon már szerepel
**++BG 2008.02.19
*     IF W_/ZAK/BEVALL-ARTYPE EQ C_ARTYPE_R.
**--BG 2008.02.19
*       W_OUTTAB-FIELD_N = W_OUTTAB-FIELD_N - LI_ANALITIKA_ABEVS-FIELD_N.
**++BG 2008.02.19
*     ENDIF.
**--BG 2008.02.19
*--1665 #08.
     PERFORM calc_field_nrk USING w_outtab-field_n
                                  w_/zak/bevallb-round
                                  w_outtab-waers
                         CHANGING w_outtab-field_nr
                                  w_outtab-field_nrk.
     MODIFY i_outtab FROM w_outtab INDEX l_outtab_index
            TRANSPORTING field_n field_nr field_nrk.
   END-OF-DEFINITION.
*  Főkönyvi feladás számítása
   DEFINE LM_GET_FOKONYV.
     CLEAR: l_field_ns, l_field_nx.
     IF NOT &2 IS INITIAL.
*      Meghatározzuk az aktuális hónap feladását összesen
       LOOP AT li_analitika_abevs_a WHERE abevaz = &1.
         ADD li_analitika_abevs_a-field_n TO l_field_ns.
         IF NOT li_analitika_abevs_a-arany_flag IS INITIAL.
           ADD li_analitika_abevs_a-field_n TO l_field_nx.
         ENDIF.
       ENDLOOP.
*      Különbség meghatározása
       l_field_nd = l_field_ns - &2.
*      Könnyvelési érték kiszámolása
       LOOP AT li_analitika_abevs_a WHERE abevaz = &1
                                      AND NOT arany_flag IS INITIAL.
         IF NOT l_field_nx IS INITIAL.
           li_analitika_abevs_a-book_n = ( l_field_nd / l_field_nx ) *
                                           li_analitika_abevs_a-field_n.
           MODIFY li_analitika_abevs_a TRANSPORTING book_n.
         ENDIF.
       ENDLOOP.
     ENDIF.
   END-OF-DEFINITION.
*++0014 2008.09.08 BG
*  Főkönyvi feladás számítása
   DEFINE LM_GET_FOKONYV_NEW.
     CLEAR: l_field_ns, l_field_nx.
     IF NOT &2 IS INITIAL.
*      Összegezni kell az előző hónapok feladásaival:
       MOVE &2 TO l_field_nx.
       IF NOT lr_prev_monat[] IS INITIAL.
         SELECT SUM( field_n ) INTO l_field_ns
                            FROM /zak/afa_arbook
                            WHERE  bukrs EQ p_bukrs
                              AND  btype IN lr_btype
                              AND  gjahr EQ s_gjahr-low
                              AND  monat IN lr_prev_monat
                              AND  abevaz EQ &1.
         IF sy-subrc EQ 0.
           SUBTRACT l_field_ns FROM l_field_nx.
         ENDIF.
       ENDIF.
*    Értékek visszaírása
       LOOP AT li_analitika_abevs_a WHERE abevaz = &1
                                      AND NOT arany_flag IS INITIAL.
         IF NOT l_field_nx IS INITIAL.
           MOVE l_field_nx TO li_analitika_abevs_a-book_n.
           MODIFY li_analitika_abevs_a TRANSPORTING book_n.
         ENDIF.
       ENDLOOP.
     ENDIF.
   END-OF-DEFINITION.
*--0014 2008.09.08 BG
*ÁFA irány meghatározás
   DEFINE LM_0GET_AFABK.
     CLEAR &2.
     SELECT SINGLE stgrp INTO l_stgrp
                         FROM t007b
                        WHERE ktosl EQ &1.
     IF sy-subrc EQ 0.
       CASE l_stgrp.
         WHEN '1'.
           MOVE 'K' TO &2.
         WHEN '2'.
           MOVE 'B' TO &2.
       ENDCASE.
     ENDIF.
   END-OF-DEFINITION.
   DEFINE LM_GET_ABEVAZ_SUM_ABEV.
     LOOP AT i_/zak/bevallb INTO w_/zak/bevallb
                           WHERE abevaz IN &1
                             AND NOT sum_abevaz IS INITIAL.
       m_def &2 'I' 'EQ' w_/zak/bevallb-abevaz space.
     ENDLOOP.
   END-OF-DEFINITION.
*  Meghatározzuk hogy a bevallás arányosított ÁFÁS-e
   CHECK NOT W_/ZAK/BEVALL-ARTYPE IS INITIAL AND P_M <> C_X.
*  Beolvassuk az ABEV-eket
   SELECT * INTO TABLE I_/ZAK/AFA_ARABEV
            FROM /ZAK/AFA_ARABEV
           WHERE BTYPE EQ W_/ZAK/BEVALL-BTYPE.
   IF SY-SUBRC NE 0.
     MESSAGE E244 WITH W_/ZAK/BEVALL-BTYPE.
*Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók!
   ELSE.
     LOOP AT I_/ZAK/AFA_ARABEV INTO W_/ZAK/AFA_ARABEV.
       M_DEF LR_ABEVAZ_ALL 'I' 'EQ' W_/ZAK/AFA_ARABEV-ABEVAZ SPACE.
     ENDLOOP.
   ENDIF.
*  Most megvannak a bejövő ABEVazonosítók, most ki kell szűrni,hogy
*  csak azok kellenek aminek a BEVLLB-ben van szumma azonosítója mert
*  egyébként többszörösét szelektálnánk:
   LM_GET_ABEVAZ_SUM_ABEV LR_ABEVAZ_ALL LR_ABEVAZ.
*  Beolvassuk az arány adatokat
   SELECT SINGLE * INTO W_/ZAK/AFA_ARANY
                   FROM /ZAK/AFA_ARANY
                  WHERE BUKRS EQ P_BUKRS
                    AND GJAHR EQ S_GJAHR-LOW
                    AND MONAT EQ S_MONAT-LOW.
   IF SY-SUBRC NE 0.
     MESSAGE E246 WITH S_GJAHR-LOW S_MONAT-LOW.
*  Nem határozható meg arány szám a & év & hónaphoz!
   ENDIF.
*  Meghatározzuk az adott év BTYPE-okat
   CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
     EXPORTING
       I_BUKRS      = P_BUKRS
       I_BTYPART    = C_BTYPART_AFA
     TABLES
*      T_BTYPE      = LR_BTYPE
       T_/ZAK/BEVALL = LI_/ZAK/BEVALL
     EXCEPTIONS
       ERROR_BTYPE  = 1
       OTHERS       = 2.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
*  Év első napja:
   CONCATENATE S_GJAHR-LOW '01' '01' INTO L_FIRST_DATE.
*  Összeállítjuk a szükséges BTYPE-okat
   LOOP AT LI_/ZAK/BEVALL WHERE DATAB LE L_FIRST_DATE
                           AND DATBI GE V_LAST_DATE.
     M_DEF LR_BTYPE 'I' 'EQ' LI_/ZAK/BEVALL-BTYPE SPACE.
   ENDLOOP.
*  Meghatározzuk az ABEV azonosítókat:
*  Ha részben arányosított
   IF W_/ZAK/BEVALL-ARTYPE EQ C_ARTYPE_R.
     SELECT MWSKZ KTOSL INTO CORRESPONDING FIELDS OF TABLE LI_MWSKZ_A
                        FROM /ZAK/AFA_RARANY
                       WHERE BUKRS EQ P_BUKRS.
     SORT LI_MWSKZ_A.
   ENDIF.
*  ABEV kódok gyűjtése:
   SELECT * INTO LW_AFA_CUST
            FROM /ZAK/AFA_CUST
          WHERE BTYPE IN LR_BTYPE.
*++1065 2010.02.15 BG
     READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                              WITH KEY BTYPE  = LW_AFA_CUST-BTYPE
                                       ABEVAZ = LW_AFA_CUST-ABEVAZ.
     IF SY-SUBRC EQ 0 AND NOT W_/ZAK/BEVALLB-SUM_ABEVAZ IS INITIAL.
       M_DEF LR_ABEVAZ 'I' 'EQ' LW_AFA_CUST-ABEVAZ SPACE.
     ENDIF.
*--1065 2010.02.15 BG
     MOVE-CORRESPONDING LW_AFA_CUST TO LI_AFA_CUST.
     APPEND LI_AFA_CUST.
*    Teljesen arányosított
     IF W_/ZAK/BEVALL-ARTYPE = C_ARTYPE_A.
       MOVE LW_AFA_CUST-MWSKZ TO LI_MWSKZ_A-MWSKZ.
       MOVE LW_AFA_CUST-KTOSL TO LI_MWSKZ_A-KTOSL.
       COLLECT LI_MWSKZ_A.
     ENDIF.
   ENDSELECT.
   SORT: LI_AFA_CUST, LI_MWSKZ_A.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_09 SPOTS /ZAK/MAIN_ES .
*++BG 2008.04.21
*  ABEVS összesen meghatározása ANALITIKA jelenlegi hónap - 1.
*  L_PREV_MONAT = S_MONAT-LOW - 1.
   REFRESH LR_PREV_MONAT.
*  Havi
   IF W_/ZAK/BEVALL-BIDOSZ EQ 'H' AND S_MONAT-LOW NE '01'.
     L_PREV_MONAT = S_MONAT-LOW - 1.
     M_DEF LR_PREV_MONAT 'I' 'BT' '01' L_PREV_MONAT.
*  Negyedéves
   ELSEIF W_/ZAK/BEVALL-BIDOSZ EQ 'N'.
     READ TABLE R_MONAT INDEX 1.
     IF R_MONAT-LOW EQ '04'.
*++0013 2008.09.01 BG
       L_PREV_MONAT = '03'.
*--0013 2008.09.01 BG
       M_DEF LR_PREV_MONAT 'I' 'BT' '01' '03'.
     ELSEIF R_MONAT-LOW EQ '07'.
*++0013 2008.09.01 BG
       L_PREV_MONAT = '06'.
*--0013 2008.09.01 BG
       M_DEF LR_PREV_MONAT 'I' 'BT' '01' '06'.
     ELSEIF R_MONAT-LOW EQ '10'.
*++0013 2008.09.01 BG
       L_PREV_MONAT = '09'.
*--0013 2008.09.01 BG
       M_DEF LR_PREV_MONAT 'I' 'BT' '01' '09'.
     ENDIF.
*  Éves (itt nem töltjük mert nincs előző időszak)
   ELSEIF W_/ZAK/BEVALL-BIDOSZ EQ 'E'.
   ENDIF.
*--BG 2008.04.21
*++1665 #15.
**++BG 2008.04.21
**Ha kell előző időszakot szelektálni
*   IF NOT LR_PREV_MONAT[] IS INITIAL.
**--BG 2008.04.16
*     SELECT  /ZAK/ANALITIKA~BTYPE
*             /ZAK/ANALITIKA~ABEVAZ
*             /ZAK/ANALITIKA~FIELD_N
*             /ZAK/ANALITIKA~MWSKZ
*             /ZAK/ANALITIKA~KTOSL
**++1565 #04.
*             /ZAK/ANALITIKA~FI_BUKRS
**--1565 #04.
*                           INTO (L_BTYPE,
*                                 LI_ANALITIKA_ABEVS-ABEVAZ,
*                                 LI_ANALITIKA_ABEVS-FIELD_N,
*                                 L_MWSKZ,
**++1565 #04.
**                                L_KTOSL)
*                                 L_KTOSL,
*                                 L_FI_BUKRS)
**--1565 #04.
*                           FROM  /ZAK/ANALITIKA INNER JOIN /ZAK/BEVALLI
*                             ON  /ZAK/BEVALLI~BUKRS  =
*                             /ZAK/ANALITIKA~BUKRS
*                            AND  /ZAK/BEVALLI~BTYPE  =
*                            /ZAK/ANALITIKA~BTYPE
*                            AND  /ZAK/BEVALLI~GJAHR  =
*                            /ZAK/ANALITIKA~GJAHR
*                            AND  /ZAK/BEVALLI~MONAT  =
*                            /ZAK/ANALITIKA~MONAT
*                            AND  /ZAK/BEVALLI~ZINDEX =
*                            /ZAK/ANALITIKA~ZINDEX
*                          WHERE  /ZAK/ANALITIKA~BUKRS EQ P_BUKRS
*                            AND  /ZAK/ANALITIKA~GJAHR EQ S_GJAHR-LOW
**++BG 2008.04.21
**                           AND  /ZAK/ANALITIKA~MONAT LE L_PREV_MONAT
*                            AND  /ZAK/ANALITIKA~MONAT IN LR_PREV_MONAT
**--BG 2008.04.16
*                            AND  /ZAK/ANALITIKA~BTYPE IN LR_BTYPE
*                            AND  /ZAK/ANALITIKA~ABEVAZ IN LR_ABEVAZ
*                            AND  /ZAK/BEVALLI~FLAG IN ('Z','X').
**    Áfa irány megahtározás
*       LM_0GET_AFABK L_KTOSL L_AFA_IRANY.
**    Csak bejovő kell
*       IF L_AFA_IRANY EQ 'B'.
*         M_DEF LR_ABEVAZ_B 'I' 'EQ' LI_ANALITIKA_ABEVS-ABEVAZ SPACE.
*         LM_GET_ARANY_ABEV_MWSKZ L_BTYPE
*                                 LI_ANALITIKA_ABEVS-ABEVAZ
*                                 LI_ANALITIKA_ABEVS-ARANY_FLAG
*                                 L_MWSKZ
*                                 L_KTOSL
*                                 L_ATYPE
**++1065 2010.02.15 BG
*                                 LR_ABEVAZ_DEL
**--1065 2010.02.15 BG
**++1665 #09.
*                                 W_/ZAK/BEVALL-ARTYPE.
**         COLLECT LI_ANALITIKA_ABEVS.
**--1665 #09.
*         M_DEF LR_ABEVAZ_B 'I' 'EQ' LI_ANALITIKA_ABEVS-ABEVAZ SPACE.
*       ENDIF.
**++1665 #09.
*       COLLECT LI_ANALITIKA_ABEVS.
*       CLEAR LI_ANALITIKA_ABEVS.
**--1665 #09.
*     ENDSELECT.
**++BG 2008.04.21
*   ENDIF.
**--BG 2008.04.16
*--1665 #15.
*  Jelenlegi időszak, itt nem kell a státuszt figyelni
   SELECT  /ZAK/ANALITIKA~BTYPE
           /ZAK/ANALITIKA~ABEVAZ
           /ZAK/ANALITIKA~HKONT
           /ZAK/ANALITIKA~FIELD_N
           /ZAK/ANALITIKA~WAERS
           /ZAK/ANALITIKA~MWSKZ
           /ZAK/ANALITIKA~KTOSL
*++1565 #04.
           /ZAK/ANALITIKA~FI_BUKRS
*--1565 #04.
                         INTO (L_BTYPE,
                               LI_ANALITIKA_ABEVS-ABEVAZ,
                               LI_ANALITIKA_ABEVS_A-HKONT,
                               LI_ANALITIKA_ABEVS-FIELD_N,
                               LI_ANALITIKA_ABEVS_A-WAERS,
                               L_MWSKZ,
*++1565 #04.
*                              L_KTOSL)
                               L_KTOSL,
                               L_FI_BUKRS)
*--1565 #04.
                         FROM  /ZAK/ANALITIKA
                        WHERE  /ZAK/ANALITIKA~BUKRS EQ P_BUKRS
                          AND  /ZAK/ANALITIKA~GJAHR EQ S_GJAHR-LOW
*++BG 2008.04.21
*                         AND  /ZAK/ANALITIKA~MONAT EQ S_MONAT-LOW
                          AND  /ZAK/ANALITIKA~MONAT IN R_MONAT
*--BG 2008.04.16
*++1565 #14.
*                          AND  /ZAK/ANALITIKA~ZINDEX EQ S_INDEX-LOW
                          AND  /ZAK/ANALITIKA~ZINDEX IN S_INDEX
*--1565 #14.
                          AND  /ZAK/ANALITIKA~BTYPE IN LR_BTYPE
                          AND  /ZAK/ANALITIKA~ABEVAZ IN LR_ABEVAZ.
*    Áfa irány megahtározás
     LM_0GET_AFABK L_KTOSL L_AFA_IRANY.
*    Csak bejovő kell
     IF L_AFA_IRANY EQ 'B'.
       M_DEF LR_ABEVAZ_B 'I' 'EQ' LI_ANALITIKA_ABEVS-ABEVAZ SPACE.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_11 SPOTS /ZAK/MAIN_ES .
       LM_GET_ARANY_ABEV_MWSKZ L_BTYPE
                               LI_ANALITIKA_ABEVS-ABEVAZ
                               LI_ANALITIKA_ABEVS-ARANY_FLAG
                               L_MWSKZ
                               L_KTOSL
                               L_ATYPE
*++1065 2010.02.15 BG
                               LR_ABEVAZ_DEL
*--1065 2010.02.15 BG
*++1665 #09.
                               W_/ZAK/BEVALL-ARTYPE.
*--1665 #09.
*      Ha ÁFA
       IF L_ATYPE EQ C_ATYPE_B.
         MOVE-CORRESPONDING LI_ANALITIKA_ABEVS TO LI_ANALITIKA_ABEVS_A.
         COLLECT LI_ANALITIKA_ABEVS_A.
       ENDIF.
*++1665 #09.
*       COLLECT LI_ANALITIKA_ABEVS.
*--1665 #09.
       M_DEF LR_ABEVAZ_B 'I' 'EQ' LI_ANALITIKA_ABEVS-ABEVAZ SPACE.
     ENDIF.
*++1665 #09.
     COLLECT LI_ANALITIKA_ABEVS.
     CLEAR LI_ANALITIKA_ABEVS.
*--1665 #09.
   ENDSELECT.
*  Most megvannak a bejövő ABEVazonosítók, most ki kell szűrni,hogy
*  csak azok kellenek aminek a BEVLLB-ben van szumma azonosítója mert
*  egyébként többszörösét szelektálnánk:
*++0014 2008.09.08 BG
*  Csak azokat az ABEV kódokat gyűjtjük össze, amik arányosíttak.
*  LM_GET_ABEVAZ_SUM_ABEV LR_ABEVAZ_B LR_ABEVAZ_BS.
   LOOP AT I_/ZAK/AFA_ARABEV INTO W_/ZAK/AFA_ARABEV.
     M_DEF LR_ABEVAZ_BS 'I' 'EQ' W_/ZAK/AFA_ARABEV-ABEVAZ SPACE.
   ENDLOOP.
*--0014 2008.09.08 BG
   IF NOT LR_ABEVAZ_BS[] IS INITIAL AND L_PREV_MONAT NE '00'.
*    Összeállítjuk havonként az utolsó időszakot
     L_MONAT = 1.
     DO.
       MOVE S_GJAHR-LOW TO LI_IDSZ-GJAHR.
       MOVE L_MONAT TO LI_IDSZ-MONAT.
       SELECT SINGLE MAX( ZINDEX ) INTO LI_IDSZ-ZINDEX
                                   FROM /ZAK/BEVALLI
                                  WHERE BUKRS EQ P_BUKRS
                                    AND BTYPE IN LR_BTYPE
                                    AND GJAHR EQ S_GJAHR-LOW
                                    AND MONAT EQ L_MONAT
                                    AND FLAG  IN ('Z','X').
       IF NOT LI_IDSZ-ZINDEX IS INITIAL.
         APPEND LI_IDSZ.
       ENDIF.
       ADD 1 TO L_MONAT.
       IF L_MONAT > L_PREV_MONAT.
         EXIT.
       ENDIF.
     ENDDO.
     LOOP AT LI_IDSZ.
*    ABEVS összesen meghatározása BEVALLO
*++1565 #14.
*       SELECT BTYPE ABEVAZ FIELD_NRK
       SELECT BTYPE ABEVAZ FIELD_N
*--1565 #14.
                             INTO (L_BTYPE,
                                   LI_BEVALLO_ABEVS-ABEVAZ,
                                   LI_BEVALLO_ABEVS-FIELD_N)
                             FROM  /ZAK/BEVALLO
                            WHERE  BUKRS EQ P_BUKRS
                              AND  GJAHR EQ LI_IDSZ-GJAHR
                              AND  MONAT EQ LI_IDSZ-MONAT
                              AND  ZINDEX EQ LI_IDSZ-ZINDEX
                              AND  BTYPE IN LR_BTYPE
                              AND  ABEVAZ IN LR_ABEVAZ_BS.
         LM_GET_ARANY_ABEV_ABEVAZ L_BTYPE
                                  LI_BEVALLO_ABEVS-ABEVAZ.
         COLLECT LI_BEVALLO_ABEVS.
       ENDSELECT.
     ENDLOOP.
   ENDIF.
*  Adatok feldolgozása
   LOOP AT I_/ZAK/AFA_ARABEV INTO W_/ZAK/AFA_ARABEV.
*    Beolvassuk az OUTTAB sort
     LM_READ_ARANY_OUTTAB    W_/ZAK/AFA_ARABEV-ABEVAZ.
*    Beolvassuk az ANALITIKA sort
     LM_READ_ANALITIKA_ABEVS W_/ZAK/AFA_ARABEV-ABEVAZ 'X'.
*    Beállítások
     LM_READ_BEVALLO_ABEVS   W_/ZAK/AFA_ARABEV-ABEVAZ.
*    Arány meghatározás
*++1665 #09.
*     LM_GET_ARANY.
     IF  W_/ZAK/BEVALL-ARTYPE EQ C_ARTYPE_R.
       LM_GET_ARANY W_/ZAK/AFA_ARABEV-ABEVAZ ''.
     ELSE.
       LM_GET_ARANY '' ''.
     ENDIF.
*--1665 #09.
     IF W_/ZAK/AFA_ARABEV-ATYPE EQ C_ATYPE_B.
*++0014 2008.09.08 BG
*      Főkönyvi feladás számítása
*       LM_GET_FOKONYV W_/ZAK/AFA_ARABEV-ABEVAZ
*                      L_FIELD_NRK.
       LM_GET_FOKONYV_NEW W_/ZAK/AFA_ARABEV-ABEVAZ
                          L_FIELD_NRK.
*--0014 2008.09.08 BG
     ENDIF.
*    Meghatározzuk volt-e VPOP-s arányosított.
*++1065 2010.02.04 BG
*    IF NOT W_/ZAK/AFA_ARABEV-VPOPF IS INITIAL.
     IF W_/ZAK/AFA_ARABEV-ARANYF CA '23'.
*--1065 2010.02.04 BG
       READ TABLE I_/ZAK/ANALITIKA TRANSPORTING NO FIELDS
            WITH KEY ABEVAZ = W_/ZAK/AFA_ARABEV-ABEVAZ
                     ARANY_FLAG = 'X'.
       IF SY-SUBRC EQ 0.
*++1665 #09.
*         MOVE 'X' TO L_VPOP_SUM.
*--1665 #09.
       ENDIF.
     ENDIF.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_OTP_01 SPOTS /ZAK/MAIN_ES .
   ENDLOOP.
*  Arány könyveléséhez adatok módosítása
   REFRESH I_/ZAK/AFA_ARBOOK.
   LOOP AT LI_ANALITIKA_ABEVS_A WHERE NOT BOOK_N IS INITIAL.
     CLEAR   W_/ZAK/AFA_ARBOOK.
     MOVE P_BUKRS TO W_/ZAK/AFA_ARBOOK-BUKRS.
     MOVE P_BTYPE TO W_/ZAK/AFA_ARBOOK-BTYPE.
     MOVE S_GJAHR-LOW TO W_/ZAK/AFA_ARBOOK-GJAHR.
     MOVE S_MONAT-LOW TO W_/ZAK/AFA_ARBOOK-MONAT.
     MOVE S_INDEX-LOW TO W_/ZAK/AFA_ARBOOK-ZINDEX.
     MOVE LI_ANALITIKA_ABEVS_A-HKONT TO W_/ZAK/AFA_ARBOOK-HKONT.
     MOVE LI_ANALITIKA_ABEVS_A-ABEVAZ TO W_/ZAK/AFA_ARBOOK-ABEVAZ.
     MOVE LI_ANALITIKA_ABEVS_A-BOOK_N TO W_/ZAK/AFA_ARBOOK-FIELD_N.
     MOVE LI_ANALITIKA_ABEVS_A-WAERS TO W_/ZAK/AFA_ARBOOK-WAERS.
     APPEND W_/ZAK/AFA_ARBOOK TO I_/ZAK/AFA_ARBOOK.
   ENDLOOP.
*  Régi adatok törlése
   DELETE FROM /ZAK/AFA_ARBOOK WHERE BUKRS EQ P_BUKRS
   AND BTYPE EQ P_BTYPE
   AND GJAHR EQ S_GJAHR-LOW
   AND MONAT EQ S_MONAT-LOW
   AND ZINDEX EQ S_INDEX-LOW.
   IF NOT I_/ZAK/AFA_ARBOOK[] IS INITIAL.
     INSERT /ZAK/AFA_ARBOOK FROM TABLE I_/ZAK/AFA_ARBOOK.
   ENDIF.
*  04/06 arányosított ÁFA összesen sor
   IF NOT L_VPOP_SUM IS INITIAL.
*++BG 2008.03.26
     IF W_/ZAK/BNYLAP IS INITIAL.
       SELECT  * INTO W_/ZAK/BNYLAP
              UP TO 1 ROWS
              FROM /ZAK/BNYLAP
             WHERE BUKRS   EQ P_BUKRS
               AND BTYPART EQ P_BTART
               AND DATBI   GE V_LAST_DATE
               AND DATAB   LE V_LAST_DATE.
       ENDSELECT.
       IF SY-SUBRC NE 0.
         MESSAGE E220 WITH P_BUKRS P_BTART V_LAST_DATE.
*Nincs beállítás a /ZAK/BNYLAP táblában! (Vállalat: &, típus: &, dátum:
*&).
       ENDIF.
     ENDIF.
*--BG 2008.03.26
     IF W_/ZAK/BNYLAP-VPOPAR IS INITIAL.
       MESSAGE E247.
*    Nincs beállítás a /ZAK/BNYLAP táblában VPOP arányosított abevhez!
     ENDIF.
*    Meghatározzuk, hogy melyik ABEV-ből kell az összeget másolni!
     READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY ABEVAZ = W_/ZAK/BNYLAP-VPOPAR.
     IF SY-SUBRC NE 0.
       MESSAGE E248 WITH W_/ZAK/BNYLAP-VPOPAR.
*   Hiányzik a & abev azonosító a /ZAK/BEVALLB táblában!
     ENDIF.
     IF W_/ZAK/BNYLAP-GET_ABEVAZ IS INITIAL.
       MESSAGE E249 WITH W_/ZAK/BEVALLB-ABEVAZ.
*Nincs beállítva & abev azonosítóhoz "átvétel abev" azonosítóból érték!
     ENDIF.
*    Beolvassuk a VPOP összesent
     READ TABLE I_OUTTAB INTO W_OUTTAB
          WITH KEY ABEVAZ = W_/ZAK/BNYLAP-GET_ABEVAZ.
     IF SY-SUBRC NE 0.
       MESSAGE E250 WITH W_/ZAK/BNYLAP-GET_ABEVAZ.
*   Nem leheta meghatározni az & abev azonosító értékét!
     ENDIF.
     W_OUTTAB-ABEVAZ = W_/ZAK/BNYLAP-VPOPAR.
     W_OUTTAB-ABEVAZ_DISP = W_/ZAK/BNYLAP-VPOPAR.
     W_OUTTAB-LAPSZ  = V_LAPSZ.
     SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
       FROM  /ZAK/BEVALLBT
             WHERE  LANGU   = SY-LANGU
             AND    BTYPE   = W_OUTTAB-BTYPE
             AND    ABEVAZ  = W_OUTTAB-ABEVAZ.
     W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.
*    Ellenőrizzük létezik e már a bejegyzés
     READ TABLE I_OUTTAB TRANSPORTING NO FIELDS
          WITH KEY ABEVAZ = W_/ZAK/BNYLAP-VPOPAR.
     IF SY-SUBRC NE 0.
       APPEND W_OUTTAB TO I_OUTTAB.
     ELSE.
       MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
     ENDIF.
   ENDIF.
*++1065 2010.02.15 BG
   IF NOT LR_ABEVAZ_DEL[] IS INITIAL.
     LOOP AT I_OUTTAB INTO W_OUTTAB WHERE ABEVAZ IN LR_ABEVAZ_DEL.
       CLEAR: W_OUTTAB-FIELD_N, W_OUTTAB-FIELD_NR, W_OUTTAB-FIELD_NRK.
       MODIFY I_OUTTAB FROM W_OUTTAB TRANSPORTING FIELD_N
                                                  FIELD_NR
                                                  FIELD_NRK.
     ENDLOOP.
   ENDIF.
*--1065 2010.02.15 BG
*++0011 BG 2008.03.28
* Ha van beállítás akkor a részletező sorok arány meghatározása
   REFRESH LR_ABEVAZ.
   SELECT * INTO TABLE I_/ZAK/AFA_RRABEV
   FROM /ZAK/AFA_RRABEV
   WHERE BTYPE EQ W_/ZAK/BEVALL-BTYPE.
   IF SY-SUBRC EQ 0.
     LOOP AT I_/ZAK/AFA_RRABEV INTO W_/ZAK/AFA_RRABEV WHERE NOT ABEVAZ IS
     INITIAL.
       M_DEF LR_ABEVAZ 'I' 'EQ' W_/ZAK/AFA_RRABEV-ABEVAZ SPACE.
     ENDLOOP.
   ENDIF.
   CHECK NOT LR_ABEVAZ[] IS INITIAL.
*  ABEVS összesen meghatározása ANALITIKA jelenlegi hónap - 1.
   REFRESH LI_ANALITIKA_ABEVS.
   REFRESH LI_ANALITIKA_ABEVS_A.
   REFRESH LI_BEVALLO_ABEVS.
   REFRESH LR_ABEVAZ_B.
   REFRESH LR_ABEVAZ_BS.
*++1665 #15.
*   SELECT  /ZAK/ANALITIKA~BTYPE
*           /ZAK/ANALITIKA~ABEVAZ
*           /ZAK/ANALITIKA~FIELD_N
*           /ZAK/ANALITIKA~MWSKZ
*           /ZAK/ANALITIKA~KTOSL
**++1665 #08.
*           /ZAK/ANALITIKA~ARANY_FLAG
**--1665 #08.
*                         INTO (L_BTYPE,
*                               LI_ANALITIKA_ABEVS-ABEVAZ,
*                               LI_ANALITIKA_ABEVS-FIELD_N,
*                               L_MWSKZ,
*                               L_KTOSL,
**++1665 #08.
*                               LI_ANALITIKA_ABEVS-ARANY_FLAG)
**--1665 #08.
*                         FROM  /ZAK/ANALITIKA INNER JOIN /ZAK/BEVALLI
*                           ON  /ZAK/BEVALLI~BUKRS  = /ZAK/ANALITIKA~BUKRS
*                          AND  /ZAK/BEVALLI~BTYPE  = /ZAK/ANALITIKA~BTYPE
*                          AND  /ZAK/BEVALLI~GJAHR  = /ZAK/ANALITIKA~GJAHR
*                          AND  /ZAK/BEVALLI~MONAT  = /ZAK/ANALITIKA~MONAT
*                          AND  /ZAK/BEVALLI~ZINDEX = /ZAK/ANALITIKA~ZINDEX
*                        WHERE  /ZAK/ANALITIKA~BUKRS EQ P_BUKRS
*                          AND  /ZAK/ANALITIKA~GJAHR EQ S_GJAHR-LOW
*                          AND  /ZAK/ANALITIKA~MONAT LE L_PREV_MONAT
*                          AND  /ZAK/ANALITIKA~BTYPE IN LR_BTYPE
*                          AND  /ZAK/ANALITIKA~ABEVAZ IN LR_ABEVAZ
*                          AND  /ZAK/BEVALLI~FLAG IN ('Z','X').
**    Áfa irány megahtározás
*     LM_0GET_AFABK L_KTOSL L_AFA_IRANY.
**    Csak bejovő kell
*     IF L_AFA_IRANY EQ 'B'.
*       M_DEF LR_ABEVAZ_B 'I' 'EQ' LI_ANALITIKA_ABEVS-ABEVAZ SPACE.
*       COLLECT LI_ANALITIKA_ABEVS.
*     ENDIF.
*   ENDSELECT.
*--1665 #15.
*  Jelenlegi hónap itt nem kell a státuszt figyelni
   SELECT  /ZAK/ANALITIKA~BTYPE
   /ZAK/ANALITIKA~ABEVAZ
   /ZAK/ANALITIKA~HKONT
   /ZAK/ANALITIKA~FIELD_N
   /ZAK/ANALITIKA~WAERS
   /ZAK/ANALITIKA~MWSKZ
   /ZAK/ANALITIKA~KTOSL
*++1665 #08.
   /ZAK/ANALITIKA~ARANY_FLAG
*--1665 #08.
   INTO (L_BTYPE,
   LI_ANALITIKA_ABEVS-ABEVAZ,
   LI_ANALITIKA_ABEVS_A-HKONT,
   LI_ANALITIKA_ABEVS-FIELD_N,
   LI_ANALITIKA_ABEVS_A-WAERS,
   L_MWSKZ,
   L_KTOSL,
*++1665 #08.
   LI_ANALITIKA_ABEVS-ARANY_FLAG)
*--1665 #08.
   FROM  /ZAK/ANALITIKA
   WHERE  /ZAK/ANALITIKA~BUKRS EQ P_BUKRS
   AND  /ZAK/ANALITIKA~GJAHR EQ S_GJAHR-LOW
*++1765 #21.
*                          AND  /ZAK/ANALITIKA~MONAT EQ S_MONAT-LOW
   AND  /ZAK/ANALITIKA~MONAT IN R_MONAT
*--1765 #21.
*++1765 #21.
*                          AND  /ZAK/ANALITIKA~ZINDEX EQ S_INDEX-LOW
   AND  /ZAK/ANALITIKA~ZINDEX IN S_INDEX
*--1765 #21.
   AND  /ZAK/ANALITIKA~BTYPE IN LR_BTYPE
   AND  /ZAK/ANALITIKA~ABEVAZ IN LR_ABEVAZ.
*    Áfa irány megahtározás
     LM_0GET_AFABK L_KTOSL L_AFA_IRANY.
*    Csak bejovő kell
     IF L_AFA_IRANY EQ 'B'.
       M_DEF LR_ABEVAZ_B 'I' 'EQ' LI_ANALITIKA_ABEVS-ABEVAZ SPACE.
*++1765 #15.
*       COLLECT LI_ANALITIKA_ABEVS.
*--1765 #15.
     ENDIF.
*++1765 #15.
     COLLECT LI_ANALITIKA_ABEVS.
     CLEAR LI_ANALITIKA_ABEVS.
*--1765 #15.
   ENDSELECT.
   IF L_PREV_MONAT NE '00'.
     LOOP AT LI_IDSZ.
*    ABEVS összesen meghatározása BEVALLO
*++1565 #14.
*       SELECT BTYPE ABEVAZ FIELD_NRK
       SELECT BTYPE ABEVAZ FIELD_N
*--1565 #14.
                             INTO (L_BTYPE,
                                   LI_BEVALLO_ABEVS-ABEVAZ,
                                   LI_BEVALLO_ABEVS-FIELD_N)
                             FROM  /ZAK/BEVALLO
                            WHERE  BUKRS EQ P_BUKRS
                              AND  GJAHR EQ LI_IDSZ-GJAHR
                              AND  MONAT EQ LI_IDSZ-MONAT
                              AND  ZINDEX EQ LI_IDSZ-ZINDEX
                              AND  BTYPE IN LR_BTYPE
                              AND  ABEVAZ IN LR_ABEVAZ.
         COLLECT LI_BEVALLO_ABEVS.
       ENDSELECT.
     ENDLOOP.
   ENDIF.
*  Adatok feldolgozása
   LOOP AT I_/ZAK/AFA_RRABEV INTO W_/ZAK/AFA_RRABEV.
*    Beolvassuk az OUTTAB sort
     LM_READ_ARANY_OUTTAB    W_/ZAK/AFA_RRABEV-ABEVAZ.
*    Beolvassuk az ANALITIKA sort
*++1665 #08.
*     LM_READ_ANALITIKA_ABEVS W_/ZAK/AFA_RRABEV-ABEVAZ ''.
     LM_READ_ANALITIKA_ABEVS W_/ZAK/AFA_RRABEV-ABEVAZ 'X'.
*--1665 #08.
*    Beállítások
     LM_READ_BEVALLO_ABEVS   W_/ZAK/AFA_RRABEV-ABEVAZ.
*    Arány meghatározás
*++1665 #08.
*     LM_GET_ARANY.
     LM_GET_ARANY W_/ZAK/AFA_RRABEV-ABEVAZ ''.
*--1665 #08.
   ENDLOOP.
*--0011 BG 2008.03.28
 ENDFORM.                    " AFA_ARANY
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO_FIELD_N  text
*      -->P_W_/ZAK/BEVALLO_ROUND  text
*      <--P_W_/ZAK/BEVALLO_FIELD_NR  text
*      <--P_W_/ZAK/BEVALLO_FIELD_NRK  text
*----------------------------------------------------------------------*
*++1565 #11.
* FORM CALC_FIELD_NRK USING    $FIELD_N   LIKE /ZAK/BEVALLO-FIELD_N
*                              $ROUND     LIKE /ZAK/BEVALLO-ROUND
*                              $WAERS
*                     CHANGING $FIELD_NR  LIKE /ZAK/BEVALLO-FIELD_NR
*                              $FIELD_NRK LIKE /ZAK/BEVALLO-FIELD_NRK.
 FORM CALC_FIELD_NRK USING    $FIELD_N
                              $ROUND
                              $WAERS
                     CHANGING $FIELD_NR
                              $FIELD_NRK.
*--1565 #11.
   DATA: L_ROUND(20) TYPE C.
*++1465 #04.
   DATA: L_CURRDEC TYPE CURRDEC.
   READ TABLE I_TCURX WITH KEY CURRKEY = $WAERS.
   IF SY-SUBRC NE 0.
     SELECT * APPENDING TABLE I_TCURX
                     FROM TCURX
                    WHERE CURRKEY = $WAERS.
     IF SY-SUBRC NE 0.
       I_TCURX-CURRKEY = $WAERS.
       I_TCURX-CURRDEC = 2.
       APPEND I_TCURX.
     ENDIF.
     READ TABLE I_TCURX WITH KEY CURRKEY = $WAERS.
   ENDIF.
   L_CURRDEC =  I_TCURX-CURRDEC + $ROUND.
*--1465 #04.
   CLEAR L_ROUND.
   WRITE $FIELD_N TO L_ROUND
*++1465 #04.
*       ROUND $ROUND NO-GROUPING.
       ROUND L_CURRDEC NO-GROUPING.
*--1465 #04.
   REPLACE ',' WITH '.'
                        INTO L_ROUND.
   $FIELD_NR = L_ROUND.
*++1465 #04.
   IF NOT I_TCURX-CURRDEC IS INITIAL.
     $FIELD_NR = $FIELD_NR * ( 10 ** I_TCURX-CURRDEC ).
   ENDIF.
*--1465 #04.
   $FIELD_NRK = $FIELD_NR * ( 10 ** $ROUND ).
 ENDFORM.                    " CALC_FIELD_NRK
*&---------------------------------------------------------------------*
*&      Form  GET_CS_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_BUKCS  text
*      -->P_I_BUKRS  text
*----------------------------------------------------------------------*
 FORM GET_CS_BUKRS TABLES   $I_BUKRS STRUCTURE /ZAK/AFACS_BUKRS
                            $R_BUKRS STRUCTURE RANGE_C4
                   USING    $BUKRS
                            $BUKCS
                            $BTYPE
                            $DATE.
   CALL FUNCTION '/ZAK/GET_BUKRS_FROM_BUKCS'
     EXPORTING
       I_BUKCS      = $BUKRS
       I_BTYPE      = $BTYPE
       I_DATUM      = $DATE
     IMPORTING
       E_BUKCS_FLAG = $BUKCS
     TABLES
       T_BUKRS      = $I_BUKRS.
   IF $BUKCS IS INITIAL.
     $I_BUKRS-BUKRS = $BUKRS.
     APPEND $I_BUKRS.
   ENDIF.
*Range feltöltése:
   LOOP AT $I_BUKRS.
     M_DEF $R_BUKRS 'I' 'EQ' $I_BUKRS-BUKRS SPACE.
   ENDLOOP.
*++1765 #06.
**Ha csoport vállalat és nem megjelenítés és nem ONYB
*   CHECK NOT $BUKCS IS INITIAL
*     AND NOT P_N IS INITIAL
*     AND P_BTART <> C_BTYPART_ONYB.
** Ellenőrizzük, hogy minden vállalat státusza legalább letöltött e
*   LOOP AT $I_BUKRS.
*     SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALLI
*                             WHERE BUKRS EQ $I_BUKRS-BUKRS
*                               AND BTYPE EQ $BTYPE
*                               AND GJAHR IN S_GJAHR
*                               AND MONAT IN S_MONAT
*                               AND ZINDEX IN S_INDEX
*                               AND FLAG EQ 'T'.
*     IF SY-SUBRC NE 0.
*       MESSAGE E294 WITH $I_BUKRS-BUKRS.
**   & vállalat APEH fájl készítés még nem futott a megadott időszakra!
*     ENDIF.
*   ENDLOOP.
*2017.02.12 Átalakítára került mivel az ONYB-nél is figyelni kell de
*nem biztos, hogy minden csoportvállalatnak van rekordja!
   DATA L_FLAG TYPE /ZAK/FLAG.
   CHECK NOT $BUKCS IS INITIAL
      AND NOT P_N IS INITIAL.
* Ellenőrizzük, hogy minden vállalat státusza legalább letöltött e
   LOOP AT $I_BUKRS.
     CLEAR L_FLAG.
     SELECT SINGLE FLAG INTO L_FLAG
                        FROM /ZAK/BEVALLI
                       WHERE BUKRS EQ $I_BUKRS-BUKRS
                         AND BTYPE EQ $BTYPE
                         AND GJAHR IN S_GJAHR
                         AND MONAT IN S_MONAT
                         AND ZINDEX IN S_INDEX.
*    Ha ÁFA akkor kell lennie bejegyzésnek T státusszal
*++1765 #07.
*    és nem migráció
*     IF P_BTART = C_BTYPART_AFA AND ( SY-SUBRC NE 0 OR L_FLAG NE 'T' ).
     IF P_BTART = C_BTYPART_AFA AND ( SY-SUBRC NE 0 OR L_FLAG NE 'T' ) AND
       P_MIGR IS INITIAL.
*--1765 #07.
       MESSAGE E294 WITH $I_BUKRS-BUKRS.
*      & vállalat APEH fájl készítés még nem futott a megadott időszakra!
*    Ha ONYB és van bejegyzés akkor az csak  T státusz lehet
*++1765 #07.
*    és nem migráció
*     ELSEIF  P_BTART = C_BTYPART_ONYB AND SY-SUBRC EQ 0 AND L_FLAG NE 'T'.
     ELSEIF  P_BTART = C_BTYPART_ONYB AND SY-SUBRC EQ 0 AND L_FLAG NE 'T' AND
       P_MIGR IS INITIAL.
*--1765 #07.
       MESSAGE E294 WITH $I_BUKRS-BUKRS.
*      & vállalat APEH fájl készítés még nem futott a megadott időszakra!
     ENDIF.
   ENDLOOP.
*--1765 #06.
 ENDFORM.                    " GET_CS_BUKRS
*&---------------------------------------------------------------------*
*&      Module  CHECK_ANALITIKA_MS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_ANALITIKA_MS INPUT.
   DATA L_DATUM     TYPE DATUM.
   DATA L_FIELDTYPE TYPE /ZAK/FIELDTYPE.
   CHECK NOT /ZAK/ANAL_MS-MSFLAG IS INITIAL.
   IF /ZAK/ANAL_MS-BTYPE IS INITIAL OR
      /ZAK/ANAL_MS-ABEVAZ IS INITIAL OR
      /ZAK/ANAL_MS-GJAHR IS INITIAL OR
      /ZAK/ANAL_MS-MONAT IS INITIAL.
     MESSAGE E303.
*   Kérem ellenpár könyvelésnél adjon meg minden értéket!
   ENDIF.
*  Dátum eltérő legyen
   IF /ZAK/ANALITIKA_S-GJAHR EQ /ZAK/ANAL_MS-GJAHR AND
      /ZAK/ANALITIKA_S-MONAT EQ /ZAK/ANAL_MS-MONAT.
     MESSAGE E301.
*   Kérem ellenpár rögzítésénél eltérő időszakot adjon meg!
   ENDIF.
*  Sztornó előjegyzés ellenpár rögzítés vizsgálat
   IF NOT /ZAK/ANALITIKA_S-VORSTOR IS INITIAL.
     MESSAGE E302.
*   Kérem ne használja a sztornó előjegyzés és ellenpár könyvelést egysz
   ENDIF.
*  IDŐSZAK BTYPE ellenőrzés
   CONCATENATE /ZAK/ANAL_MS-GJAHR
               /ZAK/ANAL_MS-MONAT
               '01' INTO L_DATUM.
   CALL FUNCTION 'LAST_DAY_OF_MONTHS' "#EC CI_USAGE_OK[2296016]
     EXPORTING
       DAY_IN            = L_DATUM
     IMPORTING
       LAST_DAY_OF_MONTH = L_DATUM.
   SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALL
                           WHERE BUKRS EQ /ZAK/ANAL_MS-BUKRS
                             AND BTYPE EQ /ZAK/ANAL_MS-BTYPE
                             AND DATBI GE L_DATUM
                             AND DATAB LE L_DATUM.
   IF SY-SUBRC NE 0.
     MESSAGE E185 WITH /ZAK/ANAL_MS-BTYPE L_DATUM.
*   & bevallás típus & napon nem érvényes
   ENDIF.
*  ABEVAZ mező típus ellenőrzése
   SELECT SINGLE FIELDTYPE INTO L_FIELDTYPE
                           FROM /ZAK/BEVALLB
                          WHERE BTYPE  EQ /ZAK/ANAL_MS-BTYPE
                            AND ABEVAZ EQ /ZAK/ANAL_MS-ABEVAZ.
   IF L_FIELDTYPE NE 'N'.
     MESSAGE E304.
*   Kérem numerikus típusú ABEV azonosítót válasszon!
   ENDIF.
 ENDMODULE.                 " CHECK_ANALITIKA_MS  INPUT
*&---------------------------------------------------------------------*
*&      Form  SAVE_ITEM_MS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_ITEM_MS .
   DATA: T_/ZAK/ANALITIKA  TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
         LT_/ZAK/ANALITIKA TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
         L_/ZAK/ANALITIKA  TYPE /ZAK/ANALITIKA,
         W_RETURN         TYPE BAPIRET2.
   DATA: L_ROUND(20) TYPE C.
*++0017 BG 2012.02.07
   DATA: L_ITEM LIKE /ZAK/ANALITIKA-ITEM.
   DATA: L_FLAG LIKE /ZAK/BEVALLI-FLAG.
   DEFINE LM_NEXT_ITEM_S.
     CLEAR /zak/analitika.
* Utolsó Tételszám
     SELECT MAX( item ) INTO l_item
         FROM /zak/analitika
        WHERE bukrs   = &1-bukrs
          AND btype   = &1-btype
          AND gjahr   = &1-gjahr
          AND monat   = &1-monat
          AND zindex  = &1-zindex
          AND abevaz  = &1-abevaz
          AND adoazon = &1-adoazon
          AND bsznum  = &1-bsznum
          AND pack    = &1-pack.
     l_item = l_item + 1.
     &1-item  = l_item.
   END-OF-DEFINITION.
*--0017 BG 2012.02.07
   REFRESH T_/ZAK/ANALITIKA.
* Új tétel
   CLEAR /ZAK/ANALITIKA-ZINDEX.
   APPEND /ZAK/ANALITIKA TO T_/ZAK/ANALITIKA.
*  Először teszt-ben futtatjuk, hogy meghatározzuk a ZINDEX-et
   PERFORM CALL_UPDATE TABLES I_RETURN
                              T_/ZAK/ANALITIKA
                       USING  /ZAK/ANALITIKA-BUKRS
                              /ZAK/ANALITIKA-BTYPE
                              /ZAK/ANALITIKA-BSZNUM
*                             /ZAK/ANALITIKA-PACK
                              SPACE
                              SPACE
                              'X'. "Teszt mód
   READ TABLE T_/ZAK/ANALITIKA INTO L_/ZAK/ANALITIKA INDEX 1.
   LM_NEXT_ITEM_S L_/ZAK/ANALITIKA.
*++1765 #25.
*   MODIFY T_/ZAK/ANALITIKA FROM L_/ZAK/ANALITIKA INDEX 1 TRANSPORTING
*   ITEM.                                          "#EC CI_NOORDER
*  Nem kell index mert majd az UPDATE fogja meghatározni és létrehozni,
*  viszont az ITEM kell mert már lehet abban az időszakban rögzítés
*  ahová átvisszük!
   CLEAR: L_/ZAK/ANALITIKA-ZINDEX.
   MODIFY T_/ZAK/ANALITIKA FROM L_/ZAK/ANALITIKA INDEX 1 TRANSPORTING
   ZINDEX ITEM.                                         "#EC CI_NOORDER
*--1765 #25.
*  Státusz ellenőrzése
   SELECT SINGLE FLAG INTO L_FLAG
                      FROM /ZAK/BEVALLI
                     WHERE BUKRS EQ L_/ZAK/ANALITIKA-BUKRS
                       AND BTYPE EQ L_/ZAK/ANALITIKA-BTYPE
                       AND MONAT EQ L_/ZAK/ANALITIKA-MONAT
                       AND ZINDEX EQ L_/ZAK/ANALITIKA-ZINDEX.
   IF SY-SUBRC EQ 0 AND L_FLAG EQ 'T'.
     MESSAGE I900.
*    Ellenpár rögzítés időszaka már letöltésre került!
   ENDIF.
   PERFORM CALL_UPDATE TABLES I_RETURN
                              T_/ZAK/ANALITIKA
                       USING  /ZAK/ANALITIKA-BUKRS
                              /ZAK/ANALITIKA-BTYPE
                              /ZAK/ANALITIKA-BSZNUM
*                             /ZAK/ANALITIKA-PACK
                              SPACE
                              SPACE
                              SPACE.
 ENDFORM.                    " SAVE_ITEM_MS
*&---------------------------------------------------------------------*
*&      Form  GET_OMREL_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_ABEVAZ_DUMMY01  text
*----------------------------------------------------------------------*
 FORM GET_OMREL_PROC  USING    $ABEVAZ_DUMMY
                               $NYLAPAZON.
   DATA LI_ANALITIKA_0102K TYPE TABLE OF /ZAK/ANAL_0102K INITIAL
   SIZE 0.
*++1365 #9.
   DATA LI_ANALITIKA_0102K_SORT TYPE TABLE OF /ZAK/ANAL_0102K
                                INITIAL SIZE 0.
*--1365 #9.
   DATA LW_ANALITIKA_0102K TYPE /ZAK/ANAL_0102K.
   DATA L_TEXT TYPE STRING.
   DATA L_LAPSZ TYPE /ZAK/LAPSZ.
   DATA L_LAPSZ_SAVE TYPE /ZAK/LAPSZ.
   DATA L_SORSZ TYPE NUMC2.
   DATA L_MAX_SORSZ TYPE NUMC2.
   DATA L_SORINDEX TYPE /ZAK/SORINDEX.
   DATA L_SUBRC LIKE SY-SUBRC.
*++1365 #3.
*  Adóazonosítók gyűjtése
   RANGES LR_ADOAZON FOR /ZAK/ANALITIKA-ADOAZON.
*--1365 #3.
*++1365 #12.
*  Számla  E, KT, K rendezéshez adatok
   TYPES: BEGIN OF LT_DATA_SORT,
            ADOAZON   TYPE /ZAK/ADOAZON,
            SZAMLASZA TYPE /ZAK/SZAMLASZA,
          END OF  LT_DATA_SORT.
   DATA LI_DATA_SORT TYPE STANDARD TABLE OF LT_DATA_SORT INITIAL SIZE 0.
   DATA LW_DATA_SORT TYPE LT_DATA_SORT.
*--1365 #12.
   DEFINE M_GET_ABEV_TO_INDEX_0102K.
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
*++1765 #24.
   DEFINE LM_MOVE.
     IF NOT &1 IS INITIAL.
       MOVE &1 TO &2.
     ENDIF.
   END-OF-DEFINITION.
*--1765 #24.
   REFRESH LI_ANALITIKA_0102K.
*++1365 #3.
   REFRESH LR_ADOAZON.
*--1365 #3.
*++1365 #12.
   REFRESH LI_DATA_SORT.
*--1365 #12.
   LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
               WHERE ABEVAZ    = $ABEVAZ_DUMMY
                 AND NYLAPAZON = $NYLAPAZON.
     CLEAR   LW_ANALITIKA_0102K.
     MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO LW_ANALITIKA_0102K.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_ZF_01 SPOTS /ZAK/MAIN_ES .
*    IDŐSZAKok
     READ TABLE S_INDEX INDEX 1.
     LW_ANALITIKA_0102K-ZINDEX = S_INDEX-HIGH.
     READ TABLE R_MONAT INDEX 1.
     LW_ANALITIKA_0102K-MONAT = R_MONAT-HIGH.
     COLLECT LW_ANALITIKA_0102K INTO LI_ANALITIKA_0102K.
*++1365 #3.
     M_DEF LR_ADOAZON 'I' 'EQ' W_/ZAK/ANALITIKA-ADOAZON SPACE.
*--1365 #3.
*++1365 #12.
     CLEAR LW_DATA_SORT.
     LW_DATA_SORT-ADOAZON    = W_/ZAK/ANALITIKA-ADOAZON.
     LW_DATA_SORT-SZAMLASZA  = W_/ZAK/ANALITIKA-SZAMLASZA.
     COLLECT LW_DATA_SORT INTO LI_DATA_SORT.
*--1365 #12.
   ENDLOOP.
   DELETE LI_ANALITIKA_0102K WHERE LWSTE IS INITIAL
                               AND LWBAS IS INITIAL.
   CLEAR V_NYLAPAZON.
*   l_text = $abevaz_dummy.
*   SHIFT l_text LEFT  DELETING LEADING 'DUMMY'.
   V_NYLAPAZON = $NYLAPAZON.
*   IF v_nylapazon IS INITIAL OR
*    ( v_nylapazon NE c_nylapazon_01 AND
*      v_nylapazon NE c_nylapazon_01_k AND
*      v_nylapazon NE c_nylapazon_02 AND
*      v_nylapazon NE c_nylapazon_02_k ).
*     MESSAGE e351 WITH $abevaz_dummy.
**   & abev-ből nem lehet érvényes nyomtatvány lap azonosítót
*meghatározni!
*   ENDIF.
*++1365 #9.
*  Analitika tábla rendezés
   FREE LI_ANALITIKA_0102K_SORT.
   SORT LI_ANALITIKA_0102K BY ADOAZON.
*++1365 #11.
*++1365 #12.
*   SORT LR_ADOAZON BY LOW.
*   LOOP AT LR_ADOAZON.
   SORT LI_DATA_SORT.
   LOOP AT LI_DATA_SORT INTO LW_DATA_SORT.
*--1365 #12.
*--1365 #11.
*  1. E-s tételek
     LOOP AT LI_ANALITIKA_0102K INTO LW_ANALITIKA_0102K
*++1365 #11.
*                              WHERE SZLATIP EQ C_SZLATIP_E.
*++1365 #12.
*                              WHERE ADOAZON EQ LR_ADOAZON-LOW
                               WHERE ADOAZON   EQ LW_DATA_SORT-ADOAZON
                                 AND SZAMLASZA EQ LW_DATA_SORT-SZAMLASZA
*--1365 #12.
                                 AND SZLATIP EQ C_SZLATIP_E.
*--1365 #11.
       APPEND LW_ANALITIKA_0102K TO LI_ANALITIKA_0102K_SORT.
       DELETE LI_ANALITIKA_0102K.
     ENDLOOP.
*  2. KT-s tételek
     LOOP AT LI_ANALITIKA_0102K INTO LW_ANALITIKA_0102K
*++1365 #11.
*                               WHERE SZLATIP EQ C_SZLATIP_KT.
*++1365 #12.
*                              WHERE ADOAZON EQ LR_ADOAZON-LOW
                               WHERE ADOAZON   EQ LW_DATA_SORT-ADOAZON
                                 AND SZAMLASZA EQ LW_DATA_SORT-SZAMLASZA
*--1365 #12.
                                 AND SZLATIP EQ C_SZLATIP_KT.
*--1365 #11.
       APPEND LW_ANALITIKA_0102K TO LI_ANALITIKA_0102K_SORT.
       DELETE LI_ANALITIKA_0102K.
     ENDLOOP.
*++2165 #02.
     IF W_/ZAK/BEVALL-M02KNO IS INITIAL.
*--2165 #02.
*  3. K-s tételek
       LOOP AT LI_ANALITIKA_0102K INTO LW_ANALITIKA_0102K
*++1365 #11.
*                               WHERE SZLATIP EQ C_SZLATIP_KT.
*++1365 #12.
*                              WHERE ADOAZON EQ LR_ADOAZON-LOW
                                 WHERE ADOAZON   EQ LW_DATA_SORT-ADOAZON
                                   AND SZAMLASZA EQ LW_DATA_SORT-SZAMLASZA
*--1365 #12.
                                   AND SZLATIP EQ C_SZLATIP_K.
*--1365 #11.
         APPEND LW_ANALITIKA_0102K TO LI_ANALITIKA_0102K_SORT.
         DELETE LI_ANALITIKA_0102K.
       ENDLOOP.
*++2165 #02.
     ENDIF.
*--2165 #02.
*++1365 #11.
   ENDLOOP.
*--1365 #11.
   FREE LI_ANALITIKA_0102K.
   LI_ANALITIKA_0102K[] = LI_ANALITIKA_0102K_SORT[].
   FREE LI_ANALITIKA_0102K_SORT.
*--1365 #9.
*++1365 #3.
*  Feldolgozás adószámonként
   LOOP AT LR_ADOAZON.
*--1365 #3.
     CLEAR L_MAX_SORSZ.
*  Megatározzuk a legnagyobb sor-indexet
     LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                          WHERE NOT SORINDEX IS INITIAL
                            AND NYLAPAZON EQ V_NYLAPAZON.
       IF W_/ZAK/BEVALLB-SORINDEX(2) > L_MAX_SORSZ.
         MOVE W_/ZAK/BEVALLB-SORINDEX(2) TO L_MAX_SORSZ.
       ENDIF.
     ENDLOOP.
     IF SY-SUBRC NE 0.
       MESSAGE E221 WITH P_BTART.
*Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához!
     ENDIF.
     L_LAPSZ = 1.
     L_SORSZ = 1.
*  Ha van adat, feldolgozás
*++1365 #3.
*   LOOP AT LI_ANALITIKA_0102K INTO LW_ANALITIKA_0102K.
     LOOP AT LI_ANALITIKA_0102K INTO LW_ANALITIKA_0102K
                               WHERE ADOAZON EQ LR_ADOAZON-LOW.
*--1365 #3.
*  Adatok feltöltése
       CLEAR W_OUTTAB.
       IF L_SORSZ > L_MAX_SORSZ.
         ADD 1 TO L_LAPSZ.
         L_SORSZ = 1.
       ENDIF.
       CASE V_NYLAPAZON.
         WHEN C_NYLAPAZON_M01.
*        Számla sorszáma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'A' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZAMLASZ TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Teljesítés dátuma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'B' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
*++1765 #24.
*             MOVE LW_ANALITIKA_0102K-BLDAT    TO W_OUTTAB-FIELD_C.
             LM_MOVE LW_ANALITIKA_0102K-BLDAT  W_OUTTAB-FIELD_C.
*--1765 #24.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adóalap
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'C' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWBAS    TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adó
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'D' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWSTE    TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
         WHEN C_NYLAPAZON_M01_K.
*        Számla sorszáma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'A' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZAMLASZ TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Számla típus
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'B' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZLATIP TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Előzmény számla sorszáma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'C' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZAMLASZE TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Számlakibocsátás dátuma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'D' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
*++1765 #24.
*             MOVE LW_ANALITIKA_0102K-SZAMLAKELT TO W_OUTTAB-FIELD_C.
             LM_MOVE LW_ANALITIKA_0102K-SZAMLAKELT W_OUTTAB-FIELD_C.
*--1765 #24.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Teljesítés dátuma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'E' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
*++1765 #24.
*             MOVE LW_ANALITIKA_0102K-BLDAT TO W_OUTTAB-FIELD_C.
             LM_MOVE LW_ANALITIKA_0102K-BLDAT W_OUTTAB-FIELD_C.
*--1765 #24.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adóalap
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'F' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWBAS TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adó
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'G' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWSTE TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
         WHEN C_NYLAPAZON_M02.
*        Számla sorszáma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'A' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZAMLASZ TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Teljesítés dátuma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'B' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
*++1765 #24.
*             MOVE LW_ANALITIKA_0102K-BLDAT TO W_OUTTAB-FIELD_C.
             LM_MOVE LW_ANALITIKA_0102K-BLDAT W_OUTTAB-FIELD_C.
*--1765 #24.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adóalap
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'C' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWBAS TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adó
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'D' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWSTE TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*++2165 #02.
*       Előlegből adódó különbözet jelölése
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'E' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-ELSTAD   TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*--2165 #02.
         WHEN C_NYLAPAZON_M02_K.
*        Számla sorszáma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'A' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZAMLASZ TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Számla típus
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'B' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZLATIP TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Előzmény számla sorszáma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'C' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-SZAMLASZE TO W_OUTTAB-FIELD_C.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Számlakibocsátás dátuma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'D' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
*++1765 #24.
*             MOVE LW_ANALITIKA_0102K-SZAMLAKELT TO W_OUTTAB-FIELD_C.
             LM_MOVE LW_ANALITIKA_0102K-SZAMLAKELT W_OUTTAB-FIELD_C.
*--1765 #24.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Teljesítés dátuma
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'E' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
*++1765 #24.
*             MOVE LW_ANALITIKA_0102K-BLDAT TO W_OUTTAB-FIELD_C.
             LM_MOVE LW_ANALITIKA_0102K-BLDAT W_OUTTAB-FIELD_C.
*--1765 #24.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adóalap
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'F' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWBAS TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
*        Adó
           M_GET_ABEV_TO_INDEX_0102K L_SORSZ 'G' L_SUBRC V_NYLAPAZON.
           IF L_SUBRC IS INITIAL.
             MOVE L_LAPSZ TO W_OUTTAB-LAPSZ.
             MOVE LW_ANALITIKA_0102K-ADOAZON  TO W_OUTTAB-ADOAZON.
             MOVE LW_ANALITIKA_0102K-LWSTE TO W_OUTTAB-FIELD_N.
             APPEND W_OUTTAB TO I_OUTTAB.
             CLEAR W_OUTTAB.
           ENDIF.
       ENDCASE.
       ADD 1 TO L_SORSZ.
     ENDLOOP.
*++1365 #3.
   ENDLOOP.
*--1365 #3.
 ENDFORM.                    " GET_OMREL_PROC
*&---------------------------------------------------------------------*
*&      Form  SUM_GEN_OMREL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_ABEVAZ_DUMMY_R  text
*----------------------------------------------------------------------*
 FORM SUM_GEN_OMREL  USING   $ABEVAZ_DUMMY_R
                             $ABEVAZ_DUMMY_M
                             $BTYPE
                             $OLWSTE.
   DATA LW_AFA_SZLA     TYPE /ZAK/AFA_SZLA.
*  Feldolgozott azonosítók gyűjtése
   DATA LI_AFA_SZLA     TYPE STANDARD TABLE OF /ZAK/AFA_SZLA.
*++1365 #21.
*   DATA li_proc_szla    TYPE STANDARD TABLE OF /zak/afa_szla.
   DATA LI_PROC_SZLA    TYPE SORTED TABLE OF /ZAK/AFA_SZLA
                        WITH NON-UNIQUE KEY BUKRS ADOAZON SZAMLASZA
                                            NYLAPAZON.
*--1365 #21.
   DATA LW_PROC_SZLA    TYPE /ZAK/AFA_SZLA.
   DATA L_TABIX LIKE SY-TABIX.
   DATA L_OLWSTE        TYPE /ZAK/LWSTE.
*++1865 #13.
   DATA L_OLWSTE_M01    TYPE /ZAK/LWSTE.
   DATA L_M01VALID      TYPE DATUM.
*--1865 #13.
   DATA LW_/ZAK/ANALITIKA_SAVE TYPE /ZAK/ANALITIKA.
*++2465 #02.
   DATA LW_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
*--2465 #02.
   DATA LW_AFA_SZLA_SUM TYPE /ZAK/AFA_SZLASUM.
   DATA L_AMOUNT_EXTERNAL LIKE  BAPICURR-BAPICURR.
   DATA LW_ADOAZON LIKE I_ADOAZON.
   DATA L_NYLAPAZON_FLAG TYPE /ZAK/NYLAPAZON.
   DATA LS_BEVALLB TYPE /ZAK/BEVALLB.
   DATA L_FIELD_NR  TYPE /ZAK/FIELDNR.
   DATA L_FIELD_NRK TYPE /ZAK/FIELDNRK.
*++1365 #3.
   DATA LW_ANALITIKA_E_SAVE TYPE /ZAK/ANALITIKA.
   DATA L_E_GEN TYPE XFELD. "E számlatípus kell a normál lapra is.
*--1365 #3.
*++1365 #16.
   DATA L_BUKRS TYPE BUKRS.
*--1365 #16.
*++1965 #04.
   DATA L_PADOSZ TYPE /ZAK/PADOSZ.
   DATA L_STCD3  TYPE STCD3.
   FIELD-SYMBOLS <LFS1> LIKE LINE OF I_/ZAK/ANALITIKA.
   FIELD-SYMBOLS <LFS2> LIKE LINE OF I_AFA_SZLA_SUM.
   DATA L_ADOAZON_SAVE  TYPE /ZAK/ADOAZON.
   DATA LI_AFA_SZLA_SUM TYPE STANDARD TABLE OF /ZAK/AFA_SZLASUM .
*--1965 #04.

   CHECK NOT $OLWSTE IS INITIAL.
   SELECT SINGLE * INTO LS_BEVALLB
                   FROM /ZAK/BEVALLB
                  WHERE BTYPE  EQ $BTYPE
                    AND ABEVAZ EQ $ABEVAZ_DUMMY_M.
   L_AMOUNT_EXTERNAL = $OLWSTE.
   CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
     EXPORTING
       CURRENCY             = C_HUF
       AMOUNT_EXTERNAL      = L_AMOUNT_EXTERNAL
       MAX_NUMBER_OF_DIGITS = 20
     IMPORTING
       AMOUNT_INTERNAL      = L_OLWSTE
*      RETURN               =
     .
*++1865 #13.
*  Ellenőritni kell az M01 lapérvényességét:
   SELECT SINGLE M01VALID INTO L_M01VALID
                          FROM /ZAK/START
                         WHERE BUKRS EQ P_BUKRS.
   IF SY-SUBRC EQ 0 AND NOT L_M01VALID IS INITIAL AND L_M01VALID <= V_LAST_DATE.
*    Meg kell keresni az érvényesség végén érvényes kulcsot
     SELECT SINGLE OLWSTE INTO L_OLWSTE_M01
                          FROM /ZAK/BEVALL
                         WHERE BUKRS EQ P_BUKRS
                           AND DATBI GE L_M01VALID
                           AND DATAB LE L_M01VALID
                           AND BTYPART EQ C_BTYPART_AFA.
     IF SY-SUBRC EQ 0 AND NOT L_OLWSTE_M01 IS INITIAL.
       L_AMOUNT_EXTERNAL = L_OLWSTE_M01.
       CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
         EXPORTING
           CURRENCY             = C_HUF
           AMOUNT_EXTERNAL      = L_AMOUNT_EXTERNAL
           MAX_NUMBER_OF_DIGITS = 20
         IMPORTING
           AMOUNT_INTERNAL      = L_OLWSTE_M01
*          RETURN               =
         .
     ELSE.
       L_OLWSTE_M01 = L_OLWSTE.
     ENDIF.
   ELSE.
     L_OLWSTE_M01 = L_OLWSTE.
   ENDIF.
*--1865 #13.

   LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
                          WHERE ABEVAZ  = $ABEVAZ_DUMMY_R.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_04 SPOTS /ZAK/MAIN_ES .
*   Adószámok gy#jtése
     LW_ADOAZON-ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
     COLLECT LW_ADOAZON INTO I_ADOAZON.
*   Elmentjük az új ANALITIKA sorok létrehozásához
     IF LW_/ZAK/ANALITIKA_SAVE IS INITIAL.
       LW_/ZAK/ANALITIKA_SAVE = W_/ZAK/ANALITIKA.
     ENDIF.
*++1365 #16.
*    Csoportos vállalat kezelés
     IF NOT V_BUKCS IS INITIAL.
       L_BUKRS = W_/ZAK/ANALITIKA-FI_BUKRS.
     ELSE.
       L_BUKRS = W_/ZAK/ANALITIKA-BUKRS.
     ENDIF.
*--1365 #16.
*++1365 #21.
**  Számla azonosító meghatározása
*     SELECT SINGLE * INTO lw_afa_szla
*                     FROM /zak/afa_szla
**++1365 #16.
**                    WHERE BUKRS     EQ W_/ZAK/ANALITIKA-BUKRS
*                    WHERE bukrs     EQ l_bukrs
**--1365 #16.
*                      AND adoazon   EQ w_/zak/analitika-adoazon
*                      AND szamlasz  EQ w_/zak/analitika-szamlasz
*                      AND nylapazon EQ w_/zak/analitika-nylapazon(3).
*     IF sy-subrc NE 0.
**++1365 #16.
**       MESSAGE E305 WITH W_/ZAK/ANALITIKA-BUKRS W_/ZAK/ANALITIKA-ADOAZON
*       MESSAGE e305 WITH l_bukrs w_/zak/analitika-adoazon
**--1365 #16.
*       w_/zak/analitika-szamlasz.
**       Hiba a &/&/& számla adatainak meghatározásánál!
*     ENDIF.
**++1365 #13.
**    NONEED-et külön kell ellen#rizni! Lehet olyan eset, hogy
**    többször szerepel amib#l van olyan amiben a NONEED üres!
***    Ha nem releváns akkor nem dolgozzuk fel
**     IF NOT LW_AFA_SZLA-NONEED IS INITIAL.
**       CONTINUE.
**     ENDIF.
*     SELECT SINGLE COUNT( * )
*                     FROM /zak/afa_szla
**++1365 #16.
**                    WHERE BUKRS     EQ W_/ZAK/ANALITIKA-BUKRS
*                    WHERE bukrs     EQ l_bukrs
**--1365 #16.
*                      AND adoazon   EQ w_/zak/analitika-adoazon
*                      AND szamlasz  EQ w_/zak/analitika-szamlasz
*                      AND nylapazon EQ w_/zak/analitika-nylapazon(3)
*                      AND noneed    NE 'X'.
*     IF sy-subrc NE 0.
*       CONTINUE.
*     ENDIF.
**--1365 #13.
**    Ellen#rizzük, hogy feldolgoztuk e már a számlát
*     READ TABLE li_proc_szla TRANSPORTING NO FIELDS
*                WITH KEY bukrs     = lw_afa_szla-bukrs
*                         adoazon   = lw_afa_szla-adoazon
*                         szamlasza = lw_afa_szla-szamlasza
*                         nylapazon = lw_afa_szla-nylapazon
*                         BINARY SEARCH.
*     CHECK sy-subrc NE 0.
*     REFRESH li_afa_szla.
*     SELECT * INTO TABLE li_afa_szla
*              FROM /zak/afa_szla
*             WHERE bukrs     EQ lw_afa_szla-bukrs
*               AND adoazon   EQ lw_afa_szla-adoazon
*               AND szamlasza EQ lw_afa_szla-szamlasza
*               AND nylapazon EQ lw_afa_szla-nylapazon
**++1365 #14.
*               AND noneed    NE 'X'
**--1365 #14.
**++1365 #15.
*               AND ( ( gjahr LT s_gjahr-low ) OR
*                     ( gjahr EQ s_gjahr-low AND
*                       monat LE r_monat-high ) ).
**--1365 #15.
**++1365 #18.
**    Kell egy külön feldolgozás ami ellen#rzi, hogy az E-s
**    rekordhoz létezik e K-s pár. Ha nem akkor összesítés
**    el#tt csak az az E-s rekord maradhat ami az id#s/zak/zakba
**    esik. Pld: van egy számla a következ# hónapban újra
**    létrehozzák majd sztornózzák, ebben az esetben mi
**    mindkét id#s/zak/zakban szerepeltetnénk a számlát ami nem
**    megfelel#:
*Optimalizálás, hogy a /ZAK/AFA_SZLA-t csak egyszer olvassuk
     REFRESH LI_AFA_SZLA.
     SELECT  * INTO TABLE LI_AFA_SZLA
                     FROM /ZAK/AFA_SZLA
                    WHERE BUKRS     EQ L_BUKRS
                      AND ADOAZON   EQ W_/ZAK/ANALITIKA-ADOAZON
                      AND SZAMLASZA EQ W_/ZAK/ANALITIKA-SZAMLASZA
                      AND NYLAPAZON EQ W_/ZAK/ANALITIKA-NYLAPAZON(3).
     IF SY-SUBRC NE 0.
       MESSAGE E305 WITH L_BUKRS W_/ZAK/ANALITIKA-ADOAZON
       W_/ZAK/ANALITIKA-SZAMLASZA.
*       Hiba a &/&/& számla adatainak meghatározásánál!
     ELSE.
       SORT LI_AFA_SZLA BY BUKRS ADOAZON SZAMLASZ NYLAPAZON NONEED.
       READ TABLE LI_AFA_SZLA TRANSPORTING NO FIELDS
                  WITH KEY BUKRS     = L_BUKRS
                           ADOAZON   = W_/ZAK/ANALITIKA-ADOAZON
                           SZAMLASZ  = W_/ZAK/ANALITIKA-SZAMLASZ
                           NYLAPAZON = W_/ZAK/ANALITIKA-NYLAPAZON(3)
                           BINARY SEARCH.
       IF SY-SUBRC NE 0.
         MESSAGE E305 WITH L_BUKRS W_/ZAK/ANALITIKA-ADOAZON
         W_/ZAK/ANALITIKA-SZAMLASZ.
*       Hiba a &/&/& számla adatainak meghatározásánál!
       ENDIF.
     ENDIF.
*    NONEED-et külön kell ellen#rizni! Lehet olyan eset, hogy
*    többször szerepel amib#l van olyan amiben a NONEED üres!
**   Ha nem releváns akkor nem dolgozzuk fel
     READ TABLE LI_AFA_SZLA TRANSPORTING NO FIELDS
          WITH KEY BUKRS     = L_BUKRS
                   ADOAZON   = W_/ZAK/ANALITIKA-ADOAZON
                   SZAMLASZ  = W_/ZAK/ANALITIKA-SZAMLASZ
                   NYLAPAZON = W_/ZAK/ANALITIKA-NYLAPAZON(3)
                   NONEED    = ''
                   BINARY SEARCH.
     IF SY-SUBRC NE 0.
       CONTINUE.
     ENDIF.
*    Ellen#rizzük, hogy feldolgoztuk e már a számlát
     READ TABLE LI_PROC_SZLA TRANSPORTING NO FIELDS
*++1465 #18.
*                WITH KEY BUKRS     = W_/ZAK/ANALITIKA-BUKRS
                WITH KEY BUKRS     = L_BUKRS
*--1465 #18.
                         ADOAZON   = W_/ZAK/ANALITIKA-ADOAZON
                         SZAMLASZA = W_/ZAK/ANALITIKA-SZAMLASZA
                         NYLAPAZON = W_/ZAK/ANALITIKA-NYLAPAZON(3).
*++1365 #21.
*                         BINARY SEARCH.
*--1365 #21.
     CHECK SY-SUBRC NE 0.
     DELETE LI_AFA_SZLA WHERE NONEED = 'X' OR
                              ( ( GJAHR > S_GJAHR-LOW ) OR
                              (   GJAHR = S_GJAHR-LOW AND
                                  MONAT > R_MONAT-HIGH ) ).
     SORT LI_AFA_SZLA BY BUKRS ADOAZON SZAMLASZA SZLATIP.
*--1365 #21.
     LOOP AT LI_AFA_SZLA INTO LW_AFA_SZLA WHERE SZLATIP EQ C_SZLATIP_E.
       READ TABLE LI_AFA_SZLA TRANSPORTING NO FIELDS
                  WITH KEY BUKRS     = LW_AFA_SZLA-BUKRS
                           ADOAZON   = LW_AFA_SZLA-ADOAZON
                           SZAMLASZA = LW_AFA_SZLA-SZAMLASZA
                           SZLATIP   = C_SZLATIP_K
*++1365 #21.
                           BINARY SEARCH.
*--1365 #21.
*      Nincs K-s tétel
       IF SY-SUBRC NE 0.
         IF LW_AFA_SZLA-GJAHR NOT IN S_GJAHR OR
          ( LW_AFA_SZLA-GJAHR IN S_GJAHR AND LW_AFA_SZLA-MONAT NOT IN R_MONAT ).
           DELETE LI_AFA_SZLA.
         ENDIF.
       ENDIF.
     ENDLOOP.
*--1365 #18.
*    Adatok feldolgozása
     LOOP AT LI_AFA_SZLA INTO LW_AFA_SZLA.
       READ TABLE I_AFA_SZLA_SUM INTO W_AFA_SZLA_SUM
                  WITH KEY BUKRS     = LW_AFA_SZLA-BUKRS
                           ADOAZON   = LW_AFA_SZLA-ADOAZON
                           SZAMLASZA = LW_AFA_SZLA-SZAMLASZA
                           SZAMLASZ  = LW_AFA_SZLA-SZAMLASZ
                           SZAMLASZE = LW_AFA_SZLA-SZAMLASZE
                           NYLAPAZON = LW_AFA_SZLA-NYLAPAZON
*++2165 #03.
                           ELSTAD    = LW_AFA_SZLA-ELSTAD.
*--2165 #03

*++1365 #21.
*                           BINARY SEARCH.
*--1365 #21.
       IF SY-SUBRC EQ 0.
         L_TABIX = SY-TABIX.
         ADD LW_AFA_SZLA-LWBAS TO W_AFA_SZLA_SUM-LWBAS.
         ADD LW_AFA_SZLA-LWSTE TO W_AFA_SZLA_SUM-LWSTE.
         IF W_AFA_SZLA_SUM-LWSTE_MAX < W_AFA_SZLA_SUM-LWSTE.
           W_AFA_SZLA_SUM-LWSTE_MAX = W_AFA_SZLA_SUM-LWSTE.
         ENDIF.
         MODIFY I_AFA_SZLA_SUM FROM W_AFA_SZLA_SUM INDEX L_TABIX
                        TRANSPORTING LWBAS LWSTE LWSTE_MAX.
       ELSE.
         CLEAR W_AFA_SZLA_SUM.
         MOVE-CORRESPONDING LW_AFA_SZLA TO W_AFA_SZLA_SUM.
*         W_AFA_SZLA_SUM-SZAMLASZA = LW_AFA_SZLA-SZAMLASZA.
*         W_AFA_SZLA_SUM-NYLAPAZON = LW_AFA_SZLA-NYLAPAZON.
*         W_AFA_SZLA_SUM-SZLATIP   = LW_AFA_SZLA-SZLATIP.
         W_AFA_SZLA_SUM-LWSTE_MAX = W_AFA_SZLA_SUM-LWSTE.
*++1365 #21.
*         APPEND w_afa_szla_sum TO i_afa_szla_sum.
         INSERT W_AFA_SZLA_SUM INTO TABLE I_AFA_SZLA_SUM.
*         SORT i_afa_szla_sum BY bukrs adoazon szamlasza szamlasz szamlasze nylapazon.
*--1365 #21.
       ENDIF.
     ENDLOOP.
*++1365 #14.
     IF SY-SUBRC EQ 0.
*--1365 #14.
*    Bejegyzés a feldolgozásról
       CLEAR LW_PROC_SZLA.
       LW_PROC_SZLA-BUKRS     = LW_AFA_SZLA-BUKRS.
       LW_PROC_SZLA-ADOAZON   = LW_AFA_SZLA-ADOAZON.
       LW_PROC_SZLA-SZAMLASZA = LW_AFA_SZLA-SZAMLASZA.
       LW_PROC_SZLA-NYLAPAZON = LW_AFA_SZLA-NYLAPAZON.
*++1365 #21.
       INSERT LW_PROC_SZLA INTO TABLE LI_PROC_SZLA.
*       APPEND lw_proc_szla TO li_proc_szla.
*       SORT li_proc_szla.
*       SORT li_proc_szla BY bukrs adoazon szamlasza nylapazon.
*--1365 #21.
*++1365 #14.
     ENDIF.
*--1365 #14.
   ENDLOOP.
*++1365 #21.
*   REFRESH li_proc_szla.
   FREE LI_PROC_SZLA.
*--1365 #21.
*  Releváns számlák meghatározása
   LOOP AT I_AFA_SZLA_SUM INTO W_AFA_SZLA_SUM
*++1865 #13.
*                          WHERE LWSTE_MAX GE L_OLWSTE.
                          WHERE LWSTE_MAX GE L_OLWSTE_M01
                            AND NYLAPAZON(3) EQ C_NYLAPAZON_M01.
*--1865 #13.
*    Ellen#rizzük, hogy feldolgoztuk e már a számlát
     READ TABLE LI_PROC_SZLA TRANSPORTING NO FIELDS
                WITH KEY BUKRS     = W_AFA_SZLA_SUM-BUKRS
                         ADOAZON   = W_AFA_SZLA_SUM-ADOAZON
                         SZAMLASZA = W_AFA_SZLA_SUM-SZAMLASZA
                         NYLAPAZON = W_AFA_SZLA_SUM-NYLAPAZON.
*++1365 #21.
*                         BINARY SEARCH.
*--1365 #21.
     IF SY-SUBRC NE 0.
       CLEAR LW_PROC_SZLA.
       LW_PROC_SZLA-BUKRS     = W_AFA_SZLA_SUM-BUKRS.
       LW_PROC_SZLA-ADOAZON   = W_AFA_SZLA_SUM-ADOAZON.
       LW_PROC_SZLA-SZAMLASZA = W_AFA_SZLA_SUM-SZAMLASZA.
       LW_PROC_SZLA-NYLAPAZON = W_AFA_SZLA_SUM-NYLAPAZON.
*++1365 #21.
       INSERT LW_PROC_SZLA INTO TABLE LI_PROC_SZLA.
*       APPEND lw_proc_szla TO li_proc_szla.
*       SORT li_proc_szla BY bukrs adoazon szamlasza nylapazon.
*--1365 #21.
     ENDIF.
   ENDLOOP.
*++1365 #21.
*++1865 #13.
*  Releváns számlák meghatározása
   LOOP AT I_AFA_SZLA_SUM INTO W_AFA_SZLA_SUM
                          WHERE LWSTE_MAX GE L_OLWSTE
                            AND NYLAPAZON(3) EQ C_NYLAPAZON_M02.
*    Ellen#rizzük, hogy feldolgoztuk e már a számlát
     READ TABLE LI_PROC_SZLA TRANSPORTING NO FIELDS
                WITH KEY BUKRS     = W_AFA_SZLA_SUM-BUKRS
                         ADOAZON   = W_AFA_SZLA_SUM-ADOAZON
                         SZAMLASZA = W_AFA_SZLA_SUM-SZAMLASZA
                         NYLAPAZON = W_AFA_SZLA_SUM-NYLAPAZON.
     IF SY-SUBRC NE 0.
       CLEAR LW_PROC_SZLA.
       LW_PROC_SZLA-BUKRS     = W_AFA_SZLA_SUM-BUKRS.
       LW_PROC_SZLA-ADOAZON   = W_AFA_SZLA_SUM-ADOAZON.
       LW_PROC_SZLA-SZAMLASZA = W_AFA_SZLA_SUM-SZAMLASZA.
       LW_PROC_SZLA-NYLAPAZON = W_AFA_SZLA_SUM-NYLAPAZON.
       INSERT LW_PROC_SZLA INTO TABLE LI_PROC_SZLA.
     ENDIF.
   ENDLOOP.
*--1865 #13.
*   SORT li_proc_szla.
*--1365 #21.
*++1365 #9.
*  Kitöröljük azokat a sorokat, ahol a faktorral kerekített érték 0,
*  mert ezek a sorok üresen jelennek meg a bevallásban és az hibát
*  okoz!
   IF LS_BEVALLB-FIELDTYPE EQ 'N' AND   NOT LS_BEVALLB-ROUND IS INITIAL.
     LOOP AT I_AFA_SZLA_SUM INTO LW_AFA_SZLA_SUM.
       PERFORM CALC_FIELD_NRK
             USING LW_AFA_SZLA_SUM-LWSTE
                   LS_BEVALLB-ROUND
                   LW_AFA_SZLA_SUM-WAERS
          CHANGING L_FIELD_NR
                   L_FIELD_NRK.
*++1365 #19.
* Csak K-s tételéket töröljük, hogy E-s ne kerüljön ki a számított mezőből
*       IF L_FIELD_NR IS INITIAL.
*++2165 #13.
*       IF L_FIELD_NR IS INITIAL AND LW_AFA_SZLA_SUM-SZLATIP = C_SZLATIP_K.
       IF LW_AFA_SZLA_SUM-LWSTE IS INITIAL AND LW_AFA_SZLA_SUM-SZLATIP = C_SZLATIP_K.
*--2165 #13.
*++2065 #10.
         IF L_OLWSTE GE '10.00'. "Ha nagyobb mint 1 000 akkor tötöljük!
**--1365 #19.
           DELETE I_AFA_SZLA_SUM.
**++1365 #17.
         ENDIF.
*--2065 #10.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_OTP_02 SPOTS /ZAK/MAIN_ES .

* Ha törlünk rekordot, akkor ellen#rizni kell, hogy ez E-s rekord nem e
* maradt önmagában. Ha igen akkor azt is törölni kell mert egyébként
* rákerül a M01 vagy M02 lapra és ez nem megfelel#!
* Ha van még K-s rekord akkor nem kell az E-t törölni!
         READ TABLE I_AFA_SZLA_SUM TRANSPORTING NO FIELDS
              WITH KEY BUKRS     = LW_AFA_SZLA_SUM-BUKRS
                       ADOAZON   = LW_AFA_SZLA_SUM-ADOAZON
                       SZAMLASZA = LW_AFA_SZLA_SUM-SZAMLASZA
                       SZLATIP   = C_SZLATIP_K.
* Ha nincs már K-s rekord, akkor E-s törlése ha nem a feldolgozott
* id#s/zak/zakban van
         IF SY-SUBRC NE 0.
           DELETE I_AFA_SZLA_SUM
                     WHERE BUKRS     = LW_AFA_SZLA_SUM-BUKRS
                       AND ADOAZON   = LW_AFA_SZLA_SUM-ADOAZON
                       AND SZAMLASZA = LW_AFA_SZLA_SUM-SZAMLASZA
                       AND SZLATIP   = C_SZLATIP_E
                       AND ( ( GJAHR NOT IN S_GJAHR ) OR
*++1765 #09.
*                             ( GJAHR IN S_GJAHR AND MONAT NOT IN S_MONAT ) ).
                             ( GJAHR IN S_GJAHR AND MONAT NOT IN R_MONAT ) ).
*--1765 #09.
         ENDIF.
*--1365 #17.
       ENDIF.
     ENDLOOP.
*++1665 #12.
*    Elképzelhető, hogy marad az összesítésben még olyan rekord amit 901
*    betöltéssel 0-áztak ki és E típusú, ezeket is törölni kell, hogy ne
*    jelenjen meg az ALV-n sem
*++2065 #10.
     IF L_OLWSTE GE '10.00'. "Ha nagyobb mint 1 000 akkor tötöljük!
       DELETE I_AFA_SZLA_SUM  WHERE LWBAS IS INITIAL AND LWSTE IS INITIAL.
     ENDIF.
*--2065 #10.
*--1665 #12.
   ENDIF.
*--1365 #9.
*++1365 #21.
*   SORT i_afa_szla_sum BY bukrs adoazon szamlasza nylapazon szlatip.
*--1365 #21.
   LOOP AT LI_PROC_SZLA INTO LW_PROC_SZLA.
*    Eredeti számla sor beolvasása
     READ TABLE I_AFA_SZLA_SUM INTO LW_AFA_SZLA_SUM
                WITH KEY BUKRS     = LW_PROC_SZLA-BUKRS
                         ADOAZON   = LW_PROC_SZLA-ADOAZON
                         SZAMLASZA = LW_PROC_SZLA-SZAMLASZA
                         NYLAPAZON = LW_PROC_SZLA-NYLAPAZON
                         SZLATIP   = C_SZLATIP_E.
*++1365 #21.
*                         BINARY SEARCH.
*--1365 #21.
*    Meghatározzuk van e olyan sor ami nem E ha igen, akkor
*    minden érték -K lapra kerül, egyébként a M01 vagy M02-re
     LOOP AT I_AFA_SZLA_SUM TRANSPORTING NO FIELDS
                WHERE    BUKRS     = LW_PROC_SZLA-BUKRS
                  AND    ADOAZON   = LW_PROC_SZLA-ADOAZON
                  AND    SZAMLASZA = LW_PROC_SZLA-SZAMLASZA
                  AND    NYLAPAZON = LW_PROC_SZLA-NYLAPAZON
                  AND    SZLATIP   NE C_SZLATIP_E.
       EXIT.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       L_NYLAPAZON_FLAG = '-K'.
     ELSE.
       CLEAR L_NYLAPAZON_FLAG.
     ENDIF.
*++1365 #3.
     CLEAR: L_E_GEN, LW_ANALITIKA_E_SAVE.
*--1365 #3.
     LOOP AT I_AFA_SZLA_SUM INTO W_AFA_SZLA_SUM
                           WHERE  BUKRS     = LW_PROC_SZLA-BUKRS
                             AND  ADOAZON   = LW_PROC_SZLA-ADOAZON
                             AND  SZAMLASZA = LW_PROC_SZLA-SZAMLASZA
                             AND  NYLAPAZON = LW_PROC_SZLA-NYLAPAZON.
       IF NOT W_AFA_SZLA_SUM-SZAMLASZE IS INITIAL.
*        Azonos hónap az eredeti számlával
*++1365 #8.
*        IF W_AFA_SZLA_SUM-SZAMLAKELT(6) EQ
*           LW_AFA_SZLA_SUM-SZAMLAKELT(6).
*++1365 #13.
*         IF W_AFA_SZLA_SUM-GJAHR  EQ LW_AFA_SZLA_SUM-GJAHR AND
*            W_AFA_SZLA_SUM-MONAT  EQ LW_AFA_SZLA_SUM-MONAT AND
*            W_AFA_SZLA_SUM-ZINDEX EQ LW_AFA_SZLA_SUM-ZINDEX.
         IF W_AFA_SZLA_SUM-GJAHR IN S_GJAHR AND
            W_AFA_SZLA_SUM-MONAT IN R_MONAT.
*--1365 #13.
*--1365 #8.
           W_AFA_SZLA_SUM-SZLATIP = C_SZLATIP_KT.
*++1365 #14.
* Csak akkor kell generálni, ha az eredeti számla is a
* feldolgozott id#s/zak/zakban van!
           IF LW_AFA_SZLA_SUM-GJAHR IN S_GJAHR AND
              LW_AFA_SZLA_SUM-MONAT IN R_MONAT.
*--1365 #14.
*++1365 #3.
             MOVE 'X' TO L_E_GEN.
*--1365 #3.
*++1365 #14.
           ENDIF.
*--1365 #14.
*        Eltér# hónap
         ELSE.
           W_AFA_SZLA_SUM-SZLATIP = C_SZLATIP_K.
*++1365 #3.
           CLEAR L_E_GEN.
*--1365 #3.
         ENDIF.
       ENDIF.
       CLEAR W_/ZAK/ANALITIKA.
*++1465 #12.
*       MOVE-CORRESPONDING LW_/ZAK/ANALITIKA_SAVE TO  W_/ZAK/ANALITIKA.
*      Meghatározzuk a DUMMY_R-es rekordot az eredeti adatok miatt
       READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
                                  WITH KEY  BUKRS     = W_AFA_SZLA_SUM-BUKRS
                                            ADOAZON   = W_AFA_SZLA_SUM-ADOAZON
                                            SZAMLASZ  = W_AFA_SZLA_SUM-SZAMLASZ
                                            ABEVAZ    = $ABEVAZ_DUMMY_R.
       IF SY-SUBRC NE 0.
*++2465 #02.
         SELECT SINGLE * INTO LW_/ZAK/ANALITIKA
                         FROM /ZAK/ANALITIKA
                        WHERE BUKRS    EQ W_AFA_SZLA_SUM-BUKRS
                          AND ABEVAZ   EQ $ABEVAZ_DUMMY_R
                          AND ADOAZON  EQ W_AFA_SZLA_SUM-ADOAZON
                          AND SZAMLASZ EQ W_AFA_SZLA_SUM-SZAMLASZ.
         IF SY-SUBRC EQ 0.
           MOVE-CORRESPONDING LW_/ZAK/ANALITIKA TO  W_/ZAK/ANALITIKA.
         ELSE.
*--2465 #02.
           MOVE-CORRESPONDING LW_/ZAK/ANALITIKA_SAVE TO  W_/ZAK/ANALITIKA.
*++2465 #02.
         ENDIF.
*--2465 #02.
       ENDIF.
*--1465 #12.
       MOVE-CORRESPONDING W_AFA_SZLA_SUM TO W_/ZAK/ANALITIKA.
*++1365 #16.
*      Csoport vállalatnál vállalat kód csere
       IF NOT V_BUKCS IS INITIAL.
         W_/ZAK/ANALITIKA-BUKRS = LW_/ZAK/ANALITIKA_SAVE-BUKRS.
       ENDIF.
*--1365 #16.
       W_/ZAK/ANALITIKA-ABEVAZ = $ABEVAZ_DUMMY_M.
       CLEAR: W_/ZAK/ANALITIKA-BSZNUM,
              W_/ZAK/ANALITIKA-PACK,
              W_/ZAK/ANALITIKA-FIELD_C,
              W_/ZAK/ANALITIKA-FIELD_N.
       MOVE SY-TABIX TO W_/ZAK/ANALITIKA-ITEM.
       IF NOT L_NYLAPAZON_FLAG IS INITIAL.
         CONCATENATE W_/ZAK/ANALITIKA-NYLAPAZON
                     '-K' INTO W_/ZAK/ANALITIKA-NYLAPAZON.
       ENDIF.
*      Ha a DUMMY_M N-r van állítva, akkor ellen#rizzük hogy
*      a struktúrában szerepl# LWSTE a beállított kerekítési
*      faktorral nagyobb e mint 0, ha nem akkor nem kell feldogozni!
       IF LS_BEVALLB-FIELDTYPE EQ 'N' AND
          NOT LS_BEVALLB-ROUND IS INITIAL.
         PERFORM CALC_FIELD_NRK
               USING W_/ZAK/ANALITIKA-LWSTE
                     LS_BEVALLB-ROUND
                     W_/ZAK/ANALITIKA-WAERS
            CHANGING L_FIELD_NR
                     L_FIELD_NRK.
       ELSE.
         L_FIELD_NR = W_/ZAK/ANALITIKA-LWSTE.
       ENDIF.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_OTP_03 SPOTS /ZAK/MAIN_ES .

*++2065 #10.
*       IF NOT L_FIELD_NR IS INITIAL.
       IF NOT L_FIELD_NR IS INITIAL OR L_OLWSTE LT '10.00'. "Ha kisebb mint 1 000 akkor kell!
*--2065 #10.
         APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
*++1365 #3.
         IF W_/ZAK/ANALITIKA-SZLATIP EQ C_SZLATIP_E.
           LW_ANALITIKA_E_SAVE = W_/ZAK/ANALITIKA.
         ENDIF.
*--1365 #3.
       ENDIF.
       MOVE 'X' TO W_AFA_SZLA_SUM-MLAP.
       MODIFY I_AFA_SZLA_SUM FROM W_AFA_SZLA_SUM
                     TRANSPORTING SZLATIP MLAP.
     ENDLOOP.
*++1365 #3.
     IF NOT L_E_GEN IS INITIAL.
       IF LW_ANALITIKA_E_SAVE-NYLAPAZON+3(2) = '-K'.
         LW_ANALITIKA_E_SAVE-NYLAPAZON =
                   LW_ANALITIKA_E_SAVE-NYLAPAZON(3).
         APPEND LW_ANALITIKA_E_SAVE TO I_/ZAK/ANALITIKA.
       ENDIF.
     ENDIF.
*--1365 #3.
   ENDLOOP.
*++1965 #04.
*++2165 #02.
*  Előleg stádium korrigálása
   LOOP AT I_/ZAK/ANALITIKA ASSIGNING <LFS1> WHERE ABEVAZ EQ $ABEVAZ_DUMMY_M
                                              AND NOT ELSTAD IS INITIAL.
*++2265 #06.
*     READ TABLE I_/ZAK/ANALITIKA  INTO W_/ZAK/ANALITIKA
*                                 WITH KEY  BUKRS     = <LFS1>-BUKRS
*                                           ABEVAZ    = $ABEVAZ_DUMMY_R
*                                           ADOAZON   = <LFS1>-ADOAZON
*                                           SZAMLASZ  = <LFS1>-SZAMLASZ
*                                           SZAMLASZA = <LFS1>-SZAMLASZA
*                                           LWBAS     = <LFS1>-LWBAS
*                                           LWSTE     = <LFS1>-LWSTE.
     LOOP AT  I_/ZAK/ANALITIKA  INTO W_/ZAK/ANALITIKA
                                 WHERE     BUKRS     = <LFS1>-BUKRS
                                   AND     ABEVAZ    = $ABEVAZ_DUMMY_R
                                   AND     ADOAZON   = <LFS1>-ADOAZON
                                   AND     SZAMLASZ  = <LFS1>-SZAMLASZ
                                   AND     SZAMLASZA = <LFS1>-SZAMLASZA
                                   AND     LWBAS     = <LFS1>-LWBAS
                                   AND     LWSTE     = <LFS1>-LWSTE
                                   AND NOT ELSTAD IS INITIAL.
       EXIT.
     ENDLOOP.
*--2265 #06.
     IF SY-SUBRC EQ 0 AND <LFS1>-ELSTAD NE W_/ZAK/ANALITIKA-ELSTAD.
       <LFS1>-ELSTAD = W_/ZAK/ANALITIKA-ELSTAD.
     ENDIF.
   ENDLOOP.
*--2165 #02.
* Partner csoport adószám kezelés
*    Meg kell keresni az érvényesség végén érvényes kulcsot
   SELECT SINGLE PADOSZ INTO L_PADOSZ
                        FROM /ZAK/BEVALL
                       WHERE BUKRS EQ P_BUKRS
                         AND DATBI GE V_LAST_DATE
                         AND DATAB LE V_LAST_DATE
                         AND BTYPART EQ C_BTYPART_AFA.
*  Saját beállító tábla (/ZAK/PADONSZA) szerinti kezelés
   IF SY-SUBRC EQ 0 AND L_PADOSZ EQ C_PADOSZ_C.
     LI_AFA_SZLA_SUM[] = I_AFA_SZLA_SUM[].
     FREE I_AFA_SZLA_SUM[].
*    Lecseréljük az összes adószámot a csoport adószámra (ANALITIKA, AFA_SZLA)
     LOOP AT I_ADOAZON INTO LW_ADOAZON.
       CLEAR L_STCD3.
       SELECT SINGLE STCD3 INTO L_STCD3
                           FROM /ZAK/PADONSZA
                          WHERE ADOAZON EQ LW_ADOAZON-ADOAZON
                            AND DATAB   LE V_LAST_DATE
                            AND DATBI   GE V_LAST_DATE.
       IF SY-SUBRC EQ 0 AND L_STCD3 NE LW_ADOAZON-ADOAZON.
         LOOP AT I_/ZAK/ANALITIKA ASSIGNING <LFS1> WHERE ABEVAZ  = $ABEVAZ_DUMMY_M
                                               AND ADOAZON = LW_ADOAZON-ADOAZON.
           <LFS1>-ADOAZON = L_STCD3(8).
         ENDLOOP.
         LOOP AT LI_AFA_SZLA_SUM ASSIGNING <LFS2> WHERE ADOAZON = LW_ADOAZON-ADOAZON.
           <LFS2>-ADOAZON = L_STCD3(8).
         ENDLOOP.
       ENDIF.
     ENDLOOP.
*++2365 #05.
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_OTP_04 SPOTS /ZAK/MAIN_ES .
*--2365 #05.
     I_AFA_SZLA_SUM[] = LI_AFA_SZLA_SUM[].
     FREE LI_AFA_SZLA_SUM.
*  SAP törzsadat szerinti kezelés
   ELSEIF SY-SUBRC EQ 0 AND L_PADOSZ EQ C_PADOSZ_S.
     LI_AFA_SZLA_SUM[] = I_AFA_SZLA_SUM[].
     FREE I_AFA_SZLA_SUM[].
*    Lecseréljük az összes adószámot a csoport adószámra (ANALITIKA, AFA_SZLA)
     LOOP AT I_/ZAK/ANALITIKA ASSIGNING <LFS1> WHERE ABEVAZ  = $ABEVAZ_DUMMY_M.
       L_ADOAZON_SAVE = <LFS1>-ADOAZON.
       IF NOT <LFS1>-STCD3 IS INITIAL.
         <LFS1>-ADOAZON = <LFS1>-STCD3(8).
       ELSE.
         SELECT SINGLE STCD3 INTO L_STCD3
                  FROM /ZAK/ANALITIKA
                 WHERE BUKRS   EQ <LFS1>-BUKRS
                   AND BTYPE   EQ <LFS1>-BTYPE
                   AND GJAHR   EQ <LFS1>-GJAHR
                   AND MONAT   IN R_MONAT
                   AND ZINDEX  LE <LFS1>-ZINDEX
*++1965 #07.
                   AND ABEVAZ  EQ C_ABEVAZ_DUMMY_R
*                  AND ADOAZON EQ <LFS1>-STCD1(8)
                   AND ADOAZON EQ <LFS1>-ADOAZON
*--1965 #07.
                   AND STCD3   NE ''.
         IF SY-SUBRC EQ 0 AND  <LFS1>-ADOAZON NE L_STCD3.
           <LFS1>-ADOAZON = L_STCD3(8).
         ENDIF.
       ENDIF.
       IF  L_ADOAZON_SAVE NE <LFS1>-ADOAZON.
         LOOP AT LI_AFA_SZLA_SUM ASSIGNING <LFS2> WHERE ADOAZON = L_ADOAZON_SAVE.
           <LFS2>-ADOAZON = <LFS1>-ADOAZON.
         ENDLOOP.
       ENDIF.
     ENDLOOP.
     I_AFA_SZLA_SUM[] = LI_AFA_SZLA_SUM[].
     FREE LI_AFA_SZLA_SUM.
   ENDIF.
*--1965 #04.

 ENDFORM.                    " SUM_GEN_OMREL
*++1365 #21.
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
*--1365 #21.
*&---------------------------------------------------------------------*
*&      Form  GET_ADDR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_ANALITIKA_PTG_LIFKUN  text
*      -->P_LW_ADDR1_VAL  text
*----------------------------------------------------------------------*
*++PTGSZLAA #02. 2014.03.05
* FORM GET_ADDR_DATA  USING    $LIFKUN
 FORM GET_ADDR_DATA  USING    $XBLNR
                              $LIFKUN
*--PTGSZLAA #02. 2014.03.05
                              $ADDR1_VAL STRUCTURE ADDR1_VAL
                              $SUBRC.
   DATA L_ADRNR TYPE ADRNR.
   DATA LI_ADDR1_SEL TYPE TABLE OF ADDR1_SEL WITH HEADER LINE.
   DATA LI_ADDR1_VAL TYPE TABLE OF ADDR1_VAL WITH HEADER LINE.
   DATA L_ITAB TYPE TABLE OF STRING WITH HEADER LINE.
   DATA L_TABIX LIKE SY-TABIX.
*++PTGSZLAH #02. 2015.01.30
   CHECK V_FORM_INACT IS INITIAL.
*--PTGSZLAH #02. 2015.01.30
   CLEAR: $ADDR1_VAL, $SUBRC.
   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
     EXPORTING
*++PTGSZLAA #02. 2014.03.05
*      INPUT  = $LIFKUN
       INPUT  = $XBLNR
*--PTGSZLAA #02. 2014.03.05
     IMPORTING
       OUTPUT = $LIFKUN.
*  Vevő meghatározása
   SELECT SINGLE ADRNR INTO L_ADRNR
                       FROM KNA1
                      WHERE KUNNR EQ $LIFKUN.
   IF SY-SUBRC NE 0.
*++PTGSZLAA #02. 2014.03.04
*     MOVE SY-SUBRC TO L_SUBRC.
     MOVE SY-SUBRC TO $SUBRC.
*--PTGSZLAA #02. 2014.03.04
     EXIT.
   ELSE.
     REFRESH: LI_ADDR1_SEL, LI_ADDR1_VAL.
     LI_ADDR1_SEL-ADDRNUMBER = L_ADRNR.
     APPEND LI_ADDR1_SEL.
     CALL FUNCTION 'ADDR_GET'
       EXPORTING
         ADDRESS_SELECTION = LI_ADDR1_SEL
*        ADDRESS_GROUP     =
*        READ_SADR_ONLY    = ' '
*        READ_TEXTS        = ' '
*        IV_CURRENT_COMM_DATA          = ' '
       IMPORTING
         ADDRESS_VALUE     = $ADDR1_VAL
*        ADDRESS_ADDITIONAL_INFO       =
*        RETURNCODE        =
*        ADDRESS_TEXT      =
*        SADR              =
*       TABLES
*        ADDRESS_GROUPS    =
*        ERROR_TABLE       =
*        VERSIONS          =
*       EXCEPTIONS
*        PARAMETER_ERROR   = 1
*        ADDRESS_NOT_EXIST = 2
*        VERSION_NOT_EXIST = 3
*        INTERNAL_ERROR    = 4
*        OTHERS            = 5
       .
     IF SY-SUBRC <> 0.
       MOVE SY-SUBRC TO L_SUBRC.
       EXIT.
     ENDIF.
*  Közterület szétbontása, neve, jellege:
     REFRESH L_ITAB.
     SPLIT $ADDR1_VAL-STREET AT SPACE INTO TABLE L_ITAB.
     DESCRIBE TABLE L_ITAB LINES L_TABIX.
     IF L_TABIX GE 2.
       CLEAR $ADDR1_VAL-STREET.
       SUBTRACT 1 FROM L_TABIX.
       LOOP AT L_ITAB FROM 1 TO L_TABIX.
         IF NOT $ADDR1_VAL-STREET IS INITIAL.
           CONCATENATE  $ADDR1_VAL-STREET L_ITAB INTO $ADDR1_VAL-STREET
                        SEPARATED BY SPACE.
         ELSE.
           $ADDR1_VAL-STREET = L_ITAB.
         ENDIF.
       ENDLOOP.
       ADD 1 TO L_TABIX.
       READ TABLE L_ITAB INDEX L_TABIX.
       $ADDR1_VAL-HOUSE_NUM2 = L_ITAB.
     ENDIF.
   ENDIF.
 ENDFORM.                    " GET_ADDR_DATA
ENHANCEMENT-POINT /ZAK/ZAK_MAIN_TELEKOM_03 SPOTS /ZAK/MAIN_ES STATIC .
*++2365 #03.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9901  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9901 OUTPUT.
   SET PF-STATUS '9901'.
   SET TITLEBAR  '9901'.
 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9901  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9901 INPUT.

   DATA L_SAVE_OK_CODE    LIKE SY-UCOMM.

   L_SAVE_OK_CODE = V_OK_9901.
   CLEAR V_OK_9901.

   CASE L_SAVE_OK_CODE.
     WHEN 'ENTER'.
       LEAVE TO SCREEN 0.
   ENDCASE.

 ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FILL_9901  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE FILL_9901 OUTPUT.

   M_DEF S_SPECM 'I' 'BT' W_/ZAK/BEVALL-DATAB+4(2) W_/ZAK/BEVALL-DATBI+4(2).

 ENDMODULE.
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
*   A megadott időszakra jelenleg NAV ellenőrzés van folyamatban!
   ENDIF.

 ENDFORM.
*--2508 #10.
