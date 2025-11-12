*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_ABEVAZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_ABEV_CONTACT  text
*      -->P_I_ABEVAZ  text
*----------------------------------------------------------------------*
FORM GET_ABEVAZ USING   $ABEV_CONTACT STRUCTURE /ZAK/ABEVCONTACT
                        $BTYPE
                        $ABEVAZ.

  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.

  SELECT SINGLE ABEVAZE INTO L_ABEVAZ
                        FROM /ZAK/ABEVK
*++ BG 2006.12.13
                       WHERE BTYPE   EQ $BTYPE
                         AND ABEVAZ  EQ $ABEVAZ
                         AND BTYPEE  EQ $ABEV_CONTACT-BTYPE.
*--0003 BG 2006.12.13
  IF SY-SUBRC EQ 0.
    MOVE L_ABEVAZ TO $ABEVAZ.
*++ BG 2006.12.13
  ELSE.
    MOVE $ABEVAZ TO $ABEV_CONTACT-ABEVAZ.
*--0003 BG 2006.12.13
  ENDIF.

ENDFORM.                    " GET_ABEVAZ
*&---------------------------------------------------------------------*
*&      Form  get_abev_contact
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_BEVALLO_BTYPE  text
*      -->P_V_BEVALLO_ABEVAZ  text
*      <--P_V_BEVALLO_BTYPE_DISP  text
*      <--P_V_BEVALLO_ABEVAZ_DISP  text
*----------------------------------------------------------------------*
FORM GET_ABEV_CONTACT TABLES   I_BTYPE TYPE /ZAK/T_BTYPE
*++S4HANA#01.
*                      USING    $BTYPE
*                               $ABEVAZ
*                               $BTYPE_TO
*                      CHANGING $BTYPE_DISP
*                               $ABEVAZ_DISP.
                      USING    $BTYPE TYPE /ZAK/BEVALLALV-BTYPE
                               $ABEVAZ TYPE /ZAK/BEVALLALV-ABEVAZ
                               $BTYPE_TO TYPE /ZAK/BTYPE
                      CHANGING $BTYPE_DISP TYPE /ZAK/BEVALLALV-BTYPE_DISP
                               $ABEVAZ_DISP TYPE /ZAK/BEVALLALV-ABEVAZ_DISP.
*--S4HANA#01.
  DATA: W_BTYPE      TYPE /ZAK/BTYPE.
  DATA: L_BTYPE      TYPE /ZAK/BTYPE.
  DATA: L_ABEVAZ     TYPE /ZAK/ABEVAZ.
  DATA: L_ABEVAZ_NEW TYPE /ZAK/ABEVAZ.

  L_BTYPE  = $BTYPE.
  L_ABEVAZ = $ABEVAZ.
  LOOP AT I_BTYPE INTO W_BTYPE.

    IF L_BTYPE IS INITIAL.
      L_BTYPE = W_BTYPE.
    ENDIF.
    IF L_ABEVAZ_NEW IS INITIAL.
      L_ABEVAZ_NEW = L_ABEVAZ.
    ENDIF.

    L_ABEVAZ = L_ABEVAZ_NEW.

    CHECK W_BTYPE NE $BTYPE_TO.
    PERFORM READ_ABEVK USING W_BTYPE
                             L_ABEVAZ
                       CHANGING L_BTYPE
                                L_ABEVAZ_NEW.

  ENDLOOP.

* At the last record
  IF L_BTYPE IS INITIAL.
    L_BTYPE = W_BTYPE.
  ENDIF.
  IF L_ABEVAZ_NEW IS INITIAL.
    L_ABEVAZ_NEW = L_ABEVAZ.
  ENDIF.

  $BTYPE_DISP = L_BTYPE.
  $ABEVAZ_DISP = L_ABEVAZ_NEW.
ENDFORM.                    " get_abev_contact
*&---------------------------------------------------------------------*
*&      Form  get_all_btype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BTYPE_TO  text
*      <--P_L_BTYPE  text
*----------------------------------------------------------------------*
FORM GET_ALL_BTYPE TABLES   I_BTYPE TYPE /ZAK/T_BTYPE
*++S4HANA#01.
*                   USING    $BUKRS
*                            $BTYPE_FROM
*                            $BTYPE_TO.
                   USING    $BUKRS TYPE BUKRS
                            $BTYPE_FROM TYPE /ZAK/BTYPE
                            $BTYPE_TO TYPE /ZAK/BTYPE.
*--S4HANA#01.
  DATA: W_BTYPE    TYPE /ZAK/BTYPE.
  DATA: L_BTYPE    TYPE /ZAK/BTYPE.
  DATA: L_BTYPE_TO TYPE /ZAK/BTYPE.
  DATA: I_BTYPE_LOCAL TYPE /ZAK/T_BTYPE.
  DATA: L_COUNTER TYPE I.

  L_BTYPE_TO = $BTYPE_TO.
  L_BTYPE    = $BTYPE_FROM.


  APPEND L_BTYPE_TO TO I_BTYPE_LOCAL.

  DO.


    SELECT BTYPEE UP TO 1 ROWS INTO L_BTYPE FROM /ZAK/BEVALL
       WHERE BUKRS = $BUKRS
         AND BTYPE = L_BTYPE_TO
*++S4HANA#01.
      ORDER BY PRIMARY KEY.
*--S4HANA#01.
    ENDSELECT.

    APPEND L_BTYPE TO I_BTYPE_LOCAL.

    L_BTYPE_TO = L_BTYPE.

    IF L_BTYPE = $BTYPE_FROM.
      EXIT.
    ENDIF.

  ENDDO.


* Reverse the order of the records
*++S4HANA#01.
*  DESCRIBE TABLE I_BTYPE_LOCAL LINES L_COUNTER.
  L_COUNTER = LINES( I_BTYPE_LOCAL ).
*--S4HANA#01.

  DO.
    IF L_COUNTER = 0.
      EXIT.
    ENDIF.

    READ TABLE I_BTYPE_LOCAL INTO W_BTYPE INDEX L_COUNTER.
    IF SY-SUBRC = 0.
      APPEND W_BTYPE TO I_BTYPE.
      L_COUNTER = L_COUNTER - 1.
    ENDIF.
  ENDDO.

ENDFORM.                    " get_all_btype
*&---------------------------------------------------------------------*
*&      Form  read_abevk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_BTYPE  text
*      -->P_L_ABEVAZ  text
*      <--P_L_BTYPE  text
*      <--P_L_ABEVAZ_NEW  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM READ_ABEVK USING    $BTYPE_IN
*                         $ABEVAZ_IN
*                CHANGING $BTYPE_OUT
*                         $ABEVAZ_OUT.
FORM READ_ABEVK USING    $BTYPE_IN TYPE /ZAK/BTYPE
                         $ABEVAZ_IN TYPE /ZAK/ABEVAZ
                CHANGING $BTYPE_OUT TYPE /ZAK/BTYPE
                         $ABEVAZ_OUT TYPE /ZAK/ABEVAZ.
*--S4HANA#01.

  CLEAR W_/ZAK/ABEVK.
  SELECT * UP TO 1 ROWS INTO W_/ZAK/ABEVK FROM  /ZAK/ABEVK "#EC CI_NOFIELD
        WHERE  BTYPEE   = $BTYPE_IN
          AND    ABEVAZE  = $ABEVAZ_IN
*++S4HANA#01.
    ORDER BY PRIMARY KEY.
*--S4HANA#01.
  ENDSELECT.

  IF SY-SUBRC = 0.
    $BTYPE_OUT  = W_/ZAK/ABEVK-BTYPE.
    $ABEVAZ_OUT = W_/ZAK/ABEVK-ABEVAZ.

  ELSE.
    CLEAR: $BTYPE_OUT, $ABEVAZ_OUT.
  ENDIF.


ENDFORM.                    " read_abevk
*&---------------------------------------------------------------------*
*&      Form  get_abev_text
*&---------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_ABEV_TEXT USING    $BTYPE_DISP
*                            $ABEVAZ_DISP
*                   CHANGING $ABEVTEXT_DISP.
FORM GET_ABEV_TEXT USING $BTYPE_DISP TYPE /ZAK/BEVALLALV-BTYPE_DISP
                         $ABEVAZ_DISP TYPE /ZAK/BEVALLALV-ABEVAZ_DISP
                CHANGING $ABEVTEXT_DISP TYPE /ZAK/BEVALLALV-ABEVTEXT_DISP.
*--S4HANA#01.

  CLEAR $ABEVTEXT_DISP.

  SELECT SINGLE ABEVTEXT INTO $ABEVTEXT_DISP
    FROM  /ZAK/BEVALLBT
         WHERE  LANGU   = SY-LANGU
         AND    BTYPE   = $BTYPE_DISP
         AND    ABEVAZ  = $ABEVAZ_DISP.

ENDFORM.                    " get_abev_text
*&---------------------------------------------------------------------*
*&      Form  read_all_bevallb
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BTYPE_TO  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM READ_ALL_BEVALLB USING $BTYPE.
*
*  REFRESH I_/ZAK/BEVALLB.
FORM READ_ALL_BEVALLB USING $BTYPE TYPE /ZAK/BTYPE.

  CLEAR I_/ZAK/BEVALLB[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLB FROM /ZAK/BEVALLB
      WHERE BTYPE = $BTYPE
*++S4HANA#01.
    ORDER BY PRIMARY KEY.
*--S4HANA#01.

ENDFORM.                    " read_all_bevallb
*&---------------------------------------------------------------------*
*&      Form  check_validities
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BUKRS  text
*      -->P_I_BTYPE_FROM  text
*      -->P_I_BTYPE_TO  text
*      <--P_V_SUBRC  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_VALIDITIES USING    $BUKRS
*                               $BTYPE_FROM
*                               $BTYPE_TO
*                      CHANGING $SUBRC.
FORM CHECK_VALIDITIES USING    $BUKRS TYPE BUKRS
                               $BTYPE_FROM TYPE /ZAK/BTYPE
                               $BTYPE_TO TYPE /ZAK/BTYPE
                      CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.
  DATA: V_DATAB_FROM TYPE D,
        V_DATBI_FROM TYPE D,
        V_DATAB_TO   TYPE D,
        V_DATBI_TO   TYPE D.

  CLEAR $SUBRC.

* Validity of BTYPE_FROM
  PERFORM READ_BEVALL_VALID USING $BUKRS
                                  $BTYPE_FROM
                         CHANGING V_DATAB_FROM
                                  V_DATBI_FROM.

  PERFORM READ_BEVALL_VALID USING $BUKRS
                                  $BTYPE_TO
                         CHANGING V_DATAB_TO
                                  V_DATBI_TO.


  IF V_DATAB_FROM >= V_DATAB_TO OR
     V_DATBI_FROM >= V_DATBI_TO.
    $SUBRC = 4.
  ENDIF.


ENDFORM.                    " check_validities
*&---------------------------------------------------------------------*
*&      Form  read_bevall_valid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$BUKRS  text
*      -->P_$BTYPE_FROM  text
*      <--P_V_DATAB_FROM  text
*      <--P_V_DATBI_FROM  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM READ_BEVALL_VALID USING    $BUKRS
*                                $BTYPE
FORM READ_BEVALL_VALID USING    $BUKRS TYPE BUKRS
                                $BTYPE TYPE /ZAK/BTYPE
*--S4HANA#01.
                       CHANGING $DATAB
                                $DATBI.
  CLEAR: $DATAB, $DATBI.

  SELECT DATAB DATBI UP TO 1 ROWS INTO ($DATAB, $DATBI)
    FROM  /ZAK/BEVALL
      WHERE     BUKRS  = $BUKRS
         AND    BTYPE  = $BTYPE
*++S4HANA#01.
    ORDER BY PRIMARY KEY.
*--S4HANA#01.
  ENDSELECT.

ENDFORM.                    " read_bevall_valid
*&---------------------------------------------------------------------*
*&      Form  get_bevall
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/ANALITIKA_BUKRS  text
*      -->P_W_/ZAK/ANALITIKA_BTYPE  text
*      -->P_V_LAST_DATE  text
*      <--P_V_NEW_BTYPE  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_BEVALL USING    $BUKRS
*                         $BTYPE
*                         $LAST_DATE
*                CHANGING $BTYPART
*                         $NEW_BTYPE.
FORM GET_BEVALL USING    $BUKRS TYPE /ZAK/ANALITIKA-BUKRS
                         $BTYPE TYPE /ZAK/ANALITIKA-BTYPE
                         $LAST_DATE
                CHANGING $BTYPART TYPE /ZAK/BTYPART
                         $NEW_BTYPE TYPE /ZAK/BTYPE.
*--S4HANA#01.


  CLEAR: $BTYPART, $NEW_BTYPE.

*++S4HANA#01.
*  REFRESH I_/ZAK/BEVALL.
  CLEAR I_/ZAK/BEVALL[].
*--S4HANA#01.
  SELECT * INTO TABLE I_/ZAK/BEVALL FROM  /ZAK/BEVALL
      WHERE     BUKRS  = $BUKRS
         AND    BTYPE  = $BTYPE
         AND    DATBI  >= $LAST_DATE
         AND    DATAB  <= $LAST_DATE.

  DESCRIBE TABLE I_/ZAK/BEVALL LINES SY-TFILL.
  IF SY-TFILL >= 1.
    $NEW_BTYPE = $BTYPE.
  ELSE.
    CLEAR $BTYPART.
    SELECT BTYPART INTO $BTYPART UP TO 1 ROWS FROM  /ZAK/BEVALL
        WHERE     BUKRS  = $BUKRS
           AND    BTYPE  = $BTYPE
*++S4HANA#01.
      ORDER BY PRIMARY KEY.
*--S4HANA#01.
    ENDSELECT.
    IF SY-SUBRC = 0.
      CLEAR $NEW_BTYPE.
      SELECT BTYPE INTO $NEW_BTYPE UP TO 1 ROWS
         FROM  /ZAK/BEVALL
         WHERE     BUKRS    = $BUKRS
            AND    BTYPART  = $BTYPART
            AND    DATBI  >= $LAST_DATE
            AND    DATAB  <= $LAST_DATE
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
*--S4HANA#01.
      ENDSELECT.
      IF SY-SUBRC NE 0.
* Mi van ha nincs ilyen?
        CLEAR $NEW_BTYPE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_bevall

*&---------------------------------------------------------------------*
*&      Form  convert_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_W_/ZAK/ANALITIKA  text
*----------------------------------------------------------------------*
FORM CONVERT_ITEM CHANGING $/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA.
  DATA: I_CONTACT LIKE /ZAK/ABEVCONTACT OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION '/ZAK/ABEV_CONTACT'
    EXPORTING
      I_BUKRS        = $/ZAK/ANALITIKA-BUKRS
      I_BTYPE        = $/ZAK/ANALITIKA-BTYPE
      I_ABEVAZ       = $/ZAK/ANALITIKA-ABEVAZ
      I_GJAHR        = $/ZAK/ANALITIKA-GJAHR
      I_MONAT        = $/ZAK/ANALITIKA-MONAT
    TABLES
      T_ABEV_CONTACT = I_CONTACT
    EXCEPTIONS
      ERROR_BTYPE    = 1
      ERROR_MONAT    = 2
      ERROR_ABEVAZ   = 3
      OTHERS         = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*++S4HANA#01.
*  DESCRIBE TABLE I_CONTACT LINES SY-TFILL.
*  READ TABLE I_CONTACT INDEX SY-TFILL.
  SY-TFILL = LINES( I_CONTACT ).
  READ TABLE I_CONTACT INTO I_CONTACT INDEX SY-TFILL.
*--S4HANA#01.
  IF SY-SUBRC = 0.
    $/ZAK/ANALITIKA-BTYPE  = I_CONTACT-BTYPE.
    $/ZAK/ANALITIKA-ABEVAZ = I_CONTACT-ABEVAZ.
  ENDIF.

ENDFORM.                    " convert_item
*&---------------------------------------------------------------------*
*&      Form  convert_bevallo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_LINES  text
*----------------------------------------------------------------------*
FORM CONVERT_BEVALLO TABLES   T_BEVALLO STRUCTURE /ZAK/BEVALLO
                              I_LINES   STRUCTURE /ZAK/ATVEZ_SOR
                              I_EXCEL   STRUCTURE /ZAK/ATVEZ_EXCEL
                     USING    P_BUKRS.

*++S4HANA#01.
*  DATA: BEGIN OF I_LINES_TMP OCCURS 0,
*          SOR(2)    TYPE N,
*          OSZLOP(8) TYPE C,
*          ABEVAZ    TYPE /ZAK/ABEVAZ,
*          FIELD_N   TYPE /ZAK/FIELDN,
*          FIELD_C   TYPE /ZAK/FIELDC,
*        END OF I_LINES_TMP.
  TYPES: BEGIN OF TS_I_LINES_TMP ,
           SOR     TYPE N LENGTH 2,
           OSZLOP  TYPE C LENGTH 8,
           ABEVAZ  TYPE /ZAK/ABEVAZ,
           FIELD_N TYPE /ZAK/FIELDN,
           FIELD_C TYPE /ZAK/FIELDC,
         END OF TS_I_LINES_TMP .
  TYPES TT_I_LINES_TMP TYPE STANDARD TABLE OF TS_I_LINES_TMP .
  DATA: LS_I_LINES_TMP TYPE TS_I_LINES_TMP.
  DATA: LT_I_LINES_TMP TYPE TT_I_LINES_TMP.
*--S4HANA#01.



  LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO.

* Load form data for ABEV
    CLEAR W_/ZAK/BEVALLB.
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_/ZAK/BEVALLO-BTYPE
                ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE  = W_/ZAK/BEVALLO-BTYPE
          AND   ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
      INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
    ENDIF.


*++S4HANA#01.
*    I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
*    I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
*    I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
*    I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
*    I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.
*
*    CHECK I_LINES_TMP-SOR NE '00' OR
*          I_LINES_TMP-SOR NE SPACE.
*    APPEND I_LINES_TMP.
    LS_I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
    LS_I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
    LS_I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
    LS_I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
    LS_I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.

    CHECK LS_I_LINES_TMP-SOR NE '00' OR
          LS_I_LINES_TMP-SOR NE SPACE.
    APPEND LS_I_LINES_TMP TO LT_I_LINES_TMP.
*--S4HANA#01.


  ENDLOOP.

*++S4HANA#01.
*  SORT I_LINES_TMP.
*
*  LOOP AT I_LINES_TMP.
  SORT LT_I_LINES_TMP.

  LOOP AT LT_I_LINES_TMP INTO LS_I_LINES_TMP.
*--S4HANA#01.

    AT NEW SOR.
      CLEAR I_LINES.
    ENDAT.

*++S4HANA#01.
*    CASE I_LINES_TMP-OSZLOP.
*      WHEN 'A'.
*        I_LINES-ADONEM_SRC = I_LINES_TMP-FIELD_C.
*      WHEN 'C'.
*        I_LINES-WRBTR_SRC = I_LINES_TMP-FIELD_N.
*      WHEN 'D'.
*        I_LINES-ADONEM_DES = I_LINES_TMP-FIELD_C.
*      WHEN 'F'.
*        I_LINES-WRBTR_DES = I_LINES_TMP-FIELD_N.
*      WHEN 'G'.
*        I_LINES-WRBTR_UTAL = I_LINES_TMP-FIELD_N.
*    ENDCASE.
    CASE LS_I_LINES_TMP-OSZLOP.
      WHEN 'A'.
        I_LINES-ADONEM_SRC = LS_I_LINES_TMP-FIELD_C.
      WHEN 'C'.
        I_LINES-WRBTR_SRC = LS_I_LINES_TMP-FIELD_N.
      WHEN 'D'.
        I_LINES-ADONEM_DES = LS_I_LINES_TMP-FIELD_C.
      WHEN 'F'.
        I_LINES-WRBTR_DES = LS_I_LINES_TMP-FIELD_N.
      WHEN 'G'.
        I_LINES-WRBTR_UTAL = LS_I_LINES_TMP-FIELD_N.
    ENDCASE.
*--S4HANA#01.

    I_LINES-WAERS_SRC  = W_/ZAK/BEVALLO-WAERS.
    I_LINES-WAERS_DES  = W_/ZAK/BEVALLO-WAERS.
    I_LINES-WAERS_UTAL = W_/ZAK/BEVALLO-WAERS.

    PERFORM FILL_TEXTS  USING W_/ZAK/BEVALLO-BUKRS
                        CHANGING I_LINES.

    AT END OF SOR.
      APPEND I_LINES.
    ENDAT.
  ENDLOOP.



* Excel format
  LOOP AT I_LINES.
    CHECK I_LINES-WRBTR_DES > 0.

    CLEAR I_EXCEL.
*++BG 2006/11/22
*   I_EXCEL-ADONEM_SRC_TXT = I_LINES-ADONEM_SRC_TXT.
    I_EXCEL-ADONEM_DES_TXT = I_LINES-ADONEM_SRC_TXT.
*--BG 2006/11/22

    SELECT SINGLE LIFNR SAKNR
*++BG 2006/11/22
*      INTO (I_EXCEL-ADONEM_SRC_LIFNR, I_EXCEL-ADONEM_SRC_SAKNR)
       INTO (I_EXCEL-ADONEM_DES_LIFNR, I_EXCEL-ADONEM_DES_SAKNR)
*--BG 2006/11/22
       FROM /ZAK/ADONEM
       WHERE BUKRS = P_BUKRS
         AND ADONEM = I_LINES-ADONEM_SRC.
*++BG 2006/11/22
*   I_EXCEL-ADONEM_DES_TXT = I_LINES-ADONEM_DES_TXT.
    I_EXCEL-ADONEM_SRC_TXT = I_LINES-ADONEM_DES_TXT.
*--BG 2006/11/22

    SELECT SINGLE LIFNR SAKNR
*++BG 2006/11/22
*      INTO (I_EXCEL-ADONEM_DES_LIFNR, I_EXCEL-ADONEM_DES_SAKNR)
       INTO (I_EXCEL-ADONEM_SRC_LIFNR, I_EXCEL-ADONEM_SRC_SAKNR)
*--BG 2006/11/22
       FROM /ZAK/ADONEM
       WHERE BUKRS = P_BUKRS
         AND ADONEM = I_LINES-ADONEM_DES.


    IF I_LINES-WRBTR_SRC = I_LINES-WRBTR_DES.
      WRITE I_LINES-WRBTR_SRC TO I_EXCEL-WRBTR
            CURRENCY I_LINES-WAERS_SRC
            NO-GROUPING.
    ELSE.
      WRITE I_LINES-WRBTR_DES TO I_EXCEL-WRBTR
            CURRENCY I_LINES-WAERS_SRC
            NO-GROUPING.
    ENDIF.
    APPEND I_EXCEL.
  ENDLOOP.


ENDFORM.                    " convert_bevallo
*&---------------------------------------------------------------------*
*&      Form  convert_bevallo_new
*&---------------------------------------------------------------------*
*       FI 20070111
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_LINES  text
*----------------------------------------------------------------------*
FORM CONVERT_BEVALLO_NEW TABLES   T_BEVALLO STRUCTURE /ZAK/BEVALLO
*                              I_LINES   STRUCTURE /ZAK/ATVEZ_SOR
                              I_EXCEL   STRUCTURE /ZAK/ATV_EXCELN
*++S4HANA#01.
*                     USING    P_BUKRS.
                     USING    P_BUKRS TYPE BUKRS..
*--S4HANA#01.

*++S4HANA#01.
*  DATA: BEGIN OF I_LINES_TMP OCCURS 0,
*          SOR(2)    TYPE N,
*          OSZLOP(8) TYPE C,
*          ABEVAZ    TYPE /ZAK/ABEVAZ,
*          FIELD_N   TYPE /ZAK/FIELDN,
*          FIELD_C   TYPE /ZAK/FIELDC.
*          INCLUDE STRUCTURE /ZAK/ATV_EXCELN.
*  DATA: END OF I_LINES_TMP.
*  DATA: BEGIN OF I_LINES  OCCURS 0.
*          INCLUDE STRUCTURE /ZAK/ATVEZ_SOR.
*          INCLUDE STRUCTURE /ZAK/ATV_EXCELN.
*  DATA: END OF I_LINES.
  TYPES: BEGIN OF TS_I_LINES_TMP ,
           SOR     TYPE N LENGTH 2,
           OSZLOP  TYPE C LENGTH 8,
           ABEVAZ  TYPE /ZAK/ABEVAZ,
           FIELD_N TYPE /ZAK/FIELDN,
           FIELD_C TYPE /ZAK/FIELDC.
           INCLUDE TYPE /ZAK/ATV_EXCELN.
  TYPES: END OF TS_I_LINES_TMP .
  TYPES TT_I_LINES_TMP TYPE STANDARD TABLE OF TS_I_LINES_TMP .
  DATA: LS_I_LINES_TMP TYPE TS_I_LINES_TMP.
  DATA: LT_I_LINES_TMP TYPE TT_I_LINES_TMP.
  TYPES: BEGIN OF TS_I_LINES .
           INCLUDE TYPE /ZAK/ATVEZ_SOR.
           INCLUDE TYPE /ZAK/ATV_EXCELN.
  TYPES: END OF TS_I_LINES .
  TYPES TT_I_LINES TYPE STANDARD TABLE OF TS_I_LINES .
  DATA: LS_I_LINES TYPE TS_I_LINES.
  DATA: LT_I_LINES TYPE TT_I_LINES.
*--S4HANA#01.

  LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO.

* Load form data for ABEV
    CLEAR W_/ZAK/BEVALLB.
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_/ZAK/BEVALLO-BTYPE
                ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE  = W_/ZAK/BEVALLO-BTYPE
          AND   ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
      INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
    ENDIF.

*++S4HANA#01.
*    I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
*    I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
*    I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
*    I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
*    I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.
*    CHECK I_LINES_TMP-SOR NE '00' OR
*          I_LINES_TMP-SOR NE SPACE.
    LS_I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
    LS_I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
    LS_I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
    LS_I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
    LS_I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.
    CHECK LS_I_LINES_TMP-SOR NE '00' OR
          LS_I_LINES_TMP-SOR NE SPACE.
*--S4HANA#01.
*   Fill whatever is possible for Excel
*++S4HANA#01.
*    I_LINES_TMP-BUKRS       = W_/ZAK/BEVALLO-BUKRS.
    LS_I_LINES_TMP-BUKRS       = W_/ZAK/BEVALLO-BUKRS.
*--S4HANA#01.
*    concatenate  W_/ZAK/BEVALLO-BTYPE(5)
*                 W_/ZAK/BEVALLO-GJAHR
*                 W_/ZAK/BEVALLO-MONAT
*                 W_/ZAK/BEVALLO-ZINDEX into I_LINES_TMP-REFERENCIA.
*++S4HANA#01.
*    I_LINES_TMP-PENZNEM  = W_/ZAK/BEVALLO-WAERS.
*    I_LINES_TMP-PERIODUS = SY-DATUM+4(2).
*    I_LINES_TMP-BIZFAJTA = 'KF'.
*    WRITE SY-DATUM TO I_LINES_TMP-KONYVDAT.
*    WRITE SY-DATUM TO I_LINES_TMP-BIZDATUM.
*    I_LINES_TMP-SZOVEG = 'Tax transfer'.
*    I_LINES_TMP-FEJSZOVEG = ' '.
**    I_LINES_TMP-OSSZEG
*    I_LINES_TMP-KK1 = '27'.
*    PERFORM GET_UZLAG USING W_/ZAK/BEVALLO-BUKRS
*                            I_LINES_TMP-UZLETAG.
*    I_LINES_TMP-KK2 = '37'.
*    APPEND I_LINES_TMP.
    LS_I_LINES_TMP-PENZNEM  = W_/ZAK/BEVALLO-WAERS.
    LS_I_LINES_TMP-PERIODUS = SY-DATUM+4(2).
    LS_I_LINES_TMP-BIZFAJTA = 'KF'.
    WRITE SY-DATUM TO LS_I_LINES_TMP-KONYVDAT.
    WRITE SY-DATUM TO LS_I_LINES_TMP-BIZDATUM.
    LS_I_LINES_TMP-SZOVEG = 'Adó átvezetés'.
    LS_I_LINES_TMP-FEJSZOVEG = ' '.
    LS_I_LINES_TMP-KK1 = '27'.
    PERFORM GET_UZLAG USING W_/ZAK/BEVALLO-BUKRS
                            CHANGING LS_I_LINES_TMP-UZLETAG.
    LS_I_LINES_TMP-KK2 = '37'.
    APPEND LS_I_LINES_TMP TO LT_I_LINES_TMP.
*--S4HANA#01.
  ENDLOOP.

*++S4HANA#01.
*  SORT I_LINES_TMP.
** Assemble the data
*  LOOP AT I_LINES_TMP.
  SORT LT_I_LINES_TMP.
*  ASSEMBLE THE DATA
  LOOP AT LT_I_LINES_TMP INTO LS_I_LINES_TMP.
*--S4HANA#01.

    AT NEW SOR.
*++S4HANA#01.
*      CLEAR I_LINES.
*    ENDAT.
*    MOVE-CORRESPONDING I_LINES_TMP TO I_LINES.
*    CASE I_LINES_TMP-OSZLOP.
*      WHEN 'A'.
*        I_LINES-ADONEM_SRC = I_LINES_TMP-FIELD_C.
*      WHEN 'C'.
*        I_LINES-WRBTR_SRC = I_LINES_TMP-FIELD_N.
*      WHEN 'D'.
*        I_LINES-ADONEM_DES = I_LINES_TMP-FIELD_C.
*      WHEN 'F'.
*        I_LINES-WRBTR_DES = I_LINES_TMP-FIELD_N.
*      WHEN 'G'.
*        I_LINES-WRBTR_UTAL = I_LINES_TMP-FIELD_N.
*    ENDCASE.
      CLEAR LS_I_LINES.
    ENDAT.
    MOVE-CORRESPONDING LS_I_LINES_TMP TO LS_I_LINES.
    CASE LS_I_LINES_TMP-OSZLOP.
      WHEN 'A'.
        LS_I_LINES-ADONEM_SRC = LS_I_LINES_TMP-FIELD_C.
      WHEN 'C'.
        LS_I_LINES-WRBTR_SRC = LS_I_LINES_TMP-FIELD_N.
      WHEN 'D'.
        LS_I_LINES-ADONEM_DES = LS_I_LINES_TMP-FIELD_C.
      WHEN 'F'.
        LS_I_LINES-WRBTR_DES = LS_I_LINES_TMP-FIELD_N.
      WHEN 'G'.
        LS_I_LINES-WRBTR_UTAL = LS_I_LINES_TMP-FIELD_N.
    ENDCASE.
*--S4HANA#01.


    AT END OF SOR.
*++S4HANA#01.
*      APPEND I_LINES.
      APPEND LS_I_LINES TO LT_I_LINES.
*--S4HANA#01.
    ENDAT.
  ENDLOOP.



* Excel format
*++S4HANA#01.
*  LOOP AT I_LINES.
*    CHECK I_LINES-WRBTR_DES > 0.
*
*    CLEAR I_EXCEL.
*    MOVE-CORRESPONDING I_LINES TO I_EXCEL.
  LOOP AT LT_I_LINES INTO LS_I_LINES.
    CHECK LS_I_LINES-WRBTR_DES > 0.

    CLEAR I_EXCEL.
    MOVE-CORRESPONDING LS_I_LINES TO I_EXCEL.
*--S4HANA#01.
    SELECT SINGLE LIFNR
       INTO I_EXCEL-FOKONYV1
       FROM /ZAK/ADONEM
       WHERE BUKRS = P_BUKRS
*++S4HANA#01.
*         AND ADONEM = I_LINES-ADONEM_SRC.
         AND ADONEM = LS_I_LINES-ADONEM_SRC.
*--S4HANA#01.

    SELECT SINGLE LIFNR
       INTO I_EXCEL-FOKONYV2
       FROM /ZAK/ADONEM
       WHERE BUKRS = P_BUKRS
*++S4HANA#01.
*         AND ADONEM = I_LINES-ADONEM_DES.
         AND ADONEM = LS_I_LINES-ADONEM_DES.
*--S4HANA#01.


*++S4HANA#01.
*    IF I_LINES-WRBTR_SRC = I_LINES-WRBTR_DES.
*      WRITE I_LINES-WRBTR_SRC TO I_EXCEL-OSSZEG
*            CURRENCY I_LINES-PENZNEM
*            NO-GROUPING.
*    ELSE.
*      WRITE I_LINES-WRBTR_DES TO I_EXCEL-OSSZEG
*            CURRENCY I_LINES-PENZNEM
    IF LS_I_LINES-WRBTR_SRC = LS_I_LINES-WRBTR_DES.
      WRITE LS_I_LINES-WRBTR_SRC TO I_EXCEL-OSSZEG
            CURRENCY LS_I_LINES-PENZNEM
            NO-GROUPING.
    ELSE.
      WRITE LS_I_LINES-WRBTR_DES TO I_EXCEL-OSSZEG
            CURRENCY LS_I_LINES-PENZNEM
*--S4HANA#01.
              NO-GROUPING.
    ENDIF.
    APPEND I_EXCEL.
  ENDLOOP.


ENDFORM.                    " convert_bevallo_v2
*&---------------------------------------------------------------------*
*&      Form  convert_bevallo_v2
*&---------------------------------------------------------------------*
*       FI 20070111
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_LINES  text
*----------------------------------------------------------------------*
FORM CONVERT_BEVALLO_V2 TABLES   T_BEVALLO STRUCTURE /ZAK/BEVALLO
*                              I_LINES   STRUCTURE /ZAK/ATVEZ_SOR
                              I_EXCEL   STRUCTURE /ZAK/ATV_EXCELV2
                     USING    P_BUKRS.

*++S4HANA#01.
*  DATA: BEGIN OF I_LINES_TMP OCCURS 0,
*          SOR(2)    TYPE N,
*          OSZLOP(8) TYPE C,
*          ABEVAZ    TYPE /ZAK/ABEVAZ,
*          FIELD_N   TYPE /ZAK/FIELDN,
*          FIELD_C   TYPE /ZAK/FIELDC.
*          INCLUDE STRUCTURE /ZAK/ATV_EXCELV2.
*  DATA: END OF I_LINES_TMP.
*  DATA: BEGIN OF I_LINES  OCCURS 0.
*          INCLUDE STRUCTURE /ZAK/ATVEZ_SOR.
*          INCLUDE STRUCTURE /ZAK/ATV_EXCELV2.
*  DATA: END OF I_LINES.
  TYPES: BEGIN OF TS_I_LINES_TMP ,
           SOR     TYPE N LENGTH 2,
           OSZLOP  TYPE C LENGTH 8,
           ABEVAZ  TYPE /ZAK/ABEVAZ,
           FIELD_N TYPE /ZAK/FIELDN,
           FIELD_C TYPE /ZAK/FIELDC.
           INCLUDE TYPE /ZAK/ATV_EXCELV2.
  TYPES: END OF TS_I_LINES_TMP .
  TYPES TT_I_LINES_TMP TYPE STANDARD TABLE OF TS_I_LINES_TMP .
  DATA: LS_I_LINES_TMP TYPE TS_I_LINES_TMP.
  DATA: LT_I_LINES_TMP TYPE TT_I_LINES_TMP.
  TYPES: BEGIN OF TS_I_LINES .
           INCLUDE TYPE /ZAK/ATVEZ_SOR.
           INCLUDE TYPE /ZAK/ATV_EXCELV2.
  TYPES: END OF TS_I_LINES .
  TYPES TT_I_LINES TYPE STANDARD TABLE OF TS_I_LINES .
  DATA: LS_I_LINES TYPE TS_I_LINES.
  DATA: LT_I_LINES TYPE TT_I_LINES.
*--S4HANA#01.
  DATA: L_SZAMLA_BELNR(10).

  LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO.

* Load form data for ABEV
    CLEAR W_/ZAK/BEVALLB.
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_/ZAK/BEVALLO-BTYPE
                ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE  = W_/ZAK/BEVALLO-BTYPE
          AND   ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
      INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
    ENDIF.

*++S4HANA#01.
*    I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
*    I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
*    I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
*    I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
*    I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.
*    CHECK I_LINES_TMP-SOR NE '00' OR
*          I_LINES_TMP-SOR NE SPACE.
    LS_I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
    LS_I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
    LS_I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
    LS_I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
    LS_I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.
    CHECK LS_I_LINES_TMP-SOR NE '00' OR
          LS_I_LINES_TMP-SOR NE SPACE.
*--S4HANA#01.

*    One identifier should group the items; currently a single item number does this
*++S4HANA#01.
*    L_SZAMLA_BELNR =    L_SZAMLA_BELNR + 1 .
*    I_LINES_TMP-BIZ_AZON = L_SZAMLA_BELNR.
*    I_LINES_TMP-BIZ_TETEL = '0001'.
*    I_LINES_TMP-PENZNEM  = W_/ZAK/BEVALLO-WAERS.
*    I_LINES_TMP-HO = SY-DATUM+4(2).
*    I_LINES_TMP-BF = 'KF'.
*    WRITE SY-DATUM TO I_LINES_TMP-KONYV_DAT.
*    WRITE SY-DATUM TO I_LINES_TMP-BIZ_DATUM.
*    I_LINES_TMP-SZOVEG = 'Tax transfer'.
*    I_LINES_TMP-FEJSZOVEG = ' '.
*    I_LINES_TMP-KK = '27'.
*    PERFORM GET_UZLAG USING W_/ZAK/BEVALLO-BUKRS
*                            I_LINES_TMP-UZLETAG.
**   Saves the first row
*    APPEND I_LINES_TMP.
    LS_I_LINES_TMP-BIZ_AZON = L_SZAMLA_BELNR.
    LS_I_LINES_TMP-BIZ_TETEL = '0001'.
    LS_I_LINES_TMP-PENZNEM  = W_/ZAK/BEVALLO-WAERS.
    LS_I_LINES_TMP-HO = SY-DATUM+4(2).
    LS_I_LINES_TMP-BF = 'KF'.
    WRITE SY-DATUM TO LS_I_LINES_TMP-KONYV_DAT.
    WRITE SY-DATUM TO LS_I_LINES_TMP-BIZ_DATUM.
    LS_I_LINES_TMP-SZOVEG = 'Adó átvezetés'.
    LS_I_LINES_TMP-FEJSZOVEG = ' '.
    LS_I_LINES_TMP-KK = '27'.
    PERFORM GET_UZLAG USING W_/ZAK/BEVALLO-BUKRS
                            CHANGING LS_I_LINES_TMP-UZLETAG.
*   SAVES THE FIRST ROW
    APPEND LS_I_LINES_TMP TO LT_I_LINES_TMP.
*--S4HANA#01.
*    I_LINES_TMP-KK  = '37'.
**   elmenti az 2. sort
*    APPEND I_LINES_TMP.
  ENDLOOP.

*++S4HANA#01.
*  SORT I_LINES_TMP.
** Assemble the data
*  LOOP AT I_LINES_TMP.
  SORT LT_I_LINES_TMP.
* Assemble the data
  LOOP AT LT_I_LINES_TMP INTO LS_I_LINES_TMP.
*--S4HANA#01.

    AT NEW SOR.
*++S4HANA#01.
*      CLEAR I_LINES.
*    ENDAT.
*    MOVE-CORRESPONDING I_LINES_TMP TO I_LINES.
*    CASE I_LINES_TMP-OSZLOP.
*      WHEN 'A'.
*        I_LINES-ADONEM_SRC = I_LINES_TMP-FIELD_C.
*      WHEN 'C'.
*        I_LINES-WRBTR_SRC = I_LINES_TMP-FIELD_N.
*      WHEN 'D'.
*        I_LINES-ADONEM_DES = I_LINES_TMP-FIELD_C.
*      WHEN 'F'.
*        I_LINES-WRBTR_DES = I_LINES_TMP-FIELD_N.
*      WHEN 'G'.
*        I_LINES-WRBTR_UTAL = I_LINES_TMP-FIELD_N.
*    ENDCASE.
      CLEAR LS_I_LINES.
    ENDAT.
    MOVE-CORRESPONDING LS_I_LINES_TMP TO LS_I_LINES.
    CASE LS_I_LINES_TMP-OSZLOP.
      WHEN 'A'.
        LS_I_LINES-ADONEM_SRC = LS_I_LINES_TMP-FIELD_C.
      WHEN 'C'.
        LS_I_LINES-WRBTR_SRC = LS_I_LINES_TMP-FIELD_N.
      WHEN 'D'.
        LS_I_LINES-ADONEM_DES = LS_I_LINES_TMP-FIELD_C.
      WHEN 'F'.
        LS_I_LINES-WRBTR_DES = LS_I_LINES_TMP-FIELD_N.
      WHEN 'G'.
        LS_I_LINES-WRBTR_UTAL = LS_I_LINES_TMP-FIELD_N.
    ENDCASE.
*--S4HANA#01.


    AT END OF SOR.
*++S4HANA#01.
*      APPEND I_LINES.
      APPEND LS_I_LINES TO LT_I_LINES.
*--S4HANA#01.
    ENDAT.
  ENDLOOP.



* Excel format
* Create two posting lines from one row
*++S4HANA#01.
*  LOOP AT I_LINES.
*    CHECK I_LINES-WRBTR_DES > 0.
  LOOP AT LT_I_LINES INTO LS_I_LINES.
    CHECK LS_I_LINES-WRBTR_DES > 0.
*--S4HANA#01.

    CLEAR I_EXCEL.
*   Determine line 1
*++S4HANA#01.
*    MOVE-CORRESPONDING I_LINES TO I_EXCEL.
    MOVE-CORRESPONDING LS_I_LINES TO I_EXCEL.
*--S4HANA#01.
    SELECT SINGLE LIFNR
       INTO I_EXCEL-FOKONYV
       FROM /ZAK/ADONEM
       WHERE BUKRS = P_BUKRS
*++S4HANA#01.
*         AND ADONEM = I_LINES-ADONEM_SRC.
         AND ADONEM = LS_I_LINES-ADONEM_SRC.
*--S4HANA#01.

*++S4HANA#01.
*    IF I_LINES-WRBTR_SRC = I_LINES-WRBTR_DES.
*      WRITE I_LINES-WRBTR_SRC TO I_EXCEL-OSSZEG
*            CURRENCY I_LINES-PENZNEM
*            NO-GROUPING.
*    ELSE.
*      WRITE I_LINES-WRBTR_DES TO I_EXCEL-OSSZEG
*            CURRENCY I_LINES-PENZNEM
    IF LS_I_LINES-WRBTR_SRC = LS_I_LINES-WRBTR_DES.
      WRITE LS_I_LINES-WRBTR_SRC TO I_EXCEL-OSSZEG
            CURRENCY LS_I_LINES-PENZNEM
            NO-GROUPING.
    ELSE.
      WRITE LS_I_LINES-WRBTR_DES TO I_EXCEL-OSSZEG
            CURRENCY LS_I_LINES-PENZNEM
*--S4HANA#01.
              NO-GROUPING.
    ENDIF.
*   Save line 1
    APPEND I_EXCEL.
*   Process item 2
    I_EXCEL-BIZ_TETEL = '0002'.
    I_EXCEL-KK        = '37'.

    SELECT SINGLE LIFNR
       INTO I_EXCEL-FOKONYV
       FROM /ZAK/ADONEM
       WHERE BUKRS = P_BUKRS
*++S4HANA#01.
*         AND ADONEM = I_LINES-ADONEM_DES.
         AND ADONEM = LS_I_LINES-ADONEM_DES.
*--S4HANA#01.
*   Save line 2
    APPEND I_EXCEL.
  ENDLOOP.


ENDFORM.                    " convert_bevallo_v2

*&---------------------------------------------------------------------*
*&      Form  READ_BEVALLB_m
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM READ_BEVALLB_M USING  $BTYPE.
*  REFRESH I_/ZAK/BEVALLB.
FORM READ_BEVALLB_M USING  $BTYPE TYPE /ZAK/BTYPE.
  CLEAR I_/ZAK/BEVALLB[].
*--S4HANA#01.

  SELECT * INTO TABLE I_/ZAK/BEVALLB FROM /ZAK/BEVALLB
      WHERE BTYPE = $BTYPE.
*++BG 2006/06/23
  SORT I_/ZAK/BEVALLB BY BTYPE ABEVAZ.
*--BG 2006/06/23
ENDFORM.                    " READ_BEVALLB_m
*&---------------------------------------------------------------------*
*&      Form  fill_texts
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM FILL_TEXTS USING P_BUKRS
FORM FILL_TEXTS USING P_BUKRS TYPE /ZAK/BEVALLO-BUKRS
*--S4HANA#01.
                CHANGING I_LINES STRUCTURE /ZAK/ATVEZ_SOR.

* Tax code description - source
  IF NOT I_LINES-ADONEM_SRC IS INITIAL.

    SELECT SINGLE ADONEM_TXT INTO I_LINES-ADONEM_SRC_TXT
        FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = P_BUKRS
           AND    ADONEM  = I_LINES-ADONEM_SRC.
  ENDIF.

* Tax code description - target
  IF NOT I_LINES-ADONEM_DES IS INITIAL.

    SELECT SINGLE ADONEM_TXT INTO I_LINES-ADONEM_DES_TXT
        FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = P_BUKRS
           AND    ADONEM  = I_LINES-ADONEM_DES.
  ENDIF.


ENDFORM.                    " fill_texts
*&---------------------------------------------------------------------*
*&      Form  download_file_v2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE_V2 TABLES
                          I_EXCEL STRUCTURE /ZAK/ATV_EXCELV2
                   USING    P_BUKRS
                            P_BTYPE
                   CHANGING P_ERROR.

  DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
        L_CANCEL(1).

  DATA: BEGIN OF I_FIELDS OCCURS 10,
          NAME(40),
        END OF I_FIELDS.

  DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
  DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

*++ BG 2006.04.20
  DATA:
    L_FILENAME TYPE STRING,
    L_FILTER   TYPE STRING,
    L_PATH     TYPE STRING,
    L_FULLPATH TYPE STRING,
    L_ACTION   TYPE I.

  DATA:  L_FILENAME_DOWN LIKE RLGRAP-FILENAME.
*  DATA:  L_RC.

*-- BG 2006.04.20

*++S4HANA#01.
  DATA LV_FILENAME TYPE STRING.
  DATA LV_PATH TYPE STRING.
  DATA LV_DEFAULT_FILENAME TYPE STRING.
  DATA LV_FULLPATH TYPE STRING.
  DATA LV_USER_ACTION TYPE I.
  DATA LV_RC TYPE I.
  DATA LV_WINDOW_TITLE TYPE STRING.
*--S4HANA#01.

  CLEAR P_ERROR.

  CONCATENATE P_BUKRS P_BTYPE INTO L_DEF_FILENAME
    SEPARATED BY '_'.
  CONCATENATE L_DEF_FILENAME '.XLS' INTO L_DEF_FILENAME.

* Read the data structure
  CALL FUNCTION 'DD_GET_DD03P_ALL'
    EXPORTING
      LANGU         = SYST-LANGU
      TABNAME       = '/ZAK/ATV_EXCELV2'
    TABLES
      A_DD03P_TAB   = I_DD03P
      N_DD03P_TAB   = I_DD03P_2
    EXCEPTIONS
      ILLEGAL_VALUE = 1
      OTHERS        = 2.

  IF SY-SUBRC = 0.

    LOOP AT I_DD03P WHERE FIELDNAME <> '.INCLUDE'.
      I_FIELDS-NAME = I_DD03P-REPTEXT.
      APPEND I_FIELDS.
    ENDLOOP.

  ENDIF.

*++ BG 2006.04.20 Path determination
  MOVE L_DEF_FILENAME TO L_FILENAME.


* ++ CST 2006.05.27
  L_FILTER = '*.XLS'.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
*     WINDOW_TITLE      =
*     DEFAULT_EXTENSION = '*.*'
      DEFAULT_FILE_NAME = L_FILENAME
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    CHANGING
      FILENAME          = L_FILENAME
      PATH              = L_PATH
      FULLPATH          = L_FULLPATH
      USER_ACTION       = L_ACTION
    EXCEPTIONS
      CNTL_ERROR        = 1
      ERROR_NO_GUI      = 2
      OTHERS            = 3.

  CHECK SY-SUBRC = 0.

  MOVE L_FULLPATH TO L_DEF_FILENAME.
*-- BG 2006.04.20


*  DATA: L_MASK(20)   TYPE C VALUE ',*.XLS  ,*.xls.'.


*  CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING
*                DEF_FILENAME     =  L_DEF_FILENAME
**                def_path         =  L_DEF_FILENAME
*                MASK             =  L_MASK
*                MODE             = 'S'
*                TITLE            =  SY-TITLE
*     IMPORTING  FILENAME         =  L_FILENAME
**                RC               =  l_rc
*     EXCEPTIONS INV_WINSYS       =  04
*                NO_BATCH         =  08
*                SELECTION_CANCEL =  12
*                SELECTION_ERROR  =  16.
* -- CST 2006.05.27

  MOVE L_FILENAME TO L_FILENAME_DOWN.

*++S4HANA#01.
*  CALL FUNCTION 'DOWNLOAD'
*    EXPORTING
*      FILENAME                = L_FILENAME_DOWN
*      FILETYPE                = 'DAT'
**++ BG 2006/03/30
*      ITEM                    = 'Transfer posting accounting upload'(004)
**-- BG 2006/03/30
**     FILEMASK_ALL            = 'X'
*      FILETYPE_NO_CHANGE      = 'X'
*      FILETYPE_NO_SHOW        = 'X'
*    IMPORTING
*      CANCEL                  = L_CANCEL
*    TABLES
*      DATA_TAB                = I_EXCEL[]
*      FIELDNAMES              = I_FIELDS
*    EXCEPTIONS
*      INVALID_FILESIZE        = 1
*      INVALID_TABLE_WIDTH     = 2
*      INVALID_TYPE            = 3
*      NO_BATCH                = 4
*      UNKNOWN_ERROR           = 5
*      GUI_REFUSE_FILETRANSFER = 6
*      CUSTOMER_ERROR          = 7
*      OTHERS                  = 8.
  LV_DEFAULT_FILENAME = L_FILENAME_DOWN.
  CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
    EXPORTING
      FULL_NAME     = LV_DEFAULT_FILENAME
    IMPORTING
      STRIPPED_NAME = LV_FILENAME
      FILE_PATH     = LV_PATH
    EXCEPTIONS
      X_ERROR       = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  LV_WINDOW_TITLE = 'Átvezetés könyvelési feladás'(004).
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_WINDOW_TITLE
      DEFAULT_FILE_NAME = LV_FILENAME
      INITIAL_DIRECTORY = LV_PATH
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
      USER_ACTION       = LV_USER_ACTION.
  CHECK LV_USER_ACTION EQ 0.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME   = LV_FULLPATH
      FILETYPE   = 'DAT'
      FIELDNAMES = I_FIELDS[]
    CHANGING
      DATA_TAB   = I_EXCEL[]
    EXCEPTIONS
      OTHERS     = 1.
*--S4HANA#01.

  IF SY-SUBRC <> 0 OR L_CANCEL = 'X' OR L_CANCEL = 'x'.
    P_ERROR = 'X'.
  ENDIF.
ENDFORM.                    " download_file_v2
*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE TABLES
* ++ FI 20070111
*                          I_EXCEL STRUCTURE /ZAK/ATVEZ_EXCEL
                          I_EXCEL STRUCTURE /ZAK/ATV_EXCELN
* -- FI 20070111
*++S4HANA#01.
*                   USING    P_BUKRS
*                            P_BTYPE
*                   CHANGING P_ERROR.
                   USING    P_BUKRS TYPE BUKRS
                            P_BTYPE TYPE /ZAK/BTYPE
                   CHANGING P_ERROR TYPE CLIKE.
*--S4HANA#01.

  DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
        L_CANCEL(1).

  DATA: BEGIN OF I_FIELDS OCCURS 10,
          NAME(40),
        END OF I_FIELDS.

  DATA: I_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
  DATA: I_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

*++ BG 2006.04.20
  DATA:
    L_FILENAME TYPE STRING,
    L_FILTER   TYPE STRING,
    L_PATH     TYPE STRING,
    L_FULLPATH TYPE STRING,
    L_ACTION   TYPE I.

  DATA:  L_FILENAME_DOWN LIKE RLGRAP-FILENAME.
*  DATA:  L_RC.

*-- BG 2006.04.20

*++S4HANA#01.
  DATA LV_FILENAME TYPE STRING.
  DATA LV_PATH TYPE STRING.
  DATA LV_DEFAULT_FILENAME TYPE STRING.
  DATA LV_FULLPATH TYPE STRING.
  DATA LV_USER_ACTION TYPE I.
  DATA LV_RC TYPE I.
  DATA LV_WINDOW_TITLE TYPE STRING.
*--S4HANA#01.

  CLEAR P_ERROR.

  CONCATENATE P_BUKRS P_BTYPE INTO L_DEF_FILENAME
    SEPARATED BY '_'.
  CONCATENATE L_DEF_FILENAME '.XLS' INTO L_DEF_FILENAME.

* Read the data structure
  CALL FUNCTION 'DD_GET_DD03P_ALL'
    EXPORTING
      LANGU         = SYST-LANGU
      TABNAME       = '/ZAK/ATV_EXCELN'
    TABLES
      A_DD03P_TAB   = I_DD03P
      N_DD03P_TAB   = I_DD03P_2
    EXCEPTIONS
      ILLEGAL_VALUE = 1
      OTHERS        = 2.

  IF SY-SUBRC = 0.

    LOOP AT I_DD03P.
      IF I_DD03P-FIELDNAME+7(3) = 'SRC'.
        CONCATENATE  'T' I_DD03P-REPTEXT INTO I_FIELDS-NAME.
      ELSEIF I_DD03P-FIELDNAME+7(3) = 'DES'.
        CONCATENATE  'K' I_DD03P-REPTEXT INTO I_FIELDS-NAME.
      ELSE.
        I_FIELDS-NAME = I_DD03P-REPTEXT.
      ENDIF.
      APPEND I_FIELDS.
    ENDLOOP.
*++FI20070222
  ELSE.
*  If there is an error then the error code must be set
    P_ERROR = 'X'.
*--FI20070222
  ENDIF.

*++ BG 2006.04.20 Path determination
  MOVE L_DEF_FILENAME TO L_FILENAME.


* ++ CST 2006.05.27
  L_FILTER = '*.XLS'.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
*     WINDOW_TITLE      =
*     DEFAULT_EXTENSION = '*.*'
      DEFAULT_FILE_NAME = L_FILENAME
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    CHANGING
      FILENAME          = L_FILENAME
      PATH              = L_PATH
      FULLPATH          = L_FULLPATH
      USER_ACTION       = L_ACTION
    EXCEPTIONS
      CNTL_ERROR        = 1
      ERROR_NO_GUI      = 2
      OTHERS            = 3.
*++FI20070222
  IF SY-SUBRC <> 0.
    P_ERROR = 'X' .
  ENDIF.
*--FI20070222
  CHECK SY-SUBRC = 0.

  MOVE L_FULLPATH TO L_DEF_FILENAME.
*-- BG 2006.04.20


*  DATA: L_MASK(20)   TYPE C VALUE ',*.XLS  ,*.xls.'.


*  CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING
*                DEF_FILENAME     =  L_DEF_FILENAME
**                def_path         =  L_DEF_FILENAME
*                MASK             =  L_MASK
*                MODE             = 'S'
*                TITLE            =  SY-TITLE
*     IMPORTING  FILENAME         =  L_FILENAME
**                RC               =  l_rc
*     EXCEPTIONS INV_WINSYS       =  04
*                NO_BATCH         =  08
*                SELECTION_CANCEL =  12
*                SELECTION_ERROR  =  16.
* -- CST 2006.05.27

  MOVE L_FILENAME TO L_FILENAME_DOWN.

*++S4HANA#01.
*  CALL FUNCTION 'DOWNLOAD'
*    EXPORTING
*      FILENAME                = L_FILENAME_DOWN
*      FILETYPE                = 'DAT'
**++ BG 2006/03/30
*      ITEM                    = 'Transfer posting accounting upload'(004)
**-- BG 2006/03/30
**     FILEMASK_ALL            = 'X'
*      FILETYPE_NO_CHANGE      = 'X'
*      FILETYPE_NO_SHOW        = 'X'
*    IMPORTING
*      CANCEL                  = L_CANCEL
*    TABLES
*      DATA_TAB                = I_EXCEL[]
*      FIELDNAMES              = I_FIELDS
*    EXCEPTIONS
*      INVALID_FILESIZE        = 1
*      INVALID_TABLE_WIDTH     = 2
*      INVALID_TYPE            = 3
*      NO_BATCH                = 4
*      UNKNOWN_ERROR           = 5
*      GUI_REFUSE_FILETRANSFER = 6
*      CUSTOMER_ERROR          = 7
*      OTHERS                  = 8.
  LV_DEFAULT_FILENAME = L_FILENAME_DOWN.
  CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
    EXPORTING
      FULL_NAME     = LV_DEFAULT_FILENAME
    IMPORTING
      STRIPPED_NAME = LV_FILENAME
      FILE_PATH     = LV_PATH
    EXCEPTIONS
      X_ERROR       = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  LV_WINDOW_TITLE = 'Átvezetés könyvelési feladás'(004).
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_WINDOW_TITLE
      DEFAULT_FILE_NAME = LV_FILENAME
      INITIAL_DIRECTORY = LV_PATH
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
      USER_ACTION       = LV_USER_ACTION.
  CHECK LV_USER_ACTION EQ 0.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME   = LV_FULLPATH
      FILETYPE   = 'DAT'
      FIELDNAMES = I_FIELDS[]
    CHANGING
      DATA_TAB   = I_EXCEL[]
    EXCEPTIONS
      OTHERS     = 1.
*--S4HANA#01.

  IF SY-SUBRC <> 0 OR L_CANCEL = 'X' OR L_CANCEL = 'x'.
    P_ERROR = 'X'.
  ENDIF.
ENDFORM.                    " download_file
*&---------------------------------------------------------------------*
*&      Form  convert_bevallo_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_LINES  text
*      -->P_I_BUKRS  text
*----------------------------------------------------------------------*
FORM CONVERT_BEVALLO_LINES TABLES   T_BEVALLO STRUCTURE /ZAK/BEVALLO
                                    I_LINES   STRUCTURE /ZAK/ATVEZ_SOR
*++S4HANA#01.
*                           USING    P_BUKRS.
                           USING    P_BUKRS TYPE BUKRS..
*--S4HANA#01.

*++S4HANA#01.
*  DATA: BEGIN OF I_LINES_TMP OCCURS 0,
*          SOR(2)    TYPE N,
*          OSZLOP(8) TYPE C,
*          ABEVAZ    TYPE /ZAK/ABEVAZ,
*          FIELD_N   TYPE /ZAK/FIELDN,
*          FIELD_C   TYPE /ZAK/FIELDC,
*        END OF I_LINES_TMP.
  TYPES: BEGIN OF TS_I_LINES_TMP ,
           SOR     TYPE N LENGTH 2,
           OSZLOP  TYPE C LENGTH 8,
           ABEVAZ  TYPE /ZAK/ABEVAZ,
           FIELD_N TYPE /ZAK/FIELDN,
           FIELD_C TYPE /ZAK/FIELDC,
         END OF TS_I_LINES_TMP .
  TYPES TT_I_LINES_TMP TYPE STANDARD TABLE OF TS_I_LINES_TMP .
  DATA: LS_I_LINES_TMP TYPE TS_I_LINES_TMP.
  DATA: LT_I_LINES_TMP TYPE TT_I_LINES_TMP.
*--S4HANA#01.


  LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO.

* Load form data for ABEV
    CLEAR W_/ZAK/BEVALLB.
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_/ZAK/BEVALLO-BTYPE
                ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE  = W_/ZAK/BEVALLO-BTYPE
          AND   ABEVAZ = W_/ZAK/BEVALLO-ABEVAZ.
      INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
    ENDIF.


*++S4HANA#01.
*    I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
*    I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
*    I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
*    I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
*    I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.
*
*    CHECK I_LINES_TMP-SOR NE '00' OR
*          I_LINES_TMP-SOR NE SPACE.
*    APPEND I_LINES_TMP.
    LS_I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
    LS_I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
    LS_I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
    LS_I_LINES_TMP-FIELD_N = W_/ZAK/BEVALLO-FIELD_N.
    LS_I_LINES_TMP-FIELD_C = W_/ZAK/BEVALLO-FIELD_C.

    CHECK LS_I_LINES_TMP-SOR NE '00' OR
          LS_I_LINES_TMP-SOR NE SPACE.
    APPEND LS_I_LINES_TMP TO LT_I_LINES_TMP.
*--S4HANA#01.


  ENDLOOP.

*++S4HANA#01.
*  SORT I_LINES_TMP.
*
*  LOOP AT I_LINES_TMP.
  SORT LT_I_LINES_TMP.

  LOOP AT LT_I_LINES_TMP INTO LS_I_LINES_TMP.
*--S4HANA#01.

    AT NEW SOR.
      CLEAR I_LINES.
    ENDAT.

*++S4HANA#01.
*    CASE I_LINES_TMP-OSZLOP.
*      WHEN 'A'.
*        I_LINES-ADONEM_SRC = I_LINES_TMP-FIELD_C.
*      WHEN 'C'.
*        I_LINES-WRBTR_SRC = I_LINES_TMP-FIELD_N.
*      WHEN 'D'.
*        I_LINES-ADONEM_DES = I_LINES_TMP-FIELD_C.
*      WHEN 'F'.
*        I_LINES-WRBTR_DES = I_LINES_TMP-FIELD_N.
*      WHEN 'G'.
*        I_LINES-WRBTR_UTAL = I_LINES_TMP-FIELD_N.
*    ENDCASE.
    CASE LS_I_LINES_TMP-OSZLOP.
      WHEN 'A'.
        I_LINES-ADONEM_SRC = LS_I_LINES_TMP-FIELD_C.
      WHEN 'C'.
        I_LINES-WRBTR_SRC = LS_I_LINES_TMP-FIELD_N.
      WHEN 'D'.
        I_LINES-ADONEM_DES = LS_I_LINES_TMP-FIELD_C.
      WHEN 'F'.
        I_LINES-WRBTR_DES = LS_I_LINES_TMP-FIELD_N.
      WHEN 'G'.
        I_LINES-WRBTR_UTAL = LS_I_LINES_TMP-FIELD_N.
    ENDCASE.
*--S4HANA#01.

    I_LINES-WAERS_SRC  = W_/ZAK/BEVALLO-WAERS.
    I_LINES-WAERS_DES  = W_/ZAK/BEVALLO-WAERS.
    I_LINES-WAERS_UTAL = W_/ZAK/BEVALLO-WAERS.

    PERFORM FILL_TEXTS  USING W_/ZAK/BEVALLO-BUKRS
                        CHANGING I_LINES.

    AT END OF SOR.
      APPEND I_LINES.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " convert_bevallo_lines
*&---------------------------------------------------------------------*
*&      Form  update_adonsza
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_LINES  text
*      -->P_I_BUKRS  text
*      -->P_I_BTYPE  text
*      -->P_I_GJAHR  text
*      -->P_I_MONAT  text
*      -->P_I_INDEX  text
*      <--P_V_ERROR  text
*----------------------------------------------------------------------*
FORM UPDATE_ADONSZA TABLES   I_LINES STRUCTURE /ZAK/ATVEZ_SOR
*++S4HANA#01.
*                    USING    P_BUKRS
*                             P_BTYPE
*                             P_GJAHR
*                             P_MONAT
*                             P_INDEX
*                    CHANGING P_ERROR.
                    USING    P_BUKRS TYPE BUKRS
                             P_BTYPE TYPE /ZAK/BTYPE
                             P_GJAHR TYPE GJAHR
                             P_MONAT TYPE MONAT
                             P_INDEX TYPE /ZAK/INDEX
                    CHANGING P_ERROR TYPE CLIKE.
*--S4HANA#01.


  LOOP AT I_LINES.
    CHECK I_LINES-WRBTR_DES > 0.

* Source tax code
    CLEAR W_/ZAK/ADONSZA.
    PERFORM GET_NUMBER USING    P_BUKRS
                       CHANGING W_/ZAK/ADONSZA-BELNR
                                P_ERROR.
    CHECK P_ERROR = SPACE.

    W_/ZAK/ADONSZA-BUKRS  = P_BUKRS.
    W_/ZAK/ADONSZA-GJAHR  = P_GJAHR.
    W_/ZAK/ADONSZA-ADONEM = I_LINES-ADONEM_SRC.
    W_/ZAK/ADONSZA-BTYPE  = P_BTYPE.
    W_/ZAK/ADONSZA-MONAT  = P_MONAT.
    W_/ZAK/ADONSZA-ZINDEX = P_INDEX.
*++BG 2006/11/22, 2007/08/31
    W_/ZAK/ADONSZA-KOTEL  = C_KOTEL_K.
*   W_/ZAK/ADONSZA-KOTEL  = C_KOTEL_T.
*--BG 2006/11/22, 2007/08/31
    W_/ZAK/ADONSZA-ESDAT  = SY-DATUM.

*++BG 2007/09/07
*   W_/ZAK/ADONSZA-WRBTR =  I_LINES-WRBTR_SRC * ( -1 ).
    W_/ZAK/ADONSZA-WRBTR =  I_LINES-WRBTR_SRC.
*--BG 2007/09/07

    W_/ZAK/ADONSZA-WAERS =  I_LINES-WAERS_SRC.

    W_/ZAK/ADONSZA-DATUM =  SY-DATUM.
    W_/ZAK/ADONSZA-UZEIT =  SY-UZEIT.
    W_/ZAK/ADONSZA-UNAME =  SY-UNAME.
    INSERT INTO /ZAK/ADONSZA VALUES W_/ZAK/ADONSZA.
    IF SY-SUBRC NE 0.
      P_ERROR = 'X'.
      EXIT.
    ENDIF.


    CHECK P_ERROR = SPACE.

* Target tax code
    CLEAR W_/ZAK/ADONSZA.
    PERFORM GET_NUMBER USING    P_BUKRS
                       CHANGING W_/ZAK/ADONSZA-BELNR
                                P_ERROR.
    CHECK P_ERROR = SPACE.

    W_/ZAK/ADONSZA-BUKRS  = P_BUKRS.
    W_/ZAK/ADONSZA-GJAHR  = P_GJAHR.
    W_/ZAK/ADONSZA-ADONEM = I_LINES-ADONEM_DES.
    W_/ZAK/ADONSZA-BTYPE  = P_BTYPE.
    W_/ZAK/ADONSZA-MONAT  = P_MONAT.
    W_/ZAK/ADONSZA-ZINDEX = P_INDEX.
*++BG 2006/11/22, 2007/08/31
    W_/ZAK/ADONSZA-KOTEL  = C_KOTEL_K.
*   W_/ZAK/ADONSZA-KOTEL  = C_KOTEL_T.
*--BG 2006/11/22, 2007/08/31
    W_/ZAK/ADONSZA-ESDAT  = SY-DATUM.

*++BG 2007/09/07
*   W_/ZAK/ADONSZA-WRBTR =  I_LINES-WRBTR_DES.
    W_/ZAK/ADONSZA-WRBTR =  I_LINES-WRBTR_DES * ( -1 ).
*--BG 2007/09/07


    W_/ZAK/ADONSZA-WAERS =  I_LINES-WAERS_DES.

    W_/ZAK/ADONSZA-DATUM =  SY-DATUM.
    W_/ZAK/ADONSZA-UZEIT =  SY-UZEIT.
    W_/ZAK/ADONSZA-UNAME =  SY-UNAME.
    INSERT INTO /ZAK/ADONSZA VALUES W_/ZAK/ADONSZA.
    IF SY-SUBRC NE 0.
      P_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF P_ERROR = SPACE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    " update_adonsza
*&---------------------------------------------------------------------*
*&      Form  get_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      <--P_W_/ZAK/ADONSZA_BELNR  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_NUMBER USING    P_BUKRS
*                CHANGING P_BELNR
*                         P_ERROR.
FORM GET_NUMBER USING    P_BUKRS TYPE BUKRS
                CHANGING P_BELNR TYPE /ZAK/ADONSZA-BELNR
                         P_ERROR TYPE CLIKE.
*--S4HANA#01.
  CLEAR P_BELNR.

* Document number range
  CALL FUNCTION '/ZAK/NEW_BELNR'
    EXPORTING
      I_BUKRS          = P_BUKRS
    IMPORTING
      E_BELNR          = P_BELNR
    EXCEPTIONS
      ERROR_GET_NUMBER = 1
      OTHERS           = 2.

  IF SY-SUBRC <> 0.
    P_ERROR = 'X'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ENDIF.

ENDFORM.                    " get_number
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_EXCEL  text
*----------------------------------------------------------------------*
FORM GET_DATA_ONELL_V2 TABLES   $BEVALLO STRUCTURE /ZAK/BEVALLO
                             $EXCEL_T   STRUCTURE /ZAK/SZJAEXCELV2
                    USING    $W_BEVALLO STRUCTURE /ZAK/BEVALLO
*++S4HANA#01.
*                             $SUBRC.
                             $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

*Define ranges to collect field names
  RANGES R_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.
  DATA   L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA   L_FIELD_NRK TYPE WERTV9.
  DATA   L_DATUM LIKE SY-DATUM.
  DATA:  $EXCEL1 TYPE /ZAK/SZJAEXCELV2
        ,$EXCEL2 TYPE /ZAK/SZJAEXCELV2
        .
*Define a macro to fill the ranges
*  DEFINE M_DEF.
*    MOVE: 'I'     TO &1-SIGN,
*          'EQ'    TO &1-OPTION,
*          &2      TO &1-LOW.
*    APPEND &1.
*  END-OF-DEFINITION.

*++BG 2007.04.23
  RANGES R_ONELL_ADONEM FOR /ZAK/ADONEM-ADONEM.
  DATA L_ADONEM TYPE /ZAK/ADON.
*--BG 2007.04.23


  CLEAR $SUBRC.


*++BG 2007.04.23 Self-audit tax codes in /ZAK/ADONEM
*table flagged by the ONREL field:
*++S4HANA#01.
*  REFRESH R_ONELL_ADONEM.
  CLEAR R_ONELL_ADONEM[].
*--S4HANA#01.

  SELECT ADONEM INTO L_ADONEM
                FROM /ZAK/ADONEM
               WHERE BUKRS EQ $W_BEVALLO-BUKRS
                 AND ONREL EQ 'X'.
    M_DEF R_ONELL_ADONEM 'I' 'EQ' L_ADONEM SPACE.
  ENDSELECT.

  CHECK SY-SUBRC EQ 0.
*--BG 2007.04.23


* Determine the self-audit surcharge ABEV identifier(s).
  SELECT ABEVAZ INTO L_ABEVAZ
                FROM /ZAK/BEVALLB
               WHERE BTYPE   EQ $W_BEVALLO-BTYPE

*++BG 2007.04.23
*                AND ADONEM  EQ C_ONELL_ADONEM.
*++BG 2008.03.11
*Tax codes must be looked up among the self-audit tax codes
*                AND ADONEM  IN R_ONELL_ADONEM.
                 AND ADONEM_ONR IN R_ONELL_ADONEM.
*--BG 2008.03.11
*--BG 2007.04.23


    M_DEF R_ABEVAZ 'I' 'EQ' L_ABEVAZ SPACE.
  ENDSELECT.

* Ha van ABEVAZ
  CHECK NOT R_ABEVAZ IS INITIAL.

  CLEAR L_FIELD_NRK.
* Sum the FIELD_NR fields.
  LOOP AT $BEVALLO WHERE ABEVAZ IN R_ABEVAZ.
    ADD $BEVALLO-FIELD_NRK TO L_FIELD_NRK.
  ENDLOOP.

* If there is an amount, assemble the posting data
  CHECK NOT L_FIELD_NRK IS INITIAL.

* Read the settings
  SELECT SINGLE * INTO W_/ZAK/ONELL_BOOK
                  FROM /ZAK/ONELL_BOOK
                 WHERE BUKRS EQ $W_BEVALLO-BUKRS.
  IF SY-SUBRC NE 0.
    MOVE 4 TO $SUBRC.
  ENDIF.
ENHANCEMENT-POINT /ZAK/ZAK_TELEKOM_ONELL_01 SPOTS /ZAK/FUNCTIONS_ES .

* Populate the posting file
  CLEAR: $EXCEL1,$EXCEL2.
*++BG 2006/07/19
* Document date.
*  MOVE $W_BEVALLO-GJAHR TO L_DATUM(4).
*  MOVE $W_BEVALLO-MONAT TO L_DATUM+4(2).

* Changed (Lehel Attila): use the last day of the submission month
  MOVE SY-DATUM(4)   TO  L_DATUM(4).
  MOVE SY-DATUM+4(2) TO L_DATUM+4(2).
*--BG 2006/07/19

  MOVE '01' TO L_DATUM+6(2).
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = L_DATUM
    IMPORTING
      LAST_DAY_OF_MONTH = L_DATUM.

  WRITE L_DATUM TO $EXCEL1-BIZ_DATUM.
  WRITE L_DATUM TO $EXCEL2-BIZ_DATUM.

  $EXCEL1-BIZ_AZON = '1'.
  $EXCEL2-BIZ_AZON = '1'.
  $EXCEL1-BIZ_TETEL = '1'.
  $EXCEL2-BIZ_TETEL = '2'.
  $EXCEL1-KK = '40'.
  $EXCEL2-KK = '50'.

  $EXCEL1-PENZNEM = $BEVALLO-WAERS.
  $EXCEL2-PENZNEM = $BEVALLO-WAERS.



* Document type
  MOVE W_/ZAK/ONELL_BOOK-BLART TO $EXCEL1-BF.
  MOVE W_/ZAK/ONELL_BOOK-BLART TO $EXCEL2-BF.
* Company

*  MOVE $W_BEVALLO-BUKRS TO $EXCEL-VALL.
* Posting date
  WRITE L_DATUM TO  $EXCEL1-KONYV_DAT.
  WRITE L_DATUM TO  $EXCEL2-KONYV_DAT.
* Month
*  MOVE $W_BEVALLO-MONAT TO $EXCEL1-HO.
*  MOVE $W_BEVALLO-MONAT TO $EXCEL2-HO.
  MOVE L_DATUM+4(2) TO $EXCEL1-HO.
  MOVE L_DATUM+4(2) TO $EXCEL2-HO.

* Header text
*++BG 2006/08/31
* Filled based on the document date (Lehel Attila)
  CONCATENATE
*              $W_BEVALLO-GJAHR
*              $W_BEVALLO-MONAT
               $EXCEL1-BIZ_DATUM(4)
               $EXCEL1-BIZ_DATUM+5(2)
              'Önell.pótl.'(001)
         INTO $EXCEL1-FEJSZOVEG
              SEPARATED BY SPACE.
  $EXCEL2-FEJSZOVEG = $EXCEL1-FEJSZOVEG.
*--BG 2006/08/31

* Account 1 (debit)
  MOVE W_/ZAK/ONELL_BOOK-SZAMLA1 TO $EXCEL1-FOKONYV.
* Amount.
*++BG 2006/07/19
* The currency was not read into the work area, therefore divide by 100
* hozta.
* WRITE L_FIELD_NRK CURRENCY $W_BEVALLO-WAERS TO $EXCEL-FORINT
  WRITE L_FIELD_NRK CURRENCY $BEVALLO-WAERS  TO $EXCEL1-OSSZEG
                             NO-GROUPING
                             NO-SIGN.
  $EXCEL2-OSSZEG = $EXCEL1-OSSZEG.
*--BG 2006/07/19
* Account 2 (credit)
  MOVE W_/ZAK/ONELL_BOOK-SZAMLA2 TO $EXCEL2-FOKONYV.
* Profitcenter
  MOVE W_/ZAK/ONELL_BOOK-PRCTR   TO $EXCEL1-PRCTR .
  MOVE W_/ZAK/ONELL_BOOK-GSBER   TO $EXCEL2-UZLETAG .
*++BG 2007/08/02
* Assign the order to the line on which
* a profitcenter van.
* MOVE W_/ZAK/ONELL_BOOK-AUFNR   TO $EXCEL2-RENDELES .
  MOVE W_/ZAK/ONELL_BOOK-AUFNR   TO $EXCEL1-RENDELES .
*--BG 2007/08/02

*++BG 2008/02/22
* Fill the cost center
  MOVE W_/ZAK/ONELL_BOOK-KOSTL   TO $EXCEL1-KTGH.
*--BG 2008/02/22

* Text
  MOVE $EXCEL1-FEJSZOVEG  TO $EXCEL1-SZOVEG .
  MOVE $EXCEL2-FEJSZOVEG  TO $EXCEL2-SZOVEG .
* Save rows
  APPEND $EXCEL1 TO $EXCEL_T.
  APPEND $EXCEL2 TO $EXCEL_T.

ENDFORM.                    " get_data_v2
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_EXCEL  text
*----------------------------------------------------------------------*
FORM GET_DATA_ONELL TABLES   $BEVALLO STRUCTURE /ZAK/BEVALLO
                             $EXCEL   STRUCTURE /ZAK/SZJA_EXCEL
                    USING    $W_BEVALLO STRUCTURE /ZAK/BEVALLO
                             $SUBRC.

*Define ranges to collect field names
  RANGES R_ABEVAZ FOR /ZAK/BEVALLB-ABEVAZ.
  DATA   L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA   L_FIELD_NRK TYPE WERTV9.
  DATA   L_DATUM LIKE SY-DATUM.

*Define a macro to fill the ranges
*  DEFINE M_DEF.
*    MOVE: 'I'     TO &1-SIGN,
*          'EQ'    TO &1-OPTION,
*          &2      TO &1-LOW.
*    APPEND &1.
*  END-OF-DEFINITION.

  CLEAR $SUBRC.


* Determine the self-audit surcharge ABEV identifier(s).
  SELECT ABEVAZ INTO L_ABEVAZ
                FROM /ZAK/BEVALLB
               WHERE BTYPE   EQ $W_BEVALLO-BTYPE
                 AND ADONEM  EQ C_ONELL_ADONEM.

    M_DEF R_ABEVAZ 'I' 'EQ' L_ABEVAZ SPACE.
  ENDSELECT.

* Ha van ABEVAZ
  CHECK NOT R_ABEVAZ IS INITIAL.

  CLEAR L_FIELD_NRK.
* Sum the FIELD_NR fields.
  LOOP AT $BEVALLO WHERE ABEVAZ IN R_ABEVAZ.
    ADD $BEVALLO-FIELD_NRK TO L_FIELD_NRK.
  ENDLOOP.

* If there is an amount, assemble the posting data
  CHECK NOT L_FIELD_NRK IS INITIAL.

* Read the settings
  SELECT SINGLE * INTO W_/ZAK/ONELL_BOOK
                  FROM /ZAK/ONELL_BOOK
                 WHERE BUKRS EQ $W_BEVALLO-BUKRS.
  IF SY-SUBRC NE 0.
    MOVE 4 TO $SUBRC.
  ENDIF.

* Populate the posting file
  CLEAR $EXCEL.
*++BG 2006/07/19
* Document date.
*  MOVE $W_BEVALLO-GJAHR TO L_DATUM(4).
*  MOVE $W_BEVALLO-MONAT TO L_DATUM+4(2).

* Changed (Lehel Attila): use the last day of the submission month
  MOVE SY-DATUM(4)   TO  L_DATUM(4).
  MOVE SY-DATUM+4(2) TO L_DATUM+4(2).
*--BG 2006/07/19

  MOVE '01' TO L_DATUM+6(2).
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = L_DATUM
    IMPORTING
      LAST_DAY_OF_MONTH = L_DATUM.
  MOVE L_DATUM TO $EXCEL-BIZ_DATUM.
* Document type
  MOVE W_/ZAK/ONELL_BOOK-BLART TO $EXCEL-BF.
* Company

  MOVE $W_BEVALLO-BUKRS TO $EXCEL-VALL.
* Posting date
  MOVE L_DATUM TO  $EXCEL-KONYV_DAT.
* Month
  MOVE $W_BEVALLO-MONAT TO $EXCEL-HO.

* Header text
*++BG 2006/08/31
* Filled based on the document date (Lehel Attila)
  CONCATENATE
*              $W_BEVALLO-GJAHR
*              $W_BEVALLO-MONAT
               $EXCEL-BIZ_DATUM(4)
               $EXCEL-BIZ_DATUM+5(2)
              'Önell.pótl.'(001)
         INTO $EXCEL-FEJSZOVEG
              SEPARATED BY SPACE.
*--BG 2006/08/31

* Account 1 (debit)
  MOVE W_/ZAK/ONELL_BOOK-SZAMLA1 TO $EXCEL-SZAMLA1.
* Amount.
*++BG 2006/07/19
* The currency was not read into the work area, therefore divide by 100
* hozta.
* WRITE L_FIELD_NRK CURRENCY $W_BEVALLO-WAERS TO $EXCEL-FORINT
  WRITE L_FIELD_NRK CURRENCY $BEVALLO-WAERS  TO $EXCEL-FORINT
                             NO-GROUPING
                             NO-SIGN.
*--BG 2006/07/19
* Account 2 (credit)
  MOVE W_/ZAK/ONELL_BOOK-SZAMLA2 TO $EXCEL-SZAMLA2.
* Profitcenter
  MOVE W_/ZAK/ONELL_BOOK-PRCTR   TO $EXCEL-PRCTR1.
* Text
* ++ FI 20070111
*  MOVE $EXCEL-FEJSZOVEG  TO $EXCEL-SZOVEG.
  MOVE $EXCEL-FEJSZOVEG  TO $EXCEL-SZOVEG1.
* -- FI 20070111
  APPEND $EXCEL.

ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE_ONELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EXCEL  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE_ONELL TABLES   $I_EXCEL STRUCTURE /ZAK/SZJAEXCELV2
                         USING    $W_BEVALLO STRUCTURE /ZAK/BEVALLO
*++S4HANA#01.
*                                  $SUBRC.
                                  $SUBRC TYPE SY-SUBRC..
*--S4HANA#01.

  DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
        L_CANCEL(1).

  DATA: BEGIN OF LI_FIELDS OCCURS 10,
          NAME(40),
        END OF LI_FIELDS.

  DATA: LI_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
  DATA: LI_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

*++ BG 2006.04.20
  DATA:
    L_FILENAME TYPE STRING,
    L_FILTER   TYPE STRING,
    L_PATH     TYPE STRING,
    L_FULLPATH TYPE STRING,
    L_ACTION   TYPE I.

  DATA:  L_FILENAME_DOWN LIKE RLGRAP-FILENAME.
* DATA:  L_RC.

*-- BG 2006.04.20
*++S4HANA#01.
  DATA LV_FILENAME TYPE STRING.
  DATA LV_PATH TYPE STRING.
  DATA LV_DEFAULT_FILENAME TYPE STRING.
  DATA LV_FULLPATH TYPE STRING.
  DATA LV_USER_ACTION TYPE I.
  DATA LV_RC TYPE I.
  DATA LV_WINDOW_TITLE TYPE STRING.
*--S4HANA#01.

  CLEAR $SUBRC.

  CHECK NOT $I_EXCEL[] IS INITIAL.

* Determine the file name
*++BG 2007.05.17
*  CONCATENATE $W_BEVALLO-BUKRS $W_BEVALLO-BTYPE TEXT-002
*         INTO L_DEF_FILENAME SEPARATED BY '_'.
  CONCATENATE $W_BEVALLO-BUKRS
              $W_BEVALLO-BTYPE
              $W_BEVALLO-GJAHR
              $W_BEVALLO-MONAT
              $W_BEVALLO-ZINDEX
              TEXT-002
         INTO L_DEF_FILENAME SEPARATED BY '_'.
*--BG 2007.05.17


  CONCATENATE L_DEF_FILENAME '.XLS' INTO L_DEF_FILENAME.

* Read the data structure
  CALL FUNCTION 'DD_GET_DD03P_ALL'
    EXPORTING
      DEFSTATUS     = 'A'
      LANGU         = SY-LANGU
      TABNAME       = '/ZAK/SZJAEXCELV2'
    TABLES
      A_DD03P_TAB   = LI_DD03P
      N_DD03P_TAB   = LI_DD03P_2
    EXCEPTIONS
      ILLEGAL_VALUE = 1
      OTHERS        = 2.

  IF SY-SUBRC = 0.
    LOOP AT LI_DD03P WHERE FIELDNAME <> '.INCLUDE'.
      MOVE LI_DD03P-REPTEXT TO LI_FIELDS-NAME.
      APPEND LI_FIELDS.
    ENDLOOP.
  ENDIF.

*++ BG 2006.04.20 Path determination
  MOVE L_DEF_FILENAME TO L_FILENAME.

*++0001 2007.01.03 BG (FMC)
* ++ CST 2006.05.27
*
  L_FILTER = '*.XLS'.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
*     WINDOW_TITLE      =
*     DEFAULT_EXTENSION = '*.*'
      DEFAULT_FILE_NAME = L_FILENAME
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    CHANGING
      FILENAME          = L_FILENAME
      PATH              = L_PATH
      FULLPATH          = L_FULLPATH
      USER_ACTION       = L_ACTION
    EXCEPTIONS
      CNTL_ERROR        = 1
      ERROR_NO_GUI      = 2
      OTHERS            = 3.

  CHECK SY-SUBRC = 0.

* MOVE L_FULLPATH TO L_DEF_FILENAME.
*-- BG 2006.04.20

*  DATA: L_MASK(20)   TYPE C VALUE ',*.XLS  ,*.xls.'.
*
*  L_FILTER = '*.XLS'.
*
*  CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING
*                DEF_FILENAME     =  L_DEF_FILENAME
**                def_path         =  L_DEF_FILENAME
*                MASK             =  L_MASK
*                MODE             = 'S'
*                TITLE            =  SY-TITLE
*     IMPORTING  FILENAME         =  L_FILENAME
**                RC               =  l_rc
*     EXCEPTIONS INV_WINSYS       =  04
*                NO_BATCH         =  08
*                SELECTION_CANCEL =  12
*                SELECTION_ERROR  =  16.
* -- CST 2006.05.27

*++ BG 2007.05.17
*  MOVE  L_FILENAME TO L_FILENAME_DOWN.
  MOVE  L_FULLPATH TO L_FILENAME_DOWN.
*--BG 2007.05.17

*++S4HANA#01.
*  CALL FUNCTION 'DOWNLOAD'
*    EXPORTING
**++BG 2006/06/23
**     FILENAME                = L_DEF_FILENAME
*      FILENAME                = L_FILENAME_DOWN
**--BG 2006/06/23
*      FILETYPE                = 'DAT'
*      ITEM                    = 'Self-audit surcharge'(003)
*      FILETYPE_NO_CHANGE      = 'X'
*      FILETYPE_NO_SHOW        = 'X'
*    IMPORTING
*      CANCEL                  = L_CANCEL
*    TABLES
*      DATA_TAB                = $I_EXCEL[]
*      FIELDNAMES              = LI_FIELDS
*    EXCEPTIONS
*      INVALID_FILESIZE        = 1
*      INVALID_TABLE_WIDTH     = 2
*      INVALID_TYPE            = 3
*      NO_BATCH                = 4
*      UNKNOWN_ERROR           = 5
*      GUI_REFUSE_FILETRANSFER = 6
*      CUSTOMER_ERROR          = 7
*      OTHERS                  = 8.
  LV_DEFAULT_FILENAME = L_FILENAME_DOWN.
  CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
    EXPORTING
      FULL_NAME     = LV_DEFAULT_FILENAME
    IMPORTING
      STRIPPED_NAME = LV_FILENAME
      FILE_PATH     = LV_PATH
    EXCEPTIONS
      X_ERROR       = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  LV_WINDOW_TITLE = 'Önellenőrzési pótlék'(003).
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_WINDOW_TITLE
      DEFAULT_FILE_NAME = LV_FILENAME
      INITIAL_DIRECTORY = LV_PATH
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
      USER_ACTION       = LV_USER_ACTION.
  CHECK LV_USER_ACTION EQ 0.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME   = LV_FULLPATH
      FILETYPE   = 'DAT'
      FIELDNAMES = LI_FIELDS[]
    CHANGING
      DATA_TAB   = $I_EXCEL[]
    EXCEPTIONS
      OTHERS     = 1.
*--S4HANA#01.

  IF SY-SUBRC <> 0 OR L_CANCEL = 'X' OR L_CANCEL = 'x'.
    MOVE 4 TO $SUBRC.
  ENDIF.


ENDFORM.                    " DOWNLOAD_FILE_ONELL
*&---------------------------------------------------------------------*
*&      Form  CONVERT_BEVALLO_ADONSZA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO  text
*      -->P_I_/ZAK/ADONSZA  text
*----------------------------------------------------------------------*
FORM CONVERT_BEVALLO_ADONSZA TABLES  $I_BEVALLO STRUCTURE /ZAK/BEVALLO
*++0001 BG 2008.05.05 /ZAK/POST_ADONSZA
                                     $I_ADONSZA STRUCTURE /ZAK/ADONSZA
*--0001 BG 2008.05.05 /ZAK/POST_ADONSZA
                                     $I_BEVALLB STRUCTURE /ZAK/BEVALLB
                                     $R_ATV_BTYPE STRUCTURE RANGE_C10
*++S4HANA#01.
*                             USING   $BUKRS
*                                     $BTYPE
*                                     $GJAHR
*                                     $MONAT
*                                     $INDEX
**++0001 BG 2008.05.05 /ZAK/POST_ADONSZA
*                                     $TESZT
**--0001 BG 2008.05.05 /ZAK/POST_ADONSZA
*                                     $BTYPE_CONV
*                                     $SUBRC.
                             USING   $BUKRS TYPE BUKRS
                                     $BTYPE TYPE /ZAK/BTYPE
                                     $GJAHR TYPE GJAHR
                                     $MONAT TYPE MONAT
                                     $INDEX TYPE /ZAK/INDEX
                                     $TESZT TYPE XFELD
                                     $BTYPE_CONV TYPE /ZAK/BEVALL-BTYPE
                                     $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

  DATA L_ESDAT   LIKE /ZAK/ADONSZA-ESDAT.
  DATA L_ERROR.
  DATA L_BTYPE LIKE /ZAK/BEVALL-BTYPE.
*++S4HANA#01.
*  DATA LW_BEVALL LIKE /ZAK/BEVALL.
  TYPES: BEGIN OF TS_LW_BEVALL_SEL,
           BTYPART TYPE /ZAK/BEVALL-BTYPART,
         END OF TS_LW_BEVALL_SEL.
  DATA LW_BEVALL TYPE TS_LW_BEVALL_SEL.
*--S4HANA#01.
  DATA L_DATE LIKE SY-DATUM.
*++S4HANA#01.
*  DATA LI_LAST_BEVALLO LIKE /ZAK/BEVALLO OCCURS 0 WITH HEADER LINE.
  TYPES: TT_LI_LAST_BEVALLO TYPE STANDARD TABLE OF /ZAK/BEVALLO .
  DATA: LT_LI_LAST_BEVALLO TYPE TT_LI_LAST_BEVALLO.
  DATA: LS_LI_LAST_BEVALLO TYPE /ZAK/BEVALLO.
*--S4HANA#01.
  DATA L_LAST_INDEX TYPE /ZAK/INDEX.
*++BG 2008.03.26
* Collect tax codes: for VAT which tax code had the
* difference aggregation
*++S4HANA#01.
*  RANGES LR_ADONEM FOR /ZAK/BEVALLB-ADONEM.
  TYPES TT_ADONEM TYPE RANGE OF /ZAK/BEVALLB-ADONEM.
  DATA LT_ADONEM TYPE TT_ADONEM.
  DATA LS_ADONEM TYPE LINE OF TT_ADONEM.
*--S4HANA#01.

*++S4HANA#01.
*  DATA: BEGIN OF LI_ABEV_ADON OCCURS 0,
*          ABEVAZ TYPE /ZAK/ABEVAZ,
*          ADONEM TYPE /ZAK/ADON,
*        END OF LI_ABEV_ADON.
  TYPES: BEGIN OF TS_LI_ABEV_ADON ,
           ABEVAZ TYPE /ZAK/ABEVAZ,
           ADONEM TYPE /ZAK/ADON,
         END OF TS_LI_ABEV_ADON .
  TYPES TT_LI_ABEV_ADON TYPE STANDARD TABLE OF TS_LI_ABEV_ADON .
  DATA: LS_LI_ABEV_ADON TYPE TS_LI_ABEV_ADON.
  DATA: LT_LI_ABEV_ADON TYPE TT_LI_ABEV_ADON.
*--S4HANA#01.
*--BG 2008.03.26

*Define a macro to fill the ranges
*  DEFINE M_DEF.
*    MOVE: 'I'     TO &1-SIGN,
*          'EQ'    TO &1-OPTION,
*          &2      TO &1-LOW.
*    APPEND &1.
*  END-OF-DEFINITION.


  CLEAR: $SUBRC, $BTYPE_CONV.

  SORT: $I_BEVALLO, $I_BEVALLB.

* Last day of the month
  CONCATENATE $GJAHR $MONAT '01' INTO L_DATE.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = L_DATE
    IMPORTING
      LAST_DAY_OF_MONTH = L_DATE.


* Determine the return type
*++S4HANA#01.
*  SELECT SINGLE * INTO LW_BEVALL
*                  FROM /ZAK/BEVALL
*                 WHERE BUKRS EQ $BUKRS
*                   AND BTYPE EQ $BTYPE
*                   AND DATBI GE L_DATE
*                   AND DATAB LE L_DATE.
  SELECT BTYPART INTO LW_BEVALL
                  FROM /ZAK/BEVALL UP TO 1 ROWS
                 WHERE BUKRS EQ $BUKRS
                   AND BTYPE EQ $BTYPE
                   AND DATBI GE L_DATE
                   AND DATAB LE L_DATE
                 ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.

* For VAT and self-audit the previous period is also required
  IF LW_BEVALL-BTYPART EQ C_BTYPART_AFA AND $INDEX NE '000'.
    L_LAST_INDEX = $INDEX - 1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = L_LAST_INDEX
      IMPORTING
        OUTPUT = L_LAST_INDEX.


*++S4HANA#01.
*    SELECT * INTO TABLE LI_LAST_BEVALLO
    SELECT * INTO TABLE LT_LI_LAST_BEVALLO
*--S4HANA#01.
                    FROM  /ZAK/BEVALLO
                   WHERE  BUKRS   EQ $BUKRS
                     AND  BTYPE   EQ $BTYPE
                     AND  GJAHR   EQ $GJAHR
                     AND  MONAT   EQ $MONAT
                     AND  ZINDEX  EQ L_LAST_INDEX.
*++S4HANA#01.
*    SORT LI_LAST_BEVALLO.
    SORT LT_LI_LAST_BEVALLO.
*--S4HANA#01.
  ENDIF.

* Determine the due date
  READ TABLE $I_BEVALLB INTO W_/ZAK/BEVALLB
                        WITH KEY BTYPE      = $BTYPE
                                 ESDAT_FLAG = 'X'.
* Determine the due date based on the ABEV field
  IF SY-SUBRC EQ 0.
*   Determine the value of the ABEV field
    READ TABLE $I_BEVALLO INTO W_/ZAK/BEVALLO
                          WITH KEY BUKRS  = $BUKRS
                                   BTYPE  = $BTYPE
                                   GJAHR  = $GJAHR
                                   MONAT  = $MONAT
                                   ZINDEX = $INDEX
                                   ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ
                                   BINARY SEARCH.
*   Once the field value is found, copy it to ESDAT
    IF SY-SUBRC EQ 0.
      CALL FUNCTION 'CONVERSION_EXIT_IDATE_INPUT'
        EXPORTING
          INPUT  = W_/ZAK/BEVALLO-FIELD_C
        IMPORTING
          OUTPUT = L_ESDAT.
    ENDIF.
  ENDIF.

* Populate transfer BTYPEs
*  REFRESH $R_ATV_BTYPE.
*
*  SELECT BTYPE INTO L_BTYPE
*               FROM /ZAK/BEVALL
*              WHERE BUKRS   EQ $BUKRS
*                AND BTYPART EQ C_BTYPART_ATV.
*    M_DEF $R_ATV_BTYPE L_BTYPE.
*  ENDSELECT.


  GET TIME.
*++BG 2008.03.26
* Process data
*++S4HANA#01.
*  REFRESH LR_ADONEM.
  CLEAR LT_ADONEM[].
*--S4HANA#01.
*--BG 2008.03.26

  LOOP AT $I_BEVALLO INTO W_/ZAK/BEVALLO WHERE NOT FIELD_NRK IS INITIAL.
*  Determine the tax code for the ABEV identifier
*++BG 2006/06/23
*    LOOP AT $I_BEVALLB INTO  W_/ZAK/BEVALLB
*                       WHERE BTYPE  EQ W_/ZAK/BEVALLO-BTYPE
*                         AND ABEVAZ EQ W_/ZAK/BEVALLO-ABEVAZ.
    READ TABLE $I_BEVALLB INTO  W_/ZAK/BEVALLB WITH KEY
                          BTYPE  =  W_/ZAK/BEVALLO-BTYPE
                          ABEVAZ =  W_/ZAK/BEVALLO-ABEVAZ
                          BINARY SEARCH.
    CHECK SY-SUBRC EQ 0.
*--BG 2006/06/23

*    For a normal period the ADONEM must be considered.
    IF $INDEX EQ '000'.
      CHECK NOT W_/ZAK/BEVALLB-ADONEM IS INITIAL.
    ELSE.
      CHECK NOT W_/ZAK/BEVALLB-ADONEM_ONR IS INITIAL.
    ENDIF.

    CLEAR: W_/ZAK/ADONEM, W_/ZAK/ADONSZA.
*     Determine tax code data
*     Normal period
    IF $INDEX EQ '000'.
*++S4HANA#01.
*      SELECT SINGLE * INTO W_/ZAK/ADONEM
      SELECT SINGLE ADONEM FIZHAT INTO CORRESPONDING FIELDS OF W_/ZAK/ADONEM
*--S4HANA#01.
                    FROM /ZAK/ADONEM
                   WHERE BUKRS  = $BUKRS
                     AND ADONEM = W_/ZAK/BEVALLB-ADONEM.
*++BG 2007.05.22
      IF SY-SUBRC NE 0.
        MESSAGE E219(/ZAK/ZAK) WITH $BUKRS W_/ZAK/BEVALLB-ADONEM.
*       Missing configuration in table /ZAK/ADONEM! (Company: &, tax code: &).
      ENDIF.
*--BG 2007.05.22

*     Self-audit period
    ELSE.
*++S4HANA#01.
*      SELECT SINGLE * INTO W_/ZAK/ADONEM
      SELECT SINGLE ADONEM FIZHAT INTO CORRESPONDING FIELDS OF W_/ZAK/ADONEM
*--S4HANA#01.
                     FROM /ZAK/ADONEM
                    WHERE BUKRS  = $BUKRS
                      AND ADONEM = W_/ZAK/BEVALLB-ADONEM_ONR.
*++BG 2007.05.22
      IF SY-SUBRC NE 0.
        MESSAGE E219(/ZAK/ZAK) WITH $BUKRS W_/ZAK/BEVALLB-ADONEM.
*       Missing configuration in table /ZAK/ADONEM! (Company: &, tax code: &).
      ENDIF.
*--BG 2007.05.22
    ENDIF.

*   Calculate the due date
    PERFORM GET_ESED_DAT USING W_/ZAK/BEVALLO
                               W_/ZAK/BEVALLB
                               $BUKRS
                               $INDEX
                               L_ESDAT
                               W_/ZAK/ADONEM-FIZHAT
                      CHANGING W_/ZAK/ADONSZA-ESDAT.

*++BG 2007.10.04
*     Rotate company
    CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
      EXPORTING
        I_AD_BUKRS    = W_/ZAK/BEVALLO-BUKRS
      IMPORTING
        E_FI_BUKRS    = W_/ZAK/ADONSZA-BUKRS
      EXCEPTIONS
        MISSING_INPUT = 1
        OTHERS        = 2.
    IF SY-SUBRC <> 0.
      MOVE SY-SUBRC TO $SUBRC.
      EXIT.
    ENDIF.

*      IF W_/ZAK/BEVALLO-BUKRS EQ 'MMOB'.
*        W_/ZAK/ADONSZA-BUKRS  = 'MA01'.
*      ELSE.
*        W_/ZAK/ADONSZA-BUKRS  =  W_/ZAK/BEVALLO-BUKRS.
*      ENDIF.
*--BG 2007.10.04

*++BG 2008.03.26
**   PERFORM GET_NUMBER USING    $BUKRS
*    PERFORM GET_NUMBER USING    W_/ZAK/ADONSZA-BUKRS
**--BG 2007.05.22
*                       CHANGING W_/ZAK/ADONSZA-BELNR
*                                L_ERROR.
** ++CST 2006.06.04
*    IF L_ERROR NE SPACE.
*      $SUBRC = 4.
*    ENDIF.
** --CST 2006.06.04
*
*    CHECK L_ERROR IS INITIAL.
*--BG 2008.03.26

*++BG 2007.05.22
**++2007.01.11 BG (FMC)
*    IF W_/ZAK/BEVALLO-BUKRS EQ 'MMOB'.
*      W_/ZAK/ADONSZA-BUKRS  = 'MA01'.
*    ELSE.
*      W_/ZAK/ADONSZA-BUKRS  =  W_/ZAK/BEVALLO-BUKRS.
*    ENDIF.
*++BG 2007.05.22
*   Because the document number range is split based on SY-DATUM
*   the system must use it here as well.
*   W_/ZAK/ADONSZA-GJAHR  =  W_/ZAK/BEVALLO-GJAHR.
    W_/ZAK/ADONSZA-GJAHR  =  SY-DATUM(4).
*--2007.01.11 BG (FMC)
*++2009.02.02 BG
*   Elrakjuk az eredetit is:
    W_/ZAK/ADONSZA-/ZAK/GJAHR  =  W_/ZAK/BEVALLO-GJAHR.
*--2009.02.02 BG
    W_/ZAK/ADONSZA-ADONEM =  W_/ZAK/ADONEM-ADONEM.
*++0965 2009.02.02 BG
*   Only convert the BTYPE for 0865
*   IF  $INDEX NE '000'.
    IF  $INDEX NE '000' AND $BTYPE EQ C_0865.
*--0965 2009.02.02 BG
      PERFORM CONVERT_BTYPE_FROM_DISP USING W_/ZAK/BEVALLO
*++S4HANA#01.
*                                            $BTYPE_CONV
                                   CHANGING $BTYPE_CONV
*--S4HANA#01.
                                            W_/ZAK/ADONSZA-BTYPE.

*     Do not convert the BTYPE
    ELSE.
      W_/ZAK/ADONSZA-BTYPE  =  W_/ZAK/BEVALLO-BTYPE_DISP.
    ENDIF.

    W_/ZAK/ADONSZA-MONAT  =  W_/ZAK/BEVALLO-MONAT.
    W_/ZAK/ADONSZA-ZINDEX =  W_/ZAK/BEVALLO-ZINDEX.
    W_/ZAK/ADONSZA-KOTEL  =  C_KOTEL_K.

*     If sign reversal is flagged in the settings
    IF NOT W_/ZAK/BEVALLB-ELF_ADONSZA IS INITIAL.
      MULTIPLY W_/ZAK/BEVALLO-FIELD_NRK BY -1.
    ENDIF.

*   Difference creation only for VAT
    IF W_/ZAK/ADONEM-ADONEM NE C_ONELL_ADONEM AND
       $INDEX NE '000' AND
       LW_BEVALL-BTYPART EQ C_BTYPART_AFA.


*++S4HANA#01.
*      PERFORM GET_DIFFERENT_WRBTR TABLES LI_LAST_BEVALLO
      PERFORM GET_DIFFERENT_WRBTR TABLES LT_LI_LAST_BEVALLO
*--S4HANA#01.
*                                        $R_ATV_BTYPE
*++BG 2007.05.22
                                         $I_BEVALLB
*--BG 2007.05.22
*++BG 2008.03.26
*++S4HANA#01.
*                                         LR_ADONEM
                                         LT_ADONEM
*--S4HANA#01.
*--BG 2008.03.26

                                  USING  W_/ZAK/BEVALLO
                                         W_/ZAK/ADONSZA-ADONEM
*++S4HANA#01.
*                                         W_/ZAK/ADONSZA-WRBTR
*--S4HANA#01.
                                         L_LAST_INDEX
*++BG 2007.03.20
                                         W_/ZAK/BEVALLB-ELF_ADONSZA
*--BG 2007.03.20
*++S4HANA#01.
                                CHANGING W_/ZAK/ADONSZA-WRBTR
*--S4HANA#01.
                                         .

*     Post the normal amount to the subledger account
    ELSE.
      W_/ZAK/ADONSZA-WRBTR  =  W_/ZAK/BEVALLO-FIELD_NRK.
    ENDIF.

*++BG 2006/06/20
*  If the amount is less than 0, set the ZLOCK flag
    IF W_/ZAK/ADONSZA-WRBTR < 0.
      MOVE 'X' TO W_/ZAK/ADONSZA-ZLOCK.
    ENDIF.
*--BG 2006/06/20

    W_/ZAK/ADONSZA-WAERS  =  W_/ZAK/BEVALLO-WAERS.
    W_/ZAK/ADONSZA-DATUM  =  SY-DATUM.
    W_/ZAK/ADONSZA-UZEIT  =  SY-UZEIT.
    W_/ZAK/ADONSZA-UNAME  =  SY-UNAME.

*++0001 BG 2008.05.05 /ZAK/POST_ADONSZA
**++BG 2008.03.26
**   IF NOT W_/ZAK/ADONSZA-WRBTR IS INITIAL.
*    IF NOT W_/ZAK/ADONSZA-WRBTR IS INITIAL AND $TESZT IS INITIAL.
**--0001 BG 2008.05.05 /ZAK/POST_ADONSZA
*
*      PERFORM GET_NUMBER USING    W_/ZAK/ADONSZA-BUKRS
*                         CHANGING W_/ZAK/ADONSZA-BELNR
*                                  L_ERROR.
*      IF L_ERROR NE SPACE.
*        $SUBRC = 4.
*        EXIT.
*      ENDIF.
*      INSERT INTO /ZAK/ADONSZA VALUES W_/ZAK/ADONSZA.
**++0001 BG 2008.05.05 /ZAK/POST_ADONSZA
*    ELSE.
*++2009.09.15 BG
*   Fill the original due date
    MOVE W_/ZAK/ADONSZA-ESDAT TO W_/ZAK/ADONSZA-ZESDAT.
*--2009.09.15 BG
    APPEND W_/ZAK/ADONSZA TO $I_ADONSZA.
*--0001 BG 2008.05.05 /ZAK/POST_ADONSZA
*    ENDIF.
*--BG 2008.03.26
*++BG 2006/06/23
*   ENDLOOP.
*--BG 2006/06/23
  ENDLOOP.

*++0001 BG 2008.05.13 /ZAK/POST_ADONSZA
* The subledger posting had to be changed because if
* the tax code did not exist it raised the 'E' message
* but the items so far had already been written to the subledger
  IF $TESZT IS INITIAL.
    LOOP AT $I_ADONSZA INTO W_/ZAK/ADONSZA  WHERE NOT WRBTR IS INITIAL.
      PERFORM GET_NUMBER USING    W_/ZAK/ADONSZA-BUKRS
                         CHANGING W_/ZAK/ADONSZA-BELNR
                                  L_ERROR.
      IF L_ERROR NE SPACE.
        $SUBRC = 4.
        EXIT.
      ENDIF.
      INSERT INTO /ZAK/ADONSZA VALUES W_/ZAK/ADONSZA.
    ENDLOOP.
  ENDIF.
*--0001 BG 2008.05.13 /ZAK/POST_ADONSZA


*++BG 2008.03.26
* For VAT determine whether a difference was created for every tax code
* difference creation.
* This case occurs when payable and reclaim positions
* switch, but due to unsettled financial status it still
* results in zero reclaimable VAT. In this case we did not
* handle the tax subledger correctly.
  IF LW_BEVALL-BTYPART EQ C_BTYPART_AFA AND $INDEX NE '000'.
*   Collect the tax codes.
*++S4HANA#01.
*    REFRESH LI_ABEV_ADON.
    CLEAR LT_LI_ABEV_ADON[].
*--S4HANA#01.
    READ TABLE $I_BEVALLO INTO W_/ZAK/BEVALLO INDEX 1.

    LOOP AT  $I_BEVALLB INTO  W_/ZAK/BEVALLB
                        WHERE BTYPE = W_/ZAK/BEVALLO-BTYPE
                          AND NOT ADONEM_ONR IS INITIAL.
*++S4HANA#01.
*      CLEAR LI_ABEV_ADON.
*      MOVE W_/ZAK/BEVALLB-ABEVAZ     TO LI_ABEV_ADON-ABEVAZ.
*      MOVE W_/ZAK/BEVALLB-ADONEM_ONR TO LI_ABEV_ADON-ADONEM.
*      COLLECT LI_ABEV_ADON.
      CLEAR LS_LI_ABEV_ADON.
      MOVE W_/ZAK/BEVALLB-ABEVAZ     TO LS_LI_ABEV_ADON-ABEVAZ.
      MOVE W_/ZAK/BEVALLB-ADONEM_ONR TO LS_LI_ABEV_ADON-ADONEM.
      COLLECT LS_LI_ABEV_ADON INTO LT_LI_ABEV_ADON.
*--S4HANA#01.
    ENDLOOP.
*   Remove the tax codes that have already been processed
*++S4HANA#01.
*    IF NOT LR_ADONEM[] IS INITIAL.
*      DELETE LI_ABEV_ADON WHERE ADONEM IN LR_ADONEM.
    IF NOT LT_ADONEM[] IS INITIAL.
      DELETE LT_LI_ABEV_ADON WHERE ADONEM IN LT_ADONEM.
*--S4HANA#01.
    ENDIF.
*   Each tax code must be processed only once.
*++S4HANA#01.
*    SORT LI_ABEV_ADON BY ADONEM.
*    DELETE ADJACENT DUPLICATES FROM LI_ABEV_ADON COMPARING ADONEM.
    SORT LT_LI_ABEV_ADON BY ADONEM.
    DELETE ADJACENT DUPLICATES FROM LT_LI_ABEV_ADON COMPARING ADONEM.
*--S4HANA#01.

*   If there are remaining tax codes to process
*++S4HANA#01.
*    LOOP AT LI_ABEV_ADON.
*      READ TABLE $I_BEVALLO INTO W_/ZAK/BEVALLO
*                 WITH KEY ABEVAZ = LI_ABEV_ADON-ABEVAZ.
    LOOP AT LT_LI_ABEV_ADON INTO LS_LI_ABEV_ADON.
      READ TABLE $I_BEVALLO INTO W_/ZAK/BEVALLO
                 WITH KEY ABEVAZ = LS_LI_ABEV_ADON-ABEVAZ.
*--S4HANA#01.
      CHECK SY-SUBRC EQ 0.
      READ TABLE $I_BEVALLB INTO  W_/ZAK/BEVALLB WITH KEY
                            BTYPE  =  W_/ZAK/BEVALLO-BTYPE
                            ABEVAZ =  W_/ZAK/BEVALLO-ABEVAZ
                            BINARY SEARCH.
      CHECK SY-SUBRC EQ 0 AND  NOT W_/ZAK/BEVALLB-ADONEM_ONR IS INITIAL.
      CLEAR: W_/ZAK/ADONSZA.
*++S4HANA#01.
*      SELECT SINGLE * INTO W_/ZAK/ADONEM
      SELECT SINGLE ADONEM FIZHAT INTO CORRESPONDING FIELDS OF w_/ZAK/ADONEM
*--S4HANA#01.
                     FROM /ZAK/ADONEM
                    WHERE BUKRS  = $BUKRS
                      AND ADONEM = W_/ZAK/BEVALLB-ADONEM_ONR.
      IF SY-SUBRC NE 0.
        MESSAGE E219(/ZAK/ZAK) WITH $BUKRS W_/ZAK/BEVALLB-ADONEM.
*       Missing configuration in table /ZAK/ADONEM! (Company: &, tax code: &).
      ENDIF.
*   Calculate the due date
      PERFORM GET_ESED_DAT USING W_/ZAK/BEVALLO
                                 W_/ZAK/BEVALLB
                                 $BUKRS
                                 $INDEX
                                 L_ESDAT
                                 W_/ZAK/ADONEM-FIZHAT
                        CHANGING W_/ZAK/ADONSZA-ESDAT.

*     Rotate company
      CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
        EXPORTING
          I_AD_BUKRS    = W_/ZAK/BEVALLO-BUKRS
        IMPORTING
          E_FI_BUKRS    = W_/ZAK/ADONSZA-BUKRS
        EXCEPTIONS
          MISSING_INPUT = 1
          OTHERS        = 2.
      IF SY-SUBRC <> 0.
        MOVE SY-SUBRC TO $SUBRC.
        EXIT.
      ENDIF.

      W_/ZAK/ADONSZA-GJAHR  =  SY-DATUM(4).
      W_/ZAK/ADONSZA-ADONEM =  W_/ZAK/ADONEM-ADONEM.
*     Convert the BTYPE
      PERFORM CONVERT_BTYPE_FROM_DISP USING W_/ZAK/BEVALLO
*++S4HANA#01.
*                                            $BTYPE_CONV
                                   CHANGING $BTYPE_CONV
*--S4HANA#01.
                                            W_/ZAK/ADONSZA-BTYPE.

      W_/ZAK/ADONSZA-MONAT  =  W_/ZAK/BEVALLO-MONAT.
      W_/ZAK/ADONSZA-ZINDEX =  W_/ZAK/BEVALLO-ZINDEX.
      W_/ZAK/ADONSZA-KOTEL  =  C_KOTEL_K.

*    If sign reversal is flagged in the settings
      IF NOT W_/ZAK/BEVALLB-ELF_ADONSZA IS INITIAL.
        MULTIPLY W_/ZAK/BEVALLO-FIELD_NRK BY -1.
      ENDIF.

*   Difference creation only for VAT
      IF W_/ZAK/ADONEM-ADONEM NE C_ONELL_ADONEM.
*++S4HANA#01.
*        PERFORM GET_DIFFERENT_WRBTR TABLES LI_LAST_BEVALLO
        PERFORM GET_DIFFERENT_WRBTR TABLES LT_LI_LAST_BEVALLO
*--S4HANA#01.
*                                        $R_ATV_BTYPE
*++BG 2007.05.22
                                           $I_BEVALLB
*--BG 2007.05.22
*++BG 2008.03.26
*++S4HANA#01.
*                                           LR_ADONEM
                                           LT_ADONEM
*--S4HANA#01.
*--BG 2008.03.26

                                    USING  W_/ZAK/BEVALLO
                                           W_/ZAK/ADONSZA-ADONEM
*++S4HANA#01.
*                                           W_/ZAK/ADONSZA-WRBTR
*--S4HANA#01.
                                           L_LAST_INDEX
*++BG 2007.03.20
                                           W_/ZAK/BEVALLB-ELF_ADONSZA
*--BG 2007.03.20
*++S4HANA#01.
                                  CHANGING W_/ZAK/ADONSZA-WRBTR
*--S4HANA#01.
                                           .

      ENDIF.

*  If the amount is less than 0, set the ZLOCK flag
      IF W_/ZAK/ADONSZA-WRBTR < 0.
        MOVE 'X' TO W_/ZAK/ADONSZA-ZLOCK.
      ENDIF.

      W_/ZAK/ADONSZA-WAERS  =  W_/ZAK/BEVALLO-WAERS.
      W_/ZAK/ADONSZA-DATUM  =  SY-DATUM.
      W_/ZAK/ADONSZA-UZEIT  =  SY-UZEIT.
      W_/ZAK/ADONSZA-UNAME  =  SY-UNAME.
*++0001 BG 2008.05.05 /ZAK/POST_ADONSZA
*++BG 2008.03.26
*     IF NOT W_/ZAK/ADONSZA-WRBTR IS INITIAL.
      IF NOT W_/ZAK/ADONSZA-WRBTR IS INITIAL AND $TESZT IS INITIAL.
*--0001 BG 2008.05.05 /ZAK/POST_ADONSZA
        PERFORM GET_NUMBER USING    W_/ZAK/ADONSZA-BUKRS
                           CHANGING W_/ZAK/ADONSZA-BELNR
                                    L_ERROR.
        IF L_ERROR NE SPACE.
          $SUBRC = 4.
          EXIT.
        ENDIF.
        INSERT INTO /ZAK/ADONSZA VALUES W_/ZAK/ADONSZA.
*++0001 BG 2008.05.05 /ZAK/POST_ADONSZA
      ELSE.
        APPEND W_/ZAK/ADONSZA TO $I_ADONSZA.
*--0001 BG 2008.05.05 /ZAK/POST_ADONSZA
      ENDIF.
*--BG 2008.03.26
    ENDLOOP.
  ENDIF.
*--BG 2008.03.26

ENDFORM.                    " CONVERT_BEVALLO_ADONSZA
*&---------------------------------------------------------------------*
*&      Form  GET_ESED_DAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_ESDAT  text
*      -->P_W_/ZAK/ADONEM_FIZHAT  text
*      <--P_W_/ZAK/ADONSZA_ESDAT  text
*----------------------------------------------------------------------*
FORM GET_ESED_DAT USING    $BEVALLO STRUCTURE /ZAK/BEVALLO
                           $BEVALLB STRUCTURE /ZAK/BEVALLB
                           $BUKRS
                           $INDEX
                           $DATUM
                           $FIZHAT
                  CHANGING $ESDAT.

  CLEAR $ESDAT.

* For a normal period use the BEVALLO date
  IF $INDEX EQ '000'.
    CONCATENATE $BEVALLO-GJAHR
                $BEVALLO-MONAT
                '01' INTO $ESDAT.
* Last day of the month
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
      EXPORTING
        DAY_IN            = $ESDAT
      IMPORTING
        LAST_DAY_OF_MONTH = $ESDAT.
* First day of the next month
    ADD 1 TO $ESDAT.
    $ESDAT = $ESDAT + $FIZHAT - 1.
* For self-audit use the due date
  ELSE.
    MOVE $DATUM TO $ESDAT.
  ENDIF.

*++2007.07.23 BG(FMC) Convert due date to next
*munkanapra
  CALL FUNCTION 'BKK_GET_NEXT_WORKDAY'
    EXPORTING
      I_DATE         = $ESDAT
      I_CALENDAR1    = C_CALID
*     I_CALENDAR2    =
    IMPORTING
      E_WORKDAY      = $ESDAT
    EXCEPTIONS
      CALENDAR_ERROR = 1
      OTHERS         = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E226(/ZAK/ZAK) WITH $ESDAT.
*   Error when converting the due date to the next working day!(&)
  ENDIF.
*--2007.07.23 BG(FMC)


ENDFORM.                    " GET_ESED_DAT
*&---------------------------------------------------------------------*
*&      Form  CONVERT_BTYPE_FROM_DISP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO  text
*      <--P_W_/ZAK/ADONSZA_BTYPE  text
*----------------------------------------------------------------------*
FORM CONVERT_BTYPE_FROM_DISP USING    $BEVALLO  STRUCTURE /ZAK/BEVALLO
*++S4HANA#01.
*                                      $BTYPE_CONV
*                                      $BTYPE.
                             CHANGING $BTYPE_CONV TYPE /ZAK/BEVALL-BTYPE
                                      $BTYPE TYPE /ZAK/ADONSZA-BTYPE.
*--S4HANA#01.

*++S4HANA#01.
*  DATA LW_BEVALL   LIKE /ZAK/BEVALL.
  TYPES: BEGIN OF TS_LW_BEVALL_SEL,
           BUKRS   TYPE /ZAK/BEVALL-BUKRS,
           DATBI   TYPE /ZAK/BEVALL-DATBI,
           BTYPART TYPE /ZAK/BEVALL-BTYPART,
         END OF TS_LW_BEVALL_SEL.
  DATA LW_BEVALL   TYPE TS_LW_BEVALL_SEL.
*--S4HANA#01.
  DATA L_BTYPART_O LIKE /ZAK/BEVALL-BTYPART.



* Determine the self-audit BTYPE
  IF  $BTYPE_CONV IS INITIAL.
*++S4HANA#01.
*    SELECT SINGLE *  INTO LW_BEVALL
*                          FROM /ZAK/BEVALL
*                         WHERE BUKRS EQ $BEVALLO-BUKRS
*                           AND BTYPE EQ $BEVALLO-BTYPE_DISP.
    SELECT BUKRS DATBI BTYPART  INTO LW_BEVALL
                      FROM /ZAK/BEVALL UP TO 1 ROWS
                     WHERE BUKRS EQ $BEVALLO-BUKRS
                       AND BTYPE EQ $BEVALLO-BTYPE_DISP
                     ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.
*   Find the self-audit BTYPE in the valid period
    CONCATENATE LW_BEVALL-BTYPART 'O' INTO L_BTYPART_O.
*++S4HANA#01.
*    SELECT SINGLE BTYPE INTO $BTYPE_CONV
*                        FROM /ZAK/BEVALL
*                       WHERE BUKRS EQ LW_BEVALL-BUKRS
*                         AND DATBI GE LW_BEVALL-DATBI
*                         AND DATAB LE LW_BEVALL-DATBI
*                         AND BTYPART EQ L_BTYPART_O.
    SELECT BTYPE INTO $BTYPE_CONV
                    FROM /ZAK/BEVALL UP TO 1 ROWS
                   WHERE BUKRS EQ LW_BEVALL-BUKRS
                     AND DATBI GE LW_BEVALL-DATBI
                     AND DATAB LE LW_BEVALL-DATBI
                     AND BTYPART EQ L_BTYPART_O
                   ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.
*   If no record is found then use the DISP BTYPE
    IF SY-SUBRC NE 0.
      MOVE $BEVALLO-BTYPE_DISP TO $BTYPE_CONV.
    ENDIF.
  ENDIF.

  MOVE $BTYPE_CONV TO $BTYPE.

ENDFORM.                    " CONVERT_BTYPE_FROM_DISP
*&---------------------------------------------------------------------*
*&      Form  GET_DIFFERENT_WRBTR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/BEVALLO  text
*      -->P_W_/ZAK/ADONSZA_WRBTR  text
*----------------------------------------------------------------------*
FORM GET_DIFFERENT_WRBTR TABLES   $I_LAST_BEVALLO STRUCTURE /ZAK/BEVALLO
*                                 $R_ATV_BTYPE STRUCTURE RANGE_C10
*++BG 2007.05.22
                                  $I_BEVALLB STRUCTURE /ZAK/BEVALLB
*--BG 2007.05.22
*++BG 2008.03.26
                                  $R_ADONEM STRUCTURE RANGE_C10
*--BG 2008.03.26

                         USING    $BEVALLO     STRUCTURE /ZAK/BEVALLO
*++S4HANA#01.
*                                  $ADONEM
*                                  $WRBTR
*                                  $LAST_INDEX
**++BG 2007.03.20
*                                  $ELF_ADONSZA
**--BG 2007.03.20
                                  $ADONEM TYPE /ZAK/ADONSZA-ADONEM
                                  $LAST_INDEX TYPE /ZAK/INDEX
                                  $ELF_ADONSZA TYPE /ZAK/BEVALLB-ELF_ADONSZA
                         CHANGING $WRBTR TYPE /ZAK/ADONSZA-WRBTR.
*--S4HANA#01.
  .

  DATA LW_BEVALLO LIKE /ZAK/BEVALLO.
*++BG 2007.05.22
  DATA LW_BEVALLB LIKE /ZAK/BEVALLB.
*--BG 2007.05.22

*  DATA L_WRBTR LIKE /ZAK/ADONSZA-WRBTR.

** Determine the amount of the items posted so far
*  SELECT SUM( WRBTR ) INTO L_WRBTR
*                      FROM /ZAK/ADONSZA
*                     WHERE BUKRS  EQ $BEVALLO-BUKRS
*                       AND GJAHR  EQ $BEVALLO-GJAHR
*                       AND ADONEM EQ $ADONEM
*                       AND NOT BTYPE IN $R_ATV_BTYPE
*                       AND MONAT  EQ $BEVALLO-MONAT
*                       AND ZINDEX NE '999'          "manual entries
*nem
*                       AND KOTEL  EQ C_KOTEL_K.
*
*  $WRBTR = $BEVALLO-FIELD_NRK - L_WRBTR.
*++BG 2007.05.22
  $WRBTR = $BEVALLO-FIELD_NRK.

  LOOP AT $I_BEVALLB INTO LW_BEVALLB WHERE ADONEM EQ $ADONEM.
*--BG 2007.05.22
* Determine the previous period ABEV identifier
    READ TABLE $I_LAST_BEVALLO INTO LW_BEVALLO
                               WITH KEY BUKRS  = $BEVALLO-BUKRS
                                        BTYPE  = $BEVALLO-BTYPE
                                        GJAHR  = $BEVALLO-GJAHR
                                        MONAT  = $BEVALLO-MONAT
                                        ZINDEX = $LAST_INDEX
*++BG 2007.05.22
*                                       ABEVAZ = $BEVALLO-ABEVAZ
                                        ABEVAZ = LW_BEVALLB-ABEVAZ
*--BG 2007.05.22

                                        BINARY SEARCH.
    IF SY-SUBRC EQ 0.

*++BG 2007.03.20
*++BG 2007.05.22
*     IF NOT $ELF_ADONSZA IS INITIAL.
      IF NOT LW_BEVALLB-ELF_ADONSZA IS INITIAL.
*--BG 2007.05.22
        MULTIPLY LW_BEVALLO-FIELD_NRK BY -1.
      ENDIF.
*--BG 2007.03.20

*++BG 2007.05.22
*      $WRBTR = $BEVALLO-FIELD_NRK - LW_BEVALLO-FIELD_NRK.
*    ELSE.
*      $WRBTR = $BEVALLO-FIELD_NRK.
      $WRBTR = $WRBTR - LW_BEVALLO-FIELD_NRK.
*--BG 2007.05.22
    ENDIF.
  ENDLOOP.
*++BG 2008.03.26
* Store the tax code
  M_DEF $R_ADONEM 'I' 'EQ' $ADONEM SPACE.
*--BG 2008.03.26

ENDFORM.                    " GET_DIFFERENT_WRBTR
*&---------------------------------------------------------------------*
*&      Form  get_uzlag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_UZLETAG  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM GET_UZLAG  USING    $BUKRS
*                         $UZLETAG.
FORM GET_UZLAG  USING $BUKRS TYPE /ZAK/BEVALLO-BUKRS
             CHANGING $UZLETAG TYPE /ZAK/ATV_EXCELN-UZLETAG.
*--S4HANA#01.
  CLEAR $UZLETAG.
  SELECT SINGLE GSBER INTO $UZLETAG
                      FROM /ZAK/ONELL_BOOK
                      WHERE BUKRS = $BUKRS.
  IF SY-SUBRC <> 0 OR $UZLETAG IS INITIAL.
*   I cannot really do anything here anymore
  ENDIF.
ENDFORM.                    " get_uzlag
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE_ARBOOK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EXCEL  text
*      -->P_I_BUKRS  text
*      -->P_I_BTYPE  text
*      -->P_I_GJAHR  text
*      -->P_I_MONAT  text
*      -->P_I_ZINDEX  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE_ARBOOK  TABLES   $I_EXCEL STRUCTURE /ZAK/SZJAEXCELV2
*++S4HANA#01.
*                           USING    $BUKRS
*                                    $BTYPE
*                                    $GJAHR
*                                    $MONAT
*                                    $ZINDEX
*                                    $SUBRC.
                           USING    $BUKRS TYPE BUKRS
                                    $BTYPE TYPE /ZAK/BTYPE
                                    $GJAHR TYPE GJAHR
                                    $MONAT TYPE MONAT
                                    $ZINDEX TYPE /ZAK/INDEX
                           CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

  DATA: L_DEF_FILENAME LIKE RLGRAP-FILENAME,
        L_CANCEL(1).

  DATA: BEGIN OF LI_FIELDS OCCURS 10,
          NAME(40),
        END OF LI_FIELDS.

  DATA: LI_DD03P   LIKE DD03P OCCURS 0 WITH HEADER LINE.
  DATA: LI_DD03P_2 LIKE DD03P OCCURS 0 WITH HEADER LINE.

  DATA:
    L_FILENAME TYPE STRING,
    L_FILTER   TYPE STRING,
    L_PATH     TYPE STRING,
    L_FULLPATH TYPE STRING,
    L_ACTION   TYPE I.

  DATA:  L_FILENAME_DOWN LIKE RLGRAP-FILENAME.

*++S4HANA#01.
  DATA LV_FILENAME TYPE STRING.
  DATA LV_PATH TYPE STRING.
  DATA LV_DEFAULT_FILENAME TYPE STRING.
  DATA LV_FULLPATH TYPE STRING.
  DATA LV_USER_ACTION TYPE I.
  DATA LV_RC TYPE I.
  DATA LV_WINDOW_TITLE TYPE STRING.
*--S4HANA#01.

  CLEAR $SUBRC.

  CONCATENATE $BUKRS
              $BTYPE
              $GJAHR
              $MONAT
              $ZINDEX
              TEXT-005
         INTO L_DEF_FILENAME SEPARATED BY '_'.


  CONCATENATE L_DEF_FILENAME '.XLS' INTO L_DEF_FILENAME.


* Read the data structure
  CALL FUNCTION 'DD_GET_DD03P_ALL'
    EXPORTING
      DEFSTATUS     = 'A'
      LANGU         = SY-LANGU
      TABNAME       = '/ZAK/SZJAEXCELV2'
    TABLES
      A_DD03P_TAB   = LI_DD03P
      N_DD03P_TAB   = LI_DD03P_2
    EXCEPTIONS
      ILLEGAL_VALUE = 1
      OTHERS        = 2.

  IF SY-SUBRC = 0.
    LOOP AT LI_DD03P WHERE FIELDNAME <> '.INCLUDE'.
      MOVE LI_DD03P-REPTEXT TO LI_FIELDS-NAME.
      APPEND LI_FIELDS.
    ENDLOOP.
  ENDIF.


  MOVE L_DEF_FILENAME TO L_FILENAME.

  L_FILTER = '*.XLS'.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
*     WINDOW_TITLE      =
*     DEFAULT_EXTENSION = '*.*'
      DEFAULT_FILE_NAME = L_FILENAME
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    CHANGING
      FILENAME          = L_FILENAME
      PATH              = L_PATH
      FULLPATH          = L_FULLPATH
      USER_ACTION       = L_ACTION
    EXCEPTIONS
      CNTL_ERROR        = 1
      ERROR_NO_GUI      = 2
      OTHERS            = 3.

  CHECK SY-SUBRC = 0.

  MOVE  L_FULLPATH TO L_FILENAME_DOWN.

*++S4HANA#01.
*  CALL FUNCTION 'DOWNLOAD'
*    EXPORTING
*      FILENAME                = L_FILENAME_DOWN
*      FILETYPE                = 'DAT'
*      ITEM                    = 'Self-audit surcharge'(003)
*      FILETYPE_NO_CHANGE      = 'X'
*      FILETYPE_NO_SHOW        = 'X'
*    IMPORTING
*      CANCEL                  = L_CANCEL
*    TABLES
*      DATA_TAB                = $I_EXCEL[]
*      FIELDNAMES              = LI_FIELDS
*    EXCEPTIONS
*      INVALID_FILESIZE        = 1
*      INVALID_TABLE_WIDTH     = 2
*      INVALID_TYPE            = 3
*      NO_BATCH                = 4
*      UNKNOWN_ERROR           = 5
*      GUI_REFUSE_FILETRANSFER = 6
*      CUSTOMER_ERROR          = 7
*      OTHERS                  = 8.
  LV_DEFAULT_FILENAME = L_FILENAME_DOWN.
  CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
    EXPORTING
      FULL_NAME     = LV_DEFAULT_FILENAME
    IMPORTING
      STRIPPED_NAME = LV_FILENAME
      FILE_PATH     = LV_PATH
    EXCEPTIONS
      X_ERROR       = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  LV_WINDOW_TITLE = 'Önellenőrzési pótlék'(003).
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE      = LV_WINDOW_TITLE
      DEFAULT_FILE_NAME = LV_FILENAME
      INITIAL_DIRECTORY = LV_PATH
    CHANGING
      FILENAME          = LV_FILENAME
      PATH              = LV_PATH
      FULLPATH          = LV_FULLPATH
      USER_ACTION       = LV_USER_ACTION.
  CHECK LV_USER_ACTION EQ 0.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME   = LV_FULLPATH
      FILETYPE   = 'DAT'
      FIELDNAMES = LI_FIELDS[]
    CHANGING
      DATA_TAB   = $I_EXCEL[]
    EXCEPTIONS
      OTHERS     = 1.
*--S4HANA#01.
  IF SY-SUBRC <> 0 OR
L_CANCEL   = 'X' OR
L_CANCEL   = 'x'.
    MOVE 4 TO $SUBRC.
  ENDIF.


ENDFORM.                    " DOWNLOAD_FILE_ARBOOK
