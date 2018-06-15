/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class test_patienthealthhistory_trigger {

  
   
	
  static testMethod void test_navigation_methods() {    
    test.startTest();
      
    Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	Center_Information__c test_center = new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3,DoseSpot_Clinic_ID__c = '1231');
	insert test_center;
	
    User my_test_user = new User(profileid = sys_admin_profile.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	insert my_test_user;
	    
    //set up test patient
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	Account test_patient = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '(719) 332-1582', 
	  RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_user.id, date_of_birth__c = System.today(), Gender__c = 'Male', BillingStreet = '1234 Test Street', 
	  BillingCity = 'Test City', BillingState = 'Colorado', BillingPostalCode = '80910');
	insert test_patient;
	
	Patient_Health_History__c health_history_form = new Patient_Health_History__c(account__c = test_patient.id, work_phone__c = '5555555555');
	insert health_history_form;
	
	//verify phone number updated for test_patient;
	test_patient = [select id,business_phone__c from account where id = :test_patient.id];
	System.assertequals(test_patient.business_phone__c,'5555555555');  
             
    test.stopTest();
  }   
  
  
}