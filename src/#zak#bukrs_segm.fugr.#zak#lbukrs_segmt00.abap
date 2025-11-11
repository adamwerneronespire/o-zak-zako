*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BUKRS_SEGMV................................*
TABLES: /ZAK/BUKRS_SEGMV, */ZAK/BUKRS_SEGMV. "view work areas
CONTROLS: TCTRL_/ZAK/BUKRS_SEGMV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BUKRS_SEGMV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BUKRS_SEGMV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BUKRS_SEGMV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BUKRS_SEGMV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BUKRS_SEGMV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BUKRS_SEGMV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BUKRS_SEGMV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BUKRS_SEGMV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BUKRS_SEGM                 .
