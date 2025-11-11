*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_LIFKNMMVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_DATA.


  GET TIME.
  /ZAK/AFA_LIFKNMV-AS4USER = SY-UNAME.
  /ZAK/AFA_LIFKNMV-AS4DATE = SY-DATUM.
  /ZAK/AFA_LIFKNMV-AS4TIME = SY-UZEIT.

* Szállító/Vevő név meghatározása
  CHECK NOT /ZAK/AFA_LIFKNMV-LIFKUN IS INITIAL.

  IF /ZAK/AFA_LIFKNMV-KOART EQ 'D'.
    SELECT SINGLE NAME1 INTO /ZAK/AFA_LIFKNMV-NAME1
                        FROM KNA1
                       WHERE KUNNR EQ /ZAK/AFA_LIFKNMV-LIFKUN.
  ELSEIF /ZAK/AFA_LIFKNMV-KOART EQ 'K'.
    SELECT SINGLE NAME1 INTO /ZAK/AFA_LIFKNMV-NAME1
                        FROM LFA1
                       WHERE LIFNR EQ /ZAK/AFA_LIFKNMV-LIFKUN.
  ENDIF.


ENDFORM.                    "change_data
