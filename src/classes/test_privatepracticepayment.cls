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
private class test_privatepracticepayment {

    static testMethod void myUnitTest() {
      // TO DO: implement unit test
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
	  
	  String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	  Account test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_user.id);
	  insert test_account;
	  Opportunity test_ops = new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper');
	  insert test_ops;	 
	  
	  test.starttest();

	  Private_Practice_Patient__c pp = new Private_practice_Patient__c(First_Name__c = 'Test',Last_Name__c = 'Patient', Patient_email__c = 'tpateint@clearchoice.com', center__c = test_center.id);
	  insert pp;
	  Private_Practice_Payment__c ppay = new Private_Practice_Payment__c(Private_Practice_Patient__c = pp.id);
	  insert ppay;
	  try {
	  	ppay.payment_amount__c = 100.00;
	  	update ppay;
	  }
	  catch (Exception e) {
	  	//should throw an error
	  }
	  pp.Practice_ID__c = 'WinID12372';
	  update pp;
	  ppay.payment_amount__c = 100.00;
	  ppay.payment_date__c = System.today().adddays(1);
	  ppay.payment_type__c = 'Prom Note';
	  ppay.payment_status__c = ' Anticipated Promise Note';
	  ppay.finance_fee__c = 0.00;
	  update ppay;
	  ppay.payment_date__c = System.today();
	  update ppay;
	  try {
	    ppay.payment_status__c = 'Collected';
	    update ppay;
	  }
	  catch (Exception e) {
	  	//should throw an error
	  }
	  ppay.payment_status__c = 'Collected Promise Note';
	  update ppay;
	  
	  ppay = new Private_Practice_Payment__c(Opportunity__c = test_ops.id);
	  insert ppay;
	  try {
	  	ppay.payment_amount__c = 100.00;
	  	update ppay;
	  }
	  catch (Exception e) {
	  	//should throw an error
	  }
	  test_ops.windent_patient_id__c = 'WinTest8262';
	  update test_ops;
	  ppay.payment_amount__c = 100.00;
	  ppay.payment_date__c = System.today().adddays(1);
	  ppay.payment_type__c = 'Prom Note';
	  ppay.payment_status__c = ' Anticipated Promise Note';
	  ppay.finance_fee__c = 0.00;
	  update ppay;
	  ppay.payment_date__c = System.today();
	  update ppay;
	  try {
	    ppay.payment_status__c = 'Collected';
	    update ppay;
	  }
	  catch (Exception e) {
	  	//should throw an error
	  }
	  ppay.payment_status__c = 'Collected Promise Note';
	  update ppay;
	  test_ops.windent_patient_id__c = null;
	  update test_ops;
	  
	  CCPayment__c cc = new CCPayment__c(Opportunity__c = test_ops.id);
	  insert cc;
	  try {
	  	cc.payment_amount__c = 100.00;
	  	update cc;
	  }
	  catch (Exception e) {
	  	
	  }
	  test_ops.windent_patient_id__c = 'WinTest8262';
	  update test_ops;
	  cc.payment_amount__c = 100.00;
	  cc.payment_date__c = System.today().adddays(1);
	  cc.payment_type__c = 'Prom Note';
	  cc.payment_status__c = ' Anticipated Promise Note';
	  cc.finance_fee__c = 0.00;
	  update cc;
	  cc.payment_date__c = System.today();
	  update cc;
	  try {
	    cc.payment_status__c = 'Collected';
	    update cc;
	  }
	  catch (Exception e) {
	  	//should throw an error
	  }
	  cc.payment_status__c = 'Collected Promise Note';
	  update cc;

	  test.stoptest();
    }
}