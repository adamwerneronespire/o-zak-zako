*&--------------------------------------------------------------------*
*& Program : ZHR_GET_T5HVX_FROM_HR_WITH_RFC                           *
*& Author  : Balázs Gábor                                             *
*& Date    : 2009.08.04                                               *
*& Desc.   : A T5HVX tábla tartalmának másolása a HR rendszerből
*              T5HS7 tábla tartalmának másolása a HR rendszerből
*              T5HVC tábla tartalmának másolása a HR rendszerből
*&--------------------------------------------------------------------*
*& Program type      : Report                                         *
*& Dev.class         : ZMT_HR                                         *
*& Logical database  : none                                           *
*& Module            : HR                                             *
*&--------------------------------------------------------------------*
*& Modification log                                                   *
*&                                                                    *
*& Date       Author Log     Desciption                               *
*& ---------- ------ ------- -----------------------------------------*
*&                                                                    *
*&                                                                    *
*&--------------------------------------------------------------------*
REPORT ZHR_GET_T5HVX_FROM_HR_WITH_RFC.

*----------------------------------------------------------------------
*       INTERNAL TABLES
*----------------------------------------------------------------------
DATA: T_T5HVX    LIKE /ZAK/T5HVX  OCCURS 0 WITH HEADER LINE,
      T_T5HS7    LIKE /ZAK/T5HS7  OCCURS 0 WITH HEADER LINE,
      T_T5HVC    LIKE /ZAK/T5HVC  OCCURS 0 WITH HEADER LINE,
      T_SEL_TAB  LIKE BDSEL_STAT OCCURS 0 WITH HEADER LINE,
      T_NAMETAB  LIKE BDI_MFGRP  OCCURS 0 WITH HEADER LINE,
      T_TABENTRY LIKE BDI_ENTRY  OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------
*       GLOBAL VARIABLES
*----------------------------------------------------------------------
*DATA G_RFCDEST LIKE ZHR_RFCDEST-RFCDEST.
DATA G_RFCDEST type RFCDEST.
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

*----------------------------------------------------------------------
*       START-OF-SELECTION
*----------------------------------------------------------------------
START-OF-SELECTION.
*  SELECT SINGLE RFCDEST FROM ZHR_RFCDEST INTO G_RFCDEST.
  IF G_RFCDEST IS INITIAL.
    WRITE: 'Kérem tartsa karban a HR RFC cél beállítását',
           'az ZHR_RFCDEST tranzakcióval!'.
    EXIT.
  ENDIF.


* T5HVX
  CALL FUNCTION 'TABLE_ENTRIES_GET_VIA_RFC'
    DESTINATION G_RFCDEST
    EXPORTING
*     LANGU                     = SY-LANGU
*     ONLY                      = ' '
      TABNAME                   = 'T5HVX'
*   IMPORTING
*     RC                        =
    TABLES
      SEL_TAB                   = T_SEL_TAB
      NAMETAB                   = T_NAMETAB
      TABENTRY                  = T_TABENTRY
    EXCEPTIONS
      INTERNAL_ERROR            = 1
      TABLE_HAS_NO_FIELDS       = 2
      TABLE_NOT_ACTIV           = 3
      NOT_AUTHORIZED            = 4
      OTHERS                    = 5.
  IF SY-SUBRC NE 0.
    WRITE / 'Hiba történt'.
    EXIT.
  ENDIF.

  T_T5HVX[] = T_TABENTRY[].

  DELETE FROM /ZAK/T5HVX. "#EC CI_NOWHERE
  WRITE: / '/ZAK/T5HVX - törölt rekordok száma:', SY-DBCNT.

  MODIFY /ZAK/T5HVX FROM TABLE T_T5HVX.
  WRITE: / '/ZAK/T5HVX - másolt rekordok száma:', SY-DBCNT.

* T5HS7
  CALL FUNCTION 'TABLE_ENTRIES_GET_VIA_RFC'
    DESTINATION G_RFCDEST
    EXPORTING
*     LANGU                     = SY-LANGU
*     ONLY                      = ' '
      TABNAME                   = 'T5HS7'
*   IMPORTING
*     RC                        =
    TABLES
      SEL_TAB                   = T_SEL_TAB
      NAMETAB                   = T_NAMETAB
      TABENTRY                  = T_TABENTRY
    EXCEPTIONS
      INTERNAL_ERROR            = 1
      TABLE_HAS_NO_FIELDS       = 2
      TABLE_NOT_ACTIV           = 3
      NOT_AUTHORIZED            = 4
      OTHERS                    = 5.
  IF SY-SUBRC NE 0.
    WRITE / 'Hiba történt'.
    EXIT.
  ENDIF.

  T_T5HS7[] = T_TABENTRY[].

  DELETE FROM /ZAK/T5HS7.  "#EC CI_NOWHERE
  WRITE: / '/ZAK/T5HS7 - törölt rekordok száma:', SY-DBCNT.

  MODIFY /ZAK/T5HS7 FROM TABLE T_T5HS7.
  WRITE: / '/ZAK/T5HS7 - másolt rekordok száma:', SY-DBCNT.

* T5HVC
  CALL FUNCTION 'TABLE_ENTRIES_GET_VIA_RFC'
    DESTINATION G_RFCDEST
    EXPORTING
*     LANGU                     = SY-LANGU
*     ONLY                      = ' '
      TABNAME                   = 'T5HVC'
*   IMPORTING
*     RC                        =
    TABLES
      SEL_TAB                   = T_SEL_TAB
      NAMETAB                   = T_NAMETAB
      TABENTRY                  = T_TABENTRY
    EXCEPTIONS
      INTERNAL_ERROR            = 1
      TABLE_HAS_NO_FIELDS       = 2
      TABLE_NOT_ACTIV           = 3
      NOT_AUTHORIZED            = 4
      OTHERS                    = 5.
  IF SY-SUBRC NE 0.
    WRITE / 'Hiba történt'.
    EXIT.
  ENDIF.

  T_T5HVC[] = T_TABENTRY[].

  DELETE FROM /ZAK/T5HVC.  "#EC CI_NOWHERE
  WRITE: / '/ZAK/T5HVC - törölt rekordok száma:', SY-DBCNT.

  MODIFY /ZAK/T5HVC FROM TABLE T_T5HVC.
  WRITE: / '/ZAK/T5HVC - másolt rekordok száma:', SY-DBCNT.


*----------------------------------------------------------------------
*       END-OF-SELECTION
*----------------------------------------------------------------------
END-OF-SELECTION.
