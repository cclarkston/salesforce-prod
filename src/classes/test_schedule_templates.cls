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
private class test_schedule_templates {
	static ctrl_schedule_template my_ext;
	
	static Center_Information__c test_center;
	static Schedule_Templates__c test_template;
	static Template_Apt__c test_temp_apt;
	static Consult_Rooms__c test_room;
	static Consult_Rooms__c test_room2;
	
  static User my_test_user;
	static Pagereference pageref;

  static {
  	//generate a test user id to use below
		Profile p = [select id from Profile where name = 'System Administrator'];		
		my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
  }
 
	private static void init() {
		Market__c m = [select id from Market__c limit 1];
		test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,calendar_name__c = 'Test Center' );
	  insert test_center; 
		test_template = new Schedule_Templates__c(Name = 'Test Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = false, 
		  Saturday__c = false,  Sunday__c = false);
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
		  schedule_template__c = test_template.id, start_hour__c = '14', starting_minutes__c = '00'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Grey', Ending_Hour__c = '16', Ending_Minutes__c = '45', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '15', starting_minutes__c = '45'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Yellow', Ending_Hour__c = '17', Ending_Minutes__c = '50', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '16', starting_minutes__c = '50'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Orange', Ending_Hour__c = '18', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '17', starting_minutes__c = '55')}; 
		insert test_templates;
		test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id);
		insert test_room;
		test_room2 = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 2', Room_Type__c = 'Manual', Schedule_Template__c = test_template.id);
		insert test_room2;
					  	  
    my_ext = new ctrl_schedule_template();    	     
    pageref = Page.manage_schedule_templates;
    Test.setCurrentPage(pageref);     			
	}
	
		static testMethod void TemplateSearch() {
		  init();		
		  test.startTest();
		  		  
		  my_ext.name_filter = 'Test Template';
		  my_ext.center_filter = test_center.id;
		  //test seach with name - verify we find at least our test template
		  List<Schedule_Templates__c> search_results = my_ext.getTemplateList();
		  System.assert(search_results.size()>0);
      my_ext.name_filter = 'jsdfhgyaweguefg';
		  search_results = my_ext.getTemplateList();
		  System.assertEquals(search_results.size(),0);
		  test.stopTest();
		}
		
		static testMethod void GeneralTests() {
			init();
			test.startTest();
			
			my_Ext.new_template_form();
			List<Selectoption> center_options = my_ext.getCenterlist();
			List<Center_Information__c> all_centers = [select id from Center_Information__c];
			//subtract 1 because of the default option
			System.assertEquals((center_options.size()-1), all_centers.size());
			my_ext.my_template.name = 'Insert Template';
		  my_ext.new_template();
			
			test.stopTest();
		}
		
	  static testMethod void view_update_modify_methods() {
			init();
			test.startTest();
			
      pageref = new PageReference('/apex/manage_schedule_templates?tid=' + test_template.Id);
		  Test.setCurrentPage(pageref);
		  my_ext = new ctrl_schedule_template();
		  my_ext.template_view();  
		  List<Template_Apt__c> all_apts = my_ext.getexisting_apts();
		  system.assertEquals(all_apts.size(), 8);
		  my_ext.my_template.Name = 'Updated Template Name';
		  my_ext.update_template();

		  List<ctrl_schedule_template.Calendar_Rows> cal_entries = my_ext.getview_calendar();
			for(ctrl_schedule_template.Calendar_Rows cal_row : cal_entries) {
				String label = cal_row.getrow_label();
				for(ctrl_schedule_template.Calendar_Apts cal_apts : cal_row.row_apts) {
					cal_apts.getstart_time();
					cal_apts.getend_time();
					cal_apts.getprescreen_label();
				}
			}
			
			all_apts[0].Starting_Minutes__c = '30';
		  my_ext.modify_apts();
		  all_apts[0].Start_Hour__c = '23';
		  my_ext.modify_apts();
		  System.assert(my_ext.update_errors.contains('End Time must be greater than Start Time'));
		  
		  all_apts[0].Start_Hour__c = '26';
		  all_apts[0].Starting_Minutes__c = '65';
		  all_apts[0].Ending_Hour__c = '26';
		  all_apts[0].Ending_Minutes__c = '65';
		  my_ext.modify_apts();
		  System.assert(my_ext.update_errors.contains('Starting Hour must be a number between 0 and 23'));
		  System.assert(my_ext.update_errors.contains('Starting Minutes must be a number between 0 and 59'));
		  System.assert(my_ext.update_errors.contains('Ending Hour must be a number between 0 and 23'));
		  System.assert(my_ext.update_errors.contains('Ending Minutes must be a number between 0 and 59'));
		  
		  all_apts[0].Start_Hour__c = 'A';
		  all_apts[0].Starting_Minutes__c = 'ab';
		  all_apts[0].Ending_Hour__c = 'A';
		  all_apts[0].Ending_Minutes__c = 'ab';
		  all_apts[0].pre_screen_type__c = null;
		  all_apts[0].color_code__c = null;		 		  
		  try {
		    my_ext.modify_apts();
		  } catch (DmlException e) {
		    System.assert(my_ext.update_errors.contains('Starting Hour must be a number between 0 and 23'));
		    System.assert(my_ext.update_errors.contains('Starting Minutes must be a number between 0 and 59'));
		    System.assert(my_ext.update_errors.contains('Ending Hour must be a number between 0 and 23'));
		    System.assert(my_ext.update_errors.contains('Ending Minutes must be a number between 0 and 59'));
		  }
		  
		  my_ext.new_apt.start_hour__c = '8';
		  my_ext.new_apt.starting_minutes__c = '30';
		  my_ext.new_apt.ending_hour__c = '9';
		  my_ext.new_apt.ending_minutes__c = '45';
		  my_ext.new_apt.pre_screen_type__c = 'Any';
		  my_ext.new_apt.color_code__c = 'Light Blue';
		  my_ext.new_apt();
		  
		  my_ext.getdisplay_admin();
		  my_ext.getdisplay_cc_sup();
		  my_ext.getdisplay_confirmation();
			
			test.stopTest();
		}
}