class /ZAK/CL_IM_AK_INVOICE_UPDATE definition
  public
  final
  create public .

*"* public components of class /ZAK/CL_IM_AK_INVOICE_UPDATE
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_INVOICE_UPDATE .
protected section.
*"* protected components of class /ZAK/CL_IM_AK_INVOICE_UPDATE
*"* do not include other source files here!!!
private section.
*"* private components of class /ZAK/CL_IM_AK_INVOICE_UPDATE
*"* do not include other source files here!!!
ENDCLASS.



CLASS /ZAK/CL_IM_AK_INVOICE_UPDATE IMPLEMENTATION.


method IF_EX_INVOICE_UPDATE~CHANGE_AT_SAVE.
*----------------------------------------------------------------------*
* Módosítás  Dátum          Szerző                    HelpDesk ID
*                           Rövid leírás
* 001        2010.06.09     Förgeteg Csaba (IQSYS)
*                           1. Deactivating this part of the exchange
*                              rate determination enhancement, because
*                              according to the SELECT statement this
*                              part of the functionality does not run.
*                              Further analysis of this source code
*                              showed that even if the BKPF SELECT
*                              found something, the program would NOT
*                              determine any document number and
*                              document date for BTE (function module
*                              /ZAK/TAX_EXCHANGE_RATE_2051) used to
*                              determine the exchange rate.
*                              In addition to this, the BKPF SELECT is
*                              constructed the way that it is very time
*                              consuming.
*
*----------------------------------------------------------------------*
* 001/01 beginning of modification
*data: v_rseg type mrmrseg.
*data: i_bkpf type standard table of bkpf initial size 0,
*      w_bkpf type bkpf.
*data: i_bseg type standard table of bseg initial size 0,
*      w_bseg type bseg.
*data: v_belnr type belnr_d,
*      v_bldat type bldat.
* 001/01 end of modification

*----------------------------------------------------------------------*
* Adó átszámítási árfolyamának meghatározása
*----------------------------------------------------------------------*

* 001/01 beginning of modification
*read table ti_rseg_new into v_rseg index 1.
*if sy-subrc = 0.
*  clear w_bkpf.
*  clear: v_belnr, v_bldat.
*  check not v_rseg-ebeln is initial.

** -- Keresni BKPF rekordokat
*  select * into table i_bkpf from bkpf
*     where blart = 'SB' and
*           tcode = 'EUVP'.

*  if not i_bkpf[] is initial.

*    select * into table i_bseg from bseg
*      for all entries in i_bkpf
*        where BUKRS = i_bkpf-bukrs
*          and BELNR = i_bkpf-belnr
*          and GJAHR = i_bkpf-gjahr
*          and ebeln = v_rseg-ebeln.

*     if not i_bseg[] is initial.
*       read table i_bseg into w_bseg index 1.
*       if sy-subrc = 0.

*       read table i_bkpf into w_bkpf with key
*              BUKRS = w_bseg-bukrs
*              BELNR = w_bseg-belnr
*              GJAHR = w_bseg-gjahr.
*       if sy-subrc = 0.
*          clear v_belnr.
*          clear v_bldat.
*          export v_bldat from w_bkpf-bldat to memory id 'BLDAT'.
*          export v_belnr from w_bkpf-belnr to memory id 'BELNR'.
*       endif.
*       endif.
*     endif.

*  endif.

*endif.

*export v_bldat from w_bkpf-bldat to memory id 'BLDAT'.
*export v_belnr from w_bkpf-belnr to memory id 'BELNR'.
* 001/01 end of modification
endmethod.


method IF_EX_INVOICE_UPDATE~CHANGE_BEFORE_UPDATE.
* ...

endmethod.


method IF_EX_INVOICE_UPDATE~CHANGE_IN_UPDATE.
* ...
endmethod.
ENDCLASS.
