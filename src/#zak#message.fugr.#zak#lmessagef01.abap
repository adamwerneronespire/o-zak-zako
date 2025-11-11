*----------------------------------------------------------------------*
***INCLUDE /ZAK/LMESSAGEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_mess_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_RETURN  text
*      -->P_I_MESS_TAB  text
*----------------------------------------------------------------------*
FORM get_mess_tab TABLES   $return   STRUCTURE bapiret2
                           $mess_tab STRUCTURE smesg.

  LOOP AT $return.
    CLEAR $mess_tab.
    MOVE sy-tabix           TO $mess_tab-zeile.
    MOVE $return-type       TO $mess_tab-msgty.
    MOVE $return-message    TO $mess_tab-text.
    MOVE $return-id         TO $mess_tab-arbgb.
    MOVE $return-number     TO $mess_tab-txtnr.
    MOVE $return-message_v1 TO $mess_tab-msgv1.
    MOVE $return-message_v2 TO $mess_tab-msgv2.
    MOVE $return-message_v3 TO $mess_tab-msgv3.
    MOVE $return-message_v4 TO $mess_tab-msgv4.
    APPEND $mess_tab.
  ENDLOOP.

ENDFORM.                    " get_mess_tab
