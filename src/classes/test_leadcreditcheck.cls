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
private class test_leadcreditcheck {

	static testMethod void CreditCheck() { 	
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
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c = true,
	      pre_screen__c = 'Blue (No Hit)', street = '230 E Colfax Ave', city = 'Denver', postalcode = '80203', state = 'CO', email = 'tscript@clearchoice.com'
	      );
	  insert test_lead;
	  test.startTest();
	  CCVars__c cvar1 = new CCVars__c(Name = 'Track', CC_Counter__c = 0);
	  insert cvar1;
  	
  	Pagereference pageref = new PageReference('/apex/PreScreenPage_rev2?id=' + test_lead.id);
    Test.setCurrentPage(pageRef);      

    ApexPages.StandardController sc = new ApexPages.standardController(test_lead);
    lead_creditcheck lc = new lead_creditcheck(sc);    
    lc.instance = 'Test';
    lc.check_cc_counter();
    
    System.debug('URL : ' + lc.getlead_url());
    
    lc.update_sfcu_check();
    lc.run_experian_check();
    
    lc = new lead_creditcheck(sc);
    lc.check_cc_counter();
    
    // Create a new email and envelope object 
    Messaging.InboundEmail email  = new Messaging.InboundEmail(); 
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
    email.plainTextBody = 'This should become a note'; 
    email.fromAddress ='cmcdowell@test.com'; 
    String contactEmail = 'tscript@clearchoice.com';
    //email.toAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
    email.toAddresses = new String[] {contactEmail};
    email.ccAddresses = new String[] {'J Smith <cmcdowell@clearchoice.com>'}; 
    email.subject = 'Dummy Account Name 123'; 
    cc_emailhandler edr = new cc_emailhandler(); 

    Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env); 
    
    test.stopTest();
  }

	static testMethod void test_run_prospect_all_check_sets_No_Credit_Check_Performed_flag_and_Credit_Check_Errors_when_required_info_is_missing_from_supplied_Lead() {
		// We don't want to make calls to credit check vendor if required info is missing. If any one piece of required info is null or an empty string, the call is NOT made,
		// No_Credit_Check_Performed__c is set to true and Credit_Check_Errors__c gets a message identifying the missing info.
		Test.startTest();
			Lead test_lead = new Lead(FirstName = '', LastName = 'Waisman', Street = null, City = null, State = null, PostalCode = '');
			insert test_lead;
			Pagereference pageref = new PageReference('/apex/PreScreenPage_rev2?id=' + test_lead.id);
			Test.setCurrentPage(pageRef);

			ApexPages.StandardController sc = new ApexPages.standardController(test_lead);
			lead_creditcheck controller = new lead_creditcheck(sc);

			Credit_Check__c credit_check = new Credit_Check__c();
			controller.run_prospect_all_check(credit_check, test_lead);
			system.assertEquals(true, credit_check.No_Credit_Check_Performed__c);
			system.assertEquals('Missing info: First Name, Street, City, State, Postal Code', credit_check.Credit_Check_Errors__c);
			system.assert(credit_check.Blue_Model_Response__c == null);
			system.assert(credit_check.Blue_Model_Name__c	  == null);
			system.assert(credit_check.Blue_Model_Tier__c	  == null);
			system.assert(credit_check.Blue_Model_Score__c	  == null);
			system.assert(credit_check.Blue_Model_Type__c	  == null);
			system.assert(credit_check.Blue_Model_Result__c	  == null);
		Test.stopTest();
	}

}