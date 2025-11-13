FUNCTION-POOL /ZAK/READ_XML.                "MESSAGE-ID ..
*&---------------------------------------------------------------------*
*& Tables                                                              *
*&---------------------------------------------------------------------*
*++S4HANA#01.
*TABLES: SKB1,
*        T001.
DATA GS_SKB1 TYPE SKB1.
TABLES: T001.
*--S4HANA#01.

TYPE-POOLS: IXML.

*&---------------------------------------------------------------------*
*& WORK AREAS                                                          *
*&---------------------------------------------------------------------*
DATA: W_XLS       TYPE ALSMEX_TABLINE,
      W_ITAB      TYPE /ZAK/SZJA_001,
      W_DD03P     TYPE DD03P,
      W_RETURN    LIKE BAPIRETURN,
      W_HIBA      TYPE /ZAK/ADAT_HIBA,
      W_LINE2     TYPE /ZAK/LINE,
      W_ANALITIKA TYPE /ZAK/ANALITIKA,
      W_BEVALLB   TYPE /ZAK/BEVALLB,
      W_BEVALLBT TYPE /ZAK/BEVALLBT.
*xml
DATA: L_DOM      TYPE REF TO IF_IXML_ELEMENT,
      M_DOCUMENT TYPE REF TO IF_IXML_DOCUMENT,
      G_IXML     TYPE REF TO IF_IXML,
      W_STRING   TYPE XSTRING,
      W_SIZE     TYPE I,
      W_RESULT   TYPE I,
      W_LINE     TYPE STRING,
      IT_XML     TYPE DCXMLLINES,
      S_XML      LIKE LINE OF IT_XML,
      W_RC       LIKE SY-SUBRC.


DATA: XML TYPE DCXMLLINES.
DATA: RC    TYPE SY-SUBRC.
*++S4HANA#01.
*      BEGIN OF XML_TAB OCCURS 0,
*        D LIKE LINE OF XML,
*      END OF XML_TAB.
TYPES:BEGIN OF TS_XML_TAB,
        D LIKE LINE OF XML,
      END OF TS_XML_TAB .
TYPES TT_XML_TAB TYPE STANDARD TABLE OF TS_XML_TAB .
DATA: GS_XML_TAB TYPE TS_XML_TAB.
DATA: GT_XML_TAB TYPE TT_XML_TAB.
*--S4HANA#01.

TYPES: BEGIN OF T_SOR,
         LINE(1000),
       END OF T_SOR.

DATA: W_SOR TYPE T_SOR.
*&---------------------------------------------------------------------*
*& INTERNAL TABLES                                                     *
*&---------------------------------------------------------------------*
DATA: I_ITAB TYPE STANDARD TABLE OF /ZAK/SZJA_001   INITIAL SIZE 0,
      I_XLS  TYPE STANDARD TABLE OF ALSMEX_TABLINE  INITIAL SIZE 0.
* Error description table
DATA: I_HIBA      TYPE STANDARD TABLE OF /ZAK/ADAT_HIBA  INITIAL SIZE 0,
      I_LINE2     TYPE STANDARD TABLE OF /ZAK/LINE      INITIAL SIZE 0,
      I_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                   INITIAL SIZE 0,
      I_SOR       TYPE STANDARD TABLE OF T_SOR INITIAL SIZE 0.

*++S4HANA#01.
DATA I_/ZAK/BEVALLB  TYPE STANDARD TABLE OF /ZAK/BEVALLB   INITIAL SIZE 0.
*DATA I_/ZAK/BEVALLB  TYPE STANDARD TABLE OF TS_I_/ZAK/BEVALLB_SEL   INITIAL SIZE 0.
*--S4HANA#01.
DATA I_/ZAK/BEVALLBT TYPE STANDARD TABLE OF /ZAK/BEVALLBT  INITIAL SIZE 0.


* For XML reading
TYPES: BEGIN OF T_DATA_LINE,
         ELEMENT(50) TYPE C,
         ATTRIB(50)  TYPE C,
         VALUE(50)   TYPE C,
       END OF T_DATA_LINE.

DATA: I_DATA_TABLE TYPE TABLE OF T_DATA_LINE,
      W_DATA_LINE  TYPE T_DATA_LINE.
*++PTGSZLAA #04. 2014.04.25
CONSTANTS: C_ABEVAZ_DUMMY TYPE /ZAK/ABEVAZ VALUE 'DUMMY'.
*--PTGSZLAA #04. 2014.04.25
*++PTGSZLAH #01. 2015.01.16
CONSTANTS: C_BTYPE_PTGSZLAA TYPE /ZAK/BTYPE VALUE 'PTGSZLAA',
           C_BTYPE_PTGSZLAH TYPE /ZAK/BTYPE VALUE 'PTGSZLAH'.
*--PTGSZLAH #01. 2015.01.16

*++1665 #04.
*Macro definition for filling range
DEFINE M_DEF.
  MOVE: &2      TO &1-SIGN,
        &3      TO &1-OPTION,
        &4      TO &1-LOW,
        &5      TO &1-HIGH.
  COLLECT &1.
END-OF-DEFINITION.
*--1665 #04.
