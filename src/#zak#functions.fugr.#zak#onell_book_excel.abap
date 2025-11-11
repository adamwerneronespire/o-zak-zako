FUNCTION /ZAK/ONELL_BOOK_EXCEL .
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS OPTIONAL
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE OPTIONAL
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_MONAT) TYPE  MONAT OPTIONAL
*"     VALUE(I_INDEX) TYPE  /ZAK/INDEX OPTIONAL
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLO OPTIONAL
*"  EXCEPTIONS
*"      DATA_MISMATCH
*"      ERROR_ONELL_BOOK
*"      ERROR_DOWNLOAD_FILE
*"      EMPTY_FILE
*"      ERROR_CHANGE_BUKRS
*"----------------------------------------------------------------------

  DATA: BEGIN OF I_EXCEL OCCURS 20.
*++FI 20070213
*          INCLUDE STRUCTURE /ZAK/SZJA_EXCEL.
*++S4HANA#01.
*          INCLUDE STRUCTURE /ZAK/SZJAEXCELV2.
          INCLUDE TYPE /ZAK/SZJAEXCELV2.
*--S4HANA#01.
*--FI 20070213
  DATA: END OF I_EXCEL.

  DATA: V_SUBRC LIKE SY-SUBRC.

  IF NOT T_BEVALLO[] IS INITIAL.
*   Adatkonzisztencia ellenőrzése
    IF NOT I_BUKRS IS INITIAL AND
       NOT I_BTYPE IS INITIAL AND
       NOT I_GJAHR IS INITIAL AND
       NOT I_MONAT IS INITIAL AND
       NOT I_INDEX IS INITIAL.
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
    ENDIF.
  ELSE.
*   Ha bármelyik paraméter üres hiba
    IF I_BUKRS IS INITIAL OR
       I_BTYPE IS INITIAL OR
       I_GJAHR IS INITIAL OR
       I_MONAT IS INITIAL OR
       I_INDEX IS INITIAL.
      RAISE DATA_MISMATCH.
      V_SUBRC = 4.
    ELSE.
      SELECT * INTO TABLE T_BEVALLO FROM  /ZAK/BEVALLO
             WHERE  BUKRS   = I_BUKRS
             AND    BTYPE   = I_BTYPE
             AND    GJAHR   = I_GJAHR
             AND    MONAT   = I_MONAT
             AND    ZINDEX  = I_INDEX
*++S4HANA#01.
        ORDER BY PRIMARY KEY.
*--S4HANA#01.
    ENDIF.
  ENDIF.

  CHECK V_SUBRC IS INITIAL.

* BEVALLO első sora
  READ TABLE T_BEVALLO INTO W_/ZAK/BEVALLO INDEX 1.

* Adatok meghatározása
*++FI 20070213
*   PERFORM GET_DATA_ONELL TABLES T_BEVALLO
*                                I_EXCEL
*                         USING  W_/ZAK/BEVALLO
*                                V_SUBRC.

*++BG 2008.04.16
* Vállalat forgatás
  CALL FUNCTION '/ZAK/ROTATE_BUKRS_OUTPUT'
    EXPORTING
      I_AD_BUKRS    = W_/ZAK/BEVALLO-BUKRS
    IMPORTING
      E_FI_BUKRS    = W_/ZAK/BEVALLO-BUKRS
    EXCEPTIONS
      MISSING_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
    RAISE ERROR_CHANGE_BUKRS.
  ENDIF.
*--BG 2008.04.16

  PERFORM GET_DATA_ONELL_V2 TABLES T_BEVALLO
                                I_EXCEL
                         USING  W_/ZAK/BEVALLO
*++S4HANA#01.
*                               V_SUBRC.
                       CHANGING V_SUBRC.
*--S4HANA#01.
*--FI 20070213

* Önellenőrzési pótlék beállítás hiba
  IF V_SUBRC EQ 4.
    RAISE ERROR_ONELL_BOOK.
  ENDIF.

* Nincs adat nem töltünk le semmit
  IF I_EXCEL[] IS INITIAL.
    RAISE EMPTY_FILE.
  ENDIF.


ENHANCEMENT-POINT /ZAK/ZAK_TELEKOM_ONELL_BOOK SPOTS /ZAK/FUNCTIONS_ES .


* Excel fájl készítése
  PERFORM DOWNLOAD_FILE_ONELL TABLES I_EXCEL
                              USING  W_/ZAK/BEVALLO
*++S4HANA#01.
*                                    V_SUBRC.
                           CHANGING  V_SUBRC.
*--S4HANA#01.

  IF NOT V_SUBRC IS INITIAL.
    RAISE ERROR_DOWNLOAD_FILE.
  ENDIF.

ENDFUNCTION.
