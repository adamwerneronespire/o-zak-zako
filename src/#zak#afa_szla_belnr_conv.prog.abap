*&---------------------------------------------------------------------*
*& Report  /ZAK/BUKRS_CORR
*&
*&---------------------------------------------------------------------*
*& The program fills the /ZAK/AFA_SZLA BELNR field with a leading 0
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_SZLA_BELNR_CONV MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/AFA_SZLA.



*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Constants           -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Ranges              -   (R_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Types               -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methods             -   (METH_xxx...)                           *
*      Object              -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*MACRO definition for range upload
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.


DATA I_/ZAK/AFA_SZLA TYPE STANDARD TABLE OF /ZAK/AFA_SZLA INITIAL SIZE 0
.
DATA W_/ZAK/AFA_SZLA TYPE /ZAK/AFA_SZLA.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
*SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
PARAMETERS P_SIZE TYPE I DEFAULT '100000' OBLIGATORY.
*SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Eligibility check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
  IF SY-SUBRC NE 0.
    MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Data processing
  PERFORM PROCESS_DATA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .

  SELECT * INTO TABLE I_/ZAK/AFA_SZLA
            PACKAGE SIZE P_SIZE
            FROM /ZAK/AFA_SZLA
           WHERE BSEG_GJAHR EQ '0000'.

    DELETE /ZAK/AFA_SZLA FROM TABLE I_/ZAK/AFA_SZLA.
    LOOP AT I_/ZAK/AFA_SZLA INTO W_/ZAK/AFA_SZLA.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = W_/ZAK/AFA_SZLA-BSEG_BELNR
        IMPORTING
          OUTPUT = W_/ZAK/AFA_SZLA-BSEG_BELNR.

      MODIFY I_/ZAK/AFA_SZLA FROM W_/ZAK/AFA_SZLA TRANSPORTING BSEG_BELNR.
    ENDLOOP.
    INSERT /ZAK/AFA_SZLA FROM TABLE I_/ZAK/AFA_SZLA.
  ENDSELECT.
  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE I216.
* Data changes saved!
  ENDIF.

ENDFORM.                    " PROCESS_DATA
