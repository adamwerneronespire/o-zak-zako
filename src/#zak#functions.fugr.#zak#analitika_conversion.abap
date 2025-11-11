FUNCTION /ZAK/ANALITIKA_CONVERSION.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"----------------------------------------------------------------------
  DATA: V_LAST_DATE  TYPE D,
        V_NEW_BTYPE  TYPE /ZAK/BTYPE,
        V_BTYPART    TYPE /ZAK/BTYPART.

  LOOP AT T_ANALITIKA INTO W_/ZAK/ANALITIKA.

* Determine the last day of the declaration
    PERFORM GET_LAST_DAY_OF_PERIOD USING W_/ZAK/ANALITIKA-GJAHR
                                         W_/ZAK/ANALITIKA-MONAT
*++PTGSZLAA #01. 2014.03.03
                                         W_/ZAK/ANALITIKA-BTYPE
*--PTGSZLAA #01. 2014.03.03
                                    CHANGING V_LAST_DATE.

* Is the declaration type valid on the last day?
* If not -> conversion required
    PERFORM GET_BEVALL USING W_/ZAK/ANALITIKA-BUKRS
                             W_/ZAK/ANALITIKA-BTYPE
                             V_LAST_DATE
                       CHANGING V_BTYPART
                                V_NEW_BTYPE.

* Convert when the type differs
    IF NOT V_NEW_BTYPE IS INITIAL.

      IF V_NEW_BTYPE NE W_/ZAK/ANALITIKA-BTYPE.

        PERFORM CONVERT_ITEM CHANGING W_/ZAK/ANALITIKA.
        MODIFY T_ANALITIKA FROM W_/ZAK/ANALITIKA.

      ENDIF.
    ELSE.
      MESSAGE E126(/ZAK/ZAK) WITH W_/ZAK/ANALITIKA-BUKRS
                             V_BTYPART
                             V_LAST_DATE.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
