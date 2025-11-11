*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_FKABEVV................................*
TABLES: /ZAK/AFA_FKABEVV, */ZAK/AFA_FKABEVV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_FKABEVV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_FKABEVV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_FKABEVV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_FKABEVV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_FKABEVV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_FKABEVV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_FKABEVV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_FKABEVV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_FKABEVV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_FKABEV                 .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
