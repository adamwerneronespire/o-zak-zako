FUNCTION /ZAK/KULF_FILE_DOWNLOAD.
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

  DATA LI_A_XXK79 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_M_XXK79 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_MS_XXK79 TYPE TABLE OF  /ZAK/MSLINEXXK79.
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
  ABEV = '0A0001C004'. "Vállalat ABEV 11K79-ben
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Adószám meghatározása
*++19K79 #01.
*  ABEV = '0A0001C002'. "Adószám ABEV 11K79-ben
  ABEV = '0A0001C001'. "Adószám ABEV
*--19K79 #01.
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.
* Nyomtatvány azonosítók:
*++2208 #01.
  DATA L_BTYPEA TYPE /ZAK/BTYPEA.
  DATA L_DATBI  TYPE DATBI.

  CONCATENATE LW_BEVALLO_ALV-GJAHR LW_BEVALLO_ALV-MONAT '01' INTO L_DATBI.
  SELECT SINGLE  BTYPEA INTO L_BTYPEA
                        FROM /ZAK/BEVALL
                       WHERE BUKRS EQ LW_BEVALLO_ALV-BUKRS
                         AND BTYPE EQ LW_BEVALLO_ALV-BTYPE
                         AND DATBI GE L_DATBI
                         AND DATAB LE L_DATBI.
  IF SY-SUBRC EQ 0 AND NOT L_BTYPEA IS INITIAL.
    LW_BEVALLO_ALV-BTYPE =  L_BTYPEA.
  ENDIF.
*--2208 #01.
  CONCATENATE LW_BEVALLO_ALV-BTYPE 'A' INTO NYOMTA.
  CONCATENATE LW_BEVALLO_ALV-BTYPE 'M' INTO NYOMTM.


* Adatok összeállítása BEVALLO_ALV-ből
  PERFORM FIELDS_FROM_IT_BEVALLO_TO_KULF TABLES T_/ZAK/BEVALLALV
                                                I_/ZAK/BEVALLB
                                                LI_A_XXK79
                                                LI_M_XXK79
                                                LI_MS_XXK79.

  SORT LI_A_XXK79.
  SORT LI_MS_XXK79.

  TRY.
      CALL TRANSFORMATION /ZAK/XXK79 OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA     = NYOMTA
                                           NYOMTM     = NYOMTM
                                           BUKRSTEXT  = BUKRSTEXT
                                           ADOSZAM    = ADOSZAM
                                           I_A_XXK79  = LI_A_XXK79
                                           I_MS_XXK79 = LI_MS_XXK79
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
