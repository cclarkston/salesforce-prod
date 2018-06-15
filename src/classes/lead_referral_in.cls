public without sharing class lead_referral_in {
  public Lead referral_in {get; set;}
  Dental_Practice__c referring_dp;
  Practice_Doctor__c referring_pd;
  Center_Information__c ci;
  public Boolean display_lead_form {get; set;}
  public Boolean display_contact_section {get; set;}
  public String contact_method {get;set;}
  public Boolean sMonday {get;set;} 
  public Boolean sTuesday {get;set;}
  public Boolean sWednesday {get;set;}
  public Boolean sThursday {get;set;}
  public Boolean sFriday {get;set;}
  public Boolean sSaturday {get;set;}
  public Boolean sSunday {get;set;}
  public lead_consultschedule.next_consult[] search_consult_results;
  public Consult_Inventory__c block_form {get; set;}
  public Integer stime_filter {get;set;}
  public Integer etime_filter {get;set;}     
  public String search_issues {get;set;}
  public String schedule_issues {get;set;}
  public String lead_valid_errors {get; set;}
  public Boolean display_confirmation {get; set;}  
  
  public lead_referral_in () {
  	display_lead_form = true;
  	display_confirmation = false;
  	sMonday = true;
    sTuesday = true;
    sWednesday = true;
    sThursday = true;
    sFriday = true;
    sSaturday = true;
    sSunday = true;
    block_form = new Consult_Inventory__c(apt_date__c = System.today());
    stime_filter = 7;
    etime_filter = 23;
    lead_valid_errors = '';
  	display_contact_section = false;
  	User u = [select contact.account.dental_practice_partner__c from User u where id = :Userinfo.getuserid()];
  	if(u.contact.account.dental_practice_partner__c==null) {
  	  //grab the unknown center
  	  ci = [select id,name from Center_Information__c where name = 'Unknown'];
  	}
  	else {
  	  referring_dp = [select id,name,center_information__c from Dental_Practice__c where id = :u.contact.account.dental_practice_partner__c];
  	  System.debug(' DP : ' + referring_dp);
  	  referring_pd = [select id from Practice_Doctor__C where dental_practice__c = :referring_dp.id order by createddate limit 1];
  	  ci = [select id,name from Center_Information__c where id = :referring_dp.center_information__c];
  	}
  	try {
  		System.debug('Creating Lead ');
	  	referral_in = new Lead (inbound_call__c = 'Referral', center__c = ci.id, call_center_agent__c = userinfo.getuserid(), marketing_source__c = 'Referral Portal', call_result__c = 'Not Scheduled',
	  	  objection__c = 'Not Checked', status = 'Not Scheduled', Gender__c = 'Unknown', receive_text_reminder__c = false, receive_auto_reminder__c = true);
	  	if(referring_dp!=null)
	  	  referral_in.referral_office__c = referring_dp.id;
	  	if(referring_pd!=null)
	  	  referral_in.referral_doctor__c = referring_pd.id;
  	} catch (Exception e) {
  		System.debug('Error : ' + e);
  	}
  }
  
  public void update_lead_reminder_preference() {
 	try {
      update referral_in;
      //search for consult on the calendar that are for today or anytime in the future
	  Consult_Inventory__c ci = [select id,send_reminder__c,auto_reminder__c from Consult_Inventory__c where scheduled_lead__c = :referral_in.id and apt_date__c >= today and active__c = true limit 1];
	  ci.send_reminder__c = referral_in.receive_text_reminder__c;
	  ci.auto_reminder__c = referral_in.receive_auto_reminder__c;
	  update ci;
  	} catch(Exception e) {
  	  System.debug('Error ' + e.getmessage());
  	}
  }
  
  public String getformatted_consult_time() {
  	return referral_in.DateTime_Consult_Scheduled__c.format('M/dd/yyyy hh:mm:ss');
  }
  
  public List<SelectOption> getcontact_methods() {
  	List<selectoption> option_list = new List<SelectOption>();
  	option_list.add(new SelectOption('1','Request that we contact the patient'));
  	option_list.add(new SelectOption('2','Schedule patient for a consult now'));
  	return option_list;
  }
  
  public void create_new_referral() {
  	contact_method = '2';
  	if(referral_in.email!=null || referral_in.phone!=null) 
  	  try {
  	    insert referral_in;
        display_contact_section = true;
        display_lead_form = false;
  	  }
  	  catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error was encountered while trying to submit your referral.  Please correct the error or contact your rep for more assistance'));
        ApexPages.addMessages(e);
  	  }
  	else 
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide either a phone number or email address,  so that we are able to contact the referral.'));
  }
  
  public Integer getcontact_num() {
  	return [select count() from Task where whoid = :referral_in.id and activity_type__c = 'Inbound Call'];
  }
  
  public Integer getschedule_num() {
  	return [select count() from Consult_Inventory__c where scheduled_lead__c = :referral_in.id and active__c = true];
  }
  
  public lead_consultschedule.next_consult[] getsearch_consult_results() {
  	if(search_consult_results==null)
  	  search_consult_results = new lead_consultschedule.next_consult[] {};
  	return search_consult_results;
  }
  
  public List<Selectoption> getbetween_times() {
  	List<Selectoption> btimes = new List<Selectoption>();
  	for(Integer i=1;i<=23;i++) {
  		String option_label = '';
  		if(i>12) 
  		  option_label = string.valueOf((i-12)) + ' PM';
  		else if(i==12)
  		  option_label = 12 + ' PM';
  		else
  		  option_label = string.valueOf(i) + ' AM';  
  		btimes.add(new selectOption(string.valueof(i),option_label));
  	}
  	return btimes;
  }
  
  public void schedule_consult() {
  	Boolean schedule = true;
  	Integer num_issues = 0;
  	schedule_issues = '';
  	//make sure the patient is not already booked.
  	Integer i = [select count() from Consult_Inventory__c c where c.scheduled_lead__c = :referral_in.id and c.active__c = true and c.apt_date__c >= today and consult_show_status__c=null];
  	if(i>0) {
  	  schedule_issues += '<span class="blank" style="color:red;">Lead is currently scheduled for a consult.</span>You will not be able to schedule this consult until the existing appointment has been removed.  Please contact ClearChoice for assistance.<br />';
  	  schedule = false;
  	}
  	Consult_Inventory__c apt_check = [select c.consult_room__r.center_information__r.confirmation_email_address__c,c.consult_room__r.center_information__r.send_confirmation_email__c,c.consult_room__r.center_information__r.name,c.auto_reminder__c,c.send_reminder__c,c.consult_room__r.room_type__c,c.id,c.scheduled_account__c,c.start_hour_int__c,c.start_minute_int__c,c.scheduled_lead__c,c.scheduled_by__c,c.scheduled_time__c,c.consult_room__r.center_information__c,c.apt_date__c,c.pre_screen_type__c,c.consult_room__r.center_information__r.type__c, c.consult_room__r.center_information__r.Vantage_OfficeID__c,c.start_minute__c,c.start_hour__c from Consult_Inventory__c c where c.id = :apexpages.currentpage().getparameters().get('aid') for update];
  	if(apt_check.Scheduled_lead__c<>null && apt_check.scheduled_account__c<>null) {
  	  schedule = false;
  	  schedule_issues += '<span class="blank" style="color:red;">Sorry - Consult is no longer avaliable</span><br />';  
  	}
  	Lead my_lead = [select id,email,center__c,pre_screen__c,leadscore__c from lead where id = :referral_in.id];
  	if(apt_check.Consult_Room__r.center_information__c!=my_lead.center__c) {
  	  schedule = false;
  	  schedule_issues += '<span class="blank" style="color:red;">Consult is in a different center than the one the patient has been assigned to<br />Please update the patient record before trying to schedule here<br /></span>';
  	}
  	for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :apt_check.id and active_hold__c = true  and hold_by__c <> :Userinfo.getuserid()]) {
  		//see if the hold_time is less than 5 minutes old
  		Datetime h_end_time = ch.hold_time__c;
  		h_end_time = h_end_time.addHours(2);  		
  		if(System.now()<h_end_time) {
  			schedule = false;
  		  schedule_issues += '<span class="blank" style="color:red;">Block Held by : ' + ch.hold_by__r.name + '.<br />Hold will be released at : ' + h_end_time.format('M/dd/yyyy hh:mm:ss a') + '</span>';
  		}
  	}    	
  	if(schedule) {
  	  Integer next_seven = next_seven_count();
  	  //try and book the lead to this block  	
  	  apt_check.Scheduled_Lead__c = referral_in.id;
	  apt_check.Scheduled_by__c = Userinfo.getUserId();  	  
	  apt_check.scheduled_time__c = System.now();
	  apt_check.leadscore_at_schedule_time__c = my_lead.leadscore__c;
	  apt_check.auto_reminder__c = referral_in.receive_auto_reminder__c;
	  apt_check.send_reminder__c = referral_in.receive_text_reminder__c;
  	  System.debug('Days Between : ' + System.today().daysBetween(apt_check.apt_date__c));
  	  try {
	  	update apt_check;
	  	Apt_History__c history = new Apt_History__c(Consult_Inventory__c = apt_check.id, Lead__c = apt_check.scheduled_lead__c, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled',apts_in_next_seven__c = next_seven);
	    insert history;
	  	Time schedule_time = time.newInstance(Math.round(apt_check.Start_Hour_Int__c), math.round(apt_check.Start_Minute_Int__c), 0, 0);
  	    referral_in.DateTime_Consult_Scheduled__c = datetime.newInstance(apt_check.apt_date__c, schedule_time);
  	    referral_in.OBJECTION__c = null;
  	    referral_in.status = 'Consult Scheduled';
  	    if(System.today().daysBetween(apt_check.apt_date__c)<=3) 
	  	  referral_in.Confirmed_Appointment__c = true;
	  	else
		  referral_in.Confirmed_Appointment__c = false;
		referral_in.Could_not_Reach__c = false;
		referral_in.Left_Message_to_Confirm__c = false;
		Date today_date = system.today();  		
		referral_in.Call_Result__c = 'Consultation Scheduled';		  	 	    
  	    update referral_in; 
  	    try {
    	  Integer print_cnt = [select count() from Awaiting_Bulk_Print__c where batch_form__c = 'Welcome Letter' and lead_id__c = :referral_in.id and status__c = 'Pending'];
  	      if(print_cnt==0) {
			Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Welcome Letter', Lead_Id__c = referral_in.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
			insert bulk_print;	    
			Task t2 = new Task(WhoId = referral_in.Id, OwnerId = Userinfo.getUserId(), Subject = 'Welcome Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
			insert t2;
  	      }
    	  if(my_lead.email!=null) 
  	    	send_welcome_email(my_lead,'');  	        	        	      
  	   	} catch (Exception e) {
  			for (Integer i_cnt = 0; i_cnt < e.getNumDml(); i_cnt++) {
	           schedule_issues += e.getDmlMessage(i_cnt) + '<br />';
	           num_issues++; 
	        }  		  
		       Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		       String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		       mail.setToAddresses(toAddresses);
		       mail.setReplyTo('cmcdowell@acme.com');
		       mail.setSenderDisplayName('Apex error message');
		       mail.setSubject('Scheduling System Error - Welcome Letter');
		       mail.setPlainTextBody(e.getMessage());
		       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	        
	  	}	  	
  	  }	catch (System.DmlException e) {
  	     for (i = 0; i < e.getNumDml(); i++) {
            schedule_issues += e.getDmlMessage(i) + '<br />'; 
            num_issues++;
          }  		  
  		}
  	}
  	else
  	  //update the next avaliable search
  	  find_next_avaliable();  	
  	System.debug('Schedule Issues : ' + schedule_issues);  
  	if(num_issues==0) {
  	  display_confirmation = true;
  	  display_contact_section = false;
  	}	
  }  
  
  public void find_next_avaliable() {
  	//need to parse the filtered query and display the next five avaliable items.
  	search_issues = '';
  	Date sdate = block_form.Apt_Date__c;
  	Lead my_lead = [select center__c,pre_screen__c,leadscore__c from lead where id = :referral_in.id];
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.center_information__c = \'' + my_lead.Center__c + '\' and apt_date__c >= :sdate and dow_int__c in (';       
    Integer day_cnt = 0;
    if(sMonday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '1';
      day_cnt++; 
    }
    if(sTuesday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '2';
      day_cnt++; 
    }
    if(sWednesday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '3';
      day_cnt++; 
    }
    if(sThursday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '4';
      day_cnt++; 
    }
    if(sFriday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '5';
      day_cnt++; 
    }
    if(sSaturday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '6';
      day_cnt++; 
    }
    if(sSunday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '7';
      day_cnt++; 
    }
    if(day_cnt==0) {
      search_issues += '<span class="blank" style="color:red;">You did not select any days.</span>  No appointments will match your criteria<br />';
      next_filter += '9';
    }
    next_filter += ') and start_hour_int__c >= ' + stime_filter + ' and start_hour_int__c <= ' + etime_filter;	  	 
    if(stime_filter > etime_filter)
      search_issues += '<span class="blank" style="color:red;">Your starting time is greater than your ending time.</span>  No appointments will match your critera<br />';
    String query = '';      	
  	next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
    query = 'Select c.special_initiative__c,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c ' + next_filter;      
  	query += ' order by apt_date__c,start_hour_int__c,c.consult_room__r.room_type__c limit 20';
  	System.debug('Search Query : ' + query);
  	search_consult_results = new lead_consultschedule.next_consult[] {};
  	for(Consult_Inventory__c apt_matches : database.query(query)) {
  	   search_consult_results.add(new lead_consultschedule.next_consult(apt_matches));
  	}  	
  }
  
  public void send_welcome_email(Lead my_lead,String initiative) {
  	try {  	
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0'];	    
	    //mail.setSenderDisplayName(Userinfo.getUserName());
	    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
		if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}  
	    mail.setTargetObjectId(my_lead.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);	   
 		  if(initiative=='Workshop') {
			  List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();					    
	      for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: my_lead.center__c and name like 'Workshop%' order by createddate desc limit 1]) {
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
	    schedule_issues += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR, 
        'Caught email exception: ' + e));
      schedule_issues += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';      
  	}
  }
  
  public Integer next_seven_count() {
  	Date sdate = System.today();
  	Date edate = sdate.adddays(7);
  	String query = '';
  	
  	Lead my_lead = [select center__c,pre_screen__c,leadscore__c from lead where id = :referral_in.id];
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.center_information__c = \'' + my_lead.Center__c + '\' and apt_date__c >= :sdate and apt_date__c <= :edate';       
  	next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
      query = 'Select id From Consult_Inventory__c c ' + next_filter;      
  	Integer apt_count = 0;
  	try {
  	  List<Consult_Inventory__c> ci_list =  database.query(query);
  	  apt_count = ci_list.size();	
  	}
  	catch (Exception e) {
  		
  	}
  	return apt_count;  	
  }
}