FUNCTION /ZAK/F4IF_FIELD_VALUE_REQUEST.
*"----------------------------------------------------------------------
*"*"Lokális interfész:
*"       IMPORTING
*"             VALUE(TABNAME) TYPE  DFIES-TABNAME
*"             VALUE(FIELDNAME) TYPE  DFIES-FIELDNAME
*"             VALUE(SEARCHHELP) TYPE  SHLPNAME DEFAULT SPACE
*"             VALUE(SHLPPARAM) TYPE  SHLPFIELD DEFAULT SPACE
*"             VALUE(DYNPPROG) TYPE  SY-REPID DEFAULT SPACE
*"             VALUE(DYNPNR) TYPE  SY-DYNNR DEFAULT SPACE
*"             VALUE(DYNPROFIELD) TYPE  HELP_INFO-DYNPROFLD
*"         DEFAULT SPACE
*"             VALUE(STEPL) TYPE  SY-STEPL DEFAULT 0
*"             VALUE(VALUE) TYPE  HELP_INFO-FLDVALUE DEFAULT SPACE
*"             VALUE(MULTIPLE_CHOICE) TYPE  DDBOOL_D DEFAULT SPACE
*"             VALUE(DISPLAY) TYPE  DDBOOL_D DEFAULT SPACE
*"             VALUE(SUPPRESS_RECORDLIST) TYPE  DDSHF4CTRL-HIDE_LIST
*"         DEFAULT SPACE
*"             VALUE(CALLBACK_PROGRAM) TYPE  SY-REPID DEFAULT SPACE
*"             VALUE(CALLBACK_FORM) TYPE  SY-XFORM DEFAULT SPACE
*"       TABLES
*"              RETURN_TAB STRUCTURE  DDSHRETVAL OPTIONAL
*"       EXCEPTIONS
*"              FIELD_NOT_FOUND
*"              NO_HELP_FOR_FIELD
*"              INCONSISTENT_HELP
*"              NO_VALUES_FOUND
*"----------------------------------------------------------------------
  DATA help_info LIKE help_info.
  DATA ocx_help_info LIKE help_info.
  DATA shlp_top TYPE shlp_descr_t.
  DATA dynpfields LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA dynpselect_dummy LIKE dselc OCCURS 0 WITH HEADER LINE.
  DATA interface_wa LIKE ddshiface.
  DATA callcontrol LIKE ddshf4ctrl.
  DATA: ocxinterface LIKE ddshocxint.
  DATA irc LIKE sy-subrc.
  DATA callbacksave LIKE ddshocxint-callback.
* Flag, ob direkt ins Dynpro zurückgestellt werden soll.
  DATA dynp_update.
* Dummy-Variablen für Forms aus dem F4-Prozessor:
  DATA: selection, select_value LIKE help_info-fldvalue.
* Abschneiden der Unterstriche, die DYNP_VALUES_READ für
* vom Dynp verdeckte Stellen am Ende anhängt.
  FIELD-SYMBOLS: <c>.
  DATA len TYPE i.
  DATA tabix LIKE sy-tabix.
  DATA record_tab LIKE seahlpres OCCURS 0.    "Dummy für CALLBACK

  CLEAR return_tab[].
* OCXINTERFACE wird bei F4 auf Selektionspopup exportiert, damit
* das OCX sein Parent-Control kennt. Damit nachfolgende F4-Aufrufe
* nicht durcheinander kommen, wird das Memory sofort danach gelöscht.
  IMPORT ocxinterface FROM MEMORY ID 'OCXINT'.
* Wenn das gutgeht, muß das OCX gestartet werden, obwohl der Wert
* nicht zurückgestellt werden kann.
  IF sy-subrc = 0.
    EXPORT space TO MEMORY ID 'OCXINT'.  "Nächsten Aufruf wieder normal
  ENDIF.
  help_info-dynprofld = dynprofield. "Kann noch überschrieben werden.
  IF dynpprog <> space AND dynpnr <> space AND dynprofield <> space.
    PERFORM set_help_info_from_focus CHANGING help_info.
*   Update wird vom Baustein (oder vom ActiveX) selbst gemacht.
    dynp_update = 'X'.
  ENDIF.

* Suchhilfe zu dem Feld bestimmen.
  IF searchhelp = space.
    CALL FUNCTION 'F4IF_DETERMINE_SEARCHHELP'
         EXPORTING
              tabname           = tabname
              fieldname         = fieldname
         IMPORTING
              shlp              = shlp_top
         EXCEPTIONS
              field_not_found   = 1
              no_help_for_field = 2
              inconsistent_help = 3
              OTHERS            = 4.
    CASE sy-subrc.
      WHEN 0.
*       Alles in Ordnung
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING field_not_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING no_help_for_field.
      WHEN OTHERS. "Inclusive 3
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING inconsistent_help.
    ENDCASE.
*   Interface zeigt jetzt auf TABNAME-FIELDNAME. Wenn das Dynprofeld
*   mitgegeben wurde, muß auf dieses umgebogen werden.
    IF help_info-dynprofld <> space.
      interface_wa-valtabname = space.
      interface_wa-valfield = help_info-dynprofld.
      MODIFY shlp_top-interface FROM interface_wa
             TRANSPORTING valtabname valfield
             WHERE valtabname = tabname AND
                   valfield = fieldname.
    ENDIF.
    help_info-tabname = tabname.
    help_info-fieldname = fieldname.
*   Falls das Feld eine Prüftabelle hat, kann der CREATE-Button
*   angeboten werden.
    PERFORM check_custtab_available
            CHANGING help_info callcontrol.
  ELSE.
    CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
         EXPORTING
              shlpname = searchhelp
*             SHLPTYPE = 'SH'
         IMPORTING
              shlp     = shlp_top
         EXCEPTIONS
              OTHERS   = 1.
    IF sy-subrc <> 0 OR shlp_top-shlpname = space.
* MSG DH811: Suchhilfe & existiert nicht.
      MESSAGE i811(dh) WITH searchhelp RAISING inconsistent_help.
    ENDIF.
*   Das erste Exporting-Feld ist das F4-Feld, falls SHLPPARAM = SPACE
    CLEAR tabix.
    IF shlpparam = space.
*     Bei direkter Anbindung wird der erste Exporting-Parameter als
*     der Parameter betrachtet, der an dem Dynprofeld hängt.
      LOOP AT shlp_top-interface INTO interface_wa.
        tabix = sy-tabix.
        READ TABLE shlp_top-fieldprop TRANSPORTING NO FIELDS
             WITH KEY fieldname = interface_wa-shlpfield
                      shlpoutput = 'X'.
        IF sy-subrc = 0.
* ++ CST
      interface_wa-f4field = 'X'.
      MODIFY shlp_top-interface FROM interface_wa
             INDEX tabix
             TRANSPORTING f4field.

*          EXIT.
* -- CST
        ELSE.
          CLEAR tabix.
        ENDIF.
      ENDLOOP.
    ELSE.
      READ TABLE shlp_top-interface INTO interface_wa
           WITH KEY shlpfield = shlpparam.
      IF sy-subrc <> 0.
* MSG DH805: Anzeige nicht möglich (Inkonsistenz der Eingabehilfe)
        MESSAGE i805(dh) WITH searchhelp RAISING inconsistent_help.
      ELSE.
        tabix = sy-tabix.
      ENDIF.
    ENDIF.
    IF tabix <> 0.
      interface_wa-f4field = 'X'.
      MODIFY shlp_top-interface FROM interface_wa
             INDEX tabix
             TRANSPORTING f4field.
    ENDIF.
    help_info-call = 'M'.
    help_info-mcobj = searchhelp.
  ENDIF.
  callcontrol-maxrecords = 500.
* Wenn keine Trefferliste angezeigt werden soll, werden als Default
* alle Felder der Trefferliste zurückgegeben.
  IF suppress_recordlist = 'X'.
    callcontrol-hide_list = 'X'.
    callcontrol-retallflds = 'X'.
    CLEAR: callcontrol-maxrecords.
    callcontrol-pvalues = 'D'. "Persönliche Hilfe ausschalten
    CLEAR dynp_update. "Zurückstellen macht hier keinen Sinn
  ENDIF.
  IF dynp_update = 'X'.
    CALL FUNCTION 'DYNP_VALUES_READ'
         EXPORTING
              dyname     = help_info-dynpprog
              dynumb     = help_info-dynpro
              request    = 'A'
         TABLES
              dynpfields = dynpfields
         EXCEPTIONS
              OTHERS     = 9.
*   Inhalt des F4-Feldes wird gleich mit übernommen
    IF value = space.
      SORT dynpfields BY fieldname stepl.
      READ TABLE dynpfields
           WITH KEY fieldname = help_info-dynprofld
                     stepl = help_info-stepl BINARY SEARCH.
      IF sy-subrc = 0.
*       Unterstriche am Ende entfernen
        len = strlen( dynpfields-fieldvalue ) - 1.
        WHILE len > 0.
          ASSIGN dynpfields-fieldvalue+len(1) TO <c>.
          IF <c> <> '_'.
            EXIT.
          ENDIF.
          <c> = space.
          SUBTRACT 1 FROM len.
        ENDWHILE.
        help_info-fldvalue = dynpfields-fieldvalue.
        IF dynpfields-fieldinp = space.
          callcontrol-disponly = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF value <> space.
    help_info-fldvalue = value.
  ENDIF.
* Wenn weder ein DDIC-Feld noch ein Dynpro-Feld angegeben wurde, muß
* irgendwas eingetragen werden, damit das Rückgabefeld markiert wird.
  IF help_info-dynprofld = space AND
     help_info-tabname = space AND
     help_info-fieldname = space.
    help_info-dynprofld = '~'.
  ENDIF.
* Bei Mehrfachauswahl ist z.Zt. kein automatisches Update des
* Dynp-Feldes möglich. Außerdem kann das ActiveX noch keine
* Merhfachauswahl, das wird aber im F4-Prozessor bereits abgefangen
  IF multiple_choice = 'X'.
    callcontrol-multisel = 'X'.
    dynp_update = space.
  ENDIF.
* Bei F4 auf OCX ist auch kein direktes Rückstellen möglich
  IF ocxinterface-ctrlparent <> 0.
    dynp_update = space.
  ENDIF.
* Bei DISPLAY = 'F' wie FORCE, wird auch dann zurückgestellt,
* wenn das Feld auf dem Dynpro nicht eingabebereit ist.
  IF display = 'X'.
    callcontrol-disponly = 'X'.
  ELSEIF display = 'F'.
    callcontrol-disponly = ' '. "Auch wenn es vorher gesetzt war
*   Das ActiveX verläßt sich auf das Interface.
    interface_wa-dispfield = 'T'.
    MODIFY shlp_top-interface FROM interface_wa
           TRANSPORTING dispfield
           WHERE f4field = 'X'.
  ENDIF.
  IF help_info-fldvalue(1) = '='.
    callcontrol-shortcut = 'X'.
  ENDIF.
  callcontrol-curow = sy-curow.
  callcontrol-cucol = sy-cucol.
************** Callback falls gewünscht ********************************
  IF callback_form <> space.
    PERFORM (callback_form) IN PROGRAM (callback_program)
            TABLES record_tab
            CHANGING shlp_top callcontrol.
  ENDIF.
************ Mapping auf Dynpro-Felder erst nach dem Callback *********
* Dadurch können im Callback zusätzliche Dynpro-Felder angegeben
* werden.
* Wenn allerdings gar keine Dynp-Info mitgegeben wurde, dann sollen
* die Modifikationen aus der Callback-Form nicht nochmal überschrieben
* werden.
  IF NOT dynpfields[] IS INITIAL.
    PERFORM map_dynp_to_interface_new(saplsdsd)
            TABLES dynpfields
                   dynpselect_dummy
            CHANGING shlp_top
                  help_info.
  ELSE.
*   Mindestens das F4-Feld und den Inhalt ans Dynprofeld hängen.
    CLEAR interface_wa-valtabname.
    interface_wa-valfield = help_info-dynprofld.
    MODIFY shlp_top-interface FROM interface_wa
           TRANSPORTING valtabname valfield
           WHERE f4field <> space AND
                 valtabname = space AND valfield = space.
    IF help_info-fldvalue <> space.
      interface_wa-value = help_info-fldvalue.
      MODIFY shlp_top-interface FROM interface_wa
             TRANSPORTING value
             WHERE f4field <> space.
    ENDIF.
  ENDIF.
* Erst jetzt, wird bei einer Prüftabellenhilfe entschieden, ob sie
* letztendlich über eine Suchhilfe, über einen Helpview oder über
* einen virtuellen Helpview (mit oder ohne Texttabelle) realisiert
* wird.
  IF shlp_top-shlptype = 'CH'.
    PERFORM get_checktable_help(saplsdsd) CHANGING shlp_top.
  ENDIF.
* Für's OCX exportieren wir auch noch die HELP_INFO
* Das amodale OCX kann nur gestartet werden, wenn das direkte
* Zurückstellen ins Dynpro funktioniert.
* Auserdem macht ein amodaler Aufruf keinen Sinn, wenn der Aufrufer
* hinterher die RETURN_TAB auswerten will.
* Das OCX läuft automatisch modal, wenn in HELP_INFOS keine Information
* zum Dynpro steckt.
  ocx_help_info = help_info.
  IF dynp_update = space OR return_tab IS REQUESTED.
    CLEAR: ocx_help_info-dynpprog, ocx_help_info-dynpro.
  ENDIF.
  PERFORM put_help_infos(saplsdsd)
          USING ocx_help_info CHANGING shlp_top.
  callbacksave = ocxinterface-callback.
  CLEAR ocxinterface-callback.
* ********************* Aufruf des F4-Dialogs ************************
  PERFORM f4proz(saplsdsd)
          TABLES return_tab
          USING shlp_top
          CHANGING callcontrol ocxinterface
                   irc.
  ocxinterface-callback = callbacksave.
  IF ocxinterface-ctrlparent <> 0.
    EXPORT ocxinterface TO MEMORY ID 'OCXINT'.
  ENDIF.
* Rückkehr aus amodalem OCX soll nicht zur Meldung führen.
* Deshalb Abfrage auf DYNP_UPDATE
  IF irc = 4 AND dynp_update = space.
* MSG DH801: Keine Werte gefunden
    MESSAGE s801(dh)
            RAISING no_values_found.
  ENDIF.
  CHECK irc = 0.

* Falls automatische Rückgabe erfolgen soll, die SH-Parameter
* auf die Dynp-Felder mappen und ins Dynpro zurückschreiben.
* Das Ergebnis jetzt wieder auf die Dynp-Felder mappen
  IF dynp_update <> space.
    PERFORM map_shfields_to_dynpfields(saplsdsd)
            TABLES shlp_top-interface
                   dynpfields
                   return_tab
            USING help_info
            CHANGING selection select_value.
    CALL FUNCTION 'DYNP_VALUES_UPDATE'
         EXPORTING
              dyname     = help_info-dynpprog
              dynumb     = help_info-dynpro
         TABLES
              dynpfields = dynpfields
         EXCEPTIONS
              OTHERS     = 8.
  ENDIF.
ENDFUNCTION.
