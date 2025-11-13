*&---------------------------------------------------------------------*
*& Report  /ZAK/ONYB_DEL_DATA
*&
*&---------------------------------------------------------------------*
*& Function description: Deleting data
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2009.03.30
*& Functional spec author: Róth Nándor
*& SAP module name    : ADO
*& Program type      : Report
*& SAP version       : 50
*&---------------------------------------------------------------------*

REPORT  /ZAK/ONYB_DEL_DATA MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& MODIFICATIONS (The OSS note number must be written at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER                     DESCRIPTION
*& ----   ----------   ----------    -----------------------------------
*&
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.



*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table        -   (I_xxx...)                              *
*      FORM parameter        -   ($xxxx...)                              *
*      Constant              -   (C_xxx...)                              *
*      Parameter variable    -   (P_xxx...)                              *
*      Selection option      -   (S_xxx...)                              *
*      Ranges                -   (R_xxx...)                              *
*      Global variables      -   (V_xxx...)                              *
*      Local variables       -   (L_xxx...)                              *
*      Work area             -   (W_xxx...)                              *
*      Type                  -   (T_xxx...)                              *
*      Macros                -   (M_xxx...)                              *
*      Field symbol          -   (FS_xxx...)                             *
*      Method                -   (METH_xxx...)                           *
*      Object                -   (O_xxx...)                              *
*      Class                 -   (CL_xxx...)                             *
*      Event                 -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*Macro definition for filling the range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.


RANGES R_BTYPE FOR /ZAK/ANALITIKA-BTYPE.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(75) TEXT-101.

  SELECTION-SCREEN END OF LINE.
*Company
  SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS.
*Declaration type
  SELECT-OPTIONS S_BTYPE FOR /ZAK/ANALITIKA-BTYPE.
*Year
  SELECT-OPTIONS S_GJAHR FOR /ZAK/ANALITIKA-GJAHR.
*Month
  SELECT-OPTIONS S_MONAT FOR /ZAK/ANALITIKA-MONAT.

SELECTION-SCREEN END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You are not authorized to run the program!
  ENDIF.
*--1765 #19.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Determining the BTYPE values:
  PERFORM GET_BTYPE.
  IF R_BTYPE[] IS INITIAL.
    MESSAGE E000 WITH 'Nem lehet releváns bevallás típust meghatározni'.
*   & & & &
  ENDIF.

* /ZAK/ZAK_BEVASZ and /ZAK/BEVALLI deletion:
  PERFORM PROGRESS_INDICATOR USING TEXT-P02
                                   0
                                   0.
  PERFORM DEK_/ZAK/BEVALLSZ.

* /ZAK/ANALITIKA deletion
  PERFORM PROGRESS_INDICATOR USING TEXT-P03
                                   0
                                   0.
  PERFORM DEL_/ZAK/ANALITIKA.

* /ZAK/BEVALLO deletion
  PERFORM PROGRESS_INDICATOR USING TEXT-P04
                                   0
                                   0.
  PERFORM DEL_/ZAK/BEVALLO.

  COMMIT WORK AND WAIT.

  MESSAGE I000 WITH 'Adatbázis törlés befejezve!'.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&      Form  get_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BTYPE .

*Only VAT BTYPE values are needed for those before 0865:
*++S4HANA#01.
*  SELECT * INTO W_/ZAK/BEVALL
  SELECT BTYPE INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALL
*--S4HANA#01.
             FROM /ZAK/BEVALL
            WHERE BUKRS IN S_BUKRS
              AND BTYPE IN S_BTYPE
              AND BTYPART EQ C_BTYPART_ONYB.
    IF W_/ZAK/BEVALL-BTYPE(2) < '08'.
      M_DEF R_BTYPE 'I' 'EQ' W_/ZAK/BEVALL-BTYPE SPACE.
    ENDIF.
  ENDSELECT.

ENDFORM.                    " get_btype
*&---------------------------------------------------------------------*
*&      Form  DEK_/ZAK/BEVALLSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEK_/ZAK/BEVALLSZ .

  DELETE FROM /ZAK/BEVALLI
        WHERE BUKRS IN S_BUKRS
          AND BTYPE IN R_BTYPE
          AND GJAHR IN S_GJAHR
          AND MONAT IN S_MONAT.

  DELETE FROM /ZAK/BEVALLSZ
        WHERE BUKRS IN S_BUKRS
          AND BTYPE IN R_BTYPE
          AND GJAHR IN S_GJAHR
          AND MONAT IN S_MONAT.


ENDFORM.                    " DEK_/ZAK/BEVALLSZ


*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM PROGRESS_INDICATOR USING  $TEXT
FORM PROGRESS_INDICATOR USING  $TEXT TYPE CLIKE
*--S4HANA#01.
                               $LINES
                               $ACT_LINE.
  DATA L_PERCENTAGE TYPE I.
  DATA L_DIVIDE TYPE P DECIMALS 2.

  CLEAR L_PERCENTAGE.

  IF NOT $LINES IS INITIAL AND NOT $ACT_LINE IS INITIAL.
    L_DIVIDE = $ACT_LINE / $LINES  * 100.
    L_PERCENTAGE = TRUNC( L_DIVIDE ).
  ENDIF.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = L_PERCENTAGE
      TEXT       = $TEXT.


ENDFORM.                    " PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  DEL_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_/ZAK/ANALITIKA .

  DELETE   FROM /ZAK/ANALITIKA
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT.

ENDFORM.                    " DEL_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  DEL_/ZAK/BEVALLO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_/ZAK/BEVALLO .

  DELETE   FROM /ZAK/BEVALLO
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN R_BTYPE
            AND GJAHR IN S_GJAHR
            AND MONAT IN S_MONAT.

ENDFORM.                    " DEL_/ZAK/BEVALLO
