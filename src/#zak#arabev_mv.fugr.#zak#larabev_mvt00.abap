*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_ARABEVV................................*
TABLES: /ZAK/AFA_ARABEVV, */ZAK/AFA_ARABEVV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_ARABEVV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_ARABEVV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_ARABEVV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_ARABEVV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ARABEVV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ARABEVV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_ARABEVV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ARABEVV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ARABEVV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_ARABEV                 .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
