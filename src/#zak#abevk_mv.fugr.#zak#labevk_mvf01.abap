*----------------------------------------------------------------------*
***INCLUDE /ZAK/LABEVK_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.


* Háttérmezők ellátása
  GET TIME.
  MOVE SY-DATUM TO /ZAK/ABEVK_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/ABEVK_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/ABEVK_V-UNAME.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_LAST_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/ZAK/ABEVK_V_TOTAL_BTYPE  text
*      -->P_/ZAK/ABEVK_V_TOTAL_BTYPEE  text
*----------------------------------------------------------------------*
FORM CHECK_LAST_BTYPE USING    $BTYPE
                               $BTYPEE
                               $ABEVAZE.

  DATA W_BEVALL  LIKE /ZAK/BEVALL.
  DATA W_BEVALLE LIKE /ZAK/BEVALL.
  DATA L_COUNT TYPE I.

* Bevallás típus
  SELECT * INTO W_BEVALL UP TO 1 ROWS
           FROM /ZAK/BEVALL
          WHERE BTYPE EQ $BTYPE
           ORDER BY DATBI.
  ENDSELECT.

** Bevallás típus előző
*  SELECT * INTO W_BEVALLE UP TO 1 ROWS
*           FROM /ZAK/BEVALL
*          WHERE BTYPE EQ $BTYPEE
*           ORDER BY DATBI.
*  ENDSELECT.

** Bevallás fajta ellenőrzése
*  IF W_BEVALL-BTYPART NE W_BEVALLE-BTYPART.
*    MESSAGE E125(/ZAK/ZAK) WITH W_BEVALL-BTYPART.
**   Kérem & fajtájú bevallás típust adjon meg!
*  ENDIF.
*
** Ha a BTYPEE érvényessége megelőzi a BTYPE-t
*  IF W_BEVALLE-DATAB GE W_BEVALL-DATBI.
*    MESSAGE E127(/ZAK/ZAK).
**   Kérem dátum szerint előző bevallás típust adjon meg!
*  ENDIF.

* Csak a BEVALL alapján meghatározott előző típust adhatja meg.
  IF W_BEVALL-BTYPEE NE $BTYPEE.
    MESSAGE E130(/ZAK/ZAK) WITH W_BEVALL-BTYPEE.
*   Előző bevallás típus csak & lehet!
  ENDIF.

* Ha már létezik előző bevallás típus és ABEV azonosító
  CLEAR L_COUNT.
  LOOP AT /ZAK/ABEVK_V_TOTAL WHERE BTYPEE  = $BTYPEE
                              AND ABEVAZE = $ABEVAZE.
    ADD 1 TO L_COUNT.
  ENDLOOP.
  IF L_COUNT GT 1.
    MESSAGE E128(/ZAK/ZAK) WITH $BTYPEE $ABEVAZE.
*   Már létezik bejegyzés & bevallás típus & ABEVAZ értékkel!
  ENDIF.


ENDFORM.                    " CHECK_LAST_BTYPE

*---------------------------------------------------------------------*
*       FORM verify_field                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VERIFY_FIELD.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BTYPE  TYPE /ZAK/BTYPE.
  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA L_BTYPEE TYPE /ZAK/BTYPEE.
  DATA L_ABEVAZE TYPE /ZAK/ABEVAZE.
  DATA LW_BEVALL TYPE /ZAK/BEVALL.

  DATA LI_ABEVK_TOTAL LIKE /ZAK/ABEVK_V_TOTAL  OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.

*  LI_ABEVK_TOTAL[] = /ZAK/ABEVK_V_TOTAL[].
*
** Végigolvassuk azokat a rekordokat ahol volt módosítás
*  LOOP AT /ZAK/ABEVK_V_TOTAL WHERE NOT ACTION IS INITIAL.
*    MOVE SY-TABIX TO L_TABIX.
*
**   Ha törlés akkor azt engedjük
*    CHECK /ZAK/ABEVK_V_TOTAL-ACTION NE 'D'.
*    CHECK /ZAK/ABEVK_V_TOTAL-ACTION NE 'X'.
*
**   Bevallás típus
*    SELECT * INTO LW_BEVALL UP TO 1 ROWS
*             FROM /ZAK/BEVALL
*            WHERE BTYPE EQ /ZAK/ABEVK_V_TOTAL-BTYPE
*             ORDER BY DATBI DESCENDING.
*    ENDSELECT.
*
**   Csak a BEVALL alapján meghatározott előző típust adhatja meg.
*    IF /ZAK/ABEVK_V_TOTAL-BTYPEE NE LW_BEVALL-BTYPEE.
*      MOVE 'E' TO L_TRUE.
*    ENDIF.
*
**   Előző bevallás típus és ABEV azonosító nem fordulhat elő többször.
*    LOOP AT LI_ABEVK_TOTAL.
*      CHECK SY-TABIX NE L_TABIX AND
*            LI_ABEVK_TOTAL-BTYPEE  EQ /ZAK/ABEVK_V_TOTAL-BTYPEE AND
*            LI_ABEVK_TOTAL-ABEVAZE EQ /ZAK/ABEVK_V_TOTAL-ABEVAZE.
**     Van többszöri előfordulás
*      MOVE 'D' TO L_TRUE.
*      MOVE /ZAK/ABEVK_V_TOTAL-BTYPEE  TO L_BTYPEE.
*      MOVE /ZAK/ABEVK_V_TOTAL-ABEVAZE TO L_ABEVAZE.
*    ENDLOOP.
*
*    IF NOT L_TRUE IS INITIAL.
*      MOVE /ZAK/ABEVK_V_TOTAL-BTYPE  TO L_BTYPE.
*      MOVE /ZAK/ABEVK_V_TOTAL-ABEVAZ TO L_ABEVAZ.
*      EXIT.
*    ENDIF.
*  ENDLOOP.
*
**  Előző bevallás típus hiba.
*  IF L_TRUE EQ  'E'.
*    MOVE 'X' TO VIM_ABORT_SAVING.
*    MESSAGE S130(/ZAK/ZAK) WITH LW_BEVALL-BTYPEE L_BTYPE L_ABEVAZ.
**   Előző bevallás típus csak & lehet!
*
*  ELSEIF L_TRUE EQ 'D'.
*    MOVE 'X' TO VIM_ABORT_SAVING.
*    MESSAGE S128(/ZAK/ZAK) WITH L_BTYPEE L_ABEVAZE L_BTYPE L_ABEVAZ.
**   Már létezik bejegyzés & bevallás típus & ABEVAZ értékkel!
*  ENDIF.
*
*
*  FREE LI_ABEVK_TOTAL.

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


*&---------------------------------------------------------------------*
*&      Module  CHECK_FIELD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FIELD INPUT.

* Ellenőrzések
* Az előző időszak típus csak ugyanolyan fajtájú de előtte lévő
* időszakban kell lennie.
  PERFORM CHECK_LAST_BTYPE USING /ZAK/ABEVK_V-BTYPE
                                 /ZAK/ABEVK_V-BTYPEE
                                 /ZAK/ABEVK_V-ABEVAZE.

ENDMODULE.                 " CHECK_FIELD  INPUT
