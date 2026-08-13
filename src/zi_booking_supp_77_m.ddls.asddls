@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKING_SUPP_77_M
  as select from zdt_booksup_77_m
  association [1..1] to ZI_TRAVEL_77_M         as _travel         on  $projection.TravelId = _travel.TravelId
  association        to parent ZI_BOOKING_77_M as _booking        on  $projection.TravelId  = _booking.TravelId
                                                                  and $projection.BookingId = _booking.BookingId
  association [1..1] to /DMO/I_Supplement      as _supplement     on  $projection.SupplementId = _supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText  as _supplementtext on  $projection.SupplementId = _supplementtext.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _travel,
      _booking,
      _supplement,
      _supplementtext
}
