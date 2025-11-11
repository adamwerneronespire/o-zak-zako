*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_FMUV_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFA_FMUV_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/AFA_FMUV_V-AS4TIME.
  MOVE SY-UNAME TO /ZAK/AFA_FMUV_V-AS4USER.

ENDFORM.                    "get_change_data
