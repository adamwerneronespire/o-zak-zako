*&---------------------------------------------------------------------*
*& Program: SZJA XML migráció feltöltés
*&---------------------------------------------------------------------*
REPORT /ZAK/MIGR_SZJA_SEL MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás: __________________
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor
*& Létrehozás dátuma : 2018.12.06
*& Funkc.spec.készítő: Balázs Gábor
*& SAP modul neve    : ADO
*& Program  típus    : ________
*& SAP verzió        : ________
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*
*&
*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS
*& ----   ----------   ----------     ---------------------- -----------
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE: /ZAK/READ_TOP.
INCLUDE EXCEL__C.
INCLUDE <ICON>.
*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: BKPF,
        T001,
        DD02L.
*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.
*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_CLASS       TYPE DD02L-TABCLASS VALUE 'INTTAB',
           C_A           TYPE C VALUE 'A',
* file típusok
           C_FILE_XLS(2) TYPE C VALUE   '02',
           C_FILE_TXT(2) TYPE C VALUE   '01',
           C_FILE_XML(2) TYPE C VALUE   '03',
           C_FILE_SAP(2) TYPE C VALUE   '04',
*++PTGSZLAA 2014.03.04 BG (Ness)
           C_FILE_CSV(2) TYPE C VALUE   '05',
*--PTGSZLAA 2014.03.04 BG (Ness)
* excel betöltéshez
           C_END_ROW     TYPE I VALUE '65536',
           C_BEGIN_ROW   TYPE I VALUE    '1',
* file ellenörzése
           C_FILE_X(1)   TYPE C VALUE    'X',
* analitika adatszerkezet
           C_ANALITIKA   LIKE /ZAK/BEVALLD-STRNAME VALUE '/ZAK/ANALITIKA'.
*++BG 2007.02.12
*++1565 #10.
* CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 5000.
CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 9000.
*--1565 #10.
*--BG 2007.02.12
*++PTGSZLAA #01. 2014.03.03
CONSTANTS: C_PTGSZLAA  TYPE /ZAK/BTYPE VALUE 'PTGSZLAA'.
*--PTGSZLAA #01. 2014.03.03
*++1865 #10.
CONSTANTS: C_PTGSZLAH  TYPE /ZAK/BTYPE VALUE 'PTGSZLAH'.
*--1865 #10.
*type: begin of line
*&---------------------------------------------------------------------*
*& Munkaterület  (W_XXX..)                                           *
*&---------------------------------------------------------------------*
* struktúra ellenőrzése
DATA: W_DD02L TYPE DD02L.
* excel betöltéshez
DATA: W_XLS      TYPE ALSMEX_TABLINE,
      W_DD03P    TYPE DD03P,
      W_MAIN_STR TYPE DD03P,
      WA_DD03P   TYPE DD03P,
      W_LINE     TYPE /ZAK/LINE.
DATA: W_OUTTAB  TYPE /ZAK/ANALITIKA,
      W_BEVALLI TYPE /ZAK/BEVALLI,
      W_ELSO    TYPE /ZAK/BEVALLI.
* adatszerkezet hiba
DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.
DATA: BEGIN OF GT_OUTTAB OCCURS 0.
        INCLUDE STRUCTURE /ZAK/ANALITIKA.
DATA: LIGHT TYPE C.
DATA: END OF GT_OUTTAB.
DATA: G_LIGHTS_NAME TYPE LVC_CIFNM VALUE 'LIGHT'.
* message
DATA: W_MESSAGE TYPE BAPIRET2.
*&---------------------------------------------------------------------*
*& BELSŐ TÁBLÁK  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
DATA: I_XLS      TYPE STANDARD TABLE OF ALSMEX_TABLINE
                                                      INITIAL SIZE 0,
      I_DD03P    TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0,
      I_MAIN_STR TYPE STANDARD TABLE OF DD03P       INITIAL SIZE 0.
DATA: I_OUTTAB    TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
      I_OUTTAB_EX TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
* bevallási időszakok
DATA: I_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0,
      I_ELSO    TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0.
* Hiba adaszerkezet tábla
DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
DATA: I_LINE TYPE STANDARD TABLE OF /ZAK/LINE            INITIAL SIZE 0.
* message
DATA: E_MESSAGE TYPE STANDARD TABLE OF BAPIRET2     INITIAL SIZE 0.
*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Globális változók   -   (V_xxx...)                              *
*      Munkaterület        -   (W_xxx...)                              *
*      Típus               -   (T_xxx...)                              *
*      Makrók              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Osztály             -   (CL_xxx...)                             *
*      Esemény             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA: V_WRBTR       LIKE BSEG-WRBTR,
      V_WRBTR_C(16).
DATA: V_DATUM      LIKE SY-DATUM,
      V_DATUMC(10) TYPE C.
DATA: V_TABIX LIKE SY-TABIX,
      V_SUBRC LIKE SY-SUBRC.
* változók
DATA: V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.
* szelekciós képernyő
DATA: V_BUTXT   LIKE T001-BUTXT.
DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
      V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.
* excel betöltéshez
DATA: V_BEGIN_COL TYPE I,
      V_END_COL   TYPE I.
* képernyőre
DATA: V_SCR1(70) TYPE C,
      V_SCR2(70) TYPE C,
      V_SCR3(70) TYPE C,
      V_SCR4(70) TYPE C.
* ALV kezelési változók
DATA: V_OK_CODE           LIKE SY-UCOMM,
      V_SAVE_OK           LIKE SY-UCOMM,
      V_REPID             LIKE SY-REPID,
      V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CONTAINER2        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',
      V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
      V_GRID2             TYPE REF TO CL_GUI_ALV_GRID,
      V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      V_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      I_FIELDCAT          TYPE LVC_T_FCAT,
      I_FIELDCAT2         TYPE LVC_T_FCAT,
      V_LAYOUT            TYPE LVC_S_LAYO,
      V_LAYOUT2           TYPE LVC_S_LAYO,
      V_VARIANT           TYPE DISVARIANT,
      V_VARIANT2          TYPE DISVARIANT,
      V_TOOLBAR           TYPE STB_BUTTON,
      V_DYNDOC_ID         TYPE REF TO CL_DD_DOCUMENT,
*      V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
*      V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER,
      V_STRUC             TYPE DD02L-TABNAME.
* popup üzenethez
DATA: V_TEXT1(40) TYPE C,
      V_TEXT2(40) TYPE C,
      V_TITEL     TYPE C,
      V_ANSWER.
* file ellenörzése
DATA: LV_ACTIVE TYPE ABAP_BOOL.
DATA: V_WNUM(30) TYPE N,
      V_WAERS    LIKE T001-WAERS.
*++BG 2007.02.12
DATA: V_XLS_LINE TYPE SY-TABIX VALUE 5000.
*--BG 2007.02.12
* field symbol
FIELD-SYMBOLS <FS> TYPE ANY.
*++0002 BG 2007.07.02
*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.
*--0002 BG 2007.07.02
*&---------------------------------------------------------------------*
*& PARAMÉTEREK  (P_XXXXXXX..)                                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SZELEKT-OPCIÓK (S_XXXXXXX..)                                        *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.

PARAMETERS: P_BUKRS LIKE /ZAK/BEVALL-BUKRS VALUE CHECK
                         OBLIGATORY MEMORY ID BUK.
PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE OBLIGATORY.
PARAMETERS: P_GJAHR TYPE GJAHR OBLIGATORY.
PARAMETERS: P_MONAT TYPE MONAT OBLIGATORY.

PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
                          MATCHCODE OBJECT /ZAK/BEVD
                          OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B01.


************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

* Szelekció
  PERFORM SEL_DATA.
  IF I_OUTTAB[] IS INITIAL.
    MESSAGE I141.
*   Nincs a feltételnek megfelelő analitika rekord!
    EXIT.
  ENDIF.

  PERFORM UPD_DATA.

************************************************************************
* END-OF-SELECTION
***********************************************************************
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  SEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEL_DATA .

  FIELD-SYMBOLS <DATA> TYPE /ZAK/ANALITIKA.


  SELECT * INTO TABLE I_OUTTAB
           FROM /ZAK/MIGR_ANAL
          WHERE BUKRS EQ P_BUKRS
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT.

  LOOP AT I_OUTTAB ASSIGNING <DATA> WHERE BSZNUM NE P_BSZNUM.
    <DATA>-BSZNUM = P_BSZNUM.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPD_DATA .




  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = P_BUKRS
      I_BTYPE     = P_BTYPE
*     I_BTYPART   = W_/ZAK/BEVALL-BTYPART
      I_BSZNUM    = P_BSZNUM
*     I_PACK      = P_PACK
      I_GEN       = 'X'
      I_TEST      = ''
*     I_FILE      = P_FDIR
    TABLES
      I_ANALITIKA = I_OUTTAB
*     I_AFA_SZLA  = I_/ZAK/AFA_SZLA
      E_RETURN    = E_MESSAGE.
*   Üzenetek kezelése
  IF NOT E_MESSAGE[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = E_MESSAGE.
  ENDIF.

ENDFORM.
