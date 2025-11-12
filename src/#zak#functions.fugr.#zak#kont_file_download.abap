FUNCTION /ZAK/KONT_FILE_DOWNLOAD.
*"----------------------------------------------------------------------
*"* Local interface:
*"  TABLES
*"      T_/ZAK/BEVALLALV STRUCTURE  /ZAK/BEVALLALV OPTIONAL
*"  CHANGING
*"     VALUE(I_FILE) TYPE  STRING OPTIONAL
*"  EXCEPTIONS
*"      ERROR_CUST_FILE_DATA
*"      ERROR_T001Z
*"      ERROR_FILE_DOWNLOAD
*"----------------------------------------------------------------------
* Parameter type
  CONSTANTS C_PARTY LIKE T001Z-PARTY VALUE 'YHRASZ'.

  DATA: L_FILENAME LIKE RLGRAP-FILENAME.



  DATA: LI_BEVALLO TYPE /ZAK/BEVALLALV OCCURS 0,
        LW_BEVALLO TYPE /ZAK/BEVALLALV,
        LW_BEVALLO_TMP TYPE /ZAK/BEVALLALV.

  DATA: LI_KFILE TYPE /ZAK/KFILE OCCURS 0,
        LW_KFILE TYPE /ZAK/KFILE.

  DATA: BEGIN OF LI_FILE OCCURS 0,
        LINE(5000),
        END OF LI_FILE.

  DATA  LW_FILE LIKE LI_FILE.
  DATA  L_PAVAL LIKE T001Z-PAVAL.

  DATA  L_SORSZ TYPE NUMC06.
  DATA  L_BEGIN TYPE I.   "Sztring kezdő pozíció

  DATA  L_FILESIZE TYPE I.
  DATA  L_ADOAZON_SAVE TYPE /ZAK/ADOAZON.

  DATA: BEGIN OF LI_FILENAME OCCURS 0,
        LINE(100),
        END OF LI_FILENAME.
  DATA  L_TABIX LIKE SY-TABIX.


* Save table
  LI_BEVALLO[] =  T_/ZAK/BEVALLALV[].

* Read the first row (due to parameters).
  READ TABLE LI_BEVALLO INTO LW_BEVALLO INDEX 1.

* Load settings
  SELECT * INTO TABLE LI_KFILE
                FROM  /ZAK/KFILE
               WHERE  BTYPE EQ LW_BEVALLO-BTYPE.
  IF SY-SUBRC NE 0.
    MESSAGE E097(/ZAK/ZAK) WITH LW_BEVALLO-BTYPE
            RAISING ERROR_CUST_FILE_DATA.
*   File structure cannot be determined for declaration type &!
  ENDIF.

* Sort data
  SORT LI_BEVALLO BY  ADOAZON ABEVAZ.

* Select T001Z to determine the payer tax ID
  SELECT SINGLE PAVAL INTO L_PAVAL
                      FROM T001Z
                     WHERE BUKRS EQ LW_BEVALLO-BUKRS
                       AND PARTY EQ C_PARTY.
  IF SY-SUBRC NE 0.
    MESSAGE E098(/ZAK/ZAK) WITH LW_BEVALLO-BUKRS RAISING ERROR_T001Z.
*   Error determining payer identifier for company &! (table T001Z)
  ENDIF.

* Convert parameter
  TRANSLATE L_PAVAL USING '- '.
  CONDENSE  L_PAVAL NO-GAPS .

* If a tax ID exists
  LOOP AT LI_BEVALLO INTO LW_BEVALLO WHERE
                      NOT ADOAZON IS INITIAL.
    CHECK L_ADOAZON_SAVE NE LW_BEVALLO-ADOAZON.
* Determine file header positions 1-17
* 1 - 5  alphanumeric record marker, fixed value 05K33, mandatory
* 6 - 6  single alpha character, blank (space)
* 7 - 17  payer tax ID, eleven alphanumeric characters, mandatory,
*                   left aligned, padded with blanks on the right
    CLEAR LW_FILE.
    PERFORM GET_HEAD USING LW_BEVALLO-BTYPE
                           L_PAVAL
                           L_BEGIN
                           LW_FILE-LINE
                           L_SORSZ.
*     Iterate through the field structure
    LOOP AT LI_KFILE INTO LW_KFILE.
      CLEAR LW_BEVALLO_TMP.
*       Read records with tax ID
      READ TABLE LI_BEVALLO INTO LW_BEVALLO_TMP
                            WITH KEY BUKRS   = LW_BEVALLO-BUKRS
                                     BTYPE   = LW_BEVALLO-BTYPE
                                     GJAHR   = LW_BEVALLO-GJAHR
                                     MONAT   = LW_BEVALLO-MONAT
                                     ZINDEX  = LW_BEVALLO-ZINDEX
                                     ABEVAZ  = LW_KFILE-ABEVAZ
                                     ADOAZON = LW_BEVALLO-ADOAZON.
*       If nothing is found, search without the tax number
      IF SY-SUBRC NE 0.
        READ TABLE LI_BEVALLO INTO LW_BEVALLO_TMP
                              WITH KEY BUKRS   = LW_BEVALLO-BUKRS
                                       BTYPE   = LW_BEVALLO-BTYPE
                                       GJAHR   = LW_BEVALLO-GJAHR
                                       MONAT   = LW_BEVALLO-MONAT
                                       ZINDEX  = LW_BEVALLO-ZINDEX
                                       ABEVAZ  = LW_KFILE-ABEVAZ
                                       ADOAZON = ''.

      ENDIF.
*       If a value exists, populate it
      IF NOT LW_BEVALLO_TMP IS INITIAL.
        PERFORM GET_LINE USING  LW_BEVALLO_TMP-BTYPE
                                LW_BEVALLO_TMP-ABEVAZ
                                LW_BEVALLO_TMP-FIELD_C
                                LW_BEVALLO_TMP-FIELD_NRK
                                LW_BEVALLO_TMP-WAERS
                                L_BEGIN
                                LW_KFILE-LNGTH
                                LW_FILE-LINE.
*       No value found, set starting position
      ELSE.
        ADD LW_KFILE-LNGTH TO L_BEGIN.
      ENDIF.
    ENDLOOP.
*++2010.08.17 Unicode correction Balazs Gabor (Ness)
*   Code page 852
*    TRANSLATE LW_FILE TO CODE PAGE '1403'.
    perform translate_codepage using '1404'
                                     '1403'
                                     LW_FILE.
*--2010.08.17 Unicode correction Balazs Gabor (Ness)
    APPEND LW_FILE TO LI_FILE.
    MOVE LW_BEVALLO-ADOAZON TO L_ADOAZON_SAVE.
  ENDLOOP.

* Modify file name
  SPLIT I_FILE AT '\' INTO TABLE LI_FILENAME.
  DESCRIBE TABLE LI_FILENAME LINES L_TABIX.
  READ TABLE LI_FILENAME INDEX L_TABIX.
  CLEAR LI_FILENAME-LINE.
* First 8 characters of the file name
  LI_FILENAME-LINE(8)   = L_PAVAL(8).
* '.'
  LI_FILENAME-LINE+8(1) = '.'.
* 05K33
  LI_FILENAME-LINE+9(5) = LW_BEVALLO-BTYPE+2(5).
* _0
  LI_FILENAME-LINE+14(2) = '_0'.
  MODIFY LI_FILENAME INDEX L_TABIX.
  CLEAR I_FILE.
  LOOP AT LI_FILENAME.
    IF SY-TABIX EQ 1.
      CONCATENATE I_FILE LI_FILENAME-LINE INTO I_FILE.
    ELSE.
      CONCATENATE I_FILE LI_FILENAME-LINE INTO I_FILE
                                      SEPARATED BY '\'
                                       .
    ENDIF.
  ENDLOOP.

  CONDENSE I_FILE.


* FILE DOWNLOAD
*++0001 2007.01.03 BG (FMC)
* 0001 ++ CST 2006.05.27
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
*    BIN_FILESIZE            = L_FILESIZE
     FILENAME                = I_FILE
*    FILETYPE                = 'BIN'
*    APPEND                  = SPACE
*    WRITE_FIELD_SEPARATOR   = SPACE
*    HEADER                  = '00'
*    TRUNC_TRAILING_BLANKS   = SPACE
*    WRITE_LF                = 'X'
*    COL_SELECT              = SPACE
*    COL_SELECT_MASK         = SPACE
*  IMPORTING
*    FILELENGTH              =
    CHANGING
      DATA_TAB                = LI_FILE[]
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      OTHERS                  = 22.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    RAISE ERROR_FILE_DOWNLOAD.
  ENDIF.

*l_filename = i_file.
*
*CALL FUNCTION 'WS_DOWNLOAD'
* EXPORTING
**   BIN_FILESIZE                  = ' '
**   CODEPAGE                      = ' '
*    FILENAME                      = l_filename
**   FILETYPE                      = 'ASC'
**   MODE                          = ' '
**   WK1_N_FORMAT                  = ' '
**   WK1_N_SIZE                    = ' '
**   WK1_T_FORMAT                  = ' '
**   WK1_T_SIZE                    = ' '
**   COL_SELECT                    = ' '
**   COL_SELECTMASK                = ' '
**   NO_AUTH_CHECK                 = ' '
** IMPORTING
**   FILELENGTH                    =
*  TABLES
*    DATA_TAB                      = li_file[]
**   FIELDNAMES                    =
* EXCEPTIONS
*   FILE_OPEN_ERROR               = 1
*   FILE_WRITE_ERROR              = 2
*   INVALID_FILESIZE              = 3
*   INVALID_TYPE                  = 4
*   NO_BATCH                      = 5
*   UNKNOWN_ERROR                 = 6
*   INVALID_TABLE_WIDTH           = 7
*   GUI_REFUSE_FILETRANSFER       = 8
*   CUSTOMER_ERROR                = 9
*   OTHERS                        = 10.
*
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    RAISE ERROR_FILE_DOWNLOAD.
*  ENDIF.
* 0001 -- CST 2006.05.27
*--0001 2007.01.03 BG (FMC)

ENDFUNCTION.
