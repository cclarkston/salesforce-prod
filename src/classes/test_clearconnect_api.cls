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
 
/*modified by cm on 5/13/2014
   added some new methods to cover the API to ClearConnect
 */
 
 /*List of classes this test unit is intended to cover:
   CConnectAPIController - 93%
   lead_referral - 81% 
   myWS - 40% (coming - just covers a couple of calls directly to ClearConnect)
 */
@isTest
private class test_clearconnect_api {

   static testMethod void insert_update_lead_tests() {    	
      Profile p = [select id from Profile where name = 'System Administrator'];		
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;
	  
      //insert our ClearConnect API Key
	  CCAPI__c api_record = new CCAPI__c(name='ClearConnect',access_key__c='eabhadfa12',user__c='ClearConnect');
	  insert api_record;	  	  	  
	  test.startTest();
	  Map<String,Object> myReturn = new Map<String,Object>();  
	   
	  PageReference pageRef = Page.CCAPI;
      Test.setCurrentPage(pageRef);
       
      CCAPI API = new CCAPI();
      pageRef.getParameters().put('APIKEY', api_record.access_key__c);           
      API = new CCAPI();	  
	  //run the call with an improper action - should error out
	  pageRef.getParameters().put('vaction', 'bad_action');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '102');
	  
	  //run the call with an improper action using the correct param - should error out
	  pageRef.getParameters().put('ccaction', 'bad_action');
	  
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '101');
	  
	  
	  //should throw an error with no params set
	  pageRef.getParameters().put('ccaction', 'leadinsert');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '109');
	  
	  //should fail d
	  pageRef.getParameters().put('firstname', 'test');
	  pageRef.getParameters().put('DistanceToCenter', '3.0');
	  pageRef.getParameters().put('Latitude', '3.0');
	  pageRef.getParameters().put('Longitude', '3.0');
	  pageRef.getParameters().put('LastName', 'testlast');
	  pageRef.getParameters().put('Phone', '5555555555');
	  pageRef.getParameters().put('Email', 'na@test.com');
	  pageRef.getParameters().put('Street', '111 test');
	  pageRef.getParameters().put('City', 'colorado Springs');
	  pageRef.getParameters().put('State', 'CO');
	  pageRef.getParameters().put('Zip', '80910');
	  pageRef.getParameters().put('Country', 'US');
	  pageRef.getParameters().put('Mobile', '5555555555');
	  pageRef.getParameters().put('DateOfBirth', '');
	  pageRef.getParameters().put('SalesAlert', 'na');
	  pageRef.getParameters().put('ExternalID', '123456');
	  pageRef.getParameters().put('PhoneNotes', 'notes');
	  pageRef.getParameters().put('RefusedtoGiveEmail', 'true');
	  pageRef.getParameters().put('CallResult', 'na');
	  pageRef.getParameters().put('DateCallBackScheduled', '5/5/2014');
	  pageRef.getParameters().put('Gender', 'male');
	  pageRef.getParameters().put('LanguageSpoken', 'English');
	  pageRef.getParameters().put('Alert', 'na');
	  pageRef.getParameters().put('DoNotCall', 'true');
	  pageRef.getParameters().put('DentalCondition', 'missing teeth');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  	  	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '105');
	  
	  pageRef.getParameters().put('DateOfBirth', '1955-5-15');
	  pageRef.getParameters().put('DateCallBackScheduled', '2015-5-5');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());	  
	  
	  system.assert(myReturn.get('Success') == 'true');
	  String wid = String.valueOf(myReturn.get('WarrantyID'));
	  
	  //fails due to invalid location code
	  pageRef.getParameters().put('LocationCode', 'na');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  	  	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '111');	  
	  
	  Center_Information__c ci = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012',
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	  insert ci;
	  Dental_Practice__c dp = new Dental_Practice__c(name='Test Practice', Location_code__c = 'Test_loc', Center_Information__c = ci.id, ClearConnect_UserName__c = 'TestUser');
	  insert dp;
	  
	  pageRef.getParameters().put('LocationCode', 'Test_loc');
	  pageRef.getParameters().put('RefusedtoGiveEmail', 'false');
	  pageRef.getParameters().put('CallCenterAgent', my_test_user.id);
	  
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  
	  //reset for updatelead	   
	  pageRef = Page.CCAPI;
      Test.setCurrentPage(pageRef);
            
      pageRef.getParameters().put('APIKEY', api_record.access_key__c);                 	  	  
	  pageRef.getParameters().put('ccaction', 'updatelead');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  
	  //should fail because we have no WID
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '201');	  
	   
	  //should fail because we used an invalid WID
	  pageRef.getParameters().put('wid', 'invalid WID');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());	  	  
	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '106');
	  
	  //should fail because we didn't provide any fields to update
	  pageRef.getParameters().put('wid', wid);
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  	  
	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '110');
	  
	  pageRef.getParameters().put('firstname', 'test');
	  pageRef.getParameters().put('DistanceToCenter', '3.0');
	  pageRef.getParameters().put('Latitude', '3.0');
	  pageRef.getParameters().put('Longitude', '3.0');
	  pageRef.getParameters().put('LastName', 'testlast');
	  pageRef.getParameters().put('Phone', '5555555555');
	  pageRef.getParameters().put('Email', 'na@test.com');
	  pageRef.getParameters().put('Street', '111 test');
	  pageRef.getParameters().put('City', 'colorado Springs');
	  pageRef.getParameters().put('State', 'CO');
	  pageRef.getParameters().put('Zip', '80910');
	  pageRef.getParameters().put('Country', 'US');
	  pageRef.getParameters().put('Mobile', '5555555555');
	  pageRef.getParameters().put('DateOfBirth', '');
	  pageRef.getParameters().put('SalesAlert', 'na');
	  pageRef.getParameters().put('ExternalID', '123456');
	  pageRef.getParameters().put('PhoneNotes', 'notes');
	  pageRef.getParameters().put('RefusedtoGiveEmail', 'true');
	  pageRef.getParameters().put('CallResult', 'na');
	  pageRef.getParameters().put('DateCallBackScheduled', '5/5/2014');
	  pageRef.getParameters().put('Gender', 'male');
	  pageRef.getParameters().put('LanguageSpoken', 'English');
	  pageRef.getParameters().put('Alert', 'na');
	  pageRef.getParameters().put('DoNotCall', 'true');
	  pageRef.getParameters().put('DentalCondition', 'missing teeth');
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  
	  system.assert(myReturn.get('Success') == 'false');
	  system.assert(myReturn.get('Error') == '108');
	  
	  pageRef.getParameters().put('DateOfBirth', '1955-5-15');
	  pageRef.getParameters().put('DateCallBackScheduled', '2015-5-5');
	  pageRef.getParameters().put('CallCenterAgent', my_test_user.id);
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());	  
	  
	  //system.assert(myReturn.get('Success') == 'true');
	  
	  test.stopTest();	  	   
    }
    
    //test for lead referral stuff
    static testMethod void lead_referral_tests() {    	
      Profile p = [select id from Profile where name = 'System Administrator'];		
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;
	  Market__c m = new Market__c (Name = 'Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com', legal_name__c = 'Test Name', Call_Center_Marketing__c = '555-555-5555', time_zone__c = 'EST');
	  insert test_center; 
	  myWs.ClearConnectCenterSetup(test_center.id);
	  Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555',
	      work_street__c = '111 work street', work_state__c = 'CO', work_city__c = 'Aurora', Work_Postal_Code__c = '80015', Date_of_Birth__c = System.today(),postalcode = '80910');
	  insert test_lead;
	  Lead test_lead2 = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555',
	      work_state__c = 'CO', work_city__c = 'Aurora', Work_Postal_Code__c = '80015', Date_of_Birth__c = System.today(),postalcode = '80910');
	  insert test_lead2;
	  Insurance_Option__c[] insurance_list = new Insurance_Option__c[]{new Insurance_Option__c(Name='Insurance 1',isactive__c=true), new Insurance_Option__c(Name='Insurance 2',isactive__c=true)};
	  insert insurance_list;
	  Dental_Practice__c[] dp_list = new Dental_Practice__c[]{new Dental_Practice__c(Monday_Open__c = true, Tuesday_Open__c = true, Wednesday_open__c = true, Friday_Open__c = true, Saturday_Open__c = true, Sunday_open__c = true, 
	      Monday_Start__c = '8:00', Tuesday_Start__c = '8:00', Wednesday_Start__c = '8:00', Thursday_Start__c = '8:00', Friday_Start__c = '8:00', Saturday_Start__c = '8:00', Sunday_Start__c = '8:00',
	      Monday_End__c = '18:00', Tuesday_End__c = '18:00', Wednesday_End__c = '18:00', Thursday_End__c = '18:00', Friday_End__c = '18:00', Saturday_End__c = '18:00', Sunday_End__c = '18:00',Phone__c = '555-555-5555',Street__c = '117 Test Street', city__c = 'Aurora', postal_code__c = '80015', state_province__c = 'CO', name='Test Practice', Location_code__c = 'Test_loc', Center_Information__c = test_center.id, ClearConnect_UserName__c = 'TestUser', refer_to_this_practice__c = true, display_to_vendor__c = true, ClearVantage_Complete__c = true, PSA_Contract_Completed__c = true, hygiene__c = true, Crown_Bridge__c = true, Teeth_Whitening__c = true, Dentures__c = true, Invisalign__c = true, Botox__c = true, Traditional_Orthodontics__c = true, Endodontics__c = true, Laser_Dentistry__c = true, Veneers__c = true),
	    new Dental_Practice__c(Monday_Open__c = true, Tuesday_Open__c = true, Wednesday_open__c = true, Friday_Open__c = true, Saturday_Open__c = true, Sunday_open__c = true, 
	      Monday_Start__c = '8:00', Tuesday_Start__c = '8:00', Wednesday_Start__c = '8:00', Thursday_Start__c = '8:00', Friday_Start__c = '8:00', Saturday_Start__c = '8:00', Sunday_Start__c = '8:00',
	      Monday_End__c = '18:00', Tuesday_End__c = '18:00', Wednesday_End__c = '18:00', Thursday_End__c = '18:00', Friday_End__c = '18:00', Saturday_End__c = '18:00', Sunday_End__c = '18:00',
	      Phone__c = '555-555-5555',Street__c = '117 Test Street', city__c = 'Aurora', postal_code__c = '80015', state_province__c = 'CO', name='Test Practice 2', Location_code__c = 'Test_loc2', Center_Information__c = test_center.id, ClearConnect_UserName__c = 'TestUser2',refer_to_this_practice__c = true, display_to_vendor__c = true, PSA_Contract_Completed__c = true, ClearVantage_Complete__c = true, hygiene__c = true, Crown_Bridge__c = true, Teeth_Whitening__c = true, Dentures__c = true, Invisalign__c = true, Botox__c = true, Traditional_Orthodontics__c = true, Endodontics__c = true, Laser_Dentistry__c = true, Veneers__c = true)};
	  insert dp_list;
	  Practice_Doctor__c pd = new Practice_Doctor__c(Middle__c = 'test mid', Title__c = 'test title', Suffix__c = 'dr.', License__c = '12345', Last_Name__c = 'test Last', First_Name__c = 'test First', Email__c = 'na@test.com', Dental_Practice__c = dp_list[0].id);
	  insert pd;	  
	  Practice_Insurance__c[] pi_list = new Practice_Insurance__c[] {new Practice_Insurance__c(Insurance_Option__c = insurance_list[0].id,Dental_Practice__c = dp_list[0].id),
	  	new Practice_Insurance__c(Insurance_Option__c = insurance_list[1].id,Dental_Practice__c = dp_list[0].id),
	  	new Practice_Insurance__c(Insurance_Option__c = insurance_list[0].id,Dental_Practice__c = dp_list[1].id)};	  
	  insert pi_list;	  
	  
      //insert our ClearConnect API Key
	  test.startTest();  	   
	  PageReference pageRef = Page.referral_lookup;
      Test.setCurrentPage(pageRef);
      myWs.newCCOinfo(dp_list[0].id);
      
      ApexPages.StandardController con = new ApexPages.StandardController(test_lead);  	
      lead_referral lead_ref = new lead_referral(con);
      test_center.time_zone__c = null;
      update test_center;
      lead_ref = new lead_referral(con);
      test_center.time_zone__c = 'CST';
      update test_center;
      lead_ref = new lead_referral(con);
      test_center.time_zone__c = 'MST';
      update test_center;
      lead_ref = new lead_referral(con);
      test_center.time_zone__c = 'PST';
      update test_center;
      lead_ref = new lead_referral(con);
      
      List<SelectOption> address_options = lead_ref.getnear_options();
      System.assert(address_options.size()==2);
      
      List<Selectoption> insurance_options = lead_ref.getinsurance_options_list();
      System.assert(insurance_options.size()==3);
      lead_ref.Insurance_Plan = insurance_list[0].id;
      
      lead_ref.Hygiene = true;
      lead_ref.search_referral();
      lead_ref.getpractice_count();
      System.debug('Referral Practice Size : ' + lead_ref.referral_practice.size());
      
      lead_ref.getmonday_hours();
      lead_ref.gettuesday_hours();
      lead_ref.getwednesday_hours();
      lead_ref.getthursday_hours();
      lead_ref.getfriday_hours();
      lead_ref.getsaturday_hours();
      lead_ref.getsunday_hours();
      
      lead_ref.ReferralPrint_link();
      lead_ref.next_practice_option();
      lead_ref.search_referral();
      lead_ref.getmonday_hours();
      lead_ref.gettuesday_hours();
      lead_ref.getwednesday_hours();
      lead_ref.getthursday_hours();
      lead_ref.getfriday_hours();
      lead_ref.getsaturday_hours();
      lead_ref.getsunday_hours();
      
      lead_ref.ReferralPrint_link();
      
      lead_ref.previous_practice_option();
      
      lead_ref.ref_out();
      //lead_ref.rout.Referral_Outcome__c = 'test';
      //lead_ref.ref_out();
      lead_ref.rout.Referral_Outcome__c = 'Transfer_Successful';
      lead_ref.ref_out();
            
      lead_ref.Crown_Bridge = true;
      lead_ref.Dentures = true;
      lead_ref.Invisalign = true;
      lead_ref.botox = true;
      lead_ref.Traditional_Ortho = true;
      lead_ref.Endontics = true;
      lead_ref.Laser_Dentistry = true;
      lead_ref.Veneers = true;
      lead_ref.Teeth_Whitening = true;
      lead_ref.search_referral();
      lead_ref.ReferralPrint_link();      
      lead_ref.ref_declined();
      
      lead_ref.address_near = 'Work';
      lead_ref.search_referral();
      System.debug('Referral Practice Size ' + lead_ref.referral_practice.size());
      
      lead_ref.refuse_out();      
      lead_ref.getrefused_list();
      lead_ref.search_referral();
                  
      //should hit the no results section
      lead_ref.Wisdom_Teeth = true;
      lead_ref.search_referral();
      lead_ref.Hygiene = false;
      lead_ref.search_referral();
      lead_ref.crown_bridge=false;
      lead_ref.search_referral();
      lead_ref.teeth_whitening=false;
      lead_ref.search_referral();
      lead_ref.dentures=false;
      lead_ref.search_referral();
      lead_ref.invisalign=false;
      lead_ref.search_referral();
      lead_ref.botox=false;
      lead_ref.search_referral();
      lead_ref.endontics=false;
      lead_ref.search_referral();
      lead_ref.Laser_Dentistry=false;
      lead_ref.search_referral();
      lead_ref.veneers=false;
      lead_ref.search_referral();
      
      con = new ApexPages.StandardController(test_lead2);  	
      lead_ref = new lead_referral(con);
      
      Insurance_options = lead_ref.getinsurance_options_list();
      lead_ref.Insurance_Plan = insurance_list[0].id;
      
      lead_ref.Hygiene = true;
      lead_ref.address_near = 'Work';
      lead_ref.search_referral();
      lead_ref.callback_change();
      
      test.stopTest();
    }
    
    //test for lead referral stuff
    static testMethod void account_referral_tests() {    	
      Profile p = [select id from Profile where name = 'System Administrator'];		
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;
	  Market__c m = new Market__c (Name = 'Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com', legal_name__c = 'Test Name', Call_Center_Marketing__c = '555-555-5555', 
		  time_zone__c = 'EST');
	  insert test_center; 
	  myWs.ClearConnectCenterSetup(test_center.id);
	  Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555',
	      work_street__c = '111 work street', work_state__c = 'CO', work_city__c = 'Aurora', Work_Postal_Code__c = '80015', Date_of_Birth__c = System.today(),postalcode = '80910');
	  insert test_lead;
	  Database.LeadConvert lc = new Database.LeadConvert();
	  lc.setLeadId(test_lead.id);

      LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      lc.setConvertedStatus(convertStatus.MasterLabel);
      
      Database.LeadConvertResult lcr = Database.convertLead(lc);
      System.assert(lcr.isSuccess());
      Account test_account = [select id,name,center__c,billingstreet,billingstate,billingcity,billingpostalcode,work_street__c,work_state__c,work_city__c,work_postal_code__c,refused_referrals__c from Account where id = :lcr.getAccountID()];
	  Lead test_lead2 = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555',
	      work_state__c = 'CO', work_city__c = 'Aurora', Work_Postal_Code__c = '80015', Date_of_Birth__c = System.today(),postalcode = '80910');
	  insert test_lead2;
	  lc = new Database.LeadConvert();
	  lc.setLeadId(test_lead2.id);

      lc.setConvertedStatus(convertStatus.MasterLabel);
      
      lcr = Database.convertLead(lc);
      System.assert(lcr.isSuccess());
      Account test_account2 = [select id,name,center__c,billingstreet,billingstate,billingcity,billingpostalcode,work_street__c,work_state__c,work_city__c,work_postal_code__c,refused_referrals__c from Account where id = :lcr.getAccountID()];
	  
	  Insurance_Option__c[] insurance_list = new Insurance_Option__c[]{new Insurance_Option__c(Name='Insurance 1',isactive__c=true), new Insurance_Option__c(Name='Insurance 2',isactive__c=true)};
	  insert insurance_list;
	  Dental_Practice__c[] dp_list = new Dental_Practice__c[]{new Dental_Practice__c(Monday_Open__c = true, Tuesday_Open__c = true, Wednesday_open__c = true, Friday_Open__c = true, Saturday_Open__c = true, Sunday_open__c = true, 
	      Monday_Start__c = '8:00', Tuesday_Start__c = '8:00', Wednesday_Start__c = '8:00', Thursday_Start__c = '8:00', Friday_Start__c = '8:00', Saturday_Start__c = '8:00', Sunday_Start__c = '8:00',
	      Monday_End__c = '18:00', Tuesday_End__c = '18:00', Wednesday_End__c = '18:00', Thursday_End__c = '18:00', Friday_End__c = '18:00', Saturday_End__c = '18:00', Sunday_End__c = '18:00',
	      Phone__c = '555-555-5555',Street__c = '117 Test Street', city__c = 'Aurora', postal_code__c = '80015', state_province__c = 'CO', name='Test Practice', Location_code__c = 'Test_loc', 
	      Center_Information__c = test_center.id, ClearConnect_UserName__c = 'TestUser', refer_to_this_practice__c = true, display_to_vendor__c = true, PSA_Contract_Completed__c = true, ClearVantage_Complete__c = true, hygiene__c = true, Crown_Bridge__c = true, Teeth_Whitening__c = true, 
	      Dentures__c = true, Invisalign__c = true, Botox__c = true, Traditional_Orthodontics__c = true, Endodontics__c = true, Laser_Dentistry__c = true, Veneers__c = true),
	    new Dental_Practice__c(Monday_Open__c = true, Tuesday_Open__c = true, Wednesday_open__c = true, Friday_Open__c = true, Saturday_Open__c = true, Sunday_open__c = true, 
	      Monday_Start__c = '8:00', Tuesday_Start__c = '8:00', Wednesday_Start__c = '8:00', Thursday_Start__c = '8:00', Friday_Start__c = '8:00', Saturday_Start__c = '8:00', Sunday_Start__c = '8:00',
	      Monday_End__c = '18:00', Tuesday_End__c = '18:00', Wednesday_End__c = '18:00', Thursday_End__c = '18:00', Friday_End__c = '18:00', Saturday_End__c = '18:00', Sunday_End__c = '18:00',
	      Phone__c = '555-555-5555',Street__c = '117 Test Street', city__c = 'Aurora', postal_code__c = '80015', state_province__c = 'CO', name='Test Practice 2', Location_code__c = 'Test_loc2', Center_Information__c = test_center.id, ClearConnect_UserName__c = 'TestUser2',refer_to_this_practice__c = true,ClearVantage_Complete__c = true, PSA_Contract_Completed__c = true, hygiene__c = true, Crown_Bridge__c = true, Teeth_Whitening__c = true, Dentures__c = true, Invisalign__c = true, Botox__c = true, Traditional_Orthodontics__c = true, Endodontics__c = true, Laser_Dentistry__c = true, Veneers__c = true)};
	  insert dp_list;
	  Practice_Doctor__c pd = new Practice_Doctor__c(Suffix__c = 'Dr.', License__c = '12345', Last_Name__c = 'Test Last', First_Name__c = 'Test First', Email__c = 'na@test.com', Dental_Practice__c = dp_list[0].id);
	  insert pd;	  
	  Practice_Insurance__c[] pi_list = new Practice_Insurance__c[] {new Practice_Insurance__c(Insurance_Option__c = insurance_list[0].id,Dental_Practice__c = dp_list[0].id),
	  	new Practice_Insurance__c(Insurance_Option__c = insurance_list[1].id,Dental_Practice__c = dp_list[0].id),
	  	new Practice_Insurance__c(Insurance_Option__c = insurance_list[0].id,Dental_Practice__c = dp_list[1].id)};	  
	  insert pi_list;	  
	  
      //insert our ClearConnect API Key
	  test.startTest();  	   
	  PageReference pageRef = Page.referral_lookup_account;
      Test.setCurrentPage(pageRef);
      myWs.newCCOinfo(dp_list[0].id);
      
      ApexPages.StandardController con = new ApexPages.StandardController(test_account);  	
      account_referral lead_ref = new account_referral(con);
      
      //try all timezones
      test_center.time_zone__c = 'CST';
      update test_center;
      lead_ref = new account_referral(con);
      test_center.time_zone__c = 'MST';
      update test_center;
      lead_ref = new account_referral(con);
      test_center.time_zone__c = 'PST';
      update test_center;
      lead_ref = new account_referral(con);
      
      List<SelectOption> address_options = lead_ref.getnear_options();
      System.assert(address_options.size()==2);
      
      List<Selectoption> insurance_options = lead_ref.getinsurance_options_list();
      System.assert(insurance_options.size()==3);
      lead_ref.Insurance_Plan = insurance_list[0].id;
      
      lead_ref.Hygiene = true;
      lead_ref.search_referral();
      lead_ref.getpractice_count();
      System.debug('Referral Practice Size : ' + lead_ref.referral_practice.size());
      
      lead_ref.getmonday_hours();
      lead_ref.gettuesday_hours();
      lead_ref.getwednesday_hours();
      lead_ref.getthursday_hours();
      lead_ref.getfriday_hours();
      lead_ref.getsaturday_hours();
      lead_ref.getsunday_hours();
      
      lead_ref.ReferralPrint_link();
      lead_ref.next_practice_option();
      lead_ref.search_referral();
      lead_ref.getmonday_hours();
      lead_ref.gettuesday_hours();
      lead_ref.getwednesday_hours();
      lead_ref.getthursday_hours();
      lead_ref.getfriday_hours();
      lead_ref.getsaturday_hours();
      lead_ref.getsunday_hours();
      
      lead_ref.ReferralPrint_link();
      
      lead_ref.previous_practice_option();
      
      lead_ref.ref_out();
      //lead_ref.rout.Referral_Outcome__c = 'test';
      lead_ref.rout.Referral_Outcome__c = 'Transfer_Successful';
      lead_ref.ref_out();
            
      lead_ref.Crown_Bridge = true;
      lead_ref.Dentures = true;
      lead_ref.Invisalign = true;
      lead_ref.botox = true;
      lead_ref.Traditional_Ortho = true;
      lead_ref.Endontics = true;
      lead_ref.Laser_Dentistry = true;
      lead_ref.Veneers = true;
      lead_ref.Teeth_Whitening = true;
      lead_ref.search_referral();
      lead_ref.ReferralPrint_link();      
      lead_ref.ref_declined();
      
      lead_ref.address_near = 'Work';
      lead_ref.search_referral();
      System.debug('Referral Practice Size ' + lead_ref.referral_practice.size());
      
      lead_ref.refuse_out();      
      lead_ref.getrefused_list();
      lead_ref.search_referral();
                  
      //should hit the no results section
      lead_ref.Wisdom_Teeth = true;
      lead_ref.search_referral();
      lead_ref.Hygiene = false;
      lead_ref.search_referral();
      lead_ref.crown_bridge=false;
      lead_ref.search_referral();
      lead_ref.teeth_whitening=false;
      lead_ref.search_referral();
      lead_ref.dentures=false;
      lead_ref.search_referral();
      lead_ref.invisalign=false;
      lead_ref.search_referral();
      lead_ref.botox=false;
      lead_ref.search_referral();
      lead_ref.endontics=false;
      lead_ref.search_referral();
      lead_ref.Laser_Dentistry=false;
      lead_ref.search_referral();
      lead_ref.veneers=false;
      lead_ref.search_referral();
      
      con = new ApexPages.StandardController(test_account2);  	
      lead_ref = new account_referral(con);
      
      Insurance_options = lead_ref.getinsurance_options_list();
      lead_ref.Insurance_Plan = insurance_list[0].id;
      
      lead_ref.Hygiene = true;
      lead_ref.address_near = 'Work';
      lead_ref.search_referral();
      lead_ref.callback_change();
      
      test.stopTest();
    }
    
    static testMethod void print_referral_tests() {    	
      Profile p = [select id from Profile where name = 'System Administrator'];		
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;
	  Market__c m = new Market__c (Name = 'Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com', legal_name__c = 'Test Name', Call_Center_Marketing__c = '555-555-5555', time_zone__c = 'EST');
	  insert test_center; 
	  myWs.ClearConnectCenterSetup(test_center.id);
	  Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555',
	      work_street__c = '111 work street', work_state__c = 'CO', work_city__c = 'Aurora', Work_Postal_Code__c = '80015', Date_of_Birth__c = System.today(),postalcode = '80910');
	  insert test_lead;
	  Database.LeadConvert lc = new Database.LeadConvert();
	  lc.setLeadId(test_lead.id);

      LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
      lc.setConvertedStatus(convertStatus.MasterLabel);
      
      Database.LeadConvertResult lcr = Database.convertLead(lc);
      System.assert(lcr.isSuccess());
      Account test_account = [select id,name,center__c,billingstreet,billingstate,billingcity,billingpostalcode,work_street__c,work_state__c,work_city__c,work_postal_code__c,refused_referrals__c from Account where id = :lcr.getAccountID()];
	  Lead test_lead2 = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555',
	      work_state__c = 'CO', work_city__c = 'Aurora', Work_Postal_Code__c = '80015', Date_of_Birth__c = System.today(),postalcode = '80910');
	  insert test_lead2;
	  
	  Insurance_Option__c[] insurance_list = new Insurance_Option__c[]{new Insurance_Option__c(Name='Insurance 1',isactive__c=true), new Insurance_Option__c(Name='Insurance 2',isactive__c=true)};
	  insert insurance_list;
	  Dental_Practice__c[] dp_list = new Dental_Practice__c[]{new Dental_Practice__c(Phone__c = '555-555-5555',Street__c = '117 Test Street', city__c = 'Aurora', postal_code__c = '80015', state_province__c = 'CO', name='Test Practice', Location_code__c = 'Test_loc', Center_Information__c = test_center.id, ClearConnect_UserName__c = 'TestUser', refer_to_this_practice__c = true, display_to_vendor__c = true, ClearVantage_Complete__c = true, PSA_Contract_Completed__c = true, hygiene__c = true, Crown_Bridge__c = true, Teeth_Whitening__c = true, Dentures__c = true, Invisalign__c = true, Botox__c = true, Traditional_Orthodontics__c = true, Endodontics__c = true, Laser_Dentistry__c = true, Veneers__c = true),
	    new Dental_Practice__c(Monday_Open__c = true, Tuesday_Open__c = true, Wednesday_open__c = true, Friday_Open__c = true, Saturday_Open__c = true, Sunday_open__c = true, 
	      Monday_Start__c = '8:00', Tuesday_Start__c = '8:00', Wednesday_Start__c = '8:00', Thursday_Start__c = '8:00', Friday_Start__c = '8:00', Saturday_Start__c = '8:00', Sunday_Start__c = '8:00',
	      Monday_End__c = '18:00', Tuesday_End__c = '18:00', Wednesday_End__c = '18:00', Thursday_End__c = '18:00', Friday_End__c = '18:00', Saturday_End__c = '18:00', Sunday_End__c = '18:00',
	      Phone__c = '555-555-5555',Street__c = '117 Test Street', city__c = 'Aurora', postal_code__c = '80015', state_province__c = 'CO', name='Test Practice 2', Location_code__c = 'Test_loc2', Center_Information__c = test_center.id, ClearConnect_UserName__c = 'TestUser2',refer_to_this_practice__c = true,display_to_vendor__c = true,ClearVantage_Complete__c = true, PSA_Contract_Completed__c = true, hygiene__c = true, Crown_Bridge__c = true, Teeth_Whitening__c = true, Dentures__c = true, Invisalign__c = true, Botox__c = true, Traditional_Orthodontics__c = true, Endodontics__c = true, Laser_Dentistry__c = true, Veneers__c = true)};
	  insert dp_list;
	  Practice_Doctor__c pd = new Practice_Doctor__c(Suffix__c = 'Dr.', License__c = '12345', Last_Name__c = 'Test Last', First_Name__c = 'Test First', Email__c = 'na@test.com', Dental_Practice__c = dp_list[0].id);
	  insert pd;	  
	  Practice_Insurance__c[] pi_list = new Practice_Insurance__c[] {new Practice_Insurance__c(Insurance_Option__c = insurance_list[0].id,Dental_Practice__c = dp_list[0].id),
	  	new Practice_Insurance__c(Insurance_Option__c = insurance_list[1].id,Dental_Practice__c = dp_list[0].id),
	  	new Practice_Insurance__c(Insurance_Option__c = insurance_list[0].id,Dental_Practice__c = dp_list[1].id)};	  
	  insert pi_list;	  
	  
      //insert our ClearConnect API Key
	  test.startTest();  	   
	  PageReference pageRef = Page.referral_printout;
      Test.setCurrentPage(pageRef);
      ctrl_referral_print print_con = new ctrl_referral_print();
      pageRef.getParameters().put('dpid', dp_list[0].id);
      pageRef.getParameters().put('lid', test_lead2.id);
      pageRef.getParameters().put('hygiene', '1');
      pageRef.getParameters().put('crown_bridge', '1');
      pageRef.getParameters().put('teeth_whitening', '1');
      pageRef.getParameters().put('dentures', '1');
      pageRef.getParameters().put('invisalign', '1');
      pageRef.getParameters().put('botox', '1');
      pageRef.getParameters().put('traditional_ortho', '1');
      pageRef.getParameters().put('endontics', '1');
      pageRef.getParameters().put('laser_dentistry', '1');
      pageRef.getParameters().put('veneers', '1');
      pageRef.getParameters().put('wisdom_teeth', '1');
      Test.setCurrentPage(pageRef);
      
      print_con = new ctrl_referral_print();
      print_con.getpatient_name();
      print_con.getpatient_phone();
      print_con.getpatient_street();
      print_con.getpatient_city();
      print_con.getpatient_postal();
      print_con.getdentist_name();
      print_con.getMapId();
      print_con.getmonday_hours();
      print_con.gettuesday_hours();
      print_con.getwednesday_hours();
      print_con.getthursday_hours();
      print_con.getfriday_hours();
      print_con.getsaturday_hours();
      print_con.getsunday_hours();
      
      pageRef = null;
      pageRef = Page.referral_printout;
      System.debug('Current Params : ' + pageRef.getParameters());
      
      pageRef.getParameters().put('dpid', dp_list[0].id);
      pageRef.getParameters().put('aid', test_account.id);
      System.debug('Current Params : ' + pageRef.getParameters());
      pageRef.getParameters().put('hygiene', '1');
      pageRef.getParameters().put('crown_bridge', '1');
      pageRef.getParameters().put('teeth_whitening', '1');
      pageRef.getParameters().put('dentures', '1');
      pageRef.getParameters().put('invisalign', '1');
      pageRef.getParameters().put('botox', '1');
      pageRef.getParameters().put('traditional_ortho', '1');
      pageRef.getParameters().put('endontics', '1');
      pageRef.getParameters().put('laser_dentistry', '1');
      pageRef.getParameters().put('veneers', '1');
      pageRef.getParameters().put('wisdom_teeth', '1');
      Test.setCurrentPage(pageRef);
      
      print_con = new ctrl_referral_print();
      print_con.getpatient_name();
      print_con.getpatient_phone();
      print_con.getpatient_street();
      print_con.getpatient_city();
      print_con.getpatient_postal();
      print_con.getdentist_name();
      print_con.getMapId();
      print_con.getmonday_hours();
      print_con.gettuesday_hours();
      print_con.getwednesday_hours();
      print_con.getthursday_hours();
      print_con.getfriday_hours();
      print_con.getsaturday_hours();
      print_con.getsunday_hours();
      
      Referral_Out__c rout = new Referral_Out__c(Procedure_Interested_In__c='Hygiene;Crown & Bridge;Teeth Whitening;Dentures;Invisalign;Botox;Traditional Orthodontics;Endontics;Veneers;Wisdom Teeth', Lead__c = test_lead2.id, Dental_Practice__c = dp_list[1].id);
      insert rout;
      pageRef = null;
      pageRef = Page.referral_printout;
      System.debug('Current Params : ' + pageRef.getParameters());
      
      pageRef.getParameters().put('rout', rout.id);
      System.debug('Current Params : ' + pageRef.getParameters());
      Test.setCurrentPage(pageRef);
      print_con = new ctrl_referral_print();
      print_con.getpatient_name();
      print_con.getpatient_phone();
      print_con.getpatient_street();
      print_con.getpatient_city();
      print_con.getpatient_postal();
      print_con.getdentist_name();
      print_con.getMapId();
      print_con.getmonday_hours();
      print_con.gettuesday_hours();
      print_con.getwednesday_hours();
      print_con.getthursday_hours();
      print_con.getfriday_hours();
      print_con.getsaturday_hours();
      print_con.getsunday_hours();
      
      test.stopTest();
    }
    
}