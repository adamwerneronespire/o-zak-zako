FUNCTION-POOL /ZAK/GET_PACK.                "MESSAGE-ID ..

* INCLUDE /ZAK/LGET_PACKD...                 " Local class definition
*++1765 #13.
  DATA L_AMOUNT_E   TYPE BAPICURR_D.
  DATA L_AMOUNT_I   TYPE BAPICURR_D.

  DEFINE M_CONV_CURR_EXTERNAL.
    IF NOT &1 IS INITIAL.
      CLEAR: L_AMOUNT_E, L_AMOUNT_I.
      L_AMOUNT_I = &1.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          CURRENCY                   = &2
          AMOUNT_INTERNAL            = L_AMOUNT_I
        IMPORTING
          AMOUNT_EXTERNAL            = L_AMOUNT_E
*          RETURN                     =
                .
      &1 = L_AMOUNT_E.
    ENDIF.
  END-OF-DEFINITION.
*--1765 #13.
