FUNCTION /ZAK/READ_FILE_EXIT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"----------------------------------------------------------------------
  DATA L_TRUE.

* Setting dynamic page number handling!
  LOOP AT T_ANALITIKA INTO W_/ZAK/ANALITIKA.
*
*      PERFORM get_abev USING w_/zak/analitika-abev
*                       CHANGING w_/zak/analitika-valami.
*       Tax base
*        MOVE '6306'  TO w_/zak/analitika-abevaz.
*        MOVE '0001' TO w_/zak/analitika-valami.
*        APPEND w_/zak/analitika TO t_analitika.
  ENDLOOP.

ENDFUNCTION.
