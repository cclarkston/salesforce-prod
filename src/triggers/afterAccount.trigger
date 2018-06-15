trigger afterAccount on Account (after insert, after update, before update) {
  if(trigger.isInsert) {
    for(Account a : Trigger.new) {
      if(a.referral_office__c!=null) {
        try {
          User u = [select id from User where contact.account.dental_practice_partner__c = :a.referral_office__c];
          AccountShare ashare = new AccountShare();
          ashare.AccountId = a.id;
          ashare.UserOrGroupId = u.id;
          ashare.OpportunityAccessLevel = 'Read';
          ashare.AccountAccessLevel = 'Read';
          insert ashare;          
        } catch (Exception e) {
          
        }       
      }
    }
  }
  
  if(trigger.isBefore && trigger.isUpdate) {  	  	
  	//run through all account records,  and grab all of the zip codes we need to look up  	
  	Set<String> all_zips = new Set<String>();
  	for(Account newAccount : trigger.new) {
  	  Account oldAccount = Trigger.oldMap.get(newAccount.id);
  	  if(newAccount.BillingPostalCode !=null && newAccount.BillingPostalCode  != oldAccount.BillingPostalCode ) {
  	  	all_zips.add(newAccount.BillingPostalCode.substring(0,5));
  	  }
  	}
  	 
  	//build a map of the zip codes
  	Map<String,Zip_Demographic__c> zip_map = new Map<String,Zip_Demographic__c> ();
  	for(Zip_Demographic__c zd : [select id,zipcode__c from Zip_Demographic__c where zipcode__c in :all_zips]) {
  	  zip_map.put(zd.zipcode__c,zd);
  	}
  	
  	//run through the accounts again, and update the records with zip demographic info,  if necessary
    for(Account newAccount : trigger.new) {
  	  Account oldAccount = Trigger.oldMap.get(newAccount.id);
  	  if(newAccount.BillingPostalCode !=null && newAccount.BillingPostalCode  != oldAccount.BillingPostalCode ) {
  	  	if(zip_map.get(newAccount.BillingPostalCode.substring(0,5))!=null)
  	  	  newAccount.Zip_Demographic__c = zip_map.get(newAccount.BillingPostalCode.substring(0,5)).id; 
  	  }
  	}
  }
  
  if(trigger.isUpdate) {
    for(Account a: trigger.new) {
      Account oldAccount = Trigger.oldMap.get(a.id);    
      Account newAccount = Trigger.newMap.get(a.id);
      if(newAccount.referral_office__c!=null && newAccount.referral_office__c!=oldAccount.referral_office__c) {     
        try {
          User u = [select id from User where contact.account.dental_practice_partner__c = :newAccount.referral_office__c];
          AccountShare ashare = new AccountShare();
          ashare.AccountId = a.id;
          ashare.UserOrGroupId = u.id;
          ashare.OpportunityAccessLevel = 'Read';
          ashare.AccountAccessLevel = 'Read';
          insert ashare;
        } catch (Exception e) {
          
        }
      }
      //see if an account was tied to a dental office.  if it has a user account - build sharing rules
      if(newAccount.dental_practice_partner__c!=null && oldAccount.dental_practice_partner__c==null) {
        List<LeadShare> lshares = new List<LeadShare>();
        List<AccountShare> ashares = new List<AccountShare>();
        for(User u : [select id from user where accountid = :a.id]) {
          //set up a chatter group for this user
          Dental_Practice__c dp = [select name,center_information__r.name from Dental_Practice__c where id = :newAccount.dental_practice_partner__c];
          newPracticeFeed.create_new_practice_feed(u.id, dp.name, dp.center_information__r.name);
          //newPracticeFeed np = new newPracticeFeed(u.id, dp.name, dp.center_information__r.name);
          //we have a user account - grab leads and account records tied to this referral office
          String dpid = newAccount.dental_practice_partner__c;
          for(lead l :[select id from Lead where referral_office__c = :dpid]) {
            LeadShare lshare = new LeadShare();
            lshare.LeadId = l.id;
            lshare.UserOrGroupID = u.id;
            lshare.LeadAccessLevel = 'Read';
            lshares.add(lshare);
          }
          for(Account amatch :[select id from Account where referral_office__c = :dpid]) {
            AccountShare ashare = new AccountShare();
            ashare.AccountId = amatch.id;
            ashare.UserOrGroupId = u.id;
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
    }
  }
}