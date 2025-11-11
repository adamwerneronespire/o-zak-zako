*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BEVALLP_MV.................................*
TABLES: /ZAK/BEVALLP_MV, */ZAK/BEVALLP_MV. "view work areas
CONTROLS: TCTRL_/ZAK/BEVALLP_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BEVALLP_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BEVALLP_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BEVALLP_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLP_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLP_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BEVALLP_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLP_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLP_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLP                   .
