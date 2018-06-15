public class Lead_Status_Update {
  @future(callout=true)
  public static void update_lead_status() {
  	Set<Id> all_leads = new Set<ID> ();
    List<Task> insert_tasks = new List<Task>();
    Campaign c = [select id,name from campaign where type = 'No Show-Cancellation Outbound' and status = 'In Progress' and startdate <= today and name like 'N%' order by startdate desc limit 1];
    System.debug('No Show Campaign Id : ' + c.id + ' Name : ' + c.name);
  	List<Consult_Inventory__c> no_shows = [select no_show_contacted__c,no_show_contacted_notes__c,id,consult_show_status__c,scheduled_lead__c from consult_inventory__c where apt_date__c = today and consult_room__r.room_type__c != 'Practice' and status_exported__c = false and consult_show_status__c = 'No Show' and scheduled_lead__c != null];
  	for(Consult_Inventory__c ci : no_shows) {
  		all_leads.add(ci.scheduled_lead__c);        		  		
  		ci.status_exported__c = true;
  		if(ci.No_Show_Contacted__c) { 
  			Task t = new Task(Description = ci.No_Show_Contacted_Notes__C,WhoId = ci.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'No Show Contacted', Type = 'Call', Activity_Type__c = 'Outbound Call', Outcome__c = 'No Show Contacted', Call_No_Answer__c = false, Status = 'Completed');
  			insert_tasks.add(t);
  		}
  	}
  	try {
  	  update no_shows;
  	  if(insert_tasks.size()>0)
  	    insert insert_tasks;
  	}
  	catch(Exception e) {
  		
  	}
  	Map<Id,Integer> cm_count = new Map<Id,Integer>();
  	for(AggregateResult ar : [select leadid,count(id) num_records from campaignmember where campaignid = :c.id and leadid in :all_leads group by leadid]) {
  		System.debug('No Show Membership Count : ' + ar);
  		cm_count.put((Id)ar.get('leadid'),(Integer)ar.get('num_records'));
  	}

  	List<CampaignMember> no_show_cm = new List<CampaignMember>();
  	//work through all of the leads and change the status to - No Show
  	List<Lead> no_show_list = [select id,status,convertedcontactid from lead where id in :all_leads and convertedcontactid = null];
  	for(Lead l : no_show_list) {
  		System.debug('CM Count : ' + cm_count.get(l.id));
  		if(cm_count.get(l.id)==null) {
  			CampaignMember cm = new CampaignMember(campaignId = c.id, leadid = l.id);	  		  	  	
		    no_show_cm.add(cm);
  		}
  		l.status = 'No Show';
  	}
  	try {
  	  update no_show_list;
  	  if(no_show_cm.size()>0) {
  	  	System.debug('Inserting : ' + no_show_cm);
  	    insert no_show_cm;
  	  }
  	}
  	catch (Exception e) {
  		
  	}
  	
  	all_leads = new Set<ID> ();
  	List<Consult_Inventory__c> consult_completed = [select id,consult_show_status__c,scheduled_lead__c from consult_inventory__c where apt_date__c = today and consult_room__r.room_type__c != 'Practice' and status_exported__c = false and consult_show_status__c = 'Consult Completed' and scheduled_lead__c != null];
  	for(Consult_Inventory__c ci : consult_completed) {
  		all_leads.add(ci.scheduled_lead__c);
  		ci.status_exported__c = true;
  	}
  	try {
  	  update consult_completed;
  	}
  	catch(Exception e) {
  		
  	}
  	//work through all of the leads and change the status to - Completed
  	List<Lead> completed_list = [select id,status,convertedcontactid from lead where id in :all_leads and convertedcontactid = null];
  	for(Lead l : completed_list) {
  		l.status = 'Consult Completed';
  	}
  	try {
  	  update completed_list;
  	}
  	catch (Exception e) {
  		
  	}
  	
  	//Identify all walk-outs for update
    all_leads = new Set<ID> ();
    List<Task> walkout_tasks = new List<Task>();
  	List<Consult_Inventory__c> walk_outs = [select id,consult_show_status__c,scheduled_lead__c,walk_out_reason__c,arrival_time__c,left_time__c from consult_inventory__c where apt_date__c = today and consult_room__r.room_type__c != 'Practice' and status_exported__c = false and consult_show_status__c = 'Patient Left' and left_time__c != null and scheduled_lead__c != null];
  	for(Consult_Inventory__c ci : walk_outs) {
  		all_leads.add(ci.scheduled_lead__c);
  		ci.status_exported__c = true;  	  
  	  Decimal wait_minutes = ((ci.left_time__c.getTime() - ci.arrival_time__c.getTime())/ (1000.0*60.0)); 
  	  String task_description = 'Walk Out - Patient Walked Out after ' + wait_minutes.round() + ' minutes - ' + ci.Walk_Out_Reason__c;  	    	    	 
  	  Task t = new Task(Description = ci.Walk_Out_Reason__c,WhoId = ci.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = task_description, Type = 'Consult Status', Activity_Type__c = 'Walk Out', Outcome__c = 'Walk Out', Call_No_Answer__c = true, Status = 'Completed');
  	  walkout_tasks.add(t);
  	}
  	try {
  	  update walk_outs;
  	}
  	catch(Exception e) {
  		
  	}
  	
  	//work through all of the leads and change the status to - Patient Left
  	List<Lead> walkout_list = [select id,status,convertedcontactid from lead where id in :all_leads and convertedcontactid = null];  	
  	for(Lead l : walkout_list) {
  		l.status = 'Patient Left';
  		l.Call_Result__c = 'Not Scheduled';
  	}
  	try {
  	  update walkout_list;
  	  Util_TriggerContext.setalreadyProcessed();
  	  if(walkout_tasks.size()>0)
  	    insert walkout_tasks;  
  	}
  	catch (Exception e) {
  		
  	}
  }
  
	static testMethod void LeadStatus() {
		Profile p = [select id from Profile where name = 'System Administrator'];		
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
		
		Market__c m = [select id from Market__c limit 1];
		Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
	  insert test_center; 
	  
	  Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
		insert test_room;
		
		Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com');
	      //Refused_to_give_email__c=true
	  insert test_lead;
		
		Consult_Inventory__c[] test_ci = new Consult_Inventory__c[] {new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = system.today(),Start_Hour__c = '8',Start_Minute__c = '30',
		  End_Hour__c = '9', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'blue', dow_int__c = 1, scheduled_lead__c = test_lead.id, consult_show_status__c = 'Patient Left', arrival_time__c = system.now(),left_time__c = system.now().addminutes(20)),
		  new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = system.today(),Start_Hour__c = '9',Start_Minute__c = '30',
		  End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'blue', dow_int__c = 1, scheduled_lead__c = test_lead.id, consult_show_status__c = 'Consult Completed'),
		  new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = system.today(),Start_Hour__c = '10',Start_Minute__c = '30',
		  End_Hour__c = '11', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'blue', dow_int__c = 1, scheduled_lead__c = test_lead.id, consult_show_status__c = 'No Show',no_show_contacted__c = true, no_show_contacted_notes__c = 'no show test notes')};
		insert test_ci;
		
		Campaign test_campaign = new Campaign(name = 'No-Show Campaign',type = 'No Show-Cancellation Outbound',status = 'In Progress',startdate= system.today());
		insert test_campaign;
		
		Lead_Status_Update.update_lead_status();
	}
}