FUNCTION /ZAK/CONV_ADOAZON.
*"----------------------------------------------------------------------
*"* Local interface:
*"  IMPORTING
*"     VALUE(INPUT)
*"  EXPORTING
*"     VALUE(OUTPUT)
*"----------------------------------------------------------------------

  OUTPUT = INPUT.
  TRANSLATE OUTPUT USING '- '.
  CONDENSE OUTPUT NO-GAPS.

ENDFUNCTION.