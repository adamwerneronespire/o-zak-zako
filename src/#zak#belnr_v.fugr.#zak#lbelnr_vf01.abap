*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBELNR_VF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/OUT_BELNR_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/OUT_BELNR_V-AS4TIME.
  MOVE SY-UNAME TO /ZAK/OUT_BELNR_V-AS4USER.

ENDFORM.
