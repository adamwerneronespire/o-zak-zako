FUNCTION /ZAK/XML_AFA_UPLOAD.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(FILENAME) LIKE  RLGRAP-FILENAME
*"     REFERENCE(I_BUKRS) TYPE  T001-BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"  EXPORTING
*"     VALUE(E_ONREV) TYPE  XFELD
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
        L_NYOMT   TYPE /ZAK/ANALITIKA-BTYPE,
        L_ABEVAZ  TYPE /ZAK/ANALITIKA-ABEVAZ,
        L_BTYPE_M TYPE /ZAK/BTYPE.

  DATA: L_ITEM    LIKE /ZAK/ANALITIKA-ITEM.

  DATA: L_TABIX   LIKE SY-TABIX.
  DATA: L_INDEX   LIKE SY-TABIX.
  DATA: L_ELOJEL.
  DATA: L_SOR      TYPE NUMC4.
  DATA: L_SOR_SAVE TYPE NUMC4.
  DATA: L_SORVEG(2) TYPE C.
  DATA: L_ONELL TYPE XFELD.

  DATA: L_BEGIN TYPE I.

* Header fields:
  RANGES LR_VPOP_ABEV FOR /ZAK/ANALITIKA-ABEVAZ.
  RANGES LR_ONREV_ABEV FOR /ZAK/ANALITIKA-ABEVAZ.
  RANGES LR_NO_SORVEG_01 FOR RANGE_C2-LOW.
  RANGES LR_NO_SORVEG_02 FOR RANGE_C2-LOW.
  RANGES LR_NO_SORVEG_03 FOR RANGE_C2-LOW.
  RANGES LR_NO_SORVEG_04 FOR RANGE_C2-LOW.



* ABEVAZ conversion
  DEFINE LM_CONV_/ZAK/ABEVAZ.
    &2(1) = 'A'.
    CONCATENATE &2 &1(2) &1+6 INTO &2.
  END-OF-DEFINITION.

  DEFINE LM_SAVE_ANALITIKA.
    IF NOT W_ANALITIKA IS INITIAL.
      W_ANALITIKA-BUKRS  = I_BUKRS.
      W_ANALITIKA-BTYPE  = I_BTYPE.
      W_ANALITIKA-BSZNUM = I_BSZNUM.
      W_ANALITIKA-GJAHR  = L_GJAHR.
      W_ANALITIKA-MONAT  = L_MONAT.
*      W_ANALITIKA-ADOAZON = L_ADOAZON.
      W_ANALITIKA-ITEM   = L_TABIX.
*      W_ANALITIKA-ABEVAZ = C_ABEVAZ_DUMMY.
      APPEND W_ANALITIKA TO T_/ZAK/ANALITIKA.
      CLEAR: W_ANALITIKA, L_SOR, L_SOR_SAVE.
    ENDIF.
  END-OF-DEFINITION.

* VPOP ABEV fields
  M_DEF LR_VPOP_ABEV 'I' 'BT' 'A0HC0001AA' 'A0HC0025FA'.
* Self-revision ABEV
  M_DEF LR_ONREV_ABEV 'I' 'EQ' 'A0AF004A' SPACE.

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
* Building the M-type BTYPE
  CONCATENATE I_BTYPE 'M' INTO L_BTYPE_M.

* Data processing
  LOOP AT I_DATA_TABLE INTO W_DATA_LINE.
* To ensure dialog runtime
    PERFORM PROCESS_IND_ITEM USING '10000'
                                   L_INDEX
                                   TEXT-P01.
    CLEAR: W_HIBA.
*   Tax number
    IF W_DATA_LINE-ELEMENT = 'adoszam'(004).
      CLEAR L_ADOAZON.
      L_ADOAZON = W_DATA_LINE-VALUE.
    ENDIF.
*   Form identifier
    IF W_DATA_LINE-ELEMENT = 'nyomtatvanyazonosito'(005).
      CLEAR L_NYOMT.
      L_NYOMT = W_DATA_LINE-VALUE.
      IF W_DATA_LINE-VALUE(4) NE I_BTYPE.
        W_HIBA-ZA_HIBA = 'Szelekciótól eltérő BTYPE!'(009).
        W_HIBA-SOR          = L_TABIX.
*           W_HIBA-OSZLOP       = 'We do not know'.
        W_HIBA-/ZAK/F_VALUE  = W_DATA_LINE-VALUE.
        W_HIBA-FIELDNAME    = 'BTYPE'.
        APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
      ENDIF.
*     M-type sheets no longer need to be processed
      IF W_DATA_LINE-VALUE EQ L_BTYPE_M.
        EXIT.
      ENDIF.
    ENDIF.

*   To
    IF W_DATA_LINE-ELEMENT = 'ig'(006).
      CLEAR: L_GJAHR,L_MONAT.
      L_GJAHR = W_DATA_LINE-VALUE(4).
      L_MONAT = W_DATA_LINE-VALUE+4(2).
    ENDIF.

    ADD 1 TO L_TABIX.
*   eazon
    IF W_DATA_LINE-ELEMENT = 'eazon'(003).
      CLEAR L_ABEVAZ.
*     ABEVAZ conversion
      LM_CONV_/ZAK/ABEVAZ  W_DATA_LINE-ATTRIB L_ABEVAZ.
*      IF L_ABEVAZ IN LR_NO_ABEV AND NOT LR_NO_ABEV[] IS INITIAL.
*        LM_SAVE_ANALITIKA.
*        DELETE I_DATA_TABLE.
*        CONTINUE.
*      ENDIF.
      MOVE L_ABEVAZ TO W_ANALITIKA-ABEVAZ.
*     Monitoring self-revision
      IF  W_ANALITIKA-ABEVAZ IN LR_ONREV_ABEV AND  W_DATA_LINE-VALUE EQ 'O'.
        E_ONREV = 'X'.
      ENDIF.

*     We check the ABEV identifier in the form data!
      READ TABLE I_/ZAK/BEVALLB INTO W_BEVALLB
                           WITH KEY BTYPE  = I_BTYPE
                                    ABEVAZ = W_ANALITIKA-ABEVAZ
                                    BINARY SEARCH.
*     If there is a record and it is required
      IF SY-SUBRC EQ 0 AND NOT W_BEVALLB-XMLALL IS INITIAL.
        IF W_BEVALLB-FIELDTYPE EQ 'N'.
          IF NOT W_DATA_LINE-VALUE  CO '-0123456789., '.
            READ TABLE I_/ZAK/BEVALLBT INTO W_BEVALLBT
                       WITH KEY LANGU  = SY-LANGU
                                BTYPE  = I_BTYPE
                                ABEVAZ = W_ANALITIKA-ABEVAZ.
            W_HIBA-ZA_HIBA = 'Csak numerikus lehet!'(008).
            W_HIBA-SOR          = L_TABIX.
*           W_HIBA-OSZLOP       = 'We do not know'.
            W_HIBA-/ZAK/F_VALUE  = W_ANALITIKA-FIELD_C.
            CONCATENATE W_ANALITIKA-ABEVAZ W_BEVALLBT-ABEVTEXT
                        INTO W_HIBA-FIELDNAME SEPARATED BY '-'.
            APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
          ELSE.
*         Handling negative values
            CLEAR L_ELOJEL.
            MOVE W_DATA_LINE-VALUE  TO W_ANALITIKA-FIELD_N.
            W_ANALITIKA-FIELD_N = W_ANALITIKA-FIELD_N *
                                  ( 10 ** W_BEVALLB-ROUND ).
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
        ELSEIF   W_BEVALLB-FIELDTYPE EQ 'N'.
          MOVE  W_DATA_LINE-VALUE TO W_ANALITIKA-FIELD_C.
        ENDIF.
        LM_SAVE_ANALITIKA.
**     The ABEV identifier does not exist
*      ELSE.
*        W_HIBA-ZA_HIBA = 'The ABEV identifier does not exist'(007).
*        W_HIBA-SOR          = L_TABIX.
*        W_HIBA-/ZAK/F_VALUE  = W_ANALITIKA-ABEVAZ.
*        APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
*     VPOP row
      ELSEIF SY-SUBRC EQ 0 AND   W_ANALITIKA-ABEVAZ IN LR_VPOP_ABEV.
        L_BEGIN = STRLEN( W_ANALITIKA-ABEVAZ ).
        SUBTRACT 2 FROM L_BEGIN.
        L_SORVEG = W_ANALITIKA-ABEVAZ+L_BEGIN(2).
        IF L_SORVEG EQ 'AA'.
          CLEAR W_ANALITIKA.
          W_ANALITIKA-ADOAZON = W_DATA_LINE-VALUE.
        ELSEIF L_SORVEG EQ 'BA'.
          W_ANALITIKA-BLDAT = W_DATA_LINE-VALUE.
        ELSEIF L_SORVEG EQ 'CA'.
          IF NOT W_DATA_LINE-VALUE  CO '-0123456789., '.
            W_HIBA-ZA_HIBA = 'Csak numerikus lehet!'(008).
            W_HIBA-SOR          = L_TABIX.
*           W_HIBA-OSZLOP       = 'We do not know'.
            W_HIBA-/ZAK/F_VALUE  = W_DATA_LINE-VALUE.
            APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
          ELSE.
*         Handling negative values
            CLEAR L_ELOJEL.
            MOVE W_DATA_LINE-VALUE  TO W_ANALITIKA-LWSTE.
            W_ANALITIKA-LWSTE = W_ANALITIKA-LWSTE *
                                  ( 10 ** W_BEVALLB-ROUND ).
            IF W_ANALITIKA-LWSTE < 0.
              W_ANALITIKA-LWSTE = ABS( W_ANALITIKA-LWSTE ).
              MOVE '-' TO L_ELOJEL.
            ENDIF.
          ENDIF.
          CALL FUNCTION 'Z_2_CONVERT_STRING_TO_PACKED'
            EXPORTING
              I_AMOUNT        = W_ANALITIKA-LWSTE
              I_CURRENCY_CODE = T001-WAERS
            IMPORTING
              E_AMOUNT        = W_ANALITIKA-LWSTE
            EXCEPTIONS
              NOT_NUMERIC     = 1
              OTHERS          = 2.
          IF SY-SUBRC <> 0.
            MESSAGE E173(/ZAK/ZAK) WITH W_ANALITIKA-LWSTE.
*            Amount conversion error & !
          ENDIF.
*         If the sign was '-'.
          IF L_ELOJEL EQ '-'.
            MULTIPLY W_ANALITIKA-LWSTE BY -1.
          ENDIF.
          MOVE T001-WAERS TO W_ANALITIKA-WAERS.
        ELSEIF L_SORVEG EQ 'DA'.
          W_ANALITIKA-XBLNR = W_DATA_LINE-VALUE.
        ELSEIF L_SORVEG EQ 'EA'.
          W_ANALITIKA-AUGDT = W_DATA_LINE-VALUE.
        ELSEIF L_SORVEG EQ 'FA'.
          IF NOT W_DATA_LINE-VALUE  CO '-0123456789., '.
            W_HIBA-ZA_HIBA = 'Csak numerikus lehet!'(008).
            W_HIBA-SOR          = L_TABIX.
*           W_HIBA-OSZLOP       = 'We do not know'.
            W_HIBA-/ZAK/F_VALUE  = W_DATA_LINE-VALUE.
            APPEND W_HIBA TO T_HIBA. CLEAR W_HIBA.
          ELSE.
*         Handling negative values
            CLEAR L_ELOJEL.
            MOVE W_DATA_LINE-VALUE  TO W_ANALITIKA-FWSTE.
            W_ANALITIKA-FWSTE = W_ANALITIKA-FWSTE *
                                  ( 10 ** W_BEVALLB-ROUND ).
            IF W_ANALITIKA-FWSTE < 0.
              W_ANALITIKA-FWSTE = ABS( W_ANALITIKA-FWSTE ).
              MOVE '-' TO L_ELOJEL.
            ENDIF.
          ENDIF.
          CALL FUNCTION 'Z_2_CONVERT_STRING_TO_PACKED'
            EXPORTING
              I_AMOUNT        = W_ANALITIKA-FWSTE
              I_CURRENCY_CODE = T001-WAERS
            IMPORTING
              E_AMOUNT        = W_ANALITIKA-FWSTE
            EXCEPTIONS
              NOT_NUMERIC     = 1
              OTHERS          = 2.
          IF SY-SUBRC <> 0.
            MESSAGE E173(/ZAK/ZAK) WITH W_ANALITIKA-FWSTE.
*            Amount conversion error & !
          ENDIF.
*         If the sign was '-'.
          IF L_ELOJEL EQ '-'.
            MULTIPLY W_ANALITIKA-FWSTE BY -1.
          ENDIF.
          MOVE T001-WAERS TO W_ANALITIKA-WAERS.
          W_ANALITIKA-ABEVAZ  = 'DUMMY'.
          LM_SAVE_ANALITIKA.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  FREE I_DATA_TABLE.

ENDFUNCTION.
