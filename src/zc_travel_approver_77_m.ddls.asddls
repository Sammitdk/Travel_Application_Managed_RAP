@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Approver'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        value: 'TravelId'
    }
}
@Search.searchable: true
define root view entity ZC_TRAVEL_APPROVER_77_M
  provider contract transactional_query
  as projection on ZI_TRAVEL_77_M
{
      @UI.facet: [{
                    id: 'Travel',
                    purpose: #STANDARD,
                    position: 10,
                    label: 'Travel',
                    type: #IDENTIFICATION_REFERENCE
                },{
                    id: 'Booking',
                    purpose: #STANDARD,
                    position: 20,
                    label: 'Booking',
                    type: #LINEITEM_REFERENCE,
                    targetElement: '_booking'
                }]

      @UI : {  lineItem: [ { position : 10, importance : #HIGH },
                           { position : 10 }]}
  key TravelId,

      @UI : {  lineItem: [ { position : 20, importance : #HIGH } ],
               identification: [{ position : 20, importance : #HIGH }],
               selectionField: [{ position : 20 }] }

      @Consumption.valueHelpDefinition: [{ entity: {
                                name: '/DMO/I_Agency',
                                element: 'AgencyID'
                            } }]

      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true

      AgencyId,
      _Agency.Name       as AgencyName,

      @UI : {  lineItem: [ { position : 30, importance : #HIGH } ],
              identification: [{ position : 30, importance : #HIGH }],
              selectionField: [{ position : 30 }] }

      @Consumption.valueHelpDefinition: [{ entity: {
                                name: '/DMO/I_Customer',
                                element: 'CustomerID'
                            } }]

      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      CustomerId,
      _Customer.LastName as CustomerName,
      @UI : {  identification: [{ position : 40, importance : #HIGH }] }
      BeginDate,
      @UI : {  identification: [{ position : 50, importance : #HIGH}] }
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI : {  lineItem: [ { position : 60, importance : #MEDIUM } ],
             identification: [{ position : 60, importance : #MEDIUM }]  }
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI : {  lineItem: [ { position : 70, importance : #MEDIUM } ],
            identification: [{ position : 70, importance : #MEDIUM }]  }
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity: {
                               name: 'I_CURRENCY',
                               element: 'Currency'
                           } } ]
      CurrencyCode,
      @UI : {  lineItem: [ { position : 80, importance : #MEDIUM } ],
      identification: [{ position : 80, importance : #MEDIUM }]  }
      Description,

      @UI : {  lineItem: [ { position : 15, importance : #HIGH, label: 'Status' },
                           { type :  #FOR_ACTION, dataAction : 'acceptTravel',
                             label : 'Accept Travel'},{
                             type :  #FOR_ACTION, dataAction : 'rejectTravel',
                             label : 'Reject Travel' } ],
               identification: [{ position : 15, importance : #HIGH, label: 'Status' },
                           { type :  #FOR_ACTION, dataAction : 'acceptTravel',
                             label : 'Accept Travel'},{
                             type :  #FOR_ACTION, dataAction : 'rejectTravel',
                             label : 'Reject Travel' } ],
               textArrangement: #TEXT_ONLY,
               selectionField: [{ position : 90 }]
       }
      @EndUserText.label: 'Overall Status'
      @Consumption.valueHelpDefinition: [{ entity: {
                                               name: '/DMO/I_OVERALL_STATUS_VH',
                                               element: 'OverallStatus'
                                           } }]
      @ObjectModel.text.element: [ 'overallstatusText' ]
      OverallStatus,
      @UI.hidden: true
      _status._Text.Text as overallstatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _booking : redirected to composition child ZC_BOOKING_APPROVER_77_M,
      _currency,
      _Customer,
      _status
}
