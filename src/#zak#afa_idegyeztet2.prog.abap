*&---------------------------------------------------------------------*
*& Program: Áfa bevallás egyeztető (APEH) lista
*----------------------------------------------------------------------*
 REPORT /ZAK/AFA_IDEGYEZTET2 MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Funkció leírás:
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor
*& Létrehozás dátuma : 2006.08.01
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

 INCLUDE /ZAK/AFA_TOP.
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*





*&---------------------------------------------------------------------*
*& BELSŐ TÁBLÁK  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
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
 DATA V_GJAHR TYPE GJAHR.
 DATA V_MONAT_FROM TYPE MONAT.
 DATA V_MONAT_TO   TYPE MONAT.
 DATA V_BTYPE TYPE /ZAK/BTYPE.

 DATA V_SUBRC LIKE SY-SUBRC.

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
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER.

*++BG 2006.09.15
*++S4HANA#01.
* RANGES R_ABEV1 FOR /ZAK/BEVALLB-ABEVAZ.
* RANGES R_ABEV2 FOR /ZAK/BEVALLB-ABEVAZ.
 TYPES TT_ABEV1 TYPE RANGE OF /ZAK/BEVALLB-ABEVAZ.
 DATA GT_ABEV1 TYPE TT_ABEV1.
 DATA GS_ABEV1 TYPE LINE OF TT_ABEV1.
 TYPES TT_ABEV2 TYPE RANGE OF /ZAK/BEVALLB-ABEVAZ.
 DATA GT_ABEV2 TYPE TT_ABEV2.
 DATA GS_ABEV2 TYPE LINE OF TT_ABEV2.
*--S4HANA#01.

*MAKRO definiálás range feltöltéshez
 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   APPEND &1.
 END-OF-DEFINITION.
*--BG 2006.09.15

*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
 SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-A01.
     PARAMETERS: P_BUKRS  LIKE T001-BUKRS VALUE CHECK "DEFAULT 'MA01'
                               OBLIGATORY MEMORY ID BUK.
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID HID.
   SELECTION-SCREEN END OF LINE.
   SELECT-OPTIONS: S_DATUM FOR /ZAK/BSET-BUPER NO-EXTENSION
                           OBLIGATORY.
 SELECTION-SCREEN: END OF BLOCK BL01.

*++BG 2006.09.15
 SELECTION-SCREEN: BEGIN OF BLOCK BL02 WITH FRAME TITLE TEXT-T02.
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(79) TEXT-001.
   SELECTION-SCREEN END OF LINE.

   SELECTION-SCREEN SKIP.

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-A02.
     PARAMETERS: P_ABEV1 LIKE /ZAK/BEVALLB-ABEVAZ DEFAULT '6242' OBLIGATORY.
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_ABEVT1 TYPE /ZAK/ABEVTEXT MODIF ID HID.
   SELECTION-SCREEN END OF LINE.

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT 01(31) TEXT-A03.
     PARAMETERS: P_ABEV2 LIKE /ZAK/BEVALLB-ABEVAZ DEFAULT '6277' OBLIGATORY.
     SELECTION-SCREEN POSITION 50.
     PARAMETERS: P_ABEVT2 TYPE /ZAK/ABEVTEXT MODIF ID HID.
   SELECTION-SCREEN END OF LINE.

 SELECTION-SCREEN: END OF BLOCK BL02.
*--BG 2006.09.15

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
 INITIALIZATION.
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

************************************************************************
* AT SELECTION-SCREEN output
************************************************************************



*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
 AT SELECTION-SCREEN OUTPUT.
   PERFORM MODIF_SCREEN.

 AT SELECTION-SCREEN ON P_BUTXT.
   PERFORM FIELD_DESCRIPT.

*++BG 2006.09.15
 AT SELECTION-SCREEN ON P_ABEVT1.
   PERFORM GET_ABEV_TEXT USING P_ABEV1
                      CHANGING P_ABEVT1.

 AT SELECTION-SCREEN ON P_ABEVT2.
   PERFORM GET_ABEV_TEXT USING P_ABEV2
                      CHANGING P_ABEVT2.

*--BG 2006.09.15

 AT SELECTION-SCREEN.
   PERFORM SEL_CHECK.


*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 CLASS LCL_EVENT_RECEIVER DEFINITION.

   PUBLIC SECTION.


     CLASS-METHODS:
       HANDLE_DOUBLE_CLICK
         FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW
                   E_COLUMN
                   ES_ROW_NO,

       HANDLE_HOTSPOT_CLICK
         FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW_ID
                   E_COLUMN_ID
                   ES_ROW_NO.


*    HANDLE_USER_COMMAND
*        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
*             IMPORTING E_UCOMM.



   PRIVATE SECTION.
     DATA: ERROR_IN_DATA TYPE C.

 ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
 CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

*---------------------------------------------------------------------*
*       METHOD double_click                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_DOUBLE_CLICK.
     PERFORM D9000_EVENT_DOUBLE_CLICK USING E_ROW
                                            E_COLUMN.
   ENDMETHOD.     "double_click

*---------------------------------------------------------------------*
*       METHOD hotspot_click                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_HOTSPOT_CLICK.

     IF SY-DYNNR = '9001'.
       PERFORM D9001_EVENT_HOTSPOT_CLICK USING E_ROW_ID
                                               E_COLUMN_ID.

     ENDIF.
   ENDMETHOD.                    "hotspot_click



 ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION



*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
 START-OF-SELECTION.
*  Jogosultság vizsgálat
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 C_BTYPART_AFA
                                 C_ACTVT_01.
*  Egyéb adatok meghatározása
   PERFORM GET_OTHERS_DATA.

*++BG 2006.09.15
*  Fizetendő, levonandó ABEV azonosítók meghetározása
*++S4HANA#01.
*   PERFORM GET_RANGE_ABEVAZ: TABLES R_ABEV1
   PERFORM GET_RANGE_ABEVAZ: TABLES GT_ABEV1
*--S4HANA#01.
                          USING  V_BTYPE
                                 P_ABEV1,
*++S4HANA#01.
*                          TABLES R_ABEV2
                          TABLES GT_ABEV2
*--S4HANA#01.
                          USING  V_BTYPE
                                 P_ABEV2.
* Ha üres a fizetendő ÁFA adó összege range
*++S4HANA#01.
*   IF R_ABEV1[] IS INITIAL.
   IF GT_ABEV1[] IS INITIAL.
*--S4HANA#01.
     MESSAGE I195.
*  Nem lehet ABEV azonosítókat meghatározni a fizetendő adó összesenhez
     EXIT.
   ENDIF.

* Ha üres a levonandó ÁFA adó összege range
*++S4HANA#01.
*   IF R_ABEV2[] IS INITIAL.
   IF GT_ABEV2[] IS INITIAL.
*--S4HANA#01.
     MESSAGE I196.
*  Nem lehet ABEV azonosítókat meghatározni a levonandó adó összesenhez!
     EXIT.
   ENDIF.
*--BG 2006.09.15


*  Adat szelekció
*++S4HANA#01.
*   PERFORM SEL_/ZAK/ANALITIKA USING V_SUBRC.
   PERFORM SEL_/ZAK/ANALITIKA CHANGING V_SUBRC.
*--S4HANA#01.
   IF NOT V_SUBRC IS INITIAL.
     MESSAGE I031.
*    Adatbázis nem tartalmaz feldolgozható rekordot!
     EXIT.
   ENDIF.

*++1665 #11.
   PERFORM FILL_LOG USING  P_BUKRS
                           I_OUTTAB2[].
*--1665 #11.


 END-OF-SELECTION.
   PERFORM ALV_LIST.


************************************************************************
*                             ALPROGRAMOK
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  MODIF_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MODIF_SCREEN.
   LOOP AT SCREEN.
     IF SCREEN-GROUP1 = 'HID'.
       SCREEN-INPUT = 0.
       SCREEN-OUTPUT = 1.
       SCREEN-DISPLAY_3D = 0.
     ENDIF.
     MODIFY SCREEN.
   ENDLOOP.


 ENDFORM.                    " MODIF_SCREEN
*
*&---------------------------------------------------------------------*
*&      Form  SEL_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM SEL_/ZAK/ANALITIKA USING $SUBRC.
 FORM SEL_/ZAK/ANALITIKA CHANGING $SUBRC TYPE SY-SUBRC.
*--S4HANA#01.

   CLEAR $SUBRC.

*++BG 2006.09.15
*++S4HANA#01.
*   SELECT * INTO W_/ZAK/ANALITIKA
   SELECT GJAHR MONAT ZINDEX ABEVAZ BSZNUM WAERS BSEG_BELNR BUDAT BLDAT ZFBDT HKONT FIELD_C
       FIELD_N INTO CORRESPONDING FIELDS OF W_/ZAK/ANALITIKA
*--S4HANA#01.
             FROM /ZAK/ANALITIKA
            WHERE BUKRS EQ P_BUKRS
             AND  BTYPE EQ V_BTYPE
             AND  GJAHR EQ V_GJAHR
             AND  MONAT GE V_MONAT_FROM
             AND  MONAT LE V_MONAT_TO
*++S4HANA#01.
*             AND ( ABEVAZ IN R_ABEV1 OR
*                   ABEVAZ IN R_ABEV2 ).
             AND ( ABEVAZ IN GT_ABEV1 OR
                   ABEVAZ IN GT_ABEV2 ).
*--S4HANA#01.
*  Belső tábla feltöltés
     CLEAR W_OUTTAB2.
     W_OUTTAB2-GJAHR = W_/ZAK/ANALITIKA-BUDAT(4).
     W_OUTTAB2-MONAT = W_/ZAK/ANALITIKA-BUDAT+4(2).
*++BG 2006.12.20
     W_OUTTAB2-ZINDEX = W_/ZAK/ANALITIKA-ZINDEX.
*--BG 2006.12.20
     CONCATENATE W_/ZAK/ANALITIKA-GJAHR
                 W_/ZAK/ANALITIKA-MONAT INTO W_OUTTAB2-BUPER.
     MOVE W_/ZAK/ANALITIKA-BSZNUM  TO W_OUTTAB2-BSZNUM.
     MOVE W_/ZAK/ANALITIKA-FIELD_N TO W_OUTTAB2-DMBTR.
     MOVE W_/ZAK/ANALITIKA-WAERS   TO W_OUTTAB2-WAERS.

*++S4HANA#01.
*     IF W_/ZAK/ANALITIKA-ABEVAZ IN R_ABEV2.
     IF W_/ZAK/ANALITIKA-ABEVAZ IN GT_ABEV2.
*--S4HANA#01.
       MULTIPLY W_OUTTAB2-DMBTR BY -1.
     ENDIF.
*--BG 2006.09.15
     COLLECT W_OUTTAB2 INTO I_OUTTAB2.
   ENDSELECT.
   IF SY-SUBRC NE 0.
     MOVE SY-SUBRC TO $SUBRC.
   ENDIF.

 ENDFORM.                    " SEL_/ZAK/ANALITIKA
*&---------------------------------------------------------------------*
*&      Form  FIELD_DESCRIPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FIELD_DESCRIPT.

   IF NOT P_BUKRS IS INITIAL.
*++S4HANA#01.
*     SELECT SINGLE *  FROM T001
     SELECT SINGLE *  FROM T001 INTO T001
*--S4HANA#01.
           WHERE BUKRS = P_BUKRS.
     P_BUTXT = T001-BUTXT.
   ENDIF.

 ENDFORM.                    " FIELD_DESCRIPT
*&---------------------------------------------------------------------*
*&      Form  GET_OTHERS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_OTHERS_DATA.

*  Év, hónap meghatározás
   V_GJAHR      = S_DATUM-LOW(4).
   V_MONAT_FROM = S_DATUM-LOW+4(2).
   V_MONAT_TO   = S_DATUM-HIGH+4(2).

*  BTYPE meghatározása
   CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
     EXPORTING
       I_BUKRS     = P_BUKRS
       I_BTYPART   = C_BTYPART_AFA
       I_GJAHR     = V_GJAHR
       I_MONAT     = V_MONAT_FROM
     IMPORTING
       E_BTYPE     = V_BTYPE
     EXCEPTIONS
       ERROR_MONAT = 1
       ERROR_BTYPE = 2
       OTHERS      = 3.
   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " GET_OTHERS_DATA
*&---------------------------------------------------------------------*
*&      Form  SEL_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SEL_CHECK.
*  Éven belüli intervallum ellenőrzése
   IF NOT S_DATUM-HIGH IS INITIAL AND
      S_DATUM-LOW(4) NE S_DATUM-HIGH(4).
     MESSAGE E193.
*     Kérem az intervallumot egy éven belül adja meg!
   ENDIF.

*  Felső érték kitöltése ha üres
   IF S_DATUM-HIGH IS INITIAL AND NOT S_DATUM-LOW IS INITIAL.
     MOVE S_DATUM-LOW TO S_DATUM-HIGH.
*++S4HANA#01.
*     MODIFY S_DATUM INDEX 1.
     MODIFY S_DATUM FROM S_DATUM INDEX 1.
*--S4HANA#01.
   ENDIF.

 ENDFORM.                    " SEL_CHECK
*&---------------------------------------------------------------------*
*&      Form  ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ALV_LIST.
* ALV lista
   CALL SCREEN 9000.

 ENDFORM.                    " ALV_LIST

*&---------------------------------------------------------------------
*
*&      Form  d9000_event_double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
 FORM D9000_EVENT_DOUBLE_CLICK USING   $ROW    TYPE LVC_S_ROW
                                       $COLUMN TYPE LVC_S_COL.

   IF SY-DYNNR EQ '9000' AND NOT $ROW IS INITIAL.
*++S4HANA#01.
*     REFRESH I_ITEM2.
     CLEAR I_ITEM2[].
*--S4HANA#01.
     CLEAR W_ITEM2.
*  a kijelölt sorhoz tartozó bizonylatok megjelenítése
     READ TABLE I_OUTTAB2 INTO W_OUTTAB2 INDEX $ROW.
     IF SY-SUBRC EQ 0.
*      Tételes adatok meghatározása
*++S4HANA#01.
*       SELECT * INTO W_/ZAK/ANALITIKA
       SELECT GJAHR MONAT ZINDEX ABEVAZ BSZNUM WAERS BSEG_BELNR BUDAT BLDAT ZFBDT HKONT FIELD_C
           FIELD_N INTO CORRESPONDING FIELDS OF W_/ZAK/ANALITIKA
*--S4HANA#01.
              FROM /ZAK/ANALITIKA
             WHERE BUKRS  EQ  P_BUKRS
               AND BTYPE  EQ  V_BTYPE
               AND GJAHR  EQ  W_OUTTAB2-BUPER(4)
               AND MONAT  EQ  W_OUTTAB2-BUPER+4(2)
*++BG 2006.12.20
               AND ZINDEX EQ  W_OUTTAB2-ZINDEX
*--BG 2006.12.20
               AND BSZNUM EQ  W_OUTTAB2-BSZNUM.
*        Csak ha egyezik a BUDAT
         CHECK W_/ZAK/ANALITIKA-BUDAT(4)   EQ W_OUTTAB2-GJAHR AND
               W_/ZAK/ANALITIKA-BUDAT+4(2) EQ W_OUTTAB2-MONAT AND
               W_/ZAK/ANALITIKA-FIELD_C IS INITIAL.
*        Adatok feltöltése
*++ BG 2007.01.31
         MOVE W_/ZAK/ANALITIKA-ABEVAZ TO W_ITEM2-ABEVAZ.
         PERFORM GET_ABEV_TEXT USING W_ITEM2-ABEVAZ
                            CHANGING W_ITEM2-ABEVTEXT.
*-- BG 2007.01.31
         MOVE W_/ZAK/ANALITIKA-HKONT TO W_ITEM2-HKONT.
         MOVE W_/ZAK/ANALITIKA-BSEG_BELNR TO W_ITEM2-BELNR.
         MOVE W_/ZAK/ANALITIKA-BSZNUM TO W_ITEM2-BSZNUM.
         MOVE W_OUTTAB2-GJAHR TO W_ITEM2-GJAHR.
         MOVE W_/ZAK/ANALITIKA-FIELD_N TO W_ITEM2-DMBTR.
         MOVE W_/ZAK/ANALITIKA-BUDAT TO W_ITEM2-BUDAT.
         MOVE W_/ZAK/ANALITIKA-BLDAT TO W_ITEM2-BLDAT.
         MOVE W_/ZAK/ANALITIKA-ZFBDT TO W_ITEM2-ZFBDT.
         MOVE W_OUTTAB2-BUPER TO W_ITEM2-BUPER.
         MOVE W_OUTTAB2-WAERS TO W_ITEM2-WAERS.
         APPEND W_ITEM2 TO I_ITEM2.
       ENDSELECT.
     ENDIF.
*    Ha van adat.
     IF NOT I_ITEM2[] IS INITIAL.
       CALL SCREEN 9001.
     ENDIF.
   ENDIF.


 ENDFORM.                    " d9000_event_double_click

*&---------------------------------------------------------------------
*
*&      Form  D9001_EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
 FORM D9001_EVENT_HOTSPOT_CLICK USING $ROW_ID    TYPE LVC_S_ROW
                                      $COLUMN_ID TYPE LVC_S_COL.

   DATA: LS_OUT   TYPE /ZAK/EGY2_TETALV.

   READ TABLE I_ITEM2 INTO W_ITEM2 INDEX $ROW_ID.

   IF SY-SUBRC = 0.
     CASE $COLUMN_ID.
       WHEN 'BELNR'.

         IF NOT W_ITEM2-GJAHR IS INITIAL AND
            NOT W_ITEM2-BELNR IS INITIAL.

           SET PARAMETER ID 'BUK' FIELD P_BUKRS.
           SET PARAMETER ID 'GJR' FIELD W_ITEM2-GJAHR.
           SET PARAMETER ID 'BLN' FIELD W_ITEM2-BELNR.

           CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " d9001_event_hotspot_click
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9000 OUTPUT.

   PERFORM SET_STATUS.

   IF V_CUSTOM_CONTAINER IS INITIAL.
     PERFORM CREATE_AND_INIT_ALV CHANGING I_OUTTAB2[]
                                          I_FIELDCAT
                                          V_LAYOUT
                                          V_VARIANT.
   ENDIF.


 ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_STATUS.

   TYPES: BEGIN OF TAB_TYPE,
            FCODE LIKE RSMPE-FUNC,
          END OF TAB_TYPE.

   DATA: TAB    TYPE STANDARD TABLE OF TAB_TYPE WITH
                  NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
         WA_TAB TYPE TAB_TYPE.

   IF SY-DYNNR = '9000'.
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9000'.
   ELSEIF SY-DYNNR = '9001'.
     SET PF-STATUS 'MAIN9001' EXCLUDING TAB.
     SET TITLEBAR  'MAIN9001'.
   ENDIF.

 ENDFORM.                    " SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB2[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV CHANGING $I_OUTTAB2  LIKE I_OUTTAB2[]
                                   $I_FIELDCAT TYPE LVC_T_FCAT
                                   $LAYOUT     TYPE LVC_S_LAYO
                                   $VARIANT    TYPE DISVARIANT.

   DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.


   CREATE OBJECT V_CUSTOM_CONTAINER
     EXPORTING
       CONTAINER_NAME = V_CONTAINER.
   CREATE OBJECT V_GRID
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER.


* Mezőkatalógus összeállítása
   PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                          CHANGING $I_FIELDCAT.

   $LAYOUT-CWIDTH_OPT = 'X'.
   $LAYOUT-SEL_MODE = 'A'.

   CLEAR $VARIANT.
   $VARIANT-REPORT = SY-REPID.

   CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT           = $VARIANT
       I_SAVE               = 'A'
       I_DEFAULT            = 'X'
       IS_LAYOUT            = $LAYOUT
       IT_TOOLBAR_EXCLUDING = LI_EXCLUDE
     CHANGING
       IT_FIELDCATALOG      = $I_FIELDCAT
       IT_OUTTAB            = $I_OUTTAB2.

   CREATE OBJECT V_EVENT_RECEIVER.
   SET HANDLER V_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK  FOR V_GRID.

   CALL METHOD V_GRID->SET_TOOLBAR_INTERACTIVE.



 ENDFORM.                    " CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_DYNNR  text
*      <--P_$I_FIELDCAT  text
*----------------------------------------------------------------------*
 FORM BUILD_FIELDCAT USING    $DYNNR      LIKE SYST-DYNNR
                     CHANGING $T_FIELDCAT TYPE LVC_T_FCAT.

   DATA: LS_FCAT TYPE LVC_S_FCAT.

*  Összesített lista:
   IF $DYNNR = '9000'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/EGYEZT2_ALV'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = $T_FIELDCAT.


*  Tételes lista:
   ELSEIF $DYNNR = '9001'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/EGY2_TETALV'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = $T_FIELDCAT.

     LOOP AT $T_FIELDCAT INTO LS_FCAT.
       IF LS_FCAT-FIELDNAME = 'BELNR'.
         LS_FCAT-HOTSPOT = 'X'.
         MODIFY $T_FIELDCAT FROM LS_FCAT.
       ENDIF.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9000 INPUT.

   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.

   CASE V_SAVE_OK.
* Vissza
     WHEN 'BACK'.
       SET SCREEN 0.
       LEAVE SCREEN.
* Kilépés
     WHEN 'EXIT'.
       PERFORM EXIT_PROGRAM.

     WHEN OTHERS.
*     do nothing
   ENDCASE.


 ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXIT_PROGRAM.
   LEAVE PROGRAM.
 ENDFORM.                    " EXIT_PROGRAM
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE STATUS_9001 OUTPUT.
   PERFORM SET_STATUS.

   IF V_CUSTOM_CONTAINER2 IS INITIAL.
     PERFORM CREATE_AND_INIT_ALV2 CHANGING I_ITEM2[]
                                           I_FIELDCAT2
                                           V_LAYOUT2
                                           V_VARIANT2.
   ELSE.
     CALL METHOD V_GRID2->REFRESH_TABLE_DISPLAY.
   ENDIF.


 ENDMODULE.                 " STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_ITEM2[]  text
*      <--P_I_FIELDCAT2  text
*      <--P_V_LAYOUT2  text
*      <--P_V_VARIANT2  text
*----------------------------------------------------------------------*
 FORM CREATE_AND_INIT_ALV2 CHANGING $I_ITEM     LIKE I_ITEM2[]
                                    $I_FIELDCAT TYPE LVC_T_FCAT
                                    $LAYOUT   TYPE LVC_S_LAYO
                                    $VARIANT  TYPE DISVARIANT.

   DATA: LI_EXCLUDE TYPE UI_FUNCTIONS.
   CREATE OBJECT V_CUSTOM_CONTAINER2
     EXPORTING
       CONTAINER_NAME = V_CONTAINER2.
   CREATE OBJECT V_GRID2
     EXPORTING
       I_PARENT = V_CUSTOM_CONTAINER2.

* Mezőkatalógus összeállítása
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING $I_FIELDCAT.

   $LAYOUT-CWIDTH_OPT = 'X'.
*  allow to select multiple lines
   $LAYOUT-SEL_MODE = 'B'.


   CLEAR $VARIANT.
   $VARIANT-REPORT = SY-REPID.

   CALL METHOD V_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
     EXPORTING
       IS_VARIANT           = $VARIANT
       I_SAVE               = 'A'
       I_DEFAULT            = 'X'
       IS_LAYOUT            = $LAYOUT
       IT_TOOLBAR_EXCLUDING = LI_EXCLUDE
     CHANGING
       IT_FIELDCATALOG      = $I_FIELDCAT
       IT_OUTTAB            = $I_ITEM.

   CREATE OBJECT V_EVENT_RECEIVER2.
   SET HANDLER V_EVENT_RECEIVER2->HANDLE_HOTSPOT_CLICK FOR V_GRID2.


 ENDFORM.                    " CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE USER_COMMAND_9001 INPUT.

   V_SAVE_OK = V_OK_CODE.
   CLEAR V_OK_CODE.
   CASE V_SAVE_OK.

* Vissza
     WHEN 'BACK'.
       SET SCREEN 0.
       LEAVE SCREEN.

     WHEN OTHERS.
*     do nothing
   ENDCASE.

 ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_ABEV_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ABEV1  text
*      <--P_P_ABEVT1  text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM GET_ABEV_TEXT USING    $ABEV
*                    CHANGING $ABEV_TEXT.
 FORM GET_ABEV_TEXT USING    $ABEV TYPE /ZAK/ABEVAZ
                   CHANGING $ABEV_TEXT TYPE /ZAK/ABEVTEXT.
*--S4HANA#01.


   CHECK NOT $ABEV IS INITIAL.

   IF V_BTYPE IS INITIAL.
     PERFORM GET_OTHERS_DATA.
   ENDIF.

   SELECT SINGLE COUNT( * )
                          FROM /ZAK/BEVALLB
                          WHERE BTYPE EQ V_BTYPE
                            AND ABEVAZ EQ $ABEV.
   IF SY-SUBRC NE 0.
*++1665 #11.
*     MESSAGE E112 WITH V_BTYPE $ABEV.
     MESSAGE W112 WITH V_BTYPE $ABEV.
*--1665 #11.
*   & bevallás & ABEV azonosító nem létezik!
   ENDIF.

   SELECT SINGLE   ABEVTEXT INTO $ABEV_TEXT
                          FROM /ZAK/BEVALLBT
                          WHERE LANGU EQ SY-LANGU
                            AND BTYPE EQ V_BTYPE
                            AND ABEVAZ EQ $ABEV.
 ENDFORM.                    " GET_ABEV_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_RANGE_ABEVAZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*++S4HANA#01.
* FORM GET_RANGE_ABEVAZ TABLES $RANGE STRUCTURE R_ABEV1
*                       USING  $BTYPE
*                              $ABEVAZ.
 FORM GET_RANGE_ABEVAZ TABLES $RANGE STRUCTURE GS_ABEV1
                       USING  $BTYPE TYPE /ZAK/BTYPE
                              $ABEVAZ TYPE /ZAK/BEVALLB-ABEVAZ.
*--S4HANA#01.

   DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.


   SELECT ABEVAZ INTO L_ABEVAZ
                 FROM /ZAK/BEVALLB
                WHERE BTYPE EQ $BTYPE
                  AND SUM_ABEVAZ EQ $ABEVAZ.
     M_DEF $RANGE 'I' 'EQ' L_ABEVAZ SPACE.
   ENDSELECT.

 ENDFORM.                    " GET_RANGE_ABEVAZ
*&---------------------------------------------------------------------*
*&      Form  FILL_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_I_OUTTAB2[]  text
*----------------------------------------------------------------------*
 FORM FILL_LOG  USING    $BUKRS
                         $I_OUTTAB2 LIKE I_OUTTAB2[].

   DATA LI_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI.
   DATA LW_BEVALLI TYPE /ZAK/BEVALLI.
   DATA LW_OUTTAB2 TYPE /ZAK/EGYEZT2_ALV.
   DATA L_BTYPE TYPE /ZAK/BTYPE.


   LOOP AT $I_OUTTAB2 INTO LW_OUTTAB2.
     CLEAR LW_BEVALLI.
     CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
       EXPORTING
         I_BUKRS     = $BUKRS
         I_BTYPART   = C_BTYPART_AFA
         I_GJAHR     = LW_OUTTAB2-BUPER(4)
         I_MONAT     = LW_OUTTAB2-BUPER+4(2)
       IMPORTING
         E_BTYPE     = L_BTYPE
       EXCEPTIONS
         ERROR_MONAT = 1
         ERROR_BTYPE = 2
         OTHERS      = 3.
     IF SY-SUBRC EQ 0.
       READ TABLE LI_BEVALLI INTO LW_BEVALLI
                         WITH KEY  BUKRS = $BUKRS
                                   BTYPE = L_BTYPE
                                   GJAHR = LW_OUTTAB2-BUPER(4)
                                   MONAT = LW_OUTTAB2-BUPER+4(2)
                                   ZINDEX = LW_OUTTAB2-ZINDEX.
       IF SY-SUBRC NE 0.
         SELECT SINGLE * INTO  LW_BEVALLI
                  FROM  /ZAK/BEVALLI
                  WHERE  BUKRS = $BUKRS AND
                         BTYPE = L_BTYPE AND
                         GJAHR = LW_OUTTAB2-BUPER(4) AND
                         MONAT = LW_OUTTAB2-BUPER+4(2) AND
                         ZINDEX = LW_OUTTAB2-ZINDEX.
         APPEND LW_BEVALLI TO LI_BEVALLI.
         SORT LI_BEVALLI.
       ENDIF.
       LW_OUTTAB2-FLAG = LW_BEVALLI-FLAG.
       MODIFY $I_OUTTAB2 FROM LW_OUTTAB2 TRANSPORTING FLAG.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " FILL_LOG
