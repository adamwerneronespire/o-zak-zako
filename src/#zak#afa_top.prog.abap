***INCLUDE /ZAK/AFA_TOP .
*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
 TABLES: BKPF,
         BSEG,
         GLT0,
         SKB1,
         T001,
         /ZAK/BSET.

*&---------------------------------------------------------------------*
*& MUNKATERÜLETEK                                                      *
*&---------------------------------------------------------------------*
 DATA: W_BSEG     TYPE BSEG,
       W_BKPF     TYPE BKPF,
       W_GLTO     TYPE GLT0,
       W_/ZAK/BSET TYPE /ZAK/BSET,
       W_OUTTAB   TYPE /ZAK/EGYEZTETALV,
       W_ITEM     TYPE /ZAK/EGYTETELALV,
       W_OUTTAB_I TYPE /ZAK/EGYEZTALV_I,
       W_ITEM_I   TYPE /ZAK/IDTETEL_ALV,
       W_OUTTAB2  TYPE /ZAK/EGYEZT2_ALV,
       W_ITEM2    TYPE /ZAK/EGY2_TETALV.

*&---------------------------------------------------------------------*
*& BELSŐ TÁBLÁK                                                        *
*&---------------------------------------------------------------------*

 DATA: I_BSEG   TYPE STANDARD TABLE OF BSEG              INITIAL SIZE 0,
       I_BKPF   TYPE STANDARD TABLE OF BKPF              INITIAL SIZE 0,
       I_GLT0   TYPE STANDARD TABLE OF GLT0              INITIAL SIZE 0,
       I_/ZAK/BSET TYPE STANDARD TABLE OF /ZAK/BSET        INITIAL SIZE 0,
       I_OUTTAB TYPE STANDARD TABLE OF /ZAK/EGYEZTETALV INITIAL SIZE 0,
       I_OUTTAB_I TYPE  STANDARD TABLE OF /ZAK/EGYEZTALV_I
                                                         INITIAL SIZE 0,
       I_OUTTAB2  TYPE STANDARD TABLE OF /ZAK/EGYEZT2_ALV
                                                         INITIAL SIZE 0,

       I_ITEM   TYPE STANDARD TABLE OF /ZAK/EGYTETELALV INITIAL SIZE 0,
*++0001 2008.11.05 Balázs Gábor (Fmc)
     I_ITEM_ALL TYPE STANDARD TABLE OF /ZAK/EGYTETELALV INITIAL SIZE 0,
*--0001 2008.11.05 Balázs Gábor (Fmc)
       I_ITEM_I TYPE STANDARD TABLE OF /ZAK/IDTETEL_ALV INITIAL SIZE 0,
       I_ITEM2  TYPE STANDARD TABLE OF /ZAK/EGY2_TETALV INITIAL SIZE 0
       .
*++BG 2007.10.15
*MAKRO definiálás range feltöltéshez
 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   APPEND &1.
 END-OF-DEFINITION.
*--BG 2007.10.15
