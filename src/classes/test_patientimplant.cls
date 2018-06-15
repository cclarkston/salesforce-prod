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
private class test_patientimplant {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    }
    
	private static void init() {
        
	  	Market__c m = new Market__c(Name = 'Test Market');
	  	insert m;
	    Center_Information__c test_center = new Center_Information__c(Name = 'Test Austin', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
			  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
			  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
			  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
		  insert test_center; 
	    Profile p = [select id from Profile where name = 'System Administrator'];		
			User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
			  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
			  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_center.name);
			insert my_test_user;
	    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
		      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
		      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c = true);
		  insert test_lead;	 
		  RecordType rt = [select id from RecordType where sobjecttype = 'Account' and name = 'Prospective Patients' limit 1];	  
		  Account test_account = new Account(billingcity = 'Test city', billingstate = 'CO', firstname = 'test', lastname = 'Account',recordtypeid = rt.id, center__c = test_center.id);
		  insert test_account;
		  Opportunity test_opp = new Opportunity(accountid = test_account.id,name = test_account.firstname, stagename = 'Paid In Full', closedate = system.today());
		  insert test_opp;
		  Integer cnt = [select count() from Opportunity];	
		  Private_Practice_Patient__c test_pp = new Private_Practice_Patient__c(Center__c = test_center.id, First_Name__c = 'Test', Last_Name__c = 'PrivatePatient', Name = 'Test PrivatePatient', main_phone__c = '1234567890', main_phone_type__c = 'Work', patient_email__c = 'tprivatepatient@clearchoice.com', treatment_plan__c = 'TBD');
		  insert test_pp;
		  Implant_Parts__c ip = new Implant_Parts__c(name = 'PNTest', part_description__c = 'This is the implant used for our test module', brand__c = 'ACME');
		  insert ip;
		  Dental_Practice__c dp = new Dental_Practice__c(name='Test Practice',primary_contact_email__c = 'test@fake.com');
		  insert dp;
		  Implementation_Checklist__c ic = new Implementation_Checklist__c(dental_practice__c = dp.id);
		  insert ic;
		  Practice_Doctor__c[] pd = new Practice_Doctor__c[] {new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com'),
		  	new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor2', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com'),
		  	new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor3', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com'),
		  	new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor4', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com'),
		  	new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor5', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com')};
		  insert pd;
		  PP_Workshop__c pww = new PP_Workshop__c(name='Test Workshop',event_date__c = system.today(), event_time__c = '6:00 PM', location_name__c = 'Test Loc', location_street__c = 'Test Street', location_city__c = 'Test City', location_state__c = 'Test State', location_postal_code__c = '00001');
		  insert pww;
		  PP_Workshop_Member__c[] pww_mem = new PP_Workshop_Member__c[] {new PP_Workshop_Member__c(PP_Workshop__c = pww.id, Practice_Doctor__c = pd[0].id),
		  new PP_Workshop_Member__c(PP_Workshop__c = pww.id, Practice_Doctor__c = pd[1].id),
		  new PP_Workshop_Member__c(PP_Workshop__c = pww.id, Practice_Doctor__c = pd[2].id),
		  new PP_Workshop_Member__c(PP_Workshop__c = pww.id, Practice_Doctor__c = pd[3].id),
		  new PP_Workshop_Member__c(PP_Workshop__c = pww.id, Practice_Doctor__c = pd[4].id)};
		  insert pww_mem;
	  }
	  
  static testmethod void testchecklist_psa() {
  	init();
  	test.startTest();
  	
  	Implementation_Checklist__c ic = [select id,dental_practice__c from Implementation_Checklist__c limit 1];
  	ApexPages.StandardController con = new ApexPages.StandardController(ic);
  	checklist_psa psa_ext = new checklist_psa(con);
  	psa_ext.dp.psa_contract_completed__c = true;
  	psa_ext.psa_updated();
  
    test.stoptest();
  }
  
  static testMethod void ImplantTest() {
  	init();
  	test.startTest();
  	
  	User my_test_user =[select id,name from User where email = 'testu@clearchoice.com'];
  	
  	System.runas(my_test_user) {
	  	Pagereference pageref = new PageReference('/apex/patient_implants');
	    Test.setCurrentPage(pageRef);      
	    ctrl_patientimplants cpi = new ctrl_patientimplants();
	    cpi.getcurrent_implants_size();
	    System.assert(cpi.getuser_name()==Userinfo.getName());
	    System.assert(cpi.getpatient_display_name()=='<span style="font-style:italic;">Use the search feature below to select your patient</span>');
	    
	    cpi.patient_search();
	    System.assert(cpi.patient_search_error);
	    cpi.name_filter = 'Test';
	    cpi.center_filter = 'Test Austin';
	    cpi.patient_search();
	    List<ctrl_patientimplants.practice_patient> olist = cpi.getpatient_search_results();
	    for(ctrl_patientimplants.practice_patient patient : olist) {
	      patient.getprosth_date();
	      patient.gettx_plan();
	      patient.getpatient_email();
	      patient.getpatient_phone();
	    }
	    System.assert(olist.size()>=1);
	    //Opportunity o = [select id,name from Opportunity limit 1];	    
	    //pageRef.getParameters().put('oid','FAIL');
	    Account a = [select id,name from Account limit 1];
	    pageRef.getParameters().put('aid','FAIL');
	    cpi.select_patient();
	    
	    pageRef.getParameters().put('aid',a.id);
	    cpi.select_patient();
	    System.assert(cpi.getpatient_display_name()==a.name);
	    
	    List<ctrl_patientimplants.implant_info> plist = cpi.getcurrent_implants();
	    System.assert(plist.size()==0);
	    System.assert(cpi.getcurrent_implants_size()==0);
	    cpi.add_implant();
	    //System.assert(cpi.implant_error_message == '<span class="warning">You must enter something into the lot number field for this implant</span>');
	    cpi.implant.Lot_Number__c = '1111';
	    //Implant_Parts__c i = [select id from Implant_Parts__c limit 1];
	    //cpi.implant.implant__c = i.id;
	    //cpi.add_implant();
	    cpi.implant.implant_free__c = '12611';
	    cpi.add_implant();    
	    System.assert(cpi.implant_error==false);
	    cpi.current_implants[0].pi.implant_status__c = 'Installed';    
	    cpi.update_implant_status();
	    
	    cpi.delete_implant();
	    pageRef.getParameters().put('dimpid',cpi.current_implants[0].pi.id);
	    cpi.delete_implant();
	    
	    cpi = new ctrl_patientimplants();
	    pageref = new PageReference('/apex/patient_implants');
	    Test.setCurrentPage(pageRef);
	    cpi.name_filter = 'Test';
	    cpi.center_filter = 'Test Austin';
	    Private_Practice_Patient__c pp = [select id,name from Private_Practice_Patient__c limit 1];
	    //pageRef.getParameters().put('oid',null);
	    pageRef.getParameters().put('aid',null);
	    pageRef.getParameters().put('ppid','FAIL');
	    cpi.select_patient();
	    
	    pageRef.getParameters().put('ppid',pp.id);
	    cpi.select_patient();  
	    
	    cpi.change_patient();
	    System.assert(cpi.patient_search_message=='<span class="warning" style="color:red;">Please type in part of a name to search for a patient</span>');
	    cpi.select_patient();
	    
	    plist = cpi.getcurrent_implants();
	    System.assert(plist.size()==0);
	    System.assert(cpi.getcurrent_implants_size()==0);
	    cpi.add_implant();
	    //System.assert(cpi.implant_error_message == '<span class="warning">You must enter something into the lot number field for this implant</span>');
	    cpi.implant.Lot_Number__c = '1111';
	    //Implant_Parts__c i = [select id from Implant_Parts__c limit 1];
	    //cpi.implant.implant__c = i.id;
	    //cpi.add_implant();
	    cpi.implant.implant_free__c = '12611';
	    cpi.add_implant();    
	    System.assert(cpi.implant_error==false);
	    cpi.current_implants[0].pi.implant_status__c = 'Installed';
	    cpi.current_implants[0].getallow_edit();    
	    cpi.update_implant_status();
	    
	    cpi.delete_implant();
	    pageRef.getParameters().put('dimpid',cpi.current_implants[0].pi.id);
	    cpi.delete_implant();
	    cpi = new ctrl_patientimplants();
  	}
  	
  	test.stopTest();
  }
  
  static testmethod void ImplantNewPatient() {
  	init();
  	test.startTest();
  	
  	User my_test_user =[select id,name from User where email = 'testu@clearchoice.com'];
  	
  	System.runas(my_test_user) {
	  	Pagereference pageref = new PageReference('/apex/patient_implants');
	    Test.setCurrentPage(pageRef);      
	    ctrl_patientimplants cpi = new ctrl_patientimplants();
	    cpi.name_filter = 'Test';
	    cpi.center_filter = 'Test Austin';
	    cpi.new_private_practice_form();
	    try {
	      cpi.add_practice_patient();
	    } catch (Exception e) {
	    	
	    }
	    cpi.new_patient.first_name__c = 'First';
	    cpi.add_practice_patient();
	    cpi.new_patient.last_name__c = 'last';
	    cpi.add_practice_patient();
	    cpi.new_patient.practice_id__c = 'Test123';
	    cpi.add_practice_patient();
	    cpi.new_patient.patient_email__c = 'firstlast@clearchoice.com';
	    cpi.add_practice_patient();
  	}
  	
  	test.stopTest();
  }
  
  static testMethod void BadgeTest() {
  	init();
  	test.startTest();
  	  	
  	PP_Workshop__c ppw = [select id from PP_Workshop__c where name = 'Test Workshop' order by createddate desc limit 1];
  	PP_Workshop_Member__c pm = [select id,practice_doctor__c,event_status__c from PP_Workshop_Member__c where pp_workshop__c = :ppw.id order by createddate desc limit 1];
  	pm.event_status__c = 'Attended';
  	update pm;
  	Dental_Practice__c dp = [select id,primary_contact_email__c from Dental_Practice__c order by createddate desc limit 1];  	
  	Pagereference pageref = new PageReference('/apex/event_tags?pwid=' + ppw.id);  	
    Test.setCurrentPage(pageRef);      
    ctrl_workshop_badge cb = new ctrl_workshop_badge();
    List<ctrl_workshop_badge.name_tags> tags = cb.all_tags;
    for(ctrl_workshop_badge.name_tags nt : tags) {
      nt.getpage_break();
    }
    for(ctrl_workshop_badge.blank_tags btags : cb.free_tags) {
      btags.getpage_break();
    }
    
    pageref = new PageReference('/apex/event_tags?pmid=' + pm.id);
    Test.setCurrentPage(pageRef);
    cb = new ctrl_workshop_badge();  	
    tags = cb.all_tags;
    for(ctrl_workshop_badge.name_tags nt : tags) {
      nt.getpage_break();
    }
    for(ctrl_workshop_badge.blank_tags btags : cb.free_tags) {
      btags.getpage_break();
    }
    
    ctrl_workshop_badge.email_application_all(ppw.id);
    ctrl_workshop_badge.email_application_single(pm.practice_doctor__c);
    ctrl_workshop_badge.workshop_reminder_all(ppw.id);
    ctrl_workshop_badge.workshop_reminder_single(pm.id);
    ctrl_workshop_badge.email_compliance_form(dp.id); 
    
    ctrl_workshop_badge.email_psa_request_form(dp.id);  
    ctrl_workshop_badge.next_steps_email(dp.id); 
    
    
// Create a new email and envelope object 
    Messaging.InboundEmail email  = new Messaging.InboundEmail(); 
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
    email.plainTextBody = 'This should become a note'; 
    email.fromAddress ='test@test.com'; 
    String contactEmail = 'test@fake.com'; 
    email.toAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
    email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'}; 
    email.subject = 'Dummy Account Name 123'; 
    ppriv_emailhandler edr = new ppriv_emailhandler(); 

    Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env); 
    
    Practice_Doctor__c pd = [select id from Practice_Doctor__c where id = :pm.practice_doctor__c];
    delete pd;
    Test.stopTest(); 
  }
  
  static testMethod void WorkshopAttendanceTest() {
  	init();
  	test.startTest();
  	
  	PP_Workshop__c ppw = [select id from PP_Workshop__c where name = 'Test Workshop' order by createddate desc limit 1];
  	PP_Workshop_Member__c pm = [select id,practice_doctor__c from PP_Workshop_Member__c order by createddate desc limit 1];  	  	
  	Pagereference pageref = new PageReference('/apex/pp_workshop_tracker');  	
    Test.setCurrentPage(pageRef); 
    ctrl_event_attendance ctrl = new ctrl_event_attendance();
    
    ctrl.event_filter = '';
    ctrl.event_search();
    System.assert(ctrl.event_search_message == '<span class="warning" style="color:red;">Please type in part of a name to search for an event</span>');
    
    //test invalid event id
    ctrl.event_filter = 'Test';
    ctrl.event_search();
    List<PP_Workshop__c> list_holder = ctrl.getevent_search_results();
    System.assert(list_holder.size()>0);
    
    pageref.getParameters().put('eid', 'Invalid ID');
    
    //test good event id
    ctrl.select_event();
    pageref.getParameters().put('eid', ppw.id);
    ctrl.select_event();
    
    ctrl.name_filter = 'Test';
    ctrl.name_search();
    
    List<PP_Workshop_Member__c> members_list = ctrl.getmember_search_results();
    System.assert(members_list.size()>0);
    
    ctrl.ticket_scan = 'No Match';
    ctrl.handle_ticket_scan();
    System.assert(ctrl.event_scan_results.contains('was not matched up to this event'));
    
    ctrl.ticket_scan = pm.id;
    ctrl.handle_ticket_scan();
    
    pageref.getParameters().put('mid', 'Fail');
     ctrl.select_member();
     ctrl.reset_member();
    
    for(PP_Workshop_Member__c wm : members_list) {
      pageref.getParameters().put('mid', wm.id);
      ctrl.select_member();
      ctrl.reset_member();      
    }
    
    
    ctrl.change_event();
            
  }
}