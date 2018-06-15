public without sharing class ctrl_patientimplants {
  public practice_patient patient {get; set;}
  public Patient_Implant__c implant {get; set;}
  public Boolean display_patient_search {get; set;}
  public Boolean display_implant_info {get; set;}   
  public Boolean display_new_practice_patient {get; set;}      
  public Boolean patient_search_error {get;set;}
  public String patient_search_message {get; set;} 
  public Boolean implant_error {get; set;}
  public String implant_error_message {get; set;}
  public String patient_type {get;set;}
  public Private_Practice_Patient__c new_patient {get; set;}
        
  //List<Opportunity> patient_search_results;
  practice_patient[] patient_search_results;
  //public List<Patient_Implant__c> current_implants;
  public List<implant_info> current_implants;
  public String name_filter {get; set;}
  public String center_filter {get; set;}
  public String market_filter {get; set;}
        
  public class implant_info {
    public Patient_Implant__c pi {get; set;}
        
    public implant_info(Patient_Implant__c my_pi) {
      pi = my_pi;
    }
        
    public Boolean getallow_edit() {
      if(pi.createdby.name==Userinfo.getName()) {
        Date cdate = Date.newinstance(pi.createddate.year(),pi.createddate.month(),pi.createddate.day());
        Date tdate = date.today();
        Boolean rval = tdate.isSameDay(cdate);
        return rval;
      }
      return false;
    }
  }
  
  public class practice_patient implements Comparable {
  	public String patient_type {get; set;}
  	//public Opportunity o {get; set;}
  	public Account a {get; set;}
  	public Private_Practice_Patient__c pp {get; set;}
  	public String patient_name {get; set;}
  	
  	//public practice_patient(Opportunity opp,Private_Practice_Patient__c p) {
  	public practice_patient(Account acc,Private_Practice_Patient__c p) {
  	  //if(opp!=null) {
  	  	//patient_type = 'Opportunity';
  	 if(acc!=null) {
  	  	patient_type = 'Account';
  	  	patient_name = acc.name;
  	  	this.a = acc;
  	  }
  	  if(p!=null) {
  	  	patient_type = 'Private_Practice';
  	  	patient_name = p.name;
  	  	this.pp = p;
  	  }
  	}
  	
  	public String getprosth_date() {
  	  /*String prosth_date = patient_type=='Opportunity' ? o.closedate.format() : '';
  	  return prosth_date;*/
  	  return '';
  	}
  	
  	public String gettx_plan() {
  	  //String tx_plan = patient_type=='Opportunity' ? o.preliminary_treatment_plan__c : patient_type=='Private_Practice' ? pp.treatment_plan__c : '';
  	  String tx_plan = patient_type=='Account' ? a.preliminary_treatment_plan__c : patient_type=='Private_Practice' ? pp.treatment_plan__c : '';
  	  return tx_plan;
  	}
  	
  	public String getpatient_email() {
  	  String email = '';
  	  //if(patient_type=='Opportunity')
  	    //email = o.account.email__c;
  	  if(patient_type=='Account')
  	    email = a.email__c;
  	  if(patient_type=='Private_Practice')
  	    email =  pp.patient_email__c;
  	  return email;
  	}
  	
  	public String getpatient_phone() {
      String phone = '';
  	  /*if(patient_type=='Opportunity')
  	    phone = o.account.phone;*/
  	  if(patient_type=='Account')
  	    phone = a.phone;
  	  if(patient_type=='Private_Practice')
  	    phone = pp.main_phone__c;
  	  return phone;
  	}
  	
  	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      practice_patient compareTopatient = (practice_patient)compareTo;
        
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (patient_name > compareTopatient.patient_name) {
        // Set return value to a positive value.
        returnValue = 1;
      } else if (patient_name < compareTopatient.patient_name) {
        // Set return value to a negative value.
        returnValue = -1;
      }        
      return returnValue;       
    }
  
  }
             
  public ctrl_patientimplants() {  
    name_filter = '';
    patient_type = '';
    display_new_practice_patient = false;
    center_filter = [select clinic_calendar__c from User where id = :Userinfo.getUserId()].clinic_calendar__c;  
    System.debug('Center Filter : ' + center_filter + ' User Id : ' + Userinfo.getUserId());
    Center_Information__c current_center = [select id,name,sales_market__c from Center_Information__c where name = :center_filter];
    System.debug('Current Center : ' + current_center);
    market_filter = current_center.sales_market__c;
    System.debug('Market Filter : ' + market_filter); 
    /*if(apexpages.currentpage().getparameters().get('oid')!=null) { 
      Opportunity o = [select id, name, accountid, closedate, preliminary_treatment_plan__c, account.phone, account.email__c from Opportunity where id = :apexpages.currentpage().getparameters().get('oid')]; 
      Patient = new Practice_Patient(o,null);
      display_patient_search = false;
      patient_search_error = false;
      patient_search_message = '';
      refresh_implants();
      display_implant_info = true;
      implant = new Patient_Implant__c(Prosth_patient__c = patient.o.id, account__c = patient.o.accountid, Implant_Status__c = 'Installed', Implant_Type__c = 'Implant');
    } */
    if(apexpages.currentpage().getparameters().get('aid')!=null) { 
      Account a = [select id, name, preliminary_treatment_plan__c, phone, email__c from Account where id = :apexpages.currentpage().getparameters().get('aid')]; 
      Patient = new Practice_Patient(a,null);
      display_patient_search = false;
      patient_search_error = false;
      patient_search_message = '';
      refresh_implants();
      display_implant_info = true;
      implant = new Patient_Implant__c(account__c = patient.a.id, Implant_Status__c = 'Installed', Implant_Type__c = 'Implant');
    }
    else if(apexpages.currentpage().getparameters().get('ppid')!=null) {
      Private_Practice_Patient__c pp = [Select p.treatment_plan__c,p.Patient_Email__c, p.Name, p.Main_Phone__c, p.Last_Name__c, p.Id, p.First_Name__c From Private_Practice_Patient__c p where id = :apexpages.currentpage().getparameters().get('ppid')];
      Patient = new Practice_Patient(null,pp);
      display_patient_search = false;
      patient_search_error = false;
      patient_search_message = '';
      refresh_implants();
      display_implant_info = true;
      implant = new Patient_Implant__c(Private_Practice_Patient__c = pp.id, Implant_Status__c = 'Installed', Implant_Type__c = 'Implant');
    } 
    else {
      patient = null;
      display_patient_search = true;
      patient_search_error = true;
      patient_search_message = '<span class="warning" style="color:red;">Please type in part of a name to search for a patient</span>';
      display_implant_info = false; 
    }
  }  
  
  public void new_private_practice_form() {
  	display_new_practice_patient = true;
  	display_patient_search = false;
  	display_implant_info = false;
  	try {
  	  Center_Information__c ci = [select id,name from Center_Information__c ci where name = :center_filter];
  	  new_patient = new Private_Practice_Patient__c(center__c = ci.id);
  	}
  	catch (Exception e) {
  	  ApexPages.addMessages(e); 
  	}
  }
  
  public void patient_search() {
    if(name_filter<>'') { 
      patient_search_results = new practice_patient[] {};
      try {
        patient_search_error = false;
        patient_search_message = '';
        System.debug('Market Filter : ' + market_filter); 
        /*String query = 'select id,name,account.center__r.name,closedate, preliminary_treatment_plan__c,account.phone,account.email__c from Opportunity where name like \'%' 
          + name_filter + '%\' and account.center__r.name = \'' + center_filter + '\' order by name limit 100';*/
        /*String query = 'select id,name,account.center__r.name,closedate, preliminary_treatment_plan__c,account.phone,account.email__c from Opportunity where name like \'%' 
          + name_filter + '%\' and account.center__r.sales_market__c = \'' + market_filter + '\' order by name limit 100';*/
        String query = 'select id, name, preliminary_treatment_plan__c, phone, email__c from Account where name like \'%' 
          + name_filter + '%\' and account.center__r.sales_market__c = \'' + market_filter + '\' order by name limit 100';
        System.debug('Query : ' + query);
        //grab opportunity records
        //for(Opportunity o : database.query(query)) {
        for(Account a : database.query(query)) {
          Practice_Patient p = new Practice_patient(a,null);
          patient_search_results.add(p);
        }
        //grab private practice records
        /*query = 'Select p.treatment_plan__c,p.Patient_Email__c, p.Name, p.Main_Phone__c, p.Last_Name__c, p.Id, p.First_Name__c From Private_Practice_Patient__c p where name like \'%'
          + name_filter + '%\' and p.center__r.name = \'' + center_filter + '\' order by name limit 100';*/
        query = 'Select p.treatment_plan__c,p.Patient_Email__c, p.Name, p.Main_Phone__c, p.Last_Name__c, p.Id, p.First_Name__c From Private_Practice_Patient__c p where name like \'%'
          + name_filter + '%\' and p.center__r.sales_market__c = \'' + market_filter + '\' order by name limit 100';
        for(Private_Practice_Patient__c pp : database.query(query)) {
          Practice_Patient p = new Practice_patient(null,pp);
          patient_search_results.add(p);
        }
      }
      catch (Exception e) {
        patient_search_error = true;
        patient_search_message = '<span class="warning" style="color:red;">There was an error while searching for patients</span><br />' + e.getmessage();
      }
    }
    else {
      patient_search_error = true;
      patient_search_message = '<span class="warning" style="color:red;">Please type in part of a name to search for a patient</span>';
    }
  }
  
  public void add_practice_patient() {
  	Boolean patient_validated = true;
  	if(new_patient.first_name__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for First Name'));
  	  patient_validated = false;
  	}
  	if(new_patient.last_name__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for Last Name'));
  	  patient_validated = false;
  	}
  	if(new_patient.practice_id__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for Windent Patient ID'));
  	  patient_validated = false;
  	}
  	if(new_patient.patient_email__c==null && new_patient.main_phone__c==null && new_patient.street_address__c==null && new_patient.practice_id__c==null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for either email,  phone, or street address'));
  	  patient_validated = false;
  	}
  	if(patient_validated) {
	  try {
	  	new_patient.name = new_patient.first_name__c + ' ' + new_patient.last_name__c;
	    insert new_patient;
	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Success - private practice patient was added'));
	    Center_Information__c ci = [select id,name from Center_Information__c ci where name = :center_filter];
  	    new_patient = new Private_Practice_Patient__c(center__c = ci.id);
	  }
	  catch (Exception e) {
	    ApexPages.addMessages(e); 	
	  }
  	}
  }
  
  public void select_patient() {
    try {
      /*if(apexpages.currentpage().getparameters().get('oid')!=null) {
      	Opportunity o = [select id, name, accountid, closedate, preliminary_treatment_plan__c, account.phone, account.email__c from Opportunity where id = :apexpages.currentpage().getparameters().get('oid')];*/
      if(apexpages.currentpage().getparameters().get('aid')!=null) {
      	Account a = [select id, name, preliminary_treatment_plan__c, phone, email__c from Account where id = :apexpages.currentpage().getparameters().get('aid')];      	 
        Patient = new Practice_Patient(a,null); 
      }
      else if(apexpages.currentpage().getparameters().get('ppid')!=null) {
        Private_Practice_Patient__c pp = [Select p.treatment_plan__c,p.Patient_Email__c, p.Name, p.Main_Phone__c, p.Last_Name__c, p.Id, p.First_Name__c From Private_Practice_Patient__c p where id = :apexpages.currentpage().getparameters().get('ppid')];
        Patient = new Practice_Patient(null,pp);
      }
      display_patient_search = false;
      patient_search_error = false;
      patient_search_message = '';
      refresh_implants();
      implant_error = false;
      implant_error_message = '';
      display_implant_info = true;
      setup_new_implant();
    }
    catch (Exception e) {
      implant_error = true;
      implant_error_message = '<span class="warning">There was an error grabbing the implant information for this patient</span> ' + e.getmessage();      
    }
  }
  
  public void change_patient() {
  	new_patient = null;
    patient = null;
    current_implants = null;
    display_patient_search = true;
    patient_search_error = true;
    display_new_practice_patient = false;
    patient_search_message = '<span class="warning" style="color:red;">Please type in part of a name to search for a patient</span>';
    display_implant_info = false;
    name_filter = '';       
  }
  
  public String getpatient_display_name() {
    if(patient==null)
      return '<span style="font-style:italic;">Use the search feature below to select your patient</span>';
    else
      return patient.patient_name;
  }
  
  public Practice_Patient[] getpatient_search_results () {
  	patient_search_results.sort();
    return patient_search_results;
  }
  
  public List<implant_info> getcurrent_implants() {
    return current_implants;
  }
  
  public integer getcurrent_implants_size() {
    if(current_implants==null)
      return 0;
    else 
     return current_implants.size();
  }
  
  public void refresh_implants() {
    current_implants = new List<implant_info> ();
    String query = 'Select implant_type__c,id,lot_number__c,implant_free__c, implant__r.name,implant__r.brand__c,implant__r.part_description__c,createdby.name,createddate,lastmodifiedby.name,lastmodifieddate,implant_status__c,gudid__c,implant_location__c from patient_implant__c ';
    /*if(patient.patient_type=='Opportunity') 
      query += 'where prosth_patient__c = \'' + patient.o.id + '\'';*/
    if(patient.patient_type=='Account') 
      query += 'where account__c = \'' + patient.a.id + '\'';
    else if(patient.patient_type=='Private_Practice')
      query += 'where Private_Practice_Patient__c = \'' + patient.pp.id + '\'';
    try {
      for(Patient_Implant__c pi : database.query(query)) {
        implant_info i = new implant_info(pi);
        current_implants.add(i);
      }
    } catch (Exception e) {
      ApexPages.addMessages(e); 
    }       
  }
  
  public void setup_new_implant() {
  	implant = new Patient_Implant__c(Implant_Status__c = 'Installed', Implant_Type__c = 'Implant');
    /*if(patient.patient_type=='Opportunity') {
      implant.Prosth_patient__c = patient.o.id;
      implant.account__c = patient.o.accountid;
    }*/
    if(patient.patient_type=='Account') 
      //implant.Prosth_patient__c = patient.o.id;
      implant.account__c = patient.a.id;
    if(patient.patient_type=='Private_Practice') 
      implant.Private_Practice_Patient__c = patient.pp.id;
  }
  
  public void add_implant() {
    if((implant.Lot_Number__c!=null && implant.implant_free__c!=null) || implant.GUDID__c!=null) {
      try {
        insert implant;
        refresh_implants();
        implant_error = false;
        implant_error_message = '';
        display_implant_info = true;
        setup_new_implant();
      }
      catch (Exception e) {
        implant_error = true;
        implant_error_message = '<span class="warning">There was an error adding the implant information for this patient</span> ' + e.getmessage();
        //apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'System Error', implant_error_message));
      }
    }
    else {
      implant_error = true;
      implant_error_message = '<span class="warning">You must enter something into the lot number and implant number field OR the GUDID # for this item</span>';
    }
  }
  
  public void update_implant_status() {
    try {
      List<Patient_Implant__c> pi_list = new List<Patient_Implant__c>();
      for(implant_info i : current_implants) {
        pi_list.add(i.pi);
      }
      update pi_list;
      refresh_implants();
    }
    catch (Exception e) {
      implant_error = true;
      implant_error_message = '<span class="warning">There was an error adding the implant information for this patient</span> ' + e.getmessage();
    }
  }
  
  public String getuser_name() {
    return Userinfo.getName();
  }
  
  public void delete_implant() {
    try {
      implant_error = false;
      implant_error_message = '';
      Patient_Implant__c remove_implant = [select id,createdby.name from Patient_Implant__c where id = :apexpages.currentpage().getparameters().get('dimpid')];
      //verify the person deleting it is the same as the person who created this record
      if(remove_implant.createdby.name==Userinfo.getName()) {
        delete remove_implant;
        //current_implants = [Select id,lot_number__c,implant_free__c,implant__r.name,implant__r.brand__c,implant__r.part_description__c,createdby.name,createddate,lastmodifiedby.name,lastmodifieddate,implant_status__c from patient_implant__c where prosth_patient__c = :patient.id];
        refresh_implants();                                         
      }
      else {
        implant_error = true;
        implant_error_message = '<span class="warning">You are not authorized to delete this implant</span>';
      }
    }
    catch (Exception e) {
      implant_error = true;
      implant_error_message = '<span class="warning">There was an error adding the implant information for this patient</span> ' + e.getmessage();
      //apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'System Error', implant_error_message));
    }
  }
  
  
  public Component.Apex.IncludeScript getPhoneGapJS() { 
     String userAgent = System.currentPageReference().getHeaders().get('User-Agent'); 
     Component.Apex.IncludeScript jsScript; 
     /*if (userAgent.contains('iPhone') || userAgent.contains('iPad')){ 
       jsScript = new Component.Apex.IncludeScript(); 
       jsScript.expressions.value = '{!URLFOR($Resource.PhoneGap1_8_1_iOS)}'; 
     }else if (userAgent.contains('Android')){*/ 
       jsScript = new Component.Apex.IncludeScript(); 
       jsScript.expressions.value = '{!URLFOR($Resource.PhoneGap1_8_1_Android)}'; 
     //} 
     return jsScript; 
   } 
  
    public Component.Apex.IncludeScript getBarCodeScannerJS() { 
     String userAgent = System.currentPageReference().getHeaders().get('User-Agent'); 
     Component.Apex.IncludeScript jsScript; 
     /*if (userAgent.contains('iPhone') || userAgent.contains('iPad')){ 
       jsScript = new Component.Apex.IncludeScript(); 
       jsScript.expressions.value = '{!URLFOR($Resource.PhoneGap1_8_1_iOS)}'; 
     }else if (userAgent.contains('Android')){*/ 
       jsScript = new Component.Apex.IncludeScript(); 
       jsScript.expressions.value = '{!URLFOR($Resource.BarCodeScanner)}'; 
     //} 
     return jsScript; 
   } 

  
}