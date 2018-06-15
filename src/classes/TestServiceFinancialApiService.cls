@isTest
private class TestServiceFinancialApiService {
  static Lead lead;

  // acxiom class variables
  static Integer mock_token_status  = null;
  static Map<String, String> mock_token_headers;
  static String mock_token_body;
  static Integer mock_data_status;
  static Map<String, String> mock_data_headers;
  static String mock_data_body;
  static Acxiom.DocumentWrapper[] documents;

  // TEST SETUP
  @testSetup static void setup() {
    Lead lead = new Lead(
      FirstName = 'Test',
      LastName = 'Patient',
      Street = '123 Main St',
      City = 'Denver',
      State = 'CO',
      PostalCode = '80111',
      StrikeForce1__USAddress_Address_Status__c = 'Verified'
    );

    insert lead;

    Service_Financial__c token = new Service_Financial__c(
      Token__c = '1345678'
    );

    insert token;
  }

  static void init() {
    lead = [SELECT FirstName, LastName, Street, City,
                   State, PostalCode, Pre_Screen__c,
                   StrikeForce1__USAddress_Address_Status__c,
                   Prescreen_Street_Name__c
            FROM Lead
            LIMIT 1
          ];

    ServiceFinancialApiService.fetchLeadData(lead.Id);
  }

  // When the Lead record is updated it triggers a call to the Acxiom API
  // so there are 2 mock response generators in this test suite. One to the Service
  // Financial API and one to the Acxiom API. This is the setup for the Acxiom call.
  static void initAcxiom() {
    mock_token_status  = null;
    mock_token_headers = null;
    mock_token_body = '{"access_token":"xx123456-x12x-123x-x1xx-1xx1x12x'
                    + '1xxx","token_type":"Bearer","expires_in":3600}';
    mock_data_status  = null;
    mock_data_headers = null;
    mock_data_body = success_response_json(1);

    documents = success_response(1);
    system.assertEquals(0, [SELECT count() FROM Acxiom_Data__c]);
  }

  // Pre_Screen__c should be 'PO Box' when address contains 'PO Box'
  static TestMethod void testPoBox() {
    init();
    String responseBody = successfulResponseBody();
    Lead prescreen = [SELECT Pre_Screen__c, PostalCode
                      FROM Lead
                      LIMIT 1
                    ];

    prescreen.PostalCode = '00200';
    prescreen.Street = 'Po Box 1234';
    update prescreen;

    Test.startTest();
      ServiceFinancialApiService.prescreen(lead.Id);
    Test.stopTest();

    Lead lead = [SELECT Pre_Screen__c
                 FROM Lead
                 LIMIT 1
               ];

    System.assertEquals('PO Box', lead.Pre_Screen__c);
  }

  // test it builds the body of the request for the callout
  static TestMethod void testBuildRequestBody() {
    init();
    String sampleRequestBody = 'FirstName=Test&LastName=Patient&Address=123+Main+'
                             + 'St&City=Denver&State=CO&Zip=80111';
    ServiceFinancialApiService.lead = lead;
    String builtRequestBody = ServiceFinancialApiService.buildRequestBody();

    System.assertEquals(sampleRequestBody, builtRequestBody);
  }

  // test the build of the body of the request fails if there is a null value passed
  static TestMethod void testBuildRequestBodyFailsWithNullValues() {
    init();
    ServiceFinancialApiService.lead.PostalCode = null;
    String nullResult = ServiceFinancialApiService.buildRequestBody();
    System.assertEquals(nullResult, null);

    Integer invocations = Limits.getEmailInvocations();
    System.assertEquals(1, invocations,  ' An email should be sent');
  }

  // test sending a request to the mock response generator
  static TestMethod void testSendRequest() {
    init();
    String responseBody = successfulResponseBody();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '200');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);
    Test.stopTest();

    System.assertEquals('Ok', response.getStatus());
    System.assertEquals(200, response.getStatusCode());
    System.assertEquals(responseBody, response.getBody());
  }

  // RESPONSE PARSING TEST METHODS
  // test the application can handle the various responses
  // section includes callouts the MockHttp_Acxiom
  static TestMethod void testParseAndUpdateSuccessfulResponse() {
    init();
    initAcxiom();
    String responseBody = successfulResponseBody();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '200');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Green', updatedlead.Pre_Screen__c);
    System.assertEquals(200, response.getStatusCode());
  }

  static TestMethod void testParseAndUpdateSuccessfulResponseBlue() {
    init();
    initAcxiom();
    String responseBody = successfulResponseBodyBlue();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '200');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Blue (No Hit)', updatedlead.Pre_Screen__c);
    System.assertEquals(200, response.getStatusCode());
  }

  static TestMethod void testParseAndUpdateSuccessfulResponseWithFailureMessage() {
    init();
    initAcxiom();
    String responseBody = successfulResponseBodyWithFailureMessage();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '200');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Website Down-No Prescreen', updatedlead.Pre_Screen__c);
    System.assertEquals(200, response.getStatusCode());
  }

  static TestMethod void testParseAndUpdateUnauthorizedResponse() {
    init();
    initAcxiom();
    String responseBody = '';

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '401');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Website Down-No Prescreen', updatedLead.Pre_Screen__c);
    System.assertEquals(401, response.getStatusCode());
  }

  static TestMethod void testParseAndUpdateBadRequest() {
    init();
    initAcxiom();
    String responseBody = errorResponseBody();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '400');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Website Down-No Prescreen', updatedLead.Pre_Screen__c);
    System.assertEquals(400, response.getStatusCode());
  }

  static TestMethod void testParseAndUpdateInternalServerErrorResponse() {
    init();
    initAcxiom();
    String responseBody = errorResponseBody();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();
      requestBody = requestBody.replace('111', '500');

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Website Down-No Prescreen', updatedLead.Pre_Screen__c);
    System.assertEquals(500, response.getStatusCode());
  }

  static TestMethod void testParseUnknownErrorResponse() {
    init();
    initAcxiom();
    String responseBody = errorResponseBody();

    Test.startTest();
      String requestBody = ServiceFinancialApiService.buildRequestBody();

      Test.setMock(HttpCalloutMock.class, new MockServiceFinancialResponseGenerator(responseBody));
      HttpResponse response = ServiceFinancialApiService.sendRequest(requestBody);

      Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status,
                                                              mock_token_headers,
                                                              mock_token_body,
                                                              mock_data_status,
                                                              mock_data_headers,
                                                              mock_data_body)
                                                            );
      ServiceFinancialApiService.parseResponseWithoutMessages(response);
    Test.stopTest();

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Website Down-No Prescreen', updatedLead.Pre_Screen__c);
  }

  // EXPECTED RESPONSES
  static String successfulResponseBody() {
    String body = '{"result": "success","ColorBand": "Lime","ScriptText": "Some text", '
                + '"Comments": ["FileHit: Regular hit on file.","SSN Match: No SSN on input '
                + 'but SSN on file.", "OFAC Result:  OFAC Name Screen Clear"]}';

    return body;
  }

  static String successfulResponseBodyBlue() {
    String body = '{"result": "success","ColorBand": "Blue","ScriptText": "Some text", '
                + '"Comments": ["FileHit: Regular hit on file.","SSN Match: No SSN on input '
                + 'but SSN on file.", "OFAC Result:  OFAC Name Screen Clear"]}';

    return body;
  }

  static String successfulResponseBodyWithFailureMessage() {
    String body = '{"result": "failed","ColorBand": "Lime","ScriptText": "Some text", '
                + '"Comments": ["FileHit: Regular hit on file.","SSN Match: No SSN on input '
                + 'but SSN on file.", "OFAC Result:  OFAC Name Screen Clear"]}';

    return body;
  }

  static String errorResponseBody() {
    String body = '{"result":"failed","message":["Error message"]}';
    return body;
  }

  // ACXIOM CALLOUT METHODS
  // These methods were extracted from Test_Acxiom.cls and are part of the setup
  private static String success_response_json(Integer document_count) {
      return JSON.serialize(success_response(document_count));
  }

  private static Acxiom.DocumentWrapper[] success_response(Integer document_count) {
      Acxiom.DocumentWrapper[] document_wrappers = new Acxiom.DocumentWrapper[]{};
      for (Integer i = 0; i < document_count; i++) {
          Acxiom.DocumentWrapper wrapper = new Acxiom.DocumentWrapper();
          wrapper.code                                 = 200;
          wrapper.document                             = new Acxiom.Document();
          wrapper.document.person                      = new Acxiom.Person();
          wrapper.document.person.personicxLifestage   = completed_personicxLifestage();
          wrapper.document.person.investmentsAndAssets = completed_investmentsAndAssets();
          document_wrappers.add(wrapper);
      }

      return document_wrappers;
  }

  private static Acxiom.PersonicxLifestage completed_personicxLifestage() {
      Acxiom.PersonicxLifestage personicxLifestage = new Acxiom.PersonicxLifestage();

      personicxLifestage.lifestageCluster = '01';
      personicxLifestage.lifestageGroup   = '01Y';

      return personicxLifestage;
  }

  private static Acxiom.InvestmentsAndAssets completed_investmentsAndAssets() {
      Acxiom.InvestmentsAndAssets investmentsAndAssets = new Acxiom.InvestmentsAndAssets();

      investmentsAndAssets.acquiredAnIRA                                       = 'Likely';
      investmentsAndAssets.acquiredAny401k                                     = 'Likely';
      investmentsAndAssets.activeInvestments                                   = true;
      investmentsAndAssets.affordabilityUS                                     = 'Cushioned comfort';
      investmentsAndAssets.annuitiesAcquired                                   = 'Likely';
      investmentsAndAssets.anyInvestmentsAcquired                              = 'Likely';
      investmentsAndAssets.economicStabilityIndicator                          = 1;
      investmentsAndAssets.estimatedIncomeMax                                  = 124999;
      investmentsAndAssets.estimatedIncomeMin                                  = 15000;
      investmentsAndAssets.fullServiceInvestor                                 = 'Likely';
      investmentsAndAssets.haveA529SavingsPlan                                 = 'Likely';
      investmentsAndAssets.haveAnOnlineTradingAccount                          = 'Likely';
      investmentsAndAssets.haveAny401k                                         = 'Likely';
      investmentsAndAssets.haveAnyAnnuities                                    = 'Likely';
      investmentsAndAssets.haveAnyIRAAccount                                   = 'Likely';
      investmentsAndAssets.haveAnyPrivatelyHeldSharesOfCompaniesOrPartnerships = 'Likely';
      investmentsAndAssets.haveCorporateBondsOrDebentures                      = 'Likely';
      investmentsAndAssets.housingInvestmentPropertiesOwned                    = 1;
      investmentsAndAssets.investingInterests                                  = new String[]{'Investing/Finance', 'Money seekers', 'Personal', 'Real estate', 'Stocks/Bonds', 'Foreign'};
      investmentsAndAssets.investmentServicesConsumerSegment                   = 'Enviables';
      investmentsAndAssets.investor                                            = 'Likely';
      investmentsAndAssets.netWorthGoldMax                                     = 1999999;
      investmentsAndAssets.netWorthGoldMin                                     = 1;
      investmentsAndAssets.netWorthUltraAffluent                               = true;
      investmentsAndAssets.ownsRealEstateProperty                              = true;
      investmentsAndAssets.retirementAssets                                    = 1;
      investmentsAndAssets.selfDirectedInvestor                                = 'Likely';
      investmentsAndAssets.stocksAndBondsInvestor                              = 'Likely';
      investmentsAndAssets.totalLiquidInvestibleAssets                         = 1;

      return investmentsAndAssets;
  }
}