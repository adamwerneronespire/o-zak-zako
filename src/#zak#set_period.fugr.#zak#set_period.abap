FUNCTION /ZAK/SET_PERIOD.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  T001-BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_MONAT) TYPE  MONAT
*"  EXPORTING
*"     VALUE(E_GJAHR) TYPE  GJAHR
*"     VALUE(E_MONAT_TOL) TYPE  MONAT
*"     VALUE(E_MONAT_IG) TYPE  MONAT
*"     VALUE(E_BIDOSZ) TYPE  /ZAK/IDOSZ
*"----------------------------------------------------------------------
  DATA: V_LAST_DATE TYPE DATUM.
  DATA: L_GJAHR TYPE GJAHR,
        L_MONAT TYPE MONAT,
        L_DATE  TYPE DATUM.

  E_GJAHR = I_GJAHR.

*  IF I_MONAT = 12.
*    L_GJAHR = I_GJAHR + 1.
*    L_MONAT = '01'.
*  ELSE.
*    L_MONAT = I_MONAT + 1.
*    L_GJAHR = I_GJAHR.
*  ENDIF.

* Bevallás utolsó napjának meghatározás
  PERFORM GET_LAST_DAY_OF_PERIOD USING I_GJAHR
                                       I_MONAT
                                  CHANGING V_LAST_DATE.

  CLEAR W_/ZAK/BEVALL.
  SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL FROM  /ZAK/BEVALL
      WHERE     BUKRS  = I_BUKRS
         AND    BTYPE  = I_BTYPE
         AND    DATBI  >= V_LAST_DATE
*++S4HANA#01.
    ORDER BY PRIMARY KEY.
*--S4HANA#01.
  ENDSELECT.
* időszak
  E_BIDOSZ = W_/ZAK/BEVALL-BIDOSZ.

* ...negyedéves
  IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
    CASE I_MONAT.
      WHEN '01' OR '02' OR '03'.
        E_MONAT_TOL = '01'.
        E_MONAT_IG = '03'.
      WHEN '04' OR '05' OR '06'.
        E_MONAT_TOL = '04'.
        E_MONAT_IG = '06'.
      WHEN '07' OR '08' OR '09'.
        E_MONAT_TOL = '07'.
        E_MONAT_IG = '09'.
      WHEN '10' OR '11' OR '12'.
        E_MONAT_TOL = '10'.
        E_MONAT_IG = '12'.
    ENDCASE.
* ...éves
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
    E_MONAT_TOL = '01'.
    E_MONAT_IG = '12'.
* ...havi
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'H'.
    E_MONAT_TOL = I_MONAT.
    E_MONAT_IG = I_MONAT.
  ENDIF.

*  SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*     WHERE BUKRS = I_BUKRS AND
*           BTYPE = I_BTYPE AND
*           GJAHR => I_GJAHR AND
*           FLAG NE 'X' AND
*           FLAG NE 'Z'.
*
*  SORT I_/ZAK/BEVALLI BY BUKRS BTYPE GJAHR MONAT ZINDEX DESCENDING.
*  LOOP AT I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
*
**    CONCATENATE $GJAHR $MONAT '01' INTO L_DATE1.
*
*    IF W_/ZAK/BEVALLI-GJAHR = I_GJAHR AND
*       W_/ZAK/BEVALLI-MONAT = I_MONAT.
** időszak nyitott
*      E_GJAHR = I_GJAHR.
*      E_MONAT = I_MONAT.
*    ELSE.
** következő időszak
*      IF W_/ZAK/BEVALLI-GJAHR NE L_GJAHR AND
*         W_/ZAK/BEVALLI-MONAT NW L_MONAT.
*
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
ENDFUNCTION.
