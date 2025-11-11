*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BEVALLI_MV..................................*
TABLES: /ZAK/BEVALLI_MV, */ZAK/BEVALLI_MV. "view work areas
CONTROLS: TCTRL_/ZAK/BEVALLI_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BEVALLI_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BEVALLI_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BEVALLI_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLI_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLI_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BEVALLI_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLI_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLI_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLI                    .
