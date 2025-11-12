FUNCTION /ZAK/AFA_XML_DOWNLOAD.
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

  DATA LI_A_XX65 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_M_XX65 TYPE TABLE OF /ZAK/XML_GEN.
  DATA LI_MS_XX65 TYPE TABLE OF  /ZAK/MS_LINEXX65.
  DATA LW_XML_GEN TYPE /ZAK/XML_GEN.
  DATA LW_BEVALLO_ALV TYPE /ZAK/BEVALLALV.
  DATA NYOMTA TYPE TEXT30.
  DATA NYOMTM TYPE TEXT30.
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
*++2065 #09.
  DATA L_BTYPE  TYPE /ZAK/BTYPE.
  DATA L_BTYPEA TYPE /ZAK/BTYPEA.
  DATA L_DATBI  TYPE DATBI.
*--2065 #09.
  READ TABLE T_/ZAK/BEVALLALV INTO LW_BEVALLO_ALV INDEX 1.

* Read declaration settings
  REFRESH I_/ZAK/BEVALLB.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  LW_BEVALLO_ALV-BTYPE.

  SORT I_/ZAK/BEVALLB.


* Determine the company name
*++1565 #01. 2015.02.09
  IF LW_BEVALLO_ALV-BTYPE EQ C_1565
*++1665 #01. 2015.02.02
  OR LW_BEVALLO_ALV-BTYPE EQ C_1665
*--1665 #01. 2015.02.02
*++1765 #01. 2017.01.31
  OR LW_BEVALLO_ALV-BTYPE EQ C_1765
*--1765 #01. 2017.01.31
*++1865 #01. 2018.01.30
  OR LW_BEVALLO_ALV-BTYPE EQ C_1865.
*--1865 #01. 2018.01.30
    ABEV = '0A0001E005'. " Company ABEV in 1565
*++1965 #01.
  ELSEIF LW_BEVALLO_ALV-BTYPE EQ C_1965
*++2065 #09.
**++2065 #01.
**  OR LW_BEVALLO_ALV-BTYPE EQ C_2065.
  OR LW_BEVALLO_ALV-BTYPE(4) EQ C_2065
**--2065 #01.
*++2165 #01.
  OR LW_BEVALLO_ALV-BTYPE(4) EQ C_2165
*--2165 #01.
*++2265 #01.
  OR LW_BEVALLO_ALV-BTYPE(4) EQ C_2265
*--2265 #01.
*++2365 #01.
  OR LW_BEVALLO_ALV-BTYPE(4) EQ C_2365
*--2365 #01.
*++2465 #01.
  OR LW_BEVALLO_ALV-BTYPE(4) EQ C_2465.
*--2465 #01.
*++2065 #09.
    ABEV = '0A0001E006'.
*--1965 #01.
*++2565 #01.
  ELSEIF LW_BEVALLO_ALV-BTYPE(4) EQ C_2565.
    ABEV = '0A0001E007'.
*--2565 #01.
  ELSE.
*--1565 #01. 2015.02.09
    ABEV = '0A0001E008'. " Company ABEV in 1365
*++1565 #01. 2015.02.09
  ENDIF.
*--1565 #01. 2015.02.09
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  BUKRSTEXT = VALUE.

* Determine the tax number
  ABEV = '0A0001E001'. " Tax number ABEV in 1365
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  ADOSZAM = VALUE.

* Period from
  ABEV = '0A0001F001'. " Tax number ABEV in 1365
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDTOL = VALUE.

* Period to
  ABEV = '0A0001F002'. " Tax number ABEV in 1365
  CLEAR VALUE.
  PERFORM GET_VALUE_BEVALLO_A TABLES T_/ZAK/BEVALLALV
                               USING ABEV
                            CHANGING VALUE.
  IDIG = VALUE.


* Form identifiers:
*++2065 #09.
*  CONCATENATE LW_BEVALLO_ALV-BTYPE 'A' INTO NYOMTA.
*  CONCATENATE LW_BEVALLO_ALV-BTYPE 'M' INTO NYOMTM.
  CONCATENATE LW_BEVALLO_ALV-GJAHR LW_BEVALLO_ALV-MONAT '01' INTO L_DATBI.
  SELECT SINGLE  BTYPEA INTO L_BTYPEA
                        FROM /ZAK/BEVALL
                       WHERE BUKRS EQ LW_BEVALLO_ALV-BUKRS
                         AND BTYPE EQ LW_BEVALLO_ALV-BTYPE
                         AND DATBI GE L_DATBI
                         AND DATAB LE L_DATBI.
  IF NOT L_BTYPEA IS INITIAL.
    L_BTYPE =  L_BTYPEA.
  ELSE.
    L_BTYPE = LW_BEVALLO_ALV-BTYPE.
  ENDIF.
  CONCATENATE L_BTYPE 'A' INTO NYOMTA.
  CONCATENATE L_BTYPE 'M' INTO NYOMTM.
*--2065 #09.

* Assemble data from BEVALLO_ALV
  PERFORM FIELDS_FROM_IT_BEVALLO_TO_XX65 TABLES T_/ZAK/BEVALLALV
                                                I_/ZAK/BEVALLB
                                                LI_A_XX65
                                                LI_M_XX65
                                                LI_MS_XX65.

  SORT LI_A_XX65.
  SORT LI_MS_XX65.

  TRY.
      CALL TRANSFORMATION /ZAK/XX65 OPTIONS XML_HEADER = 'no'
                                    SOURCE NYOMTA     = NYOMTA
                                           NYOMTM     = NYOMTM
                                           BUKRSTEXT  = BUKRSTEXT
                                           ADOSZAM    = ADOSZAM
                                           IDTOL      = IDTOL
                                           IDIG       = IDIG
                                           I_A_XX65   = LI_A_XX65
                                           I_MS_XX65  = LI_MS_XX65
                                    RESULT XML STRING.
*    PERFORM display_xml USING string.
*++2065 #03.
*      STRING = STRING+1.
ENHANCEMENT-POINT /ZAK/AFA_XML_DOWN SPOTS /ZAK/FUNCTIONS_ES .
*--2065 #03.
      CONCATENATE '<?xml version="1.0" encoding="utf-8"?>'  STRING
                  INTO STRING.
      PERFORM SAVE_KULF_XML_FILE USING STRING
                                       I_FILE.
    CATCH CX_ROOT INTO EX.
      ERROR_TEXT = EX->GET_TEXT( ).
      MESSAGE E000(/ZAK/ZAK) WITH ERROR_TEXT RAISING ERROR.
  ENDTRY.

ENDFUNCTION.
