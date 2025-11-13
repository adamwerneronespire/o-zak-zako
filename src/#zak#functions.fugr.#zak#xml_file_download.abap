FUNCTION /ZAK/XML_FILE_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
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
* A funkciós elem alpját a HR-ben létrehozott RPLHBXH0 program képzi,
* mivel az XML letöltést ott is meg kellett valósítani, ezért a változók
* szemantikai tulajdonságai si ehhez a programhoz igazodnak.

*++BG 2006/09/29 Az APEH az XML fájl előállítás átalakította:
*az új program amivel az XML fájl előáll RPLVAXH0
*az űrlapok a T5HVX táblában találhatók időfüggően
*--BG 2006/09/29
*++0908/2 2009.08.04 BG
* T5HSV -> /ZAK/ZAK_T5HSV
* T5HVX -> /ZAK/T5HVX
* T5HS7 -> /ZAK/T5HS7
* Másoló program : /ZAK/GET_T5HV_TABLES_FROM_HR
*--0908/2 2009.08.04 BG


* XML sorokat tartalmazó tábla
  DATA: IT_XML_DATA TYPE TTY_XML_TABLE.
  TYPES: BEGIN OF T_ADOAZON,
         ADOAZON TYPE /ZAK/ADOAZON,
         END OF T_ADOAZON.

* Adószámok gyűjtéséhez
  DATA I_ADOAZON TYPE HASHED TABLE OF T_ADOAZON WITH UNIQUE KEY ADOAZON
                                                INITIAL SIZE 0.
  DATA W_ADOAZON TYPE T_ADOAZON.

* 'A'-s abev azonosítók
  DATA I_/ZAK/BEVALLALV_A LIKE /ZAK/BEVALLALV OCCURS 0
                           WITH HEADER LINE.
* INDEX mentése
  DATA V_INDEX_SAVE LIKE SY-TABIX VALUE 1.
  DATA V_MAX_LINE   TYPE I.
  DATA L_INDEX TYPE SY-TABIX.


*++BG 2006/09/29
  DATA V_BEV_DAT LIKE SY-DATUM.
* Meghatározzuk a bevallás első napját
  IF NOT I_GJAHR IS INITIAL AND NOT I_MONAT IS INITIAL.
    CONCATENATE I_GJAHR I_MONAT '01' INTO V_BEV_DAT.
  ELSE.
    MESSAGE E198(/ZAK/ZAK) RAISING ERROR_IMP_PAR.
*   Hiányzó import paraméter XML fájl letöltéshez! (Év vagy Hónap)
  ENDIF.
*--BG 2006/09/29

* formulárok beolvasása
* PERFORM READ_FORMS.
  PERFORM READ_FORMS_N USING V_BEV_DAT.


* Tábla rendezése
  SORT T_/ZAK/BEVALLALV BY ADOAZON LAPSZ ABEVAZ.


* Adóazonosítók meghatározása
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
* Bevallások beállításának beolvasása
  REFRESH I_/ZAK/BEVALLB.
  SELECT * INTO TABLE I_/ZAK/BEVALLB
           FROM /ZAK/BEVALLB
          WHERE BTYPE EQ  T_/ZAK/BEVALLALV-BTYPE.
  SORT I_/ZAK/BEVALLB.
*--0808 BG 2008.02.07

  SORT I_ADOAZON BY ADOAZON.

* XML fájl előállítása
* XML-header előállítása
  PERFORM CREATE_XML_HEADER TABLES GT_XFORM0 IT_XML_DATA.

* <ÉV>08A nyomtatvány
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
* <ÉV>08M előállítása munkavállalónként
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


* XML-footer előállítása
  PERFORM CREATE_XML_FOOTER TABLES GT_XFORM1 IT_XML_DATA.


* XML-fájl kiírása
  PERFORM SAVE_XML_FILE TABLES IT_XML_DATA
                        USING  I_FILE.



ENDFUNCTION.
