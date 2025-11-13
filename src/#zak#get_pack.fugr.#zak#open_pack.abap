FUNCTION /ZAK/OPEN_PACK.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPART) TYPE  /ZAK/BTYPART OPTIONAL
*"  TABLES
*"      T_/ZAK/OPACK STRUCTURE  /ZAK/OPACK
*"----------------------------------------------------------------------
  REFRESH T_/ZAK/OPACK.
  CHECK NOT I_BUKRS IS INITIAL.

   SELECT BUKRS PACK DATUM UZEIT UNAME
      INTO TABLE T_/ZAK/OPACK
            FROM /ZAK/BEVALLP
           WHERE BUKRS   EQ I_BUKRS
             AND ALOADED NE 'X'
             AND XLOEK   NE 'X'.
*++1965 #05.
  DATA LW_/ZAK/OPACK TYPE /ZAK/OPACK.
  DATA L_BTYPE TYPE /ZAK/BTYPE.
  DATA L_BTYPART TYPE /ZAK/BTYPART.

  IF NOT I_BTYPART IS INITIAL.
    LOOP AT T_/ZAK/OPACK INTO LW_/ZAK/OPACK.
      CLEAR L_BTYPE.
      SELECT SINGLE BTYPE INTO L_BTYPE
                          FROM /ZAK/BEVALLSZ
                         WHERE BUKRS EQ LW_/ZAK/OPACK-BUKRS
                           AND PACK  EQ LW_/ZAK/OPACK-PACK.
      IF SY-SUBRC EQ 0 AND NOT L_BTYPE IS INITIAL.
        CLEAR L_BTYPART.
        CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
          EXPORTING
            I_BUKRS       = LW_/ZAK/OPACK-BUKRS
            I_BTYPE       = L_BTYPE
          IMPORTING
            E_BTYPART     = L_BTYPART
          EXCEPTIONS
            ERROR_IMP_PAR = 1
            OTHERS        = 2.
        IF SY-SUBRC EQ 0 AND L_BTYPART NE I_BTYPART.
          DELETE T_/ZAK/OPACK.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*--1965 #05.

ENDFUNCTION.
