*----------------------------------------------------------------------*
***INCLUDE /ZAK/LONELL_MVF01 .
*----------------------------------------------------------------------*

FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/ONELL_BOOKV-DATUM.
  MOVE SY-UZEIT TO /ZAK/ONELL_BOOKV-UZEIT.
  MOVE SY-UNAME TO /ZAK/ONELL_BOOKV-UNAME.

ENDFORM.
