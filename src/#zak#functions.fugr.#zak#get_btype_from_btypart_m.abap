FUNCTION /ZAK/GET_BTYPE_FROM_BTYPART_M.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPART) TYPE  /ZAK/BTYPART
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_MONAT) TYPE  MONAT OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_BTYPE) TYPE  /ZAK/BTYPE
*"  TABLES
*"      T_BTYPES TYPE  /ZAK/T_BTYPE
*"  EXCEPTIONS
*"      ERROR_MONAT
*"      ERROR_BTYPE
*"----------------------------------------------------------------------

  DATA V_DATUM LIKE SY-DATUM.

* Hónap ellenőrzése
  IF NOT I_MONAT IS INITIAL.
    IF NOT I_MONAT BETWEEN '01' AND '12'.
      MESSAGE E110(/ZAK/ZAK) WITH I_MONAT RAISING ERROR_MONAT.
*   Hónap megadás hiba! (&)
    ENDIF.


*Időpont meghatározása
    V_DATUM(4)   = I_GJAHR.
    V_DATUM+4(2) = I_MONAT.
    V_DATUM+6(2) = 01.


* Hónap utolsó napjának meghatározása
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
         EXPORTING
              DAY_IN            = V_DATUM
         IMPORTING
              LAST_DAY_OF_MONTH = V_DATUM.


    SELECT BTYPE INTO E_BTYPE
                        UP TO 1 ROWS
                        FROM /ZAK/BEVALL
                       WHERE BUKRS EQ I_BUKRS
                         AND DATBI GE V_DATUM
                         AND DATAB LE V_DATUM
                         AND BTYPART EQ I_BTYPART
*++S4HANA#01.
      ORDER BY PRIMARY KEY.
*--S4HANA#01.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      MESSAGE E114(/ZAK/ZAK) RAISING ERROR_BTYPE.
*   Bevallás típus meghatározás hiba!
    ENDIF.

* Nincs év-hónap megadva
  ELSE.

    SELECT BTYPE INTO TABLE T_BTYPES
                        FROM /ZAK/BEVALL
                       WHERE BUKRS EQ I_BUKRS
                         AND BTYPART EQ I_BTYPART.
    SORT T_BTYPES.
    DELETE ADJACENT DUPLICATES FROM T_BTYPES.

    IF NOT T_BTYPES[] IS INITIAL.
      READ TABLE T_BTYPES INDEX 1.
      IF SY-SUBRC = 0.
        E_BTYPE = T_BTYPES.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
