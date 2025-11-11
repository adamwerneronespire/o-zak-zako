*&---------------------------------------------------------------------*
*& Program: Tax return configuration changes
*&---------------------------------------------------------------------*
REPORT /ZAK/ALV_BEVALLB_MOD .
*&---------------------------------------------------------------------*
*& Function description: Changes made in the tax return configuration data
*&---------------------------------------------------------------------*
*& Author             : Cserhegyi Timea - fmc
*& Creation date      : 2006.06.27
*& Functional spec by : ________
*& SAP module         : ADO
*& Program type       : Report
*& SAP version        : 46C
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (Write the OSS note number at the end of the modified lines)
*&
*& LOG#     DATE        MODIFIER                DESCRIPTION           TRANSPORT
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
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You are not authorized to run the program!
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
