*----------------------------------------------------------------------*
***INCLUDE /ZAK/LSET_PERIODF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_DAY_OF_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_GJAHR  text
*      -->P_I_MONAT  text
*      <--P_V_LAST_DATE  text
*----------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_PERIOD USING    $GJAHR
                                      $MONAT
                              CHANGING V_LAST_DATE.

  DATA: L_DATE1 TYPE DATUM,
        L_DATE2 TYPE DATUM.
  CLEAR V_LAST_DATE.

  CONCATENATE $GJAHR $MONAT '01' INTO L_DATE1.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
       EXPORTING
            DAY_IN            = L_DATE1
       IMPORTING
            LAST_DAY_OF_MONTH = L_DATE2
       EXCEPTIONS
            DAY_IN_NO_DATE    = 1
            OTHERS            = 2.

  IF SY-SUBRC = 0.
    V_LAST_DATE = L_DATE2.
  ENDIF.
ENDFORM.                    " GET_LAST_DAY_OF_PERIOD
