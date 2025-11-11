*----------------------------------------------------------------------*
***INCLUDE /ZAK/LSZJA_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/SZJA_CUST_V-DATUM.
  MOVE SY-UZEIT TO /ZAK/SZJA_CUST_V-UZEIT.
  MOVE SY-UNAME TO /ZAK/SZJA_CUST_V-UNAME.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM verify_field                                             *
*---------------------------------------------------------------------*
*       Mező ellenőrzések
*---------------------------------------------------------------------*
FORM VERIFY_FIELD.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BUKRS  TYPE BUKRS.
  DATA L_BTYPE  TYPE /ZAK/BTYPE.
  DATA L_BSZNUM TYPE /ZAK/BSZNUM.
  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.

  DATA LI_/ZAK/SZJA_CUST_TOTAL LIKE /ZAK/SZJA_CUST_V_TOTAL OCCURS 0
       WITH HEADER LINE.


  DEFINE LM_DATE.
    &1(2)   = '20'.
    &1+2(2) = &2(2).
    &1+4(2) = &3.
    &1+6(2) = &4.
  END-OF-DEFINITION.

  CLEAR VIM_ABORT_SAVING.
  LI_/ZAK/SZJA_CUST_TOTAL[] = /ZAK/SZJA_CUST_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/SZJA_CUST_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.

*   Ha törlés akkor azt engedjük
    CHECK /ZAK/SZJA_CUST_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/SZJA_CUST_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_BUKRS, L_BTYPE, L_BSZNUM, L_ABEVAZ.
*   Üres dátum mező feltöltése
    IF /ZAK/SZJA_CUST_V_TOTAL-DATAB IS INITIAL.
      LM_DATE /ZAK/SZJA_CUST_V_TOTAL-DATAB /ZAK/SZJA_CUST_V_TOTAL-BTYPE '01' '01'.
    ENDIF.

    IF /ZAK/SZJA_CUST_V_TOTAL-DATBI IS INITIAL.
      LM_DATE /ZAK/SZJA_CUST_V_TOTAL-DATBI /ZAK/SZJA_CUST_V_TOTAL-BTYPE '12' '31'.
    ENDIF.

*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/SZJA_CUST_V_TOTAL-DATAB GE /ZAK/SZJA_CUST_V_TOTAL-DATBI.
      MOVE 'E' TO L_TRUE.
      EXIT.
    ENDIF.

*   Átfedő intervallumok keresése bizonylat fajtára
    LOOP AT LI_/ZAK/SZJA_CUST_TOTAL WHERE BUKRS   EQ /ZAK/SZJA_CUST_V_TOTAL-BUKRS
                                     AND BTYPE   EQ /ZAK/SZJA_CUST_V_TOTAL-BTYPE
                                     AND BSZNUM  EQ /ZAK/SZJA_CUST_V_TOTAL-BSZNUM
                                     AND ABEVAZ  EQ /ZAK/SZJA_CUST_V_TOTAL-ABEVAZ
                                     AND SAKNR   EQ /ZAK/SZJA_CUST_V_TOTAL-SAKNR
                                     AND SAKNR   EQ /ZAK/SZJA_CUST_V_TOTAL-SAKNR.

*   Üres dátum mező feltöltése
      IF LI_/ZAK/SZJA_CUST_TOTAL-DATAB IS INITIAL.
        LM_DATE LI_/ZAK/SZJA_CUST_TOTAL-DATAB LI_/ZAK/SZJA_CUST_TOTAL-BTYPE '01' '01'.
      ENDIF.

      IF LI_/ZAK/SZJA_CUST_TOTAL-DATBI IS INITIAL.
        LM_DATE LI_/ZAK/SZJA_CUST_TOTAL-DATBI LI_/ZAK/SZJA_CUST_TOTAL-BTYPE '12' '31'.
      ENDIF.

      CHECK SY-TABIX NE L_TABIX AND
       LI_/ZAK/SZJA_CUST_TOTAL-ACTION NE 'D' AND
       LI_/ZAK/SZJA_CUST_TOTAL-ACTION NE 'X' AND
       ( /ZAK/SZJA_CUST_V_TOTAL-DATAB BETWEEN LI_/ZAK/SZJA_CUST_TOTAL-DATAB AND
                                             LI_/ZAK/SZJA_CUST_TOTAL-DATBI OR
         /ZAK/SZJA_CUST_V_TOTAL-DATBI BETWEEN LI_/ZAK/SZJA_CUST_TOTAL-DATAB AND
                                             LI_/ZAK/SZJA_CUST_TOTAL-DATBI ).
      MOVE 'A' TO L_TRUE.
      EXIT.
    ENDLOOP.

    IF NOT L_TRUE IS INITIAL.
      MOVE /ZAK/SZJA_CUST_V_TOTAL-BUKRS  TO L_BUKRS.
      MOVE /ZAK/SZJA_CUST_V_TOTAL-BTYPE  TO L_BTYPE.
      MOVE /ZAK/SZJA_CUST_V_TOTAL-BSZNUM TO L_BSZNUM.
      MOVE /ZAK/SZJA_CUST_V_TOTAL-ABEVAZ TO L_ABEVAZ.
      EXIT.
    ENDIF.
  ENDLOOP.

* Átfedő intervallum
  IF  L_TRUE EQ 'A'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S131(/ZAK/ZAK) WITH L_BUKRS L_BTYPE L_BSZNUM L_ABEVAZ.
*   Kérem ne adjon meg átfedő intervallumot!

* Érvényesség kezdete > Érvényesség vége
  ELSEIF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_BUKRS L_BTYPE L_BSZNUM L_ABEVAZ.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)
  ENDIF.
  FREE LI_/ZAK/SZJA_CUST_TOTAL.
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
