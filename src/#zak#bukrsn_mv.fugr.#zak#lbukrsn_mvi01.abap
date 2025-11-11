*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBUKRSN_MVI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  D0105_INPUT_SETNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE D0105_INPUT_SETNR INPUT.
*..... Fill table of relevant screen fields .......................... *
  DATA: DYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD WITH HEADER LINE.
  DATA: TABNAME_AUX  LIKE RGSBM-UTAB,
        FLDNAME_AUX  LIKE RGSBS-FIELD,
        SETNAME_AUX  LIKE RGSBM-SHORTNAME,
        SETID_AUX    LIKE RGSBS-SETNR,
        SETCLASS_AUX LIKE RGSBM-SETCLASS,
        VARNAME_AUX  LIKE RGSBM-VARNAME,
        VALUE_AUX    LIKE RGSBV-FROM,
        WF_GCF_FLAG(1)        TYPE C.

  DATA: MSGID LIKE SY-MSGID,             "Message id
        MSGTY LIKE SY-MSGTY,             "Message type
        MSGNO LIKE SY-MSGNO,             "Message number
        MSGV1 LIKE SY-MSGV1,             "First message variable
        MSGV2 LIKE SY-MSGV2,             "Second message variable
        MSGV3 LIKE SY-MSGV3,             "Third message variable
        MSGV4 LIKE SY-MSGV4.             "Fourth message variable


  REFRESH DYNPFIELDS.
  CLEAR DYNPFIELDS.

  DYNPFIELDS-FIELDNAME  = '/ZAK/BUKRSN_MV-SHORTNAME'.      "Set Name
  APPEND DYNPFIELDS.

*  DYNPFIELDS-FIELDNAME  = 'RGSBM-SETCLASS'.      "Setklasse
*  APPEND DYNPFIELDS.
*
*  DYNPFIELDS-FIELDNAME = 'RGSBS-SETNR'."Setid to be set
*  APPEND DYNPFIELDS.

*..... Read actual contents of relevant screen fields ................ *

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG  "Current program
      DYNUMB               = SY-DYNNR  "Current screen
    TABLES
      DYNPFIELDS           = DYNPFIELDS  "Relevant screen fields
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 01
      INVALID_DYNPROFIELD  = 02
      INVALID_DYNPRONAME   = 03
      INVALID_DYNPRONUMMER = 04
      INVALID_REQUEST      = 05
      NO_FIELDDESCRIPTION  = 06
      UNDEFIND_ERROR       = 07
      OTHERS               = 999.

*..... Fill auxilary fields with masks for set name and table ........ *

  READ TABLE DYNPFIELDS INDEX 1.
  SETNAME_AUX = DYNPFIELDS-FIELDVALUE.
  IF SETNAME_AUX CA '+*'.
    TRANSLATE SETNAME_AUX TO UPPER CASE.                 "#EC TRANSLANG
  ELSE.
    SETNAME_AUX = '*'.
  ENDIF.

*  READ TABLE DYNPFIELDS INDEX 2.
*  SETCLASS_AUX = DYNPFIELDS-FIELDVALUE.
*  TRANSLATE SETCLASS_AUX TO UPPER CASE.                  "#EC TRANSLANG

*..... Popup(s) for set selection by user ............................ *

  CALL FUNCTION 'G_RW_SET_SELECT'
    EXPORTING
      SET             = SETNAME_AUX
      CLASS           = SETCLASS_AUX
      SHOW_TABLE_NAME = 'X'
    IMPORTING
      SET_NAME        = SETNAME_AUX
      CLASS_NAME      = SETCLASS_AUX
      SETID           = SETID_AUX
    EXCEPTIONS
      NO_SET_PICKED   = 01
      NO_SETS         = 02
      OTHERS          = 999.

  IF SY-SUBRC EQ 0.

*..... Overwrite masks by selected values for set name and table ..... *

    READ TABLE DYNPFIELDS INDEX 1.
    DYNPFIELDS-FIELDVALUE = SETNAME_AUX.
    MODIFY DYNPFIELDS INDEX SY-TABIX.

*    IF WF_GCF_FLAG = 'X'.
*      READ TABLE DYNPFIELDS INDEX 2.
*      DYNPFIELDS-FIELDVALUE = SETCLASS_AUX.
*      MODIFY DYNPFIELDS INDEX SY-TABIX.
*    ENDIF.
*
*    READ TABLE DYNPFIELDS INDEX 3.
*    DYNPFIELDS-FIELDVALUE = SETID_AUX.
*    MODIFY DYNPFIELDS INDEX SY-TABIX.
*
*..... Transfer contents of relevant fields into screen fields ....... *

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = DYNPFIELDS
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 01
        INVALID_DYNPROFIELD  = 02
        INVALID_DYNPRONAME   = 03
        INVALID_DYNPRONUMMER = 04
        INVALID_REQUEST      = 05
        NO_FIELDDESCRIPTION  = 06
        UNDEFIND_ERROR       = 07
        OTHERS               = 999.
  ELSE.
* ... Exception handling: S-message if no set found or picked ...
    MSGID = SY-MSGID.                  "Message id
    MSGTY = 'S'.                       "Message type
    MSGNO = SY-MSGNO.                  "Message number

    MSGV1 = SY-MSGV1.                  "First message variable
    MSGV2 = SY-MSGV2.                  "Second message variable
    MSGV3 = SY-MSGV3.                  "Third message variable
    MSGV4 = SY-MSGV4.                  "Fourth message variable

    MESSAGE ID     MSGID
            TYPE   MSGTY
            NUMBER MSGNO
            WITH   MSGV1 MSGV2 MSGV3 MSGV4.
  ENDIF.

ENDMODULE.                 " D0105_INPUT_SETNR  INPUT
