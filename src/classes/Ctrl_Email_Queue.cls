public with sharing class Ctrl_Email_Queue {
  @future(callout=true)
  public static void send_email_queue() {
  	User default_sender;
  	try {
      //default_sender = [select id,name from user where name = 'Carrie Strohmeyer' limit 1];
      default_sender = [select id,name from user where name = 'Pat Greenwood' limit 1];
  	}
  	catch (Exception e) {
  	  default_sender = null; 
  	  System.debug('Exception was : ' + e);
  	}
  	Map<String,Id> Email_Template_Map = new Map<String,Id>(); 
    Set<String> all_templates = new Set<String>(); 	
  	for(AggregateResult ar : [select template_name__c from Email_Queue__c where email_sent__c = false group by template_name__c]) {
      all_templates.add((String)ar.get('template_name__c'));
  	}
  	for(EmailTemplate et : [select id,developername from emailtemplate where isactive = true and developername in :all_templates]) {
  		email_template_map.put(et.developername,et.id);
  	}  	
  	System.debug('Email Template Map : ' + email_template_map);
  	List<Email_Queue__c> waiting_emails = [select template_name__c,target_id__c,seminar_id__c,email_sent__c,email_sent_time__c from Email_Queue__c where email_sent__c = false]; 
  	for(Email_Queue__c eq : waiting_emails) {
  		try {  	
		    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    //EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'Seminar_VF'];
		    /*if(default_sender==null)	    
		    	mail.setSenderDisplayName(Userinfo.getUserName());
		    else
		      mail.setSenderDisplayName(default_sender.name);*/
			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
			if ( owea.size() > 0 ) {
			  mail.setOrgWideEmailAddressId(owea.get(0).Id);
			}  
		    mail.setTargetObjectId(eq.target_id__c); //Specify who the email should be sent to.
		    mail.setTemplateId(email_template_map.get(eq.template_name__c));
		    
		    ///adding in the new seminar ics piece here
		    if(eq.Seminar_Id__c!=null && eq.Target_Id__c!=null) {		    	
			    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
			    try {
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
					    	AND leadid = :eq.Target_Id__c
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
			    
			    //testing seminar email
			    //List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
			    
		        for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: eq.seminar_id__c]) {
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
			    }
			    catch(Exception e) {	    
			    }
			    if(fileAttachments.size()>0)
	        	mail.setFileAttachments(fileAttachments);
        }
        	
      	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
      	eq.Email_Sent__c = true;
      	eq.Email_Sent_Time__c = System.now();
	  	} catch (System.Emailexception e) {
	  		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		    mail.setToAddresses(toAddresses);
		    mail.setReplyTo('cmcdowell@clearchoice.com');
		    mail.setSenderDisplayName('Apex error message');
		    mail.setSubject('Email Queue Error - On Template Send');
		    mail.setPlainTextBody(e.getMessage());
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	}	  	
  	}
  	try {
  		if(waiting_emails.size() > 0)
  		  update waiting_emails;
  	}
  	catch (Exception e) {
  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	    mail.setToAddresses(toAddresses);
	    mail.setReplyTo('cmcdowell@clearchoice.com');
	    mail.setSenderDisplayName('Apex error message');
	    mail.setSubject('Email Queue Error - On Update');
	    mail.setPlainTextBody(e.getMessage());
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	    
  	}
  }
  

}