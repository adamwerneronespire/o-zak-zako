*&---------------------------------------------------------------------*
*&  Include           /ZAK/ALV_GRID_ALAP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Adatdeklarációk
*&---------------------------------------------------------------------*
DATA: GT_DATA     TYPE TY_DATA,
      GS_DATA     LIKE LINE OF GT_DATA,
      GV_PRGNAME  TYPE TRDIRT-TEXT,
      GT_DATA_TMP TYPE TY_DATA.

*&---------------------------------------------------------------------*
*& ALV Adatok
*&---------------------------------------------------------------------*
DATA: GO_ALV  TYPE REF TO CL_GUI_ALV_GRID,
      GO_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_BACKCONT TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_EVT  TYPE REF TO LCL_EVENT_HANDLER,
      GT_FCAT TYPE LVC_T_FCAT,
      GS_FCAT TYPE LVC_S_FCAT,
      GS_LAYO TYPE LVC_S_LAYO,
      GS_VARI TYPE DISVARIANT,
      GT_ROWS TYPE LVC_T_ROID,
      GV_MOD  TYPE XFELD.

DATA: GV_OK_9000  TYPE OK.

FIELD-SYMBOLS: <FS_FCAT> TYPE LVC_S_FCAT,
               <FS_ANY>  TYPE ANY.
*&---------------------------------------------------------------------*
*& ALV Makrók
*&---------------------------------------------------------------------*
* mező elrejtése
DEFINE M_HIDE_FIELD.
  READ TABLE &1 ASSIGNING <FS_FCAT>
  WITH KEY FIELDNAME = &2.
  IF SY-SUBRC EQ 0.
    <FS_FCAT>-NO_OUT = 'X'.
  ENDIF.
END-OF-DEFINITION.

* hotspot megadása
DEFINE M_HOTSPOT.
  READ TABLE &1 ASSIGNING <FS_FCAT>
  WITH KEY FIELDNAME = &2.
  IF SY-SUBRC EQ 0.
    <FS_FCAT>-HOTSPOT = 'X'.
  ENDIF.
END-OF-DEFINITION.

* mező módosítása
DEFINE M_MODIFY_FIELD.
  READ TABLE &1 ASSIGNING <FS_FCAT>
  WITH KEY FIELDNAME = &2.
  IF SY-SUBRC EQ 0.
    ASSIGN COMPONENT &3 OF STRUCTURE <FS_FCAT> TO <FS_ANY>.
    IF SY-SUBRC EQ 0.
      <FS_ANY> = &4.
    ENDIF.
  ENDIF.
END-OF-DEFINITION.

DEFINE M_CREATE_FCAT.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = &1
    CHANGING
      CT_FIELDCAT            = &2
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
  ENDIF.
END-OF-DEFINITION.

DEFINE M_TYPICAL_LAYO.
  &1-CWIDTH_OPT = 'X'.
  &1-ZEBRA = 'X'.

END-OF-DEFINITION.

DEFINE M_CHECKBOX.
  LOOP AT GT_FCAT INTO GS_FCAT WHERE FIELDNAME EQ &1.
    GS_FCAT-CHECKBOX = 'X'.
    MODIFY GT_FCAT FROM GS_FCAT TRANSPORTING CHECKBOX.
  ENDLOOP.
END-OF-DEFINITION.

DEFINE M_GET_PRG_NAME.
  SELECT SINGLE TEXT FROM TRDIRT INTO GV_PRGNAME
    WHERE SPRSL EQ SY-LANGU
      AND NAME  EQ SY-CPROG.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*& Eseménykezelő osztály
*&---------------------------------------------------------------------*

CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                           IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO,

      HANDLE_BUTTON_CLICK FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
                          IMPORTING ES_COL_ID ES_ROW_NO,

      HANDLE_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
                          IMPORTING E_COLUMN ES_ROW_NO.

ENDCLASS.                    "lcl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_HOTSPOT_CLICK USING E_COLUMN_ID
                                       E_ROW_ID-INDEX.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_BUTTON_CLICK.
    PERFORM HANDLE_BUTTON_CLICK USING ES_COL_ID-FIELDNAME
                                      ES_ROW_NO-ROW_ID.
  ENDMETHOD.                    "handle_button_click

  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM HANDLE_DOUBLE_CLICK USING E_COLUMN-FIELDNAME
                                      ES_ROW_NO-ROW_ID.
  ENDMETHOD.                    "handle_double_click
ENDCLASS.                    "lcl_event_handler IMPLEMENTATION
