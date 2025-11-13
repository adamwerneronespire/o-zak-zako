FUNCTION /ZAK/STAPO_EXIT.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
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
*& KONSTANSOK  (C_XXXXXXX..)                                           *
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
* statisztika flag törlése!
* ismételt feltöltés, vagy feltöltés
* azonosítóval létrehozott adatokat törlünk technikai funkcióval,
* így a megelőző
* indexű lezárt bevallásnál a statisztikai flag-et üresre módosítom
        SELECT * INTO TABLE I_FREE_STAPO FROM /ZAK/ANALITIKA
                      WHERE BUKRS EQ I_BUKRS AND
                            PACK EQ I_PACK
*++2308 #03.
                      ORDER BY PRIMARY KEY.
*--2308 #03.
        IF NOT I_FREE_STAPO[] IS INITIAL.
          CLEAR L_ZINDEX.
*++BG 2006/06/20
          MOVE 'X' TO L_ADOAZON_SAVE. "Első esetben mindig lefusson
*--BG 2006/06/20
*++2308 #03.
          SORT I_FREE_STAPO.
*--2308 #03.
          LOOP AT I_FREE_STAPO INTO W_/ZAK/ANALITIKA.
*         Dialógus futás biztosításhoz
            PERFORM PROCESS_IND_ITEM USING '1000'
                                           L_ZINDEX
                                           TEXT-P12.
            L_GJAHR     = W_/ZAK/ANALITIKA-GJAHR.
            L_MONAT_TOL = W_/ZAK/ANALITIKA-MONAT.
            AT NEW MONAT.
*++1508 #03.
              MOVE 'X' TO L_ADOAZON_SAVE. "Hónapváltás
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



* statisztika flag jelölése !
* Új analitika bejegyzések, így a megelőző
* indexű lezárt bevallásnál a statisztikai flag-et 'X'-re módosítom
      CLEAR L_ZINDEX.
*++BG 2006/06/20
      MOVE 'X' TO L_ADOAZON_SAVE. "Első esetben mindig lefusson
*--BG 2006/06/20
      LOOP AT T_ANALITIKA INTO W_/ZAK/ANALITIKA.
*       Dialógus futás biztosításhoz
        PERFORM PROCESS_IND_ITEM USING '1000'
                                       L_ZINDEX
                                       TEXT-P12.

        L_GJAHR     = W_/ZAK/ANALITIKA-GJAHR.
        L_MONAT_TOL = W_/ZAK/ANALITIKA-MONAT.
        AT NEW MONAT. "#EC_CI_SORTED
*++1508 #03.
          MOVE 'X' TO L_ADOAZON_SAVE. "Hónapváltás
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
**Nem kell ABEV azonosítót vizsgálni mert nem biztos, hogy
**adott ez előző időszakban
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
* Bizonyos esetekben előfodult, hogy az UPDATE funkció nem
* jelölte statisztikai tételre fentiekben meghatározott összes
* tételt, ami bevallás hibához vezetett, ezért le kell ellenőrizni
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
*    Súlyos adatbázis hiba a statisztikai flag jelölésnél!
    ENDIF.
*--BG 2007.06.12
  ENDIF.
ENDFORM.                    " set_stapo
