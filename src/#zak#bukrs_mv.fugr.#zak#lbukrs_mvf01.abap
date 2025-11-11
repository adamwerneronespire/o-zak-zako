*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBUKRS_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BUKRS_MV-DATUM.
  MOVE SY-UZEIT TO /ZAK/BUKRS_MV-UZEIT.
  MOVE SY-UNAME TO /ZAK/BUKRS_MV-UNAME.

ENDFORM.                    "GET_CHANGE_DATA
