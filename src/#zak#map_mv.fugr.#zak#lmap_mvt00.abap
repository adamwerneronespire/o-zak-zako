*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/MAP........................................*
DATA:  BEGIN OF STATUS_/ZAK/MAP                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ZAK/MAP                      .
CONTROLS: TCTRL_/ZAK/MAP
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: */ZAK/MAP                      .
TABLES: /ZAK/MAP                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
