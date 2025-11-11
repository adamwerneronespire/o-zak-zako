*----------------------------------------------------------------------*
*   INCLUDE /ZAK/LBEVC_MVF01                                           *
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BEVALLC_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/BEVALLC_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/BEVALLC_V-UNAME.

ENDFORM.
