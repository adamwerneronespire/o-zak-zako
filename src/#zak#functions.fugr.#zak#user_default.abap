FUNCTION /ZAK/USER_DEFAULT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(USERS) TYPE  SY-UNAME
*"  EXCEPTIONS
*"      ERROR_DATF
*"----------------------------------------------------------------------


  DATA I_USERS LIKE USDEF OCCURS 0 WITH HEADER LINE.


  CLEAR I_USERS.
  MOVE SY-MANDT TO I_USERS-MANDT.
  MOVE USERS    TO I_USERS-BNAME.
  APPEND I_USERS.


  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      LANGU = 'E'
    TABLES
      USERS = I_USERS.

  READ TABLE I_USERS INDEX 1.

  IF I_USERS-DATFM NE 'YYYY.MM.DD'.
    MESSAGE E204(/ZAK/ZAK) RAISING ERROR_DATF.
*   The user's date format is not set to 'YYYY.MM.DD'!
  ENDIF.

ENDFUNCTION.
