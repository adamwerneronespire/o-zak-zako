*----------------------------------------------------------------------*
***INCLUDE /ZAK/LMGCIM_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/MGCIM_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/MGCIM_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/MGCIM_V-UNAME.

ENDFORM.                    "GET_CHANGE_DATA
