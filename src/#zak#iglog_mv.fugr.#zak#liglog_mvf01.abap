*----------------------------------------------------------------------*
***INCLUDE /ZAK/LIGLOG_MVF01.
*----------------------------------------------------------------------*
FORM CHANGE_DATA .
  GET TIME.
  /ZAK/IGLOG_V-AS4USER = SY-UNAME.
  /ZAK/IGLOG_V-AS4DATE = SY-DATUM.
  /ZAK/IGLOG_V-AS4TIME = SY-UZEIT.
ENDFORM.
