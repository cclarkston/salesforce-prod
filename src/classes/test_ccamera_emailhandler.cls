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
private class test_ccamera_emailhandler {
  	
  static testMethod void test_consult_camera_email_handler() {
    Market__c m = new Market__c(Name = 'Test Market');
    Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = '200 E Colfax Ave', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	insert test_center; 
    Profile p = [select id from Profile where name = 'System Administrator'];		
	User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
	  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
	  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	insert my_test_user;  
	Lead[] test_confirmation = new Lead[] { 
	  new Lead(Inbound_Call__c = 'Dental Inquiry',  Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown1', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'English', Confirmed_Appointment__c = false,phone='1111111111',email = 'leaddupe@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry', 
	    Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown2', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today(), Language_Spoken__c = 'English', Confirmed_Appointment__c = true,phone='1111111111',email = 'leaddupe@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry', Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown3', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'Spanish', Confirmed_Appointment__c = false,phone='1111111111',email = 'leadnodupe@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry', Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown3', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'Spanish', Confirmed_Appointment__c = false,phone='1111111111',email = 'leadnodupe1@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry',  Call_Center_Agent__c = my_test_user.id, LastName = 'Camera Consult', FirstName = 'No Match', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'English', Confirmed_Appointment__c = false,phone='1111111111',email = 'nmcc@clearchoice.com')
	    };
	insert test_confirmation;
	Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
	insert test_room; 
	
	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
	
	test.startTest();
	// Create a new email and envelope object 
    Messaging.InboundEmail email  = new Messaging.InboundEmail(); 
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
    email.plainTextBody = '{"patient_email_address":"leaddupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}'; 
    email.fromAddress ='cmcdowell@test.com';  
    email.subject = 'Test Consult Camera'; 
    ccamera_emailhandler ce = new ccamera_emailhandler(); 

    Messaging.InboundEmailResult result = ce.handleInboundEmail(email, env); 
    
    email.plainTextBody = '{"patient_email_address":"leadnodupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_confirmation[0].id);
    
    lc.setConvertedStatus(convertStatus.MasterLabel);
      
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    
    lc.setLeadId(test_confirmation[1].id);
    lcr = Database.convertLead(lc);
    lc.setLeadId(test_confirmation[2].id);
    lcr = Database.convertLead(lc);
    
    result = ce.handleInboundEmail(email, env);
    email.plainTextBody = '{"patient_email_address":"leaddupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    Consult_Inventory__c ci_test = new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_Lead__c = test_confirmation[3].id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true,
	  Consult_PEC__c = my_test_user.id);
	insert ci_test;
	email.plainTextBody = '{"patient_email_address":"leadnodupe1@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);    
    
    test.stoptest();
  }
  
  static testMethod void test_consult_camera_email_handler_2() {
    Market__c m = new Market__c(Name = 'Test Market');
    Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = '200 E Colfax Ave', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	insert test_center; 
    Profile p = [select id from Profile where name = 'System Administrator'];		
	User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
	  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
	  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	insert my_test_user;  
	Lead[] test_confirmation = new Lead[] { 
	  new Lead(Inbound_Call__c = 'Dental Inquiry',  Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown1', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'English', Confirmed_Appointment__c = false,phone='1111111111',email = 'leaddupe@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry', 
	    Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown2', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today(), Language_Spoken__c = 'English', Confirmed_Appointment__c = true,phone='1111111111',email = 'leaddupe@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry', Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown3', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'Spanish', Confirmed_Appointment__c = false,phone='1111111111',email = 'leadnodupe@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry', Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown3', FirstName = 'Test', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'Spanish', Confirmed_Appointment__c = false,phone='1111111111',email = 'leadnodupe1@clearchoice.com'),
	  new Lead(Inbound_Call__c = 'Dental Inquiry',  Call_Center_Agent__c = my_test_user.id, LastName = 'Camera Consult', FirstName = 'No Match', Gender__c = 'Male',
	    Call_Result__c = 'Consultation Scheduled', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'English', Confirmed_Appointment__c = false,phone='1111111111',email = 'nmcc@clearchoice.com')
	    };
	insert test_confirmation;
	Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
	insert test_room;
	
	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
	
	Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_confirmation[0].id);
   
    lc.setConvertedStatus(convertStatus.MasterLabel);
      
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    
    lc.setLeadId(test_confirmation[1].id);
    lcr = Database.convertLead(lc);
    lc.setLeadId(test_confirmation[2].id);
    lcr = Database.convertLead(lc);
    
    Account a = [select id from Account where personemail = 'leadnodupe@clearchoice.com'];
	
	Consult_Inventory__c ci_test = new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_Lead__c = test_confirmation[3].id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true,
	  Consult_PEC__c = my_test_user.id);
	insert ci_test;
	
	Consult_Inventory__c[] ci_list = new Consult_Inventory__c[] {new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_account__c = test_confirmation[0].convertedaccountid, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true,
	  Consult_PEC__c = my_test_user.id),
      new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_account__c = test_confirmation[1].convertedaccountid, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true,
	  Consult_PEC__c = my_test_user.id)
    };
    insert ci_list;
	
	test.startTest();
	// Create a new email and envelope object 
    Messaging.InboundEmail email  = new Messaging.InboundEmail(); 
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
    email.plainTextBody = '{"patient_email_address":"leaddupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}'; 
    email.fromAddress ='cmcdowell@test.com';  
    email.subject = 'Test Consult Camera'; 
    ccamera_emailhandler ce = new ccamera_emailhandler(); 

    Messaging.InboundEmailResult result = ce.handleInboundEmail(email, env); 
    
    email.plainTextBody = '{"patient_email_address":"leadnodupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    
    result = ce.handleInboundEmail(email, env);
    email.plainTextBody = '{"patient_email_address":"leaddupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    
	email.plainTextBody = '{"patient_email_address":"leadnodupe1@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
	ci_test = new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_account__c = a.id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today(), Active__c = true,
	  Consult_PEC__c = my_test_user.id);
	insert ci_test;
	email.plainTextBody = '{"patient_email_address":"leadnodupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    
    email.plainTextBody = '{"patient_email_address":"leaddupe@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    email.plainTextBody = '{"patient_email_address":"nomatch@clearchoice.com","video_id":"517","part_number":"1","confirmation_token":"RyyzxB1yaTtzEvoA-r2G"}';
    result = ce.handleInboundEmail(email, env);
    
    test.stoptest();
  }
}