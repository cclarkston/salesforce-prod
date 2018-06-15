global with sharing class dp_clinical_dosespot {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  public Account patient {get;set;}
    
  public String search_name {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public List<Account> consult_search_results {get; set;}
  
  public Integer DS_trans_errors {get; set;}
  public Integer DS_refill_errors {get; set;}
  public Boolean display_ds_error_iframe {get ;set;}
  
  public Boolean display_patient_search_modal {get; set;}
  Set<ID> market_centers;
  
  public String search_first {get;set;}
  public String search_unique {get; set;}
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
      
  public class bendException extends Exception {}	
  
  public List<clinician_errors> staff_errors {get;set;}   
  
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}
  
  static {
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  }   
  
  public class clinician_errors {
  	public User clinician {get;set;}
  	public Integer refill_errors {get;set;}
  	public Integer trans_errors {get; set;}
  	public Integer pending_scripts {get; set;}
  	
  	public clinician_errors(User u,Integer refills_e, Integer transmission_e, Integer script_e) {
  	  this.clinician = u;
  	  this.refill_errors = refills_e;
  	  this.trans_errors = transmission_e;
  	  this.pending_scripts = script_e;
  	}  	
  }
	  
  public dp_clinical_dosespot() {
  	display_ds_error_iframe = false;
  	staff_errors = new List<clinician_errors>();
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
        User u = [select id,name,clinic_calendar__c from user where id =:userinfo.getUserId()];         
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   	  	  	 
  	market_centers = getcenters_in_market();
  	 	  	
  	//to-do handle default patient
  	try {
  	  if(apexpages.currentpage().getparameters().get('ptid')!=null) {
  	    getpatient_record(apexpages.currentpage().getparameters().get('ptid'),current_center.id);
  	    display_patient_search_modal = false;
  	  } else {
  	    display_patient_search_modal = true;
  	    search_name = '';
  	    search_first = '';
  	    search_unique = '';
  	    search_phone = '';
  	    search_email = ''; 
  	    consult_search_results = new List<Account>();
  	  }    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the patient record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}

  	display_patient_search_modal = false;
  	
  	ds_refill_errors = 0;
  	ds_trans_errors = 0;
  	num_patient_records = 20;
    display_more_search_records = false;
  	
  	//check for transmission/refill error counts
  	try {
  	  //dp_clinical_dosespot.response_parse nresponse = (dp_clinical_dosespot.response_parse)JSON.deserialize(DosespotServices.refill_requests_and_transmission_errors(current_center),dp_clinical_dosespot.response_parse.class);
  	  //DS_refill_errors = Integer.valueof(nresponse.data.get('refillRequestCount'));
  	  //DS_trans_errors = Integer.valueof(nresponse.data.get('transmissionErrorCount'));

      //build a list of the clinician ids we need to check
  	  Set<Integer> all_clinician_ids = new Set<Integer>();
  	  Map<Integer,User> clinician_map = new Map<Integer,User>();
  	  for(User u : [select u.id,u.DoseSpot_User_ID__c,u.name from User u 
  	    where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name
  	    and u.dosespot_user_id__c != null ]) {  		
  	    all_clinician_ids.add(Integer.valueof(u.dosespot_user_id__c));
  	    clinician_map.put(Integer.valueof(u.dosespot_user_id__c),u);
  	  } 
  	  Set<ID> missing_users = new Set<ID> ();
  	  //check user_center_assignments?
  	  for(User_Center_Assignment__c uca : [select id,dosespot_user_id__c,user__c from user_center_assignment__c 
  	    where center_information__c = :current_center.id and user__r.Profile.name in ('Clinical Doctor','SF - Clinical Doctor')
  	    and dosespot_user_id__c != null ]) {
  	    all_clinician_ids.add(Integer.valueof(uca.dosespot_user_id__c));
  	    if(clinician_map.get(Integer.valueof(uca.dosespot_user_id__c))==null)
  	      missing_users.add(uca.user__c);
  	  }
  	  //do we have user records we need to grab here
  	  if(missing_users.size()>0) {
  	  	for(User u : [select u.id,u.DoseSpot_User_ID__c,u.name from User u where id in :missing_users]) {
  	  	  clinician_map.put(Integer.valueof(u.dosespot_user_id__c),u);
  	  	}
  	  }
  	  
  	  //shouldn't happen in production,  but I'm leaving this in place here for the test environment and initial setup circumstances
  	  if(all_clinician_ids.size()==0) {
  	    DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
        Map<String,Object> amap = (Map<String,object>)dres.data;
        DS_refill_errors += Integer.valueof(amap.get('refillRequestCount'));        
        DS_trans_errors += Integer.valueof(amap.get('transmissionErrorCount'));
        if(amap.get('RefillsErrors')!=null)
          DS_refill_errors += Integer.valueof(amap.get('RefillsErrors'));        
  	  } else {
  	  	for(Integer clinician_id : all_clinician_ids) {
          Integer rerrors = 0;
          DoseSpotServices.Response dres = DosespotServices.notification_counts(current_center,String.valueof(clinician_id));
          Map<String,Object> amap = (Map<String,object>)dres.data;
          DS_refill_errors += Integer.valueof(amap.get('refillRequestCount'));
          rerrors += Integer.valueof(amap.get('refillRequestCount'));
          DS_trans_errors += Integer.valueof(amap.get('transmissionErrorCount'));
          DS_refill_errors += Integer.valueof(amap.get('pendingPrescriptionsCount'));          
          if(amap.get('RefillsErrors')!=null) {
            DS_refill_errors += Integer.valueof(amap.get('RefillsErrors'));
            rerrors += Integer.valueof(amap.get('RefillsErrors'));
          }    
          staff_errors.add(new clinician_errors(clinician_map.get(clinician_id),rerrors,Integer.valueof(amap.get('transmissionErrorCount')),Integer.valueof(amap.get('pendingPrescriptionsCount'))   ));      
  	  	}
  	  }  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the patient record.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public Set<ID> getcenters_in_market() {
  	Set<ID> all_centers = new Set<ID> {current_center.id};
  	try {
  	  for(Center_Information__c ci : [select id from Center_Information__c where market__c = : current_center.market__c and id != :current_center.id]) {
  	    all_centers.add(ci.id);
  	  }
  	} catch (Exception e) {
  	  //bad or missng market__c value?
  	}
  	return all_centers;
  }
    
  public List<Center_Information__c> getcenter_list() {
  List<Center_Information__c> ci_list;
  //to-do: need to modify this so it display all centers relevant to the user
  	//User current_user = [Select u.Name, u.Id,userrole.name, clinic_calendar__c, regional_traveler__c From User u where id = :userinfo.getuserid()];
  	//admin or user is a traveler by role - display all centers  	
  	if(display_corp_admin || u.userrole.name=='Traveler - PEC') 
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id order by name];
  	//regional traveler - display all centers in this region
  	else if(u.regional_traveler__c)
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and sales_region__c = :current_center.sales_region__c order by name];
  	//standard user - display centers in the same market (same doctor ownership)
  	else
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c = :current_center.market__c order by name];
  	return ci_list;
  }
  
  public List<dp_clinical_common.hrx_navigation_link> getgear_menu() {return common_header.getnav_pages_by_name('Gear',current_center);}
     
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  market_centers = getcenters_in_market();
  	  patient = null;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public PageReference navigate_to() {
  	PageReference pr;
  	if(apexpages.currentpage().getparameters().get('navid')!=null) {
  	  try {
  	  	pr = common_header.pref_navid(current_center,apexpages.currentpage().getparameters().get('navid'));  	  	  	  	
  	    if(patient!=null)
  	      pr.getParameters().put('ptid',patient.id);       	      
  	    return pr;  	  	
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change pages.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  	return null;
  	  }
  	}
  	return pr;
  }
  
  public PageReference navigate_to_recent_patient() {  	  	
    return common_header.pref_to_patient(current_center,apexpages.currentpage().getparameters().get('recentid'));  	  	
  }
  
  public Boolean getpatient_record_selected() {
  	if(patient==null)
  	  return false;
  	else
  	  return true;
  }
  
  public Integer getsearch_result_size() {
  	return consult_search_results.size();
  } 
  
  public void search_consult_records() {
  	Set<ID> opp_matches = new Set<ID>();
  	String query_filter = ' where center__c in :market_centers';
  	if((search_name==null?'':search_name)!='')
  	  query_filter += ' and lastname like \'%' + search_name.trim() + '%\' ';
  	if((search_first==null?'':search_first)!='')
  	  query_filter += ' and firstname like \'%' + search_first.trim() + '%\' ';
  	if((search_unique==null?'':search_unique)!='') {  	  
  	  for(Opportunity o : database.query('select id,accountid from opportunity where windent_patient_id__c like \'%' + search_unique  +'%\'')) {
  	  	opp_matches.add(o.accountid);
  	  }
  	  query_filter += ' and (warranty_id__c like \'%' + search_unique.trim() + '%\' or id in :opp_matches) ';
  	}  	    	  
  	if((search_phone==null?'':search_phone)!='') {
  	  //clean up the phone number so we can search with it
  	  query_filter += ' and (phone like \'%' + search_phone.trim() + '%\' or personmobilephone like \'%' + search_phone.trim() + '%\') ';
  	}
  	if((search_email==null?'':search_email)!='') 
  	  query_filter += ' and (email__c like \'%' + search_email.trim() + '%\' or personemail like \'%' + search_email.trim() + '%\') ';
  	//to-do search for consult matches
  	try {
  	 // System.debug('Consult Search Query : ' + 'select id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode from Account ' + query_filter + ' limit 20');
  	  consult_search_results = database.query('select id,name,phone,email__c,personemail,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,warranty_id__c from Account ' 
  	    + query_filter + ' order by name limit ' + num_patient_records);	
  	  if(consult_search_results.size()==num_patient_records)
  	    display_more_search_records = true;
  	  else
  	    display_more_search_records = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error searching for patients.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }    
  
  public Pagereference select_search_patient() {
  	Pagereference pr;
  	try {
  	  getpatient_record(apexpages.currentpage().getparameters().get('sptid'),current_center.id);
  	  //using a trick here to get this record inserted into the recentlyviewed table that SF maintains
  	  PageReference aPage = new ApexPages.StandardController(patient).view();
  	  if(!Test.isRunningTest())
        aPage.getContent();
  	  apexpages.currentpage().getparameters().put('ptid',apexpages.currentpage().getparameters().get('sptid'));
  	  consult_search_results = new List<Account>();
  	  display_patient_search_modal = false;
  	  //calling dosespot here to handle the possible update
  	  //check for patient id here 
      pr = Page.ccare_clinical_dosespot;
  	  pr.getparameters().put('ptid',apexpages.currentpage().getparameters().get('sptid'));
  	  pr.getparameters().put('ctrid',current_center.id);
  	  pr.setredirect(true);         
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the patient record.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return pr;
  	}
  	try {
  	  Dosespot dosespot = new DoseSpot(patient.id,current_center);             
      dosespot.DoseSpot_patient_URL();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to setup dosespot for this patient.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return pr;
  	}  
  	return pr;
  }
  
  public void getpatient_record(String patient_id,String center_id) {
    patient = [select id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,emergency_contact_name__c,emergency_contact_phone__c,
      clinical_notes__c,isPersonAccount,firstname,lastname,date_of_birth__c,PersonContactId,main_photo_id__c
      from Account where id = :patient_id and center__c in :market_centers];
  }
    
  public void open_patient_search() {
  	display_patient_search_modal = true;
  	search_name = '';
  	search_first = '';
  	search_unique = '';
  	search_phone = '';
  	search_email = ''; 
  	consult_search_results = new List<Account>();
  }
  
  public void more_patient_records() {
  	num_patient_records += 20;
  	search_consult_records();
  }
  
  public void close_patient_search() {
  	display_patient_search_modal = false;
  }
  
  global class response_parse {
    public Boolean is_ok;
    public String message;
    public map<string,string> data;
  }
  
  public Integer getdosespot_notification_count() {
  	Integer error_count = 0;  	
  	ds_refill_errors = 0;
  	ds_trans_errors = 0;
  	try {  	  	  
  	  /*DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
      Map<String,Object> amap = (Map<String,object>)dres.data;
      error_count += Integer.valueof(amap.get('refillRequestCount'));
      error_count += Integer.valueof(amap.get('transmissionErrorCount'));*/
      //build a list of the clinician ids we need to check
      //staff_errors = new List<clinician_errors>();
      
      Set<Integer> all_clinician_ids = new Set<Integer>();
  	  Map<Integer,User> clinician_map = new Map<Integer,User>();
  	  for(User u : [select u.id,u.DoseSpot_User_ID__c,u.name from User u 
  	    where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name
  	    and u.dosespot_user_id__c != null ]) {  		
  	    all_clinician_ids.add(Integer.valueof(u.dosespot_user_id__c));
  	    clinician_map.put(Integer.valueof(u.dosespot_user_id__c),u);
  	  } 
  	  //shouldn't happen in production,  but I'm leaving this in place here for the test environment and initial setup circumstances
  	  if(all_clinician_ids.size()==0) {
  	    DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
        Map<String,Object> amap = (Map<String,object>)dres.data;
        error_count += Integer.valueof(amap.get('refillRequestCount'));
        error_count += Integer.valueof(amap.get('transmissionErrorCount'));
        if(amap.get('RefillsErrors')!=null)
          error_count += Integer.valueof(amap.get('RefillsErrors'));
  	  } else {
  	  	for(Integer clinician_id : all_clinician_ids) {
  	  	  /*DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors_by_clinician(current_center,clinician_id);
          Map<String,Object> amap = (Map<String,object>)dres.data;
          error_count += Integer.valueof(amap.get('refillRequestCount'));
          error_count += Integer.valueof(amap.get('transmissionErrorCount'));
          if(amap.get('RefillsErrors')!=null)
            error_count += Integer.valueof(amap.get('RefillsErrors'));*/
          Integer rerrors = 0;
          DoseSpotServices.Response dres = DosespotServices.notification_counts(current_center,String.valueof(clinician_id));
          Map<String,Object> amap = (Map<String,object>)dres.data;
          DS_refill_errors += Integer.valueof(amap.get('refillRequestCount'));
          rerrors += Integer.valueof(amap.get('refillRequestCount'));
          DS_trans_errors += Integer.valueof(amap.get('transmissionErrorCount'));
          DS_refill_errors += Integer.valueof(amap.get('pendingPrescriptionsCount'));          
          if(amap.get('RefillsErrors')!=null) {
            DS_refill_errors += Integer.valueof(amap.get('RefillsErrors'));
            rerrors += Integer.valueof(amap.get('RefillsErrors'));
          }    
          error_count += rerrors;
          //staff_errors.add(new clinician_errors(clinician_map.get(clinician_id),rerrors,Integer.valueof(amap.get('transmissionErrorCount')),Integer.valueof(amap.get('pendingPrescriptionsCount'))   ));
  	  	}
  	  }        	  
      return error_count;    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return error_count;
  }
  
  
  public String getdosespot_notification_iframe_url() {
  	String return_url = '';
  	System.debug('Notification IFRAME');
  	try {
      Dosespot dosespot = new DoseSpot(current_center);      
      return_url = dosespot.refill_requests_and_transmission_errors_URL();      
                   
      /*if(patient!=null) {
  	    Dosespot dosespot = new DoseSpot(patient.id,current_center);
  	    return_url = dosespot.DoseSpot_patient_URL();
      } */     	
      
      return_url = return_url.replace('http:','https:');
      System.debug('Endpoint : ' + return_url);
      
      return return_url; 
    } catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return return_url;
  	}
  	return return_url;
  }
  
  public void patient_dosespot_id_check() {
  	try {
  	  if(patient!=null) {
  	    Dosespot dosespot = new DoseSpot(patient.id,current_center);             
        dosespot.DoseSpot_patient_URL();
  	  }               
    } catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  	
  }
  
  public String getdosespot_iframe_url() {
  	String return_url = '';
  	try {
  	  Dosespot dosespot = new DoseSpot(patient.id,current_center);             
      return_url = dosespot.DoseSpot_patient_URL();              
      return_url = return_url.replace('http:','https:');
      System.debug('Endpoint : ' + return_url);
      
      return return_url; 
    } catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return return_url;
  	}
  	return return_url;
  }
  
  public void toggle_trans_iframe() {
  	if(display_ds_error_iframe)
  	  display_ds_error_iframe = false;
  	else
  	  display_ds_error_iframe = true;
  }
}