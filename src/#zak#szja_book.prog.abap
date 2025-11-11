*&---------------------------------------------------------------------*
*& Program: Analitika sorok könyvelése
*&---------------------------------------------------------------------*
 REPORT /ZAK/SZJA_BOOK_SEL MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& leválogatja a /ZAK/ANALITIKA adatokat, és az előre megadott formátumba
*& Excel fájlban tárolja a könyveléshez.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2006.03.22
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
*& 0002   2006/10/26   Balázs G.     Több bevallás típus kezelése
*& 0003   2007/03/06   Forgó I.      Főkönyv "előjel helyes" könyvelés
*& 0004   2008/10/31   Balázs G.     Könyvelés fájl tagolás
*& 0005   2009/01/12   Balázs G.     Forgatás beépítés
*& 0006   2008/08/25   Balázs G.     PST elem kontírozás
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE /ZAK/SAP_SEL_F01.



*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
 TABLES : BSEG,              "Bizonylatszegmens: könyvelés
          BKPF,              "Bizonylatfej könyveléshez
          /ZAK/SZJA_CUST,     "SZJA lev., könyvelés feladás beállítása
          /ZAK/SZJA_ABEV.     "SZJA lev., ABEV megh.mezőnév alapján


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
* DATA W_/ZAK/SZJA_EXCEL TYPE  /ZAK/SZJA_EXCEL.
* DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJA_EXCEL
*                                                        INITIAL SIZE 0.
 DATA W_/ZAK/SZJA_EXCEL1 TYPE  /ZAK/SZJAEXCELV2.
 DATA W_/ZAK/SZJA_EXCEL2 TYPE  /ZAK/SZJAEXCELV2.
 DATA I_/ZAK/SZJA_EXCEL TYPE STANDARD TABLE OF /ZAK/SZJAEXCELV2
                                                        INITIAL SIZE 0.


*BSEG
 DATA W_BSEG TYPE  BSEG.
 DATA I_BSEG TYPE STANDARD TABLE OF BSEG INITIAL SIZE 0.
*BKPF
 DATA W_BKPF TYPE  BKPF.
 DATA I_BKPF TYPE STANDARD TABLE OF BKPF INITIAL SIZE 0.
* Hibaüzenetek táblája
* DATA I_RETURN TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0.
* DATA W_RETURN TYPE BAPIRET2.


* ALV kezelési változók
 DATA: V_OK_CODE LIKE SY-UCOMM,
       V_SAVE_OK LIKE SY-UCOMM,
       V_CONTAINER   TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',
       V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       I_FIELDCAT   TYPE  LVC_T_FCAT ,
       V_LAYOUT     TYPE LVC_S_LAYO,
       V_VARIANT    TYPE DISVARIANT,
       V_GRID   TYPE REF TO CL_GUI_ALV_GRID.
*      V_EVENT_RECEIVER  TYPE REF TO lCL_EVENT_RECEIVER.
 DATA: BEGIN OF I_OUTTAB2 OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
 DATA: CELLTAB TYPE LVC_T_STYL.
 DATA: END OF I_OUTTAB2.


*++0002 BG 2006/10/26
 RANGES R_BTYPE FOR /ZAK/BEVALL-BTYPE.
*--0002 BG 2006/10/26

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
 SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

* Vállalat.
 SELECTION-SCREEN BEGIN OF LINE.
 SELECTION-SCREEN COMMENT 01(31) TEXT-101.
 PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLSZ-BUKRS VALUE CHECK
                           OBLIGATORY MEMORY ID BUK.
 SELECTION-SCREEN POSITION 50.
 PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.

 SELECTION-SCREEN END OF LINE.
* ++BG
* Bevallás típus.
* SELECTION-SCREEN BEGIN OF LINE.
* SELECTION-SCREEN COMMENT 01(31) TEXT-102.
*++0002 BG 2006/10/26
* PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLSZ-BTYPE
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
* Könyvelési dátum
 PARAMETERS: P_BUDAT LIKE BKPF-BUDAT DEFAULT SY-DATUM
                                     OBLIGATORY.

* Teszt futás
 PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X' .

 SELECTION-SCREEN: END OF BLOCK BL01.



*Könyvelési excel fájl
 SELECTION-SCREEN BEGIN OF BLOCK B104 WITH FRAME TITLE TEXT-T02.
 PARAMETERS: P_OUTF LIKE FC03TAB-PL00_FILE ."OBLIGATORY.
*++0004 2008.10.31 BG
 PARAMETERS: P_SPLIT TYPE I.
*--0004 2008.10.31 BG
 SELECTION-SCREEN END OF BLOCK B104.





*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.
   GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Megnevezések meghatározása
   PERFORM READ_ADDITIONALS.
*  Könyvelési dátum
   PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                        P_MONAT
                               CHANGING P_BUDAT .
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
*++0002 BG 2006/10/26
 AT SELECTION-SCREEN ON P_BTYPAR.
*  SZJA bevallás típus ellenőrzése
   PERFORM VER_BTYPEART USING P_BUKRS
                              P_BTYPAR
                              C_BTYPART_SZJA
                     CHANGING V_SUBRC.
*--0002 BG 2006/10/26

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
*--0002 BG 2006/10/26
   ENDIF.


 AT SELECTION-SCREEN ON P_MONAT.
*  Periódus ellenőrzése
   PERFORM VER_PERIOD   USING P_MONAT.


 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_OUTF.
   PERFORM FILENAME_GET USING P_OUTF.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_BUDAT.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN.
*  Megnevezések meghatározása
   PERFORM READ_ADDITIONALS.
*  Fájl ellenőrzés
   PERFORM VER_FILENAME USING P_OUTF.



*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*  Jogosultság vizsgálat
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 P_BTYPAR
                                 C_ACTVT_01.

*++0002 BG 2006/10/26
**  Ha a BYTPE üres, akkor meghatározzuk
*   IF P_BTYPE IS INITIAL.
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
*   ENDIF.
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
*--0002 BG 2006/10/26


*  Vállalati adatok beolvasása
   PERFORM GET_T001 USING P_BUKRS
                          V_SUBRC.
   IF NOT V_SUBRC IS INITIAL.
     MESSAGE A036 WITH P_BUKRS.
*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla)
   ENDIF.

*  Az adatok leválogatása
   PERFORM VALOGAT USING V_SUBRC.
   IF V_SUBRC <> 0.
*    nincs a szelekciónak megfelelő adat.
     MESSAGE I031.
*++2007.01.11 BG (FMC)
     EXIT.
*--2007.01.11 BG (FMC)
   ENDIF.

*  az adatok feldolgozása
   PERFORM FELDOLGOZ TABLES I_/ZAK/ANALITIKA
                            I_/ZAK/SZJA_ABEV
                            I_/ZAK/SZJA_EXCEL
                            USING V_SUBRC.
*++2007.01.11 BG (FMC)
*   IF SY-SUBRC <> 0.
*     EXIT.
*   ENDIF.
   IF  V_SUBRC NE 0.
     MESSAGE E206.
*    Súlyos hiba a FELDOLGOZÁS rutinban!
   ENDIF.
*--2007.01.11 BG (FMC)

*++0005 2009.01.12 BG
* Könyvelés fájl forgatás (költséghely, rendelés, PC)
   PERFORM ROTATION_DATA(/ZAK/SZJA_SAP_SEL)
                         TABLES I_/ZAK/SZJA_EXCEL
                         USING  P_BUKRS.
*--0005 2009.01.12 BG
************************************************************************
 END-OF-SELECTION.
************************************************************************
   IF P_TESZT IS INITIAL.
*  A  könyvelendőket EXCELbe
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
*    Ha sikeres volt az Excelbe töltés, aktualizálja az állományt
     IF V_SUBRC = 0.
       PERFORM SET_BOOK.
       MESSAGE I009 WITH P_OUTF.
*      & fájl sikeresen letöltve
*++2009.04.02 BG
     ELSE.
       MESSAGE E175 WITH P_OUTF.
*     Hiba a & fájl letöltésénél.
*--2009.04.02 BG
     ENDIF.
   ENDIF.

   PERFORM LIST_DISPLAY.




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
     IF SCREEN-GROUP1 = 'DIS'
        OR SCREEN-NAME = 'P_BTYPAR'.
       SCREEN-INPUT = 0.
       SCREEN-OUTPUT = 1.
       IF SCREEN-NAME = 'P_BTYPAR'.
         SCREEN-DISPLAY_3D = 1.
       ELSE.
         SCREEN-DISPLAY_3D = 0.
       ENDIF.
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
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILENAME_GET USING $FILE.

   DATA: L_FILENAME   TYPE STRING,
         L_PATH       TYPE STRING,
         L_FULLPATH   TYPE STRING.

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


   DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*   CALL FUNCTION 'WS_FILENAME_GET'
*      EXPORTING  DEF_FILENAME     =  '*.XLS'
**                 DEF_PATH         = 'C:\temp'
*                 MASK             =  L_MASK
*                 MODE             = 'S'
*                 TITLE            =  'Könyvelési fájl'
*      IMPORTING  FILENAME         =  $FILE
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
*     DEFAULT_EXTENSION =
*     EFAULT_FILE_NAME  =
*     WITH_ENCODING     =
      FILE_FILTER       = '*.XLS'
*     INITIAL_DIRECTORY =
*     DEFAULT_ENCODING  =
    IMPORTING
*     FILENAME          =
*     PATH              =
      FULLPATH          = L_FULLPATH
*     USER_ACTION       =
*     FILE_ENCODING     =
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
*++0001 2007.01.03 BG (FMC)
            L_FULLPATH   TYPE STRING,
            L_RC         TYPE I.
*           L_FULLPATH   LIKE RLGRAP-FILENAME,
*           L_RC         TYPE C.

*--0001 2007.01.03 BG (FMC)

   DATA: BEGIN OF LI_FILE OCCURS 0,
           LINE(50),
         END OF LI_FILE.
   IF $FILE IS INITIAL AND
      P_TESZT IS INITIAL.
     MESSAGE E146 .
   ENDIF.
   CHECK NOT $FILE IS INITIAL.
   MOVE $FILE TO L_FULLPATH.

   MOVE '1' TO LI_FILE-LINE.

*++0001 2007.01.03 BG (FMC)
* ++ 0001 CST 2006.05.27
*
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
       OTHERS                  = 22.

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
   ENDIF.
 ENDFORM.                    "VER_FILENAME
*&---------------------------------------------------------------------*
*&      Form  valogat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT USING  $SUBRC.
*++0002 BG 2006/10/26
**   /ZAK/BEVALL leválogatása
*   PERFORM VALOGAT_/ZAK/BEVALL  USING W_/ZAK/BEVALL
*                                     P_BUKRS
*                                     P_BTYPE
*                            CHANGING V_SUBRC.
*   IF V_SUBRC <> 0.
**    Hiba az BEVALL - MEZŐ meghatározásánál!
*     MESSAGE E089 WITH '/ZAK/BEVALL_V'.
*   ENDIF.
*--0002 BG 2006/10/26
*++0002 BG 2006/10/26
*  Beállítások laválogatása
   PERFORM VALOGAT_BEALLITAS TABLES I_/ZAK/SZJA_CUST
                                    R_BTYPE
                              USING P_BUKRS
*                                   P_BTYPE
*                                   P_BSZNUM
                           CHANGING V_SUBRC.
*--0002 BG 2006/10/26
   $SUBRC = V_SUBRC.
   IF V_SUBRC <> 0.
*    Hiba az SZJA beállítások meghatározásánál!
     MESSAGE E089 WITH '/ZAK/SZJA_CUST_V'.
   ENDIF.
*++0002 BG 2006/10/26
   PERFORM VALOGAT_SZJA_ABEV TABLES I_/ZAK/SZJA_ABEV
                                    R_BTYPE
                             USING  P_BUKRS
*                                   P_BTYPE
                          CHANGING  V_SUBRC.
*--0002 BG 2006/10/26
   IF V_SUBRC <> 0.
*    Hiba az ABEV - MEZŐ meghatározásánál!
     MESSAGE E089 WITH '/ZAK/SZJA_ABEV'.
   ENDIF.
*++0002 BG 2006/10/26
   PERFORM VALOGAT_BEVALLSZ TABLES I_/ZAK/BEVALLSZ
                                   I_/ZAK/SZJA_CUST
                                   R_BTYPE
                             USING P_BUKRS
*                                  P_BTYPE
                          CHANGING V_SUBRC.
*--0002 BG 2006/10/26
   IF V_SUBRC <> 0.
*    Hiba az ABEV - MEZŐ meghatározásánál!
*     MESSAGE E089 WITH '/ZAK/BEVALLSZ'
*++0002 BG 2006/10/26
*     MESSAGE A031.
     MESSAGE I031.
     EXIT.
*--0002 BG 2006/10/26
   ENDIF.

   PERFORM VALOGAT_ANALITIKA TABLES I_/ZAK/ANALITIKA
                                    I_/ZAK/BEVALLSZ
                           CHANGING V_SUBRC.
   IF V_SUBRC <> 0.
*    Hiba az ABEV - MEZŐ meghatározásánál!
     MESSAGE E141  .
   ENDIF.




 ENDFORM.                    " valogat
*&---------------------------------------------------------------------*
*&      Form  VALOGAT_SZJA_ABEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_ABEV  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_SZJA_ABEV TABLES   $/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                                 $BTYPE STRUCTURE R_BTYPE
                        USING    $BUKRS
*                                $BTYPE
                        CHANGING $SUBRC.
   SELECT * INTO TABLE $/ZAK/SZJA_ABEV
            FROM /ZAK/SZJA_ABEV
            WHERE BUKRS     = $BUKRS
*             AND BTYPE     = $BTYPE.
              AND BTYPE     IN $BTYPE.

   $SUBRC = SY-SUBRC.

 ENDFORM.                    " VALOGAT_SZJA_ABEV
*&---------------------------------------------------------------------*
*&      Form  valogat_analitika
*&---------------------------------------------------------------------*
*       Csak az a rekord kell, ahol könyvelésre jelölt BOOK = 'M'.
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/ANALITIKA  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_ANALITIKA TABLES   $/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                                 $I_/ZAK/BEVALLSZ STRUCTURE /ZAK/BEVALLSZ
                         CHANGING $SUBRC.
   SELECT * FROM /ZAK/ANALITIKA
            INTO TABLE $/ZAK/ANALITIKA
            FOR ALL ENTRIES IN $I_/ZAK/BEVALLSZ
            WHERE BUKRS  = $I_/ZAK/BEVALLSZ-BUKRS
             AND  BTYPE  = $I_/ZAK/BEVALLSZ-BTYPE
             AND  BSZNUM = $I_/ZAK/BEVALLSZ-BSZNUM
             AND  GJAHR  = $I_/ZAK/BEVALLSZ-GJAHR
             AND  MONAT  = $I_/ZAK/BEVALLSZ-MONAT
             AND  ZINDEX = $I_/ZAK/BEVALLSZ-ZINDEX
             AND  PACK   = $I_/ZAK/BEVALLSZ-PACK
             AND  BOOK  = 'M'.


   $SUBRC = SY-SUBRC.

 ENDFORM.                    " valogat_analitika
*&---------------------------------------------------------------------*
*&      Form  FELDOLGOZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/ANALITIKA  text
*      -->P_I_/ZAK/SZJA_ABEV  text
*      -->P_I_RETURN  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM FELDOLGOZ TABLES   $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                         $I_/ZAK/SZJA_ABEV STRUCTURE /ZAK/SZJA_ABEV
                         $I_/ZAK/SZJA_EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                USING    $SUBRC.
   DATA: L_RETURN        TYPE STANDARD TABLE OF BAPIRET2
                                        INITIAL SIZE 0.
   DATA W_RETURN TYPE BAPIRET2.

*++0004 2008.10.31 BG
   DEFINE LR_GET_SZAMLA_BELNR.
     IF NOT &1 IS INITIAL.
       IF &2 = &1.
         CLEAR &2.
       ENDIF.
     ENDIF.
   END-OF-DEFINITION.
*--0004 2008.10.31 BG


   W_RETURN-TYPE    = 'E'.
   W_RETURN-ID      = '/ZAK/ZAK'.
*   W_RETURN-NUMBER  = '113'.
*++FI 20070213
   DATA: L_SZAMLA_BELNR(10).
*--FI 20070213

   LOOP AT $I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA .
*
     W_RETURN-MESSAGE_V1 = W_/ZAK/ANALITIKA-BSEG_GJAHR.
     W_RETURN-MESSAGE_V2 = W_/ZAK/ANALITIKA-BSEG_BELNR.
     W_RETURN-MESSAGE_V3 = W_/ZAK/ANALITIKA-BSEG_BUZEI.
     W_RETURN-MESSAGE_V4 = W_/ZAK/ANALITIKA-ABEVAZ.

*++0908 2009.02.04 BG
*     READ TABLE $I_/ZAK/SZJA_ABEV
*          INTO W_/ZAK/SZJA_ABEV
*          WITH KEY BUKRS  =  W_/ZAK/ANALITIKA-BUKRS
*                   BTYPE  =  W_/ZAK/ANALITIKA-BTYPE
*                   ABEVAZ =  W_/ZAK/ANALITIKA-ABEVAZ.
*    Először adatszolgáltatás azonosító szerint keressük:
     READ TABLE $I_/ZAK/SZJA_ABEV
          INTO W_/ZAK/SZJA_ABEV
          WITH KEY BUKRS  =  W_/ZAK/ANALITIKA-BUKRS
                   BTYPE  =  W_/ZAK/ANALITIKA-BTYPE
                   BSZNUM =  W_/ZAK/ANALITIKA-BSZNUM
                   ABEVAZ =  W_/ZAK/ANALITIKA-ABEVAZ.
*    Ha így nincs olvassuk a '000' azonosítót
     IF SY-SUBRC NE 0.
       READ TABLE $I_/ZAK/SZJA_ABEV
            INTO W_/ZAK/SZJA_ABEV
            WITH KEY BUKRS  =  W_/ZAK/ANALITIKA-BUKRS
                     BTYPE  =  W_/ZAK/ANALITIKA-BTYPE
                     BSZNUM =  '000'
                     ABEVAZ =  W_/ZAK/ANALITIKA-ABEVAZ.
     ENDIF.
*--0908 2009.02.04 BG
*   Ha nem talál beállítást, akkor hiba
     IF SY-SUBRC <> 0.
       W_RETURN-NUMBER  = '142'.

       APPEND W_RETURN TO L_RETURN.
       CONTINUE.
     ENDIF.
*    ha incs kitöltve a TART/KOV az is hiba
     IF W_/ZAK/SZJA_ABEV-TARTOZIK IS INITIAL OR
        W_/ZAK/SZJA_ABEV-KOVETEL  IS INITIAL .
       W_RETURN-NUMBER  = '143'.

       APPEND W_RETURN TO L_RETURN.
       CONTINUE.
     ENDIF.
*    KÖNYVELÉS elkészítése ***********************
*     PERFORM BOOK_ANALITIKA USING
*                                  W_/ZAK/ANALITIKA
*                                  W_/ZAK/SZJA_ABEV
*                                  W_/ZAK/BEVALL
*                                  W_/ZAK/SZJA_EXCEL.
**           kiírja a rekordot
*     APPEND W_/ZAK/SZJA_EXCEL TO I_/ZAK/SZJA_EXCEL.
     PERFORM BOOK_ANALITIKA_V2 USING
                                  W_/ZAK/ANALITIKA
                                  W_/ZAK/SZJA_ABEV
                                  W_/ZAK/BEVALL
                                  W_/ZAK/SZJA_EXCEL1
                                  W_/ZAK/SZJA_EXCEL2.
*           kiírja a rekordot
*    Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az
*++0004 2008.10.31 BG
*    Állomány darabolás
     LR_GET_SZAMLA_BELNR P_SPLIT L_SZAMLA_BELNR.
*--0004 2008.10.31 BG
     L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
     W_/ZAK/SZJA_EXCEL1-BIZ_AZON = L_SZAMLA_BELNR.
     W_/ZAK/SZJA_EXCEL2-BIZ_AZON = L_SZAMLA_BELNR.
     APPEND W_/ZAK/SZJA_EXCEL1 TO I_/ZAK/SZJA_EXCEL.
     APPEND W_/ZAK/SZJA_EXCEL2 TO I_/ZAK/SZJA_EXCEL.
   ENDLOOP.
*  Üzenetek kezelése
   IF NOT L_RETURN[] IS INITIAL.
     CALL FUNCTION '/ZAK/MESSAGE_SHOW'
       TABLES
         T_RETURN = L_RETURN.
     $SUBRC = 4.
   ENDIF.
   W_RETURN-NUMBER  = '113'.

*++0004 2008.10.31 BG
* Ez nem tudjuk mire kellett de ez az utasítás nem törölt ki semmit
* mivel a bizonylatszámok soha nem egyeztek meg.
**++BG 2006.12.28
**Duplikált tételek kiszűrése egy éven belül több bevallás típus
**miatt
*   SORT I_/ZAK/SZJA_EXCEL.
*   DELETE ADJACENT DUPLICATES FROM I_/ZAK/SZJA_EXCEL.
**--BG 2006.12.28
*++0004 2008.10.31 BG


 ENDFORM.                    " FELDOLGOZ
*&---------------------------------------------------------------------*
*&      Form  VALOGAT_bevallsz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALLSZ  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM VALOGAT_BEVALLSZ TABLES   $I_/ZAK/BEVALLSZ STRUCTURE  /ZAK/BEVALLSZ
                                $I_/ZAK/SZJA_CUST STRUCTURE /ZAK/SZJA_CUST
                                $BTYPE   STRUCTURE R_BTYPE
                       USING    $BUKRS
*                               $BTYPE
                       CHANGING $SUBRC.
   RANGES : R_FLAG FOR /ZAK/BEVALLSZ-FLAG.
* összerakja, milyen FLAG nem kell
   R_FLAG = 'EEQ'.
   R_FLAG-LOW = 'Z'. APPEND R_FLAG.
   R_FLAG-LOW = 'X'. APPEND R_FLAG.
   R_FLAG-LOW = 'E'. APPEND R_FLAG.
   R_FLAG-LOW = 'B'. APPEND R_FLAG.

   SELECT * INTO TABLE $I_/ZAK/BEVALLSZ
            FROM /ZAK/BEVALLSZ
            FOR ALL ENTRIES IN $I_/ZAK/SZJA_CUST
            WHERE BUKRS  = $I_/ZAK/SZJA_CUST-BUKRS
             AND  BTYPE  = $I_/ZAK/SZJA_CUST-BTYPE
             AND  BSZNUM = $I_/ZAK/SZJA_CUST-BSZNUM
             AND  FLAG   IN R_FLAG.

   $SUBRC = SY-SUBRC.


 ENDFORM.                    " VALOGAT_bevallsz
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
                        USING    $BUKRS
*                                $BTYPE
                        CHANGING $SUBRC.
*a szelekciós képernyő adatai alapján leválogatja a beállítás adatokat

   SELECT * INTO TABLE $/ZAK/SZJA_CUST
            FROM /ZAK/SZJA_CUST
            WHERE BUKRS  = $BUKRS
*             AND BTYPE  = $BTYPE.
              AND BTYPE  IN $BTYPE.

   $SUBRC = SY-SUBRC.
 ENDFORM.                    " valogat_beallitas
*&---------------------------------------------------------------------*
*&      Form  BOOK_ANALITIKA_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BKPF  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_W_/ZAK/BEVALL  text
*      -->P_W_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM BOOK_ANALITIKA_V2 USING
                     $ANALITIKA STRUCTURE /ZAK/ANALITIKA
                     $ABEV STRUCTURE /ZAK/SZJA_ABEV
                     $BEVALL STRUCTURE /ZAK/BEVALL
                     $EXCEL1 STRUCTURE /ZAK/SZJAEXCELV2
                     $EXCEL2 STRUCTURE /ZAK/SZJAEXCELV2.
   DATA : L_TMP_DAT LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR,
          L_TMP_KOSTL LIKE /ZAK/ANALITIKA-HKONT.
   CLEAR : $EXCEL1,$EXCEL2.

   CLEAR $BEVALL.
   READ TABLE I_/ZAK/BEVALL INTO $BEVALL
                           WITH KEY BUKRS = $ANALITIKA-BUKRS
                                    BTYPE = $ANALITIKA-BTYPE.
   $EXCEL1-BIZ_TETEL = '0001'.
   $EXCEL2-BIZ_TETEL = '0002'.
   $EXCEL1-PENZNEM = $ANALITIKA-WAERS.
   $EXCEL2-PENZNEM = $ANALITIKA-WAERS.
*  Bizonylat dátum meghatározása
*++0005 2009.01.12 BG
   IF NOT $ANALITIKA-BLDAT IS INITIAL.
     L_TMP_DAT = $ANALITIKA-BLDAT.
   ELSE.
*--0005 2009.01.12 BG
     PERFORM GET_LAST_DAY_OF_PERIOD USING $ANALITIKA-GJAHR
                                          $ANALITIKA-MONAT
                                 CHANGING L_TMP_DAT .
*++0005 2009.01.12 BG
   ENDIF.
*--0005 2009.01.12 BG

   WRITE  L_TMP_DAT     TO $EXCEL1-BIZ_DATUM.
   WRITE  L_TMP_DAT     TO $EXCEL2-BIZ_DATUM.

*  Bizonylat fajta meghatározása
   PERFORM GET_BLART USING L_TMP_DAT "Bizonylat dátum
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL1-BF   .
   $EXCEL2-BF = $EXCEL1-BF.
*  Vállalat
*   MOVE   P_BUKRS   TO $EXCEL-VALL.
*  Könyvelési dátum
   WRITE  P_BUDAT     TO $EXCEL1-KONYV_DAT.
   WRITE  P_BUDAT     TO $EXCEL2-KONYV_DAT.
*++0908 2009.03.10 BG
**  Bizdátum figyelése
*   IF $EXCEL1-BIZ_DATUM > $EXCEL1-KONYV_DAT.
*     $EXCEL1-BIZ_DATUM = $EXCEL1-KONYV_DAT.
*     $EXCEL2-BIZ_DATUM = $EXCEL2-KONYV_DAT.
*   ENDIF.
*--0908 2009.03.10 BG
*  Periódus
   MOVE   P_MONAT       TO $EXCEL1-HO.
   MOVE   P_MONAT       TO $EXCEL2-HO.
*  Fejszoveg
   MOVE $ANALITIKA-PACK TO $EXCEL1-FEJSZOVEG.
   MOVE $ANALITIKA-PACK TO $EXCEL2-FEJSZOVEG.
*++ 0003 FI
   MOVE   $ABEV-TARTOZIK     TO $EXCEL1-FOKONYV.
   MOVE   $ABEV-KOVETEL      TO $EXCEL2-FOKONYV.
   IF $ANALITIKA-FIELD_N >= 0.
     CLEAR $EXCEL2-KTGH .
     $EXCEL1-KK = '40'.
     $EXCEL2-KK = '50'.
   ELSE.
*    Ha az érték negatív, akkor cserélődik a KK
     CLEAR $EXCEL1-KTGH .
     $EXCEL1-KK = '50'.
     $EXCEL2-KK = '40'.
   ENDIF.
*   IF $ANALITIKA-FIELD_N >= 0.
*     MOVE   $ABEV-TARTOZIK     TO $EXCEL1-FOKONYV.
*     MOVE   $ABEV-KOVETEL      TO $EXCEL2-FOKONYV.
*     CLEAR $EXCEL2-KTGH .
*     $EXCEL1-KK = '40'.
*     $EXCEL2-KK = '50'.
*   ELSE.
**    Ha az érték negatív, akkor cserélődik az 1 és 2
*     MOVE   $ABEV-TARTOZIK     TO $EXCEL2-FOKONYV.
*     MOVE   $ABEV-KOVETEL      TO $EXCEL1-FOKONYV.
*     CLEAR $EXCEL1-KTGH .
*     $EXCEL1-KK = '50'.
*     $EXCEL2-KK = '40'.
*   ENDIF.
*-- 0003 FI
*  KÖLTSÉGHELYEK MEGHATÁROZÁSA
   PERFORM GET_KTGH USING $EXCEL1-FOKONYV
                          P_BUDAT " könyvelési dátum
                          $ANALITIKA-KOSTL
                          $ANALITIKA-AUFNR
*++0006 BG 2009.08.25
                          $ANALITIKA-POSID
*--0006 BG 2009.08.25
                          $EXCEL1-KTGH
                          $EXCEL1-RENDELES
*++0006 BG 2009.08.25
                          $EXCEL1-PST
*--0006 BG 2009.08.25
                          .
   PERFORM GET_KTGH USING $EXCEL2-FOKONYV
                          P_BUDAT " könyvelési dátum
                          $ANALITIKA-KOSTL
                          $ANALITIKA-AUFNR
*++0006 BG 2009.08.25
                          $ANALITIKA-POSID
*--0006 BG 2009.08.25
                          $EXCEL2-KTGH
                          $EXCEL2-RENDELES
*++0006 BG 2009.08.25
                          $EXCEL2-PST
*--0006 BG 2009.08.25
                          .
*  Hozzarendelés
   MOVE $ANALITIKA-BSEG_BELNR  TO $EXCEL1-HOZZARENDELES.
   MOVE $ANALITIKA-BSEG_BELNR  TO $EXCEL2-HOZZARENDELES.
*  Szöveg
   WRITE  $ANALITIKA-HKONT  TO $EXCEL1-SZOVEG .
   WRITE  $ANALITIKA-HKONT  TO $EXCEL2-SZOVEG .
*  Szöveg
*++ FI 20070312
   IF $ANALITIKA-HKONT IS INITIAL.
*    Ha "B" blokkos, akkor az kell a szövegbe
     IF $ANALITIKA-BSZNUM = '117' OR
        $ANALITIKA-BSZNUM = '118' OR
        $ANALITIKA-BSZNUM = '119'.
       CONCATENATE '"B" Blokk -'
                   $ANALITIKA-BSZNUM
              INTO $EXCEL1-SZOVEG SEPARATED BY SPACE.
     ELSE.
       MOVE $ANALITIKA-BSZNUM TO $EXCEL1-SZOVEG.
     ENDIF.
     $EXCEL2-SZOVEG = $EXCEL1-SZOVEG.
   ELSE.
*  Szöveg
     WRITE  $ANALITIKA-HKONT  TO $EXCEL1-SZOVEG .
     WRITE  $ANALITIKA-HKONT  TO $EXCEL2-SZOVEG .

   ENDIF.
*-- FI 20070312
*  Az érték abszulut értékben kell
   $ANALITIKA-FIELD_N = ABS( $ANALITIKA-FIELD_N ).
   WRITE $ANALITIKA-FIELD_N CURRENCY $ANALITIKA-WAERS TO $EXCEL1-OSSZEG.
   PERFORM SZAM_ATIR USING $EXCEL1-OSSZEG.
   $EXCEL2-OSSZEG = $EXCEL1-OSSZEG.
   MOVE $ANALITIKA-GSBER TO $EXCEL1-UZLETAG.
   MOVE $ANALITIKA-GSBER TO $EXCEL2-UZLETAG.

 ENDFORM.                    " BOOK_ANALITIKA_v2
*&---------------------------------------------------------------------*
*&      Form  BOOK_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BKPF  text
*      -->P_W_BSEG  text
*      -->P_W_/ZAK/SZJA_ABEV  text
*      -->P_W_/ZAK/BEVALL  text
*      -->P_W_/ZAK/SZJA_EXCEL  text
*----------------------------------------------------------------------*
 FORM BOOK_ANALITIKA USING
                     $ANALITIKA STRUCTURE /ZAK/ANALITIKA
                     $ABEV STRUCTURE /ZAK/SZJA_ABEV
                     $BEVALL STRUCTURE /ZAK/BEVALL
                     $EXCEL STRUCTURE /ZAK/SZJA_EXCEL.
   DATA : L_TMP_DAT LIKE SY-DATUM,
          L_TMP_DMBTR LIKE BSEG-DMBTR,
          L_TMP_KOSTL LIKE /ZAK/ANALITIKA-HKONT.
   CLEAR : $EXCEL.

*++0002 BG 2006/10/26
   CLEAR $BEVALL.
   READ TABLE I_/ZAK/BEVALL INTO $BEVALL
                           WITH KEY BUKRS = $ANALITIKA-BUKRS
                                    BTYPE = $ANALITIKA-BTYPE.
*--0002 BG 2006/10/26

*  Bizonylat dátum meghatározása
   PERFORM GET_LAST_DAY_OF_PERIOD USING $ANALITIKA-GJAHR
                                        $ANALITIKA-MONAT
                               CHANGING L_TMP_DAT .

   WRITE  L_TMP_DAT     TO $EXCEL-BIZ_DATUM.

*  Bizonylat fajta meghatározása
   PERFORM GET_BLART USING L_TMP_DAT "Bizonylat dátum
                           P_GJAHR
                           $BEVALL-BLART
                  CHANGING $EXCEL-BF   .
*  Vállalat
   MOVE   P_BUKRS   TO $EXCEL-VALL.
*  Könyvelési dátum
   WRITE  P_BUDAT     TO $EXCEL-KONYV_DAT.
*++0908 2009.03.10 BG
**  Bizdátum figyelése
*   IF $EXCEL-BIZ_DATUM > $EXCEL-KONYV_DAT.
*     $EXCEL-BIZ_DATUM = $EXCEL-KONYV_DAT.
*   ENDIF.
*--0908 2009.03.10 BG
*  Periódus
   MOVE   P_MONAT       TO $EXCEL-HO.
*  Fejszoveg
   MOVE $ANALITIKA-PACK TO $EXCEL-FEJSZOVEG.

   IF $ANALITIKA-FIELD_N >= 0.
     MOVE   $ABEV-TARTOZIK     TO $EXCEL-SZAMLA1.
     MOVE   $ABEV-KOVETEL      TO $EXCEL-SZAMLA2.
     CLEAR $EXCEL-KTGH2.

   ELSE.
*    Ha az érték negatív, akkor cserélődik az 1 és 2
     MOVE   $ABEV-TARTOZIK     TO $EXCEL-SZAMLA2.
     MOVE   $ABEV-KOVETEL      TO $EXCEL-SZAMLA1.
     CLEAR $EXCEL-KTGH1.
   ENDIF.
*  KÖLTSÉGHELYEK MEGHATÁROZÁSA
   PERFORM GET_KTGH USING $EXCEL-SZAMLA1
                          P_BUDAT " könyvelési dátum
                          $ANALITIKA-KOSTL
*++ BG 2007.01.24
                          $ANALITIKA-AUFNR
*-- BG 2007.01.24
*++0006 BG 2009/08/25
                          $ANALITIKA-POSID
*--0006 BG 2009/08/25

                          $EXCEL-KTGH1
*++ BG 2007.01.24
                          $EXCEL-B_RENDEL1
*-- BG 2007.01.24
*++0006 BG 2009/08/25
                          $EXCEL-PST1
*--0006 BG 2009/08/25

                          .
   PERFORM GET_KTGH USING $EXCEL-SZAMLA2
                          P_BUDAT " könyvelési dátum
                          $ANALITIKA-KOSTL
*++ BG 2007.01.24
                          $ANALITIKA-AUFNR
*-- BG 2007.01.24
*++0006 BG 2009/08/25
                          $ANALITIKA-POSID
*--0006 BG 2009/08/25
                          $EXCEL-KTGH2
*++ BG 2007.01.24
                          $EXCEL-B_RENDEL2
*-- BG 2007.01.24
*++0006 BG 2009/08/25
                          $EXCEL-PST2
*--0006 BG 2009/08/25
                          .
*  Hozzarendelés
* ++ FI 20070111
*   MOVE $ANALITIKA-BSEG_BELNR  TO $EXCEL-HOZZARENDEL.
   MOVE $ANALITIKA-BSEG_BELNR  TO $EXCEL-HOZZARENDEL1.
   MOVE $ANALITIKA-BSEG_BELNR  TO $EXCEL-HOZZARENDEL2.
* -- FI 20070111
*  Szöveg
* ++ FI 20070111
*   WRITE  $ANALITIKA-HKONT  TO $EXCEL-SZOVEG.
   WRITE  $ANALITIKA-HKONT  TO $EXCEL-SZOVEG1.
   WRITE  $ANALITIKA-HKONT  TO $EXCEL-SZOVEG2.
*++ BG 2007.01.24
*   IF $EXCEL-KTGH1 IS NOT INITIAL.
*     $EXCEL-V_RENDEL1 = $ANALITIKA-AUFNR.
*   ENDIF.
*   IF $EXCEL-KTGH2 IS NOT INITIAL.
*     $EXCEL-V_RENDEL2 = $ANALITIKA-AUFNR.
*   ENDIF.
*-- BG 2007.01.24
* -- FI 20070111

*  Az érték abszulut értékben kell
   $ANALITIKA-FIELD_N = ABS( $ANALITIKA-FIELD_N ).
   WRITE $ANALITIKA-FIELD_N CURRENCY $ANALITIKA-WAERS TO $EXCEL-FORINT.
   PERFORM SZAM_ATIR USING $EXCEL-FORINT.

*++ BG 20070118
   MOVE $ANALITIKA-GSBER TO $EXCEL-UAG1.
   MOVE $ANALITIKA-GSBER TO $EXCEL-UAG2.
*-- BG 20070118

 ENDFORM.                    " BOOK_ANALITIKA
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
         L_DIF TYPE I,
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

   CALL FUNCTION 'LAST_DAY_OF_MONTHS' "#EC CI_USAGE_OK[2296016]
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
*&      Form  get_ktgh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$EXCEL_SZAMLA1  text
*      -->P_L_TMP_DAT  text
*      -->P_$ANALITIKA_KOSTL  text
*      -->P_L_TMP_KOSTL  text
*----------------------------------------------------------------------*
 FORM GET_KTGH USING    $SZAMLA1
                        $DAT
                        $KOSTL_I
                        $AUFNR_I
*++0006 BG 2009/08/25
                        $PST_I
*--0006 BG 2009/08/25
                        $KOSTL_O
                        $AUFNR_O
*++0006 BG 2009/08/25
                        $PST_O
*--0006 BG 2009/08/25
                        .

   DATA : V_KOKRS LIKE TKA02-KOKRS  .
   SELECT SINGLE KOKRS INTO V_KOKRS
      FROM TKA02
      WHERE BUKRS = P_BUKRS AND
            GSBER = SPACE.

   CALL FUNCTION 'RK_KSTAR_READ'
     EXPORTING
       DATUM                 = $DAT
       KOKRS                 = V_KOKRS
       KSTAR                 = $SZAMLA1
*    SPRAS                 = ' '
*  IMPORTING
*    KTEXT                 =
*    V_CSKB                =
  EXCEPTIONS
    KSTAR_NOT_FOUND       = 1
*++ BG 2007.01.24 Szintaktikai ellenőrzés miatt.
*    TEXT_NOT_FOUND        = 2
*    OTHERS                = 3
*-- BG 2007.01.24

             .
   IF SY-SUBRC <> 0.
*++0006 BG 2009/08/25
*    CLEAR $KOSTL_O.
     CLEAR: $KOSTL_O, $AUFNR_O, $PST_O.
*--0006 BG 2009/08/25
   ELSE.
     WRITE $KOSTL_I TO $KOSTL_O .
*++ BG 2007.01.24
     MOVE  $AUFNR_I TO $AUFNR_O.
*-- BG 2007.01.24
*++0006 BG 2009/08/25
     MOVE $PST_I TO $PST_O.
*--0006 BG 2009/08/25
   ENDIF.


 ENDFORM.                    " get_ktgh
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LIST_DISPLAY.
*++0004 2008.10.31 BG
*   SORT I_/ZAK/SZJA_EXCEL .
*--0004 2008.10.31 BG
   CALL SCREEN 9001.


 ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9001 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

   PERFORM SET_STATUS.

   IF V_CUSTOM_CONTAINER IS INITIAL.
     PERFORM CREATE_AND_INIT_ALV CHANGING I_/ZAK/SZJA_EXCEL[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT.

   ENDIF.




 ENDMODULE.                 " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
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

   IF SY-DYNNR = '9001'.
     IF P_TESZT IS INITIAL.
       SET TITLEBAR 'MAIN9001'.
     ELSE.
       SET TITLEBAR 'MAIN9001T'.
     ENDIF.
     SET PF-STATUS 'MAIN9001'.
   ENDIF.

 ENDFORM.                    " SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_/ZAK/SZJA_EXCEL[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV CHANGING $I_/ZAK/SZJA_EXCEL LIKE
                                                    I_/ZAK/SZJA_EXCEL[]
                                    $FIELDCAT  TYPE LVC_T_FCAT
                                    $LAYOUT    TYPE LVC_S_LAYO
                                    $VARIANT   TYPE DISVARIANT.
   DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER
          EXPORTING CONTAINER_NAME = V_CONTAINER.
   CREATE OBJECT V_GRID
          EXPORTING I_PARENT = V_CUSTOM_CONTAINER.

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

*   CREATE OBJECT V_EVENT_RECEIVER.
*   SET HANDLER V_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK  FOR V_GRID.

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


   IF $DYNNR = '9001'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/SZJAEXCELV2'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = $FIELDCAT.

   ENDIF.
 ENDFORM.                    "BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9001 INPUT.
   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.
* Kilépés
     WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
       PERFORM EXIT_PROGRAM.

     WHEN OTHERS.
*     do nothing
   ENDCASE.

 ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXIT_PROGRAM.
*   LEAVE PROGRAM.
   LEAVE TO SCREEN 0.
 ENDFORM.                    " EXIT_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_EXCEL  text
*      -->P_P_OUTF  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE_V2  TABLES $EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                     USING  $OUTF
                     CHANGING L_SUBRC.

   DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
         L_CANCEL(1).

   DATA: BEGIN OF I_FIELDS OCCURS 10,
           NAME(40),
         END OF I_FIELDS.

   DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
   DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

   DATA  L_FILENAME TYPE STRING.



*  concatenate p_bukrs l_adonem l_esdat into l_def_filename
*    separated by '_'.
*  concatenate l_def_filename '.XLS' into l_def_filename.

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

     LOOP AT I_DD03P WHERE FIELDNAME <> '.INCLUDE'.
       CLEAR I_FIELDS-NAME.
       I_FIELDS-NAME = I_DD03P-SCRTEXT_M.
       APPEND I_FIELDS.
     ENDLOOP.

   ENDIF.

*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
**++0001 2007.01.03 BG (FMC)
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
  DATA l_filename_string TYPE string.

  MOVE $OUTF TO l_filename_string.


  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = l_filename_string
      filetype                = 'DAT'
      FIELDNAMES              = I_FIELDS[]
    CHANGING
      data_tab                = $EXCEL[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
   IF SY-SUBRC <> 0.
*++2009.04.02 BG
     MOVE SY-SUBRC TO L_SUBRC.
*--2009.04.02 BG
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
*--0001 2007.01.03 BG (FMC)


 ENDFORM.                    " DOWNLOAD_FILE_v2
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/SZJA_EXCEL  text
*      -->P_P_OUTF  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
 FORM DOWNLOAD_FILE  TABLES $EXCEL STRUCTURE /ZAK/SZJA_EXCEL
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

   DATA  L_FILENAME TYPE STRING.



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
       I_FIELDS-NAME = I_DD03P-SCRTEXT_S.
       APPEND I_FIELDS.
     ENDLOOP.

   ENDIF.
*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
*++0001 2007.01.03 BG (FMC)
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
  DATA l_filename_string TYPE string.

  MOVE $OUTF TO l_filename_string.


  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = l_filename_string
      filetype                = 'DAT'
      FIELDNAMES              = I_FIELDS[]
    CHANGING
      data_tab                = $EXCEL[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
*--0001 2007.01.03 BG (FMC)


 ENDFORM.                    " DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  set_book
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_BOOK.
   DATA L_SUBRC LIKE SY-SUBRC.
   W_/ZAK/ANALITIKA-BOOK = 'B'.
*  Analitika wisszaírása könyveltre
   MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING BOOK
                          WHERE BOOK <> 'B'.
   UPDATE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.
   IF SY-SUBRC = 0.
*    /ZAK/BEVALLSZ is visszaíródhat.
     W_/ZAK/BEVALLSZ-FLAG = 'B'.
     MODIFY I_/ZAK/BEVALLSZ FROM W_/ZAK/BEVALLSZ TRANSPORTING FLAG
                        WHERE FLAG <> 'B'.
     UPDATE /ZAK/BEVALLSZ FROM TABLE I_/ZAK/BEVALLSZ.
     IF SY-SUBRC = 0.
       COMMIT WORK.
     ELSE.
       ROLLBACK WORK.
     ENDIF.
   ELSE.
     ROLLBACK WORK.
   ENDIF.

ENDFORM.                    " set_book
