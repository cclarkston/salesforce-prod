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
private class test_salesranking {


  @testSetup private static void init() {
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
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Unknown Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com'),new Center_Information__c(Name = 'Chicago', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Chicago Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com')
	  };
	insert test_center;
	Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center[0].id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
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
    }

	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_users[1].id);
	insert test_account;
    // ID rtype = [Select ID From RecordType Where sObjectType = 'Task' and Name = 'Standard'].id;
	// Task t = new Task(whatid = test_account.id,ownerid = Userinfo.getuserid(),activity_type__c = 'Sales Call', RecordTypeID = rtype, Subject = 'Scheduled Callback',Description = ' Need to call back patient and follow up',activitydate = System.today().adddays(-1));
    Task t = new Task(whatid = test_account.id,ownerid = Userinfo.getuserid(),activity_type__c = 'Sales Call', Subject = 'Scheduled Callback',Description = ' Need to call back patient and follow up',activitydate = System.today().adddays(-1));
	insert t;
	List<Consult_Inventory__c> ci_list = new List<Consult_Inventory__c> {
	  new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(),
	  Scheduled_account__c = test_account.id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(),
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true),
	  new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(),
	  Scheduled_account__c = a.id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(),
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true)};
	insert ci_list;
	List<Opportunity> test_ops = new List<Opportunity>{new Opportunity(accountid = test_account.id, center_information__c = test_center[0].id, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', windent_patient_id__c = 'Test1', has_treatment_option__c = true,Treatment_Amount__c = 6000.00),
	    new Opportunity(accountid = test_account.id, center_information__c = test_center[0].id, name = 'Test Op', exam_center__c = test_center[0].id,
	    StageName = 'Scheduled', Closedate = System.today(),  Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', windent_patient_id__c = 'Test1', has_treatment_option__c = true,Treatment_Amount__c = 6000.00),
	    new Opportunity(accountid = a.id, center_information__c = test_center[0].id, name = 'Test Refund', exam_center__c = test_center[1].id,
	    StageName = 'Cancelled Not Rescheduled' , Cancel_Date__c = System.today(), Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', windent_patient_id__c = 'Test2', has_treatment_option__c = true,Treatment_Amount__c = 6000.00),
	    new Opportunity(accountid = a.id, center_information__c = test_center[0].id, name = 'Test Refund', 
	    StageName = 'Cancelled Not Rescheduled' , Cancel_Date__c = System.today(), Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', windent_patient_id__c = 'Test2', has_treatment_option__c = true,Treatment_Amount__c = 6000.00)};
	insert test_ops;
	List<CCPayment__c> test_payments = new List<CCPayment__c>{
		new CCPayment__c(payment_amount__c = 8000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 20.00),
		new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
		new CCPayment__c(payment_amount__c = 8000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[1].id, finance_fee__c = 20.00),
		new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[1].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[2].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 8000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[2].id, finance_fee__c = 20.00),
	    new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[3].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 8000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[3].id, finance_fee__c = 20.00)
	   };
	insert test_payments;
  }

  //static test for ctrl_callbacks
  static testmethod void callback_test() {
  	//init();
  	test.starttest();
  	PageReference pageref = new PageReference('/apex/callbacks');
  	ctrl_callbacks controller = new ctrl_callbacks();
  	List<Account> account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account limit 20];
  	controller.process_account_results(account_results,'Testing Queue');
  	List<ctrl_callbacks.patient_callback> pc_list = controller.getreturn_list();
  	for(ctrl_callbacks.patient_callback pc : pc_list) {
  	  Account a = pc.consult_record;
  	  Task t = pc.last_task;
  	  String squeue = pc.queue_source;
  	  pc.getTaskDate();
  	  pc.getTaskType();
  	  pc.getTaskSubject();
  	  pc.getTaskDescription();
  	}
  	controller.is_traveller = false;
  	controller.refresh_return_list();
  	controller.is_traveller = true;
  	controller.refresh_return_list();
  	test.stoptest();
  }

  static testMethod void salesrank_test() {
  	//init();
    test.starttest();
    PageReference pageref = new PageReference('/apex/sales_ranking');
    Test.setCurrentPage(pageRef);
    ctrl_salesranking controller = new ctrl_salesranking();
    List<selectoption> possible_intervals = controller.getIntervalOptions();
    System.assert(possible_intervals.size()>1);
    Decimal sold_dollars = controller.getsold_dollars();
    Decimal cancelled_dollars = controller.getcancelled_dollars();
    Decimal collected = controller.getcollected_dollars();
    Decimal refunded = controller.getrefunded_dollars();
    Decimal gp_collected = controller.getgp_collected_fees();
    Decimal gp_refunded = controller.getgp_refunded_fees();
    controller.report_interval = 'this_year';
    controller.change_report_interval();
    List<ctrl_salesranking.finance_rank> finance_pec_ranks = controller.getfinance_list();
    finance_pec_ranks.sort();
    for(ctrl_salesranking.finance_rank fr : finance_pec_ranks) {
      fr.update_finance_count(1);
    }
    finance_pec_ranks = controller.getcenter_finance_list();
    finance_pec_ranks.sort();
    for(ctrl_salesranking.finance_rank fr : finance_pec_ranks) {
      fr.update_finance_count(1);
    }


    controller.display_all_center();
    controller.display_all_pec();
    List<ctrl_salesranking.pec_ranking> rank_list = controller.getpec_start_dollars();
    for(ctrl_salesranking.pec_ranking pr : rank_list) {
      System.debug('Name : ' + pr.display_name + ' Value : ' + pr.display_value);
    }
    rank_list = controller.getcenter_start_dollars();
    for(ctrl_salesranking.pec_ranking pr : rank_list) {
      System.debug('Name : ' + pr.display_name + ' Value : ' + pr.display_value);
    }
    controller.display_all_finance_center();
    controller.display_all_finance_pec();

    rank_list = controller.getpec_collected_dollars();
    for(ctrl_salesranking.pec_ranking pr : rank_list) {
      System.debug('Name : ' + pr.display_name + ' Value : ' + pr.display_value + ' Close Rate : ' + pr.getclose_rate());
    }
    rank_list = controller.getcenter_collected_dollars();
    for(ctrl_salesranking.pec_ranking pr : rank_list) {
      System.debug('Name : ' + pr.display_name + ' Value : ' + pr.display_value + ' Close Rate : ' + pr.getclose_rate());
    }
    controller.display_all_collected_center();
    controller.display_all_collected_pec();

    controller.getpec_revenue_per_start();
    controller.getcenter_revenue_per_start();
    controller.getpec_collections_per_consult();
    controller.getcenter_collections_per_consult();

    test.stoptest();
  }

  static testMethod void bigboard_test() {
    //init();
    test.starttest();
    ctrl_leadership_board controller = new ctrl_leadership_board();
    controller.getConsultStarts();
    controller.getStarts();
    controller.getStartsCancelled();
    controller.getCollected();
    controller.getRefunded();
    test.stoptest();
  }
}