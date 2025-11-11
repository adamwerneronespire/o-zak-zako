FUNCTION /ZAK/CONV_ADOAZON.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(INPUT)
*"  EXPORTING
*"     VALUE(OUTPUT)
*"----------------------------------------------------------------------

  OUTPUT = INPUT.
  TRANSLATE OUTPUT USING '- '.
  CONDENSE OUTPUT NO-GAPS.

ENDFUNCTION.
