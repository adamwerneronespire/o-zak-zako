FUNCTION /ZAK/CONVERT_STRING_TO_PACKED .
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_AMOUNT)
*"     VALUE(I_CURRENCY_CODE)
*"  EXPORTING
*"     VALUE(E_AMOUNT)
*"  EXCEPTIONS
*"      NOT_NUMERIC
*"----------------------------------------------------------------------
  tables tcurx.

  DATA: W_AMOUNT_C      TYPE TEXT255,
        W_AMOUNT_F      TYPE F,
        W_AMOUNT_P(16)  TYPE P DECIMALS 2,
        W_DEC_POINT_CNT TYPE N,
        W_DEC_POINT_POS LIKE SY-FDPOS VALUE 1.
  DATA: W_CURRDEC       LIKE TCURX-CURRDEC,
        W_DIVIDER       TYPE I.
* Formátum ellenõrzés
  W_AMOUNT_C = I_AMOUNT.
* Tizedes vesszõ és pont lecserélése #-ra
  TRANSLATE W_AMOUNT_C USING ',#.#'.
* Van-e benne több tizedes pont?
  DO.
    SEARCH W_AMOUNT_C FOR '#' STARTING AT W_DEC_POINT_POS.
    IF SY-SUBRC <> 0. EXIT. ENDIF.
    W_DEC_POINT_CNT = W_DEC_POINT_CNT + 1.
    W_DEC_POINT_POS = W_DEC_POINT_POS + SY-FDPOS + 1.
  ENDDO.
  IF W_DEC_POINT_CNT > 1.
    RAISE NOT_NUMERIC.
  ENDIF.
* Ven-e benne nem numerikus karakter
  IF NOT W_AMOUNT_C CO '0123456789# '.
    RAISE NOT_NUMERIC.
  ENDIF.
* A # átalakítása tizedes ponttá
  TRANSLATE W_AMOUNT_C USING '#.'.
* Szóközök kiszedése
  CONDENSE W_AMOUNT_C NO-GAPS.
*
* Összeg kiszámolása
  W_AMOUNT_F = W_AMOUNT_C.
* Osztó meghatározása
  SELECT SINGLE * FROM  TCURX
         WHERE  CURRKEY  = I_CURRENCY_CODE.
  IF SY-SUBRC <> 0.
    W_CURRDEC = 2.
    W_DIVIDER = 1.
  ELSE.
    W_CURRDEC = TCURX-CURRDEC.
    W_DIVIDER = 10 ** ( 2 - TCURX-CURRDEC ).
  ENDIF.

* Pakolt összeg kiszámítása
  IF W_DIVIDER = 1.
    W_AMOUNT_P = W_AMOUNT_F.
  ELSE.
    W_AMOUNT_P = W_AMOUNT_F / W_DIVIDER.
  ENDIF.
*
  E_AMOUNT = W_AMOUNT_P.

ENDFUNCTION.
