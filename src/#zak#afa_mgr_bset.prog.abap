*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_MGR_BSET
*&
*&---------------------------------------------------------------------*
*& Program: Load VAT codes and operation keys based on table BSET
*&
*&---------------------------------------------------------------------*
REPORT  /ZAK/AFA_MGR_BSET MESSAGE-ID /ZAK/ZAK.

*++S4HANA#01.
*TABLES /ZAK/BSET.
DATA GS_/ZAK/BSET TYPE /ZAK/BSET.
*--S4HANA#01.

INCLUDE /ZAK/COMMON_STRUCT.


*For BSET selection
DATA W_/ZAK/BSET  TYPE /ZAK/BSET.
DATA I_/ZAK/BSET  TYPE STANDARD TABLE OF /ZAK/BSET   INITIAL SIZE 0.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

*++S4HANA#01.
*  SELECT-OPTIONS S_BUKRS FOR /ZAK/BSET-BUKRS.
  SELECT-OPTIONS S_BUKRS FOR GS_/ZAK/BSET-BUKRS.
*--S4HANA#01.

SELECTION-SCREEN: END OF BLOCK BL01.

*++1765 #19.
INITIALIZATION.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You are not authorized to run the program!
  ENDIF.
*--1765 #19.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM SEL_DATA.

  PERFORM UPDATE_DATA.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  SEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEL_DATA .

*++S4HANA#01.
  TYPES: BEGIN OF TS_BSET_NEW,
           MWSKZ LIKE W_/ZAK/BSET-MWSKZ,
           KTOSL LIKE W_/ZAK/BSET-KTOSL,
           BUKRS TYPE BSET-BUKRS,
           BELNR TYPE BSET-BELNR,
           GJAHR TYPE BSET-GJAHR,
           BUZEI TYPE BSET-BUZEI,
         END OF TS_BSET_NEW.
  DATA: LT_BSET_NEW TYPE HASHED TABLE OF TS_BSET_NEW
    WITH UNIQUE KEY BUKRS BELNR GJAHR BUZEI.
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BSET
           FROM /ZAK/BSET
          WHERE BUKRS IN S_BUKRS
            AND ( MWSKZ EQ '' OR KTOSL EQ '' ).
  IF SY-SUBRC NE 0.
    MESSAGE I000 WITH 'Nincs a feltételnek megfelelő adat!'(001).
*   & & & &
    EXIT.
  ELSE.
*++S4HANA#01.
    IF NOT I_/ZAK/BSET[] IS INITIAL.
      DATA(LT_W_/ZAK/BSET_DRV) = I_/ZAK/BSET[].
      SORT LT_W_/ZAK/BSET_DRV BY BUKRS BELNR GJAHR BUZEI.
      DELETE ADJACENT DUPLICATES FROM LT_W_/ZAK/BSET_DRV
        COMPARING BUKRS BELNR GJAHR BUZEI.
      SELECT MWSKZ KTOSL BUKRS BELNR GJAHR BUZEI
        FROM BSET
        INTO CORRESPONDING FIELDS OF TABLE LT_BSET_NEW
        FOR ALL ENTRIES IN LT_W_/ZAK/BSET_DRV
        WHERE BUKRS EQ LT_W_/ZAK/BSET_DRV-BUKRS
        AND   BELNR EQ LT_W_/ZAK/BSET_DRV-BELNR
        AND   GJAHR EQ LT_W_/ZAK/BSET_DRV-GJAHR
        AND   BUZEI EQ LT_W_/ZAK/BSET_DRV-BUZEI
        ORDER BY PRIMARY KEY.  "$smart(M): #601

      FREE LT_W_/ZAK/BSET_DRV[].
    ENDIF.
*--S4HANA#01.
    LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET.
*++S4HANA#01.
*      SELECT SINGLE MWSKZ KTOSL INTO (W_/ZAK/BSET-MWSKZ,
*                                      W_/ZAK/BSET-KTOSL)
*                           FROM BSET
*                          WHERE BUKRS EQ W_/ZAK/BSET-BUKRS
*                            AND BELNR EQ W_/ZAK/BSET-BELNR
*                            AND GJAHR EQ W_/ZAK/BSET-GJAHR
*                            AND BUZEI EQ W_/ZAK/BSET-BUZEI.
      ASSIGN LT_BSET_NEW[
             BUKRS = W_/ZAK/BSET-BUKRS
             BELNR = W_/ZAK/BSET-BELNR
             GJAHR = W_/ZAK/BSET-GJAHR
             BUZEI = W_/ZAK/BSET-BUZEI
      ] TO FIELD-SYMBOL(<LS_BSET_NEW>).
*--S4HANA#01.
      IF SY-SUBRC EQ 0.
*++S4HANA#01.
        W_/ZAK/BSET-MWSKZ = <LS_BSET_NEW>-MWSKZ.
        W_/ZAK/BSET-KTOSL = <LS_BSET_NEW>-KTOSL.
*--S4HANA#01.
        MODIFY I_/ZAK/BSET FROM W_/ZAK/BSET TRANSPORTING MWSKZ KTOSL.
      ENDIF.
    ENDLOOP.
*++S4HANA#01.
    FREE LT_BSET_NEW[].
*--S4HANA#01.
  ENDIF.


ENDFORM.                    " SEL_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_DATA .

  IF NOT I_/ZAK/BSET[] IS INITIAL.
*   Update table BSET.
    UPDATE /ZAK/BSET FROM TABLE I_/ZAK/BSET.
    COMMIT WORK AND WAIT.
    MESSAGE I000 WITH 'Adatbázis módosítás befejezve!'(002).
*   & & & &

  ENDIF.

ENDFORM.                    " UPDATE_DATA
