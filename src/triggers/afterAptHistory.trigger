trigger afterAptHistory on Apt_History__c (after insert) {
  if(Trigger.isInsert) {
  	for(Apt_History__c ah : trigger.new) {
      //see if this is an event that migght trigger a feed
      if(ah.action__c=='Arrived' || ah.action__c=='Cancel' || ah.action__c=='Completed' || ah.action__c=='Left' || ah.action__c=='No Show' || ah.action__c=='Scheduled') {
  	    Boolean referral_lead = false;
  	    String office_name;
  	    String center_id;
  	    String office_id;
  	    String link_id;
  	    String center_body;
  	    String practice_body;
  	    if(ah.lead__c!=null) {
  	      Lead l = [select id,referral_office__c,referral_office__r.name,center__c from lead where id = :ah.lead__c];
  	      if(l.referral_office__c!=null) {
  	      	referral_lead = true;
  	      	office_name = l.referral_office__r.name;
  	      	center_id = l.center__c;
  	      	office_id = l.referral_office__c;
  	      	link_id = l.id;
  	      }
    	}
  	    else if(ah.account__c!=null) {
  	  	  Account a = [select id,referral_office__c,referral_office__r.name,center__c from Account where id = :ah.account__c];
  	  	  if(a.referral_office__c!=null) {
  	  	  	referral_lead = true;
  	      	office_name = a.referral_office__r.name;
  	      	center_id = a.center__c;
  	      	office_id = a.referral_office__c;
  	      	link_id = a.id;
  	  	  }
  	    }
  	    //if this was a referral lead - post relevant post to the feeds
  	    if(Referral_lead) {
	  	    if(ah.action__c=='Arrived')  {
	  	      center_body = 'A referral from ' + office_name + ' has arrived at their apt';
	  	      practice_body = 'A referral you sent to us,  has just arrived for their apt';
	  	    }
	  	    else if(ah.action__c=='Scheduled') {
	  	      Consult_Inventory__c ci = [select id,apt_date__c,start_hour__c,start_minute__c from Consult_Inventory__c where id = :ah.consult_inventory__c];
	  	      Datetime apt_datetime = datetime.newinstance(ci.apt_date__c.year(),ci.apt_date__c.month(),ci.apt_date__c.day(),0,0,0);
	  	      if(ah.notes__c.contains('rescheduled')) {		  	      	 
	  	      	center_body = 'A referral from ' + office_name + ' has been rescheduled for a consultation on ' + apt_datetime.format('M/dd/YYYY') + ' ' + ci.start_hour__c + ':' + ci.start_minute__c;
	  	        practice_body = 'A referral you sent to us has been rescheduled for a consultation on ' + apt_datetime.format('M/dd/YYYY') + ' ' + ci.start_hour__c + ':' + ci.start_minute__c;
	  	      }
	  	      else {
	  	        center_body = 'A referral from ' + office_name + ' has been scheduled for a consultation on ' + apt_datetime.format('M/dd/YYYY') + ' ' + ci.start_hour__c + ':' + ci.start_minute__c;
	  	        practice_body = 'A referral you sent to us has been scheduled for a consultation on ' + apt_datetime.format('M/dd/YYYY') + ' ' + ci.start_hour__c + ':' + ci.start_minute__c;
	  	      }
	  	    }
	  	    else if(ah.action__c=='No Show') {
	  	      center_body = 'A referral from ' + office_name + ' did not show up for a consultation';
	  	      practice_body = 'A referral you sent to us,  did not show up for a consultation';
	  	    }
	  	    else if(ah.action__c=='Left') {
	  	      center_body = 'A referral from ' + office_name + ' left their consultation';
	  	      practice_body = 'A referral you sent to us,  left their consultation';
	  	    }
	  	    else if(ah.action__c=='Cancel') {
	  	      center_body = 'A referral from ' + office_name + ' has just cancelled their consult';
	  	      practice_body = 'A referral you sent to us,  has just cancelled their consultation';
	  	    }
	  	    else if(ah.action__c=='Completed') {
	  	      center_body = 'A referral from ' + office_name + ' has just completed their consult';
	  	      practice_body = 'A referral you sent to us,  has just completed their consult';
	  	    } 
	  	  newPracticeFeed.newCenterFeedPostLink(center_id, center_body,'/' + link_id,'View Patient');
	  	  newPracticeFeed.newPracticeFeedPostLink(office_id, practice_body, '/referral/' + link_id, 'View Patient');
  	    }  	     
      }
  	}
  }
}