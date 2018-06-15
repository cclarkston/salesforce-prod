public with sharing class dp_clinical_images {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  
  public Account patient {get;set;}
  public Boolean display_patient_search_modal {get; set;}
  public String search_name {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public List<Account> consult_search_results {get; set;}
  
  public Boolean confirmation_modal_display {get; set;}
  public String confirmation_modal_type {get; set;}
  public String modal_out {get; set;}
  
  public Boolean display_medical_warnings {get; set;}
  Set<ID> market_centers;
   
  public String search_first {get;set;}
  public String search_unique {get; set;}
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
    
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}
  
  public class bendException extends Exception {}	
  
    	//see if it's a corporate admin
  static {
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  }
  
  public Boolean allow_quick_search;
  public Boolean getallow_quick_search() {
  	if(allow_quick_search==null)
  	  allow_quick_search = [select id,Enable_Patient_Quick_Search__c from user where id = :userinfo.getuserid()].enable_patient_quick_search__c; 
  	return allow_quick_search;
  } 
    
  public dp_clinical_images() {
  	display_medical_warnings = true;
  	//User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];       	
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
            
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,icat_flex_center__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,	Windent_UNC_Path__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,icat_flex_center__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,	Windent_UNC_Path__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,icat_flex_center__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,	Windent_UNC_Path__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
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
  	
  	confirmation_modal_display = false;   
  	num_patient_records = 20;
    display_more_search_records = false;
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
  	else {
  	  //modifying this a bit,  now that we've added the user - center assignment table.  We need to pull a list of all centers in a market with the centers a user is tied to
  	  Set<ID> possible_markets = new Set<ID>();
  	  for(User_Center_Assignment__c uca : user_assignments) {
  	  	possible_markets.add(uca.center_information__r.market__c);
  	  }
  	  //ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c = :current_center.market__c order by name];
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c in :possible_markets order by name];
  	}
  	return ci_list;
  }
  
  public List<dp_clinical_common.hrx_navigation_link> getgear_menu() {return common_header.getnav_pages_by_name('Gear',current_center);}
  
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,icat_flex_center__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,Windent_UNC_Path__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
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
  
  public void close_patient_search() {
  	display_patient_search_modal = false;
  }
  
  public void more_patient_records() {
  	num_patient_records += 20;
  	search_consult_records();
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
  
  public Integer getsearch_result_size() {
  	return consult_search_results.size();
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
  	  display_medical_warnings = true;  
      pr = Page.ccare_clinical_images;
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
  
  public Boolean getpatient_record_selected() {
  	if(patient==null)
  	  return false;
  	else
  	  return true;
  }
  
  public Integer getnotification_size() {
  	return getpatient_notification_list().size();
  }

  public class patient_notification {
  	public String image_class {get; set;}
  	public String notification_text {get; set;}
  	public String notification_color {get; set;}
  	
  	public patient_notification(String image, String note_text, String note_color) {
  	  this.image_class = image;
  	  this.notification_text = note_text;
  	  this.notification_color = note_color;
  	} 
  }

  public List<patient_notification> getpatient_notification_list() {
  	List<patient_notification> all_notifications = new List<patient_notification> ();
  	//to-do: add in all possible patient notification messages for display here 
  	//adding medical clearances here
  	for(Medical_Clearance__c mc : [Select m.Requested_Via__c, m.Request_Status__c, m.Doctor_Specialty__c, m.Doctor_Name__c, m.Health_Condition__c, m.CreatedDate, m.Account__c 
  	  From Medical_Clearance__c m where account__c = :patient.id and request_status__c in ('Declined','Pending','Approved') and isactive__c = true]) {
  	  if(mc.request_status__c=='Pending')
  	    all_notifications.add(new patient_notification('ccf-error cc-font-light-16','Medical Clearance is pending for ' + mc.Health_Condition__c,'red'));
  	  else if(mc.request_status__c=='Declined')
  	    all_notifications.add(new patient_notification('ccf-error cc-font-light-16','Medical Clearance for ' + mc.Health_Condition__c + ' was declined by ' + mc.doctor_name__c,'red'));
  	  else if(mc.request_status__c=='Approved')
  	    all_notifications.add(new patient_notification('ccf-ok cc-font-light-16 cc-green','Medical Clearance for ' + mc.Health_Condition__c + ' was approved','#39b17f'));
  	}
  	//add a line for allergies if the patient has any
  	String allergy_line = '';
  	String prefix_char = '';
  	for(Allergy__c a : [select name from Allergy__c where patient__c = :patient.id]) {
  	  allergy_line += prefix_char + a.name;
  	  prefix_char = ',';
  	}
  	if(allergy_line!='') 
  	  all_notifications.add(new patient_notification('ccf-pill cc-font-light-16','Allergy Alert : ' + allergy_line,'red'));
  	//add staff created notifications
  	for(Note n : [select id,body,title from Note where title = 'Patient Notification' and parentid = :patient.id]) {
      all_notifications.add(new patient_notification('ccf-emergency cc-font-light-16',n.body,'red'));
  	}    	 
  	return all_notifications;
  }

  public void close_medical_warnings() {
  	display_medical_warnings = false;
  }
   
  public void close_confirmation_modal() {
  	confirmation_modal_display = false;
  }     
  
  public String getdexis_patient_id() {
  	//need to figure out the logic here....this should return either a sf id or possible a windent id.    	
  	String return_id = String.valueof(patient.id).right(12);
  	//pull a list of opportunities for this account and see if we have a patient id  	
  	if(current_center.Use_Windent_ID_for_Dexis_when_possible__c) {
	  for(Opportunity o : [select id,	Windent_Patient_Id__c, Unique_Windent_ID__c from Opportunity where accountid = :patient.id]) {
	    if(o.windent_patient_id__c!=null) {
	      return_id = String.valueof(o.windent_patient_id__c).right(12);
	      while(return_id.length()<6) {
	    	return_id = '0' + return_id;
	      }
	    }
	  }  	 
  	}
  	return return_id;
  }
  
  public Boolean getdisplay_icat() {
  	return current_center.icat_flex_center__c;
  	//Set<String> icat_flex_centers = new Set<String> {'Denver','Dallas Arlington'};
  	//if(icat_flex_centers.contains(current_center.name))
  	  //return true;
  	//else
  	  //return false;
  }
  
  public String getpatient_formatted_dob() {
  	String return_val = '';
    if(patient.date_of_birth__c!=null) {
  	  Datetime dob = Datetime.newinstance(patient.date_of_birth__c,Time.newinstance(0,0,0,0));  	
  	  return_val = dob.format('M/dd/yyyy');
    }
    return return_val;
  }
  
  public String geticat_page_header() {
  	return patient.firstname.left(1) + ' ' + patient.lastname.left(3);
  }
  
  public Integer getdosespot_notification_count() {
  	Integer error_count = 0;  	
  	try {  	
  	  /*DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
      Map<String,Object> amap = (Map<String,object>)dres.data;
      error_count += Integer.valueof(amap.get('refillRequestCount'));
      error_count += Integer.valueof(amap.get('transmissionErrorCount'));*/
      //build a list of the clinician ids we need to check
  	  Set<Integer> all_clinician_ids = new Set<Integer>();
  	  for(User u : [select u.id,u.DoseSpot_User_ID__c from User u 
  	    where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name
  	    and u.dosespot_user_id__c != null ]) {  		
  	    all_clinician_ids.add(Integer.valueof(u.dosespot_user_id__c));
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
          DoseSpotServices.Response dres = DosespotServices.notification_counts(current_center,String.valueof(clinician_id));
          Map<String,Object> amap = (Map<String,object>)dres.data;
          error_count += Integer.valueof(amap.get('refillRequestCount'));
          error_count += Integer.valueof(amap.get('transmissionErrorCount'));
          error_count += Integer.valueof(amap.get('pendingPrescriptionsCount'));          
          if(amap.get('RefillsErrors')!=null)
            error_count += Integer.valueof(amap.get('RefillsErrors'));
  	  	}
  	  }  	  
      return error_count;    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return error_count;
  }
    
  public String getwindent_attachment_path() {
    /*String return_html = '';
    if(current_center.windent_unc_path__c!='') {
      for(Opportunity o : [select id,	Windent_Patient_Id__c, Unique_Windent_ID__c from Opportunity where accountid = :patient.id and windent_patient_id__c != null]) {	  
	    String return_id = String.valueof(o.windent_patient_id__c).right(12);
	    while(return_id.length()<6) {
	      return_id = '0' + return_id;
	    }
	    return_id = current_center.windent_unc_path__c + '/' + return_id;
	    return_html += '<a href="file:///' + return_id + '" target="_blank">Windent Attachments (' + return_id + ')</a><br /><br />';
      }	
    } 
    return return_html;*/
    String return_html = '';
    if(current_center.windent_unc_path__c!='') {
      for(Opportunity o : [select id,	Windent_Patient_Id__c, Unique_Windent_ID__c from Opportunity where accountid = :patient.id and windent_patient_id__c != null]) {	  
	    String return_id = String.valueof(o.windent_patient_id__c).right(12);
	    while(return_id.length()<6) {
	      return_id = '0' + return_id;
	    }
	    //return_id = current_center.windent_unc_path__c + '\\' + return_id;
	    return_html += current_center.windent_unc_path__c + '\\' + return_id + '<br /><br />';
	    if(current_center.name=='Atlanta') {
	      return_html += current_center.windent_unc_path__c.replace('images','letters') + '\\' + return_id + '<br /><br />';
	    }
      }	
    } 
    
    if(return_html!='')
      return_html = '<h3>To view Windent attachments,  please copy the link below and paste it into a new browser window</h3><br /><br />' + return_html;
    return return_html;
  }
  
  public String getclean_first() {
  	return getclean_dexis_value(patient.firstname);
  }
  
  public String getclean_last() {
  	return getclean_dexis_value(patient.lastname);
  }
  
  public String getclean_dexis_value(String svalue) {
  	String cleaned_string = svalue;
  	Set<String> replacement_targets = new Set<String> {' ','(',')','.','"','\''};
  	for(String target : replacement_targets) {
  	  cleaned_string = cleaned_string.replace(target,'');
  	}
  	return cleaned_string;
  }
}