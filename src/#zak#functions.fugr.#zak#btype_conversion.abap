FUNCTION /ZAK/BTYPE_CONVERSION.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE_FROM) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_BTYPE_TO) TYPE  /ZAK/BTYPE
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLALV
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"      VALIDITY_ERROR
*"----------------------------------------------------------------------

  data: v_bevallo type /zak/bevallalv.
  data: i_btype   type /zak/t_btype.
  data: v_subrc   like sy-subrc.

* Érvényességek ellenőrzése
  perform check_validities using i_bukrs
                                 i_btype_from
                                 i_btype_to
                           changing v_subrc.

  if v_subrc ne 0.
    message e118(/zak/zak) with i_bukrs
                           i_btype_from
                           i_btype_to
                      raising VALIDITY_ERROR.
  endif.

  check v_subrc = 0.
*
  perform get_all_btype  tables   i_btype
                         using    i_bukrs
                                  i_btype_from
                                  i_btype_to.


* Bevallb beolvasása
  perform read_all_bevallb using I_BTYPE_TO.

* Sorok feldolgozása
  loop at t_bevallo into v_bevallo.


    perform get_abev_contact tables i_btype
                             using v_bevallo-btype
                                   v_bevallo-abevaz
                                   i_btype_to
                          changing v_bevallo-btype_disp
                                   v_bevallo-abevaz_disp.


* Új ABEV kód megnevezése
    perform get_abev_text using v_bevallo-btype_disp
                                v_bevallo-abevaz_disp
                          changing v_bevallo-ABEVTEXT_DISP.


* Új BEVALLB adatok
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = v_bevallo-btype_disp
                ABEVAZ = v_bevallo-abevaz_disp.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE  = v_bevallo-btype_disp
            AND ABEVAZ = v_bevallo-abevaz_disp.
      INSERT W_/ZAK/BEVALLB INTO table I_/ZAK/BEVALLB.
    ENDIF.


    v_bevallo-MANUAL  = W_/ZAK/BEVALLB-manual.
    v_bevallo-COLLECT = W_/ZAK/BEVALLB-collect.
    v_bevallo-ABEV_NO = W_/ZAK/BEVALLB-abev_no.

    modify t_bevallo from v_bevallo.
  endloop.
*


ENDFUNCTION.
