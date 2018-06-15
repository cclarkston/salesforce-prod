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
 *  Major Code Coverage
 *  portal_referral_out  95%
 *
 */
@isTest
private class test_portal_referral_out {
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
    List<Referral_Out__c> rout_list = new List<Referral_Out__c> {
      new Referral_out__c(lead__c = test_leads[0].id, Dental_Practice__c = dp.id, preferred_callback_time__c = 'Evenings', Procedure_Interested_In__c = 'Hygiene', Referral_Notes__c = 'Test Notes'),
      new Referral_out__c(lead__c = test_leads[1].id, Dental_Practice__c = dp.id, preferred_callback_time__c = 'Morning', Procedure_Interested_In__c = 'Dentures', Referral_Notes__c = 'Test Notes')
    };
    insert rout_list;
       
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
  
  static testMethod void test_Referral_Out() {
    init();    
    test.startTest();
    
    PageReference pageref = new PageReference('/apex/portal_home');
    Test.setCurrentPage(pageref);
    portal_referral_out ctrl = new portal_referral_out();
    pageRef.getParameters().put('pid',null);
    ctrl = new portal_referral_out();
    pageRef.getParameters().put('pid','All');
    ctrl = new portal_referral_out();
    
    ctrl.getreferral_list_size();
    for(portal_referral_out.referral_out ro : ctrl.getpaged_referrals()) {
      ro.getreferral_practice();
      ro.getreferral_name();
      ro.getreferral_phone();
      ro.getreferral_email();
      ro.getreferral_street();
      ro.getreferral_state();
      ro.getreferral_city();
      ro.getreferral_link();
      ro.getreferral_date();
      ro.getreferral_postal();
      ro.getreferral_procedure();
      ro.getreferral_callback_time();
    }
     
    ctrl.referral_partner_id = dp.id;
    ctrl.change_practice();
    
    ctrl.next();
    ctrl.prev();
    
    ctrl.name_sort();
    ctrl.name_sort();
    ctrl.name_sort();
    ctrl.phone_sort();
    ctrl.phone_sort();
    ctrl.email_sort();
    ctrl.email_sort();
    ctrl.procedure_sort();
    ctrl.procedure_sort();
    ctrl.date_sort();
    ctrl.date_sort();
    
    ctrl.getpractice_list();
    
        
    //csv stuff
    ctrl.getfile_header();
    ctrl.getfilename();
    ctrl.getnew_line();
    ctrl.getcsv_detail();
    
    System.runAs(my_portal_test_user) {
      ctrl = new portal_referral_out();	      
    }
    
    test.stopTest();
  }
}