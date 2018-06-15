public with sharing class dp_clinical_pot {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  public Account patient {get;set;}
  public String activation_id {get;set;} 
  public Boolean uncomitted_changes {get; set;}
  public String drug_filter {get; set;}
  
  public String pot_name {get;set;}
    
  public String profile_name {get; set;}
  
  public Boolean display_phi {get; set;}
  
  public Patient_Health_History__c phhistory {get; set;}
  
  public Boolean display_patient_search_modal {get; set;}
  public String search_name {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public List<Account> consult_search_results {get; set;}
  
  public Boolean switch_treatment_plan {get; set;}
  public Boolean display_medical_warnings {get; set;}
  public ID existing_pot {get; set;}
  
  public Boolean display_new_treatment_modal {get; set;}
  public String new_pot_name  {get; set;}
  public String lower_arch {get; set;}
  public String upper_arch {get; set;}
  public String selected_pot_tab {get; set;}
  public String new_pot_display {get; set;}
  public String pot_search {get; set;}
  public ID pot_opp {get; set;}
  
  public Boolean confirmation_modal_display {get; set;}
  public String confirmation_modal_type {get; set;}
  public String modal_out {get; set;}
  
  public String new_apt_form_id {get; set;}
  public String new_apt_name {get; set;}
  public String new_proc_name {get; set;}
  public String new_proc_ada {get; set;}
  public String new_proc_form_id {get;set;}
  public Boolean display_new_proc_form {get; set;}
  public String apt_filter {get; set;}
  public String procedure_filter {get; set;}
  
  public Boolean display_tooth_modal {get; set;}
  public ID proc_id {get; set;}
  
  public Boolean display_history_modal {get; set;}
  public ID apt_id {get; set;}
  
  public ID current_edit {get; set;}
  
  public pot[] displayed_plans {get; set;}
  
  public String[] arch_options = new String[] {'Any','Arch Replacement','Denture','Implant Bridge','Multiple','None','Phased','Single','Zirconia'};
  
  public Boolean display_clearance_form {get; set;}
  public Patient_POT__c current_srx_pot {get; set;}
  public Patient_POT__c current_mc_pot {get; set;}
  public Patient_POT__c current_lrx_pot {get; set;}
  public Medical_Clearance__c new_med_clearance {get; set;}
  
  public Attachment new_mc_attachment {get;set;}
  public Boolean display_mc_attachment_form {get;set;} 
  
  public Attachment new_rx_attachment {get;set;}
  public Boolean display_attachment_form {get;set;}
  
  public Attachment new_sx_attachment {get;set;}
  public Boolean display_sx_attachment_form {get;set;}
     
  public Boolean display_lab_rx_form {get; set;}
  public Lab_rx__c new_lab_rx {get; set;}
  
  public Boolean display_surgical_rx_form {get; set;}
  public Surgical_rx__c new_surgical_rx {get; set;}
  
  //stuff for variable tooth selection
  public sObject target_object {get; set;}
  public String target_field {get; set;}
  public String tooth_chart_label {get; set;}
  public Boolean display_var_tooth_modal {get; set;}
  
  Set<String> clinical_profiles;
  Set<String> doctor_profiles;
  Set<ID> market_centers;
  
  public String search_first {get;set;}
  public String search_unique {get; set;}  
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  public Boolean srx_review_display {get; set;}
  
  public transient String photo_data {get;set;}
  public transient String photo_content_type {get;set;}
  public transient String photo_name {get;set;}
  public String current_edit_id {get; set;}
  
  public Date report_sdate {get; set;}
  public Date report_edate {get; set;}
  
  public String confirmation_id {get; set;}
  
  public class bendException extends Exception {}	
  public Boolean zero_balance_override {get; set;}  
  public Boolean display_cost_info {get; set;}
  public List<SelectOption> doc_list; 
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()]; 
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
    
  static StaticResource sr = [SELECT id,name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = 'CCLogo_Transparent' limit 1];
  
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}   

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
	  
  public dp_clinical_pot() {
  	display_medical_warnings = true;
  	drug_filter = 'All';
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
        //User u = [select clinic_calendar__c from user where id =:userinfo.getUserId()];         
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,default_pot_tab__r.name,default_pot_tab__c,sales_region__c,	Allow_ADA_Cost_Display__c,Use_Alternate_Url__c,	Lab_RX_display_PHI__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,default_pot_tab__r.name,default_pot_tab__c,sales_region__c, Allow_ADA_Cost_Display__c,Use_Alternate_Url__c,	Lab_RX_display_PHI__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,default_pot_tab__r.name,default_pot_tab__c,sales_region__c, Allow_ADA_Cost_Display__c,Use_Alternate_Url__c,	Lab_RX_display_PHI__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
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
  	  	
  	display_phi = current_center.Lab_RX_display_PHI__c;
  	display_history_modal = false;
  	display_new_treatment_modal = false;
  	display_new_proc_form = false;
  	new_apt_form_id = null;
  	new_proc_form_id = null; 	
  	confirmation_modal_display = false;
  	current_edit = null;	
  	display_tooth_modal = false;
  	display_clearance_form = false;
  	display_lab_rx_form = false;
  	display_surgical_rx_form = false;
  	display_var_tooth_modal = false;
  	switch_treatment_plan = false;
  	srx_review_display = false;
  	current_edit_id = null;
  	profile_name = [select name from profile where id = :userinfo.getprofileid()].name;
  	clinical_profiles = new Set<String>();
  	clinical_profiles.add('Clinical Doctor');
  	clinical_profiles.add('Clinical Assistant');
  	clinical_profiles.add('System Administrator');
  	clinical_profiles.add('SF - Clinical Doctor');
  	clinical_profiles.add('SF - Clinical Assistant');
  	doctor_profiles = new Set<String>();
  	doctor_profiles.add('Clinical Doctor');
  	doctor_profiles.add('SF - Clinical Doctor');  	
    num_patient_records = 20;
    display_more_search_records = false;    
    uncomitted_changes = false;
    display_attachment_form = false;
    display_sx_attachment_form = false;
    display_mc_attachment_form = false;
    if(apexpages.currentpage().getparameters().get('srxid')!=null) {
      edit_existing_surgical_rx_form();
    }
    report_sdate = Date.newinstance(2010,1,1);
    report_edate = System.today();
    zero_balance_override = false;
    display_cost_info = false;    
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
  	User current_user = [Select u.Name, u.Id,userrole.name, clinic_calendar__c, regional_traveler__c From User u where id = :userinfo.getuserid()];
  	//admin or user is a traveler by role - display all centers  	
  	if(display_corp_admin || current_user.userrole.name=='Traveler - PEC') 
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id order by name];
  	//regional traveler - display all centers in this region
  	else if(current_user.regional_traveler__c)
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
  	  current_center = [select id,name,market__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,default_pot_tab__r.name,default_pot_tab__c,sales_region__c,	Allow_ADA_Cost_Display__c,Use_Alternate_Url__c, Lab_RX_display_PHI__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  market_centers = getcenters_in_market();
  	  patient = null;
  	  doc_list = null;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public void toggle_uncomitted_status() {
  	uncomitted_changes = true;
  }  
  
  public Pagereference confirm_navigate_to() {
  	//user has decided to press ahead with unsaved changes - woe is them
  	uncomitted_changes = false;
  	return navigate_to();
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
  
  public void open_history_modal() {
  	display_history_modal = true;
  	apt_id =  apexpages.currentpage().getparameters().get('aptid');
  }
  
  public void close_history_modal() {
  	display_history_modal = false;
  	apt_id = null;
  }
  
  public String getapt_history_name() {
  	return [select name from Patient_POT_Apt__c where id = :apt_id].name;
  }
  
  public List<Clinical_Apt_History__c> getapt_history_list() {
  	//to-do: adjust this to include all of the relevant fields when ready to finish this piece
  	return [select id,name,createddate,createdby.name,action__c,action_reason__c,notes__c from Clinical_Apt_History__c where Patient_POT_Apt__c = :apt_id order by createddate desc];
  }
  
  public void open_variable_tooth_modal() {
  	display_var_tooth_modal = true;
  	String otype = apexpages.currentpage().getparameters().get('object_type');
  	if(otype=='lab')
  	  target_object = new_lab_rx;
  	if(otype=='surgical')
  	  target_object = new_surgical_rx;
  	target_field = apexpages.currentpage().getparameters().get('field_name');
  	tooth_chart_label = apexpages.currentpage().getparameters().get('chart_label');
  }
  
  public void open_tooth_modal() {
  	display_tooth_modal = true;
  	proc_id = apexpages.currentpage().getparameters().get('procid');
  }
  
  public void close_variable_tooth_modal() {
  	display_var_tooth_modal = false;
  	target_object = null;
  	target_field = null;
  	tooth_chart_label = null;
  }
  
  public void close_tooth_modal() {
  	display_tooth_modal = false;
  	proc_id = null;
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
  
  public PageReference navigate_to_recent_patient() {  	  	
    return common_header.pref_to_patient(current_center,apexpages.currentpage().getparameters().get('recentid'));  	  	
  }
  
  public void getpatient_record(String patient_id,String center_id) {
    patient = [select id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,emergency_contact_name__c,emergency_contact_phone__c,
      clinical_notes__c,isPersonAccount,firstname,lastname,date_of_birth__c,PersonContactId,main_photo_id__c,personemail,age__c,warranty_id__c
      from Account where id = :patient_id and center__c in :market_centers];
    doc_list = null;
    try {      
      phhistory = [select id,Is_Complete__c,edit_link__c,Review_Page_Link__c from patient_health_history__c where account__c = :patient.id order by createddate desc limit 1];           
    } catch (Exception e) {
      //not an issue - there is no health history file
      phhistory = null;
    } 
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
  
  public void rx_refresh() {
  	try {
  	  if(patient!=null) 
  	    //refresh perscription info  	
  	    DoseSpotServices.Response dres = DosespotServices.upsert_medication_history(patient.id);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the drug rx information.  Please contact IT for help'));
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
  	  display_medical_warnings = true;
      //verify warranty_id__c is valid
      if(patient.warranty_id__c==null)
        generate_unique_patient_id();
      else if(patient.warranty_id__c.length()>9)
        generate_unique_patient_id(); 
      pr = Page.ccare_clinical_pot;
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
      //refresh perscription info
  	  DoseSpotServices.Response dres = DosespotServices.upsert_medication_history(patient.id);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to setup dosespot for this patient.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return pr;
  	}  
  	return pr;
  }
  
  public void generate_unique_patient_id() {
  	try {
  	  patient.warranty_id__c = guidGenerator.generateWID();
  	  update patient;
  	  //getpatient_record(patient.id,current_center.id);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error generating a unique id for this patient.'));
      ApexPages.addMessages(e);
  	}
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
  
  public String getpot_treatment_plan_name() {
  	String rval = '';
  	Patient_pot__c pp = [select id,opportunity__c from Patient_Pot__c where id = :existing_pot];
  	Opportunity o = [select id,name,preliminary_treatment_plan__c,closedate,treatment_amount__c,(Select Name, Treatment_Option__r.name From Treatment_Plans__r) from Opportunity 
  	  where id = :pp.opportunity__c];
  	System.debug('Opp Plan : ' + o);
  	System.debug('Treatment Plans : ' + o.treatment_plans__r);
  	if(o.treatment_plans__r.size()>0) {
  	  System.debug('Returning : ' + o.treatment_plans__r[0].treatment_option__r.name);  
  	  rval =  o.treatment_plans__r[0].treatment_option__r.name;
  	}
  	else
  	  rval = o.preliminary_treatment_plan__c;
  	
  	return rval;
  }
  
  public void change_treatment_name() {
    display_new_treatment_modal = true;    
    existing_pot = apexpages.currentpage().getparameters().get('potid');
    if(current_center.default_pot_tab__c!=null)
      selected_pot_tab = current_center.default_pot_tab__r.name;
    else
      selected_pot_tab = 'Standard Plans';
    upper_arch = 'Any';
    lower_arch = 'Any';
    new_pot_display = 'name_change';
    pot_search = 'Quick Search';
    pot_name = null;
  }
  
  public void change_treatment_form() {
    display_new_treatment_modal = true;
    switch_treatment_plan = true;
    existing_pot = apexpages.currentpage().getparameters().get('potid');
    //pot_opp = apexpages.currentpage().getparameters().get('opid');
    if(current_center.default_pot_tab__c!=null)
      selected_pot_tab = current_center.default_pot_tab__r.name;
    else
      selected_pot_tab = 'Standard Plans';
    upper_arch = 'Any';
    lower_arch = 'Any';
    new_pot_name = 'Enter Plan Name';
    new_pot_display = 'pot';
    pot_search = 'Quick Search';
  }
  
  public void new_treatment_form() {
  	display_new_treatment_modal = true;
  	pot_opp = null;
  	selected_pot_tab = null;
  	upper_arch = 'Any';
  	lower_arch = 'Any';
  	new_pot_name = 'Enter Plan Name';
  	new_pot_display = 'start';
  	pot_search = 'Quick Search';
  }
     
  public void close_treatment_form() {
  	display_new_treatment_modal = false;
  }
  
  public Boolean getis_clinical_profile() {
  	return clinical_profiles.contains(profile_name);
  }
  
  public Boolean getis_user_doctor() {
  	return doctor_profiles.contains(profile_name);
  }
  
  public List<Plan_of_Treatment__c> getsearch_treatment_plans() {
  	List<Plan_of_Treatment__c> pot_list = new List<Plan_of_Treatment__c> ();
  	//to-do: build query filter and search for matching treatment plans
  	String query_filter = '';
  	if(selected_pot_tab=='Standard Plans' && current_center.name != 'Philadelphia')
  	  query_filter += ' where center_information__r.name = \'Unknown\' and doctor__c = null ';
  	else if(selected_pot_tab=='Standard Plans' && current_center.name == 'Philadelphia')
  	  query_filter += ' where center_information__r.name = \'Philadelphia\' and doctor__c = null ';
  	else 
  	  query_filter += ' where center_information__c = \'' + current_center.id + '\' and doctor__r.name = \'' + selected_pot_tab + '\' ';
  	query_filter += ' and isactive__c = true ';
  	//check to see if this is a doctor or assistant - otherwise only offer non doctor selections (Prosth Exam POTs)
  	if(!clinical_profiles.contains(profile_name))
      query_filter += ' and Non_Doctor_Selection__c = true ';        	
  	//check for a quick search filter
  	if(pot_search != '' && pot_search != 'Quick Search') 
  	  query_filter += ' and (name like \'%' + pot_search + '%\' or treatment_description__c like \'%' + pot_search + '\') ';
  	//check for arch filters
  	if(upper_arch != 'Any')
  	  query_filter += ' and upper_arch__c = \'' + upper_arch + '\' ';
  	if(lower_arch != 'Any')
  	  query_filter += ' and lower_arch__c = \'' + lower_arch + '\' ';
    System.debug('PPOT Search Query : ' + 'Select id,name,treatment_description__c from plan_of_treatment__c ' + query_filter + ' order by name');  	  
  	for(Plan_of_Treatment__c pt : database.query('Select id,name,treatment_description__c from plan_of_treatment__c ' + query_filter + ' order by name')) {
  	  pot_list.add(pt);
  	}
  	return pot_list;
  }
  
  public void select_treatment_plan() {
  	//to-do: build the entries for the treatment plan in the following tables patient_pot,  patient_pot_apts,  patient_pot_apt_procedures
  	try {
      Integer starting_sort_order;  
      Integer sort_differential = 0;
      Patient_POT__c new_pt;
      Plan_of_Treatment__c pt = [select id,name,treatment_description__c,center_information__c, center_information__r.name from Plan_of_Treatment__c where id = :apexpages.currentpage().getparameters().get('potid')];	  
  	  //check to see if we're switching a plan
  	  if(switch_treatment_plan) {  	  	  	  	
  	  	new_pt = [select plan_of_treatment__c, plan_of_treatment__r.Non_Doctor_Selection__c, account__c, treatment_description__c,name 
      	  from Patient_POT__c
      	  where id = :existing_pot];
      	//this rule is no longer true - they are allowed to switch any plan if nothing has been scheduled past the prosth exam apt (sort order 1)      	 
      	//if(!new_pt.plan_of_treatment__r.non_doctor_selection__c)
          //throw new bendException('You are currently unable to change this plan.  Please contact IT for help');                        
        //switch the plan to the newly selected one 
        new_pt.plan_of_treatment__c = pt.id;
        new_pt.name = pt.name;
        new_pt.treatment_description__c = pt.treatment_description__c;
        update new_pt;
        starting_sort_order = 1;
        switch_treatment_plan = false;       
        //modified by cm on 2017/6/1 - per a request from Andy Mcmullen.  We no longer want these to auto-delete
        //since they can now switch plans that haven't been scheduled yet,  I need to check and see if there are already apts/procedures in the plan past sort order 1
        //modified by cm on 2017/6/7 - per request by Andy McMullen
        //now checking and deleting anything that doesn't have calendar entries
        List<Patient_POT_Apt__c> old_apts = [select id,(Select Id From Clinical_Apt_Calendar__r),clinical_appointment__r.isProsth_Exam__c from patient_pot_apt__c where sort_order__c > 1 and patient_pot__c = :new_pt.id];
        if(old_apts.size()>0) {
          Set<ID> old_apt_ids = new Set<ID>();
          List<Patient_POT_Apt__c> old_apts_removal_list = new List<Patient_POT_Apt__c>();
          for(Patient_POT_Apt__c old_ppa : old_apts) {
          	if(old_ppa.clinical_apt_calendar__r.size()==0 && !old_ppa.clinical_appointment__r.isProsth_Exam__c) {
          	  old_apt_ids.add(old_ppa.id);
          	  old_apts_removal_list.add(old_ppa);
          	}
          } 	
          List<Patient_POT_Apt_Procedure__c> old_procs = [select id from patient_pot_apt_procedure__c where patient_pot_apt__c in :old_apt_ids];
          delete old_procs;
          delete old_apts_removal_list;
        }       
        /*List<Patient_POT_Apt__c> old_apts = [select id from patient_pot_apt__c where sort_order__c > 1 and patient_pot__c = :new_pt.id];
        if(old_apts.size()>0) {
          Set<ID> old_apt_ids = (new Map<Id, Patient_Pot_Apt__c>(old_apts)).keyset();
          List<Patient_POT_Apt_Procedure__c> old_procs = [select id from patient_pot_apt_procedure__c where patient_pot_apt__c in :old_apt_ids];
          delete old_procs;
          delete old_apts;
        }*/
        try {
          Patient_Pot_Apt__c ppa_max_sort = [select sort_order__c from patient_pot_apt__c where patient_pot__c = :new_pt.id order by sort_order__c desc limit 1];
          sort_differential = ppa_max_sort.sort_order__c.intvalue()-1;
        } catch (Exception e) {
        	
        }
  	  }
  	  else {  		  	  
  	    Opportunity o = [select id,accountid from Opportunity where id = :pot_opp];  	    
  	    //check to see if we already have a pot plan for this opportunity - since this is not a switch,  that would be an exception
        Integer existing_count = [select count() from patient_pot__c where opportunity__c = :o.id and account__c = :o.accountid];
        if(existing_count>0) {
      	  throw new bendException('You are currently unable to change this plan.  Please contact IT for help');                	
        }
        else {
      	  new_pt = new Patient_POT__c(Plan_of_Treatment__c = pt.id, opportunity__c = o.id, account__c = o.accountid, treatment_description__c = pt.treatment_description__c, name = pt.name);
  	      insert new_pt;
  	      starting_sort_order = 0;
        }
  	  }  
                    	    	  
  	  List<Patient_POT_Apt__c> new_apt_list = new List<Patient_POT_Apt__c>();
  	  //figure out if a standard plan was used
  	  System.debug('PT : ' + pt);
  	  System.debug('PT Center : ' + pt.center_information__r.name);
  	  if(pt.center_information__r.name=='Unknown') {
  	  	//build a map of appointments in the selected center,  so we can handle the translation and use the centers appointment setup
  	  	Map<String,Clinical_Appointment__c> center_apt_map = new Map<String,Clinical_Appointment__c>();
  	  	for(Clinical_Appointment__c ca : [select id,name,appointment_description__c,lab_time__c,padding_time__c from Clinical_Appointment__c where center_information__c = :current_center.id]) {
  	  	  center_apt_map.put(ca.name,ca);
  	  	} 
  	    //work through all of the apts
    	for(POT_Appointment__c pa : [Select p.name, p.Sort_Order__c, p.Plan_of_Treatment__c, p.Id, p.Days_Out__c, p.Clinical_Appointment__c, p.clinical_appointment__r.name, 
  	        p.clinical_appointment__r.appointment_description__c, p.clinical_appointment__r.lab_time__c, p.clinical_appointment__r.padding_time__c  
            From POT_Appointment__c p where plan_of_treatment__c = :pt.id and sort_order__c > :starting_sort_order]) {     
            System.debug('Find Apt ' + pa.clinical_appointment__r.name + ' in map');       	
            Clinical_Appointment__c center_apt = center_apt_map.get(pa.clinical_appointment__r.name);            
    	  	Patient_POT_Apt__c new_apt = new Patient_POT_Apt__c(Appointment_Description__c = center_apt.appointment_description__c,
  	  	    clinical_appointment__c = center_apt.id, days_out__c = pa.days_out__c, isactive__c = true, lab_time__c = center_apt.lab_time__c,
  	  	    padding_time__c = center_apt.padding_time__c, patient_pot__c = new_pt.id, sort_order__c = (pa.sort_order__c + sort_differential), name = center_apt.name);
  	  	  new_apt_list.add(new_apt);  	  	
  	    }  	  	
  	  }
  	  else {
  	    //work through all of the apts
  	    for(POT_Appointment__c pa : [Select p.name, p.Sort_Order__c, p.Plan_of_Treatment__c, p.Id, p.Days_Out__c, p.Clinical_Appointment__c, p.clinical_appointment__r.name, 
    	      p.clinical_appointment__r.appointment_description__c, p.clinical_appointment__r.lab_time__c, p.clinical_appointment__r.padding_time__c  
            From POT_Appointment__c p where plan_of_treatment__c = :pt.id and sort_order__c > :starting_sort_order]) {
  	  	  Patient_POT_Apt__c new_apt = new Patient_POT_Apt__c(Appointment_Description__c = pa.clinical_appointment__r.appointment_description__c,
  	  	    clinical_appointment__c = pa.clinical_appointment__c, days_out__c = pa.days_out__c, isactive__c = true, lab_time__c = pa.clinical_appointment__r.lab_time__c,
  	  	    padding_time__c = pa.clinical_appointment__r.padding_time__c, patient_pot__c = new_pt.id, sort_order__c = (pa.sort_order__c + sort_differential), name = pa.clinical_appointment__r.name);
  	  	  new_apt_list.add(new_apt);  	  	
  	    }  	  	
  	  }  	  
  	  insert new_apt_list;
  	  Map<ID,ID> apt_map = new Map<ID,ID>();
  	  for(Patient_POT_Apt__c pa : new_apt_list) {
  	  	apt_map.put(pa.clinical_appointment__c,pa.id);
  	  }  	    	  
  	  List<Patient_POT_Apt_Procedure__c> new_procedure_list = new List<Patient_POT_Apt_Procedure__c>();
  	  //work through all of the procedures
  	  for(Clinical_Apt_Procedure__c cap : [Select c.SystemModstamp, c.Sort_Order__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Procedure__r.Insurance_Fee__c,
  	      c.Clinical_Procedure__r.Cost__c, c.Clinical_Procedure__r.ADA_Code__c, c.Clinical_Procedure__r.Assistants_Needed__c, c.Clinical_Procedure__r.Doctor_Required__c, 
  	      c.Clinical_Procedure__r.Time_Required__c, c.Clinical_Procedure__r.Procedure_Description__c, c.Clinical_Procedure__c, c.Clinical_Appointment__c, c.clinical_procedure__r.name,
  	      c.Clinical_Procedure__r.allow_tooth_selection__c, c.Clinical_Procedure__r.default_teeth_selection__c
  	      From Clinical_Apt_Procedure__c c where c.Clinical_Appointment__c in : apt_map.keySet()]) {
  	    Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cap.Clinical_Procedure__r.ADA_Code__c, Clinical_Procedure__c = cap.clinical_procedure__c,
  	      Cost__c = cap.Clinical_Procedure__r.Cost__c, Insurance_Fee__c = cap.Clinical_Procedure__r.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = (string)apt_map.get(cap.clinical_appointment__c),
  	      Sort_Order__c = cap.sort_order__c, Time_Required__c = cap.Clinical_Procedure__r.Time_Required__c, name = cap.clinical_procedure__r.name, allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c,
  	      target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c, procedure_description__c = cap.Clinical_Procedure__r.Procedure_Description__c);
  	    new_procedure_list.add(new_procedure);
  	  }  	  
  	  insert new_procedure_list;
  	  check_patient_forms();
  	  close_treatment_form();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a new plan of treatment.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public Integer getnum_available_patient_starts() {
  	return getpatient_available_starts().size();
  }
  
  public class start_plan {
  	public Opportunity o {get; set;}
  	  	
  	public start_plan(Opportunity opp) {
  	  this.o = opp;
  	}
  	
  	public String gettx_name() {
  	  String plan = '';
  	  if(o.Treatment_Plans__r.size()>0)
  	    plan = o.treatment_plans__r[0].treatment_option__r.name;
  	  else
  	    plan = o.preliminary_treatment_plan__c;
  	  return plan;
  	}
  }
  
  public List<start_plan> getpatient_available_starts() {
  	List<start_plan> start_list = new List<start_plan>();
  	for(Opportunity o : [select id,name,preliminary_treatment_plan__c,closedate,treatment_amount__c,(Select Name, Treatment_Option__r.name From Treatment_Plans__r) from Opportunity where accountid = :patient.id and id not in (select opportunity__c from patient_pot__c)]) {
  	  start_plan splan = new start_plan(o);
  	  start_list.add(splan); 
  	}
  	return start_list;
  }
  
  public void select_dr_tab() {
	selected_pot_tab = apexpages.currentpage().getparameters().get('tname');
  }
  
  public String[] getdoctor_tab_list() {
  	String[] dr_name = new String[] {};
  	for(AggregateResult ar : database.query('select doctor__c, doctor__r.name dname from plan_of_treatment__c where isactive__c = true and center_information__c = \'' + current_center.id  + '\' group by doctor__c,doctor__r.name')) {
  	  dr_name.add((string)ar.get('dname'));
  	  //check to see if user id matches 
  	  if(Userinfo.getUserId()==(string)ar.get('doctor__c'))
  	    selected_pot_tab = (string)ar.get('dname');
  	  //check to see if we haven't selected a tab yet - if so default to one  
  	  else if(selected_pot_tab==null)
  	    selected_pot_tab = (string)ar.get('dname');
  	}
  	dr_name.add('Standard Plans');
  	if(new_pot_display!='name_change')
  	  dr_name.add('Blank Template');
  	return dr_name;
  }
  
  public void select_treatment_opp() {
  	System.debug('POT Opp : ' + pot_opp);
  	new_pot_display = 'pot';
  	if(current_center.default_pot_tab__c!=null)
      selected_pot_tab = current_center.default_pot_tab__r.name;
    else
      selected_pot_tab = 'Standard Plans';
  }
  
  public List<String> getupper_arch_options() {
  	List<String> arch_list = new List<String>();
  	for(String option_name : arch_options) {
  	  if(upper_arch != option_name)
  	    arch_list.add(option_name);	
  	}
	return arch_list;
  }
  
  public List<String> getlower_arch_options() {
  	List<String> arch_list = new List<String>();
  	for(String option_name : arch_options) {
  	  if(lower_arch != option_name)
  	    arch_list.add(option_name);	
  	}
	return arch_list;
  }
  
  public void lower_arch_change() {
  	lower_arch = apexpages.currentpage().getparameters().get('aname');
  }
  
  public void upper_arch_change() {
  	upper_arch = apexpages.currentpage().getparameters().get('aname');
  }
  
  public void create_blank_pot() {
  	//check for issues first
  	Integer num_issues = 0;
  	if(new_pot_name=='' || new_pot_name=='Enter Plan Name') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for plan name'));
  	}  	
  	if(num_issues==0) {
  	  try {
  	    Opportunity o = [select id,accountid from Opportunity where id = :pot_opp];
  	    Patient_POT__c new_pt = new Patient_POT__c(opportunity__c = o.id, account__c = o.accountid, treatment_description__c = 'Blank Treatment Plan', name = new_pot_name);
  	    insert new_pt;
  	    close_treatment_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a new plan of treatment.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public class patient_form {
  	public patient_procedure_form__c pform {get;set;}
  	
  	public patient_form(patient_procedure_form__c pf) {
  	  this.pform = pf;
  	}
  	
  	public String getcompleted_date() {
  	  String cdate = '';
  	  if(pform.upload_date__c!=null)
  	    cdate = pform.upload_date__c.format('MM/dd/YYYY');
  	  return cdate;
  	}
  	
  	public String getaction_link() {
  	  //to-do generate download link or upload link here 
  	  String alink = '';
  	  //upload - html
  	  if(pform.form_status__c=='Incomplete')
  	    alink = '<div class="cc-patient-form-scan cc-hover-tooltips-light cc-color-font-hover-blue cc-cursor-hover" onclick="odoc_form(\'' + pform.id + '\');" >' +
          '<i class="ccf-upload"></i>' + 
          '<div class="cc-tooltip cc-center" style="top:40%;">Upload scan</div>' +
          '</div>';
      else      
        //download - html
        alink = '<div class="cc-patient-form-scan cc-hover-tooltips-light cc-color-font-hover-blue cc-cursor-hover" onclick="odoc_form(\'' + pform.id + '\');" >' +
          '<i class="ccf-upload"></i>' + 
          '<div class="cc-tooltip cc-center" style="top:40%;">Document Admin</div>' +
          '</div>&nbsp;'; 
          /*'<div class="cc-patient-form-status-scanned ">' +
                          '<a href="/servlet/servlet.FileDownload?file=' + doc.id + '" target="__blank" class="cc-color-font-hover-blue cc-hover">Scanned</a>' +
                 '</div>';*/
        
  	  return alink;
  	}
  	
  	public Boolean getis_upload() {
  	  if(pform.office_form__c!=null)
  	    return pform.office_form__r.isupload__c;
  	  else
  	    //all manual docs are considered upload
  	    return true;
  	}
  	
  	public Boolean getis_removable() {
      //if the form has an attachment,  it can not be removed
      if(pform.attachments.size()>0)
        return false;
  	  else if(pform.office_form__c!=null) 
  	    return pform.office_form__r.isremovable__c;
  	  else  	  	
  	    return true;
  	}
  }
  
  public class form_section {
  	public String section_name {get; set;}
  	public patient_form[] all_forms {get; set;}
  	
  	public form_section(String sname) {
  	  this.section_name = sname;
  	  this.all_forms = new patient_form[] {};
  	}
  	
  	public Integer getprogress_status() {
      Decimal completion_percent = 100;
  	  Integer total_docs = all_forms.size();
  	  Double completed_docs = 0;
  	  for(patient_form pf : all_forms) {
  	  	if(pf.getis_upload()==false)
  	  	  total_docs--;
  	  	else if(pf.pform.form_status__c=='Scanned')
  	  	  completed_docs++;
  	  }
  	  System.debug('Total Docs : ' + total_docs);
  	  System.debug('Completed Docs : ' + completed_docs);
  	  	
  	  if(total_docs>0) {
  	  	//Decimal dvalue = (completed_docs / total_docs) * 100;
  	  	//completion_percent = dvalue.intvalue();  	  	
  	  	completion_percent = (completed_docs / total_docs) * 100;
  	  } 
  	  return completion_percent.intvalue();
  	}
  	
  	public String getprogress_color() {
  	  String pcolor = 'rgb(245,0,122)';
  	  Integer current_status = getprogress_status();
  	  if(current_status<=25)
  	    pcolor = 'rgb(245,0,122)';
  	  else if(current_status <= 50)
  	    pcolor = 'rgb(245,122,0)';
  	  else if(current_status <= 75)
  	    pcolor = 'rgb(122,0,245)';
  	  else 
  	    pcolor = 'rgb(0,160,243)';
  	  return pcolor;
  	}
  }
  
  
  public class pot {
  	public Patient_POT__c plan {get; set;}
  	public pot_apt[] apts {get; set;}  	
  	
  	public pot(Patient_POT__c p) {
  	  this.plan = p;
  	  this.apts = new pot_apt[] {};
  	}
  	
  	public Boolean getallow_delete() {
      Boolean delete_check = true;
      //to-do:check with Andy and verify when we should allow deletion here
      //check to make sure no apt has been completed or actively scheduled   
      //work through all of the apts and make sure all of them allow delete still - if not,  then the pot can't be deleted either
      for(pot_apt pa : apts) {
      	if(!pa.getallow_delete())
      	  delete_check = false;
      }    
  	  return delete_check;
  	}
  	
  	public Boolean getallow_name_change() {
  	  if(plan.name == 'Legacy Blank Import POT' || plan.createdby.name == 'Chris McDowell')
  	    return true;
  	  else
  	    return false;
  	}
  	
  	public List<Selectoption> getapt_options_list() {
  	  List<Selectoption> clist = new List<Selectoption>();
  	  clist.add(new Selectoption('','Please Select Appointment'));
  	  for(Pot_apt patient_apt : apts) {
  	  	clist.add(new Selectoption(patient_apt.apt.id,patient_apt.apt.name + ' ' + patient_apt.getnext_scheduled_date()));
  	  }  	  
	  return clist;
    }  
  	
  	public String gethandout_name() {
  	  String rval = '';
  	  Opportunity o = [select id,name,preliminary_treatment_plan__c,closedate,treatment_amount__c,(Select Name, Treatment_Option__r.name From Treatment_Plans__r) from Opportunity 
  	    where id = :plan.opportunity__c];
  	  if(o.treatment_plans__r.size()>0) {  
  	    rval =  o.treatment_plans__r[0].treatment_option__r.name;
  	  }
  	  else
  	    rval = o.preliminary_treatment_plan__c;
  	  return rval; 
  	}
  	
  	public Boolean getallow_change() {
  	  Boolean allow_change = true;
  	  //two options here - the first is the plan is a non doctor selection (prosth only plan)
  	  //second option is that the plan has been changed once,  but no appointment has been scheduled yet (they chose the wrong plan scenario), in this case still allow a switch
  	  if(!plan.plan_of_treatment__r.Non_Doctor_Selection__c) {
  	  	//work through the apts and see if anything has been scheduled for them other than the prosth exam apt
  	  	for(pot_apt pa : apts) {
  	  	  //better way might be to check the prosth exam flag,  but all of the logic is built around first appointment right now
  	  	  if(pa.blocks.size()>0 && pa.apt.sort_order__c>1)
  	  	    allow_change = false;
  	  	}
  	  }
  	  return allow_change;
  	}
  	
  	public String getpot_status() {
  	  //to-do:look through the apts and figure out the status here
  	  //possible outcomes - Not Started,  Started (In Porgress), Pending Medical Clearance, Cancelled, Completed
  	  //Andy mentioned we might also want an on-hold....not sure how we'll have this systematically generated and tracked yet.
  	  //String pot_status = 'Not Started';
  	  String pot_status = '';
  	  return pot_status;
  	}
  	
  	public String getcurrent_apt_id() {
  	  String next_apt_id = '';
  	  for(pot_apt pa : apts) {
  	  	if(pa.getallow_scheduling() && next_apt_id=='')
  	  	  next_apt_id = pa.apt.id;
  	  }
  	  return next_apt_id;
  	}
  	
  	public List<Lab_Rx__c> getlab_rx_list() {
      List<Lab_rx__c> lab_list = [Select l.due_date__c,l.provider__c,l.provider__r.name,l.provider__r.doctor_suffix__c, l.Reference_Appointment__c, l.Reference_Appointment__r.name, l.Form_type__c, l.isactive__c, l.Vertical_Open__c, l.Vertical_Maintain_Existing__c, l.Vertical_Close__c, l.UA04__c, l.Tooth_Shade__c, l.tooth_shade_other__c, l.Tooth_Mould__c, l.SystemModstamp, l.Provisional_RPD_teeth__c, l.Patient_POT__c, l.OwnerId, l.Overlap_Vertical__c, l.Overlap_Freeway_Space__c, l.Occlusal_Plan_Maintain_Existing__c, l.Name, l.MxCD__c, l.Midline_set_off_opposing__c, l.Midline_move_right__c, l.Midline_move_left__c, l.Midline_maintain_existing__c, l.MdCD__c, l.LastModifiedDate, l.LastModifiedById, l.LA04__c, l.IsDeleted, l.Id, l.DA04__c, l.singlemultiple__c, l.CreatedDate, l.CreatedById, l.Comments__c, l.BR_upper_right__c, l.BR_upper_left__c, l.BR_lower_right__c, l.BR_lower_left__c, l.Acryllic_Shade__c, l.Account__c,createdby.name,l.display_name__c, l.Whitening_Trays__c, l.Whitening_Tray_Note__c, l.next_pot_apt__c, l.clinical_apt_calendar__c, l.clinical_apt_calendar__r.apt_date__c, l.next_pot_apt__r.name, l.mxrpd__c,l.mdRPD__c,l.description_notes__c,l.midline_notes__c,
       (Select Id, Name, Description From Attachments)  
        From Lab_RX__c l 
        where patient_pot__c = :plan.id and isactive__c = true];
      return lab_list;
  	}
  	
  	public List<Surgical_Rx__c> getsurgical_rx_list() {
  	  List<Surgical_Rx__c> surgery_list = [Select s.Single_Multi_Grafting__c, s.Single_Multi_Grafting_Note__c, s.Max_Grafting__c, s.Max_Grafting_Note__c, s.Mand_grafting__c, s.Mand_Grafting_note__c, s.BMI__c,s.Weight__c, s.SystemModstamp, s.Reason__c, s.Pulse__c, s.Pulse_Ox__c, s.Patient_POT__c, s.OwnerId, s.Name, s.Max_max_left_post_bone_reduction__c, s.Max_max_ant_bone_reduction__c, s.Max_Implant_teeth__c, s.Man_max_right_post_bone_reduction__c, s.Man_max_left_post_bone_reduction__c, s.Man_max_ant_bone_reduction__c, s.Man_implant_teeth__c, s.MAX_max_right_post_bone_reduction__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Placement__c, s.Id, s.Height_Inches__c, s.Height_Feet__c, s.Grafting_as_needed__c, s.Extraction_teeth__c, s.Dr_to__c, s.DR_for__c, s.CreatedDate, s.CreatedById, s.Comments__c, s.BP_Systolic__c, s.BP_Diastolic__c, s.Account__c, s.ASA__c, s.createdby.name,(Select Id, Name, Description From Attachments where (not name like 'Surgical Rx%'))   
  	    From Surgical_RX__c s
  	    where patient_pot__c = :plan.id and isactive__c = true];
  	  return surgery_list;
  	}
  	
  	public List<Medical_Clearance__c> getmedical_clearance_list() {
  	  List<Medical_Clearance__c> mc_list = [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c, m.IsActive__c, m.Id,
  	    m.Health_Condition__c, m.health_condition_other__c, m.Doctor_Specialty__c, m.Doctor_Phone__c, m.Doctor_Name__c, m.Doctor_Fax__c, m.Date_Clearance_Requested__c, m.Account__c,
  	    (Select Id, Name, Description From Attachments)   
  	    From Medical_Clearance__c m
  	    where Patient_Pot__c = :plan.id and isactive__c = true order by createddate desc];
  	  return mc_list;  
  	}
  	
  	public Boolean getneeds_medical_clearance() {
      Boolean med_clearance = false;            
      Integer med_count = 0;
      for(Medical_Clearance__c mc : plan.medical_clearances__r) {
      	if(mc.request_status__c=='Declined')
      	//if(mc.request_status__c=='Pending' || mc.request_status__c=='Declined')
      	  med_count++;
      }
      if(med_count>0)
        med_clearance = true;
      return med_clearance;
  	}
  	
  	public form_section[] getoffice_form_container() {
  	  List<form_section> all_sections = new List<form_section>(); 
  	  form_section current_section;
  	  for(Patient_procedure_Form__c pf : [Select (Select Id, Name, BodyLength, createdby.name, createddate From Attachments), p.Upload_Date__c, p.Patient_POT__c, p.Office_Form__c, p.Form_Status__c, p.Account__c, p.form_name__c,p.forms_category__c,p.office_form__r.isremovable__c,p.office_form__r.isupload__c 
  	    From Patient_Procedure_Form__c p 
  	    where p.patient_pot__c = :plan.id
  	    and isactive__c = true
  	    order by forms_category__c]) {
  	  	if(current_section == null)
  	  	  current_section = new form_section(pf.forms_category__c);
  	  	else if(current_section.section_name!=pf.forms_category__c) {
  	  	  all_sections.add(current_section);
  	  	  current_section = new form_section(pf.forms_category__c);
  	  	}
  	  	patient_form p = new patient_form(pf);
  	  	current_section.all_forms.add(p);
  	  }
  	  if(current_section!=null)
  	    all_sections.add(current_section);
  	  return all_sections;
  	}
  	
  	public Boolean getdisplay_apt_reminders() {
  	  Boolean display_reminders = false;
  	  for(pot_apt pa : apts) {
  	  	for(Clinical_Apt_Calendar__c ca : pa.blocks) {
  	  	  if(ca.apt_date__c > System.today() && ca.apt_status__c==null)
  	  	    display_reminders = true;
  	  	}
  	  }
  	  return display_reminders;
  	}
  	
  }
  
  public class pot_apt {
  	public Patient_POT_Apt__c apt {get; set;}
  	public Patient_POT_Apt__c prior_apt {get; set;}
  	public Patient_POT_Apt_Procedure__c[] procedures {get; set;}
  	public Clinical_Apt_Calendar__c[] blocks {get; set;}
  	public Boolean outstanding_medical_clearance {get; set;}
  	public Boolean on_clipboard {get; set;}
  	//to-do:grab apt history entries for this apt
  	
  	public pot_apt(Patient_POT_Apt__c a,Patient_POT_Apt__c previous,Boolean med_clearance,Boolean on_board) {
  	  this.apt = a;
  	  this.prior_apt = previous;
  	  //this.procedures = new Patient_POT_Apt_Procedure__c[] {};
  	  //this.blocks = new Clinical_Apt_Calendar__c[] {};
  	  //work through the procedures
  	  //for(Patient_POT_Apt_Procedure__c pp : a.Patient_POT_Apt_Procedures__r) {
  	  	//this.procedures.add(pp);
  	  //}
  	  //work through the blocks
  	  this.procedures = a.Patient_POT_Apt_Procedures__r;
  	  this.blocks = a.Clinical_Apt_Calendar__r;
  	  this.outstanding_medical_clearance = med_clearance;
  	  this.on_clipboard = on_board;
  	}
  	
  	public Boolean getallow_delete() {
  	  Boolean delete_check = true; 
  	  //check our blocks and make sure there are no completed visits here
  	  //to-do: check with team and see when we allow delete to hapen
  	  /*for(Clinical_Apt_Calendar__c ca : blocks) {
  	  	//if the block is for today or a date in the future,  do not allow delete
  	  	if(ca.apt_date__c>=system.today())
  	  	  delete_check = false;
  	  	else {
  	  	  //else if the block is in a completed state in the past,  do not allow delete
  	  	  String current_apt_status = blocks[0].apt_status__c==null?'':blocks[0].apt_status__c;
  	  	  Set<String> completed_status = new Set<String>{'Completed','Patient Arrived','Appointment Started','Patient Ready'}; 
  	  	  if(completed_status.contains(current_apt_status)) {
  	  	    delete_check = false;
  	  	  }
  	  	}
  	  }*/
  	  //due to some issues in Atlanta,  and the introduction of the incomplete status,  I'm going to block delete if there are any scheduled blocks on the calendar now
  	  if(blocks.size()>0)
  	    delete_check = false;
  	  return delete_check;
  	}
  	
  	public Integer gettotal_dr_minutes() {  	  
  	  //figuring out time makeup
	  Integer time_before = 0;
	  Integer time_dr = 0;
	  Integer time_after = 0;
	  String current_stage = 'before';
	  for(Patient_POT_Apt_Procedure__c pa : procedures) {
	   	//does the procedure need a doctor
	    if(pa.clinical_procedure__r.doctor_required__c) {
	      //check our stage       
	      if(current_stage=='before') {
	        current_stage = 'doctor';
	        time_dr += pa.time_required__c.intvalue();            
	      }
	      else if(current_stage=='doctor')
	        time_dr += pa.time_required__c.intValue();
	      else if(current_stage=='after') {
	       	//this means we had a non-doctor required procedure in between some required ones.  for now we handle this by builinding a continuous block of dr time
	       	current_stage = 'doctor';
	       	time_dr += pa.time_required__c.intValue() + time_after;
	       	time_after = 0;
	      }
	    } else {
	      //no doctor needed...check our stage
	      if(current_stage=='before')
	        time_before += pa.time_required__c.intvalue();
	      else if(current_stage=='doctor') {
	      	current_stage = 'after';
	       	time_after += pa.time_required__c.intvalue();
	      }
	      else if(current_stage=='after')
	        time_after += pa.time_required__c.intvalue();
	    }        
	  }
	  return time_dr; 
  	}
  	
  	public Integer gettotal_apt_minutes() {
  	  Double tminutes = 0;
  	  for(Patient_POT_Apt_Procedure__c pa : procedures) {
  	  	tminutes += pa.time_required__c;
  	  }
  	  return tminutes.intvalue();
  	}  	
  	
  	public String getcurrent_block_status() {
  	  String current_status = '';
  	  if(blocks.size()>0) {
  	  	current_status = blocks[0].apt_status__c==null?'Scheduled':blocks[0].apt_status__c;
  	  }
  	  if(current_status=='Scheduled' && blocks[0].apt_date__c < System.today())
  	    current_status = 'No Show';
  	  return current_status;
  	}
  	
  	public String getblock_id() {
  	  String bid = '';
  	  if(blocks.size()>0) {
  	  	bid = blocks[0].id;  	  
  	  }
  	  return bid;
  	}
  	
  	public String getnext_scheduled_time() {
  	  String sched_date = '';
  	  //to-do:look at apt calendar and return the next schedule date if we have an upcoming one on the active calendar
  	  if(blocks.size()>0) {
  	  	//make sure the status hasn't been changed
  	  	if(blocks[0].apt_status__c==null && blocks[0].apt_date__c>=System.today()) {
  	  	  Datetime stime = Datetime.newinstance(blocks[0].apt_date__c,Time.newinstance(blocks[0].start_hour_int__c.intvalue(),blocks[0].start_minute_int__c.intvalue(),0,0));   	  	
  	      sched_date = stime.format('h:mm a');
  	      Datetime etime = Datetime.newinstance(blocks[0].apt_date__c,Time.newinstance(blocks[0].end_hour_int__c.intvalue(),blocks[0].end_minute_int__c.intvalue(),0,0));   	  	
  	      sched_date += ' - ' + etime.format('h:mm a');
  	  	}
  	  }
  	  return sched_date;
  	}
  	
  	public String getnext_scheduled_date() {
  	  String sched_date = '';
  	  //to-do:look at apt calendar and return the next schedule date if we have an upcoming one on the active calendar
  	  if(blocks.size()>0) {
  	  	//make sure the status hasn't been changed
  	  	if(blocks[0].apt_status__c==null && blocks[0].apt_date__c>=System.today()) {
  	  	  Datetime adate = Datetime.newinstance(blocks[0].apt_date__c.year(),blocks[0].apt_date__c.month(),blocks[0].apt_date__c.day());   	  	
  	      sched_date = adate.format('M/dd/yy');
  	  	}
  	  }
  	  return sched_date;
  	}
  	
  	public String getapt_completed_date() {
  	  String completed_date = '';
  	  if(blocks.size()>0) {
  	  	String current_apt_status = blocks[0].apt_status__c==null?'':blocks[0].apt_status__c;
  	  	Set<String> completed_status = new Set<String>{'Completed','Patient Arrived','Appointment Started','Patient Ready'}; 
  	  	if(completed_status.contains(current_apt_status)) {
  	  	  Datetime adate = Datetime.newinstance(blocks[0].apt_date__c.year(),blocks[0].apt_date__c.month(),blocks[0].apt_date__c.day());   	  	
  	      completed_date = adate.format('M/dd/yyyy');
  	  	}
  	  }
  	  return completed_date;
  	}
  	
  	public Integer gethistory_count() {
  	  Integer hcount = 0;
  	  //to-do:work through apt history and return a count of history events that are relevant to the team
  	  hcount = apt.clinical_apt_histories__r.size();
  	  return hcount;
  	}
  	
  	public String getcircle_color() {
  	  String css_color = 'blue';
  	  //check to see if apt has been scheduled - yellow
  	  if(this.getnext_scheduled_date()!='')
  	    css_color = 'yellow';
  	  //check to see if apt has been completed - if so pink
  	  if(this.getapt_completed_date()!='')
  	    css_color = 'pink';
  	  return css_color;  	    	    	  
  	}
  	
  	public Boolean getallow_clipboard() {
  	  Boolean sched = true;
  	  System.debug('Checking allow scheduling status for - ' + apt.name);
  	  //see if this is already on the clipboard
  	  if(this.on_clipboard)
  	    return false;
  	  //review the prior apt to see if it has been scheduled
  	  if(prior_apt!=null) {
  	  	System.debug('Looking at previous apt - ' + apt.name);
  	  	//see if this apt has been completed or scheduled
  	  	if(prior_apt.clinical_apt_calendar__r.size()==0) {
  	  	  sched = true;  	  	  
  	  	}
  	  	else {
  	  	  //see if the prior apt status is in no show or patient left..if so then don't allow scheduling here until that is updated
  	  	  String prior_apt_status = prior_apt.clinical_apt_calendar__r[0].apt_status__c==null?'':prior_apt.clinical_apt_calendar__r[0].apt_status__c;
  	  	  if(prior_apt_status=='No Show' || prior_apt_status=='Patient Left') {
  	  	    sched = true;
  	  	  }
  	  	}
  	  }  	  
  	  //check what the calendar looks like for this apt
  	  //do we have a scheduled block for this
  	  if(blocks.size()>0) {
  	  	//if so,  check the apt status for the most recent block....if it's anything other than no show or patient left,  then block scheduling
  	  	String current_apt_status = blocks[0].apt_status__c==null?'':blocks[0].apt_status__c;
  	  	//treat unmarked blocks in the past as no shows
  	  	if(current_apt_status=='' && blocks[0].apt_date__c < System.today())
  	  	  current_apt_status = 'No Show';
  	  	Set<String> allowed_status = new Set<String> {'No Show','Patient Left'};
  	  	if(!allowed_status.contains(current_apt_status)) {
  	  	  sched = false;
  	  	  System.debug('Current Apt Status does not allow for scheduling - ' + current_apt_status + ' - ' + apt.name);  	  	
  	  	}
  	  } 
  	  //check to see if we are waiting on a medical clearance for this Plan of Treatment
  	  //if(outstanding_medical_clearance)
  	    //sched = false;  	   	  
  	  return sched;	
  	}
  	
  	public Boolean getallow_scheduling() {
  	  Boolean sched = true;
  	  System.debug('Checking allow scheduling status for - ' + apt.name);
  	  //review the prior apt to see if it has been scheduled
  	  if(prior_apt!=null) {
  	  	System.debug('Looking at previous apt - ' + apt.name);
  	  	//see if this apt has been completed or scheduled
  	  	if(prior_apt.clinical_apt_calendar__r.size()==0) {
  	  	  sched = false;
  	  	  System.debug('Previous Apt has not been scheduled - ' + apt.name);
  	  	}
  	  	else {
  	  	  //see if the prior apt status is in no show or patient left..if so then don't allow scheduling here until that is updated
  	  	  String prior_apt_status = prior_apt.clinical_apt_calendar__r[0].apt_status__c==null?'':prior_apt.clinical_apt_calendar__r[0].apt_status__c;
  	  	  if(prior_apt_status=='No Show' || prior_apt_status=='Patient Left') {
  	  	    sched = false;
  	  	    System.debug('Prior Apt needs to be rescheduled - ' + apt.name);
  	  	  }
  	  	}
  	  }  	  
  	  //check what the calendar looks like for this apt
  	  //do we have a scheduled block for this
  	  if(blocks.size()>0) {
  	  	//if so,  check the apt status for the most recent block....if it's anything other than no show or patient left,  then block scheduling
  	  	String current_apt_status = blocks[0].apt_status__c==null?'':blocks[0].apt_status__c;
  	  	//treat unmarked blocks in the past as no shows
  	  	if(current_apt_status=='' && blocks[0].apt_date__c < System.today())
  	  	  current_apt_status = 'No Show';
  	  	Set<String> allowed_status = new Set<String> {'No Show','Patient Left'};
  	  	if(!allowed_status.contains(current_apt_status)) {
  	  	  sched = false;
  	  	  System.debug('Current Apt Status does not allow for scheduling - ' + current_apt_status + ' - ' + apt.name);  	  	
  	  	}
  	  } 
  	  //check to see if we are waiting on a medical clearance for this Plan of Treatment
  	  //if(outstanding_medical_clearance)
  	    //sched = false;  	   	  
  	  return sched;
  	}
  }
  
  public pot[] getpatient_pot_list() {
  	//build a map of clipboard items
  	Set<ID> clipboard_apts = new Set<ID>();
  	//for(Clinical_Clipboard__c clip : [select id,patient_pot_apt__c from Clinical_Clipboard__c where createdbyid = :userinfo.getuserid()]) {
  	for(Clinical_Clipboard__c clip : [select id,patient_pot_apt__c from Clinical_Clipboard__c where center_information__c = :current_center.id]) {
      clipboard_apts.add(clip.patient_pot_apt__c);
  	} 
  	displayed_plans = new pot[] {};
  	for(Patient_POT__c p : [Select p.opportunity__c, p.plan_of_treatment__r.Non_Doctor_Selection__c, p.Treatment_Description__c, p.SystemModstamp, p.Plan_of_Treatment__c, p.plan_of_treatment__r.name, p.OwnerId, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.createdby.name, p.CreatedById, p.Account__c, p.doctor_notes__c, p.plan_of_treatment__r.display_handout_name__c, (Select Health_Condition__c, Request_Status__c, IsActive__c, Patient_POT__c From Medical_Clearances__r where isactive__c = true) From Patient_POT__c p where account__c = :patient.id order by createddate desc]) {
  	  pot new_plan = new pot(p);
  	  //grab out apts
  	  Patient_POT_Apt__c last_apt;
  	  for(Patient_POT_Apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, p.doctor_notes__c, (Select Id, Name, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c, allow_tooth_selection__c, target_teeth__c, clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c), (Select Id, Apt_Date__c,apt_status__c From Clinical_Apt_Calendar__r order by apt_date__c desc),(Select Id From Clinical_Apt_Histories__r) From Patient_POT_Apt__c p where isactive__c = true and patient_pot__c = :new_plan.plan.id order by sort_order__c]) {
  	  	Boolean on_clipboard = false;
  	  	if(clipboard_apts.contains(pa.id))
  	  	  on_clipboard = true;
  	    pot_apt new_apt = new pot_apt(pa,last_apt,new_plan.getneeds_medical_clearance(),on_clipboard);
  	    new_plan.apts.add(new_apt);
  	    last_apt = pa;
  	  }
  	  //new_plan.apts = [Select p.Sort_Order__c, p.Padding_Time__c, p.Name, p.Lab_Time__c, p.IsActive__c, p.Id, p.Days_Out__c, p.Appointment_Description__c, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Patient_POT_Apt__c, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c) From Patient_POT_Apt__c p where isactive__c = true and patient_pot__c = :new_plan.plan.id order by sort_order__c];
  	  displayed_plans.add(new_plan);
  	}
  	return displayed_plans;
  }
  
  public void edit_selected_apt() {
  	current_edit = apexpages.currentpage().getparameters().get('aptid');
  	System.debug('Current Edit : ' + current_edit);
  }
  
  //save method for the pot[]
  public void save_pot_changes() {
  	List<Patient_POT__c> pot_list = new List<Patient_POT__c>();
  	List<Patient_POT_Apt__c> apt_list = new List<Patient_POT_Apt__c>();
  	List<Patient_POT_Apt_Procedure__c> proc_list = new List<Patient_POT_Apt_Procedure__c>();
  	//loop through all plans of treatment
  	for(pot p : displayed_plans) {
  	  pot_list.add(p.plan);
  	  //loop through all apts
  	  for(pot_apt a : p.apts) {
  	  	proc_list.addall(a.procedures);
  	  	apt_list.add(a.apt);
  	  }
  	}
  	try {  	
  	  //save changes to the procedures
  	  update proc_list;  	
  	  //save changes to the apts
  	  update apt_list;
  	  //save changes to the pot
  	  update pot_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a new plan of treatment.  Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  	current_edit = null;
  }
  
  public void new_appointment_form() {
  	new_apt_form_id = apexpages.currentpage().getparameters().get('potid');
  	apt_filter = 'All';
  	new_apt_name = 'Enter Appointment';
  }
  
  public void clear_proc_id() {
    new_proc_form_id = null;
  }
  
  public void new_procedure_form() {
   	display_new_proc_form = true;
  	new_proc_form_id = apexpages.currentpage().getparameters().get('aptid');
  	new_proc_name = 'Enter procedure';
  	new_proc_ada = 'Enter ADA';
  	procedure_filter = 'All';
  }
  
  public List<Selectoption> getreference_apt_list() {
  	Set<ID> clipboard_apts = new Set<ID>();
  	//for(Clinical_Clipboard__c clip : [select id,patient_pot_apt__c from Clinical_Clipboard__c where createdbyid = :userinfo.getuserid()]) {
  	for(Clinical_Clipboard__c clip : [select id,patient_pot_apt__c from Clinical_Clipboard__c where center_information__c = :current_center.id]) {
      clipboard_apts.add(clip.patient_pot_apt__c);
  	} 
  	Patient_POT__c p = [Select p.plan_of_treatment__r.Non_Doctor_Selection__c, p.Treatment_Description__c, p.SystemModstamp, p.Plan_of_Treatment__c, p.plan_of_treatment__r.name, p.OwnerId, 
  	  p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.createdby.name, p.Account__c, p.doctor_notes__c, p.opportunity__c,
  	  (Select Health_Condition__c, Request_Status__c, IsActive__c, Patient_POT__c From Medical_Clearances__r where isactive__c = true) 
  	  From Patient_POT__c p where account__c = :patient.id and id = :new_lab_rx.patient_pot__c order by createddate desc];
  	pot lab_pot = new pot(p);
  	//grab our apts
  	Patient_POT_Apt__c last_apt;
  	for(Patient_POT_Apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, p.doctor_notes__c, (Select Id, Name, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c, allow_tooth_selection__c, target_teeth__c, clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c), (Select Id, Apt_Date__c,apt_status__c From Clinical_Apt_Calendar__r order by apt_date__c desc),(Select Id From Clinical_Apt_Histories__r) From Patient_POT_Apt__c p where isactive__c = true 
  	  and patient_pot__c = :lab_pot.plan.id order by sort_order__c]) {
  	  Boolean on_clipboard = false;
  	  if(clipboard_apts.contains(pa.id))
  	    on_clipboard = true;
  	  pot_apt new_apt = new pot_apt(pa,last_apt,lab_pot.getneeds_medical_clearance(),on_clipboard);
  	  lab_pot.apts.add(new_apt);
  	  last_apt = pa;
  	}
  	
  	List<Selectoption> ref_apt_list = new List<Selectoption>();
  	ref_apt_list.add(new Selectoption('','No Appointment Selected'));
  	for(pot_apt apt : lab_pot.apts) {
      if(apt.apt.id==new_lab_rx.reference_appointment__c)
        ref_apt_list.add(new Selectoption(apt.apt.id,apt.apt.name));
      else if(apt.getapt_completed_date()=='' || apt.getapt_completed_date()==System.now().format('M/dd/yyyy'))
        ref_apt_list.add(new Selectoption(apt.apt.id,apt.apt.name));
  	}
  	return ref_apt_list;
  }
  
  public List<Selectoption> getactive_provider_list() {  	
    List<Selectoption> provider_list = new List<Selectoption>();
    Set<String> all_doctor_options = new Set<String>();
    provider_list.add(new Selectoption('','No Provider Selected'));
  	//for(User doctor : [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name order by isactive desc, name]) {
  	for(User doctor : [select u.id,u.name,u.doctor_suffix__c from User u where u.Profile.name in :doctor_profiles and u.clinic_calendar__c = :current_center.name and isactive = true order by isactive desc, name]) {
      String doctor_plus_suffix = doctor.name + (doctor.doctor_suffix__c==null?'':(', ' + doctor.doctor_suffix__c));
  	  provider_list.add(new Selectoption(doctor.id,doctor_plus_suffix));
  	  all_doctor_options.add(doctor.id);
  	}
  	//need to check if there are any surgical rxs with a doctor that is inactive
  	Set<String> assigned_doctors = new Set<String> ();
  	for(Lab_Rx__c lrx : [Select l.due_date__c,l.provider__c,l.provider__r.name,l.provider__r.doctor_suffix__c From Lab_RX__c l where account__c = :patient.id and l.provider__c not in :all_doctor_options and l.provider__c != null]) {
  	  if(!all_doctor_options.contains(lrx.provider__c)) {
  	    String doctor_plus_suffix = lrx.provider__r.name + (lrx.provider__r.doctor_suffix__c==null?'':(', ' + lrx.provider__r.doctor_suffix__c));
  	    provider_list.add(new Selectoption(lrx.provider__c,doctor_plus_suffix));
  	    all_doctor_options.add(lrx.provider__c);
  	  }
  	}  	  	  
  	return provider_list;
  }   
  
  public List<Selectoption> getactive_doctor_list() {
  	if(doc_list==null) {
      doc_list = new List<Selectoption>();
      Set<String> all_doctor_options = new Set<String>();
      Set<ID> all_doctor_ids = new Set<ID>();
      doc_list.add(new Selectoption('NA','No Doctor Selected'));
  	  //for(User doctor : [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name order by isactive desc, name]) {
  	  for(User doctor : [select u.id,u.name,u.doctor_suffix__c from User u where u.Profile.name in :doctor_profiles 
  	    and u.clinic_calendar__c = :current_center.name and isactive = true order by isactive desc, name]) {
  	  	String doctor_plus_suffix = doctor.name + (doctor.doctor_suffix__c==null?'':(', ' + doctor.doctor_suffix__c));
  	    doc_list.add(new Selectoption(doctor.name,doctor_plus_suffix));
  	    all_doctor_options.add(doctor.name);
  	    all_doctor_ids.add(doctor.id);
  	  }
  	  for(User_Center_Assignment__c doctor : [select id,user__c,user__r.name,user__r.doctor_suffix__c from user_center_assignment__c 
  	    where center_information__r.name = :current_center.name  and user__r.isactive = true
  	    and user__r.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and user__c not in :all_doctor_ids]) {
  	      String doctor_plus_suffix = doctor.user__r.name + (doctor.user__r.doctor_suffix__c==null?'':(', ' + doctor.user__r.doctor_suffix__c));
  	      doc_list.add(new Selectoption(doctor.user__r.name,doctor_plus_suffix));
  	      all_doctor_options.add(doctor.user__r.name);	
  	  }  	  
  	  //need to check if there are any surgical rxs with a doctor that is inactive
  	  Set<String> assigned_doctors = new Set<String> ();
  	  for(Surgical_Rx__c srx : [Select s.Dr_to__c, s.DR_for__c, s.Account__c From Surgical_RX__c s where account__c = :patient.id]) {
  	  	if(srx.dr_to__c!=null)
  	      assigned_doctors.add(srx.dr_to__c);
  	    if(srx.dr_for__c!=null)
  	      assigned_doctors.add(srx.dr_for__c);	
  	  }  	
  	  for(String s : assigned_doctors) {
  	    if(!all_doctor_options.contains(s) && s!='NA') {
  	      doc_list.add(new Selectoption(s,s));
  	      all_doctor_options.add(s);
  	    }
  	  }
  	}
  	return doc_list;
  }
  
  public List<Selectoption> getapt_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	for(Schema.PicklistEntry Value : Clinical_Appointment__c.appointment_filter__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  }  
  
  public List<Selectoption> getprocedure_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	for(Schema.PicklistEntry Value : Clinical_Procedure__c.procedure_filter__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }  	
	return clist;
  }  
  
  public Integer getpot_next_proc_sort_value() {
  	Integer next_sort = 1;
  	try {
  	  AggregateResult ar = [select max(sort_order__c) msort from Patient_POT_Apt_Procedure__c where Patient_POT_Apt__c = :new_proc_form_id and isactive__c = true];
  	  if(ar.get('msort')!=null) {
  	    Decimal sort_holder = (Decimal)ar.get('msort');
  	    next_sort = sort_holder.intValue() + 1;
  	  }
  	} catch (Exception e) {
  		
  	}
  	return next_sort;
  }
  
  public Integer getpot_next_sort_value() {
  	Integer next_sort = 1;
  	try {
  	  AggregateResult ar = [select max(sort_order__c) msort from Patient_POT_Apt__c where Patient_POT__c = :new_apt_form_id and isactive__c = true];
  	  if(ar.get('msort')!=null) {
  	    Decimal sort_holder = (Decimal)ar.get('msort');
  	    next_sort = sort_holder.intValue() + 1;
  	  }
  	} catch (Exception e) {
  		
  	}
  	return next_sort;  	
  }  
  
  public void reset_apt_form() {
  	new_apt_name = 'Enter Appointment';
  	apt_filter = 'All';
  }
  
  public void reset_proc_form() {
  	new_proc_name = 'Enter procedure';
  	new_proc_ada = 'Enter ADA';
  	procedure_filter = 'All';
  }
  
  public void hide_apt_form() {
  	new_apt_form_id = null;
  }
  
  public void hide_procedure_form() {
  	new_proc_form_id = null;
  	display_new_proc_form = false;
  }
  
  public List<Clinical_Appointment__c> getsearch_appointments() {
  	List<Clinical_Appointment__c> ca_list;
  	try {
  	  String query_filter = ' where center_information__c = \'' + current_center.id + '\' and isactive__c = true ';
  	  if(new_apt_name!=null)
  	    if(new_apt_name != 'Enter Appointment')
  	      query_filter += ' and (name like \'%' + new_apt_name + '%\' or appointment_description__c like \'%' + new_apt_name + '%\')  ';
  	  if(apt_filter!='All')
  	    query_filter += ' and appointment_filter__c = \'' + apt_filter + '\' ';
  	  //system.debug('Apt Query : select id,name,appointment_description__c from clinical_appointment__c ' + query_filter + ' order by name');
  	  ca_list = database.query('select id,name,appointment_description__c from clinical_appointment__c ' + query_filter + ' order by name');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical appointments for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  	return ca_list;
  }
  
  public List<Clinical_Procedure__c> getsearch_procedures() {
  	List<Clinical_Procedure__c> cp_list;
  	try {
  	  String query_filter = ' where center_information__c = \'' + current_center.id + '\' and isactive__c = true ';
  	  if(new_proc_name!=null)
  	    if(new_proc_name != 'Enter procedure')
  	      query_filter += ' and (name like \'%' + new_proc_name + '%\' or procedure_description__c like \'%' + new_proc_name + '%\')  ';
  	  if(new_proc_ada!=null)
  	    if(new_proc_ada != 'Enter ADA')
  	      query_filter += ' and ada_code__c like \'%' + new_proc_ada + '%\' ';
  	  if(procedure_filter!='All')
  	    query_filter += ' and procedure_filter__c = \'' + procedure_filter + '\' ';
  	  System.debug('Query Filter : ' + query_filter);
  	  cp_list = database.query('select id,name,procedure_description__c from clinical_procedure__c ' + query_filter + ' order by name');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical procedures for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  	return cp_list;
  }
  
  public void select_appointment() {
  	new_apt_name = [select name from Clinical_Appointment__c where id = :apexpages.currentpage().getparameters().get('aptid')].name;
  	add_appointment_step();
  }
  
  public void add_appointment_step() {
  	//see if we have a match
  	Integer proc_matches = [select count() from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	if(proc_matches==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid appointment name'));	
  	} else {
  	  try {    	  	
  	  	Clinical_Appointment__c ca = [select id, appointment_description__c,lab_time__c,padding_time__c,name from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	  	//create and insert record	
  	    Patient_POT_Apt__c new_apt = new Patient_POT_Apt__c(Appointment_Description__c = ca.appointment_description__c,
  	  	  clinical_appointment__c = ca.id, days_out__c = 0, isactive__c = true, lab_time__c = ca.lab_time__c,
  	  	  padding_time__c = ca.padding_time__c, patient_pot__c = new_apt_form_id, sort_order__c = getpot_next_sort_value(), name = ca.name); 	
  	    insert new_apt;
  	    //create procedure entries
  	    List<Patient_POT_Apt_Procedure__c> new_procedure_list = new List<Patient_POT_Apt_Procedure__c>();
  	    //work through all of the procedures
  	    for(Clinical_Apt_Procedure__c cap : [Select c.SystemModstamp, c.Sort_Order__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Procedure__r.Insurance_Fee__c,
  	      c.Clinical_Procedure__r.Cost__c, c.Clinical_Procedure__r.ADA_Code__c, c.Clinical_Procedure__r.Assistants_Needed__c, c.Clinical_Procedure__r.Doctor_Required__c, 
  	      c.Clinical_Procedure__r.Time_Required__c, c.Clinical_Procedure__r.Procedure_Description__c, c.Clinical_Procedure__c, c.Clinical_Appointment__c, c.clinical_procedure__r.name,
  	      c.clinical_procedure__r.allow_tooth_selection__c,c.clinical_procedure__r.default_teeth_selection__c
  	      From Clinical_Apt_Procedure__c c where c.Clinical_Appointment__c = :ca.id]) {
  	      Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cap.Clinical_Procedure__r.ADA_Code__c, Clinical_Procedure__c = cap.clinical_procedure__c,
  	        Cost__c = cap.Clinical_Procedure__r.Cost__c, Insurance_Fee__c = cap.Clinical_Procedure__r.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = new_apt.id,
  	        Sort_Order__c = cap.sort_order__c, Time_Required__c = cap.Clinical_Procedure__r.Time_Required__c, name = cap.clinical_procedure__r.name,
  	        procedure_description__c = cap.Clinical_Procedure__r.Procedure_Description__c, allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c, 
  	        target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c);
  	      new_procedure_list.add(new_procedure);
  	    }  	  
  	    insert new_procedure_list;  
  	    check_patient_forms();	    
  	    hide_apt_form();  	   
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the appointment. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void select_procedure() {
  	new_proc_name = [select name from Clinical_Procedure__c where id = :apexpages.currentpage().getparameters().get('prid')].name;
  	add_procedure_step();
  }
  
  public void add_procedure_step() {
  	//see if we have a match
  	Integer proc_matches = [select count() from Clinical_Procedure__c where name = :new_proc_name and center_information__c = :current_center.id and isactive__c = true];
  	if(proc_matches==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid procedure name'));	
  	} else {
  	  try {    	   	  	
  	  	Clinical_Procedure__c cp = [select id,ada_code__c,cost__c,insurance_fee__c,time_required__c,name,allow_tooth_selection__c,default_teeth_selection__c,procedure_description__c 
  	  	  from Clinical_Procedure__c where name = :new_proc_name and center_information__c = :current_center.id and isactive__c = true];
  	  	//create and insert record
  	  	Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cp.ADA_Code__c, Clinical_Procedure__c = cp.id,
  	      Cost__c = cp.Cost__c, Insurance_Fee__c = cp.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = new_proc_form_id,
  	      procedure_description__c = cp.procedure_description__c, Sort_Order__c = getpot_next_proc_sort_value(), Time_Required__c = cp.Time_Required__c, name = cp.name, 
  	      allow_tooth_selection__c = cp.allow_tooth_selection__c, target_teeth__c = cp.default_teeth_selection__c);  	  	  	  	  	      	    	  	    
  	    insert new_procedure;
        check_patient_forms();
        display_new_proc_form = false;
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the procedure. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void edit_srx_review() {
  	srx_review_display = false;
  }
  
  public void confirm_srx_review() {
  	srx_review_display = false;
  	//modified by cm on 7/25/2017 - Andy requested that surgical rx stay open after saving
  	//close_surgical_rx_form();
  }
  
  public void close_confirmation_pot_name() {
  	display_new_treatment_modal = true;
  	new_pot_display = 'name_change';
  	close_confirmation_modal();
  }
  
  public void close_confirmation_modal() {
  	confirmation_modal_display = false;
  	activation_id = null;
  	confirmation_id = null;
  }
  
  public void commit_pot_name_change() {
  	try {  	
  	  Plan_of_Treatment__c new_pot = [Select p.Treatment_Description__c, p.Name, p.Id From Plan_of_Treatment__c p where id = :pot_name];
  	  Patient_POT__c current_pot = [Select p.Treatment_Description__c, p.Name, p.Id From Patient_POT__c p where id = :existing_pot];  
  	  current_pot.treatment_description__c = new_pot.treatment_description__c;
  	  current_pot.name = new_pot.name;
  	  update current_pot;
  	  pot_name = null;
  	  existing_pot = null;
  	  confirmation_modal_display = false;
  	} catch (Exception e) {
  	  modal_out += '<br />There was an error trying to commit the name change ' + e.getmessage();
  	}
  }
  
  public void confirm_pot_name_change() {
  	confirmation_modal_display = true;
  	confirmation_modal_type = 'pot_name';
  	new_pot_display = null;
  	display_new_treatment_modal = false;
  	pot_name = apexpages.currentpage().getparameters().get('potid');
  	Plan_of_Treatment__c new_pot = [Select p.Treatment_Description__c, p.Name, p.Id From Plan_of_Treatment__c p where id = :pot_name];
  	Patient_POT__c current_pot = [Select p.Treatment_Description__c, p.Name, p.Id From Patient_POT__c p where id = :existing_pot];
  	modal_out = 'Are you sure you want to change the POT name from ' + current_pot.name + ' to ' + new_pot.name; 
  }
  
  public void confirm_proc_removal() {  	
    confirmation_modal_display = true;
    confirmation_modal_type = 'procedure';
  	Patient_POT_Apt_Procedure__c pa = [select id,isactive__c,name,Patient_POT_Apt__c from Patient_POT_Apt_Procedure__c where id=:activation_id];
  	new_proc_form_id = pa.patient_pot_apt__c;
  	modal_out = 'You are about to remove ' + pa.name + ' from this appointment ';
  }
  
  public void confirm_apt_removal() {
    confirmation_modal_display = true;
    confirmation_modal_type = 'appointment';
  	Patient_POT_Apt__c pa = [select id,isactive__c,name from Patient_POT_Apt__c where id=:activation_id];
  	modal_out = 'You are about to remove ' + pa.name + ' from this plan of treatment ';
  }
  
  public void delete_pot_proc() {
  	try {
  	  Patient_POT_Apt_Procedure__c p = [select id,isactive__c,Patient_POT_Apt__c from Patient_POT_Apt_Procedure__c where id=:activation_id];
  	  p.isactive__c = false;
  	  update p;
  	  //resort the procedure list
  	  Integer new_sort_order = 1;
  	  List<Patient_POT_Apt_Procedure__c> active_procs = [select id,sort_order__c from Patient_POT_Apt_Procedure__c where Patient_POT_Apt__c = :p.patient_pot_apt__c and isactive__c = true order by sort_order__c];
  	  for(Patient_POT_Apt_procedure__c pp : active_procs) {
  	  	pp.sort_order__c = new_sort_order;
  	  	new_sort_order++;
  	  }
  	  update active_procs;
      check_patient_forms();
  	  close_confirmation_modal();
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the procedure. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void delete_pot_apt() {
  	try {
  	  //pull procedure tied to this apt and deactivate them
  	  List<Patient_POT_Apt_Procedure__c> proc_list = [select id,isactive__c from Patient_POT_Apt_Procedure__c where Patient_Pot_Apt__c = :activation_id];
  	  for(Patient_POT_Apt_Procedure__c pp : proc_list) {
  	  	pp.isactive__c = false;
  	  }
 	  update proc_list;
  	  //deactivate the actual apt
  	  Patient_POT_Apt__c ppa = [select id,isactive__c,name,Patient_POT__c from Patient_POT_Apt__c where id=:activation_id];
  	  ppa.isactive__c = false;
  	  update ppa;  	
  	  //run through remaining apts and reset the sort order.
  	  Integer new_sort_order = 1; 
  	  List<Patient_POT_Apt__c> active_apts = [select id,sort_order__c from Patient_POT_Apt__c where Patient_POT__c = :ppa.patient_pot__c and isactive__c = true order by sort_order__c]; 
  	  for(Patient_POT_Apt__c pa : active_apts) {
  	  	pa.sort_order__c = new_sort_order;
  	  	new_sort_order++;
  	  }
  	  update active_apts;
  	  check_patient_forms();
  	  close_confirmation_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  //to-do: confirmation of delete apt method
  public void confirm_pot_removal() {
    confirmation_modal_display = true;
    confirmation_modal_type = 'pot';
  	Patient_POT__c p = [select id,name from Patient_POT__c where id=:activation_id];
  	modal_out = 'You are about to remove treatment plan - ' + p.name;
  }
  
  //to-do: delete apt method
  public void delete_full_pot() {
  	try {
  	  //pull apt list tied to this treatment plan 
  	  List<Patient_POT_Apt__c> apt_list = [select id from Patient_POT_Apt__c where Patient_POT__c = :activation_id];
  	  Set<ID> apt_ids = new Set<ID>();
  	  for(Patient_POT_Apt__c pa : apt_list) {
  	  	apt_ids.add(pa.id);
  	  }  	  	  		
  	  //pull procedures tied to this apt and delete them (not worrying about deactivation)  	  
  	  List<Patient_POT_Apt_Procedure__c> proc_list = [select id,isactive__c from Patient_POT_Apt_Procedure__c where Patient_Pot_Apt__c in :apt_ids];  	  
 	  delete proc_list; 	  
 	  //delete the apts
 	  delete apt_list; 	  
  	  //delete the pot
  	  Patient_POT__c p = [select id,name from Patient_POT__c where id=:activation_id];
  	  delete p;  	  
      check_patient_forms();	  
  	  close_confirmation_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void test_apt_sort() {
  	try {
  	  String pot_id = apexpages.currentpage().getparameters().get('potid');
  	  pot_id = pot_id.replace('pot_','');
  	  //System.debug('POT Id : ' + pot_id);
  	  String pass_thru = apexpages.currentpage().getparameters().get('pthru');      
      pass_thru = pass_thru.replace('apt_','');
      //System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      //System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      //List<Patient_POT_Apt__c> apt_list = new List<Patient_POT_Apt__c>();
      Map<ID,Patient_POT_Apt__c> apt_list_map = new Map<ID,Patient_POT_Apt__c> ([select id,sort_order__c from Patient_Pot_Apt__c where patient_pot__c = :pot_id]);      
      for(String my_id : pass_array) {
      	//Patient_POT_Apt__c apt = [select id,sort_order__c from Patient_POT_Apt__c where id = :my_id and patient_pot__c = :pot_id];
      	if(apt_list_map.get(my_id)!=null)
      	  apt_list_map.get(my_id).sort_order__c = sort_order;
      	//apt_list.add(apt);
      	sort_order++;
      }
      update apt_list_map.values();            
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessages(e);	
    }  
  }
  
  public void test_procedure_sort() {
  	try {
  	  String pass_thru = apexpages.currentpage().getparameters().get('pthru');      
      pass_thru = pass_thru.replace('p_','');
      System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      List<Patient_POT_Apt_Procedure__c> proc_list = new List<Patient_POT_Apt_Procedure__c>();
      for(String my_id : pass_array) {
      	Patient_POT_Apt_Procedure__c proc = [select id,sort_order__c from Patient_POT_Apt_procedure__c where id = :my_id];
      	proc.sort_order__c = sort_order;
      	proc_list.add(proc);
      	sort_order++;
      }
      update proc_list;            
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessages(e);	
    }  
  }
  
  //class for tooth
  public class tooth {
  	public String tooth_image {get; set;}
  	public Boolean tooth_selected {get; set;}
  	public Integer tooth_num {get; set;}
  	public perio_chart_tooth__c tooth {get; set;}
  	
  	public tooth(String image, Boolean is_selected, Integer tnum) {
  	  this.tooth_image = image;
  	  this.tooth_selected = is_selected ;
  	  this.tooth_num = tnum;
  	}
  	
  	public String gettooth_direction() {
  	  if(tooth.tooth_integer__c>=1 && tooth.tooth_integer__c <= 16)
  	    return 'f';
  	  else
  	    return 'l';
  	}
  	
  	public String gett_image() {
  	  String image_css = tooth_image;
  	  if(tooth!=null) {
	  	  if(tooth.tooth_type__c=='Natural' && !tooth.endo__c)
	  	    image_css = '/img-perio/' + tooth.name + '.png';
	  	  else if(tooth.tooth_type__c=='Natural' && tooth.endo__c)
	  	    image_css = '/img-perio/' + tooth.name + '-Endodontic.png';
	  	  else if(tooth.tooth_type__c=='Implant')
	  	    image_css = '/img-perio/Implant-' + gettooth_direction() + '.png';
	  	  else if(tooth.tooth_type__c=='Missing')
	  	    image_css = '/img-perio/Missing-l.png';
	  	  else if(tooth.tooth_type__c=='Pontic')
	  	    image_css = '/img-perio/Pontic-' + gettooth_direction() + '.png';
	  	  else if(tooth.tooth_type__c=='Crown' && !tooth.endo__c)
	  	    image_css = '/img-perio/' + tooth.name + '-Crown.png';
	  	  else if(tooth.tooth_type__c=='Crown' && tooth.endo__c)
	  	    image_css = '/img-perio/' + tooth.name + '-Crown-Endodontic.png';  	    
  	  }
  	  return image_css;
  	}  	
  	
  	public String gettooth_label_css() {
  	  String label_css = 'cc-perio-teeth-number-label';
  	  if(tooth!=null) {
  	    if(tooth.decay__c)
  	      label_css += ' cc-perio-thumbToothDecay';
  	  }
  	  return label_css; 
  	}
  }
  
  //method to get tooth chart - array of tooth
  public tooth[] gettooth_chart() {
  	tooth[] tooth_chart = new tooth[] {};
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
  	
  	Patient_Pot_Apt_Procedure__c p = [select id,target_teeth__c from Patient_POT_Apt_Procedure__c where id = :proc_id];
  	String[] selected_teeth = p.target_teeth__c.split(',');
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 1; tnum<=32; tnum++) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  tooth t = new tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum);
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }   
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  //method to get variable upper tooth chart - array of tooth
  public tooth[] getupper_variable_tooth_chart() {
  	tooth[] tooth_chart = new tooth[] {};  	
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
  	
  	System.debug('Target Object : ' + target_object);
  	System.debug('Target Field : ' + target_field);  	
  	
  	String current_target_teeth = (String)target_object.get(target_field);  	
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 1; tnum<=16; tnum++) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  tooth t = new tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum); 
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }    
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  //method to get upper tooth chart - array of tooth
  public tooth[] getupper_tooth_chart() {
  	tooth[] tooth_chart = new tooth[] {};  	
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
  	
  	Patient_Pot_Apt_Procedure__c p = [select id,target_teeth__c from Patient_POT_Apt_Procedure__c where id = :proc_id ];  	
  	String[] selected_teeth = (p.target_teeth__c==null ? new String[] {'999'} : p.target_teeth__c.split(','));
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 1; tnum<=16; tnum++) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  tooth t = new tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum); 
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }    
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  //method to get variable lower tooth chart - array of tooth
  public tooth[] getlower_variable_tooth_chart() {
  	tooth[] tooth_chart = new tooth[] {};  	
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
  	
  	System.debug('Target Object : ' + target_object);
  	System.debug('Target Field : ' + target_field); 
  	
  	String current_target_teeth = (String)target_object.get(target_field);  	
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 32; tnum>=17; tnum--) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  tooth t = new tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum); 
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }    
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  //method to get lower tooth chart - array of tooth
  public tooth[] getlower_tooth_chart() {
  	tooth[] tooth_chart = new tooth[] {};
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
  	Patient_Pot_Apt_Procedure__c p = [select id,target_teeth__c from Patient_POT_Apt_Procedure__c where id = :proc_id];
  	String[] selected_teeth = (p.target_teeth__c==null ? new String[] {'999'} : p.target_teeth__c.split(','));
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	for(Integer tnum = 32; tnum>=17; tnum--) {
  	  String timage = 'img-perio/' + String.valueOf(tnum) + '.png';
  	  tooth t = new tooth(timage, teeth_set.contains(String.valueOf(tnum)) ,tnum); 
  	  if(tooth_map.get(tnum)!=null) {
  	  	System.debug('Adding tooth record');
  	    t.tooth = tooth_map.get(tnum);
  	  }    
  	  tooth_chart.add(t);
  	}  	
  	return tooth_chart;
  }
  
  public Boolean getvariable_tooth_max_selected() {
  	System.debug('Target Object : ' + target_object);
  	System.debug('Target Field : ' + target_field); 
  	String current_target_teeth = (String)target_object.get(target_field);  
  	if(current_target_teeth=='')
  	  current_target_teeth=null;  		
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	String clicked_tooth = apexpages.currentpage().getparameters().get('toothid');  	
  	return teeth_set.contains('All Max');
  }
  
  public Boolean getvariable_tooth_mand_selected() {
  	System.debug('Target Object : ' + target_object);
  	System.debug('Target Field : ' + target_field); 
  	String current_target_teeth = (String)target_object.get(target_field);  
  	if(current_target_teeth=='')
  	  current_target_teeth=null;  		
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
  	String clicked_tooth = apexpages.currentpage().getparameters().get('toothid');  	
  	return teeth_set.contains('All Mand');
  }
  
  //method to toggle a tooth
  public void toggle_variable_tooth_selection() {
  	System.debug('Target Object : ' + target_object);
  	System.debug('Target Field : ' + target_field); 
  	String current_target_teeth = (String)target_object.get(target_field);  
  	if(current_target_teeth=='')
  	  current_target_teeth=null;  		
  	String[] selected_teeth = (current_target_teeth==null ? new String[] {'999'} : current_target_teeth.split(','));
  	System.debug('Selected teeth : ' + selected_teeth);
  	Set<String> teeth_set = new Set<String>(selected_teeth);
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
  	  if(s=='All Max')
  	    sort_teeth.add(-2);
  	  else if(s=='All Mand')
  	    sort_teeth.add(-1);
  	  else
  	    sort_teeth.add(Integer.valueof(s));
  	}
  	sort_teeth.sort();  	  
  	//build the new target string
  	String new_target = '';
  	for(Integer t : sort_teeth) {
  	  if(t==-2)
  	    new_target += 'All Max,';
  	  else if(t==-1)
  	    new_target += 'All Mand,';
  	  else
  	    new_target += String.valueof(t) + ',';
  	}  	
  	System.debug('New Target : ' + new_target);
  	target_object.put(target_field,(new_target.removeEnd(',').replace(',999',''))); 
  	toggle_uncomitted_status();
  	/*try {
  	  update target_object;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating tooth selection. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}*/
  }  
      
  //method to toggle a tooth
  public void toggle_tooth_selection() {
  	Patient_Pot_Apt_Procedure__c p = [select id,target_teeth__c from Patient_POT_Apt_Procedure__c where id = :proc_id];
  	String[] selected_teeth = (p.target_teeth__c==null ? new String[] {'999'} : p.target_teeth__c.split(','));
  	Set<String> teeth_set = new Set<String>(selected_teeth);
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
  	p.target_teeth__c = new_target.removeEnd(',').replace(',999','');  	
  	try {
  	  update p;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating tooth selection. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void display_new_surgical_rx_form() {
  	display_surgical_rx_form = true;
  	current_srx_pot = [select id, account__c from Patient_Pot__c where id = :apexpages.currentpage().getparameters().get('potid')];
  	new_surgical_rx = new Surgical_rx__c(account__c = current_srx_pot.account__c, patient_pot__c = current_srx_pot.id, isactive__c = true, center_information__c = current_center.id);
  	try {insert new_surgical_rx;} catch (Exception e) {ApexPages.addMessages(e);}
  	uncomitted_changes = false;
  	new_surgical_rx = getsurgical_rx(new_surgical_rx.id);
  	//to-do:try to figure out default values for max_implant teeth (1-16) and man_implant_teeth (17-32)
  	//this might be hard,  because the code will need to figure out which surgery appointment and specific procedure to pull the values from  	
  }
  
  public pot_apt getnext_pot_apt(String pot_id) {
  	pot_apt ppa = null;
  	//cycle through plans of treatment and find the one we're working on
  	for(pot p : displayed_plans) {
  	  if(p.plan.id==pot_id) {
  	  	System.debug('Found POT');
  	  	//found our plan....now work through the apts to figure out which one is next
  	  	for(pot_apt pa : p.apts) {
  	  	  //check if block has a completion date
  	  	  if(pa.getapt_completed_date()=='' && ppa==null) {
  	  	  	System.debug('Found Incomplete Apt');
  	  	    ppa = pa;  	  	  
  	  	  }
  	  	}
  	  }
  	}
  	return ppa;
  }
  
  public void reset_lab_next_apt() {
  	current_lrx_pot = [select id, account__c from Patient_Pot__c where id = :new_lab_rx.patient_pot__c];
  	System.debug('Starting Reset');
  	pot_apt next_apt = getnext_pot_apt(current_lrx_pot.id);
  	System.debug('Starting Reset - ' + next_apt);
  	Clinical_Apt_Calendar__c next_sched = null;  	
  	if(next_apt.blocks.size()>0) {  	  
  	  System.debug('Block : ' + next_apt.blocks[0].apt_status__c + ' - ' + next_apt.blocks[0].apt_date__c);
  	  if(next_apt.blocks[0].apt_status__c==null && next_apt.blocks[0].apt_date__c>=System.today()) {
  	    next_sched = next_apt.blocks[0];
  	  }
  	}
  	System.debug('Starting Reset - ' + next_sched);  	
  	String next_apt_id = (next_apt==null?null:next_apt.apt.id);
  	String next_sched_id = (next_sched==null?null:next_sched.id);
  	new_lab_rx.next_pot_apt__c = next_apt_id;
  	new_lab_rx.clinical_apt_calendar__c = next_sched_id;
  	update new_lab_rx;
  	uncomitted_changes = false;
  	new_lab_rx = getlab_rx(new_lab_rx.id);
  }
  
  public void display_new_lab_rx_form() {
  	display_lab_rx_form = true;
  	current_lrx_pot = [select id, account__c, opportunity__c from Patient_Pot__c where id = :apexpages.currentpage().getparameters().get('potid')];
  	pot_apt next_apt = getnext_pot_apt(current_lrx_pot.id);
  	Clinical_Apt_Calendar__c next_sched = null;
  	if(next_apt != null)  	
  	  if(next_apt.blocks.size()>0) {  	  
  	    if(next_apt.blocks[0].apt_status__c==null && next_apt.blocks[0].apt_date__c>=System.today()) {
  	      next_sched = next_apt.blocks[0];
  	    }
  	  }  	
  	String next_apt_id = (next_apt==null?null:next_apt.apt.id);
  	String next_sched_id = (next_sched==null?null:next_sched.id);
  	new_lab_rx = new Lab_RX__c(account__c = current_lrx_pot.account__c, patient_pot__c = current_lrx_pot.id, isactive__c = true, next_pot_apt__c = next_apt_id, clinical_apt_calendar__c = next_sched_id);
  	clear_uncomitted_changes('new_lab_rx');
  	uncomitted_changes = true;  	 
  	if(patient.warranty_id__c==null)
      generate_unique_patient_id();
    else if(patient.warranty_id__c.length()>9)
      generate_unique_patient_id(); 
  }
  
  public void display_new_clearance_form() {
  	display_clearance_form = true;
  	current_mc_pot = [select id, account__c, opportunity__c from Patient_Pot__c where id = :apexpages.currentpage().getparameters().get('potid')];
  	System.debug('Current_pot ' + current_mc_pot);
  	new_med_clearance = new Medical_Clearance__c(account__c = current_mc_pot.account__c, patient_pot__c = current_mc_pot.id, isactive__c = true,  
  	  date_clearance_requested__c = system.today(), request_status__c = 'Pending');  	
  	uncomitted_changes = true;
  }
  
  public void close_surgical_rx_form() {
  	if(uncomitted_changes) {
  	  confirmation_modal_display = true;
  	  modal_out = 'You might have unsaved changes to the surgical rx.  Are you sure you wish to continue?';
  	  confirmation_modal_type = 'confirm_srx_close';	
  	} else {
  	  display_surgical_rx_form = false;
  	  current_srx_pot = null;
  	  new_surgical_rx = null;
  	}
  }
  
  public void confirm_close_surgical_rx_form() {
  	clear_uncomitted_changes(new_surgical_rx.id==null?'new_surgical_rx':new_surgical_rx.id);
  	uncomitted_changes = false;
  	confirmation_modal_display = false;
  	modal_out = '';
  	confirmation_modal_type = '';
  	close_surgical_rx_form();
  }  
  
  public void close_lab_rx_form() {
  	if(uncomitted_changes) {
      confirmation_modal_display = true;
  	  modal_out = 'You might have unsaved changes to the lab rx.  Are you sure you wish to continue?';
  	  confirmation_modal_type = 'confirm_lrx_close';
  	} else {
  	  display_lab_rx_form = false;
  	  current_lrx_pot = null;
  	  clear_uncomitted_changes((new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id));
  	  //commented this out for now to help with Boston's latency issues
  	  //new_lab_rx = null;
  	}
  }
  
  public void confirm_close_lab_rx_form() {
  	uncomitted_changes = false;
  	confirmation_modal_display = false;
  	modal_out = '';
  	confirmation_modal_type = '';
  	close_lab_rx_form();
  }
  
  public void confirm_close_clearance_form() {
  	uncomitted_changes = false;
  	confirmation_modal_display = false;
  	modal_out = '';
  	confirmation_modal_type = '';
  	close_clearance_form();
  }  
  
  public void close_clearance_form() {
  	if(uncomitted_changes) {
      confirmation_modal_display = true;
  	  modal_out = 'You might have unsaved changes to the medical clearance.  Are you sure you wish to continue?';
  	  confirmation_modal_type = 'confirm_mc_close';
  	} else {  	
  	  display_clearance_form = false;
  	  current_mc_pot = null;
  	  //commenting this out for the moment to see if it might help with Boston latency issues
  	  //new_med_clearance = null;
  	}
  }
  
  public Surgical_RX__c getsurgical_rx(ID srx_id) {
  	return [Select s.Max_Implant_System__c, s.Max_Implant_System_Other__c, s.Man_implant_system__c, s.Man_Implant_System_Other__c, s.Single_Multi_Grafting__c, s.Single_Multi_Grafting_Note__c, 
  	  s.Max_Grafting__c, s.Max_Grafting_Note__c, s.Mand_grafting__c, s.Mand_Grafting_note__c, s.BMI__c,s.isactive__c, s.Weight__c, s.SystemModstamp, s.Reason__c, s.Pulse__c, s.Pulse_Ox__c, 
  	  s.Patient_POT__c, s.OwnerId, s.Name, s.Max_max_left_post_bone_reduction__c, s.Max_max_ant_bone_reduction__c, s.Max_Implant_teeth__c, s.Man_max_right_post_bone_reduction__c, 
  	  s.Man_max_left_post_bone_reduction__c, s.Man_max_ant_bone_reduction__c, s.Man_implant_teeth__c, s.MAX_max_right_post_bone_reduction__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, 
  	  s.Implant_Placement__c, s.Id, s.Height_Inches__c, s.Height_Feet__c, s.Grafting_as_needed__c, s.Extraction_teeth__c, s.Dr_to__c, s.DR_for__c, s.CreatedDate, s.CreatedById, s.Comments__c, 
  	  s.BP_Systolic__c, s.BP_Diastolic__c, s.Account__c, s.ASA__c, s.createdby.name, s.upper_arch_sinus_grafting__c, s.upper_arch_sinus_grafting_right__c, s.upper_arch_sinus_grafting_left__c,
  	  s.sm_sinus_grafting__c, s.sm_sinus_grafting_left__c, s.sm_sinus_grafting_right__c, s.extraction_notes__c, s.sm_implant_system__c, s.sm_implant_system_other__c, s.sm_implant_system_type__c,
  	  s.lower_immediate_load__c, s.lower_immediate_placement__c, s.lower_immediate_load_notes__c, s.upper_immediate_load__c, s.upper_immediate_placement__c, s.upper_immediate_notes__c ,
  	  s.sm_immediate_load__c, s.sm_immediate_placement__c, s.sm_immediate_load_notes__c, s.include_upper_arch__c, s.include_lower_arch__c, s.include_sm__c, s.reviewed_by__r.name, s.review_time__c, s.reviewed_by__c,
  	  s.center_information__r.legal_name__c,s.center_information__r.street_1__c,s.center_information__r.street_2__c,s.center_information__r.city__c,s.center_information__r.state__c,s.center_information__r.zip_code__c,
  	  (Select Id, Name, Description From Attachments where (not name like 'Surgical Rx%')) 
  	  From Surgical_RX__c s
  	  where id = :srx_id];
  }
  
  public void edit_existing_surgical_rx_form() {
  	display_surgical_rx_form = true;
  	new_surgical_rx = getsurgical_rx(apexpages.currentpage().getparameters().get('srxid'));
  	current_srx_pot = [select id, account__c from Patient_Pot__c where id = :new_surgical_rx.patient_pot__c];
  	clear_uncomitted_changes(apexpages.currentpage().getparameters().get('srxid'));
  }
  
  public void edit_existing_lab_rx_form() {
  	display_lab_rx_form = true;
  	new_lab_rx = getlab_rx(apexpages.currentpage().getparameters().get('lrxid'));
  	current_lrx_pot = [select id, account__c from Patient_Pot__c where id = :new_lab_rx.patient_pot__c];
  	clear_uncomitted_changes(apexpages.currentpage().getparameters().get('lrxid'));
  	if(patient.warranty_id__c==null)
      generate_unique_patient_id();
    else if(patient.warranty_id__c.length()>9)
      generate_unique_patient_id(); 
  } 
  
  static lab_rx__c generic_lab_rx;
  public Lab_Rx__c getgeneric_lab_rx() {
  	return getlab_rx(apexpages.currentpage().getparameters().get('lrxid'));
  }
  
  public string getgeneric_lab_rx_provider_license() {
  	try {
  	  String license_text = '';
  	  for(Medical_License__c ml : [select id,license_number__c,license_type__c,license_expiration_date__c,license_issue_date__c from Medical_License__c 
  	    where doctor__c = :getgeneric_lab_rx().provider__c
  	    order by license_expiration_date__c]) {
  	    license_text += 'License #: ' + ml.license_number__c + '<br />';  	
  	  }
  	  return license_text;  	  
  	} catch (Exception e) {
  	  return '';
  	}
  }
  
  public Lab_RX__c getlab_rx(ID lrx_id) {
  	return [Select l.due_date__c,l.provider__c,l.provider__r.name,l.provider__r.doctor_suffix__c, l.Reference_Appointment__c, l.Reference_Appointment__r.name,l.Form_type__c, l.Occlusal_Plane__c, l.Occlusal_Plane_Other__c, l.isactive__c, l.Vertical_Open__c, l.Vertical_Maintain_Existing__c, l.Vertical_Close__c, l.UA04__c, l.Tooth_Shade__c, 
  	  l.Tooth_Mould__c, l.SystemModstamp, l.Provisional_RPD_teeth__c, l.Patient_POT__c, l.OwnerId, l.Overlap_Vertical__c, l.Overlap_Freeway_Space__c, l.Occlusal_Plan_Maintain_Existing__c, 
  	  l.Name, l.MxCD__c, l.Midline_set_off_opposing__c, l.Midline_move_right__c, l.Midline_move_left__c, l.Midline_maintain_existing__c, l.MdCD__c, l.LastModifiedDate, l.LastModifiedById, l.LA04__c, 
  	  l.IsDeleted, l.Id, l.DA04__c, l.singlemultiple__c, l.CreatedDate, l.CreatedById, l.Comments__c, l.BR_upper_right__c, l.BR_upper_left__c, l.BR_lower_right__c, l.BR_lower_left__c, l.Acryllic_Shade__c, l.Account__c,
  	  createdby.name, l.overlap_horizontal__c, l.br_upper_anterior__c, l.br_lower_anterior__c, l.reviewed_by__r.name, l.review_time__c, l.reviewed_by__c, l.tooth_shade_other__c, l.Whitening_Trays__c, 
  	  l.Whitening_Tray_Note__c, l.next_pot_apt__c, l.clinical_apt_calendar__c, l.clinical_apt_calendar__r.apt_date__c, l.next_pot_apt__r.name, l.mxrpd__c,l.mdrpd__c,l.description_notes__c,l.midline_notes__c,
  	  (Select Id, Name, Description From Attachments)  
  	  From Lab_RX__c l
  	  where id = :lrx_id];
  } 
  
  public void review_lab_rx() {
  	try {
  	  new_lab_rx.reviewed_by__c = userinfo.getUserId();
  	  new_lab_rx.review_time__c = system.now();
  	  update new_lab_rx;
  	  new_lab_rx = getlab_rx(new_lab_rx.id);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the lab rx.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);	
  	}
  }
  
  public void review_surgical_rx() {
  	try {
  	  new_surgical_rx.reviewed_by__c = userinfo.getUserId();
  	  new_surgical_rx.review_time__c = system.now();
  	  update new_surgical_rx;
  	  new_surgical_rx = getsurgical_rx(new_surgical_rx.id);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the surgical rx.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);	
  	}
  }
  
  public void edit_existing_clearance_form() {
  	display_clearance_form = true;
  	new_med_clearance = [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c,  m.IsActive__c, m.Health_Condition__c, m.health_condition_other__c, m.Doctor_Specialty__c, 
  	  m.Doctor_Phone__c, m.Doctor_Name__c, m.Doctor_Fax__c, m.Date_Clearance_Requested__c, m.Account__c,(Select Id, Name, Description From Attachments)  From Medical_Clearance__c m where id = :apexpages.currentpage().getparameters().get('mcid')];
  	current_mc_pot = [select id, account__c from Patient_Pot__c where id = :new_med_clearance.patient_pot__c];    	  	
  }
    
  
  public void cancel_surgical_rx_form() {
  	if(new_surgical_rx.id==null) {
  	  close_surgical_rx_form();
  	  uncomitted_changes = false;
  	} else {
  	  confirmation_modal_display = true;
  	  confirmation_modal_type = 'surgical_rx';
  	  modal_out = 'Are you sure you want to delete this surgical rx form';
  	}
  }
  
  public void cancel_lab_rx_form() {
  	//check to see if we're working non a new lab rx file,  or an existing one
  	if(new_lab_rx.id==null) {
  	  close_lab_rx_form();
  	} else {
  	  //pop confirmation modal
  	  confirmation_modal_display = true;
  	  confirmation_modal_type = 'lab_rx';
  	  modal_out = 'Are you sure you want to delete this lab rx form';
  	}
  }
  
  public void cancel_clearance_form() {
  	//check to see if this is a new medical clearance form,  or an existing one
  	if(new_med_clearance.id==null) {
  	  close_clearance_form();
  	} else {
  	  //display the confirmation modal
  	  confirmation_modal_display = true;
      confirmation_modal_type = 'med_clearance';
      modal_out = 'You are about to remove the medical clearance request for - ' + new_med_clearance.health_condition__c + ' to ' + new_med_clearance.doctor_name__c;  	  
  	}
  }
  
  public void delete_surgical_rx() {
  	try {
  	  new_surgical_rx.isactive__c = false;
  	  update new_surgical_rx;
  	  clear_uncomitted_changes(new_surgical_rx.id==null?'new_surgical_rx':new_surgical_rx.id);
  	  display_surgical_rx_form = false;
  	  uncomitted_changes = false;
  	  close_confirmation_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the surgical rx. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void delete_lab_rx() {
  	try {
  	  new_lab_rx.isactive__c = false;
  	  update new_lab_rx;
  	  clear_uncomitted_changes(new_lab_rx.id);
  	  display_lab_rx_form = false;
  	  uncomitted_changes = true;
  	  close_confirmation_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the lab rx. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void delete_clearance() {
  	try {
  	  new_med_clearance.isactive__c = false;
  	  update new_med_clearance;
  	  display_clearance_form = false;
  	  close_confirmation_modal();
  	  uncomitted_changes = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the medical clearance. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
/*  public void record_srx() {
  	Pagereference pr = Page.ccare_clinical_srx_preview;
    pr.getParameters().put('srxid',new_surgical_rx.id);
    pr.getParameters().put('ptid',patient.id);
    pr.getParameters().put('ctrid',current_center.id);
    String file_name = 'Surgical Rx ' + system.now().format('M/dd/yyyy') + '.html';
    Blob abody;
    if(Test.isRunningTest())
      abody = Blob.valueof('<html><body>Test SRX Snap</body></html>');
    else    
      abody = pr.getContent();
    String ctype = 'text/html';
    try { 
      Attachment att = new Attachment(Name = file_name, parentid = new_surgical_rx.id, body = abody, isprivate = false, contenttype = ctype);
      insert att;
    } catch (Exception e) {
      System.debug('Error running snapshot' + e);  	
    }
  }*/  
  
  public void save_clearance() {
  	Integer num_issues = 0;
  	//make sure condition is not blank
  	if(new_med_clearance.health_condition__c==null) {
  	  num_issues++;  	  
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for condition'));  	  
  	} else if(new_med_clearance.health_condition__c=='Other' && new_med_clearance.health_condition_other__c==null) {
      num_issues++;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for other condition'));
  	}   	
  	//check for doctor name
  	if(new_med_clearance.doctor_name__c==null) {
  	  num_issues++;  	  
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for doctor name'));  	  
  	} 
  	//check for requested via
  	if(new_med_clearance.requested_via__c==null) {
  	  num_issues++;  	  
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an option for how the clearance was requested'));  	    	 
  	} 
  	if(num_issues == 0) {  	
  	  try {
  	    if(new_med_clearance.id==null)
  	      insert new_med_clearance;
  	    else
  	      update new_med_clearance; 
  	    uncomitted_changes = false; 	  
  	    close_clearance_form();
  	  } catch (Exception e) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the medical clearance.  Please try again or contact IT for help'));
  		ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void save_lab_rx() {
  	//apply our uncomitted changes here
  	list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c = :(new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id)
  	  and createdbyid = :userinfo.getuserid() and vf_page__c = 'POT']; 
  	for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	  if(ucf.field_type__c=='Boolean')
  	    new_lab_rx.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	  else
  	    new_lab_rx.put(ucf.field_name__c,ucf.field_value__c);  	
  	}  	
  	//to-do: add in error check here - andy will get me the info on what the rules should be
  	Integer num_issues = 0;	
  	if(num_issues == 0) {  	
  	  try {
  	    if(new_lab_rx.id==null)
  	      insert new_lab_rx;
  	    else
  	      update new_lab_rx;
  	    if(ucf_list.size()>0)
  	      delete ucf_list;
  	    uncomitted_changes = false;
  	    //7/25/2017 cm - andy requested that lab rx stay open on save  	  
  	    //close_lab_rx_form();
  	  } catch (Exception e) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the lab rx.  Please try again or contact IT for help'));
  		ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void save_surgical_rx() {
  	//System.debug('Running Save SRX');
  	Integer num_issues = 0;
  	list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where 
  	  form_id__c = :(new_surgical_rx.id==null?'new_surgical_rx':new_surgical_rx.id) and createdbyid = :userinfo.getuserid() and vf_page__c = 'POT']; 
  	for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	  if(ucf.field_type__c=='Boolean')
  	    new_surgical_rx.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	  else
  	    new_surgical_rx.put(ucf.field_name__c,ucf.field_value__c);  	
  	} 
  	//to-do: add in error check here - andy will get me the info on what the rules should be
  	if(num_issues == 0) {    			
  	  try {
  	    if(new_surgical_rx.id==null)
  	      insert new_surgical_rx;
  	    else
  	      update new_surgical_rx;
  	    uncomitted_changes = false;  	    
  	    System.debug('Calling out for Surgical RX attachment');  	    
  	    myWs.record_srx(new_surgical_rx.id,patient.id);
  	    //grab the record for review
  	    new_surgical_rx = getsurgical_rx(new_surgical_rx.id); 	   
  	    //close_surgical_rx_form();
  	    srx_review_display = true;
  	  } catch (Exception e) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the surgical rx.  Please try again or contact IT for help'));
  		ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void change_lab_text() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	record_uncomitted_change((new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id),fname,new_val,System.now(),'String');
  	//new_lab_rx.put(fname,new_val);
  	uncomitted_changes = true;
  }
  
  public void record_uncomitted_change(String form_id, String field_name, String field_value, Datetime rtime, String field_type) {
  	//TO-DO : get rtime actually working based on when the ajax call initiated
  	//check to see if we have an existing request for this field
  	try {
  	  Integer change_count = [select count() from uncomitted_form_change__c where form_id__c = :form_id and field_name__c = :field_name and vf_page__c = 'POT' and createdbyid = :userinfo.getUserId()];
  	  Uncomitted_form_change__c change_record;
  	  if(change_count>0) {
  	    change_record = [select id,form_id__c,field_name__c,field_value__c,request_time__c,field_type__c,vf_page__c from uncomitted_form_change__c where form_id__c = :form_id and field_name__c = :field_name and createdbyid = :userinfo.getUserId()];
  	    change_record.field_value__c = field_value;
  	  }
  	  else
  	    change_record = new Uncomitted_form_change__c(form_id__c = form_id, field_name__c = field_name, field_value__c = field_value, request_time__c = rtime, field_type__c = field_type, vf_page__c = 'POT');
  	  upsert change_record;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error recording form changes.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);
  	}
  }
  
  public void change_lab_field() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	//Boolean current_val = (Boolean)new_lab_rx.get(fname);
  	//Boolean new_val = false;
  	//if(current_val==null)
  	  //new_val = true;
  	//else if(current_val)
  	  //new_val = false;
  	//else if(!current_val)
  	  //new_val = true;  	
  	record_uncomitted_change((new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id),fname,new_val,System.now(),'Boolean');
  	//new_lab_rx.put(fname,new_val);
  	uncomitted_changes = true;  	
  }
  
  public void change_lab_type() {
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	record_uncomitted_change((new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id),'form_type__c',new_val,System.now(),'String');
  	apply_lab_rx_uncomitted();
  	uncomitted_changes = true;
  }
  
  public void apply_lab_rx_uncomitted() {
    list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c = :(new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id)
  	  and createdbyid = :userinfo.getuserid() and vf_page__c = 'POT']; 
  	for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	  if(ucf.field_type__c=='Boolean')
  	    new_lab_rx.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	  else
  	    new_lab_rx.put(ucf.field_name__c,ucf.field_value__c);  	
  	}   
  }
  
  public void commit_lab_rx_changes() {
  	list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c = :(new_lab_rx.id==null?'new_lab_rx':new_lab_rx.id)
  	  and createdbyid = :userinfo.getuserid() and vf_page__c = 'POT']; 
  	for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	  if(ucf.field_type__c=='Boolean')
  	    new_lab_rx.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	  else
  	    new_lab_rx.put(ucf.field_name__c,ucf.field_value__c);  	
  	}   	
  	upsert new_lab_rx;
  	if(ucf_list.size()>0)
  	  delete ucf_list;
  }
  
  public void commit_surgical_rx_changes() {
  	list<Uncomitted_Form_Change__c> ucf_list = [select id,form_id__c,field_name__c,field_value__c,field_type__c from Uncomitted_Form_Change__c where form_id__c = :(new_surgical_rx.id==null?'new_surgical_rx':new_surgical_rx.id)
  	    and createdbyid = :userinfo.getuserid() and vf_page__c = 'POT']; 
  	  for(Uncomitted_Form_Change__c ucf : ucf_list) {
  	    if(ucf.field_type__c=='Boolean')
  	      new_surgical_rx.put(ucf.field_name__c,Boolean.valueof(ucf.field_value__c));
  	    else
  	      new_surgical_rx.put(ucf.field_name__c,ucf.field_value__c);  	
  	  }   		
  	  update new_surgical_rx;
  	  if(ucf_list.size()>0)
  	    delete ucf_list;
  }
  
  public void open_lab_rx_tooth_modal() {
  	try {
  	  //apply our uncomitted changes here
  	  commit_lab_rx_changes();
  	  open_variable_tooth_modal();  	  
  	  uncomitted_changes = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error attempting to update the lab rx.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);
  	}
  }
  
  public void change_surgical_rx_include() {
  	try {
  	  //apply our uncomitted changes here
  	  commit_surgical_rx_changes();
  	  open_variable_tooth_modal();  	  
  	  uncomitted_changes = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error attempting to update the surgical rx.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);
  	}
  }
  
  public void change_surgical_rx_boolean() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	//Boolean current_val = (Boolean)new_surgical_rx.get(fname);
  	//Boolean new_val = false;
  	//if(current_val==null)
  	  //new_val = true;
  	//else if(current_val)
  	  //new_val = false;
  	//else if(!current_val)
  	  //new_val = true;  	
  	//new_surgical_rx.put(fname,new_val);
  	record_uncomitted_change((new_surgical_rx.id==null?'new_surgical_rx':new_surgical_rx.id),fname,new_val,System.now(),'Boolean');
  	uncomitted_changes = true;
  }
    
  public void change_surgical_rx_text() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	record_uncomitted_change((new_surgical_rx.id==null?'new_surgical_rx':new_surgical_rx.id),fname,new_val,System.now(),'String');  	
  	//new_surgical_rx.put(fname,new_val);
  	uncomitted_changes = true;
  }  
  
  public void check_med_clearance() {
  	System.debug('Clearance : ' + new_med_clearance);
  	System.debug('Modal Out	: ' + modal_out);
  }
    
  public String gettooth_chart_procedure_name() {
  	Patient_Pot_Apt_procedure__c p = [select id,name from Patient_Pot_Apt_Procedure__c where id = :proc_id];
  	return p.name;
  }
  
  public String getcurrent_tooth_selections() {
  	Patient_Pot_Apt_procedure__c p = [select id,name,target_teeth__c from Patient_Pot_Apt_Procedure__c where id = :proc_id];
  	return p.target_teeth__c;
  }
  
  public String getcurrent_variable_tooth_selections() {  	
  	return (String)target_object.get(target_field);
  }    
  
  public void check_patient_forms() {
  	//lists for insert/update process
  	List<Patient_Procedure_Form__c> forms_remove_list = new List<Patient_Procedure_Form__c>();
  	List<Patient_procedure_Form__c> forms_insert_list = new List<Patient_Procedure_Form__c>();
  	
  	//keep a running list of pots we looked through,  to make sure one wasn't deleted
  	Set<ID> pot_id = new Set<ID>();
  	
  	//work through all patient pots
  	for(Patient_POT__c pot : [Select p.Id, p.Account__c From Patient_POT__c p where account__c = :patient.id]) {  		  		  	
  	  //build set of all procedures in this pot
  	  Set<ID> proc_ids = new Set<ID>();
  	  for(Patient_Pot_Apt_Procedure__c ppp : [Select p.Clinical_Procedure__c From Patient_POT_Apt_Procedure__c p where Patient_POT_Apt__r.patient_POT__c = :pot.id and isactive__c = true]) {
  	  	proc_ids.add(ppp.clinical_procedure__c);
  	  }
  	  
  	  //build set of all office documents tied to these procedures
  	  Set<ID> form_ids = new Set<ID>();
  	  Map<ID,Clinical_Procedure_Form__c> cpf_map = new Map<ID,Clinical_Procedure_Form__c>();
  	  for(Clinical_Procedure_Form__c cpf : [select office_form__c,office_form__r.name,office_form__r.forms_category__c from Clinical_Procedure_Form__c where clinical_procedure__c in :proc_ids]) {
  	  	form_ids.add(cpf.office_form__c);
  	  	cpf_map.put(cpf.office_form__c,cpf);
  	  }
  	  
  	  //add to forms_insert_list
  	  //--build a map of the current forms for this patient/pot
  	  //--loop through our set and find out which items are not in the map - create a record for these items
  	  Map<ID,Patient_Procedure_Form__c> patient_forms_map = new Map<ID,Patient_Procedure_Form__c> ();
  	  for(Patient_procedure_Form__c pf : [select id,office_form__c from Patient_procedure_form__c where account__c = :patient.id and patient_pot__c = :pot.id ]) {
  	  	patient_forms_map.put(pf.office_form__c,pf);
  	  }
  	  for(Id fid : form_ids) {
  	  	if(patient_forms_map.get(fid)==null) {
  	  	  Clinical_Procedure_Form__c cp = cpf_map.get(fid);
  	  	  Patient_Procedure_Form__c new_form = new Patient_Procedure_Form__c(Office_form__c = fid, account__c = patient.id, patient_pot__c = pot.id, form_status__c = 'Incomplete', form_name__c = cp.office_form__r.name, forms_category__c = cp.office_form__r.forms_category__c,isactive__c = true);
  	  	  forms_insert_list.add(new_form);
  	  	}  	  	 
  	  }
  	  
  	  //add to forms_remove_list - ONLY if they have not be uploaded....
  	  for(Patient_Procedure_Form__c pf : [select id from Patient_procedure_form__c where account__c = :patient.id and patient_pot__c = :pot.id and office_form__c not in :form_ids and form_status__c = 'Incomplete']) {
  	  	forms_remove_list.add(pf);
  	  }
  	  
  	  //add pot id to our set
  	  pot_id.add(pot.id);
  	}
  	
    //check to see if we have any docs tied to a pot that was not covered (indicates a pot was deleted for this patient)
    for(Patient_procedure_Form__c pform : [select id from Patient_procedure_Form__c where account__c = :patient.id and patient_pot__c not in :pot_id]) {
      //add all doc entries tied to this pot to our forms_remove_list
      forms_remove_list.add(pform);
    }
     
    //do DML updates
    try {
      insert forms_insert_list;
      delete forms_remove_list;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the required office documentation.  Please try again or contact IT for help'));
  	  ApexPages.addMessages(e);	
    }     
  }
  
  public List<quick_select_option> getsm_itype_options() {
  	/*List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('na','Select Type'));
  	if(new_surgical_rx.sm_implant_system__c=='Nobel Biocare') {
  	  clist.add(new Selectoption('NobelActive NP','NobelActive NP'));
  	  clist.add(new Selectoption('NobelActive RP','NobelActive RP'));
      clist.add(new Selectoption('NobelReplace','NobelReplace'));
      clist.add(new Selectoption('NobelSpeedy Groovy RP','NobelSpeedy Groovy RP'));
      clist.add(new Selectoption('NobelSpeedy Groovy WP','NobelSpeedy Groovy WP'));
      clist.add(new Selectoption('Zygoma Implant RP','Zygoma Implant RP'));
    } else if(new_surgical_rx.sm_implant_system__c=='Neodent') {
  	  clist.add(new Selectoption('Alvim CM','Alvim CM'));
  	  clist.add(new Selectoption('Alvim Smart','Alvim Smart'));
  	  clist.add(new Selectoption('Alvim Smart Acqua','Alvim Smart Acqua'));
  	  clist.add(new Selectoption('Drive CM','Drive CM'));
      clist.add(new Selectoption('Drive CM Acqua','Drive CM Acqua'));
      clist.add(new Selectoption('Drive Smart','Drive Smart'));
	  clist.add(new Selectoption('Titamax CM','Titamax CM'));
      clist.add(new Selectoption('Titamax CM EX','Titamax CM EX'));
      clist.add(new Selectoption('Titamax CM EX Acqua','Titamax CM EX Acqua'));
      clist.add(new Selectoption('Titamax Smart','Titamax Smart'));
      clist.add(new Selectoption('Titamax Smart EX','Titamax Smart EX'));
  	} else if(new_surgical_rx.sm_implant_system__c=='Straumann') {
  	  clist.add(new Selectoption('Bone Level (BL)','Bone Level (BL)'));
  	  clist.add(new Selectoption('Bone Level Tapered (BLT)','Bone Level Tapered (BLT)'));
  	  clist.add(new Selectoption('NNC Roxolid','NNC Roxolid'));
  	  clist.add(new Selectoption('Standard (S)','Standard (S)'));
      clist.add(new Selectoption('Standard Plus (SP)','Standard Plus (SP)'));
      clist.add(new Selectoption('Tapered Effect (TE)','Tapered Effect (TE)'));
  	}  	  */
  	List<quick_select_option> clist = new List<quick_select_option>();
  	clist.add(new quick_select_option('na','Select Type',new_surgical_rx.SM_Implant_System_Type__c));
  	if(new_surgical_rx.sm_implant_system__c=='Nobel Biocare') {
  	  clist.add(new quick_select_option('NobelActive NP','NobelActive NP',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('NobelActive RP','NobelActive RP',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('NobelReplace','NobelReplace',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('NobelSpeedy Groovy RP','NobelSpeedy Groovy RP',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('NobelSpeedy Groovy WP','NobelSpeedy Groovy WP',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Zygoma Implant RP','Zygoma Implant RP',new_surgical_rx.SM_Implant_System_Type__c));
    } else if(new_surgical_rx.sm_implant_system__c=='Neodent') {
  	  clist.add(new quick_select_option('Alvim CM','Alvim CM',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('Alvim Smart','Alvim Smart',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('Alvim Smart Acqua','Alvim Smart Acqua',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('Drive CM','Drive CM',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Drive CM Acqua','Drive CM Acqua',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Drive GM','Drive GM',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Drive Smart','Drive Smart',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Helix GM','Helix GM',new_surgical_rx.SM_Implant_System_Type__c));
	  clist.add(new quick_select_option('Titamax CM','Titamax CM',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Titamax CM EX','Titamax CM EX',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Titamax CM EX Acqua','Titamax CM EX Acqua',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Titamax GM','Titamax GM',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Titamax Smart','Titamax Smart',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Titamax Smart EX','Titamax Smart EX',new_surgical_rx.SM_Implant_System_Type__c));      
  	} else if(new_surgical_rx.sm_implant_system__c=='Straumann') {
  	  clist.add(new quick_select_option('Bone Level (BL)','Bone Level (BL)',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('Bone Level Tapered (BLT)','Bone Level Tapered (BLT)',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('NNC Roxolid','NNC Roxolid',new_surgical_rx.SM_Implant_System_Type__c));
  	  clist.add(new quick_select_option('Standard (S)','Standard (S)',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Standard Plus (SP)','Standard Plus (SP)',new_surgical_rx.SM_Implant_System_Type__c));
      clist.add(new quick_select_option('Tapered Effect (TE)','Tapered Effect (TE)',new_surgical_rx.SM_Implant_System_Type__c));
  	} 
	return clist;
  }  
  
  public List<quick_select_option> getman_itype_options() {
  	/*List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('','Select Type'));
  	if(new_surgical_rx.man_implant_system__c=='Nobel Biocare') {
  	  clist.add(new Selectoption('NobelActive NP','NobelActive NP'));
  	  clist.add(new Selectoption('NobelActive RP','NobelActive RP'));
      clist.add(new Selectoption('NobelReplace','NobelReplace'));
      clist.add(new Selectoption('NobelSpeedy Groovy RP','NobelSpeedy Groovy RP'));
      clist.add(new Selectoption('NobelSpeedy Groovy WP','NobelSpeedy Groovy WP'));
    } else if(new_surgical_rx.man_implant_system__c=='Neodent') {
  	  clist.add(new Selectoption('Alvim CM','Alvim CM'));
  	  clist.add(new Selectoption('Alvim Smart','Alvim Smart'));
  	  clist.add(new Selectoption('Alvim Smart Acqua','Alvim Smart Acqua'));
  	  clist.add(new Selectoption('Drive CM','Drive CM'));
      clist.add(new Selectoption('Drive CM Acqua','Drive CM Acqua'));
      clist.add(new Selectoption('Drive Smart','Drive Smart'));
	  clist.add(new Selectoption('Titamax CM','Titamax CM'));
      clist.add(new Selectoption('Titamax CM EX','Titamax CM EX'));
      clist.add(new Selectoption('Titamax CM EX Acqua','Titamax CM EX Acqua'));
      clist.add(new Selectoption('Titamax Smart','Titamax Smart'));
      clist.add(new Selectoption('Titamax Smart EX','Titamax Smart EX'));
  	} else if(new_surgical_rx.man_implant_system__c=='Straumann') {
  	  clist.add(new Selectoption('Bone Level (BL)','Bone Level (BL)'));
  	  clist.add(new Selectoption('Bone Level Tapered (BLT)','Bone Level Tapered (BLT)'));
  	  clist.add(new Selectoption('NNC Roxolid','NNC Roxolid'));
  	  clist.add(new Selectoption('Standard (S)','Standard (S)'));
      clist.add(new Selectoption('Standard Plus (SP)','Standard Plus (SP)'));
      clist.add(new Selectoption('Tapered Effect (TE)','Tapered Effect (TE)'));
  	}  	  */
  	List<quick_select_option> clist = new List<quick_select_option>();
  	clist.add(new quick_select_option('','Select Type',new_surgical_rx.man_implant_teeth__c));
  	if(new_surgical_rx.man_implant_system__c=='Nobel Biocare') {
  	  clist.add(new quick_select_option('NobelActive NP','NobelActive NP',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('NobelActive RP','NobelActive RP',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('NobelReplace','NobelReplace',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('NobelSpeedy Groovy RP','NobelSpeedy Groovy RP',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('NobelSpeedy Groovy WP','NobelSpeedy Groovy WP',new_surgical_rx.man_implant_teeth__c));
    } else if(new_surgical_rx.man_implant_system__c=='Neodent') {
  	  clist.add(new quick_select_option('Alvim CM','Alvim CM',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('Alvim Smart','Alvim Smart',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('Alvim Smart Acqua','Alvim Smart Acqua',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('Drive CM','Drive CM',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Drive CM Acqua','Drive CM Acqua',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Drive Smart','Drive Smart',new_surgical_rx.man_implant_teeth__c));
	  clist.add(new quick_select_option('Titamax CM','Titamax CM',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Titamax CM EX','Titamax CM EX',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Titamax CM EX Acqua','Titamax CM EX Acqua',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Titamax Smart','Titamax Smart',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Titamax Smart EX','Titamax Smart EX',new_surgical_rx.man_implant_teeth__c));
  	} else if(new_surgical_rx.man_implant_system__c=='Straumann') {
  	  clist.add(new quick_select_option('Bone Level (BL)','Bone Level (BL)',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('Bone Level Tapered (BLT)','Bone Level Tapered (BLT)',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('NNC Roxolid','NNC Roxolid',new_surgical_rx.man_implant_teeth__c));
  	  clist.add(new quick_select_option('Standard (S)','Standard (S)',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Standard Plus (SP)','Standard Plus (SP)',new_surgical_rx.man_implant_teeth__c));
      clist.add(new quick_select_option('Tapered Effect (TE)','Tapered Effect (TE)',new_surgical_rx.man_implant_teeth__c));
  	}  	  
	return clist;
  } 
  
  public class quick_select_option {
  	public String value {get;set;}
  	public String label {get;set;}
  	Boolean opt_selected;
  	
  	public quick_select_option(String v,String l,String comparison_value) {
  	  this.value = v;
  	  this.label = l;
  	  if(v==comparison_value)
  	    this.opt_selected = true;
  	  else
  	    this.opt_selected = false;
  	}
  	
  	public String getoption_html() {
  	  if(opt_selected)
  	    return '<option value="' + value + '" selected>' + label + '</option>';
  	  else
  	    return '<option value="' + value + '">' + label + '</option>';
  	}
  }
  
  public List<quick_select_option> getmax_itype_options() {
  	/*List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('','Select Type'));
  	if(new_surgical_rx.max_implant_system__c=='Nobel Biocare') {
  	  clist.add(new Selectoption('NobelActive NP','NobelActive NP'));
  	  clist.add(new Selectoption('NobelActive RP','NobelActive RP'));
      clist.add(new Selectoption('NobelReplace','NobelReplace'));
      clist.add(new Selectoption('NobelSpeedy Groovy RP','NobelSpeedy Groovy RP'));
      clist.add(new Selectoption('NobelSpeedy Groovy WP','NobelSpeedy Groovy WP'));
    } else if(new_surgical_rx.max_implant_system__c=='Neodent') {
  	  clist.add(new Selectoption('Alvim CM','Alvim CM'));
  	  clist.add(new Selectoption('Alvim Smart','Alvim Smart'));
  	  clist.add(new Selectoption('Alvim Smart Acqua','Alvim Smart Acqua'));
  	  clist.add(new Selectoption('Drive CM','Drive CM'));
      clist.add(new Selectoption('Drive CM Acqua','Drive CM Acqua'));
      clist.add(new Selectoption('Drive Smart','Drive Smart'));
	  clist.add(new Selectoption('Titamax CM','Titamax CM'));
      clist.add(new Selectoption('Titamax CM EX','Titamax CM EX'));
      clist.add(new Selectoption('Titamax CM EX Acqua','Titamax CM EX Acqua'));
      clist.add(new Selectoption('Titamax Smart','Titamax Smart'));
      clist.add(new Selectoption('Titamax Smart EX','Titamax Smart EX'));
  	} else if(new_surgical_rx.max_implant_system__c=='Straumann') {
  	  clist.add(new Selectoption('Bone Level (BL)','Bone Level (BL)'));
  	  clist.add(new Selectoption('Bone Level Tapered (BLT)','Bone Level Tapered (BLT)'));
  	  clist.add(new Selectoption('NNC Roxolid','NNC Roxolid'));
  	  clist.add(new Selectoption('Standard (S)','Standard (S)'));
      clist.add(new Selectoption('Standard Plus (SP)','Standard Plus (SP)'));
      clist.add(new Selectoption('Tapered Effect (TE)','Tapered Effect (TE)'));
  	}  	  
	return clist;*/
	List<quick_select_option> clist = new List<quick_select_option>();
  	clist.add(new quick_select_option('','Select Type',new_surgical_rx.Max_Implant_teeth__c));
  	if(new_surgical_rx.max_implant_system__c=='Nobel Biocare') {
  	  clist.add(new quick_select_option('NobelActive NP','NobelActive NP',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('NobelActive RP','NobelActive RP',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('NobelReplace','NobelReplace',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('NobelSpeedy Groovy RP','NobelSpeedy Groovy RP',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('NobelSpeedy Groovy WP','NobelSpeedy Groovy WP',new_surgical_rx.Max_Implant_teeth__c));
    } else if(new_surgical_rx.max_implant_system__c=='Neodent') {
  	  clist.add(new quick_select_option('Alvim CM','Alvim CM',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('Alvim Smart','Alvim Smart',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('Alvim Smart Acqua','Alvim Smart Acqua',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('Drive CM','Drive CM',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Drive CM Acqua','Drive CM Acqua',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Drive Smart','Drive Smart',new_surgical_rx.Max_Implant_teeth__c));
	  clist.add(new quick_select_option('Titamax CM','Titamax CM',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Titamax CM EX','Titamax CM EX',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Titamax CM EX Acqua','Titamax CM EX Acqua',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Titamax Smart','Titamax Smart',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Titamax Smart EX','Titamax Smart EX',new_surgical_rx.Max_Implant_teeth__c));
  	} else if(new_surgical_rx.max_implant_system__c=='Straumann') {
  	  clist.add(new quick_select_option('Bone Level (BL)','Bone Level (BL)',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('Bone Level Tapered (BLT)','Bone Level Tapered (BLT)',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('NNC Roxolid','NNC Roxolid',new_surgical_rx.Max_Implant_teeth__c));
  	  clist.add(new quick_select_option('Standard (S)','Standard (S)',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Standard Plus (SP)','Standard Plus (SP)',new_surgical_rx.Max_Implant_teeth__c));
      clist.add(new quick_select_option('Tapered Effect (TE)','Tapered Effect (TE)',new_surgical_rx.Max_Implant_teeth__c));
  	}  	  
	return clist;
  }
  
  public Integer getdosespot_notification_count() {
  	Integer error_count = 0;  	
  	try {  	
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
  
  public String getdosespot_clinical_page_url() {
  	PageReference pr = Page.ccare_clinical_dosespot;
  	pr.getParameters().put('ctrid',current_center.id);
  	if(patient!=null)
  	  pr.getParameters().put('ptid',patient.id);   	        	            	      
  	return pr.getUrl();
  }
  
  public String getdosespot_iframe_url() {
  	String return_url = '';
  	try {
  	  Dosespot dosespot = new DoseSpot(patient.id,current_center);             
      return_url = dosespot.DoseSpot_patient_URL();             
      return return_url; 
    } catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return return_url;
  	}
  	return return_url;
  }
  
  public class account_statement_line implements Comparable {
  	public Date line_date {get;set;}
  	public String line_code {get; set;}
  	public String line_description {get;set;}
  	public String line_tooth {get;set;}
  	public Decimal line_charges {get;set;}
  	public Decimal line_credits {get;set;}
  	public String line_cost {get;set;}
  	
  	public account_statement_line(Date ldate,String lcode,String ldesc, String lcost) {
      this.line_date = ldate;
      this.line_code = lcode;
      this.line_description = ldesc;
      this.line_cost = (lcost==null?'':lcost);
  	}  	
  	
  	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      account_statement_line compareToline = (account_statement_line)compareTo;
        
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;      
      //compare the last referral date between the two
      if(line_date < comparetoline.line_date)
        returnvalue = -1;
      else if(line_date > comparetoline.line_date)
        returnvalue = 1;        
      return returnValue;       
    }
  }
  
  public String getcenter_address_line() {
  	String address_line = '';  	
  	try {
  	  if(new_surgical_rx==null) {
  	    address_line = current_center.street_1__c;
  	    if(current_center.street_2__c!=null)
  	      address_line += ', ' + current_center.street_2__c;
  	    address_line += '<br />' + current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c; 
  	  }
  	  else {
  	    address_line = new_surgical_rx.center_information__r.street_1__c;
  	    if(new_surgical_rx.center_information__r.street_2__c!=null)
  	      address_line += ', ' + new_surgical_rx.center_information__r.street_2__c;
  	    address_line += '<br />' + new_surgical_rx.center_information__r.city__c + ', ' + new_surgical_rx.center_information__r.state__c + ' ' + new_surgical_rx.center_information__r.zip_code__c;
  	  }
  	} catch (Exception e) {
  	  //new record - no relationship fields available yet - use center info
  	  address_line = current_center.street_1__c;
  	  if(current_center.street_2__c!=null)
  	    address_line += ', ' + current_center.street_2__c;
  	  address_line += '<br />' + current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c;
  	}
  	return address_line;
  }
  
  public String getlab_rx_patient_name() {
  	//return first three characters of last name + first initial
  	String pname = (display_phi?patient.name:(patient.lastname.left(3) + patient.firstname.left(1)));
  	return pname;
  }
  
  public String getproposed_treatment_plan_header(Integer pnum, String pot_id) {
  	//return the header html for the account statement report
  	//get the url for the logo
  	StaticResource sr = [SELECT id,name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = 'CCLogo_Transparent' limit 1];
  	String image_url = '/resource/' + sr.SystemModStamp.getTime() + '/' + (sr.namespaceprefix != null && sr.namespaceprefix != '' ? sr.namespaceprefix + '__' : '') + 'CCLogo_Transparent';      
  	String header_html = '<div class="clearfix" id="page"><!-- column -->' +
  '<div class="clearfix colelem" id="pu498"><!-- group -->' + 
    '<div class="clip_frame grpelem" id="u498"><!-- image -->' + 
      '<img class="block" id="u498_img" src="' + image_url + '" alt="" width="152" height="47"> </div>' + 
    '<div class="clearfix grpelem" id="pu503-4"><!-- column -->' + 
      '<div class="clearfix colelem" id="u503-4"><!-- content -->' + 
        '<p>Date:&nbsp;' +  System.now().format('MM/dd/YYYY') + '</p>' + 
      '</div>' +
      '<div class="clearfix colelem" id="u505-4"><!-- content -->' + 
        '<p>Page:&nbsp;' + pnum + '&nbsp;of xxxpageTotalreplacexxx</p>' + 
      '</div>' +
    '</div>' +
  '</div>' +
  '<div class="clearfix colelem" id="u487-10"><!-- content -->' + 
    '<p id="u487-2">' + current_center.legal_name__c + '</p>' +
    '<p id="u487-6">' + getcenter_address_line() + '</p>' +
    '<p id="u487-8">Phone:&nbsp;' + current_center.Local_Front_Desk__c + '</p>' +
  '</div>' +
  '<div class="clearfix colelem" id="u490"><!-- group -->' +
    '<div class="clearfix grpelem" id="u492-4"><!-- content -->' +
      '<p id="u492-2">PROPOSED TREATMENT PLAN</p>' +
    '</div>' +
  '</div>' +
  '<div class="clearfix colelem" id="u509-12"><!-- content -->' +
    '<p id="u509-2">ACCOUNT:</p>' +
    '<p id="u509-10">' +
      patient.firstname + ' ' + patient.lastname + '<br>' + patient.billingstreet + '<br>' + patient.billingcity + ', ' + patient.billingstate + ' ' + patient.billingpostalcode + '</p>' +
  '</div>' +
  '<div class="colelem" id="u484"><!-- simple frame --></div>' +
  '<div class="clearfix colelem" id="pu501-4"><!-- group -->' +
    '<div class="clearfix grpelem" id="u501-4"><!-- content -->' +
      '<p id="u501-2">APPOINTMENT</p>' +
    '</div>' +
    '<div class="clearfix grpelem" id="u489-4"><!-- content -->' +
      '<p id="u489-2">CODE</p>' +
    '</div>' +
    '<div class="clearfix grpelem" id="u506-4"><!-- content -->' +
      '<p id="u506-2">DESCRIPTION</p>' +
    '</div>' +
    '<div class="clearfix grpelem" id="u513-4"><!-- content -->' +
      '<p id="u513-2">TOOTH</p>' +
    '</div>' +
  '</div>' +
  '<div class="colelem" id="u488"><!-- simple frame --></div>';
  	return header_html;
  }
  
  
  /*public String getaccount_statement_header_old(Integer pnum, String pot_id) {
  	//grab the next apt for this patient so we can use it below
  	String next_date = '';
  	String next_time = '';
  	try {
  	  Clinical_Apt_Calendar__c ca = [select id,apt_date__c,start_hour__c,start_minute__c,start_hour_int__c,patient_pot_apt__c 
  	    from Clinical_Apt_Calendar__c 
  	    where account__c = :patient.id 
  	      and patient_pot_apt__r.patient_pot__c = :pot_id
  	      and apt_date__c > today];
  	  next_date = Datetime.newinstance(ca.apt_date__c,Time.newInstance(0, 0, 0, 0)).format('MM/dd/YYYY');
  	  String minutes;
  	  if(ca.start_minute__c.length()==1)
  	    minutes = '0' + ca.start_minute__c;
  	  else
  	    minutes = ca.start_minute__c;
  	  if(ca.start_hour_int__c>12)
  	    next_time = String.valueof(ca.start_hour_int__c - 12) + ':' + minutes + ' PM';
  	  else if(ca.start_hour_int__c==12)
  	    next_time = ca.start_hour__c + ':' + minutes + ' PM';
  	  else
  	    next_time = ca.start_hour__c + ':' + minutes + ' AM';  	   
  	} catch (Exception e) {
  		
  	}  	  	
  	//return the header html for the account statement report
  	//get the url for the logo
  	StaticResource sr = [SELECT id,name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = 'CCLogo_Transparent' limit 1];
  	String image_url = '/resource/' + sr.SystemModStamp.getTime() + '/' + (sr.namespaceprefix != null && sr.namespaceprefix != '' ? sr.namespaceprefix + '__' : '') + 'CCLogo_Transparent';      
  	String header_html = '<div class="clearfix" id="page"><!-- column -->' + 
   '<div class="clearfix colelem" id="pu246"><!-- group -->' + 
    '<div class="clip_frame grpelem" id="u246"><!-- image -->' + 
    
     '<img class="block" id="u246_img" src="' + image_url + '" alt="" width="152" height="47">' +
     //'<img class="block" id="u246_img" src="images/clearchoice_logo_cmyk_dic_tag.jpg" alt="" width="122" height="47">' + 
    '</div>' +
    '<div class="clearfix grpelem" id="pu220-4"><!-- column -->' + 
     '<div class="clearfix colelem" id="u220-4"><!-- content -->' + 
      '<p>Date:' +  System.now().format('MM/dd/YYYY') + '</p>' +  
     '</div>' +
     '<div class="clearfix colelem" id="u227-4"><!-- content -->' + 
      '<p>Page:' + pnum + '</p>' + 
     '</div>' + 
    '</div>' + 
   '</div>' + 
   '<div class="clearfix colelem" id="u265-10"><!-- content -->' + 
    '<p id="u265-2">' + current_center.legal_name__c + '</p> ' + 
    '<p id="u265-6">' + getcenter_address_line() + '</p>' + 
    '<p id="u265-8">Phone: ' + current_center.Local_Front_Desk__c + '</p>' + 
   '</div>' + 
   '<div class="clearfix colelem" id="u259"><!-- group -->' + 
    '<div class="clearfix grpelem" id="u262-4"><!-- content -->' + 
     '<p id="u262-2">ACCOUNT STATEMENT</p>' + 
    '</div>' + 
   '</div>' + 
   '<div class="clearfix colelem" id="pu256-12"><!-- group -->' + 
    '<div class="clearfix grpelem" id="u256-12"><!-- content -->' + 
     '<p id="u256-2">ACCOUNT:</p>' + //&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  XXXXXX (need to see if we actually want to use an account #)
     '<p id="u256-10">' + patient.firstname + ' ' + patient.lastname + '<br>' + patient.billingstreet + '<br>' + patient.billingcity + ', ' + patient.billingstate + ' ' + patient.billingpostalcode + '</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u268-8"><!-- content -->' + 
     '<p id="u268-2">NEXT APPOINTMENT</p>' + 
     '<p id="u268-6">DATE: ' + next_date + '<br>TIME: ' + next_time + '</p>' + 
    '</div>' + 
   '</div>' + 
   '<div class="colelem" id="u271"><!-- simple frame --></div>' + 
   '<div class="clearfix colelem" id="pu277-4"><!-- group -->' + 
    '<div class="clearfix grpelem" id="u277-4"><!-- content -->' + 
     '<p id="u277-2">DATE</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u280-4"><!-- content -->' + 
     '<p id="u280-2">CODE</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u283-4"><!-- content -->' + 
     '<p id="u283-2">DESCRIPTION</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u286-4"><!-- content -->' + 
     '<p id="u286-2">TOOTH</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u289-4"><!-- content -->' + 
     '<p id="u289-2">CHARGES</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u292-4"><!-- content -->' + 
     '<p id="u292-2">CREDITS</p>' + 
    '</div>' + 
   '</div>';
  	return header_html;
  }*/
  
  public String getaccount_statement_header(Integer pnum, String pot_id,Clinical_Apt_Calendar__c ca) {  	
  	//grab the next apt for this patient so we can use it below  	  	
  	String next_date = '';
  	String next_time = '';
  	
  	if(ca!=null) {
	  	try {  	  
	  	  next_date = Datetime.newinstance(ca.apt_date__c,Time.newInstance(0, 0, 0, 0)).format('MM/dd/YYYY');
	  	  String minutes;
	  	  if(ca.start_minute__c.length()==1)
	  	    minutes = '0' + ca.start_minute__c;
	  	  else
	  	    minutes = ca.start_minute__c;
	  	  if(ca.start_hour_int__c>12)
	  	    next_time = String.valueof(ca.start_hour_int__c - 12) + ':' + minutes + ' PM';
	  	  else if(ca.start_hour_int__c==12)
	  	    next_time = ca.start_hour__c + ':' + minutes + ' PM';
	  	  else
	  	    next_time = ca.start_hour__c + ':' + minutes + ' AM';  	   
	  	} catch (Exception e) {
	  		
	  	}  	  	
  	}
  	//return the header html for the account statement report
  	//get the url for the logo
  	//converted to static resource
  	//StaticResource sr = [SELECT id,name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = 'CCLogo_Transparent' limit 1];
  	String image_url = '/resource/' + sr.SystemModStamp.getTime() + '/' + (sr.namespaceprefix != null && sr.namespaceprefix != '' ? sr.namespaceprefix + '__' : '') + 'CCLogo_Transparent';      
  	String header_html = '<div>' + 
      '<div class="header_section">' + 
        '<div class="header_left_col" >' +     
          '<img class="block" src="' + image_url + '" alt="" width="152" height="47">' +
          '<div class="header_left_center_col">' +
            '<p class="header_section_padded">' + current_center.legal_name__c + '</p> ' + 
            '<p class="header_section_padded">' + getcenter_address_line() + '</p>' + 
            '<p class="header_section_padded">Phone: ' + current_center.Local_Front_Desk__c + '</p>' +        
          '</div>' + 
        '</div>' +
        '<div class="header_right_col">' +         
          '<p class="header_section_padded">Date: &nbsp;&nbsp;' +  System.now().format('MM/dd/YYYY') + '</p>' +
          '<p class="header_section_padded">Page: &nbsp;&nbsp;' + pnum + '</p>' +  
        '</div>' +       
      '</div>' +      
      '<div class="report_name_label">' +     
        '<p>ACCOUNT STATEMENT</p>' + 
      '</div>' +    
      '<div class="customer_info_section">' + 
        '<div class="account_col">' + 
          '<p class="header_section_padded">ACCOUNT:</p>' + 
          '<p>' + patient.firstname + ' ' + patient.lastname + '<br>' + patient.billingstreet + '<br>' + patient.billingcity + ', ' + patient.billingstate + ' ' + patient.billingpostalcode + '</p>' + 
        '</div>' +
        '<div class="next_apt_col">' + 
          '<p class="header_section_padded">NEXT APPOINTMENT</p>' + 
          '<p>DATE: ' + next_date + '</p>' + 
          '<p>TIME: ' + next_time + '</p>' + 
        '</div>' + 
      '</div>' +
             
      '<div class="detail_section">' + 
        '<div class="detail_header">' + 
          '<div class="date_col">DATE</div>' + 
          '<div class="code_col"><p>CODE</p></div>' + 
          '<div class="description_col"><p>DESCRIPTION</p></div>' +
          '<div class="tooth_col"><p>TOOTH</p></div>';
     if(display_cost_info)    
       header_html += '<div class="cost_col"><p>COST</p></div>';           
     header_html += '<div class="charges_col"><p>CHARGES</p></div>' +
          '<div class="credits_col"><p>CREDITS</p></div>' +           
        '</div>';
  	return header_html;
  }
  
  public String getproposed_treatment_plan_footer(Decimal current_balance) {
  	String footer_html = '<div class="clearfix colelem" id="u535-4"><!-- content -->' +
    '<p id="u535-2">TOTAL PLAN OF TREATMENT:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $' + current_balance + '</p>' +
  '</div>' +
  '<div class="clearfix colelem" id="u562"><!-- column -->' +
    '<div class="clearfix colelem" id="u538-4"><!-- content -->' +
      '<p id="u538-2">I authorize the doctor and/or such qualified assignees to perform the services listed above.</p>' +
    '</div>' +
    '<div class="clearfix colelem" id="ppu544-4"><!-- group -->' +
      '<div class="clearfix grpelem" id="pu544-4"><!-- group -->' +
        '<div class="clearfix grpelem" id="u544-4"><!-- content -->' +
          '<p id="u544-2">Date</p>' +
        '</div>' +
        '<div class="grpelem" id="u559"><!-- simple frame --></div>' +
      '</div>' +
      '<div class="clearfix grpelem" id="u541-4"><!-- content -->' +
        '<p id="u541-2">Patient Signature</p>' +
      '</div>' +
      '<div class="grpelem" id="u514"><!-- simple frame --></div>' +
    '</div>' +
  '</div>' +
  '<div class="clearfix colelem" id="ppu550-4"><!-- group -->' +
    '<div class="clearfix grpelem" id="pu550-4"><!-- group -->' +
      '<div class="clearfix grpelem" id="u550-4"><!-- content -->' +
        '<p id="u550-2">Date</p>' +
      '</div>' +
      '<div class="grpelem" id="u556"><!-- simple frame --></div>' +
    '</div>' +
    '<div class="clearfix grpelem" id="u547-4"><!-- content -->' +
      '<p id="u547-2">Doctor Signature</p>' +
    '</div>' +
    '<div class="grpelem" id="u553"><!-- simple frame --></div>' +
  '</div>' +
'</div>';
    return footer_html;
  }
  
  public String getaccount_statement_footer(Decimal current_balance) {
  	//return the footer html for the account statement report
  	String footer_html = 
  	  '<div class="footer_section">' +  	       
  	    '<div class="date_col footer_border">&nbsp;</div>' +
  	    '<div class="code_col footer_border">&nbsp;</div>' +
        '<div class="description_col footer_border">&nbsp;</div>' +
        '<div class="tooth_col footer_border">&nbsp;</div>';
    if(display_cost_info)
      footer_html += '<div class="cost_col footer_border">&nbsp;</div>';
    footer_html += '<div class="charges_col footer_border">&nbsp;</div>' +
        '<div class="credits_col" >' +
          'BALANCE<br />' + (zero_balance_override?'0.00':String.valueof(current_balance)) +    
        '</div>' +      
      '</div>' +     
    '</div>';
  	return footer_html;
  }
  
  public String getproposed_treatment_plan_output() {
  	Patient_POT__c pot = [Select p.Treatment_Description__c, p.Opportunity__c, p.opportunity__r.treatment_amount__c, p.createddate, p.Name, p.Id, p.Account__c From Patient_POT__c p 
  	  where id = :apexpages.currentpage().getparameters().get('potid')];
  	Integer page_num = 1;
  	String report_html = getproposed_treatment_plan_header(page_num, pot.id);
  	Decimal current_balance = pot.opportunity__r.treatment_amount__c;
  	
  	//calculate max/man targets in case we need to replace all max / all mand targets below
  	Set<Integer> all_max = new Set<Integer> {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
  	Set<Integer> all_mand = new Set<Integer> {17,18,29,20,21,22,23,24,25,26,27,28,29,30,31,32};
  	//grab the most recent perio chart and look for missing/pontic teeth.
  	try {
  	  Perio_Chart__c pc = [Select p.Id, p.Account__c, 
  	  (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Tooth_Type__c, Measurement__c, Endo__c, Decay__c, Perio_Chart__c, Tooth_Integer__c From Perio_Chart_Teeth__r 
  	    where tooth_type__c in ('Missing','Pontic','Implant')) 
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
  	//build our replacement strings
  	String max_replace = '';
  	String man_replace = '';
  	for(Integer i : all_max) {
      max_replace += i + ',';
  	}
  	for(Integer i : all_mand) {
  	  man_replace += i + ',';
  	}
  	max_replace = max_replace.left(max_replace.length()-1);
  	man_replace = man_replace.left(man_replace.length()-1);
  	
  	//build a map of surgical notes instances by patient pot apt - we'll use these to substitue info in the next section
    Map<String,String> snf_map = new Map<String,String>();
    for(Surgical_Notes_Form__c snf : [Select s.Id, s.Extractions__c, s.Clinical_Note_Instance__c, s.Account__c, clinical_note_instance__r.patient_pot_apt__c 
      From Surgical_Notes_Form__c s 
      where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :pot.id
      order by createddate desc limit 1]) {
      System.debug('SNotes : ' + snf);
      if(snf.extractions__c!=null) {
	    Clinical_Apt_Calendar__c ca = [Select c.apt_date__c,c.Patient_POT_Apt__c, c.Apt_Status__c ,c.patient_pot_apt__r.name
	  	  From Clinical_Apt_Calendar__c c 
	  	  where 
	  	    patient_pot_apt__c = :snf.clinical_note_instance__r.patient_pot_apt__c];	    
	    String string_out = '<div class="clearfix colelem" id="pu501-4"><!-- group -->' +
		    '<div class="clearfix grpelem" id="u501-4"><!-- content -->' +
		      '<p id="u501-2">' + ca.patient_pot_apt__r.name + '</p>' +
		    '</div>' +
		    '<div class="clearfix grpelem" id="u489-4"><!-- content -->' +
		      '<p id="u489-2">D7210</p>' +
		    '</div>' +
		    '<div class="clearfix grpelem" id="u506-4"><!-- content -->' +
		      '<p id="u506-2">Surgical removal of erupted tooth requiring removal of bone and/or sectioning of tooth, and including elevation of mucoperiosteal flap if indicated</p>' +
		    '</div>' +
		    '<div class="clearfix grpelem" id="u513-4"><!-- content -->' +
		      '<p id="u513-2">' + snf.extractions__c + '</p>' +
		    '</div>' +
		  '</div>';
	    snf_map.put(snf.clinical_note_instance__r.patient_pot_apt__c,string_out);  
      }
    } 
  	
  	Integer current_line_count = 1;
  	String last_ppa_id = null;
  	for(Patient_POT_Apt__c ppa : [Select p.Patient_POT__c, p.Name, p.Id, p.Clinical_Appointment__c, p.Appointment_Description__c 
  	  From Patient_POT_Apt__c p 
  	  where patient_pot__c = :pot.id 
  	    and isactive__c = true
  	  order by sort_order__c]) {
  	  if(ppa.id!=last_ppa_id) {
  	  	//if not null,  check for a map entry and add it to the report
  	  	if(last_ppa_id!=null) {
  	  	  if(snf_map.get(last_ppa_id)!=null)
  	  	    report_html += snf_map.get(last_ppa_id);
  	  	    snf_map.remove(last_ppa_id);
  	  	}
  	    last_ppa_id = ppa.id;
  	  }
  	  for(Patient_POT_Apt_Procedure__c ppp  : [Select p.Target_Teeth__c,p.Sort_Order__c, p.Procedure_Description__c, p.Patient_POT_Apt__c, p.Name, p.Id, p.ADA_Code__c 
  	    From Patient_POT_Apt_Procedure__c p
  	    where patient_pot_apt__c = :ppa.id and ada_code__c != null and isactive__c = true
  	    order by sort_order__c]) {
  	    //check for an extraction that we need to replace
  	    if(ppp.name=='Surg Extraction Erupted Tooth' && snf_map.get(ppa.id)!=null) {
  	      report_html += snf_map.get(last_ppa_id);
  	      snf_map.remove(last_ppa_id);
  	    }	
  	    	
  	  	report_html += '<div class="clearfix colelem" id="pu501-4"><!-- group -->' +
		    '<div class="clearfix grpelem" id="u501-4"><!-- content -->' +
		      '<p id="u501-2">' + ppa.name + '</p>' +
		    '</div>' +
		    '<div class="clearfix grpelem" id="u489-4"><!-- content -->' +
		      '<p id="u489-2">' + ppp.ada_code__c + '</p>' +
		    '</div>' +
		    '<div class="clearfix grpelem" id="u506-4"><!-- content -->' +
		      '<p id="u506-2">' + ppp.procedure_description__c + '</p>' +
		    '</div>' +
		    '<div class="clearfix grpelem" id="u513-4"><!-- content -->' +
		      '<p id="u513-2">' + (ppp.target_teeth__c==null?'':ppp.target_teeth__c) + '</p>' +
		    '</div>' +
		  '</div>';
        current_line_count++;
  	    if(current_line_count==22) {
  	  	  page_num++;
  	  	  //possibly add page break to the below line
  	  	  //report_html += getproposed_treatment_plan_footer(current_balance) + '<div class="pbreak"></div>' + getproposed_treatment_plan_header(page_num, pot.id);
  	  	  report_html += '<div class="pbreak"></div>' + getproposed_treatment_plan_header(page_num, pot.id);
  	  	  current_line_count = 1;
  	    }
  	  }  	
  	}
  	  	
  	report_html += getproposed_treatment_plan_footer(current_balance);
  	report_html = report_html.replace('xxxpageTotalreplacexxx',String.valueof(page_num));  	
  	return report_html;
  }
  
  public String getaccount_statement_output() {
  	try {
  	System.debug('Report Dates : ' + report_sdate + ' - ' + report_edate);
  	account_statement_line[] report_detail = new account_statement_line[] {};
  	Patient_POT__c pot = [Select p.Treatment_Description__c, p.Opportunity__c, p.opportunity__r.amount, p.opportunity__r.treatment_amount__c, p.createddate, p.Name, p.Id, p.Account__c From Patient_POT__c p 
  	  where id = :apexpages.currentpage().getparameters().get('potid')];
  	Integer page_num = 1;
  	Clinical_Apt_Calendar__c header_ca;
  	try {
      header_ca = [select id,apt_date__c,start_hour__c,start_minute__c,start_hour_int__c,patient_pot_apt__c 
  	    from Clinical_Apt_Calendar__c 
  	    where account__c = :patient.id 
  	      and patient_pot_apt__r.patient_pot__c = :pot.id
  	      and apt_date__c > today 
  	      order by apt_date__c limit 1];
  	} catch (Exception e) {}
  	
  	String report_html = getaccount_statement_header(page_num, pot.id,header_ca);  
  	  
  	//Decimal current_balance = (pot.opportunity__r.treatment_amount__c==null?0:pot.opportunity__r.treatment_amount__c);
  	Decimal current_balance = (pot.opportunity__r.amount==null?0:pot.opportunity__r.amount);
  	Map<String,String> pcode_map = new Map<String,String> ();
  	pcode_map.put('Master Card','MC');
  	pcode_map.put('Check','CK');
  	pcode_map.put('Credit Card','CC');
  	pcode_map.put('CareCredit','CARECR');
  	pcode_map.put('Springstone','STONE');
    pcode_map.put('ClearChoice Base Plan','CBP');
    pcode_map.put('ACH','ACH');
    pcode_map.put('Wire','WIRE');
    pcode_map.put('ClearChoice Marketing / Dr. Gratus','GRAT');
    pcode_map.put('Patient Preferred Financing','PPF');
    pcode_map.put('American Express','AMEX');
    pcode_map.put('Discover','DISC');
    pcode_map.put('Visa','VISA');
    pcode_map.put('Alphaeon','ALPH');    
  	
  	//add line for POT treatment 
  	account_statement_line nline = new account_statement_line(pot.createddate.date(),'POT',pot.name,null);
  	nline.line_charges = pot.opportunity__r.treatment_amount__c;
  	report_detail.add(nline);
  	
  	//work through payment detail
  	for(CCPayment__c pay : [select Opportunity__c,payment_amount__c,Payment_Status_Formula__c,Payment_Type__c,payment_date__c 
  	  from CCPayment__c 
      where
        Payment_Status_Formula__c in ('Collected','Refunded')
        and opportunity__c = :pot.opportunity__c
        and payment_date__c >= :report_sdate and payment_date__c <= :report_edate]) {
      String payment_code = pay.payment_type__c;  	
      if(pcode_map.get(pay.payment_type__c)!=null)
        payment_code = pcode_map.get(pay.payment_type__c);
      nline = new account_statement_line(pay.payment_date__c,payment_code,pay.payment_type__c + ' Payment','');      
      if(pay.payment_status_formula__c=='Collected') {
        nline.line_credits = pay.payment_amount__c * -1;
        current_balance -= pay.payment_amount__c;
      }
      if(pay.payment_status_formula__c=='Refunded') {
        nline.line_credits = pay.payment_amount__c;
        current_balance += pay.payment_amount__c;
      }
      report_detail.add(nline);
    }
    for(Private_Practice_Payment__c ppay : [select Opportunity__c,payment_amount__c,Payment_Status_Formula__c,Payment_Type__c,payment_date__c 
  	  from Private_Practice_Payment__c
      where
        Payment_Status_Formula__c in ('Collected','Refunded')
        and opportunity__c = :pot.opportunity__c
        and payment_date__c >= :report_sdate and payment_date__c <= :report_edate]) {
      String payment_code = ppay.payment_type__c;
      if(pcode_map.get(ppay.payment_type__c)!=null)
        payment_code = pcode_map.get(ppay.payment_type__c);      
      nline = new account_statement_line(ppay.payment_date__c,payment_code,ppay.payment_type__c + ' Payment','');      
      if(ppay.payment_status_formula__c=='Collected') {
        nline.line_credits = ppay.payment_amount__c * -1;
        //current_balance -= ppay.payment_amount__c;
      }
      if(ppay.payment_status_formula__c=='Refunded') {
        nline.line_credits = ppay.payment_amount__c;
        //current_balance += ppay.payment_amount__c;
      }
      report_detail.add(nline);
    }
  	
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
  	//build our replacement strings
  	String max_replace = '';
  	String man_replace = '';
  	for(Integer i : all_max) {
      max_replace += i + ',';
  	}
  	for(Integer i : all_mand) {
  	  man_replace += i + ',';
  	}
  	//System.debug('Max replace : ' + max_replace);
  	max_replace = max_replace.left(max_replace.length()-1);
  	//System.debug('Man replace : ' + man_replace);
  	man_replace = man_replace.left(man_replace.length()-1); 
  	
  	Decimal default_extraction_cost = null;
  	try {
  	  Clinical_Procedure__c cp = [select id,cost__c from clinical_procedure__c where name = 'Surg Extraction Erupted Tooth' and center_information__c = :current_center.id limit 1];
  	  default_extraction_cost = cp.cost__c;
  	} catch (Exception e) {
  	  default_extraction_cost = null;
  	}
  	
  	//System.debug('Default Extraction : ' + default_extraction_cost);
  	
    //build a map of surgical notes instances by patient pot apt - we'll use these to substitue info in the next section
    Map<String,List<account_statement_line>> snf_map = new Map<String,List<account_statement_line>>();
    for(Surgical_Notes_Form__c snf : [Select s.Id, s.Extractions__c, s.Clinical_Note_Instance__c, s.Account__c, clinical_note_instance__r.patient_pot_apt__c 
      From Surgical_Notes_Form__c s 
      where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :pot.id
      and createddate >= :report_sdate and createddate <= :report_edate
      order by createddate desc limit 1]) {
      System.debug('SNotes : ' + snf);
      if(snf.extractions__c!=null) {
	    Clinical_Apt_Calendar__c ca = [Select c.apt_date__c,c.Patient_POT_Apt__c, c.Apt_Status__c 
	  	  From Clinical_Apt_Calendar__c c 
	  	  where 
	  	    patient_pot_apt__c = :snf.clinical_note_instance__r.patient_pot_apt__c];
	  	//System.debug('Tooth Target : ' + snf.extractions__c);
	  	String tooth_target = snf.extractions__c;	
	  	Pattern all_max_pattern = Pattern.compile('All[^\\w]Max');
        Pattern all_mand_pattern = Pattern.compile('All[^\\w]Mand');	  	  
	    //tooth_target.replace('All Max',max_replace);
	    tooth_target = all_max_pattern.matcher(tooth_target).replaceAll(max_replace);
        //tooth_target.replace('All Mand',man_replace);        
        tooth_target = all_mand_pattern.matcher(tooth_target).replaceAll(man_replace);
        for(String current_target : tooth_target.split(',')) {
          nline = new account_statement_line(ca.apt_date__c,'D7210','Surgical Extraction',String.valueof(default_extraction_cost));
          nline.line_tooth = current_target;
          if(snf_map.get(snf.clinical_note_instance__r.patient_pot_apt__c)==null)
            snf_map.put(snf.clinical_note_instance__r.patient_pot_apt__c,new List<Account_statement_line>());            
          snf_map.get(snf.clinical_note_instance__r.patient_pot_apt__c).add(nline);  
        }
	    //report_detail.add(nline);	    
      }
    } 	
    
    //System.debug('SNF MAP : ' + snf_map);
  	
  	//work through attended apts for procedure info
  	List<Clinical_Apt_Calendar__c> attended_list = [Select c.apt_date__c,c.Patient_POT_Apt__c, c.Apt_Status__c 
  	  From Clinical_Apt_Calendar__c c 
  	  where 
  	    patient_pot_apt__r.patient_pot__c = :pot.id and
        apt_status__c in ('Completed','Patient Arrived','Patient Ready','Appointment Started') 
        and apt_date__c >= :report_sdate and apt_date__c <= :report_edate
      order by apt_date__c];
    Set<ID> pot_apt_set = new Set<ID>();
    Map<Id,List<Patient_POT_Apt_Procedure__c>> procedures_map = new Map<Id,List<Patient_POT_Apt_Procedure__c>>(); 
  	for(Clinical_Apt_Calendar__c ca :attended_list ) {
      pot_apt_set.add(ca.patient_pot_apt__c);
    }	
    //build out our map for below
    for(Patient_POT_Apt_Procedure__c ppa : [Select p.Target_Teeth__c, p.Sort_Order__c, p.Procedure_Description__c, p.Patient_POT_Apt__c, p.Insurance_Fee__c, p.Cost__c, p.Clinical_Procedure__c, 
      p.ADA_Code__c, p.name, p.clinical_procedure__r.procedure_description__c 
	    From Patient_POT_Apt_Procedure__c p 
	    where
	      ada_code__c != null
	      and patient_pot_apt__c in :pot_apt_set
	      and isactive__c = true
	    order by patient_pot_apt__c,sort_order__c]) {
	  if(procedures_map.get(ppa.patient_pot_apt__c)==null)
	    procedures_map.put(ppa.patient_pot_apt__c,new List<Patient_POT_Apt_Procedure__c>());
	  procedures_map.get(ppa.patient_pot_apt__c).add(ppa);    	
	}

    for(Clinical_Apt_Calendar__c ca :attended_list ) {      		      	
	  /*for(Patient_POT_Apt_Procedure__c ppa : [Select p.Target_Teeth__c, p.Sort_Order__c, p.Procedure_Description__c, p.Patient_POT_Apt__c, p.Insurance_Fee__c, p.Cost__c, p.Clinical_Procedure__c, p.ADA_Code__c, p.name 
	    From Patient_POT_Apt_Procedure__c p 
	    where
	      ada_code__c != null
	      and patient_pot_apt__c = :ca.patient_pot_apt__c
	      and isactive__c = true
	    order by sort_order__c]) {*/
	  if(procedures_map.get(ca.patient_pot_apt__c)!=null)
	  for(Patient_POT_Apt_Procedure__c ppa :procedures_map.get(ca.patient_pot_apt__c)) {
	    System.debug('PPA.Name : ' + ppa.name + ' Map : ' + snf_map.get(ca.patient_pot_apt__c));
	    if(ppa.name=='Surg Extraction Erupted Tooth' && snf_map.get(ca.patient_pot_apt__c)!=null) {
          //System.debug('Cost should be : ' + String.valueof(ppa.cost__c));         	    	
	      for(Account_statement_line aline : snf_map.get(ca.patient_pot_apt__c)) {	        
	        //System.debug('Swapping Cost : ' + ppa.cost__c);
	        aline.line_cost = String.valueof(ppa.cost__c);
	        report_detail.add(aline); 
	      }
	      snf_map.remove(ca.patient_pot_apt__c);
	    }
	    else {
	      if(ppa.target_teeth__c==null) {
	      	nline = new account_statement_line(ca.apt_date__c,ppa.ada_code__c,(ppa.procedure_description__c==null?ppa.clinical_procedure__r.procedure_description__c:ppa.procedure_description__c),String.valueof(ppa.cost__c));
	      	report_detail.add(nline);
	      }
	      else {
	        String tooth_target = ppa.target_teeth__c;	  	
	        Pattern all_max_pattern = Pattern.compile('All[^\\w]Max');
            Pattern all_mand_pattern = Pattern.compile('All[^\\w]Mand');	  	  
	        //tooth_target.replace('All Max',max_replace);
	        tooth_target = all_max_pattern.matcher(tooth_target).replaceAll(max_replace);
            //tooth_target.replace('All Mand',man_replace);        
            tooth_target = all_mand_pattern.matcher(tooth_target).replaceAll(man_replace);
            for(String current_target : tooth_target.split(',')) {
              nline = new account_statement_line(ca.apt_date__c,ppa.ada_code__c,(ppa.procedure_description__c==null?ppa.clinical_procedure__r.procedure_description__c:ppa.procedure_description__c),String.valueof(ppa.cost__c));
              nline.line_tooth = current_target;
              report_detail.add(nline);	
            }              
	      }	       	      
	    }
	    //report_detail.add(nline);    	
	  }
    }
    
    //any surgical extraction notes not used as a replacement should appear on the account summary now
    for(List<account_statement_line> aslines : snf_map.values()) {
      for(Account_Statement_Line asl : aslines) {
        report_detail.add(asl);
      }
    }
        
  	  	
  	report_detail.sort();
  	Integer current_line_count = 1;
  	Set<String> cost_display_centers = new Set<String> {'Dallas Arlington'};
  	for(account_statement_line asl : report_detail) {
  	  //add html for a detail line here
  	  report_html += '<div class="detail_row"><!-- group -->' + 
	    '<div class="date_col">' + 
	      '<p>' + Datetime.newinstance(asl.line_date,Time.newInstance(0, 0, 0, 0)).format('MM/dd/YYYY') + '</p>' +
	    '</div>' +
	    '<div class="code_col">' +
	      '<p>' + (asl.line_code==null?'':asl.line_code) + '</p>' + 
	    '</div>' + 
	    '<div class="description_col">' + 
	      '<p>' + (asl.line_description==null?'':asl.line_description) + '</p>' +
	    '</div>' +	    
	    '<div class="tooth_col">' + 
	      '<p>' + (asl.line_tooth==null?'':asl.line_tooth) + '</p>' + 
	    '</div>';
	  if(display_cost_info)	   
	    report_html += '<div class="cost_col">' + 
	      '<p>' + (asl.line_cost==null?'':asl.line_cost) + '</p>' + 
	    '</div>';	  
	  report_html += '<div class="charges_col">' + 
	      '<p>' + (asl.line_charges==null?'':string.valueof(asl.line_charges)) + '</p>' + 
	    '</div>' +
	    '<div class="credits_col">' +
	      '<p >' + (asl.line_credits==null?'':string.valueof(asl.line_credits)) + '</p>' +
	    '</div>' +
	  '</div>';
  	  /*report_html += '<div class="clearfix colelem" id="pu277-4"><!-- group -->' + 
	    '<div class="clearfix grpelem" id="u277-4"><!-- content -->' + 
	     '<p id="u277-2">' + Datetime.newinstance(asl.line_date,Time.newInstance(0, 0, 0, 0)).format('MM/dd/YYYY') + '</p>' +
	    '</div>' +
	    '<div class="clearfix grpelem" id="u280-4"><!-- content -->' +
	     '<p id="u280-2">' + (asl.line_code==null?'':asl.line_code) + '</p>' + 
	    '</div>' + 
	    '<div class="clearfix grpelem" id="u283-4"><!-- content -->' + 
	     '<p id="u283-2">' + (asl.line_description==null?'':asl.line_description) + '</p>' +
	    '</div>' +
	    '<div class="clearfix grpelem" id="u286-4"><!-- content -->' + 
	     '<p id="u286-2">' + (asl.line_tooth==null?'':asl.line_tooth) + '</p>' + 
	    '</div>' +
	    '<div class="clearfix grpelem" id="u289-4"><!-- content -->' + 
	     '<p id="u289-2">' + (asl.line_charges==null?'':string.valueof(asl.line_charges)) + '</p>' + 
	    '</div>' +
	    '<div class="clearfix grpelem" id="u292-4"><!-- content -->' +
	     '<p id="u292-2">' + (asl.line_credits==null?'':string.valueof(asl.line_credits)) + '</p>' +
	    '</div>' +
	   '</div>';*/
  	  current_line_count++;
  	  if(current_line_count==22) {
  	  	page_num++;
  	  	//possibly add page break to the below line
  	  	report_html += getaccount_statement_footer(current_balance) + '<div class="pbreak">&nbsp;</div>' + getaccount_statement_header(page_num, pot.id, header_ca);
  	  	current_line_count = 1;
  	  }
  	}
  	//report_html += '</div>';
  	report_html += getaccount_statement_footer(current_balance);
  	return report_html;
  	} catch (Exception e) { ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying generate report detail.  Please contact IT for help'));
        ApexPages.addMessages(e);return 'Issue Generating Report'; }
  	
  }
  
  /*public String getaccount_statement_output_old() {
  	account_statement_line[] report_detail = new account_statement_line[] {};
  	Patient_POT__c pot = [Select p.Treatment_Description__c, p.Opportunity__c, p.opportunity__r.treatment_amount__c, p.createddate, p.Name, p.Id, p.Account__c From Patient_POT__c p 
  	  where id = :apexpages.currentpage().getparameters().get('potid')];
  	Integer page_num = 1;
  	String report_html = getaccount_statement_header(page_num, pot.id);  
  	  
  	Decimal current_balance = (pot.opportunity__r.treatment_amount__c==null?0:pot.opportunity__r.treatment_amount__c);
  	Map<String,String> pcode_map = new Map<String,String> ();
  	pcode_map.put('Master Card','MC');
  	pcode_map.put('Check','CK');
  	pcode_map.put('Credit Card','CC');
  	pcode_map.put('CareCredit','CARECR');
  	pcode_map.put('Springstone','STONE');
    pcode_map.put('ClearChoice Base Plan','CBP');
    pcode_map.put('ACH','ACH');
    pcode_map.put('Wire','WIRE');
    pcode_map.put('ClearChoice Marketing / Dr. Gratus','GRAT');
    pcode_map.put('Patient Preferred Financing','PPF');
    pcode_map.put('American Express','AMEX');
    pcode_map.put('Discover','DISC');
    pcode_map.put('Visa','VISA');
    pcode_map.put('Alphaeon','ALPH');    
  	
  	//add line for POT treatment 
  	account_statement_line nline = new account_statement_line(pot.createddate.date(),'POT',pot.name,null);
  	nline.line_charges = pot.opportunity__r.treatment_amount__c;
  	report_detail.add(nline);
  	
  	//work through payment detail
  	for(CCPayment__c pay : [select Opportunity__c,payment_amount__c,Payment_Status_Formula__c,Payment_Type__c,payment_date__c 
  	  from CCPayment__c 
      where
        Payment_Status_Formula__c in ('Collected','Refunded')
        and opportunity__c = :pot.opportunity__c]) {
      String payment_code = pay.payment_type__c;  	
      if(pcode_map.get(pay.payment_type__c)!=null)
        payment_code = pcode_map.get(pay.payment_type__c);
      nline = new account_statement_line(pay.payment_date__c,payment_code,pay.payment_type__c + ' Payment','');      
      if(pay.payment_status_formula__c=='Collected') {
        nline.line_credits = pay.payment_amount__c * -1;
        current_balance -= pay.payment_amount__c;
      }
      if(pay.payment_status_formula__c=='Refunded') {
        nline.line_credits = pay.payment_amount__c;
        current_balance += pay.payment_amount__c;
      }
      report_detail.add(nline);
    }
    for(Private_Practice_Payment__c ppay : [select Opportunity__c,payment_amount__c,Payment_Status_Formula__c,Payment_Type__c,payment_date__c 
  	  from Private_Practice_Payment__c
      where
        Payment_Status_Formula__c in ('Collected','Refunded')
        and opportunity__c = :pot.opportunity__c]) {
      String payment_code = ppay.payment_type__c;
      if(pcode_map.get(ppay.payment_type__c)!=null)
        payment_code = pcode_map.get(ppay.payment_type__c);      
      nline = new account_statement_line(ppay.payment_date__c,payment_code,ppay.payment_type__c + ' Payment','');      
      if(ppay.payment_status_formula__c=='Collected') {
        nline.line_credits = ppay.payment_amount__c * -1;
        current_balance -= ppay.payment_amount__c;
      }
      if(ppay.payment_status_formula__c=='Refunded') {
        nline.line_credits = ppay.payment_amount__c;
        current_balance += ppay.payment_amount__c;
      }
      report_detail.add(nline);
    }
  	
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
  	//build our replacement strings
  	String max_replace = '';
  	String man_replace = '';
  	for(Integer i : all_max) {
      max_replace += i + ',';
  	}
  	for(Integer i : all_mand) {
  	  man_replace += i + ',';
  	}
  	max_replace = max_replace.left(max_replace.length()-1);
  	man_replace = man_replace.left(man_replace.length()-1); 
  	
    //build a map of surgical notes instances by patient pot apt - we'll use these to substitue info in the next section
    Map<String,account_statement_line> snf_map = new Map<String,account_statement_line>();
    for(Surgical_Notes_Form__c snf : [Select s.Id, s.Extractions__c, s.Clinical_Note_Instance__c, s.Account__c, clinical_note_instance__r.patient_pot_apt__c 
      From Surgical_Notes_Form__c s 
      where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :pot.id
      order by createddate desc limit 1]) {
      System.debug('SNotes : ' + snf);
      if(snf.extractions__c!=null) {
	    Clinical_Apt_Calendar__c ca = [Select c.apt_date__c,c.Patient_POT_Apt__c, c.Apt_Status__c 
	  	  From Clinical_Apt_Calendar__c c 
	  	  where 
	  	    patient_pot_apt__c = :snf.clinical_note_instance__r.patient_pot_apt__c];
	    nline = new account_statement_line(ca.apt_date__c,'D7210','Surgical Extraction','');
	    nline.line_tooth = snf.extractions__c;
	    //report_detail.add(nline);
	    snf_map.put(snf.clinical_note_instance__r.patient_pot_apt__c,nline);  
      }
    } 	
  	
  	//work through attended apts for procedure info
  	for(Clinical_Apt_Calendar__c ca : [Select c.apt_date__c,c.Patient_POT_Apt__c, c.Apt_Status__c 
  	  From Clinical_Apt_Calendar__c c 
  	  where 
  	    patient_pot_apt__r.patient_pot__c = :pot.id and
        apt_status__c = 'Completed' 
      order by apt_date__c]) {
	  for(Patient_POT_Apt_Procedure__c ppa : [Select p.Target_Teeth__c, p.Sort_Order__c, p.Procedure_Description__c, p.Patient_POT_Apt__c, p.Insurance_Fee__c, p.Cost__c, p.Clinical_Procedure__c, p.ADA_Code__c, p.name 
	    From Patient_POT_Apt_Procedure__c p 
	    where
	      ada_code__c != null
	      and patient_pot_apt__c = :ca.patient_pot_apt__c
	      and isactive__c = true
	    order by sort_order__c]) {
	    if(ppa.name=='Surg Extraction Erupted Tooth' && snf_map.get(ca.patient_pot_apt__c)!=null) {
	      nline = snf_map.get(ca.patient_pot_apt__c);
	      snf_map.remove(ca.patient_pot_apt__c);
	    }
	    else {
	      nline = new account_statement_line(ca.apt_date__c,ppa.ada_code__c,ppa.procedure_description__c,String.valueof(ppa.cost__c));
	      nline.line_tooth = ppa.target_teeth__c;
          //nline.line_tooth.replace('All max',max_replace);
          //nline.line_tooth.replace('All mand',man_replace);
	    }
	    report_detail.add(nline);    	
	  }
    }
    
    //any surgical extraction notes not used as a replacement should apper on the account summary now
    for(account_statement_line asl : snf_map.values()) {
      report_detail.add(asl);
    }
        
  	  	
  	report_detail.sort();
  	Integer current_line_count = 1;
  	for(account_statement_line asl : report_detail) {
  	  //add html for a detail line here
  	  report_html += '<div class="clearfix colelem" id="pu277-4"><!-- group -->' + 
    '<div class="clearfix grpelem" id="u277-4"><!-- content -->' + 
     '<p id="u277-2">' + Datetime.newinstance(asl.line_date,Time.newInstance(0, 0, 0, 0)).format('MM/dd/YYYY') + '</p>' +
    '</div>' +
    '<div class="clearfix grpelem" id="u280-4"><!-- content -->' +
     '<p id="u280-2">' + (asl.line_code==null?'':asl.line_code) + '</p>' + 
    '</div>' + 
    '<div class="clearfix grpelem" id="u283-4"><!-- content -->' + 
     '<p id="u283-2">' + (asl.line_description==null?'':asl.line_description) + '</p>' +
    '</div>' +
    '<div class="clearfix grpelem" id="u286-4"><!-- content -->' + 
     '<p id="u286-2">' + (asl.line_tooth==null?'':asl.line_tooth) + '</p>' + 
    '</div>' +
    '<div class="clearfix grpelem" id="u289-4"><!-- content -->' + 
     '<p id="u289-2">' + (asl.line_charges==null?'':string.valueof(asl.line_charges)) + '</p>' + 
    '</div>' +
    '<div class="clearfix grpelem" id="u292-4"><!-- content -->' +
     '<p id="u292-2">' + (asl.line_credits==null?'':string.valueof(asl.line_credits)) + '</p>' +
    '</div>' +
   '</div>';
  	  current_line_count++;
  	  if(current_line_count==22) {
  	  	page_num++;
  	  	//possibly add page break to the below line
  	  	report_html += getaccount_statement_footer(current_balance) + '<div class="pbreak"></div>' + getaccount_statement_header(page_num, pot.id);
  	  	current_line_count = 1;
  	  }
  	}
  	
  	report_html += getaccount_statement_footer(current_balance);
  	return report_html;
  }*/
  
  public String getpatient_allergy_info() {
  	String allergy_line = '';
  	String prefix_char = '';
  	for(Allergy__c a : [select name from Allergy__c where patient__c = :patient.id]) {
  	  allergy_line += prefix_char + a.name;
  	  prefix_char = ',';
  	}
  	if(allergy_line=='')
  	  allergy_line = 'NKDA';
  	return allergy_line;
  }
  
  public void display_mc_file_upload() {
  	display_mc_attachment_form = true;
  	new_mc_attachment = new Attachment(parentid = apexpages.currentpage().getparameters().get('mcid'));
  }
  
  public void upload_mc_file() {
  	try {
      new_mc_attachment.name = photo_name;
      new_mc_attachment.description = 'Uploaded on  - ' + System.now() + ' by ' + userinfo.getname();
      new_mc_attachment.contentType=photo_content_type;
      new_mc_attachment.Body=EncodingUtil.base64Decode(photo_data);
      insert new_mc_attachment;
      new_med_clearance = [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c,  m.IsActive__c, m.Health_Condition__c, m.health_condition_other__c, m.Doctor_Specialty__c, 
  	    m.Doctor_Phone__c, m.Doctor_Name__c, m.Doctor_Fax__c, m.Date_Clearance_Requested__c, m.Account__c,(Select Id, Name, Description From Attachments)  From Medical_Clearance__c m where id = :new_mc_attachment.parentid];
      new_mc_attachment = new Attachment(parentid = new_mc_attachment.parentid);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to upload the document.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public void save_mc_attachment_form() {
  	Integer num_issues = 0;
  	Attachment att;  	
  	for(Attachment a : new_med_clearance.attachments) {        	      	      
      if(a.id==current_edit_id)
        att = a;
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
  		update att;
  		new_med_clearance = [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c,  m.IsActive__c, m.Health_Condition__c, m.health_condition_other__c, m.Doctor_Specialty__c, 
  	    m.Doctor_Phone__c, m.Doctor_Name__c, m.Doctor_Fax__c, m.Date_Clearance_Requested__c, m.Account__c,(Select Id, Name, Description From Attachments)  From Medical_Clearance__c m where id = :att.parentid];
  	    hide_attachment_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save attachment info.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
    }
  } 
  
  public void reset_mc_attachment_form() {
  	try {
  	  new_med_clearance = [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c,  m.IsActive__c, m.Health_Condition__c, m.health_condition_other__c, m.Doctor_Specialty__c, 
  	    m.Doctor_Phone__c, m.Doctor_Name__c, m.Doctor_Fax__c, m.Date_Clearance_Requested__c, m.Account__c,(Select Id, Name, Description From Attachments)  From Medical_Clearance__c m where id = :new_med_clearance.id]; 
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the attachment record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }   
  
  public void confirm_delete_mc_file() {
  	Attachment a = [select id,name from Attachment where id = :confirmation_id];
    confirmation_modal_display = true;
    confirmation_modal_type = 'mc_attachment';
    modal_out = 'Are you sure you want to remove the file - ' + a.name;
  }
  
  public void delete_mc_file_record() {
  	try {
  	  Attachment att = [select id,parentid from Attachment where id = :confirmation_id];  	
  	  //delete the record
  	  delete att;  	    	  	  
  	  new_med_clearance = [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c,  m.IsActive__c, m.Health_Condition__c, m.health_condition_other__c, m.Doctor_Specialty__c, 
  	    m.Doctor_Phone__c, m.Doctor_Name__c, m.Doctor_Fax__c, m.Date_Clearance_Requested__c, m.Account__c,(Select Id, Name, Description From Attachments)  From Medical_Clearance__c m where id = :new_med_clearance.id];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the file.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}  	
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
  public void confirm_delete_sx_file() {
  	commit_surgical_rx_changes();
  	Attachment a = [select id,name from Attachment where id = :confirmation_id];
    confirmation_modal_display = true;
    confirmation_modal_type = 'sx_attachment';
    modal_out = 'Are you sure you want to remove the file - ' + a.name;
  }
  
  public void reset_sx_attachment_form() {
  	try {
      new_surgical_rx = getsurgical_rx(new_surgical_rx.id); 
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the attachment record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_sx_file_upload() {
  	display_sx_attachment_form = true;
  	new_sx_attachment = new Attachment(parentid = apexpages.currentpage().getparameters().get('sxid'));
  }
  
  public void save_sx_attachment_form() {
  	Integer num_issues = 0;
  	Attachment att;  	
  	for(Attachment a : new_surgical_rx.attachments) {        	      	      
      if(a.id==current_edit_id)
        att = a;
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
  		update att;
  		new_surgical_rx = getsurgical_rx(att.parentid);
  	    hide_attachment_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save attachment info.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
    }
  } 
  
  public void upload_sx_file() {
  	try {
      new_sx_attachment.name = photo_name;
      new_sx_attachment.description = 'Uploaded on  - ' + System.now() + ' by ' + userinfo.getname();
      new_sx_attachment.contentType=photo_content_type;
      new_sx_attachment.Body=EncodingUtil.base64Decode(photo_data);
      insert new_sx_attachment;
      new_surgical_rx = getsurgical_rx(new_sx_attachment.parentid);
      new_sx_attachment = new Attachment(parentid = new_sx_attachment.parentid);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to upload the document.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public void delete_sx_file_record() {
  	try {
  	  Attachment att = [select id,parentid from Attachment where id = :confirmation_id];  	
  	  //delete the record
  	  delete att;  	    
  	  new_surgical_rx = getsurgical_rx(new_surgical_rx.id);	  	    	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the file.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}  	
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
    
  public void display_rx_file_upload() {
  	display_attachment_form = true;
  	new_rx_attachment = new Attachment(parentid = apexpages.currentpage().getparameters().get('lrxid'));
  }
  
  public void upload_rx_file() {
  	try {
      new_rx_attachment.name = photo_name;
      new_rx_attachment.description = 'Uploaded on  - ' + System.now() + ' by ' + userinfo.getname();
      new_rx_attachment.contentType=photo_content_type;
      new_rx_attachment.Body=EncodingUtil.base64Decode(photo_data);
      insert new_rx_attachment;
      new_lab_rx = getlab_rx(new_rx_attachment.parentid);
      new_rx_attachment = new Attachment(parentid = new_rx_attachment.parentid);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to upload the document.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public void edit_file_attachment() {
  	current_edit_id = apexpages.currentpage().getparameters().get('fileid');
  }
  
  public void hide_attachment_form() {
  	current_edit_id = null;
  }
  
  public void save_attachment_form() {
  	Integer num_issues = 0;
  	Attachment att;  	
  	for(Attachment a : new_lab_rx.attachments) {        	      	      
      if(a.id==current_edit_id)
        att = a;
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
  		update att;
  		new_lab_rx = getlab_rx(att.parentid);
  	    hide_attachment_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save attachment info.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
    }
  } 
  
  public void reset_attachment_form() {
  	try {
  	  new_lab_rx = getlab_rx(new_lab_rx.id); 
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the attachment record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }   
  
  public void confirm_delete_file() {
  	Attachment a = [select id,name from Attachment where id = :confirmation_id];
    confirmation_modal_display = true;
    confirmation_modal_type = 'lrx_attachment';
    modal_out = 'Are you sure you want to remove the file - ' + a.name;
  }
  
  public void delete_file_record() {
  	try {
  	  Attachment att = [select id,parentid from Attachment where id = :confirmation_id];  	
  	  //delete the record
  	  delete att;  	    	  	  
  	  
  	  //refresh the medication array
  	  new_lab_rx = getlab_rx(new_lab_rx.id);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the file.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}  	
  	confirmation_id = null;
  	modal_out = '';
  	confirmation_modal_display = false;
  }
  
  public class drug_info {
  	public Medication__c rx {get; set;}
  	public String doctor_name {get; set;}
  	
  	public drug_info(Medication__c m,String doc) {
  	  this.rx = m;
  	  this.doctor_name = doc;  	  
  	}
  	
  	public String getspan_style() {
  	  if(rx.prescription_status__c=='Removed')
  	    return 'color:red;font-weight:bold;';
  	  else
  	    return '';
  	}
  	
  }
  
  public void change_drug_filter() {  	  	
  	drug_filter = apexpages.currentpage().getparameters().get('dfilter');
  }
  
  public String getdrug_option_list_html() {
    String return_val =  '<option value="All" ' + (drug_filter=='All'?'selected':'') + ' >All</option> ';
    return_val += '<option value="Completed" ' + (drug_filter=='Completed'?'selected':'') + ' >Completed</option> ';
    return_val += '<option value="Failed" ' + (drug_filter=='Failed'?'selected':'') + ' >Failed</option> ';
    return return_val;
  }
  
  public List<Selectoption> getdrug_filter_options() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	clist.add(new Selectoption('Completed','Completed'));
  	clist.add(new Selectoption('Failed','Failed'));
	return clist;
  }  
  
  public List<drug_info> getprescription_meds() {
  	//build a map of doctors by id
  	Map<String,User> doc_map = new Map<String,User>();
  	for(User u : [Select u.id,u.name,u.DoseSpot_User_ID__c From User u where u.dosespot_user_id__c != null and dosespot_user_id__c != '0']) {
  	  doc_map.put(u.dosespot_user_id__c,u);
  	}
  	List<drug_info> rx_list = new List<drug_info>();
  	String med_query = 'select id, name, days_supply__c, prescription_status__c, quantity__c, refills__c, strength__c, notes__c, date_written__c, prescriber_user_id__c, doctor__c' + 
  	  ' from medication__c where source__c = \'Prescription\' and patient__c = \'' + patient.id + '\' ';
  	if(drug_filter=='Completed')
  	  med_query += ' and prescription_status__c in (\'Sending\',\'eRxSent\',\'Entered\',\'Printed\',\'Edited\') ';
  	else if(drug_filter=='Failed')
  	  med_query += ' and prescription_status__c in (\'Error\',\'EpcsError\',\'Deleted\',\'Removed\') '; 	    	
  	med_query += ' order by date_written__c desc ';
  	//System.debug('Drug Filter : ' + drug_filter);
  	System.debug('Med Query : ' + med_query);
  	for(Medication__c m : database.query(med_query)) {
  	  String dname = '';
  	  if((m.Prescriber_User_ID__c==null?'0':String.valueof(m.Prescriber_User_ID__c))!='0') {
  	  	if(doc_map.get(String.valueof(m.prescriber_user_id__c))!=null)
  	  	  dname = doc_map.get(String.valueof(m.prescriber_user_id__c)).name; 
  	  } else if(m.doctor__c!=null)
  	    dname = m.doctor__c;
  	  rx_list.add(new drug_info(m,dname));
  	}
  	return rx_list;
  }
  
  public String getpatient_age() {
  	if(patient.Date_of_Birth__c==null)
  	  return 'N/A';
  	else {
  	  Decimal years = patient.date_of_birth__c.daysbetween(System.today())/365.2425;
  	  return string.valueof(years.intvalue());
  	}
  }
  
  public void toggle_zero_balance_override() {
  	zero_balance_override = (zero_balance_override?false:true);
  }
  
  public void toggle_display_cost_override() {
  	display_cost_info = (display_cost_info?false:true);
  }
    
  public void clear_uncomitted_changes(String target_id) {
  	try {
  	  List<Uncomitted_Form_Change__c> ucf_list = [select id from Uncomitted_Form_Change__c where vf_page__c = 'POT' and form_id__c = :target_id and createdbyid = :userinfo.getuserid()];
  	  if(ucf_list.size()>0)
  	    delete ucf_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove form state data.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void toggle_phi_display() {
  	display_phi = (display_phi?true:false); 	
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
  
  public String getwindent_patient_id() {
  	Opportunity o = [select id, unique_windent_id__c,windent_patient_id__c from Opportunity where accountid = :patient.id and windent_patient_id__c !=null limit 1];
  	return o.windent_patient_id__c;
  }
  
  public boolean getdisplay_windent_id() {
  	Integer id_count = [select count() from opportunity where accountid = :patient.id and windent_patient_id__c != null];
  	if(id_count==0)
  	  return false;
  	else 
  	  return true;
  } 
  
}