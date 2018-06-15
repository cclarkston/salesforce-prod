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
private class test_net_promoter_score {

  private static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	Center_Information__c test_center =new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', street_2__c = 'test2', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3);
	insert test_center;
	
    User my_test_user = new User(profileid = sys_admin_profile.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	insert my_test_user;
    
    //set up some test patients
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	List<Account> test_patients = new List<Account> {
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_user.id, date_of_birth__c = System.today().addyears(-24)),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_user.id, email__c = 'tpatient_aclearchoice.com', date_of_birth__c = System.today().addyears(-41)),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_user.id, date_of_birth__c = System.today().addyears(-81))
	};
	insert test_patients;
		
	//set up some test patient opportunities	
	List<Opportunity> test_ops = new List<Opportunity> {
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_center.id, name = 'Test Op', ownerid = my_test_user.id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_center.id, name = 'Test Op2', ownerid = my_test_user.id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[1].id, center_information__c = test_center.id, name = 'Test Op3', ownerid = my_test_user.id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[2].id, center_information__c = test_center.id, name = 'Test Op4', ownerid = my_test_user.id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1')
	};
	insert test_ops;	                    
  }
  
  static testMethod void test_net_promoter_score() {
    init();
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/patient_satisfaction_survery');
    Test.setCurrentPage(pageRef);    
    netpromoter_score nps_controller = new netpromoter_score();
    
    //test missing params
    try {
      nps_controller.record_net_promoter_score();
    } catch (Exception e) {
      //should fail - no parameters
    }
    
    Opportunity o = [select id from Opportunity limit 1];
    
    //test invalid score format
    pageRef.getParameters().put('oid',o.id);
    pageRef.getParameters().put('nps','ABCDE');
    try {
      nps_controller.record_net_promoter_score();
    } catch (Exception e) {
      //should fail - score is not a number
    }
    
    //test invalid score value
    pageRef.getParameters().put('nps','20');
    try {
      nps_controller.record_net_promoter_score();
    } catch (Exception e) {
      //should fail - score is not between 0 and 10
    }
        
    //valid controller instance
    pageRef.getParameters().put('nps','8');
    try {
      nps_controller.record_net_promoter_score();
    } catch (Exception e) {
      //should fail - score is not between 0 and 10
    }
    
    //verify opportunity has been updated
    o = [select id,net_promoter_score__c,net_promoter_time__c from Opportunity where id = :o.id];
    System.assertEquals(o.net_promoter_score__c,8);

    test.stopTest();
  }    
  
}