*&---------------------------------------------------------------------*
*& Program: VAT migration program
*&---------------------------------------------------------------------*
REPORT /ZAK/MIGR_AFA MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Function description: VAT migration program
*&---------------------------------------------------------------------*
*& Author            : Cserhegyi Tímea - fmc
*& Creation date     : 2006.04.12
*& Functional spec by: ________
*& SAP modul neve    : ADO
*& Program  type     : Report
*& SAP version       : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION      TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2007/05/09   Balázs G.     Generalization so that it can be
*&                                   used for more than just VAT migration.
*&---------------------------------------------------------------------*

INCLUDE /ZAK/COMMON_STRUCT.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_CLOSED_Z(1) TYPE C VALUE 'Z',
           C_CLOSED_X(1) TYPE C VALUE 'X',
           C_NUM         TYPE C VALUE 'N',
           C_CHAR        TYPE C VALUE 'C'.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table       -   (I_xxx...)                              *
*      FORM parameter       -   ($xxxx...)                              *
*      Constant             -   (C_xxx...)                              *
*      Parameter variable   -   (P_xxx...)                              *
*      Selection option     -   (S_xxx...)                              *
*      Range                -   (R_xxx...)                              *
*      Global variables     -   (V_xxx...)                              *
*      Local variables      -   (L_xxx...)                              *
*      Work area            -   (W_xxx...)                              *
*      Type                 -   (T_xxx...)                              *
*      Macros               -   (M_xxx...)                              *
*      Field symbol         -   (FS_xxx...)                             *
*      Method               -   (METH_xxx...)                           *
*      Object               -   (O_xxx...)                              *
*      Class                -   (CL_xxx...)                             *
*      Event                -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
* Standard
DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
      W_OUTTAB TYPE /ZAK/BEVALLALV.

* Converted
DATA: I_OUTTAB_C TYPE STANDARD TABLE OF /ZAK/BEVALLALV INITIAL SIZE 0,
      W_OUTTAB_C TYPE /ZAK/BEVALLALV.



TYPES: BEGIN OF T_TAB_KEY,
         BUKRS  TYPE BUKRS,
         BTYPE  TYPE /ZAK/BTYPE,
         GJAHR  TYPE GJAHR,
         MONAT  TYPE MONAT,
         ZINDEX TYPE /ZAK/INDEX,
       END OF T_TAB_KEY.

DATA: I_TAB_KEY TYPE STANDARD TABLE OF T_TAB_KEY  INITIAL SIZE 0.
DATA: W_TAB_KEY TYPE T_TAB_KEY.

DATA: I_OUT     TYPE STANDARD TABLE OF /ZAK/ALV_MIGR  INITIAL SIZE 0.
DATA: W_OUT     TYPE /ZAK/ALV_MIGR.

DATA: V_COUNTER TYPE I.

* Control variables
DATA: V_SUBRC LIKE SY-SUBRC.

* ALV control variables
DATA: V_OK_CODE          LIKE SY-UCOMM,
      V_SAVE_OK          LIKE SY-UCOMM,
      V_REPID            LIKE SY-REPID,
      V_CONTAINER        TYPE SCRFNAME VALUE 'ZALV_9000',
      V_GRID             TYPE REF TO CL_GUI_ALV_GRID,
      V_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT         TYPE LVC_T_FCAT,
      V_LAYOUT           TYPE LVC_S_LAYO,
      V_VARIANT          TYPE DISVARIANT.


*++S4HANA#01.
*RANGES R_MONAT FOR /ZAK/ANALITIKA-MONAT.
TYPES TT_MONAT TYPE RANGE OF /ZAK/ANALITIKA-MONAT.
DATA GT_MONAT TYPE TT_MONAT.
DATA GS_MONAT TYPE LINE OF TT_MONAT.
*--S4HANA#01.
*++1465 #11.
RANGES R_FLAG FOR /ZAK/BEVALLI-FLAG.
*Macro definition for filling ranges
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.

*--1465 #11.

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-101.
    PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                              OBLIGATORY MEMORY ID BUK.
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.


  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-103 FOR FIELD P_BTART.
    PARAMETERS: P_BTART LIKE /ZAK/BEVALL-BTYPART OBLIGATORY
*++0002 BG 2007.05.09
                             MEMORY ID /ZAK/ZBTR.
*--0002 BG 2007.05.09
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BTTEXT(40) TYPE C MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.


  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(31) TEXT-102 FOR FIELD P_BTYPE.
    PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE
*                         NO-DISPLAY
                              OBLIGATORY
                              .
    SELECTION-SCREEN POSITION 50.
    PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
  SELECTION-SCREEN END OF LINE.
  PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL01.


SELECTION-SCREEN: BEGIN OF BLOCK BL09 WITH FRAME TITLE TEXT-T09.
  PARAMETERS: P_CR RADIOBUTTON GROUP RADI DEFAULT 'X',
              P_CL RADIOBUTTON GROUP RADI,
              P_DE RADIOBUTTON GROUP RADI MODIF ID DIS.
  PARAMETERS: P_CUM AS CHECKBOX DEFAULT 'X' MODIF ID DIS.
SELECTION-SCREEN: END   OF BLOCK BL09.

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
*   You do not have authorization to run the program!
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
  DATA: L_SUBRC LIKE SY-SUBRC.

*  Authorization check
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                P_BTART
                                C_ACTVT_01.

*++0002 BG 2007.05.09
** Tax return type determination
*  P_BTYPE = '0665'.
*--0002 BG 2007.05.09

*++1465 #11.
  PERFORM GET_FLAG USING  P_BUKRS
                          P_BTYPE.
*--1465 #11.

* Reading current data
* Tax return general data
  PERFORM READ_BEVALL USING P_BUKRS
                            P_BTYPE.
* Tax return data provision settings
*   PERFORM READ_BEVALLC USING P_BUKRS
*                              P_BTYPE.
* Tax return data provision data
  PERFORM READ_BEVALLD USING P_BUKRS
                             P_BTYPE.
* Tax return form data
  PERFORM READ_BEVALLB USING P_BTYPE.

* Tax return - prepared (if it already exists)
  PERFORM READ_BEVALLO USING P_BUKRS
                             P_BTYPE.

* Set locking
  PERFORM ENQUEUE_PERIOD.


*----------------------------------------------------------------------*
* Tax return creation
*----------------------------------------------------------------------*
  IF P_CR = 'X'.
*++S4HANA#01.
*    REFRESH I_OUT.
    CLEAR I_OUT[].
*--S4HANA#01.
*  Analytics
    PERFORM READ_ANALITIKA.

*  Saving the tax return
    LOOP AT I_TAB_KEY INTO W_TAB_KEY.
      L_SUBRC = 0.
      PERFORM UPDATE_BEVALLO CHANGING L_SUBRC.

* Filling ranges for periods
      PERFORM FILL_RANGE.

*     Status update /ZAK/BEVALLSZ//ZAK/ZAK_BE
      IF L_SUBRC = 0.
        PERFORM STATUS_UPDATE USING 'T'.

        MOVE-CORRESPONDING W_TAB_KEY TO W_OUT.
        W_OUT-LIGHT = 3.
      ELSE.
        MOVE-CORRESPONDING W_TAB_KEY TO W_OUT.
        W_OUT-LIGHT = 1.
      ENDIF.


      APPEND W_OUT TO I_OUT.
    ENDLOOP.

    IF NOT I_OUT[] IS INITIAL.
      PERFORM LIST_DISPLAY.
    ENDIF.

  ENDIF.


*----------------------------------------------------------------------*
* Tax return closing
*----------------------------------------------------------------------*
  IF P_CL = 'X'.

*++S4HANA#01.
*    REFRESH I_OUT.
    CLEAR I_OUT[].
*--S4HANA#01.
* Is there an item marked for posting? -> cannot be closed
    READ TABLE I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
       WITH KEY BOOK = 'M'.
    IF SY-SUBRC = 0.
      MESSAGE E129(/ZAK/ZAK) WITH W_/ZAK/ANALITIKA-GJAHR
                        W_/ZAK/ANALITIKA-MONAT.
    ENDIF.

* Has a tax return been created already?
*++S4HANA#01.
*    DESCRIBE TABLE I_/ZAK/BEVALLO LINES SY-TFILL.
    SY-TFILL = LINES( I_/ZAK/BEVALLO ).
*--S4HANA#01.
    IF SY-TFILL = 0.
      MESSAGE E168(/ZAK/ZAK) WITH P_BUKRS
                             P_BTYPE.

    ENDIF.


    LOOP AT I_/ZAK/BEVALLO INTO W_/ZAK/BEVALLO.

      AT NEW ZINDEX.      "#EC_CI_SORTED
* Table keys
        READ TABLE I_TAB_KEY INTO W_TAB_KEY
          WITH KEY BUKRS  = W_/ZAK/BEVALLO-BUKRS
                   BTYPE  = W_/ZAK/BEVALLO-BTYPE
                   GJAHR  = W_/ZAK/BEVALLO-GJAHR
                   MONAT  = W_/ZAK/BEVALLO-MONAT
                   ZINDEX = W_/ZAK/BEVALLO-ZINDEX.
        IF SY-SUBRC NE 0.
          MOVE-CORRESPONDING W_/ZAK/BEVALLO TO W_TAB_KEY.
          APPEND W_TAB_KEY TO I_TAB_KEY.
        ENDIF.
      ENDAT.

    ENDLOOP.


    LOOP AT I_TAB_KEY INTO W_TAB_KEY.


* Filling ranges for periods
      PERFORM FILL_RANGE.

*   Locked period -> cannot be closed
      PERFORM CHECK_ALREADY_CLOSED.
      PERFORM GET_BEVALLI.
      PERFORM GET_BEVALLSZ.
      PERFORM CHECK_ADATSZOLG.

*++S4HANA#01.
*      PERFORM FULL_PERIOD USING
*                          I_/ZAK/BEVALLI[]
*                          I_/ZAK/BEVALLSZ[]
*                          I_/ZAK/BEVALLD[]
*                          W_TAB_KEY-MONAT
*                          W_TAB_KEY-GJAHR
*                          W_TAB_KEY-ZINDEX.
      PERFORM FULL_PERIOD USING
                          I_/ZAK/BEVALLD[]
                          W_TAB_KEY-MONAT
                          W_TAB_KEY-GJAHR
                          W_TAB_KEY-ZINDEX
                 CHANGING I_/ZAK/BEVALLI[]
                          I_/ZAK/BEVALLSZ[].
*--S4HANA#01.


      PERFORM SET_BEVALLI USING 'Z'.
      PERFORM SET_BEVALLSZ USING 'Z'.


      MOVE-CORRESPONDING W_TAB_KEY TO W_OUT.
      W_OUT-LIGHT = 3.
      APPEND W_OUT TO I_OUT.

    ENDLOOP.


    IF NOT I_OUT[] IS INITIAL.
      PERFORM LIST_DISPLAY.
    ENDIF.

  ENDIF.

*----------------------------------------------------------------------*
* Tax return deletion
*----------------------------------------------------------------------*
  IF P_DE = 'X'.

    V_SUBRC = 0.
    PERFORM DELETE_BEVALLO   CHANGING V_SUBRC.
*  check v_subrc = 0.
    PERFORM DELETE_ANALITIKA CHANGING V_SUBRC.
*  check v_subrc = 0.
    PERFORM DELETE_BEVALLSZ  CHANGING V_SUBRC.
*  check v_subrc = 0.
    PERFORM DELETE_BEVALLI   CHANGING V_SUBRC.
*  check v_subrc = 0.
    PERFORM DELETE_BSET .


    IF V_SUBRC =  0.
      COMMIT WORK.

      MESSAGE I170(/ZAK/ZAK) WITH P_BUKRS
                             P_BTART.

    ELSE.
      ROLLBACK WORK.

      MESSAGE I171(/ZAK/ZAK) WITH P_BUKRS
                             P_BTART.

    ENDIF.

  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  READ_ADDITIONALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ADDITIONALS.

* Company name
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.


* Tax return type name
    IF NOT P_BTART IS INITIAL.
      SELECT DDTEXT UP TO 1 ROWS INTO P_BTTEXT FROM DD07T
         WHERE DOMNAME = '/ZAK/BTYPART'
           AND DDLANGUAGE = SY-LANGU
           AND DOMVALUE_L = P_BTART
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
*--S4HANA#01.
      ENDSELECT.


* Cumulative self-revision of VAT-type returns
*++S4HANA#01.
*      SELECT * UP TO 1 ROWS FROM /ZAK/BEVALL INTO W_/ZAK/BEVALL
*        WHERE    BUKRS = P_BUKRS
*          AND    BTYPE = P_BTYPE.
      SELECT BTYPART BIDOSZ UP TO 1 ROWS FROM /ZAK/BEVALL
        INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALL
        WHERE    BUKRS = P_BUKRS
          AND    BTYPE = P_BTYPE
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*--S4HANA#01.

      IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_AFA.
        P_CUM = C_X.
      ENDIF.

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
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_PERIOD.
  CALL FUNCTION 'ENQUEUE_/ZAK/EBEVALLSZ'
    EXPORTING
      MODE_/ZAK/BEVALLSZ = C_X
      BUKRS             = P_BUKRS
      BTYPE             = P_BTYPE
    EXCEPTIONS
      FOREIGN_LOCK      = 1
      SYSTEM_FAILURE    = 2
      OTHERS            = 3.

  IF SY-SUBRC <> 0.
    MESSAGE W099(/ZAK/ZAK) WITH P_BUKRS P_BTYPE.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " ENQUEUE_PERIOD
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALLB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM READ_BEVALLB USING    $BTYPE.
*  REFRESH I_/ZAK/BEVALLB.
FORM READ_BEVALLB USING    $BTYPE TYPE /ZAK/BEVALL-BTYPE.
  CLEAR I_/ZAK/BEVALLB[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLB FROM /ZAK/BEVALLB
      WHERE BTYPE = $BTYPE.
ENDFORM.                    " READ_BEVALLB
*&---------------------------------------------------------------------*
*&      Form  READ_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ANALITIKA.
  DATA: L_COUNTER TYPE I.
  DATA: L_OUTTAB  LIKE W_OUTTAB.
*++1765 #01.
  DATA: L_DATUM TYPE DATUM.
*--1765 #01.
*++S4HANA#01.
*  REFRESH: I_/ZAK/ANALITIKA,
*           I_OUTTAB.
  CLEAR: I_/ZAK/ANALITIKA[].
  CLEAR: I_OUTTAB[].
*--S4HANA#01.


* Reading migration items
*++S4HANA#01.
*  SELECT * INTO TABLE I_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
  SELECT MANDT BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON LAPSZ XDEFT STAPO WAERS BOOK FIELD_C FIELD_N
    INTO CORRESPONDING FIELDS OF TABLE I_/ZAK/ANALITIKA FROM /ZAK/ANALITIKA
*--S4HANA#01.
  WHERE BUKRS  = P_BUKRS
    AND BTYPE  = P_BTYPE
*++0002 BG 2007.05.09
*      AND BSZNUM = '003'.
    AND BSZNUM = P_BSZNUM.
*--0002 BG 2007.05.09


  LOOP AT I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB.
    CLEAR W_OUTTAB.
    CLEAR L_COUNTER.

    LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
      CHECK W_/ZAK/ANALITIKA-ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
      CHECK W_/ZAK/ANALITIKA-STAPO NE C_X.

      L_COUNTER = L_COUNTER + 1.

      IF W_/ZAK/BEVALLB-ASZKOT = SPACE.
        CLEAR W_/ZAK/ANALITIKA-ADOAZON.
      ENDIF.
*++1765 #01.
      CONCATENATE W_/ZAK/ANALITIKA-GJAHR W_/ZAK/ANALITIKA-MONAT '01' INTO L_DATUM.
      LOOP AT  I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
                 WHERE    BUKRS = W_/ZAK/ANALITIKA-BUKRS
                  AND     BTYPE = W_/ZAK/ANALITIKA-BTYPE
                  AND     DATBI >= L_DATUM
                  AND     DATAB <= L_DATUM.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        MESSAGE E111 WITH W_/ZAK/ANALITIKA-BTYPE W_/ZAK/ANALITIKA-GJAHR.
*   Missing configuration for tax return type & in year &!
      ENDIF.
*--1765 #01.
* PERIOD conversion
      CASE W_/ZAK/BEVALL-BIDOSZ.
        WHEN 'E'.
          W_/ZAK/ANALITIKA-MONAT = '12'.
        WHEN 'N'.
          IF W_/ZAK/ANALITIKA-MONAT >= '01' AND
             W_/ZAK/ANALITIKA-MONAT <= '03'.
            W_/ZAK/ANALITIKA-MONAT = '03'.
          ENDIF.
          IF W_/ZAK/ANALITIKA-MONAT >= '04' AND
             W_/ZAK/ANALITIKA-MONAT <= '06'.
            W_/ZAK/ANALITIKA-MONAT = '06'.
          ENDIF.
          IF W_/ZAK/ANALITIKA-MONAT >= '07' AND
             W_/ZAK/ANALITIKA-MONAT <= '09'.
            W_/ZAK/ANALITIKA-MONAT = '09'.
          ENDIF.
          IF W_/ZAK/ANALITIKA-MONAT >= '10' AND
             W_/ZAK/ANALITIKA-MONAT <= '12'.
            W_/ZAK/ANALITIKA-MONAT = '12'.
          ENDIF.
        WHEN 'H'.
        WHEN OTHERS.
      ENDCASE.

* Character-based
      IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.

        READ TABLE I_OUTTAB INTO L_OUTTAB WITH KEY
             BUKRS = W_/ZAK/ANALITIKA-BUKRS
             BTYPE = W_/ZAK/ANALITIKA-BTYPE
             GJAHR = W_/ZAK/ANALITIKA-GJAHR
             MONAT = W_/ZAK/ANALITIKA-MONAT
             ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
             ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
             ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
* If this key does not yet exist - save it
        IF SY-SUBRC NE 0.

          MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
          MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
          W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
          W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

          SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
            FROM  /ZAK/BEVALLBT
                 WHERE  LANGU   = SY-LANGU
                 AND    BTYPE   = W_OUTTAB-BTYPE
                 AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

          W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.

          COLLECT W_OUTTAB INTO I_OUTTAB.

*  A key with this value already exists
        ELSE.
* This is the default text - modify the saved one
          IF NOT W_/ZAK/ANALITIKA-XDEFT IS INITIAL.
            READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                 BUKRS = W_/ZAK/ANALITIKA-BUKRS
                 BTYPE = W_/ZAK/ANALITIKA-BTYPE
                 GJAHR = W_/ZAK/ANALITIKA-GJAHR
                 MONAT = W_/ZAK/ANALITIKA-MONAT
                 ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                 ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                 ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
            IF SY-SUBRC = 0.
              MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
              MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.
              W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
              W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

              SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
                FROM  /ZAK/BEVALLBT
                     WHERE  LANGU   = SY-LANGU
                     AND    BTYPE   = W_OUTTAB-BTYPE
                     AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

              W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.

              MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.

            ENDIF.
          ENDIF.
        ENDIF.
* Numeric
      ELSE.
        MOVE-CORRESPONDING W_/ZAK/BEVALLB   TO W_OUTTAB.
        MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_OUTTAB.

        W_OUTTAB-BTYPE_DISP  = W_OUTTAB-BTYPE.
        W_OUTTAB-ABEVAZ_DISP = W_OUTTAB-ABEVAZ.

        SELECT SINGLE ABEVTEXT INTO W_OUTTAB-ABEVTEXT
          FROM  /ZAK/BEVALLBT
               WHERE  LANGU   = SY-LANGU
               AND    BTYPE   = W_OUTTAB-BTYPE
               AND    ABEVAZ  = W_OUTTAB-ABEVAZ.

        W_OUTTAB-ABEVTEXT_DISP = W_OUTTAB-ABEVTEXT.

        COLLECT W_OUTTAB INTO I_OUTTAB.
      ENDIF.



* Table keys
      READ TABLE I_TAB_KEY INTO W_TAB_KEY
        WITH KEY BUKRS  = W_/ZAK/ANALITIKA-BUKRS
                 BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                 GJAHR  = W_/ZAK/ANALITIKA-GJAHR
                 MONAT  = W_/ZAK/ANALITIKA-MONAT
                 ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
      IF SY-SUBRC NE 0.
        MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_TAB_KEY.
        APPEND W_TAB_KEY TO I_TAB_KEY.
      ENDIF.
    ENDLOOP.

  ENDLOOP.



  DATA: L_ROUND(20) TYPE C.
  LOOP AT I_OUTTAB INTO W_OUTTAB.
* Amount conversions

    CLEAR L_ROUND.


    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_OUTTAB-BTYPE
                ABEVAZ = W_OUTTAB-ABEVAZ.
    IF SY-SUBRC = 0.

      W_OUTTAB-ROUND = W_/ZAK/BEVALLB-ROUND.
*     if not w_/zak/bevallb-round is initial.
      WRITE W_OUTTAB-FIELD_N TO L_ROUND
          ROUND W_/ZAK/BEVALLB-ROUND NO-GROUPING.


*++S4HANA#01.
*      REPLACE ',' WITH '.' INTO L_ROUND.
      REPLACE ',' IN L_ROUND WITH '.' .
*--S4HANA#01.
      W_OUTTAB-FIELD_NR = L_ROUND.

      W_OUTTAB-FIELD_NRK = W_OUTTAB-FIELD_NR *
                           ( 10 ** W_/ZAK/BEVALLB-ROUND ).
*     endif.

      MODIFY I_OUTTAB FROM W_OUTTAB.

    ENDIF.



  ENDLOOP.





ENDFORM.                    " READ_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  update_bevallo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM UPDATE_BEVALLO CHANGING L_SUBRC.
FORM UPDATE_BEVALLO CHANGING L_SUBRC TYPE SY-SUBRC.
*--S4HANA#01.
  DATA: L_COUNT_ERROR TYPE I.

  L_COUNT_ERROR = 0.
  L_SUBRC = 4.

* Deleting any previous saves
  DELETE FROM /ZAK/BEVALLO
     WHERE BUKRS  = P_BUKRS     AND
           BTYPE  = P_BTYPE     AND
           GJAHR  = W_TAB_KEY-GJAHR AND
           MONAT  = W_TAB_KEY-MONAT AND
           ZINDEX = W_TAB_KEY-ZINDEX.

  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.


  SORT I_OUTTAB.
  LOOP AT I_OUTTAB INTO W_OUTTAB
     WHERE BUKRS  = W_TAB_KEY-BUKRS AND
           BTYPE  = W_TAB_KEY-BTYPE AND
           GJAHR  = W_TAB_KEY-GJAHR AND
           MONAT  = W_TAB_KEY-MONAT AND
           ZINDEX = W_TAB_KEY-ZINDEX.


    MOVE-CORRESPONDING W_OUTTAB TO /ZAK/BEVALLO.
    INSERT /ZAK/BEVALLO.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.
      L_COUNT_ERROR = L_COUNT_ERROR + 1.
    ENDIF.
  ENDLOOP.

  IF L_COUNT_ERROR > 0.
    DELETE FROM /ZAK/BEVALLO
      WHERE BUKRS = P_BUKRS  AND
            BTYPE = P_BTYPE  AND
            GJAHR  = W_TAB_KEY-GJAHR AND
            MONAT  = W_TAB_KEY-MONAT AND
            ZINDEX = W_TAB_KEY-ZINDEX.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
    L_SUBRC = 4.
  ELSE.
    L_SUBRC = 0.
  ENDIF.

ENDFORM.                    " update_bevallo
*&---------------------------------------------------------------------*
*&      Form  STATUS_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM STATUS_UPDATE USING $FLAG.
FORM STATUS_UPDATE USING $FLAG TYPE CLIKE.
*--S4HANA#01.


* /ZAK/BEVALLSZ
  UPDATE /ZAK/BEVALLSZ SET FLAG = $FLAG
                          DATUM = SY-DATUM
                          UZEIT = SY-UZEIT
                          UNAME = SY-UNAME
     WHERE BUKRS = P_BUKRS
       AND BTYPE = P_BTYPE
       AND GJAHR  = W_TAB_KEY-GJAHR
*++S4HANA#01.
*       AND MONAT  IN R_MONAT
       AND MONAT  IN GT_MONAT
*--S4HANA#01.
       AND ZINDEX = W_TAB_KEY-ZINDEX.

  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

* /ZAK/BEVALLI
  UPDATE /ZAK/BEVALLI SET FLAG = $FLAG
                         DWNDT = SY-DATUM
                         DATUM = SY-DATUM
                         UZEIT = SY-UZEIT
                         UNAME = SY-UNAME
     WHERE BUKRS = P_BUKRS
       AND BTYPE = P_BTYPE
       AND GJAHR  = W_TAB_KEY-GJAHR
*++S4HANA#01.
*       AND MONAT  IN R_MONAT
       AND MONAT  IN GT_MONAT
*--S4HANA#01.
       AND ZINDEX = W_TAB_KEY-ZINDEX.

  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " STATUS_UPDATE
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_BEVALL USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                          $BTYPE LIKE /ZAK/BEVALL-BTYPE.
*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALL.
  CLEAR I_/ZAK/BEVALL[].
*--S4HANA#01.

*++S4HANA#01.
*  SELECT * INTO TABLE I_/ZAK/BEVALL FROM /ZAK/BEVALL
*      WHERE BUKRS EQ $BUKRS AND
*            BTYPE EQ $BTYPE.
  SELECT DATBI DATAB BTYPART BIDOSZ
    INTO CORRESPONDING FIELDS OF TABLE I_/ZAK/BEVALL FROM /ZAK/BEVALL
      WHERE BUKRS EQ $BUKRS AND
            BTYPE EQ $BTYPE
      ORDER BY PRIMARY KEY.
*--S4HANA#01.

*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALLT.
*
*  SELECT * INTO TABLE I_/ZAK/BEVALLT FROM /ZAK/BEVALLT
*      WHERE BUKRS EQ $BUKRS AND
*            BTYPE EQ $BTYPE.
  CLEAR I_/ZAK/BEVALLT[].

  SELECT @SPACE FROM /ZAK/BEVALLT
      WHERE BUKRS EQ @$BUKRS AND
            BTYPE EQ @$BTYPE INTO TABLE @I_/ZAK/BEVALLT.
*--S4HANA#01.
ENDFORM.                    " READ_BEVALL
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_BEVALLC USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                           $BTYPE LIKE /ZAK/BEVALL-BTYPE.
*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALLC.
  CLEAR I_/ZAK/BEVALLC[].
*--S4HANA#01.

*++S4HANA#01.
*  SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
*      WHERE BTYPE EQ $BTYPE.
  SELECT @SPACE FROM /ZAK/BEVALLC
      WHERE BTYPE EQ @$BTYPE INTO TABLE @I_/ZAK/BEVALLC.
*--S4HANA#01.
ENDFORM.                    " READ_BEVALLC
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_BEVALLD USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                           $BTYPE LIKE /ZAK/BEVALL-BTYPE.
*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALLD.
  CLEAR I_/ZAK/BEVALLD[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLD FROM /ZAK/BEVALLD
      WHERE BUKRS EQ $BUKRS AND
            BTYPE EQ $BTYPE. " and
*            bsznum eq p_bsznum.

*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALLDT.
*
*  SELECT * INTO TABLE I_/ZAK/BEVALLDT FROM /ZAK/BEVALLDT
*      WHERE BUKRS EQ $BUKRS AND
*            BTYPE EQ $BTYPE. " and
**            bsznum eq p_bsznum.
  CLEAR I_/ZAK/BEVALLDT[].

  SELECT @SPACE FROM /ZAK/BEVALLDT
      WHERE BUKRS EQ @$BUKRS AND
            BTYPE EQ @$BTYPE INTO TABLE @I_/ZAK/BEVALLDT.
*--S4HANA#01.
ENDFORM.                    " READ_BEVALLD
*&---------------------------------------------------------------------*
*&      Form  read_bevallo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_BEVALLO USING    $BUKRS LIKE /ZAK/BEVALL-BUKRS
                           $BTYPE LIKE /ZAK/BEVALL-BTYPE.
*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALLO.
  CLEAR I_/ZAK/BEVALLO[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLO FROM /ZAK/BEVALLO
      WHERE BUKRS EQ $BUKRS AND
            BTYPE EQ $BTYPE
*++S4HANA#01.
      ORDER BY GJAHR MONAT ZINDEX.
*--S4HANA#01.
ENDFORM.                    " read_bevallo
*&---------------------------------------------------------------------*
*&      Form  check_already_closed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO  text
*----------------------------------------------------------------------*
FORM CHECK_ALREADY_CLOSED.

  CLEAR W_/ZAK/BEVALLI.

*++S4HANA#01.
*  SELECT SINGLE * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*     WHERE BUKRS EQ W_TAB_KEY-BUKRS AND
*           BTYPE EQ W_TAB_KEY-BTYPE AND
*           GJAHR EQ W_TAB_KEY-GJAHR AND
*           MONAT IN R_MONAT AND
*           ZINDEX EQ W_TAB_KEY-ZINDEX AND
*           FLAG   EQ 'Z'.
  SELECT * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI UP TO 1 ROWS
     WHERE BUKRS EQ W_TAB_KEY-BUKRS AND
           BTYPE EQ W_TAB_KEY-BTYPE AND
           GJAHR EQ W_TAB_KEY-GJAHR AND
           MONAT IN GT_MONAT AND
           ZINDEX EQ W_TAB_KEY-ZINDEX AND
           FLAG   EQ 'Z'
     ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.
  IF SY-SUBRC EQ 0.
    MESSAGE E055(/ZAK/ZAK) WITH W_/ZAK/BEVALLO-GJAHR
                           W_/ZAK/BEVALLO-MONAT.
  ENDIF.


ENDFORM.                    " check_already_closed
*&---------------------------------------------------------------------*
*&      Form  set_bevalli
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM SET_BEVALLI USING $FLAG.
FORM SET_BEVALLI USING $FLAG TYPE CLIKE..
*--S4HANA#01.

  DATA: W_UPD_BEVALLI  LIKE /ZAK/BEVALLI.

* /zak/bevalli status
  IF NOT I_/ZAK/BEVALLI[] IS INITIAL.
    LOOP AT I_/ZAK/BEVALLI INTO W_UPD_BEVALLI.
      W_UPD_BEVALLI-FLAG  = $FLAG.
      W_UPD_BEVALLI-DATUM = SY-DATUM.
      W_UPD_BEVALLI-UZEIT = SY-UZEIT.
      W_UPD_BEVALLI-UNAME = SY-UNAME.


*++S4HANA#01.
*      SELECT SINGLE * FROM /ZAK/BEVALLI
*    WHERE BUKRS EQ W_UPD_BEVALLI-BUKRS AND
*          BTYPE EQ W_UPD_BEVALLI-BTYPE AND
*          GJAHR EQ W_UPD_BEVALLI-GJAHR AND
*          MONAT EQ W_UPD_BEVALLI-MONAT AND
*          ZINDEX EQ W_UPD_BEVALLI-ZINDEX.
      SELECT SINGLE @SPACE FROM /ZAK/BEVALLI
        WHERE BUKRS EQ @W_UPD_BEVALLI-BUKRS AND
          BTYPE EQ @W_UPD_BEVALLI-BTYPE AND
          GJAHR EQ @W_UPD_BEVALLI-GJAHR AND
          MONAT EQ @W_UPD_BEVALLI-MONAT AND
          ZINDEX EQ @W_UPD_BEVALLI-ZINDEX INTO @/ZAK/BEVALLI.
*--S4HANA#01.
      IF SY-SUBRC EQ 0.
        UPDATE /ZAK/BEVALLI FROM W_UPD_BEVALLI.
      ELSE.
        INSERT INTO /ZAK/BEVALLI VALUES W_UPD_BEVALLI.
      ENDIF.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_bevalli
*&---------------------------------------------------------------------*
*&      Form  get_bevallsz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO  text
*----------------------------------------------------------------------*
FORM GET_BEVALLSZ.

  CHECK NOT I_/ZAK/BEVALLI[] IS INITIAL.

*++S4HANA#01.
*  REFRESH: I_/ZAK/BEVALLSZ.
  CLEAR: I_/ZAK/BEVALLSZ[].
*--S4HANA#01.
  SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
  FOR ALL ENTRIES IN I_/ZAK/BEVALLI
         WHERE  BUKRS EQ I_/ZAK/BEVALLI-BUKRS AND
                BTYPE EQ I_/ZAK/BEVALLI-BTYPE AND
                GJAHR EQ I_/ZAK/BEVALLI-GJAHR AND
*++S4HANA#01.
*                MONAT IN R_MONAT AND
                MONAT IN GT_MONAT AND
*--S4HANA#01.
                ZINDEX EQ I_/ZAK/BEVALLI-ZINDEX AND
*++1465 #11.
*                FLAG  IN ('E','T','B'). " and
                FLAG  IN R_FLAG.
*--1465 #11.
*                bsznum = p_bsznum.

ENDFORM.                    " get_bevallsz
*&---------------------------------------------------------------------*
*&      Form  get_bevalli
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO  text
*----------------------------------------------------------------------*
FORM GET_BEVALLI.

*++S4HANA#01.
*  REFRESH: I_/ZAK/BEVALLI.
  CLEAR: I_/ZAK/BEVALLI[].
*--S4HANA#01.
  SELECT * INTO TABLE I_/ZAK/BEVALLI FROM /ZAK/BEVALLI
     WHERE BUKRS EQ W_TAB_KEY-BUKRS AND
           BTYPE EQ W_TAB_KEY-BTYPE AND
           GJAHR EQ W_TAB_KEY-GJAHR AND
*++S4HANA#01.
*           MONAT IN R_MONAT AND
           MONAT IN GT_MONAT AND
*--S4HANA#01.
           ZINDEX EQ W_TAB_KEY-ZINDEX AND
*++1465 #11.
*           FLAG  IN ('E','T').
           FLAG  IN R_FLAG.
*--1465 #11.

  SORT I_/ZAK/BEVALLI BY BUKRS BTYPE GJAHR MONAT ZINDEX.

ENDFORM.                    " get_bevalli
*&---------------------------------------------------------------------*
*&      Form  set_bevallsz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM SET_BEVALLSZ USING $FLAG.
FORM SET_BEVALLSZ USING $FLAG TYPE CLIKE..
*--S4HANA#01.
  DATA: W_UPD_BEVALLSZ LIKE /ZAK/BEVALLSZ.

* /zak/bevallsz status
  IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
    LOOP AT I_/ZAK/BEVALLSZ INTO W_UPD_BEVALLSZ
                          .
*++S4HANA#01.
*      SELECT SINGLE * FROM /ZAK/BEVALLSZ
      SELECT SINGLE * FROM /ZAK/BEVALLSZ INTO /ZAK/BEVALLSZ
*--S4HANA#01.
    WHERE BUKRS EQ W_UPD_BEVALLSZ-BUKRS AND
          BTYPE EQ W_UPD_BEVALLSZ-BTYPE AND
          BSZNUM EQ W_UPD_BEVALLSZ-BSZNUM AND
          GJAHR EQ W_UPD_BEVALLSZ-GJAHR AND
          MONAT EQ W_UPD_BEVALLSZ-MONAT AND
          ZINDEX EQ W_UPD_BEVALLSZ-ZINDEX AND
          PACK   EQ W_UPD_BEVALLSZ-PACK.
      IF SY-SUBRC EQ 0.
*++S4HANA#01.
*        DELETE /ZAK/BEVALLSZ.
        DELETE /ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ.
*--S4HANA#01.
      ELSE.
        CLEAR W_UPD_BEVALLSZ-PACK.
      ENDIF.
      W_UPD_BEVALLSZ-FLAG = $FLAG.
      W_UPD_BEVALLSZ-DATUM = SY-DATUM.
      W_UPD_BEVALLSZ-UZEIT = SY-UZEIT.
      W_UPD_BEVALLSZ-UNAME = SY-UNAME.
      PERFORM SET_LARUN CHANGING W_UPD_BEVALLSZ-LARUN.
      INSERT INTO /ZAK/BEVALLSZ VALUES W_UPD_BEVALLSZ.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " set_bevallsz
*&---------------------------------------------------------------------*
*&      Form  check_adatszolg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ADATSZOLG.

  LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.
*                        WHERE XSPEC EQ SPACE
*                          and bsznum = p_bsznum.

    READ TABLE I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
    WITH KEY BSZNUM = W_/ZAK/BEVALLD-BSZNUM .
    IF SY-SUBRC NE 0.
*      MESSAGE E102(/zak/zak) WITH w_tab_key-GJAHR
*                             w_tab_key-MONAT
*                             W_/ZAK/BEVALLD-BSZNUM.
*      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " check_adatszolg
*&---------------------------------------------------------------------*
*&      Form  FULL_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/BEVALLI[]  text
*      -->P_I_/ZAK/BEVALLSZ[]  text
*      -->P_I_/ZAK/BEVALLD[]  text
*      -->P_W_/ZAK/BEVALLO_MONAT  text
*      -->P_W_/ZAK/BEVALLO_GJAHR  text
*      -->P_W_/ZAK/BEVALLO_ZINDEX  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM FULL_PERIOD USING    $/ZAK/BEVALLI  LIKE I_/ZAK/BEVALLI
*                          $/ZAK/BEVALLSZ LIKE I_/ZAK/BEVALLSZ
*                          $/ZAK/BEVALLD  LIKE I_/ZAK/BEVALLD
*                          $MONAT
*                          $GJAHR
*                          $ZINDEX LIKE W_/ZAK/BEVALLI-ZINDEX.
FORM FULL_PERIOD USING    $/ZAK/BEVALLD  LIKE I_/ZAK/BEVALLD
                          $MONAT TYPE MONAT
                          $GJAHR TYPE GJAHR
                          $ZINDEX TYPE /ZAK/BEVALLI-ZINDEX
                 CHANGING $/ZAK/BEVALLI  LIKE I_/ZAK/BEVALLI
                          $/ZAK/BEVALLSZ LIKE I_/ZAK/BEVALLSZ.
*--S4HANA#01.
  DATA: L_NUM LIKE W_/ZAK/BEVALLSZ-MONAT.
* Tax return periods
  DATA: SET_BEVI  TYPE STANDARD TABLE OF /ZAK/BEVALLI    INITIAL SIZE 0,
        SET_BEVSZ TYPE STANDARD TABLE OF /ZAK/BEVALLSZ  INITIAL SIZE 0.

*++S4HANA#01.
*  REFRESH: SET_BEVI,SET_BEVSZ.
  CLEAR: SET_BEVI[].
  CLEAR: SET_BEVSZ[].
*--S4HANA#01.
  CLEAR: L_NUM.
  SORT $/ZAK/BEVALLI BY GJAHR MONAT ZINDEX DESCENDING.
  LOOP AT $/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.
    DO 12 TIMES.
*++S4HANA#01.
*      L_NUM = R_MONAT-LOW + SY-INDEX - 1.
*      IF L_NUM > R_MONAT-HIGH.
      L_NUM = GS_MONAT-LOW + SY-INDEX - 1.
      IF L_NUM > GS_MONAT-HIGH.
*--S4HANA#01.
        CLEAR: L_NUM.
        EXIT.
      ENDIF.
      READ TABLE $/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
                 WITH KEY BSZNUM = W_/ZAK/BEVALLD-BSZNUM
                 GJAHR = $GJAHR
                 MONAT = L_NUM.
      IF SY-SUBRC NE 0.
* There is no return for the data provision period so I lock it!
        MOVE-CORRESPONDING W_/ZAK/BEVALLD TO W_/ZAK/BEVALLSZ.
        W_/ZAK/BEVALLSZ-ZINDEX = $ZINDEX.
        W_/ZAK/BEVALLSZ-MONAT = L_NUM.
        MOVE-CORRESPONDING W_/ZAK/BEVALLSZ TO W_/ZAK/BEVALLI.
        W_/ZAK/BEVALLI-MONAT = L_NUM.
        APPEND W_/ZAK/BEVALLSZ TO SET_BEVSZ.
        APPEND W_/ZAK/BEVALLI TO SET_BEVI.
      ENDIF.
    ENDDO.
  ENDLOOP.
  APPEND LINES OF SET_BEVI TO $/ZAK/BEVALLI.
  APPEND LINES OF SET_BEVSZ TO $/ZAK/BEVALLSZ.
  SORT $/ZAK/BEVALLI BY BUKRS BTYPE GJAHR MONAT.
  DELETE ADJACENT DUPLICATES FROM $/ZAK/BEVALLI
                        COMPARING BUKRS BTYPE GJAHR MONAT.


ENDFORM.                    " FULL_PERIOD
*&---------------------------------------------------------------------*
*&      Form  delete_bevallo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM DELETE_BEVALLO CHANGING $SUBRC.
FORM DELETE_BEVALLO CHANGING $SUBRC TYPE SY-SUBRC..
*--S4HANA#01.

  DELETE FROM /ZAK/BEVALLO
     WHERE BUKRS = P_BUKRS AND
           BTYPE = P_BTYPE.
  $SUBRC = SY-SUBRC.
ENDFORM.                    " delete_bevallo
*&---------------------------------------------------------------------*
*&      Form  delete_analitika
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM DELETE_ANALITIKA CHANGING $SUBRC.
FORM DELETE_ANALITIKA CHANGING $SUBRC  TYPE SY-SUBRC..
*--S4HANA#01.

  DELETE FROM /ZAK/ANALITIKA
     WHERE BUKRS = P_BUKRS AND
           BTYPE = P_BTYPE.
  $SUBRC = SY-SUBRC.
ENDFORM.                    " delete_analitika
*&---------------------------------------------------------------------*
*&      Form  delete_bevallsz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM DELETE_BEVALLSZ CHANGING $SUBRC.
FORM DELETE_BEVALLSZ CHANGING $SUBRC  TYPE SY-SUBRC..
*--S4HANA#01.

  DELETE FROM /ZAK/BEVALLSZ
     WHERE BUKRS = P_BUKRS AND
           BTYPE = P_BTYPE.
  $SUBRC = SY-SUBRC.
ENDFORM.                    " delete_bevallsz
*&---------------------------------------------------------------------*
*&      Form  delete_bevalli
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM DELETE_BEVALLI CHANGING $SUBRC.
FORM DELETE_BEVALLI CHANGING $SUBRC  TYPE SY-SUBRC..
*--S4HANA#01.

  DELETE FROM /ZAK/BEVALLI
     WHERE BUKRS = P_BUKRS AND
           BTYPE = P_BTYPE.
  $SUBRC = SY-SUBRC.
ENDFORM.                    " delete_bevalli
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1019   text
*      -->P_1020   text
*      -->P_W_/ZAK/ANALITIKA_MONAT  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM SET_RANGES USING    $TOL
*                         $IG
*                         $ANALITIKA_MON.
FORM SET_RANGES USING    $TOL TYPE CLIKE
                         $IG TYPE CLIKE
                         $ANALITIKA_MON TYPE MONAT.
*--S4HANA#01.

*++S4HANA#01.
*  REFRESH R_MONAT.
*  R_MONAT-SIGN   = 'I'.
  CLEAR GT_MONAT[].
  GS_MONAT-SIGN   = 'I'.
*--S4HANA#01.
  IF $TOL = $IG.
*++S4HANA#01.
*    R_MONAT-OPTION = 'EQ'.
*    R_MONAT-LOW    = $ANALITIKA_MON.
*    R_MONAT-HIGH   = $ANALITIKA_MON.
    GS_MONAT-OPTION = 'EQ'.
    GS_MONAT-LOW    = $ANALITIKA_MON.
    GS_MONAT-HIGH   = $ANALITIKA_MON.
*--S4HANA#01.
  ELSE.
*++S4HANA#01.
*    R_MONAT-OPTION = 'BT'.
*    R_MONAT-LOW    = $TOL.
*    R_MONAT-HIGH   = $IG.
    GS_MONAT-OPTION = 'BT'.
    GS_MONAT-LOW    = $TOL.
    GS_MONAT-HIGH   = $IG.
*--S4HANA#01.
  ENDIF.
*++S4HANA#01.
*  APPEND R_MONAT.
  APPEND GS_MONAT TO GT_MONAT.
*--S4HANA#01.
ENDFORM.                    " SET_RANGES
*&---------------------------------------------------------------------*
*&      Form  fill_range
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_RANGE.

*  describe table i_/zak/bevall lines sy-tfill.
*  read table i_/zak/bevall into w_/zak/bevall index sy-tfill.
  DATA: L_DATUM TYPE D.
  L_DATUM(4)   = W_TAB_KEY-GJAHR.
  L_DATUM+4(2) = W_TAB_KEY-MONAT.
  L_DATUM+6(2) = '01'.
  ADD 31 TO L_DATUM. L_DATUM+6(2) = '01'. SUBTRACT 1 FROM L_DATUM.
  LOOP AT I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
    WHERE DATAB <= L_DATUM AND DATBI >= L_DATUM.
    EXIT.
  ENDLOOP.

  CHECK SY-SUBRC = 0.

* ...quarterly
  IF W_/ZAK/BEVALL-BIDOSZ = 'N'.
    CASE W_TAB_KEY-MONAT.
      WHEN '01' OR '02' OR '03'.
        PERFORM SET_RANGES USING '01'
                                 '03'
                                 W_TAB_KEY-MONAT.
        IF W_TAB_KEY-MONAT NE '03'.
          MESSAGE E063(/ZAK/ZAK) WITH P_BUKRS P_BTYPE '03'.
        ENDIF.
      WHEN '04' OR '05' OR '06'.
        PERFORM SET_RANGES USING '04'
                                 '06'
                                 W_TAB_KEY-MONAT.
        IF W_TAB_KEY-MONAT NE '06'.
          MESSAGE E063(/ZAK/ZAK) WITH P_BUKRS P_BTYPE '06'.
        ENDIF.
      WHEN '07' OR '08' OR '09'.
        PERFORM SET_RANGES USING '07'
                                 '09'
                                 W_TAB_KEY-MONAT.
        IF W_TAB_KEY-MONAT NE '09'.
          MESSAGE E063(/ZAK/ZAK) WITH P_BUKRS P_BTYPE '09'.
        ENDIF.

      WHEN '10' OR '11' OR '12'.
        PERFORM SET_RANGES USING '10'
                                 '12'
                                 W_TAB_KEY-MONAT.
        IF W_TAB_KEY-MONAT NE '12'.
          MESSAGE E063(/ZAK/ZAK) WITH P_BUKRS P_BTYPE '12'.
        ENDIF.
    ENDCASE.
* ...annual
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'E'.
    PERFORM SET_RANGES USING '01'
                             '12'
                             W_TAB_KEY-MONAT.
    IF W_TAB_KEY-MONAT NE '12'.
      MESSAGE E064(/ZAK/ZAK) WITH P_BUKRS P_BTYPE '12'.
    ENDIF.
* ...havi
  ELSEIF W_/ZAK/BEVALL-BIDOSZ = 'H'.
    PERFORM SET_RANGES USING '01'
                             '01'
                             W_TAB_KEY-MONAT.
  ENDIF.

ENDFORM.                    " fill_range
*&---------------------------------------------------------------------*
*&      Form  SET_LARUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_W_UPD_BEVALLSZ_LARUN  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM SET_LARUN CHANGING $LARUN.
FORM SET_LARUN CHANGING $LARUN TYPE /ZAK/BEVALLSZ-LARUN.
*--S4HANA#01.
  DATA: L_STAMP LIKE  TZONREF-TSTAMPS.
  CLEAR L_STAMP.
* Last run time - timestamp /ZAK/BEVALLSZ-LARUN
  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      I_DATLO     = SY-DATLO
      I_TIMLO     = SY-TIMLO
    IMPORTING
      E_TIMESTAMP = L_STAMP.
  $LARUN = L_STAMP.
ENDFORM.                    " SET_LARUN
*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  CALL SCREEN 9000.
ENDFORM.                    " list_display
*&---------------------------------------------------------------------*
*&      Module  pbo_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_9000 OUTPUT.
  PERFORM SET_STATUS.

  IF V_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV CHANGING I_OUT[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.

  ENDIF.


ENDMODULE.                 " pbo_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_STATUS.

  SET PF-STATUS 'MAIN9000'.
  SET TITLEBAR 'MAIN9000'.

ENDFORM.                    " SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUT[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING PT_OUTTAB   LIKE I_OUT[]
                                  PT_FIELDCAT TYPE LVC_T_FCAT
                                  PS_LAYOUT   TYPE LVC_S_LAYO
                                  PS_VARIANT  TYPE DISVARIANT.

  DATA: I_EXCLUDE TYPE UI_FUNCTIONS.
  CREATE OBJECT V_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER.

* Building the field catalog
  PERFORM BUILD_FIELDCAT CHANGING PT_FIELDCAT.


  PS_LAYOUT-CWIDTH_OPT = C_X.
  PS_LAYOUT-EXCP_FNAME = 'LIGHT'.

  IF P_CR = 'X'.
    PS_LAYOUT-GRID_TITLE = 'Elkészült bevallások'.
  ELSEIF P_CL = 'X'.
    PS_LAYOUT-GRID_TITLE = 'Lezárt bevallások'.
  ENDIF.

  CLEAR PS_VARIANT.
  PS_VARIANT-REPORT = V_REPID.

  SORT PT_OUTTAB.

  CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = PS_VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = C_X
      IS_LAYOUT            = PS_LAYOUT
      IT_TOOLBAR_EXCLUDING = I_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = PT_FIELDCAT
      IT_OUTTAB            = PT_OUTTAB.

ENDFORM.                    " CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_DYNNR  text
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      I_STRUCTURE_NAME       = '/ZAK/ALV_MIGR'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
    CHANGING
      CT_FIELDCAT            = PT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  pai_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_9000 INPUT.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.

* Back
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

* Exit
    WHEN 'EXIT'.
      LEAVE PROGRAM.

    WHEN OTHERS.
*     do nothing
  ENDCASE.
ENDMODULE.                 " pai_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  delete_bset
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM DELETE_BSET.

  DELETE FROM /ZAK/BSET
     WHERE BUKRS = P_BUKRS.

ENDFORM.                    " delete_bset
*++1465 #11.
*&---------------------------------------------------------------------*
*&      Form  GET_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_FLAG  USING    $BUKRS
*                        $BTYPE.
FORM GET_FLAG  USING    $BUKRS TYPE /ZAK/BEVALL-BUKRS
                        $BTYPE TYPE /ZAK/BEVALL-BTYPE.
*--S4HANA#01.

  DATA L_BTYPART TYPE /ZAK/BTYPART.

  CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
    EXPORTING
      I_BUKRS       = $BUKRS
      I_BTYPE       = $BTYPE
    IMPORTING
      E_BTYPART     = L_BTYPART
    EXCEPTIONS
      ERROR_IMP_PAR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  M_DEF R_FLAG 'I' 'EQ' 'E' SPACE.
  M_DEF R_FLAG 'I' 'EQ' 'T' SPACE.
  M_DEF R_FLAG 'I' 'EQ' 'B' SPACE.

* For ONYB you can also close the F.
  IF L_BTYPART EQ C_BTYPART_ONYB.
    M_DEF R_FLAG 'I' 'EQ' 'F' SPACE.
  ENDIF.



ENDFORM.                    " GET_FLAG
*--1465 #11.
