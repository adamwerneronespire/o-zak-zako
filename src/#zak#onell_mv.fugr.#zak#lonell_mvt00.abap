*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ONELL_BOOKV................................*
TABLES: /ZAK/ONELL_BOOKV, */ZAK/ONELL_BOOKV. "view work areas
CONTROLS: TCTRL_/ZAK/ONELL_BOOKV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/ONELL_BOOKV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ONELL_BOOKV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ONELL_BOOKV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ONELL_BOOKV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ONELL_BOOKV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ONELL_BOOKV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ONELL_BOOKV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ONELL_BOOKV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ONELL_BOOK                 .
