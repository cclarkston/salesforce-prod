trigger afterReferralOut on Referral_Out__c (after insert) {
  List<LeadShare> lshares = new List<LeadShare>();
  List<AccountShare> ashares = new List<AccountShare>();

  //need a list of GP portal users and the office they are tied to
  Map<ID,ID> account_to_user = new Map<ID,ID> {};
  Map<ID,Dental_Practice__c> office_records = new Map<ID,Dental_Practice__c> {};
  Map<ID,ID> office_to_user = new Map<ID,ID> {};
  Set<ID> account_id_list = new Set<ID>();
  Set<ID> office_id_list = new Set<ID>();
  for(User u : [select id,name,accountid from user where accountid != null and isactive = true]) {
  	account_id_list.add(u.accountid);
  	account_to_user.put(u.accountid,u.id);
  } 
  //grab all of the accounts,  along with their referral offices,  so we can match the office to a user
  for(Account a : [select id,name,dental_practice_partner__c,dental_practice_partner__r.center_information__c from Account where id in :account_id_list]) {
  	office_to_user.put(a.dental_practice_partner__c,account_to_user.get(a.id));
  	if(a.dental_practice_partner__c!=null)
  	  office_id_list.add(a.dental_practice_partner__c);
  }
  //grab practice record for use later
  for(Dental_Practice__c dp : [select id,center_information__c,name from Dental_practice__c where id in :office_id_list]) {
  	office_records.put(dp.id,dp);
  }    

  if(trigger.isInsert) {
	for(Referral_Out__c ro : trigger.new) {
	  //check to see if the dental practice has a user account tied to it
	  if(office_to_user.get(ro.dental_practice__c)!=null) {
	  	//add a feed note
	  	String center_note = 'A new referral was just sent to ' + (String)office_records.get(ro.dental_practice__c).name + '.';
	  	String practice_note = 'ClearChoice just sent a new referral to you.';
	  	String link_id;
	  	if(ro.lead__c!=null) {	  		
	  	  link_id = ro.lead__c;
	  	  //set up a lead share for this referral	
	  	  LeadShare lshare = new LeadShare();
          lshare.LeadId = ro.lead__c;
          lshare.UserOrGroupID = office_to_user.get(ro.dental_practice__c);
          lshare.LeadAccessLevel = 'Read';
          lshares.add(lshare);
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('Debugging - AfterReferralOut Trigger');
 		    message.setPlainTextBody('Lead ID : ' + ro.lead__c + ' Lead Share : ' + lshare);
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	  	}
	  	else if(ro.account__c!=null) {
	  	  link_id = ro.account__c;
	  	  //set up an account share for this referral	
	  	  AccountShare ashare = new AccountShare();
          ashare.AccountId = ro.account__c;
          ashare.UserOrGroupId = office_to_user.get(ro.dental_practice__c);
          ashare.OpportunityAccessLevel = 'Read';
          ashare.AccountAccessLevel = 'Read';
          ashares.add(ashare);
	  	}
	  	
	  	newPracticeFeed.newCenterFeedPostLink(office_records.get(ro.dental_practice__c).center_information__c, center_note, '/' + link_id, 'View Patient');
	  	newPracticeFeed.newPracticeFeedPostLink(ro.dental_practice__c, practice_note, '/referral/' + link_id, 'View Patient');  	 	  	
	  }
	}
	
	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('Debugging - AfterReferralOut Trigger - Share Sizes');
 		    message.setPlainTextBody('Lshares.Size  : ' + lshares.size() + ' Ashares.size() : ' + ashares.size());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	if(lshares.size()>0) {
      try {
      	message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('Debugging - AfterReferralOut Trigger - Inserting Lshares');
 		    message.setPlainTextBody('Lead Shares : ' + lshares);
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        insert lshares;
      } catch (Exception e) {
        System.debug('Error adding lead shares : ' + e);
         message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an error creating lead share for a referral out');
 		    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      }
    }
    if(ashares.size()>0) {
      try {
        insert ashares;
      } catch(Exception e) {
        System.debug('Error adding account shares : ' + e);
         message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an error creating account share for a referral out');
 		    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      }
    }
  }
}