@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suppl Consumption View'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_BOOKING_SUPP_77_M
  as projection on ZI_BOOKING_SUPP_77_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplementText' ]
      SupplementId,
      _supplementtext.Description as SupplementText : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _booking : redirected to parent ZC_BOOKING_77_M,
      _supplement,
      _supplementtext,
      _travel  : redirected to ZC_TRAVEL_77_M
}
