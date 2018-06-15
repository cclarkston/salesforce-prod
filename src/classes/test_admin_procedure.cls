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
 *  dp_admin_procedures - 93%
 * 7/1/2016 - 92%
 *
 */
@isTest
private class test_admin_procedure  {

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
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#f5f5f5', Name = 'Procedures', Image_Name__c = 'Images/nurse.png', Image_Name_Hover__c = 'Images/nurse_black.png'),
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
    
    dp_admin_procedure dap_controller = new dp_admin_procedure();
    PageReference pageref = new PageReference('/apex/ccare_bend_prcoedure');
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
      dap_controller.change_category_filter();
    } catch (Exception e) {
      //should fail - no cfilter
    }
        
    pageRef.getParameters().put('cfilter','All');  
    dap_controller.change_category_filter();
    
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
      dap_controller = new dp_admin_procedure();
    } catch (Exception e) {
    	//this should fail
    }
    
    dap_controller.close_modal();
    
    test.stopTest();
  }
  
  static testMethod void test_procedure_main() {
    //init();
    test.startTest();
    
    dp_admin_procedure dap_controller = new dp_admin_procedure();
    PageReference pageref = new PageReference('/apex/ccare_bend_procedure');
    Test.setCurrentPage(pageRef);
    
    //go to our test center
    for(Center_Information__c ci : dap_controller.getcenter_list()) {
      if(ci.name=='Test Script Center') {
        pageRef.getParameters().put('cid',ci.id);  
        dap_controller.change_center();
      }
    }
    
    //check our counts
    system.assertEquals(dap_controller.getall_count(),0);
    system.assertEquals(dap_controller.getactive_count(),0);
    system.assertEquals(dap_controller.getinactive_count(),0);
    system.assertEquals(dap_controller.getprosth_count(),0);
    system.assertEquals(dap_controller.getsurgical_count(),0);
    system.assertEquals(dap_controller.getmisc_count(),0);
    
    //new procedure form
    dap_controller.new_procedure_form();    
    
    //reset form
    dap_controller.new_procedure.name = 'Test';
    dap_controller.reset_procedure_form();
    system.assertEquals(dap_controller.new_procedure.name,'Enter Procedure Name');
    
    //save procedure 
    //test default value errors
    dap_controller.save_new_procedure();
    //test null checks
    dap_controller.new_procedure.name = null;
    dap_controller.new_procedure.procedure_description__c = null;
    dap_controller.save_new_procedure();
    //success
    dap_controller.new_procedure.name = 'Prosth Test';
    dap_controller.new_procedure.procedure_description__c = 'Prosth Test Procedure';
    dap_controller.new_procedure.procedure_filter__c = 'Prosth';
    dap_controller.save_new_procedure();   
    system.assertEquals(dap_controller.getprosth_count(),1); 
        
    //create a procedure for each type
    dap_controller.new_procedure_form();
    dap_controller.new_procedure.name = 'Surgery Test';
    dap_controller.new_procedure.procedure_description__c = 'Surgery Test Procedure';
    dap_controller.new_procedure.procedure_filter__c = 'Surgical';
    dap_controller.save_new_procedure();
    system.assertEquals(dap_controller.getsurgical_count(),1);
    dap_controller.new_procedure_form();
    dap_controller.new_procedure.name = 'Misc Test';
    dap_controller.new_procedure.procedure_description__c = 'Misc Test Procedure';
    dap_controller.new_procedure.procedure_filter__c = 'Misc';
    dap_controller.save_new_procedure();
    system.assertEquals(dap_controller.getmisc_count(),1); 
    
    //test duplicate check
    dap_controller.new_procedure_form();
    dap_controller.new_procedure.name = 'Prosth Test';
    dap_controller.new_procedure.procedure_description__c = 'Prosth Test Procedure';
    dap_controller.new_procedure.procedure_filter__c = 'Prosth';
    dap_controller.save_new_procedure();
    
    //fail edit procedure
    try {
      dap_controller.current_edit = 'BAD ID';
      dap_controller.edit_clinical_procedure();
    } catch (Exception e) {
      //good
    }
    
    //pull lists
    List<Clinical_Procedure__c> cp_list = dap_controller.getprosth_list();
    system.assertEquals(cp_list.size(),1);
    cp_list = dap_controller.getsurgical_list();
    system.assertEquals(cp_list.size(),1);
    cp_list = dap_controller.getmisc_list();
    system.assertEquals(cp_list.size(),1);
        
    //edit procedure
    for(Clinical_Procedure__c cp : cp_list) {
      dap_controller.current_edit = cp.id;
      dap_controller.edit_clinical_procedure();      
      //save edit
      dap_controller.new_procedure.name = 'Misc Edit Test';
      dap_controller.save_new_procedure();
    }    
        
    //test quick search/filters
    dap_controller.active_filter = 'Inactive';
    dap_controller.quick_search_field = 'Test';
    system.assertEquals(dap_controller.getprosth_list().size(),0);
    dap_controller.active_filter = 'Active';
    dap_controller.category_filter = 'Prosth';
    system.assertEquals(dap_controller.getprosth_list().size(),1);
    
    //fail deactivate call
    try {
      dap_controller.activation_id = 'BAD ID';
      dap_controller.update_activation_procedure();
    } catch (Exception e) {
      //good
    }
    
    //deactivate a procedure
    for(Clinical_procedure__c cp : cp_list) {
      dap_controller.activation_id = cp.id;
      dap_controller.confim_activation_procedure();
      dap_controller.update_activation_procedure();
      system.assertEquals(dap_controller.getinactive_count(),1);
      //activate a procedure
      dap_controller.activation_id = cp.id;
      dap_controller.confim_activation_procedure();
      dap_controller.update_activation_procedure();      
      system.assertEquals(dap_controller.getactive_count(),3);
    }
          
    test.stopTest();
  }
  
  static testMethod void test_procedure_financial() {
    //init();
    test.startTest();
    
    dp_admin_procedure dap_controller = new dp_admin_procedure();
    PageReference pageref = new PageReference('/apex/ccare_bend_procedure');
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
    
    //create some procedures
    List<Clinical_Procedure__c> cp_list = new List<Clinical_Procedure__c> {
      new Clinical_Procedure__c(name = 'Prosth Test',procedure_description__c = 'Prosth Test procedure',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = c.id),
      new Clinical_Procedure__c(name = 'Surgery Test',procedure_description__c = 'Surgery Test procedure',isactive__c = true, procedure_filter__c = 'Surgical', center_information__c = c.id),
      new Clinical_Procedure__c(name = 'Misc Test',procedure_description__c = 'Misc Test procedure',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = c.id)
    };
    insert cp_list;
    
    //fail navigate to financial info
    try {
      pageRef.getParameters().put('procid','BAD ID');
      dap_controller.display_financial_info();  
    } catch (Exception e) {
      //good
    }
    
    //navigate to financial info
    pageRef.getParameters().put('procid',cp_list[0].id);
    dap_controller.display_financial_info();  
    
    //edit financial info
    dap_controller.edit_financial_info();
    //hide financial info form
    dap_controller.hide_financial_form();
    dap_controller.edit_financial_info();
    
    //reset financial info
    dap_controller.new_procedure.name = 'Test2';
    dap_controller.reset_financial_info();
    system.assertEquals(dap_controller.new_procedure.name,'Prosth Test');
    
    //save financial info
    //null check
    dap_controller.new_procedure.insurance_fee__c = null;
    dap_controller.new_procedure.cost__c = null;
    dap_controller.new_procedure.markup_min__c = null;
    dap_controller.new_procedure.markup_max__c = null;    
    dap_controller.save_financial_info();    
    //markups out of range
    dap_controller.new_procedure.markup_min__c = -20;
    dap_controller.new_procedure.markup_max__c = 200;    
    dap_controller.save_financial_info();    
    //min > max error
    dap_controller.new_procedure.markup_min__c = 50;
    dap_controller.new_procedure.markup_max__c = 40;    
    dap_controller.save_financial_info();        
    //good save
    dap_controller.new_procedure.insurance_fee__c = 300.00;
    dap_controller.new_procedure.cost__c = 100.00;
    dap_controller.new_procedure.markup_min__c = 10;
    dap_controller.new_procedure.markup_max__c = 50;    
    dap_controller.save_financial_info();    
    
    dap_controller.back_to_procedure();
    
    test.stopTest();
  }
  
  static testMethod void test_procedure_scheduling() {
    //init();
    test.startTest();
    
    dp_admin_procedure dap_controller = new dp_admin_procedure();
    PageReference pageref = new PageReference('/apex/ccare_bend_procedure');
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
    
    //create some procedures
    List<Clinical_Procedure__c> cp_list = new List<Clinical_Procedure__c> {
      new Clinical_Procedure__c(name = 'Prosth Test',procedure_description__c = 'Prosth Test procedure',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = c.id),
      new Clinical_Procedure__c(name = 'Surgery Test',procedure_description__c = 'Surgery Test procedure',isactive__c = true, procedure_filter__c = 'Surgical', center_information__c = c.id),
      new Clinical_Procedure__c(name = 'Misc Test',procedure_description__c = 'Misc Test procedure',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = c.id)
    };
    insert cp_list;
    
    //fail navigate to scheduling info
    try {
      pageRef.getParameters().put('procid','BAD ID'); 
      dap_controller.display_scheduling_info();
    } catch (Exception e) {
      //good
    }
    
    //navigate to scheduling info
    pageRef.getParameters().put('procid',cp_list[0].id); 
    dap_controller.display_scheduling_info();
    
    //edit scheduling info
    dap_controller.edit_financial_info();
    
    //save scheduling info
    //test null errors
    dap_controller.new_procedure.time_required__c = null;
    dap_controller.new_procedure.assistants_needed__c = null;
    dap_controller.save_scheduling_info();
    //test value less than 0 
    dap_controller.new_procedure.time_required__c = -20;
    dap_controller.new_procedure.assistants_needed__c = -5;
    dap_controller.save_scheduling_info();        
    //good save
    dap_controller.new_procedure.time_required__c = 30;
    dap_controller.new_procedure.assistants_needed__c = 1;
    dap_controller.save_scheduling_info();
    
    dap_controller.back_to_procedure();
    
    test.stopTest();
  }
  
  static testMethod void test_procedure_forms() {
    //init();
    test.startTest();
    
    dp_admin_procedure dap_controller = new dp_admin_procedure();
    PageReference pageref = new PageReference('/apex/ccare_bend_procedure');
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
    
    //create some procedures
    List<Clinical_Procedure__c> cp_list = new List<Clinical_Procedure__c> {
      new Clinical_Procedure__c(name = 'Prosth Test',procedure_description__c = 'Prosth Test procedure',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = c.id),
      new Clinical_Procedure__c(name = 'Surgery Test',procedure_description__c = 'Surgery Test procedure',isactive__c = true, procedure_filter__c = 'Surgical', center_information__c = c.id),
      new Clinical_Procedure__c(name = 'Misc Test',procedure_description__c = 'Misc Test procedure',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = c.id)
    };
    insert cp_list;
    
    //fail navigate to financial info
    try {
      pageRef.getParameters().put('procid','BAD ID');
      dap_controller.display_form_info();  
    } catch (Exception e) {
      //good
    }
    
    //navigate to financial info
    pageRef.getParameters().put('procid',cp_list[0].id);
    dap_controller.display_form_info();  
    
    //add a new form
    dap_controller.new_office_form();
    
    //hide new form
    dap_controller.hide_office_form();
    dap_controller.new_office_form();
    
    //reset form
    dap_controller.new_form_name = 'Test';
    dap_controller.reset_office_form();
    system.assertEquals(dap_controller.new_form_name,'Enter form');
    
    //insert some office form records
    
    List<Office_Form__c> of_list = new List<Office_Form__c> {
      new Office_Form__c(name = 'Test Form 1',isremovable__c = true, isupload__c = true),	
      new Office_Form__c(name = 'Test Form 2',isremovable__c = false, isupload__c = true),
      new Office_Form__c(name = 'Test Form 3',isremovable__c = true, isupload__c = false)
    };
    insert of_list;
    
    dap_controller.new_form_name = 'Test';
    List<Office_Form__c> search_returns = dap_controller.getsearch_forms();
    system.assertEquals(search_returns.size(),3);
    
    //add an invalid form
    dap_controller.add_office_form();
    
    //select a form
    pageRef.getParameters().put('ofid',search_returns[0].id);
    dap_controller.select_office_form();
    
    dap_controller.getprocedure_forms();
    
    //try removing it now    
    dap_controller.activation_id = dap_controller.last_insert;
    dap_controller.confim_remove_form();
    dap_controller.update_activation_form();    
    
    dap_controller.modal_type = 'N/A';
    test.stopTest();
  }
}