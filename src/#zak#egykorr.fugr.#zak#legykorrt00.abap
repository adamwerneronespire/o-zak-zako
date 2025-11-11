*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/EGYKORR.....................................*
DATA:  BEGIN OF STATUS_/ZAK/EGYKORR                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ZAK/EGYKORR                   .
CONTROLS: TCTRL_/ZAK/EGYKORR
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: */ZAK/EGYKORR                   .
TABLES: /ZAK/EGYKORR                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
