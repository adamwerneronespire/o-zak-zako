*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_ARANY_MVF01 .
*----------------------------------------------------------------------*
FORM CHANGE_ARANY.

  IF NOT /ZAK/AFA_ARANY_V-LWBAS_SUM IS INITIAL.
    /ZAK/AFA_ARANY_V-ARANY = ( /ZAK/AFA_ARANY_V-LWBAS_NMT / /ZAK/AFA_ARANY_V-LWBAS_SUM ) * 100.
  ENDIF.

  GET TIME.
  /ZAK/AFA_ARANY_V-AS4USER = SY-UNAME.
  /ZAK/AFA_ARANY_V-AS4DATE = SY-DATUM.
  /ZAK/AFA_ARANY_V-AS4TIME = SY-UZEIT.

ENDFORM.                    "CHANGE_ARANY
