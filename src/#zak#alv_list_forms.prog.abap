*----------------------------------------------------------------------*
*   INCLUDE ZALV_LIST_FORMS                                         *
*----------------------------------------------------------------------*
* Only use the forms here if they meet all of your requirements
* and they are acceptable in every respect!
* !!!   MODIFYING THE FORMS IS FORBIDDEN !!!!
*----------------------------------------------------------------------*
INCLUDE /ZAK/LIST_DEFINITIONS.       "ABAP List Viewer ALV definitions

*&---------------------------------------------------------------------*
*&      Form  common_alv_list_display
*&---------------------------------------------------------------------*
*       Display the ALV list
*----------------------------------------------------------------------*
*  --> $i_table    internal table to display
*  --> $struc_name DDIC structure of the internal table
*  --> $pf_status  name of the form that sets the list status - can be space if
*                   the standard status is sufficient. The specified form must be
*                   defined in the calling program!!
*  --> $user_command name of the form that provides interactivity - can be space
*                    if the standard behavior is sufficient. The specified form
*                    must be defined in the calling program!!
*----------------------------------------------------------------------*
FORM COMMON_ALV_LIST_DISPLAY TABLES $I_TABLE
                              USING VALUE($STRUC_NAME)
                                    VALUE($PF_STATUS)
                                    VALUE($USER_COMMAND).
* Initialize and populate list values
  L_REPID = SY-REPID.

* Call ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = L_REPID
      I_STRUCTURE_NAME         = $STRUC_NAME
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
      I_CALLBACK_PF_STATUS_SET = $PF_STATUS
      I_CALLBACK_USER_COMMAND  = $USER_COMMAND
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        = GT_SP_GROUP[]
*     IT_SORT                  = GT_SORT[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     i_default                = g_default
      I_SAVE                   = 'X' "allow saving variants
      "possible
*     IS_VARIANT               = G_VARIANT
      IT_EVENTS                = GT_EVENTS[]
*     IT_EVENT_EXIT            =
      IS_PRINT                 = GS_PRINT
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*      IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
    TABLES
      T_OUTTAB                 = $I_TABLE.

ENDFORM.                    " common_alv_list_display
*&---------------------------------------------------------------------*
*&      Form  common_alv_grid_display
*&---------------------------------------------------------------------*
*       Display the ALV list
*        Same as the standard ALV list, but the display is GRID
*        formatted
*----------------------------------------------------------------------*
*  --> $i_table    internal table to display
*  --> $struc_name DDIC structure of the internal table
*  --> $pf_status  name of the form that sets the list status - can be space if
*                   the standard status is sufficient. The specified form must be
*                   defined in the calling program!!
*  --> $user_command name of the form that provides interactivity - can be space
*                    if the standard behavior is sufficient. The specified form
*                    must be defined in the calling program!!
*----------------------------------------------------------------------*
FORM COMMON_ALV_GRID_DISPLAY TABLES $I_TABLE
                              USING VALUE($STRUC_NAME)
                                    VALUE($PF_STATUS)
                                    VALUE($USER_COMMAND).
* Initialize and populate list values
  L_REPID = SY-REPID.

* Call ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = L_REPID
      I_STRUCTURE_NAME         = $STRUC_NAME
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
      I_CALLBACK_PF_STATUS_SET = $PF_STATUS
      I_CALLBACK_USER_COMMAND  = $USER_COMMAND
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS        = GT_SP_GROUP[]
*     IT_SORT                  = GT_SORT[]
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     i_default                = g_default
      I_SAVE                   = 'X' "allow saving variants
      "possible
*     IS_VARIANT               = G_VARIANT
      IT_EVENTS                = GT_EVENTS[]
*     IT_EVENT_EXIT            =
      IS_PRINT                 = GS_PRINT
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*      IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
    TABLES
      T_OUTTAB                 = $I_TABLE.

ENDFORM.                    " common_alv_grid_display


*&---------------------------------------------------------------------*
*&      Form  COMMON_ALV_LIST_INIT
*&---------------------------------------------------------------------*
*       Initialize ALV list
*----------------------------------------------------------------------*
*      -->$title  Title text
*----------------------------------------------------------------------*
FORM COMMON_ALV_LIST_INIT
                  USING $TITLE
                        $INTERNAL_TABNAM
                        $INCLNAM.


* Initialize and populate list values
  L_REPID = SY-REPID.
  CLEAR: GT_LIST_TOP_OF_PAGE[],
         GS_LAYOUT,
         GT_EVENTS[],
         GS_PRINT,
         GT_FIELDCAT[].

* Build list header
  PERFORM COMMON_LIST_TOP_BUILD   USING GT_LIST_TOP_OF_PAGE[]
                                        $TITLE.
* Layout
  PERFORM COMMON_GS_LAYOUT_BUILD  USING GS_LAYOUT.
* Define events (top-of-page)
  PERFORM COMMON_EVENTTAB_BUILD USING GT_EVENTS[].
* Print settings
  PERFORM COMMON_GS_PRINT_BUILD USING GS_PRINT.
* Field catalog
  PERFORM COMMON_GS_FIELD_CATALOG USING GT_FIELDCAT[]
                                        $INTERNAL_TABNAM
                                        $INCLNAM.
ENDFORM.  "COMMON_ALV_LIST_INIT


*&---------------------------------------------------------------------*
*&      Form  COMMON_LIST_TOP_BUILD
*&---------------------------------------------------------------------*
*       Build list header
*----------------------------------------------------------------------*
*      -->$GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM COMMON_LIST_TOP_BUILD
                  USING  $GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER
                         $TITLE.


  DATA: L_LINE TYPE SLIS_LISTHEADER.
  DATA: L_UZEIT(10) TYPE C.

* Refresh
  REFRESH: $GT_LIST_TOP_OF_PAGE.

* Title
  CLEAR L_LINE.
  L_LINE-TYP  = 'A'.
  L_LINE-KEY  = SPACE.
  WRITE: $TITLE TO L_LINE-INFO CENTERED.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Parameters
*  CLEAR L_LINE.
*  L_LINE-TYP  = 'S'.
*  L_LINE-KEY  = 'Processing date:'.
*  L_LINE-INFO = P_FELDAT.

*  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info1
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Page:'.
  L_LINE-INFO =  SY-PAGNO.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info1
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'List generated:'.
  WRITE: SY-UZEIT TO L_UZEIT.
  WRITE: SY-DATUM TO L_LINE-INFO.
  CONCATENATE L_LINE-INFO L_UZEIT INTO L_LINE-INFO SEPARATED BY SPACE.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info2
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Client:'.
  CONCATENATE SY-SYSID SY-MANDT
         INTO L_LINE-INFO
    SEPARATED BY '-'.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info3
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Started by:'.
  L_LINE-INFO = SY-UNAME.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

ENDFORM.                               " COMMON_LIST_TOP_BUILD

*---------------------------------------------------------------------*
*       FORM COMMON_TOP_OF_PAGE
*
*---------------------------------------------------------------------*
*       For printing the header
*---------------------------------------------------------------------*
FORM COMMON_TOP_OF_PAGE.
  DATA: L_LINE TYPE SLIS_LISTHEADER.

  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Page:'.
  L_LINE-INFO =  SY-PAGNO.
  MODIFY GT_LIST_TOP_OF_PAGE FROM L_LINE INDEX 2.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.

ENDFORM.                               " COMMON_TOP_OF_PAGE


*&---------------------------------------------------------------------*
*&      Form  COMMON_GS_LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       Define list layout
*----------------------------------------------------------------------*
*      -->$LAYOUT  text
*----------------------------------------------------------------------*
FORM COMMON_GS_LAYOUT_BUILD USING $GS_LAYOUT TYPE SLIS_LAYOUT_ALV.


  $GS_LAYOUT-ZEBRA               = 'X'."Striped rows
  $GS_LAYOUT-COLWIDTH_OPTIMIZE   = 'X'."Optimize column widths
*  $gs_layout-totals_only         = 'X'."Totals only
*  $GS_LAYOUT-TOTALS_BEFORE_ITEMS = 'X'."Totals before items
*  $gs_layout-totals_text         = 'Grand total'(l01).
*  $GS_LAYOUT-SUBTOTALS_TEXT      = 'Subtotal'(L02).
*   $gs_layout-NO_MIN_LINESIZE = 'X'. " line size = width of the list
  $GS_LAYOUT-GET_SELINFOS = 'X'. "read selection criteria
*  $gs_LAYOUT-GROUP_CHANGE_EDIT = 'X'. "Subtotal display can be edited
*  $gs_LAYOUT-MIN_LINESIZE = 132.

*  $GS_LAYOUT-F2CODE            =
*  $GS_LAYOUT-CELL_MERGE        =
*  $GS_LAYOUT-BOX_FIELDNAME     = SPACE.
*  $GS_LAYOUT-NO_INPUT          =
*  $GS_LAYOUT-NO_VLINE          =
*  $GS_LAYOUT-NO_COLHEAD        =
*  $GS_LAYOUT-LIGHTS_FIELDNAME  =
*  $GS_LAYOUT-LIGHTS_CONDENSE   =
*  $GS_LAYOUT-KEY_HOTSPOT       =
*  $GS_LAYOUT-DETAIL_POPUP      =
*  $gs_layout-group_change_edit = 'X'.  "Allow the user to change
*                                       "whether sorting moves the subtotal to a new page
*                                       "or separates it with an underline
*                                       "for visual distinction
*  $GS_LAYOUT-GROUP_BUTTONS      =  space.
ENDFORM.                               " COMMON_GS_LAYOUT_BUILD

*&---------------------------------------------------------------------*
*&      Form  COMMON_EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM COMMON_EVENTTAB_BUILD USING $GT_EVENTS TYPE SLIS_T_EVENT.

  DATA: L_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 2
    IMPORTING
      ET_EVENTS   = $GT_EVENTS.
* COMMON TOP-OF-PAGE
  READ TABLE $GT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                  INTO L_EVENT.
  IF SY-SUBRC EQ 0.
    MOVE C_FORM_COMMON_TOP_OF_PAGE  TO L_EVENT-FORM.
    MODIFY $GT_EVENTS FROM L_EVENT INDEX SY-TABIX.
  ENDIF.
* END-OF-LIST
  READ TABLE $GT_EVENTS WITH KEY NAME = SLIS_EV_END_OF_LIST
                  INTO L_EVENT.
  IF SY-SUBRC EQ 0.
    MOVE C_FORM_COMMON_END_OF_LIST  TO L_EVENT-FORM.
    MODIFY $GT_EVENTS FROM L_EVENT INDEX SY-TABIX.
  ENDIF.
ENDFORM.                               " COMMON_EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  common_gs_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$GT_FIELDCAT[]  text
*      -->$STRUC_NAME
*      -->$INCLNAME    Name of the include in which the internal table is declared
*                      Provide it only if the internal table
*                      is not defined as a DDIC structure!!
*
*----------------------------------------------------------------------*
FORM COMMON_GS_FIELD_CATALOG USING $GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV
                                   $INTERNAL_TABNAM
                                   $INCLNAME.

  DATA: L_REPID LIKE SY-REPID.

  CHECK: NOT $INTERNAL_TABNAM IS INITIAL AND
         NOT $INCLNAME IS INITIAL.

  L_REPID = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = L_REPID
      I_INTERNAL_TABNAME     = $INTERNAL_TABNAM
*     i_structure_name       =
*     I_CLIENT_NEVER_DISPLAY = 'X'
      I_INCLNAME             = $INCLNAME
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      CT_FIELDCAT            = $GT_FIELDCAT[]
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

ENDFORM.                    " common_gs_field_catalog

*&---------------------------------------------------------------------*
*&      Form  COMMON_GS_PRINT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$GS_PRINT  text
*----------------------------------------------------------------------*
FORM COMMON_GS_PRINT_BUILD USING $GS_PRINT TYPE SLIS_PRINT_ALV.

  $GS_PRINT-NO_PRINT_SELINFOS  = 'X'.  "Selection info not needed
  $GS_PRINT-NO_PRINT_LISTINFOS = 'X'.  "List info not needed

ENDFORM.                               " COMMON_GS_PRINT_BUILD


*&---------------------------------------------------------------------*
*&      Form  INIT_SORTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$FIELD1   text
*      -->$FIELD2   text
*      -->$FIELD3   text
*      -->$FIELD4   text
*      -->$FIELD5   text
*      -->$FIELD6
*      -->$FIELD7
*----------------------------------------------------------------------*
FORM INIT_SORTTAB USING    $FIELD1
                           $FIELD2
                           $FIELD3
                           $FIELD4
                           $FIELD5
                           $FIELD6
                           $FIELD7.

  DATA: WA_SORT TYPE SLIS_SORTINFO_ALV.

  REFRESH GT_SORT.
* Field 1
  CHECK NOT $FIELD1 IS INITIAL.
  WA_SORT-SPOS = 1.
  WA_SORT-FIELDNAME = $FIELD1.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* Field 2
  CHECK NOT $FIELD2 IS INITIAL.
  WA_SORT-SPOS = 2.
  WA_SORT-FIELDNAME = $FIELD2.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* Field 3
  CHECK NOT $FIELD3 IS INITIAL.
  WA_SORT-SPOS = 3.
  WA_SORT-FIELDNAME = $FIELD3.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* Field 4
  CHECK NOT $FIELD4 IS INITIAL.
  WA_SORT-SPOS = 4.
  WA_SORT-FIELDNAME = $FIELD4.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* Field 5
  CHECK NOT $FIELD5 IS INITIAL.
  WA_SORT-SPOS = 5.
  WA_SORT-FIELDNAME = $FIELD5.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* Field 6
  CHECK NOT $FIELD6 IS INITIAL.
  WA_SORT-SPOS = 6.
  WA_SORT-FIELDNAME = $FIELD6.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* Field 7
  CHECK NOT $FIELD7 IS INITIAL.
  WA_SORT-SPOS = 7.
  WA_SORT-FIELDNAME = $FIELD7.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.
ENDFORM.                    " INIT_SORTTAB

*==================================================================*
*           Samples for additional ALV-related form calls
*==================================================================*


*&---------------------------------------------------------------------*
*&      Form  GT_IT_SORT_INIT
*&---------------------------------------------------------------------*
*       For aggregation: define sorting order
*                     determine whether subtotal levels go to a new page or stay on the same page
*----------------------------------------------------------------------*
*      -->P_GT_SORT[]  text
*----------------------------------------------------------------------*
*FORM gt_it_sort_init USING  $gt_sort TYPE slis_t_sortinfo_alv.

*  DATA: l_gt_sort TYPE slis_sortinfo_alv.

* Personnel number (PERNR)
*  CLEAR: l_gt_sort.
*  l_gt_sort-spos      = 1.
*  l_gt_sort-fieldname = 'PERNR'.
*  l_gt_sort-up        = 'X'.
*  l_gt_sort-subtot    = 'X'.
*  l_gt_sort-group     = 'UL'.          "Underline when the value changes
*  l_gt_sort-expa      = 1.             "Expansion level
*  APPEND l_gt_sort TO $gt_sort.
*ENDFORM.                               " GT_IT_SORT_INIT



*&---------------------------------------------------------------------*
*&      Form  GT_FIELDCAT_INIT
*&---------------------------------------------------------------------*
*       Field catalog definition
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
*FORM gt_fieldcat_init USING $gt_fieldcat TYPE slis_t_fieldcat_alv.

*  DATA: l_fieldcat TYPE slis_fieldcat_alv.

*  CLEAR l_fieldcat.
*  l_fieldcat-tabname   = 'IT_BER_LIST'.
*  l_fieldcat-fieldname   = 'BETRG'.
*-- Summation field
*  l_fieldcat-do_sum       = 'X'.
*-- Column order difference -> place the field in the first column
*  l_fieldcat-col_pos     = 1.          "Place it in the first column
*-- Fields that should not be displayed
*  l_fieldcat-no_out      = 'X'.        "Do not display
*  APPEND l_fieldcat TO $gt_fieldcat.

*ENDFORM.                               " GT_FIELDCAT_INIT
