FUNCTION /ZAK/ATV_BOOK_EXCEL.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_MONAT) TYPE  MONAT
*"     REFERENCE(I_INDEX) TYPE  /ZAK/INDEX
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLO OPTIONAL
*"  EXCEPTIONS
*"      DATA_MISMATCH
*"      DOWNLOAD_FAILED
*"----------------------------------------------------------------------
*  A new posting Excel was created, so the new format is required
*
*++S4HANA#01.
*data: begin of i_lines occurs 20.
*        INCLUDE STRUCTURE /zak/atvez_sor.
*DATA: END OF I_lines.
  TYPES: TT_I_LINES TYPE STANDARD TABLE OF /ZAK/ATVEZ_SOR INITIAL SIZE 20.
  DATA LS_I_LINES TYPE /ZAK/ATVEZ_SOR.
  DATA: LT_I_LINES TYPE TT_I_LINES.
*--S4HANA#01.

  DATA: BEGIN OF I_EXCEL OCCURS 20.
*++S4HANA#01.
*          INCLUDE STRUCTURE /ZAK/ATV_EXCELN.
          INCLUDE TYPE /ZAK/ATV_EXCELN.
*--S4HANA#01.
  DATA: END OF I_excel.


*++S4HANA#01.
*  DATA: V_ERROR.
  DATA: V_ERROR TYPE C.
*--S4HANA#01.

  IF NOT T_BEVALLO[] IS INITIAL.

* Data consistency check
    LOOP AT T_BEVALLO INTO W_/ZAK/BEVALLO.
      CHECK W_/ZAK/BEVALLO-BUKRS  NE I_BUKRS OR
            W_/ZAK/BEVALLO-BTYPE  NE I_BTYPE OR
            W_/ZAK/BEVALLO-GJAHR  NE I_GJAHR OR
            W_/ZAK/BEVALLO-MONAT  NE I_MONAT OR
            W_/ZAK/BEVALLO-ZINDEX NE I_INDEX.

      MESSAGE E147(/ZAK/ZAK) RAISING DATA_MISMATCH.
      V_ERROR = 'X'.
      EXIT.
    ENDLOOP.

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


  CHECK V_ERROR = SPACE.

* Read form data
  PERFORM READ_BEVALLB_m USING i_BTYPE.


* Interpret T_BEVALLO and convert to /ZAK/ATVEZ_SOR,
*                                  then into /ZAK/ATVEZ_EXCEL format
*++FI 20070213
* The new Excel structure had to be reverted because the old one is needed for this (vendor) posting
  PERFORM CONVERT_BEVALLO_NEW TABLES T_BEVALLO
                                 I_EXCEL
                          USING I_BUKRS.
*   perform convert_bevallo_v2 tables t_bevallo
*                                  i_excel
*                           using i_bukrs.
*--FI 20070213
* Create Excel file
*++FI 20070213
* The new Excel structure had to be reverted because the old one is needed for this (vendor) posting
  PERFORM DOWNLOAD_FILE TABLES I_EXCEL
                        USING I_BUKRS
                              I_BTYPE
                        CHANGING V_ERROR.
*  perform download_file_v2 tables i_excel
*                        using i_bukrs
*                              i_btype
*                        changing v_error.

*--FI 20070213
  IF V_ERROR NE SPACE.
    MESSAGE E148(/ZAK/ZAK) RAISING DOWNLOAD_FAILED.
  ENDIF.
ENDFUNCTION.
