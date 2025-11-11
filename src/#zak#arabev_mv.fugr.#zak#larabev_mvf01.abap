*----------------------------------------------------------------------*
***INCLUDE /ZAK/LARABEV_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFA_ARABEVV-DATUM.
  MOVE SY-UZEIT TO /ZAK/AFA_ARABEVV-UZEIT.
  MOVE SY-UNAME TO /ZAK/AFA_ARABEVV-UNAME.

ENDFORM.                    "get_change_data
