*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/IGCUST_V....................................*
TABLES: /ZAK/IGCUST_V, */ZAK/IGCUST_V. "view work areas
CONTROLS: TCTRL_/ZAK/IGCUST_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/IGCUST_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/IGCUST_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/IGCUST_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGCUST_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGCUST_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/IGCUST_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/IGCUST_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/IGCUST_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/IGCUST                     .
