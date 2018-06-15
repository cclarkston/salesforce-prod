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
private class test_callcenterteam {

  static testMethod void myUnitTest() {
    PageReference pageref = new PageReference('/apex/TeamAssignment');
    Test.setCurrentPage(pageRef); 	
    
    test.startTest();
    ctrl_CallCenterTeam controller = new ctrl_CallCenterTeam();   
    controller.name_filter = 'Chris';
    controller.getmy_users();
    controller.getdisplay_next();
    controller.getdisplay_prev();
    controller.getnum_pages();
    controller.getpage();
    controller.refreshresults();
    controller.page = 2;
    controller.getmy_users();
        
    controller.prev();   
    controller.next();
    controller.save();
    controller.user_search();
    
    //test for SalesGoals as well
    pageref = new PageReference('/apex/SalesGoals');
     	
    
    ctrl_SalesGoals controller2 = new ctrl_SalesGoals();   
    controller2.name_filter = ' ';
    controller2.getPEClist();
    controller2.getdisplay_next();
    controller2.getdisplay_prev();
    controller2.getnum_pages();
    controller2.getpage();
    controller2.refreshresults();
    controller2.page = 2;
    controller2.getPEClist();
        
    controller2.prev();   
    controller2.next();
    controller2.save();
    controller2.user_search();
    controller2.display_dashboard();
    controller2.getCenterlist();
    controller2.getTypeOptions();
    controller2.gettype_filter();
    controller2.settype_filter('pec');
    controller2.refreshresults();
    
    test.stopTest();
  }
}