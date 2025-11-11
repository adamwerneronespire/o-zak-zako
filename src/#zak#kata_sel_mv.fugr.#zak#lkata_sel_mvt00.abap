*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/KATA_SEL_V..................................*
TABLES: /ZAK/KATA_SEL_V, */ZAK/KATA_SEL_V. "view work areas
CONTROLS: TCTRL_/ZAK/KATA_SEL_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/KATA_SEL_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/KATA_SEL_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/KATA_SEL_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/KATA_SEL_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/KATA_SEL_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/KATA_SEL_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/KATA_SEL_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/KATA_SEL_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/KATA_SEL                   .
