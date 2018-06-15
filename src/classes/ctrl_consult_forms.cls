global without sharing class ctrl_consult_forms {
  public Account ahistory {get; set;}
  public Consult_Form__c cform {get; set;}
  public String display_name {get; set;}
  //VF page won't display the last name without dropping a line - using this as a workaround
  public String page_header {get; set;}
  public String check_in_code {get; set;}  
  public String consult_id {get;set;}
  public String accompanied {get;set;}
  public String work_done_error {get;set;}
  public boolean display_print {get; set;}    
  public String last_name {get;set;}
    
  public ctrl_consult_forms () {
  	check_in_code = '';
  	display_name = 'check_portal';
  	page_header = 'Check In Page';
  	work_done_error = '';
  	try {
      if(apexpages.currentpage().getparameters().get('aid')!=null) {
        ahistory = [Select a.Name, a.Taking_Bisphosphonates__c, a.Prescribed_Bisphosphonates__c, a.Pregnant__c, a.Phone, a.PersonMobilePhone, a.PersonMailingStreet, a.PersonMailingState, a.PersonMailingPostalCode, a.PersonMailingCity, a.Periodontal_Gum_Disease__c, a.Occupation__c, a.Major_Medical_Problem__c, a.Major_Medical_Problem_What__c, a.Main_Dental_Concern__c, a.Last_Dentist_Visit__c, a.LastName, a.How_would_treatment_change_your_life__c, a.How_soon_would_you_like_to_start__c, a.How_is_dental_condition_affecting_you__c, a.Have_Family_Dentist__c, a.Gender__c, a.FirstName, a.Employer__c, a.Email__c, a.Discuss_Medical_Care_Relationship_2__c, a.Discuss_Medical_Care_Relationship_1__c, a.Discuss_Medical_Care_Name_2__c, a.Discuss_Medical_Care_Name_1__c, a.Dentist_Name__c, a.Date_of_Birth__c, a.Business_Phone__c, a.BMOC_Weekend__c, a.BMOC_Evening__c, a.BMOC_Daytime__c,a.BMOC_Weekend_VM__c, a.BMOC_Evening_VM__c, a.BMOC_Daytime_VM__c, a.isPersonAccount, a.Accompanied_By__c, Accompanied_by_Name__c, a.Approve_iCat__c, a.Approve_Nothing__c, a.Approve_Panoramic__c, a.Approve_Consult__c  From Account a where a.id = :apexpages.currentpage().getparameters().get('aid')];
        check_for_consult_form();
        display_print = true;
      }
  	} catch (Exception e) {
  	  display_print = false;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the consult check in form.' + e));
  	}
  }
  
  public void refresh_call() {
  	
  }
  
  public void check_for_consult_form() {
  	//see if we already have a consult form for this patient
  	//if not,  create it
  	try {
  	  Integer cf_cnt = [select count() from Consult_Form__c where account__c = :ahistory.id];
  	  if(cf_cnt==0) {
	    cform = new Consult_Form__c(Account__c = ahistory.id, Phone__c = ahistory.phone, PersonMobilePhone__c = ahistory.PersonMobilePhone, PersonMailingStreet__c = ahistory.PersonMailingStreet,
	      PersonMailingPostalCode__c = ahistory.PersonMailingPostalCode, PersonMailingCity__c = ahistory.PersonMailingCity, LastName__c = ahistory.LastName, Gender__c = ahistory.Gender__c,
	      FirstName__c = ahistory.firstname, email__c = ahistory.email__c, date_of_birth__c = ahistory.date_of_birth__c, Accompanied_by__c = ahistory.accompanied_by__c,
	      accompanied_by_name__c = ahistory.accompanied_by_name__c);
	    insert cform;
  	  }   	
      cform = [Select c.PersonMailingCity__c, c.Taking_Bisphosphonates__c, c.SystemModstamp, c.Prescribed_Bisphosphonates__c, c.Pregnant__c, c.Phone__c, c.PersonMobilePhone__c, c.PersonMailingStreet__c, c.PersonMailingState__c, c.PersonMailingPostalCode__c, c.Periodontal_Gum_Disease__c, c.OwnerId, c.Occupation__c, c.Name, c.Major_Medical_Problem__c, c.Major_Medical_Problem_What__c, c.Main_Dental_Concern__c, c.Lead__c, c.Last_Dentist_Visit__c, c.LastName__c, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.How_would_treatment_change_your_life__c, c.How_soon_would_you_like_to_start__c, c.How_is_dental_condition_affecting_you__c, c.Have_Family_Dentist__c, c.Gender__c, c.FirstName__c, c.Employer__c, c.Email__c, c.Discuss_Medical_Care_Relationship_2__c, c.Discuss_Medical_Care_Relationship_1__c, c.Discuss_Medical_Care_Name_2__c, c.Discuss_Medical_Care_Name_1__c, c.Dentist_Name__c, c.Date_of_Birth__c, c.CreatedDate, c.CreatedById, c.Business_Phone__c, c.BMOC_Weekend__c, c.BMOC_Weekend_VM__c, c.BMOC_Evening__c, c.BMOC_Evening_VM__c, c.BMOC_Daytime__c, c.BMOC_Daytime_VM__c, c.Approve_iCat__c, c.Approve_Panoramic__c, c.Approve_Nothing__c, c.Approve_Consult__c, c.Account__c, c.Accompanied_by_Name__c, c.Accompanied_By__c From Consult_Form__c c where account__c = :ahistory.id];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error retrieving consult form record.' + e));
  	}  	
  }
  
  public String getcalculated_age() {
    //check to see if date of birth has been set
    if(cform.date_of_birth__c==null)
      return 'N/A';
    else {
       Integer year_diff =  (system.today().year() - cform.date_of_birth__c.year()) - 1;
       if(cform.date_of_birth__c.month() < system.today().month())
         year_diff++;
       else if(cform.date_of_birth__c.month() == system.today().month()) {
         if(cform.date_of_birth__c.day() <= system.today().day())
           year_diff++;
       }
       return String.valueof(year_diff);
    }
  }
  
  public String getparent_id() { 	
  	if(cform==null)
  	  return 'NA';
  	else if(cform.id==null)
  	  return 'NA';
  	else
  	  return cform.id;
  }
  
  public list<Selectoption> getyes_no_list() {
  	List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Yes','Yes'));
    options.add(new SelectOption('No','No'));
    return options;
  }
  
  public void page_two_submit() {
  	Integer num_issues = 0;
  	//do some error checking here
  	if(!cform.approve_consult__c && !cform.approve_icat__c && !cform.approve_panoramic__c && !cform.approve_nothing__c) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must check at least one box for work done.  Please see the front desk for help'));
  	  work_done_error = '<span style="color:red;font-weight:bold;">Please check at least one box</span>';
  	}
  	  	
  	//if no errors - then insert/update phistory object and change page header and display name
  	if(num_issues==0) {
  	  try {
  	  	//update ahistory;
  	  	update cform;
  	  	work_done_error = '';
  	  	//mark the patient as ready on the ci block
  	  	Consult_Inventory__c check_apt = [select id,consult_show_status__c,ready_time__c,scheduled_patient__c,scheduled_lead__c,scheduled_account__c from Consult_Inventory__c where id = :consult_id];
  	  	if(check_apt.Consult_Show_Status__c=='Arrived') {
          check_apt.Ready_Time__c = System.now();
          check_apt.Consult_Show_Status__c = 'Ready for Consult';
          try {
            update check_apt;
            Apt_History__c history = new Apt_History__c(Consult_Inventory__c = check_apt.id, Private_practice_Patient__c = check_apt.scheduled_patient__c, Lead__c = check_apt.Scheduled_Lead__c, account__c = check_apt.Scheduled_Account__c, action__c = 'Ready', notes__c = 'Consult status has been changed to Ready for Consult');          
            insert history;
          } catch (Exception e) {                
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to save your check in form.  Please see the front desk for help'));
	  	    ApexPages.addMessages(e);   
          }
        }
  	  	
  	  	display_name = 'page3';
  	  	page_header = 'Thank you';
  	  } catch(Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to save your check in form.  Please see the front desk for help'));
	  	ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void page_one_submit() {
  	Integer num_issues = 0;
  	//do some error checking here
  	  	
  	//if no errors - then insert/update phistory object and change page header and display name
  	if(num_issues==0) {
  	  try {
  	  	//update ahistory;
  	  	update cform;
  	  	display_name = 'page2';
  	  	page_header = 'Sign In Page 2';
  	  	work_done_error = '';
  	  } catch(Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to save your check in form.  Please see the front desk for help'));
	  	ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void new_check_in_code() {
  	if(check_in_code==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error with your check in code.  Please check the code and try again or contact IT for assistance'));
  	}
  	else {
  	  try {
  	    Consult_Inventory__c ci = [select patient_name__c,scheduled_patient__c,arrival_time__c, id,scheduled_lead__c,scheduled_account__c,check_in_code__c,Consult_Show_Status__c from Consult_Inventory__c where check_in_code__c = :check_in_code];
  	    consult_id = ci.id;
  	    String accnt_id;  	    
  	    if(ci.scheduled_lead__c!=null) {
  	      //convert lead and grab account fields
  	      Database.LeadConvert lc = new Database.LeadConvert();
	      lc.setLeadId(ci.scheduled_lead__c);
	      lc.setDoNotCreateOpportunity(True);

          LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
          lc.setConvertedStatus(convertStatus.MasterLabel);
      
          Database.LeadConvertResult lcr = Database.convertLead(lc);
  	      ahistory = [Select a.Name, a.Taking_Bisphosphonates__c, a.Prescribed_Bisphosphonates__c, a.Pregnant__c, a.Phone, a.PersonMobilePhone, a.PersonMailingStreet, a.PersonMailingState, a.PersonMailingPostalCode, a.PersonMailingCity, a.Periodontal_Gum_Disease__c, a.Occupation__c, a.Major_Medical_Problem__c, a.Major_Medical_Problem_What__c, a.Main_Dental_Concern__c, a.Last_Dentist_Visit__c, a.LastName, a.How_would_treatment_change_your_life__c, a.How_soon_would_you_like_to_start__c, a.How_is_dental_condition_affecting_you__c, a.Have_Family_Dentist__c, a.Gender__c, a.FirstName, a.Employer__c, a.Email__c, a.Discuss_Medical_Care_Relationship_2__c, a.Discuss_Medical_Care_Relationship_1__c, a.Discuss_Medical_Care_Name_2__c, a.Discuss_Medical_Care_Name_1__c, a.Dentist_Name__c, a.Date_of_Birth__c, a.Business_Phone__c, a.BMOC_Weekend__c, a.BMOC_Evening__c, a.BMOC_Daytime__c,a.BMOC_Weekend_VM__c, a.BMOC_Evening_VM__c, a.BMOC_Daytime_VM__c, a.isPersonAccount, a.Accompanied_By__c, Accompanied_by_Name__c, a.Approve_iCat__c, a.Approve_Nothing__c, a.Approve_Panoramic__c, a.Approve_Consult__c From Account a where a.id = :lcr.getAccountId()];
  	      accnt_id = lcr.getAccountId();
  	      //check for a consult form tied to the lead - one filled out by email link
  	      Integer cf_cnt = [select count() from Consult_Form__c where lead__c = :ci.scheduled_lead__c];
  	      if(cf_cnt>0) {
  	      	Consult_Form__c cf = [select id,lead__c,account__c from Consult_Form__c where lead__c = :ci.scheduled_lead__c];
  	      	cf.account__c = lcr.getAccountId();
  	      	update cf;
  	      }
  	      
  	      ci.scheduled_lead__c = null;
  	      ci.scheduled_account__c = lcr.getAccountId();
  	      
  	    } else if(ci.scheduled_account__c!=null) {
  	      ahistory = [Select a.Name, a.Taking_Bisphosphonates__c, a.Prescribed_Bisphosphonates__c, a.Pregnant__c, a.Phone, a.PersonMobilePhone, a.PersonMailingStreet, a.PersonMailingState, a.PersonMailingPostalCode, a.PersonMailingCity, a.Periodontal_Gum_Disease__c, a.Occupation__c, a.Major_Medical_Problem__c, a.Major_Medical_Problem_What__c, a.Main_Dental_Concern__c, a.Last_Dentist_Visit__c, a.LastName, a.How_would_treatment_change_your_life__c, a.How_soon_would_you_like_to_start__c, a.How_is_dental_condition_affecting_you__c, a.Have_Family_Dentist__c, a.Gender__c, a.FirstName, a.Employer__c, a.Email__c, a.Discuss_Medical_Care_Relationship_2__c, a.Discuss_Medical_Care_Relationship_1__c, a.Discuss_Medical_Care_Name_2__c, a.Discuss_Medical_Care_Name_1__c, a.Dentist_Name__c, a.Date_of_Birth__c, a.Business_Phone__c, a.BMOC_Weekend__c, a.BMOC_Evening__c, a.BMOC_Daytime__c,a.BMOC_Weekend_VM__c, a.BMOC_Evening_VM__c, a.BMOC_Daytime_VM__c, a.isPersonAccount, a.Accompanied_By__c, Accompanied_by_Name__c, a.Approve_iCat__c, a.Approve_Nothing__c, a.Approve_Panoramic__c, a.Approve_Consult__c  From Account a where a.id = :ci.scheduled_account__c];
  	      accnt_id = ci.scheduled_account__c;
  	    }
  	    check_for_consult_form();

  	    if(ahistory.accompanied_by_name__c==null)
  	      accompanied = 'No';
  	    //clear the code from the ci block;
  	    ci.check_in_code__c = null;
  	    //mark the patient as arrived if necessary
  	    if(ci.Patient_Name__c!=null || ci.scheduled_account__c!=null || ci.scheduled_patient__c!=null) {
  	      if(ci.Consult_Show_Status__c==null) {
            ci.Arrival_Time__c = System.now();
            ci.Consult_Show_Status__c = 'Arrived';              
            Apt_History__c history = new Apt_History__c(Consult_Inventory__c = ci.id, Private_practice_Patient__c = ci.scheduled_patient__c, account__c = accnt_id, action__c = 'Arrived', notes__c = 'Consult status has been changed to Arrived');          
            insert history;          
          }
  	    }  	    
  	    update ci;

  	    display_name = 'page1';
  	    page_header = 'Sign In Page 1';
  	    check_in_code = '';   
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error with your check in code.  Please check the code and try again or contact IT for assistance'));
  	  	ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void back_to_page_one() {
  	display_name = 'page1';
  	page_header = 'Sign In Page 1'; 
  }
  
  public void back_to_page_two() {
  	display_name = 'page2';
  	page_header = 'Sign In Page 2';
  }
  
  public void new_form_submit() {
    display_name = 'check_portal';
  	page_header = 'Check In Page';
  }
  
  @RemoteAction
  global static String saveSignatureConsultForm(String signatureBody, String my_parentId) {
    try {
      system.debug('Record Id == ' + my_parentId);
      system.debug(signatureBody);
      //check to see if patient has already previously signed....if so delete the attachment
      Integer cnt = [select count() from Attachment where parentid = :my_parentId and name = 'Signature Consult Sign In.png'];
  	  if(cnt>0) {
  	  	Attachment da = [select id from Attachment where parentid = :my_parentId and name = 'Signature Consult Sign In.png'];
  	  	delete da;
  	  }
      
      Attachment a = new Attachment(ParentId = my_parentId,Body = EncodingUtil.base64Decode(signatureBody),ContentType = 'image/png',Name = 'Signature Consult Sign In.png');
      insert a;
      return '{success:true, attachId:' + a.Id + '}';
    }  catch (Exception e) {
      return JSON.serialize(e);
    }    
    return null;
  }
  
  public Boolean getsigned_consult_form() {
  	Integer cnt = [select count() from Attachment where parentid = :cform.id and name = 'Signature Consult Sign In.png'];
  	if(cnt>0)
  	  return true;
  	else
  	  return false;
  }
  
  public String getsignature_consult_form() {  	
  	try {
  	  Attachment a = [select body from Attachment where parentid = :cform.id and name = 'Signature Consult Sign In.png'];
  	  return EncodingUtil.base64encode(a.body);
  	} catch (Exception e) {
  	  return '';
  	}
  }
  
  public String getsignature_consult_form_date() {
  	try {
  	  Attachment a = [select createddate from Attachment where parentid = :cform.id and name = 'Signature Consult Sign In.png'];
  	  return a.createddate.format('MM/dd/YYYY');
  	} catch (Exception e) {
  	  return System.now().format('MM/dd/YYYY');
  	}
  }
}