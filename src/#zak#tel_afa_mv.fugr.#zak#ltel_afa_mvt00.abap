*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/TEL_AFA_V...................................*
TABLES: /ZAK/TEL_AFA_V, */ZAK/TEL_AFA_V. "view work areas
CONTROLS: TCTRL_/ZAK/TEL_AFA_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/TEL_AFA_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/TEL_AFA_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/TEL_AFA_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/TEL_AFA_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/TEL_AFA_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/TEL_AFA_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/TEL_AFA_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/TEL_AFA_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/TEL_AFA                    .
