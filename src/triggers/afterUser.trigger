trigger afterUser on User (after insert, after update) {

  if(trigger.isInsert) {
    //check to see if we have an account - dental practice partner set
    for(User u : Trigger.new) {
      //check to see if the user,  is tied to a Partner Portal Account
      if(u.accountid!=null) {
        Account a1 = [select id,name,dental_practice_partner__c,dental_practice_partner__r.name, dental_practice_partner__r.center_information__r.name from Account where id = :u.accountid];
        System.debug('User Info - Account - Dental Partner ' + a1.dental_practice_partner__c);        
          if(a1.dental_practice_partner__c!=null) {
          	//set up a chatter group for this user
          	newPracticeFeed.create_new_practice_feed(u.id, a1.dental_practice_partner__r.name, a1.dental_practice_partner__r.center_information__r.name);        	
          	
            //set up sharing rules for this user,  on all related leads and accounts (starts comes from having account access)
            String dpid = a1.dental_practice_partner__c;
            List<LeadShare> lshares = new List<LeadShare>();
            for(lead l :[select id from Lead where referral_office__c = :dpid]) {
              LeadShare lshare = new LeadShare();
              lshare.LeadId = l.id;
              lshare.UserOrGroupID = u.id;
              lshare.LeadAccessLevel = 'Read';
              lshares.add(lshare);
            }
            List<AccountShare> ashares = new List<AccountShare>();
            for(Account a :[select id from Account where referral_office__c = :dpid]) {
              AccountShare ashare = new AccountShare();
              ashare.AccountId = a.id;
              ashare.UserOrGroupId = u.id;
              ashare.OpportunityAccessLevel = 'Read';
              ashare.AccountAccessLevel = 'Read';
              ashares.add(ashare);
            }       
            
            //work through referrals out
            for(Referral_Out__c ro : [select id,lead__c,lead__r.convertedaccountid,account__c from referral_out__c where dental_practice__c = :dpid]) {
              if(ro.lead__c!=null) {
              	LeadShare lshare = new LeadShare();
                lshare.LeadId = ro.lead__c;
                lshare.UserOrGroupID = u.id;
                lshare.LeadAccessLevel = 'Read';
                lshares.add(lshare);
              	if(ro.lead__r.convertedaccountid!=null) {
              	  AccountShare ashare = new AccountShare();
                  ashare.AccountId = ro.lead__r.convertedaccountid;
                  ashare.UserOrGroupId = u.id;
                  ashare.OpportunityAccessLevel = 'Read';
                  ashare.AccountAccessLevel = 'Read';
                  ashares.add(ashare);
              	}
              }
              if(ro.account__c!=null) {
              	AccountShare ashare = new AccountShare();
                ashare.AccountId = ro.account__c;
                ashare.UserOrGroupId = u.id;
                ashare.OpportunityAccessLevel = 'Read';
                ashare.AccountAccessLevel = 'Read';
                ashares.add(ashare);
              }
            }
            
            if(lshares.size()>0) {
              try {
                insert lshares;
              } catch (Exception e) {
                System.debug('Error adding lead shares : ' + e);
              }
            }
            if(ashares.size()>0) {
              try {
                insert ashares;
              } catch(Exception e) {
                System.debug('Error adding account shares : ' + e);
              }
            }
          }
      }       
    }
  }
  
  /*commented out - this is really covered by the account trigger when a dental practice partner field gets updated.  Can't imagine a scenario where a lead is updated and suddenly has an accountid.
    It's their from the start,  or not at all (ie - not a protal partner);*/
  /*if(trigger.isUpdate) {
    //see if dental practice value was changed from null to something else (I'm not going to handle a switch in office values right now.  That could get messy,  as I would have to delete the old shares)
    for (Integer i = 0; i < Trigger.new.size(); i++) {
      if(Trigger.new[i].accountid!=null && Trigger.old[i].accountid==null) {
        //see if the accountid has a dental practice partner 
        
        
        //create the sharing rules for lead and accounts tied to this office
        String dpid = Trigger.new[i].contact.account.dental_practice_partner__c;
        List<LeadShare> lshares = new List<LeadShare>();
        for(lead l :[select id from Lead where referral_office__c = :dpid]) {
          LeadShare lshare = new LeadShare();
          lshare.LeadId = l.id;
          lshare.UserOrGroupID = Trigger.new[i].id;
          lshare.LeadAccessLevel = 'Read';
          lshares.add(lshare);
        }
        List<AccountShare> ashares = new List<AccountShare>();
        for(Account a :[select id from Account where referral_office__c = :dpid]) {
          AccountShare ashare = new AccountShare();
          ashare.AccountId = a.id;
          ashare.UserOrGroupId = Trigger.new[i].id;
          ashare.OpportunityAccessLevel = 'Read';
          ashare.AccountAccessLevel = 'Read';
          ashares.add(ashare);
        }       
        
        if(lshares.size()>0) {
          try {
            insert lshares;
          } catch (Exception e) {
            System.debug('Error adding lead shares : ' + e);
          }
        }
        if(ashares.size()>0) {
          try {
            insert ashares;
          } catch(Exception e) {
            System.debug('Error adding account shares : ' + e);
          }
        }
      }
    }
  }*/
}