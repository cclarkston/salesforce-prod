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
private class test_pec_ranking_snapshot {
	
	private static void init() {
    Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c>  test_center = new List<Center_Information__c>{new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', sales_region__c = 'Southwest',
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com'),new Center_Information__c(Name = 'Unknown', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', sales_region__c = 'Northeast',
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com')};
	insert test_center;
  	Profile p = [select id from Profile where name = 'System Administrator'];		
	List<User> my_test_users = new List<User>{new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', center_pec__c = test_center[0].id),new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu2@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', center_pec__c = test_center[1].id),
		  new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu3@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', center_pec__c = test_center[0].id)};
	insert my_test_users;
	
	Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center[0].id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
	insert test_room; 
	
	ClearChoice_Doctor__c cd  = new ClearChoice_Doctor__c(First_Name__c = 'First',Last_name__c = 'Last test', Active__c = true, Center_information__c = test_center[0].id, Name = 'First Last Test');
	insert cd;
	
	lead test_lead = new Lead(Center__c = test_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	  Call_Center_Agent__c = my_test_users[0].id, LastName = 'Patient369', FirstName = 'Test', Gender__c = 'Male',
	  Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555', ownerid = my_test_users[0].id);
	insert test_lead;
	Consult_Inventory__c ci_test = new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_Lead__c = test_lead.id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today().adddays(-1), Active__c = true,
	  Consult_PEC__c = my_test_users[0].id);
	  insert ci_test;

    Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_lead.id);

    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);
      
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    
    Account a = [select id,financing_result__c,ownerid from account limit 1];
    a.financing_result__c = 'Approved Less Than 50%';
    a.ownerid = my_test_users[0].id;
    try {
      update a;
    }
    catch (Exception e) {
      System.debug('Error on Account insert : ' + e);
    }
	
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_users[1].id);
	insert test_account;
	Task t = new Task(whatid = test_account.id,ownerid = my_test_users[0].id,activity_type__c = 'Outbound Call',Subject = 'Scheduled Callback',Description = ' Need to call back patient and follow up',activitydate = System.today().adddays(-1));
	insert t;
		List<Opportunity> test_ops = new List<Opportunity>{new Opportunity(accountid = test_account.id, center_information__c = test_center[0].id, name = 'Test Op', ownerid = my_test_users[0].id,
	    StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
	    new Opportunity(accountid = a.id, center_information__c = test_center[0].id, name = 'Test Refund', ownerid = my_test_users[1].id,
	    StageName = 'Cancelled Not Rescheduled' , Treatment_Amount__c = 22000.00, Cancel_Date__c = System.today(), Closedate = System.today(), cancel_reason__c = 'Testing', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2')};
	insert test_ops;	 
	List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 20.00),new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[1].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 5000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[1].id, finance_fee__c = 20.00)
	   };
	insert test_payments;	
	List<PEC_Scorecard__c> pcards = new List<PEC_Scorecard__c>{new PEC_Scorecard__c(viewed_by_pec__c = true, first_viewed_time__c = System.today(), pec_scored__c = my_test_users[1].id, total_score__c = 10, total_possible_score__c = 15, score_date__c = system.today(), scorecard_completed__c = true, qualified_scorecard__c = true ),
	  new PEC_Scorecard__c(viewed_by_pec__c = true, first_viewed_time__c = System.today(), pec_scored__c = my_test_users[0].id, total_score__c = 10, total_possible_score__c = 15, score_date__c = system.today(), scorecard_completed__c = true, qualified_scorecard__c = true)
	};
	insert pcards;
  }

  static testMethod void test_ranking_snapshot() {
    init();
    System.debug('Testing');
    test.starttest();
    //run_pec_ranking_snapshot my_controller = new run_pec_ranking_snapshot();
    try {
      run_pec_ranking_snapshot.take_ranking_snapshot();
      //run_pec_ranking_snapshot.update_cards();
    } catch(Exception e) {
      System.debug('Errored out ' + e);
    }
    System.debug('Testing 2');
    test.stoptest();
  }
}