public with sharing class opp_treatmentplan {
  private Opportunity o;  
  ApexPages.Standardcontroller con;
  public Treatment_Plan__c tp {get;set;}
  public Boolean has_treatment {get;set;}
  
  
  public opp_treatmentplan(ApexPages.StandardController stdController) {
  	this.o = (Opportunity)stdController.getRecord();
    con = stdController;
    try {
      tp = [Select t.timeline__c,t.Treatment_Option__c, t.treatment_option__r.name, t.Recommended__c, t.Opportunity__c, t.total_cost__c, t.initial_cost__c, t.Final_Cost__c, t.CreatedDate, t.CreatedById, t.ClearChoice_Doctor__c,t.id,t.bleaching_tray__c,t.nightguard__c,t.bone_grafting__c,t.immediate_load__c,t.clearchoice_doctor__r.name  From Treatment_Plan__c t where opportunity__c = :o.id limit 1];
      has_treatment = true;
    }
    catch (Exception e) {
      has_treatment = false;
    }
  }
  
  public List<Treatment_Plan__c> getconsult_plans() {
  	try {
  	  //grab a list of the plans offered to the consult - with details
  	  List<Treatment_Plan__c> consult_options = [Select t.timeline__c,t.Treatment_Option__c, t.treatment_option__r.name, t.Recommended__c, t.initial_cost__c, t.Opportunity__c, t.total_cost__c, t.Final_Cost__c, t.CreatedDate, t.CreatedById, t.ClearChoice_Doctor__c, t.clearchoice_doctor__r.name From Treatment_Plan__c t where account__c = :o.accountid];
  	  return consult_options;
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There do not appear to be any valid treatment plans tied to the consult record.  Please add one,  in order to continue'));
  	  ApexPages.addMessages(e);
  	  return null;
  	}
  }
  
  public void select_consult_plan() {
  	try {
  	  //grab the id of the plan selected - grab the treatment plan record,  then make a copy of it tied to the opportunity record.
  	  Treatment_Plan__c consult_plan = [Select t.initial_cost__c, t.timeline__c,t.Treatment_Option__c, t.Recommended__c, t.Final_Cost__c, t.ClearChoice_Doctor__c,t.bleaching_tray__c,t.nightguard__c,t.bone_grafting__c,t.immediate_load__c From Treatment_Plan__c t where id = :Apexpages.currentPage().getParameters().get('cpid')];
  	  //add initial plan field once in table
  	  tp = new Treatment_Plan__c(Opportunity__c = o.id, recommended__c = consult_plan.recommended__c, treatment_option__c = consult_plan.treatment_option__c, 
  	    final_cost__c = consult_plan.final_cost__c, initial_cost__c = consult_plan.initial_cost__c,
  	    clearchoice_doctor__c = consult_plan.clearchoice_doctor__c, consult_treatment_plan__c = consult_plan.id, timeline__c = consult_plan.timeline__c,
  	    bleaching_tray__c = consult_plan.bleaching_tray__c,nightguard__c = consult_plan.nightguard__c, bone_grafting__c = consult_plan.bone_grafting__c,
  	    immediate_load__c = consult_plan.immediate_load__c);
  	  insert tp;
  	  tp = [Select t.initial_cost__c, t.Treatment_Option__c, t.treatment_option__r.old_treatment_map__c, t.treatment_option__r.name, t.Recommended__c, t.Opportunity__c, t.Final_Cost__c, t.CreatedDate, t.CreatedById, t.ClearChoice_Doctor__c,t.bleaching_tray__c,t.nightguard__c,t.bone_grafting__c,t.immediate_load__c,t.clearchoice_doctor__r.name,t.timeline__c From Treatment_Plan__c t where id = :tp.id];
  	  has_treatment = true;
  	  o.preliminary_treatment_plan__c = tp.treatment_option__r.old_treatment_map__c;
  	  o.treatment_amount__c = tp.initial_cost__c;
  	  update o;
  	}  catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occured while trying to select the treatment plan.'));
  	  ApexPages.addMessages(e);
  	}
  }
  
  public String getchange_treatment_plan_url() {
  	String page_url = '/apex/treatment_plan_change_request?tpid=' + tp.id;  	
  	return page_url;
  }
  
  public PageReference open_change_plan_page() {  	
    Pagereference pr = Page.treatment_plan_change_request;
    pr.getParameters().put('tpid',tp.id);     
    pr.setredirect(true);
    return pr;
  }
}