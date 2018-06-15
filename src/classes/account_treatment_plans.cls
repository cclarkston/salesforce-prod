/*
TO-DOs - Once we decide how to handle it,  need to calculate the center and national averages to pass through for the charting script

*/
global without sharing class account_treatment_plans {
  public Account a {get; set;}  
  public Treatment_Plan__c new_plan {get; set;}
  public String upper_option {get;set;}
  public String lower_option {get;set;}
  public Center_Information__c center {get; set;}
        
  public account_treatment_plans() {
        //System.debug('AID :' + apexpages.currentpage().getparameters().get('aid'));
        Integer cnt = 0;
        try {
          cnt = [select count() from Account where id = :apexpages.currentpage().getparameters().get('aid')];
          a = [select owner.name,owner.phone,id,center__c,center__r.sales_market__c,preliminary_treatment_plan__c,preliminary_treatment_fee_quoted__c from Account where id = :apexpages.currentpage().getparameters().get('aid')];
          center = [select legal_name__c,name,Zip_Code__c, Street_2__c, Street_1__c, State__c, City__c,call_center_marketing__c,local_front_desk__c from Center_information__c where id = :a.center__c];
        } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the consult record.' + e));
        }
        new_plan = new Treatment_Plan__c(account__c = a.id,final_cost__c = 0.00,initial_cost__c = 0.00, Include_on_Handout__c = true);          
        upper_option = 'None';
        lower_option = 'None';          
  }
  
  public string getserver_name(){
    return ApexPages.currentPage().getHeaders().get('Host');
  }
  
  WebService static void record_printout(String aid) {
  	Pagereference pr = Page.treatment_handout;
  	//Pagereference pr = Page.treatment_test;
    pr.getParameters().put('aid',aid);
    String file_name = 'Treatment Handout ' + system.now().format('M/dd/yyyy') + '.html';
    //String file_name = 'Treatment Handout ' + system.now().format('M/dd/yyyy') + '.pdf';
    Blob abody;
    if(Test.isRunningTest())
      abody = Blob.valueof('<html><body>Test Handout</body></html>');
    else    
      abody = pr.getContent();
    //Blob abody = pr.getContentaspdf();
    String ctype = 'text/html';
    // = 'text/html'
    try { 
      Attachment att = new Attachment(Name = file_name, parentid = aid, body = abody, isprivate = false, contenttype = ctype);
      insert att;
    } catch (Exception e) {
    	
    }
  }
  
  public string getaccount_name() {
  	return [select name from account where id = :a.id].name;
  }
  
  public class treatment_object {
        public Treatment_Plan__c tp {get;set;}
        
        public treatment_object(Treatment_Plan__c my_plan) {
          this.tp = my_plan;
        }
        
        public List<Attachment> getfile_list() {
           return [select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body from Attachment a where a.parentid = :tp.treatment_option__c order by createddate];
        }
  }
  
  public String getcurrent_date() {
        return system.now().format('M/dd/yyyy');
  }
  
  public PageReference return_to_consult() {
        Pagereference pr = new PageReference('/' + a.id);       
    pr.setredirect(true);
    return pr;
  }
  
  //select list for tag options
  public List<Selectoption> gettag_options() {
        List<Selectoption> tag_reasons = new List<Selectoption>();          
        for(Schema.PicklistEntry Value : Treatment_Option__c.lower_tag__c.getDescribe().getPicklistValues() ) {
          tag_reasons.add(new Selectoption(value.getValue(),value.getLabel()));
        }
        return tag_reasons;
  }
  
  //public String getTest_id() {
    //    return apexpages.currentpage().getparameters().get('aid');
  //}
  
  //pull list of doctors
  public List<SelectOption> getDoctorList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Select Doctor'));
    //pull a list of doctors based on the market
    List<ClearChoice_Doctor__c> doc_list = [select id,name from ClearChoice_Doctor__c where center_information__r.sales_market__c = :a.center__r.sales_market__c and active__c = true];
    for(ClearChoice_Doctor__c cd : doc_list) {
      options.add(new SelectOption(cd.id,cd.name));
    }  
        return options;
  }
        
  //method to search treatment options
  public List<Treatment_Option__c> gettreatment_matches() {
        if(upper_option!='None' && lower_option !='None')        
      return [select id,name from Treatment_Option__c where name!=null and upper_tag__c = :upper_option and lower_tag__c = :lower_option];
    else if(upper_option!='None')
      return [select id,name from Treatment_Option__c where name!=null and upper_tag__c = :upper_option];
    else if(lower_option!='None')
      return [select id,name from Treatment_Option__c where name!=null and lower_tag__c = :lower_option];
    else
      return [select id,name from Treatment_Option__c where name!=null];
  }
  
  public void change_treatment_option() {
        try {
          Treatment_Option__c to = [select id,name,timeline__c from Treatment_Option__c where id = :apexpages.currentpage().getparameters().get('tid')];        
          new_plan.treatment_option__c = to.id;
          new_plan.timeline__c = to.timeline__c;
          //set default timeline value
        } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to select a treatment option.' + e));
        }
  } 
  
  public Integer gettreatment_plan_size() {
  	return [select count() from Treatment_Plan__c where account__c = :a.id and include_on_handout__c = true];
  }
  
  public string gettemplate_name() {
  	Integer tsize = gettreatment_plan_size();
  	if(tsize==1)
  	  return 'template-single';
  	else if(tsize==2)
  	  return 'template-double';
  	else
  	  return 'template-index';
  }
  
  //method to return current treatment plans for the handout (custom object return)
  public List<treatment_object> getcurrent_treatments() {
        List<Treatment_object> tplans = new List<Treatment_Object>();
        for(Treatment_Plan__c tp :  [select handout_notes__c,id,account__c,ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c,initial_cost__c,Final_Cost__c,total_cost__c,recommended__c,treatment_option__r.name,
          timeline__c,bleaching_tray__c,nightguard__c,bone_grafting__c,immediate_load__c,treatment_option__r.copy__c,treatment_option__r.benefits__c,treatment_option__r.considerations__c  from Treatment_Plan__c where account__c = :a.id 
          and include_on_handout__c = true order by recommended__c desc]) {
                Treatment_Object to = new Treatment_Object(tp);
                tplans.add(to);
        }
        return tplans;
  } 
  
  //method to return current treatment plans for this consult
  public List<Treatment_Plan__c> getcurrent_treatment_plans() {
        return [select handout_notes__c,id,account__c,ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c,initial_cost__c,Final_Cost__c,total_cost__c,recommended__c,treatment_option__r.name,
          bleaching_tray__c,nightguard__c,bone_grafting__c,immediate_load__c  from Treatment_Plan__c where account__c = :a.id order by recommended__c desc];
  }
  
  //grab a doctor for the handout sheet
  //at some point,  the team will set the doctor field at the consult level - we should use that value once this gets rolled out
  public String getcurrent_doctor() {
        String doc_name = 'N/A';
        try {
          Treatment_Plan__c tp;
          Integer row_count = [select count()  from Treatment_Plan__c where account__c = :a.id and recommended__c = true];
          if(row_count>0)
            tp = [select ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c from treatment_plan__c where account__c = :a.id and recommended__c = true limit 1];
          else
            tp = [select ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c from treatment_plan__c where account__c = :a.id and recommended__c = false limit 1];
          doc_name = tp.clearchoice_doctor__r.first_name__c + ' ' + tp.clearchoice_doctor__r.last_name__c;
        } catch (Exception e) {
          //no treatment plans - will return N/A        
        }
        return doc_name;        
  }
  
  public void remove_treatment_plan() {
        try {
          Treatment_Plan__c tp = [select id from Treatment_Plan__c where id = :apexpages.currentpage().getparameters().get('dtpid')];
          delete tp;
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to delete the treatment plan.' + e));
        }
  }
  
  public void reset_treatment_plan() {
        new_plan = new Treatment_Plan__c(account__c = a.id,final_cost__c = 0.00,initial_cost__c = 0.00, include_on_handout__c = true);
  }
  
  //method to add a new treatment plan
  public void add_treatment_plan() {
    Integer num_errors = 0;
    //run error checks here - does it have a plan, does it have a doctor,  does it have a final cost
    if(new_plan.treatment_option__c==null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a treatment option,  before you can add this record.'));
      num_errors++;     
    }
    if(new_plan.clearchoice_doctor__c==null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a ClearChoice Doctor from the list before adding the treatment plan.'));
      num_errors++;
    }
    if(new_plan.Final_Cost__c==null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a future cost for this treatment plan.'));
      num_errors++;
    }
    else if(new_plan.final_cost__c<0) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Future Cost must be greater than 0'));
      num_errors++;
    }
    if(new_plan.Initial_Cost__c==null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter an initial cost for this treatment plan.'));
      num_errors++;
    }
    else if(new_plan.initial_cost__c<=0) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Initial Cost must be greater than 0'));
      num_errors++;
    }   
    if(num_errors==0) {
      //insert the plan
          try {
            insert new_plan;
            if(new_plan.recommended__c) {
              System.debug('A : ' + a);
              Treatment_Option__c to = [select name,old_treatment_map__c from Treatment_Option__c where id = :new_plan.treatment_option__c];
              a.preliminary_treatment_plan__c = to.old_treatment_map__c;
              a.preliminary_treatment_fee_quoted__c = new_plan.initial_cost__c;
              update a;
            }
            new_plan = new Treatment_Plan__c(account__c = a.id, Include_on_Handout__c = true, final_cost__c = 0.00, initial_cost__c = 0.00);            
          }  catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error insert the new treatment plan.' + e));
      }
    }
  }
  
  public string getselected_treatment_name() {
        String tname = '';
        if(new_plan.treatment_option__c!=null) {
          try {
        tname = [select name from Treatment_Option__c where id = :new_plan.treatment_option__c].name;
          } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the treatment option name.' + e));
          }
        } else
          tname = '<span style="font-style:italic;">Select a plan from the list above</span>';
        return tname;
  }
   
}