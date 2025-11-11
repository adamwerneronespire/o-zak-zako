*&---------------------------------------------------------------------*
*& Program: BSET tábla időbélyeg törlés
*&---------------------------------------------------------------------*
REPORT  /ZAK/BSET_STMDT_UPDATE MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Szerző            : Balázs Gábor - Ness
*& Létrehozás dátuma : 2016.12.06
*& Funkc.spec.készítő: ________
*& SAP modul neve    :
*& Program  típus    : Riport
*& SAP verzió        :
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.
CLASS LCL_EVENT_HANDLER DEFINITION DEFERRED.
*&---------------------------------------------------------------------*
*& Egyszerű alv alapok
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Típusdeklarációk
*&---------------------------------------------------------------------*
TYPES: TY_DATA TYPE TABLE OF /ZAK/AFA_SZLA.
INCLUDE /ZAK/ALV_GRID_ALAP.
*&---------------------------------------------------------------------*
*& TáBLáK                                                              *
*&---------------------------------------------------------------------*
TABLES: BSET.
*&---------------------------------------------------------------------*
*  PROGRAM VÁLTOZÓK                                                    *
*&---------------------------------------------------------------------*
DATA G_SUBRC TYPE SYSUBRC.
DATA G_ANSWER.
DATA G_INDEX TYPE SYTABIX.
*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
* Vállalat.
SELECT-OPTIONS S_BUKRS  FOR  BSET-BUKRS.
* Bizonylat
SELECT-OPTIONS S_BELNR  FOR  BSET-BELNR.
* Év
SELECT-OPTIONS S_GJAHR  FOR  BSET-GJAHR.
* Tétel
SELECT-OPTIONS S_BUZEI  FOR  BSET-BUZEI.
*ÁFA
SELECT-OPTIONS S_MWSKZ  FOR  BSET-MWSKZ.
*Dátum
SELECT-OPTIONS S_STMDT  FOR  BSET-STMDT.
*Idő
SELECT-OPTIONS S_STMTI  FOR  BSET-STMTI.
*Teszt
PARAMETERS P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL01.
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
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Adat rekordszám meghatározása
  PERFORM GET_INDEX USING G_INDEX.
  MESSAGE I000 WITH 'Szelekciónak megfelelő bejegyzések száma: '(001) G_INDEX.
*   & & & &
  IF NOT G_INDEX IS INITIAL AND P_TEST IS INITIAL.
    UPDATE BSET SET STMDT = '00000000'
                    STMTI = ''
                   WHERE BUKRS IN S_BUKRS
                     AND BELNR IN S_BELNR
                     AND GJAHR IN S_GJAHR
                     AND BUZEI IN S_BUZEI
                     AND MWSKZ IN S_MWSKZ
                     AND STMDT IN S_STMDT
                     AND STMTI IN S_STMTI
                     AND STMDT NE '00000000'
                     AND STMTI NE ''.
    COMMIT WORK AND WAIT.
    MESSAGE I000 WITH 'Adatbázis módosított bejegyzések száma: '(002) G_INDEX.
  ENDIF.
*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING    UV_COLUMN_NAME
                                    UV_ROW_INDEX.
** példa implementálása a hotspot kattintásnak
*  CASE uv_column_name.
*    WHEN 'EBELN'.
*      READ TABLE gt_data INTO gs_data INDEX uv_row_index.
*      IF sy-subrc EQ 0.
*        ASSIGN COMPONENT uv_column_name OF STRUCTURE gs_data TO <fs_any>.
*        IF sy-subrc EQ 0.
*          SET PARAMETER ID 'BES' FIELD gs_data-ebeln.
*          CALL TRANSACTION 'ME23' AND SKIP FIRST SCREEN.
*        ENDIF.
*
*      ENDIF.
*
*  ENDCASE.
ENDFORM.                    " HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK  USING    UV_COLUMN_NAME
                                   UV_ROW_INDEX.
ENDFORM.                    " HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*&      Form  HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING UV_COLUMN_NAME
                                UV_ROW_INDEX.
ENDFORM.                    " HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  GET_INDEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_INDEX  text
*----------------------------------------------------------------------*
FORM GET_INDEX  USING    $INDEX.
  SELECT COUNT( * ) INTO $INDEX
                    FROM BSET
                   WHERE BUKRS IN S_BUKRS
                     AND BELNR IN S_BELNR
                     AND GJAHR IN S_GJAHR
                     AND BUZEI IN S_BUZEI
                     AND MWSKZ IN S_MWSKZ
                     AND STMDT IN S_STMDT
                     AND STMTI IN S_STMTI
                     AND STMDT NE '00000000'
                     AND STMTI NE ''.
ENDFORM.                    " GET_INDEX
