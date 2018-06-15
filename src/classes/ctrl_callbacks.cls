public with sharing class ctrl_callbacks {
  Set<ID> all_consults;
  patient_callback[] current_queue {get;set;}
  patient_callback[] return_list {get;set;}
  ID task_center;
  public boolean is_traveller {get;set;}
  /*patient_callback[] thirty_day_three {get;set;}
  patient_callback[] sixty_day_one {get;set;}
  patient_callback[] sixty_day_two {get;set;}
  patient_callback[] sixty_day_three {get;set;}
  patient_callback[] cancelled_one {get;set;}
  patient_callback[] cancelled_two {get;set;}*/
  
  
  public class patient_callback implements Comparable {
  	public Account consult_record {get; set;}
  	public Integer last_contact_age;
  	public Task last_task {get; set;}
  	public String queue_source {get; set;}
  	
  	public patient_callback(Account a,Task t,String consult_source) {
  	  this.consult_record = a;
  	  this.queue_source = consult_source;
  	  if(t!=null) {
  	    this.last_task = t;
  	    if(t.activitydate!=null) {
  	      this.last_contact_age = System.today().daysBetween(t.activitydate);
  	    }
  	    else {
  	      this.last_contact_age = System.today().daysBetween(Date.newinstance(t.createddate.year(),t.createddate.month(),t.createddate.day()));
  	    }
  	  }
  	  else 
  	    this.last_contact_age = 99999;
  	}
  	
  	public String getTaskDate() {
  	  String return_text = '';
  	  if(last_task==null)
  	    return_text = 'No Sales Tasks';
  	  else {
  	  	Datetime ftime = DateTime.newInstance(last_task.sort_date__c.year(),last_task.sort_date__c.month(),last_task.sort_date__c.day());
  	  	return_text = ftime.format('M/dd/yyyy');
  	  }
  	  return return_text;
  	}
  	
  	public String getTaskType() {
  	  return last_task==null ? '':last_task.activity_type__c;
  	}
  	
  	public String getTaskSubject() {
  	  return last_task==null ? '':last_task.subject;
  	}
  	
  	public String getTaskDescription() {
  	  return last_task==null ? '':last_task.description;
  	}
  	
  	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      patient_callback compareTopatient = (patient_callback)compareTo;
        
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (last_contact_age > compareTopatient.last_contact_age) {
        // Set return value to a positive value.
        returnValue = -1;
      } else if (last_contact_age < compareTopatient.last_contact_age) {
        // Set return value to a negative value.
        returnValue = 1;
      }        
      return returnValue;       
    }
  	
  }
  
  public ctrl_callbacks() {
  	is_traveller = false;
  	User u = [select id,name,center_pec__c from User where id = :Userinfo.getuserid()];
  	Center_Information__c ci = [select id from Center_Information__c where name = 'Unknown'];
  	if(u.center_pec__c!=null) {
  	  task_center = u.center_pec__c;
  	  if(u.center_pec__c == ci.id)
  	    is_traveller = true;
  	}
  	else {
  	  try {
  	  	is_traveller = true;
  	    task_center = ci.id;
  	  }
  	  catch (Exception e) {
  	  	task_center = '';
  	  }
  	}
  	refresh_return_list();
  } 
  
  public void process_account_results(List<Account> account_results,String queue_name) {
  	current_queue = new patient_callback[] {};
  	patient_callback pc;
  	for(Account a : account_results) {
      boolean add_contact = false;
      //check to see if the account has a scheduled task.  If so,  ignore it.
      if(a.tasks.size()==0) {
      	add_contact = true;
      }
      else if(a.tasks[0].activitydate==null) {
      	add_contact = true;
      }
      else {
      	if(a.tasks[0].activitydate < System.now()) 
      	  add_contact = true;
      }
      
      if(add_contact) {
        all_consults.add(a.id);
        if(a.tasks.size()==0)
          pc = new patient_callback(a,null,queue_name);
        else
      	  pc = new patient_callback(a,a.tasks[0],queue_name);
      	current_queue.add(pc);
      }
    }
    //see if we had any valid hits
    if(current_queue.size()>0) {
      current_queue.sort();
      Integer current_hits = return_list.size();
      for(patient_callback pc1 : current_queue) {
      	if(current_hits<10) {
      	  return_list.add(pc1);
      	  current_hits++;
      	}
      }
    }
  }
  
  public void refresh_return_list() {
  	all_consults = new Set<ID>();
    return_list = new patient_callback[] {};
    List<Account> account_results;
  	//pull the list of people in the 30 Day pipleline who have been there less than 90 days
  	//append to the end of query - and center__c = :task_center  and (owner.id = :userinfo.getuserid() or owner.isactive = false)
  	if(is_traveller)
      account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c <= 90 and owner.id = :userinfo.getuserid()];
    else
      account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c <= 90 and center__c = :task_center  and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
    process_account_results(account_results,'30 Day Pipeline (<=90 Days)');
    System.debug('All Consults ' + all_consults.size() + ' 30 Day Pipeline (<=90 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 60 Day pipleline who have been there less than 90 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c <= 90 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c <= 90 and id not in :all_consults and center__c = :task_center  and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'60 Day Pipeline (<=90 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 60 Day Pipeline (<=90 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 30 Day pipleline who have been here 91 - 180 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c > 90 and pipeline_age__c <= 180 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c > 90 and pipeline_age__c <= 180 and id not in :all_consults and center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'30 Day Pipeline (91 - 180 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 30 Day Pipeline (91 - 180 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 60 Day pipleline who have been here 91 - 180 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c > 90 and pipeline_age__c <= 180 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c > 90 and pipeline_age__c <= 180 and id not in :all_consults and center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'60 Day Pipeline (91 - 180 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 60 Day Pipeline (91 - 180 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull a list of cancelled opportunities
      Datetime sdate = System.now().adddays(-90);
      Set<ID> cancelled_account_list = new Set<ID>();
      //append to the end of query - a
      List<Opportunity> cancelled_starts;
      if(is_traveller)
        cancelled_starts = [select id from opportunity where cancel_date__c >= :sdate and accountid not in : all_consults and owner.id = :userinfo.getuserid()];
      else
        cancelled_starts = [select id from opportunity where cancel_date__c >= :sdate and accountid not in : all_consults and account.center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
      for(Opportunity o : cancelled_starts) {
        cancelled_account_list.add(o.id);
      }
      account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where id in :cancelled_account_list];
      process_account_results(account_results,'PE Cancelled (<=90 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' PE Cancelled (<=90 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 60 Day pipleline who have been here 91 - 180 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c > 180 and pipeline_age__c <= 270 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c > 180 and pipeline_age__c <= 270 and id not in :all_consults and center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'30 Day Pipeline (181 - 270 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 30 Day Pipeline (181 - 270 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 60 Day pipleline who have been here 91 - 180 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c > 180 and pipeline_age__c <= 270 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c > 180 and pipeline_age__c <= 270 and id not in :all_consults and center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'60 Day Pipeline (181 - 270 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 60 Day Pipeline (181 - 270 Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 60 Day pipleline who have been here 91 - 180 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c > 270 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '30 Day Pipeline' and pipeline_age__c > 270 and id not in :all_consults and center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'30 Day Pipeline (271+ Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 30 Day Pipeline (271+ Days)');
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull the list of people in the 60 Day pipleline who have been here 91 - 180 days
      if(is_traveller)
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c > 270 and id not in :all_consults and owner.id = :userinfo.getuserid()];
	  else
	    account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where consult_result__c = '60 Day Pipeline' and pipeline_age__c > 270 and id not in :all_consults and center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
	  process_account_results(account_results,'60 Day Pipeline (271+ Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' 60 Day Pipeline (271+ Days)');
    
    //grab the next queue,  only if we don't have 10 callback options yet
    if(return_list.size()<10) {
      //pull a list of cancelled opportunities
      Datetime sdate = System.now().adddays(-90);
      Set<ID> cancelled_account_list = new Set<ID>();
      //append to the end of query - and account.center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)
      List<Opportunity> cancelled_starts;
      if(is_traveller)
        cancelled_starts = [select id from opportunity where cancel_date__c < :sdate and accountid not in : all_consults and owner.id = :userinfo.getuserid()];
      else
        cancelled_starts = [select id from opportunity where cancel_date__c < :sdate and accountid not in : all_consults and account.center__c = :task_center and (owner.id = :userinfo.getuserid() or owner.isactive = false)];
      for(Opportunity o : cancelled_starts) {
        cancelled_account_list.add(o.id);
      }
      account_results = [select id,name,consult_result__c,General_Notes__c,owner.name,center__r.name,(select createddate,activity_type__c,calltype,activitydate,subject,description,sort_date__c from tasks where activity_type__c in ('Sales Call','Outbound Call','Inbound Call') order by sort_date__c desc limit 1) from account where id in :cancelled_account_list];
      process_account_results(account_results,'PE Cancelled (<=90 Days)');
    }
    System.debug('All Consults ' + all_consults.size() + ' PE Cancelled (91+ Days)');
  }
  
  public patient_callback[] getreturn_list() {
  	return return_list;
  }
  
}