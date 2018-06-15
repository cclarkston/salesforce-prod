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
 * 2/23/2016 CM Code Coverage
 *  dp_admin_rooms - 93%
 * 
 * 1/17/2018 - 88% coverage
 *
 *
 */
@isTest
private class test_admin_rooms {

  @testSetup private static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	  	  			
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
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US')};
	insert my_test_users;
	
	List<Navigation_Header__c> header_list = new List<Navigation_Header__c> { new Navigation_Header__c(Sub_System__c = 'Setup' , Name = 'Clinical'),
		new Navigation_Header__c(Sub_System__c = 'Setup' , Name = 'Facility'),
		new Navigation_Header__c(Sub_System__c = 'Gear' , Name = 'Gear')
	};
	insert header_list;
	List<Navigation_Page__c> page_list = new List<Navigation_Page__c> { new Navigation_Page__c(css_class__c = 'staff', Sort_Order__c = 1, Page_URL__c = 'apex/text', 
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#f5f5f5', Name = 'Rooms', Image_Name__c = 'Images/nurse.png', Image_Name_Hover__c = 'Images/nurse_black.png'),
	  new Navigation_Page__c(css_class__c = 'pot', Sort_Order__c = 2, Page_URL__c = 'apex/text1', 
	  Navigation_Header__c = header_list[1].id, Nav_Color__c = '#e5e5e5', Name = 'Page 2'),
	  new Navigation_Page__c(css_class__c = 'logout', Sort_Order__c = 3, Page_URL__c = 'apex/text2', 
	  Navigation_Header__c = header_list[2].id, Nav_Color__c = '#c5c5c5', Name = 'Page 3')
	};
	insert page_list;
  }
        
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    
    dp_admin_rooms dar_controller = new dp_admin_rooms();
    PageReference pageref = new PageReference('/apex/ccare_bend_rooms');
    Test.setCurrentPage(pageRef);
    
    dar_controller.getgear_menu();
    
    try {
      dar_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dar_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dar_controller.change_center();
    }
    
    try {
      dar_controller.change_category_filter();
    } catch (Exception e) {
      //should fail - no cfilter
    }
        
    pageRef.getParameters().put('cfilter','All');  
    dar_controller.change_category_filter();
    
    try {
      dar_controller.change_active_view();
    } catch (Exception e) {
      //should fail - no afilter
    }
        
    pageRef.getParameters().put('afilter','Active');  
    dar_controller.change_active_view();
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dar_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //cycle through nav items
    for(dp_navigation_header.menu_item mi : dar_controller.getnavigation_menu()) {
      //tests for object methods if necessary
      if(mi.menu_type=='Page') {
        pageRef.getParameters().put('navid',mi.menu_id);    	
        PageReference newpage = dar_controller.navigate_to();
      }
    }
    
    System.assertEquals(dar_controller.getgear_menu().size(),1);
    
    //fail controller init
    pageRef.getParameters().put('ctrid','BAD CENTER ID');
    try {
      dar_controller = new dp_admin_rooms();
    } catch (Exception e) {
    	//this should fail
    }
    
    dar_controller.close_modal();
    
    test.stopTest();
  }
  
  static testMethod void test_room_info() {
    //init();
    test.startTest();
    
    dp_admin_rooms dar_controller = new dp_admin_rooms();
    PageReference pageref = new PageReference('/apex/ccare_bend_rooms');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    for(Center_Information__c ci : dar_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dar_controller.change_center();
      }
    }
    
    //check rooms counts
    system.assertEquals(dar_controller.getprosth_rooms().size(),0);
    system.assertEquals(dar_controller.getsurgery_rooms().size(),0);
    system.assertEquals(dar_controller.getrecovery_rooms().size(),0);
    system.assertEquals(dar_controller.gethygiene_rooms().size(),0);
    system.assertEquals(dar_controller.gethybrid_rooms().size(),0);
    system.assertEquals(dar_controller.getall_count(),0);
    system.assertEquals(dar_controller.getactive_count(),0);
    system.assertEquals(dar_controller.getinactive_count(),0);
    
    //open new room form
    dar_controller.new_room_type = 'Prosth';
    dar_controller.new_room_form();
    
    //reset room form
    dar_controller.new_room.name = 'test';
    dar_controller.reset_room_form();
    system.assertEquals(dar_controller.new_room.name,'Enter room label');
        
    //create a room
    //catch default errors
    dar_controller.save_new_room();
    //catch null errors
    dar_controller.new_room.name=null;
    dar_controller.save_new_room();
    //success
    dar_controller.new_room.name='PR1';
    dar_controller.save_new_room();
    
    //check room counts
    system.assertEquals(dar_controller.getprosth_rooms().size(),1);
    
    //try to create a duplicate room
    dar_controller.new_room_type = 'Prosth';
    dar_controller.new_room_form();
    dar_controller.new_room.name='PR1';
    dar_controller.save_new_room();
    String pthru = dar_controller.new_room.id;
    system.assertEquals(dar_controller.getprosth_rooms().size(),1);
    dar_controller.new_room.name='PR2';
    dar_controller.save_new_room();
    system.assertEquals(dar_controller.getprosth_rooms().size(),2);
        
    //create a surgery room
    dar_controller.new_room_type = 'Surgery';
    dar_controller.new_room_form();
    dar_controller.new_room.name='SR1';
    dar_controller.save_new_room();
    system.assertEquals(dar_controller.getsurgery_rooms().size(),1);
    
    //create a recovery room
    dar_controller.new_room_type = 'Recovery';
    dar_controller.new_room_form();
    dar_controller.new_room.name='RC1';
    dar_controller.save_new_room();
    system.assertEquals(dar_controller.getrecovery_rooms().size(),1);
    
    //create a hygiene room
    dar_controller.new_room_type = 'Hygiene';
    dar_controller.new_room_form();
    dar_controller.new_room.name='HG1';
    dar_controller.save_new_room();
    system.assertEquals(dar_controller.gethygiene_rooms().size(),1);
    
    //create a hybrid room
    dar_controller.new_room_type = 'Hybrid';
    dar_controller.new_room_form();
    dar_controller.new_room.name='HBR1';
    dar_controller.save_new_room();
    system.assertEquals(dar_controller.gethybrid_rooms().size(),1);
    
    //fail on edit
    try {
      dar_controller.current_edit = null;
      dar_controller.edit_room();
    } catch (Exception e) {
      //good
    }
    
    //edit our last room
    dar_controller.current_edit = dar_controller.new_room.id;
    dar_controller.edit_room();
    dar_controller.new_room.name = 'HG2';
    dar_controller.save_new_room();
    
    //grab rooms with alternate filters
    dar_controller.active_filter = 'Inactive';
    dar_controller.quick_search_field = 'NO MATCH';
    system.assertEquals(dar_controller.getall_rooms().size(),0);
    
    //modify sort order
    pageRef.getParameters().put('pthru',pthru);
    dar_controller.modify_sort_order();
    
    //fail modify
    try {
      pageRef.getParameters().put('pthru','BADID&WORSEID&NOMATCH');
      dar_controller.modify_sort_order();
    }  catch (Exception e) {
    	//good
    }
    
    test.stopTest();
  }
  
  static testMethod void test_room_appointment_methods() {
    //init();
    test.startTest();
    
    dp_admin_rooms dar_controller = new dp_admin_rooms();
    PageReference pageref = new PageReference('/apex/ccare_bend_rooms');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : dar_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dar_controller.change_center();
        c = ci;
      }
    }
    
    //create some rooms
    List<Clinical_Room__c> cr_list = new List<Clinical_Room__c> {
      new Clinical_Room__c(isactive__c = true, name = 'PR1', room_type__c = 'Prosth',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'SR1', room_type__c = 'Surgery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'RC1', room_type__c = 'Recovery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'HG1', room_type__c = 'Hygiene',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'POS1', room_type__c = 'Hybrid',sort_order__c =1, center_information__c = c.id)
    };
    insert cr_list;
    
    //probably need to create some appointments here
    List<Clinical_Appointment__c> ca_list = new List<Clinical_Appointment__c>{
      new Clinical_Appointment__c(name = 'Prosth Apt',appointment_description__c = 'A sample prosth apt',appointment_filter__c='Prosth',isactive__c=true,center_information__c = c.id ,clinical_notes_form__c = 'Prosth Exam Form'),
      new Clinical_Appointment__c(name = 'Surgery Apt',appointment_description__c = 'A sample surgery apt',appointment_filter__c='Surgical',isactive__c=true,center_information__c = c.id ,clinical_notes_form__c = 'Surgical Notes Form'),
      new Clinical_Appointment__c(name = 'Misc Apt',appointment_description__c = 'A sample misc apt',appointment_filter__c='Misc',isactive__c=true,center_information__c = c.id ,clinical_notes_form__c = 'None')
    };
    insert ca_list;
    
    //fail navigation to apt page
    try {
      dar_controller.display_appointment_info();
    } catch (Exception e) {
    	//good
    }    
    
    //navigate to apt page
    pageRef.getParameters().put('rid',cr_list[0].id);  
    dar_controller.display_appointment_info();
    
    //check counts
    system.assertEquals(dar_controller.getauthorized_apts().size(),0);
    system.assertEquals(dar_controller.getblocked_appointments().size(),3);
    system.assertEquals(dar_controller.getall_apt_count(),3);
    system.assertEquals(dar_controller.getprosth_count(),1);
    system.assertEquals(dar_controller.getsurgical_count(),1);
    system.assertEquals(dar_controller.getmisc_count(),1);
    system.assertEquals(dar_controller.getapt_category_list().size(),4);
    
    //fail authorization
    try {
      dar_controller.activation_id = 'BAD ID';
      dar_controller.authorize_appointment();
    } catch (Exception e) {
    	//good
    }
    
    //work through blocked apts and authorize them
    for(Clinical_Appointment__c ca : dar_controller.getblocked_appointments()) {
      dar_controller.activation_id = ca.id;
      dar_controller.authorize_appointment();
    }
    system.assertEquals(dar_controller.getauthorized_apts().size(),3);
    system.assertEquals(dar_controller.getblocked_appointments().size(),0);
    
    //fail block
    try {
      dar_controller.activation_id = 'BAD ID';
      dar_controller.block_appointment();
    } catch (Exception e) {
      //good
    }
    
    //work through authorized apts and block them
    for(Clinical_Room_Authorized_Apt__c cra : dar_controller.getauthorized_apts()) {
      dar_controller.activation_id = cra.id;
      dar_controller.block_appointment();
    }
    system.assertEquals(dar_controller.getblocked_appointments().size(),3);    
    
    //authorize all
    dar_controller.authorize_all_appointments();
    system.assertEquals(dar_controller.getauthorized_apts().size(),3);
    
    //block all
    dar_controller.block_all_appointments();
    system.assertEquals(dar_controller.getblocked_appointments().size(),3);
    
    //test qsearch and filter out
    dar_controller.appointment_filter = 'Prosth';
    dar_controller.quick_search_field = 'NOMATCHHERE';
    dar_controller.getauthorized_apts().size();
    dar_controller.getblocked_appointments().size();    
    
    test.stopTest();
  }
  
  static testMethod void test_calendar_methods() {
    //init();
    test.startTest();
    
    dp_admin_rooms dar_controller = new dp_admin_rooms();
    PageReference pageref = new PageReference('/apex/ccare_bend_rooms');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : dar_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dar_controller.change_center();
        c = ci;
      }
    }
    
    //create some rooms
    List<Clinical_Room__c> cr_list = new List<Clinical_Room__c> {
      new Clinical_Room__c(isactive__c = true, name = 'PR1', room_type__c = 'Prosth',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'SR1', room_type__c = 'Surgery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'RC1', room_type__c = 'Recovery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'HG1', room_type__c = 'Hygiene',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'POS1', room_type__c = 'Hybrid',sort_order__c =1, center_information__c = c.id)
    };
    insert cr_list;
    
    //probably need to create some appointments here
    List<Clinical_Appointment__c> ca_list = new List<Clinical_Appointment__c>{
      new Clinical_Appointment__c(name = 'Prosth Apt',appointment_description__c = 'A sample prosth apt',appointment_filter__c='Prosth',isactive__c=true,center_information__c = c.id),
      new Clinical_Appointment__c(name = 'Surgery Apt',appointment_description__c = 'A sample surgery apt',appointment_filter__c='Surgical',isactive__c=true,center_information__c = c.id),
      new Clinical_Appointment__c(name = 'Misc Apt',appointment_description__c = 'A sample misc apt',appointment_filter__c='Misc',isactive__c=true,center_information__c = c.id)
    };
    insert ca_list;
    
    //fail navigation to schedule page
    try {
      dar_controller.display_schedule_info();
    } catch (Exception e) {
    	//good
    }    
    
    //navigate to schedule page
    pageRef.getParameters().put('rid',cr_list[0].id);  
    dar_controller.display_schedule_info();
    
    //display the calendar for the room
    dp_admin_rooms.calendar_column[] cc = dar_controller.getcalendar_info();
    
    //fail new block form
    pageRef.getParameters().put('shour','NAN');
    pageRef.getParameters().put('sminute','NAN');
    pageRef.getParameters().put('dow','NAN');
    try {
      dar_controller.display_new_block_form();
    } catch(Exception e) {
      //good
    }
    
    //new block form
    pageRef.getParameters().put('shour','9');
    pageRef.getParameters().put('sminute','0');
    pageRef.getParameters().put('dow','1');
    dar_controller.display_new_block_form();
    
    dar_controller.show_block_form();
    dar_controller.hide_block_form();
    
    //reset block
    dar_controller.new_block.start_hour__c = '10';
    dar_controller.reset_block_form();
    system.assertEquals(dar_controller.new_block.start_hour__c,'9');
    system.assertEquals(dar_controller.getworking_on_new_block(),true);
    
    //save new block
    //catch end time before start time error
    //catch calendar label too small error
    dar_controller.new_block.end_time__c = '8:20 AM';
    dar_controller.new_block.calendar_label__c = 'A';
    dar_controller.save_block_form();    
    //block less then 30 minutes in size error
    //catch calendar label too large error
    dar_controller.new_block.end_time__c = '9:20 AM';
    dar_controller.new_block.calendar_label__c = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
    dar_controller.save_block_form();    
    //good save
    dar_controller.new_block.end_time__c = '11:20 AM';
    dar_controller.new_block.calendar_label__c = 'Good Label';
    dar_controller.save_block_form();    
    //update save
    dar_controller.save_block_form();
    
    //overlapping block issue check
    dar_controller.display_new_block_form();
    dar_controller.save_block_form();                
     
    //pull calendar with our new block
    cc = dar_controller.getcalendar_info();
    
    //test remaining labels and dow
    pageRef.getParameters().put('shour','13');
    pageRef.getParameters().put('sminute','30');
    pageRef.getParameters().put('dow','2');
    dar_controller.display_new_block_form();
    pageRef.getParameters().put('shour','12');
    pageRef.getParameters().put('dow','3');
    dar_controller.display_new_block_form();
    pageRef.getParameters().put('dow','4');
    dar_controller.display_new_block_form();
    pageRef.getParameters().put('dow','5');
    dar_controller.display_new_block_form();
    pageRef.getParameters().put('dow','6');
    dar_controller.display_new_block_form();
    pageRef.getParameters().put('dow','7');
    dar_controller.display_new_block_form();    
    
    //fail modify existing block
    try {
      pageRef.getParameters().put('bid','BAD ID');	
      dar_controller.display_existing_block_form();
    } catch (Exception e) {
      //good
    }
    
    //modify existing block
    String bid = [select id from CR_Schedule_Block__c where clinical_room__c = :cr_list[0].id limit 1].id;
    pageRef.getParameters().put('bid',bid);	
    dar_controller.display_existing_block_form();
    system.assertEquals(dar_controller.getworking_on_new_block(),false);
    dar_controller.reset_block_form();
    dar_controller.new_block.end_hour__c = '14';    
    //dar_controller.save_block_form();
    dar_controller.hide_block_form();
       
    test.stopTest();
  }
  
  static testMethod void test_block_methods() {
    //init();
    test.startTest();
    
    dp_admin_rooms dar_controller = new dp_admin_rooms();
    PageReference pageref = new PageReference('/apex/ccare_bend_rooms');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : dar_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dar_controller.change_center();
        c = ci;
      }
    }
    
    //create some rooms
    List<Clinical_Room__c> cr_list = new List<Clinical_Room__c> {
      new Clinical_Room__c(isactive__c = true, name = 'PR1', room_type__c = 'Prosth',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'SR1', room_type__c = 'Surgery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'RC1', room_type__c = 'Recovery',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'HG1', room_type__c = 'Hygiene',sort_order__c =1, center_information__c = c.id),
      new Clinical_Room__c(isactive__c = true, name = 'POS1', room_type__c = 'Hybrid',sort_order__c =1, center_information__c = c.id)
    };
    insert cr_list;
    
    //probably need to create some appointments here
    List<Clinical_Appointment__c> ca_list = new List<Clinical_Appointment__c>{
      new Clinical_Appointment__c(name = 'Prosth Apt',appointment_description__c = 'A sample prosth apt',appointment_filter__c='Prosth',isactive__c=true,center_information__c = c.id ,clinical_notes_form__c = 'Prosth Exam Form'),
      new Clinical_Appointment__c(name = 'Surgery Apt',appointment_description__c = 'A sample surgery apt',appointment_filter__c='Surgical',isactive__c=true,center_information__c = c.id ,clinical_notes_form__c = 'Surgical Notes Form'),
      new Clinical_Appointment__c(name = 'Misc Apt',appointment_description__c = 'A sample misc apt',appointment_filter__c='Misc',isactive__c=true,center_information__c = c.id ,clinical_notes_form__c = 'None')
    };
    insert ca_list;
    
    
    //create some schedule blocks
    list<CR_Schedule_Block__c> block_list = new List<CR_Schedule_Block__c> {
      new CR_Schedule_Block__c(allow_all__c = true, clinical_room__c = cr_list[0].id, dow__c = 1, end_hour__c = '10', end_minute__c = '30', start_hour__c = '8', start_minute__c = '30', 
        isactive__c = true, start_time__c = '8:30 AM', end_time__c = '10:30 AM'),
      new CR_Schedule_Block__c(allow_all__c = true, clinical_room__c = cr_list[0].id, dow__c = 1, end_hour__c = '16', end_minute__c = '00', start_hour__c = '13', start_minute__c = '00', 
        isactive__c = true, start_time__c = '1:00 PM', end_time__c = '4:00 PM')
    };
    insert block_list;
    
    pageRef.getParameters().put('bid',block_list[0].id);	
    dar_controller.display_existing_block_form();
    //add an apt authorization
    dar_controller.new_apt_form();
    
    //reset apt form
    dar_controller.new_apt_name = 'test';
    dar_controller.reset_apt_form();
    system.assertEquals(dar_controller.new_apt_name,'Enter Appointment');
    
    //find our prosth apt and authorize it
    dar_controller.new_apt_name = 'Prosth Apt';    
    dar_controller.add_block_apt_authorization();
    system.assertEquals(dar_controller.getblock_apts().size(),1);
    
    //fail block removal
    try {
      dar_controller.activation_id = null;
      dar_controller.remove_apt_authorization();
    } catch (Exception e) {
      //good
    }
        
    //search all apts and add authorization
    dar_controller.reset_apt_form();
    for(Clinical_Appointment__c ca : dar_controller.getsearch_appointments()) {
      pageRef.getParameters().put('aptid',ca.id);
      dar_controller.select_appointment();
    }    
    
    //make sure it blocks dupes
    for(Clinical_Appointment__c ca : dar_controller.getsearch_appointments()) {
      
    }
    
    //add all prosth/surgical test
    dar_controller.add_all_prosth_appointments();
    dar_controller.add_all_surgical_appointments();
    dar_controller.add_all_misc_appointments();
    
    //display the calendar with apt blocks inplace
    pageRef.getParameters().put('rid',cr_list[0].id);  
    dar_controller.display_schedule_info();
    dp_admin_rooms.calendar_column[] cc = dar_controller.getcalendar_info();
    
    //remove our blocks
    for(CR_Sched_Block_Authorized_Apt__c csb : dar_controller.getblock_apts()) {
      dar_controller.activation_id = csb.id;
      dar_controller.remove_apt_authorization();
    }
    
    //test search params
    dar_controller.new_apt_name = 'Prosth';
    dar_controller.appointment_filter = 'Prosth';    
    for(Clinical_Appointment__c ca : dar_controller.getsearch_appointments()) {
      dar_controller.add_block_apt_authorization();
    }
    
    //try to add a block for a bad apt name
    dar_controller.new_apt_name = 'NOMATCH';
    dar_controller.add_block_apt_authorization();
    
    dar_controller.hide_apt_form();    
    dar_controller.modal_type = 'NA';
    dar_controller.modal_out = 'NA';
    
    //test removal
    dar_controller.activation_id = block_list[0].id;
    dar_controller.confim_activation_block();
    dar_controller.update_activation_block();
    dar_controller.update_activation_block();
    
    pageRef.getParameters().put('bid',block_list[1].id);	
    dar_controller.display_existing_block_form();
    
    //test add blocks by form type
    for(Selectoption sopt : dar_controller.getform_type_list()) {
      pageRef.getParameters().put('ftype',sopt.getvalue());
      dar_controller.add_all_form_appointments();
    }
    
    test.stopTest();
  }
}