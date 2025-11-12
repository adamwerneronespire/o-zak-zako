FUNCTION /ZAK/KATA_EXIT.
*"----------------------------------------------------------------------
*"* Local interface:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_MONAT) TYPE  MONAT
*"     REFERENCE(I_INDEX) TYPE  /ZAK/INDEX
*"  TABLES
*"      T_BEVALLO STRUCTURE  /ZAK/BEVALLALV
*"      T_ONREV_ADOAZON STRUCTURE  /ZAK/ONR_ADOAZON OPTIONAL
*"----------------------------------------------------------------------
  DATA: V_LAST_DATE TYPE SY-DATUM.

  DATA: L_INDEX LIKE SY-TABIX.
* Ensure dialog execution
  PERFORM PROCESS_IND_ITEM USING '0'
                                 L_INDEX
                                 TEXT-P02.


* Determine the declaration deadline
  PERFORM GET_LAST_DAY_OF_PERIOD USING I_GJAHR
                                       I_MONAT
                                       I_BTYPE
                                  CHANGING V_LAST_DATE.

* General declaration data
  PERFORM READ_BEVALL  USING I_BUKRS
                             I_BTYPE
                             V_LAST_DATE.

* Verify KATA threshold settings
*++2108 #19.
*  IF W_/ZAK/BEVALL-OLWSTE IS INITIAL OR I_INDEX NE '000'.
  IF W_/ZAK/BEVALL-OLWSTE IS INITIAL.
*--2108 #19.
    EXIT.
*++2108 #19.
* Repeat the data of period '000':
  ELSEIF  I_INDEX NE '000'.
    PERFORM SEL_KATA_000 TABLES T_BEVALLO
                                T_ONREV_ADOAZON
                         USING  W_/ZAK/BEVALL
                                I_GJAHR
                                I_MONAT
                                I_INDEX.
    EXIT.
*--2108 #19.
  ENDIF.

* Calculate KATA data
  PERFORM GET_KATA_DATA TABLES T_BEVALLO
                        USING  W_/ZAK/BEVALL
                               I_GJAHR
                               I_MONAT
                               I_INDEX
                               .


ENDFUNCTION.