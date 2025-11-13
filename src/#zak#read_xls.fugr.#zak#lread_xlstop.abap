FUNCTION-POOL /ZAK/READ_XLS.                "MESSAGE-ID ..
*&---------------------------------------------------------------------*
*& Tables                                                              *
*&---------------------------------------------------------------------*
TABLES: SKB1,
        T001.

INCLUDE: /ZAK/READ_TOP.
*&---------------------------------------------------------------------*
*& WORK AREAS                                                          *
*&---------------------------------------------------------------------*
DATA: W_XLS    TYPE ALSMEX_TABLINE,
      W_DD03P  TYPE DD03P,
      W_RETURN LIKE BAPIRETURN,
      W_HIBA   TYPE /ZAK/ADAT_HIBA,
      W_LINE   TYPE /ZAK/LINE.
*&---------------------------------------------------------------------*
*& INTERNAL TABLES                                                     *
*&---------------------------------------------------------------------*
DATA: I_XLS TYPE STANDARD TABLE OF ALSMEX_TABLINE INITIAL SIZE 0 .
* Error description table
DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0,
      I_LINE TYPE STANDARD TABLE OF /ZAK/LINE        INITIAL SIZE 0.

* Variables
