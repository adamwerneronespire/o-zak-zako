*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/PENZT_FORGV................................*
TABLES: /ZAK/PENZT_FORGV, */ZAK/PENZT_FORGV. "view work areas
CONTROLS: TCTRL_/ZAK/PENZT_FORGV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/PENZT_FORGV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/PENZT_FORGV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/PENZT_FORGV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/PENZT_FORGV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/PENZT_FORGV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/PENZT_FORGV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/PENZT_FORGV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/PENZT_FORGV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/PENZATV                    .
TABLES: /ZAK/PENZT_FORG                 .
