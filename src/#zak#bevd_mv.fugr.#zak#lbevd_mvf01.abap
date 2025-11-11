*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBEVD_MVF01 .
*----------------------------------------------------------------------*

FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BEVALLD_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/BEVALLD_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/BEVALLD_V-UNAME.

ENDFORM.
