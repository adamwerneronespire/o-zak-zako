*&---------------------------------------------------------------------*
*& Program: Determining SAP data for personal income tax returns
*&---------------------------------------------------------------------*
 REPORT /ZAK/ZAK_/ZAK/SZJA_SAP_SEL MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Based on the conditions specified on the selection,
*& the program filters the data from the SAP documents and stores it in
*& /ZAK/ANALITIKA.
*&---------------------------------------------------------------------*
*& Author : Balázs Gábor - FMC
*& Creation date      : 2006.01.18
*& Functional spec    : ________
*& SAP module         : ADO
*& Program type       : Report
*& SAP version        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (The OSS note number must be written at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION       TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2006/05/27   Cserhegyi T.  Replacing CL_GUI_FRONTEND_SERVICES
*&                                   with the traditional solution
*&        2007/01/03 Balázs G. revert replacement
*& 0002 2006/10/26 Balázs G. Handling multiple return types
*& 0003 2007/01/05 Balázs G. Fixing ratio handling for month 12
*& 0004 2007/03/06 Revolving I. Accounting "sign correctly"
*& 0005 2007/05/08 Balázs G. Introducing correction document type
*& 0006 2007/10/08 Balázs G. Company rotation
*& 0007 2008/01/21 Balázs G. Transforming company rotation
*& 0008 2008/02/07 Balázs G. Reworking SOR_SZETRAK because
*&                                   it does not work correctly at year change
*& 0009 2008/07/03 Balázs G. Filtering SZJA_CUST reading based on
*&                                   the general ledger accounts provided
*&                                   in the selection
*& 0010 2008/09/12 Balázs G. Restoring validation for data service ID
*& 0011 2008/10/17 Balázs G. Business gift project 2008
*&                                   - monthly handling
*&                                   - accounting file segmentation
*&                                   - cost center rotation
*&                                   - progress indicator
*& 0012 2008/12/16 Balázs G. Removing business gift and hospitality,
*&                                   entire program copied as
*&                                   /ZAK/SZJA_SAP_SEL_OLD
*& 0013 2009/04/08 Balázs G. Setting initial values
*& 0014 2009/04/20 Balázs G. VAT code for WL accounting based on
*&                                   /ZAK/SZJA_CUST table
*& 0015 2009/05/22 Balázs G. Handling excluded documents
*& 0016 2009/08/25 Balázs G. Taking over PST element into analytics
*& 0017 2009/10/29 Balázs G. Reworking XREF1 search
*& 0018 2010/04/20 Balázs G. Excluding SC document type
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE /ZAK/SAP_SEL_F01.


*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
 TABLES : BSEG,              "Document segment: accounting
          BKPF,              "Document header for accounting
          BSIS, "Accounting: secondary index for general ledger accounts
          /ZAK/SZJA_CUST,     "SZJA deduction, accounting posting setup
          /ZAK/SZJA_ABEV.     "SZJA deduction, based on ABEV-defined field name


*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
*++BG 2007.04.18
 CONSTANTS C_REPI_MONAT TYPE MONAT VALUE '05'.
*--BG 2007.04.18

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

*     METHODS:
*      HANDLE_DATA_CHANGED
*         FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*             IMPORTING ER_DATA_CHANGED.

     CLASS-METHODS:



       HANDLE_HOTSPOT_CLICK
                     FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW_ID
                     E_COLUMN_ID
                     ES_ROW_NO.



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
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_HOTSPOT_CLICK.

     IF SY-DYNNR = '9000'.


       PERFORM D900_EVENT_HOTSPOT_CLICK USING E_ROW_ID
                                               E_COLUMN_ID.

     ENDIF.
   ENDMETHOD.                    "hotspot_click
 ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES *
*      Internal table - (I_xxx...) *
*      FORM parameter - ($xxxx...) *
*      Constant           -   (C_xxx...)                              *
*      Parameter variable - (P_xxx...) *
*      Selection option - (S_xxx...) *
*      Ranges (Range) - (R_xxx...) *
*      Global variables - (V_xxx...) *
*      Local variables - (L_xxx...) *
*      Work area - (W_xxx...) *
*      Type - (T_xxx...) *
*      Macros - (M_xxx...) *
*      Field symbol       -   (FS_xxx...)                             *
*      Method             -   (METH_xxx...)                           *
*      Object             -   (O_xxx...)                              *
*      Class - (CL_xxx...) *
*      Event - (E_xxx...) *
*&---------------------------------------------------------------------*
 DATA V_SUBRC LIKE SY-SUBRC.
 DATA V_REPID LIKE SY-REPID.
 DATA : V_A_ARANY TYPE P DECIMALS 4,
        V_R_ARANY TYPE P DECIMALS 4.
*Setting data
 DATA W_/ZAK/SZJA_CUST TYPE  /ZAK/SZJA_CUST.
 DATA I_/ZAK/SZJA_CUST TYPE STANDARD TABLE OF /ZAK/SZJA_CUST
                                                        INITIAL SIZE 0.
*Definition of ABEV
 DATA W_/ZAK/SZJA_ABEV TYPE  /ZAK/SZJA_ABEV.
 DATA I_/ZAK/SZJA_ABEV TYPE STANDARD TABLE OF /ZAK/SZJA_ABEV
                                                        INITIAL SIZE 0.
*Contains records generated by the function element
 DATA IO_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                        INITIAL SIZE 0.
* Rows to be loaded into Excedl
*++FI 20070213
* DATA W_/ZAK/SZJA_EXCEL TYPE  /ZAK/SZJA_EXCEL.
* DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJA_EXCEL
*                                                        INITIAL SIZE 0.
 DATA W_/ZAK/SZJA_EXCEL1 TYPE  /ZAK/SZJAEXCELV2. " Line 1 of accounting
 DATA W_/ZAK/SZJA_EXCEL2 TYPE  /ZAK/SZJAEXCELV2. " Line 2 of accounting
 DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJAEXCELV2
                                                        INITIAL SIZE 0.

*--FI 20070213
*BSEG
 DATA W_BSEG TYPE  BSEG.
 DATA I_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
*BKPF
 DATA W_BKPF TYPE  BKPF.
 DATA I_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.

* ALV treatment variables
 DATA: V_OK_CODE           LIKE SY-UCOMM,
       V_SAVE_OK           LIKE SY-UCOMM,
       V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
       V_CONTAINER1        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',

       V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       V_CUSTOM_CONTAINER1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       I_FIELDCAT          TYPE LVC_T_FCAT,
       V_LAYOUT            TYPE LVC_S_LAYO,
       V_VARIANT           TYPE DISVARIANT,
       V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER.
 DATA: BEGIN OF I_OUTTAB2 OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
 DATA: CELLTAB TYPE LVC_T_STYL.
 DATA: END OF I_OUTTAB2.
*++0002 BG 2006/10/26
 RANGES R_BTYPE FOR /ZAK/BEVALL-BTYPE.

*Ratio numbers must be reported by type
 DATA: BEGIN OF I_BTYPE_ARANY OCCURS 0,
         BTYPE   TYPE /ZAK/BTYPE,
         A_ARANY LIKE V_A_ARANY,
         R_ARANY LIKE V_R_ARANY,
       END OF I_BTYPE_ARANY.
*--0002 BG 2006/10/26

*++0005 BG 2007.05.08
*MACRO definition for range upload
 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   APPEND &1.
 END-OF-DEFINITION.
*--0005 BG 2007.05.08

*++0006 2007.10.08  BG (FMC)
 DATA V_SEL_BUKRS TYPE BUKRS.
*--0006 2007.10.08  BG (FMC)

*++0017 BG 2009.10.29
 TYPES: BEGIN OF T_AD_BUKRS,
          AD_BUKRS TYPE /ZAK/AD_BUKRS,
        END OF T_AD_BUKRS.

 DATA I_AD_BUKRS TYPE T_AD_BUKRS OCCURS 0 WITH HEADER LINE.
*--0017 BG 2009.10.29

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
 SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

* Company.
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-101.
 PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS
*                          /ZAK/BEVALLSZ-BUKRS
                           VALUE CHECK
                           OBLIGATORY MEMORY ID BUK.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

 SELECTION-SCREEN END OF LINE.
* ++BG
* Declaration type.
* SELECTION-SCREEN BEGIN OF LINE.
* SELECTION-SCREEN COMMENT 01(31) TEXT-102.
*++0002 BG 2006/10/26
* PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE
**                          /ZAK/BEVALLSZ-BTYPE
**                          OBLIGATORY
*                           NO-DISPLAY.
*--0002 BG 2006/10/26
* SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT
*                          MODIF ID DIS
                           NO-DISPLAY.
* SELECTION-SCREEN END OF LINE.
* Definition of declaration type
 PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                           DEFAULT C_BTYPART_SZJA
                           OBLIGATORY.
* --BG

* Year
 PARAMETERS: P_GJAHR LIKE BKPF-GJAHR DEFAULT SY-DATUM(4)
                                     OBLIGATORY.
* Month
 PARAMETERS: P_MONAT LIKE BKPF-MONAT DEFAULT SY-DATUM+4(2)
                                     OBLIGATORY.
* Data service identifier
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-103.
 PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                           MATCHCODE OBJECT /ZAK/BEVD
                                                    OBLIGATORY.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BSZTXT  LIKE /ZAK/BEVALLDT-SZTEXT MODIF ID DIS.
 SELECTION-SCREEN END OF LINE.
* Kind of proof
 SELECT-OPTIONS: S_BLART FOR BKPF-BLART NO INTERVALS.
*                         DEFAULT 'SE' OPTION EQ SIGN E.

*++0005 BG 2007.05.08
 SELECT-OPTIONS: S_KBLART FOR BKPF-BLART NO INTERVALS.
*--0005 BG 2007.05.08
*++0015 2009.05.22 BG
* Excluded receipts
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 1(31) TEXT-104.
 PARAMETERS P_KBELNR AS CHECKBOX MODIF ID DIS.
 SELECTION-SCREEN PUSHBUTTON 52(4) KBL USER-COMMAND KBL.
 SELECTION-SCREEN END OF LINE.
*--0015 2009.05.22 BG


* Test run
 PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X' .

 SELECTION-SCREEN: END OF BLOCK BL01.

*++0009 BG 2008.07.03
 SELECTION-SCREEN BEGIN OF BLOCK B105 WITH FRAME TITLE TEXT-T05.
 SELECT-OPTIONS S_SAKNR FOR /ZAK/SZJA_CUST-SAKNR.
 SELECTION-SCREEN: END OF BLOCK B105.
*--0009 BG 2008.07.03


*Select upload method
 SELECTION-SCREEN BEGIN OF BLOCK B102 WITH FRAME TITLE TEXT-T02.
 PARAMETERS: P_NORM  RADIOBUTTON GROUP R01 USER-COMMAND NORM
                                                   DEFAULT 'X',
             P_ISMET RADIOBUTTON GROUP R01,
             P_PACK  LIKE /ZAK/BEVALLP-PACK
                       MATCHCODE OBJECT /ZAK/PACK.

 SELECTION-SCREEN END OF BLOCK B102.

*++0012 2008.12.16 BG
**Enter tax-free portion
* SELECTION-SCREEN BEGIN OF BLOCK B103 WITH FRAME TITLE TEXT-T03.
**Business gift tax-free section
* PARAMETERS: P_UZAJ LIKE BSEG-DMBTR.
**Representation is a tax-free part
* PARAMETERS: P_REPR LIKE BSEG-DMBTR.
* SELECTION-SCREEN END OF BLOCK B103.
*--0012 2008.12.16 BG

*Accounting excel file
 SELECTION-SCREEN BEGIN OF BLOCK B104 WITH FRAME TITLE TEXT-T04.
 PARAMETERS: P_OUTF LIKE FC03TAB-PL00_FILE."  OBLIGATORY.
*++0011 2008.10.17 BG
 PARAMETERS: P_SPLIT TYPE I NO-DISPLAY.
*--0011 2008.10.17 BG

 SELECTION-SCREEN END OF BLOCK B104.


****************************************************************
* LOCAL CLASSES: Definition
****************************************************************



*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.
   GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Definition of designations
   PERFORM READ_ADDITIONALS.

   PERFORM S_BLART_INIT.

*++00013 2009.04.08
**++0005 BG 2007.05.08
*   PERFORM S_KBLART_INIT.
**--0005 BG 2007.05.08
*--00013 2009.04.08

*++0015 2009.05.22 BG
   WRITE ICON_DISPLAY_MORE TO KBL AS ICON.
*--0015 2009.05.22 BG


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN OUTPUT.

*++0015 2009.05.22 BG
* We define this excluded document number
   PERFORM GET_KBELNR TABLES I_KBELNR
                      USING  P_BUKRS
                             P_KBELNR.
*--0015 2009.05.22 BG

*  Set screen attributes
   PERFORM SET_SCREEN_ATTRIBUTES.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*
*++0002 BG 2006/10/26
*AT SELECTION-SCREEN ON P_BTYPE.
 AT SELECTION-SCREEN ON P_BTYPAR.
*--0002 BG 2006/10/26
*  Checking the SZJA return type
   PERFORM VER_BTYPEART USING P_BUKRS
*++0002 BG 2006/10/26
*                             P_BTYPE
                              P_BTYPAR
*--0002 BG 2006/10/26
                              C_BTYPART_SZJA
                     CHANGING V_SUBRC.

   IF NOT V_SUBRC IS INITIAL.
     MESSAGE E019.
*   Please enter the SZJA declaration ID!
*  We define the declaration type
   ELSE.
*++0002 BG 2006/10/26
*     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
*          EXPORTING
*               I_BUKRS     = P_BUKRS
*               I_BTYPART   = P_BTYPAR
*               I_GJAHR     = P_GJAHR
*               I_MONAT     = P_MONAT
*          IMPORTING
*               E_BTYPE     = P_BTYPE
*          EXCEPTIONS
*               ERROR_MONAT = 1
*               ERROR_BTYPE = 2
*               OTHERS      = 3.
*     IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     ENDIF.
     CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
       EXPORTING
         I_BUKRS      = P_BUKRS
         I_BTYPART    = P_BTYPAR
       TABLES
         T_BTYPE      = R_BTYPE
         T_/ZAK/BEVALL = I_/ZAK/BEVALL
       EXCEPTIONS
         ERROR_BTYPE  = 1
         OTHERS       = 2.
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ENDIF.
*--0002 BG 2006/10/26

 AT SELECTION-SCREEN ON P_BSZNUM.
   MOVE SY-REPID TO V_REPID.
*  Service ID verification
*++0010 BG 2008/09/12
   PERFORM VER_BSZNUM   USING P_BUKRS
                              P_BTYPAR
                              P_BSZNUM
                              V_REPID
                     CHANGING V_SUBRC.
*--0010 BG 2008/09/12
*   IF NOT V_SUBRC IS INITIAL.
*     MESSAGE E029 WITH P_BSZNUM.
**    This program cannot be used for & data services!
*   ENDIF.

 AT SELECTION-SCREEN ON P_MONAT.
*  Period check
   PERFORM VER_PERIOD   USING P_MONAT.

 AT SELECTION-SCREEN ON BLOCK B102.
*  Block check
   PERFORM VER_BLOCK_B102 USING P_NORM
                                P_ISMET
                                P_PACK.

 AT SELECTION-SCREEN ON P_PACK.

 AT SELECTION-SCREEN ON P_OUTF.
* A file name is required for live operation
   IF P_TESZT IS INITIAL AND P_OUTF IS INITIAL.
     MESSAGE E146.
*   Please enter the name of the accounting file.
   ENDIF.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_OUTF.
   PERFORM FILENAME_GET USING P_OUTF.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
*++0015 2009.05.22 BG
   CASE SY-UCOMM.
     WHEN 'KBL'.
       CALL TRANSACTION '/ZAK/OUT_BELNR_V'.
   ENDCASE.
*--0015 2009.05.22 BG


*  Definition of designations
   PERFORM READ_ADDITIONALS.
*  File check
   PERFORM VER_FILENAME USING P_OUTF.
*++0012 2008.12.16 BG
**  Checking the tax-free part of a business gift
*   PERFORM VER_12_OBLIGATORY USING P_MONAT
*                                   P_UZAJ
*                          CHANGING V_SUBRC.
*   IF NOT V_SUBRC IS INITIAL.
*     MESSAGE I083.
**   Please enter the value of the "Business gift tax-free part" field!
*   ENDIF.
*--0012 2008.12.16 BG

* file name check
   PERFORM FILENAME_OBLIGATORY USING P_OUTF.

*++0012 2008.12.16 BG
**  Inspection of the tax-free part of representation
*   PERFORM VER_12_OBLIGATORY USING P_MONAT
*                                   P_REPR
*                          CHANGING V_SUBRC.
*   IF NOT V_SUBRC IS INITIAL.
*     MESSAGE I084.
**   Please enter the value of the "Representation tax-free part" field!
*   ENDIF.
*--0012 2008.12.16 BG


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*++0015 2009.05.22 BG
* We define this excluded document number
   PERFORM GET_KBELNR TABLES I_KBELNR
                      USING  P_BUKRS
                             P_KBELNR.
*--0015 2009.05.22 BG

*++0006 2007.10.08  BG (FMC)
*++0017 BG 2009.10.29
**  Company shooting
*   PERFORM ROTATE_BUKRS_OUTPUT USING P_BUKRS
*                                     V_SEL_BUKRS.
*  Company shooting
   PERFORM ROTATE_BUKRS_OUTPUT TABLES I_AD_BUKRS
                               USING  P_BUKRS
                                      V_SEL_BUKRS.
*--0017 BG 2009.10.29

   IF P_BUKRS NE V_SEL_BUKRS.
     REFRESH I_/ZAK/BEVALL.

     CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
       EXPORTING
         I_BUKRS      = P_BUKRS
         I_BTYPART    = P_BTYPAR
       TABLES
         T_BTYPE      = R_BTYPE
         T_/ZAK/BEVALL = I_/ZAK/BEVALL
       EXCEPTIONS
         ERROR_BTYPE  = 1
         OTHERS       = 2.
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ENDIF.
*--0006 2007.10.08  BG (FMC)


*  Eligibility check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTYPAR
                                 C_ACTVT_01.

*  If BYTPE is empty, it is defined
*++0002 BG 2006/10/26
*  IF P_BTYPE IS INITIAL.
   IF R_BTYPE[] IS INITIAL.

*     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
*          EXPORTING
*               I_BUKRS     = P_BUKRS
*               I_BTYPART   = P_BTYPAR
*               I_GJAHR     = P_GJAHR
*               I_MONAT     = P_MONAT
*          IMPORTING
*               E_BTYPE     = P_BTYPE
*          EXCEPTIONS
*               ERROR_MONAT = 1
*               ERROR_BTYPE = 2
*               OTHERS      = 3.
*     IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     ENDIF.
     CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
       EXPORTING
         I_BUKRS      = P_BUKRS
         I_BTYPART    = P_BTYPAR
       TABLES
         T_BTYPE      = R_BTYPE
         T_/ZAK/BEVALL = I_/ZAK/BEVALL
       EXCEPTIONS
         ERROR_BTYPE  = 1
         OTHERS       = 2.
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
   ENDIF.
*--0002 BG 2006/10/26


*++0011 2008.10.17 BG
*  Data sorting
   PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                    0
                                    0.
*--0011 2008.10.17 BG

*  Reading company data
   PERFORM GET_T001 USING P_BUKRS
                          V_SUBRC.
   IF NOT V_SUBRC IS INITIAL.
     MESSAGE A036 WITH P_BUKRS.
*   Error defining & company data!(plate T001)
   ENDIF.

*  Data sorting
   PERFORM VALOGAT USING V_SUBRC.
   IF V_SUBRC <> 0.
*    there is no data matching the selection.
     MESSAGE I031.
     EXIT.
   ENDIF.

*  If you chose 12.v.larger snow and then you have to collect all of them
*  data.(Period 13 does not include all the records of the year, only the
*  13th monthly and so on)
*  sign correctly to calculate the ratio
*++0012 2008.12.16 BG
*++0002 BG 2006/10/26
*   IF P_MONAT >= 12.
**++0011 2008.10.17 BG
**  Determination of annual data
*     PERFORM PROGRESS_INDICATOR USING TEXT-P02
*                                      0
*                                      0.
**--0011 2008.10.17 BG
*     PERFORM EVES_ADATOK_SUM TABLES I_/ZAK/SZJA_CUST
*                                      I_BSEG
*                                      R_BTYPE
*                                      I_BTYPE_ARANY
*                             USING    P_UZAJ
*                                      P_REPR.
**                             CHANGING V_A_ARANY
**                                      V_R_ARANY.
*   ELSE.
*--0012 2008.12.16 BG
*     V_A_ARANY = 1.
*     V_R_ARANY = 1.
   LOOP AT R_BTYPE.
     CLEAR I_BTYPE_ARANY.
     MOVE R_BTYPE-LOW TO I_BTYPE_ARANY-BTYPE.
     MOVE 1 TO I_BTYPE_ARANY-A_ARANY.
     MOVE 1 TO I_BTYPE_ARANY-R_ARANY.
     APPEND I_BTYPE_ARANY.
   ENDLOOP.
*++0012 2008.12.16 BG
*   ENDIF.
**--0002 BG 2006/10/26
*--0012 2008.12.16 BG


*++0002 BG 2006/10/26
*  the selected BSEG lines are distributed in the /ZAK/ANALITIKA table and
*  for accounting
*  PERFORM SOR_SETRAK USING V_SUBRC.
*--0002 BG 2006/10/26
*++0008 BG 2007/02/07
*  A new routine is necessary because in the case of a change of year in the self-revision data
*  only replaced the BTYPE, not the ABEV ID.
*  The order must be reversed, the BSEG item must be read first
*  and determine the appropriate SZJA_CUST for the row based on the year
*  rekordot.
   PERFORM SOR_SZETRAK_NEW.
*--0008 BG 2007/02/07

*++0002 BG 2006/10/26
*  Once everything has been sorted, we create the new analytics records
*++0011 2008.10.17 BG
*  Generate analytics records
   PERFORM PROGRESS_INDICATOR USING TEXT-P04
                                    0
                                    0.
*--0011 2008.10.17 BG
   PERFORM GEN_ANALITIKA.
*--0002 BG 2006/10/26

*  Call EXIT
   PERFORM CALL_EXIT.

*++0011 2008.10.17 BG
*  Accounting file rotation (cost center)
   PERFORM ROTATION_DATA TABLES I_/ZAK/SZJA_EXCEL
                         USING  P_BUKRS.
*--0011 2008.10.17 BG

*  Test or production run, database modification, etc.
   PERFORM INS_DATA USING P_TESZT.
   IF P_TESZT IS INITIAL.
*    Accounts payable to EXCEL
*++FI 20070213
*     PERFORM DOWNLOAD_FILE
*                 TABLES
*                    I_/ZAK/SZJA_EXCEL
*                 USING
*                    P_OUTF
*                 CHANGING
*                    V_SUBRC.
     PERFORM DOWNLOAD_FILE_V2
                 TABLES
                    I_/ZAK/SZJA_EXCEL
                 USING
                    P_OUTF
                 CHANGING
                    V_SUBRC.
*--FI 20070213
   ENDIF.

*   PERFORM feldolgozas USING v_subrc.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
 END-OF-SELECTION.

   PERFORM LIST_DISPLAY.



************************************************************************
* ALPROGRAMOK
***********************************************************************
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
*
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

*++0002 BG 2006/10/26
** Name of declaration type
*   IF NOT P_BTYPE IS INITIAL.
*     SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
*        WHERE LANGU = SY-LANGU
*          AND BUKRS = P_BUKRS
*          AND BTYPE = P_BTYPE.
*   ENDIF.


** Name of data service
*   IF NOT P_BSZNUM IS INITIAL.
*     SELECT SINGLE SZTEXT INTO P_BSZTXT FROM /ZAK/BEVALLDT
*            WHERE LANGU = SY-LANGU
*              AND BUKRS = P_BUKRS
*              AND BTYPE = P_BTYPE
*              AND BSZNUM = P_BSZNUM.
*   ENDIF.
*--0002 BG 2006/10/26

 ENDFORM.                    " read_additionals
*&---------------------------------------------------------------------*
*&      Form  ver_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
 FORM VER_PERIOD USING    $MONAT.

   IF NOT $MONAT BETWEEN '01' AND '16'.
     MESSAGE E020.
*   Please enter the value of the period between 01-16!
   ENDIF.

 ENDFORM.                    " ver_period
*&---------------------------------------------------------------------*
*&      Form  ver_block_b102
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_NORM  text
*      -->P_P_ISMET  text
*      -->P_P_PACK  text
*----------------------------------------------------------------------*
 FORM VER_BLOCK_B102 USING    $NORM
                              $ISMET
                              $PACK.

   IF NOT $NORM IS INITIAL AND NOT $PACK IS INITIAL.
     MESSAGE I021.
*   Upload ID ignored!
     CLEAR $PACK.
   ENDIF.

   IF NOT $ISMET IS INITIAL AND $PACK IS INITIAL.
     MESSAGE E022.
*   Please enter the upload ID!
   ENDIF.

 ENDFORM.                    " ver_block_b102
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILENAME_GET USING $FILE.

   DATA: L_FILENAME TYPE STRING,
         L_PATH     TYPE STRING,
         L_FULLPATH TYPE STRING.

* ++ 0001 CST 2006.05.27
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
*     EXPORTING
*       WINDOW_TITLE = 'Accounting File'
*       DEFAULT_EXTENSION       = '*.XLS'
**      DEFAULT_FILE_NAME       =
**      file_filter             = '*.XLS'
*       INITIAL_DIRECTORY       = 'C:\temp'
*     CHANGING
*       FILENAME                = L_FILENAME
*       PATH                    = L_PATH
*       FULLPATH                = L_FULLPATH
*     EXCEPTIONS
*       CNTL_ERROR              = 1
*       ERROR_NO_GUI            = 2
*       OTHERS                  = 3
*       .
*   IF SY-SUBRC NE 0.
*     MESSAGE E082 WITH L_FULLPATH.
**   Error after opening the file!
*   ELSE.
*     MOVE L_FULLPATH TO $FILE.
*   ENDIF.
**   ENDIF.


   DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 12.07.2016
*   CALL FUNCTION 'WS_FILENAME_GET'
*      EXPORTING  DEF_FILENAME     =  '*.XLS'
**                 DEF_PATH         = 'C:\temp'
*                 MASK             =  L_MASK
*                 MODE             = 'S'
*                 TITLE = 'Accounting File'
*      IMPORTING  FILENAME         =   $FILE
**               RC               =  DUMMY
*      EXCEPTIONS INV_WINSYS       =  04
*                 NO_BATCH         =  08
*                 SELECTION_CANCEL =  12
*                 SELECTION_ERROR  =  16.

   DATA L_EXTENSION TYPE STRING.
   DATA L_TITLE     TYPE STRING.
   DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.

   CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
     EXPORTING
       WINDOW_TITLE      = 'Könyvelési fájl'
*      DEFAULT_EXTENSION =
*      EFAULT_FILE_NAME  =
*      WITH_ENCODING     =
       FILE_FILTER       = '*.XLS'
*      INITIAL_DIRECTORY =
*      DEFAULT_ENCODING  =
     IMPORTING
*      FILENAME          =
*      PATH              =
       FULLPATH          = L_FULLPATH
*      USER_ACTION       =
*      FILE_ENCODING     =
     .
   $FILE = L_FULLPATH.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 12.07.2016

   CHECK SY-SUBRC EQ 0.
* -- 0001 CST 2006.05.27

 ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  ver_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_OUTF  text
*----------------------------------------------------------------------*
 FORM VER_FILENAME USING    $FILE.

   DATA:
     L_FULLPATH TYPE STRING,
     L_RC       TYPE I.
*            L_FULLPATH   LIKE RLGRAP-FILENAME,
*            L_RC         TYPE C.

   DATA: BEGIN OF LI_FILE OCCURS 0,
           LINE(50),
         END OF LI_FILE.

   CHECK NOT $FILE IS INITIAL.
   MOVE $FILE TO L_FULLPATH.

   MOVE '1' TO LI_FILE-LINE.

*++0001 2007.01.03 BG (FMC)
* ++ 0001 CST 2006.05.27
   CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
     EXPORTING
*      BIN_FILESIZE            =
       FILENAME                = L_FULLPATH
*      filetype                = 'DAT'
*      APPEND                  = SPACE
*      write_field_separator   = 'X'
*      HEADER                  = '00'
*      TRUNC_TRAILING_BLANKS   = SPACE
*      WRITE_LF                = 'X'
*      COL_SELECT              = SPACE
*      COL_SELECT_MASK         = SPACE
*  IMPORTING
*      FILELENGTH              =
     CHANGING
       DATA_TAB                = LI_FILE[]
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
*      OTHERS                  = 22
     .


*   CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**   BIN_FILESIZE                  = ' '
**   CODEPAGE                      = ' '
*       FILENAME                      = L_FULLPATH
**   FILETYPE                      = 'ASC'
**   MODE                          = ' '
**   WK1_N_FORMAT                  = ' '
**   WK1_N_SIZE                    = ' '
**   WK1_T_FORMAT                  = ' '
**   WK1_T_SIZE                    = ' '
**   COL_SELECT                    = ' '
**   COL_SELECTMASK                = ' '
**   NO_AUTH_CHECK                 = ' '
** IMPORTING
**   FILELENGTH                    =
*     TABLES
*       DATA_TAB                      = LI_FILE[]
**   FIELDNAMES                    =
*    EXCEPTIONS
*      FILE_OPEN_ERROR               = 1
*      FILE_WRITE_ERROR              = 2
*      INVALID_FILESIZE              = 3
*      INVALID_TYPE                  = 4
*      NO_BATCH                      = 5
*      UNKNOWN_ERROR                 = 6
*      INVALID_TABLE_WIDTH           = 7
*      GUI_REFUSE_FILETRANSFER       = 8
*      CUSTOMER_ERROR                = 9
*      OTHERS                        = 10.
* -- 0001 CST 2006.05.27
*--0001 2007.01.03 BG (FMC)


   IF SY-SUBRC <> 0.
     MESSAGE E082 WITH L_FULLPATH.
*      Error after opening the file!
   ELSE.
*++0001 2007.01.03 BG (FMC)
* ++ 0001 CST 2006.05.27
*    Delete pattern
     CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_DELETE
       EXPORTING
         FILENAME = L_FULLPATH
       CHANGING
         RC       = L_RC.

*     CALL FUNCTION 'WS_FILE_DELETE'
*       EXPORTING
*         FILE   = L_FULLPATH
*       IMPORTING
*         RETURN = L_RC.

* -- 0001 CST 2006.05.27
*--0001 2007.01.03 BG (FMC)
   ENDIF.


 ENDFORM.                    " ver_filename
*&---------------------------------------------------------------------*
*&      Form  ver_12_obligatory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MONAT  text
*      -->P_P_UZAJ  text
*----------------------------------------------------------------------*
 FORM VER_12_OBLIGATORY USING    $MONAT
                                 $FIELD
                     CHANGING    $SUBRC.

   CLEAR $SUBRC.
* Compulsory for period 12
   IF $MONAT BETWEEN 12 AND 16 AND $FIELD IS INITIAL.
     MOVE 4 TO $SUBRC.
   ENDIF.

 ENDFORM.                    " ver_12_obligatory
*&---------------------------------------------------------------------*
*&      Form  valogat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT USING    $SUBRC.
*  Sort settings
*++0002 BG 2006/10/26
   PERFORM VALOGAT_BEALLITAS TABLES I_/ZAK/SZJA_CUST
                                    R_BTYPE
*++0009 BG 2008.07.03
                                    S_SAKNR
*--0009 BG 2008.07.03
                              USING P_BUKRS
*                                   P_BTYPE
                                    P_BSZNUM
                           CHANGING V_SUBRC.
*--0002 BG 2006/10/26
   $SUBRC = V_SUBRC.
   IF V_SUBRC <> 0.
*    Error defining SZJA settings!
     MESSAGE E089 WITH '/ZAK/SZJA_CUST_V'.
   ENDIF.

*  /Selection of ZAK/SZJA_ABEV for WL accounting
*++0002 BG 2006/10/26
   PERFORM VALOGAT_ABEV_MEZOK  TABLES R_BTYPE
                               USING  P_BUKRS
*                                     P_BTYPE
                                      'WL'
                            CHANGING  W_/ZAK/SZJA_ABEV
                                      V_SUBRC.
*--0002 BG 2006/10/26
   IF V_SUBRC <> 0.
*    Error in defining ABEV - FIELD!
     MESSAGE E089 WITH '/ZAK/SZJA_ABEV_V'.
   ENDIF.

*   /Sorting ZAK/ADMITTED
*++0002 BG 2006/10/26
*   PERFORM VALOGAT_/ZAK/BEVALL  USING W_/ZAK/BEVALL
*                                     P_BUKRS
*                                     P_BTYPE
*                            CHANGING V_SUBRC.
*   IF V_SUBRC <> 0.
**    Error in defining BEVALL - FIELD!
*     MESSAGE E089 WITH '/ZAK/BEVALL_V'.
*   ENDIF.
*--0002 BG 2006/10/26

*  Sorting of accounting records
   PERFORM SZJA_ADATOK_LEVAL TABLES I_/ZAK/SZJA_CUST
                                    I_BSEG
                                    I_BKPF
*++0015 2009.05.22 BG
                                    I_KBELNR
*--0015 2009.05.22 BG
                              USING P_BUKRS
                                    P_GJAHR
*                                   P_BTYPE
                                    P_BSZNUM
*++0006 2007.10.08  BG (FMC)
                                    V_SEL_BUKRS
*--0006 2007.10.08  BG (FMC)

                           CHANGING $SUBRC.



 ENDFORM.                    " valogat
*&---------------------------------------------------------------------*
*&      Form  valogat_beallitas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_BEALLITAS TABLES $/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                               $BTYPE STRUCTURE R_BTYPE
*++0009 BG 2008.07.03
                               $SAKNR STRUCTURE S_SAKNR
*--0009 BG 2008.07.03
                        USING    $BUKRS
*                                $BTYPE
                                 $BSZNUM
                        CHANGING $SUBRC.
*++1908 #10.
   FIELD-SYMBOLS <SZJA_CUST> TYPE /ZAK/SZJA_CUST.

   DEFINE LM_DATE.
     &1(2)   = '20'.
     &1+2(2) = &2(2).
     &1+4(2) = &3.
     &1+6(2) = &4.
   END-OF-DEFINITION.
*--1908 #10.

*selects the setting data based on the data of the selection screen
   SELECT * INTO TABLE $/ZAK/SZJA_CUST
            FROM /ZAK/SZJA_CUST
            WHERE BUKRS  = $BUKRS
*             AND BTYPE  = $BTYPE
              AND BTYPE  IN $BTYPE
              AND BSZNUM = $BSZNUM
*++0009 BG 2008.07.03
              AND SAKNR IN $SAKNR
*--0009 BG 2008.07.03
*++0012 2008.12.16 BG
              AND /ZAK/EVES = ''
*--0012 2008.12.16 BG
              .
   $SUBRC = SY-SUBRC.
*++1908 #10.
   LOOP AT $/ZAK/SZJA_CUST ASSIGNING <SZJA_CUST> WHERE DATAB IS INITIAL
                                                   OR DATBI IS INITIAL.
*    Filling in empty date fields
     IF <SZJA_CUST>-DATAB IS INITIAL.
*++1908 #11.
*       LM_DATE <SZJA_CUST>-DATAB  <SZJA_CUST>-BTYPE '01' '01'.
       SELECT SINGLE DATAB INTO <SZJA_CUST>-DATAB
                           FROM /ZAK/BEVALL
                          WHERE BUKRS EQ <SZJA_CUST>-BUKRS
                            AND BTYPE EQ <SZJA_CUST>-BTYPE.
*--1908 #11.
     ENDIF.
     IF <SZJA_CUST>-DATBI IS INITIAL.
*++1908 #11.
*       LM_DATE <SZJA_CUST>-DATBI  <SZJA_CUST>-BTYPE '12' '31'.
       SELECT SINGLE DATBI INTO <SZJA_CUST>-DATBI
                           FROM /ZAK/BEVALL
                          WHERE BUKRS EQ <SZJA_CUST>-BUKRS
                            AND BTYPE EQ <SZJA_CUST>-BTYPE.
*--1908 #11.
     ENDIF.
   ENDLOOP.
*--1908 #10.

 ENDFORM.                    " valogat_beallitas
*&---------------------------------------------------------------------*
*&      Form  feldolgozas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM FELDOLGOZAS USING    P_V_SUBRC.
*  If you have chosen the 12th month, then all the data must be collected
*  sign correctly to calculate the ratio
   EXIT.
   IF P_MONAT = 12.
*     PERFORM EVES_ADATOK_SUM TABLES I_/ZAK/SZJA_CUST
*                                      I_BSEG
*                             USING    P_UZAJ
*                                      P_REPR
*                             CHANGING V_A_ARANY
*                                      V_R_ARANY.
   ELSE.
     V_A_ARANY = 1.
     V_R_ARANY = 1.
   ENDIF.
*  calculates the tax base values ​​in the i_BSEG table
   PERFORM ADOALAP_SZAMITAS TABLES   I_/ZAK/SZJA_CUST
                                      I_BSEG
                                      I_BKPF
                             USING    V_A_ARANY
                                      V_R_ARANY.

*  Transfers the data to the /ZAK/ANALITIKA table.
   PERFORM ANALITIKA_TOLT TABLES   I_/ZAK/SZJA_CUST
                                   I_/ZAK/SZJA_ABEV
                                   I_/ZAK/ANALITIKA
                                   I_BSEG
                                   I_BKPF.






 ENDFORM.                    " feldolgozas
*&---------------------------------------------------------------------*
*&      Form  bseg_ker
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_GJAHR  text
*      -->P_AUFNR  text
*      -->P_HKONT  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM BSEG_KER TABLES   $I_BSIS STRUCTURE BSIS
                        $I_BSEG STRUCTURE BSEG
               CHANGING $SUBRC.
*    I'm sorting through the possible records.
   SELECT  * INTO TABLE $I_BSEG
             FROM BSEG
             FOR ALL ENTRIES IN $I_BSIS
             WHERE BUKRS = $I_BSIS-BUKRS
               AND GJAHR = $I_BSIS-GJAHR
               AND BELNR = $I_BSIS-BELNR
               AND BUZEI = $I_BSIS-BUZEI.       "#EC CI_DB_OPERATION_OK[2431747]

   $SUBRC = SY-SUBRC.

*++0007 2008.01.21 BG (FMC)
*  The company needs to be uploaded due to filming
*  field XREF1.
   CHECK $SUBRC IS INITIAL.

   LOOP AT $I_BSEG INTO W_BSEG.

     SELECT SINGLE XREF1 INTO W_BSEG-XREF1
                         FROM BSEG
                        WHERE BUKRS EQ W_BSEG-BUKRS
                          AND BELNR EQ W_BSEG-BELNR
                          AND GJAHR EQ W_BSEG-GJAHR
                          AND ( LIFNR NE '' OR KUNNR NE '' )
                          AND XREF1 NE ''.                    "#EC CI_DB_OPERATION_OK[2431747]
     IF SY-SUBRC EQ 0.
       MODIFY  $I_BSEG FROM W_BSEG TRANSPORTING XREF1.
     ENDIF.
   ENDLOOP.
*--0007 2008.01.21 BG (FMC)


 ENDFORM.                    " bseg_ker
*&---------------------------------------------------------------------*
*&      Form  bkpf_ker
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM BKPF_KER  TABLES  $I_BSIS   STRUCTURE BSIS
                        $I_BKPF   STRUCTURE BKPF

                USING   $SUBRC.

   SELECT * INTO TABLE $I_BKPF
            FROM BKPF
            FOR ALL ENTRIES IN $I_BSIS
            WHERE BUKRS = $I_BSIS-BUKRS
              AND BELNR = $I_BSIS-BELNR
              AND GJAHR = $I_BSIS-GJAHR.
*++BG 2006/08/11
*The program also selected non-HUF items
*mishandled in analytics because of the items a
*Calculated from the DMBTR (own currency) field for the currency
*on the other hand, BKPF-WAERS wrote a value (e.g. EUR).
*Therefore, the company always enters T001-WAERS in BKPF_WAERS
*let's enter!
   IF SY-SUBRC NE 0.
     $SUBRC = SY-SUBRC.
   ELSE.
     LOOP AT $I_BKPF.
       SELECT SINGLE WAERS INTO $I_BKPF-WAERS
                           FROM T001
                          WHERE BUKRS = $I_BKPF-BUKRS.
       MODIFY $I_BKPF TRANSPORTING WAERS.
     ENDLOOP.
   ENDIF.
*--BG 2006/08/11

 ENDFORM.                    " bkpf_ker
*&---------------------------------------------------------------------*
*&      Form  tetel_szures
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SUBRC  text
*----------------------------------------------------------------------*
 FORM TETEL_SZURES  TABLES $BKPF   STRUCTURE BKPF
                           $BSEG   STRUCTURE BSEG
                    USING  $SUBRC.
   DATA : L_TABIX LIKE SY-TABIX.
   SORT $BKPF.
   LOOP AT $BSEG INTO W_BSEG.
*    places the number of the current row
     L_TABIX = SY-TABIX.
*    search for the head data
     READ TABLE $BKPF WITH KEY BUKRS = W_BSEG-BUKRS
                               BELNR = W_BSEG-BELNR
                               GJAHR = W_BSEG-GJAHR.
*    If you can't find the head data for the item, you don't need the item either, because
*    the type of receipt is not good v.the accounting period.
*    The item is not needed even if the assignment starts with WL
*    (we book these receipts)
     IF SY-SUBRC <> 0 OR W_BSEG-ZUONR(2) = 'WL'.
       DELETE $BSEG INDEX L_TABIX.
     ENDIF.

   ENDLOOP.
   IF $BSEG[] IS INITIAL.
*    there is no BSEG item corresponding to the head data
     $SUBRC = 4.
   ENDIF.

 ENDFORM.                    " tetel_szures
*&---------------------------------------------------------------------*
*&      Form sja_datak_leval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM SZJA_ADATOK_LEVAL TABLES $/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                               $I_BSEG          STRUCTURE BSEG
                               $I_BKPF          STRUCTURE BKPF
*++0015 2009.05.22 BG
                               $I_KBELNR        STRUCTURE /ZAK/OUT_BELNR
*--0015 2009.05.22 BG
                         USING $BUKRS
                               $GJAHR
*                              $BTYPE
                               $BSZNUM
*++0006 2007.10.08  BG (FMC)
                               $SEL_BUKRS
*--0006 2007.10.08  BG (FMC)
                      CHANGING $SUBRC.
*  transition boards for sorting.
   DATA LI_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
   DATA LI_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.
   DATA L_SUBRC LIKE SY-SUBRC.
   DATA LW_BSIS TYPE  BSIS.
   DATA LI_BSIS TYPE STANDARD TABLE OF BSIS INITIAL SIZE 0.
*++0006 2007.10.08  BG (FMC)
   DATA L_BUKRS TYPE  BUKRS.
*--0006 2007.10.08  BG (FMC)
*++0011 2008.10.31 BG
   DATA L_LINES LIKE SY-TABIX.

   DESCRIBE TABLE $/ZAK/SZJA_CUST LINES L_LINES.
*--0011 2008.10.31 BG



*  sorting BSEG based on the parameter table
   LOOP AT $/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.
*++0011 2008.10.31 BG
*    Data sorting
     PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                      L_LINES
                                      SY-TABIX.
*--0011 2008.10.31 BG

     REFRESH: LI_BSEG, LI_BKPF, LI_BSIS.

     PERFORM GET_BSIS TABLES LI_BSIS
*++0003 2009.05.22 BG
                             $I_KBELNR
*--0003 2009.05.22 BG
                     USING  $BUKRS
                            $GJAHR
                            P_MONAT
                            W_/ZAK/SZJA_CUST-/ZAK/EVES
                            W_/ZAK/SZJA_CUST-AUFNR
                            W_/ZAK/SZJA_CUST-SAKNR
                   CHANGING L_SUBRC.
     IF L_SUBRC <> 0.
*      there is no data matching the condition, the next one can come
       CONTINUE.
     ENDIF.

*    control WL (we book these receipts)
     PERFORM TETEL_WL_SZURES TABLES LI_BSIS
                              USING L_SUBRC.

**    sort BSEG records
     PERFORM BSEG_KER TABLES LI_BSIS
                             LI_BSEG
                   CHANGING L_SUBRC.
     IF L_SUBRC <> 0.
*      there is no data matching the condition, the next one can come
       CONTINUE.
     ENDIF.
*    Head BKPF data for checking BSEG.
*     REFRESH LI_BKPF.
     PERFORM BKPF_KER TABLES LI_BSIS
                             LI_BKPF
                      USING  L_SUBRC.
     IF L_SUBRC <> 0.
*      there is no HEAD data, the item is not needed either
       CONTINUE.
     ENDIF.
*    If everything is fine, I will put the data away
     PERFORM FEJ_ATVESZ   TABLES LI_BKPF
                                 $I_BKPF.
     PERFORM TETEL_ATVESZ TABLES LI_BSEG
                                 $I_BSEG.


   ENDLOOP.
   IF $I_BSEG[] IS INITIAL.
*    there is no corresponding BSEG item
     $SUBRC = 4.
*++0002 BG 2006/10/26
   ELSE.
*  Delete duplicate records
     SORT $I_BKPF.
     SORT $I_BSEG.
     DELETE ADJACENT DUPLICATES FROM $I_BKPF COMPARING BUKRS BELNR GJAHR
     .
     DELETE ADJACENT DUPLICATES FROM $I_BSEG COMPARING BUKRS BELNR GJAHR
                                                                   BUZEI
                                                                   .
*--0002 BG 2006/10/26
   ENDIF.

*++0006 2007.10.08  BG (FMC)
*  Filtering BSEG records by rotated company code
   LOOP AT $I_BSEG INTO W_BSEG.
     READ TABLE $I_BKPF INTO W_BKPF
                    WITH KEY BUKRS = W_BSEG-BUKRS
                             BELNR = W_BSEG-BELNR
                             GJAHR = W_BSEG-GJAHR.

     IF SY-SUBRC EQ 0.
       PERFORM ROTATE_BUKRS_INPUT TABLES I_AD_BUKRS         "++0017 BG
                                  USING  W_BSEG
                                         W_BKPF
                               CHANGING  L_BUKRS.
       IF L_BUKRS NE $SEL_BUKRS.
         DELETE $I_BSEG.
       ENDIF.
     ENDIF.
   ENDLOOP.
*--0006 2007.10.08  BG (FMC)

 ENDFORM.                    " sja_data_leval
*&---------------------------------------------------------------------*
*&      Form  fej_atvesz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_bkpf  text
*      -->P_I_bkpf  text
*----------------------------------------------------------------------*
 FORM FEJ_ATVESZ TABLES   $LI_BKPF STRUCTURE BKPF
                          $I_BKPF  STRUCTURE BKPF.

   APPEND LINES OF $LI_BKPF TO $I_BKPF.

 ENDFORM.                    " fej_atvesz

*&---------------------------------------------------------------------*
*&      Form  tetel_atvesz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSEG  text
*      -->P_I_BSEG  text
*----------------------------------------------------------------------*
 FORM TETEL_ATVESZ TABLES   $LI_BSEG STRUCTURE BSEG
                          $I_BSEG  STRUCTURE BSEG.
   APPEND LINES OF $LI_BSEG TO $I_BSEG.

 ENDFORM.                    " fej_atvesz
*&---------------------------------------------------------------------*
*&      Form eves_data_sum
*&---------------------------------------------------------------------*
*       Collects the annual data and calculates the ratio
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_I_BSEG  text
*      <--P_A_SUM  text
*      <--P_R_SUM  text
*----------------------------------------------------------------------*
 FORM EVES_ADATOK_SUM TABLES   $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                               $I_BSEG          STRUCTURE BSEG
                               $R_BTYPE         STRUCTURE R_BTYPE
                               $I_ARANY         STRUCTURE I_BTYPE_ARANY
                      USING    $UZAJ
                               $REPR
                               .
*                      CHANGING $A_ARANY
*                               $R_ARANY.

   RANGES: LR_AUFNR FOR BSEG-AUFNR.
   DATA : L_TMP_ADOALAP LIKE BSEG-DMBTR.
   DATA : L_A_ADOALAP LIKE BSEG-DMBTR.
   DATA : L_R_ADOALAP LIKE BSEG-DMBTR.
   DATA : L_SZORZO TYPE I.
*++0012 2008.12.16 BG
*   DATA : L_UZAJ LIKE P_UZAJ.
*   DATA : L_REPR LIKE P_REPR.
   DATA : L_UZAJ TYPE DMBTR.
   DATA : L_REPR TYPE DMBTR.
*--0012 2008.12.16 BG

*  Because of the representation of the selection screen
   L_UZAJ = $UZAJ / 100.
   L_REPR = $REPR / 100.

   LOOP AT $R_BTYPE.
     CLEAR $I_ARANY.
*++0003 BG 2007/01/05
     CLEAR: L_A_ADOALAP, L_R_ADOALAP.
*--0003 BG 2007/01/05
     LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                              WHERE /ZAK/EVES <> ' '
                                AND BTYPE EQ $R_BTYPE-LOW.

       CLEAR LR_AUFNR. REFRESH LR_AUFNR.
*    It makes the order a condition for the selection
       IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
         LR_AUFNR = 'IEQ'.
         LR_AUFNR-LOW = W_/ZAK/SZJA_CUST-AUFNR.
         APPEND  LR_AUFNR.
       ENDIF.

*    It walks all the way through the appropriate BSEG lots
       LOOP AT $I_BSEG INTO W_BSEG
                       WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                         AND AUFNR IN  LR_AUFNR.

*      search for the head data
         READ TABLE I_BKPF INTO W_BKPF
                            WITH KEY BUKRS = W_BSEG-BUKRS
                                     BELNR = W_BSEG-BELNR
                                     GJAHR = W_BSEG-GJAHR.


*  It calculates the tax base according to the conditions
         PERFORM ANALITIKA_ADOALAP_SZAMITAS USING W_BSEG
                                                  W_BKPF
                                               W_/ZAK/SZJA_CUST-/ZAK/EVES
                                                W_/ZAK/SZJA_CUST-ADOALAP
                                                 W_/ZAK/SZJA_CUST-/ZAK/WL
*++0014 2010.01.08 BG
                                                  W_/ZAK/SZJA_CUST-MWSKZ
*--0014 2010.01.08 BG
                                                  1  "v_a_arany
                                                  1  "v_r_arany
                                        CHANGING L_TMP_ADOALAP.

*       IF w_bseg-shkzg = 'S'.
*         l_szorzo = 1.
*       ELSE.
*         l_szorzo = -1.
*       ENDIF.
         IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'A'.
*         l_a_adoalap = l_a_adoalap + ( w_bseg-dmbtr * l_szorzo ).
           L_A_ADOALAP = L_A_ADOALAP + L_TMP_ADOALAP.

         ELSE.
           L_R_ADOALAP = L_R_ADOALAP + L_TMP_ADOALAP.
         ENDIF.

       ENDLOOP.

     ENDLOOP.

     $I_ARANY-BTYPE = $R_BTYPE-LOW.

*  Once we have the tax base, we calculate the ratio
     IF  L_A_ADOALAP <= L_UZAJ OR L_A_ADOALAP = 0.
*    If the total tax base does not reach the tax-free part,
*    the ratio is 0 because nothing needs to be calculated.
*      $A_ARANY = 0.
       $I_ARANY-A_ARANY = 0.
     ELSE.
*      $A_ARANY = 1 - ( L_UZAJ / L_A_ADOALAP ).
       $I_ARANY-A_ARANY = 1 - ( L_UZAJ / L_A_ADOALAP ).
     ENDIF.
     IF  L_R_ADOALAP <= L_REPR  OR L_R_ADOALAP = 0.
*    If the total tax base does not reach the tax-free part,
*    the ratio is 0 because nothing needs to be calculated.
*      $R_ARANY = 0.
       $I_ARANY-R_ARANY = 0.
     ELSE.
*      $R_ARANY = 1 - ( L_REPR / L_R_ADOALAP ).
       $I_ARANY-R_ARANY = 1 - ( L_REPR / L_R_ADOALAP ).
     ENDIF.
     APPEND $I_ARANY.
   ENDLOOP.

 ENDFORM.                    " eves_data_sum
*&---------------------------------------------------------------------*
*&      Form  adoalap_szamitas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_I_BSEG  text
*      -->P_I_BKPF  text
*      -->P_V_A_ARANY  text
*      -->P_V_R_ARANY  text
*----------------------------------------------------------------------*
 FORM ADOALAP_SZAMITAS TABLES   $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                                                  $I_BSEG STRUCTURE BSEG
                                                  $I_BKPF STRUCTURE BKPF
                                                       USING    $A_ARANY
                                                                $R_ARANY
                                                                .

   RANGES: LR_AUFNR FOR BSEG-AUFNR.
*  It is stored for the current index of the table I_BSEG
   DATA : L_TABIX LIKE SY-TABIX.

*  We search for I_BSEG records through settings
   LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

     CLEAR LR_AUFNR. REFRESH LR_AUFNR.
*    It makes the order a condition for the selection
     IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
       LR_AUFNR = 'IEQ'.
       LR_AUFNR-LOW = W_/ZAK/SZJA_CUST-AUFNR.
       APPEND  LR_AUFNR.
     ENDIF.
*    It walks all the way through the appropriate BSEG lots
     LOOP AT $I_BSEG INTO W_BSEG
                     WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                       AND AUFNR IN  LR_AUFNR.
       L_TABIX = SY-TABIX.
*    search for the head data
       READ TABLE $I_BKPF INTO W_BKPF
                          WITH KEY BUKRS = W_BSEG-BUKRS
                                   BELNR = W_BSEG-BELNR
                                   GJAHR = W_BSEG-GJAHR.
       IF SY-SUBRC <> 0.
*      It can't be like that here
       ENDIF.
*      In the case of WL biz. variety, it must be multiplied by 1.2
       IF W_BKPF-BLART = 'WL'.
         W_BSEG-DMBTR = W_BSEG-DMBTR * '1.2'.
       ENDIF.
*      Based on the setting table, the tax base must be multiplied by %
       W_BSEG-DMBTR = W_BSEG-DMBTR *
                      ( W_/ZAK/SZJA_CUST-ADOALAP / 100 ).
*      It must also be multiplied by the ratio, depending on what it is
*      tipus  A / P
       IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'A'.
         W_BSEG-DMBTR = W_BSEG-DMBTR * $A_ARANY.
       ENDIF.
       IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'R'.
         W_BSEG-DMBTR = W_BSEG-DMBTR * $R_ARANY.
       ENDIF.
*      writes the new value back to the table.
       MODIFY $I_BSEG FROM W_BSEG INDEX L_TABIX TRANSPORTING  DMBTR.
     ENDLOOP.
   ENDLOOP.

 ENDFORM.                    " adoalap_szamitas
*&---------------------------------------------------------------------*
*&      Form  valogat_abev_mezok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_ABEV  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_ABEV_MEZOK  TABLES $BTYPE STRUCTURE R_BTYPE
                          USING $BUKRS
*                               $BTYPE
                                $FIELD
                          CHANGING
                               $W_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                                $SUBRC.

   SELECT SINGLE * INTO  $W_/ZAK/SZJA_ABEV
            FROM /ZAK/SZJA_ABEV
            WHERE BUKRS     = $BUKRS
*             AND BTYPE     = $BTYPE
              AND BTYPE     IN $BTYPE
              AND FIELDNAME = $FIELD.

   $SUBRC = SY-SUBRC.


 ENDFORM.                    " valogat_abev_mezok
*&---------------------------------------------------------------------*
*&      Form analytics_tolt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ANALITIKA_TOLT    TABLES  $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                                $I_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                                $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                                         $I_BSEG          STRUCTURE BSEG
                                         $I_BKPF          STRUCTURE BKPF
                                         .


   RANGES: LR_AUFNR FOR BSEG-AUFNR.
*  It is stored for the current index of the table I_BSEG
   DATA : L_TABIX LIKE SY-TABIX.

*  We search for I_BSEG records through settings
   LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

     CLEAR LR_AUFNR. REFRESH LR_AUFNR.
*    It makes the order a condition for the selection
     IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
       LR_AUFNR = 'IEQ'.
       LR_AUFNR-LOW = W_/ZAK/SZJA_CUST-AUFNR.
       APPEND  LR_AUFNR.
     ENDIF.
*    It walks all the way through the appropriate BSEG lots
     LOOP AT $I_BSEG INTO W_BSEG
                     WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                       AND AUFNR IN  LR_AUFNR.
       L_TABIX = SY-TABIX.
*      find out when you need analytes for the given batch
       PERFORM ANALITIKA_ATAD TABLES $I_/ZAK/SZJA_ABEV
                                     $I_/ZAK/ANALITIKA
                               USING W_BSEG
                                     W_/ZAK/SZJA_CUST.

     ENDLOOP.
   ENDLOOP.

 ENDFORM.                    " analytics_tolt
*&---------------------------------------------------------------------*
*&      Form analytics_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_/ZAK/SZJA_ABEV  text
*      -->P_$I_/ZAK/ANALITIKA text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_CUST  text
*----------------------------------------------------------------------*
 FORM ANALITIKA_ATAD TABLES  $I_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                             $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                     USING   $W_BSEG          STRUCTURE BSEG
                             $W_/ZAK/SZJA_CUST STRUCTURE W_/ZAK/SZJA_CUST.
*  Definition of % fields
   FIELD-SYMBOLS <FS_MEZO> TYPE ANY.

*  Runs through the fields and takes the % from the setting
   LOOP AT $I_/ZAK/SZJA_ABEV INTO W_/ZAK/SZJA_ABEV.

*    is taken over from the setting by the given % field (fields 7 - 15)
     ASSIGN COMPONENT W_/ZAK/SZJA_ABEV-FIELDNAME OF STRUCTURE
                      $W_/ZAK/SZJA_CUST TO <FS_MEZO>.

*    ANALITIKA is only needed if the % is filled
     IF NOT <FS_MEZO> IS INITIAL.

*      COMPLETES line 1 of the analytics.
*      PERFORM analytics_deleted USING w_/zak/analytics
*                                      $w_/zak/szja_cust
*                                      <fs_mezo>
*                                      w_/zak/szja_abev-abevaz
*                                      $w_bseg.

*      Saves the analytics record.
       APPEND  W_/ZAK/ANALITIKA  TO $I_/ZAK/ANALITIKA.
     ENDIF.




   ENDLOOP.

 ENDFORM.                    " analytics_data
*&---------------------------------------------------------------------*
*&      Form analytics_deleted
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/ANALITIKA text
*      -->P_<FS_MEZO>  text
*      -->P_W_BSEG  text
*----------------------------------------------------------------------*
 FORM ANALITIKA_KITOLT USING $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                             $W_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                             $W_BSEG          STRUCTURE BSEG
                             $W_BKPF          STRUCTURE BKPF
                             $W_/ZAK/BEVALL    STRUCTURE /ZAK/BEVALL
*++0006 BG 2007.10.15
                             $SEL_BUKRS
                             $BUKRS
*--0006 BG 2007.10.15
                             $SUBRC.

   DATA L_GJAHR TYPE GJAHR.
*++0005 BG 2007.05.08
   DATA L_BLDAT LIKE SY-DATUM.
*--0005 BG 2007.05.08


   CLEAR $W_/ZAK/ANALITIKA.
   CLEAR $SUBRC.
*  Fill in all possible data
   MOVE-CORRESPONDING $W_BSEG TO $W_/ZAK/ANALITIKA.

*++0006 BG 2007.10.15
   MOVE $SEL_BUKRS TO $W_/ZAK/ANALITIKA-BUKRS.
   MOVE $BUKRS TO $W_/ZAK/ANALITIKA-FI_BUKRS.
*--0006 BG 2007.10.15

*  $W_/ZAK/ANALITIKA-BTYPE = P_BTYPE.
   $W_/ZAK/ANALITIKA-BTYPE = $W_/ZAK/SZJA_CUST-BTYPE.

*++0005 BG 2007.05.08
*  We do not define it here, but the ANALITIKA year and month
*  based on
**  Definition of type of evidence
*   PERFORM GET_BLART USING $W_BKPF-BLDAT
*                           P_GJAHR
*                           $W_/ZAK/BEVALL-BLART
*                  CHANGING $W_/ZAK/ANALITIKA-BLART.
*--0005 BG 2007.05.08

*  setting accounting period and date
   IF NOT $W_/ZAK/SZJA_CUST-/ZAK/EVES IS INITIAL.
     L_GJAHR = P_GJAHR + 1.
*    We check the return type for the period
     PERFORM GET_VERIFY_BTYPE_FROM_DATUM TABLES I_/ZAK/BEVALL
                                         USING  $W_/ZAK/SZJA_CUST-BTYPE
                                                L_GJAHR
*++BG 2007.04.18
*                                               '04'
                                                C_REPI_MONAT
*--BG 2007.04.18
                                                $SUBRC.

     IF $SUBRC NE 0.
       EXIT.
     ENDIF.

*If it is an annual return, it must be set to C_REPI_MONAT of the following year
     $W_/ZAK/ANALITIKA-GJAHR = P_GJAHR + 1.
*++BG 2007.04.18
*    $W_/ZAK/ANALITIKA-MONAT = '04'.
     $W_/ZAK/ANALITIKA-MONAT = C_REPI_MONAT.
*--BG 2007.04.18
     PERFORM GET_LAST_DAY_OF_PERIOD
                               USING P_GJAHR
                                     '12'
                            CHANGING $W_/ZAK/ANALITIKA-BUDAT.

*++0005 BG 2007.05.08
*   ELSEIF $W_/ZAK/BEVALL-BLART = $W_BKPF-BLART
*       OR ( $W_BKPF-BLART(1) = 'E' )
**++ FI 20070308
*       OR ( $W_BKPF-BLART(1) = 'F' ).
**-- FI 20070308
   ELSEIF $W_BKPF-BLART IN S_KBLART.
*--0005 BG 2007.05.08

*++0005 BG 2007.05.08
**    We check the return type for the period
*     PERFORM GET_VERIFY_BTYPE_FROM_DATUM TABLES I_/ZAK/BEVALL
*                                         USING  $W_/ZAK/SZJA_CUST-BTYPE
*                                                $W_BKPF-BLDAT(4)
*                                                $W_BKPF-BLDAT+4(2)
*                                                $SUBRC.
*  We determine the type of return that exists for the period
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = P_BUKRS
         I_BTYPART   = C_BTYPART_SZJA
         I_GJAHR     = $W_BKPF-BLDAT(4)
         I_MONAT     = $W_BKPF-BLDAT+4(2)
*     IMPORTING
*        E_BTYPE     =
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
*--0005 BG 2007.05.08
     IF $SUBRC NE 0.
       EXIT.
     ENDIF.


*    If the date depends on the type of certificate
     $W_/ZAK/ANALITIKA-GJAHR = $W_BKPF-BLDAT(4).
     $W_/ZAK/ANALITIKA-MONAT = $W_BKPF-BLDAT+4(2).
     PERFORM GET_LAST_DAY_OF_PERIOD
                            USING $W_/ZAK/ANALITIKA-GJAHR
                                  $W_/ZAK/ANALITIKA-MONAT
                         CHANGING $W_/ZAK/ANALITIKA-BUDAT.
*++0005 2009.01.12 BG
     W_/ZAK/ANALITIKA-BLDAT = $W_BKPF-BLDAT.
*--0005 2009.01.12 BG
   ELSE.

*    We check the return type for the period
     PERFORM GET_VERIFY_BTYPE_FROM_DATUM TABLES I_/ZAK/BEVALL
                                         USING  $W_/ZAK/SZJA_CUST-BTYPE
                                                P_GJAHR
                                                P_MONAT
                                                $SUBRC.

     IF $SUBRC NE 0.
       EXIT.
     ENDIF.

*    Az alapeset ,
     $W_/ZAK/ANALITIKA-GJAHR = P_GJAHR.
     $W_/ZAK/ANALITIKA-MONAT = P_MONAT.

     PERFORM GET_LAST_DAY_OF_PERIOD
                            USING $W_/ZAK/ANALITIKA-GJAHR
                                  $W_/ZAK/ANALITIKA-MONAT
                         CHANGING $W_/ZAK/ANALITIKA-BUDAT.

   ENDIF.

   CHECK $SUBRC IS INITIAL.

*  Definition of type of evidence
*   PERFORM GET_BLART USING $W_BKPF-BLDAT
*                           P_GJAHR
*                           $W_/ZAK/BEVALL-BLART
*                  CHANGING $W_/ZAK/ANALITIKA-BLART.

*++0005 BG 2007.05.08
*  the type of document must be determined based on ANALITIKA
   CLEAR L_BLDAT.
   CONCATENATE $W_/ZAK/ANALITIKA-GJAHR
               $W_/ZAK/ANALITIKA-MONAT
               '01' INTO L_BLDAT.
*  Definition of type of evidence
   PERFORM GET_BLART USING L_BLDAT
                           P_GJAHR
                           $W_/ZAK/BEVALL-BLART
                  CHANGING $W_/ZAK/ANALITIKA-BLART.
*--0005 BG 2007.05.08
*++0005 2009.01.12 BG
*  We don't charge it because it causes problems at BOOK if
*  excluded type of receipt.
*  W_/ZAK/ANALITIKA-BLDAT = $W_BKPF-BLDAT.
*--0005 2009.01.12 BG

   W_/ZAK/ANALITIKA-WAERS = $W_BKPF-WAERS.
   W_/ZAK/ANALITIKA-ABEVAZ = $W_/ZAK/SZJA_CUST-ABEVAZ.
   $W_/ZAK/ANALITIKA-BSZNUM = P_BSZNUM.
   $W_/ZAK/ANALITIKA-LAPSZ = '0001'.
   $W_/ZAK/ANALITIKA-BSEG_GJAHR = $W_BSEG-GJAHR.
   $W_/ZAK/ANALITIKA-BSEG_BELNR = $W_BSEG-BELNR.
   $W_/ZAK/ANALITIKA-BSEG_BUZEI = $W_BSEG-BUZEI.
*  IF THE COST SPACE IS NOT EMPTY, THEN WE TRANSFER IT TO ANALITIKA
   IF NOT $W_/ZAK/SZJA_CUST-KOSTL IS INITIAL.
     $W_/ZAK/ANALITIKA-KTOSL = $W_/ZAK/SZJA_CUST-KOSTL.
   ENDIF.
*++0016 BG 2009/08/25
*  Receiving a PST item
   IF NOT $W_BSEG-PROJK IS INITIAL.
     CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
       EXPORTING
         INPUT  = $W_BSEG-PROJK
       IMPORTING
         OUTPUT = $W_/ZAK/ANALITIKA-POSID.
   ENDIF.
*--0016 BG 2009/08/25
*++0003 BG 2007/01/05
   READ TABLE I_BTYPE_ARANY WITH KEY BTYPE = $W_/ZAK/SZJA_CUST-BTYPE.
   IF SY-SUBRC EQ 0.
*--0003 BG 2007/01/05

*  It calculates the tax base according to the conditions
     PERFORM ANALITIKA_ADOALAP_SZAMITAS USING $W_BSEG
                                              $W_BKPF
                                              $W_/ZAK/SZJA_CUST-/ZAK/EVES
                                              $W_/ZAK/SZJA_CUST-ADOALAP
                                              $W_/ZAK/SZJA_CUST-/ZAK/WL
*++0014 2010.01.08 BG
                                              $W_/ZAK/SZJA_CUST-MWSKZ
*--0014 2010.01.08 BG
*++0003 BG 2007/01/05
*                                             V_A_ARANY
*                                             V_R_ARANY
                                              I_BTYPE_ARANY-A_ARANY
                                              I_BTYPE_ARANY-R_ARANY
*--0003 BG 2007/01/05
                                     CHANGING $W_/ZAK/ANALITIKA-FIELD_N.
*++0003 BG 2007/01/05
   ENDIF.
*--0003 BG 2007/01/05



 ENDFORM.                    " analytics_dismissed
*&---------------------------------------------------------------------*
*&      Form row_sets
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SOR_SZETRAK USING $SUBRC.

*  jumps through the settings lines
*  This is because they were originally selected based on this
*  items and the /zak/szja_cust record from the BSEG is not always clear
*  look for it.
   RANGES: L_R_AUFNR FOR BSEG-AUFNR.
*++FI 20070213
   DATA: L_SZAMLA_BELNR(10).
*--FI 20070213
*++ 0004 FI
   DATA: L_BEVHO(6).
*-- 0004 FI

   DATA L_SUBRC LIKE SY-SUBRC.


   LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

     CLEAR W_/ZAK/BEVALL.
     READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY
                                  BUKRS = W_/ZAK/SZJA_CUST-BUKRS
                                  BTYPE = W_/ZAK/SZJA_CUST-BTYPE.
     IF SY-SUBRC NE 0.
       MESSAGE E114.
*      Declaration type definition error!
     ENDIF.
*++ 0004 FI
*Returns that do not belong to the accounting period must be omitted
*setting
     CONCATENATE P_GJAHR P_MONAT INTO L_BEVHO.
     IF W_/ZAK/BEVALL-DATBI(6) >= L_BEVHO AND W_/ZAK/BEVALL-DATAB(6) <=
     L_BEVHO.
     ELSE.
       CONTINUE.
     ENDIF.
*-- 0004 FI

*    Makes a selection from the order
     PERFORM AUFNR_FELTOLT TABLES L_R_AUFNR
                           USING W_/ZAK/SZJA_CUST-AUFNR.

     LOOP AT I_BSEG INTO W_BSEG
                   WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                     AND AUFNR IN  L_R_AUFNR.

*      search for the head data
       READ TABLE I_BKPF INTO W_BKPF
                          WITH KEY BUKRS = W_BSEG-BUKRS
                                   BELNR = W_BSEG-BELNR
                                   GJAHR = W_BSEG-GJAHR.
*      If the ABEV identifier is not empty, then the line for analytics is required
       IF NOT W_/ZAK/SZJA_CUST-ABEVAZ IS INITIAL.
         IF NOT W_/ZAK/SZJA_CUST-/ZAK/EVES IS INITIAL
            AND P_MONAT < 12.
**          Candidates for ANNUAL are only needed if the month is 12
*           or greater
**          otherwise, they do not need to be given to the analytics table
*           but they still have to be posted
*           CONTINUE.
         ELSE.
*++0002 BG 2006/10/26
*          COMPLETES line 1 of the analytics.
           PERFORM ANALITIKA_KITOLT USING W_/ZAK/ANALITIKA
                                          W_/ZAK/SZJA_CUST
                                          W_BSEG
                                          W_BKPF
                                          W_/ZAK/BEVALL
*++0006 BG 2007.10.15
                                          V_SEL_BUKRS
                                          P_BUKRS
*--0006 BG 2007.10.15
                                          L_SUBRC.
           CHECK L_SUBRC EQ 0.
*--0002 BG 2006/10/26
**          ++ BG
*           PERFORM GET_ANALITIKA_ITEM TABLES I_/ZAK/ANALITIKA
*                                      USING W_/ZAK/ANALITIKA.
**          -- BG

*          Saves the analytics record.
           APPEND  W_/ZAK/ANALITIKA  TO I_/ZAK/ANALITIKA.
         ENDIF.
       ENDIF.
*      WL accounting
       IF NOT W_/ZAK/SZJA_CUST-/ZAK/WL IS INITIAL
          AND W_BKPF-BLART = 'WL'.
*          If the receipt is for the given month, it must be submitted only then
*          Items due to the annual sorting can also come here
*          otherwise they are not needed
         IF W_BKPF-MONAT = P_MONAT.
*++FI 20070213
*           PERFORM BOOK_WL USING W_BKPF
*                                 W_BSEG
*                                 W_/ZAK/SZJA_ABEV
*                                 W_/ZAK/BEVALL
*                                 W_/ZAK/SZJA_EXCEL.
**           writes the record
*           APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
           PERFORM BOOK_WL_V2 USING W_BKPF
                                    W_BSEG
                                    W_/ZAK/SZJA_ABEV
                                    W_/ZAK/BEVALL
                                    W_/ZAK/SZJA_EXCEL1
                                    W_/ZAK/SZJA_EXCEL2
                                    P_GJAHR
                                    P_MONAT.
*An identifier must unite the items, now it is an item number
           L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
           W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
           W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*           writes out the records
           APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
           APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.

*--FI 20070213
         ENDIF.
       ENDIF.
*      Transfer according to setting
       IF NOT W_/ZAK/SZJA_CUST-/ZAK/ATKONYV IS INITIAL.
*++FI 20070213
*         PERFORM BOOK_ATKONYV USING W_BKPF
*                               W_BSEG
*                               W_/ZAK/SZJA_ABEV
*                               W_/ZAK/BEVALL
*                               W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
*                               W_/ZAK/SZJA_EXCEL1.
**        writes the record
*         APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
         PERFORM BOOK_ATKONYV_V2 USING W_BKPF
                                       W_BSEG
                                       W_/ZAK/SZJA_ABEV
                                       W_/ZAK/BEVALL
                                       W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
                                       W_/ZAK/SZJA_EXCEL1
                                       W_/ZAK/SZJA_EXCEL2.
*An identifier must unite the items, now it is an item number
         L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
         W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
         W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*        writes the record
         APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
         APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
*--FI 20070213

       ENDIF.
     ENDLOOP.
   ENDLOOP.




 ENDFORM.                    " row_sets

*&---------------------------------------------------------------------*
*&      Form  aufnr_feltolt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LR_AUFNR  text
*      -->P_W_/ZAK/SZJA_CUST_AUFNR  text
*----------------------------------------------------------------------*
 FORM AUFNR_FELTOLT TABLES   $R_AUFNR STRUCTURE R_AUFNR
                    USING    $AUFNR.
   CLEAR $R_AUFNR. REFRESH $R_AUFNR.
*    It makes the order a condition for the selection
   IF NOT $AUFNR IS INITIAL.
     $R_AUFNR = 'IEQ'.
     $R_AUFNR-LOW = $AUFNR.
     APPEND  $R_AUFNR.
   ENDIF.

 ENDFORM.                    " aufnr_feltolt
*&---------------------------------------------------------------------*
*&      Form  valogat_/zak/bevall
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALL  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_/ZAK/BEVALL USING   $W_/ZAK/BEVALL STRUCTURE /ZAK/BEVALL
                                 $BUKRS
                                 $BTYPE
                        CHANGING $SUBRC.
   DATA  : L_DATBI LIKE  /ZAK/BEVALL-DATBI.

   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                              CHANGING L_DATBI.

   SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL
                         FROM /ZAK/BEVALL
                        WHERE BUKRS = $BUKRS
                          AND BTYPE = $BTYPE
                          AND DATBI >= L_DATBI.
   ENDSELECT .
   $SUBRC = SY-SUBRC.
 ENDFORM.                    " valogat_/zak/bevall
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
   IF $MONAT > '12'.
     CONCATENATE $GJAHR '12' '01' INTO L_DATE1.
   ELSE.
     CONCATENATE $GJAHR $MONAT '01' INTO L_DATE1.
   ENDIF.

   CALL FUNCTION 'LAST_DAY_OF_MONTHS'     "#EC CI_USAGE_OK[2296016]
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
*&      Form analytics tax base summary
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$W_BSEG  text
*      -->P_$W_/ZAK/SZJA_CUST_ADOALAP  text
*      <--P_$W_/ZAK/ANALITIKA_FIELD_N text
*      <--P_ENDFORM  text
*----------------------------------------------------------------------*
 FORM ANALITIKA_ADOALAP_SZAMITAS USING    $W_BSEG  STRUCTURE BSEG
                                          $W_BKPF  STRUCTURE BKPF
                                          $/ZAK/EVES
                                          $ADOALAP%
                                          $WL
*++0014 2010.01.08 BG
                                          $MWSKZ
*--0014 2010.01.08 BG
                                          $A_ARANY
                                          $R_ARANY
                                 CHANGING $FIELD_N.
   DATA : L_SZORZO TYPE I.

*++0014 2010.01.08 BG
   DATA LI_MWDAT LIKE RTAX1U15 OCCURS 0 WITH HEADER LINE.
   DATA L_MSATZ  TYPE MSATZ_F05L.

   IF $W_BKPF-BLART = 'WL' AND $WL = 'X' AND $MWSKZ IS INITIAL.
     MESSAGE E287 WITH $W_BKPF-BUKRS $W_BKPF-GJAHR $W_BSEG-HKONT.
*   There is no VAT code set for the WL field in /ZAK/SZJA_CUST (&/&/&)!
   ENDIF.
*--0014 2010.01.08 BG

*  determination of sign
   IF $W_BSEG-SHKZG = 'S'.
     L_SZORZO = 1.
   ELSE.
     L_SZORZO = -1.
   ENDIF.
   $FIELD_N = $W_BSEG-DMBTR * L_SZORZO.
*  In the case of WL biz. variety, it must be multiplied by 1.2
   IF $W_BKPF-BLART = 'WL' AND $WL = 'X'.
*++0014 2010.01.08 BG
*    $FIELD_N = $FIELD_N * '1.2'.
*  Determination of VAT code percentage
     CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
       EXPORTING
         I_BUKRS           = $W_BKPF-BUKRS
         I_MWSKZ           = $MWSKZ
*        I_TXJCD           = ' '
         I_WAERS           = $W_BKPF-WAERS
         I_WRBTR           = 0
*        I_ZBD1P           = 0
*        I_PRSDT           =
*        I_PROTOKOLL       =
*        I_TAXPS           =
*        I_ACCNT_EXT       =
*    IMPORTING
*        E_FWNAV           =
*        E_FWNVV           =
*        E_FWSTE           =
*        E_FWAST           =
       TABLES
         T_MWDAT           = LI_MWDAT
       EXCEPTIONS
         BUKRS_NOT_FOUND   = 1
         COUNTRY_NOT_FOUND = 2
         MWSKZ_NOT_DEFINED = 3
         MWSKZ_NOT_VALID   = 4
         KTOSL_NOT_FOUND   = 5
         KALSM_NOT_FOUND   = 6
         PARAMETER_ERROR   = 7
         KNUMH_NOT_FOUND   = 8
         KSCHL_NOT_FOUND   = 9
         UNKNOWN_ERROR     = 10
         ACCOUNT_NOT_FOUND = 11
         TXJCD_NOT_VALID   = 12
         OTHERS            = 13.
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.
       READ TABLE LI_MWDAT INDEX 1.
       L_MSATZ = 1 + ( LI_MWDAT-MSATZ / 100 ).
       $FIELD_N = $FIELD_N * L_MSATZ.
     ENDIF.
*--0014 2010.01.08 BG
   ENDIF.
*  Based on the setting table, the tax base must be multiplied by %
   $FIELD_N = $FIELD_N * ( $ADOALAP% / 100 ) .
*  It must also be multiplied by the ratio, depending on what it is
*  tipus  A / R
   IF $/ZAK/EVES = 'A'.
     $FIELD_N = $FIELD_N * $A_ARANY.
   ENDIF.
   IF $/ZAK/EVES = 'R'.
     $FIELD_N = $FIELD_N * $R_ARANY.
   ENDIF.



 ENDFORM.                    " analytics tax base sumitas
*&---------------------------------------------------------------------*
*&      Form Gen_analytics
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GEN_ANALITIKA.

   DATA LI_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA OCCURS 0 WITH HEADER LINE.

*It must be broken down by type of return
   LOOP AT R_BTYPE.
     LI_/ZAK/ANALITIKA[] = I_/ZAK/ANALITIKA[].
     DELETE LI_/ZAK/ANALITIKA WHERE BTYPE NE R_BTYPE-LOW.

     REFRESH IO_/ZAK/ANALITIKA.
     CLEAR   IO_/ZAK/ANALITIKA.

     CALL FUNCTION '/ZAK/SZJA_NEW_ROWS'
       EXPORTING
         I_BUKRS         = P_BUKRS
*        I_BTYPE         = P_BTYPE
         I_BTYPE         = R_BTYPE-LOW
         I_BSZNUM        = P_BSZNUM
       TABLES
*        I_/ZAK/ANALITIKA = I_/ZAK/ANALITIKA
         I_/ZAK/ANALITIKA = LI_/ZAK/ANALITIKA
         O_/ZAK/ANALITIKA = IO_/ZAK/ANALITIKA.
*    Copies the received records back to the original.
     APPEND LINES OF IO_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
   ENDLOOP.

 ENDFORM.                    " Gen_analytics
*&---------------------------------------------------------------------*
*&      Form  call_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_EXIT.
   CALL FUNCTION '/ZAK/SZJA_SAP_SEL_EXIT'
     EXPORTING
       I_BUKRS         = P_BUKRS
*      I_BTYPE         = P_BTYPE
       I_BSZNUM        = P_BSZNUM
     TABLES
       I_/ZAK/ANALITIKA = I_/ZAK/ANALITIKA.


 ENDFORM.                    " call_exit

*&---------------------------------------------------------------------*
*&      Form  ins_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INS_DATA USING $TESZT.

   DATA LI_RETURN TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0.
   DATA LW_RETURN TYPE BAPIRET2.

   DATA L_TEXTLINE1(80).
   DATA L_TEXTLINE2(80).
   DATA L_DIAGNOSETEXT1(80).
   DATA L_DIAGNOSETEXT2(80).
   DATA L_DIAGNOSETEXT3(80).
   DATA L_TITLE(40).

   DATA L_ANSWER.

   DATA L_PACK LIKE /ZAK/ANALITIKA-PACK.

   IF I_/ZAK/ANALITIKA[] IS INITIAL.
     MESSAGE I031.
*    The database does not contain a record that can be processed!
     EXIT.
   ENDIF.
*  The conversion must be called
   CALL FUNCTION '/ZAK/ANALITIKA_CONVERSION'
     TABLES
       T_ANALITIKA = I_/ZAK/ANALITIKA.

*  We always run it as a test first
   CALL FUNCTION '/ZAK/UPDATE'
     EXPORTING
*++0006 BG 2007.10.24
*      I_BUKRS     = P_BUKRS
       I_BUKRS     = V_SEL_BUKRS
*--0006 BG 2007.10.24
*++BG 2006.09.15
*      I_BTYPE     = P_BTYPE
       I_BTYPART   = P_BTYPAR
*--BG 2006.09.15
       I_BSZNUM    = P_BSZNUM
       I_PACK      = P_PACK
       I_GEN       = 'X'
       I_TEST      = 'X'
*      I_FILE      =
     TABLES
       I_ANALITIKA = I_/ZAK/ANALITIKA
       E_RETURN    = LI_RETURN.

*   Manage messages
   IF NOT LI_RETURN[] IS INITIAL.
     CALL FUNCTION '/ZAK/MESSAGE_SHOW'
       TABLES
         T_RETURN = LI_RETURN.
   ENDIF.

*  If it is not a test run, then we check if there is an ERROR
   IF NOT $TESZT IS INITIAL.
     LOOP AT LI_RETURN INTO LW_RETURN WHERE TYPE CA 'EA'.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       MESSAGE E062.
*     Data upload is not possible!
     ENDIF.
   ENDIF.

*  Live operation but there is an error message and not ERROR, question about the continuation
   IF $TESZT IS INITIAL.

     IF NOT LI_RETURN[] IS INITIAL.
*    Loading texts
       MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
       MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                            TO L_DIAGNOSETEXT1.
       MOVE 'Folytatja  feldolgozást?'(003)
                                            TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 12.07.2016
*       CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*         EXPORTING
*           DEFAULTOPTION        = 'N'
*           DIAGNOSETEXT1        = L_DIAGNOSETEXT1
**          DIAGNOSETEXT2        = ' '
**          DIAGNOSETEXT3        = ' '
*           TEXTLINE1            = L_TEXTLINE1
**          TEXTLINE2            = ' '
*           TITEL                = L_TITLE
*           START_COLUMN         = 25
*           START_ROW            = 6
**        CANCEL_DISPLAY       = 'X'
*           IMPORTING
*           ANSWER               = L_ANSWER
*                 .
       DATA L_QUESTION TYPE STRING.

       CONCATENATE L_DIAGNOSETEXT1
                   L_TEXTLINE1
                   INTO L_QUESTION SEPARATED BY SPACE.
       CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
           TITLEBAR              = L_TITLE
*          DIAGNOSE_OBJECT       = ' '
           TEXT_QUESTION         = L_QUESTION
*          TEXT_BUTTON_1         = 'Ja'(001)
*          ICON_BUTTON_1         = ' '
*          TEXT_BUTTON_2         = 'Nein'(002)
*          ICON_BUTTON_2         = ' '
           DEFAULT_BUTTON        = '2'
*          DISPLAY_CANCEL_BUTTON = 'X'
*          USERDEFINED_F1_HELP   = ' '
           START_COLUMN          = 25
           START_ROW             = 6
*          POPUP_TYPE            =
         IMPORTING
           ANSWER                = L_ANSWER.
       IF L_ANSWER EQ '1'.
         MOVE 'J' TO L_ANSWER.
       ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 12.07.2016
*    You can go anyway
     ELSE.
       MOVE 'J' TO L_ANSWER.
     ENDIF.

*    You can modify the database
     IF L_ANSWER EQ 'J'.
*      Modification of data
       CALL FUNCTION '/ZAK/UPDATE'
         EXPORTING
*++0006 BG 2007.10.24
*          I_BUKRS     = P_BUKRS
           I_BUKRS     = V_SEL_BUKRS
*--0006 BG 2007.10.24
*++BG 2006.09.15
*          I_BTYPE     = P_BTYPE
           I_BTYPART   = P_BTYPAR
*--BG 2006.09.15
           I_BSZNUM    = P_BSZNUM
           I_PACK      = P_PACK
           I_GEN       = 'X'
           I_TEST      = $TESZT
*          I_FILE      =
         TABLES
           I_ANALITIKA = I_/ZAK/ANALITIKA
           E_RETURN    = LI_RETURN.
*    We return the index
       LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*        We save the package identifier
         IF L_PACK IS INITIAL.
           MOVE W_/ZAK/ANALITIKA-PACK TO L_PACK.
         ENDIF.

         INSERT INTO /ZAK/ANALITIKA VALUES W_/ZAK/ANALITIKA.

*++BG 2007.10.08
*         UPDATE /ZAK/BSET SET ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
*                       WHERE BUKRS = W_/ZAK/ANALITIKA-BUKRS
*                         AND BELNR = W_/ZAK/ANALITIKA-BSEG_BELNR
*                         AND BUZEI = W_/ZAK/ANALITIKA-BSEG_BUZEI.
*--BG 2007.10.08

       ENDLOOP.
       COMMIT WORK AND WAIT.
       MESSAGE I033 WITH L_PACK.
*      Upload & package number done!
     ENDIF.
   ENDIF.
 ENDFORM.                    " ins_data
*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

 FORM LIST_DISPLAY.
   SORT I_/ZAK/ANALITIKA BY BUKRS BTYPE BSEG_GJAHR BSEG_BELNR
                           BSEG_BUZEI ABEVAZ.
   CALL SCREEN 9000.
 ENDFORM.                    " list_display
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
     IF P_TESZT IS INITIAL.
       SET TITLEBAR 'MAIN9000'.
     ELSE.
       SET TITLEBAR 'MAIN9000T'.
     ENDIF.
     SET PF-STATUS 'MAIN9000'.
   ENDIF.
   IF SY-DYNNR = '9001'.
     IF P_TESZT IS INITIAL.
       SET TITLEBAR 'MAIN9001'.
     ELSE.
       SET TITLEBAR 'MAIN9001T'.
     ENDIF.
     SET PF-STATUS 'MAIN9001'.
   ENDIF.

 ENDFORM.                    " set_status
*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/ANALITIKA[] text
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
     EXPORTING
       CONTAINER_NAME = V_CONTAINER.
   CREATE OBJECT V_GRID
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER.

* Compilation of a field catalog
   PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                          CHANGING $FIELDCAT.

* Exclusion of functions
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
       IT_OUTTAB            = $I_/ZAK/ANALITIKA.

   CREATE OBJECT V_EVENT_RECEIVER.
   SET HANDLER V_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK  FOR V_GRID.

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
*      -->P_SY_DYNNR  text
*      <--P_$FIELDCAT  text
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
       IF  S_FCAT-FIELDNAME = 'ADOAZON'  OR
           S_FCAT-FIELDNAME = 'XMANU'    OR
           S_FCAT-FIELDNAME = 'XDEFT'    OR
           S_FCAT-FIELDNAME = 'VORSTOR'  OR
           S_FCAT-FIELDNAME = 'STAPO'    OR
*           s_fcat-fieldname = 'DMBTR'    OR
*           s_fcat-fieldname = 'KOSTL'    OR
           S_FCAT-FIELDNAME = 'ZCOMMENT' OR
           S_FCAT-FIELDNAME = 'BOOK'     OR
           S_FCAT-FIELDNAME = 'KMONAT'."   OR
*           s_fcat-fieldname = 'AUFNR'.
         S_FCAT-NO_OUT = 'X'.
       ENDIF.
       IF S_FCAT-FIELDNAME = 'BSEG_GJAHR' OR
          S_FCAT-FIELDNAME = 'BSEG_BELNR' OR
          S_FCAT-FIELDNAME = 'BSEG_BUZEI' OR
          S_FCAT-FIELDNAME = 'AUFNR'      OR
          S_FCAT-FIELDNAME = 'HKONT'      OR
          S_FCAT-FIELDNAME = 'KOSTL'.

         S_FCAT-HOTSPOT = 'X'.
       ENDIF.

       MODIFY $FIELDCAT FROM S_FCAT.
     ENDLOOP.
   ELSEIF $DYNNR = '9001'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/SZJAEXCELV2'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = $FIELDCAT.



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
     WHEN 'EXCEL'.

       CALL SCREEN 9001.
* Exit
*++0005 BG 2007.05.08
*    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
     WHEN 'BACK'.
*--0005 BG 2007.05.08
       PERFORM EXIT_PROGRAM.
*++0005 BG 2007.05.08
     WHEN 'EXIT' OR 'CANCEL'.
       LEAVE PROGRAM.
*--0005 BG 2007.05.08
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
   LEAVE TO SCREEN 0 .
 ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  book_wl_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM BOOK_WL_V2 USING $BKPF STRUCTURE BKPF
                    $BSEG STRUCTURE BSEG
                    $ABEV STRUCTURE /ZAK/SZJA_ABEV
                    $BEVALL STRUCTURE /ZAK/BEVALL
                    $EXCEL1 STRUCTURE /ZAK/SZJAEXCELV2
                    $EXCEL2 STRUCTURE /ZAK/SZJAEXCELV2
                    $GJAHR
                    $MONAT.

   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL1,$EXCEL2.
*++0014 2009.04.20 BG
   DATA LI_MWDAT LIKE RTAX1U15 OCCURS 0 WITH HEADER LINE.
   DATA L_MSATZ  TYPE MSATZ_F05L.
*--0014 2009.04.20 BG

*  determination of sequence number
   $EXCEL1-BIZ_TETEL = '0001' .
   $EXCEL2-BIZ_TETEL = '0002' .
   $EXCEL1-PENZNEM = $BKPF-WAERS.
   $EXCEL2-PENZNEM = $BKPF-WAERS.
*  Definition of type of evidence
   PERFORM GET_BLART USING $BKPF-BLDAT
                           $GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL1-BF   .
   $EXCEL2-BF = $EXCEL1-BF.
*++ 0004 FI
   $EXCEL1-KK = '40'.
   $EXCEL2-KK = '50'.
*-- 0004 FI

*++0014 2009.04.20 BG
*  Determination of VAT code percentage
   CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
     EXPORTING
       I_BUKRS           = $BKPF-BUKRS
       I_MWSKZ           = $ABEV-MWSKZ
*      I_TXJCD           = ' '
       I_WAERS           = $BKPF-WAERS
       I_WRBTR           = 0
*      I_ZBD1P           = 0
*      I_PRSDT           =
*      I_PROTOKOLL       =
*      I_TAXPS           =
*      I_ACCNT_EXT       =
*    IMPORTING
*      E_FWNAV           =
*      E_FWNVV           =
*      E_FWSTE           =
*      E_FWAST           =
     TABLES
       T_MWDAT           = LI_MWDAT
     EXCEPTIONS
       BUKRS_NOT_FOUND   = 1
       COUNTRY_NOT_FOUND = 2
       MWSKZ_NOT_DEFINED = 3
       MWSKZ_NOT_VALID   = 4
       KTOSL_NOT_FOUND   = 5
       KALSM_NOT_FOUND   = 6
       PARAMETER_ERROR   = 7
       KNUMH_NOT_FOUND   = 8
       KSCHL_NOT_FOUND   = 9
       UNKNOWN_ERROR     = 10
       ACCOUNT_NOT_FOUND = 11
       TXJCD_NOT_VALID   = 12
       OTHERS            = 13.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     READ TABLE LI_MWDAT INDEX 1.
     L_MSATZ = LI_MWDAT-MSATZ / 100.
   ENDIF.
*--0014 2009.04.20 BG

   IF $BSEG-SHKZG = 'S'.
     MOVE   $BSEG-HKONT   TO $EXCEL1-FOKONYV.
     MOVE   $ABEV-KOVETEL TO $EXCEL2-FOKONYV.
*++0014 2009.04.20 BG
*    L_TMP_DMBTR = $BSEG-DMBTR * '0.2'.
     L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG

     MOVE   $BSEG-AUFNR   TO $EXCEL1-RENDELES. CLEAR $EXCEL2-RENDELES.
*++ 2009.03.30. BG
*     MOVE   'B3'          TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
*++0014 2009.04.20 BG
*     MOVE   'B4'          TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
     MOVE   $ABEV-MWSKZ    TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
*--0014 2009.04.20 BG
*-- 2009.03.30. BG
     MOVE   $BSEG-KOSTL   TO $EXCEL1-KTGH.     CLEAR $EXCEL2-KTGH.
     MOVE   $BSEG-PRCTR   TO $EXCEL1-PRCTR.    CLEAR $EXCEL2-PRCTR.
*++0015 BG 2009/08/25
*    Loading a PST item
     IF NOT $BSEG-PROJK IS INITIAL.
       CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
         EXPORTING
           INPUT  = $BSEG-PROJK
         IMPORTING
           OUTPUT = $EXCEL1-PST.
     ENDIF.
*--0015 BG 2009/08/25
*++ 0004 FI
*     $EXCEL1-KK = '40'.
*     $EXCEL2-KK = '50'.
*-- 0004 FI

   ELSE.
*    If the value is negative, 1 and 2 are exchanged
     MOVE   $BSEG-HKONT   TO $EXCEL2-FOKONYV.
     MOVE   $ABEV-KOVETEL TO $EXCEL1-FOKONYV.
*++ 0004 FI
*     L_TMP_DMBTR = $BSEG-DMBTR * '0.2' * -1.
*++0014 2009.04.20 BG
*    L_TMP_DMBTR = $BSEG-DMBTR * '0.2'.
     L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG
*-- 0004 FI
     MOVE   $BSEG-AUFNR   TO $EXCEL2-RENDELES. CLEAR $EXCEL1-RENDELES.
*++ 2009.03.30. BG
*     MOVE   'B3'          TO $EXCEL1-ADOKOD.   CLEAR $EXCEL2-ADOKOD.
*++0014 2009.04.20 BG
*     MOVE   'B4'          TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
     MOVE   $ABEV-MWSKZ   TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
*--0014 2009.04.20 BG
*-- 2009.03.30. BG
     MOVE   $BSEG-KOSTL   TO $EXCEL2-KTGH.     CLEAR $EXCEL1-KTGH.
     MOVE   $BSEG-PRCTR   TO $EXCEL2-PRCTR.    CLEAR $EXCEL1-PRCTR.
*++0015 BG 2009/08/25
*    Loading a PST item
     IF NOT $BSEG-PROJK IS INITIAL.
       CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
         EXPORTING
           INPUT  = $BSEG-PROJK
         IMPORTING
           OUTPUT = $EXCEL2-PST.
     ENDIF.
*--0015 BG 2009/08/25
*++ 0004 FI
*     $EXCEL1-KK = '50'.
*     $EXCEL2-KK = '40'.
*-- 0004 FI
   ENDIF.

   WRITE  $BKPF-BLDAT   TO $EXCEL1-BIZ_DATUM.
   WRITE  $BKPF-BLDAT   TO $EXCEL2-BIZ_DATUM.

*   MOVE   $BKPF-BUKRS   TO $EXCEL1-VALL.
*   MOVE   $BKPF-BUKRS   TO $EXCEL2-VALL.

*  The value must be in absolute value
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).
   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL1-OSSZEG.
   PERFORM SZAM_ATIR USING $EXCEL1-OSSZEG.
   $EXCEL2-OSSZEG = $EXCEL1-OSSZEG.
*  determination of the last day of the selection period
   PERFORM GET_LAST_DAY_OF_PERIOD USING $GJAHR
                                        $MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL1-KONYV_DAT.
   $EXCEL2-KONYV_DAT = $EXCEL1-KONYV_DAT.
*++2009.01.12 BG
*  It was not appropriate because at UREPI
*  when we selected the whole year in December
*  there was also a previous period for accounting
*   MOVE   $BKPF-MONAT   TO $EXCEL1-HO.
*   MOVE   $BKPF-MONAT   TO $EXCEL2-HO.
   MOVE   $MONAT   TO $EXCEL1-HO.
   MOVE   $MONAT   TO $EXCEL2-HO.
*--2009.01.12 BG

*   MOVE   'X'           TO $EXCEL-ASZ. !!!!????
   CONCATENATE 'WL' $BSEG-BELNR
               INTO  $EXCEL1-HOZZARENDELES
                     SEPARATED BY SPACE.
   $EXCEL2-HOZZARENDELES  = $EXCEL1-HOZZARENDELES.

   CONCATENATE $BSEG-BELNR '-' $BSEG-EBELN
                      INTO $EXCEL1-SZOVEG
                      SEPARATED BY SPACE.
   $EXCEL2-SZOVEG  = $EXCEL1-SZOVEG.

   MOVE   $BSEG-VBUND   TO $EXCEL1-PARTN_TARS.
   MOVE   $BSEG-VBUND   TO $EXCEL2-PARTN_TARS.
   IF $BKPF-BKTXT IS NOT INITIAL.
     MOVE   $BKPF-BKTXT   TO $EXCEL1-FEJSZOVEG.
     MOVE   $BKPF-BKTXT   TO $EXCEL2-FEJSZOVEG.
   ELSE.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL1-FEJSZOVEG.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL2-FEJSZOVEG.

   ENDIF.

 ENDFORM.                    " book_wl_v2
*&---------------------------------------------------------------------*
*&      Form  book_wl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM BOOK_WL USING $BKPF STRUCTURE BKPF
                    $BSEG STRUCTURE BSEG
                    $ABEV STRUCTURE /ZAK/SZJA_ABEV
                    $BEVALL STRUCTURE /ZAK/BEVALL
                    $EXCEL STRUCTURE /ZAK/SZJA_EXCEL.
   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL.
*  Definition of type of evidence
   PERFORM GET_BLART USING $BKPF-BLDAT
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL-BF   .

   IF $BSEG-SHKZG = 'S'.
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA1.
     MOVE   $ABEV-KOVETEL TO $EXCEL-SZAMLA2.
     L_TMP_DMBTR = $BSEG-DMBTR * '0.2'.
     MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL1. CLEAR $EXCEL-B_RENDEL2.
     MOVE   'B3'          TO $EXCEL-ADO2.      CLEAR $EXCEL-ADO1.
     MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH1.     CLEAR $EXCEL-KTGH2.
     MOVE   $BSEG-PRCTR   TO $EXCEL-PRCTR1.    CLEAR $EXCEL-PRCTR2.

   ELSE.
*    If the value is negative, 1 and 2 are exchanged
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA2.
     MOVE   $ABEV-KOVETEL TO $EXCEL-SZAMLA1.
     L_TMP_DMBTR = $BSEG-DMBTR * '0.2' * -1.
     MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL2. CLEAR $EXCEL-B_RENDEL1.
     MOVE   'B3'          TO $EXCEL-ADO1.      CLEAR $EXCEL-ADO2.
     MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH2.     CLEAR $EXCEL-KTGH1.
     MOVE   $BSEG-PRCTR   TO $EXCEL-PRCTR2.    CLEAR $EXCEL-PRCTR1.
   ENDIF.

   WRITE  $BKPF-BLDAT   TO $EXCEL-BIZ_DATUM.
*   MOVE   $bevall-blart TO $excel-bf.
   MOVE   $BKPF-BUKRS   TO $EXCEL-VALL.
*  The value must be in absolute value
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).
   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL-FORINT.
   PERFORM SZAM_ATIR USING $EXCEL-FORINT.
*  determination of the last day of the selection period
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL-KONYV_DAT.
   MOVE   $BKPF-MONAT   TO $EXCEL-HO.
*   MOVE   $bkpf-bktxt   TO $excel-fejszoveg. !!!!!!!!!!!!!!!!!!!!!!!
   MOVE   'X'           TO $EXCEL-ASZ.
   CONCATENATE 'WL' $BSEG-BELNR
* ++ FI 20070111
*               INTO  $EXCEL-HOZZARENDEL
               INTO  $EXCEL-HOZZARENDEL1
                     SEPARATED BY SPACE.
   $EXCEL-HOZZARENDEL2  = $EXCEL-HOZZARENDEL1.
* -- FI 20070111
*   MOVE   $BSEG-BELNR   TO $EXCEL-HOZZARENDEL.

   CONCATENATE $BSEG-BELNR '-' $BSEG-EBELN
* ++ FI 20070111
*                      INTO $EXCEL-SZOVEG
                      INTO $EXCEL-SZOVEG1
                      SEPARATED BY SPACE.
   $EXCEL-SZOVEG2 = $EXCEL-SZOVEG1.
*  MOVE   $BSEG-VBUND   TO $EXCEL-PATARS.
   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS1.
* -- FI 20070111




 ENDFORM.                    " book_wl
*&---------------------------------------------------------------------*
*&      Form  book_atkonyv_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BKPF  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_W_/ZAK/BEVALL  text
*      -->P_W_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM BOOK_ATKONYV_V2 USING $BKPF          STRUCTURE BKPF
                            $BSEG          STRUCTURE BSEG
                            $ABEV          STRUCTURE /ZAK/SZJA_ABEV
                            $BEVALL        STRUCTURE /ZAK/BEVALL
                            $/ZAK/ATKONYV
                            $EXCEL1        STRUCTURE /ZAK/SZJAEXCELV2
                            $EXCEL2        STRUCTURE /ZAK/SZJAEXCELV2.
   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL1, $EXCEL2.

*++0005 BG 2007.05.08
   DATA L_BLDAT LIKE SY-DATUM.
*--0005 BG 2007.05.08

*++0014 2009.04.20 BG
   DATA LI_MWDAT LIKE RTAX1U15 OCCURS 0 WITH HEADER LINE.
   DATA L_MSATZ  TYPE MSATZ_F05L.
*--0014 2009.04.20 BG

*  determination of sequence number
   $EXCEL1-BIZ_TETEL = '0001' .
   $EXCEL2-BIZ_TETEL = '0002' .
   $EXCEL1-PENZNEM = $BKPF-WAERS.
   $EXCEL2-PENZNEM = $BKPF-WAERS.

*++0014 2009.04.20 BG
*  Determination of VAT code percentage
   CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
     EXPORTING
       I_BUKRS           = $BKPF-BUKRS
       I_MWSKZ           = $ABEV-MWSKZ
*      I_TXJCD           = ' '
       I_WAERS           = $BKPF-WAERS
       I_WRBTR           = 0
*      I_ZBD1P           = 0
*      I_PRSDT           =
*      I_PROTOKOLL       =
*      I_TAXPS           =
*      I_ACCNT_EXT       =
*    IMPORTING
*      E_FWNAV           =
*      E_FWNVV           =
*      E_FWSTE           =
*      E_FWAST           =
     TABLES
       T_MWDAT           = LI_MWDAT
     EXCEPTIONS
       BUKRS_NOT_FOUND   = 1
       COUNTRY_NOT_FOUND = 2
       MWSKZ_NOT_DEFINED = 3
       MWSKZ_NOT_VALID   = 4
       KTOSL_NOT_FOUND   = 5
       KALSM_NOT_FOUND   = 6
       PARAMETER_ERROR   = 7
       KNUMH_NOT_FOUND   = 8
       KSCHL_NOT_FOUND   = 9
       UNKNOWN_ERROR     = 10
       ACCOUNT_NOT_FOUND = 11
       TXJCD_NOT_VALID   = 12
       OTHERS            = 13.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     READ TABLE LI_MWDAT INDEX 1.
     L_MSATZ = 1 + ( LI_MWDAT-MSATZ / 100 ).
   ENDIF.
*--0014 2009.04.20 BG

*++0005 BG 2007.05.08
*  Date determination for the type of evidence
   CLEAR L_BLDAT.
   IF $BKPF-BLART IN S_KBLART.
     MOVE $BKPF-BLDAT TO L_BLDAT.
   ELSE.
     CONCATENATE P_GJAHR
                 P_MONAT
                 '01' INTO L_BLDAT.
   ENDIF.
*--0005 BG 2007.05.08

*  Definition of type of evidence
*++0005 BG 2007.05.08
*  PERFORM GET_BLART USING $BKPF-BLDAT
   PERFORM GET_BLART USING L_BLDAT
*--0005 BG 2007.05.08
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL1-BF   .


   $EXCEL2-BF = $EXCEL1-BF.
*++ 0004 FI
   $EXCEL1-KK = '40'.
   $EXCEL2-KK = '50'.
*-- 0004 FI

   IF $BSEG-SHKZG = 'S'.
     MOVE   $/ZAK/ATKONYV  TO $EXCEL1-FOKONYV.
     MOVE   $BSEG-HKONT   TO $EXCEL2-FOKONYV.
*    For WL, multiply by 1.2
     IF $BKPF-BLART = 'WL'.
*++0014 2009.04.20 BG
*      L_TMP_DMBTR = $BSEG-DMBTR * '1.2'.
       L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG
     ELSE.
       L_TMP_DMBTR = $BSEG-DMBTR .
     ENDIF.
*++ 0004 FI
*     $EXCEL1-KK = '40'.
*     $EXCEL2-KK = '50'.
*-- 0004 FI
   ELSE.
*    If the value is negative, 1 and 2 are exchanged
     MOVE   $/ZAK/ATKONYV  TO $EXCEL2-FOKONYV.
     MOVE   $BSEG-HKONT   TO $EXCEL1-FOKONYV.
*    For WL, multiply by 1.2
     IF $BKPF-BLART = 'WL'.
*++ 0004 FI
*       L_TMP_DMBTR = $BSEG-DMBTR * '1.2' * -1.
*++0014 2009.04.20 BG
*      L_TMP_DMBTR = $BSEG-DMBTR * '1.2'.
       L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG
*-- 0004 FI
     ELSE.
*++ 0004 FI
*       L_TMP_DMBTR = $BSEG-DMBTR * -1.
       L_TMP_DMBTR = $BSEG-DMBTR .
*-- 0004 FI
     ENDIF.
*++ 0004 FI
*     $EXCEL1-KK = '50'.
*     $EXCEL2-KK = '40'.
*-- 0004 FI

   ENDIF.
   MOVE   $BSEG-VBUND   TO $EXCEL1-PARTN_TARS.

   MOVE   $BSEG-AUFNR   TO $EXCEL1-RENDELES.
   MOVE   $BSEG-AUFNR   TO $EXCEL2-RENDELES.
   MOVE   $BSEG-KOSTL   TO $EXCEL1-KTGH.
   MOVE   $BSEG-KOSTL   TO $EXCEL2-KTGH.
   MOVE   $BSEG-PPRCT   TO $EXCEL1-PRCTR.
   MOVE   $BSEG-PPRCT   TO $EXCEL2-PRCTR.
   WRITE  $BKPF-BLDAT   TO $EXCEL1-BIZ_DATUM.
   WRITE  $BKPF-BLDAT   TO $EXCEL2-BIZ_DATUM.
*   MOVE   $BKPF-BUKRS   TO $EXCEL-VALL.
*  The value must be in absolute value
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).

   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL1-OSSZEG.
   PERFORM SZAM_ATIR USING $EXCEL1-OSSZEG.

   $EXCEL2-OSSZEG = $EXCEL1-OSSZEG.
*  determination of the last day of the selection period
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL1-KONYV_DAT.
   WRITE  L_TMP_DAT     TO $EXCEL2-KONYV_DAT.
   MOVE   $BKPF-MONAT   TO $EXCEL1-HO.
   MOVE   $BKPF-MONAT   TO $EXCEL2-HO.
   MOVE   $BSEG-BELNR   TO $EXCEL1-SZOVEG.
   MOVE   $BSEG-BELNR   TO $EXCEL2-SZOVEG.
   MOVE   $BSEG-VBUND   TO $EXCEL1-PARTN_TARS.
   MOVE   $BSEG-VBUND   TO $EXCEL2-PARTN_TARS.
   MOVE   $BSEG-PPRCT   TO $EXCEL1-PARPRCTR.
   MOVE   $BSEG-PPRCT   TO $EXCEL2-PARPRCTR.
   IF $BKPF-BKTXT IS NOT INITIAL.
     MOVE   $BKPF-BKTXT   TO $EXCEL1-FEJSZOVEG.
     MOVE   $BKPF-BKTXT   TO $EXCEL2-FEJSZOVEG.
   ELSE.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL1-FEJSZOVEG.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL2-FEJSZOVEG.

   ENDIF.
*++0015 BG 2009/08/25
*    Loading a PST item
   IF NOT $BSEG-PROJK IS INITIAL.
     CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
       EXPORTING
         INPUT  = $BSEG-PROJK
       IMPORTING
         OUTPUT = $EXCEL1-PST.
   ENDIF.
*--0015 BG 2009/08/25

 ENDFORM.                    " book_atkonyv_v2
*&---------------------------------------------------------------------*
*&      Form  book_atkonyv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BKPF  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_W_/ZAK/BEVALL  text
*      -->P_W_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM BOOK_ATKONYV USING    $BKPF          STRUCTURE BKPF
                            $BSEG          STRUCTURE BSEG
                            $ABEV          STRUCTURE /ZAK/SZJA_ABEV
                            $BEVALL        STRUCTURE /ZAK/BEVALL
                            $/ZAK/ATKONYV
                            $EXCEL         STRUCTURE /ZAK/SZJA_EXCEL.
   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL.
*  Definition of type of evidence
   PERFORM GET_BLART USING $BKPF-BLDAT
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL-BF   .

   IF $BSEG-SHKZG = 'S'.
     MOVE   $/ZAK/ATKONYV  TO $EXCEL-SZAMLA1.
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA2.
*    For WL, multiply by 1.2
     IF $BKPF-BLART = 'WL'.
       L_TMP_DMBTR = $BSEG-DMBTR * '1.2'.
     ELSE.
       L_TMP_DMBTR = $BSEG-DMBTR .
     ENDIF.
   ELSE.
*    If the value is negative, 1 and 2 are exchanged
     MOVE   $/ZAK/ATKONYV  TO $EXCEL-SZAMLA2.
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA1.
*    For WL, multiply by 1.2
     IF $BKPF-BLART = 'WL'.
       L_TMP_DMBTR = $BSEG-DMBTR * '1.2' * -1.
     ELSE.
       L_TMP_DMBTR = $BSEG-DMBTR * -1.
     ENDIF.

   ENDIF.
* ++ FI 20070111
*   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS.
   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS1.
* -- FI 20070111
   MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL1.
   MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL2.
   MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH1.
   MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH2.
   MOVE   $BSEG-PPRCT   TO $EXCEL-PRCTR1.
   MOVE   $BSEG-PPRCT   TO $EXCEL-PRCTR2.
   WRITE  $BKPF-BLDAT   TO $EXCEL-BIZ_DATUM.
*   MOVE   $bevall-blart TO $excel-bf.
   MOVE   $BKPF-BUKRS   TO $EXCEL-VALL.
*  The value must be in absolute value
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).

   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL-FORINT.
   PERFORM SZAM_ATIR USING $EXCEL-FORINT.
*  determination of the last day of the selection period
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL-KONYV_DAT.
   MOVE   $BKPF-MONAT   TO $EXCEL-HO.
*   MOVE   $bkpf-bktxt   TO $excel-fejszoveg. !!!!!!!!!!!!
* ++ FI 20070111
*   MOVE   $BSEG-BELNR   TO $EXCEL-SZOVEG.
*   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS.
*   MOVE   $BSEG-PPRCT   TO $EXCEL-PARPROFC.
   MOVE   $BSEG-BELNR   TO $EXCEL-SZOVEG1.
   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS1.
   MOVE   $BSEG-PPRCT   TO $EXCEL-PARPROFC1.
* ++ FI 20070111

 ENDFORM.                    " book_atkonyv
*&---------------------------------------------------------------------*
*&      Form  download_file_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE_V2 TABLES $EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                        USING $OUTF
                     CHANGING L_SUBRC.
*   TABLES : DD03T.
   DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
         L_CANCEL(1).

   DATA: BEGIN OF I_FIELDS OCCURS 10,
           NAME(40),
         END OF I_FIELDS.

   DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

* Reading a data structure
   CALL FUNCTION 'DD_GET_DD03P_ALL'
     EXPORTING
       LANGU         = SYST-LANGU
       TABNAME       = '/ZAK/SZJAEXCELV2'
     TABLES
       A_DD03P_TAB   = I_DD03P
       N_DD03P_TAB   = I_DD03P_2
     EXCEPTIONS
       ILLEGAL_VALUE = 1
       OTHERS        = 2.

   IF SY-SUBRC = 0.

     LOOP AT I_DD03P WHERE  FIELDNAME <> '.INCLUDE'.
       CLEAR I_FIELDS-NAME.
       I_FIELDS-NAME = I_DD03P-DDTEXT.
       APPEND I_FIELDS.
     ENDLOOP.

   ENDIF.
*++MOL_UPG_UCCHECK István Forgó (NESS) 28.06.2016

*   CALL FUNCTION 'WS_DOWNLOAD'
*        EXPORTING
*             FILENAME                = $OUTF
*             FILETYPE                = 'DAT'
**       IMPORTING
**            CANCEL                  = L_CANCEL
*        TABLES
*             DATA_TAB                = $EXCEL
*             FIELDNAMES              = I_FIELDS
*        EXCEPTIONS
*             INVALID_FILESIZE        = 1
*             INVALID_TABLE_WIDTH     = 2
*             INVALID_TYPE            = 3
*             NO_BATCH                = 4
*             UNKNOWN_ERROR           = 5
*             GUI_REFUSE_FILETRANSFER = 6
*             CUSTOMER_ERROR          = 7
*             OTHERS                  = 8.
   DATA L_FILENAME_STRING TYPE STRING.

   MOVE $OUTF TO L_FILENAME_STRING.


   CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
     EXPORTING
       FILENAME                = L_FILENAME_STRING
       FILETYPE                = 'DAT'
       FIELDNAMES              = I_FIELDS[]
     CHANGING
       DATA_TAB                = $EXCEL[]
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
       NOT_SUPPORTED_BY_GUI    = 22
       ERROR_NO_GUI            = 23
       OTHERS                  = 24.

*--MOL_UPG_UCCHECK István Forgó (NESS) 28.06.2016
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.


 ENDFORM.                    " download_file_v2
*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE TABLES $EXCEL STRUCTURE /ZAK/SZJA_EXCEL
                    USING  $OUTF
                    CHANGING L_SUBRC.
   TABLES : DD03T.
   DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
         L_CANCEL(1).

   DATA: BEGIN OF I_FIELDS OCCURS 10,
           NAME(40),
         END OF I_FIELDS.

   DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03T   LIKE DD03T OCCURS 0 WITH HEADER LINE.


   SELECT * FROM DD03T INTO TABLE I_DD03T
            WHERE TABNAME = '/ZAK/SZJA_EXCEL'
              AND DDLANGUAGE = SYST-LANGU.




*  concatenate p_bukrs l_adonem l_esdat into l_def_filename
*    separated by '_'.
*  concatenate l_def_filename '.XLS' into l_def_filename.

* Reading a data structure
   CALL FUNCTION 'DD_GET_DD03P_ALL'
     EXPORTING
       LANGU         = SYST-LANGU
       TABNAME       = '/ZAK/SZJA_EXCEL'
     TABLES
       A_DD03P_TAB   = I_DD03P
       N_DD03P_TAB   = I_DD03P_2
     EXCEPTIONS
       ILLEGAL_VALUE = 1
       OTHERS        = 2.

   IF SY-SUBRC = 0.

     LOOP AT I_DD03P.
       CLEAR I_FIELDS-NAME.
       READ TABLE I_DD03T WITH KEY FIELDNAME = I_DD03P-FIELDNAME.
       I_FIELDS-NAME = I_DD03T-DDTEXT.
       APPEND I_FIELDS.
     ENDLOOP.

   ENDIF.

*++MOL_UPG_UCCHECK István Forgó (NESS) 28.06.2016
*   CALL FUNCTION 'WS_DOWNLOAD'
*        EXPORTING
*             FILENAME                = $OUTF
*             FILETYPE                = 'DAT'
**       IMPORTING
**            CANCEL                  = L_CANCEL
*        TABLES
*             DATA_TAB                = $EXCEL
*             FIELDNAMES              = I_FIELDS
*        EXCEPTIONS
*             INVALID_FILESIZE        = 1
*             INVALID_TABLE_WIDTH     = 2
*             INVALID_TYPE            = 3
*             NO_BATCH                = 4
*             UNKNOWN_ERROR           = 5
*             GUI_REFUSE_FILETRANSFER = 6
*             CUSTOMER_ERROR          = 7
*             OTHERS                  = 8.
   DATA L_FILENAME_STRING TYPE STRING.

   MOVE $OUTF TO L_FILENAME_STRING.


   CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
     EXPORTING
       FILENAME                = L_FILENAME_STRING
       FILETYPE                = 'DAT'
       FIELDNAMES              = I_FIELDS[]
     CHANGING
       DATA_TAB                = $EXCEL[]
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
       NOT_SUPPORTED_BY_GUI    = 22
       ERROR_NO_GUI            = 23
       OTHERS                  = 24.



*--MOL_UPG_UCCHECK István Forgó (NESS) 28.06.2016
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.


 ENDFORM.                    " download_file
*&---------------------------------------------------------------------*
*&      Form  get_blart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BLDAT  text
*      -->P_P_GJAHR  text
*      -->P_I_BLART  text
*      <--P_O_BLART  text
*----------------------------------------------------------------------*
 FORM GET_BLART USING    $BLDAT
                         $P_GJAHR
                         $I_BLART
                CHANGING $O_BLART.
   DATA: L_GJAHR LIKE BKPF-GJAHR,
         L_DIF   TYPE I,
         L_EV(1).

   L_GJAHR = $BLDAT(4). " It subtracts the year from the bizdate.
   L_DIF = L_GJAHR - $P_GJAHR.
   IF L_DIF < 0.
*    It affects the previous year
     L_DIF = ABS( L_DIF ).
     WRITE: L_DIF TO L_EV.
     $O_BLART(1) = 'E'.
     $O_BLART+1(1) = L_EV.
   ELSE.
     $O_BLART = $I_BLART.
   ENDIF.


 ENDFORM.                    " get_blart
*&---------------------------------------------------------------------*
*&      Form  szam_atir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$EXCEL_FORINT  text
*----------------------------------------------------------------------*
 FORM SZAM_ATIR USING    $FORINT.
   TRANSLATE $FORINT USING ', '.
   TRANSLATE $FORINT USING '. '.
   CONDENSE $FORINT NO-GAPS .
   SHIFT $FORINT RIGHT DELETING TRAILING SPACE.
   IF $FORINT+12(1) = '-'.
     $FORINT(1) = '-'.
     $FORINT+12(1) = ' '.
     CONDENSE $FORINT NO-GAPS .
   ENDIF.
 ENDFORM.                    " szam_atir
*&---------------------------------------------------------------------*
*&      Form  s_blart_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM S_BLART_INIT.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SE'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'KE'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SG'     TO S_BLART-LOW.
   APPEND S_BLART.
*++BG 2006/12/06
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'LB'     TO S_BLART-LOW.
   APPEND S_BLART.
*--BG 2006/12/06
*++FI 2007/03/08
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SS'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'M7'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'RM'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SI'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'U3'     TO S_BLART-LOW.
   APPEND S_BLART.
   MOVE:   'V3'     TO S_BLART-LOW.    APPEND S_BLART.
   MOVE:   'SN'     TO S_BLART-LOW.    APPEND S_BLART.
   MOVE:   'SU'     TO S_BLART-LOW.    APPEND S_BLART.
   MOVE:   'SV'     TO S_BLART-LOW.    APPEND S_BLART.
   MOVE:   'TE'     TO S_BLART-LOW.    APPEND S_BLART.
*--FI 2007/03/08
*++00013 2009.04.08
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SR'     TO S_BLART-LOW.
   APPEND S_BLART.
*--00013 2009.04.08

*++0018 2010.04.20
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SC'     TO S_BLART-LOW.
   APPEND S_BLART.
*--0018 2010.04.20

 ENDFORM.                    " s_blart_init
*&---------------------------------------------------------------------*
*&      Form  D900_EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
 FORM D900_EVENT_HOTSPOT_CLICK USING    E_ROW_ID TYPE LVC_S_ROW
                                        E_COLUMN_ID  TYPE LVC_S_COL.
   DATA: S_OUT   TYPE /ZAK/ANALITIKA,
         V_KOKRS TYPE KOKRS.

   READ TABLE I_/ZAK/ANALITIKA INTO S_OUT INDEX E_ROW_ID.
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

           CALL TRANSACTION 'KO03' AND SKIP FIRST SCREEN.
         ENDIF.
       WHEN 'HKONT'.
         IF NOT S_OUT-HKONT IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'SAK' FIELD S_OUT-HKONT.

           CALL TRANSACTION 'FS03' ."AND SKIP FIRST SCREEN.

         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " D900_EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  get_bsis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSEG  text
*      -->P_$BUKRS  text
*      -->P_$GJAHR  text
*      -->P_W_/ZAK/SZJA_CUST_AUFNR  text
*      -->P_W_/ZAK/SZJA_CUST_SAKNR  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
 FORM GET_BSIS TABLES    $I_BSIS STRUCTURE BSIS
*++0015 2009.05.22 BG
                         $I_KBELNR     STRUCTURE /ZAK/OUT_BELNR
*--0015 2009.05.22 BG
                USING    $BUKRS
                         $GJAHR
                         $MONAT
                         $/ZAK/EVES
                         $AUFNR
                         $HKONT
                CHANGING $SUBRC.
   DATA LW_BSIS TYPE  BSIS.
   RANGES: LR_AUFNR FOR BSEG-AUFNR.
   RANGES  R_MONAT FOR BKPF-MONAT.

   CLEAR LR_AUFNR.
   REFRESH LR_AUFNR.

*  It makes the order a condition for the selection
   IF NOT $AUFNR IS INITIAL.
     LR_AUFNR = 'IEQ'.
     LR_AUFNR-LOW = $AUFNR.
     APPEND  LR_AUFNR.
   ENDIF.
*  Determination of PERIOD
   CLEAR R_MONAT.
   REFRESH R_MONAT.
*++0012 2008.12.16 BG
** --Ez volt az eredeti
**  It makes the period a condition for selection
**  Either the period is not 12, or /ZAK/EVES <> ' '
**  If both conditions are FALSE, there is no need to monitor the period
*   IF $MONAT <> '12' OR $/ZAK/EVES IS INITIAL.
*--0012 2008.12.16 BG
   R_MONAT = 'IEQ'.
   R_MONAT-LOW = $MONAT.
   APPEND R_MONAT.
*++0012 2008.12.16 BG
*   ELSE.
*     R_MONAT = 'IBT'.
*     R_MONAT-LOW  = '01'.
*     R_MONAT-HIGH = '12'.
*     APPEND R_MONAT.
*   ENDIF.
*--0012 2008.12.16 BG

   SELECT * INTO TABLE $I_BSIS
            FROM BSIS
            WHERE BUKRS = $BUKRS
              AND HKONT = $HKONT
              AND GJAHR = $GJAHR
              AND BLART IN S_BLART
              AND MONAT IN R_MONAT
              AND AUFNR IN LR_AUFNR.
   $SUBRC = SY-SUBRC.
*++0015 2009.05.22 BG
   IF NOT $I_KBELNR[] IS INITIAL.
     LOOP AT $I_BSIS.
       READ TABLE $I_KBELNR TRANSPORTING NO FIELDS
                WITH KEY BUKRS = $I_BSIS-BUKRS
                         GJAHR = $I_BSIS-GJAHR
                         BELNR = $I_BSIS-BELNR.
       IF SY-SUBRC EQ 0.
         DELETE $I_BSIS.
       ENDIF.
     ENDLOOP.
   ENDIF.
*--0015 2009.05.22 BG

*++0015 2009.08.07 BG
*  If no record remains, it is an error
   IF $I_BSIS[] IS INITIAL.
     MOVE 4 TO $SUBRC.
   ENDIF.
*--0015 2009.08.07 BG
 ENDFORM.                    " get_bsis
*&---------------------------------------------------------------------*
*&      Form  tetel_WL_szures
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSIS  text
*      -->P_L_SUBRC  text
*----------------------------------------------------------------------*
 FORM TETEL_WL_SZURES TABLES   $BSIS STRUCTURE BSIS
                      USING    $SUBRC.
   DATA LW_BSIS TYPE  BSIS.

   LOOP AT  $BSIS INTO LW_BSIS.
     IF LW_BSIS-ZUONR(2) = 'WL'.
       DELETE $BSIS.
     ENDIF.

   ENDLOOP.


 ENDFORM.                    " tetel_WL_szures
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9001 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
   PERFORM SET_STATUS.
   IF V_CUSTOM_CONTAINER1 IS INITIAL.
     REFRESH I_FIELDCAT.
     PERFORM CREATE_AND_INIT_ALV1 CHANGING I_/ZAK/SZJA_EXCEL[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT.

   ENDIF.


 ENDMODULE.                 " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/SZJA_EXCEL[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV1 CHANGING $I_/ZAK/SZJA_EXCEL LIKE
                                                    I_/ZAK/SZJA_EXCEL[]
                                   $FIELDCAT TYPE LVC_T_FCAT
                                   $LAYOUT   TYPE LVC_S_LAYO
                                   $VARIANT  TYPE DISVARIANT.

   DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER
     EXPORTING
       CONTAINER_NAME = V_CONTAINER1.
   CREATE OBJECT V_GRID
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER.

* Compilation of a field catalog
   PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                          CHANGING $FIELDCAT.

* Exclusion of functions
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
       IT_OUTTAB            = $I_/ZAK/SZJA_EXCEL.

 ENDFORM.                    " CREATE_AND_INIT_ALV1
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9001 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'ANALITIKA'.
       CALL SCREEN 9000.
* Exit
*++0005 BG 2007.05.08
*    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
     WHEN 'BACK'.
*--0005 BG 2007.05.08
       PERFORM EXIT_PROGRAM.
*++0005 BG 2007.05.08
     WHEN 'EXIT' OR 'CANCEL'.
       LEAVE PROGRAM.
*--0005 BG 2007.05.08
     WHEN OTHERS.
*     do nothing
   ENDCASE.


 ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  FILENAME_OBLIGATORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_OUTF  text
*----------------------------------------------------------------------*
 FORM FILENAME_OBLIGATORY USING  $FILE.
   IF P_TESZT IS INITIAL.
     IF $FILE IS INITIAL.
       MESSAGE E146 .
     ENDIF.
   ENDIF.
 ENDFORM.                    " FILENAME_OBLIGATORY
*&---------------------------------------------------------------------*
*&      Form  GET_VERIFY_BTYPE_FROM_DATUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALL  text
*      -->P_$W_/ZAK/SZJA_CUST_BTYPE  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      -->P_$SUBRC  text
*----------------------------------------------------------------------*
 FORM GET_VERIFY_BTYPE_FROM_DATUM TABLES $I_/ZAK/BEVALL
                                             STRUCTURE /ZAK/BEVALL
                                  USING  $BTYPE
                                         $GJAHR
                                         $MONAT
                                         $SUBRC.

   DATA L_DATUM LIKE SY-DATUM.

*  You don't even need the record
   MOVE 4 TO $SUBRC.

*  Date determination
   PERFORM GET_LAST_DAY_OF_PERIOD
                             USING $GJAHR
                                   $MONAT
                          CHANGING L_DATUM.

*  We define the BTYPE.
   LOOP AT $I_/ZAK/BEVALL WHERE DATBI GE L_DATUM
                           AND DATAB LE L_DATUM.

   ENDLOOP.

   IF SY-SUBRC EQ 0 AND $I_/ZAK/BEVALL-BTYPE EQ $BTYPE.
     CLEAR $SUBRC.
   ENDIF.

 ENDFORM.                    " GET_VERIFY_BTYPE_FROM_DATUM
*&---------------------------------------------------------------------*
*&      Form  S_KBLART_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM S_KBLART_INIT .

   M_DEF: S_KBLART 'I' 'EQ' 'SA' SPACE,
          S_KBLART 'I' 'EQ' 'SP' SPACE,
*++BG 2007.09.10
*         S_KBLART 'I' 'EQ' 'E*' SPACE,
*         S_KBLART 'I' 'EQ' 'F*' SPACE.
          S_KBLART 'I' 'CP' 'E*' SPACE,
          S_KBLART 'I' 'CP' 'F*' SPACE.
*--BG 2007.09.10

 ENDFORM.                    " S_KBLART_INIT
*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_SEL_BUKRS  text
*----------------------------------------------------------------------*
 FORM ROTATE_BUKRS_OUTPUT  TABLES   $I_AD_BUKRS STRUCTURE I_AD_BUKRS
                           USING    $BUKRS
                                    $SEL_BUKRS.

   MOVE $BUKRS TO $SEL_BUKRS.
   CLEAR $BUKRS.

   CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
     EXPORTING
       I_AD_BUKRS    = $SEL_BUKRS
     IMPORTING
       E_FI_BUKRS    = $BUKRS
     EXCEPTIONS
       MISSING_INPUT = 1
       OTHERS        = 2.
   IF SY-SUBRC <> 0.
     MESSAGE E231 WITH P_BUKRS.
*   Error in defining & company rotation!...
   ENDIF.

*++0017 BG 2009.10.29
*  We define all possible values ​​that can be in XREF1
   SELECT AD_BUKRS INTO TABLE $I_AD_BUKRS
                   FROM /ZAK/BUKRSN
                  WHERE FI_BUKRS EQ $BUKRS.
*--0017 BG 2009.10.29


 ENDFORM.                    " ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BSEG  text
*      -->P_W_BKPF  text
*      <--P_L_BUKRS  text
*----------------------------------------------------------------------*
 FORM ROTATE_BUKRS_INPUT  TABLES   $I_AD_BUKRS STRUCTURE I_AD_BUKRS
                          USING    $BSEG STRUCTURE BSEG
                                   $BKPF STRUCTURE BKPF
                          CHANGING $BUKRS.

   DATA L_BUKRS TYPE BUKRS.

*++0017 BG 2009.10.29
*  MOVE $BSEG-XREF1+8(4) TO L_BUKRS.
   LOOP AT $I_AD_BUKRS.
     IF $BSEG-XREF1 CS $I_AD_BUKRS-AD_BUKRS.
       MOVE $I_AD_BUKRS-AD_BUKRS TO L_BUKRS.
     ENDIF.
   ENDLOOP.
*--0017 BG 2009.10.29

   CALL FUNCTION '/ZAK/ROTATE_BUKRS_INPUT'
     EXPORTING
       I_FI_BUKRS    = $BSEG-BUKRS
*++0007 2008.01.21 BG (FMC)
       I_AD_BUKRS    = L_BUKRS
*--0007 2008.01.21 BG (FMC)
       I_DATE        = $BKPF-BLDAT
*++0007 2008.01.21 BG (FMC)
*      I_GSBER       = $BSEG-GSBER
*      I_PRCTR       = $BSEG-PRCTR
*--0007 2008.01.21 BG (FMC)
     IMPORTING
       E_AD_BUKRS    = $BUKRS
     EXCEPTIONS
       MISSING_INPUT = 1
       OTHERS        = 2.
   IF SY-SUBRC <> 0.
     MESSAGE E232 WITH $BSEG-BUKRS.
*        Error in defining & company rotation!
   ENDIF.

 ENDFORM.                    " ROTATE_BUKRS_INPUT
*&---------------------------------------------------------------------*
*&      Form SOR_SETS_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SOR_SZETRAK_NEW.

   DATA L_GJAHR TYPE GJAHR.
   DATA L_MONAT TYPE MONAT.
   DATA L_BTYPE TYPE /ZAK/BTYPE.

   DATA: L_SZAMLA_BELNR(10).
   DATA L_SUBRC LIKE SY-SUBRC.


*++0011 2008.10.17 BG
   DATA L_LINES LIKE SY-TABIX.
*++1908 #10.
   DATA L_CUST_DATUM TYPE DATUM.
*--1908 #10.

   DEFINE LR_GET_SZAMLA_BELNR.
     IF NOT &1 IS INITIAL.
       IF &2 = &1.
         CLEAR &2.
       ENDIF.
     ENDIF.
   END-OF-DEFINITION.

   DESCRIBE TABLE I_BSEG LINES L_LINES.
*--0011 2008.10.17 BG

   LOOP AT I_BSEG INTO W_BSEG.
*++0011 2008.10.17 BG
*    Data processing
     PERFORM PROGRESS_INDICATOR USING TEXT-P03
                                      L_LINES
                                      SY-TABIX.
*--0011 2008.10.17 BG
*++1908 #10.
     CLEAR L_CUST_DATUM.
*--1908 #10.
*    The head searches for data
     READ TABLE I_BKPF INTO W_BKPF
                        WITH KEY BUKRS = W_BSEG-BUKRS
                                 BELNR = W_BSEG-BELNR
                                 GJAHR = W_BSEG-GJAHR.
*    Declaration type definition
     IF W_BKPF-BLART IN S_KBLART.
*      We determine the type of return that exists for the period
       CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
         EXPORTING
           I_BUKRS     = P_BUKRS
           I_BTYPART   = C_BTYPART_SZJA
           I_GJAHR     = W_BKPF-BLDAT(4)
           I_MONAT     = W_BKPF-BLDAT+4(2)
         IMPORTING
           E_BTYPE     = L_BTYPE
         EXCEPTIONS
           ERROR_MONAT = 1
           ERROR_BTYPE = 2
           OTHERS      = 3.
       IF SY-SUBRC NE 0.
         CONTINUE.
*++1908 #10.
       ELSE.
         L_CUST_DATUM = W_BKPF-BLDAT.
*--1908 #10.
       ENDIF.
     ELSE.
*      We determine the type of return that exists for the period
       CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
         EXPORTING
           I_BUKRS     = P_BUKRS
           I_BTYPART   = C_BTYPART_SZJA
           I_GJAHR     = P_GJAHR
           I_MONAT     = P_MONAT
         IMPORTING
           E_BTYPE     = L_BTYPE
         EXCEPTIONS
           ERROR_MONAT = 1
           ERROR_BTYPE = 2
           OTHERS      = 3.
       IF SY-SUBRC NE 0.
         CONTINUE.
*++1908 #10.
       ELSE.
         CONCATENATE P_GJAHR P_MONAT '01' INTO L_CUST_DATUM.
*--1908 #10.
       ENDIF.
     ENDIF.
*++1908 #10.
**    We define SZJA_CUST for the first order as well.
*     READ TABLE I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
*                            WITH KEY BTYPE = L_BTYPE
*                                     SAKNR = W_BSEG-HKONT
*                                     AUFNR = W_BSEG-AUFNR.
**    We will try without an order
*     IF SY-SUBRC NE 0.
*       READ TABLE I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
*                              WITH KEY BTYPE = L_BTYPE
*                                       SAKNR = W_BSEG-HKONT
*                                       AUFNR = ''.
*     ENDIF.
     CLEAR W_/ZAK/SZJA_CUST.
     LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                            WHERE BTYPE  =  L_BTYPE
                              AND SAKNR  =  W_BSEG-HKONT
                              AND AUFNR  =  W_BSEG-AUFNR
                              AND DATAB  LE L_CUST_DATUM
                              AND DATBI  GE L_CUST_DATUM.
       EXIT.
     ENDLOOP.
*    We will try without an order
     IF SY-SUBRC NE 0.
       LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                              WHERE BTYPE  =  L_BTYPE
                                AND SAKNR  =  W_BSEG-HKONT
                                AND DATAB  LE L_CUST_DATUM
                                AND DATBI  GE L_CUST_DATUM.
         EXIT.
       ENDLOOP.
     ENDIF.
*--1908 #10.
     CHECK SY-SUBRC EQ 0.

     CLEAR W_/ZAK/BEVALL.
     READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY
                                  BUKRS = W_/ZAK/SZJA_CUST-BUKRS
                                  BTYPE = W_/ZAK/SZJA_CUST-BTYPE.
     IF SY-SUBRC NE 0.
       MESSAGE E114.
*      Declaration type definition error!
     ENDIF.
*++2408 #01.
     CALL FUNCTION '/ZAK/SET_DATUM'
       EXPORTING
         I_DATUM  = W_BSEG-VALUT
         I_BIDOSZ = W_/ZAK/SZJA_CUST-BIDOSZ
       IMPORTING
         E_DATUM  = W_BSEG-VALUT.
*--2408 #01.
***********************************************************************
*    We have all the data and can use the old algorithm:
*    based on FORM SOR_SETRAK
***********************************************************************

*      If the ABEV identifier is not empty, then the line for analytics is required
     IF NOT W_/ZAK/SZJA_CUST-ABEVAZ IS INITIAL.
       IF NOT W_/ZAK/SZJA_CUST-/ZAK/EVES IS INITIAL
          AND P_MONAT < 12.
**          Candidates for ANNUAL are only needed if the month is 12
*           or greater
**          otherwise, they do not need to be given to the analytics table
*           but they still have to be posted
*           CONTINUE.
       ELSE.
*++0002 BG 2006/10/26
*          COMPLETES line 1 of the analytics.
         PERFORM ANALITIKA_KITOLT USING W_/ZAK/ANALITIKA
                                        W_/ZAK/SZJA_CUST
                                        W_BSEG
                                        W_BKPF
                                        W_/ZAK/BEVALL
*++0006 BG 2007.10.15
                                        V_SEL_BUKRS
                                        P_BUKRS
*--0006 BG 2007.10.15
                                        L_SUBRC.
         CHECK L_SUBRC EQ 0.
*--0002 BG 2006/10/26
**          ++ BG
*           PERFORM GET_ANALITIKA_ITEM TABLES I_/ZAK/ANALITIKA
*                                      USING W_/ZAK/ANALITIKA.
**          -- BG

*          Saves the analytics record.
         APPEND  W_/ZAK/ANALITIKA  TO I_/ZAK/ANALITIKA.
       ENDIF.
     ENDIF.
*      WL accounting
     IF NOT W_/ZAK/SZJA_CUST-/ZAK/WL IS INITIAL
        AND W_BKPF-BLART = 'WL'.
*          If the receipt is for the given month, it must be submitted only then
*          Items due to the annual sorting can also appear here
*          otherwise they are not needed
*++0014 2009.04.20 BG
**++2009.01.12 BG
**      We define the setting for the declaration type:
*       CLEAR W_/ZAK/SZJA_ABEV.
*       SELECT SINGLE * INTO W_/ZAK/SZJA_ABEV
*             FROM /ZAK/SZJA_ABEV
*             WHERE BUKRS     = P_BUKRS
*               AND BTYPE     = L_BTYPE
*               AND FIELDNAME = 'WL'.
**--2009.01.12 BG
       PERFORM GET_SZJA_ABEV USING W_/ZAK/SZJA_ABEV
                                   P_BUKRS
                                   L_BTYPE.
*--0014 2009.04.20 BG

       IF W_BKPF-MONAT = P_MONAT.
*++FI 20070213
*           PERFORM BOOK_WL USING W_BKPF
*                                 W_BSEG
*                                 W_/ZAK/SZJA_ABEV
*                                 W_/ZAK/BEVALL
*                                 W_/ZAK/SZJA_EXCEL.
**           writes the record
*           APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
         PERFORM BOOK_WL_V2 USING W_BKPF
                                  W_BSEG
                                  W_/ZAK/SZJA_ABEV
                                  W_/ZAK/BEVALL
                                  W_/ZAK/SZJA_EXCEL1
                                  W_/ZAK/SZJA_EXCEL2
                                  P_GJAHR
                                  P_MONAT.
*An identifier must unite the items, now it is an item number
*++0011 2008.10.17 BG
         LR_GET_SZAMLA_BELNR P_SPLIT L_SZAMLA_BELNR.
*--0011 2008.10.17 BG
         L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
         W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
         W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*           writes out the records
         APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
         APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.

*--FI 20070213
       ENDIF.
     ENDIF.
*    Transfer according to setting
     IF NOT W_/ZAK/SZJA_CUST-/ZAK/ATKONYV IS INITIAL.
*++FI 20070213
*         PERFORM BOOK_ATKONYV USING W_BKPF
*                               W_BSEG
*                               W_/ZAK/SZJA_ABEV
*                               W_/ZAK/BEVALL
*                               W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
*                               W_/ZAK/SZJA_EXCEL1.
**        writes the record
*         APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
**--2009.01.12 BG
       PERFORM GET_SZJA_ABEV USING W_/ZAK/SZJA_ABEV
                                   P_BUKRS
                                   L_BTYPE.
*--0014 2009.04.20 BG
       PERFORM BOOK_ATKONYV_V2 USING W_BKPF
                                     W_BSEG
                                     W_/ZAK/SZJA_ABEV
                                     W_/ZAK/BEVALL
                                     W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
                                     W_/ZAK/SZJA_EXCEL1
                                     W_/ZAK/SZJA_EXCEL2.
*An identifier must unite the items, now it is an item number
*++0011 2008.10.17 BG
       LR_GET_SZAMLA_BELNR P_SPLIT L_SZAMLA_BELNR.
*--0011 2008.10.17 BG
       L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
       W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
       W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*        writes the record
       APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
       APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
*--FI 20070213

     ENDIF.

   ENDLOOP.


 ENDFORM.                    " SOR_SETS_NEW

*++0011 2008.10.17 BG
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
 FORM PROGRESS_INDICATOR USING  $TEXT
                                $LINES
                                $ACT_LINE.
   DATA L_PERCENTAGE TYPE I.
   DATA L_DIVIDE TYPE P DECIMALS 2.

   CLEAR L_PERCENTAGE.

   IF NOT $LINES IS INITIAL AND NOT $ACT_LINE IS INITIAL.
     L_DIVIDE = $ACT_LINE / $LINES * 100.
     L_PERCENTAGE = TRUNC( L_DIVIDE ).
   ENDIF.

   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
       PERCENTAGE = L_PERCENTAGE
       TEXT       = $TEXT.


 ENDFORM.                    " PROGRESS_INDICATOR
*--0011 2008.10.17 BG
*&---------------------------------------------------------------------*
*&      Form  ROTATION_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM ROTATION_DATA TABLES $I_/ZAK/SZJA_EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                    USING  $BUKRS.

*   DATA LI_CNV_AUFNR LIKE ZRP_CNV_AUFNR OCCURS 0 WITH HEADER LINE.
*   DATA LI_Z2CJOGUTOD LIKE Z2CJOGUTOD OCCURS 0 WITH HEADER LINE.
*   DATA LI_CNV_PC LIKE ZRP_PS001_CNV_PC OCCURS 0 WITH HEADER LINE.
*   DATA L_BUDAT LIKE SY-DATUM.
*   DATA L_KOKRS TYPE KOKRS.
*   RANGES LR_AUFNR FOR /ZAK/SZJAEXCELV2-RENDELES.
*   RANGES LR_KOSTL FOR /ZAK/SZJAEXCELV2-KTGH.
*   RANGES LR_PRCTR FOR /ZAK/SZJAEXCELV2-PRCTR.
*
*
*
**  Definition of a cost calculation circle
*   CALL FUNCTION 'BAPI_CONTROLLINGAREA_FIND'
*     EXPORTING
*       COMPANYCODEID           = $BUKRS
*     IMPORTING
*       CONTROLLINGAREAID       = L_KOKRS
**      RETURN                  =
*             .
*
*
*
**  Shootings
*   LOOP AT $I_/ZAK/SZJA_EXCEL INTO W_/ZAK/SZJA_EXCEL1.
*
*     CALL FUNCTION 'CONVERSION_EXIT_PCDAT_OUTPUT'
*       EXPORTING
*         INPUT  = W_/ZAK/SZJA_EXCEL1-KONYV_DAT
*       IMPORTING
*         OUTPUT = L_BUDAT.
*
**    1. Order
*     IF NOT W_/ZAK/SZJA_EXCEL1-RENDELES IS INITIAL AND
*        ( LR_AUFNR[] IS INITIAL OR
*          NOT W_/ZAK/SZJA_EXCEL1-RENDELES IN LR_AUFNR ).
*       READ TABLE LI_CNV_AUFNR WITH KEY
*                  AUFNR = W_/ZAK/SZJA_EXCEL1-RENDELES
*                  BINARY SEARCH.
*       IF SY-SUBRC EQ 0.
**        There is a new order
*         IF NOT LI_CNV_AUFNR-AUFNR_NEW IS INITIAL.
*           MOVE LI_CNV_AUFNR-AUFNR_NEW TO W_/ZAK/SZJA_EXCEL1-RENDELES.
**        There is a new place of payment
*         ELSEIF NOT LI_CNV_AUFNR-KOSTL_NEW IS INITIAL.
*           MOVE LI_CNV_AUFNR-KOSTL_NEW TO W_/ZAK/SZJA_EXCEL1-KTGH.
*         ENDIF.
*       ELSE.
**        Turntable reading
*         SELECT SINGLE * INTO LI_CNV_AUFNR
*                         FROM ZRP_CNV_AUFNR
*                        WHERE DATBI GE L_BUDAT
*                          AND AUFNR EQ W_/ZAK/SZJA_EXCEL1-RENDELES
*                          AND DATAB LE L_BUDAT.
*         IF SY-SUBRC EQ 0.
**          There is a new order
*           IF NOT LI_CNV_AUFNR-AUFNR_NEW IS INITIAL.
*             MOVE LI_CNV_AUFNR-AUFNR_NEW TO W_/ZAK/SZJA_EXCEL1-RENDELES.
**          There is a new place of payment
*           ELSEIF NOT LI_CNV_AUFNR-KOSTL_NEW IS INITIAL.
*             MOVE LI_CNV_AUFNR-KOSTL_NEW TO W_/ZAK/SZJA_EXCEL1-KTGH.
*           ENDIF.
*           APPEND LI_CNV_AUFNR SORTED BY AUFNR.
**        We gather that we have already dealt with it
*         ELSE.
*           M_DEF LR_AUFNR 'I' 'EQ' W_/ZAK/SZJA_EXCEL1-RENDELES SPACE.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*
**  2. Cost center
*     IF NOT W_/ZAK/SZJA_EXCEL1-KTGH IS INITIAL AND
*       ( LR_KOSTL[] IS INITIAL OR
*         NOT W_/ZAK/SZJA_EXCEL1-KTGH IN LR_KOSTL ).
**++2009.01.12 BG
**      Loading leading 0s
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-KTGH
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-KTGH.
**--2009.01.12 BG
*       READ TABLE LI_Z2CJOGUTOD WITH KEY
*                   KOKRS  = L_KOKRS
*                   MKOSTL = W_/ZAK/SZJA_EXCEL1-KTGH
*                   BINARY SEARCH.
**       There is a new place of payment
*       IF SY-SUBRC EQ 0.
*         MOVE LI_Z2CJOGUTOD-JKOSTL TO W_/ZAK/SZJA_EXCEL1-KTGH.
*       ELSE.
*         SELECT SINGLE * INTO LI_Z2CJOGUTOD
*                         FROM Z2CJOGUTOD
*                        WHERE KOKRS  EQ L_KOKRS
*                          AND MKOSTL EQ W_/ZAK/SZJA_EXCEL1-KTGH.
*         IF SY-SUBRC EQ 0.
*           MOVE LI_Z2CJOGUTOD-JKOSTL TO W_/ZAK/SZJA_EXCEL1-KTGH.
*           APPEND LI_Z2CJOGUTOD SORTED BY MKOSTL.
*         ELSE.
*           M_DEF LR_KOSTL 'I' 'EQ' W_/ZAK/SZJA_EXCEL1-KTGH SPACE.
*         ENDIF.
*       ENDIF.
**++2009.01.12 BG
**      Remove leading 0s
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-KTGH
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-KTGH.
**--2009.01.12 BG
*     ENDIF.
*
**  3. profitcenter
*     IF W_/ZAK/SZJA_EXCEL1-RENDELES IS INITIAL AND
*        W_/ZAK/SZJA_EXCEL1-KTGH IS INITIAL AND
*        NOT W_/ZAK/SZJA_EXCEL1-PRCTR IS INITIAL AND
*        ( LR_PRCTR[] IS INITIAL OR
*        NOT W_/ZAK/SZJA_EXCEL1-PRCTR IN LR_PRCTR ).
*
**++2009.01.12 BG
**      Loading leading 0s
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-PRCTR
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-PRCTR.
**--2009.01.12 BG
*
*       READ TABLE LI_CNV_PC WITH KEY
*                  PRCTR = W_/ZAK/SZJA_EXCEL1-PRCTR.
**       I have a new PC
*       IF SY-SUBRC EQ 0.
*         MOVE LI_CNV_PC-PRCTR_NEW TO W_/ZAK/SZJA_EXCEL1-PRCTR.
*       ELSE.
*         SELECT SINGLE * INTO LI_CNV_PC
*                         FROM ZRP_PS001_CNV_PC
*                        WHERE DATBI GE L_BUDAT
*                          AND KOKRS EQ L_KOKRS
*                          AND PRCTR EQ W_/ZAK/SZJA_EXCEL1-PRCTR.
*         IF SY-SUBRC EQ 0.
*           MOVE LI_CNV_PC-PRCTR_NEW TO W_/ZAK/SZJA_EXCEL1-PRCTR.
*           APPEND LI_CNV_PC SORTED BY PRCTR.
*         ELSE.
*           M_DEF LR_PRCTR 'I' 'EQ' W_/ZAK/SZJA_EXCEL1-PRCTR SPACE.
*         ENDIF.
*       ENDIF.
**++2009.01.12 BG
**      Remove leading 0s
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-PRCTR
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-PRCTR.
**--2009.01.12 BG
*
*     ENDIF.
*
*     MODIFY $I_/ZAK/SZJA_EXCEL FROM W_/ZAK/SZJA_EXCEL1
*            TRANSPORTING RENDELES KTGH PRCTR.
*
*
*   ENDLOOP.
*
*   FREE: LI_CNV_AUFNR, LI_Z2CJOGUTOD, LI_CNV_PC.

 ENDFORM.                    " ROTATION_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SZJA_ABEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_P_BUKRS  text
*      -->P_L_BTYPE  text
*----------------------------------------------------------------------*
 FORM GET_SZJA_ABEV  USING    $W_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                              $BUKRS
                              $BTYPE.
   CLEAR $W_/ZAK/SZJA_ABEV.
   CLEAR W_/ZAK/SZJA_ABEV.
   SELECT SINGLE * INTO $W_/ZAK/SZJA_ABEV
         FROM /ZAK/SZJA_ABEV
         WHERE BUKRS     = $BUKRS
           AND BTYPE     = $BTYPE
           AND FIELDNAME = 'WL'.
*  If no VAT code is set, then error:
   IF $W_/ZAK/SZJA_ABEV-MWSKZ IS INITIAL.
     MESSAGE E284 WITH $BUKRS $BTYPE.
*No VAT code is set for field WL in /ZAK/SZJA_ABEV
* (Company: &, typ.: &)
   ENDIF.

 ENDFORM.                    " GET_SZJA_ABEV
