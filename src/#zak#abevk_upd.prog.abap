*&---------------------------------------------------------------------*
*& Program: ABEV azonosító kapcsolatok karbantartása
*&---------------------------------------------------------------------*
REPORT ZAD_ABEVK_UPD MESSAGE-ID /ZAK/ZAK.

*&---------------------------------------------------------------------*
*& Funkció leírás: A /ZAK/ABEVK karbantartásának megvalósítása
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - FMC
*& Létrehozás dátuma : 2006.03.18
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
* ABEVK tábla karbantartáshoz
TYPES: BEGIN OF T_ABEVK.
*++S4HANA#01.
*        INCLUDE STRUCTURE /ZAK/ABEVK.
*TYPES:  MARK,
         INCLUDE TYPE /ZAK/ABEVK.
TYPES:   MARK TYPE C,
*--S4HANA#01.
       END OF T_ABEVK.

DATA I_ABEVK TYPE T_ABEVK OCCURS 0.
*++S4HANA#01.
DATA: G_TC_ABEVK_WA2 LIKE LINE OF I_ABEVK.
*--S4HANA#01.
DATA W_ABEVK TYPE T_ABEVK.

DATA OK_CODE_100  LIKE SY-UCOMM.
DATA OK_CODE_SAVE LIKE SY-UCOMM.

*++S4HANA#01.
*DATA V_VIEW.
DATA V_VIEW TYPE C.
*--S4HANA#01.

*GUI státuszok tíltásához
TYPES: BEGIN OF T_STAB,
         FCODE LIKE RSMPE-FUNC,
       END OF T_STAB.
DATA: I_STAB TYPE STANDARD TABLE OF T_STAB WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      W_STAB TYPE T_STAB.

*Makró definiálása státusz töltéséhez
DEFINE M_STATUS.
  MOVE &1 TO W_STAB-FCODE.
  APPEND W_STAB TO I_STAB.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
*++1765 #19.
INITIALIZATION.
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
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Adatok szelektálása
  SELECT * INTO TABLE I_ABEVK                           "#EC CI_NOWHERE
           FROM /ZAK/ABEVK
*++S4HANA#01.
           ORDER BY PRIMARY KEY.
*--S4HANA#01.

* Karbantartó képernyő meghívása
  CALL SCREEN 0100.

*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '0100' EXCLUDING I_STAB.

  IF V_VIEW IS INITIAL.
    SET TITLEBAR  '100' WITH TEXT-001.
  ELSE.
    SET TITLEBAR  '100' WITH TEXT-002.
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*&spwizard: declaration of tablecontrol 'TC_ABEVK' itself
CONTROLS: TC_ABEVK TYPE TABLEVIEW USING SCREEN 0100.

*&spwizard: lines of tablecontrol 'TC_ABEVK'
DATA:     G_TC_ABEVK_LINES  LIKE SY-LOOPC.

*&spwizard: output module for tc 'TC_ABEVK'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE TC_ABEVK_CHANGE_TC_ATTR OUTPUT.
*++S4HANA#01.
*  DESCRIBE TABLE I_ABEVK LINES TC_ABEVK-LINES.
  TC_ABEVK-LINES = LINES( I_ABEVK ).
*--S4HANA#01.
ENDMODULE.

*&spwizard: output module for tc 'TC_ABEVK'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TC_ABEVK_GET_LINES OUTPUT.
  G_TC_ABEVK_LINES = SY-LOOPC.
ENDMODULE.

*&spwizard: input module for tc 'TC_ABEVK'. do not change this line!
*&spwizard: modify table
MODULE TC_ABEVK_MODIFY INPUT.
  MODIFY I_ABEVK
    FROM W_ABEVK
    INDEX TC_ABEVK-CURRENT_LINE.
ENDMODULE.

*&spwizard: input modul for tc 'TC_ABEVK'. do not change this line!
*&spwizard: mark table
MODULE TC_ABEVK_MARK INPUT.
*++S4HANA#01.
*  DATA: G_TC_ABEVK_WA2 LIKE LINE OF I_ABEVK.
*--S4HANA#01.
  IF TC_ABEVK-LINE_SEL_MODE = 1.
    LOOP AT I_ABEVK INTO G_TC_ABEVK_WA2
      WHERE MARK = 'X'.
      G_TC_ABEVK_WA2-MARK = ''.
      MODIFY I_ABEVK
        FROM G_TC_ABEVK_WA2
        TRANSPORTING MARK.
    ENDLOOP.
  ENDIF.
  MODIFY I_ABEVK
    FROM W_ABEVK
    INDEX TC_ABEVK-CURRENT_LINE
    TRANSPORTING MARK.
ENDMODULE.

*&spwizard: input module for tc 'TC_ABEVK'. do not change this line!
*&spwizard: process user command
MODULE TC_ABEVK_USER_COMMAND INPUT.
  OK_CODE_100 = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_ABEVK'
                              'I_ABEVK'
                              'MARK'
                     CHANGING OK_CODE_100.
  SY-UCOMM = OK_CODE_100.
ENDMODULE.

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
*++S4HANA#01.
*                         P_TABLE_NAME
*                         P_MARK_NAME
                         P_TABLE_NAME TYPE CLIKE
                         P_MARK_NAME TYPE CLIKE
*--S4HANA#01.
                CHANGING P_OK      LIKE SY-UCOMM.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA: L_OK     TYPE SY-UCOMM,
        L_OFFSET TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
* execute general and TC specific operations                           *
  CASE L_OK.
    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_INSERT_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
*++S4HANA#01.
*                       P_TABLE_NAME             .
                       P_TABLE_NAME TYPE CLIKE.
*--S4HANA#01.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* get looplines of TableControl
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

* get current line
  GET CURSOR LINE L_SELLINE.
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line and new cursor line                           *
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
* insert initial line
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
* set cursor
  SET CURSOR LINE L_LINE.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_DELETE_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
*++S4HANA#01.
*                       P_TABLE_NAME
*                       P_MARK_NAME   .
                       P_TABLE_NAME TYPE CLIKE
                       P_MARK_NAME TYPE CLIKE.
*--S4HANA#01.


*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
*++S4HANA#01.
*  FIELD-SYMBOLS <WA>.
*  FIELD-SYMBOLS <MARK_FIELD>.
  FIELD-SYMBOLS <WA>         TYPE ANY.
  FIELD-SYMBOLS <MARK_FIELD> TYPE ANY.
*--S4HANA#01.

*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* delete marked lines                                                  *
*++S4HANA#01.
*  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
  <TC>-LINES = LINES( <TABLE> ).
*--S4HANA#01.

  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    IF <MARK_FIELD> = 'X'.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
*                                      P_OK.
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME TYPE DYNFNAM
                                      P_OK TYPE SY-UCOMM.
*--S4HANA#01.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <LINES>      TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
* get looplines of TableControl
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


* is no line filled?                                                   *
  IF <TC>-LINES = 0.
*   yes, ...                                                           *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        ENTRY_ACT      = <TC>-TOP_LINE
        ENTRY_FROM     = 1
        ENTRY_TO       = <TC>-LINES
        LAST_PAGE_FULL = 'X'
        LOOPS          = <LINES>
        OK_CODE        = P_OK
        OVERLAPPING    = 'X'
      IMPORTING
        ENTRY_NEW      = L_TC_NEW_TOP_LINE
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
*     set actual column                                                *
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM FCODE_TC_MARK_LINES USING P_TC_NAME
*                               P_TABLE_NAME
*                               P_MARK_NAME.
FORM FCODE_TC_MARK_LINES USING P_TC_NAME TYPE DYNFNAM
                               P_TABLE_NAME TYPE CLIKE
                               P_MARK_NAME TYPE CLIKE.
*--S4HANA#01.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
*++S4HANA#01.
*  FIELD-SYMBOLS <WA>.
*  FIELD-SYMBOLS <MARK_FIELD>.
  FIELD-SYMBOLS <WA>         TYPE ANY.
  FIELD-SYMBOLS <MARK_FIELD> TYPE ANY.
*--S4HANA#01.

*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
*++S4HANA#01.
*FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
*                                 P_TABLE_NAME
*                                 P_MARK_NAME .
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME TYPE DYNFNAM
                                 P_TABLE_NAME TYPE CLIKE
                                 P_MARK_NAME TYPE CLIKE .
*--S4HANA#01.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
*++S4HANA#01.
*  FIELD-SYMBOLS <WA>.
*  FIELD-SYMBOLS <MARK_FIELD>.
    FIELD-SYMBOLS <WA>       TYPE ANY.
  FIELD-SYMBOLS <MARK_FIELD> TYPE ANY.
*--S4HANA#01.

*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Module  CHECK_BTYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BTYPE INPUT.

*BTYPE ellenőrzése
  SELECT COUNT( * ) FROM /ZAK/BEVALL
                   WHERE BTYPE EQ W_ABEVK-BTYPE.
  IF SY-SUBRC NE 0.
    MESSAGE E120 WITH W_ABEVK-BTYPE.
*   & bevallás típus nem létezik!
  ENDIF.

ENDMODULE.                 " CHECK_BTYPE  INPUT
