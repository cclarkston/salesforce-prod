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
private class test_guid_generator {
	
  private static void init() {
  	Profile p = [select id from Profile where name = 'System Administrator'];		
	User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		 timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	insert my_test_user;
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	Center_Information__c  test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	insert test_center;
	Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
	insert test_room; 
	
	lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	  Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	  Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
	insert test_lead;
	Consult_Inventory__c ci_test = new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_Lead__c = test_lead.id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true);
	  insert ci_test;

    Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_lead.id);

    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);
      
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    
    Account a = [select id,financing_result__c,ownerid from account limit 1];
    a.financing_result__c = 'Approved Less Than 50%';
    a.ownerid = my_test_user.id;
    try {
      update a;
    }
    catch (Exception e) {
      System.debug('Error on Account insert : ' + e);
    }
	
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_user.id);
	insert test_account;
	Task t = new Task(whatid = test_account.id,ownerid = Userinfo.getuserid(),activity_type__c = 'Sales Call',Subject = 'Scheduled Callback',Description = ' Need to call back patient and follow up',activitydate = System.today().adddays(-1));
	insert t;
	
	Opportunity test_ops = new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op',
	   StageName = 'Scheduled', Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', windent_patient_id__c = 'Test1');
	insert test_ops;	 	
  }

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        init();
        Opportunity o = [select id from Opportunity limit 1];
        guidGenerator.generateCheckCode();
        guidGenerator.generateSignInCode(o.id);
        guidGenerator.generateWID();
    }
}