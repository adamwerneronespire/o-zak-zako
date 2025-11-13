DATA L_ADRNR TYPE ADRNR.

CLEAR: W_ADRC, V_PAVAL, V_MEGNEV, V_TEXT, V_LOGO.

SELECT SINGLE ADRNR INTO L_ADRNR
                    FROM T001
                   WHERE BUKRS EQ BUKRS.
IF SY-SUBRC EQ 0.
* Address data
  SELECT SINGLE * INTO W_ADRC
                  FROM ADRC
                 WHERE ADDRNUMBER EQ L_ADRNR.
* Tax number
*++2508 #12.
  SELECT SINGLE ADOSZAM INTO V_PAVAL
                        FROM /ZAK/IGLOG
                       WHERE BUKRS EQ BUKRS.
  IF V_PAVAL IS INITIAL.
*--2508 #12.
    SELECT SINGLE PAVAL INTO V_PAVAL
                        FROM T001Z
                       WHERE BUKRS EQ BUKRS
                         AND PARTY EQ 'YHRASZ'.
*++2508 #12.
  ENDIF.
*--2508 #12.
ENDIF.
*++ 2021.03.02 Baranyai Balázs Dynamic texts and logos
* Name text element
SELECT SINGLE  TDNAME INTO V_MEGNEV
         FROM /ZAK/IGCUST
        WHERE BTYPE EQ BTYPE
          AND BSZNUM EQ BSZNUM
          AND TEXTTYPE EQ 'MEGN'.
* Text content element
SELECT SINGLE  TDNAME INTO V_TEXT
         FROM /ZAK/IGCUST
        WHERE BTYPE EQ BTYPE
          AND BSZNUM EQ BSZNUM
          AND TEXTTYPE EQ 'SZOV'.
* LOGO
SELECT SINGLE  TDNAME INTO V_LOGO
         FROM /ZAK/IGLOG
        WHERE BUKRS EQ BUKRS.
*-- 2021.03.02 Baranyai Balázs Dynamic texts and logos








