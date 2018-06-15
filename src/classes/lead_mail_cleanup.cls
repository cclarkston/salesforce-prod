global class lead_mail_cleanup {
	
  /*modified by cm on 4/18/2017
    major re-write - the process should now be able to handle processing a large number of records in a single go.  Cleaned up some queries inside of for loops and handled
    trigger changes inside of script so I could mark util_context as completed already.
  */
	
  static EmailTemplate bcp_prescreen = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF_6_0'];
  static EmailTemplate bcp_no_prescreen = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF_6_0_no_prescreen'];
  static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];

  @future
  public static void check_for_lead_cleanup() {
  	List<Awaiting_Bulk_Print__c> bulk_list = new List<Awaiting_Bulk_Print__c>();
  	List<Task> task_list = new List<Task>();
  	Messaging.SingleEmailMessage[] email_list = new Messaging.SingleEmailMessage[]{};  	
  	
  	Set<ID> finished_leads = new Set<ID>();  
  	
  	//pull the list of leads to clean up  	
    List<Lead> process_leads = [select id,name,email,pre_screen__c,bcp_dvd_packet_sent__c,ignoreValidation__c from lead where createddate >= last_week and marketing_source__c = 'CCWebsiteOSI'
      and last_marketing_source__c = null and pre_screen__c in ('Green','Yellow','Red') and bcp_dvd_packet_sent__c = false and email_welcome_packet_sent__c = false and Welcome_Packet_Sent__c = false
      and isconverted = false and id not in (Select Lead_Id__c From Awaiting_Bulk_Print__c) and phone_length__c = 14 and center__r.allow_bulk_printing__c = true limit 8];
    Set<ID> all_lead_ids = new Set<ID>();
    for(lead l :process_leads) {
      all_lead_ids.add(l.id);
    }
    //build a map of relevant tasks for these leads
    Map<Id,Integer> task_count_map = new Map<ID,Integer>();
    for(AggregateResult ar : [select whoid,count(id) num_emails from task where whoid in :all_lead_ids and subject = 'Email: Thank you for contacting ClearChoice Dental Implant Center' group by whoid]) {
      task_count_map.put((ID)ar.get('whoid'),(Integer)ar.get('num_emails'));
    }
          
    for(Lead l : process_leads) {
      if(l.email==null) {
        Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'BCP Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
  	    bulk_list.add(bulk_print);
        Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'BCP Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
        task_list.add(t);
      }
      else {
      	//make sure there was not already a BCP email - Email: Thank you for contacting ClearChoice Dental Implant Center
      	if((task_count_map.get(l.id)==null?0:task_count_map.get(l.id))==0) {
	      	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    EmailTemplate et;
		    //per Vince - use the new format for all centers regardless of signup
		    if(l.pre_screen__c=='Green' || l.pre_screen__c=='Yellow' || l.pre_screen__c=='Red')
		      et = bcp_prescreen;
		    else
		      et = bcp_no_prescreen;		    
			if ( owea.size() > 0 ) {
			  mail.setOrgWideEmailAddressId(owea.get(0).Id);
			}  
		    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
		    mail.setTemplateId(et.id);
		    email_list.add(mail);
		    l.BCP_DVD_Packet_Sent__c = true;
      	} else {
      	  l.bcp_dvd_packet_sent__c = true;
      	  l.ignoreValidation__c = true;
      	}
      }
    }
    
    Util_TriggerContext.setalreadyProcessed();
    
    if(bulk_list.size()>0) {
      try {
      	insert bulk_list;
      	insert task_list;
      }  catch (Exception e) {
      	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Lead CleanUp Insert Issue');
 		message.setPlainTextBody('Failed During Insert Call /r/n' + bulk_list + ' ' + task_list + ' ' + 'Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      }
    } 
    
    if(email_list.size()>0) {
      try {
        Messaging.sendEmail(email_list,false);
      } catch (Exception e) {
      	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Lead CleanUp Email Issue');
 		message.setPlainTextBody('Failed During Email Send ' + email_list + ' ' + 'Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });      	
      }
    }  
    
    try {
      update process_leads;
    } catch (Exception e) {
    	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Lead CleanUp - Lead Update');
 		message.setPlainTextBody('Failed During BCP Update ' + process_leads + ' ' + e.getMessage() + ' Stack : ' + e.getStackTraceString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });   
    }
    
    /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setHtmlBody('<html><body>Lead Cleanup Completed<br />Process Leads : ' + process_leads + '<br /><br />Email List : ' + email_list + '<br /><br />Bulk List : ' + bulk_list + '</body></html>');
		mail.setReplyTo('cmcdowell@clearchoice.com');
        mail.setSubject('Lead CleanUp - Lead Update');
    	mail.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/   
  }

}