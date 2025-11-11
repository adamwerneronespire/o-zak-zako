*----------------------------------------------------------------------*
***INCLUDE /ZAK/LIDSZ_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/GET_IDSZ_MV-DATUM.
  MOVE SY-UZEIT TO /ZAK/GET_IDSZ_MV-UZEIT.
  MOVE SY-UNAME TO /ZAK/GET_IDSZ_MV-UNAME.

ENDFORM.                    "GET_CHANGE_DATA
