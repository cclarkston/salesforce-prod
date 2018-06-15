/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class ppriv_emailhandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //will hold aa list of dental practices that we matched up to based on to/cc address in the email
        Set<ID> practice_matches = new Set<ID>();
        String[] all_address = new String[] {};
        String html_body = 'Email ' + email + '<br /><br />' + envelope + '<br /<br /><hr /><br />From Address : ' + email.fromAddress + '<br />'; 
        
        if(email.fromAddress!=null)
          all_address.add(email.fromaddress);
        html_body += 'Address List after From process : ' + all_address + '<br /><br />To Address : ' + email.toaddresses + '<br />';
        
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
            else 
              all_address.add(toAddress); 
          } 
        }
        html_body += 'Address List after To Address : ' + all_address + '<br /><br />CC Address : ' + email.ccaddresses + '<br />'; 
        
        if(email.ccaddresses!=null) {
          /*if(email.ccaddresses.size()>0) {
	        for(String s : email.ccaddresses) {
	          all_address.add(s);
	        }
          }*/
          //Clean the "ccAddresses" list 
          for (string ccAddress : email.ccAddresses) { 
			Matcher matcher = pattern.compile('<.+>').matcher(ccAddress); 
		    //Parse it to emails and add it to our clean list 
            if (matcher.find()) { 
             string cleanCcEmail = matcher.group().replaceAll('[<>]', ''); 
             all_address.add(cleanCcEmail); 
            } 
            else { 
              all_address.add(ccAddress); 
            } 
          } 
        }
        html_body += 'Address List after CC Address : ' + all_address + '<br /><br />';
        
        //check for Practice matches first
        for(Dental_Practice__c dp : [select id from Dental_practice__c where primary_contact_email__c in :all_address]) {
          practice_matches.add(dp.id);
        }
        html_body += 'Practice Matches : ' + practice_matches.size() + '<br />';
        
        //check for doctor match
        for(Practice_Doctor__c pd : [select dental_practice__c from Practice_Doctor__c where email__c in : all_address]) {
          practice_matches.add(pd.dental_practice__c);
        }
        html_body += 'Matches with Doctors : ' + practice_matches.size() + '<br />';
        
        //see if we found any matches
        if(practice_matches.size()>0) {
          List<Note> new_notes = new List<Note> ();
          List<Attachment> new_attachments = new List<Attachment> ();
          //build all new notes
          for(ID dp_id : practice_matches) {
          	Note note = new Note(); 
			note.Title = email.fromName + ' (' + DateTime.now() + ') Re : ' + email.subject==null?'No Subject':email.subject; 
			note.Body = email.plainTextBody; 
			note.ParentId = dp_id; 
			new_notes.add(note); 
          }
          
          //build all new attachments
          for(ID dp_id : practice_matches) {
          	if(email.textAttachments!=null)
          	  for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) { 
			    Attachment attachment = new Attachment(); 
			    attachment.Name = tAttachment.fileName; 
			    attachment.Body = Blob.valueOf(tAttachment.body); 
			    attachment.ParentId = dp_Id; 
			    new_attachments.add(attachment); 
			  }
			if(email.binaryAttachments!=null)   
			  for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) { 
			    Attachment attachment = new Attachment(); 
			    attachment.Name = bAttachment.fileName; 
			    attachment.Body = bAttachment.body; 
			    attachment.ParentId = dp_Id; 
			    new_attachments.add(attachment); 
			  } 
          }
          
          html_body += 'New Notes to enter : ' + new_notes.size() + '<br /><br />';
          /*Messaging.SingleEmailMessage debug_message = new Messaging.SingleEmailMessage();
          debug_message.setReplyTo('cmcdowell@clearchoice.com');
          debug_message.setSubject('Debug - PPRiv Email Handler');
          debug_message.setHtmlBody(html_body);
    	  debug_message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { debug_message });*/
          //make any necessary inserts 
          try {
          	if(new_notes.size()>0)
          	  insert new_notes;
          }
          catch (Exception e) {
          	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an Error inserting notes from email service');
 		    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
          }
          
          try {
          	if(new_attachments.size()>0)
          	  insert new_attachments;
          }
          catch (Exception e) {
          	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an Error inserting attachments from email service');
 		    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
          }
        }
        
        return result;
    }
}