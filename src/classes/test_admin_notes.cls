/**
 Code Coverage
 dp_admin_notes - 92% - CM 7/5/2016
 */
@isTest
private class test_admin_notes {

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
	  Navigation_Header__c = header_list[2].id, Nav_Color__c = '#c5c5c5', Name = 'Page 3'),
	  new Navigation_Page__c(css_class__c = 'notes', Sort_Order__c = 4, Page_URL__c = 'apex/text3', 
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#c5c5c5', Name = 'Click Notes')
	};
	insert page_list;
	
	//create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Prosth Apt' , appointment_description__c = 'Example Prosth Apt', appointment_filter__c = 'Prosth' , center_information__c = test_centers[0].id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Surgery Apt' , appointment_description__c = 'Example Surgery Apt', appointment_filter__c = 'Surgical' , center_information__c = test_centers[0].id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Misc Apt' , appointment_description__c = 'Example Misc Apt', appointment_filter__c = 'Misc' , center_information__c = test_centers[0].id, isactive__c = true)
    };
    insert ca_list;    
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    
    dp_admin_notes dan_controller = new dp_admin_notes();
    PageReference pageref = new PageReference('/apex/ccare_bend_appointment');
    Test.setCurrentPage(pageRef);
    
    dan_controller.getgear_menu();
    
    try {
      dan_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dan_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dan_controller.change_center();
    }
    
    try {
      dan_controller.change_category_filter();
    } catch (Exception e) {
      //should fail - no cfilter
    }
        
    pageRef.getParameters().put('cfilter','All');  
    dan_controller.change_category_filter();
    
    try {
      dan_controller.change_active_view();
    } catch (Exception e) {
      //should fail - no afilter
    }
        
    pageRef.getParameters().put('afilter','Active');  
    dan_controller.change_active_view();
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dan_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //cycle through nav items
    for(dp_navigation_header.menu_item mi : dan_controller.getnavigation_menu()) {
      //tests for object methods if necessary
      if(mi.menu_type=='Page') {
        pageRef.getParameters().put('navid',mi.menu_id);    	
        PageReference newpage = dan_controller.navigate_to();
      }
    }
    
    System.assertEquals(dan_controller.getgear_menu().size(),1);
    
    //fail controller init
    pageRef.getParameters().put('ctrid','BAD CENTER ID');
    try {
      dan_controller = new dp_admin_notes();
    } catch (Exception e) {
    	//this should fail
    }
    
    dan_controller.close_modal();
    dan_controller.back_to_notes();
    
    test.stopTest();
  }
  
  static testMethod void test_notes_main() {
    //init();
    test.startTest();
    
    dp_admin_notes dan_controller = new dp_admin_notes();
    PageReference pageref = new PageReference('/apex/ccare_bend_notes');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    for(Center_Information__c ci : dan_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dan_controller.change_center();
      }
    }
    
    //check our counts
    system.assertEquals(dan_controller.getall_count(),0);
    system.assertEquals(dan_controller.getactive_count(),0);
    system.assertEquals(dan_controller.getinactive_count(),0);
    
    //new note form
    dan_controller.new_note_form();
    
    //reset appointment form
    dan_controller.new_note.note_text__c = 'Test';
    dan_controller.reset_note_form();
    system.assertEquals(dan_controller.new_note.note_text__c,'Enter note');
        
    //save new appointment
    //test default value check
    dan_controller.save_new_note();    
    //test null checks
    dan_controller.new_note.note_text__c = null;
    dan_controller.save_new_note();    
    //note too short
    dan_controller.new_note.note_text__c = '1';
    dan_controller.save_new_note();    
    //good save
    dan_controller.new_note.note_text__c = '123456';
    dan_controller.save_new_note();    
                      
    //pull lists
    List<Custom_Clinical_Note__c> cn_list = dan_controller.getnotes_list();
    system.assertEquals(cn_list.size(),1);
    
    //fail edit call?
    try {
      dan_controller.current_edit = 'BAD ID';
      dan_controller.edit_custom_note();
    } catch (Exception e) {
      //good
    }
        
    //edit note
    dan_controller.current_edit = cn_list[0].id;
    dan_controller.edit_custom_note();
    dan_controller.new_note.note_text__c = 'Test Script Custom Note';
    dan_controller.save_new_note();
        
    //fail activation call
    try {
      dan_controller.activation_id = 'BAD ID';
      dan_controller.update_note_activation();
    } catch (Exception e) {
      //good
    }    
    
    pageRef.getParameters().put('noteid',cn_list[0].id);   
    //deactivate the note and test counts
    dan_controller.confirm_deactivate_note();
    dan_controller.update_note_activation();
    system.assertEquals(dan_controller.getactive_count(),0);
    system.assertEquals(dan_controller.getinactive_count(),1);
    //reactivate the note
    dan_controller.confirm_activate_note();
    dan_controller.update_note_activation();
    system.assertEquals(dan_controller.getactive_count(),1);
    system.assertEquals(dan_controller.getinactive_count(),0);
                            
    //test note qsearch - can't do much here as the note text field is a long text area and is not searchable
    dan_controller.active_filter = 'Inactive';
    system.assertEquals(dan_controller.getnotes_list().size(),0);
    dan_controller.active_filter = 'Active';
    system.assertEquals(dan_controller.getnotes_list().size(),1);   
    
    pageRef.getParameters().put('noteid',cn_list[0].id);
    dan_controller.expand_appointment_list();
    dan_controller.collapse_appointment_list();
    test.stopTest();
  }
  
  static testMethod void test_notes_appointment_assignment() {
  	//init();
    test.startTest();
    
    dp_admin_notes dan_controller = new dp_admin_notes();
    PageReference pageref = new PageReference('/apex/ccare_bend_notes');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    for(Center_Information__c ci : dan_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dan_controller.change_center();
      }
    }
    
  	//create a new note
  	dan_controller.new_note_form();
    dan_controller.new_note.note_text__c = 'Test Note for Apt Assignment';
    dan_controller.save_new_note();    
  	
  	//add an appointment to it
  	List<Custom_Clinical_Note__c> cn_list = dan_controller.getnotes_list();
  	pageRef.getParameters().put('noteid',cn_list[0].id);
  	dan_controller.open_apt_modal();
  	
  	//default category should be all right now - test size
  	List<Clinical_Appointment__c> apt_list = dan_controller.getappointment_list();
  	system.assertEquals(apt_list.size(),3);
  	
  	pageRef.getParameters().put('cfilter','Surgical');
  	dan_controller.change_category_filter();
  	apt_list = dan_controller.getappointment_list();
  	system.assertEquals(apt_list.size(),1);
  	
  	//fail add an apt to the note
  	try {
  	  pageRef.getParameters().put('aptid','BAD APT ID');
  	  dan_controller.add_note_by_appointment();
  	} catch (Exception e) {
  	  //good
  	}
  	
  	//add an apt to the note
  	pageRef.getParameters().put('aptid',apt_list[0].id);
  	dan_controller.add_note_by_appointment();
  	//test size
  	Custom_Clinical_Note__c cn = dan_controller.getcurrent_note_info(cn_list[0].id);
  	system.assertEquals(cn.Custom_Clinical_Notes_by_Apt__r.size(),1);
  	
  	//remove an appointment
  	pageRef.getParameters().put('aptid',cn.Custom_Clinical_Notes_by_Apt__r[0].id);
  	dan_controller.confirm_remove_apt();
  	dan_controller.remove_note_apt();
  	//test size
  	cn = dan_controller.getcurrent_note_info(cn_list[0].id);
  	system.assertEquals(cn.Custom_Clinical_Notes_by_Apt__r.size(),0);  	
  	
  	dan_controller.close_apt_modal();
  	test.stopTest();
  }
}