@isTest
private class TestCtrlLendingApp {

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
    Lending_App_Offer__c standardOffer  = new Lending_App_Offer__c(Account__c = patient.Id, Promotional_Period__c = 0);
    offers.add(standardOffer);

    Lending_App_Offer__c promotionalOffer  = new Lending_App_Offer__c(Account__c = patient.Id,
                                                                      Promotional_Period__c = 60);
    offers.add(promotionalOffer);
    insert offers;
	}

	static testMethod void testFetchUserProfile() {
    Id profileId = UserInfo.getProfileId();
    String userProfileName = [SELECT Name
                              FROM Profile
                              WHERE Id = :profileId
                            ][0].Name;

    CtrlLendingApp controller = new CtrlLendingApp();
		controller.fetchUserProfileName();

		System.assertEquals(controller.userProfileName, userProfileName);
	}

	static testMethod void testInvalidPassword() {
		Boolean correctErrorMessage = false;
		String errorMessage =
		'Invalid login information. Please enter correct Last Name and Password. '+
		'If you still can\'t login ClearChoice can verify your information and '+
		'even generate a new password for you.';

		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = 'Invalid Password';

		controller.validateLogin();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());

		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == errorMessage &&
					 message.getSeverity() == ApexPages.Severity.ERROR) {
		    correctErrorMessage = true;
		   }
		}

		System.assert(correctErrorMessage);
	}

	static testMethod void testSaveApplicationInfo() {
		Date issuanceDate = Date.today() - 30;
		Date expirationDate = Date.today() + 30;

		Account patient = [SELECT Id, Name, LastName, Temp_Password__c
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

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
    controller.ssn = '999999999';
    controller.ssnReentry = '999999999';
		controller.validateLogin();

		System.assertEquals(patient.Name, 'Test User');

		controller.virtualPatient.FirstName = 'Update';
		controller.application.Home_State__c = 'Atlanta';
		controller.saveApplicationInfo();

		Account updatedPatient = [SELECT Id, Name, Temp_Password__c
														 FROM Account
														 WHERE Id = :patient.Id];

		Lending_App_Application__c updatedApplication = [SELECT Id, Gross_Yearly_Individual_Income__c
																										 FROM Lending_App_Application__c
																										 WHERE Account__c = :patient.Id];

   ApexPages.Message[] pageMessages = ApexPages.getMessages();

   for(ApexPages.Message message : pageMessages) {
     System.debug('crash: ' + message.getSummary());
   }

		System.assertEquals(updatedPatient.Id, patient.Id);
		System.assertEquals(updatedPatient.Name, 'Update User');
		System.assertEquals(updatedApplication.Gross_Yearly_Individual_Income__c, 50000);
	}

	static testMethod void testUpsertApplicationFails() {
		Boolean correctErrorMessage = false;
		String errorMessage1 = 'There was a problem updating the inquiry information. '+
												 	 'Contact ClearChoice for more information.';
    String errorMessage2 = 'Required fields are missing: [Account__c]';

		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);

		Lending_App_Application__c application = new Lending_App_Application__c(
												Account__c = patient.Id);

		insert application;

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();

		controller.application.Account__c = null;

		controller.upsertApplication();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());

		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == errorMessage1
        || message.getSummary() == errorMessage2
				&& message.getSeverity() == ApexPages.Severity.ERROR) {
		    correctErrorMessage = true;
		   }
		}

		System.assert(correctErrorMessage);
	}

	static testMethod void testUpdatePatientWithVirtualPatientFails() {
		Boolean correctErrorMessage = false;
		String errorMessage1 = 'There was a problem updating the patient information. '+
												 	 'Contact ClearChoice for more information.';
    String errorMessage2 = 'Required fields are missing: [LastName]';

		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
    controller.ssn = '999999999';
    controller.ssnReentry = '999999999';
		controller.validateLogin();

		controller.virtualPatient.LastName = null;

		controller.updatePatientWithVirtualPatient();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());

		for(ApexPages.Message message : pageMessages) {
		    if(message.getSummary() == errorMessage1
        || message.getSummary() == errorMessage2
				&& message.getSeverity() == ApexPages.Severity.ERROR) {
		    correctErrorMessage = true;
		   }
		}

		System.assert(correctErrorMessage);
	}

	static testMethod void testvalidateRequiredFieldExceptions() {
		Date issuanceDate = Date.today() + 30;
		Date expirationDate = Date.today() - 30;
    Date dateOfBirth = Date.today().addYears(10);

		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];

		Lending_App_Application__c application = new Lending_App_Application__c(
 												Account__c = patient.Id, Loan_Amount__c = 0,
											  Id_Issuance_Date__c = issuanceDate,
												Id_Expiration_Date__c = expirationDate,
												Gross_Yearly_Individual_Income__c = 0);

 		insert application;

		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
    controller.ssn = '999999999';
    controller.ssnReentry = '999999999';
		controller.validateLogin();

		controller.virtualPatient.FirstName = '';
		controller.virtualPatient.LastName = '';
		controller.virtualPatient.BillingStreet = '';
		controller.virtualPatient.BillingCity = '';
		controller.virtualPatient.BillingState = '';
		controller.virtualPatient.BillingPostalCode = '';
		controller.virtualPatient.Phone = '';
		controller.virtualPatient.PersonEmail = '';
		controller.virtualPatient.Date_of_Birth = dateOfBirth;

		new LendingAppValidations(controller).run();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(20, pageMessages.size());
	}

  static testMethod void testGenerateEmailAddress() {
    String emailAddress = 'testemail@test.com';
    Account patient = [SELECT Id, LastName, Temp_Password__c
                       FROM Account LIMIT 1];

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);

    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;

    controller.virtualPatient.PersonEmail = emailAddress;
    System.assertEquals(controller.virtualPatient.PersonEmail, emailAddress);

    controller.generateEmailAddress();
    System.assertNotEquals(controller.virtualPatient.PersonEmail, emailAddress);

    String patientName = controller.virtualPatient.FirstName + controller.virtualPatient.LastName;
    String newEmailAddress = controller.virtualPatient.PersonEmail;
    Boolean result = newEmailAddress.contains(patientName);
    System.assert(result);
  }

	static testMethod void testIncorrectSsn() {
		Boolean correctErrorMessage = false;
		String errorMessage = 'A valid Social Security Number is a required';

		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();

		controller.ssn = '66677999';

		Boolean ssnValid = controller.ssnValid();

		System.assert(ssnValid == false);
	}

	static testMethod void testSsnNotMatching() {
		Boolean correctErrorMessage = false;
		String errorMessage = 'Social security numbers do not match. '+
							            'Please re-enter correct, matching social security numbers.';

    Date issuanceDate = Date.today() - 30;
 		Date expirationDate = Date.today() + 30;

 		Account patient = [SELECT Id, Name, LastName, Temp_Password__c
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

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);

 		CtrlLendingApp controller = new CtrlLendingApp();
 		controller.loginLastName = patient.LastName;
 		controller.loginPassword = patient.Temp_Password__c;
    controller.ssn = '999999999';
    controller.ssnReentry = '888888888';
 		controller.validateLogin();

    controller.saveApplicationInfo();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertNotEquals(0, pageMessages.size());

		for(ApexPages.Message message : pageMessages) {
				if(message.getSummary() == errorMessage
				&& message.getSeverity() == ApexPages.Severity.ERROR) {
				correctErrorMessage = true;
			 }
		}

		System.assert(correctErrorMessage);
	}

	static testMethod void testAcceptTermsandConditionsFails() {
    Boolean correctErrorMessage;
    correctErrorMessage = false;
    String errorMessage = 'Please check each checkbox to agree to terms and conditions.';

    Account patient = [SELECT Id, LastName, Temp_Password__c
                       FROM Account
                       LIMIT 1];

    PageReference lendingAppPage = Page.lending_app;
    Test.setCurrentPage(lendingAppPage);
    ApexPages.currentPage().getParameters().put('AccountId', patient.Id);
    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();

    controller.ssn = '666779999';
    controller.ssnReentry = '666779999';
    controller.acceptTerms1 = true;
    controller.acceptTerms2 = true;
    controller.acceptTerms3 = true;
    controller.acceptTerms4 = true;
    controller.virtualPatient.PersonMobilePhone = '';

    controller.acceptTermsAndConditions();

    ApexPages.Message[] pageMessages = ApexPages.getMessages();
    System.assertNotEquals(0, pageMessages.size());

    for(ApexPages.Message message : pageMessages) {
      System.debug('crash: ' + message.getSummary());
        if(message.getSummary() == errorMessage
        && message.getSeverity() == ApexPages.Severity.ERROR) {
        correctErrorMessage = true;
       }
    }

		System.assert(correctErrorMessage);
	}

  static TestMethod void testVerifyMobileNumber() {
    Account patient = [SELECT Id, LastName, Temp_Password__c, Phone, PersonMobilePhone
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();

    String phoneNumber = controller.verifyMobileNumber();
    System.assertEquals(patient.Phone, '1234567891');


    controller.patient.PersonMobilePhone = '9999999999';
    String mobileNumber = controller.verifyMobileNumber();
    System.assertEquals('9999999999', mobileNumber);
  }

  static TestMethod void testGetStandardOffers() {
    Account patient = [SELECT Id, LastName, Temp_Password__c
                       FROM Account LIMIT 1];
    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();

    Lending_App_Offer__c[] offers1 = controller.getStandardOffers();
    System.assertEquals(offers1.size(), 1);

    controller.sortOffersBy = 'Lender__c';
    Lending_App_Offer__c[] offers2 = controller.getStandardOffers();
    System.assertEquals(offers2.size(), 1);
  }

  static TestMethod void testGetPromotionalOffers() {
    Account patient = [SELECT Id, LastName, Temp_Password__c
                       FROM Account LIMIT 1];
    CtrlLendingApp controller = new CtrlLendingApp();
    controller.loginLastName = patient.LastName;
    controller.loginPassword = patient.Temp_Password__c;
    controller.validateLogin();

    Lending_App_Offer__c[] offers1 = controller.getPromotionalOffers();
    System.assertEquals(1, offers1.size());

    controller.sortOffersBy = 'Lender__c';
    Lending_App_Offer__c[] offers2 = controller.getPromotionalOffers();
    System.assertEquals(1, offers1.size());
  }

	static testMethod void testCcPrivacyPolicyPage() {
		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();
		controller.page = 'main';

		controller.ccPrivacyPolicy();

		System.assertEquals(controller.page, 'privacy-policy');
	}

	static testMethod void testCcPrivacyPolicyReset() {
		Account patient = [SELECT Id, LastName, Temp_Password__c
											 FROM Account LIMIT 1];
		CtrlLendingApp controller = new CtrlLendingApp();
		controller.loginLastName = patient.LastName;
		controller.loginPassword = patient.Temp_Password__c;
		controller.validateLogin();
		controller.page = 'main';

		controller.ccPrivacyPolicy();
		System.assertEquals(controller.page, 'privacy-policy');
		controller.ccPrivacyPolicy();
		System.assertEquals(controller.page, 'main');
	}

	// formatted json response

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