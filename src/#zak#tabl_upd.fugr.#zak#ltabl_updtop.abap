FUNCTION-POOL /ZAK/TABL_UPD.                "MESSAGE-ID ..

INCLUDE /ZAK/COMMON_STRUCT.

DATA: V_/ZAK/PACK TYPE /ZAK/PACK.

DATA: I_BEVI   TYPE STANDARD TABLE OF /ZAK/BEVALLI INITIAL SIZE 0.

* adatbázis tábla update
DATA: W_UPD_BEVALLI   TYPE /ZAK/BEVALLI,
      W_UPD_BEVALLSZ  TYPE /ZAK/BEVALLSZ,
      W_RETURN        TYPE BAPIRET2.

DATA: I_UPD_BEVALLI  TYPE STANDARD TABLE OF /ZAK/BEVALLI  INITIAL SIZE 0,
      I_UPD_BEVALLSZ TYPE STANDARD TABLE OF /ZAK/BEVALLSZ INITIAL SIZE 0,
      IG_RETURN       TYPE STANDARD TABLE OF BAPIRET2    INITIAL SIZE 0.

* Szja bevall. Önrev.-ra feltöltésnél előző indexű, azonos
* adaszolgáltatás és adószámhoz tartozó tételeket statisztikai tételként
* kell megjelölni.
DATA: W_STAT_ANALITIKA TYPE /ZAK/ANALITIKA.

DATA: I_STAT_ANALITIKA TYPE STANDARD TABLE OF /ZAK/ANALITIKA
                                                         INITIAL SIZE 0.

RANGES: R_MONAT FOR /ZAK/ANALITIKA-MONAT.

*++1365 #14.
*Konverzió
DEFINE m_run_conv.
  call method cl_reca_ddic_services=>do_struct_conv_exit
*      EXPORTING
*        id_convexit        =
*        if_only_if_defined = ABAP_TRUE
*        if_output          = ABAP_FALSE
    changing
      cs_struct          = &1
    exceptions
      error              = 1
      others             = 2
          .
END-OF-DEFINITION.
*--1365 #14.
*++PTGSZLAA #02. 2014.03.05
CONSTANTS: C_PTGSZLAA  TYPE /ZAK/BTYPE VALUE 'PTGSZLAA'.
*--PTGSZLAA #02. 2014.03.05
