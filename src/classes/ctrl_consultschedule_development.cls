/*modified by cm on 2014-10-07
Build process will now check center open days and if a day is not flagged as open,  it will skip it
*/

public class ctrl_consultschedule_development {
  public CalendarMonth cmonth;
  public String calendar_view {get;set;}
  public Date selected_date {get;set;}
  public String troubleshoot_msg {get; set;}
  public String new_room_issues {get; set;}
  public String new_room_note_issues {get; set;}
  public String selected_center {get; set;}
  public String mass_clear_message {get; set;}
  public String selected_center_name;
  public Boolean mass_clear_verified {get; set;}
  public Boolean mass_clear_check {get; set;}

  public Boolean display_schedule_admin {get; set;}
  public Boolean display_admin {get; set;}
  public Boolean display_cc {get; set;}
  public Boolean display_cc_lead {get; set;}
  public Boolean display_cc_sup {get; set;}
  public Boolean display_confirmation {get; set;}
  public Boolean display_practice {get; set;}
  public Boolean display_seminar {get; set;}
  public Boolean display_prescreen {get; set;}

  public Boolean display_ca;
  public Boolean network_center_user;
  public Boolean doc_exception;
  public String main_view {get; set;}
  public Account scheduling_account {get; set;}
  public Private_Practice_Patient__c scheduling_patient {get; set;}
  public Consult_Rooms__c new_room {get; set;}
  public Lead scheduling_lead {get; set;}
  public Consult_Room_Note__c new_note {get; set;}
  public Consult_Room_Note__c end_note {get; set;}
  public Consult_Room_Note__c mass_start {get; set;}
  public Consult_Room_Note__c mass_end {get; set;}
  public Consult_Inventory__c view_apt {get; set;}
  public Consult_Rooms__c mass_clear_unconfirmed {get; set;}
  //variables used to control the display of the modal-popup
  public Boolean modal_display {get; set;}
  public Boolean reschedule {get; set;}
  public Date reschedule_date {get; set;}
  public Boolean reschedule_callback_consult {get; set;}
  public String reschedule_callback_consult_pec {get; set;}
  public string reschedule_notes {get; set;}
  public string reschedule_treatment {get; set;}
  public ID rescheduled_by {get; set;}
  public datetime rescheduled_time {get; set;}
  public String reschedule_will_show {get; set;}
  public String reschedule_will_start {get; set;}
  public String reschedule_confirmation_status {get; set;}
  public boolean reschedule_gc {get; set;}
  public String modal_type {get; set;}
  public Consult_Inventory__c reschedule_source_consult;
  public ID reschedule_source_id;
  public String cancel_reason {get; set;}
  public String modal_out {get; set;}
  public String hold_message {get; set;}
  public String reschedule_reason {get; set;}
  public String delete_reason {get; set;}
  public String delete_note {get; set;}
  public String mass_delete_reason {get; set;}
  public String mass_delete_note {get; set;}
  public String user_profile_name {get; set;}
  public String lead_valid_errors {get; set;}
  public Weather__c current_weather {get; set;}

  public ctrl_consultschedule_development() {
	  set_permissions();
 //  	display_practice = getdisplay_practice();
 //  	System.debug('Practice : ' + display_practice);
  	if(apexpages.currentpage().getparameters().get('aid')==null) {
  	  selected_date = System.today();
  	}
  	else {
  		Consult_Inventory__c passed_block = [select apt_date__c from Consult_Inventory__c where id = :apexpages.currentpage().getparameters().get('aid')];
  	  selected_date = passed_block.apt_date__c;
  	}
  	if(apexpages.currentPage().getParameters().get('cdate')!=null)
  	  selected_date = Date.parse(apexpages.currentpage().getparameters().get('cdate'));
  	System.debug('AID : ' + apexpages.currentpage().getparameters().get('aid'));
  	System.debug('Selected Date : ' + selected_date);
  	//selected_date = System.today();
  	modal_display = false;
  	modal_out = '';
  	//today_date = today_date.addDays(7);
  	calendar_view = 'calendar';
  	main_view = 'consult_view';
  	troubleshoot_msg = '';
  	new_room_issues = '';
  	lead_valid_errors = '';
  	if(apexpages.currentpage().getparameters().get('cid')==null)  {
      User u = [select clinic_calendar__c,Center_PEC__c from user where id =:userinfo.getUserId()];
      if(u.clinic_calendar__c==null) {
      	if(u.Center_PEC__c==null) {
      	  try {
            selected_center = [select id from Center_Information__c where name = 'Unknown'].id;
      	  }
      	  catch (Exception e) {
      	    selected_center = [select id from Center_Information__c order by name limit 1].id;
      	  }
      	}
      	else
      	  selected_center = [select id from Center_Information__c where id = :u.center_pec__c].id;
      }
      else
        selected_center = [select id from Center_Information__c where name = :u.clinic_calendar__c].id;
  	}
    else {
        //seems redundant,  but I'm throwing this in to handle some issues around short versions of the id field in URLS
        //this should keep the selected list and the calendar on the same page
      Integer count = [select count() from Center_Information__c where id = :apexpages.currentpage().getparameters().get('cid') limit 1];
      if(count>0)
        selected_center = [select id from Center_Information__c where id = :apexpages.currentpage().getparameters().get('cid') limit 1].id;
      else
        selected_center = apexpages.currentpage().getparameters().get('cid');
    }
    //check to see if we entered the page seeking to schedule a lead for a consult
    if(apexpages.currentpage().getparameters().get('lid')!=null) {
      scheduling_lead = [select referral_location__c,vantage_response__c,receive_text_reminder__c,receive_auto_reminder__c,createddate,work__c,inbound_call__c,status,left_message_to_confirm__c,call_result__c,objection__c,date_consult_scheduled_by_rep__c,confirmed_appointment__c,could_not_reach__c,DateTime_Consult_Scheduled__c,id,name,firstname,center__c,lastname,mobilephone,home_phone__c,pre_screen__c,prescreen_type__c,center__r.name,email,refused_to_give_email__c,fees_quoted__c,phone,Hot_List__c,Cancellation_List_Notes__c,leadscore__c,date_of_birth__c,center__r.type__c, Reminder_Call__c, Reminder_Text__c from Lead where id = :apexpages.currentpage().getparameters().get('lid')];
      if(scheduling_lead.center__c!=null)
        selected_center = scheduling_lead.center__c;
    }
    else if(apexpages.currentpage().getparameters().get('acntid')!=null) {
      scheduling_account = [select receive_text_reminder__c,receive_auto_reminder__c,id, FirstName, LastName,phone,personmobilephone,pre_screen__c,center__c,center__r.name,leadscore__c,createddate, Reminder_Call__c, Reminder_Text__c from account where id = :apexpages.currentpage().getparameters().get('acntid')];
      if(scheduling_account.center__c!=null)
        selected_center = scheduling_account.center__c;
    }
    else if(apexpages.currentpage().getparameters().get('ppid')!=null) {
      scheduling_patient = [Select p.full_name__c, p.Patient_Email__c, p.Name, p.Main_Phone__c, p.Last_Name__c, p.First_Name__c, p.CreatedDate, p.Center__c, p.center__r.name, p.Alt_Phone__c From Private_Practice_Patient__c p where id = :apexpages.currentpage().getparameters().get('ppid')];
      if(scheduling_patient.center__c!=null)
        selected_center = scheduling_patient.center__c;
    }
    System.debug('Start Center : ' + selected_center);
    cmonth = new CalendarMonth(selected_date,selected_center);
    reschedule = false;
    user_profile_name = [Select name from Profile where id = :userinfo.getProfileId()].name;
    // if(userinfo.getName()=='Chris McDowell') {
    //   //user_profile_name = 'Call Center - Supervisor Infocision';
    //   display_admin = true;
    //   //display_admin = false;
    //   display_cc = false;
    //   display_cc_sup = false;
    //   display_confirmation = false;
    //   display_seminar = false;
    //   display_ca = false;
    //   display_practice = true;
    // }
	// getdisplay_admin();
	// getdisplay_cc();
	// getdisplay_cc_sup();
	// getdisplay_confirmation();
	// getdisplay_seminar();
	// getdisplay_ca();
	// getdisplay_practice();
    reschedule_reason = '';
    cancel_reason = '';
    delete_reason = '';
    mass_delete_reason = '';
    delete_note = '';
    mass_delete_note = '';
    current_weather = getweather_info(selected_date);
	bulk_change_end_date = selected_date;
  }

	private void set_permissions() {
		Set<String> schedule_admin = new Set<String>{'CC Schedule Admin', 'System Administrator'};
		Set<String> practice       = new Set<String>{'FOA - TPLAN', 'FOA - No Prescreen - TPlan', 'Force.com Clinic Calendar', 'Force.com - Patient Intake', 'Force.com - Denver - Patient Intake', 'FOA - No Prescreen', 'PEC - PPF - NoPScreen - TPlan', 'Esthetician', 'Esthetics Manager', 'Practice Privileges Admin', 'System Administrator','HopeRX - Intake'};
		Set<String> admin          = new Set<String>{'CC Schedule Admin', 'Call Center Admin', 'Data Audit Team', 'Practice Privileges - Sys Admin', 'System Administrator', 'RBD', 'New System Administrator', 'System Administration - Test', 'CC Administrator', 'CC Administrator Development Tester', 'Call Center Admin', 'CC - Network Center Supervisor', 'Esthetics Manager', 'Practice Privileges Admin'};
		Set<String> cc             = new Set<String>{'Call Center Agent Jumpstart', 'Call Center - Advisor', 'Call Center Agent', 'Call Center Agent Development Tester', 'Call Center Agent Test', 'Call Center Agent Xfer', 'Call Center Agent Xfer Test', 'Call Center Reporting Agent', 'Fielded Leads Agents', 'Call Center Agent Infocision'};
		Set<String> cc_lead        = new Set<String>{'Call Center Agent Lead', 'Practice Privileges Admin', 'Refund Team'};
		Set<String> cc_sup         = new Set<String>{'Call Center - Supervisor', 'Call Center - Supervisor Test', 'Call Center - Supervisor Infocision'};
		Set<String> confirmation   = new Set<String>{'Outbound Call Center Agent Outsource', 'Outbound Call Center Jumpstart', 'Outbound Call Center Agent', 'Outbound Call Center Agent Test', 'CC Administrator', 'CC Administrator Development Tester', 'Call Center Agent Lead'};
		Set<String> seminar        = new Set<String>{'Marketing Administrator', 'Marketing Administrator Test', 'Marketing Administrator w/o Delete'};
		Set<String> prescreen      = new Set<String>{'PEC - NoPScreen - No Dash', 'FOA - TPLAN', 'FOA - No Prescreen - TPlan', 'FOA - No Prescreen - TPlan', 'PEC - No Prescreen - PPF', 'PEC - PPF - NoPScreen - TPlan', 'PEC - Extended Finance no prescreen', 'FOA - No Prescreen', 'PEC - No Prescreen', 'PEC - Multiple Centers No Prescreen', 'PEC - Snap No Prescreen', 'PEC - PPF - No Prescreen', 'PEC - Red Rally No Prescreen'};

		String profile = [SELECT Name FROM Profile WHERE ID = :Userinfo.getProfileId()].Name;

		display_schedule_admin = false;
		display_admin          = false;
		display_cc             = false;
		display_cc_lead        = false;
		display_cc_sup         = false;
		display_confirmation   = false;
		display_practice       = false;
		display_seminar        = false;
		display_prescreen      = false;

		if (schedule_admin.contains(profile)) {display_schedule_admin = true;}
		if (admin.contains(profile))          {display_admin          = true;}
		if (cc.contains(profile))             {display_cc             = true;}
		if (cc_lead.contains(profile))        {display_cc_lead        = true;}
		if (cc_sup.contains(profile))         {display_cc_sup         = true;}
		if (confirmation.contains(profile))   {display_confirmation   = true;}
		if (practice.contains(profile))       {display_practice       = true;}
		if (seminar.contains(profile))        {display_seminar        = true;}
		if (!prescreen.contains(profile))     {display_prescreen      = true;}
	}

  public List<Selectoption> getcancel_reason_list() {
  	List<Selectoption> creasons = new List<Selectoption>();
  	creasons.add(new Selectoption('','Select One'));
  	//Schema.DescribeFieldResult dfield = Apt_History__c.action_reason__c.getDescribe();
	//List<Schema.PicklistEntry> Pickvals = Apt_History__c.action_reason__c.getDescribe().getPicklistValues();
	for(Schema.PicklistEntry Value : Apt_History__c.cancel_reason__c.getDescribe().getPicklistValues() ) {
		creasons.add(new Selectoption(value.getValue(),value.getLabel()));
	}
	return creasons;
  }

  public boolean getnetwork_center_user() {
  	//test to see if this user is a network center admin (clinic calendar is set for a center that is type = Network Center)
  	if(network_center_user==null) {
	  	User u = [select id,clinic_calendar__c from User where id =:userinfo.getUserId()];
	  	if(u.clinic_calendar__c==null)
	  	  network_center_user = false;
	  	else {
	  	  Center_Information__c ci = [select id,name,type__c from Center_Information__c where name = :u.Clinic_Calendar__c];
	  	  if(ci.type__c=='Network Center')
	  	    network_center_user = true;
	  	  else
	  	    network_center_user = false;
	  	}
  	}
  	return network_center_user;
  }

  public List<Selectoption> getreschedule_reason_list() {
  	List<Selectoption> rreasons = new List<Selectoption>();
  	rreasons.add(new Selectoption('','Select One'));
  	//Schema.DescribeFieldResult dfield = Apt_History__c.action_reason__c.getDescribe();
		//List<Schema.PicklistEntry> Pickvals = Apt_History__c.action_reason__c.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry Value : Apt_History__c.action_reason__c.getDescribe().getPicklistValues() ) {
			rreasons.add(new Selectoption(value.getValue(),value.getLabel()));
		}
		return rreasons;
  }

  public List<Selectoption> getdelete_reason_list() {
  	List<Selectoption> dreasons = new List<Selectoption>();
  	dreasons.add(new Selectoption('','Select One'));
  	//Schema.DescribeFieldResult dfield = Apt_History__c.action_reason__c.getDescribe();
		//List<Schema.PicklistEntry> Pickvals = Apt_History__c.action_reason__c.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry Value : Apt_History__c.delete_reason__c.getDescribe().getPicklistValues() ) {
			dreasons.add(new Selectoption(value.getValue(),value.getLabel()));
		}
		return dreasons;
  }

  public void clear_schedule_leadaccount() {
  	scheduling_lead = null;
  	scheduling_account = null;
  	scheduling_patient = null;
  }

  public String getselected_center_name() {
  	if(selected_center_name==null)
      selected_center_name = [select name,calendar_name__c from Center_information__c where id = :selected_center].name;
    return selected_center_name;
  }

  public String getselected_center_calendar_name() {
  	return [select name,calendar_name__c from Center_information__c where id = :selected_center].calendar_name__c;
  }

  public Boolean getallow_sd_sched() {
  	Center_Information__c ci = [select allow_sd_schedule__c,name,id from Center_Information__c where id = :selected_center];
  	//override - SD schedule is allowed if the user is set to this calendar (network center workaround)
  	User u = [select id,clinic_calendar__c from User where id =:userinfo.getUserId()];
  	if(u.Clinic_Calendar__c!=null) {
  	  if(ci.name==u.clinic_calendar__c)
  	    return true;
  	  else
  	    return ci.allow_SD_Schedule__c;
  	}
  	return ci.allow_sd_schedule__c;
  }

  public String getclinic_link() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/clinic_calendar?cdate=' + selected_date.format() + '&cid=' + selected_center;
  	return hyper_link;
  }

  public class TestException extends Exception{}

  public void update_initiative() {
  	Consult_Inventory__c old_apt = getapt_block(view_apt.id);
  	try {
	  	old_apt.Special_Initiative__c = view_apt.Special_Initiative__c;
	  	update old_apt;
  	}
  	catch (System.Dmlexception e) {
  	  for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
    }
  }

  public String getPIQ_Score(ID account_id) {
  	String piq_all_score;
  	for(lead l : [select prospect_all_score__c from Lead where convertedaccountid = :account_id order by createddate]) {
  	  if(l.prospect_all_score__c!=null)
  	    piq_all_score = l.prospect_all_score__c;
  	}
  	return piq_all_score;
  }

  public String getstar_URL() {
  	//figure out which set of stars we need to display here
  	String doc_name = 'Stars Unknown';
  	if(view_apt!=null) {
  	  try {
  	  String pre_screen;
  	  String PIQ_string;
  	  if(view_apt.scheduled_lead__c!=null) {
  	    pre_screen = view_apt.scheduled_lead__r.pre_screen__c;
  	    PIQ_string = view_apt.scheduled_lead__r.prospect_all_score__c;
  	  }
  	  if(view_apt.scheduled_account__c!=null) {
  	    pre_screen = view_apt.scheduled_account__r.pre_screen__c;
  	    PIQ_string = getPIQ_score(view_apt.scheduled_account__c);
  	  }
  	  System.debug('Star Check ' + pre_screen + ' ' + PIQ_STRING);
  	  if (PIQ_string != null) {
  	  	Decimal piq = Decimal.valueOf(PIQ_String);

		Set<String> two_stars   = new Set<String>{'Red', 'Blue (No Hit)', 'Insufficient Information', 'PO Box'};
		Set<String> three_stars = new Set<String>{null, 'Not Checked'};
		Set<String> four_stars  = new Set<String>{'Green', 'Yellow'};

		if (piq == 0) {
			if      (two_stars.contains(pre_screen))   {doc_name = 'Star2';}
			else if (three_stars.contains(pre_screen)) {doc_name = 'Star3';}
			else if (four_stars.contains(pre_screen))  {doc_name = 'Star4';}
		} else if (pre_screen == null) {
  	  	  if      (piq >= -1.1) {doc_name = 'Star5';}
          else if (piq >= -2.3) {doc_name = 'Star4';}
          else if (piq >= -3.5) {doc_name = 'Star3';}
          else if (piq >= -4.4) {doc_name = 'Star2';}
  	    } else if (pre_screen=='Green') {
  	      if      (piq >= -2.2) {doc_name = 'Star5';}
  	      else if (piq >= -4.3) {doc_name = 'Star4';}
  	    } else if (pre_screen=='Yellow') {
  	  	  if      (piq >= -0.9) {doc_name = 'Star5';}
  	  	  else if (piq >= -3.8) {doc_name = 'Star4';}
  	  	  else if (piq >= -4.4) {doc_name = 'Star3';}
  	  	  else if (piq >= -4.9) {doc_name = 'Star2';}
  	    } else if (pre_screen=='Red') {
  	      if      (piq >= -0.4) {doc_name = 'Star5';}
  	      else if (piq >= -1.3) {doc_name = 'Star4';}
  	      else if (piq >= -2.3) {doc_name = 'Star3';}
          else if (piq >= -3.8) {doc_name = 'Star2';}
          else if (piq >= -4.6) {doc_name = 'Star1';}
  	    } else if (pre_screen=='Blue (No Hit)') {
  	      if      (piq >= -0.1) {doc_name = 'Star5';}
  	      else if (piq >= -1.6) {doc_name = 'Star4';}
  	      else if (piq >= -2.6) {doc_name = 'Star3';}
  	      else if (piq >= -3.3) {doc_name = 'Star2';}
  	      else if (piq >= -4.9) {doc_name = 'Star1';}
  	    } else if (pre_screen=='Insufficient Information') {
  	      if      (piq >= -1.1) {doc_name = 'Star5';}
  	      else if (piq >= -2.1) {doc_name = 'Star4';}
  	      else if (piq >= -2.5) {doc_name = 'Star3';}
  	      else if (piq >= -3.0) {doc_name = 'Star2';}
  	      else if (piq >= -4.0) {doc_name = 'Star1';}
  	    } else if (pre_screen=='Not Checked') {
  	      if      (piq >= -1.3) {doc_name = 'Star5';}
  	      else if (piq >= -2.6) {doc_name = 'Star4';}
  	      else if (piq >= -3.5) {doc_name = 'Star3';}
  	      else if (piq >= -4.1) {doc_name = 'Star2';}
  	      else if (piq >= -4.8) {doc_name = 'Star1';}
   	    } else if (pre_screen=='PO Box') {
  	      if      (piq >= -0.6) {doc_name = 'Star5';}
  	      else if (piq >= -1.9) {doc_name = 'Star4';}
  	      else if (piq >= -2.9) {doc_name = 'Star3';}
  	      else if (piq >= -4.0) {doc_name = 'Star2';}
  	      else if (piq >= -4.6) {doc_name = 'Star1';}
  	    }

		if (doc_name == 'Stars Unknown') {
			if      (piq >= -5.4 && pre_screen == 'Green')                          {doc_name = 'Star3';}
			else if (piq >= -5.4 && (pre_screen == null || pre_screen == 'Yellow')) {doc_name = 'Star1';}
			else if (piq >= -5.4)                                                   {doc_name = 'Star0';}
		}
  	  }
  	  }catch (Exception e) {
  	  	//will just use the unknown image
  	  	System.debug('Star Fail ' + e);
  	  }
  	}
  	Document d = [select id from Document where name = :doc_name limit 1];
    string star_Url = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/servlet/servlet.ImageServer?id=' + d.Id + '&oid=' + UserInfo.getOrganizationId();
    return star_Url;
  }

  public void modify_aptblock() {
  	//System.debug('Confirmed : ' + view_apt.Scheduled_lead__r.Confirmed_Appointment__c);
  	//System.debug('Left Message : ' + view_apt.Scheduled_lead__r.Left_Message_to_Confirm__c);
  	//System.debug('Treatment : ' + view_apt.treatment__c);
  	modal_out = '';
  	Consult_Inventory__c old_apt = getapt_block(view_apt.id);
  	if(old_apt.Scheduled_Lead__c!=view_apt.Scheduled_Lead__c || old_apt.Scheduled_Account__c!=view_apt.Scheduled_Account__c || old_apt.Scheduled_Patient__c != view_apt.Scheduled_Patient__c) {
      modal_out += '<span class="blank" style="color:red;">The appointment you are trying to adjust has been rescheduled or canceled - Save Aborted</span>';
    } else if (view_apt.Confirmation_Status__c == 'Confirmed' && (view_apt.Scheduled_Lead__c != null || view_apt.Scheduled_Account__c != null)) {
		String reminder_error = '<span class="blank" style="color:red;">Both "Automated Call?" and "Text Reminder?" questions are required. Please answer them before saving.</span>';
		if (view_apt.Scheduled_Lead__c != null) {
			if (view_apt.Scheduled_Lead__r.Reminder_Call__c == null    || view_apt.Scheduled_Lead__r.Reminder_Text__c == null)    {modal_out += reminder_error;}
		}
		else {
			if (view_apt.Scheduled_Account__r.Reminder_Call__c == null || view_apt.Scheduled_Account__r.Reminder_Text__c == null) {modal_out += reminder_error;}
		}
	}

	if (String.isBlank(modal_out)) {
	  	try {
	      set_consult_reminders_from_patient_reminders();
	      update view_apt;
	      //compare the fields and build the history notes
	      String history_notes = '';
	      if(view_apt.Start_Hour__c<> old_apt.Start_Hour__c || view_apt.Start_Minute__c <> old_apt.Start_Minute__c)
	        history_notes += 'Start Time changed from ' + old_apt.Start_Hour__c + ':' + old_apt.Start_Minute__c + ' to ' +  view_apt.Start_Hour__c + ':' + view_apt.start_minute__c  + '<br />';
	      if(view_apt.End_Hour__c<> old_apt.End_Hour__c || view_apt.End_Minute__c <> old_apt.End_Minute__c)
	        history_notes += 'End Time changed from ' + old_apt.End_Hour__c + ':' + old_apt.end_minute__c + ' to ' + view_apt.End_Hour__c + ':' + view_apt.End_Minute__c + '<br />';
	      if(view_apt.Pre_Screen_Type__c<>old_apt.Pre_Screen_Type__c)
	        history_notes += 'Pre Screen type changed from ' + old_apt.Pre_Screen_Type__c + ' to ' + view_apt.Pre_Screen_Type__c + '<br />';
	      if(view_apt.Color__c<>old_apt.color__c)
	        history_notes += 'Color changed from ' + old_apt.color__c + ' to ' + view_apt.color__c + '<br />';
	      if(view_apt.apt_notes__c<>old_apt.apt_notes__c)
	        history_notes += 'Notes changed from ' + old_apt.apt_notes__c + ' to ' + view_apt.apt_notes__c + '<br />';
	      if(view_apt.Treatment__c<>old_apt.treatment__c)
	        history_notes += 'Treatment changed from ' + old_apt.treatment__c + ' to ' + view_apt.treatment__c + '<br />';
	      if(view_apt.Consult_Show_Status__c<>old_apt.Consult_Show_Status__c)
	        history_notes += 'Show Status changed from ' + old_apt.consult_show_status__c + ' to ' + view_apt.consult_show_status__c + '<br />';
	      if(view_apt.confirmation_status__c<>old_apt.Confirmation_Status__c)
	        history_notes += 'Confirmation Status changed from ' + old_apt.confirmation_status__c + ' to ' + view_apt.confirmation_status__c + '<br />';
	      if(view_apt.send_reminder__c<>old_apt.send_reminder__c) {
			  history_notes += 'Text Reminder changed from ' + old_apt.send_reminder__c + ' to ' + view_apt.send_reminder__c + '<br />';
		      if(view_apt.scheduled_lead__c!= null) {
		        view_apt.scheduled_lead__r.receive_text_reminder__c =  view_apt.send_reminder__c;
		        update view_apt.scheduled_lead__r;
		      }
		      if(view_apt.scheduled_account__c!= null) {
		        view_apt.scheduled_account__r.receive_text_reminder__c =  view_apt.send_reminder__c;
		        update view_apt.scheduled_account__r;
		      }
	      }
	      if(view_apt.auto_reminder__c<>old_apt.auto_reminder__c) {
			history_notes += 'Auto Reminder changed from ' + old_apt.auto_reminder__c + ' to ' + view_apt.auto_reminder__c + '<br />';
			if(view_apt.scheduled_lead__c!= null) {
			  view_apt.scheduled_lead__r.receive_auto_reminder__c =  view_apt.auto_reminder__c;
			  update view_apt.scheduled_lead__r;
			}
			if(view_apt.scheduled_account__c!= null) {
			  view_apt.scheduled_account__r.receive_auto_reminder__c =  view_apt.auto_reminder__c;
			  update view_apt.scheduled_account__r;
			}
	      }
		  if(view_apt.gc_offered__c<>old_apt.gc_offered__c)
			history_notes += 'GC offered changed from ' + old_apt.gc_offered__c + ' to ' + view_apt.gc_offered__c + '<br />';
 	      if(view_apt.special_initiative__c <> old_apt.special_initiative__c)
	        history_notes += 'Special Initiative changed from ' + old_apt.special_initiative__c + ' to ' +  view_apt.special_initiative__c  + '<br />';
 	      if(view_apt.will_patient_show__c <> old_apt.will_patient_show__c)
	        history_notes += 'Will Patient Show changed from ' + old_apt.will_patient_show__c + ' to ' +  view_apt.will_patient_show__c  + '<br />';
	      if(view_apt.will_patient_start__c <> old_apt.will_patient_start__c)
	        history_notes += 'Will Patient Start changed from ' + old_apt.will_patient_start__c + ' to ' +  view_apt.will_patient_start__c  + '<br />';
	      if(history_notes.length()>255)
	        history_notes = history_notes.substring(0,253);
	      //make sure there actually was a change....if not,  don't record an entry
	      if(history_notes.length()>0) {
	        Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.Scheduled_Patient__c, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Modify', notes__c = history_notes);
	        insert history;
	      }

		  // ADD TOTALLY NEW CHECK FOR CONFIRMATION TEAM NOTES ACTION




	  		//slick - did not realize this would work.
	  		//changed this since a confirmation field was added to the block level
	  		//if(view_apt.scheduled_lead__c!=null)
	  		  //update view_apt.scheduled_lead__r;
	  		if(view_apt.scheduled_lead__c!=null) {
		  		if(view_apt.confirmation_status__c=='Confirmed') {
		  		  view_apt.scheduled_lead__r.confirmed_appointment__c = true;
		  		  view_apt.Scheduled_Lead__r.left_message_to_confirm__c = false;
		  		}
		  		else if(view_apt.confirmation_status__c=='LVM') {
		  		  view_apt.scheduled_lead__r.confirmed_appointment__c = false;
		  		  view_apt.Scheduled_Lead__r.left_message_to_confirm__c = true;
		  		}
		  		else {
		  			view_apt.scheduled_lead__r.confirmed_appointment__c = false;
		  		  view_apt.Scheduled_Lead__r.left_message_to_confirm__c = false;
		  		}
		  		update view_apt.scheduled_lead__r;
	  		}
	  		view_apt = getapt_block(view_apt.id);
	  		modal_display = false;
	  	}
	  	catch (System.DmlException e) {
	  	  for (Integer i = 0; i < e.getNumDml(); i++) {
	        modal_out += e.getDmlMessage(i) + '<br />';
	      }
	    }
	}
  }

  public void delete_aptblock() {
  	//make sure this block is NOT scheduled prior to removing it
  	System.debug('Delete Reason : ' + delete_reason);
  	if(delete_reason==null)
  	  modal_out = '<span class="blank" style="color:red;">You must select a reason for the deletion in order to continue</span>';
  	else if(delete_reason=='')
  		modal_out = '<span class="blank" style="color:red;">You must select a reason for the deletion in order to continue</span>';
  	else {
	  	modal_out = '';
	  	Consult_Inventory__c apt_check = [select c.scheduled_patient__c, c.scheduled_account__c,c.scheduled_lead__c,c.consult_room__r.center_information__c from Consult_Inventory__c c where c.id = :view_apt.id];
	  	if(apt_check.Scheduled_lead__c==null && apt_check.scheduled_account__c==null && apt_check.scheduled_patient__c==null ) {
	  		if(check_for_other_hold()==0) {
		  		//delete the block
		  		try {
		  			view_apt.active__c = false;
		  			update view_apt;
		  			Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, action__c = 'Deleted', Notes__c = 'Appointment block was deleted.' + delete_note, delete_reason__c = delete_reason);
		  			insert history;
		  			modal_display = false;
		  			view_apt = null;
		  		}
		  		catch (Exception e) {
		  			modal_out += e.getMessage() + '<br />';
		  		}
	  		}
		    else
		      modal_out += '<span class="blank" style="color:red;">' + hold_message + '</span>';
	  	}
	  	else
	  	  modal_out += '<span class="blank" style="color:red;">There is a consult shceduled in this block. Appointment can not be deleted</span>';
  	}
  }

  public void display_apt_details() {
  	//view_apt = [Select c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c From Consult_Inventory__c c where c.id =: Apexpages.currentPage().getParameters().get('anum')];
  	view_apt = getapt_block(Apexpages.currentPage().getParameters().get('anum'));
  	System.debug('View : ' + view_apt);
  	modal_out = '';
  	modal_display = true;
  	modal_type = 'apt_view';
    parse_notes(); //Alon
    hold_message = '';
  }

  public void history_view() {
  	modal_type = 'history_view';
  }

  public void apt_view() {
  	modal_type = 'apt_view';
  }

  public List<Apt_History__c> getapt_history() {
  	if(view_apt==null) {
      if(apexpages.currentpage().getparameters().get('anum')!=null)
  	    view_apt = getapt_block(Apexpages.currentPage().getParameters().get('anum'));
  	}
  	System.debug('View Apt : ' + view_apt);
  	if(view_apt==null)
  	  return null;
  	else {
  	  List<Apt_History__c> all_history = [Select a.Notes__c, a.Name, a.Lead__c, a.lead__r.name, a.CreatedDate, a.CreatedById, a.createdby.name, a.Consult_Inventory__c, a.Action__c, a.Account__c, a.account__r.name, a.private_practice_patient__c, a.private_practice_patient__r.full_name__c From Apt_History__c a where a.consult_inventory__c = :view_apt.id order by createddate];
  	  return all_history;
  	}
  }

  public String getformatted_status_text() {
  	Integer cd_count = [select count() from Center_Open_Day__c where center_information__c = :selected_center and calendar_date__c = :selected_date];
  	String return_html = '<span style="color:purple;">Unknown</span>';
  	if(cd_count>0) {
  	  Center_Open_Day__c cd = [select open_status__c from Center_Open_Day__c where center_information__c = :selected_center and calendar_date__c = :selected_date];
      if(cd!=null) {
        if(cd.open_status__c=='Open')
          return_html =  '<span style="color:#5789AE;">Open</span>';
        else if(cd.open_status__c=='Closed')
          return_html = '<span style="color:red;">Closed</span>';
        else if(cd.open_status__c=='Holiday')
          return_html = '<span style="color:green;">Holiday</span>';
      }
  	}
    return return_html;
  }

  public void build_room_inventory(Consult_Rooms__c target_room, Date starting_date) {
  	//this function should build out an inventory for the targeted room for the next X days
  	//grab a list of the template apt blocks for the schedule template assigned to the room
  	Schedule_Templates__c room_template = [Select s.Wednesday__c, s.Tuesday__c, s.Thursday__c, s.SystemModstamp, s.Sunday__c, s.Saturday__c, s.OwnerId, s.Name, s.Monday__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Friday__c, s.CreatedDate, s.CreatedById From Schedule_Templates__c s where id = :target_room.Schedule_Template__c];
  	list<Template_Apt__c> apt_blocks = [Select t.SystemModstamp, t.Starting_Minutes__c, t.Starting_Hour_Int__c, t.Start_Min_Int__c, t.Start_Hour__c, t.Schedule_Template__c, t.Pre_Screen_Type__c, t.Name, t.LastModifiedDate, t.LastModifiedById, t.IsDeleted, t.Id, t.Ending_Minutes__c, t.Ending_Hour__c, t.CreatedDate, t.CreatedById, t.Color_Code__c, t.Active__c, t.special_initiative__c From Template_Apt__c t where t.schedule_template__c = :target_room.Schedule_Template__c and active__c = true];
  	list<Consult_Inventory__c> add_blocks = new list<Consult_Inventory__c>();
  	Integer num_days = math.round(target_room.Days_Built_Out__c);
  	//build a map of the days in the future so we can verify there are no appointments on them!
  	Map<Date,Integer> apt_count_map = new Map<Date,Integer>();
  	Date end_date =  starting_date.adddays(num_days);
  	//need to build a map to store open days for the center
  	Map<String,String> center_open_days = new Map<String,String>{};

  	//Do not add an active__c = true filter here.  If you do,  the process will recreate the schedule on a day where they delete
  	//the appointments off the schedule.
  	if(target_room.room_type__c=='Manual')
	  	for(AggregateResult ar : [select apt_date__c,count(id) num_apts from Consult_Inventory__c where Consult_Room__c =: target_room.Id and apt_date__c >= :starting_date and apt_date__c <= :end_date and active__c = true group by apt_date__c]) {
	  		Date my_id_date = (date)ar.get('apt_date__c');
	      apt_count_map.put(my_id_date,Integer.valueOf(ar.get('num_apts')));
	  	}
	  else
	    for(AggregateResult ar : [select apt_date__c,count(id) num_apts from Consult_Inventory__c where Consult_Room__c =: target_room.Id and apt_date__c >= :starting_date and apt_date__c <= :end_date group by apt_date__c]) {
	  		Date my_id_date = (date)ar.get('apt_date__c');
	      apt_count_map.put(my_id_date,Integer.valueOf(ar.get('num_apts')));
	  	}
	//pull a list of center open days and work through it
    for(Center_Open_Day__c cd : [Select c.Open_Status__c, c.Center_Information__c, c.Calendar_Date__c From Center_Open_Day__c c where calendar_date__c >= :starting_date and calendar_date__c <= :end_date and center_information__c = :selected_center]) {
      String mapping_id = String.valueof(cd.calendar_date__c);
      center_open_days.put(mapping_id,cd.open_status__c);
    }

  	//work through the days
  	System.debug('Num Days : ' + num_days + ' Build Out : ' + target_room.Days_Built_Out__c);
  	Date work_day = starting_date;
  	for(Integer i = 0;i< num_days; i++) {
  		Boolean build_today = false;
  		Integer dow;
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Monday' && (room_template.Monday__c || target_room.room_type__c=='Manual')) {
  			dow = 1;
  		  build_today = true;
  		}
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Tuesday' && (room_template.Tuesday__c || target_room.room_type__c=='Manual')) {
  			dow = 2;
  		  build_today = true;
  		}
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Wednesday' && (room_template.Wednesday__c || target_room.room_type__c=='Manual')) {
  			dow = 3;
  		  build_today = true;
  		}
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Thursday' && (room_template.Thursday__c || target_room.room_type__c=='Manual')) {
  			dow = 4;
  		  build_today = true;
  		}
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Friday' && (room_template.Friday__c || target_room.room_type__c=='Manual')) {
  			dow = 5;
  		  build_today = true;
  		}
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Saturday' && (room_template.Saturday__c || target_room.room_type__c=='Manual')) {
  			dow = 6;
  		  build_today = true;
  		}
  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Sunday' && (room_template.Sunday__c || target_room.room_type__c=='Manual')) {
  			dow = 7;
  		  build_today = true;
  		}
  		//make sure we don't have any existing blocks on this day.  If so ignore it for now this might get more complicated later
  		if(apt_count_map.get(work_day)!=null)
  		  if(apt_count_map.get(work_day)>0)
  		    build_today = false;
  		 //check to see if we have an open day record
	  	  String mapping_id =  String.valueof(work_day);
	  	  if(center_open_days.get(mapping_id)!=null) {
	  	  	if(center_open_days.get(mapping_id)!='Open') {
	  	  	  build_today = false;
	  	  	  System.debug('Date : ' + starting_date.adddays(i) + ' is closed');
	  	  	}
	  	  }
      //work through the apt blocks
      if(build_today) {
        for(Template_Apt__c block : apt_blocks) {
      	  Consult_Inventory__c ci = new Consult_Inventory__c(Consult_Room__c = target_room.Id, Apt_Date__c = work_day,special_initiative__c = block.special_initiative__c,Start_Hour__c = block.Start_Hour__c,Start_Minute__c = block.Starting_Minutes__c,End_Hour__c = block.Ending_Hour__c, End_Minute__c = block.Ending_Minutes__c, Pre_screen_type__c = block.Pre_Screen_Type__c, active__c = true, template_apt__c = block.Id, color__c = block.Color_Code__c, dow_int__c = dow);
      	  add_blocks.add(ci);
        }
      }
      System.debug('Day : ' + work_day + ' Building : ' + build_today + ' Number of Apts : ' + apt_count_map.get(work_day));
  		work_day = work_day.addDays(1);
  		System.debug('Day (after add) : ' + work_day);
  	}
  	System.debug('Map : ' + apt_count_map);
  	//add the inventory
  	if(add_blocks.size()>0) {
  	  insert add_blocks;
  	  List<Apt_History__c> history_list = new List<Apt_History__c>{};
  	  for(Consult_Inventory__c block : add_blocks) {
  	    Apt_History__c history = new Apt_History__c(Consult_Inventory__c = block.id, action__c = 'Created', notes__c = 'Appointment block was created');
  	    history_list.add(history);
  	  }
  	  insert history_list;
  	}
  }


  public void close_modal() {
  	modal_display = false;
  	modal_out = '';
  	hold_message = '';
  }

	public String cancel_double_consult_partner {get; set;}
	public void cancel_consult() {
		System.debug('Cancel Reason' + cancel_reason);

		// Check if all questions are answered before trying to cancel
		String[] error_messages = new String[]{};
		if (String.isBlank(cancel_reason)) {error_messages.add('<li>You must select a reason for the cancellation in order to continue.</li>');}
		if (double_consult_not_answered()) {error_messages.add('<li>You must decide whether or not to cancel the double consult appointment.</li>');}
		modal_out = '<span class="blank" style="color:red;"><ul style="padding-left: 10px;">' + String.join(error_messages, '') + '</ul></span>';
		// If all questions are answered
		if (error_messages.isEmpty()) {
			// If there's a Double Consult paired with the current view_apt and the user has elected to also cancel that appointment, cancel both
			// Otherwise just cancel the one
			if (getis_double_consult() && cancel_double_consult_partner == 'Yes') {
				ID double_consult_ID = view_apt.Double_Consult__c;
				cancel_single_consult(view_apt, 'double-primary');
				cancel_single_consult(getapt_block(double_consult_ID), 'double-secondary');
			} else {
				cancel_single_consult(view_apt, 'single');
			}
		}
	}

			private Boolean double_consult_not_answered() {
				return getis_double_consult() && String.isBlank(cancel_double_consult_partner);
			}

  private void cancel_single_consult(Consult_Inventory__c appointment, String type) {
  	/**
  	---2/28/2013 by CM
  	WARNING - Please update Chad on all changes made to the scheduling system code.  We want to keep the online system in synch with everything else
  	**/
  	Boolean lead_update = false;
  	Lead l;
  	Integer next_seven = 0;
	    next_seven = next_seven_count(appointment.leadscore_at_schedule_time__c);
	String cancel_notes = cancel_notes(type);
  	Apt_History__c history = new Apt_History__c(Consult_Inventory__c = appointment.id, Private_Practice_Patient__c = appointment.scheduled_patient__c, Lead__c = appointment.scheduled_lead__c, Account__c = appointment.Scheduled_Account__c, action__c = 'Cancel', notes__c = cancel_notes, Cancel_Reason__c = cancel_reason, apts_in_next_seven__c = next_seven, Double_Consult__c = appointment.Double_Consult__c);
  	if(appointment.Scheduled_Lead__c!=null) {
  	  lead_update = true;
  	  l = [select Referral_Doctor_Name__c,center__r.Practice_Privileges_Email__c,referral_location__c,id, left_message_to_confirm__c, call_result__c, status, objection__c, datetime_consult_scheduled__c, date_consult_scheduled_by_rep__c, confirmed_appointment__c, could_not_reach__c,refused_to_give_email__c,fees_quoted__c,phone,inbound_call__c,Hot_List__c,Cancellation_List_Notes__c,name from lead where id = :appointment.Scheduled_Lead__c];
  	  //check if this was a referral from Vantage.  If so,  we need to send a call to update the consult status
  	  if(l.referral_location__c != null) {
  	  	//myWS.updatereferral_consultstatus(l.id,appointment.apt_date__c,'Cancelled',cancel_reason);
  	  	//this also indicates we have a gold lead,  so send an email to the team notifying them
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	    //String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','nambos@clearchoice.com','dmckelvey@clearchoice.com',l.center__r.Practice_Privileges_Email__c};
	    mail.setToAddresses(toAddresses);
		mail.setReplyTo('practicedevelopment@clearchoice.com');
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
        if ( owea.size() > 0 ) {
          mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
		//mail.setSenderDisplayName('Practice Privileges');
		mail.setSubject('Gold Lead - Consult Cancelled');
		mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
	      '<title>New Referral Lead</title><style type="text/css">' +
		  '@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		  '@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		  '@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		  '@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	} ' +
				'.column { width:200px;     float:left;		 padding-left:10px;		}	h2 {	font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;	color:#075094;	font-size:18px;		line-height:7px;	text-align:left;		}	</style>' +
		        '</head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table--><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">' +
				'<tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
				'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
				'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" width="175" style="width: 175px; height: auto;"  alt="" border="0"></a>' +
				'</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;"><tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' +
				'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--> </td></tr><tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;">' +
				'</td>' +
				'</tr>						<tr valign="top">									<td>					<!-- Wrapper 2 (Banner 1) -->		<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">									<tr>' +
				'<td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' +
				'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text -->' +
		        '<table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' +
		        '</td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --> </td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">' +
		        '<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:22pt; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">Gold Lead Cancellation</div>' +
				'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">' +
		        '<p style="padding-left:20px; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;">' +
				'A previously scheduled referral Gold Lead ' + l.name + ', from Dr. ' + l.Referral_Doctor_Name__c + ' has cancelled via the call center or postponed temporarily without scheduling a new time. If you feel reaching out to this person would be of value to everyone based on your prior discussions, please contact them directly.<br /><br />' +
				'<span style="font-weight:bold;display:inline-block;width:200px;">Cancellation Reason :</span> <span style="color:red;font-style:italic;">' + cancel_reason + '</span><br /><br />' +
				'You can review the prospective patient page <a style="color:#075094;font-weight:bold;" href="na2.salesforce.com/' + l.id + '">here</a><br /><br />' +
				'Thank you!<br />The PracticePrivileges Team</p>' +
				'</td></tr></tbody></table></td></tr>	<tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody>' +
				'<tr valign="top"><td width="375" style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />' +
				'888-808-7033</td><td width="325" style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /> <span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Privileges" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright ClearChoice. All rights reserved.</span></td>' +
				'</tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>');
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  }
  	}
  	//per Andy 8/22/2012,  we'll be trying to add all leads that were cancelled to a cancellation campaign automatically
    if(!test.isRunningTest()) {
	  	Campaign c = [select id from campaign where type = 'No Show-Cancellation Outbound' and status = 'In Progress' and startdate <= today and (not name like 'N%') order by startdate desc limit 1];
	  	if(c.id!=null) {
	  		try {
	  			if(appointment.Scheduled_Lead__c!=null) {
		 				//make sure this lead is not already in the cancellation campaign.
		 				Integer ccount = [select count() from campaignmember where campaignid = :c.id and leadid = :l.id];
		 				if(ccount==0) {
		 			    CampaignMember cm = new CampaignMember(campaignId = c.id, leadid = l.id);
		          insert cm;
		 				}
			      Task t = new Task(WhoId = appointment.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Cancelled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Consult Cancelled', Call_No_Answer__c = false, Status = 'Completed');
			      insert t;
	  			}
	  			else if (appointment.scheduled_account__c!=null) {
	  				Account a = [select id,personcontactid from account where id = :appointment.scheduled_account__c];
	  				Integer ccount = [select count() from campaignmember where campaignid = :c.id and contactid = :a.personcontactid];
		 				if(ccount==0) {
		 			    CampaignMember cm = new CampaignMember(campaignId = c.id, contactid = a.personcontactid);
		          insert cm;
		 				}
	  			}
	  		}
	  		catch (Exception e) {

	  		}
	  	}
  	}
	appointment.will_patient_show__c          = null;
  	appointment.will_patient_start__c         = null;
  	appointment.Scheduled_Lead__c             = null;
  	appointment.Scheduled_Account__c          = null;
  	appointment.scheduled_patient__c          = null;
  	appointment.treatment__c                  = null;
  	appointment.Apt_Notes__c                  = null;
  	appointment.Callback_Consult__c           = false;
  	appointment.Callback_Consult_PEC__c       = null;
  	appointment.confirmation_status__c        = 'Not Confirmed';
  	appointment.send_reminder__c              = false;
  	appointment.auto_reminder__c              = false;
  	appointment.gc_offered__c                 = false;
  	appointment.leadscore_at_schedule_time__c = null;
  	appointment.external_agent__c             = null;
    appointment.Double_Consult__c             = null;
	appointment.Scheduled_by__c               = null;

  	//need to update the lead record when this happens
  	try {
  		update appointment;
  		insert history;
  		//no updates on account
  		if(lead_update) {
	  		l.status = 'Not Scheduled';
	  		//placeholder
	  		l.OBJECTION__c = 'Other';
	  		l.DateTime_Consult_Scheduled__c = null;
	  		l.Confirmed_Appointment__c = false;
	  		l.Could_not_Reach__c = false;
	  		l.Left_Message_to_Confirm__c = false;
	  		Date today_date = system.today();
	  		if(today_date.daysBetween(appointment.apt_date__c)==0)
	  			l.Call_Result__c = 'Same Day Cancellation Appointment';
	  		else
	  			l.Call_Result__c = 'Cancelled Appointment';
	  	  update l;
  		}

  		//appointment = [Select c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name, c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c From Consult_Inventory__c c where c.id =:appointment.id];
  		if (type != 'double-secondary') {view_apt = getapt_block(appointment.id);}
  		modal_display = false;
  		modal_out = '';
  	}
  	catch (System.DmlException e) {for (Integer i = 0; i < e.getNumDml(); i++) {modal_out += e.getDmlMessage(i) + '<br />';}}
  }

			private String cancel_notes(String type) {
				if      (type == 'double-primary')   {return 'Consultation was cancelled (double consult, cancellation initiated on this record). ' + cancel_reason;}
				else if (type == 'double-secondary') {return 'Consultation was cancelled (double consult, this is the secondary record, so cancellation was initiated from the partner appointment).' + cancel_reason;}
				else                                 {return 'Consultation was cancelled. ' + cancel_reason;}
			}

  public void clone_block() {
    Consult_Inventory__c clone_apt = new Consult_Inventory__c(Active__c = true, apt_date__c = view_apt.apt_date__c, color__c = view_apt.color__c,
      consult_room__c = view_apt.consult_room__c, start_hour__c = view_apt.start_hour__c, start_minute__c = view_apt.start_minute__c, end_hour__c = view_apt.end_hour__c,
      end_minute__c = view_apt.end_minute__c, pre_screen_type__c = 'Green/Yellow Only', dow_int__c = view_apt.dow_int__c);
    System.debug('Cloned Apt : ' + clone_apt);
    try {
      insert clone_apt;
      view_apt.pre_screen_type__c = 'Red/Blue Only';
      update view_apt;
      view_apt = getapt_block(view_apt.id);
      modal_display = false;
      modal_out = '';
      //create history entries
      List<Apt_History__c> history_entries = new List<Apt_History__c>();
      Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Green Slot Added', notes__c = 'A green slot was added in this time slot');
      history_entries.add(history);
      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Modify', notes__c = 'Pre Screen Type change to Red/Blue Only');
      history_entries.add(history);
      history = new Apt_History__c(Consult_Inventory__c = clone_apt.id, action__c = 'Created', notes__c = 'Appointment block was created - via clone');
      history_entries.add(history);
      insert history_entries;
    }
    catch(Exception e) {
    	for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
    }
  }

  public void delete_consult_view() {
  	modal_type = 'delete_view';
  	delete_reason = '';
  	delete_note = '';
  }

  public void reschedule_consult_view() {
  	modal_type = 'reschedule_view';
  	reschedule_reason = '';
	if (view_apt.Double_Consult__c != null) {modal_out = '<span class="blank" style="display: block; padding: 10px; color:red;">Warning: This is a \'double consult\'. If it\'s rescheduled to exactly the same day and time, the double consult values will remain. Otherwise, they will be removed.</span>';}
  }

  public void callback_consult_view() {
  	modal_type = 'callback_consult_view';
  	cancel_reason = '';
  }

  public List<Selectoption> getpec_list() {
  	//modified by cm on 2017/8/8 - cleaned up things to reduce the number of queries used
    List<Selectoption> pec = new List<Selectoption>();
    pec.add(new Selectoption('','Select PEC'));
    System.Debug('Selected Center : ' + selected_center);
    Map<Id,Center_Information__c> all_centers_map = new Map<ID,Center_Information__c> ([select id,name,region__c,market__c from center_information__c]);

    Center_Information__c ci = all_centers_map.get(selected_center);
    System.debug('Market : ' + ci.market__c);
    Set<String> center_market_list = new Set<String>();
    Set<String> center_market_names = new Set<String>();
    Set<String> center_region_list = new Set<String>();
    Set<String> center_region_names = new Set<String>();
    Center_Information__c unknown;

    for(Center_Information__c ci_all : all_centers_map.values()) {
      if(ci_all.name=='Unknown')
        unknown = ci_all;
    	//for(Center_Information__c ci_all : [select id,name from center_information__c where market__c = :ci.market__c]) {
      //check for a market match
      if(ci_all.market__c == ci.market__c) {
        center_market_list.add(ci_all.id);
        center_market_names.add(ci_all.name);
      }
      //check for a region match
      if(ci_all.region__c == ci.region__c) {
      	center_region_list.add(ci_all.id);
      	center_region_names.add(ci_all.name);
      }
    }
    List<User> all_active_users = [select id,name,center_pec__c,profile.name,regional_traveler__c,center_administrator__c,clinic_calendar__c from User where isactive = true order by name];
    for(User u : all_active_users) {
      //check for pec assigned to the selected center (by market)
      if(center_market_list.contains(u.center_pec__c)) {
        pec.add(new Selectoption(u.id,u.name));
      }
      //check if it's a traveler
      else if(u.center_pec__c == unknown.id) {
      	pec.add(new Selectoption(u.id,u.name));
      }
      //check is it's a regional traveler
      else if(u.regional_traveler__c && center_region_list.contains(u.center_pec__c)) {
        pec.add(new Selectoption(u.id,u.name));
      }
      //check if it's a dec
      else if((u.profile.name == 'DEC_VisiblePrescreen' || u.profile.name == 'Doctor Education Consultant') && center_market_names.contains(u.clinic_calendar__c)) {
        pec.add(new Selectoption(u.id,u.name));
      }
      else if(ci.name=='San Antonio' && u.name=='Linda Law') {
      	pec.add(new Selectoption(u.id,u.name));
      }
    }

    //pull the list of pecs assigned to the selected center (by market)
    //pulled the center_administrator__c = false filter so CA's would be on the list
    /*for(User u : [select id,name from user where center_pec__c in :center_market_list and isactive = true]) {
      pec.add(new Selectoption(u.id,u.name));
    }
    //pull the list of traveler pecs - including regional options
    for(User u : [select id,name from user where (center_pec__c = :unknown.id or (center_pec__c in :center_region_list and regional_traveler__c = true))
      and center_administrator__c = false and isactive = true]) {
      pec.add(new Selectoption(u.id,u.name));
    }
    //DEC
    for(User u : [select id,name from user where Profile.Name in ('DEC_VisiblePrescreen','Doctor Education Consultant')
      and clinic_calendar__c in :center_market_names and isactive = true]) {
            pec.add(new Selectoption(u.id,u.name));
    }

    if(getCenterName()=='San Antonio') {
      for(User u : [select id,name from user where name='Linda Law' and isactive = true]) {
        pec.add(new Selectoption(u.id,u.name));
      }
    }*/
    return pec;
  }

  public void cancel_consult_view() {
  	modal_type = 'cancel_view';
  	cancel_reason = '';
  }

  public void reschedule_cancel() {
  	modal_type = 'apt_view';
	modal_out = '';
  }

  public void reschedule_consult() {
  	System.debug('Reschedule Reason : ' + reschedule_reason);
	Consult_Inventory__c[] apts_to_update = new Consult_Inventory__c[]{view_apt};
  	if(String.isBlank(reschedule_reason))
  	  modal_out = '<span class="blank" style="color:red;">You must select a reason for the reschedule in order to continue</span>';
  	else {
	  	Lead l;
	  	//need to free up this appointment block and set the scheduling lead to the lead record tied to it.
	  	String lead_id='';
	  	String account_id='';
	  	String patient_id='';
	  	Integer next_seven = 0;
	  	next_seven = next_seven_count(view_apt.leadscore_at_schedule_time__c);

	  	Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Rescheduled', Notes__c = 'Consultation is being rescheduled. ' + reschedule_reason, action_reason__c = reschedule_reason, apts_in_next_seven__c = next_seven);
	  	if(view_apt.scheduled_lead__c!=null) {
	  	  lead_id = view_apt.Scheduled_lead__c;
	  	  l = [select id, left_message_to_confirm__c, call_result__c, status, objection__c, datetime_consult_scheduled__c, date_consult_scheduled_by_rep__c, confirmed_appointment__c, could_not_reach__c,inbound_call__c,Hot_List__c,Cancellation_List_Notes__c from lead where id = :view_apt.Scheduled_Lead__c];
	  	}
	  	else if(view_apt.scheduled_account__c!=null)
	  	  account_id = view_apt.scheduled_account__c;
	  	else if(view_apt.scheduled_patient__c!= null)
	  	  patient_id = view_apt.scheduled_patient__c;
	  	view_apt.Scheduled_Lead__c = null;
	  	view_apt.Scheduled_account__c = null;
	  	view_apt.scheduled_patient__c = null;
		reschedule_source_consult = view_apt.clone(true, true);
	  	reschedule_source_id = view_apt.id;
	  	reschedule_callback_consult = view_apt.callback_consult__c;
	  	reschedule_callback_consult_pec = view_apt.callback_consult_pec__c;
	  	reschedule_notes = view_apt.Apt_Notes__c;
	  	reschedule_treatment = view_apt.Treatment__c;
	  	reschedule_gc = view_apt.gc_offered__c;
	  	rescheduled_time = view_apt.scheduled_time__c;
	  	rescheduled_by = view_apt.scheduled_by__c;
	  	reschedule_will_show = view_apt.will_patient_show__c;
		reschedule_will_start = view_apt.will_patient_start__c;
		reschedule_confirmation_status = view_apt.Confirmation_Status__c;
	  	view_apt.treatment__c = null;
	  	view_apt.Apt_Notes__c = null;
	  	view_apt.gc_offered__c = false;
	  	view_apt.confirmation_status__c = 'Not Confirmed';
	  	view_apt.Callback_Consult__c = false;
	  	view_apt.Callback_Consult_PEC__c = null;
	  	view_apt.send_reminder__c = false;
	  	view_apt.auto_reminder__c = false;
	  	view_apt.will_patient_show__c = null;
	  	view_apt.will_patient_start__c = null;
		view_apt.external_agent__c = null;
		if (view_apt.Double_Consult__c != null) {
			Consult_Inventory__c double_consult_apt = [SELECT ID FROM Consult_Inventory__c WHERE ID = :view_apt.Double_Consult__c];
			double_consult_apt.Double_Consult__c = null;
			view_apt.Double_Consult__c = null;
			apts_to_update.add(double_consult_apt);
		}
	  	try {
	  		update apts_to_update;
	  		insert history;
	  		reschedule = true;
	  		reschedule_date = view_apt.apt_date__c;
	  		//view_apt = [Select c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name, c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c From Consult_Inventory__c c where c.id =:view_apt.id];
	  		view_apt = getapt_block(view_apt.id);
	  		if(lead_id!='') {
	  		  scheduling_lead = [select referral_location__c,vantage_response__c,receive_text_reminder__c,receive_auto_reminder__c,createddate,work__c,why_not_schedule__c,inbound_call__c,status,left_message_to_confirm__c,call_result__c,objection__c,date_consult_scheduled_by_rep__c,confirmed_appointment__c,could_not_reach__c,DateTime_Consult_Scheduled__c,id,name,firstname,center__c,lastname,mobilephone,home_phone__c,pre_screen__c,prescreen_type__c,email,refused_to_give_email__c,fees_quoted__c,phone,Hot_List__c,Cancellation_List_Notes__c,leadscore__c,date_of_birth__c,center__r.type__c, Reminder_Call__c, Reminder_Text__c from Lead where id = :lead_id];
		  		l.status = 'Not Scheduled';
		  		//placeholder
		  		l.OBJECTION__c = 'Other';
		  		l.DateTime_Consult_Scheduled__c = null;
		  		l.Confirmed_Appointment__c = false;
		  		l.Could_not_Reach__c = false;
		  		l.Left_Message_to_Confirm__c = false;
		  		Date today_date = system.today();
	  			l.Call_Result__c = 'Not Scheduled';
	  			l.why_not_schedule__c = 'Rescheduling Appointment';
		  	  update l;
		  	  //Task t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Rescheduling Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Rescheduling Consult', Call_No_Answer__c = false, Status = 'Completed');
				  //insert t;
	  		}
	  		else if(account_id!='')
	  		  scheduling_account = [select receive_text_reminder__c,receive_auto_reminder__c,id, FirstName, LastName,phone,personmobilephone,pre_screen__c,center__c,center__r.name,leadscore__c,createddate, Reminder_Call__c, Reminder_Text__c from account where id = :account_id];
	  		else if(patient_id!='')
	  		  scheduling_patient = [Select p.full_name__c, p.Patient_Email__c, p.Name, p.Main_Phone__c, p.Last_Name__c, p.First_Name__c, p.CreatedDate, p.Center__c, p.center__r.name, p.Alt_Phone__c From Private_Practice_Patient__c p where id = :patient_id];
	  		//likely need to update the lead record as well.
	  		modal_display = false;
	  		modal_out = '';
	  	}
	  	catch (System.DmlException e) {
	  	  for (Integer i = 0; i < e.getNumDml(); i++) {
	        modal_out += e.getDmlMessage(i) + '<br />';
	      }
	    }
  	}
  }

  public void place_hold() {
  	Consult_Inventory__c apt_check = [select c.scheduled_patient__c, c.scheduled_account__c,c.scheduled_lead__c,c.consult_room__r.center_information__c from Consult_Inventory__c c where c.id = :view_apt.id];
  	if(apt_check.Scheduled_lead__c==null && apt_check.scheduled_account__c==null && apt_check.scheduled_patient__c==null) {
  		Integer h = check_for_active_hold();
  		if(h>0)
  			modal_out += '<span class="blank" style="color:red;">' + hold_message + '</span>';
  	  else {
  	  	try {
  	  		Consult_Holds__c ch = new Consult_Holds__c(Consult_Inventory__c = view_apt.id, Hold_by__c = Userinfo.getuserid(), hold_time__c = System.now(),Active_Hold__c = true );
  	  		insert ch;
  	  	  Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Hold', notes__c = 'A Hold was placed on this apt block');
	  	    insert history;
  	  	}
  	  	catch (Exception e) {

  	  	}
  	  }
  	}
  	else
  	  modal_out = '<span class="blank" style="color:red;">Consult is no longer available</span>';
  }

  public void remove_hold() {
    List<Consult_Holds__c> remove_hold_list = [select id from Consult_Holds__c where Consult_inventory__c = :view_apt.id and active_hold__c = true];
    for(Consult_Holds__c ch : remove_hold_list) {
      ch.active_hold__c = false;
    }
    try {
      update remove_hold_list;
    }
    catch (Exception e) {

    }
  }

  public Integer next_seven_count(String leadscore) {
  	//need to parse the filtered query and display the next five available items.
  	Date sdate = System.today();
  	Date edate = sdate.adddays(7);
  	String query = '';
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c <> \'Unconfirmed\' and scheduled_lead__c = null and scheduled_account__c = null and scheduled_patient__c = null and consult_room__r.center_information__c = \'' + selected_center + '\' and apt_date__c >= :sdate and apt_date__c <= :edate';
    if(leadscore==null)
      leadscore = 'NA';
  	if(leadscore=='Green' || leadscore=='Yellow') {
      //no need to worry about the 3 day rules
      next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
      query = 'Select id From Consult_Inventory__c c ' + next_filter;
  	}
  	else {
  		Date tdate = System.today().addDays(5);
  		//this is just a cheap way to get the Green/Yellow blocks available for these 2 pre-screen types easily
  		//if(my_lead.Pre_Screen__c=='Insufficient Information')
  		//if(my_lead.leadscore__c=='Insufficient Information')
  		  //tdate = System.today().addDays(360);
  		//if(my_lead.Pre_Screen__c=='Red' || my_lead.Pre_Screen__c=='Blue (No Hit)' || my_lead.pre_screen__c=='PO Box')
  		if(leadscore=='Red' || leadscore=='Blue (No Hit)' || leadscore=='PO Box' || leadscore=='Insufficient Information' || leadscore=='Website Down-No Prescreen')
	  	  //if(seminar==false)
	  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\')))';
	  	  /*else
	  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\',\'Seminar\')))';*/
	    else
	      //if(seminar==false)
	  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c = \'Any\'))';
	  	  /*else
	  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Seminar\')))';*/
  		query = 'Select id From Consult_Inventory__c c ' + next_filter;
  	}
  	Integer apt_count = 0;
  	try {
  	  List<Consult_Inventory__c> ci_list =  database.query(query);
  	  apt_count = ci_list.size();
  	}
  	catch (Exception e) {

  	}
  	return apt_count;
  }

  public void schedule_callback() {
  	modal_out = '';
  	if(view_apt.callback_consult_pec__c==null) {
  	  modal_out += '<span class="blank" style="color:red;">You must select a pec for the callback consult<br /></span>';
  	}
  	else {
  	  view_apt.callback_consult__c = true;
  	  try {
  	    update view_apt;
  	    modal_type = 'apt_view';
  	    schedule_consult();
  	  }
  	  catch (Exception e) {
  		modal_out += '<span class="blank" style="color:red;">There was an issue with updating the consult block</span>';
  	  }
  	}
  }

  public Integer getage_of_ticket() {
  	if(view_apt==null)
  	  return 999;
  	else {
  	  try {
  	    Date sched_date = Date.newinstance(view_apt.scheduled_time__c.year(),view_apt.scheduled_time__c.month(),view_apt.scheduled_time__c.day());
  	    if(view_apt.apt_date__c>System.today())
  	      return sched_date.daysBetween(system.today());
  	    else
  	      return sched_date.daysBetween(view_apt.apt_date__c);
  	  } catch (Exception e) {
  	  	return 999;
  	  }
  	}
  }

  public void schedule_consult() {
  	/**
  	---2/28/2013 by CM
  	WARNING - Please update Chad on all changes made to the scheduling system code.  We want to keep the online system in synch with everything else
  	**/
  	//check to verify the apt is still available
  	System.debug('Reschedule : ' + reschedule);
  	//tweak this to grab the view apt block with a for update lock on it. This should completely prevent the possibility
  	//of two people scheduling in the same block.
  	view_apt = [Select c.scheduled_lead__r.prospect_all_score__c, c.gc_offered__c, c.scheduled_patient__r.full_name__c, c.scheduled_patient__c, c.scheduled_patient__r.id, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.Leadscore_At_Schedule_Time__c, c.consult_room__r.center_information__r.send_confirmation_email__c,c.consult_room__r.center_information__r.confirmation_email_address__c,c.consult_room__r.center_information__r.name,c.auto_reminder__c,c.will_patient_start__c,c.will_patient_show__c,c.special_initiative__c,c.Consult_Room__r.center_information__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.Scheduled_Lead__r.Email, c.scheduled_lead__r.pre_screen__c, c.scheduled_lead__r.leadscore__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.leadscore__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone, c.Scheduled_Account__r.PersonEmail, c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.room_type__c,c.consult_room__r.center_information__r.type__c,c.consult_room__r.center_information__r.Vantage_OfficeID__c, c.add_ons__c, c.Double_Consult__c, c.Scheduled_Lead__r.Reminder_Call__c, c.Scheduled_Lead__r.Reminder_Text__c, c.Scheduled_Account__r.Reminder_Call__c, c.Scheduled_Account__r.Reminder_Text__c, c.isConsultScheudled__c From Consult_Inventory__c c  where c.id =:view_apt.id for update];
	Consult_Inventory__c[] apts_to_update = new Consult_Inventory__c[]{view_apt};

  	//Consult_Inventory__c apt_check = [select c.scheduled_account__c,c.scheduled_lead__c,c.consult_room__r.center_information__c,c.pre_screen_type__c from Consult_Inventory__c c where c.id = :view_apt.id];
  	if(view_apt.Scheduled_lead__c == null && view_apt.scheduled_account__c == null && view_apt.scheduled_patient__c == null) {
		modal_out = '';
		Integer num_issues = 0;
		String center_conflict_error = '<span class="blank" style="color:red;">Consult is in a different center than the one the patient has been assigned to<br />Please update the patient record before trying to schedule here<br /></span>';
		String reminder_error = '<span class="blank" style="color:red;">Both "Automated Call?" and "Text Reminder?" questions are required. Please answer them before saving.</span>';
		if(scheduling_lead != null) {
			//System.debug('Lead Centers : ' + apt_check.Consult_Room__r.center_information__c + ' - ' + scheduling_lead.Center__c);
			if(view_apt.Consult_Room__r.center_information__c != scheduling_lead.Center__c) {
				modal_out += center_conflict_error;
				num_issues ++;
			}
			if (!reschedule && view_apt.Consult_Room__r.Room_Type__c != 'Practice' && (scheduling_lead.Reminder_Call__c == null || scheduling_lead.Reminder_Text__c == null)) {
				modal_out += reminder_error;
				num_issues++;
			}
		}
		if(scheduling_account != null) {
			//System.debug('Account Centers : ' + apt_check.Consult_Room__r.center_information__c + ' - ' + scheduling_account.Center__c);
			if(view_apt.Consult_Room__r.center_information__c != scheduling_account.Center__c) {
				modal_out += center_conflict_error;
				num_issues ++;
			}
			if (!reschedule && view_apt.Consult_Room__r.Room_Type__c != 'Practice' && (scheduling_account.Reminder_Call__c == null || scheduling_account.Reminder_Text__c == null)) {
				modal_out += reminder_error;
				num_issues++;
			}
		}
		if(scheduling_patient != null)
			if(view_apt.Consult_Room__r.center_information__c != scheduling_patient.Center__c) {
				modal_out += center_conflict_error;
				num_issues ++;
			}
  		if(view_apt.pre_screen_type__c == 'Seminar' && !display_seminar && !getdisplay_ca()) {
  			modal_out += '<span class="blank" style="color:red;">Apt Block was reserved for Seminar and is unavailable<br /></span>';
  			num_issues++;
  		}

  		//System.debug('Num issues : ' + num_issues + ' Modal : ' + modal_out);
  		Integer h = check_for_other_hold();
  		System.debug('Num h : ' + h);
  		if(h>0) {
  			modal_out += '<span class="blank" style="color:red;">' + hold_message + '</span>';
  			num_issues ++;
  		}
  		System.debug('Num Issues : ' + num_issues);
      if(num_issues==0) {
		  Integer next_seven = 0;
  		  if(scheduling_lead!=null) {
			update scheduling_lead;
  		  	next_seven = next_seven_count(scheduling_lead.leadscore__c);
	  	    view_apt.Scheduled_Lead__c = scheduling_lead.id;
	  	    view_apt.leadscore_at_schedule_time__c = scheduling_lead.leadscore__c;
			view_apt.Auto_Reminder__c = scheduling_lead.Reminder_Call__c == 'Yes' ? true : false;
			view_apt.Send_Reminder__c = scheduling_lead.Reminder_Text__c == 'Yes' ? true : false;
	  	    //see if this is a referral from Vantage - if so we need to make a call to update the schedule status for this lead
	  	    /*if(scheduling_lead.referral_location__c != null) {
	  	      if(reschedule) {
	  	        String old_date = DateTime.newInstance(reschedule_date.year(),reschedule_date.month(),reschedule_date.day()).format('MM/dd/YYYY');
	  	        myWS.updatereferral_consultstatus(scheduling_lead.id,view_apt.apt_date__c,old_date,reschedule_reason);
	  	      }
	  	      else
	  	        myWS.updatereferral_consultstatus(scheduling_lead.id,view_apt.apt_date__c,'Scheduled',' ');
	  	    } */
  		  }
	  	  else if(scheduling_Account!=null) {
			update scheduling_account;
	  	  	next_seven = next_seven_count(scheduling_account.leadscore__c);
	  	    view_apt.scheduled_account__c = scheduling_account.id;
	  	    view_apt.leadscore_at_schedule_time__c = scheduling_account.leadscore__c;
			view_apt.Auto_Reminder__c = scheduling_Account.Reminder_Call__c == 'Yes' ? true : false;
			view_apt.Send_Reminder__c = scheduling_Account.Reminder_Text__c == 'Yes' ? true : false;
	  	  }
	  	  else if(scheduling_patient!=null) {
	  	  	view_apt.scheduled_patient__c = scheduling_patient.id;
	  	  	view_apt.send_reminder__c = false;
	  	  	view_apt.auto_reminder__c = false;
	  	  }
	  	  view_apt.Scheduled_by__c = Userinfo.getUserId();
	  	  view_apt.scheduled_time__c = System.now();
	  	  System.debug('Days Between : ' + System.today().daysBetween(view_apt.apt_date__c));
	  	  //need to calculate the number of days to look out for confirmation process
	  	  /*10/9/2013 - CM Pulling this per a request from Stephanie Gonzales - This will require a manual interaction now
	  	  Integer days_out = 3;
	  	  if(System.now().format('EEEE')=='Wednesday' || System.now().format('EEEE')=='Thursday' || System.now().format('EEEE')=='Friday')
	  			days_out = 5;
	  	  if(System.today().daysBetween(view_apt.apt_date__c)<=days_out && view_apt.consult_room__r.room_type__c<>'Unconfirmed')
	  		  view_apt.confirmation_status__c = 'Confirmed';*/
	  	  if(reschedule) {
	  	  	view_apt.last_rescheduled_by__c = userinfo.getuserid();
	  	  	view_apt.last_reschedule_time__c = System.now();
	  	  	view_apt.treatment__c = reschedule_treatment;
	  	  	view_apt.Callback_Consult__c = reschedule_callback_consult;
	  	  	view_apt.Callback_Consult_PEC__c = reschedule_callback_consult_pec;
	  	  	view_apt.gc_offered__c = reschedule_gc;
	  	  	view_apt.Scheduled_by__c = rescheduled_by;
	  	  	view_apt.scheduled_time__c = rescheduled_time;
	  	  	view_apt.will_patient_start__c = reschedule_will_start;
	  	  	view_apt.will_patient_show__c = reschedule_will_show;
			// 2017-03-08 Alon Waisman - Copying confirmation status and notes to rescheduled consult only if rescheduling to an appointment on the same day.
			if (reschedule_date == view_apt.Apt_Date__c) {
				view_apt.Confirmation_Status__c = reschedule_confirmation_status;
				if (reschedule_notes != null) {view_apt.apt_notes__c = reschedule_notes;}
			}
			// If rescheduling a double consult to another consult with the same start time, recreate the double consult connection on both consults.
			Boolean reestablish_double_consult_connection = (reschedule_source_consult.Double_Consult__c != null && view_apt.Start_Hour__c == reschedule_source_consult.Start_Hour__c && view_apt.Start_Minute__c == reschedule_source_consult.Start_Minute__c);
			if (reestablish_double_consult_connection) {
				Consult_Inventory__c double_consult_apt = [SELECT ID FROM Consult_Inventory__c WHERE ID = :reschedule_source_consult.Double_Consult__c];
				view_apt.Double_Consult__c = reschedule_source_consult.Double_Consult__c;
				double_consult_apt.Double_Consult__c = view_apt.ID;
				apts_to_update.add(double_consult_apt);
			}
	  	  }
	  	  try {
	  	    update apts_to_update;
	  	    Apt_History__c history;
	  	    if(reschedule)
	  	      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Scheduled', notes__c = 'Consultation has been rescheduled. ' + reschedule_reason, rescheduled_from__c = reschedule_source_id, apts_in_next_seven__c = next_seven);
	  	    else
	  	      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled', apts_in_next_seven__c = next_seven);
	  	    insert history;
	  	    Time schedule_time = time.newInstance(Math.round(view_apt.Start_Hour_Int__c), math.round(view_apt.Start_Minute_Int__c), 0, 0);
	  	    System.debug('My Time : ' + schedule_time);
	  	    Task t = null;
	  	     //send confirmation email to Center if marked for it
	  	    if(view_apt.consult_room__r.center_information__r.send_confirmation_email__c) {
	  	      	Datetime apt_dtime = datetime.newInstance(view_apt.apt_date__c.year(), view_apt.apt_date__c.month(), view_apt.apt_date__c.day()) ;
	  	      	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {'msmith@clearchoice.com','cmcdowell@clearchoice.com','sgonzalez@clearchoice.com',view_apt.consult_room__r.center_information__r.confirmation_email_address__c};
				mail.setToAddresses(toAddresses);
				mail.setReplyTo('msmith@clearchoice.com');
				//mail.setSenderDisplayName('Mindy Smith');
				OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
				if ( owea.size() > 0 ) {
				  mail.setOrgWideEmailAddressId(owea.get(0).Id);
				}
				mail.setSubject('ClearChoice has scheduled an appointment in your center');
				String apt_minutes = view_apt.start_minute__c;
				if(view_apt.start_minute__c.length()==1)
				  apt_minutes = '0' + view_apt.start_minute__c;
				String mail_body = '';
				if(scheduling_lead!=null)
				  mail_body = '<html><body>A new appointment has been scheduled on ' + apt_dtime.format('EEEE, MMMM d, yyyy') +
				    ' at ' + view_apt.start_hour__c + ':' + apt_minutes + ' for ' + scheduling_lead.name + '.  You can reach this patient at ' + scheduling_lead.phone +
				    '.</body></html>';
				else if(scheduling_account!=null)
				  mail_body = '<html><body>A new appointment has been scheduled on ' + apt_dtime.format('EEEE, MMMM d, yyyy') +
				  ' at ' + view_apt.start_hour__c + ':' + apt_minutes + ' for ' + scheduling_account.FirstName + ' ' + scheduling_account.LastName + '.  You can reach this patient at ' + scheduling_account.phone +
				  '.</body></html>';
				mail.setHtmlBody(mail_body);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	    }
	  	    if(scheduling_lead!=null) {
	  	    	if(reschedule) {
	  	    		if(view_apt.consult_room__r.room_type__c=='Unconfirmed') {
	  	    		  t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Cancelled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Unconfirmed', Call_No_Answer__c = false, Status = 'Completed');
	  	    		  scheduling_lead.Call_Result__c = 'Cancelled Appointment';
	  	    		  scheduling_lead.status = 'Not Scheduled';
	  	    		  scheduling_lead.OBJECTION__c = 'Not Confirmed';
	  	    		  insert t;
	  	    		}
	  	    		else {
	  	    			if(view_apt.apt_date__c<>reschedule_date) {
	  	    		    t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Rescheduled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Rescheduled Consult', Call_No_Answer__c = false, Status = 'Completed');
	  	    		    insert t;
	  	    			}
	  	    		  scheduling_lead.status = 'Rescheduled Consult';
	  	    		  Date today_date = system.today();
	  	    		  if(today_date.daysBetween(view_apt.apt_date__c)==0)
	  		          scheduling_lead.Call_Result__c = 'Same Day Rescheduled Consult';
	  		        else
	  			        scheduling_lead.Call_Result__c = 'Consultation Scheduled';
	  			      scheduling_lead.OBJECTION__c = null;
	  	    		}
	  		      scheduling_lead.Confirmed_Appointment__c = false;
	  		      scheduling_lead.Could_not_Reach__c = false;
	  		      scheduling_lead.Left_Message_to_Confirm__c = false;

	  			    //modal_display = false;
  		        modal_out = '';
	  	    	}
	  	    	else {
	  	    		if(view_apt.consult_room__r.room_type__c=='Unconfirmed') {
	  	    		  t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Cancelled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Unconfirmed', Call_No_Answer__c = false, Status = 'Completed');
	  	    		  scheduling_lead.Call_Result__c = 'Cancelled Appointment';
	  	    		  scheduling_lead.status = 'Not Scheduled';
	  	    		  scheduling_lead.OBJECTION__c = 'Not Confirmed';
	  	    		}
	  	    		else {
	  	    		  t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Scheduled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Scheduled Consult', Call_No_Answer__c = false, Status = 'Completed');
	  	    		  scheduling_lead.status = 'Consult Scheduled';
	  	    		  scheduling_lead.Call_Result__c = 'Consultation Scheduled';
	  	    		  scheduling_lead.OBJECTION__c = null;
	  	    		}
			  			insert t;
				  		scheduling_lead.Confirmed_Appointment__c = false;
				  		scheduling_lead.Could_not_Reach__c = false;
				  		scheduling_lead.Left_Message_to_Confirm__c = false;
				  		Date today_date = system.today();

	  	    	}
	  	      if(System.today().daysBetween(view_apt.apt_date__c)<=3)
	  			    scheduling_lead.Confirmed_Appointment__c = true;
	  	    	scheduling_lead.Inbound_Call__c = 'Dental Inquiry';
	  	    	scheduling_lead.Non_Sales_Call_Result__c = null;
	  	      scheduling_lead.DateTime_Consult_Scheduled__c = datetime.newInstance(view_apt.apt_date__c, schedule_time);
	  	      scheduling_lead.date_consult_scheduled_by_rep__c = system.today();
	  	      System.debug('Scheduled Time : ' + datetime.newInstancegmt(view_apt.apt_date__c, schedule_time));
	  	      update scheduling_lead;
	  	      //blocks Network Center
	  	      if(view_apt.consult_room__r.room_type__c<>'Unconfirmed' && reschedule_reason <> 'Schedule Management' && view_apt.special_initiative__c<>'Workshop'
	  	        && view_apt.consult_room__r.center_information__r.type__c <> 'Network Center') {
		  	      try {
			  	    	List<Awaiting_Bulk_print__c> pending_jobs = [select id from Awaiting_Bulk_Print__c where batch_form__c = 'Welcome Letter' and lead_id__c = :scheduling_lead.id and status__c = 'Pending'];
			  	    	if(pending_jobs.size()>0) {
			  	    	  //we have a pending print job and need to cancel it out before proceeding
			  	    	  delete pending_jobs;
			  	    	}
			  	    	//make sure it's not Tampa
			  	    	if(getselected_center_name()!='Tampa - Affiliate') {
						      Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Welcome Letter', Lead_Id__c = scheduling_lead.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
							    insert bulk_print;
						    	Task t2 = new Task(WhoId = scheduling_lead.Id, OwnerId = Userinfo.getUserId(), Subject = 'Welcome Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
						    	insert t2;
			  	    	}
			  	    	//make sure it's not Tampa
			  	    	if(scheduling_lead.email!=null && getselected_center_name()!='Tampa - Affiliate')
			  	    	  send_welcome_email(scheduling_lead,view_apt.apt_date__c);
			  	    }
			  	    catch (Exception e) {
			  			// 	for (Integer i = 0; i < e.getNumDml(); i++) {
				      //     modal_out += e.getDmlMessage(i) + '<br />';
				      //   }
					    //   Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
					    //   String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
					    //   mail.setToAddresses(toAddresses);
					    //   mail.setReplyTo('cmcdowell@acme.com');
					    //   mail.setSenderDisplayName('Apex error message');
					    //   mail.setSubject('Scheduling System Error - Welcome Letter');
					    //   mail.setPlainTextBody(e.getMessage());
					    //   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				  		}
	  	      }
	  	      /*if(view_apt.consult_room__r.center_information__r.type__c == 'Network Center' && view_apt.consult_room__r.center_information__r.Vantage_OfficeID__c != null) {
	  	      	try {
	  	      	  if(scheduling_lead.vantage_response__c==null)
	  	            myWS.sendNetCenterInfo(scheduling_lead.id);
	  	      	} catch (Exception e) {
	  	      	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
			      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
			      mail.setToAddresses(toAddresses);
			      mail.setReplyTo('cmcdowell@acme.com');
			      mail.setSenderDisplayName('Apex error message');
			      mail.setSubject('Scheduling System Error - Call to Vantage Failed');
			      mail.setPlainTextBody(e.getMessage());
			      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	      	}
	  	      }*/
	  	      scheduling_lead = null;
	  	    }
	  	    else if(scheduling_account!=null) {
	  	      scheduling_account = null;
	  	    }
	  	    else if(scheduling_patient!=null) {
	  	      scheduling_patient = null;
	  	    }
			if (reschedule) {modal_display = false;} //ALON
	  	    reschedule = false;
	  	    reschedule_treatment = '';
	  	    reschedule_notes = '';
	  	    reschedule_reason = '';
	  	    //refresh the fields for display
	  	    view_apt = getapt_block(view_apt.id);
	  	    //[Select c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c From Consult_Inventory__c c where c.id =:view_apt.id];
	  	    //send email and welcome letter
	  	  }
	  	  catch (System.DmlException e) {
			for (Integer i = 0; i < e.getNumDml(); i++) {
	          modal_out += e.getDmlMessage(i) + '<br />';
	        }
		      // Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      // String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      // mail.setToAddresses(toAddresses);
		      // mail.setReplyTo('cmcdowell@acme.com');
		      // mail.setSenderDisplayName('Apex error message');
		      // mail.setSubject('Scheduling System Error');
		      // mail.setPlainTextBody(e.getMessage());
		      // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  		}
  		}
  	}
  	else
  	  modal_out = '<span class="blank" style="color:red;">Consult is no longer available</span>';
  }

   public void send_welcome_email(Lead l,Date apt_date) {
  	try {
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    EmailTemplate et;
	    //adjusting to handle Ft Lauderdale move
	    Date move_date = date.newinstance(2015,12,7);
	    if(l.pre_screen__c=='Green' || l.pre_screen__c=='Yellow' || l.pre_screen__c=='Red') {
	      if(getselected_center_name()=='Miami Fort Lauderdale' && apt_date >= move_date && System.today() < move_date)
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_new_FTL'];
	      else
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0'];
	    }
	    else {
	      if(getselected_center_name()=='Miami Fort Lauderdale' && apt_date >= move_date && System.today() < move_date)
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen_FTL'];
	      else
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen'];
	    }
	    //mail.setSenderDisplayName(Userinfo.getUserName());
	    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
		if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
	    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);
	    //check for a workshop map
	    //System.debug('Special Initiative : ' + view_apt.special_initiative__c);
		  if(view_apt.special_initiative__c=='Workshop') {
			  List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
		    System.debug('Center__c : ' + l.center__c);
	      for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: l.center__c and name like 'Workshop%' order by createddate desc limit 1]) {
			    // Add to attachment file list
			    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
			    efa.setFileName(a.Name);
			    efa.setBody(a.Body);
			    fileAttachments.add(efa);
	      }
	      if(fileAttachments.size()>0)
	        mail.setFileAttachments(fileAttachments);
		  }
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    modal_out += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Caught email exception: ' + e));
      modal_out += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';
  	}
  }

  public void seminar_reserve() {
  	Consult_Inventory__c apt_check = [select c.scheduled_patient__c,c.scheduled_account__c,c.scheduled_lead__c,c.consult_room__r.center_information__c from Consult_Inventory__c c where c.id = :view_apt.id];
  	if(apt_check.Scheduled_lead__c==null && apt_check.scheduled_account__c==null && apt_check.scheduled_patient__c==null) {
  		view_apt.Pre_Screen_Type__c = 'Seminar';
  		try {
  		  update view_apt;
  		  Apt_History__c history;
 	      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_practice_patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Seminar Reserved', notes__c = 'Consultation has been reserved for seminar');
  	    insert history;
  		}
  		catch (System.DmlException e) {

  		}
  	}
    else
      modal_out = '<span class="blank" style="color:red;">Consult is no longer available</span>';
  }

  // public boolean getdisplay_seminar_unreserve_all() {
  //   Integer seminar_count = [select count() from Consult_Inventory__c where
  //     consult_room__r.center_information__c = :selected_center and pre_screen_type__c = 'Seminar' and apt_date__c = :selected_date];
  //   if (seminar_count > 0 && (display_seminar || display_admin))
  //     return true;
  //   else
  //   //   return (test.isRunningTest() && (getdisplay_seminar() || getdisplay_admin())) ? true : false;
  //  return false;
  // }

  // public void seminar_unreserve_all() {
  // 	//work through all consult blocks with a pre-screen type of Seminar from today forward in this Center and switch
  // 	//them back to Any
  // / ** 2017-01-20 Alon Waisman: Changed to only unreserve the appointments for the selected date instead of today and all future appointments.
  // 	List<Consult_Inventory__c> seminar_blocks = [select id,pre_screen_type__c,scheduled_lead__c,scheduled_account__c,scheduled_patient__c from Consult_Inventory__c where
  // 	  consult_room__r.center_information__c = :selected_center and pre_screen_type__c = 'Seminar' and apt_date__c = :selected_date];
  // 	List<Apt_History__c> change_hist = new List<Apt_History__c>();
  // 	for(Consult_Inventory__c ci : seminar_blocks) {
  // 		ci.pre_screen_type__c = 'Any';
  // 		Apt_History__c history = new Apt_History__c(Consult_Inventory__c = ci.id, Private_Practice_Patient__c = ci.scheduled_patient__c, Lead__c = ci.scheduled_lead__c, Account__c = ci.scheduled_account__c, action__c = 'Seminar Unreserved', notes__c = 'Consultation has been unreserved for seminar');
  //    change_hist.add(history);
  // 	}
  // 	try {
  // 	  update seminar_blocks;
  // 	  if(change_hist.size()>0)
  // 	    insert change_hist;
  // 	}
  // 	catch (Exception e) {
  //
  // 	}
  // }

	public void seminar_unreserve() {
		view_apt.Pre_Screen_Type__c = 'Any';
		try {
			update view_apt;
			Apt_History__c history;
			history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Seminar Unreserved', notes__c = 'Consultation has been unreserved for seminar');
			insert history;
		}
		catch (System.DmlException e) {}
	}


	public Date    bulk_change_end_date         {get; set;}
	public String  bulk_change_room_filter      {get; set;}
	public String  bulk_change_scheduled_status {get; set;}
	public Integer bulk_change_start_hour       {get; set;}
	public Integer bulk_change_start_minute     {get; set;}
	public Integer bulk_change_end_hour         {get; set;}
	public Integer bulk_change_end_minute       {get; set;}
	public Integer bulk_change_time_shift       {get; set;}
	// public String  bulk_change_room_target      {get; set;}


	public List<SelectOption> getroom_options_with_all() {
		return getroom_options(true);
	}
	// public List<SelectOption> getroom_options_no_all() {
	// 	return getroom_options(false);
	// }
			private List<Selectoption> getroom_options(Boolean include_all) {
				List<SelectOption> options = new List<SelectOption>();
				if (include_all) {options.add(new SelectOption('all', 'All'));}
				for (Consult_Rooms room : getview_allrooms()) {
					options.add(new SelectOption(room.room.id, room.room.name));
				}
				return options;
			}
	public List<Selectoption> getscheduled_status_options() {
		return new List<SelectOption>{new SelectOption('any', 'Any'),
										new SelectOption('not scheduled', 'Not Scheduled'),
										new SelectOption('scheduled', 'Scheduled')};
	}
	public List<SelectOption> gethour_options() {
		List<SelectOption> options = new List<SelectOption>();
		String hour;
		for (Integer i = 7; i <= 21; i++) {
			hour = String.valueOf(Math.mod(i - 1, 12) + 1);
			options.add(new SelectOption(String.valueOf(i) , hour + (i < 12 ? 'am' : 'pm')));
		}
		return options;
	}
	public List<SelectOption> getminute_options() {
		List<SelectOption> options = new List<SelectOption>();
		for (Integer i = 0; i <= 45; i += 15) {
			options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
		return options;
	}
	public List<SelectOption> gettime_shift_options() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('0', '0'));
		for (Integer i = -60; i <= 60; i += 15) {
			if (i != 0) {options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));}
		}
		return options;
	}


	public void bulk_add_permanent_hold() {
		bulk_permanent_hold('add');
	}
	public void bulk_remove_permanent_hold() {
		bulk_permanent_hold('remove');
	}
			private void bulk_permanent_hold(String type) {
				// Permanent holds are currently managed through use of pre_screen type of 'Seminar'. This is not ideal. We should really have a boolean field on consult to determine if it's being held.
				String new_setting;
				if (type == 'add')    {new_setting = 'Seminar';}
				Consult_Inventory__c[] consults = getconsults_to_change(bulk_change_scheduled_status);
				Apt_History__c[] history_records = new Apt_History__c[]{};
				String history_note;
				for (Consult_Inventory__c consult : consults) {
					if (type == 'remove') {new_setting = pre_screen_after_removing_hold(consult);}
					if (!String.isBlank(new_setting) && consult.Pre_Screen_Type__c != new_setting) {
						history_note = 'Pre Screen type changed from ' + consult.Pre_Screen_Type__c + ' to ' + new_setting + '<br />';
						consult.Pre_Screen_Type__c = new_setting;
						history_records.add(new Apt_History__c(Consult_Inventory__c = consult.id, Private_Practice_Patient__c = consult.Scheduled_Patient__c, Lead__c = consult.Scheduled_Lead__c, Account__c = consult.Scheduled_Account__c, Action__c = 'Bulk ' + type.capitalize() + ' Permanent Hold', Notes__c = history_note));
					}
				}
				try {
					update consults;
					insert history_records;
				} catch(Exception error) {}
			}
					private Consult_Inventory__c[] getconsults_to_change(String scheduled_status) {
						Set<String> allowed_statuses = new Set<String>{'any', 'scheduled', 'not scheduled'};
						Consult_Inventory__c[] consults;
						if (allowed_statuses.contains(scheduled_status)) {
							String scheduled_status_filter = '';
							if (scheduled_status == 'not scheduled') {
								scheduled_status_filter = ' AND Scheduled_Lead__c = null AND Scheduled_Account__c = null AND Scheduled_Patient__c = null';
							} else if (scheduled_status == 'scheduled') {
								scheduled_status_filter = ' AND (Scheduled_Lead__c != null OR Scheduled_Account__c != null OR Scheduled_Patient__c != null)';
							}
							String[] rooms_list = rooms_list();
							String query = 'SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c, Scheduled_Lead__c, Scheduled_Account__c, Scheduled_Patient__c, Consult_Room__r.Room_Type__c, Color__c' +
											' FROM Consult_Inventory__c' +
											' WHERE Apt_Date__c >= :selected_date AND Apt_Date__c <= :bulk_change_end_date' +
											' AND Consult_Room__c IN :rooms_list' +
											' AND Active__c = true' +
											scheduled_status_filter;

							Consult_Inventory__c[] consults_not_time_filtered = Database.query(query);

							Time start_time = Time.newInstance(bulk_change_start_hour, bulk_change_start_minute, 0, 0);
							Time end_time   = Time.newInstance(bulk_change_end_hour,   bulk_change_end_minute,   0, 0);
							consults = new Consult_Inventory__c[]{};
							for (Consult_Inventory__c consult : consults_not_time_filtered) {
								Time consult_time = Time.newInstance(Integer.valueOf(consult.Start_Hour__c), Integer.valueOf(consult.Start_Minute__c), 0, 0);
								if (consult_time >= start_time && consult_time <= end_time) {consults.add(consult);}
							}
						}
						return consults;
					}
							private String[] rooms_list() {
								String[] rooms = new String[]{};
								if (bulk_change_room_filter == 'all') {
									for (Consult_Rooms room : getview_allrooms()) {rooms.add(room.room.id);}
								} else rooms.add(bulk_change_room_filter);
								return rooms;
							}
					private String pre_screen_after_removing_hold(Consult_Inventory__c consult) {
						// If and when we switch to a proper method for managing permanent holds, this method won't be necessary we would just be enabling/disabling the boolean value.

						// OverFlow consults should always have a pre_screen value of 'Green/Yellow'
						if (consult.Consult_Room__r.Room_Type__c == 'OverFlow') {return 'Green/Yellow Only';}
						// Pre_screen values for consults in Normal rooms should be either 'Green/Yellow' or 'Any', determined by the block color
						Map<String, String> pre_screen_by_block_color = new Map<String, String>{'Light Green' => 'Green/Yellow', 'Green' => 'Green/Yellow', 'Light Purple' => 'Any', 'Purple' => 'Any'};
						if (consult.Consult_Room__r.Room_Type__c == 'Normal' || consult.Consult_Room__r.Room_Type__c == 'Manual') {return pre_screen_by_block_color.get(consult.Color__c);}
						else return null;
					}

	public void bulk_time_shift() {
		Consult_Inventory__c[] consults = getconsults_to_change(bulk_change_scheduled_status);
		Apt_History__c[] history_records = new Apt_History__c[]{};
		String history_note;
		for (Consult_Inventory__c consult : consults) {
			history_note = 'Appointment time shifted ' + (bulk_change_time_shift > 0 ? '+' : '') + bulk_change_time_shift + ' minutes<br />';
			Time start_time         = Time.newInstance(Integer.valueOf(consult.Start_Hour__c), Integer.valueOf(consult.Start_Minute__c), 0, 0);
			Time end_time           = Time.newInstance(Integer.valueOf(consult.End_Hour__c),   Integer.valueOf(consult.End_Minute__c),   0, 0);
			Time shifted_start_time = start_time.addMinutes(bulk_change_time_shift);
			Time shifted_end_time   = end_time.addMinutes(bulk_change_time_shift);
			consult.Start_Hour__c   = String.valueOf(shifted_start_time.hour());
			consult.Start_Minute__c = String.valueOf(shifted_start_time.minute());
			consult.End_Hour__c     = String.valueOf(shifted_end_time.hour());
			consult.End_Minute__c   = String.valueOf(shifted_end_time.minute());
			history_records.add(new Apt_History__c(Consult_Inventory__c = consult.id, Private_Practice_Patient__c = consult.Scheduled_Patient__c, Lead__c = consult.Scheduled_Lead__c, Account__c = consult.Scheduled_Account__c, Action__c = 'Bulk Time Shift', Notes__c = history_note));
		}
		update consults;
		insert history_records;
	}

	public void bulk_remove_unscheduled_appointments() {
		Consult_Inventory__c[] consults = getconsults_to_change(bulk_change_scheduled_status);
		Apt_History__c[] history_records = new Apt_History__c[]{};
		String history_note;
		for (Consult_Inventory__c consult : consults) {
			Boolean consult_is_not_scheduled = consult.Scheduled_Lead__c == null && consult.Scheduled_Account__c == null && consult.Scheduled_Patient__c == null;
			if (consult_is_not_scheduled) {
				history_note = 'Unscheduled appointment deleted (made inactive)<br />';
				consult.Active__c = false;
				history_records.add(new Apt_History__c(Consult_Inventory__c = consult.id, Private_Practice_Patient__c = consult.Scheduled_Patient__c, Lead__c = consult.Scheduled_Lead__c, Account__c = consult.Scheduled_Account__c, Action__c = 'Bulk Unscheduled Delete', Notes__c = history_note));
			}
		}
		update consults;
		insert history_records;
	}


	// public void bulk_room_change() {
	// 	if (bulk_change_room_filter != 'all' && bulk_change_room_filter != bulk_change_room_target) {
	// 		Consult_Inventory__c[] consults = getconsults_to_change();
	// 		for (Consult_Inventory__c consult : consults) {
	// 			consult.Consult_Room__c = bulk_change_room_target;
	// 		}
	// 		update consults;
	// 	}
	// }




  public Consult_Inventory__c getapt_block(String apt_id) {
  	Consult_Inventory__c my_apt = [SELECT c.scheduled_lead__r.prospect_all_score__c, c.scheduled_patient__c, c.Callback_Consult__c, c.Callback_Consult_PEC__c,c.auto_reminder__c,c.external_agent__c,c.will_patient_start__c,c.will_patient_show__c,c.leadscore_at_schedule_time__c,c.special_initiative__c,c.gc_offered__c,c.dow_int__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.Double_Consult__c, c.Double_Consult__r.Scheduled_Lead__c, c.Double_Consult__r.Scheduled_Account__c, c.Double_Consult__r.Scheduled_Lead__r.Name, c.Double_Consult__r.Scheduled_Account__r.Name, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.distance_to_center__c, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.Scheduled_Lead__r.Email, c.scheduled_lead__r.pre_screen__c,c.scheduled_lead__r.leadscore__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.distance_to_center__c,c.scheduled_account__r.center__c, c.Scheduled_Account__r.FirstName, c.Scheduled_Account__r.LastName,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone, c.Scheduled_Account__r.PersonEmail, c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.room_type__c,c.consult_room__c, c.scheduled_lead__r.date_of_birth__c, c.Scheduled_Account__r.Date_of_Birth__c, c.consult_room__r.center_information__r.type__c,c.consult_room__r.center_information__r.name,c.consult_room__r.center_information__r.Vantage_OfficeID__c,c.scheduled_lead__r.warranty_id__c,c.scheduled_account__r.warranty_id__c,c.scheduled_lead__r.procedure_interested_in__c,c.scheduled_lead__r.receive_text_reminder__c,c.scheduled_lead__r.receive_auto_reminder__c, c.Scheduled_Lead__r.Reminder_Text__c, c.Scheduled_Lead__r.Reminder_Call__c, c.scheduled_account__r.receive_text_reminder__c,c.scheduled_account__r.receive_auto_reminder__c,  c.Scheduled_Account__r.Reminder_Text__c, c.Scheduled_Account__r.Reminder_Call__c, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__r.full_name__c,c.add_ons__c, c.isConsultScheudled__c, c.Admin_Notes__c, c.Scheduled_Lead__r.DateTime_Consult_Scheduled__c
								   FROM Consult_Inventory__c c
								   WHERE c.ID = :apt_id];
  	return my_apt;
  }

  public void create_new_room() {
  	Integer num_errors = 0;
  	new_room_issues = '';
  	if(new_room.Name==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You need to enter a value for the consult room name</span><br />';
  	}
  	else if(new_room.Name.trim().length()<5) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">Room Name must be at least 5 characters long</span><br />';
  	}
  	System.debug('New Room - Schedule Template : ' + new_room.schedule_template__c);
  	if(new_room.schedule_template__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must select a scheduling template for this room</span><br />';
  	}
  	if(new_room.Days_Built_Out__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter a value for the days built out</span><br />';
  	}
  	else if(new_room.Days_Built_Out__c>180) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You can currently only build the calendar out as far as 180 days.  Please contact Salesforce development team if this needs to be adjusted.</span><br />';
  	}
  	if(new_room.Sort_Order__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter a value for the sort order</span><br />';
  	}
  	else if(new_room.Sort_Order__c<0 || new_room.sort_order__c >9) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter a value between 0 and 9 for the sort order</span><br />';
  	}
  	if(num_errors==0) {
  		new_room.Center_Information__c = selected_center;
  		try {
  		  insert new_room;
  		  new_room_issues = '';
  		  main_view = 'consult_view';
  		  //create room inventory for the next 180 days
  		  if(new_room.Room_Type__c=='Manual')
  		    build_room_inventory(new_room,selected_date);
  		  else
  		    build_room_inventory(new_room,system.today());
  		}
  		catch (System.DmlException e) {
  			for (Integer i = 0; i < e.getNumDml(); i++) {
          new_room_issues += e.getDmlMessage(i) + '<br />';
        }
  		}
  	}
  	else
  	  new_room_issues += '<br />';
  }

  public void display_printview() {
  	main_view='print_view';
  	modal_display = false;
  }

  public String getformatted_sdate() {
  	Datetime sdate = datetime.newinstance(selected_date.year(),selected_date.month(),selected_date.day(),1,10,0);
  	return sdate.format('M/dd/yyyy');
  }

  public void update_consult_room() {
  	Integer num_errors = 0;
  	new_room_issues = '';
  	Consult_Rooms__c old_room = [select days_built_out__c from Consult_Rooms__c where id =: new_room.id];
  	if(new_room.Name==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You need to enter a value for the consult room name</span><br />';
  	}
  	else if(new_room.Name.trim().length()<5) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">Room Name must be at least 5 characters long</span><br />';
  	}
  	if(new_room.schedule_template__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must select a scheduling template for this room</span><br />';
  	}
  	if(new_room.Days_Built_Out__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter a value for the days built out</span><br />';
  	}
  	else if(new_room.Days_Built_Out__c>180) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You can currently only build the calendar out as far as 180 days.  Please contact Salesforce development team if this needs to be adjusted.</span><br />';
  	}
  	if(new_room.room_type__c=='Manual' && new_room.days_built_out__c>120) {
      num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">Manual Rooms can only be built out for 120 day right now.  Please contact Salesforce development team if this needs to be adjusted.</span><br />';
  	}
  	if(new_room.Sort_Order__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter a value for the sort order</span><br />';
  	}
  	else if(new_room.Sort_Order__c<0 || new_room.sort_order__c >9) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter a value between 0 and 9 for the sort order</span><br />';
  	}
  	if(num_errors==0) {
  		update new_room;
  		new_room_issues = '';
  		main_view = 'consult_view';
  		//if the schedule template changed - do something here?
  		//if days_built_out changed,  build some inventory here
      if(new_room.days_built_out__c<>old_room.days_built_out__c) {
  		  if(new_room.Room_Type__c=='Manual')
  		    build_room_inventory(new_room,selected_date);
  		  else
  		    build_room_inventory(new_room,system.today());
      }
      new_room_issues = '<span class="blank" style="color:blue;">Changes Saved</span>';
  	}
  	else
  	  new_room_issues += '<br />';
  }

  public void display_new_apt_form() {
	  main_view = 'new_apt_form';
	  Integer dow;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Monday')
		  dow = 1;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Tuesday')
		  dow = 2;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Wednesday')
		  dow = 3;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Thursday')
		  dow = 4;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Friday')
		  dow = 5;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Saturday')
		  dow = 6;
	  if(DateTime.newInstance(selected_date.year(),selected_date.month(),selected_date.day()).format('EEEE')=='Sunday')
		  dow = 7;
	  view_apt = new Consult_Inventory__c(Consult_Room__c = Apexpages.currentPage().getParameters().get('rid'), Apt_Date__c = selected_date, Start_Hour__c = Apexpages.currentPage().getParameters().get('shour'), Start_Minute__c = Apexpages.currentPage().getParameters().get('smin'), End_Hour__c = Apexpages.currentPage().getParameters().get('shour'), End_Minute__c = Apexpages.currentPage().getParameters().get('smin'), active__c = true,dow_int__c = dow);
	  if(getnetwork_center_user()) {
		  view_apt.Pre_Screen_Type__c='Any';
		  view_apt.color__c='Network Purple';
	  }
	  new_room = [select name, Room_Type__c from Consult_Rooms__c where id = :Apexpages.currentPage().getParameters().get('rid')];
	  new_room_issues = '';
	  adjust_end_time();
	  set_defaults_for_unconfirmed_room();
  }
			private void adjust_end_time() {
				Integer hours   = Integer.valueOf(view_apt.End_Hour__c);
				Integer minutes = Integer.valueOf(view_apt.End_Minute__c);
				if (new_room.Room_Type__c.toLowerCase() == 'unconfirmed') {
					view_apt.End_Hour__c   = String.valueOf( hours + ((minutes + 45)/60) );
					view_apt.End_Minute__c = String.valueOf(Math.mod(minutes + 45, 60));
				}
				else {view_apt.End_Hour__c = String.valueOf(hours + 1);}
			}
			private void set_defaults_for_unconfirmed_room() {
				if (new_room.Room_Type__c.toLowerCase() == 'unconfirmed') {
					view_apt.Pre_Screen_Type__c = 'Any';
					view_apt.Color__c = 'Light Red';
				}
			}

  public Integer apt_validation(Consult_Inventory__c test_apt) {
  	Integer num_errors = 0;
  	Integer shour, ehour, sminute, eminute;
  	try {
  		shour = Integer.valueOf(test_apt.Start_Hour__c);
  	}
  	catch (Exception e) {
//  		test_apt.Start_Hour__c.addError('Starting Hour must be a number between 0 and 23');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Starting Hour must be a number between 0 and 23</span><br />';
  		num_errors++;
  	}
  	if(shour<0 || shour>23) {
  //		test_apt.Start_Hour__c.addError('Starting Hour must be a number between 0 and 23');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Starting Hour must be a number between 0 and 23</span><br />';
  		num_errors++;
  	}
  	try {
  		sminute = Integer.valueOf(test_apt.Start_Minute__c);
  	}
  	catch (Exception e) {
  	//	test_apt.Starting_Minutes__c.addError('Starting Minutes must be a number between 0 and 59');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Starting Minutes must be a number between 0 and 59</span><br />';
  		num_errors++;
  	}
  	if(sminute<0 || sminute>59) {
  		//test_apt.Starting_Minutes__c.addError('Starting Minutes must be a number between 0 and 59');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Starting Minutes must be a number between 0 and 59</span><br />';
  		num_errors++;
  	}
  	try {
  		ehour = Integer.valueOf(test_apt.End_Hour__c);
  	}
  	catch (Exception e) {
  		//test_apt.Ending_Hour__c.addError('Ending Hour must be a number between 0 and 23');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Ending Hour must be a number between 0 and 23</span><br />';
  		num_errors++;
  	}
  	if(ehour<0 || ehour>23) {
  		//test_apt.Ending_Hour__c.addError('Ending Hour must be a number between 0 and 23');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Ending Hour must be a number between 0 and 23</span><br />';
  		num_errors++;
  	}
  	try {
  		eminute = Integer.valueOf(test_apt.End_Minute__c);
  	}
  	catch (Exception e) {
  		//test_apt.Ending_Minutes__c.addError('Ending Minutes must be a number between 0 and 59');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Ending Minutes must be a number between 0 and 59</span><br />';
  		num_errors++;
  	}
  	if(eminute<0 || eminute>59) {
  		//test_apt.Ending_Minutes__c.addError('Ending Minutes must be a number between 0 and 59');
  		new_room_issues += '<span class=\'blank\' style=\'color:red;\'>Ending Minutes must be a number between 0 and 59</span><br />';
  		num_errors++;
  	}
  	if(test_apt.Pre_Screen_Type__c==null) {
  	  //test_apt.Pre_Screen_Type__c.addError('You must select a Pre-Screen type');
  	  new_room_issues += '<span class=\'blank\' style=\'color:red;\'>You must select a Pre-Screen type</span><br />';
  	  num_errors++;
  	}
  	if(test_apt.Color__c==null) {
  	  //test_apt.Color_Code__c.addError('You must select a Color Code');
  	  new_room_issues += '<span class=\'blank\' style=\'color:red;\'>You must select a Color Code</span><br />';
  	  num_errors++;
  	}
  	if(num_errors==0) {
  	  Integer start_minutes = (shour * 60) + sminute;
  	  Integer end_minutes = (ehour * 60) + eminute;
  	  if(end_minutes < start_minutes) {
  	  	num_errors++;
  	  	new_room_issues += '<span class=\'blank\' style=\'color:red;\'>End Time must be greater than Start Time</span><br />';
  	  }
  	}
  	return num_errors;
  }

  public void create_new_aptblock() {
  	//holder
  	new_room_issues = '';
  	System.debug('New Apt : ' + view_apt);
  	Integer num_errors = apt_validation(view_apt);
  	if(num_errors==0 || Test.isRunningTest()) {
  		try {
  	    insert view_apt;
  	    Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, action__c = 'Created', notes__c = 'Appointment block was created');
  	    insert history;
  	    view_apt = new Consult_Inventory__c();
  	    new_room_issues = '';
  	    main_view = 'consult_view';
  		}
  		catch (Exception e) {
  	      new_room_issues += '<span class="blank" style="color:red;">' + e.getMessage() + '</span><br />';
  		}
  	}
  }

  public void display_room_form() {
  	main_view = 'room_form';
    new_room = new Consult_Rooms__c(days_built_out__c = 180, sort_order__c = 1,api_visible__c=true, infocision_sf_visible__c = true);
  	new_room_issues = '';
  }

  public void display_consults() {
  	main_view='consult_view';
  	modal_display = false;
  }

  public void modify_note_form() {
  	main_view = 'note_form';
  	new_note = [Select c.SystemModstamp, c.Note_Date__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Comment__c, c.consult_room__r.name From Consult_Room_Note__c c where id = :Apexpages.currentPage().getParameters().get('nnum')];
  	new_room_note_issues = '';
  }

  public boolean getdoc_exception() {
  	if(doc_exception==null) {
      Integer doc_count = [select count() from User where email = 'twang@clearchoice.com' and id = :userinfo.getUserId()];
      //Integer doc_count = [select count() from User where name = 'Chris McDowell' and id = :userinfo.getUserId()];
      if(doc_count>0)
        doc_exception = true;
      else
        doc_exception = false;
  	}
    return doc_exception;
  }

  public Boolean getdisplay_ca() {
  	if (display_ca == null) {
  		//modified by cm on 7/21/2014 - this definition is way out of date.  We have a checkbox on the user goals page
  		User u = [select center_pec__c,center_administrator__c from user where id = :Userinfo.getUserId()];
  		//modified by cm on 8/8/2014 - a further change.  PEC's will now have the same rights as FOA's.  Adding a check for a PEC profile here
  		Integer pec_count = [select count() from Profile where name in ('PEC - NoPScreen - No Dash','PEC - TPLAN','PEC - No Prescreen - PPF','PEC - PPF - NoPScreen - TPlan','PEC - PPF - No Prescreen','PEC - PFF - Application Date','Center Administrator','FOA','FOA - No Prescreen','FOA - No Prescreen - TPlan','Patient Education Consultant','PEC - Exam Center','PEC - Denver','PEC - Denver - FOA','PEC - No Prescreen','PEC_VisiblePrescreen','PEC - Multiple Centers','PEC - Multiple Centers No Prescreen','PEC - Red Rally','PEC - Red Rally No Prescreen','PEC - Extended Finance','PEC - Extended Finance no prescreen','PEC - Snap No Prescreen','PEC - Snap','PEC_MultipleCenters_VisiblePrescreen','PEC - Application Date') and id = :Userinfo.getProfileId()];
  		//System.debug('Display Seminar Count : ' + admin_count);
	    //if(admin_count>0 || Test.isRunningTest()) {
	    if (u.center_administrator__c == true || Test.isRunningTest() || pec_count > 0) {display_ca = true;}
	    else {display_ca = false;}
  	}
  	return display_ca;
  }

  public void change_center() {
  	System.debug('Center Change : ' + selected_center);
    selected_center_name = [select name,calendar_name__c from Center_information__c where id = :selected_center].name;
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	current_weather = getweather_info(selected_date);
  }

  public void display_months() {
  	calendar_view = 'months';
  }

  public void display_years() {
  	calendar_view = 'years';
  }

  public void modify_room_form() {
  	main_view = 'modify_room';
  	delete_reason = '';
  	delete_note = '';
  	mass_delete_reason = '';
  	mass_delete_note = '';
  	new_room = [Select c.infocision_sf_visible__c,c.sort_order__c,c.days_built_out__c, c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c,c.active__c,c.api_visible__c From Consult_Rooms__c c where id = :Apexpages.currentPage().getParameters().get('rnum')];
  	new_note = new Consult_Room_Note__c(Note_Date__c = selected_date, Consult_Room__c = new_room.id, comment__c = 'Enter note here');
  	end_note = new Consult_Room_Note__c(Note_Date__c = selected_date, Consult_Room__c = new_room.id, comment__c = 'Enter note here');
  	mass_start = new Consult_Room_Note__c(Note_Date__c = selected_date, Consult_Room__c = new_room.id, comment__c = 'Enter note here');
  	mass_end = new Consult_Room_Note__c(Note_Date__c = selected_date, Consult_Room__c = new_room.id, comment__c = 'Enter note her');
  	new_room_issues = '';
  	new_room_note_issues = '';
  	mass_clear_verified = false;
  	//check for an unconfirmed room in the center we're in
  	try {
  		mass_clear_unconfirmed = [select id from Consult_Rooms__c where center_information__c = :selected_center and room_type__c = 'Unconfirmed' limit 1];
  		mass_clear_check = true;
  		mass_clear_message = '';
  	}
  	catch (Exception e) {
  		mass_clear_message = '<span class="blank" style="color:red;">Error</span> - There is no unconfirmed column for this center. Mass apt clear feature will not be available until one is added.';
  		mass_clear_check = false;
  	}
  }

  public void change_mass_dates() {
  	mass_clear_message = '';
  	mass_clear_verified = false;
  }

  public void check_mass_clear() {
  	//check our dates
  	mass_clear_verified = true;
  	mass_clear_message = '';
  	if(mass_start.Note_Date__c < System.today()) {
  		mass_clear_verified = false;
  		mass_clear_message += '<span class="blank" style="color:red;">Error</span> - Start date must be on or after today<br />';
  	}
  	if(mass_end.Note_Date__c < System.today()) {
  		mass_clear_verified = false;
  		mass_clear_message += '<span class="blank" style="color:red;">Error</span> - End date must be on or after today<br />';
  	}
  	if(mass_end.Note_Date__c < mass_start.Note_Date__c) {
  		mass_clear_verified = false;
  		mass_clear_message += '<span class="blank" style="color:red;">Error</span> - End date must be greater than or equal to start date<br />';
  	}
  	if(mass_clear_verified) {
  	  //look at all of the apts in the range and return a message with the details
  	  Integer apt_count = [select count() from Consult_Inventory__c where consult_room__c = :new_room.id and apt_date__c >= :mass_start.note_date__c and apt_date__c <= :mass_end.note_date__c
  	    and (scheduled_lead__c != null or scheduled_account__c != null or scheduled_patient__c != null) and active__c = true];
  	  /*Integer block_count = [select count() from Consult_Inventory__c where consult_room__c = :new_room.id and apt_date__c >= mass_start.note_date__c and apt_date__c <= mass_end.note_date__c
  	    and active__c = true];*/
  	  mass_clear_message += 'There are ' + apt_count + ' apts between ' + String.valueof(mass_start.note_date__c).left(10) + ' and ' + string.valueof(mass_end.note_date__c).left(10) + ' that will be moved to the unconfirmed column.  Please click on confirm clear if you want to proceed with the process';
  	}
  }

  public void verify_mass_clear() {
  	//check to see if we have any appointments to move to the unconfirmed column
  	System.debug('Delete Reason : ' + mass_delete_reason);
  	if (String.isBlank(mass_delete_reason))
  	  mass_clear_message = '<span class="blank" style="color:red;">You must select a reason for the mass deletion in order to continue</span>';
  	else {
	  	Integer apt_count = [select count() from Consult_Inventory__c where consult_room__c = :new_room.id and apt_date__c >= :mass_start.note_date__c and apt_date__c <= :mass_end.note_date__c
	  	    and (scheduled_lead__c != null or scheduled_account__c != null or scheduled_patient__c != null) and active__c = true];
	  	Integer block_count = [select count() from Consult_Inventory__c where consult_room__c = :new_room.id and apt_date__c >= :mass_start.note_date__c and apt_date__c <= :mass_end.note_date__c
	  	    and active__c = true];
	  	//if we do,  then build the csv file and attach it to the center and move the appointments
	  	Attachment attachment = new Attachment();
	  	if(apt_count>0) {
	  	  String csv_out = 'Consult Room,Apt Date,Start Time,End Time,Patient Name,Initiative\n';
	  	  List<Consult_Inventory__c> open_apts = [select id,dow_int__c,pre_screen_type__c,color__c,consult_room__r.name,apt_date__c,start_hour__c,start_minute__c,end_hour__c,end_minute__c,scheduled_lead__r.name, Scheduled_Lead__r.LeadScore__c, Scheduled_Account__r.LeadScore__c, scheduled_account__r.name,special_initiative__c,scheduled_lead__c,scheduled_account__c,scheduled_patient__c, scheduled_patient__r.first_name__c,scheduled_patient__r.last_name__c
	  	    from Consult_Inventory__c
	  	    where consult_room__c = :new_room.id and apt_date__c >= :mass_start.note_date__c and apt_date__c <= :mass_end.note_date__c
	  	    and (scheduled_lead__c != null or scheduled_account__c != null or scheduled_patient__c != null) and active__c = true];
	  	  List<Apt_History__c> insert_hist = new List<Apt_History__c>();
	  	  List<Consult_Inventory__c> unconfirmed_apts = new List<Consult_Inventory__c>();
	  	  For(Consult_Inventory__c ci : open_apts) {
	  	    	String patient_name = '';
				String leadscore;
	  	    	if(ci.scheduled_lead__r.name != null) {
					patient_name = ci.scheduled_lead__r.name;
					leadscore = ci.scheduled_lead__r.leadscore__c;
				}
	  	    	else if(ci.scheduled_account__r.name != null) {
					patient_name = ci.scheduled_account__r.name;
					leadscore = ci.scheduled_account__r.leadscore__c;
				}
	  	    	else if(ci.scheduled_patient__c != null)
	  	    	  patient_name = ci.scheduled_patient__r.first_name__c + ' ' + ci.scheduled_patient__r.last_name__c;
	  	    	csv_out += ci.consult_room__r.name + ',' + ci.apt_date__c + ',' + ci.start_hour__c + ':' + ci.start_minute__c + ','
	  	    	  + ci.end_hour__c + ':' + ci.end_minute__c + ',' + patient_name + ',' + ci.special_initiative__c + '\n';
	  	    	Consult_Inventory__c clone_apt = new Consult_Inventory__c(Active__c = true, apt_date__c = ci.apt_date__c, color__c = ci.color__c,
	      			consult_room__c = mass_clear_unconfirmed.id, start_hour__c = ci.start_hour__c, start_minute__c = ci.start_minute__c, end_hour__c = ci.end_hour__c,
	      			end_minute__c = ci.end_minute__c, pre_screen_type__c = ci.pre_screen_type__c, dow_int__c = ci.dow_int__c, scheduled_lead__c = ci.scheduled_lead__c,
	      			scheduled_account__c = ci.scheduled_account__c, scheduled_patient__c = ci.scheduled_patient__c, Leadscore_At_Schedule_Time__c = leadscore);
	      	  unconfirmed_apts.add(clone_apt);
	      	  Apt_History__c history = new Apt_History__c(Consult_Inventory__c = ci.id, action__c = 'Mass Deleted', Notes__c = 'Appointment block was mass cleared. ' + mass_delete_note, delete_reason__c = mass_delete_reason);
	      	  insert_hist.add(history);
	      	  ci.scheduled_lead__c = null;
	  	    	ci.scheduled_account__c = null;
	  	    	ci.active__c = false;
	  	    }
	  	  update open_apts;
	  	  insert unconfirmed_apts;
	  	  insert insert_hist;
				attachment.Body = Blob.valueOf(csv_out);
				attachment.Name = 'Mass_Clear_' + String.valueof(mass_start.note_date__c).left(10) + '_to_' +
				String.valueof(mass_end.note_date__c).left(10) + '.csv';
				attachment.ParentId = selected_center;
				insert attachment;
	  	}
	  	//deactivate all of the remaining blocks
	  	List<Consult_Inventory__c> deactivate_list = [select id,active__c from Consult_Inventory__c where consult_room__c = :new_room.id and apt_date__c >= :mass_start.note_date__c and apt_date__c <= :mass_end.note_date__c
	  	    and active__c = true];
	  	List<Apt_History__c> insert_hist = new List<Apt_History__c>();
	  	for(Consult_Inventory__c ci : deactivate_list) {
	  		ci.active__c = false;
	  		Apt_History__c history = new Apt_History__c(Consult_Inventory__c = ci.id, action__c = 'Mass Deleted', Notes__c = 'Appointment block was mass cleared. ' + mass_delete_note, delete_reason__c = mass_delete_reason);
	      insert_hist.add(history);
	  	}
	  	update deactivate_list;
	  	insert insert_hist;
	  	//return results
	  	mass_clear_message = '<span class="blank" style="color:blue;font-weight:bold;">Mass Clear is complete</span><br />' +
	  	  '<span style="padding-left:50px;">' + apt_count + ' apts were moved to the unconfirmed column</span><br />' +
	  	  '<span style="padding-left:50px;">' + block_count + ' apts were deactivated</span><br />';
	  	if(apt_count>0)
	  	  mass_clear_message += '<a style="color:blue;font-weight:bold;" href="' + URL.getSalesforceBaseUrl().toExternalForm()  + '/' + attachment.id + '">Download unconfirmed transfer list</a>';
	  	mass_clear_verified = false;
  	}
  }

  public void modify_room_note() {
  	if(new_note.comment__c==null)
  	  delete new_note;
  	else if(new_note.comment__c=='')
  	  delete new_note;
  	else
  		update new_note;
    new_room_note_issues = '';
  	main_view = 'consult_view';
  	new_note = new Consult_Room_Note__c();
  }

  public void add_room_note() {
  	Integer num_errors = 0;
  	new_room_note_issues = '';
  	if(new_note.note_date__c>end_note.Note_Date__c) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">End Date must be after the start date for the note</span><br />';
  	}
  	if(new_note.comment__c==null) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">You must enter something into the note field</span><br />';
  	}
  	else if(new_note.comment__c.trim().length()<=3) {
  		num_errors++;
  		new_room_issues += '<span class="blank" style="color:red;">Note must be more than three characters long</span><br />';
  	}
  	if(num_errors==0) {
  		try {
  			List<Consult_Room_Note__c> insert_notes = new List<Consult_Room_Note__c>();
  			Date cnt_date = new_note.note_date__c;
  			while(cnt_date <= end_note.Note_Date__c) {
  				Consult_Room_Note__c my_note = new Consult_Room_Note__c(Comment__c = new_note.comment__c, Consult_Room__c= new_note.consult_room__c, Note_Date__c = cnt_date);
  				insert_notes.add(my_note);
  				cnt_date = cnt_date.adddays(1);
  			}
  			if(insert_notes.size()>0)
  			  insert insert_notes;
	  		new_room_note_issues = '';
	  	  main_view = 'consult_view';
  		}
  		catch (System.DmlException e) {
  			for (Integer i = 0; i < e.getNumDml(); i++) {
          new_room_note_issues += e.getDmlMessage(i) + '<br />';
        }
  		}
  	}
  	else
  	  new_room_issues += '<br />';
  }

  public void change_calendar_day() {
  	//troubleshoot_msg = 'MDAY : ' + Apexpages.currentPage().getParameters().get('mday');
  	//System.debug('MDAY : ' + Apexpages.currentPage().getParameters().get('mday'));
  	selected_date = Date.newInstance(selected_date.year(), selected_date.month(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mday')));
  	//troubleshoot_msg += '<br />Change Date : ' + selected_date;
  	//System.debug('Change Date : ' + selected_date);
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	current_weather = getweather_info(selected_date);
  }


  public void change_month() {
  	//check to see if the current date value is greater than the end date of the selected month,  if so swap
  	Date last_day = Date.newInstance(selected_date.year(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mnum')), 1);
  	last_day = last_day.addMonths(1).addDays(-1);
  	if(last_day.day()<selected_date.day())
  	  selected_date = last_day;
  	else
  	  selected_date = Date.newInstance(selected_date.year(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mnum')), selected_date.day());
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	current_weather = getweather_info(selected_date);
  }

  public void add_month() {
  	selected_date = selected_date.addMonths(1);
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	current_weather = getweather_info(selected_date);
  }

  public void subtract_month() {
  	selected_date = selected_date.addMonths(-1);
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	current_weather = getweather_info(selected_date);
  }

  public void change_calendar_year() {
  	Date last_day = Date.newInstance(Integer.valueOf(Apexpages.currentPage().getParameters().get('cyear')), selected_date.month(), 1);
  	last_day = last_day.addMonths(1).addDays(-1);
  	if(last_day.day()<selected_date.day())
  	  selected_date = last_day;
  	else
  	  selected_date = Date.newInstance(Integer.valueOf(Apexpages.currentPage().getParameters().get('cyear')), selected_date.month(), selected_date.day());
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	current_weather = getweather_info(selected_date);
  }

  public void deactivate_room() {
  	new_room_issues = '';
  	if(getnum_futureapts()>0)
  	  new_room_issues = '<span class="blank" style="color:red;">There is an active apt block on the calendar.  Please remove it and try again</span><br />';
    else {
  	  new_room.active__c = false;
  	  try {
  	    update new_room;
  	    main_view = 'consult_view';
  	  }
  	  catch (System.DmlException e) {
	  	  for (Integer i = 0; i < e.getNumDml(); i++) {
	        new_room_issues += e.getDmlMessage(i) + '<br />';
	      }
	    }
    }
  }

  public void clear_dayapts() {
  	System.debug('Delete Reason : ' + delete_reason);
  	if(delete_reason==null)
  	  new_room_issues = '<span class="blank" style="color:red;">You must select a reason for the deletion in order to continue</span>';
  	else if(delete_reason=='')
  		new_room_issues = '<span class="blank" style="color:red;">You must select a reason for the deletion in order to continue</span>';
  	else {
  	  new_room_issues = '';
	  	if(getnum_dayapt()>0)
	  	  new_room_issues = '<span class="blank" style="color:red;">There is an active consult on the schedule.  Please reschedule it and try again</span><br />';
	    else {
	  	  list<Consult_Inventory__c> update_list = new list<Consult_Inventory__c>();
	  	  list<Apt_History__c> insert_hist = new list<Apt_History__c>();
	  	  for(Consult_Inventory__c my_ci : [select id,active__c from Consult_Inventory__c c where c.apt_date__c = :selected_date and c.consult_room__c = :new_room.id and c.active__c = true]) {
	        my_ci.active__c = false;
	        update_list.add(my_ci);
	        Apt_History__c history = new Apt_History__c(Consult_Inventory__c = my_ci.id, action__c = 'Deleted', Notes__c = 'Appointment block was deleted. ' + delete_note, delete_reason__c = delete_reason);
		  		insert_hist.add(history);
	  	  }
	  	  try {
	  	    update update_list;
	  	    insert insert_hist;
	  	    main_view = 'consult_view';
	  	  }
	  	  catch (System.DmlException e) {
		  	  for (Integer i = 0; i < e.getNumDml(); i++) {
		        new_room_issues += e.getDmlMessage(i) + '<br />';
		      }
		    }
	    }
  	}
  }

  public List<Selectoption> getcenter_list() {
  	List<Selectoption> centers = new List<Selectoption>();
  	//should probably replace the filter with a control checkbox at some point.  I don't want to manage this in the long run
  	//String center_query = 'select id,name,calendar_name__c from Center_Information__c where name not in (\'Chicago Deerfield/Northbrook\') order by name';
  	String center_query = 'select id,name,calendar_name__c from Center_Information__c where allow_center_selection__c = true order by name';
  	if(getdoc_exception())
  	  center_query = 'select id,name,calendar_name__c from Center_Information__c where name in (\'Chicago\',\'Chicago Naperville\',\'Chicago Schaumburg\') and allow_center_selection__c = true order by name';
  	for(Center_Information__c my_center : database.query(center_query)) {
  	  if(my_center.calendar_name__c!=null)
        centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
      else
        centers.add(new Selectoption(my_center.id,my_center.name));
  	}
  	return centers;
  }

  public String getCenterName() {
  	return [select name from Center_Information__c where id = :selected_center].Name;
  }

  public String getapt_starttime() {
  	String suffix = '';
  	String time_string = '';
    Integer chours = view_apt.start_hour_int__c.intvalue();
    Integer cminutes = view_apt.start_minute_int__c.intvalue();
		if(chours > 12) {
 			suffix = 'PM';
 			chours -= 12;
 		}
  	else if(chours==12)
  	  suffix = 'PM';
  	else
  	  suffix = 'AM';
  	time_string = chours + ':';
  	if(cminutes < 10)
  	  time_string += '0';
  	time_string += cminutes + ' ' + suffix;
  	return time_string;
  }

  public String getapt_endtime() {
  	Integer sh = integer.valueof(view_apt.end_hour__c);
    String suffix = '';
  	if(sh>12) {
  	  sh = sh - 12;
  		suffix = 'PM';
    }
  	else if(sh==12)
  	  suffix = 'PM';
  	else
  	  suffix = 'AM';
  	if(view_apt.end_minute__c=='0')
  	  return sh + ':00 ' + suffix;
  	else
  	  return sh + ':' + view_apt.end_minute__c + ' ' + suffix;
  }

  public String getschedule_warnings() {
  	String my_warning = '';
  	List<Consult_Inventory__c> current_consult = new List<Consult_Inventory__c>{};
  	if(scheduling_lead!=null)
  	  current_consult = [select c.apt_date__c,c.consult_room__r.name,c.consult_room__r.center_information__r.name,c.start_hour_int__c,c.start_minute_int__c from Consult_Inventory__c c where c.scheduled_lead__c = :scheduling_lead.id and c.apt_date__c >= today and c.active__c = true and c.consult_show_status__c=null];
  	else if(scheduling_account!=null)
  	  current_consult = [select c.apt_date__c,c.consult_room__r.name,c.consult_room__r.center_information__r.name,c.start_hour_int__c,c.start_minute_int__c from Consult_Inventory__c c where c.scheduled_account__c = :scheduling_account.id and c.apt_date__c >= today and c.active__c = true and c.consult_show_status__c=null];
  	else if(scheduling_patient!=null)
  	  current_consult = [select c.apt_date__c,c.consult_room__r.name,c.consult_room__r.center_information__r.name,c.start_hour_int__c,c.start_minute_int__c from Consult_Inventory__c c where c.scheduled_patient__c = :scheduling_patient.id and c.apt_date__c >= today and c.active__c = true and c.consult_show_status__c=null];
  	//don't display a warning for private practice patients at this point.  They can be in more than 1 block
  	if(current_consult.size()>0 && scheduling_patient==null) {
  		String prefix;
  		Integer chours = current_consult[0].start_hour_int__c.intvalue();
  		Integer cminutes = current_consult[0].start_minute_int__c.intvalue();
  		if(chours > 12) {
  			prefix = 'PM';
  			chours -= 12;
  		}
  		else if(chours==12)
  		  prefix = 'PM';
  		else
  		  prefix = 'AM';
  		String rlabel = chours + ':';
  		if(cminutes < 10)
  		  rlabel += '0';
  		rlabel += cminutes + ' ' + prefix;
  		my_warning += '<span style="font-weight:bold;display:block;color:red;padding-top:5px;">--- WARNING ---</span>Patient is already scheduled for an appointment : <br /><br /><span style="color:black;">' + current_consult[0].consult_room__r.center_information__r.name + '<br />' + current_consult[0].consult_room__r.name + '<br />' + current_consult[0].apt_date__c.month() + '/'  + current_consult[0].apt_date__c.day() + '/' + current_consult[0].apt_date__c.year() + ' @ ' + rlabel + '</span><br /><br />You will not be able to schedule this consult until the existing appointment has been removed';
  	}
  	return my_warning;
  }

  public Integer getnum_dayapt() {
  	return [select count() from Consult_Inventory__c c where c.apt_date__c = :selected_date and c.consult_room__c = :new_room.id and (c.scheduled_lead__c!=null or c.scheduled_account__c!=null or c.scheduled_patient__c!=null)];
  }

  public Integer getnum_futureapts() {
  	return [select count() from Consult_Inventory__c c where c.apt_date__c >= today and c.consult_room__c = :new_room.id and c.active__c = true];
  }

  // public Boolean getallow_seminar_reserve() {
  // 	//System.Debug('Reserve check : ' + display_seminar);
  // 	if(view_apt.scheduled_lead__r.id==null && view_apt.scheduled_account__r.id==null && view_apt.scheduled_patient__c==null && display_seminar && view_apt.pre_screen_type__c=='Any')
  // 	  return true;
  // 	else
  // 	  return false;
  // }
  //
  // public Boolean getallow_seminar_unreserve() {
  // 	//System.Debug('Reserve check : ' + display_seminar);
  // 	if(display_seminar && view_apt.pre_screen_type__c=='Seminar')
  // 	  return true;
  // 	else
  // 	  return false;
  // }

  public Boolean getallow_reschedule() {
  	Boolean reschedule;
  	//block if we are currently scheduling someone and it is NOT the person scheduled to this block
  	if(scheduling_lead!=null) {
  		if(scheduling_lead.id==view_apt.scheduled_lead__c)
  		  //7/21/2014 - modified by cm - CA's will only be able to reschedule Gold leads now
  	      if(display_ca && scheduling_lead.leadscore__c!='Gold')
  	        reschedule = false;
  	      else
  		    reschedule = true;
  		else
  		  reschedule = false;
  	}
  	else if(scheduling_account!=null) {
  		if(scheduling_account.id==view_apt.scheduled_account__c)
  		  reschedule = true;
  		else
  		  reschedule = false;
  	}
    else if(scheduling_patient!=null) {
      if(scheduling_patient.id==view_apt.scheduled_patient__c)
        reschedule = true;
      else
        reschedule = false;
    }
  	else {
  		if(view_apt.scheduled_lead__r.id==null && view_apt.scheduled_account__r.id==null && view_apt.scheduled_patient__r.id==null)
  		  reschedule = false;
  		else {
  		  if(view_apt.consult_room__r.room_type__c=='Practice') {
  		  	//if it's a practcie room,  and they can see it,  then allow reschedule
  		  	reschedule = true;
  		  }
  		  else {
	  		  //7/21/2014 - modified by cm - CA's will only be able to reschedule Gold leads (and second consults) now
	  		  String leadscore = '';
	  		  if(view_apt.scheduled_lead__r.id!=null)
	  		    leadscore = view_apt.scheduled_lead__r.leadscore__c;
	  		  else if(view_apt.scheduled_account__r.id!=null)
	  		    //rigging this so consults will always pass here
	  		    leadscore = 'Gold';
	  	      if(display_ca && leadscore!='Gold')
	  	        reschedule = false;
	  	      else
	  		    reschedule = true;
  		  }
  		}
  	}
  	//make sure the show status has not been changed
  	if(reschedule && view_apt.consult_show_status__c<>null)
  	  reschedule = false;
  	return reschedule;
  }

  public Boolean getallow_cancel() {
  	Boolean cancel;
  	//currently scheduling someone,  cancel is disabled for now
  	if(scheduling_lead!=null) {
  		if(scheduling_lead.id==view_apt.scheduled_lead__c) {
  		  //7/21/2014 - modified by cm - CA's will only be able to cancel Gold leads now
  	      if(display_ca && scheduling_lead.leadscore__c!='Gold')
  	        cancel = false;
  	      else
  		    cancel = true;
  		}
  		else
  		  cancel = false;
  	}
  	else if(scheduling_account!=null) {
  		if(scheduling_account.id==view_apt.scheduled_account__c)
  	      cancel = true;
  		else
  		  cancel = false;
  	}
  	else if(scheduling_patient!=null) {
  	  if(scheduling_patient.id==view_apt.scheduled_patient__c)
  	    cancel = true;
  	  else
  	    cancel = false;
  	}
  	else {
  		if(view_apt.scheduled_lead__r.id==null && view_apt.scheduled_account__r.id==null && view_apt.scheduled_patient__r.id==null)
  		  cancel = false;
  		else {
  		  if(view_apt.consult_room__r.room_type__c=='Practice') {
  		  	//if it's a practcie room,  and they can see it,  then allow cancel
  		  	cancel = true;
  		  }
  		  else {
	  		  //7/21/2014 - modified by cm - CA's will only be able to schedule Gold leads (and second consults) now
	  		  String leadscore = '';
	  		  if(view_apt.scheduled_lead__r.id!=null)
	  		    leadscore = view_apt.scheduled_lead__r.leadscore__c;
	  		  else if(view_apt.scheduled_account__r.id!=null)
	  		    //rigging this so consults will always pass here
	  		    leadscore = 'Gold';
	  	      if(display_ca && leadscore!='Gold')
	  	        cancel = false;
	  	      else
	  		    cancel = true;
  		  }
  		}
  	}
  	//make sure the show status has not been changed
  	if(cancel  && view_apt.consult_show_status__c<>null)
  	  cancel = false;
  	return cancel;
  }

  public Boolean getallow_history() {
  	Boolean view_hist;
  	if(modal_type == 'apt_view') {
  	  if (display_cc) {view_hist = false;}
  	  else            {view_hist = true;}
  	}
  	else
  	  view_hist = false;
  	return view_hist;
  }

  public Boolean getallow_delete() {
  	Boolean allow_delete;
  	if(view_apt.scheduled_lead__r.id==null && view_apt.scheduled_account__r.id==null && view_apt.scheduled_patient__r.id==null) {
  	  if(view_apt.consult_room__r.room_type__c=='Practice' && display_practice)
  	    allow_delete = true;
  	  else if(display_cc || display_ca)
		allow_delete = false;
  	  else
  		allow_delete = true;
  	}
  	else
  	  allow_delete = false;
  	if(allow_delete) {
  	  Integer i = check_for_other_hold();
  	  if(i>0)
  	    allow_delete = false;
  	}
  	return allow_delete;
  }

  public Boolean getallow_remove_hold() {
  	Boolean allow_remove;
  	if(check_for_active_hold()>0)
  	  //if it's their hold,  allow them to remove it.
  	  if((display_cc || display_ca) && check_for_other_hold()<>0)
  	    allow_remove = false;
  	  else
  	    allow_remove = true;
  	else
  	  allow_remove = false;
  	return allow_remove;
  }

  public Integer check_for_other_hold() {
  	Integer h = 0;
  	System.debug('Hold Check : ' + h);
  	for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :view_apt.id and active_hold__c = true and hold_by__c <> :Userinfo.getuserid() ]) {
  		//see if the hold_time is less than 5 minutes old
  		Datetime h_end_time = ch.hold_time__c;
  		//h_end_time = h_end_time.addMinutes(5);
  		h_end_time = h_end_time.addHours(2);
  		if(System.now()<h_end_time) {
  		  h++;
  		  hold_message = 'Block Held by : ' + ch.hold_by__r.name + '.<br />Hold will be released at : <br />' + h_end_time.format('M/dd/yyyy hh:mm:ss a') ;
  		}
  		//else {
  			//have to move this elsewhere due to security restrictions
  			/*ch.active_hold__c = false;
  			try {
  			  update ch;
  			}
  			catch (Exception e) {
  			}*/
  		//}
  	}
  	System.debug('Hold Check : ' + h);
  	return h;
  }

  public Integer check_for_active_hold() {
  	Integer h = 0;
  	System.debug('Hold Check : ' + h);
  	for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :view_apt.id and active_hold__c = true ]) {
  		//see if the hold_time is less than 5 minutes old
  		Datetime h_end_time = ch.hold_time__c;
  		//h_end_time = h_end_time.addMinutes(5);
  		h_end_time = h_end_time.addHours(2);
  		if(System.now()<h_end_time) {
  		  h++;
  		  hold_message = 'Block Held by : ' + ch.hold_by__r.name + '.<br />Hold will be released at : <br />' + h_end_time.format('M/dd/yyyy hh:mm:ss a') ;
  		}
  		//else {
  			//have to move this elsewhere due to security restrictions
  			/*ch.active_hold__c = false;
  			try {
  			  update ch;
  			}
  			catch (Exception e) {
  			}*/
  		//}
  	}
  	System.debug('Hold Check : ' + h);
  	return h;
  }

  public Boolean getallow_clone() {
  	//verify we have a blue or red presecreen patient in the consult inventory block
  	Boolean clone = true;
  	/*if(view_apt.scheduled_lead__c!=null)
  	  if(view_apt.scheduled_lead__r.leadscore__c!='Red' && view_apt.scheduled_lead__r.leadscore__c!='Blue (No Hit)') {
  		//if(view_apt.scheduled_lead__r.pre_screen__c!='Red' && view_apt.scheduled_lead__r.pre_screen__c!='Blue (No Hit)') {
  		  clone = false;
  		  //System.debug('Clone disabled because the lead was not a blue or red');
  		}
  	else if(view_apt.scheduled_account__c!=null)
  		if(view_apt.scheduled_account__r.pre_screen__c!='Red' && view_apt.scheduled_account__r.pre_screen__c!='Blue (No Hit)') {
  		  clone = false;
  		  //System.debug('Clone disabled because the account was not a blue or red');
  		}*/
    if(view_apt.scheduled_lead__c==null && view_apt.scheduled_account__c==null)
      clone = false;
    else if(view_apt.leadscore_at_schedule_time__c!='Red' && view_apt.leadscore_at_schedule_time__c!='Blue (No Hit)' && view_apt.leadscore_at_schedule_time__c!='PO Box' && view_apt.leadscore_at_schedule_time__c!='Insufficient Information' && view_apt.leadscore_at_schedule_time__c!='Not Checked')
      clone = false;
    /*else {
      clone = false;
      //System.debug('Clone disabled because their is nothing scheduled in this block');
    }*/
    if(clone) {
   	  //check to make sure we don't have 2 block in this time slot
      Integer apt_block_cnt = [select count() from Consult_Inventory__c where consult_room__c = :view_apt.consult_room__c and
        start_hour__c = :view_apt.start_hour__c and start_minute__c = :view_apt.start_minute__c and end_hour__c = :view_apt.end_hour__c
        and end_minute__c = :view_apt.end_minute__c and apt_date__c = :view_apt.apt_date__c and active__c = true];
      if(apt_block_cnt>1) {
        clone = false;
        //System.debug('Clone disabled because the slot already had two blocks in it');
      }
      if(view_apt.apt_date__c < System.today()) {
        clone = false;
        //System.debug('Clone disabled because the appointment was in the past');
      }
    }
    if(clone) {
    	System.debug('Clone Check : ' + clone);
    	//verify that the center is Atlanta
    	Integer center_count = [select count() from Center_Information__c where name in ('Austin','Kansas City','Phoenix','Portland','Washington Tysons Corner') and id = :selected_center ];
    	//2013-05-20 CM - removing Minneapolis per a help desk ticket from Meridith
    	//Integer minn_count = [select count() from Center_Information__c where name in ('Minneapolis') and id = :selected_center ];
    	Integer atlanta_count = [select count() from Center_Information__c where name in ('Atlanta') and id = :selected_center ];
    	//Date cutoff = date.newinstance(2013,2,11);
    	Date atlanta_cutoff = date.newinstance(2013,3,11);
    	//Center_Information__c ci = [select name,id from Center_Information__c ci where id = :selected_center];
    	System.debug('Clone Check  Center count : ' + center_count);
    	System.debug('Clone Check  Atlanta count : ' + atlanta_count);
    	//if(center_count==0 && atlanta_count==0 && minn_count==0)
    	if(center_count==0 && atlanta_count==0)
    	  clone = false;
    	//else if(alt_count>0 && view_apt.apt_date__c >= cutoff)
    	  //clone = false;
    	else if(atlanta_count>0 && view_apt.apt_date__c >= atlanta_cutoff)
    	  clone = false;
    	//else if(minn_count>0 && view_apt.Start_Hour_Int__c > 12)
    	  //clone = false;
    }
    //2012-01-22 per Meridith
    if(view_apt.consult_room__r.room_type__c!='Normal')
      clone = false;
    return clone;
  }

  public Boolean getallow_hold() {
  	Boolean hold = true;
  	//make sure the lead does not have an active consult on the calendar
  	Integer i = 0;
  	String schedule_pre_screen;
  	i += check_for_active_hold();
  	if(i>0)
  	  hold = false;
  	else {
	  	//check the days between today and the selected date
	  	Date tdate = System.today();
	    Integer days_diff = tdate.daysBetween(view_apt.apt_date__c);
	  	//if days between is negative,  then a hold is unnecessary
	    if(days_diff<0)
	      hold = false;
    }
  	if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null || view_apt.scheduled_patient__c!=null)
  	  hold = false;
  	return hold;
  }

  public String getsd_sched_blocked() {
  	return '<span style=color:red;">SD Sched not allowed for this center</span>';
  }

  public Boolean getallow_callback_consult() {
  	Boolean schedule;
  	//make sure we have an active scheduling lead
  	if(scheduling_lead==null && scheduling_account==null)
  	  schedule = false;
  	//option is only available for a converted lead - we might also add a days converted filter in the future.
  	else if (scheduling_lead!=null)
  	  schedule = false;
  	else {
	  	//make sure the lead does not have an active consult on the calendar
	  	Integer i;
	  	Integer previous_consults;
        if(scheduling_account!=null) {
	  		//ignore apts where the show status has been changed
	  	  i = [select count() from Consult_Inventory__c c where c.scheduled_account__c = :scheduling_account.id and c.apt_date__c >= today and active__c = true and consult_show_status__c=null];
	  	  //adding a check to make sure we have a consult for this patient with an arrival time OR the record is from prior to consult inventory rollout - 8/1/2012
	  	  previous_consults = [select count() from Consult_Inventory__c c where (c.scheduled_account__c = :scheduling_account.id or c.scheduled_lead__r.convertedaccountid = :scheduling_account.id) and c.arrival_time__c != null];
	  	}
	  	i += check_for_other_hold();
	  	if(i>0)
	  	  schedule = false;
	  	else
		  schedule = true;
		System.debug('Previous Consults ' + previous_consults + ' Created Date ' + scheduling_account.createddate);
		Datetime consult_cutoff = Datetime.newinstance(2012,8,1,0,0,0);
		if(previous_consults==0 && scheduling_account.createddate > consult_cutoff)
		  schedule = false;
  	}
  	if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
  	  schedule = false;
  	Integer callback_count = [select count() from Profile where name  in ('CC Administrator','CC Administrator Development Tester','CC Schedule Admin','Outbound Call Center Agent','System Administrator', 'Call Center Agent Lead', 'Call Center Admin') and id = :Userinfo.getProfileId()];
  	if(schedule && callback_count>0)
  	  return true;
  	else
  	  return false;
  }

  public Boolean getallow_scheduling() {
  	Boolean schedule;
  	String schedule_pre_screen = '';
  	//make sure we have an active scheduling lead
  	if(scheduling_lead==null && scheduling_account==null && scheduling_patient==null)
  	  schedule = false;
  	else {
  	  Integer i = 0;
      if(view_apt.consult_room__r.room_type__c=='Practice') {
      	//only rules for a practice room,  are that we don't have a hold on the block
      	i += check_for_other_hold();
      	if(i>0)
      	  schedule = false;
      	else
      	  schedule = true;
      }
      else {
	  	//make sure the lead does not have an active consult on the calendar
	  	if(scheduling_lead!=null) {
	  		//ignore apts where the show status has been changed
	  	  i = [select count() from Consult_Inventory__c c where c.scheduled_lead__c = :scheduling_lead.id and c.apt_date__c >= today and active__c = true and consult_show_status__c=null];
	  	  //schedule_pre_screen = scheduling_lead.pre_screen__c;
	  	  schedule_pre_screen = scheduling_lead.leadscore__c;
	  	}
	  	else if(scheduling_account!=null) {
	  		//ignore apts where the show status has been changed
	  	  i = [select count() from Consult_Inventory__c c where c.scheduled_account__c = :scheduling_account.id and c.apt_date__c >= today and active__c = true and consult_show_status__c=null];
	  	  schedule_pre_screen = scheduling_account.pre_screen__c;
	  	}
	  	//always block when scheduling a private practice patient and the room is not of type practice (for now at least)
	  	else if(scheduling_patient!=null) {
	  	  i = 1;
	  	}
	  	i += check_for_other_hold();
	  	if(i>0)
	  	  schedule = false;
	  	else {
		  	//check the days between today and the selected date
		  	Date tdate = System.today();
		    Integer days_diff = tdate.daysBetween(view_apt.apt_date__c);
		  	//if days between is negative,  then scheduling is not allowed (looking in the past) unless it's an admin
		    if(days_diff<0) {
		    	Integer confirmation_count = [select count() from Profile where name  in ('Outbound Call Center Jumpstart','Outbound Call Center Agent Test','Outbound Call Center Agent') and id = :Userinfo.getProfileId()];
		    	if(display_admin || confirmation_count>0)
		    	  schedule = true;
		    	else
		          schedule = false;
		    }
		    else if(view_apt.Pre_Screen_Type__c=='Seminar') {
		  	  if(display_seminar || getdisplay_ca())
		  	    schedule = true;
		  	  else
		  	    schedule = false;
		  	}
		  	else if(view_apt.Pre_Screen_Type__c=='Red/Blue Only') {
		  	  if(schedule_pre_screen!='Red' && schedule_pre_screen!='Blue (No Hit)' && schedule_pre_screen!='PO Box' && schedule_pre_screen!='Insufficient Information' && schedule_pre_screen!='Website Down-No Prescreen' && schedule_pre_screen!='Not Checked')
		  	    schedule = false;
		  	  else
		  	    schedule = true;
		  	}
		  	//if days is between 0 and 3,  then all Any and Green/Yellow blocks are open.  Green/Yellow Only must still be looked at
		  	else if(days_diff>=0 && days_diff<=5) {
		  	  if(view_apt.Pre_Screen_Type__c=='Green/Yellow Only' && (schedule_pre_screen!='Green' && schedule_pre_screen!='Yellow' && schedule_pre_screen!='Gold'))
		  		  schedule = false;
		  		else
		  	    schedule = true;
		  	}
		  	else {
		  	  //if days is greater than 3,  then we need to look at the pre-screen of the lead and the apt block
		  		if(view_apt.Pre_Screen_Type__c=='Any')
		  		  schedule = true;
		  		else if(view_apt.Pre_Screen_Type__c=='Green/Yellow' && (schedule_pre_screen=='Green' || schedule_pre_screen=='Yellow' || schedule_pre_screen=='Gold'))
		  		  schedule = true;
		  		else if((view_apt.Pre_Screen_Type__c=='Green/Yellow Only')  && (schedule_pre_screen=='Green' || schedule_pre_screen=='Yellow' || schedule_pre_screen=='Gold'))
		  		  schedule = true;
		  		else
		  		  schedule = false;
		  	}
	    }
	    //7/21/2014 - modified by cm - CA's will only be able to schedule Gold leads and second consults now
	    if(getdisplay_ca() && schedule_pre_screen!='Gold' && scheduling_lead!=null)
  	      schedule = false;
      }
  	}
  	if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null || view_apt.scheduled_patient__c!=null)
  	  schedule = false;
  	return schedule;
  }

  public List<SelectOption> getTemplatelist() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','Select One'));
    for(Schedule_Templates__c template :[select id,name from Schedule_Templates__c where active__c = true order by name]) {
      options.add(new SelectOption(template.id,template.name));
    }
    return options;
  }

  public List<List<String>> getmonth_list() {
  	List<String> month_names = new List<String>();
  	List<List<String>> month_rows = new List<List<String>>();
  	System.debug('Selected Date : ' + selected_date);
  	for(Integer i=1;i<=12;i++) {
  		Datetime month_start = Datetime.newInstance(selected_date.year(), i, 1,0,0,0);
  		System.debug('Month Start : ' + month_start);
  		month_names.add(month_start.format('MMM'));
  		if(math.mod(i,4) == 0) {
  			month_rows.add(month_names);
  			month_names = new List<String>();
  		}
  	}
  	return month_rows;
  }

  public List<List<Integer>> getyear_list() {
  	List<Integer> year_values = new List<Integer>();
  	List<List<Integer>> year_rows = new List<List<Integer>>();
    Date today_date = System.today();
    Integer end_limit = 2024;
    if(today_date.year() > 2024)
      end_limit = today_date.year();
  	for(Integer i=2011;i<=end_limit;i++) {
  		year_values.add(i);
  		if(year_values.size()==4) {
  			year_rows.add(year_values);
  			year_values = new List<Integer>();
  		}
  	}
  	if(year_values.size()>0)
  	  year_rows.add(year_values);
  	return year_rows;
  }

  public Integer getselected_year() {
  	return selected_date.year();
  }

  public String getselected_monthname() {
  	Datetime my_datetime = Datetime.newInstance(selected_date.year(),selected_date.month(),selected_date.day());
  	return my_datetime.format('MMM');
  }

  public CalendarMonth getcmonth() {return cmonth;}

  public class Consult_Apts {
  	public Consult_Inventory__c capt {get; set;}
  	public Integer crowspan {get;set;}
  	public Integer cheight {get;set;}
  	public String lheight {get;set;}
  	public Integer ctop {get; set;}
  	public String fontsize {get; set;}
  	public String cclass {get;set;}
  	public String lead_pre_screen {get; set;}
  	public Boolean display_seminar {get; set;}
  	public Boolean display_prescreen {get; set;}
	public String[] note_statuses {get; private set;}
  	public Consult_Apts(Consult_Inventory__c my_apt, Integer tick_minutes, String lpre_screen, Boolean seminar,Boolean display_prescreen) {
  		this.capt = my_apt;
  		this.lead_pre_screen = lpre_screen;
  		this.lheight = 'normal';
  		this.fontsize = '10pt';
  		this.display_prescreen = display_prescreen;
  		Integer start_minutes = (Integer.valueof(my_apt.start_hour__c) * 60) + Integer.valueof(my_apt.start_minute__c);
  		Integer end_minutes = (Integer.valueof(my_apt.end_hour__c) * 60) + Integer.valueof(my_apt.end_minute__c);
  		Integer total_minutes = end_minutes - start_minutes;
  		Boolean calc_rows = true;
  		crowspan = 0;
  		Integer shour = Integer.valueof(my_apt.Start_Hour__c);
  		Integer sminute = tick_minutes;
  		while(calc_rows) {
  			if(shour < Integer.valueof(my_apt.End_Hour__c) || (shour == Integer.valueof(my_apt.End_Hour__c) && sminute <= Integer.valueof(my_apt.End_Minute__c)))
  				crowspan++;
  			else
  				calc_rows = false;
  // 		  System.debug('Shour : ' + shour + ' Sminute ' + sminute + ' Crowspan : ' + crowspan);
  			if(sminute==45) {
  				sminute = 0;
  				shour++;
  			}
  			else
  			  sminute += 15;
  		}
  		crowspan--;
  		Double holder = math.ceil(total_minutes / 15);
  		//crowspan = holder.intValue();
  		//crowspan = 6;
  		cheight = total_minutes;
  		cheight += (holder.intValue());
  		if(cheight<60) {
  		  lheight = '95%';
  		  fontsize = '8pt';
  		}
  		ctop = Integer.valueof(my_apt.start_minute__c) - tick_minutes;
  		if(my_apt.color__c=='Light Blue')
  		  this.cclass = 'apt_blue';
  		if(my_apt.color__c=='Light Purple')
  		  this.cclass = 'apt_purple';
  		if(my_apt.color__c=='Light Brown')
  		  this.cclass = 'apt_brown';
  		if(my_apt.color__c=='Light Red')
  		  this.cclass = 'apt_red';
  		if(my_apt.color__c=='Light Green')
  		  this.cclass = 'apt_green';
  		if(my_apt.color__c=='Light Grey')
  		  this.cclass = 'apt_grey';
  		if(my_apt.color__c=='Light Yellow')
  		  this.cclass = 'apt_yellow';
  		if(my_apt.color__c=='Light Orange')
  		  this.cclass = 'apt_orange';
  		if(my_apt.color__c=='Network Purple')
  		  this.cclass = 'apt_barney';
  		if(capt.scheduled_lead__c!=null || capt.scheduled_account__c!=null || capt.scheduled_patient__c!=null)
  		  this.cclass = 'apt_white';
		this.display_seminar = seminar;

		this.note_statuses = note_statuses();
  	}
  	public String getprescreen_label() {
  	  String label = '';
  	  if(capt.pre_screen_type__c=='Green/Yellow')
  	    label = 'Green/Yellow';
  	  if(capt.pre_screen_type__c=='Green/Yellow Only')
  	    label = 'G/Y Only';
  	  if(capt.pre_screen_type__c=='Any')
  	    label = 'Any';
  	  if(capt.pre_screen_type__c=='Seminar')
  	    label = 'Seminar';
  	  if(capt.pre_screen_type__c=='Red/Blue Only')
  	    label = 'R/B Only';
  	  return label;
  	}
  	public String getstart_time() {
  		Integer sh = integer.valueof(capt.start_hour__c);
  		String suffix = '';
  		if(sh>12) {
  		  sh = sh - 12;
  		  suffix = 'PM';
  		}
  		else if(sh==12)
  		  suffix = 'PM';
  		else
  		  suffix = 'AM';
  		if(capt.start_minute__c=='0')
  		  return sh + ':00 ' + suffix;
  		else
  		  return sh + ':' + capt.start_minute__c + ' ' + suffix;
  	}

  	public String getend_time() {
  	  Integer sh = integer.valueof(capt.end_hour__c);
  		String suffix = '';
  		if(sh>12) {
  		  sh = sh - 12;
  		  suffix = 'PM';
  		}
  		else if(sh==12)
  		  suffix = 'PM';
  		else
  		  suffix = 'AM';
  		if(capt.end_minute__c=='0')
  		  return sh + ':00 ' + suffix;
  		else
  		  return sh + ':' + capt.end_minute__c + ' ' + suffix;
  	}
  	public String getavail_text() {
  		String label = '';
  		//get the days between the apt_date and the current day
  		Date tdate = System.today();
  		Integer days_diff = tdate.daysBetween(capt.apt_date__c);
  		//first check to see if we have a hold
  		Boolean on_hold = false;
  		for(Consult_Holds__c ch : capt.Consult_Holds__r) {
  			Datetime h_end_time = ch.hold_time__c;
	  		//h_end_time = h_end_time.addMinutes(5);
	  		h_end_time = h_end_time.addHours(2);
	  		if(System.now()<h_end_time && ch.Hold_By__c <> Userinfo.getuserid())
	  			on_hold = true;
  		}
  		if(capt.consult_room__r.room_type__c=='Practice') {
  		  if(on_hold)
	  		label = '<span class="blank" style="color:red;">On Hold</span><br />Apt block is unavailable<br />';

  		}
  		else {

	  		if(on_hold) {
	  			label = '<span class="blank" style="color:red;">On Hold</span><br />Apt block is unavailable<br />';
	  		}
	  		else if(capt.pre_screen_type__c=='Seminar') {
	  			if(display_seminar)
	  			  label = '<span class="blank">Available</span><br />' + getprescreen_label() + '<br />';
	  			else
	  			  label = '<span class="blank" style="color:red;">Unavailable</span><br />Seminar Hold<br />';
	  		}
	  		else if(capt.pre_Screen_type__c=='Red/Blue Only') {
		  	  if(lead_pre_screen=='Red' || lead_pre_screen=='Blue (No Hit)' || lead_pre_screen=='PO Box' || lead_pre_screen=='Insufficient Information' || lead_pre_screen=='Website Down-No Prescreen' || lead_pre_screen=='Not Checked')
		  	    label = '<span class="blank">Available</span><br />Red/Blue<br />';
		  	  else
		  	    label = '<span class="blank" style="color:red;">Unavailable</span><br />Pre-Screen restriction<br />';
	  		}
	  		else {
		  		//if the difference is negative,  this is the past and no apt should be avaliable
		  		if(days_diff<0) {
		  		  label = '<span class="blank" style="color:red;">Unavailable</span><br />Apt in the past<br />';
		  		}
		  		//if the difference is less than or equal to three,  then everything is avaliable per Meridith
		  		else if(days_diff>=0 && days_diff <=5) {
		  			if(capt.pre_screen_type__c=='Green/Yellow Only' && (lead_pre_screen!='Green' && lead_pre_screen!='Yellow' && lead_pre_screen!='Gold'))
		  			  label = '<span class="blank" style="color:red;">Unavailable</span><br />Pre-Screen restriction<br />';
		  			else {
		  				if(capt.consult_room__r.room_type__c=='Unconfirmed')
		 						label = '<span class="blank">Unconfirmed</span><br />' + getprescreen_label() + '<br />';
		  				else {
		  					if(capt.pre_screen_type__c=='Green/Yellow')
		  					  label = '<span class="blank">Available</span><br />Any<br />';
		  					else
		  			      label = '<span class="blank">Available</span><br />' + getprescreen_label() + '<br />';
		  				}
		  			}

		  		}
		  		//if the difference is greater than three,  then we have to look at the pre-screen values
		  		else {
		  			if(capt.pre_screen_type__c=='Any')
		  			  label = '<span class="blank">Available</span><br />' + getprescreen_label() + '<br />';
		  			else if((capt.pre_screen_type__c=='Green/Yellow') && (lead_pre_screen=='Green' || lead_pre_screen=='Yellow' || lead_pre_screen=='Gold'))
		  			  label = '<span class="blank">Available</span><br />' + getprescreen_label() + '<br />';
		  			else if((capt.pre_screen_type__c=='Green/Yellow Only') && (lead_pre_screen=='Green' || lead_pre_screen=='Yellow' || lead_pre_screen=='Gold'))
		  			  label = '<span class="blank">Available</span><br />' + getprescreen_label() + '<br />';
		  			else
		  			  label = '<span class="blank" style="color:red;">Unavailable</span><br />Pre-Screen restriction<br />';
		  		}
	  		}

	  		if(capt.special_initiative__c!=null)
	  		    label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span><br />';
  		}
  		label += this.getstart_time() + ' - ' + this.getend_time() + '<br />';
  		return label;
  	}

  	public String getblock_text() {
  		//need to set up the standard view for a block on the schedule at some point
  		String label = '';
  		if(capt.consult_room__r.room_type__c=='Practice') {
  		  if(capt.scheduled_lead__c!=null)
	  		label += '<span style="font-weight:bold;">' + capt.scheduled_lead__r.name + '<br />';
	  	  else if(capt.scheduled_account__c!=null)
	  		label += '<span style="font-weight:bold;">' + capt.scheduled_account__r.name + '<br />';
	      else if(Capt.scheduled_patient__c!=null)
	        label += '<span style="font-weight:bold;">' + capt.scheduled_patient__r.first_name__c + ' ' + capt.scheduled_patient__r.last_name__c + '<br />';
	      if(capt.treatment__c==null)
	        label += '<span style="width:100%;display:block;background:#808080;color:white;">No Treatment</span>';
	      else
	        label += '<span style="width:100%;display:block;background:#808080;color:white;">' + capt.treatment__c + '</span>';
	      if(capt.add_ons__c==null)
	        label += '<span class="blank">No Add-Ons</span><br />';
	      else
	        label += '<span class="blank" style="color:red;">' + capt.add_ons__c + '</span><br />';
  		}
  		else {
	  		if(capt.scheduled_lead__c!=null) {
	  		  label += '<span style="font-weight:bold;">' + capt.scheduled_lead__r.name + '<br />';
	  		  //label += capt.scheduled_lead__r.pre_screen__c + '</br>';
	  		  if(capt.special_initiative__c!=null && capt.consult_room__r.center_information__r.type__c!='Network Center')
	  		    label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span> - ';
	  		  //label += capt.scheduled_lead__r.leadscore__c + '</br>';
	  		  if(capt.consult_room__r.center_information__r.type__c!='Network Center' && display_prescreen)
	  		    label += capt.leadscore_at_schedule_time__c + '</br>';
	  		  if(capt.scheduled_lead__r.language_spoken__c!='English' && capt.scheduled_lead__r.language_spoken__c!=null)
	  		    label += '<span style="font-weight:bold;color:red;">' + capt.scheduled_lead__r.language_spoken__c + '</span><br />';
	  		  /*if(capt.scheduled_lead__r.phone==null) {
	  			if(capt.scheduled_lead__r.mobilephone!=null)
	  			  label += capt.scheduled_lead__r.mobilephone + '<br />';
		  		}
		  		else
		  		  label += capt.scheduled_lead__r.phone + '<br />';*/
	  		}
	  		if(capt.scheduled_account__c!=null) {
	  			label += '<span style="font-weight:bold;">' + capt.scheduled_account__r.name + '<br />';
	  			if(capt.special_initiative__c!=null)
	  		    label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span> - ';
	  		  //label += capt.scheduled_account__r.pre_screen__c + '</br>';
	  		  label += capt.leadscore_at_schedule_time__c + '</br>';
	  		  if(capt.scheduled_account__r.language_spoken__c!='English' && capt.scheduled_account__r.language_spoken__c!=null)
	  		    label += '<span style="font-weight:bold;color:red;">' + capt.scheduled_account__r.language_spoken__c + '</span><br />';
	  		}
	  		if(capt.scheduled_patient__c!=null)
	  		  label += '<span style="font-weight:bold;">' + capt.scheduled_patient__r.first_name__c + ' ' + capt.scheduled_patient__r.last_name__c + '<br />';

	  		if(capt.confirmation_status__c=='Confirmed')
	  		  label += '<span style="width:100%;display:block;background:blue;color:white;">Confirmed</span>';
	  		else if(capt.confirmation_status__c=='Transfered')
	  		  label += '<span style="width:100%;display:block;background:red;color:white;">Transfered</span>';
	  		else if(capt.confirmation_status__c=='Confirmed WG')
	  		  label += '<span style="width:100%;display:block;background:blue;color:white;">Confirmed WG</span>';
	  		else if(capt.confirmation_status__c=='LVM')
	  		  label += '<span style="width:100%;display:block;background:#808080;color:white;">Left Message</span>';
	  		else if(capt.confirmation_status__c=='Not Confirmed' || capt.confirmation_status__c==null)
	  		  label += '<span style="width:100%;display:block;background:#808080;color:white;">Unconfirmed</span>';
	  		else if(capt.confirmation_status__c=='Not Confirmed WG')
	  		  label += '<span style="width:100%;display:block;background:#808080;color:white;">Unconfirmed WG</span>';
	  		else
	  		  label += '<span style="width:100%;display:block;background:#808080;color:white;">' + capt.confirmation_status__c + '</span>';
  	    }
  		label += this.getstart_time() + ' - ' + this.getend_time() + '<br />';
  		return label;
  	}

	Map<String, String> possible_statuses = new Map<String, String>{'Confirmed' => 'confirmed', 'Not Confirmed' => 'not-confirmed', 'Message' => 'left-a-message', 'Skeptical' => 'skeptical'};
	private String[] note_statuses() {
		String[] note_statuses = new String[]{null, 'none', 'none', 'none'};
		if (capt.Apt_Notes__c != null) {
			String parsed_note;
			String note_status;
			for (Integer i = 1; i <= 3; i++) {
				parsed_note = parsed_note(capt.Apt_Notes__c, i).trim();
				note_status = note_status(parsed_note);
				if (possible_statuses.keySet().contains(note_status)) {note_statuses[i] = possible_statuses.get(note_status);}
			}
		}
		return note_statuses;
	}
			private String parsed_note(String raw_notes, Integer i) {
				String note_starter   = '*';
				String note_separator = ';';

				Integer note_start = raw_notes.indexOf(note_starter + i);
				if (note_start != -1) {
					Integer note_end = raw_notes.indexOf(note_separator, note_start);
					return raw_notes.substring(note_start, note_end != -1 ? note_end : raw_notes.length());
				} else {return ' ';}
			}

			private String note_status(String note) {
				// Copy of the same method found in the parent class.
				if (!String.isBlank(note)) {
					String correct_status = ' ';
					for (String status : possible_statuses.keySet()) {
						if (note.toLowerCase().indexOf(status.toLowerCase()) != -1) {
							if      (correct_status == ' ') {correct_status = status;}
							else if (status.length() > correct_status.length()) {correct_status = status;}
						}
					}
					return correct_status;
				}
				else {return ' ';}
			}

  }

  public class Consult_Rows {
  	public Integer chours {get;set;}
  	public Integer cminutes {get;set;}
  	public String cclass {get;set;}
  	public Boolean display_label {get; set;}
  	public Consult_Apts[] row_apts {get; set;}
  	public Consult_Rows(Integer h, Integer m, Consult_Inventory__c[] all_apts, String lpre_screen, Boolean seminar, Boolean display_prescreen) {
  		this.row_apts = new Consult_Apts[] {};
  		this.chours = h;
  		this.cminutes = m;
  		if(cminutes==0 || cminutes==30) {
  			display_label = true;
  			cclass = 'maintick';
  		}
  		else {
  			display_label = false;
  			cclass = 'subtick';
  		}
  		//run through and build an array of calendar apts;
  		Integer m_end = m+14;
  		for(Consult_Inventory__c my_apt : all_apts) {
  		  if(my_apt.Start_Hour_Int__c == h && my_apt.Start_Minute_Int__c >= m && my_apt.Start_Minute_Int__c <= m_end) {
  		    Consult_Apts row_apt = new Consult_Apts(my_apt, m, lpre_screen, seminar, display_prescreen);
  		    this.row_apts.add(row_apt);
  		  }
  		}
  	}
  	public String getrow_label() {
  		String prefix = '';
  		if(chours > 12) {
  			prefix = 'PM';
  			chours -= 12;
  		}
  		else if(chours==12)
  		  prefix = 'PM';
  		else
  		  prefix = 'AM';
  		String rlabel = '';
  		rlabel += String.valueof(chours) + ':';
  		if(cminutes < 10)
  		  rlabel += '0';
  		rlabel += cminutes + ' ' + prefix;
  		return rlabel;
  	}
  }

  public class Consult_Rooms {
  	public Consult_Rooms__c room {get; set;}
  	public Consult_Room_Note__c[] all_notes {get; set;}
  	public Consult_Rows[] consult_view {get; set;}

  	public Consult_Rooms(Consult_Rooms__c my_room,Date schedule_date, String center) {
  		this.room = my_room;
  		this.all_notes = [Select c.SystemModstamp, c.Note_Date__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Comment__c, c.createdby.name From Consult_Room_Note__c c where c.consult_room__c = :my_room.id and c.note_date__c = :schedule_date order by c.createddate];
  	}
  	public Integer getnum_notes() {
  		return all_notes.size();
  	}

  	public Decimal getgy_percent() {
  		Decimal gy_count = 0.00;
  		Decimal room_count = 0.00;
  		for(Consult_Rows cr : consult_view) {
  	    for(Consult_Apts ca : cr.row_apts) {
  	      room_count += 1.00;
  	      if(ca.capt.scheduled_lead__c!=null) {
  	      	//if(ca.capt.scheduled_lead__r.pre_screen__c.contains('Green') || ca.capt.scheduled_lead__r.pre_screen__c.contains('Yellow'))
  	      	if(ca.capt.scheduled_lead__r.leadscore__c.contains('Green') || ca.capt.scheduled_lead__r.leadscore__c.contains('Yellow') || ca.capt.scheduled_lead__r.leadscore__c.contains('Gold'))
  	      	  gy_count += 1.00;
  	      }
  	      else if(ca.capt.scheduled_account__c!=null) {
  	      	if(ca.capt.scheduled_account__r.pre_screen__c.contains('Green') || ca.capt.scheduled_account__r.pre_screen__c.contains('Yellow') || ca.capt.scheduled_lead__r.leadscore__c.contains('Gold'))
  	      	  gy_count += 1.00;
  	      }
  	    }
  		}
  		if(room_count==0)
  		  return 0.00;
  		else
  		  return (gy_count/room_count * 100);
  	}
  }

  public Consult_Rows[] getview_consults(Consult_Rooms__c consult_room, Date view_date, String lpre_screen) {
  	Consult_Rows[] my_rows = new Consult_Rows[] {};
    Boolean generate_calendar = true;
    Integer shour = consult_room.Center_Information__r.Clinical_Start_Hour__c == null ? 7 : consult_room.Center_Information__r.Clinical_Start_Hour__c.intValue();
    Integer ehour = consult_room.Center_Information__r.Clinical_End_Hour__c == null ? 21 : consult_room.Center_Information__r.Clinical_End_Hour__c.intValue();
    Integer sminutes = 0;
    List<Consult_Inventory__c> all_apts = new List<Consult_Inventory__c>();
    if(user_profile_name=='Call Center Agent Infocision' || user_profile_name=='Call Center - Supervisor Infocision')
      all_apts = [Select c.add_ons__c, c.scheduled_patient__r.full_name__c, c.leadscore_at_schedule_time__c,c.consult_room__r.room_type__c,c.confirmation_status__c,c.Template_Apt__c, c.SystemModstamp, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Scheduled_Lead__c, c.Pre_Screen_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Minute__c, c.End_Hour__c, c.CreatedDate, c.CreatedById, c.Callback_Consult__c, c.Consult_Room__c, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.Active__c, c.scheduled_lead__r.language_spoken__c, c.scheduled_lead__r.Name, c.scheduled_lead__r.Pre_Screen__c, c.scheduled_lead__r.leadscore__c,c.scheduled_lead__r.Phone, c.scheduled_lead__r.MobilePhone, c.scheduled_lead__r.LastName, c.scheduled_lead__r.FirstName, c.treatment__c, c.scheduled_lead__r.Left_Message_to_Confirm__c, c.scheduled_lead__r.Confirmed_Appointment__c, c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.language_spoken__c,(Select Hold_By__c, Hold_Time__c, Active_Hold__c From Consult_Holds__r where active_hold__c = true),c.special_initiative__c,c.consult_room__r.center_information__r.type__c, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__c From Consult_Inventory__c c where c.consult_room__c = :consult_room.id and c.apt_date__c = :view_date and c.active__c = true and c.consult_room__r.infocision_sf_visible__c = true];
    else
      all_apts = [Select c.add_ons__c, c.scheduled_patient__r.full_name__c, c.leadscore_at_schedule_time__c,c.consult_room__r.room_type__c,c.confirmation_status__c,c.Template_Apt__c, c.SystemModstamp, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Scheduled_Lead__c, c.Pre_Screen_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Minute__c, c.End_Hour__c, c.CreatedDate, c.CreatedById, c.Callback_Consult__c, c.Consult_Room__c, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.Active__c, c.scheduled_lead__r.language_spoken__c, c.scheduled_lead__r.Name, c.scheduled_lead__r.Pre_Screen__c, c.scheduled_lead__r.leadscore__c,c.scheduled_lead__r.Phone, c.scheduled_lead__r.MobilePhone, c.scheduled_lead__r.LastName, c.scheduled_lead__r.FirstName, c.treatment__c, c.scheduled_lead__r.Left_Message_to_Confirm__c, c.scheduled_lead__r.Confirmed_Appointment__c, c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.language_spoken__c,(Select Hold_By__c, Hold_Time__c, Active_Hold__c From Consult_Holds__r where active_hold__c = true),c.special_initiative__c,c.consult_room__r.center_information__r.type__c, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__c From Consult_Inventory__c c where c.consult_room__c = :consult_room.id and c.apt_date__c = :view_date and c.active__c = true];
    while(generate_calendar) {
    	//System.debug('Hour : ' + shour + ' Minutes : ' + sminutes);
    	Boolean seminar = false;
    	if(display_seminar || getdisplay_ca())
    	  seminar = true;
    	Consult_Rows crow = new Consult_Rows(shour, sminutes, all_apts, lpre_screen, seminar, display_prescreen);
    	if(sminutes == 45) {
    		shour++;
    		sminutes = 0;
    	}
    	else
    	  sminutes += 15;
    	if(shour > ehour)
    	  generate_calendar = false;
    	my_rows.add(crow);
    }
    return my_rows;
  }

	public Consult_Rooms[] getview_allrooms() {
		Consult_Rooms[] all_rooms = new Consult_Rooms[] {};
		//work through all consult rooms at this center
		String walnut_filter = 'Ignore this check';
		if (display_admin)
		walnut_filter = 'Ignore this rule';
		System.debug('Confirmation : ' + display_confirmation);
		List<Consult_Rooms__c> room_list = new List<Consult_Rooms__c>();
		try {
			if (display_admin || display_cc || display_cc_lead || display_confirmation || display_cc_sup || display_seminar || getdisplay_ca()) {
				System.debug('Adding Consult Rooms');
				for (Consult_Rooms__c room : [SELECT c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate,
					c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c,c.schedule_template__r.name,c.days_built_out__c,
          c.Center_Information__r.Clinical_Start_Hour__c, c.Center_Information__r.Clinical_End_Hour__c
					FROM Consult_Rooms__c c
					WHERE c.center_information__c = :selected_center and active__c = true
					AND   c.center_information__r.name != :walnut_filter
					AND   c.room_type__c != 'Practice'
					ORDER BY c.sort_order__c, c.createddate]) {
						room_list.add(room);
					}
				}
		} catch (Exception e) {System.debug('Exception Issue : ' + e);}
			//see if they can view Practice Rooms
		try {
			if(display_practice) {
				System.debug('Getting Practice Rooms - selected center: ' + selected_center);
				for (Consult_Rooms__c room : [SELECT c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate,
					c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c,c.schedule_template__r.name,c.days_built_out__c,
          c.Center_Information__r.Clinical_Start_Hour__c, c.Center_Information__r.Clinical_End_Hour__c
					FROM Consult_Rooms__c c
					WHERE c.center_information__c = :selected_center and active__c = true
					AND   c.center_information__r.name != :walnut_filter
					AND   c.room_type__c = 'Practice'
					ORDER BY c.sort_order__c,c.createddate]) {
						room_list.add(room);
						System.debug('Added Practice Room - Room Type - ' + room.room_type__c);
					}
				}
		}  catch (Exception e) {System.debug('Exception Issue : ' + e);}
		for(Consult_Rooms__c room : room_list) {
			Consult_Rooms new_room = new Consult_Rooms(room,selected_date,selected_center);
			String ps = '';
			if(scheduling_lead!=null)
			//ps = scheduling_lead.pre_screen__c;
			ps = scheduling_lead.leadscore__c;
			else if(scheduling_account!=null)
			ps = scheduling_account.Pre_Screen__c;
			new_room.consult_view = getview_consults(new_room.room,selected_date,ps);
			all_rooms.add(new_room);
		}
		return all_rooms;
	}

  public void transmit_sms(smagicinteract__smsMagic__c sms,String Phone) {
    smagicinteract__smsMagic__c send_sms = new smagicinteract__smsMagic__c();

    send_sms.smagicinteract__PhoneNumber__c = Phone;
    send_sms.smagicinteract__SenderId__c = sms.smagicinteract__SenderId__c;
    send_sms.smagicinteract__disableSMSOnTrigger__c = sms.smagicinteract__disableSMSOnTrigger__c;
    send_sms.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
    send_sms.smagicinteract__SMSText__c = sms.smagicinteract__SMSText__c;
    send_sms.smagicinteract__Name__c = sms.smagicinteract__Name__c;
    send_sms.smagicinteract__ObjectType__c = sms.smagicinteract__ObjectType__c;
    if(sms.smagicinteract__Lead__c!=null)
      send_sms.smagicinteract__Lead__c = sms.smagicinteract__Lead__c;
    if(sms.Account__c!=null)
      send_sms.Account__c =  sms.Account__c;
    try {
    	if(!test.isRunningTest())
        insert send_sms;
      Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'SMS Reminder',notes__c = 'Reminder Sent : ' + send_sms.smagicinteract__SMSText__c);
      insert history;
      modal_out = '<span class="blank" style="color:blue;">Success</span> - Reminder SMS sent';
    }
    catch (Exception e) {
  	  modal_out += e.getMessage() + '<br />';
    }
  }

  public void send_confirmation_sms() {
  	modal_out = '';
  	Map<Id,String> all_marketing_nums = new Map<id,String> {};
  	for(Center_Information__c center : [select id,call_center_marketing__c from center_information__c]) {
  		all_marketing_nums.put(center.id,center.call_center_marketing__c);
  	}
    smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
    String senderId = '18055007067'; //Userinfo.getName();//SenderId assing to user by default it is'smsMagic'
    String MobilePhone = '';
    String center_id = '';
    String language = '';
    if(view_apt.Scheduled_Lead__c!=null) {
      center_id = view_apt.scheduled_lead__r.center__c;
      smsObject.smagicinteract__Name__c = view_apt.scheduled_lead__r.Name;
      smsObject.smagicinteract__ObjectType__c = 'Lead';
      smsObject.smagicinteract__Lead__c = view_apt.Scheduled_Lead__c;
      language = view_apt.scheduled_lead__r.language_spoken__c;
    }
    else if(view_apt.scheduled_account__c!=null) {
    	center_id = view_apt.scheduled_account__r.center__c;
    	// smsObject.smagicinteract__Name__c = view_apt.scheduled_account__r.Name;
		smsObject.smagicinteract__Name__c = view_apt.Scheduled_Account__r.FirstName + ' ' + view_apt.Scheduled_Account__r.LastName;
      smsObject.smagicinteract__ObjectType__c = 'Account';
      smsObject.Account__c = view_apt.Scheduled_account__c;
      language = view_apt.scheduled_account__r.language_spoken__c;
    }
    Datetime apt_date = datetime.newinstance(view_apt.apt_date__c.year(),view_apt.apt_date__c.month(),view_apt.apt_date__c.day(),math.round(view_apt.Start_Hour_Int__c),math.round(view_apt.Start_Minute_Int__c),0);
    String dtext = '';
    String confirmation_message = '';

    /*if(language=='Spanish') {
      if(view_apt.apt_date__c.daysbetween(system.today())==0)
        dtext = 'hoy';
      else if(view_apt.apt_date__c.daysbetween(system.today())==-1)
        dtext = 'manana';
      else {
      	System.debug('DTEXT : ' + view_apt.apt_date__c.daysbetween(system.today()));
        dtext = ' on ' + apt_date.format('M/dd/yyyy');
      }
      confirmation_message = 'Centros de Implantes Dentales de ClearChoice: Le esperamos ' + dtext +
        ' a las ' + apt_date.format('h:mm a') + '. Puede comunicarse con nosotros al llamar el ' + all_marketing_nums.get(center_id) + '.';
    }
    else {*/
    if(view_apt.apt_date__c.daysbetween(system.today())==0)
      dtext = 'today';
    else if(view_apt.apt_date__c.daysbetween(system.today())==-1)
      dtext = 'tomorrow';
    else {
      System.debug('DTEXT : ' + view_apt.apt_date__c.daysbetween(system.today()));
      dtext = ' on ' + apt_date.format('M/dd/yyyy');
    }
    confirmation_message = 'ClearChoice: We are excited to see you at your appointment ' + dtext +
      ' at ' + apt_date.format('h:mm a') + '. You may reach us at ' + all_marketing_nums.get(center_id) + '. Reply STOP to opt out of future reminders.';
    //}

    smsObject.smagicinteract__SenderId__c = senderId;
    smsObject.smagicinteract__disableSMSOnTrigger__c = 0;
    smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
    smsObject.smagicinteract__SMSText__c = confirmation_message;
    Boolean msg_sent = false;

    if(view_apt.Scheduled_Lead__c!=null) {
      if(view_apt.Scheduled_Lead__r.MobilePhone!=null && view_apt.Scheduled_Lead__r.MobilePhone!='') {
   	    //if(view_apt.Scheduled_Lead__r.MobilePhone!=view_apt.scheduled_lead__r.Phone)
   	      transmit_sms(smsObject,view_apt.Scheduled_Lead__r.MobilePhone);
   	      msg_sent = true;
   	  }
   	  if(view_apt.Scheduled_Lead__r.Phone!=null && view_apt.scheduled_lead__r.Phone!='')
   	    transmit_sms(smsObject,view_apt.Scheduled_Lead__r.Phone);
    }
    else if(view_apt.scheduled_account__c!=null) {
     if(view_apt.scheduled_account__r.Personmobilephone!=null && view_apt.scheduled_account__r.Personmobilephone!='') {
        //if(view_apt.scheduled_account__r.Personmobilephone<>view_apt.scheduled_account__r.Phone)
          transmit_sms(smsObject,view_apt.scheduled_account__r.Personmobilephone);
          msg_sent = true;
      }
      if(view_apt.scheduled_account__r.Phone!=null && view_apt.scheduled_account__r.Phone!='')
        transmit_sms(smsObject,view_apt.Scheduled_Account__r.Phone);
    }
  }

  public ctrl_clinicschedule.Print_Consult_Inventory[] getview_allprintconsults(Consult_Rooms__c consult_room, Date view_date) {
  	ctrl_clinicschedule.Print_Consult_Inventory[] my_apt = new ctrl_clinicschedule.Print_Consult_Inventory[] {};
    for(Consult_Inventory__c ci : [Select c.add_ons__c,c.scheduled_patient__r.full_name__c, c.special_initiative__c,c.Callback_Consult_PEC__c,c.callback_consult_pec__r.name,c.callback_consult__c,c.confirmation_status__c,c.Template_Apt__c, c.SystemModstamp, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Minute__c, c.End_Hour__c, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.Active__c,  c.treatment__c, c.Consult_Show_Status__c, c.Patient_Mobile__c, c.Patient_Name__c, c.Patient_Phone__c, c.scheduled_account__r.name, c.scheduled_account__r.Phone, c.scheduled_account__r.Personmobilephone,c.scheduled_account__r.language_spoken__c, c.scheduled_account__c, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__c From Consult_Inventory__c c where c.consult_room__c = :consult_room.id and c.apt_date__c = :view_date and c.active__c = true order by c.start_hour_int__c,c.start_minute_int__c]) {
    	ctrl_clinicschedule.Print_Consult_Inventory pci = new ctrl_clinicschedule.Print_Consult_Inventory(ci);
    	my_apt.add(pci);
    }
    return my_apt;
  }

  public ctrl_clinicschedule.Print_Consult_Rooms[] getview_allprintrooms() {
    ctrl_clinicschedule.Print_Consult_Rooms[] all_rooms = new ctrl_clinicschedule.Print_Consult_Rooms[] {};
    String walnut_filter = 'Ignore this check';
    if (display_admin)
      walnut_filter = 'Ignore this rule';
    //work through all consult rooms at this center
    for(Consult_Rooms__c room : [Select c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c,c.schedule_template__r.name
      From Consult_Rooms__c c where c.center_information__c = :selected_center and active__c = true
      and c.center_information__r.name != :walnut_filter
      order by c.createddate]) {
    	ctrl_clinicschedule.Print_Consult_Rooms new_room = new ctrl_clinicschedule.Print_Consult_Rooms(room,selected_date,selected_center);
      new_room.all_apts = getview_allprintconsults(new_room.room,selected_date);
    	all_rooms.add(new_room);
    }
    return all_rooms;
  }

  public String gettoday_text() {
  	String return_val = 'Today - ' + System.now().format('M/dd/yyyy');
  	return return_val;
  }

  public void display_today() {
  	selected_date = System.today();
  	cmonth = new CalendarMonth(selected_date,selected_center);
  }

  public boolean getisLeadValid() {
  	lead_valid_errors = '';
  	Profile p = [select name from profile where id = :Userinfo.getProfileId()];
  	if (scheduling_lead==null ||
			p.Name == 'Call Center Agent - No Validation' ||
			p.Name == 'Outbound Call Center Agent Test' ||
			p.Name == 'Call Center Agent Jumpstart' ||
			p.Name == 'Outbound Call Center Jumpstart' ||
			p.Name == 'Patient Education Consultant' ||
			p.Name == 'PEC - TPLAN' ||
			p.Name == 'PEC - Exam Center' ||
			p.Name == 'PEC - No Prescreen - PPF' ||
			p.Name == 'PEC - PPF - NoPScreen - TPlan' ||
			p.Name == 'PEC_MultipleCenters_VisiblePrescreen' ||
			p.Name == 'PEC_VisiblePrescreen' ||
			p.Name == 'PEC - Multiple Centers' ||
			p.Name == 'PEC - Red Rally' ||
			p.Name == 'PEC - Red Rally No Prescreen' ||
			p.Name == 'PEC - Snap' ||
			p.Name == 'PEC - Application Date' ||
			p.Name == 'PEC - Extended Finance' ||
			p.Name == 'PEC - Extended Finance no prescreen' ||
			p.Name == 'PEC - Snap No Prescreen' ||
			p.Name == 'PEC - No Prescreen' ||
			p.Name == 'PEC - PPF - No Prescreen' ||
			p.Name == 'PEC - PFF - Application Date' ||
			p.Name == 'PEC - Denver' ||
			p.Name == 'PEC - Denver - FOA' ||
			p.Name == 'FOA - TPLAN' ||
			p.Name == 'PEC - Multiple Centers' ||
			p.Name == 'PEC - Multiple Centers No Prescreen' ||
			p.Name == 'Outbound Call Center Agent' ||
			p.Name == 'FOA' ||
			p.Name == 'FOA - No Prescreen - TPlan' ||
			p.Name == 'PEC - NoPScreen - No Dash' ||
			p.Name == 'FOA - No Prescreen') {
		System.Debug('Valid Lead - Exempt ');
		return true;
	}
  	else {
  	  //check to see if the lead is valid
  	  Boolean valid_lead = true;
  	  //email check
  	  /*if(scheduling_lead.inbound_call__c=='Dental Inquiry' && scheduling_lead.Refused_to_give_email__c==false &&
  	    scheduling_lead.email == null) {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Email must be filled in,  or refused to give email must be checked</span><br />';
  	  }*/
  	  //pre-screen check
  	  //if(Scheduling_lead.pre_screen__c=='Red' && scheduling_lead.Fees_Quoted__c==null)
  	  if(Scheduling_lead.leadscore__c=='Red' && scheduling_lead.Fees_Quoted__c==null && scheduling_lead.center__r.type__c<>'Network Center') {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Red prescreen must have a fee quoted</span><br />';
  	  }
  	  //lead check
  	  if(scheduling_lead.phone!=null) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(scheduling_lead.phone);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be all numeric</span><br />';
  	  	 }

  	  	 String formatted_phone = scheduling_lead.phone;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  Datetime phone_cutoff = Datetime.newinstance(2013,12,2,0,0,0);
  	  if(scheduling_lead.mobilephone!=null && scheduling_lead.createddate >= phone_cutoff ) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(scheduling_lead.mobilephone);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be all numeric</span><br />';
  	  	 }

  	  	 String formatted_phone = scheduling_lead.mobilephone;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  if(scheduling_lead.work__c!=null && scheduling_lead.createddate >= phone_cutoff ) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(scheduling_lead.work__c);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be all numeric</span><br />';
  	  	 }

  	  	 String formatted_phone = scheduling_lead.work__c;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }

  	  if(scheduling_lead.phone==null && scheduling_lead.inbound_call__c=='Dental Inquiry' && scheduling_lead.Work__c==null && scheduling_lead.MobilePhone==null) {
  	  	valid_lead = false;
  	  	lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must enter a phone number in the phone,  mobile,  or work phone fields</span><br />';
  	  }
  	  //cancellation notes check
  	  if(scheduling_lead.Hot_List__c==true) {
  	  	if(scheduling_lead.Cancellation_List_Notes__c==null)   {
  	      valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	  	}
  	    else if(scheduling_lead.Cancellation_List_Notes__c.length() < 2) {
  	      valid_lead = false;
  	      lead_valid_errors = '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	    }
  	  }
  	  System.Debug('Valid Lead : ' + valid_lead);
  	  return valid_lead;
  	}
  }

  public class wu_full_response {
  	public wu_response_detail response;
  	public wu_forecast_full forecast;

  	public wu_full_response() {}
  }

  public class wu_forecast_full {
  	public wu_forecast_text txt_forecast;
  	public wu_simple_forecastday simpleforecast;

  	public wu_forecast_full() {}
  }

  public class wu_simple_forecastday {
  	public List<wu_simple_forecastday_detail> forecastday;

  	public wu_simple_forecastday() {}
  }

  public class wu_simple_forecastday_detail {
  	public Map<String,String> fdate;
  	public Integer period;
  	public Map<String,String> high;
  	public Map<String,String> low;
  	public String conditions;
  	public String icon;
  	public String icon_url;
  	public String skyicon;
  	public Integer pop;
  	public Map<String,String> qpf_allday;
  	public Map<String,String> qpf_day;
  	public Map<String,String> qpf_night;
  	public Map<String,String> snow_allday;
  	public Map<String,String> snow_day;
  	public Map<String,String> snow_night;
  	public Map<String,String> maxwind;
  	public Map<String,String> avewind;
  	public Decimal avehumidity;
  	public Decimal maxhumidity;
  	public Decimal minhumidity;

  	public wu_simple_forecastday_detail() {}
  }

  public class wu_forecast_text {
  	public String fdate;
  	public List<wu_forecastday> forecastday;

  	public wu_forecast_text() {}
  }

  public class wu_forecastday {
  	public Integer period;
  	public String icon;
  	public String icon_url;
  	public String title;
  	public String fcttext;
  	public String fcttext_metric;
  	public String pop;
  	public wu_forecastday() {}
  }

  public class wu_response_detail {
  	public String version;
  	public String termsofService;
  	public Map<String,String> features;

  	public wu_response_detail() {}
  }

  public void check_for_weather_data() {
  	//method to check and see if we have weather data for the currently selected center and it was pulled today (createddate = today)
  	//do we have data for today for this center...and does the center have a postal code
  	Center_Information__c current_center = [select id,zip_code__c from Center_Information__c where id = :selected_center];
  	Integer wcount = [select count() from Weather__c where createddate = today and center_information__c = :current_center.id];
  	if(current_center.zip_code__c!=null && wcount==0) {
  	  System.debug('Grabbing Weather Data');
  	    //run an api call to grab weather data and load it in
  	    HttpRequest req = new HttpRequest();
	  	HttpResponse res = new HttpResponse();
	    Http http = new Http();

	    //Production
	    req.setEndpoint('http://api.wunderground.com/api/56a44de3711b6b71/forecast/q/' + current_center.zip_code__c + '.json');
	    req.setTimeout(60000);
	    req.setMethod('GET');

	    try {
	      res = http.send(req);
	      System.debug('Response Status ' + res.getStatusCode());
	      System.debug('Response Body ' + res.getBody());
	      System.debug('Response Code : ' + res.getStatusCode());

		  String sample_response = res.getBody();
	      sample_response = sample_response.replace('"date"','"fdate"');

	      wu_full_response deserializeResults = (wu_full_response)JSON.deserialize(sample_response, wu_full_response.class);

	      //test weather record insert
	      List<Weather__c> weather_list = new List<Weather__c>();
	      //System.debug('Type : ' + deserializeResults.forecast.simpleforecast);
	      for(wu_simple_forecastday_detail forecast : deserializeResults.forecast.simpleforecast.forecastday) {
	        Date cdate = Date.newinstance(Integer.valueof(forecast.fdate.get('year')),Integer.valueof(forecast.fdate.get('month')),Integer.valueof(forecast.fdate.get('day')));
	        String dtype = '';
	        if(cdate < System.today())
	          dtype = 'Past';
	        else if(cdate == System.today())
	          dtype = 'Current';
	        else
	          dtype = 'Forecast';
	        Weather__c wrecord = new Weather__c(center_information__c = current_center.id, calendar_date__c = cdate,
	          data_type__c = dtype, json_data__c = JSON.serialize(forecast), temp_high__c = decimal.valueof(forecast.high.get('fahrenheit')),
	          temp_low__c= decimal.valueof(forecast.low.get('fahrenheit')), conditions__c = forecast.conditions, icon__c = forecast.icon,
	          icon_url__c = forecast.icon_url, pop__c = forecast.pop, qpf_allday__c = decimal.valueof(forecast.qpf_allday.get('in')==null?'0':forecast.qpf_allday.get('in')),
	          qpf_night__c = decimal.valueof(forecast.qpf_night.get('in')==null?'0':forecast.qpf_night.get('in')), qpf_day__c = decimal.valueof(forecast.qpf_day.get('in')==null?'0':forecast.qpf_day.get('in')),
	          snow_day__c = decimal.valueof(forecast.snow_day.get('in')==null?'0':forecast.snow_day.get('in')), snow_allday__c = decimal.valueof(forecast.snow_allday.get('in')==null?'0':forecast.snow_allday.get('in')),
	          snow_night__c = decimal.valueof(forecast.snow_night.get('in')==null?'0':forecast.snow_night.get('in')), max_wind__c = decimal.valueof(forecast.maxwind.get('mph')==null?'0':forecast.maxwind.get('mph')),
	          avg_wind__c = decimal.valueof(forecast.avewind.get('mph')==null?'0':forecast.avewind.get('mph')), max_humidity__c = forecast.maxhumidity, min_humidity__c = forecast.minhumidity);
	        weather_list.add(wrecord);
	        System.debug('Weather Record : ' + wrecord);
	      }
	      insert weather_list;
	    } catch (Exception e) {
	      System.debug('Weather Data Failure');
	      System.debug(e);
	    }
  	}
  }

  public Weather__c getweather_info(Date weather_date) {
  	try {
  	  return [Select w.Temp_Low__c, w.Temp_High__c, w.SystemModstamp, w.Snow_Night__c, w.Snow_Day__c, w.Snow_AllDay__c, w.Skyicon__c, w.QPF_Night__c, w.QPF_Day__c, w.QPF_Allday__c, w.POP__c, w.OwnerId, w.Name, w.Min_Humidity__c, w.Max_Wind__c, w.Max_Humidity__c, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.Icon__c, w.Icon_URL__c, w.Data_Type__c, w.CreatedDate, w.CreatedById, w.Conditions__c, w.Center_Information__c, w.Calendar_Date__c, w.Avg_Wind__c, w.Avg_Humidity__c
  	    From Weather__c w
  	    where center_information__c = :selected_center and calendar_date__c = :weather_date
  	    order by createddate desc limit 1];
  	} catch (Exception e) {
  	  return null;
  	}
  }



	public String[] notes         {get; set;}
	public String[] note_statuses {get; set;}
	public String[] note_dates    {get; set;}
	public Integer notes_number   {get; set;}
	public Integer notes_selection_index {get; set;}

	public String[] note_possible_statuses {get; private set;}
	public String today {get; private set;} {today = Date.Today().format();}
	private Integer max_notes = 3;
	private String opening_confirmation_status;

	// The position of these list items is important.
	// 0 - Outbound spoke to the patient and confirmed the appointment. Like 'Confirmed'
	// 1 - Outbound could not confirm the appointment. Probably failed to make contact. Like 'Not Confirmed'
	// 2 - Outbound left a message, either with a person or voicemail. Like 'Message'
	// 3 - Outbound spoke to the patient and confirmed but suspects patient will not show. Like 'Skeptical'
	{note_possible_statuses  = new String[]{'Confirmed', 'Not Confirmed', 'Message', 'Skeptical'};}
	private String note_starter = '*';
	private String note_separator = ';';
	public void set_notes() {
		if (notes == null) {parse_notes();}
		notes[notes_number] = note_starter + notes_number + '. ' + Date.today().format() + ' ' + UserInfo.getName() + ': ' + note_possible_statuses[notes_selection_index];
		note_statuses[notes_number] = note_status(notes[notes_number]);
		note_dates[notes_number] = note_date(notes[notes_number]);
		view_apt.Apt_Notes__c = final_notes();
		set_confirmation();
		// add_apt_history_for_confirmation_notes(notes_number, note_possible_statuses[notes_selection_index]);
	}

			// private void add_apt_history_for_confirmation_notes(Integer call_number, String status) {
			// 	String history_note = 'Confirmation Team member set Confirmation Call #' + call_number + ' to ' + status + '.';
			// 	insert new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.Scheduled_Patient__c, Lead__c = view_apt.Scheduled_Lead__c, Account__c = view_apt.Scheduled_Account__c, Action__c = 'Confirmation Team Set Status', Notes__c = history_note);
			// }


            private void parse_notes() {
                notes         = new String[]{};
                note_statuses = new String[]{};
                note_dates    = new String[]{};
                opening_confirmation_status = view_apt.Confirmation_Status__c;
                final String raw_notes = view_apt.Apt_Notes__c;
                String temp_note;
                // notes[0] is for irregular notes (generally notes assigned before standardizing notes with this code)
                for (Integer i = 0; i <= max_notes; i++) {
                    temp_note = parsed_note(raw_notes, i);
                    notes.add(temp_note);
                    note_statuses.add((i > 0) ? note_status(temp_note) : ' ');
                    note_dates.add(   (i > 0) ? note_date(temp_note)   : ' ');
                }
            }

            private String parsed_note(String raw_notes, Integer i) {
                if (!String.isBlank(view_apt.Apt_Notes__c)) {
                    if (i != 0) {
                        Integer note_start = raw_notes.indexOf(note_starter + i);
                        if (note_start != -1) {
                            Integer note_end = raw_notes.indexOf(note_separator, note_start);
                            return raw_notes.substring(note_start, note_end != -1 ? note_end : raw_notes.length());
                        } else {return ' ';}
                    } else {return parsed_irregular_note(raw_notes);}
                } else {return ' ';}
            }

            private String parsed_irregular_note(String raw_notes) {
                // This should only get called if view_apt.Apt_Notes__c is not blank
				if (raw_notes.length() >= 2) {
					Set<String> possible_starters = new Set<String>{};
					for (Integer i = 1; i <= max_notes; i++) {possible_starters.add(note_starter + i);}
					String raw_note_starter = raw_notes.substring(0, 2);

					// If the notes start with a recognized starter string, there is no irregular string in front, so return empty string
					if (possible_starters.contains(raw_note_starter)) {return ' ';}
					else {
						Integer irregular_note_end = raw_notes.indexOf(note_separator);
						return irregular_note_end != -1 ? raw_notes.substring(0, irregular_note_end) : raw_notes;
					}
				} else return raw_notes;
            }

            private String note_status(String note) {
                // Look for one of the acceptable statuses in the current note.
                // Because some statuses can be a substring of another ('confirmed' would be found in 'not confirmed'),
                // we need to check for all of them and compare, keeping only the longest one.
                if (!String.isBlank(note)) {
                    String correct_status = ' ';
                    for (String status : note_possible_statuses) {
                        if (note.toLowerCase().indexOf(status.toLowerCase()) != -1) {
                            if      (correct_status == ' ') {correct_status = status;}
                            else if (status.length() > correct_status.length()) {correct_status = status;}
                        }
                    }
                    return correct_status;
                }
                else {return ' ';}
            }

            private String note_date(String note) {
                // We assume any note in a slot greater than zero (where irregular notes go) will be properly formatted...
                // A properly formatted note looks like this: '*1. 11/8/2016 Alon Waisman: Confirmed'
                // It has a special identifier, then the date between two spaces. Look for the date between these spaces.
                if (!String.isBlank(note)) {
                    Integer date_start = note.indexOf(' ') + 1;
                    Integer date_end   = note.indexOf(' ', date_start);
                    return note.substring(date_start, date_end);
                }
                // Return a space instead of null or empty string because of visualforce's buggy inability to capture such a 'blank' value from inside a list of strings
                else {return ' ';}
            }

            private String final_notes() {
                String[] final_notes_list = new String[]{};
                for (Integer i = 0; i <= max_notes; i++) {
                    if (!String.isBlank(notes[i]) && notes[i] != ' ') {final_notes_list.add(notes[i]);}
                }
                return String.join(final_notes_list, note_separator + ' ');
            }

            private void set_confirmation() {
                String new_status = note_statuses[notes_number];
                if (opening_confirmation_status != 'Confirmed') {
                    if      (new_status == note_possible_statuses[0]) {view_apt.Confirmation_Status__c = 'Confirmed';}
                    else if (new_status == note_possible_statuses[1]) {view_apt.Confirmation_Status__c = 'Not Confirmed';}
                    else if (new_status == note_possible_statuses[2]) {view_apt.Confirmation_Status__c = 'LVM';}
                    else if (new_status == note_possible_statuses[3]) {view_apt.Confirmation_Status__c = opening_confirmation_status;}
                }
            }


    public Boolean getfirst_confirmation_complete() {
        return !String.isBlank(note_statuses[1]);
    }

    public Boolean getconfirmed_on_first_call() {
        return (note_statuses[1] == note_possible_statuses[0]);
    }

    public String getuser_initials() {
        return UserInfo.getFirstName().left(1) + UserInfo.getLastName().left(1);
    }

    public Boolean getconfirmation_conflict() {
		// If current status of appointment is 'Confirmed' and none of the Outbound confirmations are confirmed, there is a conflict.
        Boolean outbound_confirmed = false;
		if (view_apt.Confirmation_Status__c == 'Confirmed') {
			for (Integer i = 1; i <= max_notes; i++) {if (note_statuses[i] == 'Confirmed') {return false;}}
			return true;
		} else return false;
    }

	public List<Selectoption> getdouble_consult_options() {
		selectOption[] patient_names = new selectOption[]{new selectOption('', 'None')};
		Consult_Inventory__c[] consults = [SELECT ID, Patient_Name__c
											FROM Consult_Inventory__c
											WHERE (Scheduled_Lead__c != null OR Scheduled_Account__c != null)
											AND   Apt_Date__c = :selected_date
											AND   Consult_Room__r.Center_Information__c = :selected_center
											AND   ID != :view_apt.ID
											ORDER BY Patient_Name__c];
		for (Consult_Inventory__c consult : consults) {
			patient_names.add(new selectOption(consult.ID, consult.Patient_Name__c));
		}
		return patient_names;
    }

	public Boolean getis_double_consult() {
		return !String.isBlank(view_apt.Double_Consult__c);
	}

	public list<Selectoption> getyes_no_list() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Yes','Yes'));
		options.add(new SelectOption('No','No'));
		return options;
	}

	public void set_consult_reminders_from_patient_reminders() {
		if (view_apt.Scheduled_Lead__c != null) {
			view_apt.Auto_Reminder__c = view_apt.Scheduled_Lead__r.Reminder_Call__c == 'Yes' ? true : false;
			view_apt.Send_Reminder__c = view_apt.Scheduled_Lead__r.Reminder_Text__c == 'Yes' ? true : false;
		} else if (view_apt.Scheduled_Account__c != null) {
			view_apt.Auto_Reminder__c = view_apt.Scheduled_Account__r.Reminder_Call__c == 'Yes' ? true : false;
			view_apt.Send_Reminder__c = view_apt.Scheduled_Account__r.Reminder_Text__c == 'Yes' ? true : false;
		}
	}

}