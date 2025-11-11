*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_ELV...................................*
TABLES: /ZAK/AFA_ELV, */ZAK/AFA_ELV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_ELV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_ELV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_ELV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_ELV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ELV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ELV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_ELV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_ELV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_ELV_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_ELO                    .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
