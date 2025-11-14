*&---------------------------------------------------------------------*
*& Report  /ZAK/UREP_SAP_SEL
*&
*&---------------------------------------------------------------------*
*& Function description: The program selects data from SAP documents based on the selection criteria
*& filters the SAP documents for the data and determines
*& the dataset to be processed in /ZAK/ZAKO
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date : 2008.11.17
*& Functional spec author: Róth Nándor
*& SAP modul neve    : ADO
*& Program type     : Report
*& SAP version       : 50
*&---------------------------------------------------------------------*

REPORT  /ZAK/UREP_SAP_SEL MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& CHANGES (The OSS note number must be written to the end of modified lines)*
*&
*& LOG#     DATE        MODIFIER                      DESCRIPTION
*& ----   ----------   ----------    -----------------------------------
*& 0001   2009.01.12   Balázs Gábor  WL posting fix: general ledger, period
*& 0002   2009.04.20   Balázs Gábor  WL VAT code from /ZAK/SZJA_ABEV
*& 0003   2009.05.22   Balázs Gábor  Handling excluded documents
*& 0004   2009.10.29   Balázs Gábor  Company rotation handling
*& 0005   2010.01.08   Balázs Gábor  PST element filling
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/SAP_SEL_F01.



*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
TABLES : BSEG,              "Document segment: accounting
         BKPF,              "Document header for accounting
         BSIS, "Accounting: secondary index for G/L accounts
         /ZAK/SZJA_CUST,     "SZJA deduction, posting configuration
         /ZAK/SZJA_ABEV,     "SZJA deduction, ABEV field-name-based mapping
         /ZAK/START,         "Tax: define start date per company
         /ZAK/UREPI_LOG.     "Business gift, representation LOG


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS C_UREPF_U TYPE /ZAK/UREPF VALUE 'U'. "Business
CONSTANTS C_UREPF_R TYPE /ZAK/UREPF VALUE 'R'. "Repi
CONSTANTS C_REPI_MONAT TYPE MONAT VALUE '05'.


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
*& PROGRAM VARIABLES                                                    *
*      Internal table        -   (I_xxx...)                              *
*      FORM parameter       -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Parameter variable   -   (P_xxx...)                              *
*      Selection option     -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Global variables     -   (V_xxx...)                              *
*      Local variables      -   (L_xxx...)                              *
*      Work area            -   (W_xxx...)                              *
*      Type                 -   (T_xxx...)                              *
*      Macros               -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class                -   (CL_xxx...)                             *
*      Event                -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*Macro definition for filling ranges
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

DATA V_SUBRC LIKE SY-SUBRC.
DATA V_REPID LIKE SY-REPID.

RANGES R_BTYPE FOR /ZAK/BEVALL-BTYPE.

DATA V_SEL_BUKRS TYPE BUKRS.

DATA V_LAST_DAY TYPE DATUM.

DATA /ZAK/UREPI_LOG_SAVE TYPE /ZAK/UREPI_LOG.

*PERIODS for selection
TYPES: BEGIN OF T_IDSZ,
         GJAHR TYPE GJAHR,
         MONAT TYPE MONAT,
         GJMON TYPE RSCALMONTH,
       END OF T_IDSZ.
*PERIODS
DATA I_IDSZ TYPE STANDARD TABLE OF T_IDSZ INITIAL SIZE 0.
DATA W_IDSZ TYPE T_IDSZ.
*Feldolgozattlan rekordok
DATA I_UREPI_FELD TYPE STANDARD TABLE OF /ZAK/UREPI_FELD INITIAL SIZE 0.
DATA W_UREPI_FELD TYPE /ZAK/UREPI_FELD.
*Configuration data
DATA W_/ZAK/SZJA_CUST TYPE  /ZAK/SZJA_CUST.
DATA I_/ZAK/SZJA_CUST TYPE STANDARD TABLE OF /ZAK/SZJA_CUST
                                            INITIAL SIZE 0.
DATA I_UREPI_DATA TYPE STANDARD TABLE OF /ZAK/UREPIDATA
                                            INITIAL SIZE 0.
DATA W_UREPI_DATA TYPE /ZAK/UREPIDATA.

*BSEG
DATA W_BSEG TYPE  BSEG.
DATA I_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
*BKPF
DATA W_BKPF TYPE  BKPF.
DATA I_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.

DATA : V_U_ARANY TYPE P DECIMALS 4,
       V_R_ARANY TYPE P DECIMALS 4.

*Ratios are needed per declaration type
DATA: BEGIN OF I_BTYPE_ARANY OCCURS 0,
        GJAHR   TYPE GJAHR,
        U_ALAP  TYPE DMBTR,
        R_ALAP  TYPE DMBTR,
        U_ARANY LIKE V_U_ARANY,
        R_ARANY LIKE V_R_ARANY,
*      U_FLAG   TYPE XFELD,
*      R_FLAG   TYPE XFELD,
      END OF I_BTYPE_ARANY.
*
DATA W_/ZAK/SZJA_EXCEL1 TYPE  /ZAK/SZJAEXCELV2. " Accounting line 1
DATA W_/ZAK/SZJA_EXCEL2 TYPE  /ZAK/SZJAEXCELV2. " Accounting line 2
DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJAEXCELV2
                                                       INITIAL SIZE 0.

*ABEV determination
DATA W_/ZAK/SZJA_ABEV TYPE  /ZAK/SZJA_ABEV.
DATA I_/ZAK/SZJA_ABEV TYPE STANDARD TABLE OF /ZAK/SZJA_ABEV
                                                       INITIAL SIZE 0.

* ALV handling variables
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

*++0004 BG 2009.10.29
TYPES: BEGIN OF T_AD_BUKRS,
         AD_BUKRS TYPE /ZAK/AD_BUKRS,
       END OF T_AD_BUKRS.

DATA I_AD_BUKRS TYPE T_AD_BUKRS OCCURS 0 WITH HEADER LINE.
*--0004 BG 2009.10.29


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Company.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-101.
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS
                          VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

SELECTION-SCREEN END OF LINE.
PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT
                          NO-DISPLAY.
* Determine type of declaration
PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                          DEFAULT C_BTYPART_SZJA
                          OBLIGATORY.
* Year
PARAMETERS: P_GJAHR LIKE BKPF-GJAHR DEFAULT SY-DATUM(4)
                                    OBLIGATORY.
* Month
PARAMETERS: P_MONAT LIKE BKPF-MONAT DEFAULT SY-DATUM+4(2)
                                    OBLIGATORY.
* Data service identifier
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-103.
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM  OBLIGATORY.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BSZTXT  LIKE /ZAK/BEVALLDT-SZTEXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.
* Bizonylat fajta
SELECT-OPTIONS: S_BLART FOR BKPF-BLART NO INTERVALS.
*++0003 2009.05.22 BG
* Excluded documents
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-104.
PARAMETERS P_KBELNR AS CHECKBOX MODIF ID DIS.
SELECTION-SCREEN PUSHBUTTON 52(4) KBL USER-COMMAND KBL.
SELECTION-SCREEN END OF LINE.
*--0003 2009.05.22 BG
*SELECT-OPTIONS: S_KBLART FOR BKPF-BLART NO INTERVALS.

* Test run
PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X' .

SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN BEGIN OF BLOCK B105 WITH FRAME TITLE TEXT-T05.
SELECT-OPTIONS S_SAKNR FOR /ZAK/SZJA_CUST-SAKNR.
SELECTION-SCREEN: END OF BLOCK B105.

*Select upload mode
SELECTION-SCREEN BEGIN OF BLOCK B102 WITH FRAME TITLE TEXT-T02.
PARAMETERS: P_NORM  RADIOBUTTON GROUP R01 USER-COMMAND NORM
                                                  DEFAULT 'X',
            P_ISMET RADIOBUTTON GROUP R01,
            P_PACK  LIKE /ZAK/BEVALLP-PACK
                      MATCHCODE OBJECT /ZAK/PACK.

SELECTION-SCREEN END OF BLOCK B102.

*Accounting Excel file
SELECTION-SCREEN BEGIN OF BLOCK B104 WITH FRAME TITLE TEXT-T04.
PARAMETERS: P_OUTF LIKE FC03TAB-PL00_FILE."  OBLIGATORY.
PARAMETERS: P_SPLIT TYPE I NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK B104.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Determine descriptions
  PERFORM READ_ADDITIONALS.

  PERFORM S_BLART_INIT.

* PERFORM S_KBLART_INIT.
*++0003 2009.05.22 BG
  WRITE ICON_DISPLAY_MORE TO KBL AS ICON.
*--0003 2009.05.22 BG
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
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
*++0003 2009.05.22 BG
AT SELECTION-SCREEN.

  CASE SY-UCOMM.
    WHEN 'KBL'.
      CALL TRANSACTION '/ZAK/OUT_BELNR_V'.
  ENDCASE.

*--0003 2009.05.22 BG

AT SELECTION-SCREEN OUTPUT.
*++0003 2009.05.22 BG
* Determine whether there are excluded document numbers
  PERFORM GET_KBELNR TABLES I_KBELNR
                     USING  P_BUKRS
                            P_KBELNR.
*--0003 2009.05.22 BG

*  Set screen attributes
  PERFORM SET_SCREEN_ATTRIBUTES.

AT SELECTION-SCREEN ON P_BTYPAR.
*  Check SZJA declaration type
  PERFORM VER_BTYPEART USING P_BUKRS
                             P_BTYPAR
                             C_BTYPART_SZJA
                    CHANGING V_SUBRC.

  IF NOT V_SUBRC IS INITIAL.
    MESSAGE E019.
*   Please provide an SZJA-type declaration identifier!
*  Determine the declaration type
  ELSE.
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

AT SELECTION-SCREEN ON P_BSZNUM.
  MOVE SY-REPID TO V_REPID.
*  Validate service identifier
  PERFORM VER_BSZNUM   USING P_BUKRS
                             P_BTYPAR
                             P_BSZNUM
                             V_REPID
                    CHANGING V_SUBRC.

AT SELECTION-SCREEN ON P_MONAT.
*  Period validation
  PERFORM VER_PERIOD   USING P_MONAT.

AT SELECTION-SCREEN ON BLOCK B102.
*  Check block
  PERFORM VER_BLOCK_B102 USING P_NORM
                               P_ISMET
                               P_PACK.

AT SELECTION-SCREEN ON P_OUTF.
* File name is required for live run
  IF P_TESZT IS INITIAL AND P_OUTF IS INITIAL.
    MESSAGE E146.
*   Please provide the accounting file name!
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_OUTF.
  PERFORM FILENAME_GET USING P_OUTF.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*++ 2010.06.10 RN
* az AT SELECTION SCREEN mellett ide is be kellett rakni, mert ott csak
* akkor fut le, ha Entert is nyomnak a selection screen-en
* Determine whether there are excluded document numbers
  PERFORM GET_KBELNR TABLES I_KBELNR
                     USING  P_BUKRS
                            P_KBELNR.
*-- 2010.06.10 RN

*++0004 BG 2009.10.29
**  Company rotation
*  PERFORM ROTATE_BUKRS_OUTPUT USING P_BUKRS
*                                    V_SEL_BUKRS.
*  Company rotation
  PERFORM ROTATE_BUKRS_OUTPUT(/ZAK/SZJA_SAP_SEL)
                              TABLES I_AD_BUKRS
                              USING  P_BUKRS
                                     V_SEL_BUKRS.
*--0004 BG 2009.10.29


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

* Authorization check
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                P_BTYPAR
                                C_ACTVT_01.

* If BTYPE is empty, determine it
  IF R_BTYPE[] IS INITIAL.
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

* Read company data
  PERFORM GET_T001 USING P_BUKRS
                         V_SUBRC.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE A036 WITH P_BUKRS.
*   Error while retrieving the company data for &! (table T001)
  ENDIF.

* Determine start date
  PERFORM GET_START USING P_BUKRS
                          V_SUBRC.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE A281 WITH P_BUKRS.
*   Missing setting for determining the start date of company &!
  ENDIF.

* Read the log from the last run
  PERFORM GET_LAST_LOG USING P_BUKRS.

* Determine configuration data
  PERFORM GET_UREPI_DATA TABLES I_UREPI_DATA
                         USING  P_BUKRS.


* Determine the last day of the selection month
  PERFORM GET_LAST_DAY USING P_GJAHR
                             P_MONAT
                             V_LAST_DAY.

* Determine periods for selection
  PERFORM GET_IDSZ TABLES I_IDSZ
                   USING  /ZAK/START
                          /ZAK/UREPI_LOG
                          V_LAST_DAY.
* Error if no period exists
  IF I_IDSZ[] IS INITIAL.
    MESSAGE E282.
*   Processing period cannot be determined!
  ENDIF.

* Data selection
  PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                   0
                                   0.

* Determine settings
  PERFORM VALOGAT_BEALLITAS TABLES I_/ZAK/SZJA_CUST
                                   R_BTYPE
                                   S_SAKNR
                             USING P_BUKRS
                                   P_BSZNUM
                                   V_SUBRC.
  IF V_SUBRC <> 0.
*    Error while determining the SZJA settings!
    MESSAGE E089 WITH '/ZAK/SZJA_CUST_V'.
  ENDIF.

* Filter unprocessed records
  PERFORM GET_UREPI_FELD TABLES I_UREPI_FELD
*++0003 2009.05.22 BG
                                I_KBELNR
*--0003 2009.05.22 BG
                          USING P_BUKRS.

* Filter accounting data
  PERFORM GET_BOOK_DATA TABLES I_/ZAK/SZJA_CUST
                               I_BKPF
                               I_BSEG
                               I_UREPI_FELD
                               I_IDSZ
                               S_BLART
                               I_UREPI_DATA
*++0003 2009.05.22 BG
                               I_KBELNR
*--0003 2009.05.22 BG
                        USING  /ZAK/UREPI_LOG
                               /ZAK/UREPI_LOG_SAVE
                               P_BUKRS
                               P_TESZT
*++0004 BG 2009.10.29
                               V_SEL_BUKRS.
*--0004 BG 2009.10.29

  IF I_BKPF[] IS INITIAL.
*    No data matches the selection.
    MESSAGE I031.
    EXIT.
  ENDIF.

* Determine ratio
  PERFORM PROGRESS_INDICATOR USING TEXT-P03
                                   0
                                   0.

  PERFORM EVES_ADATOK_SUM TABLES   I_/ZAK/SZJA_CUST
                                   I_BSEG
                                   I_BKPF
                                   R_BTYPE
                                   I_BTYPE_ARANY
                                   I_UREPI_DATA
                           USING   P_BUKRS.


  PERFORM SOR_SZETRAK_NEW TABLES I_BSEG
                                 I_BKPF
                                 I_/ZAK/SZJA_CUST
                                 I_/ZAK/BEVALL
                                 I_/ZAK/ANALITIKA
                                 I_/ZAK/SZJA_EXCEL
                                 I_BTYPE_ARANY
                          USING  P_BUKRS
                                 V_SEL_BUKRS
                                 P_GJAHR
                                 P_MONAT
                                 P_BSZNUM.

  PERFORM GEN_ANALITIKA TABLES R_BTYPE
                               I_/ZAK/ANALITIKA
                        USING  P_BUKRS
                               P_BSZNUM.

* Rotate accounting file (cost center)
  PERFORM ROTATION_DATA(/ZAK/SZJA_SAP_SEL)
                        TABLES I_/ZAK/SZJA_EXCEL
                        USING  P_BUKRS.

* Live run, database update, etc.
  PERFORM INS_DATA  TABLES I_/ZAK/ANALITIKA
                           I_UREPI_FELD
                           I_UREPI_DATA
                    USING  /ZAK/UREPI_LOG_SAVE
                           P_TESZT
                           V_SEL_BUKRS
                           P_BTYPAR
                           P_BSZNUM
                           P_PACK.
*  Download accounting file
  IF P_TESZT IS INITIAL.
    PERFORM DOWNLOAD_FILE_V2(/ZAK/SZJA_SAP_SEL)
                TABLES
                   I_/ZAK/SZJA_EXCEL
                USING
                   P_OUTF
                CHANGING
                   V_SUBRC.
  ENDIF.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*

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
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'LB'     TO S_BLART-LOW.
  APPEND S_BLART.
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


ENDFORM.                    " s_blart_init

*&---------------------------------------------------------------------*
*&      Form  S_KBLART_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM S_KBLART_INIT .

*  M_DEF: S_KBLART 'I' 'EQ' 'SA' SPACE,
*         S_KBLART 'I' 'EQ' 'SP' SPACE,
*         S_KBLART 'I' 'CP' 'E*' SPACE,
*         S_KBLART 'I' 'CP' 'F*' SPACE.

ENDFORM.                    " S_KBLART_INIT
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
*   Please provide a period value between 01 and 16!
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
*   Please provide the upload identifier!
  ENDIF.
ENDFORM.                    "VER_BLOCK_B102

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

  DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*  CALL FUNCTION 'WS_FILENAME_GET'
*    EXPORTING
*      DEF_FILENAME     = '*.XLS'
**     DEF_PATH         = 'C:\temp'
*      MASK             = L_MASK
*      MODE             = 'S'
*      TITLE            = 'Accounting file'
*    IMPORTING
*      FILENAME         = $FILE
**     RC               = DUMMY
*    EXCEPTIONS
*      INV_WINSYS       = 04
*      NO_BATCH         = 08
*      SELECTION_CANCEL = 12
*      SELECTION_ERROR  = 16.

  DATA L_EXTENSION TYPE STRING.
  DATA L_TITLE     TYPE STRING.
  DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.

  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      WINDOW_TITLE = 'Könyvelési fájl'
*     DEFAULT_EXTENSION =
*     EFAULT_FILE_NAME  =
*     WITH_ENCODING     =
      FILE_FILTER  = '*.XLS'
*     INITIAL_DIRECTORY =
*     DEFAULT_ENCODING  =
    IMPORTING
*     FILENAME     =
*     PATH         =
      FULLPATH     = L_FULLPATH
*     USER_ACTION  =
*     FILE_ENCODING     =
    .
  $FILE = L_FULLPATH.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

  CHECK SY-SUBRC EQ 0.

ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_SEL_BUKRS  text
*----------------------------------------------------------------------*
FORM ROTATE_BUKRS_OUTPUT  USING    $BUKRS
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
*   Error while determining the company rotation for &!...
  ENDIF.

ENDFORM.                    " ROTATE_BUKRS_OUTPUT

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
    L_DIVIDE = $ACT_LINE / $LINES  * 100.
    L_PERCENTAGE = TRUNC( L_DIVIDE ).
  ENDIF.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = L_PERCENTAGE
      TEXT       = $TEXT.


ENDFORM.                    " PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  GET_START
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_START  USING    $BUKRS
                         $SUBRC.

  CLEAR $SUBRC.
  SELECT SINGLE * FROM /ZAK/START
                 WHERE BUKRS EQ $BUKRS.
  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
  ENDIF.

ENDFORM.                    " GET_START
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
FORM GET_LAST_LOG  USING   $BUKRS.


  CLEAR /ZAK/UREPI_LOG.

  SELECT SINGLE * FROM /ZAK/UREPI_LOG
                 WHERE BUKRS EQ $BUKRS.


ENDFORM.                    " GET_LAST_LOG
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_DAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      -->P_V_LAST_DAY  text
*----------------------------------------------------------------------*
FORM GET_LAST_DAY  USING    $GJAHR
                            $MONAT
                            $LAST_DAY.


  CLEAR $LAST_DAY.

  CONCATENATE $GJAHR $MONAT '01' INTO $LAST_DAY.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = $LAST_DAY
    IMPORTING
      LAST_DAY_OF_MONTH = $LAST_DAY
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_LAST_DAY
*&---------------------------------------------------------------------*
*&      Form  GET_IDSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_IDSZ  text
*      -->P_/ZAK/START  text
*      -->P_/ZAK/UREPI_LOG  text
*      -->P_V_LAST_DAY  text
*----------------------------------------------------------------------*
FORM GET_IDSZ  TABLES   $I_IDSZ          LIKE   I_IDSZ
               USING    $/ZAK/START       STRUCTURE  /ZAK/START
                        $/ZAK/UREPI_LOG   STRUCTURE  /ZAK/UREPI_LOG
                        $LAST_DAY.

  DATA L_DATUM TYPE DATUM.

  REFRESH $I_IDSZ.

* No period – exit
  IF $/ZAK/START-ZURDAT IS INITIAL AND $/ZAK/UREPI_LOG-CPUDT IS INITIAL.
    EXIT.
  ENDIF.

* Go from the later date back to the one provided in the selection.
  IF $/ZAK/START-ZURDAT >  $/ZAK/UREPI_LOG-CPUDT.
    L_DATUM = $/ZAK/START-ZURDAT.
  ELSE.
    CONCATENATE $/ZAK/UREPI_LOG-GJAHR $/ZAK/UREPI_LOG-MONAT '01' INTO L_DATUM.
  ENDIF.
* Exit if the initial period is greater
  IF L_DATUM > $LAST_DAY.
    EXIT.
  ENDIF.

* Initial period
  CLEAR W_IDSZ.
  W_IDSZ-GJAHR = L_DATUM(4).
  W_IDSZ-MONAT = L_DATUM+4(2).
  CONCATENATE W_IDSZ-GJAHR W_IDSZ-MONAT INTO W_IDSZ-GJMON.
  APPEND W_IDSZ TO $I_IDSZ.

* Populate period
  DO.
    ADD 1 TO W_IDSZ-MONAT.
    IF W_IDSZ-MONAT > 16.
      ADD 1 TO  W_IDSZ-GJAHR.
      W_IDSZ-MONAT = '01'.
    ENDIF.
    CONCATENATE W_IDSZ-GJAHR W_IDSZ-MONAT INTO W_IDSZ-GJMON.
    IF W_IDSZ-GJMON > $LAST_DAY(6).
      EXIT.
    ENDIF.
    APPEND W_IDSZ TO $I_IDSZ.
  ENDDO.


ENDFORM.                    " GET_IDSZ

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
                              $SAKNR STRUCTURE S_SAKNR
                       USING    $BUKRS
                                $BSZNUM
                       CHANGING $SUBRC.

  SELECT * INTO TABLE $/ZAK/SZJA_CUST
           FROM /ZAK/SZJA_CUST
           WHERE BUKRS   = $BUKRS
             AND BTYPE  IN $BTYPE
             AND BSZNUM  = $BSZNUM
             AND SAKNR  IN $SAKNR
             AND /ZAK/EVES NE ''.

  $SUBRC = SY-SUBRC.
ENDFORM.                    " valogat_beallitas
*&---------------------------------------------------------------------*
*&      Form  GET_UREPI_FELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_UREPI_FELD  text
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
FORM GET_UREPI_FELD  TABLES   $I_UREPI_FELD STRUCTURE /ZAK/UREPI_FELD
*++0003 2009.05.22 BG
                              $I_KBELNR     STRUCTURE /ZAK/OUT_BELNR
*--0003 2009.05.22 BG
                     USING    $BUKRS.

*++0003 2009.05.22 BG
  DATA LW_UREPI_FELD TYPE /ZAK/UREPI_FELD.
*--0003 2009.05.22 BG


  SELECT * INTO TABLE  $I_UREPI_FELD
           FROM /ZAK/UREPI_FELD
          WHERE BUKRS EQ $BUKRS.


*++0003 2009.05.22 BG
  IF NOT $I_KBELNR[] IS INITIAL.
    LOOP AT $I_UREPI_FELD INTO LW_UREPI_FELD.
      READ TABLE $I_KBELNR TRANSPORTING NO FIELDS
               WITH KEY BUKRS = LW_UREPI_FELD-BUKRS
                        GJAHR = LW_UREPI_FELD-GJAHR
                        BELNR = LW_UREPI_FELD-BELNR.
      IF SY-SUBRC EQ 0.
        DELETE $I_UREPI_FELD.
      ENDIF.
    ENDLOOP.
  ENDIF.
*--0003 2009.05.22 BG

ENDFORM.                    " GET_UREPI_FELD
*&---------------------------------------------------------------------*
*&      Form  GET_BOOK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BSIS  text
*      -->P_I_BKPF  text
*      -->P_I_BSEG  text
*      -->P_I_UREPI_FELD  text
*      -->P_I_IDSZ  text
*      -->P_/ZAK/UREPI_LOG  text
*      -->P_P_BUKRS  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_BOOK_DATA  TABLES   $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                             $I_BKPF STRUCTURE BKPF
                             $I_BSEG STRUCTURE BSEG
                             $I_UREPI_FELD STRUCTURE /ZAK/UREPI_FELD
                             $I_IDSZ LIKE I_IDSZ
                             $S_BLART STRUCTURE S_BLART
                             $I_UREPI_DATA STRUCTURE /ZAK/UREPIDATA
*++0003 2009.05.22 BG
                             $I_KBELNR     STRUCTURE /ZAK/OUT_BELNR
*--0003 2009.05.22 BG
                    USING    $UREPI_LOG STRUCTURE /ZAK/UREPI_LOG
                             $UREPI_LOG_SAVE STRUCTURE /ZAK/UREPI_LOG
                             $BUKRS
                             $TESZT
*++0004 BG 2009.10.29
                             $SEL_BUKRS.
*--0004 BG 2009.10.29

*  Temporary tables for filtering.
  DATA LI_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
  DATA LI_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA LW_BSIS TYPE  BSIS.
  DATA LI_BSIS TYPE STANDARD TABLE OF BSIS INITIAL SIZE 0.
  DATA L_BUKRS TYPE  BUKRS.
  DATA L_LINES LIKE SY-TABIX.
  DATA LI_UREPI_FELD_NEW TYPE STANDARD TABLE OF /ZAK/UREPI_FELD
                                                INITIAL SIZE 0.
  DATA LW_UREPI_LOG TYPE /ZAK/UREPI_LOG.
  DATA LW_UREPI_LOG_SAVE TYPE /ZAK/UREPI_LOG.


  DESCRIBE TABLE $I_/ZAK/SZJA_CUST LINES L_LINES.

  REFRESH:  $I_BKPF, $I_BSEG, LI_UREPI_FELD_NEW.


* Filter BKPF and BSEG for normal items (based on last run)
  LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.
*   Data selection
    PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                     L_LINES
                                     SY-TABIX.
    REFRESH: LI_BSEG, LI_BKPF, LI_BSIS.
*   Determine BSIS records
    PERFORM GET_BSIS TABLES LI_BSIS
                            $S_BLART
                            $I_IDSZ
*++0003 2009.05.22 BG
                            $I_KBELNR
*--0003 2009.05.22 BG
                      USING $BUKRS
                            W_/ZAK/SZJA_CUST-AUFNR
                            W_/ZAK/SZJA_CUST-SAKNR
                   CHANGING L_SUBRC.
*   Determine BKPF records
    PERFORM GET_BKPF TABLES LI_BSIS
                            LI_BKPF
                            LI_UREPI_FELD_NEW
                            $I_UREPI_DATA
                      USING $BUKRS
                            $UREPI_LOG
                            $UREPI_LOG_SAVE
                   CHANGING L_SUBRC.
*   If there is no BKPF record, continue with the next one
    IF LI_BKPF[] IS INITIAL.
      CONTINUE.
    ENDIF.
*   Filter BSEG records
    PERFORM BSEG_KER(/ZAK/SZJA_SAP_SEL) TABLES LI_BSIS
                                              LI_BSEG
                                     CHANGING L_SUBRC.
    IF L_SUBRC <> 0.
*      No data matches the condition, continue with the next one
      CONTINUE.
    ENDIF.
*   Ha minden rendben,akkor elteszem az adatokat
    PERFORM FEJ_ATVESZ(/ZAK/SZJA_SAP_SEL)   TABLES LI_BKPF
                                                  $I_BKPF.
    PERFORM TETEL_ATVESZ(/ZAK/SZJA_SAP_SEL) TABLES LI_BSEG
                                                  $I_BSEG.
  ENDLOOP.

  REFRESH: LI_BSEG, LI_BKPF, LI_BSIS.
* Feldolgozatlan rekordok
  IF NOT $I_UREPI_FELD[] IS INITIAL.
*   Filter BSIS records for unprocessed items
    SELECT * INTO TABLE LI_BSIS
             FROM BSIS
             FOR ALL ENTRIES IN $I_UREPI_FELD
             WHERE BUKRS EQ $I_UREPI_FELD-BUKRS
               AND GJAHR EQ $I_UREPI_FELD-GJAHR
               AND BELNR EQ $I_UREPI_FELD-BELNR
               AND BUZEI EQ $I_UREPI_FELD-BUZEI.
  ENDIF.

  REFRESH $I_UREPI_FELD.

  IF NOT LI_BSIS[] IS INITIAL.
* Feldolgozatlan rekordok
    PERFORM PROGRESS_INDICATOR USING TEXT-P02
                                     0
                                     0.

* Determine BKPF records
    PERFORM GET_BKPF TABLES LI_BSIS
                            LI_BKPF
                            LI_UREPI_FELD_NEW
                            $I_UREPI_DATA
                      USING $BUKRS
                            LW_UREPI_LOG      "Empty
                            LW_UREPI_LOG_SAVE "Empty
                   CHANGING L_SUBRC.

* Filter BSEG records
    IF NOT LI_BSIS[] IS INITIAL.

      PERFORM BSEG_KER(/ZAK/SZJA_SAP_SEL) TABLES LI_BSIS
                                                LI_BSEG
                                       CHANGING L_SUBRC.

* Ha minden rendben,akkor elteszem az adatokat
      PERFORM FEJ_ATVESZ(/ZAK/SZJA_SAP_SEL)   TABLES LI_BKPF
                                                    $I_BKPF.
      PERFORM TETEL_ATVESZ(/ZAK/SZJA_SAP_SEL) TABLES LI_BSEG
                                                    $I_BSEG.
    ENDIF.
  ENDIF.

* Save unprocessed records
  IF NOT LI_UREPI_FELD_NEW[] IS INITIAL.
    APPEND LINES OF LI_UREPI_FELD_NEW TO $I_UREPI_FELD.
    SORT $I_UREPI_FELD.
    DELETE ADJACENT DUPLICATES FROM $I_UREPI_FELD.
  ENDIF.

* Delete duplicate items:
  SORT: $I_BKPF, $I_BSEG.
  DELETE ADJACENT DUPLICATES FROM $I_BKPF.
  DELETE ADJACENT DUPLICATES FROM $I_BSEG.


*++0004 BG 2009.10.29
*  Filter BSEG records for the rotated company code
  LOOP AT $I_BSEG INTO W_BSEG.
    READ TABLE $I_BKPF INTO W_BKPF
                   WITH KEY BUKRS = W_BSEG-BUKRS
                            BELNR = W_BSEG-BELNR
                            GJAHR = W_BSEG-GJAHR.

    IF SY-SUBRC EQ 0.
      PERFORM ROTATE_BUKRS_INPUT(/ZAK/SZJA_SAP_SEL) TABLES I_AD_BUKRS
                                                   USING  W_BSEG
                                                          W_BKPF
                                                CHANGING  L_BUKRS.
      IF L_BUKRS NE $SEL_BUKRS.
        DELETE $I_BSEG.
      ENDIF.
    ENDIF.
  ENDLOOP.
*--0004 BG 2009.10.29

ENDFORM.                    " GET_BOOK_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_BKPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSIS  text
*      -->P_$BUKRS  text
*      -->P_$I_IDSZ  text
*      -->P_W_/ZAK/SZJA_CUST_AUFNR  text
*      -->P_W_/ZAK/SZJA_CUST_SAKNR  text
*      -->P_$UREPI_LOG  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_BKPF  TABLES   $I_BSIS  STRUCTURE BSIS
                        $I_BKPF  STRUCTURE BKPF
                        $I_UREPI_FELD_NEW STRUCTURE /ZAK/UREPI_FELD
                        $I_UREPI_DATA STRUCTURE /ZAK/UREPIDATA
               USING    $BUKRS
                        $UREPI_LOG STRUCTURE /ZAK/UREPI_LOG
                        $UREPI_LOG_SAVE STRUCTURE /ZAK/UREPI_LOG
                        $SUBRC.

  DATA   LW_BSIS TYPE  BSIS.
  DATA   LW_BKPF TYPE BKPF.
  DATA   L_CPUDTM_LOG(14).
  DATA   L_CPUDTM_BKPF(14).
  DATA   L_CPUDTM_BKPF_SAVE(14).

* Last LOG timestamp
  CONCATENATE $UREPI_LOG-CPUDT $UREPI_LOG-CPUTM INTO L_CPUDTM_LOG.
* Filter by CPU date and time
  LOOP AT $I_BSIS INTO LW_BSIS.
* Filter WL documents (these documents are posted by us)
    IF LW_BSIS-ZUONR(2) = 'WL'.
      DELETE $I_BSIS.
      CONTINUE.
    ELSE.
*     Last saved timestamp:
      CONCATENATE $UREPI_LOG_SAVE-CPUDT $UREPI_LOG_SAVE-CPUTM INTO L_CPUDTM_BKPF_SAVE.
*     Check whether it can be processed.
      READ TABLE $I_UREPI_DATA TRANSPORTING NO FIELDS
           WITH KEY BUKRS = LW_BSIS-BUKRS
                    GJAHR = LW_BSIS-BLDAT(4).
*     Item not to be processed
      IF SY-SUBRC NE 0.
        MOVE-CORRESPONDING LW_BSIS TO W_UREPI_FELD.
        APPEND W_UREPI_FELD TO $I_UREPI_FELD_NEW.
        DELETE $I_BSIS.
        CONTINUE.
      ENDIF.

      SELECT SINGLE * INTO LW_BKPF
                      FROM BKPF
                     WHERE BUKRS EQ LW_BSIS-BUKRS
                       AND BELNR EQ LW_BSIS-BELNR
                       AND GJAHR EQ LW_BSIS-GJAHR.
      IF SY-SUBRC EQ 0.
*     Last record for filtering
        CONCATENATE LW_BKPF-CPUDT LW_BKPF-CPUTM INTO L_CPUDTM_BKPF.
*       Ha van LOG
        IF NOT $UREPI_LOG IS INITIAL AND $UREPI_LOG-GJAHR
            EQ LW_BKPF-BUDAT(4)
            AND $UREPI_LOG-MONAT EQ LW_BKPF-BUDAT+4(2).
*       Record already processed
          IF L_CPUDTM_LOG GE L_CPUDTM_BKPF.
            DELETE $I_BSIS.
            CONTINUE.
          ENDIF.
        ENDIF.
*       Save LOG data if necessary
        IF L_CPUDTM_BKPF > L_CPUDTM_BKPF_SAVE.
          MOVE-CORRESPONDING LW_BKPF TO $UREPI_LOG_SAVE.
        ENDIF.
*Currency check
*The program also filtered items that were not in HUF
*which the analytics handled incorrectly because it took the amounts from the items
*calculated the currency from the DMBTR (local currency) field
*while writing the BKPF-WAERS value (e.g. EUR).
*Therefore always place the company T001-WAERS into BKPF_WAERS
*write that value!
        SELECT SINGLE WAERS INTO LW_BKPF-WAERS
                            FROM T001
                           WHERE BUKRS = LW_BKPF-BUKRS.
        APPEND LW_BKPF TO $I_BKPF.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_BKPF
*&---------------------------------------------------------------------*
*&      Form  GET_UREPI_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_UREPI_DATA  text
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
FORM GET_UREPI_DATA  TABLES   $I_UREPI_DATA STRUCTURE /ZAK/UREPIDATA
                     USING    $BUKRS.

  SELECT * INTO TABLE $I_UREPI_DATA
           FROM /ZAK/UREPIDATA
          WHERE BUKRS EQ $BUKRS.

ENDFORM.                    " GET_UREPI_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_BSIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSIS  text
*      -->P_$S_BLART  text
*      -->P_LI_BKPF  text
*      -->P_$I_IDSZ  text
*      -->P_LI_UREPI_FELD_NEW  text
*      -->P_$I_UREPI_DATA  text
*      -->P_$BUKRS  text
*      -->P_W_/ZAK/SZJA_CUST_AUFNR  text
*      -->P_W_/ZAK/SZJA_CUST_SAKNR  text
*      -->P_$UREPI_LOG  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_BSIS  TABLES   $I_BSIS  STRUCTURE BSIS
                        $S_BLART STRUCTURE S_BLART
                        $I_IDSZ  LIKE I_IDSZ
*++0003 2009.05.22 BG
                        $I_KBELNR     STRUCTURE /ZAK/OUT_BELNR
*--0003 2009.05.22 BG
               USING    $BUKRS
                        $AUFNR
                        $SAKNR
               CHANGING $SUBRC.


  RANGES LR_AUFNR FOR BSEG-AUFNR.

*  Build a selection condition from the order
  REFRESH LR_AUFNR.
  IF NOT $AUFNR IS INITIAL.
    M_DEF LR_AUFNR 'I' 'EQ' $AUFNR SPACE.
  ENDIF.

* BSIS selection
  SELECT * INTO TABLE $I_BSIS
           FROM BSIS
           FOR ALL ENTRIES IN $I_IDSZ
           WHERE BUKRS = $BUKRS
             AND HKONT = $SAKNR
             AND GJAHR = $I_IDSZ-GJAHR
             AND BLART IN S_BLART
             AND MONAT = $I_IDSZ-MONAT
             AND AUFNR IN LR_AUFNR.
*++0003 2009.05.22 BG
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
*--0003 2009.05.22 BG


ENDFORM.                    " GET_BSIS
*&---------------------------------------------------------------------*
*&      Form  EVES_ADATOK_SUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_I_BSEG  text
*      -->P_R_BTYPE  text
*      -->P_I_BTYPE_ARANY  text
*      -->P_I_UREPI_DATA  text
*----------------------------------------------------------------------*
FORM EVES_ADATOK_SUM  TABLES   $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                               $I_BSEG          STRUCTURE BSEG
                               $I_BKPF          STRUCTURE BKPF
                               $R_BTYPE         STRUCTURE R_BTYPE
                               $I_ARANY         STRUCTURE I_BTYPE_ARANY
                               $I_UREPI_DATA    STRUCTURE /ZAK/UREPIDATA
                       USING   $BUKRS.

  RANGES: LR_AUFNR FOR BSEG-AUFNR.
  DATA L_TMP_ADOALAP LIKE BSEG-DMBTR.
  DATA L_DATAB TYPE DATAB.
  DATA L_DATBI TYPE DATBI.
  DATA LW_BEVALL TYPE /ZAK/BEVALL.
  DATA L_TABIX LIKE SY-TABIX.

* Determine ratio
  DEFINE LM_GET_ARANY.
    IF NOT  $I_ARANY-&2_ALAP IS INITIAL.
      READ TABLE $I_UREPI_DATA INTO W_UREPI_DATA
                 WITH KEY BUKRS = $BUKRS
                          GJAHR = &1-GJAHR
                          UREPF = C_UREPF_&2.
      IF SY-SUBRC EQ 0.
        L_TABIX = SY-TABIX.
        L_TMP_ADOALAP = &1-&2_ALAP + W_UREPI_DATA-HFORG.
*       Ha a keret alatt vagyunk
        IF L_TMP_ADOALAP <= W_UREPI_DATA-ADOMN AND
           W_UREPI_DATA-HFORG <= W_UREPI_DATA-ADOMN.
          $I_ARANY-&2_ARANY = 0.
*       We are crossing the threshold now
        ELSEIF W_UREPI_DATA-HFORG <= W_UREPI_DATA-ADOMN AND
           L_TMP_ADOALAP > W_UREPI_DATA-ADOMN.
          $I_ARANY-&2_ARANY = ( L_TMP_ADOALAP -
                                W_UREPI_DATA-ADOMN ) /
                                &1-&2_ALAP.
*       We have already crossed the threshold
        ELSEIF W_UREPI_DATA-HFORG > W_UREPI_DATA-ADOMN AND
               L_TMP_ADOALAP > W_UREPI_DATA-ADOMN.
          $I_ARANY-&2_ARANY = 1.
*       We drop back below the threshold
        ELSEIF W_UREPI_DATA-HFORG > W_UREPI_DATA-ADOMN AND
               L_TMP_ADOALAP <= W_UREPI_DATA-ADOMN.
          $I_ARANY-&2_ARANY = ( W_UREPI_DATA-HFORG -
                                W_UREPI_DATA-ADOMN ) /
                                &1-&2_ALAP.
        ENDIF.
        W_UREPI_DATA-HFORG = L_TMP_ADOALAP.
        MODIFY $I_UREPI_DATA FROM W_UREPI_DATA INDEX L_TABIX
                             TRANSPORTING HFORG.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.


  LOOP AT $R_BTYPE.
    CLEAR: $I_ARANY, L_DATAB, L_DATBI.
*   Determine the start and end of the period
    SELECT * INTO LW_BEVALL
             FROM /ZAK/BEVALL
            WHERE BUKRS EQ $BUKRS
              AND BTYPE EQ $R_BTYPE-LOW.
      IF L_DATBI IS INITIAL OR LW_BEVALL-DATBI > L_DATBI.
        MOVE LW_BEVALL-DATBI TO L_DATBI.
      ENDIF.
      IF L_DATAB IS INITIAL OR LW_BEVALL-DATAB < L_DATAB.
        MOVE LW_BEVALL-DATAB TO L_DATAB.
      ENDIF.
    ENDSELECT.

    LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                             WHERE BTYPE EQ $R_BTYPE-LOW.
*     Build a selection condition from the order
      REFRESH LR_AUFNR.
      IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
        M_DEF LR_AUFNR 'I' 'EQ' W_/ZAK/SZJA_CUST-AUFNR SPACE.
      ENDIF.
*      Walk through the relevant BSEG items
      LOOP AT $I_BSEG INTO W_BSEG
                      WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                        AND AUFNR IN  LR_AUFNR.

*        Looks up the header data
        READ TABLE $I_BKPF INTO W_BKPF
                           WITH KEY BUKRS = W_BSEG-BUKRS
                                    BELNR = W_BSEG-BELNR
                                    GJAHR = W_BSEG-GJAHR.

        CHECK W_BKPF-BLDAT BETWEEN L_DATAB AND L_DATBI.
*        Calculates the tax base according to the conditions
        PERFORM ANALITIKA_ADOALAP_SZAMITAS(/ZAK/SZJA_SAP_SEL)
                                        USING W_BSEG
                                              W_BKPF
                                              W_/ZAK/SZJA_CUST-/ZAK/EVES
                                              W_/ZAK/SZJA_CUST-ADOALAP
                                              W_/ZAK/SZJA_CUST-/ZAK/WL
                                              W_/ZAK/SZJA_CUST-MWSKZ
                                              1  "v_a_arany
                                              1  "v_r_arany
                                     CHANGING L_TMP_ADOALAP.
*        Tax base accumulation
        CLEAR $I_ARANY.
        $I_ARANY-GJAHR = W_BKPF-BLDAT(4).
        IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'A'.
          $I_ARANY-U_ALAP = L_TMP_ADOALAP.
        ELSE.
          $I_ARANY-R_ALAP = L_TMP_ADOALAP.
        ENDIF.
        COLLECT $I_ARANY.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

* Accumulate bases and calculate ratio
  LOOP AT $I_ARANY.
*   Business part
    LM_GET_ARANY $I_ARANY U.
*   Representation part
    LM_GET_ARANY $I_ARANY R.
    MODIFY $I_ARANY.
  ENDLOOP.

ENDFORM.                    " EVES_ADATOK_SUM
*&---------------------------------------------------------------------*
*&      Form  SOR_SZETRAK_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SOR_SZETRAK_NEW TABLES   $I_BSEG           STRUCTURE BSEG
                              $I_BKPF           STRUCTURE BKPF
                              $I_/ZAK/SZJA_CUST  STRUCTURE /ZAK/SZJA_CUST
                              $I_/ZAK/BEVALL     STRUCTURE /ZAK/BEVALL
                              $I_/ZAK/ANALITIKA  STRUCTURE /ZAK/ANALITIKA
                              $I_/ZAK/SZJA_EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                              $I_BTYPE_ARANY    STRUCTURE I_BTYPE_ARANY
                      USING   $BUKRS
                              $SEL_BUKRS
                              $GJAHR
                              $MONAT
                              $BSZNUM.

  DATA L_GJAHR TYPE GJAHR.
  DATA L_MONAT TYPE MONAT.
  DATA L_BTYPE TYPE /ZAK/BTYPE.

  DATA: L_SZAMLA_BELNR(10).
  DATA L_SUBRC LIKE SY-SUBRC.


  DATA L_LINES LIKE SY-TABIX.

  DEFINE LR_GET_SZAMLA_BELNR.
    IF NOT &1 IS INITIAL.
      IF &2 = &1.
        CLEAR &2.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

  DESCRIBE TABLE $I_BSEG LINES L_LINES.

  LOOP AT I_BSEG INTO W_BSEG.
*    Processing data
    PERFORM PROGRESS_INDICATOR USING TEXT-P04
                                     L_LINES
                                     SY-TABIX.

*   Look up the header data
    READ TABLE $I_BKPF INTO W_BKPF
                       WITH KEY BUKRS = W_BSEG-BUKRS
                                BELNR = W_BSEG-BELNR
                                GJAHR = W_BSEG-GJAHR.

*   Determine whether a declaration type exists for the period
    CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
      EXPORTING
        I_BUKRS     = $BUKRS
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
    ENDIF.

*   Determine SZJA_CUST first with the order as well.
    READ TABLE $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                           WITH KEY BTYPE = L_BTYPE
                                    SAKNR = W_BSEG-HKONT
                                    AUFNR = W_BSEG-AUFNR.
*   Try without the order
    IF SY-SUBRC NE 0.
      READ TABLE $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                             WITH KEY BTYPE = L_BTYPE
                                      SAKNR = W_BSEG-HKONT
                                      AUFNR = ''.
    ENDIF.

    CLEAR W_/ZAK/BEVALL.
    READ TABLE $I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY
                                 BUKRS = W_/ZAK/SZJA_CUST-BUKRS
                                 BTYPE = W_/ZAK/SZJA_CUST-BTYPE.
    IF SY-SUBRC NE 0.
      MESSAGE E114.
*     Error while determining the declaration type!
    ENDIF.

*   If the ABEV ID is not empty, the row must be added to the analytics
    IF NOT W_/ZAK/SZJA_CUST-ABEVAZ IS INITIAL.
*      FILLS the first row of the analytics.
      PERFORM ANALITIKA_KITOLT TABLES $I_/ZAK/BEVALL
                                      $I_BTYPE_ARANY
                               USING  W_/ZAK/ANALITIKA
                                      W_/ZAK/SZJA_CUST
                                      W_BSEG
                                      W_BKPF
                                      W_/ZAK/BEVALL
                                      $SEL_BUKRS
                                      $BUKRS
                                      $GJAHR
                                      $MONAT
                                      $BSZNUM
                                      L_SUBRC.
      CHECK L_SUBRC EQ 0.
*     Elmenti az analitoka rekordot.
      APPEND  W_/ZAK/ANALITIKA  TO $I_/ZAK/ANALITIKA.
    ENDIF.
*   WL postings
    IF NOT W_/ZAK/SZJA_CUST-/ZAK/WL IS INITIAL
       AND W_BKPF-BLART = 'WL' AND W_/ZAK/SZJA_CUST-WLBOUT IS INITIAL.

*++0002 2009.04.20 BG
**++0001 2009.01.12 BG
*      CLEAR W_/ZAK/SZJA_ABEV.
*      SELECT SINGLE * INTO W_/ZAK/SZJA_ABEV
*             FROM /ZAK/SZJA_ABEV
*             WHERE BUKRS     = $BUKRS
*               AND BTYPE     = L_BTYPE
*               AND FIELDNAME = 'WL'.
**--0001 2009.01.12 BG
      PERFORM GET_SZJA_ABEV(/ZAK/SZJA_SAP_SEL)
                            USING W_/ZAK/SZJA_ABEV
                                  P_BUKRS
                                  L_BTYPE.

*--0002 2009.04.20 BG
      PERFORM BOOK_WL_V2(/ZAK/SZJA_SAP_SEL) USING W_BKPF
                               W_BSEG
                               W_/ZAK/SZJA_ABEV
                               W_/ZAK/BEVALL
                               W_/ZAK/SZJA_EXCEL1
                               W_/ZAK/SZJA_EXCEL2
                               $GJAHR
                               $MONAT.
*One identifier has to group the items; currently a line number is used
      L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
      W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
      W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*       Outputs the records
      APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
      APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
    ENDIF.
*   Reposting according to configuration
    IF NOT W_/ZAK/SZJA_CUST-/ZAK/ATKONYV IS INITIAL.
*++0002 2009.04.20 BG
      PERFORM GET_SZJA_ABEV(/ZAK/SZJA_SAP_SEL)
                            USING W_/ZAK/SZJA_ABEV
                                  P_BUKRS
                                  L_BTYPE.
*--0002 2009.04.20 BG
      PERFORM BOOK_ATKONYV_V2(/ZAK/SZJA_SAP_SEL) USING W_BKPF
                                    W_BSEG
                                    W_/ZAK/SZJA_ABEV
                                    W_/ZAK/BEVALL
                                    W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
                                    W_/ZAK/SZJA_EXCEL1
                                    W_/ZAK/SZJA_EXCEL2.
*One identifier has to group the items; currently a line number is used
      L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
      W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
      W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*        Outputs the record
      APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
      APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " SOR_SZETRAK_NEW
*&---------------------------------------------------------------------*
*&      Form  analitika_kitolt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/ANALITIKA  text
*      -->P_<FS_MEZO>  text
*      -->P_W_BSEG  text
*----------------------------------------------------------------------*
FORM ANALITIKA_KITOLT TABLES $I_/ZAK/BEVALL    STRUCTURE /ZAK/BEVALL
                             $I_BTYPE_ARANY   STRUCTURE I_BTYPE_ARANY
                      USING  $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                             $W_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                             $W_BSEG          STRUCTURE BSEG
                             $W_BKPF          STRUCTURE BKPF
                             $W_/ZAK/BEVALL    STRUCTURE /ZAK/BEVALL
                             $SEL_BUKRS
                             $BUKRS
                             $GJAHR
                             $MONAT
                             $BSZNUM
                             $SUBRC.

  DATA L_GJAHR TYPE GJAHR.
  DATA L_BLDAT LIKE SY-DATUM.
  DATA L_BTYPE TYPE /ZAK/BTYPE.
  DATA : LI_ABEV_CONTACT TYPE STANDARD TABLE OF /ZAK/ABEVCONTACT,
         LW_ABEV_CONTACT TYPE                   /ZAK/ABEVCONTACT.

  CLEAR $W_/ZAK/ANALITIKA.
  CLEAR $SUBRC.
*  Fill every possible field
  MOVE-CORRESPONDING $W_BSEG TO $W_/ZAK/ANALITIKA.

  MOVE $SEL_BUKRS TO $W_/ZAK/ANALITIKA-BUKRS.
  MOVE $BUKRS TO $W_/ZAK/ANALITIKA-FI_BUKRS.


* Set posting period and date
  L_GJAHR = W_BKPF-BLDAT(4) + 1.

* Check the declaration type for the period
*  PERFORM GET_VERIFY_BTYPE_FROM_DATUM(/ZAK/SZJA_SAP_SEL) TABLES $I_/ZAK/BEVALL
*                                      USING  $W_/ZAK/SZJA_CUST-BTYPE
*                                             L_GJAHR
*                                             C_REPI_MONAT
*                                             $SUBRC.
*  IF $SUBRC NE 0.
*    EXIT.
*  ENDIF.

* Determine the declaration type for the period
  CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
    EXPORTING
      I_BUKRS     = $BUKRS
      I_BTYPART   = C_BTYPART_SZJA
      I_GJAHR     = L_GJAHR
      I_MONAT     = C_REPI_MONAT
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

* If it does not match, then convert:
  IF $W_/ZAK/SZJA_CUST-BTYPE NE L_BTYPE.

*  Check what the appropriate ABEV would be
    CALL FUNCTION '/ZAK/ABEV_CONTACT'
      EXPORTING
        I_BUKRS        = $BUKRS
        I_BTYPE        = $W_/ZAK/SZJA_CUST-BTYPE
        I_ABEVAZ       = $W_/ZAK/SZJA_CUST-ABEVAZ
        I_GJAHR        = L_GJAHR
        I_MONAT        = C_REPI_MONAT
      TABLES
        T_ABEV_CONTACT = LI_ABEV_CONTACT
      EXCEPTIONS
        ERROR_BTYPE    = 1
        ERROR_MONAT    = 2
        ERROR_ABEVAZ   = 3
        OTHERS         = 4.
    IF SY-SUBRC EQ 0.
      DESCRIBE TABLE LI_ABEV_CONTACT LINES SY-TFILL.
      READ TABLE LI_ABEV_CONTACT INTO LW_ABEV_CONTACT INDEX SY-TFILL.
      IF SY-SUBRC = 0.
        $W_/ZAK/SZJA_CUST-ABEVAZ = LW_ABEV_CONTACT-ABEVAZ.
      ENDIF.
      $W_/ZAK/ANALITIKA-BTYPE = L_BTYPE.
    ELSE.
      $W_/ZAK/ANALITIKA-BTYPE = $W_/ZAK/SZJA_CUST-BTYPE.
    ENDIF.
  ELSE.
    $W_/ZAK/ANALITIKA-BTYPE = $W_/ZAK/SZJA_CUST-BTYPE.
  ENDIF.

*  Must be set to C_REPI_MONAT for the following year
  $W_/ZAK/ANALITIKA-GJAHR = W_BKPF-BLDAT(4) + 1.
  $W_/ZAK/ANALITIKA-MONAT = C_REPI_MONAT.

* Decide what the posting date should be
  PERFORM GET_LAST_DAY_OF_PERIOD(/ZAK/SZJA_SAP_SEL)
                            USING $GJAHR
                                  $MONAT
                         CHANGING $W_/ZAK/ANALITIKA-BUDAT.


*  Determine the document type based on BKPF-BLDAT
*  CLEAR L_BLDAT.
*  CONCATENATE $W_/ZAK/ANALITIKA-GJAHR
*              $W_/ZAK/ANALITIKA-MONAT
*              '01' INTO L_BLDAT.
*  Determine document type
  PERFORM GET_BLART(/ZAK/SZJA_SAP_SEL) USING W_BKPF-BLDAT
                          $GJAHR
                          $W_/ZAK/BEVALL-BLART
                 CHANGING $W_/ZAK/ANALITIKA-BLART.

  W_/ZAK/ANALITIKA-BLDAT = $W_BKPF-BLDAT.
  W_/ZAK/ANALITIKA-WAERS = $W_BKPF-WAERS.
  W_/ZAK/ANALITIKA-ABEVAZ = $W_/ZAK/SZJA_CUST-ABEVAZ.
  $W_/ZAK/ANALITIKA-BSZNUM = $BSZNUM.
  $W_/ZAK/ANALITIKA-LAPSZ = '0001'.
  $W_/ZAK/ANALITIKA-BSEG_GJAHR = $W_BSEG-GJAHR.
  $W_/ZAK/ANALITIKA-BSEG_BELNR = $W_BSEG-BELNR.
  $W_/ZAK/ANALITIKA-BSEG_BUZEI = $W_BSEG-BUZEI.
* IF THE COST CENTER IS NOT EMPTY, THEN COPY IT INTO THE ANALYTICS
  IF NOT $W_/ZAK/SZJA_CUST-KOSTL IS INITIAL.
    $W_/ZAK/ANALITIKA-KTOSL = $W_/ZAK/SZJA_CUST-KOSTL.
  ENDIF.

*++0005 BG 2010/01/08
*  Transfer the PST element
  IF NOT $W_BSEG-PROJK IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
      EXPORTING
        INPUT  = $W_BSEG-PROJK
      IMPORTING
        OUTPUT = $W_/ZAK/ANALITIKA-POSID.
  ENDIF.
*--0005 BG 2010/01/08

  READ TABLE $I_BTYPE_ARANY WITH KEY GJAHR = $W_BKPF-BLDAT(4).
  IF SY-SUBRC EQ 0.
*  Calculates the tax base according to the conditions
    PERFORM ANALITIKA_ADOALAP_SZAMITAS(/ZAK/SZJA_SAP_SEL)
                                       USING $W_BSEG
                                             $W_BKPF
                                             $W_/ZAK/SZJA_CUST-/ZAK/EVES
                                             $W_/ZAK/SZJA_CUST-ADOALAP
                                             $W_/ZAK/SZJA_CUST-/ZAK/WL
                                             $W_/ZAK/SZJA_CUST-MWSKZ
                                             $I_BTYPE_ARANY-U_ARANY
                                             $I_BTYPE_ARANY-R_ARANY
                                    CHANGING $W_/ZAK/ANALITIKA-FIELD_N.
  ENDIF.

ENDFORM.                    " analitika_kitolt
*&---------------------------------------------------------------------*
*&      Form  GEN_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_BTYPE  text
*      -->P_I_ANALITIKA  text
*----------------------------------------------------------------------*
FORM GEN_ANALITIKA  TABLES   $R_BTYPE          STRUCTURE  R_BTYPE
                             $I_/ZAK/ANALITIKA  STRUCTURE  /ZAK/ANALITIKA
                    USING    $BUKRS
                             $BSZNUM.

  DATA LI_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA OCCURS 0 WITH HEADER LINE.
*Contains the records generated by the function module
  DATA LIO_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                         INITIAL SIZE 0.

*Need to split by declaration type
  LOOP AT $R_BTYPE.
    LI_/ZAK/ANALITIKA[] = $I_/ZAK/ANALITIKA[].
    DELETE LI_/ZAK/ANALITIKA WHERE BTYPE NE $R_BTYPE-LOW.

    REFRESH LIO_/ZAK/ANALITIKA.
    CLEAR   LIO_/ZAK/ANALITIKA.

    CALL FUNCTION '/ZAK/SZJA_NEW_ROWS'
      EXPORTING
        I_BUKRS         = $BUKRS
        I_BTYPE         = $R_BTYPE-LOW
        I_BSZNUM        = $BSZNUM
      TABLES
        I_/ZAK/ANALITIKA = LI_/ZAK/ANALITIKA
        O_/ZAK/ANALITIKA = LIO_/ZAK/ANALITIKA.
*    Copy the received records back into the original.
    APPEND LINES OF LIO_/ZAK/ANALITIKA TO $I_/ZAK/ANALITIKA.
  ENDLOOP.


ENDFORM.                    " GEN_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  INS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/ANALITIKA  text
*      -->P_I_UREPI_FELD  text
*      -->P_/ZAK/UREPI_LOG  text
*      -->P_P_TESZT  text
*      -->P_V_SEL_BUKRS  text
*      -->P_P_BTYPAR  text
*      -->P_P_BSZNUM  text
*      -->P_P_PACK  text
*----------------------------------------------------------------------*
FORM INS_DATA  TABLES   $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                        $I_UREPI_FELD    STRUCTURE /ZAK/UREPI_FELD
                        $I_UREPI_DATA    STRUCTURE /ZAK/UREPIDATA
               USING    $/ZAK/UREPI_LOG   STRUCTURE /ZAK/UREPI_LOG
                        $TESZT
                        $SEL_BUKRS
                        $BTYPAR
                        $BSZNUM
                        $PACK.

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

  IF $I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I031.
*    The database does not contain any processable records!
    EXIT.
  ENDIF.
*  The conversion needs to be called
  CALL FUNCTION '/ZAK/ANALITIKA_CONVERSION'
    TABLES
      T_ANALITIKA = $I_/ZAK/ANALITIKA.

*  Always run in test mode first
  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = $SEL_BUKRS
      I_BTYPART   = $BTYPAR
      I_BSZNUM    = $BSZNUM
      I_PACK      = $PACK
      I_GEN       = 'X'
      I_TEST      = 'X'
*     I_FILE      =
    TABLES
      I_ANALITIKA = $I_/ZAK/ANALITIKA
      E_RETURN    = LI_RETURN.

*   Handle messages
  IF NOT LI_RETURN[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = LI_RETURN.
  ENDIF.

*  If not a test run, check whether there are ERROR messages
  IF NOT $TESZT IS INITIAL.
    LOOP AT LI_RETURN INTO LW_RETURN WHERE TYPE CA 'EA'.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      MESSAGE E062.
*     Data upload is not possible!
    ENDIF.
  ENDIF.

*  In live run with non-ERROR messages, ask whether to continue
  IF $TESZT IS INITIAL.

    IF NOT LI_RETURN[] IS INITIAL.
*    Load texts
      MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
      MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                           TO L_DIAGNOSETEXT1.
      MOVE 'Folytatja  feldolgozást?'(003)
                                           TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*        EXPORTING
*          DEFAULTOPTION = 'N'
*          DIAGNOSETEXT1 = L_DIAGNOSETEXT1
**         DIAGNOSETEXT2 = ' '
**         DIAGNOSETEXT3 = ' '
*          TEXTLINE1     = L_TEXTLINE1
**         TEXTLINE2     = ' '
*          TITEL         = L_TITLE
*          START_COLUMN  = 25
*          START_ROW     = 6
**         CANCEL_DISPLAY       = 'X'
*        IMPORTING
*          ANSWER        = L_ANSWER.
      DATA L_QUESTION TYPE STRING.

      CONCATENATE L_DIAGNOSETEXT1
                  L_TEXTLINE1
                  INTO L_QUESTION SEPARATED BY SPACE.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR       = L_TITLE
*         DIAGNOSE_OBJECT             = ' '
          TEXT_QUESTION  = L_QUESTION
*         TEXT_BUTTON_1  = 'Ja'(001)
*         ICON_BUTTON_1  = ' '
*         TEXT_BUTTON_2  = 'Nein'(002)
*         ICON_BUTTON_2  = ' '
          DEFAULT_BUTTON = '2'
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
          START_COLUMN   = 25
          START_ROW      = 6
*         POPUP_TYPE     =
        IMPORTING
          ANSWER         = L_ANSWER.
      IF L_ANSWER EQ '1'.
        MOVE 'J' TO L_ANSWER.
      ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*    Otherwise it can continue
    ELSE.
      MOVE 'J' TO L_ANSWER.
    ENDIF.

*    The database update can proceed
    IF L_ANSWER EQ 'J'.
*      Modify data
      CALL FUNCTION '/ZAK/UPDATE'
        EXPORTING
          I_BUKRS     = $SEL_BUKRS
          I_BTYPART   = $BTYPAR
          I_BSZNUM    = $BSZNUM
          I_PACK      = $PACK
          I_GEN       = 'X'
          I_TEST      = $TESZT
*         I_FILE      =
        TABLES
          I_ANALITIKA = I_/ZAK/ANALITIKA
          E_RETURN    = LI_RETURN.
*     Restore the index
      LOOP AT $I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*        Save the package identifier
        IF L_PACK IS INITIAL.
          MOVE W_/ZAK/ANALITIKA-PACK TO L_PACK.
        ENDIF.
        INSERT INTO /ZAK/ANALITIKA VALUES W_/ZAK/ANALITIKA.
      ENDLOOP.
*     Save unprocessed data
      DELETE FROM /ZAK/UREPI_FELD WHERE BUKRS EQ $SEL_BUKRS.
      IF NOT $I_UREPI_FELD[] IS INITIAL.
        INSERT /ZAK/UREPI_FELD FROM TABLE $I_UREPI_FELD.
      ENDIF.
*     Save LOG
      MODIFY /ZAK/UREPI_LOG FROM $/ZAK/UREPI_LOG.
*     Save cumulative turnover
      MODIFY /ZAK/UREPIDATA FROM TABLE $I_UREPI_DATA.
      COMMIT WORK AND WAIT.
      MESSAGE I033 WITH L_PACK.
*     Upload completed with package number &!
    ENDIF.
  ENDIF.

ENDFORM.                    " INS_DATA
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .
  SORT I_/ZAK/ANALITIKA BY BUKRS BTYPE BSEG_GJAHR BSEG_BELNR
                          BSEG_BUZEI ABEVAZ.
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
FORM SET_STATUS .
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

ENDFORM.                    " SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/ANALITIKA[]  text
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

* Build field catalog
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING $FIELDCAT.

* Exclude functions
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
*    Exit
    WHEN 'BACK'.
      PERFORM EXIT_PROGRAM.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
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

* Build field catalog
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING $FIELDCAT.

* Exclude functions
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
    WHEN 'BACK'.
      PERFORM EXIT_PROGRAM.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9001  INPUT
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
