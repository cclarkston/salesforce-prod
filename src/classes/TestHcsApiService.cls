@isTest
private class TestHcsApiService {

  @testSetup static void setup() {
    Id userId = UserInfo.getUserId();

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


  static testMethod void testSendHcsAuthorizationRequest() {
		Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();

    HcsApiService hcsApiService = new HcsApiService(controller, patient.Center__r.Name);

		String responseBody = '{"access_token":"123_test_access_token"}';

		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHcsHttpResponseGenerator(responseBody));
			String response = hcsApiService.sendHcsAuthorizationRequest();
		Test.stopTest();

		System.assertEquals(responseBody, response);
	}

	static testMethod void testSetHcsAuthorizationInfo() {
		Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();

    HcsApiService hcsApiService = new HcsApiService(controller, patient.Center__r.Name);

		String responseBody = '{"access_token":"123_test_access_token"}';

		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHcsHttpResponseGenerator(responseBody));
			String response = hcsApiService.sendHcsAuthorizationRequest();
			String token = hcsApiService.setHcsAuthorizationInfo(response);
		Test.stopTest();

		System.assertEquals(token, '123_test_access_token');
	}

	/*static testMethod void testBuildHcsRequest() {
		Date issuanceDate = Date.today() - 30;
		Date expirationDate = Date.today() + 30;

		Account patient = [SELECT Id, FirstName, LastName, BillingStreet, BillingCity,
															BillingCountry, BillingPostalCode, Phone, PersonEmail, BillingState,
															Date_of_Birth__c, Center__c, Temp_Password__c, PersonMobilePhone,
                              Center__r.Name
											 FROM Account LIMIT 1];

		Lending_App_Application__c application = new Lending_App_Application__c(
												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
												Loan_Amount__c = 25000, Id_Number__c = '1234567',
												Id_State__c = 'Colorado', Id_Issuance_Date__c = issuanceDate,
												Id_Expiration_Date__c = expirationDate,
												Employment_Status__c = 'Employed', Gross_Yearly_Individual_Income__c = 50000,
                        Home_State__c = 'Colorado');

		insert application;

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();

    HcsApiService hcsApiService = new HcsApiService(controller, patient.Center__r.Name);

		controller.patient.PersonMobilePhone = '1234567890';
		controller.ssn = '666779999';
		String request = hcsApiService.buildHcsRequest();

		HcsJsonTestRequest objectNotationRequest = HcsJsonTestRequest.parse(request);
		Decimal loanAmount = objectNotationRequest.AppliedAmount;
		String firstName = objectNotationRequest.Applicant.FirstName;
		String lastName = objectNotationRequest.Applicant.LastName;
		String street = objectNotationRequest.Applicant.Address.StreetLine1;
		String city = objectNotationRequest.Applicant.Address.City;
		String state = objectNotationRequest.Applicant.Address.State;
		String zipcode = objectNotationRequest.Applicant.Address.ZipCode;
		String country = objectNotationRequest.Applicant.Address.Country;
		String idNumber = objectNotationRequest.Applicant.DocumentIdentification.IdentificationNumber;
		String idState = objectNotationRequest.Applicant.DocumentIdentification.IdentificationStateIssuance;
		Date idIssuance = Date.parse(objectNotationRequest.Applicant.DocumentIdentification.IdentificationIssuanceDate);
		Date idExpiration = Date.parse(objectNotationRequest.Applicant.DocumentIdentification.IdentificationExpirationDate);
		String email = objectNotationRequest.Applicant.Email;
		Date dob = Date.parse(objectNotationRequest.Applicant.Dob);
		String phone = objectNotationRequest.Applicant.PhoneNumber;
		Decimal income = objectNotationRequest.EmploymentInfo.GrossIncome;

		System.assertEquals(loanAmount, application.Loan_Amount__c);
		System.assertEquals(firstName, patient.FirstName);
		System.assertEquals(lastName, patient.LastName);
		System.assertEquals(street, patient.BillingStreet);
		System.assertEquals(city, patient.BillingCity);
		System.assertEquals(zipcode, patient.BillingPostalCode);
		System.assertEquals(country, patient.BillingCountry);
		System.assertEquals(idNumber, application.Id_Number__c);
		System.assertEquals(idIssuance, application.Id_Issuance_Date__c);
		System.assertEquals(idExpiration, application.Id_Expiration_Date__c);
		System.assertEquals(email, patient.PersonEmail);
		System.assertEquals(dob, patient.Date_of_Birth__c);
		System.assertEquals(phone, patient.Phone);
		System.assertEquals(income, application.Gross_Yearly_Individual_Income__c);
	}*/

	/*static testMethod void testSendHcsRequest() {
		Date issuanceDate = Date.today() - 30;
		Date expirationDate = Date.today() + 30;

		Account patient = [SELECT Id, LastName, Temp_Password__c, Center__r.Name
											 FROM Account LIMIT 1];

		Lending_App_Application__c application = new Lending_App_Application__c(
												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
												Loan_Amount__c = 25000, Id_Number__c = '1234567',
												Id_State__c = 'Colorado', Id_Issuance_Date__c = issuanceDate,
												Id_Expiration_Date__c = expirationDate,
												Employment_Status__c = 'Employed', Gross_Yearly_Individual_Income__c = 50000,
                        Home_State__c = 'Colorado');

		insert application;

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.bypassLoginPage();
		controller.ssn = '666779999';

    HcsApiService hcsApiService = new HcsApiService(controller, patient.Center__r.Name);

		String token = '123_test_access_token';
		String body = completeJsonResponse();

		Test.startTest();
			String request = hcsApiService.buildHcsRequest();

			Test.setMock(HttpCalloutMock.class, new MockHcsHttpResponseGenerator(body));
			HttpResponse response = hcsApiService.sendHcsRequest(token, request);
		Test.stopTest();

		String expected = response.getBody();
		Integer statusCode = response.getStatusCode();
		String status = response.getStatus();

		System.assertEquals(body, expected);
		System.assertEquals(200, statusCode);
		System.assertEquals('OK', status);
	}*/

	/*static testMethod void testSendHcsRequestFails() {
		Date issuanceDate = Date.today() - 30;
		Date expirationDate = Date.today() + 30;

		Account patient = [SELECT Id, FirstName, LastName, BillingStreet, BillingCity,
															BillingCountry, BillingPostalCode, Phone, PersonEmail,
															Date_of_Birth__c, Center__c, Temp_Password__c,
                              Center__r.Name
											 FROM Account LIMIT 1];

		Lending_App_Application__c application = new Lending_App_Application__c(
												Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
												Loan_Amount__c = 25000, Id_Number__c = '1234567',
												Id_State__c = 'Colorado', Id_Issuance_Date__c = issuanceDate,
												Id_Expiration_Date__c = expirationDate,
												Employment_Status__c = 'Employed', Gross_Yearly_Individual_Income__c = 50000,
                        Home_State__c = 'Colorado');

		insert application;

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();

    HcsApiService hcsApiService = new HcsApiService(controller, patient.Center__r.Name);

		String token = '';
		String body = completeJsonResponse();

		Test.startTest();
			controller.ssn = '666779999';
			String request = hcsApiService.buildHcsRequest();

			Test.setMock(HttpCalloutMock.class, new MockHcsHttpResponseGenerator(body));
			HttpResponse response = hcsApiService.sendHcsRequest(token, request);
			hcsApiService.saveHcsResponse(response);
		Test.stopTest();

		String expected = response.getBody();
		Integer statusCode = response.getStatusCode();
		String status = response.getStatus();

		System.assertEquals(400, statusCode);
		System.assertEquals('Bad Request', status);
	}*/

  // static testMethod void testSaveApplicationResponseAndGetInquiryOffers() {
	// 	Date issuanceDate = Date.today() - 30;
	// 	Date expirationDate = Date.today() + 30;
  //
	// 	Account patient = [SELECT Id, FirstName, LastName, BillingStreet, BillingCity,
	// 														BillingCountry, BillingPostalCode, Phone, PersonEmail,
	// 														Date_of_Birth__c, Center__c, Temp_Password__c
	// 										 FROM Account LIMIT 1];
  //
	// 	Lending_App_Application__c application = new Lending_App_Application__c(
	// 											Account__c = patient.Id, Id_Type__c = 'Driver\'s License',
	// 											Loan_Amount__c = 25000, Id_Number__c = '1234567',
	// 											Id_State__c = 'Atlanta', Id_Issuance_Date__c = issuanceDate,
	// 											Id_Expiration_Date__c = expirationDate,
	// 											Employment_Status__c = 'Employed', Gross_Yearly_Individual_Income__c = 50000);
  //
	// 	insert application;
  //
	// 	CtrlLendingApp controller = new CtrlLendingApp();
	// 	controller.loginLastName = patient.LastName;
	// 	controller.loginPassword = patient.Temp_Password__c;
	// 	controller.validateLogin();
  //
	// 	String token = '123_test_access_token';
	// 	String body = completeJsonResponse();
  //
	// 	Test.startTest();
	// 		controller.ssn = '666779999';
	// 		String request = controller.buildHcsRequest();
  //
	// 		Test.setMock(HttpCalloutMock.class, new MockHcsHttpResponseGenerator(body));
	// 		HttpResponse response = controller.sendHcsRequest(token, request);
	// 		controller.saveHcsResponse(response);
	// 	Test.stopTest();
  //
	// 	Lending_App_Offer__c[] offers = [SELECT Id, Term__c, APR__c, Min_Line__c,
	// 		Max_Line__c
	// 		FROM Lending_App_Offer__c
	// 		WHERE Account__c = :patient.Id];
  //
	// 	Lending_App_Offer__c[] listOfOffers = controller.getInquiryOffers();
  //
	// 	Decimal term = offers[0].Term__c;
	// 	Decimal APR = offers[0].APR__c;
	// 	Decimal minAmount = offers[0].Min_Line__c;
	// 	Decimal maxAmount = offers[0].Max_Line__c;
	// 	System.assertEquals(60, term);
	// 	System.assertEquals(21.99, APR);
	// 	System.assertEquals(6000, minAmount);
	// 	System.assertEquals(7500, maxAmount);
	// 	System.assertEquals(21.99, listOfOffers[0].APR__c);
	// }
  //
	// static testMethod void testHcsDisclosures() {
	// 	Account patient = [SELECT Id, LastName, Temp_Password__c
	// 										 FROM Account LIMIT 1];
	// 	CtrlLendingApp controller = new CtrlLendingApp();
	// 	controller.loginLastName = patient.LastName;
	// 	controller.loginPassword = patient.Temp_Password__c;
	// 	controller.validateLogin();
	// 	controller.page = 'main';
  //
	// 	controller.ccPrivacyPolicy();
  //
	// 	System.assertEquals(controller.page, 'privacy-policy');
	// }
  //
  // // formatted json response
  //
  static String completeJsonResponse() {
    return
      '{"Result":{"LoanApplicationTransaction":"TRN000015805","ApplicationStatus":'+
      '{"Id":"APS001","Name":"Approved"},"ProductOffers":[{"ProductCode":"PI0060",'+
      '"ProductName":"60 Month Installment Loan","ProductType":{"Id":"2","Name":'+
      '"Regular"},"PromoTerm":0,"Term":60,"MinLine":6000.0000,"MaxLine":7500.0000,'+
      '"PromoAPR":null,"APR":21.9900},{"ProductCode":"PI0048","ProductName":"48'+
      ' Month Installment Loan","ProductType":{"Id":"2","Name":"Regular"},'+
      '"PromoTerm":0,"Term":48,"MinLine":4000.0000,"MaxLine":7500.0000,"PromoAPR"'+
      ':null,"APR":21.9900},{"ProductCode":"PI0036","ProductName":"36 Month '+
      'Installment Loan","ProductType":{"Id":"2","Name":"Regular"},"PromoTerm":'+
      '0,"Term":36,"MinLine":3000.0000,"MaxLine":7500.0000,"PromoAPR":null,"APR":'+
      '21.9900},{"ProductCode":"PI0024","ProductName":"24 Month Installment Loan",'+
      '"ProductType":{"Id":"2","Name":"Regular"},"PromoTerm":0,"Term":24,"MinLine":'+
      '2000.0000,"MaxLine":7500.0000,"PromoAPR":null,"APR":21.9900},{"ProductCode":'+
      '"OP1224","ProductName":"12 month SAC / 24 month term","ProductType":{"Id":"2",'+
      '"Name":"Promo"},"PromoTerm":12,"Term":24,"MinLine":2000.0000,"MaxLine":7500.0000,'+
      '"PromoAPR":null,"APR":23.9900},{"ProductCode":"PI0012","ProductName":"12 Month'+
      ' Installment Loan","ProductType":{"Id":"2","Name":"Regular"},"PromoTerm":0,'+
      '"Term":12,"MinLine":750.0000,"MaxLine":7500.0000,"PromoAPR":null,"APR":21.9900}],'+
      '"LoanApplicationUrl":"https://stage-tng.hcsloans.com/Consumer/Continue/5Xq17yBrLL7krdL6nxaV"},'+
      '"Messages":{}}';
  }
}