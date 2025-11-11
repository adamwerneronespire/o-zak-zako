*&---------------------------------------------------------------------*
*&      Form  check_xls
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_XLS  text
*----------------------------------------------------------------------*
FORM CHECK_XLS USING    $W_XLS TYPE ALSMEX_TABLINE
                        $I_BUKRS LIKE T001-BUKRS
                        $I_CDV
*++BG 2006.04.10
*              CHANGING $CHECK_TAB TYPE DD03P
                        $CHECK_TAB TYPE DD03P
*--BG 2006.04.10
                        .

  DATA: L_SAKNR LIKE SKB1-SAKNR.
*++BG 2009.03.27
  DATA  L_LENGTH TYPE I.
*--BG 2009.03.27
* automatikus ellenörzés a konvertálási rutin alapján periódus!
  IF $CHECK_TAB-CONVEXIT EQ 'PERI'
     AND NOT $W_XLS-VALUE IS INITIAL.
    CLEAR W_RETURN.
    CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
      EXPORTING
        INPUT            = $W_XLS-VALUE
        NO_MESSAGE       = 'X'
     IMPORTING
*    OUTPUT           =
        RETURN           = W_RETURN.

    $CHECK_TAB-REPTEXT = W_RETURN-MESSAGE.
  ENDIF.

* főkönyvi szám ellenörzése
  IF $CHECK_TAB-ROLLNAME EQ 'SAKNR'
     AND NOT $W_XLS-VALUE IS INITIAL  .
    CLEAR L_SAKNR.
*++BG 2009.03.27
*   Meghatározzuk a mező hosszát
    L_LENGTH = STRLEN(  $W_XLS-VALUE ).
    IF L_LENGTH < 10.
*--BG 2009.03.27
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = $W_XLS-VALUE
        IMPORTING
          OUTPUT = L_SAKNR.
*++BG 2009.03.27
    ELSE.
      L_SAKNR = $W_XLS-VALUE.
    ENDIF.
*--BG 2009.03.27
*++S4HANA#01.
*    SELECT SINGLE * FROM SKB1
     SELECT SINGLE COUNT(*) FROM SKB1    "#EC CI_DB_OPERATION_OK[2431747]
*--S4HANA#01.
                  WHERE BUKRS  EQ $I_BUKRS AND
                        SAKNR  EQ L_SAKNR.
    IF SY-SUBRC NE 0.
      $CHECK_TAB-REPTEXT = 'Ismeretlen főkönyvi szám!'.
    ENDIF.
  ENDIF.
* kötelező mezők ellenörzése!
  IF $W_XLS-VALUE IS INITIAL.
*    CASE $CHECK_TAB-ROLLNAME.
*      WHEN 'SPBUP'       OR
*           'NATSL'       OR
*           'GESCH'       OR
*           'PAD_CNAME'   OR
*           '/ZAK/LAKCIM'  OR
*           '/ZAK/ADOAZON' OR
*           'DMBTR'       OR
*           'HWBAS'       OR
*           'DMBTR'.
*        $CHECK_TAB-REPTEXT = 'Mező megadása kötelező'.
*    ENDCASE.
  ENDIF.
*  mező típus ellenörzése, tartalmi ellenörzés
  CASE $CHECK_TAB-ROLLNAME.
*++BG 2006.04.10
** adószám ellenörzése
*    WHEN '/ZAK/ADOAZON'.
*      IF NOT $I_CDV IS INITIAL.
*        CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*             EXPORTING
*                  INPUT  = $W_XLS-VALUE
*             IMPORTING
*                  RETURN = $CHECK_TAB-REPTEXT.
*      ENDIF.
** adószám ellenörzése
*    WHEN '/ZAK/ADOSZAM'.
*      IF NOT $I_CDV IS INITIAL.
*        CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*             EXPORTING
*                  INPUT  = $W_XLS-VALUE
*             IMPORTING
*                  RETURN = $CHECK_TAB-REPTEXT.
*      ENDIF.
    WHEN '/ZAK/ADOAZON' OR '/ZAK/ADOSZAM'.
*   Adószám átalakítás '-' nélkülire
      CALL FUNCTION '/ZAK/CONV_ADOAZON'
        EXPORTING
          INPUT  = $W_XLS-VALUE
        IMPORTING
          OUTPUT = $W_XLS-VALUE.
*++0003 2008.12.11 BG (Fmc)
*     Az adószám ellenőrzés áthelyezésre került, mert kell hozzá
*     a születési év is:
*      IF NOT $I_CDV IS INITIAL.
*        CALL FUNCTION '/ZAK/READ_ADOAZON_EXIT'
*             EXPORTING
*                  INPUT  = $W_XLS-VALUE
*             IMPORTING
*                  RETURN = $CHECK_TAB-REPTEXT.
*      ENDIF.
*--0003 2008.12.11 BG (Fmc)
  ENDCASE.
*--BG 2006.04.10
*
  CASE $CHECK_TAB-INTTYPE.
* csak numerikus lehet
    WHEN 'N' .
      IF NOT $W_XLS-VALUE CO '-0123456789., '.
        $CHECK_TAB-REPTEXT = 'Csak numerikus lehet!'.
      ENDIF.
* csak érték lehet
    WHEN 'P'.
      IF NOT $W_XLS-VALUE CO '-0123456789., '.
        $CHECK_TAB-REPTEXT = 'Csak numerikus lehet!'.
      ENDIF.
  ENDCASE.

ENDFORM.                    " check_xls
*&---------------------------------------------------------------------*
*&      Form  APPEND_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_(V_TABL)  text
*----------------------------------------------------------------------*
FORM APPEND_TAB USING    $AS.
  WRITE:/ $AS.
ENDFORM.                    " APPEND_TAB
