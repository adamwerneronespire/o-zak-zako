FUNCTION /ZAK/PTG_XML_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_FILE) TYPE  STRING
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_MONAT) TYPE  MONAT OPTIONAL
*"  TABLES
*"      T_/ZAK/BEVALLALV STRUCTURE  /ZAK/BEVALLALV OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"      ERROR_DOWNLOAD
*"----------------------------------------------------------------------

  DATA LI_A_PTGSZLAA TYPE TABLE OF /ZAK/XML_GEN.
  DATA LW_XML_GEN TYPE /ZAK/XML_GEN.
  DATA LW_BEVALLO_ALV TYPE /ZAK/BEVALLALV.
  DATA NYOMTA TYPE TEXT30.
  DATA BUKRSTEXT TYPE TEXT30.
  DATA ADOSZAM   TYPE TEXT30.
  DATA STRING TYPE STRING.
  DATA EX TYPE REF TO CX_ROOT.
  DATA ERROR_TEXT TYPE STRING.
  DATA ABEV  LIKE /ZAK/T5HS7-MEZON.
  DATA VALUE LIKE /ZAK/T5HS7-MEZOE.
*++PTGSZLAH #03.
  DATA FROM TYPE DATE.
  DATA TO   TYPE DATE.
*--PTGSZLAH #03.

  READ TABLE T_/ZAK/BEVALLALV INTO LW_BEVALLO_ALV INDEX 1.

* Reading declaration settings
  REFRESH I_/ZAK/BEVALLB.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  LW_BEVALLO_ALV-BTYPE.

  SORT I_/ZAK/BEVALLB.


* Determining company name
*++PTGSZLAH #03.
  IF LW_BEVALLO_ALV-BTYPE EQ C_BTYPE_PTGSZLAH.
    ABEV = '0A0001C004'. "Company in ABEV PTGSZLAA
  ELSE.
*--PTGSZLAH #03.
    ABEV = '0A0001C003'. "Company in ABEV PTGSZLAA
*++PTGSZLAH #03.
  ENDIF.
*--PTGSZLAH #03.
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Determining tax number
  ABEV = '0A0001C001'. "Tax number in ABEV PTGSZLAA
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.

*++PTGSZLAH #03.
* Determining period-from value
  ABEV = '0A0001D001'. "Tax number in ABEV PTGSZLAA
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  FROM = VALUE.

* Determining period-to value
  ABEV = '0A0001D002'. "Tax number in ABEV PTGSZLAA
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  TO = VALUE.
*--PTGSZLAH #03.

* Form identifiers:
  MOVE LW_BEVALLO_ALV-BTYPE TO NYOMTA.


* Compiling data from BEVALLO_ALV
  PERFORM FIELDS_FROM_BEVALLO_TO_PTG    TABLES T_/ZAK/BEVALLALV
                                               I_/ZAK/BEVALLB
                                               LI_A_PTGSZLAA.

  SORT LI_A_PTGSZLAA.

  TRY.
      CALL TRANSFORMATION /ZAK/PTGSZLAA OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA        = NYOMTA
                                           BUKRSTEXT     = BUKRSTEXT
                                           ADOSZAM       = ADOSZAM
*++PTGSZLAH #03.
                                           FROM          = FROM
                                           TO            = TO
*--PTGSZLAH #03.
                                           I_A_PTGSZLAA  = LI_A_PTGSZLAA
                                    RESULT XML STRING.

*    PERFORM display_xml USING string.
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
