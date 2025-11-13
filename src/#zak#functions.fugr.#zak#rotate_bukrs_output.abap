FUNCTION /ZAK/ROTATE_BUKRS_OUTPUT.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_AD_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(E_FI_BUKRS) TYPE  BUKRS
*"  EXCEPTIONS
*"      MISSING_INPUT
*"----------------------------------------------------------------------
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    -----------------------------------
*& 0001   2008.01.21   Balázs Gábor  Vállalat forgatás tábla átalakítás
*&                                   átvezetése
*&---------------------------------------------------------------------*

* Kötelező mezők kitöltésének ellenőrzése:
  IF I_AD_BUKRS IS INITIAL.
    RAISE MISSING_INPUT.
  ENDIF.

  IF I_BUKRS[] IS INITIAL.
*   Vezérlő tábla beolvasása
    SELECT * INTO TABLE I_BUKRS
*++0001 BG 2007.01.21
*            FROM /ZAK/BUKRS.
             FROM /ZAK/BUKRSN.  "#EC CI_NOWHERE
*--0001 BG 2007.01.21
  ENDIF.

  E_FI_BUKRS = I_AD_BUKRS.

  CHECK NOT I_BUKRS[] IS INITIAL.

  DO.
    READ TABLE I_BUKRS INTO W_BUKRS WITH KEY AD_BUKRS = E_FI_BUKRS.
    IF SY-SUBRC NE 0.
      EXIT.
    ELSE.
      E_FI_BUKRS = W_BUKRS-FI_BUKRS.
    ENDIF.
  ENDDO.

ENDFUNCTION.
