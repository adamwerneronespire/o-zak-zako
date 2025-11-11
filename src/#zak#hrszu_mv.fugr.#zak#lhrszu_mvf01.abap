*----------------------------------------------------------------------*
***INCLUDE /ZAK/LHRSZU_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/HRSZU_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/HRSZU_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/HRSZU_V-UNAME.

ENDFORM.                    "GET_CHANGE_DATA
