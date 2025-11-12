*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF19 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_M_SZJA_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_m_szja_1908  TABLES t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                                   t_adoazon_all STRUCTURE
                                                 /zak/adoazonlpsz
                           USING   $index
                                   $last_date.

  SORT t_bevallb BY abevaz.
  SORT t_bevallo BY abevaz adoazon lapsz.
  RANGES lr_abevaz FOR /zak/bevallb-abevaz.

*Special M calculations by tax identification number
*M 02-312 d Consolidated tax base (the sum of lines 300-306 and lines 308-3011 "D")
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0304da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0305da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0306da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0308da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0309da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0310da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0311da space.
*  field0 = field1+field2+...fieldN as many as there are in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0312da.           "field0


*M 02-315 d Tax advance base (difference between lines 313-314)
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0312da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0313da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0314da space.
*  field0 = field1-field2-........ fieldN as many as there are in the RANGE
  PERFORM get_sub_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0315da            "field0
                             '+'.      "The result cannot be '-'

*M 02-316 d Amount considered wages from line 312 (data from lines 300-303 "D", 310-311 "A")
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0310aa space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0311aa space.
*  field0 = field1+field2+...fieldN as many as there are in the RANGE
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0316da  .         "field0

*  A0ZZ000002
  PERFORM get_sum_calc  TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0zz000002   "Modified field
                               c_abevaz_m0ed0418ca          "Source 1
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
                               c_abevaz_m0ed0416ca          "Source 1
                               space                        "Source 2
                               space                        "Source 3
                               space                        "Source 4
                               space                        "Source 5
                               space                        "Source 6
                               space                        "Source 7
                               space                        "Source 8
                               space                        "Source 9
                               space.                       "Source 10

ENDFORM.                    " CALC_ABEV_M_SZJA_1908
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_SPECIAL_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_1139   text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_szja_special_1908   TABLES  t_bevallo STRUCTURE /zak/bevallo
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
*      The ABEV identifier value belonging to the condition must be determined
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
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0087ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0088ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0089ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0090ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0091ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0095ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ec0096ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0097ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0098ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0099ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0100ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0101ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0102ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0103ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0104ca space.

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0120ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0121ca space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0fc0122ca space.


* the following ABEV codes can occur only once, aggregating or character
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    This line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
             BINARY SEARCH.

    CHECK sy-subrc EQ 0.

    v_tabix = sy-tabix .

*    Special calculations
    CASE w_/zak/bevallb-abevaz.
*     A 03-087 With a START card a 10% social contribution allowance applies |
      WHEN  c_abevaz_a0ec0087ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '1' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*     A 03-088 With a START card a 20% social contribution allowance applies |
      WHEN  c_abevaz_a0ec0088ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '1' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0644CA' 'M0JC007A' lr_cond.
*     A 03-089 With a START PLUS card a 10% social contribution allowance applies |
      WHEN  c_abevaz_a0ec0089ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*     A 03-090 With a START PLUS card a 20% social contribution allowance applies |
      WHEN  c_abevaz_a0ec0090ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0644CA' 'M0JC007A' lr_cond.
*     A 03-091 With a START EXTRA card a 10% social contribution allowance applies |
      WHEN  c_abevaz_a0ec0091ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '3' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*     A 03-095 Public employment with 9.75% social contribution obligation (code 2, 678c)
      WHEN  c_abevaz_a0ec0095ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 03-096 Employment in positions not requiring professional qualifications |
      WHEN  c_abevaz_a0ec0096ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '05' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-097 Employment over 180 days for employees under 25 with 12.5% social contribution
      WHEN  c_abevaz_a0fc0097ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '07' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-099 Employees over 55 with 12.5% social contribution (code 8: 679.)
      WHEN  c_abevaz_a0fc0098ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '08' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-099 Permanently job-seeking employees with 12.5% social contribution (code 9: 679.)
      WHEN  c_abevaz_a0fc0099ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '09' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*++1908 #12.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*--1908 #12.
*     A 04-100 Employees on GYED, GYES, GYET with 12.5% social contribution (code 10: 67|
      WHEN  c_abevaz_a0fc0100ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '10' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*++1908 #12.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*--1908 #12.
*     A 04-101 Enterprises operating in a free enterprise zone with 12.5% social contribution (code 11|
      WHEN  c_abevaz_a0fc0101ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '11' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-102 National higher education doctoral training with 12.5% social contribution requirement |
      WHEN  c_abevaz_a0fc0102ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '13' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-103 Agricultural employment pay with 12.5% social contribution |
      WHEN  c_abevaz_a0fc0103ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '15' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-104 Career Bridge
      WHEN  c_abevaz_a0fc0104ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '16' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-120 Private individual pension contributions (563, 604, 611|
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
*     A 04-121-c Private burden unemployment, job seeker pension (line 605|
      WHEN  c_abevaz_a0fc0121ca.
*       Populate condition
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '25' space.
        m_def lr_cond 'I' 'EQ' '42' space.
        m_def lr_cond 'I' 'EQ' '81' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*     A 04-122-c Private burden pension paid after GYED, S, T (line 604|
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

ENDFORM.                    " CALC_ABEV_SZJA_SPECIAL_1908
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONREV_SZJA_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_onrev_szja_1908  TABLES  t_bevallo STRUCTURE /zak/bevallo
                                          t_bevallb STRUCTURE
                                          /zak/bevallb
                                          t_adoazon STRUCTURE
                                          /zak/onr_adoazon
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

*  To populate fields to be summed
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  If self-revision
  CHECK $index NE '000'.

  SORT t_bevallb BY abevaz.

*  Read the 'A' ABEV identifiers from the previous period
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

*  Delete records that were not submitted in the given period
  LOOP AT t_bevallo INTO w_/zak/bevallo
                    WHERE NOT adoazon IS INITIAL.
    READ TABLE t_adoazon WITH KEY adoazon = w_/zak/bevallo-adoazon
                                  BINARY SEARCH.
*    Record not needed.
    IF sy-subrc NE 0.
      DELETE t_bevallo.
      CONTINUE.
    ENDIF.
*  M 11 Mark with an X if the return qualifies as a correction
    IF w_/zak/bevallo-abevaz EQ c_abevaz_m0ae003a.
      MOVE 'H' TO w_/zak/bevallo-field_c.
      MODIFY t_bevallo FROM w_/zak/bevallo TRANSPORTING field_c.
    ENDIF.
  ENDLOOP.
*++1908 #04.
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
*++1908 #06.
*                                C_ABEVAZ_A0EC0074DA         "Source 1
                                c_abevaz_a0ec0074ca         "Source 1
*--1908 #06.
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0GD0192CA
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
*++1908 #06.
** A0HD0198CA
*  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
*                               T_BEVALLB
*                        USING  C_ABEVAZ_A0HD0198CA   "Modified field
*                               C_ABEVAZ_A0HD0198DA
*                               '0.195'.
*--1908 #06.
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
                               '0.195'.

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

* A0HD0210DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0210da   "Modified field
                                c_abevaz_a0gc0150ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0210CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0210ca   "Modified field
                               c_abevaz_a0hd0210da
                               '0.04'.

* A0HD0211DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0211da   "Modified field
                                c_abevaz_a0gc0151ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0211CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0211ca   "Modified field
                               c_abevaz_a0hd0211da
                               '0.03'.

* A0HD0212DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0212da   "Modified field
                                c_abevaz_a0gc0152ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0212CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0212ca   "Modified field
                               c_abevaz_a0hd0212da
                               '0.015'.

* A0HD0213DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0213da   "Modified field
                                c_abevaz_a0gc0154ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0213CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0213ca   "Modified field
                               c_abevaz_a0hd0213da
                               '0.095'.

* A0HD0214DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0214da   "Modified field
                                c_abevaz_a0gc0155ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0214CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0214ca   "Modified field
                               c_abevaz_a0hd0214da
                               '0.195'.

* A0HD0215DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0215da   "Modified field
                                c_abevaz_a0gc0156ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0215CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0215ca   "Modified field
                               c_abevaz_a0hd0215da
                               '0.111'.

* A0HD0216DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0216da   "Modified field
                                c_abevaz_a0gc0157ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0216CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0216ca   "Modified field
                               c_abevaz_a0hd0216da
                               '0.15'.

* A0HD0217AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0217aa   "Modified field
                                c_abevaz_a0gc0158ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0218AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0218aa   "Modified field
                                c_abevaz_a0gc0159ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0219DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0219da   "Modified field
                                c_abevaz_a0gc0124ca         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0219CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0219ca   "Modified field
                               c_abevaz_a0hd0219da
                               '0.13'.

* A0HD0221DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0221da   "Modified field
                                c_abevaz_a0zz000003         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0221CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0221ca   "Modified field
                               c_abevaz_a0hd0221da
                               '0.195'.

* A0HD0222DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0222da   "Modified field
                                c_abevaz_a0zz000002         "Source 1
                                space                       "Source 2
                                space                       "Source 3
                                space                       "Source 4
                                space.                      "Source 5

* A0HD0222CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0222ca   "Modified field
                               c_abevaz_a0hd0222da
                               '0.14'.

* A0HD0220DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0221da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0222da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0220da.
* A0HD0194DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0195da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0196da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0194da.

*++1908 #06.
* A0HD0198CA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0200ca space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0198ca.
*--1908 #06.

* A0HD0198DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0199da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0200da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0198da.

* A0HD0206DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0207da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0208da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0206da.

* A0HD0209DA
  REFRESH lr_abevaz.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0210da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0211da space.
  m_def  lr_abevaz 'I' 'EQ' c_abevaz_a0hd0212da space.

  PERFORM get_onrev_sum TABLES t_bevallo
                               lr_abevaz
                               t_bevallb
                        USING  c_abevaz_a0hd0209da.
*--1908 #04.


ENDFORM.                    " CALC_ABEV_ONREV_SZJA_1908
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_szja_1908  TABLES  t_bevallo STRUCTURE /zak/bevallo
                                   t_bevallb STRUCTURE /zak/bevallb
                            USING  $date
                                   $index.

  DATA: l_kam_kezd TYPE datum.

  DATA: BEGIN OF li_adoazon OCCURS 0,
          adoazon TYPE /zak/adoazon,
        END OF li_adoazon.
  DATA: l_bevallo TYPE /zak/bevallo.

*  To determine self-audit
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  RANGES lr_sel_abevaz FOR /zak/bevallo-abevaz.

************************************************************************
* Special ABEV fields
************************************************************************

  SORT t_bevallb BY abevaz  .

* the following ABEV codes can occur only once, aggregating or character

  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac039a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac040a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac044a space.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0ac041a space.
*++1908 #07.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0GC001A SPACE.
  m_def lr_sel_abevaz 'I' 'EQ' c_abevaz_a0hc001a space.
*--1908 #07.

  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    This line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
         BINARY SEARCH.

    CHECK sy-subrc EQ 0.
    v_tabix = sy-tabix .


    CASE w_/zak/bevallb-abevaz.
*      First day of the period from
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

*      Last day of the period to
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
*      Correction, self-audit
      WHEN c_abevaz_a0ac041a.
*        Only for self-audit
        IF $index NE '000'.
          REFRESH lr_abevaz.
*          Search for numeric values within this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hd0193da
                                   c_abevaz_a0hd0222da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0ic0240ca
                                   c_abevaz_a0ie0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          Monitor the rounded amount because FIELD_N may
*          be non-empty but no value is posted due to the factor.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          Value exists:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'O'.
*          Corrective
          ELSE.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*      Repeated self-audit
*++1908 #07.
*      WHEN C_ABEVAZ_A0GC001A.
      WHEN c_abevaz_a0hc001a.
*--1908 #07.
*        Only for self-audit
        IF $index > '001'.
          REFRESH lr_abevaz.
*          Search for numeric values within this range
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hd0193da
                                   c_abevaz_a0hd0222da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0ic0240ca
                                   c_abevaz_a0ie0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          Monitor the rounded amount because FIELD_N may
*          be non-empty but no value is posted due to the factor.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          Value exists:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'X'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
    ENDCASE.

  ENDLOOP.


ENDFORM.                    " CALC_ABEV_SZJA_1908
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_0_SZJA_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_SPACE  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM calc_abev_0_szja_1908  TABLES  t_bevallo STRUCTURE /zak/bevallo
                              t_adoazon_all STRUCTURE /zak/adoazonlpsz
                              USING   $onrev
                                      $date
                                      $index.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  DATA   lr_value  LIKE range_c3 OCCURS 0 WITH HEADER LINE.
  DATA   lr_value2 LIKE range_c3 OCCURS 0 WITH HEADER LINE.

* To avoid extending every FORM, handle the self-revision in a global
* variable:
  CLEAR v_onrev.
  IF NOT $onrev IS INITIAL.
    MOVE $onrev TO v_onrev.
  ENDIF.
**  If field1 >= field2 then set field3 zero flag
*   PERFORM GET_NULL_FLAG TABLES T_BEVALLO
*                                T_ADOAZON_ALL
*                         USING  C_ABEVAZ_M0BC0382CA         "field1
*                                C_ABEVAZ_M0BC0382BA         "field2
*                                C_ABEVAZ_M0BC0382DA.        "field3
**  If field1+field2+field3+field4 > 0 then set zero flag
*   PERFORM GET_NULL_FLAG_ASUM TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0IC0284HA
*                              "Set zero flag
*                                     C_ABEVAZ_A0IC0284CA    "field1
*                                     C_ABEVAZ_A0IC0284DA    "field2
*                                     C_ABEVAZ_A0IC0284EA    "field3
*                                     SPACE.                 "field4
** If field1 is not 0 or field2 is not 0 or field3 is not 0 or field4 is not 0
** or if field5 is not 0 then set zero flag
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
** set zero flag on field1
*     PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
*                                 USING  C_ABEVAZ_A0BC50041A.
* If field1 = field2 then set zero flag
*   PERFORM GET_NULL_FLAG_EQM TABLES T_BEVALLO
*                                    T_ADOAZON_ALL
*                             USING  C_ABEVAZ_M0FD0496AA     "field1
*                                    C_ABEVAZ_M0FD0495AA     "field2
*                                    C_ABEVAZ_M0FD0498BA     "0-flag
*                                    C_ABEVAZ_M0FD0497BA.    "0-flag
* If field1 in LR_VALUE and LR_ABEVAZ >= 0 (or), then zero flag
* perform get_null_flag_M_in_or_abevaz TABLES T_BEVALLO
*                                             T_ADOAZON_ALL
*                                             LR_VALUE
*                                             LR_ABEVAZ
*                                       using C_ABEVAZ_M0GC007A   "field1
*                                             C_ABEVAZ_M0GD0570CA."0-flag
*     PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                        T_ADOAZON_ALL
*                                 USING  C_ABEVAZ_M0BD0341BA.
*  If field1 >= field2 then set field3 zero flag
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
                        USING  c_abevaz_m0bc0308ca          "field1
                               c_abevaz_m0bc0308ba          "field2
                               c_abevaz_m0bc0308da.         "field3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0308da          "field1
                               c_abevaz_m0bc0308ba          "field2
                               c_abevaz_m0bc0308ca.         "field3

*  Set zero flag on field1
  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0312da.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bc0315da.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bd0330ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0bd0331ba.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0642aa.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0642ca.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0jd0645ca    "0flag
                                     c_abevaz_m0jc001a      "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

* Self-audit surcharge if self-revision



  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0678ca    "0flag
                                     c_abevaz_m0kd0678aa    "field1
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
*++1908 #02.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0flag
                                     c_abevaz_m0gd0570ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*--1908 #02.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0hd0605ca    "0flag
                                     c_abevaz_m0hd0603ca    "field1
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

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0574ca.

  PERFORM get_null_flag_0_m   TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0567ca.
*++1908 #02.
*  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                   T_ADOAZON_ALL
*                            USING  C_ABEVAZ_M0GD0571CA.
*--1908 #02.


  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0364da    "0flag
                                     c_abevaz_m0dc0364ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0364ea    "0flag
                                     c_abevaz_m0dc0364ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0368da    "0flag
                                     c_abevaz_m0dc0368ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0368ea    "0flag
                                     c_abevaz_m0dc0368ba    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0680aa    "0flag
                                     c_abevaz_m0kd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0680ca    "0flag
                                     c_abevaz_m0kd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0677aa    "0flag
                                     c_abevaz_m0kd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0677ca    "0flag
                                     c_abevaz_m0kd0673aa    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0565ca    "0flag
                                     c_abevaz_m0gd0564ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0569ca    "0flag
                                     c_abevaz_m0gd0568ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0573ca    "0flag
                                     c_abevaz_m0gd0572ca    "field1
                                     space                  "field2
                                     space                  "field3
                                     space                  "field4
                                     space                  "field5
                                     space.                 "field6
*++1908 #05.
* Self-audit surcharge if self-revision
  IF $index NE '000'.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0ic0240ca.
    PERFORM get_null_flag_0     TABLES t_bevallo
                                USING  c_abevaz_a0ic0242ca.
  ENDIF.
*--1908 #05.

ENDFORM.                    " CALC_ABEV_0_SZJA_1908
*&---------------------------------------------------------------------*
*&      Form  GET_LAP_SZ_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*----------------------------------------------------------------------*
FORM get_lap_sz_1908  TABLES t_bevallo STRUCTURE  /zak/bevallalv.


  DATA l_alv LIKE /zak/bevallalv.
  DATA l_index LIKE sy-tabix.
  DATA l_tabix LIKE sy-tabix.
  DATA l_nylap LIKE sy-tabix.
  DATA l_bevallo_alv LIKE /zak/bevallalv.
  DATA l_null_flag TYPE /zak/null.

  CLEAR l_index.

*  Populate ranges for managing pensioner counts
*++1908 #02.
  m_def r_a0ac047a 'I' 'EQ' 'M0FC003A' space.
*--1908 #02.
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

*   Csak SZJA-nal
    IF  w_/zak/bevall-btypart EQ c_btypart_szja.
*      Collect pensioner tax numbers
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
*  Zero flag handling was not adequate
*  If calculating self-revisions then the T_BEVALLO zero flag is needed
*  otherwise the I_/ZAK/BEVALLO zero flag.
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

*  Determine pensioners
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
*++1965 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_1965
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
FORM calc_abev_afa_1965   TABLES t_bevallo STRUCTURE /zak/bevallo
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
* Special ABEV fields

******************************************************** VAT normal only

  DATA: w_sz TYPE /zak/bevallb.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  Populate calculated fields
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
*++1865 #16.
  DATA l_sum_not_valid TYPE xfeld.
*--1865 #16.

  SORT t_bevallb BY abevaz  .
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_abevaz.
    CLEAR : l_sum,w_/zak/bevallo.
* This line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.
* 84.C. Amount of tax payable (data from line 83 if without sign)
      WHEN c_abevaz_a0dd0084ca.
        l_upd = 'X'. "Always update, because if the amount changes sign it must be cleared
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
* 00C Filing period from
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
*00C Filing period to
      WHEN c_abevaz_a0af002a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*00C Nature of the return
      WHEN c_abevaz_a0af005a.
        IF w_/zak/bevallo-zindex GE '001'.
          w_/zak/bevallo-field_c = 'O'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*04 (O) Mark repeated self-audit (x)
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
*82.B. Amount of deductible item creditable from previous period (previous period
      WHEN c_abevaz_a0dd0082ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0082ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*83.C. Combined amount of assessed tax payable for the current period.
      WHEN c_abevaz_a0dd0083ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0083ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*84.B. Amount of tax to be paid (data from line 83 if without sign)
      WHEN c_abevaz_a0dd0084ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0084ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*85.B. Amount of reclaimable tax (line 83 with negative sign, ...
      WHEN c_abevaz_a0dd0085ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0085ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*86.B. Amount of receivable carried to next period
      WHEN c_abevaz_a0dd0086ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0086ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*00F year month day
      WHEN c_abevaz_a0ai002a.
        w_/zak/bevallo-field_c = sy-datum.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*85.C. Amount of reclaimable tax (line 83 with negative sign...
      WHEN  c_abevaz_a0dd0085ca.
        l_upd = 'X'. "Always update, because if the amount changes sign it must be cleared
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
*Carried forward to next period
      WHEN  c_abevaz_a0dd0086ca.
        l_upd = 'X'. "Always update, because if the amount changes sign it must be cleared
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
* Fill every numeric value for calculated fields!
* For total calculation follow this procedure:
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
* This line must be modified!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.

*00D I do not request a disbursement
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
* Fill every numeric value for calculated fields!
* For total calculation follow this procedure:
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

*  Calculate VAT summary report fields below the threshold
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
*  Handle month
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
*  Determine amounts by tax number and invoice
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
*    Determine threshold
    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*      If it appears on form M or the threshold exceeds the configured value
      READ TABLE t_afa_szla_sum TRANSPORTING NO FIELDS
                 WITH KEY adoazon = lw_adoaz_szamlasza_sum-adoazon
                          nylapazon(3) = c_nylapazon_m02
                          mlap    = 'X'.

      IF sy-subrc NE 0 AND lw_adoaz_szamlasza_sum-lwste < l_olwste.
        CONTINUE.
      ENDIF.
*     Populate other calculated fields on the M main sheet
      PERFORM calc_abev_afa_1965_m TABLES t_bevallo
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.

*    Handle calculated fields on the M sheet fields as well
    FREE li_adoaz_szamlasza_sum.
*    Determine amounts by tax number and invoice
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE NOT mlap   IS INITIAL.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.

    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*       Populate other calculated fields on the M main sheet
*++1965 #03.
*     PERFORM CALC_ABEV_AFA_1865_M TABLES T_BEVALLO
      PERFORM calc_abev_afa_1965_m TABLES t_bevallo
*--1965 #03.
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.
  ENDIF.


************************************************************************
****
* Calculate self-audit surcharge
************************************************************************
****
  IF $index NE '000'.
* if A0DD0084CA - A0DD0084BA > 0 use this value, otherwise 0
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
*     If A0DD0082CA-A0DD0082BA < 0 reduce by this amount
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

* Determine self-audit surcharge
* Calculate ABEV A0HD0002CA from A0HD0001CA; if the index is 2 or higher multiply by 1.5
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
* Determine period
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_23337.
        IF sy-subrc EQ 0 AND
        NOT w_/zak/bevallo-field_c IS INITIAL .
* Determine the surcharge calculation deadline! tax type 104
* tax type is needed for the /ZAK/ADONEM table key !!
          SELECT SINGLE fizhat INTO w_/zak/adonem-fizhat FROM /zak/adonem
                                WHERE bukrs  EQ w_/zak/bevallo-bukrs AND
                                                 adonem EQ c_adonem_104
                                                 .
          IF sy-subrc EQ 0.
* Surcharge calculation start date
            CLEAR l_kam_kezd.
            l_kam_kezd = $date + 1 + w_/zak/adonem-fizhat.
* Surcharge calculation end date in the character field of ABEV line 5299
            CLEAR l_kam_veg.
            CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
              EXPORTING
                input  = w_/zak/bevallo-field_c
              IMPORTING
                output = l_kam_veg.
* Surcharge calculation
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
*              Handle the zero flag value during form validation
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

*  Zero flag field handling
* Ha field1 ne 0 vagy field2 ne 0 vagy field3 ne 0 vagy field4 ne 0
* or if field5 is not 0 then set zero flag
  PERFORM get_null_flag_init TABLES t_bevallo
                             USING  c_abevaz_a0hd0002ca
                             "Set zero flag
                                    c_abevaz_a0hd0001ca     "field1
                                    space                   "field2
                                    space                   "field3
                                    space                   "field4
                                    space                   "field5
                                    space.                  "field6

ENDFORM.                    " CALC_ABEV_AFA_1965

*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_1965_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_LW_ADOAZ_SZAMLASZA_SUM_ADOAZON  text
*      -->P_W_/ZAK/BEVALL  text
*----------------------------------------------------------------------*
FORM calc_abev_afa_1965_m  TABLES   $t_bevallo STRUCTURE /zak/bevallo
                                     $t_bevallb STRUCTURE /zak/bevallb
*++S4HANA#01.
*                            USING    $adoazon
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

*  M0AD001A Filing period from, can be taken from A0AF001A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad001a
                                  c_abevaz_a0af001a
                                  $adoazon.

*  M0AD002A Filing period to, can be taken from A0AF002A
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad002a
                                  c_abevaz_a0af002a
                                  $adoazon.
*++1965 #04.
* The tax number is not empty
  IF NOT $adoazon IS INITIAL.
*   ADOAZON
    PERFORM get_afa_m_value  TABLES $t_bevallo
                                    $t_bevallb
                             USING  c_abevaz_m0ac006a
                                    $adoazon
                                    $adoazon.
*  Provide group name
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

* M0AC005A Partner tax number: place the M-sheet ADOAZON here,
*if loaded from STCD1 (from /ZAK/ANALITIKA take the customer or
*vendor code + KOART indicates vendor or customer!)
*M0AC006A if loaded from STCD3
  READ TABLE $t_bevallo INTO lw_bevallo INDEX 1.
*  Populate month:
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
**   Must be filled, otherwise ABEV reports an error
**   Read the first one where it exists!
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
*    Vendor name
    ELSEIF lw_analitika-koart EQ 'K'.
      SELECT SINGLE name1 INTO l_name1
                          FROM lfa1
                         WHERE lifnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "ha nem CPD
*--1765 #26.
    ENDIF.
*    DUMMY_R record contains the name in field_c
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

ENDFORM.                    " CALC_ABEV_AFA_1965_M
*--1965 #01.
*++19A60 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONYB_19A60
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM calc_abev_onyb_19a60  TABLES t_bevallo STRUCTURE /zak/bevallo
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
* H - Monthly
  ELSEIF w_/zak/bevall-bidosz = 'H'.

  ENDIF.

  CONCATENATE l_gjahr l_monat '01' INTO l_begin_day.

* the following ABEV codes can occur only once, aggregating or character
  LOOP AT t_bevallb INTO w_/zak/bevallb
    WHERE  abevaz EQ     c_abevaz_a0ad001a
       OR  abevaz EQ     c_abevaz_a0ad002a
       OR  abevaz EQ     c_abevaz_a0ad004a
       OR  abevaz EQ     c_abevaz_a0ad005a.

* This line must be modified!
    LOOP AT t_bevallo INTO w_/zak/bevallo
                      WHERE abevaz = w_/zak/bevallb-abevaz.

      CASE w_/zak/bevallb-abevaz.

*++2010.02.11 RN
* this field is no longer on form 10A60
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
*    Populate correction flags
*    Always populate if self-revision:
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

ENDFORM.                    " CALC_ABEV_ONYB_19A60
*--19A60 #01.
*&---------------------------------------------------------------------*
*&      Form  DEL_ESDAT_FIELD_1908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_C_ABEVAZ_A0AC041A  text
*----------------------------------------------------------------------*
FORM del_esdat_field_1908  TABLES   $t_bevallo STRUCTURE /zak/bevallalv
                                     $t_bevallb STRUCTURE /zak/bevallb
                            USING    $abevaz_jelleg.

  DATA lw_/zak/bevallalv TYPE /zak/bevallalv.

*  Determine the type:
  READ TABLE $t_bevallo INTO lw_/zak/bevallalv
                        WITH KEY abevaz = $abevaz_jelleg
                        BINARY SEARCH.
*  In this case do not fill the due date:
  IF sy-subrc EQ 0 AND lw_/zak/bevallalv-field_c = 'H'.
**  Value of the ABEV identifier marked in ESDAT_FLAG
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
*  For corrective returns no zero flag is needed in the self-audit surcharge either
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

ENDFORM.                    " DEL_ESDAT_FIELD_1908
