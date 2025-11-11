*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_CONV_0865
*&
*&---------------------------------------------------------------------*
*& Funkció leírás: Adatok konvertálása 0865-re. (0665,0765).
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2009.01.21
*& Funkc.spec.készítő: Róth Nándor
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 50
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_CONV_0865 MESSAGE-ID /ZAK/ZAK.

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
CONSTANTS: C_0865 TYPE /ZAK/BTYPE VALUE '0865'.

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


DATA: I_/ZAK/BEVALL_NEW    TYPE STANDARD TABLE
                            OF /ZAK/BEVALL  INITIAL SIZE 0,
      I_/ZAK/BEVALLT_NEW   TYPE STANDARD TABLE
                            OF /ZAK/BEVALLT  INITIAL SIZE 0,
      I_/ZAK/BEVALLI_NEW   TYPE STANDARD TABLE
                            OF /ZAK/BEVALLI  INITIAL SIZE 0,
      I_/ZAK/BEVALLSZ_NEW  TYPE STANDARD TABLE
                            OF /ZAK/BEVALLSZ INITIAL SIZE 0,
      I_/ZAK/ANALITIKA_NEW TYPE STANDARD TABLE
                            OF /ZAK/ANALITIKA INITIAL SIZE 0,
      I_/ZAK/BEVALLO_NEW   TYPE STANDARD TABLE
                            OF /ZAK/BEVALLO INITIAL SIZE 0.



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
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*



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

* /ZAK/BEVALL és /ZAK/BEVALLT konverzió:
  PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                   0
                                   0.
  PERFORM CONV_/ZAK/BEVALL.


* /ZAK/ZAK_BEVASZ és /ZAK/BEVALLI konverzió:
  PERFORM PROGRESS_INDICATOR USING TEXT-P02
                                   0
                                   0.
  PERFORM CONV_/ZAK/BEVALLSZ.


* /ZAK/ANALITIKA konverzió
  PERFORM PROGRESS_INDICATOR USING TEXT-P03
                                   0
                                   0.
  PERFORM CONV_/ZAK/ANALITIKA.

* /ZAK/BEVALLO konverzió
  PERFORM PROGRESS_INDICATOR USING TEXT-P05
                                   0
                                   0.
  PERFORM CONV_/ZAK/BEVALLO.


* Adatbázis módosítások:
  PERFORM PROGRESS_INDICATOR USING TEXT-P07
                                   0
                                   0.

  PERFORM COMMIT.

  MESSAGE I000 WITH 'Adatbázis módosítások befejezve!'.


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
             AND BTYPART EQ C_BTYPART_AFA.
    IF W_/ZAK/BEVALL-BTYPE(2) < '08'.
      M_DEF R_BTYPE 'I' 'EQ' W_/ZAK/BEVALL-BTYPE SPACE.
    ENDIF.
  ENDSELECT.

ENDFORM.                    " get_btype
*
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*FORM PROGRESS_INDICATOR USING  $TEXT
FORM PROGRESS_INDICATOR USING  $TEXT TYPE CLIKE
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
*&      Form  CONV_/ZAK/BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONV_/ZAK/BEVALL .

*++S4HANA#01.
*  REFRESH: I_/ZAK/BEVALL, I_/ZAK/BEVALLT.
  CLEAR: I_/ZAK/BEVALL[].
  CLEAR: I_/ZAK/BEVALLT[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALL
           FROM /ZAK/BEVALL
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE.

  IF I_/ZAK/BEVALL[] IS INITIAL.
    MESSAGE I000 WITH 'Nincs releváns /ZAK/BEVALL rekord!'.
    EXIT.
  ENDIF.

  SELECT * INTO TABLE I_/ZAK/BEVALLT
           FROM /ZAK/BEVALLT
           FOR ALL ENTRIES IN I_/ZAK/BEVALL
           WHERE BUKRS EQ I_/ZAK/BEVALL-BUKRS
             AND BTYPE EQ I_/ZAK/BEVALL-BTYPE
             AND DATBI EQ I_/ZAK/BEVALL-DATBI.

* Új rekordok képzése:
  LOOP AT I_/ZAK/BEVALL INTO W_/ZAK/BEVALL.
    W_/ZAK/BEVALL-BTYPE  = C_0865.
    W_/ZAK/BEVALL-BTYPEE = C_0865.
    APPEND W_/ZAK/BEVALL TO I_/ZAK/BEVALL_NEW.
  ENDLOOP.

  LOOP AT I_/ZAK/BEVALLT INTO W_/ZAK/BEVALLT.
    W_/ZAK/BEVALLT-BTYPE = C_0865.
    APPEND W_/ZAK/BEVALLT TO I_/ZAK/BEVALLT_NEW.
  ENDLOOP.

  FREE: I_/ZAK/BEVALL, I_/ZAK/BEVALLT.

ENDFORM.                    " CONV_/ZAK/BEVALL
*&---------------------------------------------------------------------*
*&      Form  CONV_/ZAK/BEVALLSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONV_/ZAK/BEVALLSZ .

*++S4HANA#01.
*  REFRESH: I_/ZAK/BEVALLI, I_/ZAK/BEVALLSZ.
  CLEAR: I_/ZAK/BEVALLI[].
  CLEAR: I_/ZAK/BEVALLSZ[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLI
           FROM /ZAK/BEVALLI
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT.
  IF I_/ZAK/BEVALLI[] IS INITIAL.
    MESSAGE I000 WITH 'Nincs releváns /ZAK/BEVALLI rekord!'.
    EXIT.
  ENDIF.

  SELECT * INTO TABLE I_/ZAK/BEVALLSZ
           FROM /ZAK/BEVALLSZ
           FOR ALL ENTRIES IN I_/ZAK/BEVALLI
           WHERE BUKRS EQ I_/ZAK/BEVALLI-BUKRS
             AND BTYPE EQ I_/ZAK/BEVALLI-BTYPE
             AND GJAHR EQ I_/ZAK/BEVALLI-GJAHR
             AND MONAT EQ I_/ZAK/BEVALLI-MONAT.

* Új rekordok képzése:
  LOOP AT I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
    W_/ZAK/BEVALLI-BTYPE = C_0865.
    APPEND W_/ZAK/BEVALLI TO I_/ZAK/BEVALLI_NEW.
  ENDLOOP.

  LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ.
    W_/ZAK/BEVALLSZ-BTYPE = C_0865.
    APPEND W_/ZAK/BEVALLSZ TO I_/ZAK/BEVALLSZ_NEW.
  ENDLOOP.

  FREE: I_/ZAK/BEVALLI, I_/ZAK/BEVALLSZ.

ENDFORM.                    " CONV_/ZAK/BEVALLSZ
*&---------------------------------------------------------------------*
*&      Form  CONV_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONV_/ZAK/ANALITIKA .

  DATA LI_BEVALLO_ALV LIKE /ZAK/BEVALLALV OCCURS 0 WITH HEADER LINE.
  DATA L_LINES LIKE SY-TABIX.


*Adatok leválogatása
*++S4HANA#01.
*  REFRESH: I_/ZAK/ANALITIKA, LI_BEVALLO_ALV.
  CLEAR: I_/ZAK/ANALITIKA[].
  CLEAR: LI_BEVALLO_ALV[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT
*++S4HANA#01.
          ORDER BY PRIMARY KEY.
*--S4HANA#01.
  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I000 WITH 'Nincs releváns /ZAK/ANALITIKA rekord!'.
    EXIT.
  ENDIF.

*++S4HANA#01.
*  DESCRIBE TABLE I_/ZAK/ANALITIKA LINES L_LINES.
  L_LINES = LINES( I_/ZAK/ANALITIKA ).
*--S4HANA#01.

  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*   Adatok konverzió
    PERFORM PROGRESS_INDICATOR USING TEXT-P04
                                     L_LINES
                                     SY-TABIX.

*++S4HANA#01.
*    REFRESH LI_BEVALLO_ALV.
    CLEAR LI_BEVALLO_ALV[].
*--S4HANA#01.
    CLEAR LI_BEVALLO_ALV.
    MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO LI_BEVALLO_ALV.
*++S4HANA#01.
*    APPEND LI_BEVALLO_ALV.
    APPEND LI_BEVALLO_ALV TO LI_BEVALLO_ALV.
*--S4HANA#01.

    CALL FUNCTION '/ZAK/BTYPE_CONVERSION'
      EXPORTING
        I_BUKRS          = W_/ZAK/ANALITIKA-BUKRS
        I_BTYPE_FROM     = W_/ZAK/ANALITIKA-BTYPE
        I_BTYPE_TO       = C_0865
      TABLES
        T_BEVALLO        = LI_BEVALLO_ALV
      EXCEPTIONS
        CONVERSION_ERROR = 1
        VALIDITY_ERROR   = 2
        OTHERS           = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*++S4HANA#01.
*    READ TABLE LI_BEVALLO_ALV INDEX 1.
    READ TABLE LI_BEVALLO_ALV INTO LI_BEVALLO_ALV INDEX 1.
*--S4HANA#01.

    W_/ZAK/ANALITIKA-BTYPE   = C_0865.
    W_/ZAK/ANALITIKA-ABEVAZ  = LI_BEVALLO_ALV-ABEVAZ_DISP.
    APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
  ENDLOOP.

  FREE: I_/ZAK/ANALITIKA.


ENDFORM.                    " CONV_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  CONV_/ZAK/BEVALLO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONV_/ZAK/BEVALLO .

  DATA LI_BEVALLO_ALV LIKE /ZAK/BEVALLALV OCCURS 0 WITH HEADER LINE.
  DATA L_LINES LIKE SY-TABIX.


*Adatok leválogatása
*++S4HANA#01.
*  REFRESH: I_/ZAK/BEVALLO, LI_BEVALLO_ALV.
  CLEAR: I_/ZAK/BEVALLO[].
  CLEAR: LI_BEVALLO_ALV[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLO
           FROM /ZAK/BEVALLO
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT
*++S4HANA#01.
          ORDER BY PRIMARY KEY.
*--S4HANA#01.
  IF I_/ZAK/BEVALLO[] IS INITIAL.
    MESSAGE I000 WITH 'Nincs releváns /ZAK/BEVALLO rekord!'.
    EXIT.
  ENDIF.

*++S4HANA#01.
*  DESCRIBE TABLE I_/ZAK/BEVALLO LINES L_LINES.
  L_LINES = LINES( I_/ZAK/BEVALLO ).
*--S4HANA#01.

  LOOP AT I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO.
*   Adatok konverzió
    PERFORM PROGRESS_INDICATOR USING TEXT-P06
                                     L_LINES
                                     SY-TABIX.

*++S4HANA#01.
*    REFRESH LI_BEVALLO_ALV.
    CLEAR LI_BEVALLO_ALV[].
*--S4HANA#01.
    CLEAR LI_BEVALLO_ALV.
    MOVE-CORRESPONDING W_/ZAK/BEVALLO TO LI_BEVALLO_ALV.
*++S4HANA#01.
*    APPEND LI_BEVALLO_ALV.
    APPEND LI_BEVALLO_ALV TO LI_BEVALLO_ALV.
*--S4HANA#01.

    CALL FUNCTION '/ZAK/BTYPE_CONVERSION'
      EXPORTING
        I_BUKRS          = W_/ZAK/BEVALLO-BUKRS
        I_BTYPE_FROM     = W_/ZAK/BEVALLO-BTYPE
        I_BTYPE_TO       = C_0865
      TABLES
        T_BEVALLO        = LI_BEVALLO_ALV
      EXCEPTIONS
        CONVERSION_ERROR = 1
        VALIDITY_ERROR   = 2
        OTHERS           = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*++S4HANA#01.
*    READ TABLE LI_BEVALLO_ALV INDEX 1.
    READ TABLE LI_BEVALLO_ALV INTO LI_BEVALLO_ALV INDEX 1.
*--S4HANA#01.

    W_/ZAK/BEVALLO-BTYPE   = C_0865.
    W_/ZAK/BEVALLO-ABEVAZ  = LI_BEVALLO_ALV-ABEVAZ_DISP.
    W_/ZAK/BEVALLO-BTYPE_DISP = C_0865.
    W_/ZAK/BEVALLO-ABEVAZ_DISP = LI_BEVALLO_ALV-ABEVAZ_DISP.
    APPEND W_/ZAK/BEVALLO TO I_/ZAK/BEVALLO_NEW.
  ENDLOOP.

  FREE: I_/ZAK/BEVALLO.

ENDFORM.                    " CONV_/ZAK/BEVALLO
*&---------------------------------------------------------------------*
*&      Form  COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COMMIT .

  DEFINE L_MOD_DATA.
    IF NOT &1[] IS INITIAL.
      MODIFY &2 FROM TABLE &1.
    ENDIF.
  END-OF-DEFINITION.


  L_MOD_DATA: I_/ZAK/BEVALL_NEW /ZAK/BEVALL,
              I_/ZAK/BEVALLT_NEW /ZAK/BEVALLT,
              I_/ZAK/BEVALLI_NEW /ZAK/BEVALLI,
              I_/ZAK/BEVALLSZ_NEW /ZAK/BEVALLSZ,
              I_/ZAK/ANALITIKA_NEW /ZAK/ANALITIKA,
              I_/ZAK/BEVALLO_NEW /ZAK/BEVALLO.
  COMMIT WORK AND WAIT.

ENDFORM.                    " COMMIT
