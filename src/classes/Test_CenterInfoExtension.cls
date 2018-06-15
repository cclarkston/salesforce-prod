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
private class Test_CenterInfoExtension {

  static testMethod void testNextWeekBtn() {
  	try {
	  	Market__c test_market = [select id from Market__c limit 1];
	    Center_Information__c[] test_center = new Center_Information__c[] {
	    	new Center_Information__c(Name = 'Test Center', Street_1__c = 'Test Street', State__c = 'CO', Zip_Code__c = '80013',
	    	  Directions__c = 'Test Directions', Market__c = test_market.Id, Sales_Market__c = test_market.Id,
	    	  CID__c ='1', Location__c = 'Test', Type__c = 'Mini', CAdmin__c = 'Test user', Doctor_1__c = 'Test Doc 1',
	    	  Doctor_1_Type__c = 'Pros', Doctor_2__c = 'test Doc 2', Doctor_2_Type__c = 'OS', Aval_Cnslts_This_Week__c = 5,
	    	  Aval_Cnslts_Next_Week__c = 10, Aval_Cnslts_2nd_Week__c = 15, Aval_Cnslts_3rd_Week__c = 20, Aval_Cnslts_4th_Week__c = 25)
	    };
	    insert test_center;
	    
	    System.debug(test_center[0]);
	    
	    PageReference pageref = new PageReference('/apex/ShiftCenterConsults');	    
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id',test_center[0].Id);
	    ApexPages.StandardController sc = new ApexPages.StandardController(test_center[0]);
	    CenterInfoExtension controller = new CenterInfoExtension(sc);
	 
	    Test.startTest();
	    //process the next week button and verify the consults all shifted up 1 week with the 4th being set to 0
	    controller.autoRun();	    
	    
	    Center_Information__c ci = [select id,name,Aval_Cnslts_This_Week__c,aval_cnslts_next_week__c,
	      aval_cnslts_2nd_week__c,aval_cnslts_3rd_week__c,aval_cnslts_4th_week__c from center_information__c  
	      where id = :test_center[0].Id];
	    System.debug(ci);
	    System.assert(ci.Aval_Cnslts_This_Week__c == 10);
	    System.assert(ci.Aval_Cnslts_Next_Week__c == 15);
	    System.assert(ci.Aval_Cnslts_2nd_Week__c == 20);
	    System.assert(ci.Aval_Cnslts_3rd_Week__c == 25);
	    System.assert(ci.Aval_Cnslts_4th_Week__c == 0);
	    Test.stopTest();
	    
		} catch(Exception e) {    system.debug ('error: ' + e.getMessage() );    }        
	}
}