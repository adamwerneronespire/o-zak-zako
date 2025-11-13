FUNCTION /ZAK/MESSAGE_SHOW.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  TABLES
*"      T_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA I_MESS_TAB TYPE SMESG OCCURS 0 WITH HEADER LINE.
*++2165 #06.
  DATA L_LIST_TYPE TYPE C.
*--2165 #06.
  CHECK NOT T_RETURN[] IS INITIAL.


  PERFORM GET_MESS_TAB TABLES T_RETURN
                              I_MESS_TAB.


  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT I_MESS_TAB.
    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        ARBGB                  = I_MESS_TAB-ARBGB
*       EXCEPTION_IF_NOT_ACTIVE      = 'X'
        MSGTY                  = I_MESS_TAB-MSGTY
        MSGV1                  = I_MESS_TAB-MSGV1
        MSGV2                  = I_MESS_TAB-MSGV2
        MSGV3                  = I_MESS_TAB-MSGV3
        MSGV4                  = I_MESS_TAB-MSGV4
        TXTNR                  = I_MESS_TAB-TXTNR
        ZEILE                  = I_MESS_TAB-ZEILE
      EXCEPTIONS
        MESSAGE_TYPE_NOT_VALID = 1
        NOT_ACTIVE             = 2
        OTHERS                 = 3.
  ENDLOOP.

*++2165 #06.
  IF NOT SY-BATCH IS INITIAL.
    L_LIST_TYPE = 'L'. "List
  ELSE.
    L_LIST_TYPE = 'J'.
  ENDIF.
*--2165 #06.
  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      OBJECT          = 'Adatfeltöltés üzenetei'(001)
*++2165 #06.
      BATCH_LIST_TYPE = L_LIST_TYPE.
*--2165 #06.

ENDFUNCTION.
