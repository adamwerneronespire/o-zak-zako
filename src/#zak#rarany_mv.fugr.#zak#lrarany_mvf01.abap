*----------------------------------------------------------------------*
***INCLUDE /ZAK/LRARANY_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFA_RARANYV-DATUM.
  MOVE SY-UZEIT TO /ZAK/AFA_RARANYV-UZEIT.
  MOVE SY-UNAME TO /ZAK/AFA_RARANYV-UNAME.


ENDFORM.                    "get_change_data
