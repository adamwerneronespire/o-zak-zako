FUNCTION /ZAK/XML_FILE_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_FILE) TYPE  STRING
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_MONAT) TYPE  MONAT OPTIONAL
*"  TABLES
*"      T_/ZAK/BEVALLALV STRUCTURE  /ZAK/BEVALLALV OPTIONAL
*"  EXCEPTIONS
*"      ERROR_DOWNLOAD
*"      ERROR_IMP_PAR
*"----------------------------------------------------------------------
* The functional element is based on the RPLHBXH0 program created in HR,
* because the XML download also had to be implemented there, so the
* semantic properties of the variables follow that program.

*++BG 2006/09/29 The tax authority changed the XML file generation:
*the new program that generates the XML file is RPLVAXH0
*the forms are stored in table T5HVX with time dependency
*--BG 2006/09/29
*++0908/2 2009.08.04 BG
* T5HSV -> /ZAK/ZAK_T5HSV
* T5HVX -> /ZAK/T5HVX
* T5HS7 -> /ZAK/T5HS7
* Copy program : /ZAK/GET_T5HV_TABLES_FROM_HR
*--0908/2 2009.08.04 BG


* Table containing XML rows
  DATA: IT_XML_DATA TYPE TTY_XML_TABLE.
  TYPES: BEGIN OF T_ADOAZON,
         ADOAZON TYPE /ZAK/ADOAZON,
         END OF T_ADOAZON.

* For collecting tax numbers
  DATA I_ADOAZON TYPE HASHED TABLE OF T_ADOAZON WITH UNIQUE KEY ADOAZON
                                                INITIAL SIZE 0.
  DATA W_ADOAZON TYPE T_ADOAZON.

* 'A' ABEV identifiers
  DATA I_/ZAK/BEVALLALV_A LIKE /ZAK/BEVALLALV OCCURS 0
                           WITH HEADER LINE.
* Saving index
  DATA V_INDEX_SAVE LIKE SY-TABIX VALUE 1.
  DATA V_MAX_LINE   TYPE I.
  DATA L_INDEX TYPE SY-TABIX.


*++BG 2006/09/29
  DATA V_BEV_DAT LIKE SY-DATUM.
* Determine the first day of the declaration
  IF NOT I_GJAHR IS INITIAL AND NOT I_MONAT IS INITIAL.
    CONCATENATE I_GJAHR I_MONAT '01' INTO V_BEV_DAT.
  ELSE.
    MESSAGE E198(/ZAK/ZAK) RAISING ERROR_IMP_PAR.
*   Missing import parameter for XML file download! (Year or Month)
  ENDIF.
*--BG 2006/09/29

* Read forms
* PERFORM READ_FORMS.
  PERFORM READ_FORMS_N USING V_BEV_DAT.


* Sort table
  SORT T_/ZAK/BEVALLALV BY ADOAZON LAPSZ ABEVAZ.


* Determine tax identifiers
  REFRESH I_ADOAZON.
  LOOP AT T_/ZAK/BEVALLALV.
    MOVE T_/ZAK/BEVALLALV-ADOAZON TO W_ADOAZON.
    AT NEW ADOAZON.
      IF NOT W_ADOAZON IS INITIAL.
        COLLECT W_ADOAZON INTO I_ADOAZON.
      ENDIF.
    ENDAT.

    IF T_/ZAK/BEVALLALV-ABEVAZ(1) EQ 'A'.
      APPEND T_/ZAK/BEVALLALV TO I_/ZAK/BEVALLALV_A.
    ENDIF.

*    CHECK NOT T_/ZAK/BEVALLALV-ADOAZON IS INITIAL.
*    MOVE T_/ZAK/BEVALLALV-ADOAZON TO W_ADOAZON.
*    COLLECT W_ADOAZON INTO I_ADOAZON.
  ENDLOOP.
*++0808 BG 2008.02.07
* Read declaration configuration
  REFRESH I_/ZAK/BEVALLB.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  T_/ZAK/BEVALLALV-BTYPE.
  SORT I_/ZAK/BEVALLB.
*--0808 BG 2008.02.07

  SORT I_ADOAZON BY ADOAZON.

* Generate XML file
* Generate XML header
  PERFORM CREATE_XML_HEADER TABLES GT_XFORM0 IT_XML_DATA.

* <YEAR>08A form
  PERFORM CREATE_SZJA_A TABLES GT_XFORM2
                               GT_XFORM3
                               T_/ZAK/BEVALLALV
                               IT_XML_DATA
                               I_/ZAK/BEVALLALV_A
*++0808 BG 2008.02.07
                               I_/ZAK/BEVALLB
*--0808 BG 2008.02.07

*++BG 2006/09/29
                         USING V_BEV_DAT.
*--BG 2006/09/29
  CLEAR L_INDEX.
* Generate <YEAR>08M per employee
  LOOP AT I_ADOAZON INTO W_ADOAZON.
    PERFORM PROCESS_IND_ITEM USING '10000'
                                    L_INDEX
                                    TEXT-P10.
    PERFORM CREATE_SZJA_M TABLES GT_XFORM4
                                 GT_XFORM3
                                 T_/ZAK/BEVALLALV
                                 IT_XML_DATA
                                 I_/ZAK/BEVALLALV_A
*++0808 BG 2008.02.07
                                 I_/ZAK/BEVALLB
*--0808 BG 2008.02.07

                         USING   W_ADOAZON
                                 V_INDEX_SAVE
                                 V_MAX_LINE
*++BG 2006/09/29
                                 V_BEV_DAT.
*--BG 2006/09/29
  ENDLOOP.


* Generate XML footer
  PERFORM CREATE_XML_FOOTER TABLES GT_XFORM1 IT_XML_DATA.


* Write XML file
  PERFORM SAVE_XML_FILE TABLES IT_XML_DATA
                        USING  I_FILE.



ENDFUNCTION.
