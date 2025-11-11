*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_MWSKZNV................................*
TABLES: /ZAK/AFA_MWSKZNV, */ZAK/AFA_MWSKZNV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_MWSKZNV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_MWSKZNV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_MWSKZNV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_MWSKZNV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_MWSKZNV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_MWSKZNV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_MWSKZNV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_MWSKZNV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_MWSKZNV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_MWSKZNM                .
