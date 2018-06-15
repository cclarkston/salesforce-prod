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
private class test_doctor_master_center_trigger {
	
  public static Boolean just_playing_around(List<Sobject> insert_obj) {
  	try{ insert insert_obj; return true; }
		catch(System.DmlException e){
			for (Integer i = 0; i < e.getNumDml(); i++) {
        		System.debug('ERROR...' + e.getDmlMessage(i));
	    	}
	    	return false;
		}
  }

  private static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	Profile doctor_profile = [select id from Profile where name = 'Clinical Doctor'];
  	Profile assistant_profile = [select id from Profile where name = 'Clinical Assistant'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	//insert m;
	just_playing_around(new List<Sobject> {m});
	
	Center_Information__c test_center = new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3,battlegroup_stars__c = 0);
	insert test_center;
	
    User my_test_user = new User(profileid = sys_admin_profile.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
	  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
	  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
    insert my_test_user;       
  }
  
  static testMethod void test_arch_delivery_change() {
    init();
    test.startTest();  
    
    Center_Information__c test_center = [select id,name from Center_Information__c where name = 'Test Script Center' limit 1];
    User test_user = [Select id,name from User where username = 'testu@clearchoice.com' limit 1];
        
    //generate a monthly center snapshot record
    Doctor_Mastery_Center_Snapshot__c center_test_snap = new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().month(), 
      Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_center.id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null);
    insert center_test_snap;
    
    //generate a clearchoice doctor record
    ClearChoice_Doctor__c test_doc = new ClearChoice_Doctor__c(Name = 'Test Doctor', Last_Name__c = 'Doctor', First_Name__c = 'Test', Email_Address__c = 'tdoc@clearchoice.com', Doctor_type__c = 'Prosthodontist', 
      Center_Information__c = test_center.id, Active__c = true, Total_Arches_Delivered__c = 200.00, Practice_Mastery_Completed__c = true, Practice_Mastery_2_Completed__c = true, 
      Practice_Leadership_Completed__c = true, Management_Essentials_Completed__c = true, Employee_Start_Date__c = System.today().addYears(-2),cce_credits__c = 25.0);
    insert test_doc;
    
    //generate a user snapshot record
    Doctor_Mastery_User_Snapshot__c test_snapshot = new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 200, Tenure_Years__c = 2, Month__c = System.today().month(), 
      ClearChoice_Doctor__c = test_doc.id, CCE_Credits__c = 25.0);
    insert test_snapshot;
    
    //update the arches delivered on the monthly center snpshot
    center_test_snap.arches_delivered__c = 175;
    update center_test_snap;
    
    //check the arches delivered on our clearchoice doctor record
    test_doc = [select id,total_arches_delivered__c from ClearChoice_Doctor__c where id = :test_doc.id];
    System.assertequals(test_doc.total_arches_delivered__c.intvalue(),375);
    
    //check the arches delivered on our user snapshot
    test_snapshot = [select id,total_arches_delivered__c from Doctor_Mastery_User_Snapshot__c where id = :test_snapshot.id];
    System.assertequals(test_snapshot.total_arches_delivered__c.intvalue(),375);
       
    test.stopTest();
  }  
  
  static testMethod void test_battlegroup_stars() {
  	init();
  	test.startTest();
  	
  	Center_Information__c test_center = [select id,name from Center_Information__c where name = 'Test Script Center' limit 1];
    User test_user = [Select id,name from User where username = 'testu@clearchoice.com' limit 1];
    
    //generate a clearchoice doctor record
    ClearChoice_Doctor__c test_doc = new ClearChoice_Doctor__c(Name = 'Test Doctor', Last_Name__c = 'Doctor', First_Name__c = 'Test', Email_Address__c = 'tdoc@clearchoice.com', Doctor_type__c = 'Prosthodontist', 
      Center_Information__c = test_center.id, Active__c = true, Total_Arches_Delivered__c = 200.00, Practice_Mastery_Completed__c = true, Practice_Mastery_2_Completed__c = true, 
      Practice_Leadership_Completed__c = true, Management_Essentials_Completed__c = true, Employee_Start_Date__c = System.today().addYears(-2),cce_credits__c = 25.0,battlegroup_stars__c = 0);
    insert test_doc;
    
    //add a center battlegroup star
    Battlestars.AddCenterStar(test_center.id);
    Battlestars.AddDoctorStar(test_doc.id);
    
    test_center = [select id,name,battlegroup_stars__c from Center_Information__c where id = :test_center.id];
    test_doc = [select id,name,battlegroup_stars__c from ClearChoice_Doctor__c where id = :test_doc.id];
    
    System.AssertEquals(test_center.battlegroup_stars__c.intvalue(),1);
    System.AssertEquals(test_doc.battlegroup_stars__c.intvalue(),2);  	
  	
  	test.stopTest();
  } 
}