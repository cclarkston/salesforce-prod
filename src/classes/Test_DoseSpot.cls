/*
2016-01-10
Alon Waisman
Classes:
  DoseSpotAPI_v12_2017_01_05 - 90% (The API is huge. All unused portions are commented out.)
  DoseSpot - 83%
  DoseSpotServices - 81%
*/

@isTest
private class Test_DoseSpot {
    static User current_user;

    private static void init(String DoseSpot_patient_ID) {
        Center_Information__c center = new_center();
        create_account(DoseSpot_patient_ID, center);
        current_user = new_user();
    }


    static testMethod void test_DoseSpot_patient_URL_when_user_IS_NOT_already_in_DoseSpot_it_returns_a_properly_formatted_DoseSpot_URL_with_new_PatientID_parameter() {
        String DoseSpot_patient_ID = '111111';
        init(null);
        Integer mock_status = 302;
        Map<String, String> mock_headers = new Map<String, String>{'Location' => '/secure/PatientDetail.aspx?PatientID=' + DoseSpot_patient_ID};
        String mock_body = '';
        Account patient = patient('Test Patient');
        // String expected = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&PatientID=111111&Prefix=&FirstName=Test&MiddleName=&LastName=Patient&Suffix=&DateOfBirth=01-01-2000&Gender=Male&MRN=&Address1=123 Test Street&Address2=&City=Test City&State=Teststate&ZipCode=12345&PrimaryPhone=(303) 123-4567&PrimaryPhoneType=Primary&PharmacyID=';
        String expected = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&PatientID=111111&Prefix=&FirstName=Test&MiddleName=&LastName=Patient&Suffix=&DateOfBirth=01-01-2000&Gender=Male&MRN=&Address1=123+Test+Street&Address2=&City=Test+City&State=Teststate&ZipCode=12345&PrimaryPhone=%28303%29+123-4567&PrimaryPhoneType=Primary&PharmacyID=';

        System.runAs(current_user){
            Test.setMock(HttpCalloutMock.class, new MockHttp_DoseSpot_patient_URL(mock_status, mock_headers, mock_body));
            Test.startTest();
                String result = DoseSpotServices.DoseSpot_patient_URL(patient.id);
                system.assert(result.contains('PatientID=111111'));
                system.assertEquals(expected, result);
            Test.stopTest();
        }
    }

    static testMethod void test_DoseSpot_patient_URL_when_user_IS_NOT_already_in_DoseSpot_it_updates_patient_with_new_DoseSpot_patient_ID() {
        String DoseSpot_patient_ID = '222222';
        init(null);
        Integer mock_status = 302;
        Map<String, String> mock_headers = new Map<String, String>{'Location' => '/secure/PatientDetail.aspx?PatientID=' + DoseSpot_patient_ID};
        String mock_body = '';
        Account patient = [SELECT ID, DoseSpot_Patient_ID__c FROM Account WHERE Name = 'Test Patient'];

        System.runAs(current_user){
            Test.setMock(HttpCalloutMock.class, new MockHttp_DoseSpot_patient_URL(mock_status, mock_headers, mock_body));
            Test.startTest();
                system.assertEquals(null, patient.DoseSpot_Patient_ID__c);
                DoseSpotServices.DoseSpot_patient_URL(patient.id);
                patient = [SELECT ID, DoseSpot_Patient_ID__c FROM Account WHERE Name = 'Test Patient'];
                system.assertEquals('222222', patient.DoseSpot_Patient_ID__c);
            Test.stopTest();
        }
    }

    static testMethod void test_DoseSpot_patient_URL_when_user_IS_already_in_DoseSpot_it_returns_a_properly_formatted_DoseSpot_URL_with_existing_Patient_ID() {
        String DoseSpot_patient_ID = '333333';
        init(DoseSpot_patient_ID);
        Account patient = patient('Test Patient');
        Integer mock_status = 302;
        Map<String, String> mock_headers = new Map<String, String>{'Location' => '/secure/PatientDetail.aspx?PatientID=' + DoseSpot_patient_ID};
        String mock_body = '';
        // String expected = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&PatientID=333333&Prefix=&FirstName=Test&MiddleName=&LastName=Patient&Suffix=&DateOfBirth=01-01-2000&Gender=Male&MRN=&Address1=123 Test Street&Address2=&City=Test City&State=Teststate&ZipCode=12345&PrimaryPhone=(303) 123-4567&PrimaryPhoneType=Primary&PharmacyID=';
        String expected = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&PatientID=333333&Prefix=&FirstName=Test&MiddleName=&LastName=Patient&Suffix=&DateOfBirth=01-01-2000&Gender=Male&MRN=&Address1=123+Test+Street&Address2=&City=Test+City&State=Teststate&ZipCode=12345&PrimaryPhone=%28303%29+123-4567&PrimaryPhoneType=Primary&PharmacyID=';

        System.runAs(current_user){
            Test.setMock(HttpCalloutMock.class, new MockHttp_DoseSpot_patient_URL(mock_status, mock_headers, mock_body));
            Test.startTest();
                String result = DoseSpotServices.DoseSpot_patient_URL(patient.id);
                system.assert(result.contains('PatientID=333333'));
                system.assertEquals(expected, result);
            Test.stopTest();
        }
    }

    static testMethod void test_refill_requests_and_transmission_errors_returns_the_standard_JSON_package_with_correct_refillRequestCount_and_transmissionErrorCount_and_URL() {
        init(null);
        Center_Information__c center = [SELECT ID FROM Center_Information__c LIMIT 1];
        Integer mock_refill_requests = 1;
        Integer mock_transmission_errors = 2;
        String expected_URL = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&RefillsErrors=1';

		Boolean success_status    = true;
		String mock_error_message = null;

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_refill_requests_and_transmission_errors(new Map<String, Integer>{'refill_requests' => mock_refill_requests, 'transmission_errors' => mock_transmission_errors}, success_status, mock_error_message));
            Test.startTest();
                DoseSpotServices.Response result = DoseSpotServices.refill_requests_and_transmission_errors(center);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                Map<String, Object> result_data = (Map<String, Object>)result.data;
                system.assertEquals(1, result_data.get('refillRequestCount'));
                system.assertEquals(2, result_data.get('transmissionErrorCount'));
                system.assertEquals(expected_URL, result_data.get('URL'));
            Test.stopTest();
        }
    }

    static testMethod void test_notification_counts_returns_the_standard_response_package_with_correct_refillRequestCount_and_transmissionErrorCount_and_pendingPrescriptionsCount_and_URL() {
        init(null);
        Center_Information__c center = [SELECT ID FROM Center_Information__c LIMIT 1];
        Integer mock_refill_requests       = 1;
        Integer mock_transmission_errors   = 2;
        Integer mock_pending_prescriptions = 3;
        String expected_URL = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&RefillsErrors=1';

		Boolean success_status    = true;
		String mock_error_message = null;

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_notifications_count(new Map<String, Integer>{'refill_requests' => mock_refill_requests, 'transmission_errors' => mock_transmission_errors, 'pending_prescriptions' => mock_pending_prescriptions}, success_status, mock_error_message));
            Test.startTest();
                DoseSpotServices.Response result = DoseSpotServices.notification_counts(center, current_user.DoseSpot_User_ID__c);
                Map<String, Object> result_data = (Map<String, Object>)result.data;
                system.assertEquals(1, result_data.get('refillRequestCount'));
                system.assertEquals(2, result_data.get('transmissionErrorCount'));
                system.assertEquals(3, result_data.get('pendingPrescriptionsCount'));
                system.assertEquals(expected_URL, result_data.get('URL'));
            Test.stopTest();
        }
    }

    static testMethod void test_medication_search_results_takes_a_search_term_with_at_least_three_letters_then_returns_package_with_many_name_and_lexicompdrugid_and_lexicompsynonymid() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String query    = 'tes';
        Account patient = patient('Test Patient');

        String  mock_name1              = 'Test medication 1';
        String  mock_lexicompdrugid1    = 'test1234';
        Integer mock_lexicompsynonymid1 = 98765;
        String  mock_name2              = 'Test medication 2';
        String  mock_lexicompdrugid2    = 'test5678';
        Integer mock_lexicompsynonymid2 = 43210;

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_medication_search_results(new List<Map<String, Object>>{new Map<String, Object>{'name' => mock_name1, 'lexicompdrugid' => mock_lexicompdrugid1, 'lexicompsynonymid' => mock_lexicompsynonymid1},
                                                                                                                          new Map<String, Object>{'name' => mock_name2, 'lexicompdrugid' => mock_lexicompdrugid2, 'lexicompsynonymid' => mock_lexicompsynonymid2}}));
            Test.startTest();
                // String json_result = DoseSpotServices.medication_search_results(query, patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                // List<Object> result_data   = (List<Object>)result.get('data');
                // system.assertEquals(2, result_data.size());
                // Map<String, Object> medication1 = (Map<String, Object>)result_data[0];
                // Map<String, Object> medication2 = (Map<String, Object>)result_data[1];
                DoseSpotServices.Response response_package = DoseSpotServices.medication_search_results(query, patient.id);
                List<Object> result_data = (List<Object>)response_package.data;
                system.assertEquals(2, result_data.size());
                Map<String, String> medication1 = (Map<String, String>)result_data[0];
                Map<String, String> medication2 = (Map<String, String>)result_data[1];

                system.assertEquals('Test medication 1', medication1.get('name'));
                system.assertEquals('Test medication 2', medication2.get('name'));
                system.assertEquals('test1234', medication1.get('lexicompdrugid'));
                system.assertEquals('test5678', medication2.get('lexicompdrugid'));
                system.assertEquals(98765, Integer.valueOf(medication1.get('lexicompsynonymid')));
                system.assertEquals(43210, Integer.valueOf(medication2.get('lexicompsynonymid')));
            Test.stopTest();
        }
    }

    static testMethod void test_add_medication_success_returns_package_with_success_message_including_name_of_medication() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String medication         = 'Test Medication';
        String lexicompdrugid     = 'a12345';
        Integer lexicompsynonymid = 98765;
        Account patient           = patient('Test Patient');

        Boolean success_status = true;
        String mock_error_message = null;

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_add_medication(success_status, medication, mock_error_message));
            Test.startTest();
                // String json_result = DoseSpotServices.add_medication(medication, lexicompdrugid, lexicompsynonymid, patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                // String result_message = (String)result.get('message');
                DoseSpotServices.Response response_package = DoseSpotServices.add_medication(medication, lexicompdrugid, lexicompsynonymid, patient.id);
                system.assertEquals('\'Test Medication\' has been added to patient\'s list of medications.', response_package.message);
            Test.stopTest();
        }
    }

    static testMethod void test_add_medication_failure_returns_package_with_failure_message() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String medication         = 'Test Medication';
        String lexicompdrugid     = 'a12345';
        Integer lexicompsynonymid = 98765;
        Account patient           = patient('Test Patient');

        Boolean success_status    = false;
        String mock_error_message = 'An error occurred while updating the entries...';

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_add_medication(success_status, medication, mock_error_message));
            Test.startTest();
                // String json_result = DoseSpotServices.add_medication(medication, lexicompdrugid, lexicompsynonymid, patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                // String result_message = (String)result.get('message');
                DoseSpotServices.Response response_package = DoseSpotServices.add_medication(medication, lexicompdrugid, lexicompsynonymid, patient.id);
                system.assertEquals(mock_error_message, response_package.message);
            Test.stopTest();
        }
    }

    static testMethod void test_upsert_medication_history_adds_new_medications_to_SalesForce_and_returns_package_with_success_message_including_count_of_added_medications() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String mock_name1 = 'Test Medication 1';
        Integer mock_id1  = 12345;
        String mock_name2 = 'Test Medication 2';
        Integer mock_id2  = 98765;
        Account patient   = patient('Test Patient');

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_upsert_medication_history(new List<Map<String, Object>>{new Map<String, Object>{'name' => mock_name1, 'medication_id' => mock_id1},
                                                                                                                          new Map<String, Object>{'name' => mock_name2, 'medication_id' => mock_id2}}));
            Test.startTest();
                system.assertEquals(0, patient_medications(patient.id).size());
                DoseSpotServices.Response result = DoseSpotServices.upsert_medication_history(patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                String result_message = result.message;
                system.assertEquals('2 medications added/updated in patient\'s record.', result_message);
                patient = patient('Test Patient');
                Medication__c[] patient_medications = patient_medications(patient.id);
                system.assertEquals(2, patient_medications.size());
                system.assertEquals('Test Medication 1', patient_medications[0].Name);
                system.assertEquals('Test Medication 2', patient_medications[1].Name);
                system.assertEquals(12345, patient_medications[0].Medication_ID__c);
                system.assertEquals(98765, patient_medications[1].Medication_ID__c);
            Test.stopTest();
        }
    }

    static testMethod void test_upsert_medication_history_updates_existing_medications_in_SalesForce_with_or_without_a_medication_ID() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String initial_status  = 'Active';
        String name1           = 'Test Medication 1';
        Integer id1            = 12345;
        String dispense_units1 = null; //'test dispense unit 1';
        String strength1       = null; //'10 test units'
        Date date_written1     = null; //Date.newInstance(2000, 2, 20);
        String name2           = 'Test Medication 2';
        Integer id2            = 98765;
        String dispense_units2 = 'test dispense unit 2';
        String strength2       = '20 test units';
        Date date_written2     = Date.newInstance(2016, 2, 20);
        Account patient        = patient('Test Patient');
        Medication__c medication = new Medication__c();
        insert new Medication__c(Patient__c = patient.id, Name = name1, Medication_Status__c = initial_status, Medication_ID__c = id1, Dispense_Units__c = null, Strength__c = null, Date_Written__c = null);
        insert new Medication__c(Patient__c = patient.id, Name = name2, Medication_Status__c = initial_status, Medication_ID__c = null, Dispense_Units__c = dispense_units2, Strength__c = strength2, Date_Written__c = date_written2);

        String updated_status = 'Inactive';

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_upsert_medication_history(new List<Map<String, Object>>{new Map<String, Object>{'name' => name1, 'status' => updated_status, 'medication_id' => id1, 'dispense_units' => dispense_units1, 'strength' => strength1, 'date_written' => date_written1},
                                                                                                                          new Map<String, Object>{'name' => name2, 'status' => updated_status, 'medication_id' => id2, 'dispense_units' => dispense_units2, 'strength' => strength2, 'date_written' => date_written2}}));
            Test.startTest();
                Medication__c[] patient_medications = patient_medications(patient.id);
                Integer initial_medication_count = patient_medications.size();
                system.assert(patient_medications[0].Medication_Status__c == initial_status && patient_medications[1].Medication_Status__c == initial_status);
                DoseSpotServices.upsert_medication_history(patient.id);
                patient_medications = patient_medications(patient.id);

                system.assertEquals(initial_medication_count, patient_medications.size());
                system.assertEquals(updated_status, patient_medications[0].Medication_Status__c);
                system.assertEquals(updated_status, patient_medications[1].Medication_Status__c);
                // system.assert(patient_medications[0].Medication_Status__c == updated_status && patient_medications[1].Medication_Status__c == updated_status);
            Test.stopTest();
        }
    }


    static testMethod void test_allergy_search_results_takes_a_search_term_with_at_least_three_letters_then_returns_package_with_many_name_and_code_and_code_type() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String query = 'tes';

        Account patient        = patient('Test Patient');
        String mock_name1      = 'Test allergy 1';
        String mock_code1      = 'test1234';
        String mock_code_type1 = 'TestType1';
        String mock_name2      = 'Test allergy 2';
        String mock_code2      = 'test5678';
        String mock_code_type2 = 'TestType2';

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_allergy_search_results(new List<Map<String, Object>>{new Map<String, Object>{'name' => mock_name1, 'code' => mock_code1, 'code_type' => mock_code_type1},
                                                                                                                       new Map<String, Object>{'name' => mock_name2, 'code' => mock_code2, 'code_type' => mock_code_type2}}));
            Test.startTest();
                // String json_result = DoseSpotServices.allergy_search_results(query);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                // List<Object> result_data   = (List<Object>)result.get('data');
                // system.assertEquals(2, result_data.size());
                // Map<String, Object> allergy1 = (Map<String, Object>)result_data[0];
                // Map<String, Object> allergy2 = (Map<String, Object>)result_data[1];
                DoseSpotServices.Response response_package = DoseSpotServices.allergy_search_results(patient.ID, query);
                List<Map<String, String>> result_data = (List<Map<String, String>>)response_package.data;
                system.assertEquals(2, result_data.size());
                Map<String, String> allergy1 = result_data[0];
                Map<String, String> allergy2 = result_data[1];

                system.assertEquals('Test allergy 1', allergy1.get('name'));
                system.assertEquals('Test allergy 2', allergy2.get('name'));
                system.assertEquals('test1234', allergy1.get('code'));
                system.assertEquals('test5678', allergy2.get('code'));
                system.assertEquals('TestType1', allergy1.get('code_type'));
                system.assertEquals('TestType2', allergy2.get('code_type'));
            Test.stopTest();
        }
    }

    static testMethod void test_add_allergy_success_returns_package_with_success_message_including_name_of_allergy() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String allergy  = 'Test Allergy';
        String code          = 'test code';
        String code_type     = 'test code_type';
        String reaction      = 'test reaction';
        String reaction_type = 'test reaction_type';
        Datetime onset_date  = Datetime.newInstance(1999, 12, 31);
        Account patient      = patient('Test Patient');

        Boolean success_status    = true;
        String mock_error_message = null;

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_add_allergy(success_status, allergy, mock_error_message));
            Test.startTest();
                // String json_result = DoseSpotServices.add_allergy(allergy, code, code_type, reaction, reaction_type, onset_date, patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                // String result_message = (String)result.get('message');
                DoseSpotServices.Response response_package = DoseSpotServices.add_allergy(allergy, code, code_type, reaction, reaction_type, onset_date, patient.id);
                system.assertEquals('\'Test Allergy\' has been added to patient\'s list of allergies.', response_package.message);
            Test.stopTest();
        }
    }

    static testMethod void test_add_allergy_failure_returns_package_with_failure_message() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String allergy       = 'Test Allergy';
        String code          = 'test code';
        String code_type     = 'test code_type';
        String reaction      = 'test reaction';
        String reaction_type = 'test reaction_type';
        Datetime onset_date  = Datetime.newInstance(1999, 12, 31);
        Account patient      = patient('Test Patient');

        Boolean success_status    = false;
        String mock_error_message = 'An error occurred while updating the entries...';

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_add_allergy(success_status, allergy, mock_error_message));
            Test.startTest();
                // String json_result = DoseSpotServices.add_allergy(allergy, code, code_type, reaction, reaction_type, onset_date, patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                // String result_message = (String)result.get('message');
                DoseSpotServices.Response response_package = DoseSpotServices.add_allergy(allergy, code, code_type, reaction, reaction_type, onset_date, patient.id);
                system.assertEquals(mock_error_message, response_package.message);
            Test.stopTest();
        }
    }

    static testMethod void test_upsert_allergies_adds_new_allergies_to_SalesForce_and_returns_package_with_success_message_including_count_of_added_allergies() {
        String DoseSpot_patient_ID = '111111';
        init(DoseSpot_patient_ID);
        String mock_name1 = 'Test Allergy 1';
        Integer mock_id1  = 12345;
        String mock_name2 = 'Test Allergy 2';
        Integer mock_id2  = 98765;
        Account patient   = patient('Test Patient');

        System.runAs(current_user){
            Test.setMock(WebServiceMock.class, new MockWebService_upsert_allergies(new List<Map<String, Object>>{new Map<String, Object>{'name' => mock_name1, 'allergy_id' => mock_id1},
                                                                                                                 new Map<String, Object>{'name' => mock_name2, 'allergy_id' => mock_id2}}));
            Test.startTest();
                system.assertEquals(0, patient_allergies(patient.id).size());
                DoseSpotServices.Response result = DoseSpotServices.upsert_allergies(patient.id);
                // Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(json_result);
                String result_message = result.message;
                system.assertEquals('2 allergies added/updated in patient\'s record.', result_message);
                patient = patient('Test Patient');
                Allergy__c[] patient_allergies = patient_allergies(patient.id);
                system.assertEquals(2, patient_allergies.size());
                system.assertEquals('Test Allergy 1', patient_allergies[0].Name);
                system.assertEquals('Test Allergy 2', patient_allergies[1].Name);
                system.assertEquals(12345, patient_allergies[0].Allergy_ID__c);
                system.assertEquals(98765, patient_allergies[1].Allergy_ID__c);
            Test.stopTest();
        }
    }

    // I dropped this test because Allergies should always come back with ID's, and I'm no longer trying to match non-DoseSpot enterred allergies against those enterred with DoseSpot.
    // static testMethod void test_upsert_allergies_updates_existing_allergies_in_SalesForce_with_or_without_an_allergy_ID() {
    //     String DoseSpot_patient_ID = '111111';
    //     init(DoseSpot_patient_ID);
    //     String initial_status  = 'Active';
    //     String name1           = 'Test Allergy 1';
    //     Integer id1            = 12345;
    //     String name2           = 'Test Allergy 2';
    //     Integer id2            = 98765;
    //     Account patient        = patient('Test Patient');
    //     Allergy__c allergy = new Allergy__c();
    //     insert new Allergy__c(Patient__c = patient.id, Name = name1, Status__c = initial_status, Allergy_ID__c = id1);
    //     insert new Allergy__c(Patient__c = patient.id, Name = name2, Status__c = initial_status, Allergy_ID__c = null);
    //
    //     String updated_status = 'Inactive';
    //
    //
    //     System.runAs(current_user){
    //         Test.setMock(WebServiceMock.class, new MockWebService_upsert_allergies(new List<Map<String, Object>>{new Map<String, Object>{'name' => name1, 'status' => updated_status, 'allergy_id' => id1},
    //                                                                                                              new Map<String, Object>{'name' => name2, 'status' => updated_status, 'allergy_id' => id2}}));
    //         Test.startTest();
    //             Allergy__c[] patient_allergies = patient_allergies(patient.id);
    //             Integer initial_allergy_count = patient_allergies.size();
    //             system.assert(patient_allergies[0].Status__c == initial_status && patient_allergies[1].Status__c == initial_status);
    //             DoseSpotServices.upsert_allergies(patient.id);
    //             patient_allergies = patient_allergies(patient.id);
    //             system.assertEquals(initial_allergy_count, patient_allergies.size());
    //             system.assert(patient_allergies[0].Status__c == updated_status && patient_allergies[1].Status__c == updated_status);
    //         Test.stopTest();
    //     }
    // }


        	private static void create_account(String DoseSpot_patient_ID, Center_Information__c center) {
        		insert new Account(FirstName = 'Test',
        							LastName = 'Patient',
                                    Date_of_Birth__c = Date.newInstance(2000, 1, 1),
                                    Gender__c = 'Male',
                                    BillingStreet = '123 Test Street',
                                    BillingCity = 'Test City',
                                    BillingState = 'Teststate',
                                    BillingPostalCode = '12345',
                                    Phone = '(303) 123-4567',
                                    DoseSpot_patient_ID__c = DoseSpot_patient_ID,
                                    Center__c = center.id);
        	}

            private static User new_user() {
                ID profile_id = [Select ID FROM Profile where name = 'System Administrator'].id;
                User testuser = new User(Username = 'alon@alon.alon', FirstName = 'Test', LastName = 'User', Email = 'alon@alon.alon', Alias = 'null', CommunityNickname = 'alon', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = profile_id, LanguageLocaleKey = 'en_US',
                                         Clinic_Calendar__c = 'Denver',
                                         DoseSpot_User_ID__c = '666');
                insert testuser;
                return testuser;
            }

            private static Center_Information__c new_center() {
                Center_Information__c center = new Center_Information__c(Name = 'Denver',
                                                                         DoseSpot_Clinic_ID__c = '123',
                                                                         latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
                insert center;
                return center;
            }

            private static Account patient(String name) {
                return [SELECT ID FROM Account WHERE Name = :name];
            }

            private static Medication__c[] patient_medications(ID patient_id) {
                return [SELECT Name, Medication_ID__c, Medication_Status__c FROM Medication__c WHERE Patient__c = :patient_id];
            }

            private static Allergy__c[] patient_allergies(ID patient_id) {
                return [SELECT Name, Allergy_ID__c, Status__c FROM Allergy__c WHERE Patient__c = :patient_id];
            }


    public class MockHttp_DoseSpot_patient_URL implements HttpCalloutMock {
        private HttpResponse response = new HttpResponse();
        public MockHttp_DoseSpot_patient_URL(Integer status_code, Map<String, String> headers, String body) {
            response.setStatusCode(status_code);
            for (String key : headers.keySet()) {
                response.setHeader(key, headers.get(key));
            }
            response.setBody(body);
        }

        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }

    public class MockWebService_refill_requests_and_transmission_errors implements WebServiceMock {
		private Boolean successful;
		private String error_message;
        private Integer refill_requests;
        private Integer transmission_errors;
        public MockWebService_refill_requests_and_transmission_errors(Map<String, Integer> data, Boolean success_status, String an_error_message) {
			successful			= success_status;
            refill_requests     = data.get('refill_requests');
            transmission_errors = data.get('transmission_errors');
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionErrorsMessageResult DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionErrorsMessageResult();
            DoseSpot_response.RefillRequestsTransmissionErrors                                 	   = new DoseSpotAPI_v12_2017_01_05.ArrayOfRefillRequestsTransmissionError();
            DoseSpot_response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError	   = new DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionError[]{};
            DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionError                            data = new DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionError();

			DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
			DoseSpot_response.Result.ResultCode = successful ? 'OK' : 'ERROR';
			if (!successful) DoseSpot_response.Result.ResultDescription = error_message;

            data.RefillRequestsCount    = refill_requests;
            data.TransactionErrorsCount = transmission_errors;
            DoseSpot_response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError.add(data);

            response.put('response_x', DoseSpot_response);
        }
    }

    public class MockWebService_notifications_count implements WebServiceMock {
		private Boolean successful;
		private String error_message;
        private Integer refill_requests;
        private Integer transmission_errors;
        private Integer pending_prescriptions;
        public MockWebService_notifications_count(Map<String, Integer> data, Boolean success_status, String an_error_message) {
			successful			  = success_status;
            refill_requests       = data.get('refill_requests');
            transmission_errors   = data.get('transmission_errors');
            pending_prescriptions = data.get('pending_prescriptions');
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.GetPrescriberNotificationCountsResponse DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.GetPrescriberNotificationCountsResponse();
            // DoseSpot_response.RefillRequestsTransmissionErrors                                 = new DoseSpotAPI_v12_2017_01_05.ArrayOfRefillRequestsTransmissionError();
            // DoseSpot_response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError = new DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionError[]{};
            // DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionError                                   data = new DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionError();

			DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
			DoseSpot_response.Result.ResultCode = successful ? 'OK' : 'ERROR';
			if (!successful) DoseSpot_response.Result.ResultDescription = error_message;

            DoseSpot_response.RefillRequestsCount       = refill_requests;
            DoseSpot_response.TransactionErrorsCount    = transmission_errors;
            DoseSpot_response.PendingPrescriptionsCount = pending_prescriptions;

            response.put('response_x', DoseSpot_response);
        }
    }

    public class MockWebService_medication_search_results implements WebServiceMock {
        private List<Map<String, Object>> medications;
        public MockWebService_medication_search_results(List<Map<String, Object>> the_medications) {
            medications = the_medications;
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResponse   DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResponse();
            DoseSpot_response.SearchResults                                      = new DoseSpotAPI_v12_2017_01_05.ArrayOfSelfReportedMedicationSearchResult();
            DoseSpot_response.SearchResults.SelfReportedMedicationSearchResult   = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResult[]{};

            for (Map<String, Object> medication_data : medications) {
                DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResult medication = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResult();
                medication.DisplayName       = String.valueOf(medication_data.get('name'));
                medication.LexiCompDrugId    = String.valueOf(medication_data.get('lexicompdrugid'));
                medication.LexiCompSynonymId = Integer.valueOf(medication_data.get('lexicompsynonymid'));
                DoseSpot_response.SearchResults.SelfReportedMedicationSearchResult.add(medication);
            }
            DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
            DoseSpot_response.Result.ResultCode = 'OK';
            response.put('response_x', DoseSpot_response);
        }
    }

    public class MockWebService_add_medication implements WebServiceMock {
        private Boolean successful;
		private String error_message;
        private String medication_name;
        public MockWebService_add_medication(Boolean success_status, String a_medication_name, String an_error_message) {
            successful = success_status;
            medication_name = a_medication_name;
            error_message = an_error_message;
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.AddSelfReportedMedicationsResponse DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.AddSelfReportedMedicationsResponse();

            DoseSpot_response.SelfReportedMedications                                    = new DoseSpotAPI_v12_2017_01_05.ArrayOfSelfReportedMedication();
            DoseSpot_response.SelfReportedMedications.SelfReportedMedication             = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedication[]{};
            DoseSpotAPI_v12_2017_01_05.SelfReportedMedication medication                                = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedication();
            medication.DisplayName                                                       = medication_name;
            DoseSpot_response.SelfReportedMedications.SelfReportedMedication.add(medication);
            DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
            DoseSpot_response.Result.ResultCode = successful ? 'OK' : 'ERROR';
            if (!successful) DoseSpot_response.Result.ResultDescription = error_message;
            response.put('response_x', DoseSpot_response);
        }
    }

    public class MockWebService_upsert_medication_history implements WebServiceMock {
        private List<Map<String, Object>> medications;
        public MockWebService_upsert_medication_history(List<Map<String, Object>> the_medications) {
            medications = the_medications;
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.GetMedicationListResponse DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.GetMedicationListResponse();
            DoseSpot_response.Medications                           = new DoseSpotAPI_v12_2017_01_05.ArrayOfMedicationListItem();
            DoseSpot_response.Medications.MedicationListItem        = new DoseSpotAPI_v12_2017_01_05.MedicationListItem[]{};

            for (Map<String, Object> medication_data : medications) {
                DoseSpotAPI_v12_2017_01_05.MedicationListItem medication = new DoseSpotAPI_v12_2017_01_05.MedicationListItem();
                medication.DisplayName      = String.valueOf(medication_data.get('name'));
                medication.MedicationStatus = String.valueOf(medication_data.get('status'));
                medication.MedicationId     = Integer.valueOf(medication_data.get('medication_id'));
                medication.DispenseUnits    = String.valueOf(medication_data.get('dispense_units'));
                medication.Strength         = String.valueOf(medication_data.get('strength'));
                medication.DateWritten      = Date.valueOf(medication_data.get('date_written'));

                DoseSpot_response.Medications.MedicationListItem.add(medication);
            }
            DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
            DoseSpot_response.Result.ResultCode = 'OK';
            response.put('response_x', DoseSpot_response);
        }
    }

    // public class MockWebService_log_consent implements WebServiceMock {
    //     public MockWebService_log_consent() {}
    //     public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
    //         DoseSpotAPI_v12_2017_01_05.MedHistoryConsentResponse DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.MedHistoryConsentResponse();
    //
    //         DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
    //         DoseSpot_response.Result.ResultCode = 'OK';
    //         response.put('response_x', DoseSpot_response);
    //     }
    // }


    public class MockWebService_allergy_search_results implements WebServiceMock {
        private List<Map<String, Object>> allergies;
        public MockWebService_allergy_search_results(List<Map<String, Object>> the_allergies) {
            allergies = the_allergies;
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.AllergySearchResponse   DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.AllergySearchResponse();
            DoseSpot_response.SearchResults                       = new DoseSpotAPI_v12_2017_01_05.ArrayOfAllergySearchResult();
            DoseSpot_response.SearchResults.AllergySearchResult   = new DoseSpotAPI_v12_2017_01_05.AllergySearchResult[]{};

            for (Map<String, Object> allergy_data : allergies) {
                DoseSpotAPI_v12_2017_01_05.AllergySearchResult allergy = new DoseSpotAPI_v12_2017_01_05.AllergySearchResult();
                allergy.Name     = String.valueOf(allergy_data.get('name'));
                allergy.Code     = String.valueOf(allergy_data.get('code'));
                allergy.CodeType = String.valueOf(allergy_data.get('code_type'));
                DoseSpot_response.SearchResults.AllergySearchResult.add(allergy);
            }
            DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
            DoseSpot_response.Result.ResultCode = 'OK';
            response.put('response_x', DoseSpot_response);
        }
    }

    public class MockWebService_add_allergy implements WebServiceMock {
        private Boolean successful;
        private String allergy_name;
        private String error_message;
        public MockWebService_add_allergy(Boolean success_status, String an_allergy_name, String an_error_message) {
            successful = success_status;
            allergy_name = an_allergy_name;
            error_message = an_error_message;
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.AddAllergyResponse DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.AddAllergyResponse();
            DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
            DoseSpot_response.Result.ResultCode = successful ? 'OK' : 'ERROR';
            if (!successful) DoseSpot_response.Result.ResultDescription = error_message;
            response.put('response_x', DoseSpot_response);
        }
    }

    public class MockWebService_upsert_allergies implements WebServiceMock {
        private List<Map<String, Object>> allergies;
        public MockWebService_upsert_allergies(List<Map<String, Object>> the_allergies) {
            allergies = the_allergies;
        }

        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            DoseSpotAPI_v12_2017_01_05.AllergyListResponse DoseSpot_response = new DoseSpotAPI_v12_2017_01_05.AllergyListResponse();
            DoseSpot_response.Allergies                           = new DoseSpotAPI_v12_2017_01_05.ArrayOfAllergy();
            DoseSpot_response.Allergies.Allergy        = new DoseSpotAPI_v12_2017_01_05.Allergy[]{};

            for (Map<String, Object> allergy_data : allergies) {
                DoseSpotAPI_v12_2017_01_05.Allergy allergy = new DoseSpotAPI_v12_2017_01_05.Allergy();
                allergy.Name                = String.valueOf(allergy_data.get('name'));
                allergy.StatusType          = String.valueOf(allergy_data.get('status'));
                allergy.PatientAllergyId    = Integer.valueOf(allergy_data.get('allergy_id'));

                DoseSpot_response.Allergies.Allergy.add(allergy);
            }
            DoseSpot_response.Result            = new DoseSpotAPI_v12_2017_01_05.Result();
            DoseSpot_response.Result.ResultCode = 'OK';
            response.put('response_x', DoseSpot_response);
        }
    }

}