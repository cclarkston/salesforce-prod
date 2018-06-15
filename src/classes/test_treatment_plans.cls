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
 * 2/23/2006 - 86% code coverage for account_treatment_plans
 */
@isTest
private class test_treatment_plans {
	
  private static void init() {
  	Profile p = [select id from Profile where name = 'System Administrator'];		
	User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
	insert my_test_user;
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	insert test_center;
	
	lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	  Call_Center_Agent__c = my_test_user.id, LastName = 'Patient369', FirstName = 'Test', Gender__c = 'Male',
	  Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
	insert test_lead;
	
    Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_lead.id);

    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);
      
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    
    Account a = [select id,financing_result__c,ownerid from account limit 1];
    a.financing_result__c = 'Approved Less Than 50%';
    a.ownerid = my_test_user.id;
    try {
      update a;
    }
    catch (Exception e) {
      System.debug('Error on Account insert : ' + e);
    }
	
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_user.id);
	insert test_account;
	
	ClearChoice_Doctor__c cd = new ClearChoice_Doctor__c(first_name__c = 'Test',last_name__c = 'Doctor12367', center_information__c = test_center.id,active__c = true);
	insert cd; 
	List<Treatment_Option__c> to_list = new List<Treatment_Option__c> {
	  new Treatment_Option__c(name = 'Treatment 1', Upper_Tag__c = 'None', Lower_tag__c = 'AO4', timeline__c = '1 year',start_value__c = 0),
	  new Treatment_Option__c(name = 'Treatment 1', Upper_Tag__c = 'AO4', Lower_tag__c = 'AO4', timeline__c = '1 year',start_value__c = 1),
	  new Treatment_Option__c(name = 'Treatment 1', Upper_Tag__c = 'AO4', Lower_tag__c = 'None', timeline__c = '1 year',start_value__c = 2)
	};
	insert to_list;
  }

  static testMethod void treatment_plan_test() {
    // TO DO: implement unit test
    init();
    test.startTest();
    
    try {
      account_treatment_plans bad_controller = new account_treatment_plans();
    } catch (Exception e) {
    	//should fail - no account id provided
    }
           
    PageReference pageref = new PageReference('/apex/new_treatment_plan');
    Account a = [select id,center__r.sales_market__c,center__c from account where name = 'Test Patient369'];
    //System.debug('Account Sales Market : ' + a.center__r.sales_market__c);
    pageRef.getParameters().put('aid',a.id);    
    
    ClearChoice_Doctor__c cd = [select id,center_information__r.sales_market__c from ClearChoice_Doctor__c where first_name__c = 'Test' and last_name__c = 'Doctor12367' limit 1];
    //System.debug('Doctor Sales Market : ' + cd.center_information__r.sales_market__c);
    
    Test.setCurrentPage(pageRef);   
    
  	account_treatment_plans controller = new account_treatment_plans();
  	controller.getcurrent_date();
  	List<Selectoption> tag_options = controller.gettag_options();
  	List<Selectoption> doctor_options = controller.getDoctorList();
  	//System.debug('Doctor List Size : ' + doctor_options.size());
  	List <Treatment_Option__c> to_list = controller.gettreatment_matches();
  	
  	//test lower option only
  	controller.lower_option = tag_options[1].getValue();
  	controller.gettreatment_matches();
  	//test upper option only
  	controller.lower_option = 'None';
  	controller.upper_option = tag_options[1].getValue();
  	controller.gettreatment_matches();
  	//test both upper and lower options
  	controller.lower_option = tag_options[1].getValue();
  	controller.gettreatment_matches();  	
  	
  	//select a treatment option
  	pageRef.getParameters().put('tid',to_list[0].id);
    controller = new account_treatment_plans();	

  	controller.add_treatment_plan();  	
  	controller.getselected_treatment_name();  	
  	controller.change_treatment_option();
  	controller.getselected_treatment_name();
  	
  	//set other values
  	controller.new_plan.clearchoice_doctor__c = cd.id;
  	controller.new_plan.final_cost__c = 100;
  	controller.new_plan.initial_cost__c = 100;
  	controller.new_plan.recommended__c = true;  	
  	controller.add_treatment_plan();
  	  	
  	//add a second non-recommended plan
  	controller.change_treatment_option();
  	controller.new_plan.clearchoice_doctor__c = cd.id;
  	controller.new_plan.final_cost__c = 100;
  	controller.new_plan.initial_cost__c = 100;
  	controller.new_plan.recommended__c = false;  	
  	controller.add_treatment_plan();
    	
  	//run this after adding a treatment option
  	controller.getcurrent_doctor();
  	//List<account_treatment_plans.treatment_object> = controller.getcurrent_treatments();
  	for(account_treatment_plans.treatment_object  atp : controller.getcurrent_treatments()) {
  	  atp.getfile_list();
  	}
  	List<Treatment_Plan__c> tp_list = controller.getcurrent_treatment_plans();
  	
  	controller.gettreatment_plan_size();
    controller.gettemplate_name();
    controller.getserver_name();
    controller.getaccount_name();    
    account_treatment_plans.record_printout(a.id);
  	
  	//remove a plan
  	pageRef.getParameters().put('dtpid',tp_list[0].id);
  	new account_treatment_plans();
  	
  	controller.remove_treatment_plan();
  	
  	controller.reset_treatment_plan();
  	  	
  	controller.return_to_consult();     	
  	
  	ApexPages.StandardController con = new ApexPages.StandardController(a);
  	account_treatment_display atd_controller = new account_treatment_display(con);
  	
  	atd_controller.getcurrent_treatment_plans();  
  	
  	Opportunity test_ops = new Opportunity(accountid = a.id, center_information__c = a.center__c, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1');
	insert test_ops;
	
	ApexPages.StandardController ocon = new ApexPages.StandardController(test_ops);
	opp_treatmentplan o_controller = new opp_treatmentplan(ocon);
	
	List<Treatment_Plan__c> tlist = o_controller.getconsult_plans();
	//System.debug('Tlist Size : ' + tlist.size() + ' Tlist : ' + tlist);	
		
	pageref = new PageReference('/apex/opp_treatment_plan');
	pageRef.getParameters().put('cpid',tlist[0].id);
	pageRef.getParameters().put('tpid',tlist[0].id);
	Test.setCurrentPage(pageRef); 
	ocon = new ApexPages.StandardController(test_ops);
	
	o_controller.select_consult_plan();
	o_controller.open_change_plan_page();
    o_controller.getchange_treatment_plan_url();
	
	Treatment_Plan__c tpc = [select id from treatment_plan__c where opportunity__c = :test_ops.id];
	
	ApexPages.StandardController tpcon = new ApexPages.StandardController(tpc);
	ctrl_treatmentplan ctp_con = new ctrl_treatmentplan(tpcon);
	
	ctp_con.getdoctor_list();
	ctp_con.quick_save();
	
	pageref = new PageReference('/apex/treatment_plan_change_request');
	pageRef.getParameters().put('tpid',tpc.id);
	Test.setCurrentPage(pageRef); 
		
	ctrl_treatment_plan_change pchange_con = new ctrl_treatment_plan_change();		
	List<Treatment_Plan__c> alt_list = pchange_con.getconsult_plans();
	//System.debug('Alt List Size : ' + alt_list.size() + ' Alt List : ' + alt_list);
	pchange_con.getdoctor_list();
	
	pageRef.getParameters().put('cpid',tlist[0].id);
    pchange_con = new ctrl_treatment_plan_change();		
    pchange_con.new_change_request();
    
	pchange_con.switch_treatment_plan();
	pchange_con.save_changes();
	pchange_con.change_request.reason_for_change__c='Other - fill in notes';
	pchange_con.save_changes();
	pchange_con.change_request.reason_notes__c = 'Testing notes';
	pchange_con.change_request.treatment_stage__c = 'Testing';
	pchange_con.change_request.new_treatment_amount__c = -120;
	pchange_con.save_changes();
	pchange_con.change_request.new_treatment_amount__c = 120;
	pchange_con.change_request.new_treatment_option__c = pchange_con.change_request.current_treatment_option__c;
	pchange_con.save_changes();
  	
    test.stopTest();
  }
  
  
}