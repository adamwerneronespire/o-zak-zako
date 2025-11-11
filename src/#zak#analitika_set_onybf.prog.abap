*&---------------------------------------------------------------------*
*& Report  /ZAK/ANALITIKA_SET_ONYBF
*&
*&---------------------------------------------------------------------*
*& A program a /ZAK/ANALITIKA tábla ONYBF mezőjét tölti fel:
*& Feltételek:
*&    - /ZAK/BEVALLB-ONYBF = 'X' (ABEV azonosítók)
*&    - feltöltés azonosító <= 2008.01.21
*&    - /ZAK/ANALITIKA-GJAHR < 2008
*&---------------------------------------------------------------------*
REPORT  /ZAK/ANALITIKA_SET_ONYBF  MESSAGE-ID /ZAK/ZAK.

INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE /ZAK/SAP_SEL_F01.


*MAKRO definiálás range feltöltéshez
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.

RANGES R_BTYPE FOR /ZAK/ANALITIKA-BTYPE.
RANGES R_PACK  FOR /ZAK/ANALITIKA-PACK.

SELECT-OPTIONS S_BUKRS FOR /ZAK/ANALITIKA-BUKRS OBLIGATORY.
SELECT-OPTIONS S_PACK  FOR /ZAK/ANALITIKA-PACK.
*++2011.01.27 BG
SELECT-OPTIONS S_GJAHR FOR /ZAK/ANALITIKA-BSEG_GJAHR NO INTERVALS
                                                    NO-EXTENSION.
SELECT-OPTIONS S_BELNR FOR /ZAK/ANALITIKA-BSEG_BELNR.
*--2011.01.27 BG
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
*++2011.01.27 BG
AT SELECTION-SCREEN.
  IF S_PACK[] IS INITIAL AND
     S_GJAHR[] IS INITIAL AND
     S_BELNR[] IS INITIAL.
    MESSAGE E292.
*   Kérem adjon meg további éretéket a szelekción!
  ENDIF.
*--2011.01.27 BG

START-OF-SELECTION.

  PERFORM GET_ONYB_ABEV TABLES I_ONYB_ABEV.
  IF I_ONYB_ABEV[] IS INITIAL.
    MESSAGE E268.
*    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei!
  ENDIF.

* Feltöltjük a bevallás típusokat:
*  m_def r_btype 'I' 'EQ' '0665' space.
*  m_def r_btype 'I' 'EQ' '0765' space.
*  m_def r_btype 'I' 'EQ' '0865' space.
*  m_def r_btype 'I' 'EQ' '0965' space.
*  m_def r_btype 'I' 'EQ' '1065' space.

* Meghatározzuk a feltöltés azonosítókat:
*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'.

* Adatok leválogatása
  SELECT * INTO TABLE I_/ZAK/ANALITIKA
           FROM /ZAK/ANALITIKA
           FOR ALL ENTRIES IN I_ONYB_ABEV
          WHERE BUKRS  IN S_BUKRS
            AND BTYPE  EQ I_ONYB_ABEV-BTYPE
*            AND gjahr  <  '2008'
            AND ABEVAZ EQ I_ONYB_ABEV-ABEVAZ
*++2011.01.27 BG
            AND BSEG_GJAHR IN S_GJAHR
            AND BSEG_BELNR IN S_BELNR
*--2011.01.27 BG
*            AND pack   IN r_pack
            AND PACK   IN S_PACK
            AND ONYBF  EQ ''.
*++2011.01.27 BG
  IF SY-SUBRC NE 0.
    MESSAGE E141.
*   Nincs a feltételnek megfelelő analitika rekord!
    EXIT.
  ENDIF.
*--2011.01.27 BG

  W_/ZAK/ANALITIKA-ONYBF = C_X.

  MODIFY I_/ZAK/ANALITIKA FROM W_/ZAK/ANALITIKA TRANSPORTING ONYBF
                        WHERE ONYBF IS INITIAL.

  UPDATE /ZAK/ANALITIKA FROM TABLE I_/ZAK/ANALITIKA.

  COMMIT WORK AND WAIT.

  MESSAGE I223.
* Az adatok mentése sikeresen megtörtént!


END-OF-SELECTION.
