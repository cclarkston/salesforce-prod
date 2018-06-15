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
private class test_centerdays {
	
	
	private static void init() {
	  Market__c m = new Market__c(Name = 'Test Market');
	  Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,sales_region__c = 'Midwest' );
	  insert test_center; 
	  Profile p = [select id from Profile where name = 'System Administrator'];		
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',clinic_calendar__c = 'Austin', center_pec__c = test_center.id);
	  insert my_test_user;
	  Schedule_Templates__c test_template = new Schedule_Templates__c(Name = 'Test Any Day Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true, 
		  Saturday__c = true,  Sunday__c = true);
	  insert test_template;
	  Template_Apt__c[] test_templates = new Template_Apt__c[] {new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Purple', Ending_Hour__c = '9', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '9', starting_minutes__c = '5'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Brown', Ending_Hour__c = '12', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Any',
		  schedule_template__c = test_template.id, start_hour__c = '11', starting_minutes__c = '10'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Red', Ending_Hour__c = '13', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow Only',
		  schedule_template__c = test_template.id, start_hour__c = '12', starting_minutes__c = '50'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Green', Ending_Hour__c = '15', Ending_Minutes__c = '40', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '14', starting_minutes__c = '00')};
      insert test_templates;
      Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id, active__c = true);
	  insert test_room;
	  System.runas(my_test_user) {
	    ctrl_consultschedule my_ext = new ctrl_consultschedule();
        my_ext.build_room_inventory(test_room,System.today());
	  } 
	}

    static testMethod void myUnitTest() {
      // TO DO: implement unit test
      init();
  	  test.startTest();
  	
  	  Pagereference pageref = new PageReference('/apex/center_days');
      Test.setCurrentPage(pageRef);
      User my_test_user = [select id,name from User where username = 'testu@clearchoice.com'];      
      System.runAs(my_test_user) {
        ctrl_centerdays cd = new ctrl_centerdays();
        cd.create_new_center_days();
        cd.current_date.getformatted_status_text();
        cd.getstatus_color();
        cd.getcenter_total_open_days();
        cd.getRBD_email();
      }
      Center_Information__c test_center = [select id,sales_region__c from center_information__c limit 1];
      test_center.sales_region__c = 'Northeast';
      pageRef.getParameters().put('cid',test_center.id);
      ctrl_centerdays cd = new ctrl_centerdays();
      cd.create_new_center_days();
      cd.getRBD_email();
      update test_center;
      cd.getRBD_email();
      test_center.sales_region__c = 'Northwest';
      update test_center;
      cd.getRBD_email();
      test_center.sales_region__c = 'Southeast';
      update test_center;
      cd.getRBD_email();
      test_center.sales_region__c = 'Southwest';
      update test_center;
      cd.getRBD_email();
      test_center.sales_region__c = 'Texas';
      update test_center;
      cd.getRBD_email();
      cd.getdisplay_admin();
      cd.getdisplay_foa();
      List<List<String>> month_list = cd.getmonth_list();
      List<List<Integer>> year_list = cd.getyear_list();
      cd.getselected_year();
      cd.getselected_monthname();
      cd.getcmonth();
      cd.display_months();
      cd.display_years();
      cd.getcenter_list();
      cd.getfoa_center_list();
      cd.getselected_center_calendar_name();
      cd.close_modal();
      
      test.stoptest();
    }
    
    static testMethod void calendar_navigation() {
      // TO DO: implement unit test
      init();
  	  test.startTest();
  	  
  	  Pagereference pageref = new PageReference('/apex/center_days');
      Test.setCurrentPage(pageRef);
      User my_test_user = [select id,name from User where username = 'testu@clearchoice.com'];      
      System.runAs(my_test_user) {
        ctrl_centerdays cd = new ctrl_centerdays();
        cd.create_new_center_days();
        cd.current_date.getformatted_status_text();
        cd.getstatus_color();
        cd.getcenter_total_open_days();
        cd.getRBD_email();
        cd.add_month();
        cd.subtract_month();
        pageRef.getParameters().put('mnum','1');
        cd.change_month();
        cd.create_new_center_days();
        pageRef.getParameters().put('mnum','4');
        cd.change_month();
        cd.create_new_center_days();
        pageRef.getParameters().put('mnum','7');
        cd.change_month();
        cd.create_new_center_days();
        pageRef.getParameters().put('mnum','10');
        cd.change_month();
        cd.create_new_center_days();
        pageRef.getParameters().put('mday','7');
        cd.change_calendar_day();
        cd.create_new_center_days();
        pageRef.getParameters().put('cyear','2018');
        cd.change_calendar_year();
        cd.change_center();        
        
      }
  	  
  	  test.stoptest();
    }
    
    static testMethod void buildout_options() {
      // TO DO: implement unit test
      init();
  	  test.startTest();
  	  
  	  Pagereference pageref = new PageReference('/apex/center_days');
      Test.setCurrentPage(pageRef);
      User my_test_user = [select id,name from User where username = 'testu@clearchoice.com'];      
      System.runAs(my_test_user) {
        ctrl_centerdays cd = new ctrl_centerdays();
        cd.create_new_center_days();
        Integer day_count = [Select count() from Center_Open_Day__c];
        
        Date sdate = Date.newinstance(system.today().year(),system.today().month(),system.today().day());

        Center_Open_Day__c cod = [Select id,calendar_date__c from Center_Open_Day__c where center_information__c = :cd.selected_center and calendar_date__c >= :sdate  limit 1];
        cd.selected_date = cod.calendar_date__c;
        cd.current_date = new ctrl_centerdays.Center_Day(cd.selected_center,cd.selected_date);
        
        cd.display_close_form();
        cd.open_center();
        cd.getclose_requests();
        cd.submit_build_out();
        
        
        
        cd.deny_build_out();
        cd.deny_holder.denied_reason__c='1';
        cd.deny_build_out();
        cd.deny_holder.denied_reason__c='Success';
        cd.deny_build_out();
        
        cd.submit_build_out();
        cd.getformatted_qtr_date();
        cd.current_date.getformatted_status_text();
        cd.getstatus_color();
        cd.approve_build_out();
        
        cd.display_close_form();
        cd.create_new_center_days();
        System.debug('Selected Date : ' + cd.selected_date);
        System.debug('Selected Center : ' + cd.selected_center);
        cd.update_center_day();
        cd.current_date.cd.closed_reason__c='testing';
        cd.update_center_day();
        cd.current_date.cd.closed_note__c='1';
        cd.update_center_day();
        cd.current_date.cd.closed_note__c='Success';
        Close_Request__c cr = [select id,denied_reason__c from Close_Request__c cr limit 1];
        pageRef.getParameters().put('cdid',cod.id);
        cd = new ctrl_centerdays();
        pageRef.getParameters().put('crid',cr.id);
        cd = new ctrl_centerdays();
        cd.getclose_requests();
        cd.deny_close_request();
        cr.denied_reason__c = '1';
        update cr;
        cd.deny_close_request();
        cr.denied_reason__c = 'testing';
        update cr;
        cd.deny_close_request();
        cd.current_date = new ctrl_centerdays.Center_Day(cd.selected_center,cd.selected_date);
        cd.current_date.getformatted_status_text();
        cd.open_center();
        cd.approve_close_request();
        
        cd.reset_build_out();
      }
  	  
  	  test.stoptest();
    }
}