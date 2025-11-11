*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBUKRSN_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BUKRSN_MV-DATUM.
  MOVE SY-UZEIT TO /ZAK/BUKRSN_MV-UZEIT.
  MOVE SY-UNAME TO /ZAK/BUKRSN_MV-UNAME.

ENDFORM.                    "GET_CHANGE_DATA
