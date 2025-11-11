*----------------------------------------------------------------------*
***INCLUDE /ZAK/LVPOPLIFN_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/VPOP_LIFNRV-DATUM.
  MOVE SY-UZEIT TO /ZAK/VPOP_LIFNRV-UZEIT.
  MOVE SY-UNAME TO /ZAK/VPOP_LIFNRV-UNAME.

ENDFORM.                    "GET_CHANGE_DATA
