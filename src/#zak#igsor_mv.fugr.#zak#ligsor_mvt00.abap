*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/IGSOR_V.....................................*
TABLES: /ZAK/IGSOR_V, */ZAK/IGSOR_V. "view work areas
CONTROLS: TCTRL_/ZAK/IGSOR_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/IGSOR_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/IGSOR_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/IGSOR_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGSOR_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGSOR_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/IGSOR_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGSOR_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGSOR_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/IGSOR                      .
TABLES: /ZAK/IGSORT                     .
