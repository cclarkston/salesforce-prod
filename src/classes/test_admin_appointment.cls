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
 *
 * 2/25/2016 CM Code Coverage
 *  dp_admin_appointment - 89%
   7/1/2016 CM Code Coverage - 90%
   4/10/2018 - 90%
 *
 */
@isTest
private class test_admin_appointment {

  @testSetup private static void init() {
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
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#f5f5f5', Name = 'Appointments', Image_Name__c = 'Images/nurse.png', Image_Name_Hover__c = 'Images/nurse_black.png'),
	  new Navigation_Page__c(css_class__c = 'pot', Sort_Order__c = 2, Page_URL__c = 'apex/text1', 
	  Navigation_Header__c = header_list[1].id, Nav_Color__c = '#e5e5e5', Name = 'Page 2'),
	  new Navigation_Page__c(css_class__c = 'logout', Sort_Order__c = 3, Page_URL__c = 'apex/text2', 
	  Navigation_Header__c = header_list[2].id, Nav_Color__c = '#c5c5c5', Name = 'Page 3')
	};
	insert page_list;
	
	//need some clinical procedures to use with the appointments
	List<Clinical_Procedure__c> cp_list = new List<Clinical_Procedure__c> {
      new Clinical_Procedure__c(name = 'Prosth Test',procedure_description__c = 'Prosth Test procedure',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = test_centers[0].id, time_required__c = 10),
      new Clinical_Procedure__c(name = 'Surgery Test',procedure_description__c = 'Surgery Test procedure',isactive__c = true, procedure_filter__c = 'Surgical', center_information__c = test_centers[0].id, time_required__c = 10),
      new Clinical_Procedure__c(name = 'Misc Test',procedure_description__c = 'Misc Test procedure',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id, time_required__c = 30)
    };    
    insert cp_list;
  }
  
  static testMethod void test_navigation_methods() {
   // init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    daa_controller.getgear_menu();
    
    try {
      daa_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : daa_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      daa_controller.change_center();
    }
    
    try {
      daa_controller.change_category_filter();
    } catch (Exception e) {
      //should fail - no cfilter
    }
        
    pageRef.getParameters().put('cfilter','All');  
    daa_controller.change_category_filter();
    
    try {
      daa_controller.change_active_view();
    } catch (Exception e) {
      //should fail - no afilter
    }
        
    pageRef.getParameters().put('afilter','Active');  
    daa_controller.change_active_view();
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      daa_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //cycle through nav items
    for(dp_navigation_header.menu_item mi : daa_controller.getnavigation_menu()) {
      //tests for object methods if necessary
      if(mi.menu_type=='Page') {
        pageRef.getParameters().put('navid',mi.menu_id);    	
        PageReference newpage = daa_controller.navigate_to();
      }
    }
    
    System.assertEquals(daa_controller.getgear_menu().size(),1);
    
    //fail controller init
    pageRef.getParameters().put('ctrid','BAD CENTER ID');
    try {
      daa_controller = new dp_admin_appointment();
    } catch (Exception e) {
    	//this should fail
    }
    
    daa_controller.close_modal();
    
    test.stopTest();
  }
  
  static testMethod void test_appointment_main() {
    //init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    for(Center_Information__c ci : daa_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        daa_controller.change_center();
      }
    }
    
    //check our counts
    system.assertEquals(daa_controller.getall_count(),0);
    system.assertEquals(daa_controller.getactive_count(),0);
    system.assertEquals(daa_controller.getinactive_count(),0);
    system.assertEquals(daa_controller.getprosth_count(),0);
    system.assertEquals(daa_controller.getsurgical_count(),0);
    system.assertEquals(daa_controller.getmisc_count(),0);
    
    //new appointment form
    daa_controller.new_appointment_form();
    
    //reset appointment form
    daa_controller.new_appointment.name = 'Test';
    daa_controller.reset_appointment_form();
    system.assertEquals(daa_controller.new_appointment.name,'Enter Apt Name');
        
    //save new appointment
    //test default value check
    daa_controller.save_new_appointment();    
    //test null checks
    daa_controller.new_appointment.name = null;
    daa_controller.new_appointment.appointment_description__c = null;
    daa_controller.new_appointment.appointment_filter__c = null;
    daa_controller.save_new_appointment();    
    //good save
    daa_controller.new_appointment.name = 'Prosth Exam';
    daa_controller.new_appointment.appointment_description__c = 'Posth Exam Appointment';
    daa_controller.new_appointment.appointment_filter__c = 'Prosth';
    daa_controller.save_new_appointment();    
    
    //duplicate check
    daa_controller.new_appointment_form();
    daa_controller.getdays_out_text();
    daa_controller.new_appointment.lab_days_before__c = 7;
    daa_controller.getdays_out_text();
    daa_controller.new_appointment.name = 'Prosth Exam';
    daa_controller.new_appointment.appointment_description__c = 'Posth Exam Appointment';
    daa_controller.new_appointment.appointment_filter__c = 'Prosth';
    daa_controller.save_new_appointment();    
        
    //create an appointment for each category
    daa_controller.new_appointment_form();
    daa_controller.new_appointment.name = 'Surgery AO4';
    daa_controller.new_appointment.appointment_description__c = 'Test surgery appointment';
    daa_controller.new_appointment.appointment_filter__c = 'Surgical';
    daa_controller.save_new_appointment();
    daa_controller.new_appointment_form();
    daa_controller.new_appointment.name = 'Repair Frac Bar';
    daa_controller.new_appointment.appointment_description__c = 'Test misc appointment';
    daa_controller.new_appointment.appointment_filter__c = 'Misc';
    daa_controller.toggle_repair();
    daa_controller.save_new_appointment();
    
    //pull lists
    List<Clinical_Appointment__c> ca_list = daa_controller.getprosth_list();
    system.assertEquals(ca_list.size(),1);
    ca_list = daa_controller.getsurgical_list();
    system.assertEquals(ca_list.size(),1);
    ca_list = daa_controller.getmisc_list();
    system.assertEquals(ca_list.size(),1);
    
    //fail edit call?
    try {
      daa_controller.current_edit = 'BAD ID';
      daa_controller.edit_clinical_appointment();
    } catch (Exception e) {
      //good
    }
        
    //edit appointment
    for(Clinical_Appointment__c ca : ca_list) {
      daa_controller.current_edit = ca.id;
      daa_controller.edit_clinical_appointment();
      daa_controller.new_appointment.name = 'Misc test Appointment';
      daa_controller.edit_lab_time();
      daa_controller.edit_padding();
      daa_controller.save_new_appointment();
    }
        
    //fail activation call
    try {
      daa_controller.activation_id = 'BAD ID';
      daa_controller.update_activation_appointment();
    } catch (Exception e) {
      //good
    }    
        
    //activate/deactivate appointment
    for(Clinical_Appointment__c ca : ca_list) {
      daa_controller.activation_id = ca.id;
      daa_controller.confim_activation_appointment();
      daa_controller.update_activation_appointment();
      system.assertEquals(daa_controller.getinactive_count(),1);      
      daa_controller.activation_id = ca.id;
      daa_controller.update_activation_appointment();
      system.assertEquals(daa_controller.getinactive_count(),0);
    }
        
    //test qsearch
    daa_controller.active_filter = 'Inactive';
    daa_controller.quick_search_field = 'Test';
    system.assertEquals(daa_controller.getprosth_list().size(),0);
    daa_controller.active_filter = 'Active';
    daa_controller.category_filter = 'Surgical';
    system.assertEquals(daa_controller.getsurgical_list().size(),1);   
    
    daa_controller.save_notes_form(); 
    daa_controller.edit_notes_form();
    daa_controller.toggle_final_delivery();
    daa_controller.toggle_surgery();
    daa_controller.toggle_prosth_exam();
  }
  
  static testMethod void test_appointment_scheduling() {
    //init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : daa_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        daa_controller.change_center();
        c = ci;
      }
    }
    
    //fail padding save
    try {
      daa_controller.save_padding_form();
    } catch (Exception e) {
      //good
    }    
    
    //fail going to scheduling page
    try {
      pageRef.getParameters().put('aptid','BAD ID');  
      daa_controller.display_scheduling_info();
    } catch (Exception e) {
      //good
    }
    
    //create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Prosth Apt' , appointment_description__c = 'Example Prosth Apt', appointment_filter__c = 'Prosth' , center_information__c = c.id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Surgery Apt' , appointment_description__c = 'Example Surgery Apt', appointment_filter__c = 'Surgical' , center_information__c = c.id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Misc Apt' , appointment_description__c = 'Example Misc Apt', appointment_filter__c = 'Misc' , center_information__c = c.id, isactive__c = true)
    };
    insert ca_list;
    
    //navigate to scheduling page
    pageRef.getParameters().put('aptid',ca_list[0].id);  
    daa_controller.display_scheduling_info();

    //display new procedure form
    daa_controller.new_procedure_form();
    
    //get category options
    daa_controller.getprocedure_category_list();
    
    //hide form and then redisplay form
    daa_controller.hide_procedure_form();
    daa_controller.new_procedure_form();
        
    //reset procedure form
    daa_controller.new_proc_name = 'Test';
    daa_controller.procedure_filter = 'Surgical';
    daa_controller.reset_procedure_form();
    system.assertEquals(daa_controller.new_proc_name,'Enter procedure');
    system.assertEquals(daa_controller.procedure_filter,'All');    
    
    //get procedure search results
    daa_controller.new_proc_name = 'Prosth';
    daa_controller.procedure_filter = 'Prosth';
    List<Clinical_Procedure__c> cp_list = daa_controller.getsearch_procedures();
    daa_controller.new_procedure_form();
    cp_list = daa_controller.getsearch_procedures();
    
    //add a procedure by name
    //fail with no match
    daa_controller.add_procedure_step();
    //select a procedure from list
    System.debug('CP LIST : ' + cp_list.size());
    pageRef.getParameters().put('prid',cp_list[0].id);
    daa_controller.select_procedure();  
        
    //select a duplicate procedure
    daa_controller.select_procedure();
     
    //add the rest of our procedures
    daa_controller.new_procedure_form();
    
    for(Clinical_Procedure__c cp : daa_controller.getsearch_procedures()) {
      pageRef.getParameters().put('prid',cp_list[0].id);
      daa_controller.select_procedure();  
    }
    
    //modify sort order
    //fail 
    try {
     pageRef.getParameters().put('pthru','BAD ID1&BAD ID 2');
     daa_controller.modify_sort_order();
    } catch (Exception e) {
      //good
    }
    
    //success
    String pthru = '';
    for(Clinical_Apt_Procedure__c cp : daa_controller.getprocedure_steps()) {
      pthru = cp.id + '&';
    }
    pthru += '';
    try {
      pageRef.getParameters().put('pthru',pthru);
      daa_controller.modify_sort_order();
    } catch (Exception e) {
      
    }
        
    //fail procedure removal
    try {
      daa_controller.activation_id = 'BAD ID';
      daa_controller.delete_appointment_procedure();
    } catch (Exception e) {
      //good
    }
    
    daa_controller.gettotal_apt_time();
    
    //pull list of procedures
    for(Clinical_Apt_Procedure__c cp : daa_controller.getprocedure_steps()) {
      //remove a procedure
      daa_controller.activation_id = cp.id;
      daa_controller.confim_remove_procedure();
      daa_controller.delete_appointment_procedure();
    } 
    
    //work on padding stuff
    daa_controller.edit_padding();
    daa_controller.reset_padding_form();
    daa_controller.save_padding_form();    
    daa_controller.hide_padding_form();
    
    //lab time calls
    daa_controller.edit_lab_time();
    daa_controller.hide_lab_time_form();
    
    //arch count calls 
    daa_controller.toggle_arch_count_display();
    
    daa_controller.back_to_appointments();
    
    test.stopTest();
  }
  
  static testMethod void test_appointment_room() {
    //init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : daa_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        daa_controller.change_center();
        c = ci;
      }
    }
    
    //fail going to scheduling page
    try {
      pageRef.getParameters().put('aptid','BAD ID');  
      daa_controller.display_room_info();
    } catch (Exception e) {
      //good
    }
    
    //create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Prosth Apt' , appointment_description__c = 'Example Prosth Apt', appointment_filter__c = 'Prosth' , center_information__c = c.id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Surgery Apt' , appointment_description__c = 'Example Surgery Apt', appointment_filter__c = 'Surgical' , center_information__c = c.id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Misc Apt' , appointment_description__c = 'Example Misc Apt', appointment_filter__c = 'Misc' , center_information__c = c.id, isactive__c = true)
    };
    insert ca_list;
    
    //create some rooms
    List<Clinical_Room__c> cr_list = new List<Clinical_Room__c> {
      new Clinical_Room__c(isactive__c = true, name = 'PR1', room_type__c = 'Prosth',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'SR1', room_type__c = 'Surgery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'RC1', room_type__c = 'Recovery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'HG1', room_type__c = 'Hygiene',sort_order__c =1, center_information__c = c.id)
    };
    insert cr_list;
    
    //go to room page
    pageRef.getParameters().put('aptid',ca_list[0].id);  
    daa_controller.display_room_info();
    
    //check counts    
    system.assertEquals(daa_controller.getauthorized_rooms().size(),0);    
    system.assertEquals(daa_controller.getblocked_rooms().size(),4);
    
    //authorize rooms    
    //success
    for(Clinical_Room__c cr : daa_controller.getblocked_rooms()) {
      daa_controller.activation_id = cr.id;
      daa_controller.authorize_room();
    }
    
    //block rooms
    //fail
    try {
      daa_controller.activation_id = null;
      daa_controller.block_room();
    } catch (Exception e) {
      //good
    }
    //success
    for(Clinical_Room_Authorized_Apt__c cra : daa_controller.getauthorized_rooms()) {
      daa_controller.activation_id = cra.id;
      daa_controller.block_room();
    }
    
    //authorize all rooms
    daa_controller.authorize_all_rooms();
    system.assertEquals(daa_controller.getauthorized_rooms().size(),4); 
    
    //block all rooms
    daa_controller.block_all_rooms();
    system.assertEquals(daa_controller.getblocked_rooms().size(),4); 
    
    //test quicks search
    daa_controller.quick_search_field = 'TEST';
    daa_controller.getauthorized_rooms();
    daa_controller.getblocked_rooms();
    
    try {daa_controller = new dp_admin_appointment(); daa_controller.save_notes_form(); } catch (Exception e) {}
    
    test.stopTest();
  }
  
  static testMethod void test_appointment_doctor() {
    //init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : daa_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        daa_controller.change_center();
        c = ci;
      }
    }
    
    //fail going to scheduling page
    try {
      pageRef.getParameters().put('aptid','BAD ID');  
      daa_controller.display_doctor_info();
      
    } catch (Exception e) {
      //good
    }
    
    //create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Prosth Apt' , appointment_description__c = 'Example Prosth Apt', appointment_filter__c = 'Prosth' , center_information__c = c.id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Surgery Apt' , appointment_description__c = 'Example Surgery Apt', appointment_filter__c = 'Surgical' , center_information__c = c.id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Misc Apt' , appointment_description__c = 'Example Misc Apt', appointment_filter__c = 'Misc' , center_information__c = c.id, isactive__c = true)
    };
    insert ca_list;
    
    //create some rooms
    List<Clinical_Room__c> cr_list = new List<Clinical_Room__c> {
      new Clinical_Room__c(isactive__c = true, name = 'PR1', room_type__c = 'Prosth',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'SR1', room_type__c = 'Surgery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'RC1', room_type__c = 'Recovery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'HG1', room_type__c = 'Hygiene',sort_order__c =1, center_information__c = c.id)
    };
    insert cr_list;
    
    //go to room page
    pageRef.getParameters().put('aptid',ca_list[0].id);  
    daa_controller.display_doctor_info();
    
    //check counts    
    system.assertEquals(daa_controller.getauthorized_doctors().size(),0);    
    system.assertEquals(daa_controller.getblocked_doctors().size(),1);
    
    //authorize doctor    
    //success
    for(User u : daa_controller.getblocked_doctors()) {
      daa_controller.activation_id = u.id;
      daa_controller.authorize_doctor();
    }
    
    //block doctor
    //fail
    try {
      daa_controller.activation_id = null;
      daa_controller.block_doctor();
    } catch (Exception e) {
      //good
    }
    //success
    for(Clinical_DR_Authorized_Apt__c cra : daa_controller.getauthorized_doctors()) {
      daa_controller.activation_id = cra.id;
      daa_controller.block_doctor();
    }    
    
    //test quicks search
    daa_controller.quick_search_field = 'TEST';
    daa_controller.getauthorized_doctors();
    daa_controller.getblocked_doctors();
    
    test.stopTest();
  }
  
  static testMethod void test_exceptions() {
    //init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    daa_controller.current_center = null;
    try {daa_controller.getsearch_procedures();} catch (Exception e) {}
    try {daa_controller.add_procedure_step();} catch (Exception e) {}
   
    try {daa_controller.getprocedure_steps();} catch (Exception e) {}
    
    try {daa_controller.edit_clinical_appointment();} catch (Exception e) {}
    try {daa_controller.getblocked_doctors();} catch (Exception e) {}
    try {daa_controller.getblocked_rooms();} catch (Exception e) {}
    
    test.stopTest();
  }
  
  static testMethod void custom_colors() {
    //init();
    test.startTest();
    
    dp_admin_appointment daa_controller = new dp_admin_appointment();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    //create an appointment
    Clinical_Appointment__c ca =  new Clinical_Appointment__c (name = 'Prosth Apt' , appointment_description__c = 'Example Prosth Apt', appointment_filter__c = 'Prosth' , isactive__c = true);
    insert ca;
    
    //navigate to scheduling page
    pageRef.getParameters().put('aptid',ca.id);  
    daa_controller.display_scheduling_info();
    
    List<Selectoption> color_options = daa_controller.getcolor_grouping_options();
    pageRef.getParameters().put('cschema','1');
    daa_controller.apply_custom_schema();
    
    test.stopTest();
  }
}