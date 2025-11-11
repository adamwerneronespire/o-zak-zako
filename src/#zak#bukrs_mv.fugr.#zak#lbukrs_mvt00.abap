*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BUKRS_MV....................................*
TABLES: /ZAK/BUKRS_MV, */ZAK/BUKRS_MV. "view work areas
CONTROLS: TCTRL_/ZAK/BUKRS_MV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BUKRS_MV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BUKRS_MV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BUKRS_MV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BUKRS_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BUKRS_MV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BUKRS_MV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BUKRS_MV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BUKRS_MV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BUKRS                      .
