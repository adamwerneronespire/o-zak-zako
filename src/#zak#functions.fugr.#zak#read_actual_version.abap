FUNCTION /ZAK/READ_ACTUAL_VERSION.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_MONAT) TYPE  MONAT
*"  EXPORTING
*"     REFERENCE(E_ZINDEX) TYPE  /ZAK/INDEX
*"----------------------------------------------------------------------

  clear E_ZINDEX.
  SELECT * into table i_/zak/bevalli FROM  /ZAK/BEVALLI
         WHERE  BUKRS  = i_bukrs
         AND    BTYPE  = i_btype
         AND    GJAHR  = i_gjahr
         AND    MONAT  = i_monat.


  delete i_/zak/bevalli where flag = 'Z'.
  delete i_/zak/bevalli where flag = 'X'.


  sort i_/zak/bevalli.
  describe table i_/zak/bevalli lines sy-tfill.

  if sy-tfill > 0.
    clear w_/zak/bevalli.
    read table i_/zak/bevalli into w_/zak/bevalli index sy-tfill.
    if sy-subrc = 0.
      e_zindex = w_/zak/bevalli-zindex.
    endif.
  else.
   e_zindex = space.
  endif.

ENDFUNCTION.
