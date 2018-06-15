global without sharing class newPracticeFeed {
	
  @future 
  public static void newCenterFeedPostLink(String center_id, String feed_body, String link_url, String link_name) {
  	try {
  	  Center_Information__c ci = [select id,name from Center_Information__c where id = :center_id];
  	  String group_name = ci.name + ' Practice Development';
  	  CollaborationGroup cg = [select id from CollaborationGroup where name = :group_name];
  	  FeedItem testFeed1 = new FeedItem(Body=feed_body, ParentId = cg.Id, Type='AdvancedTextPost', linkurl = 'https://na2.salesforce.com' + link_url, title = link_name);
	  insert testFeed1;
  	} catch (Exception e) {
  	  
  	}
  }
  
  @future
  public static void newCenterFeedPost(String center_id, String feed_body) {
  	try {
  	  Center_Information__c ci = [select id,name from Center_Information__c where id = :center_id];
  	  String group_name = ci.name + ' Practice Development';
  	  CollaborationGroup cg = [select id from CollaborationGroup where name = :group_name];
  	  FeedItem testFeed1 = new FeedItem(Body=feed_body, ParentId = cg.Id, Type='TextPost');
	  insert testFeed1;
  	} catch (Exception e) {
  	  
  	}
  }
  
  @future 
  public static void newPracticeFeedPostLink(String dp_id, String feed_body, String link_url, String link_name) {
  	try {
      Network n = [select id from network where name = 'Practice Development' limit 1];
  	  Dental_Practice__c ci = [select id,name from Dental_Practice__c where id = :dp_id];
  	  String group_name = ci.name + ' Referral Feed';
  	  CollaborationGroup cg = [select id from CollaborationGroup where name = :group_name];
  	  FeedItem testFeed1 = new FeedItem(Body=feed_body, ParentId = cg.Id, Type='AdvancedTextPost', linkurl = 'https://clearchoice.force.com' + link_url, title = link_name, networkscope = n.id);
  	  System.debug('Feed Item : ' + testFeed1);
	  insert testFeed1;
  	} catch (Exception e) {
  		
  	}
  }
  
  @future 
  public static void newPracticeFeedPost(String dp_id, String feed_body) {
  	try {
  	  Network n = [select id from network where name = 'Practice Development' limit 1];
  	  Dental_Practice__c ci = [select id,name from Dental_Practice__c where id = :dp_id];
  	  String group_name = ci.name + ' Referral Feed';
  	  CollaborationGroup cg = [select id from CollaborationGroup where name = :group_name];
  	  FeedItem testFeed1 = new FeedItem(Body=feed_body, ParentId = cg.Id, Type='TextPost', networkscope = n.id);
	  insert testFeed1;
  	} catch (Exception e) {
  		
  	}
  }
  
  @future 
  public static void create_new_practice_feed(ID uid, String pname, String cname) {
  	try {
  	  Network n = [select id from network where name = 'Practice Development' limit 1];
  	  //check to see if we already have a group for this practice
  	  String group_name = pname + ' Referral Feed';
  	  Integer cnt = [select count() from CollaborationGroup where Name = :group_name];
  	  CollaborationGroup cg;
  	  if(cnt>0) {
  	  	cg = [select id from CollaborationGroup where Name = :group_name];
  	  }
  	  else {
  	    cg = new CollaborationGroup(collaborationtype = 'Private', Description = 'A group to monitor referral events for referral practice ' + pname,
          networkid = n.id, canhaveguests = false, name = pname + ' Referral Feed');
        insert cg;
  	  }
      CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupID = cg.id, CollaborationRole = 'Admin', Memberid = uid, NotificationFrequency = 'D');
      insert cgm;
  	} catch (Exception e) {
  		System.debug('Exception ' + e);
  	}
  	
  	//try to add a feeditem to the center group  
  	try {
  	  String group_name = cname + ' Practice Development'; 
  	  CollaborationGroup cg = [select id from CollaborationGroup where name = :group_name];
	  FeedItem testFeed1 = new FeedItem(Body='New Practice has just been added to the portal - ' + pname, ParentId = cg.Id, Type='AdvancedTextPost', linkurl = 'https://na2.salesforce.com/' + uid, title = 'View User');
	  insert testFeed1;
  	} catch (Exception e) {
  		System.debug('Exception ' + e);
  	}
  	
  }
}