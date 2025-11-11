*&---------------------------------------------------------------------*
*& Report  /ZAK/ADOAZON_CORR
*&
*&---------------------------------------------------------------------*
*& SZJA upload tax ID adjustment
*&---------------------------------------------------------------------*
REPORT  /ZAK/ADOAZON_CORR MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA, /ZAK/BEVALLO.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Constants          -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Ranges            -   (R_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Types               -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*Macro definition for loading ranges
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

DATA I_/ZAK/ANALITIKA_DEL TYPE STANDARD TABLE OF
                         /ZAK/ANALITIKA INITIAL SIZE 0.
DATA I_/ZAK/ANALITIKA_NEW TYPE STANDARD TABLE OF
                         /ZAK/ANALITIKA INITIAL SIZE 0.
DATA I_/ZAK/BEVALLO_DEL TYPE STANDARD TABLE OF
                         /ZAK/BEVALLO INITIAL SIZE 0.
DATA I_/ZAK/BEVALLO_NEW TYPE STANDARD TABLE OF
                         /ZAK/BEVALLO INITIAL SIZE 0.


DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
DATA W_/ZAK/BEVALLO   TYPE /ZAK/BEVALLO.
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS MEMORY ID BUK OBLIGATORY.
PARAMETERS P_BTYPE LIKE /ZAK/ANALITIKA-BTYPE OBLIGATORY.
PARAMETERS P_GJAHR LIKE /ZAK/ANALITIKA-GJAHR DEFAULT SY-DATUM(4)
                                            OBLIGATORY.
*PARAMETERS p_monat LIKE /zak/analitika-monat OBLIGATORY.
SELECT-OPTIONS S_MONAT FOR /ZAK/ANALITIKA-MONAT NO-EXTENSION.
SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-B02.
PARAMETERS P_ADO_O LIKE /ZAK/ANALITIKA-ADOAZON OBLIGATORY.
PARAMETERS P_ADO_N LIKE /ZAK/ANALITIKA-ADOAZON OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL02.



*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++2365 #02.
* Authorization check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
                   ID 'TCD'  FIELD '/ZAK/ADOAZON_CORR'.
   IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
     MESSAGE E152(/ZAK/ZAK).
*   You are not authorized to run the program!
   ENDIF.
*--2365 #02.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*  Set screen attributes
  PERFORM SET_SCREEN_ATTRIBUTES.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Process data
  PERFORM PROCESS_DATA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
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
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA.

*  DATA L_TABNAME(20).
*
*
  SELECT * INTO TABLE I_/ZAK/ANALITIKA_DEL
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
*            AND MONAT EQ P_MONAT
            AND MONAT IN S_MONAT
            AND ADOAZON EQ P_ADO_O.
  IF SY-SUBRC EQ 0.
    SELECT * INTO TABLE I_/ZAK/BEVALLO_DEL
             FROM /ZAK/BEVALLO
            WHERE BUKRS EQ P_BUKRS
              AND BTYPE EQ P_BTYPE
              AND GJAHR EQ P_GJAHR
*              AND MONAT EQ P_MONAT
              AND MONAT IN S_MONAT
              AND ADOAZON EQ P_ADO_O.
    LOOP AT I_/ZAK/ANALITIKA_DEL INTO W_/ZAK/ANALITIKA.
      W_/ZAK/ANALITIKA-ADOAZON = P_ADO_N.
*     Also replace the value of FILED_C if it contains the tax ID!
      IF W_/ZAK/ANALITIKA-FIELD_C = P_ADO_O.
        W_/ZAK/ANALITIKA-FIELD_C = P_ADO_N.
      ENDIF.
      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
    ENDLOOP.

    LOOP AT I_/ZAK/BEVALLO_DEL INTO W_/ZAK/BEVALLO.
      W_/ZAK/BEVALLO-ADOAZON = P_ADO_N.
*     Also replace the value of FILED_C if it contains the tax ID!
      IF W_/ZAK/BEVALLO-FIELD_C = P_ADO_O.
        W_/ZAK/BEVALLO-FIELD_C = P_ADO_N.
      ENDIF.
      APPEND W_/ZAK/BEVALLO TO I_/ZAK/BEVALLO_NEW.
    ENDLOOP.
    INSERT /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_NEW.
    DELETE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_DEL.
    INSERT /ZAK/BEVALLO   FROM TABLE I_/ZAK/BEVALLO_NEW.
    DELETE /ZAK/BEVALLO   FROM TABLE I_/ZAK/BEVALLO_DEL.
    COMMIT WORK AND WAIT.
    MESSAGE I216.
*   Data changes have been saved!
  ELSE.
    MESSAGE I141.
*   No analytics record matches the condition!
  ENDIF.

ENDFORM.                    " PROCESS_DATA
