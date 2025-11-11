*&---------------------------------------------------------------------*
*& Program: Könyvelések feladása lezárt időszakról
*&---------------------------------------------------------------------*
 REPORT /ZAK/BOOK_FILE_GEN MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& a lezárt időszakból készítí el az átvzeteés valamint az önellenőrzési
*& pótlék könyvelési feladás excel fájlt.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2006.03.30
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




*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK BL1 WITH FRAME TITLE TEXT-T01.
* Vállalat.
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-101.
 PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLI-BUKRS VALUE CHECK
                           OBLIGATORY MEMORY ID BUK.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

 SELECTION-SCREEN END OF LINE.

* Bevallás fajta meghatározása
 PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART
                           OBLIGATORY.
* Bevallás típus
 PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLI-BTYPE
*                          OBLIGATORY
                           NO-DISPLAY.
* Év
 PARAMETERS: P_GJAHR  LIKE /ZAK/BEVALLI-GJAHR DEFAULT SY-DATUM(4).

* Hónap
 PARAMETERS: P_MONAT  LIKE /ZAK/BEVALLI-MONAT DEFAULT SY-DATUM+4(2).

* Index
 PARAMETERS: P_INDEX LIKE /ZAK/BEVALLI-ZINDEX.

 SELECTION-SCREEN: END OF BLOCK BL1.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.

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
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
*  Megnevezések meghatározása
   PERFORM READ_ADDITIONALS.
*  Bevallás típus meghatározása
   PERFORM GET_BTYPE.
*  Ellenőrizzük a megadott időszak lezárt-e.
   PERFORM GET_STATUS_CLOSE.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*  Jogosultság vizsgálat
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTYPAR
                                 C_ACTVT_01.

*  Átvezetés vagy egyéb
   IF P_BTYPAR = C_BTYPART_ATV.
     CALL FUNCTION '/ZAK/ATV_BOOK_EXCEL'
          EXPORTING
               I_BUKRS         = P_BUKRS
               I_BTYPE         = P_BTYPE
               I_GJAHR         = P_GJAHR
               I_MONAT         = P_MONAT
               I_INDEX         = P_INDEX
*         TABLES
*              T_BEVALLO       = I_/ZAK/BEVALLO
          EXCEPTIONS
               DATA_MISMATCH   = 1
               DOWNLOAD_FAILED = 2
               OTHERS          = 3.

     IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ELSE.
       MESSAGE I009 WITH SPACE.
*   & fájl sikeresen letöltve
     ENDIF.
   ELSE.
     CALL FUNCTION '/ZAK/ONELL_BOOK_EXCEL'
      EXPORTING
        I_BUKRS                   = P_BUKRS
        I_BTYPE                   = P_BTYPE
        I_GJAHR                   = P_GJAHR
        I_MONAT                   = P_MONAT
        I_INDEX                   = P_INDEX
*     TABLES
*       T_BEVALLO                 = I_/ZAK/BEVALLO
      EXCEPTIONS
        DATA_MISMATCH             = 1
        ERROR_ONELL_BOOK          = 2
        ERROR_DOWNLOAD_FILE       = 3
        EMPTY_FILE                = 4
*++BG 2008.04.16
        ERROR_CHANGE_BUKRS        = 5
*--BG 2008.04.16

        OTHERS                    = 6
               .
     IF SY-SUBRC <> 0.
       CASE SY-SUBRC.
         WHEN 2.
           MESSAGE I154.
*      Önellenőrzési pótlék könyvelés beállítás hiba! Fájl nem készült!
         WHEN 3.
           MESSAGE I155.
*      Önellenőrzési pótlék könyvelési fájl létrehozás hiba!
         WHEN 4.
           MESSAGE I157.
*      Nincs meghatározható adat! Fájl nem készült!
*++BG 2008.04.16
         WHEN 5.
           MESSAGE I231 WITH P_BUKRS.
*   Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPU
*--BG 2008.04.16

       ENDCASE .
     ELSE.
       MESSAGE I009 WITH SPACE.
*   & fájl sikeresen letöltve
     ENDIF.
*++BG 2008.01.07 ÁFA arányosítás könyvelés feladás
     IF P_BTYPAR = C_BTYPART_AFA.
       CALL FUNCTION '/ZAK/AFAR_BOOK_EXCEL'
         EXPORTING
           I_BUKRS             = P_BUKRS
           I_BTYPE             = P_BTYPE
           I_GJAHR             = P_GJAHR
           I_MONAT             = P_MONAT
           I_INDEX             = P_INDEX
         EXCEPTIONS
           MISSING_INPUT       = 1
           ERROR_AFAR_BOOK     = 2
           ERROR_DOWNLOAD_FILE = 3
           EMPTY_FILE          = 4
           ERROR_DATUM         = 5
           OTHERS              = 6.
       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
         MESSAGE I009 WITH SPACE.
*        & fájl sikeresen letöltve
       ENDIF.
     ENDIF.
*--BG 2008.01.07 ÁFA arányosítás könyvelés
   ENDIF.

 END-OF-SELECTION.

*&---------------------------------------------------------------------*
*                            PERFORMOK
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
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
     ENDIF.
     MODIFY SCREEN.
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
 FORM READ_ADDITIONALS.

* Vállalat megnevezése
   IF NOT P_BUKRS IS INITIAL.
     SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
        WHERE BUKRS = P_BUKRS.
   ENDIF.

 ENDFORM.                    " READ_ADDITIONALS
*&---------------------------------------------------------------------*
*&      Form  GET_STATUSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
 FORM GET_STATUSZ USING    $BUKRS
                           $BTYPE
                           $GJAHR
                           $MONAT.

   CLEAR W_/ZAK/BEVALLI.
   SELECT SINGLE * INTO W_/ZAK/BEVALLI
                   FROM /ZAK/BEVALLI
                  WHERE BUKRS EQ P_BUKRS
                    AND BTYPE EQ P_BTYPE
                    AND GJAHR EQ P_GJAHR
                    AND MONAT EQ P_MONAT
                    AND ZINDEX EQ P_INDEX.


 ENDFORM.                    " GET_STATUSZ
*&---------------------------------------------------------------------*
*&      Form  get_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_BTYPE.

*  Ha a BYTPE üres, akkor meghatározzuk
*   IF P_BTYPE IS INITIAL AND
*      NOT P_BUKRS IS INITIAL AND
*      NOT P_BTYPAR IS INITIAL AND
*      NOT P_GJAHR IS INITIAL AND
*      NOT P_MONAT IS INITIAL.
   CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
     EXPORTING
       I_BUKRS     = P_BUKRS
       I_BTYPART   = P_BTYPAR
       I_GJAHR     = P_GJAHR
       I_MONAT     = P_MONAT
     IMPORTING
       E_BTYPE     = P_BTYPE
     EXCEPTIONS
       ERROR_MONAT = 1
       ERROR_BTYPE = 2
       OTHERS      = 3.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
*   ENDIF.


 ENDFORM.                    " get_btype
*&---------------------------------------------------------------------*
*&      Form  GET_STATUS_CLOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_STATUS_CLOSE.

*  Meghatározzuk a státuszt
   PERFORM GET_STATUSZ USING P_BUKRS
                             P_BTYPE
                             P_GJAHR
                             P_MONAT.

*  Ha a státusz nem lezárt:
   IF W_/ZAK/BEVALLI-FLAG NA 'ZX'.
     MESSAGE E156.
*   Kérem csak lezárt időszakot adjon meg!
   ENDIF.

 ENDFORM.                    " GET_STATUS_CLOSE
