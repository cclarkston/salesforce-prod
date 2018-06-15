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
 *  dp_admin_pot - %88
 *
 */
@isTest
private class test_admin_pot {

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
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#f5f5f5', Name = 'Plans of Treatment', Image_Name__c = 'Images/nurse.png', Image_Name_Hover__c = 'Images/nurse_black.png'),
	  new Navigation_Page__c(css_class__c = 'pot', Sort_Order__c = 2, Page_URL__c = 'apex/text1', 
	  Navigation_Header__c = header_list[1].id, Nav_Color__c = '#e5e5e5', Name = 'Page 2'),
	  new Navigation_Page__c(css_class__c = 'logout', Sort_Order__c = 3, Page_URL__c = 'apex/text2', 
	  Navigation_Header__c = header_list[2].id, Nav_Color__c = '#c5c5c5', Name = 'Page 3')
	};
	insert page_list;
	
	//need some clinical procedures to use with the appointments
	List<Clinical_Procedure__c> cp_list = new List<Clinical_Procedure__c> {
      new Clinical_Procedure__c(name = 'Prosth Test',procedure_description__c = 'Prosth Test procedure',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = test_centers[0].id),
      new Clinical_Procedure__c(name = 'Surgery Test',procedure_description__c = 'Surgery Test procedure',isactive__c = true, procedure_filter__c = 'Surgical', center_information__c = test_centers[0].id),
      new Clinical_Procedure__c(name = 'Misc Test',procedure_description__c = 'Misc Test procedure',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id)
    };    
    insert cp_list;  
    
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
    
    dp_admin_pot dap_controller = new dp_admin_pot();
    PageReference pageref = new PageReference('/apex/ccare_bend_pot');
    Test.setCurrentPage(pageRef);
    
    dap_controller.getgear_menu();
    
    try {
      dap_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dap_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dap_controller.change_center();
    }
            
    try {
      dap_controller.change_active_view();
    } catch (Exception e) {
      //should fail - no afilter
    }
        
    pageRef.getParameters().put('afilter','Active');  
    dap_controller.change_active_view();
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dap_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //cycle through nav items
    for(dp_navigation_header.menu_item mi : dap_controller.getnavigation_menu()) {
      //tests for object methods if necessary
      if(mi.menu_type=='Page') {
        pageRef.getParameters().put('navid',mi.menu_id);    	
        PageReference newpage = dap_controller.navigate_to();
      }
    }
    
    System.assertEquals(dap_controller.getgear_menu().size(),1);
    
    //fail controller init
    pageRef.getParameters().put('ctrid','BAD CENTER ID');
    try {
      dap_controller = new dp_admin_pot();
    } catch (Exception e) {
    	//this should fail
    }
    
    dap_controller.close_modal();
    dap_controller.modal_type = 'NA';
    
    test.stopTest();
  }
  
  static testMethod void test_pot_main() {
    //init();
    test.startTest();
    
    dp_admin_pot dap_controller = new dp_admin_pot();
    PageReference pageref = new PageReference('/apex/ccare_bend_pot');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : dap_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dap_controller.change_center();
        c = ci;
      }
    }
    
    dap_controller.display_all_pot();
    
    //check our counts
    system.assertEquals(dap_controller.getall_count(),0);
    system.assertEquals(dap_controller.getactive_count(),0);
    system.assertEquals(dap_controller.getinactive_count(),0);

    //new treatment plan form   
    system.assertEquals(dap_controller.getdisplay_new_plan(),false);
    dap_controller.new_pot_form();
    
    //reset form
    dap_controller.new_pot.name = 'Test';
    dap_controller.reset_pot_form();
    system.assertEquals(dap_controller.new_pot.name,'Enter Plan Name');
    
    //save pot
    //test default value check
    dap_controller.save_new_pot();
    //test null check
    dap_controller.new_pot.name = null;
    dap_controller.new_pot.treatment_description__c = null;
    dap_controller.save_new_pot();
    //success
    dap_controller.new_pot.name = 'Test 1 POT';
    dap_controller.new_pot.treatment_description__c = 'Using this as a test';
    dap_controller.save_new_pot();
    String pot_id = dap_controller.new_pot.id;
    system.assertEquals(dap_controller.getall_count(),1);
    
    //check duplicate pot catch  
    dap_controller.new_pot_form();
    dap_controller.new_pot.name = 'Test 1 POT';
    dap_controller.new_pot.treatment_description__c = 'Using this as a test';
    dap_controller.save_new_pot();
    system.assertEquals(dap_controller.getall_count(),1);
    
    //fail activation call
    try {
      dap_controller.activation_id = 'BAD ID';
      dap_controller.update_activation_pot();
    } catch(Exception e) {
       //good
    }
        
    //deactivate pot
    dp_admin_pot.pot_parent[] pot_list = dap_controller.getpot_list();
    for(dp_admin_pot.pot_parent pp : pot_list) {
      for(Plan_of_Treatment__c pot : pp.tplans) {
      	dap_controller.activation_id = pot.id;
      	dap_controller.confirm_activation_pot();
      	dap_controller.update_activation_pot();
      	//reactivate it
      	dap_controller.activation_id = pot.id;      	
      	dap_controller.update_activation_pot();
      }
    }
        
    //manually create some pot_appointment records for our pot
    Integer step_count = 0;
    List<Clinical_Appointment__c> ca_list = [select id from Clinical_Appointment__c where center_information__c = :c.id];
    list<POT_Appointment__c> step_list = new List<POT_Appointment__c> {
      new POT_Appointment__c(Clinical_Appointment__c =  ca_list[0].id, Days_Out__c = 7, Plan_of_treatment__c = pot_id, Sort_Order__c = step_count++),
      new POT_Appointment__c(Clinical_Appointment__c =  ca_list[1].id, Days_Out__c = 7, Plan_of_treatment__c = pot_id, Sort_Order__c = step_count++),
      new POT_Appointment__c(Clinical_Appointment__c =  ca_list[2].id, Days_Out__c = 7, Plan_of_treatment__c = pot_id, Sort_Order__c = step_count++)
    };
    insert step_list;   
    
    //clone pot
    dap_controller.clone_id = pot_id;
    dap_controller.clone_pot();
    dap_controller.reset_pot_form();
    dap_controller.new_pot.name = 'Clone Test';
    dap_controller.save_new_pot();    
    
    //fail edit call
    try {
      dap_controller.current_edit = 'Null';
      dap_controller.edit_plan_of_treatment();
    } catch (Exception e) {
     //good
    }
    
    //edit pot
    dap_controller.current_edit = pot_id;
    dap_controller.edit_plan_of_treatment();
    dap_controller.save_new_pot();   
    
    //test search filters
    dap_controller.active_filter = 'Inactive';
    dap_controller.quick_search_field = 'test';
    dap_controller.getpot_list();     
  
    test.stopTest();
  }
  
  static testMethod void test_pot_apt() {
    //init();
    test.startTest();
    
    dp_admin_pot dap_controller = new dp_admin_pot();
    PageReference pageref = new PageReference('/apex/ccare_bend_pot');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    Center_Information__c c;
    for(Center_Information__c ci : dap_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dap_controller.change_center();
        c = ci;
      }
    }
    
    //insert a pot
    Plan_of_Treatment__c pot = new Plan_of_Treatment__c(name = 'Test POT',treatment_description__c = 'Test POT',isactive__c = true,center_information__c = c.id);
    insert pot;
    
    //fail apt details nav
    try {
      dap_controller.pot_id = 'BAD ID';
      dap_controller.display_apt_detail();
    } catch (Exception e) {
    	//good
    }
    
    //open apt details screen
    dap_controller.pot_id= pot.id;
    dap_controller.display_apt_detail();
        
    //grab category list
    dap_controller.getapt_category_list();
    
    //should have no appointments yet
    system.assertEquals(dap_controller.getappointment_details().size(),0);
    
    //display new apt form
    dap_controller.new_apt_form();  
    
    //save new apt step
    //no match check
    dap_controller.new_apt_name = 'No Match';
    dap_controller.add_appointment_step();
    //work through apt search and add all apts
    String pthru_test = '';
    dap_controller.reset_apt_form();
    for(Clinical_Appointment__c ca : dap_controller.getsearch_appointments()) {
      pageRef.getParameters().put('aptid',ca.id);
      dap_controller.select_appointment();
      pthru_test += dap_controller.last_insert + '&'; 
    }
    system.assertEquals(dap_controller.getappointment_details().size(),3); 
    
    //fail edit call
    try {
      dap_controller.current_edit = 'BAD ID';
      dap_controller.edit_apt_detail();
    } catch (Exception e) {
      //good
    }
    
    //modify apt detail (days out)
    dap_controller.current_edit = dap_controller.last_insert;
    dap_controller.edit_apt_detail();
    
    //null check
    dap_controller.new_apt_detail.days_out__c = null;
    dap_controller.save_apt_detail();
    //negative check
    dap_controller.new_apt_detail.days_out__c = -3;
    dap_controller.save_apt_detail();
    //good check
    dap_controller.new_apt_detail.days_out__c = 18;
    dap_controller.save_apt_detail();
            
    //change sort order
    pageRef.getParameters().put('pthru',pthru_test);  
    dap_controller.modify_sort_order();
        
    //remove apt detail
    for(POT_Appointment__c pa : dap_controller.getappointment_details()) {
      dap_controller.activation_id = pa.id;
      dap_controller.confirm_activation_apt_detail();
      dap_controller.update_activation_apt_detail();
    }
    system.assertEquals(dap_controller.getappointment_details().size(),0);

    //fail activation call
    try {
      dap_controller.activation_id = 'null';
      dap_controller.update_activation_apt_detail();
    }  catch (Exception e) {
    	//good
    } 
        
    //test qsearch fields
    dap_controller.new_apt_name = 'test';
    dap_controller.apt_filter = 'Prosth';
    dap_controller.getsearch_appointments();   
    
    dap_controller.hide_apt_detail_form(); 
    
    test.stopTest();
  }
}