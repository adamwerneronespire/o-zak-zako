*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/GET_IDSZ_MV.................................*
TABLES: /ZAK/GET_IDSZ_MV, */ZAK/GET_IDSZ_MV. "view work areas
CONTROLS: TCTRL_/ZAK/GET_IDSZ_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/GET_IDSZ_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/GET_IDSZ_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/GET_IDSZ_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/GET_IDSZ_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/GET_IDSZ_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/GET_IDSZ_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/GET_IDSZ_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/GET_IDSZ_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/GET_IDSZ                   .
