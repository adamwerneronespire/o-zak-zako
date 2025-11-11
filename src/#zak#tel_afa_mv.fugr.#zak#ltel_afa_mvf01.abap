*----------------------------------------------------------------------*
***INCLUDE /ZAK/LTEL_AFA_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.

  MOVE SY-UNAME TO /ZAK/TEL_AFA_V-AS4USER.
  MOVE SY-DATUM TO /ZAK/TEL_AFA_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/TEL_AFA_V-AS4TIME.

ENDFORM.                    "get_change_data
