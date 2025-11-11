*&---------------------------------------------------------------------*
*& Program: SAP adatok meghatározása SZJA adóbevalláshoz
*&---------------------------------------------------------------------*
 REPORT /ZAK/ZAK_/ZAK/SZJA_SAP_SEL MESSAGE-ID /ZAK/ZAK.
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
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2006/05/27   Cserhegyi T.  CL_GUI_FRONTEND_SERVICES
*&                                   cseréje hagyományosra
*&        2007.01.03   Balázs G.     vissza csere
*& 0002   2006/10/26   Balázs G.     Több bevallás típus kezelése
*& 0003   2007/01/05   Balázs G.     Arányszámok kezelés javítása 12.hó
*& 0004   2007/03/06   Forgó I.      Könyvelés "előjel helyesen"
*& 0005   2007/05/08   Balázs G.     Korrekciós bizonylat fajta bevezet.
*& 0006   2007/10/08   Balázs G.     Vállalat forgatás
*& 0007   2008/01/21   Balázs G.     Vállalat forgatás átalakítása
*& 0008   2008/02/07   Balázs G.     SOR_SZETRAK átalakítása mert
*&                                   évváltásnál nem működik helyesen
*& 0009   2008/07/03   Balázs G.     SZJA_CUST beolvasásának szűrése
*&                                   szelekción megadott főkönyvek
*&                                   alapján
*& 0010   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra
*&                                   ellenőrzés visszaállítása
*& 0011   2008/10/17   Balázs G.     Üzleti ajándék projekt 2008
*&                                   -havi kezelés
*&                                   -könyvelési fájl tagolás
*&                                   -költséghely forgatás
*&                                   -progress indicator
*& 0012   2008/12/16   Balázs G.     Üzleti ajándék és repi eltávolítása
*&                                   teljes program lemásolva:
*&                                   /ZAK/SZJA_SAP_SEL_OLD néven
*& 0013   2009/04/08   Balázs G.     Iniciális értékek beállítása
*& 0014   2009/04/20   Balázs G.     WL könyvelésnél ÁFA kód
*&                                   /ZAK/SZJA_CUST tábla alapján
*& 0015   2009/05/22   Balázs G.     Kizárt bizonylatok kezelése
*& 0016   2009/08/25   Balázs G.     PST elem átvétele analitikába
*& 0017   2009/10/29   Balázs G.     XREF1 keresés átalakítás
*& 0018   2010/04/20   Balázs G.     SC bizonylatfajta kizárás
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


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
*++BG 2007.04.18
 CONSTANTS C_REPI_MONAT TYPE MONAT VALUE '05'.
*--BG 2007.04.18

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
*
* lcl_event_receiver (Definition)
*===============================================================

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
 DATA V_SUBRC LIKE SY-SUBRC.
 DATA V_REPID LIKE SY-REPID.
 DATA : V_A_ARANY TYPE P DECIMALS 4,
        V_R_ARANY TYPE P DECIMALS 4.
*Beállítás adatok
 DATA W_/ZAK/SZJA_CUST TYPE  /ZAK/SZJA_CUST.
 DATA I_/ZAK/SZJA_CUST TYPE STANDARD TABLE OF /ZAK/SZJA_CUST
                                                        INITIAL SIZE 0.
*ABEV meghatározása
 DATA W_/ZAK/SZJA_ABEV TYPE  /ZAK/SZJA_ABEV.
 DATA I_/ZAK/SZJA_ABEV TYPE STANDARD TABLE OF /ZAK/SZJA_ABEV
                                                        INITIAL SIZE 0.
*A funkcioelem áltlal generált rekordokat tartalmazza
 DATA IO_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                        INITIAL SIZE 0.
* Excedlbe töltendő sorok
*++FI 20070213
* DATA W_/ZAK/SZJA_EXCEL TYPE  /ZAK/SZJA_EXCEL.
* DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJA_EXCEL
*                                                        INITIAL SIZE 0.
 DATA W_/ZAK/SZJA_EXCEL1 TYPE  /ZAK/SZJAEXCELV2. " Könyvelés 1. sora
 DATA W_/ZAK/SZJA_EXCEL2 TYPE  /ZAK/SZJAEXCELV2. " Könyvelés 2. sora
 DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJAEXCELV2
                                                        INITIAL SIZE 0.

*--FI 20070213
*BSEG
 DATA W_BSEG TYPE  BSEG.
 DATA I_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
*BKPF
 DATA W_BKPF TYPE  BKPF.
 DATA I_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.

* ALV kezelési változók
 DATA: V_OK_CODE           LIKE SY-UCOMM,
       V_SAVE_OK           LIKE SY-UCOMM,
       V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
       V_CONTAINER1        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',

       V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       V_CUSTOM_CONTAINER1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       I_FIELDCAT          TYPE LVC_T_FCAT,
       V_LAYOUT            TYPE LVC_S_LAYO,
       V_VARIANT           TYPE DISVARIANT,
       V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER.
 DATA: BEGIN OF I_OUTTAB2 OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
 DATA: CELLTAB TYPE LVC_T_STYL.
 DATA: END OF I_OUTTAB2.
*++0002 BG 2006/10/26
 RANGES R_BTYPE FOR /ZAK/BEVALL-BTYPE.

*Arányszámok bevallás típusonként kell
 DATA: BEGIN OF I_BTYPE_ARANY OCCURS 0,
         BTYPE   TYPE /ZAK/BTYPE,
         A_ARANY LIKE V_A_ARANY,
         R_ARANY LIKE V_R_ARANY,
       END OF I_BTYPE_ARANY.
*--0002 BG 2006/10/26

*++0005 BG 2007.05.08
*MAKRO definiálás range feltöltéshez
 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   APPEND &1.
 END-OF-DEFINITION.
*--0005 BG 2007.05.08

*++0006 2007.10.08  BG (FMC)
 DATA V_SEL_BUKRS TYPE BUKRS.
*--0006 2007.10.08  BG (FMC)

*++0017 BG 2009.10.29
 TYPES: BEGIN OF T_AD_BUKRS,
          AD_BUKRS TYPE /ZAK/AD_BUKRS,
        END OF T_AD_BUKRS.

 DATA I_AD_BUKRS TYPE T_AD_BUKRS OCCURS 0 WITH HEADER LINE.
*--0017 BG 2009.10.29

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
* ++BG
* Bevallás típus.
* SELECTION-SCREEN BEGIN OF LINE.
* SELECTION-SCREEN COMMENT 01(31) TEXT-102.
*++0002 BG 2006/10/26
* PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE
**                          /ZAK/BEVALLSZ-BTYPE
**                          OBLIGATORY
*                           NO-DISPLAY.
*--0002 BG 2006/10/26
* SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT
*                          MODIF ID DIS
                           NO-DISPLAY.
* SELECTION-SCREEN END OF LINE.
* Bevallás fajta meghatározása
 PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                           DEFAULT C_BTYPART_SZJA
                           OBLIGATORY.
* --BG

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
                                                    OBLIGATORY.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BSZTXT  LIKE /ZAK/BEVALLDT-SZTEXT MODIF ID DIS.
 SELECTION-SCREEN END OF LINE.
* Bizonylat fajta
 SELECT-OPTIONS: S_BLART FOR BKPF-BLART NO INTERVALS.
*                         DEFAULT 'SE' OPTION EQ SIGN E.

*++0005 BG 2007.05.08
 SELECT-OPTIONS: S_KBLART FOR BKPF-BLART NO INTERVALS.
*--0005 BG 2007.05.08
*++0015 2009.05.22 BG
* Kizárt bizonylatok
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 1(31) TEXT-104.
 PARAMETERS P_KBELNR AS CHECKBOX MODIF ID DIS.
 SELECTION-SCREEN PUSHBUTTON 52(4) KBL USER-COMMAND KBL.
 SELECTION-SCREEN END OF LINE.
*--0015 2009.05.22 BG


* Teszt futás
 PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X' .

 SELECTION-SCREEN: END OF BLOCK BL01.

*++0009 BG 2008.07.03
 SELECTION-SCREEN BEGIN OF BLOCK B105 WITH FRAME TITLE TEXT-T05.
 SELECT-OPTIONS S_SAKNR FOR /ZAK/SZJA_CUST-SAKNR.
 SELECTION-SCREEN: END OF BLOCK B105.
*--0009 BG 2008.07.03


*Feltöltés módjának kiválasztása
 SELECTION-SCREEN BEGIN OF BLOCK B102 WITH FRAME TITLE TEXT-T02.
 PARAMETERS: P_NORM  RADIOBUTTON GROUP R01 USER-COMMAND NORM
                                                   DEFAULT 'X',
             P_ISMET RADIOBUTTON GROUP R01,
             P_PACK  LIKE /ZAK/BEVALLP-PACK
                       MATCHCODE OBJECT /ZAK/PACK.

 SELECTION-SCREEN END OF BLOCK B102.

*++0012 2008.12.16 BG
**Adómentes rész megadása
* SELECTION-SCREEN BEGIN OF BLOCK B103 WITH FRAME TITLE TEXT-T03.
**Üzleti ajándék adómentes rész
* PARAMETERS: P_UZAJ LIKE BSEG-DMBTR.
**Reprezentáció adómentes rész
* PARAMETERS: P_REPR LIKE BSEG-DMBTR.
* SELECTION-SCREEN END OF BLOCK B103.
*--0012 2008.12.16 BG

*Könyvelési excel fájl
 SELECTION-SCREEN BEGIN OF BLOCK B104 WITH FRAME TITLE TEXT-T04.
 PARAMETERS: P_OUTF LIKE FC03TAB-PL00_FILE."  OBLIGATORY.
*++0011 2008.10.17 BG
 PARAMETERS: P_SPLIT TYPE I NO-DISPLAY.
*--0011 2008.10.17 BG

 SELECTION-SCREEN END OF BLOCK B104.


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

   PERFORM S_BLART_INIT.

*++00013 2009.04.08
**++0005 BG 2007.05.08
*   PERFORM S_KBLART_INIT.
**--0005 BG 2007.05.08
*--00013 2009.04.08

*++0015 2009.05.22 BG
   WRITE ICON_DISPLAY_MORE TO KBL AS ICON.
*--0015 2009.05.22 BG


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN OUTPUT.

*++0015 2009.05.22 BG
* Meghatározzuk ban e kizárt bizonylatszám
   PERFORM GET_KBELNR TABLES I_KBELNR
                      USING  P_BUKRS
                             P_KBELNR.
*--0015 2009.05.22 BG

*  Képernyő attribútomok beállítása
   PERFORM SET_SCREEN_ATTRIBUTES.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*
*++0002 BG 2006/10/26
*AT SELECTION-SCREEN ON P_BTYPE.
 AT SELECTION-SCREEN ON P_BTYPAR.
*--0002 BG 2006/10/26
*  SZJA bevallás típus ellenőrzése
   PERFORM VER_BTYPEART USING P_BUKRS
*++0002 BG 2006/10/26
*                             P_BTYPE
                              P_BTYPAR
*--0002 BG 2006/10/26
                              C_BTYPART_SZJA
                     CHANGING V_SUBRC.

   IF NOT V_SUBRC IS INITIAL.
     MESSAGE E019.
*   Kérem SZJA típusú bevallás azonosítót adjon meg!
*  Meghatározzuk a bevallás típust
   ELSE.
*++0002 BG 2006/10/26
*     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
*          EXPORTING
*               I_BUKRS     = P_BUKRS
*               I_BTYPART   = P_BTYPAR
*               I_GJAHR     = P_GJAHR
*               I_MONAT     = P_MONAT
*          IMPORTING
*               E_BTYPE     = P_BTYPE
*          EXCEPTIONS
*               ERROR_MONAT = 1
*               ERROR_BTYPE = 2
*               OTHERS      = 3.
*     IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     ENDIF.
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
*--0002 BG 2006/10/26

 AT SELECTION-SCREEN ON P_BSZNUM.
   MOVE SY-REPID TO V_REPID.
*  Szolgáltatás azonosító ellenőrzése
*++0010 BG 2008/09/12
   PERFORM VER_BSZNUM   USING P_BUKRS
                              P_BTYPAR
                              P_BSZNUM
                              V_REPID
                     CHANGING V_SUBRC.
*--0010 BG 2008/09/12
*   IF NOT V_SUBRC IS INITIAL.
*     MESSAGE E029 WITH P_BSZNUM.
**    Ez a program a  & adatszolgáltatáshoz nem használható!
*   ENDIF.

 AT SELECTION-SCREEN ON P_MONAT.
*  Periódus ellenőrzése
   PERFORM VER_PERIOD   USING P_MONAT.

 AT SELECTION-SCREEN ON BLOCK B102.
*  Blokk ellenőrzése
   PERFORM VER_BLOCK_B102 USING P_NORM
                                P_ISMET
                                P_PACK.

 AT SELECTION-SCREEN ON P_PACK.

 AT SELECTION-SCREEN ON P_OUTF.
* Éles futásnál kell fájl név
   IF P_TESZT IS INITIAL AND P_OUTF IS INITIAL.
     MESSAGE E146.
*   Kérem adja meg a könyvelési fájl nevét!
   ENDIF.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_OUTF.
   PERFORM FILENAME_GET USING P_OUTF.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
*++0015 2009.05.22 BG
   CASE SY-UCOMM.
     WHEN 'KBL'.
       CALL TRANSACTION '/ZAK/OUT_BELNR_V'.
   ENDCASE.
*--0015 2009.05.22 BG


*  Megnevezések meghatározása
   PERFORM READ_ADDITIONALS.
*  Fájl ellenőrzés
   PERFORM VER_FILENAME USING P_OUTF.
*++0012 2008.12.16 BG
**  Üzleti ajándék adómentes rész ellenőrzése
*   PERFORM VER_12_OBLIGATORY USING P_MONAT
*                                   P_UZAJ
*                          CHANGING V_SUBRC.
*   IF NOT V_SUBRC IS INITIAL.
*     MESSAGE I083.
**   Kérem adja meg az "Üzleti ajándék adómentes rész" mező értékét!
*   ENDIF.
*--0012 2008.12.16 BG

* fájlnév ellenőrzése
   PERFORM FILENAME_OBLIGATORY USING P_OUTF.

*++0012 2008.12.16 BG
**  Reprezentáció adómentes rész ellenőrzése
*   PERFORM VER_12_OBLIGATORY USING P_MONAT
*                                   P_REPR
*                          CHANGING V_SUBRC.
*   IF NOT V_SUBRC IS INITIAL.
*     MESSAGE I084.
**   Kérem adja meg a "Reprezentáció adómentes rész" mező értékét!
*   ENDIF.
*--0012 2008.12.16 BG


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*++0015 2009.05.22 BG
* Meghatározzuk ban e kizárt bizonylatszám
   PERFORM GET_KBELNR TABLES I_KBELNR
                      USING  P_BUKRS
                             P_KBELNR.
*--0015 2009.05.22 BG

*++0006 2007.10.08  BG (FMC)
*++0017 BG 2009.10.29
**  Vállalat forgatás
*   PERFORM ROTATE_BUKRS_OUTPUT USING P_BUKRS
*                                     V_SEL_BUKRS.
*  Vállalat forgatás
   PERFORM ROTATE_BUKRS_OUTPUT TABLES I_AD_BUKRS
                               USING  P_BUKRS
                                      V_SEL_BUKRS.
*--0017 BG 2009.10.29

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
*--0006 2007.10.08  BG (FMC)


*  Jogosultság vizsgálat
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTYPAR
                                 C_ACTVT_01.

*  Ha a BYTPE üres, akkor meghatározzuk
*++0002 BG 2006/10/26
*  IF P_BTYPE IS INITIAL.
   IF R_BTYPE[] IS INITIAL.

*     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
*          EXPORTING
*               I_BUKRS     = P_BUKRS
*               I_BTYPART   = P_BTYPAR
*               I_GJAHR     = P_GJAHR
*               I_MONAT     = P_MONAT
*          IMPORTING
*               E_BTYPE     = P_BTYPE
*          EXCEPTIONS
*               ERROR_MONAT = 1
*               ERROR_BTYPE = 2
*               OTHERS      = 3.
*     IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*     ENDIF.
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
*--0002 BG 2006/10/26


*++0011 2008.10.17 BG
*  Adatok leválogatása
   PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                    0
                                    0.
*--0011 2008.10.17 BG

*  Vállalati adatok beolvasása
   PERFORM GET_T001 USING P_BUKRS
                          V_SUBRC.
   IF NOT V_SUBRC IS INITIAL.
     MESSAGE A036 WITH P_BUKRS.
*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla)
   ENDIF.

*  Adatok leválogatása
   PERFORM VALOGAT USING V_SUBRC.
   IF V_SUBRC <> 0.
*    nincs a szelekciónak megfelelő adat.
     MESSAGE I031.
     EXIT.
   ENDIF.

*  Ha 12.v.nagyobb hót választott és akkor össze kell szedni az összes
*  adatot. (13. periódusban nem az év összes rekordja szerepel, csak a
*  13. havi és így tovább)
*  előjel helyesen az arányszám kiszámításához
*++0012 2008.12.16 BG
*++0002 BG 2006/10/26
*   IF P_MONAT >= 12.
**++0011 2008.10.17 BG
**  Éves adatok meghatározása
*     PERFORM PROGRESS_INDICATOR USING TEXT-P02
*                                      0
*                                      0.
**--0011 2008.10.17 BG
*     PERFORM EVES_ADATOK_SUM TABLES   I_/ZAK/SZJA_CUST
*                                      I_BSEG
*                                      R_BTYPE
*                                      I_BTYPE_ARANY
*                             USING    P_UZAJ
*                                      P_REPR.
**                             CHANGING V_A_ARANY
**                                      V_R_ARANY.
*   ELSE.
*--0012 2008.12.16 BG
*     V_A_ARANY = 1.
*     V_R_ARANY = 1.
   LOOP AT R_BTYPE.
     CLEAR I_BTYPE_ARANY.
     MOVE R_BTYPE-LOW TO I_BTYPE_ARANY-BTYPE.
     MOVE 1 TO I_BTYPE_ARANY-A_ARANY.
     MOVE 1 TO I_BTYPE_ARANY-R_ARANY.
     APPEND I_BTYPE_ARANY.
   ENDLOOP.
*++0012 2008.12.16 BG
*   ENDIF.
**--0002 BG 2006/10/26
*--0012 2008.12.16 BG


*++0002 BG 2006/10/26
*  a leválogatott BSEG sorokat szétrakja a /ZAK/ANALITIKA táblába és
*  a könyveléshez
*  PERFORM SOR_SZETRAK USING V_SUBRC.
*--0002 BG 2006/10/26
*++0008 BG 2007/02/07
*  Új rutin szükséges mert évváltás esetén az önrevíziós adatokban
*  csak a BTYPE-ot cserélte ki, az ABEV azonosítót a nem.
*  Meg kell cserélni a sorrendet, először a BSEG tételt kell olvasni
*  és a sorhoz meghatározni az év alapján a megfelelő SZJA_CUST
*  rekordot.
   PERFORM SOR_SZETRAK_NEW.
*--0008 BG 2007/02/07

*++0002 BG 2006/10/26
*  Ha mindent szétválogattunk, akkor képezzük az új analitika rekordokat
*++0011 2008.10.17 BG
*  Analitika rekordok generálása
   PERFORM PROGRESS_INDICATOR USING TEXT-P04
                                    0
                                    0.
*--0011 2008.10.17 BG
   PERFORM GEN_ANALITIKA.
*--0002 BG 2006/10/26

*  EXIT meghívása
   PERFORM CALL_EXIT.

*++0011 2008.10.17 BG
*  Könyvelés fájl forgatás (költséghely)
   PERFORM ROTATION_DATA TABLES I_/ZAK/SZJA_EXCEL
                         USING  P_BUKRS.
*--0011 2008.10.17 BG

*  Teszt vagy éles futás, adatbázis módosítás, stb.
   PERFORM INS_DATA USING P_TESZT.
   IF P_TESZT IS INITIAL.
*    A  könyvelendőket EXCELbe
*++FI 20070213
*     PERFORM DOWNLOAD_FILE
*                 TABLES
*                    I_/ZAK/SZJA_EXCEL
*                 USING
*                    P_OUTF
*                 CHANGING
*                    V_SUBRC.
     PERFORM DOWNLOAD_FILE_V2
                 TABLES
                    I_/ZAK/SZJA_EXCEL
                 USING
                    P_OUTF
                 CHANGING
                    V_SUBRC.
*--FI 20070213
   ENDIF.

*   PERFORM feldolgozas USING v_subrc.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
 END-OF-SELECTION.

   PERFORM LIST_DISPLAY.



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

*++0002 BG 2006/10/26
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
*   ENDIF.
*--0002 BG 2006/10/26

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
                              $PACK.

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
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILENAME_GET USING $FILE.

   DATA: L_FILENAME TYPE STRING,
         L_PATH     TYPE STRING,
         L_FULLPATH TYPE STRING.

* ++ 0001 CST 2006.05.27
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
*     EXPORTING
*       WINDOW_TITLE            = 'Könyvelési fájl'
*       DEFAULT_EXTENSION       = '*.XLS'
**      DEFAULT_FILE_NAME       =
**      file_filter             = '*.XLS'
*       INITIAL_DIRECTORY       = 'C:\temp'
*     CHANGING
*       FILENAME                = L_FILENAME
*       PATH                    = L_PATH
*       FULLPATH                = L_FULLPATH
*     EXCEPTIONS
*       CNTL_ERROR              = 1
*       ERROR_NO_GUI            = 2
*       OTHERS                  = 3
*       .
*   IF SY-SUBRC NE 0.
*     MESSAGE E082 WITH L_FULLPATH.
**   Hiba & fájl megnyitásánál!
*   ELSE.
*     MOVE L_FULLPATH TO $FILE.
*   ENDIF.
**   ENDIF.


   DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*   CALL FUNCTION 'WS_FILENAME_GET'
*      EXPORTING  DEF_FILENAME     =  '*.XLS'
**                 DEF_PATH         = 'C:\temp'
*                 MASK             =  L_MASK
*                 MODE             = 'S'
*                 TITLE            =  'Könyvelési fájl'
*      IMPORTING  FILENAME         =   $FILE
**               RC               =  DUMMY
*      EXCEPTIONS INV_WINSYS       =  04
*                 NO_BATCH         =  08
*                 SELECTION_CANCEL =  12
*                 SELECTION_ERROR  =  16.

   DATA L_EXTENSION TYPE STRING.
   DATA L_TITLE     TYPE STRING.
   DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.

   CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
     EXPORTING
       WINDOW_TITLE      = 'Könyvelési fájl'
*      DEFAULT_EXTENSION =
*      EFAULT_FILE_NAME  =
*      WITH_ENCODING     =
       FILE_FILTER       = '*.XLS'
*      INITIAL_DIRECTORY =
*      DEFAULT_ENCODING  =
     IMPORTING
*      FILENAME          =
*      PATH              =
       FULLPATH          = L_FULLPATH
*      USER_ACTION       =
*      FILE_ENCODING     =
     .
   $FILE = L_FULLPATH.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

   CHECK SY-SUBRC EQ 0.
* -- 0001 CST 2006.05.27

 ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  ver_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_OUTF  text
*----------------------------------------------------------------------*
 FORM VER_FILENAME USING    $FILE.

   DATA:
     L_FULLPATH TYPE STRING,
     L_RC       TYPE I.
*            L_FULLPATH   LIKE RLGRAP-FILENAME,
*            L_RC         TYPE C.

   DATA: BEGIN OF LI_FILE OCCURS 0,
           LINE(50),
         END OF LI_FILE.

   CHECK NOT $FILE IS INITIAL.
   MOVE $FILE TO L_FULLPATH.

   MOVE '1' TO LI_FILE-LINE.

*++0001 2007.01.03 BG (FMC)
* ++ 0001 CST 2006.05.27
   CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
     EXPORTING
*      BIN_FILESIZE            =
       FILENAME                = L_FULLPATH
*      filetype                = 'DAT'
*      APPEND                  = SPACE
*      write_field_separator   = 'X'
*      HEADER                  = '00'
*      TRUNC_TRAILING_BLANKS   = SPACE
*      WRITE_LF                = 'X'
*      COL_SELECT              = SPACE
*      COL_SELECT_MASK         = SPACE
*  IMPORTING
*      FILELENGTH              =
     CHANGING
       DATA_TAB                = LI_FILE[]
     EXCEPTIONS
       FILE_WRITE_ERROR        = 1
       NO_BATCH                = 2
       GUI_REFUSE_FILETRANSFER = 3
       INVALID_TYPE            = 4
       NO_AUTHORITY            = 5
       UNKNOWN_ERROR           = 6
       HEADER_NOT_ALLOWED      = 7
       SEPARATOR_NOT_ALLOWED   = 8
       FILESIZE_NOT_ALLOWED    = 9
       HEADER_TOO_LONG         = 10
       DP_ERROR_CREATE         = 11
       DP_ERROR_SEND           = 12
       DP_ERROR_WRITE          = 13
       UNKNOWN_DP_ERROR        = 14
       ACCESS_DENIED           = 15
       DP_OUT_OF_MEMORY        = 16
       DISK_FULL               = 17
       DP_TIMEOUT              = 18
       FILE_NOT_FOUND          = 19
       DATAPROVIDER_EXCEPTION  = 20
       CONTROL_FLUSH_ERROR     = 21
*      OTHERS                  = 22
     .


*   CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**   BIN_FILESIZE                  = ' '
**   CODEPAGE                      = ' '
*       FILENAME                      = L_FULLPATH
**   FILETYPE                      = 'ASC'
**   MODE                          = ' '
**   WK1_N_FORMAT                  = ' '
**   WK1_N_SIZE                    = ' '
**   WK1_T_FORMAT                  = ' '
**   WK1_T_SIZE                    = ' '
**   COL_SELECT                    = ' '
**   COL_SELECTMASK                = ' '
**   NO_AUTH_CHECK                 = ' '
** IMPORTING
**   FILELENGTH                    =
*     TABLES
*       DATA_TAB                      = LI_FILE[]
**   FIELDNAMES                    =
*    EXCEPTIONS
*      FILE_OPEN_ERROR               = 1
*      FILE_WRITE_ERROR              = 2
*      INVALID_FILESIZE              = 3
*      INVALID_TYPE                  = 4
*      NO_BATCH                      = 5
*      UNKNOWN_ERROR                 = 6
*      INVALID_TABLE_WIDTH           = 7
*      GUI_REFUSE_FILETRANSFER       = 8
*      CUSTOMER_ERROR                = 9
*      OTHERS                        = 10.
* -- 0001 CST 2006.05.27
*--0001 2007.01.03 BG (FMC)


   IF SY-SUBRC <> 0.
     MESSAGE E082 WITH L_FULLPATH.
*      Hiba & fájl megnyitásánál!
   ELSE.
*++0001 2007.01.03 BG (FMC)
* ++ 0001 CST 2006.05.27
*    Minta törlése
     CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_DELETE
       EXPORTING
         FILENAME = L_FULLPATH
       CHANGING
         RC       = L_RC.

*     CALL FUNCTION 'WS_FILE_DELETE'
*       EXPORTING
*         FILE   = L_FULLPATH
*       IMPORTING
*         RETURN = L_RC.

* -- 0001 CST 2006.05.27
*--0001 2007.01.03 BG (FMC)
   ENDIF.


 ENDFORM.                    " ver_filename
*&---------------------------------------------------------------------*
*&      Form  ver_12_obligatory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MONAT  text
*      -->P_P_UZAJ  text
*----------------------------------------------------------------------*
 FORM VER_12_OBLIGATORY USING    $MONAT
                                 $FIELD
                     CHANGING    $SUBRC.

   CLEAR $SUBRC.
* 12. periódusra kötelező
   IF $MONAT BETWEEN 12 AND 16 AND $FIELD IS INITIAL.
     MOVE 4 TO $SUBRC.
   ENDIF.

 ENDFORM.                    " ver_12_obligatory
*&---------------------------------------------------------------------*
*&      Form  valogat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT USING    $SUBRC.
*  Beállítások laválogatása
*++0002 BG 2006/10/26
   PERFORM VALOGAT_BEALLITAS TABLES I_/ZAK/SZJA_CUST
                                    R_BTYPE
*++0009 BG 2008.07.03
                                    S_SAKNR
*--0009 BG 2008.07.03
                              USING P_BUKRS
*                                   P_BTYPE
                                    P_BSZNUM
                           CHANGING V_SUBRC.
*--0002 BG 2006/10/26
   $SUBRC = V_SUBRC.
   IF V_SUBRC <> 0.
*    Hiba az SZJA beállítások meghatározásánál!
     MESSAGE E089 WITH '/ZAK/SZJA_CUST_V'.
   ENDIF.

*  /ZAK/SZJA_ABEV leválogatása a WL könyveléshez
*++0002 BG 2006/10/26
   PERFORM VALOGAT_ABEV_MEZOK  TABLES R_BTYPE
                               USING  P_BUKRS
*                                     P_BTYPE
                                      'WL'
                            CHANGING  W_/ZAK/SZJA_ABEV
                                      V_SUBRC.
*--0002 BG 2006/10/26
   IF V_SUBRC <> 0.
*    Hiba az ABEV - MEZŐ meghatározásánál!
     MESSAGE E089 WITH '/ZAK/SZJA_ABEV_V'.
   ENDIF.

*   /ZAK/BEVALL leválogatása
*++0002 BG 2006/10/26
*   PERFORM VALOGAT_/ZAK/BEVALL  USING W_/ZAK/BEVALL
*                                     P_BUKRS
*                                     P_BTYPE
*                            CHANGING V_SUBRC.
*   IF V_SUBRC <> 0.
**    Hiba az BEVALL - MEZŐ meghatározásánál!
*     MESSAGE E089 WITH '/ZAK/BEVALL_V'.
*   ENDIF.
*--0002 BG 2006/10/26

*  Könyvelési rekordok leválogatása
   PERFORM SZJA_ADATOK_LEVAL TABLES I_/ZAK/SZJA_CUST
                                    I_BSEG
                                    I_BKPF
*++0015 2009.05.22 BG
                                    I_KBELNR
*--0015 2009.05.22 BG
                              USING P_BUKRS
                                    P_GJAHR
*                                   P_BTYPE
                                    P_BSZNUM
*++0006 2007.10.08  BG (FMC)
                                    V_SEL_BUKRS
*--0006 2007.10.08  BG (FMC)

                           CHANGING $SUBRC.



 ENDFORM.                    " valogat
*&---------------------------------------------------------------------*
*&      Form  valogat_beallitas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_BEALLITAS TABLES $/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                               $BTYPE STRUCTURE R_BTYPE
*++0009 BG 2008.07.03
                               $SAKNR STRUCTURE S_SAKNR
*--0009 BG 2008.07.03
                        USING    $BUKRS
*                                $BTYPE
                                 $BSZNUM
                        CHANGING $SUBRC.
*++1908 #10.
   FIELD-SYMBOLS <SZJA_CUST> TYPE /ZAK/SZJA_CUST.

   DEFINE LM_DATE.
     &1(2)   = '20'.
     &1+2(2) = &2(2).
     &1+4(2) = &3.
     &1+6(2) = &4.
   END-OF-DEFINITION.
*--1908 #10.

*a szelekciós képernyő adatai alapján leválogatja a beállítás adatokat
   SELECT * INTO TABLE $/ZAK/SZJA_CUST
            FROM /ZAK/SZJA_CUST
            WHERE BUKRS  = $BUKRS
*             AND BTYPE  = $BTYPE
              AND BTYPE  IN $BTYPE
              AND BSZNUM = $BSZNUM
*++0009 BG 2008.07.03
              AND SAKNR IN $SAKNR
*--0009 BG 2008.07.03
*++0012 2008.12.16 BG
              AND /ZAK/EVES = ''
*--0012 2008.12.16 BG
              .
   $SUBRC = SY-SUBRC.
*++1908 #10.
   LOOP AT $/ZAK/SZJA_CUST ASSIGNING <SZJA_CUST> WHERE DATAB IS INITIAL
                                                   OR DATBI IS INITIAL.
*    Üres dátum mezők feltöltése
     IF <SZJA_CUST>-DATAB IS INITIAL.
*++1908 #11.
*       LM_DATE <SZJA_CUST>-DATAB  <SZJA_CUST>-BTYPE '01' '01'.
       SELECT SINGLE DATAB INTO <SZJA_CUST>-DATAB
                           FROM /ZAK/BEVALL
                          WHERE BUKRS EQ <SZJA_CUST>-BUKRS
                            AND BTYPE EQ <SZJA_CUST>-BTYPE.
*--1908 #11.
     ENDIF.
     IF <SZJA_CUST>-DATBI IS INITIAL.
*++1908 #11.
*       LM_DATE <SZJA_CUST>-DATBI  <SZJA_CUST>-BTYPE '12' '31'.
       SELECT SINGLE DATBI INTO <SZJA_CUST>-DATBI
                           FROM /ZAK/BEVALL
                          WHERE BUKRS EQ <SZJA_CUST>-BUKRS
                            AND BTYPE EQ <SZJA_CUST>-BTYPE.
*--1908 #11.
     ENDIF.
   ENDLOOP.
*--1908 #10.

 ENDFORM.                    " valogat_beallitas
*&---------------------------------------------------------------------*
*&      Form  feldolgozas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM FELDOLGOZAS USING    P_V_SUBRC.
*  Ha 12. hót választott és akkor össze kell szedni az összes adatot
*  előjel helyesen az arányszám kiszámításához
   EXIT.
   IF P_MONAT = 12.
*     PERFORM EVES_ADATOK_SUM TABLES   I_/ZAK/SZJA_CUST
*                                      I_BSEG
*                             USING    P_UZAJ
*                                      P_REPR
*                             CHANGING V_A_ARANY
*                                      V_R_ARANY.
   ELSE.
     V_A_ARANY = 1.
     V_R_ARANY = 1.
   ENDIF.
*  kiszámítja az adóalap értékeket a i_BSEG táblában
   PERFORM ADOALAP_SZAMITAS TABLES   I_/ZAK/SZJA_CUST
                                      I_BSEG
                                      I_BKPF
                             USING    V_A_ARANY
                                      V_R_ARANY.

*  Áttölti az adatokat a /ZAK/ANALITIKA táblába.
   PERFORM ANALITIKA_TOLT TABLES   I_/ZAK/SZJA_CUST
                                   I_/ZAK/SZJA_ABEV
                                   I_/ZAK/ANALITIKA
                                   I_BSEG
                                   I_BKPF.






 ENDFORM.                    " feldolgozas
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
   SELECT  * INTO TABLE $I_BSEG
             FROM BSEG
             FOR ALL ENTRIES IN $I_BSIS
             WHERE BUKRS = $I_BSIS-BUKRS
               AND GJAHR = $I_BSIS-GJAHR
               AND BELNR = $I_BSIS-BELNR
               AND BUZEI = $I_BSIS-BUZEI.       "#EC CI_DB_OPERATION_OK[2431747]

   $SUBRC = SY-SUBRC.

*++0007 2008.01.21 BG (FMC)
*  A vállalat forgatás miatt fel kell tölteni
*  az XREF1 mezőt.
   CHECK $SUBRC IS INITIAL.

   LOOP AT $I_BSEG INTO W_BSEG.

     SELECT SINGLE XREF1 INTO W_BSEG-XREF1
                         FROM BSEG
                        WHERE BUKRS EQ W_BSEG-BUKRS
                          AND BELNR EQ W_BSEG-BELNR
                          AND GJAHR EQ W_BSEG-GJAHR
                          AND ( LIFNR NE '' OR KUNNR NE '' )
                          AND XREF1 NE ''.                    "#EC CI_DB_OPERATION_OK[2431747]
     IF SY-SUBRC EQ 0.
       MODIFY  $I_BSEG FROM W_BSEG TRANSPORTING XREF1.
     ENDIF.
   ENDLOOP.
*--0007 2008.01.21 BG (FMC)


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
*&      Form  tetel_szures
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SUBRC  text
*----------------------------------------------------------------------*
 FORM TETEL_SZURES  TABLES $BKPF   STRUCTURE BKPF
                           $BSEG   STRUCTURE BSEG
                    USING  $SUBRC.
   DATA : L_TABIX LIKE SY-TABIX.
   SORT $BKPF.
   LOOP AT $BSEG INTO W_BSEG.
*    elteszi az aktuális sor számát
     L_TABIX = SY-TABIX.
*    rákeres a fej adatra
     READ TABLE $BKPF WITH KEY BUKRS = W_BSEG-BUKRS
                               BELNR = W_BSEG-BELNR
                               GJAHR = W_BSEG-GJAHR.
*    Ha nem talát a tételhez fej adatot, akkor a tétel sem kell, mert
*    nem jó a bizonylat fajta v. a könyvelési periódus.
*    Akkor sem kell a tétel, ha a hozzárendelés WL-el kezdődik
*    (ezeket a bizonylatokat mi könyveljük)
     IF SY-SUBRC <> 0 OR W_BSEG-ZUONR(2) = 'WL'.
       DELETE $BSEG INDEX L_TABIX.
     ENDIF.

   ENDLOOP.
   IF $BSEG[] IS INITIAL.
*    nincs a fej adatoknak megfelelő BSEG tétel
     $SUBRC = 4.
   ENDIF.

 ENDFORM.                    " tetel_szures
*&---------------------------------------------------------------------*
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
*++0015 2009.05.22 BG
                               $I_KBELNR        STRUCTURE /ZAK/OUT_BELNR
*--0015 2009.05.22 BG
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
*++0011 2008.10.31 BG
   DATA L_LINES LIKE SY-TABIX.

   DESCRIBE TABLE $/ZAK/SZJA_CUST LINES L_LINES.
*--0011 2008.10.31 BG



*  a paraméter tábla alapján BSEG leválogatása
   LOOP AT $/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.
*++0011 2008.10.31 BG
*    Adatok leválogatása
     PERFORM PROGRESS_INDICATOR USING TEXT-P01
                                      L_LINES
                                      SY-TABIX.
*--0011 2008.10.31 BG

     REFRESH: LI_BSEG, LI_BKPF, LI_BSIS.

     PERFORM GET_BSIS TABLES LI_BSIS
*++0003 2009.05.22 BG
                             $I_KBELNR
*--0003 2009.05.22 BG
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

*    ellenőrzés WL (ezeket a bizonylatokat mi könyveljük)
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
       PERFORM ROTATE_BUKRS_INPUT TABLES I_AD_BUKRS         "++0017 BG
                                  USING  W_BSEG
                                         W_BKPF
                               CHANGING  L_BUKRS.
       IF L_BUKRS NE $SEL_BUKRS.
         DELETE $I_BSEG.
       ENDIF.
     ENDIF.
   ENDLOOP.
*--0006 2007.10.08  BG (FMC)

 ENDFORM.                    " szja_adatok_leval
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
*&      Form  eves_adatok_sum
*&---------------------------------------------------------------------*
*       Összeszedi az éves adatokat és kiszámolja az arányszámot
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_I_BSEG  text
*      <--P_A_SUM  text
*      <--P_R_SUM  text
*----------------------------------------------------------------------*
 FORM EVES_ADATOK_SUM TABLES   $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                               $I_BSEG          STRUCTURE BSEG
                               $R_BTYPE         STRUCTURE R_BTYPE
                               $I_ARANY         STRUCTURE I_BTYPE_ARANY
                      USING    $UZAJ
                               $REPR
                               .
*                      CHANGING $A_ARANY
*                               $R_ARANY.

   RANGES: LR_AUFNR FOR BSEG-AUFNR.
   DATA : L_TMP_ADOALAP LIKE BSEG-DMBTR.
   DATA : L_A_ADOALAP LIKE BSEG-DMBTR.
   DATA : L_R_ADOALAP LIKE BSEG-DMBTR.
   DATA : L_SZORZO TYPE I.
*++0012 2008.12.16 BG
*   DATA : L_UZAJ LIKE P_UZAJ.
*   DATA : L_REPR LIKE P_REPR.
   DATA : L_UZAJ TYPE DMBTR.
   DATA : L_REPR TYPE DMBTR.
*--0012 2008.12.16 BG

*  A szelekciós képernyő ábrázolása miatt
   L_UZAJ = $UZAJ / 100.
   L_REPR = $REPR / 100.

   LOOP AT $R_BTYPE.
     CLEAR $I_ARANY.
*++0003 BG 2007/01/05
     CLEAR: L_A_ADOALAP, L_R_ADOALAP.
*--0003 BG 2007/01/05
     LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                              WHERE /ZAK/EVES <> ' '
                                AND BTYPE EQ $R_BTYPE-LOW.

       CLEAR LR_AUFNR. REFRESH LR_AUFNR.
*    A rendelésből feltételt csinál a szelekcióhoz
       IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
         LR_AUFNR = 'IEQ'.
         LR_AUFNR-LOW = W_/ZAK/SZJA_CUST-AUFNR.
         APPEND  LR_AUFNR.
       ENDIF.

*    Végig gyalogol a megfelelő BSEG tételeken
       LOOP AT $I_BSEG INTO W_BSEG
                       WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                         AND AUFNR IN  LR_AUFNR.

*      rákeres a fej adatra
         READ TABLE I_BKPF INTO W_BKPF
                            WITH KEY BUKRS = W_BSEG-BUKRS
                                     BELNR = W_BSEG-BELNR
                                     GJAHR = W_BSEG-GJAHR.


*  Az adóalapot számítja a feltételeknek megfelelően
         PERFORM ANALITIKA_ADOALAP_SZAMITAS USING W_BSEG
                                                  W_BKPF
                                               W_/ZAK/SZJA_CUST-/ZAK/EVES
                                                W_/ZAK/SZJA_CUST-ADOALAP
                                                 W_/ZAK/SZJA_CUST-/ZAK/WL
*++0014 2010.01.08 BG
                                                  W_/ZAK/SZJA_CUST-MWSKZ
*--0014 2010.01.08 BG
                                                  1  "v_a_arany
                                                  1  "v_r_arany
                                        CHANGING L_TMP_ADOALAP.

*       IF w_bseg-shkzg = 'S'.
*         l_szorzo = 1.
*       ELSE.
*         l_szorzo = -1.
*       ENDIF.
         IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'A'.
*         l_a_adoalap = l_a_adoalap + ( w_bseg-dmbtr * l_szorzo ).
           L_A_ADOALAP = L_A_ADOALAP + L_TMP_ADOALAP.

         ELSE.
           L_R_ADOALAP = L_R_ADOALAP + L_TMP_ADOALAP.
         ENDIF.

       ENDLOOP.

     ENDLOOP.

     $I_ARANY-BTYPE = $R_BTYPE-LOW.

*  Miután megvan az adóalap, kiszámítjuk az arányszámot
     IF  L_A_ADOALAP <= L_UZAJ OR L_A_ADOALAP = 0.
*    Ha az összes adóalap nem éri el az adómentes részt,
*    az arány 0, mert nem kell számítani semmit.
*      $A_ARANY = 0.
       $I_ARANY-A_ARANY = 0.
     ELSE.
*      $A_ARANY = 1 - ( L_UZAJ / L_A_ADOALAP ).
       $I_ARANY-A_ARANY = 1 - ( L_UZAJ / L_A_ADOALAP ).
     ENDIF.
     IF  L_R_ADOALAP <= L_REPR  OR L_R_ADOALAP = 0.
*    Ha az összes adóalap nem éri el az adómentes részt,
*    az arány 0, mert nem kell számítani semmit.
*      $R_ARANY = 0.
       $I_ARANY-R_ARANY = 0.
     ELSE.
*      $R_ARANY = 1 - ( L_REPR / L_R_ADOALAP ).
       $I_ARANY-R_ARANY = 1 - ( L_REPR / L_R_ADOALAP ).
     ENDIF.
     APPEND $I_ARANY.
   ENDLOOP.

 ENDFORM.                    " eves_adatok_sum
*&---------------------------------------------------------------------*
*&      Form  adoalap_szamitas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_CUST  text
*      -->P_I_BSEG  text
*      -->P_I_BKPF  text
*      -->P_V_A_ARANY  text
*      -->P_V_R_ARANY  text
*----------------------------------------------------------------------*
 FORM ADOALAP_SZAMITAS TABLES   $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                                                  $I_BSEG STRUCTURE BSEG
                                                  $I_BKPF STRUCTURE BKPF
                                                       USING    $A_ARANY
                                                                $R_ARANY
                                                                .

   RANGES: LR_AUFNR FOR BSEG-AUFNR.
*  Az I_BSEG tábla aktuális indexér tárolja
   DATA : L_TABIX LIKE SY-TABIX.

*  Beállításokon keresztül keressük az I_BSEG rekordokat
   LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

     CLEAR LR_AUFNR. REFRESH LR_AUFNR.
*    A rendelésből feltételt csinál a szelekcióhoz
     IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
       LR_AUFNR = 'IEQ'.
       LR_AUFNR-LOW = W_/ZAK/SZJA_CUST-AUFNR.
       APPEND  LR_AUFNR.
     ENDIF.
*    Végig gyalogol a megfelelő BSEG tételeken
     LOOP AT $I_BSEG INTO W_BSEG
                     WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                       AND AUFNR IN  LR_AUFNR.
       L_TABIX = SY-TABIX.
*    rákeres a fej adatra
       READ TABLE $I_BKPF INTO W_BKPF
                          WITH KEY BUKRS = W_BSEG-BUKRS
                                   BELNR = W_BSEG-BELNR
                                   GJAHR = W_BSEG-GJAHR.
       IF SY-SUBRC <> 0.
*      Itt már nem lehet ilyen
       ENDIF.
*      WL biz.fajta esetén szorozni kell 1,2-vel
       IF W_BKPF-BLART = 'WL'.
         W_BSEG-DMBTR = W_BSEG-DMBTR * '1.2'.
       ENDIF.
*      A beállító tábla alapján szorozni kell az adóalap %-al
       W_BSEG-DMBTR = W_BSEG-DMBTR *
                      ( W_/ZAK/SZJA_CUST-ADOALAP / 100 ).
*      Az arányszámmal is szorozni kell, attól függően, hogy milyen
*      tipus  A / P
       IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'A'.
         W_BSEG-DMBTR = W_BSEG-DMBTR * $A_ARANY.
       ENDIF.
       IF W_/ZAK/SZJA_CUST-/ZAK/EVES = 'R'.
         W_BSEG-DMBTR = W_BSEG-DMBTR * $R_ARANY.
       ENDIF.
*      visszaírja az új értéket a táblába.
       MODIFY $I_BSEG FROM W_BSEG INDEX L_TABIX TRANSPORTING  DMBTR.
     ENDLOOP.
   ENDLOOP.

 ENDFORM.                    " adoalap_szamitas
*&---------------------------------------------------------------------*
*&      Form  valogat_abev_mezok
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_ABEV  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_ABEV_MEZOK  TABLES $BTYPE STRUCTURE R_BTYPE
                          USING $BUKRS
*                               $BTYPE
                                $FIELD
                          CHANGING
                               $W_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                                $SUBRC.

   SELECT SINGLE * INTO  $W_/ZAK/SZJA_ABEV
            FROM /ZAK/SZJA_ABEV
            WHERE BUKRS     = $BUKRS
*             AND BTYPE     = $BTYPE
              AND BTYPE     IN $BTYPE
              AND FIELDNAME = $FIELD.

   $SUBRC = SY-SUBRC.


 ENDFORM.                    " valogat_abev_mezok
*&---------------------------------------------------------------------*
*&      Form  analitika_tolt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ANALITIKA_TOLT    TABLES  $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                                $I_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                                $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                                         $I_BSEG          STRUCTURE BSEG
                                         $I_BKPF          STRUCTURE BKPF
                                         .


   RANGES: LR_AUFNR FOR BSEG-AUFNR.
*  Az I_BSEG tábla aktuális indexér tárolja
   DATA : L_TABIX LIKE SY-TABIX.

*  Beállításokon keresztül keressük az I_BSEG rekordokat
   LOOP AT $I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

     CLEAR LR_AUFNR. REFRESH LR_AUFNR.
*    A rendelésből feltételt csinál a szelekcióhoz
     IF NOT W_/ZAK/SZJA_CUST-AUFNR IS INITIAL.
       LR_AUFNR = 'IEQ'.
       LR_AUFNR-LOW = W_/ZAK/SZJA_CUST-AUFNR.
       APPEND  LR_AUFNR.
     ENDIF.
*    Végig gyalogol a megfelelő BSEG tételeken
     LOOP AT $I_BSEG INTO W_BSEG
                     WHERE HKONT = W_/ZAK/SZJA_CUST-SAKNR
                       AND AUFNR IN  LR_AUFNR.
       L_TABIX = SY-TABIX.
*      kikeresi, hogy az adott tételhez mikor kell analitoka
       PERFORM ANALITIKA_ATAD TABLES $I_/ZAK/SZJA_ABEV
                                     $I_/ZAK/ANALITIKA
                               USING W_BSEG
                                     W_/ZAK/SZJA_CUST.

     ENDLOOP.
   ENDLOOP.

 ENDFORM.                    " analitika_tolt
*&---------------------------------------------------------------------*
*&      Form  analitika_atad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_/ZAK/SZJA_ABEV  text
*      -->P_$I_/ZAK/ANALITIKA  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_CUST  text
*----------------------------------------------------------------------*
 FORM ANALITIKA_ATAD TABLES  $I_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                             $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                     USING   $W_BSEG          STRUCTURE BSEG
                             $W_/ZAK/SZJA_CUST STRUCTURE W_/ZAK/SZJA_CUST.
*  A % mezők meghatározása
   FIELD-SYMBOLS <FS_MEZO> TYPE ANY.

*  Végigszalad a mezőkön és átveszi a beállításból a %-ot
   LOOP AT $I_/ZAK/SZJA_ABEV INTO W_/ZAK/SZJA_ABEV.

*    átveszi a beállításból az adott % mező  (7 - 15. mező)
     ASSIGN COMPONENT W_/ZAK/SZJA_ABEV-FIELDNAME OF STRUCTURE
                      $W_/ZAK/SZJA_CUST TO <FS_MEZO>.

*    Csak akkor kell a ANALITIKA, ha a % ki van töltve
     IF NOT <FS_MEZO> IS INITIAL.

*      KITÖLTI az analitika 1 sorát.
*      PERFORM analitika_kitolt USING w_/zak/analitika
*                                      $w_/zak/szja_cust
*                                      <fs_mezo>
*                                      w_/zak/szja_abev-abevaz
*                                      $w_bseg.

*      Elmenti az analitoka rekordot.
       APPEND  W_/ZAK/ANALITIKA  TO $I_/ZAK/ANALITIKA.
     ENDIF.




   ENDLOOP.

 ENDFORM.                    " analitika_atad
*&---------------------------------------------------------------------*
*&      Form  analitika_kitolt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/ANALITIKA  text
*      -->P_<FS_MEZO>  text
*      -->P_W_BSEG  text
*----------------------------------------------------------------------*
 FORM ANALITIKA_KITOLT USING $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                             $W_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                             $W_BSEG          STRUCTURE BSEG
                             $W_BKPF          STRUCTURE BKPF
                             $W_/ZAK/BEVALL    STRUCTURE /ZAK/BEVALL
*++0006 BG 2007.10.15
                             $SEL_BUKRS
                             $BUKRS
*--0006 BG 2007.10.15
                             $SUBRC.

   DATA L_GJAHR TYPE GJAHR.
*++0005 BG 2007.05.08
   DATA L_BLDAT LIKE SY-DATUM.
*--0005 BG 2007.05.08


   CLEAR $W_/ZAK/ANALITIKA.
   CLEAR $SUBRC.
*  Minden lehetséges adatot kitölt
   MOVE-CORRESPONDING $W_BSEG TO $W_/ZAK/ANALITIKA.

*++0006 BG 2007.10.15
   MOVE $SEL_BUKRS TO $W_/ZAK/ANALITIKA-BUKRS.
   MOVE $BUKRS TO $W_/ZAK/ANALITIKA-FI_BUKRS.
*--0006 BG 2007.10.15

*  $W_/ZAK/ANALITIKA-BTYPE = P_BTYPE.
   $W_/ZAK/ANALITIKA-BTYPE = $W_/ZAK/SZJA_CUST-BTYPE.

*++0005 BG 2007.05.08
*  Nem itt határozzuk meg, hanem az ANALITIKA év és hónap
*  alapján
**  Bizonylat fajta meghatározása
*   PERFORM GET_BLART USING $W_BKPF-BLDAT
*                           P_GJAHR
*                           $W_/ZAK/BEVALL-BLART
*                  CHANGING $W_/ZAK/ANALITIKA-BLART.
*--0005 BG 2007.05.08

*  könyvelési periódus  és dátum beállítása
   IF NOT $W_/ZAK/SZJA_CUST-/ZAK/EVES IS INITIAL.
     L_GJAHR = P_GJAHR + 1.
*    Ellenőrizzük az időszakhoz a bevallás típust
     PERFORM GET_VERIFY_BTYPE_FROM_DATUM TABLES I_/ZAK/BEVALL
                                         USING  $W_/ZAK/SZJA_CUST-BTYPE
                                                L_GJAHR
*++BG 2007.04.18
*                                               '04'
                                                C_REPI_MONAT
*--BG 2007.04.18
                                                $SUBRC.

     IF $SUBRC NE 0.
       EXIT.
     ENDIF.

*Ha éves bevallás, akkor a következő év C_REPI_MONAT-ra kell beállítani
     $W_/ZAK/ANALITIKA-GJAHR = P_GJAHR + 1.
*++BG 2007.04.18
*    $W_/ZAK/ANALITIKA-MONAT = '04'.
     $W_/ZAK/ANALITIKA-MONAT = C_REPI_MONAT.
*--BG 2007.04.18
     PERFORM GET_LAST_DAY_OF_PERIOD
                               USING P_GJAHR
                                     '12'
                            CHANGING $W_/ZAK/ANALITIKA-BUDAT.

*++0005 BG 2007.05.08
*   ELSEIF $W_/ZAK/BEVALL-BLART = $W_BKPF-BLART
*       OR ( $W_BKPF-BLART(1) = 'E' )
**++ FI 20070308
*       OR ( $W_BKPF-BLART(1) = 'F' ).
**-- FI 20070308
   ELSEIF $W_BKPF-BLART IN S_KBLART.
*--0005 BG 2007.05.08

*++0005 BG 2007.05.08
**    Ellenőrizzük az időszakhoz a bevallás típust
*     PERFORM GET_VERIFY_BTYPE_FROM_DATUM TABLES I_/ZAK/BEVALL
*                                         USING  $W_/ZAK/SZJA_CUST-BTYPE
*                                                $W_BKPF-BLDAT(4)
*                                                $W_BKPF-BLDAT+4(2)
*                                                $SUBRC.
*  Meghatározzuk az időszakhoz létezik e bevallás típust
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = P_BUKRS
         I_BTYPART   = C_BTYPART_SZJA
         I_GJAHR     = $W_BKPF-BLDAT(4)
         I_MONAT     = $W_BKPF-BLDAT+4(2)
*     IMPORTING
*        E_BTYPE     =
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
*--0005 BG 2007.05.08
     IF $SUBRC NE 0.
       EXIT.
     ENDIF.


*    Ha Bizonylat típustól függ az időpont
     $W_/ZAK/ANALITIKA-GJAHR = $W_BKPF-BLDAT(4).
     $W_/ZAK/ANALITIKA-MONAT = $W_BKPF-BLDAT+4(2).
     PERFORM GET_LAST_DAY_OF_PERIOD
                            USING $W_/ZAK/ANALITIKA-GJAHR
                                  $W_/ZAK/ANALITIKA-MONAT
                         CHANGING $W_/ZAK/ANALITIKA-BUDAT.
*++0005 2009.01.12 BG
     W_/ZAK/ANALITIKA-BLDAT = $W_BKPF-BLDAT.
*--0005 2009.01.12 BG
   ELSE.

*    Ellenőrizzük az időszakhoz a bevallás típust
     PERFORM GET_VERIFY_BTYPE_FROM_DATUM TABLES I_/ZAK/BEVALL
                                         USING  $W_/ZAK/SZJA_CUST-BTYPE
                                                P_GJAHR
                                                P_MONAT
                                                $SUBRC.

     IF $SUBRC NE 0.
       EXIT.
     ENDIF.

*    Az alapeset ,
     $W_/ZAK/ANALITIKA-GJAHR = P_GJAHR.
     $W_/ZAK/ANALITIKA-MONAT = P_MONAT.

     PERFORM GET_LAST_DAY_OF_PERIOD
                            USING $W_/ZAK/ANALITIKA-GJAHR
                                  $W_/ZAK/ANALITIKA-MONAT
                         CHANGING $W_/ZAK/ANALITIKA-BUDAT.

   ENDIF.

   CHECK $SUBRC IS INITIAL.

*  Bizonylat fajta meghatározása
*   PERFORM GET_BLART USING $W_BKPF-BLDAT
*                           P_GJAHR
*                           $W_/ZAK/BEVALL-BLART
*                  CHANGING $W_/ZAK/ANALITIKA-BLART.

*++0005 BG 2007.05.08
*  a bizonylatfjata meghatározás az ANALITIKA alapján kell
   CLEAR L_BLDAT.
   CONCATENATE $W_/ZAK/ANALITIKA-GJAHR
               $W_/ZAK/ANALITIKA-MONAT
               '01' INTO L_BLDAT.
*  Bizonylat fajta meghatározása
   PERFORM GET_BLART USING L_BLDAT
                           P_GJAHR
                           $W_/ZAK/BEVALL-BLART
                  CHANGING $W_/ZAK/ANALITIKA-BLART.
*--0005 BG 2007.05.08
*++0005 2009.01.12 BG
*  Nem töltjük mert a BOOK-nál gondot okoz, ha
*  kizárt bizonylat fajta.
*  W_/ZAK/ANALITIKA-BLDAT = $W_BKPF-BLDAT.
*--0005 2009.01.12 BG

   W_/ZAK/ANALITIKA-WAERS = $W_BKPF-WAERS.
   W_/ZAK/ANALITIKA-ABEVAZ = $W_/ZAK/SZJA_CUST-ABEVAZ.
   $W_/ZAK/ANALITIKA-BSZNUM = P_BSZNUM.
   $W_/ZAK/ANALITIKA-LAPSZ = '0001'.
   $W_/ZAK/ANALITIKA-BSEG_GJAHR = $W_BSEG-GJAHR.
   $W_/ZAK/ANALITIKA-BSEG_BELNR = $W_BSEG-BELNR.
   $W_/ZAK/ANALITIKA-BSEG_BUZEI = $W_BSEG-BUZEI.
*  HA A KÖLTSÉGHELY NEM ÜRES, AKKOR ÁTTESSZÜK AZ ANALITIKÁBA
   IF NOT $W_/ZAK/SZJA_CUST-KOSTL IS INITIAL.
     $W_/ZAK/ANALITIKA-KTOSL = $W_/ZAK/SZJA_CUST-KOSTL.
   ENDIF.
*++0016 BG 2009/08/25
*  PST elem átvétele
   IF NOT $W_BSEG-PROJK IS INITIAL.
     CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
       EXPORTING
         INPUT  = $W_BSEG-PROJK
       IMPORTING
         OUTPUT = $W_/ZAK/ANALITIKA-POSID.
   ENDIF.
*--0016 BG 2009/08/25
*++0003 BG 2007/01/05
   READ TABLE I_BTYPE_ARANY WITH KEY BTYPE = $W_/ZAK/SZJA_CUST-BTYPE.
   IF SY-SUBRC EQ 0.
*--0003 BG 2007/01/05

*  Az adóalapot számítja a feltételeknek megfelelően
     PERFORM ANALITIKA_ADOALAP_SZAMITAS USING $W_BSEG
                                              $W_BKPF
                                              $W_/ZAK/SZJA_CUST-/ZAK/EVES
                                              $W_/ZAK/SZJA_CUST-ADOALAP
                                              $W_/ZAK/SZJA_CUST-/ZAK/WL
*++0014 2010.01.08 BG
                                              $W_/ZAK/SZJA_CUST-MWSKZ
*--0014 2010.01.08 BG
*++0003 BG 2007/01/05
*                                             V_A_ARANY
*                                             V_R_ARANY
                                              I_BTYPE_ARANY-A_ARANY
                                              I_BTYPE_ARANY-R_ARANY
*--0003 BG 2007/01/05
                                     CHANGING $W_/ZAK/ANALITIKA-FIELD_N.
*++0003 BG 2007/01/05
   ENDIF.
*--0003 BG 2007/01/05



 ENDFORM.                    " analitika_kitolt
*&---------------------------------------------------------------------*
*&      Form  sor_szetrak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SOR_SZETRAK USING $SUBRC.

*  végiglohol a beállítás sorokon
*  Azért ezen, mert eredetileg is ez alapján lettek leválogatva a
*  tételek és nem mindíg egyértelmű a BSEG-ből a /zak/szja_cust rekord
*  viss/zak/zakeresése.
   RANGES: L_R_AUFNR FOR BSEG-AUFNR.
*++FI 20070213
   DATA: L_SZAMLA_BELNR(10).
*--FI 20070213
*++ 0004 FI
   DATA: L_BEVHO(6).
*-- 0004 FI

   DATA L_SUBRC LIKE SY-SUBRC.


   LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.

     CLEAR W_/ZAK/BEVALL.
     READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY
                                  BUKRS = W_/ZAK/SZJA_CUST-BUKRS
                                  BTYPE = W_/ZAK/SZJA_CUST-BTYPE.
     IF SY-SUBRC NE 0.
       MESSAGE E114.
*      Bevallás típus meghatározás hiba!
     ENDIF.
*++ 0004 FI
*Ki kell hagyni, ami nem a könyvelés időszakához tartozó bevallás
*beállítás
     CONCATENATE P_GJAHR P_MONAT INTO L_BEVHO.
     IF W_/ZAK/BEVALL-DATBI(6) >= L_BEVHO AND W_/ZAK/BEVALL-DATAB(6) <=
     L_BEVHO.
     ELSE.
       CONTINUE.
     ENDIF.
*-- 0004 FI

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
*      Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor
       IF NOT W_/ZAK/SZJA_CUST-ABEVAZ IS INITIAL.
         IF NOT W_/ZAK/SZJA_CUST-/ZAK/EVES IS INITIAL
            AND P_MONAT < 12.
**          Az ÉVES-re jelöltek csak akkor kellenek, ha a hónap 12 vagy
*           nagyobb
**          egyébként nem kell őket átadni az analitokának
*           könyvelni egyébként kell
*           CONTINUE.
         ELSE.
*++0002 BG 2006/10/26
*          KITÖLTI az analitika 1 sorát.
           PERFORM ANALITIKA_KITOLT USING W_/ZAK/ANALITIKA
                                          W_/ZAK/SZJA_CUST
                                          W_BSEG
                                          W_BKPF
                                          W_/ZAK/BEVALL
*++0006 BG 2007.10.15
                                          V_SEL_BUKRS
                                          P_BUKRS
*--0006 BG 2007.10.15
                                          L_SUBRC.
           CHECK L_SUBRC EQ 0.
*--0002 BG 2006/10/26
**          ++ BG
*           PERFORM GET_ANALITIKA_ITEM TABLES I_/ZAK/ANALITIKA
*                                      USING  W_/ZAK/ANALITIKA.
**          -- BG

*          Elmenti az analitoka rekordot.
           APPEND  W_/ZAK/ANALITIKA  TO I_/ZAK/ANALITIKA.
         ENDIF.
       ENDIF.
*      WL-es könyvelés
       IF NOT W_/ZAK/SZJA_CUST-/ZAK/WL IS INITIAL
          AND W_BKPF-BLART = 'WL'.
*          Ha az adott havi a bizonylat, csak akkor kell feladni
*          Itt jöhetnek olyan tételek is amik az éves leválogatás miatt
*          nem kellenek
         IF W_BKPF-MONAT = P_MONAT.
*++FI 20070213
*           PERFORM BOOK_WL USING W_BKPF
*                                 W_BSEG
*                                 W_/ZAK/SZJA_ABEV
*                                 W_/ZAK/BEVALL
*                                 W_/ZAK/SZJA_EXCEL.
**           kiírja a rekordot
*           APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
           PERFORM BOOK_WL_V2 USING W_BKPF
                                    W_BSEG
                                    W_/ZAK/SZJA_ABEV
                                    W_/ZAK/BEVALL
                                    W_/ZAK/SZJA_EXCEL1
                                    W_/ZAK/SZJA_EXCEL2
                                    P_GJAHR
                                    P_MONAT.
*Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az
           L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
           W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
           W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*           kiírja a rekordokat
           APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
           APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.

*--FI 20070213
         ENDIF.
       ENDIF.
*      Beállítás szerinti átkönyvelés
       IF NOT W_/ZAK/SZJA_CUST-/ZAK/ATKONYV IS INITIAL.
*++FI 20070213
*         PERFORM BOOK_ATKONYV USING W_BKPF
*                               W_BSEG
*                               W_/ZAK/SZJA_ABEV
*                               W_/ZAK/BEVALL
*                               W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
*                               W_/ZAK/SZJA_EXCEL1.
**        kiírja a rekordot
*         APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
         PERFORM BOOK_ATKONYV_V2 USING W_BKPF
                                       W_BSEG
                                       W_/ZAK/SZJA_ABEV
                                       W_/ZAK/BEVALL
                                       W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
                                       W_/ZAK/SZJA_EXCEL1
                                       W_/ZAK/SZJA_EXCEL2.
*Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az
         L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
         W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
         W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*        kiírja a rekordot
         APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
         APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
*--FI 20070213

       ENDIF.
     ENDLOOP.
   ENDLOOP.




 ENDFORM.                    " sor_szetrak

*&---------------------------------------------------------------------*
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
*&      Form  valogat_/zak/bevall
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALL  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_/ZAK/BEVALL USING   $W_/ZAK/BEVALL STRUCTURE /ZAK/BEVALL
                                 $BUKRS
                                 $BTYPE
                        CHANGING $SUBRC.
   DATA  : L_DATBI LIKE  /ZAK/BEVALL-DATBI.

   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                              CHANGING L_DATBI.

   SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALL
                         FROM /ZAK/BEVALL
                        WHERE BUKRS = $BUKRS
                          AND BTYPE = $BTYPE
                          AND DATBI >= L_DATBI.
   ENDSELECT .
   $SUBRC = SY-SUBRC.
 ENDFORM.                    " valogat_/zak/bevall
*&---------------------------------------------------------------------*
*&      Form  get_last_day_of_peeriod
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_GJAHR_LOW  text
*      -->P_S_MONAT_LOW  text
*      <--P_V_LAST_DATE  text
*----------------------------------------------------------------------*
 FORM GET_LAST_DAY_OF_PERIOD USING    $GJAHR
                                      $MONAT
                              CHANGING V_LAST_DATE.

   DATA: L_DATE1 TYPE DATUM,
         L_DATE2 TYPE DATUM.

   CLEAR V_LAST_DATE.
   IF $MONAT > '12'.
     CONCATENATE $GJAHR '12' '01' INTO L_DATE1.
   ELSE.
     CONCATENATE $GJAHR $MONAT '01' INTO L_DATE1.
   ENDIF.

   CALL FUNCTION 'LAST_DAY_OF_MONTHS'     "#EC CI_USAGE_OK[2296016]
     EXPORTING
       DAY_IN            = L_DATE1
     IMPORTING
       LAST_DAY_OF_MONTH = L_DATE2
     EXCEPTIONS
       DAY_IN_NO_DATE    = 1
       OTHERS            = 2.

   IF SY-SUBRC = 0.
     V_LAST_DATE = L_DATE2.
   ENDIF.



 ENDFORM.                    " get_last_day_of_period
*&---------------------------------------------------------------------*
*&      Form  analitika_adoalap_szamitas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$W_BSEG  text
*      -->P_$W_/ZAK/SZJA_CUST_ADOALAP  text
*      <--P_$W_/ZAK/ANALITIKA_FIELD_N  text
*      <--P_ENDFORM  text
*----------------------------------------------------------------------*
 FORM ANALITIKA_ADOALAP_SZAMITAS USING    $W_BSEG  STRUCTURE BSEG
                                          $W_BKPF  STRUCTURE BKPF
                                          $/ZAK/EVES
                                          $ADOALAP%
                                          $WL
*++0014 2010.01.08 BG
                                          $MWSKZ
*--0014 2010.01.08 BG
                                          $A_ARANY
                                          $R_ARANY
                                 CHANGING $FIELD_N.
   DATA : L_SZORZO TYPE I.

*++0014 2010.01.08 BG
   DATA LI_MWDAT LIKE RTAX1U15 OCCURS 0 WITH HEADER LINE.
   DATA L_MSATZ  TYPE MSATZ_F05L.

   IF $W_BKPF-BLART = 'WL' AND $WL = 'X' AND $MWSKZ IS INITIAL.
     MESSAGE E287 WITH $W_BKPF-BUKRS $W_BKPF-GJAHR $W_BSEG-HKONT.
*   Nincs beállítva ÁFA kód WL mezőhöz /ZAK/SZJA_CUST-ban (&/&/&)!
   ENDIF.
*--0014 2010.01.08 BG

*  előjel meghatározása
   IF $W_BSEG-SHKZG = 'S'.
     L_SZORZO = 1.
   ELSE.
     L_SZORZO = -1.
   ENDIF.
   $FIELD_N = $W_BSEG-DMBTR * L_SZORZO.
*  WL biz.fajta esetén szorozni kell 1,2-vel
   IF $W_BKPF-BLART = 'WL' AND $WL = 'X'.
*++0014 2010.01.08 BG
*    $FIELD_N = $FIELD_N * '1.2'.
*  ÁFA kód százalék meghatározása
     CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
       EXPORTING
         I_BUKRS           = $W_BKPF-BUKRS
         I_MWSKZ           = $MWSKZ
*        I_TXJCD           = ' '
         I_WAERS           = $W_BKPF-WAERS
         I_WRBTR           = 0
*        I_ZBD1P           = 0
*        I_PRSDT           =
*        I_PROTOKOLL       =
*        I_TAXPS           =
*        I_ACCNT_EXT       =
*    IMPORTING
*        E_FWNAV           =
*        E_FWNVV           =
*        E_FWSTE           =
*        E_FWAST           =
       TABLES
         T_MWDAT           = LI_MWDAT
       EXCEPTIONS
         BUKRS_NOT_FOUND   = 1
         COUNTRY_NOT_FOUND = 2
         MWSKZ_NOT_DEFINED = 3
         MWSKZ_NOT_VALID   = 4
         KTOSL_NOT_FOUND   = 5
         KALSM_NOT_FOUND   = 6
         PARAMETER_ERROR   = 7
         KNUMH_NOT_FOUND   = 8
         KSCHL_NOT_FOUND   = 9
         UNKNOWN_ERROR     = 10
         ACCOUNT_NOT_FOUND = 11
         TXJCD_NOT_VALID   = 12
         OTHERS            = 13.
     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.
       READ TABLE LI_MWDAT INDEX 1.
       L_MSATZ = 1 + ( LI_MWDAT-MSATZ / 100 ).
       $FIELD_N = $FIELD_N * L_MSATZ.
     ENDIF.
*--0014 2010.01.08 BG
   ENDIF.
*  A beállító tábla alapján szorozni kell az adóalap %-al
   $FIELD_N = $FIELD_N * ( $ADOALAP% / 100 ) .
*  Az arányszámmal is szorozni kell, attól függően, hogy milyen
*  tipus  A / R
   IF $/ZAK/EVES = 'A'.
     $FIELD_N = $FIELD_N * $A_ARANY.
   ENDIF.
   IF $/ZAK/EVES = 'R'.
     $FIELD_N = $FIELD_N * $R_ARANY.
   ENDIF.



 ENDFORM.                    " analitika_adoalap_szamitas
*&---------------------------------------------------------------------*
*&      Form  Gen_analitika
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GEN_ANALITIKA.

   DATA LI_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA OCCURS 0 WITH HEADER LINE.

*Szét kell bontani bevallás típusonként
   LOOP AT R_BTYPE.
     LI_/ZAK/ANALITIKA[] = I_/ZAK/ANALITIKA[].
     DELETE LI_/ZAK/ANALITIKA WHERE BTYPE NE R_BTYPE-LOW.

     REFRESH IO_/ZAK/ANALITIKA.
     CLEAR   IO_/ZAK/ANALITIKA.

     CALL FUNCTION '/ZAK/SZJA_NEW_ROWS'
       EXPORTING
         I_BUKRS         = P_BUKRS
*        I_BTYPE         = P_BTYPE
         I_BTYPE         = R_BTYPE-LOW
         I_BSZNUM        = P_BSZNUM
       TABLES
*        I_/ZAK/ANALITIKA = I_/ZAK/ANALITIKA
         I_/ZAK/ANALITIKA = LI_/ZAK/ANALITIKA
         O_/ZAK/ANALITIKA = IO_/ZAK/ANALITIKA.
*    A kapott rekordokat visszamásolja az eredetibe.
     APPEND LINES OF IO_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
   ENDLOOP.

 ENDFORM.                    " Gen_analitika
*&---------------------------------------------------------------------*
*&      Form  call_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CALL_EXIT.
   CALL FUNCTION '/ZAK/SZJA_SAP_SEL_EXIT'
     EXPORTING
       I_BUKRS         = P_BUKRS
*      I_BTYPE         = P_BTYPE
       I_BSZNUM        = P_BSZNUM
     TABLES
       I_/ZAK/ANALITIKA = I_/ZAK/ANALITIKA.


 ENDFORM.                    " call_exit

*&---------------------------------------------------------------------*
*&      Form  ins_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INS_DATA USING $TESZT.

   DATA LI_RETURN TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0.
   DATA LW_RETURN TYPE BAPIRET2.

   DATA L_TEXTLINE1(80).
   DATA L_TEXTLINE2(80).
   DATA L_DIAGNOSETEXT1(80).
   DATA L_DIAGNOSETEXT2(80).
   DATA L_DIAGNOSETEXT3(80).
   DATA L_TITLE(40).

   DATA L_ANSWER.

   DATA L_PACK LIKE /ZAK/ANALITIKA-PACK.

   IF I_/ZAK/ANALITIKA[] IS INITIAL.
     MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
     EXIT.
   ENDIF.
*  Meg kell hívni a konverziót
   CALL FUNCTION '/ZAK/ANALITIKA_CONVERSION'
     TABLES
       T_ANALITIKA = I_/ZAK/ANALITIKA.

*  Először mindig tesztben futtatjuk
   CALL FUNCTION '/ZAK/UPDATE'
     EXPORTING
*++0006 BG 2007.10.24
*      I_BUKRS     = P_BUKRS
       I_BUKRS     = V_SEL_BUKRS
*--0006 BG 2007.10.24
*++BG 2006.09.15
*      I_BTYPE     = P_BTYPE
       I_BTYPART   = P_BTYPAR
*--BG 2006.09.15
       I_BSZNUM    = P_BSZNUM
       I_PACK      = P_PACK
       I_GEN       = 'X'
       I_TEST      = 'X'
*      I_FILE      =
     TABLES
       I_ANALITIKA = I_/ZAK/ANALITIKA
       E_RETURN    = LI_RETURN.

*   Üzenetek kezelése
   IF NOT LI_RETURN[] IS INITIAL.
     CALL FUNCTION '/ZAK/MESSAGE_SHOW'
       TABLES
         T_RETURN = LI_RETURN.
   ENDIF.

*  Ha nem teszt futás, akkor ellenőrizzük van-e ERROR
   IF NOT $TESZT IS INITIAL.
     LOOP AT LI_RETURN INTO LW_RETURN WHERE TYPE CA 'EA'.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       MESSAGE E062.
*     Adatfeltöltés nem lehetséges!
     ENDIF.
   ENDIF.

*  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról
   IF $TESZT IS INITIAL.

     IF NOT LI_RETURN[] IS INITIAL.
*    Szövegek betöltése
       MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
       MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                            TO L_DIAGNOSETEXT1.
       MOVE 'Folytatja  feldolgozást?'(003)
                                            TO L_TEXTLINE1.

*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*       CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*         EXPORTING
*           DEFAULTOPTION        = 'N'
*           DIAGNOSETEXT1        = L_DIAGNOSETEXT1
**          DIAGNOSETEXT2        = ' '
**          DIAGNOSETEXT3        = ' '
*           TEXTLINE1            = L_TEXTLINE1
**          TEXTLINE2            = ' '
*           TITEL                = L_TITLE
*           START_COLUMN         = 25
*           START_ROW            = 6
**        CANCEL_DISPLAY       = 'X'
*           IMPORTING
*           ANSWER               = L_ANSWER
*                 .
       DATA L_QUESTION TYPE STRING.

       CONCATENATE L_DIAGNOSETEXT1
                   L_TEXTLINE1
                   INTO L_QUESTION SEPARATED BY SPACE.
       CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
           TITLEBAR              = L_TITLE
*          DIAGNOSE_OBJECT       = ' '
           TEXT_QUESTION         = L_QUESTION
*          TEXT_BUTTON_1         = 'Ja'(001)
*          ICON_BUTTON_1         = ' '
*          TEXT_BUTTON_2         = 'Nein'(002)
*          ICON_BUTTON_2         = ' '
           DEFAULT_BUTTON        = '2'
*          DISPLAY_CANCEL_BUTTON = 'X'
*          USERDEFINED_F1_HELP   = ' '
           START_COLUMN          = 25
           START_ROW             = 6
*          POPUP_TYPE            =
         IMPORTING
           ANSWER                = L_ANSWER.
       IF L_ANSWER EQ '1'.
         MOVE 'J' TO L_ANSWER.
       ENDIF.
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
*++0006 BG 2007.10.24
*          I_BUKRS     = P_BUKRS
           I_BUKRS     = V_SEL_BUKRS
*--0006 BG 2007.10.24
*++BG 2006.09.15
*          I_BTYPE     = P_BTYPE
           I_BTYPART   = P_BTYPAR
*--BG 2006.09.15
           I_BSZNUM    = P_BSZNUM
           I_PACK      = P_PACK
           I_GEN       = 'X'
           I_TEST      = $TESZT
*          I_FILE      =
         TABLES
           I_ANALITIKA = I_/ZAK/ANALITIKA
           E_RETURN    = LI_RETURN.
*    Visszavezetjük az indexet
       LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
*        Elmentjük a package azonosítót
         IF L_PACK IS INITIAL.
           MOVE W_/ZAK/ANALITIKA-PACK TO L_PACK.
         ENDIF.

         INSERT INTO /ZAK/ANALITIKA VALUES W_/ZAK/ANALITIKA.

*++BG 2007.10.08
*         UPDATE /ZAK/BSET SET ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
*                       WHERE BUKRS  = W_/ZAK/ANALITIKA-BUKRS
*                         AND BELNR  = W_/ZAK/ANALITIKA-BSEG_BELNR
*                         AND BUZEI  = W_/ZAK/ANALITIKA-BSEG_BUZEI.
*--BG 2007.10.08

       ENDLOOP.
       COMMIT WORK AND WAIT.
       MESSAGE I033 WITH L_PACK.
*      Feltöltés & package számmal megtörtént!
     ENDIF.
   ENDIF.
 ENDFORM.                    " ins_data
*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

 FORM LIST_DISPLAY.
   SORT I_/ZAK/ANALITIKA BY BUKRS BTYPE BSEG_GJAHR BSEG_BELNR
                           BSEG_BUZEI ABEVAZ.
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
   IF SY-DYNNR = '9001'.
     IF P_TESZT IS INITIAL.
       SET TITLEBAR 'MAIN9001'.
     ELSE.
       SET TITLEBAR 'MAIN9001T'.
     ENDIF.
     SET PF-STATUS 'MAIN9001'.
   ENDIF.

 ENDFORM.                    " set_status
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

   CREATE OBJECT V_EVENT_RECEIVER.
   SET HANDLER V_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK  FOR V_GRID.

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
*      -->P_SY_DYNNR  text
*      <--P_$FIELDCAT  text
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
*           s_fcat-fieldname = 'DMBTR'    OR
*           s_fcat-fieldname = 'KOSTL'    OR
           S_FCAT-FIELDNAME = 'ZCOMMENT' OR
           S_FCAT-FIELDNAME = 'BOOK'     OR
           S_FCAT-FIELDNAME = 'KMONAT'."   OR
*           s_fcat-fieldname = 'AUFNR'.
         S_FCAT-NO_OUT = 'X'.
       ENDIF.
       IF S_FCAT-FIELDNAME = 'BSEG_GJAHR' OR
          S_FCAT-FIELDNAME = 'BSEG_BELNR' OR
          S_FCAT-FIELDNAME = 'BSEG_BUZEI' OR
          S_FCAT-FIELDNAME = 'AUFNR'      OR
          S_FCAT-FIELDNAME = 'HKONT'      OR
          S_FCAT-FIELDNAME = 'KOSTL'.

         S_FCAT-HOTSPOT = 'X'.
       ENDIF.

       MODIFY $FIELDCAT FROM S_FCAT.
     ENDLOOP.
   ELSEIF $DYNNR = '9001'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/SZJAEXCELV2'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = $FIELDCAT.



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
     WHEN 'EXCEL'.

       CALL SCREEN 9001.
* Kilépés
*++0005 BG 2007.05.08
*    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
     WHEN 'BACK'.
*--0005 BG 2007.05.08
       PERFORM EXIT_PROGRAM.
*++0005 BG 2007.05.08
     WHEN 'EXIT' OR 'CANCEL'.
       LEAVE PROGRAM.
*--0005 BG 2007.05.08
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
 FORM EXIT_PROGRAM.
   LEAVE TO SCREEN 0 .
 ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  book_wl_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM BOOK_WL_V2 USING $BKPF STRUCTURE BKPF
                    $BSEG STRUCTURE BSEG
                    $ABEV STRUCTURE /ZAK/SZJA_ABEV
                    $BEVALL STRUCTURE /ZAK/BEVALL
                    $EXCEL1 STRUCTURE /ZAK/SZJAEXCELV2
                    $EXCEL2 STRUCTURE /ZAK/SZJAEXCELV2
                    $GJAHR
                    $MONAT.

   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL1,$EXCEL2.
*++0014 2009.04.20 BG
   DATA LI_MWDAT LIKE RTAX1U15 OCCURS 0 WITH HEADER LINE.
   DATA L_MSATZ  TYPE MSATZ_F05L.
*--0014 2009.04.20 BG

*  sorszám meghatározása
   $EXCEL1-BIZ_TETEL = '0001' .
   $EXCEL2-BIZ_TETEL = '0002' .
   $EXCEL1-PENZNEM = $BKPF-WAERS.
   $EXCEL2-PENZNEM = $BKPF-WAERS.
*  Bizonylat fajta meghatározása
   PERFORM GET_BLART USING $BKPF-BLDAT
                           $GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL1-BF   .
   $EXCEL2-BF = $EXCEL1-BF.
*++ 0004 FI
   $EXCEL1-KK = '40'.
   $EXCEL2-KK = '50'.
*-- 0004 FI

*++0014 2009.04.20 BG
*  ÁFA kód százalék meghatározása
   CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
     EXPORTING
       I_BUKRS           = $BKPF-BUKRS
       I_MWSKZ           = $ABEV-MWSKZ
*      I_TXJCD           = ' '
       I_WAERS           = $BKPF-WAERS
       I_WRBTR           = 0
*      I_ZBD1P           = 0
*      I_PRSDT           =
*      I_PROTOKOLL       =
*      I_TAXPS           =
*      I_ACCNT_EXT       =
*    IMPORTING
*      E_FWNAV           =
*      E_FWNVV           =
*      E_FWSTE           =
*      E_FWAST           =
     TABLES
       T_MWDAT           = LI_MWDAT
     EXCEPTIONS
       BUKRS_NOT_FOUND   = 1
       COUNTRY_NOT_FOUND = 2
       MWSKZ_NOT_DEFINED = 3
       MWSKZ_NOT_VALID   = 4
       KTOSL_NOT_FOUND   = 5
       KALSM_NOT_FOUND   = 6
       PARAMETER_ERROR   = 7
       KNUMH_NOT_FOUND   = 8
       KSCHL_NOT_FOUND   = 9
       UNKNOWN_ERROR     = 10
       ACCOUNT_NOT_FOUND = 11
       TXJCD_NOT_VALID   = 12
       OTHERS            = 13.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     READ TABLE LI_MWDAT INDEX 1.
     L_MSATZ = LI_MWDAT-MSATZ / 100.
   ENDIF.
*--0014 2009.04.20 BG

   IF $BSEG-SHKZG = 'S'.
     MOVE   $BSEG-HKONT   TO $EXCEL1-FOKONYV.
     MOVE   $ABEV-KOVETEL TO $EXCEL2-FOKONYV.
*++0014 2009.04.20 BG
*    L_TMP_DMBTR = $BSEG-DMBTR * '0.2'.
     L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG

     MOVE   $BSEG-AUFNR   TO $EXCEL1-RENDELES. CLEAR $EXCEL2-RENDELES.
*++ 2009.03.30. BG
*     MOVE   'B3'          TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
*++0014 2009.04.20 BG
*     MOVE   'B4'          TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
     MOVE   $ABEV-MWSKZ    TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
*--0014 2009.04.20 BG
*-- 2009.03.30. BG
     MOVE   $BSEG-KOSTL   TO $EXCEL1-KTGH.     CLEAR $EXCEL2-KTGH.
     MOVE   $BSEG-PRCTR   TO $EXCEL1-PRCTR.    CLEAR $EXCEL2-PRCTR.
*++0015 BG 2009/08/25
*    PST elem töltése
     IF NOT $BSEG-PROJK IS INITIAL.
       CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
         EXPORTING
           INPUT  = $BSEG-PROJK
         IMPORTING
           OUTPUT = $EXCEL1-PST.
     ENDIF.
*--0015 BG 2009/08/25
*++ 0004 FI
*     $EXCEL1-KK = '40'.
*     $EXCEL2-KK = '50'.
*-- 0004 FI

   ELSE.
*    Ha az érték negatív, akkor cserélődik az 1 és 2
     MOVE   $BSEG-HKONT   TO $EXCEL2-FOKONYV.
     MOVE   $ABEV-KOVETEL TO $EXCEL1-FOKONYV.
*++ 0004 FI
*     L_TMP_DMBTR = $BSEG-DMBTR * '0.2' * -1.
*++0014 2009.04.20 BG
*    L_TMP_DMBTR = $BSEG-DMBTR * '0.2'.
     L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG
*-- 0004 FI
     MOVE   $BSEG-AUFNR   TO $EXCEL2-RENDELES. CLEAR $EXCEL1-RENDELES.
*++ 2009.03.30. BG
*     MOVE   'B3'          TO $EXCEL1-ADOKOD.   CLEAR $EXCEL2-ADOKOD.
*++0014 2009.04.20 BG
*     MOVE   'B4'          TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
     MOVE   $ABEV-MWSKZ   TO $EXCEL2-ADOKOD.   CLEAR $EXCEL1-ADOKOD.
*--0014 2009.04.20 BG
*-- 2009.03.30. BG
     MOVE   $BSEG-KOSTL   TO $EXCEL2-KTGH.     CLEAR $EXCEL1-KTGH.
     MOVE   $BSEG-PRCTR   TO $EXCEL2-PRCTR.    CLEAR $EXCEL1-PRCTR.
*++0015 BG 2009/08/25
*    PST elem töltése
     IF NOT $BSEG-PROJK IS INITIAL.
       CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
         EXPORTING
           INPUT  = $BSEG-PROJK
         IMPORTING
           OUTPUT = $EXCEL2-PST.
     ENDIF.
*--0015 BG 2009/08/25
*++ 0004 FI
*     $EXCEL1-KK = '50'.
*     $EXCEL2-KK = '40'.
*-- 0004 FI
   ENDIF.

   WRITE  $BKPF-BLDAT   TO $EXCEL1-BIZ_DATUM.
   WRITE  $BKPF-BLDAT   TO $EXCEL2-BIZ_DATUM.

*   MOVE   $BKPF-BUKRS   TO $EXCEL1-VALL.
*   MOVE   $BKPF-BUKRS   TO $EXCEL2-VALL.

*  Az érték abszulut értékben kell
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).
   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL1-OSSZEG.
   PERFORM SZAM_ATIR USING $EXCEL1-OSSZEG.
   $EXCEL2-OSSZEG = $EXCEL1-OSSZEG.
*  szelekciós periódus utolsó napjának meghatározása
   PERFORM GET_LAST_DAY_OF_PERIOD USING $GJAHR
                                        $MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL1-KONYV_DAT.
   $EXCEL2-KONYV_DAT = $EXCEL1-KONYV_DAT.
*++2009.01.12 BG
*  Nem volt megfelelő mert az UREPI-nél
*  amikor teljes évet válogattunk a decemberi
*  könyveléseknél volt előző időszak is
*   MOVE   $BKPF-MONAT   TO $EXCEL1-HO.
*   MOVE   $BKPF-MONAT   TO $EXCEL2-HO.
   MOVE   $MONAT   TO $EXCEL1-HO.
   MOVE   $MONAT   TO $EXCEL2-HO.
*--2009.01.12 BG

*   MOVE   'X'           TO $EXCEL-ASZ. !!!!????
   CONCATENATE 'WL' $BSEG-BELNR
               INTO  $EXCEL1-HOZZARENDELES
                     SEPARATED BY SPACE.
   $EXCEL2-HOZZARENDELES  = $EXCEL1-HOZZARENDELES.

   CONCATENATE $BSEG-BELNR '-' $BSEG-EBELN
                      INTO $EXCEL1-SZOVEG
                      SEPARATED BY SPACE.
   $EXCEL2-SZOVEG  = $EXCEL1-SZOVEG.

   MOVE   $BSEG-VBUND   TO $EXCEL1-PARTN_TARS.
   MOVE   $BSEG-VBUND   TO $EXCEL2-PARTN_TARS.
   IF $BKPF-BKTXT IS NOT INITIAL.
     MOVE   $BKPF-BKTXT   TO $EXCEL1-FEJSZOVEG.
     MOVE   $BKPF-BKTXT   TO $EXCEL2-FEJSZOVEG.
   ELSE.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL1-FEJSZOVEG.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL2-FEJSZOVEG.

   ENDIF.

 ENDFORM.                    " book_wl_v2
*&---------------------------------------------------------------------*
*&      Form  book_wl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM BOOK_WL USING $BKPF STRUCTURE BKPF
                    $BSEG STRUCTURE BSEG
                    $ABEV STRUCTURE /ZAK/SZJA_ABEV
                    $BEVALL STRUCTURE /ZAK/BEVALL
                    $EXCEL STRUCTURE /ZAK/SZJA_EXCEL.
   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL.
*  Bizonylat fajta meghatározása
   PERFORM GET_BLART USING $BKPF-BLDAT
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL-BF   .

   IF $BSEG-SHKZG = 'S'.
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA1.
     MOVE   $ABEV-KOVETEL TO $EXCEL-SZAMLA2.
     L_TMP_DMBTR = $BSEG-DMBTR * '0.2'.
     MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL1. CLEAR $EXCEL-B_RENDEL2.
     MOVE   'B3'          TO $EXCEL-ADO2.      CLEAR $EXCEL-ADO1.
     MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH1.     CLEAR $EXCEL-KTGH2.
     MOVE   $BSEG-PRCTR   TO $EXCEL-PRCTR1.    CLEAR $EXCEL-PRCTR2.

   ELSE.
*    Ha az érték negatív, akkor cserélődik az 1 és 2
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA2.
     MOVE   $ABEV-KOVETEL TO $EXCEL-SZAMLA1.
     L_TMP_DMBTR = $BSEG-DMBTR * '0.2' * -1.
     MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL2. CLEAR $EXCEL-B_RENDEL1.
     MOVE   'B3'          TO $EXCEL-ADO1.      CLEAR $EXCEL-ADO2.
     MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH2.     CLEAR $EXCEL-KTGH1.
     MOVE   $BSEG-PRCTR   TO $EXCEL-PRCTR2.    CLEAR $EXCEL-PRCTR1.
   ENDIF.

   WRITE  $BKPF-BLDAT   TO $EXCEL-BIZ_DATUM.
*   MOVE   $bevall-blart TO $excel-bf.
   MOVE   $BKPF-BUKRS   TO $EXCEL-VALL.
*  Az érték abszulut értékben kell
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).
   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL-FORINT.
   PERFORM SZAM_ATIR USING $EXCEL-FORINT.
*  szelekciós periódus utolsó napjának meghatározása
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL-KONYV_DAT.
   MOVE   $BKPF-MONAT   TO $EXCEL-HO.
*   MOVE   $bkpf-bktxt   TO $excel-fejszoveg. !!!!!!!!!!!!!!!!!!!!!!!
   MOVE   'X'           TO $EXCEL-ASZ.
   CONCATENATE 'WL' $BSEG-BELNR
* ++ FI 20070111
*               INTO  $EXCEL-HOZZARENDEL
               INTO  $EXCEL-HOZZARENDEL1
                     SEPARATED BY SPACE.
   $EXCEL-HOZZARENDEL2  = $EXCEL-HOZZARENDEL1.
* -- FI 20070111
*   MOVE   $BSEG-BELNR   TO $EXCEL-HOZZARENDEL.

   CONCATENATE $BSEG-BELNR '-' $BSEG-EBELN
* ++ FI 20070111
*                      INTO $EXCEL-SZOVEG
                      INTO $EXCEL-SZOVEG1
                      SEPARATED BY SPACE.
   $EXCEL-SZOVEG2 = $EXCEL-SZOVEG1.
*  MOVE   $BSEG-VBUND   TO $EXCEL-PATARS.
   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS1.
* -- FI 20070111




 ENDFORM.                    " book_wl
*&---------------------------------------------------------------------*
*&      Form  book_atkonyv_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BKPF  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_W_/ZAK/BEVALL  text
*      -->P_W_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM BOOK_ATKONYV_V2 USING $BKPF          STRUCTURE BKPF
                            $BSEG          STRUCTURE BSEG
                            $ABEV          STRUCTURE /ZAK/SZJA_ABEV
                            $BEVALL        STRUCTURE /ZAK/BEVALL
                            $/ZAK/ATKONYV
                            $EXCEL1        STRUCTURE /ZAK/SZJAEXCELV2
                            $EXCEL2        STRUCTURE /ZAK/SZJAEXCELV2.
   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL1, $EXCEL2.

*++0005 BG 2007.05.08
   DATA L_BLDAT LIKE SY-DATUM.
*--0005 BG 2007.05.08

*++0014 2009.04.20 BG
   DATA LI_MWDAT LIKE RTAX1U15 OCCURS 0 WITH HEADER LINE.
   DATA L_MSATZ  TYPE MSATZ_F05L.
*--0014 2009.04.20 BG

*  sorszám meghatározása
   $EXCEL1-BIZ_TETEL = '0001' .
   $EXCEL2-BIZ_TETEL = '0002' .
   $EXCEL1-PENZNEM = $BKPF-WAERS.
   $EXCEL2-PENZNEM = $BKPF-WAERS.

*++0014 2009.04.20 BG
*  ÁFA kód százalék meghatározása
   CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
     EXPORTING
       I_BUKRS           = $BKPF-BUKRS
       I_MWSKZ           = $ABEV-MWSKZ
*      I_TXJCD           = ' '
       I_WAERS           = $BKPF-WAERS
       I_WRBTR           = 0
*      I_ZBD1P           = 0
*      I_PRSDT           =
*      I_PROTOKOLL       =
*      I_TAXPS           =
*      I_ACCNT_EXT       =
*    IMPORTING
*      E_FWNAV           =
*      E_FWNVV           =
*      E_FWSTE           =
*      E_FWAST           =
     TABLES
       T_MWDAT           = LI_MWDAT
     EXCEPTIONS
       BUKRS_NOT_FOUND   = 1
       COUNTRY_NOT_FOUND = 2
       MWSKZ_NOT_DEFINED = 3
       MWSKZ_NOT_VALID   = 4
       KTOSL_NOT_FOUND   = 5
       KALSM_NOT_FOUND   = 6
       PARAMETER_ERROR   = 7
       KNUMH_NOT_FOUND   = 8
       KSCHL_NOT_FOUND   = 9
       UNKNOWN_ERROR     = 10
       ACCOUNT_NOT_FOUND = 11
       TXJCD_NOT_VALID   = 12
       OTHERS            = 13.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     READ TABLE LI_MWDAT INDEX 1.
     L_MSATZ = 1 + ( LI_MWDAT-MSATZ / 100 ).
   ENDIF.
*--0014 2009.04.20 BG

*++0005 BG 2007.05.08
*  Bizonylatfajtához dátum meghatározás
   CLEAR L_BLDAT.
   IF $BKPF-BLART IN S_KBLART.
     MOVE $BKPF-BLDAT TO L_BLDAT.
   ELSE.
     CONCATENATE P_GJAHR
                 P_MONAT
                 '01' INTO L_BLDAT.
   ENDIF.
*--0005 BG 2007.05.08

*  Bizonylat fajta meghatározása
*++0005 BG 2007.05.08
*  PERFORM GET_BLART USING $BKPF-BLDAT
   PERFORM GET_BLART USING L_BLDAT
*--0005 BG 2007.05.08
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL1-BF   .


   $EXCEL2-BF = $EXCEL1-BF.
*++ 0004 FI
   $EXCEL1-KK = '40'.
   $EXCEL2-KK = '50'.
*-- 0004 FI

   IF $BSEG-SHKZG = 'S'.
     MOVE   $/ZAK/ATKONYV  TO $EXCEL1-FOKONYV.
     MOVE   $BSEG-HKONT   TO $EXCEL2-FOKONYV.
*    WL esetén szorozni 1.2-vel
     IF $BKPF-BLART = 'WL'.
*++0014 2009.04.20 BG
*      L_TMP_DMBTR = $BSEG-DMBTR * '1.2'.
       L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG
     ELSE.
       L_TMP_DMBTR = $BSEG-DMBTR .
     ENDIF.
*++ 0004 FI
*     $EXCEL1-KK = '40'.
*     $EXCEL2-KK = '50'.
*-- 0004 FI
   ELSE.
*    Ha az érték negatív, akkor cserélődik az 1 és 2
     MOVE   $/ZAK/ATKONYV  TO $EXCEL2-FOKONYV.
     MOVE   $BSEG-HKONT   TO $EXCEL1-FOKONYV.
*    WL esetén szorozni 1.2-vel
     IF $BKPF-BLART = 'WL'.
*++ 0004 FI
*       L_TMP_DMBTR = $BSEG-DMBTR * '1.2' * -1.
*++0014 2009.04.20 BG
*      L_TMP_DMBTR = $BSEG-DMBTR * '1.2'.
       L_TMP_DMBTR = $BSEG-DMBTR * L_MSATZ.
*--0014 2009.04.20 BG
*-- 0004 FI
     ELSE.
*++ 0004 FI
*       L_TMP_DMBTR = $BSEG-DMBTR * -1.
       L_TMP_DMBTR = $BSEG-DMBTR .
*-- 0004 FI
     ENDIF.
*++ 0004 FI
*     $EXCEL1-KK = '50'.
*     $EXCEL2-KK = '40'.
*-- 0004 FI

   ENDIF.
   MOVE   $BSEG-VBUND   TO $EXCEL1-PARTN_TARS.

   MOVE   $BSEG-AUFNR   TO $EXCEL1-RENDELES.
   MOVE   $BSEG-AUFNR   TO $EXCEL2-RENDELES.
   MOVE   $BSEG-KOSTL   TO $EXCEL1-KTGH.
   MOVE   $BSEG-KOSTL   TO $EXCEL2-KTGH.
   MOVE   $BSEG-PPRCT   TO $EXCEL1-PRCTR.
   MOVE   $BSEG-PPRCT   TO $EXCEL2-PRCTR.
   WRITE  $BKPF-BLDAT   TO $EXCEL1-BIZ_DATUM.
   WRITE  $BKPF-BLDAT   TO $EXCEL2-BIZ_DATUM.
*   MOVE   $BKPF-BUKRS   TO $EXCEL-VALL.
*  Az érték abszulut értékben kell
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).

   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL1-OSSZEG.
   PERFORM SZAM_ATIR USING $EXCEL1-OSSZEG.

   $EXCEL2-OSSZEG = $EXCEL1-OSSZEG.
*  szelekciós periódus utolsó napjának meghatározása
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL1-KONYV_DAT.
   WRITE  L_TMP_DAT     TO $EXCEL2-KONYV_DAT.
   MOVE   $BKPF-MONAT   TO $EXCEL1-HO.
   MOVE   $BKPF-MONAT   TO $EXCEL2-HO.
   MOVE   $BSEG-BELNR   TO $EXCEL1-SZOVEG.
   MOVE   $BSEG-BELNR   TO $EXCEL2-SZOVEG.
   MOVE   $BSEG-VBUND   TO $EXCEL1-PARTN_TARS.
   MOVE   $BSEG-VBUND   TO $EXCEL2-PARTN_TARS.
   MOVE   $BSEG-PPRCT   TO $EXCEL1-PARPRCTR.
   MOVE   $BSEG-PPRCT   TO $EXCEL2-PARPRCTR.
   IF $BKPF-BKTXT IS NOT INITIAL.
     MOVE   $BKPF-BKTXT   TO $EXCEL1-FEJSZOVEG.
     MOVE   $BKPF-BKTXT   TO $EXCEL2-FEJSZOVEG.
   ELSE.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL1-FEJSZOVEG.
     MOVE   $EXCEL1-SZOVEG   TO $EXCEL2-FEJSZOVEG.

   ENDIF.
*++0015 BG 2009/08/25
*    PST elem töltése
   IF NOT $BSEG-PROJK IS INITIAL.
     CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
       EXPORTING
         INPUT  = $BSEG-PROJK
       IMPORTING
         OUTPUT = $EXCEL1-PST.
   ENDIF.
*--0015 BG 2009/08/25

 ENDFORM.                    " book_atkonyv_v2
*&---------------------------------------------------------------------*
*&      Form  book_atkonyv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BKPF  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_W_/ZAK/BEVALL  text
*      -->P_W_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM BOOK_ATKONYV USING    $BKPF          STRUCTURE BKPF
                            $BSEG          STRUCTURE BSEG
                            $ABEV          STRUCTURE /ZAK/SZJA_ABEV
                            $BEVALL        STRUCTURE /ZAK/BEVALL
                            $/ZAK/ATKONYV
                            $EXCEL         STRUCTURE /ZAK/SZJA_EXCEL.
   DATA : L_TMP_DAT   LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR.
   CLEAR : $EXCEL.
*  Bizonylat fajta meghatározása
   PERFORM GET_BLART USING $BKPF-BLDAT
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL-BF   .

   IF $BSEG-SHKZG = 'S'.
     MOVE   $/ZAK/ATKONYV  TO $EXCEL-SZAMLA1.
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA2.
*    WL esetén szorozni 1.2-vel
     IF $BKPF-BLART = 'WL'.
       L_TMP_DMBTR = $BSEG-DMBTR * '1.2'.
     ELSE.
       L_TMP_DMBTR = $BSEG-DMBTR .
     ENDIF.
   ELSE.
*    Ha az érték negatív, akkor cserélődik az 1 és 2
     MOVE   $/ZAK/ATKONYV  TO $EXCEL-SZAMLA2.
     MOVE   $BSEG-HKONT   TO $EXCEL-SZAMLA1.
*    WL esetén szorozni 1.2-vel
     IF $BKPF-BLART = 'WL'.
       L_TMP_DMBTR = $BSEG-DMBTR * '1.2' * -1.
     ELSE.
       L_TMP_DMBTR = $BSEG-DMBTR * -1.
     ENDIF.

   ENDIF.
* ++ FI 20070111
*   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS.
   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS1.
* -- FI 20070111
   MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL1.
   MOVE   $BSEG-AUFNR   TO $EXCEL-B_RENDEL2.
   MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH1.
   MOVE   $BSEG-KOSTL   TO $EXCEL-KTGH2.
   MOVE   $BSEG-PPRCT   TO $EXCEL-PRCTR1.
   MOVE   $BSEG-PPRCT   TO $EXCEL-PRCTR2.
   WRITE  $BKPF-BLDAT   TO $EXCEL-BIZ_DATUM.
*   MOVE   $bevall-blart TO $excel-bf.
   MOVE   $BKPF-BUKRS   TO $EXCEL-VALL.
*  Az érték abszulut értékben kell
   L_TMP_DMBTR = ABS( L_TMP_DMBTR ).

   WRITE  L_TMP_DMBTR CURRENCY $BKPF-WAERS
                        TO $EXCEL-FORINT.
   PERFORM SZAM_ATIR USING $EXCEL-FORINT.
*  szelekciós periódus utolsó napjának meghatározása
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING L_TMP_DAT .
   WRITE  L_TMP_DAT     TO $EXCEL-KONYV_DAT.
   MOVE   $BKPF-MONAT   TO $EXCEL-HO.
*   MOVE   $bkpf-bktxt   TO $excel-fejszoveg. !!!!!!!!!!!!
* ++ FI 20070111
*   MOVE   $BSEG-BELNR   TO $EXCEL-SZOVEG.
*   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS.
*   MOVE   $BSEG-PPRCT   TO $EXCEL-PARPROFC.
   MOVE   $BSEG-BELNR   TO $EXCEL-SZOVEG1.
   MOVE   $BSEG-VBUND   TO $EXCEL-PATARS1.
   MOVE   $BSEG-PPRCT   TO $EXCEL-PARPROFC1.
* ++ FI 20070111

 ENDFORM.                    " book_atkonyv
*&---------------------------------------------------------------------*
*&      Form  download_file_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE_V2 TABLES $EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                        USING $OUTF
                     CHANGING L_SUBRC.
*   TABLES : DD03T.
   DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
         L_CANCEL(1).

   DATA: BEGIN OF I_FIELDS OCCURS 10,
           NAME(40),
         END OF I_FIELDS.

   DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

* Adatszerkezet beolvasása
   CALL FUNCTION 'DD_GET_DD03P_ALL'
     EXPORTING
       LANGU         = SYST-LANGU
       TABNAME       = '/ZAK/SZJAEXCELV2'
     TABLES
       A_DD03P_TAB   = I_DD03P
       N_DD03P_TAB   = I_DD03P_2
     EXCEPTIONS
       ILLEGAL_VALUE = 1
       OTHERS        = 2.

   IF SY-SUBRC = 0.

     LOOP AT I_DD03P WHERE  FIELDNAME <> '.INCLUDE'.
       CLEAR I_FIELDS-NAME.
       I_FIELDS-NAME = I_DD03P-DDTEXT.
       APPEND I_FIELDS.
     ENDLOOP.

   ENDIF.
*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28

*   CALL FUNCTION 'WS_DOWNLOAD'
*        EXPORTING
*             FILENAME                = $OUTF
*             FILETYPE                = 'DAT'
**       IMPORTING
**            CANCEL                  = L_CANCEL
*        TABLES
*             DATA_TAB                = $EXCEL
*             FIELDNAMES              = I_FIELDS
*        EXCEPTIONS
*             INVALID_FILESIZE        = 1
*             INVALID_TABLE_WIDTH     = 2
*             INVALID_TYPE            = 3
*             NO_BATCH                = 4
*             UNKNOWN_ERROR           = 5
*             GUI_REFUSE_FILETRANSFER = 6
*             CUSTOMER_ERROR          = 7
*             OTHERS                  = 8.
   DATA L_FILENAME_STRING TYPE STRING.

   MOVE $OUTF TO L_FILENAME_STRING.


   CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
     EXPORTING
       FILENAME                = L_FILENAME_STRING
       FILETYPE                = 'DAT'
       FIELDNAMES              = I_FIELDS[]
     CHANGING
       DATA_TAB                = $EXCEL[]
     EXCEPTIONS
       FILE_WRITE_ERROR        = 1
       NO_BATCH                = 2
       GUI_REFUSE_FILETRANSFER = 3
       INVALID_TYPE            = 4
       NO_AUTHORITY            = 5
       UNKNOWN_ERROR           = 6
       HEADER_NOT_ALLOWED      = 7
       SEPARATOR_NOT_ALLOWED   = 8
       FILESIZE_NOT_ALLOWED    = 9
       HEADER_TOO_LONG         = 10
       DP_ERROR_CREATE         = 11
       DP_ERROR_SEND           = 12
       DP_ERROR_WRITE          = 13
       UNKNOWN_DP_ERROR        = 14
       ACCESS_DENIED           = 15
       DP_OUT_OF_MEMORY        = 16
       DISK_FULL               = 17
       DP_TIMEOUT              = 18
       FILE_NOT_FOUND          = 19
       DATAPROVIDER_EXCEPTION  = 20
       CONTROL_FLUSH_ERROR     = 21
       NOT_SUPPORTED_BY_GUI    = 22
       ERROR_NO_GUI            = 23
       OTHERS                  = 24.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.


 ENDFORM.                    " download_file_v2
*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE TABLES $EXCEL STRUCTURE /ZAK/SZJA_EXCEL
                    USING  $OUTF
                    CHANGING L_SUBRC.
   TABLES : DD03T.
   DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
         L_CANCEL(1).

   DATA: BEGIN OF I_FIELDS OCCURS 10,
           NAME(40),
         END OF I_FIELDS.

   DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03T   LIKE DD03T OCCURS 0 WITH HEADER LINE.


   SELECT * FROM DD03T INTO TABLE I_DD03T
            WHERE TABNAME = '/ZAK/SZJA_EXCEL'
              AND DDLANGUAGE = SYST-LANGU.




*  concatenate p_bukrs l_adonem l_esdat into l_def_filename
*    separated by '_'.
*  concatenate l_def_filename '.XLS' into l_def_filename.

* Adatszerkezet beolvasása
   CALL FUNCTION 'DD_GET_DD03P_ALL'
     EXPORTING
       LANGU         = SYST-LANGU
       TABNAME       = '/ZAK/SZJA_EXCEL'
     TABLES
       A_DD03P_TAB   = I_DD03P
       N_DD03P_TAB   = I_DD03P_2
     EXCEPTIONS
       ILLEGAL_VALUE = 1
       OTHERS        = 2.

   IF SY-SUBRC = 0.

     LOOP AT I_DD03P.
       CLEAR I_FIELDS-NAME.
       READ TABLE I_DD03T WITH KEY FIELDNAME = I_DD03P-FIELDNAME.
       I_FIELDS-NAME = I_DD03T-DDTEXT.
       APPEND I_FIELDS.
     ENDLOOP.

   ENDIF.

*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
*   CALL FUNCTION 'WS_DOWNLOAD'
*        EXPORTING
*             FILENAME                = $OUTF
*             FILETYPE                = 'DAT'
**       IMPORTING
**            CANCEL                  = L_CANCEL
*        TABLES
*             DATA_TAB                = $EXCEL
*             FIELDNAMES              = I_FIELDS
*        EXCEPTIONS
*             INVALID_FILESIZE        = 1
*             INVALID_TABLE_WIDTH     = 2
*             INVALID_TYPE            = 3
*             NO_BATCH                = 4
*             UNKNOWN_ERROR           = 5
*             GUI_REFUSE_FILETRANSFER = 6
*             CUSTOMER_ERROR          = 7
*             OTHERS                  = 8.
   DATA L_FILENAME_STRING TYPE STRING.

   MOVE $OUTF TO L_FILENAME_STRING.


   CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
     EXPORTING
       FILENAME                = L_FILENAME_STRING
       FILETYPE                = 'DAT'
       FIELDNAMES              = I_FIELDS[]
     CHANGING
       DATA_TAB                = $EXCEL[]
     EXCEPTIONS
       FILE_WRITE_ERROR        = 1
       NO_BATCH                = 2
       GUI_REFUSE_FILETRANSFER = 3
       INVALID_TYPE            = 4
       NO_AUTHORITY            = 5
       UNKNOWN_ERROR           = 6
       HEADER_NOT_ALLOWED      = 7
       SEPARATOR_NOT_ALLOWED   = 8
       FILESIZE_NOT_ALLOWED    = 9
       HEADER_TOO_LONG         = 10
       DP_ERROR_CREATE         = 11
       DP_ERROR_SEND           = 12
       DP_ERROR_WRITE          = 13
       UNKNOWN_DP_ERROR        = 14
       ACCESS_DENIED           = 15
       DP_OUT_OF_MEMORY        = 16
       DISK_FULL               = 17
       DP_TIMEOUT              = 18
       FILE_NOT_FOUND          = 19
       DATAPROVIDER_EXCEPTION  = 20
       CONTROL_FLUSH_ERROR     = 21
       NOT_SUPPORTED_BY_GUI    = 22
       ERROR_NO_GUI            = 23
       OTHERS                  = 24.



*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.


 ENDFORM.                    " download_file
*&---------------------------------------------------------------------*
*&      Form  get_blart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BLDAT  text
*      -->P_P_GJAHR  text
*      -->P_I_BLART  text
*      <--P_O_BLART  text
*----------------------------------------------------------------------*
 FORM GET_BLART USING    $BLDAT
                         $P_GJAHR
                         $I_BLART
                CHANGING $O_BLART.
   DATA: L_GJAHR LIKE BKPF-GJAHR,
         L_DIF   TYPE I,
         L_EV(1).

   L_GJAHR = $BLDAT(4). " A bizdátumból leveszi az évet.
   L_DIF = L_GJAHR - $P_GJAHR.
   IF L_DIF < 0.
*    Az előző évet érinti
     L_DIF = ABS( L_DIF ).
     WRITE: L_DIF TO L_EV.
     $O_BLART(1) = 'E'.
     $O_BLART+1(1) = L_EV.
   ELSE.
     $O_BLART = $I_BLART.
   ENDIF.


 ENDFORM.                    " get_blart
*&---------------------------------------------------------------------*
*&      Form  szam_atir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$EXCEL_FORINT  text
*----------------------------------------------------------------------*
 FORM SZAM_ATIR USING    $FORINT.
   TRANSLATE $FORINT USING ', '.
   TRANSLATE $FORINT USING '. '.
   CONDENSE $FORINT NO-GAPS .
   SHIFT $FORINT RIGHT DELETING TRAILING SPACE.
   IF $FORINT+12(1) = '-'.
     $FORINT(1) = '-'.
     $FORINT+12(1) = ' '.
     CONDENSE $FORINT NO-GAPS .
   ENDIF.
 ENDFORM.                    " szam_atir
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
*++BG 2006/12/06
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'LB'     TO S_BLART-LOW.
   APPEND S_BLART.
*--BG 2006/12/06
*++FI 2007/03/08
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
*--FI 2007/03/08
*++00013 2009.04.08
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SR'     TO S_BLART-LOW.
   APPEND S_BLART.
*--00013 2009.04.08

*++0018 2010.04.20
   MOVE:   'E'      TO S_BLART-SIGN,
           'EQ'     TO S_BLART-OPTION,
           'SC'     TO S_BLART-LOW.
   APPEND S_BLART.
*--0018 2010.04.20

 ENDFORM.                    " s_blart_init
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
   DATA: S_OUT   TYPE /ZAK/ANALITIKA,
         V_KOKRS TYPE KOKRS.

   READ TABLE I_/ZAK/ANALITIKA INTO S_OUT INDEX E_ROW_ID.
   IF SY-SUBRC = 0.

     CASE E_COLUMN_ID.
       WHEN 'BSEG_GJAHR' OR
            'BSEG_BELNR' OR
            'BSEG_BUZEI'.

         IF NOT S_OUT-BSEG_GJAHR IS INITIAL AND
            NOT S_OUT-BSEG_BELNR IS INITIAL AND
            NOT S_OUT-BSEG_BUZEI IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'GJR' FIELD S_OUT-BSEG_GJAHR.
           SET PARAMETER ID 'BLN' FIELD S_OUT-BSEG_BELNR.

           CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
         ENDIF.
       WHEN 'KOSTL'.
         IF NOT S_OUT-KOSTL IS INITIAL.
           SELECT SINGLE KOKRS INTO V_KOKRS
              FROM TKA02
              WHERE BUKRS = S_OUT-BUKRS AND
                    GSBER = SPACE.

           SET PARAMETER ID 'CAC' FIELD V_KOKRS.
           SET PARAMETER ID 'KOS' FIELD S_OUT-KOSTL.

           CALL TRANSACTION 'KS03' AND SKIP FIRST SCREEN.
         ENDIF.
       WHEN 'AUFNR'.
         IF NOT S_OUT-AUFNR IS INITIAL.
           SELECT SINGLE KOKRS INTO V_KOKRS
              FROM TKA02
              WHERE BUKRS = S_OUT-BUKRS AND
                    GSBER = SPACE.

           SET PARAMETER ID 'CAC' FIELD V_KOKRS.
           SET PARAMETER ID 'ANR' FIELD S_OUT-AUFNR.

           CALL TRANSACTION 'KO03' AND SKIP FIRST SCREEN.
         ENDIF.
       WHEN 'HKONT'.
         IF NOT S_OUT-HKONT IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD S_OUT-BUKRS.
           SET PARAMETER ID 'SAK' FIELD S_OUT-HKONT.

           CALL TRANSACTION 'FS03' ."AND SKIP FIRST SCREEN.

         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " D900_EVENT_HOTSPOT_CLICK
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
*++0015 2009.05.22 BG
                         $I_KBELNR     STRUCTURE /ZAK/OUT_BELNR
*--0015 2009.05.22 BG
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
*++0012 2008.12.16 BG
** --Ez volt az eredeti
**  Az időszakból feltételt csinál a szelekcióhoz
**  Vagy nem 12 a periódus, vagy /ZAK/EVES <> ' '
**  Ha mindkét feltétel HAMIS, akkor nem kell figyelni a periódust
*   IF $MONAT <> '12' OR $/ZAK/EVES IS INITIAL.
*--0012 2008.12.16 BG
   R_MONAT = 'IEQ'.
   R_MONAT-LOW = $MONAT.
   APPEND R_MONAT.
*++0012 2008.12.16 BG
*   ELSE.
*     R_MONAT = 'IBT'.
*     R_MONAT-LOW  = '01'.
*     R_MONAT-HIGH = '12'.
*     APPEND R_MONAT.
*   ENDIF.
*--0012 2008.12.16 BG

   SELECT * INTO TABLE $I_BSIS
            FROM BSIS
            WHERE BUKRS = $BUKRS
              AND HKONT = $HKONT
              AND GJAHR = $GJAHR
              AND BLART IN S_BLART
              AND MONAT IN R_MONAT
              AND AUFNR IN LR_AUFNR.
   $SUBRC = SY-SUBRC.
*++0015 2009.05.22 BG
   IF NOT $I_KBELNR[] IS INITIAL.
     LOOP AT $I_BSIS.
       READ TABLE $I_KBELNR TRANSPORTING NO FIELDS
                WITH KEY BUKRS = $I_BSIS-BUKRS
                         GJAHR = $I_BSIS-GJAHR
                         BELNR = $I_BSIS-BELNR.
       IF SY-SUBRC EQ 0.
         DELETE $I_BSIS.
       ENDIF.
     ENDLOOP.
   ENDIF.
*--0015 2009.05.22 BG

*++0015 2009.08.07 BG
*  Ha nem marad rekord, akkor hiba
   IF $I_BSIS[] IS INITIAL.
     MOVE 4 TO $SUBRC.
   ENDIF.
*--0015 2009.08.07 BG
 ENDFORM.                    " get_bsis
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
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9001 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
   PERFORM SET_STATUS.
   IF V_CUSTOM_CONTAINER1 IS INITIAL.
     REFRESH I_FIELDCAT.
     PERFORM CREATE_AND_INIT_ALV1 CHANGING I_/ZAK/SZJA_EXCEL[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT.

   ENDIF.


 ENDMODULE.                 " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/SZJA_EXCEL[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV1 CHANGING $I_/ZAK/SZJA_EXCEL LIKE
                                                    I_/ZAK/SZJA_EXCEL[]
                                   $FIELDCAT TYPE LVC_T_FCAT
                                   $LAYOUT   TYPE LVC_S_LAYO
                                   $VARIANT  TYPE DISVARIANT.

   DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER
     EXPORTING
       CONTAINER_NAME = V_CONTAINER1.
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
       IT_OUTTAB            = $I_/ZAK/SZJA_EXCEL.

 ENDFORM.                    " CREATE_AND_INIT_ALV1
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9001 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
     WHEN 'ANALITIKA'.
       CALL SCREEN 9000.
* Kilépés
*++0005 BG 2007.05.08
*    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
     WHEN 'BACK'.
*--0005 BG 2007.05.08
       PERFORM EXIT_PROGRAM.
*++0005 BG 2007.05.08
     WHEN 'EXIT' OR 'CANCEL'.
       LEAVE PROGRAM.
*--0005 BG 2007.05.08
     WHEN OTHERS.
*     do nothing
   ENDCASE.


 ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  FILENAME_OBLIGATORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_OUTF  text
*----------------------------------------------------------------------*
 FORM FILENAME_OBLIGATORY USING  $FILE.
   IF P_TESZT IS INITIAL.
     IF $FILE IS INITIAL.
       MESSAGE E146 .
     ENDIF.
   ENDIF.
 ENDFORM.                    " FILENAME_OBLIGATORY
*&---------------------------------------------------------------------*
*&      Form  GET_VERIFY_BTYPE_FROM_DATUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALL  text
*      -->P_$W_/ZAK/SZJA_CUST_BTYPE  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*      -->P_$SUBRC  text
*----------------------------------------------------------------------*
 FORM GET_VERIFY_BTYPE_FROM_DATUM TABLES $I_/ZAK/BEVALL
                                             STRUCTURE /ZAK/BEVALL
                                  USING  $BTYPE
                                         $GJAHR
                                         $MONAT
                                         $SUBRC.

   DATA L_DATUM LIKE SY-DATUM.

*  Egyenlőre nem kell a rekord
   MOVE 4 TO $SUBRC.

*  Dátum meghatározás
   PERFORM GET_LAST_DAY_OF_PERIOD
                             USING $GJAHR
                                   $MONAT
                          CHANGING L_DATUM.

*  Meghatározzuk a BTYPE-ot.
   LOOP AT $I_/ZAK/BEVALL WHERE DATBI GE L_DATUM
                           AND DATAB LE L_DATUM.

   ENDLOOP.

   IF SY-SUBRC EQ 0 AND $I_/ZAK/BEVALL-BTYPE EQ $BTYPE.
     CLEAR $SUBRC.
   ENDIF.

 ENDFORM.                    " GET_VERIFY_BTYPE_FROM_DATUM
*&---------------------------------------------------------------------*
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
*++BG 2007.09.10
*         S_KBLART 'I' 'EQ' 'E*' SPACE,
*         S_KBLART 'I' 'EQ' 'F*' SPACE.
          S_KBLART 'I' 'CP' 'E*' SPACE,
          S_KBLART 'I' 'CP' 'F*' SPACE.
*--BG 2007.09.10

 ENDFORM.                    " S_KBLART_INIT
*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_V_SEL_BUKRS  text
*----------------------------------------------------------------------*
 FORM ROTATE_BUKRS_OUTPUT  TABLES   $I_AD_BUKRS STRUCTURE I_AD_BUKRS
                           USING    $BUKRS
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

*++0017 BG 2009.10.29
*  Meghatározzuk az összes lehetséges értéket ami az XREF1-ben lehet
   SELECT AD_BUKRS INTO TABLE $I_AD_BUKRS
                   FROM /ZAK/BUKRSN
                  WHERE FI_BUKRS EQ $BUKRS.
*--0017 BG 2009.10.29


 ENDFORM.                    " ROTATE_BUKRS_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  ROTATE_BUKRS_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BSEG  text
*      -->P_W_BKPF  text
*      <--P_L_BUKRS  text
*----------------------------------------------------------------------*
 FORM ROTATE_BUKRS_INPUT  TABLES   $I_AD_BUKRS STRUCTURE I_AD_BUKRS
                          USING    $BSEG STRUCTURE BSEG
                                   $BKPF STRUCTURE BKPF
                          CHANGING $BUKRS.

   DATA L_BUKRS TYPE BUKRS.

*++0017 BG 2009.10.29
*  MOVE $BSEG-XREF1+8(4) TO L_BUKRS.
   LOOP AT $I_AD_BUKRS.
     IF $BSEG-XREF1 CS $I_AD_BUKRS-AD_BUKRS.
       MOVE $I_AD_BUKRS-AD_BUKRS TO L_BUKRS.
     ENDIF.
   ENDLOOP.
*--0017 BG 2009.10.29

   CALL FUNCTION '/ZAK/ROTATE_BUKRS_INPUT'
     EXPORTING
       I_FI_BUKRS    = $BSEG-BUKRS
*++0007 2008.01.21 BG (FMC)
       I_AD_BUKRS    = L_BUKRS
*--0007 2008.01.21 BG (FMC)
       I_DATE        = $BKPF-BLDAT
*++0007 2008.01.21 BG (FMC)
*      I_GSBER       = $BSEG-GSBER
*      I_PRCTR       = $BSEG-PRCTR
*--0007 2008.01.21 BG (FMC)
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
*&      Form  SOR_SZETRAK_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SOR_SZETRAK_NEW.

   DATA L_GJAHR TYPE GJAHR.
   DATA L_MONAT TYPE MONAT.
   DATA L_BTYPE TYPE /ZAK/BTYPE.

   DATA: L_SZAMLA_BELNR(10).
   DATA L_SUBRC LIKE SY-SUBRC.


*++0011 2008.10.17 BG
   DATA L_LINES LIKE SY-TABIX.
*++1908 #10.
   DATA L_CUST_DATUM TYPE DATUM.
*--1908 #10.

   DEFINE LR_GET_SZAMLA_BELNR.
     IF NOT &1 IS INITIAL.
       IF &2 = &1.
         CLEAR &2.
       ENDIF.
     ENDIF.
   END-OF-DEFINITION.

   DESCRIBE TABLE I_BSEG LINES L_LINES.
*--0011 2008.10.17 BG

   LOOP AT I_BSEG INTO W_BSEG.
*++0011 2008.10.17 BG
*    Adatok feldolgozása
     PERFORM PROGRESS_INDICATOR USING TEXT-P03
                                      L_LINES
                                      SY-TABIX.
*--0011 2008.10.17 BG
*++1908 #10.
     CLEAR L_CUST_DATUM.
*--1908 #10.
*    Rákeres a fej adatra
     READ TABLE I_BKPF INTO W_BKPF
                        WITH KEY BUKRS = W_BSEG-BUKRS
                                 BELNR = W_BSEG-BELNR
                                 GJAHR = W_BSEG-GJAHR.
*    Bevallás fajta meghatározás
     IF W_BKPF-BLART IN S_KBLART.
*      Meghatározzuk az időszakhoz létezik e bevallás típust
       CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
         EXPORTING
           I_BUKRS     = P_BUKRS
           I_BTYPART   = C_BTYPART_SZJA
           I_GJAHR     = W_BKPF-BLDAT(4)
           I_MONAT     = W_BKPF-BLDAT+4(2)
         IMPORTING
           E_BTYPE     = L_BTYPE
         EXCEPTIONS
           ERROR_MONAT = 1
           ERROR_BTYPE = 2
           OTHERS      = 3.
       IF SY-SUBRC NE 0.
         CONTINUE.
*++1908 #10.
       ELSE.
         L_CUST_DATUM = W_BKPF-BLDAT.
*--1908 #10.
       ENDIF.
     ELSE.
*      Meghatározzuk az időszakhoz létezik e bevallás típust
       CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
         EXPORTING
           I_BUKRS     = P_BUKRS
           I_BTYPART   = C_BTYPART_SZJA
           I_GJAHR     = P_GJAHR
           I_MONAT     = P_MONAT
         IMPORTING
           E_BTYPE     = L_BTYPE
         EXCEPTIONS
           ERROR_MONAT = 1
           ERROR_BTYPE = 2
           OTHERS      = 3.
       IF SY-SUBRC NE 0.
         CONTINUE.
*++1908 #10.
       ELSE.
         CONCATENATE P_GJAHR P_MONAT '01' INTO L_CUST_DATUM.
*--1908 #10.
       ENDIF.
     ENDIF.
*++1908 #10.
**    Meghatározzuk az SZJA_CUST először rendelésre is.
*     READ TABLE I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
*                            WITH KEY BTYPE = L_BTYPE
*                                     SAKNR = W_BSEG-HKONT
*                                     AUFNR = W_BSEG-AUFNR.
**    Megpróbáljuk rendelés nélkül
*     IF SY-SUBRC NE 0.
*       READ TABLE I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
*                              WITH KEY BTYPE = L_BTYPE
*                                       SAKNR = W_BSEG-HKONT
*                                       AUFNR = ''.
*     ENDIF.
     CLEAR W_/ZAK/SZJA_CUST.
     LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                            WHERE BTYPE  =  L_BTYPE
                              AND SAKNR  =  W_BSEG-HKONT
                              AND AUFNR  =  W_BSEG-AUFNR
                              AND DATAB  LE L_CUST_DATUM
                              AND DATBI  GE L_CUST_DATUM.
       EXIT.
     ENDLOOP.
*    Megpróbáljuk rendelés nélkül
     IF SY-SUBRC NE 0.
       LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST
                              WHERE BTYPE  =  L_BTYPE
                                AND SAKNR  =  W_BSEG-HKONT
                                AND DATAB  LE L_CUST_DATUM
                                AND DATBI  GE L_CUST_DATUM.
         EXIT.
       ENDLOOP.
     ENDIF.
*--1908 #10.
     CHECK SY-SUBRC EQ 0.

     CLEAR W_/ZAK/BEVALL.
     READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL WITH KEY
                                  BUKRS = W_/ZAK/SZJA_CUST-BUKRS
                                  BTYPE = W_/ZAK/SZJA_CUST-BTYPE.
     IF SY-SUBRC NE 0.
       MESSAGE E114.
*      Bevallás típus meghatározás hiba!
     ENDIF.
*++2408 #01.
     CALL FUNCTION '/ZAK/SET_DATUM'
       EXPORTING
         I_DATUM  = W_BSEG-VALUT
         I_BIDOSZ = W_/ZAK/SZJA_CUST-BIDOSZ
       IMPORTING
         E_DATUM  = W_BSEG-VALUT.
*--2408 #01.
***********************************************************************
*    Minden adatok megvan jöhet a régi algoritmus:
*    FORM SOR_SZETRAK alapján
***********************************************************************

*      Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor
     IF NOT W_/ZAK/SZJA_CUST-ABEVAZ IS INITIAL.
       IF NOT W_/ZAK/SZJA_CUST-/ZAK/EVES IS INITIAL
          AND P_MONAT < 12.
**          Az ÉVES-re jelöltek csak akkor kellenek, ha a hónap 12 vagy
*           nagyobb
**          egyébként nem kell őket átadni az analitokának
*           könyvelni egyébként kell
*           CONTINUE.
       ELSE.
*++0002 BG 2006/10/26
*          KITÖLTI az analitika 1 sorát.
         PERFORM ANALITIKA_KITOLT USING W_/ZAK/ANALITIKA
                                        W_/ZAK/SZJA_CUST
                                        W_BSEG
                                        W_BKPF
                                        W_/ZAK/BEVALL
*++0006 BG 2007.10.15
                                        V_SEL_BUKRS
                                        P_BUKRS
*--0006 BG 2007.10.15
                                        L_SUBRC.
         CHECK L_SUBRC EQ 0.
*--0002 BG 2006/10/26
**          ++ BG
*           PERFORM GET_ANALITIKA_ITEM TABLES I_/ZAK/ANALITIKA
*                                      USING  W_/ZAK/ANALITIKA.
**          -- BG

*          Elmenti az analitoka rekordot.
         APPEND  W_/ZAK/ANALITIKA  TO I_/ZAK/ANALITIKA.
       ENDIF.
     ENDIF.
*      WL-es könyvelés
     IF NOT W_/ZAK/SZJA_CUST-/ZAK/WL IS INITIAL
        AND W_BKPF-BLART = 'WL'.
*          Ha az adott havi a bizonylat, csak akkor kell feladni
*          Itt jöhetnek olyan tételek is amik az éves leválogatás miatt
*          nem kellenek
*++0014 2009.04.20 BG
**++2009.01.12 BG
**      Meghatározzuk a beállítást a bevallás típushoz:
*       CLEAR W_/ZAK/SZJA_ABEV.
*       SELECT SINGLE * INTO W_/ZAK/SZJA_ABEV
*             FROM /ZAK/SZJA_ABEV
*             WHERE BUKRS     = P_BUKRS
*               AND BTYPE     = L_BTYPE
*               AND FIELDNAME = 'WL'.
**--2009.01.12 BG
       PERFORM GET_SZJA_ABEV USING W_/ZAK/SZJA_ABEV
                                   P_BUKRS
                                   L_BTYPE.
*--0014 2009.04.20 BG

       IF W_BKPF-MONAT = P_MONAT.
*++FI 20070213
*           PERFORM BOOK_WL USING W_BKPF
*                                 W_BSEG
*                                 W_/ZAK/SZJA_ABEV
*                                 W_/ZAK/BEVALL
*                                 W_/ZAK/SZJA_EXCEL.
**           kiírja a rekordot
*           APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
         PERFORM BOOK_WL_V2 USING W_BKPF
                                  W_BSEG
                                  W_/ZAK/SZJA_ABEV
                                  W_/ZAK/BEVALL
                                  W_/ZAK/SZJA_EXCEL1
                                  W_/ZAK/SZJA_EXCEL2
                                  P_GJAHR
                                  P_MONAT.
*Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az
*++0011 2008.10.17 BG
         LR_GET_SZAMLA_BELNR P_SPLIT L_SZAMLA_BELNR.
*--0011 2008.10.17 BG
         L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
         W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
         W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*           kiírja a rekordokat
         APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
         APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.

*--FI 20070213
       ENDIF.
     ENDIF.
*    Beállítás szerinti átkönyvelés
     IF NOT W_/ZAK/SZJA_CUST-/ZAK/ATKONYV IS INITIAL.
*++FI 20070213
*         PERFORM BOOK_ATKONYV USING W_BKPF
*                               W_BSEG
*                               W_/ZAK/SZJA_ABEV
*                               W_/ZAK/BEVALL
*                               W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
*                               W_/ZAK/SZJA_EXCEL1.
**        kiírja a rekordot
*         APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
**--2009.01.12 BG
       PERFORM GET_SZJA_ABEV USING W_/ZAK/SZJA_ABEV
                                   P_BUKRS
                                   L_BTYPE.
*--0014 2009.04.20 BG
       PERFORM BOOK_ATKONYV_V2 USING W_BKPF
                                     W_BSEG
                                     W_/ZAK/SZJA_ABEV
                                     W_/ZAK/BEVALL
                                     W_/ZAK/SZJA_CUST-/ZAK/ATKONYV
                                     W_/ZAK/SZJA_EXCEL1
                                     W_/ZAK/SZJA_EXCEL2.
*Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az
*++0011 2008.10.17 BG
       LR_GET_SZAMLA_BELNR P_SPLIT L_SZAMLA_BELNR.
*--0011 2008.10.17 BG
       L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
       W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
       W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
*        kiírja a rekordot
       APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
       APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
*--FI 20070213

     ENDIF.

   ENDLOOP.


 ENDFORM.                    " SOR_SZETRAK_NEW

*++0011 2008.10.17 BG
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
 FORM PROGRESS_INDICATOR USING  $TEXT
                                $LINES
                                $ACT_LINE.
   DATA L_PERCENTAGE TYPE I.
   DATA L_DIVIDE TYPE P DECIMALS 2.

   CLEAR L_PERCENTAGE.

   IF NOT $LINES IS INITIAL AND NOT $ACT_LINE IS INITIAL.
     L_DIVIDE = $ACT_LINE / $LINES * 100.
     L_PERCENTAGE = TRUNC( L_DIVIDE ).
   ENDIF.

   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
       PERCENTAGE = L_PERCENTAGE
       TEXT       = $TEXT.


 ENDFORM.                    " PROGRESS_INDICATOR
*--0011 2008.10.17 BG
*&---------------------------------------------------------------------*
*&      Form  ROTATION_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM ROTATION_DATA TABLES $I_/ZAK/SZJA_EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                    USING  $BUKRS.

*   DATA LI_CNV_AUFNR LIKE ZRP_CNV_AUFNR OCCURS 0 WITH HEADER LINE.
*   DATA LI_Z2CJOGUTOD LIKE Z2CJOGUTOD OCCURS 0 WITH HEADER LINE.
*   DATA LI_CNV_PC LIKE ZRP_PS001_CNV_PC OCCURS 0 WITH HEADER LINE.
*   DATA L_BUDAT LIKE SY-DATUM.
*   DATA L_KOKRS TYPE KOKRS.
*   RANGES LR_AUFNR FOR /ZAK/SZJAEXCELV2-RENDELES.
*   RANGES LR_KOSTL FOR /ZAK/SZJAEXCELV2-KTGH.
*   RANGES LR_PRCTR FOR /ZAK/SZJAEXCELV2-PRCTR.
*
*
*
**  Költségszámítási kör meghatározása
*   CALL FUNCTION 'BAPI_CONTROLLINGAREA_FIND'
*     EXPORTING
*       COMPANYCODEID           = $BUKRS
*     IMPORTING
*       CONTROLLINGAREAID       = L_KOKRS
**      RETURN                  =
*             .
*
*
*
**  Forgatások
*   LOOP AT $I_/ZAK/SZJA_EXCEL INTO W_/ZAK/SZJA_EXCEL1.
*
*     CALL FUNCTION 'CONVERSION_EXIT_PCDAT_OUTPUT'
*       EXPORTING
*         INPUT  = W_/ZAK/SZJA_EXCEL1-KONYV_DAT
*       IMPORTING
*         OUTPUT = L_BUDAT.
*
**    1. Rendelés
*     IF NOT W_/ZAK/SZJA_EXCEL1-RENDELES IS INITIAL AND
*        ( LR_AUFNR[] IS INITIAL OR
*          NOT W_/ZAK/SZJA_EXCEL1-RENDELES IN LR_AUFNR ).
*       READ TABLE LI_CNV_AUFNR WITH KEY
*                  AUFNR = W_/ZAK/SZJA_EXCEL1-RENDELES
*                  BINARY SEARCH.
*       IF SY-SUBRC EQ 0.
**        Van új rendelés
*         IF NOT LI_CNV_AUFNR-AUFNR_NEW IS INITIAL.
*           MOVE LI_CNV_AUFNR-AUFNR_NEW TO W_/ZAK/SZJA_EXCEL1-RENDELES.
**        Van új koltséghely
*         ELSEIF NOT LI_CNV_AUFNR-KOSTL_NEW IS INITIAL.
*           MOVE LI_CNV_AUFNR-KOSTL_NEW TO W_/ZAK/SZJA_EXCEL1-KTGH.
*         ENDIF.
*       ELSE.
**        Forgató tábla olvasás
*         SELECT SINGLE * INTO LI_CNV_AUFNR
*                         FROM ZRP_CNV_AUFNR
*                        WHERE DATBI GE L_BUDAT
*                          AND AUFNR EQ W_/ZAK/SZJA_EXCEL1-RENDELES
*                          AND DATAB LE L_BUDAT.
*         IF SY-SUBRC EQ 0.
**          Van új rendelés
*           IF NOT LI_CNV_AUFNR-AUFNR_NEW IS INITIAL.
*             MOVE LI_CNV_AUFNR-AUFNR_NEW TO W_/ZAK/SZJA_EXCEL1-RENDELES.
**          Van új koltséghely
*           ELSEIF NOT LI_CNV_AUFNR-KOSTL_NEW IS INITIAL.
*             MOVE LI_CNV_AUFNR-KOSTL_NEW TO W_/ZAK/SZJA_EXCEL1-KTGH.
*           ENDIF.
*           APPEND LI_CNV_AUFNR SORTED BY AUFNR.
**        Gyűjtjük, hogy már foglalkoztunk vele
*         ELSE.
*           M_DEF LR_AUFNR 'I' 'EQ' W_/ZAK/SZJA_EXCEL1-RENDELES SPACE.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*
**  2. Költséghely
*     IF NOT W_/ZAK/SZJA_EXCEL1-KTGH IS INITIAL AND
*       ( LR_KOSTL[] IS INITIAL OR
*         NOT W_/ZAK/SZJA_EXCEL1-KTGH IN LR_KOSTL ).
**++2009.01.12 BG
**      Vezető 0-ák feltöltése
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-KTGH
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-KTGH.
**--2009.01.12 BG
*       READ TABLE LI_Z2CJOGUTOD WITH KEY
*                   KOKRS  = L_KOKRS
*                   MKOSTL = W_/ZAK/SZJA_EXCEL1-KTGH
*                   BINARY SEARCH.
**       Van új koltséghely
*       IF SY-SUBRC EQ 0.
*         MOVE LI_Z2CJOGUTOD-JKOSTL TO W_/ZAK/SZJA_EXCEL1-KTGH.
*       ELSE.
*         SELECT SINGLE * INTO LI_Z2CJOGUTOD
*                         FROM Z2CJOGUTOD
*                        WHERE KOKRS  EQ L_KOKRS
*                          AND MKOSTL EQ W_/ZAK/SZJA_EXCEL1-KTGH.
*         IF SY-SUBRC EQ 0.
*           MOVE LI_Z2CJOGUTOD-JKOSTL TO W_/ZAK/SZJA_EXCEL1-KTGH.
*           APPEND LI_Z2CJOGUTOD SORTED BY MKOSTL.
*         ELSE.
*           M_DEF LR_KOSTL 'I' 'EQ' W_/ZAK/SZJA_EXCEL1-KTGH SPACE.
*         ENDIF.
*       ENDIF.
**++2009.01.12 BG
**      Vezető 0-ák eltávolítása
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-KTGH
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-KTGH.
**--2009.01.12 BG
*     ENDIF.
*
**  3. profitcenter
*     IF W_/ZAK/SZJA_EXCEL1-RENDELES IS INITIAL AND
*        W_/ZAK/SZJA_EXCEL1-KTGH IS INITIAL AND
*        NOT W_/ZAK/SZJA_EXCEL1-PRCTR IS INITIAL AND
*        ( LR_PRCTR[] IS INITIAL OR
*        NOT W_/ZAK/SZJA_EXCEL1-PRCTR IN LR_PRCTR ).
*
**++2009.01.12 BG
**      Vezető 0-ák feltöltése
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-PRCTR
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-PRCTR.
**--2009.01.12 BG
*
*       READ TABLE LI_CNV_PC WITH KEY
*                  PRCTR = W_/ZAK/SZJA_EXCEL1-PRCTR.
**       Van új PC
*       IF SY-SUBRC EQ 0.
*         MOVE LI_CNV_PC-PRCTR_NEW TO W_/ZAK/SZJA_EXCEL1-PRCTR.
*       ELSE.
*         SELECT SINGLE * INTO LI_CNV_PC
*                         FROM ZRP_PS001_CNV_PC
*                        WHERE DATBI GE L_BUDAT
*                          AND KOKRS EQ L_KOKRS
*                          AND PRCTR EQ W_/ZAK/SZJA_EXCEL1-PRCTR.
*         IF SY-SUBRC EQ 0.
*           MOVE LI_CNV_PC-PRCTR_NEW TO W_/ZAK/SZJA_EXCEL1-PRCTR.
*           APPEND LI_CNV_PC SORTED BY PRCTR.
*         ELSE.
*           M_DEF LR_PRCTR 'I' 'EQ' W_/ZAK/SZJA_EXCEL1-PRCTR SPACE.
*         ENDIF.
*       ENDIF.
**++2009.01.12 BG
**      Vezető 0-ák eltávolítása
*       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*         EXPORTING
*           INPUT  = W_/ZAK/SZJA_EXCEL1-PRCTR
*         IMPORTING
*           OUTPUT = W_/ZAK/SZJA_EXCEL1-PRCTR.
**--2009.01.12 BG
*
*     ENDIF.
*
*     MODIFY $I_/ZAK/SZJA_EXCEL FROM W_/ZAK/SZJA_EXCEL1
*            TRANSPORTING RENDELES KTGH PRCTR.
*
*
*   ENDLOOP.
*
*   FREE: LI_CNV_AUFNR, LI_Z2CJOGUTOD, LI_CNV_PC.

 ENDFORM.                    " ROTATION_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SZJA_ABEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_P_BUKRS  text
*      -->P_L_BTYPE  text
*----------------------------------------------------------------------*
 FORM GET_SZJA_ABEV  USING    $W_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                              $BUKRS
                              $BTYPE.
   CLEAR $W_/ZAK/SZJA_ABEV.
   CLEAR W_/ZAK/SZJA_ABEV.
   SELECT SINGLE * INTO $W_/ZAK/SZJA_ABEV
         FROM /ZAK/SZJA_ABEV
         WHERE BUKRS     = $BUKRS
           AND BTYPE     = $BTYPE
           AND FIELDNAME = 'WL'.
*  Ha nics beállítva ÁFA kód, akkor hiba:
   IF $W_/ZAK/SZJA_ABEV-MWSKZ IS INITIAL.
     MESSAGE E284 WITH $BUKRS $BTYPE.
*Nincs beállítva ÁFA kód WL mezőhöz /ZAK/SZJA_ABEV-ben
* (Váll.: &, típ.: &)
   ENDIF.

 ENDFORM.                    " GET_SZJA_ABEV
