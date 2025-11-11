*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_ELMVF01 .
*----------------------------------------------------------------------*
FORM get_change_data.

  GET TIME.
  MOVE sy-datum TO /zak/afa_elv-as4date.
  MOVE sy-uzeit TO /zak/afa_elv-as4time.
  MOVE sy-uname TO /zak/afa_elv-as4user.

ENDFORM.                    "get_change_data
