FUNCTION /zak/main_exit .
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_MONAT) TYPE  MONAT
*"     REFERENCE(I_INDEX) TYPE  /ZAK/INDEX
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLALV
*"      T_ADOAZON STRUCTURE  /ZAK/ONR_ADOAZON OPTIONAL
*"      T_AFA_SZLA_SUM STRUCTURE  /ZAK/AFA_SZLASUM OPTIONAL
*"----------------------------------------------------------------------
  DATA: v_last_date TYPE sy-datum.


************************************************************************
* Bevallás adatok
* Bevallás utolsó napjának meghatározás
  PERFORM get_last_day_of_period USING i_gjahr
                                       i_monat
*++PTGSZLAA #01. 2014.03.03
                                       i_btype
*--PTGSZLAA #01. 2014.03.03
                                  CHANGING v_last_date.


* Bevallás általános adatai
  PERFORM read_bevall  USING i_bukrs
                             i_btype
                             v_last_date.


*  Bevallás adatszerkezetének kiolvasása
  PERFORM read_bevallb USING t_bevallo[]
                             i_btype.

*++ BG 2007.05.17
* A nyomtatvány default értékeket a display BTYPE
* alapján kell beolvasni:
**  bevallás Nyomtatvány default értékek
*  PERFORM READ_BEVALLDEF USING I_BUKRS
*                               I_BTYPE.
*-- BG 2007.05.17

*
  DATA: l_alv   LIKE /zak/bevallalv,
        l_tabix LIKE sy-tabix.

  CLEAR w_/zak/bevallo.
  REFRESH i_/zak/bevallo.

*++ BG 2007.05.17
  REFRESH r_disp_btype.
*-- BG 2007.05.17

  LOOP AT t_bevallo INTO l_alv.
    MOVE-CORRESPONDING l_alv TO w_/zak/bevallo.
    APPEND w_/zak/bevallo TO i_/zak/bevallo.
*++ BG 2007.05.17
*   Display BTYPE gyűjtése
    READ TABLE r_disp_btype WITH KEY low = l_alv-btype_disp.
    IF sy-subrc NE 0.
      m_def r_disp_btype 'I' 'EQ' l_alv-btype_disp space.
    ENDIF.
*-- BG 2007.05.17
  ENDLOOP.

*++ BG 2007.05.17
*  bevallás Nyomtatvány default értékek
  PERFORM read_bevalldef TABLES r_disp_btype
                          USING i_bukrs.
*-- BG 2007.05.17

*++1365 2013.01.22 Balázs Gábor (Ness)
* Nyomtatvány default értékek beállítása !
  PERFORM set_default_abev TABLES i_/zak/bevallo
                                  i_/zak/bevalldef
                           USING  i_gjahr
                                  i_monat
                                  i_index
                                  i_bukrs
*++BG 2007/10/10
                                  v_last_date
*--BG 2007/10/10
                                  .
*--1365 2013.01.22 Balázs Gábor (Ness)

* Bevallás - számított ABEV-ek
*++1365 2013.01.22 Balázs Gábor (Ness)
*  PERFORM CALC_ABEV TABLES I_/ZAK/BEVALLO
  PERFORM calc_abev_afa TABLES i_/zak/bevallo
                               i_/zak/bevallb
                               t_adoazon
                               t_afa_szla_sum
                        USING  v_last_date
                               i_index.
*--1365 2013.01.22 Balázs Gábor (Ness)

*++1365 2013.01.22 Balázs Gábor (Ness)
** Nyomtatvány default értékek beállítása !
*  PERFORM SET_DEFAULT_ABEV TABLES I_/ZAK/BEVALLO
*                                  I_/ZAK/BEVALLDEF
*                           USING  I_GJAHR
*                                  I_MONAT
*                                  I_INDEX
*                                  I_BUKRS
**++BG 2007/10/10
*                                  V_LAST_DATE
**--BG 2007/10/10
*                                  .
*--1365 2013.01.22 Balázs Gábor (Ness)

* Bevallás - átvett ABEV-ek
  PERFORM get_abev TABLES i_/zak/bevallo
                          i_/zak/bevallb.


* Bevallás - sorok számlálása
  PERFORM count_abev TABLES i_/zak/bevallo
                            i_/zak/bevallb.

  DATA: w_dele LIKE /zak/bevallalv .

  LOOP AT i_sum INTO w_/zak/bevallo.
    CLEAR v_tabix.
    READ TABLE t_bevallo INTO w_dele
    WITH KEY abevaz = w_/zak/bevallo-abevaz.
    IF sy-subrc EQ 0.
      v_tabix = sy-tabix.
      DELETE t_bevallo WHERE abevaz EQ w_/zak/bevallo-abevaz.
    ENDIF.
    CLEAR l_alv.
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
    IF v_tabix IS INITIAL.
      APPEND l_alv TO t_bevallo.
    ELSE.
      INSERT l_alv INTO t_bevallo INDEX v_tabix.
    ENDIF.
  ENDLOOP.

*++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás
*++S4HANA#01.
*  SORT T_BEVALLO.
  SORT t_bevallo BY bukrs btype gjahr monat zindex abevaz adoazon lapsz.
*--S4HANA#01.
*--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás

  LOOP AT i_/zak/bevallo INTO w_/zak/bevallo.
    l_tabix = sy-tabix.
    READ TABLE t_bevallo INTO l_alv WITH KEY
                  bukrs   = w_/zak/bevallo-bukrs
                  btype   = w_/zak/bevallo-btype
                  gjahr   = w_/zak/bevallo-gjahr
                  monat   = w_/zak/bevallo-monat
                  zindex  = w_/zak/bevallo-zindex
                  abevaz  = w_/zak/bevallo-abevaz
                  adoazon = w_/zak/bevallo-adoazon
*++1365 #6.
                  lapsz   = w_/zak/bevallo-lapsz
*--1365 #6.
*++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás
                  BINARY SEARCH.
*--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING w_/zak/bevallo TO l_alv.
      MODIFY t_bevallo FROM l_alv INDEX sy-tabix.
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
*++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás
      SORT t_bevallo.
*--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
