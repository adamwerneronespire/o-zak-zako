*&---------------------------------------------------------------------*
*& Report  /ZAK/ZAK_ANALATIKA_CORR
*&
*&---------------------------------------------------------------------*
*& A program a 1008 bevallás 2011 adatait forgatja át DUMMY-ra
*&---------------------------------------------------------------------*
REPORT  /ZAK/ANALITIKA_CORR MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.

*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
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
*++S4HANA#01.
CONSTANTS C_ABEVAZ TYPE /ZAK/ABEVAZ VALUE 'DUMMY_R'.
*--S4HANA#01.
*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

*++S4HANA#01.
*DATA I_/ZAK/ANALITIKA_DEL TYPE STANDARD TABLE OF
*                         /ZAK/ANALITIKA INITIAL SIZE 0.
*DATA I_/ZAK/ANALITIKA_NEW TYPE STANDARD TABLE OF
*                         /ZAK/ANALITIKA INITIAL SIZE 0.
TYPES: BEGIN OF TS_I_/ZAK/ANALITIKA_SEL,
         BUKRS      TYPE /ZAK/ANALITIKA-BUKRS,
         BTYPE      TYPE /ZAK/ANALITIKA-BTYPE,
         GJAHR      TYPE /ZAK/ANALITIKA-GJAHR,
         MONAT      TYPE /ZAK/ANALITIKA-MONAT,
         ZINDEX     TYPE /ZAK/ANALITIKA-ZINDEX,
         ABEVAZ     TYPE /ZAK/ANALITIKA-ABEVAZ,
         PACK       TYPE /ZAK/ANALITIKA-PACK,
         BSEG_GJAHR TYPE /ZAK/ANALITIKA-BSEG_GJAHR,
         BSEG_BELNR TYPE /ZAK/ANALITIKA-BSEG_BELNR,
         BSEG_BUZEI TYPE /ZAK/ANALITIKA-BSEG_BUZEI,
       END OF TS_I_/ZAK/ANALITIKA_SEL.
DATA I_/ZAK/ANALITIKA TYPE STANDARD TABLE OF TS_I_/ZAK/ANALITIKA_SEL INITIAL SIZE 0.
*--S4HANA#01.


*++S4HANA#01.
*DATA W_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.
DATA W_/ZAK/ANALITIKA TYPE TS_I_/ZAK/ANALITIKA_SEL..
*--S4HANA#01.
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-B01.
  SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS MODIF ID DIS.
  SELECT-OPTIONS S_BTYPE FOR /ZAK/ANALITIKA-BTYPE MODIF ID DIS.
*++S4HANA#01.
  SELECT-OPTIONS S_PACK FOR /ZAK/ANALITIKA-PACK OBLIGATORY.
*--S4HANA#01.
  PARAMETERS P_GJAHR LIKE /ZAK/ANALITIKA-GJAHR DEFAULT '2011'
                                              MODIF ID DIS.
  PARAMETERS P_MONAT LIKE /ZAK/ANALITIKA-MONAT DEFAULT '01'
                                              MODIF ID DIS.
  PARAMETERS P_ZINDEX LIKE /ZAK/ANALITIKA-ZINDEX DEFAULT '000'
                                              MODIF ID DIS.

SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  M_DEF S_BUKRS 'I' 'EQ' 'MA01' SPACE.
  M_DEF S_BUKRS 'I' 'EQ' 'MG16' SPACE.
  M_DEF S_BTYPE 'I' 'EQ' '1008' SPACE.
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
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*  Képernyő attribútomok beállítása
  PERFORM SET_SCREEN_ATTRIBUTES.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Adatok feldolgozása
  PERFORM PROCESS_DATA.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SET_SCREEN_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA.

*++S4HANA#01.
**  DATA L_TABNAME(20).
**
**
*  SELECT * INTO TABLE I_/ZAK/ANALITIKA_DEL
*             FROM /ZAK/ANALITIKA
*            WHERE BUKRS IN S_BUKRS
*              AND BTYPE IN S_BTYPE
*              AND GJAHR EQ P_GJAHR
*              AND MONAT EQ P_MONAT
*              AND ZINDEX EQ P_ZINDEX.
*  IF SY-SUBRC EQ 0.
*    DELETE I_/ZAK/ANALITIKA_DEL WHERE ABEVAZ EQ 'DUMMY'.
*    LOOP AT I_/ZAK/ANALITIKA_DEL INTO W_/ZAK/ANALITIKA.
*      W_/ZAK/ANALITIKA-ZCOMMENT = W_/ZAK/ANALITIKA-ABEVAZ.
*      W_/ZAK/ANALITIKA-ABEVAZ = 'DUMMY'.
*      APPEND W_/ZAK/ANALITIKA TO I_/ZAK/ANALITIKA_NEW.
*    ENDLOOP.
*    DELETE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_DEL.
*    INSERT /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA_NEW.
*    COMMIT WORK AND WAIT.
*    MESSAGE I216.
**   Adatmódosítások elmentve!
*  ELSE.
*    MESSAGE I141.
**   Nincs a feltételnek megfelelő analitika rekord!
*  ENDIF.

  DATA L_TABNAME TYPE C LENGTH 20.                                                               "$smart: #139
  DATA L_INDEX TYPE SYST_INDEX.
  DATA LI_BSET TYPE STANDARD TABLE OF BSET.
  DATA LW_BSET TYPE BSET.
  DATA: L_LWBAS TYPE LWBAS_BSET,
        L_FWBAS TYPE FWBAS_BSES,
        L_LWSTE TYPE /ZAK/LWSTE,
        L_FWSTE TYPE /ZAK/FWSTE,
        L_HWBTR TYPE /ZAK/HWBTR,
        L_FWBTR TYPE /ZAK/FWBTR.
  DATA LW_ANALITIKA_BSET TYPE /ZAK/ANALITIKA.

  SELECT BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ PACK BSEG_GJAHR BSEG_BELNR BSEG_BUZEI INTO TABLE  "$smart: #712
    I_/ZAK/ANALITIKA                                                                              "$smart: #712
           FROM /ZAK/ANALITIKA
          WHERE BUKRS  EQ S_BUKRS
            AND ABEVAZ EQ C_ABEVAZ
            AND PACK   IN S_PACK.

  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.
    CLEAR LI_BSET[].                                                                             "$smart: #157
    CLEAR: L_LWBAS, L_LWSTE.
    SELECT * INTO TABLE LI_BSET
             FROM BSET
            WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS
              AND BELNR EQ W_/ZAK/ANALITIKA-BSEG_BELNR
              AND GJAHR EQ W_/ZAK/ANALITIKA-BSEG_GJAHR
            ORDER BY PRIMARY KEY.                                                                "$smart: #600
    LOOP AT LI_BSET INTO LW_BSET.
*  Ha LWBAS ¸res, akkor haszn·ljuk a HWBAS,HWSTE-t.
*++1765 #11. 2017.03.20
*        IF LW_BSET-LWBAS IS INITIAL.
*--1765 #11. 2017.03.20
      MOVE LW_BSET-HWBAS TO LW_BSET-LWBAS.
*++1765 #11. 2017.03.20
*        ENDIF.
*        IF LW_BSET-LWSTE IS INITIAL.
*--1765 #11. 2017.03.20
      MOVE LW_BSET-HWSTE TO LW_BSET-LWSTE.
*++1765 #11. 2017.03.20
*        ENDIF.
*--1765 #11. 2017.03.20
*       Elıjel forgat·s
*++S4HANA#01.
      PERFORM CHANGE_SIGN IN PROGRAM /ZAK/AFA_SAP_SELN USING LW_BSET                              "$smart: #146
                                             CHANGING     LW_ANALITIKA_BSET.
*--S4HANA#01.
      ADD LW_ANALITIKA_BSET-LWBAS TO L_LWBAS.
      ADD LW_ANALITIKA_BSET-LWSTE TO L_LWSTE.
    ENDLOOP.
    UPDATE /ZAK/ANALITIKA SET LWBAS = L_LWBAS
                             LWSTE = L_LWSTE
                       WHERE BUKRS = W_/ZAK/ANALITIKA-BUKRS
                         AND BTYPE = W_/ZAK/ANALITIKA-BTYPE
                         AND GJAHR = W_/ZAK/ANALITIKA-GJAHR
                         AND MONAT = W_/ZAK/ANALITIKA-MONAT
                         AND ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                         AND ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                         AND PACK = W_/ZAK/ANALITIKA-PACK
                         AND BSEG_GJAHR = W_/ZAK/ANALITIKA-BSEG_GJAHR
                         AND BSEG_BELNR = W_/ZAK/ANALITIKA-BSEG_BELNR
                         AND BSEG_BUZEI = W_/ZAK/ANALITIKA-BSEG_BUZEI.
    UPDATE /ZAK/AFA_SZLA  SET LWBAS = L_LWBAS
                             LWSTE = L_LWSTE
                       WHERE BUKRS = W_/ZAK/ANALITIKA-BUKRS
                         AND PACK = W_/ZAK/ANALITIKA-PACK
                         AND BSEG_GJAHR = W_/ZAK/ANALITIKA-BSEG_GJAHR
                         AND BSEG_BELNR = W_/ZAK/ANALITIKA-BSEG_BELNR.
    ADD 1 TO L_INDEX.
  ENDLOOP.

  COMMIT WORK AND WAIT.

  MESSAGE I000 WITH 'Rekordok módosítva (YAK_ANALITIKA és YAK_AFA_SZLA)'.
*   & & & &

*++S4HANA#01.

ENDFORM.                    " PROCESS_DATA
