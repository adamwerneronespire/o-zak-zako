*----------------------------------------------------------------------*
***INCLUDE LSDHIF03 .
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM GET_FIELDS_OF_VALUE_TAB                                  *
*---------------------------------------------------------------------*
*       Beschreibung einer intern definierten Tabelle in Form
*       einer DFIES-Tabelle gewinnen.
*---------------------------------------------------------------------*
*  -->  VALUE_TAB                                                     *
*  -->  FIELD_TAB                                                     *
*  -->  RETFIELD                                                      *
*---------------------------------------------------------------------*
FORM GET_FIELDS_OF_VALUE_TAB
     TABLES VALUE_TAB
            FIELD_TAB STRUCTURE DFIES
     CHANGING RETFIELD LIKE DFIES-FIELDNAME.
  DATA HLP(61).
  DATA OFFSET LIKE DFIES-OFFSET.
  DATA DFIES_ZWI LIKE DFIES.
  DATA DTELINFO_WA TYPE DTELINFO.
  DATA: TABNAME LIKE DD03P-TABNAME, LFIELDNAME LIKE DFIES-LFIELDNAME.
  FIELD-SYMBOLS: <F>.
  DATA: I LIKE SY-INDEX.
  DATA: N(4) TYPE N.

  DESCRIBE FIELD VALUE_TAB HELP-ID HLP.
  DO.
    I = SY-INDEX.
    ASSIGN COMPONENT I OF STRUCTURE VALUE_TAB TO <F>.
    IF SY-SUBRC <> 0 . EXIT. ENDIF.
    DESCRIBE FIELD <F> HELP-ID HLP.
    SPLIT HLP AT '-' INTO TABNAME LFIELDNAME.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
              TABNAME        = TABNAME
              LFIELDNAME     = LFIELDNAME
              ALL_TYPES      = 'X'
         IMPORTING
*             X030L_WA       =
*             DDOBJTYPE      =
              DFIES_WA       = DFIES_ZWI
*        TABLES
*             DFIES_TAB      = DFIES_ZWI
         EXCEPTIONS
              NOT_FOUND      = 1
              INTERNAL_ERROR = 2
              OTHERS         = 3.
    CHECK SY-SUBRC = 0.
    DESCRIBE DISTANCE BETWEEN VALUE_TAB AND <F> INTO DFIES_ZWI-OFFSET
                                         in character mode.
    CLEAR DFIES_ZWI-TABNAME.
    N = I.
    CONCATENATE 'F' N INTO DFIES_ZWI-FIELDNAME.
    dfies_zwi-mask+2(1) = 'X'.         "Rollname für F1-Hilfe verantw.
*   Das Flag F4-Available muß jetzt aber aus dem DTEL kommen.
    CLEAR: DFIES_ZWI-F4AVAILABL, DTELINFO_WA.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
         EXPORTING
              TABNAME     = DFIES_ZWI-ROLLNAME
              ALL_TYPES   = 'X'
         IMPORTING
              DTELINFO_WA = DTELINFO_WA
         EXCEPTIONS
              OTHERS      = 0.
    DFIES_ZWI-F4AVAILABL = DTELINFO_WA-F4AVAILABL.
    APPEND DFIES_ZWI TO FIELD_TAB.
  ENDDO.
  ASSIGN COMPONENT RETFIELD OF STRUCTURE VALUE_TAB TO <F>.
  DESCRIBE DISTANCE BETWEEN VALUE_TAB AND <F> INTO OFFSET
                                 in character mode.
  READ TABLE FIELD_TAB WITH KEY OFFSET = OFFSET.
  CHECK SY-SUBRC = 0.
  RETFIELD = FIELD_TAB-FIELDNAME.
ENDFORM.                               " GET_FIELDS_OF_VALUE_TAB
*---------------------------------------------------------------------*
*       FORM SET_HELP_INFO_FROM_FOCUS                                 *
*---------------------------------------------------------------------*
*       Die Info, zu dem Feld, das bei F4 den Focus hatte, in die
*       HELP_INFO übertragen. Mit dieser Info ist das ActiveX in
*       der Lage, das Feld eindeutig zu identifizieren.
*---------------------------------------------------------------------*
*  -->  HELP_INFO                                                     *
*---------------------------------------------------------------------*
FORM SET_HELP_INFO_FROM_FOCUS CHANGING HELP_INFO STRUCTURE HELP_INFO.
  DATA: BEGIN OF FOCUS,
            SUBPROG LIKE HELP_INFO-DYNPPROG,
            SUBNUM LIKE HELP_INFO-DYNPRO,
            MAINPROG LIKE HELP_INFO-DYNPPROG,
            MAINNUM LIKE HELP_INFO-DYNPRO,
            FIELDNAME LIKE HELP_INFO-DYNPROFLD,
            OFFS TYPE I,               "Cursor innerhalb des Feldes
            LINE TYPE I,               "Steploop
        END OF FOCUS.
* Der Call funktioniert nicht bei der Standard-Hilfe,
* sondern nur zu PAI und POV.
  CALL 'DY_GET_FOCUS'
        ID 'SSCREENNAM' FIELD FOCUS-SUBPROG
        ID 'SSCREENNBR' FIELD FOCUS-SUBNUM
        ID 'MSCREENNAM' FIELD FOCUS-MAINPROG
        ID 'MSCREENNBR' FIELD FOCUS-MAINNUM
        ID 'FIELDNAME' FIELD FOCUS-FIELDNAME
        ID 'FIELDOFFS' FIELD FOCUS-OFFS
        ID 'LINE' FIELD FOCUS-LINE.
*   Die mitgegebene Info ist leider bei Subscreens nicht ausreichend.
*   Deshalb wird hier noch mal die Information zu dem Feld gelesen,
*   das zur Zeit den Focus hat. Wenn erkannt wird, daß das Feld auf
*   einem Subscreen liegt, wird die Information zu dem Subscreen-Feld
*   genommen.
  IF ( FOCUS-SUBPROG <> FOCUS-MAINPROG OR
       FOCUS-SUBNUM <> FOCUS-MAINNUM ).
*     Das Dynprofeld, liegt in einem Subscreen.
    HELP_INFO-SY_DYN = 'U'.
    HELP_INFO-MSGV1 = FOCUS-MAINPROG.  "So ist es nun mal vereinbart
    HELP_INFO-MSGV2 = FOCUS-MAINNUM.
    HELP_INFO-DYNPPROG = FOCUS-SUBPROG.
    HELP_INFO-DYNPRO = FOCUS-SUBNUM.
  ELSE.
    HELP_INFO-DYNPPROG = FOCUS-MAINPROG.
    HELP_INFO-DYNPRO = FOCUS-MAINNUM.
  ENDIF.
  HELP_INFO-STEPL = FOCUS-LINE.
  HELP_INFO-DYNPROFLD = FOCUS-FIELDNAME.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM check_custtab_available                                  *
*---------------------------------------------------------------------*
*       In CALLCONTROL-CUSTTAB die Prüftabelle zum Feld
*       HELP_INFO-TABNAME/FIELDNAME eintragen, falls es
*       dazu eine Customizing-Transaktion gibt.
*---------------------------------------------------------------------*
*  -->  help_info                                                     *
*  -->  callcontrol                                                   *
*---------------------------------------------------------------------*
form check_custtab_available
     changing help_info type help_info
              callcontrol type ddshf4ctrl.
  data dfies_wa type dfies.
  data lfieldname type dfies-lfieldname.
  data irc(1) type c.                  "Achtung: nicht like SY-SUBRC

  check help_info-fieldname <> space and
        help_info-tabname <> space.
  lfieldname = help_info-fieldname.

  CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
            TABNAME    = help_info-tabname
            LFIELDNAME = lfieldname
       IMPORTING
            DFIES_WA   = dfies_wa
       EXCEPTIONS
            OTHERS     = 2.
  check SY-SUBRC = 0 and dfies_wa-checktable <> space.
  help_info-checktable = dfies_wa-checktable.
  CALL FUNCTION 'F4_GET_OBJECT_INFORMATION'
       EXPORTING
            checktable = help_info-checktable
       IMPORTING
            returncode = irc
       EXCEPTIONS
            OTHERS     = 1.
  IF sy-subrc = 0 and irc <> space.
    callcontrol-custtab = help_info-checktable.
  ENDIF.
endform.
