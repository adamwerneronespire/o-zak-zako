*----------------------------------------------------------------------*
***INCLUDE /ZAK/LUREPI_MVF01 .
*----------------------------------------------------------------------*
FORM GET_CHANGE_DATA.

  GET TIME.
  MOVE SY-DATUM TO /ZAK/UREPI_MV-AS4DATE.
  MOVE SY-UZEIT TO /ZAK/UREPI_MV-AS4TIME.
  MOVE SY-UNAME TO /ZAK/UREPI_MV-AS4USER.

ENDFORM.                    "GET_CHANGE_DATA


*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.

  DATA LW_UREPI_DATA TYPE /ZAK/UREPIDATA.

* Adatok átvezetése /ZAK/UREPIDATA táblába
  LOOP AT /ZAK/UREPI_MV_TOTAL WHERE NOT ACTION IS INITIAL.

*++2010.06.03 BG
**   A törléssel nem foglalkozunk
*    CHECK /ZAK/UREPI_MV_TOTAL-ACTION NE 'D'.
*    CHECK /ZAK/UREPI_MV_TOTAL-ACTION NE 'X'.
*  Ezzel is foglalkozni kell mert egyébként nem törli az adatokat:
    IF /ZAK/UREPI_MV_TOTAL-ACTION EQ 'D' OR
       /ZAK/UREPI_MV_TOTAL-ACTION EQ 'X'.
      DELETE FROM /ZAK/UREPIDATA WHERE BUKRS = /ZAK/UREPI_MV_TOTAL-BUKRS
                                   AND GJAHR = /ZAK/UREPI_MV_TOTAL-GJAHR.
    ELSE.
*--2010.06.03 BG
*   Megpróbáljuk módosítani 'Üzleti'
      UPDATE /ZAK/UREPIDATA SET ADOMN = /ZAK/UREPI_MV_TOTAL-UZADM
                          WHERE BUKRS = /ZAK/UREPI_MV_TOTAL-BUKRS
                            AND GJAHR = /ZAK/UREPI_MV_TOTAL-GJAHR
                            AND UREPF = 'U'.
      IF SY-SUBRC NE 0.
        CLEAR LW_UREPI_DATA.
        MOVE SY-MANDT TO LW_UREPI_DATA-MANDT.
        MOVE /ZAK/UREPI_MV_TOTAL-BUKRS TO LW_UREPI_DATA-BUKRS.
        MOVE /ZAK/UREPI_MV_TOTAL-GJAHR TO LW_UREPI_DATA-GJAHR.
        MOVE 'U' TO LW_UREPI_DATA-UREPF.
        MOVE /ZAK/UREPI_MV_TOTAL-UZADM TO LW_UREPI_DATA-ADOMN.
        MOVE /ZAK/UREPI_MV_TOTAL-WAERS TO LW_UREPI_DATA-WAERS.
        INSERT /ZAK/UREPIDATA FROM LW_UREPI_DATA.
      ENDIF.

*   Megpróbáljuk módosítani 'Repi'
      UPDATE /ZAK/UREPIDATA SET ADOMN = /ZAK/UREPI_MV_TOTAL-READM
                          WHERE BUKRS = /ZAK/UREPI_MV_TOTAL-BUKRS
                            AND GJAHR = /ZAK/UREPI_MV_TOTAL-GJAHR
                            AND UREPF = 'R'.
      IF SY-SUBRC NE 0.
        CLEAR LW_UREPI_DATA.
        MOVE SY-MANDT TO LW_UREPI_DATA-MANDT.
        MOVE /ZAK/UREPI_MV_TOTAL-BUKRS TO LW_UREPI_DATA-BUKRS.
        MOVE /ZAK/UREPI_MV_TOTAL-GJAHR TO LW_UREPI_DATA-GJAHR.
        MOVE 'R' TO LW_UREPI_DATA-UREPF.
        MOVE /ZAK/UREPI_MV_TOTAL-READM TO LW_UREPI_DATA-ADOMN.
        MOVE /ZAK/UREPI_MV_TOTAL-WAERS TO LW_UREPI_DATA-WAERS.
        INSERT /ZAK/UREPIDATA FROM LW_UREPI_DATA.
      ENDIF.
*++2010.06.03 BG
    ENDIF.
*--2010.06.03 BG
  ENDLOOP.

ENDFORM.                    "get_data
