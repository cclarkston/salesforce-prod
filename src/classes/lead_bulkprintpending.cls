public without sharing class lead_bulkprintpending {
  private final Lead l;
  public ID delrecordid {get; set;}
  public boolean displaybulkprintqueue;
  ApexPages.Standardcontroller con;
  public String email_result {get; set;}
  public String confirmation_template {get; set;}
  public string lead_valid_errors {get; set;}
  
  // The extension constructor initializes the private member 
  // variable acct by using the getRecord method from the standard 
  // controller. 

  public lead_bulkprintpending(ApexPages.StandardController stdController) {
    this.l = (Lead)stdController.getRecord();
    con = stdController;
  }
  
  public String getparent_id() {
  	return l.id;
  }
  
  public boolean getnetwork_center_record() {
  	if(l.center__r.type__c=='Network Center')
  	  return true;
  	else
  	  return false;
  }
  
  public void check_lead_record() {  	
  	Lead my_lead = [select call_center_agent__c from lead where id = :l.id];
  	if(my_lead.Call_Center_Agent__c==null) {
  		try {
  		  my_lead.call_center_agent__c = Userinfo.getUserId();
  		  update my_lead;
  		}
  		catch (Exception e) {
  			email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Call Center Agent is currently blank and needs to be filled out</span><br />';
  		}
  	}
  }
  
  public Pagereference send_bcp_email() {  	
    try {  	
    	email_result = '';
    	check_lead_record();
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    //EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF'];
	    EmailTemplate et;
	    Lead test_lead = [select id,center__r.transunion_eligible__c,pre_screen__c from Lead where id = :l.id];
	    //if(test_lead.center__r.transunion_eligible__c)
	    //per Vince - use the new format for all centers regardless of signup
	    if(test_lead.pre_screen__c=='Green' || test_lead.pre_screen__c=='Yellow' || test_lead.pre_screen__c=='Red')
	      et = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF_6_0'];
	    else
	      et = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF_6_0_no_prescreen'];
	    //else
	      //et = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF_5_0'];
	      
	    //new version of the letter rolled out with the credit letter offer
	    //this is on hold for now
	    //EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_v_3_0'];	    
	    /*//Documentation states that you can not currently use the bcc or cc features when using an email template
	    User cc = [select id,email from user where id = :userinfo.getUserId()];
	    String[] cc_list = new String[] {};
	    cc_list.add(cc.email);
	    mail.setCcAddresses(cc_list);*/
	    //mail.setReplyTo('test_bucket@clearchoice.com');
	    //mail.setSenderDisplayName(Userinfo.getUserName());
	    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
		if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}  
	    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    email_result += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR, 
        'Caught email exception: ' + e));
      email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';      
  		return null;
  	}
    return null;
  }
  
  public Pagereference send_welcome_email() {
  	try {  	
  		email_result = '';
  		check_lead_record();
  		Lead test_lead = [select id,center__r.transunion_eligible__c,pre_screen__c,datetime_consult_scheduled__c,center__r.name from Lead where id = :l.id];
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_VF'];
		//EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_VF_5_0'];
		EmailTemplate et;
		Datetime move_date = datetime.newinstance(2015,12,7,0,0,0);
		if(test_lead.pre_screen__c=='Green' || test_lead.pre_screen__c=='Yellow' || test_lead.pre_screen__c=='Red') {
		  if(test_lead.center__r.name=='Miami Fort Lauderdale' && test_lead.datetime_consult_scheduled__c >= move_date && System.now() < move_date)
		    et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_new_FTL'];
		  else
		    et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0'];
		}
		else {
		  if(test_lead.center__r.name=='Miami Fort Lauderdale' && test_lead.datetime_consult_scheduled__c >= move_date && System.now() < move_date)
		    et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen_FTL'];
		  else
		    et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen'];
		}
			//new version of the letter rolled out with the credit letter offer
			//on hold for now
			//EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v3_0'];	 	    
	    mail.setSenderDisplayName(Userinfo.getUserName());
	    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);
	    
	    //testing seminar email
	    /*List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
      for (Attachment a : [select Name, Body, BodyLength from Attachment]) {
		    // Add to attachment file list
		    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
		    efa.setFileName(a.Name);
		    efa.setBody(a.Body);
		    fileAttachments.add(efa);
      }	    
      if(fileAttachments.size()>0)
        mail.setFileAttachments(fileAttachments);*/
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    email_result += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR, 
        'Caught email exception: ' + e));
      email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';      
  		return null;
  	}
    return null;
  }
  
  public Pagereference send_seminar_email() {
  	try {  	
  		email_result = '';
  		check_lead_record();
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Seminar_VF'];	    
	    //mail.setSenderDisplayName(Userinfo.getUserName());
	    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
	    if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}  
	    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);
	    
	    //testing seminar email
	    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
	    CampaignMember cm = [
	    	SELECT id, 
	    	 campaign.name, campaign.type, campaign.location_name__c,
	    	 campaign.StartDate, campaign.Time__c, campaign.EndDate,
	    	 campaign.Location_Address__c, campaign.Location_Postal_Code__c,
			 campaign.Location_State__c, campaign.Location_City__c, campaign.Location_Street__c,
			 campaign.Description, campaign.Phone_Number__c, 
			 campaign.Center__r.State__c,
			 campaign.Center__r.Time_Zone__c,
	    	 leadid, campaignid 
	    	FROM campaignmember 
		    WHERE campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House') 
		    	AND leadid = :l.id
		    ORDER BY createddate DESC
		    LIMIT 1];
		    
		// Start ICS file attachment	    
      String startDate = String.valueof(cm.campaign.StartDate.year());
	  startDate += String.valueof(((cm.campaign.StartDate.month()<10)? '0':'')+cm.campaign.StartDate.month());
	  startDate += String.valueof(((cm.campaign.StartDate.day()<10)? '0':'')+cm.campaign.StartDate.day());
	 	  
	  String endDate = startDate;
	  Boolean allDay = (cm.campaign.Time__c != null) ? false : true;
	  	  
	  if(cm.campaign.EndDate != null){
		  endDate = String.valueof(cm.campaign.EndDate.year());
		  endDate += String.valueof(((cm.campaign.EndDate.month()<10)? '0':'')+cm.campaign.EndDate.month());
		  endDate += String.valueof(((cm.campaign.EndDate.day()<10)? '0':'')+cm.campaign.EndDate.day());
	  } else {
	  	endDate = String.valueof(cm.campaign.StartDate.year());
		endDate += String.valueof(((cm.campaign.StartDate.month()<10)? '0':'')+cm.campaign.StartDate.month());
		Integer newEndDay = cm.campaign.StartDate.day()+((allDay)?1:0);
		endDate += String.valueof(((newEndDay<10)? '0':'') + newEndDay);
	  }
	  
	  if(allDay == false){
	  	system.debug(cm.campaign.Time__c);
	  	Time myNewTime = fnct.strToTime(cm.campaign.Time__c);
	  	system.debug(myNewTime);
	  	
	  	DateTime convertedGMTDate = fnct.setGMTTime(datetime.newinstance(
		  		cm.campaign.StartDate.year(), cm.campaign.StartDate.month(), cm.campaign.StartDate.day(), 
		  		myNewTime.hour(), myNewTime.minute(), myNewTime.second()),
	  		
	  		cm.campaign.Center__r.Time_Zone__c, ((cm.campaign.Center__r.State__c == 'AZ')?true:false));
	  	system.debug(convertedGMTDate);
	  	
	  	Integer myHour = convertedGMTDate.hour();
	  	Integer myMinute = convertedGMTDate.minute();
	  	Integer mySecond = convertedGMTDate.second();
	  	
	  	String myStartHour = ((myHour<10)?'0'+String.ValueOf(myHour)
	  		:String.ValueOf(myHour));
	  	String myEndHour = (((myHour+2)<10)?'0'+String.ValueOf((myHour+2))
	  		:String.ValueOf((myHour+2)));
	  		
	  	String myStartMinute = ((myMinute<10)?'0'+String.ValueOf(myMinute)
	  		:String.ValueOf(myMinute));
	  	String myStartSecond = ((mySecond<10)?'0'+String.ValueOf(mySecond)
	  		:String.ValueOf(mySecond));
	  		
	  	startDate += 'T' + myStartHour + myStartMinute + myStartSecond;
	  	endDate += 'T' + myEndHour + myStartMinute + myStartSecond;
	  }
      
      String ICSString = 'BEGIN:VCALENDAR'+'\n'+
			'VERSION:2.0'+'\n'+
			'BEGIN:VEVENT'+'\n'+
			'DTSTART;TZID=GMT'+(allDay ? ';VALUE=DATE' : '')+':'+startDate+'\n'+
			'DTEND;TZID=GMT'+(allDay ? ';VALUE=DATE' : '')+':'+endDate+'\n'+
			'SUMMARY:'+cm.campaign.name+'\n'+
			'LOCATION:'+cm.campaign.Location_Street__c+', '+cm.campaign.Location_City__c+' '
				+cm.campaign.Location_State__c+' '+cm.campaign.Location_Postal_Code__c+'\n'+
			'DESCRIPTION:'
				+cm.campaign.Description+'\\n'
				+cm.campaign.location_name__c+'\\n'
				+cm.campaign.Location_Street__c+'\\n'
				+cm.campaign.Location_City__c+' '+cm.campaign.Location_State__c+' '+cm.campaign.Location_Postal_Code__c+'\\n'
				+((cm.campaign.Phone_Number__c != null) ? cm.campaign.Phone_Number__c : '')
				+'\\n\\n\\n' + '\n';
      
      for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: cm.campaignid]) {
		    // Add to attachment file list
		    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
		    efa.setFileName(a.Name);
		    efa.setBody(a.Body);
		    fileAttachments.add(efa);
		    
		    // Add file to ICS file
		    ICSString += 'ATTACH;ENCODING=BASE64;VALUE=BINARY;X-FILENAME="' + a.Name + '":'+
		    	EncodingUtil.base64Encode(a.Body)+'\n';
      }	   

      Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
	  efa.setFileName(cm.campaign.name+'.ics');
	  efa.setContentType('text/calendar');	  	  
	  efa.setBody(Blob.valueof(ICSString+
			'PRIORITY:3'+'\n'+
			'END:VEVENT'+'\n'+ 
			'END:VCALENDAR'));
	  fileAttachments.add(efa);
	  
      if(fileAttachments.size()>0)
        mail.setFileAttachments(fileAttachments);
	  
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	  email_result += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR, 
        'Caught email exception: ' + e));
      email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';      
  		return null;
  	}
    return null;
  }
  
  public Pagereference send_confirmation_email() {
  	try {  	
  		email_result = '';
  		check_lead_record();
  		//figure out which template to use
  		Lead my_lead = [Select l.Language_Spoken__c, l.Confirmed_Appointment__c From Lead l where id = :l.id];
  		if(my_lead.Confirmed_Appointment__c==true) {
  			if(my_lead.Language_Spoken__c=='Spanish')
  			  confirmation_template = 'Friendly_reminder_spanish_V';
  			else
  			  confirmation_template = 'Friendly_Reminder_V';   			 
  		}
  		else {
  			if(my_lead.Language_Spoken__c=='Spanish')
  			  confirmation_template = 'Appointment_Confirmation_Spanish';
  			else
  			  confirmation_template = 'Appointment_Confirmation_New';
  		}  		
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = :confirmation_template];	    
	    //mail.setSenderDisplayName(Userinfo.getUserName());
	    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);
	    //mail.setReplyTo('confirmation-team@clearchoice.com');
	    //mail.setSenderDisplayName('ClearChoice Confirmation Team');
	    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
	    if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}  
	    mail.setUseSignature(false);	    
	    
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    email_result += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR, 
        'Caught email exception: ' + e));
      email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';      
  		return null;
  	}
    return null;
  }
  
  public Pagereference send_bcp() {
  	try {
  		email_result = '';
  	  check_lead_record();
  	  Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'BCP Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
  	  insert bulk_print;
      Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'BCP Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
      insert t;
  	  displaybulkprintqueue = check_queue_size();
  	}
  	catch (Exception e) {
  		email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Letter Not submitted<br />' + e + '</span>';
  	}
  	return null;  	
  }
  
  public Pagereference send_welcome() {
  	//Lead my_lead = [select id,trigger_referral_source__c from lead  where id = :l.id];
  	//if(my_lead.Trigger_Referral_Source__c=='NA') 
  		//email_result = '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;display:block;text-align:center;">Error - Welcome letter can not be sent while the trigger referral source = NA.<br /><span style="color:black;">  Please update the record and try again.</span></span>';
  	//else {
  	try {
  		email_result = '';
  		check_lead_record();
      Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Welcome Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
	    insert bulk_print;	    
	    Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Welcome Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
	    insert t;
	    displaybulkprintqueue = check_queue_size();
  	}
  	catch (System.DmlException e) {
  		email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;display:block;text-align:center;">Error - ' + e.getMessage() + '</span>';
	    Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	    mail.setToAddresses(toAddresses);
	    mail.setReplyTo('cmcdowell@clearchoice.com');
	    mail.setSenderDisplayName('Apex error message');
	    mail.setSubject('Welcome Letter Error');
	    mail.setPlainTextBody(e.getMessage());
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	        
  	}  		
  	return null; 	
  }  
  
  public Pagereference send_seminar() {
  	try {
  		check_lead_record();
	    Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Seminar Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
	  	insert bulk_print;
		  Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Seminar Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
		  insert t;  	
	  	displaybulkprintqueue = check_queue_size();
  	}
  	catch (Exception e) {
  		email_result += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;display:block;text-align:center;">Error - ' + e.getMessage() + '</span>';
  	}
	  return null;
	   	
  }  
  
  public Boolean getdisplay_bulkqueue() {
  	User u = [select bulk_printing__c from user where id = :Userinfo.getUserId()];
  	return u.bulk_printing__c;
  }
  
  public Pagereference bulk_queue() {
  	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','display_queue');
  	pr.setredirect(true);
    return pr;   
  }
  
  public Pagereference single_bcp() {
  	check_lead_record();
  	Pagereference pr = new PageReference('/apex/single_print'); 
  	pr.getParameters().put('form_num','1');
  	pr.getParameters().put('id',l.id);
  	pr.setredirect(true);
    return pr;   
  }
  
  public Pagereference single_welcome() {
  	check_lead_record();
  	Pagereference pr = new PageReference('/apex/single_print'); 
  	pr.getParameters().put('form_num','2');
  	pr.getParameters().put('id',l.id);
  	pr.setredirect(true);
    return pr;     	
  }
  
  public Pagereference single_seminar() {
  	check_lead_record();
  	Pagereference pr = new PageReference('/apex/single_print'); 
  	pr.getParameters().put('form_num','3');
  	pr.getParameters().put('id',l.id);
  	pr.setredirect(true);
    return pr;   
  }
  
  public boolean check_queue_size() {
  	Integer cnt = [select count() from awaiting_bulk_print__c where lead_id__c = :l.id];
  	if(cnt>0)
  	  return true;
  	else
  	  return false;
  }
  
  public Boolean getdisplay_confirmationemail() {
  	Lead ltest = [select id,datetime_consult_scheduled__c,center__r.type__c from lead where id = :l.id];
		if(ltest.DateTime_Consult_Scheduled__c==null || ltest.center__r.type__c=='Network Center')
		  return false;
		else
		  return true;
  }
  
  public Boolean getdisplay_seminaremail() {
    Integer row_count = [select count() from campaignmember 
			where campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House') and leadid = :l.id  limit 1];
	  Lead ltest = [select id,datetime_consult_scheduled__c from lead where id = :l.id];
		if(row_count==0 || ltest.DateTime_Consult_Scheduled__c==null)
		  return false;
		else
		  return true;
  }

  public Boolean getdisplaybulkprintqueue() {
  	if(displaybulkprintqueue==null) {
  	  displaybulkprintqueue = check_queue_size(); 
  	}
  	return displaybulkprintqueue;
  }
  
  public PageReference removePrintJob() {
  	System.debug('Deleting Awaiting Pring Job Id : ' + delrecordid);
  	Awaiting_Bulk_Print__c delete_job = [select id from Awaiting_Bulk_Print__c where id = :delrecordid];
  	delete delete_job;
  	displaybulkprintqueue = check_queue_size();
  	return null;
  }
  
  PrintJob[] print_list;
  public class PrintJob {
  	public Awaiting_Bulk_Print__c print_job {get; set;}
  	public boolean display_delete {get; set;}
  	public PrintJob(Awaiting_Bulk_Print__c my_print_job) {
  		this.print_job = my_print_job;
  		Integer admin_count = [select count() from Profile where name in ('Data Audit Team','System Administrator','RBD','New System Administrator','System Administration - Test','Call Center - Supervisor','Call Center - Supervisor Test','Call Center Agent Lead','CC Administrator','CC Schedule Admin') and id = :Userinfo.getProfileId()];
  		if(my_print_job.Submitted_By__c==Userinfo.getUserId() || admin_count > 0)
  		  this.display_delete=true;
  		else
  		  this.display_delete = false;
  	}
  }
  
  public PrintJob[] getbulkjobs() {	
 		print_list = new PrintJob[] {};  	
  	list <Awaiting_Bulk_Print__c> print_jobs = [Select a.Submitted_Time__c, a.Submitted_By__c, a.Name, a.Id, a.Batch_Form__c,a.Submitted_By__r.Name From Awaiting_Bulk_Print__c a where a.lead_id__c = :l.id];
  	for(Awaiting_Bulk_Print__C pj : print_jobs ) {
  		print_list.add(new PrintJob(pj));
  	}
  	return print_list; 
  }
  
  public boolean getisLeadValid() {
  	lead_valid_errors = '';
  	Lead myLead = [select createddate,work__c,mobilephone,inbound_call__c, refused_to_give_email__c,email,pre_screen__c,leadscore__c,fees_quoted__c,phone,cancellation_list_notes__c,hot_list__c,center__r.type__c,center__r.allow_bulk_printing__c from Lead where id = :l.id];
  	Profile p = [select name from profile where id = :Userinfo.getProfileId()];
  	if(p.Name == 'Call Center Agent - No Validation' || 
  	  p.Name == 'Call Center Agent Jumpstart' ||
			 p.Name == 'Outbound Call Center Agent Test' ||
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
			p.Name == 'PEC - NoPScreen - No Dash' ||
			p.Name == 'PEC - PPF - No Prescreen' ||
			p.Name == 'PEC - PFF - Application Date' ||
			p.Name == 'PEC - Denver' ||
			p.Name == 'FOA - TPLAN' ||
			p.Name == 'PEC - Denver - FOA' ||
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
  	  //see if the center allows printing
  	  if(!mylead.center__r.allow_bulk_printing__c) {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">This center does not allow printing.  Please select a different center,  or contact your supervisor.</span><br />';
  	  }
  	  //pre-screen check
  	  //if(mylead.pre_screen__c=='Red' && mylead.Fees_Quoted__c==null)  	  
  	  if(mylead.leadscore__c=='Red' && mylead.Fees_Quoted__c==null && mylead.center__r.type__c<>'Network Center') {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Red prescreen must have a fee quoted</span><br />';
  	  }
  	  //lead check
  	  if(mylead.phone!=null) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(mylead.phone);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;  	 
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be all numeric</span><br />';
  	  	 } 	   
  	  	 String formatted_phone = mylead.phone;
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
  	  if(mylead.mobilephone!=null && mylead.createddate >= phone_cutoff ) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(mylead.mobilephone);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;  	 
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be all numeric</span><br />';
  	  	 } 	   
  	  	 String formatted_phone = mylead.mobilephone;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  if(mylead.work__c!=null && mylead.createddate >= phone_cutoff ) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(mylead.work__c);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;  	 
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be all numeric</span><br />';
  	  	 } 	   
  	  	 String formatted_phone = mylead.work__c;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  if(mylead.phone==null && mylead.inbound_call__c=='Dental Inquiry' && mylead.Work__c==null && mylead.MobilePhone==null) {
  	  	valid_lead = false;
  	  	lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must enter a phone number in the phone,  mobile,  or work phone fields</span><br />';
  	  }
  	  //cancellation notes check
  	  if(mylead.Hot_List__c==true) {
  	  	if(mylead.Cancellation_List_Notes__c==null) {  	  
  	      valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	  	}
  	    else if(mylead.Cancellation_List_Notes__c.length() < 2) {
  	      valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	    }
  	  }
  	  System.Debug('Valid Lead : ' + valid_lead);
  	  return valid_lead;
  	}
  }
}