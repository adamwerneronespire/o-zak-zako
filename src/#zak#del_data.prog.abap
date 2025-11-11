*&---------------------------------------------------------------------*
*& Report  /ZAK/DEL_DATA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/DEL_DATA MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: The program deletes the data specified on the selection screen
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2007.09.25
*& Functional spec by: ________
*& SAP modul neve    : ADO
*& Program  type     : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
TABLES /ZAK/BEVALLI.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                  *
*      Internal table       -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Parameter variable   -   (P_xxx...)                              *
*      Selection option     -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Global variables     -   (V_xxx...)                              *
*      Local variables      -   (L_xxx...)                              *
*      Work area            -   (W_xxx...)                              *
*      Type                 -   (T_xxx...)                              *
*      Macros               -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class                -   (CL_xxx...)                             *
*      Event                -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA V_PACK TYPE /ZAK/PACK.

RANGES R_PACK FOR /ZAK/BEVALLSZ-PACK.

*Delete data
DEFINE M_DELETE.
  PERFORM PROCESS_IND USING &2.
  DELETE FROM &1 WHERE BUKRS EQ P_BUKRS
                   AND BTYPE EQ P_BTYPE
                   AND GJAHR EQ P_GJAHR
                   AND MONAT EQ P_MONAT
                   AND ZINDEX IN S_INDEX.
  COMMIT WORK AND WAIT.
END-OF-DEFINITION.

*Macro definition for filling a range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
*Warning
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(71) TEXT-101.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(71) TEXT-102.
SELECTION-SCREEN END OF LINE.

PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLI-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.

PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLI-BTYPE
                          OBLIGATORY.

PARAMETERS: P_GJAHR  LIKE /ZAK/BEVALLI-GJAHR OBLIGATORY.

PARAMETERS: P_MONAT  LIKE /ZAK/BEVALLI-MONAT OBLIGATORY.

SELECT-OPTIONS S_INDEX FOR /ZAK/BEVALLI-ZINDEX.

SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
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


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF SY-SYSID EQ 'MTP'.
    MESSAGE I235.
*   Warning! You are about to delete data in the productive system!
  ENDIF.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* /ZAK/ANALITIKA
  M_DELETE /ZAK/ANALITIKA '/ZAK/ANALITIKA törlése'.
* /ZAK/BEVALLO
  M_DELETE /ZAK/BEVALLO   '/ZAK/BEVALLO törlése'.
* Package identifiers collection
  SELECT PACK INTO V_PACK
              FROM /ZAK/BEVALLSZ
                 WHERE BUKRS EQ P_BUKRS
                   AND BTYPE EQ P_BTYPE
                   AND GJAHR EQ P_GJAHR
                   AND MONAT EQ P_MONAT
                   AND ZINDEX IN S_INDEX
                   AND PACK  NE SPACE.
    M_DEF R_PACK 'I' 'EQ' V_PACK SPACE.
  ENDSELECT.
* /ZAK/BEVALLSZ
  M_DELETE /ZAK/BEVALLSZ  '/ZAK/BEVALLSZ törlése'.
* /ZAK/BEVALLI
  M_DELETE /ZAK/BEVALLI   '/ZAK/BEVALLI törlése'.
* /ZAK/BEVALLP update
  PERFORM PROCESS_IND USING '/ZAK/BEVALLP módosítás'.

  IF NOT R_PACK[] IS INITIAL.
    UPDATE /ZAK/BEVALLP
           SET XLOEK = 'X'
               DATUM = SY-DATUM
               UZEIT = SY-UZEIT
               UNAME = SY-UNAME
         WHERE BUKRS = P_BUKRS
           AND PACK  IN R_PACK.
  ENDIF.

  MESSAGE I008.
* Table deletions completed!


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  process_ind
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_IND USING $TEXT.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*      PERCENTAGE       = 0
      TEXT             = $TEXT.

ENDFORM.                    " process_ind
