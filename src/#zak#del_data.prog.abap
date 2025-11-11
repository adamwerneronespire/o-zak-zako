*&---------------------------------------------------------------------*
*& Report  /ZAK/DEL_DATA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/DEL_DATA MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekcióban megadott adatokat kitörli
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2007.09.25
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES /ZAK/BEVALLI.

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
DATA V_PACK TYPE /ZAK/PACK.

RANGES R_PACK FOR /ZAK/BEVALLSZ-PACK.

*Adatok törlése
DEFINE M_DELETE.
  PERFORM PROCESS_IND USING &2.
  DELETE FROM &1 WHERE BUKRS EQ P_BUKRS
                   AND BTYPE EQ P_BTYPE
                   AND GJAHR EQ P_GJAHR
                   AND MONAT EQ P_MONAT
                   AND ZINDEX IN S_INDEX.
  COMMIT WORK AND WAIT.
END-OF-DEFINITION.

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
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*Figyelmeztetés
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(71) TEXT-101.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(71) TEXT-102.
SELECTION-SCREEN END OF LINE.

PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLI-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.

PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLI-BTYPE
                          OBLIGATORY.

PARAMETERS: P_GJAHR  LIKE /ZAK/BEVALLI-GJAHR OBLIGATORY.

PARAMETERS: P_MONAT  LIKE /ZAK/BEVALLI-MONAT OBLIGATORY.

SELECT-OPTIONS S_INDEX FOR /ZAK/BEVALLI-ZINDEX.

SELECTION-SCREEN: END OF BLOCK BL01.

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
AT SELECTION-SCREEN.

  IF SY-SYSID EQ 'MTP'.
    MESSAGE I235.
*   Figyelem! Ön az éles rendszerben akar adatokat törlni!
  ENDIF.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* /ZAK/ANALITIKA
  M_DELETE /ZAK/ANALITIKA '/ZAK/ANALITIKA törlése'.
* /ZAK/BEVALLO
  M_DELETE /ZAK/BEVALLO   '/ZAK/BEVALLO törlése'.
* Package azonosítók gyűjtése
  SELECT PACK INTO V_PACK
              FROM /ZAK/BEVALLSZ
                 WHERE BUKRS EQ P_BUKRS
                   AND BTYPE EQ P_BTYPE
                   AND GJAHR EQ P_GJAHR
                   AND MONAT EQ P_MONAT
                   AND ZINDEX IN S_INDEX
                   AND PACK  NE SPACE.
    M_DEF R_PACK 'I' 'EQ' V_PACK SPACE.
  ENDSELECT.
* /ZAK/BEVALLSZ
  M_DELETE /ZAK/BEVALLSZ  '/ZAK/BEVALLSZ törlése'.
* /ZAK/BEVALLI
  M_DELETE /ZAK/BEVALLI   '/ZAK/BEVALLI törlése'.
* /ZAK/BEVALLP aktualizálás
  PERFORM PROCESS_IND USING '/ZAK/BEVALLP módosítás'.

  IF NOT R_PACK[] IS INITIAL.
    UPDATE /ZAK/BEVALLP
           SET XLOEK = 'X'
               DATUM = SY-DATUM
               UZEIT = SY-UZEIT
               UNAME = SY-UNAME
         WHERE BUKRS = P_BUKRS
           AND PACK  IN R_PACK.
  ENDIF.

  MESSAGE I008.
* Tábla törlések elvégezve!


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  process_ind
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_IND USING $TEXT.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*      PERCENTAGE       = 0
      TEXT             = $TEXT.

ENDFORM.                    " process_ind
