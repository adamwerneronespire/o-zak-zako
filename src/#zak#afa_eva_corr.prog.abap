*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_EVA_CORR
*&
*&---------------------------------------------------------------------*
*& /ZAK/ANALITIKA korrekció. A MAIN_EXIT-ben nem volt beállítva 1065
*& bevallásnál az EVA alap és adó ABEV azonosító így ezek a rekordok
*& üres ABEV azonosítóval jöttek létre. Ez a program összegyűjti a
*& szelekciónak megfelelő üres ABEV azonosítójú sorokat és a
*& FIELD_N alapján (LWBAS, LWSTE) eldönti, hogy az adott sor alap
*& vagy adó tételt tartalmaz (7995, 7996). Éles futásnál az üres
*& ABEV azonosítójú rekordokat törli és a feltöltött ABEV azonosítójú
*& rekordokat létre hozza az eredeti időszakokban.
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_EVA_CORR MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábr - FMC
*& Létrehozás dátuma : 2006.12.13
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx
*&                                   xxxxxxx xxxxxxx xxxxxxx
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.

TYPE-POOLS: SLIS.

*ALV közös rutinok
INCLUDE /ZAK/ALV_LIST_FORMS.

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
DATA I_/ZAK/ANALITIKA_DEL LIKE /ZAK/ANALITIKA OCCURS 0.
DATA I_/ZAK/ANALITIKA_NEW LIKE /ZAK/ANALITIKA OCCURS 0.


*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS.
SELECT-OPTIONS S_BTYPE FOR /ZAK/ANALITIKA-BTYPE.
SELECT-OPTIONS S_GJAHR FOR /ZAK/ANALITIKA-GJAHR.
PARAMETERS P_TESZT AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK BL01.
*++1765 #19.
INITIALIZATION.
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
* Analitika szelekció
  PERFORM GET_ANALITIKA.
  IF I_/ZAK/ANALITIKA_DEL[] IS INITIAL.
    MESSAGE I201.
*   Nem található olyan rekord, amit konvertálni kell! (/ZAK/ANALITIKA)
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* Feldolgozás
  PERFORM PROCESS_DATA.

  PERFORM ALV_LIST  TABLES  I_/ZAK/ANALITIKA_NEW
                     USING  'I_/ZAK/ANALITIKA_NEW'.


*&---------------------------------------------------------------------*
*&      Form  GET_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ANALITIKA .

  SELECT * INTO TABLE I_/ZAK/ANALITIKA_DEL
           FROM /ZAK/ANALITIKA
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN S_BTYPE
            AND GJAHR IN S_GJAHR
            and ABEVAZ eq ''.

ENDFORM.                    " GET_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .

  LOOP AT I_/ZAK/ANALITIKA_DEL INTO W_/ZAK/ANALITIKA.
*   Alap
    IF W_/ZAK/ANALITIKA-FIELD_N EQ W_/ZAK/ANALITIKA-LWBAS.
      W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_7995.
      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
*   Adó
    ELSEIF W_/ZAK/ANALITIKA-FIELD_N EQ W_/ZAK/ANALITIKA-LWSTE.
      W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_7996.
      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
*   Egyik sem nem töröljük
    ELSE.
      DELETE I_/ZAK/ANALITIKA_DEL.
    ENDIF.
  ENDLOOP.

  IF P_TESZT IS INITIAL.
    INSERT /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_NEW.
    DELETE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_DEL.
    COMMIT WORK AND WAIT.
    MESSAGE I203.
*   Konvertált tételek adatbázisban módosítva!
  ENDIF.

ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
FORM ALV_LIST   TABLES   $TAB
                USING    $TAB_NAME.

*ALV lista init
  PERFORM COMMON_ALV_LIST_INIT USING SY-TITLE
                                     $TAB_NAME
                                     '/ZAK/AFA_EVA_CORR'.

*ALV lista
  PERFORM COMMON_ALV_GRID_DISPLAY TABLES $TAB
                                  USING  $TAB_NAME
                                         SPACE
                                         SPACE.

ENDFORM.                    " LIST_SPOOL

*&---------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM END_OF_LIST.

ENDFORM.                    " END_OF_LIST
