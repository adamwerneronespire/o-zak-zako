*&---------------------------------------------------------------------*
*&  Include           /ZAK/ONJF01
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
*&---------------------------------------------------------------------*
*&      Form  GET_BTYPART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BTYPE  text
*      <--P_G_BTYPART  text
*----------------------------------------------------------------------*
FORM GET_BTYPART  USING    $BUKRS
                           $BTYPE
                  CHANGING $BTYPART.

  CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
    EXPORTING
      I_BUKRS       = $BUKRS
      I_BTYPE       = $BTYPE
    IMPORTING
      E_BTYPART     = $BTYPART
    EXCEPTIONS
      ERROR_IMP_PAR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF $BTYPART IS INITIAL.
    MESSAGE E269.
*   Nem határozható meg a bevallás fajta!
  ENDIF.

ENDFORM.                    " GET_BTYPART
*&---------------------------------------------------------------------*
*&      Form  get_t001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
FORM GET_T001  USING    $BUKRS.

  CALL FUNCTION 'K_READ_T001'
    EXPORTING
      I_BUKRS   = $BUKRS
    IMPORTING
      E_T001    = T001
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                                                    " get_t001
*&---------------------------------------------------------------------*
*&      Form  PREVIEW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONJALV  text
*      -->P_P_FNAME  text
*      -->P_P_BUKRS  text
*      -->P_P_TEST  text
*----------------------------------------------------------------------*
FORM PREVIEW_DATA  TABLES   $I_ONJALV LIKE I_ONJALV
                   USING    $FNAME
                            $BUKRS
                            $TEST.

  DATA: LT_ROWS          TYPE LVC_T_ROID WITH HEADER LINE,
        LS_ROWS          TYPE LVC_S_ROID.

  DATA  L_FM_NAME TYPE RS38L_FNAM.
  DATA  LW_ONJALV LIKE W_ONJALV.
  DATA  L_MESSAGE.
  DATA  L_OSSZESEN TYPE /ZAK/DMBTR.

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
    READ TABLE $I_ONJALV    INTO LW_ONJALV
                                 INDEX LS_ROWS-ROW_ID.
    IF LW_ONJALV-/ZAK/TEXT IS INITIAL.
      IF L_MESSAGE IS INITIAL.
        MESSAGE I275.
        MOVE 'X' TO L_MESSAGE.
      ENDIF.
*     Kérem adjon meg a tételekhez szöveg hozzárendelést!
      CONTINUE.
    ENDIF.

*   Adatok feldolgozása
    LOOP AT $I_ONJALV INTO W_ONJALV WHERE BUKRS  EQ LW_ONJALV-BUKRS
                                      AND BTYPE  EQ LW_ONJALV-BTYPE
                                      AND GJAHR  EQ LW_ONJALV-GJAHR
                                      AND MONAT  EQ LW_ONJALV-MONAT
                                      AND ZINDEX EQ LW_ONJALV-ZINDEX.
      AT FIRST.
        CLEAR:   W_ONJSMART_DATA, L_OSSZESEN.
        REFRESH: I_TEXT, I_ONELL_DATA.
      ENDAT.
*     Kitöröljük a kijelölésből
      DELETE LT_ROWS WHERE ROW_ID = SY-TABIX.
*     SMARTFORMS adatok meghetározása
      PERFORM GET_SMART_DATA TABLES I_TEXT
                                    I_ONELL_DATA
                             USING  W_ONJALV
                                    W_ONJSMART_DATA
                                    T001
                                    $TEST
                                    L_OSSZESEN
                                    SY-UNAME.
    ENDLOOP.
    IF NOT L_OSSZESEN IS INITIAL.
      WRITE L_OSSZESEN TO W_ONJSMART_DATA-OSSZESEN
                                     CURRENCY LW_ONJALV-WAERS.
    ELSE.
      W_ONJSMART_DATA-OSSZESEN = 0.
    ENDIF.
    CONDENSE W_ONJSMART_DATA-OSSZESEN.

*   Űrlap meghívása
    PERFORM CALL_SMARTFORMS TABLES I_TEXT
                                   I_ONELL_DATA
                            USING  L_FM_NAME
                                   W_ONJSMART_DATA
                                   $TEST.
  ENDLOOP.


ENDFORM.                    " PREVIEW_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SMART_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TEXT  text
*      -->P_I_ONELL_DATA  text
*      -->P_W_ONJALV  text
*      -->P_W_ONJSMART_DATA  text
*      -->P_T001  text
*      -->P_$TEST  text
*----------------------------------------------------------------------*
FORM GET_SMART_DATA  TABLES   $I_TEXT LIKE I_TEXT
                              $I_ONELL_DATA LIKE I_ONELL_DATA
                     USING    $W_ONJALV  STRUCTURE /ZAK/ONJALV
                              $W_ONJSMART_DATA STRUCTURE
                                               /ZAK/ONJSMARTDAT
                              $T001  STRUCTURE T001
                              $TEST
                              $OSSZESEN
                              $UNAME.

  DATA LI_USER_TAB LIKE V_USEREXST OCCURS 0 WITH HEADER LINE.
  DATA LI_USER_NAME LIKE V_USERNAME OCCURS 0 WITH HEADER LINE.


* Szöveg meghetározása
  IF $I_TEXT[] IS INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                        = SY-MANDT
        ID                            = '/ZAK/ZAKO'
        LANGUAGE                      = SY-LANGU
        NAME                          = $W_ONJALV-/ZAK/TEXT
        OBJECT                        = 'TEXT'
*       ARCHIVE_HANDLE                = 0
*       LOCAL_CAT                     = ' '
*     IMPORTING
*       HEADER                        =
      TABLES
        LINES                         = $I_TEXT
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

* Adatok feltöltése
  IF $W_ONJALV-ADONEM NE C_ONELL.
    CLEAR W_ONELL_DATA.

    MOVE $W_ONJALV-ADONEM TO W_ONELL_DATA-ADONEM.
* Adónem szöveg
    SELECT SINGLE ADONEM_TXT INTO W_ONELL_DATA-ADONEM_TXT
                             FROM /ZAK/ADONEMT
                            WHERE LANGU  EQ SY-LANGU
                              AND BUKRS  EQ $W_ONJALV-BUKRS
                              AND ADONEM EQ $W_ONJALV-ADONEM.

* Összeg
    WRITE $W_ONJALV-OSSZEG TO W_ONELL_DATA-OSSZEG
                           CURRENCY $W_ONJALV-WAERS.
    CONDENSE W_ONELL_DATA-OSSZEG.

* Pénznem
    SELECT SINGLE KTEXT INTO W_ONELL_DATA-WAERS
                        FROM TCURT
                       WHERE SPRAS EQ SY-LANGU
                         AND WAERS EQ $W_ONJALV-WAERS.

* Esedékesség
    WRITE $W_ONJALV-ESDAT TO W_ONELL_DATA-ESDAT.
* Önrevízió
    WRITE $W_ONJALV-ONDAT TO W_ONELL_DATA-ONDAT.
    APPEND W_ONELL_DATA TO $I_ONELL_DATA.
    ADD $W_ONJALV-OSSZEG TO $OSSZESEN.
* Pótlék töltése
  ELSE.
    IF NOT $W_ONJALV-OSSZEG IS INITIAL.
      WRITE $W_ONJALV-OSSZEG TO $W_ONJSMART_DATA-POTLEK
                            CURRENCY $W_ONJALV-WAERS.
    ELSE.
      $W_ONJSMART_DATA-POTLEK = 0.
    ENDIF.
    CONDENSE $W_ONJSMART_DATA-POTLEK.
  ENDIF.

* Egyéb mezők töltése
  MOVE $TEST TO $W_ONJSMART_DATA-TESZT.
*++BG 2009.07.16
* Vállalat
  MOVE $W_ONJALV-BUKRS TO $W_ONJSMART_DATA-BUKRS.
*--BG 2009.07.16

* Azonosító
  IF $W_ONJSMART_DATA-AZONOSITO IS INITIAL.
    CONCATENATE $W_ONJALV-BUKRS
                $W_ONJALV-BTYPE
                $W_ONJALV-GJAHR
                $W_ONJALV-MONAT
                $W_ONJALV-ZINDEX INTO $W_ONJSMART_DATA-AZONOSITO
                                 SEPARATED BY '/'.
  ENDIF.

* Készült
  IF $W_ONJSMART_DATA-KESZULT IS INITIAL.
    MOVE $W_ONJALV-KESZULT TO $W_ONJSMART_DATA-KESZULT.
  ENDIF.

* IDŐSZAK
  IF $W_ONJSMART_DATA-IDOSZAK IS INITIAL.
    CONCATENATE $W_ONJALV-GJAHR
                $W_ONJALV-MONAT INTO $W_ONJSMART_DATA-IDOSZAK
                                SEPARATED BY '.'.
  ENDIF.

* Vállalat megnevezése
  IF $W_ONJSMART_DATA-BUTXT IS INITIAL.
    MOVE $T001-BUTXT TO $W_ONJSMART_DATA-BUTXT.
  ENDIF.

* Felhasználó neve
  IF $W_ONJSMART_DATA-FELHASZN IS INITIAL.
    MOVE SY-MANDT TO LI_USER_TAB-MANDT.
    MOVE $UNAME   TO LI_USER_TAB-BNAME.
    APPEND LI_USER_TAB.
    CALL FUNCTION 'RH_USER_NAME_READ'
      EXPORTING
*       BUFFER_STORE        = 'X'
        READ_DB             = 'X'
      TABLES
        USER_TAB            = LI_USER_TAB
        USER_NAME           = LI_USER_NAME
     EXCEPTIONS
       NOTHING_FOUND       = 1
       OTHERS              = 2
              .
    IF SY-SUBRC EQ 0.
      READ TABLE LI_USER_NAME INDEX 1.
      MOVE LI_USER_NAME-NAME_TEXT TO $W_ONJSMART_DATA-FELHASZN.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_SMART_DATA
*&---------------------------------------------------------------------*
*&      Form  CALL_SMARTFORMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TEXT  text
*      -->P_I_ONELL_DATA  text
*      -->P_L_FM_NAME  text
*      -->P_W_ONJSMART_DATA  text
*----------------------------------------------------------------------*
FORM CALL_SMARTFORMS  TABLES   $I_TEXT LIKE I_TEXT
                               $I_ONELL_DATA LIKE I_ONELL_DATA
                      USING    $FNAME
                               $W_ONJSMART_DATA STRUCTURE
                                                /ZAK/ONJSMARTDAT
                               $TEST.


  DATA  LI_DOCUMENT_OUTPUT_INFO TYPE SSFCRESPD OCCURS 0
                                WITH HEADER LINE.
  DATA  LI_JOB_OUTPUT_INFO TYPE SSFCRESCL OCCURS 0 WITH HEADER LINE.


  CALL FUNCTION $FNAME
   EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
    USER_SETTINGS              = 'X'
*++BG 2009.07.16
    BUKRS                      = $W_ONJSMART_DATA-BUKRS
*--BG 2009.07.16
    TESZT                      = $W_ONJSMART_DATA-TESZT
    AZONOSITO                  = $W_ONJSMART_DATA-AZONOSITO
    KESZULT                    = $W_ONJSMART_DATA-KESZULT
    IDOSZAK                    = $W_ONJSMART_DATA-IDOSZAK
    BUTXT                      = $W_ONJSMART_DATA-BUTXT
    OSSZESEN                   = $W_ONJSMART_DATA-OSSZESEN
*   LINE                       =
    POTLEK                     = $W_ONJSMART_DATA-POTLEK
    FELHASZN                   = $W_ONJSMART_DATA-FELHASZN
  IMPORTING
   DOCUMENT_OUTPUT_INFO       = LI_DOCUMENT_OUTPUT_INFO
   JOB_OUTPUT_INFO            = LI_JOB_OUTPUT_INFO
*  JOB_OUTPUT_OPTIONS         =
  TABLES
   T_TEXT                     = $I_TEXT
   T_ONELL_DATA               = $I_ONELL_DATA
  EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
            .
  IF SY-SUBRC <> 0.
    IF $TEST IS INITIAL.
*   Hiba a & űrlap & azonosító kivitelénél!
      MESSAGE A276 WITH $FNAME $W_ONJSMART_DATA-AZONOSITO.
    ELSE.
*   Hiba a & űrlap & azonosító kivitelénél!
      MESSAGE E276 WITH $FNAME $W_ONJSMART_DATA-AZONOSITO.
    ENDIF.
  ENDIF.

  REFRESH $I_ONELL_DATA.

ENDFORM.                    " CALL_SMARTFORMS
