*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BSET_MV.....................................*
TABLES: /ZAK/BSET_MV, */ZAK/BSET_MV. "view work areas
CONTROLS: TCTRL_/ZAK/BSET_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BSET_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BSET_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BSET_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BSET_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BSET_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BSET_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BSET_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BSET_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BSET                       .
