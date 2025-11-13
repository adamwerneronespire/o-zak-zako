*&---------------------------------------------------------------------*
*& Program: Control and execution program for transferring the tax return
*&---------------------------------------------------------------------*
REPORT  /ZAK/ZAK_GET_ZF_DATA MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Based on the selection criteria provided,
*& the program displays (or modifies in productive mode) via remote RFC calls
*& the returns that can be received and lists what has already been taken over.
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - Ness
*& Creation date     : 2017.01.25
*& Functional spec   : ________
*& SAP modul neve    :
*& Program type      : Report
*& SAP version       :
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (write the OSS note number at the end of the changed lines)
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*&---------------------------------------------------------------------*

INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/MAIN_TOP.
INCLUDE /ZAK/SAP_SEL_F01.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*  PROGRAM VARIABLES                                                   *
*      Internal table       -   (I_xxx...)                             *
*      FORM parameter       -   ($xxxx...)                             *
*      Constant             -   (C_xxx...)                             *
*      Parameter variable   -   (P_xxx...)                             *
*      Selection option     -   (S_xxx...)                             *
*      Ranges               -   (R_xxx...)                             *
*      Global variables     -   (V_xxx...)                             *
*      Local variables      -   (L_xxx...)                             *
*      Work area            -   (W_xxx...)                             *
*      Type                 -   (T_xxx...)                             *
*      Macros               -   (M_xxx...)                             *
*      Field-symbol         -   (FS_xxx...)                            *
*      Method               -   (METH_xxx...)                          *
*      Object               -   (O_xxx...)                             *
*      Class                -   (CL_xxx...)                            *
*      Event                -   (E_xxx...)                             *
*&---------------------------------------------------------------------*

DATA:
  I_ANALITIKA  TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
  I_AFA_SZLA   TYPE STANDARD TABLE OF /ZAK/AFA_SZLA INITIAL SIZE 0,
  I_E_RETURN   TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0,

  I_/ZAK/OPACK  TYPE STANDARD TABLE OF /ZAK/OPACK INITIAL SIZE 0,
  WA_/ZAK/OPACK LIKE LINE OF I_/ZAK/OPACK.

DATA:
  V_OPACK_EXECUTED TYPE XFELD VALUE '',
  V_BUKRS          TYPE /ZAK/BEVALLP-BUKRS,
  V_RFCDEST        TYPE RFCDEST,
  V_OPACK          TYPE /ZAK/OPACK,
  V_GRID           TYPE REF TO CL_SALV_TABLE.

DATA:
  V_REPID LIKE SY-REPID,
  V_SUBRC LIKE SY-SUBRC,
  O_XROOT TYPE REF TO CX_ROOT.

*++1665 #01.
TYPES: BEGIN OF T_CHECK_BSZNUM,
         BUKRS TYPE BUKRS,
         BTYPE TYPE /ZAK/BTYPE,
       END OF T_CHECK_BSZNUM.

DATA I_CHECK_BSZNUM TYPE STANDARD TABLE OF T_CHECK_BSZNUM INITIAL SIZE 0.
*--1665 #01.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Company in the other system.
PARAMETERS: P_BUKRS  TYPE CHAR4  OBLIGATORY DEFAULT '2330'.
* Company in the current system
PARAMETERS: P_BUKRST LIKE /ZAK/BEVALLP-BUKRS VALUE CHECK OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
* Upload identifier
SELECT-OPTIONS S_PACK FOR /ZAK/BEVALLP-PACK NO-EXTENSION.
* Data reporting identifier
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM OBLIGATORY
                                       DEFAULT '050'.
* Type of return
PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART OBLIGATORY
                                       DEFAULT C_BTYPART_AFA.
* Test (or productive)
PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL02.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.
* Determine the RFC destination depending on the current system
  PERFORM SET_RFC_DESTINATION.
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
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PACK-LOW.
  PERFORM SUB_F4_PACK
            USING S_PACK-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PACK-HIGH.
  PERFORM SUB_F4_PACK
           USING S_PACK-HIGH.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  Service identifier check
  PERFORM VER_BSZNUM   USING P_BUKRST
                             P_BTYPAR
                             P_BSZNUM
                             V_REPID
                    CHANGING V_SUBRC.

*  VAT return type check
  PERFORM VER_BTYPEART USING P_BUKRST
                             P_BTYPAR
                             C_BTYPART_AFA
                    CHANGING V_SUBRC.

  IF NOT V_SUBRC IS INITIAL.
    MESSAGE E030.
*    Please provide a VAT-type return identifier!
  ENDIF.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM EXECUTE_ANAL.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* No list is created in the background
*  IF SY-BATCH IS INITIAL.
  PERFORM LIST_DISPLAY.
*  ENDIF.


************************************************************************
* ALPROGRAMOK
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  set_rfc_destination
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_RFC_DESTINATION.
  CLEAR V_RFCDEST.
ENHANCEMENT-POINT /ZAK/ZAK_GET_ZF_DATA_01 SPOTS /ZAK/GET_DATA_01 .


ENDFORM.    " set_rfc_destination

*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  TRY.
      CALL METHOD CL_SALV_TABLE=>FACTORY
        IMPORTING
          R_SALV_TABLE = V_GRID
        CHANGING
          T_TABLE      = I_ANALITIKA.
    CATCH CX_SALV_MSG.
  ENDTRY.

  V_GRID->DISPLAY( ).
ENDFORM.  " list_display


*&---------------------------------------------------------------------*
*&      Form  SUB_F4_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUB_F4_PACK
          USING $S_PACK TYPE /ZAK/BEVALLP-PACK.

  DATA:
    LT_RETURN      TYPE TABLE OF DDSHRETVAL,
    LWA_RETURN     TYPE DDSHRETVAL,
    LWA_DYNPFIELDS TYPE DYNPREAD,
    LT_DYNPFIELDS  TYPE TABLE OF DYNPREAD.

  REFRESH LT_DYNPFIELDS.
* Read the content from the P_BUKRS parameter field
  LWA_DYNPFIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND LWA_DYNPFIELDS TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYNPFIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_DYNPFIELDS INTO LWA_DYNPFIELDS
         WITH KEY FIELDNAME = 'P_BUKRS'.
  IF SY-SUBRC = 0.
    V_BUKRS = LWA_DYNPFIELDS-FIELDVALUE.
  ENDIF.

* Retrieve the upload identifiers for all companies
  PERFORM EXECUTE_OPEN_PACK
                 TABLES I_/ZAK/OPACK
                  USING V_BUKRS.

* Display the search help
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'PACK'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = I_/ZAK/OPACK
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INTO LWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    WRITE LWA_RETURN-FIELDVAL TO $S_PACK.
  ENDIF.
ENDFORM.                    "SUB_F4_PACK

*&---------------------------------------------------------------------*
*&      Form  EXECUTE_ANAl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_ANAL.

  DATA:
    LI_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
    LW_ANALITIKA TYPE /ZAK/ANALITIKA,
    LI_AFA_SZLA  TYPE STANDARD TABLE OF /ZAK/AFA_SZLA  INITIAL SIZE 0,
    LW_AFA_SZLA  TYPE /ZAK/AFA_SZLA,
    LI_E_RETURN  TYPE STANDARD TABLE OF BAPIRET2      INITIAL SIZE 0.
  DATA   L_SUBRC TYPE SYSUBRC.

  DATA:
    L_INTERNAL_AMOUNT TYPE WRBTR,
    L_EXTERNAL_AMOUNT TYPE BAPICURR-BAPICURR.

  DEFINE LM_CURRENCY_INTERNAL.
    L_EXTERNAL_AMOUNT = &1.
*   Amount conversion to internal HUF format
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        CURRENCY             = &2
        AMOUNT_EXTERNAL      = L_EXTERNAL_AMOUNT
        MAX_NUMBER_OF_DIGITS = 13
      IMPORTING
        AMOUNT_INTERNAL      = L_INTERNAL_AMOUNT.
    &1 = L_INTERNAL_AMOUNT.
  END-OF-DEFINITION.


* Determining the company currency

*  Reading company data
  PERFORM GET_T001(/ZAK/AFA_SAP_SELN) USING
                         P_BUKRST
                         L_SUBRC.
  IF NOT L_SUBRC IS INITIAL.
    MESSAGE A036 WITH V_BUKRS.
  ENDIF.

* Retrieve the upload identifiers for all companies
  PERFORM EXECUTE_OPEN_PACK
                 TABLES I_/ZAK/OPACK
                  USING P_BUKRS.


* Collect the analytics for the upload identifier(s) that have not been transferred
  LOOP AT I_/ZAK/OPACK INTO WA_/ZAK/OPACK WHERE PACK IN S_PACK.
    REFRESH: LI_ANALITIKA,
             LI_AFA_SZLA,
             LI_E_RETURN.

    CALL FUNCTION '/ZAK/GET_ANAL'
      DESTINATION V_RFCDEST
      EXPORTING
        I_BUKRS     = WA_/ZAK/OPACK-BUKRS
        I_PACK      = WA_/ZAK/OPACK-PACK
        I_TEST      = 'X'
      TABLES
        T_ANALITIKA = LI_ANALITIKA
        T_AFA_SZLA  = LI_AFA_SZLA.

*++2014.12.17 BG
*++1665 #01.
*    LOOP AT LI_ANALITIKA INTO LW_ANALITIKA WHERE BSZNUM NE P_BSZNUM.
    LOOP AT LI_ANALITIKA INTO LW_ANALITIKA.
*     Company reassignment
      LW_ANALITIKA-FI_BUKRS = LW_ANALITIKA-BUKRS.
      LW_ANALITIKA-BUKRS    = P_BUKRST.
      MODIFY LI_ANALITIKA FROM LW_ANALITIKA TRANSPORTING BUKRS FI_BUKRS.
*     Currency handling
      LM_CURRENCY_INTERNAL LW_ANALITIKA-DMBTR T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-LWBAS T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-LWSTE T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-HWBTR T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-FIELD_N T001-WAERS.
      MODIFY LI_ANALITIKA FROM LW_ANALITIKA TRANSPORTING DMBTR LWBAS LWSTE HWBTR FIELD_N.
      PERFORM CHECK_BSZNUM_BTYPE TABLES I_CHECK_BSZNUM
                                 USING  LW_ANALITIKA-BUKRS
                                        LW_ANALITIKA-BTYPE
                                        P_BSZNUM.
      IF LW_ANALITIKA-BSZNUM NE P_BSZNUM.
*--1665 #01.
        LW_ANALITIKA-BSZNUM = P_BSZNUM.
        MODIFY LI_ANALITIKA FROM LW_ANALITIKA TRANSPORTING BSZNUM.
*++1665 #01.
      ENDIF.
*--1665 #01.
    ENDLOOP.
*   Company adjustment for AFA_SZLA
    LOOP AT LI_AFA_SZLA INTO LW_AFA_SZLA.
      LW_AFA_SZLA-BUKRS = P_BUKRST.
      MODIFY LI_AFA_SZLA FROM LW_AFA_SZLA TRANSPORTING BUKRS.
      IF LW_AFA_SZLA-WAERS EQ 'HUF'.
        MULTIPLY LW_AFA_SZLA-LWBAS BY 100.
        MULTIPLY LW_AFA_SZLA-LWSTE BY 100.
        MODIFY LI_AFA_SZLA FROM LW_AFA_SZLA TRANSPORTING LWBAS LWSTE.
      ENDIF.
    ENDLOOP.
*--2014.12.17 BG
*   /ZAK/UPDATE call for each company and upload identifier
    PERFORM UPDATE_AFA_SZLA TABLES LI_ANALITIKA
                                   LI_AFA_SZLA
                                   LI_E_RETURN
                            USING  P_BUKRST
                                   WA_/ZAK/OPACK-PACK
                                   P_BTYPAR
                                   P_BSZNUM
                                   P_TESZT
                                   L_SUBRC.

    APPEND LINES OF LI_ANALITIKA TO I_ANALITIKA.
    APPEND LINES OF LI_AFA_SZLA TO  I_AFA_SZLA.
    APPEND LINES OF LI_E_RETURN TO  I_E_RETURN.
    IF P_TESZT IS INITIAL AND L_SUBRC IS INITIAL.
      CALL FUNCTION '/ZAK/GET_ANAL'
        DESTINATION V_RFCDEST
        EXPORTING
          I_BUKRS     = WA_/ZAK/OPACK-BUKRS
          I_PACK      = WA_/ZAK/OPACK-PACK
          I_TEST      = P_TESZT
        TABLES
          T_ANALITIKA = LI_ANALITIKA
          T_AFA_SZLA  = LI_AFA_SZLA.
    ENDIF.
  ENDLOOP.
ENDFORM.                   "EXECUTE_ANAL

*&---------------------------------------------------------------------*
*&      Form  EXECUTE_OPEN_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$BUKRS     text
*----------------------------------------------------------------------*
FORM EXECUTE_OPEN_PACK
         TABLES $TABLE LIKE I_/ZAK/OPACK
          USING $BUKRS TYPE /ZAK/BEVALLP-BUKRS.

  CALL FUNCTION '/ZAK/OPEN_PACK'
    DESTINATION V_RFCDEST
    EXPORTING
      I_BUKRS     = $BUKRS
*++1965 #05.
      I_BTYPART   = P_BTYPAR
*--1965 #05.
    TABLES
      T_/ZAK/OPACK = $TABLE.
ENDFORM.                    "EXECUTE_OPEN_PACK


*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INITIALIZATION.
  MOVE SY-REPID TO V_REPID.
ENDFORM.                    "INITIALIZATION


*&---------------------------------------------------------------------*
*&      Form  UPDATE_AFA_SZLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$I_ANALITIKA  text
*      -->$I_AFA_SZLA   text
*      -->$I_E_RETURN   text
*      -->$BUKRS        text
*      -->$PACK         text
*      -->$BTYPAR       text
*      -->$BSZNUM       text
*      -->$TEST         text
*----------------------------------------------------------------------*
FORM UPDATE_AFA_SZLA
              TABLES $I_ANALITIKA LIKE I_ANALITIKA
                     $I_AFA_SZLA  LIKE I_AFA_SZLA
                     $I_E_RETURN  LIKE I_E_RETURN
              USING  $BUKRS   TYPE  /ZAK/BEVALLP-BUKRS
                     $PACK    TYPE  /ZAK/BEVALLP-PACK
                     $BTYPAR  LIKE P_BTYPAR
                     $BSZNUM  LIKE P_BSZNUM
                     $TEST    LIKE P_TESZT
                     $SUBRC.

  DATA LW_RETURN TYPE BAPIRET2.


  CLEAR $SUBRC.

  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = $BUKRS
*     I_BTYPE     =
      I_BTYPART   = $BTYPAR
      I_BSZNUM    = $BSZNUM
      I_PACK      = $PACK
      I_GEN       = 'X'
      I_TEST      = $TEST
*     I_FILE      =
    TABLES
      I_ANALITIKA = $I_ANALITIKA
      I_AFA_SZLA  = $I_AFA_SZLA
      E_RETURN    = $I_E_RETURN.

  LOOP AT $I_E_RETURN WHERE TYPE CA 'AE'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    MOVE 4 TO $SUBRC.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        I_BAPIRET2_TAB = $I_E_RETURN.
  ENDIF.

ENDFORM.                    "UPDATE_AFA_SZLA
*++1665 #01.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BSZNUM_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_CHECK_BSZNUM  text
*      -->P_LW_ANALITIKA_BTYPE  text
*      -->P_P_BSZNUM  text
*----------------------------------------------------------------------*
FORM CHECK_BSZNUM_BTYPE  TABLES   $I_CHECK_BSZNUM LIKE I_CHECK_BSZNUM
                         USING    $BUKRS
                                  $BTYPE
                                  $BSZNUM.

  DATA LW_CHECK_BSZNUM TYPE T_CHECK_BSZNUM.

* Already checked
  READ TABLE $I_CHECK_BSZNUM TRANSPORTING NO FIELDS
                             WITH KEY BUKRS = $BUKRS
                                      BTYPE = $BTYPE
                             BINARY SEARCH.
  CHECK SY-SUBRC NE 0.
  SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALLD
                          WHERE BUKRS    EQ $BUKRS
                            AND BTYPE    EQ $BTYPE
                            AND BSZNUM   EQ $BSZNUM
                            AND PROGRAMM EQ SY-REPID.
  IF SY-SUBRC EQ 0.
    CLEAR LW_CHECK_BSZNUM.
    LW_CHECK_BSZNUM-BUKRS = $BUKRS.
    LW_CHECK_BSZNUM-BTYPE = $BTYPE.
    APPEND LW_CHECK_BSZNUM TO $I_CHECK_BSZNUM.
    SORT $I_CHECK_BSZNUM.
  ELSE.
    MESSAGE E360 WITH $BUKRS $BTYPE $BSZNUM.
*   No data reporting is configured for company & and return type &!
  ENDIF.

ENDFORM.                    " CHECK_BSZNUM_BTYPE
*--1665 #01.
