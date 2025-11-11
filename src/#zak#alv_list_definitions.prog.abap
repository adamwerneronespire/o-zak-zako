*----------------------------------------------------------------------*
*   INCLUDE /ZAK/ALV_LIST_DEFINITIONS                                   *
*----------------------------------------------------------------------*
* ABAP List Viewer global definitions
*----------------------------------------------------------------------*

CONSTANTS:
* Name of the shared top-of-page form
c_form_common_top_of_page TYPE slis_formname VALUE 'COMMON_TOP_OF_PAGE',
* Name of the form that can be called at the end of the list: 'END_OF_LIST' (must be implemented in the main program)
c_form_common_end_of_list TYPE slis_formname VALUE 'END_OF_LIST'.


* Header data
DATA: gt_list_top_of_page TYPE slis_t_listheader.

* Report name
DATA: l_repid LIKE sy-repid.

* Field catalog
DATA: gt_fieldcat         TYPE slis_t_fieldcat_alv,
      gs_fieldcat         TYPE slis_fieldcat_alv.

* List layout settings
DATA: gs_layout           TYPE slis_layout_alv.

* Sorting
DATA: gt_sort             TYPE slis_t_sortinfo_alv.

* Events (e.g. TOP-OF-PAGE)
DATA: gt_events           TYPE slis_t_event.

* Print control
DATA: gs_print TYPE slis_print_alv.

* Field groupings (mostly for cosmetics)
DATA: gt_sp_group TYPE slis_t_sp_group_alv.

* Key fields for hierarchical lists
DATA: gs_keyinfo  TYPE slis_keyinfo_alv.
