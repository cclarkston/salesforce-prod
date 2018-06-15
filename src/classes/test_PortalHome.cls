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
 *
 *  Code Coverage
 *  ctrl_portal_home - 78%
 */
@isTest
private class test_PortalHome {
  static Center_Information__c test_center; 
  static Dental_Practice__c dp; 
  static User my_test_user;
  static User my_portal_test_user;
  
  private static void init() {
    Market__c m = new Market__c(name = 'test Market');
    insert m;
    test_center = new Center_Information__c(Name = 'Testing Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
      directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
      cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
      doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
      send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
    insert test_center;
    
    
    Profile p = [select id from Profile where name = 'System Administrator'];       
    my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', Practice_Privileges_Provider__c='clearviewtv');
    insert my_test_user;
    dp = new Dental_Practice__c(name='Test Practice',primary_contact_name__c = 'Pcontact', Street__c = '111 Test Street', City__c = 'Colorado Springs',refer_to_this_practice__c = true, display_to_vendor__c = true,
        PSA_Contract_Completed__c = true, State_Province__c = 'CO', center_information__c = test_center.id, Postal_code__c = '91112', practice_website__c = 'www.test.com', phone__c = '5555555555', primary_contact_email__c = 'na@test.com', practice_management_software__c = 'Dentrix');
    insert dp;
    Practice_Doctor__c pd = new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com',phone__c = '1112223333');
    insert pd; 
    
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Doctor Referral Account'].id;
    String pprid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
    
    //create a few accounts and leads to work with
    List<Lead> test_leads = new List<Lead> {new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = userinfo.getuserid(), LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555', referral_office__c = dp.id),
      new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = userinfo.getuserid(), LastName = 'Patient', FirstName = 'NoOffice', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555', referral_office__c = dp.id)};
    insert test_leads;
    List<Account> test_accounts = new List<Account>{new Account(FirstName = 'Test', LastName = 'Account3', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish',referral_office__c = dp.id), 
      new Account(FirstName = 'Test2', LastName = 'Account4', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish', referral_office__c = dp.id),
      new Account(FirstName = 'Test3', LastName = 'Account5', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish', referral_office__c = dp.id)};
    insert test_accounts;
    List<Opportunity> olist = new List<Opportunity> {
      new Opportunity(accountid = test_accounts[0].id, center_information__c = test_center.id, name = 'Test Op',StageName = 'Scheduled', final_referral_track__c = 'Track I', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1', prosth_exam_paid_date__c = System.today()),
      new Opportunity(accountid = test_accounts[1].id, center_information__c = test_center.id, name = 'Test Op 2',StageName = 'Scheduled', final_referral_track__c = 'Track II', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='Single', Windent_Patient_ID__c = 'Testing 2', prosth_exam_paid_date__c = System.today()),
      new Opportunity(accountid = test_accounts[2].id, center_information__c = test_center.id, name = 'Test Op',StageName = 'Scheduled', final_referral_track__c = 'Track III', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='DBL AO4', Windent_Patient_ID__c = 'Testing 3', prosth_exam_paid_date__c = System.today())
    };
    insert olist;  
    List<CCPayment__c> test_payments = new List<CCPayment__c>{
    	new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = olist[0].id, finance_fee__c = 20.00),
    	new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = olist[2].id, finance_fee__c = 20.00),
	    new CCPayment__c(payment_amount__c = 8000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = olist[1].id, finance_fee__c = 20.00),
	    new CCPayment__c(payment_amount__c = 5000.00, payment_date__c = System.today(),payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = olist[1].id, finance_fee__c = 20.00)
	   };
	insert test_payments;      
    
    Account test_account = new Account(Name = 'Test Account2', Center__c = test_center.id, RecordTypeId = rid,dental_practice_partner__c = dp.id);
    insert test_account;
    Contact test_contact = new Contact(accountid = test_account.id, firstname = 'partner', lastname = 'portal test2');
    insert test_contact;
    p = [select id from Profile where name = 'Dental Practice Partner'];                  
    my_portal_test_user = new User(profileid = p.id, email = 'testportal@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'tpor', lastname = 'TestPortal2', localesidkey='en_US', country='United States', username='testportal@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',  contactid = test_contact.id);
    insert my_portal_test_user;                
  }
  
  static testMethod void PortalInit() {
    init();    
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/portal_home');
    Test.setCurrentPage(pageref);
    ctrl_portal_home home = new ctrl_portal_home();
    home.getPractice_List();
    home.getCenter_List();
    home.getreferral_track_list();
    home.getclinical_status_list();
    home.getJSON_practice_mix();
    home.getJSON_national_mix();
    
    System.runAs(my_portal_test_user) {
      home = new ctrl_portal_home();	      
    }
   
    test.stopTest(); 
  }
  
  static testMethod void Portalsorts() {
  	init();    
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/portal_home');
    Test.setCurrentPage(pageref);
    ctrl_portal_home home = new ctrl_portal_home();
    
    Integer list_size = home.getreferral_list_size();
    home.gp_sort();
    home.gp_sort();
    home.collected_sort();
    home.collected_sort();
    home.collected_sort();
    home.sold_sort();
    home.sold_sort();
    home.track_sort();
    home.track_sort();
    home.treatment_sort();
    home.treatment_sort();
    home.cstatus_sort();
    home.cstatus_sort();
    home.name_sort();
    home.name_sort();
    home.date_sort();
    home.date_sort();
        
    
    test.stopTest();
  }
  
  static testMethod void SummaryCalls() {
  	init();    
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/portal_home');
    Test.setCurrentPage(pageref);
    ctrl_portal_home home = new ctrl_portal_home();
    
    
    home.getYTD_patients();
    home.getlifetime_patients();
    home.getYTD_gpfee();
    home.getlifetime_gpfee();
    home.getYTD_close_rate();
    home.getlifetime_close_rate();
    home.getYTD_lead_consult_rate();
    home.getlifetime_lead_consult_rate();
    
    test.stopTest();
  }
  
  static testMethod void MiscCalls() {
  	init();    
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/portal_home');
    Test.setCurrentPage(pageref);
    ctrl_portal_home home = new ctrl_portal_home();
    List<ctrl_portal_home.referral_lead> rlist = home.referral_list;
    for(ctrl_portal_home.referral_lead rl : rlist) {
      rl.getlink_id();
      rl.getreferral_date();
      rl.getnum_contacts();
      rl.getfirst_contact();
      rl.getlast_contact();
      rl.getreferral_practice_name();
      rl.getreferral_name();
      rl.getreferral_track();
      rl.gettreatment_plan();
      rl.getclinical_status();
    }
    
    home.name_filter = 'Test';
    home.run_filtered_search();
    home.next();
    home.prev();
    home.getpaged_referrals();
    home.referral_partner_id = 'All';
    home.change_practice();
    home.run_filtered_search();
    
    home.clinical_status_filter = 'Single';
    home.track_filter = 'Track I';
    home.run_filtered_search();
    
    test.stopTest();
  }
  
  static testMethod void Center_Calls() {
  	init();    
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/portal_home');
    Test.setCurrentPage(pageref);
    ctrl_portal_home home = new ctrl_portal_home();
    home.center_id = test_center.id;
    home.show_center_view();        
    List<ctrl_portal_home.referral_lead> rlist = home.referral_list;

    home.name_filter = 'Test';
    home.run_filtered_search();
    home.next();
    home.prev();
    home.getpaged_referrals();
    home.center_id = 'All';
    home.change_practice();
    home.run_filtered_search();
    
    home.clinical_status_filter = 'Single';
    home.track_filter = 'Track I';
    home.run_filtered_search();
    
    test.stopTest();
  }
}