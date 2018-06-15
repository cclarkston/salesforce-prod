public with sharing class ProceedFinanceApiService {
  private CtrlLendingApp controller;
  private String secretKey {get; set;}
  private String encryptedSsn {get; set;}
  private ProceedFinanceOffer[] proceedFinanceOffers {get; set;}

	public ProceedFinanceApiService(CtrlLendingApp controller) {
    this.controller = controller;
    fetchSecretKey();
    encryptSsn();
	}

  private void fetchSecretKey() {
    secretKey = [SELECT secretKey__c
                 FROM Proceed_Finance__c
               ][0].secretKey__c;
  }

  private void encryptSsn() {
    Blob key = Blob.valueOf(secretKey);
    Blob data = Blob.valueOf(controller.ssn);
    Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key, data);

    encryptedSsn = EncodingUtil.base64Encode(encryptedData);
  }

  public HttpResponse submitProceedFinanceInquiry() {
    String proceedFinanceRequestBody = buildProceedFinanceRequest();
    HttpResponse response = sendProceedFinanceRequest(proceedFinanceRequestBody);

    return response;
  }

  @TestVisible
  private String buildProceedFinanceRequest() {

    // replace hard coded email with function
    String pecEmail = fetchPecEmail();

    String borrowerEmail = controller.patient.PersonEmail == null
                         ? controller.virtualPatient.PersonEmail
                         : controller.patient.PersonEmail;
    String fname = controller.patient.FirstName;
    String lname = controller.patient.LastName;
    String loanAmount = String.valueOf(controller.application.Loan_Amount__c);
    String dob = String.valueOf(controller.patient.Date_of_Birth__c);
    String physicalAddress = controller.patient.BillingStreet;
    String city = controller.patient.BillingCity;
    String state = controller.patient.BillingState;
    String zipCode = controller.patient.BillingPostalCode;
    String primaryPhone = formatPhone();
    String ssn = encryptedSsn;
    String grossYearlyIndividualIncome = String.valueOf(controller.application.Gross_Yearly_Individual_Income__c);
    String grossYearlyHouseholdIncome = String.valueOf(controller.application.Gross_Yearly_Household_Income__c);
    String mortgageRentType = controller.application.Residence_Type__c == null
                            ? 'None'
                            : controller.application.Residence_Type__c;
    String mortgageRent = String.valueOf(controller.application.Monthly_Residence_Payment__c) == null
                        ? '0'
                        : String.valueOf(controller.application.Monthly_Residence_Payment__c);

    String requestBody = 'email='+EncodingUtil.urlEncode(pecEmail, 'UTF-8')
                       + '&borrower_email='+EncodingUtil.urlEncode(borrowerEmail, 'UTF-8')
                       + '&fname='+EncodingUtil.urlEncode(fname, 'UTF-8')
                       + '&lname='+EncodingUtil.urlEncode(lname, 'UTF-8')
                       + '&desired_loan_amount='+EncodingUtil.urlEncode(loanAmount, 'UTF-8')
                       + '&dob='+EncodingUtil.urlEncode(dob, 'UTF-8')
                       + '&physical_address='+EncodingUtil.urlEncode(physicalAddress, 'UTF-8')
                       + '&city='+EncodingUtil.urlEncode(city, 'UTF-8')
                       + '&state='+EncodingUtil.urlEncode(state, 'UTF-8')
                       + '&zip_code='+EncodingUtil.urlEncode(zipCode, 'UTF-8')
                       + '&primary_phone='+EncodingUtil.urlEncode(primaryPhone, 'UTF-8')
                       + '&social_security_number='+EncodingUtil.urlEncode(ssn, 'UTF-8')
                       + '&gross_yearly_ind_income='+EncodingUtil.urlEncode(grossYearlyIndividualIncome, 'UTF-8')
                       + '&gross_yearly_add_income='+EncodingUtil.urlEncode(grossYearlyHouseholdIncome, 'UTF-8')
                       + '&monthly_mort_rent_type='+EncodingUtil.urlEncode(mortgageRentType, 'UTF-8')
                       + '&monthly_mort_rent='+EncodingUtil.urlEncode(mortgageRent, 'UTF-8');

    return requestBody;
  }

  @TestVisible
  private String fetchPecEmail() {
    String userId = UserInfo.getUserId();
    String pecEmail = [SELECT Email
                       FROM User
                       WHERE Id = :userId
                     ].Email;

    return pecEmail;
  }

  private String formatPhone() {
    String phoneNumber = controller.cleanPhone(controller.patient.Phone);
    String areaCode = phoneNumber.substring(0, 3);
    String prefix = phoneNumber.substring(3, 6);
    String line = phoneNumber.substring(6, 10);
    String formattedNumber = '(';
    formattedNumber += areaCode;
    formattedNumber += ')';
    formattedNumber += ' ';
    formattedNumber += prefix;
    formattedNumber += '-';
    formattedNumber += line;
    return formattedNumber;
  }

  @TestVisible
  private HttpResponse sendProceedFinanceRequest(String requestBody) {
    HttpResponse redirectResponse;
    String requestUrl = controller.sandbox ? 'https://stage.proceedfinance.com/api/web/v1/api/add-patient'
                                           : 'https://prequal.proceedfinance.com/api/web/v1/api/add-patient';

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(requestUrl);
    request.setMethod('POST');
    request.setTimeout(90000);
    request.setHeader('api_key', 'yapapp');
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setHeader('Accept', 'application/json');
    request.setBody(requestBody);

    try {
      response = http.send(request);
      System.debug('proceedResponse: response from first call:' + response.getBody());
    } catch(Exception error) {
      controller.addMessage('There is a problem with the Proceed Finance API: ' + error);
    }

    Integer responseStatusCode = response.getStatusCode();
    if(responseStatusCode == 302) {
      String redirectUrl = response.getHeader('Location');
      redirectResponse = handleRedirect(redirectUrl);
    } else if (responseStatusCode == 200) {
      handleProceedFinanceErrors(response);
    } else {
      controller.addMessage('There is a problem with the Proceed Finance API.');
    }
    return redirectResponse;
  }

  private void handleProceedFinanceErrors(HttpResponse response) {
    String allMessages = '';
    String inquiryResponse = response.getBody();

    Map<String, Object> body =
                  (Map<String, Object>)JSON.deserializeUntyped(inquiryResponse);

    Map<String, Object> data = (Map<String, Object>)body.get('data');

    Integer statusCode = (Integer)body.get('statusCode');

    if(statusCode == 400) {
      controller.proceedFinanceDeclined = true;
    } else {
      Map<String, Object> errorMessages = (Map<String, Object>)body.get('error');

      for(String message : errorMessages.keySet()) {
        allMessages += errorMessages.get(message);
      }

      controller.addMessage(allMessages);
    }
  }

  private HttpResponse handleRedirect(String redirectUrl) {
    String requestUrl = controller.sandbox ? 'https://stage.proceedfinance.com/api/web/v1/api/'
                                           : 'https://prequal.proceedfinance.com/api/web/v1/api/';

    requestUrl = requestUrl + redirectUrl;


    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(requestUrl);
    request.setMethod('POST');
    request.setTimeout(90000);
    request.setHeader('api_key', 'yapapp');
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setHeader('Accept', 'application/json');
    request.setBody('');

    try {
      response = http.send(request);
      System.debug('proceedResponse: response from redirect URL' + response.getBody());
    } catch(Exception error) {
      controller.addMessage('There is a problem with the Proceed Finance API: ' + error);
    }

    return response;
  }

  public void saveProceedFinanceResponse(HttpResponse jsonResponse) {
    controller.errorMessages = new List<String>();

    String inquiryResponse = jsonResponse.getBody();

    Map<String, Object> body =
                  (Map<String, Object>)JSON.deserializeUntyped(inquiryResponse);

    Map<String, Object> data = (Map<String, Object>)body.get('data');

    Integer statusCode = (Integer)body.get('statusCode');

    if(statusCode == 200) {
      insertProceedFinanceOffers(data);
    } else if (statusCode == 400) {
      controller.proceedFinanceDeclined = true;
    }
  }

  private void insertProceedFinanceOffers(Map<String, Object> data) {
    proceedFinanceOffers = new ProceedFinanceOffer[]{};
    parseJsonResponse(data);
    Lending_App_Offer__c[] offers = new Lending_App_Offer__c[]{};
    offers = createListOfProceedFinanceOffers(offers);

    try {
      insert offers;
      controller.hasStandardOffers = true;
    } catch(DmlException error) {
      controller.addMessage('There is a problem inserting the Proceed Finance offers. Contact ClearChoice for '
                          + 'more information. The specific error is: ' + error);
    }
  }

  private void parseJsonResponse(Map<String, Object> data) {
    Integer i = 0;
    Integer term = 24;
    Integer loanAmountApproved = (Integer)data.get('loanAmountApproved');
    String authId = (String)data.get('authId');

    String offerUrl = fetchOfferUrl(authId);

    while(i < 5) {
      String objectId = String.valueOf(term);

      Map<String, Object> emiData = (Map<String, Object>)data.get('emiData');

      Map<String, Object> offerDetails = (Map<String, Object>)emiData.get(objectId);

      Decimal monthlyPayment = (Decimal)offerDetails.get('emi');

      String apr = (String)offerDetails.get('rate');

      ProceedFinanceOffer offer = new ProceedFinanceOffer(loanAmountApproved, term, apr, offerUrl, monthlyPayment);
      proceedFinanceOffers.add(offer);

      i++;
      term += 12;
    }
  }

  public class ProceedFinanceOffer {
    String lender {get; set;}
    Integer loanAmountApproved {get; set;}
    Integer term {get; set;}
    String apr {get; set;}
    String offerUrl {get; set;}
    Decimal monthlyPayment {get; set;}

    public ProceedFinanceOffer(Integer loanAmountApproved, Integer term, String apr, String offerUrl, Decimal monthlyPayment) {
      this.lender = 'Proceed Finance';
      this.loanAmountApproved = loanAmountApproved;
      this.term = term;
      this.apr = apr;
      this.offerUrl = offerUrl;
      this.monthlyPayment = monthlyPayment;
    }
  }

  private Lending_App_Offer__c[] createListOfProceedFinanceOffers(Lending_App_Offer__c[] offers) {
    for(ProceedFinanceOffer detail : proceedFinanceOffers) {
      Lending_App_Offer__c offer = new Lending_App_Offer__c();
      offer.Account__c = controller.patientId;
      offer.APR__c = (Decimal.valueOf(detail.apr));
      offer.Lender__c = 'Proceed Finance';
      offer.Min_Line__c = 0;
      offer.Max_Line__c = Integer.valueOf(detail.loanAmountApproved);
      offer.Term__c = detail.term;
      offer.Loan_Application_Url__c = detail.offerUrl;
      offer.Monthly_Payment__c = detail.monthlyPayment;
      offers.add(offer);
    }
    return offers;
  }

  private String fetchOfferUrl(String authId) {
    String requestUrl = controller.sandbox ? 'https://stage.proceedfinance.com/api/web/v1/api/proceed'
                                           : 'https://prequal.proceedfinance.com/api/web/v1/api/proceed';

    String requestBody = 'authId='+EncodingUtil.urlEncode(authId, 'UTF-8');

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(requestUrl);
    request.setMethod('POST');
    request.setTimeout(90000);
    request.setHeader('api_key', 'yapapp');
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setHeader('Accept', 'application/json');
    request.setBody(requestBody);

    try {
      response = http.send(request);
      System.debug('proceedResponse: response with offer URL' + response.getBody());
    } catch(Exception error) {
      controller.addMessage('There is an issue with the Proceed Finance API. Please try again in 30 minutes.');
    }

    String responseStatus = response.getStatus();
    Integer responseStatusCode = response.getStatusCode();
    String responseBody = response.getBody();


    String inquiryResponse = response.getBody();

    Map<String, Object> body =
                  (Map<String, Object>)JSON.deserializeUntyped(inquiryResponse);

    Map<String, Object> data = (Map<String, Object>)body.get('data');

    String offerUrl = (String)data.get('url');

    return offerUrl;
  }
}