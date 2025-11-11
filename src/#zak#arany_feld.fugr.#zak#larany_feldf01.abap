*----------------------------------------------------------------------*
***INCLUDE /ZAK/LARANY_FELDF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/ARANY_FELDV-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/ARANY_FELDV-AS4TIME.
  MOVE SY-UNAME TO /ZAK/ARANY_FELDV-AS4USER.

ENDFORM.
