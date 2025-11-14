*&---------------------------------------------------------------------*
*& Program: Reading data from analytics
*&---------------------------------------------------------------------*
 REPORT /ZAK/READ_FILE MESSAGE-ID /ZAK/ZAK.
*&---------------------------------------------------------------------*
*& Function description: __________________
*&---------------------------------------------------------------------*
*& Author: Károly Dénes
*& Creation date: 01.03.2006
*& Functional specification maker: Gábor Balázs
*& SAP module name: ADO
*& Program type: ________
*& SAP version: ________
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (The number of the OSS note must be written at the end of the modified lines)*
*&
*& LOG# DATE MODIFIER DESCRIPTION
*& ----   ----------   ----------     ---------------------- -----------
*& 0001 2007.01.03 Balázs G. (FMC) User date format check.
*& 0002 2007.06.04 Balázs G. (FMC) Against filling in a mandatory field.
*& 0003 2008.12.11 Balázs G. (FMC) Tax ID verification method.
*&                                    /ZAK/XLS function in element
*&                                    /ZAK/TXT function in element
*& 0004 2010.03.18 Balázs G. (Ness) upload correction from previous line
*&                                     values ​​remained if a was empty
*&                                     field.
*&---------------------------------------------------------------------*
 INCLUDE /ZAK/COMMON_STRUCT.
 INCLUDE: /ZAK/READ_TOP.
 INCLUDE EXCEL__C.
 INCLUDE <ICON>.
 CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.
*&---------------------------------------------------------------------*
*& TABLES *
*&---------------------------------------------------------------------*
 TABLES: BKPF,
         T001,
         DD02L.
*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
 TYPE-POOLS: SLIS.
*&---------------------------------------------------------------------*
*& CONSTANTS (C_XXXXXXX..) *
*&---------------------------------------------------------------------*
 CONSTANTS: C_CLASS       TYPE DD02L-TABCLASS VALUE 'INTTAB',
            C_A           TYPE C VALUE 'A',
* file types
            C_FILE_XLS(2) TYPE C VALUE   '02',
            C_FILE_TXT(2) TYPE C VALUE   '01',
            C_FILE_XML(2) TYPE C VALUE   '03',
            C_FILE_SAP(2) TYPE C VALUE   '04',
*++PTGSZLAA 2014.03.04 BG (Ness)
            C_FILE_CSV(2) TYPE C VALUE   '05',
*--PTGSZLAA 2014.03.04 BG (Ness)
* excel for loading
            C_END_ROW     TYPE I VALUE '65536',
            C_BEGIN_ROW   TYPE I VALUE    '1',
* file check
            C_FILE_X(1)   TYPE C VALUE    'X',
* analytics data structure
            C_ANALITIKA   LIKE /ZAK/BEVALLD-STRNAME VALUE '/ZAK/ANALITIKA'.
*++BG 2007.02.12
*++1565 #10.
* CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 5000.
 CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 9000.
*--1565 #10.
*--BG 2007.02.12
*++PTGSZLAA #01. 2014.03.03
 CONSTANTS: C_PTGSZLAA  TYPE /ZAK/BTYPE VALUE 'PTGSZLAA'.
*--PTGSZLAA #01. 2014.03.03
*++1865 #10.
 CONSTANTS: C_PTGSZLAH  TYPE /ZAK/BTYPE VALUE 'PTGSZLAH'.
*--1865 #10.
*type: begin of line
*&---------------------------------------------------------------------*
*& Work area (W_XXX..) *
*&---------------------------------------------------------------------*
* structure control
 DATA: W_DD02L TYPE DD02L.
* excel for loading
 DATA: W_XLS      TYPE ALSMEX_TABLINE,
       W_DD03P    TYPE DD03P,
       W_MAIN_STR TYPE DD03P,
       WA_DD03P   TYPE DD03P,
       W_LINE     TYPE /ZAK/LINE.
 DATA: W_OUTTAB  TYPE /ZAK/ANALITIKA,
       W_BEVALLI TYPE /ZAK/BEVALLI,
       W_ELSO    TYPE /ZAK/BEVALLI.
* data structure error
 DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.
 DATA: BEGIN OF GT_OUTTAB OCCURS 0.
         INCLUDE STRUCTURE /ZAK/ANALITIKA.
         DATA: LIGHT TYPE C.
 DATA: END OF GT_OUTTAB.
 DATA: G_LIGHTS_NAME TYPE LVC_CIFNM VALUE 'LIGHT'.
* message
 DATA: W_MESSAGE TYPE BAPIRET2.
*&---------------------------------------------------------------------*
*& INTERNAL TABLES (I_XXXXXXX..) *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*
 DATA: I_XLS      TYPE STANDARD TABLE OF ALSMEX_TABLINE
                                                     INITIAL SIZE 0,
       I_DD03P    TYPE STANDARD TABLE OF DD03P         INITIAL SIZE 0,
       I_MAIN_STR TYPE STANDARD TABLE OF DD03P       INITIAL SIZE 0.
 DATA: I_OUTTAB    TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0,
       I_OUTTAB_EX TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
* reporting periods
 DATA: I_BEVALLI TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0,
       I_ELSO    TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0.
* Error data structure table
 DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
 DATA: I_LINE TYPE STANDARD TABLE OF /ZAK/LINE            INITIAL SIZE 0.
* message
 DATA: E_MESSAGE TYPE STANDARD TABLE OF BAPIRET2     INITIAL SIZE 0.
*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES *
*      Series (Range) - (R_xxx...) *
*      Global variables - (V_xxx...) *
*      Work area - (W_xxx...) *
*      Type - (T_xxx...) *
*      Macros - (M_xxx...) *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Class - (CL_xxx...) *
*      Event - (E_xxx...) *
*&---------------------------------------------------------------------*
 DATA: V_WRBTR       LIKE BSEG-WRBTR,
       V_WRBTR_C(16).
 DATA: V_DATUM      LIKE SY-DATUM,
       V_DATUMC(10) TYPE C.
 DATA: V_TABIX LIKE SY-TABIX,
       V_SUBRC LIKE SY-SUBRC.
* variables
 DATA: V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.
* selection screen
 DATA: V_BUTXT   LIKE T001-BUTXT.
 DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
       V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.
* excel for loading
 DATA: V_BEGIN_COL TYPE I,
       V_END_COL   TYPE I.
* screen
 DATA: V_SCR1(70) TYPE C,
       V_SCR2(70) TYPE C,
       V_SCR3(70) TYPE C,
       V_SCR4(70) TYPE C.
* ALV treatment variables
 DATA: V_OK_CODE           LIKE SY-UCOMM,
       V_SAVE_OK           LIKE SY-UCOMM,
       V_REPID             LIKE SY-REPID,
       V_CONTAINER         TYPE SCRFNAME VALUE '/ZAK/ZAK_9000',
       V_CONTAINER2        TYPE SCRFNAME VALUE '/ZAK/ZAK_9001',
       V_GRID              TYPE REF TO CL_GUI_ALV_GRID,
       V_GRID2             TYPE REF TO CL_GUI_ALV_GRID,
       V_CUSTOM_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       V_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       I_FIELDCAT          TYPE LVC_T_FCAT,
       I_FIELDCAT2         TYPE LVC_T_FCAT,
       V_LAYOUT            TYPE LVC_S_LAYO,
       V_LAYOUT2           TYPE LVC_S_LAYO,
       V_VARIANT           TYPE DISVARIANT,
       V_VARIANT2          TYPE DISVARIANT,
       V_TOOLBAR           TYPE STB_BUTTON,
       V_DYNDOC_ID         TYPE REF TO CL_DD_DOCUMENT,
       V_EVENT_RECEIVER    TYPE REF TO LCL_EVENT_RECEIVER,
       V_EVENT_RECEIVER2   TYPE REF TO LCL_EVENT_RECEIVER,
       V_STRUC             TYPE DD02L-TABNAME.
* for a popup message
 DATA: V_TEXT1(40) TYPE C,
       V_TEXT2(40) TYPE C,
       V_TITEL     TYPE C,
       V_ANSWER.
* file check
 DATA: LV_ACTIVE TYPE ABAP_BOOL.
 DATA: V_WNUM(30) TYPE N,
       V_WAERS    LIKE T001-WAERS.
*++BG 2007.02.12
 DATA: V_XLS_LINE TYPE SY-TABIX VALUE 5000.
*--BG 2007.02.12
* field symbol
 FIELD-SYMBOLS <FS> TYPE ANY.
*++0002 BG 2007.07.02
*MACRO definition for range upload
 DEFINE M_DEF.
   MOVE: &2      TO &1-SIGN,
         &3      TO &1-OPTION,
         &4      TO &1-LOW,
         &5      TO &1-HIGH.
   APPEND &1.
 END-OF-DEFINITION.
*--0002 BG 2007.07.02
*&---------------------------------------------------------------------*
*& PARAMETERS (P_XXXXXX..) *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SELECT-OPTIONS (S_XXXXXXX..) *
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
 PARAMETERS: P_BTEXT  LIKE /ZAK/BEVALLT-BTEXT MODIF ID OUT.
 SELECTION-SCREEN END OF LINE.
 SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE TEXT-B02.
 PARAMETERS: P_BSZNUM LIKE /ZAK/BEVALLD-BSZNUM
*                          MATCHCODE OBJECT /ZAK/BEVD
                                                    OBLIGATORY.
 SELECTION-SCREEN END OF BLOCK B02.
 SELECTION-SCREEN BEGIN OF BLOCK B04 WITH FRAME TITLE TEXT-B04.
 PARAMETERS: P_NORM  RADIOBUTTON GROUP R01 USER-COMMAND NORM
                                                   DEFAULT 'X',
             P_ISMET RADIOBUTTON GROUP R01,
             P_PACK  LIKE /ZAK/BEVALLP-PACK
                       MATCHCODE OBJECT /ZAK/PACK.
 SELECTION-SCREEN END OF BLOCK B04.
 SELECTION-SCREEN BEGIN OF BLOCK B03 WITH FRAME TITLE TEXT-B03.
ENHANCEMENT-POINT /ZAK/ZAK_READ_TELENOR_01 SPOTS /ZAK/READ_ES STATIC .
 PARAMETERS: P_PREZ RADIOBUTTON GROUP GR1 DEFAULT 'X' USER-COMMAND ZAPP,
             P_APPL RADIOBUTTON GROUP GR1.
 PARAMETERS: P_FDIR  LIKE FC03TAB-PL00_FILE          OBLIGATORY,
* PARAMETERS: P_FDIR(255) TYPE C                    OBLIGATORY
*                                                   LOWER CASE,
*MEMORY ID GPF
*++BG 2006/07/07
             P_HEAD  AS CHECKBOX DEFAULT 'X',
*--BG 2006/07/07
             P_TESZT AS CHECKBOX DEFAULT 'X'.
 SELECTION-SCREEN END OF BLOCK B03.
 PARAMETERS: P_CDV AS CHECKBOX.
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
* this is written on the screen
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
* designations
   PERFORM FIELD_DESCRIPT.
*++1765 #19.
*++2365 #08.
   V_REPID = SY-REPID.
*--2365 #08.
* Eligibility check
   AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2165 #03.
*                   ID 'TCD'  FIELD SY-TCODE.
                   ID 'TCD'  FIELD '/ZAK/READ_FILE'.
*--2165 #03
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
 AT SELECTION-SCREEN.
* designations
   PERFORM FIELD_DESCRIPT.
   PERFORM CHECK_PARAMS .
*++BG 2006/08/31
*  Company code check in file name
   PERFORM CHECK_BUKRS_FILENAME.
*--BG 2006/08/31
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FDIR.
*++PTGSZLAA 2014.03.04 BG (Ness)
   IF NOT P_PREZ IS INITIAL.
*--PTGSZLAA 2014.03.04 BG (Ness)
     PERFORM FILENAME_GET.
*++PTGSZLAA 2014.03.04 BG (Ness)
   ELSEIF NOT P_APPL IS INITIAL.
     PERFORM FILENAME_GET_APPL.
   ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
 AT SELECTION-SCREEN ON BLOCK B04.
*  Block check
   PERFORM VER_BLOCK_B04 USING P_NORM
                               P_ISMET
                               P_PACK.
* Check selector switch!
 AT SELECTION-SCREEN ON RADIOBUTTON GROUP R01.
************************************************************************
* AT SELECTION-SCREEN output
************************************************************************
 AT SELECTION-SCREEN OUTPUT.
   PERFORM MODIF_SCREEN.
************************************************************************
* START-OF-SELECTION
************************************************************************
 START-OF-SELECTION.
* definition of declaration type
   PERFORM READ_BEVALL USING P_BUKRS
                             P_BTYPE.
*  Eligibility check
   PERFORM AUTHORITY_CHECK USING P_BUKRS
                                 W_/ZAK/BEVALL-BTYPART
                                 C_ACTVT_01.
* reading control boards
   PERFORM READ_CUST_TABLE USING P_BUKRS
                                 P_BTYPE
                                 P_BSZNUM.
   CLEAR: V_TYPE,V_STRNAME.
* Data structure definition and verification of its existence
   PERFORM CHECK_BEVALLD USING P_BUKRS
                               P_BTYPE
                               P_BSZNUM
                      CHANGING V_TYPE
                               V_STRNAME.
* Data structure field checks and
* defining the number of columns.
   PERFORM CHECK_FIELDTYP USING    V_STRNAME
                          CHANGING V_END_COL.
* Analytics table structure
   PERFORM GET_ANALITIKA_STUC USING C_ANALITIKA.
* Definition of data structure-field association
* We only process fields with an ABEV identifier!
   PERFORM CHECK_BEVALLC USING P_BUKRS
                               P_BTYPE
                               V_STRNAME
                               P_BSZNUM.
* I call the loading functions based on the file format of the data service
   CASE V_TYPE.
     WHEN C_FILE_XLS.
*
       PERFORM PROCESS_IND USING TEXT-P00.
       V_BEGIN_COL = 1.
* the errors in the I_ERROR table!
       CALL FUNCTION '/ZAK/XLS'
         EXPORTING
           FILENAME                = P_FDIR
           I_BEGIN_COL             = V_BEGIN_COL
           I_BEGIN_ROW             = C_BEGIN_ROW
           I_END_COL               = V_END_COL
           I_END_ROW               = C_END_ROW
           I_STRNAME               = V_STRNAME
           I_BUKRS                 = P_BUKRS
           I_CDV                   = P_CDV
*++BG 2006/07/07
           I_HEAD                  = P_HEAD
*--BG 2006/07/07
*++RN 2010/12/17
           I_NOT_FILL_LINE         = 'X'
*--RN 2010/12/17
*++1565 #10.
         IMPORTING
           E_MAX_LINE              = V_XLS_LINE
*--1565 #10.
         TABLES
           INTERN                  = I_XLS
           CHECK_TAB               = I_DD03P  "adatszerkezet
           E_HIBA                  = I_HIBA
           I_LINE                  = I_LINE
         EXCEPTIONS
           INCONSISTENT_PARAMETERS = 1
           UPLOAD_OLE              = 2
           FILE_OPEN_ERROR         = 3
           INVALID_TYPE            = 4
           CONVERSION_ERROR        = 5
           OTHERS                  = 6.
       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
*++BG 2007/02/12
* Item number check, here only the max. 
* item number can be loaded!
         DESCRIBE TABLE I_LINE LINES V_XLS_LINE.
         IF V_XLS_LINE > C_MAX_XLS_LINE.
*++1565 #10.
*           MESSAGE I207 WITH V_XLS_LINE C_MAX_XLS_LINE.
           MESSAGE I207 WITH  C_MAX_XLS_LINE.
*--1565 #10.
*          The specified number of file lines (&) is greater than the max. allowed (&)!
           EXIT.
         ENDIF.
*--BG 2007/02/12
* alv list internal table filling I_OUTTAB
         PERFORM FILL_DATATAB USING I_XLS[]
                                    I_DD03P[]
                                    I_MAIN_STR[]
                                    I_/ZAK/BEVALLC[]
                                    I_LINE[]
                                    V_STRNAME.
         CHECK NOT I_OUTTAB[] IS INITIAL.
* Verification of declaration data service uploads!
*         PERFORM CHECK_UPLOAD_STATUS.
       ENDIF.
     WHEN C_FILE_TXT.
       PERFORM PROCESS_IND USING TEXT-P01.
       CALL FUNCTION '/ZAK/TXT'
         EXPORTING
           FILENAME                = P_FDIR
           I_STRNAME               = V_STRNAME
           I_BUKRS                 = P_BUKRS
           I_CDV                   = P_CDV
*++BG 2006/07/07
           I_HEAD                  = P_HEAD
*--BG 2006/07/07
         TABLES
           INTERN                  = I_XLS
           CHECK_TAB               = I_DD03P
           E_HIBA                  = I_HIBA
           I_LINE                  = I_LINE
         EXCEPTIONS
           CONVERSION_ERROR        = 1
           FILE_OPEN_ERROR         = 2
           FILE_READ_ERROR         = 3
           INVALID_TYPE            = 4
           GUI_REFUSE_FILETRANSFER = 5
           OTHERS                  = 6.
       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
* ALV LIST INTERNAL TABLE FILLING I_OUTTAB
         PERFORM FILL_DATATAB USING I_XLS[]
                                    I_DD03P[]
                                    I_MAIN_STR[]
                                    I_/ZAK/BEVALLC[]
                                    I_LINE[]
                                    V_STRNAME.
         CHECK NOT I_OUTTAB[] IS INITIAL.
       ENDIF.
     WHEN C_FILE_XML.
*       CALL FUNCTION '/ZAK/XML'
*            EXPORTING
*                 FILENAME                = P_FDIR
*                 I_STRNAME               = V_STRNAME
*                 I_BUKRS                 = P_BUKRS
*                 I_BTYPE                 = P_BTYPE
*                 I_BSZNUM                = P_BSZNUM
*            TABLES
*                 INTERN                  = I_XLS
*                 CHECK_TAB               = I_DD03P
*                 E_ERROR = I_ERROR
*                 I_LINE                  = I_LINE
*                 I_/ZAK/ANALYTICS = I_OUTTAB
*            EXCEPTIONS
*                 INCONSISTENT_PARAMETERS = 1
*                 UPLOAD_OLE              = 2
*                 FILE_OPEN_ERROR         = 3
*                 INVALID_TYPE            = 4
*                 CONVERSION_ERROR        = 5
*                 OTHERS                  = 6.
*       IF SY-SUBRC <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*       ENDIF.
       PERFORM PROCESS_IND USING TEXT-P02.
*++PTGSZLAA #04. 2014.04.25
*++PTGSZLAH #01. 2015.01.16
*       IF P_BTYPE EQ C_PTGSZLAA.
       IF P_BTYPE EQ C_PTGSZLAA OR P_BTYPE EQ C_BTYPE_PTGSZLAH.
*--PTGSZLAH #01. 2015.01.16
         CALL FUNCTION '/ZAK/XML_PTG_UPLOAD'
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
       ELSE.
*--PTGSZLAA #04. 2014.04.25
         CALL FUNCTION '/ZAK/XML'
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
*++PTGSZLAA #04. 2014.04.25
       ENDIF.
*--PTGSZLAA #04. 2014.04.25
     WHEN C_FILE_SAP.
*++PTGSZLAA 2014.03.04 BG (Ness)
     WHEN C_FILE_CSV.
       CALL FUNCTION '/ZAK/CSV'
         EXPORTING
           FILENAME                = P_FDIR
           I_STRNAME               = V_STRNAME
           I_BUKRS                 = P_BUKRS
           I_CDV                   = P_CDV
           I_HEAD                  = P_HEAD
           I_APPL                  = P_APPL
         TABLES
           INTERN                  = I_XLS
           CHECK_TAB               = I_DD03P
           E_HIBA                  = I_HIBA
           I_LINE                  = I_LINE
         EXCEPTIONS
           CONVERSION_ERROR        = 1
           FILE_OPEN_ERROR         = 2
           FILE_READ_ERROR         = 3
           INVALID_TYPE            = 4
           GUI_REFUSE_FILETRANSFER = 5
           OTHERS                  = 6.
       IF SY-SUBRC <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       ELSE.
* ALV LIST INTERNAL TABLE FILLING I_OUTTAB
         PERFORM FILL_DATATAB USING I_XLS[]
                                    I_DD03P[]
                                    I_MAIN_STR[]
                                    I_/ZAK/BEVALLC[]
                                    I_LINE[]
                                    V_STRNAME.
         CHECK NOT I_OUTTAB[] IS INITIAL.
       ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
   ENDCASE.
   REFRESH: I_OUTTAB_EX.
* Hello exit invitation
   IF W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_SZJA.
     PERFORM PROCESS_IND USING TEXT-P03.
     CALL FUNCTION '/ZAK/SZJA_NEW_ROWS'
       EXPORTING
         I_BUKRS         = P_BUKRS
         I_BTYPE         = P_BTYPE
         I_BSZNUM        = P_BSZNUM
       TABLES
         I_/ZAK/ANALITIKA = I_OUTTAB
         O_/ZAK/ANALITIKA = I_OUTTAB_EX.
     APPEND LINES OF I_OUTTAB_EX  TO I_OUTTAB.
   ENDIF.
* Call ABEV exit
   PERFORM PROCESS_IND USING TEXT-P06.
   CALL FUNCTION '/ZAK/READ_ABEV_EXIT'
     EXPORTING
       I_BUKRS     = P_BUKRS
       I_BTYPE     = P_BTYPE
       I_BSZNUM    = P_BSZNUM
     TABLES
       T_ANALITIKA = I_OUTTAB.
* Conversion of analytics items, only in case of error-free loading
   IF I_HIBA[] IS INITIAL.
     PERFORM PROCESS_IND USING TEXT-P07.
     CALL FUNCTION '/ZAK/ANALITIKA_CONVERSION'
       TABLES
         T_ANALITIKA = I_OUTTAB.
   ENDIF.
*++BG 2006.09.15
*  In the case of a SJJA declaration, there cannot be more than one BTYPE in one shipment
   IF W_/ZAK/BEVALL-BTYPART EQ C_BTYPART_SZJA.
     CLEAR W_HIBA.
     LOOP AT I_OUTTAB INTO W_OUTTAB WHERE BTYPE NE P_BTYPE.
       MOVE 'Bevallás típus'(021) TO W_HIBA-/ZAK/ATTRIB.
       MOVE W_OUTTAB-BTYPE TO W_HIBA-/ZAK/F_VALUE.
       MOVE TEXT-022 TO W_HIBA-ZA_HIBA.
       APPEND W_HIBA TO I_HIBA.
       EXIT.
     ENDLOOP.
   ENDIF.
*--BG 2006.09.15
*++1365 22.01.2013 Gábor Balázs (Ness)
*  Generation of SZLA data
   IF NOT W_/ZAK/BEVALLD-OMREL IS INITIAL.
     CALL FUNCTION '/ZAK/GEN_AFA_SZLA'
       TABLES
         T_ANALITIKA = I_OUTTAB
         T_AFA_SZLA  = I_/ZAK/AFA_SZLA
         T_RETURN    = E_MESSAGE.
     IF NOT E_MESSAGE[] IS INITIAL.
       LOOP AT E_MESSAGE INTO W_MESSAGE WHERE TYPE CA 'AXE'.
         CLEAR W_HIBA.
         CONCATENATE W_MESSAGE-ID
                     W_MESSAGE-NUMBER INTO W_HIBA-/ZAK/ATTRIB.
         W_HIBA-/ZAK/F_VALUE = W_MESSAGE-MESSAGE_V1.
         W_HIBA-ZA_HIBA     = W_MESSAGE-MESSAGE.
         W_HIBA-TABNAME     = '/ZAK/AFA_SZLA'.
         W_HIBA-FIELDNAME   = 'SZAMLASZE'.
         APPEND W_HIBA TO I_HIBA.
       ENDLOOP.
     ENDIF.
   ENDIF.
*--1365 22.01.2013 Gábor Balázs (Ness)
* Database table update
   IF I_HIBA[] IS INITIAL.
*  Examination, database modification. 
     PERFORM PROCESS_IND USING TEXT-P04.
     PERFORM UPD_DATA USING P_TESZT.
   ENDIF.
************************************************************************
* END-OF-SELECTION
***********************************************************************
 END-OF-SELECTION.
   PERFORM PROCESS_IND USING TEXT-P05.
   SORT I_OUTTAB BY ITEM.
*  GRID maximum row limit
   PERFORM GET_ALV_GRID_LINE TABLES I_OUTTAB.
   PERFORM ALV_LIST.
************************************************************************
* SUBPROGRAMS
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  filename_get
*&---------------------------------------------------------------------*
*       Enter path
*----------------------------------------------------------------------*
 FORM FILENAME_GET.
   DATA:
*    L_MASK(20),
     L_FNAM(8),
     L_INX(3),
     L_RC       TYPE I,
     L_FILENAME LIKE P_FDIR,
     LT_FILE    TYPE FILETABLE,
     L_MULTISEL TYPE I,
     L_FILTER   TYPE STRING.
   CASE W_/ZAK/BEVALLD-FILETYPE.
     WHEN C_FILE_XLS.
       L_FILTER = '*.XLS'.
     WHEN C_FILE_TXT.
       L_FILTER = '*.TXT'.
     WHEN C_FILE_XML.
       L_FILTER = '*.XML'.
     WHEN C_FILE_SAP.
   ENDCASE.
* ++ 0001 CST 2006.05.27
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*     EXPORTING
**       WINDOW_TITLE
*        DEFAULT_EXTENSION = L_FILTER
*       DEFAULT_FILENAME  = 'C:\Temp'
**       FILE_FILTER       = ',*.*,*.*.'
*        FILE_FILTER       = L_FILTER "'*.CSV'
**       INIT_DIRECTORY    = ' '
**       MULTISELECTION
*     CHANGING
*       FILE_TABLE        = LT_FILE
*       RC                = L_RC
*     EXCEPTIONS
*       FILE_OPEN_DIALOG_FAILED = 1
*       CNTL_ERROR              = 2.
*
*   CHECK SY-SUBRC IS INITIAL AND L_RC NE -1.
*   READ TABLE LT_FILE INDEX 1 INTO P_FDIR.
* -- 0001 CST 2006.05.27
   DATA: L_MASK(20)   TYPE C VALUE ',*.*  ,*.*.'.
*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*   CALL FUNCTION 'WS_FILENAME_GET'
*     EXPORTING
*       DEF_FILENAME     = L_FILTER
**      def_path         =
*       MASK             = L_MASK
*       MODE             = 'O'
*       TITLE            = SY-TITLE
*     IMPORTING
*       FILENAME         = P_FDIR
**      RC               =  DUMMY
*     EXCEPTIONS
*       INV_WINSYS       = 04
*       NO_BATCH         = 08
*       SELECTION_CANCEL = 12
*       SELECTION_ERROR  = 16.
   DATA L_EXTENSION TYPE STRING.
   DATA L_TITLE     TYPE STRING.
   DATA L_FILE      TYPE STRING.
   DATA L_FULLPATH  TYPE STRING.
   L_TITLE = SY-TITLE.
   L_EXTENSION = L_MASK.
   CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
     EXPORTING
       WINDOW_TITLE = L_TITLE
*      DEFAULT_EXTENSION = L_EXTENSION
*      DEFAULT_FILE_NAME =
*      WITH_ENCODING     =
       FILE_FILTER  = L_FILTER
*      INITIAL_DIRECTORY =
     IMPORTING
*      FILENAME     = L_FILE
*      PATH         =
       FULLPATH     = L_FULLPATH
*      USER_ACTION  =
*      FILE_ENCODING     =
     .
   P_FDIR = L_FULLPATH.
*--MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
   CHECK SY-SUBRC EQ 0.
 ENDFORM.                    " FILENAME_GET
*   ROW I_SZJA001 BY DATE.
*   LOOP AT I_SZJA001 INTO W_SZJA001.
*     AT END OF DATUM.
*       W_BEVALLI-DATE = W_SZJA001-DATE.
*       APPEND W_BEVALLI TO I_BEVALLI.
*
*       SELECT * INTO W_/ZAK/BEVALLI FROM /ZAK/BEVALLI
*          WHERE BUKRS = P_BUKRS AND
*                BTYPE = P_BTYPE AND
*                GJAHR = W_SZJA001-DATUM(4) AND
*                MONAT = W_SZJA001-DATUM+4(2).
*       ENDSELECT.
*       IF SY-SUBRC NE 0.
*         W_ELSO-DATUM = W_SZJA001-DATUM.
*         APPEND W_ELSO TO I_ELSO.
*       ENDIF.
*       SELECT * INTO W_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
*          WHERE BUKRS = P_BUKRS AND
*                BTYPE = P_BTYPE AND
*                BSZNUM = P_BSZNUM AND
*                GJAHR = W_SZJA001-DATUM(4) AND
*                MONAT = W_SZJA001-DATUM+4(2).
*
*         IF W_/ZAK/BEVALLI-FLAG EQ 'X'.
*           V_TEXT1 = TEXT-017.
*           V_TEXT2 = TEXT-018.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*
*         ELSEIF W_/ZAK/BEVALLI-FLAG EQ 'Z'.
*           V_TEXT1 = TEXT-019.
*           V_TEXT2 = TEXT-018.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*
*         ELSEIF W_/ZAK/BEVALLI-FLAG EQ 'B'.
*           V_TEXT1 = TEXT-020.
*           V_TEXT2 = TEXT-016.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*
*         ELSEIF W_/ZAK/BEVALLI-ZINDEX NOT '000'.
*           V_TEXT1 = TEXT-015.
*           V_TEXT2 = TEXT-016.
*           PERFORM POPUP USING    V_TEXT1
*                                  V_TEXT2
*                         CHANGING V_ANSWER.
*         ENDIF.
*       ENDSELECT.
*     ENDAT.
*   ENDLOOP.
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
* Declaration data service uploads!
   SELECT * INTO TABLE I_/ZAK/BEVALLSZ FROM /ZAK/BEVALLSZ
                             WHERE BUKRS  EQ $BUKRS AND
                                   BTYPE  EQ $BTYPE AND
                                   BSZNUM EQ $BSZNUM.
   IF SY-SUBRC NE 0.
*   MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
   ENDIF.
* Definition of data structure-field association
   SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
                             WHERE BTYPE EQ $BTYPE AND
                                   BSZNUM EQ $BSZNUM.
   IF SY-SUBRC NE 0.
*     MESSAGE E010 WITH $BUKRS $BTYPE .
   ENDIF.
*
 ENDFORM.                    " read_cust_table
*&---------------------------------------------------------------------*
*&      Form  check_upload_status
*&---------------------------------------------------------------------*
*       data service uploads
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_UPLOAD_STATUS.
   IF NOT I_OUTTAB[] IS INITIAL.
* I check the status of the existing downloads
* status management--> in pop-up window
* This needs to be discussed here, which version should I look at
*CALL FUNCTION '/ZAK/READ_ACTUAL_VERSION'
*  EXPORTING
*    I_BUKRS        = p_bukrs
*    I_BTYPE        = p_btype
*    I_GJAHR        = p_gjahr
*    I_MONAT        = p_monat
* IMPORTING
*    E_ZINDEX       =
*          .
* status decides the issue
     V_TEXT1 = 'Tovább?' . " teszthez
* v_text2 =
* v_titel =
*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*         DEFAULTOPTION = 'N'
*         TEXTLINE1     = V_TEXT1
*         TEXTLINE2     = V_TEXT2
*         TITEL         = V_TITEL
*       IMPORTING
*         ANSWER        = V_ANSWER
*       EXCEPTIONS
*         OTHERS        = 0.
     DATA L_QUESTION TYPE STRING.
     CONCATENATE V_TEXT1 V_TEXT2 INTO L_QUESTION SEPARATED BY SPACE.
*
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR       = V_TITEL
*        DIAGNOSE_OBJECT             = ' '
         TEXT_QUESTION  = L_QUESTION
*        TEXT_BUTTON_1  = 'Ja'(001)
*        ICON_BUTTON_1  = ' '
*        TEXT_BUTTON_2  = 'Nein'(002)
*        ICON_BUTTON_2  = ' '
         DEFAULT_BUTTON = '2'
*        DISPLAY_CANCEL_BUTTON       = 'X'
*        USERDEFINED_F1_HELP         = ' '
         START_COLUMN   = 25
         START_ROW      = 6
*        POPUP_TYPE     =
*        IV_QUICKINFO_BUTTON_1       = ' '
*        IV_QUICKINFO_BUTTON_2       = ' '
       IMPORTING
         ANSWER         = V_ANSWER
*   TABLES
*        PARAMETER      =
*   EXCEPTIONS
*        TEXT_NOT_FOUND = 1
*        OTHERS         = 2
       .
     IF V_ANSWER EQ '1'.
       V_ANSWER = 'J'.
     ELSE.
       V_ANSWER = 'N'.
     ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
     IF V_ANSWER NE 'J'.
       MESSAGE S101(/ZAK/ZAK).
       LEAVE PROGRAM.
     ELSE.
       EXIT.
     ENDIF.
   ENDIF.
 ENDFORM.                    " check_upload_status
*&---------------------------------------------------------------------*
*&      Form check_declare
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
* Data structure definition
   SELECT SINGLE * INTO W_/ZAK/BEVALLD FROM /ZAK/BEVALLD
                   WHERE BUKRS  EQ $BUKRS AND
                   BTYPE  EQ $BTYPE AND
                   BSZNUM EQ $BSZNUM.
   IF SY-SUBRC NE 0.
     MESSAGE E011 WITH $BUKRS $BTYPE $BSZNUM.
   ELSE.
     IF W_/ZAK/BEVALLD-FILETYPE EQ '04'.
* SAP data service is currently not allowed!
       MESSAGE E006.
     ENDIF.
*++2007.01.11 BG (FMC)
     IF NOT W_/ZAK/BEVALLD-XSPEC IS INITIAL.
       MESSAGE E205 WITH $BSZNUM.
*   & data service is set to special! 
     ENDIF.
*--2007.01.11 BG (FMC)
     $STRNAME = W_/ZAK/BEVALLD-STRNAME.
     $TYPE    = W_/ZAK/BEVALLD-FILETYPE.
* XML format does not need a structure
     IF  W_/ZAK/BEVALLD-FILETYPE NE '03'.
* Checking the existence of a data structure!
       SELECT SINGLE * INTO W_DD02L FROM DD02L
                       WHERE TABNAME  EQ W_/ZAK/BEVALLD-STRNAME AND
                             AS4LOCAL EQ C_A AND
                             TABCLASS EQ C_CLASS.
* activated?
       IF SY-SUBRC NE 0.
         MESSAGE E050 WITH W_/ZAK/BEVALLD-STRNAME .
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " check_bevalld
*&---------------------------------------------------------------------*
*&      Form  field_descript
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FIELD_DESCRIPT.
   IF NOT P_BUKRS IS INITIAL.
     SELECT SINGLE *  FROM T001
           WHERE BUKRS = P_BUKRS.
     P_BUTXT = T001-BUTXT.
*++1765 #18.
*     V_WAERS = T001-WAERS.
     SELECT SINGLE WAERS INTO V_WAERS
                         FROM T005
                        WHERE LAND1 EQ T001-LAND1.
*--1765 #18.
   ENDIF.
   IF NOT P_BTYPE IS INITIAL.
     SELECT SINGLE BTEXT INTO P_BTEXT FROM /ZAK/BEVALLT
         WHERE LANGU = SY-LANGU
           AND BUKRS = P_BUKRS
           AND BTYPE = P_BTYPE.
   ENDIF.
*   IF NOT P_BPART IS INITIAL.
*     SELECT SINGLE DDTEXT INTO P_BTTEXT FROM DD07T
*        WHERE DOMNAME = '/ZAK/BTYPART'
*          AND DDLANGUAGE = SY-LANGU
*          AND DOMVALUE_L = P_BPART.
*   ENDIF.
 ENDFORM.                    " field_descript
*&---------------------------------------------------------------------*
*&      Form  modif_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MODIF_SCREEN.
   IF NOT P_NORM IS INITIAL.
     LOOP AT SCREEN.
       IF SCREEN-GROUP1 = 'DIS'.
         SCREEN-INPUT = 0.
         SCREEN-OUTPUT = 1.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ELSEIF NOT P_ISMET IS INITIAL .
     LOOP AT SCREEN.
       IF SCREEN-GROUP1 = 'DIS'.
         SCREEN-INPUT = 1.
         SCREEN-OUTPUT = 1.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ENDIF.
   LOOP AT SCREEN.
     IF SCREEN-GROUP1 = 'OUT'.
       SCREEN-INPUT = 0.
       SCREEN-OUTPUT = 1.
       SCREEN-DISPLAY_3D = 0.
       MODIFY SCREEN.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " modif_screen
*&---------------------------------------------------------------------*
*&      Form  check_params
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_PARAMS.
   DATA:
     LV_FILENAME TYPE LOCALFILE,
     LV_SUBRC    LIKE SY-SUBRC,
     LV_FULLNAME TYPE LOCALFILE,
     LV_STRING   TYPE STRING.
*++1765 #32.
**++0001 2007.01.03 BG (FMC)
*   CALL FUNCTION '/ZAK/USER_DEFAULT'
*     EXPORTING
*       USERS      = SY-UNAME
*     EXCEPTIONS
*       ERROR_DATF = 1
*       OTHERS     = 2.
*   IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
**--0001 2007.01.03 BG (FMC)
*--1765 #32.
   IF NOT P_BUKRS IS INITIAL AND
      NOT P_BTYPE IS INITIAL.
     SELECT SINGLE BTYPE INTO V_BTYPE FROM /ZAK/BEVALL
                         WHERE BUKRS EQ P_BUKRS AND
                               BTYPE EQ P_BTYPE .
     IF SY-SUBRC NE 0.
       MESSAGE E010 WITH P_BUKRS P_BTYPE .
     ENDIF.
     CLEAR: W_/ZAK/BEVALLD.
     IF NOT P_ISMET IS INITIAL AND
        NOT P_PACK IS INITIAL AND
        NOT P_BSZNUM IS INITIAL.
       SELECT SINGLE * FROM /ZAK/BEVALLSZ
              WHERE BUKRS  EQ P_BUKRS AND
                    BTYPE  EQ P_BTYPE AND
                    BSZNUM EQ P_BSZNUM AND
                    PACK   EQ P_PACK.
       IF SY-SUBRC NE 0.
         MESSAGE E067 WITH P_PACK P_BSZNUM..
       ENDIF.
     ENDIF.
   ENDIF.
* Data structure definition and verification of its existence
   PERFORM CHECK_BEVALLD USING P_BUKRS
                               P_BTYPE
                               P_BSZNUM
                      CHANGING V_TYPE
                               V_STRNAME.
* ++ 0001 CST 2006.05.27
*   LV_STRING = P_FDIR.
*   CLEAR LV_ACTIVE.
*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
*     EXPORTING
*       FILE            = LV_STRING
*     RECEIVING
*       RESULT          = LV_ACTIVE
*     EXCEPTIONS
*       CNTL_ERROR      = 1
*       ERROR_NO_GUI    = 2
*       WRONG_PARAMETER = 3
*       OTHERS          = 4.
*   IF SY-SUBRC <> 0.
*     MESSAGE E004 WITH P_FDIR.
*   ENDIF.
*   IF LV_ACTIVE NE C_FILE_X.
*     MESSAGE E004 WITH P_FDIR.
*   ENDIF.
   DATA: L_RET.
*++PTGSZLAA 2014.03.04 BG (Ness)
   IF NOT P_PREZ IS INITIAL.
*--PTGSZLAA 2014.03.04 BG (Ness)
*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*     CALL FUNCTION 'WS_QUERY'
*       EXPORTING
*         QUERY    = 'FL'
*         FILENAME = P_FDIR
*       IMPORTING
*         RETURN   = L_RET.
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
*--MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*++PTGSZLAA 2014.03.04 BG (Ness)
   ELSEIF NOT P_APPL IS INITIAL.
     OPEN DATASET P_FDIR FOR INPUT IN TEXT MODE ENCODING DEFAULT.
     IF SY-SUBRC NE 0.
       CLEAR L_RET.
     ELSE.
       L_RET = 'T'.
       CLOSE DATASET P_FDIR.
     ENDIF.
   ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
   CONDENSE L_RET NO-GAPS.
   IF L_RET EQ SPACE.
*   The specified file (&) cannot be opened!
     MESSAGE E004(/ZAK/ZAK) WITH P_FDIR.
   ENDIF.
* -- 0001 CST 2006.05.27
 ENDFORM.                    " check_params
*&---------------------------------------------------------------------*
*&      Form ALV_LIST
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
* ALV list
     CALL SCREEN 9000.
*++1565 #03.
   ELSEIF NOT I_HIBA[] IS INITIAL.
     LOOP AT I_HIBA INTO W_HIBA.
       MESSAGE I000 WITH W_HIBA-ZA_HIBA W_HIBA-/ZAK/F_VALUE
                         W_HIBA-TABNAME W_HIBA-FIELDNAME.
*     & & & &
     ENDLOOP.
     MESSAGE E101.
*    Data loading complete!
   ENDIF.
*--1565 #03.
 ENDFORM.                    " ALV_LIST
*&---------------------------------------------------------------------*
*&      Module  PBO9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE PBO9000 OUTPUT.
   PERFORM SET_STATUS.
   DATA: L_NAME(20) TYPE C,
         W_RETURN   LIKE BAPIRET2.
   IF V_CUSTOM_CONTAINER IS INITIAL.
* the SAP structure of the data structure from the /ZAK/BEVALLD-strname table
* kell venni
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
** Write messages!
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
   DATA: TAB    TYPE STANDARD TABLE OF TAB_TYPE WITH
                  NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
         WA_TAB TYPE TAB_TYPE.
* analytical structure display
   IF SY-DYNNR = '9000'.
     SET PF-STATUS 'MAIN9000' EXCLUDING TAB.
     SET TITLEBAR  'MAIN'.
   ELSE.
     SET PF-STATUS 'MAIN9001' EXCLUDING TAB.
     SET TITLEBAR 'MAIN9001'.
   ENDIF.
 ENDFORM.                    " set_status
*&---------------------------------------------------------------------*
*&      Form create_and_init_alv
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
* Compilation of a field catalog
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
* /ZAK/ANALYTICS board
   IF P_DYNNR = '9000'.
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/ANALITIKA'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.
* too many fields in display
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
* error board
     CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
       EXPORTING
         I_STRUCTURE_NAME   = '/ZAK/ADAT_HIBA'
         I_BYPASSING_BUFFER = 'X'
       CHANGING
         CT_FIELDCAT        = PT_FIELDCAT.
   ENDIF.
 ENDFORM.                    " build_fieldcat
*&---------------------------------------------------------------------*
*&      Form exit_program
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
*----------------------------------------------------------------------*
*      -->P_V_STRNAME  text
*      <--P_V_BEGIN_XLS  text
*----------------------------------------------------------------------*
 FORM CHECK_FIELDTYP USING    $STRNAME
                     CHANGING $V_END_COL.
   REFRESH: I_DD03P.
   CALL FUNCTION 'DDIF_TABL_GET'
     EXPORTING
       NAME          = $STRNAME
*      STATE = 'A'
       LANGU         = SY-LANGU
     TABLES
       DD03P_TAB     = I_DD03P
     EXCEPTIONS
       ILLEGAL_INPUT = 1
       OTHERS        = 2.
   IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   $V_END_COL = SY-TFILL.
* COMPTYPE = 'S' includ line is therefore not taken into account
   DELETE I_DD03P WHERE COMPTYPE = 'S'.
   LOOP AT I_DD03P INTO W_DD03P.
     W_DD03P-POSITION = SY-TABIX.
     MODIFY I_DD03P FROM W_DD03P TRANSPORTING POSITION.
   ENDLOOP.
 ENDFORM.                    " check_fieldtyp
*&---------------------------------------------------------------------*
*&      Form  FILL_DATATAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_XLS  text
*      -->P_I_DD03P  text
*      -->P_V_STRNAME  text
*----------------------------------------------------------------------*
 FORM FILL_DATATAB USING    $I_XLS     LIKE I_XLS[]
                            $I_DD03P   LIKE I_DD03P[]
                            $I_MAIN_STR LIKE I_MAIN_STR[] "analitika str
                            $I_BEVALLC LIKE I_/ZAK/BEVALLC[]
                            $I_LINE    LIKE I_LINE[]
                            $V_STRNAME.
*++1865 #06.
*   DATA: G_TABIX LIKE SY-TABIX,
   DATA: L_TABIX    LIKE SY-TABIX,
*++1865 #06.
         L_ADOAZON  LIKE /ZAK/ANALITIKA-ADOAZON,
         L_BELNR    LIKE /ZAK/ANALITIKA-BSEG_BELNR,
         L_HKONT    LIKE /ZAK/ANALITIKA-HKONT,
         L_KOSTL    LIKE /ZAK/ANALITIKA-KOSTL,
         L_AUFNR    LIKE /ZAK/ANALITIKA-AUFNR,
         L_ITEM     LIKE /ZAK/ANALITIKA-ITEM,
         L_DATUM(6) TYPE C,
*++1765 #32.
         L_NUMC2    TYPE NUMC2,
*--1765 #32.
         L_INDX(3)  TYPE N.
   DATA COUNT TYPE I.
*++2007.01.11 BG (FMC)
   DATA  L_DATE LIKE SY-DATUM.
   DATA  L_BTYPE_VER.
*--2007.01.11 BG (FMC)
*++0002 BG 2007.07.02
   DATA   LI_BEVALLC_OBLIG LIKE /ZAK/OBLIG_FIELD OCCURS 0 WITH HEADER LINE.
   DATA   LW_XLS TYPE ALSMEX_TABLINE.
*--0002 BG 2007.07.02
*++PTGSZLAA #01. 2014.03.03
   DATA  L_WEEK TYPE KWEEK.
   DATA  L_ROW_SAVE TYPE KCD_EX_ROW_N.
*--PTGSZLAA #01. 2014.03.03
*++1465 #06.
   DATA: L_AMOUNT_EXTERNAL LIKE  BAPICURR-BAPICURR.
*--1465 #06.
*++2108 #01.
   DATA: L_NYLAPAZON TYPE XFELD.
   DATA: L_SOR       TYPE NUMC2.
   DATA: L_SORINDEX  TYPE /ZAK/SORINDEX.
   DATA: L_SORINDEX_MAX  TYPE /ZAK/SORINDEX.
   DATA: L_LAPSZ     TYPE /ZAK/LAPSZ.
*--2108 #01.

   CLEAR V_TAB.
   CONCATENATE 'W_' $V_STRNAME INTO V_TAB.
   ASSIGN (V_TAB) TO <F2>.
*
*++2007.01.11 BG (FMC)
   CLEAR L_BTYPE_VER.
*--2007.01.11 BG (FMC)
*++0002 BG 2007.07.13
*  Fill in the required fields:
   LOOP AT $I_BEVALLC INTO W_/ZAK/BEVALLC WHERE NOT OBLIG IS INITIAL.
     CLEAR  LI_BEVALLC_OBLIG.
     MOVE W_/ZAK/BEVALLC-SZTABLE TO LI_BEVALLC_OBLIG-SZTABLE.
     MOVE W_/ZAK/BEVALLC-SZFIELD TO LI_BEVALLC_OBLIG-SZFIELD.
*    We define the position in the structure:
     READ TABLE $I_DD03P INTO W_DD03P
                        WITH KEY TABNAME   = LI_BEVALLC_OBLIG-SZTABLE
                                 FIELDNAME = LI_BEVALLC_OBLIG-SZFIELD.
     IF SY-SUBRC EQ 0.
       MOVE W_DD03P-POSITION TO LI_BEVALLC_OBLIG-POSITION.
       COLLECT LI_BEVALLC_OBLIG.
     ENDIF.
   ENDLOOP.
*--0002 BG 2007.07.13
*++PTGSZLAA #01. 2014.03.03
   IF W_/ZAK/BEVALLC IS INITIAL.
     READ TABLE $I_BEVALLC INTO W_/ZAK/BEVALLC INDEX 1.
   ENDIF.

*++2108 #01.
*  If the row column structure is filled, then we have to fill it according to
   SELECT SINGLE * INTO W_/ZAK/BEVALLB
                   FROM /ZAK/BEVALLB
                  WHERE BTYPE  EQ W_/ZAK/BEVALLC-BTYPE
                    AND ABEVAZ EQ W_/ZAK/BEVALLC-ABEVAZ.
   IF SY-SUBRC EQ 0 AND NOT W_/ZAK/BEVALLB-NYLAPAZON IS INITIAL.
     REFRESH I_/ZAK/BEVALLB.
     SELECT * INTO TABLE I_/ZAK/BEVALLB
                    FROM /ZAK/BEVALLB
                   WHERE BTYPE     EQ W_/ZAK/BEVALLB-BTYPE
                     AND NYLAPAZON EQ W_/ZAK/BEVALLB-NYLAPAZON.
     IF SY-SUBRC EQ 0.
       SORT I_/ZAK/BEVALLB BY SORINDEX.
       L_NYLAPAZON = 'X'.
       DESCRIBE TABLE I_/ZAK/BEVALLB LINES L_TABIX.
       READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB INDEX L_TABIX.
       L_SORINDEX_MAX = W_/ZAK/BEVALLB-SORINDEX.
       L_LAPSZ = 1.
     ENDIF.
   ENDIF.
*--2108 #01.

*--PTGSZLAA #01. 2014.03.03
   LOOP AT $I_XLS INTO W_XLS.
*++1765 #30.
*In the I_XLS structure, the row value restarts after 9999 due to type N4,
*so the MOVE-CORRESPONDING statement is always from the first 9999 occurrences
*overwritten the values!
*++2108 #01.
     AT NEW ROW.
       ADD 1 TO L_SOR.
     ENDAT.
*--2108 #01.
     IF W_XLS-ROW IS INITIAL AND SY-TABIX IS NOT INITIAL.
*++1865 #06.
*      The line we are on does not need to be deleted, because the first value will be lost!
*      DELETE $I_XLS FROM 1 TO SY-TABIX.
       L_TABIX = SY-TABIX - 1.
       DELETE $I_XLS FROM 1 TO L_TABIX.
*--1865 #06.
     ENDIF.
*--1765 #30.
     IF NOT W_XLS-VALUE IS INITIAL.
       READ TABLE $I_DD03P INTO W_DD03P
                           WITH KEY POSITION = W_XLS-COL.
*++PTGSZLAA #01. 2014.03.03
       IF W_/ZAK/BEVALLC-BTYPE NE C_PTGSZLAA.
*--PTGSZLAA #01. 2014.03.03
         IF W_DD03P-FIELDNAME EQ 'DATUM'.
           CLEAR L_DATUM.
*++1765 #32.
*           CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
*             EXPORTING
*               INPUT      = W_XLS-VALUE
*               NO_MESSAGE = 'X'
*             IMPORTING
*               OUTPUT     = L_DATUM.
**         L_DATUM = W_XLS-VALUE.
           L_DATUM(4) = W_XLS-VALUE(4).
           L_NUMC2    = W_XLS-VALUE+4.
           CONCATENATE L_DATUM L_NUMC2 INTO L_DATUM.
*--1765 #32.
         ENDIF.

ENHANCEMENT-POINT /ZAK/ZAK_TELENOR_READ_02 SPOTS /ZAK/READ_ES .

*++PTGSZLAA #01. 2014.03.03
       ELSEIF W_DD03P-FIELDNAME EQ 'SZAMLAKELT'.
         CLEAR: L_WEEK, L_DATUM.
         L_DATE = W_XLS-VALUE.
*     Determining the number of the week
         CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE' "#EC CI_USAGE_OK[2296016]
           EXPORTING
             DATE = L_DATE
           IMPORTING
             WEEK = L_WEEK
*            MONDAY =
*            SUNDAY =
           .
         L_DATUM = L_WEEK.
       ENDIF.
*--PTGSZLAA #01. 2014.03.03
       READ TABLE I_LINE INTO W_LINE INDEX W_XLS-ROW.
       IF SY-SUBRC EQ 0.
         <F2> = W_LINE.
       ENDIF.
*++PTGSZLAA 2014.03.04 BG (Ness)
*             AT NEW ROW.
       IF L_ROW_SAVE NE W_XLS-ROW.
*--PTGSZLAA 2014.03.04 BG (Ness)
*++0004 2010.03.18 Gábor Balázs (Ness)
         CLEAR W_OUTTAB.
*--0004 2010.03.18 Gábor Balázs (Ness)
*     matching analytics fields to the data structure!
*     If the field name is the same, I fill the table /ZAK/ANALYTICS
         PERFORM MOVE_CORR
*++1465 #13.
                         TABLES  I_HIBA
*--1465 #13.
                          USING  $I_XLS[]
                                 $I_DD03P[]
                                 $I_MAIN_STR[]
                                 W_LINE
                                 W_XLS-ROW
*++1465 #13.
*                             CHANGING W_Outtab
                                 W_OUTTAB.
*--1465 #13.
*++0002 BG 2007.07.13
*              We determine whether the mandatory fields are filled in:
         LOOP AT LI_BEVALLC_OBLIG.
           READ TABLE $I_XLS INTO LW_XLS
                             WITH KEY  ROW = W_XLS-ROW
                                       COL = LI_BEVALLC_OBLIG-POSITION.
           IF SY-SUBRC NE 0 OR LW_XLS-VALUE IS INITIAL OR LW_XLS-VALUE = SPACE.
             CLEAR W_HIBA.
             W_HIBA-/ZAK/ATTRIB   = LI_BEVALLC_OBLIG-SZFIELD.
*                  W_ERROR-/ZAK/F_VALUE = .
             W_HIBA-TABNAME      = LI_BEVALLC_OBLIG-SZTABLE.
             W_HIBA-FIELDNAME    = LI_BEVALLC_OBLIG-SZFIELD.
             W_HIBA-SOR          = W_XLS-ROW.
             W_HIBA-OSZLOP       = LI_BEVALLC_OBLIG-POSITION.
             W_HIBA-ZA_HIBA      = 'Mező értéke kötelező, most üres!'(027).
             APPEND W_HIBA TO I_HIBA.
           ENDIF.
         ENDLOOP.
*--0002 BG 2007.07.13
*++PTGSZLAA 2014.03.04 BG (Ness)
*       ENDAT.
         L_ROW_SAVE = W_XLS-ROW.
       ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
*++2108 #01.
       IF NOT L_NYLAPAZON IS INITIAL.
*        Assembling a row index
         CONCATENATE L_SOR W_DD03P-FIELDNAME INTO L_SORINDEX.
*        We have reached the maximum value, let's start again
         IF L_SORINDEX > L_SORINDEX_MAX.
*          Initialization
           L_SOR = '01'.
*          We are increasing the number of pages
           ADD 1 TO L_LAPSZ.
           CONCATENATE L_SOR W_DD03P-FIELDNAME INTO L_SORINDEX.
         ENDIF.
         READ TABLE I_/ZAK/BEVALLB INTO W_/ZAK/BEVALLB
                                  WITH KEY SORINDEX = L_SORINDEX.
       ELSE.
*--2108 #01.
         READ TABLE $I_BEVALLC INTO W_/ZAK/BEVALLC
                        WITH KEY SZTABLE = W_DD03P-TABNAME
                                 SZFIELD = W_DD03P-FIELDNAME.
*++2108 #01.
       ENDIF.
*--2108 #01.

       IF SY-SUBRC EQ 0.
         CLEAR COUNT.
* I only process fields connected with the ABEV identifier!
         W_OUTTAB-BUKRS   = P_BUKRS.
         W_OUTTAB-BTYPE   = P_BTYPE.
         W_OUTTAB-WAERS   = V_WAERS.
         W_OUTTAB-GJAHR   = L_DATUM(4).
         W_OUTTAB-MONAT   = L_DATUM+4(2).
         W_OUTTAB-ZINDEX  = '000'.
*++2108 #01.
         IF NOT L_NYLAPAZON IS INITIAL.
           W_OUTTAB-LAPSZ = L_LAPSZ.
         ENDIF.
*--2108 #01.
*++2007.01.11 BG (FMC)
         IF L_BTYPE_VER IS INITIAL.
*          Checking BTYPE
*++PTGSZLAA 2014.03.04 BG (Ness)
           IF P_BTYPE EQ C_PTGSZLAA.
             CONCATENATE W_OUTTAB-GJAHR W_OUTTAB-MONAT INTO L_WEEK.
             CALL FUNCTION 'WEEK_GET_FIRST_DAY'
               EXPORTING
                 WEEK = L_WEEK
               IMPORTING
                 DATE = L_DATE
*             EXCEPTIONS
*                WEEK_INVALID       = 1
*                OTHERS             = 2
               .
*++PTGSZLAA 2014.03.04 BG (Ness)
           ENDIF.
*--PTGSZLAA 2014.03.04 BG (Ness)
           IF SY-SUBRC <> 0.
             CLEAR L_DATE.
           ELSE.
             ADD 6 TO L_DATE.
           ENDIF.
         ELSE.
*--PTGSZLAA 2014.03.04 BG (Ness)
           L_DATE(4)   = W_OUTTAB-GJAHR.
           L_DATE+4(2) = W_OUTTAB-MONAT.
           L_DATE+6(2) = '01'.
           CALL FUNCTION 'LAST_DAY_OF_MONTHS' "#EC CI_USAGE_OK[2296016]
             EXPORTING
               DAY_IN            = L_DATE
             IMPORTING
               LAST_DAY_OF_MONTH = L_DATE
             EXCEPTIONS
               DAY_IN_NO_DATE    = 1
               OTHERS            = 2.
           IF SY-SUBRC <> 0.
             CLEAR W_HIBA.
             W_HIBA-/ZAK/ATTRIB   = 'Dátum'(023).
             W_HIBA-/ZAK/F_VALUE  =  L_DATE.
             W_HIBA-ZA_HIBA      = 'Hiba a hónap utolsó nap meghatározásánál!'(024).
             APPEND W_HIBA TO I_HIBA.
           ELSE.
             SELECT SINGLE COUNT( * )
                      FROM /ZAK/BEVALL
                     WHERE BUKRS EQ P_BUKRS
                       AND BTYPE EQ P_BTYPE
                       AND ( DATBI GE L_DATE
                       AND   DATAB LE L_DATE ).
             IF SY-SUBRC NE 0.
               CLEAR W_HIBA.
               W_HIBA-/ZAK/ATTRIB   = 'Bevallás típus'(025).
               W_HIBA-/ZAK/F_VALUE  =  P_BTYPE.
               CONCATENATE TEXT-026 L_DATE INTO W_HIBA-ZA_HIBA
                                           SEPARATED BY SPACE.
               APPEND W_HIBA TO I_HIBA.
             ENDIF.
             MOVE 'X' TO L_BTYPE_VER.
           ENDIF.
         ENDIF.
*--2007.01.11 BG (FMC)
*++2108 #01.
         IF NOT L_NYLAPAZON IS INITIAL.
           W_OUTTAB-ABEVAZ  = W_/ZAK/BEVALLB-ABEVAZ.
         ELSE.
*--2108 #01.
           W_OUTTAB-ABEVAZ  = W_/ZAK/BEVALLC-ABEVAZ.
*++2108 #01.
         ENDIF.
*--2108 #01.
         W_OUTTAB-BSZNUM  = P_BSZNUM.
         W_OUTTAB-PACK    = ' '.
*             W_OUTTAB-ITEM    = W_XLS-ROW.
         CASE W_DD03P-INTTYPE.
* karakteres
           WHEN 'C'.
             W_OUTTAB-FIELD_C = W_XLS-VALUE.
* numerikus
           WHEN 'N' .
             CLEAR V_WNUM.
             CONDENSE W_XLS-VALUE NO-GAPS.
             IF NOT W_XLS-VALUE CO ' -0123456789.,'.
               W_OUTTAB-FIELD_C = W_XLS-VALUE.
             ELSE.
*++1465 #13.
*               DATA: L_NUM(16) TYPE N.
*               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                 EXPORTING
*                   INPUT  = W_XLS-VALUE
*                 IMPORTING
*                   OUTPUT = L_NUM.
**++1465 #06.
*               L_AMOUNT_EXTERNAL = L_NUM.
**--1465 #06.
               CATCH SYSTEM-EXCEPTIONS CONVT_NO_NUMBER = 1
                                       OTHERS          = 2.
                 L_AMOUNT_EXTERNAL = W_XLS-VALUE.
               ENDCATCH.
               IF SY-SUBRC NE 0.
                 CLEAR W_HIBA.
                 W_HIBA-/ZAK/ATTRIB   = W_DD03P-DDTEXT.
                 W_HIBA-/ZAK/F_VALUE  = W_XLS-VALUE.
                 W_HIBA-TABNAME      = W_DD03P-TABNAME.
                 W_HIBA-FIELDNAME    = W_DD03P-FIELDNAME.
                 W_HIBA-SOR          = W_XLS-ROW.
                 W_HIBA-OSZLOP       = W_XLS-COL.
                 W_HIBA-ZA_HIBA      = 'Csak numerikus lehet!'(028).
                 APPEND W_HIBA TO I_HIBA.
                 CONTINUE.
               ENDIF.
*++1465 #13.
*++1465 #06.
*               CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*                 EXPORTING
*                   LOCAL_CURRENCY   = V_WAERS
*                   FOREIGN_CURRENCY = V_WAERS
*                   FOREIGN_AMOUNT   = L_NUM
*                   DATE             = SY-DATUM
*                 IMPORTING
*                   LOCAL_AMOUNT     = W_OUTTAB-FIELD_N.
               CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
                 EXPORTING
                   CURRENCY             = C_HUF
                   AMOUNT_EXTERNAL      = L_AMOUNT_EXTERNAL
                   MAX_NUMBER_OF_DIGITS = 20
                 IMPORTING
                   AMOUNT_INTERNAL      = W_OUTTAB-FIELD_N.
*--1465 #06.
             ENDIF.
           WHEN 'P'.
* The amount field cannot contain a character value!
             IF NOT W_XLS-VALUE CO ' -0123456789.,'.
               W_OUTTAB-FIELD_C = W_XLS-VALUE.
             ELSE.
               W_OUTTAB-FIELD_N = W_XLS-VALUE.
             ENDIF.
         ENDCASE.
         APPEND W_OUTTAB TO I_OUTTAB.
         CLEAR: W_OUTTAB-FIELD_C,W_OUTTAB-FIELD_N.
*++BG 2007.04.18
         CLEAR: W_OUTTAB-HSZU.
*--BG 2007.04.18
       ENDIF.
*++0002 BG 2007.07.02
*       IF NOT W_/ZAK/BEVALLC-OBLIG IS INITIAL AND
*          W_XLS-VALUE IS INITIAL OR W_XLS-VALUE EQ SPACE.
*         CLEAR W_ERROR.
*         W_ERROR-/ZAK/ATTRIB = W_/ZAK/BEVALLC-SZFIELD.
**        W_ERROR-/ZAK/F_VALUE = .
*         W_ERROR-TABNAME = W_/ZAK/BEVALLC-STABLE.
*         W_ERROR-FIELDNAME = W_/ZAK/BEVALLC-SZFIELD.
*         W_ERROR-ROW = W_XLS-ROW.
*         W_ERROR-COLUMN = W_XLS-COL.
*         W_HIBA-ZA_HIBA = 'Field value is mandatory, now empty!'(027).
*         APPEND W_ERROR TO I_ERROR.
*       ENDIF.
*--0002 BG 2007.07.02
     ENDIF.
   ENDLOOP.
* item setting
   SORT I_OUTTAB BY BUKRS BTYPE GJAHR MONAT
   ZINDEX ABEVAZ ADOAZON.
   IF NOT I_OUTTAB[] IS INITIAL.
     LOOP AT I_OUTTAB INTO W_OUTTAB.
       L_ITEM = L_ITEM + 1.
       AT NEW ADOAZON.
         CLEAR L_ITEM.
       ENDAT.
       IF L_ITEM IS INITIAL.
         W_OUTTAB-ITEM = '00001'.
         L_ITEM = '00001'.
       ELSE.
         W_OUTTAB-ITEM = L_ITEM.
       ENDIF.
       MODIFY I_OUTTAB FROM W_OUTTAB TRANSPORTING ITEM.
       L_ADOAZON = W_OUTTAB-ADOAZON.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " FILL_DATATAB
*&---------------------------------------------------------------------*
*&      Form  popup
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VTEXT1  text
*      -->P_VTEXT2  text
*      <--P_V_ANSWER  text
*----------------------------------------------------------------------*
 FORM POPUP USING    $VTEXT1
                     $VTEXT2
            CHANGING $V_ANSWER.
*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*     EXPORTING
*       DEFAULTOPTION = 'N'
*       TEXTLINE1     = V_TEXT1
*       TEXTLINE2     = V_TEXT2
*       TITEL         = V_TITEL
*     IMPORTING
*       ANSWER        = V_ANSWER
*     EXCEPTIONS
*       OTHERS        = 0.
   DATA L_QUESTION TYPE STRING.
   CONCATENATE V_TEXT1 V_TEXT2 INTO L_QUESTION SEPARATED BY SPACE.
*
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR       = V_TITEL
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION  = L_QUESTION
*      TEXT_BUTTON_1  = 'Ja'(001)
*      ICON_BUTTON_1  = ' '
*      TEXT_BUTTON_2  = 'Nein'(002)
*      ICON_BUTTON_2  = ' '
       DEFAULT_BUTTON = '2'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
       START_COLUMN   = 25
       START_ROW      = 6
*      POPUP_TYPE     =
*      IV_QUICKINFO_BUTTON_1       = ' '
*      IV_QUICKINFO_BUTTON_2       = ' '
     IMPORTING
       ANSWER         = V_ANSWER
*   TABLES
*      PARAMETER      =
*   EXCEPTIONS
*      TEXT_NOT_FOUND = 1
*      OTHERS         = 2
     .
   IF V_ANSWER EQ '1'.
     V_ANSWER = 'J'.
   ELSE.
     V_ANSWER = 'N'.
   ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
   IF V_ANSWER NE 'J'.
     MESSAGE S101.
     LEAVE PROGRAM.
   ELSE.
     MESSAGE I003.
     EXIT.
   ENDIF.
 ENDFORM.                    " popup
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
*&---------------------------------------------------------------------*
*&      Form CREATE_AND_INIT_ALV2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_ERROR[] text
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
* Compilation of a field catalog
   PERFORM BUILD_FIELDCAT USING SY-DYNNR
                          CHANGING PT_FIELDCAT.
* Exclusion of functions
*  PERFORM exclude_tb_functions CHANGING lt_exclude.
   PS_LAYOUT-CWIDTH_OPT = 'X'.
* allow to select multiple lines
   PS_LAYOUT-SEL_MODE = 'B'.
   CLEAR PS_VARIANT.
*++2365 #08.
*   PS_VARIANT-REPORT = V_REPID.
*--2365 #08.
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
*&      Form CHECK_BEVALLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM CHECK_BEVALLC USING    $BUKRS
                             $BTYPE
                             $STRNAME
                             $BSZNUM.
   SELECT * INTO TABLE I_/ZAK/BEVALLC FROM /ZAK/BEVALLC
                             WHERE BTYPE   EQ $BTYPE AND
                                   BSZNUM  EQ $BSZNUM AND
                                   SZTABLE EQ $STRNAME.
   IF SY-SUBRC NE 0.
*     MESSAGE E010 WITH $BUKRS $BTYPE .
   ENDIF.
 ENDFORM.                    " CHECK_BEVALLC
*&---------------------------------------------------------------------*
*&      Form  ver_block_b04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_NORM  text
*      -->P_P_ISMET  text
*      -->P_P_PACK  text
*----------------------------------------------------------------------*
 FORM VER_BLOCK_B04 USING    $NORM
                             $ISMET
                             $PACK.
   IF NOT $NORM IS INITIAL AND NOT $PACK IS INITIAL.
     MESSAGE I021.
*   Upload ID ignored!
     CLEAR $PACK.
   ENDIF.
   IF NOT $ISMET IS INITIAL AND $PACK IS INITIAL.
     MESSAGE E022.
*   Please enter the upload ID!
   ENDIF.
   IF NOT $PACK IS INITIAL.
     SELECT SINGLE * FROM /ZAK/BEVALLSZ INTO W_/ZAK/BEVALLSZ
     WHERE BUKRS EQ P_BUKRS AND
           PACK  EQ P_PACK AND
           FLAG  IN ('Z','X').
     IF SY-SUBRC EQ 0.
       MESSAGE E039 WITH P_PACK.
     ENDIF.
   ENDIF.
 ENDFORM.                    " ver_block_b102
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
*    The database does not contain a record that can be processed!
     EXIT.
   ENDIF.
*  We always run it as a test first
   CALL FUNCTION '/ZAK/UPDATE'
     EXPORTING
       I_BUKRS     = P_BUKRS
       I_BTYPE     = P_BTYPE
*++1365 #11.
*     We also specify the BTYPART and then
*     the function determines which BTYPE belongs to it
*     thus, a file can contain several years of data.
       I_BTYPART   = W_/ZAK/BEVALL-BTYPART
*--1365 #11.
       I_BSZNUM    = P_BSZNUM
       I_PACK      = P_PACK
       I_GEN       = 'X'
       I_TEST      = 'X'
       I_FILE      = P_FDIR
     TABLES
       I_ANALITIKA = I_OUTTAB
*++1365 22.01.2013 Gábor Balázs (Ness)
       I_AFA_SZLA  = I_/ZAK/AFA_SZLA
*--1365 22.01.2013 Gábor Balázs (Ness)
       E_RETURN    = E_MESSAGE.
*   Manage messages
   IF NOT E_MESSAGE[] IS INITIAL.
     CALL FUNCTION '/ZAK/MESSAGE_SHOW'
       TABLES
         T_RETURN = E_MESSAGE.
   ENDIF.
*  If it is not a test run, then we check for ERROR
*++2508 #04.
*   IF NOT $TESZT IS INITIAL.
   IF $TESZT IS INITIAL.
*--2508 #04.
     LOOP AT E_MESSAGE INTO W_MESSAGE WHERE TYPE CA 'EA'.
     ENDLOOP.
     IF SY-SUBRC EQ 0.
       MESSAGE E062.
*     Data upload is not possible!
     ENDIF.
   ENDIF.
*  Live operation but there is an error message and not ERROR, question about the continuation
   IF $TESZT IS INITIAL.
*++1765 #31.
*     IF NOT E_MESSAGE[] IS INITIAL.
     IF NOT E_MESSAGE[] IS INITIAL AND SY-BATCH IS INITIAL.
*--1765 #31.
*    Loading texts
       MOVE 'Adatfeltöltés folytatása'(001) TO L_TITLE.
       MOVE 'Adatfeltöltésnél előfordultak figyelmeztető üzenetek'(002)
                                            TO L_DIAGNOSETEXT1.
       MOVE 'Folytatja  feldolgozást?'(003)
                                            TO L_TEXTLINE1.
*++MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*       CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*         EXPORTING
*           DEFAULTOPTION = 'N'
*           DIAGNOSETEXT1 = L_DIAGNOSETEXT1
*           TEXTLINE1     = L_TEXTLINE1
*           TITEL         = L_TITLE
*           START_COLUMN  = 25
*           START_ROW     = 6
*         IMPORTING
*           ANSWER        = L_ANSWER.
       DATA L_QUESTION TYPE STRING.
       CONCATENATE L_DIAGNOSETEXT1
                   L_TEXTLINE1
                   INTO L_QUESTION SEPARATED BY SPACE.
       CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
           TITLEBAR       = L_TITLE
*          DIAGNOSE_OBJECT       = ' '
           TEXT_QUESTION  = L_QUESTION
*          TEXT_BUTTON_1  = 'Ja'(001)
*          ICON_BUTTON_1  = ' '
*          TEXT_BUTTON_2  = 'Nein'(002)
*          ICON_BUTTON_2  = ' '
           DEFAULT_BUTTON = '2'
*          DISPLAY_CANCEL_BUTTON = 'X'
*          USERDEFINED_F1_HELP   = ' '
           START_COLUMN   = 25
           START_ROW      = 6
*          POPUP_TYPE     =
         IMPORTING
           ANSWER         = L_ANSWER.
       IF L_ANSWER EQ '1'.
         MOVE 'J' TO L_ANSWER.
       ENDIF.
*--MOL_UPG_ChangeImp – E09324753 – Gábor Balázs (Ness) - 12.07.2016
*    You can go anyway
     ELSE.
       MOVE 'J' TO L_ANSWER.
     ENDIF.
*    You can modify the database
     IF L_ANSWER EQ 'J'.
*      Modification of data
       CALL FUNCTION '/ZAK/UPDATE'
         EXPORTING
           I_BUKRS     = P_BUKRS
           I_BTYPE     = P_BTYPE
*++1365 #11.
*          We also specify the BTYPART and then
*          the function determines which BTYPE belongs to it
*          thus, a file can contain several years of data.
           I_BTYPART   = W_/ZAK/BEVALL-BTYPART
*--1365 #11.
           I_BSZNUM    = P_BSZNUM
           I_PACK      = P_PACK
           I_GEN       = 'X'
           I_TEST      = $TESZT
           I_FILE      = P_FDIR
         TABLES
           I_ANALITIKA = I_OUTTAB
*++1365 22.01.2013 Gábor Balázs (Ness)
           I_AFA_SZLA  = I_/ZAK/AFA_SZLA
*--1365 22.01.2013 Gábor Balázs (Ness)
           E_RETURN    = E_MESSAGE.
*
       READ TABLE I_OUTTAB INTO W_OUTTAB INDEX 1.
       MOVE W_OUTTAB-PACK TO L_PACK.
       MESSAGE I033 WITH L_PACK.
*      Upload & package number done!
*++PTGSZLAA 2014.03.04 BG (Ness)
*      Move file to ....\old\<filename> directory
       IF NOT P_APPL IS INITIAL.
         REFRESH LI_TAB.
         CLEAR: L_FILE, L_FILE_FROM.
         MOVE P_FDIR TO L_FILE_FROM.
         SPLIT P_FDIR AT '\' INTO TABLE LI_TAB.
         DESCRIBE TABLE LI_TAB LINES L_TABIX.
         LI_TAB = 'old'.
         INSERT LI_TAB INDEX L_TABIX.
         L_FILE = '\'.
         LOOP AT LI_TAB.
           IF NOT LI_TAB IS INITIAL.
             CONCATENATE L_FILE LI_TAB INTO L_FILE SEPARATED BY '\'.
           ENDIF.
         ENDLOOP.
         CLEAR L_PARAM.
         CONCATENATE L_FILE_FROM L_FILE INTO L_PARAM SEPARATED BY SPACE.
         CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
           EXPORTING
             COMMANDNAME                   = 'YMOVE'
             ADDITIONAL_PARAMETERS         = L_PARAM
           EXCEPTIONS
             NO_PERMISSION                 = 1
             COMMAND_NOT_FOUND             = 2
             PARAMETERS_TOO_LONG           = 3
             SECURITY_RISK                 = 4
             WRONG_CHECK_CALL_INTERFACE    = 5
             PROGRAM_START_ERROR           = 6
             PROGRAM_TERMINATION_ERROR     = 7
             X_ERROR                       = 8
             PARAMETER_EXPECTED            = 9
             TOO_MANY_PARAMETERS           = 10
             ILLEGAL_COMMAND               = 11
             WRONG_ASYNCHRONOUS_PARAMETERS = 12
             CANT_ENQ_TBTCO_ENTRY          = 13
             JOBCOUNT_GENERATION_ERROR     = 14
             OTHERS                        = 15.
         IF SY-SUBRC NE 0.
           MESSAGE I902 WITH P_FDIR.
*           Error moving the & file to the "OLD" directory!
         ENDIF.
       ENDIF.
*--TGSZLAA 2014.03.04 BG (Ness)
     ENDIF.
   ENDIF.
 ENDFORM.                    " upd_data
*&---------------------------------------------------------------------*
*&      Form GET_ANALYTICS_STUC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_ANALYSIS text
*----------------------------------------------------------------------*
 FORM GET_ANALITIKA_STUC USING  $ANALITIKA.
   REFRESH: I_MAIN_STR.
   CALL FUNCTION 'DDIF_TABL_GET'
     EXPORTING
       NAME          = $ANALITIKA
       LANGU         = SY-LANGU
     TABLES
       DD03P_TAB     = I_MAIN_STR
     EXCEPTIONS
       ILLEGAL_INPUT = 1
       OTHERS        = 2.
   IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
 ENDFORM.                    " GET_ANALITIKA_STUC
*&---------------------------------------------------------------------*
*&      Form  MOVE_CORR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_XLS[]  text
*      -->P_$I_DD03P[]  text
*      -->P_$I_MAIN_STR[]  text
*      -->P_$I_LINE[]  text
*      <--P_W_OUTTAB  text
*----------------------------------------------------------------------*
 FORM MOVE_CORR
*++1465 #13.
                TABLES   $I_HIBA    STRUCTURE /ZAK/ADAT_HIBA
*--1465 #13.
                USING    $XLS       LIKE I_XLS[]
                         $DD03P     LIKE I_DD03P[]
                         $MAIN_STR  LIKE I_MAIN_STR[]
                         $LINE      LIKE /ZAK/LINE
                         $ROW
*++1465 #13.
*                CHANGING $W_OUTTAB TYPE /ZAK/ANALYTICS
                         $W_OUTTAB  TYPE /ZAK/ANALITIKA.
*--1465 #13.
   DATA: WA_XLS TYPE ALSMEX_TABLINE.
*++1465 #06.
   DATA: L_AMOUNT_EXTERNAL LIKE  BAPICURR-BAPICURR.
*--1465 #06.
*++1765 #32.
   DATA  L_DATUM TYPE DATE.
*--1765 #32.

   CLEAR WA_XLS.
* matching analytics fields to the data structure!
* If the field name is the same, I fill the table /ZAK/ANALYTICS
   LOOP AT $MAIN_STR INTO W_MAIN_STR.
     READ TABLE $DD03P INTO WA_DD03P
                       WITH KEY FIELDNAME = W_MAIN_STR-FIELDNAME .
     IF SY-SUBRC EQ 0.
       READ TABLE $XLS INTO WA_XLS
                      WITH KEY ROW  = $ROW
                               COL = WA_DD03P-POSITION.
       IF SY-SUBRC EQ 0.
         CLEAR V_TAB_FIELD.
         CONCATENATE '$W_OUTTAB' '-' W_MAIN_STR-FIELDNAME
         INTO V_TAB_FIELD.
         ASSIGN (V_TAB_FIELD) TO <F1>.
*++2010.12.09 Balázs Gábor currency management
*++1765 #32.
*         IF W_MAIN_STR-DATATYPE NE 'CURR'.
*           MOVE WA_XLS-VALUE TO <F1>.
*         ELSE.
         IF W_MAIN_STR-DATATYPE EQ 'CURR'.
*--1765 #32.
*++1465 #13.
*           DATA: L_NUM(16) TYPE N.
*           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*             EXPORTING
*               INPUT  = WA_XLS-VALUE
*             IMPORTING
*               OUTPUT = L_NUM.
**++1465 #06.
*           L_AMOUNT_EXTERNAL = L_NUM.
**--1465 #06.
           CATCH SYSTEM-EXCEPTIONS CONVT_NO_NUMBER = 1
                                   OTHERS          = 2.
             L_AMOUNT_EXTERNAL = WA_XLS-VALUE.
           ENDCATCH.
           IF SY-SUBRC NE 0.
             CONTINUE.
           ENDIF.
*--1465 #13.
*++1465 #06.
*           CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*             EXPORTING
*               LOCAL_CURRENCY   = V_WAERS
*               FOREIGN_CURRENCY = V_WAERS
*               FOREIGN_AMOUNT   = L_NUM
*               DATE             = SY-DATUM
*             IMPORTING
*               LOCAL_AMOUNT     = <F1>.
           CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
             EXPORTING
               CURRENCY             = C_HUF
               AMOUNT_EXTERNAL      = L_AMOUNT_EXTERNAL
               MAX_NUMBER_OF_DIGITS = 20
             IMPORTING
               AMOUNT_INTERNAL      = <F1>.
*--1465 #06.
*++1765 #32.
*        In the case of a date, based on the user's date format
*        we convert:
         ELSEIF W_MAIN_STR-DATATYPE EQ 'DATS'.
           CALL FUNCTION '/ZAK/CONV_DATE_USER_2_INTERNAL'
             EXPORTING
               I_INPUT = WA_XLS-VALUE
               I_USER  = SY-UNAME
             IMPORTING
               E_DATE  = L_DATUM.
           MOVE L_DATUM TO <F1>.
         ELSE.
           MOVE WA_XLS-VALUE TO <F1>.
*--1765 #32.
         ENDIF.
*--2010.12.09 Balázs Gábor currency management
       ENDIF.
     ENDIF.
   ENDLOOP.
* kdenes 2006.02.24
*   LOOP AT $I_DD03P INTO WA_DD03P.
**          perform get_field_data using W_DD03P-FIELDNAME
*     IF WA_DD03P-FIELDNAME EQ 'DATUM'.
**             W_OUTTAB-DATUM = W_LINE+COUNT(W_DD03P-INTLEN).
*     ELSEIF WA_DD03P-FIELDNAME EQ 'ADOAZON'.
*       W_OUTTAB-ADOAZON = W_LINE+COUNT(WA_DD03P-INTLEN).
*     ELSEIF WA_DD03P-FIELDNAME EQ 'BSEG_BELNR'.
*       W_OUTTAB-BSEG_BELNR = W_LINE+COUNT(WA_DD03P-INTLEN).
*     ELSEIF WA_DD03P-FIELDNAME EQ 'HKONT'.
*       W_OUTTAB-HKONT = W_LINE+COUNT(WA_DD03P-INTLEN).
*     ELSEIF WA_DD03P-FIELDNAME EQ 'KOSTL'.
*       W_OUTTAB-KOSTL = W_LINE+COUNT(WA_DD03P-INTLEN).
*     ELSEIF WA_DD03P-FIELDNAME EQ 'AUFNR'.
*       W_OUTTAB-AUFNR = W_LINE+COUNT(WA_DD03P-INTLEN).
*     ENDIF.
*     ADD WA_DD03P-INTLEN TO COUNT.
*   ENDLOOP.
 ENDFORM.                    " MOVE_CORR
*&---------------------------------------------------------------------*
*&      Form READ_REVALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BTYPE  text
*----------------------------------------------------------------------*
 FORM READ_BEVALL USING    $BUKRS
                           $BTYPE.
* a declaration type can belong to only one declaration type, thus
* when determining the type of declaration, it is sufficient to examine the first entry!
   SELECT SINGLE * INTO W_/ZAK/BEVALL FROM /ZAK/BEVALL
                        WHERE BUKRS EQ $BUKRS AND
                              BTYPE EQ $BTYPE.
 ENDFORM.                    " READ_BEVALL
*&---------------------------------------------------------------------*
*&      Form GET_ALV_GRID_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_OUTTAB  text
*----------------------------------------------------------------------*
 FORM GET_ALV_GRID_LINE TABLES  $OUTTAB TYPE STANDARD TABLE.
   DATA: L_TABIX LIKE SY-TABIX.
   DATA: L_FROM  LIKE SY-TABIX.
*  We determine the number of rows
   DESCRIBE TABLE $OUTTAB LINES L_TABIX.
   IF L_TABIX > C_MAX_GRID_LINE.
     MESSAGE I174 WITH C_MAX_GRID_LINE.
     L_FROM = C_MAX_GRID_LINE + 1.
*   Limited to display & item due to memory overflow!
     DELETE $OUTTAB FROM L_FROM TO L_TABIX.
   ENDIF.
 ENDFORM.                    " GET_ALV_GRID_LINE
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
*      PERCENTAGE = 0
       TEXT = $TEXT.
 ENDFORM.                    " process_ind
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
*  We will slice the file access.
   SPLIT P_FDIR AT '\' INTO TABLE L_SPLIT.
*  The last one will be the file name.
   DESCRIBE TABLE L_SPLIT LINES L_LINES.
   READ TABLE L_SPLIT INDEX L_LINES.
*  We determine the length of the company
   L_LENGTH = STRLEN( P_BUKRS ).
*  If the file name does not start with the company code:
   IF L_SPLIT-LINE(L_LENGTH) NE P_BUKRS.
     MESSAGE E194 WITH P_BUKRS.
*   Incorrect file! 
   ENDIF.
 ENDFORM.                    " CHECK_BUKRS_FILENAME
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET_APPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM FILENAME_GET_APPL .
   DATA L_NAME       LIKE  SALFILE-LONGNAME.
   DATA LI_FILE_TBL  TYPE TABLE OF  SALFLDIR WITH HEADER LINE.
   DATA LI_RETURN    TYPE TABLE OF  DDSHRETVAL WITH HEADER LINE.
ENHANCEMENT-POINT /ZAK/ZAK_TELENOR_READ_01 SPOTS /ZAK/READ_ES .
   L_NAME = P_FDIR.
   CALL FUNCTION 'RZL_READ_DIR_LOCAL'
     EXPORTING
       NAME               = L_NAME
     TABLES
       FILE_TBL           = LI_FILE_TBL
     EXCEPTIONS
       ARGUMENT_ERROR     = 1
       NOT_FOUND          = 2
       NO_ADMIN_AUTHORITY = 3
       OTHERS             = 4.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
*      DDIC_STRUCTURE         = ' '
       RETFIELD     = 'NAME'
*      PVALKEY      = ' '
*      DYNPPROG     = ' '
*      DYNPNR       = ' '
*      DYNPROFIELD  = ' '
*      STEPL        = 0
       WINDOW_TITLE = 'Fájl megnyitás'
*      VALUE        = ' '
       VALUE_ORG    = 'S'
*      MULTIPLE_CHOICE        = ' '
*      DISPLAY      = ' '
*      CALLBACK_PROGRAM = ' '
*      CALLBACK_FORM          = ' '
*      CALLBACK_METHOD        =
*      MARK_TAB     =
*   IMPORTING
*      USER_RESET   =
     TABLES
       VALUE_TAB    = LI_FILE_TBL
*      FIELD_TAB    =
       RETURN_TAB   = LI_RETURN
*      DYNPFLD_MAPPING        =
*   EXCEPTIONS
*      PARAMETER_ERROR        = 1
*      NO_VALUES_FOUND        = 2
*      OTHERS       = 3
     .
   IF SY-SUBRC <> 0.
* Implement suitable error handling here
     EXIT.
   ELSE.
     READ TABLE LI_RETURN INDEX 1.
     IF NOT LI_RETURN-FIELDVAL IS INITIAL.
       CONCATENATE P_FDIR LI_RETURN-FIELDVAL INTO P_FDIR.
     ENDIF.
   ENDIF.
 ENDFORM.                    " FILENAME_GET_APPL
