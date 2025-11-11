*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/NAV_ELL_V...................................*
TABLES: /ZAK/NAV_ELL_V, */ZAK/NAV_ELL_V. "view work areas
CONTROLS: TCTRL_/ZAK/NAV_ELL_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/NAV_ELL_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/NAV_ELL_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/NAV_ELL_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/NAV_ELL_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/NAV_ELL_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/NAV_ELL_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/NAV_ELL_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/NAV_ELL_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/NAV_ELL                    .
