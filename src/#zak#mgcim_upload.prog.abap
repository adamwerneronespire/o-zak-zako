*&---------------------------------------------------------------------*
*& Function description: Upload individual address data from CSV format   *
*& Into table /ZAK/MGCIM for the tax certificate function of the /ZAK/ZAKO system          *
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2008.02.28
*& Functional spec by: Róth Nándor  - FMC
*& SAP module name   : /ZAK/ZAKO
*& Program  type     : Report
*& SAP version       : 5.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (Write the OSS note number at the end of the modified lines)*
*&
*& LOG#     DATE        MODIFIER             DESCRIPTION      TRANSPORT
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/MGCIM_UPLOAD MESSAGE-ID /ZAK/ZAK.


*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& CONSTANTS  (C_XXXXXXX..)                                            *
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table       -   (I_xxx...)                              *
*      FORM parameter       -   ($xxxx...)                              *
*      Constant             -   (C_xxx...)                              *
*      Parameter variable   -   (P_xxx...)                              *
*      Selection option     -   (S_xxx...)                              *
*      Range                -   (R_xxx...)                              *
*      Global variables     -   (G_xxx...)                              *
*      Local variables      -   (L_xxx...)                              *
*      Work area            -   (W_xxx...)                              *
*      Type                 -   (T_xxx...)                              *
*      Macros               -   (M_xxx...)                              *
*      Field symbol         -   (FS_xxx...)                             *
*      Method               -   (METH_xxx...)                           *
*      Object               -   (O_xxx...)                              *
*      Class                -   (CL_xxx...)                             *
*      Event                -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
*Data declaration

*File data
TYPES: BEGIN OF T_FILE_DATA,
         ADOAZON TYPE /ZAK/ADOAZON,
         NAME    TYPE /ZAK/NAME,
         POSTCOD TYPE AD_PSTCD1,
         CITY1   TYPE AD_CITY1,
         STREET  TYPE AD_STREET,
*++2108 #15.
         PUBCHAR TYPE /ZAK/PUBCHAR,
*--2108 #15.
         HOUSE   TYPE AD_HSNM1,
         COUNTRY TYPE LAND1,
       END   OF T_FILE_DATA.

DATA I_FILE TYPE STANDARD TABLE OF T_FILE_DATA INITIAL SIZE 0.
DATA W_FILE TYPE T_FILE_DATA.
DATA I_/ZAK/MGCIM TYPE STANDARD TABLE OF /ZAK/MGCIM INITIAL SIZE 0.
DATA W_/ZAK/MGCIM TYPE /ZAK/MGCIM.

DATA G_SUBRC LIKE SY-SUBRC.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
*General selections:
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*File access
PARAMETERS P_PATH TYPE LOCALFILE OBLIGATORY.
*Header row in the file
PARAMETERS P_HEAD AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
*++1765 #19.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2265 #02.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/MGCIM_UPLOAD'.
*--2265 #02.
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
  IF NOT SY-BATCH IS INITIAL.
    MESSAGE E259.
*   The program cannot be executed in the background!
  ENDIF.

*&--------------------------------------------------------------------*
*& AT SELECTION-SCREEN OUTPUT
*&--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
* File open search help
  PERFORM GET_FILENAME CHANGING P_PATH.

*&--------------------------------------------------------------------*
*& START-OF-SELECTION
*&--------------------------------------------------------------------*
START-OF-SELECTION.

  IF NOT SY-BATCH IS INITIAL.
    MESSAGE E259.
*   The program cannot be executed in the background!
  ENDIF.

* Reading data file
  PERFORM OPEN_DATA_FILE TABLES I_FILE
                         USING  ''     "BATCH mode
                                P_PATH
                                P_HEAD
                                G_SUBRC.
  IF NOT G_SUBRC IS INITIAL.
    MESSAGE E082 WITH P_PATH.
*   Error opening file &!
  ENDIF.

* Uploading data
  PERFORM UPLOAD_DATA.

END-OF-SELECTION.
*&--------------------------------------------------------------------*
*& END-OF-SELECTION
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA .

  LOOP AT I_FILE INTO W_FILE.
    MOVE-CORRESPONDING W_FILE TO W_/ZAK/MGCIM.
    MOVE SY-DATUM TO W_/ZAK/MGCIM-DATUM.
    MOVE SY-UZEIT TO W_/ZAK/MGCIM-UZEIT.
    MOVE SY-UNAME TO W_/ZAK/MGCIM-UNAME.
    APPEND W_/ZAK/MGCIM TO I_/ZAK/MGCIM.
  ENDLOOP.

*Database modification
  MODIFY /ZAK/MGCIM FROM TABLE I_/ZAK/MGCIM.
  COMMIT WORK AND WAIT.
  MESSAGE I261.
* Data uploaded!


ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  get_filename
*&---------------------------------------------------------------------*
*       PC file search - for the selection parameter on the F4 key
*----------------------------------------------------------------------*
*      -->$FNAME     text
*----------------------------------------------------------------------*
FORM GET_FILENAME CHANGING $FNAME.

  DATA: LV_DYNPFIELD LIKE DYNPREAD-FIELDNAME,
        LV_FNAME     LIKE IBIPPARMS-PATH.

  LV_FNAME = $FNAME.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      FILE_NAME = LV_FNAME.

  $FNAME = LV_FNAME.

ENDFORM.                    " get_filename

*&---------------------------------------------------------------------*
*&      Form  OPEN_DATA_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_FILE  text
*      -->P_P_PATH  text
*      -->P_P_HEAD  text
*----------------------------------------------------------------------*
FORM OPEN_DATA_FILE  TABLES   $I_FILE LIKE I_FILE
                     USING    $BATCH
                              $PATH
                              $HEAD
                              $SUBRC.

  DATA L_FNAME TYPE STRING.

  DATA: BEGIN OF LI_XLS OCCURS 0,
          LINE TYPE STRING,
        END OF LI_XLS.

  CHECK $BATCH IS INITIAL.

  CLEAR $SUBRC.

  MOVE $PATH TO L_FNAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                = L_FNAME
      FILETYPE                = 'ASC'
*     DAT_MODE                = 'X'
*     HAS_FIELD_SEPARATOR     = 'X'
    TABLES
      DATA_TAB                = LI_XLS
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      OTHERS                  = 17.

  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MOVE SY-SUBRC TO $SUBRC.
  ENDIF.

  IF NOT $HEAD IS INITIAL.
    DELETE LI_XLS INDEX 1.
  ENDIF.

* CSV split
  LOOP AT LI_XLS.
    PERFORM SPLIT_DATA USING LI_XLS-LINE
                    CHANGING W_FILE.
    APPEND W_FILE TO $I_FILE.
  ENDLOOP.

  IF $I_FILE[] IS INITIAL.
    MOVE 4 TO $SUBRC.
* The & file does not contain records that can be processed!
    MESSAGE E260 WITH $PATH.

  ENDIF.


ENDFORM.                    " OPEN_DATA_FILE

*&---------------------------------------------------------------------*
*&      Form  SPLIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_XLS_LINE  text
*      <--P_LW_FILE  text
*----------------------------------------------------------------------*
FORM SPLIT_DATA  USING  $DATA TYPE STRING
              CHANGING  $FILE LIKE W_FILE.

  FIELD-SYMBOLS <F>. " type string.
  DATA LW_DATA TYPE STRING.
  DATA L_TEXT  TYPE STRING.

* Init
  CLEAR: $FILE.
  LW_DATA = $DATA.

* Split
  DO.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE $FILE TO <F>.
    IF SY-SUBRC NE 0. EXIT. ENDIF.
    SPLIT LW_DATA AT ';' INTO L_TEXT LW_DATA.
    CONDENSE L_TEXT.
    <F> = L_TEXT.
  ENDDO.

ENDFORM.                    " SPLIT_DATA
