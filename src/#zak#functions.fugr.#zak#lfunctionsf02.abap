*----------------------------------------------------------------------*
***INCLUDE /ZAK/LFUNCTIONSF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_head
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_BEVALLO_BTYPE  text
*      -->P_L_PAVAL  text
*      <--P_LW_FILE_LINE  text
*----------------------------------------------------------------------*
FORM get_head USING    $btype
                       $paval
                       $begin
                       $line
                       $sorsz.

  ADD 1 TO $sorsz.
  $line(5)    = $btype+2(5).
  $line+5(1)  = space.
  $line+6(11) = $paval(11).
  $line+17(6) = $sorsz.
  $begin      = 24.


ENDFORM.                    " get_head
*&---------------------------------------------------------------------*
*&      Form  get_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LW_BEVALLO_TMP_ABEVAZ  text
*      -->P_LW_BEVALLO_TMP_FIELD_C  text
*      -->P_LW_BEVALLO_TMP_FIELD_N  text
*      -->P_L_BEGIN  text
*      <--P_LW_FILE_LINE  text
*----------------------------------------------------------------------*
FORM get_line USING    $btype
                       $abevaz
                       $field_c
                       $field_nrk
                       $waers
                       $begin
                       $lngth
                       $line.


  DATA l_fieldtype LIKE /zak/bevallb-fieldtype.
  DATA l_i TYPE i.
  DATA l_begin TYPE i.
  DATA l_text(60).


* Meghatározzuk az ABEV mező típusát
  SELECT SINGLE fieldtype INTO l_fieldtype
                          FROM /zak/bevallb
                         WHERE btype  EQ $btype
                           AND abevaz EQ $abevaz.
  IF sy-subrc EQ 0.
    l_begin = $begin - 1.
    CASE l_fieldtype.
*     Karakteres
      WHEN 'C'.
        CONDENSE $field_c.
        l_i = strlen( $field_c ).
        IF l_i > $lngth.
          $line+l_begin($lngth) = $field_c($lngth).
        ELSE.
          $line+l_begin($lngth) = $field_c.
        ENDIF.
*     Numerikus
      WHEN 'N'.
        WRITE $field_nrk CURRENCY $waers TO l_text NO-GROUPING.
        IF l_text IS INITIAL.
          l_text = '0'.
        ENDIF.
*       Vezető 0-ák feltöltése
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
             EXPORTING
                  input  = l_text
             IMPORTING
                  output = l_text.
*       Hossz beállítása
        l_i = strlen( l_text ).
        IF l_i > $lngth.
          DO.
            SHIFT l_text.
            l_i = strlen( l_text ).
            IF l_i = $lngth.
              EXIT.
            ENDIF.
          ENDDO.
          $line+l_begin($lngth) = l_text.
        ENDIF.
    ENDCASE.
  ENDIF.
  ADD $lngth TO $begin.

ENDFORM.                    " get_line
