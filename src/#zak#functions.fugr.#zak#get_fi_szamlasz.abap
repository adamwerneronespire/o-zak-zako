FUNCTION /ZAK/GET_FI_SZAMLASZ.
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
*"     VALUE(E_NONEED) TYPE  XFELD
*"  TABLES
*"      T_RETURN STRUCTURE  BAPIRET2 OPTIONAL
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
  DATA L_ZUONR   TYPE DZUONR.
*++1465 #03.
* Sztornó adatok
  DATA L_STBLG TYPE RE_STBLG.
  DATA L_STJAH TYPE RE_STJAH.
  DATA L_SZAMLASZA TYPE  /ZAK/SZAMLASZA.
  DATA L_SZAMLASZ TYPE  /ZAK/SZAMLASZ.
  DATA L_SZAMLASZE TYPE  /ZAK/SZAMLASZE.
  DATA L_SZLATIP TYPE  /ZAK/SZLATIP.
  DATA L_STORNO TYPE  XFELD.
  DATA LS_BKPF_SAVE TYPE BKPF.
*--1465 #03.
*++1665 #06.
  DATA L_NONEED TYPE XFELD.
*--1665 #06.
*++1765 #05.
  DATA LT_RETURN TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0.
*--1765 #05.
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
*++1865 #07.
*    LS_AWKDEC = I_AWKEY.
*    SELECT SINGLE * INTO LS_BKPF
*                        FROM BKPF
*                       WHERE BUKRS EQ LS_AWKDEC-BUKRS
*                         AND BELNR EQ LS_AWKDEC-BELNR
*                         AND GJAHR EQ LS_AWKDEC-GJAHR.
*  Előrögzített bizonylatnál előfordulhat, hogy ua. az AWKEY
*  több bizonylatnál, de nekünk a normál bizonylatot kell meghatározni
    SELECT SINGLE * INTO LS_BKPF
                        FROM BKPF
                       WHERE AWKEY EQ I_AWKEY
                         AND BSTAT EQ ''.
*--1865 #07.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_BC_01 SPOTS /ZAK/FUNCTIONS_ES .

ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_MOL_02 SPOTS /ZAK/FUNCTIONS_ES .
  ENDIF.

  IF SY-SUBRC NE 0.
*++1665 #08.
*++1365 #9.
**    MESSAGE E354(/ZAK/ZAK) RAISING ERROR_AWKEY.
*    MESSAGE E354(/ZAK/ZAK) WITH I_AWKEY RAISING ERROR_AWKEY.
**--1365 #9.
*   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY)
    PERFORM ADD_MESSAGE TABLES T_RETURN
                        USING  '/ZAK/ZAK'
                               'E'
                               '354'
                               I_AWKEY
                               ''
                               ''
                               ''.
*--1665 #08.
  ENDIF.

*++1465 #03.
* Elmentjük az adatokat a sztornó kezeléshez
  LS_BKPF_SAVE = LS_BKPF.
*--1465 #03.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_ZF_01 SPOTS /ZAK/FUNCTIONS_ES .

*++1565 #07.
  IF LS_BKPF-XBLNR IS INITIAL.
*++1665 #08.
*    MESSAGE I359(/ZAK/ZAK) WITH LS_BKPF-BUKRS LS_BKPF-BELNR LS_BKPF-GJAHR RAISING ERROR_OTHER.
*   Üres referencia, számlaszámot nem lehet meghatározni! (&/&/&)
    PERFORM ADD_MESSAGE TABLES T_RETURN
                        USING  '/ZAK/ZAK'
                               'I'
                               '359'
                               LS_BKPF-BUKRS
                               LS_BKPF-BELNR
                               ''
                               ''.
*--1665 #08.
  ELSE.
*--1565 #07.
    E_SZAMLASZ = LS_BKPF-XBLNR.
*++1565 #07.
*++2465 #05.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_MATE_01 SPOTS /ZAK/FUNCTIONS_ES .
*--2465 #05.
  ENDIF.
*--1565 #07.
*++2365 #04.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_BC_02 SPOTS /ZAK/FUNCTIONS_ES .
*--2365 #04.
*++2065 #15.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_FGSZ_02 SPOTS /ZAK/FUNCTIONS_ES .
*--2065 #15.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_ZF_02 SPOTS /ZAK/FUNCTIONS_ES .

ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_RG_01 SPOTS /ZAK/FUNCTIONS_ES .
*++2065 #17.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_INVITEL_02 SPOTS /ZAK/FUNCTIONS_ES .
*--2065 #17.
*++2165 #01.
**++2065 #04.
*  CLEAR V_INF_COUNT.
**--2065 #04.
*--2165 #01.
*     Előző bizonylatok keresése Cargo XBLNR
*++1765 #31.
*++2265 #07.
  CLEAR V_INF_COUNT.
*--2265 #07.
*  PERFORM GET_PREV_BELNR_XBLNR USING LS_BKPF
  PERFORM GET_PREV_BELNR_XBLNR TABLES T_RETURN
                               USING LS_BKPF
*--1765 #31.
                                     E_SZAMLASZE
                                     E_SZAMLASZA
                                     E_SZLATIP
*++1665 #06.
                                     E_NONEED.
*--1665 #06.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_ZF_04 SPOTS /ZAK/FUNCTIONS_ES .

* Ha üres akkor önmaga lesz az eredeti
  IF E_SZAMLASZA IS INITIAL.
    E_SZAMLASZA = E_SZAMLASZ.
  ENDIF.
  IF E_SZAMLASZE IS INITIAL AND E_SZLATIP IS INITIAL
    AND NOT E_SZAMLASZ IS INITIAL.
    E_SZLATIP = C_SZLATIP_E.
  ENDIF.
*++1465 #03.
* Sztornó meghatározása
  IF NOT LS_BKPF-STBLG IS INITIAL AND NOT LS_BKPF-STJAH IS INITIAL
     AND LS_BKPF-XREVERSAL EQ '2'.
    CLEAR: L_SZAMLASZA, L_SZAMLASZ, L_SZAMLASZE, L_STORNO, L_SZLATIP.
    CALL FUNCTION '/ZAK/GET_FI_SZAMLASZ'
      EXPORTING
        I_BUKRS     = LS_BKPF_SAVE-BUKRS
        I_BELNR     = LS_BKPF_SAVE-STBLG
        I_GJAHR     = LS_BKPF_SAVE-STJAH
*       I_AWKEY     =
      IMPORTING
        E_SZAMLASZA = L_SZAMLASZA
        E_SZAMLASZ  = L_SZAMLASZ
        E_SZAMLASZE = L_SZAMLASZE
        E_SZLATIP   = L_SZLATIP
        E_STORNO    = L_STORNO
*++1665 #06.
        E_NONEED    = L_NONEED
*--1665 #06.
*++1765 #05.
      TABLES
        T_RETURN    = LT_RETURN
      EXCEPTIONS
        ERROR_AWKEY = 1
        ERROR_OTHER = 2
        OTHERS      = 3.

    IF NOT T_RETURN[] IS INITIAL.
      APPEND LINES OF LT_RETURN TO T_RETURN.
    ENDIF.
*--1765 #05.
    E_STORNO = 'X'.
    E_SZAMLASZE = L_SZAMLASZ.
    E_SZAMLASZA = L_SZAMLASZA.
    E_SZLATIP   = C_SZLATIP_K.
*++1665 #06.
    E_NONEED    = L_NONEED.
*--1665 #06.
  ENDIF.
*--1465 #03.
ENDFUNCTION.
