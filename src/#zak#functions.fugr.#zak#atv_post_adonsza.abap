FUNCTION /ZAK/ATV_POST_ADONSZA.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_MONAT) TYPE  MONAT
*"     REFERENCE(I_INDEX) TYPE  /ZAK/INDEX
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLO
*"  EXCEPTIONS
*"      DATA_MISMATCH
*"      UPDATE_ERROR
*"----------------------------------------------------------------------
data: begin of i_lines occurs 20.
        INCLUDE STRUCTURE /zak/atvez_sor.
DATA: END OF I_lines.


data: v_error.

* Data consistency check
loop at t_bevallo into w_/zak/bevallo.
   check w_/zak/bevallo-bukrs  ne i_bukrs or
         w_/zak/bevallo-btype  ne i_btype or
         w_/zak/bevallo-gjahr  ne i_gjahr or
         w_/zak/bevallo-monat  ne i_monat or
         w_/zak/bevallo-zindex ne i_index.

    message e147(/zak/zak) raising data_mismatch.
    v_error = 'X'.
    exit.
endloop.


check v_error = space.

* Read form data
   PERFORM READ_BEVALLB_m USING i_BTYPE.


* Interpret T_BEVALLO and convert to /ZAK/ATVEZ_SOR
   perform convert_bevallo_lines tables t_bevallo
                                        i_lines
                                  using i_bukrs.




* Update the tax current account
  perform update_adonsza tables i_lines
                         using  i_bukrs
                                i_btype
                                i_gjahr
                                i_monat
                                i_index
                         changing v_error.

  if v_error ne space.
    message e149(/zak/zak) raising update_error.
  endif.
ENDFUNCTION.
