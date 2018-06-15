@isTest 
/**
* Clear Choice External API
* InfoCision Lead Controller
* Test CCAPI
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2012-07-19     Chad Serpan            		Initial Build 89% Coverage
* ===============================================================================
*
* @author Chad Serpan
* @version 1.0
* @copyright 2012-07-19
* @package CCAPI
* @see pages::CCAPI.page
* @see classes::CCAPI.cls
*
* @todo figure out testing for general catch statements
*/
private class TestCCAPI {
	 static testMethod void testRunCCAPI() {
	 	Test.startTest();

	 	PageReference pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);
    	
		// Test CCAPI
       	CCAPI API = new CCAPI();
    	
    	// Test No Parameters sent
		API.runCCAPI();
		Map <String, Object> myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
		
		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '002');
		
		// Test No Parameters sent with garbage and no API
		pageRef.getParameters().put('Empty1', '123');
		
		API = new CCAPI();
		API.runCCAPI();
		myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
		
		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '003');
		
		// Test No Parameters sent with garbage APIKEY
		pageRef.getParameters().put('APIKEY', '123');
		
		API = new CCAPI();
		API.runCCAPI();
		myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
		
		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '001');
		
		// Test Garbage with XML return
		pageRef.getParameters().put('XML', 'TrUe');
		
		API = new CCAPI();
		API.runCCAPI();
		
		String myReturnXML = API.getResult();
		
		system.assert(myReturnXML.contains('Invalid Session'));
		//system.assert(myReturnXML == '<?xml version="1.0"?><data><Message>Invalid Session</Message><Success>False</Success><Error>001</Error></data>');
				
		// Test APIKEY but nothing else
		pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('APIKEY', '123');
		
		API = new CCAPI();
		API.runCCAPI();
		myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
		
		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '004');		
		
		// Test Garbage API
		CCAPI__c GarbageAPI = new CCAPI__c();
		GarbageAPI.Name = 'GarbageAPI';
		GarbageAPI.access_key__c = 'SOMETHINGRANDOMTHISWAYCOMES00000';
		GarbageAPi.User__c = 'test User';
		
		insert GarbageAPI;
		
		pageRef.getParameters().put('APIKEY', GarbageAPI.access_key__c);
		pageRef.getParameters().put('Empty1', '123');
		
		API = new CCAPI();
		API.runCCAPI();
		myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
		
		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '005');		
		
		
		/*******************************************************************************/
		
		// Test InfoCision API with Garbage Select
		CCAPI__c InfoCisionLeadAPI = new CCAPI__c();
		InfoCisionLeadAPI.Name = 'InfoCisionLead';
		InfoCisionLeadAPI.access_key__c = 'SOMETHINGRANDOMTHISWAYCOMES00001';
		InfoCisionLeadAPI.User__c = 'Test User';
		
		insert InfoCisionLeadAPI;
		
	 	pageRef = Page.CCAPI;
    	Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('APIKEY', InfoCisionLeadAPI.access_key__c);
		pageRef.getParameters().put('LeadId', '123');
		
		API = new CCAPI();
		API.runCCAPI();
		myReturn = (Map<String, Object>) JSON.deserializeUntyped(API.getResult());
		
		system.assert(myReturn.get('Success') == 'false');
		system.assert(myReturn.get('Error') == '102');
		
	 }
}