*----------------------------------------------------------------------*
***INCLUDE /ZAK/LSTART_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/START_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/START_V-AS4TIME.
  MOVE SY-UNAME TO /ZAK/START_V-AS4USER.

ENDFORM.                    "get_change_data
