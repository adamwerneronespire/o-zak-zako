*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_ALAP_V..................................*
TABLES: /ZAK/AFA_ALAP_V, */ZAK/AFA_ALAP_V. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_ALAP_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_ALAP_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_ALAP_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_ALAP_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ALAP_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ALAP_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_ALAP_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ALAP_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ALAP_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_ALAP                   .
