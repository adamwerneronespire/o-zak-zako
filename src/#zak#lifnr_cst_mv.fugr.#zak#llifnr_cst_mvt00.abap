*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/LIFNR_CST_V.................................*
TABLES: /ZAK/LIFNR_CST_V, */ZAK/LIFNR_CST_V. "view work areas
CONTROLS: TCTRL_/ZAK/LIFNR_CST_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/LIFNR_CST_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/LIFNR_CST_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/LIFNR_CST_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/LIFNR_CST_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/LIFNR_CST_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/LIFNR_CST_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/LIFNR_CST_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/LIFNR_CST_V_TOTAL.

*.........table declarations:.................................*
TABLES: LFA1                           .
TABLES: /ZAK/LIFNR_CST                  .
