*&---------------------------------------------------------------------*
*& Funkció leírás: Magánszemély címadatok feltöltése CSV formátumból   *
*& /ZAK/MGCIM táblába a /ZAK/ZAKO rendszer adóigazolás funkciójához          *
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2008.02.28
*& Funkc.spec.készítő: Róth Nándor  - FMC
*& SAP modul neve    : /ZAK/ZAKO
*& Program  típus    : Riport
*& SAP verzió        : 5.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/MGCIM_UPLOAD MESSAGE-ID /ZAK/ZAK.


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
*      Globális változók   -   (G_xxx...)                              *
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
*Adatdeklaráció

*Fájl adatok
TYPES: BEGIN OF T_FILE_DATA,
         ADOAZON TYPE /ZAK/ADOAZON,
         NAME    TYPE /ZAK/NAME,
         POSTCOD TYPE AD_PSTCD1,
         CITY1   TYPE AD_CITY1,
         STREET  TYPE AD_STREET,
*++2108 #15.
         PUBCHAR TYPE /ZAK/PUBCHAR,
*--2108 #15.
         HOUSE   TYPE AD_HSNM1,
         COUNTRY TYPE LAND1,
       END   OF T_FILE_DATA.

DATA I_FILE TYPE STANDARD TABLE OF T_FILE_DATA INITIAL SIZE 0.
DATA W_FILE TYPE T_FILE_DATA.
DATA I_/ZAK/MGCIM TYPE STANDARD TABLE OF /ZAK/MGCIM INITIAL SIZE 0.
DATA W_/ZAK/MGCIM TYPE /ZAK/MGCIM.

DATA G_SUBRC LIKE SY-SUBRC.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
*Általános szelekciók:
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*Fájl elérés
PARAMETERS P_PATH TYPE LOCALFILE OBLIGATORY.
*Fejsor az állományban
PARAMETERS P_HEAD AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2265 #02.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/MGCIM_UPLOAD'.
*--2265 #02.
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
AT SELECTION-SCREEN.
  IF NOT SY-BATCH IS INITIAL.
    MESSAGE E259.
*   A program háttérben nem futtatható!
  ENDIF.

*&--------------------------------------------------------------------*
*& AT SELECTION-SCREEN OUTPUT
*&--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
* Fájl nyitás keresési segítség
  PERFORM GET_FILENAME CHANGING P_PATH.

*&--------------------------------------------------------------------*
*& START-OF-SELECTION
*&--------------------------------------------------------------------*
START-OF-SELECTION.

  IF NOT SY-BATCH IS INITIAL.
    MESSAGE E259.
*   A program háttérben nem futtatható!
  ENDIF.

* Adatfájl beolvasása
  PERFORM OPEN_DATA_FILE TABLES I_FILE
                         USING  ''     "BATCH mode
                                P_PATH
                                P_HEAD
                                G_SUBRC.
  IF NOT G_SUBRC IS INITIAL.
    MESSAGE E082 WITH P_PATH.
*   Hiba a & fájl megnyitásánál!
  ENDIF.

* Adatok feltöltése
  PERFORM UPLOAD_DATA.

END-OF-SELECTION.
*&--------------------------------------------------------------------*
*& END-OF-SELECTION
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA .

  LOOP AT I_FILE INTO W_FILE.
    MOVE-CORRESPONDING W_FILE TO W_/ZAK/MGCIM.
    MOVE SY-DATUM TO W_/ZAK/MGCIM-DATUM.
    MOVE SY-UZEIT TO W_/ZAK/MGCIM-UZEIT.
    MOVE SY-UNAME TO W_/ZAK/MGCIM-UNAME.
    APPEND W_/ZAK/MGCIM TO I_/ZAK/MGCIM.
  ENDLOOP.

*Adatbázis módosítás
  MODIFY /ZAK/MGCIM FROM TABLE I_/ZAK/MGCIM.
  COMMIT WORK AND WAIT.
  MESSAGE I261.
* Adatok feltöltve!


ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  get_filename
*&---------------------------------------------------------------------*
*       PC file keresés - F4 nyomógombra szelekciós paraméterhez
*----------------------------------------------------------------------*
*      -->$FNAME     text
*----------------------------------------------------------------------*
FORM GET_FILENAME CHANGING $FNAME.

  DATA: LV_DYNPFIELD LIKE DYNPREAD-FIELDNAME,
        LV_FNAME     LIKE IBIPPARMS-PATH.

  LV_FNAME = $FNAME.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      FILE_NAME = LV_FNAME.

  $FNAME = LV_FNAME.

ENDFORM.                    " get_filename

*&---------------------------------------------------------------------*
*&      Form  OPEN_DATA_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_FILE  text
*      -->P_P_PATH  text
*      -->P_P_HEAD  text
*----------------------------------------------------------------------*
FORM OPEN_DATA_FILE  TABLES   $I_FILE LIKE I_FILE
                     USING    $BATCH
                              $PATH
                              $HEAD
                              $SUBRC.

  DATA L_FNAME TYPE STRING.

  DATA: BEGIN OF LI_XLS OCCURS 0,
          LINE TYPE STRING,
        END OF LI_XLS.

  CHECK $BATCH IS INITIAL.

  CLEAR $SUBRC.

  MOVE $PATH TO L_FNAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                = L_FNAME
      FILETYPE                = 'ASC'
*     DAT_MODE                = 'X'
*     HAS_FIELD_SEPARATOR     = 'X'
    TABLES
      DATA_TAB                = LI_XLS
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      OTHERS                  = 17.

  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MOVE SY-SUBRC TO $SUBRC.
  ENDIF.

  IF NOT $HEAD IS INITIAL.
    DELETE LI_XLS INDEX 1.
  ENDIF.

* CSV bontás
  LOOP AT LI_XLS.
    PERFORM SPLIT_DATA USING LI_XLS-LINE
                    CHANGING W_FILE.
    APPEND W_FILE TO $I_FILE.
  ENDLOOP.

  IF $I_FILE[] IS INITIAL.
    MOVE 4 TO $SUBRC.
* A & állomány nem tartalmaz feldolgozható rekordot!
    MESSAGE E260 WITH $PATH.

  ENDIF.


ENDFORM.                    " OPEN_DATA_FILE

*&---------------------------------------------------------------------*
*&      Form  SPLIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_XLS_LINE  text
*      <--P_LW_FILE  text
*----------------------------------------------------------------------*
FORM SPLIT_DATA  USING  $DATA TYPE STRING
              CHANGING  $FILE LIKE W_FILE.

  FIELD-SYMBOLS <F>. " type string.
  DATA LW_DATA TYPE STRING.
  DATA L_TEXT  TYPE STRING.

* Init
  CLEAR: $FILE.
  LW_DATA = $DATA.

* Split
  DO.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE $FILE TO <F>.
    IF SY-SUBRC NE 0. EXIT. ENDIF.
    SPLIT LW_DATA AT ';' INTO L_TEXT LW_DATA.
    CONDENSE L_TEXT.
    <F> = L_TEXT.
  ENDDO.

ENDFORM.                    " SPLIT_DATA
