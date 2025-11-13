*&---------------------------------------------------------------------*
*&  Include           /ZAK/MAIN_VIEW_LOCAL_CLASS
*&---------------------------------------------------------------------*

*===============================================================
* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition:
* ~~~~~~~~~~~
 CLASS LCL_EVENT_RECEIVER DEFINITION.

   PUBLIC SECTION.

     METHODS:
       HANDLE_DATA_CHANGED
         FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
         IMPORTING ER_DATA_CHANGED.

     CLASS-METHODS:
       HANDLE_TOOLBAR
         FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
         IMPORTING E_OBJECT E_INTERACTIVE,


       HANDLE_DOUBLE_CLICK
         FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW
                   E_COLUMN
                   ES_ROW_NO,

       HANDLE_HOTSPOT_CLICK
         FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
         IMPORTING E_ROW_ID
                   E_COLUMN_ID
                   ES_ROW_NO,

       HANDLE_USER_COMMAND
         FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
         IMPORTING E_UCOMM.



   PRIVATE SECTION.
     DATA: ERROR_IN_DATA TYPE C.
 ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*
* lcl_event_receiver (Definition)
*===============================================================

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class lcl_event_receiver (Implementation)
*
*
 CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

   METHOD HANDLE_TOOLBAR.

* append a separator to normal toolbar
     CLEAR V_TOOLBAR.
     MOVE 3 TO V_TOOLBAR-BUTN_TYPE.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
     CLEAR V_TOOLBAR.
     MOVE '/ZAK/ZAK_MAN' TO V_TOOLBAR-FUNCTION.
     MOVE ICON_CREATE TO V_TOOLBAR-ICON.
     MOVE 'Manuális tétel rögzítése'(TO3) TO V_TOOLBAR-QUICKINFO.
     MOVE 'Manuális tétel'(TO4) TO V_TOOLBAR-TEXT.
     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
     IF P_M = C_X.
       MOVE C_X TO V_TOOLBAR-DISABLED.
     ELSE.
       MOVE SPACE TO V_TOOLBAR-DISABLED.
     ENDIF.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


* append a separator to normal toolbar
     CLEAR V_TOOLBAR.
     MOVE 3 TO V_TOOLBAR-BUTN_TYPE.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
     CLEAR V_TOOLBAR.
     MOVE '/ZAK/ZAK_ANA' TO V_TOOLBAR-FUNCTION.
     MOVE ICON_DISPLAY TO V_TOOLBAR-ICON.
     MOVE 'Analitika megjelenítése'(TO1)
          TO V_TOOLBAR-QUICKINFO.
     MOVE 'Analitika megjelenítése'(TO2) TO V_TOOLBAR-TEXT.
     MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
     MOVE SPACE TO V_TOOLBAR-DISABLED.
     APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

   ENDMETHOD.                    "HANDLE_TOOLBAR



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

     IF SY-DYNNR = '9000'.

     ELSEIF SY-DYNNR = '9001'.
       PERFORM D9001_EVENT_HOTSPOT_CLICK USING E_ROW_ID
                                               E_COLUMN_ID.

     ENDIF.
   ENDMETHOD.                    "hotspot_click



*---------------------------------------------------------------------*
*       METHOD handle_user_command                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_USER_COMMAND.

     DATA: I_ROWS TYPE LVC_T_ROW,
           W_ROWS TYPE LVC_S_ROW,
           S_OUT  TYPE /ZAK/BEVALLALV.
     DATA: I_ANA TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
           W_ANA TYPE /ZAK/ANALITIKA.

     CASE E_UCOMM.
* Analitika megjelenítése
       WHEN '/ZAK/ZAK_ANA'.

         IF SY-DYNNR = '9000'.

           CLEAR:   W_OUTTAB2.
*++S4HANA#01.
*           REFRESH: I_OUTTAB2.
           CLEAR: I_OUTTAB2[].
*--S4HANA#01.

           CALL METHOD V_GRID->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
*++S4HANA#01.
*             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
             SY-TFILL = LINES( I_ROWS ).
*--S4HANA#01.
*           IF SY-TFILL <> 1.
*             MESSAGE I018.
*           ENDIF.


             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                       WHERE BTYPE = S_OUT-BTYPE
                         AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Analitikus sor?
*               IF W_/ZAK/BEVALLB-COLLECT = C_X.
*                 MESSAGE I081(/ZAK/ZAK).
*                 CONTINUE.
*               ENDIF.

                 CHECK W_/ZAK/BEVALLB-COLLECT = SPACE.

*++0004 BG 2007.04.04
                 IF P_BTART NE C_BTYPART_ONYB.
*--0004 BG 2007.04.04
*++0005 BG 2007.05.30
*                  ÁFA 04,06-os lap kezelése
                   IF P_BTART EQ C_BTYPART_AFA AND
                      NOT S_OUT-ADOAZON IS INITIAL.
                     SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                       WHERE BUKRS   = S_OUT-BUKRS
                         AND BTYPE   = S_OUT-BTYPE
                         AND GJAHR   = S_OUT-GJAHR
                         AND MONAT   IN R_MONAT
*                        and ZINDEX  = s_out-zindex
                         AND ZINDEX  IN S_INDEX
                         AND ABEVAZ  = C_ABEVAZ_DUMMY
                         AND ADOAZON = S_OUT-ADOAZON.
*++S4HANA#01.
                     SORT I_ANA BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON BSZNUM PACK ITEM LAPSZ.
*--S4HANA#01.
                   ELSE.
*--0005 BG 2007.05.30
                     IF W_/ZAK/BEVALLB-ASZKOT = C_X.

*               SELECT * INTO TABLE I_OUTTAB2 FROM /ZAK/ANALITIKA
                       SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                         WHERE BUKRS   = S_OUT-BUKRS
                           AND BTYPE   = S_OUT-BTYPE
                           AND GJAHR   = S_OUT-GJAHR
                           AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                           AND ZINDEX  IN S_INDEX
                           AND ABEVAZ  = S_OUT-ABEVAZ
                           AND ADOAZON = S_OUT-ADOAZON.
*++S4HANA#01.
                       SORT I_ANA BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON BSZNUM PACK ITEM LAPSZ.
*--S4HANA#01.
                     ELSE.
                       SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                         WHERE BUKRS   = S_OUT-BUKRS
                           AND BTYPE   = S_OUT-BTYPE
                           AND GJAHR   = S_OUT-GJAHR
                           AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                           AND ZINDEX  IN S_INDEX
                           AND ABEVAZ  = S_OUT-ABEVAZ.
*                  AND ADOAZON = S_OUT-ADOAZON.
*++S4HANA#01.
                       SORT I_ANA BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON BSZNUM PACK ITEM LAPSZ.
*--S4HANA#01.
                     ENDIF.
*++0005 BG 2007.05.30
                   ENDIF.
*--0005 BG 2007.05.30

*++0004 BG 2007.04.04
                 ELSE. "C_BTYPART_ONYB
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
                       AND ZINDEX  IN S_INDEX
*                        AND ABEVAZ  = S_OUT-ABEVAZ
                       AND ADOAZON = S_OUT-ADOAZON.
*++S4HANA#01.
                   SORT I_ANA BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON BSZNUM PACK ITEM LAPSZ.
*--S4HANA#01.
                 ENDIF. "C_BTYPART_ONYB
*--0004 BG 2007.04.04
               ENDIF.
             ENDLOOP.
           ENDIF.
         ELSEIF SY-DYNNR = '9002'.

           CLEAR:   W_OUTTAB2.
*++S4HANA#01.
*           REFRESH: I_OUTTAB2.
           CLEAR: I_OUTTAB2[].
*--S4HANA#01.

           CALL METHOD V_GRID3->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
*++S4HANA#01.
*             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
             SY-TFILL = LINES( I_ROWS ).
*--S4HANA#01.
*           IF SY-TFILL <> 1.
*             MESSAGE I018.
*           ENDIF.


             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB_L INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                         WHERE BTYPE = S_OUT-BTYPE
                           AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Analitikus sor?
*               IF W_/ZAK/BEVALLB-COLLECT = C_X.
*                 MESSAGE I081(/ZAK/ZAK).
*                 CONTINUE.
*               ENDIF.

                 CHECK W_/ZAK/BEVALLB-COLLECT = SPACE.

                 IF W_/ZAK/BEVALLB-ASZKOT = C_X.

*               SELECT * INTO TABLE I_OUTTAB2 FROM /ZAK/ANALITIKA
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                       AND ZINDEX  IN S_INDEX
                       AND ABEVAZ  = S_OUT-ABEVAZ
                       AND ADOAZON = S_OUT-ADOAZON.
*++S4HANA#01.
                   SORT I_ANA BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON BSZNUM PACK ITEM LAPSZ.
*--S4HANA#01.
                 ELSE.
                   SELECT * APPENDING TABLE I_ANA FROM /ZAK/ANALITIKA
                     WHERE BUKRS   = S_OUT-BUKRS
                       AND BTYPE   = S_OUT-BTYPE
                       AND GJAHR   = S_OUT-GJAHR
                       AND MONAT   IN R_MONAT
*                   and ZINDEX  = s_out-zindex
                       AND ZINDEX  IN S_INDEX
                       AND ABEVAZ  = S_OUT-ABEVAZ.
*                  AND ADOAZON = S_OUT-ADOAZON.
*++S4HANA#01.
                   SORT I_ANA BY BUKRS BTYPE GJAHR MONAT ZINDEX ABEVAZ ADOAZON BSZNUM PACK ITEM LAPSZ.
*--S4HANA#01.
                 ENDIF.
               ENDIF.
             ENDLOOP.
*++S4HANA#01.
*           ELSE.
*--S4HANA#01.
           ENDIF.
         ENDIF.

         DATA:  LT_CELLTAB TYPE LVC_T_STYL.
         DATA:  L_INDEX LIKE SY-TABIX.
* Mező beállítások
         LOOP AT I_ANA INTO W_ANA.

           L_INDEX = SY-TABIX.

           MOVE-CORRESPONDING W_ANA TO W_OUTTAB2.
           APPEND W_OUTTAB2 TO I_OUTTAB2.

* Sor beállítások beolvasása
           READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
              WITH KEY BTYPE = W_OUTTAB2-BTYPE
                       ABEVAZ = W_OUTTAB2-ABEVAZ.
           IF SY-SUBRC NE 0.
             CLEAR W_/ZAK/BEVALLB.
             SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                 WHERE BTYPE = W_OUTTAB2-BTYPE
                   AND ABEVAZ = W_OUTTAB2-ABEVAZ.
             INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
           ENDIF.

* CELLTAB beállítása
           CLEAR: LT_CELLTAB,   W_OUTTAB2-CELLTAB.
*++S4HANA#01.
*           REFRESH: LT_CELLTAB, W_OUTTAB2-CELLTAB.
           CLEAR: LT_CELLTAB[].
           CLEAR: W_OUTTAB2-CELLTAB[].
*--S4HANA#01.


           IF W_/ZAK/BEVALLB-FIELDTYPE = C_CHAR.
             PERFORM FILL_CELLTAB USING 'RW'
                                  CHANGING LT_CELLTAB.

           ELSE.
             PERFORM FILL_CELLTAB USING 'RO'
                                  CHANGING LT_CELLTAB.

           ENDIF.


           INSERT LINES OF LT_CELLTAB INTO TABLE W_OUTTAB2-CELLTAB.
           MODIFY I_OUTTAB2 FROM W_OUTTAB2 INDEX L_INDEX.

         ENDLOOP.


         CALL SCREEN 9001.


* Manuális rögzítés
       WHEN '/ZAK/ZAK_MAN'.

         IF SY-DYNNR = '9000'.
*++0004 BG 2007.04.04
           IF P_BTART EQ C_BTYPART_ONYB.
             MESSAGE I215 WITH P_BTART.
*   & bevallás fajtánál nem megengedett a manuális rögzítés!
             EXIT.
           ENDIF.
*--0004 BG 2007.04.04

*++0016 BG 2011.09.14
*    Csoport vállalatnál nem engedett a manuális rögzítés
           IF NOT V_BUKCS IS INITIAL.
             MESSAGE I295 WITH P_BUKRS.
*   & csoport vállalatnál nem megengedett a manuális rögzítés!
             EXIT.
           ENDIF.
*--0016 BG 2011.09.14
           CALL METHOD V_GRID->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
*++S4HANA#01.
*             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
             SY-TFILL = LINES( I_ROWS ).
*--S4HANA#01.
             IF SY-TFILL <> 1.
               MESSAGE I018.
             ENDIF.

             CHECK SY-TFILL = 1.

             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                       WHERE BTYPE = S_OUT-BTYPE
                         AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Manuálisan módosítható sor?
                 IF W_/ZAK/BEVALLB-MANUAL <> C_X.
                   MESSAGE I043(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.

* Adószám kötelező
                 IF W_/ZAK/BEVALLB-ASZKOT = C_X AND
                    S_OUT-ADOAZON = SPACE.
                   MESSAGE I106(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.


                 IF W_/ZAK/BEVALLB-FIELDTYPE = C_NUM.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-ORIG_VALUE = /ZAK/ANALITIKA_S-FIELD_N.
                   CLEAR /ZAK/ANALITIKA_S-FIELD_N.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.
*++0017 BG 2012.02.07
                   CLEAR /ZAK/ANAL_MS.
*--0017 BG 2012.02.07
                   CALL SCREEN 9100.
                 ELSE.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.

                   CALL SCREEN 9200.
                 ENDIF.
               ENDIF.
             ENDLOOP.
           ENDIF.

         ELSEIF SY-DYNNR = '9002'.
           CALL METHOD V_GRID3->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = I_ROWS.
           CALL METHOD CL_GUI_CFW=>FLUSH.
           IF SY-SUBRC EQ 0.
*++S4HANA#01.
*             DESCRIBE TABLE I_ROWS LINES SY-TFILL.
             SY-TFILL = LINES( I_ROWS ).
*--S4HANA#01.
             IF SY-TFILL <> 1.
               MESSAGE I018.
             ENDIF.

             CHECK SY-TFILL = 1.

             LOOP AT I_ROWS INTO W_ROWS.
               READ TABLE I_OUTTAB_L INTO S_OUT INDEX W_ROWS-INDEX.
               IF SY-SUBRC = 0.

                 READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                    WITH KEY BTYPE = S_OUT-BTYPE
                             ABEVAZ = S_OUT-ABEVAZ.
                 IF SY-SUBRC NE 0.
                   CLEAR W_/ZAK/BEVALLB.
                   SELECT SINGLE * INTO W_/ZAK/BEVALLB FROM /ZAK/BEVALLB
                       WHERE BTYPE = S_OUT-BTYPE
                         AND ABEVAZ = S_OUT-ABEVAZ.
                   INSERT W_/ZAK/BEVALLB INTO TABLE I_/ZAK/BEVALLB.
                 ENDIF.

* Manuálisan módosítható sor?
                 IF W_/ZAK/BEVALLB-MANUAL <> C_X.
                   MESSAGE I043(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.

* Adószám kötelező
                 IF W_/ZAK/BEVALLB-ASZKOT = C_X AND
                    S_OUT-ADOAZON = SPACE.
                   MESSAGE I106(/ZAK/ZAK).
                   CONTINUE.
                 ENDIF.


                 IF W_/ZAK/BEVALLB-FIELDTYPE = C_NUM.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-ORIG_VALUE = /ZAK/ANALITIKA_S-FIELD_N.
                   CLEAR /ZAK/ANALITIKA_S-FIELD_N.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.
*++0017 BG 2012.02.07
                   CLEAR /ZAK/ANAL_MS.
*--0017 BG 2012.02.07
                   CALL SCREEN 9100.
                 ELSE.
                   MOVE-CORRESPONDING S_OUT TO /ZAK/ANALITIKA_S.
                   /ZAK/ANALITIKA_S-BSZNUM = '999'.
                   /ZAK/ANALITIKA_S-LAPSZ = C_LAPSZ.
                   IF /ZAK/ANALITIKA_S-WAERS IS INITIAL.
                     /ZAK/ANALITIKA_S-WAERS = C_HUF.
                   ENDIF.

                   CALL SCREEN 9200.
                 ENDIF.
               ENDIF.
             ENDLOOP.
           ENDIF.
*++S4HANA#01.
*         ELSE.
*--S4HANA#01.
         ENDIF.
     ENDCASE.
   ENDMETHOD.                           "handle_user_command
*---------------------------------------------------------------------*
*       METHOD handle_data_changed                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
   METHOD HANDLE_DATA_CHANGED.

     DATA: LS_GOOD TYPE LVC_S_MODI.
     DATA: L_XDEFT,
           L_COUNTER TYPE I.

     DATA: T_/ZAK/ANALITIKA  TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
           LT_/ZAK/ANALITIKA TYPE TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
           L_/ZAK/ANALITIKA  TYPE /ZAK/ANALITIKA,
           W_RETURN         TYPE BAPIRET2.

*++BG 2009.11.26
     DATA LS_STABLE TYPE LVC_S_STBL.

*    get position
     LS_STABLE-ROW = 'X'.
     LS_STABLE-COL = 'X'.

*--BG 2009.11.26

     ERROR_IN_DATA = SPACE.
* semantic checks

     LOOP AT ER_DATA_CHANGED->MT_GOOD_CELLS INTO LS_GOOD.
       CASE LS_GOOD-FIELDNAME.
* check if column XDEFT of this row was changed
         WHEN 'XDEFT'.
* Get new cell value to check it.
           CALL METHOD ER_DATA_CHANGED->GET_CELL_VALUE
             EXPORTING
               I_ROW_ID    = LS_GOOD-ROW_ID
               I_FIELDNAME = LS_GOOD-FIELDNAME
             IMPORTING
               E_VALUE     = L_XDEFT.
           READ TABLE I_OUTTAB2 INTO W_OUTTAB2 INDEX LS_GOOD-ROW_ID.
           IF SY-SUBRC = 0.
             W_OUTTAB2-XDEFT = L_XDEFT.

* Update
             CLEAR W_OUTTAB2-ZINDEX.
             CLEAR W_OUTTAB3.
             MOVE-CORRESPONDING W_OUTTAB2 TO W_OUTTAB3.
             APPEND W_OUTTAB3 TO T_/ZAK/ANALITIKA.
           ENDIF.


       ENDCASE.
     ENDLOOP.


     IF NOT T_/ZAK/ANALITIKA[] IS INITIAL.
       PERFORM CALL_UPDATE TABLES I_RETURN
                                  T_/ZAK/ANALITIKA
                           USING  W_OUTTAB2-BUKRS
                                  W_OUTTAB2-BTYPE
                                  W_OUTTAB2-BSZNUM
*                                 W_OUTTAB2-PACK
                                  SPACE
                                  SPACE
                                  SPACE.


       READ TABLE I_RETURN INTO W_RETURN WITH KEY TYPE = 'E'.
       IF SY-SUBRC <> 0.

         LOOP AT T_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA.

           READ TABLE I_OUTTAB2 INTO W_OUTTAB2 WITH KEY
                BUKRS = W_/ZAK/ANALITIKA-BUKRS
                BTYPE = W_/ZAK/ANALITIKA-BTYPE
                GJAHR = W_/ZAK/ANALITIKA-GJAHR
                MONAT = W_/ZAK/ANALITIKA-MONAT
                ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                ADOAZON = W_/ZAK/ANALITIKA-ADOAZON
                BSZNUM = W_/ZAK/ANALITIKA-BSZNUM
                PACK   = W_/ZAK/ANALITIKA-PACK
                ITEM   = W_/ZAK/ANALITIKA-ITEM.
           IF SY-SUBRC = 0.
             W_OUTTAB2-XDEFT = W_/ZAK/ANALITIKA-XDEFT.
             MODIFY I_OUTTAB2 FROM W_OUTTAB2 INDEX SY-TABIX.
           ENDIF.

         ENDLOOP.


         READ TABLE T_/ZAK/ANALITIKA INTO W_/ZAK/ANALITIKA
            WITH KEY XDEFT = C_X.
         IF SY-SUBRC = 0.

           IF V_DYNNR <> '9002'.

             READ TABLE I_OUTTAB INTO W_OUTTAB WITH KEY
                 BUKRS = W_/ZAK/ANALITIKA-BUKRS
                 BTYPE = W_/ZAK/ANALITIKA-BTYPE
                 GJAHR = W_/ZAK/ANALITIKA-GJAHR
                 MONAT = W_/ZAK/ANALITIKA-MONAT
                 ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                 ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                 ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
             IF SY-SUBRC = 0.
               W_OUTTAB-FIELD_C = W_/ZAK/ANALITIKA-FIELD_C.
               MODIFY I_OUTTAB FROM W_OUTTAB INDEX SY-TABIX.
             ENDIF.

           ELSE.
             READ TABLE I_OUTTAB_L INTO W_OUTTAB WITH KEY
                 BUKRS = W_/ZAK/ANALITIKA-BUKRS
                 BTYPE = W_/ZAK/ANALITIKA-BTYPE
                 GJAHR = W_/ZAK/ANALITIKA-GJAHR
                 MONAT = W_/ZAK/ANALITIKA-MONAT
                 ZINDEX = W_/ZAK/ANALITIKA-ZINDEX
                 ABEVAZ = W_/ZAK/ANALITIKA-ABEVAZ
                 ADOAZON = W_/ZAK/ANALITIKA-ADOAZON.
             IF SY-SUBRC = 0.
               W_OUTTAB-FIELD_C = W_/ZAK/ANALITIKA-FIELD_C.
               MODIFY I_OUTTAB_L FROM W_OUTTAB INDEX SY-TABIX.
             ENDIF.

           ENDIF.
         ENDIF.
       ENDIF.

     ENDIF.

     CALL METHOD V_GRID->REFRESH_TABLE_DISPLAY
*++BG 2009.11.26
       EXPORTING
         IS_STABLE = LS_STABLE.
*--BG 2009.11.26

     CALL METHOD V_GRID2->REFRESH_TABLE_DISPLAY.
     IF V_DYNNR = '9002'.
       CALL METHOD V_GRID3->REFRESH_TABLE_DISPLAY.
     ENDIF.

*++S4HANA#01.
*     REFRESH I_RETURN.
     CLEAR I_RETURN[].
*--S4HANA#01.

   ENDMETHOD.                    "HANDLE_DATA_CHANGED

 ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================
