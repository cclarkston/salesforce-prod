public with sharing class ctrl_snap_taskext {
  public Account ac {get; set;}
  Task t;
  ApexPages.StandardController controller; 
  
  public ctrl_snap_taskext(ApexPages.StandardController con) {
  	this.t = (Task)con.getRecord();
  	if(task.AccountId!=null)
  	  try { 
  	    ac = [select what_did_you_do_with_your_image__c, other_use_of_the_image__c, if_you_shared_it_with_someone_who__c,
  	      other_who_did_you_share_your_image_with__c, when_do_you_plan_to_move_forward__c, why_are_they_never_moving_forward__c from Account where id = :t.AccountId];
  	  }
  	  catch (Exception e) {
  	  	ApexPages.addMessages(e);
  	  	ac = null;
  	  }
  	this.controller = con;  	
  }
  
  public Boolean getdisplay_snap() {  	
  	Integer I = [select count() from Profile where id= :userinfo.getProfileId() and name in ('System Administrator','PEC - Snap')];
  	if(i>0) 
  	  if(ac!=null)
  	    return true;
  	  else
  	    return false;
  	else
  	  return false;
  }
  
  public Pagereference save() {
  	System.debug('Extension Save Method Called!');
  	try {
  		if(ac!=null)
  		  update ac;
  		return controller.save();
  	}
  	catch (Exception e) {
  		 ApexPages.addMessages(e);  
  		 return null;  
  	}
  }
  
}