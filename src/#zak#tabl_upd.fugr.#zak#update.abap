FUNCTION /ZAK/UPDATE.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE OPTIONAL
*"     VALUE(I_BTYPART) TYPE  /ZAK/BTYPART OPTIONAL
*"     VALUE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"     REFERENCE(I_PACK) TYPE  /ZAK/PACK OPTIONAL
*"     VALUE(I_GEN) TYPE  CHAR01
*"     VALUE(I_TEST) TYPE  CHAR1 DEFAULT 'X'
*"     REFERENCE(I_FILE) TYPE  FC03TAB-PL00_FILE OPTIONAL
*"  TABLES
*"      I_ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"      I_AFA_SZLA STRUCTURE  /ZAK/AFA_SZLA OPTIONAL
*"      E_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA: L_SUBRC LIKE SY-SUBRC.

*++S4HANA#01.
*  REFRESH E_RETURN.
  CLEAR E_RETURN[].
*--S4HANA#01.

* ++BG
* BTYPART provided, perform conversion
  IF NOT I_BTYPART IS INITIAL.
*    PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '115'
*                                 SPACE
*                                 SPACE
*                                 SPACE
*                                 SPACE.
*    E_RETURN[] = IG_RETURN[].
* Determine the Analitika table BTYPE per period
    PERFORM GET_BTYPE TABLES I_ANALITIKA
                      USING  I_BUKRS
                             I_BTYPART.
  ENDIF.
* --BG

*++1465 #10.
  IF NOT I_GEN IS INITIAL AND NOT I_PACK IS INITIAL.
*   Treat it as if it generated the package
    PERFORM CHECK_BEVALL USING I_ANALITIKA[]
                               I_UPD_BEVALLI[]
                               I_UPD_BEVALLSZ[]
                               ''
                               I_BSZNUM
                               I_GEN.
  ELSE.
*--1465 #10.
*   normal return
    PERFORM CHECK_BEVALL USING I_ANALITIKA[]
                               I_UPD_BEVALLI[]
                               I_UPD_BEVALLSZ[]
                               I_PACK
                               I_BSZNUM
                               I_GEN.
*++1465 #10.
  ENDIF.
*--1465 #10.
*++BG 2008.11.17
* BEVALLI ordering: for quarterly and yearly data, if
* there was no data in the analytics for a given period then no
* BEVALLI record was created. However, because the BEVALLO
* always writes to the last month of the period, in some
* cases it causes issues that there is no matching BEVALLI. Therefore
* this routine checks whether the BEVALLI consistency is correct
  PERFORM CHECK_BEVALLI TABLES I_UPD_BEVALLI.
*--BG 2008.11.17

  READ TABLE I_RETURN WITH KEY ID = 'E' INTO W_RETURN.
* Error, there is no database table update!
  IF SY-SUBRC NE 0.
    IF I_TEST IS INITIAL.
* generate package identifier
      IF I_GEN  EQ 'X'.
*++1465 #10.
        IF NOT I_PACK IS INITIAL.
          V_/ZAK/PACK = I_PACK.
        ELSE.
*--1465 #10.
* package number range
          CALL FUNCTION '/ZAK/NEW_PACKAGE_NUMBER'
            IMPORTING
              E_PACK           = V_/ZAK/PACK
            EXCEPTIONS
              ERROR_GET_NUMBER = 1
              OTHERS           = 2.
          IF SY-SUBRC <> 0.
*          PERFORM ERROR_HANDLING USING SY-MSGID SY-MSGTY SY-MSGNO
*                                       SY-MSGV1 SY-MSGV2 SY-MSGV3
*                                       SY-MSGV4.
            MESSAGE A001(/ZAK/ZAK).
*         Upload identifier number range error!
          ENDIF.
*++1465 #10.
        ENDIF.
*--1465 #10.
        W_/ZAK/BEVALLP-BUKRS = I_BUKRS.
*++1465 #10.
*        IF NOT I_PACK IS INITIAL.
        IF NOT I_PACK IS INITIAL AND I_GEN IS INITIAL.
*--1465 #10.
* Repeated upload!
          W_/ZAK/BEVALLP-SPACK  = I_PACK.
        ENDIF.
        W_/ZAK/BEVALLP-DATUM = SY-DATUM.
        W_/ZAK/BEVALLP-UZEIT = SY-UZEIT.
        W_/ZAK/BEVALLP-UNAME = SY-UNAME.
        W_/ZAK/BEVALLP-PACK  = V_/ZAK/PACK.
        W_/ZAK/BEVALLP-ZFILE  = I_FILE.
*++1465 #06.
        IF NOT I_BTYPART IS INITIAL.
          W_/ZAK/BEVALLP-BTYPART = I_BTYPART.
        ELSE.
          CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
            EXPORTING
              I_BUKRS   = I_BUKRS
              I_BTYPE   = I_BTYPE
            IMPORTING
              E_BTYPART = W_/ZAK/BEVALLP-BTYPART.
        ENDIF.
*--1465 #06.
*++1465 #10.
*        IF NOT I_PACK IS INITIAL.
        IF NOT I_PACK IS INITIAL AND I_GEN IS INITIAL.
*--1465 #10.
*++S4HANA#01.
*          SELECT SINGLE * FROM /ZAK/BEVALLP
          SELECT SINGLE * FROM /ZAK/BEVALLP INTO /ZAK/BEVALLP
*--S4HANA#01.
                 WHERE BUKRS EQ W_/ZAK/BEVALLP-BUKRS AND
                       PACK  EQ I_PACK.
          IF SY-SUBRC NE 0.
*   No upload identifier provided!
            PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '038'
                                         I_PACK
                                         SY-MSGV2
                                         SY-MSGV3
                                         SY-MSGV4 .
            L_SUBRC = 8.
          ELSE.
            W_/ZAK/BEVALLP-SPACK = I_PACK.
          ENDIF.
        ENDIF.
        IF L_SUBRC NE 0.
          IF SY-SUBRC NE 0.
* writing the /ZAK/BEVALLP table failed!
            PERFORM ERROR_HANDLING USING SY-MSGID SY-MSGTY SY-MSGNO
                                         SY-MSGV1 SY-MSGV2 SY-MSGV3
                                         SY-MSGV4 .
          ENDIF.
        ELSE.
          INSERT INTO /ZAK/BEVALLP VALUES W_/ZAK/BEVALLP.
        ENDIF.
      ENDIF.
      IF L_SUBRC EQ 0.
* modifying the statistical flag is only possible for a full data submission
* repetition.
*++S4HANA#01.
*        SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
        SELECT SINGLE BSZNUM
        INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALLD
        FROM /ZAK/BEVALLD         "$smart: #712
*--S4HANA#01.
        WHERE BUKRS  EQ I_BUKRS AND
              BTYPE  EQ I_BTYPE AND
              BSZNUM EQ I_BSZNUM AND
              XFULL  EQ 'X'.
        IF SY-SUBRC EQ 0.
* During uploading the SZJA return to the self-revision, items with the previous index and the same
* data submission and tax number must be marked as statistical items
* They must be flagged accordingly.
          CALL FUNCTION '/ZAK/STAPO_EXIT'
            EXPORTING
              I_BUKRS     = I_BUKRS
              I_BTYPE     = I_BTYPE
              I_PACK      = I_PACK
            TABLES
              T_ANALITIKA = I_ANALITIKA[].
        ENDIF.
        IF NOT I_PACK IS INITIAL AND I_GEN  EQ 'X'.
* repeated return! Delete every previous data where the period is not closed
* yet closed.
*++BG 2006/06/08
*          PERFORM DELETE_ABEV_TABLE  USING I_ANALITIKA[]
*                                           I_UPD_BEVALLI[]
*                                           I_UPD_BEVALLSZ[]
*                                           V_/ZAK/PACK.

          PERFORM DELETE_ABEV_TABLEN USING I_ANALITIKA[]
                                           I_UPD_BEVALLI[]
                                           I_PACK.

*--BG 2006/06/08

        ENDIF.
        PERFORM INSERT_ABEV_TABLE USING I_ANALITIKA[]
*++1365 2013.01.22 Balázs Gábor (Ness)
                                        I_AFA_SZLA[]
*--1365 2013.01.22 Balázs Gábor (Ness)
                                        I_UPD_BEVALLI[]
                                        I_UPD_BEVALLSZ[]
                                        I_PACK
                                        V_/ZAK/PACK
                                        I_GEN.
      ENDIF.
    ENDIF.
  ENDIF.
  SORT IG_RETURN BY TYPE ID NUMBER MESSAGE_V1 MESSAGE_V2.
  DELETE ADJACENT DUPLICATES FROM IG_RETURN
         COMPARING TYPE ID NUMBER MESSAGE_V1 MESSAGE_V2.

  E_RETURN[] = IG_RETURN[].
ENDFUNCTION.
