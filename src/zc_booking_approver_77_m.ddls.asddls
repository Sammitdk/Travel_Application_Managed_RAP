@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Approver'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: {
        type: #STANDARD,
        value: 'BookingId'
    }
}
define view entity ZC_BOOKING_APPROVER_77_M
  as projection on ZI_BOOKING_77_M
{

      @UI.facet: [{ id: 'BookingInfo' ,
                    purpose: #STANDARD,
                    position: 10,
                    type: #IDENTIFICATION_REFERENCE }]
      //      @UI : {  lineItem: [ { position : 10, importance : #HIGH } ] }
  key TravelId,
      @UI : {  lineItem: [ { position : 20, importance : #HIGH } ],
               identification: [ { position : 20, importance : #HIGH } ] }
  key BookingId,
      @UI : {  lineItem: [ { position : 30, importance : #HIGH } ],
               identification: [ { position : 30, importance : #HIGH } ]  }
      BookingDate,
      @UI : {  lineItem: [ { position : 40, importance : #HIGH } ],
               identification: [ { position : 40, importance : #HIGH } ]  }
      CustomerId,
      CarrierId,
      ConnectionId,
      @UI : {  lineItem: [ { position : 50, importance : #HIGH } ],
               identification: [ { position : 50, importance : #HIGH } ]  }
      FlightDate,
      @UI : {  lineItem: [ { position : 60, importance : #HIGH } ],
               identification: [ { position : 60, importance : #HIGH } ]  }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @UI : {  identification: [ { position : 70, importance : #HIGH } ],
                textArrangement: #TEXT_ONLY }
      @ObjectModel.text.element: [ 'bookingStatusText' ]
      BookingStatus,
      _booking_status._Text.Text as bookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _booking_status,
      _booking_supp,
      _carrier,
      _connection,
      _customer,
      _travel : redirected to parent ZC_TRAVEL_APPROVER_77_M
}
