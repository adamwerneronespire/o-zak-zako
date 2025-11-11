*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/OUT_BELNR_V.................................*
TABLES: /ZAK/OUT_BELNR_V, */ZAK/OUT_BELNR_V. "view work areas
CONTROLS: TCTRL_/ZAK/OUT_BELNR_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/OUT_BELNR_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/OUT_BELNR_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/OUT_BELNR_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/OUT_BELNR_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/OUT_BELNR_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/OUT_BELNR_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/OUT_BELNR_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/OUT_BELNR_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/OUT_BELNR                  .
