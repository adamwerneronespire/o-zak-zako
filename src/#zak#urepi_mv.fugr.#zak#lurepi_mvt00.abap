*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/UREPI_MV....................................*
TABLES: /ZAK/UREPI_MV, */ZAK/UREPI_MV. "view work areas
CONTROLS: TCTRL_/ZAK/UREPI_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/UREPI_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/UREPI_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/UREPI_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/UREPI_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/UREPI                      .
