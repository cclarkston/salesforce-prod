public without sharing class lead_upcomingseminars {
  private final Lead l;
  public String register_issues {get; set;}
  ApexPages.Standardcontroller con;
  public upcoming_seminars[] all_upcoming_seminars;
  public String lead_valid_errors {get; set;}

  public lead_upcomingseminars(ApexPages.StandardController stdController) {
    this.l = (Lead)stdController.getRecord();
    con = stdController;
    register_issues = '';
    lead_valid_errors = '';
  }

  public class upcoming_seminars {
  	public Campaign seminar_campaign {get; set;}
  	public Boolean currently_registered {get; set;}
  	public String cm_status {get; set;}
  	public Attachment[] sem_doc {get; set;}
  	public String guest_names {get; set;}
  	public upcoming_seminars (Campaign my_campaign, String ppt_id) {
  		this.seminar_campaign = my_campaign;
  		this.guest_names = '';
  		Integer mem_num = [select count() from CampaignMember where campaignid =: my_campaign.id and leadid = :ppt_id];
  		if(mem_num>0) {
  			this.currently_registered = true;
  			CampaignMember cm = [select status from CampaignMember where campaignid =: my_campaign.id and leadid = :ppt_id];
  			this.cm_status = '<span style="color:#5789AE;font-weight:bold;">' + cm.status + '</span><br />';
  		}
  		else {
  			this.currently_registered = false;
  			this.cm_status = '';
  		}
  		this.sem_doc = [select (Select Id, Name From Attachments) From Campaign c where c.id = :my_campaign.id].attachments;
  	}
  }

  public void cancel_seminar() {
  	register_issues = '';
  	Integer consult_count = [select count() from consult_inventory__c where scheduled_lead__c = :l.id and active__c = true and apt_date__c >= today and consult_room__r.room_type__c != 'Practice'];
  	Campaign c = [select startdate,time__c from Campaign where id = :Apexpages.currentPage().getParameters().get('cid')];
  	if(consult_count>0) {
  	  l.Call_Result__c = 'Consultation Scheduled';
  	  l.status = 'Consult Scheduled';
  	}
    else if(c.startdate == System.today())
      l.Call_Result__c = 'Same Day Cancellation Appointment';
    else
      l.Call_Result__c = 'Cancelled Appointment';
    CampaignMember cm = [select id,status from CampaignMember where campaignid = :Apexpages.currentPage().getParameters().get('cid') and leadid = :l.id];
      cm.status = 'Cancelled Seminar';
    try {
    	update l;
    	update cm;
    }
    catch (System.DmlException e) {
  	  for (Integer i = 0; i < e.getNumDml(); i++) {
        register_issues += '<span style="color:red;">' + e.getDmlMessage(i) + '</span><br />';
      }
    }
  }

  public boolean getdisplay_gold() {
  	try {
	  Lead mylead = [select leadscore__c from Lead where id = :l.id];
	  if(mylead.leadscore__c==null)
	    return false;
	  if(mylead.leadscore__c=='Gold')
	    return true;
	  else
	    return false;
  	}
  	catch (Exception e) {
  	  return false;
  	}
  }

  public void register_seminar() {
    register_issues = '';
    //insert a campaign member record for this campaign id and lead
    String cm_status;
    Campaign c = [select startdate,time__c from Campaign where id = :Apexpages.currentPage().getParameters().get('cid')];
    if(c.startdate == System.today())
      cm_status = 'Confirmed';
    else
      cm_status = 'Registered';
    System.debug('Num Guests : ' + Apexpages.currentPage().getParameters().get('nguests'));
    String guest_names =  '';
    for(upcoming_seminars us : all_upcoming_seminars) {
    	System.debug('Upcoming Seminar Id : ' + us.seminar_campaign.id + ' Register for : ' + Apexpages.currentPage().getParameters().get('cid'));
    	if(us.seminar_campaign.id==Apexpages.currentPage().getParameters().get('cid'))
    	  guest_names = us.guest_names;
    }
    System.debug('Guest Names : ' + guest_names);
    CampaignMember cm = new CampaignMember(campaignid = Apexpages.currentPage().getParameters().get('cid'),leadid = l.id,Status = cm_status, guest_names__c = guest_names, num_guests__c = Integer.valueof(Apexpages.currentPage().getParameters().get('nguests')));
    try {
    	l.Call_Result__c = 'Seminar Scheduled';
    	l.Status = 'Seminar Scheduled';
    	//work out the start time
    	Integer dt_hour;
    	Integer dt_minutes;
    	if(c.time__c==null) {
    		dt_hour = 12;
    		dt_minutes = 0;
    	}
    	else {
    		String[] time_split = c.time__c.split(':',2);
    		System.debug('Component 0 : ' + time_split[0] + ' Component 1 : ' + time_split[1]);
    		dt_hour = Integer.valueOf(time_split[0]);
    		String s_minute = time_split[1];
    		if(s_minute.contains('PM')) {
    			dt_hour += 12;
    			s_minute = s_minute.replace(' PM','');
    		}
    		else
    		  s_minute = s_minute.replace(' AM','');
    		System.debug('Hour : ' + dt_hour + ' Minute : ' + s_minute);
        dt_minutes = Integer.valueOf(s_minute);
    	}
    	Datetime seminar_time = Datetime.newInstance(c.startdate.year(),c.startdate.month(),c.startdate.day(),dt_hour,dt_minutes,0);
    	System.debug('Seminar Time : ' + seminar_time);
    	l.DateTime_Consult_Scheduled__c = seminar_time;
    	insert cm;
    	update l;
    	//send email and submit the print job
    	/*//modified by cm on 2015-10-19 - seminars are making a comeback?
    	//per Andy,  I'm pulling the letter and email piece out for now.  These will be handled via Eloqua and call center follow up for now.
    	Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Seminar Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
  	    insert bulk_print;
	    Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Seminar Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
	    insert t;
	    Lead my_lead = [select email from lead where id = :l.id];
	    if(my_lead.email!=null)
	      send_seminar_email();*/
    }
    catch (System.DmlException e) {
  	  for (Integer i = 0; i < e.getNumDml(); i++) {
        register_issues += '<span style="color:red;">' + e.getDmlMessage(i) + '</span><br />';
      }
    }
  }

	// 2017-02-27 Alon Waisman: This appears to be obsolete (see message above from Chris)... commenting out to improve test coverage.
  // public Pagereference send_seminar_email() {
  // 	try {
  //    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  //    EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Seminar_VF'];
  //    //mail.setSenderDisplayName(Userinfo.getUserName());
  //    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
  // if ( owea.size() > 0 ) {
  //   mail.setOrgWideEmailAddressId(owea.get(0).Id);
  // }
  //    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
  //    mail.setTemplateId(et.id);
  //
  //    //testing seminar email
  //    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
  //    CampaignMember cm = [select id,campaign.name,campaign.type,campaign.location_name__c,leadid,campaignid from campaignmember
  //     where campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid = :l.id order by createddate desc limit 1];
  //     for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: cm.campaignid]) {
  //     // Add to attachment file list
  //     Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
  //     efa.setFileName(a.Name);
  //     efa.setBody(a.Body);
  //     fileAttachments.add(efa);
  //     }
  //     if(fileAttachments.size()>0)
  //       mail.setFileAttachments(fileAttachments);
  //    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  // 	} catch (System.Emailexception e) {
  // 		Apexpages.addMessage(new ApexPages.Message(
  //       ApexPages.Severity.ERROR,
  //       'Caught email exception: ' + e));
  // 		return null;
  // 	}
  //   return null;
  // }

  public Integer getseminar_num() {
  	if(all_upcoming_seminars==null)
  	  getcenter_upcoming_seminars();
  	return all_upcoming_seminars.size();
  }

  public Integer getschedule_num() {
  	return [select count() from Consult_Inventory__c where scheduled_lead__c = :l.id and active__c = true and consult_room__r.room_type__c != 'Practice'];
  }

  public upcoming_seminars[] getcenter_upcoming_seminars() {
  	Lead my_lead = [select center__r.market__c,center__r.market__r.name from lead where id = :l.id];
	  all_upcoming_seminars = new upcoming_seminars[] {};
	  String rid = [Select id From RecordType where name = 'Seminars' and SobjectType = 'Campaign'].id;
	  System.debug('Record Type : ' + rid);
	  System.debug('My Lead : ' + my_lead.center__r.market__c);
	  if(my_lead.center__r.market__r.name=='San Jose' || my_lead.center__r.market__r.name=='Walnut Creek') {
	    //need to look up seminars for either market in this case
	    Set<ID> market_ids = new Set<ID> {};
	    for(Market__c m : [select id from Market__c where name in ('San Jose','Walnut Creek')])   {
	    	market_ids.add(m.id);
	    }
	    for(Campaign future_seminar : [Select c.Google_Doc_URL__c,c.Type, c.Time__c, c.Status, c.StartDate, c.Location_Name__c,c.center__c,c.center__r.name From Campaign c where c.center__r.market__c in :market_ids and c.recordtypeid=:rid and c.startdate>=today and c.isactive=true and c.type in ('Off-Site Seminar', 'Retirement Center Seminar', 'In House Seminar') limit 5]) {
	  		upcoming_seminars my_seminar = new upcoming_seminars(future_seminar,l.id);
	  		all_upcoming_seminars.add(my_seminar);
	  	}
	  }
	  else {
	  	for(Campaign future_seminar : [Select c.Google_Doc_URL__c,c.Type, c.Time__c, c.Status, c.StartDate, c.Location_Name__c,c.center__c,c.center__r.name From Campaign c where c.center__r.market__c = :my_lead.center__r.market__c and c.recordtypeid=:rid and c.startdate>=today and c.isactive=true and c.type in ('Off-Site Seminar', 'Retirement Center Seminar', 'In House Seminar') limit 5]) {
	  		upcoming_seminars my_seminar = new upcoming_seminars(future_seminar,l.id);
	  		all_upcoming_seminars.add(my_seminar);
	  	}
    }
  	return all_upcoming_seminars;
  }

  public List<ClearChoice_Doctor__c> getdoctor_list() {
  	List<ClearChoice_Doctor__c> doctor_list = new List<ClearChoice_Doctor__c>();
  	try {
  	  doctor_list = [Select c.Last_Name__c, c.First_Name__c, c.Doctor_type__c From ClearChoice_Doctor__c c where center_information__c = :l.center__c and active__c = true];
  	} catch (Exception e) {

  	}
  	return doctor_list;
  }

  public list<User> getpec_list() {
    list<User> pec_list = new list<User>();
    try {
      pec_list = [select name from user where center_pec__c = :l.center__c and center_administrator__c = false and isactive = true];
    } catch (Exception e) {

    }
    return pec_list;
  }

  public list<User> getca_list() {
  	list<User> ca_list = new list<User>();
    try {
      ca_list = [select name from user where center_pec__c = :l.center__c and center_administrator__c = true and isactive = true];
    } catch (Exception e) {

    }
    return ca_list;
  }

  public Boolean getpatient_sched_bool() {
  	Integer apt_count = [select count() from Consult_Inventory__c where scheduled_lead__c = :l.id and Active__c = TRUE and apt_date__c >= today and consult_room__r.room_type__c != 'Practice'];
  	if(apt_count==0)
  	  return false;
  	else
  	  return true;
  }

  public String getpatient_sched_status() {
  	String return_txt;
  	Integer apt_count = [select count() from Consult_Inventory__c where scheduled_lead__c = :l.id and Active__c = TRUE and apt_date__c >= today and consult_room__r.room_type__c != 'Practice'];
  	if(apt_count==0)
  	  return_txt = '<span class="blank" style="color:red;">Not Scheduled</span>';
  	else
  	  return_txt = '<span class="blank" style="color:blue;">Scheduled</span>';
  	return return_txt;
  }

  public boolean getisLeadValid() {
  	lead_valid_errors = '';
  	Lead myLead = [select createddate,mobilephone,work__c,inbound_call__c, refused_to_give_email__c,email,pre_screen__c,leadscore__c,fees_quoted__c,phone,cancellation_list_notes__c,hot_list__c,center__r.type__c from Lead where id = :l.id];
  	Profile p = [select name from profile where id = :Userinfo.getProfileId()];
  	if(p.Name == 'Call Center Agent - No Validation' ||
  	p.Name == 'Call Center Agent Jumpstart' ||
      p.Name == 'Outbound Call Center Agent Test' ||
      p.Name == 'Outbound Call Center Jumpstart' ||
			p.Name == 'Patient Education Consultant' ||
			p.Name == 'PEC - TPLAN' ||
			p.Name == 'PEC_MultipleCenters_VisiblePrescreen' ||
			p.Name == 'PEC_VisiblePrescreen' ||
			p.Name == 'PEC - Multiple Centers' ||
			p.Name == 'PEC - No Prescreen - PPF' ||
			p.Name == 'PEC - PPF - NoPScreen - TPlan' ||
			p.Name == 'PEC - Exam Center' ||
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
			p.Name == 'PEC - NoPScreen - No Dash' ||
 			p.Name == 'PEC - Multiple Centers' ||
			p.Name == 'PEC - Multiple Centers No Prescreen' ||
			p.Name == 'Outbound Call Center Agent' ||
			p.Name == 'FOA' ||
			p.Name == 'FOA - No Prescreen - TPlan' ||
			p.Name == 'FOA - No Prescreen') {
			System.Debug('Valid Lead - Exempt ');
  	  return true;
			}
  	else {
  	  //check to see if the lead is valid
  	  Boolean valid_lead = true;
  	  //email check
  	  /*if(mylead.inbound_call__c=='Dental Inquiry' && mylead.Refused_to_give_email__c==false &&
  	    mylead.email == null) {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Email must be filled in,  or refused to give email must be checked</span><br />';
  	    }*/
  	  //pre-screen check
  	  //if(mylead.pre_screen__c=='Red' && mylead.Fees_Quoted__c==null)
  	  if(mylead.leadscore__c=='Red' && mylead.Fees_Quoted__c==null && mylead.center__r.type__c<>'Network Center') {
  	  //   valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Red prescreen must have a fee quoted</span><br />';
  	  }
//lead check
  	  if(mylead.phone!=null) {
		 //   	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
		 //   	 Matcher myMatcher = mypattern.matcher(mylead.phone);
		 //   	 if(!myMatcher.matches()) {
		 //    valid_lead = false;
		 //   	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be all numeric</span><br />';
		 //   	 }
		 //  	 String formatted_phone = mylead.phone;
		 //  	 formatted_phone = formatted_phone.replace('(','');
		 //  	 formatted_phone = formatted_phone.replace(')','');
		 //  	 formatted_phone = formatted_phone.replace(' ','');
		 //  	 formatted_phone = formatted_phone.replace('-','');
		 //  String formatted_phone = mylead.phone.replaceAll('[^0-9]', '');
		 //   	 if(formatted_phone.length()>10) {
		 //    valid_lead = false;
		 //   	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be 10 digits or less</span><br />';
		 //   	 }
		 lead_valid_errors += phone_errors(mylead.phone, 'Phone');
  	  }
  	  Datetime phone_cutoff = Datetime.newinstance(2013,12,2,0,0,0);
  	  if(mylead.mobilephone!=null && mylead.createddate >= phone_cutoff ) {
		// 	  	Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
		// 	  	Matcher myMatcher = mypattern.matcher(mylead.mobilephone);
		// 	  	if(!myMatcher.matches()) {
		// 	  	  valid_lead = false;
		// 	  	  lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be all numeric</span><br />';
		// 	  	}
		// String formatted_phone = mylead.mobilephone;
		// formatted_phone = formatted_phone.replace('(','');
		// formatted_phone = formatted_phone.replace(')','');
		// formatted_phone = formatted_phone.replace(' ','');
		// formatted_phone = formatted_phone.replace('-','');
		// 	  	if(formatted_phone.length()>10) {
		//   valid_lead = false;
		// 	  	  lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be 10 digits or less</span><br />';
		// 	  	}
		lead_valid_errors += phone_errors(mylead.mobilephone, 'Mobile Phone');
  	  }
  	  if(mylead.work__c!=null && mylead.createddate >= phone_cutoff ) {
		 //   	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
		 //   	 Matcher myMatcher = mypattern.matcher(mylead.work__c);
		 //   	 if(!myMatcher.matches()) {
		 //    	   valid_lead = false;
		 //   	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be all numeric</span><br />';
		 //   	 }
		 //   	 String formatted_phone = mylead.work__c;
		 //   	 formatted_phone = formatted_phone.replace('(','');
		 //   	 formatted_phone = formatted_phone.replace(')','');
		 //   	 formatted_phone = formatted_phone.replace(' ','');
		 //   	 formatted_phone = formatted_phone.replace('-','');
		 //   	 if(formatted_phone.length()>10) {
		//    	   valid_lead = false;
		 //   	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be 10 digits or less</span><br />';
		 //   	 }
		 lead_valid_errors += phone_errors(mylead.work__c, 'Work Phone');
  	  }
  	  if(mylead.phone==null && mylead.inbound_call__c=='Dental Inquiry' && mylead.Work__c==null && mylead.MobilePhone==null) {
		// 	  	valid_lead = false;
  	  	lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must enter a phone number in the phone,  mobile,  or work phone fields</span><br />';
  	  }
  	  //cancellation notes check
  	  if(mylead.Hot_List__c==true) {
  	  	if(mylead.Cancellation_List_Notes__c==null) {
  	  //     valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	  	}
  	    else if(mylead.Cancellation_List_Notes__c.length() < 2) {
  	  //     valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	    }
  	  }
	  if (!String.isBlank(lead_valid_errors)) {valid_lead = false;}
  	  System.Debug('Valid Lead : ' + valid_lead);
  	  return valid_lead;
  	}
  }
  		private String phone_errors(String phone, String phone_name) {
			String errors = '';
			Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
			Matcher myMatcher = mypattern.matcher(phone);
			if(!myMatcher.matches()) {errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">' + phone_name + ' number must be all numeric</span><br />';}

			String formatted_phone = phone.replaceAll('[^0-9]', '');
			if(formatted_phone.length()>10) {errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">' + phone_name + ' number must be 10 digits or less</span><br />';}
			return errors;
		}
}