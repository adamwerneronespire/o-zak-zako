*----------------------------------------------------------------------*
***INCLUDE /ZAK/LONY_NYLAP_VF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  MOVE SY-UNAME TO /ZAK/ONY_NYLAP_V-AS4USER.
  MOVE SY-DATUM TO /ZAK/ONY_NYLAP_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/ONY_NYLAP_V-AS4TIME.

ENDFORM.                    "GET_CHANGE_DATA
