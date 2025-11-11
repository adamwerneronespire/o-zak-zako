*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_LIFKNMV................................*
TABLES: /ZAK/AFA_LIFKNMV, */ZAK/AFA_LIFKNMV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_LIFKNMV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_LIFKNMV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_LIFKNMV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_LIFKNMV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_LIFKNMV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_LIFKNMV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_LIFKNMV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_LIFKNMV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_LIFKNMV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_LIFKNM                 .
