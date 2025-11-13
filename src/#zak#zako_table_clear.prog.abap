*&---------------------------------------------------------------------*
*& Report  /ZAK/ZAKO_TABLE_CLEAR
*&---------------------------------------------------------------------*
*& Removes all data from selected transparent tables.
*&---------------------------------------------------------------------*
REPORT /zak/zako_table_clear.

TABLES: /zak/map.
TYPE-POOLS icon.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  SELECT-OPTIONS so_table FOR /zak/map-obj_name.
  PARAMETERS p_test AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK b1.

TYPES: BEGIN OF ty_stat,
         icon       TYPE icon_d,
         status     TYPE char1,
         old_tab    TYPE tabname,
         new_tab    TYPE tabname,
         old_length TYPE i,
         new_length TYPE i,
       END OF ty_stat.
TYPES tt_stat TYPE STANDARD TABLE OF ty_stat WITH EMPTY KEY.
TYPES tr_tabname TYPE RANGE OF /zak/map-obj_name.

CLASS lcl_confirm_popup DEFINITION DEFERRED.
CLASS lcl_deletion_log DEFINITION DEFERRED.
CLASS lcl_so_table_shlp DEFINITION DEFERRED.
CLASS lcl_table_cleaner DEFINITION DEFERRED.
CLASS lcl_table_purger DEFINITION DEFERRED.

CONSTANTS:
  BEGIN OF sc_status,
    success TYPE char1 VALUE 'S',
    warning TYPE char1 VALUE 'W',
    error   TYPE char1 VALUE 'E',
  END OF sc_status.

CLASS lcl_confirm_popup DEFINITION.
  PUBLIC SECTION.
    METHODS:
      "Requesting user confirmation
      confirm
        IMPORTING
          iv_title     TYPE string  "Title
          iv_text      TYPE string  "Question text
        RETURNING
          VALUE(rv_ok) TYPE abap_bool. "TRUE = Yes
ENDCLASS.

CLASS lcl_confirm_popup IMPLEMENTATION.
  METHOD confirm.
    DATA lv_answer TYPE c LENGTH 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = iv_title
        text_question         = iv_text
        text_button_1         = 'Igen'
        icon_button_1         = 'ICON_OKAY'
        text_button_2         = 'Nem'
        icon_button_2         = 'ICON_CANCEL'
        default_button        = '1'
        display_cancel_button = ' '
      IMPORTING
        answer                = lv_answer.

    " '1' = first button (Yes) – xsdbool converts nicely to boolean
    rv_ok = xsdbool( lv_answer = '1' ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_so_table_shlp DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS show
      CHANGING cv_value TYPE /zak/map-obj_name.
ENDCLASS.

CLASS lcl_so_table_shlp IMPLEMENTATION.
  METHOD show.
    SELECT obj_name
      FROM /zak/map AS map
      INNER JOIN dd02l AS old
        ON old~tabname = map~obj_name
      WHERE object = 'TABL'
        AND old~as4local = 'A'
        AND old~tabclass = 'TRANSP'
      INTO TABLE @DATA(lt_map).
    DATA lt_return TYPE STANDARD TABLE OF ddshretval WITH EMPTY KEY.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'OBJ_NAME'
        value_org       = 'S'
      TABLES
        value_tab       = lt_map
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc = 0.
      READ TABLE lt_return INTO DATA(ls_return) INDEX 1.
      IF sy-subrc = 0.
        cv_value = ls_return-fieldval.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_table_cleaner DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS clear
      IMPORTING iv_table TYPE tabname.
ENDCLASS.

CLASS lcl_table_cleaner IMPLEMENTATION.
  METHOD clear.
    DELETE FROM (iv_table).
    COMMIT WORK AND WAIT.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_deletion_log DEFINITION.
  PUBLIC SECTION.
    METHODS add
      IMPORTING
        iv_old_tab    TYPE ty_stat-old_tab
        iv_new_tab    TYPE ty_stat-new_tab
        iv_status     TYPE ty_stat-status
        iv_old_length TYPE ty_stat-old_length
        iv_new_length TYPE ty_stat-new_length.
    METHODS display.
  PRIVATE SECTION.
    DATA mt_stat TYPE tt_stat.
ENDCLASS.

CLASS lcl_deletion_log IMPLEMENTATION.
  METHOD add.
    DATA(lv_icon) = SWITCH icon_d( iv_status
      WHEN sc_status-success THEN icon_green_light
      WHEN sc_status-warning THEN icon_yellow_light
      WHEN sc_status-error   THEN icon_red_light
      ELSE space ).

    APPEND VALUE ty_stat(
      icon       = lv_icon
      status     = iv_status
      old_tab    = iv_old_tab
      new_tab    = iv_new_tab
      old_length = iv_old_length
      new_length = iv_new_length
    ) TO mt_stat.
  ENDMETHOD.

  METHOD display.
    TRY .
        cl_salv_table=>factory(
          IMPORTING r_salv_table = DATA(lo_salv)
          CHANGING t_table = mt_stat
        ).
      CATCH cx_salv_msg.
        RETURN.
    ENDTRY.
    lo_salv->get_columns( )->set_optimize( ).
    lo_salv->display( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_table_purger DEFINITION.
  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        io_cleaner TYPE REF TO lcl_table_cleaner
        io_log     TYPE REF TO lcl_deletion_log.
    METHODS run
      IMPORTING
        it_tables   TYPE tr_tabname
        iv_test_run TYPE abap_bool DEFAULT abap_false.
  PRIVATE SECTION.
    DATA: mo_cleaner TYPE REF TO lcl_table_cleaner,
          mo_log     TYPE REF TO lcl_deletion_log.
ENDCLASS.

CLASS lcl_table_purger IMPLEMENTATION.
  METHOD constructor.
    mo_cleaner   = io_cleaner.
    mo_log       = io_log.
  ENDMETHOD.

  METHOD run.
    SELECT FROM /zak/map AS map
      INNER JOIN dd02l AS old
        ON old~tabname = map~obj_name
      INNER JOIN dd02l AS new
        ON new~tabname = map~new_obj_name
      FIELDS
        old~tabname AS old_tab,
        new~tabname AS new_tab
      WHERE map~obj_name IN @it_tables
        AND map~object = 'TABL'
        AND old~as4local = 'A'
        AND old~tabclass = 'TRANSP'
        AND new~as4local = 'A'
        AND new~tabclass = 'TRANSP'
      INTO TABLE @DATA(lt_tables).

    IF iv_test_run = abap_true.
      mo_log->add(
        iv_old_tab  = '!!!TEST_RUN!!!'
        iv_new_tab  = '!!!TEST_RUN!!!'
        iv_status  = sc_status-warning
        iv_old_length  = 0
        iv_new_length  = 0
      ).
    ENDIF.

    LOOP AT lt_tables INTO DATA(ls_tabname).
      DATA(lv_status) = VALUE char1( ).

      SELECT COUNT( * ) FROM (ls_tabname-old_tab)
          INTO @DATA(lv_old_tab_length).
      SELECT COUNT( * ) FROM (ls_tabname-new_tab)
          INTO @DATA(lv_new_tab_length).

      IF lv_old_tab_length > lv_new_tab_length.
        IF NEW lcl_confirm_popup( )->confirm(
               iv_title = 'Lehetséges adatvesztés! Megerősítés szükséges!'
               iv_text  = 'Az új tábla kevesebb sort tartalmaz, mint a régi. Biztosan folytatod?').
          " -- User clicked the "Yes" button
          lv_status = sc_status-warning.
        ELSE.
          " -- User clicked the "No" button
          lv_status = sc_status-error.
          mo_log->add(
            iv_old_tab  = ls_tabname-old_tab
            iv_new_tab  = ls_tabname-new_tab
            iv_status  = lv_status
            iv_old_length  = CONV #( lv_old_tab_length )
            iv_new_length  = CONV #( lv_new_tab_length )
          ).
          CONTINUE.
        ENDIF.
      ELSE.
        lv_status = sc_status-success.
      ENDIF.

      IF iv_test_run = abap_false.
        mo_cleaner->clear( ls_tabname-old_tab ).
      ENDIF.

      mo_log->add(
        iv_old_tab  = ls_tabname-old_tab
        iv_new_tab  = ls_tabname-new_tab
        iv_status  = lv_status
        iv_old_length  = CONV #( lv_old_tab_length )
        iv_new_length  = CONV #( lv_new_tab_length )
      ).
    ENDLOOP.

    mo_log->display( ).
  ENDMETHOD.
ENDCLASS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_table-low.
  lcl_so_table_shlp=>show( CHANGING cv_value = so_table-low ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_table-high.
  lcl_so_table_shlp=>show( CHANGING cv_value = so_table-high ).

START-OF-SELECTION.
  DATA(lo_purger) = NEW lcl_table_purger(
      io_cleaner   = NEW lcl_table_cleaner( )
      io_log       = NEW lcl_deletion_log( ) ).

  lo_purger->run(
    it_tables  = so_table[]
    iv_test_run = p_test ).
