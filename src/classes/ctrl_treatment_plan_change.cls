public with sharing class ctrl_treatment_plan_change {
  public Treatment_Change_Request__c change_request {get; set;}
  public String warning_msg {get; set;}
  public Boolean display_save {get; set;}
  private ID opp_id;
  private ID account_id; 
  private ID center_id;
  public Treatment_Plan__c tp {get; set;}
  
  
  public ctrl_treatment_plan_change() {         
    warning_msg = '';
    display_save = true;
  }
  
  public void new_change_request() {
        if(apexpages.currentpage().getparameters().get('tpid')!=null) {
          try {
            tp = [Select t.initial_cost__c, t.Treatment_Option__c,  t.Opportunity__c, t.opportunity__r.accountid, t.opportunity__r.account.center__c, t.Id, t.Final_Cost__c, t.Consult_Treatment_Plan__c From Treatment_Plan__c t where id = : apexpages.currentpage().getparameters().get('tpid')];
            change_request = new Treatment_Change_Request__c(Parent_Treatment_plan__c = tp.id, Current_Treatment_option__c = tp.treatment_option__c, current_initial_cost__c = tp.initial_cost__c, current_treatment_amount__c = tp.final_cost__c,
              new_initial_cost__c = tp.initial_cost__c, new_treatment_option__c = tp.treatment_option__c, new_treatment_amount__c = tp.final_cost__c, current_consult_treatment_plan__c = tp.consult_treatment_plan__c, new_consult_treatment_plan__c = tp.consult_treatment_plan__c);
            opp_id = tp.opportunity__c;
            account_id = tp.opportunity__r.accountid;
            center_id = tp.opportunity__r.account.center__c;
          } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to create a new change request.  Please contact IT'));
            ApexPages.addMessages(e);
          }
        }
        else 
          //throw an error - we need to match back to an initial treatment plan,  or we have nothing to change
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to create a new change request.  Please contact IT'));
  }
  
  public List<Treatment_Plan__c> getconsult_plans() {
        try {
          //grab a list of the plans offered to the consult - with details
          List<Treatment_Plan__c> consult_options = [Select t.total_cost__c, t.initial_cost__c, t.Treatment_Option__c, t.treatment_option__r.name, t.Recommended__c, t.Opportunity__c, t.Final_Cost__c, t.CreatedDate, t.CreatedById, t.ClearChoice_Doctor__c, t.clearchoice_doctor__r.name From Treatment_Plan__c t where account__c = :account_id];
          return consult_options;
        }
        catch (Exception e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There do not appear to be any valid treatment plans tied to the consult record.  Please add one,  in order to continue'));
          ApexPages.addMessages(e);
          return null;
        }
  }
  
  //grab doctor list
  public List<SelectOption> getdoctor_list() {
        //figure out the center and grab a list of doctors for it
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','No Upsell Doctor'));
        for(ClearChoice_Doctor__c cd : [Select c.id,c.Name From ClearChoice_Doctor__c c where c.center_information__c = :center_id]) {
          options.add(new SelectOption(cd.id,cd.name));  
        }
        return options;
  }
  
  //save method - run error checking and warnings here
  public void save_changes() {
        warning_msg ='';
        //error checking
        Boolean has_errors = false;
        if(change_request.reason_for_change__c==null) {
          has_errors = true;
          warning_msg += '<span style="color:red;">Error - <span style="color:black;">You must select a reason for the change</span><br />';      
        }
        else if(change_request.reason_for_change__c=='Other - fill in notes'  && change_request.reason_notes__c==null) {
          has_errors = true;
          warning_msg += '<span style="color:red;">Error - <span style="color:black;">You must enter notes when selecting other for the reason</span><br />';
        }
        if(change_request.treatment_stage__c==null) {
          has_errors = true;
          warning_msg += '<span style="color:red;">Error - <span style="color:black;">You must select the treatment stage</span><br />';
        }
    if(change_request.new_treatment_amount__c==null) {
      has_errors = true;
          warning_msg += '<span style="color:red;">Error - <span style="color:black;">You must enter a value for the treatment amount</span><br />';
    }
    else if(change_request.new_treatment_amount__c<0) {
      has_errors = true;
          warning_msg += '<span style="color:red;">Error - <span style="color:black;">You must enter a positive value for the treatment amount</span><br />';
    } 
    if(change_request.new_treatment_option__c==null) {
      has_errors = true;
          warning_msg += '<span style="color:red;">Error - <span style="color:black;">You must select a treatment option</span><br />';
    }
        //if no errors - save the change request and update the treatment plan
    if(!has_errors) {
      try {
            tp.treatment_option__c = change_request.new_treatment_option__c;
            tp.final_cost__c = change_request.new_treatment_amount__c;
            tp.initial_cost__c = change_request.new_initial_cost__c;
            tp.consult_treatment_plan__c = change_request.new_consult_treatment_plan__c;
            update tp;                      
            insert change_request;
            //update the opportunity record now
            Treatment_Option__c to = [select old_treatment_map__c from treatment_option__c where id = :tp.treatment_option__c];
            Opportunity o = [select preliminary_treatment_plan__c,treatment_amount__c from Opportunity where id = :opp_id];            
            o.preliminary_treatment_plan__c = to.old_treatment_map__c;
  	        o.treatment_amount__c = (tp.final_cost__c + tp.initial_cost__c);
  	        update o;
            
            display_save = false;
            warning_msg = '<span style="font-weight:bold;color:blue;">Success - <span style="color:black;">You changes have been saved.  Please close this window and refresh the opportunity record to see your changes</span></span>';
      } catch(Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error was encountered while trying to save changes'));
            ApexPages.addMessages(e);
      }
        }
  }   
  
  //switch to a consult plan - adjust treatment option,  amount,  and initial treatment plan values
  public void switch_treatment_plan() {
    try {
          //grab the id of the plan selected - grab the treatment plan record,  then make a copy of it tied to the opportunity record.
          Treatment_Plan__c consult_plan = [Select t.treatment_option__r.old_treatment_map__c,t.id,t.Treatment_Option__c, t.Recommended__c, t.Final_Cost__c, t.ClearChoice_Doctor__c, t.initial_cost__c From Treatment_Plan__c t where id = :Apexpages.currentPage().getParameters().get('cpid')];
          //add initial plan field once in table
          change_request.new_treatment_option__c = consult_plan.treatment_option__c;
          change_request.new_treatment_amount__c = consult_plan.final_cost__c;
          change_request.new_initial_cost__c = consult_plan.initial_cost__c;
          change_request.new_consult_treatment_plan__c = consult_plan.id;
          
          Opportunity o = [select preliminary_treatment_plan__c,treatment_amount__c from Opportunity where id = :opp_id];
          o.preliminary_treatment_plan__c = consult_plan.treatment_option__r.old_treatment_map__c;
  	      o.treatment_amount__c = (consult_plan.final_cost__c + consult_plan.initial_cost__c);
  	      update o;
        }  catch (Exception e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occured while trying to switch the treatment plan.'));
          ApexPages.addMessages(e);
        }
  }
  
}