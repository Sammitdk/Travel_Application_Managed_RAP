@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Consumption View'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_TRAVEL_77_M
  provider contract transactional_query
  as projection on ZI_TRAVEL_77_M
{
  key TravelId,
      @ObjectModel.text.element: [ 'Agency_Name' ]

      AgencyId,
      _Agency.Name       as Agency_Name,
      @ObjectModel.text.element: [ 'Customer_name' ]
      CustomerId,
      _Customer.LastName as Customer_name,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      _status._Text.Text as OverallStatusText : localized,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _booking : redirected to composition child ZC_BOOKING_77_M,
      _currency,
      _Customer,
      _status
}
