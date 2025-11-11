*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  read_forms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_FORMS.

  SELECT * FROM T512P
           INTO CORRESPONDING FIELDS OF TABLE GT_XFORM0
           WHERE FORML EQ C_XFORM0.                     "#EC CI_GENBUFF
  SELECT * FROM T512P
           INTO CORRESPONDING FIELDS OF TABLE GT_XFORM1
           WHERE FORML EQ C_XFORM1.                     "#EC CI_GENBUFF
  SELECT * FROM T512P
           INTO CORRESPONDING FIELDS OF TABLE GT_XFORM2
           WHERE FORML EQ C_XFORM2.                     "#EC CI_GENBUFF
  SELECT * FROM T512P
           INTO CORRESPONDING FIELDS OF TABLE GT_XFORM3
           WHERE FORML EQ C_XFORM3.                     "#EC CI_GENBUFF
  SELECT * FROM T512P
           INTO CORRESPONDING FIELDS OF TABLE GT_XFORM4
           WHERE FORML EQ C_XFORM4.                     "#EC CI_GENBUFF

ENDFORM.                    " read_forms
*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM0  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_XML_HEADER TABLES GT_XFORM0 STRUCTURE GT_XFORM0
                              IT_XML_DATA TYPE TTY_XML_TABLE.

  DATA: $XML_LINE TYPE TY_XML_LINE.

  LOOP AT GT_XFORM0.

    CHECK NOT GT_XFORM0 CO SPACE.

    $XML_LINE = GT_XFORM0-LINDA.
    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.

ENDFORM.                    " CREATE_XML_HEADER
*&---------------------------------------------------------------------*
*&      Form  create_szja_a
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM2  text
*      -->P_GT_XFORM3  text
*      -->P_T_/ZAK/BEVALLALV  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_SZJA_A TABLES   GT_XFORM2 STRUCTURE  GT_XFORM2
                            GT_XFORM3 STRUCTURE  GT_XFORM3
                            IT_BEVALLO_ALV STRUCTURE /ZAK/BEVALLALV
                            IT_XML_DATA TYPE TTY_XML_TABLE
                            IT_BEVALLO_ALV_A STRUCTURE /ZAK/BEVALLALV
*++0808 BG 2008.02.07
                            IT_/ZAK/BEVALLB STRUCTURE /ZAK/BEVALLB
*--0808 BG 2008.02.07

*++BG 2006/09/29
                   USING    BEVDATUM.
*--BG 2006/09/29

* SZJA A header előállítása
  PERFORM CREATE_SZJAA_HEADER TABLES GT_XFORM2
                                     IT_BEVALLO_ALV
                                     IT_BEVALLO_ALV_A
                                     IT_XML_DATA
*++BG 2006/09/29
                            USING    BEVDATUM.
*--BG 2006/09/29


* mezők kiolvasása BEVALLO_ALV-ből
  PERFORM FIELDS_FROM_IT_BEVALLO_TO_XML TABLES IT_BEVALLO_ALV_A
*++0808 BG 2008.02.07
                                               IT_/ZAK/BEVALLB
*--0808 BG 2008.02.07

                                               IT_XML_DATA.


* SZJA A footer előállítása
  PERFORM CREATE_NYOMTATVANY_FOOTER TABLES GT_XFORM3
                                           IT_XML_DATA.



ENDFORM.                    " create_szja_a
*&---------------------------------------------------------------------*
*&      Form  create_szjaa_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM2  text
*      -->P_IT_T5HS7  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_SZJAA_HEADER TABLES   GT_XFORM2 STRUCTURE  GT_XFORM2
                                  IT_BEVALLO_ALV STRUCTURE
                                                 /ZAK/BEVALLALV
                                  IT_BEVALLO_ALV_A STRUCTURE
                                                 /ZAK/BEVALLALV
                                  IT_XML_DATA TYPE TTY_XML_TABLE
*++BG 2006/09/29
                         USING    BEVDATUM.
*--BG 2006/09/29



  DATA: $XML_LINE TYPE TY_XML_LINE.


  LOOP AT GT_XFORM2.

    CHECK NOT GT_XFORM2 CO SPACE.

    PERFORM REPLACE_VARIABLE_FROM_BEVALLO TABLES IT_BEVALLO_ALV
                                                 IT_BEVALLO_ALV_A
                                           USING GT_XFORM2-LINDA
                                                 SPACE     "ADOAZON
*++BG 2006/09/29
                                                 BEVDATUM
*--BG 2006/09/29
                                        CHANGING $XML_LINE.
    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.





ENDFORM.                    " create_szjaa_header
*&---------------------------------------------------------------------*
*&      Form  replace_variable_from_bevallo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_T5HS7  text
*      -->P_GT_XFORM2_LINDA  text
*      <--P_$XML_LINE  text
*----------------------------------------------------------------------*
FORM REPLACE_VARIABLE_FROM_BEVALLO TABLES   IT_BEVALLO_ALV STRUCTURE
                                                       /ZAK/BEVALLALV
                                            IT_BEVALLO_ALV_A STRUCTURE
                                                       /ZAK/BEVALLALV

                                   USING    VALUE(LINDA) LIKE
                                                         T512P-LINDA
                                            ADOAZON
*++BG 2006/09/29
                                            BEVDATUM
*--BG 2006/09/29
                                   CHANGING XML_LINE TYPE TY_XML_LINE.
*++0908/2 2009.08.04 BG
*  DATA: $VAR   LIKE T5HS7-MEZON,
*        $HEAD  LIKE T512P-LINDA,
*        $VALUE LIKE T5HS7-MEZOE.
  DATA: $VAR   LIKE /ZAK/T5HS7-MEZON,
        $HEAD  TYPE FORM_DATA,
        $VALUE LIKE /ZAK/T5HS7-MEZOE.
*--0908/2 2009.08.04 BG

*++0908 2009.02.10 BG
*++0908/2 2009.08.04 BG
* DATA L_HEAD_SAVE LIKE T512P-LINDA.
  DATA L_HEAD_SAVE TYPE FORM_DATA.
*--0908/2 2009.08.04 BG


  CLEAR XML_LINE.
*--0908 2009.02.10 BG

*++0908 2009.02.10 BG
  DO.
*--0908 2009.02.10 BG
    IF ( LINDA CS C_VAR_MARKER ).

      $HEAD = LINDA+0(SY-FDPOS).
      SHIFT LINDA BY SY-FDPOS PLACES. "átlépi $head-et
      SHIFT LINDA BY 1 PLACES.        "átlépi a var_markert

      IF ( LINDA CS C_VAR_MARKER ).    "megkeresi a változó végét

        $VAR = LINDA+0(SY-FDPOS).

*     kiolvassa a mezőértéket IT_BEVALLO_ALV
        IF ADOAZON IS INITIAL.
          CASE $VAR.
*         Nyomtatvány azonosító
            WHEN 'NYOMT'.
              PERFORM GET_NYOMT_VALUE TABLES IT_BEVALLO_ALV_A
                                       USING 'A'
                                    CHANGING $VALUE.
*         Verzió
            WHEN 'VERS'.
              PERFORM GET_VERS_VALUE TABLES IT_BEVALLO_ALV_A
                                       USING 'V'
                                             BEVDATUM
                                    CHANGING $VALUE.

*         ABEV kód
            WHEN OTHERS.
              PERFORM GET_VALUE_BEVALLO_A TABLES IT_BEVALLO_ALV_A
                                           USING $VAR
                                        CHANGING $VALUE.
          ENDCASE.

        ELSE.
          CASE $VAR.
*         Nyomtatvány azonosító
            WHEN 'NYOMT'.
              PERFORM GET_NYOMT_VALUE TABLES IT_BEVALLO_ALV_A
                                       USING 'M'
                                    CHANGING $VALUE.
*         Verzió
            WHEN 'VERS'.
              PERFORM GET_VERS_VALUE TABLES IT_BEVALLO_ALV_A
                                       USING 'E'
                                             BEVDATUM
                                    CHANGING $VALUE.

*         ABEV kód
            WHEN OTHERS.
              PERFORM GET_VALUE_BEVALLO_M TABLES IT_BEVALLO_ALV
                                           USING $VAR
                                                 ADOAZON
                                        CHANGING $VALUE.
          ENDCASE.

        ENDIF.
        SHIFT LINDA BY SY-FDPOS PLACES. "átlépi $var-t
        SHIFT LINDA BY 1 PLACES.        "átlépi a var_markert
*++0908 2009.02.10 BG
*       Először fut elmentjük a HEAD értékét.
        IF SY-INDEX EQ 1.
          MOVE $HEAD TO L_HEAD_SAVE.
        ENDIF.
*       az XML sor összeállítása
*       CONCATENATE $HEAD $VALUE LINDA INTO XML_LINE.
        IF NOT $VALUE IS INITIAL.
          IF NOT XML_LINE IS INITIAL.
            CONCATENATE XML_LINE $VALUE INTO XML_LINE SEPARATED BY SPACE.
          ELSE.
            MOVE $VALUE TO XML_LINE.
          ENDIF.
        ENDIF.
*--0908 2009.02.10 BG
      ELSE.
*++1865 #04.
*        MESSAGE E452(HRPAYHU) RAISING ERROR_DOWNLOAD.
        MESSAGE E367(/ZAK/ZAK) RAISING ERROR_DOWNLOAD.
*--1865 #04.
      ENDIF.

    ELSE.
*++0908 2009.02.10 BG
*     XML_LINE = LINDA.
      IF XML_LINE IS INITIAL.
        CONCATENATE L_HEAD_SAVE LINDA INTO XML_LINE.
*--0908 2009.02.10 BG
      ELSE.
        CONCATENATE L_HEAD_SAVE XML_LINE LINDA INTO XML_LINE.
*++0908 2009.02.10 BG
      ENDIF.
      EXIT.
*--0908 2009.02.10 BG
    ENDIF.
*++0908 2009.02.10 BG
  ENDDO.
*--0908 2009.02.10 BG



ENDFORM.                    " replace_variable_from_bevallo
*&---------------------------------------------------------------------*
*&      Form  GET_VALUE_BEVALLO_A
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV  text
*      -->P_$VAR  text
*      <--P_$VALUE  text
*----------------------------------------------------------------------*
FORM GET_VALUE_BEVALLO_A TABLES   IT_BEVALLO_ALV STRUCTURE
                                                 /ZAK/BEVALLALV
*++0908/2 2009.08.04 BG
*                       USING    VALUE(MEZON) LIKE T5HS7-MEZON
*                    CHANGING    VALUE(MEZOE) LIKE T5HS7-MEZOE.
                       USING    VALUE(MEZON) LIKE /ZAK/T5HS7-MEZON
                    CHANGING    VALUE(MEZOE) LIKE /ZAK/T5HS7-MEZOE.
*--0908/2 2009.08.04 BG


  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA L_INDEX LIKE SY-TABIX.

  PERFORM GET_HR_TO_ABEVAZ USING 'A'
                                 MEZON
                        CHANGING L_ABEVAZ.

  CLEAR MEZOE.
  CLEAR L_INDEX.

  LOOP AT IT_BEVALLO_ALV WHERE ABEVAZ = L_ABEVAZ.
    PERFORM PROCESS_IND_ITEM USING '1'
                                    L_INDEX
                                    TEXT-P10.


    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MEZOE = IT_BEVALLO_ALV-FIELD_C.
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL.
      MEZOE = IT_BEVALLO_ALV-FIELD_NR.
    ENDIF.
  ENDLOOP.



ENDFORM.                    " GET_VALUE_BEVALLO_A
*&---------------------------------------------------------------------*
*&      Form  GET_VALUE_BEVALLO_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV  text
*      -->P_$VAR  text
*      <--P_$VALUE  text
*----------------------------------------------------------------------*
FORM GET_VALUE_BEVALLO_M TABLES   IT_BEVALLO_ALV STRUCTURE
                                                 /ZAK/BEVALLALV
*++0908/2 2009.08.04 BG
*                       USING    VALUE(MEZON) LIKE T5HS7-MEZON
*                                ADOAZON
*                    CHANGING    VALUE(MEZOE) LIKE T5HS7-MEZOE.
                       USING    VALUE(MEZON) LIKE /ZAK/T5HS7-MEZON
                                ADOAZON
                    CHANGING    VALUE(MEZOE) LIKE /ZAK/T5HS7-MEZOE.
*--0908/2 2009.08.04 BG


  DATA L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA L_INDEX LIKE SY-TABIX.

  PERFORM GET_HR_TO_ABEVAZ USING 'M'
                                 MEZON
                        CHANGING L_ABEVAZ.

  CLEAR MEZOE.
  CLEAR L_INDEX.
*  LOOP AT IT_BEVALLO_ALV  FROM INDEX_SAVE
*                     WHERE ABEVAZ  = L_ABEVAZ
*                           AND ADOAZON = ADOAZON.
*    MOVE SY-TABIX TO INDEX_SAVE.

*    ADD 1 TO L_INDEX.
*    PERFORM PROCESS_IND_ITEM USING '10'
*                                    L_INDEX
*                                    TEXT-P10.
  READ TABLE IT_BEVALLO_ALV WITH KEY
                                     ADOAZON = ADOAZON
*++BG 2007.05.09
                                     LAPSZ   = '01'
*--BG 2007.05.09
                                     ABEVAZ  = L_ABEVAZ
                                     BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MEZOE = IT_BEVALLO_ALV-FIELD_C.
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL.
      MEZOE = IT_BEVALLO_ALV-FIELD_NR.
    ENDIF.
  ENDIF.
*  ENDLOOP.



ENDFORM.                    " GET_VALUE_BEVALLO_M

*&---------------------------------------------------------------------*
*&      Form  GET_HR_TO_ABEVAZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MEZON  text
*      <--P_L_ABEVAZ  text
*----------------------------------------------------------------------*
FORM GET_HR_TO_ABEVAZ USING    $NYOMT
                               $MEZON
                      CHANGING $ABEVAZ.

  CLEAR $ABEVAZ.
*ABEV azonosító átalakítása
  CONCATENATE $NYOMT
              $MEZON(2)
              $MEZON+6(6)
              'A' INTO $ABEVAZ.

ENDFORM.                    " GET_HR_TO_ABEVAZ
*&---------------------------------------------------------------------*
*&      Form  fields_from_it_bevallo_to_xml
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_IT_BEVALLO_TO_XML TABLES  IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
*++0808 BG 2008.02.07
                                           IT_/ZAK/BEVALLB STRUCTURE
                                                          /ZAK/BEVALLB
*--0808 BG 2008.02.07

                                           IT_XML_DATA TYPE
                                                         TTY_XML_TABLE.

  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: $XML_LINE TYPE TY_XML_LINE.
*++2108 #14.
*  DATA: L_MEZOE(40).
  DATA: L_MEZOE TYPE /ZAK/FIELDC.
*--2108 #14.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: L_ELOJEL.

  CONSTANTS: $START_TAG TYPE TY_XML_LINE VALUE '    <mezok>',
             $END_TAG   TYPE TY_XML_LINE VALUE '    </mezok>'.
  CONSTANTS: $T1 TYPE TY_XML_LINE VALUE '      <mezo eazon="',
             $T2 TYPE TY_XML_LINE VALUE '">',
             $T3 TYPE TY_XML_LINE VALUE '</mezo>'.


*++BG 2006/12/06
  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
  END-OF-DEFINITION.
*--BG 2006/12/06


  APPEND $START_TAG TO IT_XML_DATA.

  CLEAR L_INDEX.

  LOOP AT IT_BEVALLO_ALV. "WHERE ABEVAZ(1) EQ 'A'.
*    ADD 1 TO L_INDEX.
*    PERFORM PROCESS_IND_ITEM USING '1'
*                                    L_INDEX
*                                    TEXT-P10.

    CLEAR: $XML_LINE, L_MEZOE.

*++0808 BG 2008.02.07
*  Beállítás beolvasása
    READ  TABLE IT_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                   ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                   BINARY SEARCH.
*++BG 2008.03.06
*    IF SY-SUBRC NE 0.
*      CLEAR W_/ZAK/BEVALLB.
*    ENDIF.
    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.
*--BG 2008.03.06

*--0808 BG 2008.02.07

*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.

    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*++BG 2006/12/06
*   ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL.
    ELSEIF ( NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL AND
                 IT_BEVALLO_ALV-OFLAG IS INITIAL ) OR
*++0808 BG 2008.02.07
           ( NOT W_/ZAK/BEVALLB-XMLALL IS INITIAL AND
             NOT IT_BEVALLO_ALV-OFLAG IS INITIAL ).
*++BG 2008.03.11
*  Kivesszük mert önrevíziós oszlopot nem fogjuk átadani
*                                                 AND
*             NOT IT_BEVALLO_ALV-FIELD_ON IS INITIAL ).
*--BG 2008.03.11
*--0808 BG 2008.02.07

*--BG 2006/12/06
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.

*++BG 2006/12/06
*      CLEAR L_ELOJEL.
**     Negatív előjel figyelése
*      IF IT_BEVALLO_ALV-FIELD_NR < 0.
*        MOVE '-' TO L_ELOJEL.
*        IT_BEVALLO_ALV-FIELD_NR = ABS( IT_BEVALLO_ALV-FIELD_NR ).
*      ENDIF.
*      WRITE IT_BEVALLO_ALV-FIELD_NR CURRENCY IT_BEVALLO_ALV-WAERS
*            TO L_MEZOE NO-GROUPING
*                         DECIMALS 0
*                         LEFT-JUSTIFIED.
*      IF L_ELOJEL EQ '-'.
*        CONCATENATE '-' L_MEZOE INTO L_MEZOE.
*      ENDIF.
*    ENDIF.
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_ONR IS INITIAL AND
           NOT IT_BEVALLO_ALV-OFLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_ONR IT_BEVALLO_ALV-WAERS.
*--BG 2006/12/06
*++ BG 2008.03.10
*  0-ás mező ami kell
    ELSEIF NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
*++0808 2009.02.11 BG
      IF IT_BEVALLO_ALV-OFLAG IS INITIAL.
*--0808 2009.02.11 BG
        M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
*++0808 2009.02.11 BG
      ELSE.
        M_SET_MEZOE IT_BEVALLO_ALV-FIELD_ONR IT_BEVALLO_ALV-WAERS.
      ENDIF.
*--0808 2009.02.11 BG

*-- BG 2007.03.10
    ENDIF.
    CHECK NOT L_MEZOE IS INITIAL.

    CONCATENATE $T1 L_APEH_ABEVAZ $T2 L_MEZOE $T3
           INTO $XML_LINE.

    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.

  APPEND $END_TAG TO IT_XML_DATA.



ENDFORM.                    " fields_from_it_bevallo_to_xml
*&---------------------------------------------------------------------*
*&      Form  GET_ABEVAZ_TO_APEH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV_ABEVAZ  text
*      -->P_IT_BEVALLO_ALV_LAPSZ  text
*      <--P_L_APEH_ABEVAZ  text
*----------------------------------------------------------------------*
FORM GET_ABEVAZ_TO_APEH USING    $ABEVAZ
                                 $LAPSZ
                        CHANGING $APEH_ABEVAZ.


  CONCATENATE $ABEVAZ+1(2)
              $LAPSZ
              $ABEVAZ+3(10) INTO $APEH_ABEVAZ.



ENDFORM.                    " GET_ABEVAZ_TO_APEH
*&---------------------------------------------------------------------*
*&      Form  create_nyomtatvany_footer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM3  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_NYOMTATVANY_FOOTER TABLES GT_XFORM3 STRUCTURE GT_XFORM3
                                      IT_XML_DATA TYPE TTY_XML_TABLE.

  DATA: $XML_LINE TYPE TY_XML_LINE.

  LOOP AT GT_XFORM3.

    CHECK NOT GT_XFORM3 CO SPACE.

    $XML_LINE = GT_XFORM3-LINDA.
    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.

ENDFORM.                    " CREATE_XML_HEADER
*&---------------------------------------------------------------------*
*&      Form  SAVE_XML_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM SAVE_XML_FILE TABLES   IT_XML_DATA TYPE TTY_XML_TABLE
                   USING    $FILE.

  DATA: L_FILENAME LIKE RLGRAP-FILENAME.

*++0001 2007.01.03 BG (FMC)
* 0001 ++ CST 2006.05.27
* Letöltés...
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE            =
      FILENAME                = $FILE
*     FILETYPE                = 'ASC'
*      IMPORTING
*     FILELENGTH              =
    TABLES
      DATA_TAB                = IT_XML_DATA
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      OTHERS                  = 5.
  IF SY-SUBRC NE 0.
    MESSAGE E175(/ZAK/ZAK) WITH $FILE RAISING ERROR_DOWNLOAD.
*   Hiba a & fájl letöltésénél.
  ENDIF.
*  L_FILENAME = $FILE.
*
*  CALL FUNCTION 'WS_DOWNLOAD'
*    EXPORTING
**   BIN_FILESIZE                  = ' '
**   CODEPAGE                      = ' '
*      FILENAME                      = L_FILENAME
**   FILETYPE                      = 'ASC'
**   MODE                          = ' '
**   WK1_N_FORMAT                  = ' '
**   WK1_N_SIZE                    = ' '
**   WK1_T_FORMAT                  = ' '
**   WK1_T_SIZE                    = ' '
**   COL_SELECT                    = ' '
**   COL_SELECTMASK                = ' '
**   NO_AUTH_CHECK                 = ' '
** IMPORTING
**   FILELENGTH                    =
*    TABLES
*      DATA_TAB                      = IT_XML_DATA
**   FIELDNAMES                    =
*   EXCEPTIONS
*     FILE_OPEN_ERROR               = 1
*     FILE_WRITE_ERROR              = 2
*     INVALID_FILESIZE              = 3
*     INVALID_TYPE                  = 4
*     NO_BATCH                      = 5
*     UNKNOWN_ERROR                 = 6
*     INVALID_TABLE_WIDTH           = 7
*     GUI_REFUSE_FILETRANSFER       = 8
*     CUSTOMER_ERROR                = 9
*     OTHERS                        = 10
*            .
*  IF SY-SUBRC NE 0.
*    MESSAGE E175(/ZAK/ZAK) WITH $FILE RAISING ERROR_DOWNLOAD.
**   Hiba a & fájl letöltésénél.
*  ENDIF.
* 0001 -- CST 2006.05.27
*--0001 2007.01.03 BG (FMC)

ENDFORM.                    " SAVE_XML_FILE
*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_FOOTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM1  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_XML_FOOTER TABLES GT_XFORM1 STRUCTURE GT_XFORM1
                              IT_XML_DATA TYPE TTY_XML_TABLE.

  DATA: $XML_LINE TYPE TY_XML_LINE.

  LOOP AT GT_XFORM1.

    CHECK NOT GT_XFORM1 CO SPACE.

    $XML_LINE = GT_XFORM1-LINDA.
    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.

ENDFORM.                    " CREATE_XML_HEADER
*&---------------------------------------------------------------------*
*&      Form  CREATE_SZJA_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM4  text
*      -->P_GT_XFORM3  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_SZJA_M TABLES   GT_XFORM4 STRUCTURE GT_XFORM4
                            GT_XFORM3 STRUCTURE GT_XFORM3
                            IT_BEVALLO_ALV STRUCTURE /ZAK/BEVALLALV
                            IT_XML_DATA TYPE TTY_XML_TABLE
                            IT_BEVALLO_ALV_A STRUCTURE /ZAK/BEVALLALV
*++0808 BG 2008.02.07
                            IT_/ZAK/BEVALLB STRUCTURE /ZAK/BEVALLB
*--0808 BG 2008.02.07
                  USING     ADOAZON
                            INDEX_SAVE
                            MAX_LINE
*++BG 2006/09/29
                            BEVDATUM.
*--BG 2006/09/29


* SZJA M header előállítása
  PERFORM CREATE_SZJAM_HEADER TABLES GT_XFORM4
                                     IT_BEVALLO_ALV
                                     IT_XML_DATA
                                     IT_BEVALLO_ALV_A
                              USING  ADOAZON
*++BG 2006/09/29
                                     BEVDATUM.
*--BG 2006/09/29

* mezők kiolvasása BEVALLO_ALV-ből
  PERFORM FIELDS_FROM_BEVALLO_TO_XML_M TABLES IT_BEVALLO_ALV
                                              IT_XML_DATA
*++0808 BG 2008.02.07
                                              IT_/ZAK/BEVALLB
*--0808 BG 2008.02.07
                                       USING  ADOAZON
                                              INDEX_SAVE
                                              MAX_LINE.

* 0608A footer előállítása
  PERFORM CREATE_NYOMTATVANY_FOOTER TABLES GT_XFORM3
                                           IT_XML_DATA.



ENDFORM.                    " CREATE_SZJA_M
*&---------------------------------------------------------------------*
*&      Form  CREATE_SZJAM_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XFORM4  text
*      -->P_IT_BEVALLO_ALV  text
*      -->P_IT_XML_DATA  text
*----------------------------------------------------------------------*
FORM CREATE_SZJAM_HEADER TABLES   GT_XFORM4 STRUCTURE GT_XFORM4
                                  IT_BEVALLO_ALV STRUCTURE
                                                 /ZAK/BEVALLALV
                                  IT_XML_DATA TYPE TTY_XML_TABLE
                                  IT_BEVALLO_ALV_A STRUCTURE
                                                 /ZAK/BEVALLALV
                         USING    ADOAZON
*++BG 2006/09/29
                                  BEVDATUM.
*--BG 2006/09/29


  DATA: $XML_LINE TYPE TY_XML_LINE.


  LOOP AT GT_XFORM4.

    CHECK NOT GT_XFORM4 CO SPACE.

    PERFORM REPLACE_VARIABLE_FROM_BEVALLO TABLES IT_BEVALLO_ALV
                                                 IT_BEVALLO_ALV_A
                                           USING GT_XFORM4-LINDA
                                                 ADOAZON
*++BG 2006/09/29
                                                 BEVDATUM
*--BG 2006/09/29
                                        CHANGING $XML_LINE.
    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.




ENDFORM.                    " CREATE_SZJAM_HEADER
*&---------------------------------------------------------------------*
*&      Form  FIELDS_FROM_BEVALLO_TO_XML_M
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV  text
*      -->P_IT_XML_DATA  text
*      -->P_ADOAZON  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_BEVALLO_TO_XML_M TABLES IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
                                            IT_XML_DATA TYPE
                                                         TTY_XML_TABLE
*++0808 BG 2008.02.07
                                            IT_/ZAK/BEVALLB STRUCTURE
                                                           /ZAK/BEVALLB
*--0808 BG 2008.02.07
                                  USING     ADOAZON
                                            INDEX_SAVE
                                            MAX_LINE.


  DATA: $XML_LINE TYPE TY_XML_LINE.
  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
*++2108 #14.
*  DATA: L_MEZOE(40).
  DATA: L_MEZOE TYPE /ZAK/FIELDC.
*--2108 #14.
  DATA: L_ABEV_NO LIKE /ZAK/BEVALLB-ABEV_NO.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: L_INDEX_TO LIKE SY-TABIX.
  DATA: L_ELOJEL.


  CONSTANTS: $START_TAG TYPE TY_XML_LINE VALUE '    <mezok>',
             $END_TAG   TYPE TY_XML_LINE VALUE '    </mezok>'.
  CONSTANTS: $T1 TYPE TY_XML_LINE VALUE '      <mezo eazon="',
             $T2 TYPE TY_XML_LINE VALUE '">',
             $T3 TYPE TY_XML_LINE VALUE '</mezo>'.


*++BG 2006/12/06
  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
  END-OF-DEFINITION.
*--BG 2006/12/06


* Beállítjuk a tábla olvasás -tól, -ig értékét, hogy szűkítsük a
* beolvasás tartományát.
  IF NOT MAX_LINE IS INITIAL.
*   Az index TO értékét 10 lapos intervallumra állítjuk be
    L_INDEX_TO = INDEX_SAVE + ( MAX_LINE * 10 ).
  ELSE.
    DESCRIBE TABLE IT_BEVALLO_ALV LINES L_INDEX_TO.
  ENDIF.

  APPEND $START_TAG TO IT_XML_DATA.


  CLEAR L_INDEX.

  LOOP AT IT_BEVALLO_ALV FROM INDEX_SAVE
                           TO L_INDEX_TO
                         WHERE ADOAZON EQ ADOAZON
*++0002 BG 2007.05.09
                           AND NOT LAPSZ IS INITIAL.
*--0002 BG 2007.05.09

*++0808 BG 2008.02.07
**   Ha üres a BEVALLB beolvassuk
*    IF I_/ZAK/BEVALLB[] IS INITIAL.
*      SELECT * INTO TABLE I_/ZAK/BEVALLB
*                    FROM /ZAK/BEVALLB
*                   WHERE BTYPE EQ IT_BEVALLO_ALV-BTYPE.
*      SORT I_/ZAK/BEVALLB BY BTYPE ABEVAZ.
*--0808 BG 2008.02.07
    DESCRIBE TABLE I_/ZAK/BEVALLB LINES MAX_LINE.
*++0808 BG 2008.02.07
*    ENDIF.
*--0808 BG 2008.02.07

    MOVE SY-TABIX TO INDEX_SAVE.

    CLEAR: $XML_LINE, L_MEZOE.
**   Ellenőrizzük le kell e ABEV-ba a mező
*    SELECT SINGLE ABEV_NO INTO L_ABEV_NO
*                          FROM /ZAK/BEVALLB
*                         WHERE BTYPE  EQ IT_BEVALLO_ALV-BTYPE
*                           AND ABEVAZ EQ IT_BEVALLO_ALV-ABEVAZ.
*
*    CHECK L_ABEV_NO IS INITIAL.

    READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                             WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                                      ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                                      BINARY SEARCH.

    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.

*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.

    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*++BG 2006/12/06
*   ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL.
    ELSEIF ( NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL AND
               IT_BEVALLO_ALV-OFLAG IS INITIAL ) OR
*++0808 BG 2008.02.07
           ( NOT W_/ZAK/BEVALLB-XMLALL IS INITIAL AND
             NOT IT_BEVALLO_ALV-OFLAG IS INITIAL ).
*++BG 2008.03.11
*
*                                                 AND
*             NOT IT_BEVALLO_ALV-FIELD_ON IS INITIAL ).
*--BG 2008.03.11
*--0808 BG 2008.02.07

      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
*      CLEAR L_ELOJEL.
**     Negatív előjel fiyelése
*      IF IT_BEVALLO_ALV-FIELD_NR < 0.
*        MOVE '-' TO L_ELOJEL.
*        IT_BEVALLO_ALV-FIELD_NR = ABS( IT_BEVALLO_ALV-FIELD_NR ).
*      ENDIF.
*      WRITE IT_BEVALLO_ALV-FIELD_NR CURRENCY IT_BEVALLO_ALV-WAERS
*            TO L_MEZOE NO-GROUPING
*                         DECIMALS 0
*                         LEFT-JUSTIFIED.
*      IF L_ELOJEL EQ '-'.
*        CONCATENATE '-' L_MEZOE INTO L_MEZOE.
*      ENDIF.
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_ONR IS INITIAL AND
           NOT IT_BEVALLO_ALV-OFLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_ONR IT_BEVALLO_ALV-WAERS.
*--BG 2006/12/06
*++ BG 2007.06.22
*  0-ás mező ami kell
    ELSEIF NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
*++0808 2009.02.11 BG
      IF IT_BEVALLO_ALV-OFLAG IS INITIAL.
*--0808 2009.02.11 BG
        M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
*++0808 2009.02.11 BG
      ELSE.
        M_SET_MEZOE IT_BEVALLO_ALV-FIELD_ONR IT_BEVALLO_ALV-WAERS.
      ENDIF.
*--0808 2009.02.11 BG

*-- BG 2007.06.22
    ENDIF.

    CHECK NOT L_MEZOE IS INITIAL.

    CONCATENATE $T1 L_APEH_ABEVAZ $T2 L_MEZOE $T3
           INTO $XML_LINE.

    APPEND $XML_LINE TO IT_XML_DATA.

  ENDLOOP.

  APPEND $END_TAG TO IT_XML_DATA.

ENDFORM.                    " FIELDS_FROM_BEVALLO_TO_XML_
*&---------------------------------------------------------------------*
*&      Form  alpha_conv_out
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_W_/ZAK/BEVALLO_FIELD_C  text
*----------------------------------------------------------------------*
FORM ALPHA_CONV_OUT CHANGING P_FIELD_C.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_FIELD_C
    IMPORTING
      OUTPUT = P_FIELD_C.

ENDFORM.                    " alpha_conv_out
*&---------------------------------------------------------------------*
*&      Form  READ_FORMS_N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_BEV_DAT  text
*----------------------------------------------------------------------*
FORM READ_FORMS_N USING   $DATUM.

* XML head
  SELECT  XLINE AS LINDA
          INTO CORRESPONDING FIELDS OF TABLE GT_XFORM0
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
         WHERE BLOKK_ID EQ C_XHEAD
           AND BEGDA LE $DATUM
           AND ENDDA GE $DATUM.

* XML vége (end)
  SELECT  XLINE AS LINDA
          INTO CORRESPONDING FIELDS OF TABLE GT_XFORM1
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
         WHERE BLOKK_ID EQ C_XTAIL
           AND BEGDA LE $DATUM
           AND ENDDA GE $DATUM.

*Vállalati bevallás head
  SELECT  XLINE AS LINDA
          INTO CORRESPONDING FIELDS OF TABLE GT_XFORM2
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
         WHERE BLOKK_ID EQ C_NYBEG
           AND BEGDA LE $DATUM
           AND ENDDA GE $DATUM.
  SELECT  XLINE AS LINDA
          APPENDING CORRESPONDING FIELDS OF TABLE GT_XFORM2
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
         WHERE BLOKK_ID EQ C_VHEAD
           AND BEGDA LE $DATUM
           AND ENDDA GE $DATUM.

*Nyomtatvány vége
  SELECT  XLINE AS LINDA
         INTO CORRESPONDING FIELDS OF TABLE GT_XFORM3
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
        WHERE BLOKK_ID EQ C_NYEND
          AND BEGDA LE $DATUM
          AND ENDDA GE $DATUM.

*Egyéni bevallás head
  SELECT  XLINE AS LINDA
          INTO CORRESPONDING FIELDS OF TABLE GT_XFORM4
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
         WHERE BLOKK_ID EQ C_NYBEG
           AND BEGDA LE $DATUM
           AND ENDDA GE $DATUM.
  SELECT  XLINE AS LINDA
          APPENDING CORRESPONDING FIELDS OF TABLE GT_XFORM4
*++0908/2 2009.08.04 BG
*         FROM T5HVX
          FROM /ZAK/T5HVX
*--0908/2 2009.08.04 BG
         WHERE BLOKK_ID EQ C_EHEAD
           AND BEGDA LE $DATUM
           AND ENDDA GE $DATUM.



ENDFORM.                    " READ_FORMS_N
*&---------------------------------------------------------------------*
*&      Form  GET_NYOMT_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV_A  text
*      -->P_$VAR  text
*      -->P_0255   text
*      <--P_$VALUE  text
*----------------------------------------------------------------------*
FORM GET_NYOMT_VALUE TABLES   $T_BEVALLO_ALV_A STRUCTURE
                                               /ZAK/BEVALLALV
                     USING    $EXT
                     CHANGING $VALUE.

  DATA LW_/ZAK/BEVALLALV LIKE /ZAK/BEVALLALV.

  READ TABLE $T_BEVALLO_ALV_A INTO LW_/ZAK/BEVALLALV INDEX 1.

  CONCATENATE LW_/ZAK/BEVALLALV-BTYPE $EXT INTO $VALUE.


ENDFORM.                    " GET_NYOMT_VALUE
*&---------------------------------------------------------------------*
*&      Form  GET_VERS_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BEVALLO_ALV_A  text
*      -->P_$VAR  text
*      -->P_0274   text
*      <--P_$VALUE  text
*----------------------------------------------------------------------*
FORM GET_VERS_VALUE TABLES   $T_BEVALLO_ALV_A  STRUCTURE
                                               /ZAK/BEVALLALV
                    USING    $TIPUS
                             $BEVDATUM
                  CHANGING   $VALUE.
*++0908/2 2009.08.04 BG
* DATA L_NYOMT LIKE T5HVC-NYOMT.
  DATA L_NYOMT LIKE /ZAK/T5HVC-NYOMT.
*--0908/2 2009.08.04 BG

  DATA L_EXT.


  IF $TIPUS EQ 'V'.
    MOVE 'A' TO L_EXT.
  ELSEIF $TIPUS EQ 'E'.
    MOVE 'M' TO L_EXT.
  ENDIF.

*Meghatározzuk a nyomtatványt
  PERFORM GET_NYOMT_VALUE TABLES $T_BEVALLO_ALV_A
                           USING L_EXT
                        CHANGING L_NYOMT.


  SELECT SINGLE VERS INTO $VALUE                        "#EC CI_NOFIRST
*++0908/2 2009.08.04 BG
*                    FROM T5HVC
                     FROM /ZAK/T5HVC
*--0908/2 2009.08.04 BG
                    WHERE TIPUS = $TIPUS
                      AND NYOMT = L_NYOMT
                      AND ENDDA GE $BEVDATUM.


ENDFORM.                    " GET_VERS_VALUE
*&---------------------------------------------------------------------*
*&      Form  FIELDS_FROM_IT_BEVALLO_TO_KULF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO_ALV  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_I_TAB_A  text
*      -->P_I_TAB_M  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_IT_BEVALLO_TO_KULF  TABLES   IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
                                              IT_/ZAK/BEVALLB STRUCTURE
                                                         /ZAK/BEVALLB
                                              IT_TAB_A STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_M STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_MS.

  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: LW_TAB_MS  TYPE  /ZAK/MSLINEXXK79.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: LW_TAB  TYPE /ZAK/XML_GEN.
  DATA: L_ELOJEL.
*++2108 #14.
*  DATA: L_MEZOE(40).
  DATA: L_MEZOE TYPE /ZAK/FIELDC.
*--2108 #14.
  DATA: L_ADOAZON TYPE /ZAK/ADOAZON.
  DATA: L_ABEVAZ TYPE /ZAK/ABEVAZ.
*++12K79 2013.01.30
  DATA: L_BTYPE_SAVE TYPE /ZAK/BTYPE.
*--12K79 2013.01.30


  TYPES: BEGIN OF LT_TAB_MA,
           ADOAZON TYPE /ZAK/ADOAZON.
           INCLUDE STRUCTURE /ZAK/XML_GEN.
         TYPES: END OF LT_TAB_MA.
  DATA: LI_TAB_MA TYPE STANDARD TABLE OF LT_TAB_MA
                  INITIAL SIZE 0 WITH HEADER LINE.

  DATA: LI_ADOAZON TYPE STANDARD TABLE OF /ZAK/ADOAZON
                   INITIAL SIZE 0 WITH HEADER LINE.


  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
    CONDENSE L_MEZOE.
  END-OF-DEFINITION.


  DEFINE LM_GET_NAME.
    DO 3 TIMES.
      CASE SY-INDEX.
        WHEN 1.
          L_ABEVAZ = &1.
        WHEN 2.
          L_ABEVAZ = &2.
        WHEN 3.
          L_ABEVAZ = &3.
      ENDCASE.
      READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                        ABEVAZ = L_ABEVAZ.
      IF SY-SUBRC EQ 0.
        IF NOT &4 IS INITIAL.
          CONCATENATE &4 LW_TAB-VALUE INTO &4 SEPARATED BY SPACE.
        ELSE.
          &4 = LW_TAB-VALUE.
        ENDIF.
      ENDIF.
    ENDDO.
  END-OF-DEFINITION.

  DEFINE LM_GET_ADOAZON.
    CLEAR &2.
    READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                    ABEVAZ = &1.
    IF SY-SUBRC EQ 0.
      &2 = LW_TAB-VALUE.
    ENDIF.
  END-OF-DEFINITION.



  LOOP AT IT_BEVALLO_ALV.
*  Beállítás beolvasása
    READ  TABLE IT_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                   ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                   BINARY SEARCH.

    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.
*++12K79 2013.01.30
*   Bevallás típusonként más a név!
    IF L_BTYPE_SAVE IS INITIAL.
      L_BTYPE_SAVE = IT_BEVALLO_ALV-BTYPE.
    ENDIF.
*--12K79 2013.01.30

*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.
*   Karakteres
    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*   Van érték vagy 0-ás mező és kell
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL OR
           NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
    ENDIF.

    CHECK NOT L_MEZOE IS INITIAL.
    CONDENSE L_MEZOE.
    LW_TAB-ABEVAZ = L_APEH_ABEVAZ.
    LW_TAB-VALUE  = L_MEZOE.

    IF IT_BEVALLO_ALV-ABEVAZ(1) = 'A'.
      APPEND LW_TAB TO IT_TAB_A.
    ELSEIF IT_BEVALLO_ALV-ABEVAZ(1) = 'M'.
      CLEAR LI_TAB_MA.
      MOVE IT_BEVALLO_ALV-ADOAZON TO LI_TAB_MA-ADOAZON.
      MOVE-CORRESPONDING LW_TAB TO LI_TAB_MA.
      APPEND LI_TAB_MA.
    ENDIF.

  ENDLOOP.

* Adószámonként szétszedjük
  SORT LI_TAB_MA BY ADOAZON.
  LOOP AT LI_TAB_MA.
    L_ADOAZON = LI_TAB_MA-ADOAZON.
    MOVE-CORRESPONDING LI_TAB_MA TO LW_TAB.
    APPEND LW_TAB TO IT_TAB_M.
    AT END OF ADOAZON.
      SORT IT_TAB_M.
      CLEAR LW_TAB_MS.
*     Adóazonosítónak meg kell egyeznie az
*     ABEV kód értékével egyébként ABEV hiba!
*      lw_tab_ms-adoazon = l_adoazon.
*--12K79 2013.01.30
      IF L_BTYPE_SAVE EQ C_11K79.
*--12K79 2013.01.30
        LM_GET_ADOAZON '0A0001C003A'
                       LW_TAB_MS-ADOAZON.
*     Név öszeállítása
        LM_GET_NAME '0A0001C005A'
                    '0A0001C006A'
                    '0A0001C007A'
                    LW_TAB_MS-NAME.
*++12K79 2013.01.30
      ELSEIF L_BTYPE_SAVE EQ C_12K79.
        LM_GET_ADOAZON '0A0001C003A'
                       LW_TAB_MS-ADOAZON.
*     Név öszeállítása
        LM_GET_NAME '0A0001C007A'
                    '0A0001C008A'
                    ''
                    LW_TAB_MS-NAME.

*++13K79 2014.01.29
      ELSEIF L_BTYPE_SAVE EQ C_13K79.
        LM_GET_ADOAZON '0A0001C003A'
                       LW_TAB_MS-ADOAZON.
*     Név öszeállítása
        LM_GET_NAME '0A0001C006A'
                    '0A0001C007A'
                    '0A0001C008A'
                    LW_TAB_MS-NAME.
*++13K79 2014.01.29
*++19K79 #01.
      ELSEIF L_BTYPE_SAVE EQ C_19K79.
        LM_GET_ADOAZON '0A0001C003A'
                       LW_TAB_MS-ADOAZON.
*     Név öszeállítása
        LM_GET_NAME '0A0001C009A'
                    '0A0001C010A'
                    '0A0001C011A'
                    LW_TAB_MS-NAME.
*--19K79 #01.
*++20K79 #01
      ELSEIF L_BTYPE_SAVE EQ C_20K79.
        LM_GET_ADOAZON '0A0001C003A'
                       LW_TAB_MS-ADOAZON.
*     Név öszeállítása
        LM_GET_NAME '0A0001C009A'
                    '0A0001C010A'
                    '0A0001C011A'
                    LW_TAB_MS-NAME.
      ENDIF.
*--20K79 #01
      LW_TAB_MS-MDATA[] = IT_TAB_M[].
      APPEND LW_TAB_MS TO IT_TAB_MS.
      REFRESH IT_TAB_M.
    ENDAT.
  ENDLOOP.



ENDFORM.                    " FIELDS_FROM_IT_BEVALLO_TO_KULF
*&---------------------------------------------------------------------*
*&      Form  SAVE_KULF_XML_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STRING  text
*      -->P_I_FILE  text
*----------------------------------------------------------------------*
FORM SAVE_KULF_XML_FILE USING $STRING TYPE STRING
                              $FILENAME.
  DATA:
    L_XSTRING  TYPE XSTRING,
    LENGTH     TYPE I,
    XML_STREAM TYPE ETXML_XLINE_TABTYPE.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      TEXT   = $STRING
*     MIMETYPE = ' '
*     ENCODING =
    IMPORTING
      BUFFER = L_XSTRING.


  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = L_XSTRING
*     APPEND_TO_TABLE = ' '
    IMPORTING
      OUTPUT_LENGTH = LENGTH
    TABLES
      BINARY_TAB    = XML_STREAM.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LENGTH
      FILETYPE     = 'BIN'
      FILENAME     = $FILENAME
    CHANGING
      DATA_TAB     = XML_STREAM.


  IF SY-SUBRC NE 0.
    MESSAGE E175(/ZAK/ZAK) WITH $FILENAME RAISING ERROR_DOWNLOAD.
*   Hiba a & fájl letöltésénél.
  ENDIF.



ENDFORM.                    " SAVE_KULF_XML_FILE
*&---------------------------------------------------------------------*
*&      Form  FIELDS_FROM_IT_BEVALLO_TO_XX65
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_/ZAK/BEVALLALV  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_LI_A_XX65  text
*      -->P_LI_M_XX65  text
*      -->P_LI_MS_XX65  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_IT_BEVALLO_TO_XX65  TABLES   IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
                                              IT_/ZAK/BEVALLB STRUCTURE
                                                         /ZAK/BEVALLB
                                              IT_TAB_A STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_M STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_MS.

  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: LW_TAB_MS  TYPE  /ZAK/MS_LINEXX65.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: LW_TAB  TYPE /ZAK/XML_GEN.
  DATA: L_ELOJEL.
*++1765 #16.
*  DATA: L_MEZOE(40).
  DATA: L_MEZOE(70).
*--1765 #16.
  DATA: L_ADOAZON TYPE /ZAK/ADOAZON.
  DATA: L_ABEVAZ TYPE /ZAK/ABEVAZ.

  TYPES: BEGIN OF LT_TAB_MA,
           ADOAZON TYPE /ZAK/ADOAZON.
           INCLUDE STRUCTURE /ZAK/XML_GEN.
         TYPES: END OF LT_TAB_MA.
  DATA: LI_TAB_MA TYPE STANDARD TABLE OF LT_TAB_MA
                  INITIAL SIZE 0 WITH HEADER LINE.

  DATA: LI_ADOAZON TYPE STANDARD TABLE OF /ZAK/ADOAZON
                   INITIAL SIZE 0 WITH HEADER LINE.
*++1365 #9.
* Érték figyelés ezen tartományon kívűl
  RANGES LR_ABEVAZ_VALUE FOR /ZAK/ANALITIKA-ABEVAZ.
  DATA   L_APPEND TYPE XFELD.
*--1365 #9.
*++1565 #02.
  DATA L_GET_NAME_ABEVAZ TYPE /ZAK/ABEVAZ.
*--1565 #02.

  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
    CONDENSE L_MEZOE.
  END-OF-DEFINITION.


  DEFINE LM_GET_NAME.
    DO 3 TIMES.
      CASE SY-INDEX.
        WHEN 1.
          L_ABEVAZ = &1.
        WHEN 2.
          L_ABEVAZ = &2.
        WHEN 3.
          L_ABEVAZ = &3.
      ENDCASE.
      READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                        ABEVAZ = L_ABEVAZ.
      IF SY-SUBRC EQ 0.
        IF NOT &4 IS INITIAL.
          CONCATENATE &4 LW_TAB-VALUE INTO &4 SEPARATED BY SPACE.
        ELSE.
          &4 = LW_TAB-VALUE.
        ENDIF.
      ENDIF.
    ENDDO.
  END-OF-DEFINITION.

  DEFINE LM_GET_ADOAZON.
    CLEAR &2.
    READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                    ABEVAZ = &1.
    IF SY-SUBRC EQ 0.
      &2 = LW_TAB-VALUE.
    ENDIF.
  END-OF-DEFINITION.

  LOOP AT IT_BEVALLO_ALV.
    CLEAR L_MEZOE.
*++1565 #02.
    IF L_GET_NAME_ABEVAZ IS INITIAL.
      IF IT_BEVALLO_ALV-BTYPE EQ C_1565
*++1665 #01. 2015.02.02
      OR IT_BEVALLO_ALV-BTYPE EQ C_1665
*--1665 #01. 2015.02.02
*++1765 #03. 2017.02.07
      OR IT_BEVALLO_ALV-BTYPE EQ C_1765
*--1765 #03. 2017.02.07
*++1865 #01. 2018.01.30
      OR IT_BEVALLO_ALV-BTYPE EQ C_1865
*--1865 #01. 2018.01.30
*++1965 #01.
      OR IT_BEVALLO_ALV-BTYPE EQ C_1965
*--1965 #01.
**++2065 #09.
**++2065 #01.
*      OR IT_BEVALLO_ALV-BTYPE EQ C_2065.
**--2065 #01.
      OR IT_BEVALLO_ALV-BTYPE(4) EQ C_2065.
*--2065 #09.
        L_GET_NAME_ABEVAZ = '0A0001C008A'.
*++2165 #01.
      ELSEIF IT_BEVALLO_ALV-BTYPE(4) EQ C_2165
*++2165 #04.
*++2265 #01.
      OR IT_BEVALLO_ALV-BTYPE(4) EQ C_2265
*--2265 #01.
*++2365 #01.
      OR IT_BEVALLO_ALV-BTYPE(4) EQ C_2365
*--2365 #01.
*++2465 #01.
      OR IT_BEVALLO_ALV-BTYPE(4) EQ C_2465
*--2465 #01.
*++2565 #01.
      OR IT_BEVALLO_ALV-BTYPE(4) EQ C_2565.
*--2565 #01.
*        L_GET_NAME_ABEVAZ = '0A0001C005A'.
        L_GET_NAME_ABEVAZ = '0A0001C006A'.
*--2165 #04.
*--2165 #01.
      ELSE.
        L_GET_NAME_ABEVAZ = '0A0001C007A'.
      ENDIF.
    ENDIF.
*--1565 #02.
*  Beállítás beolvasása
    READ  TABLE IT_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                   ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                   BINARY SEARCH.

    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.
*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.
*++1665 #08.
*  M-es ABEV azonosítóknál 0-ás flag feltöltés
    IF IT_BEVALLO_ALV-ABEVAZ(1) = 'M' AND W_/ZAK/BEVALLB-FIELDTYPE EQ 'N'.
      IT_BEVALLO_ALV-NULL_FLAG = C_X.
    ENDIF.
*--1665 #08.
*   Karakteres
    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*   Van érték vagy 0-ás mező és kell
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL OR
           NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
    ENDIF.
*++1665 #08.
*    CHECK NOT L_MEZOE IS INITIAL.
    CHECK NOT L_MEZOE IS INITIAL OR NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
*--1665 #08.
    CONDENSE L_MEZOE.
    LW_TAB-ABEVAZ = L_APEH_ABEVAZ.
    LW_TAB-VALUE  = L_MEZOE.

    IF IT_BEVALLO_ALV-ABEVAZ(1) = 'A'.
      APPEND LW_TAB TO IT_TAB_A.
    ELSEIF IT_BEVALLO_ALV-ABEVAZ(1) = 'M'.
      CLEAR LI_TAB_MA.
      MOVE IT_BEVALLO_ALV-ADOAZON TO LI_TAB_MA-ADOAZON.
      MOVE-CORRESPONDING LW_TAB TO LI_TAB_MA.
      APPEND LI_TAB_MA.
    ENDIF.

  ENDLOOP.

*++1365 #9.
  M_DEF LR_ABEVAZ_VALUE 'I' 'BT' '0A0001C001A' '0A0001D002A'.
  CLEAR L_APPEND.
*--1365 #9.

* Adószámonként szétszedjük
  SORT LI_TAB_MA BY ADOAZON.
  LOOP AT LI_TAB_MA.
    L_ADOAZON = LI_TAB_MA-ADOAZON.
    MOVE-CORRESPONDING LI_TAB_MA TO LW_TAB.
    APPEND LW_TAB TO IT_TAB_M.
*++1365 #9.
*   Érték vizsgálat bármelyik nem fő rész abev mezőre
    IF NOT LW_TAB-ABEVAZ IN LR_ABEVAZ_VALUE AND L_APPEND IS INITIAL.
      IF NOT LW_TAB-VALUE IS INITIAL.
        L_APPEND = 'X'.
      ENDIF.
    ENDIF.
*--1365 #9.

    AT END OF ADOAZON.
      SORT IT_TAB_M.
      CLEAR LW_TAB_MS.
*     Adóazonosítónak meg kell egyeznie az
*     ABEV kód értékével egyébként ABEV hiba!
      LW_TAB_MS-ADOAZON = L_ADOAZON.
*      lm_get_adoazon '0A0001C001A'
*                     lw_tab_ms-adoazon.
*     Név öszeállítása
*++1565 #02.
*      LM_GET_NAME '0A0001C007A'
      LM_GET_NAME L_GET_NAME_ABEVAZ
*--1565 #02.
                  ''
                  ''
                  LW_TAB_MS-NAME.
      LW_TAB_MS-MDATA[] = IT_TAB_M[].
*++1365 #9.
      IF NOT L_APPEND IS INITIAL.
*--1365 #9.
        APPEND LW_TAB_MS TO IT_TAB_MS.
*++1365 #9.
        CLEAR L_APPEND.
      ENDIF.
*--1365 #9.
      REFRESH IT_TAB_M.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " FIELDS_FROM_IT_BEVALLO_TO_XX65
*&---------------------------------------------------------------------*
*&      Form  FIELDS_FROM_IT_BEVALLO_TO_XX08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_/ZAK/BEVALLALV  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_LI_A_XX08  text
*      -->P_LI_M_XX08  text
*      -->P_LI_MS_XX08  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_IT_BEVALLO_TO_XX08  TABLES   IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
                                              IT_/ZAK/BEVALLB STRUCTURE
                                                         /ZAK/BEVALLB
                                              IT_TAB_A STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_M STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_MS.



  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: LW_TAB_MS  TYPE  /ZAK/MS_LINEXX65.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: LW_TAB  TYPE /ZAK/XML_GEN.
  DATA: L_ELOJEL.
*++1808 #05.
*  DATA: L_MEZOE(40).
  DATA: L_MEZOE(70).
*--1808 #05.
  DATA: L_ADOAZON TYPE /ZAK/ADOAZON.
  DATA: L_ABEVAZ TYPE /ZAK/ABEVAZ.

  TYPES: BEGIN OF LT_TAB_MA,
           ADOAZON TYPE /ZAK/ADOAZON.
           INCLUDE STRUCTURE /ZAK/XML_GEN.
         TYPES: END OF LT_TAB_MA.
  DATA: LI_TAB_MA TYPE STANDARD TABLE OF LT_TAB_MA
                  INITIAL SIZE 0 WITH HEADER LINE.

  DATA: LI_ADOAZON TYPE STANDARD TABLE OF /ZAK/ADOAZON
                   INITIAL SIZE 0 WITH HEADER LINE.
*++1365 #9.
* Érték figyelés ezen tartományon kívűl
  RANGES LR_ABEVAZ_VALUE FOR /ZAK/ANALITIKA-ABEVAZ.
  DATA   L_APPEND TYPE XFELD.
*--1365 #9.

  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
    CONDENSE L_MEZOE.
  END-OF-DEFINITION.


  DEFINE LM_GET_NAME.
    DO 3 TIMES.
      CASE SY-INDEX.
        WHEN 1.
          L_ABEVAZ = &1.
        WHEN 2.
          L_ABEVAZ = &2.
        WHEN 3.
          L_ABEVAZ = &3.
      ENDCASE.
      READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                        ABEVAZ = L_ABEVAZ.
      IF SY-SUBRC EQ 0.
        IF NOT &4 IS INITIAL.
          CONCATENATE &4 LW_TAB-VALUE INTO &4 SEPARATED BY SPACE.
        ELSE.
          &4 = LW_TAB-VALUE.
        ENDIF.
      ENDIF.
    ENDDO.
  END-OF-DEFINITION.

  DEFINE LM_GET_ADOAZON.
    CLEAR &2.
    READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                    ABEVAZ = &1.
    IF SY-SUBRC EQ 0.
      &2 = LW_TAB-VALUE.
    ENDIF.
  END-OF-DEFINITION.

  LOOP AT IT_BEVALLO_ALV.
    CLEAR L_MEZOE.
*  Beállítás beolvasása
    READ  TABLE IT_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                   ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                   BINARY SEARCH.

    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.
*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.
*   Karakteres
    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*   Van érték vagy 0-ás mező és kell
*++1408 #04. 2014.05.09
*    ELSEIF NOT it_bevallo_alv-field_nr IS INITIAL OR
*           NOT it_bevallo_alv-null_flag IS INITIAL.
    ELSEIF ( NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL AND
                 IT_BEVALLO_ALV-OFLAG IS INITIAL ) OR
           ( NOT W_/ZAK/BEVALLB-XMLALL IS INITIAL AND
             NOT IT_BEVALLO_ALV-OFLAG IS INITIAL ).
*--1408 #04. 2014.05.09
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
*++1408 #04. 2014.05.09
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_ONR IS INITIAL AND
           NOT IT_BEVALLO_ALV-OFLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_ONR IT_BEVALLO_ALV-WAERS.
*  0-ás mező ami kell
    ELSEIF NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
      IF IT_BEVALLO_ALV-OFLAG IS INITIAL.
        M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
      ELSE.
        M_SET_MEZOE IT_BEVALLO_ALV-FIELD_ONR IT_BEVALLO_ALV-WAERS.
      ENDIF.
*--1408 #04. 2014.05.09
    ENDIF.

    CHECK NOT L_MEZOE IS INITIAL.
    CONDENSE L_MEZOE.
    LW_TAB-ABEVAZ = L_APEH_ABEVAZ.
    LW_TAB-VALUE  = L_MEZOE.

    IF IT_BEVALLO_ALV-ABEVAZ(1) = 'A'.
      APPEND LW_TAB TO IT_TAB_A.
    ELSEIF IT_BEVALLO_ALV-ABEVAZ(1) = 'M'.
      CLEAR LI_TAB_MA.
      MOVE IT_BEVALLO_ALV-ADOAZON TO LI_TAB_MA-ADOAZON.
      MOVE-CORRESPONDING LW_TAB TO LI_TAB_MA.
      APPEND LI_TAB_MA.
    ENDIF.

  ENDLOOP.

*  m_def lr_abevaz_value 'I' 'BT' '0A0001C001A' '0A0001D002A'.
  CLEAR L_APPEND.

* Adószámonként szétszedjük
  SORT LI_TAB_MA BY ADOAZON.
  LOOP AT LI_TAB_MA.
    L_ADOAZON = LI_TAB_MA-ADOAZON.
    MOVE-CORRESPONDING LI_TAB_MA TO LW_TAB.
    APPEND LW_TAB TO IT_TAB_M.
*   Érték vizsgálat bármelyik nem fő rész abev mezőre
    IF  L_APPEND IS INITIAL AND NOT LW_TAB-VALUE IS INITIAL.
      L_APPEND = 'X'.
    ENDIF.

    AT END OF ADOAZON.
      SORT IT_TAB_M.
      CLEAR LW_TAB_MS.
*     Adóazonosítónak meg kell egyeznie az
*     ABEV kód értékével egyébként ABEV hiba!
      LW_TAB_MS-ADOAZON = L_ADOAZON.
*      lm_get_adoazon '0A0001C001A'
*                     lw_tab_ms-adoazon.
*++2108 #02.
      IF IT_BEVALLO_ALV-BTYPE EQ C_2108
*++2208 #03.
      OR IT_BEVALLO_ALV-BTYPE EQ C_2208
*--2208 #03.
*++2308 #02.
      OR IT_BEVALLO_ALV-BTYPE EQ C_2308
*--2308 #02.
*++2408 #01.
      OR IT_BEVALLO_ALV-BTYPE EQ C_2408.
*--2408 #01.
*     Név öszeállítása
        LM_GET_NAME '0A0001C017A'
                    '0A0001C018A'
                    '0A0001C019A'
                    LW_TAB_MS-NAME.
      ELSE.
*--2108 #02.
*     Név öszeállítása
        LM_GET_NAME '0A0001C016A'
                    '0A0001C017A'
                    '0A0001C018A'
                    LW_TAB_MS-NAME.
*++2108 #02.
      ENDIF.
*--2108 #02.
      LW_TAB_MS-MDATA[] = IT_TAB_M[].
      IF NOT L_APPEND IS INITIAL.
        APPEND LW_TAB_MS TO IT_TAB_MS.
        CLEAR L_APPEND.
      ENDIF.
      REFRESH IT_TAB_M.
    ENDAT.
  ENDLOOP.


ENDFORM.                    " FIELDS_FROM_IT_BEVALLO_TO_XX08
*++2108 #09.
*&---------------------------------------------------------------------*
*&      Form  FIELDS_FROM_IT_BEVALLO_TO_KULF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BEVALLO_ALV  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_I_TAB_A  text
*      -->P_I_TAB_M  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_IT_BEVALLO_TO_KATA  TABLES   IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
                                              IT_/ZAK/BEVALLB STRUCTURE
                                                         /ZAK/BEVALLB
                                              IT_TAB_A STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_M STRUCTURE
                                                         /ZAK/XML_GEN
                                              IT_TAB_MS.

  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: LW_TAB_MS  TYPE  /ZAK/MSLINEXXK79.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: LW_TAB  TYPE /ZAK/XML_GEN.
  DATA: L_ELOJEL.
*++2108 #14.
*  DATA: L_MEZOE(40).
  DATA: L_MEZOE TYPE /ZAK/FIELDC.
*--2108 #14.
  DATA: L_ADOAZON TYPE /ZAK/ADOAZON.
  DATA: L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: L_BTYPE_SAVE TYPE /ZAK/BTYPE.


  TYPES: BEGIN OF LT_TAB_MA,
           ADOAZON TYPE /ZAK/ADOAZON.
           INCLUDE STRUCTURE /ZAK/XML_GEN.
         TYPES: END OF LT_TAB_MA.
  DATA: LI_TAB_MA TYPE STANDARD TABLE OF LT_TAB_MA
                  INITIAL SIZE 0 WITH HEADER LINE.

  DATA: LI_ADOAZON TYPE STANDARD TABLE OF /ZAK/ADOAZON
                   INITIAL SIZE 0 WITH HEADER LINE.


  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
    CONDENSE L_MEZOE.
  END-OF-DEFINITION.


  DEFINE LM_GET_NAME.
    DO 3 TIMES.
      CASE SY-INDEX.
        WHEN 1.
          L_ABEVAZ = &1.
        WHEN 2.
          L_ABEVAZ = &2.
        WHEN 3.
          L_ABEVAZ = &3.
      ENDCASE.
      READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                        ABEVAZ = L_ABEVAZ.
      IF SY-SUBRC EQ 0.
        IF NOT &4 IS INITIAL.
          CONCATENATE &4 LW_TAB-VALUE INTO &4 SEPARATED BY SPACE.
        ELSE.
          &4 = LW_TAB-VALUE.
        ENDIF.
      ENDIF.
    ENDDO.
  END-OF-DEFINITION.

  DEFINE LM_GET_ADOAZON.
    CLEAR &2.
    READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                    ABEVAZ = &1.
    IF SY-SUBRC EQ 0.
      &2 = LW_TAB-VALUE.
    ENDIF.
  END-OF-DEFINITION.



  LOOP AT IT_BEVALLO_ALV.
*  Beállítás beolvasása
    READ  TABLE IT_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                   ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                   BINARY SEARCH.

    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.
*   Bevallás típusonként más a név!
    IF L_BTYPE_SAVE IS INITIAL.
      L_BTYPE_SAVE = IT_BEVALLO_ALV-BTYPE.
    ENDIF.

*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.
*   Karakteres
    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*   Van érték vagy 0-ás mező és kell
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL OR
           NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
    ENDIF.

    CHECK NOT L_MEZOE IS INITIAL.
    CONDENSE L_MEZOE.
    LW_TAB-ABEVAZ = L_APEH_ABEVAZ.
    LW_TAB-VALUE  = L_MEZOE.

    IF IT_BEVALLO_ALV-ABEVAZ(1) = 'A'.
      APPEND LW_TAB TO IT_TAB_A.
    ELSEIF IT_BEVALLO_ALV-ABEVAZ(1) = 'M'.
      CLEAR LI_TAB_MA.
      MOVE IT_BEVALLO_ALV-ADOAZON TO LI_TAB_MA-ADOAZON.
      MOVE-CORRESPONDING LW_TAB TO LI_TAB_MA.
      APPEND LI_TAB_MA.
    ENDIF.

  ENDLOOP.

* Adószámonként szétszedjük
  SORT LI_TAB_MA BY ADOAZON.
  LOOP AT LI_TAB_MA.
    L_ADOAZON = LI_TAB_MA-ADOAZON.
    MOVE-CORRESPONDING LI_TAB_MA TO LW_TAB.
    APPEND LW_TAB TO IT_TAB_M.
    AT END OF ADOAZON.
      SORT IT_TAB_M.
      CLEAR LW_TAB_MS.
*     Adóazonosítónak meg kell egyeznie az
*     ABEV kód értékével egyébként ABEV hiba!
      LM_GET_ADOAZON '0A0001C003A'
                     LW_TAB_MS-ADOAZON.
*     Név öszeállítása
      LM_GET_NAME '0A0001C004A'
                  ''
                  ''
                  LW_TAB_MS-NAME.
      LW_TAB_MS-MDATA[] = IT_TAB_M[].
      APPEND LW_TAB_MS TO IT_TAB_MS.
      REFRESH IT_TAB_M.
    ENDAT.
  ENDLOOP.



ENDFORM.                    " FIELDS_FROM_IT_BEVALLO_TO_KULF
*--2108 #09.
*++2308 #09.
*&---------------------------------------------------------------------*
*&      Form  FIELDS_FROM_IT_BEVALLO_TO_TAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_/ZAK/BEVALLALV  text
*      -->P_I_/ZAK/BEVALLB  text
*      -->P_LI_A_XX29  text
*----------------------------------------------------------------------*
FORM FIELDS_FROM_IT_BEVALLO_TO_TAO  TABLES   IT_BEVALLO_ALV STRUCTURE
                                                         /ZAK/BEVALLALV
                                              IT_/ZAK/BEVALLB STRUCTURE
                                                         /ZAK/BEVALLB
                                              IT_TAB_A STRUCTURE
                                                         /ZAK/XML_GEN.

  DATA: L_APEH_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: L_INDEX LIKE SY-TABIX.
  DATA: LW_TAB  TYPE /ZAK/XML_GEN.
  DATA: L_ELOJEL.
  DATA: L_MEZOE TYPE /ZAK/FIELDC.
  DATA: L_ADOAZON TYPE /ZAK/ADOAZON.
  DATA: L_ABEVAZ TYPE /ZAK/ABEVAZ.
  DATA: L_BTYPE_SAVE TYPE /ZAK/BTYPE.

  DEFINE M_SET_MEZOE.
    CLEAR L_ELOJEL.
*     Negatív előjel figyelése
    IF &1 < 0.
      MOVE '-' TO L_ELOJEL.
      &1 = ABS( &1 ).
    ENDIF.
    WRITE &1 CURRENCY &2
          TO L_MEZOE NO-GROUPING
                       DECIMALS 0
                       LEFT-JUSTIFIED.
    IF L_ELOJEL EQ '-'.
      CONCATENATE '-' L_MEZOE INTO L_MEZOE.
    ENDIF.
    CONDENSE L_MEZOE.
  END-OF-DEFINITION.

  DEFINE LM_GET_NAME.
    DO 3 TIMES.
      CASE SY-INDEX.
        WHEN 1.
          L_ABEVAZ = &1.
        WHEN 2.
          L_ABEVAZ = &2.
        WHEN 3.
          L_ABEVAZ = &3.
      ENDCASE.
      READ TABLE IT_TAB_M INTO LW_TAB WITH KEY
                        ABEVAZ = L_ABEVAZ.
      IF SY-SUBRC EQ 0.
        IF NOT &4 IS INITIAL.
          CONCATENATE &4 LW_TAB-VALUE INTO &4 SEPARATED BY SPACE.
        ELSE.
          &4 = LW_TAB-VALUE.
        ENDIF.
      ENDIF.
    ENDDO.
  END-OF-DEFINITION.


  LOOP AT IT_BEVALLO_ALV.
*  Beállítás beolvasása
    READ  TABLE IT_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
          WITH KEY BTYPE  = IT_BEVALLO_ALV-BTYPE
                   ABEVAZ = IT_BEVALLO_ALV-ABEVAZ
                   BINARY SEARCH.

    CHECK SY-SUBRC EQ 0 AND W_/ZAK/BEVALLB-ABEV_NO IS INITIAL.

*   APEH abevaz konvertálás
    PERFORM GET_ABEVAZ_TO_APEH USING IT_BEVALLO_ALV-ABEVAZ
                                     IT_BEVALLO_ALV-LAPSZ
                            CHANGING L_APEH_ABEVAZ.
*   Karakteres
    IF NOT IT_BEVALLO_ALV-FIELD_C IS INITIAL.
      MOVE IT_BEVALLO_ALV-FIELD_C TO L_MEZOE.
*   Van érték vagy 0-ás mező és kell
    ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL OR
           NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL.
      M_SET_MEZOE IT_BEVALLO_ALV-FIELD_NR IT_BEVALLO_ALV-WAERS.
    ENDIF.

    CHECK NOT L_MEZOE IS INITIAL.
    CONDENSE L_MEZOE.
    LW_TAB-ABEVAZ = L_APEH_ABEVAZ.
    LW_TAB-VALUE  = L_MEZOE.

    IF IT_BEVALLO_ALV-ABEVAZ(1) = 'A'.
      APPEND LW_TAB TO IT_TAB_A.
    ENDIF.
  ENDLOOP.

ENDFORM.
*--2308 #09.
