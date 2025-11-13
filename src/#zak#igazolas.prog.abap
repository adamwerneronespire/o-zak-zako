*&---------------------------------------------------------------------*
*& Program: Issuing certificates for private individuals
*&---------------------------------------------------------------------*
REPORT  /ZAK/IGAZOLAS  MESSAGE-ID /ZAK/ZAK
                             LINE-SIZE  255
                             LINE-COUNT 65.
*&---------------------------------------------------------------------*
*& Function description: Based on the upload identifier(s), the program selects
*& the relevant data and generates the certificate using a SMARTFORMS form
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2008.02.28
*& Functional spec   : Róth Nándor
*& SAP modul neve    : ADO
*& Program type      : Report
*& SAP version       : 46C
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (write the OSS note number at the end of the changed lines)*
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2008.11.14   Balázs Gábor  Sequence number creation per company,
*&                                   setting the date on the selection screen
*& 0002   2009.02.27   Balázs Gábor  Passing BTYPE to smartforms
*& 0003   2009.03.03   Balázs Gábor  Position introduction (multiple ABEVAZ
*&                                   in one row)
*& 0004   2009.09.09   Balázs Gábor  Summary correction (multiple BSZNUM
*&                                   due to multiple retrieval).
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.

*Data declaration
INCLUDE /ZAK/IGTOP.
*Common routines
INCLUDE /ZAK/IGF01.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table       -   (I_xxx...)                              *
*      FORM parameter       -   ($xxxx...)                              *
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
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*Form name:
PARAMETERS P_FNAME LIKE SSFSCREEN-FNAME DEFAULT '/ZAK/MG_IGAZOLAS'
                                        MODIF ID DIS.
*Company
PARAMETERS P_BUKRS LIKE T001-BUKRS OBLIGATORY MEMORY ID BUK.
*Return type:
PARAMETERS P_BTYPE LIKE /ZAK/BEVALLB-BTYPE OBLIGATORY.
*Data reporting identifiers:
SELECT-OPTIONS S_BSZNUM FOR /ZAK/BEVALLD-BSZNUM.
*++0001 2008.11.14 BG
*Date
PARAMETERS P_DATUM LIKE SY-DATUM DEFAULT SY-DATUM OBLIGATORY.
*--0001 2008.11.14 BG
*Test run
PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.
*List output
PARAMETERS P_LIST AS CHECKBOX DEFAULT 'X'.
*++0001 2008.12.01 (BG)
*Spool control in the background
PARAMETERS P_SPOOL AS CHECKBOX DEFAULT 'X'.
*--0001 2008.12.01 (BG)
*++2008 #12.
PARAMETERS P_EVES AS CHECKBOX DEFAULT ''.
*--2008 #12.
SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  G_REPID = SY-REPID.
*++1765 #19.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2165 #03.
*                   ID 'TCD'  FIELD SY-TCODE.
                   ID 'TCD'  FIELD '/ZAK/IGAZOLAS'.
*--2165 #03.
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
  PERFORM MODIF_SCREEN.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*

* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Determine the type of return
  CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
    EXPORTING
      I_BUKRS       = P_BUKRS
      I_BTYPE       = P_BTYPE
    IMPORTING
      E_BTYPART     = G_BTYPART
    EXCEPTIONS
      ERROR_IMP_PAR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*  Authorization check
  PERFORM AUTHORITY_CHECK USING
                                P_BUKRS
                                G_BTYPART
                                C_ACTVT_01.


  PERFORM MESSAGES_INITIALIZE.

* Collect data reporting identifiers:
  PERFORM GET_BSZNUM TABLES S_BSZNUM
                            R_BSZNUM
                            I_BSZNUMT
                     USING  P_BUKRS
                            P_BTYPE.
  IF R_BSZNUM[] IS INITIAL.
    MESSAGE E255.
*   No upload identifier requiring a certificate is configured!
  ENDIF.

* Determine settings
  PERFORM GET_IGABEV TABLES I_/ZAK/IGABEV
                            I_/ZAK/IGSOR
                            I_/ZAK/IGSORT
                            R_BSZNUM
                     USING  P_BUKRS
                            P_BTYPE.
  IF I_/ZAK/IGABEV[] IS INITIAL.
    MESSAGE E256 WITH P_BUKRS.
*   No settings found for company & for the certificate data!
  ENDIF.

* Collect upload identifiers
  PERFORM GET_PACK TABLES R_BSZNUM
                          R_PACK
                   USING  P_BUKRS
                          P_BTYPE.
  IF R_PACK[] IS INITIAL.
    MESSAGE I031.
*   The database does not contain any records to process!
    EXIT.
  ENDIF.


* Collect data
  PERFORM COLLECT_DATA TABLES I_/ZAK/IGABEV
                              I_/ZAK/ANALITIKA
                              I_/ZAK/MGCIM
                              R_PACK
                              R_ADOAZON
                              I_PACK
                       USING  P_BUKRS
                              P_BTYPE.
  IF I_/ZAK/ANALITIKA[] IS INITIAL.
    MESSAGE I031.
*   The database does not contain any records to process!
    EXIT.
  ENDIF.

* Process data
  PERFORM PROCESS_DATA TABLES I_/ZAK/ANALITIKA
                              I_/ZAK/IGABEV
                              I_/ZAK/IGDATA
                              I_/ZAK/IGDATA_ALV
                              I_/ZAK/IGSOR
                              I_/ZAK/IGSORT
                              I_WAERST
                              I_BSZNUM_SORSZ
                              R_ADOAZON
                              R_PACK
                              I_PACK
                       USING  P_BUKRS
                              P_BTYPE
                              P_TEST
*++0001 2008.11.14 BG
                              P_DATUM
*--0001 2008.11.14 BG
                              .

* Display messages
  PERFORM SHOW_MESSAGES USING G_INDEX
                              P_TEST.

* Productive run form printing, data modification
  PERFORM PRODUCTIVE_RUN TABLES I_/ZAK/MGCIM
                                I_/ZAK/IGDATA
                                I_/ZAK/IGABEV
                                I_/ZAK/IGSORT
                                I_SMART_DATA
                                I_BSZNUMT
                                I_WAERST
                                R_ADOAZON
                                R_PACK
                         USING  P_BUKRS

                                P_TEST
                                P_FNAME
*++0001 2008.11.14 BG
                                P_DATUM
                                P_SPOOL
*--0001 2008.11.14 BG
*++2008 #12.
                                P_EVES
*--2008 #12.
                                .

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

* Lista kivitel
  PERFORM LIST_DISPLAY.



*&---------------------------------------------------------------------*
*&      Form  GET_BSZNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_BUKRS  text
*      -->P_S_BSZNUM  text
*      -->P_R_BSZNUM  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM GET_BSZNUM  TABLES   $S_BSZNUM STRUCTURE S_BSZNUM
                          $R_BSZNUM STRUCTURE R_BSZNUM
                          $I_BSZNUMT LIKE I_BSZNUMT
                 USING    $BUKRS
                          $BTYPE.

  DATA L_BSZNUM TYPE /ZAK/BSZNUM.
  DATA L_SZTEXT TYPE /ZAK/SZTEXT.


  REFRESH $R_BSZNUM.

  SELECT  /ZAK/BEVALLD~BSZNUM
          /ZAK/BEVALLDT~SZTEXT
          INTO (L_BSZNUM, L_SZTEXT)
                FROM /ZAK/BEVALLD INNER JOIN /ZAK/BEVALLDT
                  ON /ZAK/BEVALLDT~LANGU  = SY-LANGU
                 AND /ZAK/BEVALLDT~BUKRS  = /ZAK/BEVALLD~BUKRS
                 AND /ZAK/BEVALLDT~BTYPE  = /ZAK/BEVALLD~BTYPE
                 AND /ZAK/BEVALLDT~BSZNUM = /ZAK/BEVALLD~BSZNUM
               WHERE /ZAK/BEVALLD~BUKRS  EQ $BUKRS
                 AND /ZAK/BEVALLD~BTYPE  EQ $BTYPE
                 AND /ZAK/BEVALLD~BSZNUM IN $S_BSZNUM
                 AND /ZAK/BEVALLD~MGIF   EQ C_ON.
    M_DEF $R_BSZNUM 'I' 'EQ' L_BSZNUM SPACE.
    CLEAR W_BSZNUMT.
    MOVE  L_BSZNUM TO W_BSZNUMT-BSZNUM.
    MOVE  L_SZTEXT TO W_BSZNUMT-SZTEXT.
    APPEND W_BSZNUMT TO $I_BSZNUMT.
  ENDSELECT.

  SORT $I_BSZNUMT.


ENDFORM.                    " GET_BSZNUM
*&---------------------------------------------------------------------*
*&      Form  GET_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_R_BSZNUM  text
*      -->P_R_PACK  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM GET_PACK  TABLES   $R_BSZNUM STRUCTURE R_BSZNUM
                        $R_PACK   STRUCTURE R_PACK
               USING    $BUKRS
                        $BTYPE.

  DATA L_PACK TYPE /ZAK/PACK.

  SELECT /ZAK/BEVALLSZ~PACK
         INTO L_PACK
         FROM /ZAK/BEVALLSZ INNER JOIN /ZAK/BEVALLP
              ON /ZAK/BEVALLP~BUKRS = /ZAK/BEVALLSZ~BUKRS
             AND /ZAK/BEVALLP~PACK  = /ZAK/BEVALLSZ~PACK
             AND /ZAK/BEVALLP~MGIF  = ''
         WHERE /ZAK/BEVALLSZ~BUKRS = $BUKRS
           AND /ZAK/BEVALLSZ~BTYPE = $BTYPE
           AND /ZAK/BEVALLSZ~BSZNUM IN $R_BSZNUM.
    M_DEF $R_PACK 'I' 'EQ' L_PACK SPACE.
  ENDSELECT.

  SORT $R_PACK.
  DELETE ADJACENT DUPLICATES FROM $R_PACK.


ENDFORM.                    " GET_PACK
*&---------------------------------------------------------------------*
*&      Form  COLLECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COLLECT_DATA TABLES $I_/ZAK/IGABEV    STRUCTURE /ZAK/IGABEV
                         $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                         $I_/ZAK/MGCIM     STRUCTURE /ZAK/MGCIM
                         $R_PACK          STRUCTURE R_PACK
                         $R_ADOAZON       STRUCTURE R_ADOAZON
                         $I_PACK          LIKE      I_PACK
                  USING  $BUKRS
                         $BTYPE.


  RANGES LR_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.


  LOOP AT $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV WHERE NOT ABEVAZ IS INITIAL.
    M_DEF LR_ABEVAZ 'I' 'EQ' W_/ZAK/IGABEV-ABEVAZ SPACE.
  ENDLOOP.

* We collect the relevant ABEV identifiers
  SELECT * INTO TABLE $I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ $BUKRS
            AND BTYPE EQ $BTYPE
            AND ABEVAZ IN LR_ABEVAZ
            AND PACK IN $R_PACK
*++2108 #21.
            AND STAPO EQ ''.
*--2108 #21.
  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

* Collect tax numbers
  REFRESH $R_ADOAZON.

  LOOP AT $I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
    M_DEF $R_ADOAZON 'I' 'EQ' W_/ZAK/ANALITIKA-ADOAZON SPACE.
*   Collect upload identifiers by period.
    CLEAR W_PACK.
    MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_PACK.
*++2008 #12.
    IF NOT P_EVES IS INITIAL.
      W_PACK-MONAT = 12.
      W_/ZAK/ANALITIKA-MONAT = 12.
      MODIFY $I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING MONAT.
    ENDIF.
*--2008 #12.
    COLLECT W_PACK INTO $I_PACK.
  ENDLOOP.

* Sort upload identifiers
  SORT $I_PACK.
  DELETE ADJACENT DUPLICATES FROM $I_PACK.

* Sort tax identifiers
  SORT $R_ADOAZON.
  DELETE ADJACENT DUPLICATES FROM $R_ADOAZON.

  LOOP AT $R_ADOAZON.
*   Determine the address data
    SELECT  * APPENDING TABLE $I_/ZAK/MGCIM
             FROM /ZAK/MGCIM
            WHERE ADOAZON EQ $R_ADOAZON-LOW.
    IF SY-SUBRC NE 0.
*   Address data for tax identifier & not found!
      PERFORM MESSAGE_STORE USING G_INDEX
                                  'E'
                                  '/ZAK/ZAK'
                                  '258'
                                  R_ADOAZON-LOW
                                  SY-MSGV2
                                  SY-MSGV3
                                  SY-MSGV4.
    ENDIF.
  ENDLOOP.

  SORT $I_/ZAK/MGCIM.

ENDFORM.                    " COLLECT_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_IGABEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/IGABEV  text
*      -->P_R_BSZNUM  text
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM GET_IGABEV  TABLES  $I_/ZAK/IGABEV STRUCTURE /ZAK/IGABEV
                         $I_/ZAK/IGSOR  STRUCTURE /ZAK/IGSOR
                         $I_/ZAK/IGSORT STRUCTURE /ZAK/IGSORT
                         $R_BSZNUM     STRUCTURE R_BSZNUM
                 USING   $BUKRS
                         $BTYPE.

  SELECT * INTO TABLE $I_/ZAK/IGABEV
           FROM /ZAK/IGABEV
          WHERE BUKRS EQ $BUKRS
            AND BTYPE EQ $BTYPE
            AND BSZNUM IN $R_BSZNUM.
*++0003 2009.03.03 BG
* SORT $I_/ZAK/IGABEV BY BSZNUM TYPE SORREND.
  SORT $I_/ZAK/IGABEV BY BSZNUM TYPE SORREND POZICIO.
*--0003 2009.03.03 BG


  LOOP AT $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV.

    SELECT SINGLE * INTO W_/ZAK/IGSOR
            FROM /ZAK/IGSOR
           WHERE IGAZON EQ W_/ZAK/IGABEV-IGAZON.
    IF SY-SUBRC EQ 0.
      APPEND W_/ZAK/IGSOR TO $I_/ZAK/IGSOR.
    ELSE.
*& Certificate line identifier data not found!
      PERFORM MESSAGE_STORE USING G_INDEX
                                  'E'
                                  '/ZAK/ZAK'
                                  '266'
                                  W_/ZAK/IGABEV-IGAZON
                                  SY-MSGV2
                                  SY-MSGV3
                                  SY-MSGV4.

    ENDIF.

    SELECT SINGLE * INTO W_/ZAK/IGSORT
            FROM /ZAK/IGSORT
           WHERE LANGU  EQ SY-LANGU
             AND IGAZON EQ W_/ZAK/IGABEV-IGAZON.
    IF SY-SUBRC EQ 0.
      APPEND W_/ZAK/IGSORT TO $I_/ZAK/IGSORT.
    ELSE.
*& Certificate line identifier text data not found!
      PERFORM MESSAGE_STORE USING G_INDEX
                                  'E'
                                  '/ZAK/ZAK'
                                  '264'
                                  W_/ZAK/IGABEV-IGAZON
                                  SY-MSGV2
                                  SY-MSGV3
                                  SY-MSGV4.
    ENDIF.
  ENDLOOP.

  SORT $I_/ZAK/IGSORT.

ENDFORM.                    " GET_IGABEV


*&---------------------------------------------------------------------*
*&      Form  MESSAGES_INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MESSAGES_INITIALIZE.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

ENDFORM.                    " messages_initialize

*&---------------------------------------------------------------------*
*&      Form  message_store
*&---------------------------------------------------------------------*
FORM MESSAGE_STORE USING    $ZEILE
                            $MSGTY
                            $MSGID
                            $MSGNO
                            $VAR1
                            $VAR2
                            $VAR3
                            $VAR4.

  DATA: L_MSG TYPE SMESG.

  CLEAR L_MSG.
  ADD 1 TO $ZEILE.
  L_MSG-ARBGB = $MSGID.
  L_MSG-MSGTY = $MSGTY.
  L_MSG-ZEILE = $ZEILE.
  L_MSG-MSGV1 = $VAR1.
  L_MSG-MSGV2 = $VAR2.
  L_MSG-MSGV3 = $VAR3.
  L_MSG-MSGV4 = $VAR4.
  L_MSG-TXTNR = $MSGNO.

  CALL FUNCTION 'MESSAGE_STORE'
    EXPORTING
      ARBGB                  = L_MSG-ARBGB
*     EXCEPTION_IF_NOT_ACTIVE       = 'X'
      MSGTY                  = L_MSG-MSGTY
      MSGV1                  = L_MSG-MSGV1
      MSGV2                  = L_MSG-MSGV2
      MSGV3                  = L_MSG-MSGV3
      MSGV4                  = L_MSG-MSGV4
      TXTNR                  = L_MSG-TXTNR
      ZEILE                  = L_MSG-ZEILE
    EXCEPTIONS
      MESSAGE_TYPE_NOT_VALID = 1
      NOT_ACTIVE             = 2
      OTHERS                 = 3.

ENDFORM.                    " message_store

*&---------------------------------------------------------------------*
*&      Form  show_messages
*&---------------------------------------------------------------------*
FORM SHOW_MESSAGES USING $INDEX
                         $TEST.

  IF NOT $INDEX IS INITIAL.
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        OBJECT     = 'Üzenetek'(001)
        I_USE_GRID = 'X'.
  ELSEIF NOT $TEST IS INITIAL.
    MESSAGE I257.
*   Processing does not contain any errors!
  ENDIF.

ENDFORM.                    " show_messages
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA TABLES $I_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                         $I_/ZAK/IGABEV    STRUCTURE /ZAK/IGABEV
                         $I_/ZAK/IGDATA    STRUCTURE /ZAK/IGDATA
                         $I_/ZAK/IGDATA_ALV STRUCTURE /ZAK/IGDATA_ALV
                         $I_/ZAK/IGSOR     STRUCTURE /ZAK/IGSOR
                         $I_/ZAK/IGSORT    STRUCTURE /ZAK/IGSORT
                         $I_WAERST        LIKE I_WAERST
                         $I_BSZNUM_SORSZ  LIKE I_BSZNUM_SORSZ
                         $R_ADOAZON       STRUCTURE R_ADOAZON
                         $R_PACK          STRUCTURE R_PACK
                         $I_PACK          LIKE I_PACK
                  USING  $BUKRS
                         $BTYPE
                         $TEST
*++0001 2008.11.14 BG
                         $DATUM
*--0001 2008.11.14 BG
                         .

  DATA LW_SUM_LINE TYPE /ZAK/IGDATA.
  DATA L_TABIX LIKE SY-TABIX.
* Collect data
  TYPES: BEGIN OF LT_DATA,
           BUKRS   TYPE BUKRS,
           BTYPE   TYPE /ZAK/BTYPE,
           ADOAZON TYPE /ZAK/ADOAZON,
           GJAHR   TYPE GJAHR,
           MONAT   TYPE MONAT,
           BSZNUM  TYPE /ZAK/BSZNUM,
           SORSZ   TYPE /ZAK/SORSZ,
           WAERS   TYPE WAERS,
         END OF LT_DATA.

  DATA LI_DATA TYPE LT_DATA OCCURS 0 WITH HEADER LINE.
  DATA L_DATUM LIKE SY-DATUM.
  DATA L_FIRST.
  DATA L_SORSZ LIKE /ZAK/IGDATA-SORSZ.
  RANGES LR_SORSZ FOR /ZAK/IGDATA-SORSZ.

  DEFINE LM_SIGN.
    IF &2 EQ '-'.
      MULTIPLY &1 BY -1.
    ENDIF.
  END-OF-DEFINITION.

  DEFINE LM_FORMAT_FIELD.
    CASE &1.
      WHEN C_FORM_D.
        MOVE &2 TO L_DATUM.
        CLEAR &2.
        WRITE L_DATUM TO &2 LEFT-JUSTIFIED.
    ENDCASE.

  END-OF-DEFINITION.



* Processing by tax identifier and package
  REFRESH $I_BSZNUM_SORSZ.
  SORT: $R_ADOAZON, $R_PACK.
  SORT $I_/ZAK/IGABEV BY BUKRS BTYPE BSZNUM ABEVAZ.


*++0003 2009.03.03 BG
*  LOOP AT $R_ADOAZON.
**   LOOP AT $R_PACK.
*    LOOP AT $I_PACK INTO W_PACK.
*      MOVE 'X' TO L_FIRST.
*      LOOP AT $I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
*                             WHERE BUKRS EQ $BUKRS
*                               AND BTYPE EQ $BTYPE
*                               AND GJAHR EQ W_PACK-GJAHR
*                               AND MONAT EQ W_PACK-MONAT
*                               AND ADOAZON EQ $R_ADOAZON-LOW
*                               AND PACK  EQ W_PACK-PACK.
*
*
*        READ TABLE $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV
*               WITH KEY  BUKRS  = W_/ZAK/ANALITIKA-BUKRS
*                         BTYPE  = W_/ZAK/ANALITIKA-BTYPE
*                         BSZNUM = W_/ZAK/ANALITIKA-BSZNUM
*                         ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ.
*        IF SY-SUBRC EQ 0.
*
*
*          READ TABLE $I_/ZAK/IGSOR INTO W_/ZAK/IGSOR
*                     WITH KEY IGAZON = W_/ZAK/IGABEV-IGAZON.
*          CHECK SY-SUBRC EQ 0.
*
*          CLEAR W_/ZAK/IGDATA.
*          MOVE W_/ZAK/ANALITIKA-BUKRS    TO W_/ZAK/IGDATA-BUKRS.
*          MOVE W_/ZAK/ANALITIKA-BTYPE    TO W_/ZAK/IGDATA-BTYPE.
*          MOVE W_/ZAK/ANALITIKA-ADOAZON  TO W_/ZAK/IGDATA-ADOAZON.
*          MOVE W_/ZAK/ANALITIKA-GJAHR    TO W_/ZAK/IGDATA-GJAHR.
*          MOVE W_/ZAK/ANALITIKA-MONAT    TO W_/ZAK/IGDATA-MONAT.
*          MOVE W_/ZAK/ANALITIKA-BSZNUM   TO W_/ZAK/IGDATA-BSZNUM.
*          MOVE W_/ZAK/IGABEV-IGAZON TO W_/ZAK/IGDATA-IGAZON.
*          MOVE W_/ZAK/IGABEV-SORREND TO W_/ZAK/IGDATA-SORREND.
*          MOVE W_/ZAK/ANALITIKA-FIELD_C TO W_/ZAK/IGDATA-FIELD_C.
*          IF NOT L_FIRST IS INITIAL.
*            PERFORM GET_LAST_SORSZ TABLES $I_BSZNUM_SORSZ
*                                   USING  W_/ZAK/IGDATA
*                                          L_SORSZ
*                                          $TEST
**++0001 2008.11.14 BG
*                                          $BUKRS
**--0001 2008.11.14 BG
*                                          .
*            M_DEF LR_SORSZ 'I' 'EQ' L_SORSZ SPACE.
*            CLEAR L_FIRST.
*          ENDIF.
*          W_/ZAK/IGDATA-SORSZ = L_SORSZ.
**         If the row is in date format
*          LM_FORMAT_FIELD W_/ZAK/IGSOR-FORMATUM W_/ZAK/IGDATA-FIELD_C.
*          MOVE W_/ZAK/ANALITIKA-FIELD_N TO W_/ZAK/IGDATA-FIELD_N.
*          MOVE W_/ZAK/ANALITIKA-WAERS TO W_/ZAK/IGDATA-WAERS.
**++0001 2008.11.14 BG
**         MOVE SY-DATUM TO W_/ZAK/IGDATA-DATUM.
*          MOVE $DATUM   TO W_/ZAK/IGDATA-DATUM.
**--0001 2008.11.14 BG
*          COLLECT W_/ZAK/IGDATA INTO $I_/ZAK/IGDATA.
*          CLEAR LI_DATA.
*          MOVE W_/ZAK/ANALITIKA-BUKRS  TO LI_DATA-BUKRS.
*          MOVE W_/ZAK/ANALITIKA-BTYPE  TO LI_DATA-BTYPE.
*          MOVE W_/ZAK/ANALITIKA-ADOAZON TO LI_DATA-ADOAZON.
*          MOVE W_/ZAK/ANALITIKA-GJAHR   TO LI_DATA-GJAHR.
*          MOVE W_/ZAK/ANALITIKA-MONAT   TO LI_DATA-MONAT.
*          MOVE W_/ZAK/ANALITIKA-BSZNUM  TO LI_DATA-BSZNUM.
*          MOVE W_/ZAK/IGDATA-SORSZ      TO LI_DATA-SORSZ.
*          MOVE W_/ZAK/ANALITIKA-WAERS   TO LI_DATA-WAERS.
*          COLLECT LI_DATA.
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.
*  ENDLOOP.


  LOOP AT $R_ADOAZON.
*++2008 #12.
    IF NOT P_EVES IS INITIAL.
      MOVE 'X' TO L_FIRST.
    ENDIF.
*--2008 #12.
*   LOOP AT $R_PACK.
    LOOP AT $I_PACK INTO W_PACK.
*++2008 #12.
      IF P_EVES IS INITIAL.
*--2008 #12.
        MOVE 'X' TO L_FIRST.
*++2008 #12.
      ENDIF.
*--2008 #12.
      CLEAR: W_/ZAK/IGDATA, LI_DATA.

      LOOP AT $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV
                      WHERE BUKRS EQ $BUKRS
                        AND BTYPE EQ $BTYPE.

        LOOP AT $I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
                               WHERE BUKRS EQ W_/ZAK/IGABEV-BUKRS
                                 AND BTYPE EQ W_/ZAK/IGABEV-BTYPE
                                 AND GJAHR EQ W_PACK-GJAHR
                                 AND MONAT EQ W_PACK-MONAT
                                 AND ADOAZON EQ $R_ADOAZON-LOW
                                 AND BSZNUM EQ W_/ZAK/IGABEV-BSZNUM
                                 AND PACK  EQ W_PACK-PACK
                                 AND ABEVAZ EQ W_/ZAK/IGABEV-ABEVAZ.

          READ TABLE $I_/ZAK/IGSOR INTO W_/ZAK/IGSOR
                     WITH KEY IGAZON = W_/ZAK/IGABEV-IGAZON.
          CHECK SY-SUBRC EQ 0.

          MOVE W_/ZAK/ANALITIKA-BUKRS    TO W_/ZAK/IGDATA-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE    TO W_/ZAK/IGDATA-BTYPE.
          MOVE W_/ZAK/ANALITIKA-ADOAZON  TO W_/ZAK/IGDATA-ADOAZON.
          MOVE W_/ZAK/ANALITIKA-GJAHR    TO W_/ZAK/IGDATA-GJAHR.
          MOVE W_/ZAK/ANALITIKA-MONAT    TO W_/ZAK/IGDATA-MONAT.
          MOVE W_/ZAK/ANALITIKA-BSZNUM   TO W_/ZAK/IGDATA-BSZNUM.
          MOVE W_/ZAK/IGABEV-IGAZON TO W_/ZAK/IGDATA-IGAZON.
          MOVE W_/ZAK/IGABEV-SORREND TO W_/ZAK/IGDATA-SORREND.
          CONDENSE W_/ZAK/ANALITIKA-FIELD_C.
*         If the row is in date format
          IF W_/ZAK/IGSOR-FORMATUM EQ C_FORM_D.
            MOVE W_/ZAK/ANALITIKA-FIELD_C TO W_/ZAK/IGDATA-FIELD_C.
            LM_FORMAT_FIELD W_/ZAK/IGSOR-FORMATUM W_/ZAK/IGDATA-FIELD_C.
*         if it is in normal format
*++2108 #21.
*          ELSE.
          ELSEIF NOT  W_/ZAK/ANALITIKA-FIELD_C IS INITIAL AND
            W_/ZAK/IGDATA-FIELD_C NE W_/ZAK/ANALITIKA-FIELD_C
*++2108 #21.
            AND NOT W_/ZAK/IGDATA-FIELD_C CS W_/ZAK/ANALITIKA-FIELD_C.
*--2108 #21.
            CONCATENATE W_/ZAK/IGDATA-FIELD_C W_/ZAK/ANALITIKA-FIELD_C
                        INTO W_/ZAK/IGDATA-FIELD_C SEPARATED BY SPACE.

          ENDIF.
          IF NOT L_FIRST IS INITIAL.
            PERFORM GET_LAST_SORSZ TABLES $I_BSZNUM_SORSZ
                                   USING  W_/ZAK/IGDATA
                                          L_SORSZ
                                          $TEST
*++0001 2008.11.14 BG
                                          $BUKRS
*--0001 2008.11.14 BG
                                          .
            M_DEF LR_SORSZ 'I' 'EQ' L_SORSZ SPACE.
            CLEAR L_FIRST.
          ENDIF.
          W_/ZAK/IGDATA-SORSZ = L_SORSZ.
          ADD W_/ZAK/ANALITIKA-FIELD_N TO W_/ZAK/IGDATA-FIELD_N.
          MOVE W_/ZAK/ANALITIKA-WAERS TO W_/ZAK/IGDATA-WAERS.
*++0001 2008.11.14 BG
*         MOVE SY-DATUM TO W_/ZAK/IGDATA-DATUM.
          MOVE $DATUM   TO W_/ZAK/IGDATA-DATUM.
*--0001 2008.11.14 BG
          MOVE W_/ZAK/ANALITIKA-BUKRS  TO LI_DATA-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE  TO LI_DATA-BTYPE.
          MOVE W_/ZAK/ANALITIKA-ADOAZON TO LI_DATA-ADOAZON.
          MOVE W_/ZAK/ANALITIKA-GJAHR   TO LI_DATA-GJAHR.
          MOVE W_/ZAK/ANALITIKA-MONAT   TO LI_DATA-MONAT.
          MOVE W_/ZAK/ANALITIKA-BSZNUM  TO LI_DATA-BSZNUM.
          MOVE W_/ZAK/IGDATA-SORSZ      TO LI_DATA-SORSZ.
          MOVE W_/ZAK/ANALITIKA-WAERS   TO LI_DATA-WAERS.
        ENDLOOP.
        AT END OF SORREND.
          IF SY-SUBRC EQ 0.
            COLLECT W_/ZAK/IGDATA INTO $I_/ZAK/IGDATA.
            COLLECT LI_DATA.
          ENDIF.
          CLEAR: W_/ZAK/IGDATA, LI_DATA.
        ENDAT.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.


*--0003 2009.03.03 BG

* Check that the mandatory fields are present:
  LOOP AT LI_DATA.
    LOOP AT $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV
                          WHERE BUKRS  EQ  LI_DATA-BUKRS
                            AND BTYPE  EQ  LI_DATA-BTYPE
                            AND BSZNUM EQ  LI_DATA-BSZNUM
                            AND NOT OBLIG IS INITIAL.
*   Check whether the field exists
      READ TABLE $I_/ZAK/IGDATA TRANSPORTING NO FIELDS
                 WITH KEY BUKRS   = LI_DATA-BUKRS
                          ADOAZON = LI_DATA-ADOAZON
                          SORSZ   = LI_DATA-SORSZ
                          IGAZON  = W_/ZAK/IGABEV-IGAZON.
      IF SY-SUBRC NE 0.
        CLEAR W_/ZAK/IGDATA.
        MOVE-CORRESPONDING LI_DATA TO W_/ZAK/IGDATA.
        MOVE W_/ZAK/IGABEV-IGAZON TO W_/ZAK/IGDATA-IGAZON.
        MOVE W_/ZAK/IGABEV-SORREND TO W_/ZAK/IGDATA-SORREND.
*++0001 2008.11.14 BG
*       MOVE SY-DATUM TO W_/ZAK/IGDATA-DATUM.
        MOVE $DATUM   TO W_/ZAK/IGDATA-DATUM.
*--0001 2008.11.14 BG
        APPEND W_/ZAK/IGDATA TO $I_/ZAK/IGDATA.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

*The data is available, calculation can start:
*First we determine the base amounts
  LOOP AT $I_/ZAK/IGABEV INTO W_/ZAK/IGABEV
                       WHERE NOT SUM_IGAZON IS INITIAL.
    LOOP AT LR_SORSZ.
*++0004 2009.09.09 BG
      CHECK LR_SORSZ-LOW(3) = W_/ZAK/IGABEV-BSZNUM.
*--0004 2009.09.09 BG
*     Eredeti rekord
      READ TABLE $I_/ZAK/IGDATA INTO W_/ZAK/IGDATA
                         WITH KEY SORSZ   =  LR_SORSZ-LOW
                                  IGAZON  =  W_/ZAK/IGABEV-IGAZON.
      IF SY-SUBRC EQ 0.
*     Summary line
        READ TABLE $I_/ZAK/IGDATA INTO LW_SUM_LINE
                           WITH KEY SORSZ   =  LR_SORSZ-LOW
                                    IGAZON  =  W_/ZAK/IGABEV-SUM_IGAZON.
*     Does not exist, needs to be created
        IF SY-SUBRC NE 0.
          CLEAR LW_SUM_LINE.
          LM_SIGN W_/ZAK/IGDATA-FIELD_N W_/ZAK/IGABEV-SIGN.
          MOVE-CORRESPONDING W_/ZAK/IGDATA TO LW_SUM_LINE.
          MOVE W_/ZAK/IGABEV-SUM_IGAZON TO LW_SUM_LINE-IGAZON.
          APPEND LW_SUM_LINE TO $I_/ZAK/IGDATA.
*     Exists, needs to be modified
        ELSE.
          MOVE SY-TABIX TO L_TABIX.
          LM_SIGN W_/ZAK/IGDATA-FIELD_N W_/ZAK/IGABEV-SIGN.
          ADD W_/ZAK/IGDATA-FIELD_N TO LW_SUM_LINE-FIELD_N.
          MODIFY $I_/ZAK/IGDATA INDEX L_TABIX
                              FROM LW_SUM_LINE TRANSPORTING FIELD_N.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT $I_/ZAK/IGDATA BY ADOAZON GJAHR BSZNUM SORSZ SORREND.

* Upload to ALV with field names:
  LOOP AT $I_/ZAK/IGDATA INTO W_/ZAK/IGDATA.
    CLEAR W_/ZAK/IGDATA_ALV.
    MOVE-CORRESPONDING W_/ZAK/IGDATA TO W_/ZAK/IGDATA_ALV.
    READ TABLE $I_/ZAK/IGSORT INTO W_/ZAK/IGSORT
         WITH KEY IGAZON = W_/ZAK/IGDATA-IGAZON.
    IF SY-SUBRC EQ 0.
      MOVE W_/ZAK/IGSORT-NYTEXT TO W_/ZAK/IGDATA_ALV-NYTEXT.
    ENDIF.
    APPEND W_/ZAK/IGDATA_ALV TO $I_/ZAK/IGDATA_ALV.
    MOVE W_/ZAK/IGDATA-WAERS TO W_WAERST-WAERS.
    COLLECT W_WAERST INTO $I_WAERST.
  ENDLOOP.

*Determine currency texts
  LOOP AT $I_WAERST INTO W_WAERST.
    SELECT SINGLE KTEXT INTO W_WAERST-KTEXT
                        FROM TCURT
                       WHERE SPRAS EQ SY-LANGU
                         AND WAERS EQ W_WAERST-WAERS.
    IF SY-SUBRC EQ 0.
      MODIFY  $I_WAERST FROM W_WAERST TRANSPORTING KTEXT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_SORSZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/IGDATA  text
*      -->P_P_TEST  text
*----------------------------------------------------------------------*
FORM GET_LAST_SORSZ  TABLES  $I_BSZNUM_SORSZ LIKE I_BSZNUM_SORSZ
                     USING   $/ZAK/IGDATA STRUCTURE /ZAK/IGDATA
                             $SORSZ
                             $TEST
*++0001 2008.11.14 BG
                             $BUKRS
*--0001 2008.11.14 BG
                             .

  DATA L_SORSZ TYPE /ZAK/SORSZ.
  DATA L_NUMC5 TYPE NUMC5.
  DATA L_TABIX LIKE SY-TABIX.

**If it is a test run
*  IF NOT $TEST IS INITIAL.
*    CONCATENATE $/ZAK/IGDATA-BSZNUM
*                $/ZAK/IGDATA-GJAHR
*                'TESZT'(001) INTO  $SORSZ
*                                   SEPARATED BY '/'.
*  ELSE.
*   We look up the identifier:
  READ TABLE  $I_BSZNUM_SORSZ INTO W_BSZNUM_SORSZ
         WITH KEY BSZNUM =  $/ZAK/IGDATA-BSZNUM.
  IF SY-SUBRC NE 0.
    CLEAR W_BSZNUM_SORSZ.
    MOVE $/ZAK/IGDATA-BSZNUM TO W_BSZNUM_SORSZ-BSZNUM.
    SELECT MAX( SORSZ ) INTO L_SORSZ                    "#EC CI_NOFIRST
                      FROM /ZAK/IGDATA
                     WHERE
*++0001 2008.11.14 BG
                           BUKRS   EQ $BUKRS
*--0001 2008.11.14 BG
                       AND GJAHR   EQ $/ZAK/IGDATA-GJAHR
                       AND BSZNUM  EQ $/ZAK/IGDATA-BSZNUM
*++0001 2008.11.14 BG
*                      GROUP BY GJAHR BSZNUM.
                       GROUP BY BUKRS GJAHR BSZNUM.
*--0001 2008.11.14 BG

    ENDSELECT.
    IF SY-SUBRC EQ 0.
      W_BSZNUM_SORSZ-NUMBER = L_SORSZ+9(5).
    ELSE.
      CLEAR W_BSZNUM_SORSZ-NUMBER.
    ENDIF.
    APPEND W_BSZNUM_SORSZ TO $I_BSZNUM_SORSZ.
    MOVE SY-TABIX TO L_TABIX.
  ELSE.
    MOVE SY-TABIX TO L_TABIX.
  ENDIF.

  ADD 1 TO W_BSZNUM_SORSZ-NUMBER.

  CONCATENATE $/ZAK/IGDATA-BSZNUM
              $/ZAK/IGDATA-GJAHR
              W_BSZNUM_SORSZ-NUMBER INTO  $SORSZ
                                          SEPARATED BY '/'.
  MODIFY $I_BSZNUM_SORSZ FROM W_BSZNUM_SORSZ INDEX L_TABIX.

*  ENDIF.


ENDFORM.                    " GET_LAST_SORSZ
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .

  CHECK NOT P_LIST IS INITIAL.

* Not a background run
  IF SY-BATCH IS INITIAL.
    CALL SCREEN 100.
* Background run
  ELSE.
    PERFORM GRID_DISPLAY.
  ENDIF.

ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  GRID_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GRID_DISPLAY .

  SET PF-STATUS 'MAIN100'.
  IF P_TEST = 'X'.
    SET TITLEBAR 'MAIN100'.
  ELSE.
    SET TITLEBAR 'MAIN101'.
  ENDIF.

  PERFORM FIELDCAT_BUILD.


  GS_VARIANT-REPORT = G_REPID.
  IF NOT SPEC_LAYOUT IS INITIAL.
    MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
  ELSEIF NOT DEF_LAYOUT IS INITIAL.
    MOVE-CORRESPONDING DEF_LAYOUT TO GS_VARIANT.
  ELSE.
  ENDIF.

  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-SEL_MODE   = 'A'.
* GS_LAYOUT-EXCP_FNAME = 'LIGHT'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                =
*     I_BUFFER_ACTIVE =
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  = ' '
*     I_BACKGROUND_ID = ' '
*     I_GRID_TITLE    =
*     I_GRID_SETTINGS =
      IS_LAYOUT_LVC   = GS_LAYOUT
      IT_FIELDCAT_LVC = GT_FCAT
*     IT_EXCLUDING    =
*     IT_SPECIAL_GROUPS_LVC             =
*     IT_SORT_LVC     =
*     IT_FILTER_LVC   =
*     IT_HYPERLINK    =
*     IS_SEL_HIDE     =
      I_DEFAULT       = 'X'
      I_SAVE          = 'A'
      IS_VARIANT      = GS_VARIANT
*     IT_EVENTS       =
*     IT_EVENT_EXIT   =
*     IS_PRINT_LVC    =
*     IS_REPREP_ID_LVC                  =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 =
*     I_HTML_HEIGHT_END                 =
*     IT_EXCEPT_QINFO_LVC               =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB        = I_/ZAK/IGDATA_ALV
    EXCEPTIONS
      PROGRAM_ERROR   = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " GRID_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  PRODUCTIVE_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRODUCTIVE_RUN TABLES $I_/ZAK/MGCIM  STRUCTURE /ZAK/MGCIM
                           $I_/ZAK/IGDATA STRUCTURE /ZAK/IGDATA
                           $I_/ZAK/IGABEV STRUCTURE /ZAK/IGABEV
                           $I_/ZAK/IGSORT STRUCTURE /ZAK/IGSORT
                           $I_SMART_DATA STRUCTURE /ZAK/SMART_TABLE
                           $I_BSZNUMT LIKE I_BSZNUMT
                           $I_WAERST  LIKE I_WAERST
                           $R_ADOAZON STRUCTURE R_ADOAZON
                           $R_PACK    STRUCTURE R_PACK
                    USING  $BUKRS
                           $TEST
                           $FNAME
*++0001 2008.11.14 BG
                           $DATUM
                           $SPOOL
*--0001 2008.11.14 BG
*++2008 #12.
                           $EVES
*--2008 #12.
                           .

  DATA  L_FM_NAME TYPE RS38L_FNAM.
  DATA  LW_/ZAK/IGDATA TYPE /ZAK/IGDATA.


* Only in productive mode
  CHECK $TEST IS INITIAL.

*Check whether there is an ERROR message
  CALL FUNCTION 'MESSAGES_STOP'
*   EXPORTING
*     I_RESET_IDENTIFICATION       =
*     I_IDENTIFICATION             =
*     I_RESET_MESSAGES             =
    EXCEPTIONS
      A_MESSAGE         = 1
      E_MESSAGE         = 2
      W_MESSAGE         = 3
      I_MESSAGE         = 4
      S_MESSAGE         = 5
      DEACTIVATED_BY_MD = 6
      OTHERS            = 7.
* Abort vagy ERRROR
  IF SY-SUBRC EQ 1 OR SY-SUBRC EQ 2.
    MESSAGE I262.
*   Productive run cannot be started due to errors!
    EXIT.
  ENDIF.

* Determine form data
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = $FNAME
    IMPORTING
      FM_NAME            = L_FM_NAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC <> 0.
    MESSAGE E263 WITH $FNAME.
*   Error while reading form &!
  ENDIF.


* Processing by tax identifier
  LOOP AT $R_ADOAZON.
    CLEAR: W_/ZAK/MGCIM.
    REFRESH $I_SMART_DATA.
*   Determine address data
    READ TABLE $I_/ZAK/MGCIM INTO W_/ZAK/MGCIM
               WITH KEY ADOAZON = $R_ADOAZON-LOW
                        BINARY SEARCH.
    LOOP AT $I_/ZAK/IGDATA INTO W_/ZAK/IGDATA
                        WHERE ADOAZON EQ $R_ADOAZON-LOW.
      MOVE W_/ZAK/IGDATA TO LW_/ZAK/IGDATA.
      PERFORM GET_SMART_DATA TABLES $I_/ZAK/IGABEV
                                   $I_/ZAK/IGSORT
                                   $I_BSZNUMT
                                   $I_WAERST
                                   $I_SMART_DATA
                            USING  W_/ZAK/IGDATA.

*     When one serial number ends
      AT END OF SORSZ.
        PERFORM CALL_SMARTFORMS TABLES $I_SMART_DATA
                                USING  L_FM_NAME
                                       $FNAME
                                       $BUKRS
*++0002 2009.02.27 BG
                                       LW_/ZAK/IGDATA-BTYPE
*--0002 2009.02.27 BG
                                       LW_/ZAK/IGDATA-ADOAZON
                                       LW_/ZAK/IGDATA-SORSZ
                                       W_/ZAK/MGCIM
                                       LW_/ZAK/IGDATA-BSZNUM
                                       W_BSZNUMT-SZTEXT
                                       LW_/ZAK/IGDATA-GJAHR
                                       LW_/ZAK/IGDATA-MONAT
                                       $TEST
*++0001 2008.11.14 BG
                                       $DATUM
                                       $SPOOL
*--0001 2008.11.14 BG
*++2008 #12.
                                       $EVES
*--2008 #12.
                                       .



      ENDAT.
    ENDLOOP.
  ENDLOOP.

* Modify database
  MODIFY /ZAK/IGDATA FROM TABLE $I_/ZAK/IGDATA.

  UPDATE /ZAK/BEVALLP SET MGIF = C_X
         WHERE BUKRS = $BUKRS
           AND PACK  IN $R_PACK.

  COMMIT WORK AND WAIT.

ENDFORM.                    " PRODUCTIVE_RU
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  DATA LI_FCODE TYPE TABLE OF SY-UCOMM.

  IF NOT P_TEST IS INITIAL.
    SET TITLEBAR 'MAIN100'.
  ELSE.
    SET TITLEBAR 'MAIN101'.
  ENDIF.

  SET PF-STATUS 'MAIN100' EXCLUDING LI_FCODE.

  IF G_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT G_CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME = G_CONTAINER.
    CREATE OBJECT G_GRID1
      EXPORTING
        I_PARENT = G_CUSTOM_CONTAINER.

    PERFORM FIELDCAT_BUILD.

    GS_VARIANT-REPORT = G_REPID.
    IF NOT SPEC_LAYOUT IS INITIAL.
      MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
    ELSEIF NOT DEF_LAYOUT IS INITIAL.
      MOVE-CORRESPONDING DEF_LAYOUT TO GS_VARIANT.
    ELSE.
    ENDIF.
    GS_LAYOUT-CWIDTH_OPT = 'X'.
    GS_LAYOUT-SEL_MODE   = 'A'.
*   GS_LAYOUT-EXCP_FNAME = 'LIGHT'.

    CALL METHOD G_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT      = GS_VARIANT
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
*       it_toolbar_excluding = lt_exclude
      CHANGING
        IT_OUTTAB       = I_/ZAK/IGDATA_ALV[]
        IT_FIELDCATALOG = GT_FCAT[].
*
  ENDIF.


ENDMODULE.                 " PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELDCAT_BUILD .

  DATA: L_FCAT TYPE LVC_S_FCAT.


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/IGDATA_ALV'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = GT_FCAT[].

  LOOP AT GT_FCAT INTO L_FCAT.
    IF L_FCAT-FIELDNAME = 'CHANGE'.
      L_FCAT-CHECKBOX = 'X'.
    ENDIF.
    MODIFY GT_FCAT FROM L_FCAT.
  ENDLOOP.


ENDFORM.                    " FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.
  CASE SAVE_OK.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.
*   Display messages
    WHEN 'MESSAGE'.
      PERFORM SHOW_MESSAGES USING G_INDEX
                                  P_TEST.
*   Form display
    WHEN 'SHOW'.
      PERFORM PREVIEW_DATA TABLES I_/ZAK/IGDATA_ALV
                                  I_/ZAK/MGCIM
                                  I_SMART_DATA
                           USING  P_FNAME
                                  P_BUKRS
                                  P_TEST
*++2008 #12.
                                  P_EVES.
*--2008 #12.
    WHEN OTHERS.
*     do nothing
  ENDCASE.


ENDMODULE.                 " PAI_0100  I
