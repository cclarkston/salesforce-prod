public class HcsApiService {
  private CtrlLendingApp controller;
  private String patientCenterName;
  private Map<String, String> states;

  public HcsApiService(CtrlLendingApp controller, String patientCenterName) {
    this.controller = controller;
    this.patientCenterName = patientCenterName;
    assignStateAbbreviations();
  }

  public HttpResponse submitHcsInquiry() {
    String authorizationResponse 	= sendHcsAuthorizationRequest();
    String accessToken = setHcsAuthorizationInfo(authorizationResponse);
    HttpResponse response;

    if(accessToken != null) {
      String hcsRequestBody = buildHcsRequest();
      response = sendHcsRequest(accessToken, hcsRequestBody);
    } else {
      controller.addMessage('The PreQ App is currently unavailable. The HCS access token is '
                          + 'invalid. Contact the ClearChoice IT department for assistance.');
    }
    return response;
  }

  @TestVisible
  private String sendHcsAuthorizationRequest() {
    String clientId = controller.sandbox ? 'P1705-01-CCE'
                                         : 'P1710-02-CCD';
    String clientSecret = controller.sandbox ? '32892C6C920224D7EA2A4AAA982C09152'
                                             : 'rsxYSAnuhVx-Sy6Cr5qx9Ea74CHVyAf*';
    String grantType = 'client_credentials';
    String accessTokenUrl = controller.sandbox ? 'http://sandbox-api.hcsloans.com/auth/token'
                                               : 'https://api.hcsloans.com/auth/token';
    String body = 'client_id=' + clientId
                + '&client_secret=' + clientSecret
                + '&grant_type=' + grantType;

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(accessTokenUrl);
    request.setMethod('POST');
    request.setTimeout(60000);
    request.setBody(body);

    response = http.send(request);
    System.debug('hcsResponse: auth response' + response);
    return response.getBody();
  }

  @TestVisible
  private String setHcsAuthorizationInfo(String authorizationResponse) {
    Map<String, Object> response =
                  (Map<String, Object>)JSON.deserializeUntyped(authorizationResponse);

    return (String)response.get('access_token');
  }

  @TestVisible
  private String buildHcsRequest() {
    String emailAddress = controller.patient.PersonEmail == null
                        ? controller.virtualPatient.PersonEmail
                        : controller.patient.PersonEmail;

    JSONGenerator request = JSON.createGenerator(true);
    request.writeStartObject();

    request.writeFieldName('Office');
    request.writeStartObject();
    request.writeStringField('Id', controller.centerOfficeId.get(patientCenterName));
    request.writeEndObject();
    request.writeObjectField('EstimatedServiceDate', (Date.today() + 30).format());
    request.writeNumberField('AppliedAmount', controller.application.Loan_Amount__c);

    request.writeFieldName('Applicant');
    request.writeStartObject();
    request.writeStringField('FirstName', controller.patient.FirstName);
    request.writeStringField('LastName', controller.patient.LastName);
    request.writeStringField('ssn', controller.ssn);

    request.writeFieldName('Address');
    request.writeStartObject();
    request.writeStringField('StreetLine1', controller.patient.BillingStreet);
    request.writeStringField('StreetLine2', '');
    request.writeStringField('City', controller.patient.BillingCity);
    request.writeStringField('State', states.get(controller.patient.BillingState));
    request.writeStringField('ZipCode', controller.patient.BillingPostalCode);
    request.writeStringField('Country', 'United States');
    request.writeEndObject();

    request.writeFieldName('DocumentIdentification');
    request.writeStartObject();
    request.writeFieldName('IdentificationType');
    request.writeStartObject();
    request.writeStringField('Id', controller.documentIdType.get(controller.application.Id_Type__c));
    request.writeEndObject();
    request.writeStringField('IdentificationNumber', controller.application.Id_Number__c);
    request.writeStringField('IdentificationStateIssuance', states.get(controller.application.Id_State__c));
    request.writeStringField('IdentificationIssuanceDate', controller.application.Id_Issuance_Date__c.format());
    request.writeStringField('IdentificationExpirationDate', controller.application.Id_Expiration_Date__c.format());
    request.writeEndObject();

    request.writeStringField('Email', emailAddress);
    request.writeStringField('Dob', controller.patient.Date_of_Birth__c.format());
    request.writeStringField('PhoneNumber', controller.cleanPhone(controller.patient.Phone));
    request.writeStringField('MobileNumber', controller.verifyMobileNumber());
    request.writeEndObject();

    request.writeFieldName('EmploymentInfo');
    request.writeStartObject();
    request.writeFieldName('EmploymentType');
    request.writeStartObject();
    request.writeStringField('Id', controller.employmentStatusId.get(controller.application.Employment_Status__c));
    request.writeEndObject();
    request.writeNumberField('GrossIncome', controller.application.Gross_Yearly_Individual_Income__c);
    request.writeEndObject();

    request.writeEndObject();

    return request.getAsString();
  }

  @TestVisible
  private HttpResponse sendHcsRequest(String accessToken, String requestBody) {
    String authorizationToken = 'Bearer ' + accessToken;

    String requestUrl = controller.sandbox ? 'http://sandbox-api.hcsloans.com/api/v1/LoanApplication/Prequal'
                                           : 'https://api.hcsloans.com/api/v1/LoanApplication/Prequal';

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(requestUrl);
    request.setMethod('POST');
    request.setTimeout(60000);
    request.setHeader('Authorization', authorizationToken);
    request.setHeader('Content-Type', 'application/json');
    request.setBody(requestBody);

    try {
      response = http.send(request);
      System.debug('hcsResponse: offer response' + response.getBody());
    } catch(Exception error) {
      controller.addMessage('The HCS API is not responding. Please try again in 30 minutes.');
    }
    return response;
  }

  public void saveHcsResponse(HttpResponse jsonResponse) {
    controller.errorMessages = new List<String>();

    String inquiryResponse = jsonResponse.getBody();
    String inquiryResponseStatus = jsonResponse.getStatus();

    if (inquiryResponseStatus == 'Internal Server Error') {
      controller.header = 'PreQ Service Unavailable';
      controller.page = 'unavailable';
    } else	if (inquiryResponseStatus == 'Bad Request') {
      handleHcsErrorMessages(inquiryResponse);
    } else {
      HcsJsonResponse response = HcsJsonResponse.parse(inquiryResponse);
      if (response.Result.ApplicationStatus.Name == 'Declined') {

        } else {
          Lending_App_Offer__c[] offers = new Lending_App_Offer__c[]{};
          offers = createListOfHcsOffers(response, offers);
          try {
            insert offers;
            controller.hasStandardOffers = true;
          } catch(DmlException error) {
            controller.addMessage('There is a problem inserting the HCS offers. Contact ClearChoice for '+
            'more information. The specific error is: ' + error);
          }
        }
    }
  }

  private void handleHcsErrorMessages(String inquiryResponse) {
    Map<String, Object> body =
                  (Map<String, Object>)JSON.deserializeUntyped(inquiryResponse);
    Map<String, Object> messages = (Map<String, Object>)body.get('Messages');
    Set<String> keys = messages.keySet();

    controller.addErrorMessages(messages, keys);
  }

  // CREATE A LIST OF OFFERS TO SAVE

  private Lending_App_Offer__c[] createListOfHcsOffers(HcsJsonResponse response, Lending_App_Offer__c[] offers) {
    String offerUrl = response.Result.LoanApplicationUrl; //<-- I think this is wrong!

    for(HcsJsonResponse.ProductOffers detail : response.Result.ProductOffers) {
      Lending_App_Offer__c offer = new Lending_App_Offer__c();
      offer.Account__c = controller.patientId;
      offer.APR__c = detail.APR;
      offer.Lender__c = 'Health Credit Services';
      offer.Min_Line__c = detail.MinLine;
      offer.Max_Line__c = detail.MaxLine;
      offer.Term__c = detail.Term;
      offer.Loan_Application_Url__c = offerUrl;
      offer.Monthly_Payment__c = calculateMonthlyPayment(offer.Max_Line__c, offer.APR__c, offer.Term__c);
      offers.add(offer);
    }
    return offers;
  }

  private Decimal calculateMonthlyPayment(Decimal presentValue, Decimal apr, Decimal term) {
		Double rate = (apr * 0.01) / 12;
		Integer n = (term).intValue();

		Decimal basePayment =  ((rate * presentValue) / (1 - Math.pow(1 + rate, -n))).setScale(2);
		return basePayment;
	}

  private void assignStateAbbreviations() {
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