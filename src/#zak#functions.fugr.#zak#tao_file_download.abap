FUNCTION /ZAK/TAO_FILE_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_FILE) TYPE  STRING OPTIONAL
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_MONAT) TYPE  MONAT OPTIONAL
*"  TABLES
*"      T_/ZAK/BEVALLALV STRUCTURE  /ZAK/BEVALLALV OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      ERROR_DOWNLOAD
*"----------------------------------------------------------------------

  DATA LI_A_XX29 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LW_XML_GEN TYPE /ZAK/XML_GEN.
  DATA LW_BEVALLO_ALV TYPE /ZAK/BEVALLALV.
  DATA NYOMTA TYPE TEXT30.

  DATA BUKRSTEXT TYPE TEXT50.
  DATA ADOSZAM   TYPE TEXT30.
  DATA IDTOL    TYPE TEXT30.
  DATA IDIG     TYPE TEXT30.
  DATA STRING TYPE STRING.
  DATA EX TYPE REF TO CX_ROOT.
  DATA ERROR_TEXT TYPE STRING.
  DATA ABEV  LIKE /ZAK/T5HS7-MEZON.
  DATA VALUE LIKE /ZAK/T5HS7-MEZOE.


  READ TABLE T_/ZAK/BEVALLALV INTO LW_BEVALLO_ALV INDEX 1.

* Read declaration configuration
  REFRESH I_/ZAK/BEVALLB.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  LW_BEVALLO_ALV-BTYPE.

  SORT I_/ZAK/BEVALLB.

* Determine company name
  ABEV = '0A0001E005'. "Company
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Determine tax number
  ABEV = '0A0001E001'. "Tax number ABEV
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.
* Form identifiers:
  MOVE LW_BEVALLO_ALV-BTYPE TO NYOMTA.

* Period from:
  ABEV = '0A0001F001'. "Period from
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDTOL = VALUE.
* Period to:
  ABEV = '0A0001F002'. "Period to
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDIG = VALUE.
* Assemble data from BEVALLO_ALV
  PERFORM FIELDS_FROM_IT_BEVALLO_TO_TAO TABLES T_/ZAK/BEVALLALV
                                               I_/ZAK/BEVALLB
                                               LI_A_XX29.

  SORT LI_A_XX29.

    TRY.
      CALL TRANSFORMATION /ZAK/XX29 OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA     = NYOMTA
                                           BUKRSTEXT  = BUKRSTEXT
                                           ADOSZAM    = ADOSZAM
                                           IDTOL      = IDTOL
                                           IDIG       = IDIG
                                           I_A_XX29   = LI_A_XX29
                                    RESULT XML STRING.

      STRING = STRING+1.
      CONCATENATE '<?xml version="1.0" encoding="utf-8"?>'  STRING
                  INTO STRING.
      PERFORM SAVE_KULF_XML_FILE USING STRING
                                       I_FILE.
    CATCH CX_ROOT INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE E000(/ZAK/ZAK) WITH ERROR_TEXT RAISING ERROR.
  ENDTRY.


ENDFUNCTION.
