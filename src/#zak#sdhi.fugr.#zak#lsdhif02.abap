*----------------------------------------------------------------------*
***INCLUDE LSDHIF02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  Run_entitytab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SHLP_TAB  text
*      -->P_RECORD_TAB  text
*      -->P_DOMNAME  text
*      -->P_TABNAME  text
*      <--P_SHLP  text
*      <--P_CALLCONTROL  text
*----------------------------------------------------------------------*
FORM Run_entitytab TABLES SHLP_TAB TYPE SHLP_DESCR_TAB_T
                           RECORD_TAB STRUCTURE SEAHLPRES
                   USING DOMNAME LIKE DD01V-DOMNAME
                         VALUE(TABNAME) LIKE DD03P-TABNAME
                   CHANGING SHLP TYPE SHLP_DESCR_T
                            CALLCONTROL STRUCTURE DDSHF4CTRL.

  DATA: VALUE          LIKE DDSHIFACE-VALUE,
        DD01V_wa       LIKE DD01V,
        FIELDNAME      LIKE DFIES-FIELDNAME,
        SHLP_INT       TYPE SHLP_DESCR_T,
        INTERFACE_WA   LIKE DDSHIFACE,
        FIELDS_OUT_TAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
        RC             LIKE SY-SUBRC,
        OCXINTERFACE   LIKE DDSHOCXINT,
        DFIES_WA       TYPE DFIES,
        DFIES_INT      TYPE DFIES,
        MODE           TYPE DDDATMOD.

  IF TABNAME IS INITIAL.
    CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
      EXPORTING
        PARAMETER         = PAR%TABNAME
      IMPORTING
        VALUE             = VALUE
      TABLES
        SHLP_TAB          = SHLP_TAB
        RECORD_TAB        = RECORD_TAB
*       SELOPT_TAB        =
*       RESULTS_TAB       =
      CHANGING
        SHLP              = SHLP
        CALLCONTROL       = CALLCONTROL
      EXCEPTIONS
        PARAMETER_UNKNOWN = 1.
    IF SY-SUBRC = 0.
      TABNAME = VALUE.
    ENDIF.
  ENDIF.
  IF TABNAME CN '-'.
    CALL FUNCTION 'DDIF_DOMA_GET'
      EXPORTING
        NAME     = DOMNAME
      IMPORTING
        DD01V_WA = DD01V_wa
      EXCEPTIONS
        OTHERS   = 2.
  ENDIF.
  IF ( TABNAME CO '+&' AND DD01V_wa-ENTITYTAB IS INITIAL ) OR
     ( TABNAME NA '+&' AND DD01V_wa-ENTITYTAB <> TABNAME ).
    MESSAGE S804(DH) RAISING NO_F4_HLP.
*   No input help available
  ENDIF.
  SHLP_INT-INTDESCR-SELMETHOD = SHLP_INT-SHLPNAME
                              = DD01V_wa-ENTITYTAB.
  SHLP_INT-SHLPTYPE = 'ET'.
  CALLCONTROL-ATTACHKIND = 'A'.
  SHLP_INT-INTDESCR-SELMTYPE = 'T'.
*++S4HANA#01.
*     SELECT SINGLE FIELDNAME INTO fieldname FROM DD03K
*            WHERE TABNAME = DD01V_wa-ENTITYTAB AND DOMNAME = DOMNAME.
  SELECT FIELDNAME INTO FIELDNAME FROM DD03K UP TO 1 ROWS
    WHERE TABNAME = DD01V_wa-ENTITYTAB AND DOMNAME = DOMNAME
    ORDER BY FIELDNAME POSITION.
  ENDSELECT.
*--S4HANA#01.
  IF SY-SUBRC <> 0.
    MESSAGE S804(DH) RAISING NO_F4_HLP.
*   No input help available
  ENDIF.
  PERFORM GET_INTERFACE_CH(SAPLSDSD)
          USING DD01V_wa-ENTITYTAB FIELDNAME
          CHANGING SHLP_INT.
  READ TABLE SHLP-INTERFACE INTO INTERFACE_WA
       WITH KEY SHLPFIELD = PAR%VALUE.
  INTERFACE_WA-SHLPFIELD = FIELDNAME.
  CLEAR: INTERFACE_WA-TOPSHLPNAM, INTERFACE_WA-TOPSHLPFLD.
  LOOP AT SHLP_INT-INTERFACE TRANSPORTING NO FIELDS
       WHERE SHLPFIELD = FIELDNAME.
    MODIFY SHLP_INT-INTERFACE FROM INTERFACE_WA.
    EXIT.
  ENDLOOP.
  PERFORM GET_CHECKTABLE_HELP(SAPLSDSD) CHANGING SHLP_INT.
  LOOP AT SHLP_INT-INTERFACE INTO INTERFACE_WA
       WHERE NOT F4FIELD IS INITIAL.
    FIELDNAME = INTERFACE_WA-SHLPFIELD.
    EXIT.
  ENDLOOP.
  CLEAR CALLCONTROL-STEP.
  IF SHLP_INT-SHLPTYPE = 'ET'.
    SHLP_INT-SHLPTYPE = 'CT'.
  ENDIF.
  PERFORM F4PROZ(SAPLSDSD) TABLES FIELDS_OUT_TAB
                           USING SHLP_INT
                           CHANGING CALLCONTROL OCXINTERFACE RC.
  CHECK RC = 0.
  REFRESH RECORD_TAB.
  READ TABLE SHLP-FIELDDESCR INTO DFIES_WA
       WITH KEY FIELDNAME = PAR%VALUE.
  IF DFIES_WA-MASK+1(1) = 'E'.
    MODE = 'E'.
  ELSE.
    MODE = 'I'.
  ENDIF.
  DFIES_INT = DFIES_WA.
  DFIES_INT-OFFSET = 0.
  LOOP AT FIELDS_OUT_TAB WHERE FIELDNAME = FIELDNAME.
*    PERFORM Move_val(RADBTNA1)
*            USING FIELDS_OUT_TAB-FIELDVAL DFIES_INT 'E' DFIES_WA
*                  MODE
*            CHANGING RECORD_TAB RC.
    APPEND RECORD_TAB.
  ENDLOOP.
ENDFORM.                    " Run_entitytab


*&---------------------------------------------------------------------*
*&      Form  Handle_intervals
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SHLP_TAB  text                                             *
*      -->P_RECORD_TAB  text                                           *
*      -->P_DD07V_TAB  text                                            *
*      <--P_SHLP  text                                                 *
*      <--P_CALLCONTROL  text                                          *
*----------------------------------------------------------------------*
FORM Handle_intervals TABLES SHLP_TAB TYPE SHLP_DESCR_TAB_T
                             RECORD_TAB STRUCTURE SEAHLPRES
                             DD07V_tab STRUCTURE DD07V
                      CHANGING SHLP TYPE SHLP_DESCR_T
                               CALLCONTROL LIKE DDSHF4CTRL.

  DATA: SHLP_HLP     TYPE SHLP_DESCR_T,
        DFIES_WA     LIKE DFIES,
        FIELDPROP_WA LIKE DDSHFPROP,
        LISPOS       LIKE DDSHFPROP-SHLPLISPOS,
        SELOPT_WA    LIKE DDSHSELOPT,
        INTERFACE_WA LIKE DDSHIFACE,
        RECORD_LOC   LIKE SEAHLPRES OCCURS 0 WITH HEADER LINE,
        INTERVALS    LIKE DD07V_tab OCCURS 0,
        DD07V_loc    LIKE DD07V OCCURS 0,
        MAXROWS      LIKE DDSHF4CTRL-MAXRECORDS,
        LEN          LIKE SY-FDPOS,
        OFF          LIKE SY-FDPOS.

  READ TABLE DD07V_tab INDEX 1 TRANSPORTING DOMNAME.
  CHECK SY-SUBRC = 0.
  SHLP_HLP-SHLPNAME = SHLP-SHLPNAME.
  SHLP_HLP-INTERFACE = SHLP-INTERFACE.
  INTERFACE_WA-SHLPFIELD = PAR%_LOW.
  MODIFY SHLP_HLP-INTERFACE FROM INTERFACE_WA TRANSPORTING SHLPFIELD
         WHERE SHLPFIELD = PAR%VALUE.
  INTERFACE_WA-SHLPFIELD = PAR%_TEXT.
  MODIFY SHLP_HLP-INTERFACE FROM INTERFACE_WA TRANSPORTING SHLPFIELD
         WHERE SHLPFIELD = PAR%TEXT.
  READ TABLE SHLP-FIELDDESCR INTO DFIES_WA
       WITH KEY FIELDNAME = PAR%VALUE.
  IF SY-SUBRC <> 0.
    CLEAR DFIES_WA.
    DFIES_WA-DOMNAME = DD07V_tab-DOMNAME.
    DFIES_WA-KEYFLAG = 'X'.
    DFIES_WA-MASK+2(1) = 'X'.
  ENDIF.
  DFIES_WA-POSITION = 1.
  DFIES_WA-FIELDNAME = PAR%_LOW.
  APPEND DFIES_WA TO SHLP_HLP-FIELDDESCR.
  DFIES_WA-POSITION = 2.
  DFIES_WA-FIELDNAME = PAR%_HIGH.
  APPEND DFIES_WA TO SHLP_HLP-FIELDDESCR.
  READ TABLE SHLP-FIELDDESCR INTO DFIES_WA
       WITH KEY FIELDNAME = PAR%TEXT.
  IF SY-SUBRC = 0.
    DFIES_WA-POSITION = 3.
    APPEND DFIES_WA TO SHLP_HLP-FIELDDESCR.
  ENDIF.
  SHLP_HLP-INTDESCR = SHLP-INTDESCR.
  CLEAR SHLP_HLP-INTDESCR-SELMEXIT.
  READ TABLE SHLP-FIELDPROP INTO FIELDPROP_WA
      WITH KEY FIELDNAME = PAR%VALUE.
  IF SY-SUBRC <> 0.
    CLEAR FIELDPROP_WA.
  ENDIF.
  IF FIELDPROP_WA-SHLPLISPOS = 0.
    FIELDPROP_WA-SHLPLISPOS = 1.
  ENDIF.
  FIELDPROP_WA-FIELDNAME = PAR%_LOW.
  APPEND FIELDPROP_WA TO SHLP_HLP-FIELDPROP.
  LISPOS = FIELDPROP_WA-SHLPLISPOS.
  MODIFY SHLP_HLP-FIELDDESCR FROM DFIES_WA TRANSPORTING KEYFLAG
         WHERE FIELDNAME = PAR%_LOW.
  ADD 1 TO FIELDPROP_WA-SHLPLISPOS.
  FIELDPROP_WA-FIELDNAME = PAR%_HIGH.
  APPEND FIELDPROP_WA TO SHLP_HLP-FIELDPROP.
  SHLP_HLP-SHLPTYPE = 'DV'.
  READ TABLE SHLP-FIELDPROP INTO FIELDPROP_WA
       WITH KEY FIELDNAME = PAR%TEXT.
  IF SY-SUBRC = 0.
    FIELDPROP_WA-FIELDNAME = PAR%_TEXT.
    IF FIELDPROP_WA-SHLPLISPOS > 0.
      SHLP_HLP-SHLPTYPE = 'FV'.
      IF LISPOS = 1.
        FIELDPROP_WA-SHLPLISPOS = 3.
      ENDIF.
    ENDIF.
    APPEND FIELDPROP_WA TO SHLP_HLP-FIELDPROP.
  ENDIF.
  SHLP_HLP-SELOPT = SHLP-SELOPT.
  SELOPT_WA-SHLPFIELD = PAR%_LOW.
  MODIFY SHLP_HLP-SELOPT FROM SELOPT_WA TRANSPORTING SHLPFIELD
         WHERE SHLPFIELD = PAR%VALUE.
  SELOPT_WA-SHLPFIELD = PAR%_TEXT.
  MODIFY SHLP_HLP-SELOPT FROM SELOPT_WA TRANSPORTING SHLPFIELD
         WHERE SHLPFIELD = PAR%TEXT.
  PERFORM New_offsets CHANGING SHLP_HLP.
  LOOP AT DD07V_tab.
    IF DD07V_tab-DOMVALUE_H IS INITIAL.
      APPEND DD07V_tab TO DD07V_loc.
    ELSE.
      APPEND DD07V_tab TO INTERVALS.
    ENDIF.
  ENDLOOP.
  APPEND LINES OF INTERVALS TO DD07V_loc.
  PERFORM Set_parameter_dofv
          TABLES SHLP_TAB RECORD_LOC DD07V_loc
          USING: PAR%_LOW CHANGING SHLP_HLP CALLCONTROL,
                 PAR%_HIGH CHANGING SHLP_HLP CALLCONTROL,
                 PAR%_TEXT CHANGING SHLP_HLP CALLCONTROL.
  CALL FUNCTION 'F4IF_DISPLAY_VALUES'
    TABLES
      SHLP_TAB    = SHLP_TAB
      RECORD_TAB  = RECORD_LOC
    CHANGING
      SHLP        = SHLP_HLP
      CALLCONTROL = CALLCONTROL.
  READ TABLE SHLP_HLP-FIELDDESCR INTO DFIES_WA
       WITH KEY FIELDNAME = PAR%_LOW TRANSPORTING OFFSET INTLEN.
  LEN = DFIES_WA-INTLEN.
  OFF = DFIES_WA-OFFSET.
  CALL FUNCTION 'F4UT_PARAMETER_RESULTS_PUT'
    EXPORTING
      PARAMETER   = PAR%VALUE
      OFF_SOURCE  = OFF
      LEN_SOURCE  = LEN
    TABLES
      SHLP_TAB    = SHLP_TAB
      RECORD_TAB  = RECORD_TAB
      SOURCE_TAB  = RECORD_LOC
    CHANGING
      SHLP        = SHLP
      CALLCONTROL = CALLCONTROL
    EXCEPTIONS
      OTHERS      = 2.
  READ TABLE SHLP_HLP-FIELDDESCR INTO DFIES_WA
       WITH KEY FIELDNAME = PAR%_TEXT TRANSPORTING OFFSET INTLEN.
  CHECK SY-SUBRC = 0.
  LEN = DFIES_WA-INTLEN.
  OFF = DFIES_WA-OFFSET.
  CALL FUNCTION 'F4UT_PARAMETER_RESULTS_PUT'
    EXPORTING
      PARAMETER   = PAR%TEXT
      OFF_SOURCE  = OFF
      LEN_SOURCE  = LEN
    TABLES
      SHLP_TAB    = SHLP_TAB
      RECORD_TAB  = RECORD_TAB
      SOURCE_TAB  = RECORD_LOC
    CHANGING
      SHLP        = SHLP
      CALLCONTROL = CALLCONTROL
    EXCEPTIONS
      OTHERS      = 2.
ENDFORM.                    " Handle_intervals


*&---------------------------------------------------------------------*
*&      Form  Set_parameter_dofv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SHLP_TAB  text                                             *
*      -->P_RECORD_TAB  text                                           *
*      -->P_DD07V_TAB  text                                            *
*      <--P_SHLP  text                                                 *
*      <--P_CALLCONTROL  text                                          *
*      -->P_0379   text                                                *
*----------------------------------------------------------------------*
FORM Set_parameter_dofv TABLES SHLP_TAB TYPE SHLP_DESCR_TAB_T
                               RECORD_TAB STRUCTURE SEAHLPRES
                               DD07V_tab STRUCTURE DD07V
                        USING PARAMETER LIKE DDSHFPROP-FIELDNAME
                        CHANGING SHLP TYPE SHLP_DESCR_T
                                 CALLCONTROL LIKE DDSHF4CTRL.

  DATA: OFF     LIKE SY-FDPOS,
        LEN     LIKE SY-FDPOS,
        MAXROWS LIKE CALLCONTROL-MAXRECORDS.

  FIELD-SYMBOLS <PAR>.

  CASE PARAMETER.
    WHEN PAR%VALUE. ASSIGN DD07V_TAB-DOMVALUE_L TO <PAR>.
    WHEN PAR%TEXT. ASSIGN DD07V_TAB-DDTEXT TO <PAR>.
    WHEN PAR%_LOW. ASSIGN DD07V_TAB-DOMVALUE_L TO <PAR>.
    WHEN PAR%_HIGH. ASSIGN DD07V_TAB-DOMVALUE_H TO <PAR>.
    WHEN PAR%_TEXT. ASSIGN DD07V_TAB-DDTEXT TO <PAR>.
    WHEN OTHERS. EXIT.
  ENDCASE.
  DESCRIBE DISTANCE BETWEEN DD07V_TAB AND <PAR> INTO OFF
           IN CHARACTER MODE.
  DESCRIBE FIELD <PAR> LENGTH LEN IN CHARACTER MODE.
  CALL FUNCTION 'F4UT_PARAMETER_RESULTS_PUT'
    EXPORTING
      PARAMETER         = PARAMETER
      OFF_SOURCE        = OFF
      LEN_SOURCE        = LEN
    TABLES
      SHLP_TAB          = SHLP_TAB
      RECORD_TAB        = RECORD_TAB
      SOURCE_TAB        = DD07V_tab
    CHANGING
      SHLP              = SHLP
      CALLCONTROL       = CALLCONTROL
    EXCEPTIONS
      PARAMETER_UNKNOWN = 1
      OTHERS            = 2.
  IF CALLCONTROL-MAXRECORDS > 0.
    MAXROWS = CALLCONTROL-MAXRECORDS + 1.
    DELETE RECORD_TAB FROM MAXROWS.
    IF SY-SUBRC = 0 AND PARAMETER = PAR%VALUE.
      MESSAGE S803(DH) WITH CALLCONTROL-MAXRECORDS.
*   There are more than & input options
    ENDIF.
  ENDIF.
ENDFORM.                    " Set_parameter_dofv


*&---------------------------------------------------------------------*
*&      Form  New_offsets
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SHLP_HLP  text                                             *
*----------------------------------------------------------------------*
FORM New_offsets CHANGING SHLP TYPE SHLP_DESCR_T.

  DATA: DFIES_WA LIKE DFIES,
        RC       LIKE SY-SUBRC.


  PERFORM Domainfo_to_dfies(SAPLSDIF) TABLES SHLP-FIELDDESCR
                                      CHANGING RC.
  CLEAR DFIES_WA-OFFSET.
  MODIFY SHLP-FIELDDESCR FROM DFIES_WA TRANSPORTING OFFSET
         WHERE OFFSET > 0.
  PERFORM Set_offset(SAPLSDF4) CHANGING SHLP.
ENDFORM.                    " New_offsets


*&---------------------------------------------------------------------*
*&      Form  Callback_subshlp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SHLP_HLP  text                                             *
*----------------------------------------------------------------------*
FORM Callback_subshlp TABLES Record_tab STRUCTURE SEAHLPRES
                      CHANGING SHLP TYPE SHLP_DESCR_T
                               CALLCONTROL LIKE DDSHF4CTRL.

  DATA INTERFACE_WA LIKE DDSHIFACE.

  CALLCONTROL-RETALLFLDS = 'X'.
  CALLCONTROL-PVALUES = CALLCONTROL-PERSONALIZ = 'D'.
  INTERFACE_WA-VALUE = %SHLPNAME.
  MODIFY SHLP-INTERFACE FROM INTERFACE_WA TRANSPORTING VALUE
         WHERE SHLPFIELD = 'SHLPNAME'.
ENDFORM.                    " Callback_subshlp
