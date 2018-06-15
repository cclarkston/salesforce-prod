/*modified by cm on 2015-05-18
commenting out most of this.  These reports haevn't gone to an active person in years now,  and they probably wouldn't be valid at this point anyways
*/
global class LeadershipEmail {
  @future(callout=true)
  public static void sendCenterRevEmail() {       
  /*  EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'CurrentRevDrivers'];
    
    for(User recipient : [select id, firstname from user where name in ('Chris McDowell','David Waltzer','Edmund Smith')  and isactive = true]) {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setSenderDisplayName('Salesforce Admin');
      mail.setTemplateId(et.id);
      mail.saveAsActivity = false;
      mail.setTargetObjectId(recipient.id); // Specify who the email should be sent to.
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }*/    
  }
  
  @future(callout=true)
  public static void sendCenterYearlyRevEmail() {       
    /*EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'CenterYearlyRev'];
    
    for(User recipient : [select id, firstname from user where name in ('Chris McDowell','Chelsea Klinke','David Waltzer')  and isactive = true]) {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setSenderDisplayName('Salesforce Admin');
      mail.setTemplateId(et.id);
      mail.saveAsActivity = false;
      mail.setTargetObjectId(recipient.id); // Specify who the email should be sent to.
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    } */   
  }
  
  @future(callout=true)
  public static void sendCCDashEmail() {
    try {
	  	/*EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'CC_Dashboard'];
	    
	    for(User recipient : [select id, firstname from user where name in ('Chris McDowell','Meridith Hertach','Kathryn Bingman','Scott Lawrence') and isactive = true]) {
	    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    	mail.setSenderDisplayName('Salesforce Admin');
	      mail.setTemplateId(et.id);
	      mail.saveAsActivity = false;
	      mail.setTargetObjectId(recipient.id); // Specify who the email should be sent to.
	      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    }*/
    }
    catch(Exception e) {		  
	      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	      mail.setToAddresses(toAddresses);
	      mail.setReplyTo('cmcdowell@clearchoice.com');
	      mail.setSenderDisplayName('Apex error message');
	      mail.setSubject('CC Dash Error');
	      mail.setPlainTextBody(e.getMessage());
	      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	        
  		}
    }
    
    @future(callout=true)
    public static void create_past_due_reminders() {
    	Set<ID>  inactive_users = new Set<ID> ();
	  	for(User u : [select id from User where isactive=false]) {
	  		inactive_users.add(u.id);
	  	}
	  	Map<Id,Id> center_mco_map = new Map<Id,Id>();
	  	for(User u : [Select id,name,center_pec__c,Center_Administrator__c,isactive from user where center_administrator__c = true and isactive = true]) {
	  		center_mco_map.put(u.center_pec__c,u.id);  		
	  	}

	  	Util_TriggerContext.setalreadyProcessed();
	  	List<Task> new_tasks = new List<Task>();
	  	//adding anticipated PPF - 7/7/2015 CM
	  	for(CCPayment__c cc : [select pec__c,opportunity__c, opportunity__r.accountid, opportunity__r.ownerid, opportunity__r.account.center__c
	  	  from ccpayment__c where payment_date__c = yesterday and payment_status__c in ('Anticipated Promise Note','Anticipated','Anticipated PPF') ]) {
	  	 //check to make sure the owner is not on the inactive list
	  	  try {
		  	  Task t;
		  	  if(inactive_users.contains(cc.opportunity__r.ownerid)) { 
		  	 	  //grab the mco for this center
			  	 	  Id mco_id = center_mco_map.get(cc.opportunity__r.account.center__c);
			  	 	  t = new Task(ownerid = mco_id, description = 'Payment Follow Up', whatid = cc.opportunity__c, 
				  		type = 'Other', status = 'Not Started', Priority = 'High', Subject = 'Past Due Payment', isreminderset = true, reminderdatetime = system.now().addMinutes(5),
				  		activity_type__c = 'Other', outcome__c = 'Not Scheduled');
		  	  }
		  	  else 
		  	  //adjusting this to use the payment pec field - 7/7/2015 CM
			  		t = new Task(ownerid = cc.pec__c, description = 'Payment Follow Up', whatid = cc.opportunity__c, 
			  		type = 'Other', status = 'Not Started', Priority = 'High', Subject = 'Past Due Payment', isreminderset = true, reminderdatetime = system.now().addMinutes(5),
			  		activity_type__c = 'Other', outcome__c = 'Not Scheduled');
		  		new_tasks.add(t);
	  	  }
	  	  catch (Exception e) {
					Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
					String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
					mail.setToAddresses(toAddresses);
					mail.setReplyTo('cmcdowell@acme.com');
					mail.setSenderDisplayName('Apex Error Message');
					mail.setSubject('Task Creation - Past Due Payment error');
					mail.setPlainTextBody(e.getMessage());
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	 
	  	  }
	  	}
	  	try {
	  		insert new_tasks;
	  	}
	  	catch (Exception e) {
	  		System.debug(e);
	  		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
				mail.setToAddresses(toAddresses);
				mail.setReplyTo('cmcdowell@acme.com');
				mail.setSenderDisplayName('Apex Error Message');
				mail.setSubject('Task Creation - Past Due Payment error');
				mail.setPlainTextBody(e.getMessage());
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	  	}
	  }
    
    static testmethod void test_ccdashemail() {
    	test.startTest();
    	LeadershipEmail.sendCCDashEmail();
    	test.stoptest();
    }
    
    static testmethod void test_centeryearrev() {
    	test.startTest();
    	LeadershipEmail.sendCenterYearlyRevEmail();
    	test.stoptest();
    }
    
    static testmethod void test_centerrevdrivers() {
    	test.startTest();
    	LeadershipEmail.sendCenterRevEmail();
    	test.stoptest();
    }
    
    
}