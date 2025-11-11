*&---------------------------------------------------------------------*
*& Report  /ZAK/BUKRS_CORR
*&
*&---------------------------------------------------------------------*
*& A program a /ZAK/ANALITIKA táblában feltölti az FI vállalat a
*& /ZAK/BSET-ben az ADÓ vállalat mezőket.
*&---------------------------------------------------------------------*

REPORT  /ZAK/BUKRS_CORR MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.



*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
*      Belső tábla         -   (I_xxx...)                              *
*      FORM paraméter      -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Paraméter változó   -   (P_xxx...)                              *
*      Szelekciós opció    -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Globális változók   -   (V_xxx...)                              *
*      Lokális változók    -   (L_xxx...)                              *
*      Munkaterület        -   (W_xxx...)                              *
*      Típus               -   (T_xxx...)                              *
*      Makrók              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Osztály             -   (CL_xxx...)                             *
*      Esemény             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

DATA I_/ZAK/BSET TYPE STANDARD TABLE OF /ZAK/BSET INITIAL SIZE 0.
DATA W_/ZAK/BSET TYPE /ZAK/BSET.

DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0
.
DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
PARAMETERS P_SIZE TYPE I DEFAULT '100000' OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   Önnek nincs jogosultsága a program futtatásához!
  ENDIF.
*--1765 #19.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Adatok feldolgozása
  PERFORM PROCESS_DATA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
            PACKAGE SIZE P_SIZE
            FROM /ZAK/ANALITIKA
           WHERE BUKRS EQ P_BUKRS.

    REFRESH I_/ZAK/BSET.

    LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
      IF W_/ZAK/ANALITIKA-BUKRS EQ 'MMOB'.
        MOVE 'MA01' TO W_/ZAK/ANALITIKA-FI_BUKRS.
      ELSE.
        MOVE W_/ZAK/ANALITIKA-BUKRS TO W_/ZAK/ANALITIKA-FI_BUKRS.
      ENDIF.
*     /ZAK/BSET update
      IF W_/ZAK/ANALITIKA-BTYPE EQ '0665' OR
         W_/ZAK/ANALITIKA-BTYPE EQ '0765'.
        SELECT SINGLE * INTO W_/ZAK/BSET
                        FROM /ZAK/BSET
                       WHERE BUKRS EQ W_/ZAK/ANALITIKA-FI_BUKRS
                         AND BELNR EQ W_/ZAK/ANALITIKA-BSEG_BELNR
                         AND GJAHR EQ W_/ZAK/ANALITIKA-BSEG_GJAHR
                         AND BUZEI EQ W_/ZAK/ANALITIKA-BSEG_BUZEI.
        IF SY-SUBRC EQ 0.
          MOVE W_/ZAK/ANALITIKA-BUKRS TO W_/ZAK/BSET-AD_BUKRS.
          APPEND W_/ZAK/BSET TO I_/ZAK/BSET.
        ENDIF.
      ENDIF.
      MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING FI_BUKRS.
    ENDLOOP.
    IF NOT I_/ZAK/BSET[] IS INITIAL.
      UPDATE /ZAK/BSET FROM TABLE I_/ZAK/BSET.
    ENDIF.
    UPDATE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
  ENDSELECT.

  COMMIT WORK AND WAIT.
  MESSAGE I216.
* Adatmódosítások elmentve!

ENDFORM.                    " PROCESS_DATA
