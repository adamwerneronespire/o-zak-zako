FUNCTION /ZAK/XML_PTG_UPLOAD.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(FILENAME) LIKE  RLGRAP-FILENAME
*"     REFERENCE(I_BUKRS) TYPE  T001-BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"  TABLES
*"      T_/ZAK/ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"      T_HIBA STRUCTURE  /ZAK/ADAT_HIBA
*"  EXCEPTIONS
*"      ERROR_OPEN_FILE
*"      ERROR_XML
*"      EMPTY_FILE
*"----------------------------------------------------------------------
  DATA L_SUBRC  LIKE SY-SUBRC.
  DATA L_LIFKUN TYPE /ZAK/LIFKUN.
  DATA L_INDEX  LIKE SY-TABIX.
  DATA L_WEEK   TYPE KWEEK.
  DATA L_TABIX  LIKE SY-TABIX.
  DATA L_ELOJEL.
  DATA L_SZAMLAKELT TYPE /ZAK/SZAMLAKELT.


  DEFINE LM_CONVERT_CURR.
    CLEAR L_ELOJEL.
    IF &1 < 0.
      &1 = ABS( &1 ).
      MOVE '-' TO L_ELOJEL.
    ENDIF.
    CALL FUNCTION 'Z_2_CONVERT_STRING_TO_PACKED'
      EXPORTING
        I_AMOUNT        = &1
        I_CURRENCY_CODE = &2
      IMPORTING
        E_AMOUNT        = &1
      EXCEPTIONS
        NOT_NUMERIC     = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
      MESSAGE E173(/ZAK/ZAK) WITH &1.
*            Amount conversion error & !
    ENDIF.
*         If the sign was '-'.
    IF L_ELOJEL EQ '-'.
      MULTIPLY &1 BY -1.
    ENDIF.
  END-OF-DEFINITION.


* Reading XML file
  PERFORM UPLOAD_XML_TO_TABLE TABLES I_DATA_TABLE
                              USING  FILENAME
                                     L_SUBRC.
* File open error
  IF L_SUBRC EQ 1.
    MESSAGE E082(/ZAK/ZAK) WITH FILENAME RAISING ERROR_OPEN_FILE.
*   Error & when opening the file!
* XML file error
  ELSEIF L_SUBRC EQ 2.
    MESSAGE E172(/ZAK/ZAK) WITH FILENAME RAISING ERROR_XML.
*   The XML file (&) is incorrect!
  ENDIF.

* No data
  IF I_DATA_TABLE[] IS INITIAL.
    MESSAGE E100(/ZAK/ZAK) RAISING EMPTY_FILE.
  ENDIF.

* Company master data
  SELECT SINGLE * FROM T001
                 WHERE BUKRS EQ I_BUKRS.

  CLEAR L_INDEX.
  CLEAR: W_ANALITIKA, W_HIBA.

*++PTGSZLAH #01. 2015.01.16
  SORT I_DATA_TABLE BY ATTRIB.
*--PTGSZLAH #01. 2015.01.16

* Data processing
  LOOP AT I_DATA_TABLE INTO W_DATA_LINE WHERE ATTRIB(2) EQ '0B'.
    ADD 1 TO L_TABIX.
*   To ensure dialog runtime
    PERFORM PROCESS_IND_ITEM USING '10000'
                                   L_INDEX
                                   TEXT-P01.
*++PTGSZLAH #01. 2015.01.16
    IF I_BTYPE EQ C_BTYPE_PTGSZLAA.
*--PTGSZLAH #01. 2015.01.16
*   Determining the cash receipt location
      IF W_DATA_LINE-ATTRIB+6(5)  EQ 'B001A'.
        SELECT SINGLE ZAZON INTO L_LIFKUN
                            FROM /ZAK/PENZATV
                           WHERE NAME1 EQ W_DATA_LINE-VALUE.
        IF SY-SUBRC NE 0.
          CLEAR L_LIFKUN.
          W_HIBA-ZA_HIBA = 'Pénztárátvételi hely nem határozható meg'.
          W_HIBA-/ZAK/F_VALUE  =  W_DATA_LINE-VALUE.
          APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
        ENDIF.
      ENDIF.

*   Date:
      IF W_DATA_LINE-ATTRIB+6(5) EQ 'B002A'.
        L_SZAMLAKELT = W_DATA_LINE-VALUE.
        CALL FUNCTION 'DATE_GET_WEEK'
          EXPORTING
            DATE         = L_SZAMLAKELT
          IMPORTING
            WEEK         = L_WEEK
          EXCEPTIONS
            DATE_INVALID = 1
            OTHERS       = 2.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

*   Rows
      CASE W_DATA_LINE-ATTRIB+11(2).
        WHEN 'AA'.
          W_ANALITIKA-SZAMLASZ = W_DATA_LINE-VALUE.
        WHEN 'BA'.
          W_ANALITIKA-SZLATIP  = W_DATA_LINE-VALUE.
        WHEN 'CA'.
          W_ANALITIKA-SZAMLASZE  = W_DATA_LINE-VALUE.
        WHEN 'DA'.
          W_ANALITIKA-STCD1  = W_DATA_LINE-VALUE.
        WHEN 'EA'.
          W_ANALITIKA-ZKUNNAME  = W_DATA_LINE-VALUE.
        WHEN 'FA'.
          W_ANALITIKA-ZKUNADRS  = W_DATA_LINE-VALUE.
        WHEN 'GA'.
          W_ANALITIKA-FWSTE     = W_DATA_LINE-VALUE.
        WHEN 'HA'.
          W_ANALITIKA-WAERS     =
          W_ANALITIKA-FWAERS    = W_DATA_LINE-VALUE.
        WHEN 'IA'.
          W_ANALITIKA-FWBTR     = W_DATA_LINE-VALUE.
*       This is the end of a row
*       Amount conversion:
          LM_CONVERT_CURR: W_ANALITIKA-FWSTE W_ANALITIKA-FWAERS,
                           W_ANALITIKA-FWBTR W_ANALITIKA-FWAERS.
          W_ANALITIKA-FIELD_N = W_ANALITIKA-FWSTE.
*   General analytics data:
          W_ANALITIKA-BUKRS  = I_BUKRS.
          W_ANALITIKA-BTYPE  = I_BTYPE.
**++1465 #19.
*        W_ANALITIKA-GJAHR  = L_SZAMLAKELT(4).
          W_ANALITIKA-GJAHR  = L_WEEK(4).
*--1465 #19.
          W_ANALITIKA-MONAT  = L_WEEK.
          W_ANALITIKA-BSZNUM = I_BSZNUM.
          W_ANALITIKA-ABEVAZ = C_ABEVAZ_DUMMY.
          W_ANALITIKA-ITEM   = L_TABIX.
          W_ANALITIKA-LAPSZ  = 1.
          W_ANALITIKA-LIFKUN = L_LIFKUN.
          W_ANALITIKA-SZAMLAKELT = L_SZAMLAKELT.
          APPEND W_ANALITIKA TO T_/ZAK/ANALITIKA.
          CLEAR W_ANALITIKA.
      ENDCASE.
*++PTGSZLAH #01. 2015.01.16
    ELSEIF I_BTYPE EQ C_BTYPE_PTGSZLAH.
*   Determining the cash receipt location
      IF W_DATA_LINE-ATTRIB+6(5)  EQ 'B005A'.
        SELECT SINGLE ZAZON INTO L_LIFKUN
                            FROM /ZAK/PENZATV
                           WHERE NAME1 EQ W_DATA_LINE-VALUE.
        IF SY-SUBRC NE 0.
          CLEAR L_LIFKUN.
          W_HIBA-ZA_HIBA = 'Pénztárátvételi hely nem határozható meg'.
          W_HIBA-/ZAK/F_VALUE  =  W_DATA_LINE-VALUE.
          APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
        ENDIF.
      ENDIF.
**   Date:
    IF W_DATA_LINE-ATTRIB+6(5) EQ 'B001A'.
      L_SZAMLAKELT = W_DATA_LINE-VALUE.
*      CALL FUNCTION 'DATE_GET_WEEK'
*        EXPORTING
*          DATE         = L_SZAMLAKELT
*        IMPORTING
*          WEEK         = L_WEEK
*        EXCEPTIONS
*          DATE_INVALID = 1
*          OTHERS       = 2.
*      IF SY-SUBRC <> 0.
*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
    ENDIF.

*   Rows
      CASE W_DATA_LINE-ATTRIB+11(2).
        WHEN 'AA'.
          W_ANALITIKA-SZAMLASZ = W_DATA_LINE-VALUE.
        WHEN 'BA'.
          W_ANALITIKA-SZLATIP  = W_DATA_LINE-VALUE.
        WHEN 'CA'.
          W_ANALITIKA-SZAMLASZE  = W_DATA_LINE-VALUE.
*        WHEN 'DA'.
*          W_ANALITIKA-STCD1  = W_DATA_LINE-VALUE.
        WHEN 'DA'.
          W_ANALITIKA-ZKUNNAME  = W_DATA_LINE-VALUE.
        WHEN 'EA'.
          W_ANALITIKA-ZKUNADRS  = W_DATA_LINE-VALUE.
*        WHEN 'GA'.
*          W_ANALITIKA-FWSTE     = W_DATA_LINE-VALUE.
        WHEN 'FA'.
          W_ANALITIKA-WAERS     =
          W_ANALITIKA-FWAERS    = W_DATA_LINE-VALUE.
        WHEN 'GA'.
          W_ANALITIKA-FWBTR     = W_DATA_LINE-VALUE.
*       This is the end of a row
*       Amount conversion:
          LM_CONVERT_CURR: W_ANALITIKA-FWSTE W_ANALITIKA-FWAERS,
                           W_ANALITIKA-FWBTR W_ANALITIKA-FWAERS.
          W_ANALITIKA-FIELD_N = W_ANALITIKA-FWSTE.
*   General analytics data:
          W_ANALITIKA-BUKRS  = I_BUKRS.
          W_ANALITIKA-BTYPE  = I_BTYPE.
          W_ANALITIKA-GJAHR  = L_SZAMLAKELT(4).
          W_ANALITIKA-MONAT  = L_SZAMLAKELT+4(2).
          W_ANALITIKA-BSZNUM = I_BSZNUM.
          W_ANALITIKA-ABEVAZ = C_ABEVAZ_DUMMY.
          W_ANALITIKA-ITEM   = L_TABIX.
          W_ANALITIKA-LAPSZ  = 1.
          W_ANALITIKA-LIFKUN = L_LIFKUN.
          W_ANALITIKA-SZAMLAKELT = L_SZAMLAKELT.
          APPEND W_ANALITIKA TO T_/ZAK/ANALITIKA.
          CLEAR W_ANALITIKA.
      ENDCASE.
    ENDIF.
*--PTGSZLAH #01. 2015.01.16
  ENDLOOP.

  FREE I_DATA_TABLE.

ENDFUNCTION.
