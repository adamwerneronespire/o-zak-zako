*&---------------------------------------------------------------------*
*& Program: Év váltás korrekció
*&---------------------------------------------------------------------*

REPORT /ZAK/EVVALT_CORR MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: Mivel előző évben keletkeznek olyan rekordok az
*& analitikában, aminél a bevallás típús még az előző évi (pld. repi
*& könyvelések), ezért szükséges ez a konverziós program, ami ezeket
*& a tételeket átforgatja az aktuális év ABEV azonosítóira
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
DATA W_/ZAK/ANALITIKA_DEL TYPE /ZAK/ANALITIKA.
DATA I_/ZAK/ANALITIKA_DEL TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                INITIAL SIZE 0.

DATA I_ALV LIKE /ZAK/EVVCORR_ALV OCCURS 0.
DATA W_ALV TYPE /ZAK/EVVCORR_ALV.

DATA: V_OK_CODE          LIKE SY-UCOMM,
      V_SAVE_OK          LIKE SY-UCOMM,
      V_CONTAINER        TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT         TYPE LVC_T_FCAT,
      V_LAYOUT           TYPE LVC_S_LAYO,
      V_VARIANT          TYPE DISVARIANT,
      V_GRID             TYPE REF TO CL_GUI_ALV_GRID.

DATA V_SUBRC LIKE SY-SUBRC.
DATA V_REPID LIKE SY-REPID.
*++2065 #04.
DATA I_REL_BEVALL TYPE STANDARD TABLE OF /ZAK/BEVALL INITIAL SIZE 0.
*--2065 #04.

*++BG 2007.04.26
*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.
*--BG 2007.04.26

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
  PARAMETERS P_GJAHR TYPE GJAHR OBLIGATORY.
  SELECT-OPTIONS S_BTYPAR FOR /ZAK/BEVALL-BTYPART.
  PARAMETERS P_TESZT AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK BL01.


****************************************************************
* LOCAL CLASSES: Definition
****************************************************************



*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
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
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Megállapítjuk a lezárt időszakokat az adott  évben
  PERFORM GET_BEVALLI.
* Megállapítjuk, hogy milyen érvényes bevallás típusok léteznek az
* adott évben.
  PERFORM GET_VALID_BTYPE.
* Analitika szelekció
  PERFORM GET_ANALITIKA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* Feldolgozás
  PERFORM PROCESS_DATA.

* Előtérben obj.lista
  IF SY-BATCH IS INITIAL.
    PERFORM LIST_DISPLAY.
* Háttérben ALV listát.
  ELSE.
    PERFORM LIST_SPOOL TABLES  I_ALV
                       USING  'I_ALV'.
  ENDIF.



************************************************************************
*                            ALPROGRAMOK
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  GET_BEVALLI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BEVALLI.

  SELECT * INTO TABLE I_/ZAK/BEVALLI
           FROM /ZAK/BEVALLI
          WHERE GJAHR EQ P_GJAHR
            AND ( FLAG  EQ 'X' OR
                  FLAG  EQ 'Z' ).
  SORT I_/ZAK/BEVALLI.


ENDFORM.                    " GET_BEVALLI
*&---------------------------------------------------------------------*
*&      Form  GET_VALID_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_VALID_BTYPE.

  DATA L_GJAHR_FROM TYPE GJAHR.
  DATA L_GJAHR_TO   TYPE GJAHR.

  SELECT * INTO W_/ZAK/BEVALL
                FROM /ZAK/BEVALL.                        "#EC CI_NOWHERE
    L_GJAHR_FROM = W_/ZAK/BEVALL-DATAB(4).
    L_GJAHR_TO   = W_/ZAK/BEVALL-DATBI(4).
    IF P_GJAHR BETWEEN L_GJAHR_FROM AND L_GJAHR_TO.
      APPEND W_/ZAK/BEVALL TO I_/ZAK/BEVALL.
    ENDIF.
  ENDSELECT.

  SORT I_/ZAK/BEVALL.

  IF I_/ZAK/BEVALL[] IS INITIAL.
    MESSAGE E200 WITH P_GJAHR.
*   Nincs érvényes bevallás típus beállítva & évben! (/ZAK/BEVALL)
  ENDIF.


ENDFORM.                    " GET_VALID_BTYPE
*&---------------------------------------------------------------------*
*&      Form  GET_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ANALITIKA.

*++BG 2007.04.26
  RANGES LR_BTYPE FOR /ZAK/ANALITIKA-BTYPE.
  DATA L_BTYPE TYPE /ZAK/BTYPE.

*BTYPART alapján meghatározzuk a BTYPE-ot
  SELECT BTYPE INTO L_BTYPE
               FROM /ZAK/BEVALL
              WHERE BTYPART IN S_BTYPAR.
    M_DEF LR_BTYPE 'I' 'EQ' L_BTYPE SPACE.
  ENDSELECT.
  SORT LR_BTYPE.
  DELETE ADJACENT DUPLICATES FROM LR_BTYPE.
*--BG 2007.04.26
*++2065 #11.
  DATA L_DATUM TYPE SYDATUM.
*--2065 #11.



  SELECT * INTO W_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE GJAHR EQ P_GJAHR
*++BG 2007.04.26
            AND BTYPE IN LR_BTYPE.
*--BG 2007.04.26
*++2065 #11.
*   IDŐSZAK első napje
    CONCATENATE W_/ZAK/ANALITIKA-GJAHR W_/ZAK/ANALITIKA-MONAT '01' INTO L_DATUM.
*--2065 #11.
*   Ellenőrizzük a BTYPE-ot
    READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
                            WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                                     BTYPE = W_/ZAK/ANALITIKA-BTYPE
                                     BINARY SEARCH.
*++2065 #11.
*    IF SY-SUBRC NE 0.
    IF SY-SUBRC NE 0 OR NOT L_DATUM BETWEEN W_/ZAK/BEVALL-DATAB AND W_/ZAK/BEVALL-DATBI.
*--2065 #11.
      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
*++2065 #04.
*     Összegyűjtjük a releváns BEVALL bejegyzésket (időszak kezelés miatt)
      READ TABLE I_REL_BEVALL TRANSPORTING NO FIELDS
                 WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                          BTYPE = W_/ZAK/ANALITIKA-BTYPE.
      IF SY-SUBRC NE 0.
*++S4HANA#01.
*        SELECT * APPENDING TABLE I_REL_BEVALL
*                           FROM /ZAK/BEVALL
*                          WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
*                            AND BTYPE EQ W_/ZAK/ANALITIKA-BTYPE.
        SELECT BUKRS BTYPE DATBI DATAB BIDOSZ
          APPENDING CORRESPONDING FIELDS OF TABLE I_REL_BEVALL
                   FROM /ZAK/BEVALL
                  WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
                    AND BTYPE EQ W_/ZAK/ANALITIKA-BTYPE.
        SORT I_REL_BEVALL BY BUKRS BTYPE DATBI.
*--S4HANA#01.
      ENDIF.
*--2065 #04.
    ENDIF.
  ENDSELECT.

  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE E201.
*   Nem található olyan rekord, amit konvertálni kell! (/ZAK/ANALITIKA)
  ENDIF.

ENDFORM.                    " GET_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA.

  DATA LI_ABEV_CONTACT LIKE /ZAK/ABEVCONTACT OCCURS 0 WITH HEADER LINE.

*++S4HANA#01.
*  DATA: BEGIN OF LI_CLOSE OCCURS 0,
*          BUKRS  TYPE BUKRS,
*          BTYPE  TYPE /ZAK/BTYPE,
*          GJAHR  TYPE GJAHR,
*          MONAT  TYPE MONAT,
*          ZINDEX TYPE /ZAK/INDEX,
*        END OF LI_CLOSE.
  TYPES: BEGIN OF TS_LI_CLOSE ,
           BUKRS  TYPE BUKRS,
           BTYPE  TYPE /ZAK/BTYPE,
           GJAHR  TYPE GJAHR,
           MONAT  TYPE MONAT,
           ZINDEX TYPE /ZAK/INDEX,
         END OF TS_LI_CLOSE .
  TYPES TT_LI_CLOSE TYPE STANDARD TABLE OF TS_LI_CLOSE .
  DATA: LS_LI_CLOSE TYPE TS_LI_CLOSE.
  DATA: LT_LI_CLOSE TYPE TT_LI_CLOSE.
*--S4HANA#01.

  DATA   L_TEXT(40).

*++BG 2007.04.26
* BTYPE váltás esetén adatok gyűjtése a BEVALLI és BEVALLSZ
* átállításához.
  DATA: BEGIN OF LI_BEVALLI OCCURS 0,
          BUKRS  TYPE BUKRS,
          BTYPE  TYPE /ZAK/BTYPE,
          GJAHR  TYPE GJAHR,
          MONAT  TYPE MONAT,
          ZINDEX TYPE /ZAK/INDEX,
          BTYPEN TYPE /ZAK/BTYPE,
        END OF LI_BEVALLI.
*--BG 2007.04.26
*++2065 #04.
  DATA LI_BEVALLI_INS LIKE LI_BEVALLI OCCURS 0.
  DATA LS_BEVALLI_INS LIKE LINE OF LI_BEVALLI.
  DATA L_MONAT TYPE MONAT.
  DATA L_DATUM TYPE DATUM.
*++S4HANA#01.
  DATA LT_FILTER_W_/ZAK/BEVALLSZ TYPE STANDARD TABLE OF /ZAK/BEVALLSZ.
*--S4HANA#01.
  DEFINE LM_CHECK_BEVALLI.
    DO &1 TIMES.
      ADD 1 TO L_MONAT.
      READ TABLE LI_BEVALLI TRANSPORTING NO FIELDS
           WITH KEY BUKRS  = LI_BEVALLI-BUKRS
                    BTYPE  = LI_BEVALLI-BTYPE
                    GJAHR  = LI_BEVALLI-GJAHR
                    MONAT  = L_MONAT
                    ZINDEX = LI_BEVALLI-ZINDEX.
      IF SY-SUBRC NE 0.
        LS_BEVALLI_INS = LI_BEVALLI.
        LS_BEVALLI_INS-MONAT = L_MONAT.
        APPEND LS_BEVALLI_INS TO LI_BEVALLI_INS.
      ENDIF.
    ENDDO.
  END-OF-DEFINITION.
*--2065 #04.


  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.

*   ALV listára töltjük:
    CLEAR W_ALV.
    MOVE W_/ZAK/ANALITIKA-BUKRS  TO W_ALV-BUKRS.
    MOVE W_/ZAK/ANALITIKA-BTYPE  TO W_ALV-BTYPE.
    MOVE W_/ZAK/ANALITIKA-GJAHR  TO W_ALV-GJAHR.
    MOVE W_/ZAK/ANALITIKA-MONAT  TO W_ALV-MONAT.
    MOVE W_/ZAK/ANALITIKA-ZINDEX TO W_ALV-ZINDEX.
    MOVE W_/ZAK/ANALITIKA-BTYPE  TO W_ALV-BTYPE.
    MOVE W_/ZAK/ANALITIKA-ABEVAZ TO W_ALV-ABEVAZ.

*  Megnézzük mi lenne a megfelelő ABEV
    CALL FUNCTION '/ZAK/ABEV_CONTACT'
      EXPORTING
        I_BUKRS        = W_/ZAK/ANALITIKA-BUKRS
        I_BTYPE        = W_/ZAK/ANALITIKA-BTYPE
        I_ABEVAZ       = W_/ZAK/ANALITIKA-ABEVAZ
        I_GJAHR        = W_/ZAK/ANALITIKA-GJAHR
        I_MONAT        = W_/ZAK/ANALITIKA-MONAT
      TABLES
        T_ABEV_CONTACT = LI_ABEV_CONTACT
      EXCEPTIONS
        ERROR_BTYPE    = 1
        ERROR_MONAT    = 2
        ERROR_ABEVAZ   = 3
        OTHERS         = 4.
    IF SY-SUBRC EQ 0.
*++S4HANA#01.
*      DESCRIBE TABLE LI_ABEV_CONTACT LINES SY-TFILL.
*      READ TABLE LI_ABEV_CONTACT INDEX SY-TFILL.
      SY-TFILL = LINES( LI_ABEV_CONTACT ).
      READ TABLE LI_ABEV_CONTACT INTO LI_ABEV_CONTACT INDEX  SY-TFILL.
*--S4HANA#01.
      IF SY-SUBRC EQ 0 AND
         ( LI_ABEV_CONTACT-BTYPE  NE W_/ZAK/ANALITIKA-BTYPE OR
           LI_ABEV_CONTACT-ABEVAZ NE W_/ZAK/ANALITIKA-ABEVAZ ).
*          Ellenőrizzük, hogy le van e zárva
        READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
             WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
                      MONAT = W_/ZAK/ANALITIKA-MONAT
                      ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
*       IDŐSZAK lezárt nem lehet módosítani
        IF SY-SUBRC EQ 0.
*++S4HANA#01.
*          CLEAR LI_CLOSE.
*          MOVE W_/ZAK/ANALITIKA-BUKRS TO LI_CLOSE-BUKRS.
*          MOVE W_/ZAK/ANALITIKA-BTYPE TO LI_CLOSE-BTYPE.
*          MOVE W_/ZAK/ANALITIKA-GJAHR TO LI_CLOSE-GJAHR.
*          MOVE W_/ZAK/ANALITIKA-MONAT TO LI_CLOSE-MONAT.
*          MOVE W_/ZAK/ANALITIKA-ZINDEX TO LI_CLOSE-ZINDEX.
*          COLLECT LI_CLOSE.
          CLEAR LS_LI_CLOSE.
          MOVE W_/ZAK/ANALITIKA-BUKRS TO LS_LI_CLOSE-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE TO LS_LI_CLOSE-BTYPE.
          MOVE W_/ZAK/ANALITIKA-GJAHR TO LS_LI_CLOSE-GJAHR.
          MOVE W_/ZAK/ANALITIKA-MONAT TO LS_LI_CLOSE-MONAT.
          MOVE W_/ZAK/ANALITIKA-ZINDEX TO LS_LI_CLOSE-ZINDEX.
          COLLECT LS_LI_CLOSE INTO LT_LI_CLOSE.
*--S4HANA#01.
*       Egyébként módosítjuk
        ELSE.
          MOVE W_/ZAK/ANALITIKA TO W_/ZAK/ANALITIKA_DEL.
          APPEND W_/ZAK/ANALITIKA_DEL TO I_/ZAK/ANALITIKA_DEL.
*++BG 2007.04.26
*         BTYPE váltás
          IF W_/ZAK/ANALITIKA-BTYPE NE LI_ABEV_CONTACT-BTYPE.
            CLEAR LI_BEVALLI.
            MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO LI_BEVALLI.
            MOVE LI_ABEV_CONTACT-BTYPE TO LI_BEVALLI-BTYPEN.
            COLLECT LI_BEVALLI.
          ENDIF.
*--BG 2007.04.26
          W_/ZAK/ANALITIKA-BTYPE  = LI_ABEV_CONTACT-BTYPE.
          W_/ZAK/ANALITIKA-ABEVAZ = LI_ABEV_CONTACT-ABEVAZ.
          MOVE W_ALV-BTYPE  TO W_ALV-BTYPEE.
          MOVE W_ALV-ABEVAZ TO W_ALV-ABEVAZE.
          MOVE LI_ABEV_CONTACT-BTYPE TO W_ALV-BTYPE.
          MOVE LI_ABEV_CONTACT-ABEVAZ TO W_ALV-ABEVAZ.
          MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA
                                 TRANSPORTING BTYPE ABEVAZ.
        ENDIF.
      ENDIF.
    ENDIF.
*++BG 2007.06.08
*   APPEND W_ALV TO I_ALV.
    COLLECT W_ALV INTO I_ALV.
*--BG 2007.06.08
  ENDLOOP.

*++BG 2007.04.26
* BEVALLI és BEVALLSZ módosítása
*++2012.01.31 BG
  IF P_TESZT IS INITIAL.
*--2012.01.31 BG
*++2065 #04.
    DELETE  I_REL_BEVALL WHERE BIDOSZ EQ 'H'. "havi gyakoriság nem kell!
    LOOP AT LI_BEVALLI.
      L_DATUM(4)   = LI_BEVALLI-GJAHR - 1. "Előző évi utolsó nap beállítása kell!
      L_DATUM+4(2) = 12.
      L_DATUM+6(2) = 31.
      LOOP AT I_REL_BEVALL INTO W_/ZAK/BEVALL
                           WHERE BUKRS EQ LI_BEVALLI-BUKRS
                             AND BTYPE EQ LI_BEVALLI-BTYPE
                             AND DATBI GE L_DATUM
                             AND DATAB LE L_DATUM.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        IF W_/ZAK/BEVALL-BIDOSZ EQ 'E'.
          CLEAR L_MONAT.
          LM_CHECK_BEVALLI 12.
        ELSEIF  W_/ZAK/BEVALL-BIDOSZ EQ 'N'.
          IF LI_BEVALLI-MONAT BETWEEN '01' AND '03'.
            CLEAR L_MONAT.
          ELSEIF LI_BEVALLI-MONAT BETWEEN '04' AND '06'.
            L_MONAT = '04'.
          ELSEIF LI_BEVALLI-MONAT BETWEEN '07' AND '09'.
            L_MONAT = '06'.
          ELSEIF LI_BEVALLI-MONAT BETWEEN '10' AND '12'.
            L_MONAT = '09'.
          ENDIF.
          LM_CHECK_BEVALLI 3.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF NOT LI_BEVALLI_INS[] IS INITIAL.
      APPEND LINES OF LI_BEVALLI_INS TO LI_BEVALLI.
      SORT LI_BEVALLI.
    ENDIF.
*--2065 #04.
    LOOP AT LI_BEVALLI.
*   BEVALLI aktualizálás
      SELECT SINGLE * INTO W_/ZAK/BEVALLI
                      FROM /ZAK/BEVALLI
                     WHERE BUKRS  EQ LI_BEVALLI-BUKRS
                       AND BTYPE  EQ LI_BEVALLI-BTYPE
                       AND GJAHR  EQ LI_BEVALLI-GJAHR
                       AND MONAT  EQ LI_BEVALLI-MONAT
                       AND ZINDEX EQ LI_BEVALLI-ZINDEX.
      IF SY-SUBRC EQ 0.
        MOVE LI_BEVALLI-BTYPEN TO W_/ZAK/BEVALLI-BTYPE.
        MODIFY /ZAK/BEVALLI FROM W_/ZAK/BEVALLI.
      ENDIF.
*   BEVALLSZ aktualizálás
      SELECT * INTO W_/ZAK/BEVALLSZ
               FROM /ZAK/BEVALLSZ
              WHERE BUKRS  EQ LI_BEVALLI-BUKRS
                AND BTYPE  EQ LI_BEVALLI-BTYPE
                AND GJAHR  EQ LI_BEVALLI-GJAHR
                AND MONAT  EQ LI_BEVALLI-MONAT
                AND ZINDEX EQ LI_BEVALLI-ZINDEX.
        MOVE LI_BEVALLI-BTYPEN TO W_/ZAK/BEVALLSZ-BTYPE.
*++S4HANA#01.
*        MODIFY /ZAK/BEVALLSZ FROM W_/ZAK/BEVALLSZ.
*      ENDSELECT.
        APPEND W_/ZAK/BEVALLSZ TO LT_FILTER_W_/ZAK/BEVALLSZ. "$smart
        IF LINES( LT_FILTER_W_/ZAK/BEVALLSZ ) >= 10000.     "$smart
          MODIFY /ZAK/BEVALLSZ FROM TABLE LT_FILTER_W_/ZAK/BEVALLSZ.
          "$smart

          CLEAR LT_FILTER_W_/ZAK/BEVALLSZ[].                "$smart
        ENDIF.                                             "$smart
      ENDSELECT.                                           "$smart
      IF NOT LT_FILTER_W_/ZAK/BEVALLSZ[] IS INITIAL.        "$smart
        MODIFY /ZAK/BEVALLSZ FROM TABLE LT_FILTER_W_/ZAK/BEVALLSZ.
        "$smart

        FREE LT_FILTER_W_/ZAK/BEVALLSZ[].                   "$smart
      ENDIF.                                               "$smart
*--S4HANA#01.

*   BEVALLI törlés
      DELETE FROM /ZAK/BEVALLI
                     WHERE BUKRS  EQ LI_BEVALLI-BUKRS
                       AND BTYPE  EQ LI_BEVALLI-BTYPE
                       AND GJAHR  EQ LI_BEVALLI-GJAHR
                       AND MONAT  EQ LI_BEVALLI-MONAT
                       AND ZINDEX EQ LI_BEVALLI-ZINDEX.

*   BEVALLSZ törlés
      DELETE FROM /ZAK/BEVALLSZ
                     WHERE BUKRS  EQ LI_BEVALLI-BUKRS
                       AND BTYPE  EQ LI_BEVALLI-BTYPE
                       AND GJAHR  EQ LI_BEVALLI-GJAHR
                       AND MONAT  EQ LI_BEVALLI-MONAT
                       AND ZINDEX EQ LI_BEVALLI-ZINDEX.

    ENDLOOP.
*++2012.01.31 BG
  ENDIF.
*--2012.01.31 BG
*--BG 2007.04.26

*++S4HANA#01.
*  IF NOT LI_CLOSE[] IS INITIAL.
*    LOOP AT LI_CLOSE.
*      CONCATENATE LI_CLOSE-BTYPE
*                  LI_CLOSE-GJAHR
*                  LI_CLOSE-MONAT
*                  LI_CLOSE-ZINDEX INTO L_TEXT
*                  SEPARATED BY '/'.
*      CONDENSE L_TEXT.
*      MESSAGE I202 WITH LI_CLOSE-BUKRS L_TEXT.
  IF NOT LT_LI_CLOSE[] IS INITIAL.
    LOOP AT LT_LI_CLOSE INTO LS_LI_CLOSE.
      CONCATENATE LS_LI_CLOSE-BTYPE
                  LS_LI_CLOSE-GJAHR
                  LS_LI_CLOSE-MONAT
                  LS_LI_CLOSE-ZINDEX INTO L_TEXT
                  SEPARATED BY '/'.
      CONDENSE L_TEXT.
      MESSAGE I202 WITH LS_LI_CLOSE-BUKRS L_TEXT.
*--S4HANA#01.
*   & vállalat & időszak nem módosítható mert lezárásra került!
    ENDLOOP.
  ENDIF.

  CHECK P_TESZT IS INITIAL.

  DELETE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_DEL.

  MODIFY /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.

  COMMIT WORK AND WAIT.

  MESSAGE I203.
* Konvertált tételek adatbázisban módosítva!


ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  CALL SCREEN 9000.
ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.

  PERFORM SET_STATUS.

  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_ALV[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.



ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_STATUS.

  TYPES: BEGIN OF TAB_TYPE,
           FCODE LIKE RSMPE-FUNC,
         END OF TAB_TYPE.

  DATA: TAB    TYPE STANDARD TABLE OF TAB_TYPE WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
        WA_TAB TYPE TAB_TYPE.

  IF SY-DYNNR = '9000'.
    IF P_TESZT IS INITIAL.
      SET TITLEBAR 'MAIN9000'.
    ELSE.
      SET TITLEBAR 'MAIN9000T'.
    ENDIF.
    SET PF-STATUS 'MAIN9000'.
  ENDIF.


ENDFORM.                    " SET_STATUS

*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING $I_ALV LIKE I_ALV[]
                                  $FIELDCAT TYPE LVC_T_FCAT
                                  $LAYOUT   TYPE LVC_S_LAYO
                                  $VARIANT  TYPE DISVARIANT.

  DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER.

* Mezőkatalógus összeállítása
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING $FIELDCAT.

* Funkciók kizárása
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

  $LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
  $LAYOUT-SEL_MODE = 'A'.


  CLEAR $VARIANT.
  $VARIANT-REPORT = V_REPID.


  CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = $VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = 'X'
      IS_LAYOUT            = $LAYOUT
      IT_TOOLBAR_EXCLUDING = LI_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = $FIELDCAT
      IT_OUTTAB            = $I_ALV.

*   CREATE OBJECT v_event_receiver.
*   SET HANDLER v_event_receiver->handle_toolbar       FOR v_grid.
*   SET HANDLER v_event_receiver->handle_double_click  FOR v_grid.
*   SET HANDLER v_event_receiver->handle_user_command  FOR v_grid.
*
** raise event TOOLBAR:
*   CALL METHOD v_grid->set_toolbar_interactive.

ENDFORM.                    " create_and_init_alv

*&---------------------------------------------------------------------
*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT USING    $DYNNR    LIKE SYST-DYNNR
                    CHANGING $FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.


  IF $DYNNR = '9000'.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = '/ZAK/EVVCORR_ALV'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = $FIELDCAT.

*     LOOP AT $FIELDCAT INTO S_FCAT.
*         MODIFY $FIELDCAT FROM S_FCAT.
*     ENDLOOP.
  ENDIF.

ENDFORM.                    " build_fieldcat
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.
* Kilépés
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      PERFORM EXIT_PROGRAM USING P_TESZT.

    WHEN OTHERS.
*     do nothing
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_9000  INPUT

*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM EXIT_PROGRAM USING $TESZT.
FORM EXIT_PROGRAM USING $TESZT LIKE P_TESZT..
*--S4HANA#01.
  IF $TESZT IS INITIAL.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM LIST_SPOOL TABLES   $TAB
*                USING    $TAB_NAME.
FORM LIST_SPOOL TABLES   $TAB STRUCTURE /ZAK/EVVCORR_ALV
                USING    $TAB_NAME TYPE CLIKE.
*--S4HANA#01.

*ALV lista init
  PERFORM COMMON_ALV_LIST_INIT USING SY-TITLE
                                     $TAB_NAME
                                     '/ZAK/EVVALT_CORR'.

*ALV lista
  PERFORM COMMON_ALV_LIST_DISPLAY TABLES $TAB
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
