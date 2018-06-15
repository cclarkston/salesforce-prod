// tested by TestCtrlLendingApp
public without sharing class CtrlLendingApp {
	public Boolean sandbox =
							Test.isRunningTest() ||
							[SELECT IsSandbox
							 FROM Organization
							 LIMIT 1][0].IsSandbox;

	@TestVisible
  private String userProfileName {get; set;}
  public VirtualPatient virtualPatient {get; set;}
  public Boolean publicUser {get; private set;}
  private Account[] patientData {get; set;}
	public String page {get; set;}
	public String header {get; set;}
	public String terms {get; private set;}
	public Account patient {get; set;}
	public Lending_App_Application__c application {get; set;}
	public Lending_App_Offer__c offer {get; set;}
	public String ssn {get; set;}
	public String ssnReentry {get; set;}
	public Lending_App_Offer__c[] offers {get; set;}
	public Boolean acceptTerms1 {get; set;}
	public Boolean acceptTerms2 {get; set;}
	public Boolean acceptTerms3 {get; set;}
	public Boolean acceptTerms4 {get; set;}
	public Boolean acceptTerms5 {get; set;}
  public Boolean lendingClubDeclined {get; set;}
  public Boolean proceedFinanceDeclined {get; set;}
	public Boolean renderErrors {get; set;}
	public String[] errorMessages {get; set;}
	public String sortOffersBy {get; set;}
	public String loginLastName {get; set;}
	public String loginPassword {get; set;}
	public Id patientId {get; private set;}
	private String currentPage {get; set;}
	private String currentHeader {get; set;}
	public Integer declinedOffers {get; set;}
  public String loanApplicationUrl {get; set;}
  public String lendingClubClientId {get; set;}
  public Boolean hasStandardOffers {get; set;}
  public Boolean hasPromotionalOffers {get; set;}
  public Boolean noEmailAddress {get; set;}
  public Boolean generateEmailAddress {get; set;}
  public Boolean signed {get; private set;}

  public Map<String, String> centerOfficeId = new Map<String, String>{};
  public Map<String, String> documentIdType = new Map<String, String>
                              {'Driver\'s License' => '01', 'State ID' => '02',
                               'US Passport' => '03', 'Military ID' => '04'};
  public Map<String, String> employmentStatusId = new Map<String, String>
                              {'Employed' => '01', 'Retired' => '02',
                               'Self Employed' => '03', 'Unemployed' => '04'};

 	public CtrlLendingApp() {
    virtualPatient = new VirtualPatient();
    errorMessages = new String[]{};
    hasStandardOffers = false;
    hasPromotionalOffers = false;
    lendingClubDeclined = false;
    proceedFinanceDeclined = false;
    noEmailAddress = false;
    generateEmailAddress = false;
    userProfileName = fetchUserProfileName();
    validateUser(userProfileName);
	}

  // VIRTUAL PATIENT OBJECT //

  // Salesforce Sites limits access to database objects
  // This custom object holds the patient data so that updates can be made
  // from the app
	public class VirtualPatient {
		public String FirstName {get; set;}
		public String LastName {get; set;}
		public String BillingStreet {get; set;}
		public String BillingCity {get; set;}
		public String BillingState {get; set;}
		public String BillingPostalCode {get; set;}
		public String Phone {get; set;}
		public String PersonMobilePhone {get; set;}
		public String PersonEmail {get; set;}
		public Date Date_of_Birth {get; set;}
		public Date Prostho_Exam_Date {get; set;}
		public String Center_Name {get; set;}
		public String Temp_Password {get; set;}
	}

  // VERIFICATION, VALIDATION AND PAGE SETUP WITH PATIENT DATA //

  // determines if the user is accessing the app through Saleseforce or the
  // Saleforce Site URL
  @TestVisible
  private String fetchUserProfileName() {
    Id profileId = UserInfo.getProfileId();
    String userProfileName = [SELECT Name
                              FROM Profile
                              WHERE Id = :profileId
                            ][0].Name;

    return userProfileName;
  }

  private void validateUser(String userProfileName) {
    if(userProfileName == 'Lending App Profile' ||
       userProfileName == 'PreQ Profile') {
      header = 'PreQ Login';
      page = 'login';
    } else {
      bypassLoginPage();
    }
  }

  @TestVisible
  private void checkForExistingOffers() {
    Integer standardOffers = [SELECT Count()
                              FROM Lending_App_Offer__c
                              WHERE Account__c = :patientId
                              AND (Promotional_Period__c = 0
                              OR Promotional_Period__c = null)
                             ];
    Integer promotionalOffers = [SELECT Count()
                                 FROM Lending_App_Offer__c
                                 WHERE Account__c = :patientId
                                 AND Promotional_Period__c != 0
                               ];

    if(standardOffers > 0) {
      hasStandardOffers = true;
    }
    if(promotionalOffers > 0) {
      hasPromotionalOffers = true;
    }
  }

  @TestVisible
  private void bypassLoginPage() {
    String byAccountId = 'WHERE Id = :accountId';
    patientData = fetchPatient(byAccountId);
    publicUser = false;
    if(patientData.size() > 0) {
      setUpPatient(patientData[0]);
      goToMainPage();
    } else {
      addMessage('There is no patient data.');
    }
  }

	public void validateLogin() {
		verifyCredentials();

		if(!ApexPages.hasMessages()) {
			if (loginValid()) {
				redirectPatient();
			} else {
				addMessage(invalidLoginMessage());
			}
		}
	}

  @TestVisible
	private void verifyCredentials() {
    String byPassword = 'WHERE Temp_Password__c = :loginPassword';
    Account[] patientData = fetchPatient(byPassword);

    if (loginPassword != '' && patientData.size() != 0) {
      publicUser = true;
      setUpPatient(patientData[0]);
		} else {
			addMessage(invalidLoginMessage());
		}
	}

	private Boolean loginValid() {
		return loginLastName.toLowerCase() == patient.LastName.toLowerCase() &&
					 loginPassword.toLowerCase() == patient.Temp_Password__c.toLowerCase();
	}

  private void redirectPatient() {
    checkForExistingOffers();

    if(hasStandardOffers == true || hasPromotionalOffers == true) {
      goToOffersPage();
    } else {
      goToMainPage();
    }
  }

  private Account[] fetchPatient(String whereParam) {
    Id accountId = Apexpages.currentPage().getParameters().get('accountId');

    String queryParams = 'SELECT Id, FirstName, LastName, BillingStreet, '
                       + 'BillingCity, BillingState, BillingCountry, '
                       + 'BillingPostalCode, Phone, PersonMobilePhone, '
                       + 'PersonEmail, Date_of_Birth__c, Prostho_Exam_Date__c, '
                       + 'Center__r.Name, Center__c, Temp_Password__c, isPersonAccount '
                       + 'FROM Account '
                       + whereParam;

		Account[] patientData = Database.query(queryParams);

    return patientData;
	}

  private void setUpPatient(Account patientData) {
    patient = patientData;
    patientId = patient.Id;
    getOrCreateApplicationForPatient();
    populateVirtualPatient();
  }

	private void getOrCreateApplicationForPatient() {
		Lending_App_Application__c[] existingApplication = [SELECT Id, Loan_Amount__c,
																													Id_Type__c, Id_Number__c,
																													Id_State__c, Id_Issuance_Date__c,
																													Home_State__c, Id_Expiration_Date__c,
																													Gross_Yearly_Individual_Income__c,
                                                          Gross_Yearly_Household_Income__c,
                                                          Employment_Status__c,
                                                          Monthly_Residence_Payment__c,
                                                          Residence_Type__c
																											  FROM Lending_App_Application__c
																										    WHERE Account__c = :patientId];

		if (existingApplication.size() == 0) {
			application = new Lending_App_Application__c(Account__c = patientId);
		} else {
			application = existingApplication[0];
		}
	}

  // UPDATE PATIENT DATA IN DATABASE VIA INDIRECT OBJECT //

	public void populateVirtualPatient() {
		virtualPatient.FirstName = patient.FirstName;
		virtualPatient.LastName = patient.LastName;
		virtualPatient.BillingStreet = patient.BillingStreet;
		virtualPatient.BillingCity = patient.BillingCity;
		virtualPatient.BillingPostalCode = patient.BillingPostalCode;
		virtualPatient.Phone = patient.Phone;
		virtualPatient.PersonMobilePhone = patient.PersonMobilePhone;
		virtualPatient.PersonEmail = patient.PersonEmail;
		virtualPatient.Date_of_Birth = patient.Date_of_Birth__c;
		virtualPatient.Prostho_Exam_Date = patient.Prostho_Exam_Date__c;
		virtualPatient.Center_Name = patient.Center__r.Name;
		virtualPatient.Temp_Password = patient.Temp_Password__c;
	}

  private void goToMainPage() {
    header = 'Inquiry Information';
    page = 'main';
  }

	private String invalidLoginMessage() {
		String message =
			'Invalid login information. Please enter correct Last Name and Password. '+
			'If you still can\'t login ClearChoice can verify your information and '+
			'even generate a new password for you.';
		return message;
	}

	public void saveApplicationInfo() {
    // NOTE: disable validations in development
    new LendingAppValidations(this).run();

    if(noEmailAddress == true) {
      generateEmailAddress();
    }

		if (!ApexPages.hasMessages()) {
			upsertApplication();
			updatePatientWithVirtualPatient();
      checkForExistingSignature();
		}
	}

	@TestVisible
	private void upsertApplication() {
		try {
			upsert application;
		} catch(DmlException error) {
			addMessage(updateErrorMessage() + ' ' + error );
		}
	}

	@TestVisible
	private void updatePatientWithVirtualPatient() {
		patient.FirstName = virtualPatient.FirstName;
		patient.LastName = virtualPatient.LastName;
		patient.BillingStreet = virtualPatient.BillingStreet;
		patient.BillingCity = virtualPatient.BillingCity;
		patient.BillingState = application.Home_State__c;
		patient.BillingPostalCode = virtualPatient.BillingPostalCode.substring(0, 5);
		patient.Phone = virtualPatient.Phone;
		patient.PersonMobilePhone = virtualPatient.PersonMobilePhone;
    patient.PersonEmail = generateEmailAddress == false ? virtualPatient.PersonEmail : null;
		patient.Date_of_Birth__c = virtualPatient.Date_of_Birth;
		patient.Prostho_Exam_Date__c = virtualPatient.Prostho_Exam_Date;
		patient.Center__r.Name = virtualPatient.Center_Name;
		patient.Temp_Password__c = virtualPatient.Temp_Password;

		try {
			update patient;
      generateEmailAddress = false;
      header = 'Terms & Conditions';
      page = 'confirmation';
		} catch(DmlException error) {
			addMessage(updateErrorMessage() + ' ' + error );
      goToMainPage();
		}
	}

	private static String updateErrorMessage() {
		return 'There was a problem updating the patient information. '+
		'Contact ClearChoice for more information.';
	}

  @TestVisible
  private void generateEmailAddress() {
    generateEmailAddress = true;
    String emailAddress = '';
    Long randomLong = Crypto.getRandomLong();

    emailAddress += virtualPatient.FirstName;
    emailAddress += virtualPatient.LastName;
    emailAddress += randomLong;
    emailAddress += '@';
    emailAddress += 'email.com';
    virtualPatient.PersonEmail = emailAddress;
  }

	public void addMessage(String message) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
	}

  // ENSURES CHECKBOXES ON CONFIRMATION PAGE HAVE BEEN CHECKED BEFORE PROCEEDING

	public void acceptTermsAndConditions () {
		if (!termsAccepted()) {
			addMessage('Please check each checkbox to agree to terms ' +
                 'and conditions.');
		} else {
      checkForExistingOffers();
			submitInquiryApplication();
		}
	}

	public Boolean ssnValid() {
		String cleanSsn = sanitizeSsn(ssn);
		return cleanSsn.length() == 9 && cleanSsn.isNumeric();
	}

	public Boolean ssnMatching() {
		String cleanSsn = sanitizeSsn(ssn);
		String cleanSsnReentry = sanitizeSsn(ssnReentry);
		return cleanSsn == cleanSsnReentry;
	}

	private String sanitizeSsn(String cleanSsn) {
		return cleanSsn.replaceAll('[^0-9]', '');
	}

	private Boolean termsAccepted() {
    // NOTE: disable terms validation in development
    return acceptTerms1 == true &&
           acceptTerms2 == true &&
           acceptTerms3 == true &&
           acceptTerms4 == true &&
           acceptTerms5 == true;
    // NOTE: disable return statement in production
    // return true;
 	}

  // API REQUEST RESPONSE RUNNER
  // this method is a switch that contains groups of methods that can be
  // commented out/deleted to disable specific lenders
  public void submitInquiryApplication () {
		// CareCreditAPIService careCreditService = new CareCreditAPIService(this).submitCareCreditInquiry();

    LendingClubApiService lendingClubApiService = new LendingClubApiService(this);
    HttpResponse lendingClubResponse = lendingClubApiService.submitLendingClubInquiry();

    // ProceedFinanceApiService proceedFinanceApiService = new ProceedFinanceApiService(this);
    // HttpResponse proceedFinanceResponse = proceedFinanceApiService.submitProceedFinanceInquiry();

    // // if(careCreditResponse != null) {
    // // careCreditService.handleCareCreditResponse(careCreditResponse);
    // // }

    if(lendingClubResponse != null) {
      lendingClubApiService.saveLendingClubResponse(lendingClubResponse);
    }

    // if(proceedFinanceResponse != null) {
    //   proceedFinanceApiService.saveProceedFinanceResponse(proceedFinanceResponse);
    // }

    if(ApexPages.hasMessages()) {
      goToMainPage();
    } else {
      goToOffersPage();
    }
  }

  public String verifyMobileNumber() {
    if (patient.PersonMobilePhone == null || patient.PersonMobilePhone == '') {
      return cleanPhone(patient.Phone);
    } else
    return cleanPhone(patient.PersonMobilePhone);
  }

  public String cleanPhone(String phoneNumber) {
    String cleanPhone = phoneNumber.replaceAll('[^0-9]', '');
    return cleanPhone;
  }

	public void addErrorMessages(Map<String, Object> messages, Set<String> keys) {
		for(String key : keys) {
			String message = String.valueOf(messages.get(key));
			errorMessages.add(message);
			page = 'main';
			renderErrors = true;
		}
	}

  // GET ALL OFFERS FOR A PATIENT TO DISPLAY ON OFFERS PAGE
  // Offers can be sorted

	public Lending_App_Offer__c[] getStandardOffers() {
		if (sortOffersBy != '' && sortOffersBy != null) {
			String query = 'SELECT Account__c, APR__c, Lender__c, ' +
										 'Max_Line__c, Term__c, Monthly_Payment__c, ' +
                     'Promotional_Period__c, ' +
										 'Loan_Application_Url__c FROM Lending_App_Offer__c ' +
										 'WHERE Account__c = :patientId ' +
                     'AND (Promotional_Period__c = 0 OR Promotional_Period__c = null) ' +
                     'ORDER BY ';

			query += sortOffersBy;
			offers = Database.query(query);
		} else {
			String query = 'SELECT Account__c, APR__c, Lender__C, Monthly_Payment__c, ' +
			 							 'Max_Line__c, Term__c, Loan_Application_Url__c, ' +
                     'Promotional_Period__c ' +
										 'FROM Lending_App_Offer__c WHERE Account__c = :patientId ' +
                     'AND (Promotional_Period__c = 0 OR Promotional_Period__c = null) ' +
										 'ORDER BY Max_Line__c DESC';
			offers = Database.query(query);
		}
    System.debug('crash: ' + offers);
		return offers;
	}

	public Lending_App_Offer__c[] getPromotionalOffers() {
		if (sortOffersBy != '' && sortOffersBy != null) {
			String query = 'SELECT Account__c, APR__c, Lender__C, ' +
										 'Max_Line__c, Term__c, Monthly_Payment__c, ' +
                     'Promotional_Period__c, ' +
										 'Loan_Application_Url__c FROM Lending_App_Offer__c ' +
										 'WHERE Account__c = :patientId ' +
                     'AND (Promotional_Period__c != null AND Promotional_Period__c != 0) ' +
                     'ORDER BY ';

			query += sortOffersBy;
			offers = Database.query(query);
		} else {
			String query = 'SELECT Account__c, APR__c, Lender__C, Monthly_Payment__c, ' +
			 							 'Max_Line__c, Term__c, Loan_Application_Url__c, ' +
                     'Promotional_Period__c ' +
										 'FROM Lending_App_Offer__c WHERE Account__c = :patientId ' +
                     'AND (Promotional_Period__c != null AND Promotional_Period__c != 0) ' +
										 'ORDER BY Max_Line__c DESC';
			offers = Database.query(query);
		}
    System.debug('crash: ' + offers);
		return offers;
	}

  // SETUP/NAVIGATE TO PAGES

  public void goToOffersPage() {
    System.debug('crash: ' + 'going to offers page');
    System.debug('crash: ' + patient.FirstName);
    System.debug('crash: ' + patient.LastName);
    header = 'Pre-qualification Inquiry Offers*';
    page = 'offers';
  }

	public void ccPrivacyPolicy() {
		if (currentPage()) {
      currentHeader = header;
			currentPage = page;
			page = 'privacy-policy';
      header = 'PreQ Privacy Policy';
		} else {
			page = currentPage;
      header = currentHeader;
		}
	}

	private Boolean currentPage() {
		return (page == 'main' || page == 'confirmation' || page == 'offers');
	}

  public void selectOffer() {
    header = 'Leaving PreQ';
    page = 'leaving-clearchoice';
    loanApplicationUrl = ApexPages.currentPage().getParameters().get('loanApplicationUrl');
  }

  public void saveSignature() {
    String signatureBody = Apexpages.currentPage().getParameters().get('strDataURI');

    deleteExistingSignatures();
    saveNewSignature(signatureBody);
  }

  private void deleteExistingSignatures() {
    Attachment[] existingSignatures = fetchSignature();

    if(existingSignatures.size() > 0) {
      delete existingSignatures;
    }
  }

  private Attachment[] fetchSignature() {
    Attachment[] signatures = [SELECT Id
                               FROM Attachment
                               WHERE parentId = :application.Id
                               AND name = 'lending-app-signature.png'];
                               System.debug('signatures: ' + signatures);

    return signatures;
  }

  private void checkForExistingSignature() {
    System.debug('crash: ' + fetchSignature());
    System.debug('crash: ' + fetchSignature().isEmpty());
    signed = !fetchSignature().isEmpty() ? true : false;
  }

  @TestVisible
  private void saveNewSignature(String signatureBody) {
    try {
      Attachment attachment = new Attachment(
                                    ParentId = application.Id,
                                    Body = EncodingUtil.base64Decode(signatureBody),
                                    ContentType = 'image/png',
                                    Name = 'lending-app-signature.png');

      insert attachment;
      signed = true;
    }  catch (Exception error) {
      addMessage('There was an issue saving the signature: ' + error);
    }
  }

  public void resetSignature() {
    signed = false;
  }

  public String getsignatureImage() {
    try {
  	  Attachment attachment = [SELECT body
                               FROM Attachment
                               WHERE parentId = :application.id
                               AND name = 'lending-app-signature.png'
                               LIMIT 1
                             ];

  	  return EncodingUtil.base64encode(attachment.body);
  	} catch (Exception e) {
  	  addMessage('There was an issue retrieving the signature');
      return null;
  	}
  }

  public String getsignatureDate() {
  	try {
      Attachment signature = [SELECT Id
                              FROM Attachment
                              WHERE parentId = :application.Id
                              AND name = 'lending-app-signature.png'];

  	  return signature.createddate.format('MM/dd/YYYY');
  	} catch (Exception e) {
  	  return System.now().format('MM/dd/YYYY');
  	}
  }

}

// ALL FILES
//CtrlLendingApp
  // TestCtrlLendingApp
  // LendingAppValidations
// LendingClubApiService
  // TestLendingClubAPIService
  // MockLendingClubHttpResponseGenerator
  // LendingClubJsonTestRequest
  // LendingClubJsonResponse

// CareCreditAPIService
  // TestCareCreditApiService
// ProceedFinanaceAPIService
  // TestProceedFinanceApiService
  // MockProceedFinanceHttpResponseGenerator
// TempPasswordGenerator
  // TestTempPasswordGenerator
// LendingAppValidations

// PAGES //
// lending_app

// ASSETS
  // lending_app.resource/css/main.css
  // lending_app.resource/img
  // lending_app.resource/javascript/main.css