/*
Trigger created by cm on 6/1/2012
This trigger is set up to handle the Facebook WTL seminar registrations.  The trigger takes data from a couple of lead 
custom fields and populates the matching field on the campaign member record.  

Modified by CM on 6/13/2012
Added a before update trigger that sets a confirmation time field on the campaign member record when the status is switched 
to Confirmed

Modified by CM on 63/10/2017
Turned this off,  as I don't believe it's actively in use now - trying to reduce the load on campaign member inserts
*/

trigger seminar_guests on CampaignMember (before insert, before update) {
	//check to see if we've flagged this not to run
  /*if(!Util_TriggerContext.hasalreadyProcessed()) {
  	
		if(trigger.isInsert) {
			Set<Id> all_lead_ids = new Set<Id>();
			Set<Id> all_campaign_ids = new Set<Id>();
			String rid = [Select id From RecordType where name = 'Seminars' and SobjectType = 'Campaign'].id;
			
		  for(CampaignMember cm : Trigger.new) {
		  	if(cm.leadid!=null)
		      all_lead_ids.add(cm.leadid);
		    all_campaign_ids.add(cm.campaignid);
		  }
		  Map<Id,Campaign> all_campaigns = new Map<Id,Campaign>();
		  Map<Id,Lead> all_leads = new Map<Id,Lead>();  
		  for(Lead l : [select id,guest_name__c,description,trigger_referral_source__c from lead where id in :all_lead_ids]) {
		  	all_leads.put(l.id,l);
		  }
		  for(Campaign c : [select id,type,recordtypeid from campaign where id in : all_campaign_ids]) {
		  	all_campaigns.put(c.id,c);
		  }
		  
		  for(CampaignMember cm : Trigger.new) {
		  	if(cm.leadid!=null && cm.ContactId==null) {
		  		Lead l = all_leads.get(cm.leadid);
		  		Campaign c = all_campaigns.get(cm.campaignid);
		  		//check to see if this is a Facebook - Web To Lead entry.  If so populate the guest # and 
		  		if(l.trigger_referral_source__c=='Facebook' && c.recordtypeid == rid) {
		  			try {
		  			  if((cm.Num_Guests__c==null || cm.Num_Guests__c==0) && l.guest_name__c!=null && l.guest_name__c!='')
		  			    cm.Num_Guests__c = Integer.valueof(l.Guest_Name__c);
		  			}
		  			catch (Exception e) {
		  				//non integer value was loaded into l.guest_name__c
		  			}
		  			if(cm.Guest_Names__c==null || cm.Guest_Names__c=='')
		  			  cm.Guest_Names__c = l.description;
		  		}  		  	
		  	}
		  }
		}
		
		if(trigger.isUpdate) {
		  //work through all records and see if the confirmation status was changed to confirmed.  If so set the Confirmation_Time__c
		  for(CampaignMember cm : Trigger.new) {  	     
	      if(cm.status=='Confirmed') {
	      	CampaignMember oldcm = Trigger.oldMap.get(cm.id);
	      	if(cm.status<>oldcm.status)
	      	  cm.Confirmation_Time__c = System.now();
	      }
		  }
		} 
	
  }*/
}