/*
modified by cm on 2012-2-6
This trigger currently checks to see if a new campaign was created (but not cloned).  The trigger then
adds several campaign member statuses to the campaign.    

I'm going to be adding a new section towards the end that will search for any leads that tie to this
campaign based on:
  Phone number match between the campaign and the lead record
  Lead creation date is greater than or equal to the start date for the campaign (and less than end date)
  Lead is currently not a member of a campaign (ignore the unknown campaign)
  
When any leads meet this criteria,  I will automatically add them as campaign members for this campaign and
remove them from an unknown campaign if they are in one.
The update version of this code will work the same except I'll verify the phone number was changed on the
campaign before I take any further steps.

modified by cm on 2012-3-1
tweaked the process so it will now properly handle any leads that have been converted to contacts/accounts.
The query was excluding these items from the search previously.

modified by cm on 2012-4-24
update now looks for a change in the start date and end date,  in addition to a chance of phone number in order
to trigger.  The end date filter was adjusted so it will use a time of 23:59:59 on that day as the filter.
Added a try/catch method to handle DML exceptions of duplicate contact records.  This should cycle through 
the insert list and pull them from it. 
*/
trigger UpdateCampaignMemberStatu on Campaign (after insert, after update) {
	//check to see if we've flagged this not to run
  if(!Util_TriggerContext.hasalreadyProcessed()) {
	  if(Trigger.isInsert) {
	  	//variable to hold the id for the currently active Unknown bucket - Query will be run only if needed
	  	list <Campaign> unknown_campaign = new list<Campaign>();
	  	list <CampaignMember> cml = new list<CampaignMember>();
	  	set<ID> cml_leads = new Set<ID>();
	  	list <CampaignMember> cm_delete = new list<CampaignMember>();
	    //making a list of all the campaign ids in the insert
	    Set<ID> campaignIds = new Set<ID>();
	    for(Campaign c: Trigger.new){
	      campaignIds.add(c.id);        
	    }
	    
	    //holder to add new campaignmemberstatuses to.  These will be inserted at the end
	    List<CampaignMemberStatus> insertList = new List<CampaignMemberStatus>();
	    /*holder to pull a list of all current campaign member statuses tied to the inserts in the trigger set
	    looks like they are just trying to make sure that no one created a new campaign via clone as that
	    will port over the campaign statuses and result in duplicates.  What's interesting is they don't
	    do a map of the id's to the boolean value so you only end up adding statuses to all of the campaigns
	    or none of them. This is probably fine as you can't batch clone records that I'm aware of but it looks 
	    a little odd when you follow the logic*/
	    List<CampaignMemberStatus> existingCMStatus = new List<CampaignMemberStatus>();
	    existingCMStatus = [select id, Label FROM CampaignMemberStatus WHERE CampaignId in: campaignIds];
	    
	    Boolean isClone = false; 
	    for(CampaignMemberStatus cms:  existingCMStatus){
	      //if one of the statuses below was found,  they are assuming clone was hit - no inserts will be performed
	      if(cms.Label =='Confirmed'){
	        isClone = true;            
	      }        
	    }
	    
	    //rewrote the insert to condense things a bit
	    String[] my_status_list = new String[] {'Registered','Confirmed','Attended','No Show Seminar','Scheduled Consult','Attended Consult','No Show Consult','Started','Start Lost'};
	    if(isClone == false) { //--checking boolean first because there's no point in cycling through the set otherwise
	      for(Campaign c: Trigger.new) {
	      	Integer my_sort_order = 3;
	      	for(String my_status: my_status_list) {
	      	  CampaignMemberStatus cms1 = new CampaignMemberStatus(Label = my_status, HasResponded = false, CampaignId = c.id, SortOrder = my_sort_order);
	      	  my_sort_order++;
	      	  //system.debug('####--Campaign Member Status : ' + cms1);
	      	  insertList.add(cms1);
	      	}      	 
	      }      
	    } //---end isclone check
	    if(!insertlist.isempty())
	      try {
	        insert insertList;
	      } catch (System.DmlException e) {
	      	//this will error out if we have a cloned campaign - push on.
	        for (Integer i = 0; i < e.getNumDml(); i++) {
	        	System.debug('ID : ' + e.getDmlId(i) + ' Msg : ' +  e.getDmlMessage(i) + ' Index : ' + e.getDmlIndex(i));
	        }
	      }   
	    
	    //look through each campaign in the trigger and check to see if we have a phone number and a starting date
	    for(Campaign c : Trigger.new) {
	      String phone_num = '';
	      if(c.Phone_Number__c!=NULL && c.Phone_Number__c.trim()!='') {
	      	phone_num = c.Phone_Number__c;
	  	    phone_num = phone_num.replace('(','');
			    phone_num = phone_num.replace(')','');
			    phone_num = phone_num.replace(' ','');
			    phone_num = phone_num.replace('-','');
	        phone_num = phone_num.replace('#','');
	        phone_num = phone_num.replace('=','');
	        
	        //figure out what the unknown campaign is
	      if(unknown_campaign.isEmpty())
		      unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
		    list<lead> matched_leads = new list<lead>();
		    //now search for all leads that might potentially match to this new campaign
		    if(c.EndDate!=NULL) {
		    	String filter_date = c.EndDate.year() + '-' + c.EndDate.month() + '-' + c.EndDate.day() + ' 23:59:59';
		    	Datetime end_filter = datetime.valueof(filter_date);
		      //matched_leads = [Select l.id,l.Name, l.CreatedDate, (Select campaignid,id From CampaignMembers where campaignid not in :unknown_campaign limit 1)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.createddate <= :c.EndDate and l.ConvertedAccountId = null];
		      //matched_leads = [Select l.id,l.Name, l.CreatedDate, l.convertedcontactid,(Select campaignid,id From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.createddate <= :c.EndDate and l.ConvertedAccountId = null];
		      //convertedcontactid check is to look for odd orphaned records in the system
		      matched_leads = [Select l.id,l.Name, l.CreatedDate, l.convertedcontactid,(Select campaignid,id From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.createddate <= :end_filter and ((l.convertedaccountid = null and l.convertedcontactid = null) or l.convertedcontactid <> null) ];
		    }
		    else
		    //convertedcontactid check is to look for odd orphaned records in the system
		      matched_leads = [Select l.id,l.Name, l.CreatedDate, l.convertedcontactid,(Select campaignid,id From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and ((l.convertedaccountid = null and l.convertedcontactid = null) or l.convertedcontactid <> null)];
		  	  //matched_leads = [Select l.id,l.Name, l.CreatedDate, (Select campaignid,id From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.ConvertedAccountId = null];
		    //look through all of the matched leads and check to see if any of them are currently not tied to any campaign 
		    for(integer i=0;i<matched_leads.Size();i++){
		  	  system.debug('### Lead Id : ' + matched_leads[i].id);
		  	  //work through the campaigns it is a member of
		  	  Integer num_campaigns = 0;
		  	  CampaignMember unknown_cm_id;
		  	  Integer num_unknown = 0;
		  	  for(CampaignMember cm : matched_leads[i].campaignmembers) {
		  	  	if(cm.CampaignId == unknown_campaign[0].id) {
		  	  	  num_unknown++;
		  	  	  unknown_cm_id = cm;
		  	  	}
		  	  	else if(cm.CampaignID == c.id)
		  	  	  num_campaigns++;
		  	  }
		  	  //system.debug('### Unknown : ' + num_unknown + '  ### Other : ' + num_campaigns);
		  	  //if(matched_leads[i].campaignmembers.Size()==0) {
		  	  //changing this rule on 2-28-2012 per Teri and Steve
		  	  //they want duplication here - make sure it's not already a member of this campaign though
		  	  if(num_campaigns==0) {
		  	    //system.debug('### NO CAMPAIGN - Adding');
		  	    CampaignMember cm = new CampaignMember();  		  	      	
		  	      cm.CampaignId = c.Id;	  	    
		  	      String match_value = '';
		  	      if(matched_leads[i].convertedcontactid==null) {  
		  	        cm.leadid = matched_leads[i].Id;
		  	        match_value = matched_leads[i].Id;
		  	      }
		  	      else { 
		  	        cm.contactid = matched_leads[i].convertedcontactid;
		  	        match_value = matched_leads[i].convertedcontactid;
		  	      }
		  	    cm.Status = 'Responded';
		  	    
		  	    //make sure lead is not a duplicate
		  	    if(!cml_leads.contains(match_value)) {
		  	      cml.add(cm);
		  	      cml_leads.add(match_value);
		  	    }
		  	    //system.debug('### Insert Campaign Member (update) : ' + cm);
		  	    //insert cm;
		  	    //check for any unknown entries so we can mark them for deletion
		  	    //list <CampaignMember> cm_delete = [select id from CampaignMember where campaignid = :unknown_campaign and LeadId = :matched_leads[i].Id];
		  	    //system.debug('### In Unknown Campaign - Adding to list to remove');
		  	    if(num_unknown>0) {
	              cm_delete.add(unknown_cm_id); 
		  	    }
		  	  }
		    } //---end look through lead matches        
	      } //--end check for a valid phone number        	  	  	      	         
	    } ///---end cycle through campaigns and look for lead matches
	    if(!cml.isEmpty()) { 
	      //system.debug('### Inserting Campaign Members (Insert) : ' + cml); 
	  	  insert cml;  	  
	    }
	    
	    if(!cm_delete.isEmpty()) {
	      //system.debug('### Deleting Campaign Members (delete) : ' + cm_delete);
		  delete cm_delete;
	    }
	
	  } //---end trigger is insert
	  
	  if(Trigger.isUpdate) {
	  	//variable to hold the id for the currently active Unknown bucket - Query will be run only if needed
	  	list <Campaign> unknown_campaign = new list<Campaign>();
	  	list <CampaignMember> cml = new list<CampaignMember>();
	  	set<ID> cml_leads = new Set<ID>();
	  	list <CampaignMember> cm_delete = new list<CampaignMember>();
	  	
	  	//look through each campaign in the trigger and check to see if the phone number has been modified
	    for(Campaign c : Trigger.new) {
	      Campaign oldCampaign = Trigger.oldMap.get(c.ID);    
	      Campaign newCampaign = Trigger.newMap.get(c.ID);
	      String phone_num = '';
	      //modified by cm on 2012-4-24
	      //based on my discussion with Teri,  we want to make sure the update trigger runs if there is a
	      //change to the start and end date as well as the phone number
	      if((oldCampaign.Phone_Number__c != newCampaign.Phone_Number__c || oldCampaign.StartDate != newCampaign.StartDate || oldCampaign.EndDate != newCampaign.EndDate) && newCampaign.Phone_Number__c!=null && newCampaign.Phone_Number__c.trim()!='') {
	      	//phone number was updated - need to look for possible lead matches to the new phone number      	
	      	phone_num = newCampaign.Phone_Number__c;
	  	    phone_num = phone_num.replace('(','');
			phone_num = phone_num.replace(')','');
			phone_num = phone_num.replace(' ','');
			phone_num = phone_num.replace('-','');
	        phone_num = phone_num.replace('#','');
	        phone_num = phone_num.replace('=','');
	        
	        //figure out what the unknown campaign is
	        if(unknown_campaign.isEmpty())
		      unknown_campaign = [select id from Campaign where name = 'Unknown' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
		    list<lead> matched_leads = new list<lead>();
		    //now search for all leads that might potentially match to this new Campaign
		    if(c.EndDate!=NULL) {
		    	String filter_date = c.EndDate.year() + '-' + c.EndDate.month() + '-' + c.EndDate.day() + ' 23:59:59';
		    	Datetime end_filter = datetime.valueof(filter_date);
		      //matched_leads = [Select l.id,l.Name, l.CreatedDate, (Select campaignid From CampaignMembers where campaignid not in :unknown_campaign limit 1)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.createddate <= :c.EndDate and l.ConvertedAccountId = null];
		      //matched_leads = [Select l.id,l.Name, l.CreatedDate, (Select campaignid From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.createddate <= :c.EndDate and l.ConvertedAccountId = null];
		      //convertedcontactid check is to look for odd orphaned records in the system
		      matched_leads = [Select l.id,l.Name, l.CreatedDate, l.convertedcontactid, (Select campaignid From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.createddate <= :end_filter and ((l.convertedaccountid = null and l.convertedcontactid = null) or l.convertedcontactid <> null)];
		    }
		    else
		  	  //matched_leads = [Select l.id,l.Name, l.CreatedDate, (Select campaignid From CampaignMembers where campaignid not in :unknown_campaign limit 1)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.ConvertedAccountId = null];
		  	  //matched_leads = [Select l.id,l.Name, l.CreatedDate, (Select campaignid From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and l.ConvertedAccountId = null];
		  	  //convertedcontactid check is to look for odd orphaned records in the system
		  	  matched_leads = [Select l.id,l.Name, l.CreatedDate, l.convertedcontactid, (Select campaignid From CampaignMembers)campaignid From Lead l where l.marketing_source_formula__c = :phone_num and l.createddate >= :c.startdate and ((l.convertedaccountid = null and l.convertedcontactid = null) or l.convertedcontactid <> null)];
		    //look through all of the matched leads and check to see if any of them are currently not tied to any campaign 
		    for(integer i=0;i<matched_leads.Size();i++) {
		  	  system.debug('### Lead Id : ' + matched_leads[i].id);
		  	  Integer num_campaigns = 0;
		  	  CampaignMember unknown_cm_id;
		  	  Integer num_unknown = 0;
		  	  for(CampaignMember cm : matched_leads[i].campaignmembers) {
		  	  	if(cm.CampaignId == unknown_campaign[0].id) {
		  	  	  num_unknown++;
		  	  	  unknown_cm_id = cm;
		  	  	}
		  	  	else if(cm.CampaignID == c.id)
		  	  	  num_campaigns++;	  	  	
		  	  }
		  	  system.debug('### Unknown : ' + num_unknown + '  ### Other : ' + num_campaigns);  
		  	  //if(matched_leads[i].campaignmembers.Size()==0) {
		  	  //changing this rule on 2-28-2012 per Teri and Steve
		  	  //they want duplication here - make sure it's not already a member of this campaign though	  	  
		  	  if(num_campaigns==0) { 
		  	  	//system.debug('### NO CAMPAIGN');
		  	    CampaignMember cm = new CampaignMember();  	  	
		  	    cm.CampaignId = c.Id;
		  	    String match_value = '';
	  	        if(matched_leads[i].convertedcontactid==null) {  
	  	          cm.leadid = matched_leads[i].Id;
	  	          match_value = matched_leads[i].Id;
	  	        }
	  	        else { 
	  	          cm.contactid = matched_leads[i].convertedcontactid;
	  	          match_value = matched_leads[i].convertedcontactid;
	  	        }
		  	    cm.Status = 'Responded';
		  	    
		  	    //make sure lead is not a duplicate
		  	    if(!cml_leads.contains(match_value)) {
		  	      cml.add(cm);
		  	      cml_leads.add(match_value);
		  	    }
		  	    //system.debug('### Insert Campaign Member (update) : ' + cm);
		  	    //insert cm;
		  	    //check for any unknown entries so we can mark them for deletion
		  	    //list <CampaignMember> cm_delete = [select id from CampaignMember where campaignid = :unknown_campaign and LeadId = :matched_leads[i].Id];
		  	    if(num_unknown>0) {
	              cm_delete.add(unknown_cm_id); 
		  	    }	  	    
		  	  }
		    } //---end look through lead matches          
	      }//---end check phone number
	    }//--end cycle through campaigns in trigger
	        
	    if(!cml.isEmpty()) {
	      //system.debug('### Inserting Campaign Members (Update) : ' + cml);
	      try { 
	  	    insert cml;
	      }
	      catch(DMLException e) {
	      	//List<CampaignMember> remove_list = new List<CampaignMember>{};
	      	for(Integer i = e.getNumDML()-1; i >= 0; i--) {
	      		//likely a duplicate since we don't fully test if contacts were already members
	      		System.debug('DML Error : ' + e.getDMLMessage(i) + ' Line : ' + e.getLineNumber() + ' Index Position : ' + e.getDmlIndex(i));
	      		//remove_list.add(cml[e.getDMLIndex(i)]
	      		cml.remove(e.getDmlIndex(i));      		
	      	}     
	      	/*for(CampaignMember dr : remove_list) {
	      		for(Integer i = 0;i <= cml.size();i++) {
	      			if(cml[i].contactid<>null && cml[i].contactid==dr.contactid && cml[i].campaignid == dr.campaignid)
	      			  cml.remove(i);
	      		}
	      	}*/
	      	if(!cml.isEmpty())
	      	  insert cml;
	      }  	  
	    }
		 
		if(!cm_delete.isEmpty()) {
	      //system.debug('### Deleting Campaign Members (delete) : ' + cm_delete);
		  delete cm_delete;
	    } 
	  }//---end trigger is update
  }
}