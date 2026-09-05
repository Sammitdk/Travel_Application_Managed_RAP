CLASS zcl_testing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_testing IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA:
      lt_travel  TYPE TABLE OF zdt_travel_77_m,
      lt_booking TYPE TABLE OF zdt_booking_77_m,
      lt_suppl   TYPE TABLE OF zdt_booksup_77_m.

    "------------------------------------------------------------
    " 1. Copy Travel data
    "------------------------------------------------------------
    SELECT *
      FROM /dmo/travel_m
      INTO CORRESPONDING FIELDS OF TABLE @lt_travel.

    IF lt_travel IS NOT INITIAL.

      DELETE FROM zdt_travel_77_m.

      INSERT zdt_travel_77_m FROM TABLE @lt_travel.

      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.


    "------------------------------------------------------------
    " 2. Copy Booking data
    "------------------------------------------------------------
    SELECT *
      FROM /dmo/booking_m
      INTO CORRESPONDING FIELDS OF TABLE @lt_booking.

    IF lt_booking IS NOT INITIAL.

      DELETE FROM zdt_booking_77_m.

      INSERT zdt_booking_77_m FROM TABLE @lt_booking.

      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.


    "------------------------------------------------------------
    " 3. Copy Booking Supplement data
    "------------------------------------------------------------
    SELECT *
      FROM /dmo/booksuppl_m
      INTO CORRESPONDING FIELDS OF TABLE @lt_suppl.

    IF lt_suppl IS NOT INITIAL.

      DELETE FROM zdt_booksup_77_m.

      INSERT zdt_booksup_77_m FROM TABLE @lt_suppl.

      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.



  ENDMETHOD.


ENDCLASS.
