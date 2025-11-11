*&---------------------------------------------------------------------*
*& Report  /ZAK/BUKRS_CORR
*&
*&---------------------------------------------------------------------*
*& A program a /ZAK/AFA_SZLA BELNR mezőt tölti fel vezető 0-val
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_SZLA_BELNR_CONV MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/AFA_SZLA.



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


DATA I_/ZAK/AFA_SZLA TYPE STANDARD TABLE OF /ZAK/AFA_SZLA INITIAL SIZE 0
.
DATA W_/ZAK/AFA_SZLA TYPE /ZAK/AFA_SZLA.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
*SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
PARAMETERS P_SIZE TYPE I DEFAULT '100000' OBLIGATORY.
*SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
  IF SY-SUBRC NE 0.
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

  SELECT * INTO TABLE I_/ZAK/AFA_SZLA
            PACKAGE SIZE P_SIZE
            FROM /ZAK/AFA_SZLA
           WHERE BSEG_GJAHR EQ '0000'.

    DELETE /ZAK/AFA_SZLA FROM TABLE I_/ZAK/AFA_SZLA.
    LOOP AT I_/ZAK/AFA_SZLA INTO W_/ZAK/AFA_SZLA.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = W_/ZAK/AFA_SZLA-BSEG_BELNR
        IMPORTING
          OUTPUT = W_/ZAK/AFA_SZLA-BSEG_BELNR.

      MODIFY I_/ZAK/AFA_SZLA FROM W_/ZAK/AFA_SZLA TRANSPORTING BSEG_BELNR.
    ENDLOOP.
    INSERT /ZAK/AFA_SZLA FROM TABLE I_/ZAK/AFA_SZLA.
  ENDSELECT.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE I216.
* Adatmódosítások elmentve!
  ENDIF.

ENDFORM.                    " PROCESS_DATA
