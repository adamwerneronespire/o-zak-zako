*----------------------------------------------------------------------*
***INCLUDE /ZAK/LTABL_UPDF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  error_handling
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_MSGID  text
*      -->P_SY_MSGTY  text
*      -->P_SY_MSGNO  text
*      -->P_SY_MSGV1  text
*      -->P_SY_MSGV2  text
*      -->P_SY_MSGV3  text
*      -->P_SY_MSGV4  text
*----------------------------------------------------------------------*
FORM ERROR_HANDLING USING    $MSGID
                             $MSGTY
                             $MSGNO
                             $MSGV1
                             $MSGV2
                             $MSGV3
                             $MSGV4.
  DATA: L_MESSG LIKE MESSAGE.


  W_RETURN-TYPE       = $MSGTY.
  W_RETURN-ID         = $MSGID.
  W_RETURN-NUMBER     = $MSGNO.
  W_RETURN-MESSAGE_V1 = $MSGV1.
  W_RETURN-MESSAGE_V2 = $MSGV2.
  W_RETURN-MESSAGE_V3 = $MSGV3.
  W_RETURN-MESSAGE_V4 = $MSGV4.

*  CALL FUNCTION 'WRITE_MESSAGE'
*   EXPORTING
*     MSGID         = $MSGID
*     MSGNO         = $MSGNO
*     MSGTY         = $MSGTY
*     MSGV1         = $MSGV1
*     MSGV2         = $MSGV1
*     MSGV3         = $MSGV2
*     MSGV4         = $MSGV3
*     MSGV5         = $MSGV4
*  IMPORTING
**    ERROR         =
*     MESSG         = L_MESSG
*           .
*  W_RETURN-MESSAGE = L_MESSG-MSGTX.

  MESSAGE ID $MSGID TYPE $MSGTY NUMBER $MSGNO
          WITH $MSGV1 $MSGV2 $MSGV3 $MSGV4 INTO W_RETURN-MESSAGE.
  APPEND W_RETURN TO IG_RETURN.
ENDFORM.                    " error_handling

*&---------------------------------------------------------------------*
*&      Form  CHECK_bevall
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BEVALL USING $ANALITIKA LIKE I_/ZAK/ANALITIKA[]
                        $UPD_BEVALLI  LIKE I_UPD_BEVALLI[]
                        $UPD_BEVALLSZ LIKE I_UPD_BEVALLSZ[]
                        $PACK         TYPE /ZAK/PACK
                        $BSZNUM       TYPE /ZAK/BSZNUM
                        $GEN          TYPE CHAR1 .

  DATA: L_ISMET(1) TYPE C.
  REFRESH: $UPD_BEVALLI,
           $UPD_BEVALLSZ.
*++BG 2006/08/11
  DATA L_INDEX LIKE SY-TABIX.
*--BG 2006/08/11

*++BG 2006/08/31
* Collecting key fields
  TYPES: BEGIN OF LT_KEY,
           BUKRS  TYPE BUKRS,
           BTYPE  TYPE /ZAK/BTYPE,
           GJAHR  TYPE GJAHR,
           MONAT  TYPE MONAT,
           BSZNUM TYPE /ZAK/BSZNUM,
         END OF LT_KEY.

  DATA LI_KEY TYPE  HASHED  TABLE OF LT_KEY WITH UNIQUE DEFAULT KEY
                                                 INITIAL SIZE 0.
*++BG 2011.09.14
  DATA LI_KEY_APPEND TYPE  HASHED TABLE OF LT_KEY
                     WITH UNIQUE DEFAULT  KEY
                     INITIAL SIZE 0.

*--BG 2011.09.14

  DATA LW_KEY TYPE LT_KEY.
*--BG 2006/08/31

*++BG 2011.09.14
* Group companies
  DATA LI_CS_BUKRS LIKE /ZAK/AFACS_BUKRS OCCURS 0 WITH HEADER LINE.
  DATA L_BUKCS     TYPE /ZAK/BUKCS.
  DATA L_DATUM     TYPE DATUM.
*--BG 2011.09.14
*++PTGSZLAA #02. 2014.03.05
  DATA L_WEEK TYPE KWEEK.
*--PTGSZLAA #02. 2014.03.05

  SORT $ANALITIKA BY BUKRS BTYPE GJAHR MONAT.
*++BG 2006/08/31
* Call PROCESS INDICATOR due to dialog runtime overrun:
* !!! CHANGE: need to build an internal table from the $ANALITIKA table
*  (BUKRS, BTYPE, GJAHR, MONAT, BSZNUM) and read the
*  /ZAK/BEVALLI, /ZAK/BEVALLSZ, /ZAK/BEVALLD tables
*  with the FOR ALL ENTRIES statement based on the above table!!!!
*  olvasni!!!!
  LOOP AT $ANALITIKA INTO W_/ZAK/ANALITIKA.
    CLEAR LW_KEY.
    MOVE W_/ZAK/ANALITIKA-BUKRS TO LW_KEY-BUKRS.
    MOVE W_/ZAK/ANALITIKA-BTYPE TO LW_KEY-BTYPE.
    MOVE W_/ZAK/ANALITIKA-GJAHR TO LW_KEY-GJAHR.
    MOVE W_/ZAK/ANALITIKA-MONAT TO LW_KEY-MONAT.
    MOVE W_/ZAK/ANALITIKA-BSZNUM TO LW_KEY-BSZNUM.
    COLLECT LW_KEY INTO LI_KEY.
  ENDLOOP.
*--BG 2006/08/31

*++BG 2011.09.14
*  Group company verification
  LOOP AT LI_KEY INTO LW_KEY.
    REFRESH LI_CS_BUKRS.
    CLEAR:  L_BUKCS, L_DATUM.
*++PTGSZLAA #02. 2014.03.05
    IF LW_KEY-BTYPE EQ C_PTGSZLAA.
      CLEAR L_WEEK.
      CONCATENATE LW_KEY-GJAHR LW_KEY-MONAT INTO L_WEEK.
      CALL FUNCTION 'WEEK_GET_FIRST_DAY'
        EXPORTING
          WEEK = L_WEEK
        IMPORTING
          DATE = L_DATUM
*      EXCEPTIONS
*         WEEK_INVALID       = 1
*         OTHERS             = 2
        .
      IF SY-SUBRC <> 0.
        CLEAR L_DATUM.
      ELSE.
        ADD 6 TO L_DATUM.
      ENDIF.
    ELSE.
*--PTGSZLAA #02. 2014.03.05
*    Last day of the month
      CONCATENATE LW_KEY-GJAHR LW_KEY-MONAT '01' INTO L_DATUM.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
        EXPORTING
          DAY_IN            = L_DATUM
        IMPORTING
          LAST_DAY_OF_MONTH = L_DATUM.
*++PTGSZLAA #02. 2014.03.05
    ENDIF.
*--PTGSZLAA #02. 2014.03.05

*    Group companies
    CALL FUNCTION '/ZAK/GET_AFCS'
      EXPORTING
        I_BUKRS = LW_KEY-BUKRS
        I_BTYPE = LW_KEY-BTYPE
        I_DATUM = L_DATUM
*      IMPORTING
*       E_BUKCS =
      TABLES
        T_BUKRS = LI_CS_BUKRS.

    LOOP AT LI_CS_BUKRS.
      LW_KEY-BUKRS = LI_CS_BUKRS-BUKRS.
      COLLECT LW_KEY INTO LI_KEY_APPEND.
    ENDLOOP.
  ENDLOOP.
  IF NOT LI_KEY_APPEND[] IS INITIAL.
    LOOP AT LI_KEY_APPEND INTO LW_KEY.
      COLLECT LW_KEY INTO LI_KEY.
    ENDLOOP.
  ENDIF.
*--BG 2011.09.14

*++BG 2006/08/11
* Ensuring dialog runtime
  CLEAR L_INDEX.
  PERFORM PROCESS_IND_ITEM USING '1'
                                 L_INDEX
                                 TEXT-P02.
*--BG 2006/08/11

* Return data service indices
  SELECT * FROM /ZAK/BEVALLI
           INTO TABLE I_/ZAK/BEVALLI
*++BG 2006/08/31
*          FOR ALL ENTRIES IN $ANALITIKA
           FOR ALL ENTRIES IN LI_KEY
*           WHERE BUKRS EQ $ANALITIKA-BUKRS AND
*                 BTYPE EQ $ANALITIKA-BTYPE AND
*                 GJAHR EQ $ANALITIKA-GJAHR AND
*                 MONAT EQ $ANALITIKA-MONAT
           WHERE BUKRS EQ LI_KEY-BUKRS AND
                 BTYPE EQ LI_KEY-BTYPE AND
                 GJAHR EQ LI_KEY-GJAHR AND
                 MONAT EQ LI_KEY-MONAT.
*--BG 2006/08/31

*++BG 2006/08/09
* Ensuring dialog runtime
  CLEAR L_INDEX.
  PERFORM PROCESS_IND_ITEM USING '1'
                                 L_INDEX
                                 TEXT-P02.
*--BG 2006/08/11
* Return data service uploads
  SELECT * FROM /ZAK/BEVALLSZ
           INTO TABLE I_/ZAK/BEVALLSZ
*++BG 2006/08/31
*           FOR ALL ENTRIES IN $ANALITIKA
           FOR ALL ENTRIES IN LI_KEY
*           WHERE BUKRS  EQ $ANALITIKA-BUKRS AND
*                 BTYPE  EQ $ANALITIKA-BTYPE AND
*                 BSZNUM EQ $ANALITIKA-BSZNUM AND
*                 GJAHR  EQ $ANALITIKA-GJAHR AND
*                 MONAT  EQ $ANALITIKA-MONAT
           WHERE BUKRS  EQ LI_KEY-BUKRS AND
                 BTYPE  EQ LI_KEY-BTYPE AND
                 BSZNUM EQ LI_KEY-BSZNUM AND
                 GJAHR  EQ LI_KEY-GJAHR AND
                 MONAT  EQ LI_KEY-MONAT.
*--BG 2006/08/31
*++BG 2006/08/09
* Ensuring dialog runtime
  CLEAR L_INDEX.
  PERFORM PROCESS_IND_ITEM USING '1'
                                 L_INDEX
                                 TEXT-P02.
*--BG 2006/08/11

* Return data service data
  SELECT * FROM /ZAK/BEVALLD
           INTO TABLE I_/ZAK/BEVALLD
*++BG 2006/08/31
*          FOR ALL ENTRIES IN $ANALITIKA
           FOR ALL ENTRIES IN LI_KEY
*           WHERE BUKRS  EQ $ANALITIKA-BUKRS AND
*                 BTYPE  EQ $ANALITIKA-BTYPE AND
*                 BSZNUM EQ $ANALITIKA-BSZNUM
           WHERE BUKRS  EQ LI_KEY-BUKRS AND
                 BTYPE  EQ LI_KEY-BTYPE AND
                 BSZNUM EQ LI_KEY-BSZNUM.
*--BG 2006/08/31

*++BG 2008/05/20
*In the event that a new load is created during the period or the data
*service was not released, the function did not work properly because it
*always determined the next identifier based on the BEVALLSZ BSZNUM and
*period.
*Therefore we check whether the BSZNUM in ANALITIKA appears in BEVALLSZ
*with a "Z" or "X" status read in from BEVALLI. If not, we create it.
*++1765 #31.
* We check every status to see if it exists in BEVALLSZ!
*  LOOP AT I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI WHERE FLAG CA 'ZX'.
  LOOP AT I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI.
*++1765 #31.
    LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.
      READ TABLE I_/ZAK/BEVALLSZ TRANSPORTING NO FIELDS
                                WITH KEY BUKRS = W_/ZAK/BEVALLI-BUKRS
                                         BTYPE = W_/ZAK/BEVALLI-BTYPE
                                         BSZNUM = W_/ZAK/BEVALLD-BSZNUM
                                         GJAHR = W_/ZAK/BEVALLI-GJAHR
                                         MONAT = W_/ZAK/BEVALLI-MONAT
                                         ZINDEX = W_/ZAK/BEVALLI-ZINDEX
                                         FLAG  = W_/ZAK/BEVALLI-FLAG.
      IF SY-SUBRC NE 0.
        CLEAR W_/ZAK/BEVALLSZ.
        MOVE-CORRESPONDING W_/ZAK/BEVALLI TO W_/ZAK/BEVALLSZ.
        MOVE W_/ZAK/BEVALLD-BSZNUM TO W_/ZAK/BEVALLSZ-BSZNUM.
        APPEND W_/ZAK/BEVALLSZ TO I_/ZAK/BEVALLSZ.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
*--BG 2008/05/20

* I examine the largest ZINDEX entries
  SORT I_/ZAK/BEVALLI BY BUKRS BTYPE GJAHR MONAT ZINDEX DESCENDING.
  DELETE ADJACENT DUPLICATES FROM I_/ZAK/BEVALLI
                        COMPARING BUKRS BTYPE GJAHR MONAT.
  SORT I_/ZAK/BEVALLSZ BY BUKRS BTYPE BSZNUM GJAHR MONAT ZINDEX
DESCENDING.
  DELETE ADJACENT DUPLICATES FROM I_/ZAK/BEVALLSZ
                        COMPARING BUKRS BTYPE BSZNUM GJAHR MONAT.

* Manual entry! I handle it separately because it may still change!
  IF $GEN IS INITIAL.
    PERFORM MANUAL USING $ANALITIKA
                         I_/ZAK/BEVALLI
                         I_/ZAK/BEVALLSZ
                         $UPD_BEVALLI
                         $UPD_BEVALLSZ
                         $BSZNUM.
  ELSE.
* Item setup
*    PERFORM GET_ITEM CHANGING $ANALITIKA.
    PERFORM GENERAL USING $ANALITIKA
                          I_/ZAK/BEVALLI
                          I_/ZAK/BEVALLSZ
                          $UPD_BEVALLI
                          $UPD_BEVALLSZ
                          $BSZNUM
                          $PACK.
  ENDIF.
ENDFORM.                    " CHECK_bevall


*&---------------------------------------------------------------------*
*&      Form  INSERT_ABEV_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ANALITIKA[]  text
*      -->P_I_UPD_BEVALLI[]  text
*      -->P_I_UPD_BEVALLSZ[]  text
*      -->P_V_/ZAK/PACK  text
*----------------------------------------------------------------------*
FORM INSERT_ABEV_TABLE USING    $INS_ANALITIKA LIKE I_/ZAK/ANALITIKA[]
*++1365 2013.01.22 Balázs Gábor (Ness)
                                $INS_AFA_SZLA  LIKE I_/ZAK/AFA_SZLA[]
*--1365 2013.01.22 Balázs Gábor (Ness)
                                $INS_BEVALLI   LIKE I_UPD_BEVALLI[]
                                $INS_BEVALLSZ  LIKE I_UPD_BEVALLSZ[]
                                $OLD_PACK      TYPE /ZAK/PACK
                                $INS_PACK      TYPE /ZAK/PACK
                                $GEN           TYPE CHAR01.

  DATA: L_STAMP LIKE  TZONREF-TSTAMPS.

*++ BG 2006.03.23
  DATA: L_ITEM LIKE /ZAK/ANALITIKA-ITEM.
  DATA  L_INDEX LIKE SY-TABIX.
*-- BG 2006.03.23


* Last run time - timestamp /ZAK/BEVALLSZ-LARUN
  CLEAR W_/ZAK/BEVALLSZ.

  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      I_DATLO     = SY-DATLO
      I_TIMLO     = SY-TIMLO
    IMPORTING
      E_TIMESTAMP = L_STAMP.

* /ZAK/BEVALLSZ UPDATE
  IF NOT $INS_BEVALLSZ[] IS INITIAL.
    LOOP AT $INS_BEVALLSZ INTO W_/ZAK/BEVALLSZ.
      W_/ZAK/BEVALLSZ-PACK   = $INS_PACK.
      W_/ZAK/BEVALLSZ-LARUN  = L_STAMP.
      W_/ZAK/BEVALLSZ-FLAG = 'F'.
*++1908 #08.
      W_/ZAK/BEVALLSZ-DATUM = SY-DATUM.
      W_/ZAK/BEVALLSZ-UZEIT = SY-UZEIT.
      W_/ZAK/BEVALLSZ-UNAME = SY-UNAME.
*--1908 #08.
      IF W_/ZAK/BEVALLSZ-ZINDEX = '   '.
        W_/ZAK/BEVALLSZ-ZINDEX = '000'.
      ENDIF.
      MODIFY $INS_BEVALLSZ FROM W_/ZAK/BEVALLSZ TRANSPORTING PACK
                                                            LARUN
*++1908 #08.
                                                            DATUM
                                                            UZEIT
                                                            UNAME.
*--1908 #08.
      SELECT SINGLE * FROM /ZAK/BEVALLSZ
    WHERE BUKRS EQ W_/ZAK/BEVALLSZ-BUKRS AND
          BTYPE EQ W_/ZAK/BEVALLSZ-BTYPE AND
          BSZNUM EQ W_/ZAK/BEVALLSZ-BSZNUM AND
          GJAHR EQ W_/ZAK/BEVALLSZ-GJAHR AND
          MONAT EQ W_/ZAK/BEVALLSZ-MONAT AND
          ZINDEX EQ W_/ZAK/BEVALLSZ-ZINDEX.
*          PACK EQ W_/ZAK/ANALITIKA-PACK AND
      IF SY-SUBRC EQ 0.
*++1908 #08.
*        W_/ZAK/BEVALLSZ-DATUM = SY-DATUM.
*        W_/ZAK/BEVALLSZ-UZEIT = SY-UZEIT.
*        W_/ZAK/BEVALLSZ-UNAME = SY-UNAME.
*--1908 #08.
        IF NOT $OLD_PACK IS INITIAL.
          DELETE /ZAK/BEVALLSZ.
        ENDIF.
        COMMIT WORK.
        INSERT INTO /ZAK/BEVALLSZ VALUES W_/ZAK/BEVALLSZ.
      ELSE.
        INSERT INTO /ZAK/BEVALLSZ VALUES W_/ZAK/BEVALLSZ.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT $INS_ANALITIKA BY BUKRS BTYPE GJAHR MONAT ZINDEX
                         ABEVAZ ADOAZON BSZNUM .
* /ZAK/ANALITIKA UPDATE
  CLEAR W_/ZAK/ANALITIKA.
*++ BG 2006.03.23
  CLEAR L_ITEM.
  CLEAR L_INDEX.
*-- BG 2006.03.23
  LOOP AT $INS_ANALITIKA INTO W_/ZAK/ANALITIKA.
* Ensuring dialog runtime
    PERFORM PROCESS_IND_ITEM USING '10000'
                                   L_INDEX
                                   TEXT-P01.

    IF NOT $INS_PACK IS INITIAL.
      W_/ZAK/ANALITIKA-PACK   = $INS_PACK.
    ENDIF.
    IF W_/ZAK/ANALITIKA-ZINDEX = '   '.
      W_/ZAK/ANALITIKA-ZINDEX = '000'.
    ENDIF.

* when the final procedure is established,
*  use /ZAK/READ_FILE_EXIT!
*++BG 2006/05/24
    IF W_/ZAK/ANALITIKA-LAPSZ IS INITIAL.
      W_/ZAK/ANALITIKA-LAPSZ = C_LAPSZ.
    ENDIF.
*--BG 2006/05/24
* no package generation for manual mode, so we adjust the item!
    IF NOT $GEN IS INITIAL.
*++ BG 2006.03.23  ITEM increment
      ADD 1 TO L_ITEM.
      MOVE L_ITEM TO W_/ZAK/ANALITIKA-ITEM.
*-- BG 2006.03.23

      MODIFY $INS_ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING PACK
*++ BG 2006.03.23
                                                              ITEM
*-- BG 2006.03.23
                                                              .
    ENDIF.
* manual case if there is no package identifier!
* need to verify the key for manual entry because
* the item number must be provided differently from the existing entry!
    IF $OLD_PACK IS INITIAL AND
       $GEN IS INITIAL.
      SELECT SINGLE * FROM /ZAK/ANALITIKA
      WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
            BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
            GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
            MONAT EQ W_/ZAK/ANALITIKA-MONAT AND
            ZINDEX EQ W_/ZAK/ANALITIKA-ZINDEX AND
            ABEVAZ EQ W_/ZAK/ANALITIKA-ABEVAZ AND
            ADOAZON EQ W_/ZAK/ANALITIKA-ADOAZON AND
            BSZNUM EQ W_/ZAK/ANALITIKA-BSZNUM AND
            ITEM EQ W_/ZAK/ANALITIKA-ITEM.
      IF SY-SUBRC EQ 0.
        DELETE /ZAK/ANALITIKA.
        COMMIT WORK.
        IF SY-SUBRC EQ 0.
*++BG 2006/05/23
*          INSERT INTO /ZAK/ANALITIKA VALUES W_/ZAK/ANALITIKA.
*--BG 2006/05/23
        ENDIF.
      ELSE.
*++BG 2006/05/23
*       INSERT INTO /ZAK/ANALITIKA VALUES W_/ZAK/ANALITIKA.
*--BG 2006/05/23
      ENDIF.
    ELSE.
*++BG 2006/05/23
*      INSERT INTO /ZAK/ANALITIKA VALUES W_/ZAK/ANALITIKA.
*--BG 2006/05/23
    ENDIF.
*++BG 2006/05/24
    MODIFY $INS_ANALITIKA FROM W_/ZAK/ANALITIKA.
*--BG 2006/05/24
  ENDLOOP.

*++BG 2006/05/23
* /ZAK/ANALITIKA UPDATE
  INSERT /ZAK/ANALITIKA FROM TABLE $INS_ANALITIKA.

*++1365 2013.01.22 Balázs Gábor (Ness)
  IF NOT $INS_AFA_SZLA[] IS INITIAL.
*++1365 #21.
*++1365 #23.
*    SORT $ins_analitika BY bukrs adoazon abevaz szamlasz.
    SORT $INS_ANALITIKA BY BUKRS ADOAZON ABEVAZ BSEG_GJAHR BSEG_BELNR SZAMLASZ.
*--1365 #23.
*--1365 #21.
*++1365 #8.
    LOOP AT $INS_AFA_SZLA INTO W_/ZAK/AFA_SZLA.
*--1365 #8.
      W_/ZAK/AFA_SZLA-PACK = $INS_PACK.
*++1365 #8.
*     Determine the period:
      CLEAR W_/ZAK/ANALITIKA.
*++1365 #23.
*++1765 #14.
*      IF w_/zak/afa_szla-bseg_gjahr IS INITIAL AND
*         w_/zak/afa_szla-bseg_belnr IS INITIAL.
*     We only look at the year because BELNR in AFA_SZLA is filled with
*     the item index, so for example when loading from 901 it could not
*     find a value and therefore the ZINDEX was always 000.
      IF W_/ZAK/AFA_SZLA-BSEG_GJAHR IS INITIAL.
*++1765 #14.
*--1365 #23.
        READ TABLE $INS_ANALITIKA INTO W_/ZAK/ANALITIKA
                   WITH KEY BUKRS    = W_/ZAK/AFA_SZLA-BUKRS
                            ADOAZON  = W_/ZAK/AFA_SZLA-ADOAZON
                            ABEVAZ   = C_ABEVAZ_DUMMY_R
                            SZAMLASZ = W_/ZAK/AFA_SZLA-SZAMLASZ
*++1365 #21.
                            BINARY SEARCH.
*--1365 #21.
*++1365 #23.
      ELSE.
        READ TABLE $INS_ANALITIKA INTO W_/ZAK/ANALITIKA
                   WITH KEY BUKRS    = W_/ZAK/AFA_SZLA-BUKRS
                            ADOAZON  = W_/ZAK/AFA_SZLA-ADOAZON
                            ABEVAZ   = C_ABEVAZ_DUMMY_R
                            BSEG_GJAHR = W_/ZAK/AFA_SZLA-BSEG_GJAHR
                            BSEG_BELNR = W_/ZAK/AFA_SZLA-BSEG_BELNR
                            SZAMLASZ = W_/ZAK/AFA_SZLA-SZAMLASZ
                            BINARY SEARCH.
      ENDIF.
*--1365 #23.
      IF SY-SUBRC EQ 0.
        W_/ZAK/AFA_SZLA-GJAHR  = W_/ZAK/ANALITIKA-GJAHR.
        W_/ZAK/AFA_SZLA-MONAT  = W_/ZAK/ANALITIKA-MONAT.
        W_/ZAK/AFA_SZLA-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
      ENDIF.
*++1365 #14.
      M_RUN_CONV W_/ZAK/AFA_SZLA.
*--1365 #14.
      MODIFY $INS_AFA_SZLA FROM W_/ZAK/AFA_SZLA.
*++1365 #14.
*                           TRANSPORTING PACK GJAHR MONAT ZINDEX.
*--1365 #14.
*                           WHERE PACK NE $INS_PACK.
    ENDLOOP.
*--1365 #8.
    MODIFY /ZAK/AFA_SZLA FROM TABLE $INS_AFA_SZLA.
  ENDIF.
  COMMIT WORK.
*--BG 2006/05/23

* /ZAK/BEVALLI update
  IF NOT $INS_BEVALLI[] IS INITIAL.
    LOOP AT $INS_BEVALLI INTO W_/ZAK/BEVALLI.
      IF W_/ZAK/BEVALLI-ZINDEX = '   '.
        W_/ZAK/BEVALLI-ZINDEX = '000'.
      ENDIF.

      W_/ZAK/BEVALLI-FLAG = 'F'.
*++BG 2006/06/27
      CLEAR W_/ZAK/BEVALLI-DWNDT.
*--BG 2006/06/27
      W_/ZAK/BEVALLI-DATUM = SY-DATUM.
      W_/ZAK/BEVALLI-UZEIT = SY-UZEIT.
      W_/ZAK/BEVALLI-UNAME = SY-UNAME.

      SELECT SINGLE * FROM /ZAK/BEVALLI
*++BG 2006/06/08
*      WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
*            BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
*            GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
*            MONAT EQ W_/ZAK/ANALITIKA-MONAT AND
*            ZINDEX EQ W_/ZAK/ANALITIKA-ZINDEX.
      WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS AND
            BTYPE EQ W_/ZAK/BEVALLI-BTYPE AND
            GJAHR EQ W_/ZAK/BEVALLI-GJAHR AND
            MONAT EQ W_/ZAK/BEVALLI-MONAT AND
            ZINDEX EQ W_/ZAK/BEVALLI-ZINDEX.
*--BG 2006/06/08
*++2009.11.09 BG
*     ONJF self-audit log flag cannot be filled if we modify BEVALLI
*     here because the self-audit log will only be added for a closed
*     period:
      CLEAR W_/ZAK/BEVALLI-ONJF.
*--2009.11.09 BG
      IF SY-SUBRC EQ 0.
        UPDATE /ZAK/BEVALLI FROM W_/ZAK/BEVALLI.
      ELSE.
        INSERT INTO /ZAK/BEVALLI VALUES W_/ZAK/BEVALLI.
      ENDIF.
    ENDLOOP.
  ENDIF.
* UPDATE
  COMMIT WORK AND WAIT.
  IF NOT $INS_PACK IS INITIAL.
    IF $OLD_PACK IS INITIAL.
      PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'I' '033'
                                 $INS_PACK
                                 SY-MSGV2
                                 SY-MSGV3
                                 SY-MSGV4 .
    ELSE.
      PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '034'
                                 $INS_PACK
                                 SY-MSGV2
                                 SY-MSGV3
                                 SY-MSGV4 .
    ENDIF.
  ENDIF.
ENDFORM.                    " INSERT_ABEV_TABLE
*&---------------------------------------------------------------------*
*&      Form  DELETE_ABEV_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ANALITIKA[]  text
*      -->P_I_UPD_BEVALLI[]  text
*      -->P_I_UPD_BEVALLSZ[]  text
*      -->P_V_/ZAK/PACK  text
*----------------------------------------------------------------------*
FORM DELETE_ABEV_TABLE USING    $INS_ANALITIKA LIKE I_/ZAK/ANALITIKA[]
                                $INS_BEVALLI   LIKE I_UPD_BEVALLI[]
                                $INS_BEVALLSZ  LIKE I_UPD_BEVALLSZ[]
                                $INS_PACK      TYPE /ZAK/PACK.


  LOOP AT $INS_ANALITIKA INTO W_/ZAK/ANALITIKA.
    SELECT * FROM /ZAK/ANALITIKA
           WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
                 BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
                 GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
                 MONAT EQ W_/ZAK/ANALITIKA-MONAT AND
                 ZINDEX EQ '000'.
      DELETE /ZAK/ANALITIKA.
    ENDSELECT.
  ENDLOOP.

  LOOP AT $INS_BEVALLI INTO W_/ZAK/BEVALLI.
    SELECT SINGLE * FROM /ZAK/BEVALLI
           WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS AND
                 BTYPE EQ W_/ZAK/BEVALLI-BTYPE AND
                 GJAHR EQ W_/ZAK/BEVALLI-GJAHR AND
                 MONAT EQ W_/ZAK/BEVALLI-MONAT AND
                 FLAG  NE 'X' AND
                 FLAG  NE 'Z'.
    DELETE /ZAK/BEVALLI.
  ENDLOOP.

* UPDATE!!
  COMMIT WORK AND WAIT.
  PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '008'
                             W_/ZAK/ANALITIKA-GJAHR
                             W_/ZAK/ANALITIKA-MONAT
                             SY-MSGV3
                             SY-MSGV4 .
ENDFORM.                    " DELETE_ABEV_TABLE
*&---------------------------------------------------------------------*
*&      Form  DELETE_ABEV_TABLEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ANALITIKA[]  text
*      -->P_I_UPD_BEVALLI[]  text
*      -->P_I_UPD_BEVALLSZ[]  text
*      -->P_V_/ZAK/PACK  text
*----------------------------------------------------------------------*
FORM DELETE_ABEV_TABLEN USING    $INS_ANALITIKA LIKE I_/ZAK/ANALITIKA[]
                                 $INS_BEVALLI   LIKE I_UPD_BEVALLI[]
                                 $PACK          TYPE /ZAK/PACK.


  LOOP AT $INS_ANALITIKA INTO W_/ZAK/ANALITIKA.
*++BG 2006/06/08
* Only delete those records that belong to the old package identifier
*--BG 2006/06/08
    SELECT * FROM /ZAK/ANALITIKA
           WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
                 BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
                 GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
                 MONAT EQ W_/ZAK/ANALITIKA-MONAT AND
*++BG 2006/06/08
*                ZINDEX EQ '000'
*--BG 2006/06/08
                 PACK  EQ $PACK.
      DELETE /ZAK/ANALITIKA.
    ENDSELECT.
  ENDLOOP.

  LOOP AT $INS_BEVALLI INTO W_/ZAK/BEVALLI.
    SELECT SINGLE * FROM /ZAK/BEVALLI
           WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS AND
                 BTYPE EQ W_/ZAK/BEVALLI-BTYPE AND
                 GJAHR EQ W_/ZAK/BEVALLI-GJAHR AND
                 MONAT EQ W_/ZAK/BEVALLI-MONAT AND
                 FLAG  NE 'X' AND
                 FLAG  NE 'Z'.
    DELETE /ZAK/BEVALLI.
  ENDLOOP.

* UPDATE!!
  COMMIT WORK AND WAIT.
  PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '008'
                             W_/ZAK/ANALITIKA-GJAHR
                             W_/ZAK/ANALITIKA-MONAT
                             SY-MSGV3
                             SY-MSGV4 .
ENDFORM.                    " DELETE_ABEV_TABLEN

*&---------------------------------------------------------------------*
*&      Form  MANUAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$ANALITIKA  text
*      -->P_$UPD_BEVALLI  text
*      -->P_$UPD_BEVALLSZ  text
*      -->P_$BEVALLSZ  text
*----------------------------------------------------------------------*
FORM MANUAL USING    $ANALITIKA    LIKE I_/ZAK/ANALITIKA[]
                     $REAL_BEVALLI LIKE I_UPD_BEVALLI[]
                     $REAL_BEVALLSZ LIKE I_UPD_BEVALLSZ[]
                     $UPD_BEVALLI  LIKE I_UPD_BEVALLI[]
                     $UPD_BEVALLSZ LIKE I_UPD_BEVALLSZ[]
                     $BSZNUM       TYPE /ZAK/BSZNUM.
* index
  DATA: L_INDEX(3) TYPE N.

  LOOP AT $ANALITIKA INTO W_/ZAK/ANALITIKA.
    READ TABLE $REAL_BEVALLI INTO W_/ZAK/BEVALLI
                         WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                                  BTYPE = W_/ZAK/ANALITIKA-BTYPE
                                  GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                  MONAT = W_/ZAK/ANALITIKA-MONAT.
    IF SY-SUBRC EQ 0.
* Manual input exists only for open periods!
      IF NOT W_/ZAK/ANALITIKA-ZINDEX IS INITIAL AND
         NOT W_/ZAK/ANALITIKA-ITEM   IS INITIAL.
      ELSE.
        READ TABLE $REAL_BEVALLSZ INTO W_/ZAK/BEVALLSZ
                             WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
                                      BSZNUM = $BSZNUM
                                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                      MONAT = W_/ZAK/ANALITIKA-MONAT.
        IF SY-SUBRC NE 0.
* New BEVALLSZ entry
          MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO W_/ZAK/BEVALLSZ.
          MOVE SY-DATUM               TO W_/ZAK/BEVALLSZ-DATUM.
          MOVE SY-UZEIT               TO W_/ZAK/BEVALLSZ-UZEIT.
          MOVE SY-UNAME               TO W_/ZAK/BEVALLSZ-UNAME.
          W_/ZAK/ANALITIKA-ZINDEX = '000'.
          IF W_/ZAK/BEVALLI-FLAG EQ 'Z' .
            IF W_/ZAK/BEVALLI-ZINDEX EQ '000'.
* Must post to the next open period!
              W_/ZAK/ANALITIKA-ZINDEX = '001'.
              W_/ZAK/BEVALLSZ-ZINDEX  = '001'.
              W_/ZAK/BEVALLI-ZINDEX   = '001'.
            ELSEIF W_/ZAK/BEVALLI-ZINDEX NE '000' AND
                   W_/ZAK/BEVALLI-ZINDEX NE '999'.
* Index + 1 self-audit
*++1765 #25.
*              L_INDEX =  W_/ZAK/BEVALLSZ-ZINDEX + 1.
              L_INDEX =  W_/ZAK/BEVALLI-ZINDEX + 1.
*--1765 #25.
              W_/ZAK/ANALITIKA-ZINDEX = L_INDEX. CLEAR L_INDEX.
              W_/ZAK/BEVALLSZ-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
              W_/ZAK/BEVALLI-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
            ENDIF.
          ELSE.
            MOVE W_/ZAK/BEVALLI-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
          ENDIF.
          MOVE 'F' TO W_/ZAK/BEVALLSZ-FLAG.
          APPEND W_/ZAK/BEVALLSZ TO $UPD_BEVALLSZ.
        ELSE.
          IF W_/ZAK/BEVALLSZ-FLAG EQ 'Z' .
            IF W_/ZAK/BEVALLSZ-ZINDEX EQ '000'.
* Must post to the next open period!
              W_/ZAK/ANALITIKA-ZINDEX = '001'.
              W_/ZAK/BEVALLSZ-ZINDEX  = '001'.
              W_/ZAK/BEVALLI-ZINDEX   = '001'.
            ELSEIF W_/ZAK/BEVALLSZ-ZINDEX NE '000' AND
                   W_/ZAK/BEVALLSZ-ZINDEX NE '999'.
* Index + 1 self-audit
              L_INDEX =  W_/ZAK/BEVALLSZ-ZINDEX + 1.
              W_/ZAK/ANALITIKA-ZINDEX = L_INDEX. CLEAR L_INDEX.
              W_/ZAK/BEVALLSZ-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
              W_/ZAK/BEVALLI-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
            ENDIF.
          ELSE.
            MOVE W_/ZAK/BEVALLI-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
          ENDIF.
          MOVE 'F' TO W_/ZAK/BEVALLSZ-FLAG.
          APPEND W_/ZAK/BEVALLSZ TO $UPD_BEVALLSZ.
        ENDIF.
******
*        MOVE W_/ZAK/BEVALLI-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
      ENDIF.
      MOVE 'F' TO W_/ZAK/BEVALLI-FLAG.
      APPEND W_/ZAK/BEVALLI TO $UPD_BEVALLI.
    ELSE.
      IF NOT W_/ZAK/ANALITIKA-ZINDEX IS INITIAL AND
         NOT W_/ZAK/ANALITIKA-ITEM   IS INITIAL.
      ELSE.
* New BEVALLI entry
        MOVE W_/ZAK/ANALITIKA-BUKRS TO W_UPD_BEVALLI-BUKRS.
        MOVE W_/ZAK/ANALITIKA-BTYPE TO W_UPD_BEVALLI-BTYPE.
        MOVE W_/ZAK/ANALITIKA-GJAHR TO W_UPD_BEVALLI-GJAHR.
        MOVE W_/ZAK/ANALITIKA-MONAT TO W_UPD_BEVALLI-MONAT.
        MOVE '000'                 TO W_UPD_BEVALLI-ZINDEX.
        MOVE SY-DATUM              TO W_UPD_BEVALLI-DATUM.
        MOVE SY-UZEIT              TO W_UPD_BEVALLI-UZEIT.
        MOVE SY-UNAME              TO W_UPD_BEVALLI-UNAME.
        APPEND W_UPD_BEVALLI TO $UPD_BEVALLI.
* New BEVALLSZ entry
        MOVE W_/ZAK/ANALITIKA-BUKRS TO W_UPD_BEVALLSZ-BUKRS.
        MOVE W_/ZAK/ANALITIKA-BTYPE TO W_UPD_BEVALLSZ-BTYPE.
        MOVE W_/ZAK/ANALITIKA-GJAHR TO W_UPD_BEVALLSZ-GJAHR.
        MOVE W_/ZAK/ANALITIKA-BSZNUM TO W_UPD_BEVALLSZ-BSZNUM.
        MOVE W_/ZAK/ANALITIKA-MONAT TO W_UPD_BEVALLSZ-MONAT.
        MOVE '000'                 TO W_UPD_BEVALLSZ-ZINDEX.
        MOVE SY-DATUM              TO W_UPD_BEVALLSZ-DATUM.
        MOVE SY-UZEIT              TO W_UPD_BEVALLSZ-UZEIT.
        MOVE SY-UNAME              TO W_UPD_BEVALLSZ-UNAME.
        APPEND W_UPD_BEVALLSZ TO $UPD_BEVALLSZ.
        W_/ZAK/ANALITIKA-ZINDEX = '000'.
      ENDIF.
      MOVE 'F' TO W_/ZAK/BEVALLI-FLAG.
      MOVE 'F' TO W_/ZAK/BEVALLSZ-FLAG.
    ENDIF.
    MODIFY $ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING ZINDEX.
  ENDLOOP.
* Duplication!
  SORT $UPD_BEVALLI BY BUKRS BTYPE GJAHR MONAT ZINDEX.
  DELETE ADJACENT DUPLICATES FROM $UPD_BEVALLI
                             COMPARING BUKRS BTYPE GJAHR MONAT ZINDEX.
  SORT $UPD_BEVALLSZ BY BUKRS BTYPE BSZNUM GJAHR MONAT ZINDEX.
  DELETE ADJACENT DUPLICATES FROM $UPD_BEVALLSZ
                             COMPARING BUKRS BTYPE BSZNUM GJAHR MONAT
                                                               ZINDEX.

*++BG 2011.09.14
* Group company extensions
  PERFORM GET_CS_BUKRS TABLES $UPD_BEVALLI
                              $UPD_BEVALLSZ.
*--BG 2011.09.14


ENDFORM.                    " MANUAL
*&---------------------------------------------------------------------*
*&      Form  general
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$ANALITIKA  text
*      -->P_I_/ZAK/BEVALLI  text
*      -->P_$UPD_BEVALLI  text
*      -->P_$UPD_BEVALLSZ  text
*      -->P_$BSZNUM  text
*----------------------------------------------------------------------*
FORM GENERAL  USING  $ANALITIKA    LIKE I_/ZAK/ANALITIKA[]
                     $REAL_BEVALLI LIKE I_UPD_BEVALLI[]
                     $REAL_BEVALLSZ LIKE I_UPD_BEVALLSZ[]
                     $UPD_BEVALLI  LIKE I_UPD_BEVALLI[]
                     $UPD_BEVALLSZ LIKE I_UPD_BEVALLSZ[]
                     $BSZNUM       TYPE /ZAK/BSZNUM
                     $PACK         TYPE /ZAK/PACK.
*++1908 #03.
  DATA LW_SAVE_BEVALLSZ TYPE /ZAK/BEVALLSZ.
*--1908 #03.

* index
  DATA: L_INDEX(3) TYPE N.
  LOOP AT $ANALITIKA INTO W_/ZAK/ANALITIKA.
    READ TABLE $REAL_BEVALLSZ INTO W_/ZAK/BEVALLSZ
                         WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                                  BTYPE = W_/ZAK/ANALITIKA-BTYPE
                                  BSZNUM = $BSZNUM
                                  GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                  MONAT = W_/ZAK/ANALITIKA-MONAT
                                  .
    IF $PACK IS INITIAL.
      IF SY-SUBRC EQ 0.
        READ TABLE $REAL_BEVALLI INTO W_/ZAK/BEVALLI
                             WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
                                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                      MONAT = W_/ZAK/ANALITIKA-MONAT.

        IF W_/ZAK/BEVALLSZ-FLAG EQ 'X'.

          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '037'
                                  W_/ZAK/ANALITIKA-GJAHR
                                  W_/ZAK/ANALITIKA-MONAT
                                  SY-MSGV3
                                  SY-MSGV4 .

*++BG 2006/06/20
* Incorrect because with status "X" it also gave the next serial number
* instead of the first serial number of the next period.
*          IF W_/ZAK/BEVALLSZ-ZINDEX EQ '000'.
** Must post to the next open period!
*            W_/ZAK/ANALITIKA-ZINDEX = '001'.
*            W_/ZAK/BEVALLSZ-ZINDEX  = '001'.
*            W_/ZAK/BEVALLI-ZINDEX   = '001'.
*          ELSEIF W_/ZAK/BEVALLSZ-ZINDEX NE '000' AND
*                 W_/ZAK/BEVALLSZ-ZINDEX NE '999'.
** Index + 1 self-audit
*            L_INDEX =  W_/ZAK/BEVALLSZ-ZINDEX + 1.
*            W_/ZAK/ANALITIKA-ZINDEX = L_INDEX. CLEAR L_INDEX.
*            W_/ZAK/BEVALLSZ-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
*            W_/ZAK/BEVALLI-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
*          ENDIF.
          PERFORM GET_NEXT_ZINDEX USING W_/ZAK/ANALITIKA
                                        W_/ZAK/BEVALLSZ
                                        W_/ZAK/BEVALLI.

*--BG 2006/06/20
        ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'Z'.

          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '023'
                                  W_/ZAK/ANALITIKA-GJAHR
                                  W_/ZAK/ANALITIKA-MONAT
                                  SY-MSGV3
                                  SY-MSGV4 .
          IF W_/ZAK/BEVALLSZ-ZINDEX EQ '000'.

* Self-audit! 001
            W_/ZAK/ANALITIKA-ZINDEX = '001'.
            W_/ZAK/BEVALLSZ-ZINDEX  = '001'.
            W_/ZAK/BEVALLI-ZINDEX   = '001'.
          ELSEIF W_/ZAK/BEVALLSZ-ZINDEX NE '000' AND
                 W_/ZAK/BEVALLSZ-ZINDEX NE '999'.

*         Index + 1 self-audit
            L_INDEX =  W_/ZAK/BEVALLSZ-ZINDEX + 1.

            W_/ZAK/ANALITIKA-ZINDEX = L_INDEX. CLEAR L_INDEX.
            W_/ZAK/BEVALLI-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
            W_/ZAK/BEVALLSZ-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
          ENDIF.
        ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'B'.

          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '035'
                                  W_/ZAK/ANALITIKA-GJAHR
                                  W_/ZAK/ANALITIKA-MONAT
                                  ''
                                  '' .
          MOVE W_/ZAK/BEVALLSZ-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
        ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'F'.
*++2508 #04.
**++1908 #03.
**         Also read from the database because the found record might be generated,
**         but only once per period.
*          IF LW_SAVE_BEVALLSZ NE W_/ZAK/BEVALLSZ.
*            SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALLSZ
*                                    WHERE BUKRS  EQ W_/ZAK/BEVALLSZ-BUKRS
*                                      AND BTYPE  EQ W_/ZAK/BEVALLSZ-BTYPE
*                                      AND BSZNUM EQ W_/ZAK/BEVALLSZ-BSZNUM
*                                      AND GJAHR  EQ W_/ZAK/BEVALLSZ-GJAHR
*                                      AND MONAT  EQ W_/ZAK/BEVALLSZ-MONAT
*                                      AND ZINDEX EQ W_/ZAK/BEVALLSZ-ZINDEX.
*            IF SY-SUBRC EQ 0.
**--1908 #03.
*                PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '060'
*                                        W_/ZAK/ANALITIKA-GJAHR
*                                        W_/ZAK/ANALITIKA-MONAT
*                                        ''
*                                        '' .
**++1908 #03.
*            ENDIF.
*            LW_SAVE_BEVALLSZ = W_/ZAK/BEVALLSZ.
*          ENDIF.
**--1908 #03.
*--2508 #04.
*++BG 2006/06/12
*          W_/ZAK/ANALITIKA-ZINDEX = '000'.
*          W_/ZAK/BEVALLSZ-ZINDEX = '000'.
*          W_/ZAK/BEVALLI-ZINDEX = '000'.
          MOVE W_/ZAK/BEVALLSZ-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
*--BG 2006/06/12
        ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'T'.

          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '075'
                                  W_/ZAK/ANALITIKA-GJAHR
                                  W_/ZAK/ANALITIKA-MONAT
                                  ''
                                  '' .
*++BG 2006/06/12
*          W_/ZAK/ANALITIKA-ZINDEX = '000'.
*          W_/ZAK/BEVALLSZ-ZINDEX = '000'.
*          W_/ZAK/BEVALLI-ZINDEX = '000'.
          MOVE W_/ZAK/BEVALLSZ-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
*--BG 2006/06/12
*++2308 #06.
*       For example, in the case of "E" released data service, even if it is already set
*       the index must be taken over because otherwise it becomes 000, which causes an error!
        ELSE.
          MOVE W_/ZAK/BEVALLSZ-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
*--2308 #06.
        ENDIF.
*++2508 #04.
*         Also read from the database because the found record might be generated,
*         but only once per period.
        IF LW_SAVE_BEVALLSZ NE W_/ZAK/BEVALLSZ.
          SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALLSZ
                                  WHERE BUKRS  EQ W_/ZAK/BEVALLSZ-BUKRS
                                    AND BTYPE  EQ W_/ZAK/BEVALLSZ-BTYPE
                                    AND BSZNUM EQ W_/ZAK/BEVALLSZ-BSZNUM
                                    AND GJAHR  EQ W_/ZAK/BEVALLSZ-GJAHR
                                    AND MONAT  EQ W_/ZAK/BEVALLSZ-MONAT
                                    AND ZINDEX EQ W_/ZAK/BEVALLSZ-ZINDEX.
          IF SY-SUBRC EQ 0.
            SELECT SINGLE XFULL INTO W_/ZAK/BEVALLD-XFULL
                                FROM /ZAK/BEVALLD
                               WHERE BUKRS EQ W_/ZAK/BEVALLSZ-BUKRS
                                 AND BTYPE EQ W_/ZAK/BEVALLSZ-BTYPE
                                 AND BSZNUM EQ W_/ZAK/BEVALLSZ-BSZNUM.
            IF SY-SUBRC EQ 0 AND NOT W_/ZAK/BEVALLD-XFULL IS INITIAL.
              PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '060'
                                      W_/ZAK/ANALITIKA-GJAHR
                                      W_/ZAK/ANALITIKA-MONAT
                                      ''
                                      '' .
            ELSE.

              PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '060'
                                      W_/ZAK/ANALITIKA-GJAHR
                                      W_/ZAK/ANALITIKA-MONAT
                                      ''
                                      '' .

            ENDIF.
          ENDIF.
          LW_SAVE_BEVALLSZ = W_/ZAK/BEVALLSZ.
        ENDIF.
*--2508 #04.
*        READ TABLE $REAL_BEVALLSZ INTO W_/ZAK/BEVALLSZ
*                             WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
*                                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
*                                      BSZNUM = $BSZNUM
*                                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
*                                      MONAT = W_/ZAK/ANALITIKA-MONAT
*                                      .
*        IF W_/ZAK/BEVALLSZ-FLAG EQ 'E'.
** Cannot upload data for the given period!
*          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '027'
*                                       W_/ZAK/ANALITIKA-GJAHR
*                                       W_/ZAK/ANALITIKA-MONAT
*                                       SY-MSGV3
*                                       SY-MSGV4 .
*
*        ENDIF.
        MOVE 'F' TO W_/ZAK/BEVALLI-FLAG.
        MOVE 'F' TO W_/ZAK/BEVALLSZ-FLAG.

        READ TABLE I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD
                   WITH KEY BUKRS  = W_/ZAK/ANALITIKA-BUKRS
                            BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                            BSZNUM = W_/ZAK/ANALITIKA-BSZNUM
                            XSPEC  = ' '.
        IF SY-SUBRC EQ 0.
          APPEND W_/ZAK/BEVALLI TO $UPD_BEVALLI.
          APPEND W_/ZAK/BEVALLSZ TO $UPD_BEVALLSZ.
        ENDIF.
      ELSE.
*++1565 #12.
        LOOP AT $REAL_BEVALLI INTO W_UPD_BEVALLI
                             WHERE    BUKRS = W_/ZAK/ANALITIKA-BUKRS
                               AND    BTYPE = W_/ZAK/ANALITIKA-BTYPE
                               AND    GJAHR = W_/ZAK/ANALITIKA-GJAHR
                               AND    MONAT = W_/ZAK/ANALITIKA-MONAT
                               AND    FLAG  NA 'ZX'.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC EQ 0.
          MOVE 'F'                   TO W_UPD_BEVALLI-FLAG.
          MOVE SY-DATUM              TO W_UPD_BEVALLI-DATUM.
          MOVE SY-UZEIT              TO W_UPD_BEVALLI-UZEIT.
          MOVE SY-UNAME              TO W_UPD_BEVALLI-UNAME.
          APPEND W_UPD_BEVALLI TO $UPD_BEVALLI.
* New BEVALLSZ entry
          MOVE-CORRESPONDING W_UPD_BEVALLI TO W_UPD_BEVALLSZ.
          MOVE $BSZNUM               TO W_UPD_BEVALLSZ-BSZNUM.
          APPEND W_UPD_BEVALLSZ TO $UPD_BEVALLSZ.
          W_/ZAK/ANALITIKA-ZINDEX = W_UPD_BEVALLI-ZINDEX.
        ELSE.
*--1565 #12.
* New BEVALLI entry
          MOVE W_/ZAK/ANALITIKA-BUKRS TO W_UPD_BEVALLI-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE TO W_UPD_BEVALLI-BTYPE.
          MOVE W_/ZAK/ANALITIKA-GJAHR TO W_UPD_BEVALLI-GJAHR.
          MOVE W_/ZAK/ANALITIKA-MONAT TO W_UPD_BEVALLI-MONAT.
          MOVE '000'                 TO W_UPD_BEVALLI-ZINDEX.
          MOVE 'F'                   TO W_UPD_BEVALLI-FLAG.
          MOVE SY-DATUM              TO W_UPD_BEVALLI-DATUM.
          MOVE SY-UZEIT              TO W_UPD_BEVALLI-UZEIT.
          MOVE SY-UNAME              TO W_UPD_BEVALLI-UNAME.
          APPEND W_UPD_BEVALLI TO $UPD_BEVALLI.
* New BEVALLSZ entry
          MOVE W_/ZAK/ANALITIKA-BUKRS TO W_UPD_BEVALLSZ-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE TO W_UPD_BEVALLSZ-BTYPE.
          MOVE W_/ZAK/ANALITIKA-GJAHR TO W_UPD_BEVALLSZ-GJAHR.
          MOVE $BSZNUM               TO W_UPD_BEVALLSZ-BSZNUM.
          MOVE W_/ZAK/ANALITIKA-MONAT TO W_UPD_BEVALLSZ-MONAT.
          MOVE 'F'                   TO W_UPD_BEVALLSZ-FLAG.
          MOVE '000'                 TO W_UPD_BEVALLSZ-ZINDEX.
          MOVE SY-DATUM              TO W_UPD_BEVALLSZ-DATUM.
          MOVE SY-UZEIT              TO W_UPD_BEVALLSZ-UZEIT.
          MOVE SY-UNAME              TO W_UPD_BEVALLSZ-UNAME.
          APPEND W_UPD_BEVALLSZ TO $UPD_BEVALLSZ.
          W_/ZAK/ANALITIKA-ZINDEX = '000'.
*++1565 #12.
        ENDIF.
*--1565 #12.
      ENDIF.
    ELSE.
* Repeated load!
      IF SY-SUBRC EQ 0.
        IF W_/ZAK/BEVALLSZ-FLAG EQ 'X' OR
           W_/ZAK/BEVALLSZ-FLAG EQ 'Z'.
          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '039'
                                  W_/ZAK/ANALITIKA-GJAHR
                                  W_/ZAK/ANALITIKA-MONAT
                                  SY-MSGV3
                                  SY-MSGV4 .
        ELSEIF W_/ZAK/BEVALLSZ-FLAG EQ 'B' OR
               W_/ZAK/BEVALLSZ-FLAG EQ 'F'.
          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'W' '035'
                                  W_/ZAK/ANALITIKA-GJAHR
                                  W_/ZAK/ANALITIKA-MONAT
                                  ''
                                  '' .
          MOVE W_/ZAK/BEVALLSZ-ZINDEX TO W_/ZAK/ANALITIKA-ZINDEX.
        ENDIF.
*        READ TABLE $REAL_BEVALLSZ INTO W_/ZAK/BEVALLSZ
*                             WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
*                                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
*                                      BSZNUM = $BSZNUM
*                                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
*                                      MONAT = W_/ZAK/ANALITIKA-MONAT
*                                      .
*        IF W_/ZAK/BEVALLSZ-FLAG EQ 'E'.
** Cannot upload data for the given period!
*          PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '027'
*                                       W_/ZAK/ANALITIKA-GJAHR
*                                       W_/ZAK/ANALITIKA-MONAT
*                                       SY-MSGV3
*                                       SY-MSGV4 .
*
*        ENDIF.
*++2012.04.03 Balázs Gábor (Ness)
        READ TABLE $REAL_BEVALLI INTO W_/ZAK/BEVALLI
                             WITH KEY BUKRS = W_/ZAK/ANALITIKA-BUKRS
                                      BTYPE = W_/ZAK/ANALITIKA-BTYPE
                                      GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                      MONAT = W_/ZAK/ANALITIKA-MONAT.
*--2012.04.03 Balázs Gábor (Ness)
        MOVE 'F' TO W_/ZAK/BEVALLI-FLAG.
        MOVE 'F' TO W_/ZAK/BEVALLSZ-FLAG.
        READ TABLE I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD
                   WITH KEY BUKRS  = W_/ZAK/ANALITIKA-BUKRS
                            BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                            BSZNUM = W_/ZAK/ANALITIKA-BSZNUM
                            XSPEC  = ' '.
        IF SY-SUBRC EQ 0.
          APPEND W_/ZAK/BEVALLI TO $UPD_BEVALLI.
          APPEND W_/ZAK/BEVALLSZ TO $UPD_BEVALLSZ.
        ENDIF.
*        PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'I' '027'
*                                     $PACK
*                                     SY-MSGV2
*                                     SY-MSGV3
*                                     SY-MSGV4 .
      ELSE.
*++1565 #12.
        LOOP AT $REAL_BEVALLI INTO W_UPD_BEVALLI
                             WHERE    BUKRS = W_/ZAK/ANALITIKA-BUKRS
                               AND    BTYPE = W_/ZAK/ANALITIKA-BTYPE
                               AND    GJAHR = W_/ZAK/ANALITIKA-GJAHR
                               AND    MONAT = W_/ZAK/ANALITIKA-MONAT
                               AND    FLAG  NA 'ZX'.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC EQ 0.
          MOVE 'F'                   TO W_UPD_BEVALLI-FLAG.
          MOVE SY-DATUM              TO W_UPD_BEVALLI-DATUM.
          MOVE SY-UZEIT              TO W_UPD_BEVALLI-UZEIT.
          MOVE SY-UNAME              TO W_UPD_BEVALLI-UNAME.
          APPEND W_UPD_BEVALLI TO $UPD_BEVALLI.
* New BEVALLSZ entry
          MOVE-CORRESPONDING W_UPD_BEVALLI TO W_UPD_BEVALLSZ.
          MOVE $BSZNUM               TO W_UPD_BEVALLSZ-BSZNUM.
          APPEND W_UPD_BEVALLSZ TO $UPD_BEVALLSZ.
          W_/ZAK/ANALITIKA-ZINDEX = W_UPD_BEVALLI-ZINDEX.
        ELSE.
*--1565 #12.
* New BEVALLI entry
          MOVE W_/ZAK/ANALITIKA-BUKRS TO W_UPD_BEVALLI-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE TO W_UPD_BEVALLI-BTYPE.
          MOVE W_/ZAK/ANALITIKA-GJAHR TO W_UPD_BEVALLI-GJAHR.
          MOVE W_/ZAK/ANALITIKA-MONAT TO W_UPD_BEVALLI-MONAT.
          MOVE 'F'                   TO W_UPD_BEVALLI-FLAG.
          MOVE '000'                 TO W_UPD_BEVALLI-ZINDEX.
          MOVE SY-DATUM              TO W_UPD_BEVALLI-DATUM.
          MOVE SY-UZEIT              TO W_UPD_BEVALLI-UZEIT.
          MOVE SY-UNAME              TO W_UPD_BEVALLI-UNAME.
          APPEND W_UPD_BEVALLI TO $UPD_BEVALLI.
* New BEVALLSZ entry
          MOVE W_/ZAK/ANALITIKA-BUKRS TO W_UPD_BEVALLSZ-BUKRS.
          MOVE W_/ZAK/ANALITIKA-BTYPE TO W_UPD_BEVALLSZ-BTYPE.
          MOVE W_/ZAK/ANALITIKA-GJAHR TO W_UPD_BEVALLSZ-GJAHR.
          MOVE $BSZNUM               TO W_UPD_BEVALLSZ-BSZNUM.
          MOVE W_/ZAK/ANALITIKA-MONAT TO W_UPD_BEVALLSZ-MONAT.
          MOVE 'F'                   TO W_UPD_BEVALLSZ-FLAG.
          MOVE '000'                 TO W_UPD_BEVALLSZ-ZINDEX.
          MOVE SY-DATUM              TO W_UPD_BEVALLSZ-DATUM.
          MOVE SY-UZEIT              TO W_UPD_BEVALLSZ-UZEIT.
          MOVE SY-UNAME              TO W_UPD_BEVALLSZ-UNAME.
          APPEND W_UPD_BEVALLSZ TO $UPD_BEVALLSZ.
          W_/ZAK/ANALITIKA-ZINDEX = '000'.
*++1565 #12.
        ENDIF.
*--1565 #12.
      ENDIF.
* End of repeated load
    ENDIF.
*++2009.09.18 BG (NESS)
*    MODIFY $ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING GJAHR
*                                                        MONAT
*                                                        ZINDEX.
    MODIFY $ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING BTYPE
                                                        GJAHR
                                                        MONAT
                                                        ZINDEX
                                                        ABEVAZ.
*--2009.09.18 BG (NESS)

  ENDLOOP.


* Duplication!
  SORT $UPD_BEVALLI BY BUKRS BTYPE GJAHR MONAT ZINDEX.
  DELETE ADJACENT DUPLICATES FROM $UPD_BEVALLI
                             COMPARING BUKRS BTYPE GJAHR MONAT ZINDEX.
  SORT $UPD_BEVALLSZ BY BUKRS BTYPE BSZNUM GJAHR MONAT ZINDEX.
  DELETE ADJACENT DUPLICATES FROM $UPD_BEVALLSZ
                             COMPARING BUKRS BTYPE BSZNUM GJAHR MONAT.

*++BG 2011.09.14
* Group company extensions
  PERFORM GET_CS_BUKRS TABLES $UPD_BEVALLI
                              $UPD_BEVALLSZ.
*--BG 2011.09.14

ENDFORM.                    " general
*&---------------------------------------------------------------------*
*&      Form  get_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_$ANALITIKA  text
*----------------------------------------------------------------------*
FORM GET_ITEM CHANGING $UPD_ANALITIKA TYPE /ZAK/ANALITIKA.

  DATA: L_ITEM LIKE /ZAK/ANALITIKA-ITEM.
  CLEAR /ZAK/ANALITIKA.

* Last item number
  SELECT MAX( ITEM ) INTO L_ITEM FROM /ZAK/ANALITIKA
     WHERE BUKRS   = $UPD_ANALITIKA-BUKRS
       AND BTYPE   = $UPD_ANALITIKA-BTYPE
       AND GJAHR   = $UPD_ANALITIKA-GJAHR
       AND MONAT   = $UPD_ANALITIKA-MONAT
       AND ZINDEX  = $UPD_ANALITIKA-ZINDEX
       AND ABEVAZ  = $UPD_ANALITIKA-ABEVAZ
       AND ADOAZON = $UPD_ANALITIKA-ADOAZON
       AND BSZNUM  = $UPD_ANALITIKA-BSZNUM.
*       AND PACK    = $UPD_ANALITIKA-PACK.
  L_ITEM = L_ITEM + 1.

  $UPD_ANALITIKA-ITEM  = L_ITEM.

ENDFORM.                    " get_item
*&---------------------------------------------------------------------*
*&      Form  STAT_TO_ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ANALITIKA[]  text
*      -->P_I_PACK  text
*----------------------------------------------------------------------*
FORM STAT_TO_ANALITIKA USING    $INS_ANALITIKA LIKE I_/ZAK/ANALITIKA[]
                                $BUKRS
                                $BTYPE         TYPE /ZAK/BTYPE
                                $BTYPART       TYPE /ZAK/BTYPART
                                $INS_PACK      TYPE /ZAK/PACK.
  DATA: L_INDEX(3)  TYPE N,
        L_GJAHR     LIKE /ZAK/ANALITIKA-GJAHR,
        L_MONAT_TOL LIKE /ZAK/ANALITIKA-MONAT,
        L_MONAT_IG  LIKE /ZAK/ANALITIKA-MONAT,
        L_BIDOSZ    LIKE /ZAK/BEVALL-BIDOSZ.

*++ BG 2006.03.23
  DATA:  L_ITEM LIKE /ZAK/ANALITIKA-ITEM.
*-- BG 2006.03.23


  SELECT SINGLE * FROM /ZAK/BEVALL INTO W_/ZAK/BEVALL
         WHERE BUKRS EQ $BUKRS AND
               BTYPE EQ $BTYPE.
  IF W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_SZJA OR
     W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_TARS OR
     W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_UCS .

    LOOP AT $INS_ANALITIKA INTO W_/ZAK/ANALITIKA.
      L_GJAHR = W_/ZAK/ANALITIKA-GJAHR.
      L_MONAT_TOL = W_/ZAK/ANALITIKA-MONAT.
      AT NEW MONAT.
        CALL FUNCTION '/ZAK/SET_PERIOD'
          EXPORTING
            I_BUKRS     = $BUKRS
            I_BTYPE     = $BTYPE
            I_GJAHR     = L_GJAHR
            I_MONAT     = L_MONAT_TOL
          IMPORTING
            E_GJAHR     = L_GJAHR
            E_MONAT_TOL = L_MONAT_TOL
            E_MONAT_IG  = L_MONAT_IG
            E_BIDOSZ    = L_BIDOSZ.

        PERFORM SET_RANGES USING L_MONAT_TOL
                                 L_MONAT_IG
                                 W_/ZAK/ANALITIKA-MONAT.
      ENDAT.
      CLEAR L_INDEX.
      IF W_/ZAK/ANALITIKA-ZINDEX NE '000'.
        L_INDEX = W_/ZAK/ANALITIKA-ZINDEX - 1.

        SELECT SINGLE * FROM /ZAK/ANALITIKA
        WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
              BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
              GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
              MONAT IN R_MONAT AND
              ZINDEX EQ L_INDEX AND
              ABEVAZ EQ W_/ZAK/ANALITIKA-ABEVAZ AND
              ADOAZON EQ W_/ZAK/ANALITIKA-ADOAZON AND
              BSZNUM EQ W_/ZAK/ANALITIKA-BSZNUM.
        IF SY-SUBRC EQ 0.
          /ZAK/ANALITIKA-STAPO = 'X'.
          MODIFY /ZAK/ANALITIKA.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " STAT_TO_ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  SET_RANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_MONAT_TOL  text
*      -->P_L_MONAT_IG  text
*      -->P_W_/ZAK/ANALITIKA_MONAT  text
*----------------------------------------------------------------------*
FORM SET_RANGES USING    $TOL
                         $IG
                         $ANALITIKA_MON.

  REFRESH R_MONAT.
  R_MONAT-SIGN   = 'I'.
  IF $TOL = $IG.
    R_MONAT-OPTION = 'EQ'.
    R_MONAT-LOW    = $ANALITIKA_MON.
    R_MONAT-HIGH   = $ANALITIKA_MON.
  ELSE.
    R_MONAT-OPTION = 'BT'.
    R_MONAT-LOW    = $TOL.
    R_MONAT-HIGH   = $IG.
  ENDIF.
  APPEND R_MONAT.
ENDFORM.                    " set_ranges
*&---------------------------------------------------------------------*
*&      Form  GET_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ANALITIKA  text
*      -->P_I_BTYPART  text
*----------------------------------------------------------------------*
FORM GET_BTYPE TABLES   $ANALITIKA STRUCTURE /ZAK/ANALITIKA
               USING    $BUKRS
                        $BTYPART.

* Return type per period
  DATA: BEGIN OF LI_BTYPE OCCURS 0,
          GJAHR TYPE GJAHR,
          MONAT TYPE MONAT,
          BTYPE TYPE /ZAK/BTYPE,
        END OF LI_BTYPE.


  LOOP AT $ANALITIKA INTO W_/ZAK/ANALITIKA.
* Read which BTYPE belongs to it
    READ TABLE LI_BTYPE WITH KEY GJAHR = W_/ZAK/ANALITIKA-GJAHR
                                 MONAT = W_/ZAK/ANALITIKA-MONAT
                                 BINARY SEARCH.
*   If not found, determine it
    IF SY-SUBRC NE 0.
      CLEAR LI_BTYPE.
      CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
        EXPORTING
          I_BUKRS     = $BUKRS
          I_BTYPART   = $BTYPART
          I_GJAHR     = W_/ZAK/ANALITIKA-GJAHR
          I_MONAT     = W_/ZAK/ANALITIKA-MONAT
        IMPORTING
          E_BTYPE     = LI_BTYPE-BTYPE
        EXCEPTIONS
          ERROR_MONAT = 1
          ERROR_BTYPE = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
        PERFORM ERROR_HANDLING USING SY-MSGID SY-MSGTY SY-MSGNO
                                     SY-MSGV1 SY-MSGV2 SY-MSGV3
                                     SY-MSGV4.
      ENDIF.
      MOVE  W_/ZAK/ANALITIKA-GJAHR TO LI_BTYPE-GJAHR.
      MOVE  W_/ZAK/ANALITIKA-MONAT TO LI_BTYPE-MONAT.
      APPEND LI_BTYPE. SORT LI_BTYPE BY GJAHR MONAT.
    ENDIF.
*   Write back the BTYPE
    MOVE LI_BTYPE-BTYPE TO W_/ZAK/ANALITIKA-BTYPE.
    MODIFY $ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING BTYPE.
  ENDLOOP.



ENDFORM.                    " GET_BTYPE
*&---------------------------------------------------------------------*
*&      Form  process_ind_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_INDEX  text
*----------------------------------------------------------------------*
FORM PROCESS_IND_ITEM USING   $VALUE
                              $INDEX
                              $TEXT.
*  Only during dialog execution
  CHECK SY-BATCH IS INITIAL.
  ADD 1 TO $INDEX.
  IF $INDEX EQ $VALUE.
    PERFORM PROCESS_IND USING $TEXT.
    CLEAR $INDEX.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " process_ind_item

*&---------------------------------------------------------------------*
*&      Form  PROCESS_IND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_P01  text
*----------------------------------------------------------------------*
FORM PROCESS_IND USING $TEXT.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      TEXT = $TEXT.

ENDFORM.                    " process_ind
*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_ZINDEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/ANALITIKA  text
*      -->P_W_/ZAK/BEVALLSZ  text
*      -->P_W_/ZAK/BEVALLI  text
*----------------------------------------------------------------------*
FORM GET_NEXT_ZINDEX USING    $/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                              $/ZAK/BEVALLSZ  STRUCTURE /ZAK/BEVALLSZ
                              $/ZAK/BEVALLI   STRUCTURE /ZAK/BEVALLI.

  DATA LW_BEVALLSZ LIKE /ZAK/BEVALLSZ.
  DATA LW_BEVALLI  LIKE /ZAK/BEVALLI.
  DATA L_GJAHR     LIKE /ZAK/BEVALLI-GJAHR.
  DATA L_MONAT     LIKE /ZAK/BEVALLI-MONAT.
  DATA L_ZINDEX    LIKE /ZAK/BEVALLI-ZINDEX.
  DATA L_FLAG      LIKE /ZAK/BEVALLI-FLAG.
  DATA L_BTYPE     LIKE /ZAK/BEVALLI-BTYPE.
  DATA L_BTYPART   TYPE  /ZAK/BTYPART.
*--2009.09.18 BG (NESS)
  DATA LI_ABEV_CONTACT LIKE /ZAK/ABEVCONTACT OCCURS 0
                                        WITH HEADER LINE.
  DATA L_TABIX LIKE SY-TABIX.
*++2009.09.18 BG (NESS)


*If the FLAG is 'X', the next period is needed.
  IF $/ZAK/BEVALLSZ-FLAG EQ 'X'.
*  Determine the next open period.
    IF $/ZAK/BEVALLSZ-MONAT = '12'.
      L_GJAHR = $/ZAK/BEVALLSZ-GJAHR + 1.
      L_MONAT = '01'.
*     Need to convert the BTYPE
      SELECT SINGLE BTYPART INTO L_BTYPART
                            FROM /ZAK/BEVALL
                           WHERE BUKRS = $/ZAK/BEVALLSZ-BUKRS
                             AND BTYPE = $/ZAK/BEVALLSZ-BTYPE.
      IF SY-SUBRC NE 0.
        MESSAGE A180(/ZAK/ZAK) WITH $/ZAK/BEVALLSZ-BTYPE.
*       Error determining the & return type variant!
      ENDIF.
*     Determine the return type.
      CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
        EXPORTING
          I_BUKRS     = $/ZAK/BEVALLSZ-BUKRS
          I_BTYPART   = L_BTYPART
          I_GJAHR     = L_GJAHR
          I_MONAT     = L_MONAT
        IMPORTING
          E_BTYPE     = L_BTYPE
        EXCEPTIONS
          ERROR_MONAT = 1
          ERROR_BTYPE = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ELSE.
      L_GJAHR = $/ZAK/BEVALLSZ-GJAHR.
      L_MONAT = $/ZAK/BEVALLSZ-MONAT + 1.
      L_BTYPE = $/ZAK/BEVALLI-BTYPE.
    ENDIF.

    DO.
*++2008.11.21 BG (Fmc)
*  Nem volt helyes a SELECT mivel a GROUP BY elrontotta
*  Pld. volt a /ZAK/BEVALLI-ben 001 Z, 002 Z, 003 Z ebben az
*  In this case the SELECT returned 001 Z instead of 003 Z
*      SELECT  MAX( ZINDEX ) FLAG
*                             INTO (LW_BEVALLI-ZINDEX,
*                                   LW_BEVALLI-FLAG)
*                                  FROM /ZAK/BEVALLI
*                                 WHERE BUKRS = $/ZAK/BEVALLSZ-BUKRS
*                                   AND BTYPE = L_BTYPE
*                                   AND GJAHR = L_GJAHR
*                                   AND MONAT = L_MONAT
*                                   GROUP BY BUKRS BTYPE GJAHR MONAT
*                                            ZINDEX FLAG.
*      ENDSELECT.
      SELECT MAX( ZINDEX ) INTO LW_BEVALLI-ZINDEX
                           FROM /ZAK/BEVALLI
                          WHERE BUKRS = $/ZAK/BEVALLSZ-BUKRS
                            AND BTYPE = L_BTYPE
                            AND GJAHR = L_GJAHR
                            AND MONAT = L_MONAT.
*--2008.11.21 BG (Fmc)
*     No next period is open yet; it becomes '000'.
*++2009.09.18 BG (NESS)
*     SY-SUBRC is 0 even if no entry matches the key
*     therefore this must not be checked:
*     IF SY-SUBRC NE 0.
      IF LW_BEVALLI-ZINDEX IS INITIAL.
*--2009.09.18 BG (NESS)
        L_ZINDEX = '000'.
*++2008.11.21 BG (Fmc)
      ELSE.
*       Determine the FLAG
        SELECT SINGLE FLAG   INTO LW_BEVALLI-FLAG
                             FROM /ZAK/BEVALLI
                            WHERE BUKRS = $/ZAK/BEVALLSZ-BUKRS
                              AND BTYPE = L_BTYPE
                              AND GJAHR = L_GJAHR
                              AND MONAT = L_MONAT
                              AND ZINDEX = LW_BEVALLI-ZINDEX.
*       If the next period is also audited by the tax authority we continue
*       ELSEIF LW_BEVALLI-FLAG CA 'X'.
        IF LW_BEVALLI-FLAG CA 'X'.
*--2008.11.21 BG (Fmc)
          CLEAR   L_ZINDEX.
*       Determine the next open period.
          IF L_MONAT = '12'.
            L_GJAHR = L_GJAHR + 1.
            L_MONAT = '01'.

*     Need to convert the BTYPE
            SELECT SINGLE BTYPART INTO L_BTYPART
                                  FROM /ZAK/BEVALL
                                 WHERE BUKRS = $/ZAK/BEVALLSZ-BUKRS
                                   AND BTYPE = L_BTYPE.
            IF SY-SUBRC NE 0.
              MESSAGE A180(/ZAK/ZAK) WITH $/ZAK/BEVALLSZ-BTYPE.
*       Error determining the & return type variant!
            ENDIF.
*     Determine the return type.
            CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
              EXPORTING
                I_BUKRS     = $/ZAK/BEVALLSZ-BUKRS
                I_BTYPART   = L_BTYPART
                I_GJAHR     = L_GJAHR
                I_MONAT     = L_MONAT
              IMPORTING
                E_BTYPE     = L_BTYPE
              EXCEPTIONS
                ERROR_MONAT = 1
                ERROR_BTYPE = 2
                OTHERS      = 3.
            IF SY-SUBRC <> 0.
              MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*++2009.09.18 BG (NESS)
*           BTYPE change, start over
            ELSE.
              L_MONAT = 1.
*--2009.09.18 BG (NESS)
            ENDIF.
          ELSE.
            L_MONAT = L_MONAT + 1.
          ENDIF.
*     Next period closed
        ELSEIF LW_BEVALLI-FLAG EQ 'Z'.
          L_ZINDEX = LW_BEVALLI-ZINDEX + 1.
*     Next period open, assign it here
        ELSE.
          L_ZINDEX = LW_BEVALLI-ZINDEX.
        ENDIF.
*++2008.11.21 BG (Fmc)
      ENDIF.
*--2008.11.21 BG (Fmc)
*     Exit once found
      IF NOT L_ZINDEX IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

* Fill leading zeros
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = L_ZINDEX
      IMPORTING
        OUTPUT = L_ZINDEX.
*++2009.09.18 BG (NESS)
*   If there was a BTYPE change, convert the ABEVAZ.
    IF $/ZAK/BEVALLI-BTYPE NE L_BTYPE.
      $/ZAK/BEVALLI-BTYPE  = L_BTYPE.
      $/ZAK/BEVALLSZ-BTYPE = L_BTYPE.
*     Rotate ABEV
      CALL FUNCTION '/ZAK/ABEV_CONTACT'
        EXPORTING
          I_BUKRS        = $/ZAK/ANALITIKA-BUKRS
          I_BTYPE        = $/ZAK/ANALITIKA-BTYPE
          I_ABEVAZ       = $/ZAK/ANALITIKA-ABEVAZ
          I_GJAHR        = L_GJAHR
          I_MONAT        = L_MONAT
        TABLES
          T_ABEV_CONTACT = LI_ABEV_CONTACT
        EXCEPTIONS
          ERROR_BTYPE    = 1
          ERROR_MONAT    = 2
          ERROR_ABEVAZ   = 3
          OTHERS         = 4.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
*     Determine the last row
      DESCRIBE TABLE LI_ABEV_CONTACT LINES L_TABIX.
      IF NOT L_TABIX IS INITIAL.
        READ TABLE LI_ABEV_CONTACT INDEX L_TABIX.
        $/ZAK/ANALITIKA-ABEVAZ = LI_ABEV_CONTACT-ABEVAZ.
      ENDIF.
      $/ZAK/ANALITIKA-BTYPE = L_BTYPE.
    ENDIF.
*--2009.09.18 BG (NESS)

*  Write back the values
    $/ZAK/ANALITIKA-GJAHR  = L_GJAHR.
    $/ZAK/ANALITIKA-MONAT  = L_MONAT.
    $/ZAK/ANALITIKA-ZINDEX = L_ZINDEX.

    $/ZAK/BEVALLSZ-GJAHR  = L_GJAHR.
    $/ZAK/BEVALLSZ-MONAT  = L_MONAT.
    $/ZAK/BEVALLSZ-ZINDEX = L_ZINDEX.

    $/ZAK/BEVALLI-GJAHR  = L_GJAHR.
    $/ZAK/BEVALLI-MONAT  = L_MONAT.
    $/ZAK/BEVALLI-ZINDEX = L_ZINDEX.


  ENDIF.




ENDFORM.                    " GET_NEXT_ZINDEX
*&---------------------------------------------------------------------*
*&      Form  CHECK_BEVALLI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_UPD_BEVALLI  text
*----------------------------------------------------------------------*
FORM CHECK_BEVALLI  TABLES   $I_BEVALLI STRUCTURE /ZAK/BEVALLI.

  DATA L_DATUM TYPE DATUM.
  DATA L_BMON  TYPE MONAT.
  DATA L_TIMES TYPE I.
  DATA: BEGIN OF LI_MONAT OCCURS 12,
          MONAT TYPE MONAT,
        END OF LI_MONAT.
  DATA LI_APPEND_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI
       INITIAL SIZE 0.
*++PTGSZLAA #02. 2014.03.05
  DATA L_WEEK TYPE KWEEK.
*--PTGSZLAA #02. 2014.03.05

  DEFINE LM_GET_MONAT.
    IF &1 EQ 'N'.
      L_TIMES = 3.
      IF &2 EQ '01' OR &2 EQ '02' OR
             &2 EQ '03'.
        CLEAR L_BMON.
      ELSEIF &2 EQ '04' OR &2 EQ '05' OR
             &2 EQ '06'.
        L_BMON = 3.
      ELSEIF &2 EQ '07' OR &2 EQ '08' OR
             &2 EQ '09'.
        L_BMON = 6.
      ELSEIF &2 EQ '10' OR &2 EQ '11' OR
             &2 EQ '12'.
        L_BMON = 9.
      ENDIF.

    ELSEIF &1 EQ 'E'.
      L_TIMES = 12.
      CLEAR L_BMON.
    ENDIF.

    DO L_TIMES TIMES.
      ADD 1 TO L_BMON.
      MOVE L_BMON TO LI_MONAT-MONAT.
      APPEND LI_MONAT.
    ENDDO.

  END-OF-DEFINITION.


*Read through the records
  LOOP AT $I_BEVALLI INTO W_/ZAK/BEVALLI.
*++PTGSZLAA #02. 2014.03.05
    IF W_/ZAK/BEVALLI-BTYPE EQ C_PTGSZLAA.
      CONCATENATE W_/ZAK/BEVALLI-GJAHR W_/ZAK/BEVALLI-MONAT INTO
                  L_WEEK.
      CALL FUNCTION 'WEEK_GET_FIRST_DAY'
        EXPORTING
          WEEK = L_WEEK
        IMPORTING
          DATE = L_DATUM
*      EXCEPTIONS
*         WEEK_INVALID       = 1
*         OTHERS             = 2
        .
      IF SY-SUBRC <> 0.
        CLEAR L_DATUM.
      ELSE.
        ADD 6 TO L_DATUM.
      ENDIF.
    ELSE.
*--PTGSZLAA #02. 2014.03.05
*   Determine the last day of the period
      CONCATENATE W_/ZAK/BEVALLI-GJAHR W_/ZAK/BEVALLI-MONAT '01' INTO
      L_DATUM.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
        EXPORTING
          DAY_IN            = L_DATUM
        IMPORTING
          LAST_DAY_OF_MONTH = L_DATUM.
*++PTGSZLAA #02. 2014.03.05
    ENDIF.
*--PTGSZLAA #02. 2014.03.05

*   Determine BEVALL
    CLEAR W_/ZAK/BEVALL.
    SELECT SINGLE * INTO W_/ZAK/BEVALL
                    FROM /ZAK/BEVALL
                   WHERE BUKRS EQ W_/ZAK/BEVALLI-BUKRS
                     AND BTYPE EQ W_/ZAK/BEVALLI-BTYPE
                     AND DATBI GE L_DATUM
                     AND DATAB LE L_DATUM.
*   If quarterly or yearly
    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALL-BIDOSZ CA 'EN'.
    REFRESH LI_MONAT.
    LM_GET_MONAT W_/ZAK/BEVALL-BIDOSZ W_/ZAK/BEVALLI-MONAT.
    IF NOT LI_MONAT[] IS INITIAL.
      LOOP AT LI_MONAT.
        READ TABLE $I_BEVALLI TRANSPORTING NO FIELDS
                  WITH KEY BUKRS  = W_/ZAK/BEVALLI-BUKRS
                           BTYPE  = W_/ZAK/BEVALLI-BTYPE
                           GJAHR  = W_/ZAK/BEVALLI-GJAHR
                           MONAT  = LI_MONAT-MONAT
                           ZINDEX = W_/ZAK/BEVALLI-ZINDEX.
        IF SY-SUBRC NE 0.
          MOVE LI_MONAT-MONAT TO W_/ZAK/BEVALLI-MONAT.
          APPEND W_/ZAK/BEVALLI TO LI_APPEND_BEVALLI.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF NOT LI_APPEND_BEVALLI[] IS INITIAL.
    APPEND LINES OF LI_APPEND_BEVALLI TO $I_BEVALLI.
  ENDIF.

ENDFORM.                    " CHECK_BEVALLI
*&---------------------------------------------------------------------*
*&      Form  GET_CS_BUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$UPD_BEVALLI  text
*      -->P_$UPD_BEVALLSZ  text
*----------------------------------------------------------------------*
FORM GET_CS_BUKRS  TABLES   $UPD_BEVALLI  STRUCTURE /ZAK/BEVALLI
                            $UPD_BEVALLSZ STRUCTURE /ZAK/BEVALLSZ.

* Group companies
  DATA LI_CS_BUKRS LIKE /ZAK/AFACS_BUKRS OCCURS 0 WITH HEADER LINE.
  DATA L_BUKCS     TYPE /ZAK/BUKCS.
  DATA L_DATUM     TYPE DATUM.

  DATA LI_BEVALLI_APPEND LIKE /ZAK/BEVALLI OCCURS 0 WITH HEADER LINE.
  DATA LW_BEVALLI LIKE /ZAK/BEVALLI.

  DATA LI_BEVALLSZ_APPEND LIKE /ZAK/BEVALLSZ OCCURS 0 WITH HEADER LINE.
  DATA LW_BEVALLSZ LIKE /ZAK/BEVALLSZ.
*++PTGSZLAA #02. 2014.03.05
  DATA L_WEEK TYPE KWEEK.
*--PTGSZLAA #02. 2014.03.05


  DEFINE LM_APPEND.
    CLEAR:  L_BUKCS, L_DATUM.
*++PTGSZLAA #02. 2014.03.05
    IF &1-BTYPE EQ C_PTGSZLAA.
      CLEAR L_WEEK.
      CONCATENATE &1-GJAHR &1-MONAT INTO L_WEEK.
      CALL FUNCTION 'WEEK_GET_FIRST_DAY'  "#EC CI_USAGE_OK[2296016]
        EXPORTING
          WEEK               = L_WEEK
        IMPORTING
          DATE               = L_DATUM
*      EXCEPTIONS
*        WEEK_INVALID       = 1
*        OTHERS             = 2
                .
      IF SY-SUBRC <> 0.
        CLEAR L_DATUM.
      ELSE.
        ADD 6 TO L_DATUM.
      ENDIF.
    ELSE.
*--PTGSZLAA #02. 2014.03.05
*    Last day of the month
      CONCATENATE &1-GJAHR
                  &1-MONAT
                  '01' INTO L_DATUM.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
        EXPORTING
          DAY_IN            = L_DATUM
        IMPORTING
          LAST_DAY_OF_MONTH = L_DATUM.
*++PTGSZLAA #02. 2014.03.05
    ENDIF.
*--PTGSZLAA #02. 2014.03.05
*    Group companies
    CALL FUNCTION '/ZAK/GET_AFCS'
      EXPORTING
        I_BUKRS = &1-BUKRS
        I_BTYPE = &1-BTYPE
        I_DATUM = L_DATUM
      IMPORTING
        E_BUKCS = L_BUKCS.
*       TABLES
*         T_BUKRS       = LI_CS_BUKRS.
    IF NOT L_BUKCS IS INITIAL.
      &1-BUKRS = L_BUKCS.
      COLLECT &1 INTO &2.
    ENDIF.
  END-OF-DEFINITION.


  LOOP AT  $UPD_BEVALLI INTO LW_BEVALLI.
    LM_APPEND LW_BEVALLI LI_BEVALLI_APPEND.
  ENDLOOP.
  IF NOT LI_BEVALLI_APPEND[] IS INITIAL.
    APPEND LINES OF LI_BEVALLI_APPEND TO $UPD_BEVALLI.
  ENDIF.

  LOOP AT  $UPD_BEVALLSZ INTO LW_BEVALLSZ.
    CLEAR LW_BEVALLSZ-PACK.
    LM_APPEND LW_BEVALLSZ LI_BEVALLSZ_APPEND.
  ENDLOOP.
  IF NOT LI_BEVALLSZ_APPEND[] IS INITIAL.
    APPEND LINES OF LI_BEVALLSZ_APPEND TO $UPD_BEVALLSZ.
  ENDIF.



ENDFORM.                    " GET_CS_BUKRS
