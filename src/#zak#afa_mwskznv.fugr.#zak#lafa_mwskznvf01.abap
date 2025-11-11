*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_MWSKZNVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFA_MWSKZNV-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/AFA_MWSKZNV-AS4TIME.
  MOVE SY-UNAME TO /ZAK/AFA_MWSKZNV-AS4USER.

ENDFORM.                    "get_change_data
