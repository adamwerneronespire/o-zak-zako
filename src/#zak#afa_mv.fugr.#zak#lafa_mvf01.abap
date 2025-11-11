*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_MVF01 .
*----------------------------------------------------------------------*
FORM get_change_data.

  GET TIME.
  MOVE sy-datum TO /zak/afa_cust_v-datum.
  MOVE sy-uzeit TO /zak/afa_cust_v-uzeit.
  MOVE sy-uname TO /zak/afa_cust_v-uname.

ENDFORM.
