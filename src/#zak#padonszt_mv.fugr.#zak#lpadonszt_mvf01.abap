*----------------------------------------------------------------------*
***INCLUDE /ZAK/LPADONSZT_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  GET TIME.
  /ZAK/PADONSZT_V-AS4USER = SY-UNAME.
  /ZAK/PADONSZT_V-AS4DATE = SY-DATUM.
  /ZAK/PADONSZT_V-AS4TIME = SY-UZEIT.

ENDFORM.                    "change_data
