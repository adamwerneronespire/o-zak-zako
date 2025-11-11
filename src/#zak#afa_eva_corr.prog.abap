*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_EVA_CORR
*&
*&---------------------------------------------------------------------*
*& /ZAK/ANALITIKA correction. MAIN_EXIT did not set the EVA base and tax
*& ABEV identifiers for return 1065, so those records were created with
*& an empty ABEV ID. This program collects the selection-matching rows
*& with empty ABEV IDs and, based on FIELD_N (LWBAS, LWSTE), decides
*& whether the row holds a base or tax amount (7995, 7996). In productive
*& execution it deletes the records with empty IDs and recreates the
*& same rows with populated ABEV IDs in the original periods.
*&---------------------------------------------------------------------*

REPORT  /ZAK/AFA_EVA_CORR MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Author            : Balazs Gabor - FMC
*& Created on        : 2006.12.13
*& Functional spec by: ________
*& SAP module        : ADO
*& Program type      : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (write the OSS note number at the end of each modified line)*
*&
*& LOG#     DATE        CHANGED BY           DESCRIPTION      TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx
*&                                   xxxxxxx xxxxxxx xxxxxxx
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.

TYPE-POOLS: SLIS.

*Common ALV routines
INCLUDE /ZAK/ALV_LIST_FORMS.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
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
DATA I_/ZAK/ANALITIKA_DEL LIKE /ZAK/ANALITIKA OCCURS 0.
DATA I_/ZAK/ANALITIKA_NEW LIKE /ZAK/ANALITIKA OCCURS 0.


*Macro definition for populating the range
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
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS.
SELECT-OPTIONS S_BTYPE FOR /ZAK/ANALITIKA-BTYPE.
SELECT-OPTIONS S_GJAHR FOR /ZAK/ANALITIKA-GJAHR.
PARAMETERS P_TESZT AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK BL01.
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
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Analytics selection
  PERFORM GET_ANALITIKA.
  IF I_/ZAK/ANALITIKA_DEL[] IS INITIAL.
    MESSAGE I201.
*   No records found that need conversion! (/ZAK/ANALITIKA)
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* Processing
  PERFORM PROCESS_DATA.

  PERFORM ALV_LIST  TABLES  I_/ZAK/ANALITIKA_NEW
                     USING  'I_/ZAK/ANALITIKA_NEW'.


*&---------------------------------------------------------------------*
*&      Form  GET_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ANALITIKA .

  SELECT * INTO TABLE I_/ZAK/ANALITIKA_DEL
           FROM /ZAK/ANALITIKA
          WHERE BUKRS IN S_BUKRS
            AND BTYPE IN S_BTYPE
            AND GJAHR IN S_GJAHR
            and ABEVAZ eq ''.

ENDFORM.                    " GET_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .

  LOOP AT I_/ZAK/ANALITIKA_DEL INTO W_/ZAK/ANALITIKA.
*   Base
    IF W_/ZAK/ANALITIKA-FIELD_N EQ W_/ZAK/ANALITIKA-LWBAS.
      W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_7995.
      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
*   Tax
    ELSEIF W_/ZAK/ANALITIKA-FIELD_N EQ W_/ZAK/ANALITIKA-LWSTE.
      W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_7996.
      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
*   Neither - do not keep the entry
    ELSE.
      DELETE I_/ZAK/ANALITIKA_DEL.
    ENDIF.
  ENDLOOP.

  IF P_TESZT IS INITIAL.
    INSERT /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_NEW.
    DELETE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_DEL.
    COMMIT WORK AND WAIT.
    MESSAGE I203.
*   Converted items updated in the database!
  ENDIF.

ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
FORM ALV_LIST   TABLES   $TAB
                USING    $TAB_NAME.

*ALV list init
  PERFORM COMMON_ALV_LIST_INIT USING SY-TITLE
                                     $TAB_NAME
                                     '/ZAK/AFA_EVA_CORR'.

*ALV list
  PERFORM COMMON_ALV_GRID_DISPLAY TABLES $TAB
                                  USING  $TAB_NAME
                                         SPACE
                                         SPACE.

ENDFORM.                    " LIST_SPOOL

*&---------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM END_OF_LIST.

ENDFORM.                    " END_OF_LIST
