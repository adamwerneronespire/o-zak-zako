FUNCTION /zak/afa_ness_szla_exit.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     REFERENCE(I_START) TYPE  /ZAK/START OPTIONAL
*"     REFERENCE(I_TEST) TYPE  XFELD OPTIONAL
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA OPTIONAL
*"      T_AFA_SZLA STRUCTURE  /ZAK/AFA_SZLA OPTIONAL
*"      T_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     REFERENCE(I_START) TYPE  /ZAK/START OPTIONAL
*"     REFERENCE(I_TEST) TYPE  XFELD OPTIONAL
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA OPTIONAL
*"      T_AFA_SZLA STRUCTURE  /ZAK/AFA_SZLA OPTIONAL
*++1665 #08.
*"      T_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*--1665 #08.
*"----------------------------------------------------------------------
*Feldolgozott bizonylatok
  TYPES: BEGIN OF lt_proc_belnr,
           bukrs TYPE bukrs,
*++1365 #5.
*        belnr TYPE belnr_d,
           gjahr TYPE gjahr,
           belnr TYPE belnr_d,
           buzei TYPE buzei,
*--1365 #5.
         END OF lt_proc_belnr.
* MM AWKEY
  TYPES: BEGIN OF lt_awkey_decode,
           belnr TYPE re_belnr,
           gjahr TYPE gjahr,
         END OF lt_awkey_decode.
*++1465 #05.
*Rendezett bizonylatok
  TYPES: BEGIN OF lt_analitika_sort,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
           belnr TYPE belnr_d,
           buzei TYPE buzei,
           cpudt TYPE cpudt,
           cputm TYPE cputm,
         END OF lt_analitika_sort.
  DATA li_analitika_sort TYPE STANDARD TABLE OF lt_analitika_sort.
  DATA lw_analitika_sort TYPE lt_analitika_sort.
*--1465 #05.

  DATA ls_awkdec TYPE lt_awkey_decode.

  DATA li_proc_belnr TYPE STANDARD TABLE OF lt_proc_belnr.
  DATA lw_proc_belnr TYPE lt_proc_belnr.

  DATA li_analitika_ins TYPE STANDARD TABLE OF /zak/analitika.
  DATA lw_analitika TYPE /zak/analitika.
  DATA lw_afa_szla  TYPE /zak/afa_szla.
  DATA lw_afa_szla_tmp TYPE /zak/afa_szla.
  DATA l_awtyp TYPE awtyp.
  DATA l_awkey TYPE awkey.
  DATA l_vbeln TYPE vbeln_vf.
  DATA l_btype TYPE /zak/btype.
  DATA l_storno TYPE xfeld.
  DATA l_fkdat_e TYPE fkdat.
*++1365 #6.
  DATA l_bldat_e TYPE bldat.
*--1365 #6.
  DATA l_tabix LIKE sy-tabix.
*++1365 #10.
  DATA lw_analitika_bset TYPE /zak/analitika.
  DATA l_teljdat TYPE datum.
  DATA li_tel_afa TYPE STANDARD TABLE OF /zak/tel_afa.
*++2065 #12.
  DATA li_h_bset TYPE STANDARD TABLE OF bset.
  FIELD-SYMBOLS: <bset> TYPE ANY TABLE.
*--2065 #12.
  DATA lw_tel_afa TYPE /zak/tel_afa.
*++S4HANA#01.
  DATA lt_fagl_bseg_tmp TYPE fagl_t_bseg.
  DATA: lt_lw_analitika_drv TYPE STANDARD TABLE OF /zak/analitika.
  TYPES: BEGIN OF ts_bkpf_new,
           cpudt LIKE lw_analitika_sort-cpudt,
           cputm LIKE lw_analitika_sort-cputm,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
         END OF ts_bkpf_new.
  DATA: lt_bkpf_new TYPE HASHED TABLE OF ts_bkpf_new
      WITH UNIQUE KEY bukrs belnr gjahr.
  DATA: lt_afa_szla_drv TYPE STANDARD TABLE OF /zak/afa_szla.
*--S4HANA#01.
  RANGES lr_mwskz FOR bset-mwskz.
  DATA li_bset TYPE STANDARD TABLE OF bset.
  DATA lw_bset TYPE bset.
  DATA li_afa_cust TYPE STANDARD TABLE OF /zak/afa_cust.
  DATA lw_afa_cust TYPE /zak/afa_cust.
  DATA li_afa_ktosl TYPE STANDARD TABLE OF /zak/afa_ktosl.
  DATA lw_afa_ktosl TYPE /zak/afa_ktosl.
*--1365 #10.
*++1465 #18.
  DATA li_afa_lifknm TYPE STANDARD TABLE OF /zak/afa_lifknm.
*--1465 #18.
* Fordított művelet kulcsok meghatározása
*++S4HANA#01.*
*  DATA: BEGIN OF li_fmuv OCCURS 0,
*          btype  TYPE /zak/btype,
*          rc3    TYPE TABLE OF range_c3,
**++1865 #13.
*          rc3m01 TYPE TABLE OF range_c3,
**--1865 #13.
*        END OF li_fmuv.
*  DATA lw_fmuv LIKE li_fmuv.
  TYPES: BEGIN OF ts_li_fmuv ,
           btype  TYPE /zak/btype,
           rc3    TYPE TABLE OF range_c3 WITH DEFAULT KEY,
           rc3m01 TYPE TABLE OF range_c3 WITH DEFAULT KEY,
         END OF ts_li_fmuv .
  TYPES tt_li_fmuv TYPE STANDARD TABLE OF ts_li_fmuv .
  DATA: ls_li_fmuv TYPE ts_li_fmuv.
  DATA: lt_li_fmuv TYPE tt_li_fmuv.
  DATA lw_fmuv TYPE ts_li_fmuv.
*--S4HANA#01.
  RANGES lr_fmuv FOR /zak/afa_fmuv-ktosl.
*++1865 #13.
  RANGES lr_fmuv_m01 FOR /zak/afa_fmuv-ktosl.
  DATA l_cpudt TYPE cpudt.
  DATA l_m01valid TYPE /zak/m01valid.
*--1865 #13.
*++1365 #19.
* Nem összesítő releváns ÁFA kódok
*++S4HANA#01.
*  DATA: BEGIN OF li_mwskz_nm OCCURS 0,
*          btype TYPE /zak/btype,
*          rc2   TYPE TABLE OF range_c2,
*        END OF li_mwskz_nm.
*  DATA lw_mwskz_nm LIKE li_mwskz_nm.
  TYPES: BEGIN OF ts_li_mwskz_nm ,
           btype TYPE /zak/btype,
           rc2   TYPE TABLE OF range_c2 WITH DEFAULT KEY,
         END OF ts_li_mwskz_nm .
  TYPES tt_li_mwskz_nm TYPE STANDARD TABLE OF ts_li_mwskz_nm .
  DATA: ls_li_mwskz_nm TYPE ts_li_mwskz_nm.
  DATA: lt_li_mwskz_nm TYPE tt_li_mwskz_nm.
  DATA lw_mwskz_nm TYPE ts_li_mwskz_nm.
*--S4HANA#01.
  RANGES lr_mwskz_nm FOR /zak/afa_mwskznm-mwskz.
*--1365 #19.
*++1665 #14.
  DATA li_blart_nm TYPE STANDARD TABLE OF /zak/afa_blartnm INITIAL SIZE 0.
*--1665 #14.
*++1465 #04.
*++S4HANA#01.
*  DATA li_/zak/afa_cust TYPE STANDARD TABLE OF /zak/afa_cust
*                       INITIAL SIZE 0 WITH HEADER LINE.
  DATA lt_li_/zak/afa_cust TYPE STANDARD TABLE OF /zak/afa_cust
                     INITIAL SIZE 0 .
  DATA: ls_li_/zak/afa_cust TYPE /zak/afa_cust.
*--S4HANA#01.
*--1465 #04.
*++1665 #13.
  DATA: l_lwbas TYPE lwbas_bset,
        l_fwbas TYPE fwbas_bses,
        l_lwste TYPE /zak/lwste,
        l_fwste TYPE /zak/fwste,
        l_hwbtr TYPE /zak/hwbtr,
        l_fwbtr TYPE /zak/fwbtr.
*--1665 #13.
*++1765 #11.
* Nem levonható művelet kulcsok meghatározása
*++S4HANA#01.
*  DATA: BEGIN OF li_stazf OCCURS 0,
*          mwskz TYPE mwskz,
*          ktosl TYPE ktosl,
*          stazf TYPE stazf_007b,
*        END OF li_stazf.
  TYPES: BEGIN OF ts_li_stazf ,
           mwskz TYPE mwskz,
           ktosl TYPE ktosl,
           stazf TYPE stazf_007b,
         END OF ts_li_stazf .
  TYPES tt_li_stazf TYPE STANDARD TABLE OF ts_li_stazf .
  DATA: ls_li_stazf TYPE ts_li_stazf.
  DATA: lt_li_stazf TYPE tt_li_stazf.
*--S4HANA#01.
*--1765 #11.
*++1765 #16.
  DATA  l_datum TYPE datum.
*--1765 #16.
*++1765 2017.06.13
  DATA  li_szamla TYPE /zak/szamla_t.
  DATA  lw_szamla TYPE /zak/szamla_s.
  FIELD-SYMBOLS <lw_szamla> TYPE any.
  DATA  lw_afa_szla_s  TYPE /zak/afa_szla.
  DATA  lw_analitika_s  TYPE /zak/analitika.
*--1765 2017.06.13
*++1765 2017.09.19
  DATA  lw_sel_prlog TYPE /zak/sel_prlog.
  DATA  c_prlog_items TYPE int4 VALUE 1000.
  DATA  l_prlog_items TYPE int4.
*--1765 2017.09.19
*++2265 #10.
  DATA li_mwskz_ns TYPE STANDARD TABLE OF /zak/afa_mwskzns INITIAL SIZE 0.
*--2265 #10.

  DEFINE lm_set_noneed_szamlasze.
* Ellenőrizzük az aktuális adatokban
    READ TABLE t_afa_szla INTO lw_afa_szla_tmp
             WITH KEY bukrs     = &2-bukrs
                      adoazon   = &2-adoazon
                      szamlasza = &1-szamlasza
                      szamlasz  = &2-szamlasze.
    IF sy-subrc EQ 0.
      l_tabix = sy-tabix.
      lw_afa_szla_tmp-noneed = 'X'.
      MODIFY t_afa_szla FROM lw_afa_szla_tmp INDEX l_tabix
                        TRANSPORTING noneed.

*   Adat az adatbázisban van
    ELSE.
      SELECT SINGLE * INTO lw_afa_szla_tmp
                           FROM /zak/afa_szla
                          WHERE bukrs     EQ &2-bukrs
                            AND adoazon   EQ &2-adoazon
                            AND szamlasza EQ &1-szamlasza
                            AND szamlasz  EQ &2-szamlasze.
      IF sy-subrc EQ 0 AND lw_afa_szla_tmp-noneed IS INITIAL.
        lw_afa_szla_tmp-noneed = 'X'.
*++1465 #07.
*Ebben az esetben közvetlenül módosítjuk a rekordot mert egyébként
*létre jön egy külön package azonosítóval még egyszer!
*        APPEND LW_AFA_SZLA_TMP TO T_AFA_SZLA.
        IF i_test IS INITIAL.
          UPDATE /zak/afa_szla SET noneed     =  lw_afa_szla_tmp-noneed
                            WHERE bukrs      =  lw_afa_szla_tmp-bukrs
                              AND adoazon    =  lw_afa_szla_tmp-adoazon
                              AND pack       =  lw_afa_szla_tmp-pack
                              AND bseg_gjahr =  lw_afa_szla_tmp-bseg_gjahr
                              AND bseg_belnr =  lw_afa_szla_tmp-bseg_belnr
                              AND bseg_buzei =  lw_afa_szla_tmp-bseg_buzei
                              AND szamlasza  =  lw_afa_szla_tmp-szamlasza.
        ENDIF.
*--1465 #07.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.
*++1765 #05.
  DATA lt_return TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.
*--1765 #05.
*++2017.05.10
  RANGES lr_bschl FOR bseg-bschl.
  DATA   l_olwste TYPE /zak/lwste.
  DATA   l_amount_external LIKE  bapicurr-bapicurr.
*--2017.05.10
*++1765 2017.11.07
  DATA   l_onybf TYPE /zak/onybf.
*++S4HANA#01.
  TYPES: BEGIN OF ts_/zak/bevallb_new,
           onybf  LIKE l_onybf,
           btype  TYPE /zak/bevallb-btype,
           abevaz TYPE /zak/bevallb-abevaz,
         END OF ts_/zak/bevallb_new.
  DATA: lt_/zak/bevallb_new TYPE HASHED TABLE OF ts_/zak/bevallb_new
      WITH UNIQUE KEY btype abevaz.
*--S4HANA#01.
*--1765 2017.11.07
*++1665 #08.
*++S4HANA#01.
*  REFRESH t_return.
  CLEAR t_return[].
*--S4HANA#01.
*--1665 #08.
*++1365 #10.
* Telefon ÁFA
  SELECT * INTO TABLE li_tel_afa                        "#EC CI_NOWHERE
           FROM /zak/tel_afa.
* Egyéb művelet kulcsok
  SELECT * INTO TABLE li_afa_ktosl                      "#EC CI_NOWHERE
           FROM /zak/afa_ktosl.
*--1365 #10.
*++1465 #04.
*++S4HANA#01.
*  SELECT * INTO TABLE li_/zak/afa_cust                   "#EC CI_NOWHERE
*           FROM /zak/afa_cust.
*  SORT li_/zak/afa_cust BY btype mwskz ktosl.
  SELECT * INTO TABLE lt_li_/zak/afa_cust
        FROM /zak/afa_cust.                              "#EC CI_NOWHERE
  SORT lt_li_/zak/afa_cust BY btype mwskz ktosl.
*--S4HANA#01.
*--1465 #04.
*++1465 #18.
  SELECT * INTO TABLE li_afa_lifknm                     "#EC CI_NOWHERE
           FROM /zak/afa_lifknm.
  SORT li_afa_lifknm BY lifkun.
*--1465 #18.
*++2265 #10.
  SELECT * INTO TABLE li_mwskz_ns
           FROM /zak/afa_mwskzns.
  SORT li_mwskz_ns.
*--2265 #10.
*++2017.05.10
** Követel könyvelési kódok feltöltése
*  M_DEF LR_BSCHL 'I' 'EQ' '21' SPACE.
*  M_DEF LR_BSCHL 'I' 'EQ' '22' SPACE.
*--2017.05.10
*++1465 #05.
* Analitika feldologzása rögzítés dátuma szerint:
*++S4HANA#01.
*  LOOP AT t_analitika INTO lw_analitika WHERE abevaz(5) NE 'DUMMY'.
  LOOP AT t_analitika INTO lw_analitika WHERE abevaz(5) NE 'DUMMY'.
    APPEND lw_analitika TO lt_lw_analitika_drv[].
  ENDLOOP.
  IF NOT lt_lw_analitika_drv[] IS INITIAL.
    SORT lt_lw_analitika_drv BY btype abevaz.
    DELETE ADJACENT DUPLICATES FROM lt_lw_analitika_drv
      COMPARING btype abevaz.
    SELECT onybf btype abevaz
      FROM /zak/bevallb
      INTO CORRESPONDING FIELDS OF TABLE lt_/zak/bevallb_new
      FOR ALL ENTRIES IN lt_lw_analitika_drv
      WHERE btype EQ lt_lw_analitika_drv-btype
      AND   abevaz EQ lt_lw_analitika_drv-abevaz.
  ENDIF.
  FREE lt_lw_analitika_drv[].
  LOOP AT t_analitika INTO lw_analitika WHERE abevaz(5) NE 'DUMMY'.
*--S4HANA#01.
    CLEAR lw_analitika_sort.
    lw_analitika_sort-bukrs = lw_analitika-bukrs.
    lw_analitika_sort-gjahr = lw_analitika-bseg_gjahr.
    lw_analitika_sort-belnr = lw_analitika-bseg_belnr.
    lw_analitika_sort-buzei = lw_analitika-bseg_buzei.
*++1765 2017.11.07
*   ONYB releváns ABEV azonosítókat nem kell feldolgozni.
*++S4HANA#01.
*    SELECT SINGLE onybf INTO l_onybf
*                        FROM /zak/bevallb
*                       WHERE btype  EQ lw_analitika-btype
*                         AND abevaz EQ lw_analitika-abevaz.
    ASSIGN lt_/zak/bevallb_new[
        btype = lw_analitika-btype
        abevaz = lw_analitika-abevaz
      ] TO FIELD-SYMBOL(<ls_/zak/bevallb_new>).
    IF sy-subrc = 0.
      l_onybf = <ls_/zak/bevallb_new>-onybf.
    ENDIF.
*--S4HANA#01.
    IF sy-subrc EQ 0 AND NOT l_onybf IS INITIAL.
      CONTINUE.
    ENDIF.
*--1765 2017.11.07
    COLLECT lw_analitika_sort INTO li_analitika_sort.
  ENDLOOP.
*++S4HANA#01.
  FREE lt_/zak/bevallb_new[].
*--S4HANA#01.
* Meghatározzuk a rögzítés időpontját:
*++S4HANA#01.
  IF NOT li_analitika_sort[] IS INITIAL.
    DATA(lt_lw_analitika_sort_drv) = li_analitika_sort[].
    SORT lt_lw_analitika_sort_drv BY bukrs belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_lw_analitika_sort_drv
      COMPARING bukrs belnr gjahr.
    SELECT cpudt cputm bukrs belnr gjahr
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_new
      FOR ALL ENTRIES IN lt_lw_analitika_sort_drv
      WHERE bukrs EQ lt_lw_analitika_sort_drv-bukrs
      AND   belnr EQ lt_lw_analitika_sort_drv-belnr
      AND   gjahr EQ lt_lw_analitika_sort_drv-gjahr.
    FREE lt_lw_analitika_sort_drv[].
  ENDIF.
*--S4HANA#01.
  LOOP AT li_analitika_sort INTO lw_analitika_sort.
*++S4HANA#01.
*    SELECT SINGLE cpudt cputm INTO (lw_analitika_sort-cpudt,
*                                    lw_analitika_sort-cputm)
*                              FROM bkpf
*                             WHERE bukrs EQ lw_analitika_sort-bukrs
*                               AND belnr EQ lw_analitika_sort-belnr
*                               AND gjahr EQ lw_analitika_sort-gjahr.
    ASSIGN lt_bkpf_new[
        bukrs = lw_analitika_sort-bukrs
        belnr = lw_analitika_sort-belnr
        gjahr = lw_analitika_sort-gjahr
       ] TO FIELD-SYMBOL(<ls_bkpf_new>).
*--S4HANA#01.
    IF sy-subrc EQ 0.
*++S4HANA#01.
*      MODIFY li_analitika_sort FROM lw_analitika_sort TRANSPORTING cpudt cputm.
      lw_analitika_sort-cpudt = <ls_bkpf_new>-cpudt.
      lw_analitika_sort-cputm = <ls_bkpf_new>-cputm.
      MODIFY li_analitika_sort FROM lw_analitika_sort TRANSPORTING cpudt cputm.
*--S4HANA#01.
    ENDIF.
  ENDLOOP.
*++S4HANA#01.
  FREE lt_bkpf_new[].
*--S4HANA#01.
  SORT li_analitika_sort BY cpudt cputm.
*--1465 #05.

*++1365 #11.
*  LOOP AT T_ANALITIKA INTO LW_ANALITIKA.
*++1465 #05.
*++1765 2017.09.19
*++1765 2017.11.30
*  DESCRIBE TABLE T_ANALITIKA LINES LW_SEL_PRLOG-SUMREC.
  DESCRIBE TABLE li_analitika_sort LINES lw_sel_prlog-sumrec.
*--1765 2017.11.30
  MOVE i_start-bukrs TO lw_sel_prlog-bukrs.
  MOVE syst-cprog TO lw_sel_prlog-obj_name.
  DELETE FROM /zak/sel_prlog WHERE bukrs EQ i_start-bukrs
                               AND obj_name EQ  lw_sel_prlog-obj_name.
  IF i_start-zcommit IS INITIAL.
    c_prlog_items = lw_sel_prlog-sumrec.
  ELSE.
    c_prlog_items = i_start-zcommit.
  ENDIF.
*++1765 2017.11.07
  SORT t_analitika BY bukrs bseg_gjahr bseg_belnr bseg_buzei.
*--1765 2017.11.07
*--1765 2017.09.19
  LOOP AT li_analitika_sort INTO lw_analitika_sort.
*++1865 #15.
*++S4HANA#01.
*    REFRESH lt_return.
    CLEAR lt_return[].
*--S4HANA#01.
*--1865 #15.
*++2165 #01.
    CLEAR v_inf_count.
*--2165 #01.
*++1865 #13.
* M01 lap érvényességének meghatározása:
    IF l_m01valid IS INITIAL.
      SELECT SINGLE m01valid INTO l_m01valid
                      FROM /zak/start
                     WHERE bukrs EQ lw_analitika_sort-bukrs.
    ENDIF.
*--1865 #13.

*  LOOP AT T_ANALITIKA INTO LW_ANALITIKA WHERE ABEVAZ(5) NE 'DUMMY'.
*++1765 2017.11.07
*    LOOP AT T_ANALITIKA INTO LW_ANALITIKA WHERE BUKRS      EQ LW_ANALITIKA_SORT-BUKRS
*                                            AND BSEG_GJAHR EQ LW_ANALITIKA_SORT-GJAHR
*                                            AND BSEG_BELNR EQ LW_ANALITIKA_SORT-BELNR
*                                            AND BSEG_BUZEI EQ LW_ANALITIKA_SORT-BUZEI.
    READ TABLE t_analitika INTO lw_analitika
                       WITH KEY bukrs      =  lw_analitika_sort-bukrs
                                bseg_gjahr =  lw_analitika_sort-gjahr
                                bseg_belnr =  lw_analitika_sort-belnr
                                bseg_buzei =  lw_analitika_sort-buzei
                                BINARY SEARCH.
    IF sy-subrc EQ 0.
*--1765 2017.11.07
*--1465 #05.
*++1765 2017.09.19
      ADD 1 TO  l_prlog_items.
*--1765 2017.09.19
*++1665 #07.
*     Ha magánszemély CPD szállító vagy vevő nem kell feldolgozni:
      IF lw_analitika-stcd1 IS INITIAL AND NOT lw_analitika-stcd2 IS INITIAL.
        CONTINUE.
      ENDIF.
*--1665 #07.
*--1365 #11.
*   Feldolgozás ellenőrzése
      READ TABLE li_proc_belnr TRANSPORTING NO FIELDS
                 WITH KEY bukrs = lw_analitika-bukrs
*++1365 #5.
*                       BELNR = LW_ANALITIKA-BSEG_BELNR
                          gjahr = lw_analitika-bseg_gjahr
                          belnr = lw_analitika-bseg_belnr
*++1665 #13.
*                         BUZEI = LW_ANALITIKA-BSEG_BUZEI
*--1665 #13.
*--1365 #5.
                          BINARY SEARCH.
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.
*++1665 #13.
*++2065 #12.
*      REFRESH LI_BSET.
*++S4HANA#01.
*      REFRESH: li_bset, li_h_bset.
      CLEAR li_bset[].
      CLEAR li_h_bset[].
*--S4HANA#01.
*--2065 #12.
      CLEAR: l_lwbas, l_fwbas, l_lwste, l_fwste,
             l_hwbtr, l_fwbtr.
      SELECT * INTO TABLE li_bset
               FROM bset
              WHERE bukrs EQ lw_analitika-bukrs
                AND belnr EQ lw_analitika-bseg_belnr
                AND gjahr EQ lw_analitika-bseg_gjahr
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
*--S4HANA#01.
*++2065 #12.
*  Halasztott ÁFA kezeléshez b izonylatok beolvasása
      IF NOT lw_analitika-h_belnr IS INITIAL.
        SELECT * INTO TABLE li_h_bset
                 FROM bset
                WHERE bukrs EQ lw_analitika-bukrs
                  AND belnr EQ lw_analitika-h_belnr
                  AND gjahr EQ lw_analitika-h_gjahr.
      ENDIF.
*--2065 #12.
**++1765 #11.
*++S4HANA#01.
*      REFRESH li_stazf.
      REFRESH lt_li_stazf.
*--S4HANA#01.
*     Adó nem vonható le összesítés
      LOOP AT li_bset INTO lw_bset.
*++S4HANA#01.
*        CLEAR li_stazf.
*        MOVE lw_bset-mwskz TO li_stazf-mwskz.
*        MOVE lw_bset-ktosl TO li_stazf-ktosl.
*        SELECT SINGLE stazf INTO li_stazf-stazf
        CLEAR ls_li_stazf.
        MOVE lw_bset-mwskz TO ls_li_stazf-mwskz.
        MOVE lw_bset-ktosl TO ls_li_stazf-ktosl.
        SELECT SINGLE stazf INTO ls_li_stazf-stazf
*--S4HANA#01.
                            FROM t007b
                           WHERE ktosl EQ lw_bset-ktosl.
*++S4HANA#01.
*        COLLECT li_stazf.
        COLLECT ls_li_stazf INTO lt_li_stazf.
*--S4HANA#01.
      ENDLOOP.
**--1765 #11.
*++2065 #12.
      IF NOT li_h_bset[] IS INITIAL.
        ASSIGN li_h_bset TO <bset>.
      ELSE.
        ASSIGN li_bset TO <bset>.
      ENDIF.
*      LOOP AT LI_BSET INTO LW_BSET.
      LOOP AT <bset> INTO lw_bset.
*--2065 #12.
*  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t.
        IF lw_bset-lwbas IS INITIAL.
          MOVE lw_bset-hwbas TO lw_bset-lwbas.
        ENDIF.
        IF lw_bset-lwste IS INITIAL.
          MOVE lw_bset-hwste TO lw_bset-lwste.
        ENDIF.
**++1765 #11.
*       Adó nem vonható le ellenőrzés
*++S4HANA#01.
*        READ TABLE li_stazf WITH KEY mwskz = lw_bset-mwskz
        READ TABLE lt_li_stazf INTO ls_li_stazf WITH KEY mwskz = lw_bset-mwskz
*--S4HANA#01.
                                     ktosl = lw_bset-ktosl
                                     stazf = 'X'.
        IF sy-subrc EQ 0.
*         Keresünk olyan rekordot ahol a adó nem vonható le üres ua. az adókódnál
*++S4HANA#01.
*          READ TABLE li_stazf WITH KEY mwskz = lw_bset-mwskz
          READ TABLE lt_li_stazf INTO ls_li_stazf WITH KEY mwskz = lw_bset-mwskz
*--S4HANA#01.
                                       stazf = ''.
*         Van ilyen üríteni kell a xBAS mezők értékét
          IF sy-subrc EQ 0.
            CLEAR: lw_bset-lwbas, lw_bset-fwbas.
          ENDIF.
        ENDIF.
**--1765 #11.
*       Előjel forgatás
*++S4HANA#01.
*        PERFORM change_sign(/zak/afa_sap_seln) USING lw_bset
        PERFORM change_sign IN PROGRAM /zak/afa_sap_seln USING lw_bset
*--S4HANA#01.
                                                    lw_analitika_bset.
        ADD lw_analitika_bset-lwbas TO l_lwbas.
        ADD lw_analitika_bset-fwbas TO l_fwbas.
        ADD lw_analitika_bset-lwste TO l_lwste.
        ADD lw_analitika_bset-fwste TO l_fwste.
        ADD lw_analitika_bset-hwbtr TO l_hwbtr.
        ADD lw_analitika_bset-fwbtr TO l_fwbtr.
      ENDLOOP.
      MOVE l_lwbas TO lw_analitika-lwbas.
      MOVE l_fwbas TO lw_analitika-fwbas.
      MOVE l_lwste TO lw_analitika-lwste.
      MOVE l_fwste TO lw_analitika-fwste.
      MOVE l_hwbtr TO lw_analitika-hwbtr.
      MOVE l_fwbtr TO lw_analitika-fwbtr.
*--1665 #13.
*   Meghatározzuk a BTYPE-ot:
      CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
        EXPORTING
          i_bukrs     = lw_analitika-bukrs
          i_btypart   = c_btypart_afa
          i_gjahr     = lw_analitika-gjahr
          i_monat     = lw_analitika-monat
        IMPORTING
          e_btype     = l_btype
        EXCEPTIONS
          error_monat = 1
          error_btype = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
*++2165 #06.
*        MESSAGE E208(/ZAK/ZAK) WITH C_BTYPART_AFA LW_ANALITIKA-GJAHR
*                               LW_ANALITIKA-MONAT.
*   Bevallás típus nem hatrározható meg!(Fajta: &, Év: &, Hónap: &)
        PERFORM add_message TABLES t_return
                            USING  '/ZAK/ZAK'
                                   'E'
                                   '208'
                                   c_btypart_afa
                                   lw_analitika-gjahr
                                   lw_analitika-monat
                                   ''.
*--2165 #06.
      ENDIF.
*++1365 #12.
*++1765 #16.
      CONCATENATE lw_analitika-gjahr lw_analitika-monat '01' INTO l_datum.
*--1765 #16.
*   Típus alapján összesítő jelentés flag figyelése
*++S4HANA#01.
*      SELECT SINGLE * INTO w_/zak/bevall
*                      FROM /zak/bevall
*                     WHERE bukrs EQ lw_analitika-bukrs
      SELECT * INTO w_/zak/bevall
                  FROM /zak/bevall UP TO 1 ROWS
                  WHERE bukrs EQ lw_analitika-bukrs
*--S4HANA#01.
                     AND btype EQ l_btype
*++1765 #16.
                     AND datab LE l_datum
                     AND datbi GE l_datum
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.
*--1765 #16.
      IF w_/zak/bevall-omrel IS INITIAL.
        CONTINUE.
      ENDIF.
*--1365 #12.
*++2017.05.10
*   Összeg konvertálása
      l_amount_external = w_/zak/bevall-olwste.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          currency             = c_huf
          amount_external      = l_amount_external
          max_number_of_digits = 20
        IMPORTING
          amount_internal      = l_olwste
*         RETURN               =
        .
*--2017.05.10
*   Fordított művletkulcs ellenőrzés
*++1865 #13.
*      REFRESH LR_FMUV.
*++S4HANA#01.
*      REFRESH: lr_fmuv, lr_fmuv_m01.
      CLEAR: lr_fmuv[].
      CLEAR: lr_fmuv_m01[].
*--S4HANA#01.
*--1865 #13.
*++S4HANA#01.
*      READ TABLE li_fmuv INTO lw_fmuv
*                        WITH KEY btype = l_btype.
      READ TABLE lt_li_fmuv INTO lw_fmuv
                  WITH KEY btype = l_btype.
*--S4HANA#01.
      IF sy-subrc NE 0.
        SELECT ktosl INTO lr_fmuv-low
                     FROM /zak/afa_fmuv
                    WHERE btype EQ l_btype
*++1865 #13.
                      AND m01rel EQ ''.
*--1865 #13.
          m_def lr_fmuv 'I' 'EQ' lr_fmuv-low space.
        ENDSELECT.
        CLEAR lw_fmuv.
        lw_fmuv-btype = l_btype.
        lw_fmuv-rc3[] = lr_fmuv[].
*++1865 #13.
        SELECT ktosl INTO lr_fmuv_m01-low
                     FROM /zak/afa_fmuv
                    WHERE btype EQ l_btype
                      AND m01rel EQ 'X'.
          m_def lr_fmuv_m01 'I' 'EQ' lr_fmuv_m01-low space.
        ENDSELECT.
        lw_fmuv-rc3m01[] = lr_fmuv_m01[].
*--1865 #13.
*++S4HANA#01.
*        APPEND lw_fmuv TO li_fmuv.
        APPEND lw_fmuv TO lt_li_fmuv.
*--S4HANA#01.
      ELSE.
        lr_fmuv[] = lw_fmuv-rc3[].
*++1865 #13.
        lr_fmuv_m01[] = lw_fmuv-rc3m01[].
*--1865 #13.
      ENDIF.
*   Fordított ÁFA ellenőrzés
*++1865 #13.
*        IF NOT LR_FMUV IS INITIAL AND LW_ANALITIKA-KTOSL IN LR_FMUV.
      IF NOT lr_fmuv[] IS INITIAL AND lw_analitika-ktosl IN lr_fmuv.
*--1865 #13.
        CONTINUE.
      ENDIF.
*++1365 #19.
*++1865 #13.
*   M01 lap kitöltésének vizsgálata
      IF NOT lr_fmuv_m01[] IS INITIAL AND NOT l_m01valid IS INITIAL AND lw_analitika_sort-cpudt > l_m01valid AND
         lw_analitika-ktosl IN lr_fmuv_m01.
        CONTINUE.
      ENDIF.
*--1865 #13.

*   Nem releváns ÁFA kódok ellenőrzése
*++S4HANA#01.
*      REFRESH lr_mwskz_nm.
*      READ TABLE li_mwskz_nm INTO lw_mwskz_nm
      CLEAR lr_mwskz_nm[].
      READ TABLE lt_li_mwskz_nm INTO lw_mwskz_nm
*--S4HANA#01.
                      WITH KEY btype = l_btype.
      IF sy-subrc NE 0.
        SELECT mwskz INTO lr_mwskz_nm-low
                     FROM /zak/afa_mwskznm
                    WHERE btype EQ l_btype.
          m_def lr_mwskz_nm 'I' 'EQ' lr_mwskz_nm-low space.
        ENDSELECT.
        CLEAR lw_mwskz_nm.
        lw_mwskz_nm-btype = l_btype.
        lw_mwskz_nm-rc2[] = lr_mwskz_nm[].
*++S4HANA#01.
*        APPEND lw_mwskz_nm TO li_mwskz_nm.
        APPEND lw_mwskz_nm TO lt_li_mwskz_nm.
*--S4HANA#01.
      ELSE.
        lr_mwskz_nm[] = lw_mwskz_nm-rc2[].
      ENDIF.
*    ÁFA kód ellenőrzés
*++2165 #04.
*      IF NOT LR_MWSKZ_NM IS INITIAL AND LW_ANALITIKA-MWSKZ IN LR_MWSKZ_NM.
      IF NOT lr_mwskz_nm[] IS INITIAL AND lw_analitika-mwskz IN lr_mwskz_nm.
*--2165 #04.
        CONTINUE.
      ENDIF.
*--1365 #19.
*++1665 #14.
*   Nem releváns bizonylatfajták ellenőrzése
      READ TABLE li_blart_nm TRANSPORTING NO FIELDS
                        WITH KEY blart = lw_analitika-blart.
      IF sy-subrc NE 0.
        SELECT * APPENDING TABLE li_blart_nm
                     FROM /zak/afa_blartnm
                    WHERE blart EQ lw_analitika-blart.
      ENDIF.
*    bizonylatfajta ellenőrzés
      IF sy-subrc EQ 0.
        CONTINUE.
      ENDIF.
*--1665 #14.
*++1465 #18.
*   Nem releváns szállító vevő kódok kezelése
      IF NOT lw_analitika-lifkun IS INITIAL.
        READ TABLE li_afa_lifknm TRANSPORTING NO FIELDS
                   WITH KEY lifkun = lw_analitika-lifkun
                   BINARY SEARCH.
        IF sy-subrc EQ 0.
          CONTINUE.
        ENDIF.
      ENDIF.
*--1465 #18.
*++1465 #04.
*   Előjel kezelés
*++S4HANA#01.
*      READ TABLE li_/zak/afa_cust WITH KEY btype = l_btype
*                                          mwskz = lw_analitika-mwskz
      READ TABLE lt_li_/zak/afa_cust INTO ls_li_/zak/afa_cust WITH KEY btype = l_btype
                 mwskz = lw_analitika-mwskz
*--S4HANA#01.
                                        ktosl = lw_analitika-ktosl
                                        BINARY SEARCH.
      IF sy-subrc NE 0.
*++S4HANA#01.
*        READ TABLE li_/zak/afa_cust WITH KEY btype = l_btype
*                                           mwskz = lw_analitika-mwskz
*                                           BINARY SEARCH.
        READ TABLE lt_li_/zak/afa_cust INTO ls_li_/zak/afa_cust WITH KEY
                   mwskz = lw_analitika-mwskz
                                   BINARY SEARCH.
*--S4HANA#01.
      ENDIF.
*++S4HANA#01.
*      PERFORM change_cust_sign USING li_/zak/afa_cust
      PERFORM change_cust_sign USING ls_li_/zak/afa_cust
*--S4HANA#01.
                                     lw_analitika.
*--1465 #04.
*++1765 #26.
*++S4HANA#01.
*      PERFORM change_cust_msign USING li_/zak/afa_cust
      PERFORM change_cust_msign USING ls_li_/zak/afa_cust
*--S4HANA#01.
                                      lw_analitika.
*--1765 #26.
*   Adatok feltöltése
      CLEAR lw_afa_szla.

*   Adószám meghatározás
*++1365 #9.
*    IF NOT LW_ANALITIKA-STCD3 IS INITIAL.
*      LW_ANALITIKA-ADOAZON = LW_ANALITIKA-STCD3(8).
*    ELSEIF NOT LW_ANALITIKA-STCD1 IS INITIAL.
*      LW_ANALITIKA-ADOAZON = LW_ANALITIKA-STCD1(8).
*    ENDIF.
      IF NOT lw_analitika-stcd1 IS INITIAL.
        lw_analitika-adoazon = lw_analitika-stcd1(8).
      ENDIF.
*--1365 #9.
*   Meghatározzuk a bizonylat típusát
      SELECT SINGLE awtyp awkey INTO (l_awtyp, l_awkey)
                                FROM bkpf
                               WHERE bukrs EQ lw_analitika-bukrs
                                 AND belnr EQ lw_analitika-bseg_belnr
                                 AND gjahr EQ lw_analitika-bseg_gjahr.
      CHECK sy-subrc EQ 0.

*   SD számla
      IF  l_awtyp(1) EQ 'V'.
        CALL FUNCTION '/ZAK/GET_SD_SZAMLASZ'
          EXPORTING
*           I_BUKRS     =
*           I_BELNR     =
*           I_GJAHR     =
            i_awkey     = l_awkey
          IMPORTING
            e_szamlasza = lw_afa_szla-szamlasza
            e_szamlasz  = lw_analitika-szamlasz
            e_szamlasze = lw_analitika-szamlasze
            e_szlatip   = lw_analitika-szlatip
            e_storno    = l_storno
*++1765 #05.
          TABLES
            t_return    = lt_return
*--1765 #05.
          EXCEPTIONS
            error_awkey = 1
            error_other = 2
            OTHERS      = 3.
*++1765 #05.
*++1765 #22.
*        IF NOT T_RETURN[] IS INITIAL.
        IF NOT lt_return[] IS INITIAL.
*--1765 #22.
          APPEND LINES OF lt_return TO t_return.
        ENDIF.
*--1765 #05.
*       Ha üres akkor korrekció
        IF lw_analitika-szlatip IS INITIAL.
          lw_analitika-szlatip = c_szlatip_k.
        ENDIF.
        lw_analitika-nylapazon = c_nylapazon_m01.
*     Számla kelt:
        l_vbeln = l_awkey.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = l_vbeln
          IMPORTING
            output = l_vbeln.
*       Számlázás: fejadatok szelekció
        SELECT SINGLE fkdat INTO lw_analitika-szamlakelt
                            FROM vbrk
                           WHERE vbeln EQ l_vbeln.
*     Sztornó kezelése
*     Nem kell a hónabon beüli sztornó tétel
        IF i_start-ostorno IS INITIAL AND NOT l_storno IS INITIAL.
*       Előzmény bizonylat dátuma
          SELECT SINGLE fkdat INTO l_fkdat_e
                              FROM vbrk
                             WHERE vbeln EQ lw_analitika-szamlasze.
          IF lw_analitika-szamlakelt(6) = l_fkdat_e(6).
            lw_afa_szla-noneed = 'X'.
*         Ebben az esetben az előzmény sem kell
            lm_set_noneed_szamlasze lw_afa_szla
                                    lw_analitika.
          ENDIF.
        ENDIF.
*++1765 2017.06.13
        CLEAR lw_szamla.
*++S4HANA#01.
*        REFRESH li_szamla.
        CLEAR li_szamla[].
*--S4HANA#01.
        lw_szamla-szamlasza = lw_afa_szla-szamlasza.
        lw_szamla-szamlasz  = lw_analitika-szamlasz.
        lw_szamla-szamlasze = lw_analitika-szamlasze.
        lw_szamla-szlatip   = lw_analitika-szlatip.
        lw_szamla-storno    = l_storno.
        APPEND lw_afa_szla  TO lw_szamla-afa_szla.
        APPEND lw_analitika TO lw_szamla-analitika.
        APPEND lw_szamla TO li_szamla.
*--1765 2017.06.13
*   MM számla
      ELSEIF l_awtyp(2) EQ 'RM'.
*++1765 2017.06.13
        CLEAR lw_szamla.
*++S4HANA#01.
*        REFRESH li_szamla.
        CLEAR li_szamla[].
*--S4HANA#01.
*--1765 2017.06.13
        CALL FUNCTION '/ZAK/GET_MM_SZAMLASZ'
          EXPORTING
*           I_BUKRS     =
*           I_BELNR     =
*           I_GJAHR     =
            i_awkey     = l_awkey
*++1765 2017.06.13
*          IMPORTING
*           E_SZAMLASZA = LW_AFA_SZLA-SZAMLASZA
*           E_SZAMLASZ  = LW_ANALITIKA-SZAMLASZ
*           E_SZAMLASZE = LW_ANALITIKA-SZAMLASZE
*           E_SZLATIP   = LW_ANALITIKA-SZLATIP
*           E_STORNO    = L_STORNO
*--1765 2017.06.13
*++1765 #05.
          TABLES
*++1765 #22.
*           T_RETURN    = T_RETURN
            t_return    = lt_return
*--1765 #22.
*--1765 #05.
*++1765 2017.06.13
            t_szamla    = li_szamla
*--1765 2017.06.13
          EXCEPTIONS
            error_awkey = 1
            error_other = 2
            OTHERS      = 3.
*++1765 #05.
*++1765 #22.
*        IF NOT T_RETURN[] IS INITIAL.
        IF NOT lt_return[] IS INITIAL.
*--1765 #22.
          APPEND LINES OF lt_return TO t_return.
        ENDIF.
*--1765 #05.

*++1765 2017.06.13
**     Ha üres akkor korrekció
*        IF LW_ANALITIKA-SZLATIP IS INITIAL.
*          LW_ANALITIKA-SZLATIP = C_SZLATIP_K.
*        ENDIF.
*        LW_ANALITIKA-NYLAPAZON = C_NYLAPAZON_M02.
**     Számla kelt:
*        LS_AWKDEC = L_AWKEY.
*        SELECT SINGLE BLDAT INTO LW_ANALITIKA-SZAMLAKELT
*                            FROM RBKP
*                           WHERE BELNR EQ LS_AWKDEC-BELNR
*                             AND GJAHR EQ LS_AWKDEC-GJAHR.
**     Sztornó kezelése
**     Nem kell a hónabon beüli sztornó tétel
*        IF I_START-OSTORNO IS INITIAL AND NOT L_STORNO IS INITIAL
**++1365 #6.
*           AND NOT LW_ANALITIKA-SZAMLASZE IS INITIAL.
*
**++1465 #07.
**          LS_AWKDEC = LW_ANALITIKA-SZAMLASZE.
**--1465 #07.
*
**        Előzmény bizonylat dátuma
**        SELECT SINGLE FKDAT INTO L_FKDAT_E
**                            FROM VBRK
**                           WHERE VBELN EQ LW_ANALITIKA-SZAMLASZE.
**++1465 #07.
**          SELECT SINGLE BLDAT INTO L_BLDAT_E
**                              FROM RBKP
**                             WHERE BELNR EQ LS_AWKDEC-BELNR
**                               AND GJAHR EQ LS_AWKDEC-GJAHR.
*          SELECT SINGLE BLDAT INTO L_BLDAT_E
*                              FROM RBKP
*                             WHERE XBLNR EQ LW_ANALITIKA-SZAMLASZE
*                               AND IVTYP NE '5'.
**--1465 #07.
**       IF LW_ANALITIKA-SZAMLAKELT(6) = L_FKDAT_E(6).
*          IF SY-SUBRC EQ 0 AND LW_ANALITIKA-SZAMLAKELT(6) = L_BLDAT_E(6).
**--1365 #6.
*            LW_AFA_SZLA-NONEED = 'X'.
**         Ebben az esetben az előzmény sem kell
*            LM_SET_NONEED_SZAMLASZE LW_AFA_SZLA
*                                    LW_ANALITIKA.
*          ENDIF.
*        ENDIF.
        LOOP AT li_szamla INTO lw_szamla.
          lw_afa_szla-szamlasza  = lw_szamla-szamlasza.
          lw_analitika-szamlasz  = lw_szamla-szamlasz.
          lw_analitika-szamlasze = lw_szamla-szamlasze.
          lw_analitika-szlatip   = lw_szamla-szlatip.
          lw_afa_szla_s  = lw_afa_szla.
          lw_analitika_s = lw_analitika.
          l_storno       = lw_szamla-storno.
*     Ha üres akkor korrekció
          IF lw_analitika_s-szlatip IS INITIAL.
            lw_analitika_s-szlatip = c_szlatip_k.
          ENDIF.
          lw_analitika_s-nylapazon = c_nylapazon_m02.
*     Számla kelt:
          ls_awkdec = l_awkey.
          SELECT SINGLE bldat INTO lw_analitika_s-szamlakelt
                              FROM rbkp
                             WHERE belnr EQ ls_awkdec-belnr
                               AND gjahr EQ ls_awkdec-gjahr.
*     Sztornó kezelése
*     Nem kell a hónabon beüli sztornó tétel
          IF i_start-ostorno IS INITIAL AND NOT l_storno IS INITIAL
             AND NOT lw_analitika_s-szamlasze IS INITIAL.
*++S4HANA#01.
*            SELECT SINGLE bldat INTO l_bldat_e
*                                FROM rbkp
*                               WHERE xblnr EQ lw_analitika_s-szamlasze
*                                 AND ivtyp NE '5'.
            SELECT bldat INTO l_bldat_e
                   FROM rbkp UP TO 1 ROWS
                   WHERE xblnr EQ lw_analitika_s-szamlasze
                     AND ivtyp NE '5'
                  ORDER BY PRIMARY KEY.
            ENDSELECT.
*--S4HANA#01.
            IF sy-subrc EQ 0 AND lw_analitika_s-szamlakelt(6) = l_bldat_e(6).
              lw_afa_szla_s-noneed = 'X'.
*         Ebben az esetben az előzmény sem kell
              lm_set_noneed_szamlasze lw_afa_szla_s
                                      lw_analitika_s.
            ENDIF.
          ENDIF.
          APPEND lw_afa_szla_s  TO lw_szamla-afa_szla.
          APPEND lw_analitika_s TO lw_szamla-analitika.
          MODIFY li_szamla FROM lw_szamla.
        ENDLOOP.
*--1765 2017.06.13

*   FI számla
*++1365 #9.
*    ELSEIF L_AWTYP EQ 'BKPF'.
      ELSEIF l_awtyp(4) EQ 'BKPF'.
*--1365 #9.
*++1365 #20.
*     Halasztott ÁFA kezelése
        IF NOT lw_analitika-zmwskf IS INITIAL.
          lw_afa_szla-szamlasza = lw_analitika-xblnr.
          lw_analitika-szamlasz = lw_analitika-xblnr.
          lw_analitika-szlatip  = c_szlatip_e.
        ELSE.
*--1365 #20.
          CALL FUNCTION '/ZAK/GET_FI_SZAMLASZ'
            EXPORTING
*             I_BUKRS     =
*             I_BELNR     =
*             I_GJAHR     =
              i_awkey     = l_awkey
            IMPORTING
              e_szamlasza = lw_afa_szla-szamlasza
              e_szamlasz  = lw_analitika-szamlasz
              e_szamlasze = lw_analitika-szamlasze
              e_szlatip   = lw_analitika-szlatip
              e_storno    = l_storno
*++1665 #06.
              e_noneed    = lw_analitika-noneed
*--1665 #06.
*++1765 #05.
            TABLES
              t_return    = lt_return
            EXCEPTIONS
              error_awkey = 1
              error_other = 2
              OTHERS      = 3.

          IF NOT lt_return[] IS INITIAL.
            APPEND LINES OF lt_return TO t_return.
          ENDIF.
*--1765 #05.
*++2017.05.10
*          IF LW_ANALITIKA-BSCHL IN LR_BSCHL AND ABS( LW_AFA_SZLA-LWSTE ) >= ABS( L_OLWSTE ).
*            LW_AFA_SZLA-SZAMLASZA = LW_ANALITIKA-SZAMLASZ.
*            CLEAR LW_ANALITIKA-SZAMLASZE.
*            LW_ANALITIKA-SZLATIP = C_SZLATIP_K.
*          ENDIF.
*--2017.05.10
*++1365 #20
        ENDIF.
*--1365 #20.
*     Ha üres akkor korrekció
        IF lw_analitika-szlatip IS INITIAL.
          lw_analitika-szlatip = c_szlatip_k.
        ENDIF.
*     Számlakelt
*++S4HANA#01.
*        SELECT SINGLE bldat INTO lw_analitika-szamlakelt
*                            FROM bkpf
*                           WHERE bukrs EQ lw_analitika-bukrs
*                             AND belnr EQ lw_analitika-bseg_belnr
*                             AND gjahr EQ lw_analitika-bseg_gjahr.
        cl_fagl_emu_cvrt_services=>get_leading_ledger(
          IMPORTING
             ed_rldnr = DATA(lv_rldnr)
          EXCEPTIONS
            error  = 4
          OTHERS = 4 ).
        IF sy-subrc = 0.
          CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
            EXPORTING
              i_rldnr   = lv_rldnr
              i_bukrs   = lw_analitika-bukrs
              i_belnr   = lw_analitika-bseg_belnr
              i_gjahr   = lw_analitika-bseg_gjahr
            IMPORTING
              et_bseg   = lt_fagl_bseg_tmp
            EXCEPTIONS
              not_found = 4
              OTHERS    = 4.
          IF sy-subrc = 0.
            DATA(lt_fagl_bseg_filter) = VALUE fagl_t_bseg(
                FOR ls_pp IN lt_fagl_bseg_tmp
                WHERE ( ( koart = 'K' OR koart = 'D' ) )
                ( ls_pp ) ).
            IF lt_fagl_bseg_filter IS NOT INITIAL.
              SORT lt_fagl_bseg_filter BY buzei.
              lw_analitika-szamlakelt = lt_fagl_bseg_filter[ 1 ]-zfbdt.
            ENDIF.
            FREE: lt_fagl_bseg_tmp, lt_fagl_bseg_filter.
          ENDIF.
        ENDIF.
*--S4HANA#01.
*     Számla típus
        IF lw_analitika-koart EQ 'K'.
          lw_analitika-nylapazon = c_nylapazon_m02.
        ELSE.
          lw_analitika-nylapazon = c_nylapazon_m01.
        ENDIF.
*     Sztornó kezelése
*     Nem kell a hónabon beüli sztornó tétel
        IF i_start-ostorno IS INITIAL AND NOT l_storno IS INITIAL
           AND NOT lw_analitika-szamlasze IS INITIAL.
*        Előzmény bizonylat dátuma
*++S4HANA#01.
          CLEAR l_bldat_e.
          SELECT SINGLE bldat INTO l_bldat_e
                              FROM bkpf
                             WHERE bukrs    EQ lw_analitika-bukrs
                               AND xblnr    EQ lw_analitika-szamlasze.
          IF sy-subrc EQ 0 AND lw_analitika-szamlakelt(6) = l_bldat_e(6).
            lw_afa_szla-noneed = 'X'.
*         Ebben az esetben az előzmény sem kell
            lm_set_noneed_szamlasze lw_afa_szla
                                    lw_analitika.
*          CLEAR lr_xblnr[].
*          CONCATENATE lw_analitika-szamlasze '*' INTO lr_xblnr-low.
*          m_def lr_xblnr 'I' 'CP' lr_xblnr-low space.
*          SELECT * INTO CORRESPONDING FIELDS OF lw_proc_belnr
*                          FROM bkpf UP TO 1 ROWS
*                          WHERE bukrs EQ lw_analitika-bukrs
*                            AND xblnr IN lr_xblnr
*                         ORDER BY PRIMARY KEY.
*          ENDSELECT.
*          CLEAR l_zfbdt_e.
*          cl_fagl_emu_cvrt_services=>get_leading_ledger(
*            IMPORTING
*              ed_rldnr = lv_rldnr
*            EXCEPTIONS
*              error  = 4
*              OTHERS = 4 ).
*          IF sy-subrc = 0.
*            CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
*              EXPORTING
*                i_rldnr   = lv_rldnr
*                i_bukrs   = lw_proc_belnr-bukrs
*                i_belnr   = lw_proc_belnr-belnr
*                i_gjahr   = lw_proc_belnr-gjahr
*              IMPORTING
*                et_bseg   = lt_fagl_bseg_tmp
*              EXCEPTIONS
*                not_found = 4
*                OTHERS    = 4.
*            IF sy-subrc = 0.
*              lt_fagl_bseg_filter = VALUE fagl_t_bseg(
*                  FOR ls_pp IN lt_fagl_bseg_tmp
*                  WHERE ( ( koart = 'K' OR koart = 'D' ) )
*                  ( ls_pp ) ).
*              IF lt_fagl_bseg_filter IS NOT INITIAL.
*                SORT lt_fagl_bseg_filter BY buzei.
*                l_zfbdt_e = lt_fagl_bseg_filter[ 1 ]-zfbdt.
*              ENDIF.
*              FREE: lt_fagl_bseg_tmp, lt_fagl_bseg_filter.
*            ENDIF.
*          ENDIF.
*          IF lw_analitika-szamlakelt(6) = l_zfbdt_e(6).
*            lw_afa_szla-noneed = 'X'.
**         Ebben az esetben az előzmény sem kell
*            lm_set_noneed_szamlasze lw_afa_szla
*                                    lw_analitika.
*--S4HANA#01.
          ENDIF.
        ENDIF.
*++1765 2017.06.13
        CLEAR lw_szamla.
*++S4HANA#01.
*        REFRESH li_szamla.
        CLEAR li_szamla[].
*--S4HANA#01.
        lw_szamla-szamlasza = lw_afa_szla-szamlasza.
        lw_szamla-szamlasz  = lw_analitika-szamlasz.
        lw_szamla-szamlasze = lw_analitika-szamlasze.
        lw_szamla-szlatip   = lw_analitika-szlatip.
        lw_szamla-storno    = l_storno.
        APPEND lw_afa_szla  TO lw_szamla-afa_szla.
        APPEND lw_analitika TO lw_szamla-analitika.
        APPEND lw_szamla TO li_szamla.
*--1765 2017.06.13
*   Egyéb
      ELSE.
        CONTINUE.
      ENDIF.
*++1765 2017.06.13
      LOOP AT li_szamla INTO lw_szamla.
        READ TABLE lw_szamla-afa_szla  INTO lw_afa_szla  INDEX 1.
        READ TABLE lw_szamla-analitika INTO lw_analitika INDEX 1.
*--1765 2017.06.13
*   Ha nem sikerül meghatározni a számla azonosítót
        IF lw_afa_szla-szamlasza IS INITIAL.
*++1665 #08.
**++1365 #4.
**      MESSAGE e356(/zak/zak) WITH lw_analitika-bukrs
*        MESSAGE I356(/ZAK/ZAK) WITH LW_ANALITIKA-BUKRS
**--1365 #4.
*                               LW_ANALITIKA-BSEG_BELNR
*                               LW_ANALITIKA-BSEG_GJAHR.
**   Nem lehet közös számla azonosítót meghatározni! (&/&/&)
*++1365 #4.
          PERFORM add_message TABLES t_return
                              USING  '/ZAK/ZAK'
                                     'I'
                                     '356'
                                     lw_analitika-bukrs
                                     lw_analitika-bseg_belnr
                                     lw_analitika-bseg_gjahr
                                     ''.
*--1665 #08.
*++1365 #23.
*     Ha nincs közös számlaazonosító, akkor E-s tételként kezeljük
          IF NOT lw_analitika-szamlasz IS INITIAL.
            lw_afa_szla-szamlasza = lw_analitika-szamlasz.
            lw_analitika-szlatip  = c_szlatip_e.
          ELSE.
            CONTINUE.
          ENDIF.
*--1365 #23.
*--1365 #4.
        ENDIF.
*++1365 #10.
*   Telefon ÁFA kódnál szükséges a bizonylatokból a beállító tábla
*   szerinti másik adókód összege is!
        READ TABLE li_tel_afa INTO lw_tel_afa
             WITH KEY btype = l_btype
                      mwskz = lw_analitika-mwskz.
        IF sy-subrc EQ 0 AND NOT lw_tel_afa-mwskz_t IS INITIAL.
*   Összeállítjuk a szükséges ÁFA kódokat!
*++S4HANA#01.
*          REFRESH: lr_mwskz, li_bset.
          CLEAR: lr_mwskz[].
          CLEAR: li_bset[].
*--S4HANA#01.
          CLEAR lw_analitika_bset.
          m_def lr_mwskz 'E' 'EQ' lw_tel_afa-mwskz   space.
          m_def lr_mwskz 'I' 'EQ' lw_tel_afa-mwskz_t space.
          SELECT * INTO TABLE li_bset
                   FROM bset
                  WHERE bukrs EQ lw_analitika-bukrs
                    AND belnr EQ lw_analitika-bseg_belnr
                    AND gjahr EQ lw_analitika-bseg_gjahr
                    AND mwskz IN lr_mwskz
*++S4HANA#01.
            ORDER BY PRIMARY KEY.
*--S4HANA#01.
*     Van rekord, összesíteni kell:
          IF sy-subrc EQ 0.
            LOOP AT li_bset INTO lw_bset.
*         Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t.
              IF lw_bset-lwbas IS INITIAL.
                MOVE lw_bset-hwbas TO lw_bset-lwbas.
              ENDIF.
              IF lw_bset-lwste IS INITIAL.
                MOVE lw_bset-hwste TO lw_bset-lwste.
              ENDIF.
*++2265 #10.
*             Ellenőrizzük, hogy kell e a tételt összesíteni
              READ TABLE li_mwskz_ns TRANSPORTING NO FIELDS WITH KEY mwskz = lw_bset-mwskz
                                                                     ktosl = lw_bset-ktosl.
              IF sy-subrc  NE 0.
*               Művelet kulcs nélkül is ellenőrizzük
                READ TABLE li_mwskz_ns TRANSPORTING NO FIELDS WITH KEY mwskz = lw_bset-mwskz.
                IF sy-subrc EQ 0.
                  CONTINUE.
                ENDIF.
              ELSE.
                CONTINUE.
              ENDIF.
*--2265 #10.
*         Feltöltjük egy üres munkaterületre, hogy tudjuk használni
*         az előjelkezelés rutint!
              lw_analitika_bset-lwbas = lw_bset-lwbas.
              lw_analitika_bset-lwste = lw_bset-lwste.
*++S4HANA#01.
*              PERFORM  change_sign(/zak/afa_sap_seln) USING lw_bset
              PERFORM  change_sign IN PROGRAM /zak/afa_sap_seln USING lw_bset
*--S4HANA#01.
                                                          lw_analitika_bset.
              ADD lw_analitika_bset-lwbas TO lw_analitika-lwbas.
              ADD lw_analitika_bset-lwste TO lw_analitika-lwste.
            ENDLOOP.
          ENDIF.
        ENDIF.

*   Egyéb művelet kulcsok kezelése
        READ TABLE li_afa_ktosl INTO lw_afa_ktosl
             WITH KEY btype = l_btype
                      mwskz = lw_analitika-mwskz
                      ktosl = lw_analitika-ktosl.
        IF sy-subrc EQ 0 AND NOT lw_afa_ktosl-ktosl_t IS INITIAL.
*++S4HANA#01.
*          REFRESH: li_bset.
          CLEAR: li_bset[].
*--S4HANA#01.
          CLEAR lw_analitika_bset.
          SELECT * INTO TABLE li_bset
                   FROM bset
                  WHERE bukrs EQ lw_analitika-bukrs
                    AND belnr EQ lw_analitika-bseg_belnr
                    AND gjahr EQ lw_analitika-bseg_gjahr
                    AND mwskz EQ lw_afa_ktosl-mwskz
                    AND ktosl EQ lw_afa_ktosl-ktosl_t
*++S4HANA#01.
            ORDER BY PRIMARY KEY.
*--S4HANA#01.
*     Van rekord, összesíteni kell:
          IF sy-subrc EQ 0.
            LOOP AT li_bset INTO lw_bset.
*         Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t.
              IF lw_bset-lwbas IS INITIAL.
                MOVE lw_bset-hwbas TO lw_bset-lwbas.
              ENDIF.
              IF lw_bset-lwste IS INITIAL.
                MOVE lw_bset-hwste TO lw_bset-lwste.
              ENDIF.
*++2265 #10.
*             Ellenőrizzük, hogy kell e a tételt összesíteni
              READ TABLE li_mwskz_ns TRANSPORTING NO FIELDS WITH KEY mwskz = lw_bset-mwskz
                                                                     ktosl = lw_bset-ktosl.
              IF sy-subrc  NE 0.
*               Művelet kulcs nélkül is ellenőrizzük
                READ TABLE li_mwskz_ns TRANSPORTING NO FIELDS WITH KEY mwskz = lw_bset-mwskz.
                IF sy-subrc EQ 0.
                  CONTINUE.
                ENDIF.
              ELSE.
                CONTINUE.
              ENDIF.
*--2265 #10.
*         Feltöltjük egy üres munkaterületre, hogy tudjuk használni
*         az előjelkezelés rutint!
              lw_analitika_bset-lwbas = lw_bset-lwbas.
              lw_analitika_bset-lwste = lw_bset-lwste.
*++S4HANA#01.
*              PERFORM  change_sign(/zak/afa_sap_seln)
              PERFORM  change_sign IN PROGRAM /zak/afa_sap_seln
*--S4HANA#01.
                       USING lw_bset
                             lw_analitika_bset.
              ADD lw_analitika_bset-lwbas TO lw_analitika-lwbas.
              ADD lw_analitika_bset-lwste TO lw_analitika-lwste.
            ENDLOOP.
          ENDIF.
        ENDIF.
*--1365 #10.
*++1365 #15.
        lw_analitika-szamlasza = lw_afa_szla-szamlasza.
*--1365 #15.
*   Számla rekord
*++2165 #08.
        lw_afa_szla_tmp = lw_afa_szla.
*--2165 #08.
        MOVE-CORRESPONDING lw_analitika TO lw_afa_szla.
*++2165 #08.
        IF NOT lw_afa_szla_tmp-noneed IS INITIAL.
          lw_afa_szla-noneed = lw_afa_szla_tmp-noneed.
        ENDIF.
        CLEAR lw_afa_szla_tmp.
*--2165 #08.
*   Ha a típus E és 2013.01.01 előtti, akkor nem kell a rekord
        IF lw_afa_szla-szamlakelt < c_omrel_datum.
          lw_afa_szla-noneed = 'X'.
*++1365 #11.
**   Meghatározzuk, hogy az eredeti tétel kellett e
*    ELSEIF LW_AFA_SZLA-NONEED IS INITIAL AND
*           LW_AFA_SZLA-SZLATIP NE C_SZLATIP_E.
*      READ TABLE T_AFA_SZLA INTO LW_AFA_SZLA_TMP
*           WITH KEY BUKRS     = LW_AFA_SZLA-BUKRS
*                    ADOAZON   = LW_AFA_SZLA-ADOAZON
*                    SZAMLASZA = LW_AFA_SZLA-SZAMLASZA
*                    SZLATIP   = C_SZLATIP_E.
*      IF SY-SUBRC EQ 0 AND NOT LW_AFA_SZLA_TMP-NONEED IS INITIAL.
*        LW_AFA_SZLA-NONEED = LW_AFA_SZLA_TMP-NONEED.
**     Keressük az adatbázisban is
*      ELSEIF SY-SUBRC NE 0.
*        SELECT SINGLE NONEED INTO LW_AFA_SZLA-NONEED
*                             FROM /ZAK/AFA_SZLA
*                            WHERE BUKRS     EQ LW_AFA_SZLA-BUKRS
*                              AND ADOAZON   EQ LW_AFA_SZLA-ADOAZON
*                              AND SZAMLASZA EQ LW_AFA_SZLA-SZAMLASZA
*                              AND SZLATIP   EQ C_SZLATIP_E.
**       Olyan korrekciós, aminek még nincs előzménye, ami nem kell
*        IF SY-SUBRC NE 0.
*          LW_AFA_SZLA-NONEED = 'X'.
*        ENDIF.
*      ENDIF.
*--1365 #11.
        ENDIF.
        APPEND lw_afa_szla TO  t_afa_szla.
*   Analitika tétel
        lw_analitika-abevaz = c_abevaz_dummy_r.
*++1665 #07.
*     Ha CPD-s akkor kell a NAME1 a FIELD_C-be
        SELECT SINGLE name1 INTO lw_analitika-field_c
                            FROM bsec
                           WHERE bukrs EQ lw_analitika-bukrs
                             AND belnr EQ lw_analitika-bseg_belnr
                             AND gjahr EQ lw_analitika-bseg_gjahr.
*--1665 #07.
        APPEND lw_analitika TO li_analitika_ins.
*   Bizonylatszám mentése
        CLEAR lw_proc_belnr.
        lw_proc_belnr-bukrs = lw_analitika-bukrs.
        lw_proc_belnr-belnr = lw_analitika-bseg_belnr.
        lw_proc_belnr-gjahr = lw_analitika-bseg_gjahr.
*++1365 #5.
        lw_proc_belnr-buzei = lw_analitika-bseg_buzei.
*--1365 #5.
        APPEND lw_proc_belnr TO li_proc_belnr.
        SORT li_proc_belnr.
*++1765 2017.06.13
      ENDLOOP.
*--1765 2017.06.13
*++1765 2017.09.19
      IF l_prlog_items > c_prlog_items.
        GET TIME.
        ADD l_prlog_items TO lw_sel_prlog-proces.
        MOVE lw_analitika-bseg_belnr TO lw_sel_prlog-belnr.
        MOVE lw_analitika-bseg_gjahr TO lw_sel_prlog-gjahr.
        MOVE sy-uname TO lw_sel_prlog-as4user.
        MOVE sy-datum TO lw_sel_prlog-as4date.
        MOVE sy-uzeit TO lw_sel_prlog-as4time.
        MODIFY /zak/sel_prlog FROM lw_sel_prlog.
        COMMIT WORK.
        CLEAR l_prlog_items.
      ENDIF.
*++1765 2017.11.07
**--1765 2017.09.19
*  ENDLOOP.
**++1465 #05.
    ENDIF.
*--1765 2017.11.07
  ENDLOOP.
*--1465 #05.
*++1765 2017.09.19
  IF NOT l_prlog_items IS INITIAL.
    GET TIME.
    ADD l_prlog_items TO lw_sel_prlog-proces.
    MOVE lw_analitika-bseg_belnr TO lw_sel_prlog-belnr.
    MOVE lw_analitika-bseg_gjahr TO lw_sel_prlog-gjahr.
    MOVE sy-uname TO lw_sel_prlog-as4user.
    MOVE sy-datum TO lw_sel_prlog-as4date.
    MOVE sy-uzeit TO lw_sel_prlog-as4time.
    MODIFY /zak/sel_prlog FROM lw_sel_prlog.
    COMMIT WORK.
    CLEAR l_prlog_items.
  ENDIF.
*--1765 2017.09.19
*++1365 #11.
* Meghatározzuk, hogy az eredeti tétel kellett e
  LOOP AT t_afa_szla INTO lw_afa_szla WHERE noneed IS INITIAL
                                        AND szlatip NE c_szlatip_e.
    READ TABLE t_afa_szla INTO lw_afa_szla_tmp
         WITH KEY bukrs     = lw_afa_szla-bukrs
                  adoazon   = lw_afa_szla-adoazon
                  szamlasza = lw_afa_szla-szamlasza
                  szlatip   = c_szlatip_e.
    IF sy-subrc EQ 0 AND NOT lw_afa_szla_tmp-noneed IS INITIAL.
      lw_afa_szla-noneed = lw_afa_szla_tmp-noneed.
*     Keressük az adatbázisban is
    ELSEIF sy-subrc NE 0.
*++S4HANA#01.
*      SELECT SINGLE noneed INTO lw_afa_szla-noneed
*                           FROM /zak/afa_szla
      SELECT noneed INTO lw_afa_szla-noneed
                     FROM /zak/afa_szla UP TO 1 ROWS
*--S4HANA#01.
                        WHERE bukrs     EQ lw_afa_szla-bukrs
                          AND adoazon   EQ lw_afa_szla-adoazon
                          AND szamlasza EQ lw_afa_szla-szamlasza
                          AND szlatip   EQ c_szlatip_e
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.s
*       Olyan korrekciós, aminek még nincs előzménye, ami nem kell
      IF sy-subrc NE 0.
        lw_afa_szla-noneed = 'X'.
      ENDIF.
    ENDIF.
    MODIFY t_afa_szla FROM lw_afa_szla TRANSPORTING noneed.
  ENDLOOP.
*--1365 #11.

  IF NOT li_analitika_ins[] IS INITIAL.
    APPEND LINES OF li_analitika_ins TO t_analitika.
  ENDIF.
*++1665 #08.
  SORT t_return.
  DELETE ADJACENT DUPLICATES FROM t_return.
*--1665 #08.
*++1965 #02.
*M01 lap érvényesség vizsgálata
  LOOP AT t_afa_szla INTO lw_afa_szla WHERE nylapazon EQ c_nylapazon_m01
                                        AND noneed EQ ''.
    l_datum(4)   = lw_afa_szla-gjahr.
    l_datum+4(2) = lw_afa_szla-monat.
    l_datum+6(2) = '01'.
    IF l_datum GE l_m01valid.
      lw_afa_szla-noneed = c_x.
      MODIFY t_afa_szla FROM lw_afa_szla TRANSPORTING noneed.
    ENDIF.
  ENDLOOP.
*--1965 #02.

*++2065 #13.
  DATA l_tcode TYPE tcode.
  TYPES: BEGIN OF ts_bkpf_new_1,
           tcode LIKE l_tcode,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
         END OF ts_bkpf_new_1.
  DATA: lt_bkpf_new_1 TYPE HASHED TABLE OF ts_bkpf_new_1
      WITH UNIQUE KEY bukrs belnr gjahr.
  CONSTANTS lc_tcode TYPE tcode VALUE 'FBA8'.
  CONSTANTS lc_vorgn TYPE vorgn VALUE 'AZUM'.
  FIELD-SYMBOLS <fs_afa_szla> TYPE /zak/afa_szla.
  DATA li_afa_szla_e TYPE STANDARD TABLE OF /zak/afa_szla.
  DATA ls_afa_szla_e TYPE /zak/afa_szla.
  DATA l_elokgen TYPE /zak/elokgen.

  TYPES: BEGIN OF lt_rebzg,
           bukrs TYPE bukrs,
           rebzg TYPE rebzg,
           rebzj TYPE rebzj,
           lwbas TYPE lwbas_bset,
           lwste TYPE /zak/lwste,
         END OF lt_rebzg.
  DATA li_rebzg TYPE HASHED TABLE OF lt_rebzg WITH UNIQUE KEY bukrs rebzg rebzj
                                                      INITIAL SIZE 0.

  TYPES: BEGIN OF lt_assign_belnr,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
           rebzg TYPE rebzg,
           rebzj TYPE rebzj,
           lwbas TYPE lwbas_bset,
           lwste TYPE /zak/lwste,
         END OF lt_assign_belnr.
  DATA li_assign_belnr TYPE STANDARD TABLE OF  lt_assign_belnr .
  DATA ls_assign_belnr TYPE lt_assign_belnr.
  DATA ls_rebzg TYPE lt_rebzg.
  FIELD-SYMBOLS <fs_rebzg> TYPE lt_rebzg.
*++2165 #02.
  TYPES: BEGIN OF lt_rebzg_belnr,
           bukrs TYPE bukrs,
           rebzg TYPE rebzg,
           rebzj TYPE rebzj,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
         END OF lt_rebzg_belnr.
  DATA li_rebzg_belnr TYPE STANDARD TABLE OF lt_rebzg_belnr.
  DATA ls_rebzg_belnr TYPE lt_rebzg_belnr.
  DATA ls_bseg TYPE bseg.
*++S4HANA#01.
  DATA: lv_rldnr1     TYPE rldnr,
        lt_bseg       TYPE fagl_t_bseg,
        lt_bseg_temp  TYPE TABLE OF bseg,
        lt_bseg_temp1 TYPE TABLE OF bseg.
*--S4HANA#01.
*--2165 #02.
* Előleg kezelés M-es lap tétel generálás
*++S4HANA#01.
*  LOOP AT t_afa_szla ASSIGNING <fs_afa_szla> WHERE noneed EQ ''.
  LOOP AT t_afa_szla ASSIGNING <fs_afa_szla> WHERE noneed EQ ''.
    APPEND <fs_afa_szla> TO lt_afa_szla_drv[].
  ENDLOOP.
  IF NOT lt_afa_szla_drv[] IS INITIAL.
    SORT lt_afa_szla_drv BY bukrs bseg_belnr bseg_gjahr.
    DELETE ADJACENT DUPLICATES FROM lt_afa_szla_drv
      COMPARING bukrs bseg_belnr bseg_gjahr.
    SELECT tcode bukrs belnr gjahr
      FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE lt_bkpf_new_1
      FOR ALL ENTRIES IN lt_afa_szla_drv
      WHERE bukrs EQ lt_afa_szla_drv-bukrs
      AND   belnr EQ lt_afa_szla_drv-bseg_belnr
      AND   gjahr EQ lt_afa_szla_drv-bseg_gjahr.
  ENDIF.
  FREE lt_afa_szla_drv[].
  LOOP AT t_afa_szla ASSIGNING <fs_afa_szla> WHERE noneed EQ ''.
*--S4HANA#01.
    CLEAR l_tcode.
*   Előleg generálás eljárás kezdő időpontja:
    IF l_elokgen IS INITIAL.
      SELECT SINGLE elokgen INTO l_elokgen
                     FROM /zak/start
                    WHERE bukrs EQ <fs_afa_szla>-bukrs.
      IF l_elokgen IS INITIAL.
        l_elokgen = '99991231'.
      ENDIF.
    ENDIF.

    l_datum(4)   = <fs_afa_szla>-gjahr.
    l_datum+4(2) = <fs_afa_szla>-monat.
    l_datum+6(2) = '01'.
*   Dátum figyelés <
    IF l_datum < l_elokgen.
      CONTINUE.
    ENDIF.

*++S4HANA#01.
*    SELECT SINGLE tcode INTO l_tcode
*                        FROM bkpf
*                       WHERE bukrs EQ <fs_afa_szla>-bukrs
*                         AND belnr EQ <fs_afa_szla>-bseg_belnr
*                         AND gjahr EQ <fs_afa_szla>-bseg_gjahr.
    ASSIGN lt_bkpf_new_1[
        bukrs = <fs_afa_szla>-bukrs
        belnr = <fs_afa_szla>-bseg_belnr
        gjahr = <fs_afa_szla>-bseg_gjahr
      ] TO FIELD-SYMBOL(<ls_bkpf_new_1>).
    IF sy-subrc = 0.
      l_tcode = <ls_bkpf_new_1>-tcode.
    ENDIF.
*--S4HANA#01.
    IF sy-subrc EQ 0 AND l_tcode EQ lc_tcode.
      APPEND <fs_afa_szla> TO li_afa_szla_e.
      <fs_afa_szla>-noneed = 'X'.
    ENDIF.
  ENDLOOP.
*++S4HANA#01.
  FREE lt_bkpf_new_1[].
*--S4HANA#01.
* Előleg sorok feldolgozása
*++S4HANA#01.
  CALL FUNCTION 'FAGL_GET_LEADING_LEDGER'
    IMPORTING
      e_rldnr       = lv_rldnr
    EXCEPTIONS
      not_found     = 1
      more_than_one = 2
      OTHERS        = 3.
*--S4HANA#01.
  LOOP AT  li_afa_szla_e ASSIGNING <fs_afa_szla>.
*++S4HANA#01.
**++2165 #02.
**    SELECT BUKRS REBZG REBZJ INTO CORRESPONDING FIELDS OF LS_REBZG
*    SELECT bukrs belnr gjahr rebzg rebzj INTO CORRESPONDING FIELDS OF ls_bseg
**--2165 #02.
*                       FROM bseg
*                      WHERE bukrs EQ <fs_afa_szla>-bukrs
*                        AND belnr EQ <fs_afa_szla>-bseg_belnr
*                        AND gjahr EQ <fs_afa_szla>-bseg_gjahr
*                        AND vorgn NE lc_vorgn
*                        AND rebzg NE ''
*                        AND rebzj NE ''.
    CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
      EXPORTING
        i_rldnr   = lv_rldnr1
        i_bukrs   = <fs_afa_szla>-bukrs
        i_belnr   = <fs_afa_szla>-bseg_belnr
        i_gjahr   = <fs_afa_szla>-bseg_gjahr
      IMPORTING
        et_bseg   = lt_bseg
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc = 0.
      DELETE lt_bseg WHERE vorgn EQ lc_vorgn.
      DELETE lt_bseg WHERE rebzg EQ ''.
      DELETE lt_bseg WHERE rebzj EQ ''.
      lt_bseg_temp[] = CORRESPONDING #( lt_bseg[] ).
      APPEND LINES OF lt_bseg_temp TO lt_bseg_temp1.
      CLEAR: lt_bseg[], lt_bseg_temp[].
    ENDIF.
*--S4HANA#01.
*++2165 #02.
*++S4HANA#01.
    IF lt_bseg_temp1 IS NOT INITIAL.
      LOOP AT lt_bseg_temp1 INTO ls_bseg.
*--S4HANA#01.
        MOVE-CORRESPONDING ls_bseg TO ls_rebzg.
        MOVE-CORRESPONDING ls_bseg TO ls_rebzg_belnr.
        COLLECT ls_rebzg_belnr INTO li_rebzg_belnr.
*--2165 #02.
        COLLECT ls_rebzg INTO li_rebzg.
*++S4HANA#01.
*  ENDSELECT.
      ENDLOOP.
    ENDIF.
*--S4HANA#01.
    ls_assign_belnr-belnr = <fs_afa_szla>-bseg_belnr.
    ls_assign_belnr-gjahr = <fs_afa_szla>-bseg_gjahr.
    ls_assign_belnr-rebzg = ls_rebzg-rebzg.
    ls_assign_belnr-rebzj = ls_rebzg-rebzj.
    ls_assign_belnr-lwbas = <fs_afa_szla>-lwbas.
    ls_assign_belnr-lwste = <fs_afa_szla>-lwste.
    COLLECT ls_assign_belnr INTO li_assign_belnr.
  ENDLOOP.

*++S4HANA#01.
*  REFRESH: li_afa_szla_e.
  CLEAR: li_afa_szla_e[].
*--S4HANA#01.
* Referencia rekordok keresése:
  LOOP AT li_rebzg ASSIGNING <fs_rebzg>.
    READ TABLE t_afa_szla INTO lw_afa_szla WITH KEY bukrs      = <fs_rebzg>-bukrs
                                                    bseg_belnr = <fs_rebzg>-rebzg
                                                    bseg_gjahr = <fs_rebzg>-rebzj.
    IF sy-subrc NE 0.
*++S4HANA#01.
*      SELECT SINGLE * INTO lw_afa_szla
*                      FROM /zak/afa_szla
      SELECT * INTO lw_afa_szla
                 FROM /zak/afa_szla UP TO 1 ROWS
*--S4HANA#01.
                   WHERE bukrs = <fs_rebzg>-bukrs
                     AND bseg_belnr = <fs_rebzg>-rebzg
                     AND bseg_gjahr = <fs_rebzg>-rebzj
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.
*     HIBA a referencia bizonylat meghatározásánál
      IF sy-subrc NE 0.
        CLEAR ls_assign_belnr.
        READ TABLE li_assign_belnr INTO ls_assign_belnr WITH KEY rebzg = <fs_rebzg>-rebzg
                                                                 rebzj = <fs_rebzg>-rebzj.
*++2165 #06.
*        MESSAGE E371(/ZAK/ZAK) WITH <FS_REBZG>-REBZG <FS_REBZG>-REBZJ LS_ASSIGN_BELNR-BELNR LS_ASSIGN_BELNR-GJAHR.
*       Nem található végszámla (&/&) az előleg elszámoláshoz (&/&).
        PERFORM add_message TABLES t_return
                            USING  '/ZAK/ZAK'
                                   'E'
                                   '371'
                                   <fs_rebzg>-rebzg
                                   <fs_rebzg>-rebzj
                                   ls_assign_belnr-belnr
                                   ls_assign_belnr-gjahr.
*--2165 #06.
      ENDIF.
    ENDIF.
    <fs_rebzg>-lwbas = lw_afa_szla-lwbas.
    <fs_rebzg>-lwste = lw_afa_szla-lwste.
    CLEAR: lw_afa_szla-lwbas, lw_afa_szla-lwste, lw_afa_szla-pack,
           lw_afa_szla-noneed.
    APPEND lw_afa_szla TO li_afa_szla_e.
  ENDLOOP.
*
  LOOP AT li_afa_szla_e ASSIGNING <fs_afa_szla>.
*  REPZG-LWBAS
    READ TABLE li_rebzg INTO ls_rebzg WITH KEY  bukrs = <fs_afa_szla>-bukrs
                                                rebzg = <fs_afa_szla>-bseg_belnr
                                                rebzj = <fs_afa_szla>-bseg_gjahr.
    CLEAR: l_lwbas, l_lwste.
    LOOP AT li_assign_belnr INTO ls_assign_belnr WHERE rebzg EQ ls_rebzg-rebzg
                                                   AND rebzj EQ ls_rebzg-rebzj.
      ADD ls_assign_belnr-lwbas TO l_lwbas.
      ADD ls_assign_belnr-lwste TO l_lwste.
    ENDLOOP.
    <fs_afa_szla>-lwbas = ls_rebzg-lwbas + l_lwbas.
    <fs_afa_szla>-lwste = ls_rebzg-lwste + l_lwste.
*   Generált rekord flag
    <fs_afa_szla>-elkgen = 'X'.
*   Index törlés
    CLEAR <fs_afa_szla>-zindex.
*   Tétel beállítása
    <fs_afa_szla>-bseg_buzei = '999'.
*++2020.12.16
*    READ TABLE T_AFA_SZLA INTO LW_AFA_SZLA WITH KEY SZAMLASZ = <FS_AFA_SZLA>-SZAMLASZ
*                                                    NONEED   = 'X'.
*    IF SY-SUBRC EQ 0.
*      <FS_AFA_SZLA>-SZAMLASZA = LW_AFA_SZLA-SZAMLASZA.
*    ELSE.
*++2165 #02.
    READ TABLE li_rebzg_belnr INTO ls_rebzg_belnr WITH KEY rebzg = <fs_afa_szla>-bseg_belnr
                                                           rebzj = <fs_afa_szla>-bseg_gjahr.
    IF sy-subrc EQ 0.
      READ TABLE t_afa_szla INTO lw_afa_szla WITH KEY bseg_belnr = ls_rebzg_belnr-belnr
                                                      bseg_gjahr = ls_rebzg_belnr-gjahr.
      IF sy-subrc EQ 0.
        <fs_afa_szla>-szamlasza = lw_afa_szla-szamlasza.
      ENDIF.
    ENDIF.
*    ENDIF.
*--2020.12.16
*--2165 #02
*   Ha a végszámla összege 0 akkor nem kell a generált tétel:
    IF  <fs_afa_szla>-lwste IS INITIAL.
      <fs_afa_szla>-noneed = 'X'.
    ENDIF.
*   A generált rekord stádiuma 'KÜL'
    <fs_afa_szla>-elstad = c_estad_k.
  ENDLOOP.
* Előleg stádium jelölése végszámla
  REFRESH li_analitika_ins.
  LOOP AT li_afa_szla_e INTO ls_afa_szla_e.
    READ TABLE t_afa_szla ASSIGNING <fs_afa_szla> WITH KEY bseg_belnr    = ls_afa_szla_e-bseg_belnr
                                                           bseg_gjahr    = ls_afa_szla_e-bseg_gjahr.
*   Csak akkor kell végszámla jelölés, ha KÜL is van
*++2165 #05.
*    IF SY-SUBRC EQ 0 AND LS_AFA_SZLA_E-NONEED IS INITIAL.
    IF sy-subrc EQ 0.
      <fs_afa_szla>-noneed = ls_afa_szla_e-noneed.
*--2165 #05.
      <fs_afa_szla>-elstad = c_estad_v.
    ENDIF.
*   Analitika bővítése
    READ TABLE t_analitika INTO lw_analitika WITH KEY abevaz = c_abevaz_dummy_r
                                                      bseg_belnr = ls_afa_szla_e-bseg_belnr
                                                      bseg_gjahr = ls_afa_szla_e-bseg_gjahr.
    IF sy-subrc EQ 0.
      lw_analitika-elstad = c_estad_v.
      MODIFY t_analitika FROM lw_analitika INDEX sy-tabix TRANSPORTING elstad.
      MOVE-CORRESPONDING ls_afa_szla_e TO lw_analitika.
      APPEND lw_analitika TO li_analitika_ins.
    ENDIF.
  ENDLOOP.
* AFA SZLA bővítése
  IF NOT li_afa_szla_e[] IS INITIAL.
    APPEND LINES OF li_afa_szla_e TO t_afa_szla.
  ENDIF.
* ANALITIKA bővítése
  IF NOT li_analitika_ins[] IS INITIAL.
    APPEND LINES OF li_analitika_ins TO t_analitika.
  ENDIF.
*--2065 #13.

ENDFUNCTION.
