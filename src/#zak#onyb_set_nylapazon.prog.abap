*&---------------------------------------------------------------------*
*& Report  /ZAK/ONYB_SET_NYLAPAZON
*&
*&---------------------------------------------------------------------*
*&Program: The program fills the sheet identifier for the declaration type specified on the selection screen
*&         by setting its sheet identifier to 02.
*&---------------------------------------------------------------------*

REPORT  /ZAK/ONYB_SET_NYLAPAZON MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table        -   (I_xxx...)                              *
*      FORM parameter        -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Parameter variable    -   (P_xxx...)                              *
*      Selection option      -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Global variables      -   (V_xxx...)                              *
*      Local variables       -   (L_xxx...)                              *
*      Work area             -   (W_xxx...)                              *
*      Type                  -   (T_xxx...)                              *
*      Macros                -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class                 -   (CL_xxx...)                             *
*      Event                 -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
PARAMETERS:  P_BTYPE LIKE /ZAK/BEVALLB-BTYPE
                                      DEFAULT '0761' OBLIGATORY
                                      MODIF ID DIS.

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
*   You are not authorized to run the program!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* Setting screen attributes
  PERFORM SET_SCREEN_ATTRIBUTES.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.


  UPDATE /ZAK/ANALITIKA
         SET NYLAPAZON = '02'
       WHERE BTYPE = P_BTYPE.
  COMMIT WORK AND WAIT.

MESSAGE I007.
*   Table modifications completed!



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
*     SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
