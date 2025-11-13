FUNCTION /ZAK/SZJA_NEW_ROWS.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"  TABLES
*"      I_/ZAK/ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"      O_/ZAK/ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"----------------------------------------------------------------------
  TABLES: /ZAK/SZJA_ABEV            "SZJA selection, ABEV definition
          .
* Configuration data
  DATA W_/ZAK/SZJA_CUST TYPE  /ZAK/SZJA_CUST.
  DATA I_/ZAK/SZJA_CUST TYPE STANDARD TABLE OF /ZAK/SZJA_CUST
                                                         INITIAL SIZE 0.
*       Only searches the first half of the key

  DATA W_/ZAK/ZAK_CUST_KEY TYPE  /ZAK/SZJA_CUST.
  DATA I_/ZAK/ZAK_CUST_KEY TYPE STANDARD TABLE OF /ZAK/SZJA_CUST
                                                         INITIAL SIZE 0.

* /ZAK/ANALITIKA structures
  DATA W_I_/ZAK/ANALITIKA TYPE  /ZAK/ANALITIKA.
  DATA W_O_/ZAK/ANALITIKA TYPE  /ZAK/ANALITIKA.
* ABEV determination
  DATA W_/ZAK/SZJA_ABEV TYPE  /ZAK/SZJA_ABEV.
  DATA I_/ZAK/SZJA_ABEV TYPE STANDARD TABLE OF /ZAK/SZJA_ABEV
                                                         INITIAL SIZE 0.

*
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
*  Determination of the % fields
  FIELD-SYMBOLS <FS_MEZO> TYPE ANY.
*++0908 2009.02.04 BG
  DATA LW_SZJA_ABEV LIKE /ZAK/SZJA_ABEV.
*--0908 2009.02.04 BG
*++1908 #10.
  DATA L_DATUM TYPE DATUM.
*--1908 #10.
*
*  RANGES: r_aufnr FOR /zak/szja_cust-aufnr.
*  RANGES: r_saknr FOR /zak/szja_cust-saknr.
* Collects the ABEV identifiers.
* It searches for the key only for the analytics records defined by
* the import parameters and later processes only those records.
  PERFORM GET_ABEV_KULCS  TABLES  I_/ZAK/ANALITIKA
                                  I_/ZAK/ZAK_CUST_KEY
                          USING   I_BUKRS
                                  I_BTYPE
                                  I_BSZNUM.

* Configuration table data
  PERFORM READ_/ZAK/SZJA_CUST TABLES I_/ZAK/SZJA_CUST
                                    I_/ZAK/ZAK_CUST_KEY
                              USING I_BUKRS
                                    I_BTYPE
                                    I_BSZNUM
                                    L_SUBRC.
* Table of ABEV identifiers
  PERFORM READ_/ZAK/SZJA_ABEV TABLES I_/ZAK/SZJA_ABEV
                              USING I_BUKRS
                                    I_BTYPE
                           CHANGING L_SUBRC.
* Iterate over the configuration rows and find the corresponding analytics rows.
  LOOP AT I_/ZAK/SZJA_CUST INTO W_/ZAK/SZJA_CUST.


*    Create a selection from the order
    PERFORM AUFNR_FELTOLT TABLES R_AUFNR
                          USING W_/ZAK/SZJA_CUST-AUFNR.
*    Create a range from the general ledger
    PERFORM SAKNR_FELTOLT TABLES R_SAKNR
                          USING W_/ZAK/SZJA_CUST-SAKNR.

*   Select the analytics records for /zak/szja_cust
    LOOP AT I_/ZAK/ANALITIKA INTO W_I_/ZAK/ANALITIKA
                     WHERE BUKRS  = W_/ZAK/SZJA_CUST-BUKRS
                       AND BTYPE  = W_/ZAK/SZJA_CUST-BTYPE
                       AND BSZNUM = W_/ZAK/SZJA_CUST-BSZNUM
                       AND ABEVAZ = W_/ZAK/SZJA_CUST-ABEVAZ
                       AND HKONT IN R_SAKNR
                       AND AUFNR IN R_AUFNR.
      L_TABIX = SY-TABIX.
ENHANCEMENT-POINT /ZAK/ZAK_SZJA_GEN SPOTS /ZAK/FUNCTIONS_ES .
*++2108 #16.
      IF NOT W_I_/ZAK/ANALITIKA-ADODAT IS INITIAL.
        L_DATUM = W_I_/ZAK/ANALITIKA-ADODAT.
      ELSE.
*--2108 #16.
*++1908 #10.
        CONCATENATE W_I_/ZAK/ANALITIKA-GJAHR W_I_/ZAK/ANALITIKA-MONAT '01' INTO L_DATUM.
*++2108 #16.
      ENDIF.
*--2108 #16.
      CHECK L_DATUM BETWEEN W_/ZAK/SZJA_CUST-DATAB AND W_/ZAK/SZJA_CUST-DATBI.
*--1908 #10.
*    Create the new analytics records for the given row
*++0908 2009.02.04 BG
*     LOOP AT I_/ZAK/SZJA_ABEV INTO W_/ZAK/SZJA_ABEV.
      LOOP AT I_/ZAK/SZJA_ABEV INTO W_/ZAK/SZJA_ABEV WHERE BSZNUM IS INITIAL.
*--0908 2009.02.04 BG
*       Copy the given % field from the configuration (7th - 15th field)
        ASSIGN COMPONENT W_/ZAK/SZJA_ABEV-FIELDNAME OF STRUCTURE
                         W_/ZAK/SZJA_CUST TO <FS_MEZO>.
*       A new ANALITIKA row is only needed if the % is filled
*       and exists
        IF SY-SUBRC = 0.
          IF NOT <FS_MEZO> IS INITIAL.
*++0908 2009.02.04 BG
*         Check whether a record exists for data reporting:
            READ TABLE I_/ZAK/SZJA_ABEV INTO LW_SZJA_ABEV
                       WITH KEY BUKRS     = W_/ZAK/SZJA_CUST-BUKRS
                                BTYPE     = W_/ZAK/SZJA_CUST-BTYPE
                                BSZNUM    = W_/ZAK/SZJA_CUST-BSZNUM
                                FIELDNAME = W_/ZAK/SZJA_ABEV-FIELDNAME.
            IF SY-SUBRC EQ 0.
              MOVE LW_SZJA_ABEV TO W_/ZAK/SZJA_ABEV.
            ENDIF.
*--0908 2009.02.04 BG
*           Cost center check -> if empty, take it from the COST table,
*           if it is filled
            IF W_I_/ZAK/ANALITIKA-KOSTL IS INITIAL.
              IF NOT W_/ZAK/SZJA_CUST-KOSTL IS INITIAL.
                W_I_/ZAK/ANALITIKA-KOSTL = W_/ZAK/SZJA_CUST-KOSTL.
              ENDIF.
            ENDIF.
            PERFORM /ZAK/ANALITIKA_TOLT TABLES O_/ZAK/ANALITIKA
                                        USING W_I_/ZAK/ANALITIKA
                                              <FS_MEZO>
                                              W_/ZAK/SZJA_ABEV-ABEVAZ.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF W_/ZAK/SZJA_CUST-ALAPKONYV = 'X'.
*       If set, the original row must also be marked for posting
*       status
        W_I_/ZAK/ANALITIKA-BOOK  = 'M'. "Marked for posting
*           Cost center check -> if empty, take it from the COST table,
*           if it is filled
        IF W_I_/ZAK/ANALITIKA-KOSTL IS INITIAL.
          IF NOT W_/ZAK/SZJA_CUST-KOSTL IS INITIAL.
            W_I_/ZAK/ANALITIKA-KOSTL = W_/ZAK/SZJA_CUST-KOSTL.
          ENDIF.
        ENDIF.

        MODIFY I_/ZAK/ANALITIKA FROM W_I_/ZAK/ANALITIKA INDEX L_TABIX
                               TRANSPORTING BOOK KOSTL.
      ENDIF.



    ENDLOOP.

  ENDLOOP.



ENDFUNCTION.
