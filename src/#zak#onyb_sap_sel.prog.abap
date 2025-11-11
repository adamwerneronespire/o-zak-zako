*&---------------------------------------------------------------------*
*& Report  /ZAK/ONYB_SAP_SEL
*&
*&---------------------------------------------------------------------*
*&Program: SAP adatok meghatározása összesítő jelentéshez
*&---------------------------------------------------------------------*

REPORT  /ZAK/ONYB_SAP_SEL  MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& leválogatja a SAP-ZMT_ADO24_OJ_ANA táblából a szelekcióban
*& meghatározott adatokat és a /ZAK/ANALITIKA-ba tárolja.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2007.04.04
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    -----------------------------------
*& 0001   2007.05.22   Balázs G.     MA01 váll. fordítása MMOB-ra
*& 0002   2007.10.08   Balázs G.     Vállalat forgatás
*& 0003   2008.01.21   Balázs G.     Vállalat forgatás átalakítás
*& 0004   2008.04.04   Balázs G.     Szelekció átalakítás ANALITIKA
*&                                   alapján
*& 0005   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra
*&                                   ellenőrzés visszaállítása
*& 0006   2010/01/27   Balázs G.     10A60 miatt NYLAPAZON meghatározás
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/SAP_SEL_F01.


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
*DATA I_ZMT_AD024 TYPE STANDARD TABLE OF ZMT_AD024_OJ_ANA INITIAL SIZE 0.
*DATA W_ZMT_AD024 TYPE ZMT_AD024_OJ_ANA.

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
*Könyvelési dátum range:
*RANGES R_ADODAT FOR ZMT_AD024_OJ_ANA-BUDAT.

DATA V_SUBRC LIKE SY-SUBRC.

DATA V_REPID LIKE SY-REPID.

* ALV kezelési változók
DATA: V_OK_CODE LIKE SY-UCOMM,
      V_SAVE_OK LIKE SY-UCOMM,
      V_CONTAINER   TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT   TYPE LVC_T_FCAT,
      V_LAYOUT     TYPE LVC_S_LAYO,
      V_VARIANT    TYPE DISVARIANT,
      V_GRID   TYPE REF TO CL_GUI_ALV_GRID.

*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

*++0002 2007.10.08  BG (FMC)
DATA V_BUKRS TYPE BUKRS.
*--0002 2007.10.08  BG (FMC)
*++0004 2008.04.04  BG (FMC)
DATA I_/ZAK/ANALITIKA_SEL TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
DATA W_/ZAK/ANALITIKA_SEL TYPE /ZAK/ANALITIKA.
*--0004 2008.04.04  BG (FMC)

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*Vállalat.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-101.
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.
*Bevallás típus.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-102.
PARAMETERS:  P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                                      DEFAULT C_BTYPART_ONYB
                                              OBLIGATORY
                                      MODIF ID DIS.
SELECTION-SCREEN END OF LINE.
* Adatszolgáltatás azonosító
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BSZNUM_SH
                          OBLIGATORY.
ENHANCEMENT-POINT /ZAK/ONYB_TELENOR_SEL SPOTS /ZAK/ONYB_TELENOR STATIC .

*Teszt futás
PARAMETERS P_TESZT AS CHECKBOX DEFAULT 'X' .
SELECTION-SCREEN: END OF BLOCK BL01.

*++BG 2007.09.10 Törölve mert már nem kell
*SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
**Év
*PARAMETERS P_GJAHR TYPE GJAHR DEFAULT SY-DATUM(4) OBLIGATORY.
**Hónap
*PARAMETERS P_MONAT TYPE MONAT OBLIGATORY.
*SELECTION-SCREEN: END OF BLOCK BL02.
*--BG 2007.09.10

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.

*  MOVE '03' TO P_MONAT.

  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.
*++1765 #19.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2365 #02.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/ONYB_SAP_SEL'.
*--2365 #02.
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
* Képernyő attribútomok beállítása
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
*++BG 2007.09.10
** Hónap ellenőrzése
*  PERFORM GET_MONAT_VERIFY.
** BSZNUM ellenőrzése
*  PERFORM VERIFY_BSZNUM USING P_BUKRS
*                              P_BTYPAR
*                              P_GJAHR
*                              P_MONAT
*                              P_BSZNUM
*                              SY-REPID
*                              V_SUBRC.
*--BG 2007.09.10
*++0005 BG 2008/09/12
*  IF NOT V_SUBRC IS INITIAL.
*    MESSAGE E029 WITH P_BSZNUM.
**   Ez a program a  & adatszolgáltatáshoz nem használható!
*  ENDIF.
  MOVE SY-REPID TO V_REPID.
  PERFORM VER_BSZNUM   USING P_BUKRS
                             P_BTYPAR
                             P_BSZNUM
                             V_REPID
                    CHANGING V_SUBRC.
*--0005 BG 2008/09/12
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*++2265 #09.
   PERFORM LOCK_PROGRAM USING P_TESZT.
*--2265 #09.
*++0004 2008.04.04  BG (FMC)
* Nem kell forgatás mivel már a forgatott adatokból dolgozunk
  MOVE P_BUKRS TO V_BUKRS.
**++0002 2007.10.08  BG (FMC)
**  Vállalat forgatás
*  PERFORM ROTATE_BUKRS_OUTPUT USING P_BUKRS
*                                    V_BUKRS.
**--0002 2007.10.08  BG (FMC)
*--0004 2008.04.04  BG (FMC)

* Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING
*++0002 2007.10.08  BG (FMC)
*                               P_BUKRS
                                V_BUKRS
*--0002 2007.10.08  BG (FMC)
                                P_BTYPAR
                                C_ACTVT_01.

*  Vállalati adatok beolvasása
  PERFORM GET_T001 USING
*++0002 2007.10.08  BG (FMC)
*                        P_BUKRS
                         V_BUKRS
*--0002 2007.10.08  BG (FMC)
                         V_SUBRC.

  IF NOT V_SUBRC IS INITIAL.
*++0002 2007.10.08  BG (FMC)
*   MESSAGE A036 WITH P_BUKRS.
    MESSAGE A036 WITH V_BUKRS.
*--0002 2007.10.08  BG (FMC)
*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla)
  ENDIF.

*++0004 2008.04.04  BG (FMC)
** Adatszelekció ZMT_AD024_OJ_ANA táblából
*  PERFORM GET_DATA_SEL USING V_SUBRC.

* Meghatározzuk az ABEV azonosítókat
  PERFORM GET_ONYB_ABEV TABLES I_ONYB_ABEV.
  IF I_ONYB_ABEV[] IS INITIAL.
    MESSAGE E268.
*   Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei!
  ENDIF.

* Adatszelekció ANALITIKA alapján
  PERFORM GET_DATA_SEL_ANALITIKA TABLES I_/ZAK/ANALITIKA_SEL
                                        I_/ZAK/ANALITIKA
                                        I_ONYB_ABEV
                                 USING  V_BUKRS
*++1565 #03.
                                        P_BSZNUM
*--1565 #03.
                                        V_SUBRC.
*--0004 2008.04.04  BG (FMC)

  IF NOT V_SUBRC IS INITIAL.
    MESSAGE I031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.



* Teszt vagy éles futás, adatbázis módosítás, stb.
  PERFORM INS_DATA USING P_TESZT.
*++2265 #09.
  PERFORM UNLOCK_PROGRAM USING P_TESZT.
*--2265 #09.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*  Háttérben nem készítünk listát.
  IF SY-BATCH IS INITIAL.
    PERFORM LIST_DISPLAY.
  ENDIF.

************************************************************************
*                         ALPROGRAMOK
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
*     SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  READ_ADDITIONALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS .

* Vállalat megnevezése
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.
  ENDIF.

ENDFORM.                    " READ_ADDITIONALS
*++BG 2007.09.10
**&---------------------------------------------------------------------
**
**&      Form  GET_MONAT_VERIFY
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------
**
*FORM GET_MONAT_VERIFY .
*
*  DATA L_DATUM    LIKE SY-DATUM.
*  DATA L_DATUM_TO LIKE SY-DATUM.
*  DATA L_MONAT TYPE MONAT.
*
*  REFRESH R_ADODAT.
*
**Ellenőrizzük létezik-e bevallás
*  CONCATENATE P_GJAHR P_MONAT '01' INTO L_DATUM.
*
*  SELECT * INTO W_/ZAK/BEVALL
*           UP TO 1 ROWS
*           FROM /ZAK/BEVALL
*          WHERE BUKRS EQ P_BUKRS
*            AND DATBI GE L_DATUM
*            AND DATAB LE L_DATUM
*            AND BTYPART EQ P_BTYPAR.
*  ENDSELECT.
*  IF SY-SUBRC NE 0.
*    MESSAGE E126 WITH P_BUKRS P_BTYPAR L_DATUM.
**   & vállalatban & fajtához & napon érvényes bevallástípus nem létezik
*  ELSE.
*    CASE W_/ZAK/BEVALL-BIDOSZ.
**     Éves
*      WHEN 'E'.
*        IF P_MONAT NE '12'.
*          MESSAGE I064 WITH W_/ZAK/BEVALL-BTYPE P_BUKRS '12'.
**         & bevallás & vállalatban éves, helyes periódus &.
*          P_MONAT = '12'.
*        ENDIF.
*        CONCATENATE P_GJAHR '0101' INTO L_DATUM.
*        CONCATENATE P_GJAHR P_MONAT '31' INTO L_DATUM_TO.
*        M_DEF R_ADODAT 'I' 'BT' L_DATUM L_DATUM_TO.
**     Negyedéves
*      WHEN 'N'.
*        IF P_MONAT NE '03' AND P_MONAT NE '06' AND P_MONAT NE '09' AND
*           P_MONAT NE '12'.
*          MESSAGE E063 WITH W_/ZAK/BEVALL-BTYPE P_BUKRS TEXT-000.
**          & bevallás & vállalatban negyedéves, helyes periódus &.
*        ENDIF.
*        L_MONAT = P_MONAT - 2.
*        CONCATENATE P_GJAHR L_MONAT '01' INTO L_DATUM.
*        CONCATENATE P_GJAHR P_MONAT '01' INTO L_DATUM_TO.
*        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*          EXPORTING
*            DAY_IN            = L_DATUM_TO
*          IMPORTING
*            LAST_DAY_OF_MONTH = L_DATUM_TO
*          EXCEPTIONS
*            DAY_IN_NO_DATE    = 1
*            OTHERS            = 2.
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ELSE.
*          M_DEF R_ADODAT 'I' 'BT' L_DATUM L_DATUM_TO.
*        ENDIF.
**     Havi
*      WHEN 'H'.
*        IF NOT P_MONAT BETWEEN '01' AND '12'.
*          MESSAGE E213.
**       Kérem a hónapot 01 és 12 között adja meg'
*        ENDIF.
*        CONCATENATE P_GJAHR P_MONAT '01' INTO L_DATUM.
*        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*          EXPORTING
*            DAY_IN            = L_DATUM
*          IMPORTING
*            LAST_DAY_OF_MONTH = L_DATUM_TO
*          EXCEPTIONS
*            DAY_IN_NO_DATE    = 1
*            OTHERS            = 2.
*        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*        ELSE.
*          M_DEF R_ADODAT 'I' 'BT' L_DATUM L_DATUM_TO.
*        ENDIF.
*    ENDCASE.
*  ENDIF.
*
*ENDFORM.                    " GET_MONAT_VERIFY
*--BG 2007.09.10
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_SEL USING $SUBRC.

  DATA LW_BKPF TYPE BKPF.

  DATA LW_BSEG TYPE BSEG.
  DATA LI_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.

*++0002 2007.10.08  BG (FMC)
**++0001 BG 2007.05.22
  DATA L_BUKRS TYPE BUKRS.
*
*  IF P_BUKRS EQ 'MMOB'.
*    MOVE 'MA01' TO L_BUKRS.
*  ELSE.
*    MOVE P_BUKRS TO L_BUKRS.
*  ENDIF.
**--0001 BG 2007.05.22
  MOVE V_BUKRS TO L_BUKRS.
*--0002 2007.10.08  BG (FMC)


*  REFRESH I_ZMT_AD024.

*  SELECT * INTO TABLE I_ZMT_AD024
*           FROM ZMT_AD024_OJ_ANA
*          WHERE BUKRS EQ P_BUKRS
*            AND BUDAT IN R_ADODAT
*            AND ONREV EQ 'N'.
*  SELECT * INTO TABLE I_ZMT_AD024
*           FROM ZMT_AD024_OJ_ANA
*++0001 BG 2007.05.22
*         WHERE BUKRS  EQ P_BUKRS
*          WHERE BUKRS  EQ L_BUKRS
*--0001 BG 2007.05.22
*++BG 2007.09.10
*           AND ADODAT IN R_ADODAT
*--BG 2007.09.10
*            AND FELDO  EQ ''.

  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
    EXIT.
  ENDIF.

* Adatok feldolgozása
*  LOOP AT I_ZMT_AD024 INTO W_ZMT_AD024.
*    CLEAR: W_/ZAK/ANALITIKA, LW_BKPF, LW_BSEG.
*    FREE LI_BSEG[].
*
**   BKPF beolvasása
*    SELECT SINGLE * INTO LW_BKPF
*                    FROM BKPF
*                   WHERE BUKRS EQ W_ZMT_AD024-BUKRS
*                     AND BELNR EQ W_ZMT_AD024-BELNR
*                     AND GJAHR EQ W_ZMT_AD024-GJAHR.
**   BSEG beolvasása
*    SELECT * INTO TABLE LI_BSEG
*             FROM BSEG
*            WHERE BUKRS EQ W_ZMT_AD024-BUKRS
*              AND BELNR EQ W_ZMT_AD024-BELNR
*              AND GJAHR EQ W_ZMT_AD024-GJAHR.
*
**   Most már talán minden megvan lehet mappelni.
**   Vállalat
*    MOVE W_ZMT_AD024-BUKRS TO W_/ZAK/ANALITIKA-BUKRS.
**   FI Vállalat
*    MOVE W_ZMT_AD024-BUKRS TO W_/ZAK/ANALITIKA-FI_BUKRS.
**   Gazdasági év
*    MOVE W_ZMT_AD024-ADODAT(4) TO W_/ZAK/ANALITIKA-GJAHR.
**   Hónap
*    MOVE W_ZMT_AD024-ADODAT+4(2) TO W_/ZAK/ANALITIKA-MONAT.
**   ABEV azonosító
*    MOVE C_ABEVAZ_DUMMY TO W_/ZAK/ANALITIKA-ABEVAZ.
**   Adóazonosító
*    MOVE W_ZMT_AD024-STCEG TO W_/ZAK/ANALITIKA-ADOAZON.
*    MOVE W_ZMT_AD024-STCEG TO W_/ZAK/ANALITIKA-STCEG.
**   Adatszolgáltatás azonosító
*    MOVE P_BSZNUM TO W_/ZAK/ANALITIKA-BSZNUM.
**   Tétel
*    MOVE SY-TABIX TO W_/ZAK/ANALITIKA-ITEM.
**   Dinamikus lapszám
*    MOVE 1 TO W_/ZAK/ANALITIKA-LAPSZ.
**   Összeg saját pénznemben előjellel
*    MOVE W_ZMT_AD024-DMSHB TO W_/ZAK/ANALITIKA-DMBTR.
*    MOVE W_ZMT_AD024-DMSHB TO W_/ZAK/ANALITIKA-FIELD_N.
**   Pénznemkulcs
*    MOVE W_ZMT_AD024-WAERS TO W_/ZAK/ANALITIKA-WAERS.
*    MOVE LW_BKPF-WAERS TO W_/ZAK/ANALITIKA-FWAERS.
**   Forgalmi adó kódja
*    MOVE W_ZMT_AD024-MWSKZ TO W_/ZAK/ANALITIKA-MWSKZ.
**   Adódátum
*    MOVE W_ZMT_AD024-ADODAT TO W_/ZAK/ANALITIKA-ADODAT.
**   Gazdasági év (bizonylat)
*    MOVE W_ZMT_AD024-GJAHR TO W_/ZAK/ANALITIKA-BSEG_GJAHR.
**   Könyvelési bizonylat bizonylatszáma
*    MOVE W_ZMT_AD024-BELNR TO W_/ZAK/ANALITIKA-BSEG_BELNR.
**   Könyvelési sor száma könyvelési bizonylaton belül
*    MOVE W_ZMT_AD024-BUZEI TO W_/ZAK/ANALITIKA-BSEG_BUZEI.
**   Számlatípus
*    MOVE W_ZMT_AD024-KOART TO W_/ZAK/ANALITIKA-KOART.
**   Bizonylatdátum a bizonylaton
*    MOVE W_ZMT_AD024-BLDAT TO W_/ZAK/ANALITIKA-BLDAT.
**   Könyvelési dátum a bizonylaton
*    MOVE W_ZMT_AD024-BUDAT TO W_/ZAK/ANALITIKA-BUDAT.
**   Bizonylatfajta
*    MOVE LW_BKPF-BLART TO W_/ZAK/ANALITIKA-BLART.
**   Referenciabizonylat száma
*    MOVE LW_BKPF-XBLNR TO W_/ZAK/ANALITIKA-XBLNR.
**++0001 BG 2007.05.22
**   Meghatározzuk a tételhez tartozó üzletágat
*    READ TABLE LI_BSEG INTO LW_BSEG
*                   WITH KEY BUKRS = W_ZMT_AD024-BUKRS
*                            BELNR = W_ZMT_AD024-BELNR
*                            GJAHR = W_ZMT_AD024-GJAHR
*                            BUZEI = W_ZMT_AD024-BUZEI.
*    IF SY-SUBRC EQ 0 AND NOT LW_BSEG-GSBER IS INITIAL.
*      MOVE LW_BSEG-GSBER TO W_/ZAK/ANALITIKA-GSBER.
**++0002 2007.10.08  BG (FMC)
*      MOVE LW_BSEG-PRCTR TO W_/ZAK/ANALITIKA-PRCTR.
**--0002 2007.10.08  BG (FMC)
*    ENDIF.
**--0001 BG 2007.05.22
**   Szállító feltöltés az első BSEG tétel ahol a KOART = K.
*    LOOP AT LI_BSEG INTO LW_BSEG WHERE KOART EQ 'K'.
*      MOVE LW_BSEG-LIFNR TO W_/ZAK/ANALITIKA-LIFKUN.
**++0001 BG 2007.05.22
*      IF W_/ZAK/ANALITIKA-GSBER IS INITIAL.
*        MOVE LW_BSEG-GSBER TO W_/ZAK/ANALITIKA-GSBER.
*      ENDIF.
**--0001 BG 2007.05.22
**++0003 2008.01.21 BG (FMC)
*      MOVE LW_BSEG-XREF1+8(4) TO W_/ZAK/ANALITIKA-BUKRS.
**--0003 2008.01.21 BG (FMC)
*      EXIT.
*    ENDLOOP.
*
**++0002 2007.10.08  BG (FMC)
*    IF W_/ZAK/ANALITIKA-PRCTR IS INITIAL.
*      LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT PRCTR IS INITIAL.
*        MOVE LW_BSEG-PRCTR TO W_/ZAK/ANALITIKA-PRCTR.
*        EXIT.
*      ENDLOOP.
*    ENDIF.
*
*    CALL FUNCTION '/ZAK/ROTATE_BUKRS_INPUT'
*      EXPORTING
*        I_FI_BUKRS    = W_/ZAK/ANALITIKA-FI_BUKRS
*        I_AD_BUKRS    = W_/ZAK/ANALITIKA-BUKRS
*        I_DATE        = W_/ZAK/ANALITIKA-ADODAT
**++0003 2008.01.21 BG (FMC)
**       I_GSBER       = W_/ZAK/ANALITIKA-GSBER
**       I_PRCTR       = W_/ZAK/ANALITIKA-PRCTR
**--0003 2008.01.21 BG (FMC)
*      IMPORTING
*        E_AD_BUKRS    = W_/ZAK/ANALITIKA-BUKRS
*      EXCEPTIONS
*        MISSING_INPUT = 1
*        OTHERS        = 2.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE E232 WITH W_/ZAK/ANALITIKA-BUKRS.
**      Hiba a & vállalat forgatás meghatározásnál! ..
*    ENDIF.
*
*    IF W_/ZAK/ANALITIKA-BUKRS NE P_BUKRS.
*      DELETE I_ZMT_AD024.
*      CONTINUE.
*    ENDIF.
*
***++0001 BG 2007.05.22
***   Ha MA01 a vállalat kód és az üzletág 2, akkor MMOB-ra tesszük
**    IF W_ZMT_AD024-BUKRS EQ 'MA01' AND
**       P_BUKRS EQ 'MA01' AND
**       W_/ZAK/ANALITIKA-GSBER = '2' AND
**       W_ZMT_AD024-ADODAT < '20060301'.
**      DELETE  I_ZMT_AD024.
**      CONTINUE.
**    ENDIF.
**
**    IF W_ZMT_AD024-BUKRS EQ 'MA01' AND
**       P_BUKRS EQ 'MMOB' AND
**       W_/ZAK/ANALITIKA-GSBER = '2' AND
**       W_ZMT_AD024-ADODAT < '20060301'.
**      MOVE 'MMOB' TO W_/ZAK/ANALITIKA-BUKRS.
**    ELSEIF P_BUKRS EQ 'MMOB'.
**      DELETE  I_ZMT_AD024.
**      CONTINUE.
**    ENDIF.
***--0001 BG 2007.05.22
**--0002 2007.10.08  BG (FMC)
*
*
**   Háromszögügylet feltöltés
*    SELECT SINGLE HSZU INTO W_/ZAK/ANALITIKA-HSZU
*                       FROM /ZAK/HRSZU
*                      WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
*                        AND MWSKZ EQ W_/ZAK/ANALITIKA-MWSKZ.
*
*
*    APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
*  ENDLOOP.

ENDFORM.                    " GET_DATA_SEL
*&---------------------------------------------------------------------*
*&      Form  INS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TESZT  text
*----------------------------------------------------------------------*
FORM INS_DATA  USING $TESZT.

  DATA LI_RETURN TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0.
  DATA LW_RETURN TYPE BAPIRET2.

  DATA L_TEXTLINE1(80).
  DATA L_TEXTLINE2(80).
  DATA L_DIAGNOSETEXT1(80).
  DATA L_DIAGNOSETEXT2(80).
  DATA L_DIAGNOSETEXT3(80).
  DATA L_TITLE(40).
  DATA L_TABIX LIKE SY-TABIX.

  DATA L_ANSWER.

  DATA L_PACK LIKE /ZAK/ANALITIKA-PACK.

  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.

*  Először mindig tesztben futtatjuk
  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = P_BUKRS
*     I_BTYPE     = P_BTYPE
      I_BTYPART   = P_BTYPAR
      I_BSZNUM    = P_BSZNUM
*     I_PACK      =
      I_GEN       = 'X'
      I_TEST      = 'X'
*     I_FILE      =
    TABLES
      I_ANALITIKA = I_/ZAK/ANALITIKA
      E_RETURN    = LI_RETURN.

*   Üzenetek kezelése
  IF NOT LI_RETURN[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = LI_RETURN.
  ENDIF.

*  Ha nem teszt futás, akkor ellenőrizzük van ERROR
  IF NOT $TESZT IS INITIAL.
    LOOP AT LI_RETURN INTO LW_RETURN WHERE TYPE CA 'EA'.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      MESSAGE E062.
*     Adatfeltöltés nem lehetséges!
    ENDIF.
  ENDIF.

*  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról,
  IF $TESZT IS INITIAL.
*    Ha nem háttérben fut
    IF NOT LI_RETURN[] IS INITIAL AND SY-BATCH IS INITIAL.
*    Szövegek betöltése
      MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
      MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                           TO L_DIAGNOSETEXT1.
      MOVE 'Folytatja  feldolgozást?'(003)
                                           TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*        EXPORTING
*          DEFAULTOPTION  = 'N'
*          DIAGNOSETEXT1  = L_DIAGNOSETEXT1
**         DIAGNOSETEXT2  = ' '
**         DIAGNOSETEXT3  = ' '
*          TEXTLINE1      = L_TEXTLINE1
**         TEXTLINE2      = ' '
*          TITEL          = L_TITLE
*          START_COLUMN   = 25
*          START_ROW      = 6
**         CANCEL_DISPLAY = 'X'
*        IMPORTING
*          ANSWER         = L_ANSWER.
      DATA L_QUESTION TYPE STRING.

      CONCATENATE L_DIAGNOSETEXT1
                  L_TEXTLINE1
                  INTO L_QUESTION SEPARATED BY SPACE.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR       = L_TITLE
*         DIAGNOSE_OBJECT             = ' '
          TEXT_QUESTION  = L_QUESTION
*         TEXT_BUTTON_1  = 'Ja'(001)
*         ICON_BUTTON_1  = ' '
*         TEXT_BUTTON_2  = 'Nein'(002)
*         ICON_BUTTON_2  = ' '
          DEFAULT_BUTTON = '2'
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
          START_COLUMN   = 25
          START_ROW      = 6
*         POPUP_TYPE     =
        IMPORTING
          ANSWER         = L_ANSWER.
      IF L_ANSWER EQ '1'.
        MOVE 'J' TO L_ANSWER.
      ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*    Egyébként mehet
    ELSE.
      MOVE 'J' TO L_ANSWER.
    ENDIF.

*   Mehet az adatbázis módosítása
    IF L_ANSWER EQ 'J'.
*      Adatok módosítása
      CALL FUNCTION '/ZAK/UPDATE'
        EXPORTING
          I_BUKRS     = P_BUKRS
*         I_BTYPE     = P_BTYPE
          I_BTYPART   = P_BTYPAR
          I_BSZNUM    = P_BSZNUM
*         I_PACK      =
          I_GEN       = 'X'
          I_TEST      = $TESZT
*         I_FILE      =
        TABLES
          I_ANALITIKA = I_/ZAK/ANALITIKA
          E_RETURN    = LI_RETURN.

      READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA INDEX 1.
*++0004 2008.04.04  BG (FMC)
*      LOOP AT I_ZMT_AD024 INTO W_ZMT_AD024.
*        MOVE 'X' TO W_ZMT_AD024-FELDO.
*        MODIFY I_ZMT_AD024 FROM W_ZMT_AD024 TRANSPORTING FELDO.
*      ENDLOOP.
**     ZMT_AD024_OJ_ANA tábla update
*      UPDATE ZMT_AD024_OJ_ANA FROM TABLE I_ZMT_AD024.
      MOVE W_/ZAK/ANALITIKA-PACK TO W_/ZAK/ANALITIKA_SEL-ONYB_PACK.
      MODIFY I_/ZAK/ANALITIKA_SEL FROM W_/ZAK/ANALITIKA_SEL
                                 TRANSPORTING ONYB_PACK
                                 WHERE BUKRS EQ P_BUKRS.
*     Visszaírjuk a FLAG értékét:
      UPDATE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_SEL.
*--0004 2008.04.04  BG (FMC)

      COMMIT WORK AND WAIT.

      MESSAGE I033 WITH W_/ZAK/ANALITIKA-PACK.
*     Feltöltés & package számmal megtörtént!
    ENDIF.
  ENDIF.

ENDFORM.                    " INS_DATA

*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  CALL SCREEN 9000.
ENDFORM.                    " list_display
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.

  PERFORM SET_STATUS.


  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_/ZAK/ANALITIKA[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  set_status
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

  DATA: TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
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

ENDFORM.                    " set_status

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
FORM CREATE_AND_INIT_ALV CHANGING $I_/ZAK/ANALITIKA LIKE
                                                   I_/ZAK/ANALITIKA[]
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
      IT_OUTTAB            = $I_/ZAK/ANALITIKA.

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
FORM BUILD_FIELDCAT USING    $DYNNR    LIKE SYST-DYNNR
                    CHANGING $FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.


  IF $DYNNR = '9000'.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = $FIELDCAT.

    LOOP AT $FIELDCAT INTO S_FCAT.
*         S_FCAT-FIELDNAME = 'ADOAZON'  OR
      IF  S_FCAT-FIELDNAME = 'XMANU'    OR
          S_FCAT-FIELDNAME = 'XDEFT'    OR
          S_FCAT-FIELDNAME = 'VORSTOR'  OR
          S_FCAT-FIELDNAME = 'STAPO'    OR
*         S_FCAT-FIELDNAME = 'DMBTR'    OR
          S_FCAT-FIELDNAME = 'KOSTL'    OR
          S_FCAT-FIELDNAME = 'ZCOMMENT' OR
          S_FCAT-FIELDNAME = 'BOOK'     OR
          S_FCAT-FIELDNAME = 'KMONAT'   OR
          S_FCAT-FIELDNAME = 'KTOSL'    OR
          S_FCAT-FIELDNAME = 'KBETR'    OR
          S_FCAT-FIELDNAME = 'ZFBDT'    OR
          S_FCAT-FIELDNAME = 'HKONT'    OR
          S_FCAT-FIELDNAME = 'STCD1'    OR
          S_FCAT-FIELDNAME = 'LWBAS'    OR
          S_FCAT-FIELDNAME = 'FWBAS'    OR
          S_FCAT-FIELDNAME = 'LWSTE'    OR
          S_FCAT-FIELDNAME = 'FWSTE'    OR
          S_FCAT-FIELDNAME = 'HWBTR'    OR
          S_FCAT-FIELDNAME = 'FWBTR'    OR
          S_FCAT-FIELDNAME = 'AUFNR'    OR
          S_FCAT-FIELDNAME = 'UMSKZ'    OR
          S_FCAT-FIELDNAME = 'BSCHL'    OR
          S_FCAT-FIELDNAME = 'AUGDT'    OR
          S_FCAT-FIELDNAME = 'PRCTR'    OR
          S_FCAT-FIELDNAME = 'TTIP'    OR
          S_FCAT-FIELDNAME = 'GSBER'.
        S_FCAT-NO_OUT = 'X'.
        MODIFY $FIELDCAT FROM S_FCAT.
      ENDIF.
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
FORM EXIT_PROGRAM USING $TESZT.
  IF $TESZT IS INITIAL.
    LEAVE PROGRAM.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " exit_program
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
*&      Form  GET_DATA_SEL_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONYB_ABEV  text
*      -->P_V_BUKRS  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM GET_DATA_SEL_ANALITIKA  TABLES   $I_/ZAK/ANALITIKA_SEL
                                            STRUCTURE /ZAK/ANALITIKA
                                      $I_/ZAK/ANALITIKA
                                            STRUCTURE /ZAK/ANALITIKA
                                      $I_ONYB_ABEV LIKE I_ONYB_ABEV
                             USING    $BUKRS
*++1565 #03.
                                      $BSZNUM
*--1565 #03.
                                      $SUBRC.
ENHANCEMENT-POINT /ZAK/ZAK_RG_ONYB_01 SPOTS /ZAK/ONYB_SEL STATIC .

*++15A60 #01. 2015.01.27
**++0006 2010.01.22 BG
*  DATA LI_ONY_NYLAP LIKE /ZAK/ONY_NYLAP OCCURS 0 WITH HEADER LINE.
**--0006 2010.01.27 BG
  DATA LW_ONYB_ABEV TYPE T_ONYB_ABEV.
*--15A60 #01. 2015.01.27

*++1365 #17.  2013.05.16
  DATA LI_BEVALLD TYPE STANDARD TABLE OF /ZAK/BEVALLD WITH HEADER LINE.
*--1365 #17.  2013.05.16


  RANGES LR_BSZNUM FOR /ZAK/BEVALLD-BSZNUM.

  DEFINE LM_SET_ONYBF.
    MOVE C_X TO W_/ZAK/ANALITIKA_SEL-ONYBF.
    MODIFY I_/ZAK/ANALITIKA_SEL FROM W_/ZAK/ANALITIKA_SEL
           TRANSPORTING ONYBF.
  END-OF-DEFINITION.

* Adatok leválogatása
  SELECT * INTO TABLE $I_/ZAK/ANALITIKA_SEL
           FROM /ZAK/ANALITIKA
           FOR ALL ENTRIES IN $I_ONYB_ABEV
          WHERE BUKRS  EQ $BUKRS
            AND BTYPE  EQ $I_ONYB_ABEV-BTYPE
            AND ABEVAZ EQ $I_ONYB_ABEV-ABEVAZ
            AND ONYBF  EQ ''.
  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
    EXIT.
  ENDIF.

* Meghatározzuk azokat a feltöltés azonosítókat amiket nem kell
* figyelembe venni, de be kell jelölni, hogy feldolgoztuk.
*++1365 #17. 2013.05.16 Be kell olvasni az összes feltöltés
*azonosítót mert BTYPE-al kell vizsgálni!
*  SELECT BSZNUM INTO LR_BSZNUM-LOW
*                FROM /ZAK/BEVALLD
*               WHERE BUKRS = $BUKRS
**++2012.01.10 RN
**                 AND FILETYPE = '00'.
*                 AND FILETYPE NE '04'.
**--2012.01.10 RN
*    M_DEF LR_BSZNUM 'I' 'EQ' LR_BSZNUM-LOW SPACE.
*  ENDSELECT.
  SELECT  /ZAK/BEVALLD~BUKRS
          /ZAK/BEVALLD~BTYPE
          /ZAK/BEVALLD~BSZNUM INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALLD
          FROM /ZAK/BEVALLD INNER JOIN /ZAK/BEVALL ON
               /ZAK/BEVALL~BUKRS = /ZAK/BEVALLD~BUKRS
           AND /ZAK/BEVALL~BTYPE = /ZAK/BEVALLD~BTYPE
           AND /ZAK/BEVALL~BTYPART = C_BTYPART_AFA
         WHERE /ZAK/BEVALLD~BUKRS  = $BUKRS
           AND /ZAK/BEVALLD~FILETYPE NE '04'.
    COLLECT W_/ZAK/BEVALLD INTO LI_BEVALLD.
  ENDSELECT.
  SORT LI_BEVALLD.
*--1365 #17. 2013.05.16
ENHANCEMENT-POINT /ZAK/ZAK_RG_ONYB_02 SPOTS /ZAK/ONYB_SEL .

*++15A60 #01. 2015.01.27
**++0006 2010.01.22 BG
*  SELECT * INTO TABLE LI_ONY_NYLAP
*           FROM /ZAK/ONY_NYLAP.
*  SORT LI_ONY_NYLAP.
**--0006 2010.01.27 BG
  SORT $I_ONYB_ABEV.
*--15A60 #01. 2015.01.27


* Analitika feldolgozása
  LOOP AT $I_/ZAK/ANALITIKA_SEL INTO W_/ZAK/ANALITIKA_SEL.
*   Ha  feltöltés azonosító nem kell feldolgozni:
*++1365 #17. 2013.05.16
*    IF NOT LR_BSZNUM[] IS INITIAL AND
*       W_/ZAK/ANALITIKA_SEL-BSZNUM IN LR_BSZNUM.
*      LM_SET_ONYBF.
*      CONTINUE.
*    ENDIF.
    IF NOT LI_BEVALLD[] IS INITIAL.
      READ TABLE LI_BEVALLD TRANSPORTING NO FIELDS
           WITH KEY BUKRS  = W_/ZAK/ANALITIKA_SEL-BUKRS
                    BTYPE  = W_/ZAK/ANALITIKA_SEL-BTYPE
                    BSZNUM = W_/ZAK/ANALITIKA_SEL-BSZNUM
                    BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        LM_SET_ONYBF.
        CONTINUE.
      ENDIF.
    ENDIF.
*--1365 #17. 2013.05.16

    CLEAR W_/ZAK/ANALITIKA.
    MOVE-CORRESPONDING W_/ZAK/ANALITIKA_SEL TO W_/ZAK/ANALITIKA.
*++1565 #03.
*++1665 #03.
*    CLEAR: W_/ZAK/ANALITIKA-ZINDEX, W_/ZAK/ANALITIKA-PACK.
    CLEAR: W_/ZAK/ANALITIKA-ZINDEX, W_/ZAK/ANALITIKA-PACK, W_/ZAK/ANALITIKA-NONEED.
*--1565 #03.
    W_/ZAK/ANALITIKA-BSZNUM = $BSZNUM.
*--1565 #03.
ENHANCEMENT-POINT /ZAK/ZAK_RG_ONYB_03 SPOTS /ZAK/ONYB_SEL .

*++0006 2010.01.22 BG
*   NYLAP meghatározás
*    IF W_/ZAK/ANALITIKA-KOART EQ 'D'.
*      W_/ZAK/ANALITIKA-NYLAPAZON = '01'.
*    ELSEIF W_/ZAK/ANALITIKA-KOART EQ 'K'.
*      W_/ZAK/ANALITIKA-NYLAPAZON = '02'.
*    ENDIF.
*++15A60 #01. 2015.01.27
*    READ TABLE LI_ONY_NYLAP
*         WITH KEY BTYPE = W_/ZAK/ANALITIKA-BTYPE
*                  MWSKZ = W_/ZAK/ANALITIKA-MWSKZ
*                  KTOSL = W_/ZAK/ANALITIKA-KTOSL
*                  BINARY SEARCH.
*    IF SY-SUBRC EQ 0.
*      W_/ZAK/ANALITIKA-NYLAPAZON = LI_ONY_NYLAP-NYLAP.
*    ELSE.
*      MESSAGE E290 WITH W_/ZAK/ANALITIKA-BTYPE
*                        W_/ZAK/ANALITIKA-KOART
*                        W_/ZAK/ANALITIKA-MWSKZ
*                        W_/ZAK/ANALITIKA-KTOSL.
**   Nem sikerült lap azonosítót meghatározni! (&/&/&/&)
*    ENDIF.
    CLEAR LW_ONYB_ABEV.
    READ TABLE $I_ONYB_ABEV INTO LW_ONYB_ABEV
               WITH KEY BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                        ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                        BINARY SEARCH.
    IF NOT LW_ONYB_ABEV-ONYLAPAZON IS INITIAL.
      W_/ZAK/ANALITIKA-NYLAPAZON = LW_ONYB_ABEV-ONYLAPAZON.
    ELSE.
      MESSAGE E290 WITH W_/ZAK/ANALITIKA-BTYPE  W_/ZAK/ANALITIKA-ABEVAZ.
*   Nem sikerült lap azonosítót meghatározni! (&/&/&/&)
    ENDIF.
*--15A60 #01. 2015.01.27

*--0006 2010.01.27 BG

*   Adóazonosító
    MOVE W_/ZAK/ANALITIKA-STCEG TO W_/ZAK/ANALITIKA-ADOAZON.
*   ABEV azonosító
    MOVE C_ABEVAZ_DUMMY TO W_/ZAK/ANALITIKA-ABEVAZ.

*   Háromszögügylet feltöltés
    SELECT SINGLE HSZU INTO W_/ZAK/ANALITIKA-HSZU
                       FROM /ZAK/HRSZU
                      WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
                        AND MWSKZ EQ W_/ZAK/ANALITIKA-MWSKZ.

ENHANCEMENT-POINT /ZAK/ONYB_TELENOR_NONEED SPOTS /ZAK/ONYB_TELENOR .

ENHANCEMENT-POINT /ZAK/ZAK_RG_ONYB_04 SPOTS /ZAK/ONYB_SEL .

    APPEND W_/ZAK/ANALITIKA TO $I_/ZAK/ANALITIKA.
    LM_SET_ONYBF.
  ENDLOOP.

ENDFORM.                    " GET_DATA_SEL_ANALITIKA

*++2265 #09.
*&---------------------------------------------------------------------*
*&      Form  LOCK_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOCK_PROGRAM USING $TEST.

   CHECK $TEST IS INITIAL.

   CALL FUNCTION 'ENQUEUE_/ZAK/ESTART'
     EXPORTING
       MODE_/ZAK/START = 'X'
       MANDT          = SY-MANDT
       BUKRS          = P_BUKRS
*      X_BUKRS        = ' '
*      _SCOPE         = '2'
*      _WAIT          = ' '
*      _COLLECT       = ' '
     EXCEPTIONS
       FOREIGN_LOCK   = 1
       SYSTEM_FAILURE = 2
       OTHERS         = 3.
   IF SY-SUBRC <> 0.
* Implement suitable error handling here
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

   ENDIF.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TESZT  text
*----------------------------------------------------------------------*
 FORM UNLOCK_PROGRAM  USING    $TEST.

   CHECK $TEST IS INITIAL.
   CALL FUNCTION 'DEQUEUE_/ZAK/ESTART'
     EXPORTING
       MODE_/ZAK/START = 'X'
       MANDT          = SY-MANDT
       BUKRS          = P_BUKRS
*      X_BUKRS        = ' '
*      _SCOPE         = '3'
*      _SYNCHRON      = ' '
*      _COLLECT       = ' '
     .
 ENDFORM.
*--2265 #09.
