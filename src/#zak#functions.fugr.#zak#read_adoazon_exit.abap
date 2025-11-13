FUNCTION /ZAK/READ_ADOAZON_EXIT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(INPUT) OPTIONAL
*"     VALUE(SZIDO) TYPE  DATUM OPTIONAL
*"  EXPORTING
*"     VALUE(RETURN) TYPE  CHAR_55
*"----------------------------------------------------------------------
* 0003  2008.12.11 Balázs Gábor tax ID verification extended
*                               with birth year
*"----------------------------------------------------------------------

  DATA: L_LEN TYPE I,
        L_NUM TYPE P,
        L_SUM TYPE P,
        L_CHAR(1) TYPE C,
        L_TABIX TYPE SY-TABIX,
        L_SZOR TYPE P,
        CHAR(13).
*++0003 2008.12.11 BG (Fmc)
  CONSTANTS LC_FROM LIKE SY-DATUM VALUE '18670101'.
  DATA L_NAP TYPE I.
*--0003 2008.12.11 BG (Fmc)


  CLEAR: RETURN,L_NUM,L_LEN,L_SUM,L_CHAR,L_SZOR.

*++BG 2006.04.10
*  DO 3 TIMES.
*    REPLACE '-' WITH '' INTO INPUT.
*  ENDDO.
  TRANSLATE INPUT USING '- '.
  CONDENSE INPUT NO-GAPS.
*--BG 2006.04.10

  CHAR = INPUT.
  L_LEN = STRLEN( CHAR ).

  IF NOT INPUT CO ' 0123456789'.
* ERROR
    RETURN = 'Hibás adószám!'.
  ELSE.
    IF L_LEN = 10 .
* INDIVIDUAL TAX NUMBER
* Tax numbers are formed based on personal data (10 characters):
* a) According to the 1996 law, the first digit of the tax number, 8, is
* a constant indicating that it belongs to an individual.
* b) Digits 2-6 denote the number of days between the person's birth
* date and January 1, 1867.
* c) Digits 7-9 serve to differentiate people born on the same day.
* d) The 10th digit is a check digit calculated mathematically from the
* first nine digits.
* The 10th digit must be created by multiplying each of the nine digits
* defined in points a)-c) by its position within the identifier.
* (First digit times one, second digit times two, and so on.)
* The sum of these products is divided by 11, and the remainder equals
* the 10th digit.
* The serial number defined in point c) cannot be issued if the remainder
* of the division by 11 is equal to ten.
      IF INPUT(1) NE 8 .
        RETURN = 'Adóazonosító első számjegye csak 8 lehet!'.
        EXIT.
      ENDIF.
*++0003 2008.12.11 BG (Fmc)
      L_NAP = SZIDO - LC_FROM.

      IF INPUT+1(5) NE L_NAP.
        RETURN = 'Adóazonosító születési dátumhoz nem egyezik!'.
        EXIT.
      ENDIF.
*--0003 2008.12.11 BG (Fmc)
      DO 9 TIMES.
        L_TABIX = SY-INDEX - 1.
        L_NUM = L_NUM + ( INPUT+L_TABIX(1) * SY-INDEX ).
      ENDDO.
      L_SUM = L_NUM / 11.
      L_SUM = L_SUM * 11.
      IF L_SUM > L_NUM.
        L_SUM = L_NUM - ( L_SUM - 11 ) .
*++BG 2006/05/29
*Missing case when it is equal; in this situation the last character of
* the tax number is 0.
*      ELSEIF L_SUM < L_NUM.
      ELSEIF L_SUM <= L_NUM.
*--BG 2006/05/29
        L_SUM = L_NUM - L_SUM .
      ENDIF.
      IF L_SUM EQ 10 .
        RETURN = 'Hibás adószám!'.
      ELSE.
        IF INPUT+9(1) NE L_SUM .
          L_CHAR = L_SUM.
          CONCATENATE 'Adóazonosító utolsó számjegye csak' L_CHAR
                      'lehet' INTO RETURN SEPARATED BY SPACE.
          EXIT.
        ENDIF.
      ENDIF.
    ELSEIF L_LEN = 11.
* TAX NUMBER OF COMPANIES
* A valid tax number consists of 13 characters and has the form
* "aaaaaaaa-b-cc", where each section is numeric.
* a) The number "aaaaaaaa" must satisfy the following (CDV check):
* multiply its digits sequentially by 9,7,3,1,9,7,3,1.
* The tax number is "CDV-valid" if the sum of these products is divisible
* by 10.
* b) The value of "b" can be 1, 2, or 3.
* c) "cc" identifies the tax authority and is a number between 1 and 44.
      L_SZOR = 11.
      DO 8 TIMES.
        L_SZOR = L_SZOR - 2.
        IF L_SZOR < 0.
          L_SZOR = 9.
        ELSEIF L_SZOR = 5.
          L_SZOR = L_SZOR - 2.
        ENDIF.
        L_TABIX = SY-INDEX - 1.
        L_NUM = L_NUM + ( INPUT+L_TABIX(1) * L_SZOR ).
      ENDDO.
      L_SUM = L_NUM / 10.
      L_SUM = L_SUM * 10.
      IF L_SUM NE L_NUM.
        RETURN = 'Az adóazonosító nem CDV helyes!'.
        EXIT.
      ENDIF.
*++BG 2006/04/10
*      IF INPUT+8(1) NE '1' OR
*         INPUT+8(1) NE '2' OR
*         INPUT+8(1) NE '3'.
      IF INPUT+8(1) NA '123'.
*--BG 2006/04/10
        CONCATENATE 'Adóazonosító kilencedik számjegye csak'
                    '1,2,3 lehet!'
                    INTO RETURN SEPARATED BY SPACE.
        EXIT.
      ENDIF.
      L_SZOR = INPUT+9(2).
      IF L_SZOR < 1 OR
         L_SZOR > 44.
        RETURN = 'Adóazonosító utolsó két számjegye nem 1-44 közötti szám!'.
        EXIT.
      ENDIF.
    ELSE.
* INVALID TAX NUMBER
      RETURN = 'Hibás adóazonosító formátum!'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
