*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_BLARTNV................................*
TABLES: /ZAK/AFA_BLARTNV, */ZAK/AFA_BLARTNV. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_BLARTNV
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_BLARTNV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_BLARTNV.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_BLARTNV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_BLARTNV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_BLARTNV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_BLARTNV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_BLARTNV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_BLARTNV_TOTAL.

*.........table declarations:.................................*
TABLES: T003                           .
TABLES: T003T                          .
TABLES: /ZAK/AFA_BLARTNM                .
