CLASS lhc_ZI_BOOKING_SUPP_77_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_supp_77_m~calculateTotalPrice.

ENDCLASS.

CLASS lhc_ZI_BOOKING_SUPP_77_M IMPLEMENTATION.

  METHOD calculateTotalPrice.
  DATA: lt_travel TYPE STANDARD TABLE OF zi_travel_77_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.
    lt_travel =  CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ) .

    MODIFY ENTITIES OF zi_travel_77_m IN LOCAL MODE
      ENTITY zi_travel_77_m
     EXECUTE recalcTotalPrice
     FROM CORRESPONDING #( lt_travel ).
  ENDMETHOD.

ENDCLASS.
