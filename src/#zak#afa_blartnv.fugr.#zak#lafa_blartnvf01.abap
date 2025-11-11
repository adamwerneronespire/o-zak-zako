*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_BLARTNVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFA_BLARTNV-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/AFA_BLARTNV-AS4TIME.
  MOVE SY-UNAME TO /ZAK/AFA_BLARTNV-AS4USER.

ENDFORM.                    "get_change_data
