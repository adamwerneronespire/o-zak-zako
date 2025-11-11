*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ONY_NYLAP_V.................................*
TABLES: /ZAK/ONY_NYLAP_V, */ZAK/ONY_NYLAP_V. "view work areas
CONTROLS: TCTRL_/ZAK/ONY_NYLAP_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/ONY_NYLAP_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ONY_NYLAP_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ONY_NYLAP_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ONY_NYLAP_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ONY_NYLAP_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ONY_NYLAP_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ONY_NYLAP_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ONY_NYLAP_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ONY_NYLAP                  .
