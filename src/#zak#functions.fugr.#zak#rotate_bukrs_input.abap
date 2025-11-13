FUNCTION /ZAK/ROTATE_BUKRS_INPUT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_FI_BUKRS) TYPE  BUKRS
*"     VALUE(I_AD_BUKRS) TYPE  BUKRS OPTIONAL
*"     VALUE(I_DATE) TYPE  AGR_FDATE
*"  EXPORTING
*"     VALUE(E_AD_BUKRS) TYPE  BUKRS
*"  EXCEPTIONS
*"      MISSING_INPUT
*"----------------------------------------------------------------------
*& MODIFICATIONS (the OSS note number must be written at the end of the modified lines)
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    -----------------------------------
*& 0001   2008.01.21   Balázs Gábor  Migration of the company rotation table transformation
*&---------------------------------------------------------------------*

* Checks

*++0001 BG 2007.01.21
  IF I_FI_BUKRS IS INITIAL OR I_DATE IS INITIAL.
    RAISE MISSING_INPUT.
  ENDIF.
*--0001 BG 2007.01.21

* Check whether the company already appears.
  READ TABLE I_BUKRS TRANSPORTING NO FIELDS
             WITH KEY FI_BUKRS = I_FI_BUKRS.
  IF SY-SUBRC NE 0.
*++S4HANA#01.
*    REFRESH I_BUKRS.
    CLEAR I_BUKRS[].
*--S4HANA#01.
*++0001 BG 2007.01.21
*   Reading control table
    SELECT * INTO TABLE I_BUKRS                         "#EC CI_NOFIELD
*++0001 BG 2007.01.21
*            FROM /ZAK/BUKRS
             FROM /ZAK/BUKRSN
*--0001 BG 2007.01.21
            WHERE FI_BUKRS EQ I_FI_BUKRS
*++S4HANA#01.
      ORDER BY PRIMARY KEY.
*--S4HANA#01.
*--0001 BG 2007.01.21
  ENDIF.

* E_AD_BUKRS = I_FI_BUKRS.
* CHECK NOT I_BUKRS[] IS INITIAL.

* Check whether an appropriate rotation-table entry exists
  LOOP AT I_BUKRS INTO W_BUKRS WHERE FI_BUKRS EQ I_FI_BUKRS
*++0001 BG 2007.01.21
*                                AND GSBER    EQ I_GSBER
*                                AND PRCTR    EQ I_PRCTR
                                 AND AD_BUKRS EQ I_AD_BUKRS
*--0001 BG 2007.01.21
                                 AND FDATE    >  I_DATE.
    MOVE W_BUKRS-AD_BUKRS TO E_AD_BUKRS.
    EXIT.
  ENDLOOP.
*++0001 BG 2007.01.21
  IF SY-SUBRC NE 0.
    MOVE I_FI_BUKRS TO E_AD_BUKRS.
*    LOOP AT I_BUKRS INTO W_BUKRS WHERE FI_BUKRS EQ I_FI_BUKRS
*                               AND GSBER    EQ I_GSBER
*                               AND PRCTR    IS INITIAL
*                               AND FDATE    >  I_DATE.
*      MOVE W_BUKRS-AD_BUKRS TO E_AD_BUKRS.
*      EXIT.
*    ENDLOOP.
  ENDIF.
*--0001 BG 2007.01.21
ENDFUNCTION.
