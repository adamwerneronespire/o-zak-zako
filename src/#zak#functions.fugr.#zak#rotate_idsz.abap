FUNCTION /ZAK/ROTATE_IDSZ.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_MONAT) TYPE  MONAT
*"     VALUE(I_GSBER) TYPE  GSBER
*"     VALUE(I_KTOSL) TYPE  KTOSL
*"     VALUE(I_PRCTR) TYPE  PRCTR OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_GJAHR) TYPE  GJAHR
*"     REFERENCE(E_MONAT) TYPE  MONAT
*"  EXCEPTIONS
*"      MISSING_INPUT
*"----------------------------------------------------------------------
  DATA L_IDSZ_INPUT(6).
  DATA L_IDSZ_FORG(6).

  DATA  L_AFABK TYPE /ZAK/AFABK.
  DATA  L_STGRP TYPE STGRP_007B.

  RANGES LR_EU_KTOSL FOR T007B-KTOSL.


  DEFINE M_GET_FORG.
    IF &1 IS INITIAL.
      CHECK NOT I_KTOSL IN LR_EU_KTOSL.
    ENDIF.

    CONCATENATE W_IDSZ-GJAHR W_IDSZ-MONAT INTO L_IDSZ_FORG.
    IF L_IDSZ_INPUT < L_IDSZ_FORG.
      E_GJAHR = W_IDSZ-GJAHR.
      E_MONAT = W_IDSZ-MONAT.
    ENDIF.
    EXIT.
  END-OF-DEFINITION.


  DEFINE M_GET_AFABK.
    CLEAR &2.
    SELECT SINGLE STGRP INTO L_STGRP
                        FROM T007B
                       WHERE KTOSL EQ &1.
    IF SY-SUBRC EQ 0.
      CASE L_STGRP.
        WHEN '1'.
          MOVE 'K' TO &2.
        WHEN '2'.
          MOVE 'B' TO &2.
      ENDCASE.
    ENDIF.
  END-OF-DEFINITION.

* Populate EU transaction keys
  M_DEF LR_EU_KTOSL 'I' 'EQ' 'ESE' SPACE.
  M_DEF LR_EU_KTOSL 'I' 'EQ' 'ESA' SPACE.

* Check filling of mandatory fields:
  IF I_BUKRS IS INITIAL OR I_GJAHR IS INITIAL OR I_MONAT IS INITIAL
  OR I_GSBER IS INITIAL OR I_KTOSL IS INITIAL.
    RAISE MISSING_INPUT.
  ENDIF.

* Determine VAT direction
  M_GET_AFABK I_KTOSL L_AFABK.

* Check whether the company is already included.
  READ TABLE I_IDSZ TRANSPORTING NO FIELDS
               WITH KEY BUKRS = I_BUKRS.
  IF SY-SUBRC NE 0.
    REFRESH I_IDSZ.
*   Read control table
    SELECT * INTO TABLE I_IDSZ
             FROM /ZAK/GET_IDSZ
            WHERE BUKRS EQ I_BUKRS.
  ENDIF.

  E_GJAHR = I_GJAHR.
  E_MONAT = I_MONAT.

  CONCATENATE I_GJAHR I_MONAT INTO L_IDSZ_INPUT.

  CHECK NOT I_IDSZ[] IS INITIAL.

* Check that an appropriate rotation table entry exists
  LOOP AT I_IDSZ INTO W_IDSZ WHERE   BUKRS EQ I_BUKRS
                                 AND GSBER EQ I_GSBER
                                 AND PRCTR EQ I_PRCTR
                                 AND AFABK EQ L_AFABK.

    M_GET_FORG W_IDSZ-EUFLG.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    LOOP AT I_IDSZ INTO W_IDSZ WHERE BUKRS EQ I_BUKRS
                                 AND GSBER EQ I_GSBER
                                 AND PRCTR IS INITIAL
                                 AND AFABK EQ L_AFABK.
      M_GET_FORG W_IDSZ-EUFLG.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
