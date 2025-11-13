FUNCTION /ZAK/NEW_BELNR.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(E_BELNR) TYPE  BELNR_D
*"  EXCEPTIONS
*"      ERROR_GET_NUMBER
*"----------------------------------------------------------------------

  DATA L_TOYEAR LIKE INRI-TOYEAR.
  DATA L_NUMBER TYPE BELNR_D.

  GET TIME.

  MOVE SY-DATUM(4) TO L_TOYEAR.

* Defining the number range
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR                   = '01'
      OBJECT                        = '/ZAK/BELNR'
      QUANTITY                      = '1'
      SUBOBJECT                     = I_BUKRS
      TOYEAR                        = L_TOYEAR
*     IGNORE_BUFFER                 = ' '
    IMPORTING
      NUMBER                        = L_NUMBER
*     QUANTITY                      =
*     RETURNCODE                    =
    EXCEPTIONS
     INTERVAL_NOT_FOUND            = 1
     NUMBER_RANGE_NOT_INTERN       = 2
     OBJECT_NOT_FOUND              = 3
     QUANTITY_IS_0                 = 4
     QUANTITY_IS_NOT_1             = 5
     INTERVAL_OVERFLOW             = 6
     BUFFER_OVERFLOW               = 7
     OTHERS                        = 8
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE E085(/ZAK/ZAK) RAISING ERROR_GET_NUMBER.
* Number range error for upload identifier!
  ELSE.
    MOVE L_NUMBER TO E_BELNR.
  ENDIF.


ENDFUNCTION.
