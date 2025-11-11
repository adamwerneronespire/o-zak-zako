*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/IGABEV_V....................................*
TABLES: /ZAK/IGABEV_V, */ZAK/IGABEV_V. "view work areas
CONTROLS: TCTRL_/ZAK/IGABEV_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/IGABEV_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/IGABEV_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/IGABEV_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGABEV_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGABEV_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/IGABEV_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGABEV_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGABEV_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
TABLES: /ZAK/IGABEV                     .
TABLES: /ZAK/IGSOR                      .
TABLES: /ZAK/IGSORT                     .
