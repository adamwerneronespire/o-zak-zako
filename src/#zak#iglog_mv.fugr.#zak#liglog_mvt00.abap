*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/IGLOG_V.....................................*
TABLES: /ZAK/IGLOG_V, */ZAK/IGLOG_V. "view work areas
CONTROLS: TCTRL_/ZAK/IGLOG_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/IGLOG_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/IGLOG_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/IGLOG_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGLOG_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGLOG_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/IGLOG_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGLOG_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGLOG_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/IGLOG                      .
