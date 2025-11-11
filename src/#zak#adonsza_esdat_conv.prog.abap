*&---------------------------------------------------------------------*
*& Report  /ZAK/ADONSZA_ESDAT_CONV
*&
*&---------------------------------------------------------------------*
*& Function description: Populate the original due date (ZESDAT).
*&---------------------------------------------------------------------*
*& Author            : Balazs Gabor - FMC
*& Created on        : 2009.09.15
*& Functional spec by:
*& SAP module        : ADO
*& Program type      : Report
*& SAP version       : 50
*&---------------------------------------------------------------------*

REPORT  /ZAK/ADONSZA_ESDAT_CONV MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& CHANGES (write the OSS note number at the end of each modified line)*
*&
*& LOG#     DATE        CHANGED BY                 DESCRIPTION
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
*Macro definition for populating the range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(75) TEXT-101.

SELECTION-SCREEN END OF LINE.
*Company
SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS.
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
*   You are not authorized to run this program!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT * INTO TABLE I_/ZAK/ADONSZA
           FROM /ZAK/ADONSZA
          WHERE BUKRS IN S_BUKRS.

  LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA
                        WHERE ZESDAT IS INITIAL.
    MOVE W_/ZAK/ADONSZA-ESDAT TO W_/ZAK/ADONSZA-ZESDAT.
    MODIFY I_/ZAK/ADONSZA FROM W_/ZAK/ADONSZA TRANSPORTING ZESDAT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    MODIFY /ZAK/ADONSZA FROM TABLE I_/ZAK/ADONSZA.
    COMMIT WORK AND WAIT.
    MESSAGE I000 WITH 'Adatfeltöltés befejezve!'.
  ELSE.
    MESSAGE I000 WITH 'Nincs feltölthető rekord!'.
  ENDIF.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------
