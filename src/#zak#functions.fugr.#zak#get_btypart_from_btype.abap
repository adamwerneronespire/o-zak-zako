FUNCTION /ZAK/GET_BTYPART_FROM_BTYPE.
*"----------------------------------------------------------------------
*"* Local interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"  EXPORTING
*"     REFERENCE(E_BTYPART) TYPE  /ZAK/BTYPART
*"  EXCEPTIONS
*"      ERROR_IMP_PAR
*"----------------------------------------------------------------------


  IF I_BUKRS IS INITIAL OR I_BTYPE IS INITIAL.
    MESSAGE E197(/ZAK/ZAK) RAISING ERROR_IMP_PAR.
*   Missing import parameter when determining declaration type (company or type).
  ENDIF.


  READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY BUKRS = I_BUKRS
                                                     BTYPE = I_BTYPE.
  IF SY-SUBRC EQ 0.
    MOVE W_/ZAK/BEVALL-BTYPART TO E_BTYPART.
  ELSE.
*++S4HANA#01.
*    SELECT SINGLE * INTO W_/ZAK/BEVALL
*                    FROM /ZAK/BEVALL
    SELECT * INTO W_/ZAK/BEVALL
              FROM /ZAK/BEVALL UP TO 1 ROWS
*--S4HANA#01.
              WHERE BUKRS EQ I_BUKRS
                AND BTYPE EQ I_BTYPE
*++S4HANA#01.
              ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.

    MOVE W_/ZAK/BEVALL-BTYPART TO E_BTYPART.
    APPEND W_/ZAK/BEVALL TO I_/ZAK/BEVALL.
  ENDIF.

ENDFUNCTION.
