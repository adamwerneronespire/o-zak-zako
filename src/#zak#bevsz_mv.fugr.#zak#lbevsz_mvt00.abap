*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BEVALLSZ_MV.................................*
TABLES: /ZAK/BEVALLSZ_MV, */ZAK/BEVALLSZ_MV. "view work areas
CONTROLS: TCTRL_/ZAK/BEVALLSZ_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BEVALLSZ_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BEVALLSZ_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BEVALLSZ_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLSZ_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLSZ_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BEVALLSZ_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLSZ_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLSZ_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLSZ                   .
