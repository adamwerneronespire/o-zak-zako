*----------------------------------------------------------------------*
***INCLUDE /ZAK/LARANY_MVF01 .
*----------------------------------------------------------------------*

FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/ARANY_CUSTV-DATUM.
  MOVE SY-UZEIT TO /ZAK/ARANY_CUSTV-UZEIT.
  MOVE SY-UNAME TO /ZAK/ARANY_CUSTV-UNAME.

ENDFORM.                    "get_change_data
