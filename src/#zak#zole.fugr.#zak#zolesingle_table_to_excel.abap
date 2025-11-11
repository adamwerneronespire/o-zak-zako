FUNCTION /zak/zolesingle_table_to_excel.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(FILENAME) TYPE  RLGRAP-FILENAME
*"     VALUE(TABNAME) TYPE  CHAR30 OPTIONAL
*"  TABLES
*"      T_DATA
*"      T_HEADING STRUCTURE  LINE OPTIONAL
*"      T_FORMATOPT STRUCTURE  /ZAK/FORMOPTIONS OPTIONAL
*"  EXCEPTIONS
*"      OLE_ERROR
*"      DATA_EMPTY
*"      CLIPBOARD_EXPORT_ERROR
*"----------------------------------------------------------------------
  DATA:
  file_already_exists TYPE c.

  IF t_data[] IS INITIAL.
    MESSAGE e899(v1) WITH 'No Data in the internal table'(001)
    RAISING data_empty.
  ENDIF.

  ASSIGN w_tab TO <fs_hex> TYPE 'X'.
  <fs_hex> = c_tab.

  REFRESH it_line.

  PERFORM prepare_int_tab TABLES t_data
                                 t_heading.

  PERFORM create_excel_sheet USING filename
                                   tabname
                                   t_data
                          CHANGING file_already_exists.

  IF NOT t_formatopt[] IS INITIAL.
    PERFORM format_cells TABLES t_formatopt
                          USING filename
                                file_already_exists.
  ENDIF.


  PERFORM save_and_close USING filename
                               file_already_exists.


ENDFUNCTION.
