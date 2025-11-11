*----------------------------------------------------------------------*
*   INCLUDE /ZAK/LADOM_MVF01                                           *
*----------------------------------------------------------------------*

FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-LANGU TO /ZAK/ADONEM_V-LANGU.
  MOVE SY-DATUM TO /ZAK/ADONEM_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/ADONEM_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/ADONEM_V-UNAME.

ENDFORM.
