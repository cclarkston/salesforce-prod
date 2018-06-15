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
 *  Major Code Coverage
 *  afterAccount       -  94%
 *  newPracticeFeed    -  92%
 *  afterFeedComment   - 100%
 *  afterFeedItem      - 100%
 * 
 */
@isTest
private class testSharingTriggers {
  static Center_Information__c test_center; 
  static Dental_Practice__c dp; 
  static Lead test_lead;
    
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
    User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', Practice_Privileges_Provider__c='clearviewtv');
    insert my_test_user;
    dp = new Dental_Practice__c(name='Test Practice',primary_contact_name__c = 'Pcontact', Street__c = '111 Test Street', City__c = 'Colorado Springs',refer_to_this_practice__c = true, display_to_vendor__c = true,
        PSA_Contract_Completed__c = true, State_Province__c = 'CO', center_information__c = test_center.id, Postal_code__c = '91112', practice_website__c = 'www.test.com', phone__c = '5555555555', primary_contact_email__c = 'na@test.com', practice_management_software__c = 'Dentrix');
    insert dp;
    Practice_Doctor__c pd = new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com',phone__c = '1112223333');
    insert pd; 
    
    test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555', referral_office__c = dp.id);
        //Refused_to_give_email__c=true
    insert test_lead;                  
  }

  static testMethod void LeadTriggerTest() {
    init();    
    test.startTest();
    System.debug('Starting LeadTriggerTest');
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Doctor Referral Account'].id;
    Account test_account = new Account(Name = 'Test Account1', Center__c = test_center.id, RecordTypeId = rid, dental_practice_partner__c = dp.id);
    insert test_account;  
    
    String pprid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;       
    Account office_account =  new Account(FirstName = 'Test2', LastName = 'Account4', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish', referral_office__c = dp.id);
    insert office_account; 
     
    Contact test_contact = new Contact(accountid = test_account.id, firstname = 'partner', lastname = 'portal test2');
    insert test_contact;
    Profile p = [select id from Profile where name = 'Partner Community User'];
    System.debug('Dental Practice : ' + dp);
    System.debug('Account ' + test_account);
    System.debug('Account ' + test_account.dental_practice_partner__c);                 
    User my_portal_test_user = new User(profileid = p.id, email = 'testportal@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'tpor', lastname = 'TestPortal1', localesidkey='en_US', country='United States', username='testportal@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',  contactid = test_contact.id);
    insert my_portal_test_user;
    
    List<Lead> test_leads = new List<Lead> {new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = userinfo.getuserid(), LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555', referral_office__c = dp.id),
      new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = userinfo.getuserid(), LastName = 'Patient', FirstName = 'NoOffice', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555')};
    insert test_leads;
    test_leads[1].referral_office__c = dp.id;
    update test_leads;
    
    FeedItem testFeed = new FeedItem(Body='Testing Feeds', ParentId = test_leads[0].Id, Type='AdvancedTextPost', linkurl = 'www.salesforce.com', title = 'Salesforce');
    insert testFeed;
    FeedComment testcomment = new FeedComment(CommentBody='Test Comment', feedItemId = testfeed.Id);
    insert testcomment;
              
    test.stopTest();
  }
  
  static testMethod void AccountTriggerTest() {
    init();    
    test.startTest();
       
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Doctor Referral Account'].id;
    String pprid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
    
    Account test_account = new Account(Name = 'Test Account2', Center__c = test_center.id, RecordTypeId = rid);
    insert test_account;
    Contact test_contact = new Contact(accountid = test_account.id, firstname = 'partner', lastname = 'portal test2');
    insert test_contact;
    Profile p = [select id from Profile where name = 'Partner Community User'];        
    System.debug('Dental Practice : ' + dp);
    System.debug('Account ' + test_account);             
    User my_portal_test_user = new User(profileid = p.id, email = 'testportal@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'tpor', lastname = 'TestPortal2', localesidkey='en_US', country='United States', username='testportal@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',  contactid = test_contact.id);
    insert my_portal_test_user;
        
    List<Lead> test_leads = new List<Lead> {new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = userinfo.getuserid(), LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555', referral_office__c = dp.id),
      new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = userinfo.getuserid(), LastName = 'Patient', FirstName = 'NoOffice', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555')};
    insert test_leads;
    List<Account> test_accounts = new List<Account>{new Account(FirstName = 'Test', LastName = 'Account3', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish'), 
      new Account(FirstName = 'Test2', LastName = 'Account4', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish', referral_office__c = dp.id)};
    insert test_accounts;
    
    test_account.dental_practice_partner__c = dp.id;
    update test_account;
    
    Account laccount = new Account(FirstName = 'Test2', LastName = 'Account4', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish', referral_office__c = dp.id);
    insert laccount;

    test_accounts[0].referral_office__c = dp.id;
    update test_accounts;  
    
    FeedItem testFeed = new FeedItem(Body='Testing Feeds', ParentId = laccount.Id, Type='AdvancedTextPost', linkurl = 'www.salesforce.com', title = 'Salesforce');
    insert testFeed;
    FeedComment testcomment = new FeedComment(CommentBody='Test Comment', feedItemId = testfeed.Id);
    insert testcomment;
    
    Opportunity o = new Opportunity(accountid = laccount.id, center_information__c = test_center.id, name = 'Test Op', 
	    StageName = 'Scheduled', final_referral_track__c = 'Track I', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1', prosth_exam_paid_date__c = System.today());
	insert o;
	
	testFeed = new FeedItem(Body='Testing Feeds', ParentId = o.Id, Type='AdvancedTextPost', linkurl = 'www.salesforce.com', title = 'Salesforce');
    insert testFeed;
    testcomment = new FeedComment(CommentBody='Test Comment', feedItemId = testfeed.Id);
    insert testcomment;
              
    test.stopTest();
  }
  
  static TestMethod void FeedTesting() {
  	init();    
    test.startTest();
    
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Doctor Referral Account'].id;
    
    Account test_account = new Account(Name = 'Test Account2', Center__c = test_center.id, RecordTypeId = rid, dental_practice_partner__c = dp.id);
    insert test_account;
    Contact test_contact = new Contact(accountid = test_account.id, firstname = 'partner', lastname = 'portal test2');
    insert test_contact;
    Profile p = [select id from Profile where name = 'Partner Community User'];        
    System.debug('Dental Practice : ' + dp);
    System.debug('Account ' + test_account);             
    User my_portal_test_user = new User(profileid = p.id, email = 'testportal@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'tpor', lastname = 'TestPortal2', localesidkey='en_US', country='United States', username='testportal@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',  contactid = test_contact.id);
    insert my_portal_test_user;
    
    newPracticeFeed.create_new_practice_feed(my_portal_test_user.id, dp.name, test_center.name);    
    newPracticeFeed.newCenterFeedPost(test_center.id, 'Test Post');
    newPracticeFeed.newPracticeFeedPostLink(dp.id, 'Test Post w link', 'www.cnn.com', 'CNN');
    newPracticeFeed.newPracticeFeedPost(dp.id,'Test Post');    
    newPracticeFeed.newCenterFeedPostLink(test_center.id, 'Test Post', 'www.cnn.com', 'CNN');
    newPracticeFeed.create_new_practice_feed(my_portal_test_user.id, dp.name, test_center.name);
    
    Zip_Demographic__c zd = new Zip_Demographic__c(zipcode__c = '80015');
    insert zd;
    
    test_account.billingpostalcode = '80015';
    update test_account;  
            
    test.stopTest();
  }
  
  static TestMethod void AptHistoryTesting() {
  	init();
  	test.startTest();
  	
  	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Doctor Referral Account'].id;
  	String pprid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
    
    Account test_account = new Account(Name = 'Test Account2', Center__c = test_center.id, RecordTypeId = rid, dental_practice_partner__c = dp.id);
    insert test_account;
    Contact test_contact = new Contact(accountid = test_account.id, firstname = 'partner', lastname = 'portal test2');
    insert test_contact;
    Profile p = [select id from Profile where name = 'Partner Community User'];        
    System.debug('Dental Practice : ' + dp);
    System.debug('Account ' + test_account);             
    User my_portal_test_user = new User(profileid = p.id, email = 'testportal@clearchoice.com', emailencodingkey = 'UTF-8',
        alias = 'tpor', lastname = 'TestPortal2', localesidkey='en_US', country='United States', username='testportal@clearchoice.com',
        timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',  contactid = test_contact.id);
    insert my_portal_test_user;
    
    newPracticeFeed.create_new_practice_feed(my_portal_test_user.id, dp.name, test_center.name);
    
    //create a consult block
    Schedule_Templates__c test_template = new Schedule_Templates__c(Name = 'Test Any Day Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true, 
      Saturday__c = true,  Sunday__c = true);
    insert test_template;
    Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id);
    insert test_room;
    Consult_Inventory__c ci = new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '9',Start_Minute__c = '30',End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5);
    insert ci;
         
    //create a referral account
    Account laccount = new Account(FirstName = 'Test2', LastName = 'Account4', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = pprid, Language_Spoken__c = 'Spanish', referral_office__c = dp.id);
    insert laccount;
    
    //generate a list of apt history entries covering all of the various action types
    List<Apt_History__c> ah_list = new List<Apt_History__c> {new Apt_History__c(Consult_Inventory__c = ci.id, Lead__c = test_lead.id, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled'),
    	new Apt_History__c(Consult_Inventory__c = ci.id, Account__c = laccount.id, action__c = 'Scheduled', notes__c = 'Consultation has been rescheduled'),
    	new Apt_History__c(Consult_Inventory__c = ci.id, Lead__c = test_lead.id, action__c = 'Arrived', notes__c = 'test'),
    	new Apt_History__c(Consult_Inventory__c = ci.id, Lead__c = test_lead.id, action__c = 'No Show', notes__c = 'test'),
    	new Apt_History__c(Consult_Inventory__c = ci.id, Lead__c = test_lead.id, action__c = 'Left', notes__c = 'test'),
    	new Apt_History__c(Consult_Inventory__c = ci.id, Lead__c = test_lead.id, action__c = 'Cancel', notes__c = 'test'),
    	new Apt_History__c(Consult_Inventory__c = ci.id, Lead__c = test_lead.id, action__c = 'Completed', notes__c = 'test')};
    insert ah_list;

  	test.stopTest();
  }
}