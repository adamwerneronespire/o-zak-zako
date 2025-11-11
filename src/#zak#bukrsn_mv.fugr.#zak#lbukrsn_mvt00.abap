*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BUKRSN_MV...................................*
TABLES: /ZAK/BUKRSN_MV, */ZAK/BUKRSN_MV. "view work areas
CONTROLS: TCTRL_/ZAK/BUKRSN_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BUKRSN_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BUKRSN_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BUKRSN_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BUKRSN_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BUKRSN_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BUKRSN_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BUKRSN_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BUKRSN_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BUKRSN                     .
