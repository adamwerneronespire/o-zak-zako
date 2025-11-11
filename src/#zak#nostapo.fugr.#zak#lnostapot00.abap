*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /ZAK/NOSTAPO.....................................*
DATA:  BEGIN OF STATUS_/ZAK/NOSTAPO                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ZAK/NOSTAPO                   .
CONTROLS: TCTRL_/ZAK/NOSTAPO
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: */ZAK/NOSTAPO                   .
TABLES: /ZAK/NOSTAPO                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
