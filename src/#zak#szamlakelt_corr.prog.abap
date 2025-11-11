*&---------------------------------------------------------------------*
*& Report  /ZAK/SZAMLAKELT_CORR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/SZAMLAKELT_CORR MESSAGE-ID /ZAK/ZAK.

**&---------------------------------------------------------------------*
**& TÁBLÁK                                                              *
**&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.

DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF  /ZAK/ANALITIKA.
DATA I_/ZAK/AFA_SZLA  TYPE STANDARD TABLE OF  /ZAK/AFA_SZLA.

DATA:
  LT_RET  TYPE TABLE OF BAPIRET2,
  LO_ALV  TYPE REF TO CL_SALV_TABLE,
  LO_COLS TYPE REF TO CL_SALV_COLUMNS,
  LO_FUNC TYPE REF TO CL_SALV_FUNCTIONS_LIST.

*
**&---------------------------------------------------------------------*
**& PROGRAM VÁLTOZÓK                                                    *
**      Belső tábla         -   (I_xxx...)                              *
**      FORM paraméter      -   ($xxxx...)                              *
**      Konstans            -   (C_xxx...)                              *
**      Paraméter változó   -   (P_xxx...)                              *
**      Szelekciós opció    -   (S_xxx...)                              *
**      Sorozatok (Range)   -   (R_xxx...)                              *
**      Globális változók   -   (V_xxx...)                              *
**      Lokális változók    -   (L_xxx...)                              *
**      Munkaterület        -   (W_xxx...)                              *
**      Típus               -   (T_xxx...)                              *
**      Makrók              -   (M_xxx...)                              *
**      Field-symbol        -   (FS_xxx...)                             *
**      Methodus            -   (METH_xxx...)                           *
**      Objektum            -   (O_xxx...)                              *
**      Osztály             -   (CL_xxx...)                             *
**      Esemény             -   (E_xxx...)                              *
**&---------------------------------------------------------------------*

**&---------------------------------------------------------------------*
** SELECTION-SCREEN
**&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.

PARAMETERS P_BUKRS TYPE BUKRS OBLIGATORY MEMORY ID BUK.
SELECT-OPTIONS S_PACK FOR /ZAK/ANALITIKA-PACK OBLIGATORY.
PARAMETER P_TEST AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK BL01.

**&---------------------------------------------------------------------*
** START-OF-SELECTION
**&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM SEL_DATA.

  PERFORM PROC_DATA.

  IF I_/ZAK/AFA_SZLA[] IS INITIAL.
    MESSAGE I141.
*   Nincs a feltételnek megfelelő analitika rekord!
  ENDIF.

  PERFORM PROD_RUN.

**&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*ALV
  CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = LO_ALV
                          CHANGING  T_TABLE = I_/ZAK/AFA_SZLA ).
  LO_COLS = LO_ALV->GET_COLUMNS( ).
  LO_COLS->SET_OPTIMIZE( ).
  LO_FUNC  = LO_ALV->GET_FUNCTIONS( ).
  LO_FUNC->SET_ALL( ABAP_TRUE ).
  LO_ALV->DISPLAY( ).



*&---------------------------------------------------------------------*
*&      Form  SEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEL_DATA .

  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND PACK  IN S_PACK.

  IF SY-SUBRC NE 0.
    MESSAGE E141.
*   Nincs a feltételnek megfelelő analitika rekord!
  ELSE.
    DELETE I_/ZAK/ANALITIKA WHERE ABEVAZ EQ 'DUMMY_R'.
  ENDIF.


ENDFORM.                    " SEL_DATA
*&---------------------------------------------------------------------*
*&      Form  PROC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROC_DATA .

*++1365 2013.01.22 Balázs Gábor (Ness)
  DATA LS_START TYPE /ZAK/START.
  DATA LI_RETURN TYPE STANDARD TABLE OF BAPIRET2.

  DATA LW_AFA_SZLA  TYPE /ZAK/AFA_SZLA.
  DATA LW_ANALITIKA TYPE /ZAK/ANALITIKA.
  DATA L_SZAMLAKELT TYPE /ZAK/SZAMLAKELT.


  SELECT SINGLE * INTO LS_START
                  FROM /ZAK/START
                 WHERE BUKRS EQ P_BUKRS.

  IF NOT LS_START-SELEXIT IS INITIAL.
    CALL FUNCTION LS_START-SELEXIT
      EXPORTING
        I_START     = LS_START
*++1465 #07.
        I_TEST      = 'X'
*--1465 #07.
      TABLES
        T_ANALITIKA = I_/ZAK/ANALITIKA
        T_AFA_SZLA  = I_/ZAK/AFA_SZLA
*++1665 #08.
        T_RETURN    = LI_RETURN.
*--1665 #08.
  ENDIF.


  LOOP AT I_/ZAK/AFA_SZLA INTO LW_AFA_SZLA.

    SELECT SINGLE SZAMLAKELT INTO L_SZAMLAKELT
                             FROM /ZAK/AFA_SZLA
                      WHERE BUKRS      = LW_AFA_SZLA-BUKRS
                        AND ADOAZON    = LW_AFA_SZLA-ADOAZON
                        AND PACK       = LW_AFA_SZLA-PACK
                        AND BSEG_GJAHR = LW_AFA_SZLA-BSEG_GJAHR
                        AND BSEG_BELNR = LW_AFA_SZLA-BSEG_BELNR
*                        AND BSEG_BUZEI = LW_AFA_SZLA-BSEG_BUZEI
                        AND SZAMLASZA  = LW_AFA_SZLA-SZAMLASZA.
    IF SY-SUBRC EQ 0 AND  L_SZAMLAKELT EQ  LW_AFA_SZLA-SZAMLAKELT.
      DELETE I_/ZAK/AFA_SZLA.
    ENDIF.
  ENDLOOP.

  DELETE I_/ZAK/ANALITIKA WHERE ABEVAZ NE 'DUMMY_R'.

  LOOP AT I_/ZAK/ANALITIKA INTO LW_ANALITIKA.

    SELECT SINGLE SZAMLAKELT INTO L_SZAMLAKELT
                             FROM /ZAK/ANALITIKA
                       WHERE BUKRS      = LW_ANALITIKA-BUKRS
                         AND BTYPE      = LW_ANALITIKA-BTYPE
                         AND GJAHR      = LW_ANALITIKA-GJAHR
                         AND MONAT      = LW_ANALITIKA-MONAT
                         AND ZINDEX     = LW_ANALITIKA-ZINDEX
                         AND ABEVAZ     = LW_ANALITIKA-ABEVAZ
                         AND ADOAZON    = LW_ANALITIKA-ADOAZON
                         AND BSZNUM     = LW_ANALITIKA-BSZNUM
                         AND PACK       = LW_ANALITIKA-PACK
*                         AND ITEM       = LW_ANALITIKA-ITEM
*                         AND LAPSZ      = LW_ANALITIKA-LAPSZ.
                         AND BSEG_GJAHR = LW_ANALITIKA-BSEG_GJAHR
                         AND BSEG_BELNR = LW_ANALITIKA-BSEG_BELNR
                         AND BSEG_BUZEI = LW_ANALITIKA-BSEG_BUZEI.

    IF SY-SUBRC EQ 0 AND  L_SZAMLAKELT EQ  LW_ANALITIKA-SZAMLAKELT.
      DELETE I_/ZAK/ANALITIKA.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " PROC_DATA
*&---------------------------------------------------------------------*
*&      Form  PROD_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROD_RUN .
  DATA LW_AFA_SZLA  TYPE /ZAK/AFA_SZLA.
  DATA LW_ANALITIKA TYPE /ZAK/ANALITIKA.
  DATA L_SZAMLAKELT TYPE /ZAK/SZAMLAKELT.



  CHECK P_TEST IS INITIAL.

  LOOP AT I_/ZAK/AFA_SZLA INTO LW_AFA_SZLA.
    UPDATE /ZAK/AFA_SZLA SET SZAMLAKELT = LW_AFA_SZLA-SZAMLAKELT
                      WHERE BUKRS      = LW_AFA_SZLA-BUKRS
                        AND ADOAZON    = LW_AFA_SZLA-ADOAZON
                        AND PACK       = LW_AFA_SZLA-PACK
                        AND BSEG_GJAHR = LW_AFA_SZLA-BSEG_GJAHR
                        AND BSEG_BELNR = LW_AFA_SZLA-BSEG_BELNR
*                        AND BSEG_BUZEI = LW_AFA_SZLA-BSEG_BUZEI
                        AND SZAMLASZA  = LW_AFA_SZLA-SZAMLASZA.
  ENDLOOP.

  LOOP AT I_/ZAK/ANALITIKA INTO LW_ANALITIKA.
    UPDATE /ZAK/ANALITIKA SET SZAMLAKELT = LW_ANALITIKA-SZAMLAKELT
                       WHERE BUKRS      = LW_ANALITIKA-BUKRS
                         AND BTYPE      = LW_ANALITIKA-BTYPE
                         AND GJAHR      = LW_ANALITIKA-GJAHR
                         AND MONAT      = LW_ANALITIKA-MONAT
                         AND ZINDEX     = LW_ANALITIKA-ZINDEX
                         AND ABEVAZ     = LW_ANALITIKA-ABEVAZ
                         AND ADOAZON    = LW_ANALITIKA-ADOAZON
                         AND BSZNUM     = LW_ANALITIKA-BSZNUM
                         AND PACK       = LW_ANALITIKA-PACK
*                         AND ITEM       = LW_ANALITIKA-ITEM
                         AND SZAMLASZA  = LW_ANALITIKA-SZAMLASZA
                         AND SZAMLASZ   = LW_ANALITIKA-SZAMLASZ.
  ENDLOOP.
  IF NOT I_/ZAK/AFA_SZLA[] IS INITIAL.
    COMMIT WORK AND WAIT.
    MESSAGE I216.
*   Adatmódosítások elmentve!
  ENDIF.

ENDFORM.                    " PROD_RUN
