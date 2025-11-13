*----------------------------------------------------------------------*
***INCLUDE /ZAK/LREAD_TXTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  set_itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_SOR[]  text
*      -->P_CHECK_TAB[]  text
*      -->P_INTERN[]  text
*      -->P_E_HIBA[]  text
*----------------------------------------------------------------------*
FORM set_itab USING    $i_sor   LIKE i_sor[]
                       $check_tab LIKE i_dd03p[]
                       $intern    LIKE i_xls[]
                       $e_hiba    LIKE i_hiba[]
                       $i_bukrs   LIKE t001-bukrs
                       $i_cdv.

  DATA: l_tabix  LIKE sy-tabix,
        l_num(3) TYPE n,
        l_saknr  LIKE skb1-saknr.

  LOOP AT $i_sor INTO w_sor.
    l_tabix = sy-tabix.
    CLEAR l_num.
    LOOP AT $check_tab INTO w_dd03p.
      CLEAR w_intern.
      w_intern-row = l_tabix.
      w_intern-col = w_dd03p-position.
      w_intern-value = w_sor+l_num(w_dd03p-leng).
      l_num = l_num + w_dd03p-leng.
*++BG 2006.04.10
*      APPEND W_INTERN TO $INTERN.
*--BG 2006.04.10
* Validation based on field type, length, and content, the result
* is written into the check_tab-reptext field.
      CLEAR w_dd03p-reptext.
* Automatic check based on the conversion routine for period!
      IF w_dd03p-convexit EQ 'PERI'
         AND NOT w_intern-value IS INITIAL.
        CLEAR w_return.
        CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
          EXPORTING
            input      = w_intern-value
            no_message = 'X'
          IMPORTING
            return     = w_return.

        w_dd03p-reptext = w_return-message.
      ENDIF.
* Check general ledger account number
      IF w_dd03p-rollname EQ 'SAKNR'
         AND NOT w_intern-value IS INITIAL  .
        CLEAR l_saknr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = w_intern-value
          IMPORTING
            output = l_saknr.

*++S4HANA#01.
*        SELECT SINGLE * FROM SKB1      "#EC CI_DB_OPERATION_OK[2431747]
*                      WHERE BUKRS  EQ $I_BUKRS AND
*                            SAKNR  EQ L_SAKNR.
*        SELECT SINGLE @SPACE FROM SKB1
*            WHERE BUKRS  EQ @$I_BUKRS AND
*                  SAKNR  EQ @L_SAKNR INTO @SKB1.
        SELECT SINGLE COUNT(*) FROM skb1    "#EC CI_DB_OPERATION_OK[2431747]
             WHERE bukrs  EQ $i_bukrs AND
                   saknr  EQ l_saknr.
*--S4HANA#01.

        IF sy-subrc NE 0.
          w_dd03p-reptext = 'Ismeretlen főkönyvi szám!'.
        ENDIF.
      ENDIF.

      CASE w_dd03p-rollname.
** Checking tax number
*        WHEN '/ZAK/ADOAZON'.
*          IF NOT $I_CDV IS INITIAL.
*            CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*                 EXPORTING
*                      INPUT  = W_INTERN-VALUE
*                 IMPORTING
*                      RETURN = W_DD03P-REPTEXT.
*          ENDIF.
** Checking tax number
*        WHEN '/ZAK/ADOSZAM'.
*          IF NOT $I_CDV IS INITIAL.
*            CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*                 EXPORTING
*                      INPUT  = W_INTERN-VALUE
*                 IMPORTING
*                      RETURN = W_DD03P-REPTEXT.
*          ENDIF.
*++BG 2006.04.10
*       Tax number is required without '-'
        WHEN '/ZAK/ADOAZON' OR '/ZAK/ADOSZAM'.
          CALL FUNCTION '/ZAK/CONV_ADOAZON'
            EXPORTING
              input  = w_intern-value
            IMPORTING
              output = w_intern-value.
*         Checking tax number
          IF NOT $i_cdv IS INITIAL.
            CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
              EXPORTING
                input  = w_intern-value
              IMPORTING
                return = w_dd03p-reptext.
          ENDIF.
*--BG 2006.04.10
      ENDCASE.

      CASE w_dd03p-inttype.
* Only numeric characters are allowed
        WHEN 'N' .
          IF NOT w_intern-value CO '-0123456789., '.
            w_dd03p-reptext = 'Csak numerikus lehet!'.
          ENDIF.
* Only numeric values are allowed
        WHEN 'P'.
          IF NOT w_intern-value CO '-0123456789., '.
            w_dd03p-reptext = 'Csak numerikus lehet!'.
          ENDIF.
      ENDCASE.
* Populate error table
      IF NOT w_dd03p-reptext IS INITIAL.
        CLEAR: w_hiba.
        w_hiba-sor          = w_intern-row.
        w_hiba-oszlop       = w_intern-col.
        w_hiba-/zak/f_value  = w_intern-value.
        w_hiba-tabname      = w_dd03p-tabname.
        w_hiba-fieldname    = w_dd03p-fieldname.
        w_hiba-za_hiba      = w_dd03p-reptext.
        w_hiba-/zak/attrib   = w_dd03p-ddtext.
        APPEND w_hiba TO $e_hiba.
      ENDIF.

      MODIFY $check_tab FROM w_dd03p.

*++BG 2006.04.10
      APPEND w_intern TO $intern.
*--BG 2006.04.10
    ENDLOOP .
  ENDLOOP.
ENDFORM.                    " set_itab
*&---------------------------------------------------------------------*
*&      Form  SET_ITAB_CSV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_SOR[]  text
*      -->P_CHECK_TAB[]  text
*      -->P_INTERN[]  text
*      -->P_E_HIBA[]  text
*      -->P_I_BUKRS  text
*      -->P_I_CDV  text
*----------------------------------------------------------------------*
FORM set_itab_csv USING    $i_sor   LIKE i_sor[]
                           $check_tab LIKE i_dd03p[]
                           $intern    LIKE i_xls[]
                           $e_hiba    LIKE i_hiba[]
                           $i_bukrs   LIKE t001-bukrs
                           $i_cdv.

  DATA: l_tabix  LIKE sy-tabix,
        l_num(3) TYPE n,
        l_saknr  LIKE skb1-saknr.
  DATA  li_tab TYPE TABLE OF string WITH HEADER LINE.

  LOOP AT $i_sor INTO w_sor.
    REFRESH li_tab.
    SPLIT w_sor AT ';' INTO TABLE li_tab.
    l_tabix = sy-tabix.
    CLEAR l_num.
    LOOP AT $check_tab INTO w_dd03p.
      CLEAR w_intern.
      w_intern-row = l_tabix.
      w_intern-col = w_dd03p-position.
*      W_INTERN-VALUE = W_SOR+L_NUM(W_DD03P-LENG).
*      L_NUM = L_NUM + W_DD03P-LENG.
      READ TABLE li_tab INDEX w_dd03p-position.
      IF sy-subrc EQ 0.
        w_intern-value = li_tab.
      ENDIF.
* Validation based on field type, length, and content, the result
* is written into the check_tab-reptext field.
      CLEAR w_dd03p-reptext.
* Automatic check based on the conversion routine for period!
      IF w_dd03p-convexit EQ 'PERI'
         AND NOT w_intern-value IS INITIAL.
        CLEAR w_return.
        CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
          EXPORTING
            input      = w_intern-value
            no_message = 'X'
          IMPORTING
            return     = w_return.

        w_dd03p-reptext = w_return-message.
      ENDIF.
* Check general ledger account number
      IF w_dd03p-rollname EQ 'SAKNR'
         AND NOT w_intern-value IS INITIAL  .
        CLEAR l_saknr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = w_intern-value
          IMPORTING
            output = l_saknr.

*++S4HANA#01.
*        SELECT SINGLE * FROM skb1               "#EC CI_DB_OPERATION_OK
*        SELECT SINGLE * FROM skb1               "#EC CI_DB_OPERATION_OK
        SELECT COUNT(*) FROM skb1               "#EC CI_DB_OPERATION_OK[2431747]
*--S4HANA#01.
                      WHERE bukrs  EQ $i_bukrs AND
                            saknr  EQ l_saknr.

        IF sy-subrc NE 0.
          w_dd03p-reptext = 'Ismeretlen főkönyvi szám!'.
        ENDIF.
      ENDIF.

      CASE w_dd03p-rollname.
** Checking tax number
*        WHEN '/ZAK/ADOAZON'.
*          IF NOT $I_CDV IS INITIAL.
*            CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*                 EXPORTING
*                      INPUT  = W_INTERN-VALUE
*                 IMPORTING
*                      RETURN = W_DD03P-REPTEXT.
*          ENDIF.
** Checking tax number
*        WHEN '/ZAK/ADOSZAM'.
*          IF NOT $I_CDV IS INITIAL.
*            CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*                 EXPORTING
*                      INPUT  = W_INTERN-VALUE
*                 IMPORTING
*                      RETURN = W_DD03P-REPTEXT.
*          ENDIF.
*++BG 2006.04.10
*       Tax number is required without '-'
        WHEN '/ZAK/ADOAZON' OR '/ZAK/ADOSZAM'.
          CALL FUNCTION '/ZAK/CONV_ADOAZON'
            EXPORTING
              input  = w_intern-value
            IMPORTING
              output = w_intern-value.
*         Checking tax number
          IF NOT $i_cdv IS INITIAL.
            CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
              EXPORTING
                input  = w_intern-value
              IMPORTING
                return = w_dd03p-reptext.
          ENDIF.
*--BG 2006.04.10
      ENDCASE.

      CASE w_dd03p-inttype.
* csak numerikus lehet
        WHEN 'N' .
          IF NOT w_intern-value CO '-0123456789., '.
            w_dd03p-reptext = 'Csak numerikus lehet!'.
          ENDIF.
* Only numeric values are allowed
        WHEN 'P'.
          IF NOT w_intern-value CO '-0123456789., '.
            w_dd03p-reptext = 'Csak numerikus lehet!'.
          ENDIF.
      ENDCASE.
* Populate error table
      IF NOT w_dd03p-reptext IS INITIAL.
        CLEAR: w_hiba.
        w_hiba-sor          = w_intern-row.
        w_hiba-oszlop       = w_intern-col.
        w_hiba-/zak/f_value  = w_intern-value.
        w_hiba-tabname      = w_dd03p-tabname.
        w_hiba-fieldname    = w_dd03p-fieldname.
        w_hiba-za_hiba      = w_dd03p-reptext.
        w_hiba-/zak/attrib   = w_dd03p-ddtext.
        APPEND w_hiba TO $e_hiba.
      ENDIF.

      MODIFY $check_tab FROM w_dd03p.

*++BG 2006.04.10
      APPEND w_intern TO $intern.
*--BG 2006.04.10
    ENDLOOP .
  ENDLOOP.
ENDFORM.                    " set_itab_csv
