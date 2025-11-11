FUNCTION /ZAK/READ_ADOAZON_EXIT.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(INPUT) OPTIONAL
*"     VALUE(SZIDO) TYPE  DATUM OPTIONAL
*"  EXPORTING
*"     VALUE(RETURN) TYPE  CHAR_55
*"----------------------------------------------------------------------
* 0003  2008.12.11 Balázs Gábor adóazonosító ellenőrzés kiegészítés
*                               születési évvel
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
* HIBA
    RETURN = 'Hibás adószám!'.
  ELSE.
    IF L_LEN = 10 .
* MAGÁNSZEMÉLY ADÓSZÁMA
* Az adószámokat személyes adataink alapján képzik (10 karakter):
* a, Az 1996-os törvény szerint az adószám első száma, a 8-as, állandó
* szám, amely azt jelzi, hogy magánszemélyről van szó.
* b, A 2-6. számjegyek a személy születési időpontja és az 1867. január
* között eltelt napok számát jelöli.
* c, A 7-9. számok az azonos napon születettek megkülönböztetésére
* szolgál.
* d) a 10. számjegy az 1-9. számjegyek felhasználásával matematikai
* módszerekkel képzett ellenőrző szám.
* Az adóazonosító jel 10. számjegyét úgy kell képezni, hogy az a)-c)
* pontok szerint képzett 9 számjegy mindegyikét szorozni kell azzal a
* sorszámmal, ahányadik helyet foglalja el az azonosítón belül.
* (Első számjegy szorozva eggyel, második számjegy szorozva kettővel és
* így tovább.)
* Az így kapott szorzatok összegét el kell osztani 11-gyel, és az osztás
* maradéka a 10. számjeggyel lesz egyenlő.
* A c) pont szerinti születési sorszám nem adható ki, ha a 11-gyel való
* osztás maradéka egyenlő tízzel.
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
*Hiányzott az az eset amikor egynelő ebben az esetben
*az adószám utolsó karaktere 0.
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
* GAZDASÁGI TÁRSASÁGOK ADÓSZÁMA
* A helyes adószám 13 jelből áll, és "aaaaaaaa-b-cc" alakú, ahol
* "aaaaaaaa", "b" és "cc" mindegyike numerikus.
* a, Az "aaaaaaaa" számra teljesülni kell a következőnek (CDV
* ellenőrzés):
* Az "aaaaaaaa" számjegyeit szorozzuk meg rendre a 9,7,3,1,9,7,3,1
* számokkal.
* Akkor "CDV-helyes" az adószám, ha az így kapott szorzatok összege
* 10-el osztható.
* b, A "b" értéke 1,2,3 valamelyike lehet.
* c, A "cc" az adóhatóságot jelöli, és 1-44 közötti szám.
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
* HIBÁS ADÓSZÁM
      RETURN = 'Hibás adóazonosító formátum!'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
