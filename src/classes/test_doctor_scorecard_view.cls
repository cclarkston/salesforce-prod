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
private class test_doctor_scorecard_view {

  private static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	
	List<Center_Information__c> test_centers = new List<Center_Information__c> {new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3,battlegroup_stars__c = 0),
	  new Center_Information__c(Name = 'Test Center2', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center2',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3,battlegroup_stars__c = 10)
	};
	insert test_centers;	 
	
	//generate some monthly center snapshot records
    List<Doctor_Mastery_Center_Snapshot__c> center_test_snapshots = new List<Doctor_Mastery_Center_Snapshot__c> {
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_centers[0].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().addmonths(-1).year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().addmonths(-1).month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_centers[0].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 30, NPS_Score__c = 65.0, Month__c = System.today().month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 80.0, Center_Information__c = test_centers[1].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 30, NPS_Score__c = 65.0, Month__c = System.today().addmonths(-1).month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 80.0, Center_Information__c = test_centers[1].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00)      
    };
    insert center_test_snapshots;
    
    //generate a clearchoice doctor record
    List<ClearChoice_Doctor__c> test_docs = new List<ClearChoice_Doctor__c> {new ClearChoice_Doctor__c(Name = 'Test Doctor', Last_Name__c = 'Doctor', First_Name__c = 'Test', Email_Address__c = 'tdoc@clearchoice.com', Doctor_type__c = 'Prosthodontist', 
      Center_Information__c = test_centers[0].id, Active__c = true, Total_Arches_Delivered__c = 200.00, Practice_Mastery_Completed__c = true, Practice_Mastery_2_Completed__c = true, 
      Practice_Leadership_Completed__c = true, Pacesetter__c = true, Employee_Start_Date__c = System.today().addYears(-2),cce_credits__c = 25.0),
      new ClearChoice_Doctor__c(Name = 'Testing Doctor2', Last_Name__c = 'Doctor2', First_Name__c = 'Testing', Email_Address__c = 'tdoc2@clearchoice.com', Doctor_type__c = 'Prosthodontist', 
      Center_Information__c = test_centers[1].id, Active__c = true, Total_Arches_Delivered__c = 500.00, Practice_Mastery_Completed__c = true, Practice_Mastery_2_Completed__c = true, 
      Practice_Leadership_Completed__c = true, Pacesetter__c = true, Employee_Start_Date__c = System.today().addYears(-7),cce_credits__c = 800.0)
    };
    insert test_docs;
    
    //generate a user snapshot record
    List<Doctor_Mastery_User_Snapshot__c> test_snapshot = new List<Doctor_Mastery_User_Snapshot__c> {new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 200, Tenure_Years__c = 2, Month__c = System.today().month(), 
      ClearChoice_Doctor__c = test_docs[0].id, CCE_Credits__c = 25.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[0].id,Battlegroup_stars__c = 2,scorecard_completed__c = true),
      new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 200, Tenure_Years__c = 2, Month__c = System.today().addmonths(-1).month(), 
      ClearChoice_Doctor__c = test_docs[0].id, CCE_Credits__c = 25.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[1].id,Battlegroup_stars__c = 0,scorecard_completed__c = true),
      new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 600, Tenure_Years__c = 2, Month__c = System.today().month(), 
      ClearChoice_Doctor__c = test_docs[1].id, CCE_Credits__c = 800.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[2].id,Battlegroup_stars__c = 10,scorecard_completed__c = true),
      new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 1000, Tenure_Years__c = 2, Month__c = System.today().addmonths(-1).month(), 
      ClearChoice_Doctor__c = test_docs[1].id, CCE_Credits__c = 300.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[3].id,Battlegroup_stars__c = 4,scorecard_completed__c = true)
    };
    insert test_snapshot;
    
    List<Doctor_Mastery_Threshold__c> test_thresholds = new List<Doctor_Mastery_Threshold__c> {
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Arches Delivered', Distance_to_Fellow__c =500, Distance_to_Diplomate__c = 750, Distance_to_Clinical_Director__c =1000, Distance_to_Associate__c=250, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Battlegroup Stars', Distance_to_Fellow__c =2, Distance_to_Diplomate__c = 4, Distance_to_Clinical_Director__c =6, Distance_to_Associate__c=0, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'NPS', Distance_to_Fellow__c =40, Distance_to_Diplomate__c = 50, Distance_to_Clinical_Director__c =60, Distance_to_Associate__c=0, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Gross Margin', Distance_to_Fellow__c =50, Distance_to_Diplomate__c = 65, Distance_to_Clinical_Director__c =80, Distance_to_Associate__c=0, year__c = System.today().year()),	
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'CCE Hours', Distance_to_Fellow__c =350, Distance_to_Diplomate__c = 500, Distance_to_Clinical_Director__c =650, Distance_to_Associate__c=200, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'less than', Name = 'Surgical Backlog', Distance_to_Fellow__c =63, Distance_to_Diplomate__c = 49, Distance_to_Clinical_Director__c =28, Distance_to_Associate__c=999, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Service Years', Distance_to_Fellow__c =2, Distance_to_Diplomate__c = 3, Distance_to_Clinical_Director__c =4, Distance_to_Associate__c=0, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'OCI', Distance_to_Fellow__c =0, Distance_to_Diplomate__c = 65, Distance_to_Clinical_Director__c =75, Distance_to_Associate__c=0, year__c = System.today().year())
    };
    insert test_thresholds;    
  }
  
  static testMethod void test_battlegroup_stars() {
  	init();
  	test.startTest();
  	
  	dr_mastery_scorecard ctrl_card = new dr_mastery_scorecard();
  	ctrl_card.getis_admin();
  	
  	//call month options before setting user
  	ctrl_card.getmonth_option_list();
  	
  	System.assert(ctrl_card.getscorecard_name()=='NA');
  	List<selectOption> user_list = ctrl_card.getuser_option_list();
  	System.assert(user_list.size()==3);  	
  	
  	
  	ctrl_card.scorecard_user = user_list[1].getvalue();  	  	
  	System.assert(ctrl_card.getscorecard_name()==user_list[1].getlabel());
  	ctrl_card.refresh_scorecard();
  	
  	System.assert(ctrl_card.getmonth_option_list().size()>=1);
  	System.assert(ctrl_card.getyear_option_list().size()>=1);
  	
  	for(selectoption u : user_list) {
  	  if(u.getvalue()!='NA') {
  	  	ctrl_card.scorecard_user = user_list[1].getvalue();
  	    ctrl_card.refresh_scorecard();  
  	    ctrl_card.getgross_margin_target_text();
  	    ctrl_card.scorecard.getcce_mastery_level_text();
	  	ctrl_card.scorecard.getin_network_mastery_text();
	  	ctrl_card.scorecard.getcoe_mastery_text();
	  	ctrl_card.scorecard.getoverall_mastery_level();
	  	ctrl_card.scorecard.getoverall_next_steps();
	  	ctrl_card.scorecard.getcce_next_steps();
	  	ctrl_card.scorecard.getnetwork_next_steps();
	  	ctrl_card.scorecard.getcoe_next_steps();
	  	ctrl_card.scorecard.getdetails_table_html();
	  	ctrl_card.getrender_scorecard();
	  	ctrl_card.getformatted_card_date();	
  	  }
  	} 
  	
  	test.stopTest();
  }
}