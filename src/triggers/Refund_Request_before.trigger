trigger Refund_Request_before on Refund_Request__c (before update) {
	
	if(trigger.isbefore) {
      for(Refund_Request__c rr: Trigger.new) {
      	Refund_Request__c rr_old = System.Trigger.oldMap.get(rr.Id);
      	//check to see if the status was changed to closed 
        if(rr.refund_status__c=='Closed' && rr_old.refund_status__c != 'Closed') {
          rr.Refund_Completed_Date__c = System.now();
          //send an email to the relevant parties - still waiting on this info from Michelle
          Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
          //grab the person who made the request
          User u = [select email from User where id = :rr.createdbyid];                            
  	      String[] toAddresses = new String[] {u.email,'cmcdowell@clearchoice.com'};
  	      try {
  	      	//grab the rsm-rbd
            Opportunity o = [Select exam_Center__c,exam_center__r.sales_region__c, account.center__r.sales_region__c, account.center__c From Opportunity o where id = :rr.opportunity__c];
            Sales_Region__c sr;           
            String center_id;
            if(o.exam_center__c!=null) {
              sr = [Select name, s.RSM__c, s.RBD__c, rbd__r.email, rsm__r.email From Sales_Region__c s where name = :o.exam_center__r.sales_region__c];
              center_id = o.exam_center__c;
            }
            else {
              sr = [Select name, s.RSM__c, s.RBD__c, rbd__r.email, rsm__r.email From Sales_Region__c s where name = :o.account.center__r.sales_region__c];
              center_id = o.account.center__c;
            }
            if(sr.rbd__r.email!=null)
              toAddresses.add(sr.rbd__r.email);
            if(sr.rsm__r.email!=null)
              toAddresses.add(sr.rsm__r.email);
            try {
            	
            }  catch (Exception e) {
              User foa = [select id, email from User where center_pec__c = :center_id and center_administrator__c = true and isactive = true];
              if(foa!=null)
                toAddresses.add(foa.email);
            } 
  	      } catch (Exception e) {
  	      	
  	      } 	  
  	      mail.setToAddresses(toAddresses);
          mail.setReplyTo('refund-team@clearchoice.com');	  	  
  	      mail.setSubject('Refund Request - Completed');
  	      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'refund-team@clearchoice.com'];
          if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
		  }
  	      String html_body = '<html><body><p style="padding-left:20px;">Hello,<br /><br />Your refund is complete and has been posted in SalesForce and Windent.' +
  	        'If your refund has a receipt, it is attached to the "Notes & Attachments" section in SalesForce. Please provide this receipt to your patient.' +
  	        'Please note: Refunds are reimbursed to the same method of payment from which they were collected.<br /><br />' +
			'Please ensure your patient is aware of the refund turnaround times:<br /><br />' + 
            'CareCredit: 5-7 days to post to account<br />Lending Club: 7-10 days to post to account<br />Credit Card: 5-7 days to post to account<br />' + 
            'Check: 7-10 days to be mailed to the address you provided<br /><br />No longer need to scan refund receipts into Windent. Let me know if you have any questions, thank you!<br /><br />' + 
  	        'Click <a href="https://' + URL.getCurrentRequestUrl().getHost() + '/' + rr.id + '" target="__blank" style="color:blue;font-weight:bold;">here</a> to view the refund request.<br /><br/>' + 
  	        'Click <a href="https://' + URL.getCurrentRequestUrl().getHost() + '/' + rr.opportunity__c + '" target="__blank" style="color:blue;font-weight:bold;">here</a> to view the prosth exam record.<br /><br/>' +
  	        + '</p></body></html>';
  	      mail.setHTMLBody(html_body);
  	      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        if(rr.Patient_called_about_PE_fee__c==true && rr_old.patient_called_about_pe_fee__c!=true)
          rr.PE_call_date__c = System.today();        
      }
	}
}