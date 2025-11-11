*&---------------------------------------------------------------------*
*&  Include           /ZAK/LZOLEF01
*&---------------------------------------------------------------------*
*-----------------------------------------------------------
***INCLUDE LZTEST_OLEF01 .
*-----------------------------------------------------------
*&----------------------------------------------------------
*& Form prepare_int_tab
*&----------------------------------------------------------
* text
*-----------------------------------------------------------
* --> p1 text
* <-- p2 text
*-----------------------------------------------------------
FORM prepare_int_tab TABLES it_data
it_heading STRUCTURE line.
  CLEAR wa_line.
  IF NOT it_heading[] IS INITIAL.
    LOOP AT it_heading.
      CONCATENATE wa_line-line
      it_heading-line
      w_tab
      INTO wa_line-line.
      CONDENSE wa_line.
    ENDLOOP.
    APPEND wa_line TO it_line.
  ENDIF.
  LOOP AT it_data.
    CLEAR wa_line.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE it_data TO <fs_field>.
      IF NOT sy-subrc IS INITIAL.
        EXIT.
      ENDIF.
      w_field = <fs_field>.
      CONDENSE w_field.
      CONCATENATE wa_line-line
      w_field
      w_tab
      INTO wa_line-line.
      CONDENSE wa_line.
    ENDDO.
    APPEND wa_line TO it_line.
  ENDLOOP.

ENDFORM. " prepare_int_tab
*&----------------------------------------------------------
*& Form create_excel_sheet
*&----------------------------------------------------------
* text
*-----------------------------------------------------------
* --> p1 text
* <-- p2 text
*-----------------------------------------------------------
FORM create_excel_sheet USING p_filename
                              p_tabname
                              w_data
                     CHANGING p_file_already_exists.
  DATA:
  l_cols TYPE i,
  l_rows TYPE i,
  l_name TYPE char16,
  l_rc TYPE sy-subrc,
  l_res TYPE abap_bool,
  l_type TYPE c,
  l_file TYPE string,
  l_from TYPE ole2_object,
  l_to TYPE ole2_object,
  l_entcol TYPE ole2_object.


  CREATE OBJECT w_excel 'Excel.Application'.
  ole_error sy-subrc.

  CALL METHOD OF w_excel 'Workbooks' = w_wbooks.
  ole_error sy-subrc.
* SET PROPERTY OF w_excel 'Visible' = 1.
  ole_error sy-subrc.
  l_file = p_filename.
  CLEAR l_res.
  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file            = l_file
    RECEIVING
      result          = l_res
    EXCEPTIONS
      cntl_error      = 1
      error_no_gui    = 2
      wrong_parameter = 3
      OTHERS          = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF l_res IS INITIAL.
    CLEAR p_file_already_exists.
  ELSE.
    p_file_already_exists = 'X'.
  ENDIF.
  IF NOT p_file_already_exists IS INITIAL.

* Open the existing file in case if it exists
    CALL METHOD OF w_wbooks 'Open'
      EXPORTING
      #1 = p_filename.
    ole_error sy-subrc.

    CALL METHOD OF w_excel 'Sheets' = w_sheets.
    ole_error sy-subrc.

    CALL METHOD OF w_sheets 'Add'.
    ole_error sy-subrc.

    GET PROPERTY OF w_excel 'ActiveSheet' = w_wbook.
    ole_error sy-subrc.


  ELSE.
    CALL METHOD OF w_wbooks 'Add'. " = w_wbook.
    ole_error sy-subrc.

    GET PROPERTY OF w_excel 'ActiveSheet' = w_wbook.
    ole_error sy-subrc.

  ENDIF.

  IF NOT p_tabname IS INITIAL.

    SET PROPERTY OF w_wbook 'Name' = p_tabname.
    ole_error sy-subrc.

  ENDIF.

  CALL METHOD OF w_wbook 'Cells' = l_from
    EXPORTING
    #1 = c_bgrw
    #2 = c_bgcl.
  ole_error sy-subrc.

  DESCRIBE FIELD w_data TYPE l_type COMPONENTS l_cols.
  DESCRIBE TABLE it_line LINES l_rows.

  CALL METHOD OF w_wbook 'Cells' = l_to
    EXPORTING
    #1 = l_rows
    #2 = l_cols.
  ole_error sy-subrc.

  CALL METHOD OF w_wbook 'Range' = w_range
    EXPORTING
    #1 = l_from
    #2 = l_to.
  ole_error sy-subrc.

  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data         = it_line
    CHANGING
      rc           = l_rc
    EXCEPTIONS
      cntl_error   = 1
      error_no_gui = 2
      OTHERS       = 3.
  IF sy-subrc <> 0
  OR NOT l_rc IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    RAISING clipboard_export_error.
  ENDIF.

  CALL METHOD OF w_range 'Select'.
  ole_error sy-subrc.

  CALL METHOD OF w_wbook 'Paste'.
  ole_error sy-subrc.

  WHILE l_cols GT 0.
    l_rows = 1.
    CALL METHOD OF w_excel 'Columns' = w_cell
      EXPORTING
      #1 = l_cols.
    ole_error sy-subrc.

    CALL METHOD OF w_cell 'EntireColumn' = l_entcol.
    ole_error sy-subrc.

    l_cols = l_cols - 1.

    CALL METHOD OF l_entcol 'Autofit'.
    ole_error sy-subrc.

  ENDWHILE.

ENDFORM. " create_excel_sheet
*&----------------------------------------------------------
*& Form format_cells
*&----------------------------------------------------------
* text
*-----------------------------------------------------------
* -->P_FILENAME text
* -->P_FILE_ALREADY_EXISTS text
*-----------------------------------------------------------
FORM format_cells TABLES it_formatopt STRUCTURE /zak/formoptions
                  USING  p_filename TYPE rlgrap-filename
                         p_file_already_exists TYPE c.

  DATA:
  l_row TYPE i,
  l_col TYPE i,
  l_entcol TYPE ole2_object,
  l_cols TYPE ole2_object,
  l_comment TYPE ole2_object.

  LOOP AT it_formatopt.
    CLEAR: l_row, l_col.
    l_row = it_formatopt-row.
    l_col = it_formatopt-col.

    CALL METHOD OF w_wbook 'Cells' = w_cell
      EXPORTING
      #1 = l_row
      #2 = l_col.
    ole_error sy-subrc.

    IF NOT it_formatopt-bold IS INITIAL.
      CALL METHOD OF w_cell 'Font' = w_font.
      ole_error sy-subrc.
      SET PROPERTY OF w_font 'Bold' = 1.
      ole_error sy-subrc.
      CALL METHOD OF w_excel 'Columns' = l_cols
        EXPORTING
        #1 = l_col.
      ole_error sy-subrc.
      CALL METHOD OF l_cols 'EntireColumn' = l_entcol.
      ole_error sy-subrc.
      CALL METHOD OF l_entcol 'Autofit'.
      ole_error sy-subrc.
    ENDIF.

    IF NOT it_formatopt-color IS INITIAL.
      CALL METHOD OF w_cell 'Interior' = w_format.
      ole_error sy-subrc.
      SET PROPERTY OF w_format 'ColorIndex' = it_formatopt-color.
      ole_error sy-subrc.
      CALL METHOD OF w_excel 'Columns' = l_cols
        EXPORTING
        #1 = l_col.
      ole_error sy-subrc.
      CALL METHOD OF l_cols 'EntireColumn' = l_entcol.
      ole_error sy-subrc.
      CALL METHOD OF l_entcol 'Autofit'.
      ole_error sy-subrc.
    ENDIF.

    IF NOT it_formatopt-vert IS INITIAL.
      SET PROPERTY OF w_cell 'Orientation' = it_formatopt-vert.
      ole_error sy-subrc.
      CALL METHOD OF w_excel 'Columns' = l_cols
        EXPORTING
        #1 = l_col.
      ole_error sy-subrc.
      CALL METHOD OF l_cols 'EntireColumn' = l_entcol.
      ole_error sy-subrc.
      CALL METHOD OF l_entcol 'Autofit'.
      ole_error sy-subrc.
    ENDIF.


    IF NOT it_formatopt-comments IS INITIAL.
* CALL METHOD OF w_excel 'Range' = w_range
* EXPORTING
* #1 = l_row
* #2 = l_col.
* ole_error sy-subrc.
* CALL METHOD OF w_range 'Select'.
* ole_error sy-subrc.
      CALL METHOD OF w_cell 'AddComment' = l_comment.
      ole_error sy-subrc.
      CALL METHOD OF l_comment 'Text'
        EXPORTING
        #1 = it_formatopt-comments.
      ole_error sy-subrc.
    ENDIF.
  ENDLOOP.

ENDFORM. " format_cells
*&----------------------------------------------------------
*& Form save_and_close
*&----------------------------------------------------------
* text
*-----------------------------------------------------------
* -->P_P_FILENAME text
* -->P_P_FILE_ALREADY_EXISTS text
*-----------------------------------------------------------
FORM save_and_close USING p_filename
                          p_file_already_exists.

*  IF p_file_already_exists IS INITIAL.
  CALL METHOD OF w_wbook 'Saveas'
    EXPORTING
    #1 = p_filename.
  ole_error sy-subrc.
*  ELSE.
*    CALL METHOD OF w_excel 'ActiveWorkbook' = w_wbooks.
*    ole_error sy-subrc.
*    CALL METHOD OF w_wbooks 'Save'.
*    ole_error sy-subrc.
*  ENDIF.
  CALL METHOD OF w_wbooks 'Close'.
  ole_error sy-subrc.

ENDFORM. " save_and_close
***************Form Include Ends****************************
