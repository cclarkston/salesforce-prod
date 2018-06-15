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
 *
 * Major Code Coverage
 *  Lead_Referral_In      82%
 */
@isTest
private class test_lead_referral {
  static Center_Information__c test_center; 
  static Dental_Practice__c dp; 
  static User my_test_user;
  static User my_portal_test_user;
  static Consult_Inventory__c ci;
  static Market__c m;
  
  private static void init() {
    m = new Market__c(name = 'test Market');
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
    
    Account test_account = new Account(Name = 'Test Account2', Center__c = test_center.id, RecordTypeId = rid,dental_practice_partner__c = dp.id);
    insert test_account;
    Contact test_contact = new Contact(accountid = test_account.id, firstname = 'partner', lastname = 'portal test2');
    insert test_contact;
    p = [select id from Profile where name = 'Dental Practice Partner'];                 
    my_portal_test_user = new User(profileid = p.id, email = 'testportal@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'tpor', lastname = 'TestPortal2', localesidkey='en_US', country='United States', username='testportal@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',  contactid = test_contact.id);
    insert my_portal_test_user;  
    
    //create a consult block
    Schedule_Templates__c test_template = new Schedule_Templates__c(Name = 'Test Any Day Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true, 
      Saturday__c = true,  Sunday__c = true);
    insert test_template;
    Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id);
    insert test_room;
    ci = new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '9',Start_Minute__c = '30',End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5);
    insert ci;                      
  }

  static testMethod void lead_referral() {
    // TO DO: implement unit test
    test.startTest();
    init();
           
    //start as regular user
    Center_Information__c unknown_center = new Center_Information__c(Name = 'Unknown', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
      directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
      cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
      doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
      send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
    insert unknown_center;
    PageReference pageref = new PageReference('/apex/new_referral');
    Test.setCurrentPage(pageref);
    lead_referral_in ctrl = new lead_referral_in();
               
    System.runas(my_portal_test_user)  {
      ctrl = new lead_referral_in();	      
      ctrl.create_new_referral();
      ctrl.referral_in.email='test@clearchoice.com';
      ctrl.referral_in.firstname = 'Test';
      ctrl.referral_in.lastname = 'Referral';
      ctrl.referral_in.gender__c = 'Male';
      ctrl.referral_in.phone = '7195555555';      
      ctrl.create_new_referral();
    
      String cid = [select id from recordtype where sobjectType = 'Campaign' and name = 'Generic Campaign'].id;
      List<Campaign> c = new List<Campaign> {new Campaign(name = 'Unknown', status = 'In Progress',startdate=System.today().adddays(-3),recordtypeid = cid),
        new Campaign(name = 'Referral Portal Campaign', phone_number__c = 'Referral Portal', status = 'In Progress',startdate=System.today().adddays(-3),recordtypeid = cid)};
      insert c;
      ctrl.create_new_referral();
 
      ctrl.getcontact_methods();  
      ctrl.getbetween_times();
         
      ctrl.getcontact_num();
      ctrl.getschedule_num();
      ctrl.update_lead_reminder_preference();
       
      ctrl.getsearch_consult_results();
      ctrl.find_next_avaliable();
      for(lead_consultschedule.next_consult nc : ctrl.getsearch_consult_results()) {
      	pageRef.getParameters().put('aid',nc.apt_block.id);
      }
      
      ctrl.schedule_consult();
      ctrl.update_lead_reminder_preference();
      ctrl.getformatted_consult_time();
      ctrl.schedule_consult();
    }    
    
    test.stopTest();
  }
}