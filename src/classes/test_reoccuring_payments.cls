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
private class test_reoccuring_payments {
	
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
	Center_Information__c  test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	insert test_center;
	
	lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	  Call_Center_Agent__c = my_test_users[0].id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	  Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
	insert test_lead;

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
	Account test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_users[1].id);
	insert test_account;
	List<Opportunity> test_ops = new List<Opportunity>{new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
	    new Opportunity(accountid = a.id, center_information__c = test_center.id, name = 'Test Refund',
	    StageName = 'Cancelled Not Rescheduled' , Cancel_Date__c = System.today(), Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2')};
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
  }

  static testMethod void myUnitTest() {
    init();
    test.starttest();
    PageReference pageref = new PageReference('/apex/sales_ranking');
    Test.setCurrentPage(pageRef);      
    ctrl_reoccuring_payment rec_payment_ctrl = new ctrl_reoccuring_payment();
    Opportunity o = [Select id,windent_patient_id__c from Opportunity where windent_patient_id__c != null limit 1];
    pageRef.getParameters().put('oid',o.id);
    
    rec_payment_ctrl = new ctrl_reoccuring_payment();
    rec_payment_ctrl.getpayment_status_list();
    rec_payment_ctrl.getinterval_list();
    
    Integer current_payment_count = rec_payment_ctrl.getcurrent_payment_list().size();
    rec_payment_ctrl.rec_num_payments = 2;
    rec_payment_ctrl.rec_payment.payment_amount__c = 100.00;
    rec_payment_ctrl.create_rec_payments();
    
    //System.assertEquals(rec_payment_ctrl.getcurrent_payment_list().size() - current_payment_count,2);
    rec_payment_ctrl.rec_payment_interval_type='Week';
    rec_payment_ctrl.create_rec_payments();
    //System.assertEquals(rec_payment_ctrl.getcurrent_payment_list().size() - current_payment_count,4);
    
    rec_payment_ctrl.rec_payment_interval_type='Days';
    rec_payment_ctrl.create_rec_payments();
    //System.assertEquals(rec_payment_ctrl.getcurrent_payment_list().size() - current_payment_count,6);
    
    test.stoptest();  
  }
}