*&---------------------------------------------------------------------*
*& Program: a bevallás áttöltéséhez ellenőrző és végrehajtó program
*&---------------------------------------------------------------------*
REPORT  /ZAK/ZAK_GET_ZF_DATA MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& megjeleníti (ill. éles esetén módosítja) távoli RFC hívás segítségével
*& az átvehető bevallásokat ill. kiírja ami már átvételre került.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - Ness
*& Létrehozás dátuma : 2017.01.25
*& Funkc.spec.készítő: ________
*& SAP modul neve    :
*& Program  típus    : Riport
*& SAP verzió        :
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS
*& ----   ----------   ----------    ----------------------- -----------
*&---------------------------------------------------------------------*

INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/MAIN_TOP.
INCLUDE /ZAK/SAP_SEL_F01.

*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*  PROGRAM VÁLTOZÓK                                                    *
*      Belső tábla         -   (I_xxx...)                              *
*      FORM paraméter      -   ($xxxx...)                              *
*      Konstans            -   (C_xxx...)                              *
*      Paraméter változó   -   (P_xxx...)                              *
*      Szelekciós opció    -   (S_xxx...)                              *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Globális változók   -   (V_xxx...)                              *
*      Lokális változók    -   (L_xxx...)                              *
*      Munkaterület        -   (W_xxx...)                              *
*      Típus               -   (T_xxx...)                              *
*      Makrók              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Osztály             -   (CL_xxx...)                             *
*      Esemény             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*

DATA:
  I_ANALITIKA  TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
  I_AFA_SZLA   TYPE STANDARD TABLE OF /ZAK/AFA_SZLA INITIAL SIZE 0,
  I_E_RETURN   TYPE STANDARD TABLE OF BAPIRET2 INITIAL SIZE 0,

  I_/ZAK/OPACK  TYPE STANDARD TABLE OF /ZAK/OPACK INITIAL SIZE 0,
  WA_/ZAK/OPACK LIKE LINE OF I_/ZAK/OPACK.

DATA:
  V_OPACK_EXECUTED TYPE XFELD VALUE '',
  V_BUKRS          TYPE /ZAK/BEVALLP-BUKRS,
  V_RFCDEST        TYPE RFCDEST,
  V_OPACK          TYPE /ZAK/OPACK,
  V_GRID           TYPE REF TO CL_SALV_TABLE.

DATA:
  V_REPID LIKE SY-REPID,
  V_SUBRC LIKE SY-SUBRC,
  O_XROOT TYPE REF TO CX_ROOT.

*++1665 #01.
TYPES: BEGIN OF T_CHECK_BSZNUM,
         BUKRS TYPE BUKRS,
         BTYPE TYPE /ZAK/BTYPE,
       END OF T_CHECK_BSZNUM.

DATA I_CHECK_BSZNUM TYPE STANDARD TABLE OF T_CHECK_BSZNUM INITIAL SIZE 0.
*--1665 #01.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Vállalat másik rendszer.
PARAMETERS: P_BUKRS  TYPE CHAR4  OBLIGATORY DEFAULT '2330'.
* Vállalat saját rendszer
PARAMETERS: P_BUKRST LIKE /ZAK/BEVALLP-BUKRS VALUE CHECK OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK BL01.

SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
* Feltöltés azonosító
SELECT-OPTIONS S_PACK FOR /ZAK/BEVALLP-PACK NO-EXTENSION.
* Adatszolgáltatási azonosító
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM OBLIGATORY
                                       DEFAULT '050'.
* Bevallás fajta
PARAMETERS: P_BTYPAR LIKE /ZAK/BEVALL-BTYPART OBLIGATORY
                                       DEFAULT C_BTYPART_AFA.
* Teszt (v. éles)
PARAMETERS: P_TESZT AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL02.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.
* RFC cél meghatározása az aktuális rendszer függvényében
  PERFORM SET_RFC_DESTINATION.
*++1765 #19.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   Önnek nincs jogosultsága a program futtatásához!
  ENDIF.
*--1765 #19.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PACK-LOW.
  PERFORM SUB_F4_PACK
            USING S_PACK-LOW.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_PACK-HIGH.
  PERFORM SUB_F4_PACK
           USING S_PACK-HIGH.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  Szolgáltatás azonosító ellenőrzése
  PERFORM VER_BSZNUM   USING P_BUKRST
                             P_BTYPAR
                             P_BSZNUM
                             V_REPID
                    CHANGING V_SUBRC.

*  AFA bevallás típus ellenőrzése
  PERFORM VER_BTYPEART USING P_BUKRST
                             P_BTYPAR
                             C_BTYPART_AFA
                    CHANGING V_SUBRC.

  IF NOT V_SUBRC IS INITIAL.
    MESSAGE E030.
*    Kérem ÁFA típusú bevallás azonosítót adjon meg!
  ENDIF.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM EXECUTE_ANAL.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* Háttérben nem készítünk listát
*  IF SY-BATCH IS INITIAL.
  PERFORM LIST_DISPLAY.
*  ENDIF.


************************************************************************
* ALPROGRAMOK
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  set_rfc_destination
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_RFC_DESTINATION.
  CLEAR V_RFCDEST.
ENHANCEMENT-POINT /ZAK/ZAK_GET_ZF_DATA_01 SPOTS /ZAK/GET_DATA_01 .


ENDFORM.    " set_rfc_destination

*&---------------------------------------------------------------------*
*&      Form  list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  TRY.
      CALL METHOD CL_SALV_TABLE=>FACTORY
        IMPORTING
          R_SALV_TABLE = V_GRID
        CHANGING
          T_TABLE      = I_ANALITIKA.
    CATCH CX_SALV_MSG.
  ENDTRY.

  V_GRID->DISPLAY( ).
ENDFORM.  " list_display


*&---------------------------------------------------------------------*
*&      Form  SUB_F4_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUB_F4_PACK
          USING $S_PACK TYPE /ZAK/BEVALLP-PACK.

  DATA:
    LT_RETURN      TYPE TABLE OF DDSHRETVAL,
    LWA_RETURN     TYPE DDSHRETVAL,
    LWA_DYNPFIELDS TYPE DYNPREAD,
    LT_DYNPFIELDS  TYPE TABLE OF DYNPREAD.

  REFRESH LT_DYNPFIELDS.
* A P_BUKRS paraméter mezőben lévő tartalom beolvasása
  LWA_DYNPFIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND LWA_DYNPFIELDS TO LT_DYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_DYNPFIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  READ TABLE LT_DYNPFIELDS INTO LWA_DYNPFIELDS
         WITH KEY FIELDNAME = 'P_BUKRS'.
  IF SY-SUBRC = 0.
    V_BUKRS = LWA_DYNPFIELDS-FIELDVALUE.
  ENDIF.

* Az összes vállalathoz tartozó feltöltési azonosító lekérése
  PERFORM EXECUTE_OPEN_PACK
                 TABLES I_/ZAK/OPACK
                  USING V_BUKRS.

* A keresési segítség megjelenítése
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'PACK'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = I_/ZAK/OPACK
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN INTO LWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    WRITE LWA_RETURN-FIELDVAL TO $S_PACK.
  ENDIF.
ENDFORM.                    "SUB_F4_PACK

*&---------------------------------------------------------------------*
*&      Form  EXECUTE_ANAl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EXECUTE_ANAL.

  DATA:
    LI_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
    LW_ANALITIKA TYPE /ZAK/ANALITIKA,
    LI_AFA_SZLA  TYPE STANDARD TABLE OF /ZAK/AFA_SZLA  INITIAL SIZE 0,
    LW_AFA_SZLA  TYPE /ZAK/AFA_SZLA,
    LI_E_RETURN  TYPE STANDARD TABLE OF BAPIRET2      INITIAL SIZE 0.
  DATA   L_SUBRC TYPE SYSUBRC.

  DATA:
    L_INTERNAL_AMOUNT TYPE WRBTR,
    L_EXTERNAL_AMOUNT TYPE BAPICURR-BAPICURR.

  DEFINE LM_CURRENCY_INTERNAL.
    L_EXTERNAL_AMOUNT = &1.
*   Összeg konverzió belső HUF formátumra
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        CURRENCY             = &2
        AMOUNT_EXTERNAL      = L_EXTERNAL_AMOUNT
        MAX_NUMBER_OF_DIGITS = 13
      IMPORTING
        AMOUNT_INTERNAL      = L_INTERNAL_AMOUNT.
    &1 = L_INTERNAL_AMOUNT.
  END-OF-DEFINITION.


* Válallat pénznem meghatározása

*  Vállalati adatok beolvasása
  PERFORM GET_T001(/ZAK/AFA_SAP_SELN) USING
                         P_BUKRST
                         L_SUBRC.
  IF NOT L_SUBRC IS INITIAL.
    MESSAGE A036 WITH V_BUKRS.
  ENDIF.

* Az összes vállalathoz tartozó feltöltési azonosító lekérése
  PERFORM EXECUTE_OPEN_PACK
                 TABLES I_/ZAK/OPACK
                  USING P_BUKRS.


* Az adott nem áttöltött feltöltési azonosító(k)hoz tartozó analitika begyűjtése
  LOOP AT I_/ZAK/OPACK INTO WA_/ZAK/OPACK WHERE PACK IN S_PACK.
    REFRESH: LI_ANALITIKA,
             LI_AFA_SZLA,
             LI_E_RETURN.

    CALL FUNCTION '/ZAK/GET_ANAL'
      DESTINATION V_RFCDEST
      EXPORTING
        I_BUKRS     = WA_/ZAK/OPACK-BUKRS
        I_PACK      = WA_/ZAK/OPACK-PACK
        I_TEST      = 'X'
      TABLES
        T_ANALITIKA = LI_ANALITIKA
        T_AFA_SZLA  = LI_AFA_SZLA.

*++2014.12.17 BG
*++1665 #01.
*    LOOP AT LI_ANALITIKA INTO LW_ANALITIKA WHERE BSZNUM NE P_BSZNUM.
    LOOP AT LI_ANALITIKA INTO LW_ANALITIKA.
*     Vállalat átforgatás
      LW_ANALITIKA-FI_BUKRS = LW_ANALITIKA-BUKRS.
      LW_ANALITIKA-BUKRS    = P_BUKRST.
      MODIFY LI_ANALITIKA FROM LW_ANALITIKA TRANSPORTING BUKRS FI_BUKRS.
*     Pénznem kezelés
      LM_CURRENCY_INTERNAL LW_ANALITIKA-DMBTR T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-LWBAS T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-LWSTE T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-HWBTR T001-WAERS.
      LM_CURRENCY_INTERNAL LW_ANALITIKA-FIELD_N T001-WAERS.
      MODIFY LI_ANALITIKA FROM LW_ANALITIKA TRANSPORTING DMBTR LWBAS LWSTE HWBTR FIELD_N.
      PERFORM CHECK_BSZNUM_BTYPE TABLES I_CHECK_BSZNUM
                                 USING  LW_ANALITIKA-BUKRS
                                        LW_ANALITIKA-BTYPE
                                        P_BSZNUM.
      IF LW_ANALITIKA-BSZNUM NE P_BSZNUM.
*--1665 #01.
        LW_ANALITIKA-BSZNUM = P_BSZNUM.
        MODIFY LI_ANALITIKA FROM LW_ANALITIKA TRANSPORTING BSZNUM.
*++1665 #01.
      ENDIF.
*--1665 #01.
    ENDLOOP.
*   Vállalat forgatás AFA_SZLA
    LOOP AT LI_AFA_SZLA INTO LW_AFA_SZLA.
      LW_AFA_SZLA-BUKRS = P_BUKRST.
      MODIFY LI_AFA_SZLA FROM LW_AFA_SZLA TRANSPORTING BUKRS.
      IF LW_AFA_SZLA-WAERS EQ 'HUF'.
        MULTIPLY LW_AFA_SZLA-LWBAS BY 100.
        MULTIPLY LW_AFA_SZLA-LWSTE BY 100.
        MODIFY LI_AFA_SZLA FROM LW_AFA_SZLA TRANSPORTING LWBAS LWSTE.
      ENDIF.
    ENDLOOP.
*--2014.12.17 BG
*   /ZAK/UPDATE hívas egyenként a vállalat és feltöltés azonosítóra
    PERFORM UPDATE_AFA_SZLA TABLES LI_ANALITIKA
                                   LI_AFA_SZLA
                                   LI_E_RETURN
                            USING  P_BUKRST
                                   WA_/ZAK/OPACK-PACK
                                   P_BTYPAR
                                   P_BSZNUM
                                   P_TESZT
                                   L_SUBRC.

    APPEND LINES OF LI_ANALITIKA TO I_ANALITIKA.
    APPEND LINES OF LI_AFA_SZLA TO  I_AFA_SZLA.
    APPEND LINES OF LI_E_RETURN TO  I_E_RETURN.
    IF P_TESZT IS INITIAL AND L_SUBRC IS INITIAL.
      CALL FUNCTION '/ZAK/GET_ANAL'
        DESTINATION V_RFCDEST
        EXPORTING
          I_BUKRS     = WA_/ZAK/OPACK-BUKRS
          I_PACK      = WA_/ZAK/OPACK-PACK
          I_TEST      = P_TESZT
        TABLES
          T_ANALITIKA = LI_ANALITIKA
          T_AFA_SZLA  = LI_AFA_SZLA.
    ENDIF.
  ENDLOOP.
ENDFORM.                   "EXECUTE_ANAL

*&---------------------------------------------------------------------*
*&      Form  EXECUTE_OPEN_PACK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$BUKRS     text
*----------------------------------------------------------------------*
FORM EXECUTE_OPEN_PACK
         TABLES $TABLE LIKE I_/ZAK/OPACK
          USING $BUKRS TYPE /ZAK/BEVALLP-BUKRS.

  CALL FUNCTION '/ZAK/OPEN_PACK'
    DESTINATION V_RFCDEST
    EXPORTING
      I_BUKRS     = $BUKRS
*++1965 #05.
      I_BTYPART   = P_BTYPAR
*--1965 #05.
    TABLES
      T_/ZAK/OPACK = $TABLE.
ENDFORM.                    "EXECUTE_OPEN_PACK


*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INITIALIZATION.
  MOVE SY-REPID TO V_REPID.
ENDFORM.                    "INITIALIZATION


*&---------------------------------------------------------------------*
*&      Form  UPDATE_AFA_SZLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->$I_ANALITIKA  text
*      -->$I_AFA_SZLA   text
*      -->$I_E_RETURN   text
*      -->$BUKRS        text
*      -->$PACK         text
*      -->$BTYPAR       text
*      -->$BSZNUM       text
*      -->$TEST         text
*----------------------------------------------------------------------*
FORM UPDATE_AFA_SZLA
              TABLES $I_ANALITIKA LIKE I_ANALITIKA
                     $I_AFA_SZLA  LIKE I_AFA_SZLA
                     $I_E_RETURN  LIKE I_E_RETURN
              USING  $BUKRS   TYPE  /ZAK/BEVALLP-BUKRS
                     $PACK    TYPE  /ZAK/BEVALLP-PACK
                     $BTYPAR  LIKE P_BTYPAR
                     $BSZNUM  LIKE P_BSZNUM
                     $TEST    LIKE P_TESZT
                     $SUBRC.

  DATA LW_RETURN TYPE BAPIRET2.


  CLEAR $SUBRC.

  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = $BUKRS
*     I_BTYPE     =
      I_BTYPART   = $BTYPAR
      I_BSZNUM    = $BSZNUM
      I_PACK      = $PACK
      I_GEN       = 'X'
      I_TEST      = $TEST
*     I_FILE      =
    TABLES
      I_ANALITIKA = $I_ANALITIKA
      I_AFA_SZLA  = $I_AFA_SZLA
      E_RETURN    = $I_E_RETURN.

  LOOP AT $I_E_RETURN WHERE TYPE CA 'AE'.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    MOVE 4 TO $SUBRC.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        I_BAPIRET2_TAB = $I_E_RETURN.
  ENDIF.

ENDFORM.                    "UPDATE_AFA_SZLA
*++1665 #01.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BSZNUM_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_CHECK_BSZNUM  text
*      -->P_LW_ANALITIKA_BTYPE  text
*      -->P_P_BSZNUM  text
*----------------------------------------------------------------------*
FORM CHECK_BSZNUM_BTYPE  TABLES   $I_CHECK_BSZNUM LIKE I_CHECK_BSZNUM
                         USING    $BUKRS
                                  $BTYPE
                                  $BSZNUM.

  DATA LW_CHECK_BSZNUM TYPE T_CHECK_BSZNUM.

* Ellenőriztük már
  READ TABLE $I_CHECK_BSZNUM TRANSPORTING NO FIELDS
                             WITH KEY BUKRS = $BUKRS
                                      BTYPE = $BTYPE
                             BINARY SEARCH.
  CHECK SY-SUBRC NE 0.
  SELECT SINGLE COUNT( * ) FROM /ZAK/BEVALLD
                          WHERE BUKRS    EQ $BUKRS
                            AND BTYPE    EQ $BTYPE
                            AND BSZNUM   EQ $BSZNUM
                            AND PROGRAMM EQ SY-REPID.
  IF SY-SUBRC EQ 0.
    CLEAR LW_CHECK_BSZNUM.
    LW_CHECK_BSZNUM-BUKRS = $BUKRS.
    LW_CHECK_BSZNUM-BTYPE = $BTYPE.
    APPEND LW_CHECK_BSZNUM TO $I_CHECK_BSZNUM.
    SORT $I_CHECK_BSZNUM.
  ELSE.
    MESSAGE E360 WITH $BUKRS $BTYPE $BSZNUM.
*   & vállalat & bevallás típushoz & adatszolgáltatás nincs beállítva!
  ENDIF.

ENDFORM.                    " CHECK_BSZNUM_BTYPE
*--1665 #01.
