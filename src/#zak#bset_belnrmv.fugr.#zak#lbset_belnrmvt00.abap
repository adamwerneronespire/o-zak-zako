*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BSET_BELNRV................................*
TABLES: /ZAK/BSET_BELNRV, */ZAK/BSET_BELNRV. "view work areas
CONTROLS: TCTRL_/ZAK/BSET_BELNRV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BSET_BELNRV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BSET_BELNRV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BSET_BELNRV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BSET_BELNRV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BSET_BELNRV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BSET_BELNRV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BSET_BELNRV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BSET_BELNRV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BSET_BELNR                 .
