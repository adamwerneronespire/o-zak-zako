*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_IDOSZ_MOVE
*&
*&---------------------------------------------------------------------*
*& Beolvadt vállalatok előre mutató időszakban létrehozott feltöltések
*& átmozgatása
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_IDOSZ_MOVE MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.

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

DATA I_/ZAK/ANALITIKA LIKE /ZAK/ANALITIKA OCCURS 0 WITH HEADER LINE.
DATA I_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.

DATA I_/ZAK/BEVALLP   LIKE /ZAK/BEVALLP OCCURS 0 WITH HEADER LINE.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
PARAMETERS P_BTYPAR LIKE /ZAK/BEVALL-BTYPART DEFAULT 'AFA' MODIF ID DIS.
PARAMETERS P_BUKRS LIKE /ZAK/BEVALL-BUKRS OBLIGATORY.
PARAMETERS P_BTYPE LIKE /ZAK/BEVALL-BTYPE OBLIGATORY.
PARAMETERS P_GJAHR LIKE /ZAK/ANALITIKA-GJAHR OBLIGATORY.
PARAMETERS P_MONAT LIKE /ZAK/ANALITIKA-MONAT OBLIGATORY.
PARAMETERS P_ZINDEX LIKE /ZAK/ANALITIKA-ZINDEX OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-B02.
PARAMETERS P_TBUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL02.

SELECTION-SCREEN: BEGIN OF BLOCK BL03 WITH FRAME TITLE TEXT-B03.
PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.
PARAMETERS P_DEL  AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK BL03.

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
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* Képernyő attribútomok beállítása
  PERFORM SET_SCREEN_ATTRIBUTES.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
* Vállalat kódok ellenőrzése
  PERFORM CHECK_BUKRS.
* BTYPE ellenőrzése
  PERFORM CHECK_BTYPE.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Adatok meghatározása
  PERFORM GET_DATA.
  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I141.
*   Nincs a feltételnek megfelelő analitika rekord!
    EXIT.
  ENDIF.

* UPDATE
  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS           = P_TBUKRS
      I_BTYPE           = P_BTYPE
      I_BTYPART         = P_BTYPAR
      I_BSZNUM          = '001'
*     I_PACK            =
      I_GEN             = 'X'
      I_TEST            = P_TEST
*     I_FILE            =
    TABLES
      I_ANALITIKA       = I_/ZAK/ANALITIKA
      E_RETURN          = I_RETURN.

*  Üzenetek kezelése
  IF NOT I_RETURN[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = I_RETURN.
  ENDIF .

  IF P_TEST IS INITIAL.
    IF NOT P_DEL IS INITIAL.
*     Adatok törlése
      DELETE FROM /ZAK/ANALITIKA WHERE BUKRS EQ P_BUKRS
                                  AND BTYPE EQ P_BTYPE
                                  AND GJAHR EQ P_GJAHR
                                  AND MONAT EQ P_MONAT
                                  AND ZINDEX EQ P_ZINDEX.
      DELETE FROM /ZAK/BEVALLI  WHERE  BUKRS EQ P_BUKRS
                                 AND  BTYPE EQ P_BTYPE
                                 AND  GJAHR EQ P_GJAHR
                                 AND  MONAT EQ P_MONAT
                                 AND  ZINDEX EQ P_ZINDEX.
      DELETE FROM /ZAK/BEVALLSZ WHERE  BUKRS EQ P_BUKRS
                                 AND  BTYPE EQ P_BTYPE
                                 AND  GJAHR EQ P_GJAHR
                                 AND  MONAT EQ P_MONAT
                                 AND  ZINDEX EQ P_ZINDEX.
      LOOP AT I_/ZAK/BEVALLP.
        UPDATE /ZAK/BEVALLP SET XLOEK = 'X'
                    WHERE  BUKRS EQ I_/ZAK/BEVALLP-BUKRS
                      AND  PACK  EQ I_/ZAK/BEVALLP-PACK.
      ENDLOOP.
    ENDIF.

    MESSAGE I203.
* Konvertált tételek adatbázisban módosítva!
  ENDIF.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM GRID_DISPLAY.




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
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BUKRS .

  DATA L_DATUM LIKE SY-DATUM.

  CONCATENATE P_GJAHR P_MONAT '01' INTO L_DATUM.

  SELECT SINGLE COUNT( * )
           FROM /ZAK/BUKRSN
          WHERE FI_BUKRS EQ P_TBUKRS
            AND AD_BUKRS EQ P_BUKRS
            AND FDATE    <= L_DATUM.
  IF SY-SUBRC NE 0.
    MESSAGE E286.
*   A vállalatok ebben az időszakban nem léteznek a forgató táblában!
  ENDIF.

ENDFORM.                    " CHECK_BUKRS
*&---------------------------------------------------------------------*
*&      Form  check_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BTYPE .

  SELECT SINGLE COUNT( * )
         FROM /ZAK/BEVALL
        WHERE BUKRS EQ P_BUKRS
          AND BTYPE EQ P_BTYPE
          AND BTYPART EQ P_BTYPAR.
  IF SY-SUBRC NE 0.
    MESSAGE E124 WITH P_BUKRS P_BTYPE P_BTYPAR.
*   & vállalatban & bevallás típus & bevallás fajta nem létezik!
  ENDIF.

ENDFORM.                    " check_btype
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX EQ P_ZINDEX.

  LOOP AT I_/ZAK/ANALITIKA.
    I_/ZAK/ANALITIKA-BUKRS = P_TBUKRS.
    MODIFY I_/ZAK/ANALITIKA TRANSPORTING BUKRS.
    CLEAR I_/ZAK/BEVALLP.
    I_/ZAK/BEVALLP-BUKRS = P_BUKRS.
    I_/ZAK/BEVALLP-PACK  = I_/ZAK/ANALITIKA-PACK.
    COLLECT I_/ZAK/BEVALLP.
  ENDLOOP.


ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  GRID_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GRID_DISPLAY .
  DATA LI_FIELDCAT   TYPE LVC_T_FCAT.
  DATA L_LAYOUT      TYPE LVC_S_LAYO.
  DATA L_VARIANT     TYPE DISVARIANT.


* Mezőkatalógus összeállítása
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LI_FIELDCAT.

  L_LAYOUT-CWIDTH_OPT = 'X'.
  L_LAYOUT-SEL_MODE = 'A'.

  CLEAR L_VARIANT.
  L_VARIANT-REPORT = SY-REPID.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
   EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                =
*   I_BUFFER_ACTIVE                   =
   I_CALLBACK_PROGRAM                = '/ZAK/AFA_ABEV_CORR'
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = 'TOP_OF_PAGE'
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  = ' '
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT_LVC                     = L_LAYOUT
   IT_FIELDCAT_LVC                   = LI_FIELDCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS_LVC             =
*   IT_SORT_LVC                       =
*   IT_FILTER_LVC                     =
*   IT_HYPERLINK                      =
*   IS_SEL_HIDE                       =
   I_DEFAULT                         = 'X'
   I_SAVE                            = 'A'
   IS_VARIANT                        = L_VARIANT
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT_LVC                      =
*   IS_REPREP_ID_LVC                  =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 =
*   I_HTML_HEIGHT_END                 =
*   IT_EXCEPT_QINFO_LVC               =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
 TABLES
   T_OUTTAB                        = I_/ZAK/ANALITIKA
EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " GRID_DISPLAY
