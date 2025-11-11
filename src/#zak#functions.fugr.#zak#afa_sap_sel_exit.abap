FUNCTION /ZAK/AFA_SAP_SEL_EXIT.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BTYPART) TYPE  /ZAK/BTYPART
*"     REFERENCE(I_BSZNUM) TYPE  /ZAK/BSZNUM
*"  TABLES
*"      T_ANALITIKA STRUCTURE  /ZAK/ANALITIKA
*"----------------------------------------------------------------------
  DATA L_TRUE.
  DATA LI_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                              INITIAL SIZE 0.
  DATA LW_ANALITIKA TYPE /ZAK/ANALITIKA.
  DATA LI_AFA_ATV TYPE STANDARD TABLE OF /ZAK/AFA_ATV
                                         INITIAL SIZE 0.
  DATA LW_AFA_ATV TYPE /ZAK/AFA_ATV.
  DATA L_NUMC6_1 TYPE NUM06.
  DATA L_NUMC6_2 TYPE NUM06.
*++0965 2009.02.10 BG
  DATA L_BTYPE TYPE /ZAK/BTYPE.
  DATA L_ABEVAZ_ALAP TYPE /ZAK/ABEVAZ.
  DATA L_ABEVAZ_ADO  TYPE /ZAK/ABEVAZ.
*--0965 2009.02.10 BG
* Egyéb adatok meghatározása
* Itt határozzuk meg az adatbázis szelekción kívüli rekordokat
* Beolvassuk az előleg kezeléshez szükséges adatbázis táblát
  SELECT * INTO TABLE LI_AFA_ATV
           FROM /ZAK/AFA_ATV
          WHERE BUKRS EQ I_BUKRS.
  SORT LI_AFA_ATV BY BUKRS ABEV_FROM.
* EVA szállítók figyelembe vétele
  LOOP AT T_ANALITIKA INTO W_/ZAK/ANALITIKA.
    IF W_/ZAK/ANALITIKA-KOART EQ 'K'.
*     Adószám ellenőrzés
      PERFORM GET_EVA_STCD1 USING W_/ZAK/ANALITIKA-STCD1
                         CHANGING L_TRUE.
*     Ha EVA-s az adószám sorok beszúrása
      IF NOT L_TRUE IS INITIAL.
*       Ellenőrizzük, hogy feldolgoztuk-e már
        READ TABLE LI_ANALITIKA INTO LW_ANALITIKA WITH KEY
                   BSEG_BELNR = W_/ZAK/ANALITIKA-BSEG_BELNR
                   BSEG_BUZEI = W_/ZAK/ANALITIKA-BSEG_BUZEI.
        IF SY-SUBRC NE 0.
*++0965 2009.02.10 BG
*       BTYPE meghatározása
          CALL FUNCTION '/ZAK/GET_BTYPE_FROM_BTYPART'
            EXPORTING
              I_BUKRS     = W_/ZAK/ANALITIKA-BUKRS
              I_BTYPART   = I_BTYPART
              I_GJAHR     = W_/ZAK/ANALITIKA-GJAHR
              I_MONAT     = W_/ZAK/ANALITIKA-MONAT
            IMPORTING
              E_BTYPE     = L_BTYPE
            EXCEPTIONS
              ERROR_MONAT = 1
              ERROR_BTYPE = 2
              OTHERS      = 3.
          IF SY-SUBRC <> 0.
            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            CONTINUE.
          ENDIF.
*         0865
          IF L_BTYPE EQ C_0865.
            L_ABEVAZ_ALAP = C_ABEVAZ_6306.
            L_ABEVAZ_ADO  = C_ABEVAZ_6307.
*         0965, 1065, 1165, 1265
*++1365 #6.
*          ELSE.
          ELSEIF L_BTYPE EQ C_0965 OR
                 L_BTYPE EQ C_1065 OR
                 L_BTYPE EQ C_1165 OR
                 L_BTYPE EQ C_1265.
*--1365 #6.
            L_ABEVAZ_ALAP = C_ABEVAZ_7995.
            L_ABEVAZ_ADO  = C_ABEVAZ_7996.
*++1365 #6.
          ELSE.
            L_ABEVAZ_ALAP = C_ABEVAZ_A0DC0080BA.
            L_ABEVAZ_ADO  = C_ABEVAZ_A0DC0080CA.
*--1365 #6.
          ENDIF.
*--0965 2009.02.10 BG
*         Adóalap
*++0965 2009.02.10 BG
*         MOVE '6306'  TO w_/zak/analitika-abevaz.
          MOVE L_ABEVAZ_ALAP TO W_/ZAK/ANALITIKA-ABEVAZ.
*--0965 2009.02.10 BG
*         Tétel meghatározás
*++1765 #20.
*          PERFORM GET_ANALITIKA_ITEM(/ZAK/AFA_SAP_SEL)
          PERFORM GET_ANALITIKA_ITEM(/ZAK/AFA_SAP_SELN)
*--1765 #20.
                              TABLES LI_ANALITIKA
                               USING W_/ZAK/ANALITIKA.
          MOVE W_/ZAK/ANALITIKA-LWBAS TO W_/ZAK/ANALITIKA-FIELD_N.
          APPEND W_/ZAK/ANALITIKA TO LI_ANALITIKA.
*         Adóösszeg
*++0965 2009.02.10 BG
*         MOVE '6307'  TO w_/zak/analitika-abevaz.
          MOVE L_ABEVAZ_ADO TO W_/ZAK/ANALITIKA-ABEVAZ.
*--0965 2009.02.10 BG
*         Tétel meghatározás
*++1765 #20.
*          PERFORM GET_ANALITIKA_ITEM(/ZAK/AFA_SAP_SEL)
          PERFORM GET_ANALITIKA_ITEM(/ZAK/AFA_SAP_SELN)
*--1765 #20.
                              TABLES LI_ANALITIKA
                               USING W_/ZAK/ANALITIKA.
          MOVE W_/ZAK/ANALITIKA-LWSTE TO W_/ZAK/ANALITIKA-FIELD_N.
          APPEND W_/ZAK/ANALITIKA TO LI_ANALITIKA.
        ENDIF.
      ENDIF.
    ENDIF.
*  Előleges tételek kezelése
    READ TABLE LI_AFA_ATV INTO LW_AFA_ATV
                          WITH KEY ABEV_FROM = W_/ZAK/ANALITIKA-ABEVAZ
                          BINARY SEARCH.
*   Van rekord meg kell vizsgálni az átvezetést
    IF SY-SUBRC EQ 0.
      MOVE 'X' TO L_TRUE.
*     KOART vizsgálat
      IF LW_AFA_ATV-KOART NE W_/ZAK/ANALITIKA-KOART.
        CLEAR L_TRUE.
      ENDIF.
*     UMSKZ vizsgálat
      IF NOT W_/ZAK/ANALITIKA-UMSKZ BETWEEN LW_AFA_ATV-UMSKZ_FROM
                                       AND LW_AFA_ATV-UMSKZ_TO.
        CLEAR L_TRUE.
      ENDIF.
*     BSCHL vizsgálat
      IF NOT LW_AFA_ATV-BSCHL IS INITIAL AND
         LW_AFA_ATV-BSCHL NE W_/ZAK/ANALITIKA-BSCHL.
        CLEAR L_TRUE.
      ENDIF.
*     AUGDT vizsgálat
      IF NOT LW_AFA_ATV-AUGDT_FLAG IS INITIAL.
        CASE LW_AFA_ATV-AUGDT_FLAG.
*          Iniciális
          WHEN '1'.
            IF NOT W_/ZAK/ANALITIKA-AUGDT IS INITIAL.
              CLEAR L_TRUE.
            ENDIF.
*          Kisebb mint a bevallás időszak
          WHEN '2'.
*           Analitika ÉV+HÓNAP
            CONCATENATE W_/ZAK/ANALITIKA-GJAHR
                        W_/ZAK/ANALITIKA-MONAT INTO L_NUMC6_1.
*           AUGDT ÉV+HÓNAP
            L_NUMC6_2(4)   = W_/ZAK/ANALITIKA-AUGDT(4).
            L_NUMC6_2+4(2) = W_/ZAK/ANALITIKA-AUGDT+4(2).
            IF NOT L_NUMC6_2 < L_NUMC6_1.
              CLEAR L_TRUE.
            ENDIF.
        ENDCASE.
      ENDIF.
*     Ha kell másolni
      IF NOT L_TRUE IS INITIAL.
        CLEAR LW_ANALITIKA.
        MOVE-CORRESPONDING W_/ZAK/ANALITIKA TO LW_ANALITIKA.
*       Abev azonosító csere.
        MOVE LW_AFA_ATV-ABEV_TO TO LW_ANALITIKA-ABEVAZ.
        APPEND LW_ANALITIKA TO LI_ANALITIKA.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Gyűjtött rekordok beszúrása
  IF NOT LI_ANALITIKA[] IS INITIAL.
    LOOP AT LI_ANALITIKA INTO W_/ZAK/ANALITIKA.
      APPEND W_/ZAK/ANALITIKA TO T_ANALITIKA.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
