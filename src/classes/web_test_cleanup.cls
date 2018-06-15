public class web_test_cleanup {
  @future(callout=true)
  public static void clean_web_leads() {
    //pull a list of web test leads that have not been converted
    List<Lead> web_leads = [select id,name,createddate,createdby.name,phone,email from lead where email like '%+ostest%' and isconverted = false];
    List<Lead> leads_to_delete = new List<Lead>();
    Set<ID> delete_ids = new Set<ID>();
    for(Lead l : web_leads) {
      Integer hour_add = 24;
      //check to see if this is a 72 hour lead
      if(l.email.contains('+ostest72'))
        hour_add = 72;
      //for test scripts,  we want newly created leads deleted;
      if(test.isRunningTest())
        hour_add = 0;
      //now see if the lead should be deleted
      if(l.createddate.addhours(hour_add)<=system.now()) {
        leads_to_delete.add(l);
        delete_ids.add(l.id);
      }
    }
    
    //do we need to delete any leads?
    if(leads_to_delete.size()>0) {
      //check for any consult inventory/apt history tied to this lead and remove/update them
      List<Consult_Inventory__c> scheduled_apts = [select id,will_patient_show__c,will_patient_start__c,Scheduled_Lead__c,Scheduled_Account__c,scheduled_patient__c,treatment__c,Apt_Notes__c,
        Callback_Consult__c,Callback_Consult_PEC__c,confirmation_status__c,send_reminder__c,auto_reminder__c,gc_offered__c,leadscore_at_schedule_time__c,external_agent__c,Double_Consult__c,
        Scheduled_by__c from consult_inventory__c where scheduled_lead__c in :delete_ids];
      if(scheduled_apts.size()>0) {
	      for(Consult_Inventory__c appointment : scheduled_apts) {      
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
	      }
	    update scheduled_apts;
      }
      //see if we have any apt history entries to remove
      List<Apt_History__c> history_to_delete = [select id from apt_history__c where lead__c in :delete_ids];
      if(history_to_delete.size()>0)
        delete history_to_delete;
        
      String html_body = '<html><head><title>Web Leads Removed</title><style>tr.table_detail td {padding-bottom:2px;padding-top:4px;border-bottom:1px dashed #c5c5c5;padding-right:5px;padding-left:18px;} tr.table_header {color:white;background:#9E9E9E;} tr.table_header td {padding-left:20px;padding-right:20px;padding-top:5px;padding-bottom:2px;}' + 
	  '</style></head>' + 
	  '<body><div style="padding-left:20px;">The following leads have been removed from Salesforce through automation (' + leads_to_delete.size() + ' entries removed)<br /><br />' +
	    '<table cellpadding="0" cellspacing="0">' +
	      '<tr class="table_header"><td>Name</td><td>Email</td><td>Phone</td><td>Created By</td><td>Created Time</td></tr>';
	  for(Lead l : leads_to_delete) {
	  	html_body += '<tr class="table_detail"><td>' + l.name + '</td><td>' + l.email + '</td><td>' + l.phone + '</td><td>' + l.createdby.name + '</td><td>' + l.createddate.format('M/dd/yyyy hh:mm') + '</td></tr>';
	  }	   
	  html_body += '</table><br /></body></html>';
            
      //generate our email with details
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      //String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};	 
      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','webdev@clearchoice.com'};
	  mail.setToAddresses(toAddresses);
	  mail.setReplyTo('noresponse@clearchoice.com');
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
      if ( owea.size() > 0 ) {
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
      }
	  mail.setSubject('Web Test Leads Removed');
	  mail.setHtmlBody(html_body);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	
      delete leads_to_delete;
    }
  } 
}