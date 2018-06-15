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
 *
 * 2/23/2016 CM Code Coverage
 *  dp_admin_staff - 93%
 * 
 *
 */
@isTest
private class test_admin_staff {

  private static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	Profile doctor_profile = [select id from Profile where name = 'Clinical Doctor'];
  	Profile assistant_profile = [select id from Profile where name = 'Clinical Assistant'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c> test_centers = new List<Center_Information__c> {new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com'),
	  new Center_Information__c(Name = 'Unknown', Street_1__c = '', city__c = '', state__c = '',
	  zip_code__c = '', market__c = m.id, sales_market__c = m.id,cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Unknown'),
	  new Center_Information__c(Name = 'Denver', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com')
	  };
	insert test_centers;
	
    List<User> my_test_users = new List<User> {   new User(profileid = sys_admin_profile.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'),
	  new User(profileid = doctor_profile.id, email = 'testdoc@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testdoc', lastname = 'TDoctor', localesidkey='en_US', country='United States', username='testdoc@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_centers[0].name),
      new User(profileid = assistant_profile.id, email = 'testast@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testast', lastname = 'TAsst', localesidkey='en_US', country='United States', username='testasst@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_centers[0].name)
    };
	insert my_test_users;
	
	List<User_Center_Assignment__c> center_docs = new List<User_Center_Assignment__c> {
      new User_Center_Assignment__c(user__c = my_test_users[0].id, center_information__c = test_centers[0].id),
      new User_Center_Assignment__c(user__c = my_test_users[1].id, center_information__c = test_centers[0].id),
      new User_Center_Assignment__c(user__c = my_test_users[2].id, center_information__c = test_centers[0].id),
      new User_Center_Assignment__c(user__c = my_test_users[0].id, center_information__c = test_centers[1].id),
      new User_Center_Assignment__c(user__c = my_test_users[0].id, center_information__c = test_centers[2].id) 
	};
	insert center_docs;
	
	List<Navigation_Header__c> header_list = new List<Navigation_Header__c> { new Navigation_Header__c(Sub_System__c = 'Setup' , Name = 'Clinical'),
		new Navigation_Header__c(Sub_System__c = 'Setup' , Name = 'Facility'),
		new Navigation_Header__c(Sub_System__c = 'Gear' , Name = 'Gear')
	};
	insert header_list;
	List<Navigation_Page__c> page_list = new List<Navigation_Page__c> { new Navigation_Page__c(css_class__c = 'staff', Sort_Order__c = 1, Page_URL__c = 'apex/text', 
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#f5f5f5', Name = 'Staff', Image_Name__c = 'Images/nurse.png', Image_Name_Hover__c = 'Images/nurse_black.png'),
	  new Navigation_Page__c(css_class__c = 'pot', Sort_Order__c = 2, Page_URL__c = 'apex/text1', 
	  Navigation_Header__c = header_list[1].id, Nav_Color__c = '#e5e5e5', Name = 'Page 2'),
	  new Navigation_Page__c(css_class__c = 'logout', Sort_Order__c = 3, Page_URL__c = 'apex/text2', 
	  Navigation_Header__c = header_list[2].id, Nav_Color__c = '#c5c5c5', Name = 'Page 3')
	};
	insert page_list;
  }
  
  static testMethod void test_navigation_methods() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    das_controller.getgear_menu();
    
    try {
      das_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      das_controller.change_center();
    }
    
    try {
      das_controller.change_category_filter();
    } catch (Exception e) {
      //should fail - no cfilter
    }
        
    pageRef.getParameters().put('cfilter','All');  
    das_controller.change_category_filter();
    
    try {
      das_controller.change_active_view();
    } catch (Exception e) {
      //should fail - no afilter
    }
        
    pageRef.getParameters().put('afilter','Active');  
    das_controller.change_active_view();
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      das_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //cycle through nav items
    for(dp_navigation_header.menu_item mi : das_controller.getnavigation_menu()) {
      //tests for object methods if necessary
      if(mi.menu_type=='Page') {
        pageRef.getParameters().put('navid',mi.menu_id);    	
        PageReference newpage = das_controller.navigate_to();
      }
    }
    
    System.assertEquals(das_controller.getgear_menu().size(),1);
    
    //fail controller init
    pageRef.getParameters().put('ctrid','BAD CENTER ID');
    try {
      das_controller = new dp_admin_staff();
    } catch (Exception e) {
    	//this should fail
    }
    
    test.stopTest();
  }
  
  static testMethod void test_main_page_methods() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    //make sure we're in the test center
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        das_controller.change_center();
      }
    }
    
    das_controller.display_staff_info();
    
    //pull list of doctors
    System.assertequals(das_controller.getdoctor_list().size(),1);
    
    //pull list of assistants
    System.assertequals(das_controller.getassistant_list().size(),1);
    
    //check record counts
    System.assertequals(das_controller.getall_count(),2);
    System.assertequals(das_controller.getactive_count(),2);
    System.assertequals(das_controller.getinactive_count(),0);
    
    //change to inactive also add a quick search value
    das_controller.quick_search_field = 'T';
    das_controller.active_filter = 'Inactive';
    //pull list of doctors
    System.assertequals(das_controller.getdoctor_list().size(),0);
    
    //pull list of assistants
    System.assertequals(das_controller.getassistant_list().size(),0);
    
    
    test.stopTest();
  }
  
  static testMethod void test_general_info_methods() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    //make sure we're in the test center
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        das_controller.change_center();
      }
    }
    
    //fail switch to general info page
    pageRef.getParameters().put('staffid','Bad ID');
    try {
      das_controller.display_general_info();
    } catch (Exception e) {
      //this should fail
    }
    
    //fail update general info
    try {
      das_controller.save_general_info();
    } catch (Exception e) {
      //should fail as we have no selected staff member yet
    }
    
    //grab a doctor and navigation to the general info page
    for(User u : das_controller.getdoctor_list()) {
      pageRef.getParameters().put('staffid',u.id);  
      das_controller.display_general_info();      
    }
    
    //check record counts - should be zero since the test doctor has no license or eductaion records yet
    System.assertequals(das_controller.getall_count(),0);
    System.assertequals(das_controller.getactive_count(),0);
    System.assertequals(das_controller.getinactive_count(),0);
    
    //check license and education size - also 0 right now
    System.assertequals(das_controller.getlicense_size(),0);
    System.assertequals(das_controller.geteducation_size(),0);
    
    //show license form
    das_controller.new_license_form();
    
    //reset license form    
    das_controller.new_license.license_number__c = 'test';
    das_controller.reset_license_form();
    System.assertequals(das_controller.new_license.license_number__c,'Enter Number');
    
    //create new license
    //catch default value errors
    das_controller.save_new_license();
    //catch null detection errors
    das_controller.new_license.license_number__c = null;
    das_controller.new_license.license_type__c = null;
    das_controller.new_license.license_issue_date__c = null;
    das_controller.new_license.state_licensed_in__c = null;
    das_controller.new_license.license_expiration_date__c = null;
    das_controller.save_new_license();
    //catch expiration before issue error
    das_controller.new_license.license_number__c = '1234';
    das_controller.new_license.license_type__c = 'OSM';
    das_controller.new_license.license_issue_date__c = System.today();
    das_controller.new_license.state_licensed_in__c = 'Colorado';
    das_controller.new_license.license_expiration_date__c = System.today().adddays(-1);
    das_controller.save_new_license();
    //should pass
    das_controller.new_license.license_expiration_date__c = System.today().adddays(360);
    das_controller.save_new_license();
    das_controller.hide_license_form();
    
    //show education form
    das_controller.new_education_form();    
        
    //reset education form
    das_controller.new_education.school__c = 'Test';
    das_controller.reset_education_form();
    system.assertEquals(das_controller.new_education.school__c,'Enter School');
    
    //create new education
    //catch default value errors
    das_controller.save_new_education();
    //catch null detection errors
    das_controller.new_education.school__c = null;
    das_controller.new_education.graduation_year__c = null;
    das_controller.save_new_education();
    //graduation year 0 check
    das_controller.new_education.graduation_year__c = 0;
    das_controller.save_new_education();
    //should pass
    das_controller.new_education.school__c = 'John Hopkins';
    das_controller.new_education.graduation_year__c = 2016;
    das_controller.save_new_education();
    das_controller.hide_education_form();
    
    //check counts
    System.assertequals(das_controller.getlicense_size(),1);
    System.assertequals(das_controller.geteducation_size(),1);
    
    //work through license list and edit a record
    //this call should fail
    try {
      das_controller.current_edit = null;
      das_controller.edit_medical_license();
    } catch (Exception e) {
      //good
    }
    for(Medical_License__c ml : das_controller.getlicense_list()) {
      das_controller.current_edit = ml.id;
      das_controller.edit_medical_license();
      das_controller.new_license.license_number__c = 'Edited 1234';
      das_controller.save_new_license();
    }
    
    //work through education list and edit a record
    try {
      das_controller.current_edit = null;
      das_controller.edit_education();
    } catch (Exception e) {
      //also good
    }
    for(Education__c e : das_controller.geteducation_list()) {
      das_controller.current_edit = e.id;
      das_controller.edit_education();
      das_controller.new_education.degree__c = 'PHD';
      das_controller.save_new_education();
    }
    
    //deactivate license
    for(Medical_License__c ml : das_controller.getlicense_list()) {
      das_controller.activation_id = ml.id;
      das_controller.confim_activation_license();
      das_controller.update_activation_license();
    }
        
    //deactive education
    for(Education__c e : das_controller.geteducation_list()) {
      das_controller.activation_id = e.id;
      das_controller.confirm_activation_education();
      das_controller.update_activation_education();
    }
        
    //check counts
    System.assertequals(das_controller.getlicense_size(),0);
    System.assertequals(das_controller.geteducation_size(),0);
    das_controller.active_filter='Inactive';
    System.assertequals(das_controller.getlicense_size(),1);
    System.assertequals(das_controller.geteducation_size(),1);
    
    //reactivate license
    for(Medical_License__c ml : das_controller.getlicense_list()) {
      das_controller.activation_id = ml.id;
      das_controller.confim_activation_license();
      das_controller.update_activation_license();
    }
    
    //reactive education
    for(Education__c e : das_controller.geteducation_list()) {
      das_controller.activation_id = e.id;
      das_controller.confirm_activation_education();
      das_controller.update_activation_education();
    }
    
    //fail activation updates
    das_controller.activation_id = null;
    try {
      das_controller.update_activation_education();
    } catch (Exception e) {
      //good
    }
    try {
      das_controller.update_activation_license();
    } catch (Exception e) {
      //good
    }
    
    //check counts
    System.assertequals(das_controller.getlicense_size(),0);
    System.assertequals(das_controller.geteducation_size(),0);
    das_controller.active_filter='Active';
    System.assertequals(das_controller.getlicense_size(),1);
    System.assertequals(das_controller.geteducation_size(),1);    
    
    //test qsearch
    das_controller.quick_search_field = 'No MATCHES FOUND';
    System.assertequals(das_controller.getlicense_size(),0);
    System.assertequals(das_controller.geteducation_size(),0);    
        
    //edit general info (ssn, npi,  etc)
    das_controller.edit_general_info();
    das_controller.selected_staff_member.ssn__c = '123-123-1234';
    das_controller.reset_info_form();
    system.assertEquals(das_controller.selected_staff_member.ssn__c,null);
    das_controller.selected_staff_member.ssn__c = '123-123-1234';
    das_controller.save_general_info();
    das_controller.hide_info_form();    
    
    das_controller.close_modal();
    
    test.stopTest();
  }
  
  static testMethod void test_appointment_methods() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    //make sure we're in the test center
    Center_Information__c c;
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        das_controller.change_center();
        c = ci;
      }
    }
    
    //fail switch to general info page
    pageRef.getParameters().put('staffid','Bad ID');
    try {
      das_controller.display_appointment_info();
    } catch (Exception e) {
      //this should fail
    }
        
    //grab a doctor and navigation to the appointment page
    for(User u : das_controller.getdoctor_list()) {
      pageRef.getParameters().put('staffid',u.id);  
      das_controller.display_appointment_info();      
    }
    
    //probably need to create some appointments here
    List<Clinical_Appointment__c> cs_list = new List<Clinical_Appointment__c>{
      new Clinical_Appointment__c(name = 'Prosth Apt',appointment_description__c = 'A sample prosth apt',appointment_filter__c='Prosth',isactive__c=true,center_information__c = c.id),
      new Clinical_Appointment__c(name = 'Surgery Apt',appointment_description__c = 'A sample surgery apt',appointment_filter__c='Surgical',isactive__c=true,center_information__c = c.id),
      new Clinical_Appointment__c(name = 'Misc Apt',appointment_description__c = 'A sample misc apt',appointment_filter__c='Misc',isactive__c=true,center_information__c = c.id)
    };
    insert cs_list;
    
    //check count of allowed and blocked apts
    system.assertEquals(das_controller.getallowed_apts().size(),0);
    system.assertEquals(das_controller.getdisallowed_apts().size(),3);
    das_controller.quick_search_field = 'No MATCHES FOUND';
    system.assertEquals(das_controller.getallowed_apts().size(),0);
    system.assertEquals(das_controller.getdisallowed_apts().size(),0);
    das_controller.quick_search_field = null;
    das_controller.appointment_filter = 'Prosth';
    system.assertEquals(das_controller.getallowed_apts().size(),0);
    system.assertEquals(das_controller.getdisallowed_apts().size(),1);
    das_controller.appointment_filter = 'All';
    
    //fail authorize apt and block apt calls
    das_controller.activation_id = 'Bad ID';
    try {
      das_controller.authorize_apt();
    } catch (Exception e) {
      //good
    }
    try {
      das_controller.block_apt();
    } catch (Exception e) {
      //good
    }
    
    //work through apts and allow them
    for(Clinical_Appointment__c ca : das_controller.getdisallowed_apts()) {
      das_controller.activation_id = ca.id;
      das_controller.authorize_apt();
    }
    system.assertEquals(das_controller.getallowed_apts().size(),3);
    
    //work through apts and block them
    for(Clinical_DR_Authorized_apt__c ca : das_controller.getallowed_apts()) {
      das_controller.activation_id = ca.id;
      das_controller.block_apt();
    }
    system.assertEquals(das_controller.getallowed_apts().size(),0);
    
    //authorize all
    das_controller.authorize_all_apts();
    system.assertEquals(das_controller.getallowed_apts().size(),3);
    
    //block all
    das_controller.block_all_apts();
    system.assertEquals(das_controller.getallowed_apts().size(),0);
    
    system.assertEquals(das_controller.getall_apt_count(),3);
    system.assertEquals(das_controller.getprosth_count(),1);
    system.assertEquals(das_controller.getsurgical_count(),1);
    system.assertEquals(das_controller.getmisc_count(),1);

    test.stopTest();
  }
  
  static testMethod void test_calendar_methods() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    //make sure we're in the test center
    Center_Information__c c;
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        das_controller.change_center();
        c = ci;
      }
    }
    
    //fail switch to calendar page
    pageRef.getParameters().put('staffid','Bad ID');
    try {
      das_controller.display_calendar();
    } catch (Exception e) {
      //this should fail
    }
    
    //grab a doctor and navigation to the calendar page
    for(User u : das_controller.getdoctor_list()) {
      pageRef.getParameters().put('staffid',u.id);  
      das_controller.display_calendar();      
    }
    
    //grab calendar info
    dp_admin_staff.calendar_column[] cc = das_controller.getcalendar_info();
    
    //fail going to hours page
    try {
      das_controller.display_hours();
    } catch (Exception e) {
    	//maybe it'll fail
    }
    
    //go to the hours page
    pageRef.getParameters().put('sdow','2');
    pageRef.getParameters().put('shour','8');
    pageRef.getParameters().put('sminute','00');
    das_controller.display_hours();
    pageRef.getParameters().put('sdow','3');
    das_controller.display_hours();
    pageRef.getParameters().put('sdow','4');
    das_controller.display_hours();        
    
    pageRef.getParameters().put('sdow','1');
    pageRef.getParameters().put('shour','8');
    pageRef.getParameters().put('sminute','30');
    das_controller.display_hours();
    
    //save hours changes
    //catch null value error
    das_controller.save_hours_form();
    //catch lunch errors
    das_controller.edit_hours.lunch_start__c = '11:00 AM';
    das_controller.save_hours_form();    
    das_controller.edit_hours.lunch_end__c = '10:00 AM';
    das_controller.save_hours_form();    
    das_controller.edit_hours.lunch_end__c = '11:30 AM';
    //end before start error
    das_controller.edit_hours.end_time__c = '8:00 AM';
    das_controller.save_hours_form();
    //good save
    das_controller.edit_hours.end_time__c = '5:00 PM';
    das_controller.edit_hours.start_time__c = null;
    das_controller.save_hours_form();
    das_controller.edit_hours.start_time__c = '8:30 AM';
    das_controller.save_hours_form();
    
    //copy the schedule for the week
    das_controller.copy_hours();
    das_controller.copy_hours();    
          
    test.stopTest(); 
  }
  
  static testMethod void test_hours_methods() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    //make sure we're in the test center
    Center_Information__c c;
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        das_controller.change_center();
        c = ci;
      }
    }
    
    //grab a doctor and navigation to the calendar page
    for(User u : das_controller.getdoctor_list()) {
      pageRef.getParameters().put('staffid',u.id);  
      das_controller.display_calendar();      
    }
                    
    //go to the hours page
    pageRef.getParameters().put('sdow','2');
    pageRef.getParameters().put('shour','8');
    pageRef.getParameters().put('sminute','00');
    das_controller.display_hours();    
    
    //save hours changes    
    das_controller.edit_hours.lunch_start__c = '11:00 AM';  
    das_controller.edit_hours.lunch_end__c = '11:30 AM';
    das_controller.edit_hours.end_time__c = '5:00 PM';
    das_controller.edit_hours.start_time__c = '8:30 AM';
    das_controller.save_hours_form();
    
    //copy the schedule for the week
    das_controller.copy_hours();
        
    //grab calendar info now that we have the blocks
    dp_admin_staff.calendar_column[] cc = das_controller.getcalendar_info();
    
    //back to hours on a day with a record
    //hit the calendar again
    pageRef.getParameters().put('sdow','5');
    pageRef.getParameters().put('shour','14');
    pageRef.getParameters().put('sminute','00');
    das_controller.display_hours();  
    
    das_controller.reset_hours_form();
    das_controller.edit_hours_info();
    
    //remove an hours record
    das_controller.edit_hours.start_time__c = null;
    das_controller.edit_hours.end_time__c = null;
    das_controller.edit_hours.lunch_start__c = null;
    das_controller.edit_hours.lunch_end__c = null;
    das_controller.save_hours_form();
          
    test.stopTest(); 
  }
  
  static testMethod void test_hours_extra_navigation() {
    init();
    test.startTest();
    
    dp_admin_staff das_controller = new dp_admin_staff();
    PageReference pageref = new PageReference('/apex/ccare_bend_staff');
    Test.setCurrentPage(pageRef);
    
    //make sure we're in the test center
    Center_Information__c c;
    for(Center_Information__c ci : das_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        das_controller.change_center();
        c = ci;
      }
    }
    
    //grab a doctor and navigation to the calendar page
    for(User u : das_controller.getdoctor_list()) {
      pageRef.getParameters().put('staffid',u.id);  
      das_controller.display_calendar();      
    }
    
    pageRef.getParameters().put('sdow','1');
    pageRef.getParameters().put('shour','14');
    pageRef.getParameters().put('sminute','00');
    das_controller.display_hours();  
    das_controller.edit_hours_info();
    pageRef.getParameters().put('sdow','2');
    das_controller.edit_hours_info();
    pageRef.getParameters().put('sdow','3');
    das_controller.edit_hours_info();
    pageRef.getParameters().put('sdow','4');
    das_controller.edit_hours_info();
    
    das_controller.modal_type = 'na';
    test.stopTest();
  }
}