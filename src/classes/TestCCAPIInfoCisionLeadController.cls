@isTest
/**
* Clear Choice External API
* InfoCision Lead Controller
* Test CCAPIInfoCisionLeadController
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2012-07-19     Chad Serpan            		Initial Build 90% Coverage
* 2012-08-02     Chad Serpan            		Updated to handle test cases for wrong inbound call data 88% Coverage
* 2012-08-06     Chad Serpan            		Updated to handle Activity data 89% Coverage
* 2012-08-08     Chad Serpan            		Updated to handle Campaign data 90% Coverage
* 2012-08-27     Chad Serpan            		Updated to handle More Lead data 92% Coverage
* 2012-08-29	 Chris McDowell					Added new test methods for consult lookup and consult scheduling (kept it at 92% coverage)
* 2012-10-08	 Chad Serpan					Added tests for Date of Birth, Wearing Dentures, Lenght of Condition, and Gum Disease
* ===============================================================================
*
* @author Chad Serpan
* @version 1.4
* @copyright 2012-07-19
* @package CCAPI
* @subpackage CCAPIInfoCisionLeadController
* @see pages::CCAPI.page
* @see classes::CCAPI.cls
* @see classes::CCAPIInfoCisionLeadController.cls
*
* @todo figure out testing for general catch statements
*/
private class TestCCAPIInfoCisionLeadController {
	 static testMethod void testInfoCisionLead() {

		Test.startTest();

		// Test CCAPIInfoCisionLeadController
    CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();
    Util_TriggerContext.setalreadyProcessed();

	 	PageReference pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	// Test No Parameters sent
		Map <String, Object> myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '101');

    	// Test API but with garbage data
		pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('Empty1', '123');

    	API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '109');

		pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('Mobile','3035551234');
		pageRef.getParameters().put('DateOfBirth','1980-01-01');
		pageRef.getParameters().put('LastMarketingSource','');
		pageRef.getParameters().put('DistanceToCenter','10');
		pageRef.getParameters().put('SalesAlert','');
		pageRef.getParameters().put('ExternalID','CLCH00101278');
		pageRef.getParameters().put('MarketingSource','');
		pageRef.getParameters().put('InboundCall','');
		pageRef.getParameters().put('CallResult','');
		pageRef.getParameters().put('DateCallBackScheduled','2010-07-01 12:00:00');
		pageRef.getParameters().put('Gender','Male');
		pageRef.getParameters().put('CenterLocation','');
		pageRef.getParameters().put('LanguageSpoken','');
		pageRef.getParameters().put('CallCenterAgent', '');
		pageRef.getParameters().put('Alert', '');
		pageRef.getParameters().put('PreScreen', 'BAD VALUE');
		pageRef.getParameters().put('DoNotCall', '');
		pageRef.getParameters().put('DentalCondition', 'BAD VALUE');
		pageRef.getParameters().put('WearingDentureForHowLong', '');
		pageRef.getParameters().put('LengthOfCondition', 'BAD VALUE');
		pageRef.getParameters().put('GumDisease', '');
		pageRef.getParameters().put('Description', '');
		pageRef.getParameters().put('FeesQuoted', 'BAD VALUE');
		pageRef.getParameters().put('ConsultedImplantsBefore', 'BAD VALUE');
		pageRef.getParameters().put('HotList', '');
		pageRef.getParameters().put('CancellationListNotes', '');
		pageRef.getParameters().put('WhenConditionResolved', 'BAD VALUE');
		pageRef.getParameters().put('InboundCall','BAD VALUE');
		pageRef.getParameters().put('Objection','BAD VALUE');
		pageRef.getParameters().put('MotivationalReason','BAD VALUE');
		pageRef.getParameters().put('LastDentalVisit','BAD VALUE');
		pageRef.getParameters().put('NonSalesResult','BAD VALUE');
		pageRef.getParameters().put('MedicalHistory','false');
		pageRef.getParameters().put('RefusedtoGiveEmail','true');

		// Test API insert with bad Inbound Call data
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');
		pageRef.getParameters().put('MedicalHistory','true');

		myReturn = API.run('123');
		pageRef.getParameters().put('MotivationalReason','Appearance');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

 		// Test API insert with good data
		pageRef.getParameters().put('InboundCall','Dental Inquiry');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');

		System.debug('Prescreen Test Coming');

		// Test API insert with good data
		pageRef.getParameters().put('PreScreen','Not Checked');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Success : ' + myReturn.get('Success') + ' ' + myReturn.get('Error'));

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('DentalCondition','Missing 1-3 teeth');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('LengthOfCondition','5. Very Long (5+ Years)');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('FeesQuoted','No Quote Given');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('ConsultedImplantsBefore','No');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('WhenConditionResolved','Immediately');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		//system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

		//last dental is set to return true always right now
		//system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

		pageRef.getParameters().put('LastDentalVisit','6 - 12 Months');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Return : ' + myReturn.get('Success') + ' ' + myReturn.get('Error') + ' ' + myReturn.get('Message'));

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '114');

		pageRef.getParameters().put('Objection','Hung up');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Return : ' + myReturn.get('Success') + ' ' + myReturn.get('Error') + ' ' + myReturn.get('Message'));

		system.assert(myReturn.get('Success') == 'false');
			system.assert(myReturn.get('Error') == '115');

		pageRef.getParameters().put('NonSalesResult','Dead Air');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Return : ' + myReturn.get('Success') + ' ' + myReturn.get('Error') + ' ' + myReturn.get('Message'));

		system.assert(myReturn.get('Success') == 'true');
		String LeadID = String.valueOf(myReturn.get('LeadId'));

		Test.stopTest();
	 }

	/*
	*  ===============================================================
	*  ==															==
	*  ==						Updates								==
	*  ==															==
	*  ===============================================================
	*/
	  static testMethod void testInfoCisionUpdate() {
		Test.startTest();

		// Test CCAPIInfoCisionLeadController
       	CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

    	// Test API select

	 	PageReference pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('Mobile','3035551234');
		pageRef.getParameters().put('DateOfBirth','1980-01-01');

		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');
		String LeadID = String.valueOf(myReturn.get('LeadId'));

        pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('Action', 'leadsearch');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

	 	pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('LeadId', LeadID);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		//system.assert(myReturn.get('Success') == 'true');
		//system.assert(myReturn.get('FirstName') == 'TestCCAPIInfoCisionLeadController');

    	// Test API update with garbage data
		pageRef.getParameters().put('Empty1', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '110');

    // Test API update with good data
		pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('Mobile','3035551234');
		pageRef.getParameters().put('DateOfBirth','1980/01/01');
		pageRef.getParameters().put('LastMarketingSource','');
		pageRef.getParameters().put('DistanceToCenter','10');
		pageRef.getParameters().put('Latitude','32.5899');
		pageRef.getParameters().put('Longitude','-96.9571');
		pageRef.getParameters().put('SalesAlert','');
		pageRef.getParameters().put('ExternalID','CLCH00101278');
		pageRef.getParameters().put('MarketingSource','');
		pageRef.getParameters().put('InboundCall','');
		pageRef.getParameters().put('CallResult','');
		pageRef.getParameters().put('DateCallBackScheduled','2010/07/01 12:00:00');
		pageRef.getParameters().put('Gender','Male');
		pageRef.getParameters().put('CenterLocation','');
		pageRef.getParameters().put('LanguageSpoken','');
		pageRef.getParameters().put('CallCenterAgent', '');
		pageRef.getParameters().put('Alert', '');
		pageRef.getParameters().put('PreScreen', 'BAD VALUE');
		pageRef.getParameters().put('DoNotCall', '');
		pageRef.getParameters().put('DentalCondition', 'BAD VALUE');
		pageRef.getParameters().put('WearingDentureForHowLong', '');
		pageRef.getParameters().put('LengthOfCondition', 'BAD VALUE');
		pageRef.getParameters().put('GumDisease', '');
		pageRef.getParameters().put('Description', '');
		pageRef.getParameters().put('FeesQuoted', 'BAD VALUE');
		pageRef.getParameters().put('ConsultedImplantsBefore', 'BAD VALUE');
		pageRef.getParameters().put('HotList', '');
		pageRef.getParameters().put('CancellationListNotes', '');
		pageRef.getParameters().put('ExternalAgent', 'Test Agent');
		pageRef.getParameters().put('Whynotschedule', 'Test Data');
		pageRef.getParameters().put('Refusedtogiveemail', 'false');
		pageRef.getParameters().put('PhoneNotes', 'Test notes');
		pageRef.getParameters().put('MedicalHistory', 'true');
		pageRef.getParameters().put('LastDentalVisit', 'BAD VALUE');
		pageRef.getParameters().put('MotivationalReason', 'BAD VALUE');
		pageRef.getParameters().put('nonsalesresult', 'BAD VALUE');
		pageRef.getParameters().put('Objection', 'BAD VALUE');
		pageRef.getParameters().put('WhenConditionResolved', 'BAD VALUE');

		// Test API insert with bad Inbound Call data
		pageRef.getParameters().put('InboundCall','BAD VALUE');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
//		system.assert(myReturn.get('Error') == '113');

    	// Test API update with good data
		pageRef.getParameters().put('InboundCall','Dental Inquiry');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('PreScreen','Not Checked');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('DentalCondition','Missing 1-3 teeth');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('LengthOfCondition','5. Very Long (5+ Years)');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('FeesQuoted','No Quote Given');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');
	 }

	 static testMethod void testInfoCisionUpdate3() {
		Test.startTest();

		// Test CCAPIInfoCisionLeadController
    CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

    	// Test API select

	 	PageReference pageRef = Page.CCAPI;
    Test.setCurrentPage(pageRef);

    pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('Mobile','3035551234');
		pageRef.getParameters().put('DateOfBirth','1980-01-01');

		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');
		String LeadID = String.valueOf(myReturn.get('LeadId'));

    pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('Action', 'leadsearch');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

	 	pageRef = Page.CCAPI;
    Test.setCurrentPage(pageRef);

    pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('LeadId', LeadID);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		//system.assert(myReturn.get('Success') == 'true');
		//system.assert(myReturn.get('FirstName') == 'TestCCAPIInfoCisionLeadController');

    	// Test API update with garbage data
		pageRef.getParameters().put('Empty1', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '110');

    // Test API update with good data
		pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('Mobile','3035551234');
		pageRef.getParameters().put('DateOfBirth','1980/01/01');
		pageRef.getParameters().put('LastMarketingSource','');
		pageRef.getParameters().put('DistanceToCenter','10');
		pageRef.getParameters().put('Latitude','32.5899');
		pageRef.getParameters().put('Longitude','-96.9571');
		pageRef.getParameters().put('SalesAlert','');
		pageRef.getParameters().put('ExternalID','CLCH00101278');
		pageRef.getParameters().put('MarketingSource','');
		pageRef.getParameters().put('InboundCall','Dental Inquiry');
		pageRef.getParameters().put('CallResult','');
		pageRef.getParameters().put('DateCallBackScheduled','2010/07/01 12:00:00');
		pageRef.getParameters().put('Gender','Male');
		pageRef.getParameters().put('CenterLocation','');
		pageRef.getParameters().put('LanguageSpoken','');
		pageRef.getParameters().put('CallCenterAgent', '');
		pageRef.getParameters().put('Alert', '');
		pageRef.getParameters().put('PreScreen', 'Not Checked');
		pageRef.getParameters().put('DoNotCall', '');
		pageRef.getParameters().put('DentalCondition', 'Missing 1-3 teeth');
		pageRef.getParameters().put('WearingDentureForHowLong', '');
		pageRef.getParameters().put('LengthOfCondition', '5. Very Long (5+ Years)');
		pageRef.getParameters().put('GumDisease', '');
		pageRef.getParameters().put('Description', '');
		pageRef.getParameters().put('FeesQuoted', 'No Quote Given');
		pageRef.getParameters().put('ConsultedImplantsBefore', 'BAD VALUE');
		pageRef.getParameters().put('HotList', '');
		pageRef.getParameters().put('CancellationListNotes', '');
		pageRef.getParameters().put('ExternalAgent', 'Test Agent');
		pageRef.getParameters().put('Whynotschedule', 'Test Data');
		pageRef.getParameters().put('Refusedtogiveemail', 'false');
		pageRef.getParameters().put('PhoneNotes', 'Test notes');
		pageRef.getParameters().put('MedicalHistory', 'true');
		pageRef.getParameters().put('LastDentalVisit', 'BAD VALUE');
		pageRef.getParameters().put('MotivationalReason', 'BAD VALUE');
		pageRef.getParameters().put('nonsalesresult', 'BAD VALUE');
		pageRef.getParameters().put('Objection', 'BAD VALUE');
		pageRef.getParameters().put('WhenConditionResolved', 'BAD VALUE');


    // Test API insert with good data
		pageRef.getParameters().put('ConsultedImplantsBefore','No');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');


		system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

    	// Test API insert with good data
		pageRef.getParameters().put('WhenConditionResolved','Immediately');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		pageRef.getParameters().put('MotivationalReason','Appearance');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		//last dental is set to return true always right now
		//system.assert(myReturn.get('Success') == 'false');
		//system.assert(myReturn.get('Error') == '113');

		pageRef.getParameters().put('LastDentalVisit','6 - 12 Months');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Return : ' + myReturn.get('Success') + ' ' + myReturn.get('Error') + ' ' + myReturn.get('Message'));

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '114');

		pageRef.getParameters().put('Objection','Hung up');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Return : ' + myReturn.get('Success') + ' ' + myReturn.get('Error') + ' ' + myReturn.get('Message'));

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '115');

		pageRef.getParameters().put('NonSalesResult','Dead Air');
		// Test API with blank date and result of XML
		pageRef.getParameters().put('DateCallBackScheduled','');
		pageRef.getParameters().put('XML','true');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		System.debug('Return : ' + myReturn.get('Success') + ' ' + myReturn.get('Error') + ' ' + myReturn.get('Message'));


		system.assert(myReturn.get('Success') == 'true');
		//system.assert(myReturn.get('LeadId') == LeadID);

		//system.assert(myReturn.get('Success') == 'true');
		//system.assert(myReturn.get('LeadId') == LeadID);
		test.stoptest();
	  }

			  static testMethod void testInfoCisionUpdate2() {
		Test.startTest();

		// Test CCAPIInfoCisionLeadController
       	CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

    	// Test API select


    	// Test API select with garbage lead
    	PageReference pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('LeadId', '123');

		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '102');

    	// Test API update with garbage lead
		pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '106');
	 }

	/*
	*  ===============================================================
	*  ==															==
	*  ==						Activities							==
	*  ==															==
	*  ===============================================================
	*/
	 static testMethod void testInfoCisionActivity() {

		Test.startTest();

		// Test CCAPIInfoCisionLeadController
       	CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

		pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('LastMarketingSource','');
		pageRef.getParameters().put('DistanceToCenter','10');
		pageRef.getParameters().put('Latitude','32.5899');
		pageRef.getParameters().put('Longitude','-96.9571');
		pageRef.getParameters().put('SalesAlert','');
		pageRef.getParameters().put('ExternalID','CLCH00101278');
		pageRef.getParameters().put('MarketingSource','');
		pageRef.getParameters().put('InboundCall','');
		pageRef.getParameters().put('CallResult','');
		pageRef.getParameters().put('DateCallBackScheduled','2010-07-01 12:00:00');
		pageRef.getParameters().put('Gender','Male');
		pageRef.getParameters().put('CenterLocation','');
		pageRef.getParameters().put('LanguageSpoken','');
		pageRef.getParameters().put('CallCenterAgent', '');
		pageRef.getParameters().put('InboundCall','Dental Inquiry');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
		system.assert(myReturn.get('Success') == 'true');
		String LeadID = String.valueOf(myReturn.get('LeadId'));

		// Test Activity with Bogus Action
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('Action', 'Bogus Action');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '101');

		pageRef.getParameters().put('Action', 'LeadActivity');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '201');

		// Test Activity with no data
		pageRef.getParameters().put('LeadId', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '202');

		pageRef.getParameters().put('LeadId', LeadID);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '234');

		// Insert an Activity
		pageRef.getParameters().put('Activity', 'Inbound Consult Schdeduled');
		pageRef.getParameters().put('ActivityType', 'BAD OPTION');
		pageRef.getParameters().put('Type', 'BAD OPTION');
		pageRef.getParameters().put('Outcome', 'BAD OPTION');
		pageRef.getParameters().put('CallNoAnswer', 'false');
		pageRef.getParameters().put('Status', 'BAD OPTION');
		pageRef.getParameters().put('CallObject', 'CLCH001086743');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '280');


		pageRef.getParameters().put('ActivityType', 'Inbound Call');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '281');

		pageRef.getParameters().put('Outcome', 'Sent');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '282');

		pageRef.getParameters().put('Status', 'In Progress');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '283');

		pageRef.getParameters().put('Type', 'Other');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');
		String ActivityId = String.valueOf(myReturn.get('ActivityId'));

		// Test Activity Selection
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	pageRef.getParameters().put('APIKEY', '123');
    	pageRef.getParameters().put('XML', 'true');
		pageRef.getParameters().put('LeadId', LeadID);
		pageRef.getParameters().put('ActivityId', '123');
		pageRef.getParameters().put('Action', 'LeadActivity');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '230');

		pageRef.getParameters().put('ActivityId', ActivityId);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');
		system.assert(myReturn.get('ActivityId') == ActivityId);

		// Test Activity Update
		pageRef.getParameters().put('NonValue', 'BAD OPTION');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '243');

		pageRef.getParameters().put('Subject', 'Inbound Consult Schdeduled');
		pageRef.getParameters().put('ActivityType', 'BAD OPTION');
		pageRef.getParameters().put('Type', 'BAD OPTION');
		pageRef.getParameters().put('Outcome', 'BAD OPTION');
		pageRef.getParameters().put('CallNoAnswer', 'false');
		pageRef.getParameters().put('Status', 'BAD OPTION');
		pageRef.getParameters().put('CallObject', 'CLCH001086743');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '280');

		pageRef.getParameters().put('ActivityType', 'Inbound Call');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '281');

		pageRef.getParameters().put('Outcome', 'Sent');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '282');

		pageRef.getParameters().put('Status', 'In Progress');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '283');

		pageRef.getParameters().put('Type', 'Other');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

		// Test Update with bad Activity Id
		pageRef.getParameters().put('ActivityId', '123');
		pageRef.getParameters().put('CallObject', 'CLCH001086743');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '240');

		// Test API select
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('LeadId', LeadID);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

		Test.stopTest();
	 }

	static testMethod void test_run_prospect_all_check_sets_No_Credit_Check_Performed_flag_and_Credit_Check_Errors_when_required_info_is_missing_from_supplied_Lead() {
		// We don't want to make calls to credit check vendor if required info is missing. If any one piece of required info is null or an empty string, the call is NOT made,
		// No_Credit_Check_Performed__c is set to true and Credit_Check_Errors__c gets a message identifying the missing info.
		Test.startTest();
			PageReference pageRef = Page.CCAPI;
			Test.setCurrentPage(pageRef);

			CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

			Credit_Check__c credit_check = new Credit_Check__c();
			Lead the_lead = new Lead(FirstName='Alon', LastName='Waisman', Street='1313 Mockingbird Lane', City='Springfield', State='AB', PostalCode='01234');
			API.run_prospect_all_check(credit_check, the_lead);
			system.assertEquals(false, credit_check.No_Credit_Check_Performed__c);
			system.assertEquals(null, credit_check.Credit_Check_Errors__c);
			system.assert(credit_check.Blue_Model_Response__c != null);
			system.assert(credit_check.Blue_Model_Name__c 	  != null);
			system.assert(credit_check.Blue_Model_Tier__c	  != null);
			system.assert(credit_check.Blue_Model_Score__c	  != null);
			system.assert(credit_check.Blue_Model_Type__c	  != null);
			system.assert(credit_check.Blue_Model_Result__c	  != null);

			credit_check = new Credit_Check__c();
			the_lead = new Lead(FirstName = '', LastName = '', Street = null, City = null, State = null, PostalCode = '');
			API.run_prospect_all_check(credit_check, the_lead);
			system.assertEquals(true, credit_check.No_Credit_Check_Performed__c);
			system.assertEquals('Missing info: First Name, Last Name, Street, City, State, Postal Code', credit_check.Credit_Check_Errors__c);
			system.assert(credit_check.Blue_Model_Response__c == null);
			system.assert(credit_check.Blue_Model_Name__c	  == null);
			system.assert(credit_check.Blue_Model_Tier__c	  == null);
			system.assert(credit_check.Blue_Model_Score__c	  == null);
			system.assert(credit_check.Blue_Model_Type__c	  == null);
			system.assert(credit_check.Blue_Model_Result__c	  == null);
		Test.stopTest();
	}


	/*
	*  ===============================================================
	*  ==															==
	*  ==						Activities							==
	*  ==															==
	*  ===============================================================
	*/
	  static testMethod void testInfoCisionCampaign() {

		Test.startTest();

		// Test CCAPIInfoCisionLeadController
    	CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

		pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('FirstName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('LastName','TestCCAPIInfoCisionLeadController');
		pageRef.getParameters().put('Email','TestCCAPIInfoCisionLeadController@clearchoice.com');
		pageRef.getParameters().put('Street','123');
		pageRef.getParameters().put('City','Denver');
		pageRef.getParameters().put('State','CO');
		pageRef.getParameters().put('Zip','80021');
		pageRef.getParameters().put('Country','US');
		pageRef.getParameters().put('Phone','3035551234');
		pageRef.getParameters().put('LastMarketingSource','');
		pageRef.getParameters().put('DistanceToCenter','10');
		pageRef.getParameters().put('Latitude','32.5899');
		pageRef.getParameters().put('Longitude','-96.9571');
		pageRef.getParameters().put('SalesAlert','');
		pageRef.getParameters().put('ExternalID','CLCH00101278');
		pageRef.getParameters().put('MarketingSource','');
		pageRef.getParameters().put('InboundCall','');
		pageRef.getParameters().put('CallResult','');
		pageRef.getParameters().put('DateCallBackScheduled','2010-07-01 12:00:00');
		pageRef.getParameters().put('Gender','Male');
		pageRef.getParameters().put('CenterLocation','');
		pageRef.getParameters().put('LanguageSpoken','');
		pageRef.getParameters().put('CallCenterAgent', '');
		pageRef.getParameters().put('InboundCall','Dental Inquiry');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
		system.assert(myReturn.get('Success') == 'true');
		String LeadID = String.valueOf(myReturn.get('LeadId'));

		// Test API select
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

		pageRef.getParameters().put('Action', 'LeadCampaign');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '301');

		pageRef.getParameters().put('LeadId', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '302');

		// Test missing Campaign Id for Insert
		pageRef.getParameters().put('LeadId', LeadID);
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '303');

		// Test bad Campaign Id for Insert
		pageRef.getParameters().put('CampaignId', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '334');

		pageRef.getParameters().put('Status', 'BAD DATA');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '304');

		// Test good Campaign but missing insert values
		Campaign myCampaign = new Campaign();
		myCampaign.Name = 'InfoCisionTestCampaign';

		insert myCampaign;

		String CampaignId = myCampaign.Id;

		// Test Insertion with Bad Data
		pageRef.getParameters().put('CampaignId', CampaignId);
		pageRef.getParameters().put('Status', 'BAD DATA');
		pageRef.getParameters().put('NumGuests', 'BAD DATA');
		pageRef.getParameters().put('GuestNames', 'TESTNAME1, TESTNAME2');
		pageRef.getParameters().put('WalkIn', 'True');
		pageRef.getParameters().put('ConfirmationTime', '2010-07-01 12:00:00');
		pageRef.getParameters().put('Confirmed', 'BAD DATA');
		pageRef.getParameters().put('Attended', 'BAD DATA');
		pageRef.getParameters().put('NoShow', 'BAD DATA');
		pageRef.getParameters().put('NoShowConsult', 'BAD DATA');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '380');

		// Test Insertion with Good Data
		pageRef.getParameters().put('Status', 'Attended');
		pageRef.getParameters().put('NumGuests', '2');
		pageRef.getParameters().put('GuestNames', 'TESTNAME1, TESTNAME2');
		pageRef.getParameters().put('WalkIn', 'True');
		pageRef.getParameters().put('ConfirmationTime', '2010-07-01 12:00:00');
		pageRef.getParameters().put('Confirmed', '1');
		pageRef.getParameters().put('Attended', '1');
		pageRef.getParameters().put('NoShow', '1');
		pageRef.getParameters().put('NoShowConsult', '1');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

		String CampaignMemberId = String.valueOf(myReturn.get('CampaignMemberId'));

		// Select Bad Campaign Member
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

		pageRef.getParameters().put('APIKEY', '123');
    	pageRef.getParameters().put('XML', 'true');
		pageRef.getParameters().put('LeadId', LeadID);
		pageRef.getParameters().put('Action', 'LeadCampaign');
		pageRef.getParameters().put('CampaignMemberId', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '330');

		// Select a Good Campaign Member
		pageRef.getParameters().put('CampaignMemberId', CampaignMemberId);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

		// Test Update with Bad Campaign Member
		pageRef.getParameters().put('CampaignMemberId', '123');
		pageRef.getParameters().put('Bad Field', 'BAD DATA');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '340');

		// Test Update with bad Campaign Id
		pageRef.getParameters().put('CampaignMemberId', CampaignMemberId);
		pageRef.getParameters().put('CampaignId', '123');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '304');

		// Test Update with No Data
		pageRef.getParameters().put('CampaignId', CampaignId);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '343');

		// Test Update with Bad Data
		pageRef.getParameters().put('Status', 'BAD DATA');
		pageRef.getParameters().put('NumGuests', 'BAD DATA');
		pageRef.getParameters().put('GuestNames', 'TESTNAME1, TESTNAME2');
		pageRef.getParameters().put('WalkIn', 'True');
		pageRef.getParameters().put('ConfirmationTime', '2010-07-01 12:00:00');
		pageRef.getParameters().put('Confirmed', 'BAD DATA');
		pageRef.getParameters().put('Attended', 'BAD DATA');
		pageRef.getParameters().put('NoShow', 'BAD DATA');
		pageRef.getParameters().put('NoShowConsult', 'BAD DATA');

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '380');

		// Test Good Update
		pageRef.getParameters().put('Status', 'Attended');
		pageRef.getParameters().put('NumGuests', '2');
		pageRef.getParameters().put('GuestNames', 'TESTNAME1, TESTNAME2');
		pageRef.getParameters().put('WalkIn', 'True');
		pageRef.getParameters().put('ConfirmationTime', '2010-07-01 12:00:00');
		pageRef.getParameters().put('Confirmed', '1');
		pageRef.getParameters().put('Attended', '1');
		pageRef.getParameters().put('NoShow', '1');
		pageRef.getParameters().put('NoShowConsult', '1');
		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

		// Test API select
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);

    	pageRef.getParameters().put('APIKEY', '123');
		pageRef.getParameters().put('LeadId', LeadID);

		API = new CCAPIInfoCisionLeadController();
		myReturn = API.run('123');

		system.assert(myReturn.get('Success') == 'true');

		Test.stopTest();
     }

	/*
	*  ===============================================================
	*  ==															==
	*  ==						Scheduling							==
	*  ==															==
	*  ===============================================================
	*/

	static Center_Information__c test_center;
	static Schedule_Templates__c test_template;
	static Schedule_Templates__c test_template2;
	static Template_Apt__c test_temp_apt;
	static Consult_Rooms__c test_room;
	static Lead test_lead;
	static Account test_account;

  static User my_test_user;

  private static void scheduling_init() {
 	  //generate a test user id to use below
		Profile p = [select id from Profile where name = 'System Administrator'];
		my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;

		Market__c m = new Market__c (Name = 'Test Market');
		insert m;
		test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center;
	  my_test_user.clinic_calendar__c = test_center.name;
	  System.runas(my_test_user) {
	  update my_test_user;
		test_template = new Schedule_Templates__c(Name = 'Test Any Day Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true,
		  Saturday__c = true,  Sunday__c = true);
		insert test_template;

		test_temp_apt = new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Blue', Ending_Hour__c = '9', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '8', starting_minutes__c = '15');
		insert test_temp_apt;
	  Template_Apt__c[] test_templates = new Template_Apt__c[] {new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Purple', Ending_Hour__c = '9', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '9', starting_minutes__c = '5'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Brown', Ending_Hour__c = '12', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Any',
		  schedule_template__c = test_template.id, start_hour__c = '11', starting_minutes__c = '10'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Red', Ending_Hour__c = '13', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow Only',
		  schedule_template__c = test_template.id, start_hour__c = '12', starting_minutes__c = '50'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Green', Ending_Hour__c = '15', Ending_Minutes__c = '40', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '14', starting_minutes__c = '00')};
		insert test_templates;
		test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id);
		insert test_room;

    test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV',
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up', Contact_Agency__c = 'Infocision',email='test@clearchoice.com');
	  insert test_lead;
	  String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	  test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish');
	  insert test_account;

    ctrl_consultschedule my_ext = new ctrl_consultschedule();
    my_ext.build_room_inventory(test_room,System.today());
	  }
  }

 	static testMethod void ConsultSearch() {
 		scheduling_init();
 		test.startTest();

 		// Test CCAPIInfoCisionLeadController
		CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
   		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Action','searchconsults');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
		system.assert(myReturn.get('Error') == '401');

		pageRef.getParameters().put('LeadId','Not A LeadID');
		myReturn = API.run('123');
		system.assert(myReturn.get('Error')=='402');


		pageRef.getParameters().put('LeadId',test_lead.id);
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='481');

 		pageRef.getParameters().put('Mon','1');
 		pageRef.getParameters().put('Tue','1');
 		pageRef.getParameters().put('Wed','1');
 		pageRef.getParameters().put('Thu','1');
 		pageRef.getParameters().put('Fri','1');
 		pageRef.getParameters().put('Sat','1');
 		pageRef.getParameters().put('Sun','1');
 		pageRef.getParameters().put('Stime','12');
 		pageRef.getParameters().put('Etime','9');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='482');

 		pageRef.getParameters().put('Stime','6');
 		pageRef.getParameters().put('Etime','23');
 		pageRef.getParameters().put('Sdate','Not a Date');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='484');

 		pageRef.getParameters().put('Sdate',System.today().format());
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		Consult_Inventory__c ci = [select id,active__c,scheduled_account__c from Consult_Inventory__c where consult_room__c = :test_room.id and active__c = true limit 1];
 		ci.scheduled_lead__c = test_lead.id;
 		update ci;
 		myReturn = API.run('123');
 		//system.assert(myReturn.get('Error')=='480');

 		test.stopTest();
 	}

 	static testMethod void ConsultSchedule_fails() {
 		scheduling_init();
 		test.startTest();

 		// Test CCAPIInfoCisionLeadController
		CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Action','scheduleconsult');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
		System.debug('My Return : ' + myReturn);
		system.assert(myReturn.get('Error') == '501');

		pageRef.getParameters().put('LeadId','Not A LeadID');
		myReturn = API.run('123');
		system.assert(myReturn.get('Error')=='502');

		pageRef.getParameters().put('LeadId',test_lead.id);
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='503');

 		Consult_Inventory__c ci = [select id,active__c,scheduled_account__c from Consult_Inventory__c where consult_room__c = :test_room.id and active__c = true limit 1];
 		pageRef.getParameters().put('ConsultId','Not a ConsultID');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='504');

 		ci.active__c = false;
 		update ci;
 		pageRef.getParameters().put('ConsultId',ci.id);
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='505');

 		Lead l = new Lead(FirstName = 'Held', LastName = 'Lead', Phone = '1111111111', Refused_to_give_email__c=true);
 		insert l;
 		ci.active__c = true;
 		ci.scheduled_lead__c = l.id;
 		update ci;
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='581');

 		ci.scheduled_lead__c = test_lead.id;
 		update ci;
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='580');

 		Id room_holder = ci.Consult_Room__c;
 		ci.scheduled_lead__c = null;
 		update ci;
 		Consult_Holds__c ch = new Consult_Holds__c(consult_inventory__c = ci.id, active_hold__c = true, hold_time__c = System.now());
 		insert ch;
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='583');

 		delete ch;
 		ci.apt_date__c = System.today().addDays(-1);
 		update ci;
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='584');

 		Center_Information__c c = new Center_Information__c(Name = 'Bad Center');
 		test_lead.Center__c = c.id;
 		update test_lead;
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='582');

 		test.stopTest();
 	}

 	static testMethod void ConsultSchedule_success() {
 		scheduling_init();
 		test.startTest();

 		// Test CCAPIInfoCisionLeadController
		CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Action','scheduleconsult');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
		pageRef.getParameters().put('LeadId',test_lead.id);

 		Consult_Inventory__c ci = [select id,active__c,scheduled_account__c from Consult_Inventory__c where consult_room__c = :test_room.id and active__c = true and apt_date__c > today limit 1];
 		pageRef.getParameters().put('ConsultId',ci.id);
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		//send bcp letter
 		pageRef.getParameters().put('Action','sendbcpletter');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		//send bcp letter
 		pageRef.getParameters().put('Action','sendbcpemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		//send welcome letter
 		pageRef.getParameters().put('Action','sendwelcomeletter');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		//send welcome email
 		pageRef.getParameters().put('Action','sendwelcomeemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		test.stopTest();
 	}

 	static testMethod void ConsultLetterFailures() {
 		scheduling_init();
 		test.startTest();

 		// Test CCAPIInfoCisionLeadController
		CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Action','sendbcpletter');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
		system.assert(myReturn.get('Error')=='401');
		pageRef.getParameters().put('Action','sendwelcomeletter');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='401');
 		pageRef.getParameters().put('Action','sendwelcomeemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='401');
 		pageRef.getParameters().put('Action','sendbcpemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='401');

 		//test bad lead id
		pageRef.getParameters().put('LeadId','1');
	  pageRef.getParameters().put('Action','sendbcpletter');
		myReturn = API.run('123');
		system.assert(myReturn.get('Error')=='402');
		pageRef.getParameters().put('Action','sendwelcomeletter');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='402');
 		pageRef.getParameters().put('Action','sendwelcomeemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='402');
 		pageRef.getParameters().put('Action','sendbcpemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='402');

		//no consult id
		pageRef.getParameters().put('LeadId',test_lead.id);
		pageRef.getParameters().put('Action','sendwelcomeletter');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='503');
 		pageRef.getParameters().put('Action','sendwelcomeemail');
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Error')=='503');

 		test.stopTest();
 	}

 	static testMethod void ConsultSchedule_reschedule() {
 		scheduling_init();
 		test.startTest();

 		// Test CCAPIInfoCisionLeadController
		CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();

	 	PageReference pageRef = Page.CCAPI;
		Test.setCurrentPage(pageRef);
		//failing some resched calls here
		pageRef.getParameters().put('Action','rescheduleconsult');
		API = new CCAPIInfoCisionLeadController();
		Map <String, Object> myReturn = API.run('123');
	  pageRef.getParameters().put('LeadId',test_lead.id);
	  myReturn = API.run('123');
	  pageRef.getParameters().put('RescheduleReason',null);
	  myReturn = API.run('123');
	  pageRef.getParameters().put('RescheduleReason','bad value');
	  myReturn = API.run('123');
	  pageRef.getParameters().put('RescheduleReason','Conflict with Schedule');
	  myReturn = API.run('123');
	  pageRef.getParameters().put('ConsultId','0');
		myReturn = API.run('123');


		pageRef.getParameters().put('Action','scheduleconsult');
		pageRef.getParameters().put('LeadId',test_lead.id);
 		Consult_Inventory__c ci = [select id,active__c,scheduled_account__c from Consult_Inventory__c where consult_room__c = :test_room.id and active__c = true and apt_date__c > today limit 1];
 		pageRef.getParameters().put('ConsultId',ci.id);
 		myReturn = API.run('123');
 		system.assert(myReturn.get('Success')=='true');

 		//now reschedule it
 		pageRef.getParameters().put('Action','rescheduleconsult');
 		pageRef.getParameters().put('LeadId',test_lead.id);
 		pageRef.getParameters().put('RescheduleReason','Conflict with Schedule');
 		pageRef.getParameters().put('ConsultId',ci.id);
    myReturn = API.run('123');

 		test.stopTest();
 	}
}