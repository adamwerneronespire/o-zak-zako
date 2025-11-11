*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/START_V.....................................*
TABLES: /ZAK/START_V, */ZAK/START_V. "view work areas
CONTROLS: TCTRL_/ZAK/START_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ZAK/START_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/START_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/START_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/START_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/START_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/START_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/START_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/START_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/START                      .
