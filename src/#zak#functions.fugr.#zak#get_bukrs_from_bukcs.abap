FUNCTION /ZAK/GET_BUKRS_FROM_BUKCS.
*"----------------------------------------------------------------------
*"* Local interface:
*"  IMPORTING
*"     VALUE(I_BUKCS) TYPE  /ZAK/BUKCS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     VALUE(I_DATUM) TYPE  DATUM
*"  EXPORTING
*"     VALUE(E_BUKCS_FLAG) TYPE  XFELD
*"  TABLES
*"      T_BUKRS STRUCTURE  /ZAK/AFACS_BUKRS OPTIONAL
*"----------------------------------------------------------------------
REFRESH T_BUKRS.
CLEAR E_BUKCS_FLAG.

CHECK NOT I_BUKCS IS INITIAL AND
      NOT I_BTYPE IS INITIAL AND
      NOT I_DATUM IS INITIAL.

  SELECT BUKRS INTO CORRESPONDING FIELDS OF TABLE T_BUKRS
               FROM /ZAK/AFACS
              WHERE BUKCS EQ I_BUKCS
                AND BTYPE EQ I_BTYPE
                AND DATBI GE I_DATUM
                AND DATAB LE I_DATUM.
  IF SY-SUBRC EQ 0.
    E_BUKCS_FLAG = 'X'.
  ENDIF.

ENDFUNCTION.
