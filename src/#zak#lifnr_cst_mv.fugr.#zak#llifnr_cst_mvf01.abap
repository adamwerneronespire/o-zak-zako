*----------------------------------------------------------------------*
***INCLUDE /ZAK/LLIFNR_CST_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  GET TIME.
  /ZAK/LIFNR_CST_V-AS4USER = SY-UNAME.
  /ZAK/LIFNR_CST_V-AS4DATE = SY-DATUM.
  /ZAK/LIFNR_CST_V-AS4TIME = SY-UZEIT.

ENDFORM.                    "change_data

*---------------------------------------------------------------------*
*       FORM verify_field                                             *
*---------------------------------------------------------------------*
*       Mező ellenőrzések
*---------------------------------------------------------------------*
FORM VERIFY_FIELD.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_LIFNR TYPE LIFNR.
  DATA L_DATBI TYPE DATBI.

  DATA LI_LIFNR_CST_TOTAL LIKE /ZAK/LIFNR_CST_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_LIFNR_CST_TOTAL[] = /ZAK/LIFNR_CST_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/LIFNR_CST_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/LIFNR_CST_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/LIFNR_CST_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_LIFNR, L_DATBI.
*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/LIFNR_CST_V_TOTAL-DATAB GE /ZAK/LIFNR_CST_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
    ENDIF.

*   Átfedő intervallumok keresése bizonylat fajtára
*     Bizonylat fajta meghatározás
    SELECT  DATBI INTO L_DATBI
                    UP TO 1 ROWS
                    FROM /ZAK/LIFNR_CST
                   WHERE LIFNR EQ /ZAK/LIFNR_CST_V_TOTAL-LIFNR
                     ORDER BY DATBI DESCENDING
                    .
    ENDSELECT.

    LOOP AT LI_LIFNR_CST_TOTAL WHERE LIFNR EQ /ZAK/LIFNR_CST_V_TOTAL-LIFNR.
      CHECK SY-TABIX NE L_TABIX AND
*++BG 2006.09.15
*       /ZAK/LIFNR_CST_V_TOTAL-ACTION NE 'D' AND
*       /ZAK/LIFNR_CST_V_TOTAL-ACTION NE 'X' AND
       LI_LIFNR_CST_TOTAL-ACTION NE 'D' AND
       LI_LIFNR_CST_TOTAL-ACTION NE 'X' AND
*--BG 2006.09.15
       ( /ZAK/LIFNR_CST_V_TOTAL-DATAB BETWEEN LI_LIFNR_CST_TOTAL-DATAB AND
                                          LI_LIFNR_CST_TOTAL-DATBI OR
         /ZAK/LIFNR_CST_V_TOTAL-DATBI BETWEEN LI_LIFNR_CST_TOTAL-DATAB AND
                                          LI_LIFNR_CST_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      EXIT.
    ENDLOOP.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/LIFNR_CST_V_TOTAL-LIFNR TO L_LIFNR.
      MOVE /ZAK/LIFNR_CST_V_TOTAL-DATBI TO L_DATBI.
      EXIT.
    ENDIF.
  ENDLOOP.

* Átfedő intervallum
  IF  L_TRUE EQ 'A'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S131(/ZAK/ZAK) WITH L_LIFNR L_DATBI.
*   Kérem ne adjon meg átfedő intervallumot!

* Érvényesség kezdete > Érvényesség vége
  ELSEIF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_LIFNR L_DATBI.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)

  ENDIF.

  FREE LI_LIFNR_CST_TOTAL.



ENDFORM.                    "VERIFY_FIELD

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

ENDFORM.                    "COMMIT_WORK
