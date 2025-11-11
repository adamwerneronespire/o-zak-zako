*----------------------------------------------------------------------*
***INCLUDE /ZAK/LIGABEV_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/IGABEV_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/IGABEV_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/IGABEV_V-UNAME.


ENDFORM.                    "GET_CHANGE_DATA
