class /ZAK/CL_IM_BADI_FDCB_SUBBAS04 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BADI_FDCB_SUBBAS04 .
protected section.
private section.
ENDCLASS.



CLASS /ZAK/CL_IM_BADI_FDCB_SUBBAS04 IMPLEMENTATION.


method IF_EX_BADI_FDCB_SUBBAS04~GET_DATA_FROM_SCREEN_OBJECT.

* fill export parameters from interface attributes
  ex_invfo  = me->if_ex_badi_fdcb_subbas04~invfo.

endmethod.


method IF_EX_BADI_FDCB_SUBBAS04~PUT_DATA_TO_SCREEN_OBJECT.

* fill interface attributes from importing paramters
  me->if_ex_badi_fdcb_subbas04~invfo  = im_invfo.

endmethod.
ENDCLASS.
