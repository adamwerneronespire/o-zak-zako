*&---------------------------------------------------------------------*
*& Report  /ZAK/BSET_UPDATE
*&
*&---------------------------------------------------------------------*

REPORT /ZAK/BSET_UPDATE MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: Updates the documents created by the standard VAT run.
*& The FI_TAX_BADI_015 source code is implemented here because note 2061805
*& changed the COMMIT WORK points of program RFUMVS00, therefore the
*& BSET-STMDT and BSET-STMTI fields cannot be checked during the BAdI run.
*&---------------------------------------------------------------------*
*& Author            : Gábor Balázs - NESS
*& Creation date     : 2015.07.08
*& Functional spec by: ________
*& SAP modul neve    : ADO
*& Program type      : Report
*& SAP version       : 6.0
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of each modified line)*
*&
*& LOG#     DATE        MODIFIER        DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*

*INCLUDE /ZAK/COMMON_STRUCT.


*&---------------------------------------------------------------------*
*& TABLES                                                             *
*&---------------------------------------------------------------------*
*++S4HANA#01.
*TABLES /ZAK/BSET_BELNR.
DATA GS_/ZAK/BSET_BELNR TYPE /ZAK/BSET_BELNR.
*--S4HANA#01.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                  *
*      Internal table     -   (I_xxx...)                              *
*      FORM parameter     -   ($xxxx...)                              *
*      Constant           -   (C_xxx...)                              *
*      Parameter variable -   (P_xxx...)                              *
*      Selection option   -   (S_xxx...)                              *
*      Ranges             -   (R_xxx...)                              *
*      Global variables   -   (V_xxx...)                              *
*      Local variables    -   (L_xxx...)                              *
*      Work area          -   (W_xxx...)                              *
*      Type               -   (T_xxx...)                              *
*      Macros             -   (M_xxx...)                              *
*      Field-symbol       -   (FS_xxx...)                             *
*      Method             -   (METH_xxx...)                           *
*      Object             -   (O_xxx...)                              *
*      Class              -   (CL_xxx...)                             *
*      Event              -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA: W_AUSTE TYPE RFUMS_TAX_ITEM,
*++S4HANA#01.
*      W_VOSTE    TYPE RFUMS_TAX_ITEM,
*      W_BSET     TYPE BSET,
      W_VOSTE TYPE RFUMS_TAX_ITEM.
TYPES: BEGIN OF TS_W_BSET_SEL,
         BUKRS TYPE BSET-BUKRS,
         BELNR TYPE BSET-BELNR,
         GJAHR TYPE BSET-GJAHR,
         BUZEI TYPE BSET-BUZEI,
         STMDT TYPE BSET-STMDT,
         STMTI TYPE BSET-STMTI,
       END OF TS_W_BSET_SEL.
DATA: W_BSET     TYPE TS_W_BSET_SEL,
*--S4HANA#01.
      W_/ZAK/ZAK      TYPE /ZAK/BSET,
      L_/ZAK/ZAK      TYPE /ZAK/BSET,
      W_BSET_LOG TYPE /ZAK/BSET_LOG,
      L_BSET_LOG TYPE /ZAK/BSET_LOG.

*++2015.07.08 BG (NESS)
DATA  W_/ZAK/BELNR TYPE /ZAK/BSET_BELNR.
DATA  I_/ZAK/BELNR TYPE STANDARD TABLE OF /ZAK/BSET_BELNR.
*--2015.07.08 BG (NESS)
DATA: I_BSET TYPE STANDARD TABLE OF BSET INITIAL SIZE 0.

*  data: l_datum  type buper,
*        l_bday   type ZFMAVA_bday,
*        l_zfbdt  type datum,
*        l_kalkd  type datum,
*        l_ev(4)  type n,
*        l_ho(2)  type n,
*        l_nap(2) type n.


DATA: I_ZFMAVA_START TYPE STANDARD TABLE OF /ZAK/START INITIAL
SIZE 0,
      W_ZFMAVA_START TYPE /ZAK/START.

* Tax return category
CONSTANTS: C_BTYPART_AFA  TYPE /ZAK/BTYPART VALUE 'AFA',
           C_BTYPART_SZJA TYPE /ZAK/BTYPART VALUE 'SZJA',
           C_BTYPART_TARS TYPE /ZAK/BTYPART VALUE 'TARS',
           C_BTYPART_UCS  TYPE /ZAK/BTYPART VALUE 'UCS',
           C_BTYPART_ATV  TYPE /ZAK/BTYPART VALUE 'ATV'.

*++1365#24.
DATA: I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA,
      W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA,
      I_RETURN        TYPE STANDARD TABLE OF BAPIRET2.
DATA  L_BUPER TYPE BUPER.

TYPES: BEGIN OF T_BUPER,
         BUPER_OLD TYPE BUPER,
         BUPER_NEW TYPE BUPER,
       END OF T_BUPER.

DATA I_BUPER TYPE SORTED TABLE OF T_BUPER WITH UNIQUE KEY BUPER_OLD.
DATA W_BUPER TYPE T_BUPER.

*++S4HANA#01.
DATA : I_RLDNR     TYPE RLDNR,
       IT_BSEG_NEW TYPE FAGL_T_BSEG,
       LS_BSEG_NEW LIKE LINE OF IT_BSEG_NEW.
*--S4HANA#01.

DEFINE L_M_GET_BUPER.
*   Check
  READ TABLE I_BUPER INTO W_BUPER
             WITH KEY BUPER_OLD = &1-BUPER.
*   Determine the period
  IF SY-SUBRC NE 0.
    CLEAR   W_/ZAK/ANALITIKA.
    REFRESH: I_/ZAK/ANALITIKA, I_RETURN.
    W_/ZAK/ANALITIKA-MANDT  = SY-MANDT.
    W_/ZAK/ANALITIKA-BUKRS  = &1-BUKRS.
    W_/ZAK/ANALITIKA-GJAHR  = &1-BUPER(4).
    W_/ZAK/ANALITIKA-MONAT  = &1-BUPER+4(2).
    W_/ZAK/ANALITIKA-ABEVAZ = 'DUMMY'.
    W_/ZAK/ANALITIKA-BSZNUM = '999'.
    W_/ZAK/ANALITIKA-ITEM   = '000001'.
    W_/ZAK/ANALITIKA-LAPSZ  = '0001'.
    APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA.
    CALL FUNCTION '/ZAK/UPDATE'
      EXPORTING
        I_BUKRS           = &1-BUKRS
*       I_BTYPE           =
        I_BTYPART         = C_BTYPART_AFA
        I_BSZNUM          = '999'
*       I_PACK            =
        I_GEN             = 'X'
        I_TEST            = 'X'
*       I_FILE            =
      TABLES
        I_ANALITIKA       = I_/ZAK/ANALITIKA
*       I_AFA_SZLA        =
        E_RETURN          = I_RETURN.

    READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA INDEX 1.
    CONCATENATE W_/ZAK/ANALITIKA-GJAHR W_/ZAK/ANALITIKA-MONAT
                INTO L_BUPER.
    CLEAR W_BUPER.
    W_BUPER-BUPER_OLD = &1-BUPER.
    IF &1-BUPER NE L_BUPER.
      &1-BUPER = L_BUPER.
    ENDIF.
    W_BUPER-BUPER_NEW = L_BUPER.
    INSERT W_BUPER INTO TABLE I_BUPER.
  ELSEIF W_BUPER-BUPER_NEW NE &1-BUPER.
    &1-BUPER = W_BUPER-BUPER_NEW.
  ENDIF.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

*++S4HANA#01.
*  SELECT-OPTIONS S_BUKRS FOR /ZAK/BSET_BELNR-BUKRS.
*  SELECT-OPTIONS S_BELNR FOR /ZAK/BSET_BELNR-BELNR.
*  SELECT-OPTIONS S_GJAHR FOR /ZAK/BSET_BELNR-GJAHR.
  SELECT-OPTIONS S_BUKRS FOR GS_/ZAK/BSET_BELNR-BUKRS.
  SELECT-OPTIONS S_BELNR FOR GS_/ZAK/BSET_BELNR-BELNR.
  SELECT-OPTIONS S_GJAHR FOR GS_/ZAK/BSET_BELNR-GJAHR.
*--S4HANA#01.

SELECTION-SCREEN: END OF BLOCK BL01.

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
*   You do not have authorization to run the program!
  ENDIF.
*--1765 #19.


* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM GET_DATA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  DATA LI_/ZAK/BELNR TYPE STANDARD TABLE OF /ZAK/BSET_BELNR.
  DATA LW_/ZAK/BELNR TYPE /ZAK/BSET_BELNR.

* Data selection:
  SELECT * INTO TABLE LI_/ZAK/BELNR
            FROM /ZAK/BSET_BELNR
           WHERE BUKRS IN S_BUKRS
             AND BELNR IN S_BELNR
             AND GJAHR IN S_GJAHR.

* Data processing
  LOOP AT LI_/ZAK/BELNR INTO LW_/ZAK/BELNR.
    CLEAR W_BSET.
*++S4HANA#01.
*    SELECT SINGLE * INTO W_BSET
    SELECT SINGLE BUKRS BELNR GJAHR BUZEI STMDT STMTI INTO W_BSET
*--S4HANA#01.
                   FROM BSET
                  WHERE BUKRS EQ LW_/ZAK/BELNR-BUKRS
                    AND BELNR EQ LW_/ZAK/BELNR-BELNR
                    AND GJAHR EQ LW_/ZAK/BELNR-GJAHR
                    AND BUZEI EQ LW_/ZAK/BELNR-BUZEI.
    CHECK SY-SUBRC EQ 0 AND NOT W_BSET-STMDT IS INITIAL AND NOT W_BSET-STMTI IS INITIAL.
    CLEAR W_/ZAK/ZAK.

    W_/ZAK/ZAK-BUKRS = W_BSET-BUKRS.
    W_/ZAK/ZAK-BELNR = W_BSET-BELNR.
    W_/ZAK/ZAK-GJAHR = W_BSET-GJAHR.
    W_/ZAK/ZAK-BUZEI = W_BSET-BUZEI.
*++2007.01.11 BG (FMC)
*       w_/zak/zak-buper = w_auste-bldat(6).
*--2007.01.11 BG (FMC)
    W_/ZAK/ZAK-ZINDEX = SPACE.
*++0001 2007.01.03 BG (FMC)
**     Tax date
*        CLEAR W_/ZAK/ZAK-ADODAT.
*        SELECT SINGLE
*          ADODAT
*          INTO W_/ZAK/ZAK-ADODAT
*          FROM /ZAK/AD001_BKPF
*          WHERE BUKRS EQ W_AUSTE-BUKRS
*            AND GJAHR EQ W_AUSTE-GJAHR
*            AND BELNR EQ W_AUSTE-BELNR.
*++2007.01.11 BG (FMC)
*++2015.07.29
*    W_/ZAK/ZAK-ADODAT = LW_/ZAK/BELNR-VATDATE.
    SELECT SINGLE VATDATE INTO W_/ZAK/ZAK-ADODAT
                          FROM BKPF
                   WHERE BUKRS EQ LW_/ZAK/BELNR-BUKRS
                     AND BELNR EQ LW_/ZAK/BELNR-BELNR
                     AND GJAHR EQ LW_/ZAK/BELNR-GJAHR.
*--2015.07.29
    IF NOT W_/ZAK/ZAK-ADODAT IS INITIAL.
      W_/ZAK/ZAK-BUPER = W_/ZAK/ZAK-ADODAT(6).
    ELSE.
      W_/ZAK/ZAK-BUPER = LW_/ZAK/BELNR-BLDAT(6).
ENHANCEMENT-POINT /ZAK/ZAK_AUDI_UPD_01 SPOTS /ZAK/BSET_UPDATE_ES .
    ENDIF.
*--2007.01.11 BG (FMC)
*     Transaction type
    CLEAR W_/ZAK/ZAK-TTIP.
*++S4HANA#01.
*    SELECT
*      DIEKZ
*      INTO W_/ZAK/ZAK-TTIP
*      FROM BSEG
*      WHERE BUKRS EQ LW_/ZAK/BELNR-BUKRS
*        AND BELNR EQ LW_/ZAK/BELNR-BELNR
*        AND GJAHR EQ LW_/ZAK/BELNR-GJAHR
*        AND DIEKZ NE SPACE.
*      EXIT.
*    ENDSELECT.
    CALL FUNCTION 'FAGL_GET_LEADING_LEDGER'       "
      IMPORTING                                    "
        E_RLDNR       = I_RLDNR                    "
      EXCEPTIONS                                   "
        NOT_FOUND     = 1                          "
        MORE_THAN_ONE = 2                          "
        OTHERS        = 3.                         "
    IF SY-SUBRC = 0.                               "
      CALL FUNCTION 'FAGL_GET_GL_DOCUMENT'         "
        EXPORTING                                  "
          I_RLDNR   = I_RLDNR                      "
          I_BUKRS   = LW_/ZAK/BELNR-BUKRS           "
          I_BELNR   = LW_/ZAK/BELNR-BELNR           "
          I_GJAHR   = LW_/ZAK/BELNR-GJAHR           "
        IMPORTING                                  "
          ET_BSEG   = IT_BSEG_NEW
        EXCEPTIONS
          NOT_FOUND = 1
          OTHERS    = 2.
      IF SY-SUBRC = 0.
        DELETE IT_BSEG_NEW WHERE DIEKZ EQ SPACE.
        SORT IT_BSEG_NEW BY BUKRS BELNR GJAHR BUZEI.
        LOOP AT IT_BSEG_NEW INTO LS_BSEG_NEW.
          W_/ZAK/ZAK-TTIP = LS_BSEG_NEW-DIEKZ.
          EXIT.
        ENDLOOP.
        CLEAR: IT_BSEG_NEW, I_RLDNR.
      ENDIF.
    ENDIF.
*--S4HANA#01.
*--0001 2007.01.03 BG (FMC)
    CLEAR L_/ZAK/ZAK.
*++S4HANA#01.
*    SELECT SINGLE * INTO L_/ZAK/ZAK FROM /ZAK/BSET
*      WHERE  BUKRS  = W_/ZAK/ZAK-BUKRS
*      AND    BELNR  = W_/ZAK/ZAK-BELNR
*      AND    GJAHR  = W_/ZAK/ZAK-GJAHR
*      AND    BUZEI  = W_/ZAK/ZAK-BUZEI.
    SELECT SINGLE @SPACE FROM /ZAK/BSET
      WHERE  BUKRS  = @W_/ZAK/ZAK-BUKRS
      AND    BELNR  = @W_/ZAK/ZAK-BELNR
      AND    GJAHR  = @W_/ZAK/ZAK-GJAHR
      AND    BUZEI  = @W_/ZAK/ZAK-BUZEI INTO @L_/ZAK/ZAK.
*--S4HANA#01.
    IF SY-SUBRC NE 0.
*++1365#24.
*Determine BUPER; if the period is closed with 'X' then
*move it to the new period right here:
      L_M_GET_BUPER W_/ZAK/ZAK.
*--1365#24.
      INSERT INTO /ZAK/BSET VALUES W_/ZAK/ZAK.
      DELETE /ZAK/BSET_BELNR FROM LW_/ZAK/BELNR.
      IF SY-SUBRC = 0.
* LOG table update
        CLEAR L_BSET_LOG.
        SELECT SINGLE * INTO L_BSET_LOG FROM /ZAK/BSET_LOG
          WHERE BUKRS = W_/ZAK/ZAK-BUKRS
            AND BUPER = W_/ZAK/ZAK-BUPER.
        IF SY-SUBRC NE 0.
          CLEAR W_BSET_LOG.
          W_BSET_LOG-BUKRS = W_/ZAK/ZAK-BUKRS.
          W_BSET_LOG-BUPER = W_/ZAK/ZAK-BUPER.

          CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
            EXPORTING
              I_DATLO     = SY-DATLO
              I_TIMLO     = SY-TIMLO
*             I_TZONE     = SY-ZONLO
            IMPORTING
              E_TIMESTAMP = W_BSET_LOG-LARUN.

          INSERT INTO /ZAK/BSET_LOG VALUES W_BSET_LOG.
        ELSE.

          CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
            EXPORTING
              I_DATLO     = SY-DATLO
              I_TIMLO     = SY-TIMLO
*             I_TZONE     = SY-ZONLO
            IMPORTING
              E_TIMESTAMP = W_BSET_LOG-LARUN.

          UPDATE /ZAK/BSET_LOG SET LARUN = W_BSET_LOG-LARUN
             WHERE BUKRS = W_/ZAK/ZAK-BUKRS
               AND BUPER = W_/ZAK/ZAK-BUPER.
        ENDIF.

        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_DATA
