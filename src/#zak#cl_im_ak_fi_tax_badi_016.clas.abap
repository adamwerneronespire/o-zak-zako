class /ZAK/CL_IM_AK_FI_TAX_BADI_016 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FI_TAX_BADI_016 .
protected section.
private section.
ENDCLASS.



CLASS /ZAK/CL_IM_AK_FI_TAX_BADI_016 IMPLEMENTATION.


METHOD if_ex_fi_tax_badi_016~end_of_selection.
* ...
*&---------------------------------------------------------------------*
*& LOG#     DATE        MODIFIER                   DESCRIPTION
*& ----   ----------   ----------     ----------------------------------
*& 0001   2007.01.03   Balázs G.(FMC) /ZAK/BSET table update
*&                                    with tax date and transaction type
*&---------------------------------------------------------------------*

  DATA: w_auste    TYPE rfums_tax_item,
        w_voste    TYPE rfums_tax_item,
        w_bset     TYPE bset,
        w_/zak/zak      TYPE /zak/bset,
        l_/zak/zak      TYPE /zak/bset,
        w_bset_log TYPE /zak/bset_log,
        l_bset_log TYPE /zak/bset_log.

*++1565 #08.
  DATA  w_/zak/belnr TYPE /zak/bset_belnr.
  DATA  i_/zak/belnr TYPE STANDARD TABLE OF /zak/bset_belnr.
*--1565 #08.
  DATA: i_bset TYPE STANDARD TABLE OF bset INITIAL SIZE 0.

*  data: l_datum  type buper,
*        l_bday   type /zak/bday,
*        l_zfbdt  type datum,
*        l_kalkd  type datum,
*        l_ev(4)  type n,
*        l_ho(2)  type n,
*        l_nap(2) type n.


  DATA: i_/zak/start TYPE STANDARD TABLE OF /zak/start INITIAL SIZE 0,
        w_/zak/start TYPE /zak/start.

* Return type
  CONSTANTS: c_btypart_afa  TYPE /zak/btypart VALUE 'AFA',
             c_btypart_szja TYPE /zak/btypart VALUE 'SZJA',
             c_btypart_tars TYPE /zak/btypart VALUE 'TARS',
             c_btypart_ucs  TYPE /zak/btypart VALUE 'UCS',
             c_btypart_atv  TYPE /zak/btypart VALUE 'ATV'.

*++1365#24.
  DATA: i_/zak/analitika TYPE STANDARD TABLE OF /zak/analitika,
        w_/zak/analitika TYPE /zak/analitika,
        i_return        TYPE STANDARD TABLE OF bapiret2.
  DATA  l_buper TYPE buper.

  TYPES: BEGIN OF t_buper,
           buper_old TYPE buper,
           buper_new TYPE buper,
         END OF t_buper.

  DATA i_buper TYPE SORTED TABLE OF t_buper WITH UNIQUE KEY buper_old.
  DATA w_buper TYPE t_buper.

  DEFINE l_m_get_buper.
*   Validation
    READ TABLE i_buper INTO w_buper
               WITH KEY buper_old = &1-buper.
*   Determine the period
    IF sy-subrc NE 0.
      CLEAR   w_/zak/analitika.
      REFRESH: i_/zak/analitika, i_return.
      w_/zak/analitika-mandt  = sy-mandt.
      w_/zak/analitika-bukrs  = &1-bukrs.
      w_/zak/analitika-gjahr  = &1-buper(4).
      w_/zak/analitika-monat  = &1-buper+4(2).
      w_/zak/analitika-abevaz = 'DUMMY'.
      w_/zak/analitika-bsznum = '999'.
      w_/zak/analitika-item   = '000001'.
      w_/zak/analitika-lapsz  = '0001'.
      APPEND w_/zak/analitika TO i_/zak/analitika.
      CALL FUNCTION '/ZAK/UPDATE'
        EXPORTING
          i_bukrs           = &1-bukrs
*       I_BTYPE           =
          i_btypart         = c_btypart_afa
          i_bsznum          = '999'
*       I_PACK            =
          i_gen             = 'X'
          i_test            = 'X'
*       I_FILE            =
        TABLES
          i_analitika       = i_/zak/analitika
*       I_AFA_SZLA        =
          e_return          = i_return.

      READ TABLE i_/zak/analitika INTO w_/zak/analitika INDEX 1.
      CONCATENATE w_/zak/analitika-gjahr w_/zak/analitika-monat
                  INTO l_buper.
      CLEAR w_buper.
      w_buper-buper_old = &1-buper.
      IF &1-buper NE l_buper.
        &1-buper = l_buper.
      ENDIF.
      w_buper-buper_new = l_buper.
      INSERT w_buper INTO TABLE i_buper.
    ELSEIF w_buper-buper_new NE &1-buper.
      &1-buper = w_buper-buper_new.
    ENDIF.
  END-OF-DEFINITION.
*--1365#24.
ENHANCEMENT-POINT /ZAK/ZAK_RG_BADI_011 SPOTS /ZAK/ES_BADI_016 STATIC .
*++1665 #02.
  DATA: gt_selection_fields TYPE TABLE OF rsparams.
  DATA: gs_selection_fields TYPE rsparams.
  DATA: par_bsud TYPE umsvbsud.
*++S4HANA#01.
  DATA: lt_/zak/zak_new TYPE HASHED TABLE OF /zak/bset
  WITH UNIQUE KEY bukrs belnr gjahr buzei.
  DATA: lt_/zak/zak_new_1 TYPE HASHED TABLE OF /zak/bset
    WITH UNIQUE KEY bukrs belnr gjahr buzei.
*--S4HANA#01.
  IMPORT rsparams_table = gt_selection_fields               "1610408
         FROM MEMORY ID 'RFUMSV00_SELECTION_PARAMETERS'.    "1610408

  READ TABLE gt_selection_fields INTO gs_selection_fields
       WITH KEY selname = 'PAR_BSUD'.
  IF sy-subrc EQ 0 AND gs_selection_fields-low = 'X'.
    par_bsud = 'X'.
  ENDIF.
*--1665 #02.
ENHANCEMENT-POINT /ZAK/ZAK_RG_BADI_012 SPOTS /ZAK/ES_BADI_016 .

  DATA ls_gt_alv  TYPE rfums_tax_gt_alv.

ENHANCEMENT-POINT /ZAK/ZAK_FGSZ_BADI_001 SPOTS /ZAK/ES_BADI_016 .

* Read start date for all company codes
  SELECT * INTO TABLE i_/zak/start FROM /zak/start.

* Read per company code
  LOOP AT ch_gt_alv INTO ls_gt_alv.

* VAT items - payable
    LOOP AT ls_gt_alv-t_auste_ep INTO w_auste.

* Date validation
      IF w_auste-bukrs NE w_/zak/start-bukrs.

        CLEAR w_/zak/start.
        READ TABLE i_/zak/start INTO w_/zak/start
           WITH KEY bukrs = w_auste-bukrs.

      ENDIF.

      CHECK w_auste-budat >= w_/zak/start-zbudat.

* Select the corresponding BSET record
      CLEAR w_bset.
*++S4HANA#01.
*      REFRESH i_bset.
*      SELECT * INTO TABLE i_bset FROM  bset
      CLEAR i_bset[].
      SELECT mandt bukrs belnr gjahr buzei
        INTO CORRESPONDING FIELDS OF TABLE i_bset
        FROM  bset
*--S4HANA#01.
                WHERE  bukrs  = w_auste-bukrs
                AND    belnr  = w_auste-belnr
                AND    gjahr  = w_auste-gjahr
                AND    mwskz  = w_auste-mwskz
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
*--S4HANA#01.
*             BUZEI  = w_auste-buzei.

*++1565 #08.
*++S4HANA#01.
*      REFRESH i_/zak/belnr.
      CLEAR i_/zak/belnr[].

      IF NOT i_bset[] IS INITIAL.
        DATA(lt_w_bset_drv) = i_bset[].
        SORT lt_w_bset_drv BY bukrs belnr gjahr buzei.
        DELETE ADJACENT DUPLICATES FROM lt_w_bset_drv
          COMPARING bukrs belnr gjahr buzei.
        SELECT mandt, bukrs, belnr, gjahr, buzei
          FROM /zak/bset
          FOR ALL ENTRIES IN @lt_w_bset_drv
          WHERE bukrs = @lt_w_bset_drv-bukrs
          AND   belnr = @lt_w_bset_drv-belnr
          AND   gjahr = @lt_w_bset_drv-gjahr
          AND   buzei = @lt_w_bset_drv-buzei
          INTO CORRESPONDING FIELDS OF TABLE @lt_/zak/zak_new.
        FREE lt_w_bset_drv[].
      ENDIF.
*--S4HANA#01.
*--1565 #08.
      LOOP AT i_bset INTO w_bset.
*++1565 #08.
** If BSET is already updated, then write it to /ZAK/BSET
** the record must also be inserted there - if it was not present yet
*      IF NOT W_BSET-STMDT IS INITIAL AND
*         NOT W_BSET-STMTI IS INITIAL.
*
*        CLEAR W_/ZAK/ZAK.
*
*        W_/ZAK/ZAK-BUKRS = W_BSET-BUKRS.
*        W_/ZAK/ZAK-BELNR = W_BSET-BELNR.
*        W_/ZAK/ZAK-GJAHR = W_BSET-GJAHR.
*        W_/ZAK/ZAK-BUZEI = W_BSET-BUZEI.
**++2007.01.11 BG (FMC)
**       w_/zak/zak-buper = w_auste-bldat(6).
**--2007.01.11 BG (FMC)
*        W_/ZAK/ZAK-ZINDEX = SPACE.
*
**++0001 2007.01.03 BG (FMC)
**     Tax date
**        CLEAR W_/ZAK/ZAK-ADODAT.
**        SELECT SINGLE
**          ADODAT
**          INTO W_/ZAK/ZAK-ADODAT
**          FROM /ZAK/AD001_BKPF
**          WHERE BUKRS EQ W_AUSTE-BUKRS
**            AND GJAHR EQ W_AUSTE-GJAHR
**            AND BELNR EQ W_AUSTE-BELNR.
**++2007.01.11 BG (FMC)
*        MOVE W_AUSTE-VATDATE TO W_/ZAK/ZAK-ADODAT.
*        IF NOT W_/ZAK/ZAK-ADODAT IS INITIAL.
*          W_/ZAK/ZAK-BUPER = W_/ZAK/ZAK-ADODAT(6).
*        ELSE.
*          W_/ZAK/ZAK-BUPER = W_AUSTE-BLDAT(6).
*        ENDIF.
**--2007.01.11 BG (FMC)
**     Transaction type
*        CLEAR W_/ZAK/ZAK-TTIP.
*        SELECT
*          DIEKZ
*          INTO W_/ZAK/ZAK-TTIP
*          FROM BSEG
*          WHERE BUKRS EQ W_AUSTE-BUKRS
*            AND BELNR EQ W_AUSTE-BELNR
*            AND GJAHR EQ W_AUSTE-GJAHR
*            AND DIEKZ NE SPACE.
*          EXIT.
*        ENDSELECT.
**--0001 2007.01.03 BG (FMC)
*
*        CLEAR L_/ZAK/ZAK.
*        SELECT SINGLE * INTO L_/ZAK/ZAK FROM /ZAK/BSET
*          WHERE  BUKRS  = W_/ZAK/ZAK-BUKRS
*          AND    BELNR  = W_/ZAK/ZAK-BELNR
*          AND    GJAHR  = W_/ZAK/ZAK-GJAHR
*          AND    BUZEI  = W_/ZAK/ZAK-BUZEI.
*
*        IF SY-SUBRC NE 0.
**++1365#24.
**Determine BUPER; if the period is closed with 'X' then
**move it to the new period here:
*          L_M_GET_BUPER W_/ZAK/ZAK.
**--1365#24.
*          INSERT INTO /ZAK/BSET VALUES W_/ZAK/ZAK.
*          IF SY-SUBRC = 0.
** Log table update
*            CLEAR L_BSET_LOG.
*            SELECT SINGLE * INTO L_BSET_LOG FROM /ZAK/BSET_LOG
*              WHERE BUKRS = W_/ZAK/ZAK-BUKRS
*                AND BUPER = W_/ZAK/ZAK-BUPER.
*            IF SY-SUBRC NE 0.
*              CLEAR W_BSET_LOG.
*              W_BSET_LOG-BUKRS = W_/ZAK/ZAK-BUKRS.
*              W_BSET_LOG-BUPER = W_/ZAK/ZAK-BUPER.
*
*              CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
*                EXPORTING
*                  I_DATLO     = SY-DATLO
*                  I_TIMLO     = SY-TIMLO
**                 I_TZONE     = SY-ZONLO
*                IMPORTING
*                  E_TIMESTAMP = W_BSET_LOG-LARUN.
*
*              INSERT INTO /ZAK/BSET_LOG VALUES W_BSET_LOG.
*            ELSE.
*
*              CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
*                EXPORTING
*                  I_DATLO     = SY-DATLO
*                  I_TIMLO     = SY-TIMLO
**                 I_TZONE     = SY-ZONLO
*                IMPORTING
*                  E_TIMESTAMP = W_BSET_LOG-LARUN.
*
*              UPDATE /ZAK/BSET_LOG SET LARUN = W_BSET_LOG-LARUN
*                 WHERE BUKRS = W_/ZAK/ZAK-BUKRS
*                   AND BUPER = W_/ZAK/ZAK-BUPER.
*            ENDIF.
*
*            COMMIT WORK.
*          ENDIF.
*        ENDIF.
*      ENDIF.
        CLEAR l_/zak/zak.
*++S4HANA#01.*
*        SELECT SINGLE * INTO l_/zak/zak FROM /zak/bset
*          WHERE  bukrs  = w_bset-bukrs
*          AND    belnr  = w_bset-belnr
*          AND    gjahr  = w_bset-gjahr
*          AND    buzei  = w_bset-buzei.
        READ TABLE lt_/zak/zak_new INTO l_/zak/zak WITH KEY
          bukrs = w_bset-bukrs
          belnr = w_bset-belnr
          gjahr = w_bset-gjahr
          buzei = w_bset-buzei
          TRANSPORTING mandt.
*--S4HANA#01.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING w_bset TO w_/zak/belnr.
*++2015.07.29
*        W_/ZAK/BELNR-VATDATE = W_AUSTE-VATDATE.
*--2015.07.29
          w_/zak/belnr-bldat   = w_auste-bldat.
          APPEND w_/zak/belnr TO i_/zak/belnr.
        ENDIF.
*--1565 #08.
      ENDLOOP.
*++S4HANA#01.
      FREE lt_/zak/zak_new[].
*--S4HANA#01.
*++1565 #08.
*++1665 #02.
*   Save the data only during production runs
*    IF NOT I_/ZAK/BELNR[] IS INITIAL.
      IF NOT i_/zak/belnr[] IS INITIAL AND NOT par_bsud IS INITIAL.
*--1665 #02.
        INSERT /zak/bset_belnr FROM TABLE i_/zak/belnr ACCEPTING DUPLICATE KEYS.
        COMMIT WORK.
      ENDIF.
ENHANCEMENT-POINT /ZAK/ZAK_RG_BADI_013 SPOTS /ZAK/ES_BADI_016 .

*--1565 #08.
    ENDLOOP.

* VAT items - reclaimable
    LOOP AT ls_gt_alv-t_voste_ep INTO w_voste.

* Date validation
      IF w_voste-bukrs NE w_/zak/start-bukrs.

        CLEAR w_/zak/start.
        READ TABLE i_/zak/start INTO w_/zak/start
           WITH KEY bukrs = w_voste-bukrs.

      ENDIF.

      CHECK w_voste-budat >= w_/zak/start-zbudat.

* Select the corresponding BSET record
      CLEAR w_bset.
*++S4HANA#01.
*      REFRESH i_bset.
*      SELECT * INTO TABLE i_bset FROM  bset
      CLEAR i_bset[].
      SELECT mandt bukrs belnr gjahr buzei
        INTO CORRESPONDING FIELDS OF TABLE i_bset
        FROM bset
*--S4HANA#01.
                 WHERE  bukrs  = w_voste-bukrs
                 AND    belnr  = w_voste-belnr
                 AND    gjahr  = w_voste-gjahr
*      AND    BUZEI  = w_voste-buzei.
                 AND    mwskz  = w_voste-mwskz
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
*--S4HANA#01.
*++1565 #08.
*++S4HANA#01.
*      REFRESH i_/zak/belnr.
      CLEAR i_/zak/belnr[].
      IF NOT i_bset[] IS INITIAL.
        DATA(lt_w_bset_drv_1) = i_bset[].
        SORT lt_w_bset_drv_1 BY bukrs belnr gjahr buzei.
        DELETE ADJACENT DUPLICATES FROM lt_w_bset_drv_1
          COMPARING bukrs belnr gjahr buzei.
        SELECT mandt, bukrs, belnr, gjahr, buzei
          FROM /zak/bset
          FOR ALL ENTRIES IN @lt_w_bset_drv_1
          WHERE bukrs = @lt_w_bset_drv_1-bukrs
          AND   belnr = @lt_w_bset_drv_1-belnr
          AND   gjahr = @lt_w_bset_drv_1-gjahr
          AND   buzei = @lt_w_bset_drv_1-buzei
          INTO CORRESPONDING FIELDS OF TABLE @lt_/zak/zak_new_1.
        FREE lt_w_bset_drv_1[].
      ENDIF.
*--S4HANA#01.
*--1565 #08.
      LOOP AT i_bset INTO w_bset.
*++1565 #08.
** If BSET is already updated, then write it to /ZAK/BSET
** the record must also be inserted there - if it was not present yet
*      IF NOT W_BSET-STMDT IS INITIAL AND
*         NOT W_BSET-STMTI IS INITIAL.
*
*** Determine ZFBDT
**        clear l_zfbdt.
**        SELECT ZFBDT into l_zfbdt FROM  BSEG
**               WHERE  BUKRS  = w_voste-bukrs
**               AND    BELNR  = w_voste-belnr
**               AND    GJAHR  = w_voste-gjahr
**               AND    KOART  = 'K'.
**        ENDSELECT.
**
*** Read due date
**        clear l_bday.
**        l_datum = sy-datum.
**
**        SELECT bday into l_bday FROM  /ZAK/BEVALL
**               WHERE  BUKRS   = w_voste-bukrs
**               AND    BTYPART = c_btypart_afa
**               AND    DATBI   >= l_datum.
**        ENDSELECT.
**
**
*** Calculation date
**        l_ev    = w_voste-bldat+0(4).
**        l_ho    = w_voste-bldat+4(2).
**        l_nap   = w_voste-bldat+6(2).
**
**
**        if l_ho <= 11.
**          l_ho = l_ho + 1.
**        else.
**          l_ev = l_ev + 1.
**          l_ho = '01'.
**        endif.
**
**        l_nap = l_bday.
**        concatenate l_ev l_ho l_nap into l_kalkd.
**
**
**        if l_zfbdt > l_kalkd.
**          l_datum = l_zfbdt(6).
**        else.
**          l_datum = w_voste-bldat(6).
**        endif.
*
*        CLEAR W_/ZAK/ZAK.
*
*        W_/ZAK/ZAK-BUKRS = W_BSET-BUKRS.
*        W_/ZAK/ZAK-BELNR = W_BSET-BELNR.
*        W_/ZAK/ZAK-GJAHR = W_BSET-GJAHR.
*        W_/ZAK/ZAK-BUZEI = W_BSET-BUZEI.
**       w_/zak/zak-BUPER = l_datum.
**++2007.01.11 BG (FMC)
**       W_/ZAK/ZAK-BUPER = W_VOSTE-BLDAT(6).
**--2007.01.11 BG (FMC)
*
*        W_/ZAK/ZAK-ZINDEX = SPACE.
*
**++0001 2007.01.03 BG (FMC)
**       Tax date
*        CLEAR W_/ZAK/ZAK-ADODAT.
**        SELECT SINGLE
**          ADODAT
**          INTO W_/ZAK/ZAK-ADODAT
**          FROM /ZAK/AD001_BKPF
**          WHERE BUKRS EQ W_VOSTE-BUKRS
**            AND GJAHR EQ W_VOSTE-GJAHR
**            AND BELNR EQ W_VOSTE-BELNR.
**++2007.01.11 BG (FMC)
*        MOVE W_VOSTE-VATDATE TO W_/ZAK/ZAK-ADODAT.
*        IF NOT W_/ZAK/ZAK-ADODAT IS INITIAL.
*          W_/ZAK/ZAK-BUPER = W_/ZAK/ZAK-ADODAT(6).
*        ELSE.
*          W_/ZAK/ZAK-BUPER = W_VOSTE-BLDAT(6).
*        ENDIF.
**--2007.01.11 BG (FMC)
*
*
**       Transaction type
*        CLEAR W_/ZAK/ZAK-TTIP.
*        SELECT
*          DIEKZ
*          INTO W_/ZAK/ZAK-TTIP
*          FROM BSEG
*          WHERE BUKRS EQ W_VOSTE-BUKRS
*            AND BELNR EQ W_VOSTE-BELNR
*            AND GJAHR EQ W_VOSTE-GJAHR
*            AND DIEKZ NE SPACE.
*          EXIT.
*        ENDSELECT.
**--0001 2007.01.03 BG (FMC)
*
*        CLEAR L_/ZAK/ZAK.
*        SELECT SINGLE * INTO L_/ZAK/ZAK FROM /ZAK/BSET
*          WHERE  BUKRS  = W_/ZAK/ZAK-BUKRS
*          AND    BELNR  = W_/ZAK/ZAK-BELNR
*          AND    GJAHR  = W_/ZAK/ZAK-GJAHR
*          AND    BUZEI  = W_/ZAK/ZAK-BUZEI.
*
*        IF SY-SUBRC NE 0.
**++1365#24.
**Determine BUPER; if the period is closed with 'X' then
**move it to the new period here:
*          L_M_GET_BUPER W_/ZAK/ZAK.
**--1365#24.
*          INSERT INTO /ZAK/BSET VALUES W_/ZAK/ZAK.
** Log table update
*          IF SY-SUBRC = 0.
*            CLEAR L_BSET_LOG.
*            SELECT SINGLE * INTO L_BSET_LOG FROM /ZAK/BSET_LOG
*              WHERE BUKRS = W_/ZAK/ZAK-BUKRS
*                AND BUPER = W_/ZAK/ZAK-BUPER.
*            IF SY-SUBRC NE 0.
*              CLEAR W_BSET_LOG.
*              W_BSET_LOG-BUKRS = W_/ZAK/ZAK-BUKRS.
*              W_BSET_LOG-BUPER = W_/ZAK/ZAK-BUPER.
*
*              CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
*                EXPORTING
*                  I_DATLO     = SY-DATLO
*                  I_TIMLO     = SY-TIMLO
**                 I_TZONE     = SY-ZONLO
*                IMPORTING
*                  E_TIMESTAMP = W_BSET_LOG-LARUN.
*
*              INSERT INTO /ZAK/BSET_LOG VALUES W_BSET_LOG.
*            ELSE.
*
*              CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
*                EXPORTING
*                  I_DATLO     = SY-DATLO
*                  I_TIMLO     = SY-TIMLO
**                 I_TZONE     = SY-ZONLO
*                IMPORTING
*                  E_TIMESTAMP = W_BSET_LOG-LARUN.
*
*              UPDATE /ZAK/BSET_LOG SET LARUN = W_BSET_LOG-LARUN
*                 WHERE BUKRS = W_/ZAK/ZAK-BUKRS
*                   AND BUPER = W_/ZAK/ZAK-BUPER.
*            ENDIF.
*
*            COMMIT WORK.
*          ENDIF.
*        ENDIF.
**      ENDIF.
        CLEAR l_/zak/zak.
*++S4HANA#01.
*        SELECT SINGLE * INTO l_/zak/zak FROM /zak/bset
*          WHERE  bukrs  = w_bset-bukrs
*          AND    belnr  = w_bset-belnr
*          AND    gjahr  = w_bset-gjahr
*          AND    buzei  = w_bset-buzei.
        READ TABLE lt_/zak/zak_new_1 INTO l_/zak/zak WITH KEY
          bukrs = w_bset-bukrs
          belnr = w_bset-belnr
          gjahr = w_bset-gjahr
          buzei = w_bset-buzei
          TRANSPORTING mandt.
*--S4HANA#01.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING w_bset TO w_/zak/belnr.
*++2015.07.29
*        W_/ZAK/BELNR-VATDATE = W_VOSTE-VATDATE.
*--2015.07.29
          w_/zak/belnr-bldat   = w_voste-bldat.
          APPEND w_/zak/belnr TO i_/zak/belnr.
        ENDIF.
*--1565 #08.
      ENDLOOP.
*++S4HANA#01.
      FREE lt_/zak/zak_new_1[].
*--S4HANA#01.
*++1565 #08.
*++1665 #02.
*   Save the data only during production runs
*    IF NOT I_/ZAK/BELNR[] IS INITIAL.
      IF NOT i_/zak/belnr[] IS INITIAL AND NOT par_bsud IS INITIAL.
*--1665 #02.
        INSERT /zak/bset_belnr FROM TABLE i_/zak/belnr ACCEPTING DUPLICATE KEYS.
        COMMIT WORK.
      ENDIF.
*--1565 #08.
ENHANCEMENT-POINT /ZAK/ZAK_RG_BADI_014 SPOTS /ZAK/ES_BADI_016 .

    ENDLOOP.
  ENDLOOP.

ENDMETHOD.


method IF_EX_FI_TAX_BADI_016~SET_FLAG_USE_BADI_16.

 CH_USE_BADI_16 = 'X'.

endmethod.
ENDCLASS.
