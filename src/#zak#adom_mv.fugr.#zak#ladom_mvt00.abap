*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ADONEM_V....................................*
TABLES: /ZAK/ADONEM_V, */ZAK/ADONEM_V. "view work areas
CONTROLS: TCTRL_/ZAK/ADONEM_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ZAK/ADONEM_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ADONEM_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ADONEM_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ADONEM_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ADONEM_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ADONEM_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ADONEM_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ADONEM_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ADONEM                     .
TABLES: /ZAK/ADONEMT                    .
