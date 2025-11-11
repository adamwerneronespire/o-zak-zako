*----------------------------------------------------------------------*
***INCLUDE /ZAK/LA_KTOSL_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.

  MOVE SY-UNAME TO /ZAK/AFA_KTOSL_V-AS4USER.
  MOVE SY-DATUM TO /ZAK/AFA_KTOSL_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/AFA_KTOSL_V-AS4TIME.

ENDFORM.                    "get_change_data
