FUNCTION /ZAK/XML.
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
  DATA L_SUBRC LIKE SY-SUBRC.

* For /zak/zak_analitika
  DATA: L_ADOAZON LIKE /ZAK/ANALITIKA-ADOAZON,
        L_GJAHR   LIKE /ZAK/ANALITIKA-GJAHR,
        L_MONAT   LIKE /ZAK/ANALITIKA-MONAT,
        L_NYOMT   TYPE /ZAK/ANALITIKA-BTYPE.

  DATA: L_ITEM    LIKE /ZAK/ANALITIKA-ITEM.

  DATA: L_TABIX   LIKE SY-TABIX.
  DATA: L_INDEX   LIKE SY-TABIX.
  DATA: L_ELOJEL.

*++BG 2006.10.11 BG
  DATA: L_BEGIN TYPE I.
*--BG 2006.10.11 BG

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
*++2308 #10.
  SELECT SINGLE WAERS INTO T001-WAERS
                      FROM T005
                     WHERE LAND1 EQ T001-LAND1.
*--2308 #10.
* We check the ABEV identifier in the form data!
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  I_BTYPE.

  SELECT * INTO TABLE I_/ZAK/BEVALLBT
           FROM /ZAK/BEVALLBT
          WHERE LANGU EQ  SY-LANGU
            AND BTYPE EQ  I_BTYPE.

  SORT I_/ZAK/BEVALLB  BY BTYPE ABEVAZ.
  SORT I_/ZAK/BEVALLBT BY LANGU BTYPE ABEVAZ.

  CLEAR L_INDEX.

* Data processing
  LOOP AT I_DATA_TABLE INTO W_DATA_LINE.
* To ensure dialog runtime
    PERFORM PROCESS_IND_ITEM USING '10000'
                                   L_INDEX
                                   TEXT-P01.

    CLEAR: W_HIBA.
*   Tax identification number
    IF W_DATA_LINE-ELEMENT = 'adoazonosito'(001).
      CLEAR L_ADOAZON.
      L_ADOAZON = W_DATA_LINE-VALUE.
    ENDIF.

*   From
    IF W_DATA_LINE-ELEMENT = 'tol'(002).
      CLEAR: L_GJAHR,L_MONAT.
      L_GJAHR = W_DATA_LINE-VALUE(4).
      L_MONAT = W_DATA_LINE-VALUE+4(2).
    ENDIF.

*   Form identifier
    IF W_DATA_LINE-ELEMENT = 'nyomtatvanyazonosito'.
      CLEAR L_NYOMT.
      L_NYOMT = W_DATA_LINE-VALUE.
    ENDIF.

*   eazon
    IF W_DATA_LINE-ELEMENT = 'eazon'(003).
      ADD 1 TO L_TABIX.
      CLEAR W_ANALITIKA-ABEVAZ.
*   The sheet number is also included in the ABEV identifier, therefore
*   it does not need to be considered.
*++BG 2006.10.11 BG
*Since for 06082A the letter shifts by one character, therefore
*we always consider the last character:
      L_BEGIN = STRLEN( L_NYOMT ).
      SUBTRACT 1 FROM L_BEGIN.
*     CONCATENATE L_NYOMT+4(1)
      CONCATENATE L_NYOMT+L_BEGIN(1)
                  W_DATA_LINE-ATTRIB(2)
                  W_DATA_LINE-ATTRIB+6(10) INTO W_ANALITIKA-ABEVAZ.
      MOVE  W_DATA_LINE-VALUE TO W_ANALITIKA-FIELD_C.
*--BG 2006.10.11 BG
*   Dynamic sheet number
      MOVE W_DATA_LINE-ATTRIB+2(4) TO W_ANALITIKA-LAPSZ.

*   We check the ABEV identifier in the form data!
*      SELECT SINGLE * FROM /ZAK/BEVALLB INTO W_BEVALLB
*                      WHERE BTYPE EQ  I_BTYPE AND
*                            ABEVAZ EQ W_ANALITIKA-ABEVAZ.
      READ TABLE I_/ZAK/BEVALLB INTO W_BEVALLB
                           WITH KEY BTYPE  = I_BTYPE
                                    ABEVAZ = W_ANALITIKA-ABEVAZ
                                    BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        IF W_BEVALLB-FIELDTYPE EQ 'N'.
          IF NOT W_ANALITIKA-FIELD_C CO '-0123456789., '.
*           Filling error table
*            SELECT SINGLE * FROM /ZAK/BEVALLBT INTO W_BEVALLBT
*                            WHERE LANGU EQ SY-LANGU AND
*                                  BTYPE EQ  I_BTYPE AND
*                                  ABEVAZ EQ W_ANALITIKA-ABEVAZ.
            READ TABLE I_/ZAK/BEVALLBT INTO W_BEVALLBT
                       WITH KEY LANGU  = SY-LANGU
                                BTYPE  = I_BTYPE
                                ABEVAZ = W_ANALITIKA-ABEVAZ.
            W_HIBA-ZA_HIBA = 'Csak numerikus lehet!'.
            W_HIBA-SOR          = L_TABIX.
*           W_HIBA-OSZLOP       = 'We do not know'.
            W_HIBA-/ZAK/F_VALUE  = W_ANALITIKA-FIELD_C.
*++BG 2006.10.11 BG
*           W_HIBA-FIELDNAME    = W_BEVALLBT-ABEVTEXT.
            CONCATENATE W_ANALITIKA-ABEVAZ W_BEVALLBT-ABEVTEXT
                        INTO W_HIBA-FIELDNAME SEPARATED BY '-'.
*--BG 2006.10.11 BG
            APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
          ELSE.
*         Handling negative values
            CLEAR L_ELOJEL.
            MOVE W_ANALITIKA-FIELD_C TO W_ANALITIKA-FIELD_N.
*++BG 2006/11/29
            W_ANALITIKA-FIELD_N = W_ANALITIKA-FIELD_N *
                                  ( 10 ** W_BEVALLB-ROUND ).
*--BG 2006/11/29

            IF W_ANALITIKA-FIELD_N < 0.
              W_ANALITIKA-FIELD_N = ABS( W_ANALITIKA-FIELD_N ).
              MOVE '-' TO L_ELOJEL.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'Z_2_CONVERT_STRING_TO_PACKED'
               EXPORTING
                    I_AMOUNT        = W_ANALITIKA-FIELD_N
                    I_CURRENCY_CODE = T001-WAERS
               IMPORTING
                    E_AMOUNT        = W_ANALITIKA-FIELD_N
               EXCEPTIONS
                    NOT_NUMERIC     = 1
                    OTHERS          = 2.
          IF SY-SUBRC <> 0.
            MESSAGE E173(/ZAK/ZAK) WITH W_ANALITIKA-FIELD_C.
*            Amount conversion error & !
          ENDIF.
*         If the sign was '-'.
          IF L_ELOJEL EQ '-'.
            MULTIPLY W_ANALITIKA-FIELD_N BY -1.
          ENDIF.

          MOVE T001-WAERS TO W_ANALITIKA-WAERS.
          CLEAR W_ANALITIKA-FIELD_C.
*       The ABEV identifier does not exist
        ELSE.
          MOVE W_DATA_LINE-VALUE TO W_ANALITIKA-FIELD_C.
        ENDIF.
      ELSE.
        W_HIBA-ZA_HIBA = 'Abev azonosító nem létezik'.
        W_HIBA-SOR          = L_TABIX.
        W_HIBA-/ZAK/F_VALUE  = W_ANALITIKA-ABEVAZ.
        APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
      ENDIF.
      W_ANALITIKA-BUKRS  = I_BUKRS.
      W_ANALITIKA-BTYPE  = I_BTYPE.
      W_ANALITIKA-BSZNUM = I_BSZNUM.
      W_ANALITIKA-GJAHR  = L_GJAHR.
      W_ANALITIKA-MONAT  = L_MONAT.
      W_ANALITIKA-ADOAZON = L_ADOAZON.
      W_ANALITIKA-ITEM   = L_TABIX.
      APPEND W_ANALITIKA TO T_/ZAK/ANALITIKA.
      CLEAR W_ANALITIKA.
    ENDIF.

    DELETE I_DATA_TABLE.
  ENDLOOP.

  FREE I_DATA_TABLE.

ENDFUNCTION.
