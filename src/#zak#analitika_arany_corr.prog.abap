**&---------------------------------------------------------------------*
**& Report  /ZAK/ANALITIKA_ARANY_CORR
**&
**&---------------------------------------------------------------------*
**& A program az arányosított sorok FIELD_A mezőt tölti fel
**&---------------------------------------------------------------------*
REPORT  /ZAK/ANALITIKA_ARANY_CORR  MESSAGE-ID /ZAK/ZAK.
*
**&---------------------------------------------------------------------*
**& TÁBLÁK                                                              *
**&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.
*
**&---------------------------------------------------------------------*
**& PROGRAM VÁLTOZÓK                                                    *
**      Belső tábla         -   (I_xxx...)                              *
**      FORM paraméter      -   ($xxxx...)                              *
**      Konstans            -   (C_xxx...)                              *
**      Paraméter változó   -   (P_xxx...)                              *
**      Szelekciós opció    -   (S_xxx...)                              *
**      Sorozatok (Range)   -   (R_xxx...)                              *
**      Globális változók   -   (V_xxx...)                              *
**      Lokális változók    -   (L_xxx...)                              *
**      Munkaterület        -   (W_xxx...)                              *
**      Típus               -   (T_xxx...)                              *
**      Makrók              -   (M_xxx...)                              *
**      Field-symbol        -   (FS_xxx...)                             *
**      Methodus            -   (METH_xxx...)                           *
**      Objektum            -   (O_xxx...)                              *
**      Osztály             -   (CL_xxx...)                             *
**      Esemény             -   (E_xxx...)                              *
**&---------------------------------------------------------------------*
**MAKRO definiálás range feltöltéshez
*DEFINE M_DEF.
*  MOVE: &2      TO &1-SIGN,
*        &3      TO &1-OPTION,
*        &4      TO &1-LOW,
*        &5      TO &1-HIGH.
*  APPEND &1.
*END-OF-DEFINITION.
*
DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                          INITIAL SIZE 0.
DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
*
*DATA W_/ZAK/AFA_SZLA TYPE /ZAK/AFA_SZLA.
*
*DATA I_/ZAK/SZLA_CORR_ALV TYPE STANDARD TABLE OF /ZAK/SZLA_CORR_ALV
*                          INITIAL SIZE 0.
*DATA W_/ZAK/SZLA_CORR_ALV TYPE /ZAK/SZLA_CORR_ALV.
**
DATA:
      LT_RET  TYPE TABLE OF BAPIRET2,
      LO_ALV  TYPE REF TO CL_SALV_TABLE,
      LO_COLS TYPE REF TO CL_SALV_COLUMNS,
      LO_FUNC TYPE REF TO CL_SALV_FUNCTIONS_LIST.
*
**&---------------------------------------------------------------------*
** SELECTION-SCREEN
**&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
SELECT-OPTIONS S_BUKRS  FOR /ZAK/ANALITIKA-BUKRS NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS S_BTYPE  FOR /ZAK/ANALITIKA-BTYPE NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS S_GJAHR  FOR /ZAK/ANALITIKA-GJAHR NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS S_MONAT  FOR /ZAK/ANALITIKA-MONAT.
SELECT-OPTIONS S_INDEX  FOR /ZAK/ANALITIKA-ZINDEX.
*SELECT-OPTIONS S_BGJAHR  FOR /ZAK/ANALITIKA-BSEG_GJAHR.
*SELECT-OPTIONS S_BBELNR  FOR /ZAK/ANALITIKA-BSEG_BELNR.
*SELECT-OPTIONS S_SZAML   FOR /ZAK/ANALITIKA-SZAMLASZ.
*SELECT-OPTIONS S_SZAMLA  FOR /ZAK/ANALITIKA-SZAMLASZA.
*SELECT-OPTIONS S_SZAMLE  FOR /ZAK/ANALITIKA-SZAMLASZE.
*SELECT-OPTIONS S_SZLAT   FOR /ZAK/ANALITIKA-SZLATIP.
**SELECT-OPTIONS S_BSZNUM FOR /ZAK/ANALITIKA-BSZNUM.
**SELECT-OPTIONS S_ADOAZ  FOR /ZAK/ANALITIKA-ADOAZON.
*
PARAMETER P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL01.
**
***&---------------------------------------------------------------------*
*** INITALIZATION
***&---------------------------------------------------------------------*
**INITIALIZATION.
**
**  M_DEF S_BTYPE 'I' 'EQ' '0665' SPACE.
**  M_DEF S_BTYPE 'I' 'EQ' '0765' SPACE.
**
**++1765 #19.
*INITIALIZATION.
** Jogosultság vizsgálat
*  AUTHORITY-CHECK OBJECT 'S_TCODE'
*                  ID 'TCD'  FIELD SY-TCODE.
**++1865 #03.
**  IF SY-SUBRC NE 0.
*  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
**--1865 #03.
*    MESSAGE E152(/ZAK/ZAK).
**   Önnek nincs jogosultsága a program futtatásához!
*  ENDIF.
**--1765 #19.
***&---------------------------------------------------------------------*
*** AT SELECTION-SCREEN OUTPUT
***&---------------------------------------------------------------------*
**AT SELECTION-SCREEN OUTPUT.
**
***  Képernyő attribútomok beállítása
**  PERFORM SET_SCREEN_ATTRIBUTES.
**
**&---------------------------------------------------------------------*
** START-OF-SELECTION
**&---------------------------------------------------------------------*
START-OF-SELECTION.
*
* Adatok feldolgozása
  PERFORM PROCESS_DATA.
  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I000 WITH 'Nincs a szelekciónak megfelelő adat!'.
*   & & & &
    EXIT.
  ENDIF.

  IF P_TEST IS INITIAL.
    MODIFY /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
    COMMIT WORK AND WAIT.
    MESSAGE I216.
*   Adatmódosítások elmentve!
  ENDIF.
*
*
**&---------------------------------------------------------------------*
** END-OF-SELECTION
**&---------------------------------------------------------------------*
END-OF-SELECTION.
**ALV
  IF SY-BATCH IS INITIAL AND NOT P_TEST IS INITIAL.
    CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV
                            CHANGING  T_TABLE = I_/ZAK/ANALITIKA ).
    LO_COLS = LO_ALV->GET_COLUMNS( ).
    LO_COLS->SET_OPTIMIZE( ).
    LO_FUNC  = LO_ALV->GET_FUNCTIONS( ).
    LO_FUNC->SET_ALL( ABAP_TRUE ).
    LO_ALV->DISPLAY( ).
  ENDIF.
***&---------------------------------------------------------------------*
***&      Form  SET_SCREEN_ATTRIBUTES
***&---------------------------------------------------------------------*
***       text
***----------------------------------------------------------------------*
***  -->  p1        text
***  <--  p2        text
***----------------------------------------------------------------------*
**FORM SET_SCREEN_ATTRIBUTES .
**
**  LOOP AT SCREEN.
**    IF SCREEN-GROUP1 = 'DIS'.
**      SCREEN-INPUT = 0.
**      SCREEN-OUTPUT = 1.
**      MODIFY SCREEN.
**    ENDIF.
**  ENDLOOP.
**
**ENDFORM.                    " SET_SCREEN_ATTRIBUTES
**&---------------------------------------------------------------------*
**&      Form  PROCESS_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM PROCESS_DATA .

  DATA LW_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS  IN S_BUKRS
            AND BTYPE  IN S_BTYPE
            AND GJAHR  IN S_GJAHR
            AND MONAT  IN S_MONAT
            AND ZINDEX IN S_INDEX.

* Csak az arányosított sorok kellenek:
  DELETE I_/ZAK/ANALITIKA WHERE ARANY_FLAG NE 'X'.


  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
    LW_/ZAK/ANALITIKA = W_/ZAK/ANALITIKA.
    PERFORM GET_FIELD_A(/ZAK/AFA_SAP_SELN) USING W_/ZAK/ANALITIKA.
    IF LW_/ZAK/ANALITIKA EQ W_/ZAK/ANALITIKA.
      DELETE I_/ZAK/ANALITIKA.
    ELSE.
      MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING FIELD_A.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " PROCESS_DATA
