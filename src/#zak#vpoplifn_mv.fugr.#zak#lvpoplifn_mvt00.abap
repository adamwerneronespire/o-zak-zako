*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/VPOP_LIFNRV................................*
TABLES: /ZAK/VPOP_LIFNRV, */ZAK/VPOP_LIFNRV. "view work areas
CONTROLS: TCTRL_/ZAK/VPOP_LIFNRV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/VPOP_LIFNRV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/VPOP_LIFNRV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/VPOP_LIFNRV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/VPOP_LIFNRV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/VPOP_LIFNRV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/VPOP_LIFNRV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/VPOP_LIFNRV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/VPOP_LIFNRV_TOTAL.

*.........table declarations:.................................*
TABLES: LFA1                           .
TABLES: /ZAK/VPOP_LIFNR                 .
