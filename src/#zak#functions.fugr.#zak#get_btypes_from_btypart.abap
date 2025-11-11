FUNCTION /ZAK/GET_BTYPES_FROM_BTYPART.
*"----------------------------------------------------------------------
*"* Local interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPART) TYPE  /ZAK/BTYPART
*"  TABLES
*"      T_BTYPE STRUCTURE  RANGE_C10 OPTIONAL
*"      T_/ZAK/BEVALL STRUCTURE  /ZAK/BEVALL OPTIONAL
*"  EXCEPTIONS
*"      ERROR_BTYPE
*"----------------------------------------------------------------------

  DATA L_BTYPE TYPE /ZAK/BTYPE.

* Determine all declaration types
  SELECT BTYPE INTO L_BTYPE
               FROM /ZAK/BEVALL
              WHERE BUKRS   EQ I_BUKRS
                AND BTYPART EQ I_BTYPART.

    M_DEF T_BTYPE 'I' 'EQ' L_BTYPE SPACE.
  ENDSELECT.
  IF SY-SUBRC NE 0.
    MESSAGE E114(/ZAK/ZAK) RAISING ERROR_BTYPE.
*   Declaration type determination error!
  ELSE.
    SORT T_BTYPE.
    DELETE ADJACENT DUPLICATES FROM T_BTYPE.
    SELECT * INTO TABLE T_/ZAK/BEVALL
             FROM /ZAK/BEVALL
            WHERE BUKRS  EQ I_BUKRS
              AND BTYPE  IN T_BTYPE.
  ENDIF.

ENDFUNCTION.