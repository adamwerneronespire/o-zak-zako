FUNCTION /ZAK/GET_SEGM_FOR_BUKRS.
*"----------------------------------------------------------------------
*"* Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(E_SEGMENT) TYPE  FB_SEGMENT
*"----------------------------------------------------------------------

  CLEAR E_SEGMENT.
  IF NOT I_BUKRS IS INITIAL.
    SELECT SINGLE SEGMENT INTO E_SEGMENT
           FROM /ZAK/BUKRS_SEGM
          WHERE BUKRS EQ I_BUKRS.
  ENDIF.

ENDFUNCTION.
