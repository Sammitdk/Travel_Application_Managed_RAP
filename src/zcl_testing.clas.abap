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

*    DATA:
*      lt_travel  TYPE TABLE OF zdt_travel_77_m,
*      lt_booking TYPE TABLE OF zdt_booking_77_m,
*      lt_suppl   TYPE TABLE OF zdt_booksup_77_m.
*
*    "------------------------------------------------------------
*    " 1. Copy Travel data
*    "------------------------------------------------------------
*    SELECT *
*      FROM /dmo/travel_m
*      INTO CORRESPONDING FIELDS OF TABLE @lt_travel.
*
*    IF lt_travel IS NOT INITIAL.
*
*      DELETE FROM zdt_travel_77_m.
*
*      INSERT zdt_travel_77_m FROM TABLE @lt_travel.
*
*      IF sy-subrc = 0.
*        COMMIT WORK AND WAIT.
*      ENDIF.
*
*    ENDIF.
*
*
*    "------------------------------------------------------------
*    " 2. Copy Booking data
*    "------------------------------------------------------------
*    SELECT *
*      FROM /dmo/booking_m
*      INTO CORRESPONDING FIELDS OF TABLE @lt_booking.
*
*    IF lt_booking IS NOT INITIAL.
*
*      DELETE FROM zdt_booking_77_m.
*
*      INSERT zdt_booking_77_m FROM TABLE @lt_booking.
*
*      IF sy-subrc = 0.
*        COMMIT WORK AND WAIT.
*      ENDIF.
*
*    ENDIF.
*
*
*    "------------------------------------------------------------
*    " 3. Copy Booking Supplement data
*    "------------------------------------------------------------
*    SELECT *
*      FROM /dmo/booksuppl_m
*      INTO CORRESPONDING FIELDS OF TABLE @lt_suppl.
*
*    IF lt_suppl IS NOT INITIAL.
*
*      DELETE FROM zdt_booksup_77_m.
*
*      INSERT zdt_booksup_77_m FROM TABLE @lt_suppl.
*
*      IF sy-subrc = 0.
*        COMMIT WORK AND WAIT.
*      ENDIF.
*
*    ENDIF.

    DATA(lv_input) = |Hello|.

    TYPES : BEGIN OF ty_msg,
              role    TYPE string,
              content TYPE string,
            END OF ty_msg,
            BEGIN OF ty_req,
              model    TYPE string,
              messages TYPE STANDARD TABLE OF ty_msg WITH EMPTY KEY,
            END OF ty_req.

    TYPES: BEGIN OF ty_message,
             role    TYPE string,
             content TYPE string,
           END OF ty_message,
           BEGIN OF ty_choice,
             message TYPE ty_message,
           END OF ty_choice,
           BEGIN OF ty_resp,
             choices TYPE STANDARD TABLE OF ty_choice WITH EMPTY KEY,
           END OF ty_resp.


    DATA(ls_req) = VALUE ty_req(
      model    = 'deepseek-ai/DeepSeek-V4.1-Flash:novita'
      messages = VALUE #( ( role = 'user' content = lv_input ) ) ).

    DATA(lv_body) = /ui2/cl_json=>serialize( data = ls_req
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

*    TRY.
*        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination(
*          i_destination = cl_http_destination_provider=>create_by_cloud_destination(
*            i_name = 'HF_DEEPSEEK_R1' ) ).
*      CATCH cx_web_http_client_error cx_http_dest_provider_error INTO DATA(lx_error).
*        DATA(lv_e) = lx_error->get_longtext(  ).
*        "handle exception
*    ENDTRY.
*
*    lo_client->get_http_request( )->set_content_type( 'application/json' ).
*    lo_client->get_http_request( )->set_text( lv_body ).
*
*    TRY.
*        DATA(lv_resp_text) = lo_client->execute(
*          i_method = if_web_http_client=>post
*        )->get_text( ).
*      CATCH cx_web_http_client_error cx_web_message_error.
*        "handle exception
*    ENDTRY.

    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_url(
                                  'https://router.huggingface.co/v1/chat/completions' ).
      CATCH cx_http_dest_provider_error.
        "handle exception
    ENDTRY.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
      CATCH cx_web_http_client_error.
        "handle exception
    ENDTRY.



    lo_client->get_http_request( )->set_content_type( 'application/json' ).
    lo_client->get_http_request( )->set_text( lv_body ).

    TRY.
        DATA(lv_resp_text) = lo_client->execute( i_method = if_web_http_client=>post )->get_text( ).

        DATA(ls_resp) = VALUE ty_resp( ).

        /ui2/cl_json=>deserialize(
          EXPORTING json = lv_resp_text
          CHANGING  data = ls_resp ).

      CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lx_error).
        DATA(lv_msg) = lx_error->get_text( ).
    ENDTRY.


  ENDMETHOD.


ENDCLASS.
