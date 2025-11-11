*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BEVALLB_V...................................*
TABLES: /ZAK/BEVALLB_V, */ZAK/BEVALLB_V. "view work areas
CONTROLS: TCTRL_/ZAK/BEVALLB_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ZAK/BEVALLB_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BEVALLB_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BEVALLB_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLB_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLB_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BEVALLB_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLB_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLB_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
