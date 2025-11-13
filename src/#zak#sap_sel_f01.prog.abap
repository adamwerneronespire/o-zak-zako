*----------------------------------------------------------------------*
*   INCLUDE /ZAK/SAP_SEL_F01                                            *
*----------------------------------------------------------------------*
TABLES: T001.

*++0003 2009.05.22 BG
DATA I_KBELNR TYPE STANDARD TABLE OF /ZAK/OUT_BELNR INITIAL SIZE 0.
*--0003 2009.05.22 BG

*&---------------------------------------------------------------------*
*&      Form  get_t001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*----------------------------------------------------------------------*
FORM GET_T001 USING   $BUKRS
*++S4HANA#01.
*                      $SUBRC.
            CHANGING  $SUBRC.
*--S4HANA#01.

  CLEAR: T001, $SUBRC.
  SELECT SINGLE * INTO T001
                  FROM T001
                 WHERE BUKRS EQ $BUKRS.

  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
*++1765 #13.
  ELSE.
    SELECT SINGLE WAERS INTO T001-WAERS
                        FROM T005
                       WHERE LAND1 EQ T001-LAND1.
*--1765 #13.
  ENDIF.

ENDFORM.                                                    " get_t001


*&---------------------------------------------------------------------*
*&      Form  ver_btypeart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM VER_BTYPEART USING   $BUKRS
                          $BTYPAR
                          $BTYPART
                CHANGING  $SUBRC.

*++0003 BG 2007/01/05
  CLEAR $SUBRC.
*--0003 BG 2007/01/05

  IF $BTYPAR NE $BTYPART.
    MOVE 4 TO $SUBRC.
  ENDIF.

ENDFORM.                    " ver_btypeart
*&---------------------------------------------------------------------*
*&      Form  ver_bsznum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS   text
*      -->P_P_BTYPAR  text
*      -->P_P_BSZNUM  text
*      -->P_SY_REPID  text
*      <--P_V_SUBRC   text
*----------------------------------------------------------------------*
FORM VER_BSZNUM USING    $BUKRS
                         $BTYPAR
                         $BSZNUM
                         $REPID
                CHANGING $SUBRC.

  DATA L_PROGRAMM LIKE /ZAK/BEVALLD-PROGRAMM.
  DATA L_XSPEC    LIKE /ZAK/BEVALLD-XSPEC.

*++S4HANA#01.
*  DATA LR_BTYPE LIKE RANGE_C10 OCCURS 0.
  DATA LT_BTYPE TYPE STANDARD TABLE OF RANGE_C10 .
*--S4HANA#01.

  CLEAR $SUBRC.

* We determine the BTYPEs
  CALL FUNCTION '/ZAK/GET_BTYPES_FROM_BTYPART'
    EXPORTING
      I_BUKRS     = $BUKRS
      I_BTYPART   = $BTYPAR
    TABLES
*++S4HANA#01.
*     T_BTYPE     = LR_BTYPE
      T_BTYPE     = LT_BTYPE
*--S4HANA#01.
*     T_/ZAK/BEVALL       =
    EXCEPTIONS
      ERROR_BTYPE = 1
      OTHERS      = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*++S4HANA#01.
*  SELECT SINGLE PROGRAMM XSPEC
*                         INTO (L_PROGRAMM,
*                               L_XSPEC)
*                         FROM /ZAK/BEVALLD
*                        WHERE BUKRS  EQ $BUKRS
*                          AND BTYPE  IN LR_BTYPE
*                          AND BSZNUM EQ $BSZNUM
*                          AND FILETYPE EQ C_FILETYPE_04.
  SELECT PROGRAMM XSPEC
                         INTO (L_PROGRAMM,
                               L_XSPEC)
                         FROM /ZAK/BEVALLD UP TO 1 ROWS
                        WHERE BUKRS  EQ $BUKRS
                          AND BTYPE  IN LT_BTYPE
                          AND BSZNUM EQ $BSZNUM
                          AND FILETYPE EQ C_FILETYPE_04
                        ORDER BY PRIMARY KEY.
  ENDSELECT.
*--S4HANA#01.

  IF SY-SUBRC NE 0 OR L_PROGRAMM NE $REPID.
    MOVE 4 TO $SUBRC.
    MESSAGE E029 WITH $BSZNUM.
*   This program cannot be used for the & data service!
  ELSEIF SY-SUBRC EQ 0 AND NOT L_XSPEC IS INITIAL.
    MOVE 4 TO $SUBRC.
    MESSAGE E065 WITH $BSZNUM.
*   The special data service identifier cannot be used here! (&)
  ENDIF.

ENDFORM.                    " ver_bsznum
*&---------------------------------------------------------------------*
*&      Form  get_analitika_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/ANALITIKA  text
*      -->P_W_/ZAK/ANALITIKA_ITEM  text
*----------------------------------------------------------------------*
FORM GET_ANALITIKA_ITEM TABLES  $/ZAK/ANALITIKA   STRUCTURE /ZAK/ANALITIKA
*++S4HANA#01.
*                        USING   $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA.
                     CHANGING   $W_/ZAK/ANALITIKA STRUCTURE /ZAK/ANALITIKA.
*--S4HANA#01.

  DATA LW_/ZAK/ANALITIKA TYPE /ZAK/ANALITIKA.

  SORT $/ZAK/ANALITIKA BY BUKRS BTYPE GJAHR MONAT ABEVAZ ITEM DESCENDING.

* Determining the item identifier
  MOVE 1 TO $W_/ZAK/ANALITIKA-ITEM.
*  DO.
*    READ TABLE $/ZAK/ANALITIKA INTO LW_/ZAK/ANALITIKA
*                          WITH KEY BUKRS  = $W_/ZAK/ANALITIKA-BUKRS
*                                   BTYPE  = $W_/ZAK/ANALITIKA-BTYPE
*                                   GJAHR  = $W_/ZAK/ANALITIKA-GJAHR
*                                   MONAT  = $W_/ZAK/ANALITIKA-MONAT
*                                   ABEVAZ = $W_/ZAK/ANALITIKA-ABEVAZ
*                                   ITEM   = $W_/ZAK/ANALITIKA-ITEM
*                                   BINARY SEARCH.
*    IF SY-SUBRC NE 0.
*      EXIT.
*    ELSE.
*      ADD 1 TO $W_/ZAK/ANALITIKA-ITEM.
*    ENDIF.
*  ENDDO.

  READ TABLE $/ZAK/ANALITIKA INTO LW_/ZAK/ANALITIKA
                        WITH KEY BUKRS  = $W_/ZAK/ANALITIKA-BUKRS
                                 BTYPE  = $W_/ZAK/ANALITIKA-BTYPE
                                 GJAHR  = $W_/ZAK/ANALITIKA-GJAHR
                                 MONAT  = $W_/ZAK/ANALITIKA-MONAT
                                 ABEVAZ = $W_/ZAK/ANALITIKA-ABEVAZ
                                 BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    $W_/ZAK/ANALITIKA-ITEM = LW_/ZAK/ANALITIKA-ITEM + 1.
  ENDIF.

ENDFORM.                    " get_analitika_item
*&---------------------------------------------------------------------*
*&      Form  VERIFY_BSZNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPAR  text
*      -->P_P_GJAHR  text
*      -->P_P_MONAT  text
*----------------------------------------------------------------------*
FORM VERIFY_BSZNUM  USING    $BUKRS
                             $BTYPAR
                             $GJAHR
                             $MONAT
                             $BSZNUM
                             $REPID
*++S4HANA#01.
*                             $SUBRC.
                    CHANGING $SUBRC.
*--S4HANA#01.

  DATA L_BTYPE TYPE /ZAK/BTYPE.

  CLEAR: L_BTYPE, $SUBRC.

* Determining BTYPE
  CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
    EXPORTING
      I_BUKRS     = $BUKRS
      I_BTYPART   = $BTYPAR
      I_GJAHR     = $GJAHR
      I_MONAT     = $MONAT
    IMPORTING
      E_BTYPE     = L_BTYPE
    EXCEPTIONS
      ERROR_MONAT = 1
      ERROR_BTYPE = 2
      OTHERS      = 3.
  IF SY-SUBRC <> 0.
    MOVE SY-SUBRC TO $SUBRC.
    EXIT.
  ENDIF.

  SELECT COUNT( * ) FROM /ZAK/BEVALLD
                   WHERE BUKRS  EQ $BUKRS
                     AND BTYPE  EQ L_BTYPE
                     AND BSZNUM EQ $BSZNUM
                     AND PROGRAMM EQ $REPID.
  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
    EXIT.
  ENDIF.

ENDFORM.                    " VERIFY_BSZNUM
*&---------------------------------------------------------------------*
*&      Form  GET_ONYB_ABEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ONYB_ABEV  text
*----------------------------------------------------------------------*
FORM GET_ONYB_ABEV  TABLES   $I_ONYB_ABEV LIKE I_ONYB_ABEV.


* ABEV identifiers of the BEVALLB summary reports:
*++S4HANA#01.
*  REFRESH $I_ONYB_ABEV.
  CLEAR $I_ONYB_ABEV[].
*--S4HANA#01.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE $I_ONYB_ABEV
           FROM /ZAK/BEVALLB
          WHERE ONYBF = C_X.                            "#EC CI_NOFIELD

  SORT  $I_ONYB_ABEV.

ENDFORM.                    " GET_ONYB_ABEV
*&---------------------------------------------------------------------*
*&      Form  GET_KBELNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KBELNR  text
*      -->P_P_BUKRS  text
*      -->P_P_KBELNR  text
*----------------------------------------------------------------------*
FORM GET_KBELNR  TABLES   $I_KBELNR STRUCTURE /ZAK/OUT_BELNR
                 USING    $BUKRS
*++S4HANA#01.
*                          $KBELNR.
                 CHANGING $KBELNR.
*--S4HANA#01.

  CLEAR $KBELNR.

  CHECK NOT $BUKRS IS INITIAL.

  SELECT * INTO TABLE $I_KBELNR
           FROM /ZAK/OUT_BELNR
          WHERE BUKRS EQ $BUKRS.
  IF SY-SUBRC EQ 0.
    MOVE 'X' TO $KBELNR.
  ENDIF.

ENDFORM.                    " GET_KBELNR

ENHANCEMENT-POINT /ZAK/RG_SEL_16 SPOTS /ZAK/RG_SEL STATIC INCLUDE BOUND .
