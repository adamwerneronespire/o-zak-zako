FUNCTION /ZAK/TXT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FILENAME) LIKE  RLGRAP-FILENAME
*"     REFERENCE(I_STRNAME) TYPE  STRUKNAME
*"     REFERENCE(I_BUKRS) TYPE  T001-BUKRS
*"     REFERENCE(I_CDV) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_HEAD) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      INTERN STRUCTURE  ALSMEX_TABLINE
*"      CHECK_TAB STRUCTURE  DD03P
*"      E_HIBA STRUCTURE  /ZAK/ADAT_HIBA
*"      I_LINE STRUCTURE  /ZAK/LINE
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"      FILE_OPEN_ERROR
*"      FILE_READ_ERROR
*"      INVALID_TYPE
*"      GUI_REFUSE_FILETRANSFER
*"----------------------------------------------------------------------
*  DATA: V_FILE TYPE STRING.
*++S4HANA#01.
*  DATA: V_FILE LIKE RLGRAP-FILENAME.
  DATA: V_FILE TYPE STRING.              "$smart(M): UC
*--S4HANA#01.

  FIELD-SYMBOLS: <F1> TYPE ANY.

  V_FILE = FILENAME.
* ++ 0001 CST 2006.05.27
*  CALL FUNCTION 'GUI_UPLOAD'
*       EXPORTING
*            FILENAME                = V_FILE
*       TABLES
*            DATA_TAB                = I_SOR
*       EXCEPTIONS
*            FILE_OPEN_ERROR         = 1
*            FILE_READ_ERROR         = 2
*            NO_BATCH                = 3
*            GUI_REFUSE_FILETRANSFER = 4
*            INVALID_TYPE            = 5
*            NO_AUTHORITY            = 6
*            UNKNOWN_ERROR           = 7
*            BAD_DATA_FORMAT         = 8
*            HEADER_NOT_ALLOWED      = 9
*            SEPARATOR_NOT_ALLOWED   = 10
*            HEADER_TOO_LONG         = 11
*            UNKNOWN_DP_ERROR        = 12
*            ACCESS_DENIED           = 13
*            DP_OUT_OF_MEMORY        = 14
*            DISK_FULL               = 15
*            DP_TIMEOUT              = 16
*            OTHERS                  = 17.
*++MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27
*  CALL FUNCTION 'WS_UPLOAD'
*   EXPORTING
**   CODEPAGE                      = ' '
*      FILENAME                      = V_FILE
**   FILETYPE                      = 'ASC'
**   HEADLEN                       = ' '
**   LINE_EXIT                     = ' '
**   TRUNCLEN                      = ' '
**   USER_FORM                     = ' '
**   USER_PROG                     = ' '
**   DAT_D_FORMAT                  = ' '
** IMPORTING
**   FILELENGTH                    =
*    TABLES
*      DATA_TAB                      = I_SOR
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
*
**-- 0001 CST 2006.05.27
  DATA L_FILENAME_STRING TYPE STRING.

  MOVE V_FILE TO L_FILENAME_STRING.

*++S4HANA#01.
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
*    EXPORTING
*      FILENAME                = L_FILENAME_STRING
*      FILETYPE                = 'ASC'
*    CHANGING
*      DATA_TAB                = I_SOR
*    EXCEPTIONS
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
*      NOT_SUPPORTED_BY_GUI    = 17
*      ERROR_NO_GUI            = 18
*      OTHERS                  = 19.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME                = V_FILE
    CHANGING
      DATA_TAB                = I_SOR
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
*--S4HANA#01.

*--MOL_UPG_UCCHECK Forgó István (NESS) 2016.06.27
  IF SY-SUBRC <> 0.
*++BG 2006.04.10
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE E167(/ZAK/ZAK).
*   Error opening the file!
*--BG 2006.04.10
  ENDIF.
* Was data provided?
  IF I_SOR[] IS INITIAL.
    MESSAGE E100(/ZAK/ZAK) .
  ENDIF.
*++BG 2006/07/07
* Delete the first line of a headered data file
  IF NOT I_HEAD IS INITIAL.
    DELETE I_SOR INDEX 1.
  ENDIF.
*--BG 2006/07/07

  PERFORM SET_ITAB USING I_SOR[]
                         CHECK_TAB[]
                         INTERN[]
                         E_HIBA[]
                         I_BUKRS
                         I_CDV.
  I_LINE[] = I_SOR[].
ENDFUNCTION.
