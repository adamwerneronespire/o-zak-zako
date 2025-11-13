FUNCTION /ZAK/READ_ABEV_EXIT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"----------------------------------------------------------------------
  DATA: L_TRUE,
        L_ITEM LIKE /ZAK/ANALITIKA-ITEM.

  DATA: L_ABEV TYPE /ZAK/ANALITIKA-ABEVAZ.
  DATA: I_STAT_BEVALLSZ  TYPE STANDARD TABLE OF /ZAK/BEVALLSZ
                                                         INITIAL SIZE 0,
        I_STAT_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                         INITIAL SIZE 0,
        I_CHECK_BEVALLO  TYPE STANDARD TABLE OF /ZAK/BEVALLO
                                                         INITIAL SIZE 0.
*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
* Declaration type
*++S4HANA#01.
*  RANGES: R_MONAT FOR /ZAK/ANALITIKA-MONAT.
  TYPES TT_MONAT TYPE RANGE OF /ZAK/ANALITIKA-MONAT.
  DATA LT_MONAT TYPE TT_MONAT.
  DATA LS_MONAT TYPE LINE OF TT_MONAT.
*--S4HANA#01.
* 107 ABEV insert
*++S4HANA#01.
*  SELECT SINGLE * FROM /ZAK/BEVALL WHERE BUKRS EQ I_BUKRS AND
*                                        BTYPE EQ I_BTYPE.
  SELECT * FROM /ZAK/BEVALL UP TO 1 ROWS
           INTO /ZAK/BEVALL
           WHERE BUKRS EQ I_BUKRS
             AND BTYPE EQ I_BTYPE          "$smart: #601 #902
           ORDER BY PRIMARY KEY.           "$smart: #601

  ENDSELECT.
*--S4HANA#01.
  CHECK /ZAK/BEVALL-BTYPART = C_BTYPART_TARS OR
        /ZAK/BEVALL-BTYPART = C_BTYPART_UCS.

  DATA L_INDEX LIKE SY-TABIX.
*********************************************************

*********************************************************
*++S4HANA#01.
*  REFRESH: I_STAT_BEVALLSZ,I_STAT_ANALITIKA,I_CHECK_BEVALLO.
  CLEAR: I_STAT_BEVALLSZ[].
  CLEAR: I_STAT_ANALITIKA[].
  CLEAR: I_CHECK_BEVALLO[].
*--S4HANA#01.

  SELECT * INTO TABLE I_STAT_BEVALLSZ FROM /ZAK/BEVALLSZ
  FOR ALL ENTRIES IN T_ANALITIKA
  WHERE BUKRS   EQ T_ANALITIKA-BUKRS AND
        BTYPE   EQ T_ANALITIKA-BTYPE AND
        BSZNUM  EQ T_ANALITIKA-BSZNUM AND
        GJAHR   EQ T_ANALITIKA-GJAHR  AND
        MONAT   EQ T_ANALITIKA-MONAT.
* Was there already an upload and closure for the tax number?
  SELECT * INTO TABLE I_CHECK_BEVALLO FROM /ZAK/BEVALLO
  FOR ALL ENTRIES IN T_ANALITIKA
  WHERE BUKRS   EQ T_ANALITIKA-BUKRS AND
        BTYPE   EQ T_ANALITIKA-BTYPE AND
        GJAHR   EQ T_ANALITIKA-GJAHR  AND
*        MONAT   EQ T_ANALITIKA-MONAT AND
        ADOAZON EQ T_ANALITIKA-ADOAZON.

  SORT I_CHECK_BEVALLO BY BUKRS BTYPE GJAHR MONAT ZINDEX DESCENDING.
  SORT I_STAT_BEVALLSZ BY BUKRS BTYPE BSZNUM
                          GJAHR MONAT PACK DESCENDING.
  DELETE ADJACENT DUPLICATES FROM I_/ZAK/BEVALLSZ
                        COMPARING BUKRS BTYPE BSZNUM GJAHR MONAT .

  CLEAR L_INDEX.

  LOOP AT T_ANALITIKA INTO W_/ZAK/ANALITIKA.

* To ensure dialog execution
    PERFORM PROCESS_IND_ITEM USING '10000'
                                   L_INDEX
                                   TEXT-P11.

* ...quarterly
    IF /ZAK/BEVALL-BIDOSZ = 'N'.
      CASE W_/ZAK/ANALITIKA-MONAT.
        WHEN '01' OR '02' OR '03'.
*++S4HANA#01.
*          REFRESH R_MONAT.
*          R_MONAT-SIGN   = 'I'.
*          R_MONAT-OPTION = 'BT'.
*          R_MONAT-LOW    = '01'.
*          R_MONAT-HIGH   = '03'.
*          APPEND R_MONAT.
          CLEAR LT_MONAT[].
          LS_MONAT-SIGN   = 'I'.
          LS_MONAT-OPTION = 'BT'.
          LS_MONAT-LOW    = '01'.
          LS_MONAT-HIGH   = '03'.
          APPEND LS_MONAT TO LT_MONAT.
*--S4HANA#01.
        WHEN '04' OR '05' OR '06'.
*++S4HANA#01.
*          REFRESH R_MONAT.
*          R_MONAT-SIGN   = 'I'.
*          R_MONAT-OPTION = 'BT'.
*          R_MONAT-LOW    = '04'.
*          R_MONAT-HIGH   = '06'.
*          APPEND R_MONAT.
          CLEAR LT_MONAT[].
          LS_MONAT-SIGN   = 'I'.
          LS_MONAT-OPTION = 'BT'.
          LS_MONAT-LOW    = '04'.
          LS_MONAT-HIGH   = '06'.
          APPEND LS_MONAT TO LT_MONAT.
*--S4HANA#01.
        WHEN '07' OR '08' OR '09'.
*++S4HANA#01.
*          REFRESH R_MONAT.
*          R_MONAT-SIGN   = 'I'.
*          R_MONAT-OPTION = 'BT'.
*          R_MONAT-LOW    = '07'.
*          R_MONAT-HIGH   = '09'.
*          APPEND R_MONAT.
          CLEAR LT_MONAT[].
          LS_MONAT-SIGN   = 'I'.
          LS_MONAT-OPTION = 'BT'.
          LS_MONAT-LOW    = '07'.
          LS_MONAT-HIGH   = '09'.
          APPEND LS_MONAT TO LT_MONAT.
*--S4HANA#01.
        WHEN '10' OR '11' OR '12'.
*++S4HANA#01.
*          REFRESH R_MONAT.
*          R_MONAT-SIGN   = 'I'.
*          R_MONAT-OPTION = 'BT'.
*          R_MONAT-LOW    = '10'.
*          R_MONAT-HIGH   = '12'.
*          APPEND R_MONAT.
          CLEAR LT_MONAT[].
          LS_MONAT-SIGN   = 'I'.
          LS_MONAT-OPTION = 'BT'.
          LS_MONAT-LOW    = '10'.
          LS_MONAT-HIGH   = '12'.
          APPEND LS_MONAT TO LT_MONAT.
*--S4HANA#01.
      ENDCASE.
* ...annual
    ELSEIF /ZAK/BEVALL-BIDOSZ = 'E'.
*++S4HANA#01.
*      REFRESH R_MONAT.
*      R_MONAT-SIGN   = 'I'.
*      R_MONAT-OPTION = 'BT'.
*      R_MONAT-LOW    = '01'.
*      R_MONAT-HIGH   = '12'.
*      APPEND R_MONAT.
      CLEAR LT_MONAT[].
      LS_MONAT-SIGN   = 'I'.
      LS_MONAT-OPTION = 'BT'.
      LS_MONAT-LOW    = '01'.
      LS_MONAT-HIGH   = '12'.
      APPEND LS_MONAT TO LT_MONAT.
*--S4HANA#01.
* ...monthly
    ELSEIF /ZAK/BEVALL-BIDOSZ = 'H'.
*++S4HANA#01.
*      REFRESH R_MONAT.
*      R_MONAT-SIGN   = 'I'.
*      R_MONAT-OPTION = 'EQ'.
*      R_MONAT-LOW    = '01'.
*      APPEND R_MONAT.
      CLEAR LT_MONAT[].
      LS_MONAT-SIGN   = 'I'.
      LS_MONAT-OPTION = 'EQ'.
      LS_MONAT-LOW    = '01'.
      APPEND LS_MONAT TO LT_MONAT.
*--S4HANA#01.
    ENDIF.
    READ TABLE I_STAT_BEVALLSZ INTO W_/ZAK/BEVALLSZ
                         WITH KEY BUKRS  = W_/ZAK/ANALITIKA-BUKRS
                                  BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                                  BSZNUM = W_/ZAK/ANALITIKA-BSZNUM
                                  GJAHR  = W_/ZAK/ANALITIKA-GJAHR
                                  MONAT  = W_/ZAK/ANALITIKA-MONAT.
    IF SY-SUBRC NE 0.
* 'E' if the declaration is not closed for the period
      W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_107.
      W_/ZAK/ANALITIKA-FIELD_C = C_107_E.
      CLEAR W_/ZAK/ANALITIKA-FIELD_N.
      APPEND W_/ZAK/ANALITIKA TO I_STAT_ANALITIKA.
    ELSE.
      IF  W_/ZAK/BEVALLSZ-FLAG NE 'Z' AND
          W_/ZAK/BEVALLSZ-FLAG NE 'X'.
* 'E' if the declaration is not closed for the period
        W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_107.
        W_/ZAK/ANALITIKA-FIELD_C = C_107_E.
        CLEAR W_/ZAK/ANALITIKA-FIELD_N.
        APPEND W_/ZAK/ANALITIKA TO I_STAT_ANALITIKA.
      ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'Z'.
        LOOP AT I_CHECK_BEVALLO INTO W_/ZAK/BEVALLO
                            WHERE    BUKRS  = W_/ZAK/ANALITIKA-BUKRS AND
                                     BTYPE  = W_/ZAK/ANALITIKA-BTYPE AND
                                     GJAHR  = W_/ZAK/ANALITIKA-GJAHR AND
*++S4HANA#01.
*                                     MONAT  IN R_MONAT              AND
                                     MONAT  IN LT_MONAT             AND                         "$smart: #112
*--S4HANA#01.
                                      ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
        ENDLOOP.
        IF SY-SUBRC EQ  0.
* 'H' if the period is already closed and there is a posting for this period
          W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_107.
          W_/ZAK/ANALITIKA-FIELD_C = C_107_H.
          CLEAR W_/ZAK/ANALITIKA-FIELD_N.
          APPEND W_/ZAK/ANALITIKA TO I_STAT_ANALITIKA.
        ELSE.
* 'P' if the period is already closed and no posting has arrived yet for this tax number
          W_/ZAK/ANALITIKA-ABEVAZ = C_ABEVAZ_107.
          W_/ZAK/ANALITIKA-FIELD_C = C_107_P.
          CLEAR W_/ZAK/ANALITIKA-FIELD_N.
          APPEND W_/ZAK/ANALITIKA TO I_STAT_ANALITIKA.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF NOT I_STAT_ANALITIKA[] IS INITIAL.
*
    SORT I_STAT_ANALITIKA BY BUKRS BTYPE GJAHR MONAT
                           ZINDEX ADOAZON.
    DELETE ADJACENT DUPLICATES FROM I_STAT_ANALITIKA
                     COMPARING BUKRS BTYPE GJAHR MONAT ZINDEX ADOAZON
  .

    LOOP AT I_STAT_ANALITIKA INTO W_/ZAK/ANALITIKA.
      L_ITEM = L_ITEM + 1.
      AT NEW ADOAZON.
        CLEAR L_ITEM.
      ENDAT.
      IF L_ITEM IS INITIAL.
        W_/ZAK/ANALITIKA-ITEM = '00001'.
        L_ITEM = '00001'.
      ELSE.
        W_/ZAK/ANALITIKA-ITEM = L_ITEM.
      ENDIF.
      MODIFY I_STAT_ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING ITEM.
    ENDLOOP.
*
    APPEND LINES OF I_STAT_ANALITIKA  TO T_ANALITIKA.
  ENDIF.
ENDFUNCTION.
