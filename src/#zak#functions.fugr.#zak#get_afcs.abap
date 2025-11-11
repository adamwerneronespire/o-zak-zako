FUNCTION /ZAK/GET_AFCS.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     VALUE(I_DATUM) TYPE  DATUM
*"  EXPORTING
*"     VALUE(E_BUKCS) TYPE  /ZAK/BUKCS
*"  TABLES
*"      T_BUKRS STRUCTURE  /ZAK/AFACS_BUKRS OPTIONAL
*"----------------------------------------------------------------------
  DATA LS_AFACS TYPE /ZAK/AFACS.

  CHECK NOT I_BUKRS IS INITIAL AND
        NOT I_BTYPE IS INITIAL AND
        NOT I_DATUM IS INITIAL.

*Csoport vállalat meghatározása
*++S4HANA#01.
*SELECT SINGLE BUKCS INTO E_BUKCS
*                    FROM /ZAK/AFACS
  SELECT BUKCS INTO E_BUKCS
                    FROM /ZAK/AFACS UP TO 1 ROWS
*--S4HANA#01.
                   WHERE BUKRS EQ I_BUKRS
                     AND BTYPE EQ I_BTYPE
                     AND DATBI GE I_DATUM
                     AND DATAB LE I_DATUM
*++S4HANA#01.
                   ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.

  IF SY-SUBRC EQ 0.
    SELECT BUKRS INTO CORRESPONDING FIELDS OF TABLE T_BUKRS
                 FROM /ZAK/AFACS
                WHERE BUKCS EQ E_BUKCS
                  AND BTYPE EQ I_BTYPE
                  AND DATBI GE I_DATUM
                  AND DATAB LE I_DATUM.
  ENDIF.

ENDFUNCTION.
