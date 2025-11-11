*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/UREPI_FELDV................................*
TABLES: /ZAK/UREPI_FELDV, */ZAK/UREPI_FELDV. "view work areas
CONTROLS: TCTRL_/ZAK/UREPI_FELDV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/UREPI_FELDV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/UREPI_FELDV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/UREPI_FELDV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_FELDV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_FELDV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/UREPI_FELDV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_FELDV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_FELDV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/UREPI_FELD                 .
