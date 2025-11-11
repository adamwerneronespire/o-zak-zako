*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_FKABEVF01 .
*----------------------------------------------------------------------*
FORM get_change_data.

  GET TIME.
  MOVE sy-datum TO /zak/afa_fkabevv-datum.
  MOVE sy-uzeit TO /zak/afa_fkabevv-uzeit.
  MOVE sy-uname TO /zak/afa_fkabevv-uname.

ENDFORM.                    "get_change_data
