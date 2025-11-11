FUNCTION /ZAK/SET_DATUM.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_DATUM) TYPE  DATUM
*"     VALUE(I_BIDOSZ) TYPE  /ZAK/IDOSZ OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_DATUM) TYPE  DATUM
*"----------------------------------------------------------------------

  DATA L_MONAT TYPE MONAT.

* ...negyedéves
  IF I_BIDOSZ = 'N'.
    CASE I_DATUM+4(2).
      WHEN '01' OR '02' OR '03'.
        L_MONAT = '03'.
      WHEN '04' OR '05' OR '06'.
        L_MONAT = '06'.
      WHEN '07' OR '08' OR '09'.
        L_MONAT = '09'.
      WHEN '10' OR '11' OR '12'.
        L_MONAT = '12'.
    ENDCASE.
* ...éves
  ELSEIF I_BIDOSZ = 'E'.
    L_MONAT = '12'.
* ...havi vagy egyéb
  ELSE.
    E_DATUM = I_DATUM.
  ENDIF.

  CHECK NOT L_MONAT IS INITIAL.
* Bevallás utolsó napjának meghatározás
  PERFORM GET_LAST_DAY_OF_PERIOD USING I_DATUM(4)
                                       L_MONAT
                                  CHANGING E_DATUM.


ENDFUNCTION.
