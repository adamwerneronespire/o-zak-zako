*&---------------------------------------------------------------------*
*& Report  /ZAK/ONYB_DEL_DATA
*&
*&---------------------------------------------------------------------*
*& Funkció leírás: Adatok törlése
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2009.03.30
*& Funkc.spec.készítő: Róth Nándor
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 50
*&---------------------------------------------------------------------*

REPORT  /ZAK/ONYB_DEL_DATA MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                      LEÍRÁS
*& ----   ----------   ----------    -----------------------------------
*&
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.



*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*


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
  COLLECT &1.
END-OF-DEFINITION.


RANGES R_BTYPE FOR /ZAK/ANALITIKA-BTYPE.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(75) TEXT-101.

  SELECTION-SCREEN END OF LINE.
*Vállalat
  SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS.
*Bevallás típus
  SELECT-OPTIONS S_BTYPE FOR /ZAK/ANALITIKA-BTYPE.
*Év
  SELECT-OPTIONS S_GJAHR FOR /ZAK/ANALITIKA-GJAHR.
*Hónap
  SELECT-OPTIONS S_MONAT FOR /ZAK/ANALITIKA-MONAT.

SELECTION-SCREEN END OF BLOCK BL01.

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
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Meghatározzuk a BTYPE-okat:
  PERFORM GET_BTYPE.
  IF R_BTYPE[] IS INITIAL.
    MESSAGE E000 WITH 'Nem lehet releváns bevallás típust meghatározni'.
*   & & & &
  ENDIF.

* /ZAK/ZAK_BEVASZ és /ZAK/BEVALLI törlés:
  PERFORM PROGRESS_INDICATOR USING TEXT-P02
                                   0
                                   0.
  PERFORM DEK_/ZAK/BEVALLSZ.

* /ZAK/ANALITIKA törlés
  PERFORM PROGRESS_INDICATOR USING TEXT-P03
                                   0
                                   0.
  PERFORM DEL_/ZAK/ANALITIKA.

* /ZAK/BEVALLO törlés
  PERFORM PROGRESS_INDICATOR USING TEXT-P04
                                   0
                                   0.
  PERFORM DEL_/ZAK/BEVALLO.

  COMMIT WORK AND WAIT.

  MESSAGE I000 WITH 'Adatbázis törlés befejezve!'.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  get_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BTYPE .

*Csak ÁFA BTYPE-ok kellenek 0865 előttiek:
*++S4HANA#01.
*  SELECT * INTO W_/ZAK/BEVALL
  SELECT BTYPE INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALL
*--S4HANA#01.
             FROM /ZAK/BEVALL
            WHERE BUKRS IN S_BUKRS
              AND BTYPE IN S_BTYPE
              AND BTYPART EQ C_BTYPART_ONYB.
    IF W_/ZAK/BEVALL-BTYPE(2) < '08'.
      M_DEF R_BTYPE 'I' 'EQ' W_/ZAK/BEVALL-BTYPE SPACE.
    ENDIF.
  ENDSELECT.

ENDFORM.                    " get_btype
*&---------------------------------------------------------------------*
*&      Form  DEK_/ZAK/BEVALLSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEK_/ZAK/BEVALLSZ .

  DELETE FROM /ZAK/BEVALLI
        WHERE BUKRS IN S_BUKRS
          AND BTYPE IN R_BTYPE
          AND GJAHR IN S_GJAHR
          AND MONAT IN S_MONAT.

  DELETE FROM /ZAK/BEVALLSZ
        WHERE BUKRS IN S_BUKRS
          AND BTYPE IN R_BTYPE
          AND GJAHR IN S_GJAHR
          AND MONAT IN S_MONAT.


ENDFORM.                    " DEK_/ZAK/BEVALLSZ


*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM PROGRESS_INDICATOR USING  $TEXT
FORM PROGRESS_INDICATOR USING  $TEXT TYPE CLIKE
*--S4HANA#01.
                               $LINES
                               $ACT_LINE.
  DATA L_PERCENTAGE TYPE I.
  DATA L_DIVIDE TYPE P DECIMALS 2.

  CLEAR L_PERCENTAGE.

  IF NOT $LINES IS INITIAL AND NOT $ACT_LINE IS INITIAL.
    L_DIVIDE = $ACT_LINE / $LINES  * 100.
    L_PERCENTAGE = TRUNC( L_DIVIDE ).
  ENDIF.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = L_PERCENTAGE
      TEXT       = $TEXT.


ENDFORM.                    " PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  DEL_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_/ZAK/ANALITIKA .

  DELETE   FROM /ZAK/ANALITIKA
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT.

ENDFORM.                    " DEL_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  DEL_/ZAK/BEVALLO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_/ZAK/BEVALLO .

  DELETE   FROM /ZAK/BEVALLO
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT.

ENDFORM.                    " DEL_/ZAK/BEVALLO
