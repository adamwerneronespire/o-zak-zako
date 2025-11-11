*&---------------------------------------------------------------------*
*& Report  /ZAK/SET_STATUS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /ZAK/SET_STATUS MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekcióban megadott adatoknak beállítja
*  a státuszát 'Z'-re
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2008.07.03
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 50
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*
*TABLES: /ZAK/ANALITIKA.

INCLUDE /ZAK/COMMON_STRUCT.

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
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*Figyelmeztetés
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-101.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-102.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-103.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-B02.

PARAMETERS P_BUKRS LIKE /ZAK/BEVALLI-BUKRS OBLIGATORY MEMORY ID BUK.
PARAMETERS P_BTYPE LIKE /ZAK/BEVALLI-BTYPE OBLIGATORY.
PARAMETERS P_GJAHR LIKE /ZAK/BEVALLI-GJAHR OBLIGATORY.
PARAMETERS P_MONAT LIKE /ZAK/BEVALLI-MONAT OBLIGATORY.
PARAMETERS P_INDEX LIKE /ZAK/BEVALLI-ZINDEX OBLIGATORY.


PARAMETERS P_FLAG  LIKE /ZAK/BEVALLI-FLAG DEFAULT 'Z'
                                         MODIF ID DIS.

SELECTION-SCREEN: END OF BLOCK BL02.
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
AT SELECTION-SCREEN OUTPUT.

*  Képernyő attribútomok beállítása
  PERFORM SET_SCREEN_ATTRIBUTES.




START-OF-SELECTION.

  GET TIME.

  UPDATE /ZAK/BEVALLI SET FLAG  = P_FLAG
                         DATUM = SY-DATUM
                         UZEIT = SY-UZEIT
                         UNAME = SY-UNAME
               WHERE BUKRS  = P_BUKRS
                AND  BTYPE  = P_BTYPE
                AND  GJAHR  = P_GJAHR
                AND  MONAT  = P_MONAT
                AND  ZINDEX = P_INDEX.
  IF SY-SUBRC NE 0.
    MESSAGE I031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
    EXIT.
  ENDIF.

  UPDATE /ZAK/BEVALLSZ SET FLAG = P_FLAG
                         DATUM = SY-DATUM
                         UZEIT = SY-UZEIT
                         UNAME = SY-UNAME
                 WHERE BUKRS  = P_BUKRS
                AND  BTYPE  = P_BTYPE
                AND  GJAHR  = P_GJAHR
                AND  MONAT  = P_MONAT
                AND  ZINDEX = P_INDEX.

  COMMIT WORK AND WAIT.

  MESSAGE I216.
*   Adatmódosítások elmentve!


END-OF-SELECTION.


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
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
