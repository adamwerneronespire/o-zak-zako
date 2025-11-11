FUNCTION /ZAK/POST_ADONSZA.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_MONAT) TYPE  MONAT
*"     VALUE(I_INDEX) TYPE  /ZAK/INDEX
*"     VALUE(I_TESZT) TYPE  XFELD OPTIONAL
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLO
*"      T_ADONSZA STRUCTURE  /ZAK/ADONSZA OPTIONAL
*"  EXCEPTIONS
*"      DATA_MISMATCH
*"      OTHER_ERROR
*"----------------------------------------------------------------------
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    -----------------------------------
*& 0001   2008.05.05   Balázs Gábor  Teszt mód beépítése, ebben az
*&                                   esetben nem lesz könyvelés csak
*&                                   visszadja az értékeket az önell.
*&                                   jegyzőkönyv miatt.
*"----------------------------------------------------------------------


  DATA V_SUBRC LIKE SY-SUBRC.
  DATA V_BTYPE_CONV LIKE /ZAK/BEVALL-BTYPE.


* Átvezetéses BTYPE-ok összegyűjtéséhez
  RANGES R_ATV_BTYPE FOR /ZAK/BEVALL-BTYPE.

* Adatkonzisztencia ellenőrzése
  LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO.
    CHECK W_/ZAK/BEVALLO-BUKRS  NE I_BUKRS OR
          W_/ZAK/BEVALLO-BTYPE  NE I_BTYPE OR
          W_/ZAK/BEVALLO-GJAHR  NE I_GJAHR OR
          W_/ZAK/BEVALLO-MONAT  NE I_MONAT OR
          W_/ZAK/BEVALLO-ZINDEX NE I_INDEX.
    RAISE DATA_MISMATCH.
    V_SUBRC = 4.
    EXIT.
  ENDLOOP.

  CHECK V_SUBRC IS INITIAL.

* Nyomtatvány adatok beolvasása
  PERFORM READ_BEVALLB_M USING I_BTYPE.

* T_BEVALLO értelmezése, adófolyószámla adatok meghatározása
* adatbázis módosítás
  PERFORM CONVERT_BEVALLO_ADONSZA TABLES T_BEVALLO
*++0001 BG 2008.05.05 /ZAK/_POST_ADONSZA
                                         T_ADONSZA
*--0001 BG 2008.05.05 /ZAK/_POST_ADONSZA
                                         I_/ZAK/BEVALLB
                                         R_ATV_BTYPE
                                  USING  I_BUKRS
                                         I_BTYPE
                                         I_GJAHR
                                         I_MONAT
                                         I_INDEX
*++0001 BG 2008.05.05 /ZAK/_POST_ADONSZA
                                         I_TESZT
*--0001 BG 2008.05.05 /ZAK/_POST_ADONSZA
                                         V_BTYPE_CONV
                                         V_SUBRC
                                         .
* ++CST 2006.06.04
  IF V_SUBRC NE 0.
    RAISE OTHER_ERROR.
  ENDIF.
* --CST 2006.06.04
ENDFUNCTION.
