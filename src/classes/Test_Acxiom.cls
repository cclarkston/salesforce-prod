/*
10/17/16
Alon Waisman
Classes:
  Acxiom - 95%;
*/

@isTest
private class Test_Acxiom {

    // **************** EXAMPLE HTTP COMMUNICATIONS **************** //
    // Token request endpoint: https://login.myacxiom.com/api/v1/auth/oauth2/token?client_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx&client_secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&grant_type=client_credentials
    // Success: 200 - {"access_token":"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx","token_type":"Bearer","expires_in":3600}
    // Failure: 401 - {"error":"invalid_client","error_description":"Client authentication failed"}
    //
    // Data request endpoint: (A realistic success response has a mix of the 31 fields from investmentsAndAssets and personicxLifestage... this example shows a realistic response where not all fields are returned.)
    // Success response: 200 - {"person":{"investmentsAndAssets":{"affordabilityUS":"Cushioned comfort","economicStabilityIndicator":1,"estimatedIncomeMin":125000,"fullServiceInvestor":"Very likely","haveAnyPrivatelyHeldSharesOfCompaniesOrPartnerships":"Somewhat likely","housingInvestmentPropertiesOwned":1,"investingInterests":[ "Investing/Finance", "Money seekers", "Personal", "Stocks/Bonds", "Real estate", "Foreign" ],"investor":"Very likely","ownsRealEstateProperty":true,"retirementAssets":0,"selfDirectedInvestor":"Likely","stocksAndBondsInvestor":"Very likely","totalLiquidInvestibleAssets":0},"personicxLifestage":{"lifestageCluster":"01","lifestageGroup":"11B"}}}
    // Failure response: 400 - {"error":"invalid_request","error_description":"Missing grant_type"}

    // **************** TESTS **************** //

    private static Integer callouts;

    static testMethod void test_adding_a_lead_results_in_a_new_Acxiom_record_with_all_values_populated_given_a_successful_response() {
        Integer             mock_token_status  = null;
        Map<String, String> mock_token_headers = null;
        String              mock_token_body    = '{"access_token":"xx123456-x12x-123x-x1xx-1xx1x12x1xxx","token_type":"Bearer","expires_in":3600}';

        Integer             mock_data_status  = null;
        Map<String, String> mock_data_headers = null;
        String              mock_data_body    = success_response_json(1);

        Acxiom.DocumentWrapper[] documents = success_response(1);
        system.assertEquals(0, [SELECT count() FROM Acxiom_Data__c]);

        Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status, mock_token_headers, mock_token_body, mock_data_status, mock_data_headers, mock_data_body));
        Test.startTest();
            callouts = 0;
            create_leads(1);
            Lead test_lead = a_lead();
        Test.stopTest();

        system.assertEquals(1, [SELECT count() FROM Lead]);
        system.assertEquals(1, [SELECT count() FROM Acxiom_Data__c]);
        Acxiom_Data__c data = acxiom_record(test_lead.id);

        system.assertEquals(test_lead.id, data.Lead__c);

        system.assertEquals(documents[0].document.person.personicxLifestage.lifestageCluster,                        data.lifestageCluster__c);
        system.assertEquals(documents[0].document.person.personicxLifestage.lifestageGroup,                          data.lifestageGroup__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.acquiredAnIRA,                         data.acquiredAnIRA__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.acquiredAny401k,                       data.acquiredAny401k__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.activeInvestments,                     data.activeInvestments__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.affordabilityUS,                       data.affordabilityUS__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.annuitiesAcquired,                     data.annuitiesAcquired__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.anyInvestmentsAcquired,                data.anyInvestmentsAcquired__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.economicStabilityIndicator,            data.economicStabilityIndicator__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.estimatedIncomeMax,                    data.estimatedIncomeMax__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.estimatedIncomeMin,                    data.estimatedIncomeMin__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.fullServiceInvestor,                   data.fullServiceInvestor__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveA529SavingsPlan,                   data.haveA529SavingsPlan__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveAnOnlineTradingAccount,            data.haveAnOnlineTradingAccount__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveAny401k,                           data.haveAny401k__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveAnyAnnuities,                      data.haveAnyAnnuities__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveAnyIRAAccount,                     data.haveAnyIRAAccount__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveAnyPrivatelyHeldSharesOfCompaniesOrPartnerships, data.haveAnyPrivatelyHeldSharesOfCompanies__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.haveCorporateBondsOrDebentures,        data.haveCorporateBondsOrDebentures__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.housingInvestmentPropertiesOwned,      data.housingInvestmentPropertiesOwned__c);
        system.assertEquals(String.join(documents[0].document.person.investmentsAndAssets.investingInterests, ';'),  data.investingInterests__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.investmentServicesConsumerSegment,     data.investmentServicesConsumerSegment__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.investor,                              data.investor__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.netWorthGoldMax,                       data.netWorthGoldMax__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.netWorthGoldMin,                       data.netWorthGoldMin__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.netWorthUltraAffluent,                 data.netWorthUltraAffluent__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.ownsRealEstateProperty,                data.ownsRealEstateProperty__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.retirementAssets,                      data.retirementAssets__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.selfDirectedInvestor,                  data.selfDirectedInvestor__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.stocksAndBondsInvestor,                data.stocksAndBondsInvestor__c);
        system.assertEquals(documents[0].document.person.investmentsAndAssets.totalLiquidInvestibleAssets,           data.totalLiquidInvestibleAssets__c);
        system.assertEquals(null, data.Error_Code__c);
        system.assertEquals(null, data.Error_Message__c);
        system.assertEquals(null, data.Error_Request_ID__c);
    }

    static testMethod void test_save_acxiom_data_can_take_multiple_lead_IDs_and_generate_new_Acxiom_records_in_a_single_batch_callout() {
        Integer leads_count = 101;

        Integer             mock_token_status  = null;
        Map<String, String> mock_token_headers = null;
        String              mock_token_body    = '{"access_token":"xx123456-x12x-123x-x1xx-1xx1x12x1xxx","token_type":"Bearer","expires_in":3600}';

        Integer             mock_data_status  = null;
        Map<String, String> mock_data_headers = null;
        String              mock_data_body    = success_response_json(leads_count);

        Acxiom.DocumentWrapper[] documents = success_response(leads_count);
        system.assertEquals(0, [SELECT count() FROM Acxiom_Data__c]);

        Util_TriggerContext.alteralreadyprocessed(true);
        create_leads(leads_count);
        Lead[] leads = [SELECT ID FROM Lead];
        ID[] lead_IDs = new ID[]{};
        for (Lead lead : leads) {lead_IDs.add(lead.id);}

        Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status, mock_token_headers, mock_token_body, mock_data_status, mock_data_headers, mock_data_body));
        Test.startTest();
            callouts = 0;
            Acxiom.save_acxiom_data(lead_IDs);
        Test.stopTest();

        system.assertEquals(leads_count, [SELECT count() FROM Acxiom_Data__c]);
        system.assertEquals(2, callouts);
    }

    static testMethod void test_adding_a_lead_results_in_a_new_Acxiom_record_with_error_data_given_an_error_response() {
        Integer             mock_token_status  = null;
        Map<String, String> mock_token_headers = null;
        String              mock_token_body    = '{"access_token":"xx123456-x12x-123x-x1xx-1xx1x12x1xxx","token_type":"Bearer","expires_in":3600}';

        Integer             mock_data_status  = null;
        Map<String, String> mock_data_headers = null;
        String              mock_data_body    = error_response_json(1);

        Acxiom.DocumentWrapper[] documents = error_response(1);

        Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status, mock_token_headers, mock_token_body, mock_data_status, mock_data_headers, mock_data_body));
        Test.startTest();
            callouts = 0;
            create_leads(1);
            Lead test_lead = a_lead();
        Test.stopTest();

        Acxiom_Data__c data = acxiom_record(test_lead.id);

        system.assertEquals(test_lead.id, data.Lead__c);

        system.assertEquals(documents[0].document.error.code,      data.Error_Code__c);
        system.assertEquals(documents[0].document.error.message,   data.Error_Message__c);
        system.assertEquals(documents[0].document.error.requestId, data.Error_Request_ID__c);
    }

            // This error scenario now results in an email rather than saving an acxiom record.
            // I don't know how to test for an email being sent, so I'm disabling the test.
            // static testMethod void test_adding_a_lead_results_in_a_new_Acxiom_record_with_the_correct_error_message_when_token_request_fails() {
            //     Integer             mock_token_status  = null;
            //     Map<String, String> mock_token_headers = null;
            //     String              mock_token_body    = '{"error":"invalid_client","error_description":"Client authentication failed"}';
            //
            //     Integer             mock_data_status  = null;
            //     Map<String, String> mock_data_headers = null;
            //     String              mock_data_body    = success_response_json(1);
            //
            //     String expected_exception = 'Acxiom OAuth error: invalid_client - Client authentication failed';
            //
            //     Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status, mock_token_headers, mock_token_body, mock_data_status, mock_data_headers, mock_data_body));
            //     Test.startTest();
            //         callouts = 0;
            //         create_leads(1);
            //         Lead test_lead = a_lead();
            //     Test.stopTest();
            //
            //     Acxiom_Data__c data = acxiom_record(test_lead.id);
            //     system.assertEquals(expected_exception, data.Error_Message__c);
            // }

    static testMethod void test_adding_a_lead_results_in_a_new_Acxiom_record_with_the_correct_error_message_when_Acxiom_response_does_not_contain_person_or_error_object() {
        Integer             mock_token_status  = null;
        Map<String, String> mock_token_headers = null;
        String              mock_token_body    = '{"access_token":"xx123456-x12x-123x-x1xx-1xx1x12x1xxx","token_type":"Bearer","expires_in":3600}';

        Integer             mock_data_status  = null;
        Map<String, String> mock_data_headers = null;
        String              mock_data_body    = '[{"object_name_other_than_person_or_error":{"investmentsAndAssets":{},"personicxLifestage":{}}}]';

        String expected_exception = 'Acxiom data error: Unexpected or missing response from Acxiom. No \'person\' or \'error\' data found.';

        Test.setMock(HttpCalloutMock.class, new MockHttp_Acxiom(mock_token_status, mock_token_headers, mock_token_body, mock_data_status, mock_data_headers, mock_data_body));
        Test.startTest();
            callouts = 0;
            create_leads(1);
            Lead test_lead = a_lead();
        Test.stopTest();

        Acxiom_Data__c data = acxiom_record(test_lead.id);
        system.assertEquals(expected_exception, data.Error_Message__c);
    }

    static testMethod void test_adding_leads_results_in_new_Acxiom_records_with_the_correct_error_messages_when_given_bad_contact_info() {
        // A bad lead is one in which either the first name or last name is missing (Lead can't be created with missing last name, so that's not tested)
        // OR
        // both the postal code and city/state are missing
        Lead good_lead = new Lead(FirstName = 'Test', LastName = 'User', Street = '1313 Test Lane', City = 'Test City', State = 'AL', PostalCode = '01234-5678', Phone = '(123)456-7890', Date_of_Birth__c = Date.newInstance(2000, 1, 1));
        String first_name_error   = 'FirstName is missing or prohibited';
        String address_error      = 'City and/or State AND PostalCode are missing (or bad)';
        String both_errors        = String.join(new String[]{first_name_error, address_error}, ', ');
        String test_data_error    = 'This is only a test';

        Lead[] bad_leads = new Lead[]{};

        // Missing first name
        Lead bad_lead1 = good_lead.clone();
		bad_lead1.FirstName = null;
        bad_leads.add(bad_lead1);

        // First name is 'Unknown'
        Lead bad_lead2 = good_lead.clone();
		bad_lead2.FirstName = 'Unknown';
        bad_leads.add(bad_lead2);

        // Good city, bad state, bad postal code
		Lead bad_lead3 = good_lead.clone();
		bad_lead3.City        = 'Any non-blank string is OK';
        bad_lead3.State       = 'Correct abbreviation or correctly spelled full name is OK';
        bad_lead3.PostalCode  = 'Should_be_5_or_5-4';
        bad_leads.add(bad_lead3);

        // Bad city, good state, bad postal code
        Lead bad_lead4 = good_lead.clone();
        bad_lead4.City        = null;
        bad_lead4.State       = 'Alabama';
        bad_lead4.PostalCode  = null;
        bad_leads.add(bad_lead4);

        // Bad first name, bad address
        Lead bad_lead5 = good_lead.clone();
        bad_lead5.FirstName   = '';
        bad_lead5.City        = '';
        bad_lead5.State       = 'Misspelled State';
        bad_lead5.PostalCode  = 'badly_formatted_code';
        bad_leads.add(bad_lead5);

        // Lead is actually a test of the production environment (LastName is Test, Phone is 1111111111)... Normally these are deleted before the Acxiom process is even run
        Lead bad_lead6 = good_lead.clone();
        bad_lead6.LastName = 'Test';
        bad_lead6.Phone    = '(111) 111-1111';
        bad_leads.add(bad_lead6);

        Test.startTest();
            insert bad_leads;
        Test.stopTest();

        system.assertEquals(bad_leads.size(), [SELECT count() FROM Acxiom_Data__c]);

        Acxiom_Data__c error_record;

        error_record = acxiom_record(bad_lead1.id);
        system.assertEquals(first_name_error, error_record.Error_Message__c);

        error_record = acxiom_record(bad_lead2.id);
        system.assertEquals(first_name_error, error_record.Error_Message__c);

        error_record = acxiom_record(bad_lead3.id);
        system.assertEquals(address_error, error_record.Error_Message__c);

        error_record = acxiom_record(bad_lead4.id);
        system.assertEquals(address_error, error_record.Error_Message__c);

        error_record = acxiom_record(bad_lead5.id);
        system.assertEquals(both_errors, error_record.Error_Message__c);

        error_record = acxiom_record(bad_lead6.id);
        system.assertEquals(test_data_error, error_record.Error_Message__c);
    }


    // **************** MOCKS **************** //

    public class MockHttp_Acxiom implements HttpCalloutMock {
        private HttpResponse response = new HttpResponse();
        private Integer             t_status_code;
        private Map<String, String> t_headers;
        private String              t_body;
        private Integer             d_status_code;
        private Map<String, String> d_headers;
        private String              d_body;

        public MockHttp_Acxiom(Integer token_status_code, Map<String, String> token_headers, String token_body, Integer data_status_code, Map<String, String> data_headers, String data_body) {
            t_status_code = token_status_code;
            t_headers     = token_headers;
            t_body        = token_body;
            d_status_code = data_status_code;
            d_headers     = data_headers;
            d_body        = data_body;
        }

        public HttpResponse respond(HttpRequest request) {
            Test_Acxiom.callouts++;
            Boolean is_token_callout = request.getEndpoint().contains('/token?');

            Integer             status_code = (is_token_callout) ? t_status_code : d_status_code;
            Map<String, String> headers     = (is_token_callout) ? t_headers : d_headers;
            String              body        = (is_token_callout) ? t_body : d_body;

            if (status_code != null) {response.setStatusCode(status_code);}
            if (headers     != null) {for (String key : headers.keySet()) {response.setHeader(key, headers.get(key));}}
            if (body        != null) {response.setBody(body);}
            return response;
        }
    }

    // **************** SETUP **************** //

            private static void create_leads(Integer count) {
                Lead[] leads = new Lead[]{};
                for (Integer i = 1; i <= count; i++) {
                    Lead lead = new Lead(FirstName = 'Test' + i, LastName = 'User', Street = '1313 Test Lane', City = 'Test City', State = 'AB', PostalCode = '01234');
                    leads.add(lead);
                }
                insert leads;
            }

            private static Lead a_lead() {
                return [SELECT ID, FirstName, LastName, Street, City, State, PostalCode FROM Lead LIMIT 1];
            }

            private static Acxiom_Data__c acxiom_record(ID lead_ID) {
                return [SELECT ID,
                               Lead__c,
                               lifestageCluster__c,
                               lifestageGroup__c,
                               acquiredAnIRA__c,
                               acquiredAny401k__c,
                               activeInvestments__c,
                               affordabilityUS__c,
                               annuitiesAcquired__c,
                               anyInvestmentsAcquired__c,
                               economicStabilityIndicator__c,
                               estimatedIncomeMax__c,
                               estimatedIncomeMin__c,
                               fullServiceInvestor__c,
                               haveA529SavingsPlan__c,
                               haveAnOnlineTradingAccount__c,
                               haveAny401k__c,
                               haveAnyAnnuities__c,
                               haveAnyIRAAccount__c,
                               haveAnyPrivatelyHeldSharesOfCompanies__c,
                               haveCorporateBondsOrDebentures__c,
                               housingInvestmentPropertiesOwned__c,
                               investingInterests__c,
                               investmentServicesConsumerSegment__c,
                               investor__c,
                               netWorthGoldMax__c,
                               netWorthGoldMin__c,
                               netWorthUltraAffluent__c,
                               ownsRealEstateProperty__c,
                               retirementAssets__c,
                               selfDirectedInvestor__c,
                               stocksAndBondsInvestor__c,
                               totalLiquidInvestibleAssets__c,
                               Error_Code__c,
                               Error_Message__c,
                               Error_Request_ID__c
                        FROM Acxiom_Data__c
                        WHERE Lead__c = :lead_ID];
            }

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

            private static String error_response_json(Integer document_count) {
                return JSON.serialize(error_response(document_count));
            }

            private static Acxiom.DocumentWrapper[] error_response(Integer document_count) {
                Acxiom.DocumentWrapper[] document_wrappers = new Acxiom.DocumentWrapper[]{};
                for (Integer i = 0; i < document_count; i++) {
                    Acxiom.DocumentWrapper wrapper = new Acxiom.DocumentWrapper();
                    wrapper.code           = 404;
                    wrapper.document       = new Acxiom.Document();
                    wrapper.document.error = completed_error();
                    document_wrappers.add(wrapper);
                }

                return document_wrappers;
            }

                    private static Acxiom.Error completed_error() {
                        Acxiom.Error error = new Acxiom.Error();

                        error.code      = 'test_error_code';
                        error.message   = 'Test error message';
                        error.requestID = 'test-error-id';

                        return error;
                    }
}