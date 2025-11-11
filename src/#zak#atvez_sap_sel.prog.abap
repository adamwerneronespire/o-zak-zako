*&---------------------------------------------------------------------*
*& Program: SAP adatok meghatározása átvezetési nyomtatványhoz
*&---------------------------------------------------------------------*
REPORT /ZAK/ATVEZ_SAP_SEL .
*&---------------------------------------------------------------------*
*& Funkció leírás: A program a szelekción megadott feltételek alapján
*& adatokat rögzít és tölti a /ZAK/ANALITIKA táblát.
*&---------------------------------------------------------------------*
*& Szerző            : Cserhegyi Tímea - FMC
*& Létrehozás dátuma : 2006.03.08
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
*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx
*&                                   xxxxxxx xxxxxxx xxxxxxx
*&---------------------------------------------------------------------*

INCLUDE /ZAK/COMMON_STRUCT.


*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_NUM         TYPE C VALUE 'N'.


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

CONTROLS: TC_9000 TYPE TABLEVIEW USING SCREEN 9000.

DATA: BEGIN OF I_LINES OCCURS 20.
DATA:  MARK.                        "Check box
        INCLUDE STRUCTURE /ZAK/ATVEZ_SOR.
DATA: END OF I_LINES.


DATA: BEGIN OF I_ABEV OCCURS 20.
DATA:  FIELDNAME(20),
       COLUMN_ID(10).
DATA: END OF I_ABEV.


DATA: I_ADO_SUM TYPE STANDARD TABLE OF /ZAK/ADONSZA_ALV INITIAL SIZE 0.
DATA: W_ADO_SUM TYPE /ZAK/ADONSZA_ALV.

DATA: G_BUKTEXT(40),
      G_BEVTEXT(40).

DATA: V_OK_CODE LIKE SY-UCOMM,
      V_SAVE_OK LIKE SY-UCOMM,
      V_LAST_DATE TYPE D.
*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

* Vállalat
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-101.
PARAMETERS: P_BUKRS  LIKE /ZAK/BEVALLSZ-BUKRS VALUE CHECK
                          OBLIGATORY MEMORY ID BUK.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.

* Bevallás fajta
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-103 FOR FIELD P_BTART.
PARAMETERS: P_BTART LIKE /ZAK/BEVALL-BTYPART OBLIGATORY.
SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BTTEXT(40) TYPE C MODIF ID DIS.
SELECTION-SCREEN END OF LINE.

* Bevallás típus
SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 01(31) text-102.
PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALLSZ-BTYPE NO-DISPLAY.
SELECTION-SCREEN POSITION 33.
PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID DIS.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN: SKIP 1.
* Év
PARAMETERS: P_GJAHR LIKE BKPF-GJAHR DEFAULT SY-DATUM(4)
                                    OBLIGATORY.
* Hónap
PARAMETERS: P_MONAT LIKE BKPF-MONAT DEFAULT SY-DATUM+4(2)
                                    OBLIGATORY.
PARAMETERS: P_INDEX LIKE /ZAK/BEVALLI-ZINDEX NO-DISPLAY.
SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD P_BUKRS.
*  Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.
  PERFORM READ_COLS.
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


AT SELECTION-SCREEN ON P_BTART.
*  Bevallás típus ellenőrzése
  PERFORM VER_BTYPEART USING C_BTYPART_ATV.


AT SELECTION-SCREEN ON P_MONAT.
*  Periódus ellenőrzése
  PERFORM VER_PERIOD   USING P_MONAT.



*&---------------------------------------------------------------------*
*  AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  Megnevezések meghatározása
  PERFORM READ_ADDITIONALS.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*  Jogosultság vizsgálat
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                P_BTART
                                C_ACTVT_01.

* Zárolás beállítás
  PERFORM ENQUEUE_PERIOD.

* Bevallás utolsó napjának meghatározása
  PERFORM GET_LAST_DAY_OF_PERIOD USING P_GJAHR
                                       P_MONAT
                                  CHANGING V_LAST_DATE.

* Bevallás általános adatai
  PERFORM READ_BEVALL  USING P_BUKRS
                             P_BTART
                             P_BTYPE
                             V_LAST_DATE.
* Bevallás státusza
  PERFORM READ_BEVALLI CHANGING P_INDEX.

  PERFORM FILL_MONAT.
  PERFORM READ_ADONSZA.
  PERFORM READ_ANALITIKA.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  DESCRIBE TABLE I_LINES LINES TC_9000-LINES.
  CALL SCREEN 9000.



*&---------------------------------------------------------------------*
*&      Form  read_additionals
*&---------------------------------------------------------------------*
FORM READ_ADDITIONALS.
* Vállalat megnevezése
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE BUTXT INTO P_BUTXT FROM T001
       WHERE BUKRS = P_BUKRS.
  ENDIF.

* Bevallásfajta megnevezése
  IF NOT P_BTART IS INITIAL.
    SELECT DDTEXT UP TO 1 ROWS INTO P_BTTEXT FROM DD07T
       WHERE DOMNAME = '/ZAK/BTYPART'
         AND DDLANGUAGE = SY-LANGU
         AND DOMVALUE_L = P_BTART.
    ENDSELECT.

* Bevallás típus meghatározása
    CHECK NOT P_GJAHR IS INITIAL AND
          NOT P_MONAT IS INITIAL.

    PERFORM GET_BTYPE USING P_BUKRS
                            P_BTART
                            P_GJAHR
                            P_MONAT
                      CHANGING P_BTYPE.
  ENDIF.
* Bevallásfajta megnevezése
  IF NOT P_BTYPE IS INITIAL.
    SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
      WHERE LANGU = SY-LANGU
         AND BUKRS = P_BUKRS
         AND BTYPE = P_BTYPE.
  ENDIF.

ENDFORM.                    " read_additionals
*&---------------------------------------------------------------------*
*&      Form  set_screen_attributes
*&---------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTES.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " set_screen_attributes
*&---------------------------------------------------------------------*
*&      Form  ver_period
*&---------------------------------------------------------------------*
FORM VER_PERIOD USING    $MONAT.

  IF NOT $MONAT BETWEEN '01' AND '16'.
    MESSAGE E020(/ZAK/ZAK).
*   Kérem a periódus értékét 01-16 között adja meg!
  ENDIF.

ENDFORM.                    " ver_period
*&---------------------------------------------------------------------*
*&      Form  ver_btypeart
*&---------------------------------------------------------------------*
FORM VER_BTYPEART USING   $BTYPART.

  DATA L_BTYPART LIKE /ZAK/BEVALL-BTYPART.
  IF NOT P_BTYPE IS INITIAL.

    SELECT BTYPART up to 1 rows  INTO L_BTYPART
                          FROM /ZAK/BEVALL
                         WHERE BUKRS EQ P_BUKRS
                           AND BTYPE EQ P_BTYPE.
    endselect.
    IF SY-SUBRC NE 0 OR L_BTYPART NE $BTYPART.
      MESSAGE E107(/ZAK/ZAK).
    ENDIF.

  ELSE.
    IF P_BTART NE $BTYPART.
      MESSAGE E107(/ZAK/ZAK).
    ENDIF.

  ENDIF.
ENDFORM.                    " ver_btypeart
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'MAIN_9000'.
  SET TITLEBAR 'A00'.

  /ZAK/ANALITIKA-BUKRS = P_BUKRS.
  G_BUKTEXT = P_BUTXT.
  /ZAK/ANALITIKA-BTYPE = P_BTYPE.
  G_BEVTEXT = P_BTEXT.
  /ZAK/ANALITIKA-WAERS = C_HUF.

  /ZAK/ANALITIKA-GJAHR  = P_GJAHR.
  /ZAK/ANALITIKA-MONAT  = P_MONAT.
  /ZAK/ANALITIKA-ZINDEX = P_INDEX.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_I_lines  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_I_LINES INPUT.

* Szövegek feltöltése
  PERFORM FILL_TEXTS.

* ELLENŐRZÉSEK
  PERFORM CHECK_ADONEM.
  PERFORM CHECK_SOURCE.

  MODIFY I_LINES INDEX TC_9000-CURRENT_LINE.
ENDMODULE.                 " MODIFY_I_lines  INPUT
*&---------------------------------------------------------------------*
*&      Form  read_bevalli
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_BEVALLI CHANGING $INDEX..

  DATA: L_FOUND TYPE C.
  DATA: L_INDEX(3) TYPE N.

  SELECT * INTO TABLE I_/ZAK/BEVALLI
     FROM /ZAK/BEVALLI
     WHERE BUKRS = P_BUKRS
       AND BTYPE = P_BTYPE
       AND GJAHR = P_GJAHR
       AND MONAT = P_MONAT.

* Van valami az adott periódusra?
  DESCRIBE TABLE I_/ZAK/BEVALLI LINES SY-TFILL.
  IF SY-TFILL = 0.
    $INDEX = '000'.
    L_FOUND = 'X'.
  ENDIF.

  CHECK L_FOUND = SPACE.
* Van nyitott index?
  READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
    WITH KEY FLAG = 'F'.
  IF SY-SUBRC = 0.
    $INDEX = W_/ZAK/BEVALLI-ZINDEX.
    L_FOUND = 'X'.
  ENDIF.

  CHECK L_FOUND = SPACE.
* Melyik az utolsó lezárt?
  READ TABLE I_/ZAK/BEVALLI INTO W_/ZAK/BEVALLI
    INDEX SY-TFILL.
  IF SY-SUBRC = 0.
    L_INDEX = W_/ZAK/BEVALLI-ZINDEX + 1.
    $INDEX = L_INDEX.
    L_FOUND = 'X'.
  ENDIF.

ENDFORM.                    " read_bevalli
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

 DATA:  LINNO TYPE I.                    "line number at cursor position
  DATA:  FLD(20).                         "field name at cursor position
  DATA:  OFF TYPE I.                      "offset of cursor position


  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.

  CASE V_SAVE_OK.
* Vissza
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
* Kilépés
    WHEN 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.

* Mentés - analitika tábla feltöltése
    WHEN 'SAVE'.
      PERFORM SAVE.
      SET SCREEN 0.
      LEAVE SCREEN.


* Kijelölt rekordok törlése
    WHEN 'DELL'.
      LOOP AT I_LINES WHERE MARK = 'X'.
        DELETE I_LINES.
      ENDLOOP.
      IF SY-SUBRC <> 0.
        GET CURSOR FIELD FLD LINE LINNO OFFSET OFF.
        SET CURSOR FIELD FLD LINE LINNO OFFSET OFF.
        IF FLD CP 'I_LINES*' AND SY-SUBRC = 0.
          LINNO = LINNO + TC_9000-TOP_LINE - 1.
          DELETE I_LINES INDEX LINNO.
          TC_9000-LINES = TC_9000-LINES - 1.
        ENDIF.
      ENDIF.
* Sor beszúrása kurzorpozíció fölé
    WHEN 'INSL'.
      GET CURSOR FIELD FLD LINE LINNO OFFSET OFF.
      SET CURSOR FIELD FLD LINE LINNO OFFSET OFF.
      IF FLD CP 'I_LINES*' AND SY-SUBRC = 0.
        IF LINNO >= 1.
          LINNO = LINNO + TC_9000-TOP_LINE - 1.
          CLEAR I_LINES.
          I_LINES-WAERS_SRC  = C_HUF.
          I_LINES-WAERS_DES  = C_HUF.
          I_LINES-WAERS_UTAL = C_HUF.

          INSERT I_LINES INDEX LINNO.
          TC_9000-LINES = TC_9000-LINES + 1.
        ELSE.
          CLEAR I_LINES.
          I_LINES-WAERS_SRC  = C_HUF.
          I_LINES-WAERS_DES  = C_HUF.
          I_LINES-WAERS_UTAL = C_HUF.

          APPEND I_LINES.
          TC_9000-LINES = TC_9000-LINES + 1.
        ENDIF.
      ENDIF.


* Sor appendálása - új sor
    WHEN 'APPL'.
      CLEAR I_LINES.
      I_LINES-WAERS_SRC  = C_HUF.
      I_LINES-WAERS_DES  = C_HUF.
      I_LINES-WAERS_UTAL = C_HUF.
      APPEND I_LINES.

      TC_9000-LINES = TC_9000-LINES + 1.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  read_analitika
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_ANALITIKA.

  DATA: BEGIN OF I_LINES_TMP OCCURS 0,
          SOR(2)    TYPE N,
          OSZLOP(8) TYPE C,
          ABEVAZ    TYPE /ZAK/ABEVAZ,
          FIELD_N   TYPE /ZAK/FIELDN,
          FIELD_C   TYPE /ZAK/FIELDC,
        END OF I_LINES_TMP.

  SELECT * INTO TABLE I_/ZAK/ANALITIKA FROM  /ZAK/ANALITIKA
         WHERE  BUKRS   = P_BUKRS
         AND    BTYPE   = P_BTYPE
         AND    GJAHR   = P_GJAHR
         AND    MONAT   = P_MONAT
         AND    ZINDEX  = P_INDEX.

* Sor szerkezet szerint fel kell tölteni a belső táblát


  LOOP AT I_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.

* Nyomtatvány adatok beolvasása abevhez
    CLEAR W_/ZAK/BEVALLB.
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE  = W_/ZAK/ANALITIKA-BTYPE
                ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE  = W_/ZAK/ANALITIKA-BTYPE
          AND   ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ.
      INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
    ENDIF.


    I_LINES_TMP-SOR     = W_/ZAK/BEVALLB-SORINDEX+0(2).
    I_LINES_TMP-OSZLOP  = W_/ZAK/BEVALLB-SORINDEX+2(8).
    I_LINES_TMP-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
    I_LINES_TMP-FIELD_N = W_/ZAK/ANALITIKA-FIELD_N.
    I_LINES_TMP-FIELD_C = W_/ZAK/ANALITIKA-FIELD_C.
    APPEND I_LINES_TMP.


  ENDLOOP.

  SORT I_LINES_TMP.

  LOOP AT I_LINES_TMP.

    AT NEW SOR.
      CLEAR I_LINES.
    ENDAT.

    CASE I_LINES_TMP-OSZLOP.
      WHEN 'A'.
        I_LINES-ADONEM_SRC = I_LINES_TMP-FIELD_C.
      WHEN 'C'.
        I_LINES-WRBTR_SRC = I_LINES_TMP-FIELD_N.
      WHEN 'D'.
        I_LINES-ADONEM_DES = I_LINES_TMP-FIELD_C.
      WHEN 'F'.
        I_LINES-WRBTR_DES = I_LINES_TMP-FIELD_N.
      WHEN 'G'.
        I_LINES-WRBTR_UTAL = I_LINES_TMP-FIELD_N.
    ENDCASE.

    I_LINES-WAERS_SRC  = W_/ZAK/ANALITIKA-WAERS.
    I_LINES-WAERS_DES  = W_/ZAK/ANALITIKA-WAERS.
    I_LINES-WAERS_UTAL = W_/ZAK/ANALITIKA-WAERS.

    PERFORM FILL_TEXTS.

    AT END OF SOR.
      APPEND I_LINES.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " read_analitika
*&---------------------------------------------------------------------*
*&      Form  GET_BTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BTYPE USING    $BUKRS
                        $BTYPART
                        $GJAHR
                        $MONAT
               CHANGING $BTYPE.

  CLEAR $BTYPE.

  CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
            I_BUKRS     = $BUKRS
            I_BTYPART   = $BTYPART
            I_GJAHR     = $GJAHR
            I_MONAT     = $MONAT
       IMPORTING
            E_BTYPE     = $BTYPE
       EXCEPTIONS
            ERROR_MONAT = 1
            ERROR_BTYPE = 2
            OTHERS      = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " GET_BTYPE
*&---------------------------------------------------------------------*
*&      Module  init_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_9000 OUTPUT.
* Ha nincs tétel - kezdeti inicializálás
  IF TC_9000-LINES = 0.
    TC_9000-LINES = 1.
    CLEAR I_LINES.
    I_LINES-WAERS_SRC  = C_HUF.
    I_LINES-WAERS_DES  = C_HUF.
    I_LINES-WAERS_UTAL = C_HUF.
    APPEND I_LINES.
  ENDIF.

ENDMODULE.                 " init_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  check_source
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SOURCE.
  DATA: V_WRBTR   TYPE WRBTR.
*++S4HANA#01.
*  DATA: V_WRBTR_C(17),
*        v_wrbtr_src_c(17).
  DATA: V_WRBTR_C(23),
        v_wrbtr_src_c(23).
*--S4HANA#01.

* Ha van forrás, kell cél is
*  IF NOT I_LINES-ADONEM_SRC IS INITIAL AND
*         I_LINES-ADONEM_DES IS INITIAL.
*    MESSAGE W140(/ZAK/ZAK) WITH I_LINES-ADONEM_SRC
*                           TC_9000-CURRENT_LINE.
*  ENDIF.

* Ha van cél, kell forrás is
  IF NOT I_LINES-ADONEM_DES IS INITIAL AND
         I_LINES-ADONEM_SRC IS INITIAL.
    MESSAGE W139(/ZAK/ZAK) WITH I_LINES-ADONEM_DES
                           TC_9000-CURRENT_LINE.

  ENDIF.

* Összeg ellenőrzés: cél nagyobb, mint a forrás
  IF I_LINES-WRBTR_SRC < I_LINES-WRBTR_DES.

      WRITE I_LINES-WRBTR_DES TO V_WRBTR_C CURRENCY C_HUF.
      WRITE I_LINES-WRBTR_SRC TO V_WRBTR_src_C CURRENCY C_HUF.

    MESSAGE E138(/ZAK/ZAK) WITH V_WRBTR_src_C
                           V_WRBTR_C
                           TC_9000-CURRENT_LINE.
  ENDIF.

* Van-e a folyószámlán ennyi?
  IF NOT I_LINES-WRBTR_SRC IS INITIAL.
    READ TABLE I_ADO_SUM INTO W_ADO_SUM
                      WITH KEY BUKRS  = P_BUKRS
                               ADONEM = I_LINES-ADONEM_SRC.
    IF SY-SUBRC = 0.
      V_WRBTR = W_ADO_SUM-WRBTR.
    ELSE.
      CLEAR V_WRBTR.
    ENDIF.

    IF V_WRBTR < I_LINES-WRBTR_SRC.
      WRITE V_WRBTR TO V_WRBTR_C CURRENCY C_HUF.
      WRITE I_LINES-WRBTR_SRC TO V_WRBTR_src_C CURRENCY C_HUF.

      MESSAGE W137(/ZAK/ZAK) WITH I_LINES-ADONEM_SRC
                             v_WRBTR_SRC_c
                             V_WRBTR_C
                             TC_9000-CURRENT_LINE.

    ENDIF.

  ENDIF.

ENDFORM.                    " check_source
*&---------------------------------------------------------------------*
*&      Form  read_adonsza
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_ADONSZA.

  REFRESH I_/ZAK/ADONSZA.
  REFRESH I_ADO_SUM.

  SELECT * INTO TABLE I_/ZAK/ADONSZA
    FROM /ZAK/ADONSZA
    WHERE BUKRS = P_BUKRS AND
          KOTEL = 'K'     AND
          BELNR_K = '          '.


  LOOP AT I_/ZAK/ADONSZA INTO W_/ZAK/ADONSZA.
    CLEAR W_/ZAK/ADONSZA-ESDAT.
    MOVE-CORRESPONDING W_/ZAK/ADONSZA TO W_ADO_SUM.
    COLLECT W_ADO_SUM INTO I_ADO_SUM.
  ENDLOOP.

ENDFORM.                    " read_adonsza
*&---------------------------------------------------------------------*
*&      Form  check_adonem
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_ADONEM.

  IF NOT I_LINES-ADONEM_SRC IS INITIAL.
    SELECT SINGLE * INTO W_/ZAK/ADONEM FROM  /ZAK/ADONEM
           WHERE  BUKRS   = P_BUKRS
           AND    ADONEM  = I_LINES-ADONEM_SRC.

    IF SY-SUBRC NE 0.
      MESSAGE I136(/ZAK/ZAK) WITH P_BUKRS
                             I_LINES-ADONEM_SRC
                             TC_9000-CURRENT_LINE.
    ENDIF.
  ENDIF.

  IF NOT I_LINES-ADONEM_DES IS INITIAL.
    SELECT SINGLE * INTO W_/ZAK/ADONEM FROM  /ZAK/ADONEM
           WHERE  BUKRS   = P_BUKRS
           AND    ADONEM  = I_LINES-ADONEM_DES.

    IF SY-SUBRC NE 0.
      MESSAGE I136(/ZAK/ZAK) WITH P_BUKRS
                             I_LINES-ADONEM_DES
                             TC_9000-CURRENT_LINE.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_adonem
*&---------------------------------------------------------------------*
*&      Form  read_cols
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_COLS.

  REFRESH I_ABEV.

  CLEAR I_ABEV.
  I_ABEV-FIELDNAME = 'I_LINES-ADONEM_SRC'.
  I_ABEV-COLUMN_ID = 'A'.
  APPEND I_ABEV.

  CLEAR I_ABEV.
  I_ABEV-FIELDNAME = 'I_LINES-WRBTR_SRC'.
  I_ABEV-COLUMN_ID = 'C'.
  APPEND I_ABEV.

  CLEAR I_ABEV.
  I_ABEV-FIELDNAME = 'I_LINES-ADONEM_DES'.
  I_ABEV-COLUMN_ID = 'D'.
  APPEND I_ABEV.

  CLEAR I_ABEV.
  I_ABEV-FIELDNAME = 'I_LINES-WRBTR_DES'.
  I_ABEV-COLUMN_ID = 'F'.
  APPEND I_ABEV.

  CLEAR I_ABEV.
  I_ABEV-FIELDNAME = 'I_LINES-WRBTR_UTAL'.
  I_ABEV-COLUMN_ID = 'G'.
  APPEND I_ABEV.

ENDFORM.                    " read_cols
*&---------------------------------------------------------------------*
*&      Form  save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE.

  DATA: T_/ZAK/ANALITIKA  TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
        L_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA,
        V_INDEX LIKE SY-TABIX,
        V_DO_INDEX LIKE SY-TABIX.


* Teljes periódus törlése
  DELETE FROM /ZAK/ANALITIKA
     WHERE BUKRS = P_BUKRS     AND
           BTYPE = P_BTYPE     AND
           GJAHR = P_GJAHR     AND
           MONAT = P_MONAT     AND
           ZINDEX = P_INDEX.
  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

* ADATok mentése
  LOOP AT I_LINES.
    V_INDEX = SY-TABIX.


    DO 5 TIMES.

      V_DO_INDEX = SY-INDEX.

* ABEV azonosító meghatározása 1. mezőre
      CASE V_DO_INDEX.
        WHEN 1.
          PERFORM GET_ABEV USING V_INDEX
                                 'I_LINES-ADONEM_SRC'
                                 I_LINES-ADONEM_SRC
                           CHANGING /ZAK/ANALITIKA-ABEVAZ
                                    /ZAK/ANALITIKA-XDEFT
                                    /ZAK/ANALITIKA-ZCOMMENT
                                    /ZAK/ANALITIKA-FIELD_C
                                    /ZAK/ANALITIKA-FIELD_N.

        WHEN 2.
          PERFORM GET_ABEV USING V_INDEX
                                 'I_LINES-WRBTR_SRC'
                                 I_LINES-WRBTR_SRC
                           CHANGING /ZAK/ANALITIKA-ABEVAZ
                                    /ZAK/ANALITIKA-XDEFT
                                    /ZAK/ANALITIKA-ZCOMMENT
                                    /ZAK/ANALITIKA-FIELD_C
                                    /ZAK/ANALITIKA-FIELD_N.

        WHEN 3.
          PERFORM GET_ABEV USING V_INDEX
                                 'I_LINES-ADONEM_DES'
                                 I_LINES-ADONEM_DES
                           CHANGING /ZAK/ANALITIKA-ABEVAZ
                                    /ZAK/ANALITIKA-XDEFT
                                    /ZAK/ANALITIKA-ZCOMMENT
                                    /ZAK/ANALITIKA-FIELD_C
                                    /ZAK/ANALITIKA-FIELD_N.
        WHEN 4.
          PERFORM GET_ABEV USING V_INDEX
                                 'I_LINES-WRBTR_DES'
                                 I_LINES-WRBTR_DES
                           CHANGING /ZAK/ANALITIKA-ABEVAZ
                                    /ZAK/ANALITIKA-XDEFT
                                    /ZAK/ANALITIKA-ZCOMMENT
                                    /ZAK/ANALITIKA-FIELD_C
                                    /ZAK/ANALITIKA-FIELD_N.
        WHEN 5.
          PERFORM GET_ABEV USING V_INDEX
                                 'I_LINES-WRBTR_UTAL'
                                 I_LINES-WRBTR_UTAL
                           CHANGING /ZAK/ANALITIKA-ABEVAZ
                                    /ZAK/ANALITIKA-XDEFT
                                    /ZAK/ANALITIKA-ZCOMMENT
                                    /ZAK/ANALITIKA-FIELD_C
                                    /ZAK/ANALITIKA-FIELD_N.
      ENDCASE.

      /ZAK/ANALITIKA-BSZNUM  = '999'.
      /ZAK/ANALITIKA-ADOAZON = SPACE.
      /ZAK/ANALITIKA-PACK    = SPACE.
      /ZAK/ANALITIKA-XMANU = 'X'.

* Tételsorszám
      PERFORM GET_NEXT_ITEM USING      /ZAK/ANALITIKA
                                       V_DO_INDEX
                            CHANGING L_/ZAK/ANALITIKA.


* Dinamikus lapszám: 24 soronként lép
      PERFORM GET_PAGE_NO USING    V_INDEX
                                   24
                          CHANGING L_/ZAK/ANALITIKA-LAPSZ.


* Új tétel
      CLEAR L_/ZAK/ANALITIKA-ZINDEX.
      APPEND L_/ZAK/ANALITIKA TO T_/ZAK/ANALITIKA.

    ENDDO.

  ENDLOOP.

* Közös update
  IF NOT T_/ZAK/ANALITIKA[] IS INITIAL.
    PERFORM CALL_UPDATE TABLES I_RETURN
                               T_/ZAK/ANALITIKA
                        USING  /ZAK/ANALITIKA-BUKRS
                               /ZAK/ANALITIKA-BTYPE
                               /ZAK/ANALITIKA-BSZNUM
                               SPACE
                               SPACE
                               SPACE
                        CHANGING /ZAK/ANALITIKA-ZINDEX.
  ENDIF.


* Státusz
* Amennyiben  bevallás már letöltött volt > státusz visszaállítása
  SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
     WHERE BUKRS = /ZAK/ANALITIKA-BUKRS
       AND BTYPE = /ZAK/ANALITIKA-BTYPE
       AND GJAHR = /ZAK/ANALITIKA-GJAHR
       AND MONAT = /ZAK/ANALITIKA-MONAT
       AND ZINDEX = /ZAK/ANALITIKA-ZINDEX
       AND FLAG = 'T'.

  IF NOT I_/ZAK/BEVALLSZ[] IS INITIAL.
    LOOP AT I_/ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ.

      UPDATE /ZAK/BEVALLSZ SET FLAG = 'F'
         WHERE BUKRS  = W_/ZAK/BEVALLSZ-BUKRS
           AND BTYPE  = W_/ZAK/BEVALLSZ-BTYPE
           AND BSZNUM = W_/ZAK/BEVALLSZ-BSZNUM
           AND GJAHR  = W_/ZAK/BEVALLSZ-GJAHR
           AND MONAT  = W_/ZAK/BEVALLSZ-MONAT
           AND ZINDEX = W_/ZAK/BEVALLSZ-ZINDEX
           AND PACK   = W_/ZAK/BEVALLSZ-PACK.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.

    ENDLOOP.
  ENDIF.

  REFRESH I_RETURN.

ENDFORM.                    " save
*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_NEXT_ITEM USING    /ZAK/ANALITIKA     TYPE /ZAK/ANALITIKA
                            L_INDEX
                   CHANGING L_/ZAK/ANALITIKA   TYPE /ZAK/ANALITIKA.

  DATA: L_ITEM LIKE /ZAK/ANALITIKA-ITEM.

  CLEAR L_/ZAK/ANALITIKA.

* Utolsó Tételszám
  SELECT MAX( ITEM ) INTO L_ITEM FROM /ZAK/ANALITIKA
     WHERE BUKRS   = /ZAK/ANALITIKA-BUKRS
       AND BTYPE   = /ZAK/ANALITIKA-BTYPE
       AND GJAHR   = /ZAK/ANALITIKA-GJAHR
       AND MONAT   = /ZAK/ANALITIKA-MONAT
       AND ZINDEX  = /ZAK/ANALITIKA-ZINDEX
       AND ABEVAZ  = /ZAK/ANALITIKA-ABEVAZ
       AND ADOAZON = /ZAK/ANALITIKA-ADOAZON
       AND BSZNUM  = /ZAK/ANALITIKA-BSZNUM
       AND PACK    = /ZAK/ANALITIKA-PACK.

*  L_ITEM = L_ITEM + l_index.
  L_ITEM = L_ITEM + 1.

  MOVE-CORRESPONDING /ZAK/ANALITIKA TO L_/ZAK/ANALITIKA.
  L_/ZAK/ANALITIKA-XMANU = 'X'.
  L_/ZAK/ANALITIKA-ITEM  = L_ITEM.

ENDFORM.                    " GET_NEXT_ITEM
*&---------------------------------------------------------------------*
*&      Form  get_page_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PAGE_NO USING    P_NUMBER
                          P_LINES
                 CHANGING P_LAPSZ.

  DATA: V_MOD TYPE I,
        V_DIV TYPE I.

  CLEAR P_LAPSZ.

  V_MOD = P_NUMBER MOD P_LINES.
  V_DIV = P_NUMBER DIV P_LINES.

  IF V_MOD > 0.
    P_LAPSZ = V_DIV + 1.
  ELSE.
    P_LAPSZ = V_DIV.
  ENDIF.

ENDFORM.                    " get_page_no
*&---------------------------------------------------------------------*
*&      Form  get_abev
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ABEV USING    P_INDEX
                       P_FIELDNAME
                       P_FIELDVALUE
              CHANGING P_ABEVAZ
                       P_XDEFT
                       P_ZCOMMENT
                       P_FIELD_C
                       P_FIELD_N.

  DATA: V_SORIND LIKE /ZAK/BEVALLB-SORINDEX,
        V_COLUMN(10),
        V_IND(2) TYPE N.

  READ TABLE I_ABEV WITH KEY FIELDNAME = P_FIELDNAME.
  IF SY-SUBRC = 0.
    V_COLUMN = I_ABEV-COLUMN_ID.
    V_IND    = P_INDEX.

    CONCATENATE V_IND V_COLUMN INTO V_SORIND.
*
    CLEAR W_/ZAK/BEVALLB.
    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
       WITH KEY BTYPE = /ZAK/ANALITIKA-BTYPE
                SORINDEX  = V_SORIND.
    IF SY-SUBRC NE 0.
      CLEAR W_/ZAK/BEVALLB.
      SELECT * UP TO 1 ROWS INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
          WHERE BTYPE = /ZAK/ANALITIKA-BTYPE
          AND    SORINDEX  = V_SORIND.
      ENDSELECT.
      INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
    ENDIF.

    P_ABEVAZ = W_/ZAK/BEVALLB-ABEVAZ.
    CLEAR P_ZCOMMENT.

    IF W_/ZAK/BEVALLB-FIELDTYPE = C_NUM.
      CLEAR: P_FIELD_C,
             P_XDEFT.
      P_FIELD_N = P_FIELDVALUE.
    ELSE.
      CLEAR: P_FIELD_N.
      P_XDEFT = 'X'.
      P_FIELD_C = P_FIELDVALUE.

    ENDIF.
  ENDIF.

ENDFORM.                    " get_abev
*&---------------------------------------------------------------------*
*&      Form  CALL_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_UPDATE TABLES   I_RETURN STRUCTURE BAPIRET2
                          T_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA
                 USING    P_BUKRS   TYPE BUKRS
                          P_BTYPE   TYPE /ZAK/BTYPE
                          P_BSZNUM  TYPE /ZAK/BSZNUM
                          P_PACK    TYPE /ZAK/PACK
                          P_GEN     TYPE CHAR01
                          P_TEST    TYPE CHAR01
                 CHANGING P_INDEX   TYPE /ZAK/INDEX.


  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS           = P_BUKRS
      I_BTYPE           = P_BTYPE
*   I_BTYPART         =
      I_BSZNUM          = P_BSZNUM
      I_PACK            = P_PACK
      I_GEN             = P_GEN
      I_TEST            = P_TEST
*   I_FILE            =
    TABLES
      I_ANALITIKA       = T_/ZAK/ANALITIKA
      E_RETURN          = I_RETURN  .

  READ TABLE T_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA INDEX 1.
  IF SY-SUBRC = 0.
    P_INDEX = W_/ZAK/ANALITIKA-ZINDEX.
  ENDIF.

  IF NOT I_RETURN[] IS INITIAL.

    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
         TABLES
              T_RETURN = I_RETURN.

  ELSE.
    MESSAGE S144(/ZAK/ZAK) WITH P_BTYPE P_GJAHR P_MONAT.
  ENDIF.

ENDFORM.                    " CALL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  fill_monat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_MONAT.

* E - Éves
  IF W_/ZAK/BEVALL-BIDOSZ = 'E'.
    P_MONAT = '12'.
  ENDIF.

* H - Havi
  IF W_/ZAK/BEVALL-BIDOSZ = 'H'.

  ENDIF.


* N - Negyedéves
  IF W_/ZAK/BEVALL-BIDOSZ = 'N'.

    IF P_MONAT <= '03'.
      P_MONAT   = '03'.
    ENDIF.

    IF P_MONAT >  '03' AND
       P_MONAT <= '06'.
      P_MONAT   = '06'.
    ENDIF.

    IF P_MONAT >  '06' AND
       P_MONAT <= '09'.
      P_MONAT   = '09'.
    ENDIF.

    IF P_MONAT >  '09' AND
       P_MONAT <= '12'.
      P_MONAT   = '12'.
    ENDIF.

  ENDIF.
ENDFORM.                    " fill_monat
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_BEVALL USING    P_BUKRS
                          P_BTART
                          P_BTYPE
                          V_LAST_DATE TYPE D.

  CLEAR W_/ZAK/BEVALL.
  SELECT * INTO TABLE I_/ZAK/BEVALL FROM  /ZAK/BEVALL
      WHERE     BUKRS  = P_BUKRS
         AND    BTYPART = P_BTART
         AND    DATBI  >= V_LAST_DATE
         AND    DATAB  < V_LAST_DATE.

  READ TABLE I_/ZAK/BEVALL INTO W_/ZAK/BEVALL
     WITH KEY BUKRS = P_BUKRS
              BTYPE = P_BTYPE.

ENDFORM.                    " READ_BEVALL
*&---------------------------------------------------------------------*
*&      Form  GET_LAST_DAY_OF_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LAST_DAY_OF_PERIOD USING    $GJAHR
                                     $MONAT
                             CHANGING V_LAST_DATE.

  DATA: L_DATE1 TYPE DATUM,
        L_DATE2 TYPE DATUM.

  CLEAR V_LAST_DATE.


  CONCATENATE $GJAHR $MONAT '01' INTO L_DATE1.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'  "#EC CI_USAGE_OK[2296016]
       EXPORTING
            DAY_IN            = L_DATE1
       IMPORTING
            LAST_DAY_OF_MONTH = L_DATE2
       EXCEPTIONS
            DAY_IN_NO_DATE    = 1
            OTHERS            = 2.

  IF SY-SUBRC = 0.
    V_LAST_DATE = L_DATE2.
  ENDIF.

ENDFORM.                    " GET_LAST_DAY_OF_PERIOD
*&---------------------------------------------------------------------*
*&      Form  fill_texts
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FILL_TEXTS.
* Pénznem
  IF I_LINES-WAERS_SRC IS INITIAL.
    I_LINES-WAERS_SRC = C_HUF.
  ENDIF.
  IF I_LINES-WAERS_DES IS INITIAL.
    I_LINES-WAERS_DES = C_HUF.
  ENDIF.
  IF I_LINES-WAERS_UTAL IS INITIAL.
    I_LINES-WAERS_UTAL = C_HUF.
  ENDIF.

* Adónem megnevezése - forrás
  IF NOT I_LINES-ADONEM_SRC IS INITIAL.

    SELECT SINGLE ADONEM_TXT INTO I_LINES-ADONEM_SRC_TXT
        FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = P_BUKRS
           AND    ADONEM  = I_LINES-ADONEM_SRC.
  ENDIF.

* Adónem megnevezése - cél
  IF NOT I_LINES-ADONEM_DES IS INITIAL.

    SELECT SINGLE ADONEM_TXT INTO I_LINES-ADONEM_DES_TXT
        FROM  /ZAK/ADONEMT
           WHERE  LANGU   = SY-LANGU
           AND    BUKRS   = P_BUKRS
           AND    ADONEM  = I_LINES-ADONEM_DES.
  ENDIF.

* Kiutalandó összeg
  IF NOT I_LINES-WRBTR_SRC IS INITIAL.
    I_LINES-WRBTR_UTAL = I_LINES-WRBTR_SRC - I_LINES-WRBTR_DES.
  ENDIF.

ENDFORM.                    " fill_texts
*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ENQUEUE_PERIOD.

  CALL FUNCTION 'ENQUEUE_/ZAK/EBEVALLSZ'
       EXPORTING
            MODE_/ZAK/BEVALLSZ = 'X'
            BUKRS             = P_BUKRS
            BTYPE             = P_BTYPE
            GJAHR             = P_GJAHR
            MONAT             = P_MONAT
            ZINDEX            = P_INDEX
       EXCEPTIONS
            FOREIGN_LOCK      = 1
            SYSTEM_FAILURE    = 2
            OTHERS            = 3.

  IF SY-SUBRC <> 0.
    MESSAGE W099(/ZAK/ZAK) WITH P_BUKRS P_BTYPE.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " ENQUEUE_PERIOD
