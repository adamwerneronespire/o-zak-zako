*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF20 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_LAP_SZ_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*----------------------------------------------------------------------*
FORM get_lap_sz_2008  TABLES t_bevallo STRUCTURE  /zak/bevallalv.


  DATA l_alv LIKE /zak/bevallalv.
  DATA l_index LIKE sy-tabix.
  DATA l_tabix LIKE sy-tabix.
  DATA l_nylap LIKE sy-tabix.
  DATA l_bevallo_alv LIKE /zak/bevallalv.
  DATA l_null_flag TYPE /zak/null.

  CLEAR l_index.

*  Filling ranges for handling the number of pensioners
  m_def r_a0ac047a 'I' 'EQ' 'M0FC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0GC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0HC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0IC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0JC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0KC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0LC003A' space.
  m_def r_a0ac047a 'I' 'EQ' 'M0MC003A' space.

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

*   Only for SZJA
    IF  w_/zak/bevall-btypart EQ c_btypart_szja.
*      Collecting pensioner tax numbers
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
*  If it is a self-revision calculation then the T_BEVALLO 0 flag is needed
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

*  Determining pensioners
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
  ENDIF.                                 "Please provide the correct name for <...>.

ENDFORM.                    " GET_LAP_SZ_1908
*&---------------------------------------------------------------------*
*&      Form  DEL_ESDAT_FIELD_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_C_ABEVAZ_A0AC041A  text
*----------------------------------------------------------------------*
FORM del_esdat_field_2008  TABLES   $t_bevallo STRUCTURE /zak/bevallalv
  $t_bevallb STRUCTURE /zak/bevallb
USING    $abevaz_jelleg.

  DATA lw_/zak/bevallalv TYPE /zak/bevallalv.

*  Determine the type:
  READ TABLE $t_bevallo INTO lw_/zak/bevallalv
  WITH KEY abevaz = $abevaz_jelleg
  BINARY SEARCH.
*  In this case the due date does not need to be filled:
  IF sy-subrc EQ 0 AND lw_/zak/bevallalv-field_c = 'H'.
**  ABEV identifier value marked in ESDAT_FLAG
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
*  For corrections the self-revision surcharge does not need a 0 flag either
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

ENDFORM.                    " DEL_ESDAT_FIELD_2008
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_M_SZJA_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_m_szja_2008  TABLES t_bevallo STRUCTURE /zak/bevallo
  t_bevallb STRUCTURE /zak/bevallb
  t_adoazon_all STRUCTURE
  /zak/adoazonlpsz
USING   $index
      $last_date.

  SORT t_bevallb BY abevaz.
  SORT t_bevallo BY abevaz adoazon lapsz.
  RANGES lr_abevaz FOR /zak/bevallb-abevaz.

*Special M calculations by tax identifier
*M 02-312 d Combined tax base (sum of rows 300-306 and rows 308-3011 "D")
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
*  field0 = field1+field2+...fieldN as many as there are in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
    t_bevallb
    t_adoazon_all
    lr_abevaz
  USING  c_abevaz_m0bc0316da.           "field0


*M 02-315 d Base of tax advance (difference of rows 313-314)
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
*  field0 = field1-field2-... fieldN as many as there are in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
    t_bevallb
    t_adoazon_all
    lr_abevaz
  USING  c_abevaz_m0bc0317da.          "field0


*M 02-316 d Amount classified as wage from row 312 (data from rows 300-303 "D", 310-311 "A")
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0316da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0317da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0318da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0319da space.
*  field0 = field1+field2+...fieldN as many as there are in the RANGE
  PERFORM get_sub_r_m TABLES t_bevallo
    t_bevallb
    t_adoazon_all
    lr_abevaz
  USING  c_abevaz_m0bc0320da            "field0
         '+'.                           "The result cannot be '-'

  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0314aa space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0315aa space.
*  field0 = field1-field2-... fieldN as many as there are in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
    t_bevallb
    t_adoazon_all
    lr_abevaz
  USING  c_abevaz_m0bc0321da.          "field0

**  A0ZZ000002
*  PERFORM GET_SUM_CALC  TABLES T_BEVALLO
*    T_BEVALLB
*  USING  C_ABEVAZ_A0ZZ000002   "Modified field
*        C_ABEVAZ_M0ED0418CA          "Source 1
*        SPACE                        "Source 2
*        SPACE                        "Source 3
*        SPACE                        "Source 4
*        SPACE                        "Source 5
*        SPACE                        "Source 6
*        SPACE                        "Source 7
*        SPACE                        "Source 8
*        SPACE                        "Source 9
*        SPACE.                       "Source 10
*
**  A0ZZ000003
*  PERFORM GET_SUM_CALC  TABLES T_BEVALLO
*    T_BEVALLB
*  USING  C_ABEVAZ_A0ZZ000003   "Modified field
*        C_ABEVAZ_M0ED0416CA          "Source 1
*        SPACE                        "Source 2
*        SPACE                        "Source 3
*        SPACE                        "Source 4
*        SPACE                        "Source 5
*        SPACE                        "Source 6
*        SPACE                        "Source 7
*        SPACE                        "Source 8
*        SPACE                        "Source 9
*        SPACE.                       "Source 10

ENDFORM.                    " CALC_ABEV_M_SZJA_2008
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_SPECIAL_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_1220   text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_szja_special_2008   TABLES t_bevallo STRUCTURE /zak/bevallo
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
*      Determine the ABEV identifier value belonging to the condition
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

*  Populate selection ABEVAZ
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0095ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0096ca space.
*++2008 #02.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0097CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0098CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0099CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0100CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0101CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0102CA SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0FC0103CA SPACE.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0097ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0098ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0099ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0100ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0101ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0102ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0103ca space.
*--2008 #02.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0104ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0105ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0106ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0107ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0108ca space.

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0120ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0121ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0122ca space.


* The following abev codes may only appear once, aggregator or char
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    This row must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
    BINARY SEARCH.

    CHECK sy-subrc EQ 0.

    v_tabix = sy-tabix .

*    Special calculations
    CASE w_/zak/bevallb-abevaz.
*   A 03-095 Employment under the public employment framework with a 9.75% social contribution obligation (code 2, 678c)
      WHEN  c_abevaz_a0ec0095ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 03-096 Employment in a job not requiring vocational qualification with a 12.5% social contribution
      WHEN  c_abevaz_a0ec0096ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '05' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 04-097 Employment over 180 days for employees under 25 with a 12.5% social contribution
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0097CA.
      WHEN  c_abevaz_a0ec0097ca.
*--2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '07' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 04-099 Employment of workers over 55 years old with a 12.5% social contribution (code 8: 679...)
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0098CA.
      WHEN  c_abevaz_a0ec0098ca.
*--2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '08' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 04-099 Employment of long-term job seekers with a 12.5% social contribution (code 9: 679...)
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0099CA.
      WHEN  c_abevaz_a0ec0099ca.
*++2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '09' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JE0695CA' 'M0JC007A' lr_cond.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*     A 04-100 Employment of GYED, GYES, GYET beneficiaries with a 12.5% social contribution (code 10: 67...)
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0100CA.
      WHEN  c_abevaz_a0ec0100ca.
*--2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '10' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JE0695CA' 'M0JC007A' lr_cond.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*     A 04-101 Company operating in the free enterprise zone with a 12.5% social contribution (code 11: ...)
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0101CA.
      WHEN  c_abevaz_a0ec0101ca.
*--2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '11' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JE0695CA' 'M0JC007A' lr_cond.
*     A 04-102 National higher education doctoral training with a 12.5% social contribution
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0102CA.
      WHEN  c_abevaz_a0ec0102ca.
*--2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '13' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 04-103 Agricultural employment with a 12.5% social contribution
*++2008 #02.
*    WHEN  C_ABEVAZ_A0FC0103CA.
      WHEN  c_abevaz_a0ec0103ca.
*--2008 #02.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '15' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 04-104 Career Bridge
      WHEN  c_abevaz_a0fc0104ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '16' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*    A 04-103 Job not requiring vocational qualification
      WHEN  c_abevaz_a0fc0105ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '18' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*    A 04-103 Employment in an agricultural position
      WHEN  c_abevaz_a0fc0106ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '19' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*    A 04-103 Within public employment
      WHEN  c_abevaz_a0fc0107ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '23' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*   A 04-103 National higher education doctoral program
      WHEN  c_abevaz_a0fc0108ca.
*       Populate condition
        REFRESH lr_cond.
*++2008 #02.
*      M_DEF LR_COND 'I' 'EQ' '23' SPACE.
        m_def lr_cond 'I' 'EQ' '25' space.
*--2008 #02.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0678CA' 'M0JC007A' lr_cond.
*     A 04-120 Pension contribution charged to the individual (563,604,611...)
      WHEN  c_abevaz_a0fc0120ca.
*        Populate condition
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
*     A 04-121-c Unemployment-related pension borne by the individual (605...)
      WHEN  c_abevaz_a0fc0121ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '25' space.
        m_def lr_cond 'I' 'EQ' '42' space.
        m_def lr_cond 'I' 'EQ' '81' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*     A 04-122-c Pension paid by the individual after GYED, S, T (A 604...)
      WHEN  c_abevaz_a0fc0122ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '83' space.
        m_def lr_cond 'I' 'EQ' '92' space.
        m_def lr_cond 'I' 'EQ' '93' space.
        m_def lr_cond 'I' 'EQ' '112' space.
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


ENDFORM.                    " CALC_ABEV_SZJA_SPECIAL_2008
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONREV_SZJA_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_onrev_szja_2008  TABLES  t_bevallo STRUCTURE /zak/bevallo
                                        t_bevallb STRUCTURE /zak/bevallb
                                        t_adoazon STRUCTURE /zak/onr_adoazon
                                 USING  $index
                                        $date.
*++2008 #05.
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

*  To populate fields to be aggregated
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  If self-revision
  CHECK $index NE '000'.

  SORT t_bevallb BY abevaz.

*  Read the previous period's 'A' abev identifiers
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

*  Delete the records that were not submitted in the given period
*  adtak fel.
  LOOP AT t_bevallo INTO w_/zak/bevallo
                    WHERE NOT adoazon IS INITIAL.
    READ TABLE t_adoazon WITH KEY adoazon = w_/zak/bevallo-adoazon
                                  BINARY SEARCH.
*    Nem kell a rekord.
    IF sy-subrc NE 0.
      DELETE t_bevallo.
      CONTINUE.
    ENDIF.
*  M 11 Mark with X if the return qualifies as a correction
    IF w_/zak/bevallo-abevaz EQ c_abevaz_m0ae003a.
      MOVE 'H' TO w_/zak/bevallo-field_c.
      MODIFY t_bevallo FROM w_/zak/bevallo TRANSPORTING field_c.
    ENDIF.
  ENDLOOP.

* A0HD0193DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0193da   "Modified field
                                c_abevaz_a0bc0001ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0195DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0195da   "Modified field
                                c_abevaz_a0ec0074ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0195CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0195ca   "Modified field
                               c_abevaz_a0hd0195da
                               '0.15'.
* A0HD0196DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0196da   "Modified field
                                c_abevaz_a0bc0007ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0197DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0197da   "Modified field
                                c_abevaz_a0cd0043ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0197CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0197ca   "Modified field
                               c_abevaz_a0hd0197da
                               '0.015'.
* A0HD0199DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0199da   "Modified field
                                c_abevaz_a0bc0014ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0200DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0200da   "Modified field
                                c_abevaz_a0fc0109ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0200CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0200ca   "Modified field
                               c_abevaz_a0hd0200da
                               '0.175'.
* A0HD0203DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0203da   "Modified field
                                c_abevaz_a0fc0123ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0203CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0203ca   "Modified field
                               c_abevaz_a0hd0203da
                               '0.10'.
* A0HD0207DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0207da   "Modified field
                                c_abevaz_a0gc0150ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0207CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0207ca   "Modified field
                               c_abevaz_a0hd0207da
                               '0.04'.
* A0HD0208DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0208da   "Modified field
                                c_abevaz_a0gc0151ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0208CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0208ca   "Modified field
                               c_abevaz_a0hd0208da
                               '0.03'.
* A0HD0209DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0209da   "Modified field
                                c_abevaz_a0gc0152ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0209CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0209ca   "Modified field
                               c_abevaz_a0hd0209da
                               '0.015'.
* A0HD0210DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0210da   "Modified field
*++2008 #06.
*                                C_ABEVAZ_A0GC0150CA         "Source 1
                                c_abevaz_a0gc0154ca         "Source 1
*--2008 #06.
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0210CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0210ca   "Modified field
                               c_abevaz_a0hd0210da
                               '0.095'.
* A0HD0211DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0211da   "Modified field
                                c_abevaz_a0gc0155ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0211CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0211ca   "Modified field
                               c_abevaz_a0hd0211da
                               '0.175'.
* A0HD0212DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0212da   "Modified field
                                c_abevaz_a0gc0156ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0212CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0212ca   "Modified field
                               c_abevaz_a0hd0212da
                               '0.111'.
* A0HD0213DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0213da   "Modified field
                                c_abevaz_a0gc0157ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0213CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0213ca   "Modified field
                               c_abevaz_a0hd0213da
                               '0.15'.
* A0HD0214AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0214aa   "Modified field
                                c_abevaz_a0gc0158ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0215AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0215aa   "Modified field
                                c_abevaz_a0gc0159ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0216DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0216da   "Modified field
                                c_abevaz_a0gc0124ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD0216CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0216ca   "Modified field
                               c_abevaz_a0hd0216da
                               '0.13'.
*++2008 #09.
* A0HD50041A
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd50041a   "Modified field
                                c_abevaz_a0fc50027a         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD50038A
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd50038a   "Modified field
                                c_abevaz_a0gc50029a         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD50037A
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd50037a   "Modified field
                               c_abevaz_a0hd50038a
                               '0.185'.
* A0HD50045A
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd50045a   "Modified field
                                c_abevaz_a0gc50042a         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5
* A0HD50046A
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd50046a   "Modified field
                               c_abevaz_a0hd50045a
                               '0.185'.
*--2008 #09.
* A0HD0194DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0195da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0196da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0194da.
* A0HD0198CA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0200ca space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0198ca.
* A0HD0198DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0199da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0200da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0201da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0202da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0198da.
* A0HD0206DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0207da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0208da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0209da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0206da.
*--2008 #05.

ENDFORM.                    " CALC_ABEV_ONREV_SZJA_2008
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_szja_2008 TABLES  t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                            USING  $date
                                   $index.

  DATA: l_kam_kezd TYPE datum.

  DATA: BEGIN OF li_adoazon OCCURS 0,
          adoazon TYPE /zak/adoazon,
        END OF li_adoazon.
  DATA: l_bevallo TYPE /zak/bevallo.

*  To determine self-revision
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  RANGES lr_sel_abevaz FOR /zak/bevallo-abevaz.

************************************************************************
* Special abev fields
************************************************************************

  SORT t_bevallb BY abevaz  .

* The following abev codes may only appear once, aggregator or char

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac039a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac040a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac044a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac041a space.

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0hc001a space.

  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    This row must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
         BINARY SEARCH.

    CHECK sy-subrc EQ 0.
    v_tabix = sy-tabix .


    CASE w_/zak/bevallb-abevaz.
*      First day of the period-from
      WHEN c_abevaz_a0ac039a.
* Havi
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

*      Last day of the period-to
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
*      Correction, self-revision
      WHEN c_abevaz_a0ac041a.
*        Only for self-revision
        IF $index NE '000'.
          REFRESH lr_abevaz.
*          Search for numeric values in this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hd0193da
                                   c_abevaz_a0hd0222da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0ic0240ca
                                   c_abevaz_a0ie0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          We track the rounded amount because FIELD_N may be
*          not empty but no value is reported because of the factor.
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
*      Repeated self-revision
      WHEN c_abevaz_a0hc001a.
*        Only for self-revision
        IF $index > '001'.
          REFRESH lr_abevaz.
*          Search for numeric values in this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hd0193da
                                   c_abevaz_a0hd0216da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0ic0240ca
                                   c_abevaz_a0ie0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          We track the rounded amount because FIELD_N may be
*          not empty but no value is reported because of the factor.
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

ENDFORM.                    " CALC_ABEV_SZJA_2008
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_0_SZJA_2008
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_SPACE  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_0_szja_2008  TABLES  t_bevallo STRUCTURE /zak/bevallo
                              t_adoazon_all STRUCTURE /zak/adoazonlpsz
                              USING   $onrev
                                      $date
                                      $index.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  DATA   lr_value  LIKE range_c3 OCCURS 0 WITH HEADER LINE.
*++2008 #10.
*  DATA   LR_VALUE2 LIKE RANGE_C3 OCCURS 0 WITH HEADER LINE.
  DATA   lr_value2 LIKE range_c10 OCCURS 0 WITH HEADER LINE.

  DATA li_abev_range TYPE STANDARD TABLE OF t_abev_range.
  DATA ls_abev_range TYPE t_abev_range.
*--2008 #10.

* To avoid extending every FORM, handle the self-revision in a global
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
*                              "0 flag setting
*                                     C_ABEVAZ_A0IC0284CA    "field1
*                                     C_ABEVAZ_A0IC0284DA    "field2
*                                     C_ABEVAZ_A0IC0284EA    "field3
*                                     SPACE.                 "field4
** If field1 is not 0 or field2 is not 0 or field3 is not 0 or field4 is not 0
** or if field5 is not 0 then set 0 flag
*   PERFORM GET_NULL_FLAG_INIT TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0DC0087DA    "0 flag
*                                     C_ABEVAZ_A0DC0087CA    "field1
*                                     SPACE                  "field2
*                                     SPACE                  "field3
*                                     SPACE                  "field4
*                                     SPACE                  "field5
*                                     SPACE.                 "field6
*   PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                      T_ADOAZON_ALL
*                               USING  C_ABEVAZ_M0CC0415DA   "0 flag
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
*                                    C_ABEVAZ_M0FD0498BA     "0 flag
*                                    C_ABEVAZ_M0FD0497BA.    "0 flag
* If field1 is in LR_VALUE and LR_ABEVAZ >= 0 (or), then set 0 flag
* perform get_null_flag_M_in_or_abevaz tables T_BEVALLO
*                                             T_ADOAZON_ALL
*                                             LR_VALUE
*                                             LR_ABEVAZ
*                                       using C_ABEVAZ_M0GC007A   "field1
*                                             C_ABEVAZ_M0GD0570CA."0 flag
*     PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                        T_ADOAZON_ALL
*                                 USING  C_ABEVAZ_M0BD0341BA.
*  If field1 >= field2 then set field3 0 flag
  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0301ca          "field1
                               c_abevaz_m0bc0301ba          "field2
                               c_abevaz_m0bc0301da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0301da          "field1
                               c_abevaz_m0bc0301ba          "field2
                               c_abevaz_m0bc0301ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0302ca          "field1
                               c_abevaz_m0bc0302ba          "field2
                               c_abevaz_m0bc0302da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0302da          "field1
                               c_abevaz_m0bc0302ba          "field2
                               c_abevaz_m0bc0302ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0305ca          "field1
                               c_abevaz_m0bc0305ba          "field2
                               c_abevaz_m0bc0305da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0305da          "field1
                               c_abevaz_m0bc0305ba          "field2
                               c_abevaz_m0bc0305ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0306ca          "field1
                               c_abevaz_m0bc0306ba          "field2
                               c_abevaz_m0bc0306da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0306da          "field1
                               c_abevaz_m0bc0306ba          "field2
                               c_abevaz_m0bc0306ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0307ca          "field1
                               c_abevaz_m0bc0307ba          "field2
                               c_abevaz_m0bc0307da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0307da          "field1
                               c_abevaz_m0bc0307ba          "field2
                               c_abevaz_m0bc0307ca.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0312ca          "field1
                               c_abevaz_m0bc0312ba          "field2
                               c_abevaz_m0bc0312da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0312da          "field1
                               c_abevaz_m0bc0312ba          "field2
                               c_abevaz_m0bc0312ca.         "field3

*  Set 0 flag on field1
*++2008 #09.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0BC0316DA.
*
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0BC0320DA.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0320da    "0 flag
                                     c_abevaz_m0bc0316da    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #09.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cd0330ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cd0331ba.
*++2008 #02.
  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cc0330ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0cc0331ba.
*--2008 #02.

* Self-revision surcharge if self-revision
  IF $index NE '000'.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0ic0240ca.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0ic0242ca.
  ENDIF.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0678ca    "0 flag
                                     c_abevaz_m0jd0678aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0564ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "field1
                                              c_abevaz_m0gd0566ca. "0 flag

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0568ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "field1
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
                                        USING c_abevaz_m0gc007a    "field1
                                              c_abevaz_m0gd0578ca. "0 flag
*++2008 #09.
*  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0GD0567CA    "0 flag
*                                     C_ABEVAZ_M0GD0565CA    "field1
*                                     SPACE                  "field2
*                                     SPACE                  "field3
*                                     SPACE                  "field4
*                                     SPACE                  "field5
*                                     SPACE.                 "field6
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0567ca    "0 flag
                                     c_abevaz_m0gd0564ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #09.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0 flag
                                     c_abevaz_m0gd0569ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0 flag
                                     c_abevaz_m0gd0570ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0hd0605ca    "0 flag
                                     c_abevaz_m0hd0603ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*++2008 #09.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0GD0577CA.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0577ca    "0 flag
                                     c_abevaz_m0gd0574ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #09.
*++2008 #09.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0GD0579CA.
*--2008 #09.
  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0574ca.
*++2008 #09.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0GD0567CA.
*--2008 #09.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0364da    "0 flag
                                     c_abevaz_m0ec0364ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0364ea    "0 flag
                                     c_abevaz_m0ec0364ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0368da    "0 flag
                                     c_abevaz_m0ec0368ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ec0368ea    "0 flag
                                     c_abevaz_m0ec0368ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0680aa    "0 flag
                                     c_abevaz_m0jd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0680ca    "0 flag
                                     c_abevaz_m0jd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0677aa    "0 flag
                                     c_abevaz_m0jd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0677ca    "0 flag
                                     c_abevaz_m0jd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0565ca    "0 flag
                                     c_abevaz_m0gd0564ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0569ca    "0 flag
                                     c_abevaz_m0gd0568ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0573ca    "0 flag
                                     c_abevaz_m0gd0572ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*++2008 #07.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0319da    "0 flag
                                     c_abevaz_m0bc0319aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #07.
*++2008 #09.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0 flag
                                     c_abevaz_m0gd0568ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0320da    "0 flag
                                     c_abevaz_m0bc0319aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #09.
*++2008 #08.
*++2008 #09.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  C_ABEVAZ_M0GD0567CA.
*--2008 #09.
  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50030a.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50040a    "0 flag
                                     c_abevaz_m0ld50028a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0je0694ca    "0 flag
                                     c_abevaz_m0je0694aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #08.
*++2008 #09.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0579ca    "0 flag
                                     c_abevaz_m0gd0574ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50028a    "0 flag
                                     c_abevaz_m0ld50030a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*++2008 #11.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50060a    "0 flag
                                     c_abevaz_m0ld50030a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #11.
  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ'  c_abevaz_m0hd0600ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0hc008a    "field1
                                              c_abevaz_m0hd0604ca. "0 flag

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50028a    "0 flag
                                     c_abevaz_m0ld50044a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*++2008 #11.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50060a    "0 flag
                                     c_abevaz_m0ld50044a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #11.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50028a    "0 flag
                                     c_abevaz_m0ld50039a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*++2008 #11.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50060a    "0 flag
                                     c_abevaz_m0ld50039a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--2008 #11.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0ld50040a    "0 flag
                                     c_abevaz_m0ld50030a    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' '0' space.
  PERFORM get_null_flag_m_in_c_range   TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                        USING c_abevaz_m0lc00526a  "field1
                                              c_abevaz_m0ld50028a. "0 flag
*++2008 #11.
  PERFORM get_null_flag_m_in_c_range   TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                        USING c_abevaz_m0lc00526a  "field1
                                              c_abevaz_m0ld50060a. "0 flag
*--2008 #11.
  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' '0' space.
  PERFORM get_null_flag_m_in_c_range   TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                        USING c_abevaz_m0lc00526a  "field1
                                              c_abevaz_m0ld50040a. "0 flag
*--2008 #09.
*++2008 #10.
* C_ABEVAZ_M0LC00527A
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

  ls_abev_range-abevaz = c_abevaz_m0lc00527a.
  ls_abev_range-range[] = lr_value2[].
  APPEND ls_abev_range TO li_abev_range.
  CLEAR ls_abev_range.

  REFRESH: lr_value2.
  m_def lr_value2 'I' 'GE' '20200901' space.
  ls_abev_range-abevaz = c_abevaz_m0lc00524a.
  ls_abev_range-range[] = lr_value2[].
  APPEND ls_abev_range TO li_abev_range.
  CLEAR ls_abev_range.

  REFRESH: lr_value2.
  m_def lr_value2 'E' 'EQ' '1' space.
  m_def lr_value2 'E' 'EQ' '2' space.
  ls_abev_range-abevaz = c_abevaz_m0fc00531a.
  ls_abev_range-range[] = lr_value2[].
  MOVE 'X' TO ls_abev_range-noerr. "Ha nincs rekord az nem hiba!
  APPEND ls_abev_range TO li_abev_range.
  CLEAR ls_abev_range.
* 640 sor
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0ld50057a. "0 flag
* 641 sor
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0ld50059a. "0 flag
* 643 sor
  PERFORM get_null_flag_m_in_c_ranges  TABLES t_bevallo
                                              t_adoazon_all
                                              li_abev_range
                                        USING c_abevaz_m0ld50056a. "0 flag
*--2008 #10.

ENDFORM.                    " CALC_ABEV_0_SZJA_2008
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_2065
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
*      -->P_W_/ZAK/BEVALL_KIUTALAS  text
*----------------------------------------------------------------------*
FORM calc_abev_afa_2065  TABLES t_bevallo STRUCTURE /zak/bevallo
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
* Special abev fields

******************************************************** ONLY VAT normal

  DATA: w_sz TYPE /zak/bevallb.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  Populating calculated fields
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
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0hc001a   space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0086ba space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0dd0086ca space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ai002a   space.
  RANGES lr_monat FOR /zak/afa_szlasum-monat.
  DATA l_sum_not_valid TYPE xfeld.

  SORT t_bevallb BY abevaz  .
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_abevaz.
    CLEAR : l_sum,w_/zak/bevallo.
* This row must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.
* 84.C. Amount of tax payable (data from row 83 if non-negative)
      WHEN c_abevaz_a0dd0084ca.
        l_upd = 'X'. "Always update because if the amount reverses it must be cleared
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
* Havi
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
*00C Declaration period to
      WHEN c_abevaz_a0af002a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*00C Type of return
      WHEN c_abevaz_a0af005a.
        IF w_/zak/bevallo-zindex GE '001'.
          w_/zak/bevallo-field_c = 'O'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*04 (O) Mark repeated self-revision (x)
      WHEN c_abevaz_a0hc001a.
*        ZINDEX > '001' --> 'X'     "repeated self-revision
        IF w_/zak/bevallo-zindex > '001'.
          w_/zak/bevallo-field_c = 'X'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*00C Filing frequency /H-monthly, N-quarterly, E-annual
      WHEN c_abevaz_a0af006a.
        w_/zak/bevallo-field_c = w_/zak/bevall-bidosz.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*82.B. Amount of deductible item that can be credited from the previous period
      WHEN c_abevaz_a0dd0082ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0082ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*83.C. Total amount of tax payable determined in the current period
      WHEN c_abevaz_a0dd0083ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0083ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*84.B. Amount of tax payable (data from row 83 if non-negative)
      WHEN c_abevaz_a0dd0084ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0084ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*85.B. Amount of reclaimable tax (negative row 83, ...)
      WHEN c_abevaz_a0dd0085ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0085ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*86.B. Amount of receivable carried to the next period
      WHEN c_abevaz_a0dd0086ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0086ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*00F year month day
      WHEN c_abevaz_a0ai002a.
        w_/zak/bevallo-field_c = sy-datum.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*85.C. Amount of reclaimable tax (negative row 83 ...)
      WHEN  c_abevaz_a0dd0085ca.
        l_upd = 'X'. "Always update because if the amount reverses it must be cleared
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
*Carried over to the next period
      WHEN  c_abevaz_a0dd0086ca.
        l_upd = 'X'. "Always update because if the amount reverses it must be cleared
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
* Populate every numeric value for calculated fields!
* Follow this procedure when calculating totals:
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
*  REFRESH lr_abevaz.
  CLEAR lr_abevaz[].
*--S4HANA#01.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ag016a space.

  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_abevaz.
    CLEAR : l_sum,w_/zak/bevallo.
* This row must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.

*00D I do not request a payout
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
* Populate every numeric value for calculated fields!
* Follow this procedure when calculating totals:
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

*  Calculating fields below the VAT threshold for the summary report
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
*    REFRESH lr_monat.
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
*  Determine amounts per tax number and per invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE mlap   IS INITIAL
                            AND nylapazon(3) = c_nylapazon_m02.
*      Aggregate only within the month
      CHECK lw_afa_szla_sum-gjahr EQ $date(4) AND
            lw_afa_szla_sum-monat IN lr_monat.
      CLEAR lw_adoaz_szamlasza_sum.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      lw_adoaz_szamlasza_sum-lwste      = lw_afa_szla_sum-lwste.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.
*    Determining the threshold
    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*      If it appears on the M sheet or the threshold is higher than configured
      READ TABLE t_afa_szla_sum TRANSPORTING NO FIELDS
                 WITH KEY adoazon = lw_adoaz_szamlasza_sum-adoazon
                          nylapazon(3) = c_nylapazon_m02
                          mlap    = 'X'.

      IF sy-subrc NE 0 AND lw_adoaz_szamlasza_sum-lwste < l_olwste.
        CONTINUE.
      ENDIF.
*     Populate other calculated fields on the main M sheet
*++2065 #07.
*      PERFORM CALC_ABEV_AFA_1965_M TABLES T_BEVALLO
      PERFORM calc_abev_afa_2065_m TABLES t_bevallo
*--2065 #07.
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.

*    Handle calculated fields on the M sheet fields as well
    FREE li_adoaz_szamlasza_sum.
*    Determine amounts per tax number and per invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE NOT mlap   IS INITIAL.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.

    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*       Populate other calculated fields on the main M sheet
*     PERFORM CALC_ABEV_AFA_1865_M TABLES T_BEVALLO
*++2065 #07.
*      PERFORM CALC_ABEV_AFA_1965_M TABLES T_BEVALLO
      PERFORM calc_abev_afa_2065_m TABLES t_bevallo
*--2065 #07.
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.
  ENDIF.


************************************************************************
****
* Calculation of self-revision surcharge
************************************************************************
****
  IF $index NE '000'.
* if A0DD0084CA - A0DD0084BA > 0 then use this value, otherwise 0
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
* if (A0DD0086CA - A0DD0086BA) < 0 then negate the calculated value
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
* if A0DD0085CA - A0DD0085BA < 0 then negate the calculated value
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
*     If A0DD0082CA - A0DD0082BA < 0 then reduce by this amount
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

* Determining the self-revision surcharge
* Calculate ABEV A0HD0002CA based on A0HD0001CA; if the index is 2 or higher then multiply by 1.5
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
* Determine the period
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_23337.
        IF sy-subrc EQ 0 AND
        NOT w_/zak/bevallo-field_c IS INITIAL .
* determine the deadline for calculating the surcharge! the 104
* tax type is needed for the /ZAK/ADONEM table key !!
          SELECT SINGLE fizhat INTO w_/zak/adonem-fizhat FROM /zak/adonem
                                WHERE bukrs  EQ w_/zak/bevallo-bukrs AND
                                                 adonem EQ c_adonem_104
                                                 .
          IF sy-subrc EQ 0.
* start date of surcharge calculation
            CLEAR l_kam_kezd.
            l_kam_kezd = $date + 1 + w_/zak/adonem-fizhat.
* end date of surcharge calculation in the character field of abev row 5299
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
*              Handle the 0 flag value for form validation
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
*      If there is a value, adjust A0HD0001CA.
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

*  Handling the 0 flag field
* If field1 is not 0 or field2 is not 0 or field3 is not 0 or field4 is not 0
* or if field5 is not 0 then set the 0 flag
  PERFORM get_null_flag_init TABLES t_bevallo
                             USING  c_abevaz_a0hd0002ca
                             "0 flag beállítás
                                    c_abevaz_a0hd0001ca     "field1
                                    space                   "field2
                                    space                   "field3
                                    space                   "field4
                                    space                   "field5
                                    space.                  "field6


ENDFORM.                    " CALC_ABEV_AFA_2065
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONYB_20A60
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_onyb_20a60  TABLES t_bevallo STRUCTURE /zak/bevallo
                                  t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                           USING  $last_date.
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
* H - Havi
  ELSEIF w_/zak/bevall-bidosz = 'H'.

  ENDIF.

  CONCATENATE l_gjahr l_monat '01' INTO l_begin_day.

* The following abev codes may only appear once, aggregator or char
  LOOP AT t_bevallb INTO w_/zak/bevallb
    WHERE  abevaz EQ     c_abevaz_a0ad001a
       OR  abevaz EQ     c_abevaz_a0ad002a
       OR  abevaz EQ     c_abevaz_a0ad004a
       OR  abevaz EQ     c_abevaz_a0ad005a.

* This row must be modified!
    LOOP AT t_bevallo INTO w_/zak/bevallo
                      WHERE abevaz = w_/zak/bevallb-abevaz.

      CASE w_/zak/bevallb-abevaz.

*++2010.02.11 RN
* this field is no longer on the 10A60
**    Signature date (sy-datum)
*         WHEN  C_ABEVAZ_24.
*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.
*--2010.02.11 RN
*    PERIOD start date
        WHEN  c_abevaz_a0ad001a.
          w_/zak/bevallo-field_c = l_begin_day.
*    PERIOD end date
        WHEN  c_abevaz_a0ad002a.
          w_/zak/bevallo-field_c = $last_date.
*    Populate correction flags
*    Always populate it when self-revision:
        WHEN  c_abevaz_a0ad004a.
          IF w_/zak/bevallo-zindex NE '000'.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
*    Filing frequency
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

ENDFORM.                    " CALC_ABEV_ONYB_20A60
*++2065 #07.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_2065_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_LW_ADOAZ_SZAMLASZA_SUM_ADOAZON  text
*      -->P_W_/ZAK/BEVALL  text
*----------------------------------------------------------------------*
FORM calc_abev_afa_2065_m  TABLES   $t_bevallo STRUCTURE /zak/bevallo
                                    $t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                            USING   $adoazon
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
*++1965 #04.
  DATA l_text50 TYPE text50.
*--1965 #04.

*  M0AC001A   Taxpayer tax number, can be taken from A0AE001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac001a
                                  c_abevaz_a0ae001a
                                  $adoazon.
*  M0AC003A   Predecessor tax number, can be taken from A0AE004A if not empty
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac004a
                                  c_abevaz_a0ae004a
                                  $adoazon.

*  M0AC004A Taxpayer name, can be taken from A0AE008A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac005a
*++1965 #02.
*                                 C_ABEVAZ_A0AE005A
                                  c_abevaz_a0ae006a
*--1965 #02.
                                  $adoazon.

*  M0AD001A Declaration period from, can be taken from A0AF001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad001a
                                  c_abevaz_a0af001a
                                  $adoazon.

*  M0AD002A Declaration period to, can be taken from A0AF002A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad002a
                                  c_abevaz_a0af002a
                                  $adoazon.
*++1965 #04.
* If the tax number is not empty
  IF NOT $adoazon IS INITIAL.
*   ADOAZON
    PERFORM get_afa_m_value  TABLES $t_bevallo
                                    $t_bevallb
                             USING  c_abevaz_m0ac006a
                                    $adoazon
                                    $adoazon.
*  Specify group name
    CLEAR l_text50.
    SELECT SINGLE text50 INTO l_text50
                         FROM /zak/padonszt
                        WHERE adoazon EQ $adoazon.
    IF sy-subrc EQ 0 AND NOT l_text50 IS INITIAL.
*     NAME1
      PERFORM get_afa_m_value  TABLES $t_bevallo
                                      $t_bevallb
                               USING  c_abevaz_m0ac008a
                                      l_text50
                                      $adoazon.
    ENDIF.
  ENDIF.
*--1965 #04.

* M0AC005A Partner tax number: put the M sheet ADOAZON here
*if filled from STCD1 (take the customer or supplier code from /ZAK/ANALITIKA
*plus KOART indicates whether it is a supplier or customer!)
*M0AC006A if filled from STCD3
  READ TABLE $t_bevallo INTO lw_bevallo INDEX 1.
*  Fill the month:
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
  SELECT adoazon lifkun koart stcd1 field_c INTO lw_analitika
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
*++1965 #04.
**--1765 #10.
*    IF NOT LW_ANALITIKA-STCD3 IS INITIAL.
**     STCD3
*      PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
*                                      $T_BEVALLB
*                               USING  C_ABEVAZ_M0AC007A
*                                      LW_ANALITIKA-STCD3(8)
*                                      $ADOAZON.
**     ELSEIF NOT  LW_ANALITIKA-STCD1 IS INITIAL.
**++1565 #05.
**   It must be filled otherwise ABEV reports an error
**   read the first one where it exists!
*    ELSE.
*      SELECT SINGLE STCD3 INTO LW_ANALITIKA-STCD3
*                   FROM /ZAK/ANALITIKA
*                  WHERE BUKRS   EQ LW_BEVALLO-BUKRS
*                    AND BTYPE   EQ LW_BEVALLO-BTYPE
*                    AND GJAHR   EQ LW_BEVALLO-GJAHR
*                    AND MONAT   IN LR_MONAT
*                    AND ZINDEX  LE LW_BEVALLO-ZINDEX
*                    AND ADOAZON EQ $ADOAZON
*                    AND STCD3   NE ''.
*      IF SY-SUBRC EQ 0.
**       STCD3
*        PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
*                                        $T_BEVALLB
*                                 USING  C_ABEVAZ_M0AC007A
*                                        LW_ANALITIKA-STCD3(8)
*                                        $ADOAZON.
*      ENDIF.
**--1565 #05.
*    ENDIF.
*--1965 #04.
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
*    The name is in field_c on the DUMMY_R record
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

ENDFORM.                    " CALC_ABEV_AFA_2065_M
*--2065 #07.
*++2008 #09.
*&---------------------------------------------------------------------*
*&      Form  GET_NULL_FLAG_M_IN_OR_ABEVAZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_LR_VALUE  text
*      -->P_LR_ABEVAZ  text
*      -->P_C_ABEVAZ_M0GD0568CA  text
*      -->P_C_ABEVAZ_M0GD0570CA  text
*----------------------------------------------------------------------*
FORM get_null_flag_m_in_c_range    TABLES $t_bevallo STRUCTURE
                                                             /zak/bevallo
                                          $t_adoazon_all STRUCTURE
                                                       /zak/adoazonlpsz
*++2008 #10.
*                                          $LR_VALUE  STRUCTURE
*                                                            RANGE_C3
                                          $lr_value
*--2008 #10.
                                   USING  $abev_1
                                          $abev_0.
  DATA l_true.
  DATA l_tabix LIKE sy-tabix.
  LOOP AT $t_adoazon_all.
    CLEAR l_true.
    READ TABLE $t_bevallo WITH KEY abevaz  = $abev_1
                                   adoazon = $t_adoazon_all-adoazon
                                   lapsz   = $t_adoazon_all-lapsz
                                   BINARY SEARCH.
    IF sy-subrc EQ 0 AND $t_bevallo-field_c IN $lr_value.
      l_true = c_x.
    ENDIF.
    IF NOT l_true IS INITIAL.
      READ TABLE $t_bevallo WITH KEY abevaz  = $abev_0
                                     adoazon = $t_adoazon_all-adoazon
                                     lapsz   = $t_adoazon_all-lapsz
                                     BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO l_tabix.
        MOVE c_x TO $t_bevallo-null_flag.
        MODIFY $t_bevallo INDEX l_tabix TRANSPORTING null_flag.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_NULL_FLAG_M_IN_C_RANGE
*--2008 #09.
*++2008 #10.
*&---------------------------------------------------------------------*
*&      Form  GET_NULL_FLAG_M_IN_C_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_LR_VALUE  text
*      -->P_C_ABEVAZ_M0LC00526A  text
*      -->P_C_ABEVAZ_M0LD50040A  text
*----------------------------------------------------------------------*
FORM get_null_flag_m_in_c_ranges  TABLES $t_bevallo STRUCTURE
                                                             /zak/bevallo
                                          $t_adoazon_all STRUCTURE
                                                       /zak/adoazonlpsz
                                          $li_abev_range
                                   USING  $abev_0.
  DATA l_true.
  DATA l_tabix LIKE sy-tabix.
  DATA ls_abev_range TYPE t_abev_range.
  DATA lr_value LIKE range_c10 OCCURS 0 WITH HEADER LINE.

  LOOP AT $t_adoazon_all.
    CLEAR l_true.
    LOOP AT $li_abev_range INTO ls_abev_range.
      lr_value[] = ls_abev_range-range[].
      READ TABLE $t_bevallo WITH KEY abevaz  = ls_abev_range-abevaz
                                     adoazon = $t_adoazon_all-adoazon
                                     lapsz   = $t_adoazon_all-lapsz
                                     BINARY SEARCH.
      IF ( sy-subrc EQ 0 AND $t_bevallo-field_c IN lr_value ) OR
         ( sy-subrc NE 0 AND ls_abev_range-noerr EQ 'X' ).
        l_true = c_x.
      ELSE.
        CLEAR l_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF NOT l_true IS INITIAL.
      READ TABLE $t_bevallo WITH KEY abevaz  = $abev_0
                                     adoazon = $t_adoazon_all-adoazon
                                     lapsz   = $t_adoazon_all-lapsz
                                     BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO l_tabix.
        MOVE c_x TO $t_bevallo-null_flag.
        MODIFY $t_bevallo INDEX l_tabix TRANSPORTING null_flag.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*--2008 #10.
