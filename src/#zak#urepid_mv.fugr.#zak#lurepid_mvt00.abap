*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/UREPI_DATAV................................*
TABLES: /ZAK/UREPI_DATAV, */ZAK/UREPI_DATAV. "view work areas
CONTROLS: TCTRL_/ZAK/UREPI_DATAV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/UREPI_DATAV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/UREPI_DATAV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/UREPI_DATAV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_DATAV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_DATAV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/UREPI_DATAV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_DATAV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_DATAV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/UREPIDATA                 .
