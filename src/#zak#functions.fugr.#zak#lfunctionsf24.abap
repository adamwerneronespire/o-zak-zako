*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF24.
*----------------------------------------------------------------------*
*++2465 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_2465
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_T_AFA_SZLA_SUM  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*      -->P_W_/ZAK/BEVALL_OMREL  text
*      -->P_W_/ZAK/BEVALL_KIUTALAS  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_AFA_2465  TABLES T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                T_BEVALLB STRUCTURE /ZAK/BEVALLB
                                T_ADOAZON STRUCTURE /ZAK/ONR_ADOAZON
                                T_AFA_SZLA_SUM STRUCTURE /ZAK/AFA_SZLASUM
                          USING $DATE
                                $INDEX
                                $OMREL
                                $KIUTALAS.

  DATA: L_SUM            LIKE /ZAK/BEVALLO-FIELD_N,
        L_SUM_A0ID0001CA LIKE /ZAK/BEVALLO-FIELD_N,
        L_SUM_SAVE       LIKE /ZAK/BEVALLO-FIELD_N,
        L_KAMAT          LIKE /ZAK/BEVALLO-FIELD_N,
        L_ABEV_SUM       LIKE /ZAK/BEVALLO-FIELD_N.
  DATA: L_KAM_KEZD  TYPE DATUM,
        L_KAM_VEG   TYPE DATUM,
        L_ROUND(20) TYPE C,
        L_TABIX     LIKE SY-TABIX,
        L_UPD.

  DATA: LW_AFA_SZLA_SUM TYPE /ZAK/AFA_SZLASUM.
  DATA: L_LWSTE_SUM TYPE /ZAK/LWSTE.
  DATA: L_OLWSTE TYPE /ZAK/LWSTE.
  DATA: L_AMOUNT_EXTERNAL LIKE  BAPICURR-BAPICURR.
  TYPES: BEGIN OF LT_ADOAZ_SZAMLASZA_SUM,
           ADOAZON TYPE /ZAK/ADOAZON,
           LWSTE   TYPE /ZAK/LWSTE,
         END OF LT_ADOAZ_SZAMLASZA_SUM.
  DATA   LI_ADOAZ_SZAMLASZA_SUM TYPE TABLE OF LT_ADOAZ_SZAMLASZA_SUM.
  DATA   LW_ADOAZ_SZAMLASZA_SUM TYPE LT_ADOAZ_SZAMLASZA_SUM.
************************************************************************
* Special ABEV fields

******************************************************** VAT only normal

  DATA: W_SZ TYPE /ZAK/BEVALLB.

  RANGES LR_ABEVAZ FOR /ZAK/BEVALLO-ABEVAZ.
* Populating calculated fields
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0084CA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0AF001A   SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0AF002A   SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0AF005A   SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0AF006A   SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0082BA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0083BA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0084BA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0085BA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0085CA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0IC001A   SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0086BA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0DD0086CA SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0AI002A   SPACE.

  RANGES LR_MONAT FOR /ZAK/AFA_SZLASUM-MONAT.
  DATA L_SUM_NOT_VALID TYPE XFELD.

  SORT T_BEVALLB BY ABEVAZ  .

  LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB WHERE ABEVAZ IN LR_ABEVAZ.
    CLEAR : L_SUM,W_/ZAK/BEVALLO.
* this is the line that needs to be modified!
    READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
    WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
    V_TABIX = SY-TABIX .
    CLEAR: W_/ZAK/BEVALLO-FIELD_N,
           W_/ZAK/BEVALLO-FIELD_NR,
           W_/ZAK/BEVALLO-FIELD_NRK.

    CASE W_/ZAK/BEVALLB-ABEVAZ.
*84.C. Amount of tax to be paid (data of line 83, if unsigned)
      WHEN C_ABEVAZ_A0DD0084CA.
        L_UPD = 'X'. "You always have to update, because if the amount changes, you have to empty it
        CLEAR L_SUM.
        READ TABLE T_BEVALLO INTO W_SUM
        WITH KEY ABEVAZ = C_ABEVAZ_A0DD0083CA.
        IF SY-SUBRC = 0.
          IF W_SUM-FIELD_N > 0.
            L_SUM = W_SUM-FIELD_NRK.
            W_/ZAK/BEVALLO-FIELD_N = L_SUM.
          ELSE.
            CLEAR W_/ZAK/BEVALLO-FIELD_N.
          ENDIF.
*          L_UPD = 'X'.
        ENDIF.
*00C Declaration period from
      WHEN C_ABEVAZ_A0AF001A.
* Monthly
        IF W_/ZAK/BEVALL-BIDOSZ = 'H'.
          L_KAM_KEZD = $DATE.
          L_KAM_KEZD+6(2) = '01'.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
* Annual
        ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
          L_KAM_KEZD = $DATE.
          L_KAM_KEZD+4(4) = '0101'.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
* Quarterly
        ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'N'.

          L_KAM_KEZD = $DATE.
          IF L_KAM_KEZD+4(2) >= '01' AND
             L_KAM_KEZD+4(2) <= '03'.

            L_KAM_KEZD+4(4) = '0101'.
          ENDIF.

          IF L_KAM_KEZD+4(2) >= '04' AND
             L_KAM_KEZD+4(2) <= '06'.

            L_KAM_KEZD+4(4) = '0401'.
          ENDIF.

          IF L_KAM_KEZD+4(2) >= '07' AND
             L_KAM_KEZD+4(2) <= '09'.

            L_KAM_KEZD+4(4) = '0701'.
          ENDIF.


          IF L_KAM_KEZD+4(2) >= '10' AND
             L_KAM_KEZD+4(2) <= '12'.

            L_KAM_KEZD+4(4) = '1001'.
          ENDIF.

          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
*++2465 #03.
        ELSEIF  W_/ZAK/BEVALL-BIDOSZ = 'S'.
*The beginning of the special period must be determined
          SELECT SINGLE DATAB INTO L_KAM_KEZD
                          FROM /ZAK/BEVALL
                         WHERE BUKRS EQ W_/ZAK/BEVALLO-BUKRS
                           AND BTYPE EQ W_/ZAK/BEVALLO-BTYPE
                           AND DATBI GE $DATE
                           AND DATAB LE $DATE.
          IF SY-SUBRC EQ 0.
            L_KAM_KEZD+6(2) = '01'.
            W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
          ENDIF.
*--2465 #03.
        ELSE.
          L_KAM_KEZD = $DATE.
          L_KAM_KEZD+6(2) = '01'.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
        ENDIF.

        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*00C Declaration period until
      WHEN C_ABEVAZ_A0AF002A.
        W_/ZAK/BEVALLO-FIELD_C = $DATE.
        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*00C Nature of declaration
      WHEN C_ABEVAZ_A0AF005A.
        IF W_/ZAK/BEVALLO-ZINDEX GE '001'.
          W_/ZAK/BEVALLO-FIELD_C = 'O'.
          MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
        ENDIF.
*04 (O) Mark repeated self-check (x)
      WHEN C_ABEVAZ_A0IC001A.
*ZINDEX > '001' --> 'X' "repeated self-check
        IF W_/ZAK/BEVALLO-ZINDEX > '001'.
          W_/ZAK/BEVALLO-FIELD_C = 'X'.
          MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
        ENDIF.
*00C Declaration frequency /H-monthly, N-quarterly, E-yearly
      WHEN C_ABEVAZ_A0AF006A.
*++2465 #03.
        IF W_/ZAK/BEVALL-BIDOSZ NE 'S'.
*--2465 #03.
          W_/ZAK/BEVALLO-FIELD_C = W_/ZAK/BEVALL-BIDOSZ.
          MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*++2465 #03.
        ENDIF.
*--2465 #03.
*82.B. The amount of the reducing item that can be calculated from the previous period (previous year
      WHEN C_ABEVAZ_A0DD0082BA.
        PERFORM SET_BEVALLO USING C_ABEVAZ_A0DD0082CA
                            CHANGING W_/ZAK/BEVALLO.
        L_UPD = 'X'.
*83.C. The total amount of tax payable in the subject period.
      WHEN C_ABEVAZ_A0DD0083BA.
        PERFORM SET_BEVALLO USING C_ABEVAZ_A0DD0083CA
                            CHANGING W_/ZAK/BEVALLO.
        L_UPD = 'X'.
*84.B. Amount of tax to be paid (data of line 83, if unsigned)
      WHEN C_ABEVAZ_A0DD0084BA.
        PERFORM SET_BEVALLO USING C_ABEVAZ_A0DD0084CA
                            CHANGING W_/ZAK/BEVALLO.
        L_UPD = 'X'.
*85.B. The amount of tax that can be reclaimed (line 83 with a negative sign, ...
      WHEN C_ABEVAZ_A0DD0085BA.
        PERFORM SET_BEVALLO USING C_ABEVAZ_A0DD0085CA
                            CHANGING W_/ZAK/BEVALLO.
        L_UPD = 'X'.
*86.B. Amount of claim that can be carried over to the next period
      WHEN C_ABEVAZ_A0DD0086BA.
        PERFORM SET_BEVALLO USING C_ABEVAZ_A0DD0086CA
                            CHANGING W_/ZAK/BEVALLO.
        L_UPD = 'X'.
*00F year month day
      WHEN C_ABEVAZ_A0AI002A.
        W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.
        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*85.C. The amount of tax that can be reclaimed (line 83 with a negative sign...
      WHEN  C_ABEVAZ_A0DD0085CA.
        L_UPD = 'X'. "You always have to update, because if the amount changes, you have to empty it
        READ TABLE T_BEVALLO INTO W_SUM
             WITH KEY ABEVAZ = C_ABEVAZ_A0DD0083CA.
        IF SY-SUBRC EQ 0 AND W_SUM-FIELD_N < 0.
          CLEAR L_SUM.
          L_SUM = W_SUM-FIELD_NRK.
          READ TABLE T_BEVALLO INTO W_SUM
               WITH KEY ABEVAZ = C_ABEVAZ_A0AG018A.
          IF SY-SUBRC EQ 0 AND NOT W_SUM-FIELD_C IS INITIAL.
            W_/ZAK/BEVALLO-FIELD_N = ABS( L_SUM ).
*
          ELSEIF SY-SUBRC EQ 0 AND W_SUM-FIELD_C IS INITIAL.
            CLEAR W_/ZAK/BEVALLO-FIELD_N.
*            L_UPD = 'X'.
          ENDIF.
        ENDIF.
*Carried over to next period
      WHEN  C_ABEVAZ_A0DD0086CA.
        L_UPD = 'X'. "You always have to update, because if the amount changes, you have to empty it
        READ TABLE T_BEVALLO INTO W_SUM
             WITH KEY ABEVAZ = C_ABEVAZ_A0DD0083CA.
        IF SY-SUBRC EQ 0 AND W_SUM-FIELD_N < 0.
          CLEAR L_SUM.
          L_SUM = W_SUM-FIELD_NRK.
          READ TABLE T_BEVALLO INTO W_SUM
               WITH KEY ABEVAZ = C_ABEVAZ_A0AG018A.
          IF SY-SUBRC EQ 0 AND NOT W_SUM-FIELD_C IS INITIAL.
            CLEAR W_/ZAK/BEVALLO-FIELD_N.
*            L_UPD = 'X'.
          ELSEIF SY-SUBRC EQ 0 AND W_SUM-FIELD_C IS INITIAL.
            W_/ZAK/BEVALLO-FIELD_N = ABS( L_SUM ).
*            L_UPD = 'X'.
          ENDIF.
        ENDIF.
    ENDCASE.
*fill in all numerical values ​​for calculated fields!
*the procedure for forming an amount is as follows:
* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
*then apply the default rounding rule!
    IF NOT W_/ZAK/BEVALLB-COLLECT IS INITIAL AND
       L_UPD EQ 'X'.
      CLEAR L_ROUND.
      PERFORM CALC_FIELD_NRK USING W_/ZAK/BEVALLO-FIELD_N
                  W_/ZAK/BEVALLB-ROUND
                  W_/ZAK/BEVALLO-WAERS
         CHANGING W_/ZAK/BEVALLO-FIELD_NR
                  W_/ZAK/BEVALLO-FIELD_NRK.
      MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
      CLEAR: L_SUM,L_UPD.
    ENDIF.
    CLEAR: L_UPD,L_SUM,L_ROUND.
  ENDLOOP.

*Calculation of dependent fields
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0AG016A SPACE.

  LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB WHERE ABEVAZ IN LR_ABEVAZ.
    CLEAR : L_SUM,W_/ZAK/BEVALLO.
*this line must be modified!
    READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
    WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
    V_TABIX = SY-TABIX .
    CLEAR: W_/ZAK/BEVALLO-FIELD_N,
           W_/ZAK/BEVALLO-FIELD_NR,
           W_/ZAK/BEVALLO-FIELD_NRK.


    CASE W_/ZAK/BEVALLB-ABEVAZ.

*00D I do not request a referral
      WHEN C_ABEVAZ_A0AG016A.
        IF NOT $KIUTALAS IS INITIAL.
          READ TABLE T_BEVALLO INTO W_SUM
*                WITH KEY ABEVAZ = C_ABEVAZ_A0DD0085CA.
               WITH KEY ABEVAZ = $KIUTALAS.
          IF SY-SUBRC EQ 0 AND W_SUM-FIELD_N NE 0.
            W_/ZAK/BEVALLO-FIELD_C = C_X.
            MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
          ELSEIF SY-SUBRC EQ 0 AND W_SUM-FIELD_N EQ 0.
            CLEAR W_/ZAK/BEVALLO-FIELD_C.
            MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
          ENDIF.
        ENDIF.
    ENDCASE.
*fill in all numerical values ​​for calculated fields!
*the procedure for forming an amount is as follows:
* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk
*then apply the default rounding rule!
    IF NOT W_/ZAK/BEVALLB-COLLECT IS INITIAL AND
       L_UPD EQ 'X'.
      CLEAR L_ROUND.
      PERFORM CALC_FIELD_NRK USING W_/ZAK/BEVALLO-FIELD_N
                  W_/ZAK/BEVALLB-ROUND
                  W_/ZAK/BEVALLO-WAERS
         CHANGING W_/ZAK/BEVALLO-FIELD_NR
                  W_/ZAK/BEVALLO-FIELD_NRK.
      MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
      CLEAR: L_SUM,L_UPD.
    ENDIF.
    CLEAR: L_UPD,L_SUM,L_ROUND.

  ENDLOOP.

*Summary report Calculation of fields below the VAT value limit
  IF NOT $OMREL IS INITIAL.
*Value limit
    L_AMOUNT_EXTERNAL = W_/ZAK/BEVALL-OLWSTE.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        CURRENCY             = C_HUF
        AMOUNT_EXTERNAL      = L_AMOUNT_EXTERNAL
        MAX_NUMBER_OF_DIGITS = 20
      IMPORTING
        AMOUNT_INTERNAL      = L_OLWSTE
*       RETURN               =
      .
*Month treatment
    REFRESH LR_MONAT.
    IF W_/ZAK/BEVALL-BIDOSZ = 'H'.
      M_DEF LR_MONAT 'I' 'EQ' $DATE+4(2) SPACE.
    ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'N'.
      CASE $DATE+4(2).
        WHEN '03'.
          M_DEF LR_MONAT 'I' 'BT' '01' '03'.
        WHEN '06'.
          M_DEF LR_MONAT 'I' 'BT' '03' '06'.
        WHEN '09'.
          M_DEF LR_MONAT 'I' 'BT' '06' '09'.
        WHEN '12'.
          M_DEF LR_MONAT 'I' 'BT' '10' '12'.
      ENDCASE.
    ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
      M_DEF LR_MONAT 'I' 'BT' '01' '12'.
    ENDIF.
*Determination of amount per tax number, per invoice
    LOOP AT T_AFA_SZLA_SUM INTO LW_AFA_SZLA_SUM
                          WHERE MLAP   IS INITIAL
                            AND NYLAPAZON(3) = C_NYLAPAZON_M02.
*It must only be aggregated within the month
      CHECK LW_AFA_SZLA_SUM-GJAHR EQ $DATE(4) AND
            LW_AFA_SZLA_SUM-MONAT IN LR_MONAT.
      CLEAR LW_ADOAZ_SZAMLASZA_SUM.
      LW_ADOAZ_SZAMLASZA_SUM-ADOAZON    = LW_AFA_SZLA_SUM-ADOAZON.
      LW_ADOAZ_SZAMLASZA_SUM-LWSTE      = LW_AFA_SZLA_SUM-LWSTE.
      COLLECT LW_ADOAZ_SZAMLASZA_SUM INTO LI_ADOAZ_SZAMLASZA_SUM.
    ENDLOOP.
*Determination of value limit
    LOOP AT LI_ADOAZ_SZAMLASZA_SUM INTO LW_ADOAZ_SZAMLASZA_SUM.
*If it is listed on sheet M or the value limit is greater than the set one
      READ TABLE T_AFA_SZLA_SUM TRANSPORTING NO FIELDS
                 WITH KEY ADOAZON = LW_ADOAZ_SZAMLASZA_SUM-ADOAZON
                          NYLAPAZON(3) = C_NYLAPAZON_M02
                          MLAP    = 'X'.

      IF SY-SUBRC NE 0 AND LW_ADOAZ_SZAMLASZA_SUM-LWSTE < L_OLWSTE.
        CONTINUE.
      ENDIF.
*Filling filling of other calculated fields of main sheet M
      PERFORM CALC_ABEV_AFA_2465_M TABLES T_BEVALLO
                                          T_BEVALLB
                                   USING  LW_ADOAZ_SZAMLASZA_SUM-ADOAZON
                                          W_/ZAK/BEVALL.
    ENDLOOP.

*Management of calculated fields also on M flat fields
    FREE LI_ADOAZ_SZAMLASZA_SUM.
*Determination of amount per tax number, per invoice
    LOOP AT T_AFA_SZLA_SUM INTO LW_AFA_SZLA_SUM
                          WHERE NOT MLAP   IS INITIAL.
      LW_ADOAZ_SZAMLASZA_SUM-ADOAZON    = LW_AFA_SZLA_SUM-ADOAZON.
      COLLECT LW_ADOAZ_SZAMLASZA_SUM INTO LI_ADOAZ_SZAMLASZA_SUM.
    ENDLOOP.

    LOOP AT LI_ADOAZ_SZAMLASZA_SUM INTO LW_ADOAZ_SZAMLASZA_SUM.
*Filling filling of other calculated fields of main sheet M
      PERFORM CALC_ABEV_AFA_2465_M TABLES T_BEVALLO
                                          T_BEVALLB
                                   USING  LW_ADOAZ_SZAMLASZA_SUM-ADOAZON
                                          W_/ZAK/BEVALL.
    ENDLOOP.
  ENDIF.

************************************************************************
*calculation of self-check allowance
************************************************************************
  IF $INDEX NE '000'.
*if A0DD0084CA - A0DD0084BA > 0 then this value, otherwise 0
    LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB
      WHERE  ABEVAZ EQ     C_ABEVAZ_A0ID0001CA.
      CLEAR: L_SUM,L_SUM_A0ID0001CA.
      LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO
        WHERE  ABEVAZ EQ     C_ABEVAZ_A0DD0084BA  OR
               ABEVAZ EQ     C_ABEVAZ_A0DD0084CA.
        IF W_/ZAK/BEVALLO-ABEVAZ EQ C_ABEVAZ_A0DD0084BA.
          L_SUM = L_SUM - W_/ZAK/BEVALLO-FIELD_NRK.
        ELSE.
          L_SUM = L_SUM + W_/ZAK/BEVALLO-FIELD_NRK.
        ENDIF.
      ENDLOOP.
      IF L_SUM < 0 .
        CLEAR L_SUM.
      ENDIF.
      L_SUM_A0ID0001CA = L_SUM_A0ID0001CA + L_SUM.
      CLEAR L_SUM.
*(A0DD0086CA - A0DD0086BA) < 0 then the calculated value is minus
      LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO
        WHERE  ABEVAZ EQ     C_ABEVAZ_A0DD0086CA  OR
               ABEVAZ EQ     C_ABEVAZ_A0DD0086BA.
        IF W_/ZAK/BEVALLO-ABEVAZ EQ C_ABEVAZ_A0DD0086BA.
          L_SUM = L_SUM - W_/ZAK/BEVALLO-FIELD_NRK.
        ELSE.
          L_SUM = L_SUM + W_/ZAK/BEVALLO-FIELD_NRK.
        ENDIF.
      ENDLOOP.
      IF L_SUM > 0 .
        CLEAR L_SUM.
      ENDIF.
      L_SUM_A0ID0001CA = L_SUM_A0ID0001CA - L_SUM.
      CLEAR L_SUM.
*A0DD0085CA - A0DD0085BA < 0 then the calculated value is minus
      LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO
        WHERE  ABEVAZ EQ     C_ABEVAZ_A0DD0085CA  OR
               ABEVAZ EQ     C_ABEVAZ_A0DD0085BA.
        IF W_/ZAK/BEVALLO-ABEVAZ EQ C_ABEVAZ_A0DD0085BA.
          L_SUM = L_SUM - W_/ZAK/BEVALLO-FIELD_NRK.
        ELSE.
          L_SUM = L_SUM + W_/ZAK/BEVALLO-FIELD_NRK.
        ENDIF.
      ENDLOOP.
      IF L_SUM > 0 .
        CLEAR L_SUM.
      ENDIF.
      L_SUM_A0ID0001CA = L_SUM_A0ID0001CA - L_SUM.
      CLEAR L_SUM.
*If A0DD0082CA-A0DD0082BA < 0 then it must be reduced by this amount
*     az L_SUM_A0ID0001CA-at.
      READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
                           WITH KEY ABEVAZ = C_ABEVAZ_A0DD0082CA.
      IF SY-SUBRC EQ 0.
        L_SUM = W_/ZAK/BEVALLO-FIELD_NRK.
      ENDIF.

      READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
                           WITH KEY ABEVAZ = C_ABEVAZ_A0DD0082BA.
      IF SY-SUBRC EQ 0.
        L_SUM = L_SUM - W_/ZAK/BEVALLO-FIELD_NRK.
      ENDIF.

      IF L_SUM < 0.
        L_SUM_SAVE = ABS( L_SUM ).
        ADD L_SUM TO L_SUM_A0ID0001CA.
      ENDIF.

      IF L_SUM_A0ID0001CA < 0.
        ADD L_SUM_A0ID0001CA TO L_SUM_SAVE.
        CLEAR L_SUM_A0ID0001CA.
      ENDIF.
      READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
      WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
      V_TABIX = SY-TABIX .
      IF SY-SUBRC EQ 0.
        PERFORM CALC_FIELD_NRK USING L_SUM_A0ID0001CA
                    W_/ZAK/BEVALLB-ROUND
                    W_/ZAK/BEVALLO-WAERS
           CHANGING W_/ZAK/BEVALLO-FIELD_NR
                    W_/ZAK/BEVALLO-FIELD_NRK.
        W_/ZAK/BEVALLO-FIELD_N = L_SUM_A0ID0001CA.
        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
      ENDIF.
    ENDLOOP.

*determination of self-control allowance
*Calculation of ABEV A0ID0002CA based on A0ID0001CA, if the index is 2 or greater, then x1.5
    IF W_/ZAK/BEVALLO-ZINDEX NE '000'.

      READ TABLE T_BEVALLB INTO W_/ZAK/BEVALLB
                           WITH KEY ABEVAZ = C_ABEVAZ_A0ID0002CA.
      IF SY-SUBRC EQ 0.
        CLEAR L_SUM.
        READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
                             WITH KEY ABEVAZ = C_ABEVAZ_A0ID0001CA.
        IF SY-SUBRC = 0.
          L_SUM = W_/ZAK/BEVALLO-FIELD_NRK.
        ENDIF.
*period definition
        READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
                             WITH KEY ABEVAZ = C_ABEVAZ_23337.
        IF SY-SUBRC EQ 0 AND
        NOT W_/ZAK/BEVALLO-FIELD_C IS INITIAL .
*determining the deadline for calculating the allowance! the 104
*I don't need a tax for the /ZAK/ADONEM table key !!
          SELECT SINGLE FIZHAT INTO W_/ZAK/ADONEM-FIZHAT FROM /ZAK/ADONEM
                                WHERE BUKRS  EQ W_/ZAK/BEVALLO-BUKRS AND
                                                 ADONEM EQ C_ADONEM_104
                                                 .
          IF SY-SUBRC EQ 0.
*start date of allowance calculation
            CLEAR L_KAM_KEZD.
            L_KAM_KEZD = $DATE + 1 + W_/ZAK/ADONEM-FIZHAT.
*end date of allowance calculation in the character field of row 5299 above
            CLEAR L_KAM_VEG.
            CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
              EXPORTING
                INPUT  = W_/ZAK/BEVALLO-FIELD_C
              IMPORTING
                OUTPUT = L_KAM_VEG.
*allowance calculation
            PERFORM CALC_POTLEK USING    W_/ZAK/BEVALLO-BUKRS
                                         W_/ZAK/BEVALLO-ZINDEX
                                CHANGING L_KAM_KEZD
                                         L_KAM_VEG
                                         L_SUM
                                         L_KAMAT. " A0ID0001CA --> A0ID0002CA
            READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
                                 WITH KEY ABEVAZ = C_ABEVAZ_A0ID0002CA.
            V_TABIX = SY-TABIX.
            IF SY-SUBRC = 0.
              W_/ZAK/BEVALLO-FIELD_N = L_KAMAT.
              PERFORM CALC_FIELD_NRK USING L_KAMAT
                         W_/ZAK/BEVALLB-ROUND
                         W_/ZAK/BEVALLO-WAERS
                CHANGING W_/ZAK/BEVALLO-FIELD_NR
                         W_/ZAK/BEVALLO-FIELD_NRK.
*The value of the 0 flag must be handled in the form control
*              miatt:
              IF NOT W_/ZAK/BEVALLO-FIELD_N IS INITIAL AND
                 W_/ZAK/BEVALLO-FIELD_NRK IS INITIAL.
                W_/ZAK/BEVALLO-NULL_FLAG = 'X'.
              ENDIF.
              MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*If there is a value, A0ID0001CA must be corrected.
      IF NOT L_SUM_SAVE IS INITIAL.
        READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
        WITH KEY ABEVAZ = C_ABEVAZ_A0ID0001CA.
        V_TABIX = SY-TABIX .
        IF SY-SUBRC EQ 0.
          ADD L_SUM_SAVE TO W_/ZAK/BEVALLO-FIELD_N.
          READ TABLE T_BEVALLB INTO W_/ZAK/BEVALLB
               WITH KEY ABEVAZ = C_ABEVAZ_A0ID0001CA.
          IF SY-SUBRC EQ 0.
            PERFORM CALC_FIELD_NRK USING W_/ZAK/BEVALLO-FIELD_N
                        W_/ZAK/BEVALLB-ROUND
                        W_/ZAK/BEVALLO-WAERS
               CHANGING W_/ZAK/BEVALLO-FIELD_NR
                        W_/ZAK/BEVALLO-FIELD_NRK.
            MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*Account number management on the main page
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'A0AG015A' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'A0AG016A' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'A0AG017A' SPACE.
  PERFORM GET_SZAMLASZ_AFA TABLES T_BEVALLO
                                  LR_ABEVAZ
                           USING  'A0AG001A'  "bank kulcs
                                  'A0AG002A'  "invoice
                                  'A0AG003A'. "invoice

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_AFA_2465_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_LW_ADOAZ_SZAMLASZA_SUM_ADOAZON  text
*      -->P_W_/ZAK/BEVALL  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_AFA_2465_M  TABLES   $T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                    $T_BEVALLB STRUCTURE /ZAK/BEVALLB
                            USING   $ADOAZON
                                    $BEVALL    STRUCTURE /ZAK/BEVALL.

  DATA LW_BEVALLO   TYPE /ZAK/BEVALLO.
  DATA LW_ANALITIKA TYPE /ZAK/ANALITIKA.
  DATA L_NAME1 TYPE NAME1_GP.
  RANGES LR_MONAT FOR /ZAK/ANALITIKA-MONAT.
  DATA L_TEXT50 TYPE TEXT50.

*M0AC001A Tax number of the taxpayer, can be taken from: A0AE001A
  PERFORM GET_AFA_M_ABEVAZ TABLES $T_BEVALLO
                                  $T_BEVALLB
                           USING  C_ABEVAZ_M0AC001A
                                  C_ABEVAZ_A0AE001A
                                  $ADOAZON.
*M0AC003A Tax number of your legal predecessor, can be taken if it is not empty: from A0AE004A
  PERFORM GET_AFA_M_ABEVAZ TABLES $T_BEVALLO
                                  $T_BEVALLB
                           USING  C_ABEVAZ_M0AC003A
                                  C_ABEVAZ_A0AE004A
                                  $ADOAZON.

*M0AC004A Taxpayer name, can be taken from: A0AE008A
  PERFORM GET_AFA_M_ABEVAZ TABLES $T_BEVALLO
                                  $T_BEVALLB
                           USING  C_ABEVAZ_M0AC004A
                                  C_ABEVAZ_A0AE006A
                                  $ADOAZON.

*M0AD001A Declaration period from , can be taken from: A0AF001A
  PERFORM GET_AFA_M_ABEVAZ TABLES $T_BEVALLO
                                  $T_BEVALLB
                           USING  C_ABEVAZ_M0AD001A
                                  C_ABEVAZ_A0AF001A
                                  $ADOAZON.

*M0AD002A Declaration period until , can be taken from: A0AF002A
  PERFORM GET_AFA_M_ABEVAZ TABLES $T_BEVALLO
                                  $T_BEVALLB
                           USING  C_ABEVAZ_M0AD002A
                                  C_ABEVAZ_A0AF002A
                                  $ADOAZON.
*The tax number is not empty
  IF NOT $ADOAZON IS INITIAL.
*   ADOAZON
    PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
                                    $T_BEVALLB
                             USING  C_ABEVAZ_M0AC005A
                                    $ADOAZON
                                    $ADOAZON.
*Enter a group name
    CLEAR L_TEXT50.
    SELECT SINGLE TEXT50 INTO L_TEXT50
                         FROM /ZAK/PADONSZT
                        WHERE ADOAZON EQ $ADOAZON.
    IF SY-SUBRC EQ 0 AND NOT L_TEXT50 IS INITIAL.
*     NAME1
      PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
                                      $T_BEVALLB
                               USING  C_ABEVAZ_M0AC006A
                                      L_TEXT50
                                      $ADOAZON.
    ENDIF.
  ENDIF.

*M0AC005A Partner's tax number: the M paper ADOAZON must be entered here,
*if it was loaded from STCD1 (the receiver or
*carrier code+KOART specifies how to ship. Or customer!)
*M0AC006A if loaded from STCD3
  READ TABLE $T_BEVALLO INTO LW_BEVALLO INDEX 1.
*Upload month:
  REFRESH LR_MONAT.
  IF $BEVALL-BIDOSZ EQ 'H'.
    M_DEF LR_MONAT 'I' 'EQ' LW_BEVALLO-MONAT SPACE.
  ELSEIF $BEVALL-BIDOSZ EQ 'N'.
    IF LW_BEVALLO-MONAT BETWEEN '01' AND '03'.
*      M_DEF LR_MONAT 'I' 'EQ' '01' '03'.
      M_DEF LR_MONAT 'I' 'BT' '01' '03'.
    ELSEIF LW_BEVALLO-MONAT BETWEEN '04' AND '06'.
      M_DEF LR_MONAT 'I' 'BT' '04' '06'.
    ELSEIF LW_BEVALLO-MONAT BETWEEN '07' AND '09'.
*      M_DEF LR_MONAT 'I' 'EQ' '07' '09'.
      M_DEF LR_MONAT 'I' 'BT' '07' '09'.
    ELSEIF LW_BEVALLO-MONAT BETWEEN '10' AND '12'.
*      M_DEF LR_MONAT 'I' 'EQ' '10' '12'.
      M_DEF LR_MONAT 'I' 'BT' '10' '12'.
    ENDIF.
  ELSEIF $BEVALL-BIDOSZ EQ 'E'.
*    M_DEF LR_MONAT 'I' 'EQ' '01' '12'.
    M_DEF LR_MONAT 'I' 'BT' '01' '12'.
  ENDIF.

  SELECT SINGLE * INTO LW_ANALITIKA
                  FROM /ZAK/ANALITIKA
                 WHERE BUKRS   EQ LW_BEVALLO-BUKRS
                   AND BTYPE   EQ LW_BEVALLO-BTYPE
                   AND GJAHR   EQ LW_BEVALLO-GJAHR
*                    AND monat   EQ lw_bevallo-monat
                   AND MONAT   IN LR_MONAT
*                    AND ZINDEX  EQ LW_BEVALLO-ZINDEX
                   AND ZINDEX  LE LW_BEVALLO-ZINDEX
                   AND ADOAZON EQ $ADOAZON.
  IF SY-SUBRC EQ 0 AND NOT $ADOAZON IS INITIAL.
    IF NOT  LW_ANALITIKA-STCD1 IS INITIAL.
*      STCD1
      PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
                                      $T_BEVALLB
                               USING  C_ABEVAZ_M0AC005A
                                      LW_ANALITIKA-STCD1(8)
                                      $ADOAZON.
    ELSEIF NOT  LW_ANALITIKA-ADOAZON IS INITIAL.
*      ADOAZON
      PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
                                      $T_BEVALLB
                               USING  C_ABEVAZ_M0AC005A
                                      LW_ANALITIKA-ADOAZON
                                      $ADOAZON.
    ENDIF.
*Customer name:
    IF LW_ANALITIKA-KOART EQ 'D'.
      SELECT SINGLE NAME1 INTO L_NAME1
                          FROM KNA1
                         WHERE KUNNR EQ LW_ANALITIKA-LIFKUN
                            AND XCPDK NE 'X'.    "ha nem CPD
*Supplier name
    ELSEIF LW_ANALITIKA-KOART EQ 'K'.
      SELECT SINGLE NAME1 INTO L_NAME1
                          FROM LFA1
                         WHERE LIFNR EQ LW_ANALITIKA-LIFKUN
                            AND XCPDK NE 'X'.    "ha nem CPD
    ENDIF.
*There is a name in field_c on a DUMMY_R record
    IF L_NAME1 IS INITIAL AND NOT LW_ANALITIKA-FIELD_C IS INITIAL.
      L_NAME1 = LW_ANALITIKA-FIELD_C.
    ENDIF.
    IF NOT L_NAME1 IS INITIAL.
*      NAME1
      PERFORM GET_AFA_M_VALUE  TABLES $T_BEVALLO
                                      $T_BEVALLB
                               USING  C_ABEVAZ_M0AC006A
                                      L_NAME1
                                      $ADOAZON.
    ELSE.
*DUMMY_R FIELD_C field
      PERFORM GET_AFA_M_FROM_ABEV TABLES $T_BEVALLO
                                         $T_BEVALLB
                                  USING  C_ABEVAZ_M0AC006A
                                         C_ABEVAZ_DUMMY_R
                                         $ADOAZON.
    ENDIF.
  ENDIF.

ENDFORM.
*--2465 #01.
*++24A60 #01.
FORM CALC_ABEV_ONYB_24A60  TABLES T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                  T_BEVALLB STRUCTURE /ZAK/BEVALLB
                           USING  $LAST_DATE.

  DATA L_TABIX LIKE SY-TABIX.

  DATA L_GJAHR TYPE GJAHR.
  DATA L_MONAT TYPE MONAT.
  DATA L_BEGIN_DAY LIKE SY-DATUM.

  CLEAR: L_GJAHR,L_MONAT.

  L_GJAHR = $LAST_DATE(4).
  L_MONAT = $LAST_DATE+4(2).
*E - Annual
  IF W_/ZAK/BEVALL-BIDOSZ = 'E'.
    L_MONAT = '01'.
*N - Quarterly
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'N'.
    SUBTRACT 2 FROM L_MONAT.
* H - Monthly
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'H'.
*++2465 #05.
*Special period
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'S'.
    L_MONAT = W_/ZAK/BEVALL-DATAB+4(2).
*--2465 #05.
  ENDIF.

  CONCATENATE L_GJAHR L_MONAT '01' INTO L_BEGIN_DAY.

*the following abev codes can only occur once, summary v. char
  LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB
    WHERE  ABEVAZ EQ     C_ABEVAZ_A0AD001A
       OR  ABEVAZ EQ     C_ABEVAZ_A0AD002A
       OR  ABEVAZ EQ     C_ABEVAZ_A0AD004A
       OR  ABEVAZ EQ     C_ABEVAZ_A0AD005A.

*this line must be modified!
    LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO
                      WHERE ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.

      CASE W_/ZAK/BEVALLB-ABEVAZ.

*PERIOD start date
        WHEN  C_ABEVAZ_A0AD001A.
          W_/ZAK/BEVALLO-FIELD_C = L_BEGIN_DAY.
*PERIOD closing date
        WHEN  C_ABEVAZ_A0AD002A.
          W_/ZAK/BEVALLO-FIELD_C = $LAST_DATE.
*Loading correction flags
*We always upload if self-revision:
        WHEN  C_ABEVAZ_A0AD004A.
          IF W_/ZAK/BEVALLO-ZINDEX NE '000'.
            W_/ZAK/BEVALLO-FIELD_C = 'H'.
          ENDIF.
*Frequency of reporting
        WHEN  C_ABEVAZ_A0AD005A.
          IF W_/ZAK/BEVALL-BIDOSZ = 'H'.
            W_/ZAK/BEVALLO-FIELD_C = 'H'.
          ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'N'.
            W_/ZAK/BEVALLO-FIELD_C = 'N'.
          ENDIF.
      ENDCASE.
      MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " CALC_ABEV_ONYB_24A60
*--24A60 #01.
*++2408 #01.
*&---------------------------------------------------------------------*
*&      Form  GET_LAP_SZ_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*----------------------------------------------------------------------*
FORM GET_LAP_SZ_2408  TABLES T_BEVALLO STRUCTURE  /ZAK/BEVALLALV.

  DATA L_ALV LIKE /ZAK/BEVALLALV.
  DATA L_INDEX LIKE SY-TABIX.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_NYLAP LIKE SY-TABIX.
  DATA L_BEVALLO_ALV LIKE /ZAK/BEVALLALV.
  DATA L_NULL_FLAG TYPE /ZAK/NULL.
  DATA LI_/ZAK/BEVALLO   TYPE STANDARD TABLE OF /ZAK/BEVALLO INITIAL SIZE 0.


  CLEAR L_INDEX.

*Upload RANKS to manage retired numbers
  M_DEF R_A0AC047A 'I' 'EQ' 'M0FC003A' SPACE.
  M_DEF R_A0AC047A 'I' 'EQ' 'M0GC003A' SPACE.
  M_DEF R_A0AC047A 'I' 'EQ' 'M0HC003A' SPACE.
  M_DEF R_A0AC047A 'I' 'EQ' 'M0IC003A' SPACE.
  M_DEF R_A0AC047A 'I' 'EQ' 'M0JC003A' SPACE.
  M_DEF R_A0AC047A 'I' 'EQ' 'M0KC003A' SPACE.
*++2408 #04.
*  M_DEF R_A0AC047A 'I' 'EQ' 'M0LC003A' SPACE.
  M_DEF R_A0AC047A 'I' 'EQ' 'M0LC001A' SPACE.
*--2408 #04..
*Values
*  M_DEF R_NYLAPVAL 'I' 'EQ' '3' SPACE.
  M_DEF R_NYLAPVAL 'I' 'EQ' '7' SPACE.
  M_DEF R_NYLAPVAL 'I' 'EQ' '8' SPACE.


  REFRESH I_NYLAP.
  LI_/ZAK/BEVALLO[] = I_/ZAK/BEVALLO[].

  LOOP AT I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO.
    L_TABIX = SY-TABIX.

*Dialog run for insurance
    PERFORM PROCESS_IND_ITEM USING '100000'
          L_INDEX
          TEXT-P01.

*   Csak SZJA-nal
    IF  W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_SZJA.
*Collection of pensioner tax numbers
      PERFORM CALL_NYLAP TABLES R_A0AC047A
        R_NYLAPVAL
      USING  W_/ZAK/BEVALLO.

    ENDIF.

    READ TABLE T_BEVALLO INTO L_ALV WITH KEY
                          BUKRS   = W_/ZAK/BEVALLO-BUKRS
                          BTYPE   = W_/ZAK/BEVALLO-BTYPE
                          GJAHR   = W_/ZAK/BEVALLO-GJAHR
                          MONAT   = W_/ZAK/BEVALLO-MONAT
                          ZINDEX  = W_/ZAK/BEVALLO-ZINDEX
                          ABEVAZ  = W_/ZAK/BEVALLO-ABEVAZ
                          ADOAZON = W_/ZAK/BEVALLO-ADOAZON
                          LAPSZ   = W_/ZAK/BEVALLO-LAPSZ
                          BINARY SEARCH.
    IF SY-SUBRC EQ 0.
*The 0 flag handling was not appropriate
*If it is a self-revision calculation, the T_BEVALLO 0 flag is required
*otherwise, the I_/ZAK/BEVALLO 0 flag.
      IF NOT L_ALV-OFLAG IS INITIAL.
        L_NULL_FLAG = L_ALV-NULL_FLAG.
      ELSE.
        L_NULL_FLAG = W_/ZAK/BEVALLO-NULL_FLAG.
      ENDIF.
      MOVE-CORRESPONDING W_/ZAK/BEVALLO TO L_ALV.
      L_ALV-NULL_FLAG = L_NULL_FLAG.
      IF L_ALV-OFLAG IS INITIAL.
        MODIFY T_BEVALLO FROM L_ALV INDEX SY-TABIX
        TRANSPORTING FIELD_C FIELD_N FIELD_NR FIELD_NRK
        NULL_FLAG WAERS
        .
      ELSE.
        MODIFY T_BEVALLO FROM L_ALV INDEX SY-TABIX
        TRANSPORTING FIELD_C FIELD_N  FIELD_NR
        FIELD_NRK
        OFLAG   FIELD_ON FIELD_ONR
        FIELD_ONRK
        NULL_FLAG WAERS.
        PERFORM SUM_ONR TABLES T_BEVALLO
        USING  L_ALV
              L_ALV-FIELD_ON
              L_ALV-FIELD_ONR
              L_ALV-FIELD_ONRK.
      ENDIF.
    ELSE.
      READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
      WITH KEY ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
      MOVE-CORRESPONDING W_/ZAK/BEVALLB TO L_ALV.
      MOVE-CORRESPONDING W_/ZAK/BEVALLO TO L_ALV.
      SELECT SINGLE ABEVTEXT INTO L_ALV-ABEVTEXT
      FROM  /ZAK/BEVALLBT
      WHERE  LANGU   = SY-LANGU
      AND    BTYPE   = W_/ZAK/BEVALLO-BTYPE
      AND    ABEVAZ  = W_/ZAK/BEVALLO-ABEVAZ.
      L_ALV-ABEVTEXT_DISP = L_ALV-ABEVTEXT.
      APPEND L_ALV TO T_BEVALLO.
      SORT T_BEVALLO BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON
      LAPSZ.
    ENDIF.
    DELETE I_/ZAK/BEVALLO.
  ENDLOOP.

*Definition of pensioners
  IF NOT I_NYLAP[] IS INITIAL.
    DESCRIBE TABLE I_NYLAP LINES L_NYLAP.
    READ TABLE T_BEVALLO INTO L_BEVALLO_ALV
                          WITH KEY ABEVAZ  = 'A0AC034A'
                          BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      MOVE L_NYLAP TO L_BEVALLO_ALV-FIELD_C.
      CONDENSE L_BEVALLO_ALV-FIELD_C.
      MODIFY T_BEVALLO FROM L_BEVALLO_ALV INDEX SY-TABIX
      TRANSPORTING FIELD_C.
    ENDIF.
  ELSE.
    READ TABLE T_BEVALLO INTO L_BEVALLO_ALV
                          WITH KEY ABEVAZ  = 'A0AC034A'
                          BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      CLEAR L_BEVALLO_ALV-FIELD_C.
      MODIFY T_BEVALLO FROM L_BEVALLO_ALV INDEX SY-TABIX
      TRANSPORTING FIELD_C.
    ENDIF.
  ENDIF.                                 "Please enter the correct name of <...>.

ENDFORM.
*--2408 #01.
*++2408 #01.
*&---------------------------------------------------------------------*
*&      Form  DEL_ESDAT_FIELD_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_C_ABEVAZ_A0AC041A  text
*----------------------------------------------------------------------*
FORM DEL_ESDAT_FIELD_2408  TABLES   $T_BEVALLO STRUCTURE /ZAK/BEVALLALV
                                    $T_BEVALLB STRUCTURE /ZAK/BEVALLB
                           USING    $ABEVAZ_JELLEG.

  DATA LW_/ZAK/BEVALLALV TYPE /ZAK/BEVALLALV.

*We define the character:
  READ TABLE $T_BEVALLO INTO LW_/ZAK/BEVALLALV
  WITH KEY ABEVAZ = $ABEVAZ_JELLEG
  BINARY SEARCH.
*In this case, you do not need to fill in the due date:
  IF SY-SUBRC EQ 0 AND LW_/ZAK/BEVALLALV-FIELD_C = 'H'.
** ABEV ID value marked in ESDAT_FLAG
*     READ TABLE $T_BEVALLB INTO W_/ZAK/BEVALLB
*                         WITH KEY  ESDAT_FLAG = 'X'.
*     IF SY-SUBRC EQ 0.
*       READ TABLE $T_BEVALLO INTO LW_/ZAK/BEVALLALV
*                           WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
*                           BINARY SEARCH.
*       IF SY-SUBRC EQ 0.
*         V_TABIX = SY-TABIX .
*         CLEAR LW_/ZAK/BEVALLALV-FIELD_C.
*         MODIFY $T_BEVALLO FROM LW_/ZAK/BEVALLALV
*                               INDEX V_TABIX TRANSPORTING FIELD_C.
*       ENDIF.
*     ENDIF.
*For correctors, there is no need for 0 flag in the self-check allowance either
    READ TABLE $T_BEVALLO INTO LW_/ZAK/BEVALLALV
    WITH KEY ABEVAZ = C_ABEVAZ_A0HC0240CA
    BINARY SEARCH.
    IF SY-SUBRC EQ 0 AND NOT LW_/ZAK/BEVALLALV-NULL_FLAG IS INITIAL.
      V_TABIX = SY-TABIX .
      CLEAR LW_/ZAK/BEVALLALV-NULL_FLAG.
      MODIFY $T_BEVALLO FROM LW_/ZAK/BEVALLALV
      INDEX V_TABIX TRANSPORTING NULL_FLAG.
    ENDIF.
  ENDIF.

ENDFORM.
*--2408 #01.
*++2408 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_M_SZJA_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_M_SZJA_2408  TABLES T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                   T_BEVALLB STRUCTURE /ZAK/BEVALLB
                                   T_ADOAZON_ALL STRUCTURE
                                   /ZAK/ADOAZONLPSZ
                            USING  $INDEX
                                   $LAST_DATE.

  SORT T_BEVALLB BY ABEVAZ.
  SORT T_BEVALLO BY ABEVAZ ADOAZON LAPSZ.
  RANGES LR_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.

*Special M calculations as a tax ID
*M 02-316 d Combined tax base (sum of lines 300-306 and lines 312-315 "D")
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0300DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0301DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0302DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0303DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0304DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0305DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0306DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0312DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0313DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0314DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0315DA' SPACE.
*field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM GET_SUM_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0BD0316DA'.           "field0

*M 03-317 4 or more gy. reducing the consolidated tax base. foster mothers
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0300EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0301EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0302EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0303EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0304EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0305EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0306EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0314EA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0315EA' SPACE.

*field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM GET_SUM_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0CC0317BA'.          "field0

*M 03-318 Young people under the age of 25 reducing the consolidated tax base
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0300FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0301FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0302FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0303FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0304FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0305FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0306FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0314FA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0315FA' SPACE.
*field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM GET_SUM_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0CC0318BA'.          "field0

*M 03-319 Young people under the age of 25 reducing the consolidated tax base
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0300GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0301GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0302GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0303GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0304GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0305GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0306GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0314GA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0315GA' SPACE.
*field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM GET_SUM_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0CC0319BA'.          "field0

*Discounts reducing the combined tax base in total
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0317BA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0318BA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0319BA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0320BA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0321BA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0322BA' SPACE.

*field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM GET_SUM_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0CC0323BA'.          "field0

*M 02-324 B Basis of the tax advance (the difference between lines 316-323)
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0316DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0CC0323BA' SPACE.
*field0 = field1+field2+...fieldN as much as is in RANGE
  PERFORM GET_SUB_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0CC0324BA'            "field0
                             '+'.                    "The result cannot be '-'

*M 02-325 B Amount considered as wages from line 316 (data from lines 300-303 "D", 314-315 lines "A")
  REFRESH LR_ABEVAZ.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0300DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0301DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0302DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0303DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0314DA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0BD0315DA' SPACE.

*field0 = field1-field2-........ field as much as is in the RANGE
  PERFORM GET_SUM_R_M TABLES T_BEVALLO
                             T_BEVALLB
                             T_ADOAZON_ALL
                             LR_ABEVAZ
                      USING  'M0CC0325BA'.          "field0

ENDFORM.
*--2408 #01.
*++2408 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_SPECIAL_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_1463   text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_SZJA_SPECIAL_2408 TABLES T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                        T_BEVALLB STRUCTURE /ZAK/BEVALLB
                                        T_ADOAZON STRUCTURE /ZAK/ONR_ADOAZON
                                 USING  $INDEX
                                        $DATE.

  DATA LR_COND TYPE RANGE_C2 OCCURS 0 WITH HEADER LINE.
  DATA L_TMP_BEVALLO TYPE /ZAK/BEVALLO.
  DATA L_BEVALLO TYPE /ZAK/BEVALLO.

  FIELD-SYMBOLS: <FIELD_N>, <FIELD_NR>, <FIELD_NRK>.

  DEFINE LM_GET_FIELD.
    IF &1 EQ '000'.
      ASSIGN W_/ZAK/BEVALLO-FIELD_N   TO <FIELD_N>.
      ASSIGN W_/ZAK/BEVALLO-FIELD_NR  TO <FIELD_NR>.
      ASSIGN W_/ZAK/BEVALLO-FIELD_NRK TO <FIELD_NRK>.
    ELSE.
      ASSIGN W_/ZAK/BEVALLO-FIELD_ON   TO <FIELD_N>.
      ASSIGN W_/ZAK/BEVALLO-FIELD_ONR  TO <FIELD_NR>.
      ASSIGN W_/ZAK/BEVALLO-FIELD_ONRK TO <FIELD_NRK>.
    ENDIF.
    CLEAR: <FIELD_N>, <FIELD_NR>, <FIELD_NRK>.
  END-OF-DEFINITION.

  DEFINE LM_GET_SPEC_SUM1.
    LOOP AT T_BEVALLO INTO L_BEVALLO WHERE ABEVAZ = &1.
*The ABEV for the condition must be determined
*ID value
      READ TABLE T_BEVALLO INTO L_TMP_BEVALLO
      WITH KEY ABEVAZ  = &2
      ADOAZON = L_BEVALLO-ADOAZON
      LAPSZ  = L_BEVALLO-LAPSZ
      BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        CONDENSE L_TMP_BEVALLO-FIELD_C.
        IF L_TMP_BEVALLO-FIELD_C IN &3.
          ADD L_BEVALLO-FIELD_N TO <FIELD_N>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  END-OF-DEFINITION.

  RANGES LR_ABEVAZ     FOR /ZAK/BEVALLO-ABEVAZ.
  RANGES LR_SEL_ABEVAZ FOR /ZAK/BEVALLO-ABEVAZ.


  DEFINE LM_GET_SPEC_SUM2.
    IF NOT &1[] IS INITIAL.
      LOOP AT T_BEVALLO INTO L_BEVALLO WHERE ABEVAZ IN &1.
        IF $INDEX EQ '000'.
          ADD L_BEVALLO-FIELD_N TO <FIELD_N>.
        ELSE.
          ADD L_BEVALLO-FIELD_ON TO <FIELD_N>.
        ENDIF.
      ENDLOOP.
    ENDIF.
  END-OF-DEFINITION.

  SORT T_BEVALLB BY ABEVAZ.
*++2408 #02.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0103CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0104CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0105CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0106CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0107CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0108CA' SPACE.
*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0109CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0120CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0121CA' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0DC0122CA' SPACE.
*--2408 #02.
*the following abev codes can only occur once, summary v. char
  LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB WHERE ABEVAZ IN LR_SEL_ABEVAZ.

    CLEAR W_/ZAK/BEVALLO.

*this line must be modified!
    READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
    WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
    BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.

    V_TABIX = SY-TABIX .

*Special calculations
    CASE W_/ZAK/BEVALLB-ABEVAZ.
*++2408 #02.
*04-102 A GYED,GYES,GYET will take 12.5% ​​socho (code 10: 67|
*      WHEN  'A0EC0103CA'.
      WHEN  'A0DC0103CA'.
*--2408 #02.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '10' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KE0693CA' 'M0KC007A' LR_COND.
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '11' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KE0695CA' 'M0KC007A' LR_COND.
*04-10 does not require professional qualifications
      WHEN  'A0DC0104CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '18' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.
*04-105 is in the field of agricultural work
      WHEN  'A0DC0105CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '19' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.
*A 04-106 Those entering the labor market
      WHEN  'A0DC0106CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '20' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.
*04-107 after women with 3 or more children
      WHEN  'A0DC0107CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '21' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.
*04-108 in the framework of public employment
      WHEN  'A0DC0108CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '23' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.
*++2408 #02.
** 04-108 is the national higher education doctorate
*      WHEN  'A0DC0109CA'.
** Upload condition
*        REFRESH LR_COND.
*        M_DEF LR_COND 'I' 'EQ' '25' SPACE.
*        LM_GET_FIELD $INDEX.
*        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.
*--2408 #02.
*A 04-120 The private individual's pension contribution (563,604,611|
      WHEN  'A0DC0120CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'E' 'EQ' '25' SPACE.
        M_DEF LR_COND 'E' 'EQ' '42' SPACE.
        M_DEF LR_COND 'E' 'EQ' '81' SPACE.
        M_DEF LR_COND 'E' 'EQ' '83' SPACE.
        M_DEF LR_COND 'E' 'EQ' '92' SPACE.
        M_DEF LR_COND 'E' 'EQ' '93' SPACE.
        M_DEF LR_COND 'E' 'EQ' '112' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0GD0579CA' 'M0GC004A' LR_COND.
        LM_GET_SPEC_SUM1 'M0HD0605CA' 'M0HC004A' LR_COND.
        LM_GET_SPEC_SUM1 'M0ID0619CA' 'M0IC004A' LR_COND.
*A 04-121-c The burden of unemployment, employment pension (605.s|
      WHEN  'A0DC0121CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '25' SPACE.
        M_DEF LR_COND 'I' 'EQ' '42' SPACE.
        M_DEF LR_COND 'I' 'EQ' '81' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0HD0605CA' 'M0HC004A' LR_COND.
*A 04-122-c The private sector pays pension after GYED, S, T (A 604|
      WHEN  'A0DC0122CA'.
*Upload condition
        REFRESH LR_COND.
        M_DEF LR_COND 'I' 'EQ' '83' SPACE.
        M_DEF LR_COND 'I' 'EQ' '92' SPACE.
        M_DEF LR_COND 'I' 'EQ' '93' SPACE.
        M_DEF LR_COND 'I' 'EQ' '112' SPACE.
        LM_GET_FIELD $INDEX.
        LM_GET_SPEC_SUM1 'M0HD0605CA' 'M0HC004A' LR_COND.
    ENDCASE.
    IF <FIELD_N> IS ASSIGNED AND NOT <FIELD_N> IS INITIAL.
      PERFORM CALC_FIELD_NRK USING <FIELD_N>
                                    W_/ZAK/BEVALLB-ROUND
                                    W_/ZAK/BEVALLO-WAERS
                          CHANGING <FIELD_NR>
                                   <FIELD_NRK>.
    ENDIF.
    IF $INDEX NE '000'.
      MOVE 'X' TO W_/ZAK/BEVALLO-OFLAG.
    ENDIF.
    MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.

  ENDLOOP.


ENDFORM.
*--2408 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_ONREV_SZJA_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_T_ADOAZON  text
*      -->P_$INDEX  text
*      -->P_$LAST_DATE  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_ONREV_SZJA_2408  TABLES  T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                        T_BEVALLB STRUCTURE /ZAK/BEVALLB
                                        T_ADOAZON STRUCTURE /ZAK/ONR_ADOAZON
                                 USING  $INDEX
                                        $DATE.
  DATA LI_LAST_BEVALLO LIKE /ZAK/BEVALLO OCCURS 0 WITH HEADER LINE.

  DATA L_LAST_INDEX LIKE /ZAK/BEVALLO-ZINDEX.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.

  RANGES LR_ONREV_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.
  DATA   L_ABEVAZ LIKE /ZAK/BEVALLB-ABEVAZ.

  DATA: L_KAM_KEZD TYPE DATUM,
        L_KAM_VEG  TYPE DATUM.
  DATA   L_KAMAT LIKE /ZAK/BEVALLO-FIELD_N.
  DATA   L_KAMAT_SUM LIKE /ZAK/BEVALLO-FIELD_N.

*To upload fields to be summarized
  RANGES LR_ABEVAZ FOR /ZAK/BEVALLO-ABEVAZ.
  RANGES LR_ABEVAZ_MIN FOR /ZAK/BEVALLO-ABEVAZ.
*If self-revision
  CHECK $INDEX NE '000'.

  SORT T_BEVALLB BY ABEVAZ.

*Let's read the 'A' abev identifiers of the previous period
  READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO INDEX 1.
  CHECK SY-SUBRC EQ 0.
  L_LAST_INDEX = $INDEX - 1.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = L_LAST_INDEX
    IMPORTING
      OUTPUT = L_LAST_INDEX.


  SELECT * INTO TABLE LI_LAST_BEVALLO
                FROM  /ZAK/BEVALLO
               WHERE  BUKRS   EQ W_/ZAK/BEVALLO-BUKRS
                 AND  BTYPE   EQ W_/ZAK/BEVALLO-BTYPE
                 AND  GJAHR   EQ W_/ZAK/BEVALLO-GJAHR
                 AND  MONAT   EQ W_/ZAK/BEVALLO-MONAT
                 AND  ZINDEX  EQ L_LAST_INDEX
                 AND  ADOAZON EQ ''.

  SORT LI_LAST_BEVALLO BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ.

*We delete records that are not in the given period
*  adtak fel.
  LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO
                    WHERE NOT ADOAZON IS INITIAL.
    READ TABLE T_ADOAZON WITH KEY ADOAZON = W_/ZAK/BEVALLO-ADOAZON
                                  BINARY SEARCH.
*    Nem kell a rekord.
    IF SY-SUBRC NE 0.
      DELETE T_BEVALLO.
      CONTINUE.
    ENDIF.
*M 11 Mark with an X if your declaration is considered a correction
    IF W_/ZAK/BEVALLO-ABEVAZ EQ C_ABEVAZ_M0AE003A.
      MOVE 'H' TO W_/ZAK/BEVALLO-FIELD_C.
      MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO TRANSPORTING FIELD_C.
    ENDIF.
  ENDLOOP.

* A0GD0193DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0193DA'   "Modified field
                                'A0BD0001CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5

* A0GD0195DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0195DA'   "Modified field
                                'A0DC0074CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0195CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0195CA'   "Modified field
                               'A0GD0195DA'
                               '0.15'.
* A0GD0196DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0196DA'   "Modified field
                                'A0BD0007CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0198DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0198DA'   "Modified field
                                'A0BD0014CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0199DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0199DA'   "Modified field
                                'A0BE0026CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0200DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0200DA'   "Modified field
*++2408 #02.
*'A0DC0110CA' "Source 1
                                'A0DC0109CA'   "Source 1
*--2408 #02.
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0200CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0200CA'   "Modified field
                               'A0GD0200DA'
                               '0.13'.
* A0GD0203DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0203DA'   "Modified field
                                'A0DC0123CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0203CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0203CA'   "Modified field
                               'A0GD0203DA'
                               '0.10'.
* A0GD0205DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0205DA'   "Modified field
                                'A0EC0150CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0203CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0205CA'   "Modified field
                               'A0GD0205DA'
                               '0.04'.
* A0GD0206DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0206DA'   "Modified field
                                'A0EC0151CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0206CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0206CA'   "Modified field
                               'A0GD0206DA'
                               '0.03'.
* A0GD0207DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0207DA'   "Modified field
                                'A0EC0152CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0207CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0207CA'   "Modified field
                               'A0GD0207DA'
                               '0.015'.
* A0GD0208DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0208DA'   "Modified field
                                'A0EC0154CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0208CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0208CA'   "Modified field
                               'A0GD0208DA'
                               '0.095'.
* A0GD0209DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0209DA'   "Modified field
                                'A0EC0155CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0209CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0209CA'   "Modified field
                               'A0GD0209DA'
                               '0.13'.
* A0GD0210DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0210DA'   "Modified field
                                'A0EC0156CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0210CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0210CA'   "Modified field
                               'A0GD0210DA'
                               '0.095'.
* A0GD0211DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0211DA'   "Modified field
                                'A0EC0157CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0211CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0211CA'   "Modified field
                               'A0GD0211DA'
                               '0.15'.
*++2408 #08.
** A0GD0212AA
*  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
*                                LI_LAST_BEVALLO
*                                T_BEVALLB
*USING 'A0GD0212AA' "Modified field
*'A0EC0158CA' "Source 1
*SPACE "Source 2
*SPACE "Source 3
*SPACE "Source 4
*SPACE.         "Source 5
*--2408 #08.
* A0GD0213DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0213DA'   "Modified field
                                'A0EC0136CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0214DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0214DA'   "Modified field
                                'A0EC0160CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0214CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0214CA'   "Modified field
                               'A0GD0214DA'
                               '0.185'.
* A0GD0215DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0GD0215DA'   "Modified field
                                'A0EC0161CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
* A0GD0215CA
  PERFORM GET_ONREV_DIV TABLES T_BEVALLO
                               T_BEVALLB
                        USING  'A0GD0215CA'   "Modified field
                               'A0GD0215DA'
                               '0.185'.
* A0GD0194DA
  REFRESH LR_ABEVAZ.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0195DA' SPACE.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0196DA' SPACE.
  PERFORM GET_ONREV_SUM TABLES T_BEVALLO
                               LR_ABEVAZ
                               T_BEVALLB
                        USING  'A0GD0194DA'.

  REFRESH: LR_ABEVAZ, LR_ABEVAZ_MIN.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0198DA' SPACE.
  M_DEF  LR_ABEVAZ_MIN 'I' 'EQ' 'A0GD0199DA' SPACE.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0200DA' SPACE.
  M_DEF  LR_ABEVAZ_MIN 'I' 'EQ' 'A0GD0201DA' SPACE.
  M_DEF  LR_ABEVAZ_MIN 'I' 'EQ' 'A0GD0202DA' SPACE.

  PERFORM GET_ONREV_SIGN_SUM TABLES T_BEVALLO
                               LR_ABEVAZ
                               LR_ABEVAZ_MIN
                               T_BEVALLB
                        USING  'A0GD0197DA'.
* A0GD0197CA
  REFRESH LR_ABEVAZ.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0200CA' SPACE.

  PERFORM GET_ONREV_SUM TABLES T_BEVALLO
                               LR_ABEVAZ
                               T_BEVALLB
                        USING  'A0GD0197CA'.
* A0GD0204DA
  REFRESH LR_ABEVAZ.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0205DA' SPACE.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0206DA' SPACE.
  M_DEF  LR_ABEVAZ 'I' 'EQ' 'A0GD0207DA' SPACE.
  PERFORM GET_ONREV_SUM TABLES T_BEVALLO
                               LR_ABEVAZ
                               T_BEVALLB
                        USING  'A0GD0204DA'.
*++2408 #03.
* A0GD0215DA
  PERFORM GET_ONREV_CALC TABLES T_BEVALLO
                                LI_LAST_BEVALLO
                                T_BEVALLB
                         USING  'A0HD0250CA'   "Modified field
                                'A0EC0159CA'   "Source 1
                                SPACE          "Source 2
                                SPACE          "Source 3
                                SPACE          "Source 4
                                SPACE.         "Source 5
*--2408 #03.
ENDFORM.
*--2408 #01.
*++2408 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_0_SZJA_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_ADOAZON_ALL  text
*      -->P_SPACE  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_0_SZJA_2408  TABLES   T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                      T_ADOAZON_ALL STRUCTURE /ZAK/ADOAZONLPSZ
                              USING   $ONREV
                                      $DATE
                                      $INDEX.

  RANGES LR_ABEVAZ FOR /ZAK/BEVALLO-ABEVAZ.
  DATA   LR_VALUE  LIKE RANGE_C3 OCCURS 0 WITH HEADER LINE.
  DATA   LR_VALUE2 LIKE RANGE_C10 OCCURS 0 WITH HEADER LINE.

  DATA LI_ABEV_RANGE TYPE STANDARD TABLE OF T_ABEV_RANGE.
  DATA LS_ABEV_RANGE TYPE T_ABEV_RANGE.

*So that you don't have to expand the self-revision to a global one for every FORM
*treated as a variable:
  CLEAR V_ONREV.
  IF NOT $ONREV IS INITIAL.
    MOVE $ONREV TO V_ONREV.
  ENDIF.
** If field1 >= field2 then field3 0 flag setting
*   PERFORM GET_NULL_FLAG TABLES T_BEVALLO
*                                T_ADOAZON_ALL
*USING C_ABEVAZ_M0BC0382CA "field1
*C_ABEVAZ_M0BC0382BA "field2
*C_ABEVAZ_M0BC0382DA.        "field 3
** If field1+field2+field3+field4 > 0 then 0 flag setting
*   PERFORM GET_NULL_FLAG_ASUM TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0IC0284HA
*"0-flag setting
*C_ABEVAZ_A0IC0284CA "field1
*C_ABEVAZ_A0IC0284DA "field2
*C_ABEVAZ_A0IC0284EA "field3
*SPACE.                 "field 4
** If field1 is not 0 or field2 is not 0 or field3 is not 0 or field4 is not 0
** or field 5 not 0 then 0 flag setting
*   PERFORM GET_NULL_FLAG_INIT TABLES T_BEVALLO
*                              USING  C_ABEVAZ_A0DC0087DA    "0flag
*C_ABEVAZ_A0DC0087CA "field1
*SPACE "field2
*SPACE "field3
*SPACE "field4
*SPACE "field5
*SPACE.                 "field 6
*   PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                      T_ADOAZON_ALL
*                               USING  C_ABEVAZ_M0CC0415DA   "0flag
*C_ABEVAZ_M0BC0382BA "field1
*C_ABEVAZ_M0BC0386BA "field2
*SPACE "field3
*SPACE "field4
*SPACE "field5
*SPACE.                "field 6
** 0 flag setting on field 1
*     PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
*                                 USING  C_ABEVAZ_A0BC50041A.
*If field1 = field2 then 0 flag is set
*   PERFORM GET_NULL_FLAG_EQM TABLES T_BEVALLO
*                                    T_ADOAZON_ALL
*USING C_ABEVAZ_M0FD0496AA "field1
*C_ABEVAZ_M0FD0495AA "field2
*                                    C_ABEVAZ_M0FD0498BA     "0-flag
*                                    C_ABEVAZ_M0FD0497BA.    "0-flag
*If field1 >= field2 then field3 0 flag setting
  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0301CA'          "field 1
                               'M0BD0301BA'          "field 2
                               'M0BD0301DA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0301DA'          "field 1
                               'M0BD0301BA'          "field 2
                               'M0BD0301CA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0302CA'          "field 1
                               'M0BD0302BA'          "field 2
                               'M0BD0302DA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0302DA'          "field 1
                               'M0BD0302BA'          "field 2
                               'M0BD0302CA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0305CA'          "field 1
                               'M0BD0305BA'          "field 2
                               'M0BD0305DA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0305DA'          "field 1
                               'M0BD0305BA'          "field 2
                               'M0BD0305CA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                              T_ADOAZON_ALL
                       USING  'M0BD0306CA'          "field 1
                              'M0BD0306BA'          "field 2
                              'M0BD0306DA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0306DA'          "field 1
                               'M0BD0306BA'          "field 2
                               'M0BD0306CA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0307CA'          "field 1
                               'M0BD0307BA'          "field 2
                               'M0BD0307DA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0307DA'          "field 1
                               'M0BD0307BA'          "field 2
                               'M0BD0307CA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0312CA'          "field 1
                               'M0BD0312BA'          "field 2
                               'M0BD0312DA'.         "field 3

  PERFORM GET_NULL_FLAG TABLES T_BEVALLO
                               T_ADOAZON_ALL
                        USING  'M0BD0312DA'          "field 1
                               'M0BD0312BA'          "field 2
                               'M0BD0312CA'.         "field 3

  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CD0330BA'.
  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CD0331BA'.

  IF $INDEX NE '000'.
    PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
                                USING  'A0HC0240CA'.
    PERFORM GET_NULL_FLAG_0     TABLES T_BEVALLO
                                USING  'A0HC0242CA'.
  ENDIF.
*++2408 #06.
  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0674CA'           "0flag
                                     'M0KD0674AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

*--2408 #06.
  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0676CA'           "0flag
                                     'M0KD0676AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' 'I' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0GD0564CA' SPACE.
  PERFORM GET_NULL_FLAG_M_IN_OR_ABEVAZ TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                              LR_ABEVAZ
                                        USING 'M0GC007A'    "field 1
                                              'M0GD0566CA'. "0 flag

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' 'I' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0GD0568CA' SPACE.
  PERFORM GET_NULL_FLAG_M_IN_OR_ABEVAZ TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                              LR_ABEVAZ
                                        USING 'M0GC007A'    "field 1
                                              'M0GD0570CA'. "0 flag

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' 'I' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0GD0574CA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0GD0575CA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ' 'M0GD0576CA' SPACE.
  PERFORM GET_NULL_FLAG_M_IN_OR_ABEVAZ TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                              LR_ABEVAZ
                                        USING 'M0GC007A'    "field 1
                                              'M0GD0578CA'. "0 flag

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0571CA'           "0flag
                                     'M0GD0569CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0571CA'           "0flag
                                     'M0GD0570CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0HD0605CA'           "0flag
                                     'M0HD0603CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0577CA'           "0flag
                                     'M0GD0574CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0574CA'.

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ED0364DA'           "0flag
                                     'M0ED0364BA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ED0364EA'           "0flag
                                     'M0ED0364BA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ED0368DA'           "0flag
                                     'M0ED0368BA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ED0368EA'           "0flag
                                     'M0ED0368BA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0678AA'           "0flag
                                     'M0KD0673AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0678CA'           "0flag
                                     'M0KD0673AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6


  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0676AA'           "0flag
                                     'M0KD0673AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0676CA'           "0flag
                                     'M0KD0673AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

*++2408 #06.
  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0674AA'           "0flag
                                     'M0KD0673AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KD0674CA'           "0flag
                                     'M0KD0673AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6
*--2408 #06.

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0565CA'           "0flag
                                     'M0GD0564CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0569CA'           "0flag
                                     'M0GD0568CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0573CA'           "0flag
                                     'M0GD0572CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0321BA'           "0flag
                                     'M0CC0321AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6
*++2408 #07.
*  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
*                                     T_ADOAZON_ALL
*                              USING  'M0CC0322BA'           "0flag
*'M0CC0322AA' "field1
*SPACE "field2
*SPACE "field3
*SPACE "field4
*SPACE "field5
*SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0322AA'           "0flag
                                     'M0DC0345AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0322BA'           "0flag
                                     'M0DC0345AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6
*--2408 #07.

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0323BA'           "0flag
                                     'M0CC0320BA'           "field 1
                                     'M0CC0321BA'           "field 2
                                     'M0CC0322BA'           "field 3
*++2408 #07.
                                     'M0DC0345AA'           "field 4
*--2408 #07.
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0323BA'           "0flag
                                     'M0CC0321AA'           "field 1
                                     'M0CC0322AA'           "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0324BA'           "0flag
                                     'M0CC0321AA'           "field 1
                                     'M0CC0322AA'           "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0CC0324BA'           "0flag
                                     'M0CC0320BA'           "field 1
                                     'M0CC0321BA'           "field 2
                                     'M0CC0322BA'           "field 3
                                     'M0CD0316BA'           "field 4
                                     'M0CC0323BA'           "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0GD0567CA'           "0flag
                                     'M0GD0564CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_0_M   TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0626CA'.

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0633CA'           "0flag
                                     'M0ID0629CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0KE0694CA'           "0flag
                                     'M0KE0694AA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6


  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0629CA'           "0flag
                                     'M0ID0626CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' 'I' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ'  'M0HD0600CA' SPACE.

  PERFORM GET_NULL_FLAG_M_IN_OR_ABEVAZ TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                              LR_ABEVAZ
                                        USING 'M0HC008A'    "field 1
                                              'M0HD0604CA'. "0 flag

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' 'I' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ'  'M0ID0626CA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ'  'M0ID0627CA' SPACE.
  M_DEF LR_ABEVAZ 'I' 'EQ'  'M0ID0628CA' SPACE.

  PERFORM GET_NULL_FLAG_M_IN_OR_ABEVAZ TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                              LR_ABEVAZ
                                        USING 'M0IC007A'    "field 1
                                              'M0ID0630CA'. "0 flag

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0629CA'           "0flag
                                     'M0ID0627CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0629CA'           "0flag
                                     'M0ID0628CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0634CA'           "0flag
                                     'M0ID0640CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' '0' SPACE.
  PERFORM GET_NULL_FLAG_M_IN_C_RANGE   TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                        USING 'M0IC003A'    "field 1
                                              'M0ID0629CA'. "0 flag

  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' '0' SPACE.
  PERFORM GET_NULL_FLAG_M_IN_C_RANGE   TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                        USING 'M0IC003A'    "field 1
                                              'M0ID0633CA'. "0 flag

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0633CA'           "0flag
                                     'M0ID0626CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  PERFORM GET_NULL_FLAG_INITM TABLES T_BEVALLO
                                     T_ADOAZON_ALL
                              USING  'M0ID0643CA'           "0flag
                                     'M0ID0641CA'           "field 1
                                     SPACE                  "field 2
                                     SPACE                  "field 3
                                     SPACE                  "field 4
                                     SPACE                  "field 5
                                     SPACE.                 "field 6

  REFRESH: LR_VALUE2, LI_ABEV_RANGE.
  CLEAR LS_ABEV_RANGE.
  M_DEF LR_VALUE2  'I' 'EQ' '0' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '4' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '5' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '11' SPACE.

  LS_ABEV_RANGE-ABEVAZ = 'M0IC003A'.
  LS_ABEV_RANGE-RANGE[] = LR_VALUE2[].
  APPEND LS_ABEV_RANGE TO LI_ABEV_RANGE.
  CLEAR LS_ABEV_RANGE.

  REFRESH: LR_VALUE2.
  M_DEF LR_VALUE2  'I' 'EQ' '20' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '71' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '111' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '72' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '172' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '63' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '108' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '109' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '73' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '70' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '40' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '44' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '106' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '23' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '90' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '84' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '115' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '110' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '19' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '64' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '100' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '173' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '121' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '122' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '120' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '45' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '49' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '52' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '54' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '55' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '57' SPACE.
  M_DEF LR_VALUE2  'I' 'EQ' '58' SPACE.

  LS_ABEV_RANGE-ABEVAZ = 'M0IC004A'.
  LS_ABEV_RANGE-RANGE[] = LR_VALUE2[].
  APPEND LS_ABEV_RANGE TO LI_ABEV_RANGE.
  CLEAR LS_ABEV_RANGE.

  REFRESH: LR_VALUE2.
  M_DEF LR_VALUE2 'E' 'EQ' '1' SPACE.
  M_DEF LR_VALUE2 'E' 'EQ' '2' SPACE.
  LS_ABEV_RANGE-ABEVAZ = C_ABEVAZ_M0FC008A.
  LS_ABEV_RANGE-RANGE[] = LR_VALUE2[].
  MOVE 'X' TO LS_ABEV_RANGE-NOERR. "Ha nincs rekord az nem hiba!
  APPEND LS_ABEV_RANGE TO LI_ABEV_RANGE.
  CLEAR LS_ABEV_RANGE.

* 640 sor
  PERFORM GET_NULL_FLAG_M_IN_C_RANGES  TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LI_ABEV_RANGE
                                        USING 'M0ID0640CA'. "0 flag
* 641 sor
  PERFORM GET_NULL_FLAG_M_IN_C_RANGES  TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LI_ABEV_RANGE
                                        USING 'M0ID0641CA'. "0 flag
* 643 sor
  PERFORM GET_NULL_FLAG_M_IN_C_RANGES  TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LI_ABEV_RANGE
                                        USING 'M0ID0643CA'. "0 flag
* 634 sor
  PERFORM GET_NULL_FLAG_M_IN_C_RANGES  TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LI_ABEV_RANGE
                                        USING 'M0ID0634CA'. "0 flag
*++2408 #05.
  REFRESH: LR_VALUE, LR_ABEVAZ.
  M_DEF LR_VALUE  'I' 'EQ' '1' SPACE.
  M_DEF LR_VALUE  'I' 'EQ' '2' SPACE.
  M_DEF LR_VALUE  'I' 'EQ' '3' SPACE.
  PERFORM GET_NULL_FLAG_M_IN_C_RANGE   TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                        USING 'M0DD0350IA'  "field 1
                                              'M0BD0300GA'. "0 flag
  PERFORM GET_NULL_FLAG_M_IN_C_RANGE   TABLES T_BEVALLO
                                              T_ADOAZON_ALL
                                              LR_VALUE
                                        USING 'M0DD0350IA'  "field 1
                                              'M0CC0319BA'. "0 flag
  PERFORM GET_NULL_FLAG_M_IN_C_RANGE   TABLES T_BEVALLO
                                             T_ADOAZON_ALL
                                             LR_VALUE
                                       USING 'M0DD0350IA'  "field 1
                                             'M0CC0323BA'. "0 flag
  PERFORM GET_NULL_FLAG_M_IN_C_RANGE   TABLES T_BEVALLO
                                             T_ADOAZON_ALL
                                             LR_VALUE
                                       USING 'M0DD0350IA'  "field 1
                                             'M0CC0324BA'. "0 flag
*--2408 #05.
ENDFORM.
*--2408 #01
*++2408 #01.
*&---------------------------------------------------------------------*
*&      Form  CALC_ABEV_SZJA_2408
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_T_BEVALLB  text
*      -->P_$LAST_DATE  text
*      -->P_$INDEX  text
*----------------------------------------------------------------------*
FORM CALC_ABEV_SZJA_2408  TABLES  T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                   T_BEVALLB STRUCTURE /ZAK/BEVALLB
                            USING  $DATE
                                   $INDEX.

  DATA: L_KAM_KEZD TYPE DATUM.

  DATA: BEGIN OF LI_ADOAZON OCCURS 0,
          ADOAZON TYPE /ZAK/ADOAZON,
        END OF LI_ADOAZON.
  DATA: L_BEVALLO TYPE /ZAK/BEVALLO.

*To define a self-check
  RANGES LR_ABEVAZ FOR /ZAK/BEVALLO-ABEVAZ.
  RANGES LR_SEL_ABEVAZ FOR /ZAK/BEVALLO-ABEVAZ.

************************************************************************
*Special abev fields
************************************************************************

  SORT T_BEVALLB BY ABEVAZ  .

*the following abev codes can only occur once, summary v. char
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0AC028A' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0AC029A' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0AC033A' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0AC030A' SPACE.
  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' 'A0GC001A' SPACE.

  LOOP AT T_BEVALLB INTO W_/ZAK/BEVALLB WHERE ABEVAZ IN LR_SEL_ABEVAZ.

    CLEAR W_/ZAK/BEVALLO.

*this line must be modified!
    READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO
    WITH KEY ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
         BINARY SEARCH.

    CHECK SY-SUBRC EQ 0.
    V_TABIX = SY-TABIX .

    CASE W_/ZAK/BEVALLB-ABEVAZ.
*period from first day
      WHEN 'A0AC028A'.
* Monthly
        IF W_/ZAK/BEVALL-BIDOSZ = 'H'.
          L_KAM_KEZD = $DATE.
          L_KAM_KEZD+6(2) = '01'.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
* Annual
        ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
          L_KAM_KEZD = $DATE.
          L_KAM_KEZD+4(4) = '0101'.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
* Quarterly
        ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'N'.
          L_KAM_KEZD = $DATE.
          IF L_KAM_KEZD+4(2) >= '01' AND
             L_KAM_KEZD+4(2) <= '03'.
            L_KAM_KEZD+4(4) = '0101'.
          ENDIF.
          IF L_KAM_KEZD+4(2) >= '04' AND
             L_KAM_KEZD+4(2) <= '06'.
            L_KAM_KEZD+4(4) = '0401'.
          ENDIF.
          IF L_KAM_KEZD+4(2) >= '07' AND
             L_KAM_KEZD+4(2) <= '09'.
            L_KAM_KEZD+4(4) = '0701'.
          ENDIF.
          IF L_KAM_KEZD+4(2) >= '10' AND
             L_KAM_KEZD+4(2) <= '12'.
            L_KAM_KEZD+4(4) = '1001'.
          ENDIF.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
        ELSE.
          L_KAM_KEZD = $DATE.
          L_KAM_KEZD+6(2) = '01'.
          W_/ZAK/BEVALLO-FIELD_C = L_KAM_KEZD.
        ENDIF.
        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*last day until period
      WHEN 'A0AC029A'.
        W_/ZAK/BEVALLO-FIELD_C = $DATE.
        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*Number of taxpayers = Tax numbers
      WHEN 'A0AC033A'.
        REFRESH LI_ADOAZON.
        LOOP AT T_BEVALLO INTO L_BEVALLO WHERE ABEVAZ EQ 'M0AC007A'. "KATA tax declarations are not required
          CHECK NOT L_BEVALLO-ADOAZON IS INITIAL.
          MOVE L_BEVALLO-ADOAZON TO LI_ADOAZON.
          COLLECT LI_ADOAZON.
        ENDLOOP.

        DESCRIBE TABLE LI_ADOAZON LINES SY-TFILL.
        IF NOT SY-TFILL IS INITIAL.
          W_/ZAK/BEVALLO-FIELD_C = SY-TFILL.
        ELSE.
          CLEAR W_/ZAK/BEVALLO-FIELD_C.
        ENDIF.
        CONDENSE W_/ZAK/BEVALLO-FIELD_C.
        MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
*Correction, Self-check
      WHEN 'A0AC030A'.
*Only in self-check
        IF $INDEX NE '000'.
          REFRESH LR_ABEVAZ.
*A numerical value must be searched for in this range
          M_DEF LR_ABEVAZ 'I' 'BT' 'A0GD0193DA'
                                   'A0GD0215DA'.
          M_DEF LR_ABEVAZ 'I' 'BT' 'A0HC0240CA'
                                   'A0HE0255CA'.
          LOOP AT T_BEVALLO INTO L_BEVALLO WHERE ABEVAZ IN LR_ABEVAZ
*We monitor the rounded sum because it may be FIELD_N
*it is not empty, but no value is added to the return because of the fkator.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT FIELD_NR IS INITIAL.
            EXIT.
          ENDLOOP.
*There is value:
          IF SY-SUBRC EQ 0.
            W_/ZAK/BEVALLO-FIELD_C = 'O'.
*Corrective
          ELSE.
            W_/ZAK/BEVALLO-FIELD_C = 'H'.
          ENDIF.
          CONDENSE W_/ZAK/BEVALLO-FIELD_C.
          MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
        ENDIF.
*Repeated self-check
      WHEN 'A0GC001A'.
*Only in self-check
        IF $INDEX > '001'.
          REFRESH LR_ABEVAZ.
*A numerical value must be searched for in this range
          M_DEF LR_ABEVAZ 'I' 'BT' 'A0GD0193DA'
                                   'A0GD0215DA'.
          M_DEF LR_ABEVAZ 'I' 'BT' 'A0HC0240CA'
                                   'A0HE0255CA'.
          LOOP AT T_BEVALLO INTO L_BEVALLO WHERE ABEVAZ IN LR_ABEVAZ
*We monitor the rounded sum because it may be FIELD_N
*it is not empty, but no value is added to the return because of the fkator.
*                                          AND NOT FIELD_N  IS INITIAL.
                                          AND NOT FIELD_NR IS INITIAL.
            EXIT.
          ENDLOOP.
*There is value:
          IF SY-SUBRC EQ 0.
            W_/ZAK/BEVALLO-FIELD_C = 'X'.
          ENDIF.
          CONDENSE W_/ZAK/BEVALLO-FIELD_C.
          MODIFY T_BEVALLO FROM W_/ZAK/BEVALLO INDEX V_TABIX.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*--2408 #01.
