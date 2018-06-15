/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class cc_emailhandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //will hold a list of leads/accounts that we matched up to based on to/cc address in the email
        Set<ID> lead_matches = new Set<ID>();
        String[] all_address = new String[] {};
        
        
        if(email.fromAddress!=null)
          all_address.add(email.fromaddress);
        
        if(email.toaddresses!=null) {
          /*for(String s : email.toaddresses) {
            all_address.add(s);
          }*/
          for (string toAddress : email.toAddresses) { 
			Matcher matcher = pattern.compile('<.+>').matcher(toAddress); 
		    //Parse it to emails and add it to our clean list 
            if (matcher.find()) { 
             string cleantoEmail = matcher.group().replaceAll('[<>]', ''); 
             all_address.add(cleantoEmail); 
            } 
            else { 
              all_address.addAll(email.toAddresses); 
            } 
          } 
        }
        if(email.ccaddresses!=null)
        if(email.ccaddresses.size()>0) {        
          //Clean the "ccAddresses" list 
          for (string ccAddress : email.ccAddresses) { 
			Matcher matcher = pattern.compile('<.+>').matcher(ccAddress); 
		    //Parse it to emails and add it to our clean list 
            if (matcher.find()) { 
             string cleanCcEmail = matcher.group().replaceAll('[<>]', ''); 
             all_address.add(cleanCcEmail); 
            } 
            else { 
              all_address.addAll(email.ccAddresses); 
            } 
          } 
        }
        
          
	     /*   for(String s : email.ccaddresses) {
	          all_address.add(s);
	        }
          }*/ 
          
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was NOT an Error inserting notes from email service - cc_emailhandler');
 		    message.setPlainTextBody('All Address : ' + all_address);
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        
        //check for lead matches first
        for(Lead l : [select id from Lead where (email in :all_address or email_2__c in :all_address) and isconverted = false]) {
          lead_matches.add(l.id);
        }
        
        for(Account a: [select id from Account where personemail in :all_address or email__c in :all_address]) {
          lead_matches.add(a.id);
        }
        
         /*message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was NOT an Error inserting notes from email service - cc_emailhandler');
 		    message.setPlainTextBody('Lead Matches : ' + lead_matches.size() + '  ' + lead_matches);
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });*/ 
               
        //see if we found any matches
        if(lead_matches.size()>0) {
          /*task Version*/
          /*List<Task> new_notes = new List<Task> ();
          //build all new notes
          for(ID dp_id : lead_matches) {
          	Task note = new Task();
          	Task t = new Task(WhoId = dp_id, OwnerId = Userinfo.getUserId(), Type = 'Email', Activity_Type__c = 'Email Copy', Call_No_Answer__c = false, Status = 'Completed'); 
			t.Subject = email.fromName + ' (' + DateTime.now() + ') Re : ' + email.subject==null?'No Subject':email.subject;
			t.description = email.plainTextBody;
			//Body = email.plainTextBody; 
			//note.ParentId = dp_id; 
			new_notes.add(note); 
          }*/
          
          List<Note> new_notes = new List<Note> ();
          List<Attachment> new_attachments = new List<Attachment> ();
          //build all new notes
          for(ID dp_id : lead_matches) {
          	Note note = new Note(); 
			note.Title = email.fromName + ' (' + DateTime.now() + ') Re : ' + email.subject==null?'No Subject':email.subject; 
			note.Body = email.plainTextBody; 
			note.ParentId = dp_id; 
			new_notes.add(note); 
          }
          
          //make any necessary inserts 
          try {
          	/*message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was NOT an Error inserting notes from email service - cc_emailhandler');
 		    message.setPlainTextBody('Notes : ' + new_notes);
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });*/ 
          	if(new_notes.size()>0) 
          	  insert new_notes;
          	/*message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('Done');
 		    message.setPlainTextBody('New NOtes Done');
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); */
          }
          catch (Exception e) {
          	Messaging.SingleEmailMessage error_message = new Messaging.SingleEmailMessage();
            error_message.setReplyTo('cmcdowell@clearchoice.com');
            error_message.setSubject('There was an Error inserting notes from email service - cc_emailhandler');
 		    error_message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	    error_message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { error_message }); 
          }
          
        }
        return result;
    }
}