*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_RRABEVV................................*
TABLES: /ZAK/AFA_RRABEVV, */ZAK/AFA_RRABEVV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_RRABEVV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_RRABEVV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_RRABEVV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_RRABEVV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_RRABEVV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_RRABEVV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_RRABEVV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_RRABEVV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_RRABEVV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_RRABEV                 .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
