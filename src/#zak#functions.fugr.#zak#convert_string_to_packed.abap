FUNCTION /ZAK/CONVERT_STRING_TO_PACKED .
*"----------------------------------------------------------------------
*"* Local interface:
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
* Format validation
  W_AMOUNT_C = I_AMOUNT.
* Replace decimal comma and dot with #
  TRANSLATE W_AMOUNT_C USING ',#.#'.
* Check for multiple decimal points
  DO.
    SEARCH W_AMOUNT_C FOR '#' STARTING AT W_DEC_POINT_POS.
    IF SY-SUBRC <> 0. EXIT. ENDIF.
    W_DEC_POINT_CNT = W_DEC_POINT_CNT + 1.
    W_DEC_POINT_POS = W_DEC_POINT_POS + SY-FDPOS + 1.
  ENDDO.
  IF W_DEC_POINT_CNT > 1.
    RAISE NOT_NUMERIC.
  ENDIF.
* Check for non-numeric characters
  IF NOT W_AMOUNT_C CO '0123456789# '.
    RAISE NOT_NUMERIC.
  ENDIF.
* Convert # to decimal point
  TRANSLATE W_AMOUNT_C USING '#.'.
* Remove spaces
  CONDENSE W_AMOUNT_C NO-GAPS.
*
* Calculate amount
  W_AMOUNT_F = W_AMOUNT_C.
* Determine divisor
  SELECT SINGLE * FROM  TCURX
         WHERE  CURRKEY  = I_CURRENCY_CODE.
  IF SY-SUBRC <> 0.
    W_CURRDEC = 2.
    W_DIVIDER = 1.
  ELSE.
    W_CURRDEC = TCURX-CURRDEC.
    W_DIVIDER = 10 ** ( 2 - TCURX-CURRDEC ).
  ENDIF.

* Calculate packed amount
  IF W_DIVIDER = 1.
    W_AMOUNT_P = W_AMOUNT_F.
  ELSE.
    W_AMOUNT_P = W_AMOUNT_F / W_DIVIDER.
  ENDIF.
*
  E_AMOUNT = W_AMOUNT_P.

ENDFUNCTION.