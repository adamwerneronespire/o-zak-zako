*&---------------------------------------------------------------------*
*& Report  /ZAK/MCOM_REPI_CORR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/ANALITIKA_MOVE MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott adatokat átmozgatja
*& a megadott időszakra.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2009.10.09
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 50
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx
*&                                   xxxxxxx xxxxxxx xxxxxxx
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
*++2065 #08.
TABLES: /ZAK/ANALITIKA.
*--2065 #08.
TYPE-POOLS: SLIS.
*ALV közös rutinok
INCLUDE /ZAK/ALV_LIST_FORMS.

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
*INCLUDE /ZAK/COMMON_STRUCT.

DATA I_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA OCCURS 0.
DATA I_/ZAK/BEVALLSZ  LIKE /ZAK/BEVALLSZ  OCCURS 0.
DATA W_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA.
DATA W_/ZAK/BEVALLSZ  LIKE /ZAK/BEVALLSZ.
*++1365 #18.
DATA I_/ZAK/AFA_SZLA  LIKE /ZAK/AFA_SZLA OCCURS 0.
DATA W_/ZAK/AFA_SZLA  LIKE /ZAK/AFA_SZLA.

DATA I_/ZAK/BSET      LIKE /ZAK/BSET OCCURS 0.
DATA W_/ZAK/BSET      LIKE /ZAK/BSET.
*--1365 #18.
*++2265 #10.
CONSTANTS: C_BTYPART_AFA  TYPE /ZAK/BTYPART VALUE 'AFA'.
CONSTANTS: C_ACTVT_01(2) VALUE '01'. "Programok futtatása,létr.,mód.
*--2265 #10.
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.
PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
PARAMETERS P_BTYPE LIKE /ZAK/ANALITIKA-BTYPE OBLIGATORY.
PARAMETERS P_GJAHR LIKE /ZAK/ANALITIKA-GJAHR OBLIGATORY.
PARAMETERS P_MONAT LIKE /ZAK/ANALITIKA-MONAT OBLIGATORY.
PARAMETERS P_INDEX LIKE /ZAK/ANALITIKA-ZINDEX OBLIGATORY.
*++2065 #08.
SELECT-OPTIONS S_PACK FOR /ZAK/ANALITIKA-PACK.
*--2065 #08.
SELECTION-SCREEN END OF BLOCK B01.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
PARAMETERS P_CBUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
PARAMETERS P_CBTYPE LIKE /ZAK/ANALITIKA-BTYPE OBLIGATORY.
PARAMETERS P_CGJAHR LIKE /ZAK/ANALITIKA-GJAHR OBLIGATORY.
PARAMETERS P_CMONAT LIKE /ZAK/ANALITIKA-MONAT OBLIGATORY.
PARAMETERS P_CINDEX LIKE /ZAK/ANALITIKA-ZINDEX OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B02.

SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-B03.
PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK B03.
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*

*-----------------------------------------------------------------------
* AT SELECTION-SCREEN
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIF_SCREEN.

AT SELECTION-SCREEN.
  PERFORM VERIFY_TARGET.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++2365 #02.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                   ID 'TCD'  FIELD '/ZAK/ANALITIKA_MOVE'.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
    MESSAGE E152(/ZAK/ZAK).
*   Önnek nincs jogosultsága a program futtatásához!
  ENDIF.
*--2365 #02.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*++2265 #10.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT '/ZAK/BTYPR'
                  ID 'BUKRS'      FIELD P_BUKRS
                  ID 'ACTVT'      FIELD C_BTYPART_AFA
                  ID '/ZAK/BTYPR' FIELD C_ACTVT_01.
  IF SY-SUBRC NE 0.
    MESSAGE E152(/ZAK/ZAK).
*   Önnek nincs jogosultsága a program futtatásához!
  ENDIF.
*--2265 #10.
*Adatok szelektálása:
  PERFORM SEL_DATA.

  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.

*Adatok feldolgozása
  PERFORM PROCESS_DATA.

*Adatbázis műveletek
  PERFORM MODIFY_DATA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM ALV_LIST TABLES  I_/ZAK/ANALITIKA
                   USING  'I_/ZAK/ANALITIKA'.


*&---------------------------------------------------------------------*
*&      Form  modif_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_SCREEN.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'OUT'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " modif_screen
*&---------------------------------------------------------------------*
*&      Form  sel_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEL_DATA .


  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_INDEX
*++2065 #08.
            AND PACK IN S_PACK.
*--2065 #08.


  SELECT * INTO TABLE I_/ZAK/BEVALLSZ
           FROM /ZAK/BEVALLSZ
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_INDEX
*++2065 #08.
            AND PACK IN S_PACK.
*--2065 #08.

*++1365 #18.
  SELECT * INTO TABLE I_/ZAK/AFA_SZLA
           FROM /ZAK/AFA_SZLA
          WHERE BUKRS EQ P_BUKRS
*++2065 #08.
            AND PACK IN S_PACK
*--2065 #08.
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_INDEX.

  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
    SELECT * APPENDING TABLE I_/ZAK/BSET
             FROM /ZAK/BSET
            WHERE BUKRS EQ W_/ZAK/ANALITIKA-FI_BUKRS
              AND BELNR EQ W_/ZAK/ANALITIKA-BSEG_BELNR
              AND GJAHR EQ W_/ZAK/ANALITIKA-BSEG_GJAHR
              AND BUZEI EQ W_/ZAK/ANALITIKA-BSEG_BUZEI.
  ENDLOOP.
  SORT I_/ZAK/BSET.
  DELETE ADJACENT DUPLICATES FROM  I_/ZAK/BSET
                  COMPARING BUKRS BELNR GJAHR BUZEI.
*--1365 #18.


ENDFORM.                    " sel_data
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .

  CLEAR W_/ZAK/ANALITIKA.

  W_/ZAK/ANALITIKA-BUKRS = P_CBUKRS.
  W_/ZAK/ANALITIKA-BTYPE = P_CBTYPE.
  W_/ZAK/ANALITIKA-GJAHR = P_CGJAHR.
  W_/ZAK/ANALITIKA-MONAT = P_CMONAT.
  W_/ZAK/ANALITIKA-ZINDEX = P_CINDEX.


  MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA
                       TRANSPORTING BUKRS BTYPE GJAHR MONAT ZINDEX
                        WHERE BUKRS EQ P_BUKRS.

  W_/ZAK/BEVALLSZ-BUKRS = P_CBUKRS.
  W_/ZAK/BEVALLSZ-BTYPE = P_CBTYPE.
  W_/ZAK/BEVALLSZ-GJAHR = P_CGJAHR.
  W_/ZAK/BEVALLSZ-MONAT = P_CMONAT.
  W_/ZAK/BEVALLSZ-ZINDEX = P_CINDEX.


  MODIFY I_/ZAK/BEVALLSZ FROM W_/ZAK/BEVALLSZ
                       TRANSPORTING BUKRS BTYPE GJAHR MONAT ZINDEX
                        WHERE BUKRS EQ P_BUKRS.

*++1365 #18.
  W_/ZAK/AFA_SZLA-BUKRS = P_CBUKRS.
  W_/ZAK/AFA_SZLA-GJAHR = P_CGJAHR.
  W_/ZAK/AFA_SZLA-MONAT = P_CMONAT.
  W_/ZAK/AFA_SZLA-ZINDEX = P_CINDEX.

  MODIFY I_/ZAK/AFA_SZLA FROM W_/ZAK/AFA_SZLA
                       TRANSPORTING BUKRS GJAHR MONAT ZINDEX
                        WHERE BUKRS EQ P_BUKRS.

  LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET.
    CONCATENATE P_CGJAHR P_CMONAT INTO  W_/ZAK/BSET-BUPER.
    W_/ZAK/BSET-ZINDEX =  P_CINDEX.
    IF NOT W_/ZAK/BSET-AD_BUKRS IS INITIAL.
      W_/ZAK/BSET-AD_BUKRS = P_CBUKRS.
    ENDIF.
    MODIFY I_/ZAK/BSET FROM W_/ZAK/BSET.
  ENDLOOP.
*--1365 #18.


ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  VERIFY_TARGET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VERIFY_TARGET .

  DATA L_FLAG TYPE /ZAK/FLAG.


  IF P_BTYPE NE P_CBTYPE.
*++2265 #09.
*    MESSAGE E000 WITH 'Bevallás típus nem egyezik meg!'.
    MESSAGE W000 WITH 'Bevallás típus nem egyezik meg!'.
*--2265 #09
*   & & & &
  ENDIF.

  SELECT SINGLE FLAG INTO L_FLAG
         FROM  /ZAK/BEVALLI
         WHERE BUKRS EQ P_CBUKRS
           AND BTYPE EQ P_CBTYPE
           AND GJAHR EQ P_CGJAHR
           AND MONAT EQ P_CMONAT
           AND ZINDEX EQ P_CINDEX.
  IF SY-SUBRC NE 0.
    MESSAGE E000 WITH 'Cél időszak nincs megnyitva!'.
*   & & & &
  ENDIF.

  IF L_FLAG CA 'ZX'.
    MESSAGE E000 WITH 'Cél időszak lezárva!'.
*   & & & &
  ENDIF.


ENDFORM.                    " VERIFY_TARGET

*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
FORM ALV_LIST  TABLES   $TAB
                USING   $TAB_NAME.

*ALV lista init
  PERFORM COMMON_ALV_LIST_INIT USING SY-TITLE
                                     $TAB_NAME
                                     '/ZAK/ANALITIKA_MOVE'.

*ALV lista
  PERFORM COMMON_ALV_GRID_DISPLAY TABLES $TAB
                                  USING  $TAB_NAME
                                         ''
                                         ''.

ENDFORM.                    " LIST_SPOOL
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA .

  CHECK P_TEST IS INITIAL.
*++1365 #19.
  DELETE  FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_INDEX
*++2065 #08.
            AND PACK IN S_PACK.
*--2065 #08.
*--1365 #19.
  INSERT /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
*++1365 #19.
  DELETE  FROM /ZAK/BEVALLSZ
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_INDEX
*++2065 #08.
            AND PACK IN S_PACK.
*--2065 #08.
*--1365 #19.
  INSERT /ZAK/BEVALLSZ  FROM TABLE I_/ZAK/BEVALLSZ
*++1365 #18.
         ACCEPTING DUPLICATE KEYS.
*++1365 #19.
  DELETE  FROM /ZAK/AFA_SZLA
          WHERE BUKRS EQ P_BUKRS
*++2065 #08.
            AND PACK IN S_PACK
*--2065 #08.
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_INDEX.
*--1365 #19.
  INSERT /ZAK/AFA_SZLA  FROM TABLE I_/ZAK/AFA_SZLA
         ACCEPTING DUPLICATE KEYS.

  UPDATE /ZAK/BSET FROM TABLE I_/ZAK/BSET.
*--1365 #18.
*++1365 #19.
*  DELETE  FROM /ZAK/ANALITIKA
*          WHERE BUKRS EQ P_BUKRS
*            AND BTYPE EQ P_BTYPE
*            AND GJAHR EQ P_GJAHR
*            AND MONAT EQ P_MONAT
*            AND ZINDEX EQ P_INDEX.
*  DELETE  FROM /ZAK/BEVALLSZ
*          WHERE BUKRS EQ P_BUKRS
*            AND BTYPE EQ P_BTYPE
*            AND GJAHR EQ P_GJAHR
*            AND MONAT EQ P_MONAT
*            AND ZINDEX EQ P_INDEX.
*
*++2065 #08.
  SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALLSZ
                WHERE BUKRS EQ P_BUKRS
                  AND BTYPE EQ P_BTYPE
                  AND GJAHR EQ P_GJAHR
                  AND MONAT EQ P_MONAT
                  AND ZINDEX EQ P_INDEX.
  IF SY-SUBRC  NE 0.
*--2065 #08.
    DELETE  FROM /ZAK/BEVALLI
            WHERE BUKRS EQ P_BUKRS
              AND BTYPE EQ P_BTYPE
              AND GJAHR EQ P_GJAHR
              AND MONAT EQ P_MONAT
              AND ZINDEX EQ P_INDEX.
*++2065 #08.
  ENDIF.
*--2065 #08.
**++1365 #18.
*  DELETE  FROM /ZAK/AFA_SZLA
*          WHERE BUKRS EQ P_BUKRS
*            AND GJAHR EQ P_GJAHR
*            AND MONAT EQ P_MONAT
*            AND ZINDEX EQ P_INDEX.
**--1365 #18.
*--1365 #19.

  COMMIT WORK AND WAIT.

  MESSAGE I007.
*   Tábla módosítások elvégezve!


ENDFORM.                    " MODIFY_DATA
