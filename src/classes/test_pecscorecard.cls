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
/*
2/20/2015 CM
initial build coverage #'s
pecscorecard_tab - 77%
account_scorecards - 96%
ctrl_pecscorecard - 89%

3/17/2015 - After mass changes
ctrl_pecscorecard - 90%
pecscorecard_tab - 77%
account_scorecards - 97%

4/27/2015 - After weekly huddle changes
ctrl_pecscorecard - 88%
pecscorecard_tab - 79%
account_scorecards - 94%
*/

private class test_pecscorecard {
	
	private static void init() {
  	Profile p = [select id from Profile where name = 'System Administrator'];		
	List<User> my_test_users = new List<User>{new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'),new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu2@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'),
		  new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu3@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US')};
	insert my_test_users;
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c>  test_center = new List<Center_Information__c>{new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com'),new Center_Information__c(Name = 'Unknown', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com')};
	insert test_center;
	Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center[0].id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
	insert test_room; 
	
	ClearChoice_Doctor__c cd  = new ClearChoice_Doctor__c(First_Name__c = 'First',Last_name__c = 'Last test', Active__c = true, Center_information__c = test_center[0].id, Name = 'First Last Test');
	insert cd;
	
	lead test_lead = new Lead(Center__c = test_center[0].id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	  Call_Center_Agent__c = my_test_users[0].id, LastName = 'Patient369', FirstName = 'Test', Gender__c = 'Male',
	  Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
	insert test_lead;
	Consult_Inventory__c ci_test = new Consult_Inventory__c(Start_Minute__c = '20', Start_Hour__c = '8', Scheduled_Time__c = System.now(), 
	  Scheduled_Lead__c = test_lead.id, Ready_Time__c = system.now(), End_Minute__c = '50', End_Hour__c = '9', Consult_Started__c = system.now(), 
	  Consult_Room__c = test_room.id, Consult_Completed__c = system.now(), Arrival_Time__c = system.now(), Apt_Date__c = system.today().adddays(-1), Active__c = true,
	  Consult_PEC__c = my_test_users[0].id);
	  insert ci_test;

    Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_lead.id);

    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);
      
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    
    Account a = [select id,financing_result__c,ownerid from account limit 1];
    a.financing_result__c = 'Approved Less Than 50%';
    a.ownerid = my_test_users[0].id;
    try {
      update a;
    }
    catch (Exception e) {
      System.debug('Error on Account insert : ' + e);
    }
	
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_users[1].id);
	insert test_account; 
	Task t = new Task(whatid = test_account.id,ownerid = Userinfo.getuserid(),activity_type__c = 'Outbound Call',Subject = 'Scheduled Callback',Description = ' Need to call back patient and follow up',activitydate = System.today().adddays(-1));
	insert t;
  }

  static testMethod void test_ctrl_pecscorecard() {
    init();
    test.starttest();
    PageReference pageref = new PageReference('/apex/pec_scorecard');
    pageRef.getParameters().put('action', 'New');
    RecordType rt = [select id from RecordType where sobjecttype = 'Pec_Scorecard__c' and name = 'Consult'];        
    pageRef.getParameters().put('recordtypeid',rt.id);
    Account a = [select id from account where name = 'Test Patient369'];
    pageRef.getParameters().put('account',a.id);
    
    Test.setCurrentPage(pageRef);   
    //create a new consult scorecard
  	ctrl_pecscorecard controller = new ctrl_pecscorecard();
  	controller.check_for_actions();
    controller.quick_save_scorecard();
  	controller.save_scorecard();
  	controller.getconsult_desc();
  	controller.gettask_time();
  	
  	List<Consult_Inventory__c> ci = controller.getconsult_list();
  	pageRef.getParameters().put('cid','bad id');
  	controller.score_apt();
  	
  	pageRef.getParameters().put('cid',ci[0].id);
  	controller.score_apt();
  	controller.getconsult_desc();
  	
  	controller.pscore.viewing_method__c = 'Live';
  	controller.pscore.framing_what_score__c = '1';
  	controller.pscore.framing_how_score__c = '1';
  	controller.pscore.needs_dialogue_what_score__c = '1';
  	controller.pscore.needs_dialogue_how_score__c = '1';
  	controller.pscore.pec_consult_wrap_up_what_score__c = '1';
  	controller.pscore.pec_consult_wrap_up_how_score__c = '1'; 	
  	//controller.pscore.pre_solutions_dialogue_what_score__c = '1';
  	//controller.pscore.pre_solutions_dialogue_how_score__c = '1';
  	controller.pscore.doctor_download_what_score__c = '1';
  	controller.pscore.doctor_download_how_score__c = '1';
  	controller.pscore.doctor_role_play_what_score__c = '1';
  	controller.pscore.doctor_role_play_how_score__c = '1';
  	controller.pscore.doctor_consult_framing_what_score__c = '1';
  	controller.pscore.doctor_consult_framing_how_score__c = '1';
  	controller.pscore.doctor_consult_needs_dialogue_what_score__c = '1';
  	controller.pscore.doctor_consult_needs_dialogue_how_score__c = '1';
  	controller.pscore.solutions_dialogue_what_score__c = '1';
  	controller.pscore.solutions_dialogue_how_score__c = '1';
  	controller.pscore.wrap_up_what_score__c = '1';
  	controller.pscore.wrap_up_how_score__c = '1';
  	controller.pscore.treatment_value_what_score__c = '1';
  	controller.pscore.treatment_value_how_score__c = '1';
  	controller.pscore.frame_price_what_score__c = '1';
  	controller.pscore.frame_price_how_score__c = '1';
  	controller.pscore.resolve_objections_what_score__c = '1';
  	controller.pscore.resolve_objections_how_score__c = '1';
  	controller.pscore.financial_conversation_what_score__c = '1';
  	controller.pscore.financial_conversation_how_score__c = '1';
  	controller.pscore.pec_solutions_wrap_up_what_score__c = '1';
  	controller.pscore.pec_solutions_wrap_up_how_score__c = '1';
  	
  	controller.pscore.score_date__c=null;
  	controller.save_scorecard();
  	
  	controller.pscore.score_date__c = System.now();
  	controller.pscore.framing_Positive_Feedback__c = '1';
  	controller.pscore.framing_Positive_Ideas__c = '1';
  	controller.pscore.framing_stop__c = '1';
  	controller.pscore.needs_dialogue_Positive_Feedback__c = '1';
  	controller.pscore.needs_dialogue_Positive_Ideas__c = '1';
  	controller.pscore.needs_dialogue_stop__c = '1';
  	controller.pscore.pec_consult_wrap_up_continue__c = '1';
  	controller.pscore.pec_consult_wrap_up_start__c = '1';
  	controller.pscore.pec_consult_wrap_up_stop__c = '1';
  	//controller.pscore.pre_solutions_dialogue_Positive_Feedback__c = '1';
  	//controller.pscore.pre_solutions_dialogue_Positive_Ideas__c = '1';
  	//controller.pscore.pre_solutions_dialogue_stop__c = '1';
  	controller.pscore.doctor_download_Positive_Feedback__c = '1';
  	controller.pscore.doctor_download_Positive_Ideas__c = '1';
  	controller.pscore.doctor_download_stop__c = '1';
  	controller.pscore.doctor_role_play_continue__c = '1';
  	controller.pscore.doctor_role_play_start__c = '1';
  	controller.pscore.doctor_role_play_stop__c = '1';
  	controller.pscore.doctor_consult_framing_continue__c = '1';
  	controller.pscore.doctor_consult_framing_start__c = '1';
  	controller.pscore.doctor_consult_framing_stop__c = '1';
  	controller.pscore.doctor_consult_needs_dialogue_continue__c = '1';
  	controller.pscore.doctor_consult_needs_dialogue_start__c = '1';
  	controller.pscore.doctor_consult_needs_dialogue_stop__c = '1';
  	controller.pscore.solutions_dialogue_Positive_Feedback__c = '1';
  	controller.pscore.solutions_dialogue_Positive_Ideas__c = '1';
  	controller.pscore.solutions_dialogue_stop__c = '1';
  	controller.pscore.wrap_up_Positive_Feedback__c = '1';
  	controller.pscore.wrap_up_Positive_Ideas__c = '1';
  	controller.pscore.wrap_up_stop__c = '1';
  	controller.pscore.treatment_value_continue__c = '1';
  	controller.pscore.treatment_value_start__c = '1';
  	controller.pscore.treatment_value_stop__c = '1';
  	controller.pscore.frame_price_continue__c = '1';
  	controller.pscore.frame_price_start__c = '1';
  	controller.pscore.frame_price_stop__c = '1';
  	controller.pscore.resolve_objections_continue__c = '1';
  	controller.pscore.resolve_objections_start__c = '1';
  	controller.pscore.resolve_objections_stop__c = '1';
  	controller.pscore.financial_conversation_continue__c = '1';
  	controller.pscore.financial_conversation_start__c = '1';
  	controller.pscore.financial_conversation_stop__c = '1';
  	controller.pscore.pec_solutions_wrap_up_continue__c = '1';
  	controller.pscore.pec_solutions_wrap_up_start__c = '1';
  	controller.pscore.pec_solutions_wrap_up_stop__c = '1';
  	controller.pscore.financial_needs_dialogue_what__c = '1';
  	controller.pscore.financial_needs_dialogue_how__c = '1';
  	controller.pscore.confirm_financial_needs_what__c = '1';
  	controller.pscore.confirm_financial_needs_how__c = '1';
  	
  	controller.save_scorecard();
  	
  	ClearChoice_Doctor__c cd = [select id from ClearChoice_Doctor__c limit 1];
  	
  	controller.pscore.clearchoice_doctor__c = cd.id;
  	controller.pscore.framing_Positive_Feedback__c = '1234567890';
  	controller.pscore.framing_Positive_Ideas__c = '11234567890';
  	controller.pscore.framing_stop__c = '11234567890';
  	controller.pscore.needs_dialogue_Positive_Feedback__c = '11234567890';
  	controller.pscore.needs_dialogue_Positive_Ideas__c = '11234567890';
  	controller.pscore.needs_dialogue_stop__c = '11234567890';
  	controller.pscore.pec_consult_wrap_up_Continue__c = '11234567890';
  	controller.pscore.pec_consult_wrap_up_Start__c = '11234567890';
  	controller.pscore.pec_consult_wrap_up_stop__c = '11234567890';  	
  	//controller.pscore.pre_solutions_dialogue_Positive_Feedback__c = '11234567890';
  	//controller.pscore.pre_solutions_dialogue_Positive_Ideas__c = '11234567890';
  	//controller.pscore.pre_solutions_dialogue_stop__c = '11234567890';
  	controller.pscore.doctor_download_Positive_Feedback__c = '11234567890';
  	controller.pscore.doctor_download_Positive_Ideas__c = '11234567890';
  	controller.pscore.doctor_download_stop__c = '11234567890';
  	controller.pscore.doctor_role_play_Continue__c = '11234567890';
  	controller.pscore.doctor_role_play_Start__c = '11234567890';
  	controller.pscore.doctor_role_play_stop__c = '11234567890';
  	controller.pscore.doctor_consult_framing_Continue__c = '11234567890';
  	controller.pscore.doctor_consult_framing_Start__c = '11234567890';
  	controller.pscore.doctor_consult_framing_stop__c = '11234567890';
  	controller.pscore.doctor_consult_needs_dialogue_Continue__c = '11234567890';
  	controller.pscore.doctor_consult_needs_dialogue_Start__c = '11234567890';
  	controller.pscore.doctor_consult_needs_dialogue_stop__c = '11234567890';
  	controller.pscore.solutions_dialogue_Positive_Feedback__c = '11234567890';
  	controller.pscore.solutions_dialogue_Positive_Ideas__c = '11234567890';
  	controller.pscore.solutions_dialogue_stop__c = '11234567890';
  	controller.pscore.wrap_up_Positive_Feedback__c = '11234567890';
  	controller.pscore.wrap_up_Positive_Ideas__c = '11234567890';
  	controller.pscore.wrap_up_stop__c = '11234567890';
  	controller.pscore.treatment_value_Continue__c = '11234567890';
  	controller.pscore.treatment_value_Start__c = '11234567890';
  	controller.pscore.treatment_value_stop__c = '11234567890';
  	controller.pscore.frame_price_Continue__c = '11234567890';
  	controller.pscore.frame_price_Start__c = '11234567890';
  	controller.pscore.frame_price_stop__c = '11234567890';
  	controller.pscore.resolve_objections_Continue__c = '11234567890';
  	controller.pscore.resolve_objections_Start__c = '11234567890';
  	controller.pscore.resolve_objections_stop__c = '11234567890';
  	controller.pscore.financial_conversation_Continue__c = '11234567890';
  	controller.pscore.financial_conversation_Start__c = '11234567890';
  	controller.pscore.financial_conversation_stop__c = '11234567890';
  	controller.pscore.pec_solutions_wrap_up_Continue__c = '11234567890';
  	controller.pscore.pec_solutions_wrap_up_Start__c = '11234567890';
  	controller.pscore.pec_solutions_wrap_up_stop__c = '11234567890';
  	controller.pscore.financial_needs_dialogue_comment__c = '11234567890';
  	controller.pscore.confirm_financial_needs_comment__c = '11234567890';
  	
  	controller.save_scorecard();
  	controller.getdoctorlist();
  	controller.view_pec_consult_tab();
  	controller.view_pec_doctor_download_tab();
  	controller.view_pec_solutions_dialogue_tab();
  	controller.view_doctor_consult_tab();
  	
  	controller.getpatient_initials();
  	String card_id = controller.pscore.id;	
  	
  	//create a new callback scorecard
  	rt = [select id from RecordType where sobjecttype = 'Pec_Scorecard__c' and name = 'Call Back'];        
    pageRef.getParameters().put('recordtypeid',rt.id);
    controller.check_for_actions();
    controller.save_scorecard();
    
    List<Task> tlist =  controller.gettask_list(); 
    pageRef.getParameters().put('tid','bad id');
  	controller.score_task();
    
    pageref = new PageReference('/apex/pec_scorecard');
    pageRef.getParameters().put('id', card_id);    
    Test.setCurrentPage(pageRef);
    controller = new ctrl_pecscorecard();
    controller.check_for_actions();

  	controller.getconsults_observed();
  	controller.getcallbacks_observed();
  	controller.toggle_view();
  	controller.toggle_edit();
  	controller.getconsults_last_month();
  	controller.getconsults_mtd();
  	controller.getconsults_ytd();
  	controller.getstarts_last_month();
  	controller.getstarts_mtd();
  	controller.getstarts_ytd();
  	controller.getcancels_last_month();
  	controller.getcancels_mtd();
  	controller.getcancels_ytd();
  	controller.getrainmaker_last_month();
  	controller.getrainmaker_mtd();
  	controller.getrainmaker_ytd();
  	
  	controller.getcallbacks_last_month();
  	controller.getcallbacks_mtd();
  	controller.getcallbacks_ytd();
  	controller.getScoreOptions();
  	controller.close_modal();
  	controller.display_apt_list();
  	controller.display_task_list();
  	controller.getcoach_name();
       
    ApexPages.StandardController con = new ApexPages.StandardController(a);
    account_scorecards account_ext = new account_scorecards(con);
    List<account_scorecards.scorecards> slist = account_ext.getconsult_scorecards();
    for(account_scorecards.scorecards sc : slist) {
      sc.getscore_date();
      sc.getoverall_score();
    }
    
    account_ext.getscorecard_link();
    pageref = account_ext.new_consult_scorecard();
    pageref = account_ext.new_account_scorecard();
    pageref = account_ext.new_roleplay_scorecard();
    pageref = account_ext.new_roleplay_call_back();
    
    test.stoptest();
  }
    
  static testMethod void test_pecscorecard_tab() {  	
    init();    
    test.starttest();
    PageReference pageref = new PageReference('/apex/pec_scorecard_tab');
    Test.setCurrentPage(pageRef);
    
    //generate a weekly huddle scorecard
    ctrl_weekly_huddle ctrl = new ctrl_weekly_huddle();
    ctrl.check_for_scorecard();
    
    //generate some scorecards
    List<Pec_Scorecard__c> plist = new List<Pec_Scorecard__c>();
    for(RecordType rt : [select id from RecordType where sobjecttype = 'Pec_Scorecard__c']) {
      PEC_Scorecard__c pscore = new Pec_Scorecard__c(pec_scored__c = Userinfo.getuserid(), scorecard_completed__c = true, score_date__c = System.now(), qualified_scorecard__c = true, Recordtypeid = rt.id, total_score__c = 20, total_possible_score__c = 30);
      plist.add(pscore);
      PEC_Scorecard__c pscore2 = new Pec_Scorecard__c(pec_scored__c = Userinfo.getuserid(), scorecard_completed__c = true, score_date__c = System.now().addmonths(-1), qualified_scorecard__c = true, Recordtypeid = rt.id, total_score__c = 20, total_possible_score__c = 30);
      plist.add(pscore2);
    }          
    insert plist;
    pageref = new PageReference('/apex/pec_scorecard_tab');
    
    Test.setCurrentPage(pageRef);
       
    System.debug('Controller Starting');
  	pecscorecard_tab controller2 = new pecscorecard_tab();
  	 	
    try {
  	  controller2.getlast_consult_date();
    }
    catch (Exception e) {
    	
    }
    try {
  	  controller2.getlast_callback_date();
    }
    catch (Exception e) {
    	
    }
    try {
  	  controller2.getlast_roleplay_date();
    }
    catch (Exception e) {
    	
    }
    try {
  	  controller2.getlast_roleplay_callback_date();
    }
    catch (Exception e) {
    	
    }
    
  	controller2.run_search();
  	controller2.getdisplay_user_search();
  	
  	RecordType rt = [Select r.SobjectType, r.Name, r.Id From RecordType r where sobjecttype = 'PEC_Scorecard__c' and name = 'Consult'];
  	controller2.card_type = rt.id;
  	controller2.run_search();
  	
  	controller2.card_type = 'Any';
  	controller2.start_filter.pec_scored__c = null;
  	controller2.run_search();
    
    try {
      controller2.next();
    }
    catch (Exception e) {
    	
    }
    
    try {
      controller2.prev();
    }
    catch (Exception e) {
    	
    }
    
    controller2.getCardTypeOptions();
    controller2.getnum_scorecards();
    controller2.pec_sort();
    controller2.pec_sort();
    controller2.date_sort();
    controller2.date_sort();
    controller2.card_sort();
    controller2.card_sort();
    controller2.coach_sort();
    controller2.coach_sort();
    controller2.score_sort();
    controller2.score_sort();
    controller2.getRegionOptions();
    
    //weekly huddle stuff
    
    controller2.huddle_date_sort();
    controller2.huddle_pec_sort();
    controller2.card_type = 'Huddle';
    controller2.run_search();
    Weekly_Huddle__c wc = [Select id From Weekly_Huddle__c w order by week_start__c desc limit 1];
    
    pageref = new PageReference('apex/weekly_huddle?id=' + wc.id);
    Test.setcurrentpage(pageref);
    ctrl = new ctrl_weekly_huddle();
    
    ctrl.gethuddle_name();
    ctrl.getrainmaker_overall_avg_last_week();
    ctrl.getrainmaker_overall_avg_current_week();
    ctrl.getrainmaker_overall_how_avg_last_week();
    ctrl.getrainmaker_overall_how_avg_current_week();
    ctrl.getrainmaker_overall_what_avg_last_week();
    ctrl.getrainmaker_overall_what_avg_current_week();
    ctrl.getcallbacks_last_week();
    ctrl.getcallbacks_current_week();
    ctrl.getcloserate_last_week();
    ctrl.getcloserate_current_week();
    ctrl.getcurrent_learning_actions();
    ctrl.getprevious_learning_actions();
    ctrl.view_mode();
    
    ctrl.getpulse_options();
    
    ctrl.complete_scorecard();
    
    ctrl.quick_save();
    ctrl.current_huddle.rainmaker_how_score__c = 6;
    ctrl.complete_scorecard();
    ctrl.quick_save();
    ctrl.current_huddle.rainmaker_what_score__c = 7;
    ctrl.complete_scorecard();
    ctrl.quick_save();
    ctrl.current_huddle.rainmaker_how_score__c = 4;
    ctrl.current_huddle.rainmaker_what_score__c = 3;
        
    ctrl.add_learning_action();
    ctrl.new_learning_action.action_plan__c = 'Other';
    ctrl.add_learning_action();
    ctrl.new_learning_action.other_action_type__c = '1234';
    ctrl.add_learning_action();
    ctrl.new_learning_action.other_action_type__c = '123456789';
    ctrl.add_learning_action();
    
    ctrl.current_huddle.close_rate_goal__c = 15.0;
    ctrl.current_huddle.close_rate_goal__c = 110;
    ctrl.current_huddle.number_of_callbacks__c = 5;
    ctrl.current_huddle.pulse_check__c = '4';
    
    ctrl.complete_scorecard();

    test.stoptest();
  }
  
  /*static testMethod void test_ctrl_pecscorecard() {
    init();
    test.starttest();
    PageReference pageref = new PageReference('/apex/pec_scorecard_tab');
    
    Test.setCurrentPage(pageRef);   
    //create a new consult scorecard
  	pecscorecard_tab controller2 = new pecscorecard_tab();
  	
  	controller2.getlast_consult_date();
  	controller2.getlast_callback_date();
  	controller2.getlast_roleplay_date();
  	controller2.run_search();
  	
  	controller2.card_type = 'Consult';
  	controller2.run_search();
  	
  	controller2.card_type = 'Any';
  	controller2.start_filter.pec_score__c = null;
  	controller2.run_search();
    
    try {
      controller2.next();
    }
    catch (Exception e) {
    	
    }
    
    try {
      controller2.prev();
    }
    catch (Exception e) {
    	
    }
    
    controller2.getCardTypeOptions();
    controller2.getnum_scorecards();
    controller2.pec_sort();
    controller2.pec_sort();
    controller2.date_sort();
    controller2.date_sort();
    controller2.card_sort();
    controller2.card_sort();
    controller2.coach_sort();
    controller2.coach_sort();
    controller2.score_sort();
    controller2.score_sort();
    
    
    test.stoptest();
  }  */
  
}