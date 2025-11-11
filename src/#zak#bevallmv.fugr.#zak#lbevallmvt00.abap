*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/BEVALLV...................................*
TABLES: /ZAK/BEVALLV, */ZAK/BEVALLV. "view work areas
CONTROLS: TCTRL_/ZAK/BEVALLV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/BEVALLV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/BEVALLV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/BEVALLV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/BEVALLV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/BEVALLV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/BEVALLV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/BEVALLO                    .
