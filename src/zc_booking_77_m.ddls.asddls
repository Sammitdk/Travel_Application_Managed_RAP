@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Consumption View'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_BOOKING_77_M
  as projection on ZI_BOOKING_77_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _customer.LastName         as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _carrier.Name              as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'bookingStatusText' ]
      BookingStatus,
      _booking_status._Text.Text as bookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _booking_status,
      _booking_supp : redirected to composition child ZC_BOOKING_SUPP_77_M,
      _carrier,
      _connection,
      _customer,
      _travel       : redirected to parent ZC_TRAVEL_77_M
}
