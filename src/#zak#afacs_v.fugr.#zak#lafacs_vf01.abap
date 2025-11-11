*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFACS_VF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/AFACS_V-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/AFACS_V-AS4TIME.
  MOVE SY-UNAME TO /ZAK/AFACS_V-AS4USER.

ENDFORM.



FORM VERIFY_FIELD.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BUKRS TYPE BUKRS.
  DATA L_BTYPE TYPE /ZAK/BTYPE.
  DATA L_DATBI TYPE DATBI.

  DATA LI_AFACS_TOTAL LIKE /ZAK/AFACS_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_AFACS_TOTAL[] = /ZAK/AFACS_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/AFACS_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/AFACS_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/AFACS_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_BUKRS, L_BTYPE, L_DATBI.
*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/AFACS_V_TOTAL-DATAB GE /ZAK/AFACS_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
    ENDIF.
*   Csoport vállalat ellenőrzése
*++1965 #06.
*    IF /ZAK/AFACS_V_TOTAL-BUKRS GE /ZAK/AFACS_V_TOTAL-BUKCS.
    IF /ZAK/AFACS_V_TOTAL-BUKRS EQ /ZAK/AFACS_V_TOTAL-BUKCS.
*--1965 #06.
      MOVE 'V' TO L_TRUE.
    ENDIF.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/AFACS_V_TOTAL-BUKRS TO L_BUKRS.
      MOVE /ZAK/AFACS_V_TOTAL-BTYPE TO L_BTYPE.
      MOVE /ZAK/AFACS_V_TOTAL-DATBI TO L_DATBI.
      EXIT.
    ENDIF.

*   Átfedő intervallumok keresése vállalat és csoport vállalatra
    LOOP AT LI_AFACS_TOTAL  WHERE BUKRS   EQ /ZAK/AFACS_V_TOTAL-BUKRS
                              AND BTYPE   EQ /ZAK/AFACS_V_TOTAL-BTYPE
                              AND BUKCS   EQ /ZAK/AFACS_V_TOTAL-BUKCS.
      CHECK SY-TABIX NE L_TABIX AND
       LI_AFACS_TOTAL-ACTION NE 'D' AND
       LI_AFACS_TOTAL-ACTION NE 'X' AND
       ( /ZAK/AFACS_V_TOTAL-DATAB BETWEEN LI_AFACS_TOTAL-DATAB AND
                                          LI_AFACS_TOTAL-DATBI OR
         /ZAK/AFACS_V_TOTAL-DATBI BETWEEN LI_AFACS_TOTAL-DATAB AND
                                          LI_AFACS_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      MOVE /ZAK/AFACS_V_TOTAL-BUKRS TO L_BUKRS.
      MOVE /ZAK/AFACS_V_TOTAL-BTYPE TO L_BTYPE.
      MOVE /ZAK/AFACS_V_TOTAL-DATBI TO L_DATBI.
      EXIT.
    ENDLOOP.
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
* Csoport vállalat ellenőrzése
  ELSEIF L_TRUE EQ 'V'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S293(/ZAK/ZAK) WITH L_BUKRS.
*   Csoport vállalat megegyezik a normál vállalattal!
  ENDIF.

  FREE LI_AFACS_TOTAL.

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
