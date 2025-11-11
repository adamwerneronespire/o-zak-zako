*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_VAMT_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  GET TIME.

  /ZAK/AFA_VAMT_V-AS4USER = SY-UNAME.
  /ZAK/AFA_VAMT_V-AS4DATE = SY-DATUM.
  /ZAK/AFA_VAMT_V-AS4TIME = SY-UZEIT.

ENDFORM.                    "change_data
