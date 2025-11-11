*&---------------------------------------------------------------------*
*& Report  /ZAK/AFA_PACKDEL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /zak/afa_packdel MESSAGE-ID /zak/zak.

*&---------------------------------------------------------------------*
*& Funkció leírás: A SAP Hungary a BSET tábla töltését átírta de
*& előtte már futtatásra került a AFA_SAP_SEL program ebből adódóan
*& törölni kell a rekordokat a /ZAK/ANALITIKA és a /ZAK/BSET táblákból
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2007.04.16
*& Funkc.spec.készítő: ________
*& SAP modul neve    : ADO
*& Program  típus    : Riport
*& SAP verzió        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT
*& ----   ----------   ----------    ----------------------- -----------
*& 0001   2008/02/09   Balázs G.     /ZAK/BSET vállalat az FI_BUKRS
*&                                   alapján.
*&---------------------------------------------------------------------*
INCLUDE /zak/common_struct.

TYPE-POOLS: slis.

*ALV közös rutinok
INCLUDE /zak/alv_list_forms.




*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
DATA i_alv_data LIKE /zak/afa_packdel OCCURS 0.
DATA w_alv_data LIKE /zak/afa_packdel.

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
*MAKRO definiálás range feltöltéshez
DEFINE m_def.
  MOVE: &2      TO &1-sign,
        &3      TO &1-option,
        &4      TO &1-low,
        &5      TO &1-high.
  APPEND &1.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK bl01 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS s_pack FOR /zak/analitika-pack  NO INTERVALS
                                            OBLIGATORY
*                                         MODIF ID HID
                                            .
*++ BG 2007.05.17
  SELECT-OPTIONS s_gjahr FOR /zak/analitika-bseg_gjahr NO INTERVALS
                                                      NO-EXTENSION.
  SELECT-OPTIONS s_belnr FOR /zak/analitika-bseg_belnr.
*-- BG 2007.05.17

  PARAMETERS p_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK bl01.


****************************************************************
* LOCAL CLASSES: Definition
****************************************************************



*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
* M_DEF S_PACK 'I' 'EQ' '20070412_001429' SPACE.
* M_DEF S_PACK 'I' 'EQ' '20070412_001430' SPACE.
* M_DEF S_PACK 'I' 'EQ' '20070418_001455' SPACE.
*++1765 #19.
* Jogosultság vizsgálat
  AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2265 #02.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/AFA_PACKDEL'.
*--2265 #02.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF sy-subrc NE 0 AND sy-batch IS INITIAL.
*--1865 #03.
    MESSAGE e152(/zak/zak).
*   Önnek nincs jogosultsága a program futtatásához!
  ENDIF.
*--1765 #19.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM modif_screen.


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
*++2165 #06.
AT SELECTION-SCREEN.
ENHANCEMENT-POINT /ZAK/ZAK_DEL_TELEKOM SPOTS /ZAK/DEL_PACKAGE .

*--2165 #06.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Adatszelekció:
  PERFORM sel_data.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

* Adatfeldolgozása
  PERFORM process_data.


  PERFORM list_spool TABLES  i_alv_data
                     USING  'I_ALV_DATA'.

************************************************************************
*                            ALPROGRAMOK
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  MODIF_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modif_screen .


  LOOP AT SCREEN.
    IF screen-group1 = 'HID'.
      screen-input = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " MODIF_SCREEN
*&---------------------------------------------------------------------*
*&      Form  SEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_data .

*++S4HANA#01.
*  SELECT * INTO TABLE I_/ZAK/ANALITIKA
  SELECT mandt bukrs btype gjahr monat zindex abevaz
    adoazon bsznum pack item lapsz bseg_gjahr bseg_belnr fi_bukrs
            INTO CORRESPONDING FIELDS OF TABLE i_/zak/analitika
*--S4HANA#01.
            FROM /zak/analitika
           WHERE pack IN s_pack
*++ BG 2007.05.17
             AND bseg_gjahr IN s_gjahr
             AND bseg_belnr IN s_belnr
*-- BG 2007.05.17
           .

  IF sy-subrc NE 0.
    MESSAGE e031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
  ENDIF.

*++1365 #7.
* ÁFA számlák beolvasása
  SELECT * INTO TABLE i_/zak/afa_szla
           FROM /zak/afa_szla
          WHERE pack IN s_pack
            AND bseg_gjahr IN s_gjahr
            AND bseg_belnr IN s_belnr.
*--1365 #7.

ENDFORM.                    " SEL_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data .

  LOOP AT i_/zak/analitika INTO w_/zak/analitika
*++1365 #9.
                         WHERE abevaz NE c_abevaz_dummy_r.
*--1365 #9.

*++0001 BG 2008.02.19
*    IF W_/ZAK/ANALITIKA-BUKRS EQ 'MMOB'.
*      W_/ZAK/ANALITIKA-BUKRS = 'MA01'.
*    ENDIF.
*--0001 BG 2008.02.19
    CLEAR w_alv_data.
*++0001 BG 2008.02.19
*   MOVE W_/ZAK/ANALITIKA-BUKRS TO W_ALV_DATA-BUKRS.
    MOVE w_/zak/analitika-fi_bukrs TO w_alv_data-bukrs.
*--0001 BG 2008.02.19
    MOVE w_/zak/analitika-bseg_gjahr TO w_alv_data-gjahr.
    MOVE w_/zak/analitika-bseg_belnr TO w_alv_data-belnr.
    COLLECT w_alv_data INTO i_alv_data.
  ENDLOOP.

  IF i_alv_data[] IS INITIAL.
    MESSAGE e031.
*   Adatbázis nem tartalmaz feldolgozható rekordot!
  ENDIF.

  CHECK p_test IS INITIAL.

  LOOP AT i_alv_data INTO w_alv_data.
*   BSET update
    UPDATE /zak/bset SET zindex = ''
                  WHERE bukrs EQ w_alv_data-bukrs
                    AND belnr EQ w_alv_data-belnr
                    AND gjahr EQ w_alv_data-gjahr.
  ENDLOOP.
*++1465 #06.
*++1665 #14.
  IF s_gjahr[] IS INITIAL AND s_belnr[] IS INITIAL.
*--1665 #14.
* /ZAK/BEVALLP update
    UPDATE /zak/bevallp SET xloek = 'X'
*++1765 #01.
                           deluser = sy-uname
                           deldate = sy-datum
                           deltime = sy-uzeit
*--1765 #01.
                      WHERE pack  IN s_pack.
*--1465 #06.
*++1665 #14.
  ENDIF.
*--1665 #14.
  DELETE /zak/analitika FROM TABLE i_/zak/analitika.
*++1365 #7.
  DELETE /zak/afa_szla  FROM TABLE i_/zak/afa_szla.
*--1365 #7.
  COMMIT WORK AND WAIT.

  MESSAGE i216.
*   Adatmódosítások elmentve!



ENDFORM.                    " PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM list_spool TABLES   $tab
*                USING    $tab_name.
FORM list_spool TABLES   $tab STRUCTURE /zak/afa_packdel
                USING    $tab_name TYPE clike.
*--S4HANA#01.

*ALV lista init
  PERFORM common_alv_list_init USING sy-title
                                     $tab_name
                                     '/ZAK/AFA_PACKDEL'.

*ALV lista
  PERFORM common_alv_grid_display TABLES $tab
                                  USING  $tab_name
                                         space
                                         space.

ENDFORM.                    " LIST_SPOOL
