*&---------------------------------------------------------------------*
*& Program: Submit postings for a closed period
*&---------------------------------------------------------------------*
 REPORT /ZAK/BOOK_FILE_GEN MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Based on the selection criteria the program creates the transfer
*& and self-check surcharge posting Excel files for the closed period.
*&---------------------------------------------------------------------*
*& Author            : Gábor Balázs - FMC
*& Creation date     : 2006.03.30
*& Functional spec by: ________
*& SAP module name   : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of each modified line)*
*&
*& LOG#     DATE        MODIFIER        DESCRIPTION             TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx
*&                                   xxxxxxx xxxxxxx xxxxxxx
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.



*&---------------------------------------------------------------------*
*& TABLES                                                             *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& CONSTANTS (C_XXXXXXX..)                                             *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                  *
*      Internal table     -   (I_xxx...)                              *
*      FORM parameter     -   ($xxxx...)                              *
*      Constant           -   (C_xxx...)                              *
*      Parameter variable -   (P_xxx...)                              *
*      Selection option   -   (S_xxx...)                              *
*      Ranges             -   (R_xxx...)                              *
*      Global variables   -   (V_xxx...)                              *
*      Local variables    -   (L_xxx...)                              *
*      Work area          -   (W_xxx...)                              *
*      Type               -   (T_xxx...)                              *
*      Macros             -   (M_xxx...)                              *
*      Field-symbol       -   (FS_xxx...)                             *
*      Method             -   (METH_xxx...)                           *
*      Object             -   (O_xxx...)                              *
*      Class              -   (CL_xxx...)                             *
*      Event              -   (E_xxx...)                              *
*&---------------------------------------------------------------------*




*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-T01.
* Company.
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-101.
 PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLI-BUKRS VALUE CHECK
                           OBLIGATORY MEMORY ID BUK.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

 SELECTION-SCREEN END OF LINE.

* Determine tax return category
 PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                           OBLIGATORY.
* Tax return type
 PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLI-BTYPE
*                          OBLIGATORY
                           NO-DISPLAY.
* Year
 PARAMETERS: P_GJAHR  LIKE /ZAK/BEVALLI-GJAHR DEFAULT SY-DATUM(4).

* Month
 PARAMETERS: P_MONAT  LIKE /ZAK/BEVALLI-MONAT DEFAULT SY-DATUM+4(2).

* Index
 PARAMETERS: P_INDEX LIKE /ZAK/BEVALLI-ZINDEX.

 SELECTION-SCREEN: END OF BLOCK BL1.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.

*  Determine descriptions
   PERFORM READ_ADDITIONALS.
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

*  Set screen attributes
   PERFORM SET_SCREEN_ATTRIBUTES.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
*  Determine descriptions
   PERFORM READ_ADDITIONALS.
*  Determine tax return type
   PERFORM GET_BTYPE.
*  Check whether the specified period is closed.
   PERFORM GET_STATUS_CLOSE.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*  Authorization check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTYPAR
                                 C_ACTVT_01.

*  Transfer or other
   IF P_BTYPAR = C_BTYPART_ATV.
     CALL FUNCTION '/ZAK/ATV_BOOK_EXCEL'
          EXPORTING
               I_BUKRS         = P_BUKRS
               I_BTYPE         = P_BTYPE
               I_GJAHR         = P_GJAHR
               I_MONAT         = P_MONAT
               I_INDEX         = P_INDEX
*         TABLES
*              T_BEVALLO       = I_/ZAK/BEVALLO
          EXCEPTIONS
               DATA_MISMATCH   = 1
               DOWNLOAD_FAILED = 2
               OTHERS          = 3.

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.
       MESSAGE I009 WITH SPACE.
*   & file downloaded successfully
     ENDIF.
   ELSE.
     CALL FUNCTION '/ZAK/ONELL_BOOK_EXCEL'
      EXPORTING
        I_BUKRS                   = P_BUKRS
        I_BTYPE                   = P_BTYPE
        I_GJAHR                   = P_GJAHR
        I_MONAT                   = P_MONAT
        I_INDEX                   = P_INDEX
*     TABLES
*       T_BEVALLO                 = I_/ZAK/BEVALLO
      EXCEPTIONS
        DATA_MISMATCH             = 1
        ERROR_ONELL_BOOK          = 2
        ERROR_DOWNLOAD_FILE       = 3
        EMPTY_FILE                = 4
*++BG 2008.04.16
        ERROR_CHANGE_BUKRS        = 5
*--BG 2008.04.16

        OTHERS                    = 6
               .
     IF SY-SUBRC <> 0.
       CASE SY-SUBRC.
         WHEN 2.
           MESSAGE I154.
*      Self-check allowance accounting setting error! File not created!
         WHEN 3.
           MESSAGE I155.
*      Self-check allowance accounting file creation error!
         WHEN 4.
           MESSAGE I157.
*      There is no identifiable data! File not created!
*++BG 2008.04.16
         WHEN 5.
           MESSAGE I231 WITH P_BUKRS.
*   Error in defining & company rotation! (/ZAK/ROTATE_BUKRS_OUTPU
*--BG 2008.04.16

       ENDCASE .
     ELSE.
       MESSAGE I009 WITH SPACE.
*   & file downloaded successfully
     ENDIF.
*++BG 2008.01.07 VAT apportionment posting
     IF P_BTYPAR = C_BTYPART_AFA.
       CALL FUNCTION '/ZAK/AFAR_BOOK_EXCEL'
         EXPORTING
           I_BUKRS             = P_BUKRS
           I_BTYPE             = P_BTYPE
           I_GJAHR             = P_GJAHR
           I_MONAT             = P_MONAT
           I_INDEX             = P_INDEX
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
       ELSE.
         MESSAGE I009 WITH SPACE.
*        & file downloaded successfully
       ENDIF.
     ENDIF.
*--BG 2008.01.07 VAT apportionment posting
   ENDIF.

 END-OF-SELECTION.

*&---------------------------------------------------------------------*
*                            PERFORMOK
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
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
     ENDIF.
     MODIFY SCREEN.
   ENDLOOP.

 ENDFORM.                    " SET_SCREEN_ATTRIBUTES

*&---------------------------------------------------------------------*
*&      Form  READ_ADDITIONALS
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

 ENDFORM.                    " READ_ADDITIONALS
*&---------------------------------------------------------------------*
*&      Form  GET_STATUSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
 FORM GET_STATUSZ USING    $BUKRS
                           $BTYPE
                           $GJAHR
                           $MONAT.

   CLEAR W_/ZAK/BEVALLI.
   SELECT SINGLE * INTO W_/ZAK/BEVALLI
                   FROM /ZAK/BEVALLI
                  WHERE BUKRS EQ P_BUKRS
                    AND BTYPE EQ P_BTYPE
                    AND GJAHR EQ P_GJAHR
                    AND MONAT EQ P_MONAT
                    AND ZINDEX EQ P_INDEX.


 ENDFORM.                    " GET_STATUSZ
*&---------------------------------------------------------------------*
*&      Form  get_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_BTYPE.

*  If BTYPE is empty, determine it
*   IF P_BTYPE IS INITIAL AND
*      NOT P_BUKRS IS INITIAL AND
*      NOT P_BTYPAR IS INITIAL AND
*      NOT P_GJAHR IS INITIAL AND
*      NOT P_MONAT IS INITIAL.
   CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
     EXPORTING
       I_BUKRS     = P_BUKRS
       I_BTYPART   = P_BTYPAR
       I_GJAHR     = P_GJAHR
       I_MONAT     = P_MONAT
     IMPORTING
       E_BTYPE     = P_BTYPE
     EXCEPTIONS
       ERROR_MONAT = 1
       ERROR_BTYPE = 2
       OTHERS      = 3.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
*   ENDIF.


 ENDFORM.                    " get_btype
*&---------------------------------------------------------------------*
*&      Form  GET_STATUS_CLOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_STATUS_CLOSE.

*  Determine the status
   PERFORM GET_STATUSZ USING P_BUKRS
                             P_BTYPE
                             P_GJAHR
                             P_MONAT.

*  If the status is not closed:
   IF W_/ZAK/BEVALLI-FLAG NA 'ZX'.
     MESSAGE E156.
*   Please enter only a closed period!
   ENDIF.

 ENDFORM.                    " GET_STATUS_CLOSE
