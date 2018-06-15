@isTest
private class TestLendingClubApiService {
  private static Id userId;
  private static Sales_Region__c region;
  private static Center_Information__c center;
  private static Account account;
  private static CtrlLendingApp controller;

  @testSetup
  static void setup() {
    Sales_Region__c region = new Sales_Region__c();
    region.Name ='Test Region';
    region.RBD__c = UserId;
    insert region;

    Center_Information__c center = new Center_Information__c();
    center.Name = 'Atlanta';
    center.Sales_Region__c = region.Id;
    center.Latlong__Longitude__s = 30;
    center.Latlong__Latitude__s = 30;
    insert center;

    Account account = new Account();
    account.FirstName = 'Test';
    account.LastName = 'Patient';
		account.Center__c = center.Id;
		account.BillingStreet = '123 Main St';
    account.BillingCity = 'Denver';
		account.BillingState = 'Colorado';
    account.BillingPostalCode = '80001';
		account.BillingCountry = 'United States';
		account.Phone = '1234567891';
    account.PersonMobilePhone = '1234567891';
		account.PersonEmail = 'testpatient@email.com';
		account.Date_of_Birth__c = System.today().addYears(-30);
		account.Temp_Password__c = '1234';
    insert account;

    Lending_App_Application__c application = new Lending_App_Application__c();
    application.Account__c = account.Id;
    application.Id_Type__c = 'Driver\'s License';
    application.Loan_Amount__c = 25000;
    application.Id_Number__c = '1234567';
    application.Id_State__c = 'Atlanta';
    application.Id_Issuance_Date__c = Date.today().addDays(-30);
    application.Id_Expiration_Date__c = Date.today().addDays(30);
    application.Employment_Status__c = 'Employed';
    application.Gross_Yearly_Individual_Income__c = 50000;
    application.Gross_Yearly_Household_Income__c = 150000;
    application.Monthly_Residence_Payment__c = 1200;
 		insert application;

    Lender__c lender = new Lender__c();
    lender.Name = 'Lending Club';
    lender.Production_Api_Endpoint__c	 = 'https://api.test.com';
    lender.Sandbox_Api_Endpoint__c = 'https://api-sandbox.test.com';
    insert lender;

    Lender_Center_Client_Id__c clientId = new Lender_Center_Client_Id__c();
    clientId.Lender__c = lender.Id;
    clientId.Center__c = center.Id;
    clientId.Client_Id__c = '0189370184708OIUYOIUYOIUY';
    insert clientId;
  }

  private static void init() {
    userId = UserInfo.getUserId();

    account = [SELECT Id, Date_of_Birth__c
               FROM Account
               WHERE Name
               LIKE '%Test Patient'
             ];

    Test.setCurrentPageReference(new PageReference('Page.lending_app'));
    System.currentPageReference().getParameters().put('accountId', account.Id);

    controller = new CtrlLendingApp();
  }

  @isTest
	static void itShoudSubmitLendingClubInquiry() {
    HttpResponse response;
    String successfulResponseBody = successfulResponseBody();

    init();
    controller.ssn = '123456789';

    Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockLendingClubHttpResponseGenerator(successfulResponseBody));
      LendingClubApiService service = new LendingClubApiService(controller);
      response = service.submitLendingClubInquiry();
    Test.stopTest();

    System.assertEquals('Ok', response.getStatus());
    System.assertEquals(200, response.getStatusCode());
    System.assertEquals(successfulResponseBody, response.getBody());
	}

  @isTest
  static void itShouldBuildRequestBody() {
    init();
    controller.ssn = '123456789';

    LendingClubApiService service = new LendingClubApiService(controller);
    String requestBody = service.buildLendingClubRequest();

    LendingClubJsonTestRequest request = LendingClubJsonTestRequest.parse(requestBody);
    String appliedBy = request.appliedBy;
    String firstName = request.borrower.firstName;
    String lastName = request.borrower.lastName;
    String homePhone = request.borrower.homePhone;
    String email = request.borrower.email;
    String ssn = request.borrower.ssn;
    Integer grossYearlySalary = request.borrower.income.grossYearlySalary;
    Integer grossYearlyOtherIncome = request.borrower.income.grossYearlyOtherIncome;
    Integer monthlyResidencePayment = request.borrower.income.monthlyResidencePayment;
    String street = request.borrower.physicalAddress.street;
    String city = request.borrower.physicalAddress.city;
    String state = request.borrower.physicalAddress.state;
    String zip = request.borrower.physicalAddress.zip;

    System.assertEquals(appliedBy, 'Patient');
    System.assertEquals(firstName, 'Test');
    System.assertEquals(lastName, 'Patient');
    System.assertEquals(homePhone, '1234567891');
    System.assertEquals(email, 'testpatient@email.com');
    System.assertEquals(ssn, '123456789');
    System.assertEquals(grossYearlySalary, 50000);
    System.assertEquals(grossYearlyOtherIncome, 150000);
    System.assertEquals(monthlyResidencePayment, 1200);
    System.assertEquals(street, '123 Main St');
    System.assertEquals(city, 'Denver');
    System.assertEquals(state, 'CO');
    System.assertEquals(zip, '80001');
  }

  @isTest
  static void itShouldFormatDate() {
    init();
    LendingClubApiService service = new LendingClubApiService(controller);
    String result = service.formatDate();
    String expected = String.valueof(account.Date_of_Birth__c.year()) + '-'
                    + String.valueof(account.Date_of_Birth__c.month()) + '-'
                    + String.valueof(account.Date_of_Birth__c.day());

    System.assertEquals(expected, result);
  }

  @isTest
  static void itShouldSaveLendingClubResponse() {
    HttpResponse response;
    String successfulResponseBody = successfulResponseBody();

    init();
    controller.ssn = '123456789';

    Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockLendingClubHttpResponseGenerator(successfulResponseBody));
      LendingClubApiService service = new LendingClubApiService(controller);
      response = service.submitLendingClubInquiry();
      service.saveLendingClubResponse(response);
    Test.stopTest();

    Integer expected = [SELECT Count()
                        FROM Lending_App_Offer__c
                      ];

    System.assertEquals(5, expected);
  }

  private static String successfulResponseBody() {
    return '{"requestedAmount":10000.0,"offers":[{"loanApplicationResponse":"APPROVED","product":"Extended Plan","isCounterOffer":false,"offerItems":[{"id":9000001,"url":"https://www.lendingclub.com/patientsolutions/app/welcome?offerId=TOKEN1TOKEN1","amount":10000.0,"intRate":"0.0399","promotionalPeriod":0,"term":24,"monthlyPayment":434.92},{"id":9000002,"url":"https://www.lendingclub.com/patientsolutions/app/welcome?offerId=TOKEN2TOKEN2","amount":10000.0,"intRate":"0.0599","promotionalPeriod":0,"term":36,"monthlyPayment":304.92},{"id":9000003,"url":"https://www.lendingclub.com/patientsolutions/app/welcome?offerId=TOKEN3TOKEN3","amount":10000.0,"intRate":"0.0699","promotionalPeriod":0,"term":48,"monthlyPayment":240.1}]},{"loanApplicationResponse":"APPROVED","product":"True No-Interest Plans for 6 or 12 months","legalText":{"standardAPR":"No Interest for 6, 12, 18 or 24 months, after that 26.99% standard APR. Interest will be charged to your account at the standard APR of 26.99% from the end of the promotional period on the remaining balance if the purchase balance is not paid in full within the promotional period. Minimum monthly payments are required for this plan during the promotional period. Required minimum purchase of $499 for the 6-month plan; $999 for the 12-month plan; $1,499 for the 18-month plan; $2,499 for the 24-month plan. Lending Club Patient Solutions credit accounts are offered by Comenity Capital Bank which determines qualifications for credit and promotion eligibility. Minimum interest charge is $1.00 per credit plan. Standard APR of 26.99%.","sampleEqualMonthlyPayment":"The True No-Interest Plan Equal Monthly Payments shown are representative examples that reflect the monthly payment required to pay off the balance within the promotional period, and will not be equal to your minimum payment. If you pay the representative equal payment you should pay off the plan within the promotional period. The minimum payment due assumes there are no other balances on your account. Purchase must be made using your Lending Club Patient Solutions credit account and is subject to credit approval. The actual minimum payment due will be calculated as the greater of (a) $5; or (b) 4% of the New Balance shown on your statement (rounded to the nearest $1). At no time will your minimum payment due be less than $27. The estimated monthly payment was calculated using the following assumptions: payments are made each period; no debt cancellation or suspension agreement applies to the Account; no taxes or ancillary charges are or will be added to the Account; goods and/or services are purchased on a single date; and you are not currently and will not become delinquent on the Account. Equal Monthly Payments are not required, but are recommended to lead to full payoff during the promotional period."},"isCounterOffer":false,"offerItems":[{"id":9000004,"url":"https://www.lendingclub.com/patientsolutions/app/welcome?offerId=TOKEN4TOKEN4","amount":10000.0,"intRate":"0","promotionalPeriod":6,"term":0,"monthlyPayment":416.67},{"id":9000005,"url":"https://www.lendingclub.com/patientsolutions/app/welcome?offerId=TOKEN5TOKEN5","amount":10000.0,"intRate":"0","promotionalPeriod":12,"term":0,"monthlyPayment":833.33}]}]}';
  }
}