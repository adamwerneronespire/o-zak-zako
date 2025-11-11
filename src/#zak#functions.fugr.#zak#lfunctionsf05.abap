*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PROC_VBFA_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_VBFA_TAB_ALL  text
*      -->P_LI_GROUP  text
*      -->P_LS_COMWA_VBELN  text
*      -->P_LS_COMWA_POSNR  text
*----------------------------------------------------------------------*
FORM PROC_VBFA_TAB  TABLES   $I_VBFA_TAB STRUCTURE VBFA
                             $I_GROUP    LIKE   I_SZLA_GROUP
                             $R_VBTYP    STRUCTURE RANGE_C1
                             $R_VBTYP_M  STRUCTURE RANGE_C1
                             $R_VBTYP_S  STRUCTURE RANGE_C1
                             $R_VBTYP_F  STRUCTURE RANGE_C1
                    USING    $VBELN
                             $POSNR
                             $SZAMLASZA.
  DATA LS_COMWA    TYPE  VBCO6.
  DATA LI_VBFA_TAB TYPE STANDARD TABLE OF  VBFA.
  DATA LW_VBFA_TAB TYPE VBFA.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA LW_SZLA_GROUP TYPE  T_SZLA_GROUP.
  LOOP AT $I_VBFA_TAB INTO LW_VBFA_TAB WHERE VBELV EQ $VBELN
                                         AND POSNV EQ $POSNR.
*   Ha elértük a főkönyvi könyvelés bizonylatot, akkor kilépés
    IF  LW_VBFA_TAB-VBTYP_N IN $R_VBTYP_F.
      CONTINUE.
    ENDIF.
    IF  LW_VBFA_TAB-VBTYP_N IN $R_VBTYP.
      CLEAR LW_SZLA_GROUP.
*     Közös azonosító váltás ha a típus M-Normál számla
      IF LW_VBFA_TAB-VBTYP_N IN $R_VBTYP_M.
        $SZAMLASZA = LW_VBFA_TAB-VBELN.
        LW_SZLA_GROUP-SZLATIP = C_SZLATIP_E.
      ENDIF.
*     SZAMLASZA TYPE /ZAK/SZAMLASZA,
*     SZAMLASZ  TYPE /ZAK/SZAMLASZ,
*     POSNN     TYPE POSNR_NACH,
*     VBTYP     TYPE VBTYP_N,
*     SZLATIP   TYPE /ZAK/SZLATIP,
*     Feltöltjük a csoport adatokat
      LW_SZLA_GROUP-SZAMLASZA = $SZAMLASZA.
      LW_SZLA_GROUP-SZAMLASZ  = LW_VBFA_TAB-VBELN.
      LW_SZLA_GROUP-POSNN     = LW_VBFA_TAB-POSNN.
      LW_SZLA_GROUP-VBTYP     = LW_VBFA_TAB-VBTYP_N.
      APPEND LW_SZLA_GROUP TO $I_GROUP.
    ENDIF.
*   További tételek feldolgozása
    PERFORM PROC_VBFA_TAB TABLES $I_VBFA_TAB
                                 $I_GROUP
                                 $R_VBTYP
                                 $R_VBTYP_M
                                 $R_VBTYP_S
                                 $R_VBTYP_F
                           USING LW_VBFA_TAB-VBELN
                                 LW_VBFA_TAB-POSNN
                                 $SZAMLASZA.
  ENDLOOP.
ENDFORM.                    " PROC_VBFA_TAB
*&---------------------------------------------------------------------*
*&      Form  GET_SZAMLASZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LI_VBFA_TAB  text
*      -->P_LR_VBTYP  text
*      -->P_LS_COMWA_VBELN  text
*      -->P_LS_COMWA_POSNR  text
*      -->P_E_SZAMLASZE  text
*----------------------------------------------------------------------*
FORM GET_SZAMLASZE  TABLES   $I_VBFA_TAB STRUCTURE VBFA
                             $R_VBTYP    STRUCTURE RANGE_C1
                    USING    $VBELN
                             $POSNR
                             $SZAMLASZE.
  DATA LW_VBFA_TAB TYPE VBFA.
  DATA L_VBELN_POSNN(20).
  DATA L_VBELV_POSNV(20).
  CONCATENATE $VBELN $POSNR INTO L_VBELN_POSNN.
  LOOP AT $I_VBFA_TAB INTO LW_VBFA_TAB
                     WHERE VBELN EQ $VBELN
                       AND POSNN EQ $POSNR.
*  Ahol nem önmaga
    CONCATENATE LW_VBFA_TAB-VBELV
                LW_VBFA_TAB-POSNV INTO L_VBELV_POSNV.
    IF L_VBELV_POSNV EQ L_VBELN_POSNN.
      CONTINUE.
    ENDIF.
*   Ha számla típus
    IF LW_VBFA_TAB-VBTYP_V IN $R_VBTYP.
      $SZAMLASZE = LW_VBFA_TAB-VBELV.
*   Ha nem számla típus tovább keressük
    ELSE.
      PERFORM GET_SZAMLASZE TABLES $I_VBFA_TAB
                                   $R_VBTYP
                            USING  LW_VBFA_TAB-VBELV
                                   LW_VBFA_TAB-POSNV
                                   $SZAMLASZE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_SZAMLASZE
*&---------------------------------------------------------------------*
*&      Form  GET_PREV_BELNR_XBLNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_BKPF  text
*      -->P_E_SZAMLASZE  text
*      -->P_E_SZAMLASZA  text
*      -->P_E_SZLATIP  text
*----------------------------------------------------------------------*
*++1765 #31.
*FORM GET_PREV_BELNR_XBLNR  USING    $BKPF STRUCTURE BKPF
FORM GET_PREV_BELNR_XBLNR  TABLES   $T_RETURN STRUCTURE BAPIRET2
                           USING    $BKPF STRUCTURE BKPF
*--1765 #31.
                                    $SZAMLASZE
                                    $SZAMLASZA
                                    $SZLATIP
*++1665 #06.
                                    $NONEED.
*--1665 #06.
*++2065 #04.
  ADD 1 TO V_INF_COUNT.
  IF V_INF_COUNT > C_INF_COUNT.
    MESSAGE E370(/ZAK/ZAK) WITH $BKPF-BUKRS $BKPF-GJAHR $BKPF-BELNR.
*   Egymásra mutató referenciák (biz: &/&/&)! Futás megs/zak/zakítva!
  ENDIF.
*--2065 #04.

*************** FI_DEFAULT: ******************
*  DATA LS_BKPF TYPE BKPF.
*  DATA L_ZUONR TYPE DZUONR.
*
** Meghatározzuk a szállító láb hozzárendelési számát
*  CLEAR L_ZUONR.
*  SELECT SINGLE ZUONR INTO L_ZUONR
*                  FROM BSEG
*                 WHERE BUKRS EQ $BKPF-BUKRS
*                   AND GJAHR EQ $BKPF-GJAHR
*                   AND BELNR EQ $BKPF-BELNR
*                   AND LIFNR NE ''.
*
** Ha megegyezik, akkor nem kell tovább keresni
**  IF SY-SUBRC EQ 0 AND L_ZUONR EQ $BKPF-XBLNR .
**++1465 #16.
**  IF SY-SUBRC EQ 0 AND ( L_ZUONR EQ $BKPF-XBLNR
*  IF SY-SUBRC EQ 0 AND ( L_ZUONR(16) EQ $BKPF-XBLNR
**--1465 #16.
*                      OR L_ZUONR IS INITIAL ).
**    $SZAMLASZA = L_ZUONR.
*    $SZAMLASZA = $BKPF-XBLNR.
*    EXIT.
*  ELSEIF SY-SUBRC EQ 0.
*    SELECT SINGLE * INTO LS_BKPF
*                    FROM BKPF
*                   WHERE BUKRS EQ $BKPF-BUKRS
*                     AND XBLNR EQ L_ZUONR.
*    IF SY-SUBRC EQ 0.
*      IF $SZAMLASZE IS INITIAL.
*        $SZAMLASZE = LS_BKPF-XBLNR.
*      ENDIF.
**     Előző bizonylatok keresése
**++1765 #31.
**  PERFORM GET_PREV_BELNR_XBLNR USING LS_BKPF
*  PERFORM GET_PREV_BELNR_XBLNR TABLES $T_RETURN
*                               USING LS_BKPF
**--1765 #31.
*                                         $SZAMLASZE
*                                         $SZAMLASZA
*                                         $SZLATIP
**++1665 #06.
*                                         $NONEED.
**--1665 #06.
*    ELSE.
*      $SZAMLASZA = L_ZUONR.
*    ENDIF.
*  ENDIF.

ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_DEFAULT SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_MOL_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_ONGROPACK_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_INVITEL_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_OTP_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_ZFS_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_ZF_03 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_FGSZ_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_RG_02 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_AUDI_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_BCRT_01 SPOTS /ZAK/FUNCTIONS_ES .
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_MPK_01 SPOTS /ZAK/FUNCTIONS_ES .
*++2465 #05.
ENHANCEMENT-POINT /ZAK/ZAK_GET_FI_MATE_02 SPOTS /ZAK/FUNCTIONS_ES .
*--2465 #05.
ENDFORM.                    " GET_PREV_BELNR_XBLNR
*&---------------------------------------------------------------------*
*&      Form  GET_RE_SZAMLASZA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_BKPF  text
*      -->P_E_SZAMLASZA  text
*----------------------------------------------------------------------*
FORM GET_RE_SZAMLASZA  USING    $BKPF STRUCTURE BKPF
                                $SZAMLASZA.
  DATA LS_BKPF TYPE BKPF.
  SELECT SINGLE * INTO LS_BKPF
                  FROM BKPF
                 WHERE BUKRS EQ $BKPF-BUKRS
                   AND BLART EQ $BKPF-BLART
                   AND XBLNR EQ $BKPF-XREF1_HD.
  IF SY-SUBRC EQ 0 AND LS_BKPF-XREF1_HD IS INITIAL.
    $SZAMLASZA = LS_BKPF-XBLNR.
  ELSE.
    PERFORM GET_RE_SZAMLASZA USING LS_BKPF
                                   $SZAMLASZA.
  ENDIF.
ENDFORM.                    " GET_RE_SZAMLASZA
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_FGSZ_02 SPOTS /ZAK/FUNCTIONS_ES STATIC .
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_RG_02 SPOTS /ZAK/FUNCTIONS_ES STATIC .

*++1765 #27.
*&---------------------------------------------------------------------*
*&      Form  GET_PREV_RBKP_XBLNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_SZAMLA  text
*      -->P_LS_AWKDEC_BELNR  text
*      -->P_LS_AWKDEC_GJAHR  text
*----------------------------------------------------------------------*
FORM GET_PREV_RBKP_XBLNR    USING  $BELNR
                                   $GJAHR
                                   $SZAMLASZ
                                   $SZAMLASZE
                                   $SZAMLASZA
                                   $SZLATIP.


  DATA LS_RBKP TYPE RBKP.
*++2465 #05.
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_MATE_01 SPOTS /ZAK/FUNCTIONS_ES .
*--2465 #05.
  SELECT SINGLE * INTO LS_RBKP
                  FROM RBKP
                 WHERE BELNR EQ $BELNR
                   AND GJAHR EQ $GJAHR.
  IF SY-SUBRC EQ 0.
    IF $SZLATIP EQ C_SZLATIP_K AND $SZAMLASZE IS INITIAL.
      $SZAMLASZE = LS_RBKP-XBLNR.
*++2465 #05.
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_MATE_02 SPOTS /ZAK/FUNCTIONS_ES .
*--2465 #05.
    ENDIF.
    IF $SZAMLASZ IS INITIAL.
      $SZAMLASZ  = LS_RBKP-XBLNR.
*++2465 #05.
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_MATE_03 SPOTS /ZAK/FUNCTIONS_ES .
*--2465 #05.
    ENDIF.
    IF LS_RBKP-REBZG IS INITIAL.
      $SZAMLASZA = LS_RBKP-XBLNR.
*++2465 #05.
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_MATE_04 SPOTS /ZAK/FUNCTIONS_ES .
*--2465 #05.
      EXIT.
    ELSE.
      IF $SZLATIP IS INITIAL.
        $SZLATIP = C_SZLATIP_K.
      ENDIF.
      PERFORM GET_PREV_RBKP_XBLNR  USING    LS_RBKP-REBZG
                                            LS_RBKP-REBZJ
                                            $SZAMLASZ
                                            $SZAMLASZE
                                            $SZAMLASZA
                                            $SZLATIP.
    ENDIF.
  ENDIF.
ENDFORM.                    "GET_PREV_RBKP_XBLNR
*--1765 #27.
*++2065 #16.
ENHANCEMENT-POINT /ZAK/ZAK_GET_MM_INVITEL_02 SPOTS /ZAK/FUNCTIONS_ES STATIC .
*--2065 #16.
