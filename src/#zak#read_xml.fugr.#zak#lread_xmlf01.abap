*----------------------------------------------------------------------*
***INCLUDE /ZAK/LREAD_XMLF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_ANALITIKA  text
*      -->P_I_BUKRS  text
*      <--P_CHECK_TAB  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM CHECK_XML USING    $W_ANALITIKA LIKE W_ANALITIKA
*                        $I_BUKRS LIKE T001-BUKRS
FORM check_xml USING    $w_analitika TYPE /zak/analitika
                        $i_bukrs TYPE t001-bukrs
               CHANGING $check_tab TYPE dd03p.
*--S4HANA#01.

* Automatic check based on the conversion routine for period!
  IF $check_tab-convexit EQ 'PERI'
     AND NOT $w_analitika-field_c IS INITIAL.
    CLEAR w_return.
    CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
      EXPORTING
        input      = $w_analitika-field_c
        no_message = 'X'
      IMPORTING
*       OUTPUT     =
        return     = w_return.

    $check_tab-reptext = w_return-message.
  ENDIF.
* Check general ledger account number
  IF $check_tab-rollname EQ 'SAKNR'
     AND NOT $w_analitika-field_c IS INITIAL  .

*++S4HANA#01.
*    SELECT SINGLE * FROM SKB1
*                  WHERE BUKRS  EQ $I_BUKRS AND
*                        SAKNR  EQ $W_ANALITIKA-FIELD_C.
*    SELECT SINGLE @SPACE FROM SKB1
*            WHERE BUKRS  EQ @$I_BUKRS AND
*                  SAKNR  EQ @$W_ANALITIKA-FIELD_C INTO @GS_SKB1.
    SELECT SINGLE COUNT(*) FROM skb1   "#EC CI_DB_OPERATION_OK[2431747]
      WHERE bukrs  EQ $i_bukrs AND
                       saknr  EQ $w_analitika-field_c.
*--S4HANA#01.
    IF sy-subrc NE 0.
      $check_tab-reptext = 'Ismeretlen főkönyvi szám!'.
    ENDIF.
  ENDIF.
* Check mandatory fields!
  IF $w_analitika-field_c IS INITIAL.
    CASE $check_tab-rollname.
      WHEN 'SPBUP'       OR
           'NATSL'       OR
           'GESCH'       OR
           'PAD_CNAME'   OR
           '/ZAK/LAKCIM'  OR
           '/ZAK/ADOAZON' OR
           'HWBAS'       OR
           'DMBTR'.
        $check_tab-reptext = 'Mező megadása kötelező'.
    ENDCASE.
  ENDIF.
*  Field type validation, content validation
  CASE $check_tab-rollname.
    WHEN 'NATSL'       OR
         'GESCH'       OR
         'PAD_CNAME' .
      IF $w_analitika-field_c CO '0123456789'.

      ELSE.
        $check_tab-reptext = 'Hibás character!Numerikus nem lehet'.
      ENDIF.
* Tax number validation from HR
    WHEN '/ZAK/ADOAZON'.
* Only numeric characters are allowed
    WHEN '/ZAK/TERMELO'  OR
         '/ZAK/GAZDA'    OR
         '/ZAK/REG'.
      IF $w_analitika-field_c CO '0123456789'.

      ELSE.
        $check_tab-reptext = 'Hibás character!Csak numerikus lehet'.
      ENDIF.
* Only numeric values are allowed
    WHEN 'DMBTR'         OR
         'HWBAS'         OR
         '/ZAK/SZJA_SZAE' OR
         '/ZAK/SZJA_LEVE'.
      IF $w_analitika-field_c CO '-0123456789'.

      ELSE.
        $check_tab-reptext = 'Hibás character!Csak numerikus lehet'.
      ENDIF.
  ENDCASE.

ENDFORM.                    " CHECK_XML
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_XML_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_xml_to_table TABLES $i_data STRUCTURE w_data_line
*++S4HANA#01.
*                         USING  $FILE
*                                $SUBRC.
                         USING  $file TYPE rlgrap-filename
                                $subrc TYPE sy-subrc.
*--S4HANA#01.

  TYPES: BEGIN OF lt_xml_line,
           data(256) TYPE x,
         END OF lt_xml_line.

  DATA: l_ixml          TYPE REF TO if_ixml,
        l_streamfactory TYPE REF TO if_ixml_stream_factory,
        l_parser        TYPE REF TO if_ixml_parser,
        l_istream       TYPE REF TO if_ixml_istream,
        l_document      TYPE REF TO if_ixml_document,
        l_node          TYPE REF TO if_ixml_node,
        l_xmldata       TYPE string.

  DATA: l_elem      TYPE REF TO if_ixml_element,
        l_root_node TYPE REF TO if_ixml_node,
        l_next_node TYPE REF TO if_ixml_node,
        l_name      TYPE string,
        l_iterator  TYPE REF TO if_ixml_node_iterator.

  DATA: l_xml_table      TYPE TABLE OF lt_xml_line,
        l_xml_line       TYPE lt_xml_line,
        l_xml_table_size TYPE i.
*  DATA: L_FILENAME        TYPE STRING.
  DATA: l_filename        LIKE rlgrap-filename.

*++S4HANA#01.
  DATA lv_filename TYPE string.
  DATA lv_filetype TYPE c LENGTH 10.
*--S4HANA#01.
  CLEAR $subrc.

* Creating the main iXML factory
  CALL METHOD cl_ixml=>create
    RECEIVING
      rval = l_ixml.

* Creating a stream factory
  l_streamfactory = l_ixml->create_stream_factory( ).

  MOVE $file TO l_filename.
* ++ 0001 CST 2006.05.27
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
*  EXPORTING
*      FILENAME = L_FILENAME
*      FILETYPE = 'BIN'
*  IMPORTING
*      FILELENGTH = L_XML_TABLE_SIZE
*  CHANGING
*      DATA_TAB = L_XML_TABLE
*  EXCEPTIONS
*      FILE_OPEN_ERROR         = 1
*      FILE_READ_ERROR         = 2
*      NO_BATCH                = 3
*      GUI_REFUSE_FILETRANSFER = 4
*      INVALID_TYPE            = 5
*      NO_AUTHORITY            = 6
*      UNKNOWN_ERROR           = 7
*      BAD_DATA_FORMAT         = 8
*      HEADER_NOT_ALLOWED      = 9
*      SEPARATOR_NOT_ALLOWED   = 10
*      HEADER_TOO_LONG         = 11
*      UNKNOWN_DP_ERROR        = 12
*      ACCESS_DENIED           = 13
*      DP_OUT_OF_MEMORY        = 14
*      DISK_FULL               = 15
*      DP_TIMEOUT              = 16
*      OTHERS                  = 17.

*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27
*  CALL FUNCTION 'WS_UPLOAD'
*    EXPORTING
**   CODEPAGE                      = ' '
*      FILENAME                      = L_FILENAME
*      FILETYPE                      = 'BIN'
**   HEADLEN                       = ' '
**   LINE_EXIT                     = ' '
**   TRUNCLEN                      = ' '
**   USER_FORM                     = ' '
**   USER_PROG                     = ' '
**   DAT_D_FORMAT                  = ' '
*    IMPORTING
*      FILELENGTH                    = L_XML_TABLE_SIZE
*    TABLES
*      DATA_TAB                      = L_XML_TABLE[]
*   EXCEPTIONS
*     CONVERSION_ERROR              = 1
*     FILE_OPEN_ERROR               = 2
*     FILE_READ_ERROR               = 3
*     INVALID_TYPE                  = 4
*     NO_BATCH                      = 5
*     UNKNOWN_ERROR                 = 6
*     INVALID_TABLE_WIDTH           = 7
*     GUI_REFUSE_FILETRANSFER       = 8
*     CUSTOMER_ERROR                = 9
*     OTHERS                        = 10.

* -- 0001 CST 2006.05.27
*++S4HANA#01.
*  DATA L_FILENAME_STRING TYPE STRING.
*
*  MOVE L_FILENAME TO L_FILENAME_STRING.
  lv_filename = l_filename.
  lv_filetype = 'BIN'.
*--S4HANA#01.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
*++S4HANA#01.
*     FILENAME                = L_FILENAME_STRING
*     FILETYPE                = 'BIN'
      filename                = lv_filename
      filetype                = lv_filetype
*--S4HANA#01.
    IMPORTING
      filelength              = l_xml_table_size
    CHANGING
      data_tab                = l_xml_table[]
    EXCEPTIONS
*++S4HANA#01.
*     FILE_OPEN_ERROR         = 1
      bad_data_format         = 1
*--S4HANA#01.
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
*++S4HANA#01.
*     BAD_DATA_FORMAT         = 8
      file_open_error         = 8
*--S4HANA#01.
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27
  IF sy-subrc NE 0.
    MOVE 1 TO $subrc.
    EXIT.
  ENDIF.

* wrap the table containing the file into a stream
  l_istream = l_streamfactory->create_istream_itable(
  table = l_xml_table
  size = l_xml_table_size ).

* Creating a document
  l_document = l_ixml->create_document( ).

  l_parser = l_ixml->create_parser( stream_factory = l_streamfactory
  istream = l_istream
  document = l_document ).

* Parse the stream
  IF l_parser->parse( ) NE 0.
    IF l_parser->num_errors( ) NE 0.
      MOVE 2 TO $subrc.
      EXIT.
    ENDIF.
  ENDIF.

*   Create a Parser
  l_parser = l_ixml->create_parser( stream_factory = l_streamfactory
                                    istream        = l_istream
                                    document       = l_document ).


*   Process the document
  IF l_parser->is_dom_generating( ) EQ 'X'.
    PERFORM process_dom TABLES $i_data
                         USING l_document.
  ENDIF.




ENDFORM.                    " UPLOAD_XML_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_DATA  text
*      -->P_L_DOCUMENT  text
*----------------------------------------------------------------------*
FORM process_dom TABLES   $i_data STRUCTURE w_data_line
                 USING    document TYPE REF TO if_ixml_document.


  DATA: node     TYPE REF TO if_ixml_node,
        iterator TYPE REF TO if_ixml_node_iterator,
        nodemap  TYPE REF TO if_ixml_named_node_map,
        attr     TYPE REF TO if_ixml_node,
        name     TYPE string,
        prefix   TYPE string,
        value    TYPE string,
        count    TYPE i,
        index    TYPE i.


  node ?= document.

  CHECK NOT node IS INITIAL.

  IF node IS INITIAL. EXIT. ENDIF.
*   create a node iterator
  iterator  = node->create_iterator( ).
*   get current node
  node = iterator->get_next( ).

  CLEAR w_data_line.

*   loop over all nodes
  WHILE NOT node IS INITIAL.

    CASE node->get_type( ).
      WHEN if_ixml_node=>co_node_element.
*         element node
        name    = node->get_name( ).
        nodemap = node->get_attributes( ).
        MOVE name TO w_data_line-element.

        IF NOT nodemap IS INITIAL.
*           attributes
          count = nodemap->get_length( ).
          DO count TIMES.
            index  = sy-index - 1.
            attr   = nodemap->get_item( index ).
            name   = attr->get_name( ).
            value  = attr->get_value( ).
            MOVE name  TO w_data_line-element.
            MOVE value TO w_data_line-attrib.
          ENDDO.
        ENDIF.
      WHEN if_ixml_node=>co_node_text OR
           if_ixml_node=>co_node_cdata_section.
*       text node
        value  = node->get_value( ).
        MOVE value TO w_data_line-value.
        APPEND w_data_line TO $i_data.
        CLEAR w_data_line.
    ENDCASE.
*     advance to next node
    node = iterator->get_next( ).
  ENDWHILE.

ENDFORM.                    " PROCESS_DOM
*&---------------------------------------------------------------------*
*&      Form  process_ind_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_INDEX  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM PROCESS_IND_ITEM USING   $VALUE
*                              $INDEX
*                              $TEXT.
FORM process_ind_item USING   $value TYPE clike
                              $index TYPE sy-tabix
                              $text TYPE clike.
*--S4HANA#01.
*  Only during dialog execution
  CHECK sy-batch IS INITIAL.
  ADD 1 TO $index.
  IF $index EQ $value.
    PERFORM process_ind USING $text.
    CLEAR $index.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " process_ind_item

*&---------------------------------------------------------------------*
*&      Form  PROCESS_IND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_P01  text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM PROCESS_IND USING $TEXT.
FORM process_ind USING $text TYPE clike.
*--S4HANA#01.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE       = 0
      text = $text.

ENDFORM.                    " process_ind
