*----------------------------------------------------------------------*
***INCLUDE /ZAK/LIGSOR_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/IGSOR_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/IGSOR_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/IGSOR_V-UNAME.


ENDFORM.                    "GET_CHANGE_DATA
