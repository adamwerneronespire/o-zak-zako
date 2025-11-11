*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BEVALLC_V...................................*
TABLES: /ZAK/BEVALLC_V, */ZAK/BEVALLC_V. "view work areas
CONTROLS: TCTRL_/ZAK/BEVALLC_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ZAK/BEVALLC_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BEVALLC_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BEVALLC_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLC_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLC_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BEVALLC_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLC_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLC_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLC                    .
