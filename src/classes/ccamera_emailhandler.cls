/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class ccamera_emailhandler implements Messaging.InboundEmailHandler {

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    boolean match_error = false; 
    
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    /*message.setReplyTo('cmcdowell@clearchoice.com');
    message.setSubject('An Email was received from the Camera process');
    message.setPlainTextBody(' From : ' + email.fromName + ' Subject : ' + email.subject==null?'No Subject':email.subject + ' Body : ' + email.plainTextBody);
  	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });*/
    
    String email_body = email.plainTextBody;
    email_body = email_body.replace('\n','');
    
    Map<String, Object> consult_components = (Map<String, Object>) JSON.deserializeUntyped(email_body);
    String consult_email = String.valueof(consult_components.get('patient_email_address'));
    String video_id = String.valueof(consult_components.get('video_id'));
    String part_number = String.valueof(consult_components.get('part_number'));
    String confirmation_token = String.valueof(consult_components.get('confirmation_token'));
    
   /* message = new Messaging.SingleEmailMessage();
    message.setReplyTo('cmcdowell@clearchoice.com');
    message.setSubject('An Email was processed from the Camera process');
    message.setHtmlbody('Body : ' + email.plainTextBody + '<br /><br />Consult Email : ' + consult_email + '<br />Video Id : ' + video_id + '<br />Part Number : ' + part_number + '<br />Confirmation Token : ' + confirmation_token);
  	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });    */
    
    //try to find an account match
    Integer consult_inventory_matches = [select count() from consult_inventory__c where ((scheduled_lead__r.email = :consult_email or scheduled_lead__r.email_2__c = :consult_email) or scheduled_account__r.personemail = :consult_email) and apt_date__c = today];
    Integer account_matches = [select count() from Account where personemail = :consult_email or email__c = :consult_email];
    Integer lead_matches = [select count() from Lead where isconverted = false and (email = :consult_email or email_2__c = :consult_email)];
    
    /*message = new Messaging.SingleEmailMessage();
    message.setReplyTo('cmcdowell@clearchoice.com');
    message.setSubject('An Email was processed from the Camera process');
    message.setHtmlbody('Account Matches : ' + account_matches + '<br /><br />Lead Matches : ' + lead_matches);
  	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });*/
    
    if(consult_inventory_matches>1) {
      //amazed if this ever happens
      //send an email to me so I can figure out which one is appropriate
      String consult_id_list = '';
      for(Consult_Inventory__c ci : [select id from consult_inventory__c where ((scheduled_lead__r.email = :consult_email or scheduled_lead__r.email_2__c = :consult_email) or scheduled_account__r.personemail = :consult_email) and apt_date__c = today]) {
      	consult_id_list += ci.id + '<br />';
      }      
      message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('Multiple Matches for Camera Consult');
      message.setHtmlbody('Multiple Matches were found for the following consult video<br /><br />Consult Email : ' + consult_email + '<br />Video Id : ' + video_id + '<br />Part Number : ' + part_number + '<br />Confirmation Token : ' + confirmation_token + '<br /><br />Possible Consult Inventory Matches : ' + consult_id_list + '<br /><br />Link to video : <a href="https://secure.themedicalmemory.com/#/videos/' + video_id + '">Click Here</a>');
  	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','msmith@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      match_error = true; 
    }
    else if(consult_inventory_matches==1) {
      Consult_Inventory__c ci = [select id,apt_date__c,scheduled_lead__c,scheduled_account__c,scheduled_lead__r.isconverted,scheduled_lead__r.convertedaccountid from consult_inventory__c where ((scheduled_lead__r.email = :consult_email or scheduled_lead__r.email_2__c = :consult_email) or scheduled_account__r.personemail = :consult_email) and apt_date__c = today];
      Consult_Camera_Video__c ccv = new Consult_Camera_Video__c(confirmation_token__c = confirmation_token, Video_Id__c = video_id, Part_Number__c = integer.valueof(part_number), consult_url_link__c = 'https://secure.themedicalmemory.com/#/confirm?email=' + consult_email + ' &confirmation_token=' + confirmation_token +  '&video_id=' + video_id, PEC_Access_URL__c = 'https://secure.themedicalmemory.com/#/videos/' + video_id);
      if(ci.scheduled_account__c!=null) 
      	ccv.account__c = ci.scheduled_account__c;
      if(ci.scheduled_lead__c!=null) {
      	if(ci.scheduled_lead__r.convertedaccountid!=null)
      	  ccv.account__c = ci.scheduled_lead__r.convertedaccountid;
      	else
      	  ccv.lead__c = ci.scheduled_lead__c;
      }
      try {
      	insert ccv;
      }
      catch (Exception e) {
      	
      } 
    }
    else if(account_matches>1) {
      //send an email to me so I can figure out which one is appropriate
      String account_id_list = '';
      for(Account a : [select id from Account where personemail = :consult_email or email__c = :consult_email]) {
      	account_id_list += a.id + '<br />';
      }      
      message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('Multiple Matches for Camera Consult');
      message.setHtmlbody('Multiple Matches were found for the following consult video<br /><br />Consult Email : ' + consult_email + '<br />Video Id : ' + video_id + '<br />Part Number : ' + part_number + '<br />Confirmation Token : ' + confirmation_token + '<br /><br />Possible Account Matches : ' + account_id_list + '<br /><br />Link to video : <a href="https://secure.themedicalmemory.com/#/videos/' + video_id + '">Click Here</a>');
  	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','msmith@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });  
      match_error = true;
    }    
    else if(account_matches==1) {
      //add the consult camera video record
      Account a = [select id from Account where personemail = :consult_email or email__c = :consult_email];
      Consult_Camera_Video__c ccv = new Consult_Camera_Video__c(account__c = a.id,confirmation_token__c = confirmation_token, Video_Id__c = video_id, Part_Number__c = integer.valueof(part_number), consult_url_link__c = 'https://secure.themedicalmemory.com/#/confirm?email=' + consult_email + ' &confirmation_token=' + confirmation_token +  '&video_id=' + video_id, PEC_Access_URL__c = 'https://secure.themedicalmemory.com/#/videos/' + video_id);
      try {
      	insert ccv;
      }
      catch (Exception e) {
      	
      }
    }
    else if(lead_matches>1) {
      //send an email to me so I can figure out which one is appropriate
      String lead_id_list = '';
      for(Lead l : [select id from Lead where isconverted = false and (email = :consult_email or email_2__c = :consult_email)]) {
      	lead_id_list += l.id + '<br />';
      }      
      message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('Multiple Matches for Camera Consult');
      message.setHtmlbody('Multiple Matches were found for the following consult video<br /><br />Consult Email : ' + consult_email + '<br />Video Id : ' + video_id + '<br />Part Number : ' + part_number + '<br />Confirmation Token : ' + confirmation_token + '<br /><br />Possible Lead Matches : ' + lead_id_list + '<br /><br />Link to video : <a href="https://secure.themedicalmemory.com/#/videos/' + video_id + '">Click Here</a>');
  	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','msmith@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
      match_error = true;
    }
    else if (lead_matches==1) {
      //add the consult camera video record
      Lead l = [select id from Lead where isconverted = false and (email = :consult_email or email_2__c = :consult_email)];
      Consult_Camera_Video__c ccv = new Consult_Camera_Video__c(lead__c = l.id,confirmation_token__c = confirmation_token, Video_Id__c = video_id, Part_Number__c = integer.valueof(part_number), consult_url_link__c = 'https://secure.themedicalmemory.com/#/confirm?email=' + consult_email + '&confirmation_token=' + confirmation_token +  '&video_id=' + video_id, PEC_Access_URL__c = 'https://secure.themedicalmemory.com/#/videos/' + video_id);
      try {
      	insert ccv;
      }
      catch (Exception e) {
      	
      }
    }
    else {
      //no match found - send an email to me for troubleshooting
      message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('No Match for Camera Consult');
      message.setHtmlbody('No Match was found for the following consult video<br /><br />Consult Email : ' + consult_email + '<br />Video Id : ' + video_id + '<br />Part Number : ' + part_number + '<br />Confirmation Token : ' + confirmation_token + '<br /><br />Link to video : <a href="https://secure.themedicalmemory.com/#/videos/' + video_id + '">Click Here</a>');
  	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','msmith@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      match_error = true;
    }
    
    if(match_error==true) {
      try {
      	Lead l = [select id from Lead where name = 'No Match Camera Consult' limit 1];
      	Consult_Camera_Video__c ccv = new Consult_Camera_Video__c(lead__c = l.id,confirmation_token__c = confirmation_token, Video_Id__c = video_id, Part_Number__c = integer.valueof(part_number), consult_url_link__c = 'https://secure.themedicalmemory.com/#/confirm?email=' + consult_email + '&confirmation_token=' + confirmation_token +  '&video_id=' + video_id, PEC_Access_URL__c = 'https://secure.themedicalmemory.com/#/videos/' + video_id);
      	insert ccv;
      }
      catch (Exception e) {
      	
      }
    }
    
    return result;
  }
  
}