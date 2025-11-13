*&---------------------------------------------------------------------*
*& Report /ZAK/READ_KATA
*&---------------------------------------------------------------------*
*& Loading KATA data from an Excel file
*&---------------------------------------------------------------------*
REPORT /ZAK/READ_KATA MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: __________________
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor
*& Creation date     : 2021.02.21
*& Functional spec author: Balázs Gábor
*& SAP modul neve    : ADO
*& Program type      : ________
*& SAP version       : ________
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (The OSS note number must be written at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER                  DESCRIPTION
*& ----   ----------   ----------     ---------------------- -----------
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.


*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
TYPES:
  TY_EXCEL_DATA TYPE /ZAK/KATA_SEL,
*  ty_mand_fields_t TYPE TABLE OF ty_mand_fields,
  TY_DATA       TYPE /ZAK/KATA_SEL,
  TY_DATA_T     TYPE TABLE OF TY_DATA.
*  ty_data_t        TYPE zgttsd_condition_data.

TYPES: BEGIN OF TY_HEADER,
         COL       TYPE KCD_EX_COL_N,
         FIELDNAME TYPE FIELDNAME,
         VALUE     TYPE CHAR50,
       END OF TY_HEADER.

DATA GT_DATA TYPE TY_DATA_T.
DATA: GV_DATAB TYPE CHAR12,
      GV_DATBI TYPE CHAR12.
DATA G_EXCEL  TYPE XFELD.

DATA GT_BAPIRET2 TYPE BAPIRET2_T.

DATA GV_LOG_NUM TYPE BALOGNR.

DATA GT_HEADER    TYPE SORTED TABLE OF TY_HEADER WITH UNIQUE KEY COL.

DATA: G_BEGIN_COL TYPE I,
      G_END_COL   TYPE I.
DATA: G_BEGIN_ROW TYPE I,
      G_END_ROW   TYPE I.

* for Excel upload
DATA  G_STRNAME   TYPE STRUKNAME.
DATA: G_XLS_LINE TYPE SY-TABIX VALUE 5000.
DATA: I_DD03P TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0,
      W_DD03P TYPE DD03P.

DATA  G_ERROR TYPE XFELD.

*MAKRO fill the range
DEFINE M_DEF.
  MOVE: &2      TO &1-sign,
        &3      TO &1-option,
        &4      TO &1-low,
        &5      TO &1-high.
 collect &1 INTO &6.
END-OF-DEFINITION.

FIELD-SYMBOLS <LS_BAPIRET2> TYPE BAPIRET2.

* Macro for adding messages
DEFINE M_ADD_MSG.
  APPEND INITIAL LINE TO GT_BAPIRET2 ASSIGNING <LS_BAPIRET2>.
  <LS_BAPIRET2>-TYPE              = &1.
  <LS_BAPIRET2>-ID                = &2.
  <LS_BAPIRET2>-NUMBER            = &3.
  <LS_BAPIRET2>-MESSAGE_V1 = &4.
  <LS_BAPIRET2>-MESSAGE_V2 = &5.
  <LS_BAPIRET2>-MESSAGE_V3 = &6.
  <LS_BAPIRET2>-MESSAGE_V4 = &7.
  IF &1 CA 'EAX' AND G_ERROR IS INITIAL.
    G_ERROR = 'X'.
  ENDIF.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Global variables      -   (V_xxx...)                              *
*      Work area             -   (W_xxx...)                              *
*      Type                  -   (T_xxx...)                              *
*      Macros                -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class                 -   (CL_xxx...)                             *
*      Event                 -   (E_xxx...)                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& PARAMETERS  (P_XXXXXXX..)                                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SELECT-OPTIONS (S_XXXXXXX..)                                        *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-S01.
*Company
PARAMETERS: P_BUKRS TYPE BUKRS OBLIGATORY VALUE CHECK MEMORY ID BUK.
*File
PARAMETERS: P_FILE TYPE RLGRAP-FILENAME OBLIGATORY.
*Test run
PARAMETERS: P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK SEL.
*===============================================================
****************************************************************
* LOCAL CLASSES: Definition
****************************************************************
*===============================================================
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
CLASS LCL_HANDLE_EVENTS DEFINITION.
  PUBLIC SECTION.
    DATA: LO_ALV TYPE REF TO CL_SALV_TABLE.
    METHODS:
      ON_USER_COMMAND FOR EVENT ADDED_FUNCTION OF CL_SALV_EVENTS
        IMPORTING E_SALV_FUNCTION.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS LCL_HANDLE_EVENTS IMPLEMENTATION.
  METHOD ON_USER_COMMAND.

    DATA: LS_KOMK TYPE KOMK,
          LS_KOMP TYPE KOMP.

    DATA: LS_KEY_FIELDS   TYPE KOMG.
    DATA: LS_COPY_RECORDS TYPE KOMV,
          LT_COPY_RECORDS TYPE TABLE OF KOMV,
          L_INPUT         TYPE CHAR1.

    DATA: LR_SO_NUM TYPE GMRANGE_TAB_CHAR20.
    DATA  LS_RANGE_C20 TYPE RANGE_C20.


    CASE E_SALV_FUNCTION.
      WHEN 'BAPIRET'.
        IF NOT GT_BAPIRET2 IS INITIAL.
          CALL FUNCTION 'FINB_BAPIRET2_DISPLAY'
            EXPORTING
              IT_MESSAGE = GT_BAPIRET2.
        ENDIF.
**   Display LOG
*      WHEN 'LOGVIEW'.
*        IF NOT gv_log_num IS INITIAL.
*          m_def ls_range_c20 'I' 'EQ' gv_log_num space lr_so_num.
*          SUBMIT sbal_display_2 WITH so_num IN lr_so_num AND RETURN.
*        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "on_user_command
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION



*===================================================================
*-----------------------------------------------------------------------
*       INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
*++2265 #02.
* Authorization check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
                   ID 'TCD'  FIELD '/ZAK/READ_KATA'.
*--2265 #02.

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
* File name search help
  PERFORM GET_FILENAME CHANGING P_FILE.

AT SELECTION-SCREEN.
* Selection check
  PERFORM CHECK_SELECTION.
* File name and company assignment check
  PERFORM CHECK_BUKRS_FILENAME.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
* Reading the file
  PERFORM GET_EXCEL_DATA USING P_FILE
                      CHANGING GT_DATA.
  IF GT_DATA[] IS INITIAL.
    MESSAGE I260 WITH P_FILE.
*   The & file does not contain any records to process!
  ENDIF.
* Checking the file
  PERFORM CHECK_UPLOAD TABLES GT_DATA.

* Error handling
  IF P_TEST IS INITIAL AND NOT G_ERROR IS INITIAL.
    MESSAGE I711 DISPLAY LIKE 'E'.
*  Production processing is not possible due to errors! See the messages!
  ELSEIF NOT G_ERROR IS INITIAL.
    MESSAGE I317 DISPLAY LIKE 'W'.
*  Messages occurred during processing!
  ENDIF.

* Saving to the database
  PERFORM SAVE_DATA.

************************************************************************
* END-OF-SELECTION
***********************************************************************
END-OF-SELECTION.
* In online mode
  IF SY-BATCH IS INITIAL.
    PERFORM DISPLAY_ALV CHANGING GT_DATA.
  ENDIF.



*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
FORM GET_FILENAME  CHANGING CV_FILE.

  DATA: LT_FILETAB TYPE FILETABLE,
        LV_RC      TYPE I.


  CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG(
    EXPORTING
*    window_title            =
*    default_extension       =
*    default_filename        =
      FILE_FILTER             = 'Microsoft Excel Fájlok (*.XLS;*.XLSX)|*.XLS;*.XLSX|'
*    with_encoding           =
*    initial_directory       =
*    multiselection          =
    CHANGING
      FILE_TABLE              = LT_FILETAB
      RC                      = LV_RC
*    user_action             =
*    file_encoding           =
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5
  ).
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF NOT LT_FILETAB IS INITIAL.
    READ TABLE LT_FILETAB INTO DATA(LS_FILETAB) INDEX 1.
    IF SY-SUBRC EQ 0.
      CV_FILE = LS_FILETAB-FILENAME.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SELECTION .

  DATA L_FILE TYPE STRING.
  DATA L_RESULT TYPE C.

* Check exist file
  IF NOT P_FILE IS INITIAL.
    MOVE P_FILE TO L_FILE.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
      EXPORTING
        FILE            = L_FILE
      RECEIVING
        RESULT          = L_RESULT
      EXCEPTIONS
        CNTL_ERROR      = 1
        ERROR_NO_GUI    = 2
        WRONG_PARAMETER = 3
        OTHERS          = 4.
    IF L_RESULT EQ SPACE.
      MESSAGE E082 WITH L_FILE.
*     Error while opening file &!
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BUKRS_FILENAME.
  DATA: BEGIN OF L_SPLIT OCCURS 0,
          LINE(80),
        END OF L_SPLIT.
  DATA  L_LINES TYPE I.
  DATA  L_LENGTH TYPE I.

*  Splitting the file path.
  SPLIT P_FILE AT '\' INTO TABLE L_SPLIT.
*  The last part will be the file name.
  DESCRIBE TABLE L_SPLIT LINES L_LINES.
  READ TABLE L_SPLIT INDEX L_LINES.
*  Determining the company code length
  L_LENGTH = STRLEN( P_BUKRS ).
*  If the file name does not start with the company code:
  IF L_SPLIT-LINE(L_LENGTH) NE P_BUKRS.
    MESSAGE E194 WITH P_BUKRS.
*   Invalid file! The file name does not start with the company code! (&1)
  ENDIF.

ENDFORM.                    " CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*&      Form  GET_EXCEL_DATA_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE  text
*      <--P_GT_DATA  text
*----------------------------------------------------------------------*
FORM GET_EXCEL_DATA      USING UV_FILE
                      CHANGING CT_DATA         TYPE TY_DATA_T.

  DATA LV_PATH         TYPE STRING.
*  DATA: LO_EXCEL        TYPE REF TO ZCL_EXCEL,
*        LO_EXCEL_WRITER TYPE REF TO ZIF_EXCEL_WRITER,
*        LO_READER       TYPE REF TO ZIF_EXCEL_READER.
*  DATA: LO_EX  TYPE REF TO ZCX_EXCEL,
  DATA:  LV_MSG TYPE STRING.
*  DATA: LO_WORKSHEET      TYPE REF TO ZCL_EXCEL_WORKSHEET,
  DATA: LV_HIGHEST_COLUMN TYPE INT4,
        LV_HIGHEST_ROW    TYPE INT4,
        LV_COLUMN         TYPE INT4 VALUE 1,
        LV_COL_STR        TYPE CHAR3,
        LV_ROW            TYPE INT4               VALUE 1,
        LV_VALUE          TYPE STRING.

  DATA: LT_INTERN    TYPE TABLE OF ALSMEX_TABLINE,
        LS_HEADER    LIKE LINE OF GT_HEADER,
*        lv_row       TYPE kcd_ex_row_n,
        LV_MESSAGE   TYPE STRING,
*       lv_shift     TYPE i,
        LV_DATE_TEXT TYPE I,
        LV_WRBTR     TYPE WRBTR.
  DATA: L_STRING     TYPE CHAR20.
  DATA: LS_DATA      TYPE TY_DATA.

  DATA: LI_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
  DATA: LI_LINE TYPE STANDARD TABLE OF /ZAK/LINE            INITIAL SIZE 0.


  DATA: LO_EXREF TYPE REF TO CX_ROOT.

  FIELD-SYMBOLS: <LV_ANY> TYPE ANY.

  DATA:
    L_INTERNAL_AMOUNT TYPE WRBTR,
    L_EXTERNAL_AMOUNT TYPE BAPICURR-BAPICURR.

  DEFINE LM_CURRENCY_INTERNAL.
    l_external_amount = &1.
*   Converting the amount to internal HUF format
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        currency             = &2
        amount_external      = l_external_amount
        max_number_of_digits = 13
      IMPORTING
        amount_internal      = l_internal_amount.
    &1 = l_internal_amount.
  END-OF-DEFINITION.

  DEFINE LM_RUN_CONV.
    CALL METHOD cl_reca_ddic_services=>do_struct_conv_exit
*      EXPORTING
*        id_convexit        =
*        if_only_if_defined = ABAP_TRUE
*        if_output          = ABAP_FALSE
      CHANGING
        cs_struct          = &1
      EXCEPTIONS
        error              = 1
        OTHERS             = 2
            .
  END-OF-DEFINITION.


*  LV_PATH = UV_FILE.

*  TRY.
*      CREATE OBJECT lo_reader TYPE zcl_excel_reader_2007.
*      lo_excel = lo_reader->load_file( lv_path ).
*      lo_worksheet = lo_excel->get_active_worksheet( ).
*      lv_highest_column = lo_worksheet->get_highest_column( ).
*      lv_highest_row    = lo_worksheet->get_highest_row( ).
*
*      WHILE lv_row <= lv_highest_row.
*        WHILE lv_column <= lv_highest_column.
*          lv_col_str = zcl_excel_common=>convert_column2alpha( lv_column ).
*          lo_worksheet->get_cell(
*            EXPORTING
*              ip_column = lv_col_str
*              ip_row    = lv_row
*            IMPORTING
*              ep_value = lv_value
*          ).
*          APPEND INITIAL LINE TO lt_intern ASSIGNING FIELD-SYMBOL(<ls_intern>).
*          <ls_intern>-row   = lv_row.
*          <ls_intern>-col   = lv_column.
*          <ls_intern>-value = lv_value.
*          ADD 1 TO lv_column.
*        ENDWHILE.
*        lv_column = 1.
*        ADD 1 TO lv_row.
*      ENDWHILE.
*
*    CATCH zcx_excel INTO lo_ex.    " Exceptions for ABAP2XLSX
*      lv_msg = lo_ex->get_text( ).
*      MESSAGE lv_msg TYPE 'E'.
*  ENDTRY.

  G_STRNAME = '/ZAK/KATA_SEL'.
  G_BEGIN_COL = 1.
  G_END_ROW  = 65536.
  G_BEGIN_ROW = 1.

  PERFORM CHECK_FIELDTYP USING  G_STRNAME
                       CHANGING G_END_COL.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_FILE
      I_BEGIN_COL             = G_BEGIN_COL
      I_BEGIN_ROW             = G_BEGIN_ROW
      I_END_COL               = G_END_COL
      I_END_ROW               = G_END_ROW
    TABLES
      INTERN                  = LT_INTERN
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SORT LT_INTERN BY ROW ASCENDING
                    COL ASCENDING.

  LOOP AT LT_INTERN INTO DATA(LS_INTERN).
* first line the technical name
    IF LS_INTERN-ROW EQ 1.
      LS_HEADER-COL = LS_INTERN-COL.
      LS_HEADER-FIELDNAME = LS_INTERN-VALUE.
      READ TABLE LT_INTERN INTO LS_INTERN                "#EC CI_STDSEQ
      WITH KEY ROW = 1
               COL = LS_HEADER-COL.
      IF SY-SUBRC EQ 0.
        LS_HEADER-VALUE = LS_INTERN-VALUE.
      ENDIF.
      INSERT LS_HEADER INTO TABLE GT_HEADER.
    ELSEIF LS_INTERN-ROW GT 2.
* if change line add new line
      IF LV_ROW NE LS_INTERN-ROW.
        LV_ROW = LS_INTERN-ROW.
        APPEND INITIAL LINE TO CT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).
      ENDIF.
*      <LS_DATA>-FILENAME = P_FILE.
* field from header
      READ TABLE GT_HEADER INTO LS_HEADER BINARY SEARCH
                           WITH KEY COL = LS_INTERN-COL.
      IF SY-SUBRC EQ 0.
        ASSIGN COMPONENT LS_HEADER-FIELDNAME OF STRUCTURE <LS_DATA> TO <LV_ANY>.
        IF SY-SUBRC EQ 0.
          IF LS_HEADER-FIELDNAME = 'LWBAS' OR LS_HEADER-FIELDNAME = 'LWSTE'.
            TRY .
                LV_WRBTR = LS_INTERN-VALUE.
                <LV_ANY> = LV_WRBTR.
              CATCH CX_SY_CONVERSION_NO_NUMBER.
                <LV_ANY> = '0.0'.
                M_ADD_MSG 'E' '/ZAK/ZAK' '743'  LS_INTERN-VALUE LS_INTERN-ROW '' ''.
*                 The value & in the cell is invalid in the XLS file (row &.)!
            ENDTRY.
          ELSE.
            TRY.
                CLEAR LV_MESSAGE.
                <LV_ANY> = LS_INTERN-VALUE.
              CATCH CX_SY_CONVERSION_OVERFLOW INTO LO_EXREF.
                LV_MESSAGE = LO_EXREF->GET_TEXT( ).
            ENDTRY.
            IF NOT LV_MESSAGE IS INITIAL.
              MESSAGE E318 WITH LS_HEADER-FIELDNAME LV_MESSAGE.
*            Field conversion error! (&: &)
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE E319 WITH LS_HEADER-FIELDNAME.
*         Critical error: field &1 is missing from the database structure!
        ENDIF.
      ELSE.
        MESSAGE E320.
*       Critical error: the header does not contain enough fields!
      ENDIF.
    ENDIF.
  ENDLOOP.
* Convert data, currency, other
  LOOP AT CT_DATA ASSIGNING <LS_DATA>.
    LM_RUN_CONV <LS_DATA>.
    IF NOT <LS_DATA>-LWBAS IS INITIAL AND NOT <LS_DATA>-WAERS  IS INITIAL.
      LM_CURRENCY_INTERNAL <LS_DATA>-LWBAS <LS_DATA>-WAERS. "#NUMBER_OK
    ENDIF.
    IF NOT <LS_DATA>-LWSTE IS INITIAL AND NOT <LS_DATA>-WAERS  IS INITIAL.
      LM_CURRENCY_INTERNAL <LS_DATA>-LWSTE <LS_DATA>-WAERS. "#NUMBER_OK
    ENDIF.
    <LS_DATA>-XMANU = 'X'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  check_fieldtyp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_STRNAME  text
*      <--P_V_BEGIN_XLS  text
*----------------------------------------------------------------------*
FORM CHECK_FIELDTYP USING    $STRNAME
                    CHANGING $V_END_COL.
  REFRESH: I_DD03P.
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      NAME          = $STRNAME
*     STATE         = 'A'
      LANGU         = SY-LANGU
    TABLES
      DD03P_TAB     = I_DD03P
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  $V_END_COL = SY-TFILL.
* COMPTYPE = 'S' include row, therefore we ignore it
  DELETE I_DD03P WHERE COMPTYPE = 'S'.
  LOOP AT I_DD03P INTO W_DD03P.
    W_DD03P-POSITION = SY-TABIX.
    MODIFY I_DD03P FROM W_DD03P TRANSPORTING POSITION.
  ENDLOOP.
ENDFORM.                    " check_fieldtyp
*&---------------------------------------------------------------------*
*&      Form  CHECK_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA  text
*----------------------------------------------------------------------*
FORM CHECK_UPLOAD  TABLES   $T_DATA TYPE TY_DATA_T.

  DATA: LV_TEXT          TYPE CHAR10,
        LV_DDTEXT        TYPE AS4TEXT,
        LV_DUMMY         TYPE STRING,
        LV_INVALID_FIELD TYPE XFELD.

  FIELD-SYMBOLS: <LS_DATA> LIKE LINE OF $T_DATA,
                 <LV_ANY>  TYPE ANY.

  TYPES: BEGIN OF LT_KATA_SUM,
           BUKRS      TYPE BUKRS,
           ADOAZON    TYPE /ZAK/ADOAZON,
           BSEG_GJAHR TYPE CHAR4,
           BSEG_BELNR TYPE BELNR_D,
           BSEG_BUZEI TYPE CHAR3,
           COUNT      TYPE INT4,
         END OF LT_KATA_SUM.


  STATICS: LI_KATA_SUM TYPE STANDARD TABLE OF LT_KATA_SUM.
  DATA LS_KATA_SUM TYPE LT_KATA_SUM.

  LOOP AT $T_DATA INTO DATA(LS_DATA).
    IF LS_DATA-BUKRS NE P_BUKRS.
      M_ADD_MSG 'E' '/ZAK/ZAK' '321' P_BUKRS LS_DATA-BUKRS '' ''.
*     Company & in the file does not match the company & provided in the selection!
    ENDIF.

    IF LS_DATA-BUKRS IS INITIAL OR
       LS_DATA-ADOAZON IS INITIAL OR
       LS_DATA-GJAHR   IS INITIAL OR
       LS_DATA-MONAT   IS INITIAL OR
       LS_DATA-BUDAT   IS INITIAL OR
       LS_DATA-SZAMLASZ  IS INITIAL OR
       LS_DATA-WAERS  IS INITIAL.
      M_ADD_MSG 'E' '/ZAK/ZAK' '322' '' '' '' ''.
*      A mandatory field is missing in the file!
    ENDIF.
*   Currency check
    IF NOT LS_DATA-WAERS IS INITIAL .
      SELECT SINGLE WAERS INTO @DATA(L_WAERS)
                          FROM T001
                         WHERE BUKRS EQ @LS_DATA-BUKRS.
      IF LS_DATA-WAERS NE  L_WAERS.
        M_ADD_MSG 'E' '/ZAK/ZAK' '243' LS_DATA-WAERS L_WAERS '' ''.
*      The currency & in processing does not match the company's currency &!
      ENDIF.
    ENDIF.
    CLEAR LS_KATA_SUM.
    MOVE-CORRESPONDING LS_DATA TO LS_KATA_SUM.
    LS_KATA_SUM-COUNT = 1.
    COLLECT LS_KATA_SUM INTO LI_KATA_SUM.
  ENDLOOP.

  LOOP AT LI_KATA_SUM INTO LS_KATA_SUM WHERE COUNT NE 1.
    LV_DUMMY = LS_DATA-ADOAZON && |/| &&  LS_DATA-BSEG_GJAHR && |/| && LS_DATA-BSEG_BELNR && |/| && LS_DATA-BSEG_BUZEI.
    M_ADD_MSG 'E' '/ZAK/ZAK' '779' LV_DUMMY '' '' ''.
*   A duplicated value is found in the XLS file! (&)
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV CHANGING CT_DATA TYPE TY_DATA_T.

  DATA: LO_COLUMN      TYPE REF TO CL_SALV_COLUMN_LIST,
        LV_POSITION    TYPE I,
        LO_HANDLER     TYPE REF TO LCL_HANDLE_EVENTS,
        LV_SHORT_TEXT  TYPE SCRTEXT_S,
        LV_MEDIUM_TEXT TYPE SCRTEXT_M,
        LV_LONG_TEXT   TYPE SCRTEXT_L..
  DATA: LO_COLUMN_TABLE TYPE REF TO CL_SALV_COLUMN_TABLE.
  DATA: L_FNAME        TYPE LVC_FNAME.

  DATA : LT_TABDESCR TYPE ABAP_COMPDESCR_TAB.
  DATA : REF_TABLE_DESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  TRY.
      CL_SALV_TABLE=>FACTORY(
*  EXPORTING
*    list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*    r_container    =
*    container_name =
        IMPORTING
          R_SALV_TABLE   = DATA(LO_ALV)
        CHANGING
          T_TABLE        = CT_DATA
      ).

      DATA(LO_COLUMNS) = LO_ALV->GET_COLUMNS( ).
      TRY.
          LO_COLUMN ?= LO_COLUMNS->GET_COLUMN( 'LWBAS' ). "Currency Value
          LO_COLUMN->SET_CURRENCY_COLUMN( 'WAERS' ).      "Currency Key
        CATCH:  CX_SALV_NOT_FOUND,
                CX_SALV_DATA_ERROR.

      ENDTRY.
      TRY.
          LO_COLUMN ?= LO_COLUMNS->GET_COLUMN( 'LWSTE' ). "Currency Value
          LO_COLUMN->SET_CURRENCY_COLUMN( 'WAERS' ).      "Currency Key
        CATCH:  CX_SALV_NOT_FOUND,
                CX_SALV_DATA_ERROR.
      ENDTRY.

      LO_ALV->GET_COLUMNS( )->SET_OPTIMIZE( ).
*      TRY .
*          LO_COLUMN ?= LO_COLUMNS->GET_COLUMN( COLUMNNAME = 'ICON' ).
*          LO_COLUMN->SET_KEY( ).
*          LO_ALV->GET_COLUMNS( )->SET_COLUMN_POSITION(  COLUMNNAME = 'ICON'
*                                            POSITION   = 1 ).
*        CATCH CX_SALV_NOT_FOUND.
*      ENDTRY.

*     Disable column
      TRY.
          LO_COLUMN_TABLE ?= LO_COLUMNS->GET_COLUMN( 'MANDT' ).
          LO_COLUMN_TABLE->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>FALSE ).
          LO_COLUMN_TABLE ?= LO_COLUMNS->GET_COLUMN( 'NONEED' ).
          LO_COLUMN_TABLE->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>FALSE ).
          LO_COLUMN_TABLE ?= LO_COLUMNS->GET_COLUMN( 'PROCESS' ).
          LO_COLUMN_TABLE->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>FALSE ).

          REF_TABLE_DESCR ?=  CL_ABAP_TYPEDESCR=>DESCRIBE_BY_NAME( '/ZAK/KATA_SEL' ).
          LT_TABDESCR[] = REF_TABLE_DESCR->COMPONENTS[].

        CATCH CX_SALV_NOT_FOUND.
      ENDTRY.

      LO_ALV->GET_SELECTIONS( )->SET_SELECTION_MODE(
          VALUE = IF_SALV_C_SELECTION_MODE=>SINGLE
      ).

      LO_ALV->SET_SCREEN_STATUS(
          PFSTATUS      =  'STANDARD'
          REPORT        =  SY-REPID
          SET_FUNCTIONS = LO_ALV->C_FUNCTIONS_ALL ).

*CATCH cx_salv_existing.   " ALV: General Error Class (Checked During Syntax Check)
*CATCH cx_salv_wrong_call. " ALV: General Error Class (Checked During Syntax Check)
*      READ TABLE GT_DATA TRANSPORTING NO FIELDS
*      WITH KEY ICON = ICON_RED_LIGHT.
*      IF SY-SUBRC EQ 0.
*        TRY.
*            LO_ALV->GET_FUNCTIONS( )->SET_FUNCTION(
*              EXPORTING
*                NAME    = 'CREATE_CO'
*                BOOLEAN = ABAP_FALSE
*            ).
*          CATCH CX_SALV_WRONG_CALL.
*        ENDTRY.
**     Insert log
*        CALL FUNCTION 'Z_GSD_CREATE_APPLO'
*          TABLES
*            t_data = gt_data.
*      ENDIF.

      DATA(LO_EVENTS) = LO_ALV->GET_EVENT( ).

      CREATE OBJECT LO_HANDLER.
      LO_HANDLER->LO_ALV = LO_ALV.
      SET HANDLER LO_HANDLER->ON_USER_COMMAND FOR LO_EVENTS.
      LO_HANDLER->LO_ALV = LO_ALV.
      LO_ALV->DISPLAY( ).
    CATCH CX_SALV_NOT_FOUND.  "
    CATCH CX_SALV_MSG.    "
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA: L_PACK TYPE /ZAK/PACK.
  DATA: LS_DATA TYPE /ZAK/KATA_SEL.

  CHECK G_ERROR IS INITIAL AND P_TEST IS INITIAL.
* Generating the upload identifier
  CALL FUNCTION '/ZAK/NEW_PACKAGE_NUMBER'
    IMPORTING
      E_PACK           = L_PACK
    EXCEPTIONS
      ERROR_GET_NUMBER = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE A001(/ZAK/ZAK).
*   Upload identifier number range error!
  ENDIF.
  LS_DATA-PACK = L_PACK.
  MODIFY GT_DATA FROM LS_DATA TRANSPORTING PACK
                 WHERE PACK IS INITIAL.
  INSERT /ZAK/KATA_SEL FROM TABLE GT_DATA.
  COMMIT WORK AND WAIT.
  MESSAGE S033 WITH L_PACK.
*  Upload completed with package number &!

ENDFORM.
