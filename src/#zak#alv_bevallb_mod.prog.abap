*&---------------------------------------------------------------------*
*& Program: Bevallás beállítások módosításai
*&---------------------------------------------------------------------*
REPORT /ZAK/ALV_BEVALLB_MOD .
*&---------------------------------------------------------------------*
*& Funkció leírás: Bevallás beállítási adataiban történt módosítások
*&---------------------------------------------------------------------*
*& Szerző            : Cserhegyi Tímea - fmc
*& Létrehozás dátuma : 2006.06.27
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
*&
*&---------------------------------------------------------------------*


PARAMETERS: P_OBJEKT   LIKE CDHDR-OBJECTCLAS DEFAULT '/ZAK/BEVALLB'
                       MODIF ID DIS,
            P_OBJID    LIKE CDHDR-OBJECTID,
            P_AEND     LIKE CDHDR-USERNAME DEFAULT SY-UNAME,
            P_DATUM    LIKE CDHDR-UDATE,
            P_ZEIT     LIKE CDHDR-UTIME,
            P_DBIS     TYPE CDHDR-UDATE    DEFAULT SY-DATUM,
            P_ZBIS     TYPE CDHDR-UTIME    DEFAULT '235959',
            P_NUM      LIKE CDHDR-CHANGENR DEFAULT ' ',
            P_TABNAM   LIKE CDPOS-TABNAME  DEFAULT ' ',
            P_TABKEY   LIKE CDPOS-TABKEY   DEFAULT ' ',
            P_KEYEXP   TYPE C              DEFAULT ' ',
            P_NEWDIS   AS CHECKBOX         DEFAULT 'X'.

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


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


START-OF-SELECTION.
  SUBMIT RSSCD100
          WITH AENDERER = P_AEND
          WITH DATUM    = P_DATUM
          WITH DAT_BIS  = P_DBIS
          WITH KEY_EXP  = P_KEYEXP
          WITH NEW_DISP = P_NEWDIS
          WITH NUMMER   = P_NUM
          WITH OBJEKT   = P_OBJEKT
          WITH OBJEKTID = P_OBJID
          WITH TABKEY   = P_TABKEY
          WITH TABNAME  = P_TABNAM
          WITH ZEIT     = P_ZEIT
          WITH ZEIT_BIS = P_ZBIS.
