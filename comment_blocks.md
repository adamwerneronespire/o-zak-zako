| id | file name | comment block |
| --- | --- | --- |
| 1 | src/#zak#0406_read_file.prog.abap | *ALV közös rutinok |
| 2 | src/#zak#0406_read_file.prog.abap | * analitika adatszerkezet |
| 3 | src/#zak#0406_read_file.prog.abap | * file típusok |
| 4 | src/#zak#0406_read_file.prog.abap | * excel betöltéshez |
| 5 | src/#zak#0406_read_file.prog.abap | * maximális sorok száma |
| 6 | src/#zak#0406_read_file.prog.abap | *Hiba adaszerkezet tábla |
| 7 | src/#zak#0406_read_file.prog.abap | *GUI státuszok tíltásához |
| 8 | src/#zak#0406_read_file.prog.abap | *HIBALISTA ALV változók:<br>* Fejléc adatok |
| 9 | src/#zak#0406_read_file.prog.abap | * Lista layout beállítások |
| 10 | src/#zak#0406_read_file.prog.abap | * Események (pl: TOP-OF-PAGE) |
| 11 | src/#zak#0406_read_file.prog.abap | * Nyomtatás vezérlés |
| 12 | src/#zak#0406_read_file.prog.abap | * Mező katalógus |
| 13 | src/#zak#0406_read_file.prog.abap | * excel betöltéshez |
| 14 | src/#zak#0406_read_file.prog.abap | * struktúra ellenőrzése |
| 15 | src/#zak#0406_read_file.prog.abap | * excel betöltéshez |
| 16 | src/#zak#0406_read_file.prog.abap | *Makró definiálása státusz töltéséhez |
| 17 | src/#zak#0406_read_file.prog.abap | * megnevezések |
| 18 | src/#zak#0406_read_file.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 19 | src/#zak#0406_read_file.prog.abap | * megnevezések |
| 20 | src/#zak#0406_read_file.prog.abap | *  Jogosultság vizsgálat |
| 21 | src/#zak#0406_read_file.prog.abap | * bevallás fajta meghatározása |
| 22 | src/#zak#0406_read_file.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 23 | src/#zak#0406_read_file.prog.abap | * Adatszerkezethez tartozó mező ellenörzések, és<br>* az oszlopok számának meghatározása. |
| 24 | src/#zak#0406_read_file.prog.abap | * Analitika tábla szerkezet |
| 25 | src/#zak#0406_read_file.prog.abap | * Adatszolgáltatás fájl formátuma alapján meghívom a betöltő funkciókat |
| 26 | src/#zak#0406_read_file.prog.abap | *      a hibák a I_HIBA táblában! |
| 27 | src/#zak#0406_read_file.prog.abap | * Tételszám vizsgálat, itt csak a max. konstansban meghatározott<br>* tételszám tölthető be!<br>*++S4HANA#01.<br>*        DESCRIBE TABLE I_LINE LINES V_XLS_LINE. |
| 28 | src/#zak#0406_read_file.prog.abap | *A megadott fájl sorok száma (&), nagyobb a max.megengedettnél (&)! |
| 29 | src/#zak#0406_read_file.prog.abap | * alv lista belső tábla kitöltés I_OUTTAB |
| 30 | src/#zak#0406_read_file.prog.abap | *   Éles futás adatbázis módosítás |
| 31 | src/#zak#0406_read_file.prog.abap | *       Az adatok mentése sikeresen megtörtént! |
| 32 | src/#zak#0406_read_file.prog.abap | *       Hiba az adatbázis módosításkor! |
| 33 | src/#zak#0406_read_file.prog.abap | *++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*++S4HANA#01. |
| 34 | src/#zak#0406_read_file.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 35 | src/#zak#0406_read_file.prog.abap | * Adatszerkezet meghatározás |
| 36 | src/#zak#0406_read_file.prog.abap | * SAP adatszolgáltatást jelenleg nem engedélyezett ! |
| 37 | src/#zak#0406_read_file.prog.abap | *   & adatszolgáltatás speciálisra van beállítva! (/ZAK/BEVALLD) |
| 38 | src/#zak#0406_read_file.prog.abap | * XML formátumnál nem kell struktúra |
| 39 | src/#zak#0406_read_file.prog.abap | *--S4HANA#01.<br>* aktivált? |
| 40 | src/#zak#0406_read_file.prog.abap | * COMPTYPE = 'S' includ sor ezért nem vesszük figyelembe |
| 41 | src/#zak#0406_read_file.prog.abap | * analitika mezők megfeleltetése az adatszerkezetnek!<br>* Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát |
| 42 | src/#zak#0406_read_file.prog.abap | * csak az ABEV azonosítóval kapcsolt mezőket dolgozom fel! |
| 43 | src/#zak#0406_read_file.prog.abap | *       Feltöltés azonosító feltöltése |
| 44 | src/#zak#0406_read_file.prog.abap | *       BTYPE ellenőrzése |
| 45 | src/#zak#0406_read_file.prog.abap | *       IDŐSZAKok kezelése |
| 46 | src/#zak#0406_read_file.prog.abap | * item beállítása |
| 47 | src/#zak#0406_read_file.prog.abap | * analitika mezők megfeleltetése az adatszerkezetnek!<br>* Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát |
| 48 | src/#zak#0406_read_file.prog.abap | *       Értékmezők kezelése 'HUF' miatt |
| 49 | src/#zak#0406_read_file.prog.abap | *ALV lista init |
| 50 | src/#zak#0406_read_file.prog.abap | *ALV lista |
| 51 | src/#zak#0406_read_file.prog.abap | * ALV lista meghívása adatok megjelenítése |
| 52 | src/#zak#0406_read_file.prog.abap | * Lista értékek inicializálása, feltöltése |
| 53 | src/#zak#0406_read_file.prog.abap | * Mező katalógus |
| 54 | src/#zak#0406_read_file.prog.abap | **Színmeghatározása miatt<br>*  GSE_LAYOUT-INFO_FIELDNAME = 'COLOR'. |
| 55 | src/#zak#0406_read_file.prog.abap | * ABAP/4 List Viewer hívása |
| 56 | src/#zak#0406_read_file.prog.abap | *     IT_EXCLUDING             =<br>*     IT_SPECIAL_GROUPS        = GT_SP_GROUP[]<br>*     IT_SORT                  = GT_SORT[]<br>*     IT_FILTER                =<br>*     IS_SEL_HIDE              =<br>*     i_default                = g_default<br>*     I_SAVE                   = 'X' "variánsok mentése<br>*                                           "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 57 | src/#zak#abevk_upd.prog.abap | *GUI státuszok tíltásához |
| 58 | src/#zak#abevk_upd.prog.abap | *Makró definiálása státusz töltéséhez |
| 59 | src/#zak#abevk_upd.prog.abap | * Jogosultság vizsgálat |
| 60 | src/#zak#abevk_upd.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 61 | src/#zak#abevk_upd.prog.abap | * Adatok szelektálása |
| 62 | src/#zak#abevk_upd.prog.abap | * Karbantartó képernyő meghívása |
| 63 | src/#zak#abevk_upd.prog.abap | *BTYPE ellenőrzése |
| 64 | src/#zak#abevk_upd.prog.abap | *   & bevallás típus nem létezik! |
| 65 | src/#zak#abevk_upd.prog.screen_0100.abap | *Kilépés |
| 66 | src/#zak#adoazon_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 67 | src/#zak#adoazon_corr.prog.abap | *  Képernyő attribútomok beállítása |
| 68 | src/#zak#adoazon_corr.prog.abap | * Adatok feldolgozása |
| 69 | src/#zak#adoazon_corr.prog.abap | *     Le kell cserélni a FILED_C értékét is ha abban az adóaz.van! |
| 70 | src/#zak#adoazon_corr.prog.abap | *     Le kell cserélni a FILED_C értékét is ha abban az adóaz.van! |
| 71 | src/#zak#adoazon_corr.prog.abap | *   Adatmódosítások elmentve! |
| 72 | src/#zak#adoazon_corr.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 73 | src/#zak#adon_book.prog.abap | * Fájl adatszerkezete<br>*++ FI 20070118<br>*TYPES: T_FILE TYPE /ZAK/ADONSZA_OUT. |
| 74 | src/#zak#adon_book.prog.abap | * ALV kezelési változók |
| 75 | src/#zak#adon_book.prog.abap | *++BG 2006/07/19<br>*Range létrehozása, a kijelölt bizonylatok BTYPE gyűjtéséhez |
| 76 | src/#zak#adon_book.prog.abap | *MAKRO definiálás range feltöltéshez |
| 77 | src/#zak#adon_book.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 78 | src/#zak#adon_book.prog.abap | *++0004 2008.01.14 BG<br>* Vállalat szegmens összerendelés |
| 79 | src/#zak#adon_book.prog.abap | * Vállalat megnevezése |
| 80 | src/#zak#adon_book.prog.abap | *++0002 BG 2006.09.22<br>*   Bevallás fajta megahtározása |
| 81 | src/#zak#adon_book.prog.abap | *++BG 2006.12.20<br>*  ÁFA esetén nem különböztetjök meg az önrevíziót: |
| 82 | src/#zak#adon_book.prog.abap | * Adónem megnevezése |
| 83 | src/#zak#adon_book.prog.abap | * Mezőkatalógus összeállítása |
| 84 | src/#zak#adon_book.prog.abap | *++BG 2006/06/23<br>*CHEKBOX beállítása ZLOCK mezőn |
| 85 | src/#zak#adon_book.prog.abap | * Manuális rögzítés |
| 86 | src/#zak#adon_book.prog.abap | * Átutalási összesítő készítő |
| 87 | src/#zak#adon_book.prog.abap | * Kilépés |
| 88 | src/#zak#adon_book.prog.abap | * Manuális rögzítés |
| 89 | src/#zak#adon_book.prog.abap | *       Hiba a tétel mentésénél! (/ZAK/ADONSZA hibakód: &)<br>*--BG 2006/06/23 |
| 90 | src/#zak#adon_book.prog.abap | * Kilépés |
| 91 | src/#zak#adon_book.prog.abap | *   Meghatározzuk a bizonylat fajtához a típusokat |
| 92 | src/#zak#adon_book.prog.abap | *++BG 2006/07/19<br>* Összegyűjtjük azokat a BTYPE-okat amik ki lettek<br>* jelölve, mert egyébként csak az adónem és az esedékességi<br>* dátum határozta meg a referenciát ami nem volt jó<br>*--S4HANA#01.<br>*  REFRESH R_BTYPE. |
| 93 | src/#zak#adon_book.prog.abap | *     ÁFA típus esetén kell az önrevízió is: |
| 94 | src/#zak#adon_book.prog.abap | *++0002 BG 2006.09.22<br>* RANGE rendezése |
| 95 | src/#zak#adon_book.prog.abap | * Fájl létrehozása |
| 96 | src/#zak#adon_book.prog.abap | *++0005 2010.04.20 Balázs Gábor (Ness) |
| 97 | src/#zak#adon_book.prog.abap | *--0005 2010.04.20 Balázs Gábor (Ness) |
| 98 | src/#zak#adon_book.prog.abap | *++0005 2010.04.20 Balázs Gábor (Ness)<br>*   Adónem megnevezés |
| 99 | src/#zak#adon_book.prog.abap | *--0005 2010.04.20 Balázs Gábor (Ness) |
| 100 | src/#zak#adon_book.prog.abap | ** Fájl<br>*++ FI 20070118<br>*    W_FILE-SORSZAM    = L_COUNTER.<br>*    W_FILE-ADONEM_TXT = W_FILE_MAIN-ADONEM_TXT.<br>*-- FI 20070118 |
| 101 | src/#zak#adon_book.prog.abap | *-- FI 20070212<br>*++0005 2010.04.20 Balázs Gábor (Ness)<br>*     Vezető 0 feltöltés: |
| 102 | src/#zak#adon_book.prog.abap | *--0005 2010.04.20 Balázs Gábor (Ness) |
| 103 | src/#zak#adon_book.prog.abap | *++0005 2010.04.20 Balázs Gábor (Ness) |
| 104 | src/#zak#adon_book.prog.abap | *--0005 2010.04.20 Balázs Gábor (Ness) |
| 105 | src/#zak#adon_book.prog.abap | * Letöltés sikerült adott BUKRS/ESDAT kombinációra |
| 106 | src/#zak#adon_book.prog.abap | * Új bizonylat létrehozása |
| 107 | src/#zak#adon_book.prog.abap | * Lista aktualizálása |
| 108 | src/#zak#adon_book.prog.abap | * Adatszerkezet beolvasása |
| 109 | src/#zak#adon_book.prog.abap | *++ BG 2006.04.20 Útvonal meghatározás |
| 110 | src/#zak#adon_book.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 111 | src/#zak#adon_book.prog.abap | *--S4HANA#01.<br>* Referencia rögzítése |
| 112 | src/#zak#adon_book.prog.abap | * Kilépés |
| 113 | src/#zak#adon_book.prog.abap | * Változás meghatározás |
| 114 | src/#zak#adon_book.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 115 | src/#zak#adon_book.prog.abap | *   Kérem jelölje ki a feldolgozandó sort! |
| 116 | src/#zak#adon_book.prog.abap | *   Kérem csak egy sort jelöljön ki! |
| 117 | src/#zak#adon_book.prog.abap | * Ez alapján hasonlitjuk össze, hogy volt e feldolgozás |
| 118 | src/#zak#adon_book.prog.abap | * Kilépés |
| 119 | src/#zak#adon_book.prog.abap | * Adatok módosítása+összesítése |
| 120 | src/#zak#adon_book.prog.screen_9000.abap | nincs emberi komment blokk |
| 121 | src/#zak#adon_book.prog.screen_9001.abap | nincs emberi komment blokk |
| 122 | src/#zak#adon_book.prog.screen_9002.abap | nincs emberi komment blokk |
| 123 | src/#zak#adon_list.prog.abap | * ALV kezelési változók |
| 124 | src/#zak#adon_list.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 125 | src/#zak#adon_list.prog.abap | * Vállalat megnevezése |
| 126 | src/#zak#adon_list.prog.abap | * Adónem megnevezése |
| 127 | src/#zak#adon_list.prog.abap | * Bevallás típus megnevezése |
| 128 | src/#zak#adon_list.prog.abap | * Kötelezettég / teljesítés oszlopok |
| 129 | src/#zak#adon_list.prog.abap | * Mezőkatalógus összeállítása |
| 130 | src/#zak#adon_list.prog.abap | *++BG 2006/07/07<br>*CHEKBOX beállítása ZLOCK mezőn |
| 131 | src/#zak#adon_list.prog.abap | * Kilépés |
| 132 | src/#zak#adon_list.prog.abap | *   Kérem jelölje ki a feldolgozandó sort vagy sorokat! |
| 133 | src/#zak#adon_list.prog.abap | *  Végigolvassuk a kijelölt rekorodkat: |
| 134 | src/#zak#adon_list.prog.abap | *     A kijelölésben van pénzügyileg teljesített biz., ami már nem módosítható! |
| 135 | src/#zak#adon_list.prog.abap | *   Az esedékességi dátumnak és a zárolás flagnek minden rekordban meg kell egyezni |
| 136 | src/#zak#adon_list.prog.abap | *        Esedékességi dátum vagy zárolás flag értéke eltérő a kij. tételekben! |
| 137 | src/#zak#adon_list.prog.abap | * Ez alapján hasonlitjuk össze, hogy volt e feldolgozás |
| 138 | src/#zak#adon_list.prog.abap | *++BG 2007.05.08<br>* Beállítjuk a sor indexet. |
| 139 | src/#zak#adon_list.prog.abap | * Kilépés |
| 140 | src/#zak#adon_list.prog.abap | * Változás meghatározás |
| 141 | src/#zak#adon_list.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 142 | src/#zak#adon_list.prog.abap | * /ZAK/ADONSZA módosítása |
| 143 | src/#zak#adon_list.prog.screen_9000.abap | nincs emberi komment blokk |
| 144 | src/#zak#adon_list.prog.screen_9002.abap | nincs emberi komment blokk |
| 145 | src/#zak#adonsza_esdat_conv.prog.abap | *Vállalat |
| 146 | src/#zak#adonsza_esdat_conv.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 147 | src/#zak#afa_abev_corr.prog.abap | *Szelekció:<br>* PAREMEZTER: BUKRS, BTYPE, GJAHR, MONAT,<br>* SELECT_OPTIONS:   ZINDEX,<br>*                   MWSKZ, KTOSL<br>*<br>*  rossz            ABEVAZ<br>*  jó               ABEVAZ |
| 148 | src/#zak#afa_abev_corr.prog.abap | * Leválogatni az /ZAK/ANALITIKA<br>* Képezni egy sort ellenkező előjellel a rossz ABEV-en<br>* Képezni egy sort azonos előjellel a jó ABEV-en<br>* /ZAK/UPDATE-el felvinni. |
| 149 | src/#zak#afa_abev_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 150 | src/#zak#afa_abev_corr.prog.abap | *  Képernyő attribútomok beállítása |
| 151 | src/#zak#afa_abev_corr.prog.abap | * Adatok feldolgozása |
| 152 | src/#zak#afa_abev_corr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 153 | src/#zak#afa_abev_corr.prog.abap | *  Teszt vagy éles futás, adatbázis módosítás, stb. |
| 154 | src/#zak#afa_abev_corr.prog.abap | * Adatok leválogatása |
| 155 | src/#zak#afa_abev_corr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 156 | src/#zak#afa_abev_corr.prog.abap | *  Először mindig tesztben futtatjuk |
| 157 | src/#zak#afa_abev_corr.prog.abap | *   Üzenetek kezelése |
| 158 | src/#zak#afa_abev_corr.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 159 | src/#zak#afa_abev_corr.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 160 | src/#zak#afa_abev_corr.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról, |
| 161 | src/#zak#afa_abev_corr.prog.abap | *    Ha nem háttérben fut |
| 162 | src/#zak#afa_abev_corr.prog.abap | *    Szövegek betöltése |
| 163 | src/#zak#afa_abev_corr.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 164 | src/#zak#afa_abev_corr.prog.abap | *    Mehet az adatbázis módosítása |
| 165 | src/#zak#afa_abev_corr.prog.abap | *      Adatok módosítása |
| 166 | src/#zak#afa_abev_corr.prog.abap | * Mezőkatalógus összeállítása |
| 167 | src/#zak#afa_arany.prog.abap | *Bevallás típus |
| 168 | src/#zak#afa_arany.prog.abap | *IDŐSZAK kezdő és záró dátuma: |
| 169 | src/#zak#afa_arany.prog.abap | *ÁFA kódok<br>*++S4HANA#01.<br>*RANGES R_MWSKZ FOR /ZAK/AFA_CUST-MWSKZ. |
| 170 | src/#zak#afa_arany.prog.abap | * ALV kezelési változók |
| 171 | src/#zak#afa_arany.prog.abap | *LWBAS összegek |
| 172 | src/#zak#afa_arany.prog.abap | * ÁFA kód irány |
| 173 | src/#zak#afa_arany.prog.abap | *MAKRO definiálás range feltöltéshez |
| 174 | src/#zak#afa_arany.prog.abap | *Normál kerekítés |
| 175 | src/#zak#afa_arany.prog.abap | *   Hiba a & összeg kerekítésénél! |
| 176 | src/#zak#afa_arany.prog.abap | *Egész számra kerekítés |
| 177 | src/#zak#afa_arany.prog.abap | * Vállalat. |
| 178 | src/#zak#afa_arany.prog.abap | *Hónap |
| 179 | src/#zak#afa_arany.prog.abap | *Teszt futás |
| 180 | src/#zak#afa_arany.prog.abap | *  Megnevezések meghatározása |
| 181 | src/#zak#afa_arany.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 182 | src/#zak#afa_arany.prog.abap | *  Képernyő attribútomok beállítása |
| 183 | src/#zak#afa_arany.prog.abap | * Megnevezések meghatározása |
| 184 | src/#zak#afa_arany.prog.abap | * Jogosultság vizsgálat |
| 185 | src/#zak#afa_arany.prog.abap | * Vállalat adatok meghatározása |
| 186 | src/#zak#afa_arany.prog.abap | * Meghatározzuk a bevallás típust |
| 187 | src/#zak#afa_arany.prog.abap | * IDŐSZAK utolsó és első napjának meghatározása |
| 188 | src/#zak#afa_arany.prog.abap | * Ellenőrizzük, meghatározzuk a beállítást |
| 189 | src/#zak#afa_arany.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 190 | src/#zak#afa_arany.prog.abap | *  Háttérben nem készítünk listát. |
| 191 | src/#zak#afa_arany.prog.abap | * Vállalat megnevezése |
| 192 | src/#zak#afa_arany.prog.abap | *    Hiba a & vállalat forgatás meghatározásnál! |
| 193 | src/#zak#afa_arany.prog.abap | * Bevallás típus meghatározás |
| 194 | src/#zak#afa_arany.prog.abap | *++BG 2008.04.14<br>* A kezdeti időszak mindig az adott év első napja |
| 195 | src/#zak#afa_arany.prog.abap | *   Hiba a bevallás adatok meghatározásánál!(&/&/&) |
| 196 | src/#zak#afa_arany.prog.abap | * Ha a bevallás nem arányosított |
| 197 | src/#zak#afa_arany.prog.abap | *   A megadott adatokkal nem lehet arányosított bevallás típust meghatár |
| 198 | src/#zak#afa_arany.prog.abap | *   A program & vállalatra csak & hónapra futtatható! |
| 199 | src/#zak#afa_arany.prog.abap | *   A program & vállalatra csak & hónapra futtatható! |
| 200 | src/#zak#afa_arany.prog.abap | * ÁFA kódok feltöltése |
| 201 | src/#zak#afa_arany.prog.abap | *++BG 2008.04.14<br>*  Mert ez a típus fordított adózású beszerzés<br>*  amit ki kell hagyni. |
| 202 | src/#zak#afa_arany.prog.abap | *   Hiba az ÁFA beállítások meghatározásánál! |
| 203 | src/#zak#afa_arany.prog.abap | * Adómentes rész feltöltése |
| 204 | src/#zak#afa_arany.prog.abap | *++0003 BG 2009.03.17<br>* Feldolgozatlan tételek<br>*++S4HANA#01.<br>*  REFRESH $I_ARANY_FELD. |
| 205 | src/#zak#afa_arany.prog.abap | *--0001 BG 2008.04.09<br>*     Pénznem mező meghatározása |
| 206 | src/#zak#afa_arany.prog.abap | *--S4HANA#01.<br>*   A feldolgozásban & pénznem, nem egyezik meg a vállalat & pénznemével |
| 207 | src/#zak#afa_arany.prog.abap | *     Feltöltjük a mentes körből a KTOSL-eket |
| 208 | src/#zak#afa_arany.prog.abap | *         Előjel meghatározása összeghez |
| 209 | src/#zak#afa_arany.prog.abap | *     Ellenőrizn kell, hogy kimenő e |
| 210 | src/#zak#afa_arany.prog.abap | *         Ha KIMENŐ akkor feltöltjük a KTOSL-eket. |
| 211 | src/#zak#afa_arany.prog.abap | *           Előjel meghatározása összeghez |
| 212 | src/#zak#afa_arany.prog.abap | * Mezőkatalógus összeállítása |
| 213 | src/#zak#afa_arany.prog.abap | * Kilépés |
| 214 | src/#zak#afa_arany.prog.abap | * Arány kiszámítása |
| 215 | src/#zak#afa_arany.prog.abap | *--0004 2009.04.20 BG<br>*   Normál kerekítés |
| 216 | src/#zak#afa_arany.prog.abap | *   Következő egész számra kerekítés |
| 217 | src/#zak#afa_arany.prog.abap | *   Adatbázis módosítás |
| 218 | src/#zak#afa_arany.prog.abap | *++0003 BG 2009.03.17<br>*   Ha van rekord létrehozás: |
| 219 | src/#zak#afa_arany.prog.abap | *   Súlyos hiba az ÁFA arány számításnál! |
| 220 | src/#zak#afa_arany.prog.abap | *   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 221 | src/#zak#afa_arany.prog.abap | * Mezőkatalógus összeállítása |
| 222 | src/#zak#afa_arany.prog.abap | *   Kilépés |
| 223 | src/#zak#afa_arany.prog.screen_9000.abap | nincs emberi komment blokk |
| 224 | src/#zak#afa_arany.prog.screen_9100.abap | nincs emberi komment blokk |
| 225 | src/#zak#afa_conv_0865.prog.abap | *Vállalat |
| 226 | src/#zak#afa_conv_0865.prog.abap | *Bevallás típus |
| 227 | src/#zak#afa_conv_0865.prog.abap | *Hónap |
| 228 | src/#zak#afa_conv_0865.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 229 | src/#zak#afa_conv_0865.prog.abap | * Meghatározzuk a BTYPE-okat: |
| 230 | src/#zak#afa_conv_0865.prog.abap | * /ZAK/BEVALL és /ZAK/BEVALLT konverzió: |
| 231 | src/#zak#afa_conv_0865.prog.abap | * /ZAK/ZAK_BEVASZ és /ZAK/BEVALLI konverzió: |
| 232 | src/#zak#afa_conv_0865.prog.abap | * /ZAK/ANALITIKA konverzió |
| 233 | src/#zak#afa_conv_0865.prog.abap | * /ZAK/BEVALLO konverzió |
| 234 | src/#zak#afa_conv_0865.prog.abap | * Adatbázis módosítások: |
| 235 | src/#zak#afa_conv_0865.prog.abap | * Új rekordok képzése: |
| 236 | src/#zak#afa_conv_0865.prog.abap | * Új rekordok képzése: |
| 237 | src/#zak#afa_conv_0865.prog.abap | *Adatok leválogatása<br>*++S4HANA#01.<br>*  REFRESH: I_/ZAK/ANALITIKA, LI_BEVALLO_ALV. |
| 238 | src/#zak#afa_conv_0865.prog.abap | *   Adatok konverzió |
| 239 | src/#zak#afa_conv_0865.prog.abap | *Adatok leválogatása<br>*++S4HANA#01.<br>*  REFRESH: I_/ZAK/BEVALLO, LI_BEVALLO_ALV. |
| 240 | src/#zak#afa_conv_0865.prog.abap | *   Adatok konverzió |
| 241 | src/#zak#afa_del_data.prog.abap | *Vállalat |
| 242 | src/#zak#afa_del_data.prog.abap | *Bevallás típus |
| 243 | src/#zak#afa_del_data.prog.abap | *Hónap |
| 244 | src/#zak#afa_del_data.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 245 | src/#zak#afa_del_data.prog.abap | * Meghatározzuk a BTYPE-okat: |
| 246 | src/#zak#afa_del_data.prog.abap | * /ZAK/ZAK_BEVASZ és /ZAK/BEVALLI törlés: |
| 247 | src/#zak#afa_del_data.prog.abap | * /ZAK/ANALITIKA törlés |
| 248 | src/#zak#afa_del_data.prog.abap | * /ZAK/BEVALLO törlés |
| 249 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 250 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 251 | src/#zak#afa_egyezteto.prog.abap | * ALV kezelési változók |
| 252 | src/#zak#afa_egyezteto.prog.abap | * vállalat |
| 253 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 254 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 255 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 256 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 257 | src/#zak#afa_egyezteto.prog.abap | * Tételek megjelenítése! |
| 258 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc)<br>* Részletek megjelenítése |
| 259 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 260 | src/#zak#afa_egyezteto.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 261 | src/#zak#afa_egyezteto.prog.abap | *  Jogosultság vizsgálat |
| 262 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 263 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc)<br>*  szelekció |
| 264 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>*++0001 2008.11.05 Balázs Gábor (Fmc) |
| 265 | src/#zak#afa_egyezteto.prog.abap | *      Nem áll rendelkezésre mentett adat & vállalat & év & hónapra! |
| 266 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 267 | src/#zak#afa_egyezteto.prog.abap | *  Ha háttér futás és nem mentett feldolgozás<br>*  adatok mentése. |
| 268 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 269 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 270 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 271 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 272 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 273 | src/#zak#afa_egyezteto.prog.abap | * ALV lista |
| 274 | src/#zak#afa_egyezteto.prog.abap | * az adatszerkezet SAP-os struktúrája a /ZAK/BEVALLD-strname táblából<br>* kell venni |
| 275 | src/#zak#afa_egyezteto.prog.abap | * Kilépés |
| 276 | src/#zak#afa_egyezteto.prog.abap | * analitika struktúra megjelenítés |
| 277 | src/#zak#afa_egyezteto.prog.abap | * Mezőkatalógus összeállítása |
| 278 | src/#zak#afa_egyezteto.prog.abap | * /ZAK/ANALITIKA tábla |
| 279 | src/#zak#afa_egyezteto.prog.abap | * tétel tábla |
| 280 | src/#zak#afa_egyezteto.prog.abap | * Mezőkatalógus összeállítása |
| 281 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc)<br>*++S4HANA#01.<br>*     REFRESH R_HKONT. |
| 282 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>*--0001 2008.11.05 Balázs Gábor (Fmc) |
| 283 | src/#zak#afa_egyezteto.prog.abap | * a kijelölt sorhoz tartozó bizonylatok megjelenítése |
| 284 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 285 | src/#zak#afa_egyezteto.prog.abap | *           Nincs jogosultsága & tranzakcióhoz |
| 286 | src/#zak#afa_egyezteto.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 287 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>*--0001 2008.11.05 Balázs Gábor (Fmc) |
| 288 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 289 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc)<br>*++S4HANA#01.<br>*            INTO TABLE I_BSEG_V FROM BSEG |
| 290 | src/#zak#afa_egyezteto.prog.abap | * Forgalmi adatok főkönyvi törzse |
| 291 | src/#zak#afa_egyezteto.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc)<br>*++S4HANA#01.<br>*   SORT I_BSEG_V BY BUKRS BELNR GJAHR. |
| 292 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>* Szállító, vevő kódok meghatározása |
| 293 | src/#zak#afa_egyezteto.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 294 | src/#zak#afa_egyezteto.prog.abap | * előjel |
| 295 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>* normál |
| 296 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>* önrevízió |
| 297 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>* bevallásban nem szereplő |
| 298 | src/#zak#afa_egyezteto.prog.abap | * bevallásban nem szereplő |
| 299 | src/#zak#afa_egyezteto.prog.abap | * havi főkönyvi egyenleg a GLT0 táblából |
| 300 | src/#zak#afa_egyezteto.prog.abap | *    Kérem jelölje ki a feldolgozandó sort! |
| 301 | src/#zak#afa_egyezteto.prog.abap | *--S4HANA#01.<br>*  Kijelölt sorok feldolgozása |
| 302 | src/#zak#afa_egyezteto.prog.abap | *      előjel |
| 303 | src/#zak#afa_egyezteto.prog.abap | *      ÁFA kód |
| 304 | src/#zak#afa_egyezteto.prog.abap | *      Szállító kód |
| 305 | src/#zak#afa_egyezteto.prog.abap | *      Vevő kód |
| 306 | src/#zak#afa_egyezteto.prog.abap | *  Ha van időszak |
| 307 | src/#zak#afa_egyezteto.prog.abap | *  BTYPE meghatározása |
| 308 | src/#zak#afa_egyezteto.prog.abap | *    ÁFA CUST olvasása KTOSL alapján |
| 309 | src/#zak#afa_egyezteto.prog.abap | *    ÁFA CUST olvasása KTOSL nélkül |
| 310 | src/#zak#afa_egyezteto.prog.abap | * Mezőkatalógus összeállítása |
| 311 | src/#zak#afa_egyezteto.prog.abap | * Fejléc adatok |
| 312 | src/#zak#afa_egyezteto.prog.abap | * Fejléc megadása |
| 313 | src/#zak#afa_egyezteto.prog.screen_9000.abap | nincs emberi komment blokk |
| 314 | src/#zak#alv_bevallb_mod.prog.abap | * Jogosultság vizsgálat |
| 315 | src/#zak#alv_bevallb_mod.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 316 | src/#zak#alv_grid_alap.prog.abap | * hotspot megadása |
| 317 | src/#zak#alv_grid_alap.prog.abap | * mező módosítása |
| 318 | src/#zak#alv_list_definitions.prog.abap | * Közös top-of-page form neve |
| 319 | src/#zak#alv_list_definitions.prog.abap | * Lista végén hívható form neve:'END_OF_LIST' (Fõprogramba kell megírni) |
| 320 | src/#zak#alv_list_definitions.prog.abap | * Fejléc adatok |
| 321 | src/#zak#alv_list_definitions.prog.abap | * Mezõ katalógus |
| 322 | src/#zak#alv_list_definitions.prog.abap | * Lista layout beállítások |
| 323 | src/#zak#alv_list_definitions.prog.abap | * Rendezés |
| 324 | src/#zak#alv_list_definitions.prog.abap | * Események (pl: TOP-OF-PAGE) |
| 325 | src/#zak#alv_list_definitions.prog.abap | * Nyomtatás vezérlés |
| 326 | src/#zak#alv_list_definitions.prog.abap | * Mezõ csoportosítások (ez inkább 'csicsa') |
| 327 | src/#zak#alv_list_definitions.prog.abap | * Kulcsmezõk hierarchikus lista esetén |
| 328 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 329 | src/#zak#alv_list_forms.prog.abap | * ABAP/4 List Viewer hívása |
| 330 | src/#zak#alv_list_forms.prog.abap |       "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 331 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 332 | src/#zak#alv_list_forms.prog.abap | * ABAP/4 List Viewer hívása |
| 333 | src/#zak#alv_list_forms.prog.abap |       "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 334 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 335 | src/#zak#alv_list_forms.prog.abap | * Lista fejléc |
| 336 | src/#zak#alv_list_forms.prog.abap | * Események definiálása (top-of-page) |
| 337 | src/#zak#alv_list_forms.prog.abap | * Nyomtatás beállítások |
| 338 | src/#zak#alv_list_forms.prog.abap | * Mező katalógus |
| 339 | src/#zak#alv_list_forms.prog.abap | * Cím |
| 340 | src/#zak#alv_list_forms.prog.abap | *  $gs_layout-totals_only         = 'X'."Csak az összegek<br>*  $GS_LAYOUT-TOTALS_BEFORE_ITEMS = 'X'."Összegek a tételek előtt<br>*  $gs_layout-totals_text         = 'Mindösszesen'(l01).<br>*  $GS_LAYOUT-SUBTOTALS_TEXT      = 'Részösszeg'(L02).<br>*   $gs_layout-NO_MIN_LINESIZE = 'X'. " line size = width of the list |
| 341 | src/#zak#alv_list_forms.prog.abap | *  $gs_LAYOUT-GROUP_CHANGE_EDIT = 'X'. " Részösszeg megjel. módosítható<br>*  $gs_LAYOUT-MIN_LINESIZE = 132. |
| 342 | src/#zak#alv_list_forms.prog.abap | *  $GS_LAYOUT-F2CODE            =<br>*  $GS_LAYOUT-CELL_MERGE        =<br>*  $GS_LAYOUT-BOX_FIELDNAME     = SPACE.<br>*  $GS_LAYOUT-NO_INPUT          =<br>*  $GS_LAYOUT-NO_VLINE          =<br>*  $GS_LAYOUT-NO_COLHEAD        =<br>*  $GS_LAYOUT-LIGHTS_FIELDNAME  =<br>*  $GS_LAYOUT-LIGHTS_CONDENSE   =<br>*  $GS_LAYOUT-KEY_HOTSPOT       =<br>*  $GS_LAYOUT-DETAIL_POPUP      =<br>*  $gs_layout-group_change_edit = 'X'.  "Felhasználó változtathatja,<br>*                                       "rendezéskor a subtotal új oldal<br>*                                       "ra kerüljön, vagy aláhúzással<br>*                                       "különüljön el<br>*  $GS_LAYOUT-GROUP_BUTTONS      =  space. |
| 343 | src/#zak#alv_list_forms.prog.abap | * 1. mező |
| 344 | src/#zak#alv_list_forms.prog.abap | * 2. mező |
| 345 | src/#zak#alv_list_forms.prog.abap | * 3. mező |
| 346 | src/#zak#alv_list_forms.prog.abap | * 4. mező |
| 347 | src/#zak#alv_list_forms.prog.abap | * 5. mező |
| 348 | src/#zak#alv_list_forms.prog.abap | * 6. mező |
| 349 | src/#zak#alv_list_forms.prog.abap | * 7. mező |
| 350 | src/#zak#analitika_arany_corr.prog.abap | *<br>* Adatok feldolgozása |
| 351 | src/#zak#analitika_arany_corr.prog.abap | *   Adatmódosítások elmentve! |
| 352 | src/#zak#analitika_arany_corr.prog.abap | * Csak az arányosított sorok kellenek: |
| 353 | src/#zak#analitika_corr.prog.abap | *--S4HANA#01.<br>*MAKRO definiálás range feltöltéshez |
| 354 | src/#zak#analitika_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 355 | src/#zak#analitika_corr.prog.abap | *  Képernyő attribútomok beállítása |
| 356 | src/#zak#analitika_corr.prog.abap | * Adatok feldolgozása |
| 357 | src/#zak#analitika_del_onybf.prog.abap | *MAKRO definiálás range feltöltéshez |
| 358 | src/#zak#analitika_del_onybf.prog.abap | * Jogosultság vizsgálat |
| 359 | src/#zak#analitika_del_onybf.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 360 | src/#zak#analitika_del_onybf.prog.abap | *   Kérem adjon meg további éretéket a szelekción! |
| 361 | src/#zak#analitika_del_onybf.prog.abap | *    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 362 | src/#zak#analitika_del_onybf.prog.abap | * Feltöltjük a bevallás típusokat:<br>*  m_def r_btype 'I' 'EQ' '0665' space.<br>*  m_def r_btype 'I' 'EQ' '0765' space.<br>*  M_DEF R_BTYPE 'I' 'EQ' '0865' SPACE.<br>*  M_DEF R_BTYPE 'I' 'EQ' '0965' SPACE.<br>*  M_DEF R_BTYPE 'I' 'EQ' '1065' SPACE. |
| 363 | src/#zak#analitika_del_onybf.prog.abap | * Meghatározzuk a feltöltés azonosítókat:<br>*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'. |
| 364 | src/#zak#analitika_del_onybf.prog.abap | * Adatok leválogatása |
| 365 | src/#zak#analitika_del_onybf.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 366 | src/#zak#analitika_del_onybf.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 367 | src/#zak#analitika_move.prog.abap | *ALV közös rutinok |
| 368 | src/#zak#analitika_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 369 | src/#zak#analitika_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 370 | src/#zak#analitika_move.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 371 | src/#zak#analitika_move.prog.abap | *Adatok feldolgozása |
| 372 | src/#zak#analitika_move.prog.abap | *Adatbázis műveletek |
| 373 | src/#zak#analitika_move.prog.abap | *ALV lista init |
| 374 | src/#zak#analitika_move.prog.abap | *ALV lista |
| 375 | src/#zak#analitika_move.prog.abap | *   Tábla módosítások elvégezve! |
| 376 | src/#zak#analitika_set_onybf.prog.abap | *MAKRO definiálás range feltöltéshez |
| 377 | src/#zak#analitika_set_onybf.prog.abap | * Jogosultság vizsgálat |
| 378 | src/#zak#analitika_set_onybf.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 379 | src/#zak#analitika_set_onybf.prog.abap | *   Kérem adjon meg további éretéket a szelekción! |
| 380 | src/#zak#analitika_set_onybf.prog.abap | *    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 381 | src/#zak#analitika_set_onybf.prog.abap | * Feltöltjük a bevallás típusokat:<br>*  m_def r_btype 'I' 'EQ' '0665' space.<br>*  m_def r_btype 'I' 'EQ' '0765' space.<br>*  m_def r_btype 'I' 'EQ' '0865' space.<br>*  m_def r_btype 'I' 'EQ' '0965' space.<br>*  m_def r_btype 'I' 'EQ' '1065' space. |
| 382 | src/#zak#analitika_set_onybf.prog.abap | * Meghatározzuk a feltöltés azonosítókat:<br>*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'. |
| 383 | src/#zak#analitika_set_onybf.prog.abap | * Adatok leválogatása |
| 384 | src/#zak#analitika_set_onybf.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 385 | src/#zak#analitika_set_onybf.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 386 | src/#zak#analitika_szla_corr.prog.abap | nincs emberi komment blokk |
| 387 | src/#zak#atvez_sap_sel.prog.abap | * Vállalat |
| 388 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás fajta |
| 389 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás típus |
| 390 | src/#zak#atvez_sap_sel.prog.abap | * Hónap |
| 391 | src/#zak#atvez_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 392 | src/#zak#atvez_sap_sel.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 393 | src/#zak#atvez_sap_sel.prog.abap | *  Képernyő attribútomok beállítása |
| 394 | src/#zak#atvez_sap_sel.prog.abap | *  Bevallás típus ellenőrzése |
| 395 | src/#zak#atvez_sap_sel.prog.abap | *  Periódus ellenőrzése |
| 396 | src/#zak#atvez_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 397 | src/#zak#atvez_sap_sel.prog.abap | *  Jogosultság vizsgálat |
| 398 | src/#zak#atvez_sap_sel.prog.abap | * Zárolás beállítás |
| 399 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás utolsó napjának meghatározása |
| 400 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás általános adatai |
| 401 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás státusza |
| 402 | src/#zak#atvez_sap_sel.prog.abap | * Vállalat megnevezése |
| 403 | src/#zak#atvez_sap_sel.prog.abap | * Bevallásfajta megnevezése |
| 404 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás típus meghatározása |
| 405 | src/#zak#atvez_sap_sel.prog.abap | * Bevallásfajta megnevezése |
| 406 | src/#zak#atvez_sap_sel.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 407 | src/#zak#atvez_sap_sel.prog.abap | * Szövegek feltöltése |
| 408 | src/#zak#atvez_sap_sel.prog.abap | * Van valami az adott periódusra? |
| 409 | src/#zak#atvez_sap_sel.prog.abap | * Melyik az utolsó lezárt? |
| 410 | src/#zak#atvez_sap_sel.prog.abap | * Kilépés |
| 411 | src/#zak#atvez_sap_sel.prog.abap | * Mentés - analitika tábla feltöltése |
| 412 | src/#zak#atvez_sap_sel.prog.abap | * Kijelölt rekordok törlése |
| 413 | src/#zak#atvez_sap_sel.prog.abap | * Sor beszúrása kurzorpozíció fölé |
| 414 | src/#zak#atvez_sap_sel.prog.abap | * Sor appendálása - új sor |
| 415 | src/#zak#atvez_sap_sel.prog.abap | * Sor szerkezet szerint fel kell tölteni a belső táblát |
| 416 | src/#zak#atvez_sap_sel.prog.abap | * Nyomtatvány adatok beolvasása abevhez |
| 417 | src/#zak#atvez_sap_sel.prog.abap | * Ha nincs tétel - kezdeti inicializálás |
| 418 | src/#zak#atvez_sap_sel.prog.abap | * Ha van cél, kell forrás is |
| 419 | src/#zak#atvez_sap_sel.prog.abap | * Összeg ellenőrzés: cél nagyobb, mint a forrás |
| 420 | src/#zak#atvez_sap_sel.prog.abap | * Van-e a folyószámlán ennyi? |
| 421 | src/#zak#atvez_sap_sel.prog.abap | * Teljes periódus törlése |
| 422 | src/#zak#atvez_sap_sel.prog.abap | * ADATok mentése |
| 423 | src/#zak#atvez_sap_sel.prog.abap | * ABEV azonosító meghatározása 1. mezőre |
| 424 | src/#zak#atvez_sap_sel.prog.abap | * Tételsorszám |
| 425 | src/#zak#atvez_sap_sel.prog.abap | * Dinamikus lapszám: 24 soronként lép |
| 426 | src/#zak#atvez_sap_sel.prog.abap | * Új tétel |
| 427 | src/#zak#atvez_sap_sel.prog.abap | * Közös update |
| 428 | src/#zak#atvez_sap_sel.prog.abap | * Státusz<br>* Amennyiben  bevallás már letöltött volt > státusz visszaállítása |
| 429 | src/#zak#atvez_sap_sel.prog.abap | * Utolsó Tételszám |
| 430 | src/#zak#atvez_sap_sel.prog.abap | * N - Negyedéves |
| 431 | src/#zak#atvez_sap_sel.prog.abap | * Pénznem |
| 432 | src/#zak#atvez_sap_sel.prog.abap | * Adónem megnevezése - forrás |
| 433 | src/#zak#atvez_sap_sel.prog.abap | * Adónem megnevezése - cél |
| 434 | src/#zak#atvez_sap_sel.prog.abap | * Kiutalandó összeg |
| 435 | src/#zak#atvez_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 436 | src/#zak#book_file_gen.prog.abap | * Vállalat. |
| 437 | src/#zak#book_file_gen.prog.abap | * Bevallás fajta meghatározása |
| 438 | src/#zak#book_file_gen.prog.abap | * Bevallás típus |
| 439 | src/#zak#book_file_gen.prog.abap | * Hónap |
| 440 | src/#zak#book_file_gen.prog.abap | *  Megnevezések meghatározása |
| 441 | src/#zak#book_file_gen.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 442 | src/#zak#book_file_gen.prog.abap | *  Képernyő attribútomok beállítása |
| 443 | src/#zak#book_file_gen.prog.abap | *  Megnevezések meghatározása |
| 444 | src/#zak#book_file_gen.prog.abap | *  Bevallás típus meghatározása |
| 445 | src/#zak#book_file_gen.prog.abap | *  Ellenőrizzük a megadott időszak lezárt-e. |
| 446 | src/#zak#book_file_gen.prog.abap | *  Jogosultság vizsgálat |
| 447 | src/#zak#book_file_gen.prog.abap | *  Átvezetés vagy egyéb |
| 448 | src/#zak#book_file_gen.prog.abap | *   & fájl sikeresen letöltve |
| 449 | src/#zak#book_file_gen.prog.abap | *      Önellenőrzési pótlék könyvelés beállítás hiba! Fájl nem készült! |
| 450 | src/#zak#book_file_gen.prog.abap | *      Önellenőrzési pótlék könyvelési fájl létrehozás hiba! |
| 451 | src/#zak#book_file_gen.prog.abap | *      Nincs meghatározható adat! Fájl nem készült!<br>*++BG 2008.04.16 |
| 452 | src/#zak#book_file_gen.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPU<br>*--BG 2008.04.16 |
| 453 | src/#zak#book_file_gen.prog.abap | *   & fájl sikeresen letöltve |
| 454 | src/#zak#book_file_gen.prog.abap | *++BG 2008.01.07 ÁFA arányosítás könyvelés feladás |
| 455 | src/#zak#book_file_gen.prog.abap | *        & fájl sikeresen letöltve |
| 456 | src/#zak#book_file_gen.prog.abap | *--BG 2008.01.07 ÁFA arányosítás könyvelés |
| 457 | src/#zak#book_file_gen.prog.abap | * Vállalat megnevezése |
| 458 | src/#zak#book_file_gen.prog.abap | *  Meghatározzuk a státuszt |
| 459 | src/#zak#book_file_gen.prog.abap | *  Ha a státusz nem lezárt: |
| 460 | src/#zak#book_file_gen.prog.abap | *   Kérem csak lezárt időszakot adjon meg! |
| 461 | src/#zak#bset_corr.prog.abap | * Jogosultság vizsgálat |
| 462 | src/#zak#bset_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 463 | src/#zak#bset_corr.prog.abap | * Adatok feldolgozása |
| 464 | src/#zak#bset_corr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 465 | src/#zak#bset_corr.prog.abap | *  Először mindig tesztben futtatjuk |
| 466 | src/#zak#bset_corr.prog.abap | *   Üzenetek kezelése |
| 467 | src/#zak#bset_corr.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 468 | src/#zak#bset_corr.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 469 | src/#zak#bset_corr.prog.abap | *    Ha nem háttérben fut |
| 470 | src/#zak#bset_corr.prog.abap | *    Szövegek betöltése |
| 471 | src/#zak#bset_corr.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 472 | src/#zak#bset_corr.prog.abap | *    Mehet az adatbázis módosítása |
| 473 | src/#zak#bset_corr.prog.abap | *      Adatok módosítása |
| 474 | src/#zak#bset_corr.prog.abap | * Adatmódosítások elmentve! |
| 475 | src/#zak#bset_stmdt_update.prog.abap | * Vállalat. |
| 476 | src/#zak#bset_stmdt_update.prog.abap | * Tétel |
| 477 | src/#zak#bset_stmdt_update.prog.abap | *Dátum |
| 478 | src/#zak#bset_stmdt_update.prog.abap | *Idő |
| 479 | src/#zak#bset_stmdt_update.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 480 | src/#zak#bset_stmdt_update.prog.abap | * Adat rekordszám meghatározása |
| 481 | src/#zak#bset_update.prog.abap | * Bevallás fajta |
| 482 | src/#zak#bset_update.prog.abap | *   Ellenőrzés |
| 483 | src/#zak#bset_update.prog.abap | *   Meghatározzuk a periódust |
| 484 | src/#zak#bset_update.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 485 | src/#zak#bset_update.prog.abap | * Adatszelekció: |
| 486 | src/#zak#bset_update.prog.abap | * Adatok feldolgozása |
| 487 | src/#zak#bset_update.prog.abap | *--2007.01.11 BG (FMC)<br>*     Tranzakció típus |
| 488 | src/#zak#bset_update.prog.abap | * LOG tábla aktualizálás |
| 489 | src/#zak#bte.fugr.#zak#lbtetop.abap | nincs emberi komment blokk |
| 490 | src/#zak#bte.fugr.#zak#saplbte.abap | nincs emberi komment blokk |
| 491 | src/#zak#bte.fugr.#zak#tax_exchange_rate_2051.abap | nincs emberi komment blokk |
| 492 | src/#zak#bukrs_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 493 | src/#zak#bukrs_corr.prog.abap | * Adatok feldolgozása |
| 494 | src/#zak#bukrs_corr.prog.abap | * Adatmódosítások elmentve! |
| 495 | src/#zak#alv_bevallb_mod.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Bevallás beállítások módosításai<br>*&---------------------------------------------------------------------* |
| 496 | src/#zak#alv_bevallb_mod.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Bevallás beállítási adataiban történt módosítások<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - fmc<br>*& Létrehozás dátuma : 2006.06.27<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&<br>*&---------------------------------------------------------------------* |
| 497 | src/#zak#alv_bevallb_mod.prog.abap | * Jogosultság vizsgálat |
| 498 | src/#zak#alv_bevallb_mod.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 499 | src/#zak#alv_grid_alap.prog.abap | *&---------------------------------------------------------------------*<br>*&  Include           /ZAK/ALV_GRID_ALAP<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& Adatdeklarációk<br>*&---------------------------------------------------------------------* |
| 500 | src/#zak#alv_grid_alap.prog.abap | *&---------------------------------------------------------------------*<br>*& ALV Makrók<br>*&---------------------------------------------------------------------*<br>* mező elrejtése |
| 501 | src/#zak#alv_grid_alap.prog.abap | * hotspot megadása |
| 502 | src/#zak#alv_grid_alap.prog.abap | * mező módosítása |
| 503 | src/#zak#alv_grid_alap.prog.abap | *&---------------------------------------------------------------------*<br>*& Eseménykezelő osztály<br>*&---------------------------------------------------------------------* |
| 504 | src/#zak#alv_list_definitions.prog.abap | *----------------------------------------------------------------------*<br>*   INCLUDE /ZAK/ALV_LIST_DEFINITIONS                                   *<br>*----------------------------------------------------------------------*<br>* ABAP List Viewer globális definíciói<br>*----------------------------------------------------------------------* |
| 505 | src/#zak#alv_list_definitions.prog.abap | * Közös top-of-page form neve |
| 506 | src/#zak#alv_list_definitions.prog.abap | * Lista végén hívható form neve:'END_OF_LIST' (Fõprogramba kell megírni) |
| 507 | src/#zak#alv_list_definitions.prog.abap | * Fejléc adatok |
| 508 | src/#zak#alv_list_definitions.prog.abap | * Mezõ katalógus |
| 509 | src/#zak#alv_list_definitions.prog.abap | * Lista layout beállítások |
| 510 | src/#zak#alv_list_definitions.prog.abap | * Rendezés |
| 511 | src/#zak#alv_list_definitions.prog.abap | * Események (pl: TOP-OF-PAGE) |
| 512 | src/#zak#alv_list_definitions.prog.abap | * Nyomtatás vezérlés |
| 513 | src/#zak#alv_list_definitions.prog.abap | * Mezõ csoportosítások (ez inkább 'csicsa') |
| 514 | src/#zak#alv_list_definitions.prog.abap | * Kulcsmezõk hierarchikus lista esetén |
| 515 | src/#zak#alv_list_forms.prog.abap | *----------------------------------------------------------------------*<br>*   INCLUDE ZALV_LIST_FORMS                                         *<br>*----------------------------------------------------------------------*<br>* Az itt lévő form-okat csak akkor használd, ha számodra minden<br>* tekintetben megfelelnek !<br>* !!!   A FORM-ok MÓDOSÍTÁSA TILOS !!!!<br>*----------------------------------------------------------------------* |
| 516 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 517 | src/#zak#alv_list_forms.prog.abap | * ABAP/4 List Viewer hívása |
| 518 | src/#zak#alv_list_forms.prog.abap |       "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 519 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 520 | src/#zak#alv_list_forms.prog.abap | * ABAP/4 List Viewer hívása |
| 521 | src/#zak#alv_list_forms.prog.abap |       "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 522 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 523 | src/#zak#alv_list_forms.prog.abap | * Lista fejléc |
| 524 | src/#zak#alv_list_forms.prog.abap | * Események definiálása (top-of-page) |
| 525 | src/#zak#alv_list_forms.prog.abap | * Nyomtatás beállítások |
| 526 | src/#zak#alv_list_forms.prog.abap | * Mező katalógus |
| 527 | src/#zak#alv_list_forms.prog.abap | * Cím |
| 528 | src/#zak#alv_list_forms.prog.abap | *  $gs_layout-totals_only         = 'X'."Csak az összegek<br>*  $GS_LAYOUT-TOTALS_BEFORE_ITEMS = 'X'."Összegek a tételek előtt<br>*  $gs_layout-totals_text         = 'Mindösszesen'(l01).<br>*  $GS_LAYOUT-SUBTOTALS_TEXT      = 'Részösszeg'(L02).<br>*   $gs_layout-NO_MIN_LINESIZE = 'X'. " line size = width of the list |
| 529 | src/#zak#alv_list_forms.prog.abap | *  $gs_LAYOUT-GROUP_CHANGE_EDIT = 'X'. " Részösszeg megjel. módosítható<br>*  $gs_LAYOUT-MIN_LINESIZE = 132. |
| 530 | src/#zak#alv_list_forms.prog.abap | *  $GS_LAYOUT-F2CODE            =<br>*  $GS_LAYOUT-CELL_MERGE        =<br>*  $GS_LAYOUT-BOX_FIELDNAME     = SPACE.<br>*  $GS_LAYOUT-NO_INPUT          =<br>*  $GS_LAYOUT-NO_VLINE          =<br>*  $GS_LAYOUT-NO_COLHEAD        =<br>*  $GS_LAYOUT-LIGHTS_FIELDNAME  =<br>*  $GS_LAYOUT-LIGHTS_CONDENSE   =<br>*  $GS_LAYOUT-KEY_HOTSPOT       =<br>*  $GS_LAYOUT-DETAIL_POPUP      =<br>*  $gs_layout-group_change_edit = 'X'.  "Felhasználó változtathatja,<br>*                                       "rendezéskor a subtotal új oldal<br>*                                       "ra kerüljön, vagy aláhúzással<br>*                                       "különüljön el<br>*  $GS_LAYOUT-GROUP_BUTTONS      =  space. |
| 531 | src/#zak#alv_list_forms.prog.abap | * 1. mező |
| 532 | src/#zak#alv_list_forms.prog.abap | * 2. mező |
| 533 | src/#zak#alv_list_forms.prog.abap | * 3. mező |
| 534 | src/#zak#alv_list_forms.prog.abap | * 4. mező |
| 535 | src/#zak#alv_list_forms.prog.abap | * 5. mező |
| 536 | src/#zak#alv_list_forms.prog.abap | * 6. mező |
| 537 | src/#zak#alv_list_forms.prog.abap | * 7. mező |
| 538 | src/#zak#alv_list_forms.prog.abap | *==================================================================*<br>*           MINTÁK a további ALV-hez kapcsolódó form hívásokra<br>*==================================================================* |
| 539 | src/#zak#analitika_arany_corr.prog.abap | **&---------------------------------------------------------------------*<br>**& Report  /ZAK/ANALITIKA_ARANY_CORR<br>**&<br>**&---------------------------------------------------------------------*<br>**& A program az arányosított sorok FIELD_A mezőt tölti fel<br>**&---------------------------------------------------------------------* |
| 540 | src/#zak#analitika_arany_corr.prog.abap | *<br>* Adatok feldolgozása |
| 541 | src/#zak#analitika_arany_corr.prog.abap | *   Adatmódosítások elmentve! |
| 542 | src/#zak#analitika_arany_corr.prog.abap | * Csak az arányosított sorok kellenek: |
| 543 | src/#zak#analitika_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ZAK_ANALATIKA_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a 1008 bevallás 2011 adatait forgatja át DUMMY-ra<br>*&---------------------------------------------------------------------* |
| 544 | src/#zak#analitika_corr.prog.abap | *--S4HANA#01.<br>*MAKRO definiálás range feltöltéshez |
| 545 | src/#zak#analitika_corr.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 546 | src/#zak#analitika_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 547 | src/#zak#analitika_corr.prog.abap | *  Képernyő attribútomok beállítása |
| 548 | src/#zak#analitika_corr.prog.abap | * Adatok feldolgozása |
| 549 | src/#zak#analitika_del_onybf.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ANALITIKA_SET_ONYBF<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/ANALITIKA tábla ONYBF mezőjét tölti fel:<br>*& Feltételek:<br>*&    - /ZAK/BEVALLB-ONYBF = 'X' (ABEV azonosítók)<br>*&    - feltöltés azonosító <= 2008.01.21<br>*&    - /ZAK/ANALITIKA-GJAHR < 2008<br>*&---------------------------------------------------------------------* |
| 550 | src/#zak#analitika_del_onybf.prog.abap | *MAKRO definiálás range feltöltéshez |
| 551 | src/#zak#analitika_del_onybf.prog.abap | * Jogosultság vizsgálat |
| 552 | src/#zak#analitika_del_onybf.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 553 | src/#zak#analitika_del_onybf.prog.abap | *   Kérem adjon meg további éretéket a szelekción! |
| 554 | src/#zak#analitika_del_onybf.prog.abap | *    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 555 | src/#zak#analitika_del_onybf.prog.abap | * Feltöltjük a bevallás típusokat:<br>*  m_def r_btype 'I' 'EQ' '0665' space.<br>*  m_def r_btype 'I' 'EQ' '0765' space.<br>*  M_DEF R_BTYPE 'I' 'EQ' '0865' SPACE.<br>*  M_DEF R_BTYPE 'I' 'EQ' '0965' SPACE.<br>*  M_DEF R_BTYPE 'I' 'EQ' '1065' SPACE. |
| 556 | src/#zak#analitika_del_onybf.prog.abap | * Meghatározzuk a feltöltés azonosítókat:<br>*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'. |
| 557 | src/#zak#analitika_del_onybf.prog.abap | * Adatok leválogatása |
| 558 | src/#zak#analitika_del_onybf.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 559 | src/#zak#analitika_del_onybf.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 560 | src/#zak#analitika_move.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott adatokat átmozgatja<br>*& a megadott időszakra.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2009.10.09<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 50<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 561 | src/#zak#analitika_move.prog.abap | *ALV közös rutinok |
| 562 | src/#zak#analitika_move.prog.abap | *++2365 #02.<br>* Jogosultság vizsgálat |
| 563 | src/#zak#analitika_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 564 | src/#zak#analitika_move.prog.abap | *++2265 #10.<br>* Jogosultság vizsgálat |
| 565 | src/#zak#analitika_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 566 | src/#zak#analitika_move.prog.abap | *--2265 #10.<br>*Adatok szelektálása: |
| 567 | src/#zak#analitika_move.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 568 | src/#zak#analitika_move.prog.abap | *Adatok feldolgozása |
| 569 | src/#zak#analitika_move.prog.abap | *Adatbázis műveletek |
| 570 | src/#zak#analitika_move.prog.abap | *ALV lista init |
| 571 | src/#zak#analitika_move.prog.abap | *ALV lista |
| 572 | src/#zak#analitika_move.prog.abap | *   Tábla módosítások elvégezve! |
| 573 | src/#zak#analitika_set_onybf.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ANALITIKA_SET_ONYBF<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/ANALITIKA tábla ONYBF mezőjét tölti fel:<br>*& Feltételek:<br>*&    - /ZAK/BEVALLB-ONYBF = 'X' (ABEV azonosítók)<br>*&    - feltöltés azonosító <= 2008.01.21<br>*&    - /ZAK/ANALITIKA-GJAHR < 2008<br>*&---------------------------------------------------------------------* |
| 574 | src/#zak#analitika_set_onybf.prog.abap | *MAKRO definiálás range feltöltéshez |
| 575 | src/#zak#analitika_set_onybf.prog.abap | * Jogosultság vizsgálat |
| 576 | src/#zak#analitika_set_onybf.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 577 | src/#zak#analitika_set_onybf.prog.abap | *   Kérem adjon meg további éretéket a szelekción! |
| 578 | src/#zak#analitika_set_onybf.prog.abap | *    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 579 | src/#zak#analitika_set_onybf.prog.abap | * Feltöltjük a bevallás típusokat:<br>*  m_def r_btype 'I' 'EQ' '0665' space.<br>*  m_def r_btype 'I' 'EQ' '0765' space.<br>*  m_def r_btype 'I' 'EQ' '0865' space.<br>*  m_def r_btype 'I' 'EQ' '0965' space.<br>*  m_def r_btype 'I' 'EQ' '1065' space. |
| 580 | src/#zak#analitika_set_onybf.prog.abap | * Meghatározzuk a feltöltés azonosítókat:<br>*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'. |
| 581 | src/#zak#analitika_set_onybf.prog.abap | * Adatok leválogatása |
| 582 | src/#zak#analitika_set_onybf.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 583 | src/#zak#analitika_set_onybf.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 584 | src/#zak#analitika_szla_corr.prog.abap | **&---------------------------------------------------------------------*<br>**& Report  /ZAK/ANALITIKA_SZLA_CORR<br>**&<br>**&---------------------------------------------------------------------*<br>**& A program a közös számla azonosítót tölti fel a szelekció alapján<br>**&---------------------------------------------------------------------* |
| 585 | src/#zak#atvez_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SAP adatok meghatározása átvezetési nyomtatványhoz<br>*&---------------------------------------------------------------------* |
| 586 | src/#zak#atvez_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& adatokat rögzít és tölti a /ZAK/ANALITIKA táblát.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - FMC<br>*& Létrehozás dátuma : 2006.03.08<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 587 | src/#zak#atvez_sap_sel.prog.abap | * Vállalat |
| 588 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás fajta |
| 589 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás típus |
| 590 | src/#zak#atvez_sap_sel.prog.abap | * Hónap |
| 591 | src/#zak#atvez_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 592 | src/#zak#atvez_sap_sel.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 593 | src/#zak#atvez_sap_sel.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 594 | src/#zak#atvez_sap_sel.prog.abap | *  Képernyő attribútomok beállítása |
| 595 | src/#zak#atvez_sap_sel.prog.abap | *  Bevallás típus ellenőrzése |
| 596 | src/#zak#atvez_sap_sel.prog.abap | *  Periódus ellenőrzése |
| 597 | src/#zak#atvez_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 598 | src/#zak#atvez_sap_sel.prog.abap | *  Jogosultság vizsgálat |
| 599 | src/#zak#atvez_sap_sel.prog.abap | * Zárolás beállítás |
| 600 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás utolsó napjának meghatározása |
| 601 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás általános adatai |
| 602 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás státusza |
| 603 | src/#zak#atvez_sap_sel.prog.abap | * Vállalat megnevezése |
| 604 | src/#zak#atvez_sap_sel.prog.abap | * Bevallásfajta megnevezése |
| 605 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás típus meghatározása |
| 606 | src/#zak#atvez_sap_sel.prog.abap | * Bevallásfajta megnevezése |
| 607 | src/#zak#atvez_sap_sel.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 608 | src/#zak#atvez_sap_sel.prog.abap | * Szövegek feltöltése |
| 609 | src/#zak#atvez_sap_sel.prog.abap | * Van valami az adott periódusra? |
| 610 | src/#zak#atvez_sap_sel.prog.abap | * Melyik az utolsó lezárt? |
| 611 | src/#zak#atvez_sap_sel.prog.abap | * Kilépés |
| 612 | src/#zak#atvez_sap_sel.prog.abap | * Mentés - analitika tábla feltöltése |
| 613 | src/#zak#atvez_sap_sel.prog.abap | * Kijelölt rekordok törlése |
| 614 | src/#zak#atvez_sap_sel.prog.abap | * Sor beszúrása kurzorpozíció fölé |
| 615 | src/#zak#atvez_sap_sel.prog.abap | * Sor appendálása - új sor |
| 616 | src/#zak#atvez_sap_sel.prog.abap | * Sor szerkezet szerint fel kell tölteni a belső táblát |
| 617 | src/#zak#atvez_sap_sel.prog.abap | * Nyomtatvány adatok beolvasása abevhez |
| 618 | src/#zak#atvez_sap_sel.prog.abap | * Ha nincs tétel - kezdeti inicializálás |
| 619 | src/#zak#atvez_sap_sel.prog.abap | * Ha van cél, kell forrás is |
| 620 | src/#zak#atvez_sap_sel.prog.abap | * Összeg ellenőrzés: cél nagyobb, mint a forrás |
| 621 | src/#zak#atvez_sap_sel.prog.abap | * Van-e a folyószámlán ennyi? |
| 622 | src/#zak#atvez_sap_sel.prog.abap | * Teljes periódus törlése |
| 623 | src/#zak#atvez_sap_sel.prog.abap | * ADATok mentése |
| 624 | src/#zak#atvez_sap_sel.prog.abap | * ABEV azonosító meghatározása 1. mezőre |
| 625 | src/#zak#atvez_sap_sel.prog.abap | * Tételsorszám |
| 626 | src/#zak#atvez_sap_sel.prog.abap | * Dinamikus lapszám: 24 soronként lép |
| 627 | src/#zak#atvez_sap_sel.prog.abap | * Új tétel |
| 628 | src/#zak#atvez_sap_sel.prog.abap | * Közös update |
| 629 | src/#zak#atvez_sap_sel.prog.abap | * Státusz<br>* Amennyiben  bevallás már letöltött volt > státusz visszaállítása |
| 630 | src/#zak#atvez_sap_sel.prog.abap | * Utolsó Tételszám |
| 631 | src/#zak#atvez_sap_sel.prog.abap | * N - Negyedéves |
| 632 | src/#zak#atvez_sap_sel.prog.abap | * Pénznem |
| 633 | src/#zak#atvez_sap_sel.prog.abap | * Adónem megnevezése - forrás |
| 634 | src/#zak#atvez_sap_sel.prog.abap | * Adónem megnevezése - cél |
| 635 | src/#zak#atvez_sap_sel.prog.abap | * Kiutalandó összeg |
| 636 | src/#zak#atvez_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 637 | src/#zak#book_file_gen.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Könyvelések feladása lezárt időszakról<br>*&---------------------------------------------------------------------* |
| 638 | src/#zak#book_file_gen.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& a lezárt időszakból készítí el az átvzeteés valamint az önellenőrzési<br>*& pótlék könyvelési feladás excel fájlt.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.03.30<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 639 | src/#zak#book_file_gen.prog.abap | * Vállalat. |
| 640 | src/#zak#book_file_gen.prog.abap | * Bevallás fajta meghatározása |
| 641 | src/#zak#book_file_gen.prog.abap | * Bevallás típus |
| 642 | src/#zak#book_file_gen.prog.abap | * Hónap |
| 643 | src/#zak#book_file_gen.prog.abap | *  Megnevezések meghatározása |
| 644 | src/#zak#book_file_gen.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 645 | src/#zak#book_file_gen.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 646 | src/#zak#book_file_gen.prog.abap | *  Képernyő attribútomok beállítása |
| 647 | src/#zak#book_file_gen.prog.abap | *  Megnevezések meghatározása |
| 648 | src/#zak#book_file_gen.prog.abap | *  Bevallás típus meghatározása |
| 649 | src/#zak#book_file_gen.prog.abap | *  Ellenőrizzük a megadott időszak lezárt-e. |
| 650 | src/#zak#book_file_gen.prog.abap | *  Jogosultság vizsgálat |
| 651 | src/#zak#book_file_gen.prog.abap | *  Átvezetés vagy egyéb |
| 652 | src/#zak#book_file_gen.prog.abap | *   & fájl sikeresen letöltve |
| 653 | src/#zak#book_file_gen.prog.abap | *      Önellenőrzési pótlék könyvelés beállítás hiba! Fájl nem készült! |
| 654 | src/#zak#book_file_gen.prog.abap | *      Önellenőrzési pótlék könyvelési fájl létrehozás hiba! |
| 655 | src/#zak#book_file_gen.prog.abap | *      Nincs meghatározható adat! Fájl nem készült!<br>*++BG 2008.04.16 |
| 656 | src/#zak#book_file_gen.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPU<br>*--BG 2008.04.16 |
| 657 | src/#zak#book_file_gen.prog.abap | *   & fájl sikeresen letöltve |
| 658 | src/#zak#book_file_gen.prog.abap | *++BG 2008.01.07 ÁFA arányosítás könyvelés feladás |
| 659 | src/#zak#book_file_gen.prog.abap | *        & fájl sikeresen letöltve |
| 660 | src/#zak#book_file_gen.prog.abap | *--BG 2008.01.07 ÁFA arányosítás könyvelés |
| 661 | src/#zak#book_file_gen.prog.abap | * Vállalat megnevezése |
| 662 | src/#zak#book_file_gen.prog.abap | *  Meghatározzuk a státuszt |
| 663 | src/#zak#book_file_gen.prog.abap | *  Ha a státusz nem lezárt: |
| 664 | src/#zak#book_file_gen.prog.abap | *   Kérem csak lezárt időszakot adjon meg! |
| 665 | src/#zak#bset_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ANALITIKA_SZLA_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a közös számla azonosítót tölti fel a szelekció alapján<br>*&---------------------------------------------------------------------* |
| 666 | src/#zak#bset_corr.prog.abap | * Jogosultság vizsgálat |
| 667 | src/#zak#bset_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 668 | src/#zak#bset_corr.prog.abap | * Adatok feldolgozása |
| 669 | src/#zak#bset_corr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 670 | src/#zak#bset_corr.prog.abap | *  Először mindig tesztben futtatjuk |
| 671 | src/#zak#bset_corr.prog.abap | *   Üzenetek kezelése |
| 672 | src/#zak#bset_corr.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 673 | src/#zak#bset_corr.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 674 | src/#zak#bset_corr.prog.abap | *    Ha nem háttérben fut |
| 675 | src/#zak#bset_corr.prog.abap | *    Szövegek betöltése |
| 676 | src/#zak#bset_corr.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 677 | src/#zak#bset_corr.prog.abap | *    Mehet az adatbázis módosítása |
| 678 | src/#zak#bset_corr.prog.abap | *      Adatok módosítása |
| 679 | src/#zak#bset_corr.prog.abap | * Adatmódosítások elmentve! |
| 680 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: BSET tábla időbélyeg törlés<br>*&---------------------------------------------------------------------* |
| 681 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - Ness<br>*& Létrehozás dátuma : 2016.12.06<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    :<br>*& Program  típus    : Riport<br>*& SAP verzió        :<br>*&---------------------------------------------------------------------* |
| 682 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& Egyszerű alv alapok<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& Típusdeklarációk<br>*&---------------------------------------------------------------------* |
| 683 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& TáBLáK                                                              *<br>*&---------------------------------------------------------------------* |
| 684 | src/#zak#bset_stmdt_update.prog.abap | * Vállalat. |
| 685 | src/#zak#bset_stmdt_update.prog.abap | * Tétel |
| 686 | src/#zak#bset_stmdt_update.prog.abap | *Dátum |
| 687 | src/#zak#bset_stmdt_update.prog.abap | *Idő |
| 688 | src/#zak#bset_stmdt_update.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 689 | src/#zak#bset_stmdt_update.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 690 | src/#zak#bset_stmdt_update.prog.abap | * Adat rekordszám meghatározása |
| 691 | src/#zak#bset_update.prog.abap | * Bevallás fajta |
| 692 | src/#zak#bset_update.prog.abap | *   Ellenőrzés |
| 693 | src/#zak#bset_update.prog.abap | *   Meghatározzuk a periódust |
| 694 | src/#zak#bset_update.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 695 | src/#zak#bset_update.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 696 | src/#zak#bset_update.prog.abap | * Adatszelekció: |
| 697 | src/#zak#bset_update.prog.abap | * Adatok feldolgozása |
| 698 | src/#zak#bset_update.prog.abap | *--2007.01.11 BG (FMC)<br>*     Tranzakció típus |
| 699 | src/#zak#bset_update.prog.abap | *++1365#24.<br>*BUPER meghatározása, ha az időszak 'X'-el le van zárva, akkor<br>*már itt átrakjuk az új időszakra: |
| 700 | src/#zak#bset_update.prog.abap | * LOG tábla aktualizálás |
| 701 | src/#zak#bte.fugr.#zak#lbtetop.abap | nincs emberi komment blokk |
| 702 | src/#zak#bte.fugr.#zak#saplbte.abap | nincs emberi komment blokk |
| 703 | src/#zak#bte.fugr.#zak#tax_exchange_rate_2051.abap | nincs emberi komment blokk |
| 704 | src/#zak#bukrs_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/BUKRS_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/ANALITIKA táblában feltölti az FI vállalat a<br>*& /ZAK/BSET-ben az ADÓ vállalat mezőket.<br>*&---------------------------------------------------------------------* |
| 705 | src/#zak#bukrs_corr.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 706 | src/#zak#bukrs_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 707 | src/#zak#bukrs_corr.prog.abap | * Adatok feldolgozása |
| 708 | src/#zak#bukrs_corr.prog.abap | * Adatmódosítások elmentve! |
| 709 | src/#zak#afa_egyezteto.prog.screen_9001.abap | nincs emberi komment blokk |
| 710 | src/#zak#afa_eva_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/AFA_EVA_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& /ZAK/ANALITIKA korrekció. A MAIN_EXIT-ben nem volt beállítva 1065<br>*& bevallásnál az EVA alap és adó ABEV azonosító így ezek a rekordok<br>*& üres ABEV azonosítóval jöttek létre. Ez a program összegyűjti a<br>*& szelekciónak megfelelő üres ABEV azonosítójú sorokat és a<br>*& FIELD_N alapján (LWBAS, LWSTE) eldönti, hogy az adott sor alap<br>*& vagy adó tételt tartalmaz (7995, 7996). Éles futásnál az üres<br>*& ABEV azonosítójú rekordokat törli és a feltöltött ABEV azonosítójú<br>*& rekordokat létre hozza az eredeti időszakokban.<br>*&---------------------------------------------------------------------* |
| 711 | src/#zak#afa_eva_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábr - FMC<br>*& Létrehozás dátuma : 2006.12.13<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 712 | src/#zak#afa_eva_corr.prog.abap | *ALV közös rutinok |
| 713 | src/#zak#afa_eva_corr.prog.abap | *MAKRO definiálás range feltöltéshez |
| 714 | src/#zak#afa_eva_corr.prog.abap | * Jogosultság vizsgálat |
| 715 | src/#zak#afa_eva_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 716 | src/#zak#afa_eva_corr.prog.abap | * Analitika szelekció |
| 717 | src/#zak#afa_eva_corr.prog.abap | *   Nem található olyan rekord, amit konvertálni kell! (/ZAK/ANALITIKA) |
| 718 | src/#zak#afa_eva_corr.prog.abap | * Feldolgozás |
| 719 | src/#zak#afa_eva_corr.prog.abap | *   Adó |
| 720 | src/#zak#afa_eva_corr.prog.abap | *   Egyik sem nem töröljük |
| 721 | src/#zak#afa_eva_corr.prog.abap | *   Konvertált tételek adatbázisban módosítva! |
| 722 | src/#zak#afa_eva_corr.prog.abap | *ALV lista init |
| 723 | src/#zak#afa_eva_corr.prog.abap | *ALV lista |
| 724 | src/#zak#afa_idegyeztet2.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Áfa bevallás egyeztető (APEH) lista<br>*----------------------------------------------------------------------* |
| 725 | src/#zak#afa_idegyeztet2.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás:<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor<br>*& Létrehozás dátuma : 2006.08.01<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 726 | src/#zak#afa_idegyeztet2.prog.abap | * ALV kezelési változók |
| 727 | src/#zak#afa_idegyeztet2.prog.abap | *MAKRO definiálás range feltöltéshez |
| 728 | src/#zak#afa_idegyeztet2.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 729 | src/#zak#afa_idegyeztet2.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 730 | src/#zak#afa_idegyeztet2.prog.abap | *  Jogosultság vizsgálat |
| 731 | src/#zak#afa_idegyeztet2.prog.abap | *  Egyéb adatok meghatározása |
| 732 | src/#zak#afa_idegyeztet2.prog.abap | *  Nem lehet ABEV azonosítókat meghatározni a fizetendő adó összesenhez |
| 733 | src/#zak#afa_idegyeztet2.prog.abap | *  Nem lehet ABEV azonosítókat meghatározni a levonandó adó összesenhez! |
| 734 | src/#zak#afa_idegyeztet2.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 735 | src/#zak#afa_idegyeztet2.prog.abap | *--S4HANA#01.<br>*  Belső tábla feltöltés |
| 736 | src/#zak#afa_idegyeztet2.prog.abap | *  Év, hónap meghatározás |
| 737 | src/#zak#afa_idegyeztet2.prog.abap | *  BTYPE meghatározása |
| 738 | src/#zak#afa_idegyeztet2.prog.abap | *  Éven belüli intervallum ellenőrzése |
| 739 | src/#zak#afa_idegyeztet2.prog.abap | *     Kérem az intervallumot egy éven belül adja meg! |
| 740 | src/#zak#afa_idegyeztet2.prog.abap | *  Felső érték kitöltése ha üres |
| 741 | src/#zak#afa_idegyeztet2.prog.abap | * ALV lista |
| 742 | src/#zak#afa_idegyeztet2.prog.abap | *  a kijelölt sorhoz tartozó bizonylatok megjelenítése |
| 743 | src/#zak#afa_idegyeztet2.prog.abap | *        Csak ha egyezik a BUDAT |
| 744 | src/#zak#afa_idegyeztet2.prog.abap | *        Adatok feltöltése<br>*++ BG 2007.01.31 |
| 745 | src/#zak#afa_idegyeztet2.prog.abap | *    Ha van adat. |
| 746 | src/#zak#afa_idegyeztet2.prog.abap | * Mezőkatalógus összeállítása |
| 747 | src/#zak#afa_idegyeztet2.prog.abap | *  Összesített lista: |
| 748 | src/#zak#afa_idegyeztet2.prog.abap | *  Tételes lista: |
| 749 | src/#zak#afa_idegyeztet2.prog.abap | * Kilépés |
| 750 | src/#zak#afa_idegyeztet2.prog.abap | * Mezőkatalógus összeállítása |
| 751 | src/#zak#afa_idegyeztet2.prog.abap | *--1665 #11.<br>*   & bevallás & ABEV azonosító nem létezik! |
| 752 | src/#zak#afa_idegyeztet2.prog.screen_9000.abap | nincs emberi komment blokk |
| 753 | src/#zak#afa_idegyeztet2.prog.screen_9001.abap | nincs emberi komment blokk |
| 754 | src/#zak#afa_idegyezteto.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Áfa bevallás fõkönyv egyeztetõ lista<br>*----------------------------------------------------------------------* |
| 755 | src/#zak#afa_idegyezteto.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás:<br>*&---------------------------------------------------------------------*<br>*& Szerzõ            : Dénes Károly<br>*& Létrehozás dátuma : 2006.02.07<br>*& Funkc.spec.készítõ: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2007/01/31   Balázs G.     Szelekció optimalizálás<br>*& 0002   2007/10/15   Balázs G.     INDEX kitöltése:<br>*& 0003   2008/03/31   Balázs G.     Árfolyamkülönbözet tételek leválog.<br>*& 0004   2009/11/18   Faragó l.     Performancia<br>*& 0005   2010/01/22   Balázs G.     Adatok mentése, feld. mentett ad.<br>*&---------------------------------------------------------------------* |
| 756 | src/#zak#afa_idegyezteto.prog.abap | *++0003 BG 2008/03/31<br>*Árfolyam különbözet tételekhez |
| 757 | src/#zak#afa_idegyezteto.prog.abap | * ALV kezelési változók |
| 758 | src/#zak#afa_idegyezteto.prog.abap | * vállalat |
| 759 | src/#zak#afa_idegyezteto.prog.abap | * periódus |
| 760 | src/#zak#afa_idegyezteto.prog.abap | * Tételek megjelenítése! |
| 761 | src/#zak#afa_idegyezteto.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 762 | src/#zak#afa_idegyezteto.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 763 | src/#zak#afa_idegyezteto.prog.abap | *  Jogosultság vizsgálat |
| 764 | src/#zak#afa_idegyezteto.prog.abap | *++0005 2010.01.22 BG<br>*    Adatok mentése |
| 765 | src/#zak#afa_idegyezteto.prog.abap | *    Adatok beolvasása |
| 766 | src/#zak#afa_idegyezteto.prog.abap | *      Nem áll rendelkezésre menetett adat & vállalatra! |
| 767 | src/#zak#afa_idegyezteto.prog.abap | *--0005 2010.01.22 BG<br>* ALV lista |
| 768 | src/#zak#afa_idegyezteto.prog.abap | * az adatszerkezet SAP-os struktúrája a /ZAK/BEVALLD-strname táblából<br>* kell venni |
| 769 | src/#zak#afa_idegyezteto.prog.abap | * Kilépés |
| 770 | src/#zak#afa_idegyezteto.prog.abap | * analitika struktúra megjelenítés |
| 771 | src/#zak#afa_idegyezteto.prog.abap | * Mezõkatalógus összeállítása |
| 772 | src/#zak#afa_idegyezteto.prog.abap | * /ZAK/ANALITIKA tábla |
| 773 | src/#zak#afa_idegyezteto.prog.abap | * tétel tábla |
| 774 | src/#zak#afa_idegyezteto.prog.abap | * Mezõkatalógus összeállítása |
| 775 | src/#zak#afa_idegyezteto.prog.abap | * a kijelölt sorhoz tartozó bizonylatok megjelenítése |
| 776 | src/#zak#afa_idegyezteto.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 777 | src/#zak#afa_idegyezteto.prog.abap | * idõs/zak/zak szerinti keresés |
| 778 | src/#zak#afa_idegyezteto.prog.abap | * Bizonylatszegmens: könyvelés |
| 779 | src/#zak#afa_idegyezteto.prog.abap | * periódus szerinti keresés |
| 780 | src/#zak#afa_idegyezteto.prog.abap | * Bizonylatszegmens: könyvelés |
| 781 | src/#zak#afa_idegyezteto.prog.abap | *Bizonylatszegmens: adóadatok 2 |
| 782 | src/#zak#afa_idegyezteto.prog.abap | * normál |
| 783 | src/#zak#afa_idegyezteto.prog.abap | * bseg idõs/zak/zak - periódus összerendelés |
| 784 | src/#zak#afa_idegyezteto.prog.abap | *(nem volt jó - így is a BSIS-tól indult, HINTS-et sem vette figyelembe) |
| 785 | src/#zak#afa_idegyezteto.prog.abap | * idõs/zak/zak szerinti keresés |
| 786 | src/#zak#afa_idegyezteto.prog.abap | *      Bizonylatszegmens: könyvelés |
| 787 | src/#zak#afa_idegyezteto.prog.abap | * periódus szerinti keresés |
| 788 | src/#zak#afa_idegyezteto.prog.abap | *    Meghatározzuk a típust |
| 789 | src/#zak#afa_idegyezteto.prog.abap | *  Beolvassuk az ÁFA cust táblát. |
| 790 | src/#zak#afa_idegyezteto.prog.abap | *      Benne van az ÁFA kód a beállító táblában |
| 791 | src/#zak#afa_idegyezteto.prog.abap | *        Megkeressük a nem DUM-os indexet |
| 792 | src/#zak#afa_idegyezteto.prog.abap | *      Nincs benne az áfa kód a beállító táblában |
| 793 | src/#zak#afa_idegyezteto.prog.abap | *++0003 BG 2008/03/31<br>*    Árfolyam különbözet tételek szelektálása |
| 794 | src/#zak#afa_idegyezteto.prog.abap | *   Kérem adjon meg fõkönyvi számlát a szelekción! |
| 795 | src/#zak#afa_idegyezteto.prog.abap | *  Adatok törlése |
| 796 | src/#zak#afa_idegyezteto.prog.abap | *  Adatok mentése |
| 797 | src/#zak#afa_idegyezteto.prog.abap | *  BKPF kiegészítés |
| 798 | src/#zak#afa_idegyezteto.prog.screen_9000.abap | nincs emberi komment blokk |
| 799 | src/#zak#afa_idegyezteto.prog.screen_9001.abap | nincs emberi komment blokk |
| 800 | src/#zak#afa_idosz_move.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/AFA_IDOSZ_MOVE<br>*&<br>*&---------------------------------------------------------------------*<br>*& Beolvadt vállalatok előre mutató időszakban létrehozott feltöltések<br>*& átmozgatása<br>*&---------------------------------------------------------------------* |
| 801 | src/#zak#afa_idosz_move.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 802 | src/#zak#afa_idosz_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 803 | src/#zak#afa_idosz_move.prog.abap | * Képernyő attribútomok beállítása |
| 804 | src/#zak#afa_idosz_move.prog.abap | * Vállalat kódok ellenőrzése |
| 805 | src/#zak#afa_idosz_move.prog.abap | * BTYPE ellenőrzése |
| 806 | src/#zak#afa_idosz_move.prog.abap | * Adatok meghatározása |
| 807 | src/#zak#afa_idosz_move.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 808 | src/#zak#afa_idosz_move.prog.abap | *  Üzenetek kezelése |
| 809 | src/#zak#afa_idosz_move.prog.abap | *     Adatok törlése |
| 810 | src/#zak#afa_idosz_move.prog.abap | * Konvertált tételek adatbázisban módosítva! |
| 811 | src/#zak#afa_idosz_move.prog.abap | *   A vállalatok ebben az időszakban nem léteznek a forgató táblában! |
| 812 | src/#zak#afa_idosz_move.prog.abap | *   & vállalatban & bevallás típus & bevallás fajta nem létezik! |
| 813 | src/#zak#afa_idosz_move.prog.abap | * Mezőkatalógus összeállítása |
| 814 | src/#zak#afa_mgr_bset.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/AFA_MGR_BSET<br>*&<br>*&---------------------------------------------------------------------*<br>*& Program: A program a BSET alapján feltölti az ÁFA kódokat és a<br>*& műveletkulcsot.<br>*&---------------------------------------------------------------------* |
| 815 | src/#zak#afa_mgr_bset.prog.abap | *BSET szelekcióhoz |
| 816 | src/#zak#afa_mgr_bset.prog.abap | * Jogosultság vizsgálat |
| 817 | src/#zak#afa_mgr_bset.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 818 | src/#zak#afa_mgr_bset.prog.abap | *   BSET tábla update. |
| 819 | src/#zak#afa_packdel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A SAP Hungary a BSET tábla töltését átírta de<br>*& előtte már futtatásra került a AFA_SAP_SEL program ebből adódóan<br>*& törölni kell a rekordokat a /ZAK/ANALITIKA és a /ZAK/BSET táblákból<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2007.04.16<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2008/02/09   Balázs G.     /ZAK/BSET vállalat az FI_BUKRS<br>*&                                   alapján.<br>*&---------------------------------------------------------------------* |
| 820 | src/#zak#afa_packdel.prog.abap | *ALV közös rutinok |
| 821 | src/#zak#afa_packdel.prog.abap | * M_DEF S_PACK 'I' 'EQ' '20070412_001429' SPACE.<br>* M_DEF S_PACK 'I' 'EQ' '20070412_001430' SPACE.<br>* M_DEF S_PACK 'I' 'EQ' '20070418_001455' SPACE.<br>*++1765 #19.<br>* Jogosultság vizsgálat |
| 822 | src/#zak#afa_packdel.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 823 | src/#zak#afa_packdel.prog.abap | * Adatszelekció: |
| 824 | src/#zak#afa_packdel.prog.abap | * Adatfeldolgozása |
| 825 | src/#zak#afa_packdel.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 826 | src/#zak#afa_packdel.prog.abap | *++1365 #7.<br>* ÁFA számlák beolvasása |
| 827 | src/#zak#afa_packdel.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 828 | src/#zak#afa_packdel.prog.abap | *   Adatmódosítások elmentve! |
| 829 | src/#zak#afa_packdel.prog.abap | *ALV lista init |
| 830 | src/#zak#afa_packdel.prog.abap | *ALV lista |
| 831 | src/#zak#afa_sap_selmigr.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SAP adatok meghatározása ÁFA adóbevalláshoz<br>*&---------------------------------------------------------------------* |
| 832 | src/#zak#afa_sap_selmigr.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/ANALITIKA-ba<br>*& tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.01.18<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&--------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2007.01.03   Balázs G.     Új mezők töltése, üzletág kezelés<br>*&                                   fiktív vállalat kezelése<br>*& 0002   2007.05.29   Balázs G.     ÁFA 04-es 06-os lap kezelése<br>*& 0003   2007.09.25   Balázs G.     közösségi adószám nem a törzsből<br>*&                                   hanem a bizonylatból kell<br>*& 0004   2007.10.04   Balázs G.     Vállalat és időszak forg. beépítése<br>*& 0005   2007.12.12   Balázs G.     Program másolása /ZAK/ZAK_SAP_SEL-ről<br>*&                                   Áfa arányosítás módosítások<br>*& 0006   2008.01.21   Balázs G.     Vállalat forgatás átalakítás<br>*&                                   beépítése<br>*& 0007   2008.05.21   Balázs G.     Főkönyvi szám szerinti vállalat<br>*&                                   forgatás beépítése<br>*& 0008   2008.09.01   Balázs G.     Arányosítás vállalat forgatás<br>*&                                   javítása<br>*& 0009   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra<br>*&                                   ellenőrzés visszaállítása<br>*& 0010   2009/01/14   Balázs G.     IDŐSZAK meghatározás javítása<br>*& 0011   2009/10/29   Balázs G.     Váll.forg. XREF1 átlakítás,<br>*&                                   Prof.cent. szerinti forgatás<br>*& 0012   2010/02/04   Balázs G.     VPOP aranyásított sor kezelés<br>*&                                   módosítása<br>*&---------------------------------------------------------------------* |
| 833 | src/#zak#afa_sap_selmigr.prog.abap | *BSET szelekcióhoz |
| 834 | src/#zak#afa_sap_selmigr.prog.abap | *ÁFA beállítások |
| 835 | src/#zak#afa_sap_selmigr.prog.abap | * ALV kezelési változók |
| 836 | src/#zak#afa_sap_selmigr.prog.abap | * Bevallás típus időszakonként |
| 837 | src/#zak#afa_sap_selmigr.prog.abap | *++0002 BG 2007.05.29<br>*MAKRO definiálás range feltöltéshez |
| 838 | src/#zak#afa_sap_selmigr.prog.abap | *ÁFA irány meghatározás |
| 839 | src/#zak#afa_sap_selmigr.prog.abap | *Vállalat forgatás XREF1 makró |
| 840 | src/#zak#afa_sap_selmigr.prog.abap | * Vállalat. |
| 841 | src/#zak#afa_sap_selmigr.prog.abap | * Bevallás típus. |
| 842 | src/#zak#afa_sap_selmigr.prog.abap | *  Megnevezések meghatározása |
| 843 | src/#zak#afa_sap_selmigr.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 844 | src/#zak#afa_sap_selmigr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 845 | src/#zak#afa_sap_selmigr.prog.abap | *  Képernyő attribútomok beállítása |
| 846 | src/#zak#afa_sap_selmigr.prog.abap | *  AFA bevallás típus ellenőrzése |
| 847 | src/#zak#afa_sap_selmigr.prog.abap | *    Kérem ÁFA típusú bevallás azonosítót adjon meg! |
| 848 | src/#zak#afa_sap_selmigr.prog.abap | *  Szolgáltatás azonosító ellenőrzése<br>*++0009 BG 2008/09/12 |
| 849 | src/#zak#afa_sap_selmigr.prog.abap | *  Megnevezések meghatározása |
| 850 | src/#zak#afa_sap_selmigr.prog.abap | *  Bizonylat ellenőrzés |
| 851 | src/#zak#afa_sap_selmigr.prog.abap | *  Jogosultság vizsgálat |
| 852 | src/#zak#afa_sap_selmigr.prog.abap | *  Vállalati adatok beolvasása |
| 853 | src/#zak#afa_sap_selmigr.prog.abap | *--0004 2007.10.08  BG (FMC)<br>*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 854 | src/#zak#afa_sap_selmigr.prog.abap | *   Hiba az ÁFA beállítások meghatározásánál! |
| 855 | src/#zak#afa_sap_selmigr.prog.abap | *++0002 BG 2007.05.29<br>*  VPOP szállítók meghatározása |
| 856 | src/#zak#afa_sap_selmigr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 857 | src/#zak#afa_sap_selmigr.prog.abap | *  EXIT meghívása |
| 858 | src/#zak#afa_sap_selmigr.prog.abap | *  csak a DUMMY_R-es rekordok szükségesek |
| 859 | src/#zak#afa_sap_selmigr.prog.abap | *  Teszt vagy éles futás, adatbázis módosítás, stb. |
| 860 | src/#zak#afa_sap_selmigr.prog.abap | *  Háttérben nem készítünk listát. |
| 861 | src/#zak#afa_sap_selmigr.prog.abap | * Vállalat megnevezése |
| 862 | src/#zak#afa_sap_selmigr.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 863 | src/#zak#afa_sap_selmigr.prog.abap | *   Feltöltés azonosító figyelmen kívül hagyva! |
| 864 | src/#zak#afa_sap_selmigr.prog.abap | *   Kérem adja meg a feltöltés azonosítót! |
| 865 | src/#zak#afa_sap_selmigr.prog.abap | *  Analitika adatok 04,06-os laphoz. |
| 866 | src/#zak#afa_sap_selmigr.prog.abap | *  SORTED table az ITEM meghatározás miatt |
| 867 | src/#zak#afa_sap_selmigr.prog.abap | *  Megvizsgáljuk mennyi rekordot találtunk<br>*++S4HANA#01.<br>*   DESCRIBE TABLE I_/ZAK/BSET LINES L_TABIX. |
| 868 | src/#zak#afa_sap_selmigr.prog.abap | *  Ha nem tesztfutás, és a max határ felett van és nem<br>*  háttér, akkor üzenet. |
| 869 | src/#zak#afa_sap_selmigr.prog.abap | *    Feldolgozandó rekordszám: & . Kérem futtassa a programot háttérben! |
| 870 | src/#zak#afa_sap_selmigr.prog.abap | *++2012.04.17 BG (NESS)<br>*  Beolvassuk létezik e beállítás az előleges kezelésre<br>*++S4HANA#01.<br>*   REFRESH LI_AFA_ELO. |
| 871 | src/#zak#afa_sap_selmigr.prog.abap | *  Adatok feldolgozása |
| 872 | src/#zak#afa_sap_selmigr.prog.abap | *    BSET beolvasása |
| 873 | src/#zak#afa_sap_selmigr.prog.abap | *    BKPF beolvasása |
| 874 | src/#zak#afa_sap_selmigr.prog.abap | *++0005 BG 2007.12.12<br>*    Áfa irány megahtározás |
| 875 | src/#zak#afa_sap_selmigr.prog.abap | *    Normál ÁFA feldolgozás |
| 876 | src/#zak#afa_sap_selmigr.prog.abap | *    Arányosított ÁFA feldolgozás |
| 877 | src/#zak#afa_sap_selmigr.prog.abap | * Mezőkatalógus összeállítása |
| 878 | src/#zak#afa_sap_selmigr.prog.abap | * Kilépés |
| 879 | src/#zak#afa_sap_selmigr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 880 | src/#zak#afa_sap_selmigr.prog.abap | *  Először mindig tesztben futtatjuk |
| 881 | src/#zak#afa_sap_selmigr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 882 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 883 | src/#zak#afa_sap_selmigr.prog.abap | *   Üzenetek kezelése |
| 884 | src/#zak#afa_sap_selmigr.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 885 | src/#zak#afa_sap_selmigr.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 886 | src/#zak#afa_sap_selmigr.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról, |
| 887 | src/#zak#afa_sap_selmigr.prog.abap | *    Ha nem háttérben fut |
| 888 | src/#zak#afa_sap_selmigr.prog.abap | *    Szövegek betöltése |
| 889 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 890 | src/#zak#afa_sap_selmigr.prog.abap | *    Mehet az adatbázis módosítása |
| 891 | src/#zak#afa_sap_selmigr.prog.abap | *      Adatok módosítása |
| 892 | src/#zak#afa_sap_selmigr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 893 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 894 | src/#zak#afa_sap_selmigr.prog.abap | *       SORT I_/ZAK/BSET.<br>**    Visszavezetjük az indexet |
| 895 | src/#zak#afa_sap_selmigr.prog.abap | *      Üres BSET rekordok bejelölése |
| 896 | src/#zak#afa_sap_selmigr.prog.abap | *      BSET tábla update. |
| 897 | src/#zak#afa_sap_selmigr.prog.abap | *      Feltöltés & package számmal megtörtént! |
| 898 | src/#zak#afa_sap_selmigr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 899 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 900 | src/#zak#afa_sap_selmigr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 901 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 902 | src/#zak#afa_sap_selmigr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 903 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 904 | src/#zak#afa_sap_selmigr.prog.abap | *  Esedékességszámítás bázisdátuma |
| 905 | src/#zak#afa_sap_selmigr.prog.abap | *  Szállító |
| 906 | src/#zak#afa_sap_selmigr.prog.abap | *  Számlatípus |
| 907 | src/#zak#afa_sap_selmigr.prog.abap | *--BG 2007.10.29<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 908 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 909 | src/#zak#afa_sap_selmigr.prog.abap | *  Speciális főkönyv kódja |
| 910 | src/#zak#afa_sap_selmigr.prog.abap | *  Könyvelési kulcs |
| 911 | src/#zak#afa_sap_selmigr.prog.abap | *  Kiegyenlítés dátuma |
| 912 | src/#zak#afa_sap_selmigr.prog.abap | *++BG 2008.02.19<br>*  Elmentjük a vállalat kódot |
| 913 | src/#zak#afa_sap_selmigr.prog.abap | *--0011 BG 2009.10.29<br>*--0006 2008.01.21 BG (FMC)<br>*++BG 2008.02.19<br>*  Ha a vállalat kód üres visszaírjuk az eredetit |
| 914 | src/#zak#afa_sap_selmigr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 915 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 916 | src/#zak#afa_sap_selmigr.prog.abap | *  Számlatípus |
| 917 | src/#zak#afa_sap_selmigr.prog.abap | *  Vevő |
| 918 | src/#zak#afa_sap_selmigr.prog.abap | *--BG 2007.10.29<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 919 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 920 | src/#zak#afa_sap_selmigr.prog.abap | *  Speciális főkönyv kódja |
| 921 | src/#zak#afa_sap_selmigr.prog.abap | *  Könyvelési kulcs |
| 922 | src/#zak#afa_sap_selmigr.prog.abap | *  Kiegyenlítés dátuma |
| 923 | src/#zak#afa_sap_selmigr.prog.abap | *++BG 2008.02.19<br>*  Elmentjük a vállalat kódot |
| 924 | src/#zak#afa_sap_selmigr.prog.abap | *--0011 BG 2009.10.29<br>*--0006 2008.01.21 BG (FMC)<br>*++BG 2008.02.19<br>*  Ha a vállalat kód üres visszaírjuk az eredetit |
| 925 | src/#zak#afa_sap_selmigr.prog.abap | * VPOP szállítók meghatározása<br>*++S4HANA#01.<br>*   REFRESH $R_VPOP_LIFNR. |
| 926 | src/#zak#afa_sap_selmigr.prog.abap | *  Csak ha VPOP szállító |
| 927 | src/#zak#afa_sap_selmigr.prog.abap | *++BG 2008.05.27<br>*  IDŐSZAK meghatározása |
| 928 | src/#zak#afa_sap_selmigr.prog.abap | *  BTYPE meghatározás |
| 929 | src/#zak#afa_sap_selmigr.prog.abap | *         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&) |
| 930 | src/#zak#afa_sap_selmigr.prog.abap | *  Adatok feltöltése. |
| 931 | src/#zak#afa_sap_selmigr.prog.abap | *  Egyéb adatok meghatározása |
| 932 | src/#zak#afa_sap_selmigr.prog.abap | *  Vámtarifa határozat száma (04,06): |
| 933 | src/#zak#afa_sap_selmigr.prog.abap | *  ABEV azonosító |
| 934 | src/#zak#afa_sap_selmigr.prog.abap | *  Megfizetés időpontja (04): |
| 935 | src/#zak#afa_sap_selmigr.prog.abap | *  Fizetendő adó összege (04): |
| 936 | src/#zak#afa_sap_selmigr.prog.abap | *  Fizetett adó összege (04): |
| 937 | src/#zak#afa_sap_selmigr.prog.abap | *  Befizetési bizonylat száma (04): |
| 938 | src/#zak#afa_sap_selmigr.prog.abap | *  Vámhatározatban szereplő vám érték (06): |
| 939 | src/#zak#afa_sap_selmigr.prog.abap | *  Vámértéket növelő összeg (06): |
| 940 | src/#zak#afa_sap_selmigr.prog.abap | *    Adólebonyolítás a könyvelésben meghatározása |
| 941 | src/#zak#afa_sap_selmigr.prog.abap | *ha SHKZG=S és T007B-STGRP=2, akkor önmaga<br>*ha SHKZG=S és T007B-STGRP=1, akkor ellentetje<br>*ha SHKZG=H és T007B-STGRP=1, akkor önmaga<br>*ha SHKZG=H és T007B-STGRP=2, akkor ellentetje |
| 942 | src/#zak#afa_sap_selmigr.prog.abap | *  Adóbázis (adóalap) nemzeti pénznemben tartozik |
| 943 | src/#zak#afa_sap_selmigr.prog.abap | *  Adóbázis (adóalap) nemzeti pénznemben követel |
| 944 | src/#zak#afa_sap_selmigr.prog.abap | * Előjel korrekció a standard alapján |
| 945 | src/#zak#afa_sap_selmigr.prog.abap | *   Bruttó összeg saját pénznemben |
| 946 | src/#zak#afa_sap_selmigr.prog.abap | *      Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPUT) |
| 947 | src/#zak#afa_sap_selmigr.prog.abap | *++0011 BG 2009.10.29<br>*Meghatározzuk az összes lehetséges értéket ami az XREF1-ben lehet |
| 948 | src/#zak#afa_sap_selmigr.prog.abap | *    Most már talán minden megvan lehet mappelni.<br>*    Vállalat<br>*++S4HANA#01. |
| 949 | src/#zak#afa_sap_selmigr.prog.abap | *++0001 2007.01.03 BG (FMC)<br>*    A BUPER már az adódátum alapján van meghatározva! 2007.01.11.<br>*    Gazdasági év |
| 950 | src/#zak#afa_sap_selmigr.prog.abap | *    Gazdasági hónap |
| 951 | src/#zak#afa_sap_selmigr.prog.abap | *    Tranzakció tipus |
| 952 | src/#zak#afa_sap_selmigr.prog.abap | *    Adódátum |
| 953 | src/#zak#afa_sap_selmigr.prog.abap | *    Adatszolgáltatás azonosító |
| 954 | src/#zak#afa_sap_selmigr.prog.abap | *    Pénznemkulcs |
| 955 | src/#zak#afa_sap_selmigr.prog.abap | *    Gazdasági év BSEG |
| 956 | src/#zak#afa_sap_selmigr.prog.abap | *    Könyvelési bizonylat bizonylatszáma |
| 957 | src/#zak#afa_sap_selmigr.prog.abap | *    Könyvelési sor száma könyvelési bizonylaton belül |
| 958 | src/#zak#afa_sap_selmigr.prog.abap | *    Műveletkulcs |
| 959 | src/#zak#afa_sap_selmigr.prog.abap | *    Általános forgalmi adó kódja |
| 960 | src/#zak#afa_sap_selmigr.prog.abap | *    Adó százaléka |
| 961 | src/#zak#afa_sap_selmigr.prog.abap | *    Könyvelési dátum a bizonylaton |
| 962 | src/#zak#afa_sap_selmigr.prog.abap | *  Bizonylatdátum a bizonylaton |
| 963 | src/#zak#afa_sap_selmigr.prog.abap | *  Referenciabizonylat száma |
| 964 | src/#zak#afa_sap_selmigr.prog.abap | *  Felhasználó |
| 965 | src/#zak#afa_sap_selmigr.prog.abap | *  Főkönyvi könyvelés főkönyvi számlája |
| 966 | src/#zak#afa_sap_selmigr.prog.abap | *  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 967 | src/#zak#afa_sap_selmigr.prog.abap | *& év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&) |
| 968 | src/#zak#afa_sap_selmigr.prog.abap | *++0001 2007.01.03 BG (FMC)<br>*  Üzletág mező meghatározása |
| 969 | src/#zak#afa_sap_selmigr.prog.abap | *++0004 2007.10.04  BG (FMC)<br>*  Profitcenter mező meghatározása |
| 970 | src/#zak#afa_sap_selmigr.prog.abap | *++0011 BG 2009.10.29<br>*  Profitcenter szerinti vállalat forgatás |
| 971 | src/#zak#afa_sap_selmigr.prog.abap | *++0007 BG 2008.05.21<br>*  Főkönyvi szám szerinti vállalat forgatás kezelés |
| 972 | src/#zak#afa_sap_selmigr.prog.abap | *      Elmentjük a vállalat kódot |
| 973 | src/#zak#afa_sap_selmigr.prog.abap | *--0011 BG 2009.10.29<br>*      Ha a vállalat kód üres visszaírjuk az eredetit |
| 974 | src/#zak#afa_sap_selmigr.prog.abap | *--0001 2007.01.03 BG (FMC)<br>*  Szállítói láb megkeresése<br>*  Első szelekció UMSKZ-re |
| 975 | src/#zak#afa_sap_selmigr.prog.abap | *++0002 BG 2007.05.29<br>*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 976 | src/#zak#afa_sap_selmigr.prog.abap | *--0002 BG 2007.05.29<br>*    BSEG adatok szállító feltötése |
| 977 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*++2012.04.17 BG (NESS)<br>*    Előleg tételek keresése |
| 978 | src/#zak#afa_sap_selmigr.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van szállító kód |
| 979 | src/#zak#afa_sap_selmigr.prog.abap | *++0002 BG 2007.05.29<br>*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 980 | src/#zak#afa_sap_selmigr.prog.abap | *      BSEG adatok szállító feltötése |
| 981 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*++2012.04.17 BG (NESS)<br>*      Előleg tételek keresése |
| 982 | src/#zak#afa_sap_selmigr.prog.abap | *--1365 #8.<br>*--1365 #4.<br>*    ÁFA kód ellenőrzés (LW_BSET-MWSKZ) |
| 983 | src/#zak#afa_sap_selmigr.prog.abap | *       Halasztott ÁFA-s adókód |
| 984 | src/#zak#afa_sap_selmigr.prog.abap | *          BSEG adatok szállító feltötése |
| 985 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*          Fejadat beolvasása |
| 986 | src/#zak#afa_sap_selmigr.prog.abap | *++0002 BG 2007.05.29<br>*  Ha nem kell feldolgozni, töröljük a rekordot. |
| 987 | src/#zak#afa_sap_selmigr.prog.abap | *  Vevői láb megkeresése  Első szelekció UMSKZ-re |
| 988 | src/#zak#afa_sap_selmigr.prog.abap | *      BSEG adatok szállító feltötése |
| 989 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*++2012.04.17 BG (NESS)<br>*    Előleg tételek keresése |
| 990 | src/#zak#afa_sap_selmigr.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van vevő kód |
| 991 | src/#zak#afa_sap_selmigr.prog.abap | *        BSEG adatok vevő feltötése |
| 992 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*++2012.04.17 BG (NESS)<br>*      Előleg tételek keresése |
| 993 | src/#zak#afa_sap_selmigr.prog.abap | *        Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_INPUT) |
| 994 | src/#zak#afa_sap_selmigr.prog.abap | *  AFA customizing beolvasása |
| 995 | src/#zak#afa_sap_selmigr.prog.abap | *      Ha ki van töltve a műveletkulcs, akkor erre is ellenőrzünk |
| 996 | src/#zak#afa_sap_selmigr.prog.abap | *    ABEV azonosító |
| 997 | src/#zak#afa_sap_selmigr.prog.abap | *++0002 BG 2007.05.29<br>*  Ha van adat a 04 vagy 06-os laphoz: |
| 998 | src/#zak#afa_sap_selmigr.prog.abap | *++2012.04.17 BG (NESS)<br>*  Ha van előleg tétel, akkor ezek kezelése |
| 999 | src/#zak#afa_sap_selmigr.prog.abap | *  Maghatározzuk az utolsó bevallás típust |
| 1000 | src/#zak#afa_sap_selmigr.prog.abap | *  Legnagyobb lezárt időszak meghatározása |
| 1001 | src/#zak#afa_sap_selmigr.prog.abap | *       Következő évben van |
| 1002 | src/#zak#afa_sap_selmigr.prog.abap | *    Nincs még az évben az időszak kezdő értékére tesszük |
| 1003 | src/#zak#afa_sap_selmigr.prog.abap | *   Alapesetben normál mód |
| 1004 | src/#zak#afa_sap_selmigr.prog.abap | *--S4HANA#01.<br>*  Részben arányosított |
| 1005 | src/#zak#afa_sap_selmigr.prog.abap | *   & részben arányositott vállalathoz nincs beállítva adókód! |
| 1006 | src/#zak#afa_sap_selmigr.prog.abap | *  Teljesen arányosított |
| 1007 | src/#zak#afa_sap_selmigr.prog.abap | *       Hiba az ÁFA beállítások meghatározásánál! |
| 1008 | src/#zak#afa_sap_selmigr.prog.abap | *  ÁFA kód arányosított, KTOSL ellenőrzés |
| 1009 | src/#zak#afa_sap_selmigr.prog.abap | *   Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók! |
| 1010 | src/#zak#afa_sap_selmigr.prog.abap | *   Nem határozható meg időszak arányosított ÁFA kezeléshez! |
| 1011 | src/#zak#afa_sap_selmigr.prog.abap | *  Most már talán minden megvan lehet mappelni.<br>*  Vállalat |
| 1012 | src/#zak#afa_sap_selmigr.prog.abap | *  Bevallás típus |
| 1013 | src/#zak#afa_sap_selmigr.prog.abap | *  Hónap |
| 1014 | src/#zak#afa_sap_selmigr.prog.abap | *  Bevallás sorszáma időszakon belül |
| 1015 | src/#zak#afa_sap_selmigr.prog.abap | *    Tranzakció tipus |
| 1016 | src/#zak#afa_sap_selmigr.prog.abap | *    Adódátum |
| 1017 | src/#zak#afa_sap_selmigr.prog.abap | *    Adatszolgáltatás azonosító |
| 1018 | src/#zak#afa_sap_selmigr.prog.abap | *    Pénznemkulcs |
| 1019 | src/#zak#afa_sap_selmigr.prog.abap | *    Gazdasági év BSEG |
| 1020 | src/#zak#afa_sap_selmigr.prog.abap | *    Könyvelési bizonylat bizonylatszáma |
| 1021 | src/#zak#afa_sap_selmigr.prog.abap | *    Könyvelési sor száma könyvelési bizonylaton belül |
| 1022 | src/#zak#afa_sap_selmigr.prog.abap | *    Műveletkulcs |
| 1023 | src/#zak#afa_sap_selmigr.prog.abap | *    Általános forgalmi adó kódja |
| 1024 | src/#zak#afa_sap_selmigr.prog.abap | *    Adó százaléka |
| 1025 | src/#zak#afa_sap_selmigr.prog.abap | *    Könyvelési dátum a bizonylaton |
| 1026 | src/#zak#afa_sap_selmigr.prog.abap | *  Bizonylatdátum a bizonylaton |
| 1027 | src/#zak#afa_sap_selmigr.prog.abap | *  Referenciabizonylat száma |
| 1028 | src/#zak#afa_sap_selmigr.prog.abap | *  Főkönyvi könyvelés főkönyvi számlája |
| 1029 | src/#zak#afa_sap_selmigr.prog.abap | *  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 1030 | src/#zak#afa_sap_selmigr.prog.abap | *  Üzletág mező meghatározása |
| 1031 | src/#zak#afa_sap_selmigr.prog.abap | *  Profitcenter mező meghatározása |
| 1032 | src/#zak#afa_sap_selmigr.prog.abap | *         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&) |
| 1033 | src/#zak#afa_sap_selmigr.prog.abap | *  Első szelekció UMSKZ-re |
| 1034 | src/#zak#afa_sap_selmigr.prog.abap | *    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 1035 | src/#zak#afa_sap_selmigr.prog.abap | *    BSEG adatok szállító feltötése |
| 1036 | src/#zak#afa_sap_selmigr.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van szállító kód |
| 1037 | src/#zak#afa_sap_selmigr.prog.abap | *    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 1038 | src/#zak#afa_sap_selmigr.prog.abap | *      BSEG adatok szállító feltötése |
| 1039 | src/#zak#afa_sap_selmigr.prog.abap | *  Ha nem kell feldolgozni, töröljük a rekordot. |
| 1040 | src/#zak#afa_sap_selmigr.prog.abap | *  Vevői láb megkeresése  Első szelekció UMSKZ-re |
| 1041 | src/#zak#afa_sap_selmigr.prog.abap | *      BSEG adatok szállító feltötése |
| 1042 | src/#zak#afa_sap_selmigr.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van vevő kód |
| 1043 | src/#zak#afa_sap_selmigr.prog.abap | *        BSEG adatok szállító feltötése |
| 1044 | src/#zak#afa_sap_selmigr.prog.abap | *        Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_INPUT) |
| 1045 | src/#zak#afa_sap_selmigr.prog.abap | *    Meghatározzuk a BNYLAP-ot |
| 1046 | src/#zak#afa_sap_selmigr.prog.abap | *      Nem sikerült meghatározni a VPOP kivetés értékét! (&/&/&) |
| 1047 | src/#zak#afa_sap_selmigr.prog.abap | *    beállítjuk a VPOP alapján az arányosítás típusát |
| 1048 | src/#zak#afa_sap_selmigr.prog.abap | *    Adóalap |
| 1049 | src/#zak#afa_sap_selmigr.prog.abap | *    Adóösszeg |
| 1050 | src/#zak#afa_sap_selmigr.prog.abap | *    ABEV azonosító |
| 1051 | src/#zak#afa_sap_selmigr.prog.abap | *    Arány flag |
| 1052 | src/#zak#afa_sap_selmigr.prog.abap | *    AFA customizing beolvasása |
| 1053 | src/#zak#afa_sap_selmigr.prog.abap | *      Ha ki van töltve a műveletkulcs, akkor erre is ellenőrzünk |
| 1054 | src/#zak#afa_sap_selmigr.prog.abap | *    ABEV azonosító |
| 1055 | src/#zak#afa_sap_selmigr.prog.abap | *    Arány flag |
| 1056 | src/#zak#afa_sap_selmigr.prog.abap | *  Ha van adat a 04 vagy 06-os laphoz: |
| 1057 | src/#zak#afa_sap_selmigr.prog.screen_9000.abap | nincs emberi komment blokk |
| 1058 | src/#zak#afa_sap_seln.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SAP adatok meghatározása ÁFA adóbevalláshoz<br>*&---------------------------------------------------------------------* |
| 1059 | src/#zak#afa_sap_seln.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/ANALITIKA-ba<br>*& tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.01.18<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&--------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2007.01.03   Balázs G.     Új mezők töltése, üzletág kezelés<br>*&                                   fiktív vállalat kezelése<br>*& 0002   2007.05.29   Balázs G.     ÁFA 04-es 06-os lap kezelése<br>*& 0003   2007.09.25   Balázs G.     közösségi adószám nem a törzsből<br>*&                                   hanem a bizonylatból kell<br>*& 0004   2007.10.04   Balázs G.     Vállalat és időszak forg. beépítése<br>*& 0005   2007.12.12   Balázs G.     Program másolása /ZAK/ZAK_SAP_SEL-ről<br>*&                                   Áfa arányosítás módosítások<br>*& 0006   2008.01.21   Balázs G.     Vállalat forgatás átalakítás<br>*&                                   beépítése<br>*& 0007   2008.05.21   Balázs G.     Főkönyvi szám szerinti vállalat<br>*&                                   forgatás beépítése<br>*& 0008   2008.09.01   Balázs G.     Arányosítás vállalat forgatás<br>*&                                   javítása<br>*& 0009   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra<br>*&                                   ellenőrzés visszaállítása<br>*& 0010   2009/01/14   Balázs G.     IDŐSZAK meghatározás javítása<br>*& 0011   2009/10/29   Balázs G.     Váll.forg. XREF1 átlakítás,<br>*&                                   Prof.cent. szerinti forgatás<br>*& 0012   2010/02/04   Balázs G.     VPOP aranyásított sor kezelés<br>*&                                   módosítása<br>*&---------------------------------------------------------------------* |
| 1060 | src/#zak#afa_sap_seln.prog.abap | *BSET szelekcióhoz |
| 1061 | src/#zak#afa_sap_seln.prog.abap | *ÁFA beállítások |
| 1062 | src/#zak#afa_sap_seln.prog.abap | * ALV kezelési változók |
| 1063 | src/#zak#afa_sap_seln.prog.abap | * Bevallás típus időszakonként |
| 1064 | src/#zak#afa_sap_seln.prog.abap | *++0002 BG 2007.05.29<br>*MAKRO definiálás range feltöltéshez |
| 1065 | src/#zak#afa_sap_seln.prog.abap | *ÁFA irány meghatározás |
| 1066 | src/#zak#afa_sap_seln.prog.abap | *Vállalat forgatás XREF1 makró |
| 1067 | src/#zak#afa_sap_seln.prog.abap | * Vállalat. |
| 1068 | src/#zak#afa_sap_seln.prog.abap | * Bevallás típus. |
| 1069 | src/#zak#afa_sap_seln.prog.abap | *  Megnevezések meghatározása |
| 1070 | src/#zak#afa_sap_seln.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1071 | src/#zak#afa_sap_seln.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1072 | src/#zak#afa_sap_seln.prog.abap | *  Képernyő attribútomok beállítása |
| 1073 | src/#zak#afa_sap_seln.prog.abap | *  AFA bevallás típus ellenőrzése |
| 1074 | src/#zak#afa_sap_seln.prog.abap | *    Kérem ÁFA típusú bevallás azonosítót adjon meg! |
| 1075 | src/#zak#afa_sap_seln.prog.abap | *  Szolgáltatás azonosító ellenőrzése<br>*++0009 BG 2008/09/12 |
| 1076 | src/#zak#afa_sap_seln.prog.abap | *  Megnevezések meghatározása |
| 1077 | src/#zak#afa_sap_seln.prog.abap | *--0011 BG 2009.10.29<br>*--0004 2007.10.08  BG (FMC)<br>*  Jogosultság vizsgálat |
| 1078 | src/#zak#afa_sap_seln.prog.abap | *--0011 BG 2009.10.29<br>*  Vállalati adatok beolvasása |
| 1079 | src/#zak#afa_sap_seln.prog.abap | *--0004 2007.10.08  BG (FMC)<br>*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 1080 | src/#zak#afa_sap_seln.prog.abap | *  ÁFA beállítások betöltése |
| 1081 | src/#zak#afa_sap_seln.prog.abap | *   Hiba az ÁFA beállítások meghatározásánál! |
| 1082 | src/#zak#afa_sap_seln.prog.abap | *++0002 BG 2007.05.29<br>*  VPOP szállítók meghatározása |
| 1083 | src/#zak#afa_sap_seln.prog.abap | *++0005 BG 2007.12.12<br>*  Arányosításhoz időszak meghatározása |
| 1084 | src/#zak#afa_sap_seln.prog.abap | *--0005 BG 2007.12.12<br>*  Adatok szelektálása |
| 1085 | src/#zak#afa_sap_seln.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 1086 | src/#zak#afa_sap_seln.prog.abap | *  Háttérben nem készítünk listát. |
| 1087 | src/#zak#afa_sap_seln.prog.abap | * Vállalat megnevezése |
| 1088 | src/#zak#afa_sap_seln.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 1089 | src/#zak#afa_sap_seln.prog.abap | *   Feltöltés azonosító figyelmen kívül hagyva! |
| 1090 | src/#zak#afa_sap_seln.prog.abap | *   Kérem adja meg a feltöltés azonosítót! |
| 1091 | src/#zak#afa_sap_seln.prog.abap | *  Analitika adatok 04,06-os laphoz. |
| 1092 | src/#zak#afa_sap_seln.prog.abap | *--0001 2007.01.03 BG (FMC)<br>*  SORTED table az ITEM meghatározás miatt |
| 1093 | src/#zak#afa_sap_seln.prog.abap | *  Megvizsgáljuk mennyi rekordot találtunk |
| 1094 | src/#zak#afa_sap_seln.prog.abap | *  Ha nem tesztfutás, és a max határ felett van és nem<br>*  háttér, akkor üzenet. |
| 1095 | src/#zak#afa_sap_seln.prog.abap | *    Feldolgozandó rekordszám: & . Kérem futtassa a programot háttérben! |
| 1096 | src/#zak#afa_sap_seln.prog.abap | *++2012.04.17 BG (NESS)<br>*  Beolvassuk létezik e beállítás az előleges kezelésre |
| 1097 | src/#zak#afa_sap_seln.prog.abap | *--2012.04.17 BG (NESS)<br>*  Adatok feldolgozása |
| 1098 | src/#zak#afa_sap_seln.prog.abap | *    BSET beolvasása |
| 1099 | src/#zak#afa_sap_seln.prog.abap | *    BKPF beolvasása |
| 1100 | src/#zak#afa_sap_seln.prog.abap | *    BSEG beolvasása |
| 1101 | src/#zak#afa_sap_seln.prog.abap | *++1465 #17.<br>*    Fók központ kezelés |
| 1102 | src/#zak#afa_sap_seln.prog.abap | *      Vevő |
| 1103 | src/#zak#afa_sap_seln.prog.abap | *      Szállító |
| 1104 | src/#zak#afa_sap_seln.prog.abap | *++0005 BG 2007.12.12<br>*    Áfa irány megahtározás |
| 1105 | src/#zak#afa_sap_seln.prog.abap | *    Normál ÁFA feldolgozás |
| 1106 | src/#zak#afa_sap_seln.prog.abap | *    Arányosított ÁFA feldolgozás |
| 1107 | src/#zak#afa_sap_seln.prog.abap | * Mezőkatalógus összeállítása |
| 1108 | src/#zak#afa_sap_seln.prog.abap | * Kilépés |
| 1109 | src/#zak#afa_sap_seln.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 1110 | src/#zak#afa_sap_seln.prog.abap | *  Először mindig tesztben futtatjuk |
| 1111 | src/#zak#afa_sap_seln.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 1112 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1113 | src/#zak#afa_sap_seln.prog.abap | *--1665 #08.<br>*   Üzenetek kezelése |
| 1114 | src/#zak#afa_sap_seln.prog.abap | *    Éles futás hibák miatt nem indítható! |
| 1115 | src/#zak#afa_sap_seln.prog.abap | *--2165 #06.<br>*  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról, |
| 1116 | src/#zak#afa_sap_seln.prog.abap | *    Ha nem háttérben fut |
| 1117 | src/#zak#afa_sap_seln.prog.abap | *    Szövegek betöltése |
| 1118 | src/#zak#afa_sap_seln.prog.abap | *--MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 1119 | src/#zak#afa_sap_seln.prog.abap | *    Mehet az adatbázis módosítása |
| 1120 | src/#zak#afa_sap_seln.prog.abap | *      Adatok módosítása |
| 1121 | src/#zak#afa_sap_seln.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 1122 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1123 | src/#zak#afa_sap_seln.prog.abap | *    Visszavezetjük az indexet |
| 1124 | src/#zak#afa_sap_seln.prog.abap | *        Elmentjük a package azonosítót |
| 1125 | src/#zak#afa_sap_seln.prog.abap | *      Üres BSET rekordok bejelölése |
| 1126 | src/#zak#afa_sap_seln.prog.abap | *      BSET tábla update. |
| 1127 | src/#zak#afa_sap_seln.prog.abap | *      Feltöltés & package számmal megtörtént! |
| 1128 | src/#zak#afa_sap_seln.prog.abap | *--1665 #08.<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 1129 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1130 | src/#zak#afa_sap_seln.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 1131 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1132 | src/#zak#afa_sap_seln.prog.abap | *--1665 #12.<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 1133 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1134 | src/#zak#afa_sap_seln.prog.abap | *  Esedékességszámítás bázisdátuma |
| 1135 | src/#zak#afa_sap_seln.prog.abap | *  Szállító |
| 1136 | src/#zak#afa_sap_seln.prog.abap | *  Számlatípus |
| 1137 | src/#zak#afa_sap_seln.prog.abap | *  Speciális főkönyv kódja |
| 1138 | src/#zak#afa_sap_seln.prog.abap | *  Könyvelési kulcs |
| 1139 | src/#zak#afa_sap_seln.prog.abap | *  Kiegyenlítés dátuma |
| 1140 | src/#zak#afa_sap_seln.prog.abap | *++BG 2008.02.19<br>*  Elmentjük a vállalat kódot |
| 1141 | src/#zak#afa_sap_seln.prog.abap | *--0011 BG 2009.10.29<br>*--0006 2008.01.21 BG (FMC)<br>*++BG 2008.02.19<br>*  Ha a vállalat kód üres visszaírjuk az eredetit |
| 1142 | src/#zak#afa_sap_seln.prog.abap | *++1865 #08.<br>*Csoportos szállító kezelés<br>*Ha van a táblában adat akkor ellenőrizzük |
| 1143 | src/#zak#afa_sap_seln.prog.abap | *  Ha van rekord, akkor ellenőrizzük a tartományt |
| 1144 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 1145 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1146 | src/#zak#afa_sap_seln.prog.abap | *  Számlatípus |
| 1147 | src/#zak#afa_sap_seln.prog.abap | *  Vevő |
| 1148 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 1149 | src/#zak#afa_sap_seln.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1150 | src/#zak#afa_sap_seln.prog.abap | *  Speciális főkönyv kódja |
| 1151 | src/#zak#afa_sap_seln.prog.abap | *  Könyvelési kulcs |
| 1152 | src/#zak#afa_sap_seln.prog.abap | *  Kiegyenlítés dátuma |
| 1153 | src/#zak#afa_sap_seln.prog.abap | *++BG 2008.02.19<br>*  Elmentjük a vállalat kódot |
| 1154 | src/#zak#afa_sap_seln.prog.abap | *--0011 BG 2009.10.29<br>*--0006 2008.01.21 BG (FMC)<br>*++BG 2008.02.19<br>*  Ha a vállalat kód üres visszaírjuk az eredetit |
| 1155 | src/#zak#afa_sap_seln.prog.abap | *++1865 #08.<br>*Csoportos vevő kezelés<br>*Ha van a táblában adat akkor ellenőrizzük |
| 1156 | src/#zak#afa_sap_seln.prog.abap | *  Ha van rekord, akkor ellenőrizzük a tartományt |
| 1157 | src/#zak#afa_sap_seln.prog.abap | * VPOP szállítók meghatározása |
| 1158 | src/#zak#afa_sap_seln.prog.abap | *--1665 #02.<br>*  Csak ha VPOP szállító |
| 1159 | src/#zak#afa_sap_seln.prog.abap | *++    CSAK TESZTELÉSHEZ<br>*        AND SY-SYSID EQ 'MT1'.<br>*--    CSAK TESZTELÉSHEZ<br>*++BG 2008.05.27<br>*  IDŐSZAK meghatározása |
| 1160 | src/#zak#afa_sap_seln.prog.abap | *  BTYPE meghatározás |
| 1161 | src/#zak#afa_sap_seln.prog.abap | *         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&) |
| 1162 | src/#zak#afa_sap_seln.prog.abap | *++1665 #02.<br>*      Meg kell vizsgálni, hogy van e érvényes beállítás a BNYLAP táblában mert<br>*      csak ha van akkor kell DUMMY rekordot generálni: |
| 1163 | src/#zak#afa_sap_seln.prog.abap | *  Adatok feltöltése. |
| 1164 | src/#zak#afa_sap_seln.prog.abap | *  Egyéb adatok meghatározása<br>*  Vámtarifa határozat száma (04,06): |
| 1165 | src/#zak#afa_sap_seln.prog.abap | *  ABEV azonosító |
| 1166 | src/#zak#afa_sap_seln.prog.abap | *  Megfizetés időpontja (04): |
| 1167 | src/#zak#afa_sap_seln.prog.abap | *  Fizetendő adó összege (04): |
| 1168 | src/#zak#afa_sap_seln.prog.abap | *  Fizetett adó összege (04): |
| 1169 | src/#zak#afa_sap_seln.prog.abap | *  Befizetési bizonylat száma (04): |
| 1170 | src/#zak#afa_sap_seln.prog.abap | *  Vámhatározatban szereplő vám érték (06): |
| 1171 | src/#zak#afa_sap_seln.prog.abap | *  Vámértéket növelő összeg (06): |
| 1172 | src/#zak#afa_sap_seln.prog.abap | *    Adólebonyolítás a könyvelésben meghatározása |
| 1173 | src/#zak#afa_sap_seln.prog.abap | *ha SHKZG=S és T007B-STGRP=2, akkor önmaga<br>*ha SHKZG=S és T007B-STGRP=1, akkor ellentetje<br>*ha SHKZG=H és T007B-STGRP=1, akkor önmaga<br>*ha SHKZG=H és T007B-STGRP=2, akkor ellentetje<br>*  Adóbázis (adóalap) nemzeti pénznemben tartozik |
| 1174 | src/#zak#afa_sap_seln.prog.abap | *  Adóbázis (adóalap) nemzeti pénznemben követel |
| 1175 | src/#zak#afa_sap_seln.prog.abap | * Előjel korrekció a standard alapján |
| 1176 | src/#zak#afa_sap_seln.prog.abap | *   Bruttó összeg saját pénznemben |
| 1177 | src/#zak#afa_sap_seln.prog.abap | *      Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPUT) |
| 1178 | src/#zak#afa_sap_seln.prog.abap | *++0011 BG 2009.10.29<br>*Meghatározzuk az összes lehetséges értéket ami az XREF1-ben lehet |
| 1179 | src/#zak#afa_sap_seln.prog.abap | *    Most már talán minden megvan lehet mappelni.<br>*    Vállalat |
| 1180 | src/#zak#afa_sap_seln.prog.abap | *    Gazdasági hónap |
| 1181 | src/#zak#afa_sap_seln.prog.abap | *    Tranzakció tipus |
| 1182 | src/#zak#afa_sap_seln.prog.abap | *    Adódátum |
| 1183 | src/#zak#afa_sap_seln.prog.abap | *--0001 2007.01.03 BG (FMC)<br>*    Adatszolgáltatás azonosító |
| 1184 | src/#zak#afa_sap_seln.prog.abap | *    Pénznemkulcs |
| 1185 | src/#zak#afa_sap_seln.prog.abap | *    Gazdasági év BSEG |
| 1186 | src/#zak#afa_sap_seln.prog.abap | *    Könyvelési bizonylat bizonylatszáma |
| 1187 | src/#zak#afa_sap_seln.prog.abap | *    Könyvelési sor száma könyvelési bizonylaton belül |
| 1188 | src/#zak#afa_sap_seln.prog.abap | *    Műveletkulcs |
| 1189 | src/#zak#afa_sap_seln.prog.abap | *    Általános forgalmi adó kódja |
| 1190 | src/#zak#afa_sap_seln.prog.abap | *    Adó százaléka |
| 1191 | src/#zak#afa_sap_seln.prog.abap | *++1665 #14.<br>*   Nem releváns bizonylatfajták ellenőrzése |
| 1192 | src/#zak#afa_sap_seln.prog.abap | *    bizonylatfajta ellenőrzés |
| 1193 | src/#zak#afa_sap_seln.prog.abap | *--1665 #14.<br>*    Könyvelési dátum a bizonylaton |
| 1194 | src/#zak#afa_sap_seln.prog.abap | *  Bizonylatdátum a bizonylaton |
| 1195 | src/#zak#afa_sap_seln.prog.abap | *  Referenciabizonylat száma |
| 1196 | src/#zak#afa_sap_seln.prog.abap | *  Felhasználó |
| 1197 | src/#zak#afa_sap_seln.prog.abap | *++1965 #08.<br>*  Belső referenciakulcs feltöltése |
| 1198 | src/#zak#afa_sap_seln.prog.abap | *--1965 #08.<br>*  Főkönyvi könyvelés főkönyvi számlája |
| 1199 | src/#zak#afa_sap_seln.prog.abap | *  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 1200 | src/#zak#afa_sap_seln.prog.abap | *--0004 2007.10.29 BG (FMC)<br>*++2012.04.17 BG (NESS)<br>*  Átmozgatva mivel az előleges tételekhez kell a BTYPE<br>*  BTYPE meghatározás |
| 1201 | src/#zak#afa_sap_seln.prog.abap | *& év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&) |
| 1202 | src/#zak#afa_sap_seln.prog.abap | *--2012.04.17 BG (NESS)<br>*++0001 2007.01.03 BG (FMC)<br>*  Üzletág mező meghatározása |
| 1203 | src/#zak#afa_sap_seln.prog.abap | *++0004 2007.10.04  BG (FMC)<br>*  Profitcenter mező meghatározása |
| 1204 | src/#zak#afa_sap_seln.prog.abap | *--0004 2007.12.17  BG (FMC)<br>*++0011 BG 2009.10.29<br>*  Profitcenter szerinti vállalat forgatás |
| 1205 | src/#zak#afa_sap_seln.prog.abap | *--0011 BG 2009.10.29<br>*++0007 BG 2008.05.21<br>*  Főkönyvi szám szerinti vállalat forgatás kezelés |
| 1206 | src/#zak#afa_sap_seln.prog.abap | *      Elmentjük a vállalat kódot |
| 1207 | src/#zak#afa_sap_seln.prog.abap | *--0011 BG 2009.10.29<br>*      Ha a vállalat kód üres visszaírjuk az eredetit |
| 1208 | src/#zak#afa_sap_seln.prog.abap | *++1665 #07.<br>*CPD szállító, vevő ellenőrzése |
| 1209 | src/#zak#afa_sap_seln.prog.abap | *      KOART feltöltése könyvelési kulcs alapján |
| 1210 | src/#zak#afa_sap_seln.prog.abap | *++1665 #14.<br>*     Esedékességszámítás bázisdátuma |
| 1211 | src/#zak#afa_sap_seln.prog.abap | *      Speciális főkönyv kódja |
| 1212 | src/#zak#afa_sap_seln.prog.abap | *      Könyvelési kulcs |
| 1213 | src/#zak#afa_sap_seln.prog.abap | *      Kiegyenlítés dátuma |
| 1214 | src/#zak#afa_sap_seln.prog.abap | *      Hozzárendelés |
| 1215 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*  Szállítói láb megkeresése<br>*  Első szelekció UMSKZ-re |
| 1216 | src/#zak#afa_sap_seln.prog.abap | *--2365 #07.<br>*++0002 BG 2007.05.29<br>*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 1217 | src/#zak#afa_sap_seln.prog.abap | *--0002 BG 2007.05.29<br>*    BSEG adatok szállító feltötése |
| 1218 | src/#zak#afa_sap_seln.prog.abap | *    Előleg tételek keresése |
| 1219 | src/#zak#afa_sap_seln.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van szállító kód |
| 1220 | src/#zak#afa_sap_seln.prog.abap | *--2365 #07.<br>*++0002 BG 2007.05.29<br>*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 1221 | src/#zak#afa_sap_seln.prog.abap | *--0002 BG 2007.05.29<br>*      BSEG adatok szállító feltötése |
| 1222 | src/#zak#afa_sap_seln.prog.abap | *      Előleg tételek keresése |
| 1223 | src/#zak#afa_sap_seln.prog.abap | *--1365 #8.<br>*--1365 #4.<br>*    ÁFA kód ellenőrzés (LW_BSET-MWSKZ) |
| 1224 | src/#zak#afa_sap_seln.prog.abap | *       Halasztott ÁFA-s adókód |
| 1225 | src/#zak#afa_sap_seln.prog.abap | *        Referencia bizonylat beolvasása, az első tétel kell amiben van<br>*        szállító |
| 1226 | src/#zak#afa_sap_seln.prog.abap | *          BSEG adatok szállító feltötése |
| 1227 | src/#zak#afa_sap_seln.prog.abap | *          Fejadat beolvasása |
| 1228 | src/#zak#afa_sap_seln.prog.abap | *--1665 #06.<br>*++0002 BG 2007.05.29<br>*  Ha nem kell feldolgozni, töröljük a rekordot. |
| 1229 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*  Vevői láb megkeresése  Első szelekció UMSKZ-re |
| 1230 | src/#zak#afa_sap_seln.prog.abap | *      BSEG adatok szállító feltötése |
| 1231 | src/#zak#afa_sap_seln.prog.abap | *++2012.04.17 BG (NESS)<br>*    Előleg tételek keresése |
| 1232 | src/#zak#afa_sap_seln.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van vevő kód |
| 1233 | src/#zak#afa_sap_seln.prog.abap | *        BSEG adatok vevő feltötése |
| 1234 | src/#zak#afa_sap_seln.prog.abap | *++2012.04.17 BG (NESS)<br>*      Előleg tételek keresése |
| 1235 | src/#zak#afa_sap_seln.prog.abap | *        Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_INPUT) |
| 1236 | src/#zak#afa_sap_seln.prog.abap | *--1465 #03.<br>*  AFA customizing beolvasása |
| 1237 | src/#zak#afa_sap_seln.prog.abap | *      Ha ki van töltve a műveletkulcs, akkor erre is ellenőrzünk |
| 1238 | src/#zak#afa_sap_seln.prog.abap | *    ABEV azonosító |
| 1239 | src/#zak#afa_sap_seln.prog.abap | *++0002 BG 2007.05.29<br>*  Ha van adat a 04 vagy 06-os laphoz: |
| 1240 | src/#zak#afa_sap_seln.prog.abap | *--0002 BG 2007.05.29<br>*++2012.04.17 BG (NESS)<br>*  Ha van előleg tétel, akkor ezek kezelése |
| 1241 | src/#zak#afa_sap_seln.prog.abap | *  Maghatározzuk az utolsó bevallás típust |
| 1242 | src/#zak#afa_sap_seln.prog.abap | *  Legnagyobb lezárt időszak meghatározása |
| 1243 | src/#zak#afa_sap_seln.prog.abap | *       Következő évben van |
| 1244 | src/#zak#afa_sap_seln.prog.abap | *    Nincs még az évben az időszak kezdő értékére tesszük |
| 1245 | src/#zak#afa_sap_seln.prog.abap | *   Alapesetben normál mód |
| 1246 | src/#zak#afa_sap_seln.prog.abap | *  Részben arányosított |
| 1247 | src/#zak#afa_sap_seln.prog.abap | *      Adókódok meghatározása |
| 1248 | src/#zak#afa_sap_seln.prog.abap | *   & részben arányositott vállalathoz nincs beállítva adókód! |
| 1249 | src/#zak#afa_sap_seln.prog.abap | *  Teljesen arányosított |
| 1250 | src/#zak#afa_sap_seln.prog.abap | *  Adókódok meghatározása |
| 1251 | src/#zak#afa_sap_seln.prog.abap | *       Hiba az ÁFA beállítások meghatározásánál! |
| 1252 | src/#zak#afa_sap_seln.prog.abap | *  ÁFA kód ellenőrzése |
| 1253 | src/#zak#afa_sap_seln.prog.abap | *  ÁFA kód arányosított, KTOSL ellenőrzés |
| 1254 | src/#zak#afa_sap_seln.prog.abap | *   Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók! |
| 1255 | src/#zak#afa_sap_seln.prog.abap | *   Nem határozható meg időszak arányosított ÁFA kezeléshez! |
| 1256 | src/#zak#afa_sap_seln.prog.abap | *--1665 #08.<br>*  Most már talán minden megvan lehet mappelni.<br>*  Vállalat |
| 1257 | src/#zak#afa_sap_seln.prog.abap | *  Bevallás típus |
| 1258 | src/#zak#afa_sap_seln.prog.abap | *    Tranzakció tipus |
| 1259 | src/#zak#afa_sap_seln.prog.abap | *    Adódátum |
| 1260 | src/#zak#afa_sap_seln.prog.abap | *    Adatszolgáltatás azonosító |
| 1261 | src/#zak#afa_sap_seln.prog.abap | *    Pénznemkulcs |
| 1262 | src/#zak#afa_sap_seln.prog.abap | *    Gazdasági év BSEG |
| 1263 | src/#zak#afa_sap_seln.prog.abap | *    Könyvelési bizonylat bizonylatszáma |
| 1264 | src/#zak#afa_sap_seln.prog.abap | *    Könyvelési sor száma könyvelési bizonylaton belül |
| 1265 | src/#zak#afa_sap_seln.prog.abap | *    Műveletkulcs |
| 1266 | src/#zak#afa_sap_seln.prog.abap | *    Általános forgalmi adó kódja |
| 1267 | src/#zak#afa_sap_seln.prog.abap | *    Adó százaléka |
| 1268 | src/#zak#afa_sap_seln.prog.abap | *++1665 #14.<br>*   Nem releváns bizonylatfajták ellenőrzése |
| 1269 | src/#zak#afa_sap_seln.prog.abap | *    bizonylatfajta ellenőrzés |
| 1270 | src/#zak#afa_sap_seln.prog.abap | *--1665 #14.<br>*    Könyvelési dátum a bizonylaton |
| 1271 | src/#zak#afa_sap_seln.prog.abap | *  Bizonylatdátum a bizonylaton |
| 1272 | src/#zak#afa_sap_seln.prog.abap | *  Referenciabizonylat száma |
| 1273 | src/#zak#afa_sap_seln.prog.abap | *  Főkönyvi könyvelés főkönyvi számlája |
| 1274 | src/#zak#afa_sap_seln.prog.abap | *  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 1275 | src/#zak#afa_sap_seln.prog.abap | *--0008 2008.09.01  BG<br>*  Üzletág mező meghatározása |
| 1276 | src/#zak#afa_sap_seln.prog.abap | *  Profitcenter mező meghatározása |
| 1277 | src/#zak#afa_sap_seln.prog.abap | *  BTYPE meghatározás |
| 1278 | src/#zak#afa_sap_seln.prog.abap | *         & év & hónaphoz ÁFA típusú bevallás nincs beállítva! (Biz: &/&) |
| 1279 | src/#zak#afa_sap_seln.prog.abap | *++1665 #07.<br>*CPD szállító, vevő ellenőrzése |
| 1280 | src/#zak#afa_sap_seln.prog.abap | *      KOART feltöltése könyvelési kulcs alapján |
| 1281 | src/#zak#afa_sap_seln.prog.abap | *++1665 #14.<br>*     Esedékességszámítás bázisdátuma |
| 1282 | src/#zak#afa_sap_seln.prog.abap | *      Speciális főkönyv kódja |
| 1283 | src/#zak#afa_sap_seln.prog.abap | *      Könyvelési kulcs |
| 1284 | src/#zak#afa_sap_seln.prog.abap | *      Kiegyenlítés dátuma |
| 1285 | src/#zak#afa_sap_seln.prog.abap | *      Hozzárendelés |
| 1286 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*  Első szelekció UMSKZ-re |
| 1287 | src/#zak#afa_sap_seln.prog.abap | *--2365 #07.<br>*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 1288 | src/#zak#afa_sap_seln.prog.abap | *    BSEG adatok szállító feltötése |
| 1289 | src/#zak#afa_sap_seln.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van szállító kód |
| 1290 | src/#zak#afa_sap_seln.prog.abap | *--2365 #07.<br>*    Ha a szállító VPOP és nincs kiegyenlítve, akkor nem kell a<br>*    rekord. |
| 1291 | src/#zak#afa_sap_seln.prog.abap | *      BSEG adatok szállító feltötése |
| 1292 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*  Ha nem kell feldolgozni, töröljük a rekordot. |
| 1293 | src/#zak#afa_sap_seln.prog.abap | *--1665 #06.<br>*  Ha nem kell feldolgozni, töröljük a rekordot. |
| 1294 | src/#zak#afa_sap_seln.prog.abap | *--1665 #07.<br>*  Vevői láb megkeresése  Első szelekció UMSKZ-re |
| 1295 | src/#zak#afa_sap_seln.prog.abap | *      BSEG adatok szállító feltötése |
| 1296 | src/#zak#afa_sap_seln.prog.abap | *  Nincs kitöltött UMSKZ az első tétel kell amin van vevő kód |
| 1297 | src/#zak#afa_sap_seln.prog.abap | *        BSEG adatok szállító feltötése |
| 1298 | src/#zak#afa_sap_seln.prog.abap | *        Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_INPUT) |
| 1299 | src/#zak#afa_sap_seln.prog.abap | *    Meghatározzuk a BNYLAP-ot |
| 1300 | src/#zak#afa_sap_seln.prog.abap | *      Nem sikerült meghatározni a VPOP kivetés értékét! (&/&/&) |
| 1301 | src/#zak#afa_sap_seln.prog.abap | *    beállítjuk a VPOP alapján az arányosítás típusát |
| 1302 | src/#zak#afa_sap_seln.prog.abap | *    Adóalap |
| 1303 | src/#zak#afa_sap_seln.prog.abap | *    Adóösszeg |
| 1304 | src/#zak#afa_sap_seln.prog.abap | *    ABEV azonosító |
| 1305 | src/#zak#afa_sap_seln.prog.abap | *    Arány flag |
| 1306 | src/#zak#afa_sap_seln.prog.abap | *--1465 #03.<br>*    AFA customizing beolvasása |
| 1307 | src/#zak#afa_sap_seln.prog.abap | *      Ha ki van töltve a műveletkulcs, akkor erre is ellenőrzünk |
| 1308 | src/#zak#afa_sap_seln.prog.abap | *    ABEV azonosító |
| 1309 | src/#zak#afa_sap_seln.prog.abap | *    Arány flag |
| 1310 | src/#zak#afa_sap_seln.prog.abap | *--0012 1065 2010.02.04 BG<br>*  Ha van adat a 04 vagy 06-os laphoz: |
| 1311 | src/#zak#afa_sap_seln.prog.abap | * ha '111111' vagy '000000' van az adószámban, akkor lerövidítjük |
| 1312 | src/#zak#afa_sap_seln.prog.screen_9000.abap | nincs emberi komment blokk |
| 1313 | src/#zak#afa_szla_belnr_conv.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/BUKRS_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/AFA_SZLA BELNR mezőt tölti fel vezető 0-val<br>*&---------------------------------------------------------------------* |
| 1314 | src/#zak#afa_szla_belnr_conv.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1315 | src/#zak#afa_szla_belnr_conv.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1316 | src/#zak#afa_szla_belnr_conv.prog.abap | * Adatok feldolgozása |
| 1317 | src/#zak#afa_szla_belnr_conv.prog.abap | * Adatmódosítások elmentve! |
| 1318 | src/#zak#afa_szla_noneed.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: a bevallás áttöltéséhez ellenőrző és végrehajtó program<br>*&---------------------------------------------------------------------* |
| 1319 | src/#zak#afa_szla_noneed.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& megjeleníti (ill. éles esetén módosítja) távoli RFC hívás segítségével<br>*& az átvehető bevallásokat ill. kiírja ami már átvételre került.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Bana G. Péter - Ness<br>*& Létrehozás dátuma : 2014.09.04<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    :<br>*& Program  típus    : Riport<br>*& SAP verzió        :<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2014.09.04   Bana G. Péter  Inicializált verzió<br>*& 0002   2014.09.08   Bana G. Péter  Éles üzem hozzáadása<br>*&---------------------------------------------------------------------*<br>*++S4HANA#01. |
| 1320 | src/#zak#afa_szla_noneed.prog.abap | *&---------------------------------------------------------------------*<br>*& Egyszerű alv alapok<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& Típusdeklarációk<br>*&---------------------------------------------------------------------* |
| 1321 | src/#zak#afa_szla_noneed.prog.abap | * Vállalat. |
| 1322 | src/#zak#afa_szla_noneed.prog.abap | *++2065 #05.<br>* Adóazonosító |
| 1323 | src/#zak#afa_szla_noneed.prog.abap | * Hónap |
| 1324 | src/#zak#afa_szla_noneed.prog.abap | * Közös számla azonosító |
| 1325 | src/#zak#afa_szla_noneed.prog.abap | * Számla azonosító |
| 1326 | src/#zak#afa_szla_noneed.prog.abap | * Előzmény Számla azonosító |
| 1327 | src/#zak#afa_szla_noneed.prog.abap | * Számla típus |
| 1328 | src/#zak#afa_szla_noneed.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1329 | src/#zak#afa_szla_noneed.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1330 | src/#zak#afa_szla_noneed.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 1331 | src/#zak#afa_szla_noneed.prog.abap | * kiválasztott sorok lekérése |
| 1332 | src/#zak#afa_szla_noneed.prog.abap | *   Kérem jelölje ki a feldolgozandó sort vagy sorokat! |
| 1333 | src/#zak#afa_szla_noneed.prog.abap | * kiválasztott sorok lekérése |
| 1334 | src/#zak#afa_szla_noneed.prog.abap | *   Kérem jelölje ki a feldolgozandó sort vagy sorokat! |
| 1335 | src/#zak#afa_szla_noneed.prog.abap | * nem háttérfutás |
| 1336 | src/#zak#afa_szla_noneed.prog.abap | * háttérfutás |
| 1337 | src/#zak#afa_szla_noneed.prog.abap | * fieldcatalog generálás |
| 1338 | src/#zak#afa_szla_noneed.prog.abap | * Checkbox-á alakítás |
| 1339 | src/#zak#afa_szla_noneed.prog.abap | * hotspottá alakítás<br>*    m_hotspot gt_fcat 'EBELN'. |
| 1340 | src/#zak#afa_szla_noneed.prog.abap | * zebra és optimális mezőszélesség |
| 1341 | src/#zak#afa_szla_noneed.prog.abap | * módosíthatóság beállítása<br>*    m_modify_field gt_fcat 'ERNAM' 'EDIT' 'X'.<br>* eseménykezelő példányosítása |
| 1342 | src/#zak#afa_szla_noneed.prog.abap | * hotspot eseményre regisztrálás |
| 1343 | src/#zak#afa_szla_noneed.prog.abap | * menthető layoutok |
| 1344 | src/#zak#afa_szla_noneed.prog.abap | * kiválasztható sorok |
| 1345 | src/#zak#afa_szla_noneed.prog.abap | * módosíthatóság beállítása |
| 1346 | src/#zak#afa_szla_noneed.prog.abap | * megjelenítés |
| 1347 | src/#zak#afa_szla_noneed.prog.abap | * módosíthatóság beállítása |
| 1348 | src/#zak#afa_szla_noneed.prog.abap | *--MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12 |
| 1349 | src/#zak#afa_szla_noneed.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 1350 | src/#zak#afa_szla_noneed.prog.screen_9000.abap | nincs emberi komment blokk |
| 1351 | src/#zak#afa_top.prog.abap | *++0001 2008.11.05 Balázs Gábor (Fmc) |
| 1352 | src/#zak#afa_top.prog.abap | *--0001 2008.11.05 Balázs Gábor (Fmc) |
| 1353 | src/#zak#afa_top.prog.abap | *++BG 2007.10.15<br>*MAKRO definiálás range feltöltéshez |
| 1354 | src/#zak#afa_xml_download.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: ÁFA XML fájl letöltése<br>*&---------------------------------------------------------------------* |
| 1355 | src/#zak#afa_xml_download.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program az ÁFA bevallás XML fájlt állítja elő a<br>*& /ZAK/BEVALLO tábla alapján<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - Ness<br>*& Létrehozás dátuma : 2013.07.21<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : /ZAK/ZAKO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 6.0<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES xxxxxxxxxx<br>*&                                   cseréje hagyományosra<br>*&---------------------------------------------------------------------* |
| 1356 | src/#zak#afa_xml_download.prog.abap | * Jogosultság vizsgálat |
| 1357 | src/#zak#afa_xml_download.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1358 | src/#zak#afa_xml_download.prog.abap | *  Jogosultság vizsgálat |
| 1359 | src/#zak#afa_xml_download.prog.abap | * Bevallás típus meghatározása |
| 1360 | src/#zak#afa_xml_download.prog.abap | * Esedékességi dátum kihagyása normál időszaknál |
| 1361 | src/#zak#afa_xml_download.prog.abap | * Státusz állítás |
| 1362 | src/#zak#afa_xml_download.prog.abap | *      L_FULLPATH TYPE STRING,<br>*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*        L_FULLPATH     LIKE RLGRAP-FILENAME, |
| 1363 | src/#zak#afa_xml_download.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 1364 | src/#zak#afa_xml_download.prog.abap | * Értékek leolvasása dynpro-ról |
| 1365 | src/#zak#afa_xml_download.prog.abap | * Dynpróról az éretékek leolvasása |
| 1366 | src/#zak#afa_xml_download.prog.abap | * Értékek visszaírása a változókba |
| 1367 | src/#zak#afa_xml_download.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 1368 | src/#zak#afa_xml_download.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 1369 | src/#zak#afa_xml_download.prog.abap | * XML készítés |
| 1370 | src/#zak#afa_xml_download.prog.abap | *        Hiba az XML konvertálásnál! (&) |
| 1371 | src/#zak#afa_xml_download.prog.abap | *Csak normál időszaknál |
| 1372 | src/#zak#afa_xml_download.prog.abap | * Értékek leolvasása DYNPRO-ról: |
| 1373 | src/#zak#alv_bevallb_mod.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Bevallás beállítások módosításai<br>*&---------------------------------------------------------------------* |
| 1374 | src/#zak#alv_bevallb_mod.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Bevallás beállítási adataiban történt módosítások<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - fmc<br>*& Létrehozás dátuma : 2006.06.27<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&<br>*&---------------------------------------------------------------------* |
| 1375 | src/#zak#alv_bevallb_mod.prog.abap | * Jogosultság vizsgálat |
| 1376 | src/#zak#alv_bevallb_mod.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1377 | src/#zak#alv_grid_alap.prog.abap | *&---------------------------------------------------------------------*<br>*&  Include           /ZAK/ALV_GRID_ALAP<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& Adatdeklarációk<br>*&---------------------------------------------------------------------* |
| 1378 | src/#zak#alv_grid_alap.prog.abap | *&---------------------------------------------------------------------*<br>*& ALV Makrók<br>*&---------------------------------------------------------------------*<br>* mező elrejtése |
| 1379 | src/#zak#alv_grid_alap.prog.abap | * hotspot megadása |
| 1380 | src/#zak#alv_grid_alap.prog.abap | * mező módosítása |
| 1381 | src/#zak#alv_grid_alap.prog.abap | *&---------------------------------------------------------------------*<br>*& Eseménykezelő osztály<br>*&---------------------------------------------------------------------* |
| 1382 | src/#zak#alv_list_definitions.prog.abap | *----------------------------------------------------------------------*<br>*   INCLUDE /ZAK/ALV_LIST_DEFINITIONS                                   *<br>*----------------------------------------------------------------------*<br>* ABAP List Viewer globális definíciói<br>*----------------------------------------------------------------------* |
| 1383 | src/#zak#alv_list_definitions.prog.abap | * Közös top-of-page form neve |
| 1384 | src/#zak#alv_list_definitions.prog.abap | * Lista végén hívható form neve:'END_OF_LIST' (Fõprogramba kell megírni) |
| 1385 | src/#zak#alv_list_definitions.prog.abap | * Fejléc adatok |
| 1386 | src/#zak#alv_list_definitions.prog.abap | * Mezõ katalógus |
| 1387 | src/#zak#alv_list_definitions.prog.abap | * Lista layout beállítások |
| 1388 | src/#zak#alv_list_definitions.prog.abap | * Rendezés |
| 1389 | src/#zak#alv_list_definitions.prog.abap | * Események (pl: TOP-OF-PAGE) |
| 1390 | src/#zak#alv_list_definitions.prog.abap | * Nyomtatás vezérlés |
| 1391 | src/#zak#alv_list_definitions.prog.abap | * Mezõ csoportosítások (ez inkább 'csicsa') |
| 1392 | src/#zak#alv_list_definitions.prog.abap | * Kulcsmezõk hierarchikus lista esetén |
| 1393 | src/#zak#alv_list_forms.prog.abap | *----------------------------------------------------------------------*<br>*   INCLUDE ZALV_LIST_FORMS                                         *<br>*----------------------------------------------------------------------*<br>* Az itt lévő form-okat csak akkor használd, ha számodra minden<br>* tekintetben megfelelnek !<br>* !!!   A FORM-ok MÓDOSÍTÁSA TILOS !!!!<br>*----------------------------------------------------------------------* |
| 1394 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 1395 | src/#zak#alv_list_forms.prog.abap | * ABAP/4 List Viewer hívása |
| 1396 | src/#zak#alv_list_forms.prog.abap |       "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 1397 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 1398 | src/#zak#alv_list_forms.prog.abap | * ABAP/4 List Viewer hívása |
| 1399 | src/#zak#alv_list_forms.prog.abap |       "lehetséges<br>*     IS_VARIANT               = G_VARIANT |
| 1400 | src/#zak#alv_list_forms.prog.abap | * Lista értékek inicializálása, feltöltése |
| 1401 | src/#zak#alv_list_forms.prog.abap | * Lista fejléc |
| 1402 | src/#zak#alv_list_forms.prog.abap | * Események definiálása (top-of-page) |
| 1403 | src/#zak#alv_list_forms.prog.abap | * Nyomtatás beállítások |
| 1404 | src/#zak#alv_list_forms.prog.abap | * Mező katalógus |
| 1405 | src/#zak#alv_list_forms.prog.abap | * Cím |
| 1406 | src/#zak#alv_list_forms.prog.abap | *  $gs_layout-totals_only         = 'X'."Csak az összegek<br>*  $GS_LAYOUT-TOTALS_BEFORE_ITEMS = 'X'."Összegek a tételek előtt<br>*  $gs_layout-totals_text         = 'Mindösszesen'(l01).<br>*  $GS_LAYOUT-SUBTOTALS_TEXT      = 'Részösszeg'(L02).<br>*   $gs_layout-NO_MIN_LINESIZE = 'X'. " line size = width of the list |
| 1407 | src/#zak#alv_list_forms.prog.abap | *  $gs_LAYOUT-GROUP_CHANGE_EDIT = 'X'. " Részösszeg megjel. módosítható<br>*  $gs_LAYOUT-MIN_LINESIZE = 132. |
| 1408 | src/#zak#alv_list_forms.prog.abap | *  $GS_LAYOUT-F2CODE            =<br>*  $GS_LAYOUT-CELL_MERGE        =<br>*  $GS_LAYOUT-BOX_FIELDNAME     = SPACE.<br>*  $GS_LAYOUT-NO_INPUT          =<br>*  $GS_LAYOUT-NO_VLINE          =<br>*  $GS_LAYOUT-NO_COLHEAD        =<br>*  $GS_LAYOUT-LIGHTS_FIELDNAME  =<br>*  $GS_LAYOUT-LIGHTS_CONDENSE   =<br>*  $GS_LAYOUT-KEY_HOTSPOT       =<br>*  $GS_LAYOUT-DETAIL_POPUP      =<br>*  $gs_layout-group_change_edit = 'X'.  "Felhasználó változtathatja,<br>*                                       "rendezéskor a subtotal új oldal<br>*                                       "ra kerüljön, vagy aláhúzással<br>*                                       "különüljön el<br>*  $GS_LAYOUT-GROUP_BUTTONS      =  space. |
| 1409 | src/#zak#alv_list_forms.prog.abap | * 1. mező |
| 1410 | src/#zak#alv_list_forms.prog.abap | * 2. mező |
| 1411 | src/#zak#alv_list_forms.prog.abap | * 3. mező |
| 1412 | src/#zak#alv_list_forms.prog.abap | * 4. mező |
| 1413 | src/#zak#alv_list_forms.prog.abap | * 5. mező |
| 1414 | src/#zak#alv_list_forms.prog.abap | * 6. mező |
| 1415 | src/#zak#alv_list_forms.prog.abap | * 7. mező |
| 1416 | src/#zak#alv_list_forms.prog.abap | *==================================================================*<br>*           MINTÁK a további ALV-hez kapcsolódó form hívásokra<br>*==================================================================* |
| 1417 | src/#zak#analitika_arany_corr.prog.abap | **&---------------------------------------------------------------------*<br>**& Report  /ZAK/ANALITIKA_ARANY_CORR<br>**&<br>**&---------------------------------------------------------------------*<br>**& A program az arányosított sorok FIELD_A mezőt tölti fel<br>**&---------------------------------------------------------------------* |
| 1418 | src/#zak#analitika_arany_corr.prog.abap | *<br>* Adatok feldolgozása |
| 1419 | src/#zak#analitika_arany_corr.prog.abap | *   Adatmódosítások elmentve! |
| 1420 | src/#zak#analitika_arany_corr.prog.abap | * Csak az arányosított sorok kellenek: |
| 1421 | src/#zak#analitika_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ZAK_ANALATIKA_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a 1008 bevallás 2011 adatait forgatja át DUMMY-ra<br>*&---------------------------------------------------------------------* |
| 1422 | src/#zak#analitika_corr.prog.abap | *--S4HANA#01.<br>*MAKRO definiálás range feltöltéshez |
| 1423 | src/#zak#analitika_corr.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1424 | src/#zak#analitika_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1425 | src/#zak#analitika_corr.prog.abap | *  Képernyő attribútomok beállítása |
| 1426 | src/#zak#analitika_corr.prog.abap | * Adatok feldolgozása |
| 1427 | src/#zak#analitika_del_onybf.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ANALITIKA_SET_ONYBF<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/ANALITIKA tábla ONYBF mezőjét tölti fel:<br>*& Feltételek:<br>*&    - /ZAK/BEVALLB-ONYBF = 'X' (ABEV azonosítók)<br>*&    - feltöltés azonosító <= 2008.01.21<br>*&    - /ZAK/ANALITIKA-GJAHR < 2008<br>*&---------------------------------------------------------------------* |
| 1428 | src/#zak#analitika_del_onybf.prog.abap | *MAKRO definiálás range feltöltéshez |
| 1429 | src/#zak#analitika_del_onybf.prog.abap | * Jogosultság vizsgálat |
| 1430 | src/#zak#analitika_del_onybf.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1431 | src/#zak#analitika_del_onybf.prog.abap | *   Kérem adjon meg további éretéket a szelekción! |
| 1432 | src/#zak#analitika_del_onybf.prog.abap | *    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 1433 | src/#zak#analitika_del_onybf.prog.abap | * Feltöltjük a bevallás típusokat:<br>*  m_def r_btype 'I' 'EQ' '0665' space.<br>*  m_def r_btype 'I' 'EQ' '0765' space.<br>*  M_DEF R_BTYPE 'I' 'EQ' '0865' SPACE.<br>*  M_DEF R_BTYPE 'I' 'EQ' '0965' SPACE.<br>*  M_DEF R_BTYPE 'I' 'EQ' '1065' SPACE. |
| 1434 | src/#zak#analitika_del_onybf.prog.abap | * Meghatározzuk a feltöltés azonosítókat:<br>*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'. |
| 1435 | src/#zak#analitika_del_onybf.prog.abap | * Adatok leválogatása |
| 1436 | src/#zak#analitika_del_onybf.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 1437 | src/#zak#analitika_del_onybf.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 1438 | src/#zak#analitika_move.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott adatokat átmozgatja<br>*& a megadott időszakra.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2009.10.09<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 50<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 1439 | src/#zak#analitika_move.prog.abap | *ALV közös rutinok |
| 1440 | src/#zak#analitika_move.prog.abap | *++2365 #02.<br>* Jogosultság vizsgálat |
| 1441 | src/#zak#analitika_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1442 | src/#zak#analitika_move.prog.abap | *++2265 #10.<br>* Jogosultság vizsgálat |
| 1443 | src/#zak#analitika_move.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1444 | src/#zak#analitika_move.prog.abap | *--2265 #10.<br>*Adatok szelektálása: |
| 1445 | src/#zak#analitika_move.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 1446 | src/#zak#analitika_move.prog.abap | *Adatok feldolgozása |
| 1447 | src/#zak#analitika_move.prog.abap | *Adatbázis műveletek |
| 1448 | src/#zak#analitika_move.prog.abap | *ALV lista init |
| 1449 | src/#zak#analitika_move.prog.abap | *ALV lista |
| 1450 | src/#zak#analitika_move.prog.abap | *   Tábla módosítások elvégezve! |
| 1451 | src/#zak#analitika_set_onybf.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ANALITIKA_SET_ONYBF<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/ANALITIKA tábla ONYBF mezőjét tölti fel:<br>*& Feltételek:<br>*&    - /ZAK/BEVALLB-ONYBF = 'X' (ABEV azonosítók)<br>*&    - feltöltés azonosító <= 2008.01.21<br>*&    - /ZAK/ANALITIKA-GJAHR < 2008<br>*&---------------------------------------------------------------------* |
| 1452 | src/#zak#analitika_set_onybf.prog.abap | *MAKRO definiálás range feltöltéshez |
| 1453 | src/#zak#analitika_set_onybf.prog.abap | * Jogosultság vizsgálat |
| 1454 | src/#zak#analitika_set_onybf.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1455 | src/#zak#analitika_set_onybf.prog.abap | *   Kérem adjon meg további éretéket a szelekción! |
| 1456 | src/#zak#analitika_set_onybf.prog.abap | *    Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 1457 | src/#zak#analitika_set_onybf.prog.abap | * Feltöltjük a bevallás típusokat:<br>*  m_def r_btype 'I' 'EQ' '0665' space.<br>*  m_def r_btype 'I' 'EQ' '0765' space.<br>*  m_def r_btype 'I' 'EQ' '0865' space.<br>*  m_def r_btype 'I' 'EQ' '0965' space.<br>*  m_def r_btype 'I' 'EQ' '1065' space. |
| 1458 | src/#zak#analitika_set_onybf.prog.abap | * Meghatározzuk a feltöltés azonosítókat:<br>*  m_def r_pack 'E' 'BT' '20100414_000000' '99991231_999999'. |
| 1459 | src/#zak#analitika_set_onybf.prog.abap | * Adatok leválogatása |
| 1460 | src/#zak#analitika_set_onybf.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 1461 | src/#zak#analitika_set_onybf.prog.abap | * Az adatok mentése sikeresen megtörtént! |
| 1462 | src/#zak#analitika_szla_corr.prog.abap | **&---------------------------------------------------------------------*<br>**& Report  /ZAK/ANALITIKA_SZLA_CORR<br>**&<br>**&---------------------------------------------------------------------*<br>**& A program a közös számla azonosítót tölti fel a szelekció alapján<br>**&---------------------------------------------------------------------* |
| 1463 | src/#zak#atvez_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SAP adatok meghatározása átvezetési nyomtatványhoz<br>*&---------------------------------------------------------------------* |
| 1464 | src/#zak#atvez_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& adatokat rögzít és tölti a /ZAK/ANALITIKA táblát.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - FMC<br>*& Létrehozás dátuma : 2006.03.08<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 1465 | src/#zak#atvez_sap_sel.prog.abap | * Vállalat |
| 1466 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás fajta |
| 1467 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás típus |
| 1468 | src/#zak#atvez_sap_sel.prog.abap | * Hónap |
| 1469 | src/#zak#atvez_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 1470 | src/#zak#atvez_sap_sel.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1471 | src/#zak#atvez_sap_sel.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1472 | src/#zak#atvez_sap_sel.prog.abap | *  Képernyő attribútomok beállítása |
| 1473 | src/#zak#atvez_sap_sel.prog.abap | *  Bevallás típus ellenőrzése |
| 1474 | src/#zak#atvez_sap_sel.prog.abap | *  Periódus ellenőrzése |
| 1475 | src/#zak#atvez_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 1476 | src/#zak#atvez_sap_sel.prog.abap | *  Jogosultság vizsgálat |
| 1477 | src/#zak#atvez_sap_sel.prog.abap | * Zárolás beállítás |
| 1478 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás utolsó napjának meghatározása |
| 1479 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás általános adatai |
| 1480 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás státusza |
| 1481 | src/#zak#atvez_sap_sel.prog.abap | * Vállalat megnevezése |
| 1482 | src/#zak#atvez_sap_sel.prog.abap | * Bevallásfajta megnevezése |
| 1483 | src/#zak#atvez_sap_sel.prog.abap | * Bevallás típus meghatározása |
| 1484 | src/#zak#atvez_sap_sel.prog.abap | * Bevallásfajta megnevezése |
| 1485 | src/#zak#atvez_sap_sel.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 1486 | src/#zak#atvez_sap_sel.prog.abap | * Szövegek feltöltése |
| 1487 | src/#zak#atvez_sap_sel.prog.abap | * Van valami az adott periódusra? |
| 1488 | src/#zak#atvez_sap_sel.prog.abap | * Melyik az utolsó lezárt? |
| 1489 | src/#zak#atvez_sap_sel.prog.abap | * Kilépés |
| 1490 | src/#zak#atvez_sap_sel.prog.abap | * Mentés - analitika tábla feltöltése |
| 1491 | src/#zak#atvez_sap_sel.prog.abap | * Kijelölt rekordok törlése |
| 1492 | src/#zak#atvez_sap_sel.prog.abap | * Sor beszúrása kurzorpozíció fölé |
| 1493 | src/#zak#atvez_sap_sel.prog.abap | * Sor appendálása - új sor |
| 1494 | src/#zak#atvez_sap_sel.prog.abap | * Sor szerkezet szerint fel kell tölteni a belső táblát |
| 1495 | src/#zak#atvez_sap_sel.prog.abap | * Nyomtatvány adatok beolvasása abevhez |
| 1496 | src/#zak#atvez_sap_sel.prog.abap | * Ha nincs tétel - kezdeti inicializálás |
| 1497 | src/#zak#atvez_sap_sel.prog.abap | * Ha van cél, kell forrás is |
| 1498 | src/#zak#atvez_sap_sel.prog.abap | * Összeg ellenőrzés: cél nagyobb, mint a forrás |
| 1499 | src/#zak#atvez_sap_sel.prog.abap | * Van-e a folyószámlán ennyi? |
| 1500 | src/#zak#atvez_sap_sel.prog.abap | * Teljes periódus törlése |
| 1501 | src/#zak#atvez_sap_sel.prog.abap | * ADATok mentése |
| 1502 | src/#zak#atvez_sap_sel.prog.abap | * ABEV azonosító meghatározása 1. mezőre |
| 1503 | src/#zak#atvez_sap_sel.prog.abap | * Tételsorszám |
| 1504 | src/#zak#atvez_sap_sel.prog.abap | * Dinamikus lapszám: 24 soronként lép |
| 1505 | src/#zak#atvez_sap_sel.prog.abap | * Új tétel |
| 1506 | src/#zak#atvez_sap_sel.prog.abap | * Közös update |
| 1507 | src/#zak#atvez_sap_sel.prog.abap | * Státusz<br>* Amennyiben  bevallás már letöltött volt > státusz visszaállítása |
| 1508 | src/#zak#atvez_sap_sel.prog.abap | * Utolsó Tételszám |
| 1509 | src/#zak#atvez_sap_sel.prog.abap | * N - Negyedéves |
| 1510 | src/#zak#atvez_sap_sel.prog.abap | * Pénznem |
| 1511 | src/#zak#atvez_sap_sel.prog.abap | * Adónem megnevezése - forrás |
| 1512 | src/#zak#atvez_sap_sel.prog.abap | * Adónem megnevezése - cél |
| 1513 | src/#zak#atvez_sap_sel.prog.abap | * Kiutalandó összeg |
| 1514 | src/#zak#atvez_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 1515 | src/#zak#book_file_gen.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Könyvelések feladása lezárt időszakról<br>*&---------------------------------------------------------------------* |
| 1516 | src/#zak#book_file_gen.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& a lezárt időszakból készítí el az átvzeteés valamint az önellenőrzési<br>*& pótlék könyvelési feladás excel fájlt.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.03.30<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 1517 | src/#zak#book_file_gen.prog.abap | * Vállalat. |
| 1518 | src/#zak#book_file_gen.prog.abap | * Bevallás fajta meghatározása |
| 1519 | src/#zak#book_file_gen.prog.abap | * Bevallás típus |
| 1520 | src/#zak#book_file_gen.prog.abap | * Hónap |
| 1521 | src/#zak#book_file_gen.prog.abap | *  Megnevezések meghatározása |
| 1522 | src/#zak#book_file_gen.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1523 | src/#zak#book_file_gen.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1524 | src/#zak#book_file_gen.prog.abap | *  Képernyő attribútomok beállítása |
| 1525 | src/#zak#book_file_gen.prog.abap | *  Megnevezések meghatározása |
| 1526 | src/#zak#book_file_gen.prog.abap | *  Bevallás típus meghatározása |
| 1527 | src/#zak#book_file_gen.prog.abap | *  Ellenőrizzük a megadott időszak lezárt-e. |
| 1528 | src/#zak#book_file_gen.prog.abap | *  Jogosultság vizsgálat |
| 1529 | src/#zak#book_file_gen.prog.abap | *  Átvezetés vagy egyéb |
| 1530 | src/#zak#book_file_gen.prog.abap | *   & fájl sikeresen letöltve |
| 1531 | src/#zak#book_file_gen.prog.abap | *      Önellenőrzési pótlék könyvelés beállítás hiba! Fájl nem készült! |
| 1532 | src/#zak#book_file_gen.prog.abap | *      Önellenőrzési pótlék könyvelési fájl létrehozás hiba! |
| 1533 | src/#zak#book_file_gen.prog.abap | *      Nincs meghatározható adat! Fájl nem készült!<br>*++BG 2008.04.16 |
| 1534 | src/#zak#book_file_gen.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPU<br>*--BG 2008.04.16 |
| 1535 | src/#zak#book_file_gen.prog.abap | *   & fájl sikeresen letöltve |
| 1536 | src/#zak#book_file_gen.prog.abap | *++BG 2008.01.07 ÁFA arányosítás könyvelés feladás |
| 1537 | src/#zak#book_file_gen.prog.abap | *        & fájl sikeresen letöltve |
| 1538 | src/#zak#book_file_gen.prog.abap | *--BG 2008.01.07 ÁFA arányosítás könyvelés |
| 1539 | src/#zak#book_file_gen.prog.abap | * Vállalat megnevezése |
| 1540 | src/#zak#book_file_gen.prog.abap | *  Meghatározzuk a státuszt |
| 1541 | src/#zak#book_file_gen.prog.abap | *  Ha a státusz nem lezárt: |
| 1542 | src/#zak#book_file_gen.prog.abap | *   Kérem csak lezárt időszakot adjon meg! |
| 1543 | src/#zak#bset_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ANALITIKA_SZLA_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a közös számla azonosítót tölti fel a szelekció alapján<br>*&---------------------------------------------------------------------* |
| 1544 | src/#zak#bset_corr.prog.abap | * Jogosultság vizsgálat |
| 1545 | src/#zak#bset_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1546 | src/#zak#bset_corr.prog.abap | * Adatok feldolgozása |
| 1547 | src/#zak#bset_corr.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 1548 | src/#zak#bset_corr.prog.abap | *  Először mindig tesztben futtatjuk |
| 1549 | src/#zak#bset_corr.prog.abap | *   Üzenetek kezelése |
| 1550 | src/#zak#bset_corr.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 1551 | src/#zak#bset_corr.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 1552 | src/#zak#bset_corr.prog.abap | *    Ha nem háttérben fut |
| 1553 | src/#zak#bset_corr.prog.abap | *    Szövegek betöltése |
| 1554 | src/#zak#bset_corr.prog.abap | *--S4HANA#01.<br>*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 1555 | src/#zak#bset_corr.prog.abap | *    Mehet az adatbázis módosítása |
| 1556 | src/#zak#bset_corr.prog.abap | *      Adatok módosítása |
| 1557 | src/#zak#bset_corr.prog.abap | * Adatmódosítások elmentve! |
| 1558 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: BSET tábla időbélyeg törlés<br>*&---------------------------------------------------------------------* |
| 1559 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - Ness<br>*& Létrehozás dátuma : 2016.12.06<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    :<br>*& Program  típus    : Riport<br>*& SAP verzió        :<br>*&---------------------------------------------------------------------* |
| 1560 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& Egyszerű alv alapok<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& Típusdeklarációk<br>*&---------------------------------------------------------------------* |
| 1561 | src/#zak#bset_stmdt_update.prog.abap | *&---------------------------------------------------------------------*<br>*& TáBLáK                                                              *<br>*&---------------------------------------------------------------------* |
| 1562 | src/#zak#bset_stmdt_update.prog.abap | * Vállalat. |
| 1563 | src/#zak#bset_stmdt_update.prog.abap | * Tétel |
| 1564 | src/#zak#bset_stmdt_update.prog.abap | *Dátum |
| 1565 | src/#zak#bset_stmdt_update.prog.abap | *Idő |
| 1566 | src/#zak#bset_stmdt_update.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1567 | src/#zak#bset_stmdt_update.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1568 | src/#zak#bset_stmdt_update.prog.abap | * Adat rekordszám meghatározása |
| 1569 | src/#zak#bset_update.prog.abap | * Bevallás fajta |
| 1570 | src/#zak#bset_update.prog.abap | *   Ellenőrzés |
| 1571 | src/#zak#bset_update.prog.abap | *   Meghatározzuk a periódust |
| 1572 | src/#zak#bset_update.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1573 | src/#zak#bset_update.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1574 | src/#zak#bset_update.prog.abap | * Adatszelekció: |
| 1575 | src/#zak#bset_update.prog.abap | * Adatok feldolgozása |
| 1576 | src/#zak#bset_update.prog.abap | *--2007.01.11 BG (FMC)<br>*     Tranzakció típus |
| 1577 | src/#zak#bset_update.prog.abap | *++1365#24.<br>*BUPER meghatározása, ha az időszak 'X'-el le van zárva, akkor<br>*már itt átrakjuk az új időszakra: |
| 1578 | src/#zak#bset_update.prog.abap | * LOG tábla aktualizálás |
| 1579 | src/#zak#bte.fugr.#zak#lbtetop.abap | nincs emberi komment blokk |
| 1580 | src/#zak#bte.fugr.#zak#saplbte.abap | nincs emberi komment blokk |
| 1581 | src/#zak#bte.fugr.#zak#tax_exchange_rate_2051.abap | nincs emberi komment blokk |
| 1582 | src/#zak#bukrs_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/BUKRS_CORR<br>*&<br>*&---------------------------------------------------------------------*<br>*& A program a /ZAK/ANALITIKA táblában feltölti az FI vállalat a<br>*& /ZAK/BSET-ben az ADÓ vállalat mezőket.<br>*&---------------------------------------------------------------------* |
| 1583 | src/#zak#bukrs_corr.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 1584 | src/#zak#bukrs_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1585 | src/#zak#bukrs_corr.prog.abap | * Adatok feldolgozása |
| 1586 | src/#zak#bukrs_corr.prog.abap | * Adatmódosítások elmentve! |
| 1587 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * ...<br>*&---------------------------------------------------------------------*<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ----------------------------------<br>*& 0001   2007.01.03   Balázs G.(FMC) /ZAK/BSET tábla aktualizálása<br>*&                                    adódátummal és tranzakció típussal<br>*&---------------------------------------------------------------------* |
| 1588 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Bevallás fajta |
| 1589 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | *   Ellenőrzés |
| 1590 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | *   Meghatározzuk a periódust |
| 1591 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Kezdődátum beolvasása összes vállalathoz |
| 1592 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Áfa tételek - befizetendő |
| 1593 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Dátum ellenőrzése |
| 1594 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Hozzá tartozó BSET rekord kiválasztása |
| 1595 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Áfa tételek - visszaigényelhető |
| 1596 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Dátum ellenőrzése |
| 1597 | src/#zak#cl_im_ak_fi_tax_badi_015.clas.abap | * Hozzá tartozó BSET rekord kiválasztása |
| 1598 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * ...<br>*&---------------------------------------------------------------------*<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ----------------------------------<br>*& 0001   2007.01.03   Balázs G.(FMC) /ZAK/BSET tábla aktualizálása<br>*&                                    adódátummal és tranzakció típussal<br>*&---------------------------------------------------------------------* |
| 1599 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Bevallás fajta |
| 1600 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | *   Ellenőrzés |
| 1601 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | *   Meghatározzuk a periódust |
| 1602 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Kezdődátum beolvasása összes vállalathoz |
| 1603 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Vállalatonkénti olvasás |
| 1604 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Áfa tételek - befizetendő |
| 1605 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Dátum ellenőrzése |
| 1606 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Hozzá tartozó BSET rekord kiválasztása |
| 1607 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Áfa tételek - visszaigényelhető |
| 1608 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Dátum ellenőrzése |
| 1609 | src/#zak#cl_im_ak_fi_tax_badi_016.clas.abap | * Hozzá tartozó BSET rekord kiválasztása |
| 1610 | src/#zak#cl_im_ak_invoice_update.clas.abap | *----------------------------------------------------------------------*<br>* Adó átszámítási árfolyamának meghatározása<br>*----------------------------------------------------------------------* |
| 1611 | src/#zak#cl_im_badi_fdcb_subbas04.clas.abap | nincs emberi komment blokk |
| 1612 | src/#zak#common_struct.prog.abap | *--2065 #04.<br>* Bevallás fajta |
| 1613 | src/#zak#common_struct.prog.abap | *Nyomtatvány lap azonosítók: |
| 1614 | src/#zak#common_struct.prog.abap | *Maximális megjelnítő sorok szám ALV GRID-ben |
| 1615 | src/#zak#common_struct.prog.abap | * Adatszolgáltatás fájl formátumai:<br>* TXT fájl |
| 1616 | src/#zak#common_struct.prog.abap | * EXCEL fájl |
| 1617 | src/#zak#common_struct.prog.abap | * XML fájl |
| 1618 | src/#zak#common_struct.prog.abap | * 107 ABEV kód, kontrol adatszolgáltatás jellege |
| 1619 | src/#zak#common_struct.prog.abap | *Részben arányosított |
| 1620 | src/#zak#common_struct.prog.abap | *Teljesen arányosított |
| 1621 | src/#zak#common_struct.prog.abap | * Adóalap |
| 1622 | src/#zak#common_struct.prog.abap | * abev kód |
| 1623 | src/#zak#common_struct.prog.abap | *++BG 2006/09/22<br>* Új ABEV kódok 2006.09.01-től érvényes: |
| 1624 | src/#zak#common_struct.prog.abap | *--BG 2007/01/21<br>**++BG 2008/01/14<br>*           Transzport miatt áthelyezve a /ZAK/MAIN_EXIT_NEW-ba<br>*           C_ABEVAZ_A0IC50072A TYPE /ZAK/ABEVAZ VALUE 'A0IC50072A',<br>*           C_ABEVAZ_A0IC50073A TYPE /ZAK/ABEVAZ VALUE 'A0IC50073A',<br>*           C_ABEVAZ_A0IC50074A TYPE /ZAK/ABEVAZ VALUE 'A0IC50074A',<br>*           C_ABEVAZ_A0IC50075A TYPE /ZAK/ABEVAZ VALUE 'A0IC50075A',<br>*           C_ABEVAZ_A0IC50076A TYPE /ZAK/ABEVAZ VALUE 'A0IC50076A',<br>*           C_ABEVAZ_A0IC50077A TYPE /ZAK/ABEVAZ VALUE 'A0IC50077A'.<br>**--BG 2008/01/14 |
| 1625 | src/#zak#common_struct.prog.abap | *++2010.11.09  Balázs Gábor (Ness) |
| 1626 | src/#zak#common_struct.prog.abap | *--2010.11.09  Balázs Gábor (Ness) |
| 1627 | src/#zak#common_struct.prog.abap | *++BG 2006/05/29<br>*Adóazonosítónkénti lapszám állandók |
| 1628 | src/#zak#common_struct.prog.abap | *Range tartományok |
| 1629 | src/#zak#common_struct.prog.abap | *++BG 2006/09/22<br>* Új tartomány 2006.09.01-től |
| 1630 | src/#zak#common_struct.prog.abap | * adónem pótlék számításhoz |
| 1631 | src/#zak#common_struct.prog.abap | * adónem önellenőrzési pótlék meghatározásához |
| 1632 | src/#zak#common_struct.prog.abap | *--2010.06.04 BG<br>*++1908 #01. 2019.01.29<br>*/ZAK/START táblába átrakva<br>** pótlék számításhoz (ÁFA)<br>*CONSTANTS: C_REFER       TYPE REFERENZ   VALUE 'MATAVJ1'.<br>*--1908 #01. 2019.01.29<br>*++1908 #04. |
| 1633 | src/#zak#common_struct.prog.abap | *--1908 #04.<br>*&---------------------------------------------------------------------*<br>*& Jogosultsághoz aktivitás<br>*&---------------------------------------------------------------------* |
| 1634 | src/#zak#common_struct.prog.abap | *Összeg típusa |
| 1635 | src/#zak#common_struct.prog.abap | *++2007.07.23 BG(FMC)<br>* Termelési naptár definiálás munkanap meghatározásához: |
| 1636 | src/#zak#common_struct.prog.abap | *--2007.07.23 BG(FMC)<br>*++1365 2013.01.10 Balázs Gábor (Ness) |
| 1637 | src/#zak#common_struct.prog.abap | *--1365 2013.01.10 Balázs Gábor (Ness)<br>*++2165 #02. |
| 1638 | src/#zak#common_struct.prog.abap | *--2165 #02.<br>*++1465 #01. 2013.02.04 Balázs Gábor (Ness) |
| 1639 | src/#zak#common_struct.prog.abap | *--1465 #01. 2013.02.04 Balázs Gábor (Ness)<br>*++1565 #01. 2015.01.26 |
| 1640 | src/#zak#common_struct.prog.abap | *--1565 #02.<br>*++14A60 #01. 2014.02.04 Balázs Gábor (Ness) |
| 1641 | src/#zak#common_struct.prog.abap | *--14A60 #01. 2014.02.04 Balázs Gábor (Ness)<br>*++1765 #28. |
| 1642 | src/#zak#common_struct.prog.abap | *                              "meghatározása |
| 1643 | src/#zak#common_struct.prog.abap | *--BG 2008.03.28<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 1644 | src/#zak#common_struct.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 1645 | src/#zak#common_struct.prog.abap | * Jogosultság vizsgálat |
| 1646 | src/#zak#common_struct.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1647 | src/#zak#del_data.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekcióban megadott adatokat kitörli<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2007.09.25<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&<br>*&---------------------------------------------------------------------* |
| 1648 | src/#zak#del_data.prog.abap | *Adatok törlése |
| 1649 | src/#zak#del_data.prog.abap | *MAKRO definiálás range feltöltéshez |
| 1650 | src/#zak#del_data.prog.abap | *Figyelmeztetés |
| 1651 | src/#zak#del_data.prog.abap | * Jogosultság vizsgálat |
| 1652 | src/#zak#del_data.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1653 | src/#zak#del_data.prog.abap | *   Figyelem! Ön az éles rendszerben akar adatokat törlni! |
| 1654 | src/#zak#del_data.prog.abap | * Package azonosítók gyűjtése |
| 1655 | src/#zak#del_data.prog.abap | * /ZAK/BEVALLP aktualizálás |
| 1656 | src/#zak#del_data.prog.abap | * Tábla törlések elvégezve! |
| 1657 | src/#zak#evvalt_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Év váltás korrekció<br>*&---------------------------------------------------------------------* |
| 1658 | src/#zak#evvalt_corr.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Mivel előző évben keletkeznek olyan rekordok az<br>*& analitikában, aminél a bevallás típús még az előző évi (pld. repi<br>*& könyvelések), ezért szükséges ez a konverziós program, ami ezeket<br>*& a tételeket átforgatja az aktuális év ABEV azonosítóira<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábr - FMC<br>*& Létrehozás dátuma : 2006.12.13<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 1659 | src/#zak#evvalt_corr.prog.abap | *ALV közös rutinok |
| 1660 | src/#zak#evvalt_corr.prog.abap | *++BG 2007.04.26<br>*MAKRO definiálás range feltöltéshez |
| 1661 | src/#zak#evvalt_corr.prog.abap | * Jogosultság vizsgálat |
| 1662 | src/#zak#evvalt_corr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 1663 | src/#zak#evvalt_corr.prog.abap | * Megállapítjuk a lezárt időszakokat az adott  évben |
| 1664 | src/#zak#evvalt_corr.prog.abap | * Megállapítjuk, hogy milyen érvényes bevallás típusok léteznek az<br>* adott évben. |
| 1665 | src/#zak#evvalt_corr.prog.abap | * Analitika szelekció |
| 1666 | src/#zak#evvalt_corr.prog.abap | * Feldolgozás |
| 1667 | src/#zak#evvalt_corr.prog.abap | * Előtérben obj.lista |
| 1668 | src/#zak#evvalt_corr.prog.abap | * Háttérben ALV listát. |
| 1669 | src/#zak#evvalt_corr.prog.abap | *   Nincs érvényes bevallás típus beállítva & évben! (/ZAK/BEVALL) |
| 1670 | src/#zak#evvalt_corr.prog.abap | *BTYPART alapján meghatározzuk a BTYPE-ot |
| 1671 | src/#zak#evvalt_corr.prog.abap | *--BG 2007.04.26<br>*++2065 #11.<br>*   IDŐSZAK első napje |
| 1672 | src/#zak#evvalt_corr.prog.abap | *--2065 #11.<br>*   Ellenőrizzük a BTYPE-ot |
| 1673 | src/#zak#evvalt_corr.prog.abap | *++2065 #04.<br>*     Összegyűjtjük a releváns BEVALL bejegyzésket (időszak kezelés miatt) |
| 1674 | src/#zak#evvalt_corr.prog.abap | *   Nem található olyan rekord, amit konvertálni kell! (/ZAK/ANALITIKA) |
| 1675 | src/#zak#evvalt_corr.prog.abap | *++BG 2007.04.26<br>* BTYPE váltás esetén adatok gyűjtése a BEVALLI és BEVALLSZ<br>* átállításához. |
| 1676 | src/#zak#evvalt_corr.prog.abap | *   ALV listára töltjük: |
| 1677 | src/#zak#evvalt_corr.prog.abap | *  Megnézzük mi lenne a megfelelő ABEV |
| 1678 | src/#zak#evvalt_corr.prog.abap | *          Ellenőrizzük, hogy le van e zárva |
| 1679 | src/#zak#evvalt_corr.prog.abap | *       IDŐSZAK lezárt nem lehet módosítani |
| 1680 | src/#zak#evvalt_corr.prog.abap | *--S4HANA#01.<br>*       Egyébként módosítjuk |
| 1681 | src/#zak#evvalt_corr.prog.abap | *++BG 2007.04.26<br>*         BTYPE váltás |
| 1682 | src/#zak#evvalt_corr.prog.abap | *++BG 2007.04.26<br>* BEVALLI és BEVALLSZ módosítása<br>*++2012.01.31 BG |
| 1683 | src/#zak#evvalt_corr.prog.abap | *   BEVALLI aktualizálás |
| 1684 | src/#zak#evvalt_corr.prog.abap | *   BEVALLSZ aktualizálás |
| 1685 | src/#zak#evvalt_corr.prog.abap | *   BEVALLI törlés |
| 1686 | src/#zak#evvalt_corr.prog.abap | *   BEVALLSZ törlés |
| 1687 | src/#zak#evvalt_corr.prog.abap | *--S4HANA#01.<br>*   & vállalat & időszak nem módosítható mert lezárásra került! |
| 1688 | src/#zak#evvalt_corr.prog.abap | * Konvertált tételek adatbázisban módosítva! |
| 1689 | src/#zak#evvalt_corr.prog.abap | * Mezőkatalógus összeállítása |
| 1690 | src/#zak#evvalt_corr.prog.abap | * Kilépés |
| 1691 | src/#zak#evvalt_corr.prog.abap | *ALV lista init |
| 1692 | src/#zak#evvalt_corr.prog.abap | *ALV lista |
| 1693 | src/#zak#evvalt_corr.prog.screen_9000.abap | nincs emberi komment blokk |
| 1694 | src/#zak#functions.fugr.#zak#abev_contact.abap | * Hónap ellenőrzése |
| 1695 | src/#zak#functions.fugr.#zak#abev_contact.abap | *   Hónap megadás hiba! (&) |
| 1696 | src/#zak#functions.fugr.#zak#abev_contact.abap | * ABEV azonosító ellenőrzése |
| 1697 | src/#zak#functions.fugr.#zak#abev_contact.abap | *   & bevallás & ABEV azonosító nem létezik! |
| 1698 | src/#zak#functions.fugr.#zak#abev_contact.abap | * Nincs adat |
| 1699 | src/#zak#functions.fugr.#zak#abev_contact.abap | * Feltöltjük a bevallás típusokat! |
| 1700 | src/#zak#functions.fugr.#zak#abev_contact.abap | * Konverzió meghatározása |
| 1701 | src/#zak#functions.fugr.#zak#abev_contact.abap | *++BG 2008.12.11<br>* ha nem talál megnézzük visszafele is |
| 1702 | src/#zak#functions.fugr.#zak#abev_contact.abap | * Konverzió meghatározása |
| 1703 | src/#zak#functions.fugr.#zak#abev_contact.abap | *     Ha így sincs rekord, akkor nem változott az ABEV |
| 1704 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Ha valamelyik INPUT adat hiányzik. |
| 1705 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Adatok átvétele |
| 1706 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Adatok konvertálása: |
| 1707 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Pontos érték meghatározása |
| 1708 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Intervallum értékek<br>*++BG 2009.11.26<br>*  LW_DATA-LWBAS_LOW  = LWBAS_EXACT - ( LINTER / 2 + 1 ).<br>*  LW_DATA-LWBAS_HIGH = LWBAS_EXACT + ( LINTER / 2 + 1 ). |
| 1709 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Pontos érték kerekítése ha kell |
| 1710 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Értékek átadása EXPORT: |
| 1711 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Alsó határ: |
| 1712 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Felső határ: |
| 1713 | src/#zak#functions.fugr.#zak#afa_alap_verify.abap | * Ha nincs benne van az intervallumban: |
| 1714 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | * Ellenőrizzük az aktuális adatokban |
| 1715 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Adat az adatbázisban van |
| 1716 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | * Egyéb művelet kulcsok |
| 1717 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>* Meghatározzuk a rögzítés időpontját:<br>*++S4HANA#01. |
| 1718 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--2165 #01.<br>*++1865 #13.<br>* M01 lap érvényességének meghatározása: |
| 1719 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 2017.09.19<br>*++1665 #07.<br>*     Ha magánszemély CPD szállító vagy vevő nem kell feldolgozni: |
| 1720 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1665 #07.<br>*--1365 #11.<br>*   Feldolgozás ellenőrzése |
| 1721 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>*++2065 #12.<br>*  Halasztott ÁFA kezeléshez b izonylatok beolvasása |
| 1722 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>*     Adó nem vonható le összesítés |
| 1723 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--2065 #12.<br>*  Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 1724 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *         Van ilyen üríteni kell a xBAS mezők értékét |
| 1725 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1665 #13.<br>*   Meghatározzuk a BTYPE-ot: |
| 1726 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1365 #12.<br>*++2017.05.10<br>*   Összeg konvertálása |
| 1727 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--2017.05.10<br>*   Fordított művletkulcs ellenőrzés<br>*++1865 #13.<br>*      REFRESH LR_FMUV.<br>*++S4HANA#01.<br>*      REFRESH: lr_fmuv, lr_fmuv_m01. |
| 1728 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *++1365 #19.<br>*++1865 #13.<br>*   M01 lap kitöltésének vizsgálata |
| 1729 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1365 #19.<br>*++1665 #14.<br>*   Nem releváns bizonylatfajták ellenőrzése |
| 1730 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *    bizonylatfajta ellenőrzés |
| 1731 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1665 #14.<br>*++1465 #18.<br>*   Nem releváns szállító vevő kódok kezelése |
| 1732 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 #26.<br>*   Adatok feltöltése |
| 1733 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1365 #9.<br>*   Meghatározzuk a bizonylat típusát |
| 1734 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   SD számla |
| 1735 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 #05.<br>*       Ha üres akkor korrekció |
| 1736 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Számla kelt: |
| 1737 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *       Számlázás: fejadatok szelekció |
| 1738 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Sztornó kezelése<br>*     Nem kell a hónabon beüli sztornó tétel |
| 1739 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *       Előzmény bizonylat dátuma |
| 1740 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *         Ebben az esetben az előzmény sem kell |
| 1741 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 2017.06.13<br>*   MM számla |
| 1742 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Ha üres akkor korrekció |
| 1743 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Számla kelt: |
| 1744 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Sztornó kezelése<br>*     Nem kell a hónabon beüli sztornó tétel |
| 1745 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *         Ebben az esetben az előzmény sem kell |
| 1746 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   FI számla<br>*++1365 #9.<br>*    ELSEIF L_AWTYP EQ 'BKPF'. |
| 1747 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1365 #9.<br>*++1365 #20.<br>*     Halasztott ÁFA kezelése |
| 1748 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1365 #20.<br>*     Ha üres akkor korrekció |
| 1749 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>*     Számla típus |
| 1750 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Sztornó kezelése<br>*     Nem kell a hónabon beüli sztornó tétel |
| 1751 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *        Előzmény bizonylat dátuma<br>*++S4HANA#01. |
| 1752 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *         Ebben az esetben az előzmény sem kell |
| 1753 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 2017.06.13<br>*   Egyéb |
| 1754 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 2017.06.13<br>*   Ha nem sikerül meghatározni a számla azonosítót |
| 1755 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1665 #08.<br>*++1365 #23.<br>*     Ha nincs közös számlaazonosító, akkor E-s tételként kezeljük |
| 1756 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *++1365 #10.<br>*   Telefon ÁFA kódnál szükséges a bizonylatokból a beállító tábla<br>*   szerinti másik adókód összege is! |
| 1757 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Összeállítjuk a szükséges ÁFA kódokat!<br>*++S4HANA#01.<br>*          REFRESH: lr_mwskz, li_bset. |
| 1758 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>*     Van rekord, összesíteni kell: |
| 1759 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *         Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 1760 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *++2265 #10.<br>*             Ellenőrizzük, hogy kell e a tételt összesíteni |
| 1761 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *               Művelet kulcs nélkül is ellenőrizzük |
| 1762 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--2265 #10.<br>*         Feltöltjük egy üres munkaterületre, hogy tudjuk használni<br>*         az előjelkezelés rutint! |
| 1763 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Egyéb művelet kulcsok kezelése |
| 1764 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>*     Van rekord, összesíteni kell: |
| 1765 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *         Ha LWBAS üres, akkor használjuk a HWBAS,HWSTE-t. |
| 1766 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *++2265 #10.<br>*             Ellenőrizzük, hogy kell e a tételt összesíteni |
| 1767 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *               Művelet kulcs nélkül is ellenőrizzük |
| 1768 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--2265 #10.<br>*         Feltöltjük egy üres munkaterületre, hogy tudjuk használni<br>*         az előjelkezelés rutint! |
| 1769 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1365 #15.<br>*   Számla rekord<br>*++2165 #08. |
| 1770 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--2165 #08.<br>*   Ha a típus E és 2013.01.01 előtti, akkor nem kell a rekord |
| 1771 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Analitika tétel |
| 1772 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *++1665 #07.<br>*     Ha CPD-s akkor kell a NAME1 a FIELD_C-be |
| 1773 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Bizonylatszám mentése |
| 1774 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1765 2017.09.19<br>*++1365 #11.<br>* Meghatározzuk, hogy az eredeti tétel kellett e |
| 1775 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *     Keressük az adatbázisban is |
| 1776 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.s<br>*       Olyan korrekciós, aminek még nincs előzménye, ami nem kell |
| 1777 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--1665 #08.<br>*++1965 #02.<br>*M01 lap érvényesség vizsgálata |
| 1778 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Előleg generálás eljárás kezdő időpontja: |
| 1779 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Dátum figyelés < |
| 1780 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>* Előleg sorok feldolgozása<br>*++S4HANA#01. |
| 1781 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>* Referencia rekordok keresése: |
| 1782 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *--S4HANA#01.<br>*     HIBA a referencia bizonylat meghatározásánál |
| 1783 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Generált rekord flag |
| 1784 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Index törlés |
| 1785 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Tétel beállítása |
| 1786 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   A generált rekord stádiuma 'KÜL' |
| 1787 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | * Előleg stádium jelölése végszámla |
| 1788 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | *   Analitika bővítése |
| 1789 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | * AFA SZLA bővítése |
| 1790 | src/#zak#functions.fugr.#zak#afa_ness_szla_exit.abap | * ANALITIKA bővítése |
| 1791 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *--0965 2009.02.10 BG<br>* Egyéb adatok meghatározása<br>* Itt határozzuk meg az adatbázis szelekción kívüli rekordokat<br>* Beolvassuk az előleg kezeléshez szükséges adatbázis táblát |
| 1792 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | * EVA szállítók figyelembe vétele |
| 1793 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     Adószám ellenőrzés |
| 1794 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     Ha EVA-s az adószám sorok beszúrása |
| 1795 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *       Ellenőrizzük, hogy feldolgoztuk-e már |
| 1796 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *++0965 2009.02.10 BG<br>*       BTYPE meghatározása |
| 1797 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *  Előleges tételek kezelése |
| 1798 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *   Van rekord meg kell vizsgálni az átvezetést |
| 1799 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     KOART vizsgálat |
| 1800 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     UMSKZ vizsgálat |
| 1801 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     BSCHL vizsgálat |
| 1802 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     AUGDT vizsgálat |
| 1803 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *          Iniciális |
| 1804 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *          Kisebb mint a bevallás időszak |
| 1805 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *     Ha kell másolni |
| 1806 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | *       Abev azonosító csere. |
| 1807 | src/#zak#functions.fugr.#zak#afa_sap_sel_exit.abap | * Gyűjtött rekordok beszúrása |
| 1808 | src/#zak#functions.fugr.#zak#afa_xml_download.abap | * Bevallások beállításának beolvasása |
| 1809 | src/#zak#functions.fugr.#zak#afa_xml_download.abap | * Vállalat név meghatározása<br>*++1565 #01. 2015.02.09 |
| 1810 | src/#zak#functions.fugr.#zak#afa_xml_download.abap | * Adószám meghatározása |
| 1811 | src/#zak#functions.fugr.#zak#afa_xml_download.abap | * IDŐSZAK -tól |
| 1812 | src/#zak#functions.fugr.#zak#afa_xml_download.abap | * Nyomtatvány azonosítók:<br>*++2065 #09.<br>*  CONCATENATE LW_BEVALLO_ALV-BTYPE 'A' INTO NYOMTA.<br>*  CONCATENATE LW_BEVALLO_ALV-BTYPE 'M' INTO NYOMTM. |
| 1813 | src/#zak#functions.fugr.#zak#afa_xml_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 1814 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | * Ha bármelyik paraméter üres hiba |
| 1815 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Hiányzó import paraméter arányosítás könyveléséhez! |
| 1816 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | * Első és utolsó nap meghatározása |
| 1817 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Hiba a hónap utolsó napjának meghatározásánál! (&) |
| 1818 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Hiányzó beállítás ÁFA arány könyveléséhez! |
| 1819 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | * Ha december, akkor a következő időszak meghatározása |
| 1820 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Bizonylat azonosító |
| 1821 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Bizonylat/Tételszám |
| 1822 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Bizonylatdátum |
| 1823 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Könyvelési dátum |
| 1824 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Periódus |
| 1825 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Pénznem |
| 1826 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Fej és tétel szöveg: |
| 1827 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   T/K kód |
| 1828 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   sorok mentése |
| 1829 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *++1065 2010.02.04 BG<br>* Könyvelés fájl forgatás (költséghely, rendelés, PC) |
| 1830 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | * Ha van adat letöltés |
| 1831 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *   Excel fájl készítése |
| 1832 | src/#zak#functions.fugr.#zak#afar_book_excel.abap | *     Hiba a & fájl letöltésénél. |
| 1833 | src/#zak#functions.fugr.#zak#analitika_conversion.abap | * Bevallás utolsó napjának meghatározása |
| 1834 | src/#zak#functions.fugr.#zak#analitika_conversion.abap | * Érvényes az utolsó napon a bevallás típus?<br>* Ha nem -> konverzió szükséges |
| 1835 | src/#zak#functions.fugr.#zak#analitika_conversion.abap | * Konvertálni kell, ha a típus különbözik |
| 1836 | src/#zak#functions.fugr.#zak#atv_book_excel.abap | * Adatkonzisztencia ellenőrzése |
| 1837 | src/#zak#functions.fugr.#zak#atv_book_excel.abap | * Nyomtatvány adatok beolvasása |
| 1838 | src/#zak#functions.fugr.#zak#atv_book_excel.abap | * T_BEVALLO értelmezése, konvertálása > /ZAK/ATVEZ_SOR,<br>*                                  majd /ZAK/ATVEZ_EXCEL formátumba<br>*++FI 20070213<br>* Az új Excel struktúrát vissza kellett állítani, mert itt (szállító) könyvelésnél a régi kell |
| 1839 | src/#zak#functions.fugr.#zak#atv_post_adonsza.abap | * Adatkonzisztencia ellenőrzése |
| 1840 | src/#zak#functions.fugr.#zak#atv_post_adonsza.abap | * Nyomtatvány adatok beolvasása |
| 1841 | src/#zak#functions.fugr.#zak#atv_post_adonsza.abap | * T_BEVALLO értelmezése, konvertálása > /ZAK/ATVEZ_SOR |
| 1842 | src/#zak#functions.fugr.#zak#atv_post_adonsza.abap | * Adófolyószámla aktualizálása |
| 1843 | src/#zak#functions.fugr.#zak#btype_conversion.abap | * Érvényességek ellenőrzése |
| 1844 | src/#zak#functions.fugr.#zak#btype_conversion.abap | * Bevallb beolvasása |
| 1845 | src/#zak#functions.fugr.#zak#btype_conversion.abap | * Sorok feldolgozása |
| 1846 | src/#zak#functions.fugr.#zak#btype_conversion.abap | * Új ABEV kód megnevezése |
| 1847 | src/#zak#functions.fugr.#zak#btype_conversion.abap | * Új BEVALLB adatok |
| 1848 | src/#zak#functions.fugr.#zak#calc_potlek.abap | * létrehozok egy belső táblát, ami csak a dátumokhoz<br>* tartozó pótlék százalékokat tartalmazza! |
| 1849 | src/#zak#functions.fugr.#zak#calc_potlek.abap | * pótlék számítása!! |
| 1850 | src/#zak#functions.fugr.#zak#calc_potlek.abap | * dátumhoz tartozó kamat meghatározása<br>* a kezdő tátumot megelőző |
| 1851 | src/#zak#functions.fugr.#zak#calc_potlek.abap | *---------------------------------------------------------------------*<br>* pótlék számítás                                                     *<br>* Formel:                                                             *<br>*                          kamat                                      *<br>*         zins   = --------------------  / 100 * összeg * napszám     *<br>*                        év napszám                                   *<br>* év napszám  - napszám                                               *<br>*            360 - im Bankkalender und im franz. Kalender             *<br>*            365 - im gregorianischen Kalender, sofern kein Schaltjahr*<br>*            366 - im gregorianischen Kalender, sofern ein Schaltjahr *<br>* INTEREST_RATE_COMPUTE ????<br>*---------------------------------------------------------------------* |
| 1852 | src/#zak#functions.fugr.#zak#calc_potlek.abap | * ++ CST 2006.06.04: 1,5 szörös kamat érték. |
| 1853 | src/#zak#functions.fugr.#zak#check_adoazon.abap | * Adóazonosító |
| 1854 | src/#zak#functions.fugr.#zak#check_adoazon.abap | * Születési dátum |
| 1855 | src/#zak#functions.fugr.#zak#check_adoazon.abap | * Adatok meghatározása |
| 1856 | src/#zak#functions.fugr.#zak#check_adoazon.abap | * Adóazonosító ellenőrzés |
| 1857 | src/#zak#functions.fugr.#zak#check_adoazon.abap | * Hiba feltöltése |
| 1858 | src/#zak#functions.fugr.#zak#conv_adoazon.abap | nincs emberi komment blokk |
| 1859 | src/#zak#functions.fugr.#zak#conv_date_user_2_internal.abap | * Hónap |
| 1860 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * Formátum ellenõrzés |
| 1861 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * Tizedes vesszõ és pont lecserélése #-ra |
| 1862 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * Van-e benne több tizedes pont? |
| 1863 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * A # átalakítása tizedes ponttá |
| 1864 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * Szóközök kiszedése |
| 1865 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | *<br>* Összeg kiszámolása |
| 1866 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * Osztó meghatározása |
| 1867 | src/#zak#functions.fugr.#zak#convert_string_to_packed.abap | * Pakolt összeg kiszámítása |
| 1868 | src/#zak#functions.fugr.#zak#gen_afa_szla.abap | * Eredeti sorok meghatározása |
| 1869 | src/#zak#functions.fugr.#zak#gen_afa_szla.abap | * Korrekciós sorok meghatározása (végrehajtjuk kétszer, hogy ha a módosítások<br>* nem sorrendben következnek akkor is megtaláljuk) |
| 1870 | src/#zak#functions.fugr.#zak#gen_afa_szla.abap | * Megpróbáljuk az üreseket keresni az adatbázisban is |
| 1871 | src/#zak#functions.fugr.#zak#gen_afa_szla.abap | *   Keressük a 4 hosszú NYLAPAZON-t is |
| 1872 | src/#zak#functions.fugr.#zak#gen_afa_szla.abap | * Ha még mindig marad üres az hiba: |
| 1873 | src/#zak#functions.fugr.#zak#get_afcs.abap | nincs emberi komment blokk |
| 1874 | src/#zak#functions.fugr.#zak#get_btypart_from_btype.abap | *   Hiányzó import paraméter bevallás fajta meghatározásnál!(Váll.vagy t |
| 1875 | src/#zak#functions.fugr.#zak#get_btype_from_btypart.abap | *--PTGSZLAA #02. 2014.03.05<br>* Hónap ellenőrzése |
| 1876 | src/#zak#functions.fugr.#zak#get_btype_from_btypart.abap | *   Hónap megadás hiba! (&) |
| 1877 | src/#zak#functions.fugr.#zak#get_btype_from_btypart.abap | *Időpont meghatározása |
| 1878 | src/#zak#functions.fugr.#zak#get_btype_from_btypart.abap | * Hónap utolsó napjának meghatározása |
| 1879 | src/#zak#functions.fugr.#zak#get_btype_from_btypart.abap | *   Bevallás típus meghatározás hiba! |
| 1880 | src/#zak#functions.fugr.#zak#get_btype_from_btypart.abap | *   Bevallás típus meghatározás hiba! |
| 1881 | src/#zak#functions.fugr.#zak#get_btype_from_btypart_m.abap | * Hónap ellenőrzése |
| 1882 | src/#zak#functions.fugr.#zak#get_btype_from_btypart_m.abap | *   Hónap megadás hiba! (&) |
| 1883 | src/#zak#functions.fugr.#zak#get_btype_from_btypart_m.abap | *Időpont meghatározása |
| 1884 | src/#zak#functions.fugr.#zak#get_btype_from_btypart_m.abap | * Hónap utolsó napjának meghatározása |
| 1885 | src/#zak#functions.fugr.#zak#get_btype_from_btypart_m.abap | *   Bevallás típus meghatározás hiba! |
| 1886 | src/#zak#functions.fugr.#zak#get_btype_from_btypart_m.abap | * Nincs év-hónap megadva |
| 1887 | src/#zak#functions.fugr.#zak#get_btypes_from_btypart.abap | *Összes bevallás típus meghatározása |
| 1888 | src/#zak#functions.fugr.#zak#get_btypes_from_btypart.abap | *   Bevallás típus meghatározás hiba! |
| 1889 | src/#zak#functions.fugr.#zak#get_bukrs_from_bukcs.abap | nincs emberi komment blokk |
| 1890 | src/#zak#functions.fugr.#zak#get_fi_szamlasz.abap | *++1465 #03.<br>* Sztornó adatok |
| 1891 | src/#zak#functions.fugr.#zak#get_fi_szamlasz.abap | * Meghatározzuk az eredeti bizonylatot |
| 1892 | src/#zak#functions.fugr.#zak#get_fi_szamlasz.abap | *++1465 #03.<br>* Elmentjük az adatokat a sztornó kezeléshez |
| 1893 | src/#zak#functions.fugr.#zak#get_fi_szamlasz.abap | * Ha üres akkor önmaga lesz az eredeti |
| 1894 | src/#zak#functions.fugr.#zak#get_fi_szamlasz.abap | *++1465 #03.<br>* Sztornó meghatározása |
| 1895 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * Sztornó adatok |
| 1896 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * Range meghatározás tételekhez |
| 1897 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * 2 Számlabeérkezés és  'S' normál szállítói számla |
| 1898 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * 2 Számlabeérkezés és  'H' Jóváíró számla<br>* 3 Utólagos terhelés  és 'S'  Utólagos terhelés<br>* 3 Utólagos terhelés  és 'H'  Utólagos jóváírás |
| 1899 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *Meghatározzuk a referencia kulcsot |
| 1900 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * Beszerzési bizonylat gyűjtése |
| 1901 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *--2465 #02.<br>*++1365 #8.<br>* Ha nincs akkor XBLNR lesz a számlaszám és eredetinek tekintjük. |
| 1902 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * Sztornó meghatározása |
| 1903 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *--1865 #09.<br>* Feldolgozás tételenként |
| 1904 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *     Csak ha megfelelő típus |
| 1905 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *     Normál számla |
| 1906 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *++2065 #14.<br>*     Sztornó számla |
| 1907 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * Meghatározzuk a kimeneti adatokat: |
| 1908 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *++1665 #05.<br>* Fuvarszámlák miatt ha nem azonos a szállító, akkor nem korrekció: |
| 1909 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | * Sztornó meghatározása |
| 1910 | src/#zak#functions.fugr.#zak#get_mm_szamlasz.abap | *--2465 #05.<br>* Számlaszámok meghatározása |
| 1911 | src/#zak#functions.fugr.#zak#get_re_szamlasz.abap | * Meghatározzuk az eredeti bizonylatot |
| 1912 | src/#zak#functions.fugr.#zak#get_re_szamlasz.abap | *   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY) |
| 1913 | src/#zak#functions.fugr.#zak#get_re_szamlasz.abap | * Sztornó vagy sztornózott bizonylat |
| 1914 | src/#zak#functions.fugr.#zak#get_re_szamlasz.abap | *   Sztornózó bizonylat |
| 1915 | src/#zak#functions.fugr.#zak#get_re_szamlasz.abap | *  Helyesbített bizonylat |
| 1916 | src/#zak#functions.fugr.#zak#get_re_szamlasz.abap | *     Eredeti számlaszám meghatározása |
| 1917 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Rangek definiálása |
| 1918 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Normál bizonylattípus |
| 1919 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Normál számla |
| 1920 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Könyvelés |
| 1921 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *Meghatározzuk a referencia kulcsot |
| 1922 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *--1665 #08.<br>*   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY) |
| 1923 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Hierechia TOP meghatáozása |
| 1924 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *--1665 #08.<br>*   Nem lehet meghatározni vagy hibás referenciakulcs! (AWKEY) |
| 1925 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * ha nem volt benne egyáltalán SD Rendelés típusú bizonylat,<br>* megnézzük, hogy MM Megrendeléssel indult-e |
| 1926 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *++1465 #03.<br>*Sztornó kezelés vizsgálat |
| 1927 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *     Ez a rendelés sztornózva ez lesz az eredeti |
| 1928 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *     Ez a sztornó bizonylat, megkeressük az eredetit |
| 1929 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | "számla                                                                                "$smart: #607 |
| 1930 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap |           "és az előzménye külső                          "$smart: #607<br>*--S4HANA#01. |
| 1931 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | *   Hiba a & követõ bizonylatok meghatározásánál! |
| 1932 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Teljes bizonylatáramlás felépítése<br>*  M_SET_COMWA LW_VBFA_TAB-VBELN LW_VBFA_TAB-POSNN.<br>*  M_SET_COMWA L_VBELN L_POSNN.<br>*  M_CALL_FLOW_INFORMATION LI_VBFA_TAB_ALL L_SUBRC.<br>*--1365 #7.<br>* Hierarchia feldolgozása |
| 1933 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Meghatározzuk a kimeneti adatokat: |
| 1934 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Ha nics találat de a csoportban csak üres SZAMLASZA-k<br>* vannak, akkor a önmaga lesz |
| 1935 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Van rekord SZAMLASZA-val tehát hiba |
| 1936 | src/#zak#functions.fugr.#zak#get_sd_szamlasz.abap | * Előzmény bizonylat meghatározása |
| 1937 | src/#zak#functions.fugr.#zak#get_segm_for_bukrs.abap | nincs emberi komment blokk |
| 1938 | src/#zak#functions.fugr.#zak#kata_exit.abap | * Dialógus futás biztosításhoz |
| 1939 | src/#zak#functions.fugr.#zak#kata_exit.abap | * Bevallás utolsó napjának meghatározás |
| 1940 | src/#zak#functions.fugr.#zak#kata_exit.abap | * Bevallás általános adatai |
| 1941 | src/#zak#functions.fugr.#zak#kata_exit.abap | *++2108 #19.<br>* Meg kell ismételni a '000'-ás időszak adatait: |
| 1942 | src/#zak#functions.fugr.#zak#kata_exit.abap | * KATA adatok kalkulálás |
| 1943 | src/#zak#functions.fugr.#zak#kata_file_download.abap | * Bevallások beállításának beolvasása |
| 1944 | src/#zak#functions.fugr.#zak#kata_file_download.abap | * Vállalat név meghatározása |
| 1945 | src/#zak#functions.fugr.#zak#kata_file_download.abap | * Adószám meghatározása |
| 1946 | src/#zak#functions.fugr.#zak#kata_file_download.abap | * Nyomtatvány azonosítók: |
| 1947 | src/#zak#functions.fugr.#zak#kata_file_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 1948 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Tábla mentése |
| 1949 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Beolvassuk az első sort (parméterek miatt). |
| 1950 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Beállítások beolvasása |
| 1951 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *   Fájl szerkezet nem határozható meg & bevallás típushoz! |
| 1952 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Adatok rendezése |
| 1953 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * T001Z szelektálás kifizető adóazonosító száma meghatározásához |
| 1954 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *   Kifizető azonosító meghatározás hiba & vállalatnál! (T001Z tábla) |
| 1955 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Paraméter átalakítása |
| 1956 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Ha van adóazonosító |
| 1957 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Fájl eleje meghatározás 1-17<br>* 1 - 5  5 alfanum Rekordjel, fix adat: 05K33, kitöltése kötelező<br>* 6 - 6  1 alfa üres (blank)<br>* 7 - 17 11 alfanum A kifizető adóazonosító száma, kitöltése kötelező,<br>*                   balra igazított, jobbról blank feltöltéssel |
| 1958 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *     Végig olvassuk a  mezőszerkezetet |
| 1959 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *       Olvassuk adóazonosítóval |
| 1960 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *       Ha nem találunk, akkor megnézzük adószám nélkül |
| 1961 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *       Ha van érték, akkor feltöltés |
| 1962 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *       Nincs érték, kezdő pozíció beállítás |
| 1963 | src/#zak#functions.fugr.#zak#kont_file_download.abap | *--2010.08.17 Unicode javítás Balázs Gábor (Ness) |
| 1964 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Fájl név módosítás |
| 1965 | src/#zak#functions.fugr.#zak#kont_file_download.abap | * Fájl név első 8 karaktere |
| 1966 | src/#zak#functions.fugr.#zak#kulf_file_download.abap | * Bevallások beállításának beolvasása |
| 1967 | src/#zak#functions.fugr.#zak#kulf_file_download.abap | * Vállalat név meghatározása |
| 1968 | src/#zak#functions.fugr.#zak#kulf_file_download.abap | * Adószám meghatározása<br>*++19K79 #01.<br>*  ABEV = '0A0001C002'. "Adószám ABEV 11K79-ben |
| 1969 | src/#zak#functions.fugr.#zak#kulf_file_download.abap | * Nyomtatvány azonosítók:<br>*++2208 #01. |
| 1970 | src/#zak#functions.fugr.#zak#kulf_file_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 1971 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * SZJA Számított mezők |
| 1972 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 1973 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások |
| 1974 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2007.06.22<br>*        0-ás mezők kezelése |
| 1975 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 1976 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások |
| 1977 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2007.06.22<br>*        0-ás mezők kezelése |
| 1978 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008/01/14<br>*       START-kártyás számítások<br>*       hamarabb kell kiszámítani az önrevízióhoz mert az már<br>*       használja a mezőket (pld: A0EC0156CA), de csak az<br>*       aktuális feladás kell |
| 1979 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 1980 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások |
| 1981 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2007.06.22<br>*        0-ás mezők kezelése |
| 1982 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008.03.06<br>*        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 1983 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 1984 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 1985 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 1986 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 1987 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Újra kell számoltatni a speciális mezők miatt. |
| 1988 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások |
| 1989 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 1990 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 1991 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 1992 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 1993 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 1994 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 1995 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Újra kell számoltatni a speciális mezők miatt. |
| 1996 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások |
| 1997 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 1998 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 1999 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2000 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2001 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2002 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2003 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2004 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2005 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2006 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2007 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2008 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2009 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2010 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *<br>*<br>*        Normál számítások "A" |
| 2011 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2012 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2013 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2014 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2015 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2016 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2017 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2018 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2019 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2020 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2021 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2022 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2023 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2024 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2025 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2026 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2027 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2028 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2029 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1408 #02. 2014.03.05 BG<br>*        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2030 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2031 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2032 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2033 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **--1408 #02. 2014.03.05 BG<br>*        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2034 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *<br>*        Normál számítások "A" |
| 2035 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2036 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2037 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2038 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2039 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2040 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2041 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2042 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2043 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2044 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2045 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2046 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2047 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2048 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2049 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2050 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2051 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2052 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2053 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2054 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2055 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2056 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2057 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2058 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2059 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2060 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2061 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2062 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2063 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2064 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2065 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2066 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2067 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2068 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2069 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2070 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2071 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2072 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2073 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2074 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2075 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2076 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2077 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2078 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2079 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Kell egy összesítés, mivel van olyan speciális mező<br>*          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2080 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2081 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2082 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2083 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2084 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2085 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2086 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2108 #06.<br>*          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2087 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **          Kell egy összesítés, mivel van olyan speciális mező<br>**          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2088 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2108 #06.<br>*        Önrevízió |
| 2089 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2108 #06.<br>*        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2090 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2091 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2092 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2093 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót<br>*++2208 #04. |
| 2094 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2095 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **          Kell egy összesítés, mivel van olyan speciális mező<br>**          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2096 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2097 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2208 #04.<br>*        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2098 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2099 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2100 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2101 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2102 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2103 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **          Kell egy összesítés, mivel van olyan speciális mező<br>**          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2104 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2105 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2106 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2107 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2108 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2109 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2110 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2111 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **          Kell egy összesítés, mivel van olyan speciális mező<br>**          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2112 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2113 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2114 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2115 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2116 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Kell egy speciális összegzés ami az M-s ABEV-eket<br>*        összegzi fel technikai ABEV-ekre |
| 2117 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevíziónál a normál mezőben meghatározzuk a teljes összeget<br>*        majd az önrevízió mezőkben az önrevízióra vonatkozót |
| 2118 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2119 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **          Kell egy összesítés, mivel van olyan speciális mező<br>**          amit összesíteni kell!!!! CSAK 1208-nál jelentkezett eddig |
| 2120 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Önrevízió |
| 2121 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Speciális számítások (START kártya + EG-biz + Nyugdij) |
| 2122 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Normál számítások "A" |
| 2123 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        0-ás mezők kezelése |
| 2124 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ÁFA Számított mezők |
| 2125 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                         "Előző időszak áthozott |
| 2126 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |          "Köv.idsz. átviendő<br>*--2009.02.02 BG |
| 2127 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                         "Előző időszak áthozott |
| 2128 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |          "Köv.idsz. átviendő |
| 2129 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                         "Előző időszak áthozott |
| 2130 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |          "Köv.idsz. átviendő |
| 2131 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Társasház Számított mezők |
| 2132 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Üdülési csekk Számított mezők |
| 2133 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Átvezetés Számított mezők |
| 2134 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++0004 BG 2007.04.04<br>* Összesítő jelentés |
| 2135 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ÁFA Számított mezők |
| 2136 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                         "Előző időszak áthozott |
| 2137 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |          "Köv.idsz. átviendő<br>*--2009.02.02 BG |
| 2138 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                         "Előző időszak áthozott |
| 2139 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |          "Köv.idsz. átviendő |
| 2140 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                         "Előző időszak áthozott |
| 2141 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |          "Köv.idsz. átviendő |
| 2142 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1265 2012.01.31 BG<br>*++1365 2013.01.10 Balázs Gábor (Ness) |
| 2143 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1665 #06.<br>*--1365 2013.01.10 Balázs Gábor (Ness)<br>*++1465 #01. 2013.02.04 Balázs Gábor (Ness) |
| 2144 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1665 #06.<br>*--1465 #01. 2013.02.04 Balázs Gábor (Ness)<br>*++1765 #28.<br>*        0-ás mezők kezelése |
| 2145 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Összesítő jelentés |
| 2146 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--13A60 2013.01.28 BG<br>*++14A60 #01. 2014.02.04 Balázs Gábor (Ness) |
| 2147 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--14A60 #01. 2014.02.04 Balázs Gábor (Ness)<br>*++15A60 #01. 2015.01.26 |
| 2148 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 2149 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2150 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2151 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC028A = időszak-tól első nap<br>* Havi |
| 2152 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2153 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC029A = időszak-ig utolsó nap |
| 2154 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adózók száma = Adószámok |
| 2155 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Dinamikus lapszám |
| 2156 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 2157 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2158 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2159 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC028A = időszak-tól első nap<br>* Havi |
| 2160 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2161 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC029A = időszak-ig utolsó nap |
| 2162 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adózók száma = Adószámok |
| 2163 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Dinamikus lapszám |
| 2164 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Meg kell határozni az adószám alapján a M0KB011A mezőt |
| 2165 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 2166 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2167 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2168 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC028A = időszak-tól első nap<br>* Havi |
| 2169 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2170 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC029A = időszak-ig utolsó nap |
| 2171 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adózók száma = Adószámok |
| 2172 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Speciális számítások<br>* START-kártya kötelzettség<br>* Az érték meghatározást normál időszaknál a FIELD_N<br>* önrevízióknál a FIELD_ON mezőben kell elvégezni. |
| 2173 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők |
| 2174 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ******************************************************** CSAK ÁFA normál<br>* a periódus fajtája határozza meg az értéket! havi,éves, stb<br>* havi 6503 = 'X'<br>* negyed 6504 = 'X'<br>* éves 6505 = 'X'<br>* CSAK ÁFA önrevizió<br>*  6511 = 'X' |
| 2175 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * az abev SZÁMÍTÁS UTÁN KELL LEFUTNIA<br>* (normál és önrevízió)<br>* a mostani bevallás elötti időszak figyelembe véve az időszakot<br>* , utolsó lezárt indexnél<br>* pl (havi): 005 revizió 06 hónapra --> megelőző 05 hónapot keresek az<br>* előző lezárt időszakra |
| 2176 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pl:negyedévesnél 03-->12 kell nézni<br>* a mostani 347 = a korábbi 357 |
| 2177 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani bevallást megelöző indexü ua időszakra eső bejegyzés ha<br>* önrevizó van<br>* a mostani 360 = a korábbi 347<br>* a mostani 361 = a korábbi 349<br>* a mostani 362 = a korábbi 351<br>* a mostani 363 = a korábbi 353<br>* a mostani 364 = a korábbi 355<br>* a mostani 365 = a korábbi 357 |
| 2178 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * corrr 2006.03.29<br>* EZ MINDRE IGAZ ha 349 < 0<br>* 351 = 0<br>* ha abs(353) > abs(349) akkor 355 = 0.<br>* ha abs(353) < abs(349) akkor 355 = abs(349) - abs(353).<br>* 357 = abs(349) - 355 |
| 2179 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2180 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2181 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 351  = 349<br>* ha 349 < 0 akkor 351 = 0 |
| 2182 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 6504<br>* N - Negyedéves |
| 2183 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * csak negyedévnél 6506 = '1' v '2' v '3' v '4' |
| 2184 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 6511<br>* csak önrevíziónál kell tölteni! |
| 2185 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 6509 = gjahr<br>* csak önrevíziónál kell tölteni! |
| 2186 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * csak havinál 6507 = monat |
| 2187 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2188 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig 5287 = időszak-ig  utolsó nap |
| 2189 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani 360 = az előző indexű 347 |
| 2190 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani 361 = az előző indexű 349 |
| 2191 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani 362 = az előző indexű 351 |
| 2192 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani 363 = az előző indexű 353 |
| 2193 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani 364 = az előző indexű 355 |
| 2194 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a mostani 365 = az előző indexű 357 |
| 2195 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 5271 és 5274 'X' ha a 355 nem üres |
| 2196 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 2197 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ***********************************************************-<br>* önellenörzési pótlék számítása 203 = 351 - 362 + 364 - 355 ha > 0<br>* 203 számítása<br>* ha 351 - 362 > 0 akkor ezt az értéket<br>* ha nem akkor a következő feltétel<br>* (357 - 365) < 0 akkor minusz a számolt érték<br>* (357 - 365) > 0 akkor 0<br>* 355 - 364 < 0 akkor minusz a számolt érték<br>* 355 - 364 > 0 akkor 0 |
| 2198 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ha 351 - 362 > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 2199 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * (357 - 365) < 0 akkor minusz a számolt érték |
| 2200 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 355 - 364 < 0 akkor minusz a számolt érték |
| 2201 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * önellenörzési pótlék  meghatározása<br>* ABEV 205 számítása a 203 alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 2202 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * időszak meghatározása |
| 2203 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 2204 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 2205 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 2206 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2012.01.06 BG<br>*             L_KAM_VEG = L_KAM_VEG - 15 .<br>*--2012.01.06 BG<br>* pótlék számítás |
| 2207 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.05.18<br>*              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 2208 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*      Ha van érték, korrigálni kell a 203-at. |
| 2209 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 2210 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2211 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Megpróbáljuk szétbontani a kötőjeleknél |
| 2212 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ Új algoritmus optimalizálás miatt BG 2006/05/23 |
| 2213 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Dialógus futás biztosításhoz |
| 2214 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Forrás ABEV jellemzői |
| 2215 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Eredeti sor beolvasása |
| 2216 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Eredeti sor beolvasása<br>*++ BG 2007.06.25<br>*      Lapszámonként kell értelmezni, mert egyébként az egynél nagyobb<br>*      lapra is átveszi az 001 lap értékét:<br>*-- BG 2007.06.25 |
| 2217 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *-- Új algoritmus optimalizálás miatt BG 2006/05/23 |
| 2218 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Dialógus futás biztosításhoz |
| 2219 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Forrás ABEV jellemzői |
| 2220 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Eredeti sor beolvasása |
| 2221 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Eredeti sor beolvasása |
| 2222 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Üres dátum mezők feltöltése |
| 2223 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *             A WL  nem kell (nem itt kell) |
| 2224 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A rendelésből feltételt csinál a szelekcióhoz |
| 2225 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A főkönyvből feltételt csinál a szelekcióhoz |
| 2226 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mindezzel elkészültünk mehet a táblába |
| 2227 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * nem számított mező |
| 2228 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--BG 2006/05/29<br>*++1008 2010.03.03 BG<br>*        Önrevíziós flag itt nem számít |
| 2229 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * speciális szabályok miatt!! |
| 2230 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--BG 2006/05/29<br>*++1008 2010.03.03 BG<br>*      Önrevíziós flag itt nem számít |
| 2231 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pénznem meghatározás |
| 2232 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * üres számított abev sorok beszúrása<br>******************************************* |
| 2233 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * az összegzendő ABEV kód jellemzői |
| 2234 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mező |
| 2235 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * nem számított mező |
| 2236 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Dialógus futás biztosításhoz |
| 2237 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2006/05/29<br>*          Ha a mező nem adószám köteles akkor azt kivesszük |
| 2238 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *            Lapszám mindig 0001 |
| 2239 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * összesített sorok beszúrása! |
| 2240 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Dialógus futás biztosításhoz |
| 2241 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * begin of insert kdenes 2006.04.20.<br>* visszaírom az ABEVAZ_DISP mezőt ! |
| 2242 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * end of insert 2006.04.20<br>*++1008 2010.03.03 BG<br>*        Önrevíziós flag itt nem számít |
| 2243 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1008 2010.02.04 BG<br>* a speciális szabályok szerinti összegzéshez kell a számolt adatokat<br>* feldolgozásra átadni! |
| 2244 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2011.12.08 BG (Ness)<br>*      Ha elérjük a '000'-át kilépés |
| 2245 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ** (normál és önrevízió)<br>** a mostani bevallás elötti időszak figyelembe véve az időszakot<br>** , utolsó lezárt indexnél<br>** pl (havi): 005 revizió 06 hónapra --> megelőző 05 hónapot keresek az<br>** előző lezárt időszakra<br>** pl:negyedévesnél 03-->12 kell nézni<br>** a mostani 347 = a korábbi 357 |
| 2246 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2009.02.02 BG<br>** ezt a sort kell módosítani! |
| 2247 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--BG 2008.04.16<br>* IDŐSZAK konverzió!<br>* E - Éves |
| 2248 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 2249 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Meg kell határozni a speciális időszak kezdetét |
| 2250 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * index<br>*++BG 2007.02.20<br>*Meghatározzuk az év szerint a BTYPE-t mert lehet, hogy nem az<br>*aktuálissal<br>*kell olvasnunk. |
| 2251 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Bevallás típus nem hatrározható meg!(Fajta: &, Év: &, Hónap: &) |
| 2252 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008.04.16<br>* Feltöltjük amire mindenképp futtatni kell |
| 2253 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Meghatározzuk van a vállalatforgatásban adat |
| 2254 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0965 2009.02.09 BG<br>*--0965 2009.02.09 BG<br>*++2011.12.08 BG<br>*        végiolvassuk, amíg nem találunk értéket max '000'-ig. |
| 2255 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2256 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2257 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Csak dialógus futtatásnál |
| 2258 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * SZJA bevallás adóazonosító lapszám meghatározáshoz |
| 2259 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a lapszámokat. |
| 2260 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Lapszámok visszaírása |
| 2261 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2262 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2263 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2264 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amiknek van adószáma de nem<br>*  jött rá semmi |
| 2265 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2266 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje H-val, ha a bevallása helyesbítésnek minősül |
| 2267 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A-12-000-e Ismételt önellenőrzés |
| 2268 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  A 12a Jelölje H-val, ha a bevallása helyesbítésnek minősül |
| 2269 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számítási algoritmus ÖNREVÍZIÓHOZ:<br>*  A-12-301-d Személyi jövedelemadó összesen (kötelezettség különbözete)<br>*  A0DC0301DA |
| 2270 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-303-d A 302. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(18%)(kötelezettség különböze<br>*A0DC0303DA |
| 2271 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-304-d A 302. sorból a biztosítottól levont nyugdíjjárulék (8,5%)<br>*(kötelezettség különböze<br>*A0DC0304DA |
| 2272 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-305-d A 302. sorból a biztosítottól levont nyugdíjjárulék (0,5%) *<br>*(kötelezettség különböze<br>*A0DC0305DA |
| 2273 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-306-d A 302. sorból a felszolg.díj után fizetett nyugdíjjárulék<br>*(15%) (kötelezettség különböze<br>*A0DC0306DA |
| 2274 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-308-d A 307. sorból a foglalkoztatót terhelő egészségbizt. járulék<br>* (11%) (kötelezettség különbö<br>*A0DC0308DA |
| 2275 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-309-d A 307. sorból a biztosítottól levont egészségbizt.-i járulék<br>* (11%) (kötelezettség különbö<br>*A0DC0309DA |
| 2276 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-310-d A 307. sorból a társas vállalkozást terhelő baleseti járulék<br>* (5%) (kötelezettség különbö<br>*A0DC0310DA |
| 2277 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-311-d Munkaadói járulék (kötelezettség különbözete)<br>*A0DC0311DA |
| 2278 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-312-d Munkavállalói járulék (kötelezettség különbözete)<br>*A0DC0312DA |
| 2279 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-313-d Vállalkozói járulék (kötelezettség különbözete)<br>*A0DC0313DA |
| 2280 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-314-d Százalékos mértékű egészségügyi hozzájárulás (kötelezettség<br>*különbözete)<br>*A0DC0314DA |
| 2281 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-315-d Tételes egészségügyi hozzájárulás (kötelezettség<br>*különbözete)<br>*A0DC0315DA |
| 2282 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-316-d A START-kártyával rendelkezőre vonatkozó 15%-os mérétkű köt.<br>* (kötelezettség különbözete)<br>*A0DC0316DA |
| 2283 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-317-d A START-kártyával rendelkezőre vonatkozó 25%-os mérétkű köt.<br>* (kötelezettség különbözete)<br>*A0DC0317DA |
| 2284 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-318-d A kifizetőt terhelő egyszerűsített köztehervis.-i hozzájár<br>*20% (kötelezettség különbözet<br>*A0DC0318DA |
| 2285 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-319-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*11% (kötelezettség különbözet<br>*A0DC0319DA |
| 2286 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-320-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*11,1%(kötelezettség különbözet<br>*A0DC0320DA |
| 2287 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-321-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*15%(kötelezettség különbözet<br>*A0DC0321DA |
| 2288 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Összegzések<br>*A-12-302-d Nyugdíjbizt. Alapot megillető járulékok összesen<br>*(kötelezettség különbözete)<br>*A0DC0302DA |
| 2289 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-307-d Egészségbizt.-i Alapot megillető járulékok összesen<br>*(kötelezettség különböze<br>*A0DC0307DA |
| 2290 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A-12-322-d A 301, 302 és a 307, valamint a 311-321 sorok aladata össz.<br>*(kötelezettség különbözet<br>*A0DC0322DA |
| 2291 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A 13a Jelölje X-szel, ha a helyesbítő bevallása önellenőrzésnek<br>* minősül<br>* A0AC032A |
| 2292 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2293 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2294 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2295 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amiknek van adószáma de nem<br>*  jött rá semmi |
| 2296 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2297 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje H-val, ha a bevallása helyesbítésnek minősül |
| 2298 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A-12-000-e Ismételt önellenőrzés |
| 2299 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  A 12a Jelölje H-val, ha a bevallása helyesbítésnek minősül |
| 2300 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **  Számítási algoritmus ÖNREVÍZIÓHOZ: |
| 2301 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0411DA<br>* A-12-411-d Személyi jövedelemadó összesen (kötelezettség különbözete)<br>*(Ez a bevallás A0CC0044CA+A0BD0017CA (forintos összeg)) - (előző erre<br>* az időszakra eső bevallás A0CC0044CA+A0BD0017CA (forintos összeg)) |
| 2302 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0413DA<br>* A-12-413-d A 412. sorból a Tbj. R-5/D (1) bekezés b) (kötezettség<br>* különb.)<br>*(Ez a bevallás A0BC0003CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0BC0003CA(forintos összeg)) |
| 2303 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0414DA<br>*A-12-414-d A 412. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(18%)(kötelezettség különböze<br>*(Ez a bevallás A0DC0047CA+A0CC0030CA(forintos összeg)) - (előző erre az<br>* időszakra eső bevallás A0DC0047CA(forintos összeg)) |
| 2304 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0415DA<br>*A-12-415-d A 412. sorból a biztosítottól levont nyugdíjjárulék (8,5%)<br>*(kötelezettség különböze<br>*(Ez a bevallás A0DC0048CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0DC0048CA(forintos összeg)) |
| 2305 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0416DA<br>*A-12-416-d A 412. sorból a biztosítottól levont nyugdíjjárulék (0,5%)<br>*(kötelezettség különböze<br>*(Ez a bevallás A0DC0049CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0DC0049CA(forintos összeg)) |
| 2306 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0417DA<br>*A-12-417-d A 412. sorból a felszolg.díj után fizetett nyugdíjjárulék<br>*(15%) (kötelezettség különböze<br>*(Ez a bevallás A0DC0050CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0DC0050CA(forintos összeg)) |
| 2307 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0419DA<br>*A-12-420-d A 418. sorból a Tbj. R-5/D (1) bekezés a) (kötezettség<br>*különb.)<br>*(Ez a bevallás A0BC0005CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0BC0005CA(forintos összeg)) |
| 2308 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0420DA<br>*A-12-420-d A 418. sorból a foglalkoztatót terhelő egészségbizt. járulék<br>*(11%) (kötelezettség különbö<br>* (Ez a bevallás A0DC0053CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0DC0053CA(forintos összeg)) |
| 2309 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0421DA<br>* A-12-421-d A 418. sorból a foglalkoztatót terhelő természetbeni eg.<br>*bizt. járulék (7%) (kötelezettség<br>*(Ez a bevallás A0DC0054CA+A0CC0031CA(forintos összeg)) - (előző erre az<br>* időszakra eső bevallás A0DC0054CA+A0CC0031CA(forintos összeg)) |
| 2310 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0422DA<br>*A-12-422-d A 418. sorból a foglalkoztatót terhelő pénzbeni eg.bizt.<br>*járulék (4%) (kötez. különb.)<br>*(Ez a bevallás A0DC0055CA+A0CC0032CA(forintos összeg)) - (előző erre az<br>* időszakra eső bevallás A0DC0055CA+A0CC0032CA(forintos összeg)) |
| 2311 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0423DA<br>*A-12-423-d A 418. sorból a biztosítottól levont egészségbizt.-i járulék<br>*(4%) (kötelezettség különbö<br>*(Ez a bevallás A0DC0056CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0DC0056CA(forintos összeg)) |
| 2312 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0424DA<br>*A-12-424-d A 418. sorból a biztosítottól levont term.beniegészségbizt.<br>*-i járulék (4%) (kötelezettség<br>* (Ez a bevallás A0DC0057CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0DC0057CA(forintos összeg)) |
| 2313 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0425DA<br>*A-12-425-d A 418. sorból a biztosítottól levont pénzbeni egészségbizt.<br>*-i járulék (2%) (kötelezettség<br>*(Ez a bevallás A0DC0058CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0DC0058CA(forintos összeg)) |
| 2314 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0426DA<br>* A-12-426-d A 418. sorból a társas vállalkozást terhelő baleseti<br>*járulék (5%) (kötelezettség különbö<br>* (Ez a bevallás A0DC0059CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0DC0059CA(forintos összeg)) |
| 2315 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0427DA<br>*A-12-427-d A 418. sorból a társas vállalkozást terhelő baleseti járulék<br>* (10%) (kötelezettség különbö<br>* (Ez a bevallás A0CC0060CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0CC0060CA(forintos összeg)) |
| 2316 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0428DA<br>*A-12-428-d Munkaadói járulék (kötelezettség különbözete)<br>*(Ez a bevallás A0EC0067CA+A0CC0029CA(forintos összeg)) - (előző erre az<br>* időszakra eső bevallás A0EC0067CA+A0CC0029CA(forintos összeg)) |
| 2317 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0429DA<br>*A-12-429-d Munkavállalói járulék (1%) (kötelezettség különbözete)<br>*(Ez a bevallás A0EC0068CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0EC0068CA(forintos összeg)) |
| 2318 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0430DA<br>*A-12-430-d Munkavállalói járulék (1,5%) (kötelezettség különbözete)<br>*(Ez a bevallás A0EC0069CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0EC0069CA(forintos összeg)) |
| 2319 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0431DA<br>*A-12-431-d Vállalkozói járulék (kötelezettség különbözete) |
| 2320 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2006/11/10<br>*(Ez a bevallás A0EC0070CA+A0CC0033CA(forintos összeg)) - (előző erre az<br>* időszakra<br>*eső bevallás A0EC0070CA+A0CC0033CA(forintos összeg))<br>*--BG 2006/11/10 |
| 2321 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2006/11/22<br>**++BG 2006/11/10<br>*                                C_ABEVAZ_A0CC0033CA        "Forrás 2 |
| 2322 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0432DA<br>*A-12-432-d Százalékos mértékű egészségügyi hozzájárulás (kötelezettség<br>*különbözete)<br>*(Ez a bevallás A0EC0073CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0EC0073CA(forintos összeg)) |
| 2323 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0433DA<br>* A-12-433-d Tételes egészségügyi hozzájárulás (kötelezettség<br>*különbözete)<br>*(Ez a bevallás A0EC0074CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0EC0074CA(forintos összeg)) |
| 2324 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0434DA<br>*A-12-434-d A START-kártyával rendelkezőre vonatkozó 15%-os mérétkű köt.<br>*(kötelezettség különbözete)<br>*(Ez a bevallás A0EC0071CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0EC0071CA(forintos összeg)) |
| 2325 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0435DA<br>*A-12-435-d A START-kártyával rendelkezőre vonatkozó 25%-os mérétkű köt.<br>* (kötelezettség különbözete)<br>*(Ez a bevallás A0EC0072CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0EC0072CA(forintos összeg)) |
| 2326 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0436DA<br>*A-12-436-d A kifizetőt terhelő egyszerűsített köztehervis.-i hozzájár<br>*20% (kötelezettség különbözet<br>*(Ez a bevallás A0EC0075CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0EC0075CA(forintos összeg)) |
| 2327 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0437DA<br>*A-12-437-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*11% (kötelezettség különbözet<br>*(Ez a bevallás A0EC0076CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0EC0076CA(forintos összeg)) |
| 2328 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0438DA<br>* A-12-438-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>* 11,1%(kötelezettség különbözet<br>* (Ez a bevallás A0EC0077CA(forintos összeg)) - (előző erre az időszakra<br>* eső bevallás A0EC0077CA(forintos összeg)) |
| 2329 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0439DA<br>*A-12-439-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*15%(kötelezettség különbözet<br>*(Ez a bevallás A0EC0078CA(forintos összeg)) - (előző erre az időszakra<br>*eső bevallás A0EC0078CA(forintos összeg)) |
| 2330 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0412DA<br>* A-12-412-d Nyugdíjbizt. Alapot megillető járulékok összesen<br>*(kötelezettség különbözete)<br>* A0FC0413DA+A0FC0414DA+A0FC0415DA+A0FC0416DA+A0FC0417DA |
| 2331 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0418DA<br>* A-12-418-d Egészségbizt.-i Alapot megillető járulékok összesen<br>*(kötelezettség különböze<br>* A0FC0419DA+A0FC0420DA+A0FC0421DA+A0FC0422DA+A0FC0423DA+A0FC0424DA+<br>* +A0FC0425DA+A0FC0426DA+A0FC0427DA |
| 2332 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0440CA<br>* A-12-440-c A 411, 412 és a 418, valamint a 428-439 sorok aladata össz.<br>* (kötelezettség alapja)<br>* A0FC0411CA+A0FC0412CA+A0FC0418CA+A0FC0428CA+A0FC0429CA+A0FC0430CA+<br>*+A0FC0431CA+A0FC0432CA+A0FC0434CA+A0FC0435CA+A0FC0436CA+A0FC0437CA+<br>*+A0FC0438CA+A0FC0439CA |
| 2333 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FC0440DA<br>* A-12-440-d A 411, 412 és a 418, valamint a 428-439 sorok aladata össz.<br>* (kötelezettség különbözet<br>*  A0FC0411DA+A0FC0412DA+A0FC0418DA+A0FC0428DA+A0FC0429DA+A0FC0430DA+<br>* +A0FC0431DA+A0FC0432DA+A0FC0433DA+A0FC0434DA+A0FC0435DA+A0FC0436DA+<br>* +A0FC0437DA+A0FC0438DA+A0FC0439DA |
| 2334 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A 13a Jelölje X-szel, ha a helyesbítő bevallása önellenőrzésnek<br>* minősül<br>* A0AC032A |
| 2335 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2336 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2337 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2338 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 2339 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2340 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje H-val, ha a bevallása helyesbítésnek minősül |
| 2341 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A00-016-000-e Ismételt önellenőrzés |
| 2342 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  A 13a Jelölje X-ell, ha a bevallása helyesbítésnek minősül |
| 2343 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **  Számítási algoritmus ÖNREVÍZIÓHOZ: |
| 2344 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0240DA<br>*A 07-241-c Nyugdíjbizt. Alapot megillető járulékok összesen (alap<br>*különbözete) |
| 2345 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0243CA<br>*A 07-243-c A 241. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(18%) (alap különbözete) |
| 2346 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0243DA<br>*A 07-243-d A 241. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(18%)(kötelezettség különböze |
| 2347 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0244DA<br>*A 07-244-d A 241. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(21%)(kötelezettség különböze |
| 2348 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-244-c A 241. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(21%) (alap különbözete)<br>* A0HC0244CA = A0HC0244DA értéknek / 21% |
| 2349 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0245DA<br>*A 07-245-d A 241. sorból a biztosítottól levont nyugdíjjárulék (8,5%)<br>*(kötelezettség különböze |
| 2350 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0245CA<br>*A 07-245-c A 241. sorból a biztosítottól levont nyugdíjjárulék (8,5%)<br>*(alap különbözete) |
| 2351 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0246DA<br>*A 07-246-d A 241. sorból a biztosítottól levont nyugdíjjárulék (0,5%)<br>*(kötelezettség különböze |
| 2352 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0246CA<br>*A0HC0246DA értéknek / 0,5% |
| 2353 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0247DA<br>*A 07-247-d A 241. sorból a felszolg.díj után fizetett nyugdíjjárulék<br>*(15%) (kötelezettség különböze |
| 2354 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0247CA<br>*A0HC0247DA értéknek / 15% |
| 2355 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0241CA<br>*A 07-241-c Nyugdíjbizt. Alapot megillető járulékok összesen (alap<br>*különbözete) |
| 2356 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0241DA<br>*A 07-241-d Nyugdíjbizt. Alapot megillető járulékok összesen<br>*(kötelezettség különbözete) |
| 2357 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0250DA<br>*A 07-250-d A 248. sorból a foglalkoztatót terhelő egészségbizt. járulék<br>*(11%) (kötelezettség különbö |
| 2358 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0250CA<br>*A0HC0250DA értékének / 11% |
| 2359 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0251DA<br>*A 07-251-d A 248. sorból a foglalkoztatót terhelő természetbeni<br>*eg.bizt. járulék (7%) (kötelezettség kül.) |
| 2360 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0251CA<br>*A0HC0251DA értékének / 7% |
| 2361 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0252DA<br>*A 07-252-d A 248. sorból a foglalkoztatót terhelő természetbeni<br>*eg.bizt. járulék (5%) (kötelezettség kül.) |
| 2362 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0252CA<br>*A0HC0252DA értékének / 5% |
| 2363 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0253DA<br>*A 07-253-d A 248. sorból a foglalkoztatót terhelő pénzbeni eg.bizt.<br>*járulék (4%) (kötez. különb.) |
| 2364 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0253CA<br>*A0HC0253DA értékének / 4% |
| 2365 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0254DA<br>*A 07-254-d A 248. sorból a foglalkoztatót terhelő pénzbeni eg.bizt.<br>*járulék (3%) (kötez. különb.) |
| 2366 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0254CA<br>*A0HC0254DA értékének / 3% |
| 2367 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0255DA<br>*A 07-255-d A 248. sorból a biztosítottól levont egészségbizt.-i járulék<br>*(4%) (kötelezettség különbö |
| 2368 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0255CA<br>*A0HC0255DA értékének / 4% |
| 2369 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0256DA<br>*A 07-256-d A 248. sorból a biztosítottól levont<br>*term.beniegészségbizt.-i járulék (4%) (kötelezettség különbö |
| 2370 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0256CA<br>*A0HC0256DA értékének / 4% |
| 2371 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0257DA<br>*A 07-257-d A 248. sorból a biztosítottól levont pénzbeni<br>*egészségbizt.-i járulék (2%) (kötelezettség különbö |
| 2372 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0257CA<br>*A0HC0257DA értékének / 2% |
| 2373 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0258DA<br>*A 07-258-d A 248. sorból a biztosítottól levont pénzbeni<br>*egészségbizt.-i járulék (3%) (kötelezettség különbö |
| 2374 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0258CA<br>*A0HC0258DA értékének / 3% |
| 2375 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0259DA<br>*A 07-259-d A 248. sorból a társas vállalkozást terhelő baleseti járulék<br>*(5%) (kötelezettség különbö |
| 2376 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0259CA<br>*A0HC0259DA értékének / 5% |
| 2377 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0248CA<br>*A 07-248-c Egészségbizt.-i Alapot megillető járulékok összesen (alap<br>*különbözete) |
| 2378 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0248DA<br>*A 07-248-d Egészségbizt.-i Alapot megillető járulékok összesen<br>*(kötelezettség különböze |
| 2379 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0HC0261DA<br>*A 07-261-d A 248. sorból a társas vállalkozást terhelő baleseti járulék<br>*(kötelezettség különbö |
| 2380 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0262DA<br>*A 08-262-d Munkaadói járulék (kötelezettség különbözete) |
| 2381 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007.03.22<br>*A0IC0262CA<br>* Munkaadói járulék |
| 2382 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0263DA<br>*A 08-263-d Munkavállalói járulék (1%) (kötelezettség különbözete) |
| 2383 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0263CA<br>*A0IC0263DA értékének / 1% |
| 2384 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0264DA<br>*A 08-264-d Munkavállalói járulék (1,5%) (kötelezettség különbözete) |
| 2385 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0264CA<br>*A0IC0264DA értékének / 1,5% |
| 2386 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0265DA<br>*A 08-265-d Vállalkozói járulék (kötelezettség különbözete) |
| 2387 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0265CA<br>*A0IC0265DA értékének / 4% |
| 2388 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0266DA<br>*A 08-266-d Százalékos mértékű egészségügyi hozzájárulás (kötelezettség<br>*különbözete) |
| 2389 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0267DA<br>*A 08-267-d Tételes egészségügyi hozzájárulás (kötelezettség<br>*különbözete) |
| 2390 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0268DA<br>*A 08-268-d A START-kártyával rendelkezőre vonatkozó 15%-os mérétkű köt.<br>*(kötelezettség különbözete) |
| 2391 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0268CA<br>*A0IC0268DA értékének / 15% |
| 2392 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0269DA<br>*A 08-269-d A START-kártyával rendelkezőre vonatkozó 25%-os mérétkű köt.<br>*(kötelezettség különbözete) |
| 2393 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0269CA<br>*A0IC0269DA értékének / 25% |
| 2394 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0270DA<br>*A 08-270-d A kifizetőt terhelő egyszerűsített köztehervis.-i hozzájár<br>*20% (kötelezettség különbözet |
| 2395 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0270CA<br>*A0IC0270DA értékének / 20% |
| 2396 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0271DA<br>*A 08-271-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*11% (kötelezettség különbözet |
| 2397 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0271CA<br>*A0IC0271DA értékének / 11% |
| 2398 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0272DA<br>*A 08-272-d A magánsz-t terhelő egyszerűsített köztehervis.-i hozzájár<br>*11,1%(kötelezettség különbözet |
| 2399 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0272CA<br>*A0IC0272DA értékének / 11,1% |
| 2400 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0273DA<br>*A 08-273-d A magánsz-t terhelő -nem mnyptár - EKHO 15% (kötelezettség<br>*különbözet) |
| 2401 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0273CA<br>*A0IC0273DA értékének / 15% |
| 2402 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0274DA<br>*A 08-274-d A mnyptár tag magánsz-t terhelő - EKHO 15% (kötelezettség<br>*különbözet) |
| 2403 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0274CA<br>*A0IC0274DA értékének / 15% |
| 2404 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007.04.05<br>*A0IC50068A<br>*Különadó számolása |
| 2405 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++CST 2007.04.11<br>*A0IC50067A<br>*Különadó alapjának számolása<br>*A0IC50068A értékének / 4% |
| 2406 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008/01/14<br>* A 08-276-d A START PLUSZ kártyával rendelkezőre vonatkozó 15%-os<br>* mérétkű köt. (kötelezettség különb) |
| 2407 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-276-c A START PLUSZ kártyával rendelkezőre vonatkozó 15%-os<br>* mérétkű köt. (kötelezettség alapja) |
| 2408 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-277-d A START PLUSZ kártyával rendelkezőre vonatkozó 25%-os<br>*mérétkű köt. (kötelezettség különb) |
| 2409 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-277-c A START PLUSZ kártyával rendelkezőre vonatkozó 25%-os<br>*mérétkű köt. (kötelezettség alapja) |
| 2410 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A 08-278-d A START EXTRA kártyával rendelkezőre vonatkozó 15%-os<br>* mérétkű köt. (kötelezettség különb) |
| 2411 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-278-c A START EXTRA kártyával rendelkezőre vonatkozó 15%-os<br>*mérétkű köt. (kötelezettség alapja) |
| 2412 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0275CA<br>*++0004 BG 2007.04.04<br>*A 08-275-c A 240, 241 és a 248, valamint a 262-275 sorok aladata össz.<br>*(kötelezettség alapja<br>*--0004 BG 2007.04.04 |
| 2413 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0IC0275DA<br>*++0004 BG 2007.04.04<br>*A 08-275-c A 240, 241 és a 248, valamint a 262-274 sorok aladata össz.<br>*(kötelezettség különbözet)<br>*--0004 BG 2007.04.04 |
| 2414 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A 14a Jelölje X-szel, ha a helyesbítő bevallása önellenőrzésnek<br>* minősül<br>* A0AC033A |
| 2415 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0ID0281BA<br>*A 08-281-b Önellenőrzési pótlék Art. 28/B § alapján |
| 2416 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0ID0282BA<br>*A 08-282-b Önellenőrzési pótlék összesen (280+281. sor) |
| 2417 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007/01/21<br>*  A0BC0012CA<br>*  Itt is összesíteni kell mert a összesítő ABEVAZ-nál<br>*  még nincs érték. |
| 2418 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2419 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió és SZJA |
| 2420 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önrevízós pótlékok meghatározása<br>*  Önrevíziós ABEV azonosítók meghatározása |
| 2421 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008.03.10<br>*  Csak akkor számítunk önrevíziós pótlékot ahol be van jelölve<br>*  mert 0808-tól van olyan önrevíziós adónem ahova ad fel HR<br>*  de az már egy kiszámított pótlék, így a régi elvvel a<br>*  pótlékra is számítanánk pótlékot. |
| 2422 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 103-as<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 2423 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 2424 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az ESDAT_FLAG-ben megjelölt ABEV azonosító<br>* értéke |
| 2425 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Hiba a önrevízió esedékesség dátum konvertálásnál! (&) |
| 2426 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Hiba a önrevízió esedékesség dátum konvertálásnál! (&) |
| 2427 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2408 #03.<br>*  Beolvassuk az adónem ABEV összerendelést |
| 2428 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  kamat visszaírása<br>*  A-12-323-b Önellenőrzési pótlék összege<br>*A0DD0323BA |
| 2429 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0FD0441BA<br>*  A-12-441-b Önellenőrzési pótlék összege |
| 2430 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0ID0280BA<br>*  A-08-280-b Önellenőrzési pótlék összege |
| 2431 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ FI 20070312<br>*A0ID0282BA<br>*A 08-282-b Önellenőrzési pótlék összesen (280+281. sor) |
| 2432 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0ID0270BA<br>*  A-08-280-b Önellenőrzési pótlék összege |
| 2433 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0ID0272BA<br>*A 08-282-b Önellenőrzési pótlék összesen (270+271. sor) |
| 2434 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0ID0270BA<br>*  A-08-280-b Önellenőrzési pótlék összege |
| 2435 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A0ID0272BA<br>*A 08-282-b Önellenőrzési pótlék összesen (270+271. sor) |
| 2436 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0HD0220BA<br>*    A-08-280-b Önellenőrzési pótlék összege |
| 2437 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0HD0222BA<br>*    Önellenőrzési pótlék összesen |
| 2438 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0HD0210BA<br>*    A-08-280-b Önellenőrzési pótlék összege |
| 2439 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0HD0212CA<br>*    Önellenőrzési pótlék összesen |
| 2440 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0FD0160CA<br>*    A-08-280-b Önellenőrzési pótlék összege |
| 2441 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0FD0162CA<br>*    Önellenőrzési pótlék összesen |
| 2442 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0FD0160CA<br>*    A-08-280-b Önellenőrzési pótlék összege |
| 2443 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A0FD0162CA<br>*    Önellenőrzési pótlék összesen |
| 2444 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2445 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2446 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2447 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2448 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2449 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2450 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2451 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2452 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2453 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2454 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2455 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2456 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2457 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2458 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2459 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2460 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2461 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2462 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2463 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2464 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege<br>*++2408 #03. |
| 2465 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2466 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összege |
| 2467 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Önellenőrzési pótlék összesen |
| 2468 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Aktuális bevallás olvasása |
| 2469 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Előző időszak beolvasása |
| 2470 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Különbözet kiszámolása |
| 2471 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mező módosítása |
| 2472 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Mező keresése |
| 2473 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * RANGEK feltöltése SZJA adóazonosító lapszám kezeléshez |
| 2474 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ABEV azonosítók kizárása<br>*M-10-267-a Tárgyidőszaktól eltérő biztosításban töltött idő időtartalma |
| 2475 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M-10-267-c Tárgyidőszaktól eltérő biztosításban töltött idő időtartalma |
| 2476 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 2477 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Adóazonosítói lapszámhoz gyűjtések<br>*   17-25 mező |
| 2478 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése SZJA adóazonosító lapszám kezeléshez |
| 2479 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ** ABEV azonosítók kizárása<br>**M-10-267-a Tárgyidőszaktól eltérő biztosításban töltött idő<br>*időtartalma<br>*   M_DEF R_M0AC024A 'E' 'EQ' 'M0ID0267AA' SPACE.<br>**--BG 2006/06/27 |
| 2480 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2006.10.11<br>*  Alkalmazás minősége még kell a lapszám miatt |
| 2481 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 2482 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Adóazonosítói lapszámhoz gyűjtések<br>*   17-25 mező |
| 2483 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése SZJA adóazonosító lapszám kezeléshez |
| 2484 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ** ABEV azonosítók kizárása<br>**M-10-267-a Tárgyidőszaktól eltérő biztosításban töltött idő<br>*időtartalma<br>*   M_DEF R_M0AC024A 'E' 'EQ' 'M0ID0267AA' SPACE.<br>**--BG 2006/06/27 |
| 2485 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2006.10.11<br>*  Alkalmazás minősége még kell a lapszám miatt |
| 2486 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 2487 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Adóazonosítói lapszámhoz gyűjtések<br>*   17-25 mező |
| 2488 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007/01/21<br>*        Halmozás |
| 2489 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007.03.22<br>*  Ebbe a range-be definiált ABEV azonosítók nem kellenek 0708-nál |
| 2490 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Definiáljuk azokat az ABEV azonosítókat, amiknél nem használjuk az ONR<br>*képzést |
| 2491 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Csak önrevíziónál |
| 2492 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meg kell határozni azokat az "A"-s ABEV azonosítókat, amik<br>*  nem számítottak és numerikusak.<br>*  Mivel ezek összegei minden időszakot tartalmaznak ki kell<br>*  vonni az előzőből. |
| 2493 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Előző index meghatározása |
| 2494 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--BG 2009.07.08<br>*    Delta képzés |
| 2495 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Új érték |
| 2496 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008.05.09<br>*      0808-nál nem kell ABS étékben kezelni mert az ABEV<br>*      már tudja kezelni a negatív számokat. |
| 2497 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--BG 2008.05.09<br>*++BG 2007.03.22 Ha az összeg negatív, akkor az ABEV hibát jelez<br>*                ezért ABS értékben tároljuk el |
| 2498 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Előjel fordítás |
| 2499 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Halmozás |
| 2500 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Megjelöljük azokat a rekordokat amik összegzendők és<br>*  nincs még megjelölve |
| 2501 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008.03.06<br>*    Azokat is megjeleöljük amibe összegezzük mert nem biztos, hogy<br>*    jött bele adat de önrevíziósként kell kezelnünk. |
| 2502 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.07.08<br>*  Azokat is megjelöljük amik ABEV-ből lesznek átvéve és azok<br>*  önrevíziós számítás alá esnek: |
| 2503 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++0908 2009.02.27 BG<br>*  Csak az önrevízióknál megjelölt ABEV-eknél<br>*  kell a 0-flag-et újra kezelni: |
| 2504 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Töröljük a 0-flag értékét az önrevízióknál |
| 2505 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    0-ás mezők kezelése önrevízióra |
| 2506 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    0-ás mezők kezelése önrevízióra |
| 2507 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    0-ás mezők kezelése önrevízióra |
| 2508 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    0-ás mezők kezelése önrevízióra |
| 2509 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    0-ás mezők kezelése önrevízióra |
| 2510 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  NULL_FLAG értékek visszaírása: |
| 2511 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007.05.30<br>*                                  Performancia növelés miatt |
| 2512 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Előjel fordítás |
| 2513 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk a számítás alapját |
| 2514 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Hányados kiszámolása |
| 2515 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2008.07.09<br>*      Csak akkor számolunk így ha a kerekített kibontott nem 0 |
| 2516 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mező módosítása |
| 2517 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk a számítás alapját |
| 2518 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Hányados kiszámolása |
| 2519 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mező módosítása |
| 2520 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 2521 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2522 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Aláírás dátuma (sy-datum) |
| 2523 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK kezdő dátuma |
| 2524 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 2525 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++0004 BG 2007.05.24<br>*    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 2526 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 2527 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2528 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2529 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Aláírás dátuma (sy-datum) |
| 2530 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK kezdő dátuma |
| 2531 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 2532 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 2533 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 2534 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2535 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2536 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Aláírás dátuma (sy-datum) |
| 2537 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK kezdő dátuma |
| 2538 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 2539 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 2540 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 2541 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2542 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2543 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 2544 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 2545 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 2546 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Bevallás gyakorisága |
| 2547 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 2548 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2549 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2550 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 2551 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 2552 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 2553 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Bevallás gyakorisága |
| 2554 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0062CA >= M0BC0062BA akkor M0BC0062DA = 0 és flag beállítása |
| 2555 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0082CA >= M0BC0082BA akkor M0BC0082DA = 0 és flag beállítása |
| 2556 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0082CA >= M0BC0082BA akkor M0BC0082DA = 0 és flag beállítása |
| 2557 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Végigolvassuk adószámonként |
| 2558 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Ha nincs érték az első mezőben, akkor nem kell tovább vizsgálni |
| 2559 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Feltétel vizsgálat |
| 2560 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Van rekord érték 0 és nem kell törölni |
| 2561 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Nincs érték létre kell hozni. |
| 2562 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Meg kell határozni az adószám alapján a M0KB011A mezőt |
| 2563 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 2564 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2565 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2566 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007.12.08<br>* Speciális számítások<br>* START-kártya kötelzettség |
| 2567 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2007/01/16<br>*  Áthelyezve a számítási rutinok elé<br>*  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 2568 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2569 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje H-val, ha a bevallása helyesbítésnek minősül |
| 2570 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    A00-016-000-e Ismételt önellenőrzés |
| 2571 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 2572 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2573 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 2574 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Speciális számítások |
| 2575 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-40-c A fogl terh nyugdíjbizt összesen |
| 2576 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2577 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-41-c A fogl terh munkanélk, állásker fiz nyugbizt |
| 2578 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2579 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-40-c A fogl terh ápolási díj nyugdíjbizt |
| 2580 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2581 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-43-c A magánsz terh nyugdíjj |
| 2582 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2583 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-44-c A magánsz terh munkanélk, állásker fiz nyug |
| 2584 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2585 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-45-c A magánsz terh GYED, S, T után fiz nyugdíj |
| 2586 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2587 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-46-c A Mnypt tag magánsz terh nyugdíj |
| 2588 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2589 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-47-c A  Mnypt tag magánsz terh munkanélk, állásker nyugdíj |
| 2590 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2591 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-48-cA  Mnypt tag magánsz terh GYED,S,T fiz nyugdíj |
| 2592 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2593 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2594 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-61-c A fogl terh munkanélk állásker fiz term egbizt |
| 2595 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2596 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-62-c A fogl terh pénz egbizt |
| 2597 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2598 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-63-c A fogl terh munkanélk állásker pénzb egbizt |
| 2599 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2600 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-80-c A START-kártyával rend 15%-os |
| 2601 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2602 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-81-c  A START-kártyával rend 25%-os |
| 2603 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2604 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2605 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2606 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-84-c A START EXTRA kártyával rend 0%-os |
| 2607 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2608 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-85-c A START EXTRA kártyával rend 15%-os |
| 2609 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2610 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2611 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2612 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2613 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 2614 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2615 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 2616 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Jelölje X-ell, ha a bevallása helyesbítésnek minősül |
| 2617 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **  Számítási algoritmus ÖNREVÍZIÓHOZ: |
| 2618 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A 07-199-d A 198. sorból: magánszemélyhez nem köthető személyi<br>* jövedelemadó<br>* A0HC0199DA |
| 2619 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-200-c A 198. sorból: magánszemélyhez köthető személyi jövedelemadó<br>*A0HC0200CA |
| 2620 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *                               C_ABEVAZ_M0CC0415DA         "Forrás 1<br>*                               C_ABEVAZ_M0CF0430BA         "Forrás 2<br>*                               C_ABEVAZ_M0CF0431BA         "Forrás 3<br>*                               C_ABEVAZ_M0CF0434BA         "Forrás 4<br>*                               C_ABEVAZ_M0CF0435CA.        "Forrás 5<br>*--BG 2008.03.06 |
| 2621 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-200-d A 198. sorból: magánszemélyhez köthető személyi<br>*jövedelemadó<br>*A0HC0200DA |
| 2622 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-201-d Különadó(kötelezettség különbözet)<br>*A0HC0201DA |
| 2623 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-201-c Különadó (kötelezettség alapja)<br>*A0HC0201CA = A0HC0201DA/4% |
| 2624 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-203-d A 202. sorból a foglalkoztatót terhelő nyugdíjbizt.<br>*járulék (kötelezettség különböze<br>*A0HC0203DA |
| 2625 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-203-c A 202. sorból a foglalkoztatót terhelő nyugdíjbizt. járulék<br>*(alap különbözete)<br>*A0HC0203CA = A0HC0203DA/24% |
| 2626 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-204-d A 202. sorból a biztosítottól levont nyugdíjjárulék<br>*(kötelezettség különböze<br>*A0HC0204DA |
| 2627 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-204-c A 202. sorból a biztosítottól levont nyugdíjjárulék<br>*(alap különbözete)<br>*A0HC0204CA = A0HC0204DA/9,5% |
| 2628 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-205-d A 202. sorból a Mnypt biztosítottól levont nyugdíjjárulék<br>*(kötelezettség különböze<br>*A0HC0205DA |
| 2629 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-205-c A 202. sorból a Mnypt biztosítottól levont nyugdíjjárulék<br>*(alap különbözete)<br>*A0HC0205CA = A0HC0205DA/1,5% |
| 2630 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-206-d A 202. sorból a felszolgálási díj után fizetett nyugbizt<br>*járulék (15%)(kötelezettség<br>*A0HC0206DA |
| 2631 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-206-c A 202. sorból a felszolgálási díj után fizetett nyugbizt<br>*járulék (15%) (alap kül)<br>*A0HC0206CA = A0HC0206DA/15% |
| 2632 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-209-d A 208. sorból a foglalkoztatót terhelő természetbeni<br>*eg.bizt.<br>*járulék (kötelezettség<br>*A0HC0209DA |
| 2633 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-209-c  A 208. sorból a foglalkoztatót terhelő természetbeni eg.<br>*bizt. járulék (alap különbö<br>*A0HC0209CA = A0HC0209DA/4,5% |
| 2634 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-210-d A 208. sorból a foglalkoztatót terhelő pénzbeni eg.bizt.<br>*járulék (kötez. különb.)<br>*A0HC0210DA |
| 2635 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-210-c  A 208. sorból a foglalkoztatót terhelő pénzbeni eg.bizt.<br>*járulék (alap különbözete)<br>*A0HC0210CA = A0HC0210DA/0,5% |
| 2636 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-211-c  A 208. sorból a társas vállalkozást terhelő egészségügyi<br>*szolg.<br>*(alap különbözete)<br>*A0HC0211DA |
| 2637 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-212-d A 208. sorból a biztosítottól levont term.  egészségbizt.-i<br>*járulék<br>*(kötelezettség<br>*A0HC0212DA |
| 2638 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-212-c  A 208.sorból a biztosítottól levont term. egészségbizt.-i<br>*járulék (alap különböz<br>*A0HC0212CA = A0HC0212DA/4% |
| 2639 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-213-d A 208. sorból a biztosítottól levont pénzbeni<br>*egészségbizt.-i járulék<br>*(kötelezettség<br>*A0HC0213DA |
| 2640 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-213-c  A 208.sorból a biztosítottól levont pénzbeni egészségbizt.<br>*-i járulék (alap különböz<br>*A0HC0213CA = A0HC0213DA/2% |
| 2641 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-215-d Korkedvezmény-biztosítási járulék(kötelezettség különbözete)<br>*A0HC0215DA |
| 2642 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-215-c Korkedvezmény-biztosítási járulék (alap különbözete)<br>*A0HC0215CA = A0HC0215DA/3,25% |
| 2643 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-216-d Munkaadói járulék (kötelezettség különbözete)<br>*A0HC0216DA |
| 2644 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-216-c Munkaadói járulék (alap különbözete)<br>*A0HC0216CA = A0HC0216DA/3% |
| 2645 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-217-d Munkavállalói járulék (kötelezettség különbözete)<br>*A0HC0217DA |
| 2646 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-217-c Munkavállalói járulék  (alap különbözete)<br>*A0HC0217CA = A0HC0217DA/1,5% |
| 2647 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-218-d Vállalkozói járulék (kötelezettség különbözete)<br>*A0HC0218DA |
| 2648 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-218-c Vállalkozói járulék (alap különbözete)<br>*A0HC0218CA = A0HC0218DA/4% |
| 2649 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-220-d A 219. sorból A START-kártyával rendelkezőre vonatkozó<br>*15%-os mérétkű köt. (különbözete)<br>*A0HC0220DA |
| 2650 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-220-c A 219. sorból A START-kártyával rendelkezőre vonatkozó 15%-<br>*os mérétkű köt. (alapja)<br>*A0HC0220CA = A0HC0220DA/15% |
| 2651 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-221-d A 219. sorból A START-kártyával rendelkezőre vonatkozó<br>*25%-os mérétkű köt. (különbözete)<br>*A0HC0221DA |
| 2652 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-221-c A 219. sorból A START-kártyával rendelkezőre vonatkozó 25%-<br>*os mérétkű köt. (lapja)<br>*A0HC0221CA = A0HC0221DA/25% |
| 2653 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-221-d A 219. sorból A START-kártyával rendelkezőre vonatkozó<br>*25%-os mérétkű köt. (különbözete)<br>*A0HC0221DA |
| 2654 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-222-c A 219. sorból A START PLUSZ kártyával rendelkezőre vonatkozó<br>*15%-os mérétkű köt. (különb)<br>*A0HC0222CA = A0HC0222DA/15% |
| 2655 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-223-d A 219. sorból A START PLUSZ kártyával rendelkezőre vonatkozó<br>* 25%-os mérétkű köt. (alapja)<br>*A0HC0223DA |
| 2656 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-223-c A 219. sorból A START PLUSZ kártyával rendelkezőre vonatkozó<br>* 25%-os mérétkű köt. (különb)<br>*A0HC0223CA = A0HC0223DA/25% |
| 2657 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-224-d A 219. sorból A START EXTRA kártyával rendelkezőre vonatkozó<br>*15%-os mérétkű köt. (alapja)<br>*A0HC0224DA |
| 2658 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-224-c A 219. sorból A START EXTRA kártyával rendelkezőre vonatkozó<br>* 15%-os mérétkű köt. (különb)<br>*A0HC0224CA = A0HC0224DA/15% |
| 2659 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-225-c Százalékos mértékű egészségügyi hozzájárulás<br>*(alap különbözete)<br>*A0HC0225CA |
| 2660 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *                                C_ABEVAZ_M0EC0461CA        "Forrás 1<br>*                                C_ABEVAZ_M0EC0463CA        "Forrás 2<br>*                                SPACE                      "Forrás 3<br>*                                SPACE                      "Forrás 4<br>*                                SPACE.                     "Forrás 5<br>*--BG 2008.03.06 |
| 2661 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-225-d Százalékos mértékű egészségügyi hozzájárulás<br>* (kötelezettség különbözete)<br>*A0HC0225DA |
| 2662 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-227-d A 226. sorból Tételes Eho a teljes munkaidőben<br>*(kötelezettség különbözete)<br>*A0HC0227DA |
| 2663 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-228-d A 226. sorból Tételes Eho a részmunkaidőben<br>*(kötelezettség különbözete)<br>*A0HC0228DA |
| 2664 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-229-d A 226. sorból Eho tv. 11. § (4) bek  (kötelezettség<br>*különbözete)<br>*A0HC0229DA |
| 2665 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-230-d A kifizetőt terhelő egyszerűsített köztehervis.<br>*-i hozzájár 20% (kötelezettség különbözet<br>*A0IC0230DA |
| 2666 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-230-c A kifizetőt terhelő egyszerűsített köztehervis.-i<br>*hozzájár 20% (kötelezettség alapja)<br>*A0IC0230CA = A0IC0230DA/20% |
| 2667 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-231-a A 230. sorból számított egészségbiztosítási járulék rész<br>*(kötelezettség alapja)<br>*A0IC0231AA |
| 2668 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-232-a A 230. sorból számított egészségbiztosítási járulék rész<br>*(kötelezettség különbözet<br>*A0IC0232AA |
| 2669 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-233-d A nyugdíjas magánszemélyt terhelő Ekho (kötelezettség<br>*különbözet<br>*A0IC0233DA |
| 2670 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-233-c A nyugdíjas magánszemélyt terhelő Ekho (kötelezettség<br>*alapja)<br>*A0IC0233CA = A0IC0233DA/11% |
| 2671 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-234-d A nem Mnypt tag magánszemélyt terhelő Ekho (15%)<br>*(kötelezettség különbözet<br>*A0IC0234DA |
| 2672 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-234-d A nem Mnypt tag magánszemélyt terhelő Ekho (15%)<br>*(kötelezettség)<br>*A0IC0234CA = A0IC0234DA/15% |
| 2673 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-235-a A 234. sorból számított nyugdíjjárulék rész<br>*(kötelezettség alapja)<br>*A0IC0235AA |
| 2674 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-236-a A 234. sorból számított term. egbizt járulék rész<br>*(kötelezettség különbözet<br>*A0IC0236AA |
| 2675 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-237-d A Mnypt tag magánszemélyt terh Ekho (15%) összesen<br>*(kötelezettség különbözet<br>*A0IC0237DA |
| 2676 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-237-c A Mnypt tag magánszemélyt terh Ekho (15%) összesen<br>*(kötelezettség)<br>*A0IC0237CA = A0IC0237DA/15% |
| 2677 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-238-a A 237. sorból számított nyugdíjjárulék rész<br>*A0IC0238AA |
| 2678 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-239-a A 237. sorból számított term. egbizt. rész<br>*A0IC0239AA |
| 2679 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-260-d Az EGT tagállamban biztosított személytől levont Ekho<br>*(kötelezettség különbözet<br>*A0IC0260DA |
| 2680 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 08-260-c Az EGT tagállamban biztosított személytől levont Ekho<br>*(kötelezettség alap)<br>*A0IC0260CA = A0IC0260DA/9,5% |
| 2681 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *ÖSSZESÍTÉSEK<br>*A 07-198-c Személyi jövedelemadó összesen (alap különbözete)<br>*A0HC0198CA |
| 2682 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-198-d Személyi jövedelemadó összesen (kötelezettség különbözete)<br>*A0HC0198DA |
| 2683 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-202-c Nyugdíjbizt. Alapot megillető járulékok összesen<br>*(alap különbözete)<br>*A0HC0202CA |
| 2684 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-202-d Nyugdíjbizt. Alapot megillető járulékok összesen<br>*(kötelezettség különbözete)<br>*A0HC0202DA |
| 2685 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-208-c Egészségbizt.-i Alapot megillető járulékok összesen<br>*(alap különbözete)<br>*A0HC0208CA |
| 2686 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-208-d Egészségbizt.-i Alapot megillető járulékok összesen<br>*(kötelezettség különböze<br>*A0HC0208DA |
| 2687 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-219-c A START (START,  PLUST,  EXTRA) kártyával 15<br>*és/vagy 25%-os köt alapja<br>*A0HC0219CA |
| 2688 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-219-d A START (START,  PLUST,  EXTRA) kártyával<br>*15 és/vagy 25%-os köt kül<br>*A0HC0219DA |
| 2689 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-226-d Tételes egészségügyi hozzájárulás<br>*(kötelezettség különbözete)<br>*A0HC0226DA |
| 2690 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben a tartományban kell keresni numerikus értéket |
| 2691 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Van érték: |
| 2692 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0808 2009.02.11 BG<br>*  Jelölje X-ell, ha a bevallása önellenőrzésnek minősül |
| 2693 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Jelölje X-ell, ha a bevallása ismételt önellenőrzésnek minősül |
| 2694 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 2695 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2696 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 2697 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC029A = időszak-tól első nap |
| 2698 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2699 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      mindig A0AC030A = időszak-ig utolsó nap |
| 2700 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adózók száma = Adószámok |
| 2701 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 2702 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0382CA >= M0BC0382BA akkor M0BC0382DA = 0 és flag beállítása |
| 2703 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0382DA >= M0BC0382BA akkor M0BC0382CA = 0 és flag beállítása |
| 2704 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0386CA >= M0BC0386BA akkor M0BC0386DA = 0 és flag beállítása |
| 2705 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *M0BC0386DA >= M0BC0386BA akkor M0BC0386CA = 0 és flag beállítása |
| 2706 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mező1+mező2+mező3+mező4 > 0 akkor 0 flag beállítás |
| 2707 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2708 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2709 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2710 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2711 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2712 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2713 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2714 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2715 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2716 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2717 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2718 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2719 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2720 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2721 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2722 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2723 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2724 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2725 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2726 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2727 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 2728 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2729 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2730 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2731 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2732 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2733 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2734 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2735 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2736 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2737 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2738 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2739 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2740 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 vagy mező6 ne 0 akkor 0 flag beállítás M-s lapon |
| 2741 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése SZJA adóazonosító lapszám kezeléshez |
| 2742 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 2743 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Adóazonosítói lapszámhoz gyűjtések |
| 2744 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2745 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2746 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-200-c A 198. sorból: magánszemélyhez köthető személyi jövedelemadó<br>*A0HC0199CA : A0BC0002CA/25% + A0BC0005CA/54% + A0BC0006CA/54% +<br>*             A0BC0008CA/33% + A0BC0009CA/10% + A0BC0012CA/54% |
| 2747 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  A0HC0199CA módosítás miatt |
| 2748 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 07-225-c Százalékos mértékű egészségügyi hozzájárulás (alap<br>*különbözete)<br>*A0HC0225CA = A0BC0017CA/25% + A0BC0018CA/11% |
| 2749 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Szja kötelezettség alapja<br>*  A0ZZ000001 |
| 2750 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Eho kötelezettség alapja<br>*  A0ZZ000002 |
| 2751 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Aktuális bevallás olvasása |
| 2752 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzés |
| 2753 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mező módosítása |
| 2754 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      FILED_N-t vizsgáljuk, mert ha a FIELD_NRK 0 akkor<br>*      kiírjuk a mezőt 0-val és az ABEV ebben az esetben<br>*      az összesítő soron is 0-át vár. |
| 2755 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Ha a BEVALLB-ben be van jelölve az előjel fordítás, akkor az<br>* önrevízió mezőkön a számítás miatt megfelel de az ABEV-be nem<br>* előjelesen kell kezelni. Ezért végigolvassuk a beállítás alapján<br>* és az önrevíziós mezőkön visszafordítjuk az előjelet. |
| 2756 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 2757 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2758 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 2759 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Speciális számítások |
| 2760 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-40-c A fogl terh nyugdíjbizt összesen |
| 2761 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2762 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-41-c A fogl terh munkanélk, állásker fiz nyugbizt |
| 2763 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2764 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-40-c A fogl terh ápolási díj nyugdíjbizt |
| 2765 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2766 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-43-c A magánsz terh nyugdíjj |
| 2767 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2768 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-44-c A magánsz terh munkanélk, állásker fiz nyug |
| 2769 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2770 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-45-c A magánsz terh GYED, S, T után fiz nyugdíj |
| 2771 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2772 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-46-c A Mnypt tag magánsz terh nyugdíj |
| 2773 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2774 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-47-c A  Mnypt tag magánsz terh munkanélk, állásker nyugdíj |
| 2775 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2776 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-48-cA  Mnypt tag magánsz terh GYED,S,T fiz nyugdíj |
| 2777 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2778 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0908/2 2009.08.04 BG<br>*        Feltétel feltöltése |
| 2779 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Foglalkoztatói term egbizt 1,5% nem 25, 42, 81 |
| 2780 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2781 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Foglalkoztatói term egbizt 4,5% nem 25, 42, 81 |
| 2782 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2783 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0908/2 2009.08.04 BG<br>*      A 03-61-c A fogl terh munkanélk állásker fiz term egbizt |
| 2784 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0908/2 2009.08.04 BG<br>*        Feltétel feltöltése |
| 2785 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Foglalkoztatói term egbizt 1,5% nem 25, 42, 81 |
| 2786 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2787 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Foglalkoztatói term egbizt 4,5% nem 25, 42, 81 |
| 2788 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2789 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0908/2 2009.08.04 BG<br>*      A 03-62-c A fogl terh pénz egbizt |
| 2790 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2791 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-63-c A fogl terh munkanélk állásker pénzb egbizt |
| 2792 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2793 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-79-c A START EXTRA kártyával rend 0%-os |
| 2794 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2795 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-80-c A Pmtv. 8. § esetén 0%-os |
| 2796 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2797 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++0908/2 2009.08.07 BG<br>* Speciális összegzések csak 2009.07.től |
| 2798 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 2799 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2800 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2801 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2802 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 2803 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2804 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 2805 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | **  Számítási algoritmus ÖNREVÍZIÓHOZ:<br>*A0GC0200DA |
| 2806 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                             "Módosított mező |
| 2807 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                             "Módosított mező |
| 2808 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                             "Módosított mező |
| 2809 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés kötelezettség alapjának módosulása<br>*  A0ZZ000001 |
| 2810 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés meghatározásához |
| 2811 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 2812 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2813 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 2814 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * mindig A0AC031A = időszak-tól első nap |
| 2815 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2816 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      mindig A0AC032A = időszak-ig utolsó nap |
| 2817 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adózók száma = Adószámok |
| 2818 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     Helyesbítés, Önellenőrzés, Ismételt önellenőrzés |
| 2819 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 2820 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 2821 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2009.10.09 BG (NESS)<br>*          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 2822 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 2823 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *            Ismételt önellenőrzés |
| 2824 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *            Önellenőrzés |
| 2825 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Helyesbítő |
| 2826 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése SZJA adóazonosító lapszám kezeléshez |
| 2827 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 2828 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Értékek |
| 2829 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 2830 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adóazonosítói lapszámhoz gyűjtések |
| 2831 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Nyugdíjas adószámok gyűjtése |
| 2832 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nyugdíjasok meghatározása |
| 2833 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 2834 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mező1 >= mező2 akkor mező3 0 flag beállítás |
| 2835 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mező1+mező2+mező3+mező4 > 0 akkor 0 flag beállítás |
| 2836 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2837 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2838 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2839 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2840 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2841 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2842 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2843 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2844 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2845 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2846 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2847 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2848 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2849 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2850 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2851 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2852 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2853 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2854 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2855 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2856 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás<br>*++BG 2009.07.08 |
| 2857 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2858 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2859 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2860 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--0908/2 2009.12.09 BG<br>*++2009.11.09 BG (NESS)<br>* mező1-n 0 flag állítás |
| 2861 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2862 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2863 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2864 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2865 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2866 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2867 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2868 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2869 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2870 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2871 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2872 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2873 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2874 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2875 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2876 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2877 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2878 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2879 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2880 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2881 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2882 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                                "0-flag beállítás |
| 2883 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.07.16<br>* Ha mező1 = mező2 akkor  0 flag állítás |
| 2884 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők |
| 2885 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ******************************************************** CSAK ÁFA normál |
| 2886 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mezők feltöltése |
| 2887 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2888 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 72.C. Befizetendő adó összege |
| 2889 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 00C Bevallási időszak -tól |
| 2890 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 2891 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallási időszak -tól |
| 2892 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás jellege |
| 2893 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX = '001' --> 'O'     "önellenőrzés<br>*        ZINDEX > '001' --> 'I'     "ismételt önellenőrzés |
| 2894 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 2895 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *70.B. Előző időszakról beszámítható |
| 2896 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *71.B. Tárgyidőszakbanmegállapított |
| 2897 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *72.B. Befizetendő adó összege |
| 2898 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *73.B. Pü-ileg nem rendezett |
| 2899 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Visszaigényelhető adó összege |
| 2900 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Következő időszakra átvihető |
| 2901 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00F év hó nap |
| 2902 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Visszaigényelhető, |
| 2903 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Következő időszakra átvitt |
| 2904 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 2905 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Függő mezők számítása |
| 2906 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 2907 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00D Kiutalást nem kérek |
| 2908 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 2909 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 2910 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ha 8277 - 8276 > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 2911 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * (8283 - 8282) < 0 akkor minusz a számolt érték |
| 2912 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 8281 - 8280 < 0 akkor minusz a számolt érték |
| 2913 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     Ha a 8273-8272 < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_203-at. |
| 2914 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * önellenörzési pótlék  meghatározása<br>* ABEV 205 számítása a 203 alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 2915 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * időszak meghatározása |
| 2916 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 2917 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 2918 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 2919 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2012.01.06 BG<br>*             L_KAM_VEG = L_KAM_VEG - 15 .<br>*--2012.01.06 BG<br>* pótlék számítás |
| 2920 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.05.18<br>*              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 2921 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*      Ha van érték, korrigálni kell a 203-at. |
| 2922 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 2923 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 2924 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a jelleget: |
| 2925 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 2926 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ESDAT_FLAG-ben megjelölt ABEV azonosító értéke |
| 2927 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a jelleget: |
| 2928 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 2929 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ESDAT_FLAG-ben megjelölt ABEV azonosító értéke |
| 2930 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Speciális M-s számítások adóazonosítóként<br>*  mező0 = ( mező1 - mező2 ) * mező3<br>*  M0CC0406DA |
| 2931 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0CC0408DA<br>*  mező0 = mező1+mező2+.....mező6. |
| 2932 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés kötelezettség alapjának módosulása<br>*  A0ZZ000001 |
| 2933 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 2934 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Szelekciós ABEVAZ feltöltése |
| 2935 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 2936 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 2937 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Speciális számítások |
| 2938 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-40-c A fogl terh nyugdíjbizt összesen (Az 559 sorok "c"... |
| 2939 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2940 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-41-c A fogl terh munkanélk, állásker fiz nyugbizt.... |
| 2941 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2942 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-40-c A fogl terh ápolási díj nyugdíjbizt (A 630sorok... |
| 2943 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2944 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-43-c A magánsz terh nyugdíjj (Az 568,631 sorok "c" .... |
| 2945 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2946 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-44-c A magánsz terh munkanélk, állásker fiz nyug ..... |
| 2947 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2948 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-45-c A magánsz terh GYED, S, T után fiz nyugdíj(.... |
| 2949 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2950 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-46-c A Mnypt tag magánsz terh nyugdíj(.......) |
| 2951 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2952 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-47-c A  Mnypt tag magánsz terh munkanélk,..... |
| 2953 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2954 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-48-cA  Mnypt tag magánsz terh GYED,S,T fiz nyugdíj(.... |
| 2955 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2956 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2957 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-56-c A fogl terh munkanélk állásker fiz term egbizt(.... |
| 2958 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2959 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-57-c A fogl terh pénz egbizt(554. sorok "c" fogl minNEM.... |
| 2960 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2961 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-58-c A fogl terh munkanélk állásker pénzb egbizt(.... |
| 2962 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2963 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-73 -c A fogl. terhelő egbizt.-és munkaerő-piaci jár. term. |
| 2964 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2965 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-74-c A fogl terh egbizt.-és munkaerő-piaci jár munkanélk. |
| 2966 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2967 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 03-75 -c A fogl. terhelő egbizt.-és munkaerő-piaci jár. pénzbeli |
| 2968 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2969 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 03-76-c A fogl terh egbizt.-és munkaerő-piaci jár munkanélk |
| 2970 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2971 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-77 -c A fogl. terhelő egbizt.-és munkaerő-piaci jár. |
| 2972 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2973 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-78-c A fogl terh egbizt.-és munkaerő-piaci jár munkanélk |
| 2974 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2975 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 04-86-c A START-kártyával rend 10%/15%-os (1-es kód:A 694,.... |
| 2976 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2977 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 04-87-c A START-kártyával rend 20%/25%-os (1-es kód: A 695,693. |
| 2978 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2979 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-88-c  A START PLUSZ rend 10%/15%-os (2-es kód:A 654.,692 |
| 2980 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2981 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-89-c  A START PLUSZ rend 20%/255%-os (2-es kód:A 654.,692 |
| 2982 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2983 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-90-c A START EXTRA kártyával rend 0%-os (3,4-es kód:A 691. |
| 2984 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 2985 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-91-c A START EXTRA kártyával rend 10%/15%-os (3-as kód:A 692 |
| 2986 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2987 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2988 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2989 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 2990 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2991 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 2992 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.04.09 BG<br>*                                 C_ABEVAZ_A0BC0014CA        "Forrás 1<br>*                                 C_ABEVAZ_A0BC0015CA        "Forrás 2<br>*++2010.04.09 BG |
| 2993 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 2994 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 2995 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 2996 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 2997 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 2998 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 2999 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés meghatározásához |
| 3000 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 3001 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3002 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3003 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-tól első nap |
| 3004 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3005 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-ig utolsó nap |
| 3006 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adózók száma = Adószámok |
| 3007 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Helyesbítés, Önellenőrzés, Ismételt önellenőrzés |
| 3008 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3009 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3010 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3011 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3012 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *            Ismételt önellenőrzés |
| 3013 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *            Önellenőrzés |
| 3014 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Helyesbítő |
| 3015 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.11.09  Balázs Gábor (Ness) |
| 3016 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2010.11.09  Balázs Gábor (Ness) |
| 3017 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 3018 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.10  Balázs Gábor (Ness) |
| 3019 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mező1 >= mező2 akkor mező3 0 flag beállítás |
| 3020 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ 2010.06.10 RN<br>* ugyanaz, mint GET_NULL_FLAG_INITM, csak a vizsgálandó mező karakteres,<br>* ezért a FIELD_C-t kell figyelni<br>* csak a biztonság kedvéért raktam bele mező1-től mező6-ig, hátha később<br>* lesz ilyen eset |
| 3021 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *-- 2010.06.10 RN<br>*  mező1-n 0 flag állítás |
| 3022 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ 2010.06.10 RN<br>* Ha mező1 = mező2 akkor  0 flag állítás |
| 3023 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése SZJA adóazonosító lapszám kezeléshez |
| 3024 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 3025 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Értékek |
| 3026 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 3027 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adóazonosítói lapszámhoz gyűjtések |
| 3028 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Nyugdíjas adószámok gyűjtése |
| 3029 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 3030 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nyugdíjasok meghatározása |
| 3031 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a jelleget: |
| 3032 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 3033 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ESDAT_FLAG-ben megjelölt ABEV azonosító értéke |
| 3034 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  BEVALLB beolvasás |
| 3035 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adószámonként kell számolni: |
| 3036 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Beolvassuk a módosítandó ABEV-et |
| 3037 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Érték meghatározása |
| 3038 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.09 RN (NESS)<br>* ha negatív lenne az összeg, akkor nem kell beleírni semmit, üresen<br>* kell hagyni, még 0 sem kell bele |
| 3039 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2010.02.09 RN (NESS)<br>*      Hányados kiszámolása |
| 3040 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  BEVALLB beolvasás |
| 3041 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adószámonként kell számolni: |
| 3042 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Beolvassuk a módosítandó ABEV-et |
| 3043 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Érték meghatározása, összegzése |
| 3044 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  BEVALLB beolvasás |
| 3045 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adószámonként kell számolni: |
| 3046 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Beolvassuk a módosítandó ABEV-et |
| 3047 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Érték meghatározása, összegzése |
| 3048 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők |
| 3049 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ******************************************************** CSAK ÁFA normál |
| 3050 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mezők feltöltése |
| 3051 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3052 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 72.C. Befizetendő adó összege |
| 3053 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 00C Bevallási időszak -tól |
| 3054 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3055 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallási időszak -tól |
| 3056 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás jellege |
| 3057 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX = '001' --> 'O'     "önellenőrzés<br>*        ZINDEX > '001' --> 'I'     "ismételt önellenőrzés |
| 3058 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 3059 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *70.B. Előző időszakról beszámítható |
| 3060 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *71.B. Tárgyidőszakbanmegállapított |
| 3061 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *72.B. Befizetendő adó összege |
| 3062 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *73.B. Pü-ileg nem rendezett |
| 3063 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Visszaigényelhető adó összege |
| 3064 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Következő időszakra átvihető |
| 3065 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00F év hó nap |
| 3066 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Visszaigényelhető, |
| 3067 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Következő időszakra átvitt |
| 3068 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3069 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Függő mezők számítása |
| 3070 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3071 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00D Kiutalást nem kérek |
| 3072 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3073 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 3074 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ha 8277 - 8276 > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 3075 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * (8283 - 8282) < 0 akkor minusz a számolt érték |
| 3076 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 8281 - 8280 < 0 akkor minusz a számolt érték |
| 3077 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     Ha a 8273-8272 < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_203-at. |
| 3078 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * önellenörzési pótlék  meghatározása<br>* ABEV 205 számítása a 203 alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 3079 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * időszak meghatározása |
| 3080 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 3081 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 3082 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 3083 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2012.01.06 BG<br>*             L_KAM_VEG = L_KAM_VEG - 15 .<br>*--2012.01.06 BG<br>* pótlék számítás |
| 3084 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.05.18<br>*              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 3085 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*      Ha van érték, korrigálni kell a 203-at. |
| 3086 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 3087 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3088 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők |
| 3089 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ******************************************************** CSAK ÁFA normál |
| 3090 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mezők feltöltése |
| 3091 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3092 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 72.C. Befizetendő adó összege |
| 3093 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 00C Bevallási időszak -tól |
| 3094 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3095 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallási időszak -tól |
| 3096 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás jellege |
| 3097 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX >= '001' --> 'O'     "önellenőrzés |
| 3098 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *-04 lap Önrevízió (ismételt) |
| 3099 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 3100 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *-- 20110418 RN<br>*00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 3101 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *70.B. Előző időszakról beszámítható |
| 3102 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *71.B. Tárgyidőszakbanmegállapított |
| 3103 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *72.B. Befizetendő adó összege |
| 3104 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *73.B. Pü-ileg nem rendezett |
| 3105 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Visszaigényelhető adó összege |
| 3106 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Következő időszakra átvihető |
| 3107 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00F év hó nap |
| 3108 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Visszaigényelhető, |
| 3109 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Következő időszakra átvitt |
| 3110 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3111 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Függő mezők számítása |
| 3112 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3113 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00D Kiutalást nem kérek |
| 3114 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3115 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 3116 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ha 8277 - 8276 > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 3117 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * (8283 - 8282) < 0 akkor minusz a számolt érték |
| 3118 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 8281 - 8280 < 0 akkor minusz a számolt érték |
| 3119 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     Ha a 8273-8272 < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_203-at. |
| 3120 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * önellenörzési pótlék  meghatározása<br>* ABEV 205 számítása a 203 alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 3121 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * időszak meghatározása |
| 3122 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 3123 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 3124 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 3125 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2012.01.06 BG<br>*             L_KAM_VEG = L_KAM_VEG - 15 .<br>*--2012.01.06 BG<br>* pótlék számítás |
| 3126 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.05.18<br>*              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 3127 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*      Ha van érték, korrigálni kell a 203-at. |
| 3128 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 3129 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3130 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Érték keresése |
| 3131 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Érték keresése |
| 3132 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Érték keresése |
| 3133 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Érték keresése |
| 3134 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0BC0375DA<br>*  mező0 = mező1-mező2. |
| 3135 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0BC0376DA<br>*  mező0 = mező1+mező2+.....mező6. |
| 3136 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés meghatározásához |
| 3137 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 3138 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3139 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3140 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-tól első nap |
| 3141 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3142 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-ig utolsó nap |
| 3143 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adózók száma = Adószámok |
| 3144 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Helyesbítés, Önellenőrzés |
| 3145 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3146 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3147 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3148 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3149 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Helyesbítő |
| 3150 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Ismételt önellenőrzés |
| 3151 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3152 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3153 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3154 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3155 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2011.07.11 BG<br>* Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 3156 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Ha ABEV azonosítókon van keresett érték, akkor 0 flag beállítása |
| 3157 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3158 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3159 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3160 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mező1 >= mező2 akkor mező3 0 flag beállítás |
| 3161 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2011.04.08 BG<br>*  Értékmező 2 ha nem iniciális, akkor nézi értékmező 1 szerint a felt.<br>*  FIGYELEM CSAK 0001-ES LAPSZÁMON KERES |
| 3162 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Önellenőrzési pótlék ha önrevízió |
| 3163 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2011.06.09 BG<br>* Ha ABEV azonosítókon van keresett érték, akkor 0 flag beállítása |
| 3164 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ 2011.08.10 BG<br>*  mező1-n 0 flag állítás |
| 3165 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 3166 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Értékek |
| 3167 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 3168 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Nyugdíjas adószámok gyűjtése |
| 3169 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 3170 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nyugdíjasok meghatározása |
| 3171 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 3172 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Szelekciós ABEVAZ feltöltése |
| 3173 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3174 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3175 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Speciális számítások |
| 3176 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-50-c A fogl terh nyugdíjbizt összesen (Az 559.,630. ... |
| 3177 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3178 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-52-c A fogl terh munkanélk, állásker fiz nyugbizt(A 630. .. |
| 3179 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3180 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-53-c A fogl terh ápolási díj nyugdíjbizt (Az 630. sorok ... |
| 3181 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3182 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-53-c A magánsz terh nyugdíjj (Az 568., 607.,631. sorok ... |
| 3183 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3184 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-54-c A megánsz terh munkanélk,állásker nyugdíj (631..... |
| 3185 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3186 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-56-c A magánsz terh GYED, S, T után fiz nyugdíj(A 607..... |
| 3187 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3188 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-57-c A Mnypt tag magánsz terh nyugdíj(Az 559,608,632 .... |
| 3189 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3190 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-47-c A  Mnypt tag magánsz terh munkanélk, állásker nyugdíj.. |
| 3191 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3192 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 02-59-cA  Mnypt tag magánsz terh GYED,S,T fiz nyugdíj (608,... |
| 3193 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3194 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-80 -c A fogl. terhelő egbizt.-és munkaerő-piaci jár. ... |
| 3195 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3196 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 03-74-c A fogl terh egbizt.-és munkaerő-piaci jár munkanélk.. |
| 3197 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3198 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 03-75 -c A fogl. terhelő egbizt.-és munkaerő-piaci jár. pénzbeli |
| 3199 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3200 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 03-76-c A fogl terh egbizt.-és munkaerő-piaci jár munkanélk ... |
| 3201 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3202 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 04-100-c A START-kártyával rend 10%/15%-os (1-es kód:A 694,... |
| 3203 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3204 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     A 04-101-c A START-kártyával rend 20%/25%-os (1-es kód: A 695,693. |
| 3205 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3206 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-102-c  A START PLUSZ rend 10%/15%-os (2-es kód:A 654.,692 |
| 3207 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3208 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-103-c  A START PLUSZ rend 20%/255%-os (2-es kód:A 654.,692 |
| 3209 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3210 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-104-c A START EXTRA kártyával rend 0%-os (3,4-es kód:A 691. |
| 3211 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3212 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      A 04-91-c A START EXTRA kártyával rend 10%/15%-os (3-as kód:A 692 |
| 3213 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a jelleget: |
| 3214 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 3215 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ESDAT_FLAG-ben megjelölt ABEV azonosító értéke |
| 3216 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2011.04.09 BG<br>*  Helyesbítőnél nem kell az önellenőrzési pótlékban sem 0 flag |
| 3217 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk az adózók számát: |
| 3218 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Speciális M-s számítások adóazonosítóként<br>*  M0BC0373DA<br>*  mező0 = mező1+mező2+.....mező6. |
| 3219 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0BC0375DA<br>*  mező0 = mező1-mező2. |
| 3220 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0BC0376DA<br>*  mező0 = mező1+mező2+.....mező6. |
| 3221 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 3222 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Szelekciós ABEVAZ feltöltése |
| 3223 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3224 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3225 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Speciális számítások |
| 3226 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-038 A START kártyával rend 10%-os szociális hozz jár adó (1-es<br>*kód: 643. sor "c") |
| 3227 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3228 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-039 A START kártyával rend 20%-os szociális hozz jár adó (1-es<br>*kód: 644. sor "c") |
| 3229 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3230 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-040 A START  PLUSZ kártyával rend 10%-os szociális hozz jár adó<br>*(2-es kód: 643. sor "c") |
| 3231 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3232 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-041 A START PLUSZ kártyával rend 20%-os szociális hozz jár adó<br>*(2-es kód: 644. sor "c") |
| 3233 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3234 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-042 A START EXTRA kártyával rend 10%-os szociális hozz jár<br>*adó (3-es kód: 643. sor "c") |
| 3235 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3236 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-055 A magánszemélyt terelő nyugdíjjárulék (563,603,611. sorok<br>*"c" fodl min NEM 25,42,81,83,92,93) |
| 3237 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3238 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-56-c A megánsz terh munkanélk,állásker nyugdíj<br>*(611.sorok "c" fogl min 25,42,81) |
| 3239 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3240 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-57-c A magánsz terh GYED, S, T után fiz nyugdíj(A 603.,611. sorok<br>*"c" a fogl min 83, 92, 93) |
| 3241 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3242 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 3243 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 3244 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 3245 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 3246 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 3247 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 3248 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés meghatározásához |
| 3249 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 3250 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3251 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3252 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-tól első nap |
| 3253 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3254 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-ig utolsó nap |
| 3255 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adózók száma = Adószámok |
| 3256 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Helyesbítés, Önellenőrzés |
| 3257 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3258 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3259 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3260 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3261 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Helyesbítő |
| 3262 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Ismételt önellenőrzés |
| 3263 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3264 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3265 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3266 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3267 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2011.07.11 BG<br>* Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 3268 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ** Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>** vagy mező5 ne 0 akkor 0 flag beállítás |
| 3269 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>** vagy mező5 nem üres (karakteres) akkor 0 flag beállítás |
| 3270 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Önellenőrzési pótlék ha önrevízió |
| 3271 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2012.03.09 BG<br>*  mező1-n 0 flag állítás |
| 3272 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 3273 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Értékek |
| 3274 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 3275 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Nyugdíjas adószámok gyűjtése |
| 3276 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 3277 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nyugdíjasok meghatározása |
| 3278 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a jelleget: |
| 3279 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 3280 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők |
| 3281 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ******************************************************** CSAK ÁFA normál |
| 3282 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mezők feltöltése |
| 3283 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3284 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 72.C. Befizetendő adó összege |
| 3285 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 00C Bevallási időszak -tól |
| 3286 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3287 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallási időszak -tól |
| 3288 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás jellege |
| 3289 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX >= '001' --> 'O'     "önellenőrzés |
| 3290 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *-04 lap Önrevízió (ismételt) |
| 3291 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 3292 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *-- 20110418 RN<br>*00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 3293 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *70.B. Előző időszakról beszámítható |
| 3294 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *71.B. Tárgyidőszakbanmegállapított |
| 3295 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *72.B. Befizetendő adó összege |
| 3296 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *74.B. Következő időszakra átvihető |
| 3297 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00F év hó nap |
| 3298 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Visszaigényelhető, |
| 3299 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Következő időszakra átvitt |
| 3300 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3301 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Függő mezők számítása |
| 3302 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3303 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00D Kiutalást nem kérek |
| 3304 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3305 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1265 2012.02.20 BG<br>*  3077, és 3079 számítása |
| 3306 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Van érték |
| 3307 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Meg kell vizsgálni a 23956 értékét |
| 3308 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3309 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort tötölni kell |
| 3310 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3311 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort tötölni kell |
| 3312 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 3313 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ha 8277 - 8276 > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 3314 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * (8283 - 8282) < 0 akkor minusz a számolt érték |
| 3315 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 8281 - 8280 < 0 akkor minusz a számolt érték |
| 3316 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     Ha a 8273-8272 < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_203-at. |
| 3317 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * önellenörzési pótlék  meghatározása<br>* ABEV 205 számítása a 203 alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 3318 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * időszak meghatározása |
| 3319 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 3320 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 3321 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 3322 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2012.01.10 BG<br>*             L_KAM_VEG = L_KAM_VEG - 15 .<br>*--2012.01.10 BG<br>* pótlék számítás |
| 3323 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++BG 2009.05.18<br>*              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 3324 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*      Ha van érték, korrigálni kell a 203-at. |
| 3325 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++ BG 2009.06.17<br>*  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 3326 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3327 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 3328 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3329 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3330 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 3331 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 3332 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 3333 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Bevallás gyakorisága |
| 3334 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők |
| 3335 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ******************************************************** CSAK ÁFA normál |
| 3336 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mezők feltöltése |
| 3337 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3338 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 3339 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1765 #01.<br>*         L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3340 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * 00C Bevallási időszak -tól |
| 3341 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3342 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallási időszak -ig |
| 3343 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás jellege |
| 3344 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 3345 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 3346 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 3347 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 3348 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 3349 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 3350 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 3351 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *86.B. Következő időszakra átvihető követelés összege |
| 3352 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00F év hó nap |
| 3353 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 3354 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3355 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3356 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *Következő időszakra átvitt |
| 3357 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3358 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3359 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3360 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Függő mezők számítása |
| 3361 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3362 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *00D Kiutalást nem kérek |
| 3363 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3364 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  A0AE005A, és A0AE006A számítása |
| 3365 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Van érték |
| 3366 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Meg kell vizsgálni a A0AE004A értékét |
| 3367 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3368 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort tötölni kell |
| 3369 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3370 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort tötölni kell |
| 3371 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 3372 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Értékhatár |
| 3373 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1365 #17.<br>*  Hónap kezelése |
| 3374 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1365 #17.<br>*    Összeg meghatározása adószámonként, számlánként |
| 3375 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1365 #16.<br>*      Csak a hónapon belül kell összesíteni |
| 3376 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1365 #3.<br>*      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 3377 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1365 #3.<br>*      ezt a sort kell módosítani! |
| 3378 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Létrehozás adószámos ABEV |
| 3379 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    M-es főlap egyéb számított mezők töltése töltése |
| 3380 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 3381 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Összeg meghatározása adószámonként, számlánként |
| 3382 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 3383 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>****<br>*++1365 2013.01.22 Balázs Gábor (Ness) |
| 3384 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 3385 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 3386 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0JD0001CA-at. |
| 3387 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0JD0002CA számítása a A0JD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 3388 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * időszak meghatározása |
| 3389 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 3390 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás kezdeti dátuma |
| 3391 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 3392 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * pótlék számítás |
| 3393 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 3394 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Ha van érték, korrigálni kell a A0JD0001CA-at. |
| 3395 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 3396 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap |                               "0-flag beállítás |
| 3397 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * N - Negyedéves |
| 3398 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3399 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3400 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 3401 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 3402 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 3403 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Bevallás gyakorisága |
| 3404 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1765 #07.<br>* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3405 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * ezt a sort kell módosítani! |
| 3406 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 3407 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    IDŐSZAK záró dátuma |
| 3408 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 3409 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Bevallás gyakorisága |
| 3410 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 3411 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 3412 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 3413 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 3414 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 3415 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 3416 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1365 #4.<br>*  Hónap feltöltése: |
| 3417 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Vevő neve: |
| 3418 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1765 #26.<br>*    Szállító neve |
| 3419 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1365 #21.<br>*    DUMMY_R-es rekordon a field_c-ben van név |
| 3420 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      M0AC007A <- DUMMY_R FIELD_C mező |
| 3421 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Módosítandó ABEV beolvasása |
| 3422 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ezt a sort kell módosítani! |
| 3423 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Létrehozás adószámos ABEV |
| 3424 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk a forrás sort először Adóazonosítóval ha nincs akkor a nélkül |
| 3425 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Módosítandó ABEV beolvasása |
| 3426 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ezt a sort kell módosítani! |
| 3427 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Létrehozás adószámos ABEV |
| 3428 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha a ABEV C típus |
| 3429 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Speciális M-s számítások adóazonosítóként<br>*  M0BC0370DA M 02-370 d Összevont adóalap ( a 360-369. sorok "D"összege)<br>*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 3430 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * M0BC0372DA<br>* mező0 = mező1-mező2. |
| 3431 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M0BC0373DA<br>*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 3432 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  BEVALLB beolvasás |
| 3433 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adószámonként kell számolni: |
| 3434 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Beolvassuk a módosítandó ABEV-et |
| 3435 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Érték meghatározása, összegzése |
| 3436 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 3437 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Szelekciós ABEVAZ feltöltése |
| 3438 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3439 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3440 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Speciális számítások |
| 3441 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-081 A START kártyával rend 10%-os szociális hozz jár adó<br>*(1-es kód: 643. sor ""c"") |
| 3442 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3443 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-039 A START kártyával rend 20%-os szociális hozz jár adó (1-es<br>*kód: 644. sor "c") |
| 3444 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3445 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-040 A START  PLUSZ kártyával rend 10%-os szociális hozz jár adó<br>*(2-es kód: 643. sor "c") |
| 3446 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3447 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-041 A START PLUSZ kártyával rend 20%-os szociális hozz jár adó<br>*(2-es kód: 644. sor "c") |
| 3448 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3449 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 02-042 A START EXTRA kártyával rend 10%-os szociális hozz jár<br>*adó (3-es kód: 643. sor "c") |
| 3450 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3451 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-091 A s/zak/zakképzésettségen nem igénylő munkakörben fogl<br>*12,5%-os szocho (1-es kód:679.sor "c") |
| 3452 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3453 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-092 A 180 napnál több munkaviszonnyal rend 25 év alatti<br>*12,5% szocho (7-es kód:679.sor "c") |
| 3454 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3455 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-093 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679. sor "c") |
| 3456 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3457 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-094 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 679. sor "c") |
| 3458 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3459 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-095 A szabad váll zónában működő váll 12,5% szocho<br>*(11-es kód:679. sor "c") |
| 3460 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3461 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-055 A magánszemélyt terelő nyugdíjjárulék (563,603,611. sorok<br>*"c" fodl min NEM 25,42,81,83,92,93) |
| 3462 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3463 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-56-c A megánsz terh munkanélk,állásker nyugdíj<br>*(611.sorok "c" fogl min 25,42,81) |
| 3464 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3465 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *A 03-57-c A magánsz terh GYED, S, T után fiz nyugdíj(A 603.,611. sorok<br>*"c" a fogl min 83, 92, 93) |
| 3466 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Feltétel feltöltése |
| 3467 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Önellenőrzés meghatározásához |
| 3468 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 3469 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3470 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    ezt a sort kell módosítani! |
| 3471 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-tól első nap |
| 3472 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Negyedéves |
| 3473 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      időszak-ig utolsó nap |
| 3474 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Adózók száma = Adószámok |
| 3475 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Helyesbítés, Önellenőrzés |
| 3476 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3477 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3478 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3479 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3480 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Helyesbítő |
| 3481 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Ismételt önellenőrzés |
| 3482 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *        Csak önellenőrzésénél |
| 3483 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3484 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3485 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *          Van érték: |
| 3486 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--2011.07.11 BG<br>* Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 3487 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha mező1 >= mező2 akkor mező3 0 flag beállítás |
| 3488 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  mező1-n 0 flag állítás |
| 3489 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *++1308 2013.03.08<br>* Önellenőrzési pótlék ha önrevízió |
| 3490 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 3491 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Értékek |
| 3492 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *   Dialógus futás biztosításhoz |
| 3493 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Nyugdíjas adószámok gyűjtése |
| 3494 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 3495 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Nyugdíjasok meghatározása |
| 3496 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Meghatározzuk a jelleget: |
| 3497 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 3498 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Módosítandó ABEV beolvasása |
| 3499 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  ezt a sort kell módosítani! |
| 3500 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Létrehozás adószámos ABEV |
| 3501 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha a ABEV C típus |
| 3502 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Összegzendő mezők feltöltéséhez |
| 3503 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Ha önrevízió |
| 3504 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 3505 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 3506 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *    Nem kell a rekord. |
| 3507 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 3508 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  BEVALLB beolvasás |
| 3509 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Adószámonként kell számolni: |
| 3510 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *--1608 #01. 2015.02.08<br>*   Beolvassuk a módosítandó ABEV-et |
| 3511 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *      Érték meghatározása, összegzése |
| 3512 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Aktuális bevallás olvasása |
| 3513 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | * Előző időszak beolvasása |
| 3514 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Különbözet kiszámolása |
| 3515 | src/#zak#functions.fugr.#zak#lfunctionsf01.abap | *  Számított mező módosítása |
| 3516 | src/#zak#functions.fugr.#zak#lfunctionsf02.abap | * Meghatározzuk az ABEV mező típusát |
| 3517 | src/#zak#functions.fugr.#zak#lfunctionsf02.abap | *       Vezető 0-ák feltöltése |
| 3518 | src/#zak#functions.fugr.#zak#lfunctionsf02.abap | *       Hossz beállítása |
| 3519 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Utolsó rekordnál |
| 3520 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Rekordok sorrendjének megfordítása<br>*++S4HANA#01.<br>*  DESCRIBE TABLE I_BTYPE_LOCAL LINES L_COUNTER. |
| 3521 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * BTYPE_FROM érvénessége |
| 3522 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Mi van ha nincs ilyen? |
| 3523 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Nyomtatvány adatok beolvasása abevhez |
| 3524 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Excel formátum |
| 3525 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Nyomtatvány adatok beolvasása abevhez |
| 3526 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--S4HANA#01.<br>*   Amit lehet kitölt az Excelhez<br>*++S4HANA#01.<br>*    I_LINES_TMP-BUKRS       = W_/ZAK/BEVALLO-BUKRS. |
| 3527 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Nyomtatvány adatok beolvasása abevhez |
| 3528 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   ELMENTI AZ ELSő SORT |
| 3529 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   1 . sor mentése |
| 3530 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   2. tétel feldolgozása |
| 3531 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--S4HANA#01.<br>*   2 . sor mentése |
| 3532 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Adónem megnevezése - forrás |
| 3533 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Adónem megnevezése - cél |
| 3534 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Adatszerkezet beolvasása |
| 3535 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++ BG 2006.04.20 Útvonal meghatározás |
| 3536 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Adatszerkezet beolvasása |
| 3537 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *  ha hiba van akkor állítani kell a hibakódot |
| 3538 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++ BG 2006.04.20 Útvonal meghatározás |
| 3539 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Nyomtatvány adatok beolvasása abevhez |
| 3540 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Forrás adónem |
| 3541 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Cél adónem |
| 3542 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * bizonylatszám számkör |
| 3543 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *Range definiálása mezo nevek gyujtéséhez |
| 3544 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2007.04.23 Az önellenőrzés adónemek a /ZAK/ADONEM<br>*táblában az ONREL mező által megjelöltek:<br>*++S4HANA#01.<br>*  REFRESH R_ONELL_ADONEM. |
| 3545 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Meghatározzuk az önellenőrzéses pótlék ABEV azonosító(k)at. |
| 3546 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2007.04.23<br>*                AND ADONEM  EQ C_ONELL_ADONEM.<br>*++BG 2008.03.11<br>*Az adónemeket az önrevíziós adónemeknél kell keresni<br>*                AND ADONEM  IN R_ONELL_ADONEM. |
| 3547 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Összegezzük a FIELD_NR mezőket. |
| 3548 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Ha van összeg, akkor könyvelési adatok összeállítása |
| 3549 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Beolvassuk a beállításokat |
| 3550 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Könyvelési fájl feltöltése |
| 3551 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Megváltozott (Lehel Attila): beadás hónapjának utolsó napja legyen |
| 3552 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Vállalat |
| 3553 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Fejszöveg<br>*++BG 2006/08/31<br>* Bizonylat dátum lapján kerül feltöltésre (Lehel Attila) |
| 3554 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Számla1 (tartozik) |
| 3555 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--BG 2006/07/19<br>* Számla2 (követel) |
| 3556 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2008/02/22<br>* Költséghely töltése |
| 3557 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Szöveg |
| 3558 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * sorok mentése |
| 3559 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *Range definiálása mezo nevek gyujtéséhez |
| 3560 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Meghatározzuk az önellenőrzéses pótlék ABEV azonosító(k)at. |
| 3561 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Összegezzük a FIELD_NR mezőket. |
| 3562 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Ha van összeg, akkor könyvelési adatok összeállítása |
| 3563 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Beolvassuk a beállításokat |
| 3564 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Könyvelési fájl feltöltése |
| 3565 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Megváltozott (Lehel Attila): beadás hónapjának utolsó napja legyen |
| 3566 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Vállalat |
| 3567 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Könyvelési dátum |
| 3568 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Hónap |
| 3569 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Fejszöveg<br>*++BG 2006/08/31<br>* Bizonylat dátum lapján kerül feltöltésre (Lehel Attila) |
| 3570 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Számla1 (tartozik) |
| 3571 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--BG 2006/07/19<br>* Számla2 (követel) |
| 3572 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Fájl név meghatározás<br>*++BG 2007.05.17<br>*  CONCATENATE $W_BEVALLO-BUKRS $W_BEVALLO-BTYPE TEXT-002<br>*         INTO L_DEF_FILENAME SEPARATED BY '_'. |
| 3573 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Adatszerkezet beolvasása |
| 3574 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++ BG 2006.04.20 Útvonal meghatározás |
| 3575 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2008.03.26<br>* Adónemek gyűjtése: ÁFA-nál melyik adónemre történt<br>* különbség gyűjtés<br>*++S4HANA#01.<br>*  RANGES LR_ADONEM FOR /ZAK/BEVALLB-ADONEM. |
| 3576 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Hónap utolsó napja |
| 3577 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * AFA-nal és onrevizonal előző időszak is kell |
| 3578 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Esedékességi dátum meghatározása |
| 3579 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * ABEV mező alapján esedékességi dátum meghatározása |
| 3580 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   ABEV mező értékének meghatározása |
| 3581 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Megvan a mező értékét átmásoljuk az ESDAT-ba |
| 3582 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2008.03.26<br>* Adatok feldolgozása<br>*++S4HANA#01.<br>*  REFRESH LR_ADONEM. |
| 3583 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *    Ha normál időszak akkor ADONEM-et kell figyelni. |
| 3584 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Adónem adatok meghatározása<br>*     Normál időszak |
| 3585 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *       Nincs beállítás a /ZAK/ADONEM táblában! (Vállalat: &, adónem: & ). |
| 3586 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Önrevíziós időszak |
| 3587 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *       Nincs beállítás a /ZAK/ADONEM táblában! (Vállalat: &, adónem: & ). |
| 3588 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Esedékességi dátum kiszámítása |
| 3589 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2007.10.04<br>*     Vállalat forgatás |
| 3590 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Nem konvertálunk BTYPE-ot |
| 3591 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Ha be van jelölve a beállításokban az előjel fordítás |
| 3592 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Különbség képzés csak AFA-nal |
| 3593 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Normál összeget könyvelünk a folyószámlára |
| 3594 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2006/06/20<br>*  Ha az összeg kisebb mint 0, akkor ZLOCK flag beállítása |
| 3595 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++0001 BG 2008.05.13 /ZAK/POST_ADONSZA<br>* A folyószámlára írást át kellett alakítani, mert ha<br>* nem létezett az adónem, akkor kiadta az 'E' üzenetet<br>* de az addigi tételeket már ráírta a folyószámlára |
| 3596 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2008.03.26<br>* Ha ÁFA akkor meg kell határozni, hogy minden adónemre történt e<br>* különbség képzés.<br>* Ez az eset akkor fordul elő, ha fizetendő és visszaigénylő pozíció<br>* között átfordulás van, de a pénzügyileh nem rendezett miatt mégis<br>* 0 lesz a ténylegesen visszaigényelhető ÁFA. Ebben az esetben nem<br>* kezeltük megfelelően az adófolyószámlát. |
| 3597 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Összegyűjtjük az adónemeket.<br>*++S4HANA#01.<br>*    REFRESH LI_ABEV_ADON. |
| 3598 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *       Nincs beállítás a /ZAK/ADONEM táblában! (Vállalat: &, adónem: & ). |
| 3599 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Esedékességi dátum kiszámítása |
| 3600 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Vállalat forgatás |
| 3601 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *     Konvertálni kell a BTYPE-ot |
| 3602 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *    Ha be van jelölve a beállításokban az előjel fordítás |
| 3603 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Különbség képzés csak AFA-nal |
| 3604 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *  Ha az összeg kisebb mint 0, akkor ZLOCK flag beállítása |
| 3605 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Normál időszaknál BEVALLO dátum alapján |
| 3606 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Hónap utolsó napja |
| 3607 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Következő hó nap első napja |
| 3608 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Önrevíziónál az esedékességi dátum szerint |
| 3609 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++2007.07.23 BG(FMC) Esedékességi dátum konvertálása következő<br>*munkanapra |
| 3610 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Hiba az esedékességi dátum következő munkanapra konvertálásánál!(&) |
| 3611 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Önrevíziós BTYPE meghatározása |
| 3612 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--S4HANA#01.<br>*   Meg kell keresni az érvényes időszakban az önrevíziós BTYPE-ot |
| 3613 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--S4HANA#01.<br>*   Ha nem találunk rekordot akkor a DISP BTYPE kell |
| 3614 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *--BG 2007.05.22<br>* Meg kell határozni az előző időszak ABEV azonosítót |
| 3615 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *++BG 2008.03.26<br>* Az adónemet eltároljuk |
| 3616 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | *   Itt már nem nagyon tudok mit csinálmi |
| 3617 | src/#zak#functions.fugr.#zak#lfunctionsf03.abap | * Adatszerkezet beolvasása |
| 3618 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * SZJA A header előállítása |
| 3619 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * mezők kiolvasása BEVALLO_ALV-ből |
| 3620 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * SZJA A footer előállítása |
| 3621 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     kiolvassa a mezőértéket IT_BEVALLO_ALV |
| 3622 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *         Nyomtatvány azonosító |
| 3623 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *         Verzió |
| 3624 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *         ABEV kód |
| 3625 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *         Nyomtatvány azonosító |
| 3626 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *         Verzió |
| 3627 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *         ABEV kód |
| 3628 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++0908 2009.02.10 BG<br>*       Először fut elmentjük a HEAD értékét. |
| 3629 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *       az XML sor összeállítása<br>*       CONCATENATE $HEAD $VALUE LINDA INTO XML_LINE. |
| 3630 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *ABEV azonosító átalakítása |
| 3631 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3632 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++0808 BG 2008.02.07<br>*  Beállítás beolvasása |
| 3633 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3634 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++BG 2008.03.11<br>*  Kivesszük mert önrevíziós oszlopot nem fogjuk átadani<br>*                                                 AND<br>*             NOT IT_BEVALLO_ALV-FIELD_ON IS INITIAL ).<br>*--BG 2008.03.11<br>*--0808 BG 2008.02.07 |
| 3635 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *--BG 2006/12/06<br>*++ BG 2008.03.10<br>*  0-ás mező ami kell |
| 3636 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++0001 2007.01.03 BG (FMC)<br>* 0001 ++ CST 2006.05.27<br>* Letöltés... |
| 3637 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Hiba a & fájl letöltésénél. |
| 3638 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * SZJA M header előállítása |
| 3639 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * mezők kiolvasása BEVALLO_ALV-ből |
| 3640 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * 0608A footer előállítása |
| 3641 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3642 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * Beállítjuk a tábla olvasás -tól, -ig értékét, hogy szűkítsük a<br>* beolvasás tartományát. |
| 3643 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Az index TO értékét 10 lapos intervallumra állítjuk be |
| 3644 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3645 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *--BG 2006/12/06<br>*++ BG 2007.06.22<br>*  0-ás mező ami kell |
| 3646 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * XML vége (end) |
| 3647 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *Vállalati bevallás head |
| 3648 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *Nyomtatvány vége |
| 3649 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *Egyéni bevallás head |
| 3650 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *Meghatározzuk a nyomtatványt |
| 3651 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3652 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *  Beállítás beolvasása |
| 3653 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++12K79 2013.01.30<br>*   Bevallás típusonként más a név! |
| 3654 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3655 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Van érték vagy 0-ás mező és kell |
| 3656 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * Adószámonként szétszedjük |
| 3657 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Adóazonosítónak meg kell egyeznie az<br>*     ABEV kód értékével egyébként ABEV hiba!<br>*      lw_tab_ms-adoazon = l_adoazon.<br>*--12K79 2013.01.30 |
| 3658 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Név öszeállítása |
| 3659 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Név öszeállítása |
| 3660 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Név öszeállítása |
| 3661 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Név öszeállítása |
| 3662 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Név öszeállítása |
| 3663 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Hiba a & fájl letöltésénél. |
| 3664 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++1365 #9.<br>* Érték figyelés ezen tartományon kívűl |
| 3665 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3666 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *--1565 #02.<br>*  Beállítás beolvasása |
| 3667 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3668 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++1665 #08.<br>*  M-es ABEV azonosítóknál 0-ás flag feltöltés |
| 3669 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Van érték vagy 0-ás mező és kell |
| 3670 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * Adószámonként szétszedjük |
| 3671 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++1365 #9.<br>*   Érték vizsgálat bármelyik nem fő rész abev mezőre |
| 3672 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Adóazonosítónak meg kell egyeznie az<br>*     ABEV kód értékével egyébként ABEV hiba! |
| 3673 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *      lm_get_adoazon '0A0001C001A'<br>*                     lw_tab_ms-adoazon.<br>*     Név öszeállítása<br>*++1565 #02.<br>*      LM_GET_NAME '0A0001C007A' |
| 3674 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *++1365 #9.<br>* Érték figyelés ezen tartományon kívűl |
| 3675 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3676 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *  Beállítás beolvasása |
| 3677 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3678 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Van érték vagy 0-ás mező és kell<br>*++1408 #04. 2014.05.09<br>*    ELSEIF NOT it_bevallo_alv-field_nr IS INITIAL OR<br>*           NOT it_bevallo_alv-null_flag IS INITIAL. |
| 3679 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *  0-ás mező ami kell |
| 3680 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * Adószámonként szétszedjük |
| 3681 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Érték vizsgálat bármelyik nem fő rész abev mezőre |
| 3682 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Adóazonosítónak meg kell egyeznie az<br>*     ABEV kód értékével egyébként ABEV hiba! |
| 3683 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *--2408 #01.<br>*     Név öszeállítása |
| 3684 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *--2108 #02.<br>*     Név öszeállítása |
| 3685 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3686 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *  Beállítás beolvasása |
| 3687 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Bevallás típusonként más a név! |
| 3688 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3689 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Van érték vagy 0-ás mező és kell |
| 3690 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | * Adószámonként szétszedjük |
| 3691 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Adóazonosítónak meg kell egyeznie az<br>*     ABEV kód értékével egyébként ABEV hiba! |
| 3692 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Név öszeállítása |
| 3693 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *     Negatív előjel figyelése |
| 3694 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *  Beállítás beolvasása |
| 3695 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   APEH abevaz konvertálás |
| 3696 | src/#zak#functions.fugr.#zak#lfunctionsf04.abap | *   Van érték vagy 0-ás mező és kell |
| 3697 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *   Ha elértük a főkönyvi könyvelés bizonylatot, akkor kilépés |
| 3698 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *     Közös azonosító váltás ha a típus M-Normál számla |
| 3699 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *     SZAMLASZA TYPE /ZAK/SZAMLASZA,<br>*     SZAMLASZ  TYPE /ZAK/SZAMLASZ,<br>*     POSNN     TYPE POSNR_NACH,<br>*     VBTYP     TYPE VBTYP_N,<br>*     SZLATIP   TYPE /ZAK/SZLATIP,<br>*     Feltöltjük a csoport adatokat |
| 3700 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *   További tételek feldolgozása |
| 3701 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *  Ahol nem önmaga |
| 3702 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *   Ha számla típus |
| 3703 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *   Ha nem számla típus tovább keressük |
| 3704 | src/#zak#functions.fugr.#zak#lfunctionsf05.abap | *   Egymásra mutató referenciák (biz: &/&/&)! Futás megs/zak/zakítva! |
| 3705 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *Speciális M-s számítások adóazonosítóként<br>*M0BC0371DA M 02-371 d Összevont adóalap ( a 360-370. sorok "D"összege) |
| 3706 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *M0BC0373DA M 02-373 d Az adóelőleg alapja (a 371-372. sorok különbözete)<br>* mező0 = mező1-mező2. |
| 3707 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *M0BC0374DA M 02-374 d A 371. sorból bérnek minősülő összeg<br>*            (360-363. "D", 369-370 sor "A" adatai)<br>*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 3708 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 3709 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Szelekciós ABEVAZ feltöltése |
| 3710 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3711 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    ezt a sort kell módosítani! |
| 3712 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Speciális számítások |
| 3713 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-081 A START kártyával rend 10%-os szociális hozz jár adó<br>*(1-es kód: 643. sor ""c"") |
| 3714 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3715 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 02-039 A START kártyával rend 20%-os szociális hozz jár adó (1-es<br>*kód: 644. sor "c") |
| 3716 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3717 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 02-040 A START  PLUSZ kártyával rend 10%-os szociális hozz jár adó<br>*(2-es kód: 643. sor "c") |
| 3718 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3719 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 02-041 A START PLUSZ kártyával rend 20%-os szociális hozz jár adó<br>*(2-es kód: 644. sor "c") |
| 3720 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3721 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 02-042 A START EXTRA kártyával rend 10%-os szociális hozz jár<br>*adó (3-es kód: 643. sor "c") |
| 3722 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3723 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-091 A s/zak/zakképzésettségen nem igénylő munkakörben fogl<br>*12,5%-os szocho (1-es kód:679.sor "c") |
| 3724 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3725 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-092 A 180 napnál több munkaviszonnyal rend 25 év alatti<br>*12,5% szocho (7-es kód:679.sor "c") |
| 3726 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3727 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-093 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679. sor "c") |
| 3728 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3729 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-094 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 679. sor "c") |
| 3730 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3731 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-095 A szabad váll zónában működő váll 12,5% szocho<br>*(11-es kód:679. sor "c") |
| 3732 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3733 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 04-096 A nemzeti felsőokt. Doktori képzés 12,5% szocho kedvezmény<br>*(13-as kód:678.sor "c") |
| 3734 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3735 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *04-100 A magánszemélyt terelő nyugdíjjárulék<br>*(563,604,611. sorok ""c"" fodl min NEM 25,42,81,83,9 |
| 3736 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3737 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-56-c A megánsz terh munkanélk,állásker nyugdíj<br>*(611.sorok "c" fogl min 25,42,81) |
| 3738 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3739 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *A 03-57-c A magánsz terh GYED, S, T után fiz nyugdíj(A 603.,611. sorok<br>*"c" a fogl min 83, 92, 93) |
| 3740 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Feltétel feltöltése |
| 3741 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Önellenőrzés meghatározásához |
| 3742 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 3743 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3744 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    ezt a sort kell módosítani! |
| 3745 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      időszak-tól első nap |
| 3746 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * Negyedéves |
| 3747 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      időszak-ig utolsó nap |
| 3748 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Adózók száma = Adószámok |
| 3749 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++1408 #02. 2014.03.05 BG<br>*      Helyesbítés, Önellenőrzés |
| 3750 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Csak önellenőrzésénél |
| 3751 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3752 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3753 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          Van érték: |
| 3754 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          Helyesbítő |
| 3755 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Ismételt önellenőrzés |
| 3756 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Csak önellenőrzésénél |
| 3757 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 3758 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 3759 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *          Van érték: |
| 3760 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  mező1-n 0 flag állítás |
| 3761 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * Önellenőrzési pótlék ha önrevízió |
| 3762 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 3763 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Értékek |
| 3764 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *   Dialógus futás biztosításhoz |
| 3765 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Nyugdíjas adószámok gyűjtése |
| 3766 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 3767 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Nyugdíjasok meghatározása |
| 3768 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *--S4HANA#01.<br>* Érték figyelés ezen tartományon kívűl<br>*++S4HANA#01.<br>*   RANGES lr_abevaz_value FOR /zak/analitika-abevaz. |
| 3769 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *     Negatív előjel figyelése |
| 3770 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Beállítás beolvasása |
| 3771 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *   APEH abevaz konvertálás |
| 3772 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *   Van érték vagy 0-ás mező és kell |
| 3773 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * N - Negyedéves |
| 3774 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3775 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort kell módosítani! |
| 3776 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 3777 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    IDŐSZAK záró dátuma |
| 3778 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 3779 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Bevallás gyakorisága |
| 3780 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | ************************************************************************<br>* Speciális abev mezők<br>******************************************************** CSAK ÁFA normál |
| 3781 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*   REFRESH lr_abevaz. |
| 3782 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort kell módosítani! |
| 3783 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 3784 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3785 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * 00C Bevallási időszak -tól |
| 3786 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * Negyedéves |
| 3787 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *00C Bevallási időszak -ig |
| 3788 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *00C Bevallás jellege |
| 3789 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 3790 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 3791 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 3792 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 3793 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 3794 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 3795 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 3796 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *86.B. Következő időszakra átvihető követelés összege |
| 3797 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *00F év hó nap |
| 3798 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 3799 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3800 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3801 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *Következő időszakra átvitt |
| 3802 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3803 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++1765 #01.<br>*          L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3804 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3805 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*   REFRESH lr_abevaz. |
| 3806 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort kell módosítani! |
| 3807 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *00D Kiutalást nem kérek |
| 3808 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3809 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  A0AE005A, és A0AE006A számítása<br>*++S4HANA#01.<br>*   REFRESH lr_abevaz. |
| 3810 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Van érték |
| 3811 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Meg kell vizsgálni a A0AE004A értékét |
| 3812 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort kell módosítani! |
| 3813 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort tötölni kell |
| 3814 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort kell módosítani! |
| 3815 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort tötölni kell |
| 3816 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 3817 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Értékhatár |
| 3818 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*     REFRESH lr_monat. |
| 3819 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Összeg meghatározása adószámonként, számlánként |
| 3820 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Csak a hónapon belül kell összesíteni |
| 3821 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Értékhatár meghatározása<br>*    Összeg visszaírása adószámonként |
| 3822 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 3823 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      ezt a sort kell módosítani! |
| 3824 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *        Létrehozás adószámos ABEV |
| 3825 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    M-es főlap egyéb számított mezők töltése töltése |
| 3826 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 3827 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Összeg meghatározása adószámonként, számlánként |
| 3828 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 3829 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 3830 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 3831 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 3832 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 3833 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0JD0001CA-at. |
| 3834 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0JD0002CA számítása a A0JD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 3835 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * időszak meghatározása |
| 3836 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 3837 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * pótlék számítás kezdeti dátuma |
| 3838 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 3839 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * pótlék számítás |
| 3840 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 3841 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      Ha van érték, korrigálni kell a A0JD0001CA-at. |
| 3842 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 3843 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap |                               "0-flag beállítás |
| 3844 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 3845 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 3846 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 3847 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 3848 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 3849 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 3850 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*   REFRESH lr_monat. |
| 3851 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Vevő neve: |
| 3852 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *--1765 #26.<br>*    Szállító neve |
| 3853 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 3854 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *      M0AC007A <- DUMMY_R FIELD_C mező |
| 3855 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *--S4HANA#01.<br>* Érték figyelés ezen tartományon kívűl<br>*++S4HANA#01.<br>*   RANGES lr_abevaz_value FOR /zak/analitika-abevaz. |
| 3856 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *     Negatív előjel figyelése |
| 3857 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Beállítás beolvasása |
| 3858 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *   APEH abevaz konvertálás |
| 3859 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 3860 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *   Van érték vagy 0-ás mező és kell<br>*++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás<br>*     ELSEIF NOT IT_BEVALLO_ALV-FIELD_NR IS INITIAL OR<br>*            NOT IT_BEVALLO_ALV-NULL_FLAG IS INITIAL. |
| 3861 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 3862 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 3863 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 3864 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3865 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | * ezt a sort kell módosítani! |
| 3866 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    IDŐSZAK kezdő dátuma |
| 3867 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    IDŐSZAK záró dátuma |
| 3868 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Helyesbítés |
| 3869 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Összegzendő mezők feltöltéséhez |
| 3870 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Ha önrevízió |
| 3871 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 3872 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 3873 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *    Nem kell a rekord. |
| 3874 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 3875 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Meghatározzuk a jelleget: |
| 3876 | src/#zak#functions.fugr.#zak#lfunctionsf14.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 3877 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3878 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * ezt a sort kell módosítani! |
| 3879 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    IDŐSZAK kezdő dátuma |
| 3880 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    IDŐSZAK záró dátuma |
| 3881 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Helyesbítés |
| 3882 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | ************************************************************************<br>* Speciális abev mezők |
| 3883 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | ******************************************************** CSAK ÁFA normál |
| 3884 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH LR_ABEVAZ. |
| 3885 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * ezt a sort kell módosítani! |
| 3886 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 3887 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *++1765 #01.<br>*         L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3888 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * 00C Bevallási időszak -tól |
| 3889 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * Negyedéves |
| 3890 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *00C Bevallási időszak -ig |
| 3891 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *00C Bevallás jellege |
| 3892 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 3893 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 3894 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 3895 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 3896 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 3897 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 3898 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 3899 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *86.B. Következő időszakra átvihető követelés összege |
| 3900 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *00F év hó nap |
| 3901 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 3902 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *++1765 #01.<br>*         L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3903 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *++1765 #01.<br>*         L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3904 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *Következő időszakra átvitt |
| 3905 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *++1765 #01.<br>*         L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3906 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *++1765 #01.<br>*         L_UPD = 'X'. "Mindig kell update, mert ha megfordul az összeg, akkor űríteni kell<br>*--1765 #01. |
| 3907 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3908 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH LR_ABEVAZ. |
| 3909 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * ezt a sort kell módosítani! |
| 3910 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *00D Kiutalást nem kérek |
| 3911 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 3912 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 3913 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Értékhatár |
| 3914 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH LR_MONAT. |
| 3915 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Összeg meghatározása adószámonként, számlánként |
| 3916 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Csak a hónapon belül kell összesíteni |
| 3917 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Értékhatár meghatározása<br>*    Összeg visszaírása adószámonként |
| 3918 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 3919 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      ezt a sort kell módosítani! |
| 3920 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Létrehozás adószámos ABEV |
| 3921 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    M-es főlap egyéb számított mezők töltése töltése |
| 3922 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 3923 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Összeg meghatározása adószámonként, számlánként |
| 3924 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 3925 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 3926 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 3927 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 3928 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 3929 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0HD0001CA-at. |
| 3930 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 3931 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * időszak meghatározása |
| 3932 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 3933 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * pótlék számítás kezdeti dátuma |
| 3934 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 3935 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * pótlék számítás |
| 3936 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 3937 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Ha van érték, korrigálni kell a A0HD0001CA-at. |
| 3938 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 3939 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap |                              "0-flag beállítás |
| 3940 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 3941 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 3942 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 3943 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 3944 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 3945 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 3946 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 3947 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *     ELSEIF NOT  LW_ANALITIKA-STCD1 IS INITIAL.<br>*++1565 #05.<br>*   Mivel ki kell tölteni mert egyébként hibát az ABEV hibát ad<br>*   kiolvassuk az első-t ahol van! |
| 3948 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Vevő neve: |
| 3949 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *--1765 #26.<br>*    Szállító neve |
| 3950 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 3951 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      DUMMY_R FIELD_C mező |
| 3952 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * N - Negyedéves |
| 3953 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3954 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * ezt a sort kell módosítani! |
| 3955 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 3956 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    IDŐSZAK záró dátuma |
| 3957 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 3958 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Bevallás gyakorisága |
| 3959 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-371 d Összevont adóalap ( a 360-370. sorok "D"összege) |
| 3960 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 3961 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *M 02-374 d Az adóelőleg alapja (a 371-372. sorok különbözete) |
| 3962 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 3963 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *M 02-375 d A 371. sorból bérnek minősülő összeg (360-363. "D", 3<br>* 369-370 sor "A" adatai) |
| 3964 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 3965 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 3966 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Szelekciós ABEVAZ feltöltése |
| 3967 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 3968 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    ezt a sort kell módosítani! |
| 3969 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Speciális számítások |
| 3970 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-081 A START kártyával rend 10%-os szociális hozz jár adó<br>*(1-es kód: 643. sor ""c"") |
| 3971 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3972 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 02-039 A START kártyával rend 20%-os szociális hozz jár adó (1-es<br>*kód: 644. sor "c") |
| 3973 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3974 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 02-040 A START  PLUSZ kártyával rend 10%-os szociális hozz jár adó<br>*(2-es kód: 643. sor "c") |
| 3975 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3976 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 02-041 A START PLUSZ kártyával rend 20%-os szociális hozz jár adó<br>*(2-es kód: 644. sor "c") |
| 3977 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3978 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 02-042 A START EXTRA kártyával rend 10%-os szociális hozz jár<br>*adó (3-es kód: 643. sor "c") |
| 3979 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3980 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-091 A s/zak/zakképzésettségen nem igénylő munkakörben fogl<br>*12,5%-os szocho (1-es kód:679.sor "c") |
| 3981 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3982 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-092 A 180 napnál több munkaviszonnyal rend 25 év alatti<br>*12,5% szocho (7-es kód:679.sor "c") |
| 3983 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3984 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-093 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679. sor "c") |
| 3985 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3986 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-094 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 679. sor "c") |
| 3987 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3988 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-095 A szabad váll zónában működő váll 12,5% szocho<br>*(11-es kód:679. sor "c") |
| 3989 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3990 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 04-096 A nemzeti felsőokt. Doktori képzés 12,5% szocho kedvezmény<br>*(13-as kód:678.sor "c") |
| 3991 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3992 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 04-097 A tartósan álláskereső személyek után fiz 12,5% szocho<br>*(09-es kód,679.sorosk"c") |
| 3993 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3994 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *04-100 A magánszemélyt terelő nyugdíjjárulék<br>*(563,604,611. sorok ""c"" fodl min NEM 25,42,81,83,9 |
| 3995 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3996 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-56-c A megánsz terh munkanélk,állásker nyugdíj<br>*(611.sorok "c" fogl min 25,42,81) |
| 3997 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 3998 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *A 03-57-c A magánsz terh GYED, S, T után fiz nyugdíj(A 603.,611. sorok<br>*"c" a fogl min 83, 92, 93) |
| 3999 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Feltétel feltöltése |
| 4000 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Önellenőrzés meghatározásához |
| 4001 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4002 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char<br>* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4003 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    ezt a sort kell módosítani! |
| 4004 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      időszak-tól első nap |
| 4005 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * Negyedéves |
| 4006 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      időszak-ig utolsó nap |
| 4007 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Adózók száma = Adószámok |
| 4008 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Helyesbítés, Önellenőrzés |
| 4009 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Csak önellenőrzésénél |
| 4010 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4011 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4012 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          Van érték: |
| 4013 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          Helyesbítő |
| 4014 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Ismételt önellenőrzés |
| 4015 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *        Csak önellenőrzésénél |
| 4016 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4017 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4018 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *          Van érték: |
| 4019 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4020 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Ha mező1 >= mező2 akkor mező3 0 flag beállítás |
| 4021 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  mező1-n 0 flag állítás |
| 4022 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | * Önellenőrzési pótlék ha önrevízió |
| 4023 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 4024 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Értékek |
| 4025 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *   Dialógus futás biztosításhoz |
| 4026 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *      Nyugdíjas adószámok gyűjtése |
| 4027 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4028 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Nyugdíjasok meghatározása |
| 4029 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Meghatározzuk a jelleget: |
| 4030 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4031 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Összegzendő mezők feltöltéséhez |
| 4032 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Ha önrevízió |
| 4033 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4034 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4035 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *    Nem kell a rekord. |
| 4036 | src/#zak#functions.fugr.#zak#lfunctionsf15.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4037 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-312 d Összevont adóalap ( a 300-306. sorok  és 308-3011.sorok"D"összege) |
| 4038 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4039 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *M 02-315 d Az adóelőleg alapja (a 313-314. sorok különbözete) |
| 4040 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4041 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *M 02-316 d A 312. sorból bérnek minősülő összeg (300-303. "D", 310-311 sor "A" adatai) |
| 4042 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4043 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 4044 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Szelekciós ABEVAZ feltöltése |
| 4045 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *<br>* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4046 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    ezt a sort kell módosítani! |
| 4047 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Speciális számítások |
| 4048 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 03-086 A START kártyával rend 10%-os szociális hozz jár a\\| |
| 4049 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4050 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 03-087 A START kártyával rend 20%-os szociális hozz jár a\\| |
| 4051 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4052 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 03-088 A START  PLUSZ kártyával rend 10%-os szociális hoz\\| |
| 4053 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4054 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 03-089 A START  PLUSZ kártyával rend 20%-os szociális hoz\\| |
| 4055 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4056 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 03-090 A START EXTRA kártyával rend 10%-os szociális hozz\\| |
| 4057 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4058 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 03-096 A s/zak/zakképzésettségen nem igénylő munkakörben fogl \\| |
| 4059 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4060 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-097 A180 napnál több mv rend 25 év alatti fogl 12,5% sz |
| 4061 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4062 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-099 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679.\\| |
| 4063 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4064 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-099 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\| |
| 4065 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4066 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-100 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\| |
| 4067 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4068 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-101 A szabad váll zónában működő váll 12,5% szocho (11\\| |
| 4069 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4070 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-102 A nemzeti felsőokt. Doktori képzés 12,5% szocho ke\\| |
| 4071 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4072 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-103 A mezőgazdasági fogl fiz 12,5% sz\\| |
| 4073 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4074 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | **A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 4075 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4076 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | **A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 4077 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Feltétel feltöltése |
| 4078 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\|<br>*++1708 #02.<br>*      WHEN C_ABEVAZ_A0EC0102CA. |
| 4079 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *--1708 #02.<br>*        Feltétel feltöltése |
| 4080 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Összegzendő mezők feltöltéséhez |
| 4081 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Ha önrevízió |
| 4082 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4083 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4084 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Nem kell a rekord. |
| 4085 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4086 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Önellenőrzés meghatározásához |
| 4087 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4088 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4089 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    ezt a sort kell módosítani! |
| 4090 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      időszak-tól első nap |
| 4091 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * Negyedéves |
| 4092 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      időszak-ig utolsó nap |
| 4093 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Adózók száma = Adószámok |
| 4094 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Helyesbítés, Önellenőrzés |
| 4095 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Csak önellenőrzésénél |
| 4096 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4097 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4098 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          Van érték: |
| 4099 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          Helyesbítő |
| 4100 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Ismételt önellenőrzés |
| 4101 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Csak önellenőrzésénél |
| 4102 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4103 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4104 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *          Van érték: |
| 4105 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4106 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  mező1-n 0 flag állítás |
| 4107 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * Önellenőrzési pótlék ha önrevízió |
| 4108 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 4109 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Értékek |
| 4110 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *   Dialógus futás biztosításhoz |
| 4111 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Nyugdíjas adószámok gyűjtése |
| 4112 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4113 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Nyugdíjasok meghatározása |
| 4114 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Meghatározzuk a jelleget: |
| 4115 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4116 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | ************************************************************************<br>* Speciális abev mezők |
| 4117 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | ******************************************************** CSAK ÁFA normál |
| 4118 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4119 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * ezt a sort kell módosítani! |
| 4120 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4121 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * 00C Bevallási időszak -tól |
| 4122 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * Negyedéves |
| 4123 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *00C Bevallási időszak -ig |
| 4124 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *00C Bevallás jellege |
| 4125 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 4126 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 4127 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 4128 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 4129 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 4130 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4131 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 4132 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *86.B. Következő időszakra átvihető követelés összege |
| 4133 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *00F év hó nap |
| 4134 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 4135 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *Következő időszakra átvitt |
| 4136 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4137 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4138 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * ezt a sort kell módosítani! |
| 4139 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *00D Kiutalást nem kérek |
| 4140 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4141 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 4142 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Értékhatár |
| 4143 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH lr_monat. |
| 4144 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4145 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Csak a hónapon belül kell összesíteni |
| 4146 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Értékhatár meghatározása<br>*    Összeg visszaírása adószámonként |
| 4147 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 4148 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      ezt a sort kell módosítani! |
| 4149 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *        Létrehozás adószámos ABEV |
| 4150 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    M-es főlap egyéb számított mezők töltése töltése |
| 4151 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 4152 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4153 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 4154 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 4155 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 4156 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 4157 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 4158 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0HD0001CA-at. |
| 4159 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 4160 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * időszak meghatározása |
| 4161 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 4162 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * pótlék számítás kezdeti dátuma |
| 4163 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 4164 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * pótlék számítás |
| 4165 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 4166 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      Ha van érték, korrigálni kell a A0HD0001CA-at. |
| 4167 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 4168 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap |                              "0-flag beállítás |
| 4169 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 4170 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 4171 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 4172 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 4173 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 4174 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 4175 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 4176 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *     ELSEIF NOT  LW_ANALITIKA-STCD1 IS INITIAL.<br>*++1565 #05.<br>*   Mivel ki kell tölteni mert egyébként hibát az ABEV hibát ad<br>*   kiolvassuk az első-t ahol van! |
| 4177 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Vevő neve: |
| 4178 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *--1765 #26.<br>*    Szállító neve |
| 4179 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 4180 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *      DUMMY_R FIELD_C mező |
| 4181 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * N - Negyedéves |
| 4182 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4183 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | * ezt a sort kell módosítani! |
| 4184 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 4185 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    IDŐSZAK záró dátuma |
| 4186 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 4187 | src/#zak#functions.fugr.#zak#lfunctionsf16.abap | *    Bevallás gyakorisága |
| 4188 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-312 d Összevont adóalap ( a 300-306. sorok  és 308-3011.sorok"D"összege) |
| 4189 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4190 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *M 02-315 d Az adóelőleg alapja (a 313-314. sorok különbözete) |
| 4191 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4192 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *M 02-316 d A 312. sorból bérnek minősülő összeg (300-303. "D", 310-311 sor "A" adatai) |
| 4193 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4194 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 4195 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Szelekciós ABEVAZ feltöltése |
| 4196 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4197 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    ezt a sort kell módosítani! |
| 4198 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Speciális számítások |
| 4199 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 03-086 A START kártyával rend 10%-os szociális hozz jár a\\| |
| 4200 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4201 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 03-087 A START kártyával rend 20%-os szociális hozz jár a\\| |
| 4202 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4203 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 03-089 A START  PLUSZ kártyával rend 10%-os szociális hoz\\| |
| 4204 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4205 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 03-089 A START  PLUSZ kártyával rend 20%-os szociális hoz\\| |
| 4206 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4207 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 03-090 A START EXTRA kártyával rend 10%-os szociális hozz\\| |
| 4208 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4209 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 03-096 A s/zak/zakképzésettségen nem igénylő munkakörben fogl \\| |
| 4210 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4211 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-097 A180 napnál több mv rend 25 év alatti fogl 12,5% sz |
| 4212 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4213 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-099 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679.\\| |
| 4214 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4215 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-099 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\| |
| 4216 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4217 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-100 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\| |
| 4218 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4219 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-101 A szabad váll zónában működő váll 12,5% szocho (11\\| |
| 4220 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4221 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-102 A nemzeti felsőokt. Doktori képzés 12,5% szocho ke\\| |
| 4222 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4223 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-103 A mezőgazdasági fogl fiz 12,5% sz\\| |
| 4224 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4225 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-104 Karrier Híd |
| 4226 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4227 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | **A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 4228 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4229 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | **A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 4230 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4231 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 4232 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Feltétel feltöltése |
| 4233 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Összegzendő mezők feltöltéséhez |
| 4234 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Ha önrevízió |
| 4235 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4236 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4237 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Nem kell a rekord. |
| 4238 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4239 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *++1708 #04.<br>*                                C_ABEVAZ_A0CD0045CA         "Forrás 1 |
| 4240 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *++1708 #04.<br>*                                C_ABEVAZ_A0EC0105CA         "Forrás 1 |
| 4241 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Önellenőrzés meghatározásához |
| 4242 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4243 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4244 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    ezt a sort kell módosítani! |
| 4245 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      időszak-tól első nap |
| 4246 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * Negyedéves |
| 4247 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      időszak-ig utolsó nap |
| 4248 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Adózók száma = Adószámok |
| 4249 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Helyesbítés, Önellenőrzés |
| 4250 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Csak önellenőrzésénél |
| 4251 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4252 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4253 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          Van érték: |
| 4254 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          Helyesbítő |
| 4255 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Ismételt önellenőrzés |
| 4256 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Csak önellenőrzésénél |
| 4257 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4258 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4259 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *          Van érték: |
| 4260 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4261 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  mező1-n 0 flag állítás |
| 4262 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * Önellenőrzési pótlék ha önrevízió |
| 4263 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 4264 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Értékek |
| 4265 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *   Dialógus futás biztosításhoz |
| 4266 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Nyugdíjas adószámok gyűjtése |
| 4267 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4268 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Nyugdíjasok meghatározása |
| 4269 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Meghatározzuk a jelleget: |
| 4270 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4271 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | ************************************************************************<br>* Speciális abev mezők |
| 4272 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | ******************************************************** CSAK ÁFA normál |
| 4273 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4274 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * ezt a sort kell módosítani! |
| 4275 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4276 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * 00C Bevallási időszak -tól |
| 4277 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * Negyedéves |
| 4278 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *00C Bevallási időszak -ig |
| 4279 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *00C Bevallás jellege |
| 4280 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 4281 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 4282 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 4283 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 4284 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 4285 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4286 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 4287 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *86.B. Következő időszakra átvihető követelés összege |
| 4288 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *00F év hó nap |
| 4289 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 4290 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *Következő időszakra átvitt |
| 4291 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4292 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4293 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * ezt a sort kell módosítani! |
| 4294 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *00D Kiutalást nem kérek |
| 4295 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4296 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 4297 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Értékhatár |
| 4298 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH lr_monat. |
| 4299 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4300 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Csak a hónapon belül kell összesíteni |
| 4301 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Értékhatár meghatározása<br>*    Összeg visszaírása adószámonként |
| 4302 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 4303 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      ezt a sort kell módosítani! |
| 4304 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *        Létrehozás adószámos ABEV |
| 4305 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    M-es főlap egyéb számított mezők töltése töltése |
| 4306 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 4307 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4308 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 4309 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 4310 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 4311 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 4312 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 4313 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0HD0001CA-at. |
| 4314 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 4315 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * időszak meghatározása |
| 4316 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 4317 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * pótlék számítás kezdeti dátuma |
| 4318 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 4319 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * pótlék számítás |
| 4320 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 4321 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      Ha van érték, korrigálni kell a A0HD0001CA-at. |
| 4322 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 4323 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap |                              "0-flag beállítás |
| 4324 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 4325 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 4326 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 4327 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 4328 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 4329 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 4330 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 4331 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *     ELSEIF NOT  LW_ANALITIKA-STCD1 IS INITIAL.<br>*++1565 #05.<br>*   Mivel ki kell tölteni mert egyébként hibát az ABEV hibát ad<br>*   kiolvassuk az első-t ahol van! |
| 4332 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Vevő neve: |
| 4333 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *--1765 #26.<br>*    Szállító neve |
| 4334 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 4335 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *      DUMMY_R FIELD_C mező |
| 4336 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * N - Negyedéves |
| 4337 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4338 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | * ezt a sort kell módosítani! |
| 4339 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 4340 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    IDŐSZAK záró dátuma |
| 4341 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 4342 | src/#zak#functions.fugr.#zak#lfunctionsf17.abap | *    Bevallás gyakorisága |
| 4343 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-312 d Összevont adóalap ( a 300-306. sorok  és 308-3011.sorok"D"összege) |
| 4344 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4345 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *M 02-315 d Az adóelőleg alapja (a 313-314. sorok különbözete) |
| 4346 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4347 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *M 02-316 d A 312. sorból bérnek minősülő összeg (300-303. "D", 310-311 sor "A" adatai) |
| 4348 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4349 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 4350 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Szelekciós ABEVAZ feltöltése |
| 4351 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4352 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    ezt a sort kell módosítani! |
| 4353 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Speciális számítások |
| 4354 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-087 A START kártyával rend 10%-os szociális hozz jár a\\| |
| 4355 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4356 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-088 A START kártyával rend 20%-os szociális hozz jár a\\| |
| 4357 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4358 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-089 A START  PLUSZ kártyával rend 10%-os szociális hoz\\| |
| 4359 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4360 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-090 A START  PLUSZ kártyával rend 20%-os szociális hoz\\| |
| 4361 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4362 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-091 A START EXTRA kártyával rend 10%-os szociális hozz\\| |
| 4363 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4364 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-095 A közfogl. keretében alk.9,75% szocho köt (2-es kód,678c) |
| 4365 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4366 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 03-096 A s/zak/zakképzésettségen nem igénylő munkakörben fogl \\| |
| 4367 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4368 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-097 A180 napnál több mv rend 25 év alatti fogl 12,5% sz |
| 4369 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4370 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-099 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679.\\| |
| 4371 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4372 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-099 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\| |
| 4373 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4374 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-100 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\| |
| 4375 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4376 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-101 A szabad váll zónában működő váll 12,5% szocho (11\\| |
| 4377 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4378 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-102 A nemzeti felsőokt. Doktori képzés 12,5% szocho ke\\| |
| 4379 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4380 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-103 A mezőgazdasági fogl fiz 12,5% sz\\| |
| 4381 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4382 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-104 Karrier Híd |
| 4383 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4384 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 4385 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *        Feltétel feltöltése |
| 4386 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 4387 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4388 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 4389 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       Feltétel feltöltése |
| 4390 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Összegzendő mezők feltöltéséhez |
| 4391 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Ha önrevízió |
| 4392 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4393 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4394 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Nem kell a rekord. |
| 4395 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4396 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *++1808 #04.<br>*                                C_ABEVAZ_A0DC0076CA         "Forrás 1 |
| 4397 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Önellenőrzés meghatározásához |
| 4398 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4399 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4400 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    ezt a sort kell módosítani! |
| 4401 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      időszak-tól első nap |
| 4402 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * Negyedéves |
| 4403 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      időszak-ig utolsó nap |
| 4404 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Adózók száma = Adószámok |
| 4405 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Helyesbítés, Önellenőrzés |
| 4406 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *        Csak önellenőrzésénél |
| 4407 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4408 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4409 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          Van érték: |
| 4410 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          Helyesbítő |
| 4411 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Ismételt önellenőrzés |
| 4412 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *        Csak önellenőrzésénél |
| 4413 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4414 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4415 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *          Van érték: |
| 4416 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4417 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  mező1-n 0 flag állítás |
| 4418 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * Önellenőrzési pótlék ha önrevízió |
| 4419 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 4420 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Értékek |
| 4421 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *   Dialógus futás biztosításhoz |
| 4422 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Nyugdíjas adószámok gyűjtése |
| 4423 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4424 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Nyugdíjasok meghatározása |
| 4425 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Meghatározzuk a jelleget: |
| 4426 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4427 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | ************************************************************************<br>* Speciális abev mezők |
| 4428 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | ******************************************************** CSAK ÁFA normál |
| 4429 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4430 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * ezt a sort kell módosítani! |
| 4431 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4432 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * 00C Bevallási időszak -tól |
| 4433 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * Negyedéves |
| 4434 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *00C Bevallási időszak -ig |
| 4435 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *00C Bevallás jellege |
| 4436 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 4437 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 4438 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 4439 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 4440 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 4441 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4442 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 4443 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *86.B. Következő időszakra átvihető követelés összege |
| 4444 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *00F év hó nap |
| 4445 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 4446 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *Következő időszakra átvitt |
| 4447 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4448 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4449 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * ezt a sort kell módosítani! |
| 4450 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *00D Kiutalást nem kérek |
| 4451 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4452 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 4453 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Értékhatár |
| 4454 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH lr_monat. |
| 4455 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *++1865 #16.<br>*   2018.07.01-től nem kell az értékhatár alatti összesítés |
| 4456 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *--1865 #16.<br>*    Összeg meghatározása adószámonként, számlánként |
| 4457 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Csak a hónapon belül kell összesíteni |
| 4458 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Értékhatár meghatározása<br>*++1865 #16. |
| 4459 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *--1865 #16.<br>*    Összeg visszaírása adószámonként |
| 4460 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 4461 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *--1865 #16.<br>*      ezt a sort kell módosítani! |
| 4462 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *        Létrehozás adószámos ABEV |
| 4463 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *--1865 #16.<br>*    M-es főlap egyéb számított mezők töltése töltése |
| 4464 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 4465 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4466 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 4467 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 4468 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 4469 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 4470 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 4471 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0HD0001CA-at. |
| 4472 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 4473 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * időszak meghatározása |
| 4474 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 4475 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * pótlék számítás kezdeti dátuma |
| 4476 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 4477 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * pótlék számítás |
| 4478 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 4479 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      Ha van érték, korrigálni kell a A0HD0001CA-at. |
| 4480 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 4481 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap |                              "0-flag beállítás |
| 4482 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 4483 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 4484 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 4485 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 4486 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 4487 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 4488 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 4489 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *     ELSEIF NOT  LW_ANALITIKA-STCD1 IS INITIAL.<br>*++1565 #05.<br>*   Mivel ki kell tölteni mert egyébként hibát az ABEV hibát ad<br>*   kiolvassuk az első-t ahol van! |
| 4490 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Vevő neve: |
| 4491 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *--1765 #26.<br>*    Szállító neve |
| 4492 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 4493 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *      DUMMY_R FIELD_C mező |
| 4494 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * N - Negyedéves |
| 4495 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4496 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | * ezt a sort kell módosítani! |
| 4497 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 4498 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    IDŐSZAK záró dátuma |
| 4499 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 4500 | src/#zak#functions.fugr.#zak#lfunctionsf18.abap | *    Bevallás gyakorisága |
| 4501 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-312 d Összevont adóalap ( a 300-306. sorok  és 308-3011.sorok"D"összege) |
| 4502 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4503 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *M 02-315 d Az adóelőleg alapja (a 313-314. sorok különbözete) |
| 4504 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4505 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *M 02-316 d A 312. sorból bérnek minősülő összeg (300-303. "D", 310-311 sor "A" adatai) |
| 4506 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4507 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 4508 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Szelekciós ABEVAZ feltöltése |
| 4509 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4510 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    ezt a sort kell módosítani! |
| 4511 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Speciális számítások |
| 4512 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-087 A START kártyával rend 10%-os szociális hozz jár a\\| |
| 4513 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4514 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-088 A START kártyával rend 20%-os szociális hozz jár a\\| |
| 4515 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4516 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-089 A START  PLUSZ kártyával rend 10%-os szociális hoz\\| |
| 4517 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4518 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-090 A START  PLUSZ kártyával rend 20%-os szociális hoz\\| |
| 4519 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4520 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-091 A START EXTRA kártyával rend 10%-os szociális hozz\\| |
| 4521 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4522 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-095 A közfogl. keretében alk.9,75% szocho köt (2-es kód,678c) |
| 4523 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4524 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 03-096 A s/zak/zakképzésettségen nem igénylő munkakörben fogl \\| |
| 4525 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4526 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-097 A180 napnál több mv rend 25 év alatti fogl 12,5% sz |
| 4527 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4528 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-099 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679.\\| |
| 4529 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4530 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-099 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\| |
| 4531 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4532 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *--1908 #12.<br>*     A 04-100 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\| |
| 4533 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4534 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *--1908 #12.<br>*     A 04-101 A szabad váll zónában működő váll 12,5% szocho (11\\| |
| 4535 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4536 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-102 A nemzeti felsőokt. Doktori képzés 12,5% szocho ke\\| |
| 4537 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4538 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-103 A mezőgazdasági fogl fiz 12,5% sz\\| |
| 4539 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4540 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-104 Karrier Híd |
| 4541 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4542 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 4543 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *        Feltétel feltöltése |
| 4544 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 4545 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4546 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 4547 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *       Feltétel feltöltése |
| 4548 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Összegzendő mezők feltöltéséhez |
| 4549 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Ha önrevízió |
| 4550 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4551 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4552 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Nem kell a rekord. |
| 4553 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4554 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *++1908 #06.<br>*                                C_ABEVAZ_A0EC0074DA         "Forrás 1 |
| 4555 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Önellenőrzés meghatározásához |
| 4556 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4557 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4558 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    ezt a sort kell módosítani! |
| 4559 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      időszak-tól első nap |
| 4560 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * Negyedéves |
| 4561 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      időszak-ig utolsó nap |
| 4562 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Adózók száma = Adószámok |
| 4563 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Helyesbítés, Önellenőrzés |
| 4564 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *        Csak önellenőrzésénél |
| 4565 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4566 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4567 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          Van érték: |
| 4568 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          Helyesbítő |
| 4569 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Ismételt önellenőrzés<br>*++1908 #07.<br>*      WHEN C_ABEVAZ_A0GC001A. |
| 4570 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *--1908 #07.<br>*        Csak önellenőrzésénél |
| 4571 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4572 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4573 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *          Van érték: |
| 4574 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4575 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  mező1-n 0 flag állítás |
| 4576 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * Önellenőrzési pótlék ha önrevízió |
| 4577 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *++1908 #05.<br>* Önellenőrzési pótlék ha önrevízió |
| 4578 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez<br>*++1908 #02. |
| 4579 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Értékek |
| 4580 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *   Dialógus futás biztosításhoz |
| 4581 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Nyugdíjas adószámok gyűjtése |
| 4582 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4583 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Nyugdíjasok meghatározása |
| 4584 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | ************************************************************************<br>* Speciális abev mezők |
| 4585 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | ******************************************************** CSAK ÁFA normál |
| 4586 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4587 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * ezt a sort kell módosítani! |
| 4588 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4589 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * 00C Bevallási időszak -tól |
| 4590 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * Negyedéves |
| 4591 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *00C Bevallási időszak -ig |
| 4592 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *00C Bevallás jellege |
| 4593 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 4594 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 4595 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 4596 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 4597 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 4598 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4599 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 4600 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *86.B. Következő időszakra átvihető követelés összege |
| 4601 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *00F év hó nap |
| 4602 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 4603 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *Következő időszakra átvitt |
| 4604 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4605 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4606 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * ezt a sort kell módosítani! |
| 4607 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *00D Kiutalást nem kérek |
| 4608 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4609 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 4610 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Értékhatár |
| 4611 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH lr_monat. |
| 4612 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Összeg meghatározása adószámonként, számlánként |
| 4613 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Csak a hónapon belül kell összesíteni |
| 4614 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Értékhatár meghatározása |
| 4615 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 4616 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     M-es főlap egyéb számított mezők töltése töltése |
| 4617 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 4618 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4619 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 4620 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 4621 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 4622 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 4623 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0HD0001CA-at. |
| 4624 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 4625 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * időszak meghatározása |
| 4626 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 4627 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * pótlék számítás kezdeti dátuma |
| 4628 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 4629 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * pótlék számítás |
| 4630 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 4631 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      Ha van érték, korrigálni kell a A0HD0001CA-at. |
| 4632 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 4633 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap |                              "0-flag beállítás |
| 4634 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 4635 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 4636 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 4637 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 4638 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 4639 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *++1965 #04.<br>* Az nem üres az adószám |
| 4640 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Csoport név megadása |
| 4641 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 4642 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 4643 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Vevő neve: |
| 4644 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *--1765 #26.<br>*    Szállító neve |
| 4645 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 4646 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *      DUMMY_R FIELD_C mező |
| 4647 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * N - Negyedéves |
| 4648 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4649 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | * ezt a sort kell módosítani! |
| 4650 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 4651 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    IDŐSZAK záró dátuma |
| 4652 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 4653 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *    Bevallás gyakorisága |
| 4654 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Meghatározzuk a jelleget: |
| 4655 | src/#zak#functions.fugr.#zak#lfunctionsf19.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4656 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 4657 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Értékek |
| 4658 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *   Dialógus futás biztosításhoz |
| 4659 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Nyugdíjas adószámok gyűjtése |
| 4660 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4661 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Nyugdíjasok meghatározása |
| 4662 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Meghatározzuk a jelleget: |
| 4663 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4664 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-312 d Összevont adóalap ( a 300-306. sorok  és 308-3011.sorok"D"összege) |
| 4665 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4666 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *M 02-315 d Az adóelőleg alapja (a 313-314. sorok különbözete) |
| 4667 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4668 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *M 02-316 d A 312. sorból bérnek minősülő összeg (300-303. "D", 310-311 sor "A" adatai) |
| 4669 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4670 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4671 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 4672 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Szelekciós ABEVAZ feltöltése |
| 4673 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4674 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    ezt a sort kell módosítani! |
| 4675 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Speciális számítások |
| 4676 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *   A 03-095 A közfogl. keretében alk.9,75% szocho köt (2-es kód,678c) |
| 4677 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4678 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 03-096 A s/zak/zakképzésettségen nem igénylő munkakörben fogl \\| |
| 4679 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4680 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-097 A180 napnál több mv rend 25 év alatti fogl 12,5% sz<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0097CA. |
| 4681 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--2008 #02.<br>*       Feltétel feltöltése |
| 4682 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-099 Az 55 év feletti fogl 12,5% szocho (8-as kód: 679.\\|<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0098CA. |
| 4683 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--2008 #02.<br>*       Feltétel feltöltése |
| 4684 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-099 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\|<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0099CA. |
| 4685 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *++2008 #02.<br>*       Feltétel feltöltése |
| 4686 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-100 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\|<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0100CA. |
| 4687 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--2008 #02.<br>*       Feltétel feltöltése |
| 4688 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-101 A szabad váll zónában működő váll 12,5% szocho (11\\|<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0101CA. |
| 4689 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--2008 #02.<br>*       Feltétel feltöltése |
| 4690 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-102 A nemzeti felsőokt. Doktori képzés 12,5% szocho ke\\|<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0102CA. |
| 4691 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--2008 #02.<br>*       Feltétel feltöltése |
| 4692 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-103 A mezőgazdasági fogl fiz 12,5% sz\\|<br>*++2008 #02.<br>*    WHEN  C_ABEVAZ_A0FC0103CA. |
| 4693 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--2008 #02.<br>*       Feltétel feltöltése |
| 4694 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-104 Karrier Híd |
| 4695 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4696 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    A 04-103 a s/zak/zakképzettséget nem igénylő |
| 4697 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4698 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    A 04-103 a mezőgazdasági munkakörben fogl |
| 4699 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4700 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    A 04-103 a közfoglalkoztatás keretében |
| 4701 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4702 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *   A 04-103 a nemzeti felsőoktatás doktori |
| 4703 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4704 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 4705 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *        Feltétel feltöltése |
| 4706 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 4707 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4708 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 4709 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *       Feltétel feltöltése |
| 4710 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Összegzendő mezők feltöltéséhez |
| 4711 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Ha önrevízió |
| 4712 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4713 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4714 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Nem kell a rekord. |
| 4715 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4716 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *++2008 #06.<br>*                                C_ABEVAZ_A0GC0150CA         "Forrás 1 |
| 4717 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Önellenőrzés meghatározásához |
| 4718 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4719 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4720 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    ezt a sort kell módosítani! |
| 4721 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      időszak-tól első nap |
| 4722 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * Negyedéves |
| 4723 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      időszak-ig utolsó nap |
| 4724 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Adózók száma = Adószámok |
| 4725 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Helyesbítés, Önellenőrzés |
| 4726 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *        Csak önellenőrzésénél |
| 4727 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4728 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4729 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          Van érték: |
| 4730 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          Helyesbítő |
| 4731 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Ismételt önellenőrzés |
| 4732 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *        Csak önellenőrzésénél |
| 4733 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4734 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4735 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *          Van érték: |
| 4736 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4737 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * Önellenőrzési pótlék ha önrevízió |
| 4738 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | ************************************************************************<br>* Speciális abev mezők |
| 4739 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | ******************************************************** CSAK ÁFA normál |
| 4740 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4741 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * ezt a sort kell módosítani! |
| 4742 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4743 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * 00C Bevallási időszak -tól |
| 4744 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * Negyedéves |
| 4745 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *00C Bevallási időszak -ig |
| 4746 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *00C Bevallás jellege |
| 4747 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 4748 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 4749 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 4750 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 4751 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 4752 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4753 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 4754 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *86.B. Következő időszakra átvihető követelés összege |
| 4755 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *00F év hó nap |
| 4756 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 4757 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *Következő időszakra átvitt |
| 4758 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4759 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4760 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * ezt a sort kell módosítani! |
| 4761 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *00D Kiutalást nem kérek |
| 4762 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4763 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 4764 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Értékhatár |
| 4765 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH lr_monat. |
| 4766 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Összeg meghatározása adószámonként, számlánként |
| 4767 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Csak a hónapon belül kell összesíteni |
| 4768 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Értékhatár meghatározása |
| 4769 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 4770 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 4771 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4772 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | ************************************************************************<br>****<br>* önellenörzési pótlék számítása<br>************************************************************************<br>**** |
| 4773 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 4774 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 4775 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 4776 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0HD0001CA-at. |
| 4777 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0HD0002CA számítása a A0HD0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 4778 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * időszak meghatározása |
| 4779 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 4780 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * pótlék számítás kezdeti dátuma |
| 4781 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 4782 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * pótlék számítás |
| 4783 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 4784 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      Ha van érték, korrigálni kell a A0HD0001CA-at. |
| 4785 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  0 flag mező kezelés<br>* Ha mező1 ne 0 vagy mező2 ne 0 vagy mező3 ne 0 vagy mező4 ne 0<br>* vagy mező5 ne 0 akkor 0 flag beállítás |
| 4786 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap |                              "0-flag beállítás |
| 4787 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * N - Negyedéves |
| 4788 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4789 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * ezt a sort kell módosítani! |
| 4790 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 4791 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    IDŐSZAK záró dátuma |
| 4792 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 4793 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Bevallás gyakorisága |
| 4794 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 4795 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 4796 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 4797 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 4798 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 4799 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *++1965 #04.<br>* Az nem üres az adószám |
| 4800 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Csoport név megadása |
| 4801 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 4802 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 4803 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    Vevő neve: |
| 4804 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *--1765 #26.<br>*    Szállító neve |
| 4805 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 4806 | src/#zak#functions.fugr.#zak#lfunctionsf20.abap | *      DUMMY_R FIELD_C mező |
| 4807 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-316 d Összevont adóalap ( a 300-306. sorok  és 312-315.sorok"D"összege) |
| 4808 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4809 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *M 03-317 Összevont adóalapot csökkentő 4 vagy több gy. Nevelő anyák |
| 4810 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4811 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *++2108 #04.<br>* Öszevont adóalapot csökkentő kedvezmények összesen |
| 4812 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4813 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *M 02-322 B Az adóelőleg alapja (a 316-31. sorok különbözete) |
| 4814 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4815 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *++2108 #03.<br>*                      USING  C_ABEVAZ_M0BC0322BA            "mező0 |
| 4816 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 4817 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 4818 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Szelekciós ABEVAZ feltöltése<br>*++2108 #03.<br>*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0EC0101CA SPACE.<br>*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0EC0102CA SPACE.<br>*  M_DEF LR_SEL_ABEVAZ 'I' 'EQ' C_ABEVAZ_A0EC0103CA SPACE. |
| 4819 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4820 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    ezt a sort kell módosítani! |
| 4821 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Speciális számítások |
| 4822 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * A 04-101 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\|<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0101CA. |
| 4823 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4824 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * A 04-102 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\|<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0102CA. |
| 4825 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4826 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-103 A szabad váll zónában működő váll 12,5% szocho (11\\|<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0103CA. |
| 4827 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4828 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-10 a s/zak/zakképzettséget nem igénylő<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0104CA. |
| 4829 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4830 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-105 a mezőgazdasági munkakörben fogl<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0105CA. |
| 4831 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4832 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-106 A munkaerőpiacra lépők<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0106CA. |
| 4833 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4834 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-107 a közfoglalkoztatás keretében<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0107CA. |
| 4835 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4836 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-108 a nemzeti felsőoktatás doktori<br>*++2108 #03.<br>*      WHEN  C_ABEVAZ_A0EC0108CA. |
| 4837 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #03.<br>*       Feltétel feltöltése |
| 4838 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 4839 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *        Feltétel feltöltése |
| 4840 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 4841 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *       Feltétel feltöltése |
| 4842 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 4843 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *       Feltétel feltöltése |
| 4844 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 05-177-b A tanulók által fizetendő nyugdíjjárulék (579.sor,605.<br>*++2108 #11.<br>*      WHEN  C_ABEVAZ_A0HE0177BA. |
| 4845 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #11.<br>*       Feltétel feltöltése |
| 4846 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 05-178-b A tanulók által fizetendő term.egbizt (567.sorok<br>*++2108 #11.<br>*      WHEN  C_ABEVAZ_A0GE0178BA. |
| 4847 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #11.<br>*       Feltétel feltöltése |
| 4848 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *A 05-179-b A tanulók által fizetendő pénzbel eg.bizt (571.so<br>*++2108 #11.<br>*      WHEN  C_ABEVAZ_A0GE0179BA. |
| 4849 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #11.<br>*       Feltétel feltöltése |
| 4850 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Önellenőrzés meghatározásához |
| 4851 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 4852 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4853 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    ezt a sort kell módosítani! |
| 4854 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      időszak-tól első nap |
| 4855 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Negyedéves |
| 4856 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      időszak-ig utolsó nap |
| 4857 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Adózók száma = Adószámok |
| 4858 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Helyesbítés, Önellenőrzés |
| 4859 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *        Csak önellenőrzésénél |
| 4860 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4861 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4862 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Van érték: |
| 4863 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Helyesbítő |
| 4864 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Ismételt önellenőrzés<br>*++2108 #17.<br>*      WHEN C_ABEVAZ_A0HC001A. |
| 4865 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #17.<br>*        Csak önellenőrzésénél |
| 4866 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 4867 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 4868 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Van érték: |
| 4869 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 4870 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Értékek |
| 4871 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   Dialógus futás biztosításhoz |
| 4872 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Nyugdíjas adószámok gyűjtése |
| 4873 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 4874 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Nyugdíjasok meghatározása |
| 4875 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *++2108 #11.<br>*Tanulószerződéses tanulók létszáma |
| 4876 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  RANGEK feltöltése |
| 4877 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Értékek |
| 4878 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   Dialógus futás biztosításhoz |
| 4879 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Nyugdíjas adószámok gyűjtése |
| 4880 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 4881 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *++2108 #11.<br>*                                     SPACE                  "mező4<br>*                                     SPACE                  "mező5 |
| 4882 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *++2108 #11.<br>*                                     C_ABEVAZ_M0CC0319BA    "mező4 |
| 4883 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *                                     C_ABEVAZ_M0CC0320BA    "mező5 |
| 4884 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | ************************************************************************<br>* Speciális abev mezők |
| 4885 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | ******************************************************** CSAK ÁFA normál |
| 4886 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Számított mezők feltöltése<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4887 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * ezt a sort kell módosítani! |
| 4888 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4889 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * 00C Bevallási időszak -tól |
| 4890 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Negyedéves |
| 4891 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *00C Bevallási időszak -ig |
| 4892 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *00C Bevallás jellege |
| 4893 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 4894 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 4895 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 4896 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 4897 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 4898 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 4899 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 4900 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *86.B. Következő időszakra átvihető követelés összege |
| 4901 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *00F év hó nap |
| 4902 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 4903 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *Következő időszakra átvitt |
| 4904 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4905 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Függő mezők számítása<br>*++S4HANA#01.<br>*  REFRESH lr_abevaz. |
| 4906 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * ezt a sort kell módosítani! |
| 4907 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *00D Kiutalást nem kérek |
| 4908 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 4909 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 4910 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Értékhatár |
| 4911 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Hónap kezelése<br>*++S4HANA#01.<br>*    REFRESH lr_monat. |
| 4912 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Összeg meghatározása adószámonként, számlánként |
| 4913 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Csak a hónapon belül kell összesíteni |
| 4914 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Értékhatár meghatározása |
| 4915 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 4916 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *     M-es főlap egyéb számított mezők töltése töltése |
| 4917 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 4918 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Összeg meghatározása adószámonként, számlánként |
| 4919 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | ************************************************************************<br>* önellenörzési pótlék számítása<br>************************************************************************ |
| 4920 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 4921 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 4922 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 4923 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0ID0001CA-at. |
| 4924 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0ID0002CA számítása a A0ID0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 4925 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * időszak meghatározása |
| 4926 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 4927 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * pótlék számítás kezdeti dátuma |
| 4928 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 4929 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * pótlék számítás |
| 4930 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 4931 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      Ha van érték, korrigálni kell a A0ID0001CA-at. |
| 4932 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 4933 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 4934 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 4935 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 4936 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 4937 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Az nem üres az adószám |
| 4938 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Csoport név megadása |
| 4939 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 4940 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Hónap feltöltése:<br>*++S4HANA#01.<br>*  REFRESH lr_monat. |
| 4941 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Vevő neve: |
| 4942 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--1765 #26.<br>*    Szállító neve |
| 4943 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 4944 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *      DUMMY_R FIELD_C mező |
| 4945 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * N - Negyedéves |
| 4946 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 4947 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * ezt a sort kell módosítani! |
| 4948 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *++2010.02.11 RN<br>* ez a mező már nincs rajta a 10A60-on<br>**    Aláírás dátuma (sy-datum)<br>*         WHEN  C_ABEVAZ_24.<br>*           W_/ZAK/BEVALLO-FIELD_C = SY-DATUM.<br>*--2010.02.11 RN<br>*    IDŐSZAK kezdő dátuma |
| 4949 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    IDŐSZAK záró dátuma |
| 4950 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 4951 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Bevallás gyakorisága |
| 4952 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Alapadatok meghatározása |
| 4953 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * KATA adatok gyűjtése<br>*++2108 #12.<br>*  SORT LI_KATA_SEL BY ADOAZON. |
| 4954 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   Feldolgozott adatok összesytése |
| 4955 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   Összes adóalap képzése |
| 4956 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Összeg konvertálás |
| 4957 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * KATA adó kalkulálás |
| 4958 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   Megfizetett alap figyelembe vétele: |
| 4959 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Ha ki van töltve a sor oszlop struktúra, akkor a szerint kell töltenünk |
| 4960 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Sorindex összerakása<br>*   Elértük a maximális értéket, újra kezdjük |
| 4961 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Inicializálás |
| 4962 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *          Növeljük a lapszámot |
| 4963 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Ha van összesatő ABEVAZ, akkor azt is fel kell venni! |
| 4964 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * Nem feldolgozott relevans tételek jelölés visszavétele |
| 4965 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Általános adatok: |
| 4966 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   Kalkulált adóalap és adó visszaírása |
| 4967 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Ha az adóalap kisebb, akkor csak a határ feletti értéket írjuk vissza |
| 4968 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *--2108 #10.<br>*   Címadatok beolvasása |
| 4969 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A A 04-001 Kisadózó vállalkozás adószáma |
| 4970 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-003 Székhely külföldi cím<br>*   A 04-003 Székhely ország |
| 4971 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-003 Székhely irányítószám |
| 4972 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-003 Székhely város |
| 4973 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-004 Székhely közterület neve |
| 4974 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-004 Székhely közterület jellege |
| 4975 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-004 Székhely hsz |
| 4976 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-005 A fizetendő adó alapja |
| 4977 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *   A 04-005 Az adó összege |
| 4978 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Összegzendő mezők feltöltéséhez |
| 4979 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Ha önrevízió |
| 4980 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 4981 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 4982 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *    Nem kell a rekord. |
| 4983 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 4984 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Meghatározzuk a jelleget: |
| 4985 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 4986 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | *ABEV azonosítók meghatározása |
| 4987 | src/#zak#functions.fugr.#zak#lfunctionsf21.abap | * 000-ás időszak beolvasása mert meg kell ismételni! |
| 4988 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-316 d Összevont adóalap ( a 300-306. sorok  és 312-315.sorok"D"összege) |
| 4989 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4990 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *M 03-317 Összevont adóalapot csökkentő 4 vagy több gy. Nevelő anyák |
| 4991 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4992 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *++2208 #03.<br>*M 03-317 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 4993 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *--2208 #03.<br>*  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4994 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * Öszevont adóalapot csökkentő kedvezmények összesen |
| 4995 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4996 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *M 02-322 B Az adóelőleg alapja (a 316-31. sorok különbözete) |
| 4997 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 4998 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *M 02-323 B A 316. sorból bérnek minősülő összeg (300-303. "D", 314-315 sor "A" adatai) |
| 4999 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 5000 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 5001 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5002 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *   ezt a sort kell módosítani! |
| 5003 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *   Speciális számítások |
| 5004 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * A 04-101 A tartósan állástkereső fogl fogl 12,5% szocho (9-es kód: 679.\\| |
| 5005 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5006 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-102 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\| |
| 5007 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5008 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-103 A szabad váll zónában működő váll 12,5% szocho (11\\| |
| 5009 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5010 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-10 a s/zak/zakképzettséget nem igénylő |
| 5011 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5012 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-105 a mezőgazdasági munkakörben fogl |
| 5013 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5014 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-106 A munkaerőpiacra lépők |
| 5015 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5016 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-107 a 3 vagy több gyermeket nevelő nők után |
| 5017 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5018 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-108 a közfoglalkoztatás keretében |
| 5019 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5020 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-108 a nemzeti felsőoktatás doktori |
| 5021 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5022 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 5023 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5024 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 5025 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5026 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 5027 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       Feltétel feltöltése |
| 5028 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Önellenőrzés meghatározásához |
| 5029 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 5030 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5031 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *   ezt a sort kell módosítani! |
| 5032 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      időszak-tól első nap |
| 5033 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * Negyedéves |
| 5034 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      időszak-ig utolsó nap |
| 5035 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Adózók száma = Adószámok |
| 5036 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Helyesbítés, Önellenőrzés |
| 5037 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *        Csak önellenőrzésénél |
| 5038 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5039 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5040 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          Van érték: |
| 5041 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          Helyesbítő |
| 5042 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Ismételt önellenőrzés |
| 5043 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *        Csak önellenőrzésénél |
| 5044 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5045 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5046 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *          Van érték: |
| 5047 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 5048 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 5049 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Értékek |
| 5050 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *   Dialógus futás biztosításhoz |
| 5051 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Nyugdíjas adószámok gyűjtése |
| 5052 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 5053 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Nyugdíjasok meghatározása |
| 5054 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Meghatározzuk a jelleget: |
| 5055 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 5056 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | ************************************************************************<br>* Speciális abev mezők |
| 5057 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | ******************************************************** CSAK ÁFA normál |
| 5058 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * Számított mezők feltöltése |
| 5059 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * ezt a sort kell módosítani! |
| 5060 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5061 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * 00C Bevallási időszak -tól |
| 5062 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * Negyedéves |
| 5063 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *00C Bevallási időszak -ig |
| 5064 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *00C Bevallás jellege |
| 5065 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 5066 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 5067 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 5068 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 5069 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 5070 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5071 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 5072 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *86.B. Következő időszakra átvihető követelés összege |
| 5073 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *00F év hó nap |
| 5074 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 5075 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *Következő időszakra átvitt |
| 5076 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5077 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Függő mezők számítása |
| 5078 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * ezt a sort kell módosítani! |
| 5079 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *00D Kiutalást nem kérek |
| 5080 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5081 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 5082 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Értékhatár |
| 5083 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Hónap kezelése |
| 5084 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Összeg meghatározása adószámonként, számlánként |
| 5085 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Csak a hónapon belül kell összesíteni |
| 5086 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Értékhatár meghatározása |
| 5087 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 5088 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *     M-es főlap egyéb számított mezők töltése töltése |
| 5089 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 5090 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Összeg meghatározása adószámonként, számlánként |
| 5091 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 5092 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | ************************************************************************<br>* önellenörzési pótlék számítása<br>************************************************************************ |
| 5093 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 5094 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 5095 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 5096 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0ID0001CA-at. |
| 5097 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0ID0002CA számítása a A0ID0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 5098 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * időszak meghatározása |
| 5099 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 5100 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * pótlék számítás kezdeti dátuma |
| 5101 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 5102 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * pótlék számítás |
| 5103 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 5104 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      Ha van érték, korrigálni kell a A0ID0001CA-at. |
| 5105 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *++2265 #08.<br>* Számlaszám kezelés főlapon |
| 5106 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 5107 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 5108 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 5109 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 5110 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 5111 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * Az nem üres az adószám |
| 5112 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Csoport név megadása |
| 5113 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 5114 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Hónap feltöltése: |
| 5115 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Vevő neve: |
| 5116 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Szállító neve |
| 5117 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 5118 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *      DUMMY_R FIELD_C mező |
| 5119 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * N - Negyedéves |
| 5120 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5121 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | * ezt a sort kell módosítani! |
| 5122 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    IDŐSZAK kezdő dátuma |
| 5123 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    IDŐSZAK záró dátuma |
| 5124 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 5125 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Bevallás gyakorisága |
| 5126 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Összegzendő mezők feltöltéséhez |
| 5127 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Ha önrevízió |
| 5128 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 5129 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 5130 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *    Nem kell a rekord. |
| 5131 | src/#zak#functions.fugr.#zak#lfunctionsf22.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 5132 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | ************************************************************************<br>* Speciális abev mezők |
| 5133 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | ******************************************************** CSAK ÁFA normál |
| 5134 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Számított mezők feltöltése |
| 5135 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * ezt a sort kell módosítani! |
| 5136 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5137 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * 00C Bevallási időszak -tól |
| 5138 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Negyedéves |
| 5139 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *         Meg kell határozni a speciális időszak kezdetét |
| 5140 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *00C Bevallási időszak -ig |
| 5141 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *00C Bevallás jellege |
| 5142 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 5143 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 5144 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 5145 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *--2365 #03.<br>*82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 5146 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 5147 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5148 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 5149 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *86.B. Következő időszakra átvihető követelés összege |
| 5150 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *00F év hó nap |
| 5151 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 5152 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *Következő időszakra átvitt |
| 5153 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5154 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Függő mezők számítása |
| 5155 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * ezt a sort kell módosítani! |
| 5156 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *00D Kiutalást nem kérek |
| 5157 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5158 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 5159 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Értékhatár |
| 5160 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Hónap kezelése |
| 5161 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Összeg meghatározása adószámonként, számlánként |
| 5162 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Csak a hónapon belül kell összesíteni |
| 5163 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Értékhatár meghatározása |
| 5164 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 5165 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *     M-es főlap egyéb számított mezők töltése töltése |
| 5166 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 5167 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Összeg meghatározása adószámonként, számlánként |
| 5168 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 5169 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | ************************************************************************<br>* önellenörzési pótlék számítása<br>************************************************************************ |
| 5170 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 5171 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 5172 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 5173 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0ID0001CA-at. |
| 5174 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0ID0002CA számítása a A0ID0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 5175 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * időszak meghatározása |
| 5176 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 5177 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * pótlék számítás kezdeti dátuma |
| 5178 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 5179 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * pótlék számítás |
| 5180 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 5181 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Ha van érték, korrigálni kell a A0ID0001CA-at. |
| 5182 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Számlaszám kezelés főlapon |
| 5183 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 5184 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 5185 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 5186 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 5187 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 5188 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Az nem üres az adószám |
| 5189 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Csoport név megadása |
| 5190 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 5191 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Hónap feltöltése: |
| 5192 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Vevő neve: |
| 5193 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Szállító neve |
| 5194 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 5195 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      DUMMY_R FIELD_C mező |
| 5196 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * N - Negyedéves |
| 5197 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *++2365 #05.<br>* Speciális időszak |
| 5198 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5199 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * ezt a sort kell módosítani! |
| 5200 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    IDŐSZAK kezdő dátuma |
| 5201 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    IDŐSZAK záró dátuma |
| 5202 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 5203 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Bevallás gyakorisága |
| 5204 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 5205 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Értékek |
| 5206 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *   Dialógus futás biztosításhoz |
| 5207 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Nyugdíjas adószámok gyűjtése |
| 5208 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 5209 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Nyugdíjasok meghatározása |
| 5210 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Meghatározzuk a jelleget: |
| 5211 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 5212 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-316 d Összevont adóalap ( a 300-306. sorok  és 312-315.sorok"D"összege) |
| 5213 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5214 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *M 03-317 Összevont adóalapot csökkentő 4 vagy több gy. nevelő anyák |
| 5215 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5216 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *M 03-318 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 5217 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5218 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *M 03-319 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 5219 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5220 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Öszevont adóalapot csökkentő kedvezmények összesen |
| 5221 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5222 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * M 02-324 B Az adóelőleg alapja (a 316-323. sorok különbözete) |
| 5223 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5224 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * M 02-325 B A 316. sorból bérnek minősülő összeg (300-303. "D", 314-315 sor "A" adatai) |
| 5225 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 5226 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 5227 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5228 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *   ezt a sort kell módosítani! |
| 5229 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *   Speciális számítások |
| 5230 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-102 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\| |
| 5231 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5232 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-10 a s/zak/zakképzettséget nem igénylő |
| 5233 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5234 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-105 a mezőgazdasági munkakörben fogl |
| 5235 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5236 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-106 A munkaerőpiacra lépők |
| 5237 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5238 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-107 a 3 vagy több gyermeket nevelő nők után |
| 5239 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5240 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-108 a közfoglalkoztatás keretében |
| 5241 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5242 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-108 a nemzeti felsőoktatás doktori |
| 5243 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5244 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 5245 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5246 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 5247 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5248 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 5249 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *       Feltétel feltöltése |
| 5250 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Összegzendő mezők feltöltéséhez |
| 5251 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *--2408 #01.<br>*  Ha önrevízió |
| 5252 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 5253 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 5254 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *    Nem kell a rekord. |
| 5255 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 5256 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *++2308 #07.<br>*                                'A0DC0102CA'   "Forrás 1 |
| 5257 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *  Önellenőrzés meghatározásához |
| 5258 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 5259 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5260 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *   ezt a sort kell módosítani! |
| 5261 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      időszak-tól első nap |
| 5262 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Negyedéves |
| 5263 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      időszak-ig utolsó nap |
| 5264 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Adózók száma = Adószámok |
| 5265 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Helyesbítés, Önellenőrzés |
| 5266 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *        Csak önellenőrzésénél |
| 5267 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5268 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5269 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          Van érték: |
| 5270 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          Helyesbítő |
| 5271 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *      Ismételt önellenőrzés |
| 5272 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *        Csak önellenőrzésénél |
| 5273 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5274 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5275 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | *          Van érték: |
| 5276 | src/#zak#functions.fugr.#zak#lfunctionsf23.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 5277 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | ************************************************************************<br>* Speciális abev mezők |
| 5278 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | ******************************************************** CSAK ÁFA normál |
| 5279 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Számított mezők feltöltése |
| 5280 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * ezt a sort kell módosítani! |
| 5281 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5282 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * 00C Bevallási időszak -tól |
| 5283 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Negyedéves |
| 5284 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *         Meg kell határozni a speciális időszak kezdetét |
| 5285 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *00C Bevallási időszak -ig |
| 5286 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *00C Bevallás jellege |
| 5287 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 5288 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 5289 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 5290 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *--2465 #03.<br>*82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 5291 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 5292 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5293 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 5294 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *86.B. Következő időszakra átvihető követelés összege |
| 5295 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *00F év hó nap |
| 5296 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 5297 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *Következő időszakra átvitt |
| 5298 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5299 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Függő mezők számítása |
| 5300 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * ezt a sort kell módosítani! |
| 5301 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *00D Kiutalást nem kérek |
| 5302 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5303 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 5304 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Értékhatár |
| 5305 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Hónap kezelése |
| 5306 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Összeg meghatározása adószámonként, számlánként |
| 5307 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Csak a hónapon belül kell összesíteni |
| 5308 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Értékhatár meghatározása |
| 5309 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 5310 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *     M-es főlap egyéb számított mezők töltése töltése |
| 5311 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 5312 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Összeg meghatározása adószámonként, számlánként |
| 5313 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 5314 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | ************************************************************************<br>* önellenörzési pótlék számítása<br>************************************************************************ |
| 5315 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 5316 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 5317 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 5318 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0ID0001CA-at. |
| 5319 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0ID0002CA számítása a A0ID0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 5320 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * időszak meghatározása |
| 5321 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 5322 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * pótlék számítás kezdeti dátuma |
| 5323 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 5324 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * pótlék számítás |
| 5325 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 5326 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Ha van érték, korrigálni kell a A0ID0001CA-at. |
| 5327 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Számlaszám kezelés főlapon |
| 5328 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 5329 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 5330 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 5331 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 5332 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 5333 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Az nem üres az adószám |
| 5334 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Csoport név megadása |
| 5335 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 5336 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Hónap feltöltése: |
| 5337 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Vevő neve: |
| 5338 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Szállító neve |
| 5339 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 5340 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      DUMMY_R FIELD_C mező |
| 5341 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * N - Negyedéves |
| 5342 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *++2465 #05.<br>* Speciális időszak |
| 5343 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5344 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * ezt a sort kell módosítani! |
| 5345 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    IDŐSZAK kezdő dátuma |
| 5346 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    IDŐSZAK záró dátuma |
| 5347 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 5348 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Bevallás gyakorisága |
| 5349 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 5350 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *--2408 #04..<br>*  Értékek<br>*  M_DEF R_NYLAPVAL 'I' 'EQ' '3' SPACE. |
| 5351 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *   Dialógus futás biztosításhoz |
| 5352 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Nyugdíjas adószámok gyűjtése |
| 5353 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 5354 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Nyugdíjasok meghatározása |
| 5355 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Meghatározzuk a jelleget: |
| 5356 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 5357 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-316 d Összevont adóalap ( a 300-306. sorok  és 312-315.sorok"D"összege) |
| 5358 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5359 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *M 03-317 Összevont adóalapot csökkentő 4 vagy több gy. nevelő anyák |
| 5360 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5361 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *M 03-318 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 5362 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5363 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *M 03-319 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 5364 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5365 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Öszevont adóalapot csökkentő kedvezmények összesen |
| 5366 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5367 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * M 02-324 B Az adóelőleg alapja (a 316-323. sorok különbözete) |
| 5368 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5369 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * M 02-325 B A 316. sorból bérnek minősülő összeg (300-303. "D", 314-315 sor "A" adatai) |
| 5370 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 5371 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 5372 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *--2408 #02.<br>* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5373 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *   ezt a sort kell módosítani! |
| 5374 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *   Speciális számítások |
| 5375 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *++2408 #02.<br>* A 04-102 A GYED,GYES,GYET  fogl 12,5% szocho (10-es kód: 67\\|<br>*      WHEN  'A0EC0103CA'. |
| 5376 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *--2408 #02.<br>*       Feltétel feltöltése |
| 5377 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-10 a s/zak/zakképzettséget nem igénylő |
| 5378 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5379 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-105 a mezőgazdasági munkakörben fogl |
| 5380 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5381 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-106 A munkaerőpiacra lépők |
| 5382 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5383 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-107 a 3 vagy több gyermeket nevelő nők után |
| 5384 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5385 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-108 a közfoglalkoztatás keretében |
| 5386 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5387 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *++2408 #02.<br>** A 04-108 a nemzeti felsőoktatás doktori<br>*      WHEN  'A0DC0109CA'.<br>**       Feltétel feltöltése<br>*        REFRESH LR_COND.<br>*        M_DEF LR_COND 'I' 'EQ' '25' SPACE.<br>*        LM_GET_FIELD $INDEX.<br>*        LM_GET_SPEC_SUM1 'M0KD0677CA' 'M0KC007A' LR_COND.<br>*--2408 #02.<br>* A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 5388 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5389 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 5390 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5391 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 5392 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *       Feltétel feltöltése |
| 5393 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Összegzendő mezők feltöltéséhez |
| 5394 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Ha önrevízió |
| 5395 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 5396 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 5397 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *    Nem kell a rekord. |
| 5398 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 5399 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *++2408 #02.<br>*                                'A0DC0110CA'   "Forrás 1 |
| 5400 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 5401 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *  Önellenőrzés meghatározásához |
| 5402 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 5403 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5404 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *   ezt a sort kell módosítani! |
| 5405 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      időszak-tól első nap |
| 5406 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | * Negyedéves |
| 5407 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      időszak-ig utolsó nap |
| 5408 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Adózók száma = Adószámok |
| 5409 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Helyesbítés, Önellenőrzés |
| 5410 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *        Csak önellenőrzésénél |
| 5411 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5412 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5413 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          Van érték: |
| 5414 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          Helyesbítő |
| 5415 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *      Ismételt önellenőrzés |
| 5416 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *        Csak önellenőrzésénél |
| 5417 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5418 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5419 | src/#zak#functions.fugr.#zak#lfunctionsf24.abap | *          Van érték: |
| 5420 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *Speciális M-s számítások adóazonosítóként<br>*M 02-316 d Összevont adóalap ( a 300-306. sorok  és 312-315.sorok"D"összege) |
| 5421 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5422 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *M 03-317 Összevont adóalapot csökkentő 4 vagy több gy. nevelő anyák |
| 5423 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5424 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *M 03-318 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 5425 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5426 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *M 03-319 Összevont adóalapot csökkentő 25 év alatti fiatalok |
| 5427 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5428 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Öszevont adóalapot csökkentő kedvezmények összesen |
| 5429 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5430 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * M 02-324 B Az adóelőleg alapja (a 316-323. sorok különbözete) |
| 5431 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1+mező2+...mezőN amennyi a RANGE-ben van |
| 5432 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * M 02-325 B A 316. sorból bérnek minősülő összeg (300-303. "D", 314-315 sor "A" adatai) |
| 5433 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  mező0 = mező1-mező2-........ mezőn amennyi a RANGE-ben van |
| 5434 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Meg kell határozni a feltételhez tartozó ABEV<br>*      azonosító értékét |
| 5435 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *--2408 #02.<br>* a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5436 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *   ezt a sort kell módosítani! |
| 5437 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *   Speciális számítások |
| 5438 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-10 a s/zak/zakképzettséget nem igénylő |
| 5439 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5440 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-105 a mezőgazdasági munkakörben fogl |
| 5441 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5442 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-106 A munkaerőpiacra lépők |
| 5443 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5444 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-107 a 3 vagy több gyermeket nevelő nők után |
| 5445 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5446 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-108 a közfoglalkoztatás keretében |
| 5447 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5448 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-120 A magánszemélyt terelő nyugdíjjárulék (563,604,611\\| |
| 5449 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5450 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-121-c A megánsz terh munkanélk,állásker nyugdíj (605.s\\| |
| 5451 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5452 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A 04-122-c A magánsz terh GYED, S, T után fiz nyugdíj(A 604\\| |
| 5453 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       Feltétel feltöltése |
| 5454 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Összegzendő mezők feltöltéséhez |
| 5455 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Ha önrevízió |
| 5456 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Beolvassuk az előző időszak 'A'-s abev azonosítóit |
| 5457 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Kitöröljük azokat a rekordokat amikeket nem az adott időszakban<br>*  adtak fel. |
| 5458 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Nem kell a rekord. |
| 5459 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  M 11 Jelölje X-szel, ha a bevallása helyesbítésnek minősül |
| 5460 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Önellenőrzés meghatározásához |
| 5461 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | ************************************************************************<br>* Speciális abev mezők<br>************************************************************************ |
| 5462 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5463 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *   ezt a sort kell módosítani! |
| 5464 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      időszak-tól első nap |
| 5465 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Negyedéves |
| 5466 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      időszak-ig utolsó nap |
| 5467 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Adózók száma = Adószámok |
| 5468 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Helyesbítés, Önellenőrzés |
| 5469 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *        Csak önellenőrzésénél |
| 5470 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5471 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5472 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          Van érték: |
| 5473 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          Helyesbítő |
| 5474 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Ismételt önellenőrzés |
| 5475 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *        Csak önellenőrzésénél |
| 5476 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          Ebben a tartományban kell keresni numerikus értéket |
| 5477 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          A kerekített összeget figyeljük mert lehet hogy a FIELD_N<br>*          nem üres de a bevallásba nem kerül érték a fkator miatt.<br>*                                          AND NOT FIELD_N  IS INITIAL. |
| 5478 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *          Van érték: |
| 5479 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Hogy ne kellessen minden FORM-ot bővíteni az önrevíziót egy globális<br>* változóba kezeljük: |
| 5480 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Ha mező1 >= mező2 akkor mező3 0 flag beállítás |
| 5481 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | ************************************************************************<br>* Speciális abev mezők |
| 5482 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | ******************************************************** CSAK ÁFA normál |
| 5483 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Számított mezők feltöltése |
| 5484 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * ezt a sort kell módosítani! |
| 5485 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * 84.C. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5486 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * 00C Bevallási időszak -tól |
| 5487 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Negyedéves |
| 5488 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *         Meg kell határozni a speciális időszak kezdetét |
| 5489 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *00C Bevallási időszak -ig |
| 5490 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *00C Bevallás jellege |
| 5491 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *04 (O) Ismételt önellenőrzés jelölése (x) |
| 5492 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *        ZINDEX > '001' --> 'X'     "ismételt önellenőrzés |
| 5493 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *00C Bevallás gyakorisága /H-havi, N-negyedéves, E-éves |
| 5494 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *--2465 #03.<br>*82.B. Előző időszakról beszámítható csökkentő tétel összege (előző id. |
| 5495 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *83.C. Tárgyidőszakban megállapított fizetendő adó együttes összegének. |
| 5496 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *84.B. Befizetendő adó összege (a 83. sor adata, ha előjel nélküli) |
| 5497 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *85.B. Visszaigényelhető adó összege (a negatív előjelű 83. sor, ... |
| 5498 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *86.B. Következő időszakra átvihető követelés összege |
| 5499 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *00F év hó nap |
| 5500 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *85.C. Visszaigényelhető adó összege (a negatív előjelű 83. sor... |
| 5501 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *Következő időszakra átvitt |
| 5502 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5503 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Függő mezők számítása |
| 5504 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * ezt a sort kell módosítani! |
| 5505 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *00D Kiutalást nem kérek |
| 5506 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * számított mezőnél minden numerikus értéket tölteni!<br>* összeg képzésnél a következő az eljárás:<br>* pl: ABEV3 field_n = ABEV1 field_nrk + ABEV2 field_nrk<br>* majd a beálított kerekítési szabályt alkalmazni! |
| 5507 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Összesítő jelentés ÁFA értékhatár alatti mezők számítása |
| 5508 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Értékhatár |
| 5509 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Hónap kezelése |
| 5510 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Összeg meghatározása adószámonként, számlánként |
| 5511 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Csak a hónapon belül kell összesíteni |
| 5512 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Értékhatár meghatározása |
| 5513 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Ha szerepel M-es lapon vagy az értékhatár nagyobb a beállítottnál |
| 5514 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *     M-es főlap egyéb számított mezők töltése töltése |
| 5515 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Számított mezők kezelése az M lapos mezőkön is |
| 5516 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Összeg meghatározása adószámonként, számlánként |
| 5517 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *       M-es főlap egyéb számított mezők töltése töltése |
| 5518 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | ************************************************************************<br>* önellenörzési pótlék számítása<br>************************************************************************ |
| 5519 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * ha A0DD0084CA - A0DD0084BA > 0 akkor ezt az értéket, ellenkező esetben 0 |
| 5520 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * (A0DD0086CA - A0DD0086BA) < 0 akkor minusz a számolt érték |
| 5521 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * A0DD0085CA - A0DD0085BA < 0 akkor minusz a számolt érték |
| 5522 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *     Ha a A0DD0082CA-A0DD0082BA < 0 akkor, ezzel az összeggel csökkenteni kell<br>*     az L_SUM_A0ID0001CA-at. |
| 5523 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * önellenörzési pótlék  meghatározása<br>* ABEV A0ID0002CA számítása a A0ID0001CA alapján ha az index 2 vagy nagyobb akkor x1,5 |
| 5524 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * időszak meghatározása |
| 5525 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * a pótlék számitás határidejének meghatározása! a 104-es<br>* adónem kell a /ZAK/ADONEM tábla kulcshoz !! |
| 5526 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * pótlék számítás kezdeti dátuma |
| 5527 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * pótlék számítás vég dátuma az 5299 abev sor karakteres mezőjében |
| 5528 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * pótlék számítás |
| 5529 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *              Kezelni kell a 0 flag értékét a nyomtatvány ellenőrzés<br>*              miatt: |
| 5530 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Ha van érték, korrigálni kell a A0ID0001CA-at. |
| 5531 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Számlaszám kezelés főlapon |
| 5532 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * N - Negyedéves |
| 5533 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *++2465 #05.<br>* Speciális időszak |
| 5534 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * a következő abev kódok csak egyszer fordulhatnak elő, összegző v. char |
| 5535 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * ezt a sort kell módosítani! |
| 5536 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    IDŐSZAK kezdő dátuma |
| 5537 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    IDŐSZAK záró dátuma |
| 5538 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Helyebítési flagek töltése<br>*    Mindig feltöltjük ha önrevízió: |
| 5539 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Bevallás gyakorisága |
| 5540 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Meghatározzuk a jelleget: |
| 5541 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Ebben az esetben nem kell tölteni az esedékesség dátumát: |
| 5542 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  RANGEK feltöltése Nyugdíjas darabszám kezeléshez |
| 5543 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Értékek<br>*  M_DEF R_NYLAPVAL 'I' 'EQ' '3' SPACE. |
| 5544 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *   Dialógus futás biztosításhoz |
| 5545 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      Nyugdíjas adószámok gyűjtése |
| 5546 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Nem volt megfelelő a 0 flag kezelés<br>*  Ha önrevíziós számítás akkor a T_BEVALLO 0 flag kell<br>*  egyébként a I_/ZAK/BEVALLO 0 flag. |
| 5547 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Nyugdíjasok meghatározása |
| 5548 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  M0AC001A   Adózó adószáma, át lehet venni: A0AE001A-ból |
| 5549 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  M0AC003A   Jogelőd adószáma, át lehet venni, ha nem üres: A0AE004A-ból |
| 5550 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  M0AC004A Adózó neve, át lehet venni: A0AE008A-ból |
| 5551 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  M0AD001A Bevallási időszak -tól, át lehet venni: A0AF001A-ból |
| 5552 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  M0AD002A Bevallási időszak -ig, át lehet venni: A0AF002A-ból |
| 5553 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * Az nem üres az adószám |
| 5554 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Csoport név megadása |
| 5555 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | * M0AC005A Partner adószáma: ebbe kell tenni az M-es lapi ADOAZON-t,<br>*ha STCD1-ből töltöttük (/ZAK/ANALITIKA-ból ki kell venni a vevő vagy<br>*szállító kódot+KOART megadja hogy száll. Vagy vevő!)<br>*M0AC006A ha STCD3-ból töltöttük |
| 5556 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *  Hónap feltöltése: |
| 5557 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Vevő neve: |
| 5558 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    Szállító neve |
| 5559 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *    DUMMY_R-es rekordon a field_c-ben van név |
| 5560 | src/#zak#functions.fugr.#zak#lfunctionsf25.abap | *      DUMMY_R FIELD_C mező |
| 5561 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                             *<br>*&---------------------------------------------------------------------* |
| 5562 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--2065 #04.<br>*XML letöltéshez változók<br>*Konstans értékek<br>* HR.... XML 0 űrlap |
| 5563 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * HR.... XML 1 űrlap |
| 5564 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * HR.... XML 2 űrlap |
| 5565 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * HR.... XML 3 űrlap |
| 5566 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * HR.... XML 4 űrlap |
| 5567 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *++BG 2006/09/29<br>*APEH új formulárok miatt<br>*++0908/2 2009.08.04 BG<br>*CONSTANTS C_XHEAD LIKE T5HVX-BLOKK_ID VALUE 'XHEAD'.<br>*CONSTANTS C_XTAIL LIKE T5HVX-BLOKK_ID VALUE 'XTAIL'.<br>*CONSTANTS C_NYBEG LIKE T5HVX-BLOKK_ID VALUE 'NYBEG'.<br>*CONSTANTS C_VHEAD LIKE T5HVX-BLOKK_ID VALUE 'VHEAD'.<br>*CONSTANTS C_NYEND LIKE T5HVX-BLOKK_ID VALUE 'NYEND'.<br>*CONSTANTS C_EHEAD LIKE T5HVX-BLOKK_ID VALUE 'EHEAD'. |
| 5568 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--0908/2 2009.08.04 BG<br>*--BG 2006/09/29<br>* XML formulár, XML header |
| 5569 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * XML formulár, XML footer |
| 5570 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * XML formulár, 0608A nyomtatvány header |
| 5571 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * XML formulár, nyomtatvány footer |
| 5572 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * XML formulár, 0608M nyomtatvány header |
| 5573 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * XML adatfájl típusa |
| 5574 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * változó kezdetének és végének jelzése az űrlapokon<br>*++BG 2006/09/29<br>*CONSTANTS: C_VAR_MARKER(1) TYPE C VALUE '&'. |
| 5575 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *++BG 2006/05/29<br>* SZJA bevallás adóazonosító lapszám meghatározáshoz |
| 5576 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *MAKRO definiálás range feltöltéshez |
| 5577 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--BG 2006/05/29<br>*++1365 2013.01.22 Balázs Gábor (Ness)<br>*Konverzió |
| 5578 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | * Csoportok felépítése |
| 5579 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *   Konverzió végrehajtása |
| 5580 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 5581 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *++BG 2006.09.15<br>* ÚJ SZJA bevallás miatt a 0608-at meg kell különböztetni |
| 5582 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--1265 2012.01.31 BG<br>*++1365 2013.01.10 Balázs Gábor (Ness) |
| 5583 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--1365 2013.01.10 Balázs Gábor (Ness)<br>*++1465 #01. 2013.02.04 Balázs Gábor (Ness) |
| 5584 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--1465 #01. 2013.02.04 Balázs Gábor (Ness)<br>*++1565 #01. 2015.01.26 |
| 5585 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--1108 2010.01.24 BG<br>*++BG 2008.04.02<br>*ONYB bevallások |
| 5586 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--13A60 2012.01.28 BG<br>*++14A60 #01. 2014.02.04 Balázs Gábor (Ness) |
| 5587 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *--14A60 #01. 2014.02.04 Balázs Gábor (Ness)<br>*++15A60 #01. 2015.01.26 |
| 5588 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *++ BG 2007.06.22<br>* Kell az összes adószám mert a 0-ás mezők kezeléséhez szükséges |
| 5589 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | **++BG 2008/01/14<br>*           Transzport miatt áthelyezve a /ZAK/MAIN_EXIT_NEW-ba |
| 5590 | src/#zak#functions.fugr.#zak#lfunctionstop.abap | *++0908 2009.02.27 BG<br>*Önrevízió kezeléséhez |
| 5591 | src/#zak#functions.fugr.#zak#main_exit.abap | ************************************************************************<br>* Bevallás adatok<br>* Bevallás utolsó napjának meghatározás |
| 5592 | src/#zak#functions.fugr.#zak#main_exit.abap | * Bevallás általános adatai |
| 5593 | src/#zak#functions.fugr.#zak#main_exit.abap | *  Bevallás adatszerkezetének kiolvasása |
| 5594 | src/#zak#functions.fugr.#zak#main_exit.abap | *++ BG 2007.05.17<br>*   Display BTYPE gyűjtése |
| 5595 | src/#zak#functions.fugr.#zak#main_exit.abap | *++ BG 2007.05.17<br>*  bevallás Nyomtatvány default értékek |
| 5596 | src/#zak#functions.fugr.#zak#main_exit.abap | *++1365 2013.01.22 Balázs Gábor (Ness)<br>* Nyomtatvány default értékek beállítása ! |
| 5597 | src/#zak#functions.fugr.#zak#main_exit.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 5598 | src/#zak#functions.fugr.#zak#main_exit.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 5599 | src/#zak#functions.fugr.#zak#main_exit.abap | * Bevallás - átvett ABEV-ek |
| 5600 | src/#zak#functions.fugr.#zak#main_exit.abap | * Bevallás - sorok számlálása |
| 5601 | src/#zak#functions.fugr.#zak#main_exit.abap | *++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás<br>*++S4HANA#01.<br>*  SORT T_BEVALLO. |
| 5602 | src/#zak#functions.fugr.#zak#main_exit.abap | *--S4HANA#01.<br>*--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 5603 | src/#zak#functions.fugr.#zak#main_exit.abap | *--1365 #6.<br>*++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 5604 | src/#zak#functions.fugr.#zak#main_exit.abap | *--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 5605 | src/#zak#functions.fugr.#zak#main_exit.abap | *++PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 5606 | src/#zak#functions.fugr.#zak#main_exit.abap | *--PTGSZLAA #03. 2014.03.13 Optimalizált olvasás |
| 5607 | src/#zak#functions.fugr.#zak#main_exit_new.abap | ************************************************************************<br>* Bevallás adatok<br>* Dialógus futás biztosításhoz |
| 5608 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Bevallás utolsó napjának meghatározás |
| 5609 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5610 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Bevallás általános adatai |
| 5611 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5612 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *  Bevallás adatszerkezetének kiolvasása |
| 5613 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5614 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Itt vannak azok az adószámok amikre jött feladás |
| 5615 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Dialógus futás biztosításhoz |
| 5616 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *++ BG 2007.05.17<br>*   Display BTYPE gyűjtése |
| 5617 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *-- BG 2007.05.17<br>*++ BG 2007.06.22<br>*   Összegyűjtjük az adószámokat |
| 5618 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Ha önrevíziós az időszak és nem jött rá adatszolgáltatás<br>*   akkor töröljük. (SZJA) |
| 5619 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *++BG 2006.12.11<br>*   Ha önrevízió, akkor nekünk kell meghatározni a magánszemélyek<br>*   számát<br>*++BG 2007.06.08 |
| 5620 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5621 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *++ BG 2007.05.17<br>*  bevallás Nyomtatvány default értékek |
| 5622 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Bevallás - számított ABEV-ek |
| 5623 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5624 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Nyomtatvány default értékek beállítása ! |
| 5625 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * SZJA önrevíziós pótlék meghatározása |
| 5626 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5627 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Bevallás - átvett ABEV-ek |
| 5628 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5629 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Dialógus futás biztosításhoz |
| 5630 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Becsatolt lapok számának meghatározása<br>*++BG 2006.09.22 |
| 5631 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5632 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *++0808 BG 2008.07.09<br>*   Előjel visszafordítás, |
| 5633 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum törlés helyesbítőnél: |
| 5634 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5635 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5636 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum törlés helyesbítőnél: |
| 5637 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok |
| 5638 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5639 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5640 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum törlés helyesbítőnél: |
| 5641 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok |
| 5642 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5643 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5644 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5645 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok |
| 5646 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5647 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5648 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5649 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok |
| 5650 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5651 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5652 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5653 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5654 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5655 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5656 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *++1408 #02. 2014.03.05 BG<br>*   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5657 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5658 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5659 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5660 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5661 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5662 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5663 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5664 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5665 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5666 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5667 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5668 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5669 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5670 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5671 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5672 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5673 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5674 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5675 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5676 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5677 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Lapszámok, Nyugdíjas |
| 5678 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5679 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5680 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Esedékességi dátum, önell. pótlék nulla flag törlés helyesbítőnél, |
| 5681 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *--2108 #08.<br>*   Bevallás - átvett ABEV-ek |
| 5682 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5683 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5684 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5685 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5686 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5687 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5688 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5689 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Bevallás - átvett ABEV-ek |
| 5690 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *   Előjel visszafordítás, |
| 5691 | src/#zak#functions.fugr.#zak#main_exit_new.abap | *--2508 #01.<br>*++BG 2012.01.17<br>* Adószámok meghatározása |
| 5692 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Adóazonosítónként lapszám meghatározása |
| 5693 | src/#zak#functions.fugr.#zak#main_exit_new.abap | * Kitöröljük az üres mezőket. |
| 5694 | src/#zak#functions.fugr.#zak#new_belnr.abap | *Számkör meghatározása |
| 5695 | src/#zak#functions.fugr.#zak#new_belnr.abap | * Feltöltés azonosító számkör hiba! |
| 5696 | src/#zak#functions.fugr.#zak#new_package_number.abap | *Számkör meghatározása |
| 5697 | src/#zak#functions.fugr.#zak#new_package_number.abap | * Feltöltés azonosító számkör hiba! |
| 5698 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | *   Adatkonzisztencia ellenőrzése |
| 5699 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | *   Ha bármelyik paraméter üres hiba |
| 5700 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | * BEVALLO első sora |
| 5701 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | *++BG 2008.04.16<br>* Vállalat forgatás |
| 5702 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | * Önellenőrzési pótlék beállítás hiba |
| 5703 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | * Nincs adat nem töltünk le semmit |
| 5704 | src/#zak#functions.fugr.#zak#onell_book_excel.abap | * Excel fájl készítése |
| 5705 | src/#zak#functions.fugr.#zak#onyb_xml_download.abap | * Bevallások beállításának beolvasása |
| 5706 | src/#zak#functions.fugr.#zak#onyb_xml_download.abap | * Vállalat név meghatározása |
| 5707 | src/#zak#functions.fugr.#zak#onyb_xml_download.abap | * Adószám meghatározása |
| 5708 | src/#zak#functions.fugr.#zak#onyb_xml_download.abap | * IDŐSZAK -tól |
| 5709 | src/#zak#functions.fugr.#zak#onyb_xml_download.abap | * Nyomtatvány azonosítók: |
| 5710 | src/#zak#functions.fugr.#zak#onyb_xml_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 5711 | src/#zak#functions.fugr.#zak#post_adonsza.abap | * Átvezetéses BTYPE-ok összegyűjtéséhez |
| 5712 | src/#zak#functions.fugr.#zak#post_adonsza.abap | * Adatkonzisztencia ellenőrzése |
| 5713 | src/#zak#functions.fugr.#zak#post_adonsza.abap | * Nyomtatvány adatok beolvasása |
| 5714 | src/#zak#functions.fugr.#zak#post_adonsza.abap | * T_BEVALLO értelmezése, adófolyószámla adatok meghatározása<br>* adatbázis módosítás |
| 5715 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | * Bevallások beállításának beolvasása |
| 5716 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | * Vállalat név meghatározása<br>*++PTGSZLAH #03. |
| 5717 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | * Adószám meghatározása |
| 5718 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | *++PTGSZLAH #03.<br>* IDŐSZAK -tól érték meghatározása |
| 5719 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | * IDŐSZAK -ig érték meghatározása |
| 5720 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | * Nyomtatvány azonosítók: |
| 5721 | src/#zak#functions.fugr.#zak#ptg_xml_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 5722 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | *&---------------------------------------------------------------------*<br>*& KONSTANSOK  (C_XXXXXXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* Bevallás fajta<br>*++S4HANA#01.<br>*  RANGES: R_MONAT FOR /ZAK/ANALITIKA-MONAT. |
| 5723 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * az adószámra volt már feltöltés és lezárt ? |
| 5724 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * Dialógus futás biztosításhoz |
| 5725 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * ...negyedéves |
| 5726 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * ...éves |
| 5727 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * 'E' ha az időszakra a bevallás nincs lezárva |
| 5728 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * 'E' ha az időszakra a bevallás nincs lezárva |
| 5729 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * 'H' ha az időszak már le van zárva, és erre az időszakra már van<br>* feladás |
| 5730 | src/#zak#functions.fugr.#zak#read_abev_exit.abap | * 'P' ha az időszak már le van zárva, és erre az adószámra még nem jött<br>* feladás |
| 5731 | src/#zak#functions.fugr.#zak#read_actual_version.abap | nincs emberi komment blokk |
| 5732 | src/#zak#functions.fugr.#zak#read_adoazon_exit.abap | * MAGÁNSZEMÉLY ADÓSZÁMA<br>* Az adószámokat személyes adataink alapján képzik (10 karakter):<br>* a, Az 1996-os törvény szerint az adószám első száma, a 8-as, állandó<br>* szám, amely azt jelzi, hogy magánszemélyről van szó.<br>* b, A 2-6. számjegyek a személy születési időpontja és az 1867. január<br>* között eltelt napok számát jelöli.<br>* c, A 7-9. számok az azonos napon születettek megkülönböztetésére<br>* szolgál.<br>* d) a 10. számjegy az 1-9. számjegyek felhasználásával matematikai<br>* módszerekkel képzett ellenőrző szám.<br>* Az adóazonosító jel 10. számjegyét úgy kell képezni, hogy az a)-c)<br>* pontok szerint képzett 9 számjegy mindegyikét szorozni kell azzal a<br>* sorszámmal, ahányadik helyet foglalja el az azonosítón belül.<br>* (Első számjegy szorozva eggyel, második számjegy szorozva kettővel és<br>* így tovább.)<br>* Az így kapott szorzatok összegét el kell osztani 11-gyel, és az osztás<br>* maradéka a 10. számjeggyel lesz egyenlő.<br>* A c) pont szerinti születési sorszám nem adható ki, ha a 11-gyel való<br>* osztás maradéka egyenlő tízzel. |
| 5733 | src/#zak#functions.fugr.#zak#read_adoazon_exit.abap | *++BG 2006/05/29<br>*Hiányzott az az eset amikor egynelő ebben az esetben<br>*az adószám utolsó karaktere 0.<br>*      ELSEIF L_SUM < L_NUM. |
| 5734 | src/#zak#functions.fugr.#zak#read_adoazon_exit.abap | * GAZDASÁGI TÁRSASÁGOK ADÓSZÁMA<br>* A helyes adószám 13 jelből áll, és "aaaaaaaa-b-cc" alakú, ahol<br>* "aaaaaaaa", "b" és "cc" mindegyike numerikus.<br>* a, Az "aaaaaaaa" számra teljesülni kell a következőnek (CDV<br>* ellenőrzés):<br>* Az "aaaaaaaa" számjegyeit szorozzuk meg rendre a 9,7,3,1,9,7,3,1<br>* számokkal.<br>* Akkor "CDV-helyes" az adószám, ha az így kapott szorzatok összege<br>* 10-el osztható.<br>* b, A "b" értéke 1,2,3 valamelyike lehet.<br>* c, A "cc" az adóhatóságot jelöli, és 1-44 közötti szám. |
| 5735 | src/#zak#functions.fugr.#zak#read_file_exit.abap | * Dinamikus lapszám kezelés beállítása! |
| 5736 | src/#zak#functions.fugr.#zak#rotate_bukrs_input.abap | * Ellenőrzések |
| 5737 | src/#zak#functions.fugr.#zak#rotate_bukrs_input.abap | * ellenőrizzük szerepel e már a vállalat. |
| 5738 | src/#zak#functions.fugr.#zak#rotate_bukrs_input.abap | *--S4HANA#01.<br>*++0001 BG 2007.01.21<br>*   Vezérlő tábla beolvasása |
| 5739 | src/#zak#functions.fugr.#zak#rotate_bukrs_input.abap | * Ellenőrizzük, hogy létezik-e megfelelő forgatótábla bejegyzés |
| 5740 | src/#zak#functions.fugr.#zak#rotate_bukrs_output.abap | * Kötelező mezők kitöltésének ellenőrzése: |
| 5741 | src/#zak#functions.fugr.#zak#rotate_bukrs_output.abap | *   Vezérlő tábla beolvasása |
| 5742 | src/#zak#functions.fugr.#zak#rotate_idsz.abap | * EU-s műveletkulcsok feltöltése |
| 5743 | src/#zak#functions.fugr.#zak#rotate_idsz.abap | * Kötelező mezők kitöltésének ellenőrzése: |
| 5744 | src/#zak#functions.fugr.#zak#rotate_idsz.abap | * ÁFA irány meghatározás |
| 5745 | src/#zak#functions.fugr.#zak#rotate_idsz.abap | * ellenőrizzük szerepel e már a vállalat. |
| 5746 | src/#zak#functions.fugr.#zak#rotate_idsz.abap | *   Vezérlő tábla beolvasása |
| 5747 | src/#zak#functions.fugr.#zak#rotate_idsz.abap | * Ellenőrizzük, hogy létezik-e megfelelő forgatótábla bejegyzés |
| 5748 | src/#zak#functions.fugr.#zak#saplfunctions.abap | nincs emberi komment blokk |
| 5749 | src/#zak#functions.fugr.#zak#stapo_exit.abap | * statisztika flag törlése!<br>* ismételt feltöltés, vagy feltöltés<br>* azonosítóval létrehozott adatokat törlünk technikai funkcióval,<br>* így a megelőző<br>* indexű lezárt bevallásnál a statisztikai flag-et üresre módosítom |
| 5750 | src/#zak#functions.fugr.#zak#stapo_exit.abap | *         Dialógus futás biztosításhoz |
| 5751 | src/#zak#functions.fugr.#zak#stapo_exit.abap | * statisztika flag jelölése !<br>* Új analitika bejegyzések, így a megelőző<br>* indexű lezárt bevallásnál a statisztikai flag-et 'X'-re módosítom |
| 5752 | src/#zak#functions.fugr.#zak#stapo_exit.abap | *       Dialógus futás biztosításhoz |
| 5753 | src/#zak#functions.fugr.#zak#stapo_exit.abap | *++BG 2007.06.12<br>* Bizonyos esetekben előfodult, hogy az UPDATE funkció nem<br>* jelölte statisztikai tételre fentiekben meghatározott összes<br>* tételt, ami bevallás hibához vezetett, ezért le kell ellenőrizni |
| 5754 | src/#zak#functions.fugr.#zak#stapo_exit.abap | *    Súlyos adatbázis hiba a statisztikai flag jelölésnél! |
| 5755 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | * Beállítás adatok |
| 5756 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *       Csak a kulcs első felét keresi |
| 5757 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | * /ZAK/ANALITIKA srtucturák |
| 5758 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | * ABEV meghatározása |
| 5759 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *  A % mezők meghatározása |
| 5760 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *--1908 #10.<br>*<br>*  RANGES: r_aufnr FOR /zak/szja_cust-aufnr.<br>*  RANGES: r_saknr FOR /zak/szja_cust-saknr.<br>* Az ABEV azonosítókat szedi össze.<br>* Csak az import paraméterekkel meghatározott analitika rekordokhoz<br>* keresi a kulcsot, és később csak ezeket a rekordokat dolgozza fel. |
| 5761 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | * Beállító tábla adatai |
| 5762 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | * Az ABEV azonosítók táblája |
| 5763 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | * Végigmegy a beállítás sorokon és megkeresi hozzá az analitika sorokat. |
| 5764 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *    A rendelésből szelekciót csinál |
| 5765 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *    A főkönyvből sorozatot csinál |
| 5766 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *   kiválogatja az analitoka rekordokat /zak/szja_cust-hoz |
| 5767 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *--0908 2009.02.04 BG<br>*       átveszi a beállításból az adott % mező  (7 - 15. mező) |
| 5768 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *       Csak akkor kell a ANALITIKAból új sor, ha a % ki van töltve<br>*       és létezik |
| 5769 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *++0908 2009.02.04 BG<br>*         Ellenőrizzük létezik van e rekord adatszolgáltatáshoz: |
| 5770 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *--0908 2009.02.04 BG<br>*           költséghely ellenőrzés -> Üres, akkor venni a COST táblából,<br>*           ha ki van töltve |
| 5771 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *       Ha be van állítva, akkor a az eredeti sort is könyvelendőre<br>*       kell  állítani |
| 5772 | src/#zak#functions.fugr.#zak#szja_new_rows.abap | *           költséghely ellenőrzés -> Üres, akkor venni a COST táblából,<br>*           ha ki van töltve |
| 5773 | src/#zak#functions.fugr.#zak#szja_sap_sel_exit.abap | nincs emberi komment blokk |
| 5774 | src/#zak#functions.fugr.#zak#szja_xml_download.abap | * Bevallások beállításának beolvasása |
| 5775 | src/#zak#functions.fugr.#zak#szja_xml_download.abap | * Vállalat név meghatározása |
| 5776 | src/#zak#functions.fugr.#zak#szja_xml_download.abap | * Adószám meghatározása |
| 5777 | src/#zak#functions.fugr.#zak#szja_xml_download.abap | * IDŐSZAK -tól<br>*++2208 #03. |
| 5778 | src/#zak#functions.fugr.#zak#szja_xml_download.abap | * Nyomtatvány azonosítók: |
| 5779 | src/#zak#functions.fugr.#zak#szja_xml_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 5780 | src/#zak#functions.fugr.#zak#tao_file_download.abap | * Bevallások beállításának beolvasása |
| 5781 | src/#zak#functions.fugr.#zak#tao_file_download.abap | * Vállalat név meghatározása |
| 5782 | src/#zak#functions.fugr.#zak#tao_file_download.abap | * Adószám meghatározása |
| 5783 | src/#zak#functions.fugr.#zak#tao_file_download.abap | * Nyomtatvány azonosítók: |
| 5784 | src/#zak#functions.fugr.#zak#tao_file_download.abap | * IDŐSZAKtól: |
| 5785 | src/#zak#functions.fugr.#zak#tao_file_download.abap | * Adatok összeállítása BEVALLO_ALV-ből |
| 5786 | src/#zak#functions.fugr.#zak#user_default.abap | *   Felhasználó dátum formátuma nem 'ÉÉÉÉ.HH.NN'-ra van beállítva! |
| 5787 | src/#zak#functions.fugr.#zak#xml_file_download.abap | *++BG 2006/09/29 Az APEH az XML fájl előállítás átalakította:<br>*az új program amivel az XML fájl előáll RPLVAXH0<br>*az űrlapok a T5HVX táblában találhatók időfüggően<br>*--BG 2006/09/29<br>*++0908/2 2009.08.04 BG<br>* T5HSV -> /ZAK/ZAK_T5HSV<br>* T5HVX -> /ZAK/T5HVX<br>* T5HS7 -> /ZAK/T5HS7<br>* Másoló program : /ZAK/GET_T5HV_TABLES_FROM_HR<br>*--0908/2 2009.08.04 BG |
| 5788 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * XML sorokat tartalmazó tábla |
| 5789 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * Adószámok gyűjtéséhez |
| 5790 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * 'A'-s abev azonosítók |
| 5791 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * INDEX mentése |
| 5792 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * Meghatározzuk a bevallás első napját |
| 5793 | src/#zak#functions.fugr.#zak#xml_file_download.abap | *   Hiányzó import paraméter XML fájl letöltéshez! (Év vagy Hónap) |
| 5794 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * Tábla rendezése |
| 5795 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * Adóazonosítók meghatározása |
| 5796 | src/#zak#functions.fugr.#zak#xml_file_download.abap | *++0808 BG 2008.02.07<br>* Bevallások beállításának beolvasása |
| 5797 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * XML fájl előállítása<br>* XML-header előállítása |
| 5798 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * <ÉV>08A nyomtatvány |
| 5799 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * <ÉV>08M előállítása munkavállalónként |
| 5800 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * XML-footer előállítása |
| 5801 | src/#zak#functions.fugr.#zak#xml_file_download.abap | * XML-fájl kiírása |
| 5802 | src/#zak#get_pack.fugr.#zak#del_pack.abap | nincs emberi komment blokk |
| 5803 | src/#zak#get_pack.fugr.#zak#get_anal.abap | *++1765 #13.<br>* Összeg konverziók |
| 5804 | src/#zak#get_pack.fugr.#zak#lget_packtop.abap | nincs emberi komment blokk |
| 5805 | src/#zak#get_pack.fugr.#zak#open_pack.abap | nincs emberi komment blokk |
| 5806 | src/#zak#get_pack.fugr.#zak#saplget_pack.abap | nincs emberi komment blokk |
| 5807 | src/#zak#get_t5hv_tables_from_hr.prog.abap | * Jogosultság vizsgálat |
| 5808 | src/#zak#get_t5hv_tables_from_hr.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 5809 | src/#zak#get_xx_data.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: a bevallás áttöltéséhez ellenőrző és végrehajtó program<br>*&---------------------------------------------------------------------* |
| 5810 | src/#zak#get_xx_data.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& megjeleníti (ill. éles esetén módosítja) távoli RFC hívás segítségével<br>*& az átvehető bevallásokat ill. kiírja ami már átvételre került.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - Ness<br>*& Létrehozás dátuma : 2017.01.25<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    :<br>*& Program  típus    : Riport<br>*& SAP verzió        :<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&---------------------------------------------------------------------* |
| 5811 | src/#zak#get_xx_data.prog.abap | * Vállalat másik rendszer. |
| 5812 | src/#zak#get_xx_data.prog.abap | * Vállalat saját rendszer |
| 5813 | src/#zak#get_xx_data.prog.abap | * Feltöltés azonosító |
| 5814 | src/#zak#get_xx_data.prog.abap | * Adatszolgáltatási azonosító |
| 5815 | src/#zak#get_xx_data.prog.abap | * Bevallás fajta |
| 5816 | src/#zak#get_xx_data.prog.abap | * Teszt (v. éles) |
| 5817 | src/#zak#get_xx_data.prog.abap | * RFC cél meghatározása az aktuális rendszer függvényében |
| 5818 | src/#zak#get_xx_data.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 5819 | src/#zak#get_xx_data.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 5820 | src/#zak#get_xx_data.prog.abap | *  Szolgáltatás azonosító ellenőrzése |
| 5821 | src/#zak#get_xx_data.prog.abap | *  AFA bevallás típus ellenőrzése |
| 5822 | src/#zak#get_xx_data.prog.abap | *    Kérem ÁFA típusú bevallás azonosítót adjon meg! |
| 5823 | src/#zak#get_xx_data.prog.abap | * A P_BUKRS paraméter mezőben lévő tartalom beolvasása |
| 5824 | src/#zak#get_xx_data.prog.abap | * Az összes vállalathoz tartozó feltöltési azonosító lekérése |
| 5825 | src/#zak#get_xx_data.prog.abap | * A keresési segítség megjelenítése |
| 5826 | src/#zak#get_xx_data.prog.abap | *   Összeg konverzió belső HUF formátumra |
| 5827 | src/#zak#get_xx_data.prog.abap | * Válallat pénznem meghatározása |
| 5828 | src/#zak#get_xx_data.prog.abap | *  Vállalati adatok beolvasása |
| 5829 | src/#zak#get_xx_data.prog.abap | * Az összes vállalathoz tartozó feltöltési azonosító lekérése |
| 5830 | src/#zak#get_xx_data.prog.abap | * Az adott nem áttöltött feltöltési azonosító(k)hoz tartozó analitika begyűjtése |
| 5831 | src/#zak#get_xx_data.prog.abap | *     Vállalat átforgatás |
| 5832 | src/#zak#get_xx_data.prog.abap | *     Pénznem kezelés |
| 5833 | src/#zak#get_xx_data.prog.abap | *   Vállalat forgatás AFA_SZLA |
| 5834 | src/#zak#get_xx_data.prog.abap | *--2014.12.17 BG<br>*   /ZAK/UPDATE hívas egyenként a vállalat és feltöltés azonosítóra |
| 5835 | src/#zak#get_xx_data.prog.abap | * Ellenőriztük már |
| 5836 | src/#zak#get_xx_data.prog.abap | *   & vállalat & bevallás típushoz & adatszolgáltatás nincs beállítva! |
| 5837 | src/#zak#igazolas.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Magánszemélyek igazolás kiállítása<br>*&---------------------------------------------------------------------* |
| 5838 | src/#zak#igazolas.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a feltöltés azonosító(k) alapján leválogat-<br>*& ja a releváns adatokat és SMARTFORMS űrlappal előállítja az igazolást<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2008.02.28<br>*& Funkc.spec.készítő: Róth Nándor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&--------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2008.11.14   Balázs Gábor  Sorszám kialakítás vállalatonként,<br>*&                                   keltezés megadása szelekción<br>*& 0002   2009.02.27   Balázs Gábor  BTYPE átadás smartforms-nak<br>*& 0003   2009.03.03   Balázs Gábor  Pozíció bevezetés (több ABEVAZ<br>*&                                   egy sorban)<br>*& 0004   2009.09.09   Balázs Gábor  Összesítés javítás (több BSZNUM<br>*&                                   lehívás miatt).<br>*&---------------------------------------------------------------------* |
| 5839 | src/#zak#igazolas.prog.abap | *Adatdeklaráció |
| 5840 | src/#zak#igazolas.prog.abap | *Közös rutinok |
| 5841 | src/#zak#igazolas.prog.abap | *Vállalat |
| 5842 | src/#zak#igazolas.prog.abap | *Bevallás típus: |
| 5843 | src/#zak#igazolas.prog.abap | *Adatszolgáltatás azonosítók: |
| 5844 | src/#zak#igazolas.prog.abap | *++0001 2008.11.14 BG<br>*Keltezés |
| 5845 | src/#zak#igazolas.prog.abap | *--0001 2008.11.14 BG<br>*Teszt futás |
| 5846 | src/#zak#igazolas.prog.abap | *++0001 2008.12.01 (BG)<br>*Háttérben spool vezerlés |
| 5847 | src/#zak#igazolas.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 5848 | src/#zak#igazolas.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 5849 | src/#zak#igazolas.prog.abap | * Bevallás fajta meghatározás |
| 5850 | src/#zak#igazolas.prog.abap | *  Jogosultság vizsgálat |
| 5851 | src/#zak#igazolas.prog.abap | * Adatszolgáltatás azonosítók gyűjtése: |
| 5852 | src/#zak#igazolas.prog.abap | *   Nincs beállítva igazolást igénylő feltöltés azonosító! |
| 5853 | src/#zak#igazolas.prog.abap | * Beállítások meghatározása |
| 5854 | src/#zak#igazolas.prog.abap | *   Nem található beállítás a & vállalatra az igazolás adataihoz! |
| 5855 | src/#zak#igazolas.prog.abap | * Feltöltés azonosítók gyűjtése |
| 5856 | src/#zak#igazolas.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 5857 | src/#zak#igazolas.prog.abap | * Adatok gyűjtése |
| 5858 | src/#zak#igazolas.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 5859 | src/#zak#igazolas.prog.abap | * Adatok feldolgozása |
| 5860 | src/#zak#igazolas.prog.abap | * Üzenetek megjelenítése |
| 5861 | src/#zak#igazolas.prog.abap | * Éles futás űrlap nyomtatás, adatok módosítása |
| 5862 | src/#zak#igazolas.prog.abap | * Összegyűjtjük a releváns ABEV azonosítókat |
| 5863 | src/#zak#igazolas.prog.abap | * Adószámok gyűjtése |
| 5864 | src/#zak#igazolas.prog.abap | *   Feltöltésazonosító gyűjtések időszakonként. |
| 5865 | src/#zak#igazolas.prog.abap | * Feltöltés azonosítók rendezése |
| 5866 | src/#zak#igazolas.prog.abap | * Adóazonosítók rendezése |
| 5867 | src/#zak#igazolas.prog.abap | *   Cím adat meghatározása |
| 5868 | src/#zak#igazolas.prog.abap | *   & adóazonosító cím adatai nem találhatók! |
| 5869 | src/#zak#igazolas.prog.abap | *& igazolás sor azonosító adatai nem található! |
| 5870 | src/#zak#igazolas.prog.abap | *& igazolás sor azonosító szöveg adatai nem található! |
| 5871 | src/#zak#igazolas.prog.abap | *   A feldolgozás nem tartalmaz hibát! |
| 5872 | src/#zak#igazolas.prog.abap | * Adatok gyűjtése |
| 5873 | src/#zak#igazolas.prog.abap | * Feldolgozás adóazonosítónként, és packagenként |
| 5874 | src/#zak#igazolas.prog.abap | *         Ha dátum formátumú a sor |
| 5875 | src/#zak#igazolas.prog.abap | *         ha normál fomátum<br>*++2108 #21.<br>*          ELSE. |
| 5876 | src/#zak#igazolas.prog.abap | * Ellenőrizzük, hogy a kötelező mezők megvannak-e : |
| 5877 | src/#zak#igazolas.prog.abap | *   Ellenőrizzük megvan e a mező |
| 5878 | src/#zak#igazolas.prog.abap | *Megvannak az adatok lehet számolni:<br>*Először meghatározzuk az alap összegeket |
| 5879 | src/#zak#igazolas.prog.abap | *     Összesítő sor |
| 5880 | src/#zak#igazolas.prog.abap | *     Nem létezik létre kell hozni |
| 5881 | src/#zak#igazolas.prog.abap | *     Létezik módosítani kell |
| 5882 | src/#zak#igazolas.prog.abap | * ALV-hez feltöltés mező nevekkel: |
| 5883 | src/#zak#igazolas.prog.abap | *Pénznem szövegek meghatározása |
| 5884 | src/#zak#igazolas.prog.abap | * Nem háttér futás |
| 5885 | src/#zak#igazolas.prog.abap | * Háttér futás |
| 5886 | src/#zak#igazolas.prog.abap | * Csak élesben |
| 5887 | src/#zak#igazolas.prog.abap | *ellenőrizzük van e ERROR üzenet |
| 5888 | src/#zak#igazolas.prog.abap | *   Éles futás hibák miatt nem indítható! |
| 5889 | src/#zak#igazolas.prog.abap | * Űrlap adatok meghatározása |
| 5890 | src/#zak#igazolas.prog.abap | *   Hiba a & űrlap beolvasásánál! |
| 5891 | src/#zak#igazolas.prog.abap | * Feldolgozás adóazonosítónként |
| 5892 | src/#zak#igazolas.prog.abap | *   Címadatok meghatározása |
| 5893 | src/#zak#igazolas.prog.abap | *     Ha vége egy sorszámnak |
| 5894 | src/#zak#igazolas.prog.abap | * Adatbázis módosítása |
| 5895 | src/#zak#igazolas.prog.abap | *   Üzenetek megjelenítése |
| 5896 | src/#zak#igazolas.prog.abap | *   Űrlap megjelenítés |
| 5897 | src/#zak#igazolas.prog.screen_0100.abap | nincs emberi komment blokk |
| 5898 | src/#zak#igazolas_view.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Magánszemélyek igazolás megjelenítése<br>*&---------------------------------------------------------------------*<br>*&<br>*&<br>*&---------------------------------------------------------------------* |
| 5899 | src/#zak#igazolas_view.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a már kiállított igazolásokat tudja<br>*& megjeleníteni és kinyomtatni<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2008.03.12<br>*& Funkc.spec.készítő: Róth Nándor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&--------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&<br>*&---------------------------------------------------------------------* |
| 5900 | src/#zak#igazolas_view.prog.abap | *Adatdeklaráció |
| 5901 | src/#zak#igazolas_view.prog.abap | *Közös rutinok |
| 5902 | src/#zak#igazolas_view.prog.abap | *Vállalat |
| 5903 | src/#zak#igazolas_view.prog.abap | *Adóazonosító: |
| 5904 | src/#zak#igazolas_view.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 5905 | src/#zak#igazolas_view.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 5906 | src/#zak#igazolas_view.prog.abap | * Jogosultság vizsgálat |
| 5907 | src/#zak#igazolas_view.prog.abap | * Háttérfutás vizsgálat: |
| 5908 | src/#zak#igazolas_view.prog.abap | *   A program háttérben nem futtatható! |
| 5909 | src/#zak#igazolas_view.prog.abap | * Adatok szelektálása |
| 5910 | src/#zak#igazolas_view.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 5911 | src/#zak#igazolas_view.prog.abap | * ALV-hez feltöltés mező nevekkel: |
| 5912 | src/#zak#igazolas_view.prog.abap | * Pénznem szövegek meghatározása |
| 5913 | src/#zak#igazolas_view.prog.abap | * Címadatok beolvasása |
| 5914 | src/#zak#igazolas_view.prog.abap | *++0001 2008.11.14 BG<br>* MTP rendszeren nem nem megfelelő a rendezettség, hiába<br>* kulcs az adóazonosító |
| 5915 | src/#zak#igazolas_view.prog.abap | * Adatszolgáltatás azonosítók beolvasása |
| 5916 | src/#zak#igazolas_view.prog.abap | * Beállítások beolvasása |
| 5917 | src/#zak#igazolas_view.prog.abap | *   Űrlap megjelenítés |
| 5918 | src/#zak#igazolas_view.prog.screen_0100.abap | nincs emberi komment blokk |
| 5919 | src/#zak#igf01.prog.abap | * Kijelölt tételek meghatározása |
| 5920 | src/#zak#igf01.prog.abap | *   Kérem jelöljön ki egy tételt. |
| 5921 | src/#zak#igf01.prog.abap | * Űrlap adatok meghatározása |
| 5922 | src/#zak#igf01.prog.abap | *   Hiba a & űrlap beolvasásánál! |
| 5923 | src/#zak#igf01.prog.abap | * Adatok feldolgozása |
| 5924 | src/#zak#igf01.prog.abap | *   Címadatok meghatározása |
| 5925 | src/#zak#igf01.prog.abap | *     Kitöröljük a kijelölésből |
| 5926 | src/#zak#igf01.prog.abap | *   Űrlap meghívása |
| 5927 | src/#zak#igf01.prog.abap | * Igazolás sor megnevezése |
| 5928 | src/#zak#igf01.prog.abap | * Adatszolgáltatás azonosító megnevezése |
| 5929 | src/#zak#igf01.prog.abap | *  Adatok feltöltése |
| 5930 | src/#zak#igf01.prog.abap | * Hónap megnevezésének meghatározása |
| 5931 | src/#zak#igf01.prog.abap | *++0001 2008.12.01 (BG)<br>* Háttérben kiviteli paraméterek beállítása |
| 5932 | src/#zak#igf01.prog.abap | *   Hiba a & űrlap & adószám & sorszám kivitelénél! |
| 5933 | src/#zak#igtop.prog.abap | *&---------------------------------------------------------------------*<br>*&  Include           /ZAK/IGTOP<br>*&---------------------------------------------------------------------*<br>*& /ZAK/ZAKO igazolás adatdeklarálás<br>*&---------------------------------------------------------------------* |
| 5934 | src/#zak#igtop.prog.abap | *Formátumok |
| 5935 | src/#zak#igtop.prog.abap | *MAKRO definiálás range feltöltéshez |
| 5936 | src/#zak#igtop.prog.abap | *Adatszolgáltatás azonosítók: |
| 5937 | src/#zak#igtop.prog.abap | *Pénznem megnevezéséhez: |
| 5938 | src/#zak#igtop.prog.abap | *Feltöltés azonosítók |
| 5939 | src/#zak#igtop.prog.abap | *Adóazonosítók gyűjtése |
| 5940 | src/#zak#kata_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/KATA_SEL-be<br>*& tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor<br>*& Létrehozás dátuma : 2021.02.17<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : /ZAK/ZAKO<br>*& Program  típus    : Riport<br>*& SAP verzió        :<br>*&--------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&                                   módosítása<br>*&---------------------------------------------------------------------* |
| 5941 | src/#zak#kata_sap_sel.prog.abap | *MAKRO definiálás range feltöltéshez |
| 5942 | src/#zak#kata_sap_sel.prog.abap | * ALV kezelési változók |
| 5943 | src/#zak#kata_sap_sel.prog.abap | * Vállalat. |
| 5944 | src/#zak#kata_sap_sel.prog.abap | * Bevallás típus. |
| 5945 | src/#zak#kata_sap_sel.prog.abap | *Hónap |
| 5946 | src/#zak#kata_sap_sel.prog.abap | *Test futás |
| 5947 | src/#zak#kata_sap_sel.prog.abap | *++2265 #02.<br>* Jogosultság vizsgálat |
| 5948 | src/#zak#kata_sap_sel.prog.abap | *  Vállalat forgatás |
| 5949 | src/#zak#kata_sap_sel.prog.abap | *  Jogosultság vizsgálat |
| 5950 | src/#zak#kata_sap_sel.prog.abap | * Hónap utolsó napja: |
| 5951 | src/#zak#kata_sap_sel.prog.abap | * Package azonosítók meghatározása |
| 5952 | src/#zak#kata_sap_sel.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 5953 | src/#zak#kata_sap_sel.prog.abap | *  KATA beállítások betöltése |
| 5954 | src/#zak#kata_sap_sel.prog.abap | *   Hiba a KATA beállítások meghatározásánál! |
| 5955 | src/#zak#kata_sap_sel.prog.abap | * Analitika rekordok leválogatása |
| 5956 | src/#zak#kata_sap_sel.prog.abap | * Teszt vagy éles futás, adatbázis módosítás, stb. |
| 5957 | src/#zak#kata_sap_sel.prog.abap | *  Háttérben nem készítünk listát. |
| 5958 | src/#zak#kata_sap_sel.prog.abap | *      Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPUT) |
| 5959 | src/#zak#kata_sap_sel.prog.abap | *Package-k gyűjtése |
| 5960 | src/#zak#kata_sap_sel.prog.abap | *   Kérem a hónapot 01 és 12 között adja meg! |
| 5961 | src/#zak#kata_sap_sel.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 5962 | src/#zak#kata_sap_sel.prog.abap | *   Műveletsor nélkül is |
| 5963 | src/#zak#kata_sap_sel.prog.abap | *   Csak alapot szelektálunk |
| 5964 | src/#zak#kata_sap_sel.prog.abap | *       Nem lehet feldolgozási időszakot meghatározni! & & & & |
| 5965 | src/#zak#kata_sap_sel.prog.abap | *       Nem lehet feldolgozási időszakot meghatározni! & & & & |
| 5966 | src/#zak#kata_sap_sel.prog.abap | *   IDŐSZAKot a BUDAT alapján képezzük |
| 5967 | src/#zak#kata_sap_sel.prog.abap | *   Adószám a STCD1-ből jön |
| 5968 | src/#zak#kata_sap_sel.prog.abap | *   Cím adatok ellenőrzése |
| 5969 | src/#zak#kata_sap_sel.prog.abap | *   Feldolgozás során előfordultak üzenetek! |
| 5970 | src/#zak#kata_sap_sel.prog.abap | *   Éles futás hibák miatt nem indítható! |
| 5971 | src/#zak#kata_sap_sel.prog.abap | *   Adatmódosítások elmentve! |
| 5972 | src/#zak#kata_sap_sel.prog.abap | * Mezőkatalógus összeállítása |
| 5973 | src/#zak#kata_sap_sel.prog.abap | * Kilépés |
| 5974 | src/#zak#kata_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 5975 | src/#zak#main_batch.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: /ZAK/MAIN_VIEW ütemező program<br>*&---------------------------------------------------------------------* |
| 5976 | src/#zak#main_batch.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: /ZAK/MAIN_VIEW ütemező program<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - NESS<br>*& Létrehozás dátuma : 2014.10.14<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 60<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&                                   migrációhoz lehessen használni.<br>*&---------------------------------------------------------------------* |
| 5977 | src/#zak#main_batch.prog.abap | *MAKRO definiálás range feltöltéshez |
| 5978 | src/#zak#main_batch.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 5979 | src/#zak#main_batch.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 5980 | src/#zak#main_batch.prog.abap | *Meghatározzuk a nyitott időszakokat: |
| 5981 | src/#zak#main_batch.prog.abap | *   Nem a feltételnek megfelelő rekordot meghatározni! |
| 5982 | src/#zak#main_batch.prog.abap | * Jobok ütemezése: |
| 5983 | src/#zak#main_batch.prog.abap | * ÁFA jellegű bevallások önrevíziója kummulált |
| 5984 | src/#zak#main_batch.prog.abap | * Bevallás fajta meghatározás |
| 5985 | src/#zak#main_batch.prog.abap | * Nyitott és letöltött státusz feltöltése |
| 5986 | src/#zak#main_batch.prog.abap | * BEVALLI adatok szelektálása |
| 5987 | src/#zak#main_batch.prog.abap | *   /ZAK/MAIN_VIEW indítása |
| 5988 | src/#zak#main_batch.prog.abap | *   Jobok beütemezve, kérem ellenőrizze a JOB naplót! |
| 5989 | src/#zak#main_top.prog.abap | * Dynpro mezők |
| 5990 | src/#zak#main_view.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Adatállomány készítő, megjelenítő, manuális rögzítő program<br>*&---------------------------------------------------------------------* |
| 5991 | src/#zak#main_view.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Adatállomány készítő, megjelenítő, manuális rögzítő<br>*& program<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - fmc<br>*& Létrehozás dátuma : 2006.01.05<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES xxxxxxxxxx<br>*&                                   cseréje hagyományosra<br>*& 0002   2007.01.03   Balázs G.     CL_GUI_FRONTEND_SERVICES vissza<br>*& 0003   2007.01.31   Balázs G.     Esedékességi dátum töltése<br>*& 0004   2007.04.04   Balázs G.     Összesítő jelentés kiegészítés ONYB<br>*& 0005   2007.05.30   Balázs G.     ÁFA 04, 06 lap kezelése<br>*& 0006   2007.07.02   Balázs G.     ÁFA alap ellenőrzés<br>*& 0007   2007.07.23   Balázs G.     Esedékességi dátum meghatározása<br>*&                                   termelési naptár alapján<br>*& 0008   2007.08.06   Balázs G.     ÁFA összegek ellenőrzése<br>*& 0009   2007.12.17   Balázs G.     ÁFA arányosítás kezelése<br>*& 0010   2008.02.14   Balázs G.     Figyelmeztetés ha van az időszakban<br>*&                                   más bevallás típus is<br>*& 0011   2008.03.28   Balázs G.     Részletező sorok arányosított<br>*&                                   értékeinek meghatározása<br>*& 0012   2008.04.02   Balázs G.     Összesítő jelentés kiterjesztése<br>*&                                   ONYB (szállítók, vevők)<br>*& 0013   2008.09.01   Balázs G.     N.éves arányosításnál előző időszak<br>*&                                   gyűjtés javítása<br>*& 0014   2008.09.08   Balázs G.     Arányosítás előző időszak ABEV-ek<br>*&                                   módosítása, könyvelési feladás<br>*&                                   módosítása<br>*& 0015   2009.02.02   Balázs G.     ÁFA 0965 változások beépítése<br>*& 0016   2011.09.14   Balázs G.     Csoport vállalat kezelése<br>*& 0017   2012.02.07   Balázs G.     Manuális rögzítés más időszakra is<br>*&---------------------------------------------------------------------* |
| 5992 | src/#zak#main_view.prog.abap | * Dolgozói adatok |
| 5993 | src/#zak#main_view.prog.abap | * Adóazonosítók |
| 5994 | src/#zak#main_view.prog.abap | * Konvertált |
| 5995 | src/#zak#main_view.prog.abap | *--0005 BG 2007.05.30<br>* ALV kezelési változók |
| 5996 | src/#zak#main_view.prog.abap | *++0004 BG 2007.04.26<br>*MAKRO definiálás range feltöltéshez |
| 5997 | src/#zak#main_view.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness)<br>*++2065 #06. |
| 5998 | src/#zak#main_view.prog.abap | *Speciális időszak kezeleése |
| 5999 | src/#zak#main_view.prog.abap | *++2012.01.06 BG<br>*  Feltöltjük a beadás dátumát |
| 6000 | src/#zak#main_view.prog.abap | *--2012.01.06 BG<br>*++1765 #19.<br>* Jogosultság vizsgálat |
| 6001 | src/#zak#main_view.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6002 | src/#zak#main_view.prog.abap | * Normál, önrevízió, megjelenítés: S_ szelekciók feltöltése |
| 6003 | src/#zak#main_view.prog.abap | * Bevallás típus meghatározása |
| 6004 | src/#zak#main_view.prog.abap | * Bevallás utolsó napjának meghatározása |
| 6005 | src/#zak#main_view.prog.abap | *++0016 BG 2011.09.14<br>*  Csoportos vállalat meghatározás |
| 6006 | src/#zak#main_view.prog.abap | *--0016 BG 2011.09.14<br>*  Jogosultság vizsgálat |
| 6007 | src/#zak#main_view.prog.abap | * Zárolás beállítás |
| 6008 | src/#zak#main_view.prog.abap | * Bevallás általános adatai |
| 6009 | src/#zak#main_view.prog.abap | *  Bevallás adatszerkezetének kiolvasása |
| 6010 | src/#zak#main_view.prog.abap | *++0015 0965 2009.02.02 BG<br>* ÁFA 0965-től nem szükséges mivel a 0865-ig konvertálva lett,<br>* utána pedig mindig a saját típusa lesz a display-es. |
| 6011 | src/#zak#main_view.prog.abap | *--0009 BG 2007.12.17<br>*  Összeg sorok számítása |
| 6012 | src/#zak#main_view.prog.abap | *    Ellenőrzés hívása |
| 6013 | src/#zak#main_view.prog.abap | *    ÁFA összegek konzisztensek! |
| 6014 | src/#zak#main_view.prog.abap | *++1365 #21.<br>*  BEVALLO aktualizálás batch futás |
| 6015 | src/#zak#main_view.prog.abap | * Vállalat megnevezése |
| 6016 | src/#zak#main_view.prog.abap | * Bevallásfajta megnevezése |
| 6017 | src/#zak#main_view.prog.abap | * Normál |
| 6018 | src/#zak#main_view.prog.abap | *++0008 BG 2007.08.06<br>*      Ha nem ÁFA nem kell az ellenőrző gomb |
| 6019 | src/#zak#main_view.prog.abap | * Önrevízió |
| 6020 | src/#zak#main_view.prog.abap | *++0008 BG 2007.08.06<br>*      Ha nem ÁFA nem kell az ellenőrző gomb |
| 6021 | src/#zak#main_view.prog.abap | * Megjelenítés |
| 6022 | src/#zak#main_view.prog.abap | *--2065 #06.<br>*++0008 BG 2007.08.06<br>*      Megjelenítésnél nem kell az ellenőrzés gomb |
| 6023 | src/#zak#main_view.prog.abap | * Mezőkatalógus összeállítása |
| 6024 | src/#zak#main_view.prog.abap | * Karakteres sor? Más a mezőkatalógus!<br>* Editálható mező: XDEFT - radio-button |
| 6025 | src/#zak#main_view.prog.abap | * Dolgozó bekérése |
| 6026 | src/#zak#main_view.prog.abap | * Bevallás készítő |
| 6027 | src/#zak#main_view.prog.abap | * Státuszellenőrzés<br>* Normál bevallás<br>* Ha nincs meg az összes adatszolgáltatás nem lehet indítani |
| 6028 | src/#zak#main_view.prog.abap | * Adatszerkezet szerinti konverzió<br>* Dolgozói rekordok hozzáfűzése |
| 6029 | src/#zak#main_view.prog.abap | *--1365 #21.<br>* Státusz aktualizálása /ZAK/BEVALLSZ |
| 6030 | src/#zak#main_view.prog.abap | *        ÁFA összegek konzisztensek! |
| 6031 | src/#zak#main_view.prog.abap | * Kilépés |
| 6032 | src/#zak#main_view.prog.abap | * Normál, önrevízió, megjelenítés: S_ szelekciók feltöltése |
| 6033 | src/#zak#main_view.prog.abap | * Bevallás típus meghatározása |
| 6034 | src/#zak#main_view.prog.abap | * Bevallás utolsó napjának meghatározás |
| 6035 | src/#zak#main_view.prog.abap | * ...negyedéves |
| 6036 | src/#zak#main_view.prog.abap | * ...éves |
| 6037 | src/#zak#main_view.prog.abap | * Van-e a megadott periódusra adat? |
| 6038 | src/#zak#main_view.prog.abap | * Önrevíziónál: előfeltétel, hogy a 000 le legyen zárva |
| 6039 | src/#zak#main_view.prog.abap | * csak az éppen nyitott sorszám írható, vagy - ha  nincs nyitott - csak<br>* az utolsó lezártnál eggyel nagyobb sorszám |
| 6040 | src/#zak#main_view.prog.abap | *     Kérem adja meg az esedékesség dátum értékét a szelekción!<br>*++0007 BG 2007.07.23<br>*    Esedékességi dátum konvertálás |
| 6041 | src/#zak#main_view.prog.abap | *  Csak ha ki van töltve az érték |
| 6042 | src/#zak#main_view.prog.abap | *   Kérem a hónapot 01 és 12 között adja meg! |
| 6043 | src/#zak#main_view.prog.abap | * A beállítások alapján erre az időszakra nem választható spec.időszak! |
| 6044 | src/#zak#main_view.prog.abap | *--0016 BG 2011.12.08<br>*++1765 #16.<br>*  ÁFA 07,08 lapok feldolgozása |
| 6045 | src/#zak#main_view.prog.abap | * N - Negyedéves |
| 6046 | src/#zak#main_view.prog.abap | *--PTGSZLAA #01. 2014.03.03<br>*++2365 #03.<br>*  Speciális időszak megadása |
| 6047 | src/#zak#main_view.prog.abap | *      Speciális időszak nem megfelelő! |
| 6048 | src/#zak#main_view.prog.abap | *       Az analitikia tartalmaz & bevallás típustól eltérő tételt! |
| 6049 | src/#zak#main_view.prog.abap | *--1765 #08.<br>*++0016 BG 2011.09.14<br>* Csoport vállalatnál vállalat kód csere és sorszám frissítés az<br>* aktuális időszakra. |
| 6050 | src/#zak#main_view.prog.abap | * Analitika törlése |
| 6051 | src/#zak#main_view.prog.abap | *      Analitika létrehozás |
| 6052 | src/#zak#main_view.prog.abap | *      Státuszok beállítása feltöltöttre |
| 6053 | src/#zak#main_view.prog.abap | *            Ha még nincs ezzel a kulccsal - lementem |
| 6054 | src/#zak#main_view.prog.abap | *              Önrevízió - esdékességi dátum |
| 6055 | src/#zak#main_view.prog.abap | *            Van már ilyen kulccsal |
| 6056 | src/#zak#main_view.prog.abap | *              Ez a default szöveg - módosítom a lementettet |
| 6057 | src/#zak#main_view.prog.abap | *++0005 BG 2007.05.30<br>*           ÁFA esetén ha ki van töltve a sor/oszlop akkor nem kell |
| 6058 | src/#zak#main_view.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 6059 | src/#zak#main_view.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 6060 | src/#zak#main_view.prog.abap | *++0005 BG 2007.05.30<br>*      ÁFA típus 04, 06-os lap feldolgozása |
| 6061 | src/#zak#main_view.prog.abap | *--0005 BG 2007.09.25<br>*        Meghatározzuk az utolsó naphoz milyen beállítás tartozik |
| 6062 | src/#zak#main_view.prog.abap | *Nincs beállítás a /ZAK/BNYLAP táblában! (Vállalat: &, típus: &, dátum:<br>*&). |
| 6063 | src/#zak#main_view.prog.abap | *++1565 #01.<br>*          Ha nem kivetéses, akkor nem kell az XBLNR-t figyelembe venni<br>*          az összesítésnél |
| 6064 | src/#zak#main_view.prog.abap | *--1565 #01.<br>*        Megatározzuk a legnagyobb sor-indexet |
| 6065 | src/#zak#main_view.prog.abap | *Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához! |
| 6066 | src/#zak#main_view.prog.abap | *        Adatok feltöltése |
| 6067 | src/#zak#main_view.prog.abap | *        Ha van adat, feldolgozás |
| 6068 | src/#zak#main_view.prog.abap | *          Vámhatározat szám töltése |
| 6069 | src/#zak#main_view.prog.abap | *--0965 2009.02.23 BG<br>*            Vámhatározat közlésének napja |
| 6070 | src/#zak#main_view.prog.abap | *            Fizetendő adó összege |
| 6071 | src/#zak#main_view.prog.abap | *            Befizetési bizonylat száma |
| 6072 | src/#zak#main_view.prog.abap | *            Megfizetés időpontja |
| 6073 | src/#zak#main_view.prog.abap | *            Fizetett adó összege |
| 6074 | src/#zak#main_view.prog.abap | *          06-os lap töltése<br>*++0965 2009.02.23 BG<br>*            ELSEIF W_/ZAK/BNYLAP-NYLAPAZON EQ C_NYLAPAZON_06. |
| 6075 | src/#zak#main_view.prog.abap | *--0965 2009.02.23 BG<br>*            Vámhatározat közlésének napja |
| 6076 | src/#zak#main_view.prog.abap | *            Vámhatározatban szereplő vám érték |
| 6077 | src/#zak#main_view.prog.abap | *            Vám értéket növelő összeg |
| 6078 | src/#zak#main_view.prog.abap | *--1365 #21.<br>*          Számlaszámok összegzése M-es rekordok képzése |
| 6079 | src/#zak#main_view.prog.abap | *          ABEV azonosítók feldolgozása |
| 6080 | src/#zak#main_view.prog.abap | *++1765 #16.<br>*        ÁFA 07,08 lapok feldolgozása<br>*        Meghatározzuk milyen lapok vannak és sorrendben dolgozzuk fel: |
| 6081 | src/#zak#main_view.prog.abap | *        Feldolgozás |
| 6082 | src/#zak#main_view.prog.abap | *            Megatározzuk a legnagyobb sor-indexet |
| 6083 | src/#zak#main_view.prog.abap | *              Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához! |
| 6084 | src/#zak#main_view.prog.abap | *            Adatok feltöltése |
| 6085 | src/#zak#main_view.prog.abap | *              Vevő adószám töltése |
| 6086 | src/#zak#main_view.prog.abap | *              Teljesítés napja |
| 6087 | src/#zak#main_view.prog.abap | *              Termék megnevezése |
| 6088 | src/#zak#main_view.prog.abap | *                    & vámtarifaszámnak nem határozható meg a megnevezése! |
| 6089 | src/#zak#main_view.prog.abap | *              Vámtarifaszám |
| 6090 | src/#zak#main_view.prog.abap | *              Mennyiség |
| 6091 | src/#zak#main_view.prog.abap | *              Adóalap |
| 6092 | src/#zak#main_view.prog.abap | *--0005 BG 2007.05.30<br>*--1365 2013.01.10 Balázs Gábor (Ness)<br>*++0004 BG 2007.04.04<br>*++PTGSZLAA #01. 2014.03.03<br>*     ELSE. "C_BTYPART_ONYB |
| 6093 | src/#zak#main_view.prog.abap | *--PTGSZLAA #01. 2014.03.03<br>*      Adatok gyűjtése saját struktúrába. |
| 6094 | src/#zak#main_view.prog.abap | *      Önrevíziós kezelése |
| 6095 | src/#zak#main_view.prog.abap | *        Range feltöltése |
| 6096 | src/#zak#main_view.prog.abap | *        000-tól az aktuális index-1 ig keresünk értékeket<br>*        az analitikában. |
| 6097 | src/#zak#main_view.prog.abap | *        Adatok keresése előző index-ekben |
| 6098 | src/#zak#main_view.prog.abap | *          ADOAZON képzése |
| 6099 | src/#zak#main_view.prog.abap | *          Előző időszakokban értékek kezelése |
| 6100 | src/#zak#main_view.prog.abap | *            Talált rekordot, törölni kell |
| 6101 | src/#zak#main_view.prog.abap | *Hozzáadjuk az aktuális index elé, hogy már ne vegye újra figyelembe |
| 6102 | src/#zak#main_view.prog.abap | *            Nincs az előző időszakokban adat, módosítjuk a flag-et |
| 6103 | src/#zak#main_view.prog.abap | *--0004 BG 2007.04.19<br>*++0012 BG 2008.04.02<br>*      Meghatározzuk, hogy mennyi NYLAPAZON létezik a /ZAK/BEVALLB-ben<br>*      és ezeket olvassuk végig |
| 6104 | src/#zak#main_view.prog.abap | *Nincs nyomtatvány lap azonosító beállítás a & bevallás fajtához! |
| 6105 | src/#zak#main_view.prog.abap | *--0012 BG 2008.04.02<br>*++0012 BG 2008.04.02<br>*      Feldolgozás lap azonosítónként |
| 6106 | src/#zak#main_view.prog.abap | *--0012 BG 2008.04.02<br>*      Megatározzuk a legnagyobb sor-indexet |
| 6107 | src/#zak#main_view.prog.abap | *        Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához! |
| 6108 | src/#zak#main_view.prog.abap | *      Adatok feltöltése |
| 6109 | src/#zak#main_view.prog.abap | *        Országkód töltése |
| 6110 | src/#zak#main_view.prog.abap | *        Adószám töltése |
| 6111 | src/#zak#main_view.prog.abap | *        Összeg töltése |
| 6112 | src/#zak#main_view.prog.abap | *        Háromszögügylet töltése |
| 6113 | src/#zak#main_view.prog.abap | *        Önrevíziós flag töltése |
| 6114 | src/#zak#main_view.prog.abap | *++0004 BG 2007.05.24<br>*        Helyesbítés oka töltése |
| 6115 | src/#zak#main_view.prog.abap | *      A-s ABEV azonosítókat létre hozzuk! |
| 6116 | src/#zak#main_view.prog.abap | *--PTGSZLAH #02. 2015.01.30<br>*        Pénztárátvételi hely meghatározása |
| 6117 | src/#zak#main_view.prog.abap | *            & pénztárvételi hely nem létezik! |
| 6118 | src/#zak#main_view.prog.abap | *      Meghatározzuk az utolsó naphoz milyen beállítás tartozik |
| 6119 | src/#zak#main_view.prog.abap | *Nincs beállítás a /ZAK/BNYLAP táblában! (Vállalat: &, típus: &, dátum:<br>*&). |
| 6120 | src/#zak#main_view.prog.abap | *        Megatározzuk a legnagyobb sor-indexet |
| 6121 | src/#zak#main_view.prog.abap | *Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához! |
| 6122 | src/#zak#main_view.prog.abap | *        Adatok feltöltése |
| 6123 | src/#zak#main_view.prog.abap | *        Ha van adat, feldolgozás |
| 6124 | src/#zak#main_view.prog.abap | *          Pénztárhely vagy számlakelt változás figyelése |
| 6125 | src/#zak#main_view.prog.abap | *--PTGSZLAH #02. 2015.01.30<br>*        Pénztárátvételi hely meghatározása |
| 6126 | src/#zak#main_view.prog.abap | *            & pénztárvételi hely nem létezik! |
| 6127 | src/#zak#main_view.prog.abap | *--PTGSZLAH #01. 2015.01.16<br>*          Pénztárátvételi hely neve M0BB001A |
| 6128 | src/#zak#main_view.prog.abap | *          Számlakibocsátás kelte |
| 6129 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely irányítószáma |
| 6130 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely város |
| 6131 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely közterület neve |
| 6132 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely közterület jellege |
| 6133 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely  házszám |
| 6134 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely épület |
| 6135 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely lépcsőház |
| 6136 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely emelet |
| 6137 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely ajtó |
| 6138 | src/#zak#main_view.prog.abap | *          Számlaszám |
| 6139 | src/#zak#main_view.prog.abap | *          Számla típusa |
| 6140 | src/#zak#main_view.prog.abap | *          Előzmény számla száma |
| 6141 | src/#zak#main_view.prog.abap | *          Vevő adóazonosító száma |
| 6142 | src/#zak#main_view.prog.abap | *          Vevő neve |
| 6143 | src/#zak#main_view.prog.abap | *          Vevő címe |
| 6144 | src/#zak#main_view.prog.abap | *          ÁFA összege |
| 6145 | src/#zak#main_view.prog.abap | *          Pénznem |
| 6146 | src/#zak#main_view.prog.abap | *          Bruttó összeg |
| 6147 | src/#zak#main_view.prog.abap | *          Számlakibocsátás kelte |
| 6148 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely neve |
| 6149 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely irányítószáma |
| 6150 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely város |
| 6151 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely közterület neve |
| 6152 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely közterület jellege |
| 6153 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely  házszám |
| 6154 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely épület |
| 6155 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely lépcsőház |
| 6156 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely emelet |
| 6157 | src/#zak#main_view.prog.abap | *          Pénztárátvételi hely ajtó |
| 6158 | src/#zak#main_view.prog.abap | *          Számlaszám |
| 6159 | src/#zak#main_view.prog.abap | *          Számla típusa |
| 6160 | src/#zak#main_view.prog.abap | *          Előzmény számla száma |
| 6161 | src/#zak#main_view.prog.abap | *          Vevő címe |
| 6162 | src/#zak#main_view.prog.abap | *          Pénznem |
| 6163 | src/#zak#main_view.prog.abap | *          Bruttó összeg |
| 6164 | src/#zak#main_view.prog.abap | * Összeg konverziók |
| 6165 | src/#zak#main_view.prog.abap | *--1465 #04.<br>*++0003 BG 2007.01.31<br>*        Az esedékességi dátumot a szelekcióról kell venni önrevíziónál |
| 6166 | src/#zak#main_view.prog.abap | * Lezárt időszak megjelenítése |
| 6167 | src/#zak#main_view.prog.abap | * Mezőkatalógus összeállítása |
| 6168 | src/#zak#main_view.prog.abap | * Funkciók kizárása |
| 6169 | src/#zak#main_view.prog.abap | * Megnevezések kiolvasása<br>* Vállalat |
| 6170 | src/#zak#main_view.prog.abap | * Bevallás típus |
| 6171 | src/#zak#main_view.prog.abap | * ABEV azonosító |
| 6172 | src/#zak#main_view.prog.abap | * Adatszolgáltatás |
| 6173 | src/#zak#main_view.prog.abap | *++0017 BG 2012.02.07<br>*Ellenpár rögzítéshez adatok feltöltése |
| 6174 | src/#zak#main_view.prog.abap | * Utolsó Tételszám |
| 6175 | src/#zak#main_view.prog.abap | *++0008 BG 2007.08.06<br>* Megerősítés: biztosan elmenti? |
| 6176 | src/#zak#main_view.prog.abap | *++0017 BG 2012.02.07<br>*   Ellenpár rögzítése |
| 6177 | src/#zak#main_view.prog.abap | * Megerősítés: Kilépés mentés nélkül? |
| 6178 | src/#zak#main_view.prog.abap | * Utolsó Tételszám |
| 6179 | src/#zak#main_view.prog.abap | * Új tétel |
| 6180 | src/#zak#main_view.prog.abap | * Numerikus specialitások<br>* Stornó tétel létrehozása köv. periódusra ellentétes előjellel |
| 6181 | src/#zak#main_view.prog.abap | * Következő periódus |
| 6182 | src/#zak#main_view.prog.abap | * Karakteres specialitások<br>* Dátum<br>* XDEFT speciális kezelése - ha itt a manuális tételben beállította,<br>* akkor az összes többiből törölni kell ezt a mezőt. |
| 6183 | src/#zak#main_view.prog.abap | * Ha az I_RETURN-ben nincs hibaüzenet I_OUTTAB aktualizálása |
| 6184 | src/#zak#main_view.prog.abap | * ++ CST 2006.07.19<br>* Kerekítések |
| 6185 | src/#zak#main_view.prog.abap | * Ismételt összegzés - összegmezőkhöz |
| 6186 | src/#zak#main_view.prog.abap | * Amennyiben  bevallás már letöltött volt > státusz visszaállítása |
| 6187 | src/#zak#main_view.prog.abap | * Megnevezések kiolvasása<br>* Vállalat |
| 6188 | src/#zak#main_view.prog.abap | * Bevallás típus |
| 6189 | src/#zak#main_view.prog.abap | * ABEV azonosító |
| 6190 | src/#zak#main_view.prog.abap | * Adatszolgáltatás |
| 6191 | src/#zak#main_view.prog.abap | * Megerősítés: biztosan elmenti?<br>*++0008 BG 2007.08.06 |
| 6192 | src/#zak#main_view.prog.abap | * Megerősítés: Kilépés mentés nélkül? |
| 6193 | src/#zak#main_view.prog.abap | * Adatszolgáltatás ellenőrzése |
| 6194 | src/#zak#main_view.prog.abap | * Szükséges adatszolgáltatások |
| 6195 | src/#zak#main_view.prog.abap | * Ellenőrzések<br>* 1. Összes adatszolgáltatás F/E státuszú-e |
| 6196 | src/#zak#main_view.prog.abap | * Ellenőrzések<br>* 1. Összes adatszolgáltatás F/E státuszú-e |
| 6197 | src/#zak#main_view.prog.abap | *--0004 BG 2007.04.04<br>* Nyomtatvány sorok<br>* 1. sor |
| 6198 | src/#zak#main_view.prog.abap | *---- Egyéb |
| 6199 | src/#zak#main_view.prog.abap | *--0005 BG 2007.06.12<br>*  BEVALLB a display szerint kell ha más |
| 6200 | src/#zak#main_view.prog.abap | *--BG 2007.02.16<br>* Összesítő sorokat nem szabad letölteni |
| 6201 | src/#zak#main_view.prog.abap | * Ellenőrzés - esedékességi dátum - önrevíziónál |
| 6202 | src/#zak#main_view.prog.abap | *++BG 2007.02.16<br>*Szelekciós képernyőről töltjük. |
| 6203 | src/#zak#main_view.prog.abap | * Nyomtatvány sorok |
| 6204 | src/#zak#main_view.prog.abap | *++1365 2013.01.10 Balázs Gábor (Ness) |
| 6205 | src/#zak#main_view.prog.abap | *--1365 2013.01.10 Balázs Gábor (Ness)<br>*++14A60 #01. 2014.02.04 Balázs Gábor (Ness) |
| 6206 | src/#zak#main_view.prog.abap | *--14A60 #01. 2014.02.04 Balázs Gábor (Ness)<br>*++PTGSZLAA #01. 2014.03.03 |
| 6207 | src/#zak#main_view.prog.abap | *++1665 #01.<br>*     L_FULLPATH = L_FILENAME.<br>*++1665 #01.<br>* Mentés nyomógomb. |
| 6208 | src/#zak#main_view.prog.abap | *++1365 2013.01.10 Balázs Gábor (Ness)<br>* ÁFA XML |
| 6209 | src/#zak#main_view.prog.abap | *      XML készítés |
| 6210 | src/#zak#main_view.prog.abap | *        Hiba az XML konvertálásnál! (&) |
| 6211 | src/#zak#main_view.prog.abap | *--1365 2013.01.10 Balázs Gábor (Ness)<br>*++14A60 #01. 2014.02.04 Balázs Gábor (Ness)<br>*   ONYB XML |
| 6212 | src/#zak#main_view.prog.abap | *      XML készítés |
| 6213 | src/#zak#main_view.prog.abap | *        Hiba az XML konvertálásnál! (&) |
| 6214 | src/#zak#main_view.prog.abap | *--14A60 #01. 2014.02.04 Balázs Gábor (Ness)<br>*++PTGSZLAA #01. 2014.03.03<br>*  PTG XML |
| 6215 | src/#zak#main_view.prog.abap | *      XML készítés |
| 6216 | src/#zak#main_view.prog.abap | *        Hiba az XML konvertálásnál! (&) |
| 6217 | src/#zak#main_view.prog.abap | * Esetleges el#z# mentés törlése |
| 6218 | src/#zak#main_view.prog.abap | *  Kulcs szerinit duplikáció törlése |
| 6219 | src/#zak#main_view.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 6220 | src/#zak#main_view.prog.abap | *--1365 #21.<br>*--1365 2013.01.22 Balázs Gábor (Ness) |
| 6221 | src/#zak#main_view.prog.abap | * 'XDEFT' oszlop editálható, ha karakteres |
| 6222 | src/#zak#main_view.prog.abap | * Mezők beállítása |
| 6223 | src/#zak#main_view.prog.abap | *    s_index[] = s_index2[].<br>*++1465 #01. 2014.01.16 Háttér futáshoz szükséges mert egyébként<br>*                  nem veszi át az INDEX paramétert |
| 6224 | src/#zak#main_view.prog.abap | *     S_INDEX[] = S_INDEX3[].<br>*++1465 #01. 2014.01.16 Háttér futáshoz szükséges mert egyébként<br>*                  nem veszi át az INDEX paramétert |
| 6225 | src/#zak#main_view.prog.abap | * Ellenőrzés: újabb-e |
| 6226 | src/#zak#main_view.prog.abap | * Popup csak akkor kell, ha több lehetőség is van |
| 6227 | src/#zak#main_view.prog.abap | * Konverzió |
| 6228 | src/#zak#main_view.prog.abap | * Dolgozói adatok hozzáfűzése |
| 6229 | src/#zak#main_view.prog.abap | * Hossza nem lehet 10-nél nagyobb |
| 6230 | src/#zak#main_view.prog.abap | * Bevitt string dátummá alakítása |
| 6231 | src/#zak#main_view.prog.abap | * Mezőkatalógus összeállítása |
| 6232 | src/#zak#main_view.prog.abap | *<br>* Funkciók kizárása |
| 6233 | src/#zak#main_view.prog.abap | *   Ezzel a programmal & típusú bevallás nem készíthető!<br>*++0004 BG 2007.04.04 |
| 6234 | src/#zak#main_view.prog.abap | *   Kérem érvényes értéket adjon meg! |
| 6235 | src/#zak#main_view.prog.abap | *      TITLEBAR       = ' '<br>*      DIAGNOSE_OBJECT             = ' '<br>*++0008 BG 2007.08.06<br>*      TEXT_QUESTION  = 'Menti a rögzített adatokat?'(900) |
| 6236 | src/#zak#main_view.prog.abap | *--MOL_UPG_ChangeImp # E09324753 # Balázs Gábor (Ness) - 2016.07.12 |
| 6237 | src/#zak#main_view.prog.abap | *    Hiba az esedékességi dátum következő munkanapra konvertálásánál!(&) |
| 6238 | src/#zak#main_view.prog.abap | *   Esedékességi dátum következő munkanapra konvertálva! |
| 6239 | src/#zak#main_view.prog.abap | *  ÁFA ellenőrzéshez funkció elem |
| 6240 | src/#zak#main_view.prog.abap | *  Ide gyűjtjük a könyvelendő tételeket |
| 6241 | src/#zak#main_view.prog.abap | *  Könyvelendő tételek fej sora |
| 6242 | src/#zak#main_view.prog.abap | *  OUTTAB olvasása |
| 6243 | src/#zak#main_view.prog.abap | *  Beolvassuk az összerendelő táblát: |
| 6244 | src/#zak#main_view.prog.abap | *  Összerendelő tábla alapján ellenőrzés |
| 6245 | src/#zak#main_view.prog.abap | *    Adóalap meghatározása |
| 6246 | src/#zak#main_view.prog.abap | *    Adatok mentése, hát ha |
| 6247 | src/#zak#main_view.prog.abap | *    Adóérték meghatározása |
| 6248 | src/#zak#main_view.prog.abap | *    Csak akkor ellenőrizzük, ha vannak értékek |
| 6249 | src/#zak#main_view.prog.abap | *    Pénznem |
| 6250 | src/#zak#main_view.prog.abap | *    Ellenőrzés |
| 6251 | src/#zak#main_view.prog.abap | *      Hiba az ÁFA összeg ellenőrzés funkciónál! (/ZAK/AFA_ALAP_VERIFY) |
| 6252 | src/#zak#main_view.prog.abap | *    Üzenetek megjelenítése |
| 6253 | src/#zak#main_view.prog.abap | *    Kérdés a tételek automatikus generálásáról<br>*    Kívánja automatikusan generálni a korrekciókat? |
| 6254 | src/#zak#main_view.prog.abap | *        & csoport vállalatnál nem megengedett a manuális rögzítés! |
| 6255 | src/#zak#main_view.prog.abap | *  ANALITIKA ABEV összesenek |
| 6256 | src/#zak#main_view.prog.abap | *  ANALITIKA ABEV összesenek aktuális |
| 6257 | src/#zak#main_view.prog.abap | *  ANALITIKA ABEV összesenek SUMMA: |
| 6258 | src/#zak#main_view.prog.abap | *  ANALITIKA ABEV összesenek feldolgozott hónap (aktuális): |
| 6259 | src/#zak#main_view.prog.abap | *  BEVALLO ABEV összesenek: |
| 6260 | src/#zak#main_view.prog.abap | *  ÁFA kódok: |
| 6261 | src/#zak#main_view.prog.abap | *  Szükséges összes ABEV ÁFA_CUST-ból |
| 6262 | src/#zak#main_view.prog.abap | *  Szükséges összes ABEV ANALITIKÁHOZ |
| 6263 | src/#zak#main_view.prog.abap | *  Szükséges Bejövő ABEV BEVALLO-hoz |
| 6264 | src/#zak#main_view.prog.abap | *  Szükséges Bejövő ABEVek BEVALLO-hoz aminek van szumma azonosítója |
| 6265 | src/#zak#main_view.prog.abap | *  Szükséges VPOP összesen sor beszúrása a 04 vagy 06-os lapra. |
| 6266 | src/#zak#main_view.prog.abap | *  Arányosított ÁFA kódok |
| 6267 | src/#zak#main_view.prog.abap | *--1565 #04.<br>*  Szükséges BTYPE-ok |
| 6268 | src/#zak#main_view.prog.abap | *  Év, hónap, index: |
| 6269 | src/#zak#main_view.prog.abap | *  Főkönyvi feladás számításához: |
| 6270 | src/#zak#main_view.prog.abap | *  Különbség |
| 6271 | src/#zak#main_view.prog.abap | *++1065 2010.02.15 BG<br>*  Törlendő ABEV kódok, mivel forgatva lettek: |
| 6272 | src/#zak#main_view.prog.abap | *--1065 2010.02.15 BG<br>*++1665 #09.<br>*    Beolvassuk az ÁFA kód jellemzőit |
| 6273 | src/#zak#main_view.prog.abap | *      Olvassuk KTOSL nélkül |
| 6274 | src/#zak#main_view.prog.abap | *--1665 #09.<br>*    Ha benne van az Arányosított abev-ekben akkor nem kell forgatni |
| 6275 | src/#zak#main_view.prog.abap | *          Arányosított |
| 6276 | src/#zak#main_view.prog.abap | *          Nem arányosított |
| 6277 | src/#zak#main_view.prog.abap | *++1065 2010.02.15 BG<br>*          Olvassuk KTOSL nélkül is |
| 6278 | src/#zak#main_view.prog.abap | *          Arányosított |
| 6279 | src/#zak#main_view.prog.abap | *          Nem arányosított |
| 6280 | src/#zak#main_view.prog.abap | *++1065 2010.02.15 BG<br>*          Olvassuk KTOSL nélkül is |
| 6281 | src/#zak#main_view.prog.abap | *    Arányosított ABEV azonosítón van |
| 6282 | src/#zak#main_view.prog.abap | *++1665 #09.<br>*        Ha részben arányosít |
| 6283 | src/#zak#main_view.prog.abap | *          Arányosított |
| 6284 | src/#zak#main_view.prog.abap | *            Nem arányosított |
| 6285 | src/#zak#main_view.prog.abap | *              Olvassuk KTOSL nélkül is |
| 6286 | src/#zak#main_view.prog.abap | *++1065 2010.02.15 BG<br>*    Forgott az ABEV kód |
| 6287 | src/#zak#main_view.prog.abap | *    Ha benne van az Arányosított abev-ekben akkor nem kell forgatni |
| 6288 | src/#zak#main_view.prog.abap | *      Beolvassuk az ÁFA kód jellemzőit |
| 6289 | src/#zak#main_view.prog.abap | * Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók! |
| 6290 | src/#zak#main_view.prog.abap | * Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók! |
| 6291 | src/#zak#main_view.prog.abap | *    Arány megahatározása |
| 6292 | src/#zak#main_view.prog.abap | *++0014 2008.09.08 BG<br>*    El kell tárolni mert a főkönyvi feladáshoz kell: |
| 6293 | src/#zak#main_view.prog.abap | *--0014 2008.09.08 BG<br>*    Nem arányosított rész hozzáadása<br>*++1665 #08.<br>*     LM_READ_ANALITIKA_ABEVS W_/ZAK/AFA_ARABEV-ABEVAZ ''. |
| 6294 | src/#zak#main_view.prog.abap | *  Főkönyvi feladás számítása |
| 6295 | src/#zak#main_view.prog.abap | *      Meghatározzuk az aktuális hónap feladását összesen |
| 6296 | src/#zak#main_view.prog.abap | *      Különbség meghatározása |
| 6297 | src/#zak#main_view.prog.abap | *      Könnyvelési érték kiszámolása |
| 6298 | src/#zak#main_view.prog.abap | *++0014 2008.09.08 BG<br>*  Főkönyvi feladás számítása |
| 6299 | src/#zak#main_view.prog.abap | *      Összegezni kell az előző hónapok feladásaival: |
| 6300 | src/#zak#main_view.prog.abap | *    Értékek visszaírása |
| 6301 | src/#zak#main_view.prog.abap | *--0014 2008.09.08 BG<br>*ÁFA irány meghatározás |
| 6302 | src/#zak#main_view.prog.abap | *  Meghatározzuk hogy a bevallás arányosított ÁFÁS-e |
| 6303 | src/#zak#main_view.prog.abap | *Nem határozható meg & bevallás típushoz arányosított ABEV azonosítók! |
| 6304 | src/#zak#main_view.prog.abap | *  Most megvannak a bejövő ABEVazonosítók, most ki kell szűrni,hogy<br>*  csak azok kellenek aminek a BEVLLB-ben van szumma azonosítója mert<br>*  egyébként többszörösét szelektálnánk: |
| 6305 | src/#zak#main_view.prog.abap | *  Beolvassuk az arány adatokat |
| 6306 | src/#zak#main_view.prog.abap | *  Nem határozható meg arány szám a & év & hónaphoz! |
| 6307 | src/#zak#main_view.prog.abap | *  Meghatározzuk az adott év BTYPE-okat |
| 6308 | src/#zak#main_view.prog.abap | *  Év első napja: |
| 6309 | src/#zak#main_view.prog.abap | *  Összeállítjuk a szükséges BTYPE-okat |
| 6310 | src/#zak#main_view.prog.abap | *  Meghatározzuk az ABEV azonosítókat:<br>*  Ha részben arányosított |
| 6311 | src/#zak#main_view.prog.abap | *  ABEV kódok gyűjtése: |
| 6312 | src/#zak#main_view.prog.abap | *    Teljesen arányosított |
| 6313 | src/#zak#main_view.prog.abap | *++BG 2008.04.21<br>*  ABEVS összesen meghatározása ANALITIKA jelenlegi hónap - 1.<br>*  L_PREV_MONAT = S_MONAT-LOW - 1. |
| 6314 | src/#zak#main_view.prog.abap | *  Negyedéves |
| 6315 | src/#zak#main_view.prog.abap | *  Éves (itt nem töltjük mert nincs előző időszak) |
| 6316 | src/#zak#main_view.prog.abap | *    Áfa irány megahtározás |
| 6317 | src/#zak#main_view.prog.abap | *    Csak bejovő kell |
| 6318 | src/#zak#main_view.prog.abap | *  Most megvannak a bejövő ABEVazonosítók, most ki kell szűrni,hogy<br>*  csak azok kellenek aminek a BEVLLB-ben van szumma azonosítója mert<br>*  egyébként többszörösét szelektálnánk:<br>*++0014 2008.09.08 BG<br>*  Csak azokat az ABEV kódokat gyűjtjük össze, amik arányosíttak.<br>*  LM_GET_ABEVAZ_SUM_ABEV LR_ABEVAZ_B LR_ABEVAZ_BS. |
| 6319 | src/#zak#main_view.prog.abap | *    Összeállítjuk havonként az utolsó időszakot |
| 6320 | src/#zak#main_view.prog.abap | *  Adatok feldolgozása |
| 6321 | src/#zak#main_view.prog.abap | *    Beállítások |
| 6322 | src/#zak#main_view.prog.abap | *    Arány meghatározás<br>*++1665 #09.<br>*     LM_GET_ARANY. |
| 6323 | src/#zak#main_view.prog.abap | *++0014 2008.09.08 BG<br>*      Főkönyvi feladás számítása<br>*       LM_GET_FOKONYV W_/ZAK/AFA_ARABEV-ABEVAZ<br>*                      L_FIELD_NRK. |
| 6324 | src/#zak#main_view.prog.abap | *  Arány könyveléséhez adatok módosítása |
| 6325 | src/#zak#main_view.prog.abap | *  Régi adatok törlése |
| 6326 | src/#zak#main_view.prog.abap | *  04/06 arányosított ÁFA összesen sor |
| 6327 | src/#zak#main_view.prog.abap | *Nincs beállítás a /ZAK/BNYLAP táblában! (Vállalat: &, típus: &, dátum:<br>*&). |
| 6328 | src/#zak#main_view.prog.abap | *    Nincs beállítás a /ZAK/BNYLAP táblában VPOP arányosított abevhez! |
| 6329 | src/#zak#main_view.prog.abap | *    Meghatározzuk, hogy melyik ABEV-ből kell az összeget másolni! |
| 6330 | src/#zak#main_view.prog.abap | *   Hiányzik a & abev azonosító a /ZAK/BEVALLB táblában! |
| 6331 | src/#zak#main_view.prog.abap | *Nincs beállítva & abev azonosítóhoz "átvétel abev" azonosítóból érték! |
| 6332 | src/#zak#main_view.prog.abap | *    Beolvassuk a VPOP összesent |
| 6333 | src/#zak#main_view.prog.abap | *   Nem leheta meghatározni az & abev azonosító értékét! |
| 6334 | src/#zak#main_view.prog.abap | *    Ellenőrizzük létezik e már a bejegyzés |
| 6335 | src/#zak#main_view.prog.abap | *--1065 2010.02.15 BG<br>*++0011 BG 2008.03.28<br>* Ha van beállítás akkor a részletező sorok arány meghatározása |
| 6336 | src/#zak#main_view.prog.abap | *  ABEVS összesen meghatározása ANALITIKA jelenlegi hónap - 1. |
| 6337 | src/#zak#main_view.prog.abap | *    Áfa irány megahtározás |
| 6338 | src/#zak#main_view.prog.abap | *    Csak bejovő kell |
| 6339 | src/#zak#main_view.prog.abap | *  Adatok feldolgozása |
| 6340 | src/#zak#main_view.prog.abap | *--1665 #08.<br>*    Beállítások |
| 6341 | src/#zak#main_view.prog.abap | *    Arány meghatározás<br>*++1665 #08.<br>*     LM_GET_ARANY. |
| 6342 | src/#zak#main_view.prog.abap | *Range feltöltése: |
| 6343 | src/#zak#main_view.prog.abap | * Ellenőrizzük, hogy minden vállalat státusza legalább letöltött e |
| 6344 | src/#zak#main_view.prog.abap | *      & vállalat APEH fájl készítés még nem futott a megadott időszakra!<br>*    Ha ONYB és van bejegyzés akkor az csak  T státusz lehet<br>*++1765 #07.<br>*    és nem migráció<br>*     ELSEIF  P_BTART = C_BTYPART_ONYB AND SY-SUBRC EQ 0 AND L_FLAG NE 'T'. |
| 6345 | src/#zak#main_view.prog.abap | *      & vállalat APEH fájl készítés még nem futott a megadott időszakra! |
| 6346 | src/#zak#main_view.prog.abap | *   Kérem ellenpár könyvelésnél adjon meg minden értéket! |
| 6347 | src/#zak#main_view.prog.abap | *  Dátum eltérő legyen |
| 6348 | src/#zak#main_view.prog.abap | *   Kérem ellenpár rögzítésénél eltérő időszakot adjon meg! |
| 6349 | src/#zak#main_view.prog.abap | *  Sztornó előjegyzés ellenpár rögzítés vizsgálat |
| 6350 | src/#zak#main_view.prog.abap | *   Kérem ne használja a sztornó előjegyzés és ellenpár könyvelést egysz |
| 6351 | src/#zak#main_view.prog.abap | *  IDŐSZAK BTYPE ellenőrzés |
| 6352 | src/#zak#main_view.prog.abap | *   & bevallás típus & napon nem érvényes |
| 6353 | src/#zak#main_view.prog.abap | *  ABEVAZ mező típus ellenőrzése |
| 6354 | src/#zak#main_view.prog.abap | *   Kérem numerikus típusú ABEV azonosítót válasszon! |
| 6355 | src/#zak#main_view.prog.abap | * Utolsó Tételszám |
| 6356 | src/#zak#main_view.prog.abap | * Új tétel |
| 6357 | src/#zak#main_view.prog.abap | *  Először teszt-ben futtatjuk, hogy meghatározzuk a ZINDEX-et |
| 6358 | src/#zak#main_view.prog.abap | *--1765 #25.<br>*  Státusz ellenőrzése |
| 6359 | src/#zak#main_view.prog.abap | *    Ellenpár rögzítés időszaka már letöltésre került! |
| 6360 | src/#zak#main_view.prog.abap | *++1365 #3.<br>*  Adóazonosítók gyűjtése |
| 6361 | src/#zak#main_view.prog.abap | *--1365 #3.<br>*++1365 #12.<br>*  Számla  E, KT, K rendezéshez adatok |
| 6362 | src/#zak#main_view.prog.abap | *--1365 #12.<br>*--1365 #11.<br>*  1. E-s tételek |
| 6363 | src/#zak#main_view.prog.abap | *  2. KT-s tételek |
| 6364 | src/#zak#main_view.prog.abap | *--2165 #02.<br>*  3. K-s tételek |
| 6365 | src/#zak#main_view.prog.abap | *--1365 #9.<br>*++1365 #3.<br>*  Feldolgozás adószámonként |
| 6366 | src/#zak#main_view.prog.abap | *  Megatározzuk a legnagyobb sor-indexet |
| 6367 | src/#zak#main_view.prog.abap | *Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához! |
| 6368 | src/#zak#main_view.prog.abap | *--1365 #3.<br>*  Adatok feltöltése |
| 6369 | src/#zak#main_view.prog.abap | *        Számla sorszáma |
| 6370 | src/#zak#main_view.prog.abap | *        Teljesítés dátuma |
| 6371 | src/#zak#main_view.prog.abap | *        Adóalap |
| 6372 | src/#zak#main_view.prog.abap | *        Adó |
| 6373 | src/#zak#main_view.prog.abap | *        Számla sorszáma |
| 6374 | src/#zak#main_view.prog.abap | *        Számla típus |
| 6375 | src/#zak#main_view.prog.abap | *        Előzmény számla sorszáma |
| 6376 | src/#zak#main_view.prog.abap | *        Számlakibocsátás dátuma |
| 6377 | src/#zak#main_view.prog.abap | *        Teljesítés dátuma |
| 6378 | src/#zak#main_view.prog.abap | *        Adóalap |
| 6379 | src/#zak#main_view.prog.abap | *        Adó |
| 6380 | src/#zak#main_view.prog.abap | *        Számla sorszáma |
| 6381 | src/#zak#main_view.prog.abap | *        Teljesítés dátuma |
| 6382 | src/#zak#main_view.prog.abap | *        Adóalap |
| 6383 | src/#zak#main_view.prog.abap | *        Adó |
| 6384 | src/#zak#main_view.prog.abap | *++2165 #02.<br>*       Előlegből adódó különbözet jelölése |
| 6385 | src/#zak#main_view.prog.abap | *        Számla sorszáma |
| 6386 | src/#zak#main_view.prog.abap | *        Számla típus |
| 6387 | src/#zak#main_view.prog.abap | *        Előzmény számla sorszáma |
| 6388 | src/#zak#main_view.prog.abap | *        Számlakibocsátás dátuma |
| 6389 | src/#zak#main_view.prog.abap | *        Teljesítés dátuma |
| 6390 | src/#zak#main_view.prog.abap | *        Adóalap |
| 6391 | src/#zak#main_view.prog.abap | *        Adó |
| 6392 | src/#zak#main_view.prog.abap | *  Feldolgozott azonosítók gyűjtése |
| 6393 | src/#zak#main_view.prog.abap | *++1865 #13.<br>*  Ellenőritni kell az M01 lapérvényességét: |
| 6394 | src/#zak#main_view.prog.abap | *    Meg kell keresni az érvényesség végén érvényes kulcsot |
| 6395 | src/#zak#main_view.prog.abap | *   Adószámok gy#jtése |
| 6396 | src/#zak#main_view.prog.abap | *   Elmentjük az új ANALITIKA sorok létrehozásához |
| 6397 | src/#zak#main_view.prog.abap | *++1365 #16.<br>*    Csoportos vállalat kezelés |
| 6398 | src/#zak#main_view.prog.abap | *       Hiba a &/&/& számla adatainak meghatározásánál! |
| 6399 | src/#zak#main_view.prog.abap | *       Hiba a &/&/& számla adatainak meghatározásánál! |
| 6400 | src/#zak#main_view.prog.abap | *    NONEED-et külön kell ellen#rizni! Lehet olyan eset, hogy<br>*    többször szerepel amib#l van olyan amiben a NONEED üres!<br>**   Ha nem releváns akkor nem dolgozzuk fel |
| 6401 | src/#zak#main_view.prog.abap | *    Ellen#rizzük, hogy feldolgoztuk e már a számlát |
| 6402 | src/#zak#main_view.prog.abap | *--1365 #21.<br>*      Nincs K-s tétel |
| 6403 | src/#zak#main_view.prog.abap | *--1365 #18.<br>*    Adatok feldolgozása |
| 6404 | src/#zak#main_view.prog.abap | *--1365 #14.<br>*    Bejegyzés a feldolgozásról |
| 6405 | src/#zak#main_view.prog.abap | *--1365 #21.<br>*  Releváns számlák meghatározása |
| 6406 | src/#zak#main_view.prog.abap | *--1865 #13.<br>*    Ellen#rizzük, hogy feldolgoztuk e már a számlát |
| 6407 | src/#zak#main_view.prog.abap | *++1365 #21.<br>*++1865 #13.<br>*  Releváns számlák meghatározása |
| 6408 | src/#zak#main_view.prog.abap | *    Ellen#rizzük, hogy feldolgoztuk e már a számlát |
| 6409 | src/#zak#main_view.prog.abap | *--1865 #13.<br>*   SORT li_proc_szla.<br>*--1365 #21.<br>*++1365 #9.<br>*  Kitöröljük azokat a sorokat, ahol a faktorral kerekített érték 0,<br>*  mert ezek a sorok üresen jelennek meg a bevallásban és az hibát<br>*  okoz! |
| 6410 | src/#zak#main_view.prog.abap | * Ha törlünk rekordot, akkor ellen#rizni kell, hogy ez E-s rekord nem e<br>* maradt önmagában. Ha igen akkor azt is törölni kell mert egyébként<br>* rákerül a M01 vagy M02 lapra és ez nem megfelel#!<br>* Ha van még K-s rekord akkor nem kell az E-t törölni! |
| 6411 | src/#zak#main_view.prog.abap | * Ha nincs már K-s rekord, akkor E-s törlése ha nem a feldolgozott<br>* id#s/zak/zakban van |
| 6412 | src/#zak#main_view.prog.abap | *++1665 #12.<br>*    Elképzelhető, hogy marad az összesítésben még olyan rekord amit 901<br>*    betöltéssel 0-áztak ki és E típusú, ezeket is törölni kell, hogy ne<br>*    jelenjen meg az ALV-n sem<br>*++2065 #10. |
| 6413 | src/#zak#main_view.prog.abap | *    Eredeti számla sor beolvasása |
| 6414 | src/#zak#main_view.prog.abap | *++1365 #21.<br>*                         BINARY SEARCH.<br>*--1365 #21.<br>*    Meghatározzuk van e olyan sor ami nem E ha igen, akkor<br>*    minden érték -K lapra kerül, egyébként a M01 vagy M02-re |
| 6415 | src/#zak#main_view.prog.abap | *++1365 #14.<br>* Csak akkor kell generálni, ha az eredeti számla is a<br>* feldolgozott id#s/zak/zakban van! |
| 6416 | src/#zak#main_view.prog.abap | *--1365 #14.<br>*        Eltér# hónap |
| 6417 | src/#zak#main_view.prog.abap | *++1365 #16.<br>*      Csoport vállalatnál vállalat kód csere |
| 6418 | src/#zak#main_view.prog.abap | *      Ha a DUMMY_M N-r van állítva, akkor ellen#rizzük hogy<br>*      a struktúrában szerepl# LWSTE a beállított kerekítési<br>*      faktorral nagyobb e mint 0, ha nem akkor nem kell feldogozni! |
| 6419 | src/#zak#main_view.prog.abap | *++1965 #04.<br>*++2165 #02.<br>*  Előleg stádium korrigálása |
| 6420 | src/#zak#main_view.prog.abap | *--2165 #02.<br>* Partner csoport adószám kezelés<br>*    Meg kell keresni az érvényesség végén érvényes kulcsot |
| 6421 | src/#zak#main_view.prog.abap | *  Saját beállító tábla (/ZAK/PADONSZA) szerinti kezelés |
| 6422 | src/#zak#main_view.prog.abap | *    Lecseréljük az összes adószámot a csoport adószámra (ANALITIKA, AFA_SZLA) |
| 6423 | src/#zak#main_view.prog.abap | *  SAP törzsadat szerinti kezelés |
| 6424 | src/#zak#main_view.prog.abap | *    Lecseréljük az összes adószámot a csoport adószámra (ANALITIKA, AFA_SZLA) |
| 6425 | src/#zak#main_view.prog.abap | *  Vevő meghatározása |
| 6426 | src/#zak#main_view.prog.abap | *  Közterület szétbontása, neve, jellege: |
| 6427 | src/#zak#main_view.prog.abap | *   A megadott időszakra jelenleg NAV ellenőrzés van folyamatban! |
| 6428 | src/#zak#main_view.prog.screen_9000.abap | nincs emberi komment blokk |
| 6429 | src/#zak#main_view.prog.screen_9001.abap | nincs emberi komment blokk |
| 6430 | src/#zak#main_view.prog.screen_9002.abap | nincs emberi komment blokk |
| 6431 | src/#zak#main_view.prog.screen_9100.abap | *++0017 BG 2012.02.07<br>* Ellenpár rögzítéshez ellenőrzés |
| 6432 | src/#zak#main_view.prog.screen_9200.abap | nincs emberi komment blokk |
| 6433 | src/#zak#main_view.prog.screen_9900.abap | nincs emberi komment blokk |
| 6434 | src/#zak#main_view.prog.screen_9901.abap | nincs emberi komment blokk |
| 6435 | src/#zak#main_view_local_class.prog.abap | * Analitika megjelenítése |
| 6436 | src/#zak#main_view_local_class.prog.abap | *--0004 BG 2007.04.04<br>*++0005 BG 2007.05.30<br>*                  ÁFA 04,06-os lap kezelése |
| 6437 | src/#zak#main_view_local_class.prog.abap | * Mező beállítások |
| 6438 | src/#zak#main_view_local_class.prog.abap | * Sor beállítások beolvasása |
| 6439 | src/#zak#main_view_local_class.prog.abap | * CELLTAB beállítása |
| 6440 | src/#zak#main_view_local_class.prog.abap | * Manuális rögzítés |
| 6441 | src/#zak#main_view_local_class.prog.abap | *   & bevallás fajtánál nem megengedett a manuális rögzítés! |
| 6442 | src/#zak#main_view_local_class.prog.abap | *++0016 BG 2011.09.14<br>*    Csoport vállalatnál nem engedett a manuális rögzítés |
| 6443 | src/#zak#main_view_local_class.prog.abap | *   & csoport vállalatnál nem megengedett a manuális rögzítés! |
| 6444 | src/#zak#main_view_local_class.prog.abap | * Manuálisan módosítható sor? |
| 6445 | src/#zak#main_view_local_class.prog.abap | * Adószám kötelező |
| 6446 | src/#zak#main_view_local_class.prog.abap | * Manuálisan módosítható sor? |
| 6447 | src/#zak#main_view_local_class.prog.abap | * Adószám kötelező |
| 6448 | src/#zak#main_view_new.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Adatállomány készítő, megjelenítő, manuális rögzítő program<br>*&---------------------------------------------------------------------* |
| 6449 | src/#zak#main_view_new.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Adatállomány készítő, megjelenítő, manuális rögzítő<br>*& program<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - fmc<br>*& Létrehozás dátuma : 2006.01.05<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES xxxxxxxxxx<br>*&                                   cseréje hagyományosra<br>*&        2006/11/29   Balázs G.     Önrevízió kezelés változtatás<br>*& 0002   2007.01.03   Balázs G.     CL_GUI_FRONTEND_SERVICES vissza<br>*& 0003   2007.03.27   Balázs G.     Alkalmazás minősége kezelés<br>*& 0004   2007.05.25   Balázs G.     A BEVALLB-ACTREAD-ben megjelölt<br>*&                                   ABEV azonosítóknál csak az aktuális<br>*&                                   időszakra érkezett feladásokat kell<br>*&                                   figyelembe venni, nem a halmozotatt<br>*& 0005   2007.07.10   Balázs G.     Alkalmazás mínősége kezelésénél az<br>*&                                   adatokat csak az aktuális időszakban<br>*&                                   keressük.<br>*& 0006   2007.07.23   Balázs G.     Esedékességi dátum meghatározása<br>*&                                   termelési naptár alapján<br>*& 0007   2008.02.14   Balázs G.     Figyelmeztetés ha van az időszakban<br>*&                                   más bevallás típus is<br>*&---------------------------------------------------------------------* |
| 6450 | src/#zak#main_view_new.prog.abap | * Dolgozói adatok |
| 6451 | src/#zak#main_view_new.prog.abap | * Adóazonosítók |
| 6452 | src/#zak#main_view_new.prog.abap | * Konvertált |
| 6453 | src/#zak#main_view_new.prog.abap | * ALV kezelési változók |
| 6454 | src/#zak#main_view_new.prog.abap | *MAKRO definiálás range feltöltéshez |
| 6455 | src/#zak#main_view_new.prog.abap | * Analitika megjelenítése |
| 6456 | src/#zak#main_view_new.prog.abap | * Mező beállítások |
| 6457 | src/#zak#main_view_new.prog.abap | * Sor beállítások beolvasása |
| 6458 | src/#zak#main_view_new.prog.abap | * CELLTAB beállítása |
| 6459 | src/#zak#main_view_new.prog.abap | * Manuális rögzítés |
| 6460 | src/#zak#main_view_new.prog.abap | * Manuálisan módosítható sor? |
| 6461 | src/#zak#main_view_new.prog.abap | * Adószám kötelező |
| 6462 | src/#zak#main_view_new.prog.abap | * Manuálisan módosítható sor? |
| 6463 | src/#zak#main_view_new.prog.abap | * Adószám kötelező |
| 6464 | src/#zak#main_view_new.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6465 | src/#zak#main_view_new.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6466 | src/#zak#main_view_new.prog.abap | *  Jogosultság vizsgálat |
| 6467 | src/#zak#main_view_new.prog.abap | * Normál, önrevízió, megjelenítés: S_ szelekciók feltöltése |
| 6468 | src/#zak#main_view_new.prog.abap | * Bevallás típus meghatározása |
| 6469 | src/#zak#main_view_new.prog.abap | * Zárolás beállítás |
| 6470 | src/#zak#main_view_new.prog.abap | * Bevallás utolsó napjának meghatározása |
| 6471 | src/#zak#main_view_new.prog.abap | * Bevallás általános adatai |
| 6472 | src/#zak#main_view_new.prog.abap | *  Bevallás adatszerkezetének kiolvasása |
| 6473 | src/#zak#main_view_new.prog.abap | *++BG 2006.10.11 BG<br>*SZJA-nal nem kell (Kiss Márta, Lehel Attila) |
| 6474 | src/#zak#main_view_new.prog.abap | *  Összeg sorok számítása |
| 6475 | src/#zak#main_view_new.prog.abap | *  Ha nem batch futás lista |
| 6476 | src/#zak#main_view_new.prog.abap | *  BEVALLO aktualizálás batch futás |
| 6477 | src/#zak#main_view_new.prog.abap | * Vállalat megnevezése |
| 6478 | src/#zak#main_view_new.prog.abap | * Bevallásfajta megnevezése |
| 6479 | src/#zak#main_view_new.prog.abap | * ÁFA jellegű bevallások önrevíziója kummulált |
| 6480 | src/#zak#main_view_new.prog.abap | * Normál |
| 6481 | src/#zak#main_view_new.prog.abap | * Önrevízió |
| 6482 | src/#zak#main_view_new.prog.abap | * Megjelenítés |
| 6483 | src/#zak#main_view_new.prog.abap | * Mezőkatalógus összeállítása |
| 6484 | src/#zak#main_view_new.prog.abap | * Karakteres sor? Más a mezőkatalógus!<br>* Editálható mező: XDEFT - radio-button |
| 6485 | src/#zak#main_view_new.prog.abap | * Dolgozó bekérése |
| 6486 | src/#zak#main_view_new.prog.abap | * Bevallás készítő |
| 6487 | src/#zak#main_view_new.prog.abap | * Státuszellenőrzés<br>* Normál bevallás<br>* Ha nincs meg az összes adatszolgáltatás nem lehet indítani |
| 6488 | src/#zak#main_view_new.prog.abap | * Adatszerkezet szerinti konverzió<br>* Dolgozói rekordok hozzáfűzése |
| 6489 | src/#zak#main_view_new.prog.abap | * /ZAK/BEVALLO írása |
| 6490 | src/#zak#main_view_new.prog.abap | * Státusz aktualizálása /ZAK/BEVALLSZ |
| 6491 | src/#zak#main_view_new.prog.abap | * Kilépés |
| 6492 | src/#zak#main_view_new.prog.abap | * Normál, önrevízió, megjelenítés: S_ szelekciók feltöltése |
| 6493 | src/#zak#main_view_new.prog.abap | * Bevallás típus meghatározása |
| 6494 | src/#zak#main_view_new.prog.abap | * Bevallás utolsó napjának meghatározás |
| 6495 | src/#zak#main_view_new.prog.abap | * ...negyedéves |
| 6496 | src/#zak#main_view_new.prog.abap | * ...éves |
| 6497 | src/#zak#main_view_new.prog.abap | * Van-e a megadott periódusra adat? |
| 6498 | src/#zak#main_view_new.prog.abap | * Önrevíziónál: előfeltétel, hogy a 000 le legyen zárva |
| 6499 | src/#zak#main_view_new.prog.abap | * csak az éppen nyitott sorszám írható, vagy - ha  nincs nyitott - csak<br>* az utolsó lezártnál eggyel nagyobb sorszám |
| 6500 | src/#zak#main_view_new.prog.abap | *++BG 2006/07/19<br>*  Esedékességi dátum kitöltés ellenőrzése |
| 6501 | src/#zak#main_view_new.prog.abap | *     Kérem adja meg az esedékesség dátum értékét a szelekción!<br>*++0006 BG 2007.07.23<br>*    Esedékességi dátum konvertálás |
| 6502 | src/#zak#main_view_new.prog.abap | *  Adóazonosító+lapszám |
| 6503 | src/#zak#main_view_new.prog.abap | * N - Negyedéves |
| 6504 | src/#zak#main_view_new.prog.abap | *++0007 BG 2008.02.14<br>*    Meghatározzuk a Bevallás fajtahoz tartozó bevallás típusokat |
| 6505 | src/#zak#main_view_new.prog.abap | *       Az analitikia tartalmaz & bevallás típustól eltérő tételt! |
| 6506 | src/#zak#main_view_new.prog.abap | *++0004 BG 2007.05.25<br>*    Aktuális időszak olvasású ABEV azonosítók gyűjtése, feldolgozása |
| 6507 | src/#zak#main_view_new.prog.abap | *    Alkalmazás minősége |
| 6508 | src/#zak#main_view_new.prog.abap | *    Adóazónósító nélküli ABEV-ek |
| 6509 | src/#zak#main_view_new.prog.abap | *    Adóazónósítós  ABEV-ek |
| 6510 | src/#zak#main_view_new.prog.abap | *        Optimalizált feltöltés miatt csak azokat töltjük<br>*        fel amihez valami számítás vagy átvezetés van |
| 6511 | src/#zak#main_view_new.prog.abap | *    Összesítettek feltöltése |
| 6512 | src/#zak#main_view_new.prog.abap | *    Átvezetések feltöltése |
| 6513 | src/#zak#main_view_new.prog.abap | *    Első rekord beolvasása |
| 6514 | src/#zak#main_view_new.prog.abap | *++2308 #09.<br>*      TAO rekordok gyűjtése |
| 6515 | src/#zak#main_view_new.prog.abap | *--2308 #09.<br>*      Adóazonosító+Lapszám |
| 6516 | src/#zak#main_view_new.prog.abap | *        Bővítés |
| 6517 | src/#zak#main_view_new.prog.abap | *           'A'-s lapok létrehozása csak egyszer. |
| 6518 | src/#zak#main_view_new.prog.abap | *          Ha maradt még feldolgozandó, ez akkor fordulhat elő amikor<br>*          előszőr változik 'A'-ról  'M'-re |
| 6519 | src/#zak#main_view_new.prog.abap | *            Bővítés minen rekordra |
| 6520 | src/#zak#main_view_new.prog.abap | *      Önrevíziós tételek adószámainka gyűjtése |
| 6521 | src/#zak#main_view_new.prog.abap | *      Ha megvan kitöröljük |
| 6522 | src/#zak#main_view_new.prog.abap | *      Ha nincs meg beolvassuk az eredetiből |
| 6523 | src/#zak#main_view_new.prog.abap | *      Ha nem adóköteles és van kitöltve adószám azt nem vesszük<br>*      figyelembe |
| 6524 | src/#zak#main_view_new.prog.abap | * Önrevízió - esdékességi dátum |
| 6525 | src/#zak#main_view_new.prog.abap | *        Ha számított a mező és az analitika ad fel valamit<br>*        akkor kitöröljük |
| 6526 | src/#zak#main_view_new.prog.abap | *    Ha az utolsó rekord 'A'-s |
| 6527 | src/#zak#main_view_new.prog.abap | *--BG 2006/08/09<br>*    Bővítés |
| 6528 | src/#zak#main_view_new.prog.abap | *    Bővítés |
| 6529 | src/#zak#main_view_new.prog.abap | * Összeg konverziók |
| 6530 | src/#zak#main_view_new.prog.abap | *++BG 2006/07/19<br>*        Az esedékességi dátumot a szelekcióról kell venni önrevíziónál |
| 6531 | src/#zak#main_view_new.prog.abap | * Lezárt időszak megjelenítése |
| 6532 | src/#zak#main_view_new.prog.abap | *  Adóazonosítók gyűjtése |
| 6533 | src/#zak#main_view_new.prog.abap | *  TAO feldolgozása |
| 6534 | src/#zak#main_view_new.prog.abap | *      Megatározzuk a legnagyobb sor-indexet |
| 6535 | src/#zak#main_view_new.prog.abap | *        Nincs "Sor / oszlop azonosító" beállítás a & bevallás fajtához! |
| 6536 | src/#zak#main_view_new.prog.abap | *      Feldolgozás adószámonként |
| 6537 | src/#zak#main_view_new.prog.abap | *          Adatok feltöltése |
| 6538 | src/#zak#main_view_new.prog.abap | *          B) Jelölje, hogy hányas számú ATP-01-es laphoz kapcsolódóan.... |
| 6539 | src/#zak#main_view_new.prog.abap | *          C/a Ügyletben érintett kapcsolt vállalkozás neve |
| 6540 | src/#zak#main_view_new.prog.abap | *          C/b adószám |
| 6541 | src/#zak#main_view_new.prog.abap | *          C/d Külföldi adószám |
| 6542 | src/#zak#main_view_new.prog.abap | *          C/e Nettó érték |
| 6543 | src/#zak#main_view_new.prog.abap | *          C/f Adóalap |
| 6544 | src/#zak#main_view_new.prog.abap | * Mezőkatalógus összeállítása |
| 6545 | src/#zak#main_view_new.prog.abap | *<br>* Funkciók kizárása |
| 6546 | src/#zak#main_view_new.prog.abap | * Megnevezések kiolvasása |
| 6547 | src/#zak#main_view_new.prog.abap | * Vállalat |
| 6548 | src/#zak#main_view_new.prog.abap | * Bevallás típus |
| 6549 | src/#zak#main_view_new.prog.abap | * ABEV azonosító |
| 6550 | src/#zak#main_view_new.prog.abap | * Adatszolgáltatás |
| 6551 | src/#zak#main_view_new.prog.abap | * Megerősítés: biztosan elmenti? |
| 6552 | src/#zak#main_view_new.prog.abap | * Megerősítés: Kilépés mentés nélkül? |
| 6553 | src/#zak#main_view_new.prog.abap | * Utolsó Tételszám |
| 6554 | src/#zak#main_view_new.prog.abap | * Új tétel |
| 6555 | src/#zak#main_view_new.prog.abap | * Numerikus specialitások<br>* Stornó tétel létrehozása köv. periódusra ellentétes előjellel |
| 6556 | src/#zak#main_view_new.prog.abap | * Következő periódus |
| 6557 | src/#zak#main_view_new.prog.abap | * Karakteres specialitások |
| 6558 | src/#zak#main_view_new.prog.abap | * Dátum |
| 6559 | src/#zak#main_view_new.prog.abap | * XDEFT speciális kezelése - ha itt a manuális tételben beállította,<br>* akkor az összes többiből törölni kell ezt a mezőt. |
| 6560 | src/#zak#main_view_new.prog.abap | * Ha az I_RETURN-ben nincs hibaüzenet I_OUTTAB aktualizálása |
| 6561 | src/#zak#main_view_new.prog.abap | * ++ CST 2006.07.19<br>* Kerekítések |
| 6562 | src/#zak#main_view_new.prog.abap | * Ismételt összegzés - összegmezőkhöz |
| 6563 | src/#zak#main_view_new.prog.abap | * Amennyiben  bevallás már letöltött volt > státusz visszaállítása |
| 6564 | src/#zak#main_view_new.prog.abap | * Megnevezések kiolvasása |
| 6565 | src/#zak#main_view_new.prog.abap | * Vállalat |
| 6566 | src/#zak#main_view_new.prog.abap | * Bevallás típus |
| 6567 | src/#zak#main_view_new.prog.abap | * ABEV azonosító |
| 6568 | src/#zak#main_view_new.prog.abap | * Adatszolgáltatás |
| 6569 | src/#zak#main_view_new.prog.abap | * Megerősítés: biztosan elmenti? |
| 6570 | src/#zak#main_view_new.prog.abap | * Megerősítés: Kilépés mentés nélkül? |
| 6571 | src/#zak#main_view_new.prog.abap | * Adatszolgáltatás ellenőrzése |
| 6572 | src/#zak#main_view_new.prog.abap | * Szükséges adatszolgáltatások |
| 6573 | src/#zak#main_view_new.prog.abap | * Ellenőrzések<br>* 1. Összes adatszolgáltatás F/E státuszú-e |
| 6574 | src/#zak#main_view_new.prog.abap | * Ellenőrzések<br>* 1. Összes adatszolgáltatás F/E státuszú-e |
| 6575 | src/#zak#main_view_new.prog.abap | * Nyomtatvány sorok<br>* 1. sor |
| 6576 | src/#zak#main_view_new.prog.abap | *---- Egyéb |
| 6577 | src/#zak#main_view_new.prog.abap | * Összesítő sorokat nem szabad letölteni |
| 6578 | src/#zak#main_view_new.prog.abap | * Üres értékű azonosítók sem kellenek |
| 6579 | src/#zak#main_view_new.prog.abap | * Nyomtatvány sorok |
| 6580 | src/#zak#main_view_new.prog.abap | * Mentés nyomógomb. |
| 6581 | src/#zak#main_view_new.prog.abap | *--2308 #09.<br>* ÁFA és egyéb |
| 6582 | src/#zak#main_view_new.prog.abap | * Esetleges előző mentés törlése |
| 6583 | src/#zak#main_view_new.prog.abap | *  Kulcs szerinit duplikáció törlése |
| 6584 | src/#zak#main_view_new.prog.abap | * 'XDEFT' oszlop editálható, ha karakteres |
| 6585 | src/#zak#main_view_new.prog.abap | * Mezők beállítása |
| 6586 | src/#zak#main_view_new.prog.abap | * Ellenőrzés: újabb-e |
| 6587 | src/#zak#main_view_new.prog.abap | * Popup csak akkor kell, ha több lehetőség is van |
| 6588 | src/#zak#main_view_new.prog.abap | * Konverzió |
| 6589 | src/#zak#main_view_new.prog.abap | * Dolgozói adatok hozzáfűzése |
| 6590 | src/#zak#main_view_new.prog.abap | * Hossza nem lehet 10-nél nagyobb |
| 6591 | src/#zak#main_view_new.prog.abap | * Bevitt string dátummá alakítása |
| 6592 | src/#zak#main_view_new.prog.abap | *      XML készítés |
| 6593 | src/#zak#main_view_new.prog.abap | * Mezőkatalógus összeállítása |
| 6594 | src/#zak#main_view_new.prog.abap | *<br>* Funkciók kizárása |
| 6595 | src/#zak#main_view_new.prog.abap | *  csak dialógus futtatásnál |
| 6596 | src/#zak#main_view_new.prog.abap | *  'A'-s azonosítókat létre hozzuk |
| 6597 | src/#zak#main_view_new.prog.abap | *  Egyenlőre nem kell a rekord |
| 6598 | src/#zak#main_view_new.prog.abap | *Csak akkor kell a rekord ha számított, átvezetett vagy összegzett |
| 6599 | src/#zak#main_view_new.prog.abap | * Ha számított vagy ki van töltve az összegző vagy átvezető akkor kell |
| 6600 | src/#zak#main_view_new.prog.abap | * Ha még nem dőlt ell ellenőrizni kell hogy a összesített vagy számított<br>* mezőben szerepel e |
| 6601 | src/#zak#main_view_new.prog.abap | *   Ezzel a programmal csak & típusú bevallás készíthető! |
| 6602 | src/#zak#main_view_new.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 6603 | src/#zak#main_view_new.prog.abap | *  Törzsadatok |
| 6604 | src/#zak#main_view_new.prog.abap | *  Feladások adószámonként |
| 6605 | src/#zak#main_view_new.prog.abap | *  Adóazonosítónként utolsó alk.minőség és lapszám |
| 6606 | src/#zak#main_view_new.prog.abap | *  Meghatározzuk az ABEV azonosítókat, ha nincs akkor kilép, |
| 6607 | src/#zak#main_view_new.prog.abap | *  Ellenőrizzük van-e adat a tartományban |
| 6608 | src/#zak#main_view_new.prog.abap | *      Rangek feltöltése ALKALMAZÁS MINŐSÉGÉHEZ: |
| 6609 | src/#zak#main_view_new.prog.abap | *      Adatok gyűjtése |
| 6610 | src/#zak#main_view_new.prog.abap | *  Ellenőrizzük szerepel e az adat |
| 6611 | src/#zak#main_view_new.prog.abap | *  Alkalmazás minősége és lapszám meghatározás |
| 6612 | src/#zak#main_view_new.prog.abap | *  Meghatározzuk az utolsót |
| 6613 | src/#zak#main_view_new.prog.abap | *++BG 2007.06.11<br>*  HR adatszolgáltatást nem kezeljük |
| 6614 | src/#zak#main_view_new.prog.abap | *--BG 2007.06.11<br>*   Alkalmazás minőségének ABEV meghatározása |
| 6615 | src/#zak#main_view_new.prog.abap | *  Visszaírjuk a lapszámot és az alk.minőséget |
| 6616 | src/#zak#main_view_new.prog.abap | *++BG 2007.06.11<br>*  HR-es adatszolgáltatás nem írjuk felül mert ott lehet egy<br>*  adatszolgáltatáson belül több dinamikus lapszám |
| 6617 | src/#zak#main_view_new.prog.abap | *      Meghatározzuk az aktuális alk. minőséget és lapszámot |
| 6618 | src/#zak#main_view_new.prog.abap | *    Hiba az esedékességi dátum következő munkanapra konvertálásánál!(&) |
| 6619 | src/#zak#main_view_new.prog.abap | *   Esedékességi dátum következő munkanapra konvertálva! |
| 6620 | src/#zak#main_view_new.prog.abap | *   A megadott időszakra jelenleg NAV ellenőrzés van folyamatban! |
| 6621 | src/#zak#main_view_new.prog.screen_9000.abap | nincs emberi komment blokk |
| 6622 | src/#zak#main_view_new.prog.screen_9001.abap | nincs emberi komment blokk |
| 6623 | src/#zak#main_view_new.prog.screen_9002.abap | nincs emberi komment blokk |
| 6624 | src/#zak#main_view_new.prog.screen_9100.abap | nincs emberi komment blokk |
| 6625 | src/#zak#main_view_new.prog.screen_9200.abap | nincs emberi komment blokk |
| 6626 | src/#zak#main_view_new.prog.screen_9900.abap | nincs emberi komment blokk |
| 6627 | src/#zak#message.fugr.#zak#lmessagef01.abap | nincs emberi komment blokk |
| 6628 | src/#zak#message.fugr.#zak#lmessagetop.abap | nincs emberi komment blokk |
| 6629 | src/#zak#message.fugr.#zak#message_show.abap | nincs emberi komment blokk |
| 6630 | src/#zak#message.fugr.#zak#saplmessage.abap | nincs emberi komment blokk |
| 6631 | src/#zak#mg_igazolas.ssfo.gcoding.abap | * Címadatok |
| 6632 | src/#zak#mg_igazolas.ssfo.gcoding.abap | * Adószám<br>*++2508 #12. |
| 6633 | src/#zak#mg_igazolas.ssfo.gcoding.abap | *++ 2021.03.02 Baranyai Balázs Szövegek, logok dinamizálása<br>* Megnevezés szövegelem |
| 6634 | src/#zak#mg_igazolas.ssfo.gcoding.abap | * Szöveg szövegelem |
| 6635 | src/#zak#mg_igazolas.ssfo.gcoding.abap | *-- 2021.03.02 Baranyai Balázs Szövegek, logok dinamizálása |
| 6636 | src/#zak#mgcim_upload.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Magánszemély címadatok feltöltése CSV formátumból   *<br>*& /ZAK/MGCIM táblába a /ZAK/ZAKO rendszer adóigazolás funkciójához          *<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2008.02.28<br>*& Funkc.spec.készítő: Róth Nándor  - FMC<br>*& SAP modul neve    : /ZAK/ZAKO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 5.0<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&<br>*&---------------------------------------------------------------------* |
| 6637 | src/#zak#mgcim_upload.prog.abap | *Fájl adatok |
| 6638 | src/#zak#mgcim_upload.prog.abap | *&---------------------------------------------------------------------*<br>* SELECTION-SCREEN<br>*&---------------------------------------------------------------------*<br>*Általános szelekciók: |
| 6639 | src/#zak#mgcim_upload.prog.abap | *Fájl elérés |
| 6640 | src/#zak#mgcim_upload.prog.abap | *Fejsor az állományban |
| 6641 | src/#zak#mgcim_upload.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6642 | src/#zak#mgcim_upload.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6643 | src/#zak#mgcim_upload.prog.abap | *   A program háttérben nem futtatható! |
| 6644 | src/#zak#mgcim_upload.prog.abap | * Fájl nyitás keresési segítség |
| 6645 | src/#zak#mgcim_upload.prog.abap | *   A program háttérben nem futtatható! |
| 6646 | src/#zak#mgcim_upload.prog.abap | * Adatfájl beolvasása |
| 6647 | src/#zak#mgcim_upload.prog.abap | *   Hiba a & fájl megnyitásánál! |
| 6648 | src/#zak#mgcim_upload.prog.abap | * Adatok feltöltése |
| 6649 | src/#zak#mgcim_upload.prog.abap | *Adatbázis módosítás |
| 6650 | src/#zak#mgcim_upload.prog.abap | * Adatok feltöltve! |
| 6651 | src/#zak#mgcim_upload.prog.abap | * CSV bontás |
| 6652 | src/#zak#mgcim_upload.prog.abap | * A & állomány nem tartalmaz feldolgozható rekordot! |
| 6653 | src/#zak#migr_afa.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: ÁFA migrációs program<br>*&---------------------------------------------------------------------* |
| 6654 | src/#zak#migr_afa.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: ÁFA migrációs program<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - fmc<br>*& Létrehozás dátuma : 2006.04.12<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2007/05/09   Balázs G.     Általánosítás, hogy ne csak ÁFA<br>*&                                   migrációhoz lehessen használni.<br>*&---------------------------------------------------------------------* |
| 6655 | src/#zak#migr_afa.prog.abap | * Konvertált |
| 6656 | src/#zak#migr_afa.prog.abap | * Kezelési változók |
| 6657 | src/#zak#migr_afa.prog.abap | * ALV kezelési változók |
| 6658 | src/#zak#migr_afa.prog.abap | *MAKRO definiálás range feltöltéshez |
| 6659 | src/#zak#migr_afa.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6660 | src/#zak#migr_afa.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6661 | src/#zak#migr_afa.prog.abap | *  Jogosultság vizsgálat |
| 6662 | src/#zak#migr_afa.prog.abap | *++0002 BG 2007.05.09<br>** Bevallás típus meghatározása<br>*  P_BTYPE = '0665'.<br>*--0002 BG 2007.05.09 |
| 6663 | src/#zak#migr_afa.prog.abap | * Jelenlegi adatok beolvasása<br>* Bevallás általános adatai |
| 6664 | src/#zak#migr_afa.prog.abap | * Bevallás nyomtatvány adatok |
| 6665 | src/#zak#migr_afa.prog.abap | * Bevallás - elkészített (ha már van) |
| 6666 | src/#zak#migr_afa.prog.abap | * Zárolás beállítás |
| 6667 | src/#zak#migr_afa.prog.abap | *----------------------------------------------------------------------*<br>* Bevallás készítés<br>*----------------------------------------------------------------------* |
| 6668 | src/#zak#migr_afa.prog.abap | *  Bevallás mentése |
| 6669 | src/#zak#migr_afa.prog.abap | * Range feltöltése - időszakokhoz |
| 6670 | src/#zak#migr_afa.prog.abap | *     Státusz aktualizálása /ZAK/BEVALLSZ//ZAK/ZAK_BE |
| 6671 | src/#zak#migr_afa.prog.abap | *----------------------------------------------------------------------*<br>* Bevallás zárás<br>*----------------------------------------------------------------------* |
| 6672 | src/#zak#migr_afa.prog.abap | *--S4HANA#01.<br>* Van könyvelésre jelölt tétel? -> nem zárható |
| 6673 | src/#zak#migr_afa.prog.abap | * Volt már bevallás készítés?<br>*++S4HANA#01.<br>*    DESCRIBE TABLE I_/ZAK/BEVALLO LINES SY-TFILL. |
| 6674 | src/#zak#migr_afa.prog.abap | * Tábla kulcsok |
| 6675 | src/#zak#migr_afa.prog.abap | * Range feltöltése - időszakokhoz |
| 6676 | src/#zak#migr_afa.prog.abap | *   Zárolt időszak -> nem zárható |
| 6677 | src/#zak#migr_afa.prog.abap | *----------------------------------------------------------------------*<br>* Bevallás törlés<br>*----------------------------------------------------------------------* |
| 6678 | src/#zak#migr_afa.prog.abap | * Vállalat megnevezése |
| 6679 | src/#zak#migr_afa.prog.abap | * Bevallásfajta megnevezése |
| 6680 | src/#zak#migr_afa.prog.abap | *   Hiányzó beállítás & bevallás fajtához & évben! |
| 6681 | src/#zak#migr_afa.prog.abap | *--1765 #01.<br>* IDŐSZAK konvertálása |
| 6682 | src/#zak#migr_afa.prog.abap | * Ha még nincs ezzel a kulccsal - lementem |
| 6683 | src/#zak#migr_afa.prog.abap | *  Van már ilyen kulccsal |
| 6684 | src/#zak#migr_afa.prog.abap | * Ez a default szöveg - módosítom a lementettet |
| 6685 | src/#zak#migr_afa.prog.abap | * Tábla kulcsok |
| 6686 | src/#zak#migr_afa.prog.abap | * Összeg konverziók |
| 6687 | src/#zak#migr_afa.prog.abap | * Esetleges előző mentés(ek) törlése |
| 6688 | src/#zak#migr_afa.prog.abap | * /zak/bevalli státusz |
| 6689 | src/#zak#migr_afa.prog.abap | * /zak/bevallsz státusz |
| 6690 | src/#zak#migr_afa.prog.abap | * bevallási időszakok |
| 6691 | src/#zak#migr_afa.prog.abap | * nincs az adatszolgáltatás-időszakra bevallás tehát zárolom! |
| 6692 | src/#zak#migr_afa.prog.abap | * ...negyedéves |
| 6693 | src/#zak#migr_afa.prog.abap | * ...éves |
| 6694 | src/#zak#migr_afa.prog.abap | * Utolsó futás ideje - timestamp /ZAK/BEVALLSZ-LARUN |
| 6695 | src/#zak#migr_afa.prog.abap | * Mezőkatalógus összeállítása |
| 6696 | src/#zak#migr_afa.prog.abap | * Kilépés |
| 6697 | src/#zak#migr_afa.prog.abap | * ONYB-nél az F-et is lezárhatja. |
| 6698 | src/#zak#migr_afa.prog.screen_9000.abap | nincs emberi komment blokk |
| 6699 | src/#zak#migr_onrev.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Migrációs program önrevízióhoz - státuszok kezelése<br>*&---------------------------------------------------------------------* |
| 6700 | src/#zak#migr_onrev.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Migrációs program önrevízióhoz - státuszok kezelése<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Cserhegyi Tímea - fmc<br>*& Létrehozás dátuma : 2006.04.05<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   Cserhegyi T.  CL_GUI_FRONTEND_SERVICES<br>*&                                   cseréje hagyományosra<br>*& 0002   2007/05/09   Balázs G.     Általánosítás, hogy ne csak ÁFA<br>*&                                   migrációhoz lehessen használni.<br>*&---------------------------------------------------------------------*<br>*++S4HANA#01. |
| 6701 | src/#zak#migr_onrev.prog.abap | *&---------------------------------------------------------------------*<br>*& KONSTANSOK  (C_XXXXXXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* file típusok |
| 6702 | src/#zak#migr_onrev.prog.abap | * Hiba adaszerkezet tábla |
| 6703 | src/#zak#migr_onrev.prog.abap | * excel betöltéshez |
| 6704 | src/#zak#migr_onrev.prog.abap | * adatszerkezet hiba |
| 6705 | src/#zak#migr_onrev.prog.abap | * ALV kezelési változók |
| 6706 | src/#zak#migr_onrev.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6707 | src/#zak#migr_onrev.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6708 | src/#zak#migr_onrev.prog.abap | *  Bevallás fajta meghatározása |
| 6709 | src/#zak#migr_onrev.prog.abap | *  Jogosultság vizsgálat |
| 6710 | src/#zak#migr_onrev.prog.abap | * vezérlő táblák olvasása |
| 6711 | src/#zak#migr_onrev.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 6712 | src/#zak#migr_onrev.prog.abap | * Adatszerkezethez tartozó mező ellenörzések, és<br>* az oszlopok számának meghatározása. |
| 6713 | src/#zak#migr_onrev.prog.abap | * Analitika tábla szerkezet |
| 6714 | src/#zak#migr_onrev.prog.abap | * Adatszerkezet-mező összerendelés meghatározása<br>* Csak ABEV azonosítóval rendelkező mezőket dolgozunk fel! |
| 6715 | src/#zak#migr_onrev.prog.abap | * Adatszolgáltatás fájl formátuma alapján meghívom a betöltő funkciókat |
| 6716 | src/#zak#migr_onrev.prog.abap | * a hibák a I_HIBA táblában! |
| 6717 | src/#zak#migr_onrev.prog.abap | * Belső tábla kitöltés I_OUTTAB |
| 6718 | src/#zak#migr_onrev.prog.abap | * Belső tábla kitöltés I_OUTTAB |
| 6719 | src/#zak#migr_onrev.prog.abap | * Vállalat megnevezése |
| 6720 | src/#zak#migr_onrev.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 6721 | src/#zak#migr_onrev.prog.abap | * Vállalat + Bevallás típus |
| 6722 | src/#zak#migr_onrev.prog.abap | * Adatszolgáltatás |
| 6723 | src/#zak#migr_onrev.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 6724 | src/#zak#migr_onrev.prog.abap | * Összes adatszolgáltatás |
| 6725 | src/#zak#migr_onrev.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 6726 | src/#zak#migr_onrev.prog.abap | *   A megadott fájlt (&) nem lehet megnyitni! |
| 6727 | src/#zak#migr_onrev.prog.abap | * Adatszerkezet meghatározás |
| 6728 | src/#zak#migr_onrev.prog.abap | * SAP adatszolgáltatást jelenleg nem engedélyezett ! |
| 6729 | src/#zak#migr_onrev.prog.abap | *--S4HANA#01.<br>* aktivált? |
| 6730 | src/#zak#migr_onrev.prog.abap | *--S4HANA#01.<br>* egy bevallás típus csak egy bevallás fajtához tartozhat, így<br>* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni! |
| 6731 | src/#zak#migr_onrev.prog.abap | * Bevallás adatszolgáltatás feltöltések  ! |
| 6732 | src/#zak#migr_onrev.prog.abap | * analitika mezők megfeleltetése az adatszerkezetnek!<br>* Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát |
| 6733 | src/#zak#migr_onrev.prog.abap | * Mezőkatalógus összeállítása |
| 6734 | src/#zak#migr_onrev.prog.abap | * Kilépés |
| 6735 | src/#zak#migr_onrev.prog.abap | * Listára csak a BEVALLI rekordok kellenek. |
| 6736 | src/#zak#migr_onrev.prog.screen_9000.abap | nincs emberi komment blokk |
| 6737 | src/#zak#migr_szja_read.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SZJA XML migráció<br>*&---------------------------------------------------------------------* |
| 6738 | src/#zak#migr_szja_read.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: __________________<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor<br>*& Létrehozás dátuma : 2018.12.06<br>*& Funkc.spec.készítő: Balázs Gábor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : ________<br>*& SAP verzió        : ________<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ---------------------- -----------<br>*&---------------------------------------------------------------------* |
| 6739 | src/#zak#migr_szja_read.prog.abap | * file típusok |
| 6740 | src/#zak#migr_szja_read.prog.abap | *--PTGSZLAA 2014.03.04 BG (Ness)<br>* excel betöltéshez |
| 6741 | src/#zak#migr_szja_read.prog.abap | * file ellenörzése |
| 6742 | src/#zak#migr_szja_read.prog.abap | * analitika adatszerkezet |
| 6743 | src/#zak#migr_szja_read.prog.abap | *--1865 #10.<br>*type: begin of line<br>*&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* struktúra ellenőrzése |
| 6744 | src/#zak#migr_szja_read.prog.abap | * excel betöltéshez |
| 6745 | src/#zak#migr_szja_read.prog.abap | * adatszerkezet hiba |
| 6746 | src/#zak#migr_szja_read.prog.abap | * bevallási időszakok |
| 6747 | src/#zak#migr_szja_read.prog.abap | * Hiba adaszerkezet tábla |
| 6748 | src/#zak#migr_szja_read.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 6749 | src/#zak#migr_szja_read.prog.abap | * változók |
| 6750 | src/#zak#migr_szja_read.prog.abap | * szelekciós képernyő |
| 6751 | src/#zak#migr_szja_read.prog.abap | * excel betöltéshez |
| 6752 | src/#zak#migr_szja_read.prog.abap | * képernyőre |
| 6753 | src/#zak#migr_szja_read.prog.abap | * ALV kezelési változók |
| 6754 | src/#zak#migr_szja_read.prog.abap | * popup üzenethez |
| 6755 | src/#zak#migr_szja_read.prog.abap | * file ellenörzése |
| 6756 | src/#zak#migr_szja_read.prog.abap | *MAKRO definiálás range feltöltéshez |
| 6757 | src/#zak#migr_szja_read.prog.abap | * megnevezések |
| 6758 | src/#zak#migr_szja_read.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6759 | src/#zak#migr_szja_read.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6760 | src/#zak#migr_szja_read.prog.abap | * megnevezések |
| 6761 | src/#zak#migr_szja_read.prog.abap | *++BG 2006/08/31<br>*  Fájl névben vállalat kód ellenőrzés |
| 6762 | src/#zak#migr_szja_read.prog.abap | * bevallás fajta meghatározása |
| 6763 | src/#zak#migr_szja_read.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 6764 | src/#zak#migr_szja_read.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*++PTGSZLAA 2014.03.04 BG (Ness) |
| 6765 | src/#zak#migr_szja_read.prog.abap | *   A megadott fájlt (&) nem lehet megnyitni! |
| 6766 | src/#zak#migr_szja_read.prog.abap | *  Feldaraboljuk a fájl elérést. |
| 6767 | src/#zak#migr_szja_read.prog.abap | *  Az utolsó lesz a fájl név. |
| 6768 | src/#zak#migr_szja_read.prog.abap | *  Meghatározzuk a vállalat hosszát |
| 6769 | src/#zak#migr_szja_read.prog.abap | *  Ha a fáhjl név nem a vállalat kóddal kezdődik: |
| 6770 | src/#zak#migr_szja_read.prog.abap | *   Helytelen fájl! A fájl név nem a vállalat kóddal kezdődik! (&1) |
| 6771 | src/#zak#migr_szja_read.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 6772 | src/#zak#migr_szja_read.prog.abap | * egy bevallás típus csak egy bevallás fajtához tartozhat, így<br>* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni! |
| 6773 | src/#zak#migr_szja_read.prog.abap | *   Adatmódosítások elmentve! |
| 6774 | src/#zak#migr_szja_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SZJA XML migráció feltöltés<br>*&---------------------------------------------------------------------* |
| 6775 | src/#zak#migr_szja_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: __________________<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor<br>*& Létrehozás dátuma : 2018.12.06<br>*& Funkc.spec.készítő: Balázs Gábor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : ________<br>*& SAP verzió        : ________<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ---------------------- -----------<br>*&---------------------------------------------------------------------* |
| 6776 | src/#zak#migr_szja_sel.prog.abap | * file típusok |
| 6777 | src/#zak#migr_szja_sel.prog.abap | *--PTGSZLAA 2014.03.04 BG (Ness)<br>* excel betöltéshez |
| 6778 | src/#zak#migr_szja_sel.prog.abap | * file ellenörzése |
| 6779 | src/#zak#migr_szja_sel.prog.abap | * analitika adatszerkezet |
| 6780 | src/#zak#migr_szja_sel.prog.abap | *--1865 #10.<br>*type: begin of line<br>*&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* struktúra ellenőrzése |
| 6781 | src/#zak#migr_szja_sel.prog.abap | * excel betöltéshez |
| 6782 | src/#zak#migr_szja_sel.prog.abap | * adatszerkezet hiba |
| 6783 | src/#zak#migr_szja_sel.prog.abap | * bevallási időszakok |
| 6784 | src/#zak#migr_szja_sel.prog.abap | * Hiba adaszerkezet tábla |
| 6785 | src/#zak#migr_szja_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 6786 | src/#zak#migr_szja_sel.prog.abap | * változók |
| 6787 | src/#zak#migr_szja_sel.prog.abap | * szelekciós képernyő |
| 6788 | src/#zak#migr_szja_sel.prog.abap | * excel betöltéshez |
| 6789 | src/#zak#migr_szja_sel.prog.abap | * képernyőre |
| 6790 | src/#zak#migr_szja_sel.prog.abap | * ALV kezelési változók |
| 6791 | src/#zak#migr_szja_sel.prog.abap | * popup üzenethez |
| 6792 | src/#zak#migr_szja_sel.prog.abap | * file ellenörzése |
| 6793 | src/#zak#migr_szja_sel.prog.abap | *++0002 BG 2007.07.02<br>*MAKRO definiálás range feltöltéshez |
| 6794 | src/#zak#migr_szja_sel.prog.abap | * Szelekció |
| 6795 | src/#zak#migr_szja_sel.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 6796 | src/#zak#migr_szja_sel.prog.abap | *   Üzenetek kezelése |
| 6797 | src/#zak#mt_migr_afa.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Migrációs program ÁFA bevállás<br>*&---------------------------------------------------------------------* |
| 6798 | src/#zak#mt_migr_afa.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: Migrációs program önrevízióhoz - státuszok kezelése<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Kukely Anna<br>*& Létrehozás dátuma : 2006.10.30<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006.10.30   Kukely Anna      létrehozás<br>*&<br>*&---------------------------------------------------------------------* |
| 6799 | src/#zak#mt_migr_afa.prog.abap | * excel betöltéshez |
| 6800 | src/#zak#mt_migr_afa.prog.abap | * adatszerkezet hiba |
| 6801 | src/#zak#mt_migr_afa.prog.abap | * ALV kezelési változók |
| 6802 | src/#zak#mt_migr_afa.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6803 | src/#zak#mt_migr_afa.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6804 | src/#zak#mt_migr_afa.prog.abap | *  Bevallás fajta meghatározása |
| 6805 | src/#zak#mt_migr_afa.prog.abap | *  Jogosultság vizsgálat |
| 6806 | src/#zak#mt_migr_afa.prog.abap | * vezérlő táblák olvasása |
| 6807 | src/#zak#mt_migr_afa.prog.abap | * Vállalat megnevezése |
| 6808 | src/#zak#mt_migr_afa.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 6809 | src/#zak#mt_migr_afa.prog.abap | * Vállalat + Bevallás típus |
| 6810 | src/#zak#mt_migr_afa.prog.abap | * Adatszolgáltatás |
| 6811 | src/#zak#mt_migr_afa.prog.abap | * egy bevallás típus csak egy bevallás fajtához tartozhat, így<br>* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni! |
| 6812 | src/#zak#mt_migr_afa.prog.abap | * Bevallás adatszolgáltatás feltöltések  ! |
| 6813 | src/#zak#mt_migr_afa.prog.abap | * Adatszerkezet-mező összerendelés meghatározása |
| 6814 | src/#zak#mt_migr_afa.prog.abap | *++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28<br>*          SHIFT <F2> LEFT  DELETING LEADING 0. |
| 6815 | src/#zak#mt_migr_afa.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 6816 | src/#zak#mt_migr_afa.prog.abap | * Mező katalógus |
| 6817 | src/#zak#mt_migr_afa.prog.abap | * Mező katalógus |
| 6818 | src/#zak#mt_migr_afa.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 6819 | src/#zak#onell.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Önellenőrzési jegyzőkönyv készítés<br>*&---------------------------------------------------------------------* |
| 6820 | src/#zak#onell.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott adatok alapján<br>*& levállogatja a bevallás adataokat és elkészíti az önellenőrzés<br>*  jegyzőkönyvet.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2008.04.26<br>*& Funkc.spec.készítő: Róth Nándor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&--------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    -----------------------------------<br>*& 0001   2008.11.26   Balázs Gábor  Szelekció módosítása, készült<br>*&                                   dátum  megadható bevallásonként<br>*&---------------------------------------------------------------------*<br>*++S4HANA#01. |
| 6821 | src/#zak#onell.prog.abap | *Adatdeklaráció |
| 6822 | src/#zak#onell.prog.abap | *Közös rutinok |
| 6823 | src/#zak#onell.prog.abap | *Önellenőrzési pótlék összege. |
| 6824 | src/#zak#onell.prog.abap | *Vállalat |
| 6825 | src/#zak#onell.prog.abap | *Bevallás típus: |
| 6826 | src/#zak#onell.prog.abap | *Gazdasági év |
| 6827 | src/#zak#onell.prog.abap | *Gazdasági hónap |
| 6828 | src/#zak#onell.prog.abap | *Bevallás sorszáma időszakon belül |
| 6829 | src/#zak#onell.prog.abap | *Készült |
| 6830 | src/#zak#onell.prog.abap | *Teszt futás |
| 6831 | src/#zak#onell.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6832 | src/#zak#onell.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6833 | src/#zak#onell.prog.abap | * Bevallás fajta meghatározás |
| 6834 | src/#zak#onell.prog.abap | *  Jogosultság vizsgálat |
| 6835 | src/#zak#onell.prog.abap | * Vállalati adatok beolvasása |
| 6836 | src/#zak#onell.prog.abap | * Meghatározzuk a bevallás fajtát: |
| 6837 | src/#zak#onell.prog.abap | * Adatok meghatározása (teszt és előfeldolgozás) |
| 6838 | src/#zak#onell.prog.abap | * Adatok meghatározása (éles futás) |
| 6839 | src/#zak#onell.prog.abap | * Adatok meghatározása (megjelenítés) |
| 6840 | src/#zak#onell.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 6841 | src/#zak#onell.prog.abap | * Üzenetek megjelenítése |
| 6842 | src/#zak#onell.prog.abap | * Éles futás űrlap nyomtatás, adatok módosítás |
| 6843 | src/#zak#onell.prog.abap | *Adónemek meghatározása |
| 6844 | src/#zak#onell.prog.abap | * Önellenőrzés releváns adónemek meghatározása |
| 6845 | src/#zak#onell.prog.abap | * Meghatározzuk az esedékesség dátum abev azonosítóját |
| 6846 | src/#zak#onell.prog.abap | * Hiba a & bevallás esedékességi dátum meghatározásánál! |
| 6847 | src/#zak#onell.prog.abap | * Meghatározzuk az időszakokat: |
| 6848 | src/#zak#onell.prog.abap | * Adatok meghatározása adófolyószámla alapján |
| 6849 | src/#zak#onell.prog.abap | * Nem található adat a bevalláshoz (/ZAK/BEVALLO)! (&) |
| 6850 | src/#zak#onell.prog.abap | *       Hiba az adófolyószámla adatok meghatározásánál! (&) |
| 6851 | src/#zak#onell.prog.abap | *         Ha már volt feltöltve adat |
| 6852 | src/#zak#onell.prog.abap | *--0001 2008.11.26 (BG)<br>*           Esedékességi dátum meghatározása<br>*           Beolvassuk az adónemet |
| 6853 | src/#zak#onell.prog.abap | *             Nem lehet meghatározni az eredeti esedékesség dátumát! (&) |
| 6854 | src/#zak#onell.prog.abap | *         Az önellenőrzési adónemeket összesítjük egy összegbe |
| 6855 | src/#zak#onell.prog.abap | *       Ha már volt feltöltve adat |
| 6856 | src/#zak#onell.prog.abap | *       Önellenőrzés hozzáadás |
| 6857 | src/#zak#onell.prog.abap | *   A feldolgozás nem tartalmaz hibát! |
| 6858 | src/#zak#onell.prog.abap | * Nem háttér futás |
| 6859 | src/#zak#onell.prog.abap | * Háttér futás |
| 6860 | src/#zak#onell.prog.abap | * Menteni csak előfeldolgozásben lehet |
| 6861 | src/#zak#onell.prog.abap | * Megjelenítésnél és éles feldolgozásnál nem lehet szöveget<br>* módosítani |
| 6862 | src/#zak#onell.prog.abap | *   Mentés |
| 6863 | src/#zak#onell.prog.abap | *   Üzenetek megjelenítése |
| 6864 | src/#zak#onell.prog.abap | *   Űrlap megjelenítés |
| 6865 | src/#zak#onell.prog.abap | *   Szövegelem karbantartás |
| 6866 | src/#zak#onell.prog.abap | *   Szöveglem hozzárendelés |
| 6867 | src/#zak#onell.prog.abap | *   Szöveglem törlése |
| 6868 | src/#zak#onell.prog.abap | *   Összeg módosítás |
| 6869 | src/#zak#onell.prog.abap | * Kijelölt tételek meghatározása |
| 6870 | src/#zak#onell.prog.abap | *   Kérem jelöljön ki egy tételt. |
| 6871 | src/#zak#onell.prog.abap | * Szövegelem kiválasztása |
| 6872 | src/#zak#onell.prog.abap | * Adatok feldolgozása |
| 6873 | src/#zak#onell.prog.abap | * Kijelölt tételek meghatározása |
| 6874 | src/#zak#onell.prog.abap | *   Kérem jelöljön ki egy tételt. |
| 6875 | src/#zak#onell.prog.abap | * Adatok feldolgozása |
| 6876 | src/#zak#onell.prog.abap | *   Kérem válasszon ki egy szövegelemet! |
| 6877 | src/#zak#onell.prog.abap | * Ellenőrizzük van e hiba. |
| 6878 | src/#zak#onell.prog.abap | *   Mentés hibák miatt nem lehetséges! Lásd üzenetek! |
| 6879 | src/#zak#onell.prog.abap | * Ellenőrizzük ki van e töltve mindenütt a TEXT |
| 6880 | src/#zak#onell.prog.abap | *   Kérem minden tételhez adjon meg szöveg hozzárendelést! |
| 6881 | src/#zak#onell.prog.abap | *++0001 2008.11.26 (BG)<br>* Ellenőrizzük ki van e töltve mindenütt a KESZULT |
| 6882 | src/#zak#onell.prog.abap | *   Kérem minden tételhez adjon meg egy dátumot a "Készült" paraméterhez! |
| 6883 | src/#zak#onell.prog.abap | * ha minden rendben akkor mentés |
| 6884 | src/#zak#onell.prog.abap | *   Fejadatok feltöltése |
| 6885 | src/#zak#onell.prog.abap | *   Felhasználó |
| 6886 | src/#zak#onell.prog.abap | *--0001 2008.11.26 (BG)<br>*     Normál adónem |
| 6887 | src/#zak#onell.prog.abap | *     Önrevízió |
| 6888 | src/#zak#onell.prog.abap | * Adatbázis módosítások |
| 6889 | src/#zak#onell.prog.abap | * Adatmódosítások elmentve! |
| 6890 | src/#zak#onell.prog.abap | *--S4HANA#01.<br>* Fejadatok meghatározása |
| 6891 | src/#zak#onell.prog.abap | * Tétel adatok meghatározása |
| 6892 | src/#zak#onell.prog.abap | * Adatszolgáltatás adatok |
| 6893 | src/#zak#onell.prog.abap | * Adatok mappelése<br>* |
| 6894 | src/#zak#onell.prog.abap | *   Éles futás hibák miatt nem indítható! |
| 6895 | src/#zak#onell.prog.abap | * Űrlap adatok meghatározása |
| 6896 | src/#zak#onell.prog.abap | *   Hiba a & űrlap beolvasásánál! |
| 6897 | src/#zak#onell.prog.abap | *--S4HANA#01.<br>*   Adatok feldolgozása |
| 6898 | src/#zak#onell.prog.abap | *   Űrlap meghívása |
| 6899 | src/#zak#onell.prog.abap | * Tábla módosítások |
| 6900 | src/#zak#onell.prog.abap | * Adatmódosítások elmentve! |
| 6901 | src/#zak#onell.prog.abap | * Fejadatok meghatározása |
| 6902 | src/#zak#onell.prog.abap | * Tétel adatok meghatározása |
| 6903 | src/#zak#onell.prog.abap | * Adatok mappelése |
| 6904 | src/#zak#onell.prog.abap | * Ha előfeldolgozásban volt, akkor kilépés ellenőrzése |
| 6905 | src/#zak#onell.prog.abap | * Kijelölt tételek meghatározása |
| 6906 | src/#zak#onell.prog.abap | *   Kérem jelöljön ki egy tételt. |
| 6907 | src/#zak#onell.prog.abap | * Ha több tételt jelöl ki!<br>*++S4HANA#01.<br>*  DESCRIBE TABLE LT_ROWS LINES L_LINE. |
| 6908 | src/#zak#onell.prog.abap | *   Kérem csak egy sort jelöljön ki! |
| 6909 | src/#zak#onell.prog.abap | * Adatok feldolgozása |
| 6910 | src/#zak#onell.prog.abap | * Adónem ellenőrzése |
| 6911 | src/#zak#onell.prog.abap | *   Kérem önellenőrzéses adónemmel rendelkező sort válasszon ki! |
| 6912 | src/#zak#onell.prog.abap | * Összeg módosítása |
| 6913 | src/#zak#onell.prog.screen_0100.abap | nincs emberi komment blokk |
| 6914 | src/#zak#onell.prog.screen_0101.abap | nincs emberi komment blokk |
| 6915 | src/#zak#onell.prog.screen_0102.abap | nincs emberi komment blokk |
| 6916 | src/#zak#onj_jegyzokonyv.ssfo.gcoding.abap | nincs emberi komment blokk |
| 6917 | src/#zak#onjf01.prog.abap | *   Nem határozható meg a bevallás fajta! |
| 6918 | src/#zak#onjf01.prog.abap | * Kijelölt tételek meghatározása |
| 6919 | src/#zak#onjf01.prog.abap | *   Kérem jelöljön ki egy tételt. |
| 6920 | src/#zak#onjf01.prog.abap | * Űrlap adatok meghatározása |
| 6921 | src/#zak#onjf01.prog.abap | *   Hiba a & űrlap beolvasásánál! |
| 6922 | src/#zak#onjf01.prog.abap | * Adatok feldolgozása |
| 6923 | src/#zak#onjf01.prog.abap | *     Kérem adjon meg a tételekhez szöveg hozzárendelést! |
| 6924 | src/#zak#onjf01.prog.abap | *   Adatok feldolgozása |
| 6925 | src/#zak#onjf01.prog.abap | *     Kitöröljük a kijelölésből |
| 6926 | src/#zak#onjf01.prog.abap | *     SMARTFORMS adatok meghetározása |
| 6927 | src/#zak#onjf01.prog.abap | *   Űrlap meghívása |
| 6928 | src/#zak#onjf01.prog.abap | * Szöveg meghetározása |
| 6929 | src/#zak#onjf01.prog.abap | * Adatok feltöltése |
| 6930 | src/#zak#onjf01.prog.abap | * Adónem szöveg |
| 6931 | src/#zak#onjf01.prog.abap | * Pénznem |
| 6932 | src/#zak#onjf01.prog.abap | * Esedékesség |
| 6933 | src/#zak#onjf01.prog.abap | * Önrevízió |
| 6934 | src/#zak#onjf01.prog.abap | * Pótlék töltése |
| 6935 | src/#zak#onjf01.prog.abap | * Egyéb mezők töltése |
| 6936 | src/#zak#onjf01.prog.abap | *++BG 2009.07.16<br>* Vállalat |
| 6937 | src/#zak#onjf01.prog.abap | * Azonosító |
| 6938 | src/#zak#onjf01.prog.abap | * Készült |
| 6939 | src/#zak#onjf01.prog.abap | * Vállalat megnevezése |
| 6940 | src/#zak#onjf01.prog.abap | * Felhasználó neve |
| 6941 | src/#zak#onjf01.prog.abap | *   Hiba a & űrlap & azonosító kivitelénél! |
| 6942 | src/#zak#onjf01.prog.abap | *   Hiba a & űrlap & azonosító kivitelénél! |
| 6943 | src/#zak#onjtop.prog.abap | *Előfeldogozás |
| 6944 | src/#zak#onjtop.prog.abap | *Önellenőrzés adóneme |
| 6945 | src/#zak#onjtop.prog.abap | *MAKRO definiálás range feltöltéshez |
| 6946 | src/#zak#onjtop.prog.abap | *Önellenőrzéshez adatok: |
| 6947 | src/#zak#onjtop.prog.abap | *Önellenőrzéshez SMARTFORMS adatok: |
| 6948 | src/#zak#onyb_conv_08a60.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ONYB_CONV_08A60<br>*&<br>*&---------------------------------------------------------------------*<br>*& Funkció leírás: Adatok konvertálása 08A60-ra. (0761).<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2009.03.30<br>*& Funkc.spec.készítő: Róth Nándor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 50<br>*&---------------------------------------------------------------------* |
| 6949 | src/#zak#onyb_conv_08a60.prog.abap | *&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                      LEÍRÁS<br>*& ----   ----------   ----------    -----------------------------------<br>*&<br>*&---------------------------------------------------------------------* |
| 6950 | src/#zak#onyb_conv_08a60.prog.abap | *Vállalat |
| 6951 | src/#zak#onyb_conv_08a60.prog.abap | *Bevallás típus |
| 6952 | src/#zak#onyb_conv_08a60.prog.abap | *Hónap |
| 6953 | src/#zak#onyb_conv_08a60.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6954 | src/#zak#onyb_conv_08a60.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6955 | src/#zak#onyb_conv_08a60.prog.abap | * Meghatározzuk a BTYPE-okat: |
| 6956 | src/#zak#onyb_conv_08a60.prog.abap | * /ZAK/BEVALL és /ZAK/BEVALLT konverzió: |
| 6957 | src/#zak#onyb_conv_08a60.prog.abap | * /ZAK/ZAK_BEVASZ és /ZAK/BEVALLI konverzió: |
| 6958 | src/#zak#onyb_conv_08a60.prog.abap | * /ZAK/ANALITIKA konverzió |
| 6959 | src/#zak#onyb_conv_08a60.prog.abap | * /ZAK/BEVALLO konverzió |
| 6960 | src/#zak#onyb_conv_08a60.prog.abap | * Adatbázis módosítások: |
| 6961 | src/#zak#onyb_conv_08a60.prog.abap | *Csak Összesítő jelentés BTYPE-ok kellenek 08A60 előttiek: |
| 6962 | src/#zak#onyb_conv_08a60.prog.abap | * Új rekordok képzése: |
| 6963 | src/#zak#onyb_conv_08a60.prog.abap | * Új rekordok képzése: |
| 6964 | src/#zak#onyb_conv_08a60.prog.abap | *Adatok leválogatása |
| 6965 | src/#zak#onyb_conv_08a60.prog.abap | *   Adatok konverzió |
| 6966 | src/#zak#onyb_conv_08a60.prog.abap | *Adatok leválogatása |
| 6967 | src/#zak#onyb_conv_08a60.prog.abap | *   Adatok konverzió |
| 6968 | src/#zak#onyb_del_data.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ONYB_DEL_DATA<br>*&<br>*&---------------------------------------------------------------------*<br>*& Funkció leírás: Adatok törlése<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2009.03.30<br>*& Funkc.spec.készítő: Róth Nándor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 50<br>*&---------------------------------------------------------------------* |
| 6969 | src/#zak#onyb_del_data.prog.abap | *&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                      LEÍRÁS<br>*& ----   ----------   ----------    -----------------------------------<br>*&<br>*&---------------------------------------------------------------------* |
| 6970 | src/#zak#onyb_del_data.prog.abap | *Vállalat |
| 6971 | src/#zak#onyb_del_data.prog.abap | *Bevallás típus |
| 6972 | src/#zak#onyb_del_data.prog.abap | *Hónap |
| 6973 | src/#zak#onyb_del_data.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6974 | src/#zak#onyb_del_data.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6975 | src/#zak#onyb_del_data.prog.abap | * Meghatározzuk a BTYPE-okat: |
| 6976 | src/#zak#onyb_del_data.prog.abap | * /ZAK/ZAK_BEVASZ és /ZAK/BEVALLI törlés: |
| 6977 | src/#zak#onyb_del_data.prog.abap | * /ZAK/ANALITIKA törlés |
| 6978 | src/#zak#onyb_del_data.prog.abap | * /ZAK/BEVALLO törlés |
| 6979 | src/#zak#onyb_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ONYB_SAP_SEL<br>*&<br>*&---------------------------------------------------------------------*<br>*&Program: SAP adatok meghatározása összesítő jelentéshez<br>*&---------------------------------------------------------------------* |
| 6980 | src/#zak#onyb_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP-ZMT_ADO24_OJ_ANA táblából a szelekcióban<br>*& meghatározott adatokat és a /ZAK/ANALITIKA-ba tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2007.04.04<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                 LEÍRÁS<br>*& ----   ----------   ----------    -----------------------------------<br>*& 0001   2007.05.22   Balázs G.     MA01 váll. fordítása MMOB-ra<br>*& 0002   2007.10.08   Balázs G.     Vállalat forgatás<br>*& 0003   2008.01.21   Balázs G.     Vállalat forgatás átalakítás<br>*& 0004   2008.04.04   Balázs G.     Szelekció átalakítás ANALITIKA<br>*&                                   alapján<br>*& 0005   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra<br>*&                                   ellenőrzés visszaállítása<br>*& 0006   2010/01/27   Balázs G.     10A60 miatt NYLAPAZON meghatározás<br>*&---------------------------------------------------------------------* |
| 6981 | src/#zak#onyb_sap_sel.prog.abap | * ALV kezelési változók |
| 6982 | src/#zak#onyb_sap_sel.prog.abap | *MAKRO definiálás range feltöltéshez |
| 6983 | src/#zak#onyb_sap_sel.prog.abap | *Vállalat. |
| 6984 | src/#zak#onyb_sap_sel.prog.abap | *Bevallás típus. |
| 6985 | src/#zak#onyb_sap_sel.prog.abap | * Adatszolgáltatás azonosító |
| 6986 | src/#zak#onyb_sap_sel.prog.abap | *Teszt futás |
| 6987 | src/#zak#onyb_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 6988 | src/#zak#onyb_sap_sel.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 6989 | src/#zak#onyb_sap_sel.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 6990 | src/#zak#onyb_sap_sel.prog.abap | * Képernyő attribútomok beállítása |
| 6991 | src/#zak#onyb_sap_sel.prog.abap | * Megnevezések meghatározása |
| 6992 | src/#zak#onyb_sap_sel.prog.abap | *--2265 #09.<br>*++0004 2008.04.04  BG (FMC)<br>* Nem kell forgatás mivel már a forgatott adatokból dolgozunk |
| 6993 | src/#zak#onyb_sap_sel.prog.abap | * Jogosultság vizsgálat |
| 6994 | src/#zak#onyb_sap_sel.prog.abap | *  Vállalati adatok beolvasása |
| 6995 | src/#zak#onyb_sap_sel.prog.abap | *--0002 2007.10.08  BG (FMC)<br>*   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 6996 | src/#zak#onyb_sap_sel.prog.abap | * Meghatározzuk az ABEV azonosítókat |
| 6997 | src/#zak#onyb_sap_sel.prog.abap | *   Nincsenek beállítva a BEVALLB táblában az összesítő jelentés ABEV-ei! |
| 6998 | src/#zak#onyb_sap_sel.prog.abap | * Adatszelekció ANALITIKA alapján |
| 6999 | src/#zak#onyb_sap_sel.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7000 | src/#zak#onyb_sap_sel.prog.abap | * Teszt vagy éles futás, adatbázis módosítás, stb. |
| 7001 | src/#zak#onyb_sap_sel.prog.abap | *  Háttérben nem készítünk listát. |
| 7002 | src/#zak#onyb_sap_sel.prog.abap | * Vállalat megnevezése |
| 7003 | src/#zak#onyb_sap_sel.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7004 | src/#zak#onyb_sap_sel.prog.abap | *  Először mindig tesztben futtatjuk |
| 7005 | src/#zak#onyb_sap_sel.prog.abap | *   Üzenetek kezelése |
| 7006 | src/#zak#onyb_sap_sel.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 7007 | src/#zak#onyb_sap_sel.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 7008 | src/#zak#onyb_sap_sel.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról, |
| 7009 | src/#zak#onyb_sap_sel.prog.abap | *    Ha nem háttérben fut |
| 7010 | src/#zak#onyb_sap_sel.prog.abap | *    Szövegek betöltése |
| 7011 | src/#zak#onyb_sap_sel.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 7012 | src/#zak#onyb_sap_sel.prog.abap | *   Mehet az adatbázis módosítása |
| 7013 | src/#zak#onyb_sap_sel.prog.abap | *      Adatok módosítása |
| 7014 | src/#zak#onyb_sap_sel.prog.abap | *     Visszaírjuk a FLAG értékét: |
| 7015 | src/#zak#onyb_sap_sel.prog.abap | *     Feltöltés & package számmal megtörtént! |
| 7016 | src/#zak#onyb_sap_sel.prog.abap | * Mezőkatalógus összeállítása |
| 7017 | src/#zak#onyb_sap_sel.prog.abap | * Kilépés |
| 7018 | src/#zak#onyb_sap_sel.prog.abap | *    Hiba a & vállalat forgatás meghatározásnál! |
| 7019 | src/#zak#onyb_sap_sel.prog.abap | * Adatok leválogatása |
| 7020 | src/#zak#onyb_sap_sel.prog.abap | * Analitika feldolgozása |
| 7021 | src/#zak#onyb_sap_sel.prog.abap | *   Nem sikerült lap azonosítót meghatározni! (&/&/&/&) |
| 7022 | src/#zak#onyb_sap_sel.prog.abap | *   Adóazonosító |
| 7023 | src/#zak#onyb_sap_sel.prog.abap | *   ABEV azonosító |
| 7024 | src/#zak#onyb_sap_sel.prog.abap | *   Háromszögügylet feltöltés |
| 7025 | src/#zak#onyb_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 7026 | src/#zak#onyb_set_nylapazon.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/ONYB_SET_NYLAPAZON<br>*&<br>*&---------------------------------------------------------------------*<br>*&Program: A program a szelekción megadott bevallás típus adatainak<br>*&         lap azonosítóját feltölti 02-vel.<br>*&---------------------------------------------------------------------* |
| 7027 | src/#zak#onyb_set_nylapazon.prog.abap | * Jogosultság vizsgálat |
| 7028 | src/#zak#onyb_set_nylapazon.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7029 | src/#zak#onyb_set_nylapazon.prog.abap | * Képernyő attribútomok beállítása |
| 7030 | src/#zak#onyb_set_nylapazon.prog.abap | *   Tábla módosítások elvégezve! |
| 7031 | src/#zak#read_file.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Adatok beolvasása analitikákból<br>*&---------------------------------------------------------------------* |
| 7032 | src/#zak#read_file.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: __________________<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Dénes Károly<br>*& Létrehozás dátuma : 2006.01.03<br>*& Funkc.spec.készítő: Balázs Gábor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : ________<br>*& SAP verzió        : ________<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ---------------------- -----------<br>*& 0001   2007.01.03   Balázs G.(FMC) Felhasználó dátumforma ellenőrzés.<br>*& 0002   2007.06.04   Balázs G.(FMC) Kötelező mező kitöltésének ellen.<br>*& 0003   2008.12.11   Balázs G.(FMC) Adóazonosító ellenőrzés mód.<br>*&                                    /ZAK/XLS funkció elemben<br>*&                                    /ZAK/TXT funkció elemben<br>*& 0004   2010.03.18   Balázs G.(Ness) feltöltés javítás előző sorból<br>*&                                     maradtak értékek ha üres volt a<br>*&                                     mező.<br>*&---------------------------------------------------------------------* |
| 7033 | src/#zak#read_file.prog.abap | * file típusok |
| 7034 | src/#zak#read_file.prog.abap | *--PTGSZLAA 2014.03.04 BG (Ness)<br>* excel betöltéshez |
| 7035 | src/#zak#read_file.prog.abap | * file ellenörzése |
| 7036 | src/#zak#read_file.prog.abap | * analitika adatszerkezet |
| 7037 | src/#zak#read_file.prog.abap | *--1865 #10.<br>*type: begin of line<br>*&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* struktúra ellenőrzése |
| 7038 | src/#zak#read_file.prog.abap | * excel betöltéshez |
| 7039 | src/#zak#read_file.prog.abap | * adatszerkezet hiba |
| 7040 | src/#zak#read_file.prog.abap | * bevallási időszakok |
| 7041 | src/#zak#read_file.prog.abap | * Hiba adaszerkezet tábla |
| 7042 | src/#zak#read_file.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 7043 | src/#zak#read_file.prog.abap | * változók |
| 7044 | src/#zak#read_file.prog.abap | * szelekciós képernyő |
| 7045 | src/#zak#read_file.prog.abap | * excel betöltéshez |
| 7046 | src/#zak#read_file.prog.abap | * képernyőre |
| 7047 | src/#zak#read_file.prog.abap | * ALV kezelési változók |
| 7048 | src/#zak#read_file.prog.abap | * popup üzenethez |
| 7049 | src/#zak#read_file.prog.abap | * file ellenörzése |
| 7050 | src/#zak#read_file.prog.abap | *++0002 BG 2007.07.02<br>*MAKRO definiálás range feltöltéshez |
| 7051 | src/#zak#read_file.prog.abap | * ez ír a képernyőre |
| 7052 | src/#zak#read_file.prog.abap | * Analitika megjelenítése |
| 7053 | src/#zak#read_file.prog.abap | * megnevezések |
| 7054 | src/#zak#read_file.prog.abap | *--2365 #08.<br>* Jogosultság vizsgálat |
| 7055 | src/#zak#read_file.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7056 | src/#zak#read_file.prog.abap | * megnevezések |
| 7057 | src/#zak#read_file.prog.abap | *++BG 2006/08/31<br>*  Fájl névben vállalat kód ellenőrzés |
| 7058 | src/#zak#read_file.prog.abap | *  Blokk ellenőrzése |
| 7059 | src/#zak#read_file.prog.abap | * Választó kapcsoló ellenörzése ! |
| 7060 | src/#zak#read_file.prog.abap | * bevallás fajta meghatározása |
| 7061 | src/#zak#read_file.prog.abap | *  Jogosultság vizsgálat |
| 7062 | src/#zak#read_file.prog.abap | * vezérlő táblák olvasása |
| 7063 | src/#zak#read_file.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 7064 | src/#zak#read_file.prog.abap | * Adatszerkezethez tartozó mező ellenörzések, és<br>* az oszlopok számának meghatározása. |
| 7065 | src/#zak#read_file.prog.abap | * Analitika tábla szerkezet |
| 7066 | src/#zak#read_file.prog.abap | * Adatszerkezet-mezző összerendelés meghatározása<br>* Csak ABEV azonosítóval rendelkező mezőket dolgozunk fel! |
| 7067 | src/#zak#read_file.prog.abap | * Adatszolgáltatás fájl formátuma alapján meghívom a betöltő funkciókat |
| 7068 | src/#zak#read_file.prog.abap | * a hibák a I_HIBA táblában! |
| 7069 | src/#zak#read_file.prog.abap | *++BG 2007/02/12<br>* Tételszám vizsgálat, itt csak a max. konstansban meghatározott<br>* tételszám tölthető be! |
| 7070 | src/#zak#read_file.prog.abap | *--1565 #10.<br>*          A megadott fájl sorok száma (&), nagyobb a max.megengedettnél (&)! |
| 7071 | src/#zak#read_file.prog.abap | *--BG 2007/02/12<br>* alv lista belső tábla kitöltés I_OUTTAB |
| 7072 | src/#zak#read_file.prog.abap | * szja exit meghívása |
| 7073 | src/#zak#read_file.prog.abap | * ABEV exit meghívása |
| 7074 | src/#zak#read_file.prog.abap | * Analitika tételek konverziója,csak hibátlan betöltés esetén |
| 7075 | src/#zak#read_file.prog.abap | *++BG 2006.09.15<br>*  SZJA bevallásnál nem lehet több BTYPE egy feladásban |
| 7076 | src/#zak#read_file.prog.abap | *--BG 2006.09.15<br>*++1365 2013.01.22 Balázs Gábor (Ness)<br>*  SZLA adatok generálása |
| 7077 | src/#zak#read_file.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness)<br>* Adatbázis tábla update |
| 7078 | src/#zak#read_file.prog.abap | *  Vizsgálat, adatbázis módosítás. Teszt v Éles |
| 7079 | src/#zak#read_file.prog.abap | *  GRID maximális sor korlátozás |
| 7080 | src/#zak#read_file.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7081 | src/#zak#read_file.prog.abap | * Bevallás adatszolgáltatás feltöltések  ! |
| 7082 | src/#zak#read_file.prog.abap | * Adatszerkezet-mezző összerendelés meghatározása |
| 7083 | src/#zak#read_file.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7084 | src/#zak#read_file.prog.abap | * Adatszerkezet meghatározás |
| 7085 | src/#zak#read_file.prog.abap | * SAP adatszolgáltatást jelenleg nem engedélyezett ! |
| 7086 | src/#zak#read_file.prog.abap | *   & adatszolgáltatás speciálisra van beállítva! (/ZAK/BEVALLD) |
| 7087 | src/#zak#read_file.prog.abap | * XML formátumnál nem kell struktúra |
| 7088 | src/#zak#read_file.prog.abap | * Adatszerkezet meglétének ellenörzése! |
| 7089 | src/#zak#read_file.prog.abap | * aktivált? |
| 7090 | src/#zak#read_file.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 7091 | src/#zak#read_file.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*++PTGSZLAA 2014.03.04 BG (Ness) |
| 7092 | src/#zak#read_file.prog.abap | *   A megadott fájlt (&) nem lehet megnyitni! |
| 7093 | src/#zak#read_file.prog.abap | *--1565 #03.<br>* ALV lista |
| 7094 | src/#zak#read_file.prog.abap | *    Adatbetöltés megs/zak/zakítva! |
| 7095 | src/#zak#read_file.prog.abap | * az adatszerkezet SAP-os struktúrája a /ZAK/BEVALLD-strname táblából<br>* kell venni |
| 7096 | src/#zak#read_file.prog.abap | * Kilépés |
| 7097 | src/#zak#read_file.prog.abap | * analitika struktúra megjelenítés |
| 7098 | src/#zak#read_file.prog.abap | *  GRID maximális sor korlátozás |
| 7099 | src/#zak#read_file.prog.abap | * Mezőkatalógus összeállítása |
| 7100 | src/#zak#read_file.prog.abap | * /ZAK/ANALITIKA tábla |
| 7101 | src/#zak#read_file.prog.abap | * túl sok mező a megjelenítésben |
| 7102 | src/#zak#read_file.prog.abap | * hiba tábla |
| 7103 | src/#zak#read_file.prog.abap | * COMPTYPE = 'S' includ sor ezért nem vesszük figyelembe |
| 7104 | src/#zak#read_file.prog.abap | *--2007.01.11 BG (FMC)<br>*++0002 BG 2007.07.13<br>*  Feltöltjük a kötelező mezőket: |
| 7105 | src/#zak#read_file.prog.abap | *    Meghatározzuk a pozíciót a struktúrában: |
| 7106 | src/#zak#read_file.prog.abap | *++2108 #01.<br>*  Ha ki van töltve a sor ozslop struktúra, akkor a szerint kell töltenünk |
| 7107 | src/#zak#read_file.prog.abap | *++1765 #30.<br>*Az I_XLS struktúrában a sor értéke N4 típus miatt 9999 után újraindul,<br>*így a MOVE-CORRESPONDING utasítás mindig az első 9999 előfordulásból<br>*felülírta az értékeket!<br>*++2108 #01. |
| 7108 | src/#zak#read_file.prog.abap | *     A hét számának meghatároztása |
| 7109 | src/#zak#read_file.prog.abap | *--PTGSZLAA 2014.03.04 BG (Ness)<br>*++0004 2010.03.18 Balázs Gábor (Ness) |
| 7110 | src/#zak#read_file.prog.abap | *--0004 2010.03.18 Balázs Gábor (Ness)<br>*     analitika mezők megfeleltetése az adatszerkezetnek!<br>*     Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát |
| 7111 | src/#zak#read_file.prog.abap | *--1465 #13.<br>*++0002 BG 2007.07.13<br>*              Meghatározzuk, hogy a kötelező mezők ki vannak e töltve: |
| 7112 | src/#zak#read_file.prog.abap | *        Sorindex összerakása |
| 7113 | src/#zak#read_file.prog.abap | *        Elértük a maximális értéket, újra kezdjük |
| 7114 | src/#zak#read_file.prog.abap | *          Inicializálás |
| 7115 | src/#zak#read_file.prog.abap | *          Növeljük a lapszámot |
| 7116 | src/#zak#read_file.prog.abap | * csak az ABEV azonosítóval kapcsolt mezőket dolgozom fel! |
| 7117 | src/#zak#read_file.prog.abap | *          BTYPE ellenőrzése<br>*++PTGSZLAA 2014.03.04 BG (Ness) |
| 7118 | src/#zak#read_file.prog.abap | * Összeg mezőnél nem lehet karakteres érték! |
| 7119 | src/#zak#read_file.prog.abap | * item beállítása |
| 7120 | src/#zak#read_file.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7121 | src/#zak#read_file.prog.abap | * Mezőkatalógus összeállítása |
| 7122 | src/#zak#read_file.prog.abap | *   Feltöltés azonosító figyelmen kívül hagyva! |
| 7123 | src/#zak#read_file.prog.abap | *   Kérem adja meg a feltöltés azonosítót! |
| 7124 | src/#zak#read_file.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7125 | src/#zak#read_file.prog.abap | *  Először mindig tesztben futtatjuk |
| 7126 | src/#zak#read_file.prog.abap | *++1365 #11.<br>*     Megadjuk a  BTYPART-ot is és majd<br>*     a funkció meghatározza melyik BTYPE tartotik hozzá<br>*     így egy állomány több évi adatot is tartalmazhat. |
| 7127 | src/#zak#read_file.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7128 | src/#zak#read_file.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 7129 | src/#zak#read_file.prog.abap | *   Üzenetek kezelése |
| 7130 | src/#zak#read_file.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 7131 | src/#zak#read_file.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról |
| 7132 | src/#zak#read_file.prog.abap | *--1765 #31.<br>*    Szövegek betöltése |
| 7133 | src/#zak#read_file.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 7134 | src/#zak#read_file.prog.abap | *    Mehet az adatbázis módosítása |
| 7135 | src/#zak#read_file.prog.abap | *      Adatok módosítása |
| 7136 | src/#zak#read_file.prog.abap | *++1365 #11.<br>*          Megadjuk a  BTYPART-ot is és majd<br>*          a funkció meghatározza melyik BTYPE tartotik hozzá<br>*          így egy állomány több évi adatot is tartalmazhat. |
| 7137 | src/#zak#read_file.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7138 | src/#zak#read_file.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 7139 | src/#zak#read_file.prog.abap | *      Feltöltés & package számmal megtörtént!<br>*++PTGSZLAA 2014.03.04 BG (Ness)<br>*      Fájl mozgatása a ....\old\<filename> könyvtárba |
| 7140 | src/#zak#read_file.prog.abap | *           Hiba a & fájl "OLD" könyvtárba mozgatásnál! |
| 7141 | src/#zak#read_file.prog.abap | * analitika mezők megfeleltetése az adatszerkezetnek!<br>* Ha a mező név azonos, akkor töltöm a /ZAK/ANALITIKA táblát |
| 7142 | src/#zak#read_file.prog.abap | *--1465 #06.<br>*++1765 #32.<br>*        Dátum esetén a felhasználó dátumformátum alapján<br>*        konvertálunk: |
| 7143 | src/#zak#read_file.prog.abap | *--2010.12.09 Balázs Gábor currency kezelés |
| 7144 | src/#zak#read_file.prog.abap | * egy bevallás típus csak egy bevallás fajtához tartozhat, így<br>* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni! |
| 7145 | src/#zak#read_file.prog.abap | *  Meghatározzuk a sorok számát |
| 7146 | src/#zak#read_file.prog.abap | *   Memória túlcsordulás miatt megjelenítés & tételre korlátozva! |
| 7147 | src/#zak#read_file.prog.abap | *  Feldaraboljuk a fájl elérést. |
| 7148 | src/#zak#read_file.prog.abap | *  Az utolsó lesz a fájl név. |
| 7149 | src/#zak#read_file.prog.abap | *  Meghatározzuk a vállalat hosszát |
| 7150 | src/#zak#read_file.prog.abap | *  Ha a fáhjl név nem a vállalat kóddal kezdődik: |
| 7151 | src/#zak#read_file.prog.abap | *   Helytelen fájl! A fájl név nem a vállalat kóddal kezdődik! (&1) |
| 7152 | src/#zak#read_kata.prog.abap | *&---------------------------------------------------------------------*<br>*& Report /ZAK/READ_KATA<br>*&---------------------------------------------------------------------*<br>*& KATA adatok feltöltése excel fájlból<br>*&---------------------------------------------------------------------* |
| 7153 | src/#zak#read_kata.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: __________________<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gáébor<br>*& Létrehozás dátuma : 2021.02.21<br>*& Funkc.spec.készítő: Balázs Gábor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : ________<br>*& SAP verzió        : ________<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ---------------------- -----------<br>*&---------------------------------------------------------------------* |
| 7154 | src/#zak#read_kata.prog.abap | * excel betöltéshez |
| 7155 | src/#zak#read_kata.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 7156 | src/#zak#read_kata.prog.abap | *Vállalat |
| 7157 | src/#zak#read_kata.prog.abap | *Fájl |
| 7158 | src/#zak#read_kata.prog.abap | *Tesztfutás |
| 7159 | src/#zak#read_kata.prog.abap | *++2265 #02.<br>* Jogosultság vizsgálat |
| 7160 | src/#zak#read_kata.prog.abap | * Fájlnév keresési segítség |
| 7161 | src/#zak#read_kata.prog.abap | * Szelekció ellenőrzés |
| 7162 | src/#zak#read_kata.prog.abap | * Fájlnév vállalat összerendelés ellenőrzés |
| 7163 | src/#zak#read_kata.prog.abap | * Fájl beolvasása |
| 7164 | src/#zak#read_kata.prog.abap | *   A & állomány nem tartalmaz feldolgozható rekordot! |
| 7165 | src/#zak#read_kata.prog.abap | * Fájl ellenőrzése |
| 7166 | src/#zak#read_kata.prog.abap | * Hibakezelés |
| 7167 | src/#zak#read_kata.prog.abap | *  Éles feldolgozás hibák miatt nem lehetséges! Lásd üzenetek! |
| 7168 | src/#zak#read_kata.prog.abap | *  Feldolgozás során előfordultak üzenetek! |
| 7169 | src/#zak#read_kata.prog.abap | * Adatbázis menetés |
| 7170 | src/#zak#read_kata.prog.abap | * Online módban |
| 7171 | src/#zak#read_kata.prog.abap | *     Hiba & fájl megnyitásánál! |
| 7172 | src/#zak#read_kata.prog.abap | *  Feldaraboljuk a fájl elérést. |
| 7173 | src/#zak#read_kata.prog.abap | *  Az utolsó lesz a fájl név. |
| 7174 | src/#zak#read_kata.prog.abap | *  Meghatározzuk a vállalat hosszát |
| 7175 | src/#zak#read_kata.prog.abap | *  Ha a fáhjl név nem a vállalat kóddal kezdődik: |
| 7176 | src/#zak#read_kata.prog.abap | *   Helytelen fájl! A fájl név nem a vállalat kóddal kezdődik! (&1) |
| 7177 | src/#zak#read_kata.prog.abap | *   Összeg konverzió belső HUF formátumra |
| 7178 | src/#zak#read_kata.prog.abap | *                 A cellában lévő & érték nem megfelelő az XLS fájlban (&. sor)! |
| 7179 | src/#zak#read_kata.prog.abap | *            Mező konverzió hiba! (&: &) |
| 7180 | src/#zak#read_kata.prog.abap | *         Kritikus hiba: &1 mező hiányzik az adatbázis struktúrából! |
| 7181 | src/#zak#read_kata.prog.abap | *       Kritikus hiba: a fej nem tartalmaz elégendő mezőt! |
| 7182 | src/#zak#read_kata.prog.abap | * COMPTYPE = 'S' includ sor ezért nem vesszük figyelembe |
| 7183 | src/#zak#read_kata.prog.abap | *     Fájlban & vállalat nem egyezik meg a szelekcióban megadott & vállalattal! |
| 7184 | src/#zak#read_kata.prog.abap | *      Fájlban kötelező mező nincs megadva! |
| 7185 | src/#zak#read_kata.prog.abap | *   Pénznem ellenőrzése |
| 7186 | src/#zak#read_kata.prog.abap | *      A feldolgozásban & pénznem, nem egyezik meg a vállalat & pénznemével! |
| 7187 | src/#zak#read_kata.prog.abap | *   Az XLS fájlban duplikált érték található! (&) |
| 7188 | src/#zak#read_kata.prog.abap | * Feltöltés azonosító generálás |
| 7189 | src/#zak#read_kata.prog.abap | *   Feltöltés azonosító számkör hiba! |
| 7190 | src/#zak#read_kata.prog.abap | *  Feltöltés & package számmal megtörtént! |
| 7191 | src/#zak#read_migr_xml.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: __________________<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor<br>*& Létrehozás dátuma : 2016.07.18<br>*& Funkc.spec.készítő: Balázs Gábor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : ________<br>*& SAP verzió        : ________<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                   LEÍRÁS<br>*& ----   ----------   ----------     ---------------------- ----------- |
| 7192 | src/#zak#read_migr_xml.prog.abap | *&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* struktúra ellenőrzése |
| 7193 | src/#zak#read_migr_xml.prog.abap | * adatszerkezet hiba |
| 7194 | src/#zak#read_migr_xml.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 7195 | src/#zak#read_migr_xml.prog.abap | * Hiba adaszerkezet tábla |
| 7196 | src/#zak#read_migr_xml.prog.abap | * ALV kezelési változók |
| 7197 | src/#zak#read_migr_xml.prog.abap | * popup üzenethez |
| 7198 | src/#zak#read_migr_xml.prog.abap | * file ellenörzése |
| 7199 | src/#zak#read_migr_xml.prog.abap | *++0002 BG 2007.07.02<br>*MAKRO definiálás range feltöltéshez |
| 7200 | src/#zak#read_migr_xml.prog.abap | * ez ír a képernyőre |
| 7201 | src/#zak#read_migr_xml.prog.abap | * Analitika megjelenítése |
| 7202 | src/#zak#read_migr_xml.prog.abap | * megnevezések |
| 7203 | src/#zak#read_migr_xml.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 7204 | src/#zak#read_migr_xml.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7205 | src/#zak#read_migr_xml.prog.abap | * megnevezések |
| 7206 | src/#zak#read_migr_xml.prog.abap | *  Fájl névben vállalat kód ellenőrzés |
| 7207 | src/#zak#read_migr_xml.prog.abap | * bevallás fajta meghatározása |
| 7208 | src/#zak#read_migr_xml.prog.abap | *  Jogosultság vizsgálat |
| 7209 | src/#zak#read_migr_xml.prog.abap | * vezérlő táblák olvasása |
| 7210 | src/#zak#read_migr_xml.prog.abap | * Adatszerkezet meghatározás és meglétének ellenörzése |
| 7211 | src/#zak#read_migr_xml.prog.abap | * Adatbázis tábla update |
| 7212 | src/#zak#read_migr_xml.prog.abap | *  Vizsgálat, adatbázis módosítás. Teszt v Éles |
| 7213 | src/#zak#read_migr_xml.prog.abap | *  GRID maximális sor korlátozás |
| 7214 | src/#zak#read_migr_xml.prog.abap | *   Kérem ONYB vagy ÁFA bevallás típust adjon meg!<br>*--1765 #01. |
| 7215 | src/#zak#read_migr_xml.prog.abap | *   Ez a program a  & adatszolgáltatáshoz nem használható! |
| 7216 | src/#zak#read_migr_xml.prog.abap | *   A megadott fájlt (&) nem lehet megnyitni! |
| 7217 | src/#zak#read_migr_xml.prog.abap | * egy bevallás típus csak egy bevallás fajtához tartozhat, így<br>* a bevallás fajta meghatározásánál elég az első bejegyzést vizsgálni! |
| 7218 | src/#zak#read_migr_xml.prog.abap | * Bevallás adatszolgáltatás feltöltések  ! |
| 7219 | src/#zak#read_migr_xml.prog.abap | * Adatszerkezet-mezző összerendelés meghatározása |
| 7220 | src/#zak#read_migr_xml.prog.abap | * Adatszerkezet meghatározás |
| 7221 | src/#zak#read_migr_xml.prog.abap | * SAP adatszolgáltatást jelenleg nem engedélyezett ! |
| 7222 | src/#zak#read_migr_xml.prog.abap | *   & adatszolgáltatás speciálisra van beállítva! (/ZAK/BEVALLD) |
| 7223 | src/#zak#read_migr_xml.prog.abap | * XML formátumnál nem kell struktúra |
| 7224 | src/#zak#read_migr_xml.prog.abap | *   Kérem csak XML típusú adatszolgáltatás azonosítót válasszon! |
| 7225 | src/#zak#read_migr_xml.prog.abap | *  Feldaraboljuk a fájl elérést. |
| 7226 | src/#zak#read_migr_xml.prog.abap | *  Az utolsó lesz a fájl név. |
| 7227 | src/#zak#read_migr_xml.prog.abap | *  Meghatározzuk a vállalat hosszát |
| 7228 | src/#zak#read_migr_xml.prog.abap | *  Ha a fáhjl név nem a vállalat kóddal kezdődik: |
| 7229 | src/#zak#read_migr_xml.prog.abap | *   Helytelen fájl! A fájl név nem a vállalat kóddal kezdődik! (&1) |
| 7230 | src/#zak#read_migr_xml.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7231 | src/#zak#read_migr_xml.prog.abap | *  Először mindig tesztben futtatjuk |
| 7232 | src/#zak#read_migr_xml.prog.abap | *++1365 #11.<br>*     Megadjuk a  BTYPART-ot is és majd<br>*     a funkció meghatározza melyik BTYPE tartotik hozzá<br>*     így egy állomány több évi adatot is tartalmazhat. |
| 7233 | src/#zak#read_migr_xml.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7234 | src/#zak#read_migr_xml.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 7235 | src/#zak#read_migr_xml.prog.abap | *   Üzenetek kezelése |
| 7236 | src/#zak#read_migr_xml.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van ERROR |
| 7237 | src/#zak#read_migr_xml.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 7238 | src/#zak#read_migr_xml.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról |
| 7239 | src/#zak#read_migr_xml.prog.abap | *    Szövegek betöltése |
| 7240 | src/#zak#read_migr_xml.prog.abap | *    Egyébként mehet |
| 7241 | src/#zak#read_migr_xml.prog.abap | *    Mehet az adatbázis módosítása |
| 7242 | src/#zak#read_migr_xml.prog.abap | *++1765 #04.<br>*    Ha önrevízió, akkor alap időszakok megnyitása |
| 7243 | src/#zak#read_migr_xml.prog.abap | *--1765 #04.<br>*      Adatok módosítása |
| 7244 | src/#zak#read_migr_xml.prog.abap | *++1365 #11.<br>*          Megadjuk a  BTYPART-ot is és majd<br>*          a funkció meghatározza melyik BTYPE tartotik hozzá<br>*          így egy állomány több évi adatot is tartalmazhat. |
| 7245 | src/#zak#read_migr_xml.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7246 | src/#zak#read_migr_xml.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 7247 | src/#zak#read_migr_xml.prog.abap | *--1565 #03.<br>* ALV lista |
| 7248 | src/#zak#read_migr_xml.prog.abap | *    Adatbetöltés megs/zak/zakítva! |
| 7249 | src/#zak#read_migr_xml.prog.abap | * az adatszerkezet SAP-os struktúrája a /ZAK/BEVALLD-strname táblából<br>* kell venni |
| 7250 | src/#zak#read_migr_xml.prog.abap | * Kilépés |
| 7251 | src/#zak#read_migr_xml.prog.abap | * analitika struktúra megjelenítés |
| 7252 | src/#zak#read_migr_xml.prog.abap | *  GRID maximális sor korlátozás |
| 7253 | src/#zak#read_migr_xml.prog.abap | * Mezőkatalógus összeállítása |
| 7254 | src/#zak#read_migr_xml.prog.abap | * /ZAK/ANALITIKA tábla |
| 7255 | src/#zak#read_migr_xml.prog.abap | * túl sok mező a megjelenítésben |
| 7256 | src/#zak#read_migr_xml.prog.abap | * hiba tábla |
| 7257 | src/#zak#read_migr_xml.prog.abap | * Mezőkatalógus összeállítása |
| 7258 | src/#zak#read_migr_xml.prog.abap | *  Meghatározzuk a sorok számát |
| 7259 | src/#zak#read_migr_xml.prog.abap | *   Memória túlcsordulás miatt megjelenítés & tételre korlátozva! |
| 7260 | src/#zak#read_migr_xml_0203.prog.abap | *&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* struktúra ellenőrzése |
| 7261 | src/#zak#read_migr_xml_0203.prog.abap | * adatszerkezet hiba |
| 7262 | src/#zak#read_migr_xml_0203.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 7263 | src/#zak#read_migr_xml_0203.prog.abap | * Hiba adaszerkezet tábla |
| 7264 | src/#zak#read_migr_xml_0203.prog.abap | * ALV kezelési változók |
| 7265 | src/#zak#read_migr_xml_0203.prog.abap | * popup üzenethez |
| 7266 | src/#zak#read_migr_xml_0203.prog.abap | * file ellenörzése |
| 7267 | src/#zak#read_migr_xml_0203.prog.abap | *++0002 BG 2007.07.02<br>*MAKRO definiálás range feltöltéshez |
| 7268 | src/#zak#read_migr_xml_0203.prog.abap | *XML beolvasáshiz |
| 7269 | src/#zak#read_migr_xml_0203.prog.abap | * XML fájl beolvasása |
| 7270 | src/#zak#read_migr_xml_0203.prog.abap | *      L_FULLPATH TYPE STRING,<br>*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*        L_FULLPATH     LIKE RLGRAP-FILENAME, |
| 7271 | src/#zak#read_migr_xml_0203.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7272 | src/#zak#read_migr_xml_0203.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7273 | src/#zak#read_migr_xml_0203.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27 |
| 7274 | src/#zak#read_top.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7275 | src/#zak#read_top.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness)<br>*++PTGSZLAA #01. 2014.03.03 |
| 7276 | src/#zak#read_top.prog.abap | *--2108 #09.<br>*++2009.03.17 BG<br>*Bérleti lízing: |
| 7277 | src/#zak#read_top.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7278 | src/#zak#read_top.prog.abap | *--1365 2013.01.22 Balázs Gábor (Ness)<br>*++PTGSZLAA #01. 2014.03.03 |
| 7279 | src/#zak#read_top.prog.abap | *--2108 #09.<br>*++2009.03.17 BG<br>*Bérleti lízing: |
| 7280 | src/#zak#read_txt.fugr.#zak#csv.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27 |
| 7281 | src/#zak#read_txt.fugr.#zak#csv.abap | *   Hiba az fájl megnyitásánál! |
| 7282 | src/#zak#read_txt.fugr.#zak#csv.abap | *++BG 2006/07/07<br>* Fejléces adatállomány első sor törlése |
| 7283 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * automatikus ellenörzés a konvertálási rutin alapján periódus! |
| 7284 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * főkönyvi szám ellenörzése |
| 7285 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | *         adószám ellenörzése |
| 7286 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * csak érték lehet |
| 7287 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * Hiba tábla töltése |
| 7288 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * mező tipus, hossz, tartalom alapján ellenörzés, az eredmény<br>* a check_tab-reptext mezőbe írom. |
| 7289 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * automatikus ellenörzés a konvertálási rutin alapján periódus! |
| 7290 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * főkönyvi szám ellenörzése |
| 7291 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | *         adószám ellenörzése |
| 7292 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * csak érték lehet |
| 7293 | src/#zak#read_txt.fugr.#zak#lread_txtf01.abap | * Hiba tábla töltése |
| 7294 | src/#zak#read_txt.fugr.#zak#lread_txttop.abap | *&---------------------------------------------------------------------*<br>*& Táblák                                                              *<br>*&---------------------------------------------------------------------* |
| 7295 | src/#zak#read_txt.fugr.#zak#lread_txttop.abap | * Hiba leíró tábla |
| 7296 | src/#zak#read_txt.fugr.#zak#saplread_txt.abap | nincs emberi komment blokk |
| 7297 | src/#zak#read_txt.fugr.#zak#txt.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27 |
| 7298 | src/#zak#read_txt.fugr.#zak#txt.abap | *   Hiba az fájl megnyitásánál!<br>*--BG 2006.04.10 |
| 7299 | src/#zak#read_txt.fugr.#zak#txt.abap | *++BG 2006/07/07<br>* Fejléces adatállomány első sor törlése |
| 7300 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | *--BG 2009.03.27<br>* automatikus ellenörzés a konvertálási rutin alapján periódus! |
| 7301 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | * főkönyvi szám ellenörzése |
| 7302 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | *++BG 2009.03.27<br>*   Meghatározzuk a mező hosszát |
| 7303 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | * kötelező mezők ellenörzése! |
| 7304 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | *    CASE $CHECK_TAB-ROLLNAME.<br>*      WHEN 'SPBUP'       OR<br>*           'NATSL'       OR<br>*           'GESCH'       OR<br>*           'PAD_CNAME'   OR<br>*           '/ZAK/LAKCIM'  OR<br>*           '/ZAK/ADOAZON' OR<br>*           'DMBTR'       OR<br>*           'HWBAS'       OR<br>*           'DMBTR'.<br>*        $CHECK_TAB-REPTEXT = 'Mező megadása kötelező'.<br>*    ENDCASE. |
| 7305 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | *  mező típus ellenörzése, tartalmi ellenörzés |
| 7306 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | *   Adószám átalakítás '-' nélkülire |
| 7307 | src/#zak#read_xls.fugr.#zak#lread_xlsf01.abap | * csak érték lehet |
| 7308 | src/#zak#read_xls.fugr.#zak#lread_xlstop.abap | *&---------------------------------------------------------------------*<br>*& Táblák                                                              *<br>*&---------------------------------------------------------------------* |
| 7309 | src/#zak#read_xls.fugr.#zak#lread_xlstop.abap | * Hiba leíró tábla |
| 7310 | src/#zak#read_xls.fugr.#zak#lread_xlstop.abap | * változók |
| 7311 | src/#zak#read_xls.fugr.#zak#saplread_xls.abap | nincs emberi komment blokk |
| 7312 | src/#zak#read_xls.fugr.#zak#xls.abap | *++BG 2006/07/07<br>* Ha fejléces az adatállomány, akkor első sor törlése |
| 7313 | src/#zak#read_xls.fugr.#zak#xls.abap | * Adatok betöltése belső táblába |
| 7314 | src/#zak#read_xls.fugr.#zak#xls.abap | * mező tipus, hossz, tartalom alapján ellenörzés, az eredmény<br>* a check_tab-reptext mezőbe írom. |
| 7315 | src/#zak#read_xls.fugr.#zak#xls.abap | *--2011.12.12 BG<br>* Hiba tábla töltése |
| 7316 | src/#zak#read_xls.fugr.#zak#xls.abap | * Összeg mezőnél nem lehet karakteres érték! |
| 7317 | src/#zak#read_xls.fugr.#zak#xls.abap | *++0003 2008.12.11 BG (Fmc)<br>*   Ha be van állítva adóazonosító ellenőrzés |
| 7318 | src/#zak#read_xls.fugr.#zak#xls.abap | * teszteléshez |
| 7319 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | * automatikus ellenörzés a konvertálási rutin alapján periódus! |
| 7320 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | * főkönyvi szám ellenörzése |
| 7321 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | * kötelező mezők ellenörzése! |
| 7322 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | *  mező típus ellenörzése, tartalmi ellenörzés |
| 7323 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | * adószám ellenörzése a HR-böl |
| 7324 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | * csak érték lehet |
| 7325 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27 |
| 7326 | src/#zak#read_xml.fugr.#zak#lread_xmlf01.abap | *--S4HANA#01.<br>*  Csak dialógus futtatásnál |
| 7327 | src/#zak#read_xml.fugr.#zak#lread_xmltop.abap | * Hiba leíró tábla |
| 7328 | src/#zak#read_xml.fugr.#zak#lread_xmltop.abap | *XML beolvasáshiz |
| 7329 | src/#zak#read_xml.fugr.#zak#lread_xmltop.abap | *++1665 #04.<br>*MAKRO definiálás range feltöltéshez |
| 7330 | src/#zak#read_xml.fugr.#zak#saplread_xml.abap | nincs emberi komment blokk |
| 7331 | src/#zak#read_xml.fugr.#zak#xml.abap | * /zak/zak_analitikához |
| 7332 | src/#zak#read_xml.fugr.#zak#xml.abap | * XML fájl beolvasása |
| 7333 | src/#zak#read_xml.fugr.#zak#xml.abap | * Fájl megnyitás hiba |
| 7334 | src/#zak#read_xml.fugr.#zak#xml.abap | *   Hiba & fájl megnyitásánál!<br>* XML fájl hiba |
| 7335 | src/#zak#read_xml.fugr.#zak#xml.abap | *   Hibás az XML fájl (&)! |
| 7336 | src/#zak#read_xml.fugr.#zak#xml.abap | * Nincs adat |
| 7337 | src/#zak#read_xml.fugr.#zak#xml.abap | * Vállalat törzsadat |
| 7338 | src/#zak#read_xml.fugr.#zak#xml.abap | *--2308 #10.<br>* A nyomtatvány adatokban ellenőrizük az ABEV azonosítót! |
| 7339 | src/#zak#read_xml.fugr.#zak#xml.abap | * Adatok feldolgozása |
| 7340 | src/#zak#read_xml.fugr.#zak#xml.abap | *   Adóazonosító |
| 7341 | src/#zak#read_xml.fugr.#zak#xml.abap | *   az ABEV azonosítóban a lapszám is benne van, ezért<br>*   azt nem kell figyelembe venni.<br>*++BG 2006.10.11 BG<br>*Mivel a 06082A-nál a betű egy karakterrel odébb kerül ezért<br>*mindig az utolsó karaktert vesszük figyelembe: |
| 7342 | src/#zak#read_xml.fugr.#zak#xml.abap | *--BG 2006.10.11 BG<br>*   Dinamikus lapszám |
| 7343 | src/#zak#read_xml.fugr.#zak#xml.abap | *         Negatív érték kezelése |
| 7344 | src/#zak#read_xml.fugr.#zak#xml.abap | *            Összeg konvertálás hiba & ! |
| 7345 | src/#zak#read_xml.fugr.#zak#xml.abap | *         Ha ez előjel '-' volt. |
| 7346 | src/#zak#read_xml.fugr.#zak#xml.abap | *       Nem létezik az abev azonosító |
| 7347 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * /zak/zak_analitikához |
| 7348 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * Fejléc mezők: |
| 7349 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * ABEVAZ konvertálás |
| 7350 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * VPOP ABEV mezők |
| 7351 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * Önrevíziós ABEV |
| 7352 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * XML fájl beolvasása |
| 7353 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * Fájl megnyitás hiba |
| 7354 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *   Hiba & fájl megnyitásánál!<br>* XML fájl hiba |
| 7355 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *   Hibás az XML fájl (&)! |
| 7356 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * Nincs adat |
| 7357 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * Vállalat törzsadat |
| 7358 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * A nyomtatvány adatokban ellenőrizük az ABEV azonosítót! |
| 7359 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * M-es BTYPE összerakása |
| 7360 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | * Adatok feldolgozása |
| 7361 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *   Adószám |
| 7362 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *     M-es lapokat már nem kell feldolgozni |
| 7363 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *     ABEVAZ konvertálás |
| 7364 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *     Önrevízió figyelése |
| 7365 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *     A nyomtatvány adatokban ellenőrizük az ABEV azonosítót! |
| 7366 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *     Ha van rekord és kell |
| 7367 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *         Negatív érték kezelése |
| 7368 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *            Összeg konvertálás hiba & ! |
| 7369 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *         Ha ez előjel '-' volt. |
| 7370 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *         Negatív érték kezelése |
| 7371 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *            Összeg konvertálás hiba & ! |
| 7372 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *         Ha ez előjel '-' volt. |
| 7373 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *         Negatív érték kezelése |
| 7374 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *            Összeg konvertálás hiba & ! |
| 7375 | src/#zak#read_xml.fugr.#zak#xml_afa_upload.abap | *         Ha ez előjel '-' volt. |
| 7376 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * /zak/zak_analitikához |
| 7377 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Fejléc mezők: |
| 7378 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * ABEVAZ konvertálás |
| 7379 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Fejléc ABEV mezők kihagyása<br>* 01 |
| 7380 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * XML fájl beolvasása |
| 7381 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Fájl megnyitás hiba |
| 7382 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *   Hiba & fájl megnyitásánál!<br>* XML fájl hiba |
| 7383 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *   Hibás az XML fájl (&)! |
| 7384 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Nincs adat |
| 7385 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Vállalat törzsadat |
| 7386 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * A nyomtatvány adatokban ellenőrizük az ABEV azonosítót! |
| 7387 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Adatok feldolgozása |
| 7388 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *   Adószám |
| 7389 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *     ABEVAZ konvertálás |
| 7390 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *     A nyomtatvány adatokban ellenőrizük az ABEV azonosítót! |
| 7391 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *         Negatív érték kezelése |
| 7392 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *            Összeg konvertálás hiba & ! |
| 7393 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *         Ha ez előjel '-' volt. |
| 7394 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *     Nem létezik az abev azonosító |
| 7395 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *     Adóazonosító |
| 7396 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *     Önrevízió kezelése: |
| 7397 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *       01,02 lapon EA végű |
| 7398 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | *       01,02 lapon DA végű |
| 7399 | src/#zak#read_xml.fugr.#zak#xml_onyb_upload.abap | * Utolsó rekord mentése: |
| 7400 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *            Összeg konvertálás hiba & ! |
| 7401 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *         Ha ez előjel '-' volt. |
| 7402 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | * XML fájl beolvasása |
| 7403 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | * Fájl megnyitás hiba |
| 7404 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *   Hiba & fájl megnyitásánál!<br>* XML fájl hiba |
| 7405 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *   Hibás az XML fájl (&)! |
| 7406 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | * Nincs adat |
| 7407 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | * Vállalat törzsadat |
| 7408 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | * Adatok feldolgozása |
| 7409 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *--PTGSZLAH #01. 2015.01.16<br>*   Pénztárátvételi hely meghatározása |
| 7410 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *   Dátum: |
| 7411 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *       Itt van vége egy sornak<br>*       Összeg konverzió: |
| 7412 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *   Analitika általános adatok: |
| 7413 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *   Pénztárátvételi hely meghatározása |
| 7414 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | **   Dátum: |
| 7415 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *       Itt van vége egy sornak<br>*       Összeg konverzió: |
| 7416 | src/#zak#read_xml.fugr.#zak#xml_ptg_upload.abap | *   Analitika általános adatok: |
| 7417 | src/#zak#sap_sel_f01.prog.abap | * Meghatározzuk a BTYPE-okat |
| 7418 | src/#zak#sap_sel_f01.prog.abap | *   Ez a program a  & adatszolgáltatáshoz nem használható! |
| 7419 | src/#zak#sap_sel_f01.prog.abap | *   Speciális adatszolgáltatás azonosító itt nem használható! (&) |
| 7420 | src/#zak#sap_sel_f01.prog.abap | * Tétel azonosító meghatározás |
| 7421 | src/#zak#sap_sel_f01.prog.abap | * BTYPE meghatározása |
| 7422 | src/#zak#sap_sel_f01.prog.abap | * BEVALLB összesítő jelentések ABEV azonosítói:<br>*++S4HANA#01.<br>*  REFRESH $I_ONYB_ABEV. |
| 7423 | src/#zak#sap_sel_f01_old.prog.abap | * Meghatározzuk a BTYPE-okat |
| 7424 | src/#zak#sap_sel_f01_old.prog.abap | *   Ez a program a  & adatszolgáltatáshoz nem használható! |
| 7425 | src/#zak#sap_sel_f01_old.prog.abap | *   Speciális adatszolgáltatás azonosító itt nem használható! (&) |
| 7426 | src/#zak#sap_sel_f01_old.prog.abap | * Tétel azonosító meghatározás |
| 7427 | src/#zak#sap_sel_f01_old.prog.abap | * BTYPE meghatározása |
| 7428 | src/#zak#sap_sel_f01_old.prog.abap | * BEVALLB összesítő jelentések ABEV azonosítói: |
| 7429 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Flag, ob direkt ins Dynpro zurückgestellt werden soll. |
| 7430 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Dummy-Variablen für Forms aus dem F4-Prozessor: |
| 7431 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Abschneiden der Unterstriche, die DYNP_VALUES_READ für<br>* vom Dynp verdeckte Stellen am Ende anhängt. |
| 7432 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * OCXINTERFACE wird bei F4 auf Selektionspopup exportiert, damit<br>* das OCX sein Parent-Control kennt. Damit nachfolgende F4-Aufrufe<br>* nicht durcheinander kommen, wird das Memory sofort danach gelöscht. |
| 7433 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Wenn das gutgeht, muß das OCX gestartet werden, obwohl der Wert<br>* nicht zurückgestellt werden kann. |
| 7434 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | *   Falls das Feld eine Prüftabelle hat, kann der CREATE-Button<br>*   angeboten werden. |
| 7435 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * MSG DH805: Anzeige nicht möglich (Inkonsistenz der Eingabehilfe) |
| 7436 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Wenn keine Trefferliste angezeigt werden soll, werden als Default<br>* alle Felder der Trefferliste zurückgegeben. |
| 7437 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | *   Inhalt des F4-Feldes wird gleich mit übernommen |
| 7438 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Wenn weder ein DDIC-Feld noch ein Dynpro-Feld angegeben wurde, muß<br>* irgendwas eingetragen werden, damit das Rückgabefeld markiert wird. |
| 7439 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Bei Mehrfachauswahl ist z.Zt. kein automatisches Update des<br>* Dynp-Feldes möglich. Außerdem kann das ActiveX noch keine<br>* Merhfachauswahl, das wird aber im F4-Prozessor bereits abgefangen |
| 7440 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Bei F4 auf OCX ist auch kein direktes Rückstellen möglich |
| 7441 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Bei DISPLAY = 'F' wie FORCE, wird auch dann zurückgestellt,<br>* wenn das Feld auf dem Dynpro nicht eingabebereit ist. |
| 7442 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | ************** Callback falls gewünscht ******************************** |
| 7443 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | ************ Mapping auf Dynpro-Felder erst nach dem Callback *********<br>* Dadurch können im Callback zusätzliche Dynpro-Felder angegeben<br>* werden.<br>* Wenn allerdings gar keine Dynp-Info mitgegeben wurde, dann sollen<br>* die Modifikationen aus der Callback-Form nicht nochmal überschrieben<br>* werden. |
| 7444 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Erst jetzt, wird bei einer Prüftabellenhilfe entschieden, ob sie<br>* letztendlich über eine Suchhilfe, über einen Helpview oder über<br>* einen virtuellen Helpview (mit oder ohne Texttabelle) realisiert<br>* wird. |
| 7445 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Für's OCX exportieren wir auch noch die HELP_INFO<br>* Das amodale OCX kann nur gestartet werden, wenn das direkte<br>* Zurückstellen ins Dynpro funktioniert.<br>* Auserdem macht ein amodaler Aufruf keinen Sinn, wenn der Aufrufer<br>* hinterher die RETURN_TAB auswerten will.<br>* Das OCX läuft automatisch modal, wenn in HELP_INFOS keine Information<br>* zum Dynpro steckt. |
| 7446 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Rückkehr aus amodalem OCX soll nicht zur Meldung führen.<br>* Deshalb Abfrage auf DYNP_UPDATE |
| 7447 | src/#zak#sdhi.fugr.#zak#f4if_field_value_request.abap | * Falls automatische Rückgabe erfolgen soll, die SH-Parameter<br>* auf die Dynp-Felder mappen und ins Dynpro zurückschreiben.<br>* Das Ergebnis jetzt wieder auf die Dynp-Felder mappen |
| 7448 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * Vorbereitet für 3.0-Version |
| 7449 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * Brückenfunktionen zwischen den alten extern aufrufbaren<br>* F4-Bausteinen SHL2 und SHL3 und der neuen Hilfe. |
| 7450 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | *   Bei Suchhilfen müssen die Feldnamen eindeutig sein. |
| 7451 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * VALUE_TAB enthält die Inhalte pro Zelle zeilenweise.<br>* Aus Performance-Gründen wird aber spaltenweise in RECORD_TAB<br>* übertragen.<br>* Zunächst mal eine leere RECORD_TAB generieren. |
| 7452 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | *   Wenn das Datum bereits extern eingegeben wurde, muß das hier<br>*   berücksichtigt werden. (Die alten Bausteinen nahmen das nicht<br>*   so genau) |
| 7453 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * Leider stehen die Konvertierungsexits und das LOWERCASE-Flag<br>* nicht in der VALUESTRUC und<br>* müssen deshalb hier nachglesen werden. |
| 7454 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | *   Bei Suchhilfen müssen die Feldnamen eindeutig sein. |
| 7455 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * Aus Performance-Gründen wird spaltenweise in RECORD_TAB<br>* übertragen. |
| 7456 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | *   Wenn es die Zeile noch nicht gibt, einfügen. |
| 7457 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * Die RESULT_WA feldweise in die Tabelle SELECT_VALUES übertragen<br>* Das soll dann im externen Format passieren |
| 7458 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * DFIES-Eintrag für das Index-Feld zusammenbasteln. |
| 7459 | src/#zak#sdhi.fugr.#zak#lsdhif01.abap | * VALUE_TAB enthält die Inhalte pro Zelle zeilenweise.<br>* Aus Performance-Gründen wird aber spaltenweise in RECORD_TAB<br>* übertragen.<br>* Zunächst mal eine leere RECORD_TAB generieren. |
| 7460 | src/#zak#sdhi.fugr.#zak#lsdhif02.abap | *   Keine Eingabehilfe verfügbar |
| 7461 | src/#zak#sdhi.fugr.#zak#lsdhif02.abap | *   Keine Eingabehilfe verfügbar |
| 7462 | src/#zak#sdhi.fugr.#zak#lsdhif02.abap | *   Es gibt mehr als & Eingabemöglichkeiten |
| 7463 | src/#zak#sdhi.fugr.#zak#lsdhif03.abap | nincs emberi komment blokk |
| 7464 | src/#zak#sdhi.fugr.#zak#lsdhif04.abap | nincs emberi komment blokk |
| 7465 | src/#zak#sdhi.fugr.#zak#lsdhitop.abap | nincs emberi komment blokk |
| 7466 | src/#zak#sdhi.fugr.#zak#saplsdhi.abap | nincs emberi komment blokk |
| 7467 | src/#zak#set_period.fugr.#zak#lset_periodf01.abap | nincs emberi komment blokk |
| 7468 | src/#zak#set_period.fugr.#zak#lset_periodtop.abap | nincs emberi komment blokk |
| 7469 | src/#zak#set_period.fugr.#zak#saplset_period.abap | nincs emberi komment blokk |
| 7470 | src/#zak#set_period.fugr.#zak#set_datum.abap | * ...negyedéves |
| 7471 | src/#zak#set_period.fugr.#zak#set_datum.abap | * ...éves |
| 7472 | src/#zak#set_period.fugr.#zak#set_datum.abap | * ...havi vagy egyéb |
| 7473 | src/#zak#set_period.fugr.#zak#set_datum.abap | * Bevallás utolsó napjának meghatározás |
| 7474 | src/#zak#set_period.fugr.#zak#set_period.abap | * Bevallás utolsó napjának meghatározás |
| 7475 | src/#zak#set_period.fugr.#zak#set_period.abap | * időszak |
| 7476 | src/#zak#set_period.fugr.#zak#set_period.abap | * ...negyedéves |
| 7477 | src/#zak#set_period.fugr.#zak#set_period.abap | * ...éves |
| 7478 | src/#zak#set_status.prog.abap | *Figyelmeztetés |
| 7479 | src/#zak#set_status.prog.abap | * Jogosultság vizsgálat |
| 7480 | src/#zak#set_status.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7481 | src/#zak#set_status.prog.abap | *  Képernyő attribútomok beállítása |
| 7482 | src/#zak#set_status.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7483 | src/#zak#set_status.prog.abap | *   Adatmódosítások elmentve! |
| 7484 | src/#zak#szamlakelt_corr.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 7485 | src/#zak#szamlakelt_corr.prog.abap | *   Nincs a feltételnek megfelelő analitika rekord! |
| 7486 | src/#zak#szamlakelt_corr.prog.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7487 | src/#zak#szamlakelt_corr.prog.abap | *   Adatmódosítások elmentve! |
| 7488 | src/#zak#szja_book.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Analitika sorok könyvelése<br>*&---------------------------------------------------------------------* |
| 7489 | src/#zak#szja_book.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a /ZAK/ANALITIKA adatokat, és az előre megadott formátumba<br>*& Excel fájlban tárolja a könyveléshez.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.03.22<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   Cserhegyi T.  CL_GUI_FRONTEND_SERVICES<br>*&                                   cseréje hagyományosra<br>*& 0002   2006/10/26   Balázs G.     Több bevallás típus kezelése<br>*& 0003   2007/03/06   Forgó I.      Főkönyv "előjel helyes" könyvelés<br>*& 0004   2008/10/31   Balázs G.     Könyvelés fájl tagolás<br>*& 0005   2009/01/12   Balázs G.     Forgatás beépítés<br>*& 0006   2008/08/25   Balázs G.     PST elem kontírozás<br>*&---------------------------------------------------------------------* |
| 7490 | src/#zak#szja_book.prog.abap | *Beállítás adatok |
| 7491 | src/#zak#szja_book.prog.abap | *ABEV meghatározása |
| 7492 | src/#zak#szja_book.prog.abap | *A funkcioelem áltlal generált rekordokat tartalmazza |
| 7493 | src/#zak#szja_book.prog.abap | * ALV kezelési változók |
| 7494 | src/#zak#szja_book.prog.abap | * Vállalat. |
| 7495 | src/#zak#szja_book.prog.abap | * SELECTION-SCREEN END OF LINE.<br>* Bevallás fajta meghatározása |
| 7496 | src/#zak#szja_book.prog.abap | * Hónap |
| 7497 | src/#zak#szja_book.prog.abap | * Könyvelési dátum |
| 7498 | src/#zak#szja_book.prog.abap | * Teszt futás |
| 7499 | src/#zak#szja_book.prog.abap | *Könyvelési excel fájl |
| 7500 | src/#zak#szja_book.prog.abap | *  Megnevezések meghatározása |
| 7501 | src/#zak#szja_book.prog.abap | *  Könyvelési dátum |
| 7502 | src/#zak#szja_book.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 7503 | src/#zak#szja_book.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7504 | src/#zak#szja_book.prog.abap | *  Képernyő attribútomok beállítása |
| 7505 | src/#zak#szja_book.prog.abap | *  SZJA bevallás típus ellenőrzése |
| 7506 | src/#zak#szja_book.prog.abap | *   Kérem SZJA típusú bevallás azonosítót adjon meg!<br>*  Meghatározzuk a bevallás típust |
| 7507 | src/#zak#szja_book.prog.abap | *  Periódus ellenőrzése |
| 7508 | src/#zak#szja_book.prog.abap | *  Megnevezések meghatározása |
| 7509 | src/#zak#szja_book.prog.abap | *  Fájl ellenőrzés |
| 7510 | src/#zak#szja_book.prog.abap | *  Jogosultság vizsgálat |
| 7511 | src/#zak#szja_book.prog.abap | *  Vállalati adatok beolvasása |
| 7512 | src/#zak#szja_book.prog.abap | *   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 7513 | src/#zak#szja_book.prog.abap | *  Az adatok leválogatása |
| 7514 | src/#zak#szja_book.prog.abap | *    nincs a szelekciónak megfelelő adat. |
| 7515 | src/#zak#szja_book.prog.abap | *  az adatok feldolgozása |
| 7516 | src/#zak#szja_book.prog.abap | *    Súlyos hiba a FELDOLGOZÁS rutinban! |
| 7517 | src/#zak#szja_book.prog.abap | *++0005 2009.01.12 BG<br>* Könyvelés fájl forgatás (költséghely, rendelés, PC) |
| 7518 | src/#zak#szja_book.prog.abap | *    Ha sikeres volt az Excelbe töltés, aktualizálja az állományt |
| 7519 | src/#zak#szja_book.prog.abap | *      & fájl sikeresen letöltve<br>*++2009.04.02 BG |
| 7520 | src/#zak#szja_book.prog.abap | *     Hiba a & fájl letöltésénél.<br>*--2009.04.02 BG |
| 7521 | src/#zak#szja_book.prog.abap | * Vállalat megnevezése |
| 7522 | src/#zak#szja_book.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 7523 | src/#zak#szja_book.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7524 | src/#zak#szja_book.prog.abap | *      Hiba & fájl megnyitásánál! |
| 7525 | src/#zak#szja_book.prog.abap | * ++ 0001 CST 2006.05.27<br>*    Minta törlése |
| 7526 | src/#zak#szja_book.prog.abap | *    Hiba az SZJA beállítások meghatározásánál! |
| 7527 | src/#zak#szja_book.prog.abap | *    Hiba az ABEV - MEZŐ meghatározásánál! |
| 7528 | src/#zak#szja_book.prog.abap | *    Hiba az ABEV - MEZŐ meghatározásánál! |
| 7529 | src/#zak#szja_book.prog.abap | *    Ha így nincs olvassuk a '000' azonosítót |
| 7530 | src/#zak#szja_book.prog.abap | *--0908 2009.02.04 BG<br>*   Ha nem talál beállítást, akkor hiba |
| 7531 | src/#zak#szja_book.prog.abap | *    ha incs kitöltve a TART/KOV az is hiba |
| 7532 | src/#zak#szja_book.prog.abap | *           kiírja a rekordot<br>*    Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az<br>*++0004 2008.10.31 BG<br>*    Állomány darabolás |
| 7533 | src/#zak#szja_book.prog.abap | *  Üzenetek kezelése |
| 7534 | src/#zak#szja_book.prog.abap | * összerakja, milyen FLAG nem kell |
| 7535 | src/#zak#szja_book.prog.abap | *a szelekciós képernyő adatai alapján leválogatja a beállítás adatokat |
| 7536 | src/#zak#szja_book.prog.abap | *  Bizonylat dátum meghatározása<br>*++0005 2009.01.12 BG |
| 7537 | src/#zak#szja_book.prog.abap | *  Bizonylat fajta meghatározása |
| 7538 | src/#zak#szja_book.prog.abap | *    Ha az érték negatív, akkor cserélődik a KK |
| 7539 | src/#zak#szja_book.prog.abap | *  Hozzarendelés |
| 7540 | src/#zak#szja_book.prog.abap | *  Szöveg |
| 7541 | src/#zak#szja_book.prog.abap | *  Szöveg<br>*++ FI 20070312 |
| 7542 | src/#zak#szja_book.prog.abap | *    Ha "B" blokkos, akkor az kell a szövegbe |
| 7543 | src/#zak#szja_book.prog.abap | *  Szöveg |
| 7544 | src/#zak#szja_book.prog.abap | *-- FI 20070312<br>*  Az érték abszulut értékben kell |
| 7545 | src/#zak#szja_book.prog.abap | *  Bizonylat dátum meghatározása |
| 7546 | src/#zak#szja_book.prog.abap | *  Bizonylat fajta meghatározása |
| 7547 | src/#zak#szja_book.prog.abap | *  Vállalat |
| 7548 | src/#zak#szja_book.prog.abap | *  Könyvelési dátum |
| 7549 | src/#zak#szja_book.prog.abap | *    Ha az érték negatív, akkor cserélődik az 1 és 2 |
| 7550 | src/#zak#szja_book.prog.abap | *  Az érték abszulut értékben kell |
| 7551 | src/#zak#szja_book.prog.abap | *    Az előző évet érinti |
| 7552 | src/#zak#szja_book.prog.abap | *++ BG 2007.01.24 Szintaktikai ellenőrzés miatt.<br>*    TEXT_NOT_FOUND        = 2<br>*    OTHERS                = 3<br>*-- BG 2007.01.24 |
| 7553 | src/#zak#szja_book.prog.abap | * Mezőkatalógus összeállítása |
| 7554 | src/#zak#szja_book.prog.abap | * Kilépés |
| 7555 | src/#zak#szja_book.prog.abap | * Adatszerkezet beolvasása |
| 7556 | src/#zak#szja_book.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 7557 | src/#zak#szja_book.prog.abap | * Adatszerkezet beolvasása |
| 7558 | src/#zak#szja_book.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 7559 | src/#zak#szja_book.prog.abap | *  Analitika wisszaírása könyveltre |
| 7560 | src/#zak#szja_book.prog.abap | *    /ZAK/BEVALLSZ is visszaíródhat. |
| 7561 | src/#zak#szja_book.prog.screen_9001.abap | nincs emberi komment blokk |
| 7562 | src/#zak#szja_egyeztet.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SZJA adóbevallás adatok egyeztetése főkönyvi egyenleggel<br>*&---------------------------------------------------------------------* |
| 7563 | src/#zak#szja_egyeztet.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/ANALITIKA-ba<br>*& tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.01.18<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/11/10   Balázs G.     BTYPE kezelés módosítása, több<br>*&                                   is lehet<br>*& 0002   2006/11/29   Balázs G.     Több bevallás típus kezelése<br>*& 0003   2006/12/06   Balázs G.     HR biz.fajta elkülönítés<br>*& 0004   2007/02/22   Forgó I.      Korrekciós bevallások megjelenítése<br>*& 0005   2007/03/01   Forgó I.      Az előző ABEV kódok átforgatása<br>*                                    aktuális ABEV kódra<br>*& 0006   2007/03/26   Balázs G.     Önrevíziós időszak kezelések mód.<br>*& 0007   2007/07/24   Balázs G.     Optimalizálás nem olvassuk végig<br>*&        főkönyvenként az LI_ADOAZON azon rekordjait, amit nem találunk<br>*         az adott időszakba csak ez első főkönyvnél.<br>*& 0008   2007/11/09   Balázs G.     LOG tábla készítése, amiben<br>*&        tételesen levezethető az összeg, egy vállalathoz egy LOG<br>*&        készíthető.<br>*&---------------------------------------------------------------------* |
| 7564 | src/#zak#szja_egyeztet.prog.abap | * ALV kezelési változók |
| 7565 | src/#zak#szja_egyeztet.prog.abap | *++BG 2006/07/19<br>*MAKRO definiálás range feltöltéshez |
| 7566 | src/#zak#szja_egyeztet.prog.abap | *++0006 BG 2007.03.26<br>*++BG 2006/07/19<br>* Önrevízió kezeléséhez, önrevíziónál az ABEV<br>* kód szerinti azonosítból ki kell vonni az előző időszak<br>* ue.ABEV azonosító értékét. |
| 7567 | src/#zak#szja_egyeztet.prog.abap | *--BG 2006.12.28<br>*++0007 BG 2007.07.24<br>* Ide gyűjtjük azokat az adószámokat amiket nem találtunk |
| 7568 | src/#zak#szja_egyeztet.prog.abap | * Vállalat. |
| 7569 | src/#zak#szja_egyeztet.prog.abap | * Bevallás fajta meghatározása |
| 7570 | src/#zak#szja_egyeztet.prog.abap | * Hónap |
| 7571 | src/#zak#szja_egyeztet.prog.abap | *  Megnevezések meghatározása |
| 7572 | src/#zak#szja_egyeztet.prog.abap | *++0003 BG 2006/12/06<br>* HR bizonylat fajta feltöltés |
| 7573 | src/#zak#szja_egyeztet.prog.abap | *--0003 BG 2006/12/06<br>*++1765 #19.<br>* Jogosultság vizsgálat |
| 7574 | src/#zak#szja_egyeztet.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7575 | src/#zak#szja_egyeztet.prog.abap | * Képernyő attribútomok beállítása |
| 7576 | src/#zak#szja_egyeztet.prog.abap | * Csak 12. hóban van értelme. |
| 7577 | src/#zak#szja_egyeztet.prog.abap | *   Mentett adatok feldolgozásánál, nem készíthető LOG! |
| 7578 | src/#zak#szja_egyeztet.prog.abap | * Vállalat megnevezése |
| 7579 | src/#zak#szja_egyeztet.prog.abap | * kikeresi a következő hónap első és utolsó napját |
| 7580 | src/#zak#szja_egyeztet.prog.abap | * Összeszedi az időszakot követő feladott bevallásokat |
| 7581 | src/#zak#szja_egyeztet.prog.abap | *++0004 20070222 FI<br>*át kell rohanni a BEVALLI-n , és megnézni, hogy van-e a korrekciók<br>*között adat. |
| 7582 | src/#zak#szja_egyeztet.prog.abap | * Meg kell határozni a következő hó kezdő és záró dátumát |
| 7583 | src/#zak#szja_egyeztet.prog.abap | * Átugrunk a következő hónapra |
| 7584 | src/#zak#szja_egyeztet.prog.abap | * Az első nap meghatározása |
| 7585 | src/#zak#szja_egyeztet.prog.abap | * Az uotlsó nap meghatározása |
| 7586 | src/#zak#szja_egyeztet.prog.abap | * Összeszedi, hogy milyen abev azonosítók voltak a leválogatott<br>* időszakban |
| 7587 | src/#zak#szja_egyeztet.prog.abap | * Törli a duplikált tételeket |
| 7588 | src/#zak#szja_egyeztet.prog.abap | * Megkeresi, hogy milyen főkönyvek és abevazonosítók kellenek. |
| 7589 | src/#zak#szja_egyeztet.prog.abap | * öszerakja a főkönyveket. |
| 7590 | src/#zak#szja_egyeztet.prog.abap | * Ha változott a főkönyv, akkor le kell kérni az egyenleget |
| 7591 | src/#zak#szja_egyeztet.prog.abap | *   Ha nem változik a főkönyv, akkor az egyenleget törölni kell<br>*++0003 BG 2006/12/06<br>*     W_/ZAK/SZJA_ELL-FORGALOM = 0. |
| 7592 | src/#zak#szja_egyeztet.prog.abap | *++0006 BG 2007.04.23<br>*Egyeztető tábla összesítés (ha több azonos kulcs is előfordul, akkor<br>*összeadjuk) |
| 7593 | src/#zak#szja_egyeztet.prog.abap | *  Miután mindent leválogattunk, akkor összeszedjük a forgalmat |
| 7594 | src/#zak#szja_egyeztet.prog.abap | *  Ha önrevíziós időszak, akkor feltöltjük a -1 időszakot<br>*  mert ha 0-val volt feladva, akkor az ABEV kódon nem találjuk<br>*  meg: |
| 7595 | src/#zak#szja_egyeztet.prog.abap | *     Önrevíziós időszakok gyűjtése |
| 7596 | src/#zak#szja_egyeztet.prog.abap | *   Megnézi, hogy az adott RÉGI/ÚJ ABEV azonosító sor létezik-e már |
| 7597 | src/#zak#szja_egyeztet.prog.abap | *     Ha nincs még gyűjtő sor, akkor vegye át kezdő sort. |
| 7598 | src/#zak#szja_egyeztet.prog.abap | *   Megnézi, hogy a korrekciók között szerepel-e a bevallás sor. |
| 7599 | src/#zak#szja_egyeztet.prog.abap | *     Összeadja az önrevíziós sorokat |
| 7600 | src/#zak#szja_egyeztet.prog.abap | * Ha nem talált ABEV azonosítót, akkor is mentse a sort |
| 7601 | src/#zak#szja_egyeztet.prog.abap | *  Meg kell határozni a korrekcióhoz az eredeti indexet, és az |
| 7602 | src/#zak#szja_egyeztet.prog.abap | *++0007 BG 2007.07.24<br>*   Ha benne van a nem találtak között, akkor nem kell feldolgozni: |
| 7603 | src/#zak#szja_egyeztet.prog.abap | *++0006 BG 2007.03.26<br>*       Meg kell határozni, hogy a keresett időszakban van-e feladás<br>*       az adószámra, mert ha van, akkor figyelembe vesszük még ha 0 is. |
| 7604 | src/#zak#szja_egyeztet.prog.abap | *         Megnézi, hogy az adott RÉGI/ÚJ ABEV azonosító sor létezik-e |
| 7605 | src/#zak#szja_egyeztet.prog.abap | *--BG 2007.04.18<br>*   Megnézi, hogy a korrekciók között szerepel-e a bevallás sor. |
| 7606 | src/#zak#szja_egyeztet.prog.abap | *Ha talált korrekció bevallást , és a sorszáma is kisebb akkor a<br>*korrekciót is csökkenteni kell |
| 7607 | src/#zak#szja_egyeztet.prog.abap | *         Megnézi, hogy a korrekciók között szerepel-e a bevallás sor. |
| 7608 | src/#zak#szja_egyeztet.prog.abap | *Ha talált korrekció bevallást , és a sorszáma is kisebb akkor a<br>*korrekciót is csökkenteni kell |
| 7609 | src/#zak#szja_egyeztet.prog.abap | *         Végtelen ciklus miatt: |
| 7610 | src/#zak#szja_egyeztet.prog.abap | *++0007 BG 2007.07.24<br>*           Berakjuk a nem találtak közé: |
| 7611 | src/#zak#szja_egyeztet.prog.abap | * Mezőkatalógus összeállítása |
| 7612 | src/#zak#szja_egyeztet.prog.abap | * Kilépés |
| 7613 | src/#zak#szja_egyeztet.prog.abap | *++BG 2006/07/19<br>*  ABEV_FORG meghatározása |
| 7614 | src/#zak#szja_egyeztet.prog.abap | *  Megnézzük mi lenne a megfelelő ABEV |
| 7615 | src/#zak#szja_egyeztet.prog.abap | *++BG 2006/07/19<br>* Önrevízió kezeléséhez, önrevíziónál az ABEV<br>* kód szerinti azonosítból ki kell vonni az előző időszak<br>* ue.ABEV azonosító értékét. |
| 7616 | src/#zak#szja_egyeztet.prog.abap | *++BG 2006/07/19<br>*    $ABEV_FORG = $ABEV_FORG + W_/ZAK/BEVALLO-FIELD_N.<br>*--BG 2006/07/19<br>*++0004 20070222 FI<br>*   Megnézi, hogy a korrekciók között szerepel-e a bevallás sor. |
| 7617 | src/#zak#szja_egyeztet.prog.abap | *     Összeadja az önrevíziós sorokat |
| 7618 | src/#zak#szja_egyeztet.prog.abap | *++BG 2006/07/19<br>*     Önrevíziós időszakok gyűjtése |
| 7619 | src/#zak#szja_egyeztet.prog.abap | *Elrakja, hogy milyen bevallások voltak az utolsó előtt, mert ezeket<br>*     vissza kell venni az összes  bevallásból |
| 7620 | src/#zak#szja_egyeztet.prog.abap | *++BG 2006/07/19<br>* Önrevíziós időszakok kezelése ha volt adat |
| 7621 | src/#zak#szja_egyeztet.prog.abap | *++0004 20070222 FI<br>*  Meg kell határozni a korrekcióhoz az eredeti indexet, és az |
| 7622 | src/#zak#szja_egyeztet.prog.abap | *-- BG 2007.01.24<br>*++0004 20070222 FI<br>*          $ABEV_FORG001 = $ABEV_FORG001 - L_SUM_FIELD_N.<br>*--0004 20070222 FI<br>*++0004 20070222 FI<br>*   Megnézi, hogy a korrkciók között szerepel-e a bevallás sor. |
| 7623 | src/#zak#szja_egyeztet.prog.abap | *Ha talált korrekció bevallást , és a sorszáma is kisebb akkor a<br>*korrekciót is csökkenteni kell |
| 7624 | src/#zak#szja_egyeztet.prog.abap | *++0004 20070222 FI<br>*          $ABEV_FORG001 = $ABEV_FORG001 - L_SUM_FIELD_N.<br>*--0004 20070222 FI<br>*++0004 20070222 FI<br>*         Megnézi, hogy a korrkciók között szerepel-e a bevallás sor. |
| 7625 | src/#zak#szja_egyeztet.prog.abap | *Ha talált korrekció bevallást , és a sorszáma is kisebb akkor a<br>*korrekciót is csökkenteni kell |
| 7626 | src/#zak#szja_egyeztet.prog.abap | *  Vállalati adatok beolvasása |
| 7627 | src/#zak#szja_egyeztet.prog.abap | *   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 7628 | src/#zak#szja_egyeztet.prog.abap | * A következő időszakban feladott bevallások |
| 7629 | src/#zak#szja_egyeztet.prog.abap | *   Nincs a következő hónapnak megfelelő adat a /ZAK/BEVALLI táblában |
| 7630 | src/#zak#szja_egyeztet.prog.abap | * Bevallott tételek |
| 7631 | src/#zak#szja_egyeztet.prog.abap | *   Nincs a következő hónapnak megfelelő adat a /ZAK/BEVALLI táblában |
| 7632 | src/#zak#szja_egyeztet.prog.abap | * Milyen főkönyvek kellenek. |
| 7633 | src/#zak#szja_egyeztet.prog.abap | *   Nem áll rendelkezésre mentett adat & vállalat & év & hónapra! |
| 7634 | src/#zak#szja_egyeztet.prog.abap | *--0008 BG 2007.11.09<br>* Adatok törlése |
| 7635 | src/#zak#szja_egyeztet.prog.screen_9001.abap | nincs emberi komment blokk |
| 7636 | src/#zak#szja_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SAP adatok meghatározása SZJA adóbevalláshoz<br>*&---------------------------------------------------------------------* |
| 7637 | src/#zak#szja_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/ANALITIKA-ba<br>*& tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2006.01.18<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   Cserhegyi T.  CL_GUI_FRONTEND_SERVICES<br>*&                                   cseréje hagyományosra<br>*&        2007.01.03   Balázs G.     vissza csere<br>*& 0002   2006/10/26   Balázs G.     Több bevallás típus kezelése<br>*& 0003   2007/01/05   Balázs G.     Arányszámok kezelés javítása 12.hó<br>*& 0004   2007/03/06   Forgó I.      Könyvelés "előjel helyesen"<br>*& 0005   2007/05/08   Balázs G.     Korrekciós bizonylat fajta bevezet.<br>*& 0006   2007/10/08   Balázs G.     Vállalat forgatás<br>*& 0007   2008/01/21   Balázs G.     Vállalat forgatás átalakítása<br>*& 0008   2008/02/07   Balázs G.     SOR_SZETRAK átalakítása mert<br>*&                                   évváltásnál nem működik helyesen<br>*& 0009   2008/07/03   Balázs G.     SZJA_CUST beolvasásának szűrése<br>*&                                   szelekción megadott főkönyvek<br>*&                                   alapján<br>*& 0010   2008/09/12   Balázs G.     Adatszolgáltatás azonosítóra<br>*&                                   ellenőrzés visszaállítása<br>*& 0011   2008/10/17   Balázs G.     Üzleti ajándék projekt 2008<br>*&                                   -havi kezelés<br>*&                                   -könyvelési fájl tagolás<br>*&                                   -költséghely forgatás<br>*&                                   -progress indicator<br>*& 0012   2008/12/16   Balázs G.     Üzleti ajándék és repi eltávolítása<br>*&                                   teljes program lemásolva:<br>*&                                   /ZAK/SZJA_SAP_SEL_OLD néven<br>*& 0013   2009/04/08   Balázs G.     Iniciális értékek beállítása<br>*& 0014   2009/04/20   Balázs G.     WL könyvelésnél ÁFA kód<br>*&                                   /ZAK/SZJA_CUST tábla alapján<br>*& 0015   2009/05/22   Balázs G.     Kizárt bizonylatok kezelése<br>*& 0016   2009/08/25   Balázs G.     PST elem átvétele analitikába<br>*& 0017   2009/10/29   Balázs G.     XREF1 keresés átalakítás<br>*& 0018   2010/04/20   Balázs G.     SC bizonylatfajta kizárás<br>*&---------------------------------------------------------------------* |
| 7638 | src/#zak#szja_sap_sel.prog.abap | *Beállítás adatok |
| 7639 | src/#zak#szja_sap_sel.prog.abap | *ABEV meghatározása |
| 7640 | src/#zak#szja_sap_sel.prog.abap | *A funkcioelem áltlal generált rekordokat tartalmazza |
| 7641 | src/#zak#szja_sap_sel.prog.abap | * ALV kezelési változók |
| 7642 | src/#zak#szja_sap_sel.prog.abap | *Arányszámok bevallás típusonként kell |
| 7643 | src/#zak#szja_sap_sel.prog.abap | *++0005 BG 2007.05.08<br>*MAKRO definiálás range feltöltéshez |
| 7644 | src/#zak#szja_sap_sel.prog.abap | * Vállalat. |
| 7645 | src/#zak#szja_sap_sel.prog.abap | * SELECTION-SCREEN END OF LINE.<br>* Bevallás fajta meghatározása |
| 7646 | src/#zak#szja_sap_sel.prog.abap | * Hónap |
| 7647 | src/#zak#szja_sap_sel.prog.abap | * Adatszolgáltatás azonosító |
| 7648 | src/#zak#szja_sap_sel.prog.abap | *--0005 BG 2007.05.08<br>*++0015 2009.05.22 BG<br>* Kizárt bizonylatok |
| 7649 | src/#zak#szja_sap_sel.prog.abap | * Teszt futás |
| 7650 | src/#zak#szja_sap_sel.prog.abap | *Feltöltés módjának kiválasztása |
| 7651 | src/#zak#szja_sap_sel.prog.abap | *Könyvelési excel fájl |
| 7652 | src/#zak#szja_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 7653 | src/#zak#szja_sap_sel.prog.abap | *++0015 2009.05.22 BG<br>* Meghatározzuk ban e kizárt bizonylatszám |
| 7654 | src/#zak#szja_sap_sel.prog.abap | *  Képernyő attribútomok beállítása |
| 7655 | src/#zak#szja_sap_sel.prog.abap | *--0002 BG 2006/10/26<br>*  SZJA bevallás típus ellenőrzése |
| 7656 | src/#zak#szja_sap_sel.prog.abap | *   Kérem SZJA típusú bevallás azonosítót adjon meg!<br>*  Meghatározzuk a bevallás típust |
| 7657 | src/#zak#szja_sap_sel.prog.abap | *  Szolgáltatás azonosító ellenőrzése<br>*++0010 BG 2008/09/12 |
| 7658 | src/#zak#szja_sap_sel.prog.abap | *  Periódus ellenőrzése |
| 7659 | src/#zak#szja_sap_sel.prog.abap | *  Blokk ellenőrzése |
| 7660 | src/#zak#szja_sap_sel.prog.abap | * Éles futásnál kell fájl név |
| 7661 | src/#zak#szja_sap_sel.prog.abap | *   Kérem adja meg a könyvelési fájl nevét! |
| 7662 | src/#zak#szja_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 7663 | src/#zak#szja_sap_sel.prog.abap | *  Fájl ellenőrzés |
| 7664 | src/#zak#szja_sap_sel.prog.abap | * fájlnév ellenőrzése |
| 7665 | src/#zak#szja_sap_sel.prog.abap | *++0015 2009.05.22 BG<br>* Meghatározzuk ban e kizárt bizonylatszám |
| 7666 | src/#zak#szja_sap_sel.prog.abap | *  Jogosultság vizsgálat |
| 7667 | src/#zak#szja_sap_sel.prog.abap | *++0011 2008.10.17 BG<br>*  Adatok leválogatása |
| 7668 | src/#zak#szja_sap_sel.prog.abap | *  Vállalati adatok beolvasása |
| 7669 | src/#zak#szja_sap_sel.prog.abap | *   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 7670 | src/#zak#szja_sap_sel.prog.abap | *  Adatok leválogatása |
| 7671 | src/#zak#szja_sap_sel.prog.abap | *    nincs a szelekciónak megfelelő adat. |
| 7672 | src/#zak#szja_sap_sel.prog.abap | *++0002 BG 2006/10/26<br>*  Ha mindent szétválogattunk, akkor képezzük az új analitika rekordokat<br>*++0011 2008.10.17 BG<br>*  Analitika rekordok generálása |
| 7673 | src/#zak#szja_sap_sel.prog.abap | *  EXIT meghívása |
| 7674 | src/#zak#szja_sap_sel.prog.abap | *++0011 2008.10.17 BG<br>*  Könyvelés fájl forgatás (költséghely) |
| 7675 | src/#zak#szja_sap_sel.prog.abap | *  Teszt vagy éles futás, adatbázis módosítás, stb. |
| 7676 | src/#zak#szja_sap_sel.prog.abap | * Vállalat megnevezése |
| 7677 | src/#zak#szja_sap_sel.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 7678 | src/#zak#szja_sap_sel.prog.abap | *   Feltöltés azonosító figyelmen kívül hagyva! |
| 7679 | src/#zak#szja_sap_sel.prog.abap | *   Kérem adja meg a feltöltés azonosítót! |
| 7680 | src/#zak#szja_sap_sel.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7681 | src/#zak#szja_sap_sel.prog.abap | *      Hiba & fájl megnyitásánál! |
| 7682 | src/#zak#szja_sap_sel.prog.abap | *++0001 2007.01.03 BG (FMC)<br>* ++ 0001 CST 2006.05.27<br>*    Minta törlése |
| 7683 | src/#zak#szja_sap_sel.prog.abap | * 12. periódusra kötelező |
| 7684 | src/#zak#szja_sap_sel.prog.abap | *  Beállítások laválogatása<br>*++0002 BG 2006/10/26 |
| 7685 | src/#zak#szja_sap_sel.prog.abap | *    Hiba az SZJA beállítások meghatározásánál! |
| 7686 | src/#zak#szja_sap_sel.prog.abap | *  /ZAK/SZJA_ABEV leválogatása a WL könyveléshez<br>*++0002 BG 2006/10/26 |
| 7687 | src/#zak#szja_sap_sel.prog.abap | *    Hiba az ABEV - MEZŐ meghatározásánál! |
| 7688 | src/#zak#szja_sap_sel.prog.abap | *  Könyvelési rekordok leválogatása |
| 7689 | src/#zak#szja_sap_sel.prog.abap | *a szelekciós képernyő adatai alapján leválogatja a beállítás adatokat |
| 7690 | src/#zak#szja_sap_sel.prog.abap | *    Üres dátum mezők feltöltése |
| 7691 | src/#zak#szja_sap_sel.prog.abap | *  Ha 12. hót választott és akkor össze kell szedni az összes adatot<br>*  előjel helyesen az arányszám kiszámításához |
| 7692 | src/#zak#szja_sap_sel.prog.abap | *  kiszámítja az adóalap értékeket a i_BSEG táblában |
| 7693 | src/#zak#szja_sap_sel.prog.abap | *  Áttölti az adatokat a /ZAK/ANALITIKA táblába. |
| 7694 | src/#zak#szja_sap_sel.prog.abap | *    Leválogatom a lehetséges rekordokat. |
| 7695 | src/#zak#szja_sap_sel.prog.abap | *++0007 2008.01.21 BG (FMC)<br>*  A vállalat forgatás miatt fel kell tölteni<br>*  az XREF1 mezőt. |
| 7696 | src/#zak#szja_sap_sel.prog.abap | *++BG 2006/08/11<br>*A program leválogatott nem HUF-os tételeket is amit<br>*az analitikában rosszul kezelt mert a tételekből a<br>*DMBTR (saját pénznem) mezőből számolt a pénznemhez<br>*viszont a BKPF-WAERS (pld. EUR) értéket írta.<br>*Ezért a BKPF_WAERS-be mindig a vállalat T001-WAERS-et<br>*írjuk be! |
| 7697 | src/#zak#szja_sap_sel.prog.abap | *    elteszi az aktuális sor számát |
| 7698 | src/#zak#szja_sap_sel.prog.abap | *    rákeres a fej adatra |
| 7699 | src/#zak#szja_sap_sel.prog.abap | *    Ha nem talát a tételhez fej adatot, akkor a tétel sem kell, mert<br>*    nem jó a bizonylat fajta v. a könyvelési periódus.<br>*    Akkor sem kell a tétel, ha a hozzárendelés WL-el kezdődik<br>*    (ezeket a bizonylatokat mi könyveljük) |
| 7700 | src/#zak#szja_sap_sel.prog.abap | *    nincs a fej adatoknak megfelelő BSEG tétel |
| 7701 | src/#zak#szja_sap_sel.prog.abap | *  átmeneti táblák a leválogatáshoz. |
| 7702 | src/#zak#szja_sap_sel.prog.abap | *  a paraméter tábla alapján BSEG leválogatása |
| 7703 | src/#zak#szja_sap_sel.prog.abap | *++0011 2008.10.31 BG<br>*    Adatok leválogatása |
| 7704 | src/#zak#szja_sap_sel.prog.abap | *      nincs a feltételnek megfelelő adat, jöhet a következő |
| 7705 | src/#zak#szja_sap_sel.prog.abap | *    ellenőrzés WL (ezeket a bizonylatokat mi könyveljük) |
| 7706 | src/#zak#szja_sap_sel.prog.abap | **    leválogatja a BSEG rekordokat |
| 7707 | src/#zak#szja_sap_sel.prog.abap | *      nincs a feltételnek megfelelő adat, jöhet a következő |
| 7708 | src/#zak#szja_sap_sel.prog.abap | *    Fej BKPF adatok a BSEG ellenőrzéséhez.<br>*     REFRESH LI_BKPF. |
| 7709 | src/#zak#szja_sap_sel.prog.abap | *      nincs  FEJ adat, nem kell a tétel sem |
| 7710 | src/#zak#szja_sap_sel.prog.abap | *    nincs megfelelő BSEG tétel |
| 7711 | src/#zak#szja_sap_sel.prog.abap | *  Duplikált rekordok törlése |
| 7712 | src/#zak#szja_sap_sel.prog.abap | *++0006 2007.10.08  BG (FMC)<br>*  BSEG rekordok szűrése forgatott vállalatkódra |
| 7713 | src/#zak#szja_sap_sel.prog.abap | *  A szelekciós képernyő ábrázolása miatt |
| 7714 | src/#zak#szja_sap_sel.prog.abap | *    A rendelésből feltételt csinál a szelekcióhoz |
| 7715 | src/#zak#szja_sap_sel.prog.abap | *    Végig gyalogol a megfelelő BSEG tételeken |
| 7716 | src/#zak#szja_sap_sel.prog.abap | *      rákeres a fej adatra |
| 7717 | src/#zak#szja_sap_sel.prog.abap | *  Az adóalapot számítja a feltételeknek megfelelően |
| 7718 | src/#zak#szja_sap_sel.prog.abap | *  Miután megvan az adóalap, kiszámítjuk az arányszámot |
| 7719 | src/#zak#szja_sap_sel.prog.abap | *    Ha az összes adóalap nem éri el az adómentes részt,<br>*    az arány 0, mert nem kell számítani semmit.<br>*      $A_ARANY = 0. |
| 7720 | src/#zak#szja_sap_sel.prog.abap | *    Ha az összes adóalap nem éri el az adómentes részt,<br>*    az arány 0, mert nem kell számítani semmit.<br>*      $R_ARANY = 0. |
| 7721 | src/#zak#szja_sap_sel.prog.abap | *  Az I_BSEG tábla aktuális indexér tárolja |
| 7722 | src/#zak#szja_sap_sel.prog.abap | *  Beállításokon keresztül keressük az I_BSEG rekordokat |
| 7723 | src/#zak#szja_sap_sel.prog.abap | *    A rendelésből feltételt csinál a szelekcióhoz |
| 7724 | src/#zak#szja_sap_sel.prog.abap | *    Végig gyalogol a megfelelő BSEG tételeken |
| 7725 | src/#zak#szja_sap_sel.prog.abap | *    rákeres a fej adatra |
| 7726 | src/#zak#szja_sap_sel.prog.abap | *      Itt már nem lehet ilyen |
| 7727 | src/#zak#szja_sap_sel.prog.abap | *      WL biz.fajta esetén szorozni kell 1,2-vel |
| 7728 | src/#zak#szja_sap_sel.prog.abap | *      A beállító tábla alapján szorozni kell az adóalap %-al |
| 7729 | src/#zak#szja_sap_sel.prog.abap | *      Az arányszámmal is szorozni kell, attól függően, hogy milyen<br>*      tipus  A / P |
| 7730 | src/#zak#szja_sap_sel.prog.abap | *      visszaírja az új értéket a táblába. |
| 7731 | src/#zak#szja_sap_sel.prog.abap | *  Az I_BSEG tábla aktuális indexér tárolja |
| 7732 | src/#zak#szja_sap_sel.prog.abap | *  Beállításokon keresztül keressük az I_BSEG rekordokat |
| 7733 | src/#zak#szja_sap_sel.prog.abap | *    A rendelésből feltételt csinál a szelekcióhoz |
| 7734 | src/#zak#szja_sap_sel.prog.abap | *    Végig gyalogol a megfelelő BSEG tételeken |
| 7735 | src/#zak#szja_sap_sel.prog.abap | *      kikeresi, hogy az adott tételhez mikor kell analitoka |
| 7736 | src/#zak#szja_sap_sel.prog.abap | *  A % mezők meghatározása |
| 7737 | src/#zak#szja_sap_sel.prog.abap | *  Végigszalad a mezőkön és átveszi a beállításból a %-ot |
| 7738 | src/#zak#szja_sap_sel.prog.abap | *    átveszi a beállításból az adott % mező  (7 - 15. mező) |
| 7739 | src/#zak#szja_sap_sel.prog.abap | *    Csak akkor kell a ANALITIKA, ha a % ki van töltve |
| 7740 | src/#zak#szja_sap_sel.prog.abap | *  Minden lehetséges adatot kitölt |
| 7741 | src/#zak#szja_sap_sel.prog.abap | *  könyvelési periódus  és dátum beállítása |
| 7742 | src/#zak#szja_sap_sel.prog.abap | *    Ellenőrizzük az időszakhoz a bevallás típust |
| 7743 | src/#zak#szja_sap_sel.prog.abap | *Ha éves bevallás, akkor a következő év C_REPI_MONAT-ra kell beállítani |
| 7744 | src/#zak#szja_sap_sel.prog.abap | *    Ha Bizonylat típustól függ az időpont |
| 7745 | src/#zak#szja_sap_sel.prog.abap | *    Ellenőrizzük az időszakhoz a bevallás típust |
| 7746 | src/#zak#szja_sap_sel.prog.abap | *++0005 BG 2007.05.08<br>*  a bizonylatfjata meghatározás az ANALITIKA alapján kell |
| 7747 | src/#zak#szja_sap_sel.prog.abap | *  Bizonylat fajta meghatározása |
| 7748 | src/#zak#szja_sap_sel.prog.abap | *--0005 BG 2007.05.08<br>*++0005 2009.01.12 BG<br>*  Nem töltjük mert a BOOK-nál gondot okoz, ha<br>*  kizárt bizonylat fajta.<br>*  W_/ZAK/ANALITIKA-BLDAT = $W_BKPF-BLDAT.<br>*--0005 2009.01.12 BG |
| 7749 | src/#zak#szja_sap_sel.prog.abap | *++0016 BG 2009/08/25<br>*  PST elem átvétele |
| 7750 | src/#zak#szja_sap_sel.prog.abap | *  Az adóalapot számítja a feltételeknek megfelelően |
| 7751 | src/#zak#szja_sap_sel.prog.abap | *  végiglohol a beállítás sorokon<br>*  Azért ezen, mert eredetileg is ez alapján lettek leválogatva a<br>*  tételek és nem mindíg egyértelmű a BSEG-ből a /zak/szja_cust rekord<br>*  viss/zak/zakeresése. |
| 7752 | src/#zak#szja_sap_sel.prog.abap | *      Bevallás típus meghatározás hiba! |
| 7753 | src/#zak#szja_sap_sel.prog.abap | *++ 0004 FI<br>*Ki kell hagyni, ami nem a könyvelés időszakához tartozó bevallás<br>*beállítás |
| 7754 | src/#zak#szja_sap_sel.prog.abap | *    A rendelésből szelekciót csinál |
| 7755 | src/#zak#szja_sap_sel.prog.abap | *      rákeres a fej adatra |
| 7756 | src/#zak#szja_sap_sel.prog.abap | *      Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor |
| 7757 | src/#zak#szja_sap_sel.prog.abap | **          Az ÉVES-re jelöltek csak akkor kellenek, ha a hónap 12 vagy<br>*           nagyobb<br>**          egyébként nem kell őket átadni az analitokának<br>*           könyvelni egyébként kell<br>*           CONTINUE. |
| 7758 | src/#zak#szja_sap_sel.prog.abap | *++0002 BG 2006/10/26<br>*          KITÖLTI az analitika 1 sorát. |
| 7759 | src/#zak#szja_sap_sel.prog.abap | *      WL-es könyvelés |
| 7760 | src/#zak#szja_sap_sel.prog.abap | *          Ha az adott havi a bizonylat, csak akkor kell feladni<br>*          Itt jöhetnek olyan tételek is amik az éves leválogatás miatt<br>*          nem kellenek |
| 7761 | src/#zak#szja_sap_sel.prog.abap | *Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az |
| 7762 | src/#zak#szja_sap_sel.prog.abap | *           kiírja a rekordokat |
| 7763 | src/#zak#szja_sap_sel.prog.abap | *      Beállítás szerinti átkönyvelés |
| 7764 | src/#zak#szja_sap_sel.prog.abap | *Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az |
| 7765 | src/#zak#szja_sap_sel.prog.abap | *        kiírja a rekordot |
| 7766 | src/#zak#szja_sap_sel.prog.abap | *    A rendelésből feltételt csinál a szelekcióhoz |
| 7767 | src/#zak#szja_sap_sel.prog.abap | *   Nincs beállítva ÁFA kód WL mezőhöz /ZAK/SZJA_CUST-ban (&/&/&)! |
| 7768 | src/#zak#szja_sap_sel.prog.abap | *  előjel meghatározása |
| 7769 | src/#zak#szja_sap_sel.prog.abap | *  WL biz.fajta esetén szorozni kell 1,2-vel |
| 7770 | src/#zak#szja_sap_sel.prog.abap | *++0014 2010.01.08 BG<br>*    $FIELD_N = $FIELD_N * '1.2'.<br>*  ÁFA kód százalék meghatározása |
| 7771 | src/#zak#szja_sap_sel.prog.abap | *  A beállító tábla alapján szorozni kell az adóalap %-al |
| 7772 | src/#zak#szja_sap_sel.prog.abap | *  Az arányszámmal is szorozni kell, attól függően, hogy milyen<br>*  tipus  A / R |
| 7773 | src/#zak#szja_sap_sel.prog.abap | *Szét kell bontani bevallás típusonként |
| 7774 | src/#zak#szja_sap_sel.prog.abap | *    A kapott rekordokat visszamásolja az eredetibe. |
| 7775 | src/#zak#szja_sap_sel.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7776 | src/#zak#szja_sap_sel.prog.abap | *  Meg kell hívni a konverziót |
| 7777 | src/#zak#szja_sap_sel.prog.abap | *  Először mindig tesztben futtatjuk |
| 7778 | src/#zak#szja_sap_sel.prog.abap | *   Üzenetek kezelése |
| 7779 | src/#zak#szja_sap_sel.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van-e ERROR |
| 7780 | src/#zak#szja_sap_sel.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 7781 | src/#zak#szja_sap_sel.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról |
| 7782 | src/#zak#szja_sap_sel.prog.abap | *    Szövegek betöltése |
| 7783 | src/#zak#szja_sap_sel.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 7784 | src/#zak#szja_sap_sel.prog.abap | *    Mehet az adatbázis módosítása |
| 7785 | src/#zak#szja_sap_sel.prog.abap | *      Adatok módosítása |
| 7786 | src/#zak#szja_sap_sel.prog.abap | *    Visszavezetjük az indexet |
| 7787 | src/#zak#szja_sap_sel.prog.abap | *        Elmentjük a package azonosítót |
| 7788 | src/#zak#szja_sap_sel.prog.abap | *      Feltöltés & package számmal megtörtént! |
| 7789 | src/#zak#szja_sap_sel.prog.abap | * Mezőkatalógus összeállítása |
| 7790 | src/#zak#szja_sap_sel.prog.abap | * Kilépés<br>*++0005 BG 2007.05.08<br>*    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'. |
| 7791 | src/#zak#szja_sap_sel.prog.abap | *  sorszám meghatározása |
| 7792 | src/#zak#szja_sap_sel.prog.abap | *  Bizonylat fajta meghatározása |
| 7793 | src/#zak#szja_sap_sel.prog.abap | *++0014 2009.04.20 BG<br>*  ÁFA kód százalék meghatározása |
| 7794 | src/#zak#szja_sap_sel.prog.abap | *++0015 BG 2009/08/25<br>*    PST elem töltése |
| 7795 | src/#zak#szja_sap_sel.prog.abap | *    Ha az érték negatív, akkor cserélődik az 1 és 2 |
| 7796 | src/#zak#szja_sap_sel.prog.abap | *++0015 BG 2009/08/25<br>*    PST elem töltése |
| 7797 | src/#zak#szja_sap_sel.prog.abap | *  Az érték abszulut értékben kell |
| 7798 | src/#zak#szja_sap_sel.prog.abap | *  szelekciós periódus utolsó napjának meghatározása |
| 7799 | src/#zak#szja_sap_sel.prog.abap | *  Bizonylat fajta meghatározása |
| 7800 | src/#zak#szja_sap_sel.prog.abap | *    Ha az érték negatív, akkor cserélődik az 1 és 2 |
| 7801 | src/#zak#szja_sap_sel.prog.abap | *  Az érték abszulut értékben kell |
| 7802 | src/#zak#szja_sap_sel.prog.abap | *  szelekciós periódus utolsó napjának meghatározása |
| 7803 | src/#zak#szja_sap_sel.prog.abap | *  sorszám meghatározása |
| 7804 | src/#zak#szja_sap_sel.prog.abap | *++0014 2009.04.20 BG<br>*  ÁFA kód százalék meghatározása |
| 7805 | src/#zak#szja_sap_sel.prog.abap | *++0005 BG 2007.05.08<br>*  Bizonylatfajtához dátum meghatározás |
| 7806 | src/#zak#szja_sap_sel.prog.abap | *    WL esetén szorozni 1.2-vel |
| 7807 | src/#zak#szja_sap_sel.prog.abap | *    Ha az érték negatív, akkor cserélődik az 1 és 2 |
| 7808 | src/#zak#szja_sap_sel.prog.abap | *    WL esetén szorozni 1.2-vel |
| 7809 | src/#zak#szja_sap_sel.prog.abap | *  szelekciós periódus utolsó napjának meghatározása |
| 7810 | src/#zak#szja_sap_sel.prog.abap | *++0015 BG 2009/08/25<br>*    PST elem töltése |
| 7811 | src/#zak#szja_sap_sel.prog.abap | *  Bizonylat fajta meghatározása |
| 7812 | src/#zak#szja_sap_sel.prog.abap | *    WL esetén szorozni 1.2-vel |
| 7813 | src/#zak#szja_sap_sel.prog.abap | *    Ha az érték negatív, akkor cserélődik az 1 és 2 |
| 7814 | src/#zak#szja_sap_sel.prog.abap | *    WL esetén szorozni 1.2-vel |
| 7815 | src/#zak#szja_sap_sel.prog.abap | *  Az érték abszulut értékben kell |
| 7816 | src/#zak#szja_sap_sel.prog.abap | *  szelekciós periódus utolsó napjának meghatározása |
| 7817 | src/#zak#szja_sap_sel.prog.abap | * Adatszerkezet beolvasása |
| 7818 | src/#zak#szja_sap_sel.prog.abap | *++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 7819 | src/#zak#szja_sap_sel.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 7820 | src/#zak#szja_sap_sel.prog.abap | * Adatszerkezet beolvasása |
| 7821 | src/#zak#szja_sap_sel.prog.abap | *--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.28 |
| 7822 | src/#zak#szja_sap_sel.prog.abap | *    Az előző évet érinti |
| 7823 | src/#zak#szja_sap_sel.prog.abap | *  A rendelésből feltételt csinál a szelekcióhoz |
| 7824 | src/#zak#szja_sap_sel.prog.abap | *  IDŐSZAK meghatározása |
| 7825 | src/#zak#szja_sap_sel.prog.abap | *++0015 2009.08.07 BG<br>*  Ha nem marad rekord, akkor hiba |
| 7826 | src/#zak#szja_sap_sel.prog.abap | * Mezőkatalógus összeállítása |
| 7827 | src/#zak#szja_sap_sel.prog.abap | * Kilépés<br>*++0005 BG 2007.05.08<br>*    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'. |
| 7828 | src/#zak#szja_sap_sel.prog.abap | *  Egyenlőre nem kell a rekord |
| 7829 | src/#zak#szja_sap_sel.prog.abap | *  Dátum meghatározás |
| 7830 | src/#zak#szja_sap_sel.prog.abap | *  Meghatározzuk a BTYPE-ot. |
| 7831 | src/#zak#szja_sap_sel.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál!... |
| 7832 | src/#zak#szja_sap_sel.prog.abap | *++0017 BG 2009.10.29<br>*  Meghatározzuk az összes lehetséges értéket ami az XREF1-ben lehet |
| 7833 | src/#zak#szja_sap_sel.prog.abap | *        Hiba a & vállalat forgatás meghatározásnál! |
| 7834 | src/#zak#szja_sap_sel.prog.abap | *++0011 2008.10.17 BG<br>*    Adatok feldolgozása |
| 7835 | src/#zak#szja_sap_sel.prog.abap | *--1908 #10.<br>*    Rákeres a fej adatra |
| 7836 | src/#zak#szja_sap_sel.prog.abap | *    Bevallás fajta meghatározás |
| 7837 | src/#zak#szja_sap_sel.prog.abap | *      Meghatározzuk az időszakhoz létezik e bevallás típust |
| 7838 | src/#zak#szja_sap_sel.prog.abap | *      Meghatározzuk az időszakhoz létezik e bevallás típust |
| 7839 | src/#zak#szja_sap_sel.prog.abap | *    Megpróbáljuk rendelés nélkül |
| 7840 | src/#zak#szja_sap_sel.prog.abap | *      Bevallás típus meghatározás hiba! |
| 7841 | src/#zak#szja_sap_sel.prog.abap | *      Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor |
| 7842 | src/#zak#szja_sap_sel.prog.abap | **          Az ÉVES-re jelöltek csak akkor kellenek, ha a hónap 12 vagy<br>*           nagyobb<br>**          egyébként nem kell őket átadni az analitokának<br>*           könyvelni egyébként kell<br>*           CONTINUE. |
| 7843 | src/#zak#szja_sap_sel.prog.abap | *++0002 BG 2006/10/26<br>*          KITÖLTI az analitika 1 sorát. |
| 7844 | src/#zak#szja_sap_sel.prog.abap | *      WL-es könyvelés |
| 7845 | src/#zak#szja_sap_sel.prog.abap | *Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az<br>*++0011 2008.10.17 BG |
| 7846 | src/#zak#szja_sap_sel.prog.abap | *           kiírja a rekordokat |
| 7847 | src/#zak#szja_sap_sel.prog.abap | *    Beállítás szerinti átkönyvelés |
| 7848 | src/#zak#szja_sap_sel.prog.abap | *Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az<br>*++0011 2008.10.17 BG |
| 7849 | src/#zak#szja_sap_sel.prog.abap | *        kiírja a rekordot |
| 7850 | src/#zak#szja_sap_sel.prog.abap | *  Ha nics beállítva ÁFA kód, akkor hiba: |
| 7851 | src/#zak#szja_sap_sel.prog.abap | *Nincs beállítva ÁFA kód WL mezőhöz /ZAK/SZJA_ABEV-ben<br>* (Váll.: &, típ.: &) |
| 7852 | src/#zak#szja_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 7853 | src/#zak#szja_sap_sel.prog.screen_9001.abap | nincs emberi komment blokk |
| 7854 | src/#zak#szja_sap_sel_check.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/SZJA_SAP_SEL_CHECK<br>*&<br>*&---------------------------------------------------------------------*<br>*& Program: SAP adatok meghatározása SZJA adóbevalláshoz adatfeltöltés<br>*& után<br>*&---------------------------------------------------------------------* |
| 7855 | src/#zak#szja_sap_sel_check.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból azokat az  adatokat, amik az<br>*& adatfeltöltés után kerültek rögzítésre<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2007.10.24<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2008.01.21   Balázs G.     Módosított vállalat forgatás<br>*&                                   beállítása<br>*& 0002   2008.07.03   Balázs G.     Módosítás /ZAK/SZJA_SAP_SEL<br>*&                                   főkönyvi szűrés miatt<br>*&---------------------------------------------------------------------* |
| 7856 | src/#zak#szja_sap_sel_check.prog.abap | *ABEV meghatározása |
| 7857 | src/#zak#szja_sap_sel_check.prog.abap | * ALV kezelési változók |
| 7858 | src/#zak#szja_sap_sel_check.prog.abap | * Vállalat. |
| 7859 | src/#zak#szja_sap_sel_check.prog.abap | * Bevallás fajta meghatározása |
| 7860 | src/#zak#szja_sap_sel_check.prog.abap | * Hónap |
| 7861 | src/#zak#szja_sap_sel_check.prog.abap | * Adatszolgáltatás azonosító |
| 7862 | src/#zak#szja_sap_sel_check.prog.abap | *  Megnevezések meghatározása |
| 7863 | src/#zak#szja_sap_sel_check.prog.abap | *--0005 BG 2007.05.08<br>*++1765 #19.<br>* Jogosultság vizsgálat |
| 7864 | src/#zak#szja_sap_sel_check.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7865 | src/#zak#szja_sap_sel_check.prog.abap | *  Képernyő attribútomok beállítása |
| 7866 | src/#zak#szja_sap_sel_check.prog.abap | *  Megnevezések meghatározása |
| 7867 | src/#zak#szja_sap_sel_check.prog.abap | * Vállalat forgatás |
| 7868 | src/#zak#szja_sap_sel_check.prog.abap | *  Jogosultság vizsgálat |
| 7869 | src/#zak#szja_sap_sel_check.prog.abap | *  Vállalati adatok beolvasása |
| 7870 | src/#zak#szja_sap_sel_check.prog.abap | *   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 7871 | src/#zak#szja_sap_sel_check.prog.abap | * Adatok leválogatása |
| 7872 | src/#zak#szja_sap_sel_check.prog.abap | *    nincs a szelekciónak megfelelő adat. |
| 7873 | src/#zak#szja_sap_sel_check.prog.abap | * Adatok feldologzása |
| 7874 | src/#zak#szja_sap_sel_check.prog.abap | *    nincs a szelekciónak megfelelő adat. |
| 7875 | src/#zak#szja_sap_sel_check.prog.abap | *  Vállalat megnevezése |
| 7876 | src/#zak#szja_sap_sel_check.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál!... |
| 7877 | src/#zak#szja_sap_sel_check.prog.abap | *  Beállítások laválogatása |
| 7878 | src/#zak#szja_sap_sel_check.prog.abap | *    Hiba az SZJA beállítások meghatározásánál! |
| 7879 | src/#zak#szja_sap_sel_check.prog.abap | *  /ZAK/SZJA_ABEV leválogatása a WL könyveléshez<br>*++0002 BG 2006/10/26 |
| 7880 | src/#zak#szja_sap_sel_check.prog.abap | *    Hiba az ABEV - MEZŐ meghatározásánál! |
| 7881 | src/#zak#szja_sap_sel_check.prog.abap | *   /ZAK/BEVALL leválogatása |
| 7882 | src/#zak#szja_sap_sel_check.prog.abap | * Könyvelési rekordok leválogatása |
| 7883 | src/#zak#szja_sap_sel_check.prog.abap | * Meghatározzuk az utolsó letöltés időpontját. |
| 7884 | src/#zak#szja_sap_sel_check.prog.abap | *  végiglohol a beállítás sorokon<br>*  Azért ezen, mert eredetileg is ez alapján lettek leválogatva a<br>*  tételek és nem mindíg egyértelmű a BSEG-ből a /zak/szja_cust rekord<br>*  viss/zak/zakeresése. |
| 7885 | src/#zak#szja_sap_sel_check.prog.abap | *      Bevallás típus meghatározás hiba! |
| 7886 | src/#zak#szja_sap_sel_check.prog.abap | *Ki kell hagyni, ami nem a könyvelés időszakához tartozó bevallás<br>*beállítás |
| 7887 | src/#zak#szja_sap_sel_check.prog.abap | *    A rendelésből szelekciót csinál |
| 7888 | src/#zak#szja_sap_sel_check.prog.abap | *      rákeres a fej adatra |
| 7889 | src/#zak#szja_sap_sel_check.prog.abap | *     Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor |
| 7890 | src/#zak#szja_sap_sel_check.prog.abap | *       Ha a rögzítés dátuma későbbi a letöltésnél, akkor kell a rekord: |
| 7891 | src/#zak#szja_sap_sel_check.prog.abap | *  átmeneti táblák a leválogatáshoz. |
| 7892 | src/#zak#szja_sap_sel_check.prog.abap | *  a paraméter tábla alapján BSEG leválogatása |
| 7893 | src/#zak#szja_sap_sel_check.prog.abap | *      nincs a feltételnek megfelelő adat, jöhet a következő |
| 7894 | src/#zak#szja_sap_sel_check.prog.abap | *    ellenőrzés WL |
| 7895 | src/#zak#szja_sap_sel_check.prog.abap | **    leválogatja a BSEG rekordokat |
| 7896 | src/#zak#szja_sap_sel_check.prog.abap | *      nincs a feltételnek megfelelő adat, jöhet a következő |
| 7897 | src/#zak#szja_sap_sel_check.prog.abap | *    Fej BKPF adatok a BSEG ellenőrzéséhez.<br>*     REFRESH LI_BKPF. |
| 7898 | src/#zak#szja_sap_sel_check.prog.abap | *      nincs  FEJ adat, nem kell a tétel sem |
| 7899 | src/#zak#szja_sap_sel_check.prog.abap | *    nincs megfelelő BSEG tétel |
| 7900 | src/#zak#szja_sap_sel_check.prog.abap | *  Duplikált rekordok törlése |
| 7901 | src/#zak#szja_sap_sel_check.prog.abap | *++0006 2007.10.08  BG (FMC)<br>*  BSEG rekordok szűrése forgatott vállalatkódra |
| 7902 | src/#zak#szja_sap_sel_check.prog.abap | *  A rendelésből feltételt csinál a szelekcióhoz |
| 7903 | src/#zak#szja_sap_sel_check.prog.abap | *  IDŐSZAK meghatározása |
| 7904 | src/#zak#szja_sap_sel_check.prog.abap | * --Ez volt az eredeti<br>*  Az időszakból feltételt csinál a szelekcióhoz<br>*  Vagy nem 12 a periódus, vagy /ZAK/EVES <> ' '<br>*  Ha mindkét feltétel HAMIS, akkor nem kell figyelni a periódust |
| 7905 | src/#zak#szja_sap_sel_check.prog.abap | *++BG 2006/08/11<br>*A program leválogatott nem HUF-os tételeket is amit<br>*az analitikában rosszul kezelt mert a tételekből a<br>*DMBTR (saját pénznem) mezőből számolt a pénznemhez<br>*viszont a BKPF-WAERS (pld. EUR) értéket írta.<br>*Ezért a BKPF_WAERS-be mindig a vállalat T001-WAERS-et<br>*írjuk be! |
| 7906 | src/#zak#szja_sap_sel_check.prog.abap | *        Hiba a & vállalat forgatás meghatározásnál! |
| 7907 | src/#zak#szja_sap_sel_check.prog.abap | *    A rendelésből feltételt csinál a szelekcióhoz |
| 7908 | src/#zak#szja_sap_sel_check.prog.abap | * Mezőkatalógus összeállítása |
| 7909 | src/#zak#szja_sap_sel_check.prog.screen_9000.abap | nincs emberi komment blokk |
| 7910 | src/#zak#szja_stapalv.prog.abap | *&---------------------------------------------------------------------*<br>*& /ZAK/ANALITIKA lista Statisztikai flag figyelmbe vételével,<br>*& adószámonként csak az utolsó rekord jelenik meg.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - Ness<br>*& Létrehozás dátuma : 2010.04.09<br>*& Funkc.spec.készítő:<br>*& SAP modul neve    : /ZAK/ZAKO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 5.0<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*&<br>*&---------------------------------------------------------------------* |
| 7911 | src/#zak#szja_stapalv.prog.abap | *ALV közös rutinok |
| 7912 | src/#zak#szja_stapalv.prog.abap | *&---------------------------------------------------------------------*<br>* SELECTION-SCREEN<br>*&---------------------------------------------------------------------*<br>*Általános szelekciók: |
| 7913 | src/#zak#szja_stapalv.prog.abap | *Vállalat |
| 7914 | src/#zak#szja_stapalv.prog.abap | *Bevallás típus |
| 7915 | src/#zak#szja_stapalv.prog.abap | *Hónap |
| 7916 | src/#zak#szja_stapalv.prog.abap | *Bevallás sorszáma időszakon belül |
| 7917 | src/#zak#szja_stapalv.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 7918 | src/#zak#szja_stapalv.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7919 | src/#zak#szja_stapalv.prog.abap | *Felső érték kitöltése |
| 7920 | src/#zak#szja_stapalv.prog.abap | * Adatok leválogatása. |
| 7921 | src/#zak#szja_stapalv.prog.abap | * ALV lista összeállítás |
| 7922 | src/#zak#szja_stapalv.prog.abap | *ALV lista init |
| 7923 | src/#zak#szja_stapalv.prog.abap | *Lista fejléc átalakítása |
| 7924 | src/#zak#szja_stapalv.prog.abap | *Fieldkatalógus átalakítása |
| 7925 | src/#zak#szja_stapalv.prog.abap | * Variáns beállítása |
| 7926 | src/#zak#szja_stapalv.prog.abap | *ALV lista |
| 7927 | src/#zak#szja_stapalv.prog.abap | * Lista értékek inicializálása, feltöltése |
| 7928 | src/#zak#szja_stapalv.prog.abap | * ABAP/4 List Viewer hívása |
| 7929 | src/#zak#szja_stapalv.prog.abap |                                            "lehetséges |
| 7930 | src/#zak#szja_stapalv.prog.abap | * Cím |
| 7931 | src/#zak#szja_stat_hiba.prog.abap | *&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& Program: SAP analitika statisztika hiba vizsgálat<br>*&---------------------------------------------------------------------* |
| 7932 | src/#zak#szja_stat_hiba.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP a /ZAK/ANALITIKA táblából azokat a rekordokat<br>*& amelyek feltöltéskör nem kerültek statisztikai rekordként megjelölve.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2007.02.01<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0000   xxxx/xx/xx   xxxxxxxxxx    xxxxxxx xxxxxxx xxxxxxx xxxxxxxxxxx<br>*&                                   xxxxxxx xxxxxxx xxxxxxx<br>*&---------------------------------------------------------------------* |
| 7933 | src/#zak#szja_stat_hiba.prog.abap | *MAKRO definiálás range feltöltéshez |
| 7934 | src/#zak#szja_stat_hiba.prog.abap | * ALV kezelési változók |
| 7935 | src/#zak#szja_stat_hiba.prog.abap | *ABEVAZ kezdeti feltöltés |
| 7936 | src/#zak#szja_stat_hiba.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 7937 | src/#zak#szja_stat_hiba.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7938 | src/#zak#szja_stat_hiba.prog.abap | * Adatszolgáltatás azonosító amik teljes körűek |
| 7939 | src/#zak#szja_stat_hiba.prog.abap | * Analitika szelekció |
| 7940 | src/#zak#szja_stat_hiba.prog.abap | *  Háttérben nem készítünk listát. |
| 7941 | src/#zak#szja_stat_hiba.prog.abap | * Mezőkatalógus összeállítása |
| 7942 | src/#zak#szja_stat_hiba.prog.abap | * Kilépés |
| 7943 | src/#zak#szja_stat_hiba.prog.screen_9000.abap | nincs emberi komment blokk |
| 7944 | src/#zak#szja_xml_download.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: SZJA XML fájl letöltése<br>*&---------------------------------------------------------------------* |
| 7945 | src/#zak#szja_xml_download.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program az SZJA bevallás XML fájlt állítja elő a<br>*& /ZAK/BEVALLO tábla alapján<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - fmc<br>*& Létrehozás dátuma : 2006.05.26<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2006/05/27   CserhegyiT    CL_GUI_FRONTEND_SERVICES xxxxxxxxxx<br>*&                                   cseréje hagyományosra<br>*&---------------------------------------------------------------------* |
| 7946 | src/#zak#szja_xml_download.prog.abap | * Jogosultság vizsgálat |
| 7947 | src/#zak#szja_xml_download.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 7948 | src/#zak#szja_xml_download.prog.abap | *  Jogosultság vizsgálat |
| 7949 | src/#zak#szja_xml_download.prog.abap | * Bevallás típus meghatározása |
| 7950 | src/#zak#szja_xml_download.prog.abap | * Adatbázis szelekció |
| 7951 | src/#zak#szja_xml_download.prog.abap | * Esedékességi dátum kihagyása normál időszaknál |
| 7952 | src/#zak#szja_xml_download.prog.abap | * XML fájl létrehozás |
| 7953 | src/#zak#szja_xml_download.prog.abap | * Státusz állítás |
| 7954 | src/#zak#szja_xml_download.prog.abap | *      L_FULLPATH TYPE STRING,<br>*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*       L_FULLPATH LIKE RLGRAP-FILENAME, |
| 7955 | src/#zak#szja_xml_download.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7956 | src/#zak#szja_xml_download.prog.abap | * Értékek leolvasása dynpro-ról |
| 7957 | src/#zak#szja_xml_download.prog.abap | * Dynpróról az éretékek leolvasása |
| 7958 | src/#zak#szja_xml_download.prog.abap | * Értékek visszaírása a változókba |
| 7959 | src/#zak#szja_xml_download.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 7960 | src/#zak#szja_xml_download.prog.abap | *   Adatbázis nem tartalmaz feldolgozható rekordot! |
| 7961 | src/#zak#szja_xml_download.prog.abap | *      XML készítés |
| 7962 | src/#zak#szja_xml_download.prog.abap | *   Hiba a & fájl letöltésénél. |
| 7963 | src/#zak#szja_xml_download.prog.abap | *++BG 2006/07/19<br>* Meghatározzuk a jelenlegi státuszt, mibel lezárt vagy APEH<br>* által ellenőrzött időszakra már nem kell státusz állítás |
| 7964 | src/#zak#szja_xml_download.prog.abap | *Csak normál időszaknál |
| 7965 | src/#zak#szja_xml_download.prog.abap | *Meghatározzuk az esedékesség dátum abev azonosítót |
| 7966 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2006/08/31<br>* Kulcsmezők gyűjtése |
| 7967 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2011.09.14<br>* Csoport vállalatok |
| 7968 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2006/08/31<br>* Dialógus futásidő túllépés miatt PROCESS INDICATOR meghívása:<br>* !!! ÁTÍRNI: az $ANALITIKA táblából össze kell állítani egy<br>*  belső táblát, (BUKRS, BTYPE, GJAHR, MONAT, BSZNUM) és a<br>*  /ZAK/BEVALLI, /ZAK/BEVALLSZ, /ZAK/BEVALLD táblákat<br>*  FOR ALL ENTRIES utasítással a fenti tábla alapján kell<br>*  olvasni!!!! |
| 7969 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2011.09.14<br>*  Csoport vállalat ellenőrzés |
| 7970 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--PTGSZLAA #02. 2014.03.05<br>*    Hónap utolsó napja |
| 7971 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *    Csoport vállalatok |
| 7972 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2006/08/11<br>* Dialógus futás biztosításhoz |
| 7973 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Bevallás adatszolgáltatás indexek |
| 7974 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2006/08/09<br>* Dialógus futás biztosításhoz |
| 7975 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--BG 2006/08/11<br>* Bevallás adatszolgáltatás feltöltések |
| 7976 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--BG 2006/08/31<br>*++BG 2006/08/09<br>* Dialógus futás biztosításhoz |
| 7977 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Bevallás adatszolgáltatás adatai |
| 7978 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * a legnagyobb ZINDEX bejegyzéseket vizsgálom |
| 7979 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * manuális rögzítés! külön kezelem, mert még változhat! |
| 7980 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7981 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 7982 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Utolsó futás ideje - timestamp /ZAK/BEVALLSZ-LARUN |
| 7983 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Dialógus futás biztosításhoz |
| 7984 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * ha kialakul a végleges eljárás akkor,<br>*  /ZAK/READ_FILE_EXIT használni!<br>*++BG 2006/05/24 |
| 7985 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--BG 2006/05/24<br>* manuálisnál nincs packade generálás, tehát módosítjuk az itemet! |
| 7986 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++ BG 2006.03.23  ITEM léptetés |
| 7987 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * manuális ha nincs packade azonosító!<br>* manuális rögzítésnél ellenőrizni kell a kulcsot, mert<br>* az item számot a meglévő bejegyzéstől eltérően kell megadni! |
| 7988 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 7989 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++1365 #8.<br>*     Meghatározzuk az időszakot: |
| 7990 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--BG 2006/06/08<br>*++2009.11.09 BG<br>*     ONJF-Önellenőrzési jegyzőkönyv flag nem lehet töltve ha itt<br>*     módosítjuk a BEVALLI-t mert csak lezárt időszakra teszi majd<br>*     be az önellenőrzési jegyzőkönyv: |
| 7991 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2006/06/08<br>* Csak azokat a rekorodkat töröljük amik a régi package azonosítóhoz<br>* tartoznak<br>*--BG 2006/06/08 |
| 7992 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * csak nyitott periódusnál van manuális bevitel! |
| 7993 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevallsz |
| 7994 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * a következő nyitott periódusra kell könyvelni! |
| 7995 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * index + 1 önrevízió<br>*++1765 #25.<br>*              L_INDEX =  W_/ZAK/BEVALLSZ-ZINDEX + 1. |
| 7996 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * a következő nyitott periódusra kell könyvelni! |
| 7997 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * index + 1 önrevízió |
| 7998 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevalli |
| 7999 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevallsz |
| 8000 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * duplikáció! |
| 8001 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2011.09.14<br>* Csoport vállalat bővítések |
| 8002 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * önrevízió! 001 |
| 8003 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *         index + 1 önrevízió |
| 8004 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--BG 2006/06/12<br>*++2308 #06.<br>*       Ilyen pld. "E" elengedett adatszolgáltatás, ha már van is beállítva akkor is<br>*       át kell venni az index-et mert különben a 000-ra kerül ami hibát okoz! |
| 8005 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++2508 #04.<br>*         Ráolvasunk az adatbázisban is mert lehet, hogy a megtalált rekord generált,<br>*         de csak időszakonként 1x. |
| 8006 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevallsz |
| 8007 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--1565 #12.<br>* új bejegyzés bevalli |
| 8008 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevallsz |
| 8009 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * ismételt betöltés! |
| 8010 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--2012.04.03 Balázs Gábor (Ness) |
| 8011 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevallsz |
| 8012 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--1565 #12.<br>* új bejegyzés bevalli |
| 8013 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * új bejegyzés bevallsz |
| 8014 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * ismételt vége |
| 8015 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * duplikáció! |
| 8016 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++BG 2011.09.14<br>* Csoport vállalat bővítések |
| 8017 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Utolsó Tételszám |
| 8018 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Bevallás típus időszakonként |
| 8019 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Beolvassuk, hogy milyen BTYPE tartozik hozzá |
| 8020 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *   Nincs meg, meghatározzuk |
| 8021 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *   BTYPE visszaírása |
| 8022 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *  Csak dialógus futtatásnál |
| 8023 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *Ha a FLAG 'X', akkor a következő időszak kell. |
| 8024 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *  Meghatározzuk a következő nyitott periódust. |
| 8025 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Konvertálni kell a BTYPE-ot |
| 8026 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *       Hiba a & bevallás típus fajtájának meghatározásánál! |
| 8027 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Meghatározzuk a bevallás típust. |
| 8028 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *       Meghatározzuk a FLAG-et |
| 8029 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *       Következő időszak is APEH által ellenőrzött megyünk tovább<br>*       ELSEIF LW_BEVALLI-FLAG CA 'X'. |
| 8030 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *       Meghatározzuk a következő nyitott periódust. |
| 8031 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Konvertálni kell a BTYPE-ot |
| 8032 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *       Hiba a & bevallás típus fajtájának meghatározásánál! |
| 8033 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Meghatározzuk a bevallás típust. |
| 8034 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++2009.09.18 BG (NESS)<br>*           BTYPE váltás, indulunk előről |
| 8035 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Következő időszak lezárt |
| 8036 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Következő időszak nyitott erre tesszük |
| 8037 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--2008.11.21 BG (Fmc)<br>*     Ha megvan kilépünk |
| 8038 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * vezető 0-ák feltöltése |
| 8039 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *++2009.09.18 BG (NESS)<br>*   Ha volt BTYPE váltás, konvertálni kell az ABEVAZ-t. |
| 8040 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     ABEV forgatás |
| 8041 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *     Utolsó sor meghatározása |
| 8042 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *  Értékek visszaírása |
| 8043 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *Végigolvassuk a rekordokat |
| 8044 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--PTGSZLAA #02. 2014.03.05<br>*   IDŐSZAK utolsó napjának meghatározása |
| 8045 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *   BEVALL meghatározása |
| 8046 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *   Ha negyedéves vagy éves |
| 8047 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | * Csoport vállalatok |
| 8048 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--PTGSZLAA #02. 2014.03.05<br>*    Hónap utolsó napja |
| 8049 | src/#zak#tabl_upd.fugr.#zak#ltabl_updf01.abap | *--PTGSZLAA #02. 2014.03.05<br>*    Csoport vállalatok |
| 8050 | src/#zak#tabl_upd.fugr.#zak#ltabl_updtop.abap | * adatbázis tábla update |
| 8051 | src/#zak#tabl_upd.fugr.#zak#ltabl_updtop.abap | * Szja bevall. Önrev.-ra feltöltésnél előző indexű, azonos<br>* adaszolgáltatás és adószámhoz tartozó tételeket statisztikai tételként<br>* kell megjelölni. |
| 8052 | src/#zak#tabl_upd.fugr.#zak#ltabl_updtop.abap | *++1365 #14.<br>*Konverzió |
| 8053 | src/#zak#tabl_upd.fugr.#zak#sapltabl_upd.abap | nincs emberi komment blokk |
| 8054 | src/#zak#tabl_upd.fugr.#zak#update.abap | * ++BG<br>* BTYPART megadva, konvertálunk |
| 8055 | src/#zak#tabl_upd.fugr.#zak#update.abap | *   Úgy kezelem mintha ő generálná a package-t |
| 8056 | src/#zak#tabl_upd.fugr.#zak#update.abap | *--1465 #10.<br>*   normál bevallás |
| 8057 | src/#zak#tabl_upd.fugr.#zak#update.abap | *--1465 #10.<br>*++BG 2008.11.17<br>* BEVALLI rendezés: negyedéves és éves adatoknál, ha<br>* nem volt az analitikába valamelyik időszakra adat akkor nem<br>* jött létre a BEVALLI rekord. Viszont mivel a BEVALLO<br>* mindig időszak utolsó hónapjára íródik, ezért bizonyos<br>* esetekben gondot okoz, hogy nincs hozzá BEVALLI. Ezért<br>* ez a rutin ellenőrzi, hogy megfelelő e a BEVALLI konzisztencia |
| 8058 | src/#zak#tabl_upd.fugr.#zak#update.abap | * Error hiba , nincs adatbázis tábla update! |
| 8059 | src/#zak#tabl_upd.fugr.#zak#update.abap | * packade azonosító generálása |
| 8060 | src/#zak#tabl_upd.fugr.#zak#update.abap | *--1465 #10.<br>* package számkör |
| 8061 | src/#zak#tabl_upd.fugr.#zak#update.abap | *         Feltöltés azonosító számkör hiba! |
| 8062 | src/#zak#tabl_upd.fugr.#zak#update.abap | *--1465 #10.<br>* Ismételt feltöltés! |
| 8063 | src/#zak#tabl_upd.fugr.#zak#update.abap | *   Nincsen megadott Feltöltés azonosító! |
| 8064 | src/#zak#tabl_upd.fugr.#zak#update.abap | * sikertelen a /ZAK/BEVALLP tábla írása! |
| 8065 | src/#zak#tabl_upd.fugr.#zak#update.abap | * Szja bevall. Önrev.-ra feltöltésnél előző indexű, azonos<br>* adaszolgáltatás és adószámhoz tartozó tételeket statisztikai tételként<br>* kell megjelölni. |
| 8066 | src/#zak#tabl_upd.fugr.#zak#update.abap | *++1365 2013.01.22 Balázs Gábor (Ness) |
| 8067 | src/#zak#tabl_upd.fugr.#zak#update.abap | *--1365 2013.01.22 Balázs Gábor (Ness) |
| 8068 | src/#zak#table_upload.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 8069 | src/#zak#table_upload.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 8070 | src/#zak#table_upload.prog.abap | * Adatok feltöltése |
| 8071 | src/#zak#table_upload.prog.abap | *   Tábla módosítások elvégezve! |
| 8072 | src/#zak#tech.prog.abap | *&---------------------------------------------------------------------*<br>*& Program: Bevallással kapcsolatos technikai adatok beállítása,<br>*&          státuszok kezelése<br>*&---------------------------------------------------------------------* |
| 8073 | src/#zak#tech.prog.abap | *&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és a /ZAK/ANALITIKA-ba<br>*& tárolja.<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Dénes Károly - FMC<br>*& Létrehozás dátuma : 2006.01.26<br>*& Funkc.spec.készítő: ________<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 46C<br>*&---------------------------------------------------------------------*<br>*&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ             LEÍRÁS           TRANSZPORT<br>*& ----   ----------   ----------    ----------------------- -----------<br>*& 0001   2008/04/07   Balázs G.     ONYB szelekció törölhető<br>*& 0002   2011.09.14   Balázs G.     Csoport vállalat kezelése<br>*&---------------------------------------------------------------------* |
| 8074 | src/#zak#tech.prog.abap | * file típusok |
| 8075 | src/#zak#tech.prog.abap | * excel betöltéshez |
| 8076 | src/#zak#tech.prog.abap | * file ellenörzése |
| 8077 | src/#zak#tech.prog.abap | *&---------------------------------------------------------------------*<br>*& Munkaterület  (W_XXX..)                                           *<br>*&---------------------------------------------------------------------*<br>* struktúra ellenőrzése |
| 8078 | src/#zak#tech.prog.abap | * excel betöltéshez |
| 8079 | src/#zak#tech.prog.abap | * adatszerkezet hiba |
| 8080 | src/#zak#tech.prog.abap | * bevallási időszakok |
| 8081 | src/#zak#tech.prog.abap | * Hiba adaszerkezet tábla |
| 8082 | src/#zak#tech.prog.abap | *&---------------------------------------------------------------------*<br>*& PROGRAM VÁLTOZÓK                                                    *<br>*      Sorozatok (Range)   -   (R_xxx...)                              *<br>*      Globális változók   -   (V_xxx...)                              *<br>*      Munkaterület        -   (W_xxx...)                              *<br>*      Típus               -   (T_xxx...)                              *<br>*      Makrók              -   (M_xxx...)                              *<br>*      Field-symbol        -   (FS_xxx...)                             *<br>*      Methodus            -   (METH_xxx...)                           *<br>*      Objektum            -   (O_xxx...)                              *<br>*      Osztály             -   (CL_xxx...)                             *<br>*      Esemény             -   (E_xxx...)                              *<br>*&---------------------------------------------------------------------* |
| 8083 | src/#zak#tech.prog.abap | * változók |
| 8084 | src/#zak#tech.prog.abap | * szelekciós képernyő |
| 8085 | src/#zak#tech.prog.abap | * excel betöltéshez |
| 8086 | src/#zak#tech.prog.abap | * képernyőre |
| 8087 | src/#zak#tech.prog.abap | * ALV kezelési változók |
| 8088 | src/#zak#tech.prog.abap | * popup üzenethez |
| 8089 | src/#zak#tech.prog.abap | * file ellenörzése |
| 8090 | src/#zak#tech.prog.abap | * dynpro mezők |
| 8091 | src/#zak#tech.prog.abap | * vállalat, bev.tip megnevezés |
| 8092 | src/#zak#tech.prog.abap | * dátum a másolás képernyőn |
| 8093 | src/#zak#tech.prog.abap | * elengedett kötelezettség |
| 8094 | src/#zak#tech.prog.abap | * Analitika megjelenítése |
| 8095 | src/#zak#tech.prog.abap | * megnevezések |
| 8096 | src/#zak#tech.prog.abap | *++1765 #19.<br>* Jogosultság vizsgálat |
| 8097 | src/#zak#tech.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 8098 | src/#zak#tech.prog.abap | * megnevezések |
| 8099 | src/#zak#tech.prog.abap | * Választó kapcsoló ellenörzése ! |
| 8100 | src/#zak#tech.prog.abap | * bevallás fajta, bevallás típus kötelező |
| 8101 | src/#zak#tech.prog.abap | * Jogosultság vizsgálat |
| 8102 | src/#zak#tech.prog.abap | * Bevallás általános adatai |
| 8103 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás beállítás |
| 8104 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás adatai |
| 8105 | src/#zak#tech.prog.abap | * Bevallás nyomtatvány adatok |
| 8106 | src/#zak#tech.prog.abap | * adónemek tábla |
| 8107 | src/#zak#tech.prog.abap | *++0002 BG 2011.09.20<br>*  Csoportos vállalat meghatározás |
| 8108 | src/#zak#tech.prog.abap | * elengedett kötelezettség |
| 8109 | src/#zak#tech.prog.abap | * bevallás adatok másolása |
| 8110 | src/#zak#tech.prog.abap | *   Ez a funkció csak csoport vállalatra (&) megengedett! |
| 8111 | src/#zak#tech.prog.abap | * Nyomtatvány lezárás |
| 8112 | src/#zak#tech.prog.abap | * másolás |
| 8113 | src/#zak#tech.prog.abap | * nyomtatvány lezárás |
| 8114 | src/#zak#tech.prog.abap | * nyomtatvány lezárás |
| 8115 | src/#zak#tech.prog.abap | * nyomtatvány lezárás |
| 8116 | src/#zak#tech.prog.abap | * feltöltés azonosító törlése |
| 8117 | src/#zak#tech.prog.abap | * nyomtatvány törlése |
| 8118 | src/#zak#tech.prog.abap | ********************************************************- forrás |
| 8119 | src/#zak#tech.prog.abap | ******************************************************** cél<br>* Vállalat megnevezés |
| 8120 | src/#zak#tech.prog.abap | * Bevallás típus megnevezés |
| 8121 | src/#zak#tech.prog.abap | * bevallás típus érvényes időszaka! |
| 8122 | src/#zak#tech.prog.abap | * másolásnál a cél adatok ellenörzése! |
| 8123 | src/#zak#tech.prog.abap | * bevall táblák tartalmi ellenörzése! |
| 8124 | src/#zak#tech.prog.abap | *        Hiba & tábla másolásnál! Másolás megs/zak/zakítva! |
| 8125 | src/#zak#tech.prog.abap | * APEH által ellenörzött PBO |
| 8126 | src/#zak#tech.prog.abap | * Bevallás általános adatai |
| 8127 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás adatai |
| 8128 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás beállítás |
| 8129 | src/#zak#tech.prog.abap | *++ BG 2006.03.28<br>*  SZJA CUST másolása |
| 8130 | src/#zak#tech.prog.abap | *++ BG 2006.04.20<br>*  /ZAK/SZJA_ABEV másolása |
| 8131 | src/#zak#tech.prog.abap | *  Nyomtatvány default értékek |
| 8132 | src/#zak#tech.prog.abap | *  Áfa beállítások |
| 8133 | src/#zak#tech.prog.abap | *  ÁFA ABEV azonosító átvezetések (előleg) beállítása |
| 8134 | src/#zak#tech.prog.abap | * normál bevallás |
| 8135 | src/#zak#tech.prog.abap | *normál már le va zárva. |
| 8136 | src/#zak#tech.prog.abap | * APEH filekészítés már futott, de vannak új feltöltött<br>* bejegyzések |
| 8137 | src/#zak#tech.prog.abap | *Az APEH állománykészítő programot kérem, futtassa. |
| 8138 | src/#zak#tech.prog.abap | * önrevizós bevallás |
| 8139 | src/#zak#tech.prog.abap | * APEH filekészítés már futott, de vannak új feltöltött<br>* bejegyzések |
| 8140 | src/#zak#tech.prog.abap | *Az APEH állománykészítő programot kérem, futtassa. |
| 8141 | src/#zak#tech.prog.abap | * Van már bevallás? |
| 8142 | src/#zak#tech.prog.abap | * nyomtatvány lezárás |
| 8143 | src/#zak#tech.prog.abap | * apeh ellenörzött |
| 8144 | src/#zak#tech.prog.abap | * apeh file készítés futott? |
| 8145 | src/#zak#tech.prog.abap | * másolás |
| 8146 | src/#zak#tech.prog.abap | * elengedett kötelezettség |
| 8147 | src/#zak#tech.prog.abap | * nyomtatvány törlés |
| 8148 | src/#zak#tech.prog.abap | *              FLAG EQ 'X'.<br>* nyomtatvány elkészült? |
| 8149 | src/#zak#tech.prog.abap | * bevallás típus ellenörzése |
| 8150 | src/#zak#tech.prog.abap | * bevallás fajta vagy bevallás típus kitöltése kötelező! |
| 8151 | src/#zak#tech.prog.abap | * technikai funkciók előfeltétele! |
| 8152 | src/#zak#tech.prog.abap | * csak bevallás típus kitöltése esetén használható a funkció! |
| 8153 | src/#zak#tech.prog.abap | * vállalat, bevallás fajta, bevallás típus összerendelés |
| 8154 | src/#zak#tech.prog.abap | * esedékesség dátum meghatározás |
| 8155 | src/#zak#tech.prog.abap | * zárolt? |
| 8156 | src/#zak#tech.prog.abap | *++0002 BG 2011.09.27<br>*  Csoport vállalatnál ellenőrizzük minden normál vállalat státuszát |
| 8157 | src/#zak#tech.prog.abap | *      Nincs adat létrehozzuk |
| 8158 | src/#zak#tech.prog.abap | * /zak/bevall<br>* Bevallás utolsó napjának meghatározás |
| 8159 | src/#zak#tech.prog.abap | *--BG 2006/03/30<br>* más adatszolgáltatás ellenörzése (önrevíziónál nem kell) |
| 8160 | src/#zak#tech.prog.abap | *--0002 2011.11.30 BG (Ness)<br>* minden adatszolgáltatás, összes időszakra |
| 8161 | src/#zak#tech.prog.abap | * CST: Átvezetés kezelése |
| 8162 | src/#zak#tech.prog.abap | * Excel könyvelés feladás |
| 8163 | src/#zak#tech.prog.abap | * Csak akkor kell könyvelni, ha a fájl jól letöltődött<br>*++FI20070222 |
| 8164 | src/#zak#tech.prog.abap | * Adófolyószámla könyvelése |
| 8165 | src/#zak#tech.prog.abap | *      Önellenőrzési pótlék könyvelés beállítás hiba! Fájl nem készült! |
| 8166 | src/#zak#tech.prog.abap | *      Önellenőrzési pótlék könyvelési fájl létrehozás hiba! |
| 8167 | src/#zak#tech.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál! (/ZAK/ROTATE_BUKRS_OUTPU<br>*--BG 2008.04.16 |
| 8168 | src/#zak#tech.prog.abap | *++FI20070222<br>*      Csak akkor kell könyvelni, ha a fájl hiba nélkül letöltődött |
| 8169 | src/#zak#tech.prog.abap | *++BG 2008.01.07 ÁFA arányosítás könyvelés feladás |
| 8170 | src/#zak#tech.prog.abap | *--BG 2008.01.07 ÁFA arányosítás könyvelés |
| 8171 | src/#zak#tech.prog.abap | *        Súlyos hiba az adófolyószámla tételek könyvelésénél! (&) |
| 8172 | src/#zak#tech.prog.abap | * ++CST 2006.06.04: Ha hiba történt az adófolyószámla könyvelésnél<br>*       Státuszt nem szabad átállítani... |
| 8173 | src/#zak#tech.prog.abap | *--0002 BG 2011.09.20<br>* /zak/bevalli státusz |
| 8174 | src/#zak#tech.prog.abap | * /zak/bevallsz státusz |
| 8175 | src/#zak#tech.prog.abap | * zárolt? |
| 8176 | src/#zak#tech.prog.abap | * /zak/bevallsz státusz |
| 8177 | src/#zak#tech.prog.abap | *   Kérem a periódus értékét 01-52 között adja meg! |
| 8178 | src/#zak#tech.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 8179 | src/#zak#tech.prog.abap | * Bevallás utolsó napjának meghatározás |
| 8180 | src/#zak#tech.prog.abap | * ...negyedéves |
| 8181 | src/#zak#tech.prog.abap | * ...éves |
| 8182 | src/#zak#tech.prog.abap | * bevallás |
| 8183 | src/#zak#tech.prog.abap | *      Nyitott státusz |
| 8184 | src/#zak#tech.prog.abap | *      Ha nincs keressük a zároltakat |
| 8185 | src/#zak#tech.prog.abap | *        Van a következő időszak kell |
| 8186 | src/#zak#tech.prog.abap | *        Ha így sincs akkor 000 |
| 8187 | src/#zak#tech.prog.abap | *  Meghatározzuk az utolsó nem lezárt időszakot! |
| 8188 | src/#zak#tech.prog.abap | * minden adatszolgáltatás elengedett kötelezettség legyen, ha nem adott<br>* fel analitikát<br>* outer join kell !!! |
| 8189 | src/#zak#tech.prog.abap | * nincs  az adatszolgáltatáshoz feltöltés!<br>* /zak/bevallsz insert |
| 8190 | src/#zak#tech.prog.abap | *--2008 #04.<br>* volt már bevallás az időszakra |
| 8191 | src/#zak#tech.prog.abap | * Vállalat megnevezés |
| 8192 | src/#zak#tech.prog.abap | * Bevallás típus megnevezés |
| 8193 | src/#zak#tech.prog.abap | * Vállalat megnevezés |
| 8194 | src/#zak#tech.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 8195 | src/#zak#tech.prog.abap | *    Szövegek betöltése |
| 8196 | src/#zak#tech.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.1<br>*    Egyébként mehet |
| 8197 | src/#zak#tech.prog.abap | *    Mehet az adatbázis törlése |
| 8198 | src/#zak#tech.prog.abap | * /zak/bevallp törléskód legyen 'X' |
| 8199 | src/#zak#tech.prog.abap | * a statisztikai flag módosítás, csak teljes adatszolgáltatás<br>* ismétlésnél lehettséges. |
| 8200 | src/#zak#tech.prog.abap | * Szja bevall. Önrev.-ra feltöltésnél előző indexű, azonos<br>* adaszolgáltatás és adószámhoz tartozó tételeket statisztikai tételként<br>* kell megjelölni. |
| 8201 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás törlések |
| 8202 | src/#zak#tech.prog.abap | * Bevallás analitika törlések |
| 8203 | src/#zak#tech.prog.abap | * a /zak/bevalli tábla flag-et üresre kell állítani |
| 8204 | src/#zak#tech.prog.abap | *++BG 2010/01/08<br>*      Vegig kell menni a BEVALLI bejegyzéseken, mert nem biztos,hogy<br>*      egy feltöltés azonosító csak egy időszakban van!!! |
| 8205 | src/#zak#tech.prog.abap | *        Nincs rekord kitöröljük a sort |
| 8206 | src/#zak#tech.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 8207 | src/#zak#tech.prog.abap | * /zak/bevallp ellenörzése |
| 8208 | src/#zak#tech.prog.abap | *   & package átadásra került másik rendszerbe, kérem először ott törölje! |
| 8209 | src/#zak#tech.prog.abap | * bevallás |
| 8210 | src/#zak#tech.prog.abap | * A feltöltött adatok törlése ne legyen végrehajtható olyan package-re,<br>* amelynek a BEVALLSZ-ben lévő adatszolgáltatás azonosítója a<br>* BEVALLD-ben a /ZAK/AFA_SAP_SEL programot tartalmazza.<br>*++0004 BG 2007.04.04<br>* vagy a /ZAK/ONYB_SAP_SEL programot tartalmazza.<br>*--0004 BG 2007.04.04<br>*++2010.06.04 BG<br>* vagy /ZAK/ZAK_UREP_AP_SEL<br>*--2010.06.04 BG |
| 8211 | src/#zak#tech.prog.abap | *   Üzenetek kezelése |
| 8212 | src/#zak#tech.prog.abap | *    Szövegek betöltése |
| 8213 | src/#zak#tech.prog.abap | *'APEH által ellenőrzött időszakot állít be, a funkció nem<br>* visszavonható' |
| 8214 | src/#zak#tech.prog.abap | *    Szövegek betöltése |
| 8215 | src/#zak#tech.prog.abap | *'APEH által ellenőrzött időszakot állít be, a funkció nem<br>* visszavonható' |
| 8216 | src/#zak#tech.prog.abap | *++ BG 2006.03.28<br>*  SZJA_CUST Törlése |
| 8217 | src/#zak#tech.prog.abap | *  BEVALLDEF törlése |
| 8218 | src/#zak#tech.prog.abap | *  AFA_CUST Törlése |
| 8219 | src/#zak#tech.prog.abap | *  AFA_ATV  Törlése |
| 8220 | src/#zak#tech.prog.abap | * bevallási időszakok |
| 8221 | src/#zak#tech.prog.abap | * nincs az adatszolgáltatás-időszakra bevallás tehát zárolom! |
| 8222 | src/#zak#tech.prog.abap | * Utolsó futás ideje - timestamp /ZAK/BEVALLSZ-LARUN |
| 8223 | src/#zak#tech.prog.abap | * bevallás típushoz meghatározom a bevallás fajtát! |
| 8224 | src/#zak#tech.prog.abap | * aktualizálom a vezérlő táblákat, mert megváltozott a btype!<br>* Bevallás általános adatai |
| 8225 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás beállítás |
| 8226 | src/#zak#tech.prog.abap | * Bevallás adatszolgáltatás adatai |
| 8227 | src/#zak#tech.prog.abap | * Bevallás nyomtatvány adatok |
| 8228 | src/#zak#tech.prog.abap | * normál bevallás |
| 8229 | src/#zak#tech.prog.abap | * önrevizós bevallás |
| 8230 | src/#zak#tech.prog.abap | *   Kérem a periódus értékét 01-52 között adja meg! |
| 8231 | src/#zak#tech.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 8232 | src/#zak#tech.prog.abap | * van már bevallás az adott időszakra ? |
| 8233 | src/#zak#tech.prog.abap | * Bevallás utolsó napjának meghatározás |
| 8234 | src/#zak#tech.prog.abap | * ...negyedéves |
| 8235 | src/#zak#tech.prog.abap | * ...éves |
| 8236 | src/#zak#tech.prog.abap | * Feltöltjük a csoport vállalatot is |
| 8237 | src/#zak#tech.prog.abap | *Range feltöltése: |
| 8238 | src/#zak#tech.prog.abap | *Meghatározzuk a csoport vállalatot |
| 8239 | src/#zak#tech.prog.abap | *  Meghatározzuk a csoport vállalatot |
| 8240 | src/#zak#tech.prog.abap | * ellenőrizzük, hogy az adott időszakban szerepel e a csoportban! |
| 8241 | src/#zak#tech.prog.screen_9000.abap | nincs emberi komment blokk |
| 8242 | src/#zak#tech.prog.screen_9001.abap | nincs emberi komment blokk |
| 8243 | src/#zak#tech.prog.screen_9002.abap | nincs emberi komment blokk |
| 8244 | src/#zak#tech.prog.screen_9003.abap | nincs emberi komment blokk |
| 8245 | src/#zak#tech.prog.screen_9004.abap | nincs emberi komment blokk |
| 8246 | src/#zak#tech.prog.screen_9010.abap | nincs emberi komment blokk |
| 8247 | src/#zak#urep_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& Report  /ZAK/UREP_SAP_SEL<br>*&<br>*&---------------------------------------------------------------------*<br>*& Funkció leírás: A program a szelekción megadott feltételek alapján<br>*& leválogatja a SAP bizonylatokból az adatokat, és meghatározza<br>*& a /ZAK/ZAKO-ban feldolgozandó adathalmazt<br>*&---------------------------------------------------------------------*<br>*& Szerző            : Balázs Gábor - FMC<br>*& Létrehozás dátuma : 2008.11.17<br>*& Funkc.spec.készítő: Róth Nándor<br>*& SAP modul neve    : ADO<br>*& Program  típus    : Riport<br>*& SAP verzió        : 50<br>*&---------------------------------------------------------------------* |
| 8248 | src/#zak#urep_sap_sel.prog.abap | *&---------------------------------------------------------------------*<br>*& MÓDOSÍTÁSOK (Az OSS note számát a módosított sorok végére kell írni)*<br>*&<br>*& LOG#     DÁTUM       MÓDOSÍTÓ                      LEÍRÁS<br>*& ----   ----------   ----------    -----------------------------------<br>*& 0001   2009.01.12   Balázs Gábor  WL feladás javítás: főkönyv,periód<br>*& 0002   2009.04.20   Balázs Gábor  WL ÁFA kód /ZAK/SZJA_ABEV-ből<br>*& 0003   2009.05.22   Balázs Gábor  Kizárt bizonylatok kezelése<br>*& 0004   2009.10.29   Balázs Gábor  Vállalat forgatás kezelése<br>*& 0005   2010.01.08   Balázs Gábor  PST elem töltése<br>*&---------------------------------------------------------------------* |
| 8249 | src/#zak#urep_sap_sel.prog.abap | *IDŐSZAKok szelekcióhoz |
| 8250 | src/#zak#urep_sap_sel.prog.abap | *Beállítás adatok |
| 8251 | src/#zak#urep_sap_sel.prog.abap | *Arányszámok bevallás típusonként kell |
| 8252 | src/#zak#urep_sap_sel.prog.abap | *ABEV meghatározása |
| 8253 | src/#zak#urep_sap_sel.prog.abap | * ALV kezelési változók |
| 8254 | src/#zak#urep_sap_sel.prog.abap | * Vállalat. |
| 8255 | src/#zak#urep_sap_sel.prog.abap | * Bevallás fajta meghatározása |
| 8256 | src/#zak#urep_sap_sel.prog.abap | * Hónap |
| 8257 | src/#zak#urep_sap_sel.prog.abap | * Adatszolgáltatás azonosító |
| 8258 | src/#zak#urep_sap_sel.prog.abap | *++0003 2009.05.22 BG<br>* Kizárt bizonylatok |
| 8259 | src/#zak#urep_sap_sel.prog.abap | * Teszt futás |
| 8260 | src/#zak#urep_sap_sel.prog.abap | *Feltöltés módjának kiválasztása |
| 8261 | src/#zak#urep_sap_sel.prog.abap | *Könyvelési excel fájl |
| 8262 | src/#zak#urep_sap_sel.prog.abap | *  Megnevezések meghatározása |
| 8263 | src/#zak#urep_sap_sel.prog.abap | *--0003 2009.05.22 BG<br>*++1765 #19.<br>* Jogosultság vizsgálat |
| 8264 | src/#zak#urep_sap_sel.prog.abap | *   Önnek nincs jogosultsága a program futtatásához! |
| 8265 | src/#zak#urep_sap_sel.prog.abap | *++0003 2009.05.22 BG<br>* Meghatározzuk ban e kizárt bizonylatszám |
| 8266 | src/#zak#urep_sap_sel.prog.abap | *  Képernyő attribútomok beállítása |
| 8267 | src/#zak#urep_sap_sel.prog.abap | *  SZJA bevallás típus ellenőrzése |
| 8268 | src/#zak#urep_sap_sel.prog.abap | *   Kérem SZJA típusú bevallás azonosítót adjon meg!<br>*  Meghatározzuk a bevallás típust |
| 8269 | src/#zak#urep_sap_sel.prog.abap | *  Szolgáltatás azonosító ellenőrzése |
| 8270 | src/#zak#urep_sap_sel.prog.abap | *  Periódus ellenőrzése |
| 8271 | src/#zak#urep_sap_sel.prog.abap | *  Blokk ellenőrzése |
| 8272 | src/#zak#urep_sap_sel.prog.abap | * Éles futásnál kell fájl név |
| 8273 | src/#zak#urep_sap_sel.prog.abap | *   Kérem adja meg a könyvelési fájl nevét! |
| 8274 | src/#zak#urep_sap_sel.prog.abap | *++ 2010.06.10 RN<br>* az AT SELECTION SCREEN mellett ide is be kellett rakni, mert ott csak<br>* akkor fut le, ha Entert is nyomnak a selection screen-en<br>* Meghatározzuk ban e kizárt bizonylatszám |
| 8275 | src/#zak#urep_sap_sel.prog.abap | * Jogosultság vizsgálat |
| 8276 | src/#zak#urep_sap_sel.prog.abap | * Ha a BYTPE üres, akkor meghatározzuk |
| 8277 | src/#zak#urep_sap_sel.prog.abap | * Vállalati adatok beolvasása |
| 8278 | src/#zak#urep_sap_sel.prog.abap | *   Hiba a & vállalati adatok meghatározásánál! (T001 tábla) |
| 8279 | src/#zak#urep_sap_sel.prog.abap | * Start dátum meghatározása |
| 8280 | src/#zak#urep_sap_sel.prog.abap | *   Hiányzó beállítás & vállalat kezdődátum meghatározásához! |
| 8281 | src/#zak#urep_sap_sel.prog.abap | * Utolsó futás LOG beolvasása |
| 8282 | src/#zak#urep_sap_sel.prog.abap | * Beállítási adatok meghatározása |
| 8283 | src/#zak#urep_sap_sel.prog.abap | * Szelekció hónap utolsó napjának meghatározása |
| 8284 | src/#zak#urep_sap_sel.prog.abap | * IDŐSZAKok meghatározása szelekcióhoz |
| 8285 | src/#zak#urep_sap_sel.prog.abap | * Ha nincs időszak, akkor hiba |
| 8286 | src/#zak#urep_sap_sel.prog.abap | *   Nem lehet feldolgozási időszakot meghatározni! |
| 8287 | src/#zak#urep_sap_sel.prog.abap | * Adatok leválogatása |
| 8288 | src/#zak#urep_sap_sel.prog.abap | * Beállítások meghatározása |
| 8289 | src/#zak#urep_sap_sel.prog.abap | *    Hiba az SZJA beállítások meghatározásánál! |
| 8290 | src/#zak#urep_sap_sel.prog.abap | * Feldolgozattlan rekordok leválogatása |
| 8291 | src/#zak#urep_sap_sel.prog.abap | * Könyvelés adatok válogatása |
| 8292 | src/#zak#urep_sap_sel.prog.abap | *    nincs a szelekciónak megfelelő adat. |
| 8293 | src/#zak#urep_sap_sel.prog.abap | * Arány meghatározása |
| 8294 | src/#zak#urep_sap_sel.prog.abap | * Könyvelés fájl forgatás (költséghely) |
| 8295 | src/#zak#urep_sap_sel.prog.abap | * Éles futás, adatbázis módosítás, stb. |
| 8296 | src/#zak#urep_sap_sel.prog.abap | *  Könyvelési fájl letöltése |
| 8297 | src/#zak#urep_sap_sel.prog.abap | * Vállalat megnevezése |
| 8298 | src/#zak#urep_sap_sel.prog.abap | *   Kérem a periódus értékét 01-16 között adja meg! |
| 8299 | src/#zak#urep_sap_sel.prog.abap | *   Feltöltés azonosító figyelmen kívül hagyva! |
| 8300 | src/#zak#urep_sap_sel.prog.abap | *   Kérem adja meg a feltöltés azonosítót! |
| 8301 | src/#zak#urep_sap_sel.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12 |
| 8302 | src/#zak#urep_sap_sel.prog.abap | *   Hiba a & vállalat forgatás meghatározásnál!... |
| 8303 | src/#zak#urep_sap_sel.prog.abap | * Nincs időszak kilépés |
| 8304 | src/#zak#urep_sap_sel.prog.abap | * A nagyobb dátumtól megyük a szelekción megadottig. |
| 8305 | src/#zak#urep_sap_sel.prog.abap | * Ha az kezdeti időszak nagyobb, akkor kilépés |
| 8306 | src/#zak#urep_sap_sel.prog.abap | * Kezdeti időszak |
| 8307 | src/#zak#urep_sap_sel.prog.abap | * IDŐSZAK feltöltése |
| 8308 | src/#zak#urep_sap_sel.prog.abap | *  átmeneti táblák a leválogatáshoz. |
| 8309 | src/#zak#urep_sap_sel.prog.abap | * BKPF, BSEG leválogatása normál tételek (utolsó futás szerint) |
| 8310 | src/#zak#urep_sap_sel.prog.abap | *   Adatok leválogatása |
| 8311 | src/#zak#urep_sap_sel.prog.abap | *   BSIS rekordok meghatározása |
| 8312 | src/#zak#urep_sap_sel.prog.abap | *   BKPF rekordok meghatározása |
| 8313 | src/#zak#urep_sap_sel.prog.abap | *   Ha nincs BKPF rekord, akkor jöhet a következő |
| 8314 | src/#zak#urep_sap_sel.prog.abap | *   BSEG rekord leválogatása |
| 8315 | src/#zak#urep_sap_sel.prog.abap | *      nincs a feltételnek megfelelő adat, jöhet a következő |
| 8316 | src/#zak#urep_sap_sel.prog.abap | *   Feldolgozatlan tételek BSIS leválogatása |
| 8317 | src/#zak#urep_sap_sel.prog.abap | * BKPF rekordok meghatározása |
| 8318 | src/#zak#urep_sap_sel.prog.abap | * BSEG rekord leválogatása |
| 8319 | src/#zak#urep_sap_sel.prog.abap | * Feldogozatlan rekordok mentése |
| 8320 | src/#zak#urep_sap_sel.prog.abap | * Duplikált tételek törlése: |
| 8321 | src/#zak#urep_sap_sel.prog.abap | *++0004 BG 2009.10.29<br>*  BSEG rekordok szűrése forgatott vállalatkódra |
| 8322 | src/#zak#urep_sap_sel.prog.abap | * LOG utolsó időpont |
| 8323 | src/#zak#urep_sap_sel.prog.abap | * CPU datátum és időpont szerinti szűrés |
| 8324 | src/#zak#urep_sap_sel.prog.abap | * WL bizonylat szűrés (ezeket a bizonylatokat mi könyveljük) |
| 8325 | src/#zak#urep_sap_sel.prog.abap | *     Elmentett utolsó időpont: |
| 8326 | src/#zak#urep_sap_sel.prog.abap | *     Ellenőrizzük, hogy feldolgozható e. |
| 8327 | src/#zak#urep_sap_sel.prog.abap | *     Nem feldolgozandó tétel |
| 8328 | src/#zak#urep_sap_sel.prog.abap | *     Utolsó rekord szűréshez |
| 8329 | src/#zak#urep_sap_sel.prog.abap | *       Rekord már feldolgozva |
| 8330 | src/#zak#urep_sap_sel.prog.abap | *       LOG adatok mentése ha kell |
| 8331 | src/#zak#urep_sap_sel.prog.abap | *Pénznem ellenőrzés<br>*A program leválogatott nem HUF-os tételeket is amit<br>*az analitikában rosszul kezelt mert a tételekből a<br>*DMBTR (saját pénznem) mezőből számolt a pénznemhez<br>*viszont a BKPF-WAERS (pld. EUR) értéket írta.<br>*Ezért a BKPF_WAERS-be mindig a vállalat T001-WAERS-et<br>*írjuk be! |
| 8332 | src/#zak#urep_sap_sel.prog.abap | *  A rendelésből feltételt csinál a szelekcióhoz |
| 8333 | src/#zak#urep_sap_sel.prog.abap | * BSIS szelekció |
| 8334 | src/#zak#urep_sap_sel.prog.abap | * Arány meghatározása |
| 8335 | src/#zak#urep_sap_sel.prog.abap | *       Most lépjük át a keretet |
| 8336 | src/#zak#urep_sap_sel.prog.abap | *       Már átléptük a keretet |
| 8337 | src/#zak#urep_sap_sel.prog.abap | *       Visszamegyünk a keret alá |
| 8338 | src/#zak#urep_sap_sel.prog.abap | *   Meghatározzuk az időszak kezdetét és végét |
| 8339 | src/#zak#urep_sap_sel.prog.abap | *     A rendelésből feltételt csinál a szelekcióhoz |
| 8340 | src/#zak#urep_sap_sel.prog.abap | *      Végig gyalogol a megfelelő BSEG tételeken |
| 8341 | src/#zak#urep_sap_sel.prog.abap | *        rákeres a fej adatra |
| 8342 | src/#zak#urep_sap_sel.prog.abap | *        Az adóalapot számítja a feltételeknek megfelelően |
| 8343 | src/#zak#urep_sap_sel.prog.abap | *        Adóalap halmozás |
| 8344 | src/#zak#urep_sap_sel.prog.abap | * Alapok halmozása, arány kiszámítása |
| 8345 | src/#zak#urep_sap_sel.prog.abap | *   Üzleti rész |
| 8346 | src/#zak#urep_sap_sel.prog.abap | *   Repi rész |
| 8347 | src/#zak#urep_sap_sel.prog.abap | *    Adatok feldolgozása |
| 8348 | src/#zak#urep_sap_sel.prog.abap | *   Rákeres a fej adatra |
| 8349 | src/#zak#urep_sap_sel.prog.abap | *   Meghatározzuk az időszakhoz létezik e bevallás típust |
| 8350 | src/#zak#urep_sap_sel.prog.abap | *   Meghatározzuk az SZJA_CUST először rendelésre is. |
| 8351 | src/#zak#urep_sap_sel.prog.abap | *   Megpróbáljuk rendelés nélkül |
| 8352 | src/#zak#urep_sap_sel.prog.abap | *     Bevallás típus meghatározás hiba! |
| 8353 | src/#zak#urep_sap_sel.prog.abap | *   Ha nem üres az ABEV azonosító, akkor kell az analitikába a sor |
| 8354 | src/#zak#urep_sap_sel.prog.abap | *      KITÖLTI az analitika 1 sorát. |
| 8355 | src/#zak#urep_sap_sel.prog.abap | *   WL-es könyvelés |
| 8356 | src/#zak#urep_sap_sel.prog.abap | *Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az |
| 8357 | src/#zak#urep_sap_sel.prog.abap | *       kiírja a rekordokat |
| 8358 | src/#zak#urep_sap_sel.prog.abap | *   Beállítás szerinti átkönyvelés |
| 8359 | src/#zak#urep_sap_sel.prog.abap | *Egy azonosítónak össze kell fognia a tételeket, most egy tételszám az |
| 8360 | src/#zak#urep_sap_sel.prog.abap | *        kiírja a rekordot |
| 8361 | src/#zak#urep_sap_sel.prog.abap | *  Minden lehetséges adatot kitölt |
| 8362 | src/#zak#urep_sap_sel.prog.abap | * Könyvelési periódus  és dátum beállítása |
| 8363 | src/#zak#urep_sap_sel.prog.abap | * Meghatározzuk az időszakhoz a bevallás típust |
| 8364 | src/#zak#urep_sap_sel.prog.abap | * Ha nem egyezik meg, akkor konvertálás: |
| 8365 | src/#zak#urep_sap_sel.prog.abap | *  Megnézzük mi lenne a megfelelő ABEV |
| 8366 | src/#zak#urep_sap_sel.prog.abap | *  A következő év C_REPI_MONAT-ra kell beállítani |
| 8367 | src/#zak#urep_sap_sel.prog.abap | * Mi legyen a könyvelési dátum |
| 8368 | src/#zak#urep_sap_sel.prog.abap | *++0005 BG 2010/01/08<br>*  PST elem átvétele |
| 8369 | src/#zak#urep_sap_sel.prog.abap | *  Az adóalapot számítja a feltételeknek megfelelően |
| 8370 | src/#zak#urep_sap_sel.prog.abap | *A funkcioelem áltlal generált rekordokat tartalmazza |
| 8371 | src/#zak#urep_sap_sel.prog.abap | *Szét kell bontani bevallás típusonként |
| 8372 | src/#zak#urep_sap_sel.prog.abap | *    A kapott rekordokat visszamásolja az eredetibe. |
| 8373 | src/#zak#urep_sap_sel.prog.abap | *    Adatbázis nem tartalmaz feldolgozható rekordot! |
| 8374 | src/#zak#urep_sap_sel.prog.abap | *  Meg kell hívni a konverziót |
| 8375 | src/#zak#urep_sap_sel.prog.abap | *  Először mindig tesztben futtatjuk |
| 8376 | src/#zak#urep_sap_sel.prog.abap | *   Üzenetek kezelése |
| 8377 | src/#zak#urep_sap_sel.prog.abap | *  Ha nem teszt futás, akkor ellenőrizzük van-e ERROR |
| 8378 | src/#zak#urep_sap_sel.prog.abap | *     Adatfeltöltés nem lehetséges! |
| 8379 | src/#zak#urep_sap_sel.prog.abap | *  Éles futás de van hibaüzent és nem ERROR, kérdés a folytatásról |
| 8380 | src/#zak#urep_sap_sel.prog.abap | *    Szövegek betöltése |
| 8381 | src/#zak#urep_sap_sel.prog.abap | *--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12<br>*    Egyébként mehet |
| 8382 | src/#zak#urep_sap_sel.prog.abap | *    Mehet az adatbázis módosítása |
| 8383 | src/#zak#urep_sap_sel.prog.abap | *      Adatok módosítása |
| 8384 | src/#zak#urep_sap_sel.prog.abap | *     Visszavezetjük az indexet |
| 8385 | src/#zak#urep_sap_sel.prog.abap | *        Elmentjük a package azonosítót |
| 8386 | src/#zak#urep_sap_sel.prog.abap | *     Feldolgozatlan adatok mentése |
| 8387 | src/#zak#urep_sap_sel.prog.abap | *     LOG mentése |
| 8388 | src/#zak#urep_sap_sel.prog.abap | *     Halmozott forgalom mentése |
| 8389 | src/#zak#urep_sap_sel.prog.abap | *     Feltöltés & package számmal megtörtént! |
| 8390 | src/#zak#urep_sap_sel.prog.abap | * Mezőkatalógus összeállítása |
| 8391 | src/#zak#urep_sap_sel.prog.abap | *    Kilépés |
| 8392 | src/#zak#urep_sap_sel.prog.abap | * Mezőkatalógus összeállítása |
| 8393 | src/#zak#urep_sap_sel.prog.abap | * Kilépés |
| 8394 | src/#zak#urep_sap_sel.prog.screen_9000.abap | nincs emberi komment blokk |
| 8395 | src/#zak#urep_sap_sel.prog.screen_9001.abap | nincs emberi komment blokk |
| 8396 | src/#zak#zako_table_clear.prog.abap |       "Felhasználói megerősítés kérése |
| 8397 | src/#zak#zako_table_clear.prog.abap |     " ‘1’ = első gomb (Igen) – xsdbool szépen konvertál boolean-ra |
| 8398 | src/#zak#zako_table_clear.prog.abap |           " -- Felhasználó az „Igen” gombra kattintott |
| 8399 | src/#zak#zako_table_clear.prog.abap |           " -- Felhasználó a „Nem” gombra kattintott |
| 8400 | src/#zak#zako_table_migr.prog.abap | " F4 segítséghez: egymezős struktúra az OBJ_NAME-hez |
| 8401 | src/#zak#zako_table_migr.prog.abap |     " Dinamikus belső tábla létrehozása a forrástábla sorstruktúrájából |
| 8402 | src/#zak#zole.fugr.#zak#lzolef01.abap | nincs emberi komment blokk |
| 8403 | src/#zak#zole.fugr.#zak#lzoletop.abap | *++2010.12.08 Upgrade unicode hiba javítás Balázs Gábor (Ness)<br>*c_tab TYPE x VALUE 09, |
| 8404 | src/#zak#zole.fugr.#zak#lzoletop.abap | *--2010.12.08 Upgrade unicode hiba javítás Balázs Gábor (Ness) |
| 8405 | src/#zak#zole.fugr.#zak#saplzole.abap | nincs emberi komment blokk |
| 8406 | src/#zak#zole.fugr.#zak#zolesingle_table_to_excel.abap | nincs emberi komment blokk |
| 8407 | src/#zak#zxm08u27.prog.abap | nincs emberi komment blokk |
