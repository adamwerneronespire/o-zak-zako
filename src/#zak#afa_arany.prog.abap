
*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_ARANY
*&
*&---------------------------------------------------------------------*
*& SAP adatokból ÁFA arányszám meghatározása
*&---------------------------------------------------------------------*
REPORT  /ZAK/AFA_ARANY MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& leválogatja a SAP bizonylatokból az adatokat, meghatározza az
*& arányt és a /ZAK/AFA_ARANY táblába eltárolja
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2007.12.05
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2008.04.09   Balázs G.     Szelekció módosítása, lista kész.
*& 0002   2008.10.17   Balázs G.     Előjel javítás
*& 0003   2009.03.17   Balázs G.     Feldolgozatlan tételek kezelése
*& 0004   2009.04.20   Balázs G.     Arány max.100% javítás
*&---------------------------------------------------------------------*
*++S4HANA#01.
TYPES: BEGIN OF TAB_TYPE,
         FCODE TYPE RSMPE-FUNC,
       END OF TAB_TYPE.
DATA: TAB    TYPE STANDARD TABLE OF TAB_TYPE WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      WA_TAB TYPE TAB_TYPE.
*--S4HANA#01.
INCLUDE /ZAK/COMMON_STRUCT.


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
*++S4HANA#01.
*TABLES T001.
DATA GS_T001 TYPE T001.
*--S4HANA#01.

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
**Részben arányosított
*CONSTANTS C_ARTYPE_R TYPE /ZAK/ARTYPE VALUE 'R'.
**Teljesen arányosított
*CONSTANTS C_ARTYPE_A TYPE /ZAK/ARTYPE VALUE 'A'.
** Adóalap
*CONSTANTS C_ATYPE_A  TYPE /ZAK/ATYPE VALUE 'A'.
* Pénznem
CONSTANTS C_WAERS_HUF TYPE WAERS VALUE 'HUF'.


*Bevallás típus
DATA V_BTYPE TYPE /ZAK/BTYPE.

*IDŐSZAK kezdő és záró dátuma:
DATA V_FIRST_DATE LIKE SY-DATUM.
DATA V_LAST_DATE  LIKE SY-DATUM.

DATA V_REPID LIKE SY-REPID.


TYPES: BEGIN OF T_MWSKZ_ALL,
         MWSKZ TYPE MWSKZ,
         KTOSL TYPE KTOSL_007B,
       END OF T_MWSKZ_ALL.

*++S4HANA#01.
*DATA I_MWSKZ_ALL TYPE T_MWSKZ_ALL OCCURS 0.
DATA GT_I_MWSKZ_ALL TYPE STANDARD TABLE OF T_MWSKZ_ALL .
*--S4HANA#01.
DATA W_MWSKZ     TYPE T_MWSKZ_ALL.

*Kimenő ÁFA kódok
*++S4HANA#01.
*DATA I_MWSKZ_K TYPE T_MWSKZ_ALL OCCURS 0.
DATA GT_I_MWSKZ_K TYPE STANDARD TABLE OF T_MWSKZ_ALL .
*--S4HANA#01.
*Mentes adókódok
*++S4HANA#01.
*DATA I_MWSKZ_M TYPE T_MWSKZ_ALL OCCURS 0.
DATA GT_I_MWSKZ_M TYPE STANDARD TABLE OF T_MWSKZ_ALL .
*--S4HANA#01.

*ÁFA kódok
*++S4HANA#01.
*RANGES R_MWSKZ FOR /ZAK/AFA_CUST-MWSKZ.
TYPES TT_MWSKZ TYPE RANGE OF /ZAK/AFA_CUST-MWSKZ.
DATA GT_MWSKZ TYPE TT_MWSKZ.
DATA GS_MWSKZ TYPE LINE OF TT_MWSKZ.
*--S4HANA#01.

*++S4HANA#01.
*DATA I_ALV_DATA LIKE /ZAK/ARANY_ALV OCCURS 0.
*DATA W_ALV_DATA LIKE /ZAK/ARANY_ALV.
DATA GT_I_ALV_DATA TYPE STANDARD TABLE OF /ZAK/ARANY_ALV .
DATA W_ALV_DATA TYPE /ZAK/ARANY_ALV.
*--S4HANA#01.

*++S4HANA#01.
**++0001 BG 2008.04.09
*DATA I_ALV_ANALITIKA LIKE /ZAK/ARANY_ANAL OCCURS 0.
*DATA W_ALV_ANALITIKA LIKE /ZAK/ARANY_ANAL.
**--0001 BG 2008.04.09
**++0003 BG 2009.03.17
*DATA I_ARANY_FELD LIKE /ZAK/ARANY_FELD OCCURS 0.
**--0003 BG 2009.03.17
DATA GT_I_ALV_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ARANY_ANAL.
DATA W_ALV_ANALITIKA TYPE /ZAK/ARANY_ANAL.
DATA GT_I_ARANY_FELD TYPE STANDARD TABLE OF /ZAK/ARANY_FELD .
*--S4HANA#01.




* ALV kezelési változók
DATA: V_OK_CODE               LIKE SY-UCOMM,
      V_SAVE_OK               LIKE SY-UCOMM,
      V_CONTAINER             TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CUSTOM_CONTAINER      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT              TYPE LVC_T_FCAT,
      V_LAYOUT                TYPE LVC_S_LAYO,
      V_VARIANT               TYPE DISVARIANT,
      V_GRID                  TYPE REF TO CL_GUI_ALV_GRID,
*++0001 BG 2008.04.09
      V_OK_CODE_9100          LIKE SY-UCOMM,
      V_CONTAINER_9100        TYPE SCRFNAME VALUE '/ZAK/ZAK_9100',
      V_CUSTOM_CONTAINER_9100 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT_9100         TYPE LVC_T_FCAT,
      V_LAYOUT_9100           TYPE LVC_S_LAYO,
      V_VARIANT_9100          TYPE DISVARIANT,
      V_GRID_9100             TYPE REF TO CL_GUI_ALV_GRID.
*--0001 BG 2008.04.09

DATA L_STGRP TYPE STGRP_007B.

*LWBAS összegek
DATA V_LWBAS_NMT TYPE /ZAK/LWBAS_NMT.
DATA V_LWBAS_SUM TYPE /ZAK/LWBAS_NMT.

DATA V_TEXT(40).
DATA V_TEXT1(20).
DATA V_TEXT2(20).

* ÁFA kód irány
DEFINE M_0GET_AFABK.
  CLEAR &2.
  SELECT SINGLE STGRP INTO L_STGRP
                      FROM T007B
                     WHERE KTOSL EQ &1.
  IF SY-SUBRC EQ 0.
    CASE L_STGRP.
      WHEN '1'.
        MOVE 'K' TO &2.
      WHEN '2'.
        MOVE 'B' TO &2.
    ENDCASE.
  ENDIF.
END-OF-DEFINITION.

*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.


*Normál kerekítés
DEFINE  M_ROUND_R1.
  CALL FUNCTION 'ROUND'
    EXPORTING
      DECIMALS      = 0
      INPUT         = &1
      SIGN          = 'X'
    IMPORTING
      OUTPUT        = &2
    EXCEPTIONS
      INPUT_INVALID = 1
      OVERFLOW      = 2
      TYPE_INVALID  = 3
      OTHERS        = 4.
  IF SY-SUBRC NE 0.
    MESSAGE E242 WITH &1.
*   Hiba a & összeg kerekítésénél!
  ENDIF.
END-OF-DEFINITION.

*Egész számra kerekítés
DEFINE  M_ROUND_R2.
  V_TEXT = &1.
  CONDENSE V_TEXT.
  SPLIT V_TEXT AT '.' INTO V_TEXT1 V_TEXT2.
  CONDENSE: V_TEXT1, V_TEXT2.
  IF V_TEXT2 NE '000'.
    &2 = V_TEXT1.
    &2 = &2 + 1.
  ELSE.
    &2 = V_TEXT1.
  ENDIF.

END-OF-DEFINITION.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Vállalat.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-101.
    PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                              OBLIGATORY MEMORY ID BUK.
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.

*Év
  PARAMETERS P_GJAHR TYPE GJAHR OBLIGATORY DEFAULT SY-DATUM(4).
*Hónap
  PARAMETERS P_MONAT TYPE MONAT OBLIGATORY.

*Teszt futás
  PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
  PARAMETERS: P_R1 RADIOBUTTON GROUP GR1,
              P_R2 RADIOBUTTON GROUP GR1 DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL02.
*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.

  MOVE SY-REPID TO V_REPID.
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

*  Képernyő attribútomok beállítása
  PERFORM SET_SCREEN_ATTRIBUTES.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
* Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.
* IDŐSZAK megadás ellenőrzése
*  PERFORM VER_MONAT USING P_BUKRS
*                          P_GJAHR
*                          P_MONAT.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING
                                P_BUKRS
                                C_BTYPART_AFA
                                C_ACTVT_01.
* Vállalat adatok meghatározása
  PERFORM GET_T001 USING P_BUKRS.


* Meghatározzuk a bevallás típust
  PERFORM GET_BTYPE  USING P_BUKRS
                           P_GJAHR
                           P_MONAT
                 CHANGING  V_BTYPE.

* IDŐSZAK utolsó és első napjának meghatározása
  PERFORM GET_FIRST_LAST_DATE USING P_GJAHR
                                    P_MONAT
                           CHANGING V_FIRST_DATE
                                    V_LAST_DATE.

* Ellenőrizzük, meghatározzuk a beállítást
  PERFORM GET_BEVALL USING P_BUKRS
                           V_BTYPE
                           V_LAST_DATE
                  CHANGING W_/ZAK/BEVALL.

* ÁFA kódok meghatározása
*++S4HANA#01.
*  PERFORM GET_MWSKZ TABLES  I_MWSKZ_ALL
*                            I_MWSKZ_M
*                            R_MWSKZ
  PERFORM GET_MWSKZ TABLES  GT_I_MWSKZ_ALL
                            GT_I_MWSKZ_M
                            GT_MWSKZ
*--S4HANA#01.
                      USING  W_/ZAK/BEVALL.

* Adatok szelektálása
*++S4HANA#01.
*  PERFORM GET_SEL_DATA TABLES R_MWSKZ
*                              I_MWSKZ_ALL
*                              I_MWSKZ_M
*                              I_ALV_DATA
**++0001 BG 2008.04.09
*                              I_ALV_ANALITIKA
**--0001 BG 2008.04.09
**++0003 BG 2009.03.17
*                              I_ARANY_FELD
**--0003 BG 2009.03.17
*                       USING  P_BUKRS
**++0003 BG 2009.03.17
*                              P_GJAHR
**--0003 BG 2009.03.17
*                              V_FIRST_DATE
*                              V_LAST_DATE
*                              V_LWBAS_NMT
*                              V_LWBAS_SUM.
  PERFORM GET_SEL_DATA TABLES GT_MWSKZ
                              GT_I_MWSKZ_ALL
                              GT_I_MWSKZ_M
                              GT_I_ALV_DATA
                              GT_I_ALV_ANALITIKA
                              GT_I_ARANY_FELD
                       USING  P_BUKRS
                              P_GJAHR
                              V_FIRST_DATE
                              V_LAST_DATE
                     CHANGING V_LWBAS_NMT
                              V_LWBAS_SUM.
*--S4HANA#01.

*++0003 BG 2009.03.17
  IF V_LWBAS_SUM IS INITIAL.
    MESSAGE I031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.
*--0003 BG 2009.03.17


* Éles futtatás adatbázis módosítás
*++0003 BG 2009.03.17
*++S4HANA#01.
*  PERFORM MOD_DATA TABLES I_ARANY_FELD
  PERFORM MOD_DATA TABLES GT_I_ARANY_FELD
*--S4HANA#01.
*--0003 BG 2009.03.17
                     USING  P_BUKRS
                            P_GJAHR
                            P_MONAT
                            P_TEST
                            V_LWBAS_NMT
                            V_LWBAS_SUM
                            P_R1
                            P_R2.

END-OF-SELECTION.

*  Háttérben nem készítünk listát.
  IF SY-BATCH IS INITIAL.
    PERFORM LIST_DISPLAY.
  ENDIF.




************************************************************************
*                             ALPROGRAMOK
***********************************************************************

*&---------------------------------------------------------------------*
*&      Form  set_screen_attributes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " set_screen_attributes

*&---------------------------------------------------------------------
*
*&      Form  read_additionals
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS.

* Vállalat megnevezése
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.
  ENDIF.


ENDFORM.                    " read_additionals

*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      <--P_V_BUKRS  text
*----------------------------------------------------------------------*
FORM ROTATE_BUKRS_OUTPUT  USING    $BUKRS
                          CHANGING $BUKRS_OUTPUT.

  CLEAR $BUKRS_OUTPUT.

  CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
    EXPORTING
      I_AD_BUKRS    = $BUKRS
    IMPORTING
      E_FI_BUKRS    = $BUKRS_OUTPUT
    EXCEPTIONS
      MISSING_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E231 WITH $BUKRS.
*    Hiba a & vállalat forgatás meghatározásnál!
  ENDIF.

ENDFORM.                    " ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  GET_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      <--P_V_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_BTYPE  USING    $BUKRS
*                         $GJAHR
*                         $MONAT
*                CHANGING $BTYPE.
FORM GET_BTYPE  USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                         $GJAHR TYPE GJAHR
                         $MONAT TYPE MONAT
                CHANGING $BTYPE TYPE /ZAK/BTYPE.
*--S4HANA#01.

* Bevallás típus meghatározás
  CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
    EXPORTING
      I_BUKRS     = $BUKRS
      I_BTYPART   = C_BTYPART_AFA
      I_GJAHR     = $GJAHR
      I_MONAT     = $MONAT
    IMPORTING
      E_BTYPE     = $BTYPE
    EXCEPTIONS
      ERROR_MONAT = 1
      ERROR_BTYPE = 2
      OTHERS      = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_BTYPE
*&---------------------------------------------------------------------*
*&      Form  get_first_last_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      <--P_V_FIRST_DATE  text
*      <--P_V_LAST_DATE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_FIRST_LAST_DATE  USING    $GJAHR
*                                   $MONAT
*                          CHANGING $FIRST_DATE
*                                   $LAST_DATE.
FORM GET_FIRST_LAST_DATE  USING    $GJAHR TYPE GJAHR
                                   $MONAT TYPE MONAT
                          CHANGING $FIRST_DATE TYPE SY-DATUM
                                   $LAST_DATE TYPE SY-DATUM.
*--S4HANA#01.

  CONCATENATE $GJAHR $MONAT '01' INTO $FIRST_DATE.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = $FIRST_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = $LAST_DATE
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*++BG 2008.04.14
* A kezdeti időszak mindig az adott év első napja
  CONCATENATE $GJAHR '01' '01' INTO $FIRST_DATE.
*--BG 2008.04.14


ENDFORM.                    " get_first_last_date
*&---------------------------------------------------------------------*
*&      Form  GET_BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_BTYPE  text
*      -->P_V_LAST_DATE  text
*      <--P_W_/ZAK/BEVALL  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_BEVALL  USING    $BUKRS
*                          $BTYPE
*                          $LAST_DATE
FORM GET_BEVALL  USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                          $BTYPE TYPE /ZAK/BTYPE
                          $LAST_DATE TYPE SY-DATUM
*--S4HANA#01.
                 CHANGING $/ZAK/BEVALL STRUCTURE /ZAK/BEVALL.


*++S4HANA#01.
*  SELECT SINGLE * INTO $/ZAK/BEVALL
*                  FROM /ZAK/BEVALL
*                 WHERE BUKRS EQ $BUKRS
*                   AND BTYPE EQ $BTYPE
*                   AND DATBI GE $LAST_DATE
*                   AND DATAB LE $LAST_DATE.
  SELECT * INTO $/ZAK/BEVALL
                  FROM /ZAK/BEVALL UP TO 1 ROWS
                 WHERE BUKRS EQ $BUKRS
                   AND BTYPE EQ $BTYPE
                   AND DATBI GE $LAST_DATE
                   AND DATAB LE $LAST_DATE
                 ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.
  IF SY-SUBRC NE 0.
    MESSAGE E236 WITH $BUKRS $BTYPE $LAST_DATE.
*   Hiba a bevallás adatok meghatározásánál!(&/&/&)
  ENDIF.

* Ha a bevallás nem arányosított
  IF $/ZAK/BEVALL-ARTYPE IS INITIAL.
    MESSAGE E237.
*   A megadott adatokkal nem lehet arányosított bevallás típust meghatár
  ENDIF.

ENDFORM.                    " GET_BEVALL
*&---------------------------------------------------------------------*
*&      Form  VER_MONAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_GAJHR  text
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
FORM VER_MONAT  USING    $BUKRS
                         $GJAHR
                         $MONAT.

  DATA L_MONAT TYPE MONAT.

  SELECT MAX( MONAT ) INTO L_MONAT
                      FROM /ZAK/AFA_ARANY
                     WHERE BUKRS EQ $BUKRS
                       AND GJAHR EQ $GJAHR
                     GROUP BY BUKRS GJAHR MONAT.
  ENDSELECT.
  IF SY-SUBRC NE 0 AND $MONAT NE '01'.
    ADD 1 TO L_MONAT.
    MESSAGE W238 WITH $BUKRS L_MONAT.
*   A program & vállalatra csak & hónapra futtatható!
  ELSE.
    ADD 1 TO L_MONAT.
    IF L_MONAT NE $MONAT.
      MESSAGE W238 WITH $BUKRS L_MONAT.
*   A program & vállalatra csak & hónapra futtatható!
    ENDIF.
  ENDIF.

ENDFORM.                    " VER_MONAT
*&---------------------------------------------------------------------*
*&      Form  GET_MWSKZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MWSKZ_ALL  text
*      -->P_I_MWSKZ_K  text
*      -->P_I_MWSKZ_M  text
*      -->P_P_BUKRS  text
*      -->P_W_/ZAK/BEVALL  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_MWSKZ  TABLES   $I_MWSKZ_ALL  LIKE I_MWSKZ_ALL
*                         $I_MWSKZ_M    LIKE I_MWSKZ_M
*                         $R_MWSKZ      STRUCTURE R_MWSKZ
FORM GET_MWSKZ  TABLES $I_MWSKZ_ALL  LIKE GT_I_MWSKZ_ALL
                       $I_MWSKZ_M    LIKE GT_I_MWSKZ_M
                       $R_MWSKZ      STRUCTURE GS_MWSKZ
*--S4HANA#01.
              USING    $W_/ZAK/BEVALL STRUCTURE /ZAK/BEVALL.

  DATA L_RARANY LIKE /ZAK/AFA_RARANY.

  DEFINE LM_SORT.
    SORT &1.
    DELETE ADJACENT DUPLICATES FROM &1.
  END-OF-DEFINITION.

* ÁFA kódok feltöltése
  SELECT * INTO CORRESPONDING FIELDS OF W_MWSKZ
           FROM /ZAK/AFA_CUST
          WHERE BTYPE = $W_/ZAK/BEVALL-BTYPE
            AND ATYPE = C_ATYPE_A
*++BG 2008.04.14
*  Mert ez a típus fordított adózású beszerzés
*  amit ki kell hagyni.
            AND KTOSL NE 'ESA'
*--BG 2008.04.14
            .
    APPEND W_MWSKZ TO $I_MWSKZ_ALL.
    M_DEF $R_MWSKZ 'I' 'EQ' W_MWSKZ-MWSKZ SPACE.
  ENDSELECT.
  IF SY-SUBRC NE 0.
    MESSAGE E032.
*   Hiba az ÁFA beállítások meghatározásánál!
  ENDIF.

* Adómentes rész feltöltése
  SELECT * INTO CORRESPONDING FIELDS OF W_MWSKZ         "#EC CI_NOWHERE
           FROM /ZAK/ARANY_CUST.

    APPEND W_MWSKZ TO $I_MWSKZ_ALL.
    M_DEF $R_MWSKZ 'I' 'EQ' W_MWSKZ-MWSKZ SPACE.
    APPEND W_MWSKZ TO $I_MWSKZ_M.
  ENDSELECT.

  LM_SORT: $I_MWSKZ_ALL, $I_MWSKZ_M.


ENDFORM.                    " GET_MWSKZ
*&---------------------------------------------------------------------*
*&      Form  GET_SEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_SEL_DATA TABLES $R_MWSKZ      STRUCTURE R_MWSKZ
*                         $I_MWSKZ_ALL  LIKE I_MWSKZ_ALL
*                         $I_MWSKZ_M    LIKE I_MWSKZ_M
*                         $I_ALV_DATA   LIKE I_ALV_DATA
**++0001 BG 2008.04.09
*                         $I_ALV_ANALITIKA  LIKE I_ALV_ANALITIKA
**--0001 BG 2008.04.09
**++0003 BG 2009.03.17
*                         $I_ARANY_FELD    STRUCTURE /ZAK/ARANY_FELD
**--0003 BG 2009.03.17
*                  USING  $BUKRS
**++0003 BG 2009.03.17
*                         $GJAHR
**--0003 BG 2009.03.17
*                         $FIRST_DATE
*                         $LAST_DATE
*                         $LWBAS_NMT
*                         $LWBAS_SUM.
FORM GET_SEL_DATA TABLES $R_MWSKZ      STRUCTURE GS_MWSKZ
                         $I_MWSKZ_ALL  LIKE GT_I_MWSKZ_ALL
                         $I_MWSKZ_M    LIKE GT_I_MWSKZ_M
                         $I_ALV_DATA   LIKE GT_I_ALV_DATA
                         $I_ALV_ANALITIKA  LIKE GT_I_ALV_ANALITIKA
                         $I_ARANY_FELD    STRUCTURE /ZAK/ARANY_FELD
                  USING  $BUKRS TYPE /ZAK/BEVALL-BUKRS
                         $GJAHR TYPE GJAHR
                         $FIRST_DATE TYPE SY-DATUM
                         $LAST_DATE TYPE SY-DATUM
                         CHANGING $LWBAS_NMT TYPE /ZAK/LWBAS_NMT
                         $LWBAS_SUM TYPE /ZAK/LWBAS_NMT.
*--S4HANA#01.

*--S4HANA#01.
*  DATA L_AFA_IRANY.
  DATA L_AFA_IRANY TYPE C.
*--S4HANA#01.

*++0003 BG 2009.03.17
  DATA LW_ARANY_FELD LIKE /ZAK/ARANY_FELD.
*--0003 BG 2009.03.17

  TYPES: BEGIN OF LT_DATA,
           BUKRS TYPE BUKRS,
           MWSKZ TYPE MWSKZ,
           KTOSL TYPE KTOSL,
           LWBAS TYPE LWBAS_BSET,
           LSTML TYPE LAND1_STML,
           WAERS TYPE WAERS,
           SHKZG TYPE SHKZG,
           HWBAS TYPE HWBAS_BSES,
         END OF LT_DATA.

  DATA LW_DATA TYPE LT_DATA.
  DATA LW_BSET TYPE BSET.

*++S4HANA#01.
*  DATA LI_BKPF LIKE BKPF OCCURS 0 WITH HEADER LINE.
  TYPES: TT_LI_BKPF TYPE STANDARD TABLE OF BKPF .
  TYPES: BEGIN OF TS_LI_BKPF_SEL,
           BUKRS TYPE BKPF-BUKRS,
           BELNR TYPE BKPF-BELNR,
           GJAHR TYPE BKPF-GJAHR,
         END OF TS_LI_BKPF_SEL.
  DATA: LT_LI_BKPF TYPE TABLE OF TS_LI_BKPF_SEL.
  DATA: LS_LI_BKPF TYPE TS_LI_BKPF_SEL.
*--S4HANA#01.
*++0001 BG 2008.04.09
*  DATA LI_AD001 LIKE ZMT_AD001_BKPF OCCURS 0 WITH HEADER LINE.
  DATA L_DATUM LIKE SY-DATUM.
*--0001 BG 2008.04.09
  RANGES LR_KTOSL FOR BSET-KTOSL.


  DEFINE LM_GET_KTOSL.
    REFRESH LR_KTOSL.
    LOOP AT &1 INTO W_MWSKZ
                      WHERE MWSKZ = LW_DATA-MWSKZ.
      IF NOT W_MWSKZ-KTOSL IS INITIAL.
        M_DEF LR_KTOSL 'I' 'EQ' W_MWSKZ-KTOSL SPACE.
      ENDIF.
    ENDLOOP.
  END-OF-DEFINITION.

  DATA L_WBAS TYPE LWBAS_BSET.

  DEFINE LM_GET_WBAS_SUM.

    IF NOT &1-LWBAS IS INITIAL.
      MOVE &1-LWBAS TO L_WBAS.
    ELSE.
      MOVE &1-HWBAS TO L_WBAS.
    ENDIF.

    IF &1-SHKZG EQ 'H'.
      L_WBAS = ABS( L_WBAS ).
    ELSEIF &1-SHKZG EQ 'S'.
      L_WBAS = ABS( L_WBAS ) * -1.
    ENDIF.

    MOVE L_WBAS TO &2.

  END-OF-DEFINITION.

  CLEAR: $LWBAS_NMT, $LWBAS_SUM.

* Fej adatok
*++S4HANA#01.
*  SELECT * INTO TABLE LI_BKPF
  SELECT BUKRS BELNR GJAHR INTO TABLE LT_LI_BKPF
*--S4HANA#01.
                 FROM BKPF
                WHERE BUKRS EQ $BUKRS
                  AND BUDAT LE $LAST_DATE
                  AND BUDAT GE $FIRST_DATE.

*++0003 BG 2009.03.17
* Feldolgozatlan tételek
*++S4HANA#01.
*  REFRESH $I_ARANY_FELD.
  CLEAR $I_ARANY_FELD[].
*--S4HANA#01.
  SELECT * INTO TABLE $I_ARANY_FELD
           FROM /ZAK/ARANY_FELD
          WHERE BUKRS EQ $BUKRS
            AND GJAHR EQ $GJAHR.
  IF SY-SUBRC EQ 0.
*++S4HANA#01.
*    SELECT * APPENDING TABLE LI_BKPF
    SELECT BUKRS BELNR GJAHR APPENDING TABLE LT_LI_BKPF
*--S4HANA#01.
            FROM BKPF
            FOR ALL ENTRIES IN $I_ARANY_FELD
            WHERE BUKRS EQ $I_ARANY_FELD-BUKRS
              AND BELNR EQ $I_ARANY_FELD-BBELNR
              AND GJAHR EQ $I_ARANY_FELD-BGJAHR.
  ENDIF.

*++S4HANA#01.
*  REFRESH $I_ARANY_FELD.
  CLEAR $I_ARANY_FELD[].
*--S4HANA#01.

*  IF SY-SUBRC EQ 0.
*++S4HANA#01.
*  IF NOT LI_BKPF[] IS INITIAL.
  IF NOT LT_LI_BKPF[] IS INITIAL.
*--S4HANA#01.
*--0003 BG 2009.03.17
*++0001 BG 2008.04.09
* Leválogatjuk a bizonylat adó szegmens adatait
*    SELECT * INTO TABLE LI_AD001
*             FROM ZMT_AD001_BKPF
*             FOR ALL ENTRIES IN LI_BKPF
*             WHERE BUKRS = LI_BKPF-BUKRS
*               AND BELNR = LI_BKPF-BELNR
*               AND GJAHR = LI_BKPF-GJAHR.
*    SORT LI_AD001.

*++S4HANA#01.
*    LOOP AT LI_BKPF.
    LOOP AT LT_LI_BKPF INTO LS_LI_BKPF.
*--S4HANA#01.
*      READ TABLE LI_AD001 WITH KEY BUKRS = LI_BKPF-BUKRS
*                                   GJAHR = LI_BKPF-GJAHR
*                                   BELNR = LI_BKPF-BELNR
*                                   BINARY SEARCH.
*      IF SY-SUBRC EQ 0 AND NOT LI_AD001-ADODAT IS INITIAL.
*        MOVE LI_AD001-ADODAT TO L_DATUM.
*      ELSE.
*        MOVE LI_BKPF-BLDAT TO L_DATUM.
*      ENDIF.
*++BG 2008.04.14
*     IF L_DATUM > $LAST_DATE.
      IF L_DATUM > $LAST_DATE OR L_DATUM < $FIRST_DATE.
*--BG 2008.04.14
*++0003 BG 2009.03.17
*     Elmentjük a feldolgozatlan tételekhez ha évet vált.
*++S4HANA#01.
*        IF L_DATUM(4) NE  LI_BKPF-GJAHR.
*          CLEAR LW_ARANY_FELD.
*          MOVE LI_BKPF-BUKRS TO LW_ARANY_FELD-BUKRS.
*          MOVE L_DATUM(4) TO LW_ARANY_FELD-GJAHR.
*          MOVE LI_BKPF-BELNR TO LW_ARANY_FELD-BBELNR.
*          MOVE LI_BKPF-GJAHR TO LW_ARANY_FELD-BGJAHR.
        IF L_DATUM(4) NE  LS_LI_BKPF-GJAHR.
          CLEAR LW_ARANY_FELD.
          MOVE LS_LI_BKPF-BUKRS TO LW_ARANY_FELD-BUKRS.
          MOVE L_DATUM(4) TO LW_ARANY_FELD-GJAHR.
          MOVE LS_LI_BKPF-BELNR TO LW_ARANY_FELD-BBELNR.
          MOVE LS_LI_BKPF-GJAHR TO LW_ARANY_FELD-BGJAHR.
*--S4HANA#01.
          MOVE SY-UNAME TO LW_ARANY_FELD-AS4USER.
          MOVE SY-DATUM TO LW_ARANY_FELD-AS4DATE.
          MOVE SY-UZEIT TO LW_ARANY_FELD-AS4TIME.
          APPEND LW_ARANY_FELD TO $I_ARANY_FELD.
        ENDIF.
*--0003 BG 2009.03.17
*++S4HANA#01.
*        DELETE LI_BKPF.
        DELETE LT_LI_BKPF.
*--S4HANA#01.
      ENDIF.
    ENDLOOP.
*--0001 BG 2008.04.09

*++0003 BG 2009.03.17
*++S4HANA#01.
*    CHECK NOT LI_BKPF[] IS INITIAL.
    CHECK NOT LT_LI_BKPF[] IS INITIAL.
*--S4HANA#01.
*--0003 BG 2009.03.17

*   ÁFA bizonylatok
*++0001 BG 2008.04.09
*   SELECT * INTO CORRESPONDING FIELDS OF LW_DATA
    SELECT * INTO LW_BSET
*--0001 BG 2008.04.09
             FROM BSET
*++S4HANA#01.
*             FOR ALL ENTRIES IN LI_BKPF
*             WHERE BUKRS = LI_BKPF-BUKRS
*               AND BELNR = LI_BKPF-BELNR
*               AND GJAHR = LI_BKPF-GJAHR
*               AND MWSKZ IN $R_MWSKZ.
              FOR ALL ENTRIES IN LT_LI_BKPF
              WHERE BUKRS = LT_LI_BKPF-BUKRS
                AND BELNR = LT_LI_BKPF-BELNR
                AND GJAHR = LT_LI_BKPF-GJAHR
                AND MWSKZ IN $R_MWSKZ
              ORDER BY PRIMARY KEY.
*--S4HANA#01.
*++0001 BG 2008.04.09
      MOVE-CORRESPONDING LW_BSET TO LW_DATA.
      MOVE-CORRESPONDING LW_BSET TO W_ALV_ANALITIKA.
*++S4HANA#01.
*      MOVE T001-WAERS TO W_ALV_ANALITIKA-HW_WAERS.
      MOVE GS_T001-WAERS TO W_ALV_ANALITIKA-HW_WAERS.
*--S4HANA#01.
      SELECT SINGLE WAERS INTO W_ALV_ANALITIKA-LW_WAERS
                          FROM T005
                         WHERE LAND1 EQ W_ALV_ANALITIKA-LSTML.
      IF W_ALV_ANALITIKA-SHKZG EQ 'H'.
        W_ALV_ANALITIKA-HWBAS = ABS( W_ALV_ANALITIKA-HWBAS ).
        W_ALV_ANALITIKA-HWSTE = ABS( W_ALV_ANALITIKA-HWSTE ).
        W_ALV_ANALITIKA-LWBAS = ABS( W_ALV_ANALITIKA-LWBAS ).
        W_ALV_ANALITIKA-LWSTE = ABS( W_ALV_ANALITIKA-LWSTE ).
      ELSEIF W_ALV_ANALITIKA-SHKZG EQ 'S'.
        W_ALV_ANALITIKA-HWBAS = ABS( W_ALV_ANALITIKA-HWBAS ) * -1 .
        W_ALV_ANALITIKA-HWSTE = ABS( W_ALV_ANALITIKA-HWSTE ) * -1.
        W_ALV_ANALITIKA-LWBAS = ABS( W_ALV_ANALITIKA-LWBAS ) * -1.
        W_ALV_ANALITIKA-LWSTE = ABS( W_ALV_ANALITIKA-LWSTE ) * -1.
      ENDIF.
*--0001 BG 2008.04.09
*     Pénznem mező meghatározása
      SELECT SINGLE WAERS INTO LW_DATA-WAERS
                          FROM T005
                         WHERE LAND1 = LW_DATA-LSTML.
*++S4HANA#01.
*      IF LW_DATA-WAERS NE T001-WAERS.
*        MESSAGE E243 WITH LW_DATA-WAERS T001-WAERS.
      IF LW_DATA-WAERS NE GS_T001-WAERS.
        MESSAGE E243 WITH LW_DATA-WAERS GS_T001-WAERS.
*--S4HANA#01.
*   A feldolgozásban & pénznem, nem egyezik meg a vállalat & pénznemével
      ENDIF.
*++S4HANA#01.
      SORT $I_MWSKZ_M BY MWSKZ.
*--S4HANA#01.
      READ TABLE $I_MWSKZ_M TRANSPORTING NO FIELDS   "#EC_CI_SORTED
                 WITH KEY MWSKZ = LW_DATA-MWSKZ
                 BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LM_GET_KTOSL $I_MWSKZ_M.
*     Feltöltjük a mentes körből a KTOSL-eket
        IF LW_DATA-KTOSL IN LR_KTOSL.
          CLEAR W_ALV_DATA.
          MOVE LW_DATA-BUKRS TO W_ALV_DATA-BUKRS.
          MOVE LW_DATA-MWSKZ TO W_ALV_DATA-MWSKZ.
          MOVE LW_DATA-KTOSL TO W_ALV_DATA-KTOSL.
          MOVE 'X' TO W_ALV_DATA-AFAMENT.
*         Előjel meghatározása összeghez
          LM_GET_WBAS_SUM LW_DATA W_ALV_DATA-LWBAS_SUM.
*++S4HANA#01.
*          MOVE T001-WAERS    TO W_ALV_DATA-WAERS.
*          COLLECT W_ALV_DATA INTO I_ALV_DATA.
          MOVE GS_T001-WAERS    TO W_ALV_DATA-WAERS.
          COLLECT W_ALV_DATA INTO GT_I_ALV_DATA.
*--S4HANA#01.
*++0002 BG 2008.10.17
*         ADD LW_DATA-LWBAS TO $LWBAS_SUM.
          ADD W_ALV_DATA-LWBAS_SUM TO $LWBAS_SUM.
*--0002 BG 2008.10.17
*++0001 BG 2008.04.09
          APPEND W_ALV_ANALITIKA TO $I_ALV_ANALITIKA.
*--0001 BG 2008.04.09
        ENDIF.
*     Ellenőrizn kell, hogy kimenő e
      ELSE.
        M_0GET_AFABK LW_DATA-KTOSL L_AFA_IRANY.
        IF L_AFA_IRANY EQ 'K'.
*         Ha KIMENŐ akkor feltöltjük a KTOSL-eket.
          LM_GET_KTOSL $I_MWSKZ_ALL.
          IF SY-SUBRC EQ 0 AND LW_DATA-KTOSL IN LR_KTOSL.
            CLEAR W_ALV_DATA.
            MOVE LW_DATA-BUKRS TO W_ALV_DATA-BUKRS.
            MOVE LW_DATA-MWSKZ TO W_ALV_DATA-MWSKZ.
            MOVE LW_DATA-KTOSL TO W_ALV_DATA-KTOSL.
*           Előjel meghatározása összeghez
            LM_GET_WBAS_SUM LW_DATA W_ALV_DATA-LWBAS_SUM.
*++S4HANA#01.
*            MOVE T001-WAERS    TO W_ALV_DATA-WAERS.
*            COLLECT W_ALV_DATA INTO I_ALV_DATA.
            MOVE GS_T001-WAERS    TO W_ALV_DATA-WAERS.
            COLLECT W_ALV_DATA INTO GT_I_ALV_DATA.
*--S4HANA#01.
*++0002 BG 2008.10.17
*            ADD LW_DATA-LWBAS TO $LWBAS_SUM.
*            ADD LW_DATA-LWBAS TO $LWBAS_NMT.
            ADD W_ALV_DATA-LWBAS_SUM TO $LWBAS_SUM.
            ADD W_ALV_DATA-LWBAS_SUM TO $LWBAS_NMT.
*--0002 BG 2008.10.17
*++0001 BG 2008.04.09
            APPEND W_ALV_ANALITIKA TO $I_ALV_ANALITIKA.
*--0001 BG 2008.04.09
          ENDIF.
        ENDIF.
      ENDIF.
    ENDSELECT.

  ENDIF.


ENDFORM.                    " GET_SEL_DATA
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .

  CALL SCREEN 9000.

ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
*++S4HANA#01.
*  TYPES: BEGIN OF TAB_TYPE,
*           FCODE LIKE RSMPE-FUNC,
*         END OF TAB_TYPE.
*
*  DATA: TAB    TYPE STANDARD TABLE OF TAB_TYPE WITH
*                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
*        WA_TAB TYPE TAB_TYPE.
*--S4HANA#01.

  IF P_TEST IS INITIAL.
    SET TITLEBAR 'MAIN9000'.
  ELSE.
    SET TITLEBAR 'MAIN9000T'.
  ENDIF.
  SET PF-STATUS 'MAIN9000'.


  IF V_CUSTOM_CONTAINER IS INITIAL.
*++S4HANA#01.
*    PERFORM CREATE_AND_INIT_ALV CHANGING I_ALV_DATA[]
    PERFORM CREATE_AND_INIT_ALV CHANGING GT_I_ALV_DATA[]
*--S4HANA#01.
                                       I_FIELDCAT
                                       V_LAYOUT
                                       V_VARIANT.

  ENDIF.


ENDMODULE.                 " STATUS_9000  OUTPUT

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
FORM CREATE_AND_INIT_ALV CHANGING $I_ALV_DATA LIKE
*++S4HANA#01.
*                                                   I_ALV_DATA[]
                                                    GT_I_ALV_DATA[]
*--S4HANA#01.
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
                                  '/ZAK/ARANY_ALV'
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
      IT_OUTTAB            = $I_ALV_DATA.

*   CREATE OBJECT v_event_receiver.
*   SET HANDLER v_event_receiver->handle_toolbar       FOR v_grid.
*   SET HANDLER v_event_receiver->handle_double_click  FOR v_grid.
*   SET HANDLER v_event_receiver->handle_user_command  FOR v_grid.
*
** raise event TOOLBAR:
*   CALL METHOD v_grid->set_toolbar_interactive.

ENDFORM.                    " create_and_init_alv



*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM BUILD_FIELDCAT USING    $DYNNR    LIKE SYST-DYNNR
*                             $TABLE_NAME
FORM BUILD_FIELDCAT USING    $DYNNR    TYPE SYST-DYNNR
                             $TABLE_NAME TYPE CLIKE
*--S4HANA#01.
                    CHANGING $FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = $TABLE_NAME
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = $FIELDCAT.

  LOOP AT $FIELDCAT INTO S_FCAT.
    IF  S_FCAT-FIELDNAME = 'AFAMENT'.
      S_FCAT-CHECKBOX = 'X'.
      MODIFY $FIELDCAT FROM S_FCAT.
    ENDIF.
  ENDLOOP.

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
      PERFORM EXIT_PROGRAM USING P_TEST.

*++0001 BG 2008.04.09
    WHEN 'ANALITIKA'.
      CALL SCREEN 9100.
*--0001 BG 2008.04.09

    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9000  INPUT



*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM EXIT_PROGRAM USING $TESZT.
FORM EXIT_PROGRAM USING $TESZT LIKE P_TEST.
*--S4HANA#01.
  IF $TESZT IS INITIAL.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  MOD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      -->P_P_TEST  text
*      -->P_V_LWBAS_NMT  text
*      -->P_V_LWBAS_SUM  text
*----------------------------------------------------------------------*
*++0003 BG 2009.03.17
FORM MOD_DATA  TABLES   $I_ARANY_FELD STRUCTURE /ZAK/ARANY_FELD
*--0003 BG 2009.03.17
*++S4HANA#01.
*               USING    $BUKRS
*                        $GJAHR
*                        $MONAT
*                        $TEST
*                        $LWBAS_NMT
*                        $LWBAS_SUM
*                        $R1
*                        $R2.
               USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                        $GJAHR TYPE GJAHR
                        $MONAT TYPE MONAT
                        $TEST LIKE P_TEST
                        $LWBAS_NMT TYPE /ZAK/LWBAS_NMT
                        $LWBAS_SUM TYPE /ZAK/LWBAS_NMT
                        $R1 LIKE P_R1
                        $R2 LIKE P_R2.
*--S4HANA#01.

  DATA LW_AFA_ARANY LIKE /ZAK/AFA_ARANY.
  DATA L_MONAT TYPE MONAT.
  DATA L_ARANY TYPE P DECIMALS 3.

  CHECK $TEST IS INITIAL.

*++BG 2008.04.14
* Mivel mindig az év első napjától szelektálunk, ez már nem kell!
** Meghatározzuk az előző rekordot ha nem első hónap!
*  IF $MONAT NE '01'.
*    L_MONAT = $MONAT - 1.
*    SELECT SINGLE * INTO LW_AFA_ARANY
*                    FROM /ZAK/AFA_ARANY
*                   WHERE BUKRS EQ $BUKRS
*                     AND GJAHR EQ $GJAHR
*                     AND MONAT EQ L_MONAT.
*    IF SY-SUBRC NE 0.
*      MESSAGE E240 WITH $BUKRS $GJAHR $MONAT.
**   Nem található előző időszakhoz adat az arány kiszámításához! (&/&/&)
*    ENDIF.
*  ENDIF.
*--BG 2008.04.14

* Arány kiszámítása
  CLEAR W_/ZAK/AFA_ARANY.
  MOVE $BUKRS TO W_/ZAK/AFA_ARANY-BUKRS.
  MOVE $GJAHR TO W_/ZAK/AFA_ARANY-GJAHR.
  MOVE $MONAT TO W_/ZAK/AFA_ARANY-MONAT.
*++S4HANA#01.
*  MOVE T001-WAERS TO W_/ZAK/AFA_ARANY-WAERS.
  MOVE GS_T001-WAERS TO W_/ZAK/AFA_ARANY-WAERS.
*--S4HANA#01.
  W_/ZAK/AFA_ARANY-LWBAS_NMT = $LWBAS_NMT + LW_AFA_ARANY-LWBAS_NMT.
  W_/ZAK/AFA_ARANY-LWBAS_SUM = $LWBAS_SUM + LW_AFA_ARANY-LWBAS_SUM.

  IF NOT W_/ZAK/AFA_ARANY-LWBAS_SUM IS INITIAL.
    L_ARANY = ( W_/ZAK/AFA_ARANY-LWBAS_NMT / W_/ZAK/AFA_ARANY-LWBAS_SUM )
                * 100.
*++0004 2009.04.20 BG
    IF L_ARANY > 100.
      L_ARANY = 100.
    ENDIF.
*--0004 2009.04.20 BG
*   Normál kerekítés
    IF NOT $R1 IS INITIAL.
      M_ROUND_R1 L_ARANY W_/ZAK/AFA_ARANY-ARANY.
*   Következő egész számra kerekítés
    ELSEIF NOT $R2 IS INITIAL.
      M_ROUND_R2 L_ARANY W_/ZAK/AFA_ARANY-ARANY.
    ENDIF.
*   Adatbázis módosítás
    MODIFY /ZAK/AFA_ARANY FROM W_/ZAK/AFA_ARANY.
*++0003 BG 2009.03.17
*   Ha van rekord létrehozás:
    IF NOT $I_ARANY_FELD[] IS INITIAL.
      MODIFY /ZAK/ARANY_FELD  FROM TABLE $I_ARANY_FELD.
    ENDIF.
    COMMIT WORK AND WAIT.
*--0003 BG 2009.03.17
  ELSE.
    MESSAGE E241.
*   Súlyos hiba az ÁFA arány számításnál!
  ENDIF.


ENDFORM.                    " MOD_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_T001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_T001  USING    $BUKRS.
FORM GET_T001  USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS.
*--S4HANA#01.

*++S4HANA#01.
*  SELECT SINGLE * FROM T001
  SELECT SINGLE * FROM T001 INTO GS_T001
*--S4HANA#01.
                   WHERE BUKRS EQ $BUKRS.
  IF SY-SUBRC NE 0.
    MESSAGE E036 WITH $BUKRS.
*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla)
  ENDIF.

ENDFORM.                                                    " GET_T00
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9100 OUTPUT.

  IF P_TEST IS INITIAL.
    SET TITLEBAR 'MAIN9100'.
  ENDIF.
  SET PF-STATUS 'MAIN9100'.


  IF V_CUSTOM_CONTAINER_9100 IS INITIAL.
*++S4HANA#01.
*    PERFORM CREATE_AND_INIT_ALV_9100 CHANGING I_ALV_ANALITIKA[]
    PERFORM CREATE_AND_INIT_ALV_9100 CHANGING GT_I_ALV_ANALITIKA[]
*--S4HANA#01.
                                      I_FIELDCAT_9100
                                      V_LAYOUT_9100
                                      V_VARIANT_9100.

  ENDIF.

ENDMODULE.                 " STATUS_9100  OUTPUT
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
FORM CREATE_AND_INIT_ALV_9100 CHANGING $I_ALV_ANALITIKA LIKE
*++S4HANA#01.
*                                                   I_ALV_ANALITIKA[]
                                                    GT_I_ALV_ANALITIKA[]
*--S4HANA#01.
                                  $FIELDCAT TYPE LVC_T_FCAT
                                  $LAYOUT   TYPE LVC_S_LAYO
                                  $VARIANT  TYPE DISVARIANT.

  DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER_9100
    EXPORTING
      CONTAINER_NAME = V_CONTAINER_9100.
  CREATE OBJECT V_GRID_9100
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER_9100.

* Mezőkatalógus összeállítása
  PERFORM BUILD_FIELDCAT     USING    SY-DYNNR
                                      '/ZAK/ARANY_ANAL'
                             CHANGING $FIELDCAT.

* Funkciók kizárása
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

  $LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
  $LAYOUT-SEL_MODE = 'A'.


  CLEAR $VARIANT.
* $VARIANT-REPORT = V_REPID.


  CALL METHOD V_GRID_9100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = $VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = 'X'
      IS_LAYOUT            = $LAYOUT
      IT_TOOLBAR_EXCLUDING = LI_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = $FIELDCAT
      IT_OUTTAB            = $I_ALV_ANALITIKA.

*   CREATE OBJECT v_event_receiver.
*   SET HANDLER v_event_receiver->handle_toolbar       FOR v_grid.
*   SET HANDLER v_event_receiver->handle_double_click  FOR v_grid.
*   SET HANDLER v_event_receiver->handle_user_command  FOR v_grid.
*
** raise event TOOLBAR:
*   CALL METHOD v_grid->set_toolbar_interactive.

ENDFORM.                    " create_and_init_alv
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9100 INPUT.

  V_SAVE_OK = V_OK_CODE_9100.
  CLEAR V_OK_CODE_9100.
  CASE V_SAVE_OK.
*   Kilépés
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9100  INPUT
