/*
Created by Chris McDowell on 1/10/2012
Trigger designed to create records in the campaign membership table when leads are updated or inserted.

Modified by CM on 2/1/2012
Trigger has been updated to add leads to a Fielded Leads campaign (based on Type) when the call result
is set to fielded lead.  Also updated the script so it would only run some of the SOQL queries if
certain situations in the code came up.  This was done to lower the SOQL query usage as the TestLeadTrigger script
was getting close to it's limit.

--After Insert
Trigger should try and match the Marketing_Source__c field against the campaign.phone_number field and look for 
a match where the status is In Progress (or active is true).  If it finds a match,  it should generate the
appropraite record in the campaign members table.  If no match is found,  the campaign id for the unknown bucket
campaign will be used instead and that record will be generated in the campaign members table

Modified by CM on 4/25/2012
Converted Phone numbers to uppercase for storing in the key field of the map and comparing to the key
field of the map.  We had an issue where campaigns with text based phone numbers ccwebsite were not matching
up due to case differences (ex : ccWebsite, ccwebsite, CCWebsite, CCwebsite).  This should be resolved going
forward. 

Modified by CM on 6/27/2013
Added in some code to tie leads to the loyalty campaign when the referred by patient option is checked
*/
trigger Lead_Campaign_Membership on Lead (after insert, after update) {
	//check to see if we've flagged this not to run_schedule_backup	
  if(!Util_TriggerContext.hasalreadyProcessed() && !Util_TriggerContext.has_cmember_alreadyProcessed()) {
	  //Insert path - we will create a record in the unknown campaign bucket if we can't match the record up.
	  if(Trigger.isInsert) {
	  	list <Lead> brochure_leads = new list <Lead>();
	  	list <CampaignMember> cml = new list<CampaignMember>();
	  	//variable to hold the id for the currently active Unknown bucket - Query will be run only if needed
	  	list <Campaign> unknown_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Fielded Leads bucket - Query will be run only if needed
	  	list <Campaign> fielded_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Web Leads 2 bucket - Query will be run only if needed
	  	list <Campaign> web2_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Web Leads 3 bucket - Query will be run only if needed
	  	list <Campaign> web3_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Loyalty Program bucket - Query will be run only if needed
	  	list <Campaign> loyalty_campaign = new list<Campaign>();  	  	
	  	
	  	//build a list of clean phone numbers in the trigger set so we can query and pull all camapigns at once
	  	Set<String> trigger_phone = new Set<String>();
	  	for(lead l : Trigger.new) {
	  	  string phone_num = '';  	  
	  	  //if we don't have a phone number here stop - too easy to match blank campaigns
	  	  if(l.Marketing_Source__c!=NULL) {    	  
		  	  phone_num = l.Marketing_Source__c;
	  	    phone_num = phone_num.replace('(','');
			    phone_num = phone_num.replace(')','');
			    phone_num = phone_num.replace(' ','');
			    phone_num = phone_num.replace('-','');
	        phone_num = phone_num.replace('#','');
	        phone_num = phone_num.replace('=','');
	        trigger_phone.add(phone_num);
	  	  }
	  	}
	  	
	  	system.debug('### Trigger Phone : ' + trigger_phone.size());
	  	Map<String, Campaign> all_campaigns = new Map<String,Campaign>();
	  	list <Campaign> used_campaigns = new list<Campaign>([select phone_number__c, id, type, doctor_id__c, practice_id__c from Campaign where 
	  	  phone_number__c in :trigger_phone and status = 'In Progress' and startdate <= today order by startdate desc]);  
	  	for(campaign c_temp : used_campaigns) {
	  		String my_key = string.valueof(c_temp.Phone_Number__c);
	  	  my_key = my_key.toUpperCase();
	  	  //take only the most recent campaign tied to a given phone number
	  	  if(!all_campaigns.containskey(my_key))
	      	all_campaigns.put(my_key,c_temp);
	  	}  
	  	 	  
	  	system.debug('### All Campaigns : ' + all_campaigns.size());	
	  	for (String index_test : all_campaigns.keySet()){
	      System.debug('Mapping is ' + index_test + ' : ' + all_campaigns.get(index_test).id);
	    }
	  	    	 
	  	for(Lead l: Trigger.new) { //work through all records in the trigger set
	  	  //clean up the marketing_source__c field as it will likely have some special characters in it
	  	  string phone_num = '';
	  	  //if we don't have a phone number here stop - too easy to match blank campaigns
	  	  if(l.Marketing_Source__c!=NULL) {    	  
			  	phone_num = l.Marketing_Source__c;
		  	  phone_num = phone_num.replace('(','');
				  phone_num = phone_num.replace(')','');
				  phone_num = phone_num.replace(' ','');
				  phone_num = phone_num.replace('-','');
		      phone_num = phone_num.replace('#','');
		      phone_num = phone_num.replace('=','');
		      phone_num = phone_num.toUpperCase();
	
	  	    CampaignMember cm = new CampaignMember();
	  	    system.debug('### Marketing_Source :' + l.Marketing_Source__c);
	  	    system.debug('### Phone # :' + phone_num);
	  	    if(all_campaigns.containskey(phone_num))
	  	      system.debug('### Map Campaign Id : ' + all_campaigns.get(phone_num).id);
	  	    else
	  	      system.debug('### No Campaign Match for above Phone #');
	  	        	  
	  	    //search for a match in campaign based on the phone number field
	  	    //disabled on 2012-2-1 by CM - pushed this out to a higher loop so we run one query to pull all campaign
	  	    //ids we need to match up
	  	    /*list <Campaign> c = [select id from Campaign where phone_number__c = :phone_num 
	  	      and status = 'In Progress' and startdate <= today order by startdate desc limit 1 ];*/
	  	
	  	    if(all_campaigns.containskey(phone_num)) {
	  	  	  //found a match - make the campaign member entry
	  	  	  //cm.campaignid = c[0].id;
	  	  	  cm.campaignid = all_campaigns.get(phone_num).id;
	  	  	  cm.leadid = l.id;
	  	  	  cm.Status = 'Responded';
	  	  	  cml.add(cm);
	  	  	  if(all_campaigns.get(phone_num).type=='Brochure') {
	  	  	  	//add this lead to the list so we can update it
	  	  	  	Lead adjusted_lead = [select id,referral_office__c,referral_doctor__c from lead where id = :l.id];
	  	  	  	adjusted_lead.referral_office__c = all_campaigns.get(phone_num).practice_id__c;
	  	  	  	adjusted_lead.referral_doctor__c = all_campaigns.get(phone_num).doctor_id__c;
	  	  	  	brochure_leads.add(adjusted_lead);
	  	  	  }
	  	    }
	  	    else {
	  	      phone_num = phone_num.toUpperCase();
	  	      if(phone_num.contains('SURVEY')) {
	  	      	if(web2_campaign.isEmpty())
	  	      	  web2_campaign = [select id from Campaign where type = 'Web Lead 2 (Leadlife)' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
	  	      	  //web3_campaign = [select id from Campaign where type = 'Web Lead 3 (IMS)' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
	  	      	cm.campaignid = web2_campaign[0].id;
	  	      }
	  	      else if(phone_num.contains('IMSWEB')) {
	  	      	if(web3_campaign.isEmpty())
	  	      	  web3_campaign = [select id from Campaign where type = 'Web Lead 3 (IMS)' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
	  	      	cm.campaignid = web3_campaign[0].id;
	  	      }
	  	      else {
		  	  	//need to create the campaign member using the unknown bucket
		  	  	if(unknown_campaign.isEmpty())
		  	  	//unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' order by createddate desc limit 1];
		  	  	//modified by cm on 2012-2-1 - Switching the query so it looks for the most recent campaign start date that is active and not at a point in the future
		  	  	  unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
		  	  	 //team requested that leads with seminar as the marketing source not go into the Unknown campaign
		  	  	 if(!phone_num.contains('SEMINAR'))  	  	    
		  	  	   cm.campaignid = unknown_campaign[0].id;
	  	      }
	  	  	  cm.leadid = l.id;
	  	  	  cm.Status = 'Responded';
	  	  	  if(cm.campaignid!=null)
	  	  	    cml.add(cm);
	  	    }	  
	  	  } //---end phone number null check
	  	  //need to check status to see if this was a fielded lead.  If so they need to be added to the current outbound campaign
	  	  if(l.Call_Result__c=='Fielded Lead') {
	  	  	if(fielded_campaign.isEmpty())
	  	  	  //fielded_campaign = [select id from Campaign where type = 'Fielded Leads Outbound' and status = 'In Progress' order by createddate desc limit 1];
	  	  	  //modified by cm on 2012-2-1 - Switching the query so it looks for the most recent campaign start date that is active and not at a point in the future
	  	  	  fielded_campaign = [select id from Campaign where type = 'Fielded Leads Outbound' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];  	  	  
	  	  	CampaignMember cm = new CampaignMember();  	  	
	  	  	cm.CampaignId = fielded_campaign[0].Id;
	  	  	cm.leadid = l.id;
	  	  	cm.Status = 'Responded';
	  	  	cml.add(cm);
	  	  }//--end call result = fielded lead test
	  	  //need to check if customer was referred	
	  	  if(l.Referred_by_Patient__c) {
	  	  	if(loyalty_campaign.isEmpty())	  	  	  
	  	  	  //modified by cm on 2012-2-1 - Switching the query so it looks for the most recent campaign start date that is active and not at a point in the future
	  	  	  loyalty_campaign = [select id from Campaign where type = 'Referral' and status = 'In Progress' and startdate <= today and phone_number__c in ('Loyalty','8888585324') order by startdate desc limit 1];  	  	  
	  	  	CampaignMember cm = new CampaignMember();  	  	
	  	  	cm.CampaignId = loyalty_campaign[0].Id;
	  	  	cm.leadid = l.id;
	  	  	cm.Status = 'Responded';
	  	  	cml.add(cm);
	  	  }  //--end loyalty/referral check
	  	}//---end trigger loop
	  	
	  	try {
		  	if(!cml.isEmpty()) {
		  	  Util_TriggerContext.alter_cmember_processed(true);
		  	  //Util_TriggerContext.setalreadyProcessed();
		  	  insert cml;
		  	  //Util_TriggerContext.alteralreadyprocessed(false);
		  	}
	  	}
	  	catch(Exception e) {
	  	  System.debug('Callout error: '+ e);
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('There was an error inserting campaign members');
 		  message.setHTMLbody('Exception Error : ' + e.getmessage() + '<br /><br />Stack : ' + e.getStackTraceString() + '<br /><br /># New Records ' + cml.size() + '<br /><br />Record : ' + cml);
    	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	  	}
	  	
	  	if(brochure_leads.size()>0) {
	  	  try {
	  	    Util_TriggerContext.setalreadyProcessed();
	  	    update brochure_leads;
	  	  }
	  	  catch (Exception e) {
	  	  	System.debug('Callout error: '+ e);
	          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	          message.setReplyTo('cmcdowell@clearchoice.com');
	          message.setSubject('There was an error updating brochure leads');
	 		  message.setHTMLbody('Exception Error : ' + e.getmessage() + '<br /><br />Stack : ' + e.getStackTraceString() + '<br /><br /># New Records ' + cml.size() + '<br /><br />Record : ' + cml);
	    	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	  	  }
	  	}
	  }
	  
	  /*Update path - Not a whole lot of difference.  Need to do some extra checking to verify the old and new values
	  have changed,  An unknown record won't be generated if we have any records in campaign members for this lead, and
	  I need to run a check to verify no duplicate campaign member records get created. */
	  if(Trigger.isUpdate) {  	
	  	list <Lead> brochure_leads = new list <Lead>();
	  	list <CampaignMember> cml = new list<CampaignMember>();
	  	//variable to hold the id for the currently active Unknown bucket
	  	//variable to hold the id for the currently active Unknown bucket - Query will be run only if needed
	  	list <Campaign> unknown_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Fielded Leads bucket - Query will be run only if needed
	  	list <Campaign> fielded_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active No Show-Cancellation Outbound Campaign - Query will be run only if needed
	  	list <Campaign> noshow_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Web Leads 2 bucket - Query will be run only if needed
	  	list <Campaign> web2_campaign = new list<Campaign>();
	  	//variable to hold the id for the currently active Web Leads 3 bucket - Query will be run only if needed
	  	list <Campaign> web3_campaign = new list<Campaign>();
	  		  	//variable to hold the id for the currently active Loyalty Program bucket - Query will be run only if needed
	  	list <Campaign> loyalty_campaign = new list<Campaign>();  	
	
		//build a list of clean phone numbers in the trigger set so we can query and pull all camapigns at once
	  	Set<String> trigger_phone = new Set<String>();
		  for(Lead l: Trigger.new) {
	  	  Lead oldLead = Trigger.oldMap.get(l.ID);    
	      Lead newLead = Trigger.newMap.get(l.ID);
	      system.debug('### Old Lead Marketing Source # :' + oldLead.Last_Marketing_Source__c + '### New Lead Marketing Source # : ' + newLead.Last_Marketing_Source__c);
	      //test the old and new vaules (after clean up), to verify they are different
	  	  string old_phone = '';
	  	  string new_phone = '';            
	      if(oldLead.Last_Marketing_Source__c!=NULL) {    	  
		  	  old_phone = oldLead.Last_Marketing_Source__c;
	  	    old_phone = old_phone.replace('(','');
			    old_phone = old_phone.replace(')','');
			    old_phone = old_phone.replace(' ','');
			    old_phone = old_phone.replace('-','');
	        old_phone = old_phone.replace('#','');
	        old_phone = old_phone.replace('=','');
	  	  }                  
	      if(newLead.Last_Marketing_Source__c!=NULL) {   //don't proceed if this is blank - too easy to match a blank phone # campaign 	  
		  	  new_phone = newLead.Last_Marketing_Source__c;
	  	    new_phone = new_phone.replace('(','');
			    new_phone = new_phone.replace(')','');
			    new_phone = new_phone.replace(' ','');
			    new_phone = new_phone.replace('-','');
	        new_phone = new_phone.replace('#','');
	        new_phone = new_phone.replace('=','');
	
	   	    //check to see if last marketing source value has changed - if not then no action will be taken
	  	    if(old_phone!=new_phone) {
	  	      trigger_phone.add(new_phone);
	  	    }
	      }
		}//--end build a list of clean phone numbers
		
		system.debug('### Trigger Phone : ' + trigger_phone.size());
	  	Map<String, Campaign> all_campaigns = new Map<String,Campaign>();
	  	list <Campaign> used_campaigns = new list<Campaign>([select phone_number__c, id, type, doctor_id__c, practice_id__c from Campaign where 
	  	  phone_number__c in :trigger_phone and status = 'In Progress' and startdate <= today order by startdate desc]);  
	  	for(campaign c_temp : used_campaigns) {
	  	  //take only the most recent campaign tied to a given phone number
	  	  String my_key = string.valueof(c_temp.Phone_Number__c);
	  	  my_key = my_key.toUpperCase();
	  	  if(!all_campaigns.containskey(my_key))
	      	all_campaigns.put(my_key,c_temp);
	  	}  
	  	 	  
	  	system.debug('### All Campaigns : ' + all_campaigns.size());	
	  	for (String index_test : all_campaigns.keySet()){
	      System.debug('Mapping is ' + index_test + ' : ' + all_campaigns.get(index_test).id);
	    }
	  	
	  	for(Lead l: Trigger.new) {
	  	  Lead oldLead = Trigger.oldMap.get(l.ID);    
	      Lead newLead = Trigger.newMap.get(l.ID);
	      system.debug('### Old Lead Marketing Source # :' + oldLead.Last_Marketing_Source__c + '### New Lead Marketing Source # : ' + newLead.Last_Marketing_Source__c);
	      //test the old and new vaules (after clean up), to verify they are different
	  	  string old_phone = '';
	  	  string new_phone = '';            
	      if(oldLead.Last_Marketing_Source__c!=NULL) {    	  
		  	  old_phone = oldLead.Last_Marketing_Source__c;
	  	    old_phone = old_phone.replace('(','');
			    old_phone = old_phone.replace(')','');
			    old_phone = old_phone.replace(' ','');
			    old_phone = old_phone.replace('-','');
	        old_phone = old_phone.replace('#','');
	        old_phone = old_phone.replace('=','');
	        old_phone = old_phone.toUpperCase();
	  	  }                  
	      if(newLead.Last_Marketing_Source__c!=NULL) {   //don't proceed if this is blank - too easy to match a blank phone # campaign 	  
		  	  new_phone = newLead.Last_Marketing_Source__c;
	  	    new_phone = new_phone.replace('(','');
			    new_phone = new_phone.replace(')','');
			    new_phone = new_phone.replace(' ','');
			    new_phone = new_phone.replace('-','');
	        new_phone = new_phone.replace('#','');
	        new_phone = new_phone.replace('=','');
	        new_phone = new_phone.toUpperCase();
	
	   	    //check to see if last marketing source value has changed - if not then no action will be taken
	  	    if(old_phone!=new_phone) {
	  	  	  //try to match the campaign id
	  	  	  CampaignMember cm = new CampaignMember();
	  	  	  if(all_campaigns.containskey(new_phone))
	  	        system.debug('### Map Campaign Id : ' + all_campaigns.get(new_phone).id);
	  	      else
	  	        system.debug('### No Campaign Match for above Phone # ' + new_phone);
	  	        	    	    
	  	      //disabled on 2012-2-1 by CM - pushed this out to a higher loop so we run one query to pull all campaign
	  	      //ids we need to match up
	  	      //search for a match in campaign based on the phone number field
	  	      /*list <Campaign> c = [select id from Campaign where phone_number__c = :new_phone 
	  	        and status = 'In Progress' and startdate <= today order by startdate desc limit 1 ];*/
	  	        	     	      
	  	      if(all_campaigns.containskey(new_phone)) {
	  	  	    //found a match - test to see if we already have a campaign member record for this campaign/leadid combo
	  	  	    Integer cm_records = [select count() from CampaignMember where CampaignId = :all_campaigns.get(new_phone).id
	  	  	      and LeadId = :l.id];
	  	  	    //System.debug('### Campaign : ' + c[0].id + ' Lead : ' + l.id + ' CM Records ' + cm_records);
	  	  	    if(cm_records==0) {  //no match - create the record  	  	  	
		  	  	    cm.campaignid = all_campaigns.get(new_phone).id;
		  	   	    cm.leadid = l.id;
		  	  	    cm.Status = 'Responded';
		  	        cml.add(cm);
		  	        if(all_campaigns.get(new_phone).type=='Brochure') {
			  	  	  	//add this lead to the list so we can update it
			  	  	  	Lead adjusted_lead = [select id,referral_office__c,referral_doctor__c from lead where id = :l.id];
			  	  	  	adjusted_lead.referral_office__c = all_campaigns.get(new_phone).practice_id__c;
			  	  	  	adjusted_lead.referral_doctor__c = all_campaigns.get(new_phone).doctor_id__c;
			  	  	  	brochure_leads.add(adjusted_lead);
			  	  	  }
	  	  	    }
	  	      }
	  	      else {
	  	      	new_phone = new_phone.toUpperCase();
	  	        if(new_phone.contains('SURVEY')) {
	  	      	  if(web2_campaign.isEmpty())
	  	      	    web2_campaign = [select id from Campaign where type = 'Web Lead 2 (Leadlife)' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
		  	      cm.campaignid = web2_campaign[0].id;
		  	      cm.leadid = l.id;
	  	  	      cm.Status = 'Responded';
	  	  	      cml.add(cm);
	  		    }
	  	        else if(new_phone.contains('IMSWEB')) {
	  	      	  if(web3_campaign.isEmpty())
	  	      	    web3_campaign = [select id from Campaign where type = 'Web Lead 3 (IMS)' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
	  	      	  cm.campaignid = web3_campaign[0].id;
	  	      	  cm.leadid = l.id;
	  	  	      cm.Status = 'Responded';
	  	  	      cml.add(cm);
	  	        }
	  	      	else {
	  	  	      //need to create the campaign member using the unknown bucket - if no other cm records exist for this lead
	              Integer cm_records = [select count() from CampaignMember where LeadId = :l.id];
	  	  	      //System.debug('### Campaign : ' + c[0].id + ' Lead : ' + l.id + ' CM Records ' + cm_records);
	  	  	      //team requested that leads with seminar as the marketing source not go into the Unknown campaign
	  	  	      if(cm_records==0 && !new_phone.contains('SEMINAR')) {  //no records in CampaignMember - create an unknown record
	  	   	  	    if(unknown_campaign.isEmpty())
		  	  	    //unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' order by createddate desc limit 1];
	  	  	        //modified by cm on 2012-2-1 - Switching the query so it looks for the most recent campaign start date that is active and not at a point in the future
	  	  	          unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];  	  	    	  	  
	  	  	        cm.campaignid = unknown_campaign[0].id;
	  	  	        cm.leadid = l.id;
	  	  	        cm.Status = 'Responded';  	  	      
	  	  	        cml.add(cm);
	  	  	      }
	  	      	}
	  	  	    
	  	      } //--end check for phoen match to campaign  	      	    	    	     
	  	    }  //--end compare old phone to new phone #
	      } //--end check for blank new phone #
	        
	      //need to check status to see if this was a fielded lead and if the status was changed.  
	      //If so they need to be added to the current outbound campaign
	  	  if(newlead.Call_Result__c=='Fielded Lead' && oldlead.Call_Result__c!='Fielded Lead') {
	  	  	//check to make sure this lead is not alread in the current fielded campaign 
	  	  	if(fielded_campaign.isEmpty())
	  	  	  //fielded_campaign = [select id from Campaign where type = 'Fielded Leads Outbound' and status = 'In Progress' order by createddate desc limit 1];
	  	  	  //modified by cm on 2012-2-1 - Switching the query so it looks for the most recent campaign start date that is active and not at a point in the future
	  	  	  fielded_campaign = [select id from Campaign where type = 'Fielded Leads Outbound' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
	  	  	Integer cm_records = [select count() from CampaignMember where LeadId = :l.id and CampaignId = :fielded_campaign[0].Id];
	  	  	if(cm_records==0) {  	  	
			  	  CampaignMember cm = new CampaignMember();  	  	  	  	
			  	  cm.CampaignId = fielded_campaign[0].Id;
			  	  cm.leadid = l.id;
			  	  cm.Status = 'Responded';
			  	  cml.add(cm);
	  	  	}
	  	  }  	
	  	  if(newlead.Referred_by_Patient__c && !oldlead.Referred_by_Patient__c) {
	  	  	//check to make sure this lead is not alread in the current fielded campaign 
	  	  	if(loyalty_campaign.isEmpty())
	  	  	  //fielded_campaign = [select id from Campaign where type = 'Fielded Leads Outbound' and status = 'In Progress' order by createddate desc limit 1];
	  	  	  //modified by cm on 2012-2-1 - Switching the query so it looks for the most recent campaign start date that is active and not at a point in the future
	  	  	  loyalty_campaign = [select id from Campaign where type = 'Referral' and status = 'In Progress' and startdate <= today and phone_number__c in ('Loyalty','8888585324') order by startdate desc limit 1];
	  	  	Integer cm_records = [select count() from CampaignMember where LeadId = :l.id and CampaignId = :loyalty_campaign[0].Id];
	  	  	if(cm_records==0) {  	  	
		  	    CampaignMember cm = new CampaignMember();  	  	  	  	
		  	    cm.CampaignId = loyalty_campaign[0].Id;
		  	    cm.leadid = l.id;
		  	    cm.Status = 'Responded';
		  	    cml.add(cm);
	  	  	}
	  	  }    
	      	                    
	  	} //--end trigger for loop
	  	try {
		  	if(!cml.isEmpty()) {
		  	  Util_TriggerContext.alter_cmember_processed(true);
		  	  //Util_TriggerContext.setalreadyProcessed();
		  	  insert cml;
		  	  //Util_TriggerContext.alteralreadyprocessed(false);
		  	}
		}
	  	catch(Exception e) {
	  	  System.debug('Callout error: '+ e);
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('There was an error inserting campaign members');
 		  message.setHTMLbody('Exception Error : ' + e.getmessage() + '<br /><br />Stack : ' + e.getStackTraceString() + '<br /><br /># New Records ' + cml.size());
    	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	  	}
	  	
	  	if(brochure_leads.size()>0) {
	  	  try {
	  	    Util_TriggerContext.setalreadyProcessed();
	  	    update brochure_leads;
	  	  }
	  	  catch (Exception e) {
	  	  	System.debug('Callout error: '+ e);
	          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	          message.setReplyTo('cmcdowell@clearchoice.com');
	          message.setSubject('There was an error updating brochure leads');
	 		  message.setHTMLbody('Exception Error : ' + e.getmessage() + '<br /><br />Stack : ' + e.getStackTraceString() + '<br /><br /># New Records ' + cml.size() + '<br /><br />Record : ' + cml);
	    	  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	  	  }
	  	}
	  } //--end Trigger update
  }
}