*&---------------------------------------------------------------------*
*& Program: /ZAK/MAIN_VIEW scheduler program
*&---------------------------------------------------------------------*
REPORT /ZAK/MAIN_BATCH MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: /ZAK/MAIN_VIEW scheduler program
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - NESS
*& Creation date     : 2014.10.14
*& Functional spec by: ________
*& SAP module name   : ADO
*& Program type      : Report
*& SAP version       : 60
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER            DESCRIPTION      TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*&                                   so it can be used for migration.
*&---------------------------------------------------------------------*

INCLUDE /ZAK/COMMON_STRUCT.

*&---------------------------------------------------------------------*
*& TABLES                                                               *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_STAT_F(1) TYPE C VALUE 'F',
           C_NUM         TYPE C VALUE 'N',
           C_CHAR        TYPE C VALUE 'C'.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Internal table        -   (I_xxx...)                             *
*      FORM parameter        -   ($xxxx...)                             *
*      Constant              -   (C_xxx...)                             *
*      Parameter variable    -   (P_xxx...)                             *
*      Selection option      -   (S_xxx...)                             *
*      Ranges                -   (R_xxx...)                             *
*      Global variables      -   (V_xxx...)                             *
*      Local variables       -   (L_xxx...)                             *
*      Work area             -   (W_xxx...)                             *
*      Type                  -   (T_xxx...)                             *
*      Macros                -   (M_xxx...)                             *
*      Field-symbol          -   (FS_xxx...)                            *
*      Method                -   (METH_xxx...)                          *
*      Object                -   (O_xxx...)                             *
*      Class                 -   (CL_xxx...)                            *
*      Event                 -   (E_xxx...)                             *
*&---------------------------------------------------------------------*

DATA V_REPID   LIKE SY-REPID.
DATA V_BTYPART TYPE /ZAK/BTYPART.

*Macro definition for populating a range
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

PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.

PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE
*                         NO-DISPLAY
                          OBLIGATORY.

PARAMETERS: P_INDEX  LIKE /ZAK/BEVALLI-ZINDEX DEFAULT '000' MODIF ID DIS.

PARAMETERS: P_CUM NO-DISPLAY.

SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------
*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.

  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
  V_REPID = SY-REPID.
*++0002 BG 2007.05.09
*  P_BTYPE = '0665'.
*  P_BSZNUM = '003'.
*--0002 BG 2007.05.09
  PERFORM READ_ADDITIONALS.
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
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_ATTRIBUTES.
  PERFORM READ_ADDITIONALS.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

**  Authorization check
*  PERFORM AUTHORITY_CHECK USING P_BUKRS
*                                P_BTART
*                                C_ACTVT_01.
  IF V_BTYPART IS INITIAL.
    PERFORM READ_ADDITIONALS.
  ENDIF.

*Determining the open periods:
  PERFORM GET_BEVALLI TABLES I_/ZAK/BEVALLI
                      USING  P_BUKRS
                             P_BTYPE
                             P_INDEX.

  IF I_/ZAK/BEVALLI[] IS INITIAL.
    MESSAGE I307.
*   No record matching the criteria found!
    EXIT.
  ENDIF.

*Scheduling jobs:
  PERFORM JOB_CREATE TABLES I_/ZAK/BEVALLI
                     USING  V_BTYPART.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  READ_ADDITIONALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS.


* Cumulative self-audit for VAT-type returns
  SELECT * UP TO 1 ROWS FROM /ZAK/BEVALL INTO W_/ZAK/BEVALL
    WHERE    BUKRS = P_BUKRS
      AND    BTYPE = P_BTYPE.
  ENDSELECT.
  IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_AFA.
    P_CUM = C_X.
  ENDIF.


* Determining the type of return
  IF NOT P_BUKRS IS INITIAL AND NOT P_BTYPE IS INITIAL.
    CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
      EXPORTING
        I_BUKRS       = P_BUKRS
        I_BTYPE       = P_BTYPE
      IMPORTING
        E_BTYPART     = V_BTYPART
      EXCEPTIONS
        ERROR_IMP_PAR = 1
        OTHERS        = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.


ENDFORM.                    " READ_ADDITIONALS
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
*      SCREEN-DISPLAY_3D = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  GET_BEVALLI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALLI  text
*----------------------------------------------------------------------*
FORM GET_BEVALLI  TABLES   $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
                  USING    $BUKRS
                           $BTYPE
                           $INDEX.

  RANGES LR_FLAG FOR /ZAK/BEVALLI-FLAG.

* Populate open and downloaded statuses
  M_DEF LR_FLAG 'I' 'EQ' 'F' SPACE.
  M_DEF LR_FLAG 'I' 'EQ' 'T' SPACE.

* Selecting BEVALLI data
  SELECT * INTO TABLE $I_/ZAK/BEVALLI
           FROM /ZAK/BEVALLI
          WHERE BUKRS EQ $BUKRS
            AND BTYPE EQ $BTYPE
            AND ZINDEX EQ $INDEX
            AND FLAG IN LR_FLAG.

ENDFORM.                    " GET_BEVALLI
*&---------------------------------------------------------------------*
*&      Form  JOB_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALLI  text
*----------------------------------------------------------------------*
FORM JOB_CREATE  TABLES   $I_/ZAK/BEVALLI STRUCTURE /ZAK/BEVALLI
                 USING    $BTYPART.

  DATA LW_/ZAK/BEVALLI TYPE /ZAK/BEVALLI.
  DATA L_JOBNAME  LIKE  TBTCJOB-JOBNAME.
  DATA L_JOBCOUNT LIKE  TBTCJOB-JOBCOUNT.

  RANGES LR_GJAHR  FOR /ZAK/BEVALLO-GJAHR.
  RANGES LR_MONAT  FOR /ZAK/BEVALLO-MONAT.
  RANGES LR_ZINDEX FOR /ZAK/BEVALLO-ZINDEX.

  LOOP AT $I_/ZAK/BEVALLI INTO LW_/ZAK/BEVALLI.
    CLEAR: L_JOBNAME, L_JOBCOUNT.
    REFRESH: LR_GJAHR, LR_MONAT, LR_ZINDEX.

    CONCATENATE  LW_/ZAK/BEVALLI-BUKRS
                 LW_/ZAK/BEVALLI-BTYPE
                 LW_/ZAK/BEVALLI-GJAHR
                 LW_/ZAK/BEVALLI-MONAT
                 LW_/ZAK/BEVALLI-ZINDEX
                 'MAIN' INTO L_JOBNAME SEPARATED BY '_'.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        JOBNAME          = L_JOBNAME
        SDLSTRTDT        = SY-DATUM
        SDLSTRTTM        = SY-UZEIT
      IMPORTING
        JOBCOUNT         = L_JOBCOUNT
      EXCEPTIONS
        CANT_CREATE_JOB  = 1
        INVALID_JOB_DATA = 2
        JOBNAME_MISSING  = 3
        OTHERS           = 4.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    M_DEF LR_GJAHR  'I' 'EQ' LW_/ZAK/BEVALLI-GJAHR SPACE.
    M_DEF LR_MONAT  'I' 'EQ' LW_/ZAK/BEVALLI-MONAT SPACE.
    M_DEF LR_ZINDEX 'I' 'EQ' LW_/ZAK/BEVALLI-ZINDEX SPACE.

*   Starting /ZAK/MAIN_VIEW
    SUBMIT /ZAK/MAIN_VIEW AND RETURN
      WITH P_BUKRS = LW_/ZAK/BEVALLI-BUKRS
      WITH P_BTART = $BTYPART
*++1765 #07.
      WITH P_MIGR = 'X'
*--1765 #07.
      WITH S_GJAHR1 IN LR_GJAHR
      WITH S_MONAT1 IN LR_MONAT
      WITH S_INDEX1 IN LR_ZINDEX
      USER SY-UNAME VIA JOB L_JOBNAME NUMBER L_JOBCOUNT.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        JOBCOUNT             = L_JOBCOUNT
        JOBNAME              = L_JOBNAME
        STRTIMMED            = 'X'
      EXCEPTIONS
        CANT_START_IMMEDIATE = 1
        INVALID_STARTDATE    = 2
        JOBNAME_MISSING      = 3
        JOB_CLOSE_FAILED     = 4
        JOB_NOSTEPS          = 5
        JOB_NOTEX            = 6
        LOCK_FAILED          = 7
        INVALID_TARGET       = 8
        OTHERS               = 9.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDLOOP.

  MESSAGE I308.
*   Jobs scheduled, please check the JOB log!

ENDFORM.                    " JOB_CREATE
