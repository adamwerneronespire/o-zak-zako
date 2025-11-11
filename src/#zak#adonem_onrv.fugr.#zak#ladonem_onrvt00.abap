*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ADONEM_ONRV................................*
TABLES: /ZAK/ADONEM_ONRV, */ZAK/ADONEM_ONRV. "view work areas
CONTROLS: TCTRL_/ZAK/ADONEM_ONRV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/ADONEM_ONRV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ADONEM_ONRV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ADONEM_ONRV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ADONEM_ONRV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ADONEM_ONRV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ADONEM_ONRV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ADONEM_ONRV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ADONEM_ONRV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ADONEM_ONR                 .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
