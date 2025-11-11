*&---------------------------------------------------------------------*
*& Program: SAP adatok meghatározása ÁFA adóbevalláshoz
*&---------------------------------------------------------------------*
 REPORT /ZAK/ZAK_/ZAK/AFA_SAP_SELMIGR MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/ANALITIKA-ba
*& tárolja.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2006.01.18
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
*& 0001   2007.01.03   Balázs G.     Új mezők töltése, üzletág kezelés
*&                                   fiktív vállalat kezelése
*& 0002   2007.05.29   Balázs G.     ÁFA 04-es 06-os lap kezelése
*& 0003   2007.09.25   Balázs G.     közösségi adószám nem a törzsből
*&                                   hanem a bizonylatból kell
*& 0004   2007.10.04   Balázs G.     Vállalat és időszak forg. beépítése
*& 0005   2007.12.12   Balázs G.     Program másolása /ZAK/ZAK_SAP_SEL-ről
*&                                   Áfa arányosítás módosítások
*& 0006   2008.01.21   Balázs G.     Vállalat forgatás átalakítás
*&                                   beépítése
*& 0007   2008.05.21   Balázs G.     Főkönyvi szám szerinti vállalat
*&                                   forgatás beépítése
*& 0008   2008.09.01   Balázs G.     Arányosítás vállalat forgatás
*&                                   javítása
*& 0009   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra
*&                                   ellenőrzés visszaállítása
*& 0010   2009/01/14   Balázs G.     IDŐSZAK meghatározás javítása
*& 0011   2009/10/29   Balázs G.     Váll.forg. XREF1 átlakítás,
*&                                   Prof.cent. szerinti forgatás
*& 0012   2010/02/04   Balázs G.     VPOP aranyásított sor kezelés
*&                                   módosítása
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE /ZAK/SAP_SEL_F01.


 CONSTANTS C_BSET_MAX_REC LIKE SY-TABIX VALUE 35000.
 CONSTANTS C_DUMMY_ZINDEX LIKE /ZAK/BSET-ZINDEX VALUE 'DUM'.


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
 TABLES: /ZAK/BSET.


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
 DATA V_SUBRC LIKE SY-SUBRC.
 DATA V_REPID LIKE SY-REPID.

*BSET szelekcióhoz
 DATA W_/ZAK/BSET  TYPE /ZAK/BSET.
 DATA I_/ZAK/BSET  TYPE STANDARD TABLE OF /ZAK/BSET   INITIAL SIZE 0.
*ÁFA beállítások
 DATA W_/ZAK/AFA_CUST TYPE /ZAK/AFA_CUST.
 DATA I_/ZAK/AFA_CUST TYPE STANDARD TABLE OF /ZAK/AFA_CUST INITIAL SIZE 0.
 DATA V_TEXT(40).

* ALV kezelési változók
 DATA: V_OK_CODE          LIKE SY-UCOMM,
       V_SAVE_OK          LIKE SY-UCOMM,
       V_CONTAINER        TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
       V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       I_FIELDCAT         TYPE LVC_T_FCAT,
       V_LAYOUT           TYPE LVC_S_LAYO,
       V_VARIANT          TYPE DISVARIANT,
       V_GRID             TYPE REF TO CL_GUI_ALV_GRID.


* Bevallás típus időszakonként
 TYPES: BEGIN OF T_BTYPE,
          GJAHR TYPE GJAHR,
          MONAT TYPE MONAT,
          BTYPE TYPE /ZAK/BTYPE,
        END OF T_BTYPE.

*++S4HANA#01.
* DATA  I_BTYPE TYPE T_BTYPE OCCURS 0.
 DATA  GT_I_BTYPE TYPE STANDARD TABLE OF T_BTYPE .
*--S4HANA#01.
 DATA  W_BTYPE TYPE T_BTYPE.



 DEFINE M_GET_PACK_TO_NUM.
   WRITE &1 CURRENCY &2 TO V_TEXT NO-GROUPING
                                  LEFT-JUSTIFIED.
   REPLACE ',' WITH '.' INTO V_TEXT.
   &3 = V_TEXT.
 END-OF-DEFINITION.

*++0002 BG 2007.05.29
*MAKRO definiálás range feltöltéshez
 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   APPEND &1.
 END-OF-DEFINITION.

 RANGES R_VPOP_LIFNR FOR LFA1-LIFNR.
*--0002 BG 2007.05.29

*++0004 2007.10.08  BG (FMC)
 DATA V_BUKRS TYPE BUKRS.
*--0004 2007.10.08  BG (FMC)

*++0005 BG 2007.12.12
 TYPES: BEGIN OF T_ARANY_IDSZ,
          BUKRS  TYPE BUKRS,
          BTYPE  TYPE /ZAK/BTYPE,
          GJAHR  TYPE GJAHR,
          MONAT  TYPE MONAT,
          ZINDEX TYPE /ZAK/INDEX,
        END OF T_ARANY_IDSZ.

 DATA W_ARANY_IDSZ TYPE T_ARANY_IDSZ.

 DATA L_STGRP TYPE STGRP_007B.
*ÁFA irány meghatározás
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

 TYPES: BEGIN OF T_MWSKZ,
          MWSKZ TYPE MWSKZ,
          KTOSL TYPE KTOSL_007B,
        END OF T_MWSKZ.

*++S4HANA#01.
* DATA I_MWSKZ  TYPE T_MWSKZ OCCURS 0.
 DATA GT_I_MWSKZ  TYPE STANDARD TABLE OF T_MWSKZ .
*--S4HANA#01.
 DATA W_MWSKZ  TYPE T_MWSKZ.
*--0005 BG 2007.12.12

*++0011 BG 2009.10.29
 TYPES: BEGIN OF T_AD_BUKRS,
          AD_BUKRS TYPE /ZAK/AD_BUKRS,
        END OF T_AD_BUKRS.

 DATA I_AD_BUKRS TYPE T_AD_BUKRS OCCURS 0 WITH HEADER LINE.

 TYPES: BEGIN OF T_PRCTR,
          PRCTR    TYPE PRCTR,
          AD_BUKRS TYPE /ZAK/AD_BUKRS,
        END OF T_PRCTR.

 DATA I_PRCTR TYPE T_PRCTR OCCURS 0 WITH HEADER LINE.

*Vállalat forgatás XREF1 makró
 DEFINE M_XREF1.
   CLEAR &3.
   LOOP AT &1.
     IF &2 CS &1-AD_BUKRS.
       &3 = &1-AD_BUKRS.
     ENDIF.
   ENDLOOP.
 END-OF-DEFINITION.
*--0011 BG 2009.10.29


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
* Bevallás típus.
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-102.
* PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLD-BTYPE OBLIGATORY.
     PARAMETERS:  P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                                           DEFAULT C_BTYPART_AFA
                                                   OBLIGATORY.
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
   SELECTION-SCREEN END OF LINE.

** Év
* PARAMETERS: p_gjhar LIKE bkpf-gjahr DEFAULT sy-datum(4)
*                                     OBLIGATORY.
** Hónap
* PARAMETERS: p_monat LIKE bkpf-monat DEFAULT sy-datum+4(2)
*                                     OBLIGATORY.
* Adatszolgáltatás azonosító
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-103.
     PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BSZNUM_SH
                               OBLIGATORY.

     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_BSZTXT  LIKE /ZAK/BEVALLDT-SZTEXT MODIF ID DIS.
   SELECTION-SCREEN END OF LINE.

   PARAMETERS P_SPACE RADIOBUTTON GROUP GR1 DEFAULT 'X'.
   PARAMETERS P_BELNR RADIOBUTTON GROUP GR1.

   PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X' .

 SELECTION-SCREEN: END OF BLOCK BL01.

 SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
*Bizonylat
   SELECT-OPTIONS S_BELNR FOR /ZAK/BSET-BELNR.
*Év
   SELECT-OPTIONS S_GJAHR FOR /ZAK/BSET-GJAHR.
 SELECTION-SCREEN: END OF BLOCK BL02.

****************************************************************
* LOCAL CLASSES: Definition
****************************************************************



*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.
   GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Megnevezések meghatározása
   PERFORM READ_ADDITIONALS.
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
 AT SELECTION-SCREEN ON P_BTYPAR.
*  AFA bevallás típus ellenőrzése
   PERFORM VER_BTYPEART USING P_BUKRS
                              P_BTYPAR
                              C_BTYPART_AFA
                     CHANGING V_SUBRC.

   IF NOT V_SUBRC IS INITIAL.
     MESSAGE E030.
*    Kérem ÁFA típusú bevallás azonosítót adjon meg!
   ENDIF.




 AT SELECTION-SCREEN ON P_BSZNUM.
   MOVE SY-REPID TO V_REPID.
*  Szolgáltatás azonosító ellenőrzése
*++0009 BG 2008/09/12
   V_REPID = '/ZAK/AFA_SAP_SELN'.
   PERFORM VER_BSZNUM   USING P_BUKRS
                              P_BTYPAR
                              P_BSZNUM
                              V_REPID
                     CHANGING V_SUBRC.
*--0009 BG 2008/09/12
* AT SELECTION-SCREEN ON p_monat.
**  Periódus ellenőrzése
*   PERFORM ver_period   USING p_monat.


* AT SELECTION-SCREEN ON BLOCK b102.
**  Blokk ellenőrzése
*   PERFORM ver_block_b102 USING p_norm
*                                p_ismet
*                                p_pack.

* AT SELECTION-SCREEN ON p_pack.



*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
*  Megnevezések meghatározása
   PERFORM READ_ADDITIONALS.

*  Bizonylat ellenőrzés
   PERFORM VER_BELNR.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*++0004 2007.10.08  BG (FMC)
*  Vállalat forgatás
*++0011 BG 2009.10.29
*   PERFORM ROTATE_BUKRS_OUTPUT USING P_BUKRS
*                            CHANGING V_BUKRS.
   PERFORM ROTATE_BUKRS_OUTPUT TABLES I_AD_BUKRS
                               USING  P_BUKRS
                                      V_BUKRS.
*--0011 BG 2009.10.29

*--0004 2007.10.08  BG (FMC)


*  Jogosultság vizsgálat
   PERFORM AUTHORITY_CHECK USING
*++0004 2007.10.08  BG (FMC)
*                                P_BUKRS
                                 V_BUKRS
*--0004 2007.10.08  BG (FMC)
                                 P_BTYPAR
                                 C_ACTVT_01.

*++1665 #02.
   PERFORM CALL_BSET_UPDATE USING V_BUKRS.
*--1665 #02.


*++0007 BG 2008.05.21
   PERFORM GET_SAKNR TABLES R_SAKNR
                     USING  V_BUKRS.
*--0007 BG 2008.05.21

*++0011 BG 2009.10.29
   PERFORM GET_PRCTR TABLES I_PRCTR
                     USING  V_BUKRS.
*--0011 BG 2009.10.29

*  Vállalati adatok beolvasása
   PERFORM GET_T001 USING
*++0004 2007.10.08  BG (FMC)
*                         P_BUKRS
                          V_BUKRS
*--0004 2007.10.08  BG (FMC)
*++S4HANA#01.
*                          V_SUBRC.
                 CHANGING V_SUBRC.
*--S4HANA#01.
   IF NOT V_SUBRC IS INITIAL.
*++0004 2007.10.08  BG (FMC)
*    MESSAGE A036 WITH P_BUKRS.
     MESSAGE A036 WITH V_BUKRS.
*--0004 2007.10.08  BG (FMC)
*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla)
   ENDIF.

*  ÁFA beállítások betöltése
*++S4HANA#01.
*   PERFORM GET_AFA_CUST USING V_SUBRC.
   PERFORM GET_AFA_CUST CHANGING V_SUBRC.
*--S4HANA#01.
   IF NOT V_SUBRC IS INITIAL.
     MESSAGE E032.
*   Hiba az ÁFA beállítások meghatározásánál!
   ENDIF.

*++0002 BG 2007.05.29
*  VPOP szállítók meghatározása
   PERFORM GET_VPOP_LIFNR TABLES R_VPOP_LIFNR
                           USING
*++0004 2007.10.08  BG (FMC)
*                                P_BUKRS
                                 V_BUKRS
*--0004 2007.10.08  BG (FMC)
                                 .
*--0002 BG 2007.05.29

*++0005 BG 2007.12.12
*  Arányosításhoz időszak meghatározása
*++S4HANA#01.
*   PERFORM GET_ARANY_IDSZ USING W_ARANY_IDSZ
*                                W_/ZAK/BEVALL
*                                P_BUKRS
*                                P_BTYPAR.
   PERFORM GET_ARANY_IDSZ USING P_BUKRS
                                P_BTYPAR
                       CHANGING W_ARANY_IDSZ
                                W_/ZAK/BEVALL.
*--S4HANA#01.
*--0005 BG 2007.12.12



*  Adatok szelektálása
*++S4HANA#01.
*   PERFORM SEL_DATA USING V_SUBRC.
   PERFORM SEL_DATA CHANGING V_SUBRC.
*--S4HANA#01.
   IF NOT V_SUBRC IS INITIAL.
     MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
     EXIT.
   ENDIF.

*  Ismerjük a BTYPE-okat ellenőrzések
*  PERFORM VER_BTYPE_BSZNUM.


*  EXIT meghívása
   PERFORM CALL_EXIT.

*  csak a DUMMY_R-es rekordok szükségesek
   DELETE I_/ZAK/ANALITIKA WHERE ABEVAZ NE C_ABEVAZ_DUMMY_R.


*  Teszt vagy éles futás, adatbázis módosítás, stb.
   PERFORM INS_DATA USING P_TESZT.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
 END-OF-SELECTION.
*  Háttérben nem készítünk listát.
   IF SY-BATCH IS INITIAL.
     PERFORM LIST_DISPLAY.
   ENDIF.

************************************************************************
* ALPROGRAMOK
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
*
*&---------------------------------------------------------------------*
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

** Bevallásfajta megnevezése
*   IF NOT P_BTYPE IS INITIAL.
*     SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
*        WHERE LANGU = SY-LANGU
*          AND BUKRS = P_BUKRS
*          AND BTYPE = P_BTYPE.
*   ENDIF.

** Adatszolgáltatás megnevezése
*   IF NOT P_BSZNUM IS INITIAL.
*     SELECT SINGLE SZTEXT INTO P_BSZTXT FROM /ZAK/BEVALLDT
*            WHERE LANGU = SY-LANGU
*              AND BUKRS = P_BUKRS
*              AND BTYPE = P_BTYPE
*              AND BSZNUM = P_BSZNUM.
*  ENDIF.


 ENDFORM.                    " read_additionals
*&---------------------------------------------------------------------*
*&      Form  ver_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
 FORM VER_PERIOD USING    $MONAT.

   IF NOT $MONAT BETWEEN '01' AND '16'.
     MESSAGE E020.
*   Kérem a periódus értékét 01-16 között adja meg!
   ENDIF.

 ENDFORM.                    " ver_period
*&---------------------------------------------------------------------*
*&      Form  ver_block_b102
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_NORM  text
*      -->P_P_ISMET  text
*      -->P_P_PACK  text
*----------------------------------------------------------------------*
 FORM VER_BLOCK_B102 USING    $NORM
                              $ISMET
*++S4HANA#01.
*                              $PACK.
                     CHANGING $PACK.
*--S4HANA#01.

   IF NOT $NORM IS INITIAL AND NOT $PACK IS INITIAL.
     MESSAGE I021.
*   Feltöltés azonosító figyelmen kívül hagyva!
     CLEAR $PACK.
   ENDIF.

   IF NOT $ISMET IS INITIAL AND $PACK IS INITIAL.
     MESSAGE E022.
*   Kérem adja meg a feltöltés azonosítót!
   ENDIF.

 ENDFORM.                    " ver_block_b102
*&---------------------------------------------------------------------*
*&      Form  sel_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM SEL_DATA USING $SUBRC.
 FORM SEL_DATA CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

   DATA LW_BSET TYPE BSET.
   DATA LW_BKPF TYPE BKPF.

   DATA LW_BSEG TYPE BSEG.
   DATA LI_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.

   DATA LW_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
   DATA LW_T007B LIKE T007B.

   DATA L_TABIX LIKE SY-TABIX.

*++0001 2007.01.03 BG (FMC)
   DATA L_BUKRS TYPE BUKRS.
   DATA L_VPOP_EXIT.
*  Analitika adatok 04,06-os laphoz.
   DATA LW_ANALITIKA_0406 LIKE /ZAK/ANALITIKA.
*--0001 2007.01.03 BG (FMC)

*  SORTED table az ITEM meghatározás miatt
   DATA  LI_/ZAK/ANALITIKA TYPE SORTED TABLE OF /ZAK/ANALITIKA
                               WITH UNIQUE DEFAULT KEY
                               INITIAL SIZE 0.


*++0005 BG 2007.12.12
   DATA L_FLAG.
   DATA L_AFA_IRANY.
   DATA L_MODE.
*--0005 BG 2007.12.12

*++2012.04.17 BG (NESS)
   DATA LW_AFA_ELO TYPE /ZAK/AFA_ELO.
   DATA LI_AFA_ELO TYPE STANDARD TABLE OF /ZAK/AFA_ELO INITIAL SIZE 0.
*--2012.04.17 BG (NESS)

*++0004 2007.10.08  BG (FMC)
**++0001 2007.01.03 BG (FMC)
*     IF P_BUKRS EQ 'MMOB'.
*       MOVE 'MA01' TO L_BUKRS.
*     ELSE.
*       MOVE P_BUKRS TO L_BUKRS.
*     ENDIF.
**--0001 2007.01.03 BG (FMC)
*++S4HANA#01.
   DATA LT_FAGL_BSEG_TMP TYPE FAGL_T_BSEG.
*--S4HANA#01.
   MOVE V_BUKRS TO L_BUKRS.
*--0004 2007.10.08  BG (FMC)

   CLEAR $SUBRC.
   IF NOT P_SPACE IS INITIAL.
     SELECT * INTO TABLE I_/ZAK/BSET
              FROM /ZAK/BSET
*++0001 2007.01.03 BG (FMC)
*           WHERE BUKRS  EQ P_BUKRS
              WHERE BUKRS  EQ L_BUKRS
*--0001 2007.01.03 BG (FMC)
                AND ZINDEX EQ SPACE.
   ELSEIF NOT P_BELNR IS INITIAL.
     SELECT * INTO TABLE I_/ZAK/BSET
              FROM /ZAK/BSET
*++0001 2007.01.03 BG (FMC)
*           WHERE BUKRS  EQ P_BUKRS
              WHERE BUKRS  EQ L_BUKRS
*--0001 2007.01.03 BG (FMC)
*              AND ZINDEX EQ SPACE.
                AND BELNR  IN S_BELNR
                AND GJAHR  IN S_GJAHR.
   ENDIF.
   IF SY-SUBRC NE 0.
     MOVE SY-SUBRC TO $SUBRC.
     EXIT.
   ENDIF.

*  Megvizsgáljuk mennyi rekordot találtunk
*++S4HANA#01.
*   DESCRIBE TABLE I_/ZAK/BSET LINES L_TABIX.
   L_TABIX = LINES( I_/ZAK/BSET ).
*--S4HANA#01.

*  Ha nem tesztfutás, és a max határ felett van és nem
*  háttér, akkor üzenet.
   IF P_TESZT  IS INITIAL AND
      SY-BATCH IS INITIAL AND
      L_TABIX GE C_BSET_MAX_REC.
     MESSAGE E145 WITH L_TABIX.
*    Feldolgozandó rekordszám: & . Kérem futtassa a programot háttérben!
   ENDIF.

*++2012.04.17 BG (NESS)
*  Beolvassuk létezik e beállítás az előleges kezelésre
*++S4HANA#01.
*   REFRESH LI_AFA_ELO.
   CLEAR LI_AFA_ELO[].
*--S4HANA#01.
   SELECT * INTO TABLE LI_AFA_ELO
            FROM /ZAK/AFA_ELO
           WHERE BUKRS EQ L_BUKRS.
*--2012.04.17 BG (NESS)

*  Adatok feldolgozása
   LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET.
     MOVE SY-TABIX TO L_TABIX.

     CLEAR: W_/ZAK/ANALITIKA, LW_BSET, LW_BKPF, LW_BSEG.
*++0002 BG 2007.05.29
     CLEAR: L_VPOP_EXIT, LW_ANALITIKA_0406, L_FLAG.
*--0002 BG 2007.05.29

     FREE LI_BSEG[].
*    BSET beolvasása
     SELECT SINGLE * INTO LW_BSET
                     FROM BSET
                    WHERE BUKRS EQ W_/ZAK/BSET-BUKRS
                      AND BELNR EQ W_/ZAK/BSET-BELNR
                      AND GJAHR EQ W_/ZAK/BSET-GJAHR
                      AND BUZEI EQ W_/ZAK/BSET-BUZEI.
*    BKPF beolvasása
     SELECT SINGLE * INTO LW_BKPF
                     FROM BKPF
                    WHERE BUKRS EQ W_/ZAK/BSET-BUKRS
                      AND BELNR EQ W_/ZAK/BSET-BELNR
                      AND GJAHR EQ W_/ZAK/BSET-GJAHR.
*    BSEG beolvasása
*++S4HANA#01.
*     SELECT * INTO TABLE LI_BSEG
*              FROM BSEG
*             WHERE BUKRS EQ W_/ZAK/BSET-BUKRS
*               AND BELNR EQ W_/ZAK/BSET-BELNR
*               AND GJAHR EQ W_/ZAK/BSET-GJAHR.
     CL_FAGL_EMU_CVRT_SERVICES=>GET_LEADING_LEDGER(
          IMPORTING
            ED_RLDNR = DATA(LV_RLDNR)
          EXCEPTIONS
            ERROR  = 4
            OTHERS = 4 ).

     IF SY-SUBRC = 0.
       CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
         EXPORTING
           I_RLDNR   = LV_RLDNR
           I_BUKRS   = W_/ZAK/BSET-BUKRS
           I_BELNR   = W_/ZAK/BSET-BELNR
           I_GJAHR   = W_/ZAK/BSET-GJAHR
         IMPORTING
           ET_BSEG   = LT_FAGL_BSEG_TMP
         EXCEPTIONS
           NOT_FOUND = 4
           OTHERS    = 4.
       IF SY-SUBRC = 0.
         SORT LT_FAGL_BSEG_TMP BY BUZEI.
         LI_BSEG = LT_FAGL_BSEG_TMP.
         FREE LT_FAGL_BSEG_TMP.
       ELSE.
         CLEAR LI_BSEG.
       ENDIF.
     ENDIF.
*--S4HANA#01.

*++0005 BG 2007.12.12
*    Áfa irány megahtározás
     M_0GET_AFABK LW_BSET-KTOSL L_AFA_IRANY.

     IF L_AFA_IRANY EQ 'K'.
       MOVE 'N' TO L_MODE.
     ELSEIF L_AFA_IRANY EQ 'B'.
       PERFORM GET_ARANY_MWSKZ USING W_/ZAK/BEVALL
                                     LW_BSET
                            CHANGING L_MODE.
     ENDIF.

*    Normál ÁFA feldolgozás
     IF L_MODE EQ 'N'.
*++1765 #28.
*       PERFORM MAP_ANALITIKA_NORMAL TABLES LI_BSEG
*++S4HANA#01.
*       PERFORM /ZAK/AFA_SAP_SELN(MAP_ANALITIKA_NORMAL) TABLES LI_BSEG
       PERFORM MAP_ANALITIKA_NORMAL  IN PROGRAM /ZAK/AFA_SAP_SELN TABLES LI_BSEG
*--S4HANA#01.
*--1765 #28.
*++0007 BG 2008.05.21
                                                 R_SAKNR
*--0007 BG 2008.05.21
*++0011 BG 2009.10.29
                                                 I_PRCTR
*--0011 BG 2009.10.29
*++2012.04.17 BG (NESS)
                                                 LI_AFA_ELO
*--2012.04.17 BG (NESS)
                                          USING  W_/ZAK/BSET
                                                 LW_BSET
                                                 LW_BKPF
                                                 L_FLAG.
       IF L_FLAG = 'D'.
         DELETE I_/ZAK/BSET.
         CONTINUE.
       ENDIF.
*    Arányosított ÁFA feldolgozás
     ELSEIF L_MODE EQ 'A'.
*++1765 #28.
*       PERFORM MAP_ANALITIKA_ARANY  TABLES LI_BSEG
       PERFORM MAP_ANALITIKA_ARANY IN PROGRAM /ZAK/AFA_SAP_SELN TABLES LI_BSEG
*--1765 #28.
                                    USING  W_/ZAK/BEVALL
                                           W_ARANY_IDSZ
                                           W_/ZAK/BSET
                                           LW_BSET
                                           LW_BKPF
                                           L_FLAG.
       IF L_FLAG = 'D'.
         DELETE I_/ZAK/BSET.
         CONTINUE.
       ENDIF.
     ENDIF.
     MOVE LW_BSET-MWSKZ TO W_/ZAK/BSET-MWSKZ.
     MOVE LW_BSET-KTOSL TO W_/ZAK/BSET-KTOSL.
     MODIFY I_/ZAK/BSET FROM W_/ZAK/BSET TRANSPORTING MWSKZ KTOSL.
*--0005 BG 2007.12.12
   ENDLOOP.


 ENDFORM.                    " sel_data
*&---------------------------------------------------------------------*
*&      Form  get_afa_cust
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM GET_AFA_CUST USING $SUBRC.
 FORM GET_AFA_CUST CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

   CLEAR $SUBRC.
   SELECT * INTO TABLE I_/ZAK/AFA_CUST
            FROM /ZAK/AFA_CUST.                          "#EC CI_NOWHERE
   IF SY-SUBRC NE 0.
     MOVE SY-SUBRC TO $SUBRC.
   ENDIF.

 ENDFORM.                    " get_afa_cust
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
       IF  S_FCAT-FIELDNAME = 'ADOAZON'  OR
           S_FCAT-FIELDNAME = 'XMANU'    OR
           S_FCAT-FIELDNAME = 'XDEFT'    OR
           S_FCAT-FIELDNAME = 'VORSTOR'  OR
           S_FCAT-FIELDNAME = 'STAPO'    OR
           S_FCAT-FIELDNAME = 'DMBTR'    OR
           S_FCAT-FIELDNAME = 'KOSTL'    OR
           S_FCAT-FIELDNAME = 'ZCOMMENT' OR
           S_FCAT-FIELDNAME = 'BOOK'     OR
           S_FCAT-FIELDNAME = 'KMONAT'   OR
           S_FCAT-FIELDNAME = 'AUFNR'.
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
*++S4HANA#01.
* FORM EXIT_PROGRAM USING $TESZT.
 FORM EXIT_PROGRAM USING $TESZT LIKE P_TESZT..
*--S4HANA#01.
   IF $TESZT IS INITIAL.
     LEAVE PROGRAM.
   ELSE.
     LEAVE TO SCREEN 0.
   ENDIF.
 ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  ins_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM INS_DATA USING $TESZT.
 FORM INS_DATA USING $TESZT LIKE P_TESZT..
*--S4HANA#01.

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

*++0002 BG 2007.06.19
   DATA L_BUPER TYPE BUPER.
*--0002 BG 2007.06.19


   IF I_/ZAK/ANALITIKA[] IS INITIAL.
     MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
     EXIT.
   ENDIF.

*  Először mindig tesztben futtatjuk
   CALL FUNCTION '/ZAK/UPDATE'
     EXPORTING
       I_BUKRS     = P_BUKRS
*      I_BTYPE     = P_BTYPE
       I_BTYPART   = P_BTYPAR
       I_BSZNUM    = P_BSZNUM
*      I_PACK      =
       I_GEN       = 'X'
       I_TEST      = 'X'
*      I_FILE      =
     TABLES
       I_ANALITIKA = I_/ZAK/ANALITIKA
*++1365 2013.01.22 Balázs Gábor (Ness)
       I_AFA_SZLA  = I_/ZAK/AFA_SZLA
*--1365 2013.01.22 Balázs Gábor (Ness)
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
*++S4HANA#01.
**       CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
**         EXPORTING
**           DEFAULTOPTION  = 'N'
**           DIAGNOSETEXT1  = L_DIAGNOSETEXT1
***          DIAGNOSETEXT2  = ' '
***          DIAGNOSETEXT3  = ' '
**           TEXTLINE1      = L_TEXTLINE1
***          TEXTLINE2      = ' '
**           TITEL          = L_TITLE
**           START_COLUMN   = 25
**           START_ROW      = 6
***          CANCEL_DISPLAY = 'X'
**         IMPORTING
**           ANSWER         = L_ANSWER.
*       DATA L_QUESTION TYPE STRING.
*
*       CONCATENATE L_DIAGNOSETEXT1
*                   L_TEXTLINE1
*                   INTO L_QUESTION SEPARATED BY SPACE.
*       CALL FUNCTION 'POPUP_TO_CONFIRM'
*         EXPORTING
*           TITLEBAR       = L_TITLE
**          DIAGNOSE_OBJECT       = ' '
*           TEXT_QUESTION  = L_QUESTION
**          TEXT_BUTTON_1  = 'Ja'(001)
**          ICON_BUTTON_1  = ' '
**          TEXT_BUTTON_2  = 'Nein'(002)
**          ICON_BUTTON_2  = ' '
*           DEFAULT_BUTTON = '2'
**          DISPLAY_CANCEL_BUTTON = 'X'
**          USERDEFINED_F1_HELP   = ' '
*           START_COLUMN   = 25
*           START_ROW      = 6
**          POPUP_TYPE     =
*         IMPORTING
*           ANSWER         = L_ANSWER.
*       IF L_ANSWER EQ '1'.
*         MOVE 'J' TO L_ANSWER.
*       ENDIF.

       DATA: LV_W_TEXT_QUESTION_0(400) TYPE C.
       CONCATENATE
         L_DIAGNOSETEXT1
         L_TEXTLINE1
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
           TITLEBAR       = L_TITLE
           TEXT_QUESTION  = LV_W_TEXT_QUESTION_0
           DEFAULT_BUTTON = LV_W_DEFAULT_BUTTON_0
           START_COLUMN   = 25
           START_ROW      = 6
         IMPORTING
           ANSWER         = L_ANSWER
         EXCEPTIONS
           TEXT_NOT_FOUND = 1.
       CASE SY-SUBRC.
         WHEN 1.
* IMPLEMENT ME
       ENDCASE.

       IF L_ANSWER = '1'.
         L_ANSWER = 'J'.
       ELSEIF L_ANSWER = '2'.
         L_ANSWER = 'N'.
       ENDIF.
*--S4HANA#01.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*    Egyébként mehet
     ELSE.
       MOVE 'J' TO L_ANSWER.
     ENDIF.

*    Mehet az adatbázis módosítása
     IF L_ANSWER EQ 'J'.
*      Adatok módosítása
       CALL FUNCTION '/ZAK/UPDATE'
         EXPORTING
           I_BUKRS     = P_BUKRS
*          I_BTYPE     = P_BTYPE
           I_BTYPART   = P_BTYPAR
           I_BSZNUM    = P_BSZNUM
*          I_PACK      =
           I_GEN       = 'X'
           I_TEST      = $TESZT
*          I_FILE      =
         TABLES
           I_ANALITIKA = I_/ZAK/ANALITIKA
*++1365 2013.01.22 Balázs Gábor (Ness)
           I_AFA_SZLA  = I_/ZAK/AFA_SZLA
*--1365 2013.01.22 Balázs Gábor (Ness)
           E_RETURN    = LI_RETURN.
*       SORT I_/ZAK/BSET.
**    Visszavezetjük az indexet
       READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA INDEX 1.
       MOVE W_/ZAK/ANALITIKA-PACK TO L_PACK.
*       LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
**        Elmentjük a package azonosítót
*         IF L_PACK IS INITIAL.
*           MOVE W_/ZAK/ANALITIKA-PACK TO L_PACK.
*         ENDIF.
*
**     Be kell jelölni azokat a rekordokat is amit nem kell feldolgozni
**         UPDATE /ZAK/BSET SET ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
**                       WHERE BUKRS  = W_/ZAK/ANALITIKA-BUKRS
**                         AND BELNR  = W_/ZAK/ANALITIKA-BSEG_BELNR
**                         AND BUZEI  = W_/ZAK/ANALITIKA-BSEG_BUZEI.
*
**++0004 2007.10.08  BG (FMC)
***++0001 2007.01.03 BG (FMC)
**         IF P_BUKRS EQ 'MMOB'.
**           MOVE 'MA01' TO W_/ZAK/ANALITIKA-BUKRS.
**         ENDIF.
***--0001 2007.01.03 BG (FMC)
**--0004 2007.10.08  BG (FMC)
*
*         READ TABLE I_/ZAK/BSET INTO W_/ZAK/BSET
*                           WITH KEY
**++0004 2007.10.08  BG (FMC)
**                                   BUKRS = W_/ZAK/ANALITIKA-BUKRS
*                                    BUKRS = V_BUKRS
**--0004 2007.10.08  BG (FMC)
*                                    BELNR = W_/ZAK/ANALITIKA-BSEG_BELNR
*                                    BUZEI = W_/ZAK/ANALITIKA-BSEG_BUZEI.
*         IF SY-SUBRC EQ 0.
*           MOVE SY-TABIX TO L_TABIX.
*           MOVE W_/ZAK/ANALITIKA-ZINDEX TO W_/ZAK/BSET-ZINDEX.
**++0004 2007.1 0.29 BG (FMC)
*           MOVE W_/ZAK/ANALITIKA-BUKRS  TO W_/ZAK/BSET-AD_BUKRS.
**--0004 2007.10.29 BG (FMC)
*           MODIFY I_/ZAK/BSET FROM W_/ZAK/BSET INDEX L_TABIX
*                                             TRANSPORTING ZINDEX
**++0004 2007.10.29 BG (FMC)
*                                                          AD_BUKRS.
**--0004 2007.10.29 BG (FMC)
*
**++0002 BG 2007.06.19
*           CONCATENATE W_/ZAK/ANALITIKA-GJAHR W_/ZAK/ANALITIKA-MONAT INTO L_BUPER.
*           IF W_/ZAK/BSET-BUPER NE L_BUPER.
*             MOVE L_BUPER TO W_/ZAK/BSET-BUPER.
*             MODIFY I_/ZAK/BSET FROM W_/ZAK/BSET INDEX L_TABIX
*                                               TRANSPORTING BUPER.
*           ENDIF.
**--0002 BG 2007.06.19
*         ENDIF.
*       ENDLOOP.

       IF NOT P_SPACE IS INITIAL.
*      Üres BSET rekordok bejelölése
         LOOP AT I_/ZAK/BSET INTO W_/ZAK/BSET WHERE ZINDEX IS INITIAL.
           MOVE C_DUMMY_ZINDEX TO W_/ZAK/BSET-ZINDEX.
           MODIFY I_/ZAK/BSET FROM W_/ZAK/BSET TRANSPORTING ZINDEX.
         ENDLOOP.
*      BSET tábla update.
         UPDATE /ZAK/BSET FROM TABLE I_/ZAK/BSET.
       ENDIF.

       COMMIT WORK AND WAIT.
       MESSAGE I033 WITH L_PACK.
*      Feltöltés & package számmal megtörtént!
     ENDIF.
   ENDIF.
 ENDFORM.                    " ins_data
*&---------------------------------------------------------------------*
*&      Form  call_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_EXIT.
*++1365 2013.01.22 Balázs Gábor (Ness)
   DATA LS_START TYPE /ZAK/START.
*--1365 2013.01.22 Balázs Gábor (Ness)


   CALL FUNCTION '/ZAK/AFA_SAP_SEL_EXIT'
     EXPORTING
*++0006 2007.10.08  BG (FMC)
*      I_BUKRS     = P_BUKRS
       I_BUKRS     = V_BUKRS
*--0006 2007.10.08  BG (FMC)
       I_BTYPART   = P_BTYPAR
       I_BSZNUM    = P_BSZNUM
     TABLES
       T_ANALITIKA = I_/ZAK/ANALITIKA.

*++1365 2013.01.22 Balázs Gábor (Ness)
   SELECT SINGLE * INTO LS_START
                   FROM /ZAK/START
                  WHERE BUKRS EQ V_BUKRS.
   IF NOT LS_START-SELEXIT IS INITIAL.
     CALL FUNCTION LS_START-SELEXIT
       EXPORTING
         I_START     = LS_START
       TABLES
         T_ANALITIKA = I_/ZAK/ANALITIKA
         T_AFA_SZLA  = I_/ZAK/AFA_SZLA.
   ENDIF.

*--1365 2013.01.22 Balázs Gábor (Ness)

 ENDFORM.                    " call_exit
*&---------------------------------------------------------------------*
*&      Form  get_bseg_lifnr_analitika
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_BSEG  text
*      -->P_W_/ZAK/ANALITIKA  text
*----------------------------------------------------------------------*
 FORM GET_BSEG_LIFNR_ANALITIKA USING $BSEG      STRUCTURE BSEG
*++S4HANA#01.
*                                     $ANALITIKA STRUCTURE /ZAK/ANALITIKA.
                            CHANGING $ANALITIKA STRUCTURE /ZAK/ANALITIKA.
*--S4HANA#01.

*++BG 2007.10.29
   DATA: BEGIN OF LW_LFA1,
           LAND1 TYPE LAND1_GP,
           STCD1 TYPE STCD1,
*++1365 2013.01.22 Balázs Gábor (Ness)
           STCD3 TYPE STCD3,
*--1365 2013.01.22 Balázs Gábor (Ness)
           STCEG TYPE STCEG,
         END OF LW_LFA1.
*--BG 2007.10.29

*++BG 2008.02.19
   DATA: L_SAVE_BUKRS TYPE BUKRS.
*--BG 2008.02.19


*  Esedékességszámítás bázisdátuma
   MOVE $BSEG-ZFBDT TO $ANALITIKA-ZFBDT.
*  Szállító
   MOVE $BSEG-LIFNR TO $ANALITIKA-LIFKUN.
*  Számlatípus
   MOVE $BSEG-KOART TO $ANALITIKA-KOART.

*++0003 BG 2007.09.25
**  Adószámok
*   SELECT SINGLE STCEG STCD1 INTO ($ANALITIKA-STCEG,
*                                   $ANALITIKA-STCD1)
*                             FROM  LFA1
*                            WHERE  LIFNR = $BSEG-LIFNR.
*++BG 2007.10.29
   CLEAR LW_LFA1.
*  SELECT SINGLE STCD1 INTO  $ANALITIKA-STCD1
   SELECT SINGLE * INTO CORRESPONDING FIELDS OF LW_LFA1
*--BG 2007.10.29
                             FROM  LFA1
                            WHERE  LIFNR = $BSEG-LIFNR.
*++BG 2007.10.29
   MOVE LW_LFA1-STCD1 TO $ANALITIKA-STCD1.
*--BG 2007.10.29
*++1365 2013.01.22 Balázs Gábor (Ness)
   MOVE LW_LFA1-STCD3 TO $ANALITIKA-STCD3.
*--1365 2013.01.22 Balázs Gábor (Ness)

   IF NOT $BSEG-STCEG IS INITIAL.
     MOVE $BSEG-STCEG TO $ANALITIKA-STCEG.
*++BG 2007.10.29
*  ELSEIF NOT $BSEG-EGBLD IS INITIAL.
   ELSE.
     MOVE LW_LFA1-STCEG TO $ANALITIKA-STCEG.
*       SELECT SINGLE STCEG INTO $ANALITIKA-STCEG
*                           FROM LFAS
*                          WHERE LIFNR EQ $BSEG-LIFNR
*                            AND LAND1 EQ $BSEG-EGBLD.
*--BG 2007.10.29
   ENDIF.
*--0003 BG 2007.09.25

*  Speciális főkönyv kódja
   MOVE $BSEG-UMSKZ TO $ANALITIKA-UMSKZ.
*  Könyvelési kulcs
   MOVE $BSEG-BSCHL TO $ANALITIKA-BSCHL.
*  Kiegyenlítés dátuma
   MOVE $BSEG-AUGDT TO $ANALITIKA-AUGDT.
*++BG 2008.02.19
*  Elmentjük a vállalat kódot
   MOVE $ANALITIKA-BUKRS TO L_SAVE_BUKRS.
*--BG 2008.02.19
*++0006 2008.01.21 BG (FMC)
*++0011 BG 2009.10.29
*  MOVE $BSEG-XREF1+8(4) TO $ANALITIKA-BUKRS.
   M_XREF1 I_AD_BUKRS $BSEG-XREF1 $ANALITIKA-BUKRS.
*--0011 BG 2009.10.29
*--0006 2008.01.21 BG (FMC)
*++BG 2008.02.19
*  Ha a vállalat kód üres visszaírjuk az eredetit
   IF $ANALITIKA-BUKRS IS INITIAL.
     MOVE L_SAVE_BUKRS TO $ANALITIKA-BUKRS.
   ENDIF.
*--BG 2008.02.19

 ENDFORM.                    " get_bseg_lifnr_analitika
*&---------------------------------------------------------------------*
*&      Form  get_bseg_kunnr_analitika
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_BSEG  text
*      -->P_W_/ZAK/ANALITIKA  text
*----------------------------------------------------------------------*
 FORM GET_BSEG_KUNNR_ANALITIKA USING  $BSEG      STRUCTURE BSEG
*++S4HANA#01.
*                                     $ANALITIKA STRUCTURE /ZAK/ANALITIKA.
                             CHANGING $ANALITIKA STRUCTURE /ZAK/ANALITIKA.
*--S4HANA#01.

*++BG 2007.10.29
   DATA: BEGIN OF LW_KNA1,
           LAND1 TYPE LAND1_GP,
           STCD1 TYPE STCD1,
*++1365 2013.01.22 Balázs Gábor (Ness)
           STCD3 TYPE STCD3,
*--1365 2013.01.22 Balázs Gábor (Ness)
           STCEG TYPE STCEG,
         END OF LW_KNA1.
*--BG 2007.10.29

*++BG 2008.02.19
   DATA: L_SAVE_BUKRS TYPE BUKRS.
*--BG 2008.02.19


*  Számlatípus
   MOVE $BSEG-KOART TO $ANALITIKA-KOART.
*  Vevő
   MOVE $BSEG-KUNNR TO $ANALITIKA-LIFKUN.

*++0003 BG 2007.09.25
**  Adószámok
*   SELECT SINGLE STCEG STCD1 INTO ($ANALITIKA-STCEG,
*                                   $ANALITIKA-STCD1)
*                             FROM  KNA1
*                            WHERE  KUNNR = $BSEG-KUNNR.
*++BG 2007.10.29
   CLEAR LW_KNA1.
*  Adószámok
*   SELECT SINGLE STCD1 INTO  $ANALITIKA-STCD1
   SELECT SINGLE * INTO CORRESPONDING FIELDS OF LW_KNA1
*--BG 2007.10.29
                   FROM  KNA1
                  WHERE  KUNNR = $BSEG-KUNNR.
*++BG 2007.10.29
   MOVE LW_KNA1-STCD1 TO $ANALITIKA-STCD1.
*--BG 2007.10.29
*++1365 2013.01.22 Balázs Gábor (Ness)
   MOVE LW_KNA1-STCD3 TO $ANALITIKA-STCD3.
*--1365 2013.01.22 Balázs Gábor (Ness)

   IF NOT $BSEG-STCEG IS INITIAL.
     MOVE $BSEG-STCEG TO $ANALITIKA-STCEG.
*++BG 2007.10.29
*  ELSEIF NOT $BSEG-EGBLD IS INITIAL.
   ELSE.
     MOVE LW_KNA1-STCEG TO $ANALITIKA-STCEG.
*       SELECT SINGLE STCEG INTO $ANALITIKA-STCEG
*                           FROM KNAS
*                          WHERE KUNNR EQ $BSEG-KUNNR
*                            AND LAND1 EQ $BSEG-EGBLD.
*--BG 2007.10.29
   ENDIF.
*--0003 BG 2007.09.25

*  Speciális főkönyv kódja
   MOVE $BSEG-UMSKZ TO $ANALITIKA-UMSKZ.
*  Könyvelési kulcs
   MOVE $BSEG-BSCHL TO $ANALITIKA-BSCHL.
*  Kiegyenlítés dátuma
   MOVE $BSEG-AUGDT TO $ANALITIKA-AUGDT.
*++BG 2008.02.19
*  Elmentjük a vállalat kódot
   MOVE $ANALITIKA-BUKRS TO L_SAVE_BUKRS.
*--BG 2008.02.19
*++0006 2008.01.21 BG (FMC)
*++0011 BG 2009.10.29
*  MOVE $BSEG-XREF1+8(4) TO $ANALITIKA-BUKRS.
   M_XREF1 I_AD_BUKRS $BSEG-XREF1 $ANALITIKA-BUKRS.
*--0011 BG 2009.10.29
*--0006 2008.01.21 BG (FMC)
*++BG 2008.02.19
*  Ha a vállalat kód üres visszaírjuk az eredetit
   IF $ANALITIKA-BUKRS IS INITIAL.
     MOVE L_SAVE_BUKRS TO $ANALITIKA-BUKRS.
   ENDIF.
*--BG 2008.02.19

 ENDFORM.                    " get_bseg_kunnr_analitika
**&---------------------------------------------------------------------*
**&      Form  ver_btype_bsznum
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
* FORM VER_BTYPE_BSZNUM.
*
*   MOVE SY-REPID TO V_REPID.
*   LOOP AT I_BTYPE INTO W_BTYPE.
**  Szolgáltatás azonosító ellenőrzése
*     PERFORM VER_BSZNUM   USING P_BUKRS
*                                W_BTYPE-BTYPE
*                                P_BSZNUM
*                                V_REPID
*                       CHANGING V_SUBRC.
*   ENDLOOP.
*
* ENDFORM.                    " ver_btype_bsznum
*&---------------------------------------------------------------------*
*&      Form  GET_VPOP_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_VPOP_LIFNR  text
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
 FORM GET_VPOP_LIFNR  TABLES   $R_VPOP_LIFNR STRUCTURE R_VPOP_LIFNR
*++S4HANA#01.
*                      USING    $BUKRS.
                      USING    $BUKRS TYPE BUKRS.
*--S4HANA#01.

* VPOP szállítók meghatározása
*++S4HANA#01.
*   REFRESH $R_VPOP_LIFNR.
   CLEAR $R_VPOP_LIFNR[].
*--S4HANA#01.

   SELECT LIFNR INTO $R_VPOP_LIFNR-LOW
                FROM /ZAK/VPOP_LIFNR
               WHERE BUKRS EQ $BUKRS.
     M_DEF $R_VPOP_LIFNR 'I' 'EQ' R_VPOP_LIFNR-LOW SPACE.
     CLEAR $R_VPOP_LIFNR.
   ENDSELECT.


 ENDFORM.                    " GET_VPOP_LIFNR
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ANALITIKA0406
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_BSET  text
*      -->P_LW_BKPF  text
*      -->P_LW_BSEG  text
*      -->P_LW_ANALITIKA0406  text
*----------------------------------------------------------------------*
 FORM GET_DATA_ANALITIKA0406  TABLES   $/ZAK/AFA_CUST STRUCTURE /ZAK/AFA_CUST
*++BG 2008.05.27
*++S4HANA#01.
*                                       $I_BTYPE   LIKE I_BTYPE
                                       $I_BTYPE   LIKE GT_I_BTYPE
*--S4HANA#01.
*--BG 2008.05.27
                              USING    $BSET      STRUCTURE BSET
                                       $BKPF      STRUCTURE BKPF
                                       $BSEG      STRUCTURE BSEG
                                       $/ZAK/ANALITIKA  STRUCTURE /ZAK/ANALITIKA
*++S4HANA#01.
*                                       $ANALITIKA_0406 STRUCTURE /ZAK/ANALITIKA
                              CHANGING $ANALITIKA_0406 STRUCTURE /ZAK/ANALITIKA
*--S4HANA#01.
*++BG 2008.05.27
*                                      $BTYPE
*--BG 2008.05.27
                                       .

*  Csak ha VPOP szállító
   CHECK NOT R_VPOP_LIFNR[] IS INITIAL AND $BSEG-LIFNR IN R_VPOP_LIFNR.
*++    CSAK TESZTELÉSHEZ
*        AND SY-SYSID EQ 'MT1'.
*--    CSAK TESZTELÉSHEZ

*++BG 2008.05.27
*  IDŐSZAK meghatározása
   MOVE $BSEG-AUGDT(4)   TO $/ZAK/ANALITIKA-GJAHR.
   MOVE $BSEG-AUGDT+4(2) TO $/ZAK/ANALITIKA-MONAT.

*  BTYPE meghatározás
   READ TABLE $I_BTYPE INTO W_BTYPE
                       WITH KEY GJAHR = $/ZAK/ANALITIKA-GJAHR
                                MONAT = $/ZAK/ANALITIKA-MONAT
                                BINARY SEARCH.


   IF SY-SUBRC NE 0.
     CLEAR W_BTYPE.
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = $/ZAK/ANALITIKA-BUKRS
         I_BTYPART   = P_BTYPAR
         I_GJAHR     = $/ZAK/ANALITIKA-GJAHR
         I_MONAT     = $/ZAK/ANALITIKA-MONAT
       IMPORTING
         E_BTYPE     = W_BTYPE-BTYPE
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
*++BG 2007.04.26
     IF SY-SUBRC NE 0.
       MESSAGE E217 WITH $/ZAK/ANALITIKA-GJAHR
                         $/ZAK/ANALITIKA-MONAT
                         $/ZAK/ANALITIKA-BSEG_BELNR
                         $/ZAK/ANALITIKA-BSEG_GJAHR.
*         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&)

     ELSE.
*--BG 2007.04.26
       MOVE  $/ZAK/ANALITIKA-GJAHR TO W_BTYPE-GJAHR.
       MOVE  $/ZAK/ANALITIKA-MONAT TO W_BTYPE-MONAT.
*++S4HANA#01.
*       APPEND W_BTYPE TO I_BTYPE. SORT I_BTYPE BY GJAHR MONAT.
       APPEND W_BTYPE TO GT_I_BTYPE. SORT GT_I_BTYPE BY GJAHR MONAT.
*--S4HANA#01.
*++BG 2007.04.26
     ENDIF.
*--BG 2007.04.26
   ENDIF.
*--BG 2008.05.27

*  Ellenőrizzük, hogy az adókód létezik-e a beállításban
*++BG 2008.05.27
*  READ TABLE $/ZAK/AFA_CUST WITH KEY BTYPE = $BTYPE
   READ TABLE $/ZAK/AFA_CUST WITH KEY BTYPE = W_BTYPE-BTYPE
*--BG 2008.05.27
                                     MWSKZ = $/ZAK/ANALITIKA-MWSKZ.
   CHECK SY-SUBRC EQ 0.


*  Adatok feltöltése.
   MOVE-CORRESPONDING $/ZAK/ANALITIKA TO $ANALITIKA_0406.

*  Egyéb adatok meghatározása

*  Vámtarifa határozat száma (04,06):
   MOVE $BKPF-XBLNR TO $ANALITIKA_0406-ADOAZON.
*  ABEV azonosító
   MOVE C_ABEVAZ_DUMMY TO $ANALITIKA_0406-ABEVAZ.
*  Megfizetés időpontja (04):
   MOVE $BSEG-AUGDT TO $ANALITIKA_0406-AUGDT.
*  Fizetendő adó összege (04):
   MOVE $BSET-LWSTE TO $ANALITIKA_0406-LWSTE.
*  Fizetett adó összege (04):
   MOVE $ANALITIKA_0406-LWSTE TO $ANALITIKA_0406-FWSTE.
*  Befizetési bizonylat száma (04):
   MOVE $BSEG-AUGBL TO $ANALITIKA_0406-XBLNR.
*  Vámhatározatban szereplő vám érték (06):
   MOVE $BSET-LWBAS TO $ANALITIKA_0406-LWBAS.
*  Vámértéket növelő összeg (06):
   CLEAR $ANALITIKA_0406-FWBAS.

 ENDFORM.                    " GET_DATA_ANALITIKA0406
*&---------------------------------------------------------------------*
*&      Form  change_sign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_BSET  text
*      -->P_W_/ZAK/ANALITIKA  text
*----------------------------------------------------------------------*
 FORM CHANGE_SIGN  USING    $LW_BSET         STRUCTURE BSET
*++S4HANA#01.
*                            $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA.
                   CHANGING $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA.
*--S4HANA#01.


   DATA LW_T007B LIKE T007B.


*    Adólebonyolítás a könyvelésben meghatározása
   SELECT SINGLE * FROM T007B INTO LW_T007B
                  WHERE KTOSL EQ $LW_BSET-KTOSL.

*ha SHKZG=S és T007B-STGRP=2, akkor önmaga
*ha SHKZG=S és T007B-STGRP=1, akkor ellentetje
*ha SHKZG=H és T007B-STGRP=1, akkor önmaga
*ha SHKZG=H és T007B-STGRP=2, akkor ellentetje

*  Adóbázis (adóalap) nemzeti pénznemben tartozik
   IF $LW_BSET-SHKZG EQ 'S'.
     IF LW_T007B-STGRP EQ '2'.
       $W_/ZAK/ANALITIKA-LWBAS = $LW_BSET-LWBAS .
       $W_/ZAK/ANALITIKA-FWBAS = $LW_BSET-FWBAS .
       $W_/ZAK/ANALITIKA-LWSTE = $LW_BSET-LWSTE .
       $W_/ZAK/ANALITIKA-FWSTE = $LW_BSET-FWSTE .
     ELSEIF LW_T007B-STGRP EQ '1'.
       $W_/ZAK/ANALITIKA-LWBAS = $LW_BSET-LWBAS * -1.
       $W_/ZAK/ANALITIKA-FWBAS = $LW_BSET-FWBAS * -1.
       $W_/ZAK/ANALITIKA-LWSTE = $LW_BSET-LWSTE * -1.
       $W_/ZAK/ANALITIKA-FWSTE = $LW_BSET-FWSTE * -1.
     ENDIF.
*  Adóbázis (adóalap) nemzeti pénznemben követel
   ELSEIF $LW_BSET-SHKZG EQ 'H'.
     IF LW_T007B-STGRP EQ '1'.
       $W_/ZAK/ANALITIKA-LWBAS = $LW_BSET-LWBAS .
       $W_/ZAK/ANALITIKA-FWBAS = $LW_BSET-FWBAS .
       $W_/ZAK/ANALITIKA-LWSTE = $LW_BSET-LWSTE .
       $W_/ZAK/ANALITIKA-FWSTE = $LW_BSET-FWSTE .
     ELSEIF LW_T007B-STGRP EQ '2'.
       $W_/ZAK/ANALITIKA-LWBAS = $LW_BSET-LWBAS * -1.
       $W_/ZAK/ANALITIKA-FWBAS = $LW_BSET-FWBAS * -1.
       $W_/ZAK/ANALITIKA-LWSTE = $LW_BSET-LWSTE * -1.
       $W_/ZAK/ANALITIKA-FWSTE = $LW_BSET-FWSTE * -1.
     ENDIF.
   ENDIF.

* Előjel korrekció a standard alapján
   IF ( $W_/ZAK/ANALITIKA-LWBAS GT 0 AND $W_/ZAK/ANALITIKA-LWSTE LT 0 ) OR
         ( $W_/ZAK/ANALITIKA-LWBAS LT 0 AND $W_/ZAK/ANALITIKA-LWSTE GT 0 ).
     $W_/ZAK/ANALITIKA-LWBAS = - $W_/ZAK/ANALITIKA-LWBAS.
     $W_/ZAK/ANALITIKA-FWBAS = - $W_/ZAK/ANALITIKA-FWBAS.
   ENDIF.

*   Bruttó összeg saját pénznemben
   $W_/ZAK/ANALITIKA-HWBTR = $W_/ZAK/ANALITIKA-LWBAS +
                            $W_/ZAK/ANALITIKA-LWSTE .
   $W_/ZAK/ANALITIKA-FWBTR = $W_/ZAK/ANALITIKA-FWBAS +
                            $W_/ZAK/ANALITIKA-FWSTE .

 ENDFORM.                    " change_sign
*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      <--P_V_BUKRS  text
*----------------------------------------------------------------------*
 FORM ROTATE_BUKRS_OUTPUT  TABLES   $I_AD_BUKRS STRUCTURE I_AD_BUKRS
*++S4HANA#01.
*                           USING    $BUKRS
*                                    $BUKRS_OUTPUT.
                            USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                            CHANGING $BUKRS_OUTPUT TYPE BUKRS.
*--S4HANA#01.

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
*      Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPUT)
   ENDIF.

*++0011 BG 2009.10.29
*Meghatározzuk az összes lehetséges értéket ami az XREF1-ben lehet
   SELECT AD_BUKRS INTO TABLE $I_AD_BUKRS
                   FROM /ZAK/BUKRSN
                  WHERE FI_BUKRS EQ $BUKRS_OUTPUT.

*--0011 BG 2009.10.29



 ENDFORM.                    " ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  map_analitika_normal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSEG  text
*      -->P_W_/ZAK/BSET  text
*      -->P_LW_BSET  text
*      -->P_LW_BKPF  text
*----------------------------------------------------------------------*
 FORM MAP_ANALITIKA_NORMAL  TABLES   LI_BSEG     STRUCTURE BSEG
*++0007 BG 2008.05.21
                                     $R_SAKNR    STRUCTURE R_SAKNR
*--0007 BG 2008.05.21
*++0011 BG 2009.10.29
                                     $I_PRCTR    STRUCTURE I_PRCTR
*--0011 BG 2009.10.29
*++2012.04.17 BG (NESS)
                                     $LI_AFA_ELO  STRUCTURE /ZAK/AFA_ELO
*--2012.04.17 BG (NESS)
                            USING    W_/ZAK/BSET  STRUCTURE /ZAK/BSET
                                     LW_BSET     STRUCTURE BSET
                                     LW_BKPF     STRUCTURE BKPF
                                     L_FLAG.

   DATA LW_BSEG TYPE BSEG.
*++1365 #3.
   DATA LW_BSEG_H TYPE BSEG.
*++S4HANA#01.
*   DATA LW_BKPF_H TYPE BKPF.
   TYPES: BEGIN OF TS_LW_BKPF_H_SEL,
            BLART TYPE BKPF-BLART,
            BLDAT TYPE BKPF-BLDAT,
            BUDAT TYPE BKPF-BUDAT,
            XBLNR TYPE BKPF-XBLNR,
          END OF TS_LW_BKPF_H_SEL.
   DATA LW_BKPF_H TYPE TS_LW_BKPF_H_SEL.
*--S4HANA#01.
*--1365 #3.
   DATA L_VPOP_EXIT.
   DATA LW_ANALITIKA_0406 LIKE /ZAK/ANALITIKA.
   DATA L_ADODAT LIKE /ZAK/BSET-ADODAT.
*++0007 BG 2008.05.21
   DATA L_SAVE_BUKRS TYPE BUKRS.
*--0007 BG 2008.05.21
*++2012.04.17 BG (NESS)
   DATA L_ELO_TRUE.
*++S4HANA#01.
   DATA L_ELO_HKONT TYPE HKONT.
   DATA L_ELO_SHKZG TYPE SHKZG.
*--S4HANA#01.
   DATA LW_AFA_ELO TYPE /ZAK/AFA_ELO.
*--2012.04.17 BG (NESS)

*    Most már talán minden megvan lehet mappelni.
*    Vállalat
*++S4HANA#01.
   DATA LT_FAGL_BSEG_TMP TYPE FAGL_T_BSEG.
*--S4HANA#01.s
   MOVE W_/ZAK/BSET-BUKRS TO W_/ZAK/ANALITIKA-BUKRS.
*    Bevallás típus
*    MOVE P_BTYPE TO W_/ZAK/ANALITIKA-BTYPE.

*++0001 2007.01.03 BG (FMC)
*    A BUPER már az adódátum alapján van meghatározva! 2007.01.11.
*    Gazdasági év
   MOVE W_/ZAK/BSET-BUPER(4) TO W_/ZAK/ANALITIKA-GJAHR.
*    Gazdasági hónap
   MOVE W_/ZAK/BSET-BUPER+4(2) TO W_/ZAK/ANALITIKA-MONAT.
*    Tranzakció tipus
   MOVE W_/ZAK/BSET-TTIP TO W_/ZAK/ANALITIKA-TTIP.
*    Adódátum
   MOVE W_/ZAK/BSET-ADODAT TO W_/ZAK/ANALITIKA-ADODAT.
*--0001 2007.01.03 BG (FMC)

*    Adatszolgáltatás azonosító
   MOVE P_BSZNUM TO W_/ZAK/ANALITIKA-BSZNUM.
*    Pénznemkulcs
   MOVE T001-WAERS TO W_/ZAK/ANALITIKA-WAERS.
   MOVE LW_BKPF-WAERS TO W_/ZAK/ANALITIKA-FWAERS.
*    Gazdasági év BSEG
   MOVE LW_BSET-GJAHR TO W_/ZAK/ANALITIKA-BSEG_GJAHR.
*    Könyvelési bizonylat bizonylatszáma
   MOVE LW_BSET-BELNR TO W_/ZAK/ANALITIKA-BSEG_BELNR.
*    Könyvelési sor száma könyvelési bizonylaton belül
   MOVE LW_BSET-BUZEI TO W_/ZAK/ANALITIKA-BSEG_BUZEI.
*    Műveletkulcs
   MOVE LW_BSET-KTOSL TO W_/ZAK/ANALITIKA-KTOSL.
*    Általános forgalmi adó kódja
   MOVE LW_BSET-MWSKZ TO W_/ZAK/ANALITIKA-MWSKZ.
*    Adó százaléka
   M_GET_PACK_TO_NUM LW_BSET-KBETR '3'
                     W_/ZAK/ANALITIKA-KBETR.
   W_/ZAK/ANALITIKA-KBETR = ABS( W_/ZAK/ANALITIKA-KBETR ).
*    Bizonylatfajta
   MOVE LW_BKPF-BLART TO W_/ZAK/ANALITIKA-BLART.
*    Könyvelési dátum a bizonylaton
   MOVE LW_BKPF-BUDAT TO W_/ZAK/ANALITIKA-BUDAT.
*  Bizonylatdátum a bizonylaton
   MOVE LW_BKPF-BLDAT TO W_/ZAK/ANALITIKA-BLDAT.
*  Referenciabizonylat száma
   MOVE LW_BKPF-XBLNR TO W_/ZAK/ANALITIKA-XBLNR.
*  Felhasználó
   MOVE LW_BKPF-USNAM TO W_/ZAK/ANALITIKA-USNAM.

*  Főkönyvi könyvelés főkönyvi számlája
   MOVE LW_BSET-HKONT TO W_/ZAK/ANALITIKA-HKONT.

*  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t.
   IF LW_BSET-LWBAS IS INITIAL.
     MOVE LW_BSET-HWBAS TO LW_BSET-LWBAS.
   ENDIF.
   IF LW_BSET-LWSTE IS INITIAL.
     MOVE LW_BSET-HWSTE TO LW_BSET-LWSTE.
   ENDIF.

*++0004 2007.10.29 BG (FMC)
   MOVE W_/ZAK/BSET-BUKRS TO W_/ZAK/ANALITIKA-FI_BUKRS.
*--0004 2007.10.29 BG (FMC)

*++2012.04.17 BG (NESS)
*  Átmozgatva mivel az előleges tételekhez kell a BTYPE
*  BTYPE meghatározás
*++S4HANA#01.
*   READ TABLE I_BTYPE INTO W_BTYPE
   READ TABLE GT_I_BTYPE INTO W_BTYPE
*--S4HANA#01.
                       WITH KEY GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                MONAT = W_/ZAK/ANALITIKA-MONAT
                                BINARY SEARCH.
   IF SY-SUBRC NE 0.
     CLEAR W_BTYPE.
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = W_/ZAK/ANALITIKA-BUKRS
         I_BTYPART   = P_BTYPAR
         I_GJAHR     = W_/ZAK/ANALITIKA-GJAHR
         I_MONAT     = W_/ZAK/ANALITIKA-MONAT
       IMPORTING
         E_BTYPE     = W_BTYPE-BTYPE
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
*++BG 2007.04.26
     IF SY-SUBRC NE 0.
       MESSAGE E217 WITH W_/ZAK/ANALITIKA-GJAHR
                         W_/ZAK/ANALITIKA-MONAT
                         W_/ZAK/ANALITIKA-BSEG_BELNR
                         W_/ZAK/ANALITIKA-BSEG_GJAHR.
*& év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&)

     ELSE.
*--BG 2007.04.26
       MOVE  W_/ZAK/ANALITIKA-GJAHR TO W_BTYPE-GJAHR.
       MOVE  W_/ZAK/ANALITIKA-MONAT TO W_BTYPE-MONAT.
*++S4HANA#01.
*       APPEND W_BTYPE TO I_BTYPE. SORT I_BTYPE BY GJAHR MONAT.
       APPEND W_BTYPE TO GT_I_BTYPE. SORT GT_I_BTYPE BY GJAHR MONAT.
*--S4HANA#01.
*++BG 2007.04.26
     ENDIF.
*--BG 2007.04.26
   ENDIF.
*--2012.04.17 BG (NESS)

*++0001 2007.01.03 BG (FMC)
*  Üzletág mező meghatározása
   LOOP AT LI_BSEG INTO LW_BSEG
*++0001 2007.01.24 BG (FMC)
*                              WHERE MWSKZ EQ LW_BSET-MWSKZ
*                                    AND GSBER NE SPACE.
                             WHERE GSBER NE SPACE.
*--0001 2007.01.24 BG (FMC)
     MOVE LW_BSEG-GSBER TO  W_/ZAK/ANALITIKA-GSBER.
     EXIT.
   ENDLOOP.

*++0004 2007.10.04  BG (FMC)
*  Profitcenter mező meghatározása
   LOOP AT LI_BSEG INTO LW_BSEG
                  WHERE NOT PRCTR IS INITIAL.
     MOVE LW_BSEG-PRCTR TO W_/ZAK/ANALITIKA-PRCTR.
     EXIT.
   ENDLOOP.

*++0004 2007.12.17  BG (FMC)
   IF NOT W_/ZAK/BSET-ADODAT IS INITIAL.
     MOVE W_/ZAK/BSET-ADODAT TO L_ADODAT.
   ELSE.
     MOVE LW_BKPF-BLDAT TO L_ADODAT.
   ENDIF.
*--0004 2007.12.17  BG (FMC)

*++0011 BG 2009.10.29
*  Profitcenter szerinti vállalat forgatás
   IF NOT $I_PRCTR[]  IS INITIAL.
     LOOP AT $I_PRCTR.
       IF LW_BKPF-BKTXT CS $I_PRCTR-PRCTR.
         MOVE $I_PRCTR-AD_BUKRS TO W_/ZAK/ANALITIKA-BUKRS.
       ENDIF.
     ENDLOOP.
   ENDIF.
*--0011 BG 2009.10.29

*++0007 BG 2008.05.21
*  Főkönyvi szám szerinti vállalat forgatás kezelés
   IF NOT $R_SAKNR IS INITIAL.
     LOOP AT LI_BSEG INTO LW_BSEG WHERE HKONT IN $R_SAKNR.
*      Elmentjük a vállalat kódot
       MOVE W_/ZAK/ANALITIKA-BUKRS TO L_SAVE_BUKRS.
*++0011 BG 2009.10.29
*      MOVE LW_BSEG-XREF1+8(4) TO W_/ZAK/ANALITIKA-BUKRS.
       M_XREF1 I_AD_BUKRS LW_BSEG-XREF1 W_/ZAK/ANALITIKA-BUKRS.
*--0011 BG 2009.10.29
*      Ha a vállalat kód üres visszaírjuk az eredetit
       IF W_/ZAK/ANALITIKA-BUKRS IS INITIAL.
         MOVE L_SAVE_BUKRS TO W_/ZAK/ANALITIKA-BUKRS.
       ENDIF.
       EXIT.
     ENDLOOP.
   ENDIF.
*--0007 BG 2008.05.21

*--0001 2007.01.03 BG (FMC)
*  Szállítói láb megkeresése
*  Első szelekció UMSKZ-re
   LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL
                                  AND NOT UMSKZ IS INITIAL.
*++0002 BG 2007.05.29
*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a
*    rekord.
     IF NOT R_VPOP_LIFNR[] IS INITIAL AND
        LW_BSEG-LIFNR IN R_VPOP_LIFNR AND
        LW_BSEG-AUGDT IS INITIAL.
       MOVE 'X' TO L_VPOP_EXIT.
       EXIT.
     ENDIF.
*--0002 BG 2007.05.29
*    BSEG adatok szállító feltötése
     PERFORM GET_BSEG_LIFNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                            W_/ZAK/ANALITIKA.
                                   CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
*++2012.04.17 BG (NESS)
*    Előleg tételek keresése
     PERFORM GET_ELO_FLAG  TABLES $LI_AFA_ELO
                           USING  LW_BKPF
                                  LW_BSEG
                                  W_BTYPE-BTYPE
*++S4HANA#01.
*                                  L_ELO_TRUE.
                         CHANGING L_ELO_HKONT
                                  L_ELO_SHKZG
                                  L_ELO_TRUE.
*--S4HANA#01.
*--2012.04.17 BG (NESS)
*++0002 BG 2007.05.29
     PERFORM GET_DATA_ANALITIKA0406 TABLES I_/ZAK/AFA_CUST
*++BG 2008.05.27
                                           GT_I_BTYPE
*--BG 2008.05.27
                                    USING  LW_BSET
                                           LW_BKPF
                                           LW_BSEG
                                           W_/ZAK/ANALITIKA
                                           LW_ANALITIKA_0406
*++BG 2008.05.27
*                                          W_BTYPE-BTYPE
*--BG 2008.05.27
                                           .
*--0002 BG 2007.05.29

   ENDLOOP.

*  Nincs kitöltött UMSKZ az első tétel kell amin van szállító kód
   IF SY-SUBRC NE 0.
     LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL.
*++0002 BG 2007.05.29
*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a
*    rekord.
       IF NOT R_VPOP_LIFNR[] IS INITIAL AND
          LW_BSEG-LIFNR IN R_VPOP_LIFNR AND
          LW_BSEG-AUGDT IS INITIAL.
         MOVE 'X' TO L_VPOP_EXIT.
         EXIT.
       ENDIF.
*--0002 BG 2007.05.29

*      BSEG adatok szállító feltötése
       PERFORM GET_BSEG_LIFNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                           W_/ZAK/ANALITIKA.
                                     CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
*++2012.04.17 BG (NESS)
*      Előleg tételek keresése
       PERFORM GET_ELO_FLAG  TABLES $LI_AFA_ELO
                             USING  LW_BKPF
                                    LW_BSEG
                                    W_BTYPE-BTYPE
*++S4HANA#01.
*                                    L_ELO_TRUE.
                           CHANGING L_ELO_HKONT
                                    L_ELO_SHKZG
                                    L_ELO_TRUE.
*--S4HANA#01.
*--2012.04.17 BG (NESS)
*++0002 BG 2007.05.29
       PERFORM GET_DATA_ANALITIKA0406 TABLES I_/ZAK/AFA_CUST
*++BG 2008.05.27
*++S4HANA#01.
*                                             I_BTYPE
                                             GT_I_BTYPE
*--S4HANA#01.
*--BG 2008.05.27
                                      USING  LW_BSET
                                             LW_BKPF
                                             LW_BSEG
                                             W_/ZAK/ANALITIKA
                                             LW_ANALITIKA_0406
*++BG 2008.05.27
*                                            W_BTYPE-BTYPE
*--BG 2008.05.27
                                             .
*--0002 BG 2007.05.29
       EXIT.
     ENDLOOP.
*++1365 #3.
*    Halasztott ÁFA kezelés
*++1365 #4.
*      IF SY-SUBRC EQ 0.
*++1365 #8.
*      IF SY-SUBRC EQ 0 AND LW_BKPF-XBLNR(12) CA '0123456789'.
     IF SY-SUBRC NE 0 AND LW_BKPF-XBLNR(12) CO '0123456789'.
*--1365 #8.
*--1365 #4.
*    ÁFA kód ellenőrzés (LW_BSET-MWSKZ)
       SELECT SINGLE COUNT( * ) FROM T007A
                               WHERE ZMWSK EQ LW_BSET-MWSKZ.
*       Halasztott ÁFA-s adókód
       IF SY-SUBRC EQ 0.
         CLEAR LW_BSEG_H.
         LW_BSEG_H-BELNR = LW_BKPF-XBLNR(10).
         IF LW_BKPF-XBLNR+10(2) > 80.
           LW_BSEG_H-GJAHR = 1900 + LW_BKPF-XBLNR+10(2).
         ELSE.
           LW_BSEG_H-GJAHR = 2000 + LW_BKPF-XBLNR+10(2).
         ENDIF.
*        Referencia bizonylat beolvasása, az első tétel kell amiben van
*        szállító
*++S4HANA#01.
*         SELECT SINGLE * INTO LW_BSEG_H
*                         FROM BSEG
*                        WHERE BUKRS EQ LW_BKPF-BUKRS
*                          AND BELNR EQ LW_BSEG_H-BELNR
*                          AND GJAHR EQ LW_BSEG_H-GJAHR
*                          AND LIFNR NE ''.
         CL_FAGL_EMU_CVRT_SERVICES=>GET_LEADING_LEDGER(
              IMPORTING
                ED_RLDNR = DATA(LV_RLDNR)
              EXCEPTIONS
                ERROR  = 4
                OTHERS = 4 ).
         IF SY-SUBRC = 0.
           CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'
             EXPORTING
               I_RLDNR   = LV_RLDNR
               I_BUKRS   = LW_BKPF-BUKRS
               I_BELNR   = LW_BSEG_H-BELNR
               I_GJAHR   = LW_BSEG_H-GJAHR
             IMPORTING
               ET_BSEG   = LT_FAGL_BSEG_TMP
             EXCEPTIONS
               NOT_FOUND = 4
               OTHERS    = 4.
           IF SY-SUBRC = 0.
             DATA(LT_FAGL_BSEG_FILTER) = VALUE FAGL_T_BSEG(
                 FOR LS_PP IN LT_FAGL_BSEG_TMP
                 WHERE ( LIFNR <> '' )
                 ( LS_PP ) ).
             IF LT_FAGL_BSEG_FILTER IS NOT INITIAL.
               SORT LT_FAGL_BSEG_FILTER BY BUZEI.
               LW_BSEG_H = CORRESPONDING #( BASE ( LW_BSEG_H ) LT_FAGL_BSEG_FILTER[ 1 ]
                 MAPPING BUKRS = BUKRS BELNR = BELNR GJAHR = GJAHR
                         AUGDT = AUGDT AUGBL = AUGBL BSCHL = BSCHL
                         KOART = KOART UMSKZ = UMSKZ SHKZG = SHKZG
                         GSBER = GSBER MWSKZ = MWSKZ ZUONR = ZUONR
                         HKONT = HKONT KUNNR = KUNNR LIFNR = LIFNR
                         ZFBDT = ZFBDT STCEG = STCEG PRCTR = PRCTR
                         XREF1 = XREF1 AUGGJ = AUGGJ
                 EXCEPT * ).
             ELSE.
               SY-SUBRC = 4 ##WRITE_OK.
             ENDIF.
             FREE: LT_FAGL_BSEG_TMP, LT_FAGL_BSEG_FILTER.
           ENDIF.
         ENDIF.
*--S4HANA#01.
         IF SY-SUBRC EQ 0.
*          BSEG adatok szállító feltötése
           PERFORM GET_BSEG_LIFNR_ANALITIKA USING LW_BSEG_H
*++S4HANA#01.
*                                               W_/ZAK/ANALITIKA.
                                         CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
*          Fejadat beolvasása
           CLEAR LW_BKPF_H.
*++S4HANA#01.
*           SELECT SINGLE * INTO LW_BKPF_H
           SELECT SINGLE BLART BLDAT BUDAT XBLNR INTO LW_BKPF_H
*--S4HANA#01.
                        FROM BKPF
                       WHERE BUKRS EQ LW_BKPF-BUKRS
                         AND BELNR EQ LW_BSEG_H-BELNR
                         AND GJAHR EQ LW_BSEG_H-GJAHR.

           MOVE LW_BKPF_H-XBLNR TO  W_/ZAK/ANALITIKA-XBLNR.
           MOVE LW_BKPF_H-BLART TO  W_/ZAK/ANALITIKA-BLART.
           MOVE LW_BKPF_H-BUDAT TO  W_/ZAK/ANALITIKA-BUDAT.
           MOVE LW_BKPF_H-BLDAT TO  W_/ZAK/ANALITIKA-BLDAT.
         ENDIF.
       ENDIF.
     ENDIF.
*--1365 #3.
   ENDIF.

*++0002 BG 2007.05.29
*  Ha nem kell feldolgozni, töröljük a rekordot.
   IF NOT L_VPOP_EXIT IS INITIAL.
*++0005 BG 2007.12.12
*    DELETE I_/ZAK/BSET.
*    CONTINUE.
     MOVE 'D' TO L_FLAG.
     EXIT.
*--0005 BG 2007.12.12
   ENDIF.
*--0002 BG 2007.05.29

*  Vevői láb megkeresése  Első szelekció UMSKZ-re
   LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL
                                  AND NOT UMSKZ IS INITIAL.
*      BSEG adatok szállító feltötése
     PERFORM GET_BSEG_KUNNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                    W_/ZAK/ANALITIKA.
                                   CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
*++2012.04.17 BG (NESS)
*    Előleg tételek keresése
     PERFORM GET_ELO_FLAG  TABLES $LI_AFA_ELO
                           USING  LW_BKPF
                                  LW_BSEG
                                  W_BTYPE-BTYPE
*++S4HANA#01.
*                                  L_ELO_TRUE.
                         CHANGING L_ELO_HKONT
                                  L_ELO_SHKZG
                                  L_ELO_TRUE.
*--S4HANA#01.
*--2012.04.17 BG (NESS)
   ENDLOOP.
*  Nincs kitöltött UMSKZ az első tétel kell amin van vevő kód
   IF SY-SUBRC NE 0.
     LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL.
*        BSEG adatok vevő feltötése
       PERFORM GET_BSEG_KUNNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                              W_/ZAK/ANALITIKA.
                                     CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
*++2012.04.17 BG (NESS)
*      Előleg tételek keresése
       PERFORM GET_ELO_FLAG  TABLES $LI_AFA_ELO
                             USING  LW_BKPF
                                    LW_BSEG
                                    W_BTYPE-BTYPE
*++S4HANA#01.
*                                    L_ELO_TRUE.
                           CHANGING L_ELO_HKONT
                                    L_ELO_SHKZG
                                    L_ELO_TRUE.
*--S4HANA#01.
*--2012.04.17 BG (NESS)
       EXIT.
     ENDLOOP.
   ENDIF.

   CALL FUNCTION '/ZAK/ROTATE_BUKRS_INPUT'
     EXPORTING
       I_FI_BUKRS    = W_/ZAK/BSET-BUKRS
*++0006 2008.01.21 BG (FMC)
       I_AD_BUKRS    = W_/ZAK/ANALITIKA-BUKRS
*--0006 2008.01.21 BG (FMC)
*++0004 2007.12.17  BG (FMC)
*      I_DATE        = W_/ZAK/BSET-ADODAT
       I_DATE        = L_ADODAT
*--0004 2007.12.17  BG (FMC)
*++0006 2008.01.21 BG (FMC)
*      I_GSBER       = W_/ZAK/ANALITIKA-GSBER
*      I_PRCTR       = W_/ZAK/ANALITIKA-PRCTR
*--0006 2008.01.21 BG (FMC)
     IMPORTING
       E_AD_BUKRS    = W_/ZAK/ANALITIKA-BUKRS
     EXCEPTIONS
       MISSING_INPUT = 1
       OTHERS        = 2.
   IF SY-SUBRC <> 0.
     MESSAGE E232 WITH W_/ZAK/BSET-BUKRS.
*        Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_INPUT)
   ENDIF.

   IF W_/ZAK/ANALITIKA-BUKRS NE P_BUKRS.
*     DELETE I_/ZAK/BSET.
*     CONTINUE.
     MOVE 'D' TO L_FLAG.
     EXIT.
   ENDIF.


*++0006 2008.01.21 BG (FMC)
**    IDŐSZAK forgatás
*   CALL FUNCTION '/ZAK/ROTATE_IDSZ'
*     EXPORTING
*       I_BUKRS             = W_/ZAK/ANALITIKA-BUKRS
*       I_GJAHR             = W_/ZAK/ANALITIKA-GJAHR
*       I_MONAT             = W_/ZAK/ANALITIKA-MONAT
*       I_GSBER             = W_/ZAK/ANALITIKA-GSBER
*       I_KTOSL             = W_/ZAK/ANALITIKA-KTOSL
**      I_PRCTR             =
*     IMPORTING
*       E_GJAHR             = W_/ZAK/ANALITIKA-GJAHR
*       E_MONAT             = W_/ZAK/ANALITIKA-MONAT
*     EXCEPTIONS
*       MISSING_INPUT       = 1
*       OTHERS              = 2
*             .
*   IF SY-SUBRC <> 0.
*     MESSAGE E233 WITH W_/ZAK/ANALITIKA-BUKRS.
**        Hiba a & vállalat időszak forgatás meghatározásnál! (/ZAK/ROTATE_IDSZ)
*   ENDIF.
*--0006 2008.01.21 BG (FMC)

**    Ha MA01 a vállalat kód és az üzletág 2, akkor MMOB-ra tesszük
*     IF W_/ZAK/BSET-BUKRS EQ 'MA01' AND
*        P_BUKRS EQ 'MA01' AND
*        W_/ZAK/ANALITIKA-GSBER = '2' AND
**++BG 2007.05.22
**       W_/ZAK/BSET-ADODAT < '20060228'.
*        W_/ZAK/BSET-ADODAT < '20060301'.
**--BG 2007.05.22
*       DELETE I_/ZAK/BSET.
*       CONTINUE.
**++0004 2007.10.04  BG (FMC)
*
*       IF W_/ZAK/BSET-BUKRS EQ 'MA01' AND
*          P_BUKRS EQ 'MMOB' AND
*          W_/ZAK/ANALITIKA-GSBER = '2' AND
**++BG 2007.05.22
**       W_/ZAK/BSET-ADODAT < '20060228'.
*          W_/ZAK/BSET-ADODAT < '20060301'.
**--BG 2007.05.22
*         MOVE 'MMOB' TO W_/ZAK/ANALITIKA-BUKRS.
*       ENDIF.
*     ENDIF.
*--0004 2007.10.04  BG (FMC)
*++2012.04.17 BG (NESS)
**  BTYPE meghatározás
*   READ TABLE I_BTYPE INTO W_BTYPE
*                       WITH KEY GJAHR = W_/ZAK/ANALITIKA-GJAHR
*                                MONAT = W_/ZAK/ANALITIKA-MONAT
*                                BINARY SEARCH.
*   IF SY-SUBRC NE 0.
*     CLEAR W_BTYPE.
*     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
*       EXPORTING
*         I_BUKRS     = W_/ZAK/ANALITIKA-BUKRS
*         I_BTYPART   = P_BTYPAR
*         I_GJAHR     = W_/ZAK/ANALITIKA-GJAHR
*         I_MONAT     = W_/ZAK/ANALITIKA-MONAT
*       IMPORTING
*         E_BTYPE     = W_BTYPE-BTYPE
*       EXCEPTIONS
*         ERROR_MONAT = 1
*         ERROR_BTYPE = 2
*         OTHERS      = 3.
**++BG 2007.04.26
*     IF SY-SUBRC NE 0.
*       MESSAGE E217 WITH W_/ZAK/ANALITIKA-GJAHR
*                         W_/ZAK/ANALITIKA-MONAT
*                         W_/ZAK/ANALITIKA-BSEG_BELNR
*                         W_/ZAK/ANALITIKA-BSEG_GJAHR.
**         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&)
*
*     ELSE.
**--BG 2007.04.26
*       MOVE  W_/ZAK/ANALITIKA-GJAHR TO W_BTYPE-GJAHR.
*       MOVE  W_/ZAK/ANALITIKA-MONAT TO W_BTYPE-MONAT.
*       APPEND W_BTYPE TO I_BTYPE. SORT I_BTYPE BY GJAHR MONAT.
**++BG 2007.04.26
*     ENDIF.
**--BG 2007.04.26
*   ENDIF.
*--2012.04.17 BG (NESS)

*++0002 BG 2007.09.25
   PERFORM CHANGE_SIGN USING LW_BSET
*++S4HANA#01.
*                             W_/ZAK/ANALITIKA.
                    CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.

**    Adólebonyolítás a könyvelésben meghatározása
*     SELECT SINGLE * FROM T007B INTO LW_T007B
*                    WHERE KTOSL EQ LW_BSET-KTOSL.
*
**ha SHKZG=S és T007B-STGRP=2, akkor önmaga
**ha SHKZG=S és T007B-STGRP=1, akkor ellentetje
**ha SHKZG=H és T007B-STGRP=1, akkor önmaga
**ha SHKZG=H és T007B-STGRP=2, akkor ellentetje
*
**    Adóbázis (adóalap) nemzeti pénznemben tartozik
*     IF LW_BSET-SHKZG EQ 'S'.
*       IF LW_T007B-STGRP EQ '2'.
*         W_/ZAK/ANALITIKA-LWBAS = LW_BSET-LWBAS .
*         W_/ZAK/ANALITIKA-FWBAS = LW_BSET-FWBAS .
*         W_/ZAK/ANALITIKA-LWSTE = LW_BSET-LWSTE .
*         W_/ZAK/ANALITIKA-FWSTE = LW_BSET-FWSTE .
*       ELSEIF LW_T007B-STGRP EQ '1'.
*         W_/ZAK/ANALITIKA-LWBAS = LW_BSET-LWBAS * -1.
*         W_/ZAK/ANALITIKA-FWBAS = LW_BSET-FWBAS * -1.
*         W_/ZAK/ANALITIKA-LWSTE = LW_BSET-LWSTE * -1.
*         W_/ZAK/ANALITIKA-FWSTE = LW_BSET-FWSTE * -1.
*       ENDIF.
**    Adóbázis (adóalap) nemzeti pénznemben követel
*     ELSEIF LW_BSET-SHKZG EQ 'H'.
*       IF LW_T007B-STGRP EQ '1'.
*         W_/ZAK/ANALITIKA-LWBAS = LW_BSET-LWBAS .
*         W_/ZAK/ANALITIKA-FWBAS = LW_BSET-FWBAS .
*         W_/ZAK/ANALITIKA-LWSTE = LW_BSET-LWSTE .
*         W_/ZAK/ANALITIKA-FWSTE = LW_BSET-FWSTE .
*       ELSEIF LW_T007B-STGRP EQ '2'.
*         W_/ZAK/ANALITIKA-LWBAS = LW_BSET-LWBAS * -1.
*         W_/ZAK/ANALITIKA-FWBAS = LW_BSET-FWBAS * -1.
*         W_/ZAK/ANALITIKA-LWSTE = LW_BSET-LWSTE * -1.
*         W_/ZAK/ANALITIKA-FWSTE = LW_BSET-FWSTE * -1.
*       ENDIF.
*     ENDIF.
*
** Előjel korrekció a standard alapján
*     IF ( W_/ZAK/ANALITIKA-LWBAS GT 0 AND W_/ZAK/ANALITIKA-LWSTE LT 0 ) OR
*           ( W_/ZAK/ANALITIKA-LWBAS LT 0 AND W_/ZAK/ANALITIKA-LWSTE GT 0 ).
*       W_/ZAK/ANALITIKA-LWBAS = - W_/ZAK/ANALITIKA-LWBAS.
*       W_/ZAK/ANALITIKA-FWBAS = - W_/ZAK/ANALITIKA-FWBAS.
*     ENDIF.
*
*
**   Bruttó összeg saját pénznemben
*     W_/ZAK/ANALITIKA-HWBTR = W_/ZAK/ANALITIKA-LWBAS +
*                             W_/ZAK/ANALITIKA-LWSTE .
*     W_/ZAK/ANALITIKA-FWBTR = W_/ZAK/ANALITIKA-FWBAS +
*                             W_/ZAK/ANALITIKA-FWSTE .

*--0002 BG 2007.09.25


*  AFA customizing beolvasása
   LOOP AT I_/ZAK/AFA_CUST INTO W_/ZAK/AFA_CUST
                         WHERE
*                                bukrs EQ p_bukrs AND
                               BTYPE EQ W_BTYPE-BTYPE
                           AND MWSKZ EQ W_/ZAK/ANALITIKA-MWSKZ.

*      Ha ki van töltve a műveletkulcs, akkor erre is ellenőrzünk
     IF NOT W_/ZAK/AFA_CUST-KTOSL IS INITIAL AND
            W_/ZAK/AFA_CUST-KTOSL NE LW_BSET-KTOSL.
       CONTINUE.
     ENDIF.

     IF W_/ZAK/AFA_CUST-ATYPE EQ 'A'.
*         m_get_pack_to_num w_/zak/analitika-lwbas w_/zak/analitika-waers
*                           w_/zak/analitika-field_n.
       MOVE W_/ZAK/ANALITIKA-LWBAS TO W_/ZAK/ANALITIKA-FIELD_N.
     ELSEIF W_/ZAK/AFA_CUST-ATYPE EQ 'B'.
*         m_get_pack_to_num w_/zak/analitika-lwste w_/zak/analitika-waers
*                           w_/zak/analitika-field_n.
       MOVE W_/ZAK/ANALITIKA-LWSTE TO W_/ZAK/ANALITIKA-FIELD_N.
     ENDIF.

*    ABEV azonosító
     MOVE W_/ZAK/AFA_CUST-ABEVAZ TO W_/ZAK/ANALITIKA-ABEVAZ.

*    PERFORM GET_ANALITIKA_ITEM TABLES I_/ZAK/ANALITIKA
*                               USING  W_/ZAK/ANALITIKA.

     APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
   ENDLOOP.

*++0002 BG 2007.05.29
*  Ha van adat a 04 vagy 06-os laphoz:
   IF NOT LW_ANALITIKA_0406 IS INITIAL.
*++0002 BG 2007.09.25
     PERFORM CHANGE_SIGN USING LW_BSET
*++S4HANA#01.
*                               LW_ANALITIKA_0406.
                      CHANGING LW_ANALITIKA_0406.
*--S4HANA#01.
*--0002 BG 2007.09.25
     APPEND LW_ANALITIKA_0406 TO I_/ZAK/ANALITIKA.
   ENDIF.
*--0002 BG 2007.05.29

*++2012.04.17 BG (NESS)
*  Ha van előleg tétel, akkor ezek kezelése
   IF NOT L_ELO_TRUE IS INITIAL.
     LOOP AT $LI_AFA_ELO INTO LW_AFA_ELO
                        WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
                          AND BTYPE EQ W_BTYPE-BTYPE
                          AND BLART EQ W_/ZAK/ANALITIKA-BLART
                          AND MWSKZ EQ W_/ZAK/ANALITIKA-MWSKZ.
       IF LW_AFA_ELO-ATYPE EQ 'A'.
         MOVE W_/ZAK/ANALITIKA-LWBAS TO W_/ZAK/ANALITIKA-FIELD_N.
       ELSEIF LW_AFA_ELO-ATYPE EQ 'B'.
         MOVE W_/ZAK/ANALITIKA-LWSTE TO W_/ZAK/ANALITIKA-FIELD_N.
       ENDIF.
       IF NOT LW_AFA_ELO-SIGN IS INITIAL.
         MULTIPLY W_/ZAK/ANALITIKA-FIELD_N BY -1.
       ENDIF.
       MOVE  LW_AFA_ELO-ABEVAZ TO W_/ZAK/ANALITIKA-ABEVAZ.
       APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
     ENDLOOP.
   ENDIF.
*--2012.04.17 BG (NESS)

 ENDFORM.                    " map_analitika_normal
*&---------------------------------------------------------------------*
*&      Form  GET_ARANY_IDSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_ARANY_IDSZ  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPAR  text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM GET_ARANY_IDSZ  USING    $W_ARANY_IDSZ TYPE T_ARANY_IDSZ
*                               $W_/ZAK/BEVALL STRUCTURE /ZAK/BEVALL
*                               $BUKRS
*                               $BTYPAR.
 FORM GET_ARANY_IDSZ  USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                              $BTYPAR TYPE /ZAK/BEVALL-BTYPART
                   CHANGING   $W_ARANY_IDSZ TYPE T_ARANY_IDSZ
                              $W_/ZAK/BEVALL STRUCTURE /ZAK/BEVALL.
*--S4HANA#01.

   DATA L_GJAHR TYPE GJAHR.
   DATA L_MONAT TYPE MONAT.

   DEFINE LM_FILL_ARANY_IDSZ.
     MOVE &1-BUKRS TO $W_ARANY_IDSZ-BUKRS.
     MOVE &1-BTYPE TO $W_ARANY_IDSZ-BTYPE.
     MOVE &2 TO $W_ARANY_IDSZ-GJAHR.
     MOVE &3 TO $W_ARANY_IDSZ-MONAT.
     MOVE '000' TO $W_ARANY_IDSZ-ZINDEX.
   END-OF-DEFINITION.

*  Maghatározzuk az utolsó bevallás típust
   SELECT * INTO $W_/ZAK/BEVALL
                 UP TO 1 ROWS
            FROM /ZAK/BEVALL
           WHERE BUKRS   EQ $BUKRS
             AND BTYPART EQ $BTYPAR
             ORDER BY DATBI DESCENDING.
   ENDSELECT.
   IF SY-SUBRC EQ 0.

*  Legnagyobb lezárt időszak meghatározása
     SELECT MAX( GJAHR ) MAX( MONAT ) INTO (L_GJAHR, L_MONAT)
            FROM /ZAK/BEVALLI
           WHERE BUKRS EQ $BUKRS
             AND BTYPE EQ $W_/ZAK/BEVALL-BTYPE
             AND ( FLAG = 'Z' OR FLAG = 'X' )
             AND ZINDEX EQ '000'
             GROUP BY BUKRS GJAHR MONAT.
     ENDSELECT.
     IF SY-SUBRC EQ 0.
       ADD 1 TO L_MONAT.

*++0010 2008.01.14 BG
*    Mivel előtte adunk hozzá egyet ezért a 11. hó után
*    nem felelt meg a feltétel
*       Adott évben van
*       IF L_MONAT < 12.
       IF L_MONAT <= 12.
*--0010 2008.01.14 BG
         LM_FILL_ARANY_IDSZ $W_/ZAK/BEVALL L_GJAHR L_MONAT .
*       Következő évben van
       ELSE.
         L_MONAT = '01'.
         ADD 1 TO L_GJAHR.
         LM_FILL_ARANY_IDSZ $W_/ZAK/BEVALL L_GJAHR L_MONAT .
       ENDIF.
*    Nincs még az évben az időszak kezdő értékére tesszük
     ELSE.
       MOVE $W_/ZAK/BEVALL-DATAB(4)   TO L_GJAHR.
       MOVE $W_/ZAK/BEVALL-DATAB+4(2) TO L_MONAT.
       LM_FILL_ARANY_IDSZ $W_/ZAK/BEVALL L_GJAHR L_MONAT .
     ENDIF.
   ENDIF.


 ENDFORM.                    " GET_ARANY_IDSZ
*&---------------------------------------------------------------------*
*&      Form  GET_ARANY_MWSKZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALL  text
*      -->P_LW_BSET  text
*      <--P_L_MODE  text
*----------------------------------------------------------------------*
 FORM GET_ARANY_MWSKZ  USING    $BEVALL       STRUCTURE /ZAK/BEVALL
                                $BSET         STRUCTURE BSET
                       CHANGING $MODE.

   RANGES LR_KTOSL FOR BSET-KTOSL.

   DEFINE LM_GET_KTOSL.
     REFRESH LR_KTOSL.
     LOOP AT &1 INTO W_MWSKZ
                       WHERE MWSKZ = $BSET-MWSKZ.
       IF NOT W_MWSKZ-KTOSL IS INITIAL.
         M_DEF LR_KTOSL 'I' 'EQ' W_MWSKZ-KTOSL SPACE.
       ENDIF.
     ENDLOOP.
   END-OF-DEFINITION.

*   Alapesetben normál mód
   $MODE = 'N'.

   CHECK NOT $BEVALL-ARTYPE IS INITIAL.

*++S4HANA#01.
*   IF I_MWSKZ[] IS INITIAL.
   IF GT_I_MWSKZ[] IS INITIAL.
*--S4HANA#01.
*  Részben arányosított
     IF $BEVALL-ARTYPE EQ C_ARTYPE_R.
*      Adókódok meghatározása
*++S4HANA#01.
*       SELECT * INTO CORRESPONDING FIELDS OF TABLE I_MWSKZ
       SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_I_MWSKZ
*--S4HANA#01.
                FROM /ZAK/AFA_RARANY
               WHERE BUKRS = $BEVALL-BUKRS.
       IF SY-SUBRC NE 0.
         MESSAGE E239 WITH $BEVALL-BUKRS.
*   & részben arányositott vállalathoz nincs beállítva adókód!
       ENDIF.
*  Teljesen arányosított
     ELSEIF $BEVALL-ARTYPE EQ C_ARTYPE_A.
*  Adókódok meghatározása
*++S4HANA#01.
*       SELECT * INTO CORRESPONDING FIELDS OF TABLE I_MWSKZ
       SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_I_MWSKZ
*--S4HANA#01.
                FROM /ZAK/AFA_CUST
               WHERE BTYPE = $BEVALL-BTYPE
                 AND ATYPE = C_ATYPE_A.
       IF SY-SUBRC NE 0.
         MESSAGE E032.
*       Hiba az ÁFA beállítások meghatározásánál!
       ENDIF.
     ENDIF.
*++S4HANA#01.
*     SORT I_MWSKZ.
     SORT GT_I_MWSKZ.
*--S4HANA#01.
   ENDIF.

*  ÁFA kód ellenőrzése
*++S4HANA#01.
*   READ TABLE I_MWSKZ TRANSPORTING NO FIELDS
   READ TABLE GT_I_MWSKZ TRANSPORTING NO FIELDS
*--S4HANA#01.
              WITH KEY MWSKZ = $BSET-MWSKZ
              BINARY SEARCH.

*  ÁFA kód arányosított, KTOSL ellenőrzés
   IF SY-SUBRC EQ 0.
*     LM_GET_KTOSL I_MWSKZ.
     LM_GET_KTOSL GT_I_MWSKZ.
     IF $BSET-KTOSL IN LR_KTOSL.
       MOVE 'A' TO $MODE.
     ENDIF.
   ENDIF.

 ENDFORM.                    " GET_ARANY_MWSKZ
*&---------------------------------------------------------------------*
*&      Form  MAP_ANALITIKA_ARANY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_BSEG  text
*      -->P_W_/ZAK/BSET  text
*      -->P_LW_BSET  text
*      -->P_LW_BKPF  text
*      -->P_L_FLAG  text
*----------------------------------------------------------------------*
 FORM MAP_ANALITIKA_ARANY  TABLES   LI_BSEG      STRUCTURE BSEG
                           USING    W_/ZAK/BEVALL STRUCTURE /ZAK/BEVALL
                                    W_ARANY_IDSZ TYPE T_ARANY_IDSZ
                                    W_/ZAK/BSET   STRUCTURE /ZAK/BSET
                                    LW_BSET      STRUCTURE BSET
                                    LW_BKPF      STRUCTURE BKPF
                                    L_FLAG.

   DATA LW_BSEG TYPE BSEG.
   DATA L_VPOP_EXIT.
   DATA LW_ANALITIKA_0406 LIKE /ZAK/ANALITIKA.
   DATA L_VPOP.
*++0008 2008.09.01 BG
   DATA L_ADODAT LIKE /ZAK/BSET-ADODAT.
*--0008 2008.09.01 BG
*++0012 1065 2010.02.04 BG
   DATA LW_BNYLAP TYPE /ZAK/BNYLAP.
   DATA L_LAST_DAY LIKE SY-DATUM.
   DATA L_ARANYF TYPE /ZAK/ARANYF.
*--0012 1065 2010.02.04 BG



   IF I_/ZAK/AFA_ARABEV[] IS INITIAL.
     SELECT * INTO TABLE I_/ZAK/AFA_ARABEV
              FROM /ZAK/AFA_ARABEV
             WHERE BTYPE EQ W_/ZAK/BEVALL-BTYPE.
     IF SY-SUBRC NE 0.
       MESSAGE E244 WITH W_/ZAK/BEVALL-BTYPE.
*   Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók!
     ENDIF.
   ENDIF.

   IF W_ARANY_IDSZ IS INITIAL.
     MESSAGE E245.
*   Nem határozható meg időszak arányosított ÁFA kezeléshez!
   ENDIF.

*  Most már talán minden megvan lehet mappelni.
*  Vállalat
   MOVE W_/ZAK/BSET-BUKRS TO W_/ZAK/ANALITIKA-BUKRS.
*  Bevallás típus
   MOVE W_ARANY_IDSZ-BTYPE TO W_/ZAK/ANALITIKA-BTYPE.
*  Év
   MOVE W_ARANY_IDSZ-GJAHR TO W_/ZAK/ANALITIKA-GJAHR.
*  Hónap
   MOVE W_ARANY_IDSZ-MONAT TO W_/ZAK/ANALITIKA-MONAT.
*  Bevallás sorszáma időszakon belül
   MOVE W_ARANY_IDSZ-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
*    Tranzakció tipus
   MOVE W_/ZAK/BSET-TTIP TO W_/ZAK/ANALITIKA-TTIP.
*    Adódátum
   MOVE W_/ZAK/BSET-ADODAT TO W_/ZAK/ANALITIKA-ADODAT.
*    Adatszolgáltatás azonosító
   MOVE P_BSZNUM TO W_/ZAK/ANALITIKA-BSZNUM.
*    Pénznemkulcs
   MOVE T001-WAERS TO W_/ZAK/ANALITIKA-WAERS.
   MOVE LW_BKPF-WAERS TO W_/ZAK/ANALITIKA-FWAERS.
*    Gazdasági év BSEG
   MOVE LW_BSET-GJAHR TO W_/ZAK/ANALITIKA-BSEG_GJAHR.
*    Könyvelési bizonylat bizonylatszáma
   MOVE LW_BSET-BELNR TO W_/ZAK/ANALITIKA-BSEG_BELNR.
*    Könyvelési sor száma könyvelési bizonylaton belül
   MOVE LW_BSET-BUZEI TO W_/ZAK/ANALITIKA-BSEG_BUZEI.
*    Műveletkulcs
   MOVE LW_BSET-KTOSL TO W_/ZAK/ANALITIKA-KTOSL.
*    Általános forgalmi adó kódja
   MOVE LW_BSET-MWSKZ TO W_/ZAK/ANALITIKA-MWSKZ.
*    Adó százaléka
   M_GET_PACK_TO_NUM LW_BSET-KBETR '3'
                     W_/ZAK/ANALITIKA-KBETR.
   W_/ZAK/ANALITIKA-KBETR = ABS( W_/ZAK/ANALITIKA-KBETR ).
*    Bizonylatfajta
   MOVE LW_BKPF-BLART TO W_/ZAK/ANALITIKA-BLART.
*    Könyvelési dátum a bizonylaton
   MOVE LW_BKPF-BUDAT TO W_/ZAK/ANALITIKA-BUDAT.
*  Bizonylatdátum a bizonylaton
   MOVE LW_BKPF-BLDAT TO W_/ZAK/ANALITIKA-BLDAT.

*  Referenciabizonylat száma
   MOVE LW_BKPF-XBLNR TO W_/ZAK/ANALITIKA-XBLNR.

*  Főkönyvi könyvelés főkönyvi számlája
   MOVE LW_BSET-HKONT TO W_/ZAK/ANALITIKA-HKONT.

*  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t.
   IF LW_BSET-LWBAS IS INITIAL.
     MOVE LW_BSET-HWBAS TO LW_BSET-LWBAS.
   ENDIF.
   IF LW_BSET-LWSTE IS INITIAL.
     MOVE LW_BSET-HWSTE TO LW_BSET-LWSTE.
   ENDIF.

*++0008 2008.09.01  BG
   IF NOT W_/ZAK/BSET-ADODAT IS INITIAL.
     MOVE W_/ZAK/BSET-ADODAT TO L_ADODAT.
   ELSE.
     MOVE LW_BKPF-BLDAT TO L_ADODAT.
   ENDIF.
*--0008 2008.09.01  BG

*  Üzletág mező meghatározása
   LOOP AT LI_BSEG INTO LW_BSEG
                             WHERE GSBER NE SPACE.
     MOVE LW_BSEG-GSBER TO  W_/ZAK/ANALITIKA-GSBER.
     EXIT.
   ENDLOOP.

*  Profitcenter mező meghatározása
   LOOP AT LI_BSEG INTO LW_BSEG
                  WHERE NOT PRCTR IS INITIAL.
     MOVE LW_BSEG-PRCTR TO W_/ZAK/ANALITIKA-PRCTR.
     EXIT.
   ENDLOOP.

   MOVE W_/ZAK/BSET-BUKRS TO W_/ZAK/ANALITIKA-FI_BUKRS.

*  BTYPE meghatározás
*++S4HANA#01.
*   READ TABLE I_BTYPE INTO W_BTYPE
   READ TABLE GT_I_BTYPE INTO W_BTYPE
*--S4HANA#01.
                       WITH KEY GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                MONAT = W_/ZAK/ANALITIKA-MONAT
                                BINARY SEARCH.
   IF SY-SUBRC NE 0.
     CLEAR W_BTYPE.
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = W_/ZAK/ANALITIKA-BUKRS
         I_BTYPART   = P_BTYPAR
         I_GJAHR     = W_/ZAK/ANALITIKA-GJAHR
         I_MONAT     = W_/ZAK/ANALITIKA-MONAT
       IMPORTING
         E_BTYPE     = W_BTYPE-BTYPE
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
     IF SY-SUBRC NE 0.
       MESSAGE E217 WITH W_/ZAK/ANALITIKA-GJAHR
                         W_/ZAK/ANALITIKA-MONAT
                         W_/ZAK/ANALITIKA-BSEG_BELNR
                         W_/ZAK/ANALITIKA-BSEG_GJAHR.
*         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&)

     ELSE.
       MOVE  W_/ZAK/ANALITIKA-GJAHR TO W_BTYPE-GJAHR.
       MOVE  W_/ZAK/ANALITIKA-MONAT TO W_BTYPE-MONAT.
*++S4HANA#01.
*       APPEND W_BTYPE TO I_BTYPE. SORT I_BTYPE BY GJAHR MONAT.
       APPEND W_BTYPE TO GT_I_BTYPE. SORT GT_I_BTYPE BY GJAHR MONAT.
*--S4HANA#01.
     ENDIF.
   ENDIF.

*  Első szelekció UMSKZ-re
   LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL
                                  AND NOT UMSKZ IS INITIAL.
*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a
*    rekord.
     IF NOT R_VPOP_LIFNR[] IS INITIAL AND
        LW_BSEG-LIFNR IN R_VPOP_LIFNR AND
        LW_BSEG-AUGDT IS INITIAL.
       MOVE 'X' TO L_VPOP_EXIT.
       EXIT.
     ELSEIF NOT R_VPOP_LIFNR[] IS INITIAL AND
            LW_BSEG-LIFNR IN R_VPOP_LIFNR.
       MOVE 'X' TO L_VPOP.
     ENDIF.

*    BSEG adatok szállító feltötése
     PERFORM GET_BSEG_LIFNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                            W_/ZAK/ANALITIKA.
                                   CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
     PERFORM GET_DATA_ANALITIKA0406 TABLES I_/ZAK/AFA_CUST
*++BG 2008.05.27
*++S4HANA#01.
*                                           I_BTYPE
                                           GT_I_BTYPE
*--S4HANA#01.
*--BG 2008.05.27
                                    USING  LW_BSET
                                           LW_BKPF
                                           LW_BSEG
                                           W_/ZAK/ANALITIKA
                                           LW_ANALITIKA_0406
*++BG 2008.05.27
*                                          W_BTYPE-BTYPE
*--BG 2008.05.27
                                           .
   ENDLOOP.
*  Nincs kitöltött UMSKZ az első tétel kell amin van szállító kód
   IF SY-SUBRC NE 0.
     LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT LIFNR IS INITIAL.
*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a
*    rekord.
       IF NOT R_VPOP_LIFNR[] IS INITIAL AND
          LW_BSEG-LIFNR IN R_VPOP_LIFNR AND
          LW_BSEG-AUGDT IS INITIAL.
         MOVE 'X' TO L_VPOP_EXIT.
         EXIT.
       ELSEIF NOT R_VPOP_LIFNR[] IS INITIAL AND
              LW_BSEG-LIFNR IN R_VPOP_LIFNR.
         MOVE 'X' TO L_VPOP.
       ENDIF.

*      BSEG adatok szállító feltötése
       PERFORM GET_BSEG_LIFNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                           W_/ZAK/ANALITIKA.
                                     CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.

       PERFORM GET_DATA_ANALITIKA0406 TABLES I_/ZAK/AFA_CUST
*++BG 2008.05.27
*++S4HANA#01.
*                                             I_BTYPE
                                             GT_I_BTYPE
*--S4HANA#01.
*--BG 2008.05.27
                                      USING  LW_BSET
                                             LW_BKPF
                                             LW_BSEG
                                             W_/ZAK/ANALITIKA
                                             LW_ANALITIKA_0406
*++BG 2008.05.27
*                                            W_BTYPE-BTYPE
*--BG 2008.05.27
                                             .
       EXIT.
     ENDLOOP.
   ENDIF.

*  Ha nem kell feldolgozni, töröljük a rekordot.
   IF NOT L_VPOP_EXIT IS INITIAL.
     MOVE 'D' TO L_FLAG.
     EXIT.
   ENDIF.

*  Vevői láb megkeresése  Első szelekció UMSKZ-re
   LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL
                                  AND NOT UMSKZ IS INITIAL.
*      BSEG adatok szállító feltötése
     PERFORM GET_BSEG_KUNNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                            W_/ZAK/ANALITIKA.
                                   CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.

   ENDLOOP.
*  Nincs kitöltött UMSKZ az első tétel kell amin van vevő kód
   IF SY-SUBRC NE 0.
     LOOP AT LI_BSEG INTO LW_BSEG WHERE NOT KUNNR IS INITIAL.
*        BSEG adatok szállító feltötése
       PERFORM GET_BSEG_KUNNR_ANALITIKA USING LW_BSEG
*++S4HANA#01.
*                                              W_/ZAK/ANALITIKA.
                                     CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.
       EXIT.
     ENDLOOP.
   ENDIF.

*++0008 2008.09.01 BG
   CALL FUNCTION '/ZAK/ROTATE_BUKRS_INPUT'
     EXPORTING
       I_FI_BUKRS    = W_/ZAK/BSET-BUKRS
       I_AD_BUKRS    = W_/ZAK/ANALITIKA-BUKRS
       I_DATE        = L_ADODAT
     IMPORTING
       E_AD_BUKRS    = W_/ZAK/ANALITIKA-BUKRS
     EXCEPTIONS
       MISSING_INPUT = 1
       OTHERS        = 2.
   IF SY-SUBRC <> 0.
     MESSAGE E232 WITH W_/ZAK/BSET-BUKRS.
*        Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_INPUT)
   ENDIF.

   IF W_/ZAK/ANALITIKA-BUKRS NE P_BUKRS.
     MOVE 'D' TO L_FLAG.
     EXIT.
   ENDIF.
*--0008 2008.09.01 BG

   PERFORM CHANGE_SIGN USING LW_BSET
*++S4HANA#01.
*                             W_/ZAK/ANALITIKA.
                    CHANGING W_/ZAK/ANALITIKA.
*--S4HANA#01.


*++0012 1065 2010.02.04 BG
*   LOOP AT I_/ZAK/AFA_ARABEV INTO W_/ZAK/AFA_ARABEV WHERE VPOPF EQ L_VPOP.
**    Adóalap
*     IF W_/ZAK/AFA_ARABEV-ATYPE EQ 'A'.
*       MOVE W_/ZAK/ANALITIKA-LWBAS TO W_/ZAK/ANALITIKA-FIELD_N.
**    Adóösszeg
*     ELSEIF W_/ZAK/AFA_ARABEV-ATYPE EQ 'B'.
*       MOVE W_/ZAK/ANALITIKA-LWSTE TO W_/ZAK/ANALITIKA-FIELD_N.
*     ENDIF.
**    ABEV azonosító
*     MOVE W_/ZAK/AFA_ARABEV-ABEVAZ TO W_/ZAK/ANALITIKA-ABEVAZ.
**    Arány flag
*     MOVE 'X' TO W_/ZAK/ANALITIKA-ARANY_FLAG.
*
*
*
*     APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
*   ENDLOOP.
*  VPOP releváns tételeknél meghatározzuk a flaget
   IF NOT L_VPOP IS INITIAL.
     L_LAST_DAY(4)   =  W_ARANY_IDSZ-GJAHR.
     L_LAST_DAY+4(2) =  W_ARANY_IDSZ-MONAT.
     L_LAST_DAY+6(2) =  '01'.

     CALL FUNCTION 'LAST_DAY_OF_MONTHS' "#EC CI_USAGE_OK[2296016]
       EXPORTING
         DAY_IN            = L_LAST_DAY
       IMPORTING
         LAST_DAY_OF_MONTH = L_LAST_DAY
       EXCEPTIONS
         DAY_IN_NO_DATE    = 1
         OTHERS            = 2.
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.
*    Meghatározzuk a BNYLAP-ot
     SELECT SINGLE * INTO LW_BNYLAP
                     FROM /ZAK/BNYLAP
                    WHERE BUKRS   EQ W_/ZAK/ANALITIKA-BUKRS
                      AND BTYPART EQ W_/ZAK/BEVALL-BTYPART
                      AND DATBI   GE L_LAST_DAY
                      AND DATAB   LE L_LAST_DAY.
     IF SY-SUBRC NE 0.
       MESSAGE E291 WITH W_/ZAK/ANALITIKA-BUKRS W_/ZAK/BEVALL-BTYPART L_LAST_DAY.
*      Nem sikerült meghatározni a VPOP kivetés értékét! (&/&/&)
     ENDIF.

*    beállítjuk a VPOP alapján az arányosítás típusát
     IF LW_BNYLAP-VPOPKI IS INITIAL.
       L_ARANYF = '3'. "Import önadózással sor
     ELSE.
       L_ARANYF = '2'. "Import VPOP kivetéssel sor
     ENDIF.

     LOOP AT I_/ZAK/AFA_ARABEV INTO W_/ZAK/AFA_ARABEV WHERE ARANYF EQ L_ARANYF.
*    Adóalap
       IF W_/ZAK/AFA_ARABEV-ATYPE EQ 'A'.
         MOVE W_/ZAK/ANALITIKA-LWBAS TO W_/ZAK/ANALITIKA-FIELD_N.
*    Adóösszeg
       ELSEIF W_/ZAK/AFA_ARABEV-ATYPE EQ 'B'.
         MOVE W_/ZAK/ANALITIKA-LWSTE TO W_/ZAK/ANALITIKA-FIELD_N.
       ENDIF.
*    ABEV azonosító
       MOVE W_/ZAK/AFA_ARABEV-ABEVAZ TO W_/ZAK/ANALITIKA-ABEVAZ.
*    Arány flag
       MOVE 'X' TO W_/ZAK/ANALITIKA-ARANY_FLAG.
       APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
     ENDLOOP.
   ELSE.
*    AFA customizing beolvasása
     LOOP AT I_/ZAK/AFA_CUST INTO W_/ZAK/AFA_CUST
                           WHERE
                                 BTYPE EQ W_/ZAK/ANALITIKA-BTYPE
                             AND MWSKZ EQ W_/ZAK/ANALITIKA-MWSKZ.

*      Ha ki van töltve a műveletkulcs, akkor erre is ellenőrzünk
       IF NOT W_/ZAK/AFA_CUST-KTOSL IS INITIAL AND
              W_/ZAK/AFA_CUST-KTOSL NE LW_BSET-KTOSL.
         CONTINUE.
       ENDIF.

       IF W_/ZAK/AFA_CUST-ATYPE EQ 'A'.
*         m_get_pack_to_num w_/zak/analitika-lwbas w_/zak/analitika-waers
*                           w_/zak/analitika-field_n.
         MOVE W_/ZAK/ANALITIKA-LWBAS TO W_/ZAK/ANALITIKA-FIELD_N.
       ELSEIF W_/ZAK/AFA_CUST-ATYPE EQ 'B'.
*         m_get_pack_to_num w_/zak/analitika-lwste w_/zak/analitika-waers
*                           w_/zak/analitika-field_n.
         MOVE W_/ZAK/ANALITIKA-LWSTE TO W_/ZAK/ANALITIKA-FIELD_N.
       ENDIF.

*    ABEV azonosító
       MOVE W_/ZAK/AFA_CUST-ABEVAZ TO W_/ZAK/ANALITIKA-ABEVAZ.
*    Arány flag
       MOVE 'X' TO W_/ZAK/ANALITIKA-ARANY_FLAG.
       APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
     ENDLOOP.
   ENDIF.
*--0012 1065 2010.02.04 BG

*  Ha van adat a 04 vagy 06-os laphoz:
   IF NOT LW_ANALITIKA_0406 IS INITIAL.
     PERFORM CHANGE_SIGN USING LW_BSET
*++S4HANA#01.
*                               LW_ANALITIKA_0406.
                      CHANGING LW_ANALITIKA_0406.
*--S4HANA#01.
     APPEND LW_ANALITIKA_0406 TO I_/ZAK/ANALITIKA.
   ENDIF.

 ENDFORM.                    " MAP_ANALITIKA_ARANY
*&---------------------------------------------------------------------*
*&      Form  GET_SAKNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_SAKNR  text
*      -->P_V_BUKRS  text
*----------------------------------------------------------------------*
 FORM GET_SAKNR  TABLES   $R_SAKNR STRUCTURE  R_SAKNR
*++S4HANA#01.
*                 USING    $BUKRS.
                 USING    $BUKRS TYPE BUKRS.
*--S4HANA#01.

   DATA L_SAKNR TYPE SAKNR.

*++S4HANA#01.
*   REFRESH $R_SAKNR.
   CLEAR $R_SAKNR[].
*--S4HANA#01.

   SELECT SAKNR INTO L_SAKNR
                FROM /ZAK/BUKRSN
               WHERE FI_BUKRS EQ $BUKRS.                "#EC CI_NOFIELD
     M_DEF $R_SAKNR 'I' 'EQ' L_SAKNR SPACE.
   ENDSELECT.

 ENDFORM.                    " GET_SAKNR
*&---------------------------------------------------------------------*
*&      Form  GET_PRCTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_PRCTR  text
*      -->P_V_BUKRS  text
*----------------------------------------------------------------------*
 FORM GET_PRCTR  TABLES  $I_PRCTR STRUCTURE I_PRCTR
                 USING   $BUKRS.

   RANGES LR_PRCTR FOR CEPC-PRCTR.

   DATA L_SHORTNAME TYPE SETNAMENEW.
   DATA L_AD_BUKRS  TYPE /ZAK/AD_BUKRS.
   DATA LI_SET_VALUES LIKE RGSB4 OCCURS 0 WITH HEADER LINE.
   DATA L_KOKRS TYPE KOKRS.

   CALL FUNCTION 'KOKRS_GET_FROM_BUKRS'
     EXPORTING
       I_BUKRS = $BUKRS
     IMPORTING
       E_KOKRS = L_KOKRS.

   SELECT  SHORTNAME AD_BUKRS
                    INTO (L_SHORTNAME,
                          L_AD_BUKRS)
                    FROM /ZAK/BUKRSN
                   WHERE FI_BUKRS EQ $BUKRS.            "#EC CI_NOFIELD

     IF NOT L_SHORTNAME IS INITIAL.
       CALL FUNCTION 'G_SET_GET_ALL_VALUES'
         EXPORTING
           SETNR         = L_SHORTNAME
           CLASS         = '0000'
*          NO_DESCRIPTIONS = 'X'
*          NO_RW_INFO    = 'X'
*          DATE_FROM     =
*          DATE_TO       =
*          FIELDNAME     = ' '
         TABLES
           SET_VALUES    = LI_SET_VALUES
         EXCEPTIONS
           SET_NOT_FOUND = 1
           OTHERS        = 2.
       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
         REFRESH LR_PRCTR.
         LOOP AT LI_SET_VALUES.
           M_DEF LR_PRCTR 'I' 'BT' LI_SET_VALUES-FROM LI_SET_VALUES-TO.
         ENDLOOP.
         IF NOT LR_PRCTR[] IS INITIAL.
           CLEAR $I_PRCTR.
           SELECT PRCTR INTO  $I_PRCTR-PRCTR
                        FROM CEPC
                       WHERE PRCTR IN LR_PRCTR
                         AND KOKRS EQ L_KOKRS.
             $I_PRCTR-AD_BUKRS = L_AD_BUKRS.
             APPEND $I_PRCTR.
           ENDSELECT.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDSELECT.

   LOOP AT $I_PRCTR.
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
         INPUT  = $I_PRCTR-PRCTR
       IMPORTING
         OUTPUT = $I_PRCTR-PRCTR.
     MODIFY $I_PRCTR.
   ENDLOOP.


 ENDFORM.                    " GET_PRCTR
*&---------------------------------------------------------------------*
*&      Form  GET_ELO_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$LI_AFA_ELO  text
*      -->P_LW_BSEG  text
*      -->P_W_BTYPE_BTYPE  text
*      -->P_L_ELO_TRUE  text
*----------------------------------------------------------------------*
 FORM GET_ELO_FLAG  TABLES   $LI_AFA_ELO STRUCTURE /ZAK/AFA_ELO
                    USING    $BKPF STRUCTURE BKPF
                             $BSEG STRUCTURE BSEG
*++S4HANA#01.
*                             $BTYPE
*                             $ELO_TRUE.
                             $BTYPE TYPE /ZAK/BTYPE
                    CHANGING $ELO_HKONT TYPE HKONT
                             $ELO_SHKZG TYPE SHKZG
                             $ELO_TRUE TYPE CLIKE.
*--S4HANA#01.

   DATA LW_AFA_ELO TYPE /ZAK/AFA_ELO.

   LOOP AT $LI_AFA_ELO INTO LW_AFA_ELO.
     IF $BSEG-HKONT BETWEEN LW_AFA_ELO-HKONT_FROM AND
     LW_AFA_ELO-HKONT_TO
        AND $BKPF-BLART EQ LW_AFA_ELO-BLART
        AND $BSEG-MWSKZ EQ LW_AFA_ELO-MWSKZ.
       MOVE 'X' TO $ELO_TRUE.
       EXIT.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " GET_ELO_FLAG
*&---------------------------------------------------------------------*
*&      Form  VER_BELNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VER_BELNR .

   IF S_BELNR[] IS INITIAL AND NOT P_BELNR IS INITIAL.
     MESSAGE E000 WITH 'Kérem adjon meg bizonylatszámot!'.
*   & & & &
   ENDIF.

   IF S_GJAHR[] IS INITIAL AND NOT P_BELNR IS INITIAL.
     MESSAGE E000 WITH 'Kérem adjon meg gazdasági évet!'.
*   & & & &
   ENDIF.

 ENDFORM.                    " VER_BELNR
*++1665 #02.
*&---------------------------------------------------------------------*
*&      Form  CALL_BSET_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_BUKRS  text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM CALL_BSET_UPDATE  USING  $BUKRS.
 FORM CALL_BSET_UPDATE  USING  $BUKRS TYPE BUKRS.
*--S4HANA#01.

   RANGES LR_BUKRS FOR /ZAK/BSET-BUKRS.

   CHECK NOT $BUKRS IS INITIAL.

   M_DEF LR_BUKRS 'I' 'EQ' $BUKRS SPACE.

   SUBMIT /ZAK/BSET_UPDATE WITH S_BUKRS IN LR_BUKRS AND RETURN.

 ENDFORM.                    " CALL_BSET_UPDATE
*--1665 #02.
