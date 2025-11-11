FUNCTION /ZAK/UPDATE.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BTYPE) TYPE  /ZAK/BTYPE OPTIONAL
*"     VALUE(I_BTYPART) TYPE  /ZAK/BTYPART OPTIONAL
*"     VALUE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"     REFERENCE(I_PACK) TYPE  /ZAK/PACK OPTIONAL
*"     VALUE(I_GEN) TYPE  CHAR01
*"     VALUE(I_TEST) TYPE  CHAR1 DEFAULT 'X'
*"     REFERENCE(I_FILE) TYPE  FC03TAB-PL00_FILE OPTIONAL
*"  TABLES
*"      I_ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"      I_AFA_SZLA STRUCTURE  /ZAK/AFA_SZLA OPTIONAL
*"      E_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA: L_SUBRC LIKE SY-SUBRC.

*++S4HANA#01.
*  REFRESH E_RETURN.
  CLEAR E_RETURN[].
*--S4HANA#01.

* ++BG
* BTYPART megadva, konvertálunk
  IF NOT I_BTYPART IS INITIAL.
*    PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '115'
*                                 SPACE
*                                 SPACE
*                                 SPACE
*                                 SPACE.
*    E_RETURN[] = IG_RETURN[].
* Analitika tábla BTYPE meghatározása időszakonként
    PERFORM GET_BTYPE TABLES I_ANALITIKA
                      USING  I_BUKRS
                             I_BTYPART.
  ENDIF.
* --BG

*++1465 #10.
  IF NOT I_GEN IS INITIAL AND NOT I_PACK IS INITIAL.
*   Úgy kezelem mintha ő generálná a package-t
    PERFORM CHECK_BEVALL USING I_ANALITIKA[]
                               I_UPD_BEVALLI[]
                               I_UPD_BEVALLSZ[]
                               ''
                               I_BSZNUM
                               I_GEN.
  ELSE.
*--1465 #10.
*   normál bevallás
    PERFORM CHECK_BEVALL USING I_ANALITIKA[]
                               I_UPD_BEVALLI[]
                               I_UPD_BEVALLSZ[]
                               I_PACK
                               I_BSZNUM
                               I_GEN.
*++1465 #10.
  ENDIF.
*--1465 #10.
*++BG 2008.11.17
* BEVALLI rendezés: negyedéves és éves adatoknál, ha
* nem volt az analitikába valamelyik időszakra adat akkor nem
* jött létre a BEVALLI rekord. Viszont mivel a BEVALLO
* mindig időszak utolsó hónapjára íródik, ezért bizonyos
* esetekben gondot okoz, hogy nincs hozzá BEVALLI. Ezért
* ez a rutin ellenőrzi, hogy megfelelő e a BEVALLI konzisztencia
  PERFORM CHECK_BEVALLI TABLES I_UPD_BEVALLI.
*--BG 2008.11.17

  READ TABLE I_RETURN WITH KEY ID = 'E' INTO W_RETURN.
* Error hiba , nincs adatbázis tábla update!
  IF SY-SUBRC NE 0.
    IF I_TEST IS INITIAL.
* packade azonosító generálása
      IF I_GEN  EQ 'X'.
*++1465 #10.
        IF NOT I_PACK IS INITIAL.
          V_/ZAK/PACK = I_PACK.
        ELSE.
*--1465 #10.
* package számkör
          CALL FUNCTION '/ZAK/NEW_PACKAGE_NUMBER'
            IMPORTING
              E_PACK           = V_/ZAK/PACK
            EXCEPTIONS
              ERROR_GET_NUMBER = 1
              OTHERS           = 2.
          IF SY-SUBRC <> 0.
*          PERFORM ERROR_HANDLING USING SY-MSGID SY-MSGTY SY-MSGNO
*                                       SY-MSGV1 SY-MSGV2 SY-MSGV3
*                                       SY-MSGV4.
            MESSAGE A001(/ZAK/ZAK).
*         Feltöltés azonosító számkör hiba!
          ENDIF.
*++1465 #10.
        ENDIF.
*--1465 #10.
        W_/ZAK/BEVALLP-BUKRS = I_BUKRS.
*++1465 #10.
*        IF NOT I_PACK IS INITIAL.
        IF NOT I_PACK IS INITIAL AND I_GEN IS INITIAL.
*--1465 #10.
* Ismételt feltöltés!
          W_/ZAK/BEVALLP-SPACK  = I_PACK.
        ENDIF.
        W_/ZAK/BEVALLP-DATUM = SY-DATUM.
        W_/ZAK/BEVALLP-UZEIT = SY-UZEIT.
        W_/ZAK/BEVALLP-UNAME = SY-UNAME.
        W_/ZAK/BEVALLP-PACK  = V_/ZAK/PACK.
        W_/ZAK/BEVALLP-ZFILE  = I_FILE.
*++1465 #06.
        IF NOT I_BTYPART IS INITIAL.
          W_/ZAK/BEVALLP-BTYPART = I_BTYPART.
        ELSE.
          CALL FUNCTION '/ZAK/GET_BTYPART_FROM_BTYPE'
            EXPORTING
              I_BUKRS   = I_BUKRS
              I_BTYPE   = I_BTYPE
            IMPORTING
              E_BTYPART = W_/ZAK/BEVALLP-BTYPART.
        ENDIF.
*--1465 #06.
*++1465 #10.
*        IF NOT I_PACK IS INITIAL.
        IF NOT I_PACK IS INITIAL AND I_GEN IS INITIAL.
*--1465 #10.
*++S4HANA#01.
*          SELECT SINGLE * FROM /ZAK/BEVALLP
          SELECT SINGLE * FROM /ZAK/BEVALLP INTO /ZAK/BEVALLP
*--S4HANA#01.
                 WHERE BUKRS EQ W_/ZAK/BEVALLP-BUKRS AND
                       PACK  EQ I_PACK.
          IF SY-SUBRC NE 0.
*   Nincsen megadott Feltöltés azonosító!
            PERFORM ERROR_HANDLING USING '/ZAK/ZAK' 'E' '038'
                                         I_PACK
                                         SY-MSGV2
                                         SY-MSGV3
                                         SY-MSGV4 .
            L_SUBRC = 8.
          ELSE.
            W_/ZAK/BEVALLP-SPACK = I_PACK.
          ENDIF.
        ENDIF.
        IF L_SUBRC NE 0.
          IF SY-SUBRC NE 0.
* sikertelen a /ZAK/BEVALLP tábla írása!
            PERFORM ERROR_HANDLING USING SY-MSGID SY-MSGTY SY-MSGNO
                                         SY-MSGV1 SY-MSGV2 SY-MSGV3
                                         SY-MSGV4 .
          ENDIF.
        ELSE.
          INSERT INTO /ZAK/BEVALLP VALUES W_/ZAK/BEVALLP.
        ENDIF.
      ENDIF.
      IF L_SUBRC EQ 0.
* a statisztikai flag módosítás, csak teljes adatszolgáltatás
* ismétlésnél lehettséges.
*++S4HANA#01.
*        SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
        SELECT SINGLE BSZNUM
        INTO CORRESPONDING FIELDS OF W_/ZAK/BEVALLD
        FROM /ZAK/BEVALLD         "$smart: #712
*--S4HANA#01.
        WHERE BUKRS  EQ I_BUKRS AND
              BTYPE  EQ I_BTYPE AND
              BSZNUM EQ I_BSZNUM AND
              XFULL  EQ 'X'.
        IF SY-SUBRC EQ 0.
* Szja bevall. Önrev.-ra feltöltésnél előző indexű, azonos
* adaszolgáltatás és adószámhoz tartozó tételeket statisztikai tételként
* kell megjelölni.
          CALL FUNCTION '/ZAK/STAPO_EXIT'
            EXPORTING
              I_BUKRS     = I_BUKRS
              I_BTYPE     = I_BTYPE
              I_PACK      = I_PACK
            TABLES
              T_ANALITIKA = I_ANALITIKA[].
        ENDIF.
        IF NOT I_PACK IS INITIAL AND I_GEN  EQ 'X'.
* ismételt bevallás! Törlünk minden korábbi adatot, ahol nem lezárt
* az időszak
*++BG 2006/06/08
*          PERFORM DELETE_ABEV_TABLE  USING I_ANALITIKA[]
*                                           I_UPD_BEVALLI[]
*                                           I_UPD_BEVALLSZ[]
*                                           V_/ZAK/PACK.

          PERFORM DELETE_ABEV_TABLEN USING I_ANALITIKA[]
                                           I_UPD_BEVALLI[]
                                           I_PACK.

*--BG 2006/06/08

        ENDIF.
        PERFORM INSERT_ABEV_TABLE USING I_ANALITIKA[]
*++1365 2013.01.22 Balázs Gábor (Ness)
                                        I_AFA_SZLA[]
*--1365 2013.01.22 Balázs Gábor (Ness)
                                        I_UPD_BEVALLI[]
                                        I_UPD_BEVALLSZ[]
                                        I_PACK
                                        V_/ZAK/PACK
                                        I_GEN.
      ENDIF.
    ENDIF.
  ENDIF.
  SORT IG_RETURN BY TYPE ID NUMBER MESSAGE_V1 MESSAGE_V2.
  DELETE ADJACENT DUPLICATES FROM IG_RETURN
         COMPARING TYPE ID NUMBER MESSAGE_V1 MESSAGE_V2.

  E_RETURN[] = IG_RETURN[].
ENDFUNCTION.
