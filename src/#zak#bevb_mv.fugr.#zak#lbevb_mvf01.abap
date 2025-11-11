*----------------------------------------------------------------------*
***INCLUDE /ZAK/LBEVB_MVF01 .
*----------------------------------------------------------------------*
FORM VERIFY_FIELD.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TRUE.
  DATA L_BTYPE_FIND TYPE I.

  DATA LI_BEVALLB_TOTAL LIKE /ZAK/BEVALLB_V_TOTAL OCCURS 0
       WITH HEADER LINE.

  CLEAR VIM_ABORT_SAVING.
  LI_BEVALLB_TOTAL[] = /ZAK/BEVALLB_V_TOTAL[].


* Végigolvassuk azokat a rekordokat ahol volt módosítás
  LOOP AT /ZAK/BEVALLB_V_TOTAL WHERE NOT ACTION IS INITIAL.
    MOVE SY-TABIX TO L_TABIX.
*   Ha törlés akkor azt engedjük
    CHECK /ZAK/BEVALLB_V_TOTAL-ACTION NE 'D'.
    CHECK /ZAK/BEVALLB_V_TOTAL-ACTION NE 'X'.
    CLEAR L_BTYPE_FIND.
*   Ellenőrizzük mennyi esedékességi dátum van beállíva BTYP-onként
    LOOP AT LI_BEVALLB_TOTAL WHERE BTYPE   EQ /ZAK/BEVALLB_V_TOTAL-BTYPE
                               AND NOT ESDAT_FLAG IS INITIAL.
      ADD 1 TO L_BTYPE_FIND.
    ENDLOOP.
*   Ha több mint egy találat van, akkor hiba
    IF L_BTYPE_FIND > 1.
      MOVE 'X' TO VIM_ABORT_SAVING.
      MESSAGE S162(/ZAK/ZAK) WITH /ZAK/BEVALLB_V_TOTAL-BTYPE.
*   & bevallás típusnál egynél több esedékességi dátum mező van bejelölv
      EXIT.
    ENDIF.

ENDLOOP.


DATA: L_OBJECTID   TYPE CDOBJECTV.
DATA: NEW_BEVALLB  TYPE /ZAK/BEVALLB,
      OLD_BEVALLB  TYPE /ZAK/BEVALLB.
DATA: NEW_BEVALLBt TYPE /ZAK/BEVALLBT,
      OLD_BEVALLBt TYPE /ZAK/BEVALLBT.
data: l_ind.

LOOP AT /ZAK/BEVALLB_V_TOTAL WHERE NOT ACTION IS INITIAL.

case /ZAK/BEVALLB_V_TOTAL-action.
  when 'N'.
    l_ind = 'I'.
  when others.
    l_ind = /ZAK/BEVALLB_V_TOTAL-action.
endcase.

CONCATENATE /ZAK/BEVALLB_V_TOTAL-MANDT
            /ZAK/BEVALLB_V_TOTAL-BTYPE
            /ZAK/BEVALLB_V_TOTAL-ABEVAZ INTO L_OBJECTID.


MOVE-CORRESPONDING /ZAK/BEVALLB_V_TOTAL TO NEW_BEVALLB.
MOVE-CORRESPONDING /ZAK/BEVALLB_V_TOTAL TO NEW_BEVALLBT.

SELECT SINGLE * INTO OLD_BEVALLB FROM /ZAK/BEVALLB
        WHERE BTYPE  = /ZAK/BEVALLB_V_TOTAL-BTYPE AND
              ABEVAZ = /ZAK/BEVALLB_V_TOTAL-ABEVAZ.

SELECT SINGLE * INTO OLD_BEVALLBt FROM /ZAK/BEVALLBT
        WHERE LANGu  = SY-LANGU AND
              BTYPE  = /ZAK/BEVALLB_V_TOTAL-BTYPE AND
              ABEVAZ = /ZAK/BEVALLB_V_TOTAL-ABEVAZ.

CALL FUNCTION '/ZAK/BEVALLB_WRITE_DOCUMENT'
  EXPORTING
    OBJECTID                      = L_OBJECTID
    TCODE                         = SY-TCODE
    UTIME                         = SY-UZEIT
    UDATE                         = SY-DATUM
    USERNAME                      = SY-UNAME
*   PLANNED_CHANGE_NUMBER         = ' '
    OBJECT_CHANGE_INDICATOR       = l_ind
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
    N_/ZAK/BEVALLB                 = NEW_BEVALLB
    O_/ZAK/BEVALLB                 = OLD_BEVALLB
    UPD_/ZAK/BEVALLB               = l_ind
    N_/ZAK/BEVALLBT                = NEW_BEVALLBt
    O_/ZAK/BEVALLBT                = OLD_BEVALLBt
    UPD_/ZAK/BEVALLBT              = l_ind
          .

ENDLOOP.


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
