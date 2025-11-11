FUNCTION /ZAK/GET_BTYPE_FROM_BTYPART.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPART) TYPE  /ZAK/BTYPART
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_MONAT) TYPE  MONAT
*"  EXPORTING
*"     VALUE(E_BTYPE) TYPE  /ZAK/BTYPE
*"  EXCEPTIONS
*"      ERROR_MONAT
*"      ERROR_BTYPE
*"----------------------------------------------------------------------

  DATA V_DATUM LIKE SY-DATUM.
*++PTGSZLAA #02. 2014.03.05
  DATA: L_WEEK TYPE KWEEK.

  IF I_BTYPART EQ C_BTYPART_PTG.
    CONCATENATE I_GJAHR I_MONAT INTO L_WEEK.
    CALL FUNCTION 'WEEK_GET_FIRST_DAY'
      EXPORTING
        WEEK = L_WEEK
      IMPORTING
        DATE = V_DATUM
*      EXCEPTIONS
*       WEEK_INVALID       = 1
*       OTHERS             = 2
      .
    IF SY-SUBRC <> 0.
      CLEAR V_DATUM.
    ELSE.
      ADD 6 TO V_DATUM.
    ENDIF.
  ELSE.
*--PTGSZLAA #02. 2014.03.05
* Hónap ellenőrzése
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
        LAST_DAY_OF_MONTH = V_DATUM
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    IF SY-SUBRC <> 0.
      MESSAGE E114(/ZAK/ZAK) RAISING ERROR_BTYPE.
*   Bevallás típus meghatározás hiba!
    ENDIF.
*++PTGSZLAA #02. 2014.03.05
  ENDIF.
*--PTGSZLAA #02. 2014.03.05


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

ENDFUNCTION.
