*----------------------------------------------------------------------*
*   INCLUDE /ZAK/ALV_LIST_DEFINITIONS                                   *
*----------------------------------------------------------------------*
* ABAP List Viewer globális definíciói
*----------------------------------------------------------------------*

CONSTANTS:
* Közös top-of-page form neve
c_form_common_top_of_page TYPE slis_formname VALUE 'COMMON_TOP_OF_PAGE',
* Lista végén hívható form neve:'END_OF_LIST' (Fõprogramba kell megírni)
c_form_common_end_of_list TYPE slis_formname VALUE 'END_OF_LIST'.


* Fejléc adatok
DATA: gt_list_top_of_page TYPE slis_t_listheader.

* Report neve
DATA: l_repid LIKE sy-repid.

* Mezõ katalógus
DATA: gt_fieldcat         TYPE slis_t_fieldcat_alv,
      gs_fieldcat         TYPE slis_fieldcat_alv.

* Lista layout beállítások
DATA: gs_layout           TYPE slis_layout_alv.

* Rendezés
DATA: gt_sort             TYPE slis_t_sortinfo_alv.

* Események (pl: TOP-OF-PAGE)
DATA: gt_events           TYPE slis_t_event.

* Nyomtatás vezérlés
DATA: gs_print TYPE slis_print_alv.

* Mezõ csoportosítások (ez inkább 'csicsa')
DATA: gt_sp_group TYPE slis_t_sp_group_alv.

* Kulcsmezõk hierarchikus lista esetén
DATA: gs_keyinfo  TYPE slis_keyinfo_alv.
