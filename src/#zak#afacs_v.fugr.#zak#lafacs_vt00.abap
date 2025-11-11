*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFACS_V.....................................*
TABLES: /ZAK/AFACS_V, */ZAK/AFACS_V. "view work areas
CONTROLS: TCTRL_/ZAK/AFACS_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFACS_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFACS_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFACS_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFACS_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFACS_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFACS_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFACS_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFACS_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFACS                      .
