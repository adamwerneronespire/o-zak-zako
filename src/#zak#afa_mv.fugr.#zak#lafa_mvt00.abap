*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/AFA_CUST_V..................................*
TABLES: /ZAK/AFA_CUST_V, */ZAK/AFA_CUST_V. "view work areas
CONTROLS: TCTRL_/ZAK/AFA_CUST_V
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_/ZAK/AFA_CUST_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ZAK/AFA_CUST_V.
* Table for entries selected to show on screen
DATA: BEGIN OF /ZAK/AFA_CUST_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_CUST_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_CUST_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ZAK/AFA_CUST_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ZAK/AFA_CUST_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ZAK/AFA_CUST_V_TOTAL.

*.........table declarations:.................................*
TABLES: /ZAK/AFA_CUST                   .
TABLES: /ZAK/BEVALLB                    .
TABLES: /ZAK/BEVALLBT                   .
