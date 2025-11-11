*----------------------------------------------------------------------*
***INCLUDE /ZAK/LAFA_ATV_MVF01 .
*----------------------------------------------------------------------*

FORM get_change_data.

  GET TIME.
  MOVE sy-datum TO /zak/afa_atv_v-datum.
  MOVE sy-uzeit TO /zak/afa_atv_v-uzeit.
  MOVE sy-uname TO /zak/afa_atv_v-uname.

* ABEV TEXT mezők töltése
  PERFORM get_abev_text USING /zak/afa_atv_v-btype
                              /zak/afa_atv_v-abev_to
                     CHANGING /zak/afa_atv_v-text_abev_to.
  PERFORM get_abev_text USING /zak/afa_atv_v-btype
                              /zak/afa_atv_v-abev_from
                     CHANGING /zak/afa_atv_v-text_abev_from.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_abev_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/ZAK/AFA_ATV_V_ABEV_TO  text
*      <--P_/ZAK/AFA_ATV_V_TEXT_ABEV_TO  text
*----------------------------------------------------------------------*
FORM get_abev_text USING    $btype
                            $abev
                   CHANGING $abev_text.

  CLEAR $abev_text.
  SELECT SINGLE abevtext INTO $abev_text
                         FROM /zak/bevallbt
                        WHERE langu  EQ sy-langu
                          AND btype  EQ $btype
                          AND abevaz EQ $abev.

ENDFORM.                    " get_abev_text
