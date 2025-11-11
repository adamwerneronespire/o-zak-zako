*----------------------------------------------------------------------*
***INCLUDE /ZAK/LPENZATV_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

* Ha nincs még azonosítója
  IF /ZAK/PENZATV_V-ZAZON IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR                   = '01'
        OBJECT                        = '/ZAK/PTGT'
        QUANTITY                      = '1'
*        SUBOBJECT                     = ' '
*        TOYEAR                        = '0000'
        IGNORE_BUFFER                 = 'X'
      IMPORTING
        NUMBER                        = /ZAK/PENZATV_V-ZAZON
*        QUANTITY                      =
*        RETURNCODE                    =
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
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/PENZATV_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/PENZATV_V-AS4TIME.
  MOVE SY-UNAME TO /ZAK/PENZATV_V-AS4USER.

ENDFORM.                    "GET_CHANGE_DATA
