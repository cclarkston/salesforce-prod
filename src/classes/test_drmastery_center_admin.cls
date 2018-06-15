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

//82% - CM 3/16/2018
private class test_drmastery_center_admin {

private static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	
	Center_Information__c test_center = new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3,battlegroup_stars__c = 0);
	insert test_center;	 
  }
  
  static testMethod void test_center_snap_admin() {
    init();
    test.startTest();  
    
    Center_Information__c test_center = [select id,name from Center_Information__c where name = 'Test Script Center' limit 1];
            
    //generate some monthly center snapshot records
    List<Doctor_Mastery_Center_Snapshot__c> center_test_snapshots = new List<Doctor_Mastery_Center_Snapshot__c> {
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_center.id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().addmonths(1).year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().addmonths(1).month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_center.id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().addmonths(-1).year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().addmonths(-1).month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_center.id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().addyears(1).year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_center.id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null)
    };
    insert center_test_snapshots;
    
    ctrl_drmastery_center_admin ctl_admin = new ctrl_drmastery_center_admin();
    system.assert(ctl_admin.getmonth_option_list().size()>=2);    
    system.assert(ctl_admin.getyear_option_list().size()>=(2017 - System.today().year()));
    
    ctl_admin.snap_list[0].month__c = System.today().month();
    ctl_admin.current_month = System.today().addmonths(-1).month();
    ctl_admin.refresh_snap_list();
    system.assert(ctl_admin.snap_list[0].month__c==System.today().addmonths(-1).month());
    
    ctl_admin.snap_list[0].surgical_backlog_days__c = 7;
    ctl_admin.save_snap_list();
    ctl_admin.refresh_snap_list();
    system.assert(ctl_admin.snap_list[0].surgical_backlog_days__c==7);
       
    test.stopTest();
  }  


    
}