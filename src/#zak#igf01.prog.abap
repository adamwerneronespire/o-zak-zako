*&---------------------------------------------------------------------*
*&  Include           /ZAK/IGF01
*&---------------------------------------------------------------------*
*& Közös rutinok
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  modif_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_SCREEN.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
    IF SCREEN-GROUP1 = 'OUT'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " modif_screen
*---------------------------------------------------------------------*
*       FORM EXIT_PROGRAM                                             *
*---------------------------------------------------------------------*
FORM EXIT_PROGRAM.
  LEAVE PROGRAM.
ENDFORM.                    "exit_progr
*&---------------------------------------------------------------------*
*&      Form  PREVIEW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREVIEW_DATA TABLES $I_/ZAK/IGDATA_ALV STRUCTURE /ZAK/IGDATA_ALV
                         $I_/ZAK/MGCIM STRUCTURE /ZAK/MGCIM
                         $I_SMART_DATA     STRUCTURE /ZAK/SMART_TABLE
                  USING  $FNAME
                         $BUKRS
                         $TEST
*++2008 #12.
                         $EVES.
*--2008 #12.


  DATA: LT_ROWS TYPE LVC_T_ROID WITH HEADER LINE,
        LS_ROWS TYPE LVC_S_ROID.

  DATA  L_FM_NAME TYPE RS38L_FNAM.

  DATA  LW_/ZAK/IGDATA_ALV LIKE W_/ZAK/IGDATA_ALV.

* Kijelölt tételek meghatározása
  CALL METHOD G_GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROWS[].

  IF LT_ROWS[] IS INITIAL.
    MESSAGE I018.
*   Kérem jelöljön ki egy tételt.
    EXIT.
  ENDIF.

* Űrlap adatok meghatározása
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = $FNAME
    IMPORTING
      FM_NAME            = L_FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE E263 WITH $FNAME.
*   Hiba a & űrlap beolvasásánál!
  ENDIF.

* Adatok feldolgozása
  LOOP AT LT_ROWS INTO LS_ROWS.
    READ TABLE $I_/ZAK/IGDATA_ALV INTO LW_/ZAK/IGDATA_ALV INDEX LS_ROWS-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    CLEAR W_/ZAK/MGCIM.
    REFRESH $I_SMART_DATA.
*   Címadatok meghatározása
    READ TABLE $I_/ZAK/MGCIM INTO W_/ZAK/MGCIM
               WITH KEY ADOAZON =  LW_/ZAK/IGDATA_ALV-ADOAZON
                        BINARY SEARCH.
    LOOP AT $I_/ZAK/IGDATA_ALV INTO W_/ZAK/IGDATA_ALV
                    WHERE ADOAZON =  LW_/ZAK/IGDATA_ALV-ADOAZON
                     AND  SORSZ   =  LW_/ZAK/IGDATA_ALV-SORSZ.
*     Kitöröljük a kijelölésből
      DELETE LT_ROWS WHERE ROW_ID = SY-TABIX.
      MOVE-CORRESPONDING W_/ZAK/IGDATA_ALV TO W_/ZAK/IGDATA.
      PERFORM GET_SMART_DATA TABLES I_/ZAK/IGABEV
                                    I_/ZAK/IGSORT
                                    I_BSZNUMT
                                    I_WAERST
                                    I_SMART_DATA
                             USING  W_/ZAK/IGDATA.
    ENDLOOP.
*   Űrlap meghívása
    PERFORM CALL_SMARTFORMS TABLES $I_SMART_DATA
                            USING  L_FM_NAME
                                   $FNAME
                                   $BUKRS
*++0002 2009.02.27 BG
                                   W_/ZAK/IGDATA-BTYPE
*--0002 2009.02.27 BG
                                   W_/ZAK/IGDATA-ADOAZON
                                   W_/ZAK/IGDATA-SORSZ
                                   W_/ZAK/MGCIM
                                   W_/ZAK/IGDATA-BSZNUM
                                   W_BSZNUMT-SZTEXT
                                   W_/ZAK/IGDATA-GJAHR
                                   W_/ZAK/IGDATA-MONAT
                                   $TEST
*++0001 2008.11.14 BG
                                   W_/ZAK/IGDATA-DATUM
                                   SPACE
*--0001 2008.11.14 BG
*++2008 #12.
                                   $EVES
*--2008 #12.
                                   .
  ENDLOOP.

ENDFORM.                    " PREVIEW_DAT
*&      Form  GET_SMART_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_/ZAK/IGABEV  text
*      -->P_$I_/ZAK/IGSORT  text
*      -->P_$I_BSZNUMT  text
*      -->P_$I_WAERST  text
*      -->P_$I_SMART_DATA  text
*      -->P_W_/ZAK/IGDATA  text
*----------------------------------------------------------------------*
FORM GET_SMART_DATA  TABLES $I_/ZAK/IGABEV STRUCTURE /ZAK/IGABEV
                            $I_/ZAK/IGSORT STRUCTURE /ZAK/IGSORT
                            $I_BSZNUMT LIKE I_BSZNUMT
                            $I_WAERST  LIKE I_WAERST
                            $I_SMART_DATA STRUCTURE /ZAK/SMART_TABLE
                     USING  $W_/ZAK/IGDATA STRUCTURE /ZAK/IGDATA.

  DATA  LW_/ZAK/IGDATA TYPE /ZAK/IGDATA.

  MOVE $W_/ZAK/IGDATA TO W_/ZAK/IGDATA.
  MOVE W_/ZAK/IGDATA TO LW_/ZAK/IGDATA.
  CLEAR W_/ZAK/IGABEV.
  READ TABLE $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV
             WITH KEY BUKRS  = $W_/ZAK/IGDATA-BUKRS
                      BTYPE  = $W_/ZAK/IGDATA-BTYPE
                      BSZNUM = $W_/ZAK/IGDATA-BSZNUM
                      IGAZON = $W_/ZAK/IGDATA-IGAZON.
* Igazolás sor megnevezése
  READ TABLE $I_/ZAK/IGSORT INTO W_/ZAK/IGSORT
        WITH KEY LANGU  = SY-LANGU
                 IGAZON = W_/ZAK/IGABEV-IGAZON.
* Adatszolgáltatás azonosító megnevezése
  READ TABLE $I_BSZNUMT INTO W_BSZNUMT
                        WITH KEY BSZNUM = W_/ZAK/IGDATA-BSZNUM.
*  Adatok feltöltése
  CLEAR W_SMART_DATA.
  W_SMART_DATA-TYPE = W_/ZAK/IGABEV-TYPE.
  W_SMART_DATA-NAME = W_/ZAK/IGSORT-NYTEXT.
  IF NOT W_/ZAK/IGDATA-FIELD_C IS INITIAL.
    MOVE W_/ZAK/IGDATA-FIELD_C TO W_SMART_DATA-VALUE.
  ELSEIF NOT W_/ZAK/IGDATA-FIELD_N IS INITIAL OR
         NOT W_/ZAK/IGABEV-OBLIG IS INITIAL.
    READ TABLE $I_WAERST INTO W_WAERST
          WITH KEY WAERS = W_/ZAK/IGDATA-WAERS.
    WRITE W_/ZAK/IGDATA-FIELD_N TO W_SMART_DATA-VALUE
                           CURRENCY W_/ZAK/IGDATA-WAERS
                           LEFT-JUSTIFIED.
    CONCATENATE W_SMART_DATA-VALUE W_WAERST-KTEXT
                INTO W_SMART_DATA-VALUE SEPARATED BY SPACE.
  ENDIF.
  CONDENSE W_SMART_DATA-VALUE.
  APPEND W_SMART_DATA TO $I_SMART_DATA.


ENDFORM.                    " GET_SMART_DATA

*&---------------------------------------------------------------------*
*&      Form  CALL_SMARTFORMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_SMART_DATA  text
*      -->P_L_FM_NAME  text
*      -->P_$BUKRS  text
*      -->P_LW_/ZAK/IGDATA_SORSZ  text
*      -->P_W_/ZAK/MGCIM  text
*      -->P_LW_/ZAK/IGDATA_BSZNUM  text
*      -->P_W_BSZNUMT_SZTEXT  text
*      -->P_LW_/ZAK/IGDATA_GJAHR  text
*----------------------------------------------------------------------*
FORM CALL_SMARTFORMS  TABLES   $I_SMART_DATA STRUCTURE /ZAK/SMART_TABLE
                      USING    $FM_NAME
                               $FNAME
                               $BUKRS
*++0002 2009.02.27 BG
                               $BTYPE
*--0002 2009.02.27 BG
                               $ADOAZON
                               $SORSZ
                               $W_/ZAK/MGCIM STRUCTURE /ZAK/MGCIM
                               $BSZNUM
                               $SZTEXT
                               $GJAHR
                               $MONAT
                               $TEST
*++0001 2008.11.14 BG
                               $DATUM
                               $SPOOL
*--0001 2008.11.14 BG
*++2008 #12.
                               $EVES
*--2008 #12.
                               .

  DATA  LI_DOCUMENT_OUTPUT_INFO TYPE SSFCRESPD OCCURS 0 WITH HEADER LINE.
  DATA  LI_JOB_OUTPUT_INFO TYPE SSFCRESCL OCCURS 0 WITH HEADER LINE.
  DATA  L_KKELT TYPE /ZAK/KKELT.
  DATA  L_STREET TYPE AD_STREET.
*++0001 2008.12.01 (BG)
  DATA  L_OUTPUT_OPTIONS TYPE SSFCOMPOP.
*--0001 2008.12.01 (BG)
  CONCATENATE $W_/ZAK/MGCIM-STREET $W_/ZAK/MGCIM-HOUSE
              INTO L_STREET SEPARATED BY SPACE.

* Hónap megnevezésének meghatározása
  CLEAR L_KKELT.
*++2008 #12.
  IF $EVES IS INITIAL.
*--2008 #12.
    SELECT SINGLE /ZAK/MONAT_TEXT INTO L_KKELT
                              FROM /ZAK/MONAT_TEXT
                             WHERE ZMONAT EQ $MONAT.
    IF SY-SUBRC EQ 0.
      CONCATENATE $GJAHR L_KKELT INTO L_KKELT SEPARATED BY SPACE.
    ELSE.
      CONCATENATE $GJAHR $MONAT INTO L_KKELT SEPARATED BY SPACE.
    ENDIF.
*++2008 #12.
  ELSE.
    MOVE $GJAHR TO L_KKELT.
  ENDIF.
*--2008 #12.

*++0001 2008.12.01 (BG)
* Háttérben kiviteli paraméterek beállítása
  IF NOT SY-BATCH IS INITIAL.
    L_OUTPUT_OPTIONS-TDDEST  = 'LOCL'.
    L_OUTPUT_OPTIONS-TDNEWID = $SPOOL.
  ENDIF.
*--0001 2008.12.01 (BG)


  CALL FUNCTION $FM_NAME
    EXPORTING
*     ARCHIVE_INDEX        =
*     ARCHIVE_INDEX_TAB    =
*     ARCHIVE_PARAMETERS   =
*     CONTROL_PARAMETERS   = P_CONTROL_PARAMETERS
*     MAIL_APPL_OBJ        =
*     MAIL_RECIPIENT       =
*     MAIL_SENDER          =
*++0001 2008.12.01 (BG)
      OUTPUT_OPTIONS       = L_OUTPUT_OPTIONS
*     USER_SETTINGS        = 'X'
*++2508 #13.
      USER_SETTINGS        = ' '
*--2508 #13.
*--0001 2008.12.01 (BG)
      BUKRS                = $BUKRS
*++0002 2009.02.27 BG
      BTYPE                = $BTYPE
*--0002 2009.02.27 BG
      SORSZAM              = $SORSZ
      CIMZETT_NAME         = $W_/ZAK/MGCIM-NAME
      CIMZETT_CITY         = $W_/ZAK/MGCIM-CITY1
      CIMZETT_STREET       = L_STREET
      CIMZETT_POSTCOD      = $W_/ZAK/MGCIM-POSTCOD
      BSZNUM               = $BSZNUM
      SZTEXT               = $SZTEXT
      KKELT                = L_KKELT
      GJAHR                = $GJAHR
*++0001 2008.11.14 BG
      DATUM                = $DATUM
*--0001 2008.11.14 BG
      TESZT                = $TEST
    IMPORTING
      DOCUMENT_OUTPUT_INFO = LI_DOCUMENT_OUTPUT_INFO
      JOB_OUTPUT_INFO      = LI_JOB_OUTPUT_INFO
*     JOB_OUTPUT_OPTIONS   =
    TABLES
      T_DATA               = $I_SMART_DATA
    EXCEPTIONS
      FORMATTING_ERROR     = 1
      INTERNAL_ERROR       = 2
      SEND_ERROR           = 3
      USER_CANCELED        = 4
      OTHERS               = 5.
  IF SY-SUBRC <> 0.
*   Hiba a & űrlap & adószám & sorszám kivitelénél!
    MESSAGE A265 WITH $FNAME $ADOAZON $SORSZ SY-SUBRC.
  ENDIF.

  REFRESH $I_SMART_DATA.

ENDFORM.                    " CALL_SMARTFORMS
