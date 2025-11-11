*----------------------------------------------------------------------*
*   INCLUDE ZALV_LIST_FORMS                                         *
*----------------------------------------------------------------------*
* Az itt lévő form-okat csak akkor használd, ha számodra minden
* tekintetben megfelelnek !
* !!!   A FORM-ok MÓDOSÍTÁSA TILOS !!!!
*----------------------------------------------------------------------*
INCLUDE /ZAK/LIST_DEFINITIONS.       "ABAP List Viewer ALV definíciók

*&---------------------------------------------------------------------*
*&      Form  common_alv_list_display
*&---------------------------------------------------------------------*
*       ALV lista megjelenítése
*----------------------------------------------------------------------*
*  --> $i_table    listázandó belső tábla
*  --> $struc_name belső tábla struktúrája (DDIC)
*  --> $pf_status  lista státus beállító form neve - lehet space is, ha
*                   a standard jó. A megadott form-ot a hívó programban
*                   kell definiálni !!
*  --> $user_command lista interaktivitását biztosító form neve - lehet
*                    space is, ha standard jó. A megadott form-ot a hívó
*                    programban kell definiálni !!
*----------------------------------------------------------------------*
FORM COMMON_ALV_LIST_DISPLAY TABLES $I_TABLE
                              USING VALUE($STRUC_NAME)
                                    VALUE($PF_STATUS)
                                    VALUE($USER_COMMAND).
* Lista értékek inicializálása, feltöltése
  L_REPID = SY-REPID.

* ABAP/4 List Viewer hívása
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
      I_SAVE                   = 'X' "variánsok mentése
      "lehetséges
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
*       ALV lista megjelenítése
*        Megegyezik a normál ALV listával, de a megjelenítés GRID
*        formátumú
*----------------------------------------------------------------------*
*  --> $i_table    listázandó belső tábla
*  --> $struc_name belső tábla struktúrája (DDIC)
*  --> $pf_status  lista státus beállító form neve - lehet space is, ha
*                   a standard jó. A megadott form-ot a hívó programban
*                   kell definiálni !!
*  --> $user_command lista interaktivitását biztosító form neve - lehet
*                    space is, ha standard jó. A megadott form-ot a hívó
*                    programban kell definiálni !!
*----------------------------------------------------------------------*
FORM COMMON_ALV_GRID_DISPLAY TABLES $I_TABLE
                              USING VALUE($STRUC_NAME)
                                    VALUE($PF_STATUS)
                                    VALUE($USER_COMMAND).
* Lista értékek inicializálása, feltöltése
  L_REPID = SY-REPID.

* ABAP/4 List Viewer hívása
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
      I_SAVE                   = 'X' "variánsok mentése
      "lehetséges
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
*       ALV lista inicializálása
*----------------------------------------------------------------------*
*      -->$title  Címsor szövege
*----------------------------------------------------------------------*
FORM COMMON_ALV_LIST_INIT
                  USING $TITLE
                        $INTERNAL_TABNAM
                        $INCLNAM.


* Lista értékek inicializálása, feltöltése
  L_REPID = SY-REPID.
  CLEAR: GT_LIST_TOP_OF_PAGE[],
         GS_LAYOUT,
         GT_EVENTS[],
         GS_PRINT,
         GT_FIELDCAT[].

* Lista fejléc
  PERFORM COMMON_LIST_TOP_BUILD   USING GT_LIST_TOP_OF_PAGE[]
                                        $TITLE.
* Layout
  PERFORM COMMON_GS_LAYOUT_BUILD  USING GS_LAYOUT.
* Események definiálása (top-of-page)
  PERFORM COMMON_EVENTTAB_BUILD USING GT_EVENTS[].
* Nyomtatás beállítások
  PERFORM COMMON_GS_PRINT_BUILD USING GS_PRINT.
* Mező katalógus
  PERFORM COMMON_GS_FIELD_CATALOG USING GT_FIELDCAT[]
                                        $INTERNAL_TABNAM
                                        $INCLNAM.
ENDFORM.  "COMMON_ALV_LIST_INIT


*&---------------------------------------------------------------------*
*&      Form  COMMON_LIST_TOP_BUILD
*&---------------------------------------------------------------------*
*       Lista fejléc készítés
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

* Cím
  CLEAR L_LINE.
  L_LINE-TYP  = 'A'.
  L_LINE-KEY  = SPACE.
  WRITE: $TITLE TO L_LINE-INFO CENTERED.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Paraméterek
*  CLEAR L_LINE.
*  L_LINE-TYP  = 'S'.
*  L_LINE-KEY  = 'Feldogozási dátum:'.
*  L_LINE-INFO = P_FELDAT.

*  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info1
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Oldal:'.
  L_LINE-INFO =  SY-PAGNO.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info1
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Lista készült:'.
  WRITE: SY-UZEIT TO L_UZEIT.
  WRITE: SY-DATUM TO L_LINE-INFO.
  CONCATENATE L_LINE-INFO L_UZEIT INTO L_LINE-INFO SEPARATED BY SPACE.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info2
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Ügyfél:'.
  CONCATENATE SY-SYSID SY-MANDT
         INTO L_LINE-INFO
    SEPARATED BY '-'.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

* Info3
  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Indította:'.
  L_LINE-INFO = SY-UNAME.
  APPEND L_LINE TO $GT_LIST_TOP_OF_PAGE.

ENDFORM.                               " COMMON_LIST_TOP_BUILD

*---------------------------------------------------------------------*
*       FORM COMMON_TOP_OF_PAGE
*
*---------------------------------------------------------------------*
*       Fejléc kiíráshoz                                              *
*---------------------------------------------------------------------*
FORM COMMON_TOP_OF_PAGE.
  DATA: L_LINE TYPE SLIS_LISTHEADER.

  CLEAR L_LINE.
  L_LINE-TYP  = 'S'.
  L_LINE-KEY  = 'Oldal:'.
  L_LINE-INFO =  SY-PAGNO.
  MODIFY GT_LIST_TOP_OF_PAGE FROM L_LINE INDEX 2.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.

ENDFORM.                               " COMMON_TOP_OF_PAGE


*&---------------------------------------------------------------------*
*&      Form  COMMON_GS_LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       Lista layout definiálása
*----------------------------------------------------------------------*
*      -->$LAYOUT  text
*----------------------------------------------------------------------*
FORM COMMON_GS_LAYOUT_BUILD USING $GS_LAYOUT TYPE SLIS_LAYOUT_ALV.


  $GS_LAYOUT-ZEBRA               = 'X'."Csíkozott sorok
  $GS_LAYOUT-COLWIDTH_OPTIMIZE   = 'X'."Oszlopok optimalizálása
*  $gs_layout-totals_only         = 'X'."Csak az összegek
*  $GS_LAYOUT-TOTALS_BEFORE_ITEMS = 'X'."Összegek a tételek előtt
*  $gs_layout-totals_text         = 'Mindösszesen'(l01).
*  $GS_LAYOUT-SUBTOTALS_TEXT      = 'Részösszeg'(L02).
*   $gs_layout-NO_MIN_LINESIZE = 'X'. " line size = width of the list
  $GS_LAYOUT-GET_SELINFOS = 'X'. " olvassa be a szelekciókat
*  $gs_LAYOUT-GROUP_CHANGE_EDIT = 'X'. " Részösszeg megjel. módosítható
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
*  $gs_layout-group_change_edit = 'X'.  "Felhasználó változtathatja,
*                                       "rendezéskor a subtotal új oldal
*                                       "ra kerüljön, vagy aláhúzással
*                                       "különüljön el
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
*      -->$INCLNAME    Include neve, amelyben a belső tábla deklarálva
*                      van. Csak akkor kell tölteni, ha a belső tábla
*                      nem DDIC struktúraként van definiálva !!
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

  $GS_PRINT-NO_PRINT_SELINFOS  = 'X'.  "Szelekciós info nem kell
  $GS_PRINT-NO_PRINT_LISTINFOS = 'X'.                       "

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
* 1. mező
  CHECK NOT $FIELD1 IS INITIAL.
  WA_SORT-SPOS = 1.
  WA_SORT-FIELDNAME = $FIELD1.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* 2. mező
  CHECK NOT $FIELD2 IS INITIAL.
  WA_SORT-SPOS = 2.
  WA_SORT-FIELDNAME = $FIELD2.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* 3. mező
  CHECK NOT $FIELD3 IS INITIAL.
  WA_SORT-SPOS = 3.
  WA_SORT-FIELDNAME = $FIELD3.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* 4. mező
  CHECK NOT $FIELD4 IS INITIAL.
  WA_SORT-SPOS = 4.
  WA_SORT-FIELDNAME = $FIELD4.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* 5. mező
  CHECK NOT $FIELD5 IS INITIAL.
  WA_SORT-SPOS = 5.
  WA_SORT-FIELDNAME = $FIELD5.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* 6. mező
  CHECK NOT $FIELD6 IS INITIAL.
  WA_SORT-SPOS = 6.
  WA_SORT-FIELDNAME = $FIELD6.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.

* 7. mező
  CHECK NOT $FIELD7 IS INITIAL.
  WA_SORT-SPOS = 7.
  WA_SORT-FIELDNAME = $FIELD7.
  WA_SORT-UP        = 'X'.
  APPEND WA_SORT TO GT_SORT.
ENDFORM.                    " INIT_SORTTAB

*==================================================================*
*           MINTÁK a további ALV-hez kapcsolódó form hívásokra
*==================================================================*


*&---------------------------------------------------------------------*
*&      Form  GT_IT_SORT_INIT
*&---------------------------------------------------------------------*
*       Összegzéshez: sorrend megállapítására
*                     összegzési szintek új oldalra/ azonos oldalra
*----------------------------------------------------------------------*
*      -->P_GT_SORT[]  text
*----------------------------------------------------------------------*
*FORM gt_it_sort_init USING  $gt_sort TYPE slis_t_sortinfo_alv.

*  DATA: l_gt_sort TYPE slis_sortinfo_alv.

* Törzsszám (PERNR)
*  CLEAR: l_gt_sort.
*  l_gt_sort-spos      = 1.
*  l_gt_sort-fieldname = 'PERNR'.
*  l_gt_sort-up        = 'X'.
*  l_gt_sort-subtot    = 'X'.
*  l_gt_sort-group     = 'UL'.          "Váltáskor aláhúzás
*  l_gt_sort-expa      = 1.             "Expand szint
*  APPEND l_gt_sort TO $gt_sort.
*ENDFORM.                               " GT_IT_SORT_INIT



*&---------------------------------------------------------------------*
*&      Form  GT_FIELDCAT_INIT
*&---------------------------------------------------------------------*
*       Mező katalógus definíció
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
*FORM gt_fieldcat_init USING $gt_fieldcat TYPE slis_t_fieldcat_alv.

*  DATA: l_fieldcat TYPE slis_fieldcat_alv.

*  CLEAR l_fieldcat.
*  l_fieldcat-tabname   = 'IT_BER_LIST'.
*  l_fieldcat-fieldname   = 'BETRG'.
*-- Összegzés mezőre
*  l_fieldcat-do_sum       = 'X'.
*-- Mező sorrendbeli eltérés -> az adott mező legyen az első oszlopban
*  l_fieldcat-col_pos     = 1.          "Első oszlopban legyen
*-- Nem megjelenítendő mezők
*  l_fieldcat-no_out      = 'X'.        "ne jelenjen meg
*  APPEND l_fieldcat TO $gt_fieldcat.

*ENDFORM.                               " GT_FIELDCAT_INIT
