FUNCTION /ZAK/ONYB_XML_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
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

  DATA LI_A_XXA60 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_M_XXA60 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LW_XML_GEN TYPE /ZAK/XML_GEN.
  DATA LW_BEVALLO_ALV TYPE /ZAK/BEVALLALV.
  DATA NYOMTA TYPE TEXT30.
*++1665 #02.
*  DATA bukrstext TYPE text30.
  DATA BUKRSTEXT TYPE TEXT50.
*--1665 #02.
  DATA ADOSZAM   TYPE TEXT30.
  DATA IDTOL    TYPE TEXT30.
  DATA IDIG     TYPE TEXT30.
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
  ABEV = '0A0001C008'. "Vállalat ABEV xxA60-ban
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Adószám meghatározása
  ABEV = '0A0001C003'. "Adószám ABEV xxA60-ban
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.

* IDŐSZAK -tól
  ABEV = '0A0001D001'. "Adószám ABEV xxA60-ban
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDTOL = VALUE.

* IDŐSZAK -ig
  ABEV = '0A0001D002'. "Adószám ABEV xxA60-ban
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDIG = VALUE.


* Nyomtatvány azonosítók:
  MOVE LW_BEVALLO_ALV-BTYPE TO NYOMTA.


* Adatok összeállítása BEVALLO_ALV-ből
  PERFORM FIELDS_FROM_BEVALLO_TO_XXA60    TABLES T_/ZAK/BEVALLALV
                                                 I_/ZAK/BEVALLB
                                                 LI_A_XXA60
                                                 LI_M_XXA60.

  SORT LI_A_XXA60.
  SORT LI_M_XXA60.

  TRY.
      CALL TRANSFORMATION /ZAK/XXA60 OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA     = NYOMTA
                                           BUKRSTEXT  = BUKRSTEXT
                                           ADOSZAM    = ADOSZAM
                                           IDTOL      = IDTOL
                                           IDIG       = IDIG
                                           I_A_XXA60  = LI_A_XXA60
                                           I_M_XXA60  = LI_M_XXA60
                                    RESULT XML STRING.
*    PERFORM display_xml USING string.
*++20A60 #02.
*      STRING = STRING+1.
ENHANCEMENT-POINT /ZAK/ZAK_ONYB_XML_DOWN SPOTS /ZAK/FUNCTIONS_ES .
*--20A60 #02.
      CONCATENATE '<?xml version="1.0" encoding="utf-8"?>'  STRING
                  INTO STRING.
      PERFORM SAVE_KULF_XML_FILE USING STRING
                                       I_FILE.
    CATCH CX_ROOT INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE E000(/ZAK/ZAK) WITH ERROR_TEXT RAISING ERROR.
  ENDTRY.

ENDFUNCTION.
