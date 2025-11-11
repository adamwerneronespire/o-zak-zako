*&---------------------------------------------------------------------*
*& Report  /ZAK/ADONSZA_ESDAT_CONV
*&
*&---------------------------------------------------------------------*
*& Funkció leírás: Eredeti esedékességi dátum feltöltése (ZESDAT).
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2009.09.15
*& Funkc.spec.készítő:
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 50
*&---------------------------------------------------------------------*

REPORT  /ZAK/ADONSZA_ESDAT_CONV MESSAGE-ID /ZAK/ZAK.

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

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-101.

SELECTION-SCREEN END OF LINE.
*Vállalat
SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS.
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

  SELECT * INTO TABLE I_/ZAK/ADONSZA
           FROM /ZAK/ADONSZA
          WHERE BUKRS IN S_BUKRS.

  LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA
                        WHERE ZESDAT IS INITIAL.
    MOVE W_/ZAK/ADONSZA-ESDAT TO W_/ZAK/ADONSZA-ZESDAT.
    MODIFY I_/ZAK/ADONSZA FROM W_/ZAK/ADONSZA TRANSPORTING ZESDAT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    MODIFY /ZAK/ADONSZA FROM TABLE I_/ZAK/ADONSZA.
    COMMIT WORK AND WAIT.
    MESSAGE I000 WITH 'Adatfeltöltés befejezve!'.
  ELSE.
    MESSAGE I000 WITH 'Nincs feltölthető rekord!'.
  ENDIF.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------
