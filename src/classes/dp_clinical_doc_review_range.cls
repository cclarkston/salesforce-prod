public with sharing class dp_clinical_doc_review_range {
  public Center_Information__c current_center {get; set;}
  
  //static Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD') and id = :Userinfo.getProfileId()];
  //static Boolean display_corp_admin = (admin_count>0?true:false);
  static public Boolean display_corp_admin {get;set;}
  
  public Account patient {get;set;}
  public Boolean display_patient_search_modal {get; set;}
  public String search_name {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public List<Account> consult_search_results {get; set;}
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  
  static String profile_name = [select name from profile where id = :userinfo.getprofileid()].name;
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
    
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}    
    
  public class bendException extends Exception {}	 
  
  //public List<clinical_apt> patient_apts {get;set;}
  public Boolean display_medical_warnings {get; set;} 
      
  //public Map<ID,clinical_apt> pot_to_apt_map;
  //public Map<ID,apt_form> instance_to_form_map; 
  
  static Set<String> doctor_profiles = new set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  Set<ID> market_centers;  
  
  public String search_first {get;set;}
  public String search_unique {get; set;}
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  
  public Date report_sdate {get; set;}
  public Date report_edate {get; set;}
  
  public Boolean display_calendar_view_start {get; set;}
  public Boolean display_calendar_view_end {get; set;}
  public dp_clinical_cmonth cmonth_start {get;set;}
  public dp_clinical_cmonth cmonth_end {get;set;}
  public String modal_calendar_view_start {get; set;}
  public String modal_calendar_view_end {get; set;}
  
  //see if it's a corporate admin
  static {
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  }
  
  public dp_clinical_doc_review_range() {
  	display_medical_warnings = true;
  	//User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];       	
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {            
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
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
    display_more_search_records = false;
    report_sdate = System.today();
    report_edate = System.today();
    display_calendar_view_start = false;
    display_calendar_view_end = false;
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
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
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
  
  public void getpatient_record(String patient_id,String center_id) {
    patient = [select id,name,date_of_birth__c,gender__c,recent_height_feet__c,recent_height_inches__c from Account where id = :patient_id and center__c in :market_centers];
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
      pr = Page.ccare_clinical_doctor_range_review;
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
  	  //check user_center_assignments?
  	  for(User_Center_Assignment__c uca : [select id,dosespot_user_id__c from user_center_assignment__c 
  	    where center_information__c = :current_center.id and user__r.Profile.name in ('Clinical Doctor','SF - Clinical Doctor')
  	    and dosespot_user_id__c != null ]) {
  	    all_clinician_ids.add(Integer.valueof(uca.dosespot_user_id__c));  	
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
  
  public void calendar_select_today() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  report_sdate = system.today();
  	  display_calendar_view_start = false;
  	  cmonth_start = new dp_clinical_cmonth(report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  report_edate = system.today();
  	  display_calendar_view_end = false;
  	  cmonth_end = new dp_clinical_cmonth(report_edate);
  	}
  }
  
  public void prev_calendar_day() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  report_sdate = report_sdate.adddays(-1);
  	  cmonth_start = new dp_clinical_cmonth(report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  report_edate = report_edate.adddays(-1);
  	  cmonth_end = new dp_clinical_cmonth(report_edate);
  	}
  }  
    
  public void next_calendar_day() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  report_sdate = report_sdate.adddays(1);
  	  cmonth_start = new dp_clinical_cmonth(report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  report_edate = report_edate.adddays(1);
  	  cmonth_end = new dp_clinical_cmonth(report_edate);
  	}
  }
  
  public void display_calendar_navigation() {  	
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  display_calendar_view_start = true;
  	  modal_calendar_view_start = 'calendar';
  	  cmonth_start = new dp_clinical_cmonth(report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  display_calendar_view_end = true;
  	  modal_calendar_view_end = 'calendar';
  	  cmonth_end = new dp_clinical_cmonth(report_edate);
  	}
  }
  
  public void next_calendar_month() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') 
  	  cmonth_start = new dp_clinical_cmonth(cmonth_start.idate.addmonths(1));
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') 
  	  cmonth_end = new dp_clinical_cmonth(cmonth_end.idate.addmonths(1));
  }
  
  public void prev_calendar_month() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') 
  	  cmonth_start = new dp_clinical_cmonth(cmonth_start.idate.addmonths(-1));
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') 
  	  cmonth_end = new dp_clinical_cmonth(cmonth_end.idate.addmonths(-1));
  }
  
  public void close_calendar_navigation() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start')
  	  display_calendar_view_start = false;
  	if(apexpages.currentpage().getparameters().get('dtype')=='end')
  	  display_calendar_view_end = false;
  }
  
  public void select_calendar_day() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  report_sdate = Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('cyear')),Integer.valueof(apexpages.currentpage().getparameters().get('cmonth')),Integer.valueof(apexpages.currentpage().getparameters().get('cday')));
  	  cmonth_start = new dp_clinical_cmonth(report_sdate);
  	  display_calendar_view_start = false;
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  report_edate = Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('cyear')),Integer.valueof(apexpages.currentpage().getparameters().get('cmonth')),Integer.valueof(apexpages.currentpage().getparameters().get('cday')));
  	  cmonth_end = new dp_clinical_cmonth(report_edate);
  	  display_calendar_view_end = false;
  	}  	
  }
  
  public void display_calendar_month_navigation() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start')
  	  modal_calendar_view_start = 'month';
  	if(apexpages.currentpage().getparameters().get('dtype')=='end')
  	  modal_calendar_view_end = 'month';
  }
  
  public void display_calendar_year_navigation() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start')
  	  modal_calendar_view_start = 'year';
  	if(apexpages.currentpage().getparameters().get('dtype')=='end')
  	  modal_calendar_view_end = 'year';
  } 
  
  public void select_calendar_month() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  cmonth_start = new dp_clinical_cmonth(Date.newinstance(cmonth_start.idate.year(),Integer.valueof(apexpages.currentpage().getparameters().get('mnum')),cmonth_start.idate.day()));
  	  modal_calendar_view_start = 'calendar';
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  cmonth_end = new dp_clinical_cmonth(Date.newinstance(cmonth_end.idate.year(),Integer.valueof(apexpages.currentpage().getparameters().get('mnum')),cmonth_end.idate.day()));
  	  modal_calendar_view_end = 'calendar';
  	}
  }
  
  public void select_calendar_year() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  cmonth_start = new dp_clinical_cmonth(Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('myear')),cmonth_start.idate.month(),cmonth_start.idate.day()));
  	  modal_calendar_view_start = 'calendar';
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  cmonth_end = new dp_clinical_cmonth(Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('myear')),cmonth_end.idate.month(),cmonth_end.idate.day()));
  	  modal_calendar_view_end = 'calendar';
  	}
  }
  
  public List<List<String>> getmonth_list() {
  	List<String> month_names = new List<String>();
  	List<List<String>> month_rows = new List<List<String>>();
  	for(Integer i=1;i<=12;i++) {
  	  Datetime month_start = Datetime.newInstance(System.today().year(), i, 1,0,0,0);
  	  month_names.add(month_start.format('MMM'));
      if(math.mod(i,4) == 0) {
  		month_rows.add(month_names);
  		month_names = new List<String>();
      }
  	}
  	return month_rows;
  }

  public List<List<Integer>> getyear_list() {
  	List<Integer> year_values = new List<Integer>();
  	List<List<Integer>> year_rows = new List<List<Integer>>();
    Date today_date = System.today();
    Integer end_limit = today_date.year()+1;
  	for(Integer i=2010;i<=end_limit;i++) {
  	  year_values.add(i);
  	  if(year_values.size()==4) {
  		year_rows.add(year_values);
  		year_values = new List<Integer>();
  	  }
  	}
  	if(year_values.size()>0)
  	  year_rows.add(year_values);
  	return year_rows;
  }
  
  public list<dp_clinical_notes_new.clinical_apt> getpatient_apts() {
  	//build a set of surgical notes forms so we can pull implants
  	Set<ID> sform_ids = new Set<ID>();
  	//build a map of clinical_apt_calendar_id to clinical apt so we can add implants afterwards
  	//Map<ID,clinical_apt> patient_apt_map = new Map<ID,Clinical_Apt>();
  	
  	Map<ID,dp_clinical_notes_new.clinical_apt> pot_to_apt_map = new Map<ID,dp_clinical_notes_new.clinical_apt> ();
  	Map<ID,dp_clinical_notes_new.apt_form> instance_to_form_map = new Map<ID,dp_clinical_notes_new.apt_form> ();
  	List<dp_clinical_notes_new.Clinical_apt> patient_apts = new List<dp_clinical_notes_new.Clinical_apt>();
  	
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
  	
  	//pull alist of apts that happened during the date range
  	Set<ID> pot_apt_set = new Set<ID>();
  	Set<ID> cal_apt_set = new Set<ID>();
  	for(Clinical_Apt_Calendar__c ca : [Select c.id,c.Patient_POT_Apt__c
  	  From Clinical_Apt_Calendar__c c where clinical_room__r.center_information__c = :current_center.id
  	  and c.apt_date__c >= :report_sdate and c.apt_date__c <= :report_edate
  	  and c.patient_pot_apt__c != null  	  
  	  order by apt_date__c,stime__c]) {
      pot_apt_set.add(ca.patient_pot_apt__c);
      cal_apt_set.add(ca.id);  	  	
  	}
  	
  	//reworking all of this 5/24/2016 - page is now organized by patient pot apt with a row showing up for every apt.
  	for(Patient_POT_apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Doctor_Notes__c, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, patient_pot__r.name 
  	  From Patient_POT_Apt__c p 
  	  where isactive__c = true and id in :pot_apt_set  
  	  order by patient_pot__c, sort_order__c]) {
  	  dp_clinical_notes_new.clinical_apt c = new dp_clinical_notes_new.clinical_apt(pa);
  	  pot_to_apt_map.put(pa.id,c);  
  	  patient_apts.add(c);
  	} 
  	
  	//add clinical apts to top level object - pulling all entries now - oldest to newest so the new one overwrites the old
  	for(Clinical_Apt_Calendar__c ca : [Select c.id,c.Patient_POT_Apt__c, apt_date__c, patient_pot_apt__r.name, apt_status__c
  	  From Clinical_Apt_Calendar__c c where clinical_room__r.center_information__c = :current_center.id
  	  and c.apt_date__c >= :report_sdate and c.apt_date__c <= :report_edate
  	  and c.patient_pot_apt__c != null  	  
  	  order by apt_date__c,stime__c]) {
  	  if(pot_to_apt_map.get(ca.patient_pot_apt__c)!=null)
  	    pot_to_apt_map.get(ca.patient_pot_apt__c).apt = ca;  	
  	}
  	  	
  	//pull clinical notes instances and build second level class  	  	
  	for(Clinical_Note_Instance__c cni : [Select lastmodifiedby.name, lastmodifieddate, c.Review_Time__c, c.id, c.Reviewed_By__c, c.reviewed_by__r.name, c.Patient_POT_Apt__c, c.IsActive__c, c.CreatedDate, c.CreatedBy.name, c.Clinical_Apt_Calendar__c, c.Apt_Note__c, c.Account__c, c.account__r.name, Patient_POT_Apt__r.clinical_appointment__c, clinical_apt_calendar__r.doctor__c,clinical_apt_Calendar__r.doctor__r.name,
  	  (Select bmi_calc__c,height_feet__c,height_inches__c,post_op_general_condition__c,post_op_mental_status__c,post_op_pain_management__c,post_op_hematosis__c,avoiding_strenuous_activity__c,ambulating_without_assistance__c,post_op_oral_intake__c,post_op_general_condition_notes__c,post_op_mental_status_notes__c,
  	    responsible_adult_driver__c,post_op_pulse__c,post_op_pulse_ox__c,post_op_bp_diastolic__c,post_op_bp_systolic__c,post_op_instructions_reviewed__c,sinus_communication_notes__c,sinus_communication_right__c,sinus_communication_left__c,sutures_other__c,sinus_lift_right_max__c,sinus_lift_left_max__c,sinus_lift_right_max_type__c,sinus_lift_left_max_type__c,Procedure_Site_Confirmed__c,Medical_History_Reviewed__c,Denies_Pregnancy__c,Pre_op_medications_given__c,NPO_Confirmed__c,Radiographs_Available_and_up_to_date__c,Consent_Accurate_and_Signed__c,Patient_Examined_Heart_Lungs__c,Monitors_in_place__c,
        Emergency_Cart_Ready__c,STO_Procedure_Consent_Confirmed__c,weight__c,pre_op_notes__c,asa__c,Pre_Op_Pulse_Ox__c,Pre_Op_Pulse__c,Pre_Op_BP_Systolic__c,pre_op_BP_Diastolic__c,Post_Op_Care_Comments__c, Bone_Graft_Material_Multi__c, Bone_Graft_Material_Note__c,flap_design__c,Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Procedure_Verified__c, Vital_Signs__c, Lidocaine__c, lidocaine_50__c, local_anesthetic_other__c, sedation_other__c, sedation_used__c, sutures__c, Marcaine__c, Septocaine__c, Fentanyl__c, Versed__c, Ketamine__c, Propofol__c, Morphine__c, Envelope__c, Blade_Num__c, Releasing_Incision__c, Buccal_hockey_stick__c, Extractions__c, Alveolectomy__c, Alveolectomy_Amount__c, Alveolectomy_Leveling__c, Betadine__c, Assistants__c, Implant_System__c, Implant_System_Other__c, Implant_Tooth_Position__c, Findings_Complications__c, Discussed_Oral_Hygiene__c, Reviewed_Soft_Food_Diet__c, Interim_Night_Guard_Delivered__c, Bone_Graft_Area__c, Bone_Graft_Type__c, Bone_Graft_Material__c, Bone_Graft_Harvest_Site__c, Sinus_Communication__c, Lateral_sinus_corticotomies__c, Buccal_cortex_intact__c, Lingual_cortex_intact__c, Post_Op_Instruction_Given__c, Icepack_Placed__c, Post_operative_nausea__c, Post_Operative_Pain_Controlled__c, Post_operative_bleeding_controlled__c, Re_anesthetized__c, Post_Surgery_Lidocaine__c, Post_Surgery_MarCaine__c, Post_Surgery_Septocaine__c, Prosth_Screw_Torque_Value__c, Confirmation_Radiography__c, Impression_material_used__c, Placed_seals_using__c, Occlusal_Adjustment__c, IsActive__c, Clinical_Apt_Calendar__c, Account__c,
        Ibuprofin__c, Dexamethasone__c, Benadryl__c, Carbocaine__c         
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
  	  From Clinical_Note_Instance__c c where clinical_apt_calendar__c in :cal_apt_set order by createddate]) {
  	  dp_clinical_notes_new.apt_form af = new dp_clinical_notes_new.apt_form(cni);
  	  if(pot_to_apt_map.get(cni.patient_pot_apt__c)!=null)
  	    pot_to_apt_map.get(cni.patient_pot_apt__c).standard_forms.add(af);
  	  instance_to_form_map.put(cni.id,af);
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
  	}  	
  	
  	//grab our surgical note implants - if any
  	for(Surgical_Note_Implant__c si : [Select s.Numerical_Name__c,s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Length__c, s.Id, s.CreatedDate, s.CreatedById, s.Abutment_Straight__c, s.abutment_width__c, s.Abutment_Collar_Height__c, surgical_notes_form__r.clinical_apt_calendar__c , surgical_notes_form__r.Clinical_Note_Instance__c, bone_density__c, Unique_Placement__c, implant_torque_number__c, buried_implant__c, healing_cap_placed__c, closure_screw_placed__c, 	JIG_Ostell_ISQ__c,Conversion_Torque_Value__c, 	Ostel__c, Final_Ostell_ISQ__c, 
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
  	    instance_to_form_map.get(si.surgical_notes_form__r.Clinical_Note_Instance__c).all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.final_notes_form__c!=null)
  	    instance_to_form_map.get(si.final_notes_form__r.Clinical_Note_Instance__c).all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.conversion_notes_form__c!=null)
  	    instance_to_form_map.get(si.conversion_notes_form__r.Clinical_Note_Instance__c).all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.jig_notes_form__c!=null)
  	    instance_to_form_map.get(si.jig_notes_form__r.Clinical_Note_Instance__c).all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	  if(si.redo_surgery_form__c!=null)
  	    instance_to_form_map.get(si.redo_surgery_form__r.Clinical_Note_Instance__c).all_implants.add(new dp_clinical_notes_new.ImplantWrapper(si));
  	}  	
  	
  	//grab medications administered
  	for(Medication__c med : [select id, amount_taken__c, route__c, generic_drug_name__c, status_notes__c, surgical_notes_form__c, surgical_notes_form__r.Clinical_Note_Instance__c, Minute_Administered__c, Hour_Administered__c, Administered_Suffix__c 
  	  from Medication__c 
  	  where surgical_notes_form__c in :sform_ids]) {
  	  System.debug('Adding medication ' + med);
  	  instance_to_form_map.get(med.surgical_notes_form__r.Clinical_Note_Instance__c).all_medications.add(med);
  	}
  	return patient_apts;   	
  }
  
  public list<dp_clinical_notes_new.follow_up_note> getfollow_up_notes() {
  	list<dp_clinical_notes_new.follow_up_note> fnotes = new list<dp_clinical_notes_new.follow_up_note>();
    for(Win_Cnote_Import__c wci : [select account__r.name,note_date__c, doctor_note__c,lastmodifiedby.profile.name,createddate,lastmodifiedby.name from win_cnote_import__c    	 
      where account__r.center__c = :current_center.id and windent_note__c = false and note_date__c >= :report_sdate and note_date__c <= :report_edate order by note_date__c]) {
      fnotes.add(new dp_clinical_notes_new.follow_up_note(wci)); 
    }  	
    return fnotes;
  }
  
  public void doctor_review_note() {
    try {
	  Clinical_Note_Instance__c cn = [select id,reviewed_by__c,review_time__c from Clinical_Note_Instance__c where id = :apexpages.currentpage().getparameters().get('noteid')];   
	  cn.reviewed_by__c = Userinfo.getuserid();
	  cn.review_time__c = System.now();
	  update cn;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to review the note.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public Component.Apex.Outputpanel getapt_note_section(dp_clinical_notes_new.apt_form last_form,String pot_status, String pot_name, Date apt_date) {
  	Component.Apex.Outputpanel section_holder = new Component.Apex.Outputpanel(styleclass='cc-clinicalNotes-container');
  	Component.Apex.OutputText html_out = new Component.Apex.OutputText(escape=false);
  	String review_line = '';
  	if(last_form.getallow_review() && getis_user_doctor()) 
  	  review_line = '<div class="cc-form-notation-button" style="max-width:180px;" onclick="review_note(\'' + last_form.cnote.id + '\');">Doctor Reviewed</div>';
  	if(!last_form.getallow_review())
  	  review_line = '<div style="font-style:italic;">' + last_form.getreview_line() + '</div>';  
  	String doc_name = '';
  	if(last_form.cnote.clinical_apt_calendar__r.doctor__c!=null)
  	  doc_name = ' - ' + last_form.cnote.clinical_apt_Calendar__r.doctor__r.name;  	
  	html_out.value = '<div class="cc-form-narrative-container">'
  	  + '<div class="cc-form-header-container">'
  	  + '<div class="cc-clinicalNote-header">'
  	  + '<div class="cc-clinicalNote-header-label">' + last_form.cnote.account__r.name + ' - ' + (pot_status=='Incomplete'?'Incomplete - ':'') + pot_name + doc_name + ' -  Apt Date :&nbsp;'
  	  + Datetime.newinstance(apt_date,Time.newinstance(0,0,0,0)).format('M/dd/yyyy') + '&nbsp;&nbsp;Form Date :&nbsp;' 
  	  + last_form.cnote.createddate.format('M/dd/yyyy') + '</div></div></div><div class="cc-narrative-body">' + last_form.getnarrative_text()
  	  + '<div style="display:flex;">' + review_line + '<span class="spacer">&nbsp;</span><a style="color:black;text-decoration:none;align-self:center;" target="__blank" href="/apex/ccare_clinical_notes?ctrid=' + current_center.id + '&ici=' + last_form.cnote.id + '&ptid=' + last_form.cnote.account__c + '">' 
  	  + '<span class="cc-form-notation-button" style="max-width:180px;">Open Notes Page</span></a></div>'
  	  + '</div></div>';
  	
  	section_holder.childcomponents.add(html_out);  	
  	return section_holder;
  }
  
  public boolean getis_user_doctor() {
  	if(userinfo.getName()=='Chris McDowell')
  	  return true;
  	else
  	  return doctor_profiles.contains(profile_name);
  }
  
  public Component.Apex.Outputpanel getfollow_up_note_section(Win_Cnote_Import__c fnote) {
  	Component.Apex.Outputpanel section_holder = new Component.Apex.Outputpanel(styleclass='cc-clinicalNotes-container');
  	Component.Apex.OutputText html_out = new Component.Apex.OutputText(escape=false);  	  	
  	html_out.value = '<div class="cc-form-narrative-container">'
  	  + '<div class="cc-form-header-container">'
  	  + '<div class="cc-clinicalNote-header">'
  	  + '<div class="cc-clinicalNote-header-label">Follow Up Note - ' + fnote.account__r.name + ' - Date :&nbsp;'
  	  + Datetime.newinstance(fnote.note_date__c,Time.newinstance(0,0,0,0)).format('M/dd/yyyy')  
  	  + '</div></div></div><div class="cc-narrative-body"><pre style="background:#eee;border:0;font-family: \'Open Sans\', sans-serif;word-break:normal;white-space:pre-wrap;">' + fnote.doctor_note__c + ' - ' + fnote.lastmodifiedby.name + '</pre> ' 
  	  + '<a style="color:black;text-decoration:none;align-self:center;" target="__blank" href="/apex/ccare_clinical_notes?ctrid=' + current_center.id + '&ptid=' + fnote.account__c + '">' 
  	  + '<span class="cc-form-notation-button" style="max-width:180px;">Open Notes Page</span></a></div></div>';
  	section_holder.childcomponents.add(html_out);  	
  	return section_holder;
  }
  
  public Component.Apex.Outputpanel getnarrative_date_sorted_display() {
  	Component.Apex.Outputpanel html_holder = new Component.Apex.Outputpanel();
  	List<dp_clinical_notes_new.narrative_item> all_narrative_list = new List<dp_clinical_notes_new.narrative_item>();
  	for(dp_clinical_notes_new.clinical_apt ca : getpatient_apts()) {
  	  if(ca.getnum_notes_instances()>0) {
  	    dp_clinical_notes_new.narrative_item nitem = new dp_clinical_notes_new.narrative_item(getapt_note_section(ca.getmost_recent_form(),ca.apt.apt_status__c,ca.apt.patient_pot_apt__r.name,ca.apt.apt_date__c),ca.apt.apt_date__c);
  	    all_narrative_list.add(nitem);
  	  }
  	}
  	for(dp_clinical_notes_new.follow_up_note fnote : getfollow_up_notes()) {
  	  dp_clinical_notes_new.narrative_item nitem = new dp_clinical_notes_new.narrative_item(getfollow_up_note_section(fnote.note),fnote.note.note_date__c);
  	  all_narrative_list.add(nitem);
  	}
  	all_narrative_list.sort();
  	for(dp_clinical_notes_new.narrative_item nitem : all_narrative_list) {
  	  html_holder.childcomponents.add(nitem.narrative_section);
  	}  	
  	return html_holder;
  }
  
}