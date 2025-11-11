*----------------------------------------------------------------------*
***INCLUDE /ZAK/LPADONSZA_MVF01 .
*----------------------------------------------------------------------*
***INCLUDE /ZAK/LPADONSZA_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  GET TIME.
  /ZAK/PADONSZA_V-AS4USER = SY-UNAME.
  /ZAK/PADONSZA_V-AS4DATE = SY-DATUM.
  /ZAK/PADONSZA_V-AS4TIME = SY-UZEIT.

ENDFORM.                    "change_data

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
  DATA L_DATAB TYPE DATAB.
  DATA L_BTYPART TYPE /ZAK/BTYPART.
  DATA L_ADOAZON TYPE /ZAK/ADOAZON.

  DATA LI_PADONSZA_TOTAL LIKE /ZAK/PADONSZA_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_PADONSZA_TOTAL[] = /ZAK/PADONSZA_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/PADONSZA_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/PADONSZA_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/PADONSZA_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_BUKRS, L_BTYPE, L_DATBI.
*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/PADONSZA_V_TOTAL-DATAB GE /ZAK/PADONSZA_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
    ENDIF.

    SELECT DATBI INTO L_DATBI
                UP TO 1 ROWS
                FROM /ZAK/PADONSZA
               WHERE ADOAZON EQ /ZAK/PADONSZA_V_TOTAL-ADOAZON
                 ORDER BY DATBI DESCENDING
                .
    ENDSELECT.

    LOOP AT LI_PADONSZA_TOTAL WHERE ADOAZON EQ /ZAK/PADONSZA_V_TOTAL-ADOAZON.
      CHECK SY-TABIX NE L_TABIX AND
*++BG 2006.09.15
*       /ZAK/PADONSZA_V_TOTAL-ACTION NE 'D' AND
*       /ZAK/PADONSZA_V_TOTAL-ACTION NE 'X' AND
       LI_PADONSZA_TOTAL-ACTION NE 'D' AND
       LI_PADONSZA_TOTAL-ACTION NE 'X' AND
*--BG 2006.09.15
       ( /ZAK/PADONSZA_V_TOTAL-DATAB BETWEEN LI_PADONSZA_TOTAL-DATAB AND
                                          LI_PADONSZA_TOTAL-DATBI OR
         /ZAK/PADONSZA_V_TOTAL-DATBI BETWEEN LI_PADONSZA_TOTAL-DATAB AND
                                          LI_PADONSZA_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      EXIT.
    ENDLOOP.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/PADONSZA_V_TOTAL-DATAB TO L_DATAB.
      MOVE /ZAK/PADONSZA_V_TOTAL-ADOAZON TO L_ADOAZON.
      EXIT.
    ENDIF.
  ENDLOOP.

* Átfedő intervallum
  IF  L_TRUE EQ 'A'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S131(/ZAK/ZAK) WITH L_ADOAZON L_DATAB.
*   Kérem ne adjon meg átfedő intervallumot!

* Érvényesség kezdete > Érvényesség vége
  ELSEIF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_ADOAZON L_DATAB.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)
  ENDIF.
  FREE LI_PADONSZA_TOTAL.

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
