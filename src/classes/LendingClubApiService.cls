public with sharing class LendingClubApiService {
  CtrlLendingApp controller;
  private Map<String, String> states;

	public LendingClubApiService(CtrlLendingApp controller) {
    this.controller = controller;
    assignStateToAbbreviations();
	}

  public HttpResponse submitLendingClubInquiry() {
    System.debug('crash: ' + 'setting up request to lending club');

    String lendingClubRequestBody = buildLendingClubRequest();
    HttpResponse response = sendLendingClubRequest(lendingClubRequestBody);

    return response;
  }

  @TestVisible
  private String buildLendingClubRequest() {
    String clientId = fetchClientId();

    JSONGenerator request = JSON.createGenerator(true);
    request.writeStartObject();

    request.writeStringField('clientId', clientId);
    request.writeNumberField('loanAmount', controller.application.Loan_Amount__c);
    request.writeStringField('appliedBy', 'Patient');
    request.writeBooleanField('electronicConsentFlag', false);
    request.writeBooleanField('creditAuthConsentFlag', true);

    request.writeFieldName('borrower');
    request.writeStartObject();
    request.writeStringField('firstName', controller.patient.FirstName);
    request.writeStringField('lastName', controller.patient.LastName);
    request.writeStringField('homePhone', controller.cleanPhone(controller.patient.Phone));
    request.writeStringField('email', controller.patient.PersonEmail);
    request.writeStringField('dob', formatDate());
    request.writeStringField('ssn', controller.ssn);

    request.writeFieldName('physicalAddress');
    request.writeStartObject();
    request.writeStringField('street', controller.patient.BillingStreet);
    request.writeStringField('city', controller.patient.BillingCity);
    request.writeStringField('state', states.get(controller.patient.BillingState));
    request.writeStringField('zip', controller.patient.BillingPostalCode);
    request.writeEndObject();

    request.writeFieldName('mailingAddress');
    request.writeStartObject();
    request.writeStringField('street', controller.patient.BillingStreet);
    request.writeStringField('city', controller.patient.BillingCity);
    request.writeStringField('state', states.get(controller.patient.BillingState));
    request.writeStringField('zip', controller.patient.BillingPostalCode);
    request.writeEndObject();

    request.writeFieldName('income');
    request.writeStartObject();
    request.writeNumberField('grossYearlySalary', controller.application.Gross_Yearly_Individual_Income__c);
    request.writeNumberField('grossYearlyOtherIncome', controller.application.Gross_Yearly_Household_Income__c);
    request.writeNumberField('monthlyResidencePayment', controller.application.Monthly_Residence_Payment__c);
    request.writeEndObject();
    request.writeEndObject();

    request.writeFieldName('recipient');
    request.writeStartObject();
    request.writeStringField('firstName', controller.patient.FirstName);
    request.writeStringField('lastName', controller.patient.LastName);
    request.writeStringField('relationship', 'SELF');
    request.writeEndObject();

    request.writeEndObject();

    System.debug('crash: ' + request.getAsString());
    return request.getAsString();
  }

  @TestVisible
  private String fetchClientId() {
    Id centerId = controller.patient.Center__c;

    String lenderId = [SELECT Id
                       FROM Lender__c
                       WHERE Name = 'Lending Club'
                     ].Id;
                     System.debug('lenderId: ' + lenderId);

    String clientId = [SELECT Client_Id__c
                       FROM Lender_Center_Client_Id__c
                       WHERE Center__r.Id  = :centerId
                       AND Lender__c = :lenderId
                       LIMIT 1
                     ].Client_Id__c;
                     System.debug('clientId: ' + clientId);

    return clientId;
  }

  @TestVisible
  private HttpResponse sendLendingClubRequest(String requestBody) {
    String requestEndpoint = fetchRequestEndpoint();

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();
    System.debug('crash: ' + requestBody);
    request.setEndpoint(requestEndpoint);
    request.setMethod('POST');
    request.setTimeout(60000);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept-Type', 'application/json');
    request.setBody(requestBody);

    try {
      response = http.send(request);
    } catch(Exception error) {
      controller.addMessage('The Lending Club API is not responding. Please try again in 30 minutes.');
    }
    return response;
  }

  private String fetchRequestEndpoint() {
    String endpoint;

    if(controller.sandbox) {
      endpoint = [SELECT Sandbox_Api_Endpoint__c
                  FROM Lender__c
                ].Sandbox_Api_Endpoint__c;
    } else {
      endpoint = [SELECT Production_Api_Endpoint__c
                  FROM Lender__c
                ].Production_Api_Endpoint__c;
    }
    return endpoint;
  }

  private void addMessage(String message) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
	}

  @TestVisible
  private String formatDate() {
    Date targetDate = controller.patient.Date_of_Birth__c;
    return String.valueof(targetDate.year()) + '-'
         + String.valueof(targetDate.month()) + '-'
         + String.valueof(targetDate.day());
  }

	public void saveLendingClubResponse(HttpResponse jsonResponse) {
		controller.errorMessages = new List<String>();

		String applicationResponseStatus = jsonResponse.getStatus();
    String applicationResponse = jsonResponse.getBody();

    LendingClubJsonResponse response = LendingClubJsonResponse.parse(applicationResponse);
    System.debug('crash: ' + response);
    if(response.Offers[0].loanApplicationResponse == 'DECLINED') {
      controller.lendingClubDeclined = true;
    } else {
      handleApprovedOffers(response);
    }
	}

  private void handleApprovedOffers(LendingClubJsonResponse response) {
    LendingClubJsonResponse.offerItems[] responseStandardOffers = response.Offers[0].OfferItems;
    LendingClubJsonResponse.offerItems[] responsePromotionalOffers = response.Offers[1].OfferItems;
    if (responseStandardOffers != null) {
      createOffers(responseStandardOffers);
      controller.hasStandardOffers = true;
    }

    if (responsePromotionalOffers != null) {
      createOffers(responsePromotionalOffers);
      controller.hasPromotionalOffers = true;
    }
  }

  private void createOffers(LendingClubJsonResponse.offerItems[] responseOffers) {
    Lending_App_Offer__c[] offers = new Lending_App_Offer__c[]{};
    offers = createListOfLendingClubOffers(responseOffers, offers);
    try {
      insert offers;
    } catch(DmlException error) {
      controller.addMessage('There is a problem inserting the offers. Contact ClearChoice for '+
      'more information. Error message: ' + error);
    }
  }

	private void handleLendingClubErrorMessages(String applicationResponse) {
		Map<String, Object> body =
									(Map<String, Object>)JSON.deserializeUntyped(applicationResponse);
		Map<String, Object> messages = (Map<String, Object>)body.get('Messages');
		Set<String> keys = messages.keySet();

		controller.addErrorMessages(messages, keys);
	}

  private Lending_App_Offer__c[] createListOfLendingClubOffers(LendingClubJsonResponse.OfferItems[] response, Lending_App_Offer__c[] offers) {
    for(LendingClubJsonResponse.OfferItems detail : response) {
      Lending_App_Offer__c offer = new Lending_App_Offer__c();
      offer.Account__c = controller.patientId;
      offer.APR__c = (Decimal.valueOf(detail.intRate) * 100);
      offer.Lender__c = 'Lending Club Patient Solutions';
      offer.Min_Line__c = 0;
      offer.Max_Line__c = detail.amount;
      offer.Term__c = detail.term;
      offer.Loan_Application_Url__c = detail.url;
      offer.Monthly_Payment__c = detail.monthlyPayment;
      offer.Promotional_Period__c = detail.promotionalPeriod;
      offers.add(offer);
    }
    return offers;
  }

  private void assignStateToAbbreviations() {
    states = new Map<String, String>{ 'Alabama'=>'AL',
                                      'Alaska'=>'AK',
                                      'Arizona'=>'AZ',
                                      'Arkansas'=>'AR',
                                      'California'=>'CA',
                                      'Colorado'=>'CO',
                                      'Connecticut'=>'CT',
                                      'Delaware'=>'DE',
                                      'District of Columbia'=>'DC',
                                      'Florida'=>'FL',
                                      'Georgia'=>'GA',
                                      'Hawaii'=>'HI',
                                      'Idaho'=>'ID',
                                      'Illinois'=>'IL',
                                      'Indiana'=>'IN',
                                      'Iowa'=>'IA',
                                      'Kansas'=>'KS',
                                      'Kentucky'=>'KY',
                                      'Louisiana'=>'LA',
                                      'Maine'=>'ME',
                                      'Maryland'=>'MD',
                                      'Massachusetts'=>'MA',
                                      'Michigan'=>'MI',
                                      'Minnesota'=>'MN',
                                      'Mississippi'=>'MS',
                                      'Missouri'=>'MO',
                                      'Montana'=>'MT',
                                      'Nebraska'=>'NE',
                                      'Nevada'=>'NV',
                                      'New Hampshire'=>'NH',
                                      'New Jersey'=>'NJ',
                                      'New Mexico'=>'NM',
                                      'New York'=>'NY',
                                      'North Carolina'=>'NC',
                                      'North Dakota'=>'ND',
                                      'Ohio'=>'OH',
                                      'Oklahoma'=>'OK',
                                      'Oregon'=>'OR',
                                      'Pennsylvania'=>'PA',
                                      'Rhode Island'=>'RI',
                                      'South Carolina'=>'SC',
                                      'South Dakota'=>'SD',
                                      'Tennessee'=>'TN',
                                      'Texas'=>'TX',
                                      'Utah'=>'UT',
                                      'Vermont'=>'VT',
                                      'Virginia'=>'VA',
                                      'Washington'=>'WA',
                                      'West Virginia'=>'WV',
                                      'Wisconsin'=>'WI',
                                      'Wyoming'=>'WY'
                                    };
  }
}