*----------------------------------------------------------------------*
***INCLUDE /ZAK/LPENZT_FOR_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/PENZT_FORGV-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/PENZT_FORGV-AS4TIME.
  MOVE SY-UNAME TO /ZAK/PENZT_FORGV-AS4USER.

ENDFORM.                    "GET_CHANGE_DATA
