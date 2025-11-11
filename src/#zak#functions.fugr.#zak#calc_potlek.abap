FUNCTION /ZAK/CALC_POTLEK.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_ZINDEX) TYPE  /ZAK/INDEX
*"     VALUE(I_KAM_KEZD) TYPE  DATUM
*"     VALUE(I_KAM_VEG) TYPE  DATUM
*"     VALUE(I_FIELD_NRK) TYPE  /ZAK/FIELDNRK
*"  EXPORTING
*"     VALUE(E_KAMAT) TYPE  /ZAK/FIELDN
*"----------------------------------------------------------------------
*  TABLES: T056P.
  DATA: BEGIN OF L_KAMAT OCCURS 0,
          DATUM TYPE DATUM,
          ZSOLL LIKE T056P-ZSOLL,
          KAMAT LIKE /ZAK/BEVALLO-FIELD_N,
        END OF L_KAMAT.
  DATA: L_ZSOLL_SAVE TYPE AZINSSATZ.
  DATA: L_KEZD_DATUM TYPE DATUM.
  DATA: L_KEZD TYPE DATAB_INV,
        L_VEG  TYPE DATAB_INV.
  DATA: LW_T056P TYPE T056P.
  DATA: L_T056P   TYPE STANDARD TABLE OF T056P INITIAL SIZE 0.
  DATA  L_REFER TYPE REFERENZ.
  DATA  L_DAYS  TYPE INT4.
  DATA: L_ZINSEN(16)       TYPE P DECIMALS 2,
        L_ZINSEN3(16)      TYPE P DECIMALS 3,
        L_ZINSEN3_SAVE(16) TYPE P DECIMALS 3,
        L_ZINSEN5(16)      TYPE P DECIMALS 5,
        L_ZINS             TYPE P DECIMALS 2.

  PERFORM CONV_DATUM_T056P USING    I_KAM_KEZD
                           CHANGING L_KEZD .
  PERFORM CONV_DATUM_T056P USING    I_KAM_VEG
                           CHANGING L_VEG .
  CLEAR L_REFER.
  SELECT SINGLE REFERENZ INTO L_REFER
                         FROM /ZAK/START
                        WHERE BUKRS EQ I_BUKRS.
  IF SY-SUBRC EQ 0 AND NOT L_REFER IS INITIAL.
    SELECT * INTO TABLE L_T056P FROM T056P
             WHERE REFERENZ EQ L_REFER AND
                   DATAB <= L_KEZD AND
                   DATAB >= L_VEG.
  ENDIF.
* létrehozok egy belső táblát, ami csak a dátumokhoz
* tartozó pótlék százalékokat tartalmazza!
  LOOP AT L_T056P INTO LW_T056P.
    PERFORM INVDT_OUTPUT USING LW_T056P-DATAB
                         CHANGING L_KAMAT-DATUM.
    L_KAMAT-ZSOLL = LW_T056P-ZSOLL.
    APPEND L_KAMAT.
  ENDLOOP.
* pótlék számítása!!
  L_KEZD_DATUM = I_KAM_KEZD.
  DO .
    IF SY-INDEX EQ 1.
      SELECT * FROM  T056P INTO  LW_T056P UP TO 1 ROWS
             WHERE  REFERENZ     = L_REFER
             AND    DATAB       >= L_KEZD ORDER BY PRIMARY KEY.
      ENDSELECT.
      PERFORM INVDT_OUTPUT USING LW_T056P-DATAB
                           CHANGING L_KAMAT-DATUM.
      L_KAMAT-ZSOLL = LW_T056P-ZSOLL.
    ELSE.
      READ TABLE L_KAMAT WITH KEY DATUM = L_KEZD_DATUM.
    ENDIF.
* dátumhoz tartozó kamat meghatározása
* a kezdő tátumot megelőző
    IF SY-SUBRC <> 0.

    ENDIF.
    IF L_KEZD_DATUM > I_KAM_VEG.
      L_DAYS = I_KAM_VEG - I_KAM_KEZD + 1.
      L_ZINSEN5 = L_ZINSEN3_SAVE / 100.
      L_ZINSEN  = FLOOR( ( I_FIELD_NRK * L_ZINSEN5 * L_DAYS )  * 100 ) / 100.
      ADD L_ZINSEN TO L_ZINS.
      EXIT.
    ELSE.
*---------------------------------------------------------------------*
* pótlék számítás                                                     *
* Formel:                                                             *
*                          kamat                                      *
*         zins   = --------------------  / 100 * összeg * napszám     *
*                        év napszám                                   *
* év napszám  - napszám                                               *
*            360 - im Bankkalender und im franz. Kalender             *
*            365 - im gregorianischen Kalender, sofern kein Schaltjahr*
*            366 - im gregorianischen Kalender, sofern ein Schaltjahr *
* INTEREST_RATE_COMPUTE ????
*---------------------------------------------------------------------*
      IF NOT L_ZSOLL_SAVE IS INITIAL AND  L_KAMAT-ZSOLL NE L_ZSOLL_SAVE.
        L_DAYS = L_KAMAT-DATUM - I_KAM_KEZD.
        L_ZINSEN5 = L_ZINSEN3_SAVE / 100.
        L_ZINSEN  = FLOOR( ( I_FIELD_NRK * L_ZINSEN5 * L_DAYS )  * 100 ) / 100.
        ADD L_ZINSEN TO L_ZINS.
        CLEAR L_DAYS.
        CLEAR L_ZINSEN3_SAVE.
        I_KAM_KEZD = L_KAMAT-DATUM.
      ENDIF.
      L_ZINSEN3 = FLOOR( ( L_KAMAT-ZSOLL / 365 ) * 1000 ) / 1000.
      IF L_ZINSEN3_SAVE  IS INITIAL.
        L_ZSOLL_SAVE   = L_KAMAT-ZSOLL.
        L_ZINSEN3_SAVE = L_ZINSEN3.
      ENDIF.
      ADD 1 TO L_KEZD_DATUM.
    ENDIF.
  ENDDO.
  E_KAMAT = L_ZINS.

* ++ CST 2006.06.04: 1,5 szörös kamat érték.
  IF I_ZINDEX >= '002'.
    E_KAMAT = E_KAMAT * '1.5'.
  ENDIF.

ENDFUNCTION.
