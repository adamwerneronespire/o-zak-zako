*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/ABEVK_V.....................................*
TABLES: /ZAK/ABEVK_V, */ZAK/ABEVK_V. "view work areas
CONTROLS: TCTRL_/ZAK/ABEVK_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/ABEVK_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/ABEVK_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/ABEVK_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ABEVK_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ABEVK_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/ABEVK_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/ABEVK_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/ABEVK_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/ABEVK                      .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
