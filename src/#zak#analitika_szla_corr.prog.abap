**&---------------------------------------------------------------------*
**& Report  /ZAK/ANALITIKA_SZLA_CORR
**&
**&---------------------------------------------------------------------*
**& A program a közös számla azonosítót tölti fel a szelekció alapján
**&---------------------------------------------------------------------*
REPORT  /ZAK/ANALITIKA_SZLA_CORR  MESSAGE-ID /ZAK/ZAK.
*
**&---------------------------------------------------------------------*
**& TÁBLÁK                                                              *
**&---------------------------------------------------------------------*
*TABLES: /ZAK/ANALITIKA.
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
*DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
*                          INITIAL SIZE 0.
*DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
*
*DATA W_/ZAK/AFA_SZLA TYPE /ZAK/AFA_SZLA.
*
*DATA I_/ZAK/SZLA_CORR_ALV TYPE STANDARD TABLE OF /ZAK/SZLA_CORR_ALV
*                          INITIAL SIZE 0.
*DATA W_/ZAK/SZLA_CORR_ALV TYPE /ZAK/SZLA_CORR_ALV.
**
*DATA:
*      LT_RET  TYPE TABLE OF BAPIRET2,
*      LO_ALV  TYPE REF TO CL_SALV_TABLE,
*      LO_COLS TYPE REF TO CL_SALV_COLUMNS,
*      LO_FUNC TYPE REF TO CL_SALV_FUNCTIONS_LIST.
*
**&---------------------------------------------------------------------*
** SELECTION-SCREEN
**&---------------------------------------------------------------------*
*SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*SELECT-OPTIONS S_BUKRS  FOR /ZAK/ANALITIKA-BUKRS.
*SELECT-OPTIONS S_BTYPE  FOR /ZAK/ANALITIKA-BTYPE.
*SELECT-OPTIONS S_GJAHR  FOR /ZAK/ANALITIKA-GJAHR.
*SELECT-OPTIONS S_MONAT  FOR /ZAK/ANALITIKA-MONAT.
*SELECT-OPTIONS S_INDEX  FOR /ZAK/ANALITIKA-ZINDEX.
*SELECT-OPTIONS S_BGJAHR  FOR /ZAK/ANALITIKA-BSEG_GJAHR.
*SELECT-OPTIONS S_BBELNR  FOR /ZAK/ANALITIKA-BSEG_BELNR.
*SELECT-OPTIONS S_SZAML   FOR /ZAK/ANALITIKA-SZAMLASZ.
*SELECT-OPTIONS S_SZAMLA  FOR /ZAK/ANALITIKA-SZAMLASZA.
*SELECT-OPTIONS S_SZAMLE  FOR /ZAK/ANALITIKA-SZAMLASZE.
*SELECT-OPTIONS S_SZLAT   FOR /ZAK/ANALITIKA-SZLATIP.
**SELECT-OPTIONS S_BSZNUM FOR /ZAK/ANALITIKA-BSZNUM.
**SELECT-OPTIONS S_ADOAZ  FOR /ZAK/ANALITIKA-ADOAZON.
*
*PARAMETER P_TEST AS CHECKBOX DEFAULT 'X'.
*SELECTION-SCREEN: END OF BLOCK BL01.
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
*START-OF-SELECTION.
*
** Adatok feldolgozása
*  PERFORM PROCESS_DATA.
*  IF I_/ZAK/ANALITIKA[] IS INITIAL.
*    MESSAGE I000 WITH 'Nincs a szelekciónak megfelelő adat!'.
**   & & & &
*    EXIT.
*  ENDIF.
*
*  IF P_TEST IS INITIAL.
*    MODIFY /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
*    COMMIT WORK AND WAIT.
*    MESSAGE I216.
**   Adatmódosítások elmentve!
*  ENDIF.
*
*
**&---------------------------------------------------------------------*
** END-OF-SELECTION
**&---------------------------------------------------------------------*
*END-OF-SELECTION.
**ALV
*  CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV
*                          CHANGING  T_TABLE = I_/ZAK/SZLA_CORR_ALV ).
*  LO_COLS = LO_ALV->GET_COLUMNS( ).
*  LO_COLS->SET_OPTIMIZE( ).
*  LO_FUNC  = LO_ALV->GET_FUNCTIONS( ).
*  LO_FUNC->SET_ALL( ABAP_TRUE ).
*  LO_ALV->DISPLAY( ).
*
*
**
**
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
*FORM PROCESS_DATA .
*
*
*  SELECT * INTO TABLE I_/ZAK/ANALITIKA
*           FROM /ZAK/ANALITIKA
*          WHERE BUKRS  IN S_BUKRS
*            AND BTYPE  IN S_BTYPE
*            AND GJAHR  IN S_GJAHR
*            AND MONAT  IN S_MONAT
*            AND ZINDEX IN S_INDEX
*            AND ABEVAZ EQ 'DUMMY_R'
*            AND BSEG_GJAHR IN S_BGJAHR
*            AND BSEG_BELNR IN S_BBELNR
*            AND SZAMLASZ  IN S_SZAML
*            AND SZAMLASZA IN S_SZAMLA
*            AND SZAMLASZE IN S_SZAMLE
*            AND SZLATIP   IN S_SZLAT.
*
*  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*
*    SELECT SINGLE * INTO W_/ZAK/AFA_SZLA
*           FROM /ZAK/AFA_SZLA
*          WHERE BUKRS      EQ W_/ZAK/ANALITIKA-BUKRS
*            AND ADOAZON    EQ W_/ZAK/ANALITIKA-ADOAZON
*            AND BSEG_GJAHR EQ W_/ZAK/ANALITIKA-BSEG_GJAHR
*            AND BSEG_BELNR EQ W_/ZAK/ANALITIKA-BSEG_BELNR
*            AND BSEG_BUZEI EQ W_/ZAK/ANALITIKA-BSEG_BUZEI.
**   Valamelyik mező eltér
*    IF  W_/ZAK/ANALITIKA-SZAMLASZ  NE W_/ZAK/AFA_SZLA-SZAMLASZ OR
*        W_/ZAK/ANALITIKA-SZAMLASZA NE W_/ZAK/AFA_SZLA-SZAMLASZA OR
*        W_/ZAK/ANALITIKA-SZAMLASZE NE W_/ZAK/AFA_SZLA-SZAMLASZE OR
*        W_/ZAK/ANALITIKA-SZLATIP   NE W_/ZAK/AFA_SZLA-SZLATIP.
*      CLEAR W_/ZAK/SZLA_CORR_ALV.
*      MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_/ZAK/SZLA_CORR_ALV.
*      W_/ZAK/SZLA_CORR_ALV-A_NYLAPAZON = W_/ZAK/ANALITIKA-NYLAPAZON.
*      W_/ZAK/SZLA_CORR_ALV-A_SZAMLASZA = W_/ZAK/ANALITIKA-SZAMLASZA.
*      W_/ZAK/SZLA_CORR_ALV-A_SZAMLASZ  = W_/ZAK/ANALITIKA-SZAMLASZ.
*      W_/ZAK/SZLA_CORR_ALV-A_SZAMLASZE = W_/ZAK/ANALITIKA-SZAMLASZE.
*      W_/ZAK/SZLA_CORR_ALV-A_SZLATIP   = W_/ZAK/ANALITIKA-SZLATIP.
*
*      W_/ZAK/SZLA_CORR_ALV-SZ_NYLAPAZON = W_/ZAK/AFA_SZLA-NYLAPAZON.
*      W_/ZAK/SZLA_CORR_ALV-SZ_SZAMLASZA = W_/ZAK/AFA_SZLA-SZAMLASZA.
*      W_/ZAK/SZLA_CORR_ALV-SZ_SZAMLASZ  = W_/ZAK/AFA_SZLA-SZAMLASZ.
*      W_/ZAK/SZLA_CORR_ALV-SZ_SZAMLASZE = W_/ZAK/AFA_SZLA-SZAMLASZE.
*      W_/ZAK/SZLA_CORR_ALV-SZ_SZLATIP   = W_/ZAK/AFA_SZLA-SZLATIP.
*      W_/ZAK/SZLA_CORR_ALV-NONEED       = W_/ZAK/AFA_SZLA-NONEED.
*
*      APPEND W_/ZAK/SZLA_CORR_ALV TO I_/ZAK/SZLA_CORR_ALV.
*
*
*      W_/ZAK/ANALITIKA-SZAMLASZ  =  W_/ZAK/AFA_SZLA-SZAMLASZ.
*      W_/ZAK/ANALITIKA-SZAMLASZA =  W_/ZAK/AFA_SZLA-SZAMLASZA.
*      W_/ZAK/ANALITIKA-SZAMLASZE =  W_/ZAK/AFA_SZLA-SZAMLASZE.
*      W_/ZAK/ANALITIKA-SZLATIP   =  W_/ZAK/AFA_SZLA-SZLATIP.
*      MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA.
*    ELSE.
*      DELETE I_/ZAK/ANALITIKA.
*    ENDIF.
*
*  ENDLOOP.
*
*ENDFORM.                    " PROCESS_DATA


*++S4HANA#01.
**&---------------------------------------------------------------------*
**& TÁBLÁK                                                              *
**&---------------------------------------------------------------------*
*DATA GS_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.                                                        "$smart: #902
*
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
*DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
*                          INITIAL SIZE 0.
*DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
**
**DATA I_/ZAK/ANAL_C1 TYPE STANDARD TABLE OF /ZAK/ANAL_C1
**                          INITIAL SIZE 0.
**DATA W_/ZAK/ANAL_C1 TYPE /ZAK/ANAL_C1.
**
*DATA:
*      LT_RET  TYPE TABLE OF BAPIRET2,
*      LO_ALV  TYPE REF TO CL_SALV_TABLE,
*      LO_COLS TYPE REF TO CL_SALV_COLUMNS.
*
**&---------------------------------------------------------------------*
** SELECTION-SCREEN
**&---------------------------------------------------------------------*
*SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*SELECT-OPTIONS S_BUKRS  FOR GS_/ZAK/ANALITIKA-BUKRS.                                              "$smart: #902
*SELECT-OPTIONS S_BTYPE  FOR GS_/ZAK/ANALITIKA-BTYPE.                                              "$smart: #902
*SELECT-OPTIONS S_GJAHR  FOR GS_/ZAK/ANALITIKA-GJAHR.                                              "$smart: #902
*SELECT-OPTIONS S_MONAT  FOR GS_/ZAK/ANALITIKA-MONAT.                                              "$smart: #902
*SELECT-OPTIONS S_BSZNUM FOR GS_/ZAK/ANALITIKA-BSZNUM.                                             "$smart: #902
*SELECT-OPTIONS S_ADOAZ  FOR GS_/ZAK/ANALITIKA-ADOAZON.                                            "$smart: #902
*
*PARAMETER P_TEST TYPE C AS CHECKBOX DEFAULT 'X'.                                                 "$smart: #139
*SELECTION-SCREEN: END OF BLOCK BL01.
**
***&---------------------------------------------------------------------*
*** INITALIZATION
***&---------------------------------------------------------------------*
**INITIALIZATION.
**
**  M_DEF S_BTYPE 'I' 'EQ' '0665' SPACE.
**  M_DEF S_BTYPE 'I' 'EQ' '0765' SPACE.
**
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
*START-OF-SELECTION.
*
** Adatok feldolgozása
*  PERFORM PROCESS_DATA.
*  IF I_/ZAK/ANALITIKA[] IS INITIAL.
*    MESSAGE I000 WITH 'Nincs a szelekciónak megfelelő adat!'.
**   & & & &
*  ENDIF.
*
*  IF P_TEST IS INITIAL.
*    MODIFY /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
*    COMMIT WORK AND WAIT.
*    MESSAGE I216.
**   Adatmódosítások elmentve!
*  ENDIF.
*
*
**&---------------------------------------------------------------------*
** END-OF-SELECTION
**&---------------------------------------------------------------------*
*END-OF-SELECTION.
**ALV
*  CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV
*                          CHANGING  T_TABLE = I_/ZAK/ANALITIKA ).
*  LO_COLS = LO_ALV->GET_COLUMNS( ).
*  LO_COLS->SET_OPTIMIZE( ).
*  LO_ALV->DISPLAY( ).
*
*
**
**
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
*FORM PROCESS_DATA .
*
*  SELECT * INTO TABLE I_/ZAK/ANALITIKA
*           FROM /ZAK/ANALITIKA
*          WHERE BUKRS  IN S_BUKRS
*            AND BTYPE  IN S_BTYPE
*            AND GJAHR  IN S_GJAHR
*            AND MONAT  IN S_MONAT
*            AND ABEVAZ EQ 'DUMMY_R'
*            AND ADOAZON IN S_ADOAZ
*            AND BSZNUM IN S_BSZNUM
*            AND SZAMLASZA EQ ''                                                                  "$smart: #712
*    ORDER BY PRIMARY KEY.                                                                         "$smart(M): #601
*  . "#EC CI_ALL_FIELDS_NEEDED (confirmed full access)                                            "$smart: #712
*
*  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*    IF W_/ZAK/ANALITIKA-SZLATIP EQ 'E'.
*      W_/ZAK/ANALITIKA-SZAMLASZA = W_/ZAK/ANALITIKA-SZAMLASZ.
*    ELSEIF W_/ZAK/ANALITIKA-SZLATIP EQ 'K'.
*      SELECT SZAMLASZA INTO W_/ZAK/ANALITIKA-SZAMLASZA                                            "$smart: #601
*             FROM /ZAK/AFA_SZLA UP TO 1 ROWS                                                      "$smart: #601
*            WHERE BUKRS     EQ W_/ZAK/ANALITIKA-BUKRS
*              AND ADOAZON   EQ W_/ZAK/ANALITIKA-ADOAZON
**              AND PACK      EQ W_/ZAK/ANALITIKA-PACK
*              AND SZAMLASZ  EQ W_/ZAK/ANALITIKA-SZAMLASZ
*              AND SZAMLASZE EQ W_/ZAK/ANALITIKA-SZAMLASZE
*              AND NYLAPAZON EQ W_/ZAK/ANALITIKA-NYLAPAZON
*              AND SZLATIP   EQ W_/ZAK/ANALITIKA-SZLATIP
*            ORDER BY PRIMARY KEY.                                                                "$smart: #601
*      ENDSELECT.                                                                                 "$smart: #601
*      IF SY-SUBRC NE 0.
*        CLEAR W_/ZAK/ANALITIKA-SZAMLASZA.
*      ENDIF.
*    ENDIF.
*    MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING SZAMLASZA.
*  ENDLOOP.
*
*ENDFORM.                    " PROCESS_DATA
*--S4HANA#01.
