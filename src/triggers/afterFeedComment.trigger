trigger afterFeedComment on FeedComment (after insert) {
  if(trigger.isInsert) {
  	String lead_prefix = Lead.sObjectType.getDescribe().getKeyPrefix();
  	String account_prefix = Account.sObjectType.getDescribe().getKeyPrefix();
  	String opp_prefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
  	
  	for(FeedComment fc : trigger.new) {
  	  String parentid = fc.parentId; 
  	  Boolean referral_feed = false;
  	  String office_name;
  	  String office_id;
  	  String center_id;
  	  if(parentId.startsWith(lead_prefix)) {  	  	
  	  	Lead l = [select id,center__c,referral_office__c,referral_office__r.name from lead where id = :fc.parentId];
  	  	if(l.referral_office__c!=null) {
  	  	  office_name = l.referral_office__r.name;
  	  	  office_id = l.referral_office__c;
  	  	  center_id = l.center__c;
  	  	  referral_feed = true;
  	  	}
  	  } else if(parentId.startsWith(account_prefix)) {
  	  	Account a = [select id,center__c,referral_office__c,referral_office__r.name from Account where id = :fc.parentId];
  	  	if(a.referral_office__c!=null) {
  	  	  office_name = a.referral_office__r.name;
  	  	  office_id = a.referral_office__c;
  	  	  center_id = a.center__c;
  	  	  referral_feed = true;
  	  	}
  	  } else if(parentId.startsWith(opp_prefix)) {
  	  	Opportunity o = [select id,name,accountid,account.center__c,account.referral_office__c,account.referral_office__r.name from Opportunity where id = :fc.parentId];
  	  	if(o.account.referral_office__c!=null) {
  	  	  office_name = o.account.referral_office__r.name;
  	  	  office_id = o.account.referral_office__c;
  	  	  center_id = o.account.center__c;
  	  	  referral_feed = true;
  	  	}
  	  }
  	  //comments was on a referral lead - post it to the feed
  	  if(referral_feed) { 
        String center_post = 'A comment was just posted to a referral from ' + office_name + '.\n\n ' + fc.CommentBody;          
        newPracticeFeed.newCenterFeedPostLink(center_id, center_post, '/' + fc.parentId, 'New Chatter Comment');
        String practice_post = 'A comment was just posted to a referral you sent to ClearChoice.\n\n ' + fc.CommentBody;
        newPracticeFeed.newPracticeFeedPostLink(office_id,practice_post,'/referral/' + fc.parentId, 'New Chatter Comment');
  	  }
  	}
  }
}