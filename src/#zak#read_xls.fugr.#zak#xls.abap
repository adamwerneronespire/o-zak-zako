FUNCTION /ZAK/XLS.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FILENAME) LIKE  RLGRAP-FILENAME
*"     VALUE(I_BEGIN_COL) TYPE  I
*"     VALUE(I_BEGIN_ROW) TYPE  I
*"     VALUE(I_END_COL) TYPE  I
*"     VALUE(I_END_ROW) TYPE  I
*"     VALUE(I_STRNAME) TYPE  STRUKNAME
*"     REFERENCE(I_BUKRS) TYPE  T001-BUKRS
*"     REFERENCE(I_CDV) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_HEAD) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_NOT_FILL_LINE) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     VALUE(E_MAX_LINE) TYPE  SYTABIX
*"  TABLES
*"      INTERN STRUCTURE  ALSMEX_TABLINE
*"      CHECK_TAB STRUCTURE  DD03P
*"      E_HIBA STRUCTURE  /ZAK/ADAT_HIBA
*"      I_LINE STRUCTURE  /ZAK/LINE
*"  EXCEPTIONS
*"      INCONSISTENT_PARAMETERS
*"      UPLOAD_OLE
*"      FILE_OPEN_ERROR
*"      INVALID_TYPE
*"      CONVERSION_ERROR
*"----------------------------------------------------------------------
*++2011.12.12 BG
  DATA L_TABIX LIKE SY-TABIX.
*--2011.12.12 BG

  CLEAR V_TAB.
  CONCATENATE 'W_' I_STRNAME INTO V_TAB.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = FILENAME
      I_BEGIN_COL             = I_BEGIN_COL
      I_BEGIN_ROW             = I_BEGIN_ROW
      I_END_COL               = I_END_COL
      I_END_ROW               = I_END_ROW
    TABLES
      INTERN                  = I_XLS
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
* Was data provided?
    IF I_XLS[] IS INITIAL.
      MESSAGE E100(/ZAK/ZAK) .
    ENDIF.
*++BG 2006/07/07
* If the data file has a header, delete the first line
    IF NOT I_HEAD IS INITIAL.
      DELETE  I_XLS WHERE ROW = 1.
    ENDIF.
*--BG 2006/07/07

* Load data into the internal table
    LOOP AT I_XLS INTO W_XLS.

      CLEAR W_LINE.
* Validation based on field type, length, and content, the result
* is written into the check_tab-reptext field.

      READ TABLE CHECK_TAB WITH KEY POSITION = W_XLS-COL.
*++2011.12.12 BG
      L_TABIX = SY-TABIX.
*--2011.12.12 BG
      CLEAR CHECK_TAB-REPTEXT.

      PERFORM CHECK_XLS USING  W_XLS
                               I_BUKRS
                               I_CDV
*++BG 2006.04.10
*                       CHANGING CHECK_TAB
                               CHECK_TAB
*--BG 2006.04.10
                               .

*++2011.12.12 BG
*      MODIFY CHECK_TAB INDEX SY-TABIX.
      MODIFY CHECK_TAB INDEX L_TABIX.
*--2011.12.12 BG
* Populate error table
      IF NOT CHECK_TAB-REPTEXT IS INITIAL.
        CLEAR: W_HIBA.
        W_HIBA-SOR          = W_XLS-ROW.
        W_HIBA-OSZLOP       = W_XLS-COL.
        W_HIBA-/ZAK/F_VALUE  = W_XLS-VALUE.
        W_HIBA-TABNAME      = CHECK_TAB-TABNAME.
        W_HIBA-FIELDNAME    = CHECK_TAB-FIELDNAME.
        W_HIBA-ZA_HIBA      = 'Csak numerikus lehet!'.
        W_HIBA-/ZAK/ATTRIB   = CHECK_TAB-DDTEXT.
        APPEND W_HIBA TO E_HIBA.
      ENDIF.
      CLEAR V_TAB_FIELD.
      CONCATENATE 'W_' CHECK_TAB-TABNAME '-' CHECK_TAB-FIELDNAME
      INTO V_TAB_FIELD.
      ASSIGN (V_TAB_FIELD) TO <F1>.
* Amount fields cannot contain character values!
      IF CHECK_TAB-INTTYPE EQ 'P' AND
         NOT W_XLS-VALUE CO '-0123456789., '.
        W_XLS-VALUE = '0000'.
      ENDIF.

      CATCH  SYSTEM-EXCEPTIONS
             CONVT_NO_NUMBER    =  1.
        <F1> = W_XLS-VALUE.
      ENDCATCH.
      IF SY-SUBRC EQ 1.
        CLEAR: W_HIBA.
        W_HIBA-SOR          = W_XLS-ROW.
        W_HIBA-OSZLOP       = W_XLS-COL.
        W_HIBA-/ZAK/F_VALUE  = W_XLS-VALUE.
        W_HIBA-TABNAME      = CHECK_TAB-TABNAME.
        W_HIBA-FIELDNAME    = CHECK_TAB-FIELDNAME.
*++2208 #07.
*        W_HIBA-ZA_HIBA      = 'Csak numerikus lehet!'.
        W_HIBA-ZA_HIBA      = CHECK_TAB-REPTEXT.
*--2208 #07.
        W_HIBA-/ZAK/ATTRIB   = CHECK_TAB-DDTEXT.
        APPEND W_HIBA TO E_HIBA.
      ENDIF.

      AT END OF ROW.
*++BG 2010.12.12
        IF I_NOT_FILL_LINE IS INITIAL.
*--BG 2010.12.12
          ASSIGN (V_TAB) TO <F2>.
          W_LINE = <F2>.
          APPEND W_LINE TO I_LINE.
          CLEAR <F2>.
*++BG 2010.12.12
        ENDIF.
*--BG 2010.12.12
*++1565 #10.
        IF W_XLS-ROW > E_MAX_LINE.
          E_MAX_LINE = W_XLS-ROW.
        ENDIF.
*--1565 #10.
      ENDAT.
*++BG 2006.04.10
      MODIFY I_XLS FROM W_XLS.
*--BG 2006.04.10
*++1565 #10.
*      E_MAX_LINE = W_XLS-ROW.
*--1565 #10.
    ENDLOOP. "I_XLS

*++0003 2008.12.11 BG (Fmc)
*   If tax identification validation is enabled
    IF NOT I_CDV IS INITIAL.
      CALL FUNCTION '/ZAK/CHECK_ADOAZON'
        IMPORTING
          E_HIBA    = W_HIBA
        TABLES
          INTERN    = I_XLS
          CHECK_TAB = CHECK_TAB.
      IF NOT W_HIBA IS INITIAL.
        APPEND W_HIBA TO E_HIBA.
      ENDIF.
    ENDIF.
*--0003 2008.12.11 BG (Fmc)
  ENDIF.
* for testing
  INTERN[] = I_XLS[].
ENDFUNCTION.
