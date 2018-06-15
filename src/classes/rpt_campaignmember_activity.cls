public without sharing class rpt_campaignmember_activity {
	public String error_messages {get; set;}
	public String file_header {get; set;}
	public String file_name {get; set;}

  public rpt_campaignmember_activity() {
    Date dtoday = date.today();        	  
    file_name = 'cc_dashboard_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  }

  public class Member_Activity {
  	public CampaignMember cm {get; set;}
  	public List<Task> all_tasks {get; set;}
  	
  	public Member_Activity(CampaignMember my_cm) {
  		this.cm = my_cm;
  		this.all_tasks = new List<Task> ();
  	}
  	
  	public Integer gettask_size() {
  		return all_tasks.size();
  	}
  	
  	public Task getlast_task() {
  		Task return_task = null;
  		for(Task t : all_tasks) {
  			if(return_task==null)
  			  return_task = t;
  			else if(t.createddate > return_task.createddate)
  			  return_task = t;  			
  		}
  		return return_task;
  	}
  }
  
  public Member_Activity[] getall_member_activity() {
  	List<Member_Activity> return_list = new List<Member_Activity>();
    Map<String,Member_Activity> all_members = new Map<String,Member_Activity>	();
    Set<Id> all_leads = new Set<Id> ();
    Set<Id> all_contacts = new Set<Id> ();
    
    //grab all campaign members tied to campaign X and generate 
    for(CampaignMember cm : [select leadid,contactid,status,lead.name,lead.phone,contact.name,contact.phone,contact.mobilephone,contact.otherphone,lead.mobilephone,lead.work_phone__c,campaign.name from campaignmember 
   	where campaign.name in ('MIA--ClearChoice Outbound Miami Seminar-10-2012','SJO--ClearChoice Outbound San Jose/Walnut Creek Seminar-10-2012')]) {
      Member_Activity ma = new Member_Activity(cm);
      return_list.add(ma);
      if(cm.leadid!=null) {
        all_members.put(cm.leadid,ma);
        all_leads.add(cm.leadid);
      }
      if(cm.contactid!=null) {
        all_members.put(cm.contactid,ma);
        all_contacts.add(cm.contactid);
      }    	
    }
    
    //grab all activities tied to the lead records and add to the member activity
    for(Lead l : [Select (Select Subject, Status, CreatedDate, CreatedById, CallType, Call_No_Answer__c,  Activity_Type__c, 
      Attempt__c, Outcome__c, Activity_Hour__c From Tasks where activity_type__c = 'Outbound Call') From Lead l where l.id in :all_leads]) {
      if(l.tasks.size()>0) 
        all_members.get(l.id).all_tasks.addall(l.tasks);  	
    }
    
    //grab all activities tied to the contact records
    for(Contact c : [Select (Select Subject, Status, CreatedDate, CreatedById, CallType, Call_No_Answer__c,  Activity_Type__c, 
      Attempt__c, Outcome__c, Activity_Hour__c From Tasks where activity_type__c = 'Outbound Call') From Contact c where c.id in :all_contacts]) {
      if(c.tasks.size()>0)
        all_members.get(c.id).all_tasks.addall(c.tasks);
    }
    
    return return_list;
  }
}