*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 2006.02.27 at 15:34:51 by user FMCTI00DBG
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_ATV_V...................................*
TABLES: /ZAK/AFA_ATV_V, */ZAK/AFA_ATV_V. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_ATV_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_ATV_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_ATV_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_ATV_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ATV_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ATV_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_ATV_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ATV_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ATV_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_ATV                    .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
