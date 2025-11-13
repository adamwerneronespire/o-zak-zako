*&---------------------------------------------------------------------*
*& Report  /ZAK/TABLE_UPLOAD
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*


REPORT  /ZAK/TABLE_UPLOAD MESSAGE-ID /ZAK/ZAK.

TYPE-POOLS : ABAP.
INCLUDE /ZAK/COMMON_STRUCT.

DATA: I_XLS TYPE STANDARD TABLE OF ALSMEX_TABLINE INITIAL SIZE 0 .
DATA: W_XLS TYPE ALSMEX_TABLINE.

DATA: I_/ZAK/ABEVK    TYPE STANDARD TABLE OF /ZAK/ABEVK INITIAL SIZE 0 .
DATA: I_/ZAK/AFA_ATV  TYPE STANDARD TABLE OF /ZAK/AFA_ATV INITIAL SIZE 0 .
DATA: I_/ZAK/AFA_CUST TYPE STANDARD TABLE OF /ZAK/AFA_CUST INITIAL SIZE 0
.
DATA: I_/ZAK/AFA_RARANY TYPE STANDARD TABLE OF /ZAK/AFA_RARANY INITIAL
SIZE 0 .
DATA: I_/ZAK/BNYLAP TYPE STANDARD TABLE OF /ZAK/BNYLAP INITIAL SIZE 0 .
DATA: I_/ZAK/HRSZU TYPE STANDARD TABLE OF /ZAK/HRSZU INITIAL SIZE 0 .
DATA: I_/ZAK/KFILE TYPE STANDARD TABLE OF /ZAK/KFILE INITIAL SIZE 0 .
DATA: I_/ZAK/ONELL_BOOK TYPE STANDARD TABLE OF /ZAK/ONELL_BOOK INITIAL
SIZE 0 .
DATA: I_/ZAK/SZJA_ABEV TYPE STANDARD TABLE OF /ZAK/SZJA_ABEV INITIAL SIZE
0 .
DATA: I_/ZAK/SZJA_CUST TYPE STANDARD TABLE OF /ZAK/SZJA_CUST INITIAL SIZE
0 .
DATA: I_/ZAK/VPOP_LIFNR TYPE STANDARD TABLE OF /ZAK/VPOP_LIFNR INITIAL
SIZE 0 .

DATA I_/ZAK/T5HVC TYPE STANDARD TABLE OF /ZAK/T5HVC INITIAL
SIZE 0 .

DATA I_/ZAK/T5HVX TYPE STANDARD TABLE OF /ZAK/T5HVX INITIAL
SIZE 0 .


DATA L_FILENAME TYPE STRING.

DEFINE R_GUI_UPLOAD.

  MOVE &1 TO L_FILENAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = L_FILENAME
      FILETYPE                      = 'ASC'
      HAS_FIELD_SEPARATOR           = 'X'
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
      DAT_MODE                      = 'X'
*   CODEPAGE                      = ' '
*   ignore_cerr                   = abap_true
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
    TABLES
      DATA_TAB                      = I_&2&3
   EXCEPTIONS
     FILE_OPEN_ERROR               = 1
     FILE_READ_ERROR               = 2
     NO_BATCH                      = 3
     GUI_REFUSE_FILETRANSFER       = 4
     INVALID_TYPE                  = 5
     NO_AUTHORITY                  = 6
     UNKNOWN_ERROR                 = 7
     BAD_DATA_FORMAT               = 8
     HEADER_NOT_ALLOWED            = 9
     SEPARATOR_NOT_ALLOWED         = 10
     HEADER_TOO_LONG               = 11
     UNKNOWN_DP_ERROR              = 12
     ACCESS_DENIED                 = 13
     DP_OUT_OF_MEMORY              = 14
     DISK_FULL                     = 15
     DP_TIMEOUT                    = 16
     OTHERS                        = 17
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    R_INSERT_TABLE &2 &3 &4.
  ENDIF.

END-OF-DEFINITION.

DATA: L_SEL(100).

DEFINE R_INSERT_TABLE.
  IF &3 EQ 'B'.
*    DELETE FROM &1_&2 CLIENT SPECIFIED WHERE MANDT = SY-MANDT
*                                         AND BTYPE IN S_BTYPE.
    L_SEL = ' MANDT = SY-MANDT AND BTYPE IN S_BTYPE '.
  ELSE.
*   DELETE FROM &1_&2 CLIENT SPECIFIED WHERE MANDT = SY-MANDT.
    L_SEL = ' MANDT = SY-MANDT '.
  ENDIF.
  DELETE FROM &1&2 CLIENT SPECIFIED WHERE (L_SEL).
  INSERT &1&2 FROM TABLE I_&1&2 ACCEPTING DUPLICATE KEYS.
  IF SY-SUBRC NE 0.
    MESSAGE I000 WITH 'INPUT-ban előfordulnak duplikációk!'(004).
  ENDIF.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*& PARAMETERS  (P_XXXXXXX..)
*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SELECTION OPTIONS (S_XXXXXXX..)
*
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.
*++2065 #02.
*SELECT-OPTIONS s_btype FOR /zak/bevall-btype.
  SELECT-OPTIONS S_BTYPE FOR /ZAK/BEVALL-BTYPE OBLIGATORY.
*--2065 #02.

*++S4HANA#01.
*PARAMETERS p_file  TYPE file  OBLIGATORY.  "fc03tab-pl00_file
  PARAMETERS P_FILE  TYPE ICMFILENAME  OBLIGATORY.  "fc03tab-pl00_file
*--S4HANA#01.

  PARAMETERS P_TABLE TYPE  /ZAK/TABLE_UPLOAD OBLIGATORY.

SELECTION-SCREEN END OF BLOCK B01.


*-----------------------------------------------------------------------
*       INITIALIZATION
*-----------------------------------------------------------------------
INITIALIZATION.
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
AT SELECTION-SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM FILENAME_GET.


START-OF-SELECTION.

* Load data
  CASE P_TABLE.
    WHEN 'ABEVK'.
      R_GUI_UPLOAD P_FILE /ZAK/ ABEVK 'B'.
    WHEN 'ADONEM'.
      R_GUI_UPLOAD P_FILE /ZAK/ ADONEM SPACE.
    WHEN 'ADONEMT'.
      R_GUI_UPLOAD P_FILE /ZAK/ ADONEMT SPACE.
    WHEN 'AFA_ALAP'.
      R_GUI_UPLOAD P_FILE /ZAK/ AFA_ALAP 'B'.
    WHEN 'AFA_ARABEV'.
      R_GUI_UPLOAD P_FILE /ZAK/ AFA_ARABEV 'B'.
    WHEN 'AFA_ATV'.
      R_GUI_UPLOAD P_FILE /ZAK/ AFA_ATV 'B'.
    WHEN 'AFA_CUST'.
      R_GUI_UPLOAD P_FILE /ZAK/ AFA_CUST 'B'.
    WHEN 'AFA_RARANY'.
      R_GUI_UPLOAD P_FILE /ZAK/ AFA_RARANY SPACE.
    WHEN 'AFA_RRABEV'.
      R_GUI_UPLOAD P_FILE /ZAK/ AFA_RRABEV 'B'.
    WHEN 'ARANY_CUST'.
      R_GUI_UPLOAD P_FILE /ZAK/ ARANY_CUST SPACE.
    WHEN 'BEVALL'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALL 'B'.
    WHEN 'BEVALLT'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLT 'B'.
    WHEN 'BEVALLB'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLB 'B'.
    WHEN 'BEVALLBT'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLBT 'B'.
    WHEN 'BEVALLC'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLC 'B'.
    WHEN 'BEVALLD'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLD 'B'.
    WHEN 'BEVALLDT'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLDT 'B'.
    WHEN 'BEVALLDEF'.
      R_GUI_UPLOAD P_FILE /ZAK/ BEVALLDEF 'B'.
    WHEN 'BNYLAP'.
      R_GUI_UPLOAD P_FILE /ZAK/ BNYLAP SPACE.
    WHEN 'HRSZU'.
      R_GUI_UPLOAD P_FILE /ZAK/ HRSZU SPACE.
    WHEN 'IGSOR'.
      R_GUI_UPLOAD P_FILE /ZAK/ IGSOR SPACE.
    WHEN 'IGSORT'.
      R_GUI_UPLOAD P_FILE /ZAK/ IGSORT SPACE.
    WHEN 'KFILE'.
      R_GUI_UPLOAD P_FILE /ZAK/ KFILE 'B'.
    WHEN 'MGCIM'.
      R_GUI_UPLOAD P_FILE /ZAK/ MGCIM SPACE.
    WHEN 'ONELL_BOOK'.
      R_GUI_UPLOAD P_FILE /ZAK/ ONELL_BOOK SPACE.
    WHEN 'SZJA_ABEV'.
      R_GUI_UPLOAD P_FILE /ZAK/ SZJA_ABEV 'B'.
    WHEN 'SZJA_CUST'.
      R_GUI_UPLOAD P_FILE /ZAK/ SZJA_CUST 'B'.
    WHEN 'VPOP_LIFNR'.
      R_GUI_UPLOAD P_FILE /ZAK/ VPOP_LIFNR SPACE.
    WHEN 'IGABEV'.
      R_GUI_UPLOAD P_FILE /ZAK/ IGABEV 'B'.
    WHEN 'T5HVC'.
      R_GUI_UPLOAD P_FILE /ZAK/ T5HVC SPACE.
    WHEN 'T5HVX'.
      PERFORM INS_T5HVX.
    WHEN OTHERS.
      MESSAGE I000 WITH TEXT-003. "This table cannot be processed.
*   & & & &
      EXIT.
  ENDCASE.


END-OF-SELECTION.

  COMMIT WORK AND WAIT.
  MESSAGE I007.
*   Table modifications completed!



*&---------------------------------------------------------------------*
*&      Form  filename_get
*&---------------------------------------------------------------------*
*       Enter the file path
*----------------------------------------------------------------------*
FORM FILENAME_GET.
  DATA:
*    L_MASK(20),
    L_FNAM(8),
    L_INX(3),
    L_RC       TYPE I,
    L_FILENAME LIKE P_FILE,
    LT_FILE    TYPE FILETABLE,
    L_MULTISEL TYPE I,
    L_FILTER   TYPE STRING.

  L_FILTER = '*.TXT'.

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

*++S4HANA#01.
**++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
**  CALL FUNCTION 'WS_FILENAME_GET'
**     EXPORTING  def_filename     =  l_filter
***               def_path         =
**                mask             =  l_mask
**                mode             = 'O'
**                title            =  sy-title
**     IMPORTING  filename         =  p_file
***               RC               =  DUMMY
**     EXCEPTIONS inv_winsys       =  04
**                no_batch         =  08
**                selection_cancel =  12
**                selection_error  =  16.
*
**                SELECTION_ERROR  =  16.
*  DATA L_EXTENSION TYPE STRING.
*  DATA L_TITLE     TYPE STRING.
*  DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.
*
*  L_TITLE = SY-TITLE.
*  L_EXTENSION = L_MASK.
*
*  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
*    EXPORTING
*      WINDOW_TITLE = L_TITLE
**     DEFAULT_EXTENSION = L_EXTENSION
**     DEFAULT_FILE_NAME =
**     WITH_ENCODING     =
*      FILE_FILTER  = L_FILTER
**     INITIAL_DIRECTORY =
*    IMPORTING
**     FILENAME     = L_FILE
**     PATH         =
*      FULLPATH     = L_FULLPATH
**     USER_ACTION  =
**     FILE_ENCODING     =
*    .
*  P_FILE = L_FULLPATH.
**--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
  DATA: LT_FILE_TABLE_0     TYPE FILETABLE,
        LS_W_FILE_TABLE_0   LIKE LINE OF LT_FILE_TABLE_0,
        LV_W_RC_0           TYPE I,
        LV_W_TITLE_0        TYPE STRING,
        LV_W_SYSUBRC_TEMP_0 TYPE SY-SUBRC.

  DATA: LV_W_DEFAULT_FILENAME_0 TYPE STRING.
  LV_W_DEFAULT_FILENAME_0 = L_FILTER.

  LV_W_TITLE_0 = SY-TITLE.

  DATA: LV_W_FILE_FILTER_0 TYPE STRING.
  LV_W_FILE_FILTER_0 = L_MASK.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE     = LV_W_TITLE_0
      DEFAULT_FILENAME = LV_W_DEFAULT_FILENAME_0
      FILE_FILTER      = LV_W_FILE_FILTER_0
      WITH_ENCODING    = ABAP_FALSE
      MULTISELECTION   = SPACE
    CHANGING
      FILE_TABLE       = LT_FILE_TABLE_0
      RC               = LV_W_RC_0
    EXCEPTIONS
      OTHERS           = 4.
  LV_W_SYSUBRC_TEMP_0 = SY-SUBRC.

  READ TABLE LT_FILE_TABLE_0 INTO LS_W_FILE_TABLE_0 INDEX 1.
  IF SY-SUBRC = 0.
    P_FILE = LS_W_FILE_TABLE_0-FILENAME.
  ENDIF.

  SY-SUBRC = LV_W_SYSUBRC_TEMP_0.
*--S4HANA#01.

  CHECK SY-SUBRC EQ 0.
ENDFORM.                    " FILENAME_GET



*   SORT I_SZJA001 BY DATUM.
*   LOOP AT I_SZJA001 INTO W_SZJA001.
*     AT END OF DATUM.
*       W_BEVALLI-DATUM = W_SZJA001-DATUM.
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
*         IF     W_/ZAK/BEVALLI-FLAG EQ 'X'.
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
*         ELSEIF W_/ZAK/BEVALLI-ZINDEX NE '000'.
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
*&      Form  READ_EXCEL_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_EXCEL_FILE USING $FILE
                           $TABLE.

  DATA L_FILENAME LIKE  RLGRAP-FILENAME.
  DATA L_END_COL   TYPE I.

  MOVE $FILE TO L_FILENAME.
*++S4HANA#01.
*  REFRESH I_XLS.
  CLEAR I_XLS[].
*--S4HANA#01.

* Field checks belonging to the data structure, and
* determining the number of columns.
*++S4HANA#01.
*  PERFORM CHECK_FIELDTYP(/ZAK/READ_FILE) USING    $TABLE
  PERFORM CHECK_FIELDTYP IN PROGRAM /ZAK/READ_FILE USING    $TABLE
                                         CHANGING L_END_COL.
*--S4HANA#01.


*  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*       EXPORTING
*            filename                = l_filename
*            i_begin_col             = 1
*            i_begin_row             = 1
*            i_end_col               = l_end_col
*            i_end_row               = 65536
*       TABLES
*            intern                  = i_xls
*       EXCEPTIONS
*            inconsistent_parameters = 1
*            upload_ole              = 2
*            OTHERS                  = 3.
*   IF sy-subrc NE 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*   ENDIF.


ENDFORM.                    " READ_EXCEL_FILE
*&---------------------------------------------------------------------*
*&      Form  INS_T5HVX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INS_T5HVX .


  MOVE P_FILE TO L_FILENAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                = L_FILENAME
      FILETYPE                = 'ASC'
      HAS_FIELD_SEPARATOR     = 'X'
*     HEADER_LENGTH           = 0
*     READ_BY_LINE            = 'X'
      DAT_MODE                = 'X'
*     CODEPAGE                = ' '
*     ignore_cerr             = abap_true
*     REPLACEMENT             = '#'
*     CHECK_BOM               = ' '
*     VIRUS_SCAN_PROFILE      =
*     NO_AUTH_CHECK           = ' '
* IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    TABLES
      DATA_TAB                = I_/ZAK/T5HVX
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
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    DELETE FROM /ZAK/T5HVX.                             "#EC CI_NOWHERE
    INSERT /ZAK/T5HVX FROM TABLE I_/ZAK/T5HVX.
  ENDIF.

ENDFORM.                                                    " INS_T5HVX
