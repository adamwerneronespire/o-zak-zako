*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ARANY_FELDV................................*
TABLES: /ZAK/ARANY_FELDV, */ZAK/ARANY_FELDV. "view work areas
CONTROLS: TCTRL_/ZAK/ARANY_FELDV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/ARANY_FELDV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ARANY_FELDV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ARANY_FELDV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ARANY_FELDV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ARANY_FELDV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ARANY_FELDV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ARANY_FELDV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ARANY_FELDV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ARANY_FELD                 .
