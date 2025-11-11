*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBEV_MVF01 .
*----------------------------------------------------------------------*

FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BEVALL_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/BEVALL_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/BEVALL_V-UNAME.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM verify_field                                             *
*---------------------------------------------------------------------*
*       Mező ellenőrzések
*---------------------------------------------------------------------*
FORM VERIFY_FIELD.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BUKRS TYPE BUKRS.
  DATA L_BTYPE TYPE /ZAK/BTYPE.
  DATA L_DATBI TYPE DATBI.
  DATA L_BTYPART TYPE /ZAK/BTYPART.

  DATA LI_BEVALL_TOTAL LIKE /ZAK/BEVALL_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_BEVALL_TOTAL[] = /ZAK/BEVALL_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/BEVALL_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/BEVALL_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/BEVALL_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_BUKRS, L_BTYPE, L_DATBI.
*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/BEVALL_V_TOTAL-DATAB GE /ZAK/BEVALL_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
    ENDIF.

*   Előző bevallás típusnak uo. fajtájunak kell lennie és az érvényesség
*   végének kisebbnek kell lennie.

    IF /ZAK/BEVALL_V_TOTAL-BTYPEE NE /ZAK/BEVALL_V_TOTAL-BTYPE.

      SELECT BTYPART DATBI INTO
                                (L_BTYPART,
                                 L_DATBI)
                      UP TO 1 ROWS
                      FROM /ZAK/BEVALL
                     WHERE BUKRS EQ /ZAK/BEVALL_V_TOTAL-BUKRS
                       AND BTYPE EQ /ZAK/BEVALL_V_TOTAL-BTYPEE
                       ORDER BY DATBI DESCENDING
                      .
      ENDSELECT.
      IF ( L_BTYPART NE /ZAK/BEVALL_V_TOTAL-BTYPART ) OR SY-SUBRC NE 0.
        MOVE 'T' TO L_TRUE.
        EXIT.
      ENDIF.


*   Előző bevallás típusnak kisebb dátumúnak kell lennie
      IF L_DATBI GT /ZAK/BEVALL_V_TOTAL-DATBI.
        MOVE 'D' TO L_TRUE.
        EXIT.
      ENDIF.
    ENDIF.

*   Átfedő intervallumok keresése bizonylat fajtára
*     Bizonylat fajta meghatározás
    SELECT BTYPART DATBI INTO
                              (L_BTYPART,
                               L_DATBI)
                    UP TO 1 ROWS
                    FROM /ZAK/BEVALL
                   WHERE BUKRS EQ /ZAK/BEVALL_V_TOTAL-BUKRS
                     AND BTYPE EQ /ZAK/BEVALL_V_TOTAL-BTYPE
                     ORDER BY DATBI DESCENDING
                    .
    ENDSELECT.

    LOOP AT LI_BEVALL_TOTAL WHERE BUKRS   EQ /ZAK/BEVALL_V_TOTAL-BUKRS
                              AND BTYPART EQ L_BTYPART.
      CHECK SY-TABIX NE L_TABIX AND
*++BG 2006.09.15
*       /ZAK/BEVALL_V_TOTAL-ACTION NE 'D' AND
*       /ZAK/BEVALL_V_TOTAL-ACTION NE 'X' AND
       LI_BEVALL_TOTAL-ACTION NE 'D' AND
       LI_BEVALL_TOTAL-ACTION NE 'X' AND
*--BG 2006.09.15
       ( /ZAK/BEVALL_V_TOTAL-DATAB BETWEEN LI_BEVALL_TOTAL-DATAB AND
                                          LI_BEVALL_TOTAL-DATBI OR
         /ZAK/BEVALL_V_TOTAL-DATBI BETWEEN LI_BEVALL_TOTAL-DATAB AND
                                          LI_BEVALL_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      EXIT.
    ENDLOOP.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/BEVALL_V_TOTAL-BUKRS TO L_BUKRS.
      MOVE /ZAK/BEVALL_V_TOTAL-BTYPE TO L_BTYPE.
      MOVE /ZAK/BEVALL_V_TOTAL-DATBI TO L_DATBI.
      MOVE /ZAK/BEVALL_V_TOTAL-BTYPART TO L_BTYPART.
      EXIT.
    ENDIF.
  ENDLOOP.

* Átfedő intervallum
  IF  L_TRUE EQ 'A'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S131(/ZAK/ZAK) WITH L_BUKRS L_BTYPE L_DATBI.
*   Kérem ne adjon meg átfedő intervallumot!

* Érvényesség kezdete > Érvényesség vége
  ELSEIF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_BUKRS L_BTYPE L_DATBI.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)

* Előző bevallás típus más fajtájú
  ELSEIF L_TRUE EQ 'T'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S134(/ZAK/ZAK) WITH L_BTYPART L_BUKRS L_BTYPE L_DATBI.
*   Kérem & fajtájú bevallás típust adjon meg előzőként! (& & &)

* Előző bevallás típus dátuma nem megfelelő
  ELSEIF L_TRUE EQ 'D'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S135(/ZAK/ZAK) WITH L_BUKRS L_BTYPE L_DATBI.
*   Előző bevallás típust, megelőző időszakból adjon meg! (& & &)

  ENDIF.

  FREE LI_BEVALL_TOTAL.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM commit_work                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM COMMIT_WORK.

  IF VIM_ABORT_SAVING = SPACE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.




**&---------------------------------------------------------------------
**
**&      Module  CHECK_FIELD  INPUT
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
*MODULE CHECK_FIELD INPUT.
*
** Átfedő intervallumok kezelése
*  PERFORM CHECK_INTERVALL USING /ZAK/BEVALL_V.
*
*ENDMODULE.                 " CHECK_FIELD  INPUT
**&---------------------------------------------------------------------
**
**&      Form  check_intervall
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
**      -->P_/ZAK/BEVALL_V  text
**----------------------------------------------------------------------
**
*FORM CHECK_INTERVALL USING  $BEVALL LIKE /ZAK/BEVALL_V.
*
*  DATA L_COUNT TYPE I.
*
*  CLEAR VIM_ABORT_SAVING.
*
** Ha nem törlés
*  CHECK SY-UCOMM NE 'DELE'.
*
*  LOOP AT /ZAK/BEVALL_V_TOTAL WHERE BUKRS EQ $BEVALL-BUKRS
*                               AND BTYPE EQ $BEVALL-BTYPE
*                               .
**   Törölt rekordok kihagyása
*    CHECK /ZAK/BEVALL_V_TOTAL-ACTION NE 'D' AND
*          /ZAK/BEVALL_V_TOTAL-ACTION NE 'X'.
*
*    IF  ( $BEVALL-DATBI BETWEEN /ZAK/BEVALL_V_TOTAL-DATAB AND
*                             /ZAK/BEVALL_V_TOTAL-DATBI )  OR
*        ( $BEVALL-DATAB BETWEEN /ZAK/BEVALL_V_TOTAL-DATAB AND
*                             /ZAK/BEVALL_V_TOTAL-DATBI ).
*      ADD 1 TO L_COUNT.
*    ENDIF.
*  ENDLOOP.
*
*  IF L_COUNT GT 1.
*    MOVE 'X' TO VIM_ABORT_SAVING.
*    MESSAGE S131(/ZAK/ZAK).
**   Kérem ne adjon meg átfedő intervallumot!
*  ENDIF.
*
*ENDFORM.                    " check_intervall
