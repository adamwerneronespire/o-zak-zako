FUNCTION /ZAK/SZJA_XML_DOWNLOAD.
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

  DATA LI_A_XX08 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_M_XX08 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_MS_XX08 TYPE TABLE OF  /ZAK/MS_LINEXX08.
  DATA LW_XML_GEN TYPE /ZAK/XML_GEN.
  DATA LW_BEVALLO_ALV TYPE /ZAK/BEVALLALV.
  DATA NYOMTA TYPE TEXT30.
  DATA NYOMTM TYPE TEXT30.
*++1608 #02. 2015.02.10
*  DATA bukrstext TYPE text30.
*++1808 #05.
*  DATA bukrstext TYPE text50.
  DATA BUKRSTEXT TYPE TEXT70.
*--1808 #05.
*--1608 #02. 2015.02.10
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
  IF LW_BEVALLO_ALV-BTYPE EQ C_2508.
    ABEV = '0A0001C013'. "Vállalat ABEV 2508-ban
  ELSE.
*--2508 #03.
    ABEV = '0A0001C014'. "Vállalat ABEV 1408-ban
*++2508 #03.
  ENDIF.
*--2508 #03.
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Adószám meghatározása
  ABEV = '0A0001C002'. "Adószám ABEV 1408-ban
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.

* IDŐSZAK -tól
*++2208 #03.
  IF LW_BEVALLO_ALV-BTYPE EQ C_2208
*++2308 #02.
     OR LW_BEVALLO_ALV-BTYPE EQ C_2308
*--2308 #02.
*++2408 #01.
     OR LW_BEVALLO_ALV-BTYPE EQ C_2408.
*--2408 #01.
    ABEV = '0A0001C028'. "IDŐSZAK -tól
*++2508 #03.
  ELSEIF LW_BEVALLO_ALV-BTYPE EQ C_2508.
*--2508 #03.
    ABEV = '0A0001C027'. "IDŐSZAK -tól
  ELSE.
*--2208 #03.
    ABEV = '0A0001C039'. "IDŐSZAK-tól ABEV 1408-ban
*++2208 #03.
  ENDIF.
*--2208 #03.
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDTOL = VALUE.
*++2208 #03.
  IF LW_BEVALLO_ALV-BTYPE EQ C_2208
*++2308 #02.
     OR LW_BEVALLO_ALV-BTYPE EQ C_2308
*--2308 #02.
*++2408 #01.
     OR LW_BEVALLO_ALV-BTYPE EQ C_2408.
*--2408 #01.
    ABEV = '0A0001C029'. "IDŐSZAK -ig
*++2508 #03.
  ELSEIF LW_BEVALLO_ALV-BTYPE EQ C_2508.
    ABEV = '0A0001C028'. "IDŐSZAK -ig
*--2508 #03.
  ELSE.
*--2208 #03.
* IDŐSZAK -ig
    ABEV = '0A0001C040'. "IDŐSZAK-ig ABEV 1408-ban
*++2208 #03.
  ENDIF.
*--2208 #03.
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDIG = VALUE.


* Nyomtatvány azonosítók:
  CONCATENATE LW_BEVALLO_ALV-BTYPE 'A' INTO NYOMTA.
  CONCATENATE LW_BEVALLO_ALV-BTYPE 'M' INTO NYOMTM.


* Adatok összeállítása BEVALLO_ALV-ből
  PERFORM FIELDS_FROM_IT_BEVALLO_TO_XX08 TABLES T_/ZAK/BEVALLALV
                                                I_/ZAK/BEVALLB
                                                LI_A_XX08
                                                LI_M_XX08
                                                LI_MS_XX08.

  SORT LI_A_XX08.
  SORT LI_MS_XX08.

  TRY.
      CALL TRANSFORMATION /ZAK/XX08 OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA     = NYOMTA
                                           NYOMTM     = NYOMTM
                                           BUKRSTEXT  = BUKRSTEXT
                                           ADOSZAM    = ADOSZAM
                                           IDTOL      = IDTOL
                                           IDIG       = IDIG
                                           I_A_XX08   = LI_A_XX08
                                           I_MS_XX08  = LI_MS_XX08
                                    RESULT XML STRING.
*    PERFORM display_xml USING string.
*++2008 #03.
*      STRING = STRING+1.
ENHANCEMENT-POINT /ZAK/SZJA_XML_DOWN SPOTS /ZAK/FUNCTIONS_ES .
*--2008 #03.
      CONCATENATE '<?xml version="1.0" encoding="utf-8"?>'  STRING
                  INTO STRING.
      PERFORM SAVE_KULF_XML_FILE USING STRING
                                       I_FILE.
    CATCH CX_ROOT INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE E000(/ZAK/ZAK) WITH ERROR_TEXT RAISING ERROR.
  ENDTRY.
ENDFUNCTION.
