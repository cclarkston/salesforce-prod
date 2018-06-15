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
 
 /* 
6/18/2015 CM
initial build coverage #'s
ctrl_refundrequest - 82%
refund_request_before - 90%
*/
@isTest
private class test_refund_request {

  private static void init() {
  	Profile p = [select id from Profile where name = 'System Administrator'];		
	List<User> my_test_users = new List<User>{new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'),new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu2@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'),
		  new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu3@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US')};
	insert my_test_users;
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c>  test_center = new List<Center_Information__c>{new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com'),new Center_Information__c(Name = 'Unknown', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com')};
	insert test_center;
	/*Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center[0].id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
	insert test_room; 
	
	lead test_lead = new Lead(Center__c = test_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	  Call_Center_Agent__c = my_test_users[0].id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
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
    a.ownerid = my_test_users[0].id;
    try {
      update a;
    }
    catch (Exception e) {
      System.debug('Error on Account insert : ' + e);
    }*/
	
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_users[1].id);
	insert test_account;

	List<Opportunity> test_ops = new List<Opportunity>{new Opportunity(accountid = test_account.id, center_information__c = test_center[0].id, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', treatment_amount__c = 30000.00, windent_patient_id__c = 'Test1'),
	    new Opportunity(accountid = test_account.id, center_information__c = test_center[0].id, name = 'Test Prosth1', exam_center__c = test_center[1].id,
	    StageName = 'Completed' , Closedate = System.today().adddays(-1), preliminary_treatment_plan__c='AO4 Upper', treatment_amount__c = 20000.00, windent_patient_id__c = 'Test2')};
	insert test_ops;
	Private_Practice_Patient__c pp = new Private_Practice_Patient__c(name='Test Private1', practice_id__c = '123313', center__c = test_center[0].id,patient_email__c = 'test@clearchoice.com');
	insert pp;		 
	List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 0.00),new CCPayment__c(payment_amount__c = 200.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 0.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 10000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Springstone', opportunity__c = test_ops[1].id, finance_fee__c = 15.00),
	    new CCPayment__c(payment_amount__c = 10000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Carecredit', opportunity__c = test_ops[1].id, finance_fee__c = 20.00)
	   };	 
	insert test_payments;
	List<Private_Practice_Payment__c> test_non_comission = new List<Private_Practice_Payment__c> {new Private_Practice_Payment__c(payment_amount__c = 0.00, payment_date__c = System.today(),
	  payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 0.00), 
	  new Private_Practice_Payment__c(payment_amount__c = 0.00, payment_date__c = System.today(), payment_status__c = 'Refunded', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 0.00),
	  new Private_Practice_Payment__c(payment_amount__c = 5000.00, payment_date__c = System.today(), payment_status__c = 'Collected', payment_type__c = 'Cash', private_practice_patient__c = pp.id, finance_fee__c = 0.00),
	  new Private_Practice_Payment__c(payment_amount__c = 1000.00, payment_date__c = System.today(), payment_status__c = 'Refunded', payment_type__c = 'Cash', private_practice_patient__c = pp.id, finance_fee__c = 0.00)
	};
	insert test_non_comission;	
  }
  
  static testMethod void test_refund_request() {
    init();
    test.starttest();
    //first prosth exam record
    Opportunity o = [select id from Opportunity where name = 'Test Op' limit 1];
    Refund_Request__c rr = new Refund_Request__c(refund_status__c = 'Incomplete', opportunity__c = o.id);
    insert rr;

    Test.setCurrentPage(Page.refund_request);
    ctrl_refundrequest controller = new ctrl_refundrequest(new ApexPages.StandardController(rr));    
    System.assertequals(controller.getdisplay_address(),true);
    System.assertequals(controller.getdisplay_carecredit(),false);
    System.assertequals(controller.getdisplay_springstone(),false);
    System.assertequals(controller.getnet_collected(),1800.00);
    controller.getdisplay_doctor_signoff();
    controller.quick_save();
    controller.getrefundlist();
    controller.check_for_issues();
    controller.submit_request();
    rr.refund_status__c='Closed';
    update rr;
    
    
    //alternat prosth exam record
    o = [select id from Opportunity where name = 'Test Prosth1' limit 1];
    rr = new Refund_Request__c(refund_status__c = 'Incomplete', opportunity__c = o.id);
    insert rr;
    controller = new ctrl_refundrequest(new ApexPages.StandardController(rr));
    //controller.getdisplay_address();
    System.assertequals(controller.getdisplay_address(),false);
    System.assertequals(controller.getdisplay_carecredit(),true);
    System.assertequals(controller.getdisplay_springstone(),true);  
    System.assertequals(controller.getnet_collected(),20000.00);
    controller.getdisplay_doctor_signoff();
    controller.getrefundlist();
    rr.amount_of_refund__c = 19000.00;
    rr.refund_type__c='Full Refund';
    update rr;
    controller.getdisplay_doctor_signoff();
    controller.getrefundlist();
    controller.check_for_issues();
    controller.submit_request();
    rr.refund_status__c='Closed';
    update rr;
    
    test.stoptest();
  }
  
  static testMethod void test_private_patient_refund_request() {
    init();
    test.starttest();
    //first private_practice
    Private_Practice_Patient__c pp = [select id from Private_Practice_Patient__c where name = 'Test Private1' limit 1];
    Refund_Request__c rr = new Refund_Request__c(refund_status__c = 'Incomplete', private_practice_patient__c = pp.id);
    insert rr;

    Test.setCurrentPage(Page.refund_request);
    ctrl_refundrequest controller = new ctrl_refundrequest(new ApexPages.StandardController(rr));    
    System.assertequals(controller.getdisplay_address(),true);
    System.assertequals(controller.getdisplay_carecredit(),false);
    System.assertequals(controller.getdisplay_springstone(),false);
    System.assertequals(controller.getnet_collected(),5000.00);
    controller.getdisplay_doctor_signoff();
    controller.quick_save();
    controller.getrefundlist();
    controller.check_for_issues();
    controller.submit_request();
    rr.refund_status__c='Closed';
    update rr;    
    
    test.stoptest();
  }
}