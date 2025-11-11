*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ARANY_CUSTV................................*
TABLES: /ZAK/ARANY_CUSTV, */ZAK/ARANY_CUSTV. "view work areas
CONTROLS: TCTRL_/ZAK/ARANY_CUSTV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/ARANY_CUSTV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ARANY_CUSTV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ARANY_CUSTV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ARANY_CUSTV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ARANY_CUSTV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ARANY_CUSTV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ARANY_CUSTV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ARANY_CUSTV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ARANY_CUST                 .
