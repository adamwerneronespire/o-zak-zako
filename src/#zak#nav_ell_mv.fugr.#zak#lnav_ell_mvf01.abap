*----------------------------------------------------------------------*
***INCLUDE /ZAK/LNAV_ELL_MVF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHANGE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_DATA .

  GET TIME.
  /ZAK/NAV_ELL_V-AS4DATE = SY-DATUM.
  /ZAK/NAV_ELL_V-AS4USER = SY-UNAME.
  /ZAK/NAV_ELL_V-AS4TIME = SY-UZEIT.

ENDFORM.

INCLUDE /ZAK/LNAV_ELL_MVF02.
*&---------------------------------------------------------------------*
*&      Form  VERIFY_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VERIFY_FIELD .
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BUKRS TYPE BUKRS.
  DATA L_BTYPART TYPE /ZAK/BTYPART.
  DATA L_GJAHR TYPE GJAHR.

  DATA LI_NAV_ELL LIKE /ZAK/NAV_ELL_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_NAV_ELL[] = /ZAK/NAV_ELL_V_TOTAL[].

* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/NAV_ELL_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.
*   Ha törlés akkor azt engedjük
    CHECK /ZAK/NAV_ELL_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/NAV_ELL_V_TOTAL-ACTION NE 'X'.

    CLEAR: L_TRUE, L_BUKRS, L_BTYPART, L_GJAHR.

*   Érvényesség kezdete kisebb legyen az érv.végénél
    IF /ZAK/NAV_ELL_V_TOTAL-MONAT_FROM > /ZAK/NAV_ELL_V_TOTAL-MONAT_TO.
      MOVE  /ZAK/NAV_ELL_V_TOTAL-BUKRS   TO L_BUKRS.
      MOVE  /ZAK/NAV_ELL_V_TOTAL-BTYPART TO L_BTYPART.
      MOVE  /ZAK/NAV_ELL_V_TOTAL-GJAHR   TO L_GJAHR.
      MOVE 'E' TO L_TRUE.
    ENDIF.
  ENDLOOP.

* Érvényesség kezdete > Érvényesség vége
  IF L_TRUE EQ 'E'.
    MOVE 'X' TO VIM_ABORT_SAVING.
    MESSAGE S133(/ZAK/ZAK) WITH L_BUKRS L_BTYPART L_GJAHR.
*   Érvényesség kezdete nagyobb, mint az érvényesség vége! (& & &)
  ENDIF.

  FREE LI_NAV_ELL.

ENDFORM.
