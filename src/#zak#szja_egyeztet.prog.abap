*&---------------------------------------------------------------------*
*& Program: Reconciliation of SZJA tax return data with G/L balance
*&---------------------------------------------------------------------*
REPORT /ZAK/SZJA_EGYEZTET MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Based on the selection criteria entered
*& it filters the data from SAP documents and stores them in /ZAK/ANALITIKA
*& stores them.
*&---------------------------------------------------------------------*
*& Author            : Gábor Balázs - FMC
*& Creation date      : 2006.01.18
*& Functional spec author: ________
*& SAP module name    : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION       TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2006/11/10   Balázs G.     Modify BTYPE handling, allow multiple
*&                                   multiple entries are possible
*& 0002   2006/11/29   Balázs G.     Handle multiple declaration types
*& 0003   2006/12/06   Balázs G.     Separate HR document types
*& 0004   2007/02/22   Forgó I.      Display correction declarations
*& 0005   2007/03/01   Forgó I.      Convert previous ABEV codes
*                                    to the current ABEV code
*& 0006   2007/03/26   Balázs G.     Adjust handling of self-revision periods
*& 0007   2007/07/24   Balázs G.     Optimization: do not read through
*&        for each G/L account the LI_ADOAZON records that are not found
*         only for the first G/L account in the given period.
*& 0008   2007/11/09   Balázs G.     Create LOG table in which
*&        the amount can be itemized, one LOG per company
*&        can be created.
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/SAP_SEL_F01.



*&---------------------------------------------------------------------*
*& TABLES                                                             *
*&---------------------------------------------------------------------*
TABLES : BSEG,              "Document segment: accounting
         BKPF,              "Document header for accounting
         BSIS, "Accounting: secondary index for G/L accounts
         BSAS,
         /ZAK/SZJA_CUST,     "SZJA deduction, posting configuration
         /ZAK/SZJA_ABEV,     "SZJA deduction, based on ABEV-defined field name
         /ZAK/SZJA_ELL. "Structure for the /ZAK/SZJA_EGYEZTET program


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table        -   (I_xxx...)                              *
*      FORM parameter        -   ($xxxx...)                              *
*      Constant             -   (C_xxx...)                              *
*      Parameter variable    -   (P_xxx...)                              *
*      Selection option      -   (S_xxx...)                              *
*      Ranges               -   (R_xxx...)                              *
*      Global variables      -   (V_xxx...)                              *
*      Local variables       -   (L_xxx...)                              *
*      Work area             -   (W_xxx...)                              *
*      Type                  -   (T_xxx...)                              *
*      Macros                -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Method               -   (METH_xxx...)                           *
*      Object               -   (O_xxx...)                              *
*      Class                 -   (CL_xxx...)                             *
*      Event                 -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA V_SUBRC LIKE SY-SUBRC.
DATA V_REPID LIKE SY-REPID.



DATA :  BEGIN OF I_FOKONYV OCCURS 0,
         SAKNR  LIKE SKB1-SAKNR,
         ABEVAZ LIKE /ZAK/BEVALLB-ABEVAZ,
         BTYPE  LIKE /ZAK/BEVALLB-BTYPE,
        END OF I_FOKONYV.
RANGES:  R_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ,
         R_MONAT  FOR BKPF-MONAT.

DATA W_/ZAK/SZJA_ELL TYPE  /ZAK/SZJA_ELL.
DATA I_/ZAK/SZJA_ELL TYPE STANDARD TABLE OF /ZAK/SZJA_ELL
                                                       INITIAL SIZE 0.

*++0008 BG 2007.11.09
DATA I_/ZAK/SZJA_ELLLOG  TYPE STANDARD TABLE OF /ZAK/SZJA_ELLLOG
                                                INITIAL SIZE 0.
DATA W_/ZAK/SZJA_ELLLOG  TYPE  /ZAK/SZJA_ELLLOG.
*--0008 BG 2007.11.09

*++0004 20070222 FI
DATA: I_/ZAK/EGYKORR TYPE TABLE OF /ZAK/EGYKORR
     ,LS_/ZAK/EGYKORR TYPE /ZAK/EGYKORR
     .
*--0004 20070222 FI



* ALV handling variables
DATA: V_OK_CODE LIKE SY-UCOMM,
      V_SAVE_OK LIKE SY-UCOMM,
      V_CONTAINER   TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',
*      V_CONTAINER1  TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',

      V_CUSTOM_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT   TYPE LVC_T_FCAT,
      V_LAYOUT     TYPE LVC_S_LAYO,
      V_VARIANT    TYPE DISVARIANT,
      V_GRID   TYPE REF TO CL_GUI_ALV_GRID.
*      V_EVENT_RECEIVER  TYPE REF TO LCL_EVENT_RECEIVER.
DATA: BEGIN OF I_OUTTAB2 OCCURS 0.
        INCLUDE STRUCTURE /ZAK/SZJA_ELL.
DATA: CELLTAB TYPE LVC_T_STYL.
DATA: END OF I_OUTTAB2.

*++BG 2006/07/19
*Macro definition for filling a range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.
*++BG 2006/07/19

*++0002 BG 2006/11/29
RANGES R_BTYPE FOR /ZAK/BEVALL-BTYPE.
*--0002 BG 2006/11/29


*++0006 BG 2007.03.26
*++BG 2006/07/19
* For handling self-revision, during self-revision the ABEV
* subtract the previous period's value from the identifier based on the code
* for the same ABEV identifier value.
RANGES LR_BTYPE  FOR /ZAK/BEVALLO-BTYPE.
*++BG 2006/12/06
*  RANGES LR_GJAHR  FOR /ZAK/BEVALLO-GJAHR.
*  RANGES LR_MONAT  FOR /ZAK/BEVALLO-MONAT.
*  RANGES LR_ZINDEX FOR /ZAK/BEVALLO-ZINDEX.
DATA: BEGIN OF LI_IDOSZ OCCURS 0,
      GJAHR  TYPE GJAHR,
      MONAT  TYPE MONAT,
      ZINDEX TYPE /ZAK/INDEX,
      END OF LI_IDOSZ.

*++ BG 2007.01.24
DATA LW_IDOSZ LIKE LI_IDOSZ.
*-- BG 2007.01.24

*--BG 2006/12/06
*++BG 2006.12.28
*  RANGES LR_ADOAZON FOR /ZAK/BEVALLO-ADOAZON.
DATA: BEGIN OF LI_ADOAZON OCCURS 0,
      GJAHR   TYPE GJAHR,
      MONAT   TYPE MONAT,
      ZINDEX  TYPE /ZAK/INDEX,
      ADOAZON TYPE /ZAK/ADOAZON,
      END OF LI_ADOAZON.
*--BG 2006.12.28
*++0007 BG 2007.07.24
* Collect tax numbers that were not found here
DATA: BEGIN OF LI_ADOAZON_NOTFOUND OCCURS 0,
      BTYPE TYPE /ZAK/BTYPE.
        INCLUDE STRUCTURE LI_ADOAZON.
DATA: END OF LI_ADOAZON_NOTFOUND.
*--0007 BG 2007.07.24



DATA V_GET_IDOSZ_FROM_BEVALLO.
*--0006 BG 2007.03.26




*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

* Company.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-101.
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLSZ-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

SELECTION-SCREEN END OF LINE.
* Determine declaration type
PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                          DEFAULT C_BTYPART_SZJA
                          OBLIGATORY
                          MODIF ID DIS.
*++0002 BG 2006/11/29
*PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLSZ-BTYPE
*                           NO-DISPLAY.
*--0002 BG 2006/11/29

* Year
PARAMETERS: P_GJAHR LIKE BKPF-GJAHR DEFAULT SY-DATUM(4)
                                    OBLIGATORY.
* Month
PARAMETERS: P_MONAT LIKE BKPF-MONAT DEFAULT SY-DATUM+4(2)
                                    OBLIGATORY.
*++0003 BG 2006/12/06
* HR bizonylat fajta
SELECT-OPTIONS: S_BLART FOR BKPF-BLART OBLIGATORY.
*--0003 BG 2006/12/06
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(46) TEXT-102.
PARAMETERS: P_PERIOD  AS CHECKBOX.
SELECTION-SCREEN POSITION 50.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN: END OF BLOCK BL01.

*++0006 BG 2007.03.26
SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
PARAMETERS P_LOAD AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK BL02.
*--0006 BG 2007.03.26


*++0008 BG 2007.11.09
SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-T03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(79) TEXT-104.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(79) TEXT-105.
SELECTION-SCREEN END OF LINE.
PARAMETERS P_LOG AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK BL03.
*--0008 BG 2007.11.09
*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
  MOVE SY-REPID TO V_REPID.

*  Determine descriptions
  PERFORM READ_ADDITIONALS.
*++0003 BG 2006/12/06
* Populate HR document type
  M_DEF S_BLART 'I' 'EQ' 'SG' SPACE.
*--0003 BG 2006/12/06
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
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

* Set screen attributes
  PERFORM SET_SCREEN_ATTRIBUTES.

AT SELECTION-SCREEN ON P_PERIOD.
* Only makes sense for month 12.
  PERFORM P_PERIOD_ELL USING P_PERIOD
                             P_MONAT.
*++0008 BG 2007.11.09
AT SELECTION-SCREEN ON P_LOG.
  IF NOT P_LOAD IS INITIAL AND NOT P_LOG IS INITIAL.
    MESSAGE I234.
*   A log cannot be created when processing saved data!
    CLEAR P_LOG.
  ENDIF.
*--0008 BG 2007.11.09

************************************************************************
START-OF-SELECTION.
************************************************************************

*++0002 BG 2006/11/29
*  IF P_BTYPE IS INITIAL.
*    CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
*         EXPORTING
*              I_BUKRS     = P_BUKRS
*              I_BTYPART   = P_BTYPAR
*              I_GJAHR     = P_GJAHR
*              I_MONAT     = P_MONAT
*         IMPORTING
*              E_BTYPE     = P_BTYPE
*         EXCEPTIONS
*              ERROR_MONAT = 1
*              ERROR_BTYPE = 2
*              OTHERS      = 3.
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*  ENDIF.


*++0006 BG 2007.03.26
  IF P_LOAD IS INITIAL.
    PERFORM PROCESS_LIVE_DATA.
  ELSE.
    PERFORM PROCESS_SAVE_DATA.
  ENDIF.
*--0006 BG 2007.03.26


************************************************************************
END-OF-SELECTION.
************************************************************************

*++0006 BG 2007.03.26
  PERFORM SAVE_DATA.

  IF SY-BATCH IS INITIAL.
    PERFORM LIST_DISPLAY.
  ENDIF.
*--0006 BG 2007.03.26


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
    IF SCREEN-GROUP1 = 'DIS' .
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      IF SCREEN-NAME = 'P_BTYPAR'.
        SCREEN-DISPLAY_3D = 1.
      ELSE.
        SCREEN-DISPLAY_3D = 0.
      ENDIF.

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


ENDFORM.                    "READ_ADDITIONALS
*&---------------------------------------------------------------------*
*&      Form  get_bevalli
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_GJAHR  text
*      -->P_P_MONATH  text
*----------------------------------------------------------------------*
FORM GET_BEVALLI TABLES $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
                        $I_EGYKORR     STRUCTURE /ZAK/EGYKORR
                        "++0004 20070222 FI
*++0002 BG 2006/11/29
                        $R_BTYPE  STRUCTURE R_BTYPE
*--0002 BG 2006/11/29
                USING    $BUKRS
                          $GJAHR
                          $MONAT
*++0002 BG 2006/11/29
*                         $BTYPE
*--0002 BG 2006/11/29
                          $SUBRC
                          .

  RANGES: R_DWNDT FOR /ZAK/BEVALLI-DWNDT. " Next period
*++0004 20070222 FI
  DATA: LS_BEVALLI  TYPE /ZAK/BEVALLI
       ,LS_EGYKORR  TYPE /ZAK/EGYKORR
        .
*--0004 20070222 FI


  DATA : L_BPER LIKE /ZAK/BEVALLI-DWNDT,
         L_EPER LIKE /ZAK/BEVALLI-DWNDT.
* Looks up the first and last day of the next month
  PERFORM GET_NEXT_DATE USING $GJAHR
                              $MONAT
                              L_BPER
                              L_EPER.
  R_DWNDT = 'IBT'.
  R_DWNDT-LOW = L_BPER.
  R_DWNDT-HIGH = L_EPER.
  APPEND R_DWNDT.
* Collects declarations posted after the period
  SELECT  * INTO  TABLE $I_/ZAK/BEVALLI
                  FROM /ZAK/BEVALLI
                  WHERE BUKRS  = $BUKRS
*++0002 BG 2006/11/29
*                  AND  BTYPE  = $BTYPE
                   AND  BTYPE  IN $R_BTYPE
*--0002 BG 2006/11/29
*                  AND  FLAG   = 'T'  "Ez lett feladva.
                   AND  DWNDT IN R_DWNDT.
  .
  IF SY-SUBRC <> 0.
    V_SUBRC = SY-SUBRC.
    EXIT.
  ENDIF.
*++0004 20070222 FI
*Need to run through BEVALLI and check whether data exists among the corrections
*among the corrections.
  LOOP AT $I_/ZAK/BEVALLI INTO LS_BEVALLI.
    SELECT SINGLE * FROM /ZAK/EGYKORR INTO LS_EGYKORR
                    WHERE BUKRS  = LS_BEVALLI-BUKRS
                     AND  BTYPE  = LS_BEVALLI-BTYPE
                     AND  GJAHR  = LS_BEVALLI-GJAHR
                     AND  MONAT  = LS_BEVALLI-MONAT
                     AND  ZINDEX = LS_BEVALLI-ZINDEX.
    IF SY-SUBRC = 0.
      APPEND LS_EGYKORR TO $I_EGYKORR.

    ENDIF.

  ENDLOOP.

*--0004 20070222 FI
ENDFORM . "get_bevalli
*&---------------------------------------------------------------------*
*&      Form  get_next_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$GJAHR  text
*      -->P_$MONATH  text
*      -->P_L_BPER  text
*      -->P_L_EPER  text
*----------------------------------------------------------------------*
FORM GET_NEXT_DATE USING    $GJAHR
                            $MONAT
                            $BPER
                            $EPER.

* Determine the start and end date of the next month
  DATA L_DATE LIKE SY-DATUM.
  DATA L_MONAT LIKE /ZAK/BEVALLI-MONAT.
  IF $MONAT > '12'.
    L_MONAT = '12'.
  ELSE.
    L_MONAT = $MONAT.
  ENDIF.
  CONCATENATE $GJAHR L_MONAT '01' INTO L_DATE.
* Jump to the next month
  L_DATE = L_DATE + 32.
* Determine the first day
  L_DATE+6(2) = '01'.
  $BPER = L_DATE.
* Determine the last day
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = L_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = $EPER
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.


ENDFORM.                    " get_next_date
*&---------------------------------------------------------------------*
*&      Form  GET_BEVALLO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALLI  text
*      -->P_I_/ZAK/BEVALLO  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_BEVALLO TABLES   $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
                          $I_/ZAK/BEVALLO STRUCTURE /ZAK/BEVALLO
*++0002 BG 2006/11/29
                          $R_BTYPE  STRUCTURE R_BTYPE
*--0002 BG 2006/11/29
                 USING    $BUKRS
*++0002 BG 2006/11/29
*                         $BTYPE
*--0002 BG 2006/11/29
                          $SUBRC.
  SELECT * INTO TABLE $I_/ZAK/BEVALLO
           FROM /ZAK/BEVALLO
           FOR ALL ENTRIES IN $I_/ZAK/BEVALLI
           WHERE BUKRS   = $BUKRS
*++0002 BG 2006/11/29
*           AND  BTYPE   = $BTYPE
            AND  BTYPE   = $I_/ZAK/BEVALLI-BTYPE
*--0002 BG 2006/11/29
            AND  GJAHR   = $I_/ZAK/BEVALLI-GJAHR
            AND  MONAT   = $I_/ZAK/BEVALLI-MONAT
            AND  ZINDEX  = $I_/ZAK/BEVALLI-ZINDEX.

  $SUBRC = SY-SUBRC.



ENDFORM.                    " GET_BEVALLO
*&---------------------------------------------------------------------*
*&      Form  GET_FOKONYV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALLO  text
*      -->P_I_FOKONYV  text
*----------------------------------------------------------------------*
FORM GET_FOKONYV TABLES   $I_/ZAK/BEVALLO STRUCTURE /ZAK/BEVALLO
                          $I_FOKONYV     STRUCTURE I_FOKONYV
*++0002 BG 2006/11/29
                          $R_BTYPE  STRUCTURE R_BTYPE
*--0002 BG 2006/11/29

                 USING
*++0002 BG 2006/11/29
*                         $BTYPE
*--0002 BG 2006/11/29
                          $SUBRC
                          .

  DATA : L_SAKNR LIKE SKA1-SAKNR. " Only needed to check emptiness
* Collects which ABEV identifiers were present in the filtered
* in the period
  R_ABEVAZ = 'IEQ'.
  LOOP AT $I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO .
    R_ABEVAZ-LOW = W_/ZAK/BEVALLO-ABEVAZ.
    APPEND R_ABEVAZ.
  ENDLOOP.
* Deletes duplicate items
  SORT R_ABEVAZ.
  DELETE ADJACENT DUPLICATES FROM R_ABEVAZ.

* Finds which G/L accounts and ABEV identifiers are needed.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
           WHERE
*++0002 BG 2006/11/29
*                BTYPE = $BTYPE
                 BTYPE IN R_BTYPE
*--0002 BG 2006/11/29
*++0003 BG 2006/12/06
*            AND ABEVAZ IN R_ABEVAZ
*--0003 BG 2006/12/06
             AND SAKNR <> L_SAKNR. " G/L account is not empty

* Assembles the G/L accounts.
  LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB.
    $I_FOKONYV-ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
    $I_FOKONYV-BTYPE  = W_/ZAK/BEVALLB-BTYPE.
    $I_FOKONYV-SAKNR  = W_/ZAK/BEVALLB-SAKNR.
    APPEND $I_FOKONYV.
  ENDLOOP.



ENDFORM.                    " GET_FOKONYV
*&---------------------------------------------------------------------*
*&      Form  feldolgoz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_ELL  text
*      -->P_I_/ZAK/BEVALLO  text
*      -->P_P_BUKRS  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM FELDOLGOZ TABLES   $I_FOKONYV STRUCTURE I_FOKONYV
                        $I_/ZAK/SZJA_ELL STRUCTURE /ZAK/SZJA_ELL
                        $I_/ZAK/BEVALLO  STRUCTURE /ZAK/BEVALLO
*++0003 BG 2006/12/06
                        $BLART STRUCTURE S_BLART
*--0003 BG 2006/12/06
               USING    $BUKRS
                        $GJAHR
                        $MONAT
                        $SUBRC.
  DATA L_SAKNR LIKE SKA1-SAKNR.
  DATA W_BSIS TYPE  BSIS.
  DATA I_BSIS TYPE STANDARD TABLE OF BSIS INITIAL SIZE 0.

*++0006 BG 2007.03.26
  DATA L_LINE    TYPE SY-TABIX.
  DATA L_PER_P   TYPE P DECIMALS 2.
  DATA L_PER_I   TYPE I.
*++0006 BG 2007.03.26


*++ 0005 FI
  DATA: LT_SZJA_ELL     TYPE TABLE OF /ZAK/SZJA_ELL
       ,LS_SZJA_ELL     TYPE          /ZAK/SZJA_ELL
       ,LS_SZJA_ELL_NEW TYPE          /ZAK/SZJA_ELL
       ,L_INDEX         LIKE SY-TABIX
       .
*-- 0005 FI
  CLEAR: W_/ZAK/SZJA_ELL.
  W_/ZAK/SZJA_ELL-BUKRS = $BUKRS.
  W_/ZAK/SZJA_ELL-GJAHR = $GJAHR.
  W_/ZAK/SZJA_ELL-MONAT = $MONAT.
  W_/ZAK/SZJA_ELL-WAERS = 'HUF'.


*++0006 BG 2007.03.26
  CLEAR V_GET_IDOSZ_FROM_BEVALLO.
*--0006 BG 2007.03.26


* Collects the balances
  SORT I_FOKONYV.

*++0006 BG 2007.03.26
  DESCRIBE TABLE $I_FOKONYV LINES L_LINE.
*--0006 BG 2007.03.26

  LOOP AT $I_FOKONYV.

*++0006 BG 2007.03.26
    L_PER_P = ( SY-TABIX / L_LINE ) * 100.
    L_PER_I = TRUNC( L_PER_P ).
*--0006 BG 2007.03.26


* If the G/L account changed, the balance must be retrieved
    IF W_/ZAK/SZJA_ELL-SAKNR <> $I_FOKONYV-SAKNR.

      W_/ZAK/SZJA_ELL-SAKNR = $I_FOKONYV-SAKNR.

      PERFORM GET_FOK_EGYENLEG
*++0003 BG 2006/12/06
                               TABLES $BLART
*--0003 BG 2006/12/06
                               USING  $BUKRS
                                      $GJAHR
                                      $MONAT
                                      $I_FOKONYV-SAKNR
                                      W_/ZAK/SZJA_ELL-FORGALOM
*++0003 BG 2006/12/06
                                      W_/ZAK/SZJA_ELL-FORGHROUT
                                      W_/ZAK/SZJA_ELL-FORGHR
*--0003 BG 2006/12/06
                                      .


    ELSE.
*   If the G/L account does not change, the balance must be cleared
*++0003 BG 2006/12/06
*     W_/ZAK/SZJA_ELL-FORGALOM = 0.
      CLEAR: W_/ZAK/SZJA_ELL-FORGALOM,
             W_/ZAK/SZJA_ELL-FORGHROUT,
             W_/ZAK/SZJA_ELL-FORGHR.
*--0003 BG 2006/12/06
    ENDIF.

    W_/ZAK/SZJA_ELL-ABEVAZ = $I_FOKONYV-ABEVAZ.
*++ 0005 FI
*    PERFORM GET_ABEV_EGYENLEG TABLES $I_/ZAK/BEVALLO
**++0004 20070222 FI
*                                      I_/ZAK/EGYKORR
**--0004 20070222 FI
*                              USING $I_FOKONYV-ABEVAZ
*                                    $I_FOKONYV-SAKNR
*                                    W_/ZAK/SZJA_ELL-ABEV_FORG
**++BG 2006/06/27
*                                    W_/ZAK/SZJA_ELL-ABEV_FORG000
*                                    W_/ZAK/SZJA_ELL-ABEV_FORG001
**--BG 2006/06/27
**++0004 20070222 FI
*                                    W_/ZAK/SZJA_ELL-EGYKORR
**--0004 20070222 FI
**++BG 2006/07/19
*                                    $BUKRS
**--BG 2006/07/19
*                                    .
    REFRESH LT_SZJA_ELL.
    PERFORM GET_ABEV_EGYENLEG TABLES $I_/ZAK/BEVALLO
                                      I_/ZAK/EGYKORR
                                      LT_SZJA_ELL
                              USING W_/ZAK/SZJA_ELL
                                    $I_FOKONYV-ABEVAZ
                                    $I_FOKONYV-SAKNR
                                    $I_FOKONYV-BTYPE
*                                    W_/ZAK/SZJA_ELL-ABEV_FORG
*                                    W_/ZAK/SZJA_ELL-ABEV_FORG000
*                                    W_/ZAK/SZJA_ELL-ABEV_FORG001
*                                    W_/ZAK/SZJA_ELL-EGYKORR
                                    $BUKRS
*++0006 BG 2007.03.26
                                    V_GET_IDOSZ_FROM_BEVALLO
*--0006 BG 2007.03.26
                                    .
*-- 0005 FI
*    W_/ZAK/SZJA_ELL-ELTERES = W_/ZAK/SZJA_ELL-FORGALOM -
*                             W_/ZAK/SZJA_ELL-ABEV_FORG.
*    PERFORM SET_KORREKCIO TABLES I_/ZAK/EGYKORR
*                          USING W_/ZAK/SZJA_ELL.
*++ 0005 FI
    LOOP AT LT_SZJA_ELL INTO LS_SZJA_ELL_NEW.
      READ TABLE I_/ZAK/SZJA_ELL INTO LS_SZJA_ELL WITH KEY BUKRS  =
      LS_SZJA_ELL-BUKRS
                                                          GJAHR  =
LS_SZJA_ELL-GJAHR
                                                          MONAT  =
LS_SZJA_ELL-MONAT
                                                          SAKNR  =
LS_SZJA_ELL-SAKNR
                                                          ABEVAZ =
LS_SZJA_ELL-ABEVAZ
                                                          .
      IF SY-SUBRC = 0.
        L_INDEX  = SY-TABIX.
        LS_SZJA_ELL_NEW-ABEV_FORG000 = LS_SZJA_ELL_NEW-ABEV_FORG000 +
        LS_SZJA_ELL-ABEV_FORG000.
        LS_SZJA_ELL_NEW-ABEV_FORG001 = LS_SZJA_ELL_NEW-ABEV_FORG001 +
        LS_SZJA_ELL-ABEV_FORG001.
        LS_SZJA_ELL_NEW-EGYKORR      = LS_SZJA_ELL_NEW-EGYKORR      +
        LS_SZJA_ELL-EGYKORR.
        MODIFY I_/ZAK/SZJA_ELL FROM LS_SZJA_ELL_NEW INDEX L_INDEX.
      ELSE.
*        APPEND W_/ZAK/SZJA_ELL TO I_/ZAK/SZJA_ELL.
        APPEND LS_SZJA_ELL_NEW TO I_/ZAK/SZJA_ELL.
      ENDIF.
    ENDLOOP.
*-- 0005 FI

*++0006 BG 2007.03.26
    PERFORM PROCESS_IND USING L_PER_I
                              TEXT-103
                              10.
*--0006 BG 2007.03.26

  ENDLOOP.

*++0006 BG 2007.04.23
*Reconciliation table aggregation (if multiple identical keys appear,
*sum them up)
  PERFORM COLLECT_SZJA_ELL TABLES I_/ZAK/SZJA_ELL.

*--0006 BG 2007.04.23

  PERFORM ELTERES_OSSZERAK TABLES I_/ZAK/SZJA_ELL.

*++0006 BG 2007.03.26
  SORT I_/ZAK/SZJA_ELL .
*--0006 BG 2007.03.26

ENDFORM.                    " feldolgoz
*&---------------------------------------------------------------------*
*&      Form  get_fok_egyenleg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$BUKRS  text
*      -->P_$GJAHR  text
*      -->P_$MONAT  text
*      -->P_$I_/ZAK/SZJA_ELL_FORGALOM  text
*----------------------------------------------------------------------*
FORM GET_FOK_EGYENLEG
*++0003 BG 2006/12/06
                      TABLES   $BLART STRUCTURE S_BLART
*--0003 BG 2006/12/06
                      USING    $BUKRS
                               $GJAHR
                               $MONAT
                               $SAKNR
                               $FORGALOM
*++0003 BG 2006/12/06
                               $FORGHROUT
                               $FORGHR
*--0003 BG 2006/12/06
                               .

  DATA W_BSIS TYPE  BSIS.
  DATA I_BSIS TYPE STANDARD TABLE OF BSIS INITIAL SIZE 0.
  CLEAR : $FORGALOM,
*++0003 BG 2006.12.13
          $FORGHROUT,
          $FORGHR.
*--0003 BG 2006.12.13

  R_MONAT = 'IEQ'.
  IF P_PERIOD = 'X' AND $MONAT = '12'.
    R_MONAT-LOW = '12'. APPEND R_MONAT.
    R_MONAT-LOW = '13'. APPEND R_MONAT.
    R_MONAT-LOW = '14'. APPEND R_MONAT.
    R_MONAT-LOW = '15'. APPEND R_MONAT.
    R_MONAT-LOW = '16'. APPEND R_MONAT.
  ELSE.

    R_MONAT-LOW = $MONAT. APPEND R_MONAT.

  ENDIF.

  SELECT * FROM BSIS
           INTO TABLE I_BSIS
           WHERE BUKRS = $BUKRS
            AND  HKONT = $SAKNR
            AND  GJAHR = $GJAHR
            AND  MONAT IN R_MONAT.
  SELECT * FROM BSAS
        APPENDING TABLE I_BSIS
          WHERE BUKRS = $BUKRS
           AND  HKONT = $SAKNR
           AND  GJAHR = $GJAHR
           AND  MONAT IN R_MONAT.
*  After filtering everything, collect the turnover

  LOOP AT I_BSIS INTO W_BSIS.
*++0003 BG 2006/12/06
*    IF W_BSIS-SHKZG = 'S'. "User requested it
*      $FORGALOM = $FORGALOM +  ( W_BSIS-DMBTR * -1 ).
*    ELSE.
*      $FORGALOM = $FORGALOM + W_BSIS-DMBTR .
*    ENDIF.
    IF W_BSIS-SHKZG = 'S'. "User requested it
      MULTIPLY W_BSIS-DMBTR BY -1.
    ENDIF.

    ADD W_BSIS-DMBTR TO $FORGALOM.

*   HR forgalom
    IF W_BSIS-BLART IN $BLART.
      ADD W_BSIS-DMBTR TO $FORGHR.
    ELSE.
      ADD W_BSIS-DMBTR TO $FORGHROUT.
    ENDIF.
*--0003 BG 2006/12/06
  ENDLOOP.



ENDFORM.                    " get_fok_egyenleg
*&---------------------------------------------------------------------*
*&      Form  get_abev_egyenleg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_/ZAK/BEVALLO  text
*      -->P_$I_FOKONYV_ABEVAZ  text
*      -->P_$I_FOKONYV_SAKNR  text
*      -->P_W_/ZAK/SZJA_ELL_ABEV_FORG  text
*----------------------------------------------------------------------*
FORM GET_ABEV_EGYENLEG TABLES   $I_/ZAK/BEVALLO STRUCTURE /ZAK/BEVALLO
                                $T_EGYKORR     STRUCTURE /ZAK/EGYKORR
                                "0004 20070222 FI
                                $T_SZJA_ELL    STRUCTURE /ZAK/SZJA_ELL
                       USING    $S_SZJA_ELL    STRUCTURE /ZAK/SZJA_ELL
                                $ABEVAZ
                                $SAKNR
                                $BTYPE
*                                $ABEV_FORG
*                                $ABEV_FORG000
*                                $ABEV_FORG001
*$_EGYKORR                            "0004 20070222 FI
                                $BUKRS
*++0006 BG 2007.03.26
                                $IDOSZ_FROM_BEVALLO
*--0006 BG 2007.03.26
                                .
*++0006 BG 2007.03.26
* Moved into global declaration
**++BG 2006/07/19
** For handling self-revision, during self-revision the ABEV
** subtract the previous period's value from the identifier based on the code
** for the same ABEV identifier value.
*  RANGES LR_BTYPE  FOR /ZAK/BEVALLO-BTYPE.
*  DATA: BEGIN OF LI_IDOSZ OCCURS 0,
*        GJAHR  TYPE GJAHR,
*        MONAT  TYPE MONAT,
*        ZINDEX TYPE /ZAK/INDEX,
*        END OF LI_IDOSZ.
*  DATA: BEGIN OF LI_ADOAZON OCCURS 0,
*        GJAHR   TYPE GJAHR,
*        MONAT   TYPE MONAT,
*        ZINDEX  TYPE /ZAK/INDEX,
*        ADOAZON TYPE /ZAK/ADOAZON,
*        END OF LI_ADOAZON.
*--0006 BG 2007.03.26

  DATA L_SUM_FIELD_N LIKE /ZAK/BEVALLO-FIELD_N.

  DATA: L_VOLT_KORR(1)
       ,LS_EGYKORR TYPE /ZAK/EGYKORR
       ,L_EGYKORR_IND LIKE  /ZAK/EGYKORR-ZINDEX " A tipusa NUMC
       ,L_BTYPE LIKE /ZAK/BEVALLI-BTYPE
       ,L_ABEVAZ_OLD LIKE /ZAK/BEVALLB-ABEVAZ
       ,L_BUKRS      LIKE /ZAK/BEVALLO-BUKRS
       ,L_VOLT_ABEVAZ(1)
       .

  DATA LW_IDOSZ LIKE LI_IDOSZ.

  DATA:  LS_SZJA_ELL      TYPE /ZAK/SZJA_ELL
        ,L_ABEVAZ_NEW     LIKE /ZAK/SZJA_ELL-ABEVAZ
        ,L_SZJA_ELL_INDEX LIKE SY-TABIX.
  .

*  CLEAR : $ABEV_FORG.
*  CLEAR : $ABEV_FORG000, $ABEV_FORG001
*         ,$_EGYKORR
*          .

*++0008 BG 2007.11.09
  DATA LW_BEVALLO_LOG TYPE /ZAK/BEVALLO.
*--0008 BG 2007.11.09

*++0006 BG 2007.03.26
  IF $IDOSZ_FROM_BEVALLO IS INITIAL.
*  If this is a self-revision period, populate the -1 period
*  because if it was posted with zero, we cannot find it under the ABEV code
*  meg:
    REFRESH : LR_BTYPE,
              LI_IDOSZ.
    CLEAR   : LR_BTYPE,
              LI_IDOSZ.

    REFRESH LI_ADOAZON.

    LOOP AT $I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO WHERE ZINDEX NE '000'.

*     Collect self-revision periods
      M_DEF LR_BTYPE 'I' 'EQ' W_/ZAK/BEVALLO-BTYPE SPACE.
*     M_DEF LR_GJAHR 'I' 'EQ' W_/ZAK/BEVALLO-GJAHR SPACE.
      CLEAR LI_IDOSZ.
      MOVE W_/ZAK/BEVALLO-GJAHR TO LI_IDOSZ-GJAHR.
*     M_DEF LR_MONAT 'I' 'EQ' W_/ZAK/BEVALLO-MONAT SPACE.
      MOVE W_/ZAK/BEVALLO-MONAT TO LI_IDOSZ-MONAT.
      MOVE W_/ZAK/BEVALLO-ZINDEX TO LI_IDOSZ-ZINDEX.

      SUBTRACT 1 FROM LI_IDOSZ-ZINDEX.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = LI_IDOSZ-ZINDEX
        IMPORTING
          OUTPUT = LI_IDOSZ-ZINDEX.
      COLLECT LI_IDOSZ.
*     M_DEF LR_ADOAZON 'I' 'EQ' W_/ZAK/BEVALLO-ADOAZON SPACE.
      CLEAR LI_ADOAZON.
      MOVE W_/ZAK/BEVALLO-GJAHR   TO LI_ADOAZON-GJAHR.
      MOVE W_/ZAK/BEVALLO-MONAT   TO LI_ADOAZON-MONAT.
      MOVE LI_IDOSZ-ZINDEX       TO LI_ADOAZON-ZINDEX.
      MOVE W_/ZAK/BEVALLO-ADOAZON TO LI_ADOAZON-ADOAZON.
      COLLECT LI_ADOAZON.
    ENDLOOP.

    MOVE 'X' TO $IDOSZ_FROM_BEVALLO.

  ENDIF.
*--0006 BG 2007.03.26

  CLEAR L_VOLT_ABEVAZ.

  LOOP AT $I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO
                         WHERE ABEVAZ = $ABEVAZ
                          AND  BTYPE  = $BTYPE
                           .


    L_VOLT_ABEVAZ = 'X'.
*++0006 BG 2007.04.23
*We do not always display it under the ABEV identifier on which
*bevallottuk
*Previous ABEV codes must be matched to the current ABEV codes,
*if it is configured
*    PERFORM GET_AKT_ABEVAZ USING W_/ZAK/BEVALLO-BUKRS
*                                 W_/ZAK/BEVALLO-BTYPE
*                                 P_GJAHR
*                                 P_MONAT
*                                 $ABEVAZ
*                        CHANGING L_ABEVAZ_NEW
    MOVE $ABEVAZ TO L_ABEVAZ_NEW.
*--0006 BG 2007.04.23

*   Check whether the given OLD/NEW ABEV identifier row already exists
    READ TABLE $T_SZJA_ELL INTO LS_SZJA_ELL WITH KEY BUKRS  =
    $S_SZJA_ELL-BUKRS
                                                     GJAHR  =
                                                     $S_SZJA_ELL-GJAHR
                                                     MONAT  =
                                                     $S_SZJA_ELL-MONAT
                                                     SAKNR  =
                                                     $S_SZJA_ELL-SAKNR
                                                     ABEVAZ =
                                                     L_ABEVAZ_NEW
                                                     .
    IF SY-SUBRC <> 0.
*     If there is no collected row yet, take over the initial row.
      L_SZJA_ELL_INDEX = 0.

      LS_SZJA_ELL = $S_SZJA_ELL.
      LS_SZJA_ELL-ABEVAZ = L_ABEVAZ_NEW.
    ELSE.
      L_SZJA_ELL_INDEX = SY-TABIX.
    ENDIF.

*   Check whether the declaration row appears among the corrections.
    READ TABLE $T_EGYKORR TRANSPORTING NO FIELDS
                          WITH KEY
                          BUKRS  = W_/ZAK/BEVALLO-BUKRS
                          BTYPE  = W_/ZAK/BEVALLO-BTYPE
                          GJAHR  = W_/ZAK/BEVALLO-GJAHR
                          MONAT  = W_/ZAK/BEVALLO-MONAT
                          ZINDEX = W_/ZAK/BEVALLO-ZINDEX
                          .
    IF SY-SUBRC = 0.
      L_VOLT_KORR = 'X'.
    ELSE.
      L_VOLT_KORR = ' '.
    ENDIF.
    IF W_/ZAK/BEVALLO-ZINDEX EQ '000'.
      LS_SZJA_ELL-ABEV_FORG000 = LS_SZJA_ELL-ABEV_FORG000 +
      W_/ZAK/BEVALLO-FIELD_N.
*++0008 BG 2007.11.09
      PERFORM GET_ELL_LOG USING W_/ZAK/BEVALLO
                                $SAKNR
                                'ABEV_FORG000'
                                '+'.
*--0008 BG 2007.11.09
    ELSE.
*     Sum the self-revision rows
      IF L_VOLT_KORR = 'X'.
        LS_SZJA_ELL-EGYKORR       = LS_SZJA_ELL-EGYKORR     +
        W_/ZAK/BEVALLO-FIELD_N.
      ELSE.
        LS_SZJA_ELL-ABEV_FORG001 = LS_SZJA_ELL-ABEV_FORG001 +
        W_/ZAK/BEVALLO-FIELD_N.
*++0008 BG 2007.11.09
        PERFORM GET_ELL_LOG USING W_/ZAK/BEVALLO
                                  $SAKNR
                                  'ABEV_FORG001'
                                  '+'.
*--0008 BG 2007.11.09

      ENDIF.

*++0006 BG 2007.03.26
**     Collect self-revision periods
*      M_DEF LR_BTYPE 'I' 'EQ' W_/ZAK/BEVALLO-BTYPE SPACE.
*      CLEAR LI_IDOSZ.
*      MOVE W_/ZAK/BEVALLO-GJAHR TO LI_IDOSZ-GJAHR.
*      MOVE W_/ZAK/BEVALLO-MONAT TO LI_IDOSZ-MONAT.
*
*      SUBTRACT 1 FROM W_/ZAK/BEVALLO-ZINDEX.
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT  = W_/ZAK/BEVALLO-ZINDEX
*        IMPORTING
*          OUTPUT = W_/ZAK/BEVALLO-ZINDEX.
*      MOVE W_/ZAK/BEVALLO-ZINDEX TO LI_IDOSZ-ZINDEX.
*      COLLECT LI_IDOSZ.
*      CLEAR LI_ADOAZON.
**     Stores which declarations existed in the previous period because
*ezeket
**     must be subtracted from all declarations
*      MOVE W_/ZAK/BEVALLO-GJAHR   TO LI_ADOAZON-GJAHR.
*      MOVE W_/ZAK/BEVALLO-MONAT   TO LI_ADOAZON-MONAT.
*      MOVE W_/ZAK/BEVALLO-ZINDEX  TO LI_ADOAZON-ZINDEX.
*      MOVE W_/ZAK/BEVALLO-ADOAZON TO LI_ADOAZON-ADOAZON.
*      COLLECT LI_ADOAZON.
*--0006 BG 2007.03.26
    ENDIF.
*   Elteszi a sort
    IF L_SZJA_ELL_INDEX = 0.
      APPEND LS_SZJA_ELL TO $T_SZJA_ELL.
    ELSE.
      MODIFY $T_SZJA_ELL FROM LS_SZJA_ELL INDEX L_SZJA_ELL_INDEX.
    ENDIF.
  ENDLOOP.



* Save the row even if no ABEV identifier was found
  IF L_VOLT_ABEVAZ IS INITIAL.
    APPEND $S_SZJA_ELL TO $T_SZJA_ELL.
    EXIT.
  ENDIF.

*++0006 BG 2007.03.26
** Handle self-revision periods if data existed
**  CHECK NOT ls_szja_ell-ABEV_FORG001 IS INITIAL OR
**        NOT ls_szja_ell-EGYKORR     IS INITIAL
**            .
*  LOOP AT $T_SZJA_ELL TRANSPORTING NO FIELDS
*                      WHERE NOT ABEV_FORG001 IS INITIAL OR
*                            NOT EGYKORR      IS INITIAL
*                            .
*  ENDLOOP.
*  CHECK SY-SUBRC = 0.
  CHECK NOT LI_IDOSZ[] IS INITIAL.
*--0006 BG 2007.03.26

  CLEAR L_SUM_FIELD_N.

  LOOP AT LI_IDOSZ.
*  Determine the original index for the correction and the
    L_EGYKORR_IND = LI_IDOSZ-ZINDEX + 1.
    LOOP AT LI_ADOAZON WHERE GJAHR  EQ LI_IDOSZ-GJAHR
                         AND MONAT  EQ LI_IDOSZ-MONAT
                         AND ZINDEX EQ LI_IDOSZ-ZINDEX.

*++0007 BG 2007.07.24
*   If it is among the not-found entries, no processing is needed:
      READ TABLE LI_ADOAZON_NOTFOUND WITH KEY
                         BTYPE   = $BTYPE
                         GJAHR   = LI_ADOAZON-GJAHR
                         MONAT   = LI_ADOAZON-MONAT
                         ZINDEX  = LI_ADOAZON-ZINDEX
                         ADOAZON = LI_ADOAZON-ADOAZON
                         BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        CONTINUE.
      ENDIF.
*--0007 BG 2007.07.24


      LW_IDOSZ = LI_IDOSZ.

      DO.
        CLEAR L_SUM_FIELD_N.
*++0006 BG 2007.03.26
*       Determine whether there is posting in the searched period
*       on the tax number, because if there is, we consider it even if it is zero.
        SELECT  COUNT( * )    FROM /ZAK/BEVALLO
                                UP TO 1 ROWS
                          WHERE BUKRS EQ $BUKRS
*++0006 BG 2007.04.23
*                           AND BTYPE IN LR_BTYPE
                            AND BTYPE EQ $BTYPE
*--0006 BG 2007.04.23
                            AND GJAHR  = LW_IDOSZ-GJAHR
                            AND MONAT  = LW_IDOSZ-MONAT
                            AND ZINDEX = LW_IDOSZ-ZINDEX
                            AND ADOAZON EQ LI_ADOAZON-ADOAZON.
        IF SY-SUBRC EQ 0.
*--0006 BG 2007.03.26
          SELECT SINGLE BUKRS
                        FIELD_N
                        BTYPE
                        ABEVAZ
                        INTO (L_BUKRS, L_SUM_FIELD_N, L_BTYPE,
                        L_ABEVAZ_OLD)
                                FROM /ZAK/BEVALLO
                               WHERE BUKRS EQ $BUKRS
*++0006 BG 2007.04.23
*                                AND BTYPE IN LR_BTYPE
                                 AND BTYPE EQ $BTYPE
*--0006 BG 2007.04.23
                                 AND GJAHR  = LW_IDOSZ-GJAHR
                                 AND MONAT  = LW_IDOSZ-MONAT
                                 AND ZINDEX = LW_IDOSZ-ZINDEX
                                 AND ABEVAZ EQ $ABEVAZ
                                 AND ADOAZON EQ LI_ADOAZON-ADOAZON.
*++0008 BG 2007.11.09
          CLEAR LW_BEVALLO_LOG.
          MOVE $BUKRS TO LW_BEVALLO_LOG-BUKRS.
          MOVE $ABEVAZ TO LW_BEVALLO_LOG-ABEVAZ.
          MOVE $BTYPE TO LW_BEVALLO_LOG-BTYPE.
          MOVE LW_IDOSZ-GJAHR TO LW_BEVALLO_LOG-GJAHR.
          MOVE LW_IDOSZ-MONAT TO LW_BEVALLO_LOG-MONAT.
          MOVE LW_IDOSZ-ZINDEX TO LW_BEVALLO_LOG-ZINDEX.
          MOVE LI_ADOAZON-ADOAZON TO LW_BEVALLO_LOG-ADOAZON.
          MOVE 'HUF' TO LW_BEVALLO_LOG-WAERS.
          MOVE L_SUM_FIELD_N TO LW_BEVALLO_LOG-FIELD_N.
*--0008 BG 2007.11.09


*++BG 2007.04.23
*We do not always convert to the ABEV identifier that matches the declaration
*mutatjuk
**         Search for new ABEVAZ if available
*          PERFORM GET_AKT_ABEVAZ USING L_BUKRS
*                                       L_BTYPE
*                                       P_GJAHR
*                                       P_MONAT
*                                       $ABEVAZ
*                              CHANGING L_ABEVAZ_NEW
*                                       .
          MOVE $ABEVAZ TO L_ABEVAZ_NEW.
*--BG 2007.04.23

*         Check whether the given OLD/NEW ABEV identifier row exists
          READ TABLE $T_SZJA_ELL INTO LS_SZJA_ELL WITH KEY BUKRS  =
          $S_SZJA_ELL-BUKRS
                                                           GJAHR  =
$S_SZJA_ELL-GJAHR
                                                           MONAT  =
$S_SZJA_ELL-MONAT
                                                           SAKNR  =
$S_SZJA_ELL-SAKNR
                                                           ABEVAZ =
                                                           L_ABEVAZ_NEW
                                                           .
*++BG 2007.04.18
*         IF SY-SUBRC <> 0.
*           CONTINUE.
*         ENDIF.
*
*         L_SZJA_ELL_INDEX = SY-TABIX.
*
*         IF SY-SUBRC EQ 0 OR LW_IDOSZ-ZINDEX EQ '000'.
          IF SY-SUBRC EQ 0.
            L_SZJA_ELL_INDEX = SY-TABIX.
*--BG 2007.04.18
*   Check whether the declaration row appears among the corrections.
            READ TABLE $T_EGYKORR INTO LS_EGYKORR
                                  WITH KEY
                                  BUKRS  = $BUKRS
*                                 BTYPE  IN LR_BTYPE
                                  GJAHR  = LW_IDOSZ-GJAHR
                                  MONAT  = LW_IDOSZ-MONAT
                                  ZINDEX = L_EGYKORR_IND
                                  .
*If a correction declaration is found and its sequence number is lower then
*the correction must also be reduced
            IF SY-SUBRC = 0 AND LW_IDOSZ-ZINDEX < LS_EGYKORR-ZINDEX.
              L_VOLT_KORR = 'X'.
            ELSE.
              L_VOLT_KORR = ' '.
            ENDIF.
            IF L_VOLT_KORR = 'X'.
              LS_SZJA_ELL-EGYKORR = LS_SZJA_ELL-EGYKORR - L_SUM_FIELD_N.
            ELSE.
              LS_SZJA_ELL-ABEV_FORG001 = LS_SZJA_ELL-ABEV_FORG001 -
              L_SUM_FIELD_N.
*++0008 BG 2007.11.09
              PERFORM GET_ELL_LOG USING LW_BEVALLO_LOG
                                        $SAKNR
                                        'ABEV_FORG001'
                                        '-'.
*--0008 BG 2007.11.09
            ENDIF.
            MODIFY $T_SZJA_ELL FROM LS_SZJA_ELL INDEX L_SZJA_ELL_INDEX.
            EXIT.
          ELSE.
*         Check whether the declaration row appears among the corrections.
            READ TABLE $T_EGYKORR INTO LS_EGYKORR
                                  WITH KEY
                                  BUKRS  = $BUKRS
*                                 BTYPE  IN LR_BTYPE
                                  GJAHR  = LW_IDOSZ-GJAHR
                                  MONAT  = LW_IDOSZ-MONAT
                                  ZINDEX = L_EGYKORR_IND
                                  .
*If a correction declaration is found and its sequence number is lower then
*the correction must also be reduced
            IF SY-SUBRC = 0 AND LW_IDOSZ-ZINDEX < LS_EGYKORR-ZINDEX..
              L_VOLT_KORR = 'X'.
            ELSE.
              L_VOLT_KORR = ' '.
            ENDIF.
            IF L_VOLT_KORR = 'X'.
              LS_SZJA_ELL-EGYKORR = LS_SZJA_ELL-EGYKORR - L_SUM_FIELD_N.
            ELSE.
              LS_SZJA_ELL-ABEV_FORG001 = LS_SZJA_ELL-ABEV_FORG001 -
              L_SUM_FIELD_N.
*++0008 BG 2007.11.09
              PERFORM GET_ELL_LOG USING LW_BEVALLO_LOG
                                        $SAKNR
                                        'ABEV_FORG001'
                                        '-'.
*--0008 BG 2007.11.09
            ENDIF.
*++0006 BG 2007.03.26
*          SUBTRACT 1 FROM LW_IDOSZ-ZINDEX.
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              INPUT  = LW_IDOSZ-ZINDEX
*            IMPORTING
*              OUTPUT = LW_IDOSZ-ZINDEX.
*--0006 BG 2007.03.26
            MODIFY $T_SZJA_ELL FROM LS_SZJA_ELL INDEX L_SZJA_ELL_INDEX.
          ENDIF.
*++0006 BG 2007.03.26
          EXIT.
*--0006 BG 2007.03.26
*++0006 BG 2007.03.26
        ELSE.
          SUBTRACT 1 FROM LW_IDOSZ-ZINDEX.
*         Due to an infinite loop:
          IF LW_IDOSZ-ZINDEX < 0.
*++0007 BG 2007.07.24
*           Add it to the not-found list:
            CLEAR LI_ADOAZON_NOTFOUND.
            MOVE-CORRESPONDING LI_ADOAZON TO LI_ADOAZON_NOTFOUND.
            MOVE $BTYPE TO LI_ADOAZON_NOTFOUND-BTYPE.
            APPEND LI_ADOAZON_NOTFOUND.
            SORT LI_ADOAZON_NOTFOUND.
*--0007 BG 2007.07.24
            EXIT.
          ENDIF.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = LW_IDOSZ-ZINDEX
            IMPORTING
              OUTPUT = LW_IDOSZ-ZINDEX.
        ENDIF.
*--0006 BG 2007.03.26
      ENDDO.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " get_abev_egyenleg
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
*++0006 BG 2007.03.26
  SORT I_/ZAK/SZJA_ELL .
*--0006 BG 2007.03.26

  CALL SCREEN 9001.


ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  PERFORM SET_STATUS.

  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_/ZAK/SZJA_ELL[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.



ENDMODULE.                 " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
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

  DATA: TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
        WA_TAB TYPE TAB_TYPE.

  IF SY-DYNNR = '9001'.
    SET TITLEBAR 'MAIN9001'.
    SET PF-STATUS 'MAIN9001'.
  ENDIF.


ENDFORM.                    " SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/SZJA_ELL[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING $I_/ZAK/SZJA_ELL LIKE
                                                    I_/ZAK/SZJA_ELL[]
                                  $FIELDCAT TYPE LVC_T_FCAT
                                  $LAYOUT   TYPE LVC_S_LAYO
                                  $VARIANT  TYPE DISVARIANT.
  DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
         EXPORTING CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
         EXPORTING I_PARENT = V_CUSTOM_CONTAINER.

* Assemble field catalog
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
      IT_OUTTAB            = $I_/ZAK/SZJA_ELL.

*   CREATE OBJECT V_EVENT_RECEIVER.
*   SET HANDLER V_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK  FOR V_GRID.

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


  IF $DYNNR = '9001'.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = '/ZAK/SZJA_ELL'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = $FIELDCAT.

  ENDIF.
ENDFORM.                    "BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.
* Exit
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      PERFORM EXIT_PROGRAM.

    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM.
*   LEAVE PROGRAM.
  LEAVE TO SCREEN 0.
ENDFORM.                    " EXIT_PROGRAM

*&---------------------------------------------------------------------*
*&      Form  elteres_osszerak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_ELL  text
*----------------------------------------------------------------------*
FORM ELTERES_OSSZERAK TABLES $I_/ZAK/SZJA_ELL STRUCTURE /ZAK/SZJA_ELL.

  DATA: L_IND LIKE SY-TABIX.
  SORT $I_/ZAK/SZJA_ELL.

  LOOP AT $I_/ZAK/SZJA_ELL INTO W_/ZAK/SZJA_ELL.
    L_IND = SY-TABIX.
*++BG 2006/07/19
*  Determine ABEV_FORG
    $I_/ZAK/SZJA_ELL-ABEV_FORG =  W_/ZAK/SZJA_ELL-ABEV_FORG000 +
*++0004 20070222 FI
                                 W_/ZAK/SZJA_ELL-EGYKORR +
*--0004 20070222 FI
                                W_/ZAK/SZJA_ELL-ABEV_FORG001.
    MODIFY $I_/ZAK/SZJA_ELL TRANSPORTING ABEV_FORG.
*--BG 2006/07/19
*++BG 2006/08/09
*   AT NEW SAKNR.
    AT END OF SAKNR.
*--BG 2006/08/09
      SUM.
      $I_/ZAK/SZJA_ELL-ELTERES = W_/ZAK/SZJA_ELL-FORGALOM -
                                W_/ZAK/SZJA_ELL-ABEV_FORG.
*++0003 BG 2006/12/06
      $I_/ZAK/SZJA_ELL-ELTERHR = W_/ZAK/SZJA_ELL-FORGHROUT -
                                W_/ZAK/SZJA_ELL-ABEV_FORG.
*--0003 BG 2006/12/06

      MODIFY $I_/ZAK/SZJA_ELL  INDEX L_IND
*++0003 BG 2006/12/06
*                             TRANSPORTING ELTERES.
                              TRANSPORTING ELTERES ELTERHR.

*--0003 BG 2006/12/06
    ENDAT.
  ENDLOOP.

ENDFORM.                    " elteres_osszerak
*&---------------------------------------------------------------------*
*&      Form  P_PERIOD_ell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PERIOD  text
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
FORM P_PERIOD_ELL USING    $PERIOD
                           $MONAT.
  IF P_PERIOD = 'X' AND $MONAT <> '12'.
    MESSAGE E166.
  ENDIF.
ENDFORM.                    " P_PERIOD_ell
*&---------------------------------------------------------------------*
*&      Form  get_akt_abevaz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_BTYPE  text
*      -->P_GJAHR  text
*      -->P_MONAT  text
*      <--P_ABEVAZ  text
*----------------------------------------------------------------------*
FORM GET_AKT_ABEVAZ  USING    $_BUKRS
                              $_BTYPE
                              $_GJAHR
                              $_MONAT
                              $_ABEVAZ
                     CHANGING $_ABEVAZ_NEW.
  DATA : LI_ABEV_CONTACT TYPE STANDARD TABLE OF /ZAK/ABEVCONTACT
        ,LS_ABEV_CONTACT TYPE                   /ZAK/ABEVCONTACT
         .
*  Determine the appropriate ABEV
  CALL FUNCTION '/ZAK/ABEV_CONTACT'
    EXPORTING
      I_BUKRS        = $_BUKRS
      I_BTYPE        = $_BTYPE
      I_ABEVAZ       = $_ABEVAZ
      I_GJAHR        = $_GJAHR
      I_MONAT        = $_MONAT
    TABLES
      T_ABEV_CONTACT = LI_ABEV_CONTACT
    EXCEPTIONS
      ERROR_BTYPE    = 1
      ERROR_MONAT    = 2
      ERROR_ABEVAZ   = 3
      OTHERS         = 4.
  IF SY-SUBRC EQ 0.
    DESCRIBE TABLE LI_ABEV_CONTACT LINES SY-TFILL.
    READ TABLE LI_ABEV_CONTACT INTO LS_ABEV_CONTACT INDEX SY-TFILL.
    IF SY-SUBRC = 0.
      $_ABEVAZ_NEW = LS_ABEV_CONTACT-ABEVAZ.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_akt_abevaz


*&---------------------------------------------------------------------*
*&      Form  get_abev_egyenleg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_/ZAK/BEVALLO  text
*      -->P_$I_FOKONYV_ABEVAZ  text
*      -->P_$I_FOKONYV_SAKNR  text
*      -->P_W_/ZAK/SZJA_ELL_ABEV_FORG  text
*----------------------------------------------------------------------*
FORM GET_ABEV_EGYENLEG_OLD TABLES   $I_/ZAK/BEVALLO STRUCTURE /ZAK/BEVALLO
                                $T_EGYKORR     STRUCTURE /ZAK/EGYKORR
                                "0004 20070222 FI
                       USING    $ABEVAZ
                                $SAKNR
                                $ABEV_FORG
                                $ABEV_FORG000
                                $ABEV_FORG001
                                $_EGYKORR
                                "0004 20070222 FI
                                $BUKRS.

*++BG 2006/07/19
* For handling self-revision, during self-revision the ABEV
* subtract the previous period's value from the identifier based on the code
* for the same ABEV identifier value.
  RANGES LR_BTYPE  FOR /ZAK/BEVALLO-BTYPE.
*++BG 2006/12/06
*  RANGES LR_GJAHR  FOR /ZAK/BEVALLO-GJAHR.
*  RANGES LR_MONAT  FOR /ZAK/BEVALLO-MONAT.
*  RANGES LR_ZINDEX FOR /ZAK/BEVALLO-ZINDEX.
  DATA: BEGIN OF LI_IDOSZ OCCURS 0,
        GJAHR  TYPE GJAHR,
        MONAT  TYPE MONAT,
        ZINDEX TYPE /ZAK/INDEX,
        END OF LI_IDOSZ.

*--BG 2006/12/06
*++BG 2006.12.28
*  RANGES LR_ADOAZON FOR /ZAK/BEVALLO-ADOAZON.
  DATA: BEGIN OF LI_ADOAZON OCCURS 0,
        GJAHR   TYPE GJAHR,
        MONAT   TYPE MONAT,
        ZINDEX  TYPE /ZAK/INDEX,
        ADOAZON TYPE /ZAK/ADOAZON,
        END OF LI_ADOAZON.
*--BG 2006.12.28
  DATA L_SUM_FIELD_N LIKE /ZAK/BEVALLO-FIELD_N.
*--BG 2006/07/19

*++0004 20070222 FI
  DATA: L_VOLT_KORR(1)
       ,LS_EGYKORR TYPE /ZAK/EGYKORR
       ,L_EGYKORR_IND LIKE  /ZAK/EGYKORR-ZINDEX " A tipusa NUMC
       .
*--0004 20070222 FI

*++ BG 2007.01.24
  DATA LW_IDOSZ LIKE LI_IDOSZ.
*-- BG 2007.01.24


  CLEAR : $ABEV_FORG.
*++BG 2006/06/27
  CLEAR : $ABEV_FORG000, $ABEV_FORG001
         ,$_EGYKORR                            "0004 20070222 FI
          .
*--BG 2006/06/27
*++BG 2006/07/19
  REFRESH : LR_BTYPE,
*                    LR_GJAHR, LR_MONAT, LR_ZINDEX.
            LI_IDOSZ.
  CLEAR   : LR_BTYPE,
*                   LR_GJAHR, LR_MONAT, LR_ZINDEX.
            LI_IDOSZ.
*--BG 2006/07/19

*++BG 2006.12.28
  REFRESH LI_ADOAZON.
*  BG 2006.12.28

  LOOP AT $I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO
                         WHERE ABEVAZ = $ABEVAZ
                           .
*++BG 2006/07/19
*    $ABEV_FORG = $ABEV_FORG + W_/ZAK/BEVALLO-FIELD_N.
*--BG 2006/07/19
*++0004 20070222 FI
*   Check whether the declaration row appears among the corrections.
    READ TABLE $T_EGYKORR TRANSPORTING NO FIELDS
                          WITH KEY
                          BUKRS  = W_/ZAK/BEVALLO-BUKRS
                          BTYPE  = W_/ZAK/BEVALLO-BTYPE
                          GJAHR  = W_/ZAK/BEVALLO-GJAHR
                          MONAT  = W_/ZAK/BEVALLO-MONAT
                          ZINDEX = W_/ZAK/BEVALLO-ZINDEX
                          .
    IF SY-SUBRC = 0.
      L_VOLT_KORR = 'X'.
    ELSE.
      L_VOLT_KORR = ' '.
    ENDIF.
*--0004 20070222 FI
*++BG 2006/06/27
    IF W_/ZAK/BEVALLO-ZINDEX EQ '000'.
      $ABEV_FORG000 = $ABEV_FORG000 + W_/ZAK/BEVALLO-FIELD_N.
    ELSE.
*     Sum the self-revision rows
      IF L_VOLT_KORR = 'X'.
        $_EGYKORR = $_EGYKORR + W_/ZAK/BEVALLO-FIELD_N.
      ELSE.
        $ABEV_FORG001 = $ABEV_FORG001 + W_/ZAK/BEVALLO-FIELD_N.
      ENDIF.
*++BG 2006/07/19
*     Collect self-revision periods
      M_DEF LR_BTYPE 'I' 'EQ' W_/ZAK/BEVALLO-BTYPE SPACE.
*     M_DEF LR_GJAHR 'I' 'EQ' W_/ZAK/BEVALLO-GJAHR SPACE.
      CLEAR LI_IDOSZ.
      MOVE W_/ZAK/BEVALLO-GJAHR TO LI_IDOSZ-GJAHR.
*     M_DEF LR_MONAT 'I' 'EQ' W_/ZAK/BEVALLO-MONAT SPACE.
      MOVE W_/ZAK/BEVALLO-MONAT TO LI_IDOSZ-MONAT.

      SUBTRACT 1 FROM W_/ZAK/BEVALLO-ZINDEX.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = W_/ZAK/BEVALLO-ZINDEX
        IMPORTING
          OUTPUT = W_/ZAK/BEVALLO-ZINDEX.
*     M_DEF LR_ZINDEX 'I' 'EQ' W_/ZAK/BEVALLO-ZINDEX SPACE.
      MOVE W_/ZAK/BEVALLO-ZINDEX TO LI_IDOSZ-ZINDEX.
      COLLECT LI_IDOSZ.
*++BG 2006.12.28
*     M_DEF LR_ADOAZON 'I' 'EQ' W_/ZAK/BEVALLO-ADOAZON SPACE.
      CLEAR LI_ADOAZON.
*Stores which declarations existed in the previous period because these
*     must be subtracted from all declarations
      MOVE W_/ZAK/BEVALLO-GJAHR   TO LI_ADOAZON-GJAHR.
      MOVE W_/ZAK/BEVALLO-MONAT   TO LI_ADOAZON-MONAT.
      MOVE W_/ZAK/BEVALLO-ZINDEX  TO LI_ADOAZON-ZINDEX.
      MOVE W_/ZAK/BEVALLO-ADOAZON TO LI_ADOAZON-ADOAZON.
      COLLECT LI_ADOAZON.
*--BG 2006.12.28
*--BG 2006/07/19
    ENDIF.
*--BG 2006/06/27
  ENDLOOP.

*++BG 2006/07/19
* Handle self-revision periods if data existed
  CHECK NOT $ABEV_FORG001 IS INITIAL OR
*++0004 20070222 FI
        NOT $_EGYKORR     IS INITIAL
            .
*--0004 20070222 FI

  CLEAR L_SUM_FIELD_N.

  LOOP AT LI_IDOSZ.
*++0004 20070222 FI
*  Determine the original index for the correction and the
    L_EGYKORR_IND = LI_IDOSZ-ZINDEX + 1.
*--0004 20070222 FI
*++BG 2006.12.20
*++BG 2006.12.28
*   LOOP AT LR_ADOAZON.
    LOOP AT LI_ADOAZON WHERE GJAHR  EQ LI_IDOSZ-GJAHR
                         AND MONAT  EQ LI_IDOSZ-MONAT
                         AND ZINDEX EQ LI_IDOSZ-ZINDEX.

*++ BG 2007.01.24
      LW_IDOSZ = LI_IDOSZ.
*-- BG 2007.01.24

*--BG 2006.12.28
      DO.
*--BG 2006.12.20
        CLEAR L_SUM_FIELD_N.
*++BG 2006.12.28
*       SELECT SUM( FIELD_N ) INTO L_SUM_FIELD_N
        SELECT SINGLE FIELD_N  INTO L_SUM_FIELD_N
*  BG 2006.12.28
                              FROM /ZAK/BEVALLO
                             WHERE BUKRS EQ $BUKRS
                               AND BTYPE IN LR_BTYPE
*++ BG 2007.01.24
*                              AND GJAHR = LI_IDOSZ-GJAHR
*                              AND MONAT = LI_IDOSZ-MONAT
*                              AND ZINDEX = LI_IDOSZ-ZINDEX
                               AND GJAHR  = LW_IDOSZ-GJAHR
                               AND MONAT  = LW_IDOSZ-MONAT
                               AND ZINDEX = LW_IDOSZ-ZINDEX
*-- BG 2007.01.24


                               AND ABEVAZ EQ $ABEVAZ
*++BG 2006.12.20
*                              AND ADOAZON IN LR_ADOAZON.
                               AND ADOAZON EQ LI_ADOAZON-ADOAZON.
*--BG 2006.12.20

*++ BG 2007.01.24
*       IF SY-SUBRC EQ 0 OR LI_IDOSZ-ZINDEX EQ '000'.
        IF SY-SUBRC EQ 0 OR LW_IDOSZ-ZINDEX EQ '000'.
*-- BG 2007.01.24
*++0004 20070222 FI
*          $ABEV_FORG001 = $ABEV_FORG001 - L_SUM_FIELD_N.
*--0004 20070222 FI
*++0004 20070222 FI
*   Check whether the declaration row appears among the corrections.
          READ TABLE $T_EGYKORR INTO LS_EGYKORR
                                WITH KEY
                                BUKRS  = $BUKRS
*                              BTYPE  IN LR_BTYPE
                                GJAHR  = LW_IDOSZ-GJAHR
                                MONAT  = LW_IDOSZ-MONAT
                                ZINDEX = L_EGYKORR_IND
                                .
*If a correction declaration is found and its sequence number is lower then
*the correction must also be reduced
          IF SY-SUBRC = 0 AND LW_IDOSZ-ZINDEX < LS_EGYKORR-ZINDEX.
            L_VOLT_KORR = 'X'.
          ELSE.
            L_VOLT_KORR = ' '.
          ENDIF.
          IF L_VOLT_KORR = 'X'.
            $_EGYKORR = $_EGYKORR - L_SUM_FIELD_N.
          ELSE.
            $ABEV_FORG001 = $ABEV_FORG001 - L_SUM_FIELD_N.
          ENDIF.
*--0004 20070222 FI
          EXIT.
        ELSE.
*++0004 20070222 FI
*          $ABEV_FORG001 = $ABEV_FORG001 - L_SUM_FIELD_N.
*--0004 20070222 FI
*++0004 20070222 FI
*         Check whether the declaration row appears among the corrections.
          READ TABLE $T_EGYKORR INTO LS_EGYKORR
                                WITH KEY
                                BUKRS  = $BUKRS
*                              BTYPE  IN LR_BTYPE
                                GJAHR  = LW_IDOSZ-GJAHR
                                MONAT  = LW_IDOSZ-MONAT
                                ZINDEX = L_EGYKORR_IND
                                .
*If a correction declaration is found and its sequence number is lower then
*the correction must also be reduced
          IF SY-SUBRC = 0 AND LW_IDOSZ-ZINDEX < LS_EGYKORR-ZINDEX..
            L_VOLT_KORR = 'X'.
          ELSE.
            L_VOLT_KORR = ' '.
          ENDIF.
          IF L_VOLT_KORR = 'X'.
            $_EGYKORR = $_EGYKORR - L_SUM_FIELD_N.
          ELSE.
            $ABEV_FORG001 = $ABEV_FORG001 - L_SUM_FIELD_N.
          ENDIF.
*--0004 20070222 FI
*++ BG 2007.01.24
*         SUBTRACT 1 FROM LI_IDOSZ-ZINDEX.
          SUBTRACT 1 FROM LW_IDOSZ-ZINDEX.
*-- BG 2007.01.24
*++BG 2006.12.28
*++ BG 2007.01.24
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*            EXPORTING
*              INPUT  = LI_IDOSZ-ZINDEX
*            IMPORTING
*              OUTPUT = LI_IDOSZ-ZINDEX.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = LW_IDOSZ-ZINDEX
            IMPORTING
              OUTPUT = LW_IDOSZ-ZINDEX.
*-- BG 2007.01.24

*--BG 2006.12.28
        ENDIF.
      ENDDO.
*++BG 2006.12.20
    ENDLOOP.
*--BG 2006.12.20
  ENDLOOP.
*--BG 2006/07/19

ENDFORM.                    " get_abev_egyenleg_old

*&---------------------------------------------------------------------*
*&      Form  PROCESS_IND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_P01  text
*----------------------------------------------------------------------*
FORM PROCESS_IND USING $PERCENT
                       $TEXT
                       $DIV.

  DATA L_M TYPE P DECIMALS 2.

  L_M = $PERCENT MOD $DIV.

  IF L_M EQ 0.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = $PERCENT
        TEXT       = $TEXT.
  ENDIF.

ENDFORM.                    " process_ind
*&---------------------------------------------------------------------*
*&      Form  PROCESS_LIVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_LIVE_DATA .

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
*--0002 BG 2006/11/29

*  Read company data
  PERFORM GET_T001 USING P_BUKRS
                         V_SUBRC.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE A036 WITH P_BUKRS.
*   Error while determining company & data! (table T001)
  ENDIF.
* Declarations posted in the next period
  PERFORM GET_BEVALLI TABLES I_/ZAK/BEVALLI
*++0004 20070222 FI
                             I_/ZAK/EGYKORR
*--0004 20070222 FI
*++0002 BG 2006/11/29
                             R_BTYPE
*--0002 BG 2006/11/29
                      USING P_BUKRS
                            P_GJAHR
                            P_MONAT
*++0002 BG 2006/11/29
*                           P_BTYPE
*--0002 BG 2006/11/29
                            V_SUBRC
.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE E164 WITH P_BUKRS.
*   No data exists in table /ZAK/BEVALLI for the next month
  ENDIF.

* Declared items
  PERFORM GET_BEVALLO TABLES I_/ZAK/BEVALLI
                             I_/ZAK/BEVALLO
*++0002 BG 2006/11/29
                             R_BTYPE
*--0002 BG 2006/11/29
                       USING P_BUKRS
*++0002 BG 2006/11/29
*                            P_BTYPE
*--0002 BG 2006/11/29
                             V_SUBRC
.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE E165 WITH P_BUKRS.
*   No data exists in table /ZAK/BEVALLI for the next month
  ENDIF.

* Which G/L accounts are needed.
  PERFORM GET_FOKONYV TABLES I_/ZAK/BEVALLO
                             I_FOKONYV
*++0002 BG 2006/11/29
                             R_BTYPE
*--0002 BG 2006/11/29
                      USING
*++0002 BG 2006/11/29
*                            P_BTYPE
*--0002 BG 2006/11/29
                             V_SUBRC.

  PERFORM FELDOLGOZ  TABLES I_FOKONYV
                            I_/ZAK/SZJA_ELL
                            I_/ZAK/BEVALLO
*++0003 BG 2006/12/06
                            S_BLART
*--0003 BG 2006/12/06
                       USING P_BUKRS
                             P_GJAHR
                             P_MONAT
                             V_SUBRC.

ENDFORM.                    " PROCESS_LIVE_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_SAVE_DATA .

  REFRESH I_/ZAK/SZJA_ELL.

  SELECT * INTO TABLE I_/ZAK/SZJA_ELL
           FROM /ZAK/SZJA_ELL
          WHERE BUKRS EQ P_BUKRS
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT.
  IF SY-SUBRC NE 0.
    MESSAGE I212 WITH P_BUKRS P_GJAHR P_MONAT.
*   No saved data is available for company &, year &, month &!
  ENDIF.


ENDFORM.                    " PROCESS_SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .

*++0008 BG 2007.11.09
  IF P_LOAD IS INITIAL.
*--0008 BG 2007.11.09
* Delete data
    DELETE FROM /ZAK/SZJA_ELL WHERE BUKRS EQ P_BUKRS
                               AND GJAHR EQ P_GJAHR
                               AND MONAT EQ P_MONAT.

    MODIFY /ZAK/SZJA_ELL FROM TABLE I_/ZAK/SZJA_ELL.
*++0008 BG 2007.11.09
  ENDIF.
*--0008 BG 2007.11.09

*++0008 BG 2007.11.09
  IF NOT P_LOG IS INITIAL.
    DELETE FROM /ZAK/SZJA_ELLLOG WHERE BUKRS EQ P_BUKRS.
    MODIFY /ZAK/SZJA_ELLLOG FROM TABLE I_/ZAK/SZJA_ELLLOG.
  ENDIF.
*--0008 BG 2007.11.09

  COMMIT WORK AND WAIT.

ENDFORM.                    " SAVE_DATA
*&---------------------------------------------------------------------*
*&      Form  COLLECT_SZJA_ELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_SZJA_ELL  text
*----------------------------------------------------------------------*
FORM COLLECT_SZJA_ELL  TABLES   $T_SZJA_ELL STRUCTURE /ZAK/SZJA_ELL.

  DATA: LT_SZJA_ELL_SAVE  TYPE TABLE OF /ZAK/SZJA_ELL.
  DATA: LW_SZJA_ELL_SAVE  TYPE /ZAK/SZJA_ELL.

  LT_SZJA_ELL_SAVE[] = $T_SZJA_ELL[].
  REFRESH $T_SZJA_ELL.
  CLEAR   $T_SZJA_ELL.

  LOOP AT  LT_SZJA_ELL_SAVE INTO LW_SZJA_ELL_SAVE.
    COLLECT LW_SZJA_ELL_SAVE INTO $T_SZJA_ELL.
  ENDLOOP.

  FREE LT_SZJA_ELL_SAVE.


ENDFORM.                    " COLLECT_SZJA_ELL
*&---------------------------------------------------------------------*
*&      Form  GET_ELL_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO  text
*      -->P_$SAKNR  text
*      -->P_1496   text
*----------------------------------------------------------------------*
FORM GET_ELL_LOG  USING   $/ZAK/BEVALLO STRUCTURE /ZAK/BEVALLO
                          $SAKNR
                          $FIELD
                          $OP.

  DATA L_TEXT(40).
  FIELD-SYMBOLS <FIELD>.

  CLEAR W_/ZAK/SZJA_ELLLOG.

  MOVE-CORRESPONDING $/ZAK/BEVALLO TO W_/ZAK/SZJA_ELLLOG.
  MOVE $SAKNR TO W_/ZAK/SZJA_ELLLOG-SAKNR.
  CONCATENATE 'W_/ZAK/SZJA_ELLLOG-' $FIELD INTO L_TEXT.
  ASSIGN (L_TEXT) TO <FIELD>.
  IF $OP EQ '+'.
    MOVE $/ZAK/BEVALLO-FIELD_N TO <FIELD>.
  ELSEIF $OP EQ '-'.
    <FIELD> = -1 * $/ZAK/BEVALLO-FIELD_N.
  ENDIF.
  APPEND W_/ZAK/SZJA_ELLLOG TO I_/ZAK/SZJA_ELLLOG.


ENDFORM.                    " GET_ELL_LOG
