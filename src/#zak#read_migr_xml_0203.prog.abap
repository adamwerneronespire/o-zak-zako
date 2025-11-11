*&---------------------------------------------------------------------*
*& Report  /ZAK/READ_MIGR_XML_0203
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/READ_MIGR_XML_0203 MESSAGE-ID /ZAK/ZAK.


INCLUDE /ZAK/COMMON_STRUCT.
INCLUDE: /ZAK/READ_TOP.
INCLUDE EXCEL__C.
INCLUDE <ICON>.
*CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.
*&---------------------------------------------------------------------*
*& TÁBLÁK                                                              *
*&---------------------------------------------------------------------*
TABLES: T001.

*&---------------------------------------------------------------------*
*& type-pools
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS.
*&---------------------------------------------------------------------*
*& KONSTANSOK  (C_XXXXXXX..)                                           *
*&---------------------------------------------------------------------*
CONSTANTS: C_CLASS TYPE DD02L-TABCLASS VALUE 'INTTAB',
           C_A TYPE C VALUE 'A'.
CONSTANTS: C_MAX_XLS_LINE TYPE SY-TABIX VALUE 9000.
*&---------------------------------------------------------------------*
*& Munkaterület  (W_XXX..)                                           *
*&---------------------------------------------------------------------*
* struktúra ellenőrzése
DATA: W_DD02L TYPE DD02L.

*&---------------------------------------------------------------------*
*& BELSŐ TÁBLÁK  (I_XXXXXXX..)                                         *
*&   BEGIN OF I_TAB OCCURS ....                                        *
*&              .....                                                  *
*&   END OF I_TAB.                                                     *
*&---------------------------------------------------------------------*

* message
DATA: E_MESSAGE TYPE STANDARD TABLE OF BAPIRET2     INITIAL SIZE 0.
* message
DATA: W_MESSAGE TYPE BAPIRET2.
* adatszerkezet hiba
DATA: W_HIBA    TYPE /ZAK/ADAT_HIBA.

*&---------------------------------------------------------------------*
*& PROGRAM VÁLTOZÓK                                                    *
*      Sorozatok (Range)   -   (R_xxx...)                              *
*      Globális változók   -   (V_xxx...)                              *
*      Munkaterület        -   (W_xxx...)                              *
*      Típus               -   (T_xxx...)                              *
*      Makrók              -   (M_xxx...)                              *
*      Field-symbol        -   (FS_xxx...)                             *
*      Methodus            -   (METH_xxx...)                           *
*      Objektum            -   (O_xxx...)                              *
*      Osztály             -   (CL_xxx...)                             *
*      Esemény             -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA: V_BTYPE   LIKE /ZAK/BEVALL-BTYPE.
DATA: V_BTYPART TYPE /ZAK/BTYPART.

DATA: V_TYPE    LIKE /ZAK/BEVALLD-FILETYPE,
      V_STRNAME LIKE /ZAK/BEVALLD-STRNAME.

DATA: I_OUTTAB TYPE STANDARD TABLE OF /ZAK/ANALITIKA INITIAL SIZE 0.
DATA: W_OUTTAB  TYPE /ZAK/ANALITIKA.

* Hiba adaszerkezet tábla
DATA: I_HIBA TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA   INITIAL SIZE 0.
* ALV kezelési változók
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
*V_EVENT_RECEIVER  TYPE REF TO LCL_EVENT_RECEIVER,
*V_EVENT_RECEIVER2 TYPE REF TO LCL_EVENT_RECEIVER,
V_STRUC     TYPE DD02L-TABNAME.
* popup üzenethez
DATA: V_TEXT1(40) TYPE C,
      V_TEXT2(40) TYPE C,
      V_TITEL     TYPE C,
      V_ANSWER.
* file ellenörzése
DATA: LV_ACTIVE TYPE ABAP_BOOL.
DATA: V_WNUM(30) TYPE N,
      V_WAERS LIKE T001-WAERS.

*++BG 2007.02.12
DATA: V_XLS_LINE TYPE SY-TABIX VALUE 5000.
*--BG 2007.02.12

* field symbol
FIELD-SYMBOLS <FS> TYPE ANY.

*++0002 BG 2007.07.02
*MAKRO definiálás range feltöltéshez
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

*XML beolvasáshiz
TYPES: BEGIN OF T_DATA_LINE,
          ELEMENT(50) TYPE C,
          ATTRIB(50) TYPE C,
          VALUE(50) TYPE C,
       END OF T_DATA_LINE.

DATA: I_DATA_TABLE      TYPE TABLE OF T_DATA_LINE,
      W_DATA_LINE       TYPE T_DATA_LINE.
DATA L_SUBRC LIKE SY-SUBRC.

*&---------------------------------------------------------------------*
*& PARAMÉTEREK  (P_XXXXXXX..)                                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& SZELEKT-OPCIÓK (S_XXXXXXX..)                                        *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-B01.

PARAMETERS: P_FDIR LIKE FC03TAB-PL00_FILE          OBLIGATORY.
PARAMETERS: P_CDIR LIKE FC03TAB-PL00_FILE."          OBLIGATORY.

SELECTION-SCREEN END OF BLOCK B01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FDIR.
  PERFORM FILENAME_GET  USING P_FDIR.
  PERFORM FILENAME_SAVE USING P_CDIR.

START-OF-SELECTION.
* XML fájl beolvasása
  PERFORM UPLOAD_XML_TO_TABLE TABLES I_DATA_TABLE
                               USING P_FDIR
                                     L_SUBRC.


END-OF-SELECTION.

  WRITE:/'OK'.

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
*&      Form  FILENAME_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CDIR  text
*----------------------------------------------------------------------*
FORM FILENAME_SAVE  USING    $FILE.

  DATA: L_DEF_FILENAME TYPE STRING,
       L_FILENAME TYPE STRING,
       L_FILTER   TYPE STRING,
       L_PATH     TYPE STRING,
*      L_FULLPATH TYPE STRING,
*++MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
*        L_FULLPATH     LIKE RLGRAP-FILENAME,
        L_FULLPATH     TYPE STRING,
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12
       L_ACTION   TYPE I.


  DATA: L_MASK(20)   TYPE C VALUE ',*.csv  ,*.*.'.
  DATA L_EXTENSION TYPE STRING.
  DATA L_TITLE     TYPE STRING.
  DATA L_FILE      TYPE STRING.
*  DATA L_FULLPATH  TYPE STRING.

  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      WINDOW_TITLE = 'Output fájl'
*     DEFAULT_EXTENSION =
*++1765 #07.
      DEFAULT_FILE_NAME  = L_DEF_FILENAME
*--1765 #07.
*     WITH_ENCODING     =
      FILE_FILTER  = '*.CSV'
*     INITIAL_DIRECTORY =
*     DEFAULT_ENCODING  =
    IMPORTING
*     FILENAME     =
*     PATH         =
      FULLPATH     = L_FULLPATH
*     USER_ACTION  =
*     FILE_ENCODING     =
    .
*--MOL_UPG_ChangeImp – E09324753 – Balázs Gábor (Ness) - 2016.07.12

  CHECK SY-SUBRC EQ 0.
  $FILE = L_FULLPATH.
* -- 0001 CST 2006.05.27

ENDFORM.                    " FILENAME_SAVE
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_XML_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_XML_TO_TABLE TABLES $I_DATA STRUCTURE W_DATA_LINE
                         USING  $FILE
                                $SUBRC.

  TYPES: BEGIN OF LT_XML_LINE,
          DATA(256) TYPE X,
        END OF LT_XML_LINE.

  DATA: L_IXML            TYPE REF TO IF_IXML,
        L_STREAMFACTORY   TYPE REF TO IF_IXML_STREAM_FACTORY,
        L_PARSER          TYPE REF TO IF_IXML_PARSER,
        L_ISTREAM         TYPE REF TO IF_IXML_ISTREAM,
        L_DOCUMENT        TYPE REF TO IF_IXML_DOCUMENT,
        L_NODE            TYPE REF TO IF_IXML_NODE,
        L_XMLDATA         TYPE STRING.

  DATA: L_ELEM            TYPE REF TO IF_IXML_ELEMENT,
        L_ROOT_NODE       TYPE REF TO IF_IXML_NODE,
        L_NEXT_NODE       TYPE REF TO IF_IXML_NODE,
        L_NAME            TYPE STRING,
        L_ITERATOR        TYPE REF TO IF_IXML_NODE_ITERATOR.

  DATA: L_XML_TABLE       TYPE TABLE OF LT_XML_LINE,
        L_XML_LINE        TYPE LT_XML_LINE,
        L_XML_TABLE_SIZE  TYPE I.
*  DATA: L_FILENAME        TYPE STRING.
  DATA: L_FILENAME        LIKE RLGRAP-FILENAME.

  CLEAR $SUBRC.

* Creating the main iXML factory
  CALL METHOD CL_IXML=>CREATE
    RECEIVING
      RVAL = L_IXML.

* Creating a stream factory
  L_STREAMFACTORY = L_IXML->CREATE_STREAM_FACTORY( ).

  MOVE $FILE TO L_FILENAME.
* ++ 0001 CST 2006.05.27
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
*  EXPORTING
*      FILENAME = L_FILENAME
*      FILETYPE = 'BIN'
*  IMPORTING
*      FILELENGTH = L_XML_TABLE_SIZE
*  CHANGING
*      DATA_TAB = L_XML_TABLE
*  EXCEPTIONS
*      FILE_OPEN_ERROR         = 1
*      FILE_READ_ERROR         = 2
*      NO_BATCH                = 3
*      GUI_REFUSE_FILETRANSFER = 4
*      INVALID_TYPE            = 5
*      NO_AUTHORITY            = 6
*      UNKNOWN_ERROR           = 7
*      BAD_DATA_FORMAT         = 8
*      HEADER_NOT_ALLOWED      = 9
*      SEPARATOR_NOT_ALLOWED   = 10
*      HEADER_TOO_LONG         = 11
*      UNKNOWN_DP_ERROR        = 12
*      ACCESS_DENIED           = 13
*      DP_OUT_OF_MEMORY        = 14
*      DISK_FULL               = 15
*      DP_TIMEOUT              = 16
*      OTHERS                  = 17.

*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27
*  CALL FUNCTION 'WS_UPLOAD'
*    EXPORTING
**   CODEPAGE                      = ' '
*      FILENAME                      = L_FILENAME
*      FILETYPE                      = 'BIN'
**   HEADLEN                       = ' '
**   LINE_EXIT                     = ' '
**   TRUNCLEN                      = ' '
**   USER_FORM                     = ' '
**   USER_PROG                     = ' '
**   DAT_D_FORMAT                  = ' '
*    IMPORTING
*      FILELENGTH                    = L_XML_TABLE_SIZE
*    TABLES
*      DATA_TAB                      = L_XML_TABLE[]
*   EXCEPTIONS
*     CONVERSION_ERROR              = 1
*     FILE_OPEN_ERROR               = 2
*     FILE_READ_ERROR               = 3
*     INVALID_TYPE                  = 4
*     NO_BATCH                      = 5
*     UNKNOWN_ERROR                 = 6
*     INVALID_TABLE_WIDTH           = 7
*     GUI_REFUSE_FILETRANSFER       = 8
*     CUSTOMER_ERROR                = 9
*     OTHERS                        = 10.

* -- 0001 CST 2006.05.27
  DATA L_FILENAME_STRING TYPE STRING.

  MOVE L_FILENAME TO L_FILENAME_STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME                = L_FILENAME_STRING
      FILETYPE                = 'BIN'
    IMPORTING
      FILELENGTH              = L_XML_TABLE_SIZE
    CHANGING
      DATA_TAB                = L_XML_TABLE[]
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
      NOT_SUPPORTED_BY_GUI    = 17
      ERROR_NO_GUI            = 18
      OTHERS                  = 19.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27
  IF SY-SUBRC NE 0.
    MOVE 1 TO $SUBRC.
    EXIT.
  ENDIF.

* wrap the table containing the file into a stream
  L_ISTREAM = L_STREAMFACTORY->CREATE_ISTREAM_ITABLE(
  TABLE = L_XML_TABLE
  SIZE = L_XML_TABLE_SIZE ).

* Creating a document
  L_DOCUMENT = L_IXML->CREATE_DOCUMENT( ).

  L_PARSER = L_IXML->CREATE_PARSER( STREAM_FACTORY = L_STREAMFACTORY
  ISTREAM = L_ISTREAM
  DOCUMENT = L_DOCUMENT ).

* Parse the stream
  IF L_PARSER->PARSE( ) NE 0.
    IF L_PARSER->NUM_ERRORS( ) NE 0.
      MOVE 2 TO $SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

*   Create a Parser
  L_PARSER = L_IXML->CREATE_PARSER( STREAM_FACTORY = L_STREAMFACTORY
                                    ISTREAM        = L_ISTREAM
                                    DOCUMENT       = L_DOCUMENT ).


*   Process the document
  IF L_PARSER->IS_DOM_GENERATING( ) EQ 'X'.
    PERFORM PROCESS_DOM TABLES $I_DATA
                         USING L_DOCUMENT.
  ENDIF.




ENDFORM.                    " UPLOAD_XML_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$I_DATA  text
*      -->P_L_DOCUMENT  text
*----------------------------------------------------------------------*
FORM PROCESS_DOM TABLES   $I_DATA STRUCTURE W_DATA_LINE
                 USING    DOCUMENT TYPE REF TO IF_IXML_DOCUMENT.


  DATA: NODE      TYPE REF TO IF_IXML_NODE,
        ITERATOR  TYPE REF TO IF_IXML_NODE_ITERATOR,
        NODEMAP   TYPE REF TO IF_IXML_NAMED_NODE_MAP,
        ATTR      TYPE REF TO IF_IXML_NODE,
        NAME      TYPE STRING,
        PREFIX    TYPE STRING,
        VALUE     TYPE STRING,
        COUNT     TYPE I,
        INDEX     TYPE I.


  NODE ?= DOCUMENT.

  CHECK NOT NODE IS INITIAL.

  IF NODE IS INITIAL. EXIT. ENDIF.
*   create a node iterator
  ITERATOR  = NODE->CREATE_ITERATOR( ).
*   get current node
  NODE = ITERATOR->GET_NEXT( ).

  CLEAR W_DATA_LINE.

*   loop over all nodes
  WHILE NOT NODE IS INITIAL.

    CASE NODE->GET_TYPE( ).
      WHEN IF_IXML_NODE=>CO_NODE_ELEMENT.
*         element node
        NAME    = NODE->GET_NAME( ).
        NODEMAP = NODE->GET_ATTRIBUTES( ).
        MOVE NAME TO W_DATA_LINE-ELEMENT.

        IF NOT NODEMAP IS INITIAL.
*           attributes
          COUNT = NODEMAP->GET_LENGTH( ).
          DO COUNT TIMES.
            INDEX  = SY-INDEX - 1.
            ATTR   = NODEMAP->GET_ITEM( INDEX ).
            NAME   = ATTR->GET_NAME( ).
            VALUE  = ATTR->GET_VALUE( ).
            MOVE NAME  TO W_DATA_LINE-ELEMENT.
            MOVE VALUE TO W_DATA_LINE-ATTRIB.
          ENDDO.
        ENDIF.
      WHEN IF_IXML_NODE=>CO_NODE_TEXT OR
           IF_IXML_NODE=>CO_NODE_CDATA_SECTION.
*       text node
        VALUE  = NODE->GET_VALUE( ).
        MOVE VALUE TO W_DATA_LINE-VALUE.
        APPEND W_DATA_LINE TO $I_DATA.
        CLEAR W_DATA_LINE.
    ENDCASE.
*     advance to next node
    NODE = ITERATOR->GET_NEXT( ).
  ENDWHILE.

ENDFORM.                    " PROCESS_DOM
