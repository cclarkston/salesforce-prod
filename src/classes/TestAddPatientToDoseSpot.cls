@isTest
private class TestAddPatientToDoseSpot {
    static User current_user;

    private static void init(String DoseSpot_patient_ID) {
        Center_Information__c center = new_center();
        create_account(DoseSpot_patient_ID, center);
        current_user = new_user();
    }


    static testMethod void NameTestLater() {
      String DoseSpot_patient_ID = '111111';
      init(null);
      Integer mock_status = 302;
      Map<String, String> mock_headers = new Map<String, String>{'Location' => '/secure/PatientDetail.aspx?PatientID=' + DoseSpot_patient_ID};
      String mock_body = '';
      Account patient = patient('Test Patient');
      // String expected = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&PatientID=111111&Prefix=&FirstName=Test&MiddleName=&LastName=Patient&Suffix=&DateOfBirth=01-01-2000&Gender=Male&MRN=&Address1=123 Test Street&Address2=&City=Test City&State=Teststate&ZipCode=12345&PrimaryPhone=(303) 123-4567&PrimaryPhoneType=Primary&PharmacyID=';
      // String expected = 'http://my.staging.dosespot.com/LoginSingleSignOn.aspx?SingleSignOnClinicId=123&SingleSignOnUserId=666&SingleSignOnPhraseLength=32&SingleSignOnCode=12345678901234567890123456789012XX4ECXavvh%2F269l9w0dWAXpCSEuKNuJ2iGFT2Vl5bx4yRE2xc4Z200No4EpxYMJzLuhihyTmRidjUpBIjMkFjQ&SingleSignOnUserIdVerify=l2zj9NNWuDAOS7KV75yedwjVYsKDwTDfqatuxW0iGm6mG4%2BA1IskJQIqVkSRhvJtIZkrOE1vYw%2BbBIcLYvnhdA&PatientID=111111&Prefix=&FirstName=Test&MiddleName=&LastName=Patient&Suffix=&DateOfBirth=01-01-2000&Gender=Male&MRN=&Address1=123+Test+Street&Address2=&City=Test+City&State=Teststate&ZipCode=12345&PrimaryPhone=%28303%29+123-4567&PrimaryPhoneType=Primary&PharmacyID=';

      System.runAs(current_user){
          Test.setMock(HttpCalloutMock.class, new MockHttp_DoseSpot_patient_URL(mock_status, mock_headers, mock_body));
          Test.startTest();
            AddPatientToDoseSpot.DoseSpot_patient_URL(patient.Id);
          Test.stopTest();
      }
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
}