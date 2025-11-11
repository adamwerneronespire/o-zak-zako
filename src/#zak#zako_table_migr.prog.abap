*&---------------------------------------------------------------------*
*& Report  /ZAK/ZAKO_TABLE_MIGR
*&---------------------------------------------------------------------*
*& Copies data from one table to another using mapping table /ZAK/MAP.
*&---------------------------------------------------------------------*
REPORT /zak/zako_table_migr.

TABLES: /zak/map.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  SELECT-OPTIONS so_table FOR /zak/map-obj_name.
  PARAMETERS      p_commit TYPE i DEFAULT 1000.
SELECTION-SCREEN END OF BLOCK b1.

TYPES: BEGIN OF ty_map,
         obj_name     TYPE /zak/map-obj_name,
         new_obj_name TYPE /zak/map-new_obj_name,
       END OF ty_map.
TYPES tt_map TYPE STANDARD TABLE OF ty_map WITH DEFAULT KEY.

" F4 segítséghez: egymezős struktúra az OBJ_NAME-hez
TYPES: BEGIN OF ty_shlp_map,
         obj_name TYPE /zak/map-obj_name,
       END OF ty_shlp_map.

TYPES: BEGIN OF ty_stat,
         src_tab   TYPE tabname,
         dst_tab   TYPE tabname,
         src_count TYPE i,
         dst_count TYPE i,
       END OF ty_stat.
TYPES tt_stat TYPE STANDARD TABLE OF ty_stat WITH DEFAULT KEY.
TYPES tr_obj_name TYPE RANGE OF /zak/map-obj_name.
TYPES ty_so_line  LIKE LINE OF so_table.
TYPES ty_so_table TYPE STANDARD TABLE OF ty_so_line WITH DEFAULT KEY.

CLASS lcl_so_table_shlp DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS show
      CHANGING cv_value TYPE /zak/map-obj_name.
ENDCLASS.

CLASS lcl_so_table_shlp IMPLEMENTATION.
  METHOD show.
    DATA lt_map TYPE STANDARD TABLE OF ty_shlp_map WITH DEFAULT KEY.
    DATA ls_map TYPE ty_shlp_map.
    CLEAR lt_map.
    SELECT map~obj_name
      INTO ls_map-obj_name
      FROM /zak/map AS map
      INNER JOIN dd02l AS d
        ON d~tabname = map~obj_name
      WHERE map~object = 'TABL'
        AND d~as4local = 'A'
        AND d~tabclass = 'TRANSP'.
      APPEND ls_map TO lt_map.
    ENDSELECT.
    DATA lt_return TYPE STANDARD TABLE OF ddshretval WITH DEFAULT KEY.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield   = 'OBJ_NAME'
        value_org  = 'S'
      TABLES
        value_tab  = lt_map
        return_tab = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc = 0.
      DATA ls_return TYPE ddshretval.
      READ TABLE lt_return INTO ls_return INDEX 1.
      IF sy-subrc = 0.
        cv_value = ls_return-fieldval.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_map_repository DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING i_tablesel TYPE ty_so_table.
    METHODS get_mapping
      RETURNING VALUE(rt_map) TYPE tt_map.
  PRIVATE SECTION.
    DATA mt_sel TYPE ty_so_table.
ENDCLASS.

CLASS lcl_map_repository IMPLEMENTATION.
  METHOD constructor.
    mt_sel = i_tablesel.
  ENDMETHOD.

  METHOD get_mapping.
    DATA lt_tmp TYPE tt_map.
    CLEAR lt_tmp.
    SELECT obj_name new_obj_name
      INTO TABLE lt_tmp
      FROM /zak/map
      WHERE object = 'TABL'
        AND obj_name IN mt_sel.
    rt_map = lt_tmp.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_table_validator DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS is_valid
      IMPORTING iv_tabname   TYPE tabname
      RETURNING VALUE(rv_ok) TYPE abap_bool.
ENDCLASS.

CLASS lcl_table_validator IMPLEMENTATION.
  METHOD is_valid.
    DATA lv_tabclass TYPE dd02l-tabclass.
    SELECT SINGLE tabclass INTO lv_tabclass
      FROM dd02l
      WHERE tabname  = iv_tabname
        AND as4local = 'A'.
    IF sy-subrc = 0 AND lv_tabclass = 'TRANSP'.
      rv_ok = abap_true.
    ELSE.
      rv_ok = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_table_transformer DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor IMPORTING iv_commit TYPE i DEFAULT 1000.
    METHODS transfer
      IMPORTING iv_source TYPE tabname
                iv_target TYPE tabname.
  PRIVATE SECTION.
    DATA mv_commit TYPE i.
ENDCLASS.

CLASS lcl_table_transformer IMPLEMENTATION.
  METHOD constructor.
    mv_commit = iv_commit.
  ENDMETHOD.

  METHOD transfer.
    DATA: lr_src_data TYPE REF TO data.
    FIELD-SYMBOLS:
      <lt_src> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_src> TYPE ANY.
    " Dinamikus belső tábla létrehozása a forrástábla sorstruktúrájából
    CREATE DATA lr_src_data TYPE STANDARD TABLE OF (iv_source).
    ASSIGN lr_src_data->* TO <lt_src>.

    SELECT * INTO TABLE <lt_src> FROM (iv_source).

    DATA lv_counter TYPE i.
    lv_counter = 0.

    LOOP AT <lt_src> ASSIGNING <ls_src>.
      MODIFY (iv_target) FROM <ls_src>.
      lv_counter = lv_counter + 1.

      IF lv_counter >= mv_commit.
        COMMIT WORK AND WAIT.
        lv_counter = 0.
      ENDIF.
    ENDLOOP.

    IF lv_counter <> 0.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_migration_log DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS add
      IMPORTING iv_src     TYPE tabname
                iv_dst     TYPE tabname
                iv_src_cnt TYPE i
                iv_dst_cnt TYPE i.
    METHODS display.
  PRIVATE SECTION.
    DATA mt_stat TYPE tt_stat.
ENDCLASS.

CLASS lcl_migration_log IMPLEMENTATION.
  METHOD add.
    DATA ls_stat TYPE ty_stat.
    ls_stat-src_tab = iv_src.
    ls_stat-dst_tab = iv_dst.
    ls_stat-src_count = iv_src_cnt.
    ls_stat-dst_count = iv_dst_cnt.
    APPEND ls_stat TO mt_stat.
  ENDMETHOD.

  METHOD display.
    DATA lo_salv TYPE REF TO cl_salv_table.
    DATA lo_cols TYPE REF TO cl_salv_columns_table.
    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_salv
          CHANGING t_table = mt_stat ).
      CATCH cx_salv_msg.
        RETURN.
    ENDTRY.
    lo_cols = lo_salv->get_columns( ).
    lo_cols->set_optimize( ).
    lo_salv->display( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_table_migrator DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repo        TYPE REF TO lcl_map_repository
        io_validator   TYPE REF TO lcl_table_validator
        io_transformer TYPE REF TO lcl_table_transformer
        io_log         TYPE REF TO lcl_migration_log.
    METHODS run.
  PRIVATE SECTION.
    DATA: mo_repo        TYPE REF TO lcl_map_repository,
          mo_validator   TYPE REF TO lcl_table_validator,
          mo_transformer TYPE REF TO lcl_table_transformer,
          mo_log         TYPE REF TO lcl_migration_log.
ENDCLASS.

CLASS lcl_table_migrator IMPLEMENTATION.
  METHOD constructor.
    mo_repo        = io_repo.
    mo_validator   = io_validator.
    mo_transformer = io_transformer.
    mo_log         = io_log.
  ENDMETHOD.

  METHOD run.
    DATA lt_map TYPE tt_map.
    FIELD-SYMBOLS <ls_map> TYPE ty_map.
    DATA lv_src TYPE i.
    DATA lv_dst TYPE i.
    DATA lv_tab TYPE tabname.
    DATA lv_src_tab TYPE tabname.
    DATA lv_dst_tab TYPE tabname.

    lt_map = mo_repo->get_mapping( ).
    LOOP AT lt_map ASSIGNING <ls_map>.
      lv_tab = <ls_map>-obj_name.
      IF mo_validator->is_valid( lv_tab ).
        lv_src_tab = <ls_map>-obj_name.
        lv_dst_tab = <ls_map>-new_obj_name.
        mo_transformer->transfer(
          iv_source = lv_src_tab
          iv_target = lv_dst_tab ).
        SELECT COUNT( * ) INTO lv_src FROM (<ls_map>-obj_name).
        SELECT COUNT( * ) INTO lv_dst FROM (<ls_map>-new_obj_name).
        mo_log->add(
          iv_src     = lv_src_tab
          iv_dst     = lv_dst_tab
          iv_src_cnt = lv_src
          iv_dst_cnt = lv_dst ).
      ENDIF.
    ENDLOOP.
    mo_log->display( ).
  ENDMETHOD.
ENDCLASS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_table-low.
  lcl_so_table_shlp=>show( CHANGING cv_value = so_table-low ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_table-high.
  lcl_so_table_shlp=>show( CHANGING cv_value = so_table-high ).

START-OF-SELECTION.
  DATA lo_migr        TYPE REF TO lcl_table_migrator.
  DATA lo_repo        TYPE REF TO lcl_map_repository.
  DATA lo_validator   TYPE REF TO lcl_table_validator.
  DATA lo_transformer TYPE REF TO lcl_table_transformer.
  DATA lo_log         TYPE REF TO lcl_migration_log.

  CREATE OBJECT lo_repo        EXPORTING i_tablesel = so_table[].
  CREATE OBJECT lo_validator.
  CREATE OBJECT lo_transformer EXPORTING iv_commit  = p_commit.
  CREATE OBJECT lo_log.

  CREATE OBJECT lo_migr
    EXPORTING
      io_repo        = lo_repo
      io_validator   = lo_validator
      io_transformer = lo_transformer
      io_log         = lo_log.

  lo_migr->run( ).
