FUNCTION /ZAK/ABEV_CONTACT.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     VALUE(I_ABEVAZ) TYPE  /ZAK/ABEVAZ
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_MONAT) TYPE  MONAT
*"  TABLES
*"      T_ABEV_CONTACT STRUCTURE  /ZAK/ABEVCONTACT OPTIONAL
*"  EXCEPTIONS
*"      ERROR_BTYPE
*"      ERROR_MONAT
*"      ERROR_ABEVAZ
*"----------------------------------------------------------------------

  DATA V_BUKRS   LIKE /ZAK/BEVALL-BUKRS.
  DATA V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.

  DATA V_BTYPART LIKE /ZAK/BEVALL-BTYPART.
  DATA V_DATUM LIKE SY-DATUM.
  DATA V_GJAHR TYPE GJAHR.
  DATA V_ABEVAZ TYPE /ZAK/ABEVAZ.
*++S4HANA#01.
*  DATA V_UPDN.
  DATA V_UPDN TYPE C.
*--S4HANA#01.

  DATA W_ABEV_CONTACT TYPE /ZAK/ABEVCONTACT.

*++1365#24.
  RANGES R_BTYPE  FOR /ZAK/BEVALL-BTYPE.
  DATA   V_BTYPEE LIKE /ZAK/BEVALL-BTYPE.
*--1365#24.

* Hónap ellenőrzése
  IF NOT I_MONAT BETWEEN '01' AND '12'.
    MESSAGE E110(/ZAK/ZAK) WITH I_MONAT RAISING ERROR_MONAT.
*   Hónap megadás hiba! (&)
  ENDIF.

* ABEV azonosító ellenőrzése
  SELECT SINGLE COUNT( * )
                 FROM /ZAK/BEVALLB
                WHERE BTYPE  EQ I_BTYPE
                  AND ABEVAZ EQ I_ABEVAZ.
  IF SY-SUBRC NE 0.
    MESSAGE E112(/ZAK/ZAK) WITH I_BTYPE I_ABEVAZ RAISING ERROR_ABEVAZ.
*   & bevallás & ABEV azonosító nem létezik!
  ENDIF.





*++0003 BG 2006.12.13

  MOVE I_BTYPE  TO T_ABEV_CONTACT-BTYPE.
  MOVE I_ABEVAZ TO T_ABEV_CONTACT-ABEVAZ.
  APPEND T_ABEV_CONTACT.

* Meghatározzuk az import beszámoló típusát
*++S4HANA#01.
*  SELECT SINGLE BTYPART INTO V_BTYPART
*                        FROM /ZAK/BEVALL
*                     WHERE BUKRS EQ I_BUKRS
*                       AND BTYPE EQ I_BTYPE.
  SELECT BTYPART INTO V_BTYPART
                        FROM /ZAK/BEVALL UP TO 1 ROWS
                     WHERE BUKRS EQ I_BUKRS
                       AND BTYPE EQ I_BTYPE
                     ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.

  V_DATUM(4)   = I_GJAHR.
  V_DATUM+4(2) = I_MONAT.
  V_DATUM+6(2) = 01.


  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
    EXPORTING
      DAY_IN            = V_DATUM
    IMPORTING
      LAST_DAY_OF_MONTH = V_DATUM
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  SELECT BTYPE  INTO  V_BTYPE
                      UP TO 1 ROWS
                      FROM /ZAK/BEVALL
                     WHERE BUKRS EQ I_BUKRS
                       AND BTYPART EQ V_BTYPART
*++S4HANA#01.
*                      AND DATBI GE V_DATUM.
                       AND DATBI GE V_DATUM
                     ORDER BY PRIMARY KEY.
*--S4HANA#01.

  ENDSELECT.
* Nincs adat
  IF SY-SUBRC NE 0.
*   MESSAGE E109(/ZAK/ZAK) WITH I_BTYPE I_BUKRS RAISING ERROR_BTYPE.
*   & bevallás típus & vállalatban nem létezik!
    EXIT.
  ENDIF.

*++1365#24.
  IF V_BTYPE EQ I_BTYPE.
    EXIT.
  ENDIF.

  M_DEF R_BTYPE 'I' 'EQ' V_BTYPE SPACE.
* Feltöltjük a bevallás típusokat!
  DO.

*++S4HANA#01.
*    SELECT SINGLE *     FROM /ZAK/BEVALL
*                        WHERE BUKRS EQ I_BUKRS
*                          AND BTYPE EQ R_BTYPE-LOW.

    SELECT *     FROM /ZAK/BEVALL UP TO 1 ROWS INTO /ZAK/BEVALL
                    WHERE BUKRS EQ I_BUKRS
                      AND BTYPE EQ R_BTYPE-LOW
                    ORDER BY PRIMARY KEY.
    ENDSELECT.
*--S4HANA#01.

    IF SY-SUBRC EQ 0.
      M_DEF R_BTYPE 'I' 'EQ' /ZAK/BEVALL-BTYPEE SPACE.
    ENDIF.
    IF SY-SUBRC NE 0 OR
       /ZAK/BEVALL-BTYPEE EQ I_BTYPE OR
       /ZAK/BEVALL-BTYPEE IS INITIAL OR
       /ZAK/BEVALL-BTYPEE EQ /ZAK/BEVALL-BTYPE.
      EXIT.
    ENDIF.
  ENDDO.
  SORT R_BTYPE BY LOW.
  V_BTYPEE = I_BTYPE.

  LOOP AT R_BTYPE WHERE LOW NE I_BTYPE.
    V_BTYPE = R_BTYPE-LOW.
*--1365#24.

* Konverzió meghatározása
    SELECT ABEVAZ INTO V_ABEVAZ
                  FROM /ZAK/ABEVK
                  UP TO 1 ROWS
                 WHERE BTYPE   EQ V_BTYPE
*++1365#24.
*                AND btypee  EQ i_btype
                   AND BTYPEE  EQ V_BTYPEE
*--1365#24.
*++S4HANA#01.
*                   AND ABEVAZE EQ I_ABEVAZ.
                   AND ABEVAZE EQ I_ABEVAZ
             ORDER BY PRIMARY KEY.
*--S4HANA#01.
    ENDSELECT.
    IF SY-SUBRC EQ 0.
      MOVE V_BTYPE  TO T_ABEV_CONTACT-BTYPE.
      MOVE V_ABEVAZ TO T_ABEV_CONTACT-ABEVAZ.
      APPEND T_ABEV_CONTACT.
*++BG 2008.12.11
* ha nem talál megnézzük visszafele is
    ELSE.
* Konverzió meghatározása
      SELECT ABEVAZE INTO V_ABEVAZ
                    FROM /ZAK/ABEVK
                    UP TO 1 ROWS
*++1365#24.
*                   WHERE btype   EQ i_btype
*                     AND abevaz  EQ i_abevaz
*                     AND btypee  EQ v_btype.
                     WHERE BTYPE   EQ V_BTYPEE
                       AND ABEVAZ  EQ I_ABEVAZ
                       AND BTYPEE  EQ V_BTYPE.
*--1365#24.
      ENDSELECT.
      IF SY-SUBRC EQ 0.
        MOVE V_BTYPE  TO T_ABEV_CONTACT-BTYPE.
        MOVE V_ABEVAZ TO T_ABEV_CONTACT-ABEVAZ.
        APPEND T_ABEV_CONTACT.
*++1365#24.
        V_BTYPEE = V_BTYPEE.
        I_ABEVAZ = V_ABEVAZ.
*     Ha így sincs rekord, akkor nem változott az ABEV
      ELSE.
        MOVE V_BTYPE  TO T_ABEV_CONTACT-BTYPE.
        MOVE I_ABEVAZ TO T_ABEV_CONTACT-ABEVAZ.
        APPEND T_ABEV_CONTACT.
*--1365#24.
      ENDIF.
*--BG 2008.12.11
    ENDIF.
*++1365#24.
  ENDLOOP.
*--1365#24.

** Meghatározzuk az import beszámoló típusát
*  SELECT BUKRS BTYPE BTYPART MAX( DATBI )
*                              INTO (V_BUKRS,
*                                    V_BTYPE,
*                                    V_BTYPART,
*                                    V_DATUM)
*                              FROM  /ZAK/BEVALL
*                            WHERE   BUKRS EQ I_BUKRS
*                               AND  BTYPE EQ I_BTYPE
*                            GROUP BY BUKRS BTYPE BTYPART.
*  ENDSELECT.
** Nincs adat
*  IF SY-SUBRC NE 0.
*    MESSAGE E109(/ZAK/ZAK) WITH I_BTYPE I_BUKRS RAISING ERROR_BTYPE.
**   & bevallás típus & vállalatban nem létezik!
*  ENDIF.
*
** Kiinduló év
*  V_GJAHR = V_DATUM(4).
*
** Meghatározzuk az irányt.
*  IF I_GJAHR < V_GJAHR.
*    V_UPDN = '-'.
*  ELSEIF I_GJAHR > V_GJAHR.
*    V_UPDN = '+'.
*  ENDIF.
*
*
** Meghatározzuk a bevallás típusokat.
*  DO.
*    CLEAR: W_ABEV_CONTACT.
*    IF V_DATUM IS INITIAL.
*      V_DATUM(4)   = V_GJAHR.
*      V_DATUM+4(2) = I_MONAT.
*      V_DATUM+6(2) = 01.
*    ENDIF.
*
**   Hónap utolsó napjának meghatározása
*    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
*         EXPORTING
*              DAY_IN            = V_DATUM
*         IMPORTING
*              LAST_DAY_OF_MONTH = V_DATUM.
**   Bevallás típusok meghatározása
*    SELECT BTYPE INTO W_ABEV_CONTACT-BTYPE
*                 FROM /ZAK/BEVALL
*                      UP TO 1 ROWS
*                WHERE BUKRS EQ I_BUKRS
*                  AND DATBI GE V_DATUM
*                  AND DATAB LE V_DATUM
*                  AND BTYPART EQ V_BTYPART.
*    ENDSELECT.
*    IF SY-SUBRC NE 0.
*      MESSAGE E111(/ZAK/ZAK) WITH V_BTYPART V_DATUM(4) RAISING ERROR_BTYPE.
**     Hiányzó beállítás & bevallás fajtához & évben!
*    ELSE.
*      APPEND W_ABEV_CONTACT TO T_ABEV_CONTACT.
*    ENDIF.
*    IF V_UPDN EQ '-'.
*      SUBTRACT 1 FROM V_GJAHR.
*      IF V_GJAHR < I_GJAHR.
*        EXIT.
*      ENDIF.
*    ELSEIF V_UPDN EQ '+'.
*      ADD 1 TO V_GJAHR.
*      IF V_GJAHR > I_GJAHR.
*        EXIT.
*      ENDIF.
**++BG 2006.09.15
*    ELSE.
*      EXIT.
**--BG 2006.09.15
*    ENDIF.
*  ENDDO.
*
*  MOVE I_ABEVAZ TO V_ABEVAZ.
*
** ABEV azonosítók meghatározása
*  LOOP AT T_ABEV_CONTACT INTO W_ABEV_CONTACT.
*
*    PERFORM GET_ABEVAZ USING W_ABEV_CONTACT
*                             V_BTYPE
*                             V_ABEVAZ
*                             .
*    MODIFY T_ABEV_CONTACT FROM W_ABEV_CONTACT TRANSPORTING ABEVAZ.
*    MOVE W_ABEV_CONTACT-BTYPE TO V_BTYPE.
*  ENDLOOP.




*--0003 BG 2006.12.13

ENDFUNCTION.
