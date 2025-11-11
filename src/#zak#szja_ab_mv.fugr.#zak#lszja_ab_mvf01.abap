*----------------------------------------------------------------------*
***INCLUDE /ZAK/LSZJA_AB_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  GET TIME.

  MOVE SY-UNAME TO /ZAK/SZJA_ABEV_V-AS4USER.
  MOVE SY-DATUM TO /ZAK/SZJA_ABEV_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/SZJA_ABEV_V-AS4TIME.

ENDFORM.
