FUNCTION /ZAK/KATA_FILE_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
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

  DATA LI_A_XXK102 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_M_XXK102 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_MS_XXK102 TYPE TABLE OF  /ZAK/MSLINEXXK79.
  DATA LW_XML_GEN TYPE /ZAK/XML_GEN.
  DATA LW_BEVALLO_ALV TYPE /ZAK/BEVALLALV.
  DATA NYOMTA TYPE TEXT30.
  DATA NYOMTM TYPE TEXT30.
*++1665 #02.
*  DATA bukrstext TYPE text30.
  DATA BUKRSTEXT TYPE TEXT50.
*--1665 #02.
  DATA ADOSZAM   TYPE TEXT30.
  DATA STRING TYPE STRING.
  DATA EX TYPE REF TO CX_ROOT.
  DATA ERROR_TEXT TYPE STRING.
  DATA ABEV  LIKE /ZAK/T5HS7-MEZON.
  DATA VALUE LIKE /ZAK/T5HS7-MEZOE.




  READ TABLE T_/ZAK/BEVALLALV INTO LW_BEVALLO_ALV INDEX 1.

* Bevallások beállításának beolvasása
  REFRESH I_/ZAK/BEVALLB.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  LW_BEVALLO_ALV-BTYPE.

  SORT I_/ZAK/BEVALLB.


* Vállalat név meghatározása
  ABEV = '0A0001C004'. "Vállalat
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Adószám meghatározása
  ABEV = '0A0001C001'. "Adószám ABEV
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.
* Nyomtatvány azonosítók:
  CONCATENATE LW_BEVALLO_ALV-BTYPE 'A' INTO NYOMTA.
  CONCATENATE LW_BEVALLO_ALV-BTYPE 'M' INTO NYOMTM.


* Adatok összeállítása BEVALLO_ALV-ből
  PERFORM FIELDS_FROM_IT_BEVALLO_TO_KATA TABLES T_/ZAK/BEVALLALV
                                                I_/ZAK/BEVALLB
                                                LI_A_XXK102
                                                LI_M_XXK102
                                                LI_MS_XXK102.

  SORT LI_A_XXK102.
  SORT LI_MS_XXK102.

  TRY.
      CALL TRANSFORMATION /ZAK/XXK102 OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA     = NYOMTA
                                           NYOMTM     = NYOMTM
                                           BUKRSTEXT  = BUKRSTEXT
                                           ADOSZAM    = ADOSZAM
                                           I_A_XXK102  = LI_A_XXK102
                                           I_MS_XXK102 = LI_MS_XXK102
                                    RESULT XML STRING.
ENHANCEMENT-POINT /ZAK/KATA_XML_DOWN SPOTS /ZAK/FUNCTIONS_ES .

*     PERFORM display_xml USING string.
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
