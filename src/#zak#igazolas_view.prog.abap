*&---------------------------------------------------------------------*
*& Program: Displaying certificates for private individuals
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /ZAK/IGAZOLAS_VIEW  MESSAGE-ID /ZAK/ZAK
                             LINE-SIZE  255
                             LINE-COUNT 65.

*&---------------------------------------------------------------------*
*& Function description: The program can handle already issued certificates
*& by displaying and printing them
*&---------------------------------------------------------------------*
*& Author            : Balázs Gábor - FMC
*& Creation date     : 2008.03.12
*& Functional spec   : Róth Nándor
*& SAP module name   : ADO
*& Program type      : Report
*& SAP version       : 46C
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODIFICATIONS (write the OSS note number at the end of the changed lines)*
*&
*& LOG#     DATE        MODIFIER                 DESCRIPTION
*& ----   ----------   ----------    ----------------------- -----------
*&
*&---------------------------------------------------------------------*
INCLUDE /ZAK/COMMON_STRUCT.

*Data declaration
INCLUDE /ZAK/IGTOP.
*Common routines
INCLUDE /ZAK/IGF01.

*&---------------------------------------------------------------------*
*& TABLES                                                              *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& PROGRAM VARIABLES                                                   *
*      Internal table       -   (I_xxx...)                              *
*      FORM parameter       -   ($xxxx...)                              *
*      Constant             -   (C_xxx...)                              *
*      Parameter variable   -   (P_xxx...)                              *
*      Selection option     -   (S_xxx...)                              *
*      Ranges               -   (R_xxx...)                              *
*      Global variables     -   (V_xxx...)                              *
*      Local variables      -   (L_xxx...)                              *
*      Work area            -   (W_xxx...)                              *
*      Type                 -   (T_xxx...)                              *
*      Macros               -   (M_xxx...)                              *
*      Field-symbol         -   (FS_xxx...)                             *
*      Method               -   (METH_xxx...)                           *
*      Object               -   (O_xxx...)                              *
*      Class                -   (CL_xxx...)                             *
*      Event                -   (E_xxx...)                              *
*&---------------------------------------------------------------------*
DATA V_SUBRC LIKE SY-SUBRC.


*&---------------------------------------------------------------------*
* SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK BL01 WITH FRAME TITLE TEXT-T01.
*Form name:
PARAMETERS P_FNAME LIKE SSFSCREEN-FNAME DEFAULT '/ZAK/MG_IGAZOLAS'
                                        MODIF ID DIS.
*Company
PARAMETERS P_BUKRS LIKE T001-BUKRS OBLIGATORY MEMORY ID BUK.
*Year
SELECT-OPTIONS S_GJAHR FOR /ZAK/IGDATA-GJAHR.
*Tax identifier:
SELECT-OPTIONS S_ADOAZ FOR /ZAK/IGDATA-ADOAZON.

SELECTION-SCREEN: END OF BLOCK BL01.


*&---------------------------------------------------------------------*
* INITALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  G_REPID = SY-REPID.
*++1765 #19.
* Authorization check
  AUTHORITY-CHECK OBJECT 'S_TCODE'
*++2165 #03.
*                  ID 'TCD'  FIELD SY-TCODE.
                  ID 'TCD'  FIELD '/ZAK/IGAZOLAS_VIEW'.
*--2165 #03.
*++1865 #03.
*  IF SY-SUBRC NE 0.
  IF SY-SUBRC NE 0 AND SY-BATCH IS INITIAL.
*--1865 #03.
    MESSAGE E152(/ZAK/ZAK).
*   You do not have authorization to run the program!
  ENDIF.
*--1765 #19.
*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIF_SCREEN.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

* Authorization check
  PERFORM AUTHORITY_CHECK USING
                                P_BUKRS
                                C_BTYPART_SZJA
                                C_ACTVT_01.


* Background run check:
  IF NOT SY-BATCH IS INITIAL.
    MESSAGE A259.
*   The program cannot be executed in the background!
  ENDIF.

* Data selection
  PERFORM SEL_DATA_FORM_IGDATA TABLES I_/ZAK/IGDATA
                                      I_/ZAK/IGDATA_ALV
                                      I_/ZAK/IGSORT
                                      I_/ZAK/MGCIM
                                      I_/ZAK/IGABEV
                                      I_BSZNUMT
                                      I_WAERST
                                      S_GJAHR
                                      S_ADOAZ
                               USING  P_BUKRS
                                      V_SUBRC.
  IF NOT V_SUBRC IS INITIAL.
    MESSAGE I031.
*   The database does not contain any records to process!
    EXIT.
  ENDIF.


*&---------------------------------------------------------------------*
* END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

* List output
  PERFORM LIST_DISPLAY.


*&---------------------------------------------------------------------*
*&      Form  SEL_DATA_FORM_IGDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_/ZAK/IGDATA  text
*      -->P_I_/ZAK/IGDATA_ALV  text
*      -->P_S_GJAHR  text
*      -->P_S_ADOAZ  text
*      -->P_P_BUKRS  text
*      -->P_V_SUBRC  text
*----------------------------------------------------------------------*
FORM SEL_DATA_FORM_IGDATA TABLES $I_/ZAK/IGDATA STRUCTURE /ZAK/IGDATA
                            $I_/ZAK/IGDATA_ALV  STRUCTURE /ZAK/IGDATA_ALV
                            $I_/ZAK/IGSORT      STRUCTURE /ZAK/IGSORT
                            $I_/ZAK/MGCIM       STRUCTURE /ZAK/MGCIM
                            $I_/ZAK/IGABEV      STRUCTURE /ZAK/IGABEV
                            $I_BSZNUMT         LIKE      I_BSZNUMT
                            $I_WAERST          LIKE I_WAERST
                            $S_GJAHR           STRUCTURE S_GJAHR
                            $S_ADOAZ           STRUCTURE S_ADOAZ
                           USING  $BUKRS
                                  $SUBRC.
  DATA L_BSZNUM TYPE /ZAK/BSZNUM.
  DATA L_SZTEXT TYPE /ZAK/SZTEXT.


  CLEAR $SUBRC.

  SELECT * INTO TABLE $I_/ZAK/IGDATA
           FROM /ZAK/IGDATA
          WHERE BUKRS EQ  $BUKRS
            AND ADOAZON IN $S_ADOAZ
            AND GJAHR   IN $S_GJAHR.
  IF SY-SUBRC NE 0.
    MOVE SY-SUBRC TO $SUBRC.
    EXIT.
  ENDIF.

  SORT $I_/ZAK/IGDATA BY ADOAZON GJAHR BSZNUM SORSZ SORREND.

* Upload to ALV with field names:
  LOOP AT $I_/ZAK/IGDATA INTO W_/ZAK/IGDATA.
    CLEAR W_/ZAK/IGDATA_ALV.
    MOVE-CORRESPONDING W_/ZAK/IGDATA TO W_/ZAK/IGDATA_ALV.
    READ TABLE $I_/ZAK/IGSORT INTO W_/ZAK/IGSORT
         WITH KEY IGAZON = W_/ZAK/IGDATA-IGAZON.
    IF SY-SUBRC EQ 0.
      MOVE W_/ZAK/IGSORT-NYTEXT TO W_/ZAK/IGDATA_ALV-NYTEXT.
    ELSE.
      SELECT  * APPENDING TABLE $I_/ZAK/IGSORT
                    FROM /ZAK/IGSORT
                   WHERE LANGU  EQ SY-LANGU
                     AND IGAZON EQ W_/ZAK/IGDATA-IGAZON.
    ENDIF.
    APPEND W_/ZAK/IGDATA_ALV TO $I_/ZAK/IGDATA_ALV.
    MOVE W_/ZAK/IGDATA-WAERS TO W_WAERST-WAERS.
    COLLECT W_WAERST INTO $I_WAERST.
  ENDLOOP.

* Determine currency texts
  LOOP AT $I_WAERST INTO W_WAERST.
    SELECT SINGLE KTEXT INTO W_WAERST-KTEXT
                        FROM TCURT
                       WHERE SPRAS EQ SY-LANGU
                         AND WAERS EQ W_WAERST-WAERS.
    IF SY-SUBRC EQ 0.
      MODIFY  $I_WAERST FROM W_WAERST TRANSPORTING KTEXT.
    ENDIF.
  ENDLOOP.

* Reading address data
  SELECT * INTO TABLE $I_/ZAK/MGCIM
           FROM /ZAK/MGCIM.                              "#EC CI_NOWHERE
*++0001 2008.11.14 BG
* In the MTP system the sorting is not correct despite
* the tax identifier being the key
  SORT $I_/ZAK/MGCIM BY ADOAZON.
*--0001 2008.11.14 BG



* Reading data reporting identifiers
  SELECT  /ZAK/BEVALLD~BSZNUM
          /ZAK/BEVALLDT~SZTEXT
          INTO (L_BSZNUM, L_SZTEXT)
                FROM /ZAK/BEVALLD INNER JOIN /ZAK/BEVALLDT
                  ON /ZAK/BEVALLDT~LANGU  = SY-LANGU
                 AND /ZAK/BEVALLDT~BUKRS  = /ZAK/BEVALLD~BUKRS
                 AND /ZAK/BEVALLDT~BTYPE  = /ZAK/BEVALLD~BTYPE
                 AND /ZAK/BEVALLDT~BSZNUM = /ZAK/BEVALLD~BSZNUM
               WHERE /ZAK/BEVALLD~BUKRS  EQ $BUKRS
                 AND /ZAK/BEVALLD~MGIF   EQ C_ON.
    CLEAR W_BSZNUMT.
    MOVE  L_BSZNUM TO W_BSZNUMT-BSZNUM.
    MOVE  L_SZTEXT TO W_BSZNUMT-SZTEXT.
    APPEND W_BSZNUMT TO $I_BSZNUMT.
  ENDSELECT.

* Reading settings
  SELECT * INTO TABLE $I_/ZAK/IGABEV
           FROM /ZAK/IGABEV
          WHERE BUKRS EQ $BUKRS.


ENDFORM.                    " SEL_DATA_FORM_IGDATA
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_DISPLAY .

  CALL SCREEN 100.

ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  DATA LI_FCODE TYPE TABLE OF SY-UCOMM.

  SET TITLEBAR 'MAIN100'.

  SET PF-STATUS 'MAIN100' EXCLUDING LI_FCODE.

  IF G_CUSTOM_CONTAINER IS INITIAL.
    CREATE OBJECT G_CUSTOM_CONTAINER
           EXPORTING CONTAINER_NAME = G_CONTAINER.
    CREATE OBJECT G_GRID1
           EXPORTING I_PARENT = G_CUSTOM_CONTAINER.

    PERFORM FIELDCAT_BUILD.

    GS_VARIANT-REPORT = G_REPID.
    IF NOT SPEC_LAYOUT IS INITIAL.
      MOVE-CORRESPONDING SPEC_LAYOUT TO GS_VARIANT.
    ELSEIF NOT DEF_LAYOUT IS INITIAL.
      MOVE-CORRESPONDING DEF_LAYOUT TO GS_VARIANT.
    ELSE.
    ENDIF.
    GS_LAYOUT-CWIDTH_OPT = 'X'.
    GS_LAYOUT-SEL_MODE   = 'A'.
*   GS_LAYOUT-EXCP_FNAME = 'LIGHT'.

    CALL METHOD G_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT           = GS_VARIANT
        I_SAVE               = 'A'
        I_DEFAULT            = 'X'
        IS_LAYOUT            = GS_LAYOUT
*       it_toolbar_excluding = lt_exclude
      CHANGING
        IT_OUTTAB            = I_/ZAK/IGDATA_ALV[]
        IT_FIELDCATALOG      = GT_FCAT[].
*
  ENDIF.



ENDMODULE.                 " PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELDCAT_BUILD .

  DATA: L_FCAT TYPE LVC_S_FCAT.


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = '/ZAK/IGDATA_ALV'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = GT_FCAT[].

  LOOP AT GT_FCAT INTO L_FCAT.
    IF L_FCAT-FIELDNAME = 'CHANGE'.
      L_FCAT-CHECKBOX = 'X'.
    ENDIF.
    MODIFY GT_FCAT FROM L_FCAT.
  ENDLOOP.


ENDFORM.                    " FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.
  CASE SAVE_OK.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.
*   Form display
    WHEN 'SHOW'.
      PERFORM PREVIEW_DATA TABLES I_/ZAK/IGDATA_ALV
                                  I_/ZAK/MGCIM
                                  I_SMART_DATA
                           USING  P_FNAME
                                  P_BUKRS
                                  ''        "Test run flag
*++2008 #12.
                                  ''.       "Annual run flag
*--2008 #12.
    WHEN OTHERS.
*     do nothing
  ENDCASE.


ENDMODULE.                 " PAI_0100  INP
