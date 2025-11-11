*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/UREPI_LOG_V.................................*
TABLES: /ZAK/UREPI_LOG_V, */ZAK/UREPI_LOG_V. "view work areas
CONTROLS: TCTRL_/ZAK/UREPI_LOG_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/UREPI_LOG_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/UREPI_LOG_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/UREPI_LOG_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_LOG_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_LOG_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/UREPI_LOG_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/UREPI_LOG_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/UREPI_LOG_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/UREPI_LOG                  .
