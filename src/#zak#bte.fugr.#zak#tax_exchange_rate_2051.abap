FUNCTION /ZAK/TAX_EXCHANGE_RATE_2051.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_COMPANY_CODE) TYPE  BUKRS
*"     VALUE(I_COUNTRY) LIKE  T005-LAND1 OPTIONAL
*"     VALUE(I_TYPE_OF_RATE) LIKE  TCURR-KURST DEFAULT 'M'
*"     VALUE(I_POSTING_DATE) LIKE  SYST-DATUM
*"     VALUE(I_DOCUMENT_DATE) LIKE  SYST-DATUM
*"     VALUE(I_FOREIGN_CURRENCY) LIKE  TCURR-FCURR
*"     VALUE(I_LOCAL_CURRENCY) LIKE  TCURR-TCURR
*"  EXPORTING
*"     REFERENCE(E_EXCHANGE_RATE)
*"  EXCEPTIONS
*"      NO_TAX_RATE_FOUND
*"----------------------------------------------------------------------
data: v_txkrs type TXKRS_BKPF.
data: v_bldat type bldat.


*import v_txkrs from memory id 'TXKRS'.
import v_bldat from memory id 'BLDAT'.

if sy-subrc = 0.
*  if not v_txkrs is initial.
*     E_EXCHANGE_RATE = v_txkrs.
*  endif.

  if not v_bldat is initial.

  CALL FUNCTION 'READ_EXCHANGE_RATE'
    EXPORTING
*     CLIENT                  = SY-MANDT
      date                    = v_bldat
      foreign_currency        = i_foreign_currency
      local_currency          = i_local_currency
      type_of_rate            = 'K'
   IMPORTING
      exchange_rate           = e_exchange_rate
*     FOREIGN_FACTOR          =
*     LOCAL_FACTOR            =
*     VALID_FROM_DATE         =
*     DERIVED_RATE_TYPE       =
*     FIXED_RATE              =
    EXCEPTIONS
      no_rate_found           = 1
      no_factors_found        = 2
      no_spread_found         = 3
      derived_2_times         = 4
      overflow                = 5
      OTHERS                  = 6
            .
  IF sy-subrc <> 0.
    RAISE no_tax_rate_found.
  ENDIF.

  endif.

endif.

ENDFUNCTION.
