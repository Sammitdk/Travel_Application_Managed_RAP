CLASS lhc_ZI_BOOKING_77_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_booking_77_m RESULT result.

    METHODS earlynumbering_cba_Booking_sup FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_77_m\_Booking_supp.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_77_m~calculateTotalPrice.

ENDCLASS.

CLASS lhc_ZI_BOOKING_77_M IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
        ENTITY zi_travel_77_m
         BY \_booking
        FIELDS ( TravelId bookingstatus )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_booking).

    result = VALUE #(
    FOR ls_booking IN lt_booking
    (
      %tky = ls_booking-%tky

      %features-%assoc-_booking_supp =
        COND #(
          WHEN ls_booking-BookingStatus = 'X'
            THEN if_abap_behv=>fc-o-disabled
          ELSE
            if_abap_behv=>fc-o-enabled
        )
    )
  ).
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking_sup.
    DATA lv_max_booking TYPE /dmo/booking_supplement_id.

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
      ENTITY zi_booking_77_m
      BY \_booking_supp
      FROM CORRESPONDING #( entities )
      LINK DATA(lt_booking_link).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_booking>)
         GROUP BY <lfs_booking>-%tky.

      "Find highest existing BookingId
      lv_max_booking = REDUCE #(
       INIT lv_max = CONV /dmo/booking_supplement_id( '0' )
       FOR ls_booking_link IN lt_booking_link USING KEY entity
       WHERE ( source-travelid = <lfs_booking>-TravelId AND source-BookingId = <lfs_booking>-BookingId )
       NEXT lv_max = COND /dmo/booking_supplement_id(
                       WHEN lv_max < ls_booking_link-target-BookingSupplementId
                       THEN ls_booking_link-target-BookingSupplementId
                       ELSE lv_max ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_book_update>)
                                               USING KEY entity
                                               WHERE TravelId = <lfs_booking>-TravelId
                                               AND BookingId = <lfs_booking>-BookingId.

        LOOP AT <lfs_book_update>-%target ASSIGNING FIELD-SYMBOL(<lfs_book_update_t>).
          APPEND CORRESPONDING #( <lfs_book_update_t> ) TO mapped-zi_booking_supp_77_m
             ASSIGNING FIELD-SYMBOL(<lfs_book_update_map>).

          IF <lfs_book_update_t>-bookingsupplementid IS INITIAL.
            lv_max_booking += 1.
            <lfs_book_update_map>-BookingSupplementId = lv_max_booking.
          ENDIF.

        ENDLOOP.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD calculateTotalPrice.
    DATA: lt_travel TYPE STANDARD TABLE OF zi_travel_77_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.
    lt_travel =  CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ) .

    MODIFY ENTITIES OF zi_travel_77_m IN LOCAL MODE
      ENTITY zi_travel_77_m
     EXECUTE recalcTotalPrice
     FROM CORRESPONDING #( lt_travel ).
  ENDMETHOD.

ENDCLASS.
