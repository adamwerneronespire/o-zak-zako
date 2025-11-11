*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBUKRS_SEGMF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BUKRS_SEGMV-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/BUKRS_SEGMV-AS4TIME.
  MOVE SY-UNAME TO /ZAK/BUKRS_SEGMV-AS4USER.

ENDFORM.
