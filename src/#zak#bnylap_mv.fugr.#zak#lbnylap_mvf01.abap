*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBNYLAP_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/BNYLAP_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/BNYLAP_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/BNYLAP_V-UNAME.


ENDFORM.                    "GET_CHANGE_DATA


*---------------------------------------------------------------------*
*       FORM verify_field                                             *
*---------------------------------------------------------------------*
*       Mező ellenőrzések
*---------------------------------------------------------------------*
FORM VERIFY_FIELD.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BUKRS     TYPE BUKRS.
  DATA L_BTYPART   TYPE /ZAK/BTYPART.
  DATA L_DATBI TYPE DATBI.

  DATA LI_BNYLAP_TOTAL LIKE /ZAK/BNYLAP_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_BNYLAP_TOTAL[] = /ZAK/BNYLAP_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/BNYLAP_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/BNYLAP_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/BNYLAP_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_BUKRS, L_BTYPART, L_DATBI.
*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/BNYLAP_V_TOTAL-DATAB GE /ZAK/BNYLAP_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
    ENDIF.

*   Átfedő intervallumok keresése bizonylat nyomtatvány azonosítóra
*     Bizonylat fajta meghatározás
    SELECT BTYPART DATBI INTO
                              (L_BTYPART,
                               L_DATBI)
                    UP TO 1 ROWS
                    FROM /ZAK/BNYLAP
                   WHERE BUKRS     EQ /ZAK/BNYLAP_V_TOTAL-BUKRS
                     AND NYLAPAZON EQ /ZAK/BNYLAP_V_TOTAL-NYLAPAZON
                     ORDER BY DATBI DESCENDING
                    .
    ENDSELECT.

    LOOP AT LI_BNYLAP_TOTAL WHERE BUKRS     EQ /ZAK/BNYLAP_V_TOTAL-BUKRS
                              AND BTYPART   EQ L_BTYPART.
      CHECK SY-TABIX NE L_TABIX AND
       LI_BNYLAP_TOTAL-ACTION NE 'D' AND
       LI_BNYLAP_TOTAL-ACTION NE 'X' AND

       ( /ZAK/BNYLAP_V_TOTAL-DATAB BETWEEN LI_BNYLAP_TOTAL-DATAB AND
                                          LI_BNYLAP_TOTAL-DATBI OR
         /ZAK/BNYLAP_V_TOTAL-DATBI BETWEEN LI_BNYLAP_TOTAL-DATAB AND
                                          LI_BNYLAP_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      EXIT.
    ENDLOOP.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/BNYLAP_V_TOTAL-BUKRS     TO L_BUKRS.
      MOVE /ZAK/BNYLAP_V_TOTAL-BTYPART   TO L_BTYPART.
      MOVE /ZAK/BNYLAP_V_TOTAL-DATBI     TO L_DATBI.
      EXIT.
    ENDIF.
  ENDLOOP.

* Átfedő intervallum
  IF  L_TRUE EQ 'A'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S131(/ZAK/ZAK) WITH L_BUKRS L_BTYPART L_DATBI.
*   Kérem ne adjon meg átfedő intervallumot!

* Érvényesség kezdete > Érvényesség vége
  ELSEIF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_BUKRS L_BTYPART L_DATBI.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)

  ENDIF.

  FREE LI_BNYLAP_TOTAL.
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
