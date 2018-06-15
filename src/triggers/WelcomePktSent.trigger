/**********************************************************************************
Name    : WelcomePktSent
Usage   : For the ActivityHistory object, Updates one of two fields based on ActivityHistory object

CHANGE HISTORY
===============================================================================
DATE            NAME                          DESC
2011-03-09     Mike Merino            Initial release                
2011-03-29     Seth Davidow           making changes
2011-04-29     Mike Merino            Change l3
2011-09-12	   Seth Davidow			  Added trigger.new[i].WhoId != NULL to line 29 to prevent apex errors 
2012-02-02	   Chris McDowell		  Format Clean up.  Added new check for BCP Packet and DVD

modified by cm on 2012-02-10   
I've added the before insert clause to the trigger and built isbefore and isafter sections of code to seperate
the pieces properly.  The isbefore section will now run a query to calculate the attempt field for the record prior
to the insert.  The isafter section contains all of the old code that was running previously

modified by cm on 2012-02-23
Added some new code to handle the confirmation team process with the new call logging system.  Certain fields
on the lead record will be checked or unchecked as the result of logging certain calls now.
  
*************************************************************************************/
/* from the internet!!
ActivityHistory is a view of closed events and tasks, so you could query the base data tables
 instead. ActivityHistory itself can be queried only as part of an aggregate query, 
 so you can get the activityHistory for a particular account by using a query something 
 like  
select id, name, (select id, subject from activityHistories) from account where id='...'
in this case it appears the relevant object is Task  
*/
    
trigger WelcomePktSent on Task (before insert, after insert, after update) {
	//check to see if we've flagged this not to run
  if(!Util_TriggerContext.hasalreadyProcessed()) {
	  if(trigger.isBefore) {
	  	for(Task my_task : Trigger.new) {
	  	  //putting this in place to handle tasks that are not tied to leads/contacts/accounts
	  	  if(my_task.Whoid!=null)
		  	if(my_task.Activity_Type__c=='Outbound Call') {
			  Integer my_attempts = [select count() from Task where whoid = :my_task.Whoid and Activity_Type__c = 'Outbound Call']; 
			  my_task.Attempt__c = my_attempts+1;	    
		  	}
	  	  if(my_task.Outcome__c=='Busy/No Answer' || my_task.Outcome__c=='Disconnect/Not in Service' ||
	  	    my_task.Outcome__c=='Wrong Number' ||  my_task.Outcome__c=='VM - LM' ||
	  	    my_task.Outcome__c=='VM - no message' ||  my_task.Outcome__c=='VM - full' ||
	  	    my_task.Outcome__c=='LM - 3rd Party') 
	  	    my_task.Call_No_Answer__c = true;
	  	  else
	  	    my_task.Call_No_Answer__c = false;
	  	}
	  }
		
	  if(trigger.isAfter) {	
	  	User this_user = [select id,Call_Center_Team__c from User where id = :trigger.new[0].ownerid];
	  	system.debug('Call_Center_Team : ' + this_user.Call_Center_Team__c);
	    List<Lead> Leads = new  List<Lead>();
	    List<Lead> sched_updates = new List<Lead>();
	    Lead l3;
	    Set<ID> consult_leads = new Set<ID>();
	    Set<ID> nonsched_leads = new Set<ID>();
	
	    for (integer i=0; i<trigger.new.size();i++) {    	
	      //system.debug('###   '+trigger.new[i].WhoId + '' + string.valueof(trigger.new[i].WhoId));
	      if (trigger.new[i].WhoId != NULL && string.valueof(trigger.new[i].WhoId).startswith('00Q')){                           
	        system.debug('### welcome pkt not yet sent '+l3);         
	        
	        if(trigger.new[i].subject!=NULL) {     
	          if(trigger.new[i].subject.contains('Email: ClearChoice Dental Implant Consultation')  ||
	              trigger.new[i].subject.contains('Email: Request for Confirmation of your ClearChoice Consultation') ||
	              trigger.new[i].subject.contains('Email: ClearChoice: Consulta para Implantes Dentales')) {
	            l3= new Lead(id = trigger.new[i].WhoId,email_welcome_packet_sent__c = true); 
	            //Leads.add(l3);
	            update l3;
	          }
	          else if(trigger.new[i].subject.contains('Welcome')) {
	            l3= new Lead(id = trigger.new[i].WhoId,welcome_packet_sent__c = true);
	            //Leads.add(l3);
	            update l3; 
	          } 
	          else if(trigger.new[i].subject.contains('BCP Letter') 
	            || trigger.new[i].subject.contains('DVD Information Letter') 
	            || trigger.new[i].subject.contains('Email: Thank you for contacting ClearChoice Dental Implant Center')
	          ) {      	
	            l3= new Lead(id = trigger.new[i].WhoId, BCP_DVD_Packet_Sent__c = true);
	            //Leads.add(l3);
	            update l3; 
	          }
	        } //--end test subject for a null
	        
	        if(trigger.new[i].Activity_Type__c=='Outbound Call') {
	          //check the outcome and update the confirmation section of the lead record;
	          //could not reach patient
	          if((trigger.new[i].Outcome__c=='Busy/No Answer' || trigger.new[i].Outcome__c=='Disconnect/Not in Service' ||
	           trigger.new[i].Outcome__c=='Wrong Number' || trigger.new[i].Outcome__c=='VM - full' || trigger.new[i].Outcome__c=='VM - no message') && this_user.Call_Center_Team__c == 'Confirmation' ) {
	           	system.debug('Could Not Reach Patient');
	            l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = false, Could_not_Reach__c = true, Left_Message_to_Confirm__c = false);
	            Leads.add(l3);
	          }
	          //confirmed apt
	          if((trigger.new[i].Outcome__c=='Consult Scheduled' || trigger.new[i].Outcome__c=='Consult Confirmed' ||
	            trigger.new[i].Outcome__c=='Consult Rescheduled' || trigger.new[i].Outcome__c=='Seminar Scheduled' ||
	            trigger.new[i].Outcome__c=='Seminar Confirmed' || trigger.new[i].Outcome__c=='Seminar Rescheduled')
	            && this_user.Call_Center_Team__c == 'Confirmation') {            	
	            //check to see if the consult is scheduled within the next three days
	            /*Date seminar_range = date.today();
	            seminar_range = seminar_range.adddays(4);
	            Datetime seminar_filter = datetime.newInstance(seminar_range.year(), seminar_range.month(), seminar_range.day());
	            system.debug('Confirmed if date is less than ' + seminar_range);
	            Integer confirm_check = [select count() from lead where id = :trigger.new[i].Whoid and DateTime_Consult_Scheduled__c < :seminar_filter];
	            if(confirm_check>0)*/ 
	          	  l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = true, Could_not_Reach__c = false, Left_Message_to_Confirm__c = false);
	            //else 
	              //l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = false, Could_not_Reach__c = false, Left_Message_to_Confirm__c = false);
	            Leads.add(l3);
	          }
	          //left message to confirm
	          if((trigger.new[i].Outcome__c=='VM - LM'  || trigger.new[i].Outcome__c=='LM - 3rd Party') && this_user.Call_Center_Team__c == 'Confirmation') {
	          	system.debug('Left Message');
	            l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = false, Could_not_Reach__c = false, Left_Message_to_Confirm__c = true);
	            Leads.add(l3);          
	          }
	          //cancelled
	          if((trigger.new[i].Outcome__c=='Consult Cancelled' || trigger.new[i].Outcome__c=='Seminar Cancelled') && this_user.Call_Center_Team__c == 'Confirmation') {
	          	system.debug('Cancelled');
	            l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = false, Could_not_Reach__c = false, Left_Message_to_Confirm__c = false);
	            Leads.add(l3);          	
	          }
	        }
	        
	        if(trigger.new[i].Activity_Type__c=='Inbound Call' && trigger.new[i].Outcome__c=='Not Scheduled') {
	          l3 = new Lead(id = trigger.new[i].WhoID, Objection__c = trigger.new[i].objection__c, why_not_schedule__c = trigger.new[i].why_not_schedule__c,status = 'Not Scheduled');
	          sched_updates.add(l3);
	          nonsched_leads.add(trigger.new[i].WhoID);
	        }
	        
	        if(trigger.new[i].Activity_Type__c=='Inbound Call' || trigger.new[i].Activity_Type__c=='Inbound Email' ) {
	          //confirmed apt
	          if( trigger.new[i].Outcome__c=='Consult Confirmed') {
	            //check to see if the consult is scheduled within the next three days
	            /*Date seminar_range = date.today();
	            seminar_range = seminar_range.adddays(4);
	            Datetime seminar_filter = datetime.newInstance(seminar_range.year(), seminar_range.month(), seminar_range.day());
	            Integer confirm_check = [select count() from lead where id = :trigger.new[i].Whoid and DateTime_Consult_Scheduled__c < :seminar_filter];
	            if(confirm_check>0)*/ 
	          	  l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = true, Could_not_Reach__c = false, Left_Message_to_Confirm__c = false);
	            //else 
	              //l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = false, Could_not_Reach__c = false, Left_Message_to_Confirm__c = false);
	            Leads.add(l3);
	          }	
	          
	          if(trigger.new[i].Outcome__c=='Consult Cancelled') {
	            l3= new Lead(id = trigger.new[i].WhoId, Confirmed_Appointment__c = false, Could_not_Reach__c = false, Left_Message_to_Confirm__c = false);
	            Leads.add(l3);          	
	          }
	        }
	        
	        //check to see if a seminar outcome was selected - if so we want to search for any seminar campaigns assigned to
	        //this lead record and update the status of that campaign member to the appropriate value
	        system.debug('### Outcome : ' + trigger.new[i].Outcome__c);
	        set<string> seminar_status = new Set<string> {'Seminar Scheduled','Seminar Cancelled','Seminar Confirmed'};
	        if(seminar_status.contains(trigger.new[i].Outcome__c)) {        	
	          list<CampaignMember> seminar_cm = [select id,campaignid from CampaignMember where leadid = :trigger.new[i].Whoid];
	          system.debug('### Seminar CM : ' + seminar_cm);
	          list<CampaignMember> cm_update_list = new list<CampaignMember>();
	          set<ID> all_campaigns = new set<ID>{};
	          for(CampaignMember cm : seminar_cm) {
	            //build a set of campaignids and then query on them all
	            all_campaigns.add(cm.campaignid);	
	          }
	          system.debug('### All Campaigns : ' + all_campaigns);
	          //build a map of the campaigns with the campaign type        	
	          map<id,string> campaign_types = new map<id,string>{};
	          list<Campaign> campaign_lookup = [select id,type from Campaign where id in :all_campaigns];
	          for(Campaign c : campaign_lookup) {
	          	campaign_types.put(c.id,c.type);          	
	          }  
	          system.debug('### Campaign Types : ' + campaign_types);
	          for(CampaignMember cm : seminar_cm) {
	          	system.debug('### Last Check : ' + campaign_types.get(cm.campaignid) + ' ' + trigger.new[i].Outcome__c );
	          	//if we have a seminar type campaign,  update the campaign members status based on the outcome
	          	if(campaign_types.get(cm.campaignid)=='Off-Site Seminar' || campaign_types.get(cm.campaignid)=='Retirement Center Seminar') {
	          	  //mark this one for update
	          	  if(trigger.new[i].Outcome__c=='Seminar Confirmed') {
	          	  	cm.Status = 'Confirmed';
	          	  	cm_update_list.add(cm); 
	          	  }
	          	}
	          }
	          system.debug('### Update List : ' + cm_update_list);
	          if(!cm_update_list.isEmpty()) {
	  	        update cm_update_list;
	  	      }
	        }
	      } //--end if WHOID
	    } //---end for loop
	
	    if (Leads.size() > 0) {
	  	  system.debug('### welcome pkt updated size=('+Leads.size()+') '+Leads);
	      update Leads;
	    }
	    
	    if(sched_updates.size()>0) {
	      //we have some leads that need to be updated with a non-sched status - need to check to see if any of them have a consult on teh calendar
	      for(Consult_Inventory__c ci : [select scheduled_lead__c from consult_inventory__c where scheduled_lead__c in :nonsched_leads and apt_date__c >= today]) {
	      	consult_leads.add(ci.scheduled_lead__c);
	      }
	      List<Lead> update_list = new List<Lead>();
	      for(Lead l : sched_updates) {
	      	if(!consult_leads.contains(l.id))
	      	  update_list.add(l);
	      }
	      if(update_list.size()>0) {
	      	Util_TriggerContext.setalreadyProcessed();
	        update update_list;
	      }
	    }
	  }//--end after
  }
} //---end trigger