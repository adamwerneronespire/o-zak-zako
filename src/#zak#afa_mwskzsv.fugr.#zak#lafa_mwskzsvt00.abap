*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_MWSKZSV................................*
TABLES: /ZAK/AFA_MWSKZSV, */ZAK/AFA_MWSKZSV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_MWSKZSV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_MWSKZSV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_MWSKZSV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_MWSKZSV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_MWSKZSV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_MWSKZSV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_MWSKZSV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_MWSKZSV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_MWSKZSV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_MWSKZNS                .
