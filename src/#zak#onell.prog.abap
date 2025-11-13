*&---------------------------------------------------------------------*
*& Program: Önellenőrzési jegyzőkönyv készítés
*&---------------------------------------------------------------------*

REPORT  /ZAK/ONELL MESSAGE-ID /ZAK/ZAK
                             LINE-SIZE  255
                             LINE-COUNT 65.

*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott adatok alapján
*& levállogatja a bevallás adataokat és elkészíti az önellenőrzés
*  jegyzőkönyvet.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2008.04.26
*& Funkc.spec.készítő: Róth Nándor
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    -----------------------------------
*& 0001   2008.11.26   Balázs Gábor  Szelekció módosítása, készült
*&                                   dátum  megadható bevallásonként
*&---------------------------------------------------------------------*
*++S4HANA#01.
DATA LI_FCODE TYPE TABLE OF SY-UCOMM.
DATA LT_STD_FCODES TYPE UI_FUNCTIONS.
DATA LT_EXCL_FUNC TYPE UI_FUNCTIONS.
*--S4HANA#01.
INCLUDE /ZAK/COMMON_STRUCT.

*Adatdeklaráció
INCLUDE /ZAK/ONJTOP.
*Közös rutinok
INCLUDE /ZAK/ONJF01.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
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
DATA G_INDEX LIKE SY-TABIX.

*Önellenőrzési pótlék összege.


* local class to handle semantic checks
CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

DATA: G_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*Űrlap neve:
  PARAMETERS P_FNAME LIKE SSFSCREEN-FNAME DEFAULT '/ZAK/ONJ_JEGYZOKONYV'
                                          MODIF ID DIS.
*Vállalat
  PARAMETERS P_BUKRS LIKE T001-BUKRS OBLIGATORY MEMORY ID BUK
                                     VALUE CHECK.
*Bevallás típus:
  PARAMETERS P_BTYPE LIKE /ZAK/BEVALLB-BTYPE OBLIGATORY.
*++0001 2008.11.26 (BG)
**Készült
*PARAMETERS P_KESZD LIKE /ZAK/ONJDATA-KESZULT DEFAULT SY-DATUM.
*--0001 2008.11.26 (BG)
SELECTION-SCREEN: END OF BLOCK BL01.

*++0001 2008.11.26 (BG)
SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-T03.
*Gazdasági év
  SELECT-OPTIONS S_GJAHR FOR /ZAK/ONJDATA-GJAHR.
*Gazdasági hónap
  SELECT-OPTIONS S_MONAT FOR /ZAK/ONJDATA-MONAT.
*Bevallás sorszáma időszakon belül
  SELECT-OPTIONS S_INDEX FOR /ZAK/ONJDATA-ZINDEX.
*Készült
  SELECT-OPTIONS S_KESZD FOR /ZAK/ONJDATA-KESZULT.
  SELECTION-SCREEN SKIP.
*--0001 2008.11.26 (BG)
  SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
*Teszt futás
    PARAMETERS:
      P_TEST RADIOBUTTON GROUP GR1 DEFAULT 'X',
      P_PROC RADIOBUTTON GROUP GR1,
      P_PROD RADIOBUTTON GROUP GR1,
      P_LIST RADIOBUTTON GROUP GR1.
  SELECTION-SCREEN: END OF BLOCK BL02.

SELECTION-SCREEN: END OF BLOCK BL03.

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS:
      HANDLE_DATA_CHANGED
        FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED.

  PRIVATE SECTION.

    METHODS: CHECK_KESZULT
      IMPORTING
        PS_GOOD_PLANETYPE TYPE LVC_S_MODI
        PR_DATA_CHANGED   TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

ENDCLASS.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_DATA_CHANGED.
    DATA: LS_GOOD TYPE LVC_S_MODI.

    LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD.
      CASE LS_GOOD-FIELDNAME.
        WHEN 'KESZULT'.
          CALL METHOD CHECK_KESZULT
            EXPORTING
              PS_GOOD_PLANETYPE = LS_GOOD
              PR_DATA_CHANGED   = ER_DATA_CHANGED.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.      "HANDLE_DATA_CHANGED

  METHOD CHECK_KESZULT.
    DATA L_KESZULT LIKE SY-DATUM.

    CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
      EXPORTING
        I_ROW_ID    = PS_GOOD_PLANETYPE-ROW_ID
        I_FIELDNAME = PS_GOOD_PLANETYPE-FIELDNAME
      IMPORTING
        E_VALUE     = L_KESZULT.

    READ TABLE I_ONJALV INTO W_ONJALV INDEX PS_GOOD_PLANETYPE-ROW_ID.
    W_ONJALV-KESZULT = L_KESZULT.
    MODIFY I_ONJALV FROM W_ONJALV INDEX PS_GOOD_PLANETYPE-ROW_ID
                    TRANSPORTING KESZULT.

  ENDMETHOD.                    "check_keszult
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.

  G_REPID = SY-REPID.
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
  PERFORM MODIF_SCREEN.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM VERIFY_SCREEN.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Bevallás fajta meghatározás
  CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
    EXPORTING
      I_BUKRS       = P_BUKRS
      I_BTYPE       = P_BTYPE
    IMPORTING
      E_BTYPART     = G_BTYPART
    EXCEPTIONS
      ERROR_IMP_PAR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING
                                P_BUKRS
                                G_BTYPART
                                C_ACTVT_01.


  PERFORM MESSAGES_INITIALIZE.

* Vállalati adatok beolvasása
  PERFORM GET_T001 USING P_BUKRS.

* Meghatározzuk a bevallás fajtát:
  PERFORM GET_BTYPART USING P_BUKRS
                            P_BTYPE
                   CHANGING G_BTYPART.

* Adatok meghatározása (teszt és előfeldolgozás)
  PERFORM GET_DATA TABLES I_ONJALV
                          I_ONJALV_SAVE
                          I_/ZAK/ADONEM
                          I_/ZAK/BEVALLI
*++0001 2008.11.26 (BG)
                          S_GJAHR
                          S_MONAT
                          S_INDEX
                          S_KESZD
*--0001 2008.11.26 (BG)
                   USING  P_BUKRS
                          P_BTYPE
*++0001 2008.11.26 (BG)
*                         P_KESZD
*--0001 2008.11.26 (BG)
                          G_BTYPART
                          P_TEST
                          P_PROD.

* Adatok meghatározása (éles futás)
  PERFORM GET_DATA_PROD TABLES I_ONJALV
                               I_/ZAK/ONJDATA
                               I_/ZAK/ONJDANA
                               I_/ZAK/BEVALLI
                        USING  P_BUKRS
                               P_PROD.


* Adatok meghatározása (megjelenítés)
  PERFORM GET_DATA_LIST TABLES I_ONJALV
                               I_/ZAK/ONJDATA
                               I_/ZAK/ONJDANA
                               S_GJAHR
                               S_MONAT
                               S_INDEX
                               S_KESZD
                        USING  P_BUKRS
                               P_BTYPE
                               P_LIST.

  IF I_ONJALV[] IS INITIAL.
    MESSAGE I031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.

* Üzenetek menetése
*++S4HANA#01.
*  PERFORM MESSAGE_SAVE_STORE USING G_INDEX
  PERFORM MESSAGE_SAVE_STORE CHANGING G_INDEX
                                      G_ERROR.
*--S4HANA#01.

* Üzenetek megjelenítése
  PERFORM SHOW_MESSAGES USING G_INDEX
                              P_TEST.


* Éles futás űrlap nyomtatás, adatok módosítás
  PERFORM PRODUCTIVE_RUN TABLES I_ONJALV
                                I_/ZAK/ONJDATA
                                I_/ZAK/BEVALLI
                         USING  P_PROD
                                P_FNAME.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* Lista kivitel
  PERFORM LIST_DISPLAY.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_G_BTYPART  text
*----------------------------------------------------------------------*
FORM GET_DATA  TABLES   $I_ONJALV      LIKE I_ONJALV
                        $I_ONJALV_SAVE LIKE I_ONJALV_SAVE
                        $I_/ZAK/ADONEM STRUCTURE /ZAK/ADONEM
                        $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
*++0001 2008.11.26 (BG)
                        $S_GJAHR STRUCTURE S_GJAHR
                        $S_MONAT STRUCTURE S_MONAT
                        $S_INDEX STRUCTURE S_INDEX
                        $S_KESZD STRUCTURE S_KESZD
*--0001 2008.11.26 (BG)
*++S4HANA#01.
*               USING    $BUKRS
*                        $BTYPE
**++0001 2008.11.26 (BG)
**                       $KESZD
**--0001 2008.11.26 (BG)
*                        $BTYPART
*                        $TEST
*                        $PROD.
               USING    $BUKRS TYPE T001-BUKRS
                        $BTYPE TYPE /ZAK/BEVALLB-BTYPE
                        $BTYPART TYPE /ZAK/BTYPART
                        $TEST LIKE P_TEST
                        $PROD LIKE P_PROD.
*--S4HANA#01.

  RANGES LR_ADONEM_ONELL FOR /ZAK/ADONEM-ADONEM.
  RANGES LR_FLAG FOR /ZAK/BEVALLI-FLAG.

  DATA L_ADONEM TYPE /ZAK/ADON.
  DATA L_TEXT TYPE STRING.
  DATA L_ONELL_OSSZEG TYPE /ZAK/DMBTR.
  DATA L_ESDAT_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA L_WAERS TYPE WAERS.
  DATA L_FIELD_C TYPE /ZAK/FIELDC.
  DATA L_/ZAK/TEXT TYPE /ZAK/TEXT.
  DATA L_ONEPOT TYPE /ZAK/ONEPOT.
  DATA L_ELO.
*++0001 2008.11.26 (BG)
  DATA L_KESZULT TYPE /ZAK/ERDAT.
*--0001 2008.11.26 (BG)

  CHECK $PROD IS INITIAL.

*Adónemek meghatározása
  SELECT * INTO TABLE $I_/ZAK/ADONEM
           FROM /ZAK/ADONEM
          WHERE BUKRS EQ $BUKRS.

* Önellenőrzés releváns adónemek meghatározása
  SELECT ADONEM INTO L_ADONEM
                FROM /ZAK/ADONEM
               WHERE BUKRS EQ $BUKRS
                 AND ONREL EQ C_X.
    M_DEF LR_ADONEM_ONELL 'I' 'EQ' L_ADONEM SPACE.
  ENDSELECT.

* Meghatározzuk az esedékesség dátum abev azonosítóját
  SELECT SINGLE ABEVAZ INTO L_ESDAT_ABEVAZ
         FROM /ZAK/BEVALLB
        WHERE BTYPE EQ $BTYPE
          AND ESDAT_FLAG EQ C_X.
  IF SY-SUBRC NE 0.
* Hiba a & bevallás esedékességi dátum meghatározásánál!
    PERFORM MESSAGE_STORE USING G_INDEX
                                'E'
                                '/ZAK/ZAK'
                                '272'
                                $BTYPE
                                SY-MSGV2
                                SY-MSGV3
                                SY-MSGV4.
  ENDIF.

* Meghatározzuk az időszakokat:
  M_DEF LR_FLAG 'I' 'EQ' 'Z' SPACE.
  M_DEF LR_FLAG 'I' 'EQ' 'X' SPACE.

  SELECT * INTO TABLE $I_/ZAK/BEVALLI
           FROM /ZAK/BEVALLI
          WHERE BUKRS EQ $BUKRS
            AND BTYPE EQ $BTYPE
*++0001 2008.11.26 (BG)
            AND GJAHR IN $S_GJAHR
            AND MONAT IN $S_MONAT
*--0001 2008.11.26 (BG)
            AND ZINDEX NE '000'
*++0001 2008.11.26 (BG)
            AND ZINDEX IN $S_INDEX
*--0001 2008.11.26 (BG)
            AND FLAG IN LR_FLAG
            AND ONJF NE C_X.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

* Adatok meghatározása adófolyószámla alapján
  LOOP AT $I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
*++S4HANA#01.
*    REFRESH: I_/ZAK/BEVALLO, I_/ZAK/ADONSZA.
    CLEAR: I_/ZAK/BEVALLO[].
    CLEAR: I_/ZAK/ADONSZA[].
*--S4HANA#01.
    CLEAR L_ONELL_OSSZEG.
    CLEAR L_/ZAK/TEXT.
    SELECT * INTO TABLE I_/ZAK/BEVALLO
             FROM /ZAK/BEVALLO
            WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS
              AND BTYPE EQ W_/ZAK/BEVALLI-BTYPE
              AND GJAHR EQ W_/ZAK/BEVALLI-GJAHR
              AND MONAT EQ W_/ZAK/BEVALLI-MONAT
              AND ZINDEX EQ W_/ZAK/BEVALLI-ZINDEX
*++S4HANA#01.
      ORDER BY PRIMARY KEY.
*--S4HANA#01.

    CONCATENATE W_/ZAK/BEVALLI-BUKRS
                W_/ZAK/BEVALLI-BTYPE
                W_/ZAK/BEVALLI-GJAHR
                W_/ZAK/BEVALLI-MONAT
                W_/ZAK/BEVALLI-ZINDEX INTO L_TEXT
                                     SEPARATED BY '/'.

    IF SY-SUBRC NE 0.
* Nem található adat a bevalláshoz (/ZAK/BEVALLO)! (&)
      PERFORM MESSAGE_STORE USING G_INDEX
                                  'E'
                                  '/ZAK/ZAK'
                                  '270'
                                  L_TEXT
                                  SY-MSGV2
                                  SY-MSGV3
                                  SY-MSGV4.


    ELSE.
*     Meghatározzuk létezik-e adat az előfeldolgozásban
*++0001 2008.11.26 (BG)
*     SELECT SINGLE /ZAK/TEXT ONEPOT
      SELECT SINGLE /ZAK/TEXT ONEPOT KESZULT
*--0001 2008.11.26 (BG)
                             INTO (L_/ZAK/TEXT,
*++0001 2008.11.26 (BG)
*                                  L_ONEPOT)
                                   L_ONEPOT,
                                   L_KESZULT)
*--0001 2008.11.26 (BG)
                             FROM /ZAK/ONJDATA
                            WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS
                              AND BTYPE EQ W_/ZAK/BEVALLI-BTYPE
                              AND GJAHR EQ W_/ZAK/BEVALLI-GJAHR
                              AND MONAT EQ W_/ZAK/BEVALLI-MONAT
                              AND ZINDEX EQ W_/ZAK/BEVALLI-ZINDEX
                              AND ONJSTAT EQ 'E'.
      IF SY-SUBRC NE 0.
        CLEAR: L_/ZAK/TEXT, L_ONEPOT, L_ELO.
      ELSE.
        MOVE 'X' TO L_ELO.
      ENDIF.

      CALL FUNCTION '/ZAK/POST_ADONSZA'
        EXPORTING
          I_BUKRS       = W_/ZAK/BEVALLI-BUKRS
          I_BTYPE       = W_/ZAK/BEVALLI-BTYPE
          I_GJAHR       = W_/ZAK/BEVALLI-GJAHR
          I_MONAT       = W_/ZAK/BEVALLI-MONAT
          I_INDEX       = W_/ZAK/BEVALLI-ZINDEX
          I_TESZT       = C_X
        TABLES
          T_BEVALLO     = I_/ZAK/BEVALLO
          T_ADONSZA     = I_/ZAK/ADONSZA
        EXCEPTIONS
          DATA_MISMATCH = 1
          OTHER_ERROR   = 2
          OTHERS        = 3.
      IF SY-SUBRC <> 0.
*       Hiba az adófolyószámla adatok meghatározásánál! (&)
        PERFORM MESSAGE_STORE USING G_INDEX
                                    'E'
                                    '/ZAK/ZAK'
                                    '271'
                                    L_TEXT
                                    SY-MSGV2
                                    SY-MSGV3
                                    SY-MSGV4.
      ELSE.
        LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA.
          CLEAR W_ONJALV.
*         Ha már volt feltöltve adat
          IF NOT L_/ZAK/TEXT IS INITIAL.
            MOVE L_/ZAK/TEXT TO W_ONJALV-/ZAK/TEXT.
          ENDIF.
*         Ha nem önellenőrzési adónem
*++1908 #09.
*          IF NOT W_/ZAK/ADONSZA-ADONEM IN LR_ADONEM_ONELL.
          IF NOT W_/ZAK/ADONSZA-ADONEM IN LR_ADONEM_ONELL OR LR_ADONEM_ONELL[] IS INITIAL.
*--1908 #09.
            MOVE W_/ZAK/BEVALLI-BUKRS TO W_ONJALV-BUKRS.
            MOVE W_/ZAK/BEVALLI-BTYPE TO W_ONJALV-BTYPE.
            MOVE W_/ZAK/BEVALLI-GJAHR TO W_ONJALV-GJAHR.
            MOVE W_/ZAK/BEVALLI-MONAT TO W_ONJALV-MONAT.
            MOVE W_/ZAK/BEVALLI-ZINDEX TO W_ONJALV-ZINDEX.
*++0001 2008.11.26 (BG)
*           MOVE $KESZD TO W_ONJALV-KESZULT.
            IF NOT L_KESZULT IS INITIAL.
              MOVE L_KESZULT TO W_ONJALV-KESZULT.
            ENDIF.
*--0001 2008.11.26 (BG)
*           Esedékességi dátum meghatározása
*           Beolvassuk az adónemet
            READ TABLE $I_/ZAK/ADONEM INTO W_/ZAK/ADONEM
                       WITH KEY BUKRS  = W_/ZAK/ADONSZA-BUKRS
                                ADONEM = W_/ZAK/ADONSZA-ADONEM.
            CLEAR: W_/ZAK/BEVALLO, W_/ZAK/BEVALLB.
            MOVE W_/ZAK/ADONSZA-BUKRS TO W_/ZAK/BEVALLO-BUKRS.
            MOVE W_/ZAK/BEVALLI-BTYPE TO W_/ZAK/BEVALLO-BTYPE.
            MOVE W_/ZAK/BEVALLI-GJAHR TO W_/ZAK/BEVALLO-GJAHR.
            MOVE W_/ZAK/BEVALLI-MONAT TO W_/ZAK/BEVALLO-MONAT.
*          Esedékességi dátum kiszámítása (/ZAK/POST_ADONSZA alapján)
*++S4HANA#01.
*            PERFORM GET_ESED_DAT(/ZAK/SAPLFUNCTIONS) USING W_/ZAK/BEVALLO
            PERFORM GET_ESED_DAT IN PROGRAM /ZAK/SAPLFUNCTIONS USING W_/ZAK/BEVALLO
*--S4HANA#01.
                                  W_/ZAK/BEVALLB
                                  $BUKRS
                                  '000'
                                  SY-DATUM
                                  W_/ZAK/ADONEM-FIZHAT
                         CHANGING W_ONJALV-ESDAT.
            IF W_ONJALV-ESDAT IS INITIAL.
*             Nem lehet meghatározni az eredeti esedékesség dátumát! (&)
              PERFORM MESSAGE_STORE USING G_INDEX
                                          'E'
                                          '/ZAK/ZAK'
                                          '273'
                                          L_TEXT
                                          SY-MSGV2
                                          SY-MSGV3
                                          SY-MSGV4.
            ENDIF.
            MOVE W_/ZAK/ADONSZA-ADONEM TO W_ONJALV-ADONEM.
            MOVE W_/ZAK/ADONSZA-WRBTR  TO W_ONJALV-OSSZEG.
            MOVE W_/ZAK/ADONSZA-WAERS  TO W_ONJALV-WAERS.
            MOVE W_/ZAK/ADONSZA-ESDAT  TO W_ONJALV-ONDAT.
            COLLECT W_ONJALV INTO $I_ONJALV.
*         Az önellenőrzési adónemeket összesítjük egy összegbe
          ELSE.
            MOVE W_/ZAK/ADONSZA-WAERS TO L_WAERS.
            ADD W_/ZAK/ADONSZA-WRBTR TO L_ONELL_OSSZEG.
          ENDIF.
        ENDLOOP.
        CLEAR W_ONJALV.
*       Ha már volt feltöltve adat
        IF NOT L_/ZAK/TEXT IS INITIAL.
          MOVE L_/ZAK/TEXT TO W_ONJALV-/ZAK/TEXT.
        ENDIF.
*       Önellenőrzés hozzáadás
        MOVE W_/ZAK/BEVALLI-BUKRS TO W_ONJALV-BUKRS.
        MOVE W_/ZAK/BEVALLI-BTYPE TO W_ONJALV-BTYPE.
        MOVE W_/ZAK/BEVALLI-GJAHR TO W_ONJALV-GJAHR.
        MOVE W_/ZAK/BEVALLI-MONAT TO W_ONJALV-MONAT.
        MOVE W_/ZAK/BEVALLI-ZINDEX TO W_ONJALV-ZINDEX.
*++0001 2008.11.26 (BG)
*       MOVE $KESZD TO W_ONJALV-KESZULT.
        IF NOT L_KESZULT IS INITIAL.
          MOVE L_KESZULT TO W_ONJALV-KESZULT.
        ENDIF.
*--0001 2008.11.26 (BG)
        MOVE C_ONELL TO W_ONJALV-ADONEM.
        IF L_ELO IS INITIAL.
          MOVE L_ONELL_OSSZEG TO W_ONJALV-OSSZEG.
        ELSE.
          MOVE L_ONEPOT TO W_ONJALV-OSSZEG.
        ENDIF.
        MOVE L_WAERS TO W_ONJALV-WAERS.
        APPEND W_ONJALV TO $I_ONJALV.
      ENDIF.
    ENDIF.
  ENDLOOP.

  $I_ONJALV_SAVE[] = $I_ONJALV[].

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  MESSAGES_INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MESSAGES_INITIALIZE .

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

ENDFORM.                    " MESSAGES_INITIALIZE

*&---------------------------------------------------------------------*
*&      Form  message_store
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM MESSAGE_STORE USING    $ZEILE
*                            $MSGTY
*                            $MSGID
*                            $MSGNO
*                            $VAR1
*                            $VAR2
*                            $VAR3
*                            $VAR4.
FORM MESSAGE_STORE USING    $ZEILE TYPE SY-TABIX
                            $MSGTY TYPE CLIKE
                            $MSGID TYPE CLIKE
                            $MSGNO TYPE CLIKE
                            $VAR1 TYPE CLIKE
                            $VAR2 TYPE SY-MSGV2
                            $VAR3 TYPE SY-MSGV3
                            $VAR4 TYPE SY-MSGV4.
*--S4HANA#01.

  DATA: L_MSG TYPE SMESG.



  CLEAR L_MSG.
*  ADD 1 TO $ZEILE.

  L_MSG-ARBGB = $MSGID.
  L_MSG-MSGTY = $MSGTY.
  L_MSG-ZEILE = $ZEILE.
  L_MSG-MSGV1 = $VAR1.
  L_MSG-MSGV2 = $VAR2.
  L_MSG-MSGV3 = $VAR3.
  L_MSG-MSGV4 = $VAR4.
  L_MSG-TXTNR = $MSGNO.

  COLLECT L_MSG INTO I_MESSAGE.

*  CALL FUNCTION 'MESSAGE_STORE'
*    EXPORTING
*     ARBGB                         = L_MSG-ARBGB
**    EXCEPTION_IF_NOT_ACTIVE       = 'X'
*     MSGTY                         = L_MSG-MSGTY
*     MSGV1                         = L_MSG-MSGV1
*     MSGV2                         = L_MSG-MSGV2
*     MSGV3                         = L_MSG-MSGV3
*     MSGV4                         = L_MSG-MSGV4
*     TXTNR                         = L_MSG-TXTNR
*     ZEILE                         = L_MSG-ZEILE
*   EXCEPTIONS
*     MESSAGE_TYPE_NOT_VALID        = 1
*     NOT_ACTIVE                    = 2
*     OTHERS                        = 3.

ENDFORM.                    " message_store

*&---------------------------------------------------------------------*
*&      Form  message_store
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM MESSAGE_SAVE_STORE USING $ZEILE
*                              $ERROR.
FORM MESSAGE_SAVE_STORE CHANGING $ZEILE TYPE SY-TABIX
                              $ERROR LIKE G_ERROR.
*--S4HANA#01.

  DATA: L_MSG TYPE SMESG.

  CLEAR L_MSG.
  LOOP AT I_MESSAGE INTO L_MSG.
    ADD 1 TO $ZEILE.
    IF L_MSG-MSGTY CA 'AE'.
      MOVE C_X TO $ERROR.
    ENDIF.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB                  = L_MSG-ARBGB
*       EXCEPTION_IF_NOT_ACTIVE       = 'X'
        MSGTY                  = L_MSG-MSGTY
        MSGV1                  = L_MSG-MSGV1
        MSGV2                  = L_MSG-MSGV2
        MSGV3                  = L_MSG-MSGV3
        MSGV4                  = L_MSG-MSGV4
        TXTNR                  = L_MSG-TXTNR
        ZEILE                  = L_MSG-ZEILE
      EXCEPTIONS
        MESSAGE_TYPE_NOT_VALID = 1
        NOT_ACTIVE             = 2
        OTHERS                 = 3.
  ENDLOOP.
ENDFORM.                    " message_store


*&---------------------------------------------------------------------*
*&      Form  show_messages
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM SHOW_MESSAGES USING $INDEX
*                         $TEST.
FORM SHOW_MESSAGES USING $INDEX TYPE SY-TABIX
                         $TEST LIKE P_TEST.
*--S4HANA#01.

  IF NOT $INDEX IS INITIAL.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        OBJECT     = 'Üzenetek'(001)
        I_USE_GRID = 'X'.
  ELSEIF NOT $TEST IS INITIAL.
    MESSAGE I257.
*   A feldolgozás nem tartalmaz hibát!
  ENDIF.

ENDFORM.                    " show_messages
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .

* Nem háttér futás
  IF SY-BATCH IS INITIAL.
    CALL SCREEN 100.
* Háttér futás
  ELSE.
    PERFORM GRID_DISPLAY.
  ENDIF.


ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.
*++S4HANA#01.
*  DATA LI_FCODE TYPE TABLE OF SY-UCOMM.
*  DATA LT_STD_FCODES TYPE UI_FUNCTIONS.
*  DATA LT_EXCL_FUNC TYPE UI_FUNCTIONS.
*--S4HANA#01.

  IF NOT P_TEST IS INITIAL.
    SET TITLEBAR 'MAIN100T'.
  ELSEIF NOT P_PROC IS INITIAL.
    SET TITLEBAR 'MAIN100P'.
  ELSEIF NOT P_PROD IS INITIAL.
    SET TITLEBAR 'MAIN100'.
  ENDIF.

* Menteni csak előfeldolgozásben lehet
  IF P_PROC IS INITIAL.
    APPEND 'SAVE' TO LI_FCODE.
    APPEND 'MODONELL' TO LI_FCODE.
  ENDIF.

* Megjelenítésnél és éles feldolgozásnál nem lehet szöveget
* módosítani
  IF NOT P_LIST IS INITIAL OR NOT P_PROD IS INITIAL.
    APPEND 'TEXTADD' TO LI_FCODE.
    APPEND 'TEXTDEL' TO LI_FCODE.
  ENDIF.

  SET PF-STATUS 'MAIN100' EXCLUDING LI_FCODE.

  IF G_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT G_CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME = G_CONTAINER.
    CREATE OBJECT G_GRID1
      EXPORTING
        I_PARENT = G_CUSTOM_CONTAINER.

    PERFORM FIELDCAT_BUILD.

    GS_VARIANT-REPORT = G_REPID.
    IF NOT SPEC_LAYOUT IS INITIAL.
      MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
    ELSEIF NOT DEF_LAYOUT IS INITIAL.
      MOVE-CORRESPONDING DEF_LAYOUT TO GS_VARIANT.
*++S4HANA#01.
*    ELSE.
*--S4HANA#01.
    ENDIF.
    GS_LAYOUT-CWIDTH_OPT = 'X'.
    GS_LAYOUT-SEL_MODE   = 'A'.
*   GS_LAYOUT-EXCP_FNAME = 'LIGHT'.
    GS_LAYOUT-NO_ROWINS  = 'X'.

*   Kizárt funkciók:
*    APPEND: '&INFO'  TO LT_EXCL_FUNC,   "Felhasználói help
*            '&GRAPH' TO LT_EXCL_FUNC,   "Grafikus megjelenítés
*            '&ABC'   TO LT_EXCL_FUNC.   "ABC elemzés

    CALL METHOD G_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT      = GS_VARIANT
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
*       IT_TOOLBAR_EXCLUDING = LT_EXCL_FUNC
      CHANGING
        IT_OUTTAB       = I_ONJALV[]
        IT_FIELDCATALOG = GT_FCAT[].
*

*    CALL METHOD G_GRID1->SET_READY_FOR_INPUT
*      EXPORTING
*        I_READY_FOR_INPUT = 1.

    CALL METHOD G_GRID1->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

    CREATE OBJECT G_EVENT_RECEIVER.
    SET HANDLER G_EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR G_GRID1.

  ENDIF.


ENDMODULE.                 " PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELDCAT_BUILD .

  DATA: L_FCAT TYPE LVC_S_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/ONJALV'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = GT_FCAT[].

*++0001 2008.11.26 (BG)
  IF NOT P_TEST IS INITIAL OR
     NOT P_PROC IS INITIAL.
    LOOP AT GT_FCAT INTO L_FCAT WHERE FIELDNAME = 'KESZULT'.
      L_FCAT-EDIT = 'X'.
      MODIFY GT_FCAT FROM L_FCAT.
    ENDLOOP.
  ENDIF.
*--0001 2008.11.26 (BG)


ENDFORM.                    " FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.
  CASE SAVE_OK.
    WHEN 'BACK'.
*++S4HANA#01.
*      PERFORM CHECK_EXIT USING G_SUBRC.
      PERFORM CHECK_EXIT CHANGING G_SUBRC.
*--S4HANA#01.
      IF G_SUBRC IS INITIAL.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
    WHEN 'EXIT'.
*++S4HANA#01.
*      PERFORM CHECK_EXIT USING G_SUBRC.
      PERFORM CHECK_EXIT CHANGING G_SUBRC.
*--S4HANA#01.
      IF G_SUBRC IS INITIAL.
        PERFORM EXIT_PROGRAM.
      ENDIF.
*   Mentés
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.

*   Üzenetek megjelenítése
    WHEN 'MESSAGE'.
      PERFORM SHOW_MESSAGES USING G_INDEX
                                  P_TEST.

*   Űrlap megjelenítés
    WHEN 'SHOW'.
      PERFORM PREVIEW_DATA TABLES I_ONJALV
                           USING  P_FNAME
                                  P_BUKRS
                                  P_TEST.

*   Szövegelem karbantartás
    WHEN 'TEXTCREATE'.
      CALL TRANSACTION '/ZAK/TEXT'.
*   Szöveglem hozzárendelés
    WHEN 'TEXTADD'.
      PERFORM ADD_TEXT TABLES I_ONJALV.
*   Szöveglem törlése
    WHEN 'TEXTDEL'.
      PERFORM DEL_TEXT TABLES I_ONJALV.
*   Összeg módosítás
    WHEN 'MODONELL'.
      PERFORM MOD_ONELL TABLES I_ONJALV.

    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " PAI_0100  INPUT

*---------------------------------------------------------------------*
*       FORM EXIT_PROGRAM                                             *
*---------------------------------------------------------------------*
FORM EXIT_PROGRAM.
  LEAVE PROGRAM.
ENDFORM.                    "exit_progr

*&---------------------------------------------------------------------*
*&      Form  GRID_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GRID_DISPLAY .

  SET PF-STATUS 'MAIN100'.
  IF P_TEST = 'X'.
    SET TITLEBAR 'MAIN100'.
  ELSE.
    SET TITLEBAR 'MAIN101'.
  ENDIF.

  PERFORM FIELDCAT_BUILD.


  GS_VARIANT-REPORT = G_REPID.
  IF NOT SPEC_LAYOUT IS INITIAL.
    MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
  ELSEIF NOT DEF_LAYOUT IS INITIAL.
    MOVE-CORRESPONDING DEF_LAYOUT TO GS_VARIANT.
*++S4HANA#01.
*  ELSE.
*--S4HANA#01.
  ENDIF.

  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-SEL_MODE   = 'A'.
* GS_LAYOUT-EXCP_FNAME = 'LIGHT'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                =
*     I_BUFFER_ACTIVE =
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  = ' '
*     I_BACKGROUND_ID = ' '
*     I_GRID_TITLE    =
*     I_GRID_SETTINGS =
      IS_LAYOUT_LVC   = GS_LAYOUT
      IT_FIELDCAT_LVC = GT_FCAT
*     IT_EXCLUDING    =
*     IT_SPECIAL_GROUPS_LVC             =
*     IT_SORT_LVC     =
*     IT_FILTER_LVC   =
*     IT_HYPERLINK    =
*     IS_SEL_HIDE     =
      I_DEFAULT       = 'X'
      I_SAVE          = 'A'
      IS_VARIANT      = GS_VARIANT
*     IT_EVENTS       =
*     IT_EVENT_EXIT   =
*     IS_PRINT_LVC    =
*     IS_REPREP_ID_LVC                  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 =
*     I_HTML_HEIGHT_END                 =
*     IT_EXCEPT_QINFO_LVC               =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB        = I_ONJALV
    EXCEPTIONS
      PROGRAM_ERROR   = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " GRID_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  ADD_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_P_TEST  text
*----------------------------------------------------------------------*
FORM ADD_TEXT  TABLES   $I_ONJALV LIKE I_ONJALV.

*++S4HANA#01.
*  DATA: LT_ROWS TYPE LVC_T_ROID WITH HEADER LINE,
  DATA: LT_ROWS          TYPE LVC_T_ROID .
  DATA: LS_ROWS_1 TYPE LVC_S_ROID,
*--S4HANA#01.
        LS_ROWS   TYPE LVC_S_ROID.
  DATA  LW_ONJALV TYPE /ZAK/ONJALV.


* Kijelölt tételek meghatározása
  CALL METHOD G_GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROWS[].

  IF LT_ROWS[] IS INITIAL.
    MESSAGE I018.
*   Kérem jelöljön ki egy tételt.
    EXIT.
  ENDIF.

* Szövegelem kiválasztása
  CALL SCREEN 0101 STARTING AT 1 1
                   ENDING   AT 65 10.

  CHECK NOT /ZAK/ONJALV-/ZAK/TEXT IS INITIAL.

* Adatok feldolgozása
  LOOP AT LT_ROWS INTO LS_ROWS.
    READ TABLE $I_ONJALV INTO LW_ONJALV INDEX LS_ROWS-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    LOOP AT $I_ONJALV INTO W_ONJALV WHERE
                      BUKRS EQ LW_ONJALV-BUKRS
                  AND BTYPE EQ LW_ONJALV-BTYPE
                  AND GJAHR EQ LW_ONJALV-GJAHR
                  AND MONAT EQ LW_ONJALV-MONAT
                  AND ZINDEX EQ LW_ONJALV-ZINDEX.
      MOVE /ZAK/ONJALV-/ZAK/TEXT TO W_ONJALV-/ZAK/TEXT.
      MODIFY $I_ONJALV FROM W_ONJALV TRANSPORTING /ZAK/TEXT.
    ENDLOOP.
  ENDLOOP.

  CALL METHOD G_GRID1->REFRESH_TABLE_DISPLAY.

ENDFORM.                    " ADD_TEXT
*&---------------------------------------------------------------------*
*&      Form  DEL_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_P_TEST  text
*----------------------------------------------------------------------*
FORM DEL_TEXT  TABLES   $I_ONJALV LIKE I_ONJALV.

*++S4HANA#01.
*  DATA: LT_ROWS TYPE LVC_T_ROID WITH HEADER LINE,
  DATA: LT_ROWS          TYPE LVC_T_ROID .
  DATA: LS_ROWS_1 TYPE LVC_S_ROID,
*--S4HANA#01.
        LS_ROWS   TYPE LVC_S_ROID.
  DATA  LW_ONJALV TYPE /ZAK/ONJALV.


* Kijelölt tételek meghatározása
  CALL METHOD G_GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROWS[].

  IF LT_ROWS[] IS INITIAL.
    MESSAGE I018.
*   Kérem jelöljön ki egy tételt.
    EXIT.
  ENDIF.


  CLEAR /ZAK/ONJALV-/ZAK/TEXT.

* Adatok feldolgozása
  LOOP AT LT_ROWS INTO LS_ROWS.
    READ TABLE $I_ONJALV INTO LW_ONJALV INDEX LS_ROWS-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    LOOP AT $I_ONJALV INTO W_ONJALV WHERE
                      BUKRS EQ LW_ONJALV-BUKRS
                  AND BTYPE EQ LW_ONJALV-BTYPE
                  AND GJAHR EQ LW_ONJALV-GJAHR
                  AND MONAT EQ LW_ONJALV-MONAT
                  AND ZINDEX EQ LW_ONJALV-ZINDEX.
      MOVE /ZAK/ONJALV-/ZAK/TEXT TO W_ONJALV-/ZAK/TEXT.
      MODIFY $I_ONJALV FROM W_ONJALV TRANSPORTING /ZAK/TEXT.
    ENDLOOP.
  ENDLOOP.

  CALL METHOD G_GRID1->REFRESH_TABLE_DISPLAY.

ENDFORM.                    " DEL_TEXT

*&---------------------------------------------------------------------*
*&      Module  PBO_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_0101 OUTPUT.

  SET TITLEBAR  'MAIN101'.
  SET PF-STATUS 'MAIN101'.


ENDMODULE.                 " PBO_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0101 INPUT.

  SAVE_OK = OK_CODE_101.
  CLEAR OK_CODE_101.
  CASE SAVE_OK.
    WHEN 'ENTER'.
      IF /ZAK/ONJALV-/ZAK/TEXT IS INITIAL.
        MESSAGE I274.
*   Kérem válasszon ki egy szövegelemet!
      ELSE.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
    WHEN 'CANCEL'.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDMODULE.                 " PAI_0101  INP
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .

* Ellenőrizzük van e hiba.
  IF NOT G_ERROR IS INITIAL.
    MESSAGE I277.
*   Mentés hibák miatt nem lehetséges! Lásd üzenetek!
    EXIT.
  ENDIF.

* Ellenőrizzük ki van e töltve mindenütt a TEXT
  READ TABLE I_ONJALV TRANSPORTING NO FIELDS WITH KEY /ZAK/TEXT = ''.
  IF SY-SUBRC EQ 0.
    MESSAGE I278.
*   Kérem minden tételhez adjon meg szöveg hozzárendelést!
    EXIT.
  ENDIF.
*++0001 2008.11.26 (BG)
* Ellenőrizzük ki van e töltve mindenütt a KESZULT
  READ TABLE I_ONJALV TRANSPORTING NO FIELDS WITH KEY KESZULT = '00000000'.
  IF SY-SUBRC EQ 0.
    MESSAGE I283.
*   Kérem minden tételhez adjon meg egy dátumot a "Készült" paraméterhez!
    EXIT.
  ENDIF.
*--0001 2008.11.26 (BG)

* ha minden rendben akkor mentés
  LOOP AT I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
    CLEAR: W_/ZAK/ONJDATA, W_/ZAK/ONJDANA.
*   Fejadatok feltöltése
    MOVE-CORRESPONDING W_/ZAK/BEVALLI TO W_/ZAK/ONJDATA.
*++0001 2008.11.26 (BG)
*   MOVE P_KESZD TO W_/ZAK/ONJDATA-KESZULT.
*--0001 2008.11.26 (BG)
*   Előfeldolgozás
    MOVE C_ONJSTAT_E TO W_/ZAK/ONJDATA-ONJSTAT.
*   Felhasználó
    MOVE SY-UNAME TO W_/ZAK/ONJDATA-UNAME.

    LOOP AT I_ONJALV INTO W_ONJALV WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS
                                     AND BTYPE EQ W_/ZAK/BEVALLI-BTYPE
                                     AND GJAHR EQ W_/ZAK/BEVALLI-GJAHR
                                     AND MONAT EQ W_/ZAK/BEVALLI-MONAT
                                     AND ZINDEX EQ W_/ZAK/BEVALLI-ZINDEX.
      CLEAR W_/ZAK/ONJDANA.
      IF W_/ZAK/ONJDATA-/ZAK/TEXT IS INITIAL.
        MOVE W_ONJALV-/ZAK/TEXT TO W_/ZAK/ONJDATA-/ZAK/TEXT.
      ENDIF.
*++0001 2008.11.26 (BG)
      MOVE W_ONJALV-KESZULT TO W_/ZAK/ONJDATA-KESZULT.
*--0001 2008.11.26 (BG)
*     Normál adónem
      IF NOT W_ONJALV-ADONEM EQ C_ONELL.
        MOVE-CORRESPONDING W_/ZAK/ONJDATA TO W_/ZAK/ONJDANA.
        MOVE W_ONJALV-ADONEM TO W_/ZAK/ONJDANA-ADONEM.
        MOVE W_ONJALV-OSSZEG TO W_/ZAK/ONJDANA-OSSZEG.
        MOVE W_ONJALV-ESDAT  TO W_/ZAK/ONJDANA-ESDAT.
        MOVE W_ONJALV-ONDAT  TO W_/ZAK/ONJDANA-ONDAT.
        MOVE W_ONJALV-WAERS  TO W_/ZAK/ONJDANA-WAERS.
        APPEND W_/ZAK/ONJDANA TO I_/ZAK/ONJDANA.
*     Önrevízió
      ELSE.
        MOVE W_ONJALV-OSSZEG TO W_/ZAK/ONJDATA-ONEPOT.
        MOVE W_ONJALV-WAERS  TO W_/ZAK/ONJDATA-WAERS.
      ENDIF.
    ENDLOOP.
    APPEND W_/ZAK/ONJDATA TO I_/ZAK/ONJDATA.
  ENDLOOP.

* Adatbázis módosítások
  MODIFY /ZAK/ONJDATA FROM TABLE I_/ZAK/ONJDATA.
  MODIFY /ZAK/ONJDANA FROM TABLE I_/ZAK/ONJDANA.
  COMMIT WORK AND WAIT.

  MESSAGE I216.
* Adatmódosítások elmentve!

  I_ONJALV_SAVE[] = I_ONJALV[].

  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.                    " SAVE_DAT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PROD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_I_/ZAK/BEVALLI  text
*      -->P_P_BUKRS  text
*      -->P_P_PROD  text
*----------------------------------------------------------------------*
FORM GET_DATA_PROD  TABLES  $I_ONJALV      LIKE      I_ONJALV
                            $I_/ZAK/ONJDATA STRUCTURE /ZAK/ONJDATA
                            $I_/ZAK/ONJDANA STRUCTURE /ZAK/ONJDANA
                            $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
*++S4HANA#01.
*                    USING   $BUKRS
*                            $PROD.
                    USING   $BUKRS TYPE T001-BUKRS
                            $PROD LIKE P_PROD.
*--S4HANA#01.

  CHECK NOT $PROD IS INITIAL.

*++S4HANA#01.
*  REFRESH: $I_ONJALV, $I_/ZAK/ONJDATA, $I_/ZAK/ONJDANA, $I_/ZAK/BEVALLI.
  CLEAR: $I_ONJALV[].
  CLEAR: $I_/ZAK/ONJDATA[].
  CLEAR: $I_/ZAK/ONJDANA[].
  CLEAR: $I_/ZAK/BEVALLI[].
*--S4HANA#01.
* Fejadatok meghatározása
  SELECT * INTO TABLE $I_/ZAK/ONJDATA
           FROM /ZAK/ONJDATA
          WHERE BUKRS   EQ $BUKRS
            AND ONJSTAT EQ C_ONJSTAT_E.
* Tétel adatok meghatározása
  SELECT * INTO TABLE $I_/ZAK/ONJDANA
           FROM /ZAK/ONJDANA
           FOR ALL ENTRIES IN $I_/ZAK/ONJDATA
           WHERE BUKRS  EQ $I_/ZAK/ONJDATA-BUKRS
             AND BTYPE  EQ $I_/ZAK/ONJDATA-BTYPE
             AND GJAHR  EQ $I_/ZAK/ONJDATA-GJAHR
             AND MONAT  EQ $I_/ZAK/ONJDATA-MONAT
             AND ZINDEX EQ $I_/ZAK/ONJDATA-ZINDEX.
* Adatszolgáltatás adatok
  SELECT * INTO TABLE $I_/ZAK/BEVALLI
           FROM /ZAK/BEVALLI
           FOR ALL ENTRIES IN $I_/ZAK/ONJDATA
           WHERE BUKRS  EQ $I_/ZAK/ONJDATA-BUKRS
             AND BTYPE  EQ $I_/ZAK/ONJDATA-BTYPE
             AND GJAHR  EQ $I_/ZAK/ONJDATA-GJAHR
             AND MONAT  EQ $I_/ZAK/ONJDATA-MONAT
             AND ZINDEX EQ $I_/ZAK/ONJDATA-ZINDEX.

* Adatok mappelése
*
  LOOP AT  $I_/ZAK/ONJDATA INTO W_/ZAK/ONJDATA.
    CLEAR W_ONJALV.
    MOVE W_/ZAK/ONJDATA-BUKRS TO W_ONJALV-BUKRS.
    MOVE W_/ZAK/ONJDATA-BTYPE TO W_ONJALV-BTYPE.
    MOVE W_/ZAK/ONJDATA-GJAHR TO W_ONJALV-GJAHR.
    MOVE W_/ZAK/ONJDATA-MONAT TO W_ONJALV-MONAT.
    MOVE W_/ZAK/ONJDATA-ZINDEX TO W_ONJALV-ZINDEX.
    MOVE W_/ZAK/ONJDATA-KESZULT TO W_ONJALV-KESZULT.
    MOVE W_/ZAK/ONJDATA-/ZAK/TEXT TO W_ONJALV-/ZAK/TEXT.

    LOOP AT $I_/ZAK/ONJDANA INTO W_/ZAK/ONJDANA
               WHERE BUKRS = W_/ZAK/ONJDATA-BUKRS
                 AND BTYPE = W_/ZAK/ONJDATA-BTYPE
                 AND GJAHR = W_/ZAK/ONJDATA-GJAHR
                 AND MONAT = W_/ZAK/ONJDATA-MONAT
                 AND ZINDEX = W_/ZAK/ONJDATA-ZINDEX.
      MOVE W_/ZAK/ONJDANA-ADONEM TO  W_ONJALV-ADONEM.
      MOVE W_/ZAK/ONJDANA-OSSZEG TO  W_ONJALV-OSSZEG.
      MOVE W_/ZAK/ONJDANA-ESDAT  TO  W_ONJALV-ESDAT.
      MOVE W_/ZAK/ONJDANA-ONDAT  TO  W_ONJALV-ONDAT.
      MOVE W_/ZAK/ONJDANA-WAERS  TO  W_ONJALV-WAERS.
      APPEND W_ONJALV TO $I_ONJALV.
    ENDLOOP.
    CLEAR: W_ONJALV-ESDAT, W_ONJALV-ONDAT.
    MOVE C_ONELL TO W_ONJALV-ADONEM.
    MOVE W_/ZAK/ONJDATA-ONEPOT TO W_ONJALV-OSSZEG.
    MOVE W_/ZAK/ONJDATA-WAERS  TO W_ONJALV-WAERS.
    APPEND  W_ONJALV TO $I_ONJALV.
    CLEAR W_/ZAK/ONJDATA-ONJSTAT.
    MODIFY $I_/ZAK/ONJDATA FROM W_/ZAK/ONJDATA TRANSPORTING ONJSTAT.
  ENDLOOP.

ENDFORM.                    " GET_DATA_PROD
*&---------------------------------------------------------------------*
*&      Form  PRODUCTIVE_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_I_/ZAK/ONJDATA  text
*      -->P_I_/ZAK/BEVALLI  text
*----------------------------------------------------------------------*
FORM PRODUCTIVE_RUN  TABLES   $I_ONJALV      LIKE I_ONJALV
                              $I_/ZAK/ONJDATA STRUCTURE /ZAK/ONJDATA
                              $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
*++S4HANA#01.
*                     USING    $PROD
*                              $FNAME.
                     USING    $PROD LIKE P_PROD
                              $FNAME TYPE SSFSCREEN-FNAME.
*--S4HANA#01.

  DATA  L_FM_NAME TYPE RS38L_FNAM.
  DATA  LW_ONJALV LIKE W_ONJALV.
  DATA  L_OSSZESEN TYPE /ZAK/DMBTR.


  CHECK NOT $PROD IS INITIAL.

  IF NOT G_ERROR IS INITIAL.
    MESSAGE I262.
*   Éles futás hibák miatt nem indítható!
    EXIT.
  ENDIF.

* Űrlap adatok meghatározása
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = $FNAME
    IMPORTING
      FM_NAME            = L_FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE E263 WITH $FNAME.
*   Hiba a & űrlap beolvasásánál!
  ENDIF.

  LOOP AT $I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
    READ TABLE $I_/ZAK/ONJDATA INTO W_/ZAK/ONJDATA
                              WITH KEY BUKRS = W_/ZAK/BEVALLI-BUKRS
                                       BTYPE = W_/ZAK/BEVALLI-BTYPE
                                       GJAHR = W_/ZAK/BEVALLI-GJAHR
                                       MONAT = W_/ZAK/BEVALLI-MONAT
                                       ZINDEX = W_/ZAK/BEVALLI-ZINDEX.
    CLEAR:   W_ONJSMART_DATA, L_OSSZESEN.
*++S4HANA#01.
*    REFRESH: I_TEXT, I_ONELL_DATA.
    CLEAR: I_TEXT[].
    CLEAR: I_ONELL_DATA[].
*--S4HANA#01.
*   Adatok feldolgozása
    LOOP AT $I_ONJALV INTO W_ONJALV WHERE BUKRS  EQ W_/ZAK/BEVALLI-BUKRS
                                      AND BTYPE  EQ W_/ZAK/BEVALLI-BTYPE
                                      AND GJAHR  EQ W_/ZAK/BEVALLI-GJAHR
                                      AND MONAT  EQ W_/ZAK/BEVALLI-MONAT
                                      AND ZINDEX EQ W_/ZAK/BEVALLI-ZINDEX
                                      .
      PERFORM GET_SMART_DATA TABLES I_TEXT
                                    I_ONELL_DATA
                             USING  W_ONJALV
                                    W_ONJSMART_DATA
                                    T001
                                    SPACE
                                    L_OSSZESEN
                                    W_/ZAK/ONJDATA-UNAME.

    ENDLOOP.
    IF NOT L_OSSZESEN IS INITIAL.
      WRITE L_OSSZESEN TO W_ONJSMART_DATA-OSSZESEN
                                     CURRENCY W_ONJALV-WAERS.
    ELSE.
      W_ONJSMART_DATA-OSSZESEN = 0.
    ENDIF.
    CONDENSE W_ONJSMART_DATA-OSSZESEN.

*   Űrlap meghívása
    PERFORM CALL_SMARTFORMS TABLES I_TEXT
                                   I_ONELL_DATA
                            USING  L_FM_NAME
                                   W_ONJSMART_DATA
                                   ''. "TEszt mód
    MOVE C_X TO W_/ZAK/BEVALLI-ONJF.
    MODIFY $I_/ZAK/BEVALLI FROM W_/ZAK/BEVALLI TRANSPORTING ONJF.
  ENDLOOP.

* Tábla módosítások
  MODIFY /ZAK/BEVALLI FROM TABLE $I_/ZAK/BEVALLI.
  MODIFY /ZAK/ONJDATA FROM TABLE $I_/ZAK/ONJDATA.
  COMMIT WORK AND WAIT.

  MESSAGE I216.
* Adatmódosítások elmentve!

ENDFORM.                    " PRODUCTIVE_RUN
*&---------------------------------------------------------------------*
*&      Form  VERIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VERIFY_SCREEN .
*++0001 2008.11.26 (BG)
*  IF P_KESZD IS INITIAL AND P_LIST IS INITIAL.
*    MESSAGE E279.
**   Kérem adjon meg egy dátumot a "Készült" paraméterhez!
*  ENDIF.
*--0001 2008.11.26 (BG)
ENDFORM.                    " VERIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_I_/ZAK/ONJDATA  text
*      -->P_I_/ZAK/ONJDANA  text
*      -->P_S_GJAHR  text
*      -->P_S_MONAT  text
*      -->P_S_INDEX  text
*      -->P_S_KESZD  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_LIST  text
*----------------------------------------------------------------------*
FORM GET_DATA_LIST  TABLES  $I_ONJALV      LIKE      I_ONJALV
                            $I_/ZAK/ONJDATA STRUCTURE /ZAK/ONJDATA
                            $I_/ZAK/ONJDANA STRUCTURE /ZAK/ONJDANA
                            $S_GJAHR       STRUCTURE S_GJAHR
                            $S_MONAT       STRUCTURE S_MONAT
                            $S_INDEX       STRUCTURE S_INDEX
                            $S_KESZD       STRUCTURE S_KESZD
*++S4HANA#01.
*                    USING   $BUKRS
*                            $BTYPE
*                            $LIST.
                    USING   $BUKRS TYPE T001-BUKRS
                            $BTYPE TYPE /ZAK/BEVALLB-BTYPE
                            $LIST LIKE P_LIST.
*--S4HANA#01.


  CHECK NOT $LIST IS INITIAL.


*++S4HANA#01.
*  REFRESH: $I_ONJALV, $I_/ZAK/ONJDATA, $I_/ZAK/ONJDANA.
  CLEAR: $I_ONJALV[].
  CLEAR: $I_/ZAK/ONJDATA[].
  CLEAR: $I_/ZAK/ONJDANA[].
*--S4HANA#01.

* Fejadatok meghatározása
  SELECT * INTO TABLE $I_/ZAK/ONJDATA
           FROM /ZAK/ONJDATA
          WHERE BUKRS   EQ $BUKRS
            AND BTYPE   EQ $BTYPE
            AND GJAHR   IN $S_GJAHR
            AND MONAT   IN $S_MONAT
            AND ZINDEX  IN $S_INDEX
            AND KESZULT IN $S_KESZD.

* Tétel adatok meghatározása
  SELECT * INTO TABLE $I_/ZAK/ONJDANA
           FROM /ZAK/ONJDANA
           FOR ALL ENTRIES IN $I_/ZAK/ONJDATA
           WHERE BUKRS  EQ $I_/ZAK/ONJDATA-BUKRS
             AND BTYPE  EQ $I_/ZAK/ONJDATA-BTYPE
             AND GJAHR  EQ $I_/ZAK/ONJDATA-GJAHR
             AND MONAT  EQ $I_/ZAK/ONJDATA-MONAT
             AND ZINDEX EQ $I_/ZAK/ONJDATA-ZINDEX.


* Adatok mappelése
  LOOP AT  $I_/ZAK/ONJDATA INTO W_/ZAK/ONJDATA.
    CLEAR W_ONJALV.
    MOVE W_/ZAK/ONJDATA-BUKRS TO W_ONJALV-BUKRS.
    MOVE W_/ZAK/ONJDATA-BTYPE TO W_ONJALV-BTYPE.
    MOVE W_/ZAK/ONJDATA-GJAHR TO W_ONJALV-GJAHR.
    MOVE W_/ZAK/ONJDATA-MONAT TO W_ONJALV-MONAT.
    MOVE W_/ZAK/ONJDATA-ZINDEX TO W_ONJALV-ZINDEX.
    MOVE W_/ZAK/ONJDATA-KESZULT TO W_ONJALV-KESZULT.
    MOVE W_/ZAK/ONJDATA-/ZAK/TEXT TO W_ONJALV-/ZAK/TEXT.

    LOOP AT $I_/ZAK/ONJDANA INTO W_/ZAK/ONJDANA
               WHERE BUKRS = W_/ZAK/ONJDATA-BUKRS
                 AND BTYPE = W_/ZAK/ONJDATA-BTYPE
                 AND GJAHR = W_/ZAK/ONJDATA-GJAHR
                 AND MONAT = W_/ZAK/ONJDATA-MONAT
                 AND ZINDEX = W_/ZAK/ONJDATA-ZINDEX.
      MOVE W_/ZAK/ONJDANA-ADONEM TO  W_ONJALV-ADONEM.
      MOVE W_/ZAK/ONJDANA-OSSZEG TO  W_ONJALV-OSSZEG.
      MOVE W_/ZAK/ONJDANA-ESDAT  TO  W_ONJALV-ESDAT.
      MOVE W_/ZAK/ONJDANA-ONDAT  TO  W_ONJALV-ONDAT.
      MOVE W_/ZAK/ONJDANA-WAERS  TO  W_ONJALV-WAERS.
      APPEND W_ONJALV TO $I_ONJALV.
    ENDLOOP.
    CLEAR: W_ONJALV-ESDAT, W_ONJALV-ONDAT.
    MOVE C_ONELL TO W_ONJALV-ADONEM.
    MOVE W_/ZAK/ONJDATA-ONEPOT TO W_ONJALV-OSSZEG.
    MOVE W_/ZAK/ONJDATA-WAERS  TO W_ONJALV-WAERS.
    APPEND  W_ONJALV TO $I_ONJALV.
  ENDLOOP.


ENDFORM.                    " GET_DATA_LIST
*&---------------------------------------------------------------------*
*&      Form  CHECK_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_EXIT USING $SUBRC.
FORM CHECK_EXIT USING $SUBRC  TYPE SY-SUBRC..
*--S4HANA#01.

  DATA L_ANSWER.

  CLEAR $SUBRC.

* Ha előfeldolgozásban volt, akkor kilépés ellenőrzése
  CHECK NOT P_PROC IS INITIAL.

  IF I_ONJALV_SAVE[] NE I_ONJALV[].
*++S4HANA#01.
**++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
**    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
**      EXPORTING
**        TEXTLINE1     = 'Adatok nem lettek elmentve!'
**        TEXTLINE2     = 'Kilép mentés nélkül?'
**        TITEL         = 'Adatok változtak'
**        START_COLUMN  = 25
**        START_ROW     = 6
**        DEFAULTOPTION = 'N'
**      IMPORTING
**        ANSWER        = L_ANSWER.
*    DATA L_QUESTION TYPE STRING.
*
*    CONCATENATE 'Adatok nem lettek elmentve!' 'Kilép mentés nélkül?' INTO L_QUESTION SEPARATED BY SPACE.
**
*    CALL FUNCTION 'POPUP_TO_CONFIRM'
*      EXPORTING
*        TITLEBAR              = 'Adatok változtak'
**       DIAGNOSE_OBJECT       = ' '
*        TEXT_QUESTION         = L_QUESTION
**       TEXT_BUTTON_1         = 'Ja'(001)
**       ICON_BUTTON_1         = ' '
**       TEXT_BUTTON_2         = 'Nein'(002)
**       ICON_BUTTON_2         = ' '
*        DEFAULT_BUTTON        = '2'
*        DISPLAY_CANCEL_BUTTON = ' '
**       USERDEFINED_F1_HELP   = ' '
*        START_COLUMN          = 25
*        START_ROW             = 6
**       POPUP_TYPE            =
**       IV_QUICKINFO_BUTTON_1 = ' '
**       IV_QUICKINFO_BUTTON_2 = ' '
*      IMPORTING
*        ANSWER                = L_ANSWER
**   TABLES
**       PARAMETER             =
**   EXCEPTIONS
**       TEXT_NOT_FOUND        = 1
**       OTHERS                = 2
*      .
*    IF L_ANSWER EQ '1'.
*      L_ANSWER = 'J'.
*    ELSE.
*      L_ANSWER = 'N'.
*    ENDIF.
**--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

    DATA: LV_W_TEXT_QUESTION_0(400) TYPE C.
    CONCATENATE
       'Adatok nem lettek elmentve!'
      'Kilép mentés nélkül?'
       INTO LV_W_TEXT_QUESTION_0 SEPARATED BY SPACE IN CHARACTER MODE.

    DATA: LV_W_DEFAULT_BUTTON_0(1) TYPE C.

    LV_W_DEFAULT_BUTTON_0 = 'N'.
    IF LV_W_DEFAULT_BUTTON_0 = 'Y' OR LV_W_DEFAULT_BUTTON_0 = 'J'.
      LV_W_DEFAULT_BUTTON_0 = '1'.
    ELSEIF LV_W_DEFAULT_BUTTON_0 = 'N'.
      LV_W_DEFAULT_BUTTON_0 = '2'.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Adatok változtak'
        TEXT_QUESTION         = LV_W_TEXT_QUESTION_0
        DIAGNOSE_OBJECT       = 'CACS_CONFIRM_LOSS_OF_DATA'
        DEFAULT_BUTTON        = LV_W_DEFAULT_BUTTON_0
        DISPLAY_CANCEL_BUTTON = ' '
        START_COLUMN          = 25
        START_ROW             = 6
        POPUP_TYPE            = 'ICON_MESSAGE_WARNING'
      IMPORTING
        ANSWER                = L_ANSWER
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1.
    CASE SY-SUBRC.
      WHEN 1.
* IMPLEMENT ME
    ENDCASE.
    CASE L_ANSWER.
      WHEN '1'.
        L_ANSWER = 'J'.
      WHEN '2'.
        L_ANSWER = 'N'.
    ENDCASE.
*--S4HANA#01.

    IF L_ANSWER EQ 'N'.
      MOVE 4 TO $SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.                    " CHECK_EXI
*&---------------------------------------------------------------------*
*&      Form  MOD_ONELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*----------------------------------------------------------------------*
FORM MOD_ONELL  TABLES   $I_ONJALV LIKE I_ONJALV.


*++S4HANA#01.
*  DATA: LT_ROWS TYPE LVC_T_ROID WITH HEADER LINE,
  DATA: LT_ROWS          TYPE LVC_T_ROID .
  DATA: LS_ROWS_1 TYPE LVC_S_ROID,
*--S4HANA#01.
        LS_ROWS   TYPE LVC_S_ROID.
  DATA  LW_ONJALV TYPE /ZAK/ONJALV.
  DATA  L_LINE TYPE SY-TABIX.


* Kijelölt tételek meghatározása
  CALL METHOD G_GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROWS[].

  IF LT_ROWS[] IS INITIAL.
    MESSAGE I018.
*   Kérem jelöljön ki egy tételt.
    EXIT.
  ENDIF.

* Ha több tételt jelöl ki!
*++S4HANA#01.
*  DESCRIBE TABLE LT_ROWS LINES L_LINE.
  L_LINE = LINES( LT_ROWS ).
*--S4HANA#01.

  IF L_LINE > 1.
    MESSAGE I187.
*   Kérem csak egy sort jelöljön ki!
    EXIT.
  ENDIF.


* Adatok feldolgozása
  READ TABLE LT_ROWS INTO LS_ROWS INDEX 1.
  READ TABLE $I_ONJALV INTO W_ONJALV INDEX LS_ROWS-ROW_ID.
  CHECK SY-SUBRC EQ 0.
* Adónem ellenőrzése
  IF W_ONJALV-ADONEM NE C_ONELL.
    MESSAGE I280.
*   Kérem önellenőrzéses adónemmel rendelkező sort válasszon ki!
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING W_ONJALV TO /ZAK/ONJALV.

* Összeg módosítása
  CALL SCREEN 0102 STARTING AT 1 1
                   ENDING   AT 65 10.

  CHECK OK_CODE_102 EQ 'SAVE'.

  MOVE /ZAK/ONJALV-OSSZEG TO W_ONJALV-OSSZEG.

  MODIFY $I_ONJALV FROM W_ONJALV INDEX LS_ROWS-ROW_ID
                   TRANSPORTING OSSZEG.

  CALL METHOD G_GRID1->REFRESH_TABLE_DISPLAY.


ENDFORM.                    " MOD_ONELL
*&---------------------------------------------------------------------*
*&      Module  PBO_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_0102 OUTPUT.

  SET TITLEBAR  'MAIN102'.
  SET PF-STATUS 'MAIN102'.

ENDMODULE.                 " PBO_0102  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0102 INPUT.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                 " PAI_0102  INPUT
