*&---------------------------------------------------------------------*
*& Report  /ZAK/SET_STATUS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /ZAK/SET_STATUS MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: The program sets the status of the data provided
*  in the selection to 'Z'
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2008.07.03
*& Functional spec by: ________
*& SAP module name   : ADO
*& Program type      : Report
*& SAP version        : 50
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of modified lines)*
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*
*TABLES: /ZAK/ANALITIKA.

INCLUDE /ZAK/COMMON_STRUCT.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Constant            -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Ranges              -   (R_xxx...)                              *
*      Global variables    -   (V_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Type                -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Method              -   (METH_xxx...)                           *
*      Object              -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*Warning
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-101.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-102.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-103.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-B02.

PARAMETERS P_BUKRS LIKE /ZAK/BEVALLI-BUKRS OBLIGATORY MEMORY ID BUK.
PARAMETERS P_BTYPE LIKE /ZAK/BEVALLI-BTYPE OBLIGATORY.
PARAMETERS P_GJAHR LIKE /ZAK/BEVALLI-GJAHR OBLIGATORY.
PARAMETERS P_MONAT LIKE /ZAK/BEVALLI-MONAT OBLIGATORY.
PARAMETERS P_INDEX LIKE /ZAK/BEVALLI-ZINDEX OBLIGATORY.


PARAMETERS P_FLAG  LIKE /ZAK/BEVALLI-FLAG DEFAULT 'Z'
                                         MODIF ID DIS.

SELECTION-SCREEN: END OF BLOCK BL02.
*++1765 #19.
INITIALIZATION.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*  Setting screen attributes
  PERFORM SET_SCREEN_ATTRIBUTES.




START-OF-SELECTION.

  GET TIME.

  UPDATE /ZAK/BEVALLI SET FLAG  = P_FLAG
                         DATUM = SY-DATUM
                         UZEIT = SY-UZEIT
                         UNAME = SY-UNAME
               WHERE BUKRS  = P_BUKRS
                AND  BTYPE  = P_BTYPE
                AND  GJAHR  = P_GJAHR
                AND  MONAT  = P_MONAT
                AND  ZINDEX = P_INDEX.
  IF SY-SUBRC NE 0.
    MESSAGE I031.
*   The database does not contain a record to be processed!
    EXIT.
  ENDIF.

  UPDATE /ZAK/BEVALLSZ SET FLAG = P_FLAG
                         DATUM = SY-DATUM
                         UZEIT = SY-UZEIT
                         UNAME = SY-UNAME
                 WHERE BUKRS  = P_BUKRS
                AND  BTYPE  = P_BTYPE
                AND  GJAHR  = P_GJAHR
                AND  MONAT  = P_MONAT
                AND  ZINDEX = P_INDEX.

  COMMIT WORK AND WAIT.

  MESSAGE I216.
*   Data changes saved!


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
