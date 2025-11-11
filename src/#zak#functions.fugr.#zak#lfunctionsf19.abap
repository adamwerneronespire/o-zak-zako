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

*Speciális M-s számítások adóazonosítóként
*M 02-312 d Összevont adóalap ( a 300-306. sorok  és 308-3011.sorok"D"összege)
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
*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0312da.           "mező0


*M 02-315 d Az adóelőleg alapja (a 313-314. sorok különbözete)
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0312da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0313da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0314da space.
*  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van
  PERFORM get_sub_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0315da            "mező0
                             '+'.      "Az eredmény nem lehet '-'

*M 02-316 d A 312. sorból bérnek minősülő összeg (300-303. "D", 310-311 sor "A" adatai)
  REFRESH lr_abevaz.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0300da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0301da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0302da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0303da space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0310aa space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0bc0311aa space.
*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van
  PERFORM get_sum_r_m TABLES t_bevallo
                             t_bevallb
                             t_adoazon_all
                             lr_abevaz
                      USING  c_abevaz_m0bc0316da  .         "mező0

*  A0ZZ000002
  PERFORM get_sum_calc  TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0zz000002   "Módosított mező
                               c_abevaz_m0ed0418ca          "Forrás 1
                               space                        "Forrás 2
                               space                        "Forrás 3
                               space                        "Forrás 4
                               space                        "Forrás 5
                               space                        "Forrás 6
                               space                        "Forrás 7
                               space                        "Forrás 8
                               space                        "Forrás 9
                               space.                       "Forrás 10

*  A0ZZ000003
  PERFORM get_sum_calc  TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0zz000003   "Módosított mező
                               c_abevaz_m0ed0416ca          "Forrás 1
                               space                        "Forrás 2
                               space                        "Forrás 3
                               space                        "Forrás 4
                               space                        "Forrás 5
                               space                        "Forrás 6
                               space                        "Forrás 7
                               space                        "Forrás 8
                               space                        "Forrás 9
                               space.                       "Forrás 10

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
*      Meg kell határozni a feltételhez tartozó ABEV
*      azonosító értékét
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

*  Szelekciós ABEVAZ feltöltése
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


* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char
  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_sel_abevaz.

    CLEAR w_/zak/bevallo.

*    ezt a sort kell módosítani!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
             BINARY SEARCH.

    CHECK sy-subrc EQ 0.

    v_tabix = sy-tabix .

*    Speciális számítások
    CASE w_/zak/bevallb-abevaz.
*     A 03-087 A START kártyával rend 10%-os szociális hozz jár a|
      WHEN  c_abevaz_a0ec0087ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '1' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*     A 03-088 A START kártyával rend 20%-os szociális hozz jár a|
      WHEN  c_abevaz_a0ec0088ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '1' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0644CA' 'M0JC007A' lr_cond.
*     A 03-089 A START  PLUSZ kártyával rend 10%-os szociális hoz|
      WHEN  c_abevaz_a0ec0089ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*     A 03-090 A START  PLUSZ kártyával rend 20%-os szociális hoz|
      WHEN  c_abevaz_a0ec0090ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0644CA' 'M0JC007A' lr_cond.
*     A 03-091 A START EXTRA kártyával rend 10%-os szociális hozz|
      WHEN  c_abevaz_a0ec0091ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '3' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0JD0643CA' 'M0JC007A' lr_cond.
*     A 03-095 A közfogl. keretében alk.9,75% szocho köt (2-es kód,678c)
      WHEN  c_abevaz_a0ec0095ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '2' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 03-096 A s/zak/zakképzésettségen nem igénylő munkakörben fogl |
      WHEN  c_abevaz_a0ec0096ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '05' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-097 A180 napnál több mv rend 25 év alatti fogl 12,5% sz
      WHEN  c_abevaz_a0fc0097ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '07' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-099 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679.|
      WHEN  c_abevaz_a0fc0098ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '08' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-099 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.|
      WHEN  c_abevaz_a0fc0099ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '09' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*++1908 #12.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*--1908 #12.
*     A 04-100 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67|
      WHEN  c_abevaz_a0fc0100ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '10' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*++1908 #12.
        lm_get_spec_sum1 'M0KE00511A' 'M0KC007A' lr_cond.
*--1908 #12.
*     A 04-101 A szabad váll zónában működő váll 12,5% szocho (11|
      WHEN  c_abevaz_a0fc0101ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '11' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-102 A nemzeti felsőokt. Doktori képzés 12,5% szocho ke|
      WHEN  c_abevaz_a0fc0102ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '13' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-103 A mezőgazdasági fogl fiz 12,5% sz|
      WHEN  c_abevaz_a0fc0103ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '15' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-104 Karrier Híd
      WHEN  c_abevaz_a0fc0104ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '16' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0KD0678CA' 'M0KC007A' lr_cond.
*     A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611|
      WHEN  c_abevaz_a0fc0120ca.
*        Feltétel feltöltése
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
*     A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s|
      WHEN  c_abevaz_a0fc0121ca.
*       Feltétel feltöltése
        REFRESH lr_cond.
        m_def lr_cond 'I' 'EQ' '25' space.
        m_def lr_cond 'I' 'EQ' '42' space.
        m_def lr_cond 'I' 'EQ' '81' space.
        lm_get_field $index.
        lm_get_spec_sum1 'M0HD0605CA' 'M0HC004A' lr_cond.
*     A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604|
      WHEN  c_abevaz_a0fc0122ca.
*       Feltétel feltöltése
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

*  Összegzendő mezők feltöltéséhez
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  Ha önrevízió
  CHECK $index NE '000'.

  SORT t_bevallb BY abevaz.

*  Beolvassuk az előző időszak 'A'-s abev azonosítóit
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

*  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban
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
*  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül
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
                         USING  c_abevaz_a0hd0193da   "Módosított mező
                                c_abevaz_a0bc0001ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0195DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0195da   "Módosított mező
*++1908 #06.
*                                C_ABEVAZ_A0EC0074DA         "Forrás 1
                                c_abevaz_a0ec0074ca         "Forrás 1
*--1908 #06.
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0GD0192CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0195ca   "Módosított mező
                               c_abevaz_a0hd0195da
                               '0.15'.

* A0HD0196DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0196da   "Módosított mező
                                c_abevaz_a0bc0007ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5
* A0HD0197DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0197da   "Módosított mező
                                c_abevaz_a0cd0043ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5
* A0HD0197CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0197ca   "Módosított mező
                               c_abevaz_a0hd0197da
                               '0.015'.
*++1908 #06.
** A0HD0198CA
*  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
*                               T_BEVALLB
*                        USING  C_ABEVAZ_A0HD0198CA   "Módosított mező
*                               C_ABEVAZ_A0HD0198DA
*                               '0.195'.
*--1908 #06.
* A0HD0199DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0199da   "Módosított mező
                                c_abevaz_a0bc0014ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0200DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0200da   "Módosított mező
                                c_abevaz_a0fc0109ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0200CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0200ca   "Módosított mező
                               c_abevaz_a0hd0200da
                               '0.195'.

* A0HD0203DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0203da   "Módosított mező
                                c_abevaz_a0fc0123ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0203CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0203ca   "Módosított mező
                               c_abevaz_a0hd0203da
                               '0.10'.

* A0HD0210DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0210da   "Módosított mező
                                c_abevaz_a0gc0150ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0210CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0210ca   "Módosított mező
                               c_abevaz_a0hd0210da
                               '0.04'.

* A0HD0211DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0211da   "Módosított mező
                                c_abevaz_a0gc0151ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0211CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0211ca   "Módosított mező
                               c_abevaz_a0hd0211da
                               '0.03'.

* A0HD0212DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0212da   "Módosított mező
                                c_abevaz_a0gc0152ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0212CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0212ca   "Módosított mező
                               c_abevaz_a0hd0212da
                               '0.015'.

* A0HD0213DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0213da   "Módosított mező
                                c_abevaz_a0gc0154ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0213CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0213ca   "Módosított mező
                               c_abevaz_a0hd0213da
                               '0.095'.

* A0HD0214DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0214da   "Módosított mező
                                c_abevaz_a0gc0155ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0214CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0214ca   "Módosított mező
                               c_abevaz_a0hd0214da
                               '0.195'.

* A0HD0215DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0215da   "Módosított mező
                                c_abevaz_a0gc0156ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0215CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0215ca   "Módosított mező
                               c_abevaz_a0hd0215da
                               '0.111'.

* A0HD0216DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0216da   "Módosított mező
                                c_abevaz_a0gc0157ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0216CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0216ca   "Módosított mező
                               c_abevaz_a0hd0216da
                               '0.15'.

* A0HD0217AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0217aa   "Módosított mező
                                c_abevaz_a0gc0158ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0218AA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0218aa   "Módosított mező
                                c_abevaz_a0gc0159ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0219DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0219da   "Módosított mező
                                c_abevaz_a0gc0124ca         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0219CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0219ca   "Módosított mező
                               c_abevaz_a0hd0219da
                               '0.13'.

* A0HD0221DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0221da   "Módosított mező
                                c_abevaz_a0zz000003         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0221CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0221ca   "Módosított mező
                               c_abevaz_a0hd0221da
                               '0.195'.

* A0HD0222DA
  PERFORM get_onrev_calc TABLES t_bevallo
                                li_last_bevallo
                                t_bevallb
                         USING  c_abevaz_a0hd0222da   "Módosított mező
                                c_abevaz_a0zz000002         "Forrás 1
                                space                       "Forrás 2
                                space                       "Forrás 3
                                space                       "Forrás 4
                                space.                      "Forrás 5

* A0HD0222CA
  PERFORM get_onrev_div TABLES t_bevallo
                               t_bevallb
                        USING  c_abevaz_a0hd0222ca   "Módosított mező
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

*  Önellenőrzés meghatározásához
  RANGES lr_abevaz FOR /zak/bevallo-abevaz.
  RANGES lr_sel_abevaz FOR /zak/bevallo-abevaz.

************************************************************************
* Speciális abev mezők
************************************************************************

  SORT t_bevallb BY abevaz  .

* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char

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

*    ezt a sort kell módosítani!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz
         BINARY SEARCH.

    CHECK sy-subrc EQ 0.
    v_tabix = sy-tabix .


    CASE w_/zak/bevallb-abevaz.
*      időszak-tól első nap
      WHEN c_abevaz_a0ac039a.
* Havi
        IF w_/zak/bevall-bidosz = 'H'.
          l_kam_kezd = $date.
          l_kam_kezd+6(2) = '01'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Éves
        ELSEIF w_/zak/bevall-bidosz = 'E'.
          l_kam_kezd = $date.
          l_kam_kezd+4(4) = '0101'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Negyedéves
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

*      időszak-ig utolsó nap
      WHEN c_abevaz_a0ac040a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.

*      Adózók száma = Adószámok
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
*      Helyesbítés, Önellenőrzés
      WHEN c_abevaz_a0ac041a.
*        Csak önellenőrzésénél
        IF $index NE '000'.
          REFRESH lr_abevaz.
*          Ebben a tartományban kell keresni numerikus értéket
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hd0193da
                                   c_abevaz_a0hd0222da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0ic0240ca
                                   c_abevaz_a0ie0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          A kerekített összeget figyeljük mert lehet hogy a FIELD_N
*          nem üres de a bevallásba nem kerül érték a fkator miatt.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          Van érték:
          IF sy-subrc EQ 0.
            w_/zak/bevallo-field_c = 'O'.
*          Helyesbítő
          ELSE.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
          CONDENSE w_/zak/bevallo-field_c.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*      Ismételt önellenőrzés
*++1908 #07.
*      WHEN C_ABEVAZ_A0GC001A.
      WHEN c_abevaz_a0hc001a.
*--1908 #07.
*        Csak önellenőrzésénél
        IF $index > '001'.
          REFRESH lr_abevaz.
*          Ebben a tartományban kell keresni numerikus értéket
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0hd0193da
                                   c_abevaz_a0hd0222da.
          m_def lr_abevaz 'I' 'BT' c_abevaz_a0ic0240ca
                                   c_abevaz_a0ie0255ca.
          LOOP AT t_bevallo INTO l_bevallo WHERE abevaz IN lr_abevaz
*          A kerekített összeget figyeljük mert lehet hogy a FIELD_N
*          nem üres de a bevallásba nem kerül érték a fkator miatt.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT field_nr IS INITIAL.
            EXIT.
          ENDLOOP.
*          Van érték:
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

* Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális
* változóba kezeljük:
  CLEAR v_onrev.
  IF NOT $onrev IS INITIAL.
    MOVE $onrev TO v_onrev.
  ENDIF.
**  Ha mező1 >= mező2 akkor mező3 0 flag beállítás
*   PERFORM GET_NULL_FLAG TABLES T_BEVALLO
*                                T_ADOAZON_ALL
*                         USING  C_ABEVAZ_M0BC0382CA         "mező1
*                                C_ABEVAZ_M0BC0382BA         "mező2
*                                C_ABEVAZ_M0BC0382DA.        "mező3
**  Ha mező1+mező2+mező3+mező4 > 0 akkor 0 flag beállítás
*   PERFORM GET_NULL_FLAG_ASUM TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0IC0284HA
*                              "0-flag beállítás
*                                     C_ABEVAZ_A0IC0284CA    "mező1
*                                     C_ABEVAZ_A0IC0284DA    "mező2
*                                     C_ABEVAZ_A0IC0284EA    "mező3
*                                     SPACE.                 "mező4
** Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0
** vagy mező5 ne 0 akkor 0 flag beállítás
*   PERFORM GET_NULL_FLAG_INIT TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0DC0087DA    "0flag
*                                     C_ABEVAZ_A0DC0087CA    "mező1
*                                     SPACE                  "mező2
*                                     SPACE                  "mező3
*                                     SPACE                  "mező4
*                                     SPACE                  "mező5
*                                     SPACE.                 "mező6
*   PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                      T_ADOAZON_ALL
*                               USING  C_ABEVAZ_M0CC0415DA   "0flag
*                                      C_ABEVAZ_M0BC0382BA   "mező1
*                                      C_ABEVAZ_M0BC0386BA   "mező2
*                                      SPACE                 "mező3
*                                      SPACE                 "mező4
*                                      SPACE                 "mező5
*                                      SPACE.                "mező6
** mező1-n 0 flag állítás
*     PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
*                                 USING  C_ABEVAZ_A0BC50041A.
* Ha mező1 = mező2 akkor  0 flag állítás
*   PERFORM GET_NULL_FLAG_EQM TABLES T_BEVALLO
*                                    T_ADOAZON_ALL
*                             USING  C_ABEVAZ_M0FD0496AA     "mező1
*                                    C_ABEVAZ_M0FD0495AA     "mező2
*                                    C_ABEVAZ_M0FD0498BA     "0-flag
*                                    C_ABEVAZ_M0FD0497BA.    "0-flag
* Ha mező1 in LR_VALUE and LR_ABEVAZ >= 0 (or), akkor 0-flag
* perform get_null_flag_M_in_or_abevaz tables T_BEVALLO
*                                             T_ADOAZON_ALL
*                                             LR_VALUE
*                                             LR_ABEVAZ
*                                       using C_ABEVAZ_M0GC007A   "mező1
*                                             C_ABEVAZ_M0GD0570CA."0-flag
*     PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
*                                        T_ADOAZON_ALL
*                                 USING  C_ABEVAZ_M0BD0341BA.
*  Ha mező1 >= mező2 akkor mező3 0 flag beállítás
  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0301ca          "mező1
                               c_abevaz_m0bc0301ba          "mező2
                               c_abevaz_m0bc0301da.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0301da          "mező1
                               c_abevaz_m0bc0301ba          "mező2
                               c_abevaz_m0bc0301ca.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0302ca          "mező1
                               c_abevaz_m0bc0302ba          "mező2
                               c_abevaz_m0bc0302da.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0302da          "mező1
                               c_abevaz_m0bc0302ba          "mező2
                               c_abevaz_m0bc0302ca.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0305ca          "mező1
                               c_abevaz_m0bc0305ba          "mező2
                               c_abevaz_m0bc0305da.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0305da          "mező1
                               c_abevaz_m0bc0305ba          "mező2
                               c_abevaz_m0bc0305ca.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0306ca          "mező1
                               c_abevaz_m0bc0306ba          "mező2
                               c_abevaz_m0bc0306da.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0306da          "mező1
                               c_abevaz_m0bc0306ba          "mező2
                               c_abevaz_m0bc0306ca.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0307ca          "mező1
                               c_abevaz_m0bc0307ba          "mező2
                               c_abevaz_m0bc0307da.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0307da          "mező1
                               c_abevaz_m0bc0307ba          "mező2
                               c_abevaz_m0bc0307ca.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0308ca          "mező1
                               c_abevaz_m0bc0308ba          "mező2
                               c_abevaz_m0bc0308da.         "mező3

  PERFORM get_null_flag TABLES t_bevallo
                               t_adoazon_all
                        USING  c_abevaz_m0bc0308da          "mező1
                               c_abevaz_m0bc0308ba          "mező2
                               c_abevaz_m0bc0308ca.         "mező3

*  mező1-n 0 flag állítás
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
                                     c_abevaz_m0jc001a      "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

* Önellenőrzési pótlék ha önrevízió



  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0678ca    "0flag
                                     c_abevaz_m0kd0678aa    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0564ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "mező1
                                              c_abevaz_m0gd0566ca. "0 flag

  REFRESH: lr_value, lr_abevaz.
  m_def lr_value  'I' 'EQ' 'I' space.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_m0gd0568ca space.

  PERFORM get_null_flag_m_in_or_abevaz TABLES t_bevallo
                                              t_adoazon_all
                                              lr_value
                                              lr_abevaz
                                        USING c_abevaz_m0gc007a    "mező1
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
                                        USING c_abevaz_m0gc007a    "mező1
                                              c_abevaz_m0gd0578ca. "0 flag

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0567ca    "0flag
                                     c_abevaz_m0gd0565ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0flag
                                     c_abevaz_m0gd0569ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6
*++1908 #02.
  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0571ca    "0flag
                                     c_abevaz_m0gd0570ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6
*--1908 #02.

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0hd0605ca    "0flag
                                     c_abevaz_m0hd0603ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

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
                                     c_abevaz_m0dc0364ba    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0364ea    "0flag
                                     c_abevaz_m0dc0364ba    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0368da    "0flag
                                     c_abevaz_m0dc0368ba    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0dc0368ea    "0flag
                                     c_abevaz_m0dc0368ba    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0680aa    "0flag
                                     c_abevaz_m0kd0673aa    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0680ca    "0flag
                                     c_abevaz_m0kd0673aa    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0677aa    "0flag
                                     c_abevaz_m0kd0673aa    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0kd0677ca    "0flag
                                     c_abevaz_m0kd0673aa    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0565ca    "0flag
                                     c_abevaz_m0gd0564ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0569ca    "0flag
                                     c_abevaz_m0gd0568ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6

  PERFORM get_null_flag_initm TABLES t_bevallo
                                     t_adoazon_all
                              USING  c_abevaz_m0gd0573ca    "0flag
                                     c_abevaz_m0gd0572ca    "mező1
                                     space                  "mező2
                                     space                  "mező3
                                     space                  "mező4
                                     space                  "mező5
                                     space.                 "mező6
*++1908 #05.
* Önellenőrzési pótlék ha önrevízió
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

*  RANGEK feltöltése Nyugdíjas darabszám kezeléshez
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

*  Értékek
  m_def r_nylapval 'I' 'EQ' '3' space.
  m_def r_nylapval 'I' 'EQ' '7' space.
  m_def r_nylapval 'I' 'EQ' '8' space.


  REFRESH i_nylap.

  LOOP AT i_/zak/bevallo INTO w_/zak/bevallo.
    l_tabix = sy-tabix.

*   Dialógus futás biztosításhoz
    PERFORM process_ind_item USING '100000'
                                   l_index
                                   TEXT-p01.

*   Csak SZJA-nal
    IF  w_/zak/bevall-btypart EQ c_btypart_szja.
*      Nyugdíjas adószámok gyűjtése
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
*  Nem volt megfelelő a 0 flag kezelés
*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell
*  egyébként a I_/ZAK/BEVALLO 0 flag.
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

*  Nyugdíjasok meghatározása
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
  ENDIF.                                 "Kérem, adja meg <...> helyes nevét.

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
* Speciális abev mezők

******************************************************** CSAK ÁFA normál

  DATA: w_sz TYPE /zak/bevallb.

  RANGES lr_abevaz FOR /zak/bevallo-abevaz.

*  Számított mezők feltöltése
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
* ezt a sort kell módosítani!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.
* 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli)
      WHEN c_abevaz_a0dd0084ca.
        l_upd = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell
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
* 00C Bevallási időszak -tól
      WHEN c_abevaz_a0af001a.
* Havi
        IF w_/zak/bevall-bidosz = 'H'.
          l_kam_kezd = $date.
          l_kam_kezd+6(2) = '01'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Éves
        ELSEIF w_/zak/bevall-bidosz = 'E'.
          l_kam_kezd = $date.
          l_kam_kezd+4(4) = '0101'.
          w_/zak/bevallo-field_c = l_kam_kezd.
* Negyedéves
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
*00C Bevallási időszak -ig
      WHEN c_abevaz_a0af002a.
        w_/zak/bevallo-field_c = $date.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*00C Bevallás jellege
      WHEN c_abevaz_a0af005a.
        IF w_/zak/bevallo-zindex GE '001'.
          w_/zak/bevallo-field_c = 'O'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*04 (O) Ismételt önellenőrzés jelölése (x)
      WHEN c_abevaz_a0hc001a.
*        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés
        IF w_/zak/bevallo-zindex > '001'.
          w_/zak/bevallo-field_c = 'X'.
          MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
        ENDIF.
*00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves
      WHEN c_abevaz_a0af006a.
        w_/zak/bevallo-field_c = w_/zak/bevall-bidosz.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id.
      WHEN c_abevaz_a0dd0082ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0082ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének.
      WHEN c_abevaz_a0dd0083ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0083ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli)
      WHEN c_abevaz_a0dd0084ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0084ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ...
      WHEN c_abevaz_a0dd0085ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0085ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*86.B. Következő időszakra átvihető követelés összege
      WHEN c_abevaz_a0dd0086ba.
        PERFORM set_bevallo USING c_abevaz_a0dd0086ca
                            CHANGING w_/zak/bevallo.
        l_upd = 'X'.
*00F év hó nap
      WHEN c_abevaz_a0ai002a.
        w_/zak/bevallo-field_c = sy-datum.
        MODIFY t_bevallo FROM w_/zak/bevallo INDEX v_tabix.
*85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor...
      WHEN  c_abevaz_a0dd0085ca.
        l_upd = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell
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
*Következő időszakra átvitt
      WHEN  c_abevaz_a0dd0086ca.
        l_upd = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell
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
* számított mezőnél minden numerikus értéket tölteni!
* összeg képzésnél a következő az eljárás:
* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
* majd a beálított kerekítési szabályt alkalmazni!
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

*  Függő mezők számítása
*++S4HANA#01.
*  REFRESH lr_abevaz.
  CLEAR lr_abevaz[].
*--S4HANA#01.
  m_def lr_abevaz 'I' 'EQ' c_abevaz_a0ag016a space.

  LOOP AT t_bevallb INTO w_/zak/bevallb WHERE abevaz IN lr_abevaz.
    CLEAR : l_sum,w_/zak/bevallo.
* ezt a sort kell módosítani!
    READ TABLE t_bevallo INTO w_/zak/bevallo
    WITH KEY abevaz = w_/zak/bevallb-abevaz.
    v_tabix = sy-tabix .
    CLEAR: w_/zak/bevallo-field_n,
           w_/zak/bevallo-field_nr,
           w_/zak/bevallo-field_nrk.


    CASE w_/zak/bevallb-abevaz.

*00D Kiutalást nem kérek
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
* számított mezőnél minden numerikus értéket tölteni!
* összeg képzésnél a következő az eljárás:
* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
* majd a beálított kerekítési szabályt alkalmazni!
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

*  Összesítő jelentés ÁFA értékhatár alatti mezők számítása
  IF NOT $omrel IS INITIAL.
*  Értékhatár
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
*  Hónap kezelése
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
*  Összeg meghatározása adószámonként, számlánként
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE mlap   IS INITIAL
                            AND nylapazon(3) = c_nylapazon_m02.
*      Csak a hónapon belül kell összesíteni
      CHECK lw_afa_szla_sum-gjahr EQ $date(4) AND
            lw_afa_szla_sum-monat IN lr_monat.
      CLEAR lw_adoaz_szamlasza_sum.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      lw_adoaz_szamlasza_sum-lwste      = lw_afa_szla_sum-lwste.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.
*    Értékhatár meghatározása
    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál
      READ TABLE t_afa_szla_sum TRANSPORTING NO FIELDS
                 WITH KEY adoazon = lw_adoaz_szamlasza_sum-adoazon
                          nylapazon(3) = c_nylapazon_m02
                          mlap    = 'X'.

      IF sy-subrc NE 0 AND lw_adoaz_szamlasza_sum-lwste < l_olwste.
        CONTINUE.
      ENDIF.
*     M-es főlap egyéb számított mezők töltése töltése
      PERFORM calc_abev_afa_1965_m TABLES t_bevallo
                                          t_bevallb
                                   USING  lw_adoaz_szamlasza_sum-adoazon
                                          w_/zak/bevall.
    ENDLOOP.

*    Számított mezők kezelése az M lapos mezőkön is
    FREE li_adoaz_szamlasza_sum.
*    Összeg meghatározása adószámonként, számlánként
    LOOP AT t_afa_szla_sum INTO lw_afa_szla_sum
                          WHERE NOT mlap   IS INITIAL.
      lw_adoaz_szamlasza_sum-adoazon    = lw_afa_szla_sum-adoazon.
      COLLECT lw_adoaz_szamlasza_sum INTO li_adoaz_szamlasza_sum.
    ENDLOOP.

    LOOP AT li_adoaz_szamlasza_sum INTO lw_adoaz_szamlasza_sum.
*       M-es főlap egyéb számított mezők töltése töltése
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
* önellenörzési pótlék számítása
************************************************************************
****
  IF $index NE '000'.
* ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0
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
* (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték
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
* A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték
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
*     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell
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

* önellenörzési pótlék  meghatározása
* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5
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
* időszak meghatározása
        READ TABLE t_bevallo INTO w_/zak/bevallo
                             WITH KEY abevaz = c_abevaz_23337.
        IF sy-subrc EQ 0 AND
        NOT w_/zak/bevallo-field_c IS INITIAL .
* a pótlék számitás határidejének meghatározása! a 104-es
* adónem kell a /ZAK/ADONEM tábla kulcshoz !!
          SELECT SINGLE fizhat INTO w_/zak/adonem-fizhat FROM /zak/adonem
                                WHERE bukrs  EQ w_/zak/bevallo-bukrs AND
                                                 adonem EQ c_adonem_104
                                                 .
          IF sy-subrc EQ 0.
* pótlék számítás kezdeti dátuma
            CLEAR l_kam_kezd.
            l_kam_kezd = $date + 1 + w_/zak/adonem-fizhat.
* pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében
            CLEAR l_kam_veg.
            CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
              EXPORTING
                input  = w_/zak/bevallo-field_c
              IMPORTING
                output = l_kam_veg.
* pótlék számítás
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
*              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés
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
*      Ha van érték, korrigálni kell a A0HD0001CA-at.
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

*  0 flag mező kezelés
* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0
* vagy mező5 ne 0 akkor 0 flag beállítás
  PERFORM get_null_flag_init TABLES t_bevallo
                             USING  c_abevaz_a0hd0002ca
                             "0-flag beállítás
                                    c_abevaz_a0hd0001ca     "mező1
                                    space                   "mező2
                                    space                   "mező3
                                    space                   "mező4
                                    space                   "mező5
                                    space.                  "mező6

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

*  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac001a
                                  c_abevaz_a0ae001a
                                  $adoazon.
*  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac004a
                                  c_abevaz_a0ae004a
                                  $adoazon.

*  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ac005a
*++1965 #02.
*                                 C_ABEVAZ_A0AE005A
                                  c_abevaz_a0ae006a
*--1965 #02.
                                  $adoazon.

*  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad001a
                                  c_abevaz_a0af001a
                                  $adoazon.

*  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból
  PERFORM get_afa_m_abevaz TABLES $t_bevallo
                                  $t_bevallb
                           USING  c_abevaz_m0ad002a
                                  c_abevaz_a0af002a
                                  $adoazon.
*++1965 #04.
* Az nem üres az adószám
  IF NOT $adoazon IS INITIAL.
*   ADOAZON
    PERFORM get_afa_m_value  TABLES $t_bevallo
                                    $t_bevallb
                             USING  c_abevaz_m0ac006a
                                    $adoazon
                                    $adoazon.
*  Csoport név megadása
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

* M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,
*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy
*szállító kódot+KOART megadja hogy száll. Vagy vevő!)
*M0AC006A ha STCD3-ból töltöttük
  READ TABLE $t_bevallo INTO lw_bevallo INDEX 1.
*  Hónap feltöltése:
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
**   Mivel ki kell tölteni mert egyébként hibát az ABEV hibát ad
**   kiolvassuk az első-t ahol van!
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
*    Vevő neve:
    IF lw_analitika-koart EQ 'D'.
      SELECT SINGLE name1 INTO l_name1
                          FROM kna1
                         WHERE kunnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "ha nem CPD
*--1765 #26.
*    Szállító neve
    ELSEIF lw_analitika-koart EQ 'K'.
      SELECT SINGLE name1 INTO l_name1
                          FROM lfa1
                         WHERE lifnr EQ lw_analitika-lifkun
*++1765 #26.
                            AND xcpdk NE 'X'.    "ha nem CPD
*--1765 #26.
    ENDIF.
*    DUMMY_R-es rekordon a field_c-ben van név
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
*      DUMMY_R FIELD_C mező
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
* E - Éves
  IF w_/zak/bevall-bidosz = 'E'.
    l_monat = '01'.
* N - Negyedéves
  ELSEIF w_/zak/bevall-bidosz = 'N'.
    SUBTRACT 2 FROM l_monat.
* H - Havi
  ELSEIF w_/zak/bevall-bidosz = 'H'.

  ENDIF.

  CONCATENATE l_gjahr l_monat '01' INTO l_begin_day.

* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char
  LOOP AT t_bevallb INTO w_/zak/bevallb
    WHERE  abevaz EQ     c_abevaz_a0ad001a
       OR  abevaz EQ     c_abevaz_a0ad002a
       OR  abevaz EQ     c_abevaz_a0ad004a
       OR  abevaz EQ     c_abevaz_a0ad005a.

* ezt a sort kell módosítani!
    LOOP AT t_bevallo INTO w_/zak/bevallo
                      WHERE abevaz = w_/zak/bevallb-abevaz.

      CASE w_/zak/bevallb-abevaz.

*++2010.02.11 RN
* ez a mező már nincs rajta a 10A60-on
**    Aláírás dátuma (sy-datum)
*         WHEN  C_ABEVAZ_24.
*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.
*--2010.02.11 RN
*    IDŐSZAK kezdő dátuma
        WHEN  c_abevaz_a0ad001a.
          w_/zak/bevallo-field_c = l_begin_day.
*    IDŐSZAK záró dátuma
        WHEN  c_abevaz_a0ad002a.
          w_/zak/bevallo-field_c = $last_date.
*    Helyebítési flagek töltése
*    Mindig feltöltjük ha önrevízió:
        WHEN  c_abevaz_a0ad004a.
          IF w_/zak/bevallo-zindex NE '000'.
            w_/zak/bevallo-field_c = 'H'.
          ENDIF.
*    Bevallás gyakorisága
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

*  Meghatározzuk a jelleget:
  READ TABLE $t_bevallo INTO lw_/zak/bevallalv
                        WITH KEY abevaz = $abevaz_jelleg
                        BINARY SEARCH.
*  Ebben az esetben nem kell tölteni az esedékesség dátumát:
  IF sy-subrc EQ 0 AND lw_/zak/bevallalv-field_c = 'H'.
**  ESDAT_FLAG-ben megjelölt ABEV azonosító értéke
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
*  Helyesbítőnél nem kell az önellenőrzési pótlékban sem 0 flag
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
