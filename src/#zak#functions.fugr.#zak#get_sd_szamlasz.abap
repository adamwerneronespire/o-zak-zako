FUNCTION /zak/get_sd_szamlasz.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS OPTIONAL
*"     VALUE(I_BELNR) TYPE  BELNR_D OPTIONAL
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_AWKEY) TYPE  AWKEY OPTIONAL
*"  EXPORTING
*"     VALUE(E_SZAMLASZA) TYPE  /ZAK/SZAMLASZA
*"     VALUE(E_SZAMLASZ) TYPE  /ZAK/SZAMLASZ
*"     VALUE(E_SZAMLASZE) TYPE  /ZAK/SZAMLASZE
*"     VALUE(E_SZLATIP) TYPE  /ZAK/SZLATIP
*"     VALUE(E_STORNO) TYPE  XFELD
*"  TABLES
*++1665 #08.
*"      T_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*--1665 #08.
*"  EXCEPTIONS
*"      ERROR_AWKEY
*"      ERROR_OTHER
*"----------------------------------------------------------------------

  DATA ls_comwa    TYPE  vbco6.
*++S4HANA#01.
*  DATA LI_VBFA_TAB TYPE STANDARD TABLE OF  VBFA.
*  DATA LI_VBFA_TAB_ALL TYPE STANDARD TABLE OF  VBFA.
*  DATA LW_VBFA_TAB TYPE VBFA.
*  DATA L_SUBRC LIKE SY-SUBRC.
  DATA li_vbfa_tab TYPE STANDARD TABLE OF  vbfa.  "$smart(M): #2198647
  DATA li_vbfa_tab_all TYPE STANDARD TABLE OF  VBFA. "$smart(M): #21986
  DATA lw_vbfa_tab TYPE VBFA.   "$smart(M): #2198647
  DATA l_subrc TYPE sy-subrc.
*--S4HANA#01.
  DATA l_orig_vbeln TYPE vbeln.
  DATA lw_szla_group TYPE t_szla_group.
*++1465 #03.
  DATA l_fksto TYPE fksto.
  DATA l_sfakn TYPE sfakn.
  DATA l_awkey TYPE awkey.
  DATA l_vbtyp_n TYPE string VALUE 'CGHIKLE'.
*--1465 #03.

* Rangek definiálása
  RANGES lr_vbtyp   FOR vbfa-vbtyp_n.
  RANGES lr_vbtyp_m FOR vbfa-vbtyp_n. "Normál számla
  RANGES lr_vbtyp_s FOR vbfa-vbtyp_n. "Sztornó
  RANGES lr_vbtyp_f FOR vbfa-vbtyp_n. "Főkönyvi bizonylat

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_TELENOR_01 SPOTS /ZAK/FUNCTIONS_ES STATIC .

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_FGSZ_01 SPOTS /ZAK/FUNCTIONS_ES .

* Normál bizonylattípus
  m_def lr_vbtyp 'I' 'EQ' 'M' space.
  m_def lr_vbtyp 'I' 'EQ' 'O' space.
  m_def lr_vbtyp 'I' 'EQ' 'P' space.
  m_def lr_vbtyp 'I' 'EQ' 'N' space.
  m_def lr_vbtyp 'I' 'EQ' 'S' space.
* Normál számla
  m_def lr_vbtyp_m 'I' 'EQ' 'M' space.
ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_TELENOR_04 SPOTS /ZAK/FUNCTIONS_ES .
* Storno
  m_def lr_vbtyp_s 'I' 'EQ' 'N' space.
  m_def lr_vbtyp_s 'I' 'EQ' 'S' space.
* Könyvelés
  m_def lr_vbtyp_f 'I' 'EQ' '+' space.
*++1365 #7.
  DATA l_vbeln TYPE vbeln.
  DATA l_posnn TYPE posnv.
*--1365 #7.

  DEFINE m_conv_alpha_input.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = &1
      IMPORTING
        output = &1.
  END-OF-DEFINITION.


*Meghatározzuk a referencia kulcsot
  IF i_awkey IS INITIAL.
    m_conv_alpha_input i_belnr.
    SELECT SINGLE awkey INTO i_awkey
                        FROM bkpf
                       WHERE bukrs EQ i_bukrs
                         AND belnr EQ i_belnr
                         AND gjahr EQ i_gjahr.
*  ELSE.
*    M_CONV_ALPHA_INPUT I_AWKEY.
  ENDIF.

  IF i_awkey IS INITIAL.
*++1665 #08.
**++1365 #9.
**    MESSAGE E354(/ZAK/ZAK) RAISING ERROR_AWKEY.
*    MESSAGE e354(/zak/zak) WITH i_awkey RAISING error_awkey.
*--1365 #9.
    PERFORM add_message TABLES t_return
                        USING  '/ZAK/ZAK'
                               'E'
                               '354'
                               i_awkey
                               ''
                               ''
                               ''.
*--1665 #08.
*   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY)
  ENDIF.
ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_TELENOR_02 SPOTS /ZAK/FUNCTIONS_ES .

*++S4HANA#01.
*  REFRESH I_SZLA_GROUP.
  CLEAR i_szla_group[].
*--S4HANA#01.
  CLEAR   v_szamlasza.

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_ZF_01 SPOTS /ZAK/FUNCTIONS_ES .

* Hierechia TOP meghatáozása
  m_set_comwa i_awkey 0.
  l_orig_vbeln = ls_comwa-vbeln.
*++S4HANA#01.
*  m_call_flow_information li_vbfa_tab l_subrc.
  m_call_flow_information li_vbfa_tab l_subrc.         "#EC CI_USAGE_OK[2198647]
*--S4HANA#01.
  IF NOT l_subrc IS INITIAL.
*++1665 #08.
**++1365 #9.
**    MESSAGE E354(/ZAK/ZAK) RAISING ERROR_AWKEY.
*    MESSAGE e354(/zak/zak) WITH i_awkey RAISING error_awkey.
**--1365 #9.
    PERFORM add_message TABLES t_return
                        USING  '/ZAK/ZAK'
                               'E'
                               '354'
                               i_awkey
                               ''
                               ''
                               ''.
*--1665 #08.
*   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY)
  ENDIF.


*++1365 #7.
  CLEAR: l_vbeln, l_posnn.

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_MOL_02 SPOTS /ZAK/FUNCTIONS_ES .

  LOOP AT li_vbfa_tab INTO lw_vbfa_tab WHERE " VBELV IS INITIAL
                                         " AND POSNV IS INITIAL
                                          NOT vbeln IS INITIAL
                                         AND NOT posnn IS INITIAL
*++1465 #03.
*                                         AND VBTYP_N CA 'CGHIKL'.
*++S4HANA#01.
*                                         AND VBTYP_N CA L_VBTYP_N.
                                         AND ( vbtyp_n = if_sd_doc_category=>order OR vbtyp_n =  "$smart: #607
                                           if_sd_doc_category=>contract OR vbtyp_n =             "$smart: #607
                                           if_sd_doc_category=>returns OR vbtyp_n =              "$smart: #607
                                           if_sd_doc_category=>order_wo_charge OR vbtyp_n =      "$smart: #607
                                           if_sd_doc_category=>credit_memo_req OR vbtyp_n =      "$smart: #607
                                           if_sd_doc_category=>debit_memo_req OR vbtyp_n =       "$smart: #607
                                           if_sd_doc_category=>sched_agree ).                    "$smart: #607
*--S4HANA#01.
*--1465 #03.
*    IF LW_VBFA_TAB-VBTYP_N = 'I'.
*      LOOP AT LI_VBFA_TAB INTO LW_VBFA_TAB WHERE VBTYP_V EQ 'I'.
* Rápozícionálunk a második sorra, hogy onnan vegyük ki az adatot
*        EXIT.
*      ENDLOOP.
*    ENDIF.
*++1465 #04.
*   Ha kiszállítási terv, akkor a szállításra állunk rá perfromancia miatt.
*++S4HANA#01.
*    IF LW_VBFA_TAB-VBTYP_N = 'E'.
    IF lw_vbfa_tab-vbtyp_n = if_sd_doc_category=>sched_agree.
*--S4HANA#01.
      READ TABLE li_vbfa_tab INTO lw_vbfa_tab
                    WITH KEY vbelv   = lw_vbfa_tab-vbeln
                             posnv   = lw_vbfa_tab-posnn
*++S4HANA#01.
*                             VBTYP_V = 'E'.
                             vbtyp_v = if_sd_doc_category=>sched_agree.
*--S4HANA#01.
      IF sy-subrc EQ 0.
        l_vbeln = lw_vbfa_tab-vbeln.
        l_posnn = lw_vbfa_tab-posnn.
      ELSE.
*++1665 #08.
*        MESSAGE E357(/ZAK/ZAK) WITH LS_COMWA-VBELN.
**       Szállítás tervhez nem lehet meghatározni kiszállítást (számla: &)!
        PERFORM add_message TABLES t_return
                            USING  '/ZAK/ZAK'
                                   'E'
                                   '357'
                                   ls_comwa-vbeln
                                   ''
                                   ''
                                   ''.
*--1665 #08.
      ENDIF.
    ELSE.
*--1465 #04.
      l_vbeln = lw_vbfa_tab-vbeln.
      l_posnn = lw_vbfa_tab-posnn.
*++1465 #04.
    ENDIF.
*--1465 #04.
    m_set_comwa l_vbeln l_posnn.
*++S4HANA#01.
*    m_call_flow_information li_vbfa_tab_all l_subrc.
    m_call_flow_information li_vbfa_tab_all l_subrc.      "#EC CI_USAGE_OK[2198647]
*--S4HANA#01.
    LOOP AT li_vbfa_tab_all TRANSPORTING NO FIELDS
                      WHERE  ( vbelv = i_awkey OR vbeln = i_awkey ).
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDLOOP.

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_MOL_03 SPOTS /ZAK/FUNCTIONS_ES .

  IF sy-subrc NE 0.
*++1465 #03.
*    LOOP AT LI_VBFA_TAB INTO LW_VBFA_TAB WHERE VBTYP_V CA 'CGHIKL'.
*++S4HANA#01.
*    LOOP AT LI_VBFA_TAB INTO LW_VBFA_TAB WHERE VBTYP_V CA L_VBTYP_N.
    LOOP AT li_vbfa_tab INTO lw_vbfa_tab WHERE ( vbtyp_v = if_sd_doc_category=>order OR vbtyp_v ="$smart: #607
      if_sd_doc_category=>contract OR vbtyp_v = if_sd_doc_category=>returns OR vbtyp_v =         "$smart: #607
      if_sd_doc_category=>order_wo_charge OR vbtyp_v = if_sd_doc_category=>credit_memo_req OR    "$smart: #607
      vbtyp_v = if_sd_doc_category=>debit_memo_req OR vbtyp_v = if_sd_doc_category=>sched_agree  "$smart: #607
      ).                                                                                         "$smart: #607
*--S4HANA#01.
*--1465 #03.
      l_vbeln = lw_vbfa_tab-vbelv.
      l_posnn = lw_vbfa_tab-posnv.
      m_set_comwa l_vbeln l_posnn.
*++S4HANA#01.
*      m_call_flow_information li_vbfa_tab_all l_subrc.
      m_call_flow_information li_vbfa_tab_all l_subrc.           "#EC CI_USAGE_OK[2198647]
*--S4HANA#01.
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0.

* ha nem volt benne egyáltalán SD Rendelés típusú bizonylat,
* megnézzük, hogy MM Megrendeléssel indult-e
      LOOP AT li_vbfa_tab INTO lw_vbfa_tab WHERE vbelv IS INITIAL
                                             AND posnv IS INITIAL
                                             AND NOT vbeln IS INITIAL
                                             AND NOT posnn IS INITIAL
*++S4HANA#01.
*                                             AND VBTYP_N EQ 'V'.
                                             AND vbtyp_n EQ if_sd_doc_category=>purchase_order. "$smart: #607
*--S4HANA#01.
        m_set_comwa l_vbeln l_posnn.
        EXIT.
      ENDLOOP.
      IF sy-subrc EQ 0.
*++S4HANA#01.
*        LOOP AT LI_VBFA_TAB INTO LW_VBFA_TAB WHERE VBTYP_V EQ 'J'.
        LOOP AT li_vbfa_tab INTO lw_vbfa_tab WHERE vbtyp_v EQ if_sd_doc_category=>delivery.      "$smart: #607
*--S4HANA#01.
          l_vbeln = lw_vbfa_tab-vbelv.
          l_posnn = lw_vbfa_tab-posnv.
          m_set_comwa l_vbeln l_posnn.
*++S4HANA#01.
*          M_CALL_FLOW_INFORMATION LI_VBFA_TAB_ALL L_SUBRC.
          m_call_flow_information li_vbfa_tab_all l_subrc. "#EC CI_USAGE_OK[2198647]
*--S4HANA#01.
          EXIT.
        ENDLOOP.
      ENDIF.
ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_TELENOR_03 SPOTS /ZAK/FUNCTIONS_ES .
*++1465 #03.
*Sztornó kezelés vizsgálat
      l_subrc = sy-subrc.
      SELECT SINGLE fksto sfakn INTO (l_fksto, l_sfakn)
                                FROM vbrk
                               WHERE vbeln = l_orig_vbeln.
*     Ez a rendelés sztornózva ez lesz az eredeti
      IF NOT l_fksto IS INITIAL.
        e_szamlasza = l_orig_vbeln.
        e_szamlasz  = l_orig_vbeln.
        e_szlatip   = c_szlatip_e.
        EXIT.
*     Ez a sztornó bizonylat, megkeressük az eredetit
      ELSEIF NOT l_sfakn IS INITIAL.
        e_szamlasz  = l_orig_vbeln.
        e_szamlasze = l_sfakn.
        e_szlatip   = c_szlatip_k.
        e_storno    = 'X'.
        l_awkey     = l_sfakn.
        CALL FUNCTION '/ZAK/GET_SD_SZAMLASZ'
          EXPORTING
            i_bukrs     = i_bukrs
*           I_BELNR     =
*           I_GJAHR     =
            i_awkey     = l_awkey
          IMPORTING
            e_szamlasza = e_szamlasza.
        EXIT.
      ELSE.

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_MOL_01 SPOTS /ZAK/FUNCTIONS_ES .

        sy-subrc = l_subrc.
      ENDIF.
*--1465 #03.
      IF sy-subrc NE 0.
*++1665 #07.
*++S4HANA#01.
*        LOOP AT LI_VBFA_TAB INTO LW_VBFA_TAB WHERE VBTYP_N EQ 'M'   "számla
*                                               AND VBTYP_V EQ '2'.  "és az előzménye külső
        LOOP AT li_vbfa_tab INTO lw_vbfa_tab WHERE vbtyp_n EQ if_sd_doc_category=>invoice        "$smart: #607
"számla                                                                                "$smart: #607
                                     AND vbtyp_v EQ                                    "$smart: #607
                                       if_sd_doc_category=>external_transaction.       "$smart: #607
          "és az előzménye külső                          "$smart: #607
*--S4HANA#01.
          EXIT.
        ENDLOOP.
        IF sy-subrc = 0.
          e_szamlasza = lw_vbfa_tab-vbeln.
          e_szamlasz  = lw_vbfa_tab-vbeln.
          e_szlatip   = c_szlatip_e.
        ELSE.
*++1665 #08.
*          MESSAGE E355(/ZAK/ZAK) WITH I_AWKEY RAISING ERROR_OTHER.
          PERFORM add_message TABLES t_return
                              USING  '/ZAK/ZAK'
                                     'E'
                                     '355'
                                     i_awkey
                                     ''
                                     ''
                                     ''.
*--1665 #08.
        ENDIF.
*        MESSAGE E355(/ZAK/ZAK) WITH I_AWKEY RAISING ERROR_OTHER.
*--1665 #07.
      ENDIF.
*   Hiba a & követõ bizonylatok meghatározásánál!
    ENDIF.
  ENDIF.
* Teljes bizonylatáramlás felépítése
*  M_SET_COMWA LW_VBFA_TAB-VBELN LW_VBFA_TAB-POSNN.
*  M_SET_COMWA L_VBELN L_POSNN.
*  M_CALL_FLOW_INFORMATION LI_VBFA_TAB_ALL L_SUBRC.
*--1365 #7.
* Hierarchia feldolgozása
  PERFORM proc_vbfa_tab TABLES li_vbfa_tab_all
                               i_szla_group
                               lr_vbtyp
                               lr_vbtyp_m
                               lr_vbtyp_s
                               lr_vbtyp_f
                         USING ls_comwa-vbeln
                               ls_comwa-posnr
*++S4HANA#01.
*                              V_SZAMLASZA.
                         CHANGING v_szamlasza.
*--S4HANA#01.

* Meghatározzuk a kimeneti adatokat:
  READ TABLE i_szla_group INTO lw_szla_group
                          WITH KEY szamlasz = l_orig_vbeln.
*++1365 #7.
  IF sy-subrc NE 0.
* Ha nics találat de a csoportban csak üres SZAMLASZA-k
* vannak, akkor a önmaga lesz
    LOOP AT i_szla_group TRANSPORTING NO FIELDS
                         WHERE NOT szamlasza IS INITIAL.
      EXIT.
    ENDLOOP.
* Van rekord SZAMLASZA-val tehát hiba
    IF sy-subrc EQ 0.
*++1665 #08.
*      MESSAGE E355(/ZAK/ZAK) WITH I_AWKEY RAISING ERROR_OTHER.
**   Hiba a & követ# bizonylatok meghatározásánál!
      PERFORM add_message TABLES t_return
                          USING  '/ZAK/ZAK'
                                 'E'
                                 '355'
                                 i_awkey
                                 ''
                                 ''
                                 ''.
*--1665 #08.
    ELSE.
      lw_szla_group-szamlasza = l_orig_vbeln.
      lw_szla_group-szamlasz  = l_orig_vbeln.
      lw_szla_group-szlatip   = c_szlatip_e.
    ENDIF.
*--1365 #7.
  ENDIF.
  e_szamlasza = lw_szla_group-szamlasza.
  e_szamlasz  = lw_szla_group-szamlasz.
  IF lw_szla_group-vbtyp IN lr_vbtyp_s.
    e_storno = 'X'.
  ENDIF.
  IF lw_szla_group-szlatip EQ c_szlatip_e.
    e_szlatip = lw_szla_group-szlatip.
* Előzmény bizonylat meghatározása
  ELSE.
*++S4HANA#01.
*    m_set_comwa lw_szla_group-szamlasz lw_szla_group-posnn.
*    m_call_flow_information li_vbfa_tab l_subrc.
    m_set_comwa lw_szla_group-szamlasz lw_szla_group-posnn.      "#EC CI_USAGE_OK[2198647]
    m_call_flow_information li_vbfa_tab l_subrc.         "#EC CI_USAGE_OK[2198647]
*--S4HANA#01.
    IF NOT l_subrc IS INITIAL.
*++1665 #08.
*      MESSAGE E355(/ZAK/ZAK) WITH I_AWKEY RAISING ERROR_OTHER.
**   Hiba a & követő bizonylatok meghatározásánál!
      PERFORM add_message TABLES t_return
                          USING  '/ZAK/ZAK'
                                 'E'
                                 '355'
                                 i_awkey
                                 ''
                                 ''
                                 ''.
*--1665 #08.
    ENDIF.
    PERFORM get_szamlasze TABLES li_vbfa_tab
                                 lr_vbtyp
                          USING  ls_comwa-vbeln
                                 ls_comwa-posnr
*++S4HANA#01.
*                                 E_SZAMLASZE.
                          CHANGING e_szamlasze.
*--S4HANA#01.

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_MOL_04 SPOTS /ZAK/FUNCTIONS_ES .

  ENDIF.

ENHANCEMENT-POINT /ZAK/ZAK_GET_SD_FGSZ_02 SPOTS /ZAK/FUNCTIONS_ES .

*++1465 #15.
  FREE: li_vbfa_tab, li_vbfa_tab_all.
*--1465 #15.
ENDFUNCTION.
