CLASS lhc_ZI_TRAVEL_77_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_77_m RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_77_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_77_m RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_77_m.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_77_m\_Booking.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_77_m~acceptTravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_77_m~copytravel.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_77_m~recalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_77_m~rejectTravel RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_77_m~calculateTotalPrice.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_77_m~validateCustomer.

ENDCLASS.

CLASS lhc_ZI_TRAVEL_77_M IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
      ENTITY zi_travel_77_m
      FIELDS ( TravelId OverallStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).


    result = VALUE #(
      FOR ls_travel IN lt_travel
      (
        %tky = ls_travel-%tky

        %features-%action-acceptTravel =
          COND #(
            WHEN ls_travel-OverallStatus = 'A'
              THEN if_abap_behv=>fc-o-disabled
            ELSE
              if_abap_behv=>fc-o-enabled
          )

        %features-%action-rejectTravel =
          COND #(
            WHEN ls_travel-OverallStatus = 'X'
              THEN if_abap_behv=>fc-o-disabled
            ELSE
              if_abap_behv=>fc-o-enabled
          )

        %features-%assoc-_booking =
          COND #(
            WHEN ls_travel-OverallStatus = 'X'
              THEN if_abap_behv=>fc-o-disabled
            ELSE
              if_abap_behv=>fc-o-enabled
          )
      )
    ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(it_entities) = entities.

    DELETE it_entities WHERE TravelId IS NOT INITIAL.


    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*       ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( it_entities ) )
          IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(iv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges.
    ENDTRY.

    ASSERT lv_qty = lines( it_entities ).

    DATA: it_travel_m TYPE TABLE FOR MAPPED EARLY zi_travel_77_m,
          ls_travel_m LIKE LINE OF it_travel_m.

    DATA(lv_curr_num) = lv_latest_num - lv_qty.

    LOOP AT entities INTO DATA(ls_entities).

      ls_travel_m = VALUE #( %cid = ls_entities-%cid ).
      IF ls_entities-TravelId IS INITIAL.
        lv_curr_num = lv_curr_num + 1.
        ls_travel_m-TravelId = lv_curr_num.

      ENDIF.

      APPEND ls_travel_m TO mapped-zi_travel_77_m.

    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
      ENTITY zi_travel_77_m
      BY \_booking
      FROM CORRESPONDING #( entities )
      LINK DATA(lt_booking_link).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_booking>)
         GROUP BY <lfs_booking>-%tky.

      "Find highest existing BookingId
      lv_max_booking = REDUCE #(
       INIT lv_max = CONV /dmo/booking_id( '0' )
       FOR ls_booking_link IN lt_booking_link USING KEY entity
       WHERE ( source-travelid = <lfs_booking>-TravelId )
       NEXT lv_max = COND /dmo/booking_id(
                       WHEN lv_max < ls_booking_link-target-bookingid
                       THEN ls_booking_link-target-bookingid
                       ELSE lv_max ) ).

      LOOP AT <lfs_booking>-%target ASSIGNING FIELD-SYMBOL(<lfs_book_update>).
        APPEND CORRESPONDING #( <lfs_book_update> ) TO mapped-zi_booking_77_m
        ASSIGNING FIELD-SYMBOL(<lfs_book_update_map>).
        IF <lfs_book_update>-BookingId IS INITIAL.
          lv_max_booking += 10.
          <lfs_book_update_map>-BookingId = lv_max_booking      .
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.
    READ ENTITY  IN LOCAL MODE zi_travel_77_m
       ALL FIELDS WITH
       CORRESPONDING #( keys ) RESULT DATA(lt_result).
    ASSERT lt_result IS NOT INITIAL.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).

*      IF <lfs_result>-OverallStatus =  'O'.

      MODIFY ENTITY IN LOCAL MODE zi_travel_77_m
       UPDATE FIELDS (  OverallStatus )
       WITH VALUE #( ( OverallStatus = 'A'
                       %tky-TravelId = <lfs_result>-TravelId ) )
       MAPPED DATA(lt_mapped)
       REPORTED DATA(lt_reported)
       FAILED DATA(lt_failed).

      IF lt_failed IS INITIAL.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %param = VALUE #( travelid = <lfs_result>-TravelId ) ) TO result.
      ENDIF.

*      ELSE.

*        APPEND VALUE #(
*          %key = <lfs_result>-%key
*        ) TO failed-zi_travel_77_m.
*
*        APPEND VALUE #( %key = <lfs_result>-%key
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text = COND #( WHEN <lfs_result>-OverallStatus =  'A' THEN 'Travel is already Accepted'
*                                       WHEN <lfs_result>-OverallStatus =  'X' THEN 'Travel is Rejected' )
*           )
*  ) TO reported-zi_travel_77_m.

*    ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD copytravel.
    DATA : et_travel        TYPE TABLE FOR CREATE zi_travel_77_m,
           et_booking       TYPE TABLE FOR CREATE zi_travel_77_m\_booking,
           et_booking_suppl TYPE TABLE FOR CREATE zi_booking_77_m\_booking_supp.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<lfs_keys>) WITH KEY %cid = space.
    ASSERT <lfs_keys> IS NOT ASSIGNED.

*    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
*      ENTITY zi_travel_77_m
*       ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_travel)
*      ENTITY zi_travel_77_m
*       BY \_booking
*      ALL FIELDS WITH CORRESPONDING #( lt_travel ) RESULT DATA(lt_booking)
*      ENTITY zi_booking_77_m
*       BY \_booking_supp
*      ALL FIELDS WITH CORRESPONDING #( lt_booking ) RESULT DATA(lt_booking_suppl).

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
    ENTITY zi_travel_77_m
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_travel).

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
    ENTITY zi_travel_77_m
    BY \_booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel ) RESULT DATA(lt_booking).

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
    ENTITY zi_booking_77_m
    BY \_booking_supp
    ALL FIELDS WITH CORRESPONDING #( lt_booking ) RESULT DATA(lt_booking_suppl).

    LOOP AT lt_travel INTO DATA(ls_travel).

      APPEND CORRESPONDING #(  ls_travel-%data EXCEPT travelid ) TO et_travel
      ASSIGNING FIELD-SYMBOL(<lfs_travel>).
      <lfs_travel>-%cid = VALUE #( keys[ KEY entity TravelId = ls_travel-TravelId ]-%cid OPTIONAL ).

      APPEND VALUE #( %cid_ref = <lfs_travel>-%cid ) TO et_booking
      ASSIGNING FIELD-SYMBOL(<lfs_booking>).

      LOOP AT lt_booking INTO DATA(ls_booking) USING KEY entity
                                               WHERE TravelId = ls_travel-TravelId.

*        APPEND CORRESPONDING #( ls_booking-%data EXCEPT travelid bookingid ) TO <lfs_booking>-%target
        APPEND CORRESPONDING #( ls_booking-%data EXCEPT travelid ) TO <lfs_booking>-%target
        ASSIGNING FIELD-SYMBOL(<lfs_booking_target>).
        <lfs_booking_target>-%cid = <lfs_travel>-%cid && ls_booking-BookingId.

        APPEND VALUE #( %cid_ref = <lfs_booking_target>-%cid ) TO et_booking_suppl
        ASSIGNING FIELD-SYMBOL(<lfs_booking_suppl>).

        LOOP AT lt_booking_suppl INTO DATA(ls_booking_suppl) USING KEY entity
                                                             WHERE travelid = ls_travel-TravelId AND
                                                                   bookingid = ls_booking-BookingId.

*          APPEND CORRESPONDING #( ls_booking_suppl-%data EXCEPT travelid bookingid BookingSupplementId ) TO <lfs_booking_suppl>-%target
          APPEND CORRESPONDING #( ls_booking_suppl-%data EXCEPT travelid bookingid ) TO <lfs_booking_suppl>-%target
         ASSIGNING FIELD-SYMBOL(<lfs_booking_suppl_target>).
          <lfs_booking_suppl_target>-%cid = <lfs_travel>-%cid && ls_booking-BookingId && ls_booking_suppl-BookingSupplementId.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_77_m IN LOCAL MODE
     ENTITY zi_travel_77_m
     CREATE FIELDS ( AgencyId BeginDate BookingFee CreatedAt CreatedBy CurrencyCode CustomerId Description EndDate LastChangedAt LastChangedBy OverallStatus TotalPrice )
     WITH et_travel
     ENTITY zi_travel_77_m
     CREATE BY \_booking FIELDS ( BookingId BookingDate BookingStatus CarrierId ConnectionId CurrencyCode CustomerId FlightDate FlightPrice LastChangedAt )
     WITH et_booking
     ENTITY zi_booking_77_m
     CREATE BY \_booking_supp FIELDS ( BookingSupplementId CurrencyCode LastChangedAt Price SupplementId )
     WITH et_booking_suppl
    MAPPED DATA(lt_mapped).

    mapped-zi_travel_77_m = lt_mapped-zi_travel_77_m.

  ENDMETHOD.

  METHOD recalcTotalPrice.
    TYPES: BEGIN OF ty_total,
             price TYPE /dmo/total_price,
             curr  TYPE /dmo/currency_code,
           END OF ty_total.

    DATA: lt_total TYPE STANDARD TABLE OF ty_total.

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
    ENTITY zi_travel_77_m
     FIELDS ( BookingFee CurrencyCode )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel)
    ENTITY zi_travel_77_m BY \_booking
     FIELDS ( FlightPrice CurrencyCode )
     WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking).

    READ ENTITIES OF zi_travel_77_m IN LOCAL MODE
    ENTITY zi_booking_77_m BY \_booking_supp
     FIELDS ( price CurrencyCode )
      WITH CORRESPONDING #( lt_booking )
    RESULT DATA(lt_booking_suppl).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      CLEAR lt_total.

      "Add Booking Fee
      lt_total = VALUE #(
        ( price = <lfs_travel>-BookingFee
          curr  = <lfs_travel>-CurrencyCode )
      ).

      "Add all Booking Prices
      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<lfs_booking>)
           USING KEY entity
           WHERE TravelId = <lfs_travel>-TravelId.

        APPEND VALUE #(
          price = <lfs_booking>-FlightPrice
          curr  = <lfs_booking>-CurrencyCode
        ) TO lt_total.

        "Add all Supplement Prices
        LOOP AT lt_booking_suppl ASSIGNING FIELD-SYMBOL(<lfs_booksuppl>)
             USING KEY entity
             WHERE TravelId = <lfs_booking>-TravelId
               AND BookingId = <lfs_booking>-BookingId.

          APPEND VALUE #(
            price = <lfs_booksuppl>-Price
            curr  = <lfs_booksuppl>-CurrencyCode
          ) TO lt_total.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<lfs_total>).

      IF <lfs_total>-curr <> <lfs_travel>-CurrencyCode.
        /dmo/cl_flight_amdp=>convert_currency(
          EXPORTING
            iv_amount               = <lfs_total>-price
            iv_currency_code_source = <lfs_total>-curr
            iv_currency_code_target = <lfs_travel>-CurrencyCode
            iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
          IMPORTING
            ev_amount               = DATA(lv_converted_price)
        ).
      ELSE.
        lv_converted_price = <lfs_total>-price.
      ENDIF.

      <lfs_travel>-TotalPrice = <lfs_travel>-TotalPrice + lv_converted_price.

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_77_m IN LOCAL MODE
     ENTITY zi_travel_77_m
    UPDATE FIELDS ( TotalPrice ) WITH CORRESPONDING #(  lt_travel  ).

  ENDMETHOD.

  METHOD rejectTravel.
    READ ENTITY  IN LOCAL MODE zi_travel_77_m
       ALL FIELDS WITH
       CORRESPONDING #( keys ) RESULT DATA(lt_result).
    ASSERT lt_result IS NOT INITIAL.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).

*      IF <lfs_result>-OverallStatus =  'O'.

      MODIFY ENTITY IN LOCAL MODE zi_travel_77_m
       UPDATE FIELDS (  OverallStatus )
       WITH VALUE #( ( OverallStatus = 'X'
                       %tky-TravelId = <lfs_result>-TravelId ) )
       MAPPED DATA(lt_mapped)
       REPORTED DATA(lt_reported)
       FAILED DATA(lt_failed).

      IF lt_failed IS INITIAL.
        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %param = VALUE #( travelid = <lfs_result>-TravelId ) ) TO result.
      ENDIF.

*      ELSE.

*        APPEND VALUE #(
*          %key = <lfs_result>-%key
*        ) TO failed-zi_travel_77_m.
*
*        APPEND VALUE #( %key = <lfs_result>-%key
*                        %msg = new_message_with_text(
*                        severity = if_abap_behv_message=>severity-error
*                        text = COND #( WHEN <lfs_result>-OverallStatus =  'A' THEN 'Travel is Accepted'
*                                       WHEN <lfs_result>-OverallStatus =  'X' THEN 'Travel is already Rejected' )
*           )
*  ) TO reported-zi_travel_77_m.

*    ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.
    MODIFY ENTITIES OF zi_travel_77_m IN LOCAL MODE
        ENTITY zi_travel_77_m
       EXECUTE recalcTotalPrice
       FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITY IN LOCAL MODE zi_travel_77_m
       FIELDS ( CustomerId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    SELECT FROM /dmo/customer AS a
     INNER JOIN @lt_travel AS b ON a~customer_id = b~customerid
      FIELDS customer_id
     INTO TABLE @DATA(lt_customer_id).


    LOOP AT lt_travel INTO DATA(ls_travel).
      IF NOT line_exists(  lt_customer_id[ customer_id = ls_travel-CustomerId ] ).
        APPEND VALUE #(
                 %key = ls_travel-%key
               ) TO failed-zi_travel_77_m.
        APPEND VALUE #( %key = ls_travel-%key
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Invalid Customer ID' ) ) TO reported-zi_travel_77_m.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
