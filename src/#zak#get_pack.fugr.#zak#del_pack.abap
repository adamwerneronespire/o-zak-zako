FUNCTION /ZAK/DEL_PACK.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_PACK) TYPE  /ZAK/PACK
*"----------------------------------------------------------------------

  UPDATE /ZAK/BEVALLP SET ALOADED = ''
                         ADATUM   = ''
                         AUZEIT   = ''
                         AUNAME   = ''
                     WHERE
                         PACK     =  I_PACK   AND
                         ALOADED  = 'X'.

ENDFUNCTION.
