*&---------------------------------------------------------------------*
*& Report  /ZAK/SZJA_SAP_SEL_CHECK
*&
*&---------------------------------------------------------------------*
*& Program: SAP adatok meghatározása SZJA adóbevalláshoz adatfeltöltés
*& után
*&---------------------------------------------------------------------*
REPORT  /ZAK/SZJA_SAP_SEL_CHECK MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& leválogatja a SAP bizonylatokból azokat az  adatokat, amik az
*& adatfeltöltés után kerültek rögzítésre
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2007.10.24
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
*& 0001   2008.01.21   Balázs G.     Módosított vállalat forgatás
*&                                   beállítása
*& 0002   2008.07.03   Balázs G.     Módosítás /ZAK/SZJA_SAP_SEL
*&                                   főkönyvi szűrés miatt
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/SAP_SEL_F01.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES : BSEG,              "Bizonylatszegmens: könyvelés
         BKPF,              "Bizonylatfej könyveléshez
         BSIS, "Könyvelés: másodlagos index főkönyvi számlákhoz
         /ZAK/SZJA_CUST,     "SZJA lev., könyvelés feladás beállítása
         /ZAK/SZJA_ABEV.     "SZJA lev., ABEV megh.mezőnév alapján




****************************************************************
* LOCAL CLASSES: Definition
****************************************************************
*===============================================================
* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition:
* ~~~~~~~~~~~
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.

*     METHODS:
*      HANDLE_DATA_CHANGED
*         FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*             IMPORTING ER_DATA_CHANGED.

    CLASS-METHODS:



     HANDLE_HOTSPOT_CLICK
        FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
            IMPORTING E_ROW_ID
                      E_COLUMN_ID
                      ES_ROW_NO.



  PRIVATE SECTION.
    DATA: ERROR_IN_DATA TYPE C.
ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class lcl_event_receiver (Implementation)
*
*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.


*---------------------------------------------------------------------*
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
  METHOD HANDLE_HOTSPOT_CLICK.

    IF SY-DYNNR = '9000'.


      PERFORM D900_EVENT_HOTSPOT_CLICK USING E_ROW_ID
                                              E_COLUMN_ID.

    ENDIF.
  ENDMETHOD.                    "hotspot_click
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION

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


DATA W_/ZAK/SZJA_CUST TYPE  /ZAK/SZJA_CUST.
DATA I_/ZAK/SZJA_CUST TYPE STANDARD TABLE OF /ZAK/SZJA_CUST
                                                       INITIAL SIZE 0.

*ABEV meghatározása
DATA W_/ZAK/SZJA_ABEV TYPE  /ZAK/SZJA_ABEV.
DATA I_/ZAK/SZJA_ABEV TYPE STANDARD TABLE OF /ZAK/SZJA_ABEV
                                                       INITIAL SIZE 0.


*BSEG
DATA W_BSEG TYPE  BSEG.
DATA I_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
*BKPF
DATA W_BKPF TYPE  BKPF.
DATA I_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.

DATA I_BKPF_ALV TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.



DATA V_SEL_BUKRS TYPE BUKRS.

DATA V_SUBRC LIKE SY-SUBRC.

RANGES R_BTYPE FOR /ZAK/BEVALL-BTYPE.

DATA V_LAST_RUN_DATUM LIKE SY-DATUM.
DATA V_LAST_RUN_UZEIT LIKE SY-UZEIT.

* ALV kezelési változók
DATA: V_OK_CODE LIKE SY-UCOMM,
      V_SAVE_OK LIKE SY-UCOMM,
      V_CONTAINER   TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CUSTOM_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT   TYPE LVC_T_FCAT,
      V_LAYOUT     TYPE LVC_S_LAYO,
      V_VARIANT    TYPE DISVARIANT,
      V_GRID   TYPE REF TO CL_GUI_ALV_GRID,
      V_EVENT_RECEIVER  TYPE REF TO LCL_EVENT_RECEIVER.

DATA V_REPID LIKE SY-REPID.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

* Vállalat.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-101.
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS
*                          /ZAK/BEVALLSZ-BUKRS
                          VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

SELECTION-SCREEN END OF LINE.

PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT
*                          MODIF ID DIS
                          NO-DISPLAY.
* Bevallás fajta meghatározása
PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                          DEFAULT C_BTYPART_SZJA
                          OBLIGATORY.

* Év
PARAMETERS: P_GJAHR LIKE BKPF-GJAHR DEFAULT SY-DATUM(4)
                                    OBLIGATORY.
* Hónap
PARAMETERS: P_MONAT LIKE BKPF-MONAT DEFAULT SY-DATUM+4(2)
                                    OBLIGATORY.
* Adatszolgáltatás azonosító
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-103.
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                           MATCHCODE OBJECT /ZAK/BEVD
                            OBLIGATORY DEFAULT '004'.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BSZTXT  LIKE /ZAK/BEVALLDT-SZTEXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.
* Bizonylat fajta
SELECT-OPTIONS: S_BLART FOR BKPF-BLART NO INTERVALS.
*                         DEFAULT 'SE' OPTION EQ SIGN E.

SELECT-OPTIONS: S_KBLART FOR BKPF-BLART NO INTERVALS.

SELECTION-SCREEN: END OF BLOCK BL01.

*++0002 BG 2008.07.03
SELECT-OPTIONS S_SAKNR FOR /ZAK/SZJA_CUST-SAKNR NO-DISPLAY.
*--0002 BG 2008.07.03

*&---------------------------------------------------------------------
*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.

  PERFORM S_BLART_INIT.

*++0005 BG 2007.05.08
  PERFORM S_KBLART_INIT.
*--0005 BG 2007.05.08
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
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Vállalat forgatás
  PERFORM ROTATE_BUKRS_OUTPUT USING P_BUKRS
                                    V_SEL_BUKRS.
  IF P_BUKRS NE V_SEL_BUKRS.
    REFRESH I_/ZAK/BEVALL.

    CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
      EXPORTING
        I_BUKRS      = P_BUKRS
        I_BTYPART    = P_BTYPAR
      TABLES
        T_BTYPE      = R_BTYPE
        T_/ZAK/BEVALL = I_/ZAK/BEVALL
      EXCEPTIONS
        ERROR_BTYPE  = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                P_BTYPAR
                                C_ACTVT_03.

  IF R_BTYPE[] IS INITIAL.
    CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
      EXPORTING
        I_BUKRS      = P_BUKRS
        I_BTYPART    = P_BTYPAR
      TABLES
        T_BTYPE      = R_BTYPE
        T_/ZAK/BEVALL = I_/ZAK/BEVALL
      EXCEPTIONS
        ERROR_BTYPE  = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

*  Vállalati adatok beolvasása
  PERFORM GET_T001 USING P_BUKRS
                         V_SUBRC.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE A036 WITH P_BUKRS.
*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla)
  ENDIF.

* Adatok leválogatása
  PERFORM VALOGAT USING V_SUBRC.
  IF V_SUBRC <> 0.
*    nincs a szelekciónak megfelelő adat.
    MESSAGE I031.
    EXIT.
  ENDIF.

* Adatok feldologzása
  PERFORM SOR_SZETRAK.

  IF I_BKPF_ALV[] IS INITIAL.
*    nincs a szelekciónak megfelelő adat.
    MESSAGE I031.
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM LIST_DISPLAY.


*&---------------------------------------------------------------------*
*&      Form  read_additionals
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS.

*  Vállalat megnevezése
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.
  ENDIF.

ENDFORM.                    " read_additionals


*&---------------------------------------------------------------------*
*&      Form  s_blart_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM S_BLART_INIT.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'SE'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'KE'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'SG'     TO S_BLART-LOW.
  APPEND S_BLART.

  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'LB'     TO S_BLART-LOW.
  APPEND S_BLART.

  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'SS'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'M7'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'RM'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'SI'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'E'      TO S_BLART-SIGN,
          'EQ'     TO S_BLART-OPTION,
          'U3'     TO S_BLART-LOW.
  APPEND S_BLART.
  MOVE:   'V3'     TO S_BLART-LOW.    APPEND S_BLART.
  MOVE:   'SN'     TO S_BLART-LOW.    APPEND S_BLART.
  MOVE:   'SU'     TO S_BLART-LOW.    APPEND S_BLART.
  MOVE:   'SV'     TO S_BLART-LOW.    APPEND S_BLART.
  MOVE:   'TE'     TO S_BLART-LOW.    APPEND S_BLART.


ENDFORM.                    " s_blart_init

*&---------------------------------------------------------------------
*
*&      Form  S_KBLART_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM S_KBLART_INIT .

  M_DEF: S_KBLART 'I' 'EQ' 'SA' SPACE,
         S_KBLART 'I' 'EQ' 'SP' SPACE,
         S_KBLART 'I' 'CP' 'E*' SPACE,
         S_KBLART 'I' 'CP' 'F*' SPACE.

ENDFORM.                    " S_KBLART_INIT
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

*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_SEL_BUKRS  text
*----------------------------------------------------------------------*
FORM ROTATE_BUKRS_OUTPUT  USING    $BUKRS
                                   $SEL_BUKRS.

  MOVE $BUKRS TO $SEL_BUKRS.
  CLEAR $BUKRS.

  CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
    EXPORTING
      I_AD_BUKRS    = $SEL_BUKRS
    IMPORTING
      E_FI_BUKRS    = $BUKRS
    EXCEPTIONS
      MISSING_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E231 WITH P_BUKRS.
*   Hiba a & vállalat forgatás meghatározásnál!...
  ENDIF.

ENDFORM.                    " ROTATE_BUKRS_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  valogat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM VALOGAT USING    $SUBRC.
*  Beállítások laválogatása
  PERFORM VALOGAT_BEALLITAS(/ZAK/SZJA_SAP_SEL) TABLES I_/ZAK/SZJA_CUST
                                   R_BTYPE
*++0009 BG 2008.07.03
                                   S_SAKNR
*--0009 BG 2008.07.03
                             USING P_BUKRS
                                   P_BSZNUM
                          CHANGING V_SUBRC.
  $SUBRC = V_SUBRC.
  IF V_SUBRC <> 0.
*    Hiba az SZJA beállítások meghatározásánál!
    MESSAGE E089 WITH '/ZAK/SZJA_CUST_V'.
  ENDIF.

*  /ZAK/SZJA_ABEV leválogatása a WL könyveléshez
*++0002 BG 2006/10/26
  PERFORM VALOGAT_ABEV_MEZOK(/ZAK/SZJA_SAP_SEL) TABLES R_BTYPE
                              USING  P_BUKRS
                                     'WL'
                           CHANGING  W_/ZAK/SZJA_ABEV
                                     V_SUBRC.
*--0002 BG 2006/10/26
  IF V_SUBRC <> 0.
*    Hiba az ABEV - MEZŐ meghatározásánál!
    MESSAGE E089 WITH '/ZAK/SZJA_ABEV_V'.
  ENDIF.

*   /ZAK/BEVALL leválogatása

* Könyvelési rekordok leválogatása
  PERFORM SZJA_ADATOK_LEVAL TABLES I_/ZAK/SZJA_CUST
                                   I_BSEG
                                   I_BKPF
                             USING P_BUKRS
                                   P_GJAHR
                                   P_BSZNUM
                                   V_SEL_BUKRS
                          CHANGING $SUBRC.

  IF NOT $SUBRC IS INITIAL.
    EXIT.
  ENDIF.

* Meghatározzuk az utolsó letöltés időpontját.
  SELECT * INTO /ZAK/BEVALLSZ
           UP TO 1 ROWS
           FROM /ZAK/BEVALLSZ
          WHERE BUKRS EQ V_SEL_BUKRS
            AND BTYPE IN R_BTYPE
            AND BSZNUM EQ P_BSZNUM
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            ORDER BY PACK DESCENDING.
  ENDSELECT.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE DATUM UZEIT INTO (V_LAST_RUN_DATUM,
                                    V_LAST_RUN_UZEIT)
                              FROM /ZAK/BEVALLP
                             WHERE BUKRS EQ /ZAK/BEVALLSZ-BUKRS
                               AND PACK  EQ /ZAK/BEVALLSZ-PACK.
  ENDIF.


ENDFORM.                    " valogat
*&---------------------------------------------------------------------*
*&      Form  SOR_SZETRAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM SOR_SZETRAK.


*  végiglohol a beállítás sorokon
*  Azért ezen, mert eredetileg is ez alapján lettek leválogatva a
*  tételek és nem mindíg egyértelmű a BSEG-ből a /zak/szja_cust rekord
*  viss/zak/zakeresése.
  RANGES: L_R_AUFNR FOR BSEG-AUFNR.
  DATA: L_SZAMLA_BELNR(10).
  DATA: L_BEVHO(6).
  DATA L_SUBRC LIKE SY-SUBRC.

  DATA L_LAST_RUN_TIME(14).
  DATA L_BKPF_TIME(14).


  CONCATENATE V_LAST_RUN_DATUM V_LAST_RUN_UZEIT INTO L_LAST_RUN_TIME.


  LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

    CLEAR W_/ZAK/BEVALL.
    READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY
                                 BUKRS = W_/ZAK/SZJA_CUST-BUKRS
                                 BTYPE = W_/ZAK/SZJA_CUST-BTYPE.
    IF SY-SUBRC NE 0.
      MESSAGE E114.
*      Bevallás típus meghatározás hiba!
    ENDIF.
*Ki kell hagyni, ami nem a könyvelés időszakához tartozó bevallás
*beállítás
    CONCATENATE P_GJAHR P_MONAT INTO L_BEVHO.
    IF W_/ZAK/BEVALL-DATBI(6) >= L_BEVHO AND W_/ZAK/BEVALL-DATAB(6) <=
    L_BEVHO.
    ELSE.
      CONTINUE.
    ENDIF.

*    A rendelésből szelekciót csinál
    PERFORM AUFNR_FELTOLT TABLES L_R_AUFNR
                          USING W_/ZAK/SZJA_CUST-AUFNR.

    LOOP AT I_BSEG INTO W_BSEG
                  WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                    AND AUFNR IN  L_R_AUFNR.

*      rákeres a fej adatra
      READ TABLE I_BKPF INTO W_BKPF
                         WITH KEY BUKRS = W_BSEG-BUKRS
                                  BELNR = W_BSEG-BELNR
                                  GJAHR = W_BSEG-GJAHR.
*     Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor
      IF NOT W_/ZAK/SZJA_CUST-ABEVAZ IS INITIAL.
        CONCATENATE W_BKPF-CPUDT W_BKPF-CPUTM INTO L_BKPF_TIME.
*       Ha a rögzítés dátuma későbbi a letöltésnél, akkor kell a rekord:
        IF L_BKPF_TIME > L_LAST_RUN_TIME.
          READ TABLE I_BKPF_ALV TRANSPORTING NO FIELDS
                    WITH KEY BUKRS = W_BKPF-BUKRS
                             BELNR = W_BKPF-BELNR
                             GJAHR = W_BKPF-GJAHR
                             BINARY SEARCH.
          IF SY-SUBRC NE 0.
            APPEND W_BKPF TO I_BKPF_ALV.
            SORT I_BKPF_ALV.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " SOR_SZETRAK

*&      Form  szja_adatok_leval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM SZJA_ADATOK_LEVAL TABLES $/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                              $I_BSEG          STRUCTURE BSEG
                              $I_BKPF          STRUCTURE BKPF
                        USING $BUKRS
                              $GJAHR
*                              $BTYPE
                              $BSZNUM
*++0006 2007.10.08  BG (FMC)
                              $SEL_BUKRS
*--0006 2007.10.08  BG (FMC)
                     CHANGING $SUBRC.
*  átmeneti táblák a leválogatáshoz.
  DATA LI_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
  DATA LI_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA LW_BSIS TYPE  BSIS.
  DATA LI_BSIS TYPE STANDARD TABLE OF BSIS INITIAL SIZE 0.
*++0006 2007.10.08  BG (FMC)
  DATA L_BUKRS TYPE  BUKRS.
*--0006 2007.10.08  BG (FMC)



*  a paraméter tábla alapján BSEG leválogatása
  LOOP AT $/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

    REFRESH: LI_BSEG, LI_BKPF, LI_BSIS.

    PERFORM GET_BSIS TABLES LI_BSIS
                    USING  $BUKRS
                           $GJAHR
                           P_MONAT
                           W_/ZAK/SZJA_CUST-/ZAK/EVES
                           W_/ZAK/SZJA_CUST-AUFNR
                           W_/ZAK/SZJA_CUST-SAKNR
                  CHANGING L_SUBRC.
    IF L_SUBRC <> 0.
*      nincs a feltételnek megfelelő adat, jöhet a következő
      CONTINUE.
    ENDIF.

*    ellenőrzés WL
    PERFORM TETEL_WL_SZURES TABLES LI_BSIS
                             USING L_SUBRC.

**    leválogatja a BSEG rekordokat
    PERFORM BSEG_KER TABLES LI_BSIS
                            LI_BSEG
                  CHANGING L_SUBRC.
    IF L_SUBRC <> 0.
*      nincs a feltételnek megfelelő adat, jöhet a következő
      CONTINUE.
    ENDIF.
*    Fej BKPF adatok a BSEG ellenőrzéséhez.
*     REFRESH LI_BKPF.
    PERFORM BKPF_KER TABLES LI_BSIS
                            LI_BKPF
                     USING  L_SUBRC.
    IF L_SUBRC <> 0.
*      nincs  FEJ adat, nem kell a tétel sem
      CONTINUE.
    ENDIF.
*    Ha minden rendben,akkor elteszem az adatokat
    PERFORM FEJ_ATVESZ   TABLES LI_BKPF
                                $I_BKPF.
    PERFORM TETEL_ATVESZ TABLES LI_BSEG
                                $I_BSEG.


  ENDLOOP.
  IF $I_BSEG[] IS INITIAL.
*    nincs megfelelő BSEG tétel
    $SUBRC = 4.
*++0002 BG 2006/10/26
  ELSE.
*  Duplikált rekordok törlése
    SORT $I_BKPF.
    SORT $I_BSEG.
    DELETE ADJACENT DUPLICATES FROM $I_BKPF COMPARING BUKRS BELNR GJAHR
    .
    DELETE ADJACENT DUPLICATES FROM $I_BSEG COMPARING BUKRS BELNR GJAHR
                                                                  BUZEI
                                                                  .
*--0002 BG 2006/10/26
  ENDIF.

*++0006 2007.10.08  BG (FMC)
*  BSEG rekordok szűrése forgatott vállalatkódra
  LOOP AT $I_BSEG INTO W_BSEG.
    READ TABLE $I_BKPF INTO W_BKPF
                   WITH KEY BUKRS = W_BSEG-BUKRS
                            BELNR = W_BSEG-BELNR
                            GJAHR = W_BSEG-GJAHR.

    IF SY-SUBRC EQ 0.
      PERFORM ROTATE_BUKRS_INPUT USING W_BSEG
                                       W_BKPF
                              CHANGING L_BUKRS.
      IF L_BUKRS NE $SEL_BUKRS.
        DELETE $I_BSEG.
      ENDIF.
    ENDIF.
  ENDLOOP.
*--0006 2007.10.08  BG (FMC)

ENDFORM.                    " szja_adatok_leval


*&---------------------------------------------------------------------*
*&      Form  get_bsis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSEG  text
*      -->P_$BUKRS  text
*      -->P_$GJAHR  text
*      -->P_W_/ZAK/SZJA_CUST_AUFNR  text
*      -->P_W_/ZAK/SZJA_CUST_SAKNR  text
*      <--P_L_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_BSIS TABLES    $I_BSIS STRUCTURE BSIS
               USING    $BUKRS
                        $GJAHR
                        $MONAT
                        $/ZAK/EVES
                        $AUFNR
                        $HKONT
               CHANGING $SUBRC.
  DATA LW_BSIS TYPE  BSIS.
  RANGES: LR_AUFNR FOR BSEG-AUFNR.
  RANGES  R_MONAT FOR BKPF-MONAT.

  CLEAR LR_AUFNR.
  REFRESH LR_AUFNR.

*  A rendelésből feltételt csinál a szelekcióhoz
  IF NOT $AUFNR IS INITIAL.
    LR_AUFNR = 'IEQ'.
    LR_AUFNR-LOW = $AUFNR.
    APPEND  LR_AUFNR.
  ENDIF.
*  IDŐSZAK meghatározása
  CLEAR R_MONAT.
  REFRESH R_MONAT.
* --Ez volt az eredeti
*  Az időszakból feltételt csinál a szelekcióhoz
*  Vagy nem 12 a periódus, vagy /ZAK/EVES <> ' '
*  Ha mindkét feltétel HAMIS, akkor nem kell figyelni a periódust
  IF $MONAT <> '12' OR $/ZAK/EVES IS INITIAL.
    R_MONAT = 'IEQ'.
    R_MONAT-LOW = $MONAT.
    APPEND R_MONAT.
  ELSE.
    R_MONAT = 'IBT'.
    R_MONAT-LOW  = '01'.
    R_MONAT-HIGH = '12'.
    APPEND R_MONAT.
  ENDIF.
  SELECT * INTO TABLE $I_BSIS
           FROM BSIS
           WHERE BUKRS = $BUKRS
             AND HKONT = $HKONT
             AND GJAHR = $GJAHR
             AND BLART IN S_BLART
             AND MONAT IN R_MONAT
             AND AUFNR IN LR_AUFNR.
  $SUBRC = SY-SUBRC.


ENDFORM.                    " get_bsis


*&---------------------------------------------------------------------*
*&      Form  bseg_ker
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_GJAHR  text
*      -->P_AUFNR  text
*      -->P_HKONT  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM BSEG_KER TABLES   $I_BSIS STRUCTURE BSIS
                       $I_BSEG STRUCTURE BSEG
              CHANGING $SUBRC.
*    Leválogatom a lehetséges rekordokat.
*++S4HANA#01.
*  SELECT  * INTO TABLE $I_BSEG
  SELECT  * INTO TABLE $I_BSEG     "#EC CI_DB_OPERATION_OK[2431747]
*--S4HANA#01.
            FROM BSEG
            FOR ALL ENTRIES IN $I_BSIS
            WHERE BUKRS = $I_BSIS-BUKRS
              AND GJAHR = $I_BSIS-GJAHR
              AND BELNR = $I_BSIS-BELNR
              AND BUZEI = $I_BSIS-BUZEI.

  $SUBRC = SY-SUBRC.

ENDFORM.                    " bseg_ker

*&---------------------------------------------------------------------*
*&      Form  bkpf_ker
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM BKPF_KER  TABLES  $I_BSIS   STRUCTURE BSIS
                       $I_BKPF   STRUCTURE BKPF

               USING   $SUBRC.

  SELECT * INTO TABLE $I_BKPF
           FROM BKPF
           FOR ALL ENTRIES IN $I_BSIS
           WHERE BUKRS = $I_BSIS-BUKRS
             AND BELNR = $I_BSIS-BELNR
             AND GJAHR = $I_BSIS-GJAHR.
*++BG 2006/08/11
*A program leválogatott nem HUF-os tételeket is amit
*az analitikában rosszul kezelt mert a tételekből a
*DMBTR (saját pénznem) mezőből számolt a pénznemhez
*viszont a BKPF-WAERS (pld. EUR) értéket írta.
*Ezért a BKPF_WAERS-be mindig a vállalat T001-WAERS-et
*írjuk be!
  IF SY-SUBRC NE 0.
    $SUBRC = SY-SUBRC.
  ELSE.
    LOOP AT $I_BKPF.
      SELECT SINGLE WAERS INTO $I_BKPF-WAERS
                          FROM T001
                         WHERE BUKRS = $I_BKPF-BUKRS.
      MODIFY $I_BKPF TRANSPORTING WAERS.
    ENDLOOP.
  ENDIF.
*--BG 2006/08/11

ENDFORM.                    " bkpf_ker


*&---------------------------------------------------------------------*
*&      Form  fej_atvesz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_bkpf  text
*      -->P_I_bkpf  text
*----------------------------------------------------------------------*
FORM FEJ_ATVESZ TABLES   $LI_BKPF STRUCTURE BKPF
                         $I_BKPF  STRUCTURE BKPF.

  APPEND LINES OF $LI_BKPF TO $I_BKPF.

ENDFORM.                    " fej_atvesz

*&---------------------------------------------------------------------*
*&      Form  tetel_atvesz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSEG  text
*      -->P_I_BSEG  text
*----------------------------------------------------------------------*
FORM TETEL_ATVESZ TABLES   $LI_BSEG STRUCTURE BSEG
                         $I_BSEG  STRUCTURE BSEG.
  APPEND LINES OF $LI_BSEG TO $I_BSEG.

ENDFORM.                    " fej_atvesz

*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BSEG  text
*      -->P_W_BKPF  text
*      <--P_L_BUKRS  text
*----------------------------------------------------------------------*
FORM ROTATE_BUKRS_INPUT  USING    $BSEG STRUCTURE BSEG
                                  $BKPF STRUCTURE BKPF
                         CHANGING $BUKRS.

*++0001 2008.01.21 BG (FMC)
  DATA L_BUKRS TYPE BUKRS.

  MOVE $BSEG-XREF1+8(4) TO L_BUKRS.
*--0001 2008.01.21 BG (FMC)

  CALL FUNCTION '/ZAK/ROTATE_BUKRS_INPUT'
    EXPORTING
      I_FI_BUKRS    = $BSEG-BUKRS
*++0001 2008.01.21 BG (FMC)
      I_AD_BUKRS    = L_BUKRS
*--0001 2008.01.21 BG (FMC)
      I_DATE        = $BKPF-BLDAT
*++0001 2008.01.21 BG (FMC)
*      I_GSBER       = $BSEG-GSBER
*      I_PRCTR       = $BSEG-PRCTR
*--0001 2008.01.21 BG (FMC)
    IMPORTING
      E_AD_BUKRS    = $BUKRS
    EXCEPTIONS
      MISSING_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E232 WITH $BSEG-BUKRS.
*        Hiba a & vállalat forgatás meghatározásnál!
  ENDIF.

ENDFORM.                    " ROTATE_BUKRS_INPUT

*&---------------------------------------------------------------------*
*&      Form  tetel_WL_szures
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSIS  text
*      -->P_L_SUBRC  text
*----------------------------------------------------------------------*
FORM TETEL_WL_SZURES TABLES   $BSIS STRUCTURE BSIS
                     USING    $SUBRC.
  DATA LW_BSIS TYPE  BSIS.

  LOOP AT  $BSIS INTO LW_BSIS.
    IF LW_BSIS-ZUONR(2) = 'WL'.
      DELETE $BSIS.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " tetel_WL_szures
*&---------------------------------------------------------------------
*
*&      Form  aufnr_feltolt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LR_AUFNR  text
*      -->P_W_/ZAK/SZJA_CUST_AUFNR  text
*----------------------------------------------------------------------*
FORM AUFNR_FELTOLT TABLES   $R_AUFNR STRUCTURE R_AUFNR
                   USING    $AUFNR.
  CLEAR $R_AUFNR. REFRESH $R_AUFNR.
*    A rendelésből feltételt csinál a szelekcióhoz
  IF NOT $AUFNR IS INITIAL.
    $R_AUFNR = 'IEQ'.
    $R_AUFNR-LOW = $AUFNR.
    APPEND  $R_AUFNR.
  ENDIF.

ENDFORM.                    " aufnr_feltolt
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .
  SORT I_BKPF_ALV.
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
    PERFORM CREATE_AND_INIT_ALV CHANGING I_BKPF_ALV[]
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
FORM SET_STATUS .

  SET PF-STATUS 'MAIN9000'.
  SET TITLEBAR  'MAIN9000'.



ENDFORM.                    " SET_STATUS

*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/ANALITIKA[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING $I_BKPF_ALV LIKE I_BKPF_ALV[]
                                  $FIELDCAT TYPE LVC_T_FCAT
                                  $LAYOUT   TYPE LVC_S_LAYO
                                  $VARIANT  TYPE DISVARIANT.

  DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
         EXPORTING CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
         EXPORTING I_PARENT = V_CUSTOM_CONTAINER.


  MOVE SY-REPID TO V_REPID.

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
      IT_OUTTAB            = $I_BKPF_ALV.

  CREATE OBJECT V_EVENT_RECEIVER.
  SET HANDLER V_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK  FOR V_GRID.

ENDFORM.                    " create_and_init_alv


*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_DYNNR  text
*      <--P_$FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT USING    $DYNNR    LIKE SYST-DYNNR
                    CHANGING $FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.


  IF $DYNNR = '9000'.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = 'BKPF'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = $FIELDCAT.

    LOOP AT $FIELDCAT INTO S_FCAT.
      IF S_FCAT-FIELDNAME = 'BELNR'.
        S_FCAT-HOTSPOT = 'X'.
      ENDIF.
      MODIFY $FIELDCAT FROM S_FCAT.
    ENDLOOP.
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
    WHEN 'BACK'.
      PERFORM EXIT_PROGRAM.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
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
FORM EXIT_PROGRAM.
  LEAVE TO SCREEN 0 .
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  D900_EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM D900_EVENT_HOTSPOT_CLICK USING    E_ROW_ID TYPE LVC_S_ROW
                                       E_COLUMN_ID  TYPE LVC_S_COL.
  DATA: LW_BKPF   TYPE BKPF.

  READ TABLE I_BKPF_ALV INTO LW_BKPF INDEX E_ROW_ID.
  IF SY-SUBRC = 0.

    CASE E_COLUMN_ID.
      WHEN 'BELNR'.

        IF NOT LW_BKPF-BUKRS IS INITIAL AND
           NOT LW_BKPF-GJAHR IS INITIAL AND
           NOT LW_BKPF-BELNR IS INITIAL.

          SET PARAMETER ID 'BUK' FIELD LW_BKPF-BUKRS.
          SET PARAMETER ID 'GJR' FIELD LW_BKPF-GJAHR.
          SET PARAMETER ID 'BLN' FIELD LW_BKPF-BELNR.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    " D900_EVENT_HOTSPOT_CLICK
