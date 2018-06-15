public with sharing class dp_clinical_notes_safe {
  public Center_Information__c current_center {get; set;}
  
  public Account patient {get;set;}
  public Boolean display_patient_search_modal {get; set;}
  public String search_name {get;set;}
  public String search_first {get;set;}
  public String search_phone {get;set;}
  public String search_unique {get; set;}
  public String search_email {get; set;}
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  public List<Account> consult_search_results {get; set;}
  
  public Boolean has_legacy_notes {get; set;}
  public Boolean display_legacy_notes {get; set;}
  public String legacy_notes_sort_direction {get; set;}
  
  public transient String photo_data {get;set;}
  public transient String photo_content_type {get;set;}
  public transient String photo_name {get;set;}
  
  public Boolean display_follow_up_form {get; set;}
  public String current_note_edit_id {get; set;}
  public Win_Cnote_Import__c follow_up_note_dml {get; set;}
  
  //stuff for variable tooth selection  
  public String target_field {get; set;}
  public String tooth_chart_label {get; set;}
  public Boolean display_var_tooth_modal {get; set;}
  
  public Boolean uncomitted_changes {get; set;}
  public String confirmation_id {get; set;}
  
  public Boolean confirmation_modal_display {get; set;}
  public String confirmation_modal_type {get; set;}
  public String modal_out {get; set;}
 
  public Boolean display_attachment_form {get; set;}
  public Attachment new_note_attachment {get; set;} 
 
  public Patient_Health_History__c phhistory {get; set;}
 
  static String profile_name = [select name from profile where id = :userinfo.getprofileid()].name;
  
  public String display_type {get;set;}
    
  public class bendException extends Exception {}	 
  
  public Boolean display_medical_warnings {get; set;}
  
  static Set<String> doctor_profiles = new set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  Set<ID> market_centers;
  
  public dp_clinical_notes_new.apt_form viewed_form {get;set;}
  
  public Boolean display_new_med_form {get; set;}
  public Medication__c new_medication {get; set;}
  public String current_edit_id {get; set;}
  
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();} 
   
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  static public Boolean display_corp_admin {get; set;}
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
  
  public dp_clinical_notes_safe() {
  	has_legacy_notes = false;
  	display_legacy_notes = false;
  	display_type = 'summary';
  	display_medical_warnings = true;       	
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {            
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
  	  	
  	num_patient_records = 20;
  	confirmation_modal_display = false;  
  	uncomitted_changes = false;
  	display_new_med_form = false;
  	legacy_notes_sort_direction = 'desc';
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
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  market_centers = getcenters_in_market();   
  	  patient = null;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }  
  
  public Pagereference confirm_navigate_to() {
  	//user has decided to press ahead with unsaved changes - woe is them
  	uncomitted_changes = false;
  	return navigate_to();
  }
  
  public PageReference nav_to_exception() {
  	PageReference pr = Page.ccare_exception_case_notes;
  	pr.getParameters().put('ctrid',current_center.id);    
  	pr.setredirect(true);  	      
  	return pr;  	        	
  }
  
  public PageReference navigate_to() {
  	PageReference pr;
  	if(uncomitted_changes) {
  	  confirmation_modal_display = true;
  	  modal_out = 'You might have unsaved changes on this page.  Are you sure you wish to continue?';
  	  confirmation_modal_type = 'confirm_navigate';
  	  confirmation_id = apexpages.currentpage().getparameters().get('navid');
  	  return null; 
  	}  	
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
  
  public void getpatient_record(String patient_id,String center_id) {
    patient = [select id,name,date_of_birth__c,gender__c,recent_height_feet__c,recent_height_inches__c from Account where id = :patient_id and center__c in :market_centers];
    check_for_legacy_notes();
    try {      
      phhistory = [select id,Is_Complete__c,edit_link__c,Review_Page_Link__c from patient_health_history__c where account__c = :patient.id order by createddate desc limit 1];           
    } catch (Exception e) {
      //not an issue - there is no health history file
      phhistory = null;
    } 
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
  
  public PageReference navigate_to_recent_patient() {  	  	
    return common_header.pref_to_patient(current_center,apexpages.currentpage().getparameters().get('recentid'));  	  	
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
      System.debug('Query filter : ' + query_filter);
      System.debug('Num Patient Records : ' + num_patient_records);
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
  	  display_medical_warnings = true;
  	  consult_search_results = new List<Account>();
  	  display_patient_search_modal = false;
  	  Navigation_Page__c notes_page = [select id,alt_page_url__c, page_url__c, name from Navigation_Page__c where name = 'Notes'];  	 
  	  pr = new Pagereference(current_center.use_alternate_url__c?notes_page.Alt_Page_URL__c:notes_page.page_url__c);
  	  pr.getparameters().put('ptid',apexpages.currentpage().getparameters().get('sptid'));
  	  pr.getparameters().put('ctrid',current_center.id);
  	  pr.setredirect(true);
  	} catch (Exception e) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the patient record.  Please contact IT for help'));
      ApexPages.addMessages(e);
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
  
  public List<dp_clinical_notes_new.link_select_option> getselect_nav_links() {
  	List<dp_clinical_notes_new.link_select_option> select_list = new List<dp_clinical_notes_new.link_select_option>();
  	for(patient_apt pa : getpatient_apt_list()) {
  	  if(pa.notes.size()==0) {
  	  	dp_clinical_notes_new.link_select_option so = new dp_clinical_notes_new.link_select_option((pa.pot_apt==null?'badlink':pa.pot_apt.name),'link_' + (pa.pot_apt==null?'badlink':pa.pot_apt.id));
  	    select_list.add(so);
  	  } else {
  	  	Integer rev_cnt = 0;
  	  	for(note_instance_min note : pa.notes) {
  	  	  String lname = pa.pot_apt.name;
  	  	  if(rev_cnt >0)
  	  	    lname += ' - Revision ' + rev_cnt;
  	  	  dp_clinical_notes_new.link_select_option so = new dp_clinical_notes_new.link_select_option(lname,'link_' + (note.note.id==null?'badlink':note.note.id));
  	  	  rev_cnt++;
  	  	  select_list.add(so);
  	  	}
  	  }
  	}
  	/*//loop through patient apts
  	for(clinical_apt ca : patient_apts) {
  	  if(ca.standard_forms.size()==0) {
  	    //create a link for the holder row
  	    link_select_option so = new link_select_option((ca.pot_apt==null?'badlink':ca.pot_apt.name),'link_' + (ca.pot_apt==null?'badlink':ca.pot_apt.id));
  	    select_list.add(so);
  	  } else {
  	  	//loop through standard forms
  	  	Integer rev_count = 0;
  	  	for(apt_form af : ca.standard_forms) {
  	  	  String lname = ca.pot_apt.name;
  	  	  if(rev_count>0)
  	  	    lname += ' - Revision ' + rev_count;
  	  	  link_select_option so = new link_select_option(lname,'link_' + (af.cnote==null?'badlink':af.cnote.id));
  	  	  rev_count++;
  	  	  select_list.add(so);
  	  	}   	  	
  	  }
  	}*/
  	return select_list;
  }
  
  public List<patient_apt> getpatient_apt_list() {
  	//build our list and return it for summary display
  	List<patient_apt> all_patient_apts = new List<patient_apt>();
  	
  	Map<Id,patient_apt> patient_apt_map = new Map<ID,patient_apt>();
  	
  	if(patient!=null)
  	try {
  		
  	  for(Patient_POT_apt__c pa : [Select p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.Id, p.Doctor_Notes__c, p.Days_Out__c, 
  	    p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, patient_pot__r.name 
  	    From Patient_POT_Apt__c p 
  	    where isactive__c = true and patient_pot__r.account__c = :patient.id  
  	    order by patient_pot__c, sort_order__c]) {
  	    patient_apt c = new patient_apt(pa);
  	    patient_apt_map.put(pa.id,c);  
  	    all_patient_apts.add(c);
  	  }  	  
  	   
  	  //grab calendar records
  	  for(Clinical_Apt_Calendar__c ca : [Select c.id,c.Patient_POT_Apt__c, apt_date__c, patient_pot_apt__r.name, apt_status__c
  	    From Clinical_Apt_Calendar__c c where account__c = :patient.id order by apt_date__c]) {
  	    if(patient_apt_map.get(ca.patient_pot_apt__c)!=null)
  	      patient_apt_map.get(ca.patient_pot_apt__c).apt = ca;  	
  	  }
  	
  	  //grab clinical note instances
  	  for(Clinical_Note_Instance__c cni : [Select lastmodifiedby.name, lastmodifieddate, c.Review_Time__c, c.id, c.Reviewed_By__c, c.reviewed_by__r.name, c.Patient_POT_Apt__c, 
  	    c.IsActive__c, c.CreatedDate, c.CreatedBy.name, c.Clinical_Apt_Calendar__c, c.Apt_Note__c, c.Account__c, Patient_POT_Apt__r.clinical_appointment__c
  	    From Clinical_Note_Instance__c c where account__c = :patient.id order by createddate]) {  	    
  	    if(patient_apt_map.get(cni.patient_pot_apt__c)!=null)
  	      patient_apt_map.get(cni.patient_pot_apt__c).notes.add(new note_instance_min(cni));
  	  }
  	} catch (Exception e) {
  		
  	} 
  	
  	return all_patient_apts;
  }
  
  public class note_instance_min {
  	public Clinical_Note_Instance__c note {get;set;}
  	
  	public note_instance_min(Clinical_Note_Instance__c cni) {
  	  this.note = cni;
  	}
  	
  	public Boolean getisform_editable() {  	
  	  //check to see if it's been 24 hours since the form was created (apt started for initial form)
  	  //time was adjusted to 48 hours per Andy McMullen - 4/26/2017 CM
  	  //Datetime dt = (Datetime)form.get('createddate');
  	  Datetime dt = note.createddate; 
  	  if(dt.addhours(48)<System.now())
  	    return false;
  	  //check to see if the note was reviewed by a doctor - if so it's locked
  	  else if(note.reviewed_by__c!=null)
  	    return false;
  	  //check to make sure this form is the active one for the apt - otherwise it's locked,  regardless of age
  	  //else if((Boolean)form.get('isactive__c'))
  	  else if(note.isactive__c)
  	    return true;
  	  else
  	    return false;
  	}
  }
  
  public class patient_apt {
  	public Patient_POT_Apt__c pot_apt {get;set;}
  	public Clinical_Apt_Calendar__c apt {get; set;}
  	public note_instance_min[] notes {get; set;}
  	
    public patient_apt(Patient_POT_Apt__c p) {
      this.pot_apt = p;	
      this.notes = new note_instance_min[] {};
      this.apt = null;
    }
    
    public note_instance_min getmost_recent_form() {
      Integer last_note_position = notes.size()-1;
      return notes[last_note_position];    	
      /*Clinical_Note_Instance__c last_note;
      for(Clinical_Note_Instance__c note : notes) {
      	last_note = note;
      }
      return last_note;*/
    }
  	  	
  	public String getholder_second_line() {
  	  String second_line = 'Not Scheduled';
  	  if(apt!=null) {
  	  	Datetime dt = Datetime.newinstance(apt.apt_date__c.year(),apt.apt_date__c.month(),apt.apt_date__c.day());
  	    second_line = '<i class="ccf-clock" ></i>&nbsp;' + dt.format('M/dd/yyyy');
  	  }
  	  return second_line;
  	}
  	
    public Integer getnum_notes_instances() {
      return notes.size();
    } 
  }
  
  public void close_displayed_form() {
  	display_type = 'summary';
  	//clear_uncomitted_changes(viewed_form);
  	//unload_form_values(viewed_form);
  }
  
  public void open_collapsed_form() {
  	display_type = 'detail';
    viewed_form = load_form_values(apexpages.currentpage().getparameters().get('noteid'));
    viewed_form.toggle_collapse();
  	clear_uncomitted_changes();       	  	 	  	
  }
  
  public void clear_uncomitted_changes() {
  	try {
  	  if(viewed_form.form!=null) {
  	    List<Uncomitted_Form_Change__c> ucf_list = [select id from Uncomitted_Form_Change__c where vf_page__c = 'Notes' and form_id__c = :viewed_form.form.id and createdbyid = :userinfo.getuserid()];
  	    if(ucf_list.size()>0)
  	      delete ucf_list;
  	  }
  	  if(viewed_form.all_implants.size()>0) {
  	  	Set<ID> implant_ids = new Set<ID> ();
  	  	for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
  	  	  implant_ids.add(iw.imp.id);
  	  	}  	  	
  	  	//Map<ID,Surgical_Note_Implant__c> implant_map = new Map<ID,Surgical_Note_Implant__c> (viewed_form.all_implants);  	  
  	    //check for any changes to these implants
  	    //list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c in :implant_map.keyset()
  	      //and createdbyid = :userinfo.getuserid() and vf_page__c = 'Notes'];
  	    list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c in :implant_ids
  	      and createdbyid = :userinfo.getuserid() and vf_page__c = 'Notes'];
  	    if(ucf_list.size()>0)
  	      delete ucf_list;  
  	  }
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove form state data.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public dp_clinical_notes_new.apt_form load_form_values(String note_id) {
  	  	
  	//build a map of custom notes tied to apt types,  so we can use it
  	Map<ID,List<Custom_Clinical_Note__c>> apt_to_note_map = new Map<ID,List<Custom_Clinical_Note__c>>();
  	Map<ID,Custom_Clinical_Note__c> custom_note_map = new Map<ID,Custom_Clinical_Note__c> ([select c.Note_Text__c, c.Name, c.Id, c.Center_Information__c,isactive__c from Custom_Clinical_Note__c c where center_information__c = :current_center.id]);
  	
  	for(Custom_Clinical_Note__c cn : [Select c.Note_Text__c, c.Name, c.Id, c.Center_Information__c, sort_order__c, isactive__c,
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Clinical_Appointment__c, Custom_Clinical_Note__c, custom_clinical_note__r.isactive__c From Custom_Clinical_Notes_by_Apt__r) 
  	  From Custom_Clinical_Note__c c where center_information__c= :current_center.id order by sort_order__c]) {
  	  //is the apt used for any apts?
  	  if(cn.Custom_Clinical_Notes_by_Apt__r.size()>0) {
  	  	for(Custom_Clinical_Note_by_Apt__c cna : cn.custom_clinical_notes_by_apt__r) {
  	  	  if(apt_to_note_map.get(cna.clinical_appointment__c)==null) {
  	  	    apt_to_note_map.put(cna.clinical_appointment__c,new List<Custom_Clinical_Note__c> {cn});
  	      } else {
  	  	    apt_to_note_map.get(cna.clinical_appointment__c).add(cn);
  	      }
  	  	}
  	  }  	  
  	}
  	
  	Set<ID> sform_ids = new Set<ID>();
  	
  	System.debug('Pulling related records for second level');
  	//pull clinical notes instances and build second level class - just pulling a single record now  	  	
  	Clinical_Note_Instance__c cni = [Select lastmodifiedby.name, lastmodifieddate, c.Review_Time__c, c.id, c.Reviewed_By__c, c.reviewed_by__r.name, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name, c.IsActive__c, c.CreatedDate, c.CreatedBy.name, c.Clinical_Apt_Calendar__c, c.clinical_apt_calendar__r.apt_date__c, c.Apt_Note__c, c.Account__c, Patient_POT_Apt__r.clinical_appointment__c,
  	  (Select bmi_calc__c,height_feet__c,height_inches__c,post_op_general_condition__c,post_op_mental_status__c,post_op_pain_management__c,post_op_hematosis__c,avoiding_strenuous_activity__c,ambulating_without_assistance__c,post_op_oral_intake__c,post_op_general_condition_notes__c,post_op_mental_status_notes__c,
  	    responsible_adult_driver__c,post_op_pulse__c,post_op_pulse_ox__c,post_op_bp_diastolic__c,post_op_bp_systolic__c,post_op_instructions_reviewed__c,sinus_communication_notes__c,sinus_communication_right__c,sinus_communication_left__c,sutures_other__c,sinus_lift_right_max__c,sinus_lift_left_max__c,sinus_lift_right_max_type__c,sinus_lift_left_max_type__c,Procedure_Site_Confirmed__c,Medical_History_Reviewed__c,Denies_Pregnancy__c,Pre_op_medications_given__c,NPO_Confirmed__c,Radiographs_Available_and_up_to_date__c,Consent_Accurate_and_Signed__c,Patient_Examined_Heart_Lungs__c,Monitors_in_place__c,
        Emergency_Cart_Ready__c,STO_Procedure_Consent_Confirmed__c,weight__c,pre_op_notes__c,asa__c,Pre_Op_Pulse_Ox__c,Pre_Op_Pulse__c,Pre_Op_BP_Systolic__c,pre_op_BP_Diastolic__c,Post_Op_Care_Comments__c, Bone_Graft_Material_Multi__c, Bone_Graft_Material_Note__c,flap_design__c,Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Procedure_Verified__c, Vital_Signs__c, Lidocaine__c, lidocaine_50__c, local_anesthetic_other__c, sedation_other__c, sedation_used__c, sutures__c, Marcaine__c, Septocaine__c, Fentanyl__c, Versed__c, Ketamine__c, Propofol__c, Morphine__c, Envelope__c, Blade_Num__c, Releasing_Incision__c, Buccal_hockey_stick__c, Extractions__c, Alveolectomy__c, Alveolectomy_Amount__c, Alveolectomy_Leveling__c, Betadine__c, Assistants__c, Implant_System__c, Implant_System_Other__c, Implant_Tooth_Position__c, Findings_Complications__c, Discussed_Oral_Hygiene__c, Reviewed_Soft_Food_Diet__c, Interim_Night_Guard_Delivered__c, Bone_Graft_Area__c, Bone_Graft_Type__c, Bone_Graft_Material__c, Bone_Graft_Harvest_Site__c, Sinus_Communication__c, Lateral_sinus_corticotomies__c, Buccal_cortex_intact__c, Lingual_cortex_intact__c, Post_Op_Instruction_Given__c, Icepack_Placed__c, Post_operative_nausea__c, Post_Operative_Pain_Controlled__c, Post_operative_bleeding_controlled__c, Re_anesthetized__c, Post_Surgery_Lidocaine__c, Post_Surgery_MarCaine__c, Post_Surgery_Septocaine__c, Prosth_Screw_Torque_Value__c, Confirmation_Radiography__c, Impression_material_used__c, Placed_seals_using__c, Occlusal_Adjustment__c, IsActive__c, Clinical_Apt_Calendar__c, Account__c,
        Ibuprofin__c, Dexamethasone__c, Benadryl__c, Carbocaine__c,implant_type__c         
  	    From Surgical_Notes_Forms__r order by createddate),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, Hygiene_Grade__c, Tissue_Grade__c, Cantilever_length__c, AP_Spread__c, IsActive__c From Final_Notes_Forms__r),  
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, Confirmation_Radiography__c, Cantilever_Length__c, AP_Spread__c, Implant_Tooth_Position__c, IsActive__c,Upper_AP_Spread__c, UR_Cantilever_Length__c, UL_Cantilever_Length__c, Lower_AP_Spread__c, LR_Cantilever_Length__c, LL_Cantilever_Length__c From Conversion_Notes_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, Occlusal_Adjustment__c, Discussed_Hygiene__c, Reviewed_Soft_Diet__c, Interim_Night_Guard_Delivered__c, IsActive__c From Interim_Delivery_Notes_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, Confirmation_Radiography__c, Hygiene_Grade__c, Tissue_Grade__c, IsActive__c From JIG_Notes_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, Healing_in_normal_limits__c, IsActive__c From Post_OP_Notes_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, Try_In_Type__c, IsActive__c From Try_In_Notes_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, BP_Systolic__c, BP_Diastolic__c, Pulse__c, Pulse_Ox__c, Weight__c, TMJ_stable_wnl__c, TMJ_pop_click_right__c, TMJ_pop_click_left__c, TMJ_max_opening__c, Periodontal_Type__c, Tissue_Max__c, Tissue_Mand__c, Hard_Soft_WNL__c, Hard_Soft_RRR__c,  OCS_Neg__c, OCS_Pos__c, Occlusion_Dental__c, Occlusion_Skeletal__c, Occlusion_Plane__c, Occlusion_Hyper_Eruption__c, Occlusion_Attrition__c, Occlusion_OJ__c, Occlusion_OB__c, Existing_Pros_Max__c, Existing_Prosth_Mand__c, Dentofacial_WNL__c, Dentofacial_Max_Direction__c, Dentofacial_Max_Amount__c, Dentofacial_Mand_Direction__c, Dentofacial_Mand_Amount__c, Smile_Line__c, Radiology_WNL__c, Radiology_Other__c, Mobility__c, AO4_Bone_Reduction_Max__c, AO4_bone_Reduction_Mand__c, Bone_Loss__c, Bone_Loss_Percent__c, Bone_Loss_Area__c, Tooth_Shade__c, Tooth_Mould__c, Account__c, Chief_Complaint__c, Perio_Chart__c, isactive__c, Existing_Prosth_Max_Type__c, Existing_Prosth_Mand_Type__c, Height_Feet__c, Height_Inches__c, BMI__c, TMJ_Notes__c, Hard_Soft_Max_RRR__c, Hard_Soft_Mand_RRR__c, Comments__c, Temperature__c, Condition__c, Crepitus__c, Deviations__c, Muscles_of_mastication_WNL__c, Tissue_Color__c, Tissue_Consistency__c, Tissue_Texture__c, Lip_Length__c, Lip_Fullness__c, At_Rest__c, In_Motion__c, Restorative_Prognosis__c, R_Upon_Opening_ROM__c, R_Upon_Closing_ROM__c, L_Upon_Opening_ROM__c, L_Upon_Closing_ROM__c, OCS_Lymph__c, OCS_Lymph_Location__c, OCS_Swelling__c, OCS_Swelling_Location__c, OCS_Asymmetry__c, OCS_Asymmetry_Location__c, OCS_Other__c, OCS_Other_Text__c, Height_Total_Inches__c, BMI_Calc__c, Tissue_Notes__c, Mobility_Notes__c, Range_of_Motion__c, Smile_Line_Notes__c, Surgical_Reduction_Notes__c, Bone_Loss_Notes__c, Reported_Bruxism__c, Evidence_of_Bruxism__c, Abrasion_Location__c, Abrasion_Severity__c, Attrition_Location__c, Attrition_Severity__c, Erosion_Location__c, Erosion_Severity__c, Physiological_Location__c, Physiological_Severity__c, Tooth_Surface_Notes__c, How_long_missing_teeth__c, FMX__c, iCAT__c, Panorex__c, Photographs__c, Image_Notes__c, Impressions__c, Facebow__c, Centric_Relation_Record__c, Records_Notes__c, Recession_Notes__c, Tooth_Shade_Other__c, Dry_Mouth__c, Salivary_Other__c, Clinical_Note_Instance__c, Clinical_Apt_Calendar__c, existing_prosth_notes__c, recession__c From Prosth_Exam_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, IsActive__c, Redo_Type__c, Implant_Failure__c, Graft_Failure__c, Mechanical_Complication__c, Mechanical_Complication_Other__c, Biological_Complication__c, Biological_Complication_Other__c, Rerelate__c, Graft_Failure_Reason__c, Graft_Failure_Site__c, Graft_Failure_Reason_Other__c, Bone_Graft_Material__c, Bone_Graft_Material_Other__c,redo_type_other__c,Implant_Tooth_Position__c From Redo_Surgery_Forms__r),
  	  (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Repair_Apt_Type__c, Account__c, Clinical_Apt_Calendar__c, Clinical_Note_Instance__c, IsActive__c, Prosthesis_Type__c, Prosthesis_Type_Other__c, Requested_By__c, Prosthesis_Stage__c, Opposing_Arch__c, Age_of_Prosthesis_Years__c, Age_of_Prosthesis_Months__c, Time_in_Lab__c, Time_in_Lab_Minutes__c, Rework_Reason__c, Rework_Reason_Other__c, Repair_Reason__c, Repair_Reason_Other__c, Rework_Completed__c, Rework_Completed_Other__c, Prosthetic_Screw_Tightening_Location__c, Abutment_Screw_Tightening_Location__c, Repair_Work_Type__c, Repair_Work_Type_Other__c, Denture_Base_Fracture_Location__c, Tooth_Fracture_Location__c, Tooth_Debonding_Location__c, Bar_Fracture_Location__c, Prosthetic_Screw_Fracture_Location__c, Abutment_Screw_Fracture_Location__c, Abutment_Screw_Loosening_Location__c From Repair_Note_Forms__r),
  	  (Select Custom_Clinical_Note__c, Comments__c, custom_clinical_note__r.sort_order__c, Custom_Clinical_Note__r.isactive__c From Clinical_Note_Custom_Note__r order by custom_clinical_note__r.sort_order__c),
  	  (Select Id, Name, Description,parentid From Attachments) 
  	  From Clinical_Note_Instance__c c where id = :note_id];
  	  dp_clinical_notes_new.apt_form af = new dp_clinical_notes_new.apt_form(cni);
  	  //check for files
  	  if(cni.attachments.size()>0) {
  	  	for(Attachment a : cni.attachments) {
  	  	  af.all_files.add(a);
  	  	}
  	  }
  	  //check for forms
  	  //surgical standard form
      if(cni.surgical_notes_forms__r.size()>0) {
      	for(Surgical_Notes_form__c sn : cni.surgical_notes_forms__r) {
          sform_ids.add(sn.id);
      	  af.form = sn;
      	}
      }
      //final notes form
      if(cni.final_notes_forms__r.size()>0) {
      	for(Final_Notes_Form__c fn : cni.final_notes_forms__r) {
      	  sform_ids.add(fn.id);
      	  af.form = fn;
      	}
      }
      //Conversion notes form
      if(cni.conversion_notes_forms__r.size()>0) {
      	for(Conversion_Notes_Form__c cn : cni.conversion_notes_forms__r) {
      	  sform_ids.add(cn.id);
      	  af.form = cn;
      	}
      }
      //interim delivery notes form
      if(cni.interim_delivery_notes_forms__r.size()>0) {
      	for(Interim_Delivery_Notes_Form__c idn : cni.interim_delivery_notes_forms__r) {
      	  af.form = idn;
      	}
      }
      //jig notes form
      if(cni.jig_notes_forms__r.size()>0) {
      	for(Jig_Notes_Form__c jn : cni.jig_notes_forms__r) {
      	  af.form = jn;
      	  sform_ids.add(jn.id);
      	}
      }
      //Post Op Notes form
      if(cni.post_op_notes_forms__r.size()>0) {
        for(Post_op_notes_form__C pon : cni.post_op_notes_forms__r) {
          af.form = pon;
        }
      }
      //try in notes
      if(cni.try_in_notes_forms__r.size()>0) {
      	for(Try_In_Notes_Form__c tin : cni.try_in_notes_forms__r) {
      	  af.form = tin;
      	}
      }
      //prosth exam form
      if(cni.Prosth_Exam_Forms__r.size()>0) {
      	for(Prosth_Exam_Form__c pef : cni.prosth_exam_forms__r) {
      	  af.form = pef;
      	}
      }
      //redo surgery form
      if(cni.Redo_Surgery_Forms__r.size()>0) {
      	for(Redo_Surgery_Form__c rsf : cni.redo_surgery_forms__r) {
          af.form = rsf;
          sform_ids.add(rsf.id);
      	}
      }
      //redo surgery form
      if(cni.Repair_Note_Forms__r.size()>0) {
      	for(Repair_Note_Form__c rnf : cni.repair_note_forms__r) {
          af.form = rnf;
          sform_ids.add(rnf.id);
      	}
      }
      
      //add our standard custom notes for this apt type
      if(apt_to_note_map.get(cni.patient_pot_apt__r.clinical_appointment__c)!=null) {
        for(Custom_Clinical_Note__c cn : apt_to_note_map.get(cni.patient_pot_apt__r.clinical_appointment__c)) {
      	  dp_clinical_notes_new.clinic_note new_custom_note = new dp_clinical_notes_new.clinic_note(cn);
      	  //System.debug('Adding note : ' + cn);
      	  af.add_new_note(new_custom_note);
      	  //System.debug('Notes size : ' + af.custom_notes.size());
        }
      }
      //now work through the list of custom notes for this note instance and check for note matches
      if(cni.clinical_note_custom_note__r.size()>0) {
      	for(Clinical_Note_Custom_Note__c cncn : cni.clinical_note_custom_note__r) {
      	  //check for a match
      	  //System.debug('Check for a notes match : ' + cncn.custom_clinical_note__c);
      	  //System.debug('Map : ' + af.note_map);
      	  if(af.note_map.get(cncn.custom_clinical_note__c)==null) {
      	    //add a new custom new - this situation would occur when viewing an older note instance and a selected custom note was later removed from the appointment type
      	    dp_clinical_notes_new.clinic_note new_custom_note = new dp_clinical_notes_new.clinic_note(custom_note_map.get(cncn.custom_clinical_note__c));
      	    af.add_new_note(new_custom_note);
      	  } else {
      	  	af.note_map.get(cncn.custom_clinical_note__c).currently_selected = true;
      	  	af.note_map.get(cncn.custom_clinical_note__c).note_record = cncn;
      	  }      	  
      	}
      }   
      
    //grab our surgical note implants - if any
  	for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
  	  final_notes_form__c, final_notes_form__r.clinical_note_instance__c, final_notes_form__r.clinical_apt_calendar__c,
  	  conversion_notes_form__c, conversion_notes_form__r.clinical_note_instance__c, conversion_notes_form__r.clinical_apt_calendar__c,
  	  jig_notes_form__c, jig_notes_form__r.clinical_note_instance__c, jig_notes_form__r.clinical_apt_calendar__c, redo_surgery_form__c, 
  	  redo_surgery_form__r.clinical_apt_calendar__c, redo_surgery_form__r.clinical_note_instance__c, date_failure_observed__c, implant_system__c, implant_system_other__c
  	  From Surgical_Note_Implant__c s
  	  where surgical_notes_form__c in :sform_ids
  	    or final_notes_form__c in :sform_ids
  	    or conversion_notes_form__c in :sform_ids
  	    or jig_notes_form__c in :sform_ids
  	    or redo_surgery_form__c in :sform_ids
  	  order by s.Numerical_Name__c]) {
  	  System.debug('Adding implant');
  	  if(si.surgical_notes_form__c!=null)
  	    af.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.final_notes_form__c!=null)
  	    af.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.conversion_notes_form__c!=null)
  	    af.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.jig_notes_form__c!=null)
  	    af.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.redo_surgery_form__c!=null)
  	    af.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	}  	
  	
  	//grab medications administered
  	for(Medication__c med : [select id, amount_taken__c, route__c, generic_drug_name__c, status_notes__c, surgical_notes_form__c, surgical_notes_form__r.Clinical_Note_Instance__c, Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c 
  	  from Medication__c 
  	  where surgical_notes_form__c in :sform_ids]) {
  	  System.debug('Adding medication ' + med);
  	  af.all_medications.add(med);
  	}   	
  	system.debug('Template Type : ' + af.getform_template_name());
  	return af;            	
  }
  
  public Integer getmessage_size() {
  	return ApexPages.getMessages().size();
  }
  
  public void toggle_form_view() {
  	viewed_form.toggle_view();  	
  }
  
  public void confirm_clone_note() {   
  	viewed_form.confirm_css = ' clone_selection';
  	confirmation_id = viewed_form.cnote.id;
  	confirmation_modal_display = true;
  	modal_out = 'Please confirm you wish to clone this note';
  	confirmation_modal_type = 'clone_note';
  }
  
  public void clone_standard_form() {
  	//modified by cm on 5/24/2016 - using note instance and map to adjust now  	   	
  	try {
  	  //clone the note instance
  	  Clinical_Note_Instance__c new_note_instance = viewed_form.cnote.clone(false,true,false,false);
  	  new_note_instance.reviewed_by__c = null;
  	  new_note_instance.review_time__c = null;
  	  insert new_note_instance;
  	  new_note_instance = [Select lastmodifiedby.name, lastmodifieddate, c.Review_Time__c, c.id, c.Reviewed_By__c, c.reviewed_by__r.name, c.Patient_POT_Apt__c, c.IsActive__c, c.CreatedDate, c.CreatedBy.name, c.Clinical_Apt_Calendar__c, c.Apt_Note__c, c.Account__c, Patient_POT_Apt__r.clinical_appointment__c from Clinical_Note_instance__c c where c.id = :new_note_instance.id];
  	  dp_clinical_notes_new.apt_form new_viewed_form = new dp_clinical_notes_new.apt_form(new_note_instance);
  	  new_viewed_form.collapsed = false;
  	  viewed_form.collapsed = true;
  	  if(viewed_form.form!=null) {
  	    viewed_form.form.put('isactive__c',false);  	       
  	    update viewed_form.form;
  	  }
  	  viewed_form.cnote.isactive__c = false;
  	  update viewed_form.cnote; 
  	  //clone the form
  	  if(viewed_form.form!=null) {  	  
  	    sobject new_form = viewed_form.form.clone(false,false,false,false);
  	    new_form.put('clinical_note_instance__c',new_note_instance.id);   	  
  	    insert new_form;
  	    new_viewed_form.form = new_form;    	  
	  	  //is it form with implants?
	  	if(viewed_form.getform_template_name()=='surgical_notes_form' || viewed_form.getform_template_name()=='final_notes_form' ||
	  	  viewed_form.getform_template_name()=='conversion_notes_form' || viewed_form.getform_template_name()=='jig_notes_form'
	  	  || viewed_form.getform_template_name()=='redo_surgery_form') {
	  	  //clone the surgical implants
	  	  if(viewed_form.all_implants.size()>0) {
	  	  	List<Surgical_Note_Implant__c> implants_to_clone = new List<Surgical_Note_Implant__c>();
	  	  	for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
	  	      implants_to_clone.add(iw.imp);
	  	  	}	  	  		  	  	
	  	    //List<Surgical_Note_Implant__c> new_implants = af.all_implants.deepclone();
	  	    List<Surgical_Note_Implant__c> new_implants = implants_to_clone.deepclone();
	  	    for(Surgical_note_implant__c sn : new_implants) {
	  	  	  sn.surgical_notes_form__c = new_form.id;
	  	    }	  	    
	  	    insert new_implants;
	  	    //new_af.all_implants = new_implants;
	  	    for(Surgical_note_implant__c sn : new_implants) {
	  	      new_viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(sn));	  	  	  
	  	    }
	  	  }
	  	}
	  	//is it a standard surgery form
	  	if(viewed_form.getform_template_name()=='surgical_notes_form') {
	  	  //clone the medications info
	  	  if(viewed_form.all_medications.size()>0) {
	  	    List<Medication__c> new_medications = viewed_form.all_medications.deepclone();
	  	    for(Medication__c m : new_medications) {
	  	   	  m.surgical_notes_form__c = new_form.id;
	  	    }
	  	    insert new_medications;
	  	    new_viewed_form.all_medications = new_medications;
	  	  }
	  	}  	  	  	
  	  }
  	  
  	  //clone the attachments
  	  if(viewed_form.all_files.size()>0) {
  	  	//run a query to pull these so we have the body field
  	  	Map<ID,Attachment> att_map = new Map<Id, Attachment>(viewed_form.all_files);
  	  	Set<ID> att_id_set = att_map.keySet();
  	  	List<Attachment> old_attachments = [select Id, Name, Description,parentid, body from Attachment where id in :att_id_set];
  	  	List<Attachment> new_attach_list = old_attachments.deepclone();
  	  	for(Attachment a : new_attach_list) {
  	  	  a.parentid = new_note_instance.id;
  	  	}
  	  	insert new_attach_list;
  	  	new_viewed_form.all_files = new_attach_list;
  	  	
  	  	/*List<Attachment> new_attach_list = viewed_form.all_files.deepclone();
  	  	for(Attachment a : new_attach_list) {
  	  	  a.parentid = new_note_instance.id;
  	  	}
  	  	insert new_attach_list;
  	  	new_viewed_form.all_files = new_attach_list;*/
  	  }
  	  
  	  //clone the custom notes when ready
	  if(viewed_form.custom_notes.size()>0) {
	    List<Clinical_Note_Custom_Note__c> old_notes = new List<Clinical_Note_Custom_Note__c>();
	    for(dp_clinical_notes_new.clinic_note cn : viewed_form.custom_notes) {
	      dp_clinical_notes_new.clinic_note new_custom_note = new dp_clinical_notes_new.clinic_note(cn.custom_note);
	    	if(cn.currently_selected) {
	     	  old_notes.add(cn.note_record);
	     	  new_custom_note.currently_selected = true;
	    	}
	    	new_viewed_form.add_new_note(new_custom_note);	
	    }  	  	
	    //see if we need to clone note records
	    if(old_notes.size()>0) {
	      List<Clinical_Note_Custom_Note__c> new_notes = old_notes.deepclone();
	      System.debug('New Notes Clone - After : ' + new_notes);
	      for(Clinical_Note_Custom_Note__c cncn : new_notes) {
	        cncn.clinical_note_instance__c = new_note_instance.id;
	      }
	      insert new_notes;
	      //work through again and tie them to our clinic note records via the map
	      for(Clinical_Note_Custom_Note__c cncn : new_notes) {
	        new_viewed_form.note_map.get(cncn.custom_clinical_note__c).note_record = cncn;
	      }
	    }
	  }
  	    	  
  	  //instance_to_form_map.put(new_note_instance.id,new_af);
  	  //pot_to_apt_map.get(new_note_instance.patient_pot_apt__c).standard_forms.add(new_af); 	  
  	  modal_out = '';
  	  confirmation_modal_display = false;
  	  confirmation_id = null;
  	  viewed_form.confirm_css = '';  
  	  display_type = 'detail';
      viewed_form = load_form_values(new_note_instance.id);
      viewed_form.toggle_collapse();
  	  clear_uncomitted_changes();    	    	  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error cloning the form.  Please contact IT for help'));
	  ApexPages.addMessages(e);
  	}
  }
  
  public void save_standard_form() {
  	uncomitted_changes = false;  	 
  	try {
  	  //process any uncomitted changes
  	  list<Uncomitted_Form_Change__c> ucf_list;
  	  if(viewed_form.form!=null) {
  	  	//System.debug('Form id : ' + viewed_form.form.id);
  	    ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c = :viewed_form.form.id
  	      and createdbyid = :userinfo.getuserid() and vf_page__c = 'Notes']; 
  	    //System.debug('Processing ' + ucf_list.size() + ' form changes');
  	    for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	      if(ucf.field_type__c=='Boolean')
  	        viewed_form.form.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	      else
  	        viewed_form.form.put(ucf.field_name__c,ucf.field_value__c);  	
  	    }
  	    update viewed_form.form;
  	    if(ucf_list.size()>0)
  	      delete ucf_list;
  	      
  	    //if we have sugrical implants,  check for any uncomitted changes
	  	if(viewed_form.all_implants.size()>0) {
	      Map<ID,dp_clinical_notes_new.ImplantWrapper> implant_map = new Map<ID,dp_clinical_notes_new.ImplantWrapper> ();
	      for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
	      	implant_map.put(iw.imp.id,iw);
	      }
	  	  //Map<ID,Surgical_Note_Implant__c> implant_map = new Map<ID,Surgical_Note_Implant__c> (viewed_form.all_implants);  	  
	  	  //check for any changes to these implants
	  	  ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c in :implant_map.keyset()
	  	    and createdbyid = :userinfo.getuserid() and vf_page__c = 'Notes'];   	  
	  	  for(Uncomitted_Form_Change__c ucf : ucf_list) {
	  	  	if(implant_map.get(ucf.form_id__c)!=null) {
	  	  	  if(ucf.field_type__c=='Boolean')
	  	        implant_map.get(ucf.form_id__c).imp.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
	  	      else
	  	        implant_map.get(ucf.form_id__c).imp.put(ucf.field_name__c,ucf.field_value__c);
	  	  	}
	  	  }
	  	  List<Surgical_note_Implant__c> implant_update_list = new List<Surgical_note_implant__c>();
	  	  for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
	  	  	implant_update_list.add(iw.imp);
	  	  }
	  	  update implant_update_list;
	  	  //update viewed_form.all_implants;
	  	  if(ucf_list.size()>0)
  	        delete ucf_list;
	  	}
	  	 
  	  }   
  	    		  		
  	  if(viewed_form.form!=null) {   
  	    
  	    //if we have a standard surgical form - update the implants and medications as well
  	    if(viewed_form.form.getSObjectType()==Schema.Surgical_Notes_Form__c.getSObjectType()) {
  	  	  //if(viewed_form.all_implants.size()>0)
  	  	    //update viewed_form.all_implants;
  	  	  if(viewed_form.all_medications.size()>0)
  	  	    update viewed_form.all_medications;  	  	  
  	    }
  	    //if we have a final notes form,  conversion notes form,  or jig notes form - update implants
  	    if(viewed_form.form.getSObjectType()==Schema.Redo_Surgery_Form__c.getSObjectType() || viewed_form.form.getSObjectType()==Schema.Final_Notes_Form__c.getSObjectType() || viewed_form.form.getSObjectType()==Schema.Conversion_Notes_Form__c.getSObjectType() || viewed_form.form.getSObjectType()==Schema.JIG_Notes_Form__c.getSObjectType()) {
  	  	  if(viewed_form.all_implants.size()>0) {
  	  	    //update viewed_form.all_implants;
  	  	    List<Surgical_note_Implant__c> implant_update_list = new List<Surgical_note_implant__c>();
		  	for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
		  	  implant_update_list.add(iw.imp);
		  	}
		 	update implant_update_list;
  	  	  }
  	    }
  	  }
  	  
  	  //update the clinical note instance (standard note and review fields)
  	  update viewed_form.cnote;
  	  //when ready - update custom notes here
  	  //pull all records that are selected
  	  List<Clinical_Note_Custom_Note__c> custom_update_list = new List<Clinical_Note_Custom_Note__c>();
  	  for(dp_clinical_notes_new.clinic_note cn : viewed_form.custom_notes) {
  	  	if(cn.note_record!=null)
  	  	  custom_update_list.add(cn.note_record);
  	  }
  	  if(custom_update_list.size()>0)
  	    update custom_update_list;
  	    	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the clinical notes.  Please contact IT for help'));
	  ApexPages.addMessages(e);
  	}  	
  }
  
  public void confirm_reset_note() {  	   
  	viewed_form.confirm_css = ' reset_selection';
  	confirmation_id = viewed_form.cnote.id;
  	confirmation_modal_display = true;
  	modal_out = 'Please confirm that you want to reset this clinical note';
  	confirmation_modal_type = 'reset_note';
  }
  
  public void confirm_delete_note() {
  	uncomitted_changes = false;  	   
  	viewed_form.confirm_css = ' delete_selection';
  	confirmation_id = viewed_form.cnote.id;
  	confirmation_modal_display = true;
  	modal_out = 'Please confirm you wish to delete this note:';
  	confirmation_modal_type = 'trash_note';
  }
  
  public void trash_note_instance() {  	
  	viewed_form.confirm_css = '';
  	String ppa_id = viewed_form.cnote.patient_pot_apt__c;
  	try {
  	  //delete cnote
  	  delete viewed_form.cnote; 
  	  if(viewed_form.form!=null) {
  	  	//clear uncomitted changes
  	  	clear_uncomitted_changes(); 	  
  	    //delete form
  	    delete viewed_form.form;
  	  }
  	  //delete surgical implants if necessary
  	  if(viewed_form.all_implants.size()>0) {
  	    //delete viewed_form.all_implants;
  	    List<Surgical_Note_Implant__c> implants_to_delete = new List<Surgical_Note_Implant__c>();
	  	for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
	  	  implants_to_delete.add(iw.imp);
	  	}	
	  	delete implants_to_delete;
  	  }
  	  //delete medications if necessary
  	  if(viewed_form.all_medications.size()>0)
  	    delete viewed_form.all_medications;
  	  //delete attachments - I think this is a master detail relationship,  so it might not be needed
  	  if(viewed_form.all_files.size()>0)
  	    delete viewed_form.all_files;  	  
  	  //delete custom notes when ready
  	  List<Clinical_Note_Custom_Note__c> custom_delete_list = new List<Clinical_Note_Custom_Note__c>();  	  
  	  if(viewed_form.custom_notes.size()>0) {
  	  	for(dp_clinical_notes_new.clinic_note cn : viewed_form.custom_notes) {
  	  	  if(cn.note_record!=null)
  	  	    custom_delete_list.add(cn.note_record);
  	  	}
  	  }
  	  if(custom_delete_list.size()>0)
  	    delete custom_delete_list;
  	   	  
  	  //identify the note instance prior to this and pull it up with the map
  	  Clinical_note_instance__c prior_instance = [select id,isactive__c from Clinical_note_Instance__c where patient_pot_apt__C = :ppa_id order by createddate desc limit 1];
  	  dp_clinical_notes_new.apt_form last_viewed_form = load_form_values(prior_instance.id);
  	  //set the cnote isactive__c to true
  	  last_viewed_form.cnote.isactive__c = true;
  	  update last_viewed_form.cnote;
  	  if(last_viewed_form.form!=null) {
  	    //set the form isactive__c to true
  	    last_viewed_form.form.put('isactive__c',true);
  	    update last_viewed_form.form;
  	  }
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error deleting this note.  Please contact IT for help - ' + e.getlinenumber()));
	  ApexPages.addMessages(e);
  	}
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
  public void cancel_delete_note() {
  	if(viewed_form!=null)  	
  	  viewed_form.confirm_css = '';
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false; 	
  }
  
  public Component.Apex.Outputpanel getconfirmation_modal() {  	
  	Component.Apex.Outputpanel html_sub_two = new Component.Apex.Outputpanel(styleclass='cc-form-confirmTrash-button cc-form-confirmClone-button-confirm');  	
  	Component.Apex.OutputText html_sub_two_text = new Component.Apex.OutputText(escape=false);
  	if(confirmation_modal_type=='trash_note') {    
      html_sub_two.onclick = 'trash_note();';
      html_sub_two_text.value = 'Delete';
  	}
  	if(confirmation_modal_type=='clone_note') {      
      html_sub_two.onclick = 'clone_form();';
      html_sub_two_text.value = 'Clone';
  	}  	
  	if(confirmation_modal_type=='review_note') {
  	  html_sub_two.onclick = 'review_note(\'' + confirmation_id + '\');';
      html_sub_two_text.value = 'Reviewed';
      html_sub_two.style='background-color: rgba(25, 117, 210, 1);  color: white;';
  	} 
  	if(confirmation_modal_type=='reset_note') {    
      html_sub_two.onclick = 'reset_note();';
      html_sub_two_text.value = 'Reset';
  	}
  	if(confirmation_modal_type=='trash_med') {    
      html_sub_two.onclick = 'trash_med();';
      html_sub_two_text.value = 'Delete';
  	}
  	if(confirmation_modal_type=='trash_file') {    
      html_sub_two.onclick = 'trash_attachment();';
      html_sub_two_text.value = 'Delete';
  	}
  	if(confirmation_modal_type=='confirm_navigate') {    
      html_sub_two.onclick = 'confirm_nav_to(\'' + confirmation_id + '\');';
      html_sub_two_text.value = 'Leave Page';
  	}
  	if(confirmation_modal_type=='trash_follow_up') {    
      html_sub_two.onclick = 'remove_follow_up_note();';
      html_sub_two_text.value = 'Delete';
  	}
  	
  	html_sub_two.childcomponents.add(html_sub_two_text);  	
  	return html_sub_two;
  }
  
  public void doctor_review_note() {
  	try {	  	
	  //modified by cm on 4/19/2017 based on request from Andy McMullen - clicking doctor review should automatically save the related notes
	  save_standard_form();	  		  		  		  	
	  viewed_form.confirm_css = '';  
	  viewed_form.cnote.reviewed_by__c = Userinfo.getuserid();
	  viewed_form.cnote.review_time__c = System.now();
	  update viewed_form.cnote;
	  viewed_form = load_form_values(viewed_form.cnote.id);
	  //viewed_form.cnote = [Select lastmodifiedby.name, lastmodifieddate, c.Review_Time__c, c.id, c.Reviewed_By__c, c.reviewed_by__r.name, c.Patient_POT_Apt__c, c.IsActive__c, c.CreatedDate, c.CreatedBy.name, c.Clinical_Apt_Calendar__c, c.Apt_Note__c, c.Account__c, Patient_POT_Apt__r.clinical_appointment__c,Patient_POT_Apt__r.name from Clinical_Note_instance__c c where c.id = :viewed_form.cnote.id];  	
	  modal_out = null;
	  confirmation_modal_display = false;  	
	  confirmation_id = null;
  	} catch (Exception e) {
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();      
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','amcmullen@clearchoice.com'} );
      message.setSubject('HRX Notes - Doctor Review error');
      message.setHtmlbody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'<br />'+e.getStackTraceString()+'<br />' + 'Confirmation id : ' + confirmation_id + ' Passed ID : ' + apexpages.currentpage().getparameters().get('noteid'));
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
  	}
  }
  
  public void reset_standard_form() {
  	uncomitted_changes = false;
  	//modified by cm on 5/24/2016 - using note instance and map to adjust now 	 
    clear_uncomitted_changes();
  	//need to refresh clinical note instance object
  	viewed_form.cnote = [Select lastmodifiedby.name, lastmodifieddate, c.Review_Time__c, c.id, c.Reviewed_By__c, c.reviewed_by__r.name, c.Patient_POT_Apt__c, c.IsActive__c, c.CreatedDate, c.CreatedBy.name, c.Clinical_Apt_Calendar__c, c.Apt_Note__c, c.Account__c, Patient_POT_Apt__r.clinical_appointment__c ,Patient_POT_Apt__r.name from Clinical_note_Instance__c c where id = :viewed_form.cnote.id];
  	//need to refresh standard forms and surgical implants if necessary
  	if(viewed_form.form.getSObjectType()==Schema.Surgical_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current stable state
  	  viewed_form.form = [select bmi_calc__c,height_feet__c,height_inches__c,post_op_general_condition__c,post_op_mental_status__c,post_op_pain_management__c,post_op_hematosis__c,avoiding_strenuous_activity__c,ambulating_without_assistance__c,post_op_oral_intake__c,post_op_general_condition_notes__c,post_op_mental_status_notes__c,
  	    responsible_adult_driver__c,post_op_pulse__c,post_op_pulse_ox__c,post_op_bp_diastolic__c,post_op_bp_systolic__c,post_op_instructions_reviewed__c,sinus_communication_notes__c,sinus_communication_right__c,sinus_communication_left__c,sutures_other__c,sinus_lift_right_max__c,sinus_lift_left_max__c,sinus_lift_right_max_type__c,sinus_lift_left_max_type__c,Procedure_Site_Confirmed__c,Medical_History_Reviewed__c,Denies_Pregnancy__c,Pre_op_medications_given__c,NPO_Confirmed__c,Radiographs_Available_and_up_to_date__c,Consent_Accurate_and_Signed__c,Patient_Examined_Heart_Lungs__c,Monitors_in_place__c,
        Emergency_Cart_Ready__c,STO_Procedure_Consent_Confirmed__c,weight__c,pre_op_notes__c,asa__c,Pre_Op_Pulse_Ox__c,Pre_Op_Pulse__c,Pre_Op_BP_Systolic__c,pre_op_BP_Diastolic__c,Post_Op_Care_Comments__c, Bone_Graft_Material_Multi__c, Bone_Graft_Material_Note__c,flap_design__c,Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Procedure_Verified__c, Vital_Signs__c, Lidocaine__c, lidocaine_50__c, local_anesthetic_other__c, sedation_other__c, sutures__c, sedation_used__c, Marcaine__c, Septocaine__c,  Fentanyl__c, Versed__c, Ketamine__c, Propofol__c, Morphine__c, Envelope__c, Blade_Num__c, Releasing_Incision__c, Buccal_hockey_stick__c, Extractions__c, Alveolectomy__c, Alveolectomy_Amount__c, Alveolectomy_Leveling__c, Betadine__c, Assistants__c, Implant_System__c, Implant_System_Other__c, Implant_Tooth_Position__c, Findings_Complications__c, Discussed_Oral_Hygiene__c, Reviewed_Soft_Food_Diet__c, Interim_Night_Guard_Delivered__c, Bone_Graft_Area__c, Bone_Graft_Type__c, Bone_Graft_Material__c, Bone_Graft_Harvest_Site__c, Sinus_Communication__c, Lateral_sinus_corticotomies__c, Buccal_cortex_intact__c, Lingual_cortex_intact__c, Post_Op_Instruction_Given__c, Icepack_Placed__c, Post_operative_nausea__c, Post_Operative_Pain_Controlled__c, Post_operative_bleeding_controlled__c, Re_anesthetized__c, Post_Surgery_Lidocaine__c, Post_Surgery_MarCaine__c, Post_Surgery_Septocaine__c, Prosth_Screw_Torque_Value__c, Confirmation_Radiography__c, Impression_material_used__c, Placed_seals_using__c, Occlusal_Adjustment__c, IsActive__c, Clinical_Apt_Calendar__c, Account__c,Carbocaine__c,implant_type__c from surgical_notes_form__c where id = :(String)viewed_form.form.get('id')];
  	  //reset surgical implants
  	  viewed_form.all_implants = new List<dp_clinical_notes_new.ImplantWrapper>();
  	  for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
  	    final_notes_form__c, final_notes_form__r.clinical_note_instance__c, final_notes_form__r.clinical_apt_calendar__c,
  	    conversion_notes_form__c, conversion_notes_form__r.clinical_note_instance__c, conversion_notes_form__r.clinical_apt_calendar__c,
  	    jig_notes_form__c, jig_notes_form__r.clinical_note_instance__c, jig_notes_form__r.clinical_apt_calendar__c, date_failure_observed__c, implant_system__c, implant_system_other__c
  	    From Surgical_Note_Implant__c s
  	    where surgical_notes_form__c = :(String)viewed_form.form.get('id')
  	    order by s.Numerical_Name__c]) {
  	    viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  }  	
  	  viewed_form.all_medications = new List<Medication__c>();
  	  for(Medication__c med : [select id, amount_taken__c, route__c, generic_drug_name__c, status_notes__c, surgical_notes_form__c, surgical_notes_form__r.Clinical_Note_Instance__c,Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c
  	    from Medication__c 
  	    where surgical_notes_form__c = :(String)viewed_form.form.get('id')]) {
  	    viewed_form.all_medications.add(med);
  	  } 
  	}
  	//final notes form refresh
  	if(viewed_form.form.getSObjectType()==Schema.Final_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select  f.Tissue_Grade__c, f.SystemModstamp, f.OwnerId, f.Name, f.LastModifiedDate, f.LastModifiedById, f.IsDeleted, f.IsActive__c, f.Id, f.Hygiene_Grade__c, f.CreatedDate, f.CreatedById, f.Clinical_Note_Instance__c, f.Clinical_Apt_Calendar__c, f.Cantilever_length__c, f.Account__c, f.AP_Spread__c 
  	    From Final_Notes_Form__c f where id = :(String)viewed_form.form.get('id')];
  	  //reset surgical implants
  	  viewed_form.all_implants = new List<dp_clinical_notes_new.ImplantWrapper>();
  	  for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
  	    final_notes_form__c, final_notes_form__r.clinical_note_instance__c, final_notes_form__r.clinical_apt_calendar__c,
  	    conversion_notes_form__c, conversion_notes_form__r.clinical_note_instance__c, conversion_notes_form__r.clinical_apt_calendar__c,
  	    jig_notes_form__c, jig_notes_form__r.clinical_note_instance__c, jig_notes_form__r.clinical_apt_calendar__c
  	    ,redo_surgery_form__c,redo_surgery_form__r.clinical_note_instance__c, redo_surgery_form__r.clinical_apt_calendar__c, date_failure_observed__c, implant_system__c, implant_system_other__c
  	    From Surgical_Note_Implant__c s
  	    where final_notes_form__c = :(String)viewed_form.form.get('id')
  	    order by s.Numerical_Name__c]) {
  	    viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  }  	
  	}
  	//redo surgery form refresh
  	if(viewed_form.form.getSObjectType()==Schema.Redo_Surgery_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [Select r.SystemModstamp, r.Rerelate__c, r.Redo_Type__c, r.OwnerId, r.Name, r.Mechanical_Complication__c, r.Mechanical_Complication_Other__c, r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.IsActive__c, r.Implant_Failure__c, r.Id, r.Graft_Failure__c, r.Graft_Failure_Site__c, r.Graft_Failure_Reason__c, r.Graft_Failure_Reason_Other__c, r.CreatedDate, r.CreatedById, r.Clinical_Note_Instance__c, r.Clinical_Apt_Calendar__c, r.Bone_Graft_Material__c, r.Bone_Graft_Material_Other__c, r.Biological_Complication__c, r.Biological_Complication_Other__c, r.Account__c,redo_type_other__c,Implant_Tooth_Position__c 
  	    From Redo_Surgery_Form__c r where id = :(String)viewed_form.form.get('id')];
  	  //reset surgical implants
  	  viewed_form.all_implants = new List<dp_clinical_notes_new.ImplantWrapper>();
  	  for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c,  s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
  	    final_notes_form__c, final_notes_form__r.clinical_note_instance__c, final_notes_form__r.clinical_apt_calendar__c,
  	    conversion_notes_form__c, conversion_notes_form__r.clinical_note_instance__c, conversion_notes_form__r.clinical_apt_calendar__c,
  	    jig_notes_form__c, jig_notes_form__r.clinical_note_instance__c, jig_notes_form__r.clinical_apt_calendar__c
  	    ,redo_surgery_form__c,redo_surgery_form__r.clinical_note_instance__c, redo_surgery_form__r.clinical_apt_calendar__c, date_failure_observed__c, implant_system__c, implant_system_other__c
  	    From Surgical_Note_Implant__c s
  	    where redo_surgery_form__c = :(String)viewed_form.form.get('id')
  	    order by s.Numerical_Name__c]) {
  	    viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  }  	
  	}  	
  	//conversion notes form refresh
  	if(viewed_form.form.getSObjectType()==Schema.Conversion_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select  c.SystemModstamp, c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.IsActive__c, c.Implant_Tooth_Position__c, c.Id, c.CreatedDate, c.CreatedById, c.Confirmation_Radiography__c, c.Clinical_Note_Instance__c, c.Clinical_Apt_Calendar__c, c.Cantilever_Length__c, c.Account__c, c.AP_Spread__c, Upper_AP_Spread__c, UR_Cantilever_Length__c, UL_Cantilever_Length__c, Lower_AP_Spread__c, LR_Cantilever_Length__c, LL_Cantilever_Length__c 
  	    From Conversion_Notes_Form__c c where id = :(String)viewed_form.form.get('id')];
  	  //reset surgical implants
  	  viewed_form.all_implants = new List<dp_clinical_notes_new.ImplantWrapper>();
  	  for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
  	    final_notes_form__c, final_notes_form__r.clinical_note_instance__c, final_notes_form__r.clinical_apt_calendar__c,
  	    conversion_notes_form__c, conversion_notes_form__r.clinical_note_instance__c, conversion_notes_form__r.clinical_apt_calendar__c,
  	    jig_notes_form__c, jig_notes_form__r.clinical_note_instance__c, jig_notes_form__r.clinical_apt_calendar__c
  	    ,redo_surgery_form__c,redo_surgery_form__r.clinical_note_instance__c, redo_surgery_form__r.clinical_apt_calendar__c, date_failure_observed__c, implant_system__c, implant_system_other__c
  	    From Surgical_Note_Implant__c s
  	    where conversion_notes_form__c = :(String)viewed_form.form.get('id')
  	    order by s.Numerical_Name__c]) {
  	    viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  }  	    	
  	}
  	//interim notes form refresh
  	if(viewed_form.form.getSObjectType()==Schema.Interim_Delivery_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select  i.SystemModstamp, i.Reviewed_Soft_Diet__c, i.OwnerId, i.Occlusal_Adjustment__c, i.Name, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.IsActive__c, i.Interim_Night_Guard_Delivered__c, i.Id, i.Discussed_Hygiene__c, i.CreatedDate, i.CreatedById, i.Clinical_Note_Instance__c, i.Clinical_Apt_Calendar__c, i.Account__c
  	    From Interim_Delivery_Notes_Form__c i where id = :(String)viewed_form.form.get('id')];  	    	    
  	}
  	//jig notes form refresh
  	if(viewed_form.form.getSObjectType()==Schema.JIG_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select  j.Tissue_Grade__c, j.SystemModstamp, j.OwnerId, j.Name, j.LastModifiedDate, j.LastModifiedById, j.IsDeleted, j.IsActive__c, j.Id, j.Hygiene_Grade__c, j.CreatedDate, j.CreatedById, j.Confirmation_Radiography__c, j.Clinical_Note_Instance__c, j.Clinical_Apt_Calendar__c, j.Account__c 
  	    From JIG_Notes_Form__c j where id = :(String)viewed_form.form.get('id')];
  	  //reset surgical implants
  	  viewed_form.all_implants = new List<dp_clinical_notes_new.ImplantWrapper>();
  	  for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
  	    final_notes_form__c, final_notes_form__r.clinical_note_instance__c, final_notes_form__r.clinical_apt_calendar__c,
  	    conversion_notes_form__c, conversion_notes_form__r.clinical_note_instance__c, conversion_notes_form__r.clinical_apt_calendar__c,
  	    jig_notes_form__c, jig_notes_form__r.clinical_note_instance__c, jig_notes_form__r.clinical_apt_calendar__c
  	    ,redo_surgery_form__c,redo_surgery_form__r.clinical_note_instance__c, redo_surgery_form__r.clinical_apt_calendar__c, date_failure_observed__c, implant_system__c, implant_system_other__c
  	    From Surgical_Note_Implant__c s
  	    where jig_notes_form__c = :(String)viewed_form.form.get('id')
  	    order by s.Numerical_Name__c]) {
  	    viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  }  	    	
  	}
  	//post op notes form refresh
  	if(viewed_form.form.getSObjectType()==Schema.Post_OP_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select p.SystemModstamp, p.OwnerId, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.IsActive__c, p.Id, p.Healing_in_normal_limits__c, p.CreatedDate, p.CreatedById, p.Clinical_Note_Instance__c, p.Clinical_Apt_Calendar__c, p.Account__c 
  	    From Post_OP_Notes_Form__c p where id = :(String)viewed_form.form.get('id')];  	    	    
  	}
  	//try in notes for refresh
  	if(viewed_form.form.getSObjectType()==Schema.Try_In_Notes_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select t.Try_In_Type__c, t.SystemModstamp, t.OwnerId, t.Name, t.LastModifiedDate, t.LastModifiedById, t.IsDeleted, t.IsActive__c, t.Id, t.CreatedDate, t.CreatedById, t.Clinical_Note_Instance__c, t.Clinical_Apt_Calendar__c, t.Account__c 
  	    From Try_In_Notes_Form__c t where id = :(String)viewed_form.form.get('id')];  	    	    
  	}
  	//prosth exam notes refresh
  	if(viewed_form.form.getSObjectType()==Schema.Prosth_Exam_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, BP_Systolic__c, BP_Diastolic__c, Pulse__c, Pulse_Ox__c, Weight__c, TMJ_stable_wnl__c, TMJ_pop_click_right__c, TMJ_pop_click_left__c, TMJ_max_opening__c, Periodontal_Type__c, Tissue_Max__c, Tissue_Mand__c, Hard_Soft_WNL__c, Hard_Soft_RRR__c, OCS_Neg__c, OCS_Pos__c, Occlusion_Dental__c, Occlusion_Skeletal__c, Occlusion_Plane__c, Occlusion_Hyper_Eruption__c, Occlusion_Attrition__c, Occlusion_OJ__c, Occlusion_OB__c, Existing_Pros_Max__c, Existing_Prosth_Mand__c, Dentofacial_WNL__c, Dentofacial_Max_Direction__c, Dentofacial_Max_Amount__c, Dentofacial_Mand_Direction__c, Dentofacial_Mand_Amount__c, Smile_Line__c, Radiology_WNL__c, Radiology_Other__c, Mobility__c, AO4_Bone_Reduction_Max__c, AO4_bone_Reduction_Mand__c, Bone_Loss__c, Bone_Loss_Percent__c, Bone_Loss_Area__c, Tooth_Shade__c, Tooth_Mould__c, Account__c, Chief_Complaint__c, Perio_Chart__c, isactive__c, Existing_Prosth_Max_Type__c, Existing_Prosth_Mand_Type__c, Height_Feet__c, Height_Inches__c, BMI__c, TMJ_Notes__c, Hard_Soft_Max_RRR__c, Hard_Soft_Mand_RRR__c, Comments__c, Temperature__c, Condition__c, Crepitus__c, Deviations__c, Muscles_of_mastication_WNL__c, Tissue_Color__c, Tissue_Consistency__c, Tissue_Texture__c, Lip_Length__c, Lip_Fullness__c, At_Rest__c, In_Motion__c, Restorative_Prognosis__c, R_Upon_Opening_ROM__c, R_Upon_Closing_ROM__c, L_Upon_Opening_ROM__c, L_Upon_Closing_ROM__c, OCS_Lymph__c, OCS_Lymph_Location__c, OCS_Swelling__c, OCS_Swelling_Location__c, OCS_Asymmetry__c, OCS_Asymmetry_Location__c, OCS_Other__c, OCS_Other_Text__c, Height_Total_Inches__c, BMI_Calc__c, Tissue_Notes__c, Mobility_Notes__c, Range_of_Motion__c, Smile_Line_Notes__c, Surgical_Reduction_Notes__c, Bone_Loss_Notes__c, Reported_Bruxism__c, Evidence_of_Bruxism__c, Abrasion_Location__c, Abrasion_Severity__c, Attrition_Location__c, Attrition_Severity__c, Erosion_Location__c, Erosion_Severity__c, Physiological_Location__c, Physiological_Severity__c, Tooth_Surface_Notes__c, How_long_missing_teeth__c, FMX__c, iCAT__c, Panorex__c, Photographs__c, Image_Notes__c, Impressions__c, Facebow__c, Centric_Relation_Record__c, Records_Notes__c, Recession_Notes__c, Tooth_Shade_Other__c, Dry_Mouth__c, Salivary_Other__c, Clinical_Note_Instance__c, Clinical_Apt_Calendar__c,existing_prosth_notes__c , recession__c
  	    From Prosth_Exam_Form__c p where id = :(String)viewed_form.form.get('id')];  	    	    
  	}
  	//repair notes refresh
  	if(viewed_form.form.getSObjectType()==Schema.Repair_Note_Form__c.getSObjectType()) {
  	  //reset form to it's current table state
  	  viewed_form.form = [Select r.Tooth_Fracture_Location__c, r.Tooth_Debonding_Location__c, r.Time_in_Lab__c, r.Time_in_Lab_Minutes__c, r.SystemModstamp, r.Rework_Reason__c, r.Rework_Reason_Other__c, r.Rework_Completed__c, r.Rework_Completed_Other__c, r.Requested_By__c, r.Repair_Work_Type__c, r.Repair_Work_Type_Other__c, r.Repair_Reason__c, r.Repair_Reason_Other__c, r.Repair_Apt_Type__c, r.Prosthetic_Screw_Tightening_Location__c, r.Prosthetic_Screw_Fracture_Location__c, r.Prosthesis_Type__c, r.Prosthesis_Type_Other__c, r.Prosthesis_Stage__c, r.OwnerId, r.Opposing_Arch__c, r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.IsActive__c, r.Id, r.Denture_Base_Fracture_Location__c, r.CreatedDate, r.CreatedById, r.Clinical_Note_Instance__c, r.Clinical_Apt_Calendar__c, r.Bar_Fracture_Location__c, r.Age_of_Prosthesis_Years__c, r.Age_of_Prosthesis_Months__c, r.Account__c, r.Abutment_Screw_Tightening_Location__c, r.Abutment_Screw_Loosening_Location__c, r.Abutment_Screw_Fracture_Location__c 
  	    From Repair_Note_Form__c r where id = :(String)viewed_form.form.get('id')];  	    	    
  	}

    //need to refresh upload section
    for(Attachment a : [select id,name,description,parentid from Attachment where parentid = :viewed_form.cnote.id]) {
      viewed_form.all_files.add(a);
    }
  	
  	//need to refresh custom notes when ready
  	//pull a list of clinical_note_custom_note__c where the note instance is a match
  	for(Clinical_note_Custom_note__c cncn : [Select c.SystemModstamp, c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Custom_Clinical_Note__c, c.CreatedDate, c.CreatedById, c.Comments__c, c.Clinical_Note_Instance__c, Custom_Clinical_Note__r.isactive__c
  	  From Clinical_Note_Custom_Note__c c
  	  where clinical_note_instance__c = :viewed_form.cnote.id
  	  order by custom_clinical_note__r.sort_order__c]) {
  	  viewed_form.note_map.get(cncn.custom_clinical_note__c).note_record = cncn;
  	}  	
  	  	
  	modal_out = '';
  	confirmation_modal_display = false;
  	confirmation_id = null;
  	viewed_form.confirm_css = '';    	
  }
  
  public void delete_medication_record() {
  	try {
  	  Medication__c delete_med = [select id,surgical_notes_form__c,surgical_notes_form__r.clinical_note_instance__c from Medication__c where id = :confirmation_id];
  	  String form_id = delete_med.surgical_notes_form__c;  	  	
  	  delete delete_med;  	    	  	  
  	  
  	  viewed_form.confirm_css = '';
  	  //refresh the medication array
  	  viewed_form.all_medications = [select id,generic_drug_name__c, route__c,amount_taken__c, status_notes__c,surgical_notes_form__c,Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c from Medication__c where surgical_notes_form__c = :form_id];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove medication info.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}  	
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
  public void delete_file_record() {
  	try {
  	  Attachment att = [select id,parentid from Attachment where id = :confirmation_id];  	
  	  String form_id = att.parentid;  	  
  	  delete att;  	    	  	  
  	  
  	  viewed_form.confirm_css = '';
  	  //refresh the medication array
  	  viewed_form.all_files = [select id,parentid,name,description from Attachment where parentid = :form_id];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the file.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}  	
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
  public void toggle_uncomitted_status() {
  	uncomitted_changes = true;
  }
  
  public void change_form_value() {  	
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	String form_id =  apexpages.currentpage().getparameters().get('formid');  	
    if(viewed_form.getisform_editable() && viewed_form.form!=null) { 
      if(form_id==(ID)viewed_form.form.get('id')) {
        toggle_uncomitted_status();
      	record_uncomitted_change(form_id, fname, new_val, System.now(), 'String');
      }
      for(dp_clinical_notes_new.ImplantWrapper sni : viewed_form.all_implants) {
        if(form_id==sni.imp.id) {
      	  toggle_uncomitted_status();
      	  record_uncomitted_change(form_id, fname, new_val, System.now(), 'String');
      	}
      }
    }    
  } 
  
  public void change_form_value_immediate() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	String form_id =  apexpages.currentpage().getparameters().get('formid');
  	System.debug('Changing Field - ' + fname);
  	if(viewed_form.getisform_editable() && viewed_form.form!=null) {
      toggle_uncomitted_status();
      if(form_id==(ID)viewed_form.form.get('id')) {
        viewed_form.form.put(fname,new_val); 
      }      
      for(dp_clinical_notes_new.ImplantWrapper sni : viewed_form.all_implants) {
      	if(form_id==sni.imp.id) {
       	  sni.imp.put(fname,new_val);
       	}
      }      
    } 
  }
  
  public void record_uncomitted_change(String form_id, String field_name, String field_value, Datetime rtime, String field_type) {
  	//TO-DO : get rtime actually working based on when the ajax call initiated
  	//check to see if we have an existing request for this field
  	try {
  	  Integer change_count = [select count() from uncomitted_form_change__c where form_id__c = :form_id and field_name__c = :field_name and vf_page__c = 'Notes' and createdbyid = :userinfo.getUserId()];
  	  Uncomitted_form_change__c change_record;
  	  if(change_count>0) {
  	    change_record = [select id,form_id__c,field_name__c,field_value__c,request_time__c,field_type__c,vf_page__c from uncomitted_form_change__c where form_id__c = :form_id and field_name__c = :field_name and createdbyid = :userinfo.getUserId()];
  	    change_record.field_value__c = field_value;
  	  }
  	  else
  	    change_record = new Uncomitted_form_change__c(form_id__c = form_id, field_name__c = field_name, field_value__c = field_value, request_time__c = rtime, field_type__c = field_type, vf_page__c = 'Notes');
  	  upsert change_record;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error recording form changes.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);
  	}
  }
  
  public void change_boolean_value() {  	  
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');  	  
  	String form_id =  apexpages.currentpage().getparameters().get('formid');  	
  	if(viewed_form.getisform_editable() && viewed_form.form!=null) {          
      if(form_id==(ID)viewed_form.form.get('id')) {
      	toggle_uncomitted_status();
        record_uncomitted_change(form_id, fname, new_val, System.now(), 'Boolean'); 
      }      	  
    }    
  }
  
  public void change_multipick_full_value() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	if(new_val=='')
  	  new_val = null;
  	String form_id =  apexpages.currentpage().getparameters().get('formid');
    if(viewed_form.getisform_editable() && viewed_form.form!=null) { 
      if(form_id==(ID)viewed_form.form.get('id')) {
      	toggle_uncomitted_status();
      	record_uncomitted_change(form_id, fname, new_val, System.now(), 'String');
      }
      for(dp_clinical_notes_new.ImplantWrapper sni : viewed_form.all_implants) {
      	if(form_id==sni.imp.id) {
      	  toggle_uncomitted_status();
      	  record_uncomitted_change(form_id, fname, new_val, System.now(), 'String');
      	}
      }
    }    
  }
  
  //tooth selection stuff  
  public void open_variable_tooth_modal() {
  	display_var_tooth_modal = true;
  	//modified by cm on 5/4/2016 - I'm adjusting this to use the note instance and map
  	String note_instance = apexpages.currentpage().getparameters().get('noteid');  	
  	target_field = apexpages.currentpage().getparameters().get('field_name');
  	tooth_chart_label = apexpages.currentpage().getparameters().get('chart_label');   	  	
  	apply_uncomitted_changes_to_form();	  	
  }
  
  //method to toggle a tooth
  public void toggle_variable_tooth_selection() {
  	sObject target_object = viewed_form.form;
  	System.debug('Target Object : ' + target_object);
  	System.debug('Target Field : ' + target_field); 
  	String current_target_teeth = (String)target_object.get(target_field);
  	if(current_target_teeth=='')
  	  current_target_teeth=null;  	
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	System.debug('Selected teeth : ' + selected_teeth);
  	if(teeth_set.contains('All Max') || teeth_set.contains('All Mand')) {
	  	//calculate max/man targets in case we need to replace all max / all mand targets below
	  	Set<Integer> all_max = new Set<Integer> {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
	  	Set<Integer> all_mand = new Set<Integer> {17,18,29,20,21,22,23,24,25,26,27,28,29,30,31,32};
	  	//grab the most recent perio chart and look for missing/pontic teeth.
	  	try {
	  	  Perio_Chart__c pc = [Select p.Id, p.Account__c, 
	  	  (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Tooth_Type__c, Measurement__c, Endo__c, Decay__c, Perio_Chart__c, Tooth_Integer__c From Perio_Chart_Teeth__r 
	  	    where tooth_type__c in ('Missing','Pontic')) 
	  	    From Perio_Chart__c p 
	  	    where account__c = :patient.id
	  	    order by createddate desc limit 1];
	  	  for(Perio_chart_tooth__c pct : pc.perio_chart_teeth__r) {
	  	    all_max.remove(pct.tooth_integer__c.intvalue());
	  	    all_mand.remove(pct.tooth_integer__c.intvalue());
	  	  }
	  	} catch (Exception e) {
	  	  //indicates we don't have a perio chart for this patient - use the defaults
	  	}	  		  	
	  if(teeth_set.contains('All Max')) {
	  	teeth_set.remove('All Max');
	  	for(Integer i : all_max) {
	  	  teeth_set.add(string.valueof(i));
	  	}
	  }
	  if(teeth_set.contains('All Mand')) {
	  	teeth_set.remove('All Mand');
	  	for(Integer i : all_mand) {
	  	  teeth_set.add(string.valueof(i));
	  	}
	  }
	  selected_teeth = new List<String> (teeth_set);
  	} 
  	teeth_set = new Set<String>(selected_teeth);
  	String clicked_tooth = apexpages.currentpage().getparameters().get('toothid');  	
  	if(teeth_set.contains(clicked_tooth)) {
  	  //tooth was toggled off and needs to be removed from the field
  	  teeth_set.remove(clicked_tooth);  	  
  	}
  	else {
  	  //tooth was toggled on and need to be added to the field
  	  teeth_set.add(clicked_tooth);
  	}  	
  	Integer[] sort_teeth = new Integer[] {};
  	for(String s : teeth_set) {
  	  sort_teeth.add(Integer.valueof(s));
  	}
  	sort_teeth.sort();  	  
  	//build the new target string
  	String new_target = '';
  	for(Integer t : sort_teeth) {
  	  new_target += String.valueof(t) + ',';
  	}  	
  	System.debug('New Target : ' + new_target);
  	target_object.put(target_field,(new_target.removeEnd(',').replace(',999','')));  	
  	
  	//if the field is Implant_Tooth_Position__c - need to process the string and create/remove  	
  	if(target_field=='Implant_Tooth_Position__c') { 
	  	Map<String,Surgical_note_implant__c> implant_map = new Map<String,Surgical_note_implant__c> ();
	  	Set<String> implant_numbers = new Set<String>();
	  	for(Surgical_note_implant__c i : [Select s.SystemModstamp, s.conversion_notes_form__c, s.final_notes_form__c, s.jig_notes_form__c, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c, s.abutment_width__c, s.Abutment_Collar_Height__c, bone_density__c,Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, s.redo_surgery_form__c, date_failure_observed__c, implant_system__c, implant_system_other__c From Surgical_Note_Implant__c s 
	  	  where surgical_notes_form__c = :(String)target_object.get('id') or conversion_notes_form__c = :(String)target_object.get('id')
	  	  or final_notes_form__c = :(String)target_object.get('id') or jig_notes_form__c = :(String)target_object.get('id')
	  	  or redo_surgery_form__c = :(String)target_object.get('id')]) {
	      implant_map.put(i.name,i);
	  	  implant_numbers.add(i.name);
	  	}
	  	List<Surgical_note_implant__c> new_implants = new List<Surgical_note_implant__c>();
	  	List<Surgical_note_implant__c> remove_implants = new List<Surgical_note_implant__c>();
	  	
	  	//work throught tooth set and see if we need to create a new record
	  	for(String snum : teeth_set) {
	  	  if(implant_numbers.contains(snum)) {
	  	    //implant record already exists - no work necessary
	  	    System.debug('Implant record already exists for tooth : ' + snum);
	  	  } else {
	  	  	if(snum!='999') {
	  	  	  System.debug('Creating implant record for tooth : ' + snum);
	  	  	  Surgical_note_implant__c implant = new Surgical_note_implant__c(name = snum);
	  	  	  if(target_object.getSObjectType()==Schema.Surgical_Notes_Form__c.getSObjectType())	  	  	  
	  	  	    implant.surgical_notes_form__c = (String)target_object.get('id');
	  	  	  if(target_object.getSObjectType()==Schema.Conversion_Notes_Form__c.getSObjectType())	  	  	  
	  	  	    implant.conversion_notes_form__c = (String)target_object.get('id');
	  	  	  if(target_object.getSObjectType()==Schema.JIG_Notes_Form__c.getSObjectType())	  	  	  
	  	  	    implant.jig_notes_form__c = (String)target_object.get('id');
	  	  	  if(target_object.getSObjectType()==Schema.Final_Notes_Form__c.getSObjectType())	  	  	  
	  	  	    implant.final_notes_form__c = (String)target_object.get('id');
	  	  	  if(target_object.getSObjectType()==Schema.Redo_Surgery_Form__c.getSObjectType())	  	  	  
	  	  	    implant.redo_surgery_form__c = (String)target_object.get('id'); 
	  	  	  new_implants.add(implant);
	  	  	  System.debug('New Implant Record ' + implant);
	  	  	}
	  	  }
	  	}
	  	  
	  	//work through implant numbers and see if we have a record that needs to be removed
	  	for(String snum : implant_numbers) {
	  	  if(teeth_set.contains(snum)) {
	  	  	//implant record is still valid
	  	  	System.debug('Implant record is good : ' + snum);
	  	  } else {
	  	  	System.debug('Implant record needs to be removed : ' + snum);
	  	  	remove_implants.add(implant_map.get(snum));
	  	  }  	  
	  	}
	  	
	  	try {
	  	  if(new_implants.size()>0) {
	  	  	System.debug('Adding ' + new_implants.size() + ' implant records');
	  	  	System.debug('Target object : ' + target_object);
	  	  	System.debug('CA : ' + (String)target_object.get('clinical_apt_calendar__c'));
	  	    insert new_implants;
	  	    for(Surgical_note_implant__c sni : new_implants) {
	  	      viewed_form.all_implants.add(new dp_clinical_notes_new.ImplantWrapper(sni));
	  	    }
	  	    viewed_form.sort_implants();	  	    		  	    
	  	  }
	  	  if(remove_implants.size()>0) {
	  	  	System.debug('Removing ' + remove_implants.size() + ' implant records');
	  	  	System.debug('Target object : ' + target_object);
	  	  	System.debug('CA : ' + (String)target_object.get('clinical_apt_calendar__c'));	  	  	
	  	  	//remove from our patient_apts object
	  	  	//Map<ID,Surgical_Note_implant__c> imap = new Map<ID,Surgical_note_Implant__c>(viewed_form.all_implants);	  	  	
	  	  	Map<ID,dp_clinical_notes_new.ImplantWrapper> imap = new Map<ID,dp_clinical_notes_new.ImplantWrapper>();
	  	  	for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
	  	      imap.put(iw.imp.id,iw);
	  	  	}
	  	    for(Surgical_note_implant__c sni : remove_implants) {	  	      
	  	  	  for(dp_clinical_notes_new.ImplantWrapper existing_implant : viewed_form.all_implants) {
	  	  	  	if(existing_implant.imp.name==sni.name) {
	  	  	  	  imap.remove(existing_implant.imp.id);
	  	  	  	}  	  	  	  
	  	  	  }
	  	    }
	  	    viewed_form.all_implants = imap.values();	  	    
	  	    viewed_form.sort_implants();
	  	  	delete remove_implants;
	  	  }
	  	} catch (Exception e) {
	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adjusting tooth selection.  Please contact IT for help'));
	      ApexPages.addMessages(e);
	  	}
  	}
  }  
  
  public void close_variable_tooth_modal() {
  	display_var_tooth_modal = false;
  	apply_uncomitted_changes_to_form();
  	target_field = null;
  	tooth_chart_label = null;
  }
  
  public void apply_uncomitted_changes_to_form() {
  	//apply form changes
  	if(viewed_form.form!=null) {
  	  list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c = :viewed_form.form.id
  	    and createdbyid = :userinfo.getuserid() and vf_page__c = 'Notes']; 
  	  //System.debug('Processing ' + ucf_list.size() + ' form changes');
  	  for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	    if(ucf.field_type__c=='Boolean')
  	      viewed_form.form.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	    else
  	      viewed_form.form.put(ucf.field_name__c,ucf.field_value__c);  	
  	  }
  	}
  	
  	//if we have sugrical implants,  check for any changes
  	if(viewed_form.all_implants.size()>0) {
  	  //Map<ID,Surgical_Note_Implant__c> implant_map = new Map<ID,Surgical_Note_Implant__c> (viewed_form.all_implants);
  	  Map<ID,dp_clinical_notes_new.ImplantWrapper> implant_map = new Map<ID,dp_clinical_notes_new.ImplantWrapper> ();
  	  for(dp_clinical_notes_new.ImplantWrapper iw : viewed_form.all_implants) {
  	    implant_map.put(iw.imp.id,iw);
  	  }  	  
  	  //check for any changes to these implants
  	  list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c in :implant_map.keyset()
  	    and createdbyid = :userinfo.getuserid() and vf_page__c = 'Notes'];   	  
  	  for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	  	if(implant_map.get(ucf.form_id__c)!=null) {
  	  	  if(ucf.field_type__c=='Boolean')
  	        implant_map.get(ucf.form_id__c).imp.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	      else
  	        implant_map.get(ucf.form_id__c).imp.put(ucf.field_name__c,ucf.field_value__c);
  	  	}
  	  }
  	}  
  }
  
  public String getcurrent_variable_tooth_selections() {  	
  	return (String)viewed_form.form.get(target_field);
  }    
  
  public dp_clinical_pot.tooth[] getlower_variable_tooth_chart() {
  	dp_clinical_pot.tooth[] tooth_chart = new dp_clinical_pot.tooth[] {};  	
  	Map<Integer,Perio_Chart_Tooth__c> tooth_map = new Map<Integer,Perio_Chart_Tooth__c>();  	
  	//check to see if we have a perio chart for this patient - if so grab the teeth from that so we can adjust images
  	try {
  	  Perio_Chart__c last_chart = [select id from Perio_Chart__c where account__c = :patient.id order by createddate desc limit 1];
  	  for(Perio_Chart_Tooth__c cpt : [Select p.Tooth_Type__c, p.Tooth_Integer__c, p.Perio_Chart__c, p.Name, p.Endo__c, p.Decay__c From Perio_Chart_Tooth__c p where perio_chart__c = :last_chart.id]) {
  	    tooth_map.put(cpt.tooth_integer__c.intvalue(),cpt);
  	  }
  	} catch (Exception e) {
  	  System.debug('Tooth Chart error' + e);
  	}
  	  	
  	String current_target_teeth = (String)viewed_form.form.get(target_field);  	
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 32; tnum>=17; tnum--) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  dp_clinical_pot.tooth t = new dp_clinical_pot.tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum); 
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }    
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  //method to get variable upper tooth chart - array of tooth
  public dp_clinical_pot.tooth[] getupper_variable_tooth_chart() {
  	dp_clinical_pot.tooth[] tooth_chart = new dp_clinical_pot.tooth[] {};  	
  	Map<Integer,Perio_Chart_Tooth__c> tooth_map = new Map<Integer,Perio_Chart_Tooth__c>();  	
  	//check to see if we have a perio chart for this patient - if so grab the teeth from that so we can adjust images
  	try {
  	  Perio_Chart__c last_chart = [select id from Perio_Chart__c where account__c = :patient.id order by createddate desc limit 1];
  	  for(Perio_Chart_Tooth__c cpt : [Select p.Tooth_Type__c, p.Tooth_Integer__c, p.Perio_Chart__c, p.Name, p.Endo__c, p.Decay__c From Perio_Chart_Tooth__c p where perio_chart__c = :last_chart.id]) {
  	    tooth_map.put(cpt.tooth_integer__c.intvalue(),cpt);
  	  }
  	} catch (Exception e) {
  	  System.debug('Tooth Chart error' + e);
  	}  	
  	
  	String current_target_teeth = (String)viewed_form.form.get(target_field);  	
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 1; tnum<=16; tnum++) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  dp_clinical_pot.tooth t = new dp_clinical_pot.tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum); 
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }    
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  public List<Selectoption> getroute_options() {
    List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('','Select Route'));
  	clist.add(new Selectoption('Topical','Topical'));
  	clist.add(new Selectoption('Enteral','Enteral'));
  	clist.add(new Selectoption('Parenteral','Parenteral'));  	
  	return clist;
  }  
  
  public List<Selectoption> gethour_options() {
    List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('1','1'));
  	clist.add(new Selectoption('2','2'));
  	clist.add(new Selectoption('3','3'));
  	clist.add(new Selectoption('4','4'));
  	clist.add(new Selectoption('5','5'));
  	clist.add(new Selectoption('6','6'));
  	clist.add(new Selectoption('7','7'));
  	clist.add(new Selectoption('8','8'));
  	clist.add(new Selectoption('9','9'));
  	clist.add(new Selectoption('10','10'));
  	clist.add(new Selectoption('11','11'));
  	clist.add(new Selectoption('12','12'));  	
  	return clist;
  }
  
  public List<Selectoption> getsuffix_options() {
    List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('AM','AM'));
  	clist.add(new Selectoption('PM','PM'));  	
  	return clist;
  }  
  
  public void add_medication_info() {
    //check for errors
    Integer num_issues = 0;
    if(new_medication.generic_drug_name__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for drug name'));      
    } else if(new_medication.generic_drug_name__c=='Enter Drug Name' || new_medication.generic_drug_name__c=='') {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid value for drug name'));
    }
    if(new_medication.amount_taken__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for dosage'));
    } else if(new_medication.amount_taken__c=='Enter Dosage' || new_medication.amount_taken__c=='') {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid value for dosage'));
    }
    if((new_medication.route__c==null?'':new_medication.route__c)=='') {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid route'));
    } 
    if(new_medication.minute_administered__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a time the drug was administered'));
    } else if(new_medication.minute_administered__c<0 || new_medication.minute_administered__c>=60) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Minutes must be a value between 0 and 59'));
    } 
    if(num_issues==0) {
  	  try {
  	  	insert new_medication;
  	  	//add the record to the all medication array for this form
  	  	//find out form - work through all clinical apts
        if(viewed_form.getisform_editable() && viewed_form.form!=null) {
      	  if(new_medication.surgical_notes_form__c==(ID)viewed_form.form.get('id')) {
      	    viewed_form.all_medications.add(new_medication);
      	  }
      	  apply_uncomitted_changes_to_form(); 
      	}      
  	    hide_medication_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a medication record.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
    
  }
  
  public void hide_medication_form() {
  	display_new_med_form = true;
  	current_edit_id = null;
  	new_medication = null;
  }
  
  public void reset_new_medication_form() {
  	new_medication = new Medication__c(Surgical_Notes_Form__c = new_medication.surgical_notes_form__c, generic_drug_name__c = 'Enter Drug Name', Amount_Taken__c = 'Enter Dosage');
  }
  
  public void save_medication_form() {  	
  	//check if record is valid
  	//grab the record we are currently updating
  	Integer num_issues = 0;
  	Medication__c refresh_med = [select id,generic_drug_name__c, route__c,amount_taken__c, status_notes__c,surgical_notes_form__c,Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c from Medication__c where id = :current_edit_id];
    if(viewed_form.getisform_editable() && viewed_form.form!=null) {
      if(refresh_med.surgical_notes_form__c==(ID)viewed_form.form.get('id')) {
        apply_uncomitted_changes_to_form(); 
        for(Medication__c m : viewed_form.all_medications) {         	      	      
          if(m.id==refresh_med.id)
            refresh_med = m;
        }      	   	 
      }
    }
    if(refresh_med.generic_drug_name__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for drug name'));      
    } else if(refresh_med.generic_drug_name__c=='Enter Drug Name' || refresh_med.generic_drug_name__c=='') {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid value for drug name'));
    }
    if(refresh_med.amount_taken__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for dosage'));
    } else if(refresh_med.amount_taken__c=='Enter Dosage' || refresh_med.amount_taken__c=='') {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid value for dosage'));
    }
    if((refresh_med.route__c==null?'':refresh_med.route__c)=='') {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid route'));
    } 
    if(refresh_med.minute_administered__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a time the drug was administered'));
    } else if(refresh_med.minute_administered__c<0 || refresh_med.minute_administered__c>=60) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Minutes must be a value between 0 and 59'));
    }
  	if(num_issues==0) {
  	  try {
  	  	//add the record to the all medication array for this form
  	  	//find out form - work through all clinical apts        
      	if(viewed_form.getisform_editable() && viewed_form.form!=null) {
      	  if(refresh_med.surgical_notes_form__c==(ID)viewed_form.form.get('id')) {
      	    update viewed_form.all_medications;
      	  }
      	}        
  	    hide_medication_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save medication info.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void reset_medication_form() {
  	try {
  	  Medication__c refresh_med = [select id,generic_drug_name__c, route__c,amount_taken__c, status_notes__c,surgical_notes_form__c,Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c from Medication__c where id = :current_edit_id];
      if(viewed_form.getisform_editable() && viewed_form.form!=null) {
        if(refresh_med.surgical_notes_form__c==(ID)viewed_form.form.get('id')) {      	      
      	  viewed_form.all_medications = [select id,generic_drug_name__c, route__c,amount_taken__c, status_notes__c,surgical_notes_form__c,Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c from Medication__c where surgical_notes_form__c = :refresh_med.surgical_notes_form__c];
      	  apply_uncomitted_changes_to_form(); 
      	}      	   	 
      }      
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the medication record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void new_medication_form() {
  	display_new_med_form = true;
  	new_medication = new Medication__c(Surgical_Notes_Form__c = viewed_form.form.id, generic_drug_name__c = 'Enter Drug Name', Amount_Taken__c = 'Enter Dosage');
  	//apply uncomitted changes to form so refresh won't screw us up
    if(viewed_form.getisform_editable() && viewed_form.form!=null) {
      apply_uncomitted_changes_to_form();  	   	 
    }  	
  }
  
  public void confirm_delete_medication() {
  	Medication__c refresh_med = [select id,generic_drug_name__c, route__c,amount_taken__c, status_notes__c, surgical_notes_form__c, surgical_notes_form__r.clinical_note_instance__c,Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c from Medication__c where id = :apexpages.currentpage().getparameters().get('medid')];  	   
  	viewed_form.confirm_css = ' delete_selection';
  	confirmation_id = refresh_med.id;
  	confirmation_modal_display = true;
  	modal_out = 'Please confirm you wish to delete the medication record for - ' + refresh_med.generic_drug_name__c;
  	confirmation_modal_type = 'trash_med';
  	apply_uncomitted_changes_to_form();
  }
  
  public void edit_medication_record() {
  	current_edit_id = apexpages.currentpage().getparameters().get('medid');
  	apply_uncomitted_changes_to_form();	  	
  }
  
  public void display_attachment_form() {
  	display_attachment_form = true;  	
  	new_note_attachment = new Attachment(parentid = apexpages.currentpage().getparameters().get('cnid'));
  	apply_uncomitted_changes_to_form();
  }
  
  public void close_attachment_form() {
  	display_attachment_form = false;
  	apply_uncomitted_changes_to_form();
  }
  
  public void set_default_implant_system() {
  	String default_system = apexpages.currentpage().getparameters().get('dsys');
  	record_uncomitted_change(viewed_form.form.id, 'Implant_System__c', default_system, System.now(), 'String');
  	viewed_form.form.put('Implant_System__c',default_system); 
  	for(dp_clinical_notes_new.implantwrapper iw : viewed_form.all_implants) {
  	  if(iw.imp.implant_system__c==null)
  	    iw.imp.implant_system__c = default_system;	  	    
  	}  	
  	apply_uncomitted_changes_to_form();
  }
  
  public void set_default_implant_type() {
  	String default_type = apexpages.currentpage().getparameters().get('dtype');
  	record_uncomitted_change(viewed_form.form.id, 'Implant_Type__c', default_type, System.now(), 'String');
  	viewed_form.form.put('Implant_Type__c',default_type);
  	for(dp_clinical_notes_new.implantwrapper iw : viewed_form.all_implants) {
  	  if(iw.imp.implant_type__c==null)
  	    iw.imp.implant_type__c = default_type;	
  	}
  	apply_uncomitted_changes_to_form();
  }
  
  public void save_attachment_form() {
  	Integer num_issues = 0;
  	Attachment att = [select parentid from Attachment where id = :current_edit_id];
    if(viewed_form.getisform_editable()) {
      if(att.parentid==viewed_form.cnote.id) {
        apply_uncomitted_changes_to_form();
        for(Attachment a : viewed_form.all_files) {         	      	      
          if(a.id==current_edit_id)
            att = a;
        }
      }      	   	 
    }
    if(att.name==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for attachment name'));
    } else if(att.name.length()<5) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a longer value for attachment name'));
    }
    if(att.description==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for attachment name'));
    } else if(att.description.length()<5) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a longer value for attachment name'));
    }
    if(num_issues==0) {
   	  try {
        if(viewed_form.getisform_editable()) {
      	  if(att.parentid==viewed_form.cnote.id) {
      	    update viewed_form.all_files;
      	  }
      	}        
  	    hide_attachment_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save attachment info.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
    }
  } 
  
  public void hide_attachment_form() {
  	Attachment a = [select id,parentid from Attachment where id = :current_edit_id];
  	apply_uncomitted_changes_to_form();
  	current_edit_id = null;
  }
  
  public void reset_attachment_form() {
  	try {
  	  Attachment refresh_att = [select id,parentid,name,description from Attachment where id = :current_edit_id];
  	  if(viewed_form.getisform_editable()) {
  	    if(refresh_att.parentid==viewed_form.cnote.id) {
  	  	  viewed_form.all_files = [select id,parentid,name,description from Attachment where parentid = :refresh_att.parentid];
  	  	  apply_uncomitted_changes_to_form();
  	  	}
  	  }  	  	  
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the attachment record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void confirm_delete_file() {
  	Attachment att = [select id,parentid,name,description from Attachment where id = :confirmation_id];  	  	   
  	apply_uncomitted_changes_to_form();
  	viewed_form.confirm_css = ' delete_selection';
  	confirmation_modal_display = true;
  	modal_out = 'Please confirm you wish to delete the file - ' + att.description;
  	confirmation_modal_type = 'trash_file';
  }
  
  public void edit_file_attachment() {
  	current_edit_id = apexpages.currentpage().getparameters().get('fileid');
  	Attachment a = [select id,parentid from Attachment where id = :current_edit_id];
  	apply_uncomitted_changes_to_form();
  }
  
  public boolean getis_user_doctor() {
  	if(userinfo.getName()=='Chris McDowell')
  	  return true;
  	else
  	  return doctor_profiles.contains(profile_name);
  }
  
  public void toggle_custom_note_selection() {
  	apply_uncomitted_changes_to_form();
  	String cn_instance = apexpages.currentpage().getparameters().get('cnid');
  	dp_clinical_notes_new.clinic_note cn = viewed_form.note_map.get(cn_instance);
  	try {  	
  	  //check if this note is selected
  	  if(cn.currently_selected) {
  	    //remove the note
  	    delete cn.note_record;  	  
  	    cn.currently_selected = false;
  	    cn.note_record = null;
  	  }
  	  else {
  	    //add the note
  	    Clinical_Note_Custom_Note__c cncn = new Clinical_Note_Custom_Note__c(Custom_Clinical_Note__c = cn.custom_note.id, Clinical_Note_Instance__c = viewed_form.cnote.id);
  	    insert cncn;
  	    cn.note_record = cncn;  	  
  	    cn.currently_selected = true;
  	  }
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the custom note'));
	  ApexPages.addMessages(e);
  	}
  }
  
  public void check_for_legacy_notes() {
  	Integer cnt = [select count() from win_cnote_import__c where account__c = :patient.id and windent_note__c = true];
  	if(cnt > 0) {
  	  has_legacy_notes = true;
  	} else {
  	  has_legacy_notes = false;
  	}
  	display_legacy_notes = false;
  }
  
  public list<win_cnote_import__c> getlegacy_notes() {
  	return database.query('select note_date__c, doctor_note__c from win_cnote_import__c where account__c = \'' + patient.id + '\' and windent_note__c = true order by note_date__c ' + legacy_notes_sort_direction);
  }
  
  public void toggle_legacy_notes_display() {
  	display_legacy_notes = (display_legacy_notes?false:true);
  }
  
  public void change_legacy_notes_sort_order() {
  	legacy_notes_sort_direction = (legacy_notes_sort_direction=='asc'?'desc':'asc');
  }
  
  public void save_follow_up_form() {
  	//check for errors
    Integer num_issues = 0;
    if(follow_up_note_dml.doctor_note__c.length()<5) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a longer note'));      
    }      
    if(num_issues==0) {
  	  try {
  	  	if(follow_up_note_dml.id==null)
  	  	  insert follow_up_note_dml;
  	  	else
  	  	  update follow_up_note_dml;
  	  	//add the record to the all medication array for this form  	  
  	    hide_follow_up_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a follow up note.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void confirm_delete_follow_up() {
  	Win_Cnote_Import__c wic = [select id,doctor_note__c from Win_Cnote_Import__c where id = :apexpages.currentpage().getparameters().get('fnid')];  	   
  	confirmation_id = wic.id;
  	confirmation_modal_display = true;
  	modal_out = 'Please confirm you wish to delete this note <br /> ' + wic.doctor_note__c;
  	confirmation_modal_type = 'trash_follow_up';
  }
  
  public void delete_follow_up() {
  	try {
  	  Win_Cnote_Import__c delete_wic = [select id from Win_Cnote_Import__c where id = :confirmation_id];  	
  	  //delete the record
  	  delete delete_wic;  	    	  	    	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the note.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}  	
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
  public void new_follow_up_form() {
  	display_follow_up_form = true;
  	follow_up_note_dml = new Win_Cnote_Import__c(account__c = patient.id, windent_note__c = false, note_date__c = system.today(), doctor_note__c = '');
  }
  
  public void edit_follow_up_form() {
  	current_note_edit_id = apexpages.currentpage().getparameters().get('fnid');
  	follow_up_note_dml = [select note_date__c, doctor_note__c,lastmodifiedby.profile.name,createddate,lastmodifiedby.name  from Win_Cnote_Import__c where id = :current_note_edit_id];
  }
  
  public void hide_follow_up_form() {
  	display_follow_up_form = false;
  	current_note_edit_id = null;
  	follow_up_note_dml = null;
  }
  
  public list<dp_clinical_notes_new.follow_up_note> getfollow_up_notes() {
  	list<dp_clinical_notes_new.follow_up_note> fnotes = new list<dp_clinical_notes_new.follow_up_note>();
    for(Win_Cnote_Import__c wci : database.query('select note_date__c, doctor_note__c,lastmodifiedby.profile.name,createddate,lastmodifiedby.name from win_cnote_import__c where account__c = \'' + patient.id + '\' and windent_note__c = false order by note_date__c ')) {
      fnotes.add(new dp_clinical_notes_new.follow_up_note(wci)); 
    }  	
    return fnotes;
  }
  
  public void upload_note_file() {
  	try {
      new_note_attachment.name = photo_name;
      new_note_attachment.description = 'New Upload - ' + new_note_attachment.name;
      new_note_attachment.contentType=photo_content_type;
      new_note_attachment.Body=EncodingUtil.base64Decode(photo_data);
      insert new_note_attachment;
      //add the file to the instance
  	  if(viewed_form.getisform_editable()) {
        if(new_note_attachment.parentid==viewed_form.cnote.id) {
          viewed_form.all_files.add(new_note_attachment);
          apply_uncomitted_changes_to_form();
        }      	   	 
      }    
      new_note_attachment = new Attachment(parentid = new_note_attachment.parentid);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to upload the document.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public Boolean gethas_patient_completed_health_history() {
  	//function name is misleading now,  as this just indicates we have a haleth history file and is used to display the icon on the patient page
  	Boolean hhistory_done = false;
  	if(phhistory!=null)   	  
  	  hhistory_done = true;  	
  	return hhistory_done;
  }
  
  public String gethealth_history_color() {
  	String hcolor = 'none';
  	if(phhistory!=null) {
  	  if(phhistory.is_complete__c)
  	    hcolor = '#39b17f';
  	  else
  	    hcolor = '#e8e57b';
  	}
  	return hcolor;  	
  }
       
}