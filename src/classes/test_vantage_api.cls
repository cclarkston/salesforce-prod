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

 /*modified by cm on 4/9/2014
   added some new methods to cover the API to Vanatge (tempuriOrg.cls) as well as the trigger (Dental_Practic_Changes.trigger) and myWS callout
 */

 /*List of classes this test unit is intended to cover:
   VantageAPIController - 92%
   tempuriOrg - 100%
   Dental_Practice_Changes - 50%
   myWS - 7% (just intended to cover one call from the trigger above)
 */
@isTest
private class test_vantage_api {

    static testMethod void myUnitTest() {
      //create a test lead so we have a warranty id to query
	  Profile p = [select id from Profile where name = 'System Administrator'];
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;

	  Market__c m = new Market__c(name='Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  Send_Gold_Lead_Text_Message__c = true, SMS_Text_Phone_3_Gold_Leads__c = '5555555555', SMS_Text_Phone_2_Gold_Leads__c = '5555555555', SMS_Text_Phone_1_Gold_Leads__c = '5555555555' );
	  insert test_center;

      Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV',
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com');
	  insert test_lead;
	  String wid = [select warranty_id__c from lead where id = :test_lead.id].warranty_id__c;
	  test.startTest();

	  //grab our vantage API Key
	  CCAPI__c api_record = new CCAPI__c(name='Vantage',access_key__c='eabhadfa12',user__c='Vantage');
	  insert api_record;
	  Map<String,Object> myReturn = new Map<String,Object>();

	  PageReference pageRef = Page.CCAPI;
      Test.setCurrentPage(pageRef);

       CCAPI API = new CCAPI();
      pageRef.getParameters().put('APIKEY', api_record.access_key__c);
      //run the call now - we should error out because no vacation was specfied
      API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  System.debug('My Return : ' + myReturn);
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '004');

	  //run the call with an improper action - should have the same result
	  pageRef.getParameters().put('vaction', 'bad_action');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '101');

	  //should fail due to no WID
	  pageRef.getParameters().put('vaction', 'widlookup');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '201');

	  //should fail due to invalid WID
	  pageRef.getParameters().put('WID', 'bad_wid');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '202');

	  //should be a success
	  pageRef.getParameters().put('WID', wid);
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  // system.assert(myReturn.get('Success') == 'true');
	  test.stopTest();
    }


    static testMethod void testDental_office_insert_update() {
      //create a test lead so we have a warranty id to query
	  Profile p = [select id from Profile where name = 'System Administrator'];
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;

	  Market__c m = new Market__c(name='Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  location_code__c = 'TestLoc', Send_Gold_Lead_Text_Message__c = true, SMS_Text_Phone_3_Gold_Leads__c = '5555555555', SMS_Text_Phone_2_Gold_Leads__c = '5555555555', SMS_Text_Phone_1_Gold_Leads__c = '5555555555');
	  insert test_center;
      Test.startTest();

      Dental_Practice__c dp = new Dental_Practice__c(name='Test Practice', Street__c = '1234 Test Street', State_Province__c = 'CO', Primary_Contact_Name__c = 'Test Contact',
        Primary_Contact_Email__c = 'test@clearchoice.com', Practice_Website__c = 'www.clearchoice.com', Postal_Code__c = '80910', Phone__c = '5555555555',
        Fax__c = '5555555555', Country__c = 'USA', City__c = 'Denver', Alt_Phone__c = '5555555555', Refer_to_this_practice__c = false, display_to_vendor__c = false, ClearVantage_Complete__c = false, PSA_Contract_Completed__c = false, center_information__c = test_center.id);
      insert dp;

      Dental_Practice__c dp2 = new Dental_Practice__c(name='Test Practice', Street__c = '1234 Test Street', State_Province__c = 'CO', Primary_Contact_Name__c = 'Test Contact',
        Primary_Contact_Email__c = 'test@clearchoice.com', Practice_Website__c = 'www.clearchoice.com', Postal_Code__c = '80910', Phone__c = '5555555555',
        Fax__c = '5555555555', Country__c = 'USA', City__c = 'Denver', Alt_Phone__c = '5555555555', Refer_to_this_practice__c = false, display_to_vendor__c = false, ClearVantage_Complete__c = true, PSA_Contract_Completed__c = false, Vantage_OfficeID__c = '3',center_information__c = test_center.id);
      insert dp2;

      Practice_Doctor__c pd = new Practice_Doctor__c(Title__c = 'Dr', Phone__c = '5555555555', Last_Name__c = 'Test Last', First_Name__c = 'First', Email__c = 'test@clearchoice.com',
        Dental_Practice__c = dp.id, Alt_Phone__c = '5555555555');
      insert pd;

      Practice_Doctor__c pd2 = new Practice_Doctor__c(Title__c = 'Dr', Phone__c = '5555555555', Last_Name__c = 'Test Last', First_Name__c = 'First', Email__c = 'test@clearchoice.com',
        Dental_Practice__c = dp2.id, Alt_Phone__c = '5555555555');
      insert pd2;

      dp.Refer_to_this_practice__c = true;
      dp.display_to_vendor__c = true;
      dp.PSA_Contract_Completed__c = true;
      dp.ClearVantage_Complete__c = true;
      update dp;

     /* try {
        dp2.Refer_to_this_practice__c = true;
        dp2.PSA_Contract_Completed__c
        update dp2;
      } catch (Exception e) {

      }*/

      //update the effective date
       //grab our vantage API Key
	  CCAPI__c api_record = new CCAPI__c(name='Vantage',access_key__c='eabhadfa12',user__c='Vantage');
	  insert api_record;
	  Map<String,Object> myReturn = new Map<String,Object>();

	  PageReference pageRef = Page.CCAPI;
      Test.setCurrentPage(pageRef);

      CCAPI API = new CCAPI();
      pageRef.getParameters().put('APIKEY', api_record.access_key__c);
      //run the call now - we should error out because no vacation was specfied
      API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  //should fail due to no WID
	  pageRef.getParameters().put('vaction', 'updateoffice');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '301');

	  //should fail due to a missing effective date
	  pageRef.getParameters().put('OfficeID', 'bad_oid');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '302');

	  //should faile because we have a bad officeID
	  pageRef.getParameters().put('MonOpen', '1');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '303');

	  //Should succeed
	  pageRef.getParameters().put('OfficeID', '3');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'true');

	  //different date formats here
	  pageRef.getParameters().put('EffectiveDate', '10/14/2014 11:46 AM');
	  pageRef.getParameters().put('MonOpen', '0');
	  pageRef.getParameters().put('MonStart', '09:00');
	  pageRef.getParameters().put('MonEnd', '16:00');
	  pageRef.getParameters().put('TueOpen', '0');
	  pageRef.getParameters().put('TueStart', '09:00');
	  pageRef.getParameters().put('TueEnd', '16:00');
	  pageRef.getParameters().put('WedOpen', '0');
	  pageRef.getParameters().put('WedStart', '09:00');
	  pageRef.getParameters().put('WedEnd', '16:00');
	  pageRef.getParameters().put('ThuOpen', '0');
	  pageRef.getParameters().put('ThuStart', '09:00');
	  pageRef.getParameters().put('ThuEnd', '16:00');
	  pageRef.getParameters().put('FriOpen', '0');
	  pageRef.getParameters().put('FriStart', '09:00');
	  pageRef.getParameters().put('FriEnd', '16:00');
	  pageRef.getParameters().put('SatOpen', '0');
	  pageRef.getParameters().put('SatStart', '09:00');
	  pageRef.getParameters().put('SatEnd', '16:00');
	  pageRef.getParameters().put('SunOpen', '0');
	  pageRef.getParameters().put('SunStart', '09:00');
	  pageRef.getParameters().put('SunEnd', '16:00');
	  pageRef.getParameters().put('Hygiene', '0');
	  pageRef.getParameters().put('Dentures', '0');
	  pageRef.getParameters().put('TraditionalOrthodontics', '0');
	  pageRef.getParameters().put('WisdomTeeth', '0');
	  pageRef.getParameters().put('CrownBridge', '0');
	  pageRef.getParameters().put('Invisalign', '0');
	  pageRef.getParameters().put('Endontics', '0');
	  pageRef.getParameters().put('Veneers', '0');
	  pageRef.getParameters().put('Botox', '0');
	  pageRef.getParameters().put('LaserDentistry', '0');
	  pageRef.getParameters().put('FirstName', 'First Name');
	  pageRef.getParameters().put('LastName', 'Last Name');
	  pageRef.getParameters().put('Email1', 'test@yahoo.com');
	  pageRef.getParameters().put('Email2', 'test@hotmail.com');
	  pageRef.getParameters().put('Phone1', '555555');
	  pageRef.getParameters().put('Phone2', '5555555555');
	  pageRef.getParameters().put('ClinicName', 'Test Clinic Name');
	  pageRef.getParameters().put('Street', '111 Test Street');
	  pageRef.getParameters().put('City', 'Colorado Springs');
	  pageRef.getParameters().put('State', 'CO');
	  pageRef.getParameters().put('ZipCode', '80910');
	  pageRef.getParameters().put('Website', 'www.test.com');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  	  System.debug('MyReturn : ' + myReturn);
	  // system.assert(myReturn.get('Success') == 'true');

	  //testeing days and procedurs as true now
	  pageRef.getParameters().put('MonOpen', '1');
	  pageRef.getParameters().put('TueOpen', '1');
	  pageRef.getParameters().put('WedOpen', '1');
	  pageRef.getParameters().put('ThuOpen', '1');
	  pageRef.getParameters().put('FriOpen', '1');
	  pageRef.getParameters().put('SatOpen', '1');
	  pageRef.getParameters().put('SunOpen', '1');
	  pageRef.getParameters().put('Hygiene', '1');
	  pageRef.getParameters().put('Dentures', '1');
	  pageRef.getParameters().put('TraditionalOrthodontics', '1');
	  pageRef.getParameters().put('WisdomTeeth', '1');
	  pageRef.getParameters().put('TeethWhitening', '0');
	  pageRef.getParameters().put('CrownBridge', '1');
	  pageRef.getParameters().put('Invisalign', '1');
	  pageRef.getParameters().put('Endontics', '1');
	  pageRef.getParameters().put('Veneers', '1');
	  pageRef.getParameters().put('Botox', '1');
	  pageRef.getParameters().put('LaserDentistry', '1');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  System.debug('MyReturn : ' + myReturn);
	  // system.assert(myReturn.get('Success') == 'true');


	  pageRef.getParameters().put('EffectiveDate', '2014/6/21 3:00:00');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'true');

	  pageRef.getParameters().put('EffectiveDate', '');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());

	  pageRef.getParameters().put('EffectiveDate', 'bad date');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '304');

	  pageRef.getParameters().put('EffectiveDate', '2014/6/21 3:00:00');
	  pageRef.getParameters().put('LaserDentistry', 'bad_value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '261');

	  pageRef.getParameters().put('LaserDentistry', '1');
	  pageRef.getParameters().put('Botox', 'bad_value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '260');

	  pageRef.getParameters().put('Botox', '1');
	  pageRef.getParameters().put('TeethWhitening', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '259');

	  pageRef.getParameters().put('TeethWhitening', '1');
	  pageRef.getParameters().put('Veneers', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '258');

	  pageRef.getParameters().put('Veneers', '1');
	  pageRef.getParameters().put('Endodontics', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '257');

	   pageRef.getParameters().put('Endodontics', '1');
	  pageRef.getParameters().put('Invisalign', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '256');

	   pageRef.getParameters().put('Invisalign', '1');
	  pageRef.getParameters().put('CrownBridge', 'bad value');
	  pageRef.getParameters().put('Crown&Bridge', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '255');

	   pageRef.getParameters().put('CrownBridge', '1');
	   pageRef.getParameters().put('Crown&Bridge', '1');
	  pageRef.getParameters().put('WisdomTeethExtractions', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '254');

       pageRef.getParameters().put('WisdomTeethExtractions', '1');
	  pageRef.getParameters().put('TraditionalOrthodontics', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '253');

	   pageRef.getParameters().put('TraditionalOrthodontics', '1');
	  pageRef.getParameters().put('Dentures', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '252');

	   pageRef.getParameters().put('Dentures', '1');
	  pageRef.getParameters().put('Hygiene', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '251');

	  pageRef.getParameters().put('Hygiene', '1');
	  pageRef.getParameters().put('MonOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '221');

	  pageRef.getParameters().put('MonOpen', '1');
	  pageRef.getParameters().put('MonStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '231');

      pageRef.getParameters().put('MonStart', '09:00');
	  pageRef.getParameters().put('MonEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '241');

	  pageRef.getParameters().put('MonEnd', '09:00');
	  pageRef.getParameters().put('TueOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '222');

	  pageRef.getParameters().put('TueOpen', '1');
	  pageRef.getParameters().put('TueStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '232');

      pageRef.getParameters().put('TueStart', '09:00');
	  pageRef.getParameters().put('TueEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '242');

	  pageRef.getParameters().put('TueEnd', '09:00');
	  pageRef.getParameters().put('WedOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '223');

	  pageRef.getParameters().put('WedOpen', '1');
	  pageRef.getParameters().put('WedStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '233');

      pageRef.getParameters().put('WedStart', '09:00');
	  pageRef.getParameters().put('WedEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '243');

	  pageRef.getParameters().put('WedEnd', '09:00');
	  pageRef.getParameters().put('ThuOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '224');

	  pageRef.getParameters().put('ThuOpen', '1');
	  pageRef.getParameters().put('ThuStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '234');




      Test.stopTest();
    }

    static testMethod void testDental_office_insert_update2() {
      //create a test lead so we have a warranty id to query
	  Profile p = [select id from Profile where name = 'System Administrator'];
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;

	  Market__c m = new Market__c(name='Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  location_code__c = 'TestLoc', Send_Gold_Lead_Text_Message__c = true, SMS_Text_Phone_3_Gold_Leads__c = '5555555555', SMS_Text_Phone_2_Gold_Leads__c = '5555555555', SMS_Text_Phone_1_Gold_Leads__c = '5555555555');
	  insert test_center;
      Test.startTest();

      Dental_Practice__c dp = new Dental_Practice__c(name='Test Practice', Street__c = '1234 Test Street', State_Province__c = 'CO', Primary_Contact_Name__c = 'Test Contact',
        Primary_Contact_Email__c = 'test@clearchoice.com', Practice_Website__c = 'www.clearchoice.com', Postal_Code__c = '80910', Phone__c = '5555555555',
        Fax__c = '5555555555', Country__c = 'USA', City__c = 'Denver', Alt_Phone__c = '5555555555', Refer_to_this_practice__c = false, display_to_vendor__c = false, ClearVantage_Complete__c = false, PSA_Contract_Completed__c = false,center_information__c = test_center.id);
      insert dp;

      Dental_Practice__c dp2 = new Dental_Practice__c(name='Test Practice', Street__c = '1234 Test Street', State_Province__c = 'CO', Primary_Contact_Name__c = 'Test Contact',
        Primary_Contact_Email__c = 'test@clearchoice.com', Practice_Website__c = 'www.clearchoice.com', Postal_Code__c = '80910', Phone__c = '5555555555',
        Fax__c = '5555555555', Country__c = 'USA', City__c = 'Denver', Alt_Phone__c = '5555555555', Refer_to_this_practice__c = false,display_to_vendor__c = false, ClearVantage_Complete__c = false, PSA_Contract_Completed__c=false, Vantage_OfficeID__c = '3',center_information__c = test_center.id);
      insert dp2;

      Practice_Doctor__c pd = new Practice_Doctor__c(Title__c = 'Dr', Phone__c = '5555555555', Last_Name__c = 'Test Last', First_Name__c = 'First', Email__c = 'test@clearchoice.com',
        Dental_Practice__c = dp.id, Alt_Phone__c = '5555555555');
      insert pd;

      Practice_Doctor__c pd2 = new Practice_Doctor__c(Title__c = 'Dr', Phone__c = '5555555555', Last_Name__c = 'Test Last', First_Name__c = 'First', Email__c = 'test@clearchoice.com',
        Dental_Practice__c = dp2.id, Alt_Phone__c = '5555555555');
      insert pd2;

      dp.Refer_to_this_practice__c = true;
      dp.display_to_vendor__c = true;
      dp.PSA_Contract_Completed__c = true;
      dp.ClearVantage_Complete__c = true;
      update dp;

     /* try {
        dp2.Refer_to_this_practice__c = true;
        dp2.PSA_Contract_Completed__c = true;
        update dp2;
      } catch (Exception e) {

      }*/

      //update the effective date
       //grab our vantage API Key
	  CCAPI__c api_record = new CCAPI__c(name='Vantage',access_key__c='eabhadfa12',user__c='Vantage');
	  insert api_record;
	  Map<String,Object> myReturn = new Map<String,Object>();

	  PageReference pageRef = Page.CCAPI;
      Test.setCurrentPage(pageRef);

      CCAPI API = new CCAPI();
      pageRef.getParameters().put('APIKEY', api_record.access_key__c);
      pageRef.getParameters().put('vaction', 'updateoffice');
      pageRef.getParameters().put('MonOpen', '1');
      pageRef.getParameters().put('OfficeID', '3');

      pageRef.getParameters().put('ThuStart', '09:00');
	  pageRef.getParameters().put('ThuEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '244');

	  pageRef.getParameters().put('ThuEnd', '09:00');
	  pageRef.getParameters().put('FriOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '225');

      pageRef.getParameters().put('FriOpen', '1');
	  pageRef.getParameters().put('FriStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '235');

      pageRef.getParameters().put('FriStart', '09:00');
	  pageRef.getParameters().put('FriEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '245');

	  pageRef.getParameters().put('FriEnd', '09:00');
	  pageRef.getParameters().put('SatOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '226');

	  pageRef.getParameters().put('SatOpen', '1');
	  pageRef.getParameters().put('SatStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '236');

      pageRef.getParameters().put('SatStart', '09:00');
	  pageRef.getParameters().put('SatEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '246');

	  pageRef.getParameters().put('SatEnd', '09:00');
	  pageRef.getParameters().put('SunOpen', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '227');

	  pageRef.getParameters().put('SunOpen', '1');
	  pageRef.getParameters().put('SunStart', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '237');

      pageRef.getParameters().put('SunStart', '09:00');
	  pageRef.getParameters().put('SunEnd', 'bad value');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '247');

      test.stoptest();
    }

    static testMethod void testlead_insert() {
      //create a test lead so we have a warranty id to query
	  Profile p = [select id from Profile where name = 'System Administrator'];
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	  insert my_test_user;

	  Market__c m = new Market__c(name='Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		  location_code__c = 'TestLoc', Send_Gold_Lead_Text_Message__c = true, SMS_Text_Phone_3_Gold_Leads__c = '5555555555', SMS_Text_Phone_2_Gold_Leads__c = '5555555555', SMS_Text_Phone_1_Gold_Leads__c = '5555555555');
	  insert test_center;

      Dental_Practice__c dp = new Dental_Practice__c(name='Test Practice', Street__c = '1234 Test Street', State_Province__c = 'CO', Primary_Contact_Name__c = 'Test Contact',
        Primary_Contact_Email__c = 'test@clearchoice.com', Practice_Website__c = 'www.clearchoice.com', Postal_Code__c = '80910', Phone__c = '5555555555',
        Fax__c = '5555555555', Country__c = 'USA', City__c = 'Denver', Alt_Phone__c = '5555555555', Refer_to_this_practice__c = false, display_to_vendor__c = false, ClearVantage_Complete__c = true, PSA_Contract_Completed__c = false, center_information__c = test_center.id);
      insert dp;

      Dental_Practice__c dp2 = new Dental_Practice__c(name='Test Practice', Street__c = '1234 Test Street', State_Province__c = 'CO', Primary_Contact_Name__c = 'Test Contact',
        Primary_Contact_Email__c = 'test@clearchoice.com', Practice_Website__c = 'www.clearchoice.com', Postal_Code__c = '80910', Phone__c = '5555555555',
        Fax__c = '5555555555', Country__c = 'USA', City__c = 'Denver', Alt_Phone__c = '5555555555', Refer_to_this_practice__c = false, display_to_vendor__c = false, ClearVantage_Complete__c = true, PSA_Contract_Completed__c = false,  Vantage_OfficeID__c = '3',center_information__c = test_center.id);
      insert dp2;

      Practice_Doctor__c pd = new Practice_Doctor__c(Title__c = 'Dr', Phone__c = '5555555555', Last_Name__c = 'Test Last', First_Name__c = 'First', Email__c = 'test@clearchoice.com',
        Dental_Practice__c = dp.id, Alt_Phone__c = '5555555555');
      insert pd;

      Practice_Doctor__c pd2 = new Practice_Doctor__c(Title__c = 'Dr', Phone__c = '5555555555', Last_Name__c = 'Test Last', First_Name__c = 'First', Email__c = 'test@clearchoice.com',
        Dental_Practice__c = dp2.id, Alt_Phone__c = '5555555555');
      insert pd2;

      Campaign c = new Campaign(name = 'Office Catch', startdate = system.today(),status = 'In Progress',phone_number__c='VANOID_3');
      insert c;

      dp2.Refer_to_this_practice__c = true;
      dp2.PSA_Contract_Completed__c = true;
      dp2.ClearVantage_Complete__c = true;
      dp2.display_to_vendor__c = true;
      update dp2;


      //update the effective date
       //grab our vantage API Key
	  CCAPI__c api_record = new CCAPI__c(name='Vantage',access_key__c='eabhadfa12',user__c='Vantage');
	  insert api_record;
	  Map<String,Object> myReturn = new Map<String,Object>();

	  PageReference pageRef = Page.CCAPI;
      Test.setCurrentPage(pageRef);
      test.starttest();
      pageRef.getParameters().put('APIKEY', api_record.access_key__c);
      pageRef.getParameters().put('vaction', 'leadinsert');
      CCAPI API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '301');

	  pageRef.getParameters().put('OfficeID', 'Invalid');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // system.assert(myReturn.get('Success') == 'false');
	  // system.assert(myReturn.get('Error') == '111');

	  pageRef.getParameters().put('OfficeID', '3');
	  pageRef.getParameters().put('FirstName', 'John');
	  pageRef.getParameters().put('LastName', 'Doe');
	  pageRef.getParameters().put('Email', 'jDoe@clearchoice.com');
	  pageRef.getParameters().put('Street', '111 test Street');
	  pageRef.getParameters().put('City', 'Colorado Springs');
	  pageRef.getParameters().put('Description', 'This is a long test note');

	  pageRef.getParameters().put('State', 'CO');
	  pageRef.getParameters().put('Zip', '80910');
	  pageRef.getParameters().put('Country', 'USA');
	  pageRef.getParameters().put('Phone', '5555555555');
	  pageRef.getParameters().put('Mobile', '4445555555');
	  pageRef.getParameters().put('DateofBirth', '1982/6/21');
	  pageRef.getParameters().put('SalesAlert', 'Test Alert');
	  pageRef.getParameters().put('ExternalID', 'blargh');
	  pageRef.getParameters().put('PhoneNotes', 'Testing phone notes');
	  pageRef.getParameters().put('RefusedtoGiveEmail', 'true');
	  pageRef.getParameters().put('CallResult', 'Not Scheduled');
	  pageRef.getParameters().put('DateCallBackScheduled', '10/14/2014 11:46 AM');
	  pageRef.getParameters().put('Alert', 'Test nonSales Alert');
	  pageRef.getParameters().put('DoNotCall', 'true');
	  pageRef.getParameters().put('DentalCondition', 'Missing Teeth');
	  pageRef.getParameters().put('TrackReferral', 'Track I');
	  pageRef.getParameters().put('ImplantType', '1');
	  pageRef.getParameters().put('ImplantAbutment', '1');
	  pageRef.getParameters().put('FullArch', '1');
	  pageRef.getParameters().put('OtherProcedure', 'TBD');

	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  System.debug('My Return ' + myReturn);
	  // system.assert(myReturn.get('Success') == 'true');

	  // Lead tlead = [select id,name,warranty_id__c from Lead where warranty_id__c <> null and referral_location__c = '3' limit 1];
	  // myWS.updatereferral_consultstatus(tlead.id,System.today(),'Scheduled',' ');

	  pageRef.getParameters().put('vaction', 'leadupdate');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  System.debug('My Return ' + myReturn);

	  pageRef.getParameters().put('WID', 'bad_warranty_id');
	  API = new CCAPI();
	  API.runCCAPI();
	  myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  System.debug('My Return ' + myReturn);

	  // pageRef.getParameters().put('WID', tlead.warranty_id__c);
	  // API = new CCAPI();
	  // API.runCCAPI();
	  // myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
	  // System.debug('My Return ' + myReturn);

      test.stoptest();
    }

    static testMethod void testWebCallOuts() {
      Test.startTest();
      // This causes a fake response to be generated
      Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_validate_account());

      String vantage_userid = '4';
  	  String vantage_username = 'cv';
  	  String vantage_pwd = '364c34557231317135747565456758667555315076513d3d';

      // Call the method that invokes a callout
      tempuriOrg.SyncrServiceEndpoint tcall = new tempuriOrg.SyncrServiceEndpoint();
      Boolean test_response = tcall.ValidateAccount(vantage_userid,vantage_username,vantage_pwd);
      System.debug('Test Response : ' + test_response);

      // Verify that a fake result is returned
      System.assert(test_response==true);

      Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_office_registration());
      String xml_file = '<?xml version="1.0"?>' +
 	    '<Request version="SSAPI 1.0" xmlns="https://myclearvantage.com">' +
		'<UserID>' + vantage_userid + '</UserID>' +
		'<Username>' + vantage_username + '</Username>' +
		'<Password>' + vantage_pwd + '</Password>' +
		'<RequestType>NewRegistration</RequestType>' +
		'<Sender>ClearVantage</Sender>' +
		'<Contact>' +
		  '<ContactDetails>' +
		  '<FirstName>First</FirstName>' +
		  '<LastName>Last</LastName>' +
		  '<Email1>test@clearchoice.com</Email1>' +
		  '<Email2></Email2>' +
		  '<Phone1>5555555555</Phone1>' +
		  '<Phone2></Phone2>' +
		  '<ClinicName>test Clinic</ClinicName>' +
		  '<Street1>1034 Peoria St</Street1>' +
		  '<Street2></Street2>' +
		  '<City>Aurora</City>' +
		  '<State>CO</State>' +
		  '<ZipCode>80910</ZipCode>' +
		  '<WebSite>www.clearchoice.com</WebSite>' +
		  '</ContactDetails>' +
		'</Contact>' +
		'</Request>';
      xml_file = EncodingUtil.base64Encode(Blob.valueof(xml_file));
      String s_response = tcall.NewOfficeRegistration(xml_file);
      System.assert(s_response=='Just Testing');

      Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_post_CVS_warranty());

      xml_file = '<Request xmlns="https://myclearvantage.com" version="SSAPI 1.0">' +
		'<UserID>' + vantage_userid + '</UserID>' +
		'<Username>' + vantage_username + '</Username>' +
		'<Password>' + vantage_pwd + '</Password>' +
		'<RequestType>NewWarrantyID</RequestType>' +
		'<Sender>ClearVantage</Sender>' +
		'<Contact>' +
		'<ContactDetails>' +
		'<PracticeID>10</PracticeID>' +
		'<FirstName>Mary</FirstName>' +
		'<LastName>Smith</LastName>' +
		'<BirthDate>09/24/1971</BirthDate>' +
		'<Gender>F</Gender>' +
		'<HomePhone>2222223333</HomePhone>' +
		'<WorkPhone>3332223333</WorkPhone>' +
		'<MobilePhone>4442223333</MobilePhone>' +
		'<Email>myemail123@gmail.com</Email>' +
		'<Street>NW 811 Gracie Terrace, Apt 101</Street>' +
		'<City>Aspen</City>' +
		'<State>CO</State>' +
		'<ZipCode>90028</ZipCode>' +
		'<Language>English</Language>' +
		'<WarrantyID>ABC123-XYZ987-QWE543-RTY837</WarrantyID>' +
		'<LeadStatus>Consult Scheduled</LeadStatus>' +
		'<ConsultDate>02/18/2014</ConsultDate>' +
		'<ProcsInterested>Implants;</ProcsInterested>' +
		'</ContactDetails>' +
		'</Contact>' +
		'</Request>';

	  xml_file = EncodingUtil.base64Encode(Blob.valueof(xml_file));
      s_response = tcall.PostCCWarrantyInformation(xml_file);
      System.assert(s_response=='CVS Just Testing');

      test.stopTest();
    }

    static testMethod void sandbox() {
      //we're not doing anything with this group anymore.
      /*String app_id = 'R9271M';
      String app_key = 'test';
      String controller = 'account';
      String action = 'GetTokenAccess';
      String username = 'gp_apitest1';
      String userpass = 'password123';
      String provider = 'gp';


      JSONGenerator json_body = JSON.createGenerator(false);
      json_body.writeStartArray();

      json_body.writeStartObject();
      json_body.writeStringField('controller',controller);
      json_body.writeStringField('action',action);
      json_body.writeStringField('username',username);
      json_body.writeStringField('userpass',userpass);
      json_body.writeStringField('provider',provider);

      json_body.writeEndObject();

      String post_body = json_body.getAsString();

      System.debug('Post Body ' + post_body);

       String Base64_body = EncodingUtil.base64Encode(Blob.valueof(post_body));

       System.debug('Base64 Body ' + base64_body);

       String postData = 'enc_request=' + post_body + '&app_id=' + app_id + '&app_key=' + app_key;
       Blob b = Blob.valueOf(postData);
       System.debug('B ' + b.toString());

       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
       req.setEndpoint('http://clearconnectnow.com/api/sandbox/');
       //req.setHeader('Content-Type', 'application/json');
       req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       req.setHeader('Content-Length',String.valueof(b.size()));
       req.setBodyAsBlob(b);

      Http http = new Http();
      HTTPResponse res = http.send(req);

      if(res.getStatusCode() != 200) {
        System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);
      }
	  else {
	    System.debug('Response ' + res.getBody());
	  }
	  /*Map<String,String> mapped_values = new Map<String,String>();
	  String json_response = '{"success":true,"errormsg":"None","data":{"ok":1,"action":"access","token":"6bf4fbb28206d0289d7c551e905fbbaa","url":"http://clearconnectnow.com/index.php?content=eferralCenter&m=1"}}';
	  JSONParser parser = JSON.createParser(json_response);
	  while (parser.nextToken() != null) {
	    //System.debug('Current Token : ' + parser.getCurrentToken());
	    if(parser.getCurrentToken() == Jsontoken.Field_Name) {
	      parser.nextToken();
	      mapped_values.put(parser.getCurrentName(),parser.getText());
	      System.debug('Name : ' + parser.getCurrentName() + '  Value : ' + parser.getText());
	    }
	  }
	  System.debug('Mapped Values : ' + mapped_values);*/
    }

    static testMethod void sandbox2() {
      /*String app_id = 'R9271M';
      String app_key = 'test';
      String controller = 'account';
      String action = 'GetTokenAccess';
      String username = 'gp_apitest1';
      String userpass = 'password123';
      String provider = 'gp';

      Map<String,Object> enc_body = new Map<String,Object> ();
      enc_body.put('controller',controller);
      enc_body.put('action',action);
      enc_body.put('username',username);
      enc_body.put('provider',provider);
      System.debug('enc_body : ' + enc_body);

      Map<String, Object> myReturn = new Map<String, Object>();
      myReturn.put('enc_request',enc_body);
      myReturn.put('app_id',app_id);
      myReturn.put('app_key',app_key);
      System.debug('My Return : ' + myReturn);

      String post_body = JSON.serialize(myReturn);

      System.debug('JSON : ' + post_body);

       Blob b = Blob.valueOf(post_body);
       System.debug('Blob : ' + b.toString());

       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
       req.setEndpoint('http://clearconnectnow.com/api/sandbox/');
       //req.setHeader('Content-Type', 'application/json');
       req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       req.setHeader('Content-Length',String.valueof(b.size()));
       req.setBodyAsBlob(b);

      Http http = new Http();
      HTTPResponse res = http.send(req);

      if(res.getStatusCode() != 200) {
        System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);
      }
	  else {
	    System.debug('Response ' + res.getBody());
	  }

      /*JSONGenerator json_body = JSON.createGenerator(false);
      json_body.writeStartArray();

      json_body.writeStartObject();
      json_body.writeStringField('controller',controller);
      json_body.writeStringField('action',action);
      json_body.writeStringField('username',username);
      json_body.writeStringField('userpass',userpass);
      json_body.writeStringField('provider',provider);

      json_body.writeEndObject();*/

      /*String post_body = json_body.getAsString();

      System.debug('Post Body ' + post_body);

       String Base64_body = EncodingUtil.base64Encode(Blob.valueof(post_body));

       System.debug('Base64 Body ' + base64_body);

       String postData = 'enc_request=' + post_body + '&app_id=' + app_id + '&app_key=' + app_key;
       Blob b = Blob.valueOf(postData);
       System.debug('B ' + b.toString());

       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
       req.setEndpoint('http://clearconnectnow.com/api/sandbox/');
       //req.setHeader('Content-Type', 'application/json');
       req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       req.setHeader('Content-Length',String.valueof(b.size()));
       req.setBodyAsBlob(b);

      Http http = new Http();
      HTTPResponse res = http.send(req);

      if(res.getStatusCode() != 200) {
        System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);
      }
	  else {
	    System.debug('Response ' + res.getBody());
	  }
	  Map<String,String> mapped_values = new Map<String,String>();
	  String json_response = '{"success":true,"errormsg":"None","data":{"ok":1,"action":"access","token":"6bf4fbb28206d0289d7c551e905fbbaa","url":"http://clearconnectnow.com/index.php?content=eferralCenter&m=1"}}';
	  JSONParser parser = JSON.createParser(json_response);
	  while (parser.nextToken() != null) {
	    //System.debug('Current Token : ' + parser.getCurrentToken());
	    if(parser.getCurrentToken() == Jsontoken.Field_Name) {
	      parser.nextToken();
	      mapped_values.put(parser.getCurrentName(),parser.getText());
	      System.debug('Name : ' + parser.getCurrentName() + '  Value : ' + parser.getText());
	    }
	  }
	  System.debug('Mapped Values : ' + mapped_values);  */
    }

}