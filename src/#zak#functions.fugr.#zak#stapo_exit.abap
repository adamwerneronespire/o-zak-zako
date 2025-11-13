FUNCTION /ZAK/STAPO_EXIT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE
*"     REFERENCE(I_PACK) TYPE  /ZAK/PACK OPTIONAL
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA OPTIONAL
*"----------------------------------------------------------------------
  DATA:
        I_FREE_STAPO TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                         INITIAL SIZE 0.

*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                             *
*&---------------------------------------------------------------------*

  DATA: L_INDEX(3) TYPE N,
        L_GJAHR LIKE /ZAK/ANALITIKA-GJAHR,
        L_MONAT_TOL LIKE /ZAK/ANALITIKA-MONAT,
        L_MONAT_IG LIKE /ZAK/ANALITIKA-MONAT,
        L_BIDOSZ LIKE /ZAK/BEVALL-BIDOSZ.
  DATA: L_ZINDEX LIKE SY-TABIX.
*++BG 2006/06/20
  DATA  L_ADOAZON_SAVE TYPE /ZAK/ADOAZON.
*--BG 2006/06/20
*********************************************************

  SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
    WHERE BUKRS EQ I_BUKRS AND
          BTYPE EQ I_BTYPE.
  IF SY-SUBRC EQ 0.
    IF W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_SZJA OR
       W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_TARS OR
       W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_UCS OR
*++2108 #15.
      W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_KATA.
*--2108 #15.

      IF NOT I_PACK IS INITIAL.
* Delete statistics flag!
* Repeated upload, or upload
* Delete data created with an identifier via technical function,
* therefore in the previous
* closed return with that index the statistics flag is set to blank
        SELECT * INTO TABLE I_FREE_STAPO FROM /ZAK/ANALITIKA
                      WHERE BUKRS EQ I_BUKRS AND
                            PACK EQ I_PACK
*++2308 #03.
                      ORDER BY PRIMARY KEY.
*--2308 #03.
        IF NOT I_FREE_STAPO[] IS INITIAL.
          CLEAR L_ZINDEX.
*++BG 2006/06/20
          MOVE 'X' TO L_ADOAZON_SAVE. "Ensure it always runs in the first case
*--BG 2006/06/20
*++2308 #03.
          SORT I_FREE_STAPO.
*--2308 #03.
          LOOP AT I_FREE_STAPO INTO W_/ZAK/ANALITIKA.
*         To ensure dialog execution
            PERFORM PROCESS_IND_ITEM USING '1000'
                                           L_ZINDEX
                                           TEXT-P12.
            L_GJAHR     = W_/ZAK/ANALITIKA-GJAHR.
            L_MONAT_TOL = W_/ZAK/ANALITIKA-MONAT.
            AT NEW MONAT.
*++1508 #03.
              MOVE 'X' TO L_ADOAZON_SAVE. "Month change
*--1508 #03.

              CALL FUNCTION '/ZAK/SET_PERIOD'
                EXPORTING
                  I_BUKRS     = I_BUKRS
                  I_BTYPE     = I_BTYPE
                  I_GJAHR     = L_GJAHR
                  I_MONAT     = L_MONAT_TOL
                IMPORTING
                  E_GJAHR     = L_GJAHR
                  E_MONAT_TOL = L_MONAT_TOL
                  E_MONAT_IG  = L_MONAT_IG
                  E_BIDOSZ    = L_BIDOSZ.

              REFRESH R_MONAT.
              R_MONAT-SIGN   = 'I'.
              IF L_MONAT_TOL = L_MONAT_IG.
                R_MONAT-OPTION = 'EQ'.
                R_MONAT-LOW    = L_MONAT_TOL.
                R_MONAT-HIGH   = L_MONAT_TOL.
              ELSE.
                R_MONAT-OPTION = 'BT'.
                R_MONAT-LOW    = L_MONAT_TOL.
                R_MONAT-HIGH   = L_MONAT_IG.
              ENDIF.
              APPEND R_MONAT.

            ENDAT.
*++BG 2006/06/20
            IF L_ADOAZON_SAVE NE W_/ZAK/ANALITIKA-ADOAZON.
*--BG 2006/06/20
              CLEAR L_INDEX.
              IF W_/ZAK/ANALITIKA-ZINDEX NE '000'.
                L_INDEX = W_/ZAK/ANALITIKA-ZINDEX - 1.
                PERFORM SET_STAPO USING W_/ZAK/ANALITIKA
                          L_INDEX
                          ' '.
*              SELECT * FROM /ZAK/ANALITIKA
*              WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
*                    BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
*                    GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
*                    MONAT IN R_MONAT AND
*                    ZINDEX EQ L_INDEX AND
*                    ABEVAZ EQ W_/ZAK/ANALITIKA-ABEVAZ AND
*                    ADOAZON EQ W_/ZAK/ANALITIKA-ADOAZON AND
*                    BSZNUM EQ W_/ZAK/ANALITIKA-BSZNUM.
*                /ZAK/ANALITIKA-STAPO = ' '.
*                MODIFY /ZAK/ANALITIKA.
*              ENDSELECT.
              ENDIF.
*++BG 2006/06/20
              MOVE W_/ZAK/ANALITIKA-ADOAZON TO L_ADOAZON_SAVE.
*--BG 2006/06/20
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.



* Mark statistics flag!
* New analytics entries, so for the previous
* closed return with that index I set the statistics flag to 'X'
      CLEAR L_ZINDEX.
*++BG 2006/06/20
      MOVE 'X' TO L_ADOAZON_SAVE. "Ensure it always runs in the first case
*--BG 2006/06/20
      LOOP AT T_ANALITIKA INTO W_/ZAK/ANALITIKA.
*       To ensure dialog execution
        PERFORM PROCESS_IND_ITEM USING '1000'
                                       L_ZINDEX
                                       TEXT-P12.

        L_GJAHR     = W_/ZAK/ANALITIKA-GJAHR.
        L_MONAT_TOL = W_/ZAK/ANALITIKA-MONAT.
        AT NEW MONAT. "#EC_CI_SORTED
*++1508 #03.
          MOVE 'X' TO L_ADOAZON_SAVE. "Month change
*--1508 #03.

          CALL FUNCTION '/ZAK/SET_PERIOD'
            EXPORTING
              I_BUKRS     = I_BUKRS
              I_BTYPE     = I_BTYPE
              I_GJAHR     = L_GJAHR
              I_MONAT     = L_MONAT_TOL
            IMPORTING
              E_GJAHR     = L_GJAHR
              E_MONAT_TOL = L_MONAT_TOL
              E_MONAT_IG  = L_MONAT_IG
              E_BIDOSZ    = L_BIDOSZ.

          REFRESH R_MONAT.
          R_MONAT-SIGN   = 'I'.
          IF L_MONAT_TOL = L_MONAT_IG.
            R_MONAT-OPTION = 'EQ'.
            R_MONAT-LOW    = L_MONAT_TOL.
            R_MONAT-HIGH   = L_MONAT_TOL.
          ELSE.
            R_MONAT-OPTION = 'BT'.
            R_MONAT-LOW    = L_MONAT_TOL.
            R_MONAT-HIGH   = L_MONAT_IG.
          ENDIF.
          APPEND R_MONAT.

        ENDAT.
*++BG 2006/06/20
        IF L_ADOAZON_SAVE NE W_/ZAK/ANALITIKA-ADOAZON.
*--BG 2006/06/20
          CLEAR L_INDEX.
          IF W_/ZAK/ANALITIKA-ZINDEX NE '000'.
            L_INDEX = W_/ZAK/ANALITIKA-ZINDEX - 1.
            PERFORM SET_STAPO USING W_/ZAK/ANALITIKA
                                    L_INDEX
                                    'X'.

*          L_INDEX = W_/ZAK/ANALITIKA-ZINDEX - 1.
*          SELECT * FROM /ZAK/ANALITIKA
*          WHERE BUKRS EQ W_/ZAK/ANALITIKA-BUKRS AND
*                BTYPE EQ W_/ZAK/ANALITIKA-BTYPE AND
*                GJAHR EQ W_/ZAK/ANALITIKA-GJAHR AND
*                MONAT IN R_MONAT AND
*                ZINDEX EQ L_INDEX AND
*                ABEVAZ EQ W_/ZAK/ANALITIKA-ABEVAZ AND
*                ADOAZON EQ W_/ZAK/ANALITIKA-ADOAZON AND
*                BSZNUM EQ W_/ZAK/ANALITIKA-BSZNUM.
*            /ZAK/ANALITIKA-STAPO = 'X'.
*            MODIFY /ZAK/ANALITIKA.
*          ENDSELECT.
          ENDIF.
*++BG 2006/06/20
          MOVE W_/ZAK/ANALITIKA-ADOAZON TO L_ADOAZON_SAVE.
*--BG 2006/06/20
        ENDIF.
      ENDLOOP.
    ENDIF.
    COMMIT WORK.
  ENDIF.
*********************************************************

ENDFUNCTION.
*&---------------------------------------------------------------------*
*&      Form  set_stapo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_/ZAK/ANALITIKA  text
*      -->P_L_INDEX  text
*----------------------------------------------------------------------*
FORM SET_STAPO USING    $/ZAK/ANALITIKA STRUCTURE W_/ZAK/ANALITIKA
                        $INDEX
                        $STAPO.

*++BG 2006/06/20
*  SELECT * FROM /ZAK/ANALITIKA
*  WHERE BUKRS EQ $/ZAK/ANALITIKA-BUKRS AND
*        BTYPE EQ $/ZAK/ANALITIKA-BTYPE AND
*        GJAHR EQ $/ZAK/ANALITIKA-GJAHR AND
*        MONAT IN R_MONAT AND
*        ZINDEX EQ $INDEX AND
**++BG 2006/06/12
**No need to check the ABEV identifier because it might not
**exist in the previous period
**       ABEVAZ EQ $/ZAK/ANALITIKA-ABEVAZ AND
**--BG 2006/06/12
*        ADOAZON EQ $/ZAK/ANALITIKA-ADOAZON AND
*        BSZNUM EQ $/ZAK/ANALITIKA-BSZNUM.
*
*    /ZAK/ANALITIKA-STAPO = $STAPO.
*    MODIFY /ZAK/ANALITIKA.
*  ENDSELECT.
  UPDATE /ZAK/ANALITIKA SET  STAPO = $STAPO
                     WHERE BUKRS EQ $/ZAK/ANALITIKA-BUKRS AND
                           BTYPE EQ $/ZAK/ANALITIKA-BTYPE AND
                           GJAHR EQ $/ZAK/ANALITIKA-GJAHR AND
                           MONAT IN R_MONAT AND
                           ZINDEX EQ $INDEX AND
                           ADOAZON EQ $/ZAK/ANALITIKA-ADOAZON AND
                           BSZNUM EQ $/ZAK/ANALITIKA-BSZNUM.
*--BG 2006/06/20
  IF SY-SUBRC NE 0 AND $INDEX NE '000'.
    $INDEX = $INDEX - 1.
    PERFORM SET_STAPO USING W_/ZAK/ANALITIKA
                            $INDEX
                            $STAPO.

*++BG 2007.06.12
* In some cases the UPDATE function did not
* mark every item defined above as statistical,
* which led to declaration errors, therefore we must check
  ELSEIF SY-SUBRC EQ 0.
    SELECT COUNT( * )
                     FROM /ZAK/ANALITIKA
*++BG 2007.08.16
                          UP TO 1 ROWS
*--BG 2007.08.16
                    WHERE BUKRS EQ $/ZAK/ANALITIKA-BUKRS AND
                          BTYPE EQ $/ZAK/ANALITIKA-BTYPE AND
                          GJAHR EQ $/ZAK/ANALITIKA-GJAHR AND
                          MONAT IN R_MONAT AND
                          ZINDEX EQ $INDEX AND
                          ADOAZON EQ $/ZAK/ANALITIKA-ADOAZON AND
                          BSZNUM EQ $/ZAK/ANALITIKA-BSZNUM
                          AND STAPO NE $STAPO.

    IF SY-SUBRC EQ 0.
      ROLLBACK WORK.
      MESSAGE A224(/ZAK/ZAK).
*    Severe database error when marking the statistics flag!
    ENDIF.
*--BG 2007.06.12
  ENDIF.
ENDFORM.                    " set_stapo
