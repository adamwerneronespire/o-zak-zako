*&---------------------------------------------------------------------*
*& Report  /ZAK/SZJA_STAPALV
*&---------------------------------------------------------------------*

REPORT  /ZAK/SZJA_STAPALV MESSAGE-ID /ZAK/ZAKO.

*&---------------------------------------------------------------------*
*& /ZAK/ANALITIKA list considering the Statistical flag,
*& only the last record per tax number is displayed.
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - Ness
*& Creation date     : 2010.04.09
*& Functional spec by:
*& SAP module name   : /ZAK/ZAKO
*& Program type      : Report
*& SAP version       : 5.0
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION       TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*

TYPE-POOLS: SLIS.
*Common ALV routines
INCLUDE /ZAK/ALV_LIST_FORMS.

*&---------------------------------------------------------------------*
*& TABLES                                                               *
*&---------------------------------------------------------------------*
TABLES: /ZAK/ANALITIKA.

*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                            *
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table      -   (I_xxx...)                              *
*      FORM parameter      -   ($xxxx...)                              *
*      Constant            -   (C_xxx...)                              *
*      Parameter variable  -   (P_xxx...)                              *
*      Selection option    -   (S_xxx...)                              *
*      Ranges              -   (R_xxx...)                              *
*      Global variables    -   (G_xxx...)                              *
*      Local variables     -   (L_xxx...)                              *
*      Work area           -   (W_xxx...)                              *
*      Type                -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Method              -   (METH_xxx...)                           *
*      Object              -   (O_xxx...)                              *
*      Class               -   (CL_xxx...)                             *
*      Event               -   (E_xxx...)                              *
*&---------------------------------------------------------------------*


DATA I_ANALITIKA     LIKE /ZAK/ANALITIKA OCCURS 0.
DATA I_ANALITIKA_ALV LIKE /ZAK/ANALITIKA OCCURS 0.

DATA: G_REPID LIKE SY-REPID.
DATA: GS_VARIANT  TYPE DISVARIANT.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
*General selections:
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*Company
PARAMETERS P_BUKRS LIKE /ZAK/ANALITIKA-BUKRS OBLIGATORY.
*Return type
PARAMETERS P_BTYPE LIKE /ZAK/ANALITIKA-BTYPE OBLIGATORY.
*Year
PARAMETERS P_GJAHR LIKE /ZAK/ANALITIKA-GJAHR OBLIGATORY.
*Month
PARAMETERS P_MONAT LIKE /ZAK/ANALITIKA-MONAT OBLIGATORY.
*Return sequence number within the period
SELECT-OPTIONS S_INDEX FOR /ZAK/ANALITIKA-ZINDEX NO-EXTENSION OBLIGATORY.
*ABEVAZ
SELECT-OPTIONS S_ABEVAZ FOR /ZAK/ANALITIKA-ABEVAZ.

SELECTION-SCREEN: END OF BLOCK BL01.

*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.

  MOVE SY-REPID TO G_REPID.
*++1765 #19.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD'  FIELD SY-TCODE.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
  ENDIF.
*--1765 #19.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*Filling the upper value
  IF S_INDEX-HIGH IS INITIAL.
    READ TABLE S_INDEX INDEX 1.
    S_INDEX-HIGH = S_INDEX-LOW.
    MODIFY S_INDEX INDEX 1.
  ENDIF.


*&--------------------------------------------------------------------*
*& AT SELECTION-SCREEN OUTPUT
*&--------------------------------------------------------------------*


*&--------------------------------------------------------------------*
*& START-OF-SELECTION
*&--------------------------------------------------------------------*
START-OF-SELECTION.

* Filtering data.
  PERFORM SELECT_DATA.


*&--------------------------------------------------------------------*
*& END-OF-SELECTION
*&--------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM ALV_LIST TABLES  I_ANALITIKA_ALV
                   USING  'I_ANALITIKA_ALV'.

*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_DATA.

  DATA LW_ANALITIKA     LIKE /ZAK/ANALITIKA.
  DATA LW_ANALITIKA_ALV LIKE /ZAK/ANALITIKA.
  DATA L_TABIX LIKE SY-TABIX.

  SELECT * INTO TABLE I_ANALITIKA
           FROM /ZAK/ANALITIKA
          WHERE BUKRS EQ P_BUKRS
            AND BTYPE EQ P_BTYPE
            AND GJAHR EQ P_GJAHR
            AND MONAT EQ P_MONAT
            AND ZINDEX IN S_INDEX
            AND ABEVAZ IN S_ABEVAZ.
* Building the ALV list
  SORT I_ANALITIKA.
  IF SY-SUBRC EQ 0.
    LOOP AT I_ANALITIKA INTO LW_ANALITIKA.
      LOOP AT I_ANALITIKA_ALV INTO LW_ANALITIKA_ALV
           WHERE    BUKRS   = LW_ANALITIKA-BUKRS
             AND    BTYPE   = LW_ANALITIKA-BTYPE
             AND    GJAHR   = LW_ANALITIKA-GJAHR
             AND    MONAT   = LW_ANALITIKA-MONAT
             AND    ABEVAZ  = LW_ANALITIKA-ABEVAZ
             AND    ADOAZON = LW_ANALITIKA-ADOAZON
             AND    ZINDEX  < LW_ANALITIKA-ZINDEX.
        LW_ANALITIKA_ALV-STAPO = 'X'.
        MODIFY I_ANALITIKA_ALV FROM LW_ANALITIKA_ALV TRANSPORTING STAPO.
      ENDLOOP.
      LW_ANALITIKA_ALV = LW_ANALITIKA.
      CLEAR LW_ANALITIKA_ALV-STAPO.
      APPEND LW_ANALITIKA_ALV TO I_ANALITIKA_ALV.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  LIST_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ALV  text
*      -->P_0128   text
*----------------------------------------------------------------------*
FORM ALV_LIST  TABLES   $TAB
                USING   $TAB_NAME.

  DATA LS_SORT TYPE SLIS_SORTINFO_ALV.

*Initialize the ALV list
  PERFORM COMMON_ALV_LIST_INIT USING SY-TITLE
                                     $TAB_NAME
                                     '/ZAK/SZJA_STAPALV'.

*Transform list header
  PERFORM COMMON_OWN_TOP_OF_PAGE USING GT_LIST_TOP_OF_PAGE[].

*Transform field catalog
  PERFORM COMMON_OWN_FIELDCAT USING GT_FIELDCAT[].

* Setting the variant

*Sorting
*  REFRESH GT_SORT.
*  CLEAR  LS_SORT.
*  LS_SORT-FIELDNAME = 'ZZIM_L1'.
*  LS_SORT-UP = 'X'.
* If it is detailed, subtotals are needed
  IF NOT P_RESZL IS INITIAL.
    LS_SORT-SUBTOT = 'X'.
  ENDIF.
*  LS_SORT-COMP = 'X'.
*
*  APPEND LS_SORT TO GT_SORT.

*ALV list
  PERFORM OWN_COMMON_ALV_GRID_DISPLAY TABLES $TAB
                                  USING  $TAB_NAME
                                         SPACE
                                         SPACE.

ENDFORM.                    " LIST_SPOOL


*---------------------------------------------------------------------*
*       FORM STATUS_SET                                               *
*---------------------------------------------------------------------*
*       Setting ALV list status - dynamic call!                       *
*---------------------------------------------------------------------*
*  -->  EXTAB                                                         *
*---------------------------------------------------------------------*
FORM STATUS_SET USING EXTAB TYPE SLIS_T_EXTAB.

*  SET PF-STATUS 'STANDARD' EXCLUDING S_TAB.

ENDFORM.   "FORM STATUS_SET

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ALV list call - with dynamic call!!
*---------------------------------------------------------------------*
*  -->  RF_UCOMM                                                      *
*  -->  SELFIELD                                                      *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING $UCOMM    LIKE SY-UCOMM
                        $SELFIELD TYPE SLIS_SELFIELD.
*  CASE $UCOMM.
*    WHEN .....
*
*  ENDCASE.

ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM END_OF_LIST.

ENDFORM.                    " END_OF_LIST


*&---------------------------------------------------------------------*
*&      Form  common_alv_grid_display
*&---------------------------------------------------------------------*
*       Displaying the ALV list
*        Same as the normal ALV list, but the display is in GRID format
*---------------------------------------------------------------------*
*  --> $i_table    internal table to be listed
*  --> $struc_name structure of the internal table (DDIC)
*  --> $pf_status  name of the FORM that sets the list status - can be space
*                   if the standard is fine. The specified FORM must be
*                   defined in the calling program!!
*  --> $user_command name of the FORM that provides list interactivity - can
*                    be space if the standard is fine. The specified FORM must
*                    be defined in the calling program!!
*----------------------------------------------------------------------*
FORM OWN_COMMON_ALV_GRID_DISPLAY TABLES $I_TABLE
                              USING VALUE($STRUC_NAME)
                                    VALUE($PF_STATUS)
                                    VALUE($USER_COMMAND).

* Initialize and fill list values
  L_REPID = SY-REPID.

* Calling the ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
            I_CALLBACK_PROGRAM       = L_REPID
            I_STRUCTURE_NAME         = $STRUC_NAME
            IS_LAYOUT                = GS_LAYOUT
            IT_FIELDCAT              = GT_FIELDCAT[]
            I_CALLBACK_PF_STATUS_SET = $PF_STATUS
            I_CALLBACK_USER_COMMAND  = $USER_COMMAND

*           IT_EXCLUDING            =
*           IT_SPECIAL_GROUPS       = GT_SP_GROUP[]
            IT_SORT                 = GT_SORT[]
*           IT_FILTER               =
*           IS_SEL_HIDE             =
*           i_default               = g_default
            I_SAVE                  =  'X' "saving variants
                                           "possible
            IS_VARIANT              = GS_VARIANT
            IT_EVENTS               = GT_EVENTS[]
*           IT_EVENT_EXIT           =
            IS_PRINT                = GS_PRINT
*           I_SCREEN_START_COLUMN   = 0
*           I_SCREEN_START_LINE     = 0
*           I_SCREEN_END_COLUMN     = 0
*           I_SCREEN_END_LINE       = 0
*      IMPORTING
*           E_EXIT_CAUSED_BY_CALLER =
       TABLES
            T_OUTTAB                = $I_TABLE.

ENDFORM.                    " common_alv_grid_display

*&---------------------------------------------------------------------*
*&      Form  common_own_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM COMMON_OWN_FIELDCAT USING  $GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: L_FCAT TYPE SLIS_FIELDCAT_ALV.

*  Transform catalog
*  LOOP AT $GT_FIELDCAT INTO L_FCAT.
*    MODIFY $GT_FIELDCAT FROM L_FCAT.
*  ENDLOOP.

ENDFORM.                    " common_own_fieldcat


*&---------------------------------------------------------------------*
*&      Form  COMMON_own_TOP_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM COMMON_OWN_TOP_OF_PAGE USING
                            $GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.

  DATA: L_LINE TYPE SLIS_LISTHEADER.
  DATA L_TEXT(80).

* Title
  READ TABLE $GT_LIST_TOP_OF_PAGE INTO L_LINE INDEX 1.
  L_LINE-TYP  = 'H'.
  L_LINE-KEY  = SPACE.
  MOVE L_TEXT TO L_LINE-INFO.
  MODIFY $GT_LIST_TOP_OF_PAGE FROM L_LINE INDEX 1.


ENDFORM.                    " COMMON_own_TOP_of_page
