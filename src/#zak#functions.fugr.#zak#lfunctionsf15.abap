*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_PTGSZLAH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_ptgszlah   TABLES t_bevallo STRUCTURE /zak/bevallo
                                 t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                          USING  $LAST_DATE
*                                 $INDEX.
                          USING  $last_date TYPE sy-datum
                                 $index TYPE /zak/index.
*--S4HANA#01.

  DATA l_tabix LIKE sy-tabix.
  DATA l_datum LIKE sy-datum.

* the following ABEV codes may appear only once, summary or character
  LOOP AT t_bevallb INTO w_/zak/bevallb
    WHERE  abevaz EQ     c_abevaz_a0ad001a
       OR  abevaz EQ     c_abevaz_a0ad002a
       OR  abevaz EQ     c_abevaz_a0ad003a.

* this line must be modified!
    LOOP AT t_bevallo INTO w_/zak/bevallo
                      WHERE abevaz = w_/zak/bevallb-abevaz.

      CASE w_/zak/bevallb-abevaz.
*    Period start date
        WHEN  c_abevaz_a0ad001a.
          l_datum = $last_date.
          l_datum+6(2) = 01.
          w_/zak/bevallo-field_c = l_datum.
*    Period end date
        WHEN  c_abevaz_a0ad002a.
          w_/zak/bevallo-field_c = $last_date.
*    Adjustment
        WHEN  c_abevaz_a0ad003a.
          IF $index NE '000'.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
      ENDCASE.
      MODIFY t_bevallo FROM w_/zak/bevallo.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " CALC_ABEV_PTGSZLAH
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_1565
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_T_AFA_SZLA_SUM  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*      -->P_W_/ZAK/BEVALL_OMREL  text
*----------------------------------------------------------------------*
FORM calc_abev_afa_1565  TABLES t_bevallo STRUCTURE /zak/bevallo
                                t_bevallb STRUCTURE /zak/bevallb
                                t_adoazon STRUCTURE /zak/onr_adoazon
                                t_afa_szla_sum STRUCTURE /zak/afa_szlasum
*++S4HANA#01.
*                          USING $DATE
*                                $INDEX
*                                $OMREL
                          USING $date TYPE sy-datum
                                $index TYPE /zak/index
                                $omrel TYPE /zak/bevall-omrel
*--S4HANA#01.
*++1665 #06.
                                $kiutalas.
*--1665 #06.
  DATA: l_sum            LIKE /zak/bevallo-field_n,
        l_sum_a0hd0001ca LIKE /zak/bevallo-field_n,
        l_sum_save       LIKE /zak/bevallo-field_n,
        l_kamat          LIKE /zak/bevallo-field_n,
        l_abev_sum       LIKE /zak/bevallo-field_n.
  DATA: l_kam_kezd  TYPE datum,
        l_kam_veg   TYPE datum,
        l_round(20) TYPE c,
        l_tabix     LIKE sy-tabix,
        l_upd.

  DATA: lw_afa_szla_sum TYPE /zak/afa_szlasum.
  DATA: l_lwste_sum TYPE /zak/lwste.
  DATA: l_olwste TYPE /zak/lwste.
  DATA: l_amount_external LIKE  bapicurr-bapicurr.
  TYPES: BEGIN OF lt_adoaz_szamlasza_sum,
           adoazon TYPE /zak/adoazon,
           lwste   TYPE /zak/lwste,
         END OF lt_adoaz_szamlasza_sum.
  DATA   li_adoaz_szamlasza_sum TYPE TABLE OF lt_adoaz_szamlasza_sum.
  DATA   lw_adoaz_szamlasza_sum TYPE lt_adoaz_szamlasza_sum.

************************************************************************
* Special ABEV fields

******************************************************** VAT only normal

  DATA: w_sz TYPE /zak/bevallb.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
*  Filling calculated fields
*++S4HANA#01.
*  REFRESH LR_ABEVAZ.
  CLEAR lr_abevaz[].
*--S4HANA#01.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0084ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0af001a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0af002a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0af005a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0af006a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0082ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0083ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0084ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0085ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0085ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0hc001a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0086ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0086ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ai002a   space.
  RANGES lr_monat FOR /zak/afa_szlasum-monat.


  SORT t_bevallb BY abevaz  .
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_abevaz.
    CLEAR : l_sum,w_/zak/bevallo.
* this line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.
* 84.C. Amount of tax payable (data of line 83 if without sign)
      WHEN c_abevaz_a0dd0084ca.
*++1765 #01.
        l_upd = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
        CLEAR l_sum.
        READ TABLE t_bevallo INTO w_sum
        WITH KEY abevaz = c_abevaz_a0dd0083ca.
        IF sy-subrc = 0.
          IF w_sum-field_n > 0.
            l_sum = w_sum-field_nrk.
            w_/zak/bevallo-field_n = l_sum.
          ELSE.
            CLEAR w_/zak/bevallo-field_n.
          ENDIF.
*++1765 #01.
*         L_UPD = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
        ENDIF.
* 00C Reporting period - from
      WHEN c_abevaz_a0af001a.
* Monthly
        IF w_/zak/bevall-bidosz = 'H'.
          l_kam_kezd = $date.
          l_kam_kezd+6(2) = '01'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Annual
        ELSEIF w_/zak/bevall-bidosz = 'E'.
          l_kam_kezd = $date.
          l_kam_kezd+4(4) = '0101'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Quarterly
        ELSEIF w_/zak/bevall-bidosz = 'N'.

          l_kam_kezd = $date.
          IF l_kam_kezd+4(2) >= '01' AND
             l_kam_kezd+4(2) <= '03'.

            l_kam_kezd+4(4) = '0101'.
          ENDIF.

          IF l_kam_kezd+4(2) >= '04' AND
             l_kam_kezd+4(2) <= '06'.

            l_kam_kezd+4(4) = '0401'.
          ENDIF.

          IF l_kam_kezd+4(2) >= '07' AND
             l_kam_kezd+4(2) <= '09'.

            l_kam_kezd+4(4) = '0701'.
          ENDIF.


          IF l_kam_kezd+4(2) >= '10' AND
             l_kam_kezd+4(2) <= '12'.

            l_kam_kezd+4(4) = '1001'.
          ENDIF.

          w_/zak/bevallo-field_c = l_kam_kezd.
        ELSE.
          l_kam_kezd = $date.
          l_kam_kezd+6(2) = '01'.
          w_/zak/bevallo-field_c = l_kam_kezd.
        ENDIF.

        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*00C Reporting period - to
      WHEN c_abevaz_a0af002a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*00C Type of return
      WHEN c_abevaz_a0af005a.
        IF w_/zak/bevallo-zindex GE '001'.
          w_/zak/bevallo-field_c = 'O'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*04 (O) Repeated self-audit indication (x)
      WHEN c_abevaz_a0hc001a.
*        ZINDEX > '001' --> 'X'     "repeated self-audit
        IF w_/zak/bevallo-zindex > '001'.
          w_/zak/bevallo-field_c = 'X'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*00C Filing frequency /H-monthly, N-quarterly, E-annual
      WHEN c_abevaz_a0af006a.
        w_/zak/bevallo-field_c = w_/zak/bevall-bidosz.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*82.B. Amount of deductible item to be credited from previous period (previous period
      WHEN c_abevaz_a0dd0082ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0082ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*83.C. Total amount of tax payable determined in the current period.
      WHEN c_abevaz_a0dd0083ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0083ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*84.B. Amount of tax payable (data of line 83 if without sign)
      WHEN c_abevaz_a0dd0084ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0084ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*85.B. Amount of tax reclaimable (line 83 with negative sign, ...
      WHEN c_abevaz_a0dd0085ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0085ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*86.B. Amount of claim transferable to next period
      WHEN c_abevaz_a0dd0086ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0086ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*00F year month day
      WHEN c_abevaz_a0ai002a.
        w_/zak/bevallo-field_c = sy-datum.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*85.C. Amount of tax reclaimable (line 83 with negative sign...
      WHEN  c_abevaz_a0dd0085ca.
*++1765 #01.
        l_upd = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
        READ TABLE t_bevallo INTO w_sum
             WITH KEY abevaz = c_abevaz_a0dd0083ca.
        IF sy-subrc EQ 0 AND w_sum-field_n < 0.
          CLEAR l_sum.
          l_sum = w_sum-field_nrk.
          READ TABLE t_bevallo INTO w_sum
               WITH KEY abevaz = c_abevaz_a0ag018a.
          IF sy-subrc EQ 0 AND NOT w_sum-field_c IS INITIAL.
            w_/zak/bevallo-field_n = abs( l_sum ).
*++1765 #01.
*         L_UPD = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
          ELSEIF sy-subrc EQ 0 AND w_sum-field_c IS INITIAL.
            CLEAR w_/zak/bevallo-field_n.
*++1765 #01.
*         L_UPD = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
          ENDIF.
        ENDIF.
*Transferred to next period
      WHEN  c_abevaz_a0dd0086ca.
*++1765 #01.
        l_upd = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
        READ TABLE t_bevallo INTO w_sum
             WITH KEY abevaz = c_abevaz_a0dd0083ca.
        IF sy-subrc EQ 0 AND w_sum-field_n < 0.
          CLEAR l_sum.
          l_sum = w_sum-field_nrk.
          READ TABLE t_bevallo INTO w_sum
               WITH KEY abevaz = c_abevaz_a0ag018a.
          IF sy-subrc EQ 0 AND NOT w_sum-field_c IS INITIAL.
            CLEAR w_/zak/bevallo-field_n.
*++1765 #01.
*         L_UPD = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
          ELSEIF sy-subrc EQ 0 AND w_sum-field_c IS INITIAL.
            w_/zak/bevallo-field_n = abs( l_sum ).
*++1765 #01.
*         L_UPD = 'X'. "Always need update, because if the amount reverses, it must be cleared
*--1765 #01.
          ENDIF.
        ENDIF.
    ENDCASE.
* fill every numeric value for calculated fields!
* the procedure for forming the sum is as follows:
* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
* then apply the configured rounding rule!
    IF NOT w_/zak/bevallb-collect IS INITIAL AND
       l_upd EQ 'X'.
      CLEAR l_round.
      PERFORM calc_field_nrk USING w_/zak/bevallo-field_n
                  w_/zak/bevallb-round
                  w_/zak/bevallo-waers
         CHANGING w_/zak/bevallo-field_nr
                  w_/zak/bevallo-field_nrk.
      MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
      CLEAR: l_sum,l_upd.
    ENDIF.
    CLEAR: l_upd,l_sum,l_round.

  ENDLOOP.

*  Calculation of dependent fields
*++S4HANA#01.
*  REFRESH LR_ABEVAZ.
  CLEAR lr_abevaz[].
*--S4HANA#01.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ag016a space.

  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_abevaz.
    CLEAR : l_sum,w_/zak/bevallo.
* this line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.

*00D I do not request disbursement
      WHEN c_abevaz_a0ag016a.
*++1665 #06.
        IF NOT $kiutalas IS INITIAL.
*--1665 #06.
          READ TABLE t_bevallo INTO w_sum
*++1665 #06.
*                WITH KEY ABEVAZ = C_ABEVAZ_A0DD0085CA.
               WITH KEY abevaz = $kiutalas.
*--1665 #06.
          IF sy-subrc EQ 0 AND w_sum-field_n NE 0.
            w_/zak/bevallo-field_c = c_x.
            MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
          ELSEIF sy-subrc EQ 0 AND w_sum-field_n EQ 0.
            CLEAR w_/zak/bevallo-field_c.
            MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
          ENDIF.
*++1665 #06.
        ENDIF.
*--1665 #06.
    ENDCASE.
* fill every numeric value for calculated fields!
* the procedure for forming the sum is as follows:
* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
* then apply the configured rounding rule!
    IF NOT w_/zak/bevallb-collect IS INITIAL AND
       l_upd EQ 'X'.
      CLEAR l_round.
      PERFORM calc_field_nrk USING w_/zak/bevallo-field_n
                  w_/zak/bevallb-round
                  w_/zak/bevallo-waers
         CHANGING w_/zak/bevallo-field_nr
                  w_/zak/bevallo-field_nrk.
      MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
      CLEAR: l_sum,l_upd.
    ENDIF.
    CLEAR: l_upd,l_sum,l_round.

  ENDLOOP.

*  Calculation of A0AE005A and A0AE006A
*   REFRESH LR_ABEVAZ.
*   LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB
*                    WHERE NOT ONYBF IS INITIAL.
*     M_DEF LR_ABEVAZ 'I' 'EQ' W_/ZAK/BEVALLB-ABEVAZ SPACE.
*   ENDLOOP.
*   IF NOT LR_ABEVAZ[] IS INITIAL.
*     LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO
*                      WHERE ABEVAZ IN LR_ABEVAZ
*                        AND FIELD_NRK IS NOT INITIAL.
*       EXIT.
*     ENDLOOP.
**    There is a value
*     IF SY-SUBRC EQ 0.
**    The value of A0AE004A must be checked
*       READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
*                        WITH KEY ABEVAZ = C_ABEVAZ_A0AE004A.
*       IF SY-SUBRC EQ 0 AND NOT W_/ZAK/BEVALLO-FIELD_C IS INITIAL.
** this line must be modified!
*         READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
*                          WITH KEY ABEVAZ = C_ABEVAZ_A0AE006A.
*         IF SY-SUBRC EQ 0.
*           V_TABIX = SY-TABIX .
*           W_/ZAK/BEVALLO-FIELD_C = C_X.
*           MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*         ENDIF.
** this line must be deleted
*         READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
*                          WITH KEY ABEVAZ = C_ABEVAZ_A0AE005A.
*         IF SY-SUBRC EQ 0.
*           V_TABIX = SY-TABIX .
*           CLEAR W_/ZAK/BEVALLO-FIELD_C.
*           MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*         ENDIF.
*       ELSEIF SY-SUBRC EQ 0 AND  W_/ZAK/BEVALLO-FIELD_C IS INITIAL.
** this line must be modified!
*         READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
*                          WITH KEY ABEVAZ = C_ABEVAZ_A0AE005A.
*         IF SY-SUBRC EQ 0.
*           V_TABIX = SY-TABIX .
*           W_/ZAK/BEVALLO-FIELD_C = C_X.
*           MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*         ENDIF.
** this line must be deleted
*         READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
*                          WITH KEY ABEVAZ = C_ABEVAZ_A0AE006A.
*         IF SY-SUBRC EQ 0.
*           V_TABIX = SY-TABIX .
*           CLEAR W_/ZAK/BEVALLO-FIELD_C.
*           MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*   ENDIF.

*  Calculation of VAT summary report fields below the threshold
  IF NOT $omrel IS INITIAL.
*  Threshold
    l_amount_external = w_/zak/bevall-olwste.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        currency             = c_huf
        amount_external      = l_amount_external
        max_number_of_digits = 20
      IMPORTING
        amount_internal      = l_olwste
*       RETURN               =
      .
*  Month handling
*++S4HANA#01.
*    REFRESH LR_MONAT.
    CLEAR lr_monat[].
*--S4HANA#01.
    IF w_/zak/bevall-bidosz = 'H'.
      m_def lr_monat 'I' 'EQ' $date+4(2) space.
    ELSEIF w_/zak/bevall-bidosz = 'N'.
      CASE $date+4(2).
        WHEN '03'.
          m_def lr_monat 'I' 'BT' '01' '03'.
        WHEN '06'.
          m_def lr_monat 'I' 'BT' '03' '06'.
        WHEN '09'.
          m_def lr_monat 'I' 'BT' '06' '09'.
        WHEN '12'.
          m_def lr_monat 'I' 'BT' '10' '12'.
      ENDCASE.
    ELSEIF w_/zak/bevall-bidosz = 'E'.
      m_def lr_monat 'I' 'BT' '01' '12'.
    ENDIF.
*    Determination of amount by tax number, by invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE mlap   IS INITIAL
                            AND nylapazon(3) = c_nylapazon_m02.
*      Only need to aggregate within the month
      CHECK lw_afa_szla_sum-gjahr EQ $date(4) AND
            lw_afa_szla_sum-monat IN lr_monat.
      CLEAR lw_adoaz_szamlasza_sum.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      lw_adoaz_szamlasza_sum-lwste      = lw_afa_szla_sum-lwste.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.
*    Determination of threshold
*    Writing back the amount by tax number
    READ TABLE t_bevallb INTO w_/zak/bevallb
                       WITH KEY abevaz = c_abevaz_m0ae0006da.

    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*      If it appears on the M sheet or the threshold is greater than configured
      READ TABLE t_afa_szla_sum TRANSPORTING NO FIELDS
                 WITH KEY adoazon = lw_adoaz_szamlasza_sum-adoazon
                          nylapazon(3) = c_nylapazon_m02
                          mlap    = 'X'.

      IF sy-subrc NE 0 AND lw_adoaz_szamlasza_sum-lwste < l_olwste.
        CONTINUE.
      ENDIF.
*      this line must be modified!
      READ TABLE t_bevallo INTO w_/zak/bevallo
           WITH KEY abevaz  = c_abevaz_m0ae0006da
                    adoazon = lw_adoaz_szamlasza_sum-adoazon.
      IF sy-subrc EQ 0.
        v_tabix = sy-tabix.
      ELSE.
*        Creation of tax-number-specific ABEV
        PERFORM create_adosz_abev_in_bevallo TABLES t_bevallo
                                             USING  w_/zak/bevallo
                                                    w_/zak/bevallb
                                                    c_abevaz_m0ae0006da
                                                    lw_adoaz_szamlasza_sum-adoazon
                                                    v_tabix.

      ENDIF.
      CLEAR: w_/zak/bevallo-field_n,
             w_/zak/bevallo-field_nr,
             w_/zak/bevallo-field_nrk.

      w_/zak/bevallo-field_n = lw_adoaz_szamlasza_sum-lwste.

      PERFORM calc_field_nrk USING w_/zak/bevallo-field_n
                  w_/zak/bevallb-round
                  w_/zak/bevallo-waers
         CHANGING w_/zak/bevallo-field_nr
                  w_/zak/bevallo-field_nrk.
      MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

*    Filling other calculated fields on M main sheet
      PERFORM calc_abev_afa_1565_m TABLES t_bevallo
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.

*    Handling calculated fields on M sheet fields as well
    FREE li_adoaz_szamlasza_sum.
*    Determination of amount by tax number, by invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE NOT mlap   IS INITIAL.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.

    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*       Filling other calculated fields on M main sheet
      PERFORM calc_abev_afa_1565_m TABLES t_bevallo
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.
  ENDIF.


************************************************************************
****
* Calculation of self-audit surcharge
************************************************************************
****
  IF $index NE '000'.
* if A0DD0084CA - A0DD0084BA > 0 then this value, otherwise 0
    LOOP AT t_bevallb INTO w_/zak/bevallb
      WHERE  abevaz EQ     c_abevaz_a0hd0001ca.
      CLEAR: l_sum,l_sum_a0hd0001ca.
      LOOP AT t_bevallo INTO w_/zak/bevallo
        WHERE  abevaz EQ     c_abevaz_a0dd0084ba  OR
               abevaz EQ     c_abevaz_a0dd0084ca.
        IF w_/zak/bevallo-abevaz EQ c_abevaz_a0dd0084ba.
          l_sum = l_sum - w_/zak/bevallo-field_nrk.
        ELSE.
          l_sum = l_sum + w_/zak/bevallo-field_nrk.
        ENDIF.
      ENDLOOP.
      IF l_sum < 0 .
        CLEAR l_sum.
      ENDIF.
      l_sum_a0hd0001ca = l_sum_a0hd0001ca + l_sum.
      CLEAR l_sum.
* if (A0DD0086CA - A0DD0086BA) < 0 then subtract the calculated value
      LOOP AT t_bevallo INTO w_/zak/bevallo
        WHERE  abevaz EQ     c_abevaz_a0dd0086ca  OR
               abevaz EQ     c_abevaz_a0dd0086ba.
        IF w_/zak/bevallo-abevaz EQ c_abevaz_a0dd0086ba.
          l_sum = l_sum - w_/zak/bevallo-field_nrk.
        ELSE.
          l_sum = l_sum + w_/zak/bevallo-field_nrk.
        ENDIF.
      ENDLOOP.
      IF l_sum > 0 .
        CLEAR l_sum.
      ENDIF.
      l_sum_a0hd0001ca = l_sum_a0hd0001ca - l_sum.
      CLEAR l_sum.
* if A0DD0085CA - A0DD0085BA < 0 then subtract the calculated value
      LOOP AT t_bevallo INTO w_/zak/bevallo
        WHERE  abevaz EQ     c_abevaz_a0dd0085ca  OR
               abevaz EQ     c_abevaz_a0dd0085ba.
        IF w_/zak/bevallo-abevaz EQ c_abevaz_a0dd0085ba.
          l_sum = l_sum - w_/zak/bevallo-field_nrk.
        ELSE.
          l_sum = l_sum + w_/zak/bevallo-field_nrk.
        ENDIF.
      ENDLOOP.
      IF l_sum > 0 .
        CLEAR l_sum.
      ENDIF.
      l_sum_a0hd0001ca = l_sum_a0hd0001ca - l_sum.
      CLEAR l_sum.
*     If A0DD0082CA-A0DD0082BA < 0 then this amount must reduce
*     az L_SUM_A0HD0001CA-at.
      READ TABLE t_bevallo INTO w_/zak/bevallo
                           WITH KEY abevaz = c_abevaz_a0dd0082ca.
      IF sy-subrc EQ 0.
        l_sum = w_/zak/bevallo-field_nrk.
      ENDIF.

      READ TABLE t_bevallo INTO w_/zak/bevallo
                           WITH KEY abevaz = c_abevaz_a0dd0082ba.
      IF sy-subrc EQ 0.
        l_sum = l_sum - w_/zak/bevallo-field_nrk.
      ENDIF.

      IF l_sum < 0.
        l_sum_save = abs( l_sum ).
        ADD l_sum TO l_sum_a0hd0001ca.
      ENDIF.

      IF l_sum_a0hd0001ca < 0.
        ADD l_sum_a0hd0001ca TO l_sum_save.
        CLEAR l_sum_a0hd0001ca.
      ENDIF.
      READ TABLE t_bevallo INTO w_/zak/bevallo
      WITH KEY abevaz = w_/zak/bevallb-abevaz.
      v_tabix = sy-tabix .
      IF sy-subrc EQ 0.
        PERFORM calc_field_nrk USING l_sum_a0hd0001ca
                    w_/zak/bevallb-round
                    w_/zak/bevallo-waers
           CHANGING w_/zak/bevallo-field_nr
                    w_/zak/bevallo-field_nrk.
        w_/zak/bevallo-field_n = l_sum_a0hd0001ca.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
      ENDIF.
    ENDLOOP.


* Determination of self-audit surcharge
* Calculation of ABEV A0HD0002CA based on A0HD0001CA, if the index is 2 or greater then x1.5
    IF w_/zak/bevallo-zindex NE '000'.

      READ TABLE t_bevallb INTO w_/zak/bevallb
                           WITH KEY abevaz = c_abevaz_a0hd0002ca.
      IF sy-subrc EQ 0.
        CLEAR l_sum.
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_a0hd0001ca.
        IF sy-subrc = 0.
          l_sum = w_/zak/bevallo-field_nrk.
        ENDIF.
* period determination
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_23337.
        IF sy-subrc EQ 0 AND
        NOT w_/zak/bevallo-field_c IS INITIAL .
* determining the deadline for surcharge calculation! the 104
* tax type is needed for the /ZAK/ADONEM table key !!
          SELECT SINGLE fizhat INTO w_/zak/adonem-fizhat FROM /zak/adonem
                                WHERE bukrs  EQ w_/zak/bevallo-bukrs AND
                                                 adonem EQ c_adonem_104
                                                 .
          IF sy-subrc EQ 0.
* initial date of surcharge calculation
            CLEAR l_kam_kezd.
            l_kam_kezd = $date + 1 + w_/zak/adonem-fizhat.
* end date of surcharge calculation in the character field of ABEV line 5299
            CLEAR l_kam_veg.
            CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
              EXPORTING
                input  = w_/zak/bevallo-field_c
              IMPORTING
                output = l_kam_veg.
* surcharge calculation
            PERFORM calc_potlek USING    w_/zak/bevallo-bukrs
                                         w_/zak/bevallo-zindex
                                CHANGING l_kam_kezd
                                         l_kam_veg
                                         l_sum
                                         l_kamat. " A0HD0001CA --> A0HD0002CA
            READ TABLE t_bevallo INTO w_/zak/bevallo
                                 WITH KEY abevaz = c_abevaz_a0hd0002ca.
            v_tabix = sy-tabix.
            IF sy-subrc = 0.
              w_/zak/bevallo-field_n = l_kamat.
              PERFORM calc_field_nrk USING l_kamat
                         w_/zak/bevallb-round
                         w_/zak/bevallo-waers
                CHANGING w_/zak/bevallo-field_nr
                         w_/zak/bevallo-field_nrk.
*              The 0 flag value must be handled for form validation
*              miatt:
              IF NOT w_/zak/bevallo-field_n IS INITIAL AND
                 w_/zak/bevallo-field_nrk IS INITIAL.
                w_/zak/bevallo-null_flag = 'X'.
              ENDIF.
              MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*      If there is a value, A0HD0001CA must be corrected.
      IF NOT l_sum_save IS INITIAL.
        READ TABLE t_bevallo INTO w_/zak/bevallo
        WITH KEY abevaz = c_abevaz_a0hd0001ca.
        v_tabix = sy-tabix .
        IF sy-subrc EQ 0.
          ADD l_sum_save TO w_/zak/bevallo-field_n.
          READ TABLE t_bevallb INTO w_/zak/bevallb
               WITH KEY abevaz = c_abevaz_a0hd0001ca.
          IF sy-subrc EQ 0.
            PERFORM calc_field_nrk USING w_/zak/bevallo-field_n
                        w_/zak/bevallb-round
                        w_/zak/bevallo-waers
               CHANGING w_/zak/bevallo-field_nr
                        w_/zak/bevallo-field_nrk.
            MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*  Handling of 0 flag field
* If field1 not 0 or field2 not 0 or field3 not 0 or field4 not 0
* or field5 not 0 then set 0 flag
  PERFORM get_null_flag_init TABLES t_bevallo
                             USING  c_abevaz_a0hd0002ca
                             "0-flag setting
                                    c_abevaz_a0hd0001ca    "field1
                                    space                  "field2
                                    space                  "field3
                                    space                  "field4
                                    space                  "field5
                                    space.                 "field6

ENDFORM.                    " CALC_ABEV_AFA_1565
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_1565_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_LW_ADOAZ_SZAMLASZA_SUM_ADOAZON  text
*      -->P_W_/ZAK/BEVALL  text
*----------------------------------------------------------------------*
FORM calc_abev_afa_1565_m  TABLES   $t_bevallo STRUCTURE /zak/bevallo
                                     $t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                            USING    $ADOAZON
                            USING    $adoazon TYPE /zak/adoazon
*--S4HANA#01.
                                     $bevall    STRUCTURE /zak/bevall.

  DATA lw_bevallo   TYPE /zak/bevallo.
*++S4HANA#01.
*  DATA lw_analitika TYPE /zak/analitika.
  TYPES: BEGIN OF ts_lw_analitika_sel,
           adoazon TYPE /zak/analitika-adoazon,
           lifkun  TYPE /zak/analitika-lifkun,
           koart   TYPE /zak/analitika-koart,
           stcd1   TYPE /zak/analitika-stcd1,
           stcd3   TYPE /zak/analitika-stcd3,
           field_c TYPE /zak/analitika-field_c,
         END OF ts_lw_analitika_sel.
  DATA lw_analitika TYPE ts_lw_analitika_sel.
*--S4HANA#01.
  DATA l_name1 TYPE name1_gp.
  RANGES lr_monat FOR /zak/analitika-monat.

*  M0AC001A   Taxpayer tax number, can be taken from: A0AE001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac001a
                                  c_abevaz_a0ae001a
                                  $adoazon.
*  M0AC003A   Predecessor tax number, can be taken if not empty from: A0AE004A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac004a
                                  c_abevaz_a0ae004a
                                  $adoazon.

*  M0AC004A Taxpayer name, can be taken from: A0AE008A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac005a
                                  c_abevaz_a0ae005a
                                  $adoazon.

*  M0AD001A Reporting period - from, can be taken from: A0AF001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad001a
                                  c_abevaz_a0af001a
                                  $adoazon.

*  M0AD002A Reporting period - to, can be taken from: A0AF002A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad002a
                                  c_abevaz_a0af002a
                                  $adoazon.

* M0AC005A Partner tax number: place the M sheet ADOAZON here,
*if filled from STCD1 (from /ZAK/ANALITIKA take the customer or
*supplier code + KOART indicates whether supplier or customer!)
*M0AC006A if filled from STCD3
  READ TABLE $t_bevallo INTO lw_bevallo INDEX 1.
*  Month filling:
*++S4HANA#01.
*  REFRESH lr_monat.
  CLEAR lr_monat[].
*--S4HANA#01.
  IF $bevall-bidosz EQ 'H'.
    m_def lr_monat 'I' 'EQ' lw_bevallo-monat space.
  ELSEIF $bevall-bidosz EQ 'N'.
    IF lw_bevallo-monat BETWEEN '01' AND '03'.
*      M_DEF LR_MONAT 'I' 'EQ' '01' '03'.
      m_def lr_monat 'I' 'BT' '01' '03'.
    ELSEIF lw_bevallo-monat BETWEEN '04' AND '06'.
*      M_DEF LR_MONAT 'I' 'EQ' '04' '06'.
*++1565 #09.
*      M_DEF LR_MONAT 'I' 'EQ' '04' '06'.
      m_def lr_monat 'I' 'BT' '04' '06'.
*--1565 #09.
    ELSEIF lw_bevallo-monat BETWEEN '07' AND '09'.
*      M_DEF LR_MONAT 'I' 'EQ' '07' '09'.
      m_def lr_monat 'I' 'BT' '07' '09'.
    ELSEIF lw_bevallo-monat BETWEEN '10' AND '12'.
*      M_DEF LR_MONAT 'I' 'EQ' '10' '12'.
      m_def lr_monat 'I' 'BT' '10' '12'.
    ENDIF.
  ELSEIF $bevall-bidosz EQ 'E'.
*    M_DEF LR_MONAT 'I' 'EQ' '01' '12'.
    m_def lr_monat 'I' 'BT' '01' '12'.
  ENDIF.
*++S4HANA#01.
*  SELECT SINGLE * INTO lw_analitika
*                  FROM /zak/analitika
  SELECT adoazon lifkun koart stcd1 stcd3 field_c INTO lw_analitika
                FROM /zak/analitika UP TO 1 ROWS
*--S4HANA#01.
                WHERE bukrs   EQ lw_bevallo-bukrs
                  AND btype   EQ lw_bevallo-btype
                  AND gjahr   EQ lw_bevallo-gjahr
*                    AND monat   EQ lw_bevallo-monat
                  AND monat   IN lr_monat
*                    AND ZINDEX  EQ LW_BEVALLO-ZINDEX
                  AND zindex  LE lw_bevallo-zindex
                  AND adoazon EQ $adoazon
*++S4HANA#01.
                ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.
*++1765 #10.
*   IF SY-SUBRC EQ 0.
  IF sy-subrc EQ 0 AND NOT $adoazon IS INITIAL.
*--1765 #10.
    IF NOT lw_analitika-stcd3 IS INITIAL.
*     STCD3
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac007a
                                      lw_analitika-stcd3(8)
                                      $adoazon.
*     ELSEIF NOT  LW_ANALITIKA-STCD1 IS INITIAL.
*++1565 #05.
*   Since it must be filled otherwise ABEV raises an error
*   we read the first one where it exists!
    ELSE.
*++S4HANA#01.
*      SELECT SINGLE stcd3 INTO lw_analitika-stcd3
*                   FROM /zak/analitika
      SELECT stcd3 INTO lw_analitika-stcd3
             FROM /zak/analitika UP TO 1 ROWS
*--S4HANA#01.
               WHERE bukrs   EQ lw_bevallo-bukrs
                 AND btype   EQ lw_bevallo-btype
                 AND gjahr   EQ lw_bevallo-gjahr
                 AND monat   IN lr_monat
                 AND zindex  LE lw_bevallo-zindex
                 AND adoazon EQ $adoazon
                 AND stcd3   NE ''
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.
      IF sy-subrc EQ 0.
*       STCD3
        PERFORM get_afa_m_value  TABLES $t_bevallo
                                        $t_bevallb
                                 USING  c_abevaz_m0ac007a
                                        lw_analitika-stcd3(8)
                                        $adoazon.
      ENDIF.
*--1565 #05.
    ENDIF.
    IF NOT  lw_analitika-stcd1 IS INITIAL.
*      STCD1
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac006a
                                      lw_analitika-stcd1(8)
                                      $adoazon.
    ELSEIF NOT  lw_analitika-adoazon IS INITIAL.
*      ADOAZON
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac006a
                                      lw_analitika-adoazon
                                      $adoazon.
    ENDIF.
*    Customer name:
    IF lw_analitika-koart EQ 'D'.
      SELECT SINGLE name1 INTO l_name1
                          FROM kna1
                         WHERE kunnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "ha nem CPD
*--1765 #26.
*    Supplier name
    ELSEIF lw_analitika-koart EQ 'K'.
      SELECT SINGLE name1 INTO l_name1
                          FROM lfa1
                         WHERE lifnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "ha nem CPD
*--1765 #26.
    ENDIF.
*    On the DUMMY_R record the name is in field_c
    IF l_name1 IS INITIAL AND NOT lw_analitika-field_c IS INITIAL.
      l_name1 = lw_analitika-field_c.
    ENDIF.
    IF NOT l_name1 IS INITIAL.
*      NAME1
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac008a
                                      l_name1
                                      $adoazon.
    ELSE.
*      DUMMY_R FIELD_C field
      PERFORM get_afa_m_from_abev TABLES $t_bevallo
                                         $t_bevallb
                                  USING  c_abevaz_m0ac008a
                                         c_abevaz_dummy_r
                                         $adoazon.

    ENDIF.
  ENDIF.

ENDFORM.                    " CALC_ABEV_AFA_1565_M
*++15A60 #01. 2015.01.26
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONYB_15A60
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_onyb_15a60  TABLES t_bevallo STRUCTURE /zak/bevallo
                                  t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                           USING  $last_date.
                           USING  $last_date TYPE SY-DATUM.
*--S4HANA#01.

  DATA l_tabix LIKE sy-tabix.

  DATA l_gjahr TYPE gjahr.
  DATA l_monat TYPE monat.
  DATA l_begin_day LIKE sy-datum.

  CLEAR: l_gjahr,l_monat.

  l_gjahr = $last_date(4).
  l_monat = $last_date+4(2).
* E - Annual
  IF w_/zak/bevall-bidosz = 'E'.
    l_monat = '01'.
* N - Quarterly
  ELSEIF w_/zak/bevall-bidosz = 'N'.
    SUBTRACT 2 FROM l_monat.
* H - Monthly
  ELSEIF w_/zak/bevall-bidosz = 'H'.

  ENDIF.

  CONCATENATE l_gjahr l_monat '01' INTO l_begin_day.

* the following ABEV codes may appear only once, summary or character
  LOOP AT t_bevallb INTO w_/zak/bevallb
    WHERE  abevaz EQ     c_abevaz_a0ad001a
       OR  abevaz EQ     c_abevaz_a0ad002a
       OR  abevaz EQ     c_abevaz_a0ad003a
       OR  abevaz EQ     c_abevaz_a0ad004a.

* this line must be modified!
    LOOP AT t_bevallo INTO w_/zak/bevallo
                      WHERE abevaz = w_/zak/bevallb-abevaz.

      CASE w_/zak/bevallb-abevaz.

*++2010.02.11 RN
* this field is no longer on the 10A60
**    Signature date (sy-datum)
*         WHEN  C_ABEVAZ_24.
*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.
*--2010.02.11 RN
*    Period start date
        WHEN  c_abevaz_a0ad001a.
          w_/zak/bevallo-field_c = l_begin_day.
*    Period end date
        WHEN  c_abevaz_a0ad002a.
          w_/zak/bevallo-field_c = $last_date.
*    Filling correction flags
*    Always fill if self-revision:
        WHEN  c_abevaz_a0ad003a.
          IF w_/zak/bevallo-zindex NE '000'.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
*    Filing frequency
        WHEN  c_abevaz_a0ad004a.
          IF w_/zak/bevall-bidosz = 'H'.
            w_/zak/bevallo-field_c = 'H'.
          ELSEIF w_/zak/bevall-bidosz = 'N'.
            w_/zak/bevallo-field_c = 'N'.
          ENDIF.
      ENDCASE.
      MODIFY t_bevallo FROM w_/zak/bevallo.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " CALC_ABEV_ONYB_15A60
*--15A60 #01. 2015.01.26
*++1508 #01. 2015.02.02
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_M_SZJA_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_m_szja_1508  TABLES t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                                   t_adoazon_all STRUCTURE
                                                 /zak/adoazonlpsz
                           USING   $index
                                   $last_date.

  SORT t_bevallb BY abevaz.
  SORT t_bevallo BY abevaz adoazon lapsz.
  RANGES lr_abevaz FOR /zak/bevallb-abevaz.

*Special M calculations by tax ID
*M 02-371 d Consolidated tax base ( sum of lines 360-370 "D")
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0360da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0361da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0362da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0363da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0364da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0365da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0366da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0367da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0368da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0369da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0370da space.
*  field0 = field1+field2+...fieldN as many as in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0371da.           "field0

*M 02-374 d Tax advance base (difference of lines 371-372)
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0371da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0372da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0373da space.
*  field0 = field1-field2-........ fieldN as many as in the RANGE
  PERFORM get_sub_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0374da            "field0
                             '+'.      "The result cannot be '-'

*M 02-375 d Amount qualifying as wage from line 371 (lines 360-363 "D", 3
* 369-370 line "A" data)
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0360da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0361da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0362da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0363da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0369aa space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0370aa space.
*  field0 = field1+field2+...fieldN as many as in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0375da.           "field0

*  A0ZZ000002
  PERFORM get_sum_calc  TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0zz000002   "Modified field
                               c_abevaz_m0dd0469ca          "Source 1
                               space                        "Source 2
                               space                        "Source 3
                               space                        "Source 4
                               space                        "Source 5
                               space                        "Source 6
                               space                        "Source 7
                               space                        "Source 8
                               space                        "Source 9
                               space.                       "Source 10
*  A0ZZ000003
  PERFORM get_sum_calc  TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0zz000003   "Modified field
                               c_abevaz_m0dd0467ca          "Source 1
                               space                        "Source 2
                               space                        "Source 3
                               space                        "Source 4
                               space                        "Source 5
                               space                        "Source 6
                               space                        "Source 7
                               space                        "Source 8
                               space                        "Source 9
                               space.                       "Source 10

ENDFORM.                    " CALC_ABEV_M_SZJA_1508
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_SPECIAL_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_szja_special_1508  TABLES  t_bevallo STRUCTURE /zak/bevallo
                                          t_bevallb STRUCTURE
                                          /zak/bevallb
                                          t_adoazon STRUCTURE
                                          /zak/onr_adoazon
                                   USING  $index
                                          $date.


  DATA lr_cond TYPE range_c2 OCCURS 0 WITH HEADER LINE.
  DATA l_tmp_bevallo TYPE /zak/bevallo.
  DATA l_bevallo TYPE /zak/bevallo.

  FIELD-SYMBOLS: <field_n>, <field_nr>, <field_nrk>.

  DEFINE lm_get_field.
    IF &1 EQ '000'.
      ASSIGN w_/zak/bevallo-field_n   TO <field_n>.
      ASSIGN w_/zak/bevallo-field_nr  TO <field_nr>.
      ASSIGN w_/zak/bevallo-field_nrk TO <field_nrk>.
    ELSE.
      ASSIGN w_/zak/bevallo-field_on   TO <field_n>.
      ASSIGN w_/zak/bevallo-field_onr  TO <field_nr>.
      ASSIGN w_/zak/bevallo-field_onrk TO <field_nrk>.
    ENDIF.
    CLEAR: <field_n>, <field_nr>, <field_nrk>.
  END-OF-DEFINITION.

  DEFINE lm_get_spec_sum1.
    LOOP AT t_bevallo INTO l_bevallo WHERE abevaz = &1.
*      Determine the ABEV belonging to the condition
*      identifier value
      READ TABLE t_bevallo INTO l_tmp_bevallo
               WITH KEY abevaz  = &2
                        adoazon = l_bevallo-adoazon
                         lapsz  = l_bevallo-lapsz
                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        CONDENSE l_tmp_bevallo-field_c.
        IF l_tmp_bevallo-field_c IN &3.
          ADD l_bevallo-field_n TO <field_n>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  END-OF-DEFINITION.

  RANGES lr_abevaz     FOR /zak/bevallo-abevaz.
  RANGES lr_sel_abevaz FOR /zak/bevallo-abevaz.


  DEFINE lm_get_spec_sum2.
    IF NOT &1[] IS INITIAL.
      LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN &1.
        IF $index EQ '000'.
          ADD l_bevallo-field_n TO <field_n>.
        ELSE.
          ADD l_bevallo-field_on TO <field_n>.
        ENDIF.
      ENDLOOP.
    ENDIF.
  END-OF-DEFINITION.

  SORT t_bevallb BY abevaz.

*  Filling selection ABEVAZ
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0081ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0082ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0083ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0084ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0085ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0091ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0dc0092ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0093ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0094ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0095ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0096ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0097ca space.

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0100ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0101ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0102ca space.


* the following ABEV codes may appear only once, summary or character
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    this line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
             BINARY SEARCH.

    CHECK sy-subrc EQ 0.

    v_tabix = sy-tabix .

*    Special calculations
    CASE w_/zak/bevallb-abevaz.
*A 03-081 Social contribution tax reduced to 10% with START card
*(code 1: line 643 "c")
      WHEN  c_abevaz_a0dc0081ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '1' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*A 02-039 Social contribution tax reduced to 20% with START card (code 1
*code: line 644 "c"
      WHEN  c_abevaz_a0dc0082ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '1' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0644CA' 'M0JC007A' lr_cond.
*A 02-040 10% social contribution tax with START PLUS card
*(code 2: line 643 "c")
      WHEN  c_abevaz_a0dc0083ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*A 02-041 20% social contribution tax with START PLUS card
*(code 2: line 644 "c")
      WHEN  c_abevaz_a0dc0084ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0644CA' 'M0JC007A' lr_cond.
*A 02-042 10% social contribution tax with START EXTRA card
*tax (code 3: line 643 "c")
      WHEN  c_abevaz_a0dc0085ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '3' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*A 03-091 Employed in a position not requiring professional qualification
*12.5% social contribution (code 1: line 679 "c")
      WHEN  c_abevaz_a0dc0091ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '05' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*A 03-092 Under 25 with more than 180 days of employment
*12.5% social contribution (code 7: line 679 "c")
      WHEN  c_abevaz_a0dc0092ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '07' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*A 03-093 Employees over 55 with 12.5% social contribution (code 8: line 679 "c")
      WHEN  c_abevaz_a0ec0093ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '08' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*A 03-094 GYED/GYES/GYET employees 12.5% social contribution (code 10: line 679 "c")
      WHEN  c_abevaz_a0ec0094ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '10' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*A 03-095 Enterprises operating in free enterprise zone 12.5% social contribution
*(code 11: line 679 "c")
      WHEN  c_abevaz_a0ec0095ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '11' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*A 04-096 National higher education doctoral training 12.5% social contribution discount
*(code 13: line 678 "c")
      WHEN  c_abevaz_a0ec0096ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '13' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*A 04-097 12.5% social contribution paid for long-term jobseekers
*(code 09, line 679 "c")
      WHEN  c_abevaz_a0ec0097ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '09' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0679CA' 'M0KC007A' lr_cond.
*04-100 Pension contribution charged to the private individual
*(lines 563, 604, 611 "c" values except 25, 42, 81, 83, 92, 93)
      WHEN  c_abevaz_a0ec0100ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'E' 'EQ' '25' space.
        m_def lr_cond 'E' 'EQ' '42' space.
        m_def lr_cond 'E' 'EQ' '81' space.
        m_def lr_cond 'E' 'EQ' '83' space.
        m_def lr_cond 'E' 'EQ' '92' space.
        m_def lr_cond 'E' 'EQ' '93' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0GD0579CA' 'M0GC004A' lr_cond.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*A 03-56-c Unemployment and jobseeker pension burden on private individuals
*(line 611 "c" values for employees min 25, 42, 81)
      WHEN  c_abevaz_a0ec0101ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '25' space.
        m_def lr_cond 'I' 'EQ' '42' space.
        m_def lr_cond 'I' 'EQ' '81' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*A 03-57-c Pension paid by private individual after GYED, S, T (lines 603, 611
*"c" for employees min 83, 92, 93)
      WHEN c_abevaz_a0ec0102ca.
*        Filling condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '83' space.
        m_def lr_cond 'I' 'EQ' '92' space.
        m_def lr_cond 'I' 'EQ' '93' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
    ENDCASE.

    PERFORM calc_field_nrk USING <field_n>
                 w_/zak/bevallb-round
                 w_/zak/bevallo-waers
        CHANGING <field_nr>
                 <field_nrk>.
    IF $index NE '000'.
      MOVE 'X' TO w_/zak/bevallo-oflag.
    ENDIF.
    MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

  ENDLOOP.


ENDFORM.                    " CALC_ABEV_SZJA_SPECIAL_1508
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_szja_1508  TABLES  t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                            USING  $date
                                   $index.

  DATA: l_kam_kezd TYPE datum.

  DATA: BEGIN OF li_adoazon OCCURS 0,
          adoazon TYPE /zak/adoazon,
        END OF li_adoazon.
  DATA: l_bevallo TYPE /zak/bevallo.

*  For determining self-audit
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  RANGES lr_sel_abevaz FOR /zak/bevallo-abevaz.

************************************************************************
* Special ABEV fields
************************************************************************

  SORT t_bevallb BY abevaz  .

* the following ABEV codes may appear only once, summary or character
* the following ABEV codes may appear only once, summary or character

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac039a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac040a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac044a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac041a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0gc001a space.

  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    this line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
         BINARY SEARCH.

    CHECK sy-subrc EQ 0.
    v_tabix = sy-tabix .


    CASE w_/zak/bevallb-abevaz.
*      period-from first day
      WHEN c_abevaz_a0ac039a.
* Monthly
        IF w_/zak/bevall-bidosz = 'H'.
          l_kam_kezd = $date.
          l_kam_kezd+6(2) = '01'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Annual
        ELSEIF w_/zak/bevall-bidosz = 'E'.
          l_kam_kezd = $date.
          l_kam_kezd+4(4) = '0101'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Quarterly
        ELSEIF w_/zak/bevall-bidosz = 'N'.

          l_kam_kezd = $date.
          IF l_kam_kezd+4(2) >= '01' AND
             l_kam_kezd+4(2) <= '03'.

            l_kam_kezd+4(4) = '0101'.
          ENDIF.

          IF l_kam_kezd+4(2) >= '04' AND
             l_kam_kezd+4(2) <= '06'.

            l_kam_kezd+4(4) = '0401'.
          ENDIF.

          IF l_kam_kezd+4(2) >= '07' AND
             l_kam_kezd+4(2) <= '09'.

            l_kam_kezd+4(4) = '0701'.
          ENDIF.


          IF l_kam_kezd+4(2) >= '10' AND
             l_kam_kezd+4(2) <= '12'.

            l_kam_kezd+4(4) = '1001'.
          ENDIF.

          w_/zak/bevallo-field_c = l_kam_kezd.
        ELSE.
          l_kam_kezd = $date.
          l_kam_kezd+6(2) = '01'.
          w_/zak/bevallo-field_c = l_kam_kezd.
        ENDIF.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

*      period-to last day
      WHEN c_abevaz_a0ac040a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

*      Number of taxpayers = Tax numbers
      WHEN c_abevaz_a0ac044a.

        REFRESH li_adoazon.
        LOOP AT t_bevallo INTO l_bevallo.
          CHECK NOT l_bevallo-adoazon IS INITIAL.
          MOVE l_bevallo-adoazon TO li_adoazon.
          COLLECT li_adoazon.
        ENDLOOP.


        DESCRIBE TABLE li_adoazon LINES sy-tfill.
        IF NOT sy-tfill IS INITIAL.
          w_/zak/bevallo-field_c = sy-tfill.
        ELSE.
          CLEAR w_/zak/bevallo-field_c.
        ENDIF.

        CONDENSE w_/zak/bevallo-field_c.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*      Adjustment, Self-audit
      WHEN c_abevaz_a0ac041a.
*        Only for self-audit
        IF $index NE '000'.
          REFRESH lr_abevaz.
*          Search for numeric value in this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0gd0150da
                                   c_abevaz_a0gd0182da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hc0190ca
                                   c_abevaz_a0he0200ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          We monitor the rounded amount because FIELD_N
*          is not empty but no value appears in the return due to the factor.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          There is a value:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'O'.
*          Correction
          ELSE.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*      Repeated self-audit
      WHEN c_abevaz_a0gc001a.
*        Only for self-audit
        IF $index > '001'.
          REFRESH lr_abevaz.
*          Search for numeric value in this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0gd0150da
                                   c_abevaz_a0gd0182da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hc0190ca
                                   c_abevaz_a0he0200ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          We monitor the rounded amount because FIELD_N
*          is not empty but no value appears in the return due to the factor.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          There is a value:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'X'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " CALC_ABEV_SZJA_1508
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_0_SZJA_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_SPACE  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_0_szja_1508  TABLES  t_bevallo STRUCTURE /zak/bevallo
                              t_adoazon_all STRUCTURE /zak/adoazonlpsz
                              USING   $onrev
                                      $date
                                      $index.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  DATA   lr_value  LIKE range_c3 OCCURS 0 WITH HEADER LINE.
  DATA   lr_value2 LIKE range_c3 OCCURS 0 WITH HEADER LINE.

* To avoid extending every FORM, manage self-revision in a global
* variable:
  CLEAR v_onrev.
  IF NOT $onrev IS INITIAL.
    MOVE $onrev TO v_onrev.
  ENDIF.

**  If field1 >= field2 then set field3 0 flag
*   PERFORM GET_NULL_FLAG TABLES T_BEVALLO
*                                T_ADOAZON_ALL
*                         USING  C_ABEVAZ_M0BC0382CA         "field1
*                                C_ABEVAZ_M0BC0382BA         "field2
*                                C_ABEVAZ_M0BC0382DA.        "field3
**  If field1+field2+field3+field4 > 0 then set 0 flag
*   PERFORM GET_NULL_FLAG_ASUM TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0IC0284HA
*                              "0-flag setting
*                                     C_ABEVAZ_A0IC0284CA    "field1
*                                     C_ABEVAZ_A0IC0284DA    "field2
*                                     C_ABEVAZ_A0IC0284EA    "field3
*                                     SPACE.                 "field4
** If field1 not 0 or field2 not 0 or field3 not 0 or field4 not 0
** or field5 not 0 then set 0 flag
*   PERFORM GET_NULL_FLAG_INIT TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0DC0087DA    "0flag
*                                     C_ABEVAZ_A0DC0087CA    "field1
*                                     SPACE                  "field2
*                                     SPACE                  "field3
*                                     SPACE                  "field4
*                                     SPACE                  "field5
*                                     SPACE.                 "field6
*   PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                      T_ADOAZON_ALL
*                               USING  C_ABEVAZ_M0CC0415DA   "0flag
*                                      C_ABEVAZ_M0BC0382BA   "field1
*                                      C_ABEVAZ_M0BC0386BA   "field2
*                                      SPACE                 "field3
*                                      SPACE                 "field4
*                                      SPACE                 "field5
*                                      SPACE.                "field6
** set 0 flag on field1
*     PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
*                                 USING  C_ABEVAZ_A0BC50041A.
* If field1 = field2 then set 0 flag
*   PERFORM GET_NULL_FLAG_EQM TABLES T_BEVALLO
*                                    T_ADOAZON_ALL
*                             USING  C_ABEVAZ_M0FD0496AA     "field1
*                                    C_ABEVAZ_M0FD0495AA     "field2
*                                    C_ABEVAZ_M0FD0498BA     "0-flag
*                                    C_ABEVAZ_M0FD0497BA.    "0-flag
* If field1 is in LR_VALUE and LR_ABEVAZ >= 0 (OR), then set 0-flag
* perform get_null_flag_M_in_or_abevaz tables T_BEVALLO
*                                             T_ADOAZON_ALL
*                                             LR_VALUE
*                                             LR_ABEVAZ
*                                       using C_ABEVAZ_M0GC007A   "field1
*                                             C_ABEVAZ_M0GD0570CA."0-flag

*  If field1 >= field2 then set field3 0 flag
  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0361ca          "field1
                               c_abevaz_m0bc0361ba          "field2
                               c_abevaz_m0bc0361da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0361da          "field1
                               c_abevaz_m0bc0361ba          "field2
                               c_abevaz_m0bc0361ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0362ca          "field1
                               c_abevaz_m0bc0362ba          "field2
                               c_abevaz_m0bc0362da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0362da          "field1
                               c_abevaz_m0bc0362ba          "field2
                               c_abevaz_m0bc0362ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0365ca          "field1
                               c_abevaz_m0bc0365ba          "field2
                               c_abevaz_m0bc0365da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0365da          "field1
                               c_abevaz_m0bc0365ba          "field2
                               c_abevaz_m0bc0365ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0366ca          "field1
                               c_abevaz_m0bc0366ba          "field2
                               c_abevaz_m0bc0366da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0366da          "field1
                               c_abevaz_m0bc0366ba          "field2
                               c_abevaz_m0bc0366ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0367ca          "field1
                               c_abevaz_m0bc0367ba          "field2
                               c_abevaz_m0bc0367da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0367da          "field1
                               c_abevaz_m0bc0367ba          "field2
                               c_abevaz_m0bc0367ca.         "field3
*  set 0 flag on field1
  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0371da.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0374da.

*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0KD0682AA.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                    t_adoazon_all
                             USING  c_abevaz_m0kd0682aa     "0flag
                                    c_abevaz_m0kc001a       "field1
                                    space                   "field2
                                    space                   "field3
                                    space                   "field4
                                    space                   "field5
                                    space.                  "field6

*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0KD0682CA.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                    t_adoazon_all
                             USING  c_abevaz_m0kd0682ca     "0flag
                                    c_abevaz_m0kc001a       "field1
                                    space                   "field2
                                    space                   "field3
                                    space                   "field4
                                    space                   "field5
                                    space.                  "field6

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bd0400ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bd0401ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0642aa.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0642ca.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0645aa.

*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0JD0645CA.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                    t_adoazon_all
                             USING  c_abevaz_m0jd0645ca     "0flag
                                    c_abevaz_m0jc001a       "field1
                                    space                   "field2
                                    space                   "field3
                                    space                   "field4
                                    space                   "field5
                                    space.                  "field6

* Self-audit surcharge if self-revision
  IF $index NE '000'.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0hc0190ca.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0hc0192ca.
  ENDIF.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                    t_adoazon_all
                             USING  c_abevaz_m0kd0678ca     "0flag
                                    c_abevaz_m0kd0678aa     "field1
                                    space                   "field2
                                    space                   "field3
                                    space                   "field4
                                    space                   "field5
                                    space.                  "field6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0564ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a "field1
                                              c_abevaz_m0gd0566ca. "0 flag

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0568ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a "field1
                                              c_abevaz_m0gd0570ca. "0 flag

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0574ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0575ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0576ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a "field1
                                              c_abevaz_m0gd0578ca. "0 flag

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0567ca    "0flag
                                     c_abevaz_m0gd0565ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0flag
                                     c_abevaz_m0gd0569ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0577ca.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0579ca.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0hd0605ca    "0flag
                                     c_abevaz_m0hd0603ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

ENDFORM.                    " CALC_ABEV_0_SZJA_1508
*&---------------------------------------------------------------------*
*&      Form  GET_LAP_SZ_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*----------------------------------------------------------------------*
FORM get_lap_sz_1508  TABLES t_bevallo STRUCTURE  /zak/bevallalv.


  DATA l_alv LIKE /zak/bevallalv.
  DATA l_index LIKE sy-tabix.
  DATA l_tabix LIKE sy-tabix.
  DATA l_nylap LIKE sy-tabix.
  DATA l_bevallo_alv LIKE /zak/bevallalv.
  DATA l_null_flag TYPE /zak/null.

  CLEAR l_index.

*  Filling ranges for handling number of retirees
  m_def r_a0ac047a 'I' 'EQ' 'M0FC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0GC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0HC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0IC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0JC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0KC003A' space.

*  Values
  m_def r_nylapval 'I' 'EQ' '3' space.
  m_def r_nylapval 'I' 'EQ' '7' space.
  m_def r_nylapval 'I' 'EQ' '8' space.


  REFRESH i_nylap.

  LOOP AT i_/zak/bevallo INTO w_/zak/bevallo.
    l_tabix = sy-tabix.

*   To ensure dialog execution
    PERFORM process_ind_item USING '100000'
                                   l_index
                                   TEXT-p01.

*   Csak SZJA-nal
    IF  w_/zak/bevall-btypart EQ c_btypart_szja.
*      Collecting retiree tax numbers
      PERFORM call_nylap TABLES r_a0ac047a
                                r_nylapval
                         USING  w_/zak/bevallo.

    ENDIF.

    READ TABLE t_bevallo INTO l_alv WITH KEY
                  bukrs   = w_/zak/bevallo-bukrs
                  btype   = w_/zak/bevallo-btype
                  gjahr   = w_/zak/bevallo-gjahr
                  monat   = w_/zak/bevallo-monat
                  zindex  = w_/zak/bevallo-zindex
                  abevaz  = w_/zak/bevallo-abevaz
                  adoazon = w_/zak/bevallo-adoazon
                  lapsz   = w_/zak/bevallo-lapsz
                  BINARY SEARCH.
    IF sy-subrc EQ 0.
*  The 0 flag handling was not adequate
*  If self-revision calculation then T_BEVALLO needs the 0 flag
*  otherwise the I_/ZAK/BEVALLO 0 flag.
      IF NOT l_alv-oflag IS INITIAL.
        l_null_flag = l_alv-null_flag.
      ELSE.
        l_null_flag = w_/zak/bevallo-null_flag.
      ENDIF.
      MOVE-CORRESPONDING w_/zak/bevallo TO l_alv.
      l_alv-null_flag = l_null_flag.
      IF l_alv-oflag IS INITIAL.
        MODIFY t_bevallo FROM l_alv INDEX sy-tabix
                        TRANSPORTING field_c field_n field_nr field_nrk
                                     null_flag waers
                                      .
      ELSE.
        MODIFY t_bevallo FROM l_alv INDEX sy-tabix
                        TRANSPORTING field_c field_n  field_nr
                        field_nrk
                                     oflag   field_on field_onr
                                     field_onrk
                                     null_flag waers.
        PERFORM sum_onr TABLES t_bevallo
                        USING  l_alv
                               l_alv-field_on
                               l_alv-field_onr
                               l_alv-field_onrk.
      ENDIF.
    ELSE.
      READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
      WITH KEY abevaz = w_/zak/bevallo-abevaz.
      MOVE-CORRESPONDING w_/zak/bevallb TO l_alv.
      MOVE-CORRESPONDING w_/zak/bevallo TO l_alv.
      SELECT SINGLE abevtext INTO l_alv-abevtext
        FROM  /zak/bevallbt
             WHERE  langu   = sy-langu
             AND    btype   = w_/zak/bevallo-btype
             AND    abevaz  = w_/zak/bevallo-abevaz.
      l_alv-abevtext_disp = l_alv-abevtext.
      APPEND l_alv TO t_bevallo.
      SORT t_bevallo BY bukrs btype gjahr monat zindex abevaz adoazon
           lapsz.
    ENDIF.
    DELETE i_/zak/bevallo.
  ENDLOOP.

*  Determining retirees
  IF NOT i_nylap[] IS INITIAL.
    DESCRIBE TABLE i_nylap LINES l_nylap.
    READ TABLE t_bevallo INTO l_bevallo_alv
                         WITH KEY abevaz  = c_abevaz_a0ac045a
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE l_nylap TO l_bevallo_alv-field_c.
      CONDENSE l_bevallo_alv-field_c.
      MODIFY t_bevallo FROM l_bevallo_alv INDEX sy-tabix
                            TRANSPORTING field_c.
    ENDIF.
  ELSE.
    READ TABLE t_bevallo INTO l_bevallo_alv
                         WITH KEY abevaz  = c_abevaz_a0ac045a
                         BINARY SEARCH.
    IF sy-subrc EQ 0.
      CLEAR l_bevallo_alv-field_c.
      MODIFY t_bevallo FROM l_bevallo_alv INDEX sy-tabix
                            TRANSPORTING field_c.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_LAP_SZ_1508
*&---------------------------------------------------------------------*
*&      Form  DEL_ESDAT_FIELD_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_C_ABEVAZ_A0AC041A  text
*----------------------------------------------------------------------*
FORM del_esdat_field_1508 TABLES   $t_bevallo STRUCTURE /zak/bevallalv
                                     $t_bevallb STRUCTURE /zak/bevallb
                            USING    $abevaz_jelleg.

  DATA lw_/zak/bevallalv TYPE /zak/bevallalv.

*  Determine the character:
  READ TABLE $t_bevallo INTO lw_/zak/bevallalv
                        WITH KEY abevaz = $abevaz_jelleg
                        BINARY SEARCH.
*  In this case the due date does not need to be filled:
  IF sy-subrc EQ 0 AND lw_/zak/bevallalv-field_c = 'H'.
**  Value of ABEV identifier marked in ESDAT_FLAG
*     READ TABLE $T_BEVALLB INTO W_/ZAK/BEVALLB
*                         WITH KEY  ESDAT_FLAG = 'X'.
*     IF SY-SUBRC EQ 0.
*       READ TABLE $T_BEVALLO INTO LW_/ZAK/BEVALLALV
*                           WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
*                           BINARY SEARCH.
*       IF SY-SUBRC EQ 0.
*         V_TABIX = SY-TABIX .
*         CLEAR LW_/ZAK/BEVALLALV-FIELD_C.
*         MODIFY $T_BEVALLO FROM LW_/ZAK/BEVALLALV
*                               INDEX V_TABIX TRANSPORTING FIELD_C.
*       ENDIF.
*     ENDIF.
*  For corrections no 0 flag is needed in the self-audit surcharge either
    READ TABLE $t_bevallo INTO lw_/zak/bevallalv
                        WITH KEY abevaz = c_abevaz_a0gc0190ca
                        BINARY SEARCH.
    IF sy-subrc EQ 0 AND NOT lw_/zak/bevallalv-null_flag IS INITIAL.
      v_tabix = sy-tabix .
      CLEAR lw_/zak/bevallalv-null_flag.
      MODIFY $t_bevallo FROM lw_/zak/bevallalv
                            INDEX v_tabix TRANSPORTING null_flag.
    ENDIF.
  ENDIF.

ENDFORM.                    " DEL_ESDAT_FIELD_1508
*--1508 #01. 2015.02.02
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONREV_SZJA_1508
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_onrev_szja_1508  TABLES t_bevallo STRUCTURE /zak/bevallo
                                       t_bevallb STRUCTURE /zak/bevallb
                                       t_adoazon STRUCTURE
                                                 /zak/onr_adoazon
                            USING   $index
                                    $last_date.

  DATA li_last_bevallo LIKE /zak/bevallo OCCURS 0 WITH HEADER LINE.

  DATA l_last_index LIKE /zak/bevallo-zindex.
  DATA l_tabix LIKE sy-tabix.
  DATA l_true.

  RANGES lr_onrev_abevaz FOR /zak/bevallb-abevaz.
  DATA   l_abevaz LIKE /zak/bevallb-abevaz.

  DATA: l_kam_kezd TYPE datum,
        l_kam_veg  TYPE datum.
  DATA   l_kamat LIKE /zak/bevallo-field_n.
  DATA   l_kamat_sum LIKE /zak/bevallo-field_n.

*  To fill fields to be summed
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  If self-revision
  CHECK $index NE '000'.

  SORT t_bevallb BY abevaz.

*  Read the previous period 'A' ABEV identifiers
  READ TABLE t_bevallo INTO w_/zak/bevallo INDEX 1.
  CHECK sy-subrc EQ 0.
  l_last_index = $index - 1.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = l_last_index
    IMPORTING
      output = l_last_index.


  SELECT * INTO TABLE li_last_bevallo
                FROM  /zak/bevallo
               WHERE  bukrs   EQ w_/zak/bevallo-bukrs
                 AND  btype   EQ w_/zak/bevallo-btype
                 AND  gjahr   EQ w_/zak/bevallo-gjahr
                 AND  monat   EQ w_/zak/bevallo-monat
                 AND  zindex  EQ l_last_index
                 AND  adoazon EQ ''.

  SORT li_last_bevallo BY bukrs btype gjahr monat zindex abevaz.

*  Delete records that are not in the given period
*  were submitted.
  LOOP AT t_bevallo INTO w_/zak/bevallo
                    WHERE NOT adoazon IS INITIAL.
    READ TABLE t_adoazon WITH KEY adoazon = w_/zak/bevallo-adoazon
                                  BINARY SEARCH.
*    Record not needed.
    IF sy-subrc NE 0.
      DELETE t_bevallo.
      CONTINUE.
    ENDIF.
*  M 11 Mark with X if your return qualifies as a correction
    IF w_/zak/bevallo-abevaz EQ c_abevaz_m0ae003a.
      MOVE 'H' TO w_/zak/bevallo-field_c.
      MODIFY t_bevallo FROM w_/zak/bevallo TRANSPORTING field_c.
    ENDIF.
  ENDLOOP.

*  A0GD0150DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0150da   "Modified field
                                c_abevaz_a0bc0001ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0152DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0152da   "Modified field
                                c_abevaz_a0dc0076ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0152CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0152ca   "Modified field
                               c_abevaz_a0gd0152da
                               '0.16'.
*  A0GD0153DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0153da   "Modified field
                                c_abevaz_a0bc0007ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0154DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0154da   "Modified field
                                c_abevaz_a0dc0077ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0154CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0154ca   "Modified field
                               c_abevaz_a0gd0154da
                               '0.98'.
*  A0GD0155DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0155da   "Modified field
                                c_abevaz_a0cc0042ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0155CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0155ca   "Modified field
                               c_abevaz_a0gd0155da
                               '0.015'.
*  A0GD0156DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0156da   "Modified field
                                c_abevaz_a0ec0099ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0156CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0156ca   "Modified field
                               c_abevaz_a0gd0156da
                               '0.27'.
*  A0GD0157DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0157da   "Modified field
                                c_abevaz_a0ec0098ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0158DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0158da   "Modified field
                                c_abevaz_a0ec0103ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0158CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0158ca   "Modified field
                               c_abevaz_a0gd0158da
                               '0.10'.
*  A0GD0159DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0159da   "Modified field
                                c_abevaz_a0ec0105ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0159CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0159ca   "Modified field
                               c_abevaz_a0gd0159da
                               '0.15'.
*  A0GD0160DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0160da   "Modified field
                                c_abevaz_a0ec0111ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0162DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0162da   "Modified field
                                c_abevaz_a0zz000003         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0162CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0162ca   "Modified field
                               c_abevaz_a0gd0162da
                               '0.27'.
*  A0GD0163DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0163da   "Modified field
                                c_abevaz_a0zz000002         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0163CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0163ca   "Modified field
                               c_abevaz_a0gd0163da
                               '0.14'.
*  A0GD0165DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0165da   "Modified field
                                c_abevaz_a0bc0015ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0166DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0166da   "Modified field
                                c_abevaz_a0bc0014ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0167DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0167da   "Modified field
                                c_abevaz_a0bc0016ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0168DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0168da   "Modified field
                                c_abevaz_a0bc0017ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0168CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0168ca   "Modified field
                               c_abevaz_a0gd0168da
                               '0.06'.
*  A0GD0170DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0170da   "Modified field
                                c_abevaz_a0ec0113ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0171DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0171da   "Modified field
                                c_abevaz_a0ec0114ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0173DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0173da   "Modified field
                                c_abevaz_a0ec0120ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0173CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0173ca   "Modified field
                               c_abevaz_a0gd0173da
                               '0.04'.
*  A0GD0174DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0174da   "Modified field
                                c_abevaz_a0ec0121ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0174CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0174ca   "Modified field
                               c_abevaz_a0gd0174da
                               '0.03'.
*  A0GD0175DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0175da   "Modified field
                                c_abevaz_a0ec0122ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0175CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0175ca   "Modified field
                               c_abevaz_a0gd0175da
                               '0.015'.
*  A0GD0176DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0176da   "Modified field
                                c_abevaz_a0fc0124ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0176CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0176ca   "Modified field
                               c_abevaz_a0gd0176da
                               '0.095'.
*  A0GD0177DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0177da   "Modified field
                                c_abevaz_a0fc0125ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0177CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0177ca   "Modified field
                               c_abevaz_a0gd0177da
                               '0.20'.
*  A0GD0178DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0178da   "Modified field
                                c_abevaz_a0fc0126ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0178CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0178ca   "Modified field
                               c_abevaz_a0gd0178da
                               '0.111'.
*  A0GD0179DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0179da   "Modified field
                                c_abevaz_a0fc0127ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0179CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0179ca   "Modified field
                               c_abevaz_a0gd0179da
                               '0.15'.
*  A0GD0180AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0180aa   "Modified field
                                c_abevaz_a0fc0128ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0181AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0181aa   "Modified field
                                c_abevaz_a0fc0129ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0182DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0gd0182da   "Modified field
                                c_abevaz_a0ec0104ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
*  A0GD0182CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0gd0182ca   "Modified field
                               c_abevaz_a0gd0182da
                               '0.13'.
*  A0GD0151DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0152da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0153da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0gd0151da.
*  A0GD0161DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0162da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0163da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0164da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0165da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0166da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0167da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0168da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0gd0161da.
*  A0GD0169DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0170da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0171da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0gd0169da.
*  A0GD0172DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0173da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0174da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0gd0175da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0gd0172da.

ENDFORM.                    " CALC_ABEV_ONREV_SZJA_1508
*++1765 #28.
*&--------------------------------------------------------------------*
*&      Form  CALC_ABEV_0_AFA_1565
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*----------------------------------------------------------------------*
FORM calc_abev_0_afa_1565   TABLES  t_bevallo STRUCTURE /zak/bevallo.
** set 0 flag on field1
*     PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
*                                 USING  C_ABEVAZ_A0BC50041A.

  PERFORM get_null_flag_0     TABLES t_bevallo
                              USING  c_abevaz_a0bc0035ba.

  PERFORM get_null_flag_0     TABLES t_bevallo
                              USING  c_abevaz_a0bc0035ca.

  PERFORM get_null_flag_0     TABLES t_bevallo
                              USING  c_abevaz_a0dc0075ba.

  PERFORM get_null_flag_0     TABLES t_bevallo
                              USING  c_abevaz_a0dc0075ca.


ENDFORM.                    " CALC_ABEV_0_AFA_1565
*--1765 #28.
