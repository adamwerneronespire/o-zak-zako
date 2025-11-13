FUNCTION-POOL /zak/zole.                         "MESSAGE-ID ..
TYPE-POOLS: abap.

* EXCEL sheet using OLE automation.
INCLUDE ole2incl.

DEFINE ole_error.
  if not &1 is initial.
    message e899(v1) with 'OLE Error ='(002) &1
    raising ole_error.
  endif.
END-OF-DEFINITION.

TYPES:
BEGIN OF ty_line,
line(4096) TYPE c,
END OF ty_line.

CONSTANTS:
*++2010.12.08 Upgrade Unicode bug fix Balázs Gábor (Ness)
*c_tab TYPE x VALUE 09,
c_tab(4) TYPE x VALUE '0009',
*--2010.12.08 Upgrade Unicode bug fix Balázs Gábor (Ness)
c_bgrw TYPE i VALUE 1,
c_bgcl TYPE i VALUE 1.
*For EXCEL operations through ABAP
DATA:
w_excel TYPE ole2_object, "Holds the excel application
w_wbooks TYPE ole2_object, "Holds Work Books
w_wbook TYPE ole2_object, "Holds Work Book
w_cell TYPE ole2_object, "Holds Cell
w_format TYPE ole2_object, "Object for format
w_font TYPE ole2_object,
w_sheets TYPE ole2_object, "Holds Active Sheet
w_range TYPE ole2_object, "To select a range

*For data processing
it_line TYPE STANDARD TABLE OF ty_line,
wa_line TYPE ty_line,
w_field TYPE ty_line-line,
w_tab TYPE c.

FIELD-SYMBOLS:
<fs_field> TYPE ANY,
<fs_hex> TYPE ANY.
********************TOP Include Ends************************
