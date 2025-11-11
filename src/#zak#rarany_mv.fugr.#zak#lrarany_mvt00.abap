*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_RARANYV................................*
TABLES: /ZAK/AFA_RARANYV, */ZAK/AFA_RARANYV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_RARANYV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_RARANYV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_RARANYV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_RARANYV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_RARANYV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_RARANYV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_RARANYV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_RARANYV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_RARANYV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_RARANY                 .
