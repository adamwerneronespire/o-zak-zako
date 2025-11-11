*----------------------------------------------------------------------*
***INCLUDE /ZAK/LRRABEV_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFA_RRABEVV-DATUM.
  MOVE SY-UZEIT TO /ZAK/AFA_RRABEVV-UZEIT.
  MOVE SY-UNAME TO /ZAK/AFA_RRABEVV-UNAME.

ENDFORM.                    "get_change_data
