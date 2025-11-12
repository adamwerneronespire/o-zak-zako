FUNCTION /ZAK/GET_RE_SZAMLASZ.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS OPTIONAL
*"     VALUE(I_BELNR) TYPE  BELNR_D OPTIONAL
*"     VALUE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"     VALUE(I_AWKEY) TYPE  AWKEY OPTIONAL
*"  EXPORTING
*"     VALUE(E_SZAMLASZA) TYPE  /ZAK/SZAMLASZA
*"     VALUE(E_SZAMLASZ) TYPE  /ZAK/SZAMLASZ
*"     VALUE(E_SZAMLASZE) TYPE  /ZAK/SZAMLASZE
*"     VALUE(E_SZLATIP) TYPE  /ZAK/SZLATIP
*"     VALUE(E_STORNO) TYPE  XFELD
*"  EXCEPTIONS
*"      ERROR_AWKEY
*"      ERROR_OTHER
*"----------------------------------------------------------------------
* FI AWKEY
  TYPES: BEGIN OF LT_AWKEY_DECODE,
         BELNR TYPE RE_BELNR,
         BUKRS TYPE BUKRS,
         GJAHR TYPE GJAHR,
         END OF LT_AWKEY_DECODE.

  DATA LS_AWKDEC TYPE LT_AWKEY_DECODE.
  DATA LS_BKPF   TYPE BKPF.

  DEFINE M_CONV_ALPHA_INPUT.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = &1
      IMPORTING
        OUTPUT = &1.
  END-OF-DEFINITION.

* Meghatározzuk az eredeti bizonylatot
  IF I_AWKEY IS INITIAL.
    M_CONV_ALPHA_INPUT I_BELNR.
    SELECT SINGLE * INTO LS_BKPF
                        FROM BKPF
                       WHERE BUKRS EQ I_BUKRS
                         AND BELNR EQ I_BELNR
                         AND GJAHR EQ I_GJAHR.
  ELSE.
    SELECT SINGLE * INTO LS_BKPF
                        FROM BKPF
                       WHERE AWKEY EQ I_AWKEY.
  ENDIF.

  IF SY-SUBRC NE 0.
    MESSAGE E354(YAK) RAISING ERROR_AWKEY.
*   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY)
  ENDIF.

  E_SZAMLASZ = LS_BKPF-XBLNR.
* Normál bizonylat
*++1365 2013.11.14 BG (a mező ha csak 0-át tartalmaz, akkor is üresnek tekintjük)
*  IF LS_BKPF-XREF1_HD IS INITIAL AND  LS_BKPF-STBLG IS INITIAL.
  IF ( LS_BKPF-XREF1_HD IS INITIAL OR LS_BKPF-XREF1_HD CO '0 ' )
     AND  LS_BKPF-STBLG IS INITIAL.
*--1365 2013.11.14
    E_SZAMLASZA = LS_BKPF-XBLNR.
    E_SZLATIP   = C_SZLATIP_E.
  ELSE.
* Sztornó vagy sztornózott bizonylat
    IF NOT LS_BKPF-STBLG IS INITIAL.
      E_STORNO = 'X'.
      IF LS_BKPF-XREVERSAL = '1'.
        E_SZAMLASZA = LS_BKPF-XBLNR.
        E_SZLATIP   = C_SZLATIP_E.
*   Sztornózó bizonylat
      ELSEIF LS_BKPF-XREVERSAL = '2'.
        E_SZAMLASZA = LS_BKPF-XREF1_HD.
        E_SZAMLASZE = LS_BKPF-XREF1_HD.
        E_SZLATIP   = C_SZLATIP_K.
      ENDIF.
*  Helyesbített bizonylat
    ELSE.
      E_SZAMLASZE = LS_BKPF-XREF1_HD.
      E_SZLATIP   = C_SZLATIP_K.
*     Eredeti számlaszám meghatározása
      PERFORM GET_RE_SZAMLASZA USING LS_BKPF
                                     E_SZAMLASZA.
    ENDIF.
  ENDIF.

ENDFUNCTION.
