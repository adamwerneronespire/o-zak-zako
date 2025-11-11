*----------------------------------------------------------------------*
***INCLUDE /ZAK/LKUNNR_CST_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  GET TIME.
  /ZAK/KUNNR_CST_V-AS4USER = SY-UNAME.
  /ZAK/KUNNR_CST_V-AS4DATE = SY-DATUM.
  /ZAK/KUNNR_CST_V-AS4TIME = SY-UZEIT.

ENDFORM.                    "change_data
*---------------------------------------------------------------------*
*       FORM verify_field                                             *
*---------------------------------------------------------------------*
*       Mező ellenőrzések
*---------------------------------------------------------------------*
FORM VERIFY_FIELD.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_KUNNR TYPE KUNNR.
  DATA L_DATBI TYPE DATBI.

  DATA LI_KUNNR_CST_TOTAL LIKE /ZAK/KUNNR_CST_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_KUNNR_CST_TOTAL[] = /ZAK/KUNNR_CST_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/KUNNR_CST_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/KUNNR_CST_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/KUNNR_CST_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_KUNNR, L_DATBI.
*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/KUNNR_CST_V_TOTAL-DATAB GE /ZAK/KUNNR_CST_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
    ENDIF.

*   Átfedő intervallumok keresése bizonylat fajtára
*     Bizonylat fajta meghatározás
    SELECT  DATBI INTO L_DATBI
                    UP TO 1 ROWS
                    FROM /ZAK/KUNNR_CST
                   WHERE KUNNR EQ /ZAK/KUNNR_CST_V_TOTAL-KUNNR
                     ORDER BY DATBI DESCENDING
                    .
    ENDSELECT.

    LOOP AT LI_KUNNR_CST_TOTAL WHERE KUNNR EQ /ZAK/KUNNR_CST_V_TOTAL-KUNNR.
      CHECK SY-TABIX NE L_TABIX AND
*++BG 2006.09.15
*       /ZAK/KUNNR_CST_V_TOTAL-ACTION NE 'D' AND
*       /ZAK/KUNNR_CST_V_TOTAL-ACTION NE 'X' AND
       LI_KUNNR_CST_TOTAL-ACTION NE 'D' AND
       LI_KUNNR_CST_TOTAL-ACTION NE 'X' AND
*--BG 2006.09.15
       ( /ZAK/KUNNR_CST_V_TOTAL-DATAB BETWEEN LI_KUNNR_CST_TOTAL-DATAB AND
                                          LI_KUNNR_CST_TOTAL-DATBI OR
         /ZAK/KUNNR_CST_V_TOTAL-DATBI BETWEEN LI_KUNNR_CST_TOTAL-DATAB AND
                                          LI_KUNNR_CST_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      EXIT.
    ENDLOOP.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/KUNNR_CST_V_TOTAL-KUNNR TO L_KUNNR.
      MOVE /ZAK/KUNNR_CST_V_TOTAL-DATBI TO L_DATBI.
      EXIT.
    ENDIF.
  ENDLOOP.

* Átfedő intervallum
  IF  L_TRUE EQ 'A'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S131(/ZAK/ZAK) WITH L_KUNNR L_DATBI.
*   Kérem ne adjon meg átfedő intervallumot!

* Érvényesség kezdete > Érvényesség vége
  ELSEIF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_KUNNR L_DATBI.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)

  ENDIF.

  FREE LI_KUNNR_CST_TOTAL.



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
