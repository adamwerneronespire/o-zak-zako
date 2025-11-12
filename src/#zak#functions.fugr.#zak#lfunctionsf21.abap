*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF21.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_M_SZJA_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_T_ADOAZON_ALL text
*      -->P_$INDEX text
*      -->P_$LAST_DATE text
*----------------------------------------------------------------------*
FORM calc_abev_m_szja_2108  TABLES t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                                   t_adoazon_all STRUCTURE
                                   /zak/adoazonlpsz
                            USING  $index
                                   $last_date.

  SORT t_bevallb BY abevaz.
  SORT t_bevallo BY abevaz adoazon lapsz.
  RANGES lr_abevaz FOR /zak/bevallb-abevaz.

*Special M calculations as a tax ID
*M 02-316 d Combined tax base (sum of lines 300-306 and lines 312-315 "D")
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0304da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0305da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0306da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0312da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0313da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0314da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0315da space.
*  field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0316da.           "field0

*M 03-317 4 or more gy. reducing the consolidated tax base. Foster mothers
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0304ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0305ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0306ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0314ea space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0315ea space.
*  field0 = field1-field2-........ field as much as is in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0cc0317ba.          "field0

*++2108 #04.
* Discounts reducing the combined tax base in total
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0cc0317ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0cc0318ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0cc0319ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0cc0320ba space.
*  field0 = field1-field2-........ field as much as is in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0cc0321ba.          "field0
*--2108 #04.

*M 02-322 B Basis of the tax advance (difference between lines 316-31)
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0316da space.
*++2108 #03.
*  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_M0BC0321DA SPACE.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0cc0321ba space.
*--2108 #03.
*  field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM get_sub_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
*++2108 #03.
*                      USING C_ABEVAZ_M0BC0322BA "field0
                      USING  c_abevaz_m0cc0322ba            "field0
*--2108 #03.
                             '+'.                           "The result cannot be '-'

  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0314aa space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0315aa space.
*  field0 = field1-field2-........ field as much as is in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0cc0323ba.          "field0

ENDFORM.                    " CALC_ABEV_M_SZJA_2108
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_SZJA_SPECIAL_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_T_ADOAZON text
*      -->P_$INDEX text
*      -->P_$LAST_DATE text
*----------------------------------------------------------------------*
FORM calc_abev_szja_special_2108 TABLES t_bevallo STRUCTURE /zak/bevallo
                                        t_bevallb STRUCTURE /zak/bevallb
                                        t_adoazon STRUCTURE /zak/onr_adoazon
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
*      The ABEV for the condition must be determined
*      ID value
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

*  Uploading selective ABEVAZ
*++2108 #03.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0EC0101CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0EC0102CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0EC0103CA SPACE.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0101ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0102ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0103ca space.
*--2108 #03.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0104ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0105ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0106ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0107ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0108ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0120ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0121ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0122ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0he0177ba space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ge0178ba space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ge0179ba space.
* the following abev codes can only occur once, summary v. char
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
* A 04-101 Permanent jobseeker receives 12.5% unemployment benefit (code 9: 679.|
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0101CA.
      WHEN  c_abevaz_a0fc0101ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '09' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KE0695CA' 'M0KC007A' lr_cond.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
* 04-102 A GYED,GYES,GYET will take 12.5% socho (code 10: 67|
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0102CA.
      WHEN  c_abevaz_a0fc0102ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '10' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KE0695CA' 'M0KC007A' lr_cond.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*A 04-103 The shoulder operating in the free shoulder zone is 12.5% socho (11|
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0103CA.
      WHEN  c_abevaz_a0fc0103ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '11' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KE0695CA' 'M0KC007A' lr_cond.
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '13' space.
        m_def lr_cond 'I' 'EQ' '15' space.
        m_def lr_cond 'I' 'EQ' '16' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*04-10 does not require professional qualifications
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0104CA.
      WHEN  c_abevaz_a0fc0104ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '18' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0677CA' 'M0KC007A' lr_cond.
*04-105 is in the field of agricultural work
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0105CA.
      WHEN  c_abevaz_a0fc0105ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '19' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0677CA' 'M0KC007A' lr_cond.
*A 04-106 Those entering the labor market
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0106CA.
      WHEN  c_abevaz_a0fc0106ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '20' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0677CA' 'M0KC007A' lr_cond.
*04-107 in the framework of public employment
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0107CA.
      WHEN  c_abevaz_a0fc0107ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '23' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0677CA' 'M0KC007A' lr_cond.
*04-108 is the national higher education doctorate
*++2108 #03.
*      WHEN  C_ABEVAZ_A0EC0108CA.
      WHEN  c_abevaz_a0fc0108ca.
*--2108 #03.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '25' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0677CA' 'M0KC007A' lr_cond.
*A 04-120 The private individual's pension contribution (563,604,611|
      WHEN  c_abevaz_a0fc0120ca.
*        Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'E' 'EQ' '25' space.
        m_def lr_cond 'E' 'EQ' '42' space.
        m_def lr_cond 'E' 'EQ' '81' space.
        m_def lr_cond 'E' 'EQ' '83' space.
        m_def lr_cond 'E' 'EQ' '92' space.
        m_def lr_cond 'E' 'EQ' '93' space.
        m_def lr_cond 'E' 'EQ' '112' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0GD0579CA' 'M0GC004A' lr_cond.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
        lm_get_spec_sum1 'M0ID0619CA' 'M0IC004A' lr_cond.
*A 04-121-c The burden of unemployment, employment pension (605.s|
      WHEN  c_abevaz_a0fc0121ca.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '25' space.
        m_def lr_cond 'I' 'EQ' '42' space.
        m_def lr_cond 'I' 'EQ' '81' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*A 04-122-c The private sector pays pension after GYED, S, T (A 604|
      WHEN  c_abevaz_a0fc0122ca.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '83' space.
        m_def lr_cond 'I' 'EQ' '92' space.
        m_def lr_cond 'I' 'EQ' '93' space.
        m_def lr_cond 'I' 'EQ' '112' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*A 05-177-b The pension contribution to be paid by students (line 579, line 605)
*++2108 #11.
*      WHEN  C_ABEVAZ_A0HE0177BA.
      WHEN  c_abevaz_a0hd0177ba.
*--2108 #11.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '46' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0GD0579CA' 'M0GC004A' lr_cond.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*A 05-178-b Product insurance to be paid by students (lines 567
*++2108 #11.
*      WHEN  C_ABEVAZ_A0GE0178BA.
      WHEN  c_abevaz_a0hd0178ba.
*--2108 #11.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '46' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0GD0567CA' 'M0GC004A' lr_cond.
*A 05-179-b With money to be paid by the students eg.bizt (571.so
*++2108 #11.
*      WHEN  C_ABEVAZ_A0GE0179BA.
      WHEN  c_abevaz_a0hd0179ba.
*--2108 #11.
*       Upload condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '46' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0GD0571CA' 'M0GC004A' lr_cond.

    ENDCASE.
    IF <field_n> IS ASSIGNED AND NOT <field_n> IS INITIAL.
      PERFORM calc_field_nrk USING <field_n>
                                    w_/zak/bevallb-round
                                    w_/zak/bevallo-waers
                          CHANGING <field_nr>
                                   <field_nrk>.
    ENDIF.
    IF $index NE '000'.
      MOVE 'X' TO w_/zak/bevallo-oflag.
    ENDIF.
    MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_SZJA_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_$LAST_DATE text
*      -->P_$INDEX text
*----------------------------------------------------------------------*
FORM calc_abev_szja_2108   TABLES  t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                            USING  $date
                                   $index.

  DATA: l_kam_kezd TYPE datum.

  DATA: BEGIN OF li_adoazon OCCURS 0,
          adoazon TYPE /zak/adoazon,
        END OF li_adoazon.
  DATA: l_bevallo TYPE /zak/bevallo.

*  To define a self-check
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  RANGES lr_sel_abevaz FOR /zak/bevallo-abevaz.

************************************************************************
* Special abev fields
************************************************************************

  SORT t_bevallb BY abevaz  .

* the following abev codes can only occur once, summary v. char

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac039a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac040a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac044a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac041a space.
*++2108 #17.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0HC001A SPACE.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ic001a space.
*--2108 #17.
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    this line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
         BINARY SEARCH.

    CHECK sy-subrc EQ 0.
    v_tabix = sy-tabix .


    CASE w_/zak/bevallb-abevaz.
*      period from first day
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
* He is four years old
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

*      last day until period
      WHEN c_abevaz_a0ac040a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

*      Number of taxpayers = Tax numbers
      WHEN c_abevaz_a0ac044a.

        REFRESH li_adoazon.
*++2108 #20.
*        LOOP AT T_BEVALLO INTO L_BEVALLO.
        LOOP AT t_bevallo INTO l_bevallo WHERE abevaz EQ 'M0AC007A'. "KATA tax declarations are not required
*--2108 #20.
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
*      Correction, Self-check
      WHEN c_abevaz_a0ac041a.
*        Only in self-check
        IF $index NE '000'.
          REFRESH lr_abevaz.
*          A numerical value must be searched for in this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0id0193da
                                   c_abevaz_a0id0231da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0jc0240ca
                                   c_abevaz_a0je0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          We monitor the rounded sum because it may be FIELD_N
*          it is not empty, but no value is added to the return because of the fkator.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          There is value:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'O'.
*          Corrective
          ELSE.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*      Repeated self-check
*++2108 #17.
*      WHEN C_ABEVAZ_A0HC001A.
      WHEN c_abevaz_a0ic001a.
*--2108 #17.
*        Only in self-check
        IF $index > '001'.
          REFRESH lr_abevaz.
*          A numerical value must be searched for in this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0id0193da
                                   c_abevaz_a0id0231da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0jc0240ca
                                   c_abevaz_a0je0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          We monitor the rounded sum because it may be FIELD_N
*          it is not empty, but no value is added to the return because of the fkator.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          There is value:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'X'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAP_SZ_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*----------------------------------------------------------------------*
FORM get_lap_sz_2108  TABLES t_bevallo STRUCTURE  /zak/bevallalv.

  DATA l_alv LIKE /zak/bevallalv.
  DATA l_index LIKE sy-tabix.
  DATA l_tabix LIKE sy-tabix.
  DATA l_nylap LIKE sy-tabix.
  DATA l_bevallo_alv LIKE /zak/bevallalv.
  DATA l_null_flag TYPE /zak/null.
*++2108 #11.
  DATA li_/zak/bevallo   TYPE STANDARD TABLE OF /zak/bevallo INITIAL SIZE 0.
*--2108 #11.


  CLEAR l_index.

*  Upload RANKS to manage retired numbers
  m_def r_a0ac047a 'I' 'EQ' 'M0FC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0GC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0HC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0IC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0JC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0KC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0LC003A' space.

*  Values
  m_def r_nylapval 'I' 'EQ' '3' space.
  m_def r_nylapval 'I' 'EQ' '7' space.
  m_def r_nylapval 'I' 'EQ' '8' space.


  REFRESH i_nylap.
*++2108 #11.
  li_/zak/bevallo[] = i_/zak/bevallo[].
*--2108 #11.

  LOOP AT i_/zak/bevallo INTO w_/zak/bevallo.
    l_tabix = sy-tabix.

*   Dialog run for insurance
    PERFORM process_ind_item USING '100000'
          l_index
          TEXT-p01.

*   Only with SZJA
    IF  w_/zak/bevall-btypart EQ c_btypart_szja.
*      Collection of pensioner tax numbers
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
*  The 0 flag handling was not appropriate
*  If it is a self-revision calculation, the T_BEVALLO 0 flag is required
*  otherwise, the I_/ZAK/BEVALLO 0 flag.
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

*  Definition of pensioners
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
  ENDIF.                                 "Please enter the correct name of <...>.

*++2108 #11.
*Number of students with student contracts
  CLEAR l_index.
  REFRESH: r_a0ac047a, r_nylapval.
*  Loading RANKS
  m_def r_a0ac047a 'I' 'EQ' 'M0FC004A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0GC004A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0HC004A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0IC004A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0JC004A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0KC004A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0LC004A' space.
*  Values
  m_def r_nylapval 'I' 'EQ' '46' space.

  REFRESH i_nylap.

  i_/zak/bevallo[] = li_/zak/bevallo[].
  FREE li_/zak/bevallo.
  LOOP AT i_/zak/bevallo INTO w_/zak/bevallo WHERE abevaz IN r_a0ac047a.
    l_tabix = sy-tabix.
*   Dialog run for insurance
    PERFORM process_ind_item USING '100000'
          l_index
          TEXT-p01.

*   Only with SZJA
    IF  w_/zak/bevall-btypart EQ c_btypart_szja.
*      Collection of pensioner tax numbers
      PERFORM call_nylap TABLES r_a0ac047a
                                r_nylapval
                         USING  w_/zak/bevallo.

    ENDIF.
    DELETE i_/zak/bevallo.
  ENDLOOP.

  IF NOT i_nylap[] IS INITIAL.
    DESCRIBE TABLE i_nylap LINES l_nylap.
    READ TABLE t_bevallo INTO l_bevallo_alv
*++2108 #03.
*                          WITH KEY ABEVAZ  = C_ABEVAZ_A0HE0175AA
                          WITH KEY abevaz  = c_abevaz_a0hd0175aa
*--2108 #03.
                          BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE l_nylap TO l_bevallo_alv-field_c.
      CONDENSE l_bevallo_alv-field_c.
      MODIFY t_bevallo FROM l_bevallo_alv INDEX sy-tabix
      TRANSPORTING field_c.
    ENDIF.
  ELSE.
    READ TABLE t_bevallo INTO l_bevallo_alv
*++2108 #03.
*                          WITH KEY ABEVAZ  = C_ABEVAZ_A0HE0175AA
                          WITH KEY abevaz  = c_abevaz_a0hd0175aa
*--2108 #03.
                          BINARY SEARCH.
    IF sy-subrc EQ 0.
      CLEAR l_bevallo_alv-field_c.
      MODIFY t_bevallo FROM l_bevallo_alv INDEX sy-tabix
      TRANSPORTING field_c.
    ENDIF.
  ENDIF.                                 "Please enter the correct name of <...>.
*--2108 #11.

ENDFORM.                    " GET_LAP_SZ_2108
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_0_SZJA_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_ADOAZON_ALL text
*      -->P_SPACE text
*      -->P_$LAST_DATE text
*      -->P_$INDEX text
*----------------------------------------------------------------------*
FORM calc_abev_0_szja_2108   TABLES   t_bevallo STRUCTURE /zak/bevallo
                                      t_adoazon_all STRUCTURE /zak/adoazonlpsz
                              USING   $onrev
                                      $date
                                      $index.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  DATA   lr_value  LIKE range_c3 OCCURS 0 WITH HEADER LINE.
  DATA   lr_value2 LIKE range_c10 OCCURS 0 WITH HEADER LINE.

  DATA li_abev_range TYPE STANDARD TABLE OF t_abev_range.
  DATA ls_abev_range TYPE t_abev_range.

* So that you don't have to expand the self-revision to a global one for every FORM
* treated as a variable:
  CLEAR v_onrev.
  IF NOT $onrev IS INITIAL.
    MOVE $onrev TO v_onrev.
  ENDIF.
** If field1 >= field2 then field3 0 flag setting
*   PERFORM GET_NULL_FLAG TABLES T_BEVALLO
*                                T_ADOAZON_ALL
*                         USING C_ABEVAZ_M0BC0382CA "field1
*                                C_ABEVAZ_M0BC0382BA "field2
*                                C_ABEVAZ_M0BC0382DA.        "field 3
** If field1+field2+field3+field4 > 0 then 0 flag setting
*   PERFORM GET_NULL_FLAG_ASUM TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0IC0284HA
*                              "0-flag setting
*                                     C_ABEVAZ_A0IC0284CA "field1
*                                     C_ABEVAZ_A0IC0284DA "field2
*                                     C_ABEVAZ_A0IC0284EA "field3
*                                     SPACE.                 "field 4
** If field1 is not 0 or field2 is not 0 or field3 is not 0 or field4 is not 0
** or field 5 not 0 then 0 flag setting
*   PERFORM GET_NULL_FLAG_INIT TABLES T_BEVALLO
*                              USING C_ABEVAZ_A0DC0087DA "0flag
*                                     C_ABEVAZ_A0DC0087CA "field1
*                                     SPACE "field2
*                                     SPACE "field3
*                                     SPACE "field4
*                                     SPACE "field5
*                                     SPACE.                 "field 6
*   PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                      T_ADOAZON_ALL
*                               USING C_ABEVAZ_M0CC0415DA "0flag
*                                      C_ABEVAZ_M0BC0382BA "field1
*                                      C_ABEVAZ_M0BC0386BA "field2
*                                      SPACE "field3
*                                      SPACE "field4
*                                      SPACE "field5
*                                      SPACE.                "field 6
** 0 flag setting on field 1
*     PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
*                                 USING  C_ABEVAZ_A0BC50041A.
* If field1 = field2 then 0 flag is set
*   PERFORM GET_NULL_FLAG_EQM TABLES T_BEVALLO
*                                    T_ADOAZON_ALL
*                             USING C_ABEVAZ_M0FD0496AA "field1
*                                    C_ABEVAZ_M0FD0495AA "field2
*                                    C_ABEVAZ_M0FD0498BA "0-flag
*                                    C_ABEVAZ_M0FD0497BA.    "0-flag
* If field1 in LR_VALUE and LR_ABEVAZ >= 0 (or), then 0-flag
* perform get_null_flag_M_in_or_abevaz tables T_BEVALLO
*                                             T_ADOAZON_ALL
*                                             LR_VALUE
*                                             LR_ABEVAZ
*                                       using C_ABEVAZ_M0GC007A "field1
*                                             C_ABEVAZ_M0GD0570CA."0-flag
*     PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                        T_ADOAZON_ALL
*                                 USING  C_ABEVAZ_M0BD0341BA.
*  If field1 >= field2 then field3 0 flag setting
  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0301ca          "field 1
                               c_abevaz_m0bc0301ba          "field 2
                               c_abevaz_m0bc0301da.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0301da          "field 1
                               c_abevaz_m0bc0301ba          "field 2
                               c_abevaz_m0bc0301ca.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0302ca          "field 1
                               c_abevaz_m0bc0302ba          "field 2
                               c_abevaz_m0bc0302da.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0302da          "field 1
                               c_abevaz_m0bc0302ba          "field 2
                               c_abevaz_m0bc0302ca.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0305ca          "field 1
                               c_abevaz_m0bc0305ba          "field 2
                               c_abevaz_m0bc0305da.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0305da          "field 1
                               c_abevaz_m0bc0305ba          "field 2
                               c_abevaz_m0bc0305ca.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0306ca          "field 1
                               c_abevaz_m0bc0306ba          "field 2
                               c_abevaz_m0bc0306da.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0306da          "field 1
                               c_abevaz_m0bc0306ba          "field 2
                               c_abevaz_m0bc0306ca.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0307ca          "field 1
                               c_abevaz_m0bc0307ba          "field 2
                               c_abevaz_m0bc0307da.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0307da          "field 1
                               c_abevaz_m0bc0307ba          "field 2
                               c_abevaz_m0bc0307ca.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0312ca          "field 1
                               c_abevaz_m0bc0312ba          "field 2
                               c_abevaz_m0bc0312da.         "field 3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0312da          "field 1
                               c_abevaz_m0bc0312ba          "field 2
                               c_abevaz_m0bc0312ca.         "field 3

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cc0322ba    "0 flag
                                     c_abevaz_m0bc0316da    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cd0330ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cd0331ba.

  IF $index NE '000'.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0jc0240ca.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0jc0242ca.
  ENDIF.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0676ca    "0 flag
                                     c_abevaz_m0kd0676aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0564ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "field 1
                                              c_abevaz_m0gd0566ca. "0 flags

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0568ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "field 1
                                              c_abevaz_m0gd0570ca. "0 flags

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0574ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0575ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0576ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "field 1
                                              c_abevaz_m0gd0578ca. "0 flags

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0567ca    "0 flag
                                     c_abevaz_m0gd0564ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0 flag
                                     c_abevaz_m0gd0569ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0 flag
                                     c_abevaz_m0gd0570ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0hd0605ca    "0 flag
                                     c_abevaz_m0hd0603ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0577ca    "0 flag
                                     c_abevaz_m0gd0574ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0574ca.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0364da    "0 flag
                                     c_abevaz_m0ec0364ba    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0364ea    "0 flag
                                     c_abevaz_m0ec0364ba    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0368da    "0 flag
                                     c_abevaz_m0ec0368ba    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0368ea    "0 flag
                                     c_abevaz_m0ec0368ba    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0678aa    "0 flag
                                     c_abevaz_m0kd0673aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0678ca    "0 flag
                                     c_abevaz_m0kd0673aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0676aa    "0 flag
                                     c_abevaz_m0kd0673aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0676ca    "0 flag
                                     c_abevaz_m0kd0673aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0565ca    "0 flag
                                     c_abevaz_m0gd0564ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0569ca    "0 flag
                                     c_abevaz_m0gd0568ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0573ca    "0 flag
                                     c_abevaz_m0gd0572ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0319ba    "0 flag
                                     c_abevaz_m0bc0319aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cc0320ba    "0 flag
                                     c_abevaz_m0cc0320aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

*++2108 #04.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cc0321ba    "0 flag
                                     c_abevaz_m0cc0318ba    "field 1
                                     c_abevaz_m0cc0319ba    "field 2
                                     c_abevaz_m0cc0320ba    "field 3
*++2108 #11.
*                                     SPACE "field4
*                                     SPACE "field5
                                     c_abevaz_m0cc0319aa
                                     c_abevaz_m0cc0320aa
*--2108 #11.
                                     space.                  "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cc0322ba    "0 flag
                                     c_abevaz_m0cc0316ba    "field 1
                                     c_abevaz_m0cc0321ba    "field 2
                                     c_abevaz_m0cc0318ba    "field 3
*++2108 #11.
*                                     C_ABEVAZ_M0CC0319BA "field4
                                     c_abevaz_m0cc0319aa    "field 4
*                                     C_ABEVAZ_M0CC0320BA "field5
                                     c_abevaz_m0cc0320aa    "field 5
*--2108 #11.
                                     space.                 "field 6
*--2108 #04.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0567ca    "0 flag
                                     c_abevaz_m0gd0564ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0626ca.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0633ca    "0 flag
                                     c_abevaz_m0id0629ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ke0694ca    "0 flag
                                     c_abevaz_m0ke0694aa    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0629ca    "0 flag
                                     c_abevaz_m0id0626ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ'  c_abevaz_m0hd0600ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0hc008a    "field 1
                                              c_abevaz_m0hd0604ca. "0 flags
*++2108 #04.
  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ'  c_abevaz_m0id0626ca space.
  m_def lr_abevaz 'I' 'EQ'  c_abevaz_m0id0627ca space.
  m_def lr_abevaz 'I' 'EQ'  c_abevaz_m0id0628ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0ic007a    "field 1
                                              c_abevaz_m0id0630ca. "0 flags
*--2108 #04.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0629ca    "0 flag
                                     c_abevaz_m0id0627ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0629ca    "0 flag
                                     c_abevaz_m0id0628ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' '0' space.
  PERFORM get_null_flag_m_in_c_range   TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                        USING c_abevaz_m0ic003a    "field 1
                                              c_abevaz_m0id0629ca. "0 flags

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' '0' space.
  PERFORM get_null_flag_m_in_c_range   TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                        USING c_abevaz_m0ic003a    "field 1
                                              c_abevaz_m0id0633ca. "0 flags


  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0633ca    "0 flag
                                     c_abevaz_m0id0626ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6
*++2108 #03.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0ID0640CA.
*
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0ID0641CA.
*--2108 #03.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0643ca    "0 flag
                                     c_abevaz_m0id0641ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

*++2108 #04.
  REFRESH: lr_value2, li_abev_range.
  CLEAR ls_abev_range.

  m_def lr_value2  'I' 'EQ' '20' space.
  m_def lr_value2  'I' 'EQ' '71' space.
  m_def lr_value2  'I' 'EQ' '111' space.
  m_def lr_value2  'I' 'EQ' '72' space.
  m_def lr_value2  'I' 'EQ' '172' space.
  m_def lr_value2  'I' 'EQ' '63' space.
  m_def lr_value2  'I' 'EQ' '108' space.
  m_def lr_value2  'I' 'EQ' '109' space.
  m_def lr_value2  'I' 'EQ' '73' space.
  m_def lr_value2  'I' 'EQ' '70' space.
  m_def lr_value2  'I' 'EQ' '40' space.
  m_def lr_value2  'I' 'EQ' '44' space.
  m_def lr_value2  'I' 'EQ' '106' space.
  m_def lr_value2  'I' 'EQ' '23' space.
  m_def lr_value2  'I' 'EQ' '90' space.
  m_def lr_value2  'I' 'EQ' '84' space.
  m_def lr_value2  'I' 'EQ' '115' space.
  m_def lr_value2  'I' 'EQ' '110' space.
  m_def lr_value2  'I' 'EQ' '19' space.
  m_def lr_value2  'I' 'EQ' '64' space.
  m_def lr_value2  'I' 'EQ' '100' space.
  m_def lr_value2  'I' 'EQ' '173' space.

  ls_abev_range-abevaz = c_abevaz_m0ic004a.
  ls_abev_range-range[] = lr_value2[].
  APPEND ls_abev_range TO li_abev_range.
  CLEAR ls_abev_range.

*  REFRESH: LR_VALUE2.
*  M_DEF LR_VALUE2 'I' 'GE' '20200901' SPACE.
*  LS_ABEV_RANGE-ABEVAZ = C_ABEVAZ_M0LC00524A.
*  LS_ABEV_RANGE-RANGE[] = LR_VALUE2[].
*  APPEND LS_ABEV_RANGE TO LI_ABEV_RANGE.
*  CLEAR LS_ABEV_RANGE.

  REFRESH: lr_value2.
  m_def lr_value2 'E' 'EQ' '1' space.
  m_def lr_value2 'E' 'EQ' '2' space.
  ls_abev_range-abevaz = c_abevaz_m0fc008a.
  ls_abev_range-range[] = lr_value2[].
  MOVE 'X' TO ls_abev_range-noerr. "If there is no record, it is not an error!
  APPEND ls_abev_range TO li_abev_range.
  CLEAR ls_abev_range.
* 640 lines
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0id0640ca. "0 flags
* 641 lines
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0id0641ca. "0 flags
* 643 lines
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0id0643ca. "0 flags

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0id0634ca    "0 flag
                                     c_abevaz_m0id0640ca    "field 1
                                     space                  "field 2
                                     space                  "field 3
                                     space                  "field 4
                                     space                  "field 5
                                     space.                 "field 6

*--2108 #04.
*++2108 #13.
  REFRESH: lr_value2, li_abev_range.
  CLEAR ls_abev_range.
  m_def lr_value2 'E' 'EQ' '' space.
  ls_abev_range-abevaz = 'M0BC0306AA'.
  ls_abev_range-range[] = lr_value2[].
  MOVE 'X' TO ls_abev_range-noerr. "If there is no record, it is not an error!
  APPEND ls_abev_range TO li_abev_range.
  CLEAR ls_abev_range.
* 306 lines
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0bc0306ba. "0 flags
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0bc0306ca. "0 flags
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0bc0306da. "0 flags
* 307 lines
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0bc0307ba. "0 flags
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0bc0307ca. "0 flags
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0bc0307da. "0 flags
*--2108 #13.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_AFA_2165
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_T_ADOAZON text
*      -->P_T_AFA_SZLA_SUM text
*      -->P_$LAST_DATE text
*      -->P_$INDEX text
*      -->P_W_/ZAK/BEVALL_OMREL text
*      -->P_W_/ZAK/BEVALL_KIUTALAS text
*----------------------------------------------------------------------*
FORM calc_abev_afa_2165  TABLES t_bevallo STRUCTURE /zak/bevallo
                                t_bevallb STRUCTURE /zak/bevallb
                                t_adoazon STRUCTURE /zak/onr_adoazon
                                t_afa_szla_sum STRUCTURE /zak/afa_szlasum
*++S4HANA#01.
*                          USING $DATE
*                                $INDEX
*                                $OMREL
*                                $KIUTALAS.
                          USING $date TYPE sy-datum
                                $index TYPE /zak/index
                                $omrel TYPE /zak/bevall-omrel
                                $kiutalas TYPE /zak/bevall-kiutalas.
*--S4HANA#01.

  DATA: l_sum            LIKE /zak/bevallo-field_n,
        l_sum_a0id0001ca LIKE /zak/bevallo-field_n,
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
* Special abev fields

****************************************************** ONLY VAT normal

  DATA: w_sz TYPE /zak/bevallb.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
* Loading calculated fields
*++S4HANA#01.
*  REFRESH lr_abevaz.
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
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ic001a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0086ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0086ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ai002a   space.

  RANGES lr_monat FOR /zak/afa_szlasum-monat.
  DATA l_sum_not_valid TYPE xfeld.

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
* 84.C. Amount of tax to be paid (data of line 83, if unsigned)
      WHEN c_abevaz_a0dd0084ca.
        l_upd = 'X'. "You always have to update, because if the amount changes, you have to empty it
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
*          L_UPD = 'X'.
        ENDIF.
* 00C Declaration period from
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
* He is four years old
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
*00C Declaration period until
      WHEN c_abevaz_a0af002a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*00C Nature of declaration
      WHEN c_abevaz_a0af005a.
        IF w_/zak/bevallo-zindex GE '001'.
          w_/zak/bevallo-field_c = 'O'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*04 (O) Mark repeated self-check (x)
      WHEN c_abevaz_a0ic001a.
*        ZINDEX > '001' --> 'X' "repeated self-check
        IF w_/zak/bevallo-zindex > '001'.
          w_/zak/bevallo-field_c = 'X'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*00C Declaration frequency /H-monthly, N-quarterly, E-yearly
      WHEN c_abevaz_a0af006a.
        w_/zak/bevallo-field_c = w_/zak/bevall-bidosz.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*82.B. The amount of the reducing item that can be calculated from the previous period (previous year
      WHEN c_abevaz_a0dd0082ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0082ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*83.C. The total amount of tax payable in the subject period.
      WHEN c_abevaz_a0dd0083ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0083ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*84.B. Amount of tax to be paid (data of line 83, if unsigned)
      WHEN c_abevaz_a0dd0084ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0084ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*85.B. The amount of tax that can be reclaimed (line 83 with a negative sign, ...
      WHEN c_abevaz_a0dd0085ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0085ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*86.B. Amount of claim that can be carried over to the next period
      WHEN c_abevaz_a0dd0086ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0086ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*00F year month day
      WHEN c_abevaz_a0ai002a.
        w_/zak/bevallo-field_c = sy-datum.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*85.C. The amount of tax that can be reclaimed (line 83 with a negative sign...
      WHEN  c_abevaz_a0dd0085ca.
        l_upd = 'X'. "You always have to update, because if the amount changes, you have to empty it
        READ TABLE t_bevallo INTO w_sum
             WITH KEY abevaz = c_abevaz_a0dd0083ca.
        IF sy-subrc EQ 0 AND w_sum-field_n < 0.
          CLEAR l_sum.
          l_sum = w_sum-field_nrk.
          READ TABLE t_bevallo INTO w_sum
               WITH KEY abevaz = c_abevaz_a0ag018a.
          IF sy-subrc EQ 0 AND NOT w_sum-field_c IS INITIAL.
            w_/zak/bevallo-field_n = abs( l_sum ).
*
          ELSEIF sy-subrc EQ 0 AND w_sum-field_c IS INITIAL.
            CLEAR w_/zak/bevallo-field_n.
*            L_UPD = 'X'.
          ENDIF.
        ENDIF.
*Carried over to next period
      WHEN  c_abevaz_a0dd0086ca.
        l_upd = 'X'. "You always have to update, because if the amount changes, you have to empty it
        READ TABLE t_bevallo INTO w_sum
             WITH KEY abevaz = c_abevaz_a0dd0083ca.
        IF sy-subrc EQ 0 AND w_sum-field_n < 0.
          CLEAR l_sum.
          l_sum = w_sum-field_nrk.
          READ TABLE t_bevallo INTO w_sum
               WITH KEY abevaz = c_abevaz_a0ag018a.
          IF sy-subrc EQ 0 AND NOT w_sum-field_c IS INITIAL.
            CLEAR w_/zak/bevallo-field_n.
*            L_UPD = 'X'.
          ELSEIF sy-subrc EQ 0 AND w_sum-field_c IS INITIAL.
            w_/zak/bevallo-field_n = abs( l_sum ).
*            L_UPD = 'X'.
          ENDIF.
        ENDIF.
    ENDCASE.
* fill in all numerical values for calculated fields!
* the procedure for forming an amount is as follows:
* eg: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
* then apply the default rounding rule!
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
*  REFRESH lr_abevaz.
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

*00D I do not request a referral
      WHEN c_abevaz_a0ag016a.
        IF NOT $kiutalas IS INITIAL.
          READ TABLE t_bevallo INTO w_sum
*                WITH KEY ABEVAZ = C_ABEVAZ_A0DD0085CA.
               WITH KEY abevaz = $kiutalas.
          IF sy-subrc EQ 0 AND w_sum-field_n NE 0.
            w_/zak/bevallo-field_c = c_x.
            MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
          ELSEIF sy-subrc EQ 0 AND w_sum-field_n EQ 0.
            CLEAR w_/zak/bevallo-field_c.
            MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
          ENDIF.
        ENDIF.
    ENDCASE.
* fill in all numerical values for calculated fields!
* the procedure for forming an amount is as follows:
* eg: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
* then apply the default rounding rule!
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

*  Summary report Calculation of fields below the VAT value limit
  IF NOT $omrel IS INITIAL.
*  Value limit
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
*  Month treatment
*++S4HANA#01.
*    REFRESH lr_month.
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
*  Determination of amount per tax number, per invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE mlap   IS INITIAL
                            AND nylapazon(3) = c_nylapazon_m02.
*      It must only be aggregated within the month
      CHECK lw_afa_szla_sum-gjahr EQ $date(4) AND
            lw_afa_szla_sum-monat IN lr_monat.
      CLEAR lw_adoaz_szamlasza_sum.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      lw_adoaz_szamlasza_sum-lwste      = lw_afa_szla_sum-lwste.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.
*    Determination of value limit
    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*      If it is listed on sheet M or the value limit is greater than the set one
      READ TABLE t_afa_szla_sum TRANSPORTING NO FIELDS
                 WITH KEY adoazon = lw_adoaz_szamlasza_sum-adoazon
                          nylapazon(3) = c_nylapazon_m02
                          mlap    = 'X'.

      IF sy-subrc NE 0 AND lw_adoaz_szamlasza_sum-lwste < l_olwste.
        CONTINUE.
      ENDIF.
*     Filling filling of other calculated fields of main sheet M
      PERFORM calc_abev_afa_2165_m TABLES t_bevallo
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.

*    Management of calculated fields also on M flat fields
    FREE li_adoaz_szamlasza_sum.
*    Determination of amount per tax number, per invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE NOT mlap   IS INITIAL.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.

    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*       Filling filling of other calculated fields of main sheet M
*++2165 #04.
*      PERFORM CALC_ABEV_AFA_2065_M TABLES T_BEVALLO
      PERFORM calc_abev_afa_2165_m TABLES t_bevallo
*--2165 #04.
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.
  ENDIF.

************************************************************************
* calculation of self-check allowance
************************************************************************
  IF $index NE '000'.
* if A0DD0084CA - A0DD0084BA > 0 then this value, otherwise 0
    LOOP AT t_bevallb INTO w_/zak/bevallb
      WHERE  abevaz EQ     c_abevaz_a0id0001ca.
      CLEAR: l_sum,l_sum_a0id0001ca.
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
      l_sum_a0id0001ca = l_sum_a0id0001ca + l_sum.
      CLEAR l_sum.
* (A0DD0086CA - A0DD0086BA) < 0 then the calculated value is minus
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
      l_sum_a0id0001ca = l_sum_a0id0001ca - l_sum.
      CLEAR l_sum.
* A0DD0085CA - A0DD0085BA < 0 then the calculated value is minus
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
      l_sum_a0id0001ca = l_sum_a0id0001ca - l_sum.
      CLEAR l_sum.
*     If A0DD0082CA-A0DD0082BA < 0 then it must be reduced by this amount
*     L_SUM_A0ID0001CA.
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
        ADD l_sum TO l_sum_a0id0001ca.
      ENDIF.

      IF l_sum_a0id0001ca < 0.
        ADD l_sum_a0id0001ca TO l_sum_save.
        CLEAR l_sum_a0id0001ca.
      ENDIF.
      READ TABLE t_bevallo INTO w_/zak/bevallo
      WITH KEY abevaz = w_/zak/bevallb-abevaz.
      v_tabix = sy-tabix .
      IF sy-subrc EQ 0.
        PERFORM calc_field_nrk USING l_sum_a0id0001ca
                    w_/zak/bevallb-round
                    w_/zak/bevallo-waers
           CHANGING w_/zak/bevallo-field_nr
                    w_/zak/bevallo-field_nrk.
        w_/zak/bevallo-field_n = l_sum_a0id0001ca.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
      ENDIF.
    ENDLOOP.

* determination of self-control allowance
* Calculation of ABEV A0ID0002CA based on A0ID0001CA, if the index is 2 or higher, then x1.5
    IF w_/zak/bevallo-zindex NE '000'.

      READ TABLE t_bevallb INTO w_/zak/bevallb
                           WITH KEY abevaz = c_abevaz_a0id0002ca.
      IF sy-subrc EQ 0.
        CLEAR l_sum.
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_a0id0001ca.
        IF sy-subrc = 0.
          l_sum = w_/zak/bevallo-field_nrk.
        ENDIF.
* period definition
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_23337.
        IF sy-subrc EQ 0 AND
        NOT w_/zak/bevallo-field_c IS INITIAL .
* determining the deadline for calculating the allowance! the 104
* I don't need a tax for the /ZAK/ADONEM table key !!
          SELECT SINGLE fizhat INTO w_/zak/adonem-fizhat FROM /zak/adonem
                                WHERE bukrs  EQ w_/zak/bevallo-bukrs AND
                                                 adonem EQ c_adonem_104
                                                 .
          IF sy-subrc EQ 0.
* start date of allowance calculation
            CLEAR l_kam_kezd.
            l_kam_kezd = $date + 1 + w_/zak/adonem-fizhat.
* end date of allowance calculation in the character field of row 5299 above
            CLEAR l_kam_veg.
            CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
              EXPORTING
                input  = w_/zak/bevallo-field_c
              IMPORTING
                output = l_kam_veg.
* allowance calculation
            PERFORM calc_potlek USING    w_/zak/bevallo-bukrs
                                         w_/zak/bevallo-zindex
                                CHANGING l_kam_kezd
                                         l_kam_veg
                                         l_sum
                                         l_kamat. " A0ID0001CA --> A0ID0002CA
            READ TABLE t_bevallo INTO w_/zak/bevallo
                                 WITH KEY abevaz = c_abevaz_a0id0002ca.
            v_tabix = sy-tabix.
            IF sy-subrc = 0.
              w_/zak/bevallo-field_n = l_kamat.
              PERFORM calc_field_nrk USING l_kamat
                         w_/zak/bevallb-round
                         w_/zak/bevallo-waers
                CHANGING w_/zak/bevallo-field_nr
                         w_/zak/bevallo-field_nrk.
*              The value of the 0 flag must be handled in the form control
*              because of:
              IF NOT w_/zak/bevallo-field_n IS INITIAL AND
                 w_/zak/bevallo-field_nrk IS INITIAL.
                w_/zak/bevallo-null_flag = 'X'.
              ENDIF.
              MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*      If there is a value, A0ID0001CA must be corrected.
      IF NOT l_sum_save IS INITIAL.
        READ TABLE t_bevallo INTO w_/zak/bevallo
        WITH KEY abevaz = c_abevaz_a0id0001ca.
        v_tabix = sy-tabix .
        IF sy-subrc EQ 0.
          ADD l_sum_save TO w_/zak/bevallo-field_n.
          READ TABLE t_bevallb INTO w_/zak/bevallb
               WITH KEY abevaz = c_abevaz_a0id0001ca.
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








ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_AFA_2165_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_LW_ADOAZ_SZAMLASZA_SUM_ADOAZON text
*      -->P_W_/ZAK/BEVALL text
*----------------------------------------------------------------------*
FORM calc_abev_afa_2165_m  TABLES   $t_bevallo STRUCTURE /zak/bevallo
                                    $t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                            USING $adoazon
                            USING   $adoazon TYPE /zak/adoazon
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
           field_c TYPE /zak/analitika-field_c,
         END OF ts_lw_analitika_sel.
  DATA lw_analitika TYPE ts_lw_analitika_sel.
*--S4HANA#01.
  DATA l_name1 TYPE name1_gp.
  RANGES lr_monat FOR /zak/analitika-monat.
  DATA l_text50 TYPE text50.

*  M0AC001A Tax number of the taxpayer, can be taken from: A0AE001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac001a
                                  c_abevaz_a0ae001a
                                  $adoazon.
*  M0AC003A Tax number of your legal predecessor, can be taken if it is not empty: from A0AE004A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac003a
                                  c_abevaz_a0ae004a
                                  $adoazon.

*  M0AC004A Taxpayer name, can be taken from: A0AE008A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac004a
                                  c_abevaz_a0ae006a
                                  $adoazon.

*  M0AD001A Declaration period from, can be taken from: A0AF001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad001a
                                  c_abevaz_a0af001a
                                  $adoazon.

*  M0AD002A Declaration period until , can be taken from: A0AF002A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad002a
                                  c_abevaz_a0af002a
                                  $adoazon.
* The tax number is not empty
  IF NOT $adoazon IS INITIAL.
*   ADOAZON
    PERFORM get_afa_m_value  TABLES $t_bevallo
                                    $t_bevallb
                             USING  c_abevaz_m0ac005a
                                    $adoazon
                                    $adoazon.
*  Enter a group name
    CLEAR l_text50.
    SELECT SINGLE text50 INTO l_text50
                         FROM /zak/padonszt
                        WHERE adoazon EQ $adoazon.
    IF sy-subrc EQ 0 AND NOT l_text50 IS INITIAL.
*     NAME1
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac006a
                                      l_text50
                                      $adoazon.
    ENDIF.
  ENDIF.

* M0AC005A Partner's tax number: the M paper ADOAZON must be entered here,
*if it was loaded from STCD1 (the receiver or
*carrier code+KOART specifies how to ship. Or customer!)
*M0AC006A if loaded from STCD3
  READ TABLE $t_bevallo INTO lw_bevallo INDEX 1.
*  Upload month:
*++S4HANA#01.
*  REFRESH lr_month.
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
*  SELECT SINGLE * INTO lw_analytics
*                  FROM /zak/analytics
  SELECT adoazon lifkun koart stcd1 field_c INTO lw_analitika
                  FROM /zak/analitika UP TO 1 ROWS
*--S4HANA#01.
                  WHERE bukrs   EQ lw_bevallo-bukrs
                    AND btype   EQ lw_bevallo-btype
                    AND gjahr   EQ lw_bevallo-gjahr
*                    AND monat EQ lw_acknowledge-monat
                    AND monat   IN lr_monat
*                    AND ZINDEX  EQ LW_BEVALLO-ZINDEX
                    AND zindex  LE lw_bevallo-zindex
                    AND adoazon EQ $adoazon
*++S4HANA#01.
    ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.
  IF sy-subrc EQ 0 AND NOT $adoazon IS INITIAL.
    IF NOT  lw_analitika-stcd1 IS INITIAL.
*      STCD1
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
*++2165 #04.
*                               USING  C_ABEVAZ_M0AC006A
                               USING  c_abevaz_m0ac005a
*--2165 #04.
                                      lw_analitika-stcd1(8)
                                      $adoazon.
    ELSEIF NOT  lw_analitika-adoazon IS INITIAL.
*      ADOAZON
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
*++2165 #04.
*                               USING  C_ABEVAZ_M0AC006A
                               USING  c_abevaz_m0ac005a
*--2165 #04.
                                      lw_analitika-adoazon
                                      $adoazon.
    ENDIF.
*    Customer name:
    IF lw_analitika-koart EQ 'D'.
      SELECT SINGLE name1 INTO l_name1
                          FROM kna1
                         WHERE kunnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "if not CPD
*--1765 #26.
*    Supplier name
    ELSEIF lw_analitika-koart EQ 'K'.
      SELECT SINGLE name1 INTO l_name1
                          FROM lfa1
                         WHERE lifnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "if not CPD
*--1765 #26.
    ENDIF.
*    There is a name in field_c on a DUMMY_R record
    IF l_name1 IS INITIAL AND NOT lw_analitika-field_c IS INITIAL.
      l_name1 = lw_analitika-field_c.
    ENDIF.
    IF NOT l_name1 IS INITIAL.
*      NAME1
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac006a
                                      l_name1
                                      $adoazon.
    ELSE.
*      DUMMY_R FIELD_C field
      PERFORM get_afa_m_from_abev TABLES $t_bevallo
                                         $t_bevallb
                                  USING  c_abevaz_m0ac006a
                                         c_abevaz_dummy_r
                                         $adoazon.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_ONYB_21A60
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_$LAST_DATE text
*----------------------------------------------------------------------*
FORM calc_abev_onyb_21a60  TABLES t_bevallo STRUCTURE /zak/bevallo
                                  t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                           USING $last_date.
                           USING  $last_date TYPE sy-datum.
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
* Mon - Monthly
  ELSEIF w_/zak/bevall-bidosz = 'H'.

  ENDIF.

  CONCATENATE l_gjahr l_monat '01' INTO l_begin_day.

* the following abev codes can only occur once, summary v. char
  LOOP AT t_bevallb INTO w_/zak/bevallb
    WHERE  abevaz EQ     c_abevaz_a0ad001a
       OR  abevaz EQ     c_abevaz_a0ad002a
       OR  abevaz EQ     c_abevaz_a0ad004a
       OR  abevaz EQ     c_abevaz_a0ad005a.

* this line must be modified!
    LOOP AT t_bevallo INTO w_/zak/bevallo
                      WHERE abevaz = w_/zak/bevallb-abevaz.

      CASE w_/zak/bevallb-abevaz.

*++2010.02.11 RN
* this field is no longer on the 10A60
** Signature date (sy-datum)
*         WHEN  C_ABEVAZ_24.
*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.
*--2010.02.11 RN
*    PERIOD start date
        WHEN  c_abevaz_a0ad001a.
          w_/zak/bevallo-field_c = l_begin_day.
*    PERIOD closing date
        WHEN  c_abevaz_a0ad002a.
          w_/zak/bevallo-field_c = $last_date.
*    Loading correction flags
*    We always upload if self-revision:
        WHEN  c_abevaz_a0ad004a.
          IF w_/zak/bevallo-zindex NE '000'.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
*    Frequency of reporting
        WHEN  c_abevaz_a0ad005a.
          IF w_/zak/bevall-bidosz = 'H'.
            w_/zak/bevallo-field_c = 'H'.
          ELSEIF w_/zak/bevall-bidosz = 'N'.
            w_/zak/bevallo-field_c = 'N'.
          ENDIF.
      ENDCASE.
      MODIFY t_bevallo FROM w_/zak/bevallo.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " CALC_ABEV_ONYB_21A60
*++2108 #05.
*&---------------------------------------------------------------------*
*& Form GET_KATA_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_W_/ZAK/BEVALL text
*----------------------------------------------------------------------*
FORM get_kata_data  TABLES   $t_bevallo STRUCTURE /zak/bevallalv
                    USING    $w_bevall  STRUCTURE /zak/bevall
                             $gjahr
                             $monat
                             $index.

  DATA ls_bevallo TYPE /zak/bevallalv.
  DATA li_kata_sum TYPE STANDARD TABLE OF /zak/kata_selsum INITIAL SIZE 0.
  DATA li_kata_sum_proc TYPE STANDARD TABLE OF /zak/kata_selsum INITIAL SIZE 0.
  DATA ls_kata_sum TYPE /zak/kata_selsum.
  DATA: l_nylapazon TYPE xfeld.
  DATA: l_sor       TYPE numc2.
  DATA: l_sorindex  TYPE /zak/sorindex.
  DATA: l_sorindex_max  TYPE /zak/sorindex.
  DATA: l_lapsz     TYPE /zak/lapsz.
  DATA: l_oszl  TYPE char1.
  DATA: l_tabix    LIKE sy-tabix.
  DATA: l_amount_external LIKE  bapicurr-bapicurr.
  DATA: l_olwste TYPE /zak/fieldn.
*++2108 #12.
  DATA: l_lwbas TYPE lwbas_bset.
*--2108 #12.

* Definition of basic data
  SELECT * INTO TABLE @DATA(li_kata_sel)
           FROM /zak/kata_sel
          WHERE bukrs EQ @$w_bevall-bukrs
           AND  gjahr EQ @$gjahr
           AND  monat LE @$monat.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
* Collection of KATA data
*++2108 #12.
*  SORT LI_KATA_SEL BY ADOAZON.
  SORT li_kata_sel BY adoazon ASCENDING budat DESCENDING.
*--2108 #12.

  LOOP AT li_kata_sel INTO DATA(ls_kata_sel).
    CLEAR: ls_kata_sum,
           ls_kata_sum-lwste.
*   Aggregation of processed data
    MOVE-CORRESPONDING ls_kata_sel TO ls_kata_sum.
    IF NOT ls_kata_sel-relevant IS INITIAL AND NOT ls_kata_sel-process IS INITIAL.
      ls_kata_sum-process = 'X'.
      COLLECT  ls_kata_sum INTO li_kata_sum_proc.
    ENDIF.
*   Formation of all tax bases
    CLEAR ls_kata_sum-process.
    COLLECT  ls_kata_sum INTO li_kata_sum.
  ENDLOOP.
* Amount conversion
  l_amount_external = $w_bevall-olwste.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      currency             = c_huf
      amount_external      = l_amount_external
      max_number_of_digits = 20
    IMPORTING
      amount_internal      = l_olwste.

* KATA tax calculation
  LOOP AT li_kata_sum ASSIGNING FIELD-SYMBOL(<ls_kata_sum>).
*   Consideration of paid-up fund:
    READ TABLE li_kata_sum_proc INTO DATA(ls_kata_sum_proc) WITH KEY adoazon = <ls_kata_sum>-adoazon.
    IF sy-subrc EQ 0.
      SUBTRACT ls_kata_sum_proc-lwbas FROM <ls_kata_sum>-lwbas.
    ELSE.
      SUBTRACT l_olwste FROM <ls_kata_sum>-lwbas.
    ENDIF.

    IF <ls_kata_sum>-lwbas GT 0.
      <ls_kata_sum>-lwste = ( <ls_kata_sum>-lwbas * $w_bevall-katasz ) / 100.
    ELSE.
      DELETE li_kata_sum.
    ENDIF.
  ENDLOOP.
*  If the row column structure is filled out, then we have to fill it according to
  REFRESH i_/zak/bevallb.
  SELECT * INTO TABLE i_/zak/bevallb
                 FROM /zak/bevallb
                WHERE btype     EQ $w_bevall-btype
                  AND nylapazon NE ''.
  IF sy-subrc EQ 0.
    SORT i_/zak/bevallb BY sorindex.
    l_nylapazon = 'X'.
    DESCRIBE TABLE i_/zak/bevallb LINES l_tabix.
    READ TABLE i_/zak/bevallb INTO w_/zak/bevallb INDEX l_tabix.
    l_sorindex_max = w_/zak/bevallb-sorindex.
    l_lapsz = 1.
  ENDIF.

  DEFINE lm_fill.
    CLEAR: ls_bevallo-field_c,
           ls_bevallo-field_n.
    l_oszl = &1.
    CONCATENATE l_sor l_oszl INTO l_sorindex.
*    Assembling a row index
*   We have reached the maximum value, let's start again
    IF l_sorindex > l_sorindex_max.
*          Initialization
      l_sor = '01'.
*          We are increasing the number of pages
      ADD 1 TO l_lapsz.
      CONCATENATE l_sor l_oszl INTO l_sorindex.
    ENDIF.

  READ TABLE i_/zak/bevallb INTO w_/zak/bevallb
                       WITH KEY sorindex = l_sorindex.
  IF sy-subrc EQ 0.
    ls_bevallo-lapsz = l_lapsz.
    ls_bevallo-abevaz =
    ls_bevallo-abevaz_disp = w_/zak/bevallb-abevaz.
    READ TABLE i_/zak/bevallbt INTO w_/zak/bevallbt WITH KEY langu = sy-langu
                                                           btype = $w_bevall-btype
                                                           abevaz = w_/zak/bevallb-abevaz.
    IF sy-subrc NE 0 .
        SELECT SINGLE * INTO w_/zak/bevallbt
                        FROM /zak/bevallbt
                       WHERE langu = sy-langu
                         AND btype = $w_bevall-btype
                         AND abevaz = w_/zak/bevallb-abevaz.
       APPEND  w_/zak/bevallbt TO i_/zak/bevallbt.
    ENDIF.
    ls_bevallo-abevtext =
    ls_bevallo-abevtext_disp = w_/zak/bevallbt-abevtext.
  ENDIF.
  CASE w_/zak/bevallb-fieldtype.
    WHEN 'C'.
      ls_bevallo-field_c = &2.
    WHEN 'N'.
      CATCH SYSTEM-EXCEPTIONS convt_no_number = 1
                     OTHERS          = 2.
        l_amount_external = &2.
      ENDCATCH.
      ls_bevallo-waers = c_huf.
      ls_bevallo-round = w_/zak/bevallb-round.
      ls_bevallo-field_n = l_amount_external.
      PERFORM calc_field_nrk USING ls_bevallo-field_n
                                   w_/zak/bevallb-round
                                   ls_bevallo-waers
                          CHANGING ls_bevallo-field_nr
                                   ls_bevallo-field_nrk.
  ENDCASE.
  APPEND ls_bevallo TO $t_bevallo.
* If there is a total ABEVAZ, then it must also be included!
  IF NOT w_/zak/bevallb-sum_abevaz IS INITIAL.
    READ TABLE $t_bevallo TRANSPORTING NO FIELDS WITH KEY abevaz = w_/zak/bevallb-sum_abevaz.
    IF sy-subrc NE 0.
    CLEAR: ls_bevallo-lapsz,
           ls_bevallo-field_c,
           ls_bevallo-field_n.
    ls_bevallo-abevaz =
    ls_bevallo-abevaz_disp = w_/zak/bevallb-sum_abevaz.
        READ TABLE i_/zak/bevallbt INTO w_/zak/bevallbt WITH KEY langu = sy-langu
                                                               btype = $w_bevall-btype
                                                               abevaz = w_/zak/bevallb-abevaz.
        IF sy-subrc NE 0 .
            SELECT SINGLE * INTO w_/zak/bevallbt
                            FROM /zak/bevallbt
                           WHERE langu = sy-langu
                             AND btype = $w_bevall-btype
                             AND abevaz = w_/zak/bevallb-abevaz.
           APPEND  w_/zak/bevallbt TO i_/zak/bevallbt.
        ENDIF.
        ls_bevallo-abevtext =
        ls_bevallo-abevtext_disp = w_/zak/bevallbt-abevtext.
     APPEND ls_bevallo TO $t_bevallo.
    ENDIF.
  ENDIF.
  END-OF-DEFINITION.

* Withdrawal of notation of relevant items that have not been processed
  UPDATE /zak/kata_sel SET relevant = ''
                    WHERE bukrs    = $w_bevall-bukrs
*++2108 #10.
                      AND gjahr    = $gjahr
*--2108 #10.
                      AND relevant = 'X'
                      AND process  = ''.
*++2108 #10.
*  MODIFY /ZAK/KATA_SELSUM FROM TABLE LI_KATA_SUM.
*--2108 #10.
* Generation of KATA analytics items
  LOOP AT li_kata_sum INTO ls_kata_sum WHERE lwste GT 0.
*  General data:
    CLEAR ls_bevallo.
*++2108 #18.
    ls_bevallo-mandt = sy-mandt.
*--2108 #18.
    ls_bevallo-bukrs = $w_bevall-bukrs.
    ls_bevallo-btype =
    ls_bevallo-btype_disp = $w_bevall-btype.
    ls_bevallo-gjahr = $gjahr.
    ls_bevallo-monat = $monat.
    ls_bevallo-zindex = $index.
    ls_bevallo-adoazon = ls_kata_sum-adoazon.
    ls_bevallo-waers = ls_kata_sum-waers.
*++2108 #10.
*++2108 #12.
*   Remarking relevant items
*    UPDATE /ZAK/KATA_SEL SET RELEVANT = 'X'
*                      WHERE BUKRS   = $W_BEVALL-BUKRS
*                        AND GJAHR    = $GJAHR
*                        AND ADOAZON = LS_KATA_SUM-ADOAZON.
*--2108 #12.
*  Only items larger than rounded 0 are required in the return:
    CATCH SYSTEM-EXCEPTIONS convt_no_number = 1
                   OTHERS          = 2.
      l_amount_external = ls_kata_sum-lwste.
    ENDCATCH.
    ls_bevallo-round = w_/zak/bevallb-round.
    ls_bevallo-field_n = l_amount_external.
    PERFORM calc_field_nrk USING ls_bevallo-field_n
                                 w_/zak/bevallb-round
                                 ls_bevallo-waers
                        CHANGING ls_bevallo-field_nr
                                 ls_bevallo-field_nrk.
*++2108 #12.
    l_lwbas = ls_kata_sum-lwbas.
*   Calculated tax base and tax return
    LOOP AT li_kata_sel INTO ls_kata_sel WHERE adoazon EQ ls_kata_sum-adoazon
                                           AND process NE 'X'.
      ls_kata_sel-relevant = 'X'.
      IF l_lwbas GE 0.
*    If the tax base is smaller, only the value above the limit is returned
        IF ls_kata_sel-lwbas LE l_lwbas.
          ls_kata_sel-hwbas = ls_kata_sel-lwbas.
          ls_kata_sel-hwste = ( ls_kata_sel-hwbas * $w_bevall-katasz ) / 100.
          SUBTRACT ls_kata_sel-hwbas FROM l_lwbas.
        ELSE.
          ls_kata_sel-hwbas = l_lwbas.
          ls_kata_sel-hwste = ( ls_kata_sel-hwbas * $w_bevall-katasz ) / 100.
          CLEAR l_lwbas.
        ENDIF.
      ENDIF.
      MODIFY /zak/kata_sel  FROM ls_kata_sel.
    ENDLOOP.
*--2108 #12.
    CHECK ls_bevallo-field_nr GT 0.
*--2108 #10.
*   Reading address data
    SELECT SINGLE * INTO @DATA(ls_mgcim)
                    FROM /zak/mgcim
                   WHERE adoazon EQ @ls_kata_sum-adoazon.
    IF sy-subrc NE 0.
      CLEAR ls_mgcim.
    ENDIF.
    ADD 1 TO l_sor.
*   The tax number of A 04-001 Taxpayer company
    lm_fill 'A' ls_kata_sum-adoazon.
*   Name of 04-002
    lm_fill 'B' ls_mgcim-name.
*   04-003 Headquarters is a foreign address
*   Country 04-003 Headquarters
    SELECT SINGLE landx INTO @DATA(l_landx)
                        FROM t005t
                       WHERE spras EQ @sy-langu
                         AND land1 EQ @ls_mgcim-country.
*++2108 #18.
*    IF SY-SUBRC EQ 0.
    IF sy-subrc EQ 0 AND ls_mgcim-country NE 'HU'.
*--2108 #18.
      lm_fill 'D' l_landx.
    ENDIF.
*   Postal code 04-003 Headquarters
    lm_fill 'E' ls_mgcim-postcod.
*   City of 04-003 Headquarters
    lm_fill 'F' ls_mgcim-city1.
*   The name of the public space 04-004 Szkhely
    lm_fill 'G' ls_mgcim-street.
*   The character of the 04-004 Szkhely public space
    lm_fill 'H' ls_mgcim-pubchar.
*   04-004 Headquarters no
    lm_fill 'I' ls_mgcim-house.
*   A 04-005 Basis of the tax to be paid
    lm_fill 'N' ls_kata_sum-lwbas.
*   A 04-005 Amount of tax
    lm_fill 'O' ls_kata_sum-lwste.
*++2108 #10.
** Remark relevant items
*    UPDATE /ZAK/KATA_SEL SET RELEVANT = 'X'
*                      WHERE BUKRS   = $W_BEVALL-BUKRS
*                        AND ADOAZON = LS_KATA_SUM-ADOAZON.
*--2108 #10.
  ENDLOOP.

ENDFORM.
*--2108 #05.
*++2108 #06.
*&---------------------------------------------------------------------*
*& Form CALC_ABEV_ONREV_SZJA_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_T_BEVALLB text
*      -->P_T_ADOAZON text
*      -->P_$INDEX text
*      -->P_$LAST_DATE text
*----------------------------------------------------------------------*
FORM calc_abev_onrev_szja_2108  TABLES  t_bevallo STRUCTURE /zak/bevallo
                                        t_bevallb STRUCTURE /zak/bevallb
                                        t_adoazon STRUCTURE /zak/onr_adoazon
                                 USING  $index
                                        $date.

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

*  To upload fields to be summarized
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  If self-revision
  CHECK $index NE '000'.

  SORT t_bevallb BY abevaz.

*  Let's read the 'A' abev identifiers of the previous period
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

*  We delete records that are not in the given period
*  they gave up.
  LOOP AT t_bevallo INTO w_/zak/bevallo
                    WHERE NOT adoazon IS INITIAL.
    READ TABLE t_adoazon WITH KEY adoazon = w_/zak/bevallo-adoazon
                                  BINARY SEARCH.
*    You don't need the record.
    IF sy-subrc NE 0.
      DELETE t_bevallo.
      CONTINUE.
    ENDIF.
*  M 11 Mark with an X if your declaration is considered a correction
    IF w_/zak/bevallo-abevaz EQ c_abevaz_m0ae003a.
      MOVE 'H' TO w_/zak/bevallo-field_c.
      MODIFY t_bevallo FROM w_/zak/bevallo TRANSPORTING field_c.
    ENDIF.
  ENDLOOP.

* A0ID0193DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0193da   "Modified field
                                c_abevaz_a0bc0001ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0195DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0195da   "Modified field
                                c_abevaz_a0fc0074ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0195CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0195ca   "Modified field
                               c_abevaz_a0id0195da
                               '0.15'.
* A0ID0196DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0196da   "Modified field
                                c_abevaz_a0bc0007ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0197DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0197da   "Modified field
                                c_abevaz_a0cd0036ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0197CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0197ca   "Modified field
                               c_abevaz_a0id0197da
                               '0.015'.
* A0ID0199DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0199da   "Modified field
                                c_abevaz_a0bc0014ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0200DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0200da   "Modified field
                                c_abevaz_a0fc0109ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0200CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0200ca   "Modified field
                               c_abevaz_a0id0200da
                               '0.155'.
* A0ID0203DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0203da   "Modified field
                                c_abevaz_a0fc0123ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0203CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0203ca   "Modified field
                               c_abevaz_a0id0203da
                               '0.10'.
* A0ID0206DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0206da   "Modified field
                                c_abevaz_a0gc0150ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0206CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0206ca   "Modified field
                               c_abevaz_a0id0206da
                               '0.04'.
* A0ID0207DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0207da   "Modified field
                                c_abevaz_a0gc0151ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0207CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0207ca   "Modified field
                               c_abevaz_a0id0207da
                               '0.03'.
* A0ID0208DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0208da   "Modified field
                                c_abevaz_a0gc0152ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0208CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0208ca   "Modified field
                               c_abevaz_a0id0208da
                               '0.015'.
* A0ID0209DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0209da   "Modified field
                                c_abevaz_a0gc0154ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0209CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0209ca   "Modified field
                               c_abevaz_a0id0209da
                               '0.095'.
* A0ID0210DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0210da   "Modified field
                                c_abevaz_a0gc0155ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0210CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0210ca   "Modified field
                               c_abevaz_a0id0210da
                               '0.155'.
* A0ID0211DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0211da   "Modified field
                                c_abevaz_a0gc0156ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0211CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0211ca   "Modified field
                               c_abevaz_a0id0211da
                               '0.095'.
* A0ID0212DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0212da   "Modified field
                                c_abevaz_a0gc0157ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0212CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0212ca   "Modified field
                               c_abevaz_a0id0212da
                               '0.15'.
* A0ID0213AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0213aa   "Modified field
                                c_abevaz_a0gc0158ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0214DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0214da   "Modified field
                                c_abevaz_a0gc0135ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0215DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0215da   "Modified field
                                c_abevaz_a0gc0136ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0216DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0216da   "Modified field
                                c_abevaz_a0gc0160ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0216CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0216ca   "Modified field
                               c_abevaz_a0id0216da
                               '0.185'.
* A0ID0217DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0217da   "Modified field
                                c_abevaz_a0gc0161ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0217CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0217ca   "Modified field
                               c_abevaz_a0id0217da
                               '0.185'.
* A0ID0218DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0id0218da   "Modified field
                                c_abevaz_a0bc0016ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0ID0218CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0id0218ca   "Modified field
                               c_abevaz_a0id0218da
                               '0.40'.
* A0ID0194DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0195da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0196da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0id0194da.
* A0ID0198DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0199da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0200da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0201da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0202da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0id0198da.
*++2108 #11.
* A0ID0198CA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0200ca space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0id0198ca.
*--2108 #11.
* A0ID0205DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0206da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0207da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0id0208da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0id0205da.

ENDFORM.
*--2108 #06.
*++2108 #08.
*&---------------------------------------------------------------------*
*& Form DEL_ESDAT_FIELD_2108
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_I_/ZAK/BEVALLB text
*      -->P_C_ABEVAZ_A0AC041A text
*----------------------------------------------------------------------*
FORM del_esdat_field_2108  TABLES   $t_bevallo STRUCTURE /zak/bevallalv
                                    $t_bevallb STRUCTURE /zak/bevallb
                           USING    $abevaz_jelleg.

  DATA lw_/zak/bevallalv TYPE /zak/bevallalv.

*  We define the character:
  READ TABLE $t_bevallo INTO lw_/zak/bevallalv
  WITH KEY abevaz = $abevaz_jelleg
  BINARY SEARCH.
*  In this case, you do not need to fill in the due date:
  IF sy-subrc EQ 0 AND lw_/zak/bevallalv-field_c = 'H'.
** ABEV ID value marked in ESDAT_FLAG
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
*  For correctors, there is no need for 0 flag in the self-check allowance either
    READ TABLE $t_bevallo INTO lw_/zak/bevallalv
    WITH KEY abevaz = c_abevaz_a0hc0240ca
    BINARY SEARCH.
    IF sy-subrc EQ 0 AND NOT lw_/zak/bevallalv-null_flag IS INITIAL.
      v_tabix = sy-tabix .
      CLEAR lw_/zak/bevallalv-null_flag.
      MODIFY $t_bevallo FROM lw_/zak/bevallalv
      INDEX v_tabix TRANSPORTING null_flag.
    ENDIF.
  ENDIF.

ENDFORM.
*--2108 #08.
*++2108 #19.
*&---------------------------------------------------------------------*
*& Form SEL_KATA_000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO text
*      -->P_W_/ZAK/BEVALL text
*      -->P_I_GJAHR text
*      -->P_I_MONAT text
*      -->P_I_INDEX text
*----------------------------------------------------------------------*
FORM sel_kata_000  TABLES   $t_bevallo STRUCTURE /zak/bevallalv
                            $t_onrev_adoazon  STRUCTURE /zak/onr_adoazon
                    USING   $w_bevall  STRUCTURE /zak/bevall
                            $gjahr
                            $monat
                            $index.

  RANGES lr_abevaz FOR /zak/bevallb-abevaz.
  DATA ls_bevallo_alv TYPE /zak/bevallalv.
  DATA ls_onrev_adoazon TYPE /zak/onr_adoazon.

*Determination of ABEV identifiers
  SELECT abevaz INTO @DATA(l_abevaz)
                 FROM /zak/bevallb
                WHERE btype     EQ @$w_bevall-btype
                  AND nylapazon NE ''.
    m_def lr_abevaz 'I' 'EQ' l_abevaz ''.
  ENDSELECT.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

* Reading period 000 because it must be repeated!
  SELECT * INTO TABLE @DATA(li_bevallo)
           FROM /zak/bevallo
          WHERE bukrs EQ @$w_bevall-bukrs
           AND  gjahr EQ @$gjahr
           AND  monat EQ @$monat
           AND  zindex EQ '000'
           AND abevaz IN @lr_abevaz.
  IF sy-subrc EQ 0.
    LOOP AT li_bevallo INTO DATA(ls_bevallo).
      MOVE-CORRESPONDING ls_bevallo TO ls_bevallo_alv.
      ls_bevallo_alv-zindex = $index.
      APPEND ls_bevallo_alv TO $t_bevallo.
      ls_onrev_adoazon-adoazon = ls_bevallo-adoazon.
      COLLECT  ls_onrev_adoazon INTO $t_onrev_adoazon.
    ENDLOOP.
  ENDIF.

ENDFORM.
*--2108 #19.
