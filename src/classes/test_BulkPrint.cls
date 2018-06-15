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
private class test_BulkPrint {
	static lead_bulkprintpending my_ext;
	static lead_bulkprintpending my_ext_bad;
	static lead_bulkprintpending my_ext_conf1;
	static lead_bulkprintpending my_ext_conf2;
	static lead_bulkprintpending my_ext_conf3;
	static lead_bulkprintpending my_ext_conf0;
	
	static Lead l;
	static Lead l_bad;
	static Lead[] test_confirmation;
	
	static User my_test_user;
	static Pagereference pageref;
	
	static {
		//Clean Up for the Sandbox
		list<Awaiting_Bulk_Print__c> bad_records = [select id from awaiting_bulk_print__c where Lead_Id__c = null];
		delete bad_records;
		//generate a test user id to use below
		Profile p = [select id from Profile where name = 'System Administrator'];		
		my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
	}
	
	private static void init() {
		Util_TriggerContext.alteralreadyprocessed(true);
	  Date my_date = date.today();
	  my_date = my_date.addDays(7);
	  Datetime test_date = datetime.newInstance(my_date.year(),my_date.month(),my_date.day(),18,30,0);
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', Street_2__c = 'Test 2', city__c = 'Denver', state__c = 'Colorado',
		directions__c = 'take a left,  straight on till morning', zip_code__c = '80012',  
		cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
		send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com', call_center_marketing__c = '555-555-5555', time_zone__c = 'MST');
	  insert test_center; 	        
	  l = new Lead(Center__c = test_center.id,Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown1', FirstName = 'Test', Gender__c = 'Male',
      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', 
      Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date, Email = 'test_lead@clearchoice.com',Phone='1111111111', pre_screen__c='Green',mobilephone='5555555555');
	  insert l;
	  
	  Campaign test_campaigns = new Campaign(Name = 'My Test Campaign', Center__c = test_center.id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '9445553467', StartDate = Date.today());
	  insert test_campaigns;
	  
	  Blob bodyBlob=Blob.valueOf('Test Doc');	  
	  Attachment a = new Attachment(parentid = test_center.id, Name = 'test_doc', body = bodyblob, contenttype = 'application/pdf');
	  insert a;
	  
	  CampaignMember new_cm = new CampaignMember(campaignid = test_campaigns.id, leadid = l.id);
	  insert new_cm;	  
	  
	  l_bad = new Lead(Center__c = test_center.id,Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown1', FirstName = 'Test', Gender__c = 'Male',
      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', 
      Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date,language_spoken__c = 'Spanish',phone='1111111111',Refused_to_give_email__c=true);
	  insert l_bad;	  
	  
	  test_confirmation = new Lead[] { 
	    new Lead(Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown1', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'English', Confirmed_Appointment__c = false,phone='1111111111',Refused_to_give_email__c=true),
	    new Lead(Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown2', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today(), Language_Spoken__c = 'English', Confirmed_Appointment__c = true,phone='1111111111',Refused_to_give_email__c=true),
	    new Lead(Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown3', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today().addDays(9), Language_Spoken__c = 'Spanish', Confirmed_Appointment__c = false,phone='1111111111',Refused_to_give_email__c=true),  
	    new Lead(Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown4', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Consultation Scheduled', Marketing_Source__c = 'I Have No Match', Last_Marketing_Source__c = 'I have no match', Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = Date.today(), Language_Spoken__c = 'Spanish', Confirmed_Appointment__c = true,phone='1111111111',Refused_to_give_email__c=true)};
	  insert test_confirmation;	
	  
	  Consult_Rooms__c cr = new Consult_Rooms__c(Center_information__c = test_center.id, name = 'Test room', active__c = true, room_type__c = 'Normal', sort_order__c = 1);
	  insert cr;  
	  
	  List<Consult_inventory__c> ci_list = new List<Consult_Inventory__c> {
	  	new Consult_Inventory__c(consult_room__c = cr.id, apt_date__c = System.today(), start_hour__c = '7', scheduled_lead__c = test_confirmation[0].id, start_minute__c = '10', end_hour__c = '8', end_minute__c = '10'),
	  	new Consult_Inventory__c(consult_room__c = cr.id, apt_date__c = System.today(), start_hour__c = '7', scheduled_lead__c = test_confirmation[1].id, start_minute__c = '10', end_hour__c = '8', end_minute__c = '10'),
	  	new Consult_Inventory__c(consult_room__c = cr.id, apt_date__c = System.today(), start_hour__c = '7', scheduled_lead__c = test_confirmation[2].id, start_minute__c = '10', end_hour__c = '8', end_minute__c = '10'),
	  	new Consult_Inventory__c(consult_room__c = cr.id, apt_date__c = System.today(), start_hour__c = '7', scheduled_lead__c = test_confirmation[3].id, start_minute__c = '10', end_hour__c = '8', end_minute__c = '10')
	  };
	  insert ci_list;
	  	  
	  ApexPages.StandardController con = new ApexPages.StandardController(l);
      my_ext = new lead_bulkprintpending(con);
      con = new ApexPages.StandardController(l_bad);
      my_ext_bad = new lead_bulkprintpending(con);
    
      con = new ApexPages.StandardController(test_confirmation[0]);
      my_ext_conf0 = new lead_bulkprintpending(con);
      con = new ApexPages.StandardController(test_confirmation[1]);
      my_ext_conf1 = new lead_bulkprintpending(con);
      con = new ApexPages.StandardController(test_confirmation[2]);
      my_ext_conf2 = new lead_bulkprintpending(con);
      con = new ApexPages.StandardController(test_confirmation[3]);
      my_ext_conf3 = new lead_bulkprintpending(con);	 
    
      pageref = Page.BulkPrintQueue;
      Test.setCurrentPage(pageref);     
	}
	
	static testMethod void SendEmail() {
		init();		
		test.startTest();
		String test_lead_id = my_ext.getparent_id();
		System.assert(l.id == test_lead_id);
		
		my_ext.getisleadvalid();
		my_ext.single_welcome();
		my_ext.getnetwork_center_record();
		
		my_ext.send_bcp_email();		
		System.assert(my_ext.email_result == '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>');
		my_ext.send_welcome_email();		
		System.assert(my_ext.email_result == '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>');
		my_ext.send_seminar_email();		
		System.assert(my_ext.email_result == '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>');
		
		Integer task_cnt = [Select count() From Task t where t.whoid = :l.id];
		System.assert(task_cnt==3);
		
		my_ext_bad.send_bcp_email();
		System.assert(my_ext_bad.email_result.contains('Error - Email Not Sent'));
		my_ext_bad.send_welcome_email();
		System.assert(my_ext_bad.email_result.contains('Error - Email Not Sent'));
//	  my_ext_bad.send_seminar_email();
	//	System.assert(my_ext_bad.email_result.contains('Error - Email Not Sent'));
		
		task_cnt = [Select count() From Task t where t.whoid = :l_bad.id];
		System.assert(task_cnt==0);
		
		my_ext_conf0.send_confirmation_email();		
		System.debug('Confirmation : ' + test_confirmation[0].Confirmed_Appointment__c + ' Language : ' + test_confirmation[0].Language_Spoken__c + ' ' + my_ext_conf0.confirmation_template);
		System.assert(my_ext_conf0.confirmation_template=='Appointment_Confirmation_New');
		my_ext_conf1.send_confirmation_email();		
		System.debug('Confirmation : ' + test_confirmation[1].Confirmed_Appointment__c + ' Language : ' + test_confirmation[1].Language_Spoken__c + ' ' + my_ext_conf1.confirmation_template);
		System.assert(my_ext_conf1.confirmation_template=='Friendly_Reminder_V');
		my_ext_conf2.send_confirmation_email();
		System.debug('Confirmation : ' + test_confirmation[2].Confirmed_Appointment__c + ' Language : ' + test_confirmation[2].Language_Spoken__c + ' ' + my_ext_conf2.confirmation_template);		
		System.assert(my_ext_conf2.confirmation_template=='Appointment_Confirmation_Spanish');
		my_ext_conf3.send_confirmation_email();		
		System.debug('Confirmation : ' + test_confirmation[3].Confirmed_Appointment__c + ' Language : ' + test_confirmation[3].Language_Spoken__c + ' ' + my_ext_conf3.confirmation_template);
		//System.assert(my_ext_conf3.confirmation_template=='Friendly_Reminder_spanish_V');		
		 
		System.assert(my_ext.getdisplay_seminaremail()==true);
		System.assert(my_ext.getdisplay_confirmationemail()==true);
		my_ext_conf3.getdisplay_bulkqueue();
		my_ext_conf3.bulk_queue();
		
		test.stopTest();
	}
	
	static testMethod void QueueBulkLetters() {
		init();
		test.startTest();
		
		//should return false with no jobs in the queue
		System.assert(!my_ext.getdisplaybulkprintqueue());
		my_ext.send_bcp();
		my_ext.send_welcome();
		my_ext.send_seminar();
		
		list<Awaiting_Bulk_Print__c> bulk_cnt = [select id from Awaiting_Bulk_Print__c where lead_id__c = :l.id];
		System.assert(bulk_cnt.size()==3);
		my_ext.getbulkjobs();
		
		my_ext.delrecordid = bulk_cnt[0].Id;
		my_ext.removePrintJob();
		Integer del_cnt = [select count() from Awaiting_Bulk_Print__c where id = :bulk_cnt[0].id];
		System.assert(del_cnt==0);
		
		test.stopTest();
	}
	
	static testMethod void BulkPrintQueueWelcome() {
		init();
		test.startTest();
		
		//make sure we'll have some jobs in the queue to test with
		my_ext.send_welcome();
		my_ext_bad.send_welcome();
		Ctrl_BulkPrintLetters bulk_con = new Ctrl_BulkPrintLetters();
		Integer num_welcome = bulk_con.num_welcome;
		System.assert((num_welcome + bulk_con.num_welcome_no_prescreen) >= 2);
		System.debug('Welcome Cnt : ' + bulk_con.num_welcome);
		
		Test.setCurrentPage(bulk_con.print_welcome_letters());		
		bulk_con = new Ctrl_BulkPrintLetters();
		String test_batch_id = bulk_con.getbatch_id();
		Integer detail_cnt = [select count() from Bulk_Print_Detail__c where Bulk_Print_No__c = :bulk_con.getbatch_id()];
		System.debug('--Print Welcome Letters-- Detail Cnt : ' + detail_cnt + ' # Welcome : ' + num_welcome + ' Batch Id : ' + test_batch_id);
		//System.assert(detail_cnt >= num_welcome);
	    String welcome_letter_output = bulk_con.getletter_output();
	    bulk_con.output_welcome_file();
		System.assert(welcome_letter_output.contains('welcome_letter'));
		Test.setCurrentPage(bulk_con.confirm_print());
		bulk_con = new Ctrl_BulkPrintLetters();
		
		Test.setCurrentPage(bulk_con.print_welcome_letters_no_prescreen());		
		bulk_con = new Ctrl_BulkPrintLetters();
		test_batch_id = bulk_con.getbatch_id();
		detail_cnt = [select count() from Bulk_Print_Detail__c where Bulk_Print_No__c = :bulk_con.getbatch_id()];
		System.debug('--Print Welcome Letters-- Detail Cnt : ' + detail_cnt + ' # Welcome : ' + num_welcome + ' Batch Id : ' + test_batch_id);
		//System.assert(detail_cnt >= num_welcome);
	    welcome_letter_output = bulk_con.getletter_output();
	    bulk_con.output_welcome_file();
		System.assert(welcome_letter_output.contains('welcome_letter'));
		Test.setCurrentPage(bulk_con.confirm_print());
		bulk_con = new Ctrl_BulkPrintLetters();
//		System.assert(bulk_con.num_welcome==0);
		
		for(Bulk_Print_Summary__c bulk_history : bulk_con.getprint_history()) {
		  if(bulk_history.id == test_batch_id) {
		  	//verify the confirmed print job is flagged as a success		  	
		  	System.assert(bulk_history.Print_Successful__c);
		  }	
		}
		
		bulk_con.reprint_id = test_batch_id;
		Test.setCurrentPage(bulk_con.reprint());
		//bulk_con = new Ctrl_BulkPrintLetters();
		//pulling this - excessive memory usage when a large queue - alternate option is doing a limit when testis running.
		//String reprint_output = bulk_con.getletter_output();
		//System.assert(reprint_output==welcome_letter_output);
		
		//Integer printed_cnt = [select count() from Awaiting_Bulk_Print__c aw where Status__c = 'Printed'];
		//bulk_con.update_task_entries();
		ctrl_bulkprintletters.update_task_entries();
		//Integer update_cnt = [select count() from Awaiting_Bulk_Print__c aw where Status__c = 'Printed'];
		//System.assert(printed_cnt>update_cnt);
		test.stopTest();
	}
	
  static testMethod void BulkPrintQueueBCP() {
		init();
		test.startTest();
		
		//make sure we'll have some jobs in the queue to test with
		my_ext.send_bcp();
		my_ext_bad.send_bcp();
		Ctrl_BulkPrintLetters bulk_con = new Ctrl_BulkPrintLetters();
		Integer num_bcp = bulk_con.num_bcp;
		System.assert(num_bcp >= 2);
		System.debug('BCP Cnt : ' + bulk_con.num_bcp);
		
		Test.setCurrentPage(bulk_con.print_bcp_letters());
		bulk_con = new Ctrl_BulkPrintLetters();
		String test_batch_id = bulk_con.getbatch_id();
		Integer detail_cnt = [select count() from Bulk_Print_Detail__c where Bulk_Print_No__c = :bulk_con.getbatch_id()];
		//if(detail_cnt <= 500)
		  //System.assert(detail_cnt >= num_bcp);
		String letter_output = bulk_con.getletter_output();
		System.assert(letter_output.contains('bcp_letter'));
		bulk_con.getbatch_name();
		Test.setCurrentPage(bulk_con.cancel_print());
		bulk_con = new Ctrl_BulkPrintLetters();
		//we canceled the print job,  so the detail cnt should indicate we still have all the jobs queued up
		System.assert(bulk_con.num_bcp >= num_bcp);
		
		for(Bulk_Print_Summary__c bulk_history : bulk_con.getprint_history()) {
		  if(bulk_history.id == test_batch_id) {
		  	//verify the canceled print job is flagged as a failure		  	
		  	System.assert(!bulk_history.Print_Successful__c);
		  }	
		}

		test.stopTest();
	}
	
	static testMethod void BulkPrintQueueSeminar() {
		init();
		test.startTest();
		
		//make sure we'll have some jobs in the queue to test with
		my_ext.send_seminar();
		my_ext_bad.send_seminar();
		Ctrl_BulkPrintLetters bulk_con = new Ctrl_BulkPrintLetters();
		Integer num_seminar = bulk_con.num_seminar;
		System.assert(num_seminar >= 2);
		System.debug('Seminar Cnt : ' + bulk_con.num_seminar);
		
		Test.setCurrentPage(bulk_con.print_seminar_letters());
		bulk_con = new Ctrl_BulkPrintLetters();
		String test_batch_id = bulk_con.getbatch_id();
		Integer detail_cnt = [select count() from Bulk_Print_Detail__c where Bulk_Print_No__c = :bulk_con.getbatch_id()];
		//placed a limit on this,  so the counts won't match if that triggers
		//if(detail_cnt!=25)
		  System.assert(detail_cnt >= num_seminar);
	  String seminar_letter_output = bulk_con.getletter_output();
		System.assert(seminar_letter_output.contains('seminar_letter'));
		Test.setCurrentPage(bulk_con.confirm_print());
		bulk_con = new Ctrl_BulkPrintLetters();
		//if(detail_cnt!=25)
		  System.assert(bulk_con.num_seminar==0);
		
		for(Bulk_Print_Summary__c bulk_history : bulk_con.getprint_history()) {
		  if(bulk_history.id == test_batch_id) {
		  	//verify the confirmed print job is flagged as a success		  	
		  	System.assert(bulk_history.Print_Successful__c);
		  }	
		}
		
		//Integer printed_cnt = [select count() from Awaiting_Bulk_Print__c aw where Status__c = 'Printed'];
		//bulk_con.update_task_entries();
		Ctrl_BulkPrintLetters.update_task_entries();
		//Integer update_cnt = [select count() from Awaiting_Bulk_Print__c aw where Status__c = 'Printed'];
		//System.assert(printed_cnt>update_cnt);
		test.stopTest();
	}
	
	static testMethod void SinglePrint() {
		init();
		test.startTest();
		Pagereference t = my_ext.single_bcp();
		Test.setCurrentPage(t);
		ctrl_MailMerge mm = new ctrl_MailMerge();
		mm.getsingle_print();
		
		t = my_ext.single_seminar();
		Test.setCurrentPage(t);
		mm.form_num=2;
		mm.getsingle_print();
		
		Pagereference t1 = new PageReference('/apex/single_print?form_num=2&id=' + l_bad.id);
		Test.setCurrentPage(t1);
		mm = new ctrl_MailMerge();
		mm.getsingle_print();		
		
		t = new PageReference('/apex/single_print?id=' + l.id);    
    Test.setCurrentPage(t);
    mm = new ctrl_MailMerge();
    mm.getsingle_print();
		mm.form_num=3;		
		mm.getsingle_print();
		mm.update_task_entries();
		
		t1 = new PageReference('/apex/single_print?form_num=3&id=' + l.id);
		Test.setCurrentPage(t1);
		mm = new ctrl_MailMerge();
		
		test.stopTest();
	}
	
	static testMethod void centerVFpage_Test() {
	  init();
		test.startTest();
		Campaign test_campaign = new Campaign(Name = 'My Test Campaign', Center__c = l.center__c, isActive = true, time__c = '12:30 PM', Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '1112223333', StartDate = Date.today());
		insert test_campaign;
    pageRef = new PageReference('/apex/centerVFpage?id=' + l.id + '&cid=' + test_campaign.id + '&nguests=1');
    Test.setCurrentPageReference(pageRef);
    ApexPages.StandardController sc = new ApexPages.standardController(l);
    lead_upcomingseminars myCon = new lead_upcomingseminars(sc);    
    Integer seminars = myCon.getseminar_num();
    System.assert(seminars>0,'Value of seminar_num : ' + seminars);
    myCon.getcenter_upcoming_seminars();    
    myCon.register_seminar();    
    myCon.getdisplay_gold();
    myCon.cancel_seminar();
    myCon.getschedule_num();
    myCon.getcenter_upcoming_seminars();
    mycon.getpatient_sched_bool();
    myCon.getpatient_sched_status();
    myCon.getisLeadValid();
    ClearChoice_Doctor__c cd = new ClearChoice_Doctor__c(first_name__c = 'test', last_name__c = 'doctor', center_information__c = l.center__c);
	insert cd;
    myCon.getdoctor_list();
    my_test_user.center_pec__c = l.center__c;
    update my_test_user;
    myCon.getpec_list();
    my_test_user.center_administrator__c = true;
    update my_test_user;
    myCon.getca_list();

    test.stopTest();
  }
  
  static testMethod void testInfocision() {
  	//Most of this is duplicate code with a simple profile filter change - not doing anything in depth here
    init();
		test.startTest();
		Ctrl_BulkPrintLetters cb = new Ctrl_BulkPrintLetters();
		cb.print_bcp_info_letters();
		cb.print_welcome_info_letters();
		cb.print_seminar_info_letters();
  	test.stopTest();
  }
  
  static testMethod void testlead_mail_cleanup() {
  	init();
  	test.startTest();
  	Center_Information__c test_center = [select id from Center_Information__c where name = 'Test Center'];
  	Date my_date = date.today();
	  my_date = my_date.addDays(7);
	  Datetime test_date = datetime.newInstance(my_date.year(),my_date.month(),my_date.day(),18,30,0);
  	List<Lead> new_leads = new List<Lead> {new Lead(Center__c = test_center.id,Inbound_Call__c = 'Dental Inquiry',  bcp_dvd_packet_sent__c = false,email_welcome_packet_sent__c = false,
      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown2', FirstName = 'Test', Gender__c = 'Male', pre_screen__c = 'Green',Welcome_Packet_Sent__c = false,
      Call_Result__c = 'Consultation Scheduled',marketing_source__c = 'CCWebsiteOSI', Last_Marketing_Source__c = null, 
      Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date, Email = 'test_lead@clearchoice.com',Phone='1111111111', mobilephone='5555555555'),
      new Lead(Center__c = test_center.id,Inbound_Call__c = 'Dental Inquiry',  bcp_dvd_packet_sent__c = false,email_welcome_packet_sent__c = false,
      Call_Center_Agent__c = my_test_user.id, LastName = 'Unknown3', FirstName = 'Test', Gender__c = 'Male', pre_screen__c = 'Green',Welcome_Packet_Sent__c = false,
      Call_Result__c = 'Consultation Scheduled',marketing_source__c = 'CCWebsiteOSI', Last_Marketing_Source__c = null, 
      Status = 'Consult Scheduled', DateTime_Consult_Scheduled__c = test_date, Phone='1111111111', mobilephone='5555555555')
  	};
  	insert new_leads;
  	lead_mail_cleanup.check_for_lead_cleanup();
  	test.stopTest();
  }
  
  static testMethod void BulkPrintBCP() {
		init();
		test.startTest();
		
		//make sure we'll have some jobs in the queue to test with
		my_ext.send_bcp();
		Ctrl_BulkPrintLetters bulk_con = new Ctrl_BulkPrintLetters();
		Integer num_bcp = bulk_con.num_bcp;
		
		Test.setCurrentPage(bulk_con.print_bcp_letters());
		bulk_con = new Ctrl_BulkPrintLetters();
		String test_batch_id = bulk_con.getbatch_id();
		Integer detail_cnt = [select count() from Bulk_Print_Detail__c where Bulk_Print_No__c = :bulk_con.getbatch_id()];
		
		Center_Information__c ci = [select id,name,transunion_eligible__c,Letter_Address__c,call_center_marketing__c,BCP_Center__c,zip_code__c,street_2__c,street_1__c,state__c,city__c,time_zone__c from Center_Information__c limit 1];
		Lead my_lead = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, 
	  	  l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,
	  	  l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c
	      from lead l where  l.center__c != null and datetime_consult_scheduled__c != null limit 1];
        //bulk_con.generate_bcp_letter_v5_14(my_lead);
        //bulk_con.generate_network_bcp_letter_v5_14(my_lead,ci);
        //bulk_con.generate_welcome_letter_v5_14(my_lead);
        bulk_con.generate_network_bcp_letter_v6_1(my_lead,ci);
        bulk_con.generate_bcp_letter_v6_1(my_lead);
        bulk_con.generate_welcome_letter_v6_1(my_lead);
        bulk_con.generate_welcome_letter_v6_1_FTL(my_lead);
        bulk_con.generate_network_bcp_letter_v6_1_no_prescreen(my_lead,ci);
        bulk_con.generate_bcp_letter_v6_1_no_prescreen(my_lead);
        bulk_con.generate_welcome_letter_v6_1_no_prescreen(my_lead);
        bulk_con.generate_welcome_letter_v6_1_no_prescreen_FTL(my_lead);
        
        bulk_con.generate_spanish_welcome_letter(my_lead);
        bulk_con.download_welcome_letters();
        
        Test.setCurrentPage(bulk_con.download_bcp_letters());
        bulk_con = new Ctrl_BulkPrintLetters();
        bulk_con.getfile_details();
        bulk_con.gethyper_prefix();
        bulk_con.output_bcp_file();
        
        Test.setCurrentPage(bulk_con.download_welcome_letters());
        bulk_con = new Ctrl_BulkPrintLetters();
        bulk_con.getfile_details();
        bulk_con.gethyper_prefix();
        bulk_con.output_welcome_file();    
        
        bulk_con.getsummary_id();       

		test.stopTest();
	}
	
}