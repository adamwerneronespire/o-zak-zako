FUNCTION /ZAK/MAIN_EXIT_NEW.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_MONAT) TYPE  MONAT
*"     REFERENCE(I_INDEX) TYPE  /ZAK/INDEX
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLALV
*"      T_ADOAZON STRUCTURE  /ZAK/ONR_ADOAZON OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& CHANGES (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE       MODIFIER             DESCRIPTION           TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*&        2006.11.29   Balázs G.     Self-review handling change
*&---------------------------------------------------------------------*
*&        2007.06.22   Balázs G.     Handling zero fields
*&---------------------------------------------------------------------*
*& 0808   2007.01.28.-2007.02.10.    0808 form settings
*&---------------------------------------------------------------------*
*& 0908   2009.01.20.-2009.03.31.    0908 form settings
*&---------------------------------------------------------------------*
*& 0908/2 2009.08.01.-2009.08.31.    0908 new form settings
*&---------------------------------------------------------------------*
*& 1008   2010.01.20.-2010.03.31.    1008 form settings
*&---------------------------------------------------------------------*
*& 1108   2011.01.20.-2011.03.31.    1108 form settings
*&---------------------------------------------------------------------*
*& 1208   2012.02.01.-2012.03.31.    1208 form settings
*&---------------------------------------------------------------------*
*& 1308   2013.01.01.-2013.03.31.    1308 form settings
*&---------------------------------------------------------------------*
*& 12K79  2013.01.01.-2013.03.31.    12K79 form settings
*&---------------------------------------------------------------------*
*& 13K79  2014.01.01.-2014.03.31.    13K79 form settings
*&---------------------------------------------------------------------*


  DATA: V_LAST_DATE TYPE SY-DATUM.

  DATA: L_INDEX LIKE SY-TABIX.

************************************************************************
* Declaration data
* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P01.


* Determining the declaration's last day
  PERFORM GET_LAST_DAY_OF_PERIOD USING I_GJAHR
                                       I_MONAT
*++PTGSZLAA #01. 2014.03.03
                                       I_BTYPE
*--PTGSZLAA #01. 2014.03.03
                                  CHANGING V_LAST_DATE.

* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P02.

* Declaration general data
  PERFORM READ_BEVALL  USING I_BUKRS
                             I_BTYPE
                             V_LAST_DATE.

* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P03.

*  Reading the declaration data structure
  PERFORM READ_BEVALLB USING T_BEVALLO[]
                             I_BTYPE.

* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P04.

*++ BG 2007.05.17
* The form default values should be read from display BTYPE
* based on it:
**  Declaration form default values
*  PERFORM READ_BEVALLDEF USING I_BUKRS
*                               I_BTYPE.
*-- BG 2007.05.17

*
  DATA: L_ALV   LIKE /ZAK/BEVALLALV,
        L_TABIX LIKE SY-TABIX.

  CLEAR W_/ZAK/BEVALLO.
  REFRESH I_/ZAK/BEVALLO.

  CLEAR L_INDEX.

*++ BG 2007.05.17
  REFRESH R_DISP_BTYPE.
*-- BG 2007.05.17

* Here are the tax numbers for which submissions arrived
  SORT T_ADOAZON.

  LOOP AT T_BEVALLO INTO L_ALV.
*   Ensuring dialog execution
    PERFORM PROCESS_IND_ITEM USING '500000'
                                   L_INDEX
                                   TEXT-P05.
    MOVE-CORRESPONDING L_ALV TO W_/ZAK/BEVALLO.
    APPEND W_/ZAK/BEVALLO TO I_/ZAK/BEVALLO.
*++ BG 2007.05.17
*   Collecting display BTYPE
    READ TABLE R_DISP_BTYPE WITH KEY LOW = L_ALV-BTYPE_DISP.
    IF SY-SUBRC NE 0.
      M_DEF R_DISP_BTYPE 'I' 'EQ' L_ALV-BTYPE_DISP SPACE.
    ENDIF.
*-- BG 2007.05.17
*++ BG 2007.06.22
*   Gathering the tax numbers
    IF NOT L_ALV-ADOAZON IS INITIAL.
      CLEAR I_ADOAZON_ALL.
      MOVE L_ALV-ADOAZON TO I_ADOAZON_ALL-ADOAZON.
      MOVE L_ALV-LAPSZ   TO I_ADOAZON_ALL-LAPSZ.
      COLLECT I_ADOAZON_ALL.
    ENDIF.
*-- BG 2007.06.22

*   If the period is self-review and no data submission arrived
*   then we delete it. (SZJA)
    IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_SZJA AND
       I_INDEX NE '000' AND
       NOT L_ALV-ADOAZON IS INITIAL.
      READ TABLE T_ADOAZON WITH KEY ADOAZON = L_ALV-ADOAZON
                           BINARY SEARCH.
      IF SY-SUBRC NE 0.
        DELETE T_BEVALLO.
      ENDIF.
    ENDIF.
*++BG 2006.12.11
*   If it is self-review, we have to determine the individuals'
*   count
*++BG 2007.06.08
    IF W_/ZAK/BEVALL-BTYPART = C_BTYPART_SZJA AND
       I_INDEX NE '000'.
      IF W_/ZAK/BEVALL-BTYPE EQ C_0608 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC034A AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_06082 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC034A AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_0708 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC037A AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*++0808 BG 2008.02.07
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_0808 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC039A AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--0808 BG 2008.02.07
*++0908 2009.01.20 BG
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_0908 AND
        ( L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC038A OR
          L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC039A ) AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--0908 2009.01.20 BG
*++1008 2010.03.03 BG
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1008 AND
        ( L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC041A OR
          L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC042A ) AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1008 2010.03.03 BG
*++1108 2011.04.08 BG
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1108 AND
        ( L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC046A OR
          L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC047A ) AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1108 2011.04.08 BG
*++1208 2012.02.01 BG
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1208 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1208 2012.02.01 BG
*++1308 2013.02.05 BG
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1308 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1308 2013.02.05 BG
*++1408 #02. 2014.03.05 BG
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1408 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1408 #02. 2014.03.05 BG
*++1508 #01. 2015.02.02
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1508 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1508 #01. 2015.02.02
*++1608 #01. 2015.02.01
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1608 AND
        L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1608 #01. 2015.02.01
*++1708 #01. 2017.01.31
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1708 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1708 #01. 2017.01.31
*++1808 #01. 2018.01.30
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1808 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1808 #01. 2018.01.30
*++1908 #01. 2019.01.29
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1908 AND
         L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
         NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--1908 #01. 2019.01.29
*++2008 #01. 2020.01.27
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2008 AND
        L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--2008 #01. 2020.01.27
*++2108 #01.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2108 AND
        L_ALV-ABEVAZ EQ C_ABEVAZ_A0AC044A  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--2108 #01.
*++2208 #01.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2208 AND
        L_ALV-ABEVAZ EQ 'A0AC033A'  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--2208 #01.
*++2308 #01.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2308 AND
        L_ALV-ABEVAZ EQ 'A0AC033A'  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--2308 #01
*++2408 #01.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2408 AND
        L_ALV-ABEVAZ EQ 'A0AC033A'  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--2408 #01.
*++2508 #01.
      ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2508 AND
        L_ALV-ABEVAZ EQ 'A0AC033A'  AND
        NOT L_ALV-FIELD_C IS INITIAL.
        CLEAR L_ALV-FIELD_C.
        MODIFY T_BEVALLO FROM L_ALV TRANSPORTING FIELD_C.
*--2508 #01.
      ENDIF.
    ENDIF.
*++BG 2007.06.08
*--BG 2006.12.11
  ENDLOOP.

  SORT I_/ZAK/BEVALLO.
*++ BG 2007.06.22
  SORT I_ADOAZON_ALL.
*-- BG 2007.06.22

* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P06.

*++ BG 2007.05.17
*  Declaration form default values
  PERFORM READ_BEVALLDEF TABLES R_DISP_BTYPE
                          USING I_BUKRS.
*-- BG 2007.05.17


* Declaration - calculated ABEV entries
  PERFORM CALC_ABEV TABLES I_/ZAK/BEVALLO
                           I_/ZAK/BEVALLB
                           T_ADOAZON
*++ BG 2007.06.22
                           I_ADOAZON_ALL
*-- BG 2007.06.22
                    USING  V_LAST_DATE
                           I_INDEX.


* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P04.

* Setting form default values!
  PERFORM SET_DEFAULT_ABEV TABLES I_/ZAK/BEVALLO
                                  I_/ZAK/BEVALLDEF
                           USING  I_GJAHR
                                  I_MONAT
                                  I_INDEX
                                  I_BUKRS
*++BG 2007.10.10
                                  V_LAST_DATE
*--BG 2007.10.10
                                  .

* Determining the SZJA self-review supplement
  PERFORM CALC_ABEV_ONREV_POTL_SZJA TABLES I_/ZAK/BEVALLO
                                           I_/ZAK/BEVALLB
                                           T_ADOAZON
                                    USING  I_INDEX
                                           V_LAST_DATE.
* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P08.

* Declaration - received ABEV entries
  PERFORM GET_ABEV TABLES I_/ZAK/BEVALLO
                          I_/ZAK/BEVALLB.

* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P09.
*++BG 2006/09/22
** Declaration - counting rows
*  PERFORM COUNT_ABEV TABLES I_/ZAK/BEVALLO
*                            I_/ZAK/BEVALLB.
*--BG 2006/09/22

*  DATA: W_DELE LIKE /ZAK/BEVALLALV .
*
*  LOOP AT I_SUM INTO W_/ZAK/BEVALLO.
*    CLEAR V_TABIX.
*    READ TABLE T_BEVALLO INTO W_DELE
*    WITH KEY ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
*    IF SY-SUBRC EQ 0.
*      V_TABIX = SY-TABIX.
*      DELETE T_BEVALLO WHERE ABEVAZ EQ W_/ZAK/BEVALLO-ABEVAZ.
*    ENDIF.
*    CLEAR L_ALV.
*    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
*    WITH KEY ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
*    MOVE-CORRESPONDING W_/ZAK/BEVALLB TO L_ALV.
*    MOVE-CORRESPONDING W_/ZAK/BEVALLO TO L_ALV.
*    SELECT SINGLE ABEVTEXT INTO L_ALV-ABEVTEXT
*      FROM  /ZAK/BEVALLBT
*           WHERE  LANGU   = SY-LANGU
*           AND    BTYPE   = W_/ZAK/BEVALLO-BTYPE
*           AND    ABEVAZ  = W_/ZAK/BEVALLO-ABEVAZ.
*    L_ALV-ABEVTEXT_DISP = L_ALV-ABEVTEXT.
*    IF V_TABIX IS INITIAL.
*      APPEND L_ALV TO T_BEVALLO.
*    ELSE.
*      INSERT L_ALV INTO T_BEVALLO INDEX V_TABIX.
*    ENDIF.
*  ENDLOOP.


* Ensuring dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P10.


  SORT T_BEVALLO BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON LAPSZ.


  DELETE I_/ZAK/BEVALLO WHERE FIELD_C IS INITIAL
                         AND FIELD_N IS INITIAL
*++ BG 2007.06.22
                         AND NULL_FLAG IS INITIAL.
*-- BG 2007.06.22

***++BG 2006/11/29
  PERFORM GET_NEW_ONR_SUM TABLES T_BEVALLO
                                 I_ADOAZON_ALL
                          USING  W_/ZAK/BEVALL-BTYPE
                                 I_INDEX
*++0908/2 2009.12.09 BG
                                 V_LAST_DATE.
*--0908/2 2009.12.09 BG

***--BG 2006/11/29

* Determining the number of attached pages
*++BG 2006.09.22
  IF W_/ZAK/BEVALL-BTYPE EQ C_0608.
    PERFORM GET_LAP_SZ_0608 TABLES T_BEVALLO.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_06082.
    PERFORM GET_LAP_SZ_06082 TABLES T_BEVALLO.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_0708.
    PERFORM GET_LAP_SZ_0708 TABLES T_BEVALLO.
*++0808 BG 2008.02.07
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_0808.
    PERFORM GET_LAP_SZ_0808 TABLES T_BEVALLO.
    PERFORM GET_ONELL_0808 TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB
                           USING  I_INDEX.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*--0808 BG 2008.02.07

*++0808 BG 2008.07.09
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.

*   Clearing the due date on the correction note:
    PERFORM DEL_ESDAT_FIELD_0808 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC035A.
*--0808 BG 2008.07.09
*++0908 2009.01.20 BG
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_0908.
    PERFORM GET_LAP_SZ_0908 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.

*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.

*   Clearing the due date on the correction note:
    PERFORM DEL_ESDAT_FIELD_0908 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC033A.
*--0908 2009.01.20 BG
*++1008 2010.01.20 BG
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1008.
*   Page counts
    PERFORM GET_LAP_SZ_1008 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.

*   Clearing the due date on the correction note:
    PERFORM DEL_ESDAT_FIELD_1008 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC036A.

*--1008 2010.01.20 BG
*++1108 2011.01.27 BG
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1108.
*   Page counts
    PERFORM GET_LAP_SZ_1108 TABLES T_BEVALLO.

*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.

*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.

*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1108 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC042A.

*--1108 2011.01.27 BG
*++1208 2012.02.01 BG
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1208.
*   Page counts
    PERFORM GET_LAP_SZ_1208 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1208 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.

*--1208 2012.02.01 BG
*++1308 2013.02.05 BG
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1308.
*   Page counts
    PERFORM GET_LAP_SZ_1308 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1308 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1308 2013.02.05 BG
*++1408 2014.01.29 BG
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1408.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_1408 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*++1408 #02. 2014.03.05 BG
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1408 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1408 #02. 2014.03.05 BG
*--1408 2014.01.29 BG
*++1508 #01. 2015.02.02
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1508.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_1508 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1508 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1508 #01. 2015.02.02
*++1608 #01. 2015.02.01
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1608.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_1608 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1608 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1608 #01. 2015.02.01
*++1708 #01. 2017.01.31
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1708.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_1708 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1708 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1708 #01. 2017.01.31
*++1808 #01. 2018.01.30
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1808.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_1808 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1808 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1808 #01. 2018.01.30
*++1908 #01. 2019.01.29
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_1908.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_1908 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_1908 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--1908 #01. 2019.01.29
*++2008 #01. 2020.01.27
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2008.
*   Page counts, pensioners
    PERFORM GET_LAP_SZ_2008 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
      I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
    PERFORM DEL_ESDAT_FIELD_2008 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
    USING  C_ABEVAZ_A0AC041A.
*--2008 #01. 2020.01.27
*++2108 #01.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2108.
*   Page counts, pensioners
*++2108 #08.
*    PERFORM GET_LAP_SZ_2008 TABLES T_BEVALLO.
    PERFORM GET_LAP_SZ_2108 TABLES T_BEVALLO.
*--2108 #08.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*   Due date, self-supplement zero flag cleanup on the correction note,
*++2108 #08.
*    PERFORM DEL_ESDAT_FIELD_2008 TABLES T_BEVALLO
    PERFORM DEL_ESDAT_FIELD_2108 TABLES T_BEVALLO
*--2108 #08.
                                        I_/ZAK/BEVALLB
                                 USING  C_ABEVAZ_A0AC041A.
*--2108 #01.
*++2208 #01.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2208.
    PERFORM GET_LAP_SZ_2208 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.

    PERFORM DEL_ESDAT_FIELD_2208 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  'A0AC030A'.

*--2208 #01.
*++2308 #01.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2308.
    PERFORM GET_LAP_SZ_2308 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*
    PERFORM DEL_ESDAT_FIELD_2308 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  'A0AC030A'.
*--2308 #01.
*++2408 #01.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2408.
    PERFORM GET_LAP_SZ_2408 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*
    PERFORM DEL_ESDAT_FIELD_2408 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  'A0AC030A'.
*--2408 #01.
*++2508 #01.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2508.
    PERFORM GET_LAP_SZ_2508 TABLES T_BEVALLO.
*   Declaration - received ABEV entries
    PERFORM GET_ONREV_ABEV TABLES T_BEVALLO
                                  I_/ZAK/BEVALLB.
*   Sign reversal,
    PERFORM CHANGE_ELOJEL TABLES T_BEVALLO
                                 I_/ZAK/BEVALLB.
*
    PERFORM DEL_ESDAT_FIELD_2508 TABLES T_BEVALLO
                                        I_/ZAK/BEVALLB
                                 USING  'A0AC030A'.
*--2508 #01.
*++BG 2012.01.17
* Determining tax numbers
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_11K79.
    PERFORM GET_ADOSZ_XXK79 TABLES T_BEVALLO
                                   I_ADOAZON_ALL
                            USING  C_ABEVAZ_A0AC028A.
*--BG 2012.01.17
*++12K79 2013.01.23
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_12K79.
    PERFORM GET_ADOSZ_XXK79 TABLES T_BEVALLO
                                   I_ADOAZON_ALL
                            USING  C_ABEVAZ_A0AC028A.
*--12K79 2013.01.23
*++13K79 2013.01.23
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_13K79.
    PERFORM GET_ADOSZ_XXK79 TABLES T_BEVALLO
                                   I_ADOAZON_ALL
                            USING  C_ABEVAZ_A0AD003A.
*++2308 #09.
  ELSEIF W_/ZAK/BEVALL-BTYPE EQ C_2229.
    PERFORM GET_DEF_VALUE TABLES T_BEVALLO.
*--2308 #09.
*--13K79 2013.01.23
  ENDIF.
*--BG 2006.09.22

  FREE I_/ZAK/BEVALLO.

** Removing duplicate fields
*  DELETE ADJACENT DUPLICATES FROM T_BEVALLO.

* Determining page counts per tax identifier
  PERFORM CALC_ABEV_LAPSZ TABLES T_BEVALLO.

* Removing empty fields.
  DELETE T_BEVALLO WHERE FIELD_C IS INITIAL
*++0808 BG 2008.02.07
                     AND ( ( OFLAG IS INITIAL AND
                             FIELD_N IS INITIAL ) OR
                           ( NOT OFLAG IS INITIAL AND
                             FIELD_ON IS INITIAL  AND
                             FIELD_N IS INITIAL ) )
*--0808 BG 2008.02.07
*++ BG 2007.06.22
                     AND NULL_FLAG IS INITIAL.
*-- BG 2007.06.22

ENDFUNCTION.
