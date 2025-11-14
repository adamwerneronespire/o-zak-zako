*&---------------------------------------------------------------------*
*& Report  /ZAK/READ_MIGR_XML
*&---------------------------------------------------------------------*

REPORT  /ZAK/READ_MIGR_XML MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: __________________
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor
*& Creation date     : 2016.07.18
*& Functional spec author: Balázs Gábor
*& SAP module name    : ADO
*& Program type       : ________
*& SAP version        : ________
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& CHANGES (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER                   DESCRIPTION
*& ----   ----------   ----------     ---------------------- -----------
INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE: /ZAK/READ_TOP.
INCLUDE EXCEL__C.
INCLUDE <ICON>.
CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*
TABLES: T001.

*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.
*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_CLASS TYPE DD02L-TABCLASS VALUE 'INTTAB',
           C_A TYPE C VALUE 'A'.
CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 9000.

*&---------------------------------------------------------------------*
*& Work area  (W_XXX..)                                           *
*&---------------------------------------------------------------------*
* structure check
DATA: W_DD02L TYPE DD02L.

*&---------------------------------------------------------------------*
*& INTERNAL TABLES  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*

* message
DATA: E_MESSAGE TYPE STANDARD TABLE OF BAPIRET2     INITIAL SIZE 0.
* message
DATA: W_MESSAGE TYPE BAPIRET2.
* data structure error
DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                    *
*      Ranges (Range)   -   (R_xxx...)                              *
*      Global variables   -   (V_xxx...)                              *
*      Work area        -   (W_xxx...)                              *
*      Type               -   (T_xxx...)                              *
*      Macros              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Object            -   (O_xxx...)                              *
*      Class             -   (CL_xxx...)                             *
*      Event             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA: V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.
DATA: V_BTYPART TYPE /ZAK/BTYPART.

DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
      V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.

DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
DATA: W_OUTTAB  TYPE /ZAK/ANALITIKA.

* Error data structure table
DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
* ALV control variables
DATA: V_OK_CODE LIKE SY-UCOMM,
      V_SAVE_OK LIKE SY-UCOMM,
      V_REPID LIKE SY-REPID,
      V_CONTAINER   TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
      V_CONTAINER2  TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',

      V_GRID   TYPE REF TO CL_GUI_ALV_GRID,
      V_GRID2  TYPE REF TO CL_GUI_ALV_GRID,

      V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      V_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

      I_FIELDCAT   TYPE LVC_T_FCAT,
      I_FIELDCAT2  TYPE LVC_T_FCAT,

      V_LAYOUT     TYPE LVC_S_LAYO,
      V_LAYOUT2    TYPE LVC_S_LAYO,

      V_VARIANT    TYPE DISVARIANT,
      V_VARIANT2   TYPE DISVARIANT,

      V_TOOLBAR      TYPE STB_BUTTON,
      V_DYNDOC_ID    TYPE REF TO CL_DD_DOCUMENT,
V_EVENT_RECEIVER  TYPE REF TO LCL_EVENT_RECEIVER,
V_EVENT_RECEIVER2 TYPE REF TO LCL_EVENT_RECEIVER,
V_STRUC     TYPE DD02L-TABNAME.
* for popup message
DATA: V_TEXT1(40) TYPE C,
      V_TEXT2(40) TYPE C,
      V_TITEL     TYPE C,
      V_ANSWER.
* file validation
DATA: LV_ACTIVE TYPE ABAP_BOOL.
DATA: V_WNUM(30) TYPE N,
      V_WAERS LIKE T001-WAERS.

*++BG 2007.02.12
DATA: V_XLS_LINE TYPE SY-TABIX VALUE 5000.
*--BG 2007.02.12

* field symbol
FIELD-SYMBOLS <FS> TYPE ANY.

*++0002 BG 2007.07.02
* Macro definition for filling ranges
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  APPEND &1.
END-OF-DEFINITION.
*--0002 BG 2007.07.02
*++1765 #04.
DATA V_ONREV TYPE XFELD.
*--1765 #04.

*&---------------------------------------------------------------------*
*& PARAMETERS  (P_XXXXXXX..)                                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SELECT-OPTIONS (S_XXXXXXX..)                                        *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-A01.
PARAMETERS: P_BUKRS LIKE /ZAK/BEVALL-BUKRS
*                         T001-BUKRS
                         VALUE CHECK
                         OBLIGATORY MEMORY ID BUK.

SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BUTXT LIKE T001-BUTXT MODIF ID OUT.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) TEXT-A02.
PARAMETERS: P_BTYPE  LIKE /ZAK/BEVALL-BTYPE OBLIGATORY.
*                         MATCHCODE OBJECT /ZAK/BEV

SELECTION-SCREEN POSITION 50.
PARAMETERS: P_BTEXT  TYPE VAL_TEXT MODIF ID OUT.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BEVD
                                                   OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B02.
SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-B03.

PARAMETERS: P_FDIR LIKE FC03TAB-PL00_FILE          OBLIGATORY,
            P_TESZT AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK B03.
SELECTION-SCREEN END OF BLOCK B01.
****************************************************************
* LOCAL CLASSES: Definition
****************************************************************
*===============================================================
* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition:
* ~~~~~~~~~~~
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.


    CLASS-METHODS:
     HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
            IMPORTING E_OBJECT E_INTERACTIVE,

   HANDLE_USER_COMMAND
       FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
           IMPORTING E_UCOMM,
* top-of-page
    HANDLE_TOP_OF_PAGE
        FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
            IMPORTING E_DYNDOC_ID,
* this writes to the screen
    HANDLE_END_OF_PAGE
        FOR EVENT PRINT_END_OF_PAGE OF CL_GUI_ALV_GRID.


  PRIVATE SECTION.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*
* lcl_event_receiver (Definition)
*===============================================================

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class lcl_event_receiver (Implementation)
*
*
CLASS  LCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD HANDLE_TOOLBAR.
* append a separator to normal toolbar
    CLEAR V_TOOLBAR.
    MOVE 1 TO V_TOOLBAR-BUTN_TYPE.
    APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* append a menut o switch between detail levels.
    CLEAR V_TOOLBAR.
    MOVE '/ZAK/HIBA' TO V_TOOLBAR-FUNCTION.
* --> This function code is evaluated in 'handle_menu_button'
    MOVE ICON_DISPLAY TO V_TOOLBAR-ICON.
    MOVE 'Hibanapló' TO V_TOOLBAR-QUICKINFO.
    MOVE 'Hibanapló' TO V_TOOLBAR-TEXT.
    MOVE 0 TO V_TOOLBAR-BUTN_TYPE.
    MOVE SPACE TO V_TOOLBAR-DISABLED.
    APPEND V_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
  ENDMETHOD.                    "HANDLE_TOOLBAR

*-------------------------------------------------------------------
  METHOD HANDLE_USER_COMMAND.
* § 3.In event handler method for event USER_COMMAND: Query your
*   function codes defined in step 2 and react accordingly.

    DATA: I_ROWS TYPE LVC_T_ROW,
          W_ROWS TYPE LVC_S_ROW,
          S_OUT  TYPE /ZAK/ANALITIKA.

    CASE E_UCOMM.
* Display analytics
      WHEN '/ZAK/HIBA'.
        IF I_HIBA[] IS INITIAL.
          MESSAGE I005 .
        ELSE.
          CALL SCREEN 9001.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
*-----------------------------------------------------------------
  METHOD HANDLE_TOP_OF_PAGE.
    WRITE:/'teszt'.
  ENDMETHOD.                           "handle_user_command
*-----------------------------------------------------------------
  METHOD HANDLE_END_OF_PAGE.
    WRITE:/'tesztelek'.

  ENDMETHOD.                           "handle_end_of_page
*-------------------------------------------

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================


*-----------------------------------------------------------------------
*       INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
* descriptions
  PERFORM FIELD_DESCRIPT.
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

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
************************************************************************
AT SELECTION-SCREEN.
* descriptions
  PERFORM FIELD_DESCRIPT(/ZAK/READ_FILE).
  PERFORM CHECK_PARAMS .
*  Company code check in file name
  PERFORM CHECK_BUKRS_FILENAME.

************************************************************************
* AT SELECTION-SCREEN output
************************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIF_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FDIR.
  PERFORM FILENAME_GET USING P_FDIR.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
* determine return type
  PERFORM READ_BEVALL USING P_BUKRS
                            P_BTYPE.
*  Authorization check
  PERFORM AUTHORITY_CHECK USING P_BUKRS
                                W_/ZAK/BEVALL-BTYPART
                                C_ACTVT_01.
* read control tables
  PERFORM READ_CUST_TABLE USING P_BUKRS
                                P_BTYPE
                                P_BSZNUM.

  CLEAR: V_TYPE,V_STRNAME.
* Determine data structure and check its existence
  PERFORM CHECK_BEVALLD USING P_BUKRS
                              P_BTYPE
                              P_BSZNUM
                     CHANGING V_TYPE
                              V_STRNAME.
  CASE W_/ZAK/BEVALL-BTYPART.
    WHEN C_BTYPART_ONYB.
      CALL FUNCTION '/ZAK/XML_ONYB_UPLOAD'
        EXPORTING
          FILENAME        = P_FDIR
          I_BUKRS         = P_BUKRS
          I_BTYPE         = P_BTYPE
          I_BSZNUM        = P_BSZNUM
        TABLES
          T_/ZAK/ANALITIKA = I_OUTTAB
          T_HIBA          = I_HIBA
        EXCEPTIONS
          ERROR_OPEN_FILE = 1
          ERROR_XML       = 2
          EMPTY_FILE      = 3
          OTHERS          = 4.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
*++1765 #01.
    WHEN C_BTYPART_AFA.
      CALL FUNCTION '/ZAK/XML_AFA_UPLOAD'
        EXPORTING
          FILENAME        = P_FDIR
          I_BUKRS         = P_BUKRS
          I_BTYPE         = P_BTYPE
          I_BSZNUM        = P_BSZNUM
*++1765 #04.
        IMPORTING
          E_ONREV         = V_ONREV
*--1765 #04.
        TABLES
          T_/ZAK/ANALITIKA = I_OUTTAB
          T_HIBA          = I_HIBA
        EXCEPTIONS
          ERROR_OPEN_FILE = 1
          ERROR_XML       = 2
          EMPTY_FILE      = 3
          OTHERS          = 4.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
*--1765 #01.
  ENDCASE.
* Database table update
  IF I_HIBA[] IS INITIAL.
*  Check, database modification. Test vs. Production
    PERFORM PROCESS_IND(/ZAK/READ_FILE) USING TEXT-P04.
    PERFORM UPD_DATA USING P_TESZT.
  ENDIF.

************************************************************************
* END-OF-SELECTION
***********************************************************************
END-OF-SELECTION.

  PERFORM PROCESS_IND(/ZAK/READ_FILE) USING TEXT-P05.

  SORT I_OUTTAB BY ITEM.
*  GRID maximum row limit
  PERFORM GET_ALV_GRID_LINE(/ZAK/READ_FILE) TABLES I_OUTTAB.

  PERFORM ALV_LIST.


*&---------------------------------------------------------------------*
*&      Form  FIELD_DESCRIPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_DESCRIPT .
  IF NOT P_BUKRS IS INITIAL.
    SELECT SINGLE *  FROM T001
          WHERE BUKRS = P_BUKRS.
    P_BUTXT = T001-BUTXT.
*    _WAERS = T001-WAERS.
  ENDIF.

  IF NOT P_BTYPE IS INITIAL.
    SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
        WHERE LANGU = SY-LANGU
          AND BUKRS = P_BUKRS
          AND BTYPE = P_BTYPE.
  ENDIF.
*  IF NOT P_BPART IS INITIAL.
*    SELECT SINGLE DDTEXT INTO P_BTEXT FROM DD07T
*       WHERE DOMNAME = '/ZAK/BTYPART'
*         AND DDLANGUAGE = SY-LANGU
*         AND DOMVALUE_L = P_BPART.
*  ENDIF.

ENDFORM.                    " FIELD_DESCRIPT
*&---------------------------------------------------------------------*
*&      Form  MODIF_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIF_SCREEN .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'DIS'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 1.
    ELSEIF SCREEN-GROUP1 = 'OUT'.
      SCREEN-INPUT = 0.
      SCREEN-OUTPUT = 1.
      SCREEN-DISPLAY_3D = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " MODIF_SCREEN
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILENAME_GET USING $FILE.

  DATA L_EXTENSION TYPE STRING.
  DATA L_TITLE     TYPE STRING.
  DATA L_FILE      TYPE STRING.
  DATA L_FULLPATH  TYPE STRING.
  DATA L_MASK(20)  TYPE C VALUE ',*.XML  ,*.xml.'.
  DATA L_FILTER TYPE STRING.

  L_TITLE = SY-TITLE.
*  L_EXTENSION = L_MASK.
  L_FILTER = '*.XML'.

  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      WINDOW_TITLE      = L_TITLE
*     DEFAULT_EXTENSION = L_EXTENSION
*     DEFAULT_FILE_NAME =
*     WITH_ENCODING     =
      FILE_FILTER       = L_FILTER
*     INITIAL_DIRECTORY =
    IMPORTING
*     FILENAME          = L_FILE
*     PATH              =
      FULLPATH          = L_FULLPATH
*     USER_ACTION       =
*     FILE_ENCODING     =
    .
  $FILE = L_FULLPATH.


ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  CHECK_PARAMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_PARAMS .
  DATA:
    LV_FILENAME   TYPE LOCALFILE,
    LV_SUBRC      LIKE SY-SUBRC,
    LV_FULLNAME   TYPE LOCALFILE,
    LV_STRING     TYPE STRING.
  DATA: L_RET.

*++0001 2007.01.03 BG (FMC)
  CALL FUNCTION '/ZAK/USER_DEFAULT'
    EXPORTING
      USERS      = SY-UNAME
    EXCEPTIONS
      ERROR_DATF = 1
      OTHERS     = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*--0001 2007.01.03 BG (FMC)


  IF NOT P_BUKRS IS INITIAL AND
     NOT P_BTYPE IS INITIAL.
    SELECT SINGLE BTYPE BTYPART INTO (V_BTYPE, V_BTYPART)
                                FROM /ZAK/BEVALL
                        WHERE BUKRS EQ P_BUKRS AND
                              BTYPE EQ P_BTYPE .
    IF SY-SUBRC NE 0.
      MESSAGE E109 WITH P_BTYPE P_BUKRS  .
*     The & return type does not exist in company &!
*++1765 #01.
*    ELSEIF  V_BTYPART NE C_BTYPART_ONYB.
*      MESSAGE E310.
**   Please provide an ONYB return type identifier!
    ELSEIF  V_BTYPART NE C_BTYPART_ONYB AND V_BTYPART NE C_BTYPART_AFA.
      MESSAGE E364.
*   Please provide an ONYB or VAT return type!
*--1765 #01.
    ENDIF.
    CLEAR: W_/ZAK/BEVALLD.
*     IF NOT P_ISMET IS INITIAL AND
*        NOT P_PACK IS INITIAL AND
*        NOT P_BSZNUM IS INITIAL.
*       SELECT SINGLE * FROM /ZAK/BEVALLSZ
*              WHERE BUKRS  EQ P_BUKRS AND
*                    BTYPE  EQ P_BTYPE AND
*                    BSZNUM EQ P_BSZNUM AND
*                    PACK   EQ P_PACK.
*       IF SY-SUBRC NE 0.
*         MESSAGE E067 WITH P_PACK P_BSZNUM..
*       ENDIF.
*     ENDIF.
    SELECT SINGLE * INTO W_/ZAK/BEVALLD
             FROM /ZAK/BEVALLD
            WHERE BUKRS  EQ P_BUKRS AND
                  BTYPE  EQ P_BTYPE AND
                  BSZNUM EQ P_BSZNUM.
    IF SY-SUBRC NE 0 OR W_/ZAK/BEVALLD-PROGRAMM NE SY-REPID.
      MESSAGE E029 WITH P_BSZNUM.
*   This program cannot be used for the & data provision!
    ENDIF.
  ENDIF.

  DATA L_FILE TYPE STRING.
  DATA L_RESULT TYPE C.
  MOVE P_FDIR TO L_FILE.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE            = L_FILE
    RECEIVING
      RESULT          = L_RESULT
    EXCEPTIONS
      CNTL_ERROR      = 1
      ERROR_NO_GUI    = 2
      WRONG_PARAMETER = 3
      OTHERS          = 4.
  MOVE L_RESULT TO L_RET.
  CONDENSE L_RET NO-GAPS.
  IF L_RET EQ SPACE.
*   The specified file (&) cannot be opened!
    MESSAGE E004(/ZAK/ZAK) WITH P_FDIR.
  ENDIF.


ENDFORM.                    " CHECK_PARAMS
*&---------------------------------------------------------------------*
*&      Form  READ_BEVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_BEVALL USING    $BUKRS
                          $BTYPE.
* one return type belongs to only one return category, so
* examining the first entry is enough when determining the return category!
  SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
                       WHERE BUKRS EQ $BUKRS AND
                             BTYPE EQ $BTYPE.


ENDFORM.                    " READ_BEVALL
*&---------------------------------------------------------------------*
*&      Form  read_cust_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
FORM READ_CUST_TABLE USING    $BUKRS  LIKE T001-BUKRS
                              $BTYPE  LIKE /ZAK/BEVALL-BTYPE
                              $BSZNUM LIKE /ZAK/BEVALLD-BSZNUM.
* Return data provision uploads!
  SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
                            WHERE BUKRS  EQ $BUKRS AND
                                  BTYPE  EQ $BTYPE AND
                                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
*   MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
  ENDIF.

* Determine data structure-field mapping
  SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
                            WHERE BTYPE EQ $BTYPE AND
                                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
*     MESSAGE E010 WITH $BUKRS $BTYPE .
  ENDIF.
*

ENDFORM.                    " read_cust_table

*&---------------------------------------------------------------------*
*&      Form  check_bevalld
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*      -->P_P_BSZNUM  text
*      -->P_P_TYPE    text
*      -->P_P_SRNAME  text
*----------------------------------------------------------------------*
FORM CHECK_BEVALLD USING    $BUKRS LIKE T001-BUKRS
                            $BTYPE LIKE /ZAK/BEVALLD-BTYPE
                            $BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
                   CHANGING $TYPE LIKE /ZAK/BEVALLD-FILETYPE
                            $STRNAME LIKE /ZAK/BEVALLD-STRNAME.

  CLEAR: W_/ZAK/BEVALLD.
* Data structure determination
  SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
                  WHERE BUKRS  EQ $BUKRS AND
                  BTYPE  EQ $BTYPE AND
                  BSZNUM EQ $BSZNUM.
  IF SY-SUBRC NE 0.
    MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
  ELSE.
    IF W_/ZAK/BEVALLD-FILETYPE EQ '04'.
* SAP data provision is currently not permitted!
      MESSAGE E006.
    ENDIF.

*++2007.01.11 BG (FMC)
    IF NOT W_/ZAK/BEVALLD-XSPEC IS INITIAL.
      MESSAGE E205 WITH $BSZNUM.
*   & data provision is set to special! (/ZAK/BEVALLD)
    ENDIF.
*--2007.01.11 BG (FMC)

    $STRNAME = W_/ZAK/BEVALLD-STRNAME.
    $TYPE    = W_/ZAK/BEVALLD-FILETYPE.

* No structure is needed for XML format
    IF  W_/ZAK/BEVALLD-FILETYPE NE '03'.
** Check that the data structure exists!
*      SELECT SINGLE * INTO W_DD02L FROM DD02L
*                      WHERE TABNAME  EQ W_/ZAK/BEVALLD-STRNAME AND
*                            AS4LOCAL EQ C_A AND
*                            TABCLASS EQ C_CLASS.
** Activated?
*      IF SY-SUBRC NE 0.
*        MESSAGE E050 WITH W_/ZAK/BEVALLD-STRNAME .
*      ENDIF.
      MESSAGE E311.
*   Please select only XML-type data provision identifiers!
    ENDIF.
  ENDIF.
ENDFORM.                    " check_bevalld
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BUKRS_FILENAME.

  DATA: BEGIN OF L_SPLIT OCCURS 0,
        LINE(80),
        END OF L_SPLIT.
  DATA  L_LINES TYPE I.
  DATA  L_LENGTH TYPE I.


*  Split the file path.
  SPLIT P_FDIR AT '\' INTO TABLE L_SPLIT.

*  The last part will be the file name.
  DESCRIBE TABLE L_SPLIT LINES L_LINES.
  READ TABLE L_SPLIT INDEX L_LINES.

*  Determine the company code length
  L_LENGTH = STRLEN( P_BUKRS ).

*  If the file name does not start with the company code:
  IF L_SPLIT-LINE(L_LENGTH) NE P_BUKRS.
    MESSAGE E194 WITH P_BUKRS.
*   Invalid file! The file name does not start with the company code! (&1)
  ENDIF.


ENDFORM.                    " CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*&      Form  upd_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TESZT  text
*----------------------------------------------------------------------*
FORM UPD_DATA USING $TESZT.

  DATA L_TEXTLINE1(80).
  DATA L_TEXTLINE2(80).
  DATA L_DIAGNOSETEXT1(80).
  DATA L_DIAGNOSETEXT2(80).
  DATA L_DIAGNOSETEXT3(80).
  DATA L_TITLE(40).
  DATA L_ANSWER.
  DATA L_PACK LIKE /ZAK/ANALITIKA-PACK.

*++ TELENOR PTGSZLAA 2014.03.04 BG (Ness)
  DATA: L_FILE LIKE FC03TAB-PL00_FILE.
  DATA: L_FILE_FROM  LIKE FC03TAB-PL00_FILE.
  DATA: L_PARAM LIKE SXPGCOLIST-PARAMETERS.
  DATA: LI_TAB TYPE TABLE OF STRING WITH HEADER LINE.
  DATA: L_TABIX LIKE SY-TABIX.
*-- TELENOR PTGSZLAA 2014.03.04 BG (Ness)

  IF I_OUTTAB[] IS INITIAL.
    MESSAGE I031.
*    The database does not contain any records to process!
    EXIT.
  ENDIF.


*  Always run in test first
  CALL FUNCTION '/ZAK/UPDATE'
    EXPORTING
      I_BUKRS     = P_BUKRS
      I_BTYPE     = P_BTYPE
*++1365 #11.
*     We also provide BTYPART and then
*     the function determines which BTYPE belongs to it
*     so one file can contain data for multiple years.
      I_BTYPART   = W_/ZAK/BEVALL-BTYPART
*--1365 #11.
      I_BSZNUM    = P_BSZNUM
*       I_PACK      = P_PACK
      I_GEN       = 'X'
      I_TEST      = 'X'
      I_FILE      = P_FDIR
    TABLES
      I_ANALITIKA = I_OUTTAB
*++1365 2013.01.22 Balázs Gábor (Ness)
      I_AFA_SZLA  = I_/ZAK/AFA_SZLA
*--1365 2013.01.22 Balázs Gábor (Ness)
      E_RETURN    = E_MESSAGE.

*   Message handling
  IF NOT E_MESSAGE[] IS INITIAL.
    CALL FUNCTION '/ZAK/MESSAGE_SHOW'
      TABLES
        T_RETURN = E_MESSAGE.
  ENDIF.

*  If it is not a test run, check whether there is an ERROR
  IF NOT $TESZT IS INITIAL.
    LOOP AT E_MESSAGE INTO W_MESSAGE WHERE TYPE CA 'EA'.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
      MESSAGE E062.
*     Data upload is not possible!
    ENDIF.
  ENDIF.

*  Production run but there is a warning instead of ERROR, ask whether to continue
  IF $TESZT IS INITIAL.
    IF NOT E_MESSAGE[] IS INITIAL.
*    Load texts
      MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
      MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                           TO L_DIAGNOSETEXT1.
      MOVE 'Folytatja  feldolgozást?'(003)
                                           TO L_TEXTLINE1.


      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
        EXPORTING
          DEFAULTOPTION = 'N'
          DIAGNOSETEXT1 = L_DIAGNOSETEXT1
          TEXTLINE1     = L_TEXTLINE1
          TITEL         = L_TITLE
          START_COLUMN  = 25
          START_ROW     = 6
        IMPORTING
          ANSWER        = L_ANSWER.
*    Otherwise proceed
    ELSE.
      MOVE 'J' TO L_ANSWER.
    ENDIF.

*    The database modification may continue
    IF L_ANSWER EQ 'J'.
*++1765 #04.
*    If this is a self-revision, open the base periods
      IF NOT V_ONREV IS INITIAL.
        CLEAR    W_/ZAK/BEVALLI.
        REFRESH  I_/ZAK/BEVALLD.
        READ TABLE I_OUTTAB INTO W_OUTTAB INDEX 1.
        SELECT * INTO TABLE I_/ZAK/BEVALLD
                 FROM /ZAK/BEVALLD
                WHERE BUKRS EQ W_OUTTAB-BUKRS
                  AND BTYPE EQ W_OUTTAB-BTYPE.
        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING W_OUTTAB TO W_/ZAK/BEVALLI.
          W_/ZAK/BEVALLI-ZINDEX = '000'.
          W_/ZAK/BEVALLI-FLAG = 'Z'.
          W_/ZAK/BEVALLI-DATUM = SY-DATUM.
          W_/ZAK/BEVALLI-UZEIT = SY-UZEIT.
          W_/ZAK/BEVALLI-UNAME = SY-UNAME.
          MODIFY /ZAK/BEVALLI FROM W_/ZAK/BEVALLI.
          LOOP AT I_/ZAK/BEVALLD INTO W_/ZAK/BEVALLD.
            CLEAR W_/ZAK/BEVALLSZ.
            MOVE-CORRESPONDING W_/ZAK/BEVALLI TO W_/ZAK/BEVALLSZ.
            W_/ZAK/BEVALLSZ-BSZNUM = W_/ZAK/BEVALLD-BSZNUM.
            MODIFY /ZAK/BEVALLSZ FROM W_/ZAK/BEVALLSZ.
          ENDLOOP.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
*--1765 #04.
*      Modify data
      CALL FUNCTION '/ZAK/UPDATE'
        EXPORTING
          I_BUKRS     = P_BUKRS
          I_BTYPE     = P_BTYPE
*++1365 #11.
*          We also provide BTYPART and then
*          the function determines which BTYPE belongs to it
*          so one file can contain data for multiple years.
          I_BTYPART   = W_/ZAK/BEVALL-BTYPART
*--1365 #11.
          I_BSZNUM    = P_BSZNUM
*          I_PACK      = P_PACK
          I_GEN       = 'X'
          I_TEST      = $TESZT
          I_FILE      = P_FDIR
        TABLES
          I_ANALITIKA = I_OUTTAB
*++1365 2013.01.22 Balázs Gábor (Ness)
          I_AFA_SZLA  = I_/ZAK/AFA_SZLA
*--1365 2013.01.22 Balázs Gábor (Ness)
          E_RETURN    = E_MESSAGE.
*
      READ TABLE I_OUTTAB INTO W_OUTTAB INDEX 1.
      MOVE W_OUTTAB-PACK TO L_PACK.
      MESSAGE I033 WITH L_PACK.
*      Upload completed with package number &!
**++PTGSZLAA 2014.03.04 BG (Ness)
**      Move the file to the ....\old\<filename> directory
*      IF NOT P_APPL IS INITIAL.
*        REFRESH LI_TAB.
*        CLEAR: L_FILE, L_FILE_FROM.
*        MOVE P_FDIR TO L_FILE_FROM.
*        SPLIT P_FDIR AT '\' INTO TABLE LI_TAB.
*        DESCRIBE TABLE LI_TAB LINES L_TABIX.
*        LI_TAB = 'old'.
*        INSERT LI_TAB INDEX L_TABIX.
*        L_FILE = '\'.
*        LOOP AT LI_TAB.
*          IF NOT LI_TAB IS INITIAL.
*            CONCATENATE L_FILE LI_TAB INTO L_FILE SEPARATED BY '\'.
*          ENDIF.
*        ENDLOOP.
*        CLEAR L_PARAM.
*        CONCATENATE L_FILE_FROM L_FILE INTO L_PARAM SEPARATED BY SPACE.
*        CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
*          EXPORTING
*            COMMANDNAME                   = 'YMOVE'
*            ADDITIONAL_PARAMETERS         = L_PARAM
*          EXCEPTIONS
*            NO_PERMISSION                 = 1
*            COMMAND_NOT_FOUND             = 2
*            PARAMETERS_TOO_LONG           = 3
*            SECURITY_RISK                 = 4
*            WRONG_CHECK_CALL_INTERFACE    = 5
*            PROGRAM_START_ERROR           = 6
*            PROGRAM_TERMINATION_ERROR     = 7
*            X_ERROR                       = 8
*            PARAMETER_EXPECTED            = 9
*            TOO_MANY_PARAMETERS           = 10
*            ILLEGAL_COMMAND               = 11
*            WRONG_ASYNCHRONOUS_PARAMETERS = 12
*            CANT_ENQ_TBTCO_ENTRY          = 13
*            JOBCOUNT_GENERATION_ERROR     = 14
*            OTHERS                        = 15.
*        IF SY-SUBRC NE 0.
*          MESSAGE I902 WITH P_FDIR.
**           Error while moving file & into the "OLD" directory!
*        ENDIF.
*      ENDIF.
*--TGSZLAA 2014.03.04 BG (Ness)

    ENDIF.
  ENDIF.

ENDFORM.                    " upd_data
*&---------------------------------------------------------------------*
*&      Form  ALV_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_LIST.
*++1565 #03.
  IF SY-BATCH IS INITIAL.
*--1565 #03.
* ALV lista
    CALL SCREEN 9000.
*++1565 #03.
  ELSEIF NOT I_HIBA[] IS INITIAL.
    LOOP AT I_HIBA INTO W_HIBA.
      MESSAGE I000 WITH W_HIBA-ZA_HIBA W_HIBA-/ZAK/F_VALUE
                        W_HIBA-TABNAME W_HIBA-FIELDNAME.
*     & & & &
    ENDLOOP.
    MESSAGE E101.
*    Data upload aborted!
  ENDIF.
*--1565 #03.
ENDFORM.                    " ALV_LIST
*&---------------------------------------------------------------------
*
*&      Form  process_ind
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_IND USING $TEXT.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      TEXT       = $TEXT.

ENDFORM.                    " process_ind
*&---------------------------------------------------------------------*
*&      Module  PBO9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO9000 OUTPUT.
  PERFORM SET_STATUS.
  DATA: L_NAME(20) TYPE C,
        W_RETURN LIKE BAPIRET2.
  IF V_CUSTOM_CONTAINER IS INITIAL.
* the SAP structure of the data definition must be taken from the /ZAK/BEVALLD-strname table
* must be used
    PERFORM CREATE_AND_INIT_ALV CHANGING I_OUTTAB[]
                                         I_FIELDCAT
                                         V_LAYOUT
                                         V_VARIANT.
    IF NOT I_HIBA[] IS INITIAL.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
        EXPORTING
          TITEL     = 'Figyelem'
          TEXTLINE1 = 'Létezik Hibanapló!'.
    ENDIF.
*     IF NOT E_MESSAGE[] IS INITIAL.
** Display messages!
*       CALL FUNCTION '/ZAK/MESSAGE_SHOW'
*            TABLES
*                 T_RETURN = E_MESSAGE.
*
*     ENDIF.
  ENDIF.

ENDMODULE.                 " PBO9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI9000 INPUT.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.
    WHEN '/ZAK/HIBA'.
      SET PF-STATUS 'MAIN9001' .
      SET TITLEBAR 'MAIN9001'.
      CALL SCREEN 9001.
* Back
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
* Exit
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.

    WHEN OTHERS.
*     do nothing
  ENDCASE.

ENDMODULE.                 " PAI9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_STATUS.
  TYPES: BEGIN OF TAB_TYPE,
          FCODE LIKE RSMPE-FUNC,
        END OF TAB_TYPE.

  DATA: TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
        WA_TAB TYPE TAB_TYPE.
* analytics structure display
  IF SY-DYNNR = '9000'.
    SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
    SET TITLEBAR  'MAIN'.
  ELSE.
    SET PF-STATUS 'MAIN9001' EXCLUDING TAB.
    SET TITLEBAR 'MAIN9001'.
  ENDIF.
ENDFORM.                    " set_status
*&---------------------------------------------------------------------*
*&      Form  create_and_init_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_OUTTAB[]  text
*      <--P_I_FIELDCAT  text
*      <--P_V_LAYOUT  text
*      <--P_V_VARIANT  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV CHANGING  PT_OUTTAB LIKE I_OUTTAB[]
                                   PT_FIELDCAT TYPE LVC_T_FCAT
                                   PS_LAYOUT   TYPE LVC_S_LAYO
                                   PS_VARIANT  TYPE DISVARIANT.

  DATA: I_EXCLUDE TYPE UI_FUNCTIONS.

*  GRID maximum row limit
  PERFORM GET_ALV_GRID_LINE TABLES PT_OUTTAB.



  CREATE OBJECT V_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = V_CONTAINER.
  CREATE OBJECT V_GRID
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER.

* Build field catalog
  PERFORM BUILD_FIELDCAT USING    SY-DYNNR
                         CHANGING PT_FIELDCAT.

  PS_LAYOUT-CWIDTH_OPT = 'X'.

  CLEAR PS_VARIANT.
  PS_VARIANT-REPORT = V_REPID.
  CALL METHOD V_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = PS_VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = 'X'
      IS_LAYOUT            = PS_LAYOUT
      IT_TOOLBAR_EXCLUDING = I_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = PT_FIELDCAT
      IT_OUTTAB            = PT_OUTTAB.

  CREATE OBJECT V_EVENT_RECEIVER.
  SET HANDLER V_EVENT_RECEIVER->HANDLE_TOOLBAR       FOR V_GRID.
  SET HANDLER V_EVENT_RECEIVER->HANDLE_USER_COMMAND  FOR V_GRID.

* raise event TOOLBAR:
  CALL METHOD V_GRID->SET_TOOLBAR_INTERACTIVE.

ENDFORM.                    " create_and_init_alv
*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT USING    P_DYNNR     LIKE SYST-DYNNR
                    CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA: S_FCAT TYPE LVC_S_FCAT.

  V_STRUC = V_STRNAME.
* /ZAK/ANALITIKA table
  IF P_DYNNR = '9000'.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = PT_FIELDCAT.

* too many fields in the display
    LOOP AT PT_FIELDCAT INTO S_FCAT.
      IF S_FCAT-FIELDNAME = 'XMANU' OR
      S_FCAT-FIELDNAME = 'XDEFT' OR
      S_FCAT-FIELDNAME = 'VORSTOR' OR
      S_FCAT-FIELDNAME = 'STAPO' OR
      S_FCAT-FIELDNAME = 'DMBTR' OR
      S_FCAT-FIELDNAME = 'WAERS' OR
*       S_FCAT-FIELDNAME = 'KOSTL' OR
      S_FCAT-FIELDNAME = 'ZCOMMENT' OR
      S_FCAT-FIELDNAME = 'BSEG_GJAHR' OR
*       S_FCAT-FIELDNAME = 'BSEG_BELNR' OR
      S_FCAT-FIELDNAME = 'BSEG_BUZEI' OR
      S_FCAT-FIELDNAME = 'BOOK' OR
      S_FCAT-FIELDNAME = 'KMONAT' OR
      S_FCAT-FIELDNAME = 'KTOSL' OR
      S_FCAT-FIELDNAME = 'MWSKZ' OR
      S_FCAT-FIELDNAME = 'KBETR' OR
      S_FCAT-FIELDNAME = 'BLART' OR
      S_FCAT-FIELDNAME = 'BUDAT' OR
      S_FCAT-FIELDNAME = 'BLDAT' OR
      S_FCAT-FIELDNAME = 'ZFBDT' OR
*       S_FCAT-FIELDNAME = 'HKONT' OR
      S_FCAT-FIELDNAME = 'LIFKUN' OR
      S_FCAT-FIELDNAME = 'STCEG' OR
      S_FCAT-FIELDNAME = 'XBLNR' OR
      S_FCAT-FIELDNAME = 'LWBAS' OR
      S_FCAT-FIELDNAME = 'LWSTE' OR
      S_FCAT-FIELDNAME = 'KOART' OR
      S_FCAT-FIELDNAME = 'HWBAS' OR
      S_FCAT-FIELDNAME = 'FWBAS' OR
      S_FCAT-FIELDNAME = 'UMSKZ' OR
      S_FCAT-FIELDNAME = 'BSCHL' OR
      S_FCAT-FIELDNAME = 'AUGDT' OR
      S_FCAT-FIELDNAME = 'HWSTE' OR
      S_FCAT-FIELDNAME = 'FWSTE' OR
      S_FCAT-FIELDNAME = 'HWBTR' OR
      S_FCAT-FIELDNAME = 'FWBTR' OR
      S_FCAT-FIELDNAME = 'FWAERS'.

*       S_FCAT-FIELDNAME = 'AUFNR'.
        S_FCAT-NO_OUT = 'X'.
      ENDIF.
      MODIFY PT_FIELDCAT FROM S_FCAT.
    ENDLOOP.

  ELSE.
* error table
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = '/ZAK/ADAT_HIBA'
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = PT_FIELDCAT.
  ENDIF.
ENDFORM.                    " build_fieldcat
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM.
  LEAVE PROGRAM.
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  check_fieldtyp
*&---------------------------------------------------------------------*
*       text
*&---------------------------------------------------------------------*
*&      Module  mod_screen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOD_SCREEN OUTPUT.
  READ TABLE I_OUTTAB INTO W_/ZAK/ANALITIKA INDEX 1.
  /ZAK/BEVALLD-BTYPE = P_BTYPE.
  /ZAK/BEVALLD-BSZNUM = P_BSZNUM.
  /ZAK/BEVALLD-BUKRS  = P_BUKRS.
  /ZAK/BEVALLP-PACK   = W_/ZAK/ANALITIKA-PACK.
  /ZAK/BEVALLP-ZFILE   = P_FDIR.


ENDMODULE.                 " mod_screen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_9001 OUTPUT.
  PERFORM SET_STATUS.

  IF V_CUSTOM_CONTAINER2 IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV2 CHANGING I_HIBA[]
                                          I_FIELDCAT2
                                          V_LAYOUT2
                                          V_VARIANT2.
  ELSE.
    CALL METHOD V_GRID2->REFRESH_TABLE_DISPLAY.
  ENDIF.
ENDMODULE.                 " pbo_9001  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_HIBA[]  text
*      <--P_I_FIELDCAT2  text
*      <--P_V_LAYOUT2  text
*      <--P_V_VARIANT2  text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV2 CHANGING PT_HIBA      LIKE I_HIBA[]
                                    PT_FIELDCAT TYPE LVC_T_FCAT
                                    PS_LAYOUT   TYPE LVC_S_LAYO
                                    PS_VARIANT  TYPE DISVARIANT.

  DATA: I_EXCLUDE TYPE UI_FUNCTIONS.



  CREATE OBJECT V_CUSTOM_CONTAINER2
    EXPORTING
      CONTAINER_NAME = V_CONTAINER2.
  CREATE OBJECT V_GRID2
    EXPORTING
      I_PARENT = V_CUSTOM_CONTAINER2.

* Build field catalog
  PERFORM BUILD_FIELDCAT USING SY-DYNNR
                         CHANGING PT_FIELDCAT.

* Exclude functions
*  PERFORM exclude_tb_functions CHANGING lt_exclude.

  PS_LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
  PS_LAYOUT-SEL_MODE = 'B'.


  CLEAR PS_VARIANT.
  PS_VARIANT-REPORT = V_REPID.

  CALL METHOD V_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = PS_VARIANT
      I_SAVE               = 'A'
      I_DEFAULT            = 'X'
      IS_LAYOUT            = PS_LAYOUT
      IT_TOOLBAR_EXCLUDING = I_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = PT_FIELDCAT
      IT_OUTTAB            = PT_HIBA.


ENDFORM.                    " CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*&      Form  GET_ALV_GRID_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_OUTTAB  text
*----------------------------------------------------------------------*
FORM GET_ALV_GRID_LINE TABLES  $OUTTAB TYPE STANDARD TABLE.

  DATA: L_TABIX LIKE SY-TABIX.
  DATA: L_FROM  LIKE SY-TABIX.


*  Determine the number of rows
  DESCRIBE TABLE $OUTTAB LINES L_TABIX.

  IF L_TABIX > C_MAX_GRID_LINE.
    MESSAGE I174 WITH C_MAX_GRID_LINE.
    L_FROM = C_MAX_GRID_LINE + 1.
*   Due to memory overflow, display limited to & items!
    DELETE $OUTTAB FROM L_FROM TO L_TABIX.
  ENDIF.


ENDFORM.                    " GET_ALV_GRID_LINE
*&---------------------------------------------------------------------*
*&      Module  pai_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_9001 INPUT.

  V_SAVE_OK = V_OK_CODE.
  CLEAR V_OK_CODE.
  CASE V_SAVE_OK.

* Back
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
*     do nothing
  ENDCASE.


ENDMODULE.                 " pai_9001  INPUT
