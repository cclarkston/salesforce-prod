@isTest
private class TestProceedFinanceApiService {

  @testSetup static void setup() {
    Id userId = UserInfo.getUserId();

    Proceed_Finance__c customSetting = new Proceed_Finance__c(Name = 'test',
                                                              secretKey__c = '1234567891234567');
    insert customSetting;

    Sales_Region__c region = new Sales_Region__c(Name ='Test Region', RBD__c = UserId);

    insert region;

    Center_Information__c center = new Center_Information__c(Name = 'Atlanta',
                                                             Sales_Region__c = region.ID,
                                                             Latlong__Longitude__s = 30,
                                                             Latlong__Latitude__s = 30);

    insert center;

    Account patient = new Account(FirstName = 'Test', LastName = 'User',
                                  Center__c = center.Id,
                                  BillingStreet = '123 Main St', BillingCity = 'Denver',
                                  BillingState = 'Colorado', BillingPostalCode = '80001',
                                  BillingCountry = 'United States',
                                  Phone = '1234567891', PersonMobilePhone = '1234567891',
                                  PersonEmail = 'testuser@test.com',
                                  Date_of_Birth__c = (System.today() - 20000),
                                  Prostho_Exam_Date__c = (System.today() + 1),
                                  Temp_Password__c = '1234');

    insert patient;

    Lending_App_Offer__c[] offers  = new Lending_App_Offer__c[]{};
    Lending_App_Offer__c standardOffer  = new Lending_App_Offer__c(Account__c = patient.Id);
    offers.add(standardOffer);
    Lending_App_Offer__c promotionalOffer  = new Lending_App_Offer__c(Account__c = patient.Id,
                                                                      Promotional_Period__c = 60);
    offers.add(promotionalOffer);
    insert offers;
  }

  static testMethod void testBuildProceedFinanceRequest() {
    Date issuanceDate = Date.today() - 30;
    Date expirationDate = Date.today() + 30;

    Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
                       FROM Account LIMIT 1];
    Lending_App_Application__c application = new Lending_App_Application__c(
 												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
 												Loan_Amount__c = 25000, Id_Number__c = '1234567',
 												Id_State__c = 'Atlanta', Id_Issuance_Date__c = issuanceDate,
 												Id_Expiration_Date__c = expirationDate,
 												Employment_Status__c = 'Employed',
                        Gross_Yearly_Individual_Income__c = 50000,
                        Gross_Yearly_Household_Income__c = 50000,
                        Monthly_Residence_Payment__c = 1200);

 		insert application;

    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();
    controller.ssn = '666779999';

    ProceedFinanceApiService proceedFinanceApiService = new ProceedFinanceApiService(controller);

    String requestBody = proceedFinanceApiService.buildProceedFinanceRequest();



    System.assert(requestBody(requestBody));
  }

  static Boolean requestBody(String requestBody) {
    String expected = 'borrower_email=testuser%40test.com&fname=Test&lname='
                    + 'User&desired_loan_amount=25000&dob=1963-03-17';

    Boolean result = requestBody.contains(requestBody) ? true : false;
    return result;
  }

  static testMethod void testSendProceedFinanceRequest() {
    Date issuanceDate = Date.today() - 30;
    Date expirationDate = Date.today() + 30;

    Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
                       FROM Account LIMIT 1];
    Lending_App_Application__c application = new Lending_App_Application__c(
 												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
 												Loan_Amount__c = 25000, Id_Number__c = '1234567',
 												Id_State__c = 'Atlanta', Id_Issuance_Date__c = issuanceDate,
 												Id_Expiration_Date__c = expirationDate,
 												Employment_Status__c = 'Employed',
                        Gross_Yearly_Individual_Income__c = 50000,
                        Gross_Yearly_Household_Income__c = 50000,
                        Monthly_Residence_Payment__c = 1200);

 		insert application;

    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();
    controller.ssn = '666779999';

    String body = 'borrower_email=testuser%40test.com&fname=Test&lname=User&desired_loan_amount=25000&dob=1963-03-17';

    ProceedFinanceApiService proceedFinanceApiService = new ProceedFinanceApiService(controller);

    Test.startTest();
      String request = proceedFinanceApiService.buildProceedFinanceRequest();

      Test.setMock(HttpCalloutMock.class, new MockProceedFinanceHttpResponseGenerator(body));
      HttpResponse response = proceedFinanceApiService.sendProceedFinanceRequest(request);
    Test.stopTest();

    Integer statusCode = response.getStatusCode();
    String status = response.getStatus();
    String responseBody  = response.getBody();
    String redirectUrl = response.getHeader('Location');

    System.assertEquals(status, 'Ok');
    System.assertEquals(statusCode, 302);
    System.assertEquals(responseBody, body);
    System.assertEquals(redirectUrl, '/target-url');
  }

  static TestMethod void testFetchPecEmail() {
    String userId = UserInfo.getUserId();
    String userEmail = [SELECT Email
                        FROM User
                        WHERE Id = :userId
                      ].Email;

    Date issuanceDate = Date.today() - 30;
    Date expirationDate = Date.today() + 30;

    Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
                       FROM Account LIMIT 1];
    Lending_App_Application__c application = new Lending_App_Application__c(
 												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
 												Loan_Amount__c = 25000, Id_Number__c = '1234567',
 												Id_State__c = 'Atlanta', Id_Issuance_Date__c = issuanceDate,
 												Id_Expiration_Date__c = expirationDate,
 												Employment_Status__c = 'Employed',
                        Gross_Yearly_Individual_Income__c = 50000,
                        Gross_Yearly_Household_Income__c = 50000,
                        Monthly_Residence_Payment__c = 1200);

 		insert application;

    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();
    controller.ssn = '666779999';

    ProceedFinanceApiService proceedFinanceApiService = new ProceedFinanceApiService(controller);
    String pecEmail = proceedFinanceApiService.fetchPecEmail();

    System.assertEquals(userEmail, pecEmail);
  }

  static TestMethod void testSaveProceedFinanceResponse() {
    String userId = UserInfo.getUserId();
    String userEmail = [SELECT Email
                        FROM User
                        WHERE Id = :userId
                      ].Email;

    Date issuanceDate = Date.today() - 30;
    Date expirationDate = Date.today() + 30;

    Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
                       FROM Account LIMIT 1];
    Lending_App_Application__c application = new Lending_App_Application__c(
 												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
 												Loan_Amount__c = 25000, Id_Number__c = '1234567',
 												Id_State__c = 'Atlanta', Id_Issuance_Date__c = issuanceDate,
 												Id_Expiration_Date__c = expirationDate,
 												Employment_Status__c = 'Employed',
                        Gross_Yearly_Individual_Income__c = 50000,
                        Gross_Yearly_Household_Income__c = 50000,
                        Monthly_Residence_Payment__c = 1200);

 		insert application;

    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();
    controller.ssn = '666779999';

    String body = proceedJsonResponse();

    Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockProceedFinanceHttpResponseGenerator(body));
      ProceedFinanceApiService proceedFinanceApiService = new ProceedFinanceApiService(controller);
      String request = proceedFinanceApiService.buildProceedFinanceRequest();
      HttpResponse response = proceedFinanceApiService.sendProceedFinanceRequest(request);
      proceedFinanceApiService.saveProceedFinanceResponse(response);
    Test.stopTest();

    Integer numberOfOffers = [SELECT Count()
                              FROM Lending_App_Offer__c];

    System.assertNotEquals(0, numberOfOffers);
  }

  static String proceedJsonResponse() {
    String body = '{ "statusCode": 200, "message": "Success","data": { "emiData":' +
                  ' { "24": { "emi": 47.3, "rate": "11.99", "dti": 0.24 }, "36": ' +
                  '{ "emi": 33.87, "rate": "12.99", "dti": 0.17 }, "48": { "emi": ' +
                  '28, "rate": "14.99", "dti": 0.14 }, "60": { "emi": 24.2, ' +
                  '"rate": "15.49", "dti": 0.12 }, "72": { "emi": 21.83, "rate":' +
                  ' "15.99", "dti": 0.11 } }, "loanAmountApproved": 1000, ' +
                  '"authId": "fe2d010308a6b3799a3d9c728ee74244"} }';
    return body;
  }
}