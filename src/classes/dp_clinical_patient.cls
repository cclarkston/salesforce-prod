public with sharing class dp_clinical_patient {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  public Account patient {get;set;}
    
  public Boolean initial_patient_search {get;set;}
  public String search_name {get;set;}
  public String search_first {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public String search_unique {get; set;}
  public String modal_out {get; set;}
  public String history_sort_direction {get; set;}
  
  public Patient_Health_History__c phhistory {get; set;}
  
  public Boolean display_medical_warnings {get; set;}
  public Boolean display_patient_search_modal {get; set;}
  public Boolean display_patient_email_modal {get; set;}  
  public Boolean display_patient_sms_modal {get; set;}
  public Boolean display_photo_modal {get; set;}
  public Boolean display_new_note {get; set;}
  public Boolean display_history_modal {get; set;}
  public Boolean display_note_history_modal {get; set;}
  public Boolean display_apt_search_modal {get; set;}  
  public Boolean display_document_modal {get; set;}
  
  public Patient_POT_Apt__c sched_apt {get; set;}
  public Patient_Procedure_Form__c new_pform {get; set;}
  
  public String email_attachment_display {get; set;}
  public String photo_display {get; set;}
  
  public List<Account> consult_search_results {get; set;}
  public String email_subject {get; set;}
  public String email_body {get; set;}
  public String email_status {get; set;}
  public String hh_email_status {get; set;}
  public List<Attachment> email_attachments {get; set;}
  public Attachment new_email_attachment {get;set;}
  public String url_label {get; set;}
  public String url_href {get; set;}
  
  public Note new_clinical_note {get; set;}
  
  public Patient_Procedure_Form__c admin_form {get; set;}
  
  public paged_results search_pager {get;set;}
  
  public String sms_text_msg {get; set;}
  public String sms_text_target {get; set;}
  
  
  //switched to transient on 4/11/2017 to reduce view state size.  Needs more testing to make sure this doesn't cause a problem.
  public transient dp_clinical_pot.pot[] displayed_plans {get; set;}
  public String new_apt_form_id {get; set;}
  
  public String new_apt_name {get; set;}
  public String apt_filter {get; set;}
  public String new_apt_sort {get; set;}
  
  //apt search filters
  public Integer month_filter {get;set;}
  public Boolean search_monday {get;set;}
  public Boolean search_tuesday {get;set;}
  public Boolean search_wednesday {get;set;}
  public Boolean search_thursday {get;set;}
  public Boolean search_friday {get;set;}
  
  public Boolean search_open {get; set;}
  public Boolean search_morning {get; set;}
  public Boolean search_noon {get; set;}
  public Boolean search_afternoon {get; set;}
  public Boolean search_close {get; set;}
  
  public String doctor_filter {get;set;}  
  
  public ID current_edit {get; set;}
  public ID apt_id {get; set;}
  public String form_remove_id {get; set;}
  
  public Boolean display_calendar_modal {get; set;}
  public Clinical_Apt_Calendar__c apt_block {get; set;}
  public String calendar_modal_display {get; set;}
  public String cancel_reason {get; set;}
  
  public Boolean display_pform {get; set;}
  
  public String allergy_search_value {get; set;}
  public List<Allergy__c> allergy_search_results {get;set;}
  public Boolean display_allergy_form {get; set;}
  public Boolean confirmation_modal_display {get; set;}
  public Allergy__c new_allergy {get; set;}
  public String confirmation_modal_type {get; set;}
  Set<ID> market_centers;
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  
  public transient String photo_data {get;set;}
  public transient String photo_content_type {get;set;}
  public transient String photo_name {get;set;}
  
  public String notes_sort_direction {get; set;}
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
    
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}  
    
  static {
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  }
  
  public class bendException extends Exception {}	
  
  public Boolean allow_quick_search;
  public Boolean getallow_quick_search() {
  	if(allow_quick_search==null)
  	  allow_quick_search = [select id,Enable_Patient_Quick_Search__c from user where id = :userinfo.getuserid()].enable_patient_quick_search__c; 
  	return allow_quick_search;
  }    
	  
  public dp_clinical_patient() { 
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
       // User u = [select clinic_calendar__c from user where id =:userinfo.getUserId()];         
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,Hope_RX_Sending_Email__c,sales_region__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,allow_dymo_reminder__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,Hope_RX_Sending_Email__c,sales_region__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,allow_dymo_reminder__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,Hope_RX_Sending_Email__c,sales_region__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,allow_dymo_reminder__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   	  	  	  	  	
  	market_centers = getcenters_in_market();
  	//to-do handle default patient
  	try {
  	  if(apexpages.currentpage().getparameters().get('ptid')!=null) {
  	    getpatient_record(apexpages.currentpage().getparameters().get('ptid'),current_center.id);
  	    initial_patient_search = false;
  	  } else {
  	    initial_patient_search = true;
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
	  
  	display_medical_warnings = true;
  	display_patient_search_modal = false;
  	display_patient_email_modal = false;
  	display_patient_sms_modal = false;
  	display_photo_modal = false;
  	display_new_note = false;
  	display_history_modal = false;
  	display_note_history_modal = false; 
  	display_apt_search_modal = false;
  	display_document_modal = false;
  	current_edit = null;
  	new_apt_form_id = null;
  	email_attachment_display = 'attachments';
  	display_calendar_modal = false;
  	display_pform = false;
  	display_allergy_form = false;
  	confirmation_modal_display = false;
  	num_patient_records = 20;
  	display_more_search_records = false;
  	history_sort_direction = 'descending';
  	form_remove_id = null;
  	notes_sort_direction = 'asc';
  	email_status = '';
  	hh_email_status = '';
  	search_pager = new paged_results();
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
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,Hope_RX_Sending_Email__c,sales_region__c,street_1__c,street_2__c,city__c,state__c,zip_code__c,legal_name__c,Local_Front_Desk__c,allow_dymo_reminder__c,Use_Windent_ID_for_Dexis_when_possible__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  market_centers = getcenters_in_market();
  	  patient = null;
  	  email_status = '';
  	  hh_email_status = '';
  	  initial_patient_search = true;
  	  search_name = '';
  	  search_first = '';
  	  search_unique = '';
  	  search_phone = '';
  	  search_email = '';
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
  
  public Boolean getpatient_record_selected() {
  	if(patient==null)
  	  return false;
  	else
  	  return true;
  }
  
  public Integer getcurrent_query_count() {
  	return Limits.getQueries();
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
  	try {
  	  return consult_search_results.size();
  	} catch (Exception e) {return 0;}
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
  	  initial_patient_search = false;
  	  display_medical_warnings = true;
  	  consult_search_results = new List<Account>();
  	  display_patient_search_modal = false;
  	  pr = Page.ccare_clinical_patient;
  	  pr.getparameters().put('ptid',apexpages.currentpage().getparameters().get('sptid'));
  	  pr.getparameters().put('ctrid',current_center.id);
  	  pr.setredirect(true);
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the patient record.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return null;
  	}
  	try {
  	  Dosespot dosespot = new DoseSpot(patient.id,current_center);             
      dosespot.DoseSpot_patient_URL();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to setup dosespot for this patient.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return pr;
  	}  
  	try {
      //verify warranty_id__c is valid
      if(patient.warranty_id__c==null)
        generate_unique_patient_id();
      else if(patient.warranty_id__c.length()>9)
        generate_unique_patient_id(); 
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to generate unique id for patient.  Please contact IT for help'));
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
  
  public String getpec_owner() {
  	String owner_name = '';
  	try {      
      owner_name = 'PEC - ' + patient.opportunities[0].current_owner__c; 
  	} catch (Exception e) {}
  	return owner_name;
  }
  
  public String getwindent_ids() {
  	String winid = '';
  	Set<String> unique_id = new Set<String>();
  	for(Opportunity o : patient.opportunities) {
  		//doing it this way to dedupe
  	  unique_id.add(o.windent_patient_id__c);
  	}
  	Integer cnt = 0;
  	for(String s : unique_id) {
  	  if(cnt>0)
  	    winid += ' | ';
      winid += s;
      cnt++; 
  	}
  	return winid;
  }
  
  public void getpatient_record(String patient_id,String center_id) {
  	System.debug('Patient id : ' + patient_id);
  	System.debug('Center : ' + market_centers);
    patient = [select business_phone__c,nickname__c,id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,emergency_contact_name__c,emergency_contact_phone__c,
      clinical_notes__c,isPersonAccount,firstname,lastname,date_of_birth__c,PersonContactId,main_photo_id__c,personemail, warranty_id__c,(select id,windent_patient_id__c,short_code__c,owner.name,current_owner__c from opportunities order by createddate desc)
      from Account where id = :patient_id and center__c in :market_centers];
    email_status = '';
    hh_email_status = '';
    //try and grab the most recent patient health history file    
    try {      
      phhistory = [select id,Is_Complete__c,edit_link__c,Review_Page_Link__c from patient_health_history__c where account__c = :patient.id order by createddate desc limit 1];           
    } catch (Exception e) {
      //not an issue - there is no health history file
      phhistory = null;
    } 
  }
  
  public void save_patient_changes() {
  	try {      
  	  update patient;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving the patient record.'));
      ApexPages.addMessages(e);
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
  	num_patient_records = 20;
  }
  
  public void close_patient_search() {
  	display_patient_search_modal = false;
  }
  
  public void open_new_mail_form() {
  	display_patient_email_modal = true;
  	email_subject = 'Subject';
  	email_body = '';
  	email_attachments = new List<Attachment>();
  	email_attachment_display = 'attachments';
  }
  
  public void close_mail_form() {
  	display_patient_email_modal = false;
  }
  
  public void close_medical_warnings() {
  	display_medical_warnings = false;
  }
  
  public void open_attachment_form() {
  	email_attachment_display = 'attachment_form';
  	new_email_attachment = new Attachment(parentid = patient.id);
  }
  
  public void close_attachment_form() {
  	email_attachment_display = 'attachments';
  }
  
  public void open_url_form() {
  	email_attachment_display = 'url_form';
  	url_label = '';
  	url_href = '';
  }
  
  public void close_url_form() {
  	email_attachment_display = 'attachments';
  }
  
  public void add_url_to_email() {
  	email_body += ' <a href="' + url_href + '">' + (url_label==''?url_href:url_label) + '</a> ';
  	close_url_form();
  }
  
  public void remove_email_attachment() {
  	//to-do delete the attachment and remove it from the list
  	ID attachment_id = apexpages.currentpage().getparameters().get('atid');
  	System.debug('Attach ID : ' + attachment_id);
  	//remove it from our email_attachments list
  	Integer i = 0;
  	Boolean match_found = false;
  	for(Attachment a : email_attachments) {
  	  if(a.id==attachment_id)
  	  	match_found = true;
  	  if(!match_found)
  	    i++;
  	}  	
  	email_attachments.remove(i);
  	//delete the attachment
  	try {
  	  Attachment a = [select id,name from Attachment where id = :attachment_id];
  	  delete a;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the attachment.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void add_email_attachment() {
  	try {
  	  insert new_email_attachment;
  	  email_attachments.add(new_email_attachment); 
  	  close_attachment_form(); 	  
  	} catch (Exception e) {
  		System.debug('Attachment issue : ' + e);
  	}  	
  }
  
  public void send_email() {
  	//TO-DO - figure out who the email should come from.  Probably a general email tied to the center...or maybe the user
  	try {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  	
	  //mail.setSenderDisplayName('ClearChoice');
	  OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where displayname = :current_center.Hope_RX_Sending_Email__c or Address = :current_center.hope_rx_sending_email__c];
	  if ( owea.size() > 0 ) {
	    mail.setOrgWideEmailAddressId(owea.get(0).Id);
	  }  
	  mail.setTargetObjectId(patient.PersonContactId); //Specify who the email should be sent to.
	  mail.setSubject(email_subject);
	  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head></head><body>' + email_body + 
	  '</body></html>');
	  mail.setPlainTextBody(email_body);
	  
	  if(email_attachments.size()>0) {
	  	List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
	    for (Attachment a : email_attachments) {
	      // Add to attachment file list
	      Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
	      efa.setFileName(a.Name);
	      efa.setBody(a.Body);
	      fileAttachments.add(efa);
	    }	    
	    mail.setFileAttachments(fileAttachments);
	  }
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});	
	  close_mail_form();	    			
	}  catch (Exception e) {
	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to send the email.  Please contact IT for help'));
      ApexPages.addMessages(e);
	}    
  }
  
  public List<Selectoption> getvalid_sms_targets() {
  	List<Selectoption> tlist = new List<Selectoption>();
  	if((patient.phone==null?'':patient.phone)!='') {
  	  tlist.add(new Selectoption('Home','Home'));
  	}
  	if((patient.personmobilephone==null?'':patient.personmobilephone)!='') {
  	  tlist.add(new Selectoption('Mobile','Mobile'));
  	}  	
	return tlist;
  }
  
  public void open_sms_form() {
  	//verify we have a phone number for this patient before opening the form
  	if((patient.personmobilephone==null?'':patient.personmobilephone)=='' && (patient.phone==null?'':patient.phone)==''  ) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no phone numbers for this patient.  SMS is not available at this time'));
  	}
  	else {
  	  display_patient_sms_modal = true;
  	  sms_text_msg = '';
  	  sms_text_target = 'Home';
  	  if((patient.personmobilephone==null?'':patient.personmobilephone)!='') {
  	    sms_text_target = 'Mobile';
  	  }
  	}
  }
   
  public void close_sms_form() {
  	display_patient_sms_modal = false;
  }
  
  public void send_sms_message() {
  	smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
    String senderId = '18055007067'; //Userinfo.getName();  //SenderId assing to user by default it is'smsMagic'
    smsObject.smagicinteract__Name__c = patient.Name;
    smsObject.smagicinteract__ObjectType__c = 'Account';
    smsObject.Account__c = patient.id;
    smsObject.smagicinteract__SenderId__c = senderId;    
    smsObject.smagicinteract__disableSMSOnTrigger__c = 0;    
    smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
    smsObject.smagicinteract__SMSText__c = sms_text_msg;
    if(sms_text_target=='Home')
      smsObject.smagicinteract__PhoneNumber__c = patient.phone;
    else if(sms_text_target=='Mobile')
      smsObject.smagicinteract__PhoneNumber__c = patient.personmobilephone;
    System.debug('smsObject ' + smsObject);
    try {
      if(!test.isRunningTest())
        insert smsObject;
      close_sms_form();
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to send the text message.  Please contact IT for help'));
      ApexPages.addMessages(e);    	
    }
  }
  
  public void open_document_modal() {
  	display_document_modal = true;
  	admin_form = [Select (Select Id, Name, BodyLength, createdby.name, createddate  From Attachments),p.Upload_Date__c, p.Patient_POT__c, p.Office_Form__c, p.Form_Status__c, p.Account__c, p.form_name__c, p.forms_category__c,patient_pot__r.name From Patient_Procedure_Form__c p where id = :apexpages.currentpage().getparameters().get('pfid')];
  	photo_display = 'document_admin';
  	new_email_attachment = new Attachment(parentid = admin_form.id, description = 'Document Scan');
  }
  
  public void back_to_document_modal() {
  	photo_display = 'document_admin';
  	new_email_attachment = new Attachment(parentid = admin_form.id, description = 'Document Scan');
  }
  
  public Integer getdocument_uploaded_count() {
  	Integer upload_count = 0;
  	if(admin_form!=null)
  	  upload_count = admin_form.attachments.size();
  	return upload_count;
  }
  
  public void add_document_upload() {
  	try {
  	  insert new_email_attachment; 
  	  new_email_attachment = new Attachment(parentid = admin_form.id, description = 'Document Scan');
  	  admin_form.upload_date__c = System.now();
  	  admin_form.form_status__c = 'Scanned';
  	  update admin_form;
  	  admin_form = [Select (Select Id, Name, BodyLength, createdby.name, createddate From Attachments),p.Upload_Date__c, p.Patient_POT__c, p.Office_Form__c, p.Form_Status__c, p.Account__c, p.form_name__c, p.forms_category__c,patient_pot__r.name From Patient_Procedure_Form__c p where id = :admin_form.id];  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to upload the document.  Please contact IT for help'));
      ApexPages.addMessages(e);    	
  	}  	
  }
  
  public void upload_patient_document() {
  	try {
      new_email_attachment.name = photo_name;
      new_email_attachment.contentType=photo_content_type;
      new_email_attachment.Body=EncodingUtil.base64Decode(photo_data);
      insert new_email_attachment;
      new_email_attachment = new Attachment(parentid = admin_form.id, description = 'Document Scan');
  	  admin_form.upload_date__c = System.now();
  	  admin_form.form_status__c = 'Scanned';
  	  update admin_form;
  	  admin_form = [Select (Select Id, Name, BodyLength, createdby.name, createddate From Attachments),p.Upload_Date__c, p.Patient_POT__c, p.Office_Form__c, p.Form_Status__c, p.Account__c, p.form_name__c, p.forms_category__c,patient_pot__r.name From Patient_Procedure_Form__c p where id = :admin_form.id];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to upload the document.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public void open_photo_modal() {
  	display_photo_modal = true;
  	photo_display = 'photo_admin';
  	new_email_attachment = new Attachment(parentid = patient.id, description = 'Patient Photo');
  }
  
  public void close_document_modal() {
  	display_document_modal = false;
  	admin_form = null;
  }
  
  public void close_photo_modal() {
  	display_photo_modal = false;
  }
  
  public void add_patient_photo() {
  	try {
  	  insert new_email_attachment; 
  	  patient.main_photo_id__c = new_email_attachment.id;
  	  update patient;
  	  new_email_attachment = new Attachment(parentid = patient.id, description = 'Patient Photo');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the photo.  Please contact IT for help'));
      ApexPages.addMessages(e);    	
  	}  	
  }
  
  public void upload_patient_photo() {
  	try {
      new_email_attachment.name = photo_name;
      new_email_attachment.contentType=photo_content_type;
      new_email_attachment.Body=EncodingUtil.base64Decode(photo_data);
      insert new_email_attachment;
      patient.main_photo_id__c = new_email_attachment.id;
  	  update patient;
  	  new_email_attachment = new Attachment(parentid = patient.id, description = 'Patient Photo');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the photo.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public void confirm_photo_removal() {
  	new_email_attachment = [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, 
  	  a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a where id = :apexpages.currentpage().getparameters().get('atid')];
  	display_photo_modal = true;
  	photo_display = 'photo_remove';  	
  }
  
  public void confirm_document_removal() {
  	new_email_attachment = [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, 
  	  a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a where id = :apexpages.currentpage().getparameters().get('atid')];
  	display_document_modal = true;
  	photo_display = 'document_remove';  	
  }
  
  public void remove_document() {
  	try {
      delete new_email_attachment;
  	  admin_form = [Select (Select Id, Name, BodyLength, createdby.name, createddate From Attachments),p.Upload_Date__c, p.Patient_POT__c, p.Office_Form__c, p.Form_Status__c, p.Account__c, p.form_name__c, p.forms_category__c,patient_pot__r.name From Patient_Procedure_Form__c p where id = :admin_form.id];
  	  photo_display = 'document_admin';
  	  //check to see if we still have a scanned doc....if not reset the status and upload date
  	  if(admin_form.attachments.size()==0) {
  	  	admin_form.upload_date__c = null;
  	  	admin_form.form_status__c = 'Incomplete';
  	  }
  	  new_email_attachment = new Attachment(parentid = admin_form.id, description = 'Document Scan');
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the document.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void remove_photo() {
  	try {
  	  String deleted_id = new_email_attachment.id;  	  
  	  delete new_email_attachment;
  	  if(patient.main_photo_id__c==deleted_id) {
  	    //check if we have any photos...if so,  grab the most recent id and set the main photo id field...otherwise set it to null
  	    if(getnum_patient_photos()>0) {
  	      List<Attachment> photos = getpatient_photos();
  	      patient.main_photo_id__c = photos[0].id;
  	    }
  	    else
  	      patient.main_photo_id__c = null;
  	    update patient;
  	  }
  	  open_photo_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the photo.  Please contact IT for help'));
      ApexPages.addMessages(e); 
  	}
  }
    
  public void change_main_photo() {
  	patient.main_photo_id__c = apexpages.currentpage().getparameters().get('atid');
  	update patient;
  }
  
  public Attachment getmain_patient_photo() {
  	try {
  	  return [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a
  	    where parentid = :patient.id and description = 'Patient Photo' and id = :patient.main_photo_id__c];
  	} catch (Exception e) {
  	  List<Attachment> pphoto = getpatient_photos();
  	  if(pphoto.size()>0)
  	    return pphoto[0];
  	  else
  	    return null;
  	} 
  }
  
  public List<Attachment> getthumbnail_photos() {
  	List<Attachment> thumb_list = [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a
  	  where parentid = :patient.id and description = 'Patient Photo' and id != :patient.main_photo_id__c];   	
  	return thumb_list;
  }
  
  public List<Attachment> getpatient_photos() {
  	return [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a
  	  where parentid = :patient.id and description = 'Patient Photo' order by createddate desc]; 
  }
  
  public Integer getnum_patient_photos() {
  	return getpatient_photos().size();
  }
  
  public class history_date implements Comparable {
  	Date hdate;
  	public history_event[] events {get;set;}
  	public String sort_direction {get;set;}
  	
  	public history_date(Date row_date,String sorder) {
  	  this.hdate = row_date;
  	  events = new List<history_event>();	
  	  this.sort_direction = sorder;
  	}
  	
  	public String getformatted_history_date() {
  	  return DateTime.newInstance(hdate.year(),hdate.month(),hdate.day()).format('M/dd/yyyy'); 	 
  	}
  	
    public Integer compareTo(Object compareTo) {
      history_date compareTodate = (history_date)compareTo;
        
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (hdate > compareTodate.hdate) {
        // Set return value to a positive value.
        returnValue = (sort_direction=='ascending'?1:-1);
      } else if (hdate < compareTodate.hdate) {
        // Set return value to a negative value.
        returnValue = (sort_direction=='ascending'?-1:1);
      }            
      return returnValue;       
    }
  }
  
  public class history_event {
  	public String icon_name {get; set;}
  	public String event_description {get; set;}
  	public String icon_color {get; set;}
  	public ID event_id {get;set;}
  	
  	public history_event(String iname, String description, String color,ID eid) {
  	  this.icon_name = iname;
  	  this.event_description = description;
  	  this.icon_color = color;
  	  this.event_id = eid;
  	}
  }
  
  public List<history_date> gethistory_items() {
  	Map<Date,history_date> history_map = new Map<Date,history_date>();
  	List<History_date> history_list = new List<history_date>();
  	/*Account subs = [Select id,name,
  	  (Select Id, Title, Body, CreatedDate, CreatedBy.name From Notes order by createddate),
  	  (Select Id, Subject, Description, Type, CreatedDate, CreatedBy.name From Tasks order by createddate),
  	  (Select Id, Subject, Description, Type, CreatedDate, CreatedBy.name From PersonTasks order by createddate),
  	  (Select Id, Name, Description,createddate,createdby.name From Attachments order by createddate),
  	  (Select Id, smagicinteract__SMSText__c,createddate,createdby.name From SMS_History__r),
  	  (Select Patient_POT_Apt__r.name, Action__c, Reschedule_Reason__c, Cancel_Reason__c, Delete_Reason__c, Notes__c, Action_Reason__c,createddate,clinical_apt_calendar__r.apt_date__c,clinical_apt_calendar__r.stime__c,clinical_apt_calendar__c From Clinical_Apt_Histories__r where action__c in ('Scheduled','Cancel','Rescheduled','Patient Left','No Show','Completed')),
  	  (Select Apt_Date__c, Patient_POT_Apt__r.name, Apt_Status__c From Clinical_Apt_Calendar__r) 	  
  	   From Account a where id=:patient.id];*/     
  	Account subs = [Select id,name,
  	  (Select Id, Title, Body, CreatedDate, CreatedBy.name From Notes order by createddate),
  	  (Select Id, Name, Description,createddate,createdby.name From Attachments order by createddate)  	  
  	   From Account a where id=:patient.id];   
  	//pull notes
  	for(Note n : subs.notes) {
  	  Date ndate = n.createddate.date();
  	  //see if we have a new date of interest
  	  if(history_map.get(ndate)==null) {
  	  	history_date new_date = new history_date(ndate,history_sort_direction);
  	  	history_map.put(ndate,new_date); 
  	  }
  	  history_event new_event = new history_event('ccf-notes','New Note - "' + n.title + '"','darkBrown',n.id);
  	  history_map.get(ndate).events.add(new_event);
  	}  	
  	//pull photos & attachments
  	for(Attachment a : subs.Attachments) {
  	  if(a.description=='Patient Photo') {
  	    Date ndate = a.createddate.date();
  	    //see if we have a new date of interest
  	    if(history_map.get(ndate)==null) {
  	  	  history_date new_date = new history_date(ndate,history_sort_direction);
  	  	  history_map.put(ndate,new_date); 
  	    }
  	    history_event new_event;  	  
  	    new_event = new history_event('ccf-photo','Uploaded new patient photo','darkPurple',a.id);
  	    history_map.get(ndate).events.add(new_event);
  	  }
  	  //else
  	    //new_event = new history_event('ccf-notes','New Attachment - "' + a.name + '"','darkYellow');  	  
  	}  	
  	//breaking this into pieces to reduce open query locators....maybe
  	subs = [Select id,name,
  	  (Select Id, Subject, Description, Type, CreatedDate, CreatedBy.name From Tasks order by createddate),
  	  (Select Id, Subject, Description, Type, CreatedDate, CreatedBy.name From PersonTasks order by createddate)  	  
  	   From Account a where id=:patient.id]; 
  	//pull tasks (email) 
  	for(Task t : subs.tasks) {
  	  Date ndate = t.createddate.date();
  	  //see if we have a new date of interest
  	  if(history_map.get(ndate)==null) {
  	  	history_date new_date = new history_date(ndate,history_sort_direction);
  	  	history_map.put(ndate,new_date); 
  	  }
  	  history_event new_event;
  	  if(t.subject==null)
  	    new_event = new history_event('ccf-message','New Task - "' + t.subject + '"','darkBrown',t.id);
  	  else if(t.subject.contains('Email'))  	  
  	    new_event = new history_event('ccf-envelope','New Email - "' + t.subject.replace('Email: ','') + '"','darkGreen',t.id);
  	  else
  	    new_event = new history_event('ccf-message','New Task - "' + t.subject + '"','darkBrown',t.id);
  	  history_map.get(ndate).events.add(new_event);
  	}
  	for(Task t : subs.Persontasks) {
  	  Date ndate = t.createddate.date();
  	  //see if we have a new date of interest
  	  if(history_map.get(ndate)==null) {
  	  	history_date new_date = new history_date(ndate,history_sort_direction);
  	  	history_map.put(ndate,new_date); 
  	  }
  	  history_event new_event;
  	  if(t.subject==null)
  	    new_event = new history_event('ccf-message','New Task - "' + t.subject + '"','darkBrown',t.id);
  	  else if(t.subject.contains('Email'))  	  
  	    new_event = new history_event('ccf-envelope','New Email - "' + t.subject.replace('Email: ','') + '"','darkGreen',t.id);
  	  else
  	    new_event = new history_event('ccf-message','New Task - "' + t.subject + '"','darkBrown',t.id);
  	  history_map.get(ndate).events.add(new_event);
  	}
  	//breaking this into pieces to reduce open query locators....maybe
  	subs = [Select id,name,(Select Id, smagicinteract__SMSText__c,createddate,createdby.name From SMS_History__r),
  	  (Select Patient_POT_Apt__r.name, Action__c, Reschedule_Reason__c, Cancel_Reason__c, Delete_Reason__c, Notes__c, Action_Reason__c,createddate,clinical_apt_calendar__r.apt_date__c,clinical_apt_calendar__r.stime__c,clinical_apt_calendar__c From Clinical_Apt_Histories__r where action__c in ('Scheduled','Cancel','Rescheduled','Patient Left','No Show','Completed')),
  	  (Select Apt_Date__c, Patient_POT_Apt__r.name, Apt_Status__c From Clinical_Apt_Calendar__r)
  	   From Account a where id=:patient.id];
  	
  	//pull sms
  	for(smagicinteract__smsMagic__c sms : subs.SMS_History__r) {
  	  Date ndate = sms.createddate.date();
  	  //make sure the text isn't null...if it is,  ignore them per Mr McMullen
  	  if(sms.smagicinteract__SMSText__c!=null) {
  	    //see if we have a new date of interest
  	    if(history_map.get(ndate)==null) {
  	  	  history_date new_date = new history_date(ndate,history_sort_direction);
  	  	  history_map.put(ndate,new_date); 
  	    }
  	    history_event new_event = new history_event('ccf-message','Sent SMS - "' + (sms.smagicinteract__SMSText__c.length()>30?(sms.smagicinteract__SMSText__c.left(30) + '...' ):sms.smagicinteract__SMSText__c) + '"','darkTeal',sms.id);
  	    history_map.get(ndate).events.add(new_event);
  	  }  	  
  	}  
  	//pull apt history information
    for(Clinical_Apt_History__c cah : subs.Clinical_Apt_Histories__r) {
      Date hdate = cah.createddate.date();
      //see if we have a new date of interest
  	  if(history_map.get(hdate)==null) {
  	  	history_date new_date = new history_date(hdate,history_sort_direction);
  	  	history_map.put(hdate,new_date); 
  	  }
  	  String event_note = cah.action__c + ' - ' + cah.patient_pot_apt__r.name;
  	  if(cah.clinical_apt_calendar__c!=null) {
  	  	Datetime adtime = Datetime.newinstance(cah.clinical_apt_calendar__r.apt_date__c, Time.newinstance(gettime_hours(cah.clinical_apt_calendar__r.stime__c.intvalue()),gettime_minutes(cah.clinical_apt_calendar__r.stime__c.intvalue()),0,0));	
  	  	event_note += ' (' + adtime.format('M/dd/yyyy h:mm a') + ')';
  	  }
  	  history_event new_event = new history_event('ccf-calendar',event_note,'darkPurple',cah.id);
  	  history_map.get(hdate).events.add(new_event);  	  
    }  		
    //pull apt list
    for(Clinical_Apt_Calendar__c ca : subs.Clinical_Apt_Calendar__r) {
      Date adate = ca.apt_date__c;
      //see if we have a new date of interest
  	  if(history_map.get(adate)==null) {
  	  	history_date new_date = new history_date(adate,history_sort_direction);
  	  	history_map.put(adate,new_date); 
  	  }
  	  history_event new_event = new history_event('ccf-clinical',ca.patient_pot_apt__r.name + (ca.apt_status__c==null?'':(' - ' + ca.apt_status__c)),'darkBlue',ca.id);
  	  history_map.get(adate).events.add(new_event);
    }
  	history_list = history_map.values();
  	history_list.sort();
  	return history_list;
  }
  
  public class patient_notes {
  	public Note pnote {get; set;}
  	public List<Note_History__c> pnote_hist {get; set;}
  	public Boolean allow_edit {get; set;}
  	
  	public patient_notes(Note n, Boolean can_edit) {
  	  this.pnote = n;
  	  this.pnote_hist = new List<Note_History__c>();
  	  this.allow_edit = can_edit;
  	}   	 
  	
  	public String getformatted_note_date() {
  	  return pnote.createddate.format('M/dd/yyyy h:mm a');  	  
  	} 
  	
  	public String getnote_type() {
  	  if(pnote.title=='Patient Notification')
  	    return 'Notification';
  	  else if(pnote.title=='Windent Note')
  	    return 'Windent';
  	  else
  	    return 'Note';  	   
  	}
  	
  	public String getnote_color() {
  	  if(pnote.title=='Patient Notification')
  	    return '#b13968';
  	  else if(pnote.title=='Windent Note')
  	    return '#f17834;';
  	  else
  	    return '#39b17f;';
  	}
  }
  
  public void cancel_edit_patient_note() {
  	current_edit = null;
  	new_clinical_note = null;
  }
  
  public void edit_patient_note() {
  	current_edit = apexpages.currentpage().getparameters().get('pnid');
  	try {
      new_clinical_note = [select id,body from Note where id = :current_edit];
  	  display_new_note = false;
  	} catch (Exception e) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The note you were trying to edit,  no longer exists'));}
  }
  
  public void reset_edited_note() {
  	try {new_clinical_note = [select id,body from Note where id = :current_edit];} catch (Exception e) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occured while trying to reset the note'));}
  }
  
  public void save_edited_note() {
  	//grab the old note prior to save
  	try {
  	  Note old_note = [select id,body,lastmodifiedbyid from Note where id = :current_edit];
  	  Note_History__c nh = new Note_History__c(old_body__c = old_note.body,notes_id__c = old_note.id,old_note_by__c = old_note.lastmodifiedbyid);
  	  insert nh;
  	  update new_clinical_note;
  	  current_edit = null;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to save the note'));
  	  ApexPages.addMessages(e); 
  	}
  }
  
  public List<patient_notes> getpatient_notes() {
  	List<patient_notes> pnotes = new List<patient_notes>();
  	Map<Id,patient_notes> pnote_map = new Map<ID, patient_notes>();
  	Account a = database.query('Select createdby.name, createdby.profile.name, ' + 
  	  ' (Select Id, IsDeleted, ParentId, Title, IsPrivate, Body, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, createdby.name, lastmodifiedby.name, lastmodifiedby.profile.name, createdby.profile.name, createdby.userrole.name From Notes order by createddate ' + notes_sort_direction + ') ' + 
  	' From Account a where id = \'' + patient.id + '\'');
  	dp_clinical_security security_controller = new dp_clinical_security();
  	for(Note n : a.notes) {
  	  //check if note should be editable  	  
  	  patient_notes pn = new patient_notes(n,security_controller.allow_notes_edit(n.lastmodifiedby.profile.name));
  	  pnotes.add(pn);
  	  pnote_map.put(pn.pnote.id,pn);
  	}  	
  	//pull notes history
  	for(Note_History__c nh : [select id,notes_id__c,old_body__c,old_note_by__r.name,createdby.name,createddate from Note_History__c where notes_id__c in :pnote_map.keyset()]) {
  	  pnote_map.get(nh.notes_id__c).pnote_hist.add(nh);
  	}
  	return pnotes;
  }  
  
  public String getcurrent_date() {
  	return System.now().format('M/dd/yyyy');
  }
  
  public String toggle_notification_swap(String current_value) {
  	System.debug('Current value : ' + current_value);
  	if(current_value=='Windent Note')
  	  return 'Windent Note';
  	else if(current_value=='Clinical Note')
  	  return 'Patient Notification';
  	else
  	  return 'Clinical Note';
  }
  
  public void toggle_note_notification() {
  	try {
  	  if(apexpages.currentpage().getparameters().get('noteid')=='New') {  	  	
  	    new_clinical_note.title = toggle_notification_swap(new_clinical_note.title);
  	    System.debug('Title : ' + new_clinical_note.title);
  	  } else {
  	    Note n = [select id, title from Note where id = :apexpages.currentpage().getparameters().get('noteid')];
  	    n.title = toggle_notification_swap(n.title);
  	    System.debug('Title : ' + n.title);
  	    update n;
  	  }
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error toggling notification state.  Please contact IT for help'));
      ApexPages.addMessages(e); 
  	}  
  }
  
  public void create_new_notification() {
  	display_new_note = true;
  	new_clinical_note = new Note(parentid = patient.id, title = 'Patient Notification');
  }
  
  public void create_new_note() {
  	display_new_note = true;
  	new_clinical_note = new Note(parentid = patient.id, title = 'Clinical Note');
  }
  
  public void remove_new_note() {
  	display_new_note = false;
  }
  
  public void save_new_note() {
  	try {
  	  insert new_clinical_note;
  	  display_new_note = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the note.  Please contact IT for help'));
      ApexPages.addMessages(e); 
  	}
  }
  
  public dp_clinical_pot.pot[] getpatient_pot_list() {
  	Set<ID> clipboard_apts = new Set<ID>();
  	//for(Clinical_Clipboard__c clip : [select id,patient_pot_apt__c,center_information__c from Clinical_Clipboard__c where createdbyid = :userinfo.getuserid()]) {
  	for(Clinical_Clipboard__c clip : [select id,patient_pot_apt__c,center_information__c from Clinical_Clipboard__c where center_information__c = :current_center.id]) {
      clipboard_apts.add(clip.patient_pot_apt__c);
  	} 
  	displayed_plans = new dp_clinical_pot.pot[] {};
  	for(Patient_POT__c p : [Select p.Treatment_Description__c, p.SystemModstamp, p.Plan_of_Treatment__c, p.plan_of_treatment__r.name, p.OwnerId, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Account__c, p.doctor_notes__c,(Select Health_Condition__c, Request_Status__c, IsActive__c, Patient_POT__c From Medical_Clearances__r where isactive__c = true) From Patient_POT__c p where account__c = :patient.id order by createddate desc]) {
  	  dp_clinical_pot.pot new_plan = new dp_clinical_pot.pot(p);
  	  //grab out apts
  	  Patient_POT_Apt__c last_apt;
  	  for(Patient_POT_Apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, p.doctor_notes__c, (Select Id, Name, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c, allow_tooth_selection__c, target_teeth__c, clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c), 
  	    (Select Id, Apt_Date__c,apt_status__c,start_hour_int__c,start_minute_int__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc),(Select Id From Clinical_Apt_Histories__r) From Patient_POT_Apt__c p where isactive__c = true and patient_pot__c = :new_plan.plan.id order by sort_order__c]) {
  	    Boolean on_clipboard = false;
  	    if(clipboard_apts.contains(pa.id))
  	      on_clipboard = true;
  	    dp_clinical_pot.pot_apt new_apt = new dp_clinical_pot.pot_apt(pa,last_apt,new_plan.getneeds_medical_clearance(),on_clipboard);
  	    new_plan.apts.add(new_apt);
  	    last_apt = pa;
  	  }
  	  //new_plan.apts = [Select p.Sort_Order__c, p.Padding_Time__c, p.Name, p.Lab_Time__c, p.IsActive__c, p.Id, p.Days_Out__c, p.Appointment_Description__c, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Patient_POT_Apt__c, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c) From Patient_POT_Apt__c p where isactive__c = true and patient_pot__c = :new_plan.plan.id order by sort_order__c];
  	  displayed_plans.add(new_plan);
  	}
  	return displayed_plans;
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
  
  public void change_notes_sort_order() {
  	notes_sort_direction = (notes_sort_direction=='asc'?'desc':'asc');
  } 
  
  public void change_history_sort_order() {
  	history_sort_direction = (history_sort_direction=='ascending'?'descending':'ascending');
  }
  
  //public List<Selectoption> gethistory_sort_option_list() {
  	//List<Selectoption> clist = new List<Selectoption> {new Selectoption('ascending','Oldest to Newest'),new Selectoption('descending','Newest to Oldest')};  	
	//return clist;
  //}  
  
  public List<Selectoption> getmonth_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('0','Any'));
  	clist.add(new Selectoption('1','January'));
  	clist.add(new Selectoption('2','February'));
  	clist.add(new Selectoption('3','March'));
  	clist.add(new Selectoption('4','April'));
  	clist.add(new Selectoption('5','May'));
  	clist.add(new Selectoption('6','June'));
  	clist.add(new Selectoption('7','July'));
  	clist.add(new Selectoption('8','August'));
  	clist.add(new Selectoption('9','September'));
  	clist.add(new Selectoption('10','October'));
  	clist.add(new Selectoption('11','November'));
  	clist.add(new Selectoption('12','December'));
	return clist;
  }  
  
  public List<Selectoption> getapt_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	for(Schema.PicklistEntry Value : Clinical_Appointment__c.appointment_filter__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  }  
  
  public void add_appointment_step() {
  	//see if we have a match
  	Integer proc_matches = [select count() from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	if(proc_matches==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid appointment name'));	
  	} else {
  	  try {    	  	
  	  	Clinical_Appointment__c ca = [select id, appointment_description__c,lab_time__c,padding_time__c,name from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	    //check to see if we need to resort the existing list;
  	  	Integer insert_sort_order = Integer.valueof(new_apt_sort);
  	  	List<Patient_Pot_Apt__c> resort_list = [select id,sort_order__c from Patient_pot_apt__c where isactive__c = true and patient_pot__c = :new_apt_form_id and sort_order__c >= :insert_sort_order];
  	  	if(resort_list.size()>0) {
  	  	  for(patient_pot_apt__c ppa : resort_list) {
  	  	  	ppa.sort_order__c = ppa.sort_order__c + 1;
  	  	  }
  	  	  update resort_list;
  	  	}
  	  	//create and insert record
  	    /*Patient_POT_Apt__c new_apt = new Patient_POT_Apt__c(Appointment_Description__c = ca.appointment_description__c,
  	  	  clinical_appointment__c = ca.id, days_out__c = 0, isactive__c = true, lab_time__c = ca.lab_time__c,
  	  	  padding_time__c = ca.padding_time__c, patient_pot__c = new_apt_form_id, sort_order__c = getpot_next_sort_value(), name = ca.name);*/
  	  	Patient_POT_Apt__c new_apt = new Patient_POT_Apt__c(Appointment_Description__c = ca.appointment_description__c,
  	  	  clinical_appointment__c = ca.id, days_out__c = 0, isactive__c = true, lab_time__c = ca.lab_time__c,
  	  	  padding_time__c = ca.padding_time__c, patient_pot__c = new_apt_form_id, sort_order__c = Integer.valueof(new_apt_sort), name = ca.name); 	
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
  	        allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c, target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c);
  	      new_procedure_list.add(new_procedure);
  	    }  	  
  	    insert new_procedure_list;  	    
  	    hide_apt_form();  	   
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the appointment. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public Integer getpot_min_sort_value() {
    //figure out min sort and go up to max
  	Patient_POT__c p = [Select p.Treatment_Description__c, p.SystemModstamp, p.Plan_of_Treatment__c, p.plan_of_treatment__r.name, p.OwnerId, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Account__c, p.doctor_notes__c,(Select Health_Condition__c, Request_Status__c, IsActive__c, Patient_POT__c From Medical_Clearances__r where isactive__c = true) From Patient_POT__c p where id = :new_apt_form_id order by createddate desc];
  	dp_clinical_pot.pot new_plan = new dp_clinical_pot.pot(p);
  	//grab out apts
  	Patient_POT_Apt__c last_apt;
  	for(Patient_POT_Apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, p.doctor_notes__c, (Select Id, Name, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c, allow_tooth_selection__c, target_teeth__c, clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c), 
  	  (Select Id, Apt_Date__c,apt_status__c,start_hour_int__c,start_minute_int__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc),(Select Id From Clinical_Apt_Histories__r) From Patient_POT_Apt__c p where isactive__c = true and patient_pot__c = :new_plan.plan.id order by sort_order__c]) {
  	  Boolean on_clipboard = false;
  	  dp_clinical_pot.pot_apt new_apt = new dp_clinical_pot.pot_apt(pa,last_apt,new_plan.getneeds_medical_clearance(),on_clipboard);
  	  new_plan.apts.add(new_apt);
  	  last_apt = pa;
  	}
  	//work through apts and look for first one that allows scheduling  	  	
  	Integer min_sort = getpot_next_sort_value();
  	for(dp_clinical_pot.pot_apt pa : new_plan.apts) {
  	  if(pa.getallow_scheduling()) {
  	    min_sort = pa.apt.sort_order__c.intvalue();
  	    break;
  	  }
  	}  	
  	return min_sort;
  }
  
  public void new_appointment_form() {
  	new_apt_form_id = apexpages.currentpage().getparameters().get('potid');
  	apt_filter = 'All';
  	new_apt_name = 'Enter Appointment';
  	new_apt_sort = String.valueof(getpot_min_sort_value());
  }
  
  public void hide_apt_form() {
  	new_apt_form_id = null;
  }
  
  public void reset_apt_form() {
  	new_apt_name = 'Enter Appointment';
  	apt_filter = 'All'; 
  	new_apt_sort = String.valueof(getpot_next_sort_value());
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
  
  public void select_appointment() {
  	new_apt_name = [select name from Clinical_Appointment__c where id = :apexpages.currentpage().getparameters().get('aptid')].name;
  	add_appointment_step();
  }
  
  public void open_apt_search_modal() {
  	display_apt_search_modal = true;
  	search_pager = new paged_results();
  	sched_apt = [Select p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, p.Clinical_Appointment__c, 
  	  p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c, p.clinical_appointment__r.name, p.clinical_appointment__r.lab_days_before__c
  	  From Patient_POT_Apt__c p
  	  where id = :apexpages.currentpage().getparameters().get('paptid')];
  	month_filter = 0;
  	doctor_filter = 'Any';
  	search_monday = false;
  	search_tuesday = false;
  	search_wednesday = false;
  	search_thursday = false;
  	search_friday = false; 
  	search_open = false;
  	search_morning = false;
  	search_noon = false;
  	search_afternoon = false;
  	search_close = false;
  }
  
  public void close_apt_search_modal() {
  	display_apt_search_modal = false;
  	sched_apt = null;
  }
  
  public void open_note_history_modal() {
  	display_note_history_modal = true;
  	apt_id = apexpages.currentpage().getparameters().get('nhid');
  	modal_out = '';
  }
  
  public void open_history_modal() {
  	display_history_modal = true;
  	apt_id = apexpages.currentpage().getparameters().get('aptid');
  	modal_out = '';
  }
  
  public void close_history_modal() {
  	display_history_modal = false;
  	display_note_history_modal = false;
  	apt_id = null;
  }
  
  public String getapt_history_name() {
  	return [select name from Patient_POT_Apt__c where id = :apt_id].name;
  }
  
  public List<Clinical_Apt_History__c> getapt_history_list() {
  	//to-do: adjust this to include all of the relevant fields when ready to finish this piece
  	return [select id,name,createddate,createdby.name,action__c,action_reason__c,notes__c from Clinical_Apt_History__c where Patient_POT_Apt__c = :apt_id order by createddate desc];
  }
  
  public List<Note_History__c> getnote_history_list() {
  	//to-do: adjust this to include all of the relevant fields when ready to finish this piece
  	return [select id,old_body__c,old_note_by__r.name,createdby.name,createddate from Note_History__c where notes_id__c = :apt_id order by createddate desc];
  }
  
  public class paged_results {
  	public Integer records_per_page {get;set;}
  	//public Integer current_page {get;set;}
  	public Boolean allow_next {get;set;}
  	public Boolean allow_prev {get;set;}
  	public Date[] previous_apt_dates {get;set;}
  	public Date paged_apt_start {get;set;} 
  	public Date starting_date {get;set;}
  	public Date ending_date {get;set;}
  	
  	public paged_results() {
  	  this.allow_next = false;
  	  this.allow_prev = false;
  	  this.records_per_page = 100;
  	  //this.current_page = 1;
  	  this.previous_apt_dates = new Date[] {};
  	}
  	
  	public String getsearch_results_header() {
  	  String search_head = '';
  	  if(starting_date!=null) {
  	  	search_head = 'Showing Results for ' + Datetime.newinstance(starting_date.year(),starting_date.month(),starting_date.day()).format('M/dd/yyyy') + ' to ' + Datetime.newinstance(ending_date.year(),ending_date.month(),ending_date.day()).format('M/dd/yyyy');
  	  }
  	  return search_head;
  	}
  	
  	public void next_page() {
      paged_apt_start = ending_date;
      previous_apt_dates.add(starting_date);
      allow_prev = true;
  	}
  	  	
  	public void prev_page() {
  	  Integer last_date = previous_apt_dates.size()-1; 
  	  paged_apt_start = previous_apt_dates.get(last_date);
  	  previous_apt_dates.remove(last_date);
  	  if(previous_apt_dates.size()>0)
  	    allow_prev = true;
  	  else
  	    allow_prev = false;
  	}
  }
  
  public void apt_search_next_page() {
  	search_pager.next_page();
  }
  
  public void apt_search_prev_page() {
  	search_pager.prev_page();
  }
  
  public search_date[] getapt_search_results() {
  	//calculate thresholds...yellow would be 75-85% of center number of lab techs * 555
  	Decimal green_top = (current_center.number_of_lab_techs__c * 555) * .75;
  	Decimal yellow_top = (current_center.number_of_lab_techs__c * 555) * .85;
  	
  	//since we can now schedule in different centers,  first we need to check and see if the apt we're using is the correct one
  	String clinical_apt_id;
  	if(sched_apt.clinical_appointment__r.center_information__c==current_center.id)
  	  clinical_apt_id = sched_apt.clinical_appointment__c;
  	else {
      try { 
      	System.debug('Translating apt for schedule center');
  	    clinical_apt_id = [select id from clinical_appointment__c where name = :sched_apt.clinical_appointment__r.name and center_information__c = :current_center.id limit 1].id;
      } catch (Exception e) {
      	
      }
  	}
  	if(clinical_apt_id==null)
  	  clinical_apt_id = sched_apt.clinical_appointment__c;
  	
  	/*Eligible Blocks - will need 2 queries here - first to identify blocks where apt has been specifically authorized
  	second query is to grab blocks that allow any apt....Queries can not be combined due to sub select combination with an or in the filter*/
  	//query 1 - apt authorized for block
  	Map<ID,CR_Schedule_Block__c> block_map = new Map<ID,CR_Schedule_block__c> ([Select id from CR_Schedule_Block__c where id in 
      (Select c.CR_Schedule_Block__c From CR_Sched_Block_Authorized_Apt__c c where clinical_appointment__c = :clinical_apt_id)]);      
    //Set<ID> block_ids = block_map.keySet();
    Set<ID> block_ids = new Set<ID>();
    block_ids.addAll(block_map.KeySet());
    
    //query 2 - blocks that allow anything
    block_map = new Map<ID,CR_Schedule_Block__c> ([select id from CR_Schedule_Block__c where allow_all__c = true and clinical_room__r.center_information__c = :current_center.id]);
    block_ids.addAll(block_map.keySet());
    
  	//Eligible Doctors  	
  	Set<ID> doctor_ids = new Set<ID>();
  	//to-do : do I need to worry about the active filter on doctor?
  	for(Clinical_DR_Authorized_Apt__c cd : [select doctor__c from Clinical_DR_Authorized_APT__c where clinical_appointment__c = :clinical_apt_id and doctor__r.isactive = true]) {
  	  if(doctor_filter=='Any')
  	    doctor_ids.add(cd.doctor__c);
  	  else if(doctor_filter==cd.doctor__c)
  	    doctor_ids.add(cd.doctor__c);
  	} 
  	
  	//Eligible Rooms
  	Map<ID,Clinical_Room__c> room_map = new Map<ID,Clinical_Room__C> ([select id,name from clinical_room__c where id in 
  	  (select clinical_room__c from Clinical_Room_Authorized_Apt__c where clinical_appointment__c = :clinical_apt_id)]);
  	Set<ID>room_ids = room_map.keySet();
  	
  	//for the search query,  we need to figure out the metrics for the clinical_appointment,  time before dr,  dr time,  and time after dr,  and days out from last apt in the sequence
  	Date earliest_apt_date;
  	Integer earliest_apt_time = 0;
  	if(sched_apt.sort_order__c==1)
  	  earliest_apt_date = System.today();
  	else {
  	  //we need to look at the apt date for the previous apt in the plan of treatment...then add days out to it to get our filter
  	  Integer prior_sort = sched_apt.sort_order__c.intValue() - 1;
  	  //modified by cm on 10/3/2017 - now looking for the first prior appointment that is NOT a repair
  	  //Patient_POT_Apt__c prior_apt = [select id, (Select Apt_Date__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c where sort_order__c = :prior_sort and patient_pot__c = :sched_apt.patient_pot__c and isactive__c = true];
  	  /*Patient_POT_Apt__c prior_apt = [select id, (Select Apt_Date__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) 
  	    from Patient_POT_Apt__c where sort_order__c <= :prior_sort and patient_pot__c = :sched_apt.patient_pot__c and isactive__c = true 
  	    and clinical_appointment__r.isrepair__c = false
  	    order by sort_order__c desc limit 1];*/ 
  	  Patient_POT_Apt__c prior_apt;
  	  try {
  	    prior_apt = [select id, (Select Apt_Date__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1)  from Patient_POT_Apt__c
  	      where sort_order__c <= :prior_sort and patient_pot__c = :sched_apt.patient_pot__c and isactive__c = true
  	      and clinical_appointment__r.isrepair__c = false order by sort_order__c desc limit 1];
  	  } catch (Exception e) {
  	    //this would occur,  if all of the prior apts happen to be repair (private practice / legacy import situation)
  	    prior_apt = [select id, (Select Apt_Date__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1)  from Patient_POT_Apt__c
  	      where sort_order__c <= :prior_sort and patient_pot__c = :sched_apt.patient_pot__c and isactive__c = true
  	      order by sort_order__c desc limit 1];
  	  }
  	  try {
  	    earliest_apt_date = prior_apt.clinical_apt_calendar__r[0].apt_date__c;
  	    earliest_apt_date = earliest_apt_date.addDays(sched_apt.days_out__c.intvalue());
  	    //earliest apt time will only be needed if the apt can be scheduled on the same day as the prior apt (a visit)
  	    if(sched_apt.days_out__c.intvalue()==0) {
  	      System.debug('Setting earliest apt time : ' + earliest_apt_time);
  	      earliest_apt_time = (prior_apt.clinical_apt_calendar__r[0].end_hour_int__c.intvalue() * 60) + prior_apt.clinical_apt_calendar__r[0].end_minute_int__c.intvalue();
  	    }
  	  } catch (Exception e) {
  	  	//if this is null,  it means we had no date for the previous apt in the chain....that's an issue - use today.
  	  	earliest_apt_date = System.today();  
  	  }
  	}
  	if(earliest_apt_date<System.today())
  	  earliest_apt_date = System.today();
  	System.debug('Earliest apt time : ' + earliest_apt_time);
  	
  	//figuring out time makeup
  	dp_clinical_calendar.apt_time_makeup apt_time = new dp_clinical_calendar.apt_time_makeup(sched_apt.id);
  	Integer time_before = apt_time.time_before;
  	Integer time_dr = apt_time.time_dr;
  	Integer time_after = apt_time.time_after;
  /*	String current_stage = 'before';
  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
      where isactive__c = true and patient_pot_apt__c = :sched_apt.id order by sort_order__c]) {
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
    System.debug('Time Before : ' + time_before);
    System.debug('Time Dr : ' + time_dr);
    System.debug('Time After : ' + time_after);
    Integer total_time = time_before + time_dr + time_after;
    System.debug('Total Time : ' + total_time);
    Integer total_before_dr =  time_before + time_dr;
    Integer total_after_dr = time_after + time_dr;     
    System.debug('Total Before + dr : ' + total_before_dr);
    System.debug('Total After + dr : ' + total_after_dr);*/
    Integer total_time = time_before + time_dr + time_after;
    Integer total_before_dr =  time_before + time_dr;
    Integer total_after_dr = time_after + time_dr;   
    
    
    Set<Integer> allowed_dow = new Set<Integer>();
    if(search_monday)
      allowed_dow.add(1);
    if(search_tuesday)
      allowed_dow.add(2);
    if(search_wednesday)
      allowed_dow.add(3);
    if(search_thursday)
      allowed_dow.add(4);
  	if(search_friday)
      allowed_dow.add(5);  	
      
    Set<Integer> month_set = new Set<Integer>();
    if(month_filter==0)
      month_set = new Set<Integer> {1,2,3,4,5,6,7,8,9,10,11,12};
    for(Integer mnum=1;mnum<=12;mnum++) {
      if(month_filter==mnum)
        month_set.add(mnum);
    }  	
  	
  	//Integer qlimit = 1000;
  	//Integer qlimit = (search_pager.current_page * search_pager.records_per_page + 10);
  	Integer qlimit = (search_pager.records_per_page + 10);
  	Date pager_date_start;
  	if(search_pager.paged_apt_start==null)
  	  pager_date_start = earliest_apt_date;
  	else
  	  pager_date_start = search_pager.paged_apt_start;
  	List<Clinical_Search_Inventory__c> possible_apts = [Select 
  	  c.Minutes_before_DR__c, 
  	  c.Minutes_after_DR__c, 
  	  c.Minutes_DR_Avail__c, 
  	  c.Clinical_Doctor_Inventory__c, 
  	  c.Clinical_Apt_Calendar__c,
  	  c.minutes_before_and_dr__c, 
  	  c.minutes_after_and_dr__c, 
  	  c.Total_Minutes__c,
  	  c.clinical_apt_calendar__r.stime__c,
  	  c.clinical_apt_calendar__r.etime__c,
  	  c.clinical_doctor_inventory__r.user__c,
  	  c.clinical_doctor_inventory__r.user__r.name,
  	  c.clinical_apt_calendar__r.clinical_room__r.name,
  	  clinical_apt_calendar__r.apt_date__c
  	From 
  	  Clinical_Search_Inventory__c c
  	where 
  	  c.clinical_apt_calendar__r.cr_schedule_block__c in :block_ids
  	  and c.clinical_doctor_inventory__r.user__c in :doctor_ids
  	  and c.clinical_doctor_inventory__r.center_information__c = :current_center.id
  	  and c.clinical_apt_calendar__r.clinical_room__c in :room_ids
  	  and c.clinical_apt_calendar__r.apt_date__c >= :earliest_apt_date 
  	  and c.clinical_apt_calendar__r.apt_date__c >= :pager_date_start
  	  and c.total_minutes__c  >= :total_time
  	  and c.minutes_before_and_dr__c >=  :total_before_dr
  	  and c.minutes_after_and_dr__c >= :total_after_dr
  	  and c.minutes_dr_avail__c >= :time_dr
  	  and c.clinical_apt_calendar__r.dow__c in :allowed_dow
  	  and c.clinical_apt_calendar__r.apt_month__c in :month_set
  	order by c.clinical_apt_calendar__r.apt_date__c, c.clinical_apt_calendar__r.stime__c
  	limit :qlimit];  	  
  	     	  
  	System.debug('Possible Options : ' + possible_apts.size());
  	  	
  	Map<Date,search_date> search_map = new Map<Date,search_date>(); 
  	search_pager.allow_next = false;
  	Integer loop_count = 0; 	  	
  	//work through possible options and identify every 10 minute possibility.  If possibility would meet hour selection criteria,  add an entry for it into the custom objects
  	for(Clinical_Search_Inventory__c csi : possible_apts) {  
  	  if(loop_count==0)
  	    search_pager.starting_date = csi.clinical_apt_calendar__r.apt_date__c;
  	  search_pager.ending_date = csi.clinical_apt_calendar__r.apt_date__c; 	    	    		
  	  //calculate the initial possible start time for the apt
  	  Integer initial_stime = csi.clinical_apt_calendar__r.stime__c.intvalue() + csi.minutes_before_dr__c.intvalue();
  	  System.debug('Initial Stime : ' + initial_stime);
  	  /*//if(block minutes before time > apt before - just subtract the apt before time to figure out the earliest possible slot)
  	  if(csi.minutes_before_dr__c>=time_before)
  	    initial_stime -= time_before;
  	  //apt before time is larger than the block...move the difference into the dr time  	  
  	  else
  	    initial_stime += (time_before - csi.minutes_before_dr__c.intvalue());*/
  	  //initial stime indicates where the doctor block starts...if apt before > block before then move into the dr range
  	  if(csi.minutes_before_dr__c < time_before)
  	    initial_stime += (time_before - csi.minutes_before_dr__c.intvalue());
  	  //actual block start time would be initial stime - time before
  	  Integer block_stime = initial_stime - time_before;
  	  System.debug('Block Start ' + block_stime);  	    	  
  	  System.debug('Doctor Time starts at : ' + initial_stime);
  	    	  
  	  //now figure out the max range possible for this apt to be fit in  	  
  	  Integer max_range = csi.minutes_dr_avail__c.intvalue() - time_dr;
  	  if(csi.minutes_before_dr__c < time_before)
  	   max_range -= (time_before - csi.minutes_before_dr__c.intvalue());
  	  System.debug('Initial Range : ' + max_range);
  	  //if the minutes after for the apt > block,  then subtract that from the range
  	  if(time_after > csi.minutes_after_dr__c)
  	    max_range += (csi.minutes_after_dr__c.intvalue() - time_after);
  	  System.debug('Adjusted Range : ' + max_range);
  	  
  	  //run a loop iterrating 10 minute spans for the extent of the range
  	  Integer current_interval = 0;
  	  while(current_interval <= max_range) {  	  
  	  	//does this apt meet the hour filter criteria?
  	  	Integer block_time = block_stime + current_interval;
  	  	//  earliest apt time check...if this apt date equals the earliest apt date,  then make sure the end time is >= earliest apt time,  otherwise we need to ignore it.
  	    if(csi.clinical_apt_calendar__r.apt_date__c==earliest_apt_date  && block_time < earliest_apt_time) {
  	      current_interval += 10;
  	      continue;
  	    }
  	  	
  	  	Boolean valid_block = false;
  	  	if(block_time <= 600 && search_open)
  	  	  valid_block = true;
  	  	if(block_time >= 600 && block_time <= 720 && search_morning)
  	  	  valid_block = true;
  	  	if(block_time >= 720 && block_time <= 840 && search_noon)
  	  	  valid_block = true;
  	  	if(block_time >= 840 && block_time <= 960 && search_afternoon)
  	  	  valid_block = true;
  	  	if(block_time >= 960 && block_time <= 840 && search_close)
  	  	  valid_block = true;
  	  	if(valid_block) {
  	  	  //do we have an entry for search date yet
  	  	  if(search_map.get(csi.clinical_apt_calendar__r.apt_date__c)==null) {
  	  	  	search_date search_result = new search_date(csi.clinical_apt_calendar__r.apt_date__c, sched_apt,current_center.id);
  	  	  	search_result.green_top = green_top;
  	  	  	search_result.yellow_top = yellow_top;
  	  	  	search_map.put(csi.clinical_apt_calendar__r.apt_date__c,search_result);
  	  	  }
  	  	  //add this block to the match list
  	  	  possible_match m = new possible_match(csi,block_time);
  	  	  search_map.get(csi.clinical_apt_calendar__r.apt_date__c).match_list.add(m);
  	  	}
  	  	current_interval += 10;
  	  }
  	  loop_count++;
  	  if(loop_count==search_pager.records_per_page) {
  	  	//we have more results on the next page
  	  	search_pager.allow_next = true;
  	  	break;
  	  }
  	}
  	//need to grab lab time for our search result dates
  	Set<Date> all_days = search_map.keyset();
  	for(AggregateResult ar : database.query('select apt_date__c,sum(patient_pot_apt__r.lab_time__c) lab_time from clinical_apt_calendar__c where apt_date__c in :all_days and clinical_room__r.center_information__c = \'' + current_center.id + '\' group by apt_date__c')) {
      if(search_map.get((Date)ar.get('apt_date__c'))!=null) {
      	if((decimal)ar.get('lab_time')!=null)
          search_map.get((Date)ar.get('apt_date__c')).current_lab_time = (decimal)ar.get('lab_time');
      }
  	}  	
  	//grab any calendar notes for matching days
  	for(Clinical_Calendar_note__c cnotes : [Select c.Note_Date__c, c.Center_Information__c, c.Calendar_Note__c From Clinical_Calendar_Note__c c where note_date__c in :all_days and center_information__c = :current_center.id]) {
  	  if(search_map.get(cnotes.note_date__c)!=null) {
  	  	search_map.get(cnotes.note_date__c).cal_notes.add(cnotes);
  	  }
  	}  	
  	return search_map.values();
  }
 
  public class search_date {
  	public Date apt_date {get; set;}
   	public Patient_POT_Apt__c apt {get; set;}
   	public possible_match[] match_list {get;set;}
   	public ID center_id {get; set;}
   	public Decimal current_lab_time {get; set;}
   	public Decimal green_top {get; set;}
   	public Decimal yellow_top {get; set;}
   	public List<Clinical_calendar_note__c> cal_notes {get;set;}
   	 
   	public search_date(Date odate,Patient_POT_Apt__c sapt,String cid) {
   	  this.apt_date = odate;
   	  this.apt = sapt;
   	  this.match_list = new possible_match[] {};
   	  this.center_id = cid;
   	  this.current_lab_time = 0;
   	  this.green_top = 240;
   	  this.yellow_top = 480;
   	  this.cal_notes = new List<Clinical_Calendar_Note__c>();
   	}
   	
   	public String getdisplay_date() {
   	  Datetime dtime = Datetime.newinstance(apt_date.year(),apt_date.month(),apt_date.day());
   	  return dtime.format('EEEE M/dd/yyyy');   	  
   	}
   	
   	public String getcurrent_lab_class() {
   	  String css_class = '';   	    
   	  if(current_lab_time <= green_top)
   	    css_class = 'ok';
   	  else if(current_lab_time <= yellow_top)
   	    css_class = 'med';
   	  else
   	    css_class = 'full';
   	  return css_class;
   	}
   	
   	public String getcurrent_lab_time_display() {
   	  Decimal lhours = math.floor(current_lab_time.intvalue()/60);
   	  Integer lminutes = math.mod(current_lab_time.intvalue(),60);
   	  return String.valueof(lhours.intvalue()) + ' hrs ' + lminutes + ' min';
   	}
   	
   	public String getlab_class() {
   	  String css_class = '';
   	  Decimal lab_time = 0; 
   	  lab_time = current_lab_time;   
   	  if(lab_time <= green_top)
   	    css_class = 'ok';
   	  else if(lab_time <= yellow_top)
   	    css_class = 'med';
   	  else
   	    css_class = 'full';
   	  return css_class;  
   	}
   	
   	public String getprojected_lab_class() {
   	  String css_class = '';
   	  Decimal lab_time = 0; 
   	  lab_time = current_lab_time + apt.lab_time__c;   
   	  if(lab_time <= green_top)
   	    css_class = 'ok';
   	  else if(lab_time <= yellow_top)
   	    css_class = 'med';
   	  else
   	    css_class = 'full';
   	  return css_class;  
   	}
   	 
   	public String getprojected_lab_time() {
   	  Decimal lab_time = 0;   	 
   	  lab_time = current_lab_time + apt.lab_time__c;
   	  Decimal lhours = math.floor(lab_time.intvalue()/60);
   	  Integer lminutes = math.mod(lab_time.intvalue(),60);
   	  return String.valueof(lhours.intvalue()) + ' hrs ' + lminutes + ' min';
   	}
  }
   
  public class possible_match {
    public Clinical_Search_Inventory__c si {get; set;}
    public Integer stime {get; set;}
   
    public possible_match(Clinical_Search_Inventory__c match, Integer start) {
      this.si = match;
      this.stime = start; 	
    } 
    
    public String getapt_label() {
      Decimal label_hour = (stime / 60);
      String suffix = 'AM';
      label_hour = math.floor(label_hour);
      if(label_hour==12)
        suffix = 'PM';
      else if(label_hour > 12) {
      	suffix = 'PM';
      	label_hour -= 12;
      }
      String lhour = String.valueof(label_hour);
      Decimal label_minutes = math.mod(stime,60);
      String lminutes = String.valueof(label_minutes);
      if(lminutes.length()==1)
        lminutes = '0' + lminutes; 
      return lhour + ':' + lminutes + ' ' + suffix + ' in ' + si.clinical_apt_calendar__r.clinical_room__r.name + '<br />' + si.clinical_doctor_inventory__r.user__r.name;
    }
       
  }
  
  public void search_all_apt_options() {
  	search_open = true;
  	search_morning = true;
  	search_afternoon = true;
  	search_noon = true;
  	search_close = true;
  	search_monday = true;
  	search_tuesday = true;
  	search_wednesday = true;
  	search_thursday = true;
  	search_friday = true;
  	month_filter = 0;
  	doctor_filter = 'Any';
  }
  
  public Integer gettime_minutes(Integer my_time) {
  	Integer my_minutes = math.mod(my_time,60);
  	return my_minutes;
  }
  
  public Integer gettime_hours(Integer my_time) {
  	Decimal my_hours = math.floor(my_time/60);
  	return my_hours.intValue();
  }
  
  public String gettodays_string() {
  	return System.now().format('M/dd/yyyy');
  }
  
  public void schedule_patient_apt() {
  	//to-do:  confirmation field,  confirmation email,  anything else we need to do on scheduling.
  	
  	//make sure the block we are trying to schedule in,  is still available...if it's got an apt in it,  throw an error message - try to lock record
  	Integer num_issues = 0;
  	modal_out = '';  	  	
  	try {
  	  Clinical_Apt_Calendar__c ca = [Select c.etime__c,c.stime__c,c.Start_Minute__c, c.Start_Hour__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Status__c, c.Apt_Date__c, c.Account__c,c.confirmation_status__c From Clinical_Apt_Calendar__c c where id = :apexpages.currentpage().getparameters().get('blockid')];
  	  if(ca.patient_pot_apt__c!=null) {
  	    //block was taken...we have an issue
  	    modal_out += 'The block you were trying to schedule in has been scheduled for another patient.<br />  Please select a different time';
  	    num_issues++;
  	  }
  	  //check to see if this apt has already been scheduled 
  	  System.debug('Sched Apt ID : ' + sched_apt.id);
  	  Integer sched_count = [select count() from Clinical_Apt_Calendar__c where Patient_pot_apt__c = :sched_apt.id and apt_status__c not in ('No Show')];
  	  if(sched_count>0) {
  	  	modal_out += 'This appointment has already been scheduled.<br />Please select a different appointment';
  	    num_issues++;
  	  }  	    	  
  	  Integer apt_stime = Integer.valueof(apexpages.currentpage().getparameters().get('stime'));
  	  //get the time makeup...we'll need it to adjust doctor inventory
  	  //figuring out time makeup
  	  Integer time_before = 0;
  	  Integer time_dr = 0;
  	  Integer time_after = 0;
  	  String current_stage = 'before';
  	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c = :sched_apt.id order by p.sort_order__c]) {
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
      Integer total_time = time_before + time_dr + time_after; 
      //verify the doctor time is also still available...if not we have a problem.
      Integer doctor_stime = apt_stime + time_before;
      Integer doctor_etime = doctor_stime + time_dr;
      Integer doctor_available = [select count() from Clinical_Doctor_Inventory__c c where user__c = :apexpages.currentpage().getparameters().get('doctorid') 
        and calendar_date__c = :ca.apt_date__c and
        stime__c <= :doctor_stime and etime__c >= :doctor_etime
        and center_information__c = :current_center.id];
      if(doctor_available==0) {
      	num_issues++;
      	modal_out += 'The doctor is no longer available for this apt.<br /> Please select a different time';
      }  	  
  	  if(num_issues==0) {
  	  	//time to schedule
  	  	//grab the calendar block and update it with patient,  apt,  and doctor info....also adjust the time fields to indicate the time where the apt will actually fall
  	    //if there is time left over before or after the apt shceduled,  build block as needed.
  	    //also make sure to enter an apt history record for this schedule event
  	    //list to hold new blocks if needed - will check size at the end
  	    List<Clinical_Apt_Calendar__c> new_blocks = new List<Clinical_Apt_Calendar__c> ();
  	    if(ca.stime__c<apt_stime) {
  	      //need to create a preceding block
  	      Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(apt_stime)), End_Hour__c = String.valueof(gettime_hours(apt_stime)), 
  	        DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      new_blocks.add(new_block);
  	      ca.start_minute__c = String.valueof(gettime_minutes(apt_stime));
  	      ca.start_hour__c = String.valueof(gettime_hours(apt_stime));
  	    }
  	      	    
  	    if(ca.etime__c > (apt_stime + total_time)) {
  	      //need to create a trailing block as we have some time left over
          Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(apt_stime + total_time)), Start_Hour__c =  String.valueof(gettime_hours(apt_stime + total_time)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	        DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      new_blocks.add(new_block);
  	      ca.end_minute__c = String.valueof(gettime_minutes(apt_stime + total_time));
  	      ca.end_hour__c = String.valueof(gettime_hours(apt_stime + total_time));  	      
  	    }
  	    ca.Patient_POT_Apt__c = sched_apt.id;
  	    //Patient_Pot_Apt__c pa = [Select p.Patient_POT__r.opportunity__c From Patient_POT_Apt__c p where id = :sched_apt.id]; 
  	    //ca.opportunity__c = pa.patient_pot__r.opportunity__c;
  	    ca.account__c = patient.id;
  	    ca.doctor__c = apexpages.currentpage().getparameters().get('doctorid');
  	    Clinical_Doctor_Inventory__c cdi; 
  	    List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	
  	    //check to see if this apt actually requires doctor time - if not we can skip this piece
  	    if(time_dr > 0) {
  	      //grab the doctor inventory - check if we have space before or after the scheduled apt (only worry about the doctor time) - create new blocks as needed
  	      cdi = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	        user__c = :apexpages.currentpage().getparameters().get('doctorid') and calendar_date__c = :ca.apt_date__c and stime__c <= :doctor_stime and etime__c >= :doctor_etime and center_information__c = :current_center.id];
  	      //check if we have doctor time left over before the block
  	      if(cdi.stime__c < doctor_stime) {
  	        Clinical_Doctor_Inventory__c new_doctor_block = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c, 
  	          End_Minute__c = String.valueof(gettime_minutes(doctor_stime)), End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	        new_doctor_blocks.add(new_doctor_block);
  	      }
  	      //check if we have doctor time left over after the block
  	      if(cdi.etime__c > doctor_etime) {
  	        Clinical_Doctor_Inventory__c new_doctor_block = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)), 
  	          End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	        new_doctor_blocks.add(new_doctor_block);
  	      }
  	    }
  	    
  	    //grabbing search inventory before any deletions occur - in order to prevent orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :ca.apt_date__c and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :ca.apt_date__c
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
  	    
  	    ca.confirmation_status__c = 'Not Confirmed';
  	    //commit changes - Blocks
        System.debug('Modified Apt Block : ' + ca);
        update ca;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        if(time_dr>0) {
          System.debug('Doctor Inventory Deleted : ' + cdi);
          delete cdi;
        }
        System.debug('Doctor Inventory Blocks Created : ' + new_doctor_blocks.size());
        if(new_doctor_blocks.size()>0) {
          System.debug('New Doctor Blocks : ' + new_doctor_blocks);
          insert new_doctor_blocks;     
        }
        //create a history entry
        //Time atime = ;
        Datetime adtime = Datetime.newinstance(ca.apt_date__c, Time.newinstance(gettime_hours(apt_stime),gettime_minutes(apt_stime),0,0));
        Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = sched_apt.id, Notes__c = 'Apt has been scheduled - ' + adtime.format('M/dd/yyyy h:mm a'), Clinical_Apt_Calendar__c = ca.id, 
          Action__c = 'Scheduled', Account__c = patient.id);
        System.debug('Apt History : ' + cah);
        insert cah; 
        
        //do we need to update/generate a lab case
        /*if(sched_apt.clinical_appointment__r.lab_days_before__c!=null) {
          common_lab_methods clm = new common_lab_methods(current_center.id);          
          clm.update_lab_case(ca.id,ca.apt_date__c,sched_apt.id,patient.id,sched_apt.clinical_appointment__r.lab_days_before__c.intvalue());
        }*/
  	
        //rebuild the search inventory for this day 
        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :ca.apt_date__c 
          and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :ca.apt_date__c and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //bad design - query on each loop iteration - fixing it
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :ca.apt_date__c and user__r.clinic_calendar__c = :current_center.name]) {
  	      for(Clinical_Doctor_Inventory__c cd : day_doc_inventory) {
  	        //see if there is an overlap 
  	        //if so - create a search block
  	        if((capt.stime__c >= cd.stime__c && capt.stime__c < cd.etime__c) || (capt.etime__c > cd.stime__c && capt.etime__c <= cd.etime__c)) {
  	          Integer minutes_before = 0;
  	          Integer minutes_dr = 0;
  	          Integer minutes_after = 0;
  	          //calculate minutes before dr is available
  	          if(capt.stime__c < cd.stime__c)
  	            minutes_before = cd.stime__c.intvalue() - capt.stime__c.intvalue();
  	          if(cd.etime__c > capt.etime__c) {
  	          	//see which value is higher - block or doctor start time
  	          	if(capt.stime__c > cd.stime__c)
  	          	  minutes_dr = (capt.etime__c.intvalue() - capt.stime__c.intvalue());
  	          	else
  	              minutes_dr = (capt.etime__c.intvalue() - cd.stime__c.intvalue());
  	          }
  	          else {
  	          	//see which value is higher - block or doctor start time
  	          	if(capt.stime__c > cd.stime__c)
  	          	  minutes_dr = (cd.etime__c.intvalue() - capt.stime__c.intvalue());
  	          	else
  	              minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	          } 
  	          //calculate minutes after dr available
  	          if(capt.etime__c > cd.etime__c)
  	            minutes_after = capt.etime__c.intvalue() - cd.etime__c.intvalue();
  	          //create our search block
  	          Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = capt.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	            minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	          csi_new.add(csi);
  	        }  	      
  	        //else - no need to do anything
  	      }
  	    }        
        
        //commit changes - CSI        
        System.debug('Consult Search Inventory - Deleted Size : ' + csi_old.size());
        delete csi_old;
        if(csi_new.size()>0) {
          System.debug('Consult Search Inventory - New Size : ' + csi_new.size());
          insert csi_new; 
        }                            	    
        
        //close modal
        close_apt_search_modal();     
  	  }
  	} catch (Exception e) {
  	  modal_out += 'Encountered an error while scheduling the apt<br />' + e + '<br />Contact IT for help<br />';
  	  modal_out += 'Line Number : <br />' + e.getLineNumber();
  	  ApexPages.addMessages(e);
   	}  	
  }  
  
  public Clinical_Apt_Calendar__c getapt_block(String apt_id) {
  	try {
      Clinical_Apt_Calendar__c my_apt = [Select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.account__r.personmobilephone, c.account__r.phone, account__r.email__c,
  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, 
  	    c.confirmation_status__c, c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, 
  	    account__r.recent_height_feet__c, account__r.recent_height_inches__c, account__r.recent_weight__c, patient_pot_apt__r.clinical_Appointment__r.clinical_Notes_Form__c, patient_pot_apt__r.clinical_appointment__r.lab_days_before__c,
  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c, (Select Id From Clinical_Apt_Histories__r),
  	    account__r.distance_to_center__c, arrival_time__c, ready_time__c, Apt_Start_Time__c, Apt_Complete_Time__c, patient_left_time__c, patient_pot_apt__r.patient_pot__c
  	  From Clinical_Apt_Calendar__c c
  	  where id = :apt_id];
      return my_apt;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the apt.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return null;
  	}          
  } 
  
  public void open_calendar_modal() {
  	display_calendar_modal = true;
  	apt_block = getapt_block(apexpages.currentpage().getparameters().get('aptid'));
  	calendar_modal_display = 'block_info';
  }
  
  public void close_calendar_modal() {
  	display_calendar_modal = false;
  	apt_block = null;
  	calendar_modal_display = null;
  }
  
  public Boolean getallow_arrived() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)=='' && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_ready() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)=='Patient Arrived' && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_started() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)=='Patient Ready' && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_completed() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)=='Appointment Started' && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_no_show() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)=='' && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_patient_left() {
  	Boolean rvalue = false;
  	String astatus = apt_block.apt_status__c==null?'':apt_block.apt_status__c;
  	Set<String> valid_status = new Set<String> {'Patient Arrived','Patient Ready','Appointment Started'};
  	if(valid_status.contains(astatus) && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_reset() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)!='' && apt_block.apt_date__c == System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public void make_history_entry(String action_text, String notes_text) {
    try {
      Clinical_Apt_History__c history = new Clinical_Apt_History__c(Account__c = apt_block.account__c, Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = notes_text, Clinical_Apt_Calendar__c = apt_block.id, Action__c = action_text);    
      insert history;
    } catch(Exception e) {
    	
    }
  }
  
  public String getcurrent_status() {
  	String apt_status = '';
  	if(apt_block.apt_status__c==null) {
  	  if(system.today()>apt_block.apt_date__c)
  	    apt_status = 'Unmarked No Show';
  	  else 
  	    apt_status = 'Upcoming';
  	}
  	else
  	  apt_status = apt_block.apt_status__c;  	 
  	return apt_status;
  }
  
  public String getapt_timestamps() {
  	String timestamp_info = '';
  	if(apt_block.arrival_time__c!=null)
  	  timestamp_info += '<div class="cc-modal-distance-row"><div class="cc-modal-patientInfo-label">Patient Arrived:</div>' + 
  	    '<div class="cc-modal-patientInfo-content">' + apt_block.arrival_time__c.format('h:mm a') + '</div></div>';
  	if(apt_block.ready_time__c!=null)
  	  timestamp_info += '<div class="cc-modal-distance-row"><div class="cc-modal-patientInfo-label">Patient Ready:</div>' + 
  	    '<div class="cc-modal-patientInfo-content">' + apt_block.ready_time__c.format('h:mm a') + '</div></div>';
  	if(apt_block.Apt_Start_Time__c!=null)
  	  timestamp_info += '<div class="cc-modal-distance-row"><div class="cc-modal-patientInfo-label">Appointment Started:</div>' + 
  	    '<div class="cc-modal-patientInfo-content">' + apt_block.apt_start_time__c.format('h:mm a') + '</div></div>';
  	if(apt_block.Apt_Complete_Time__c!=null)
  	  timestamp_info += '<div class="cc-modal-distance-row"><div class="cc-modal-patientInfo-label">Appointment Completed:</div>' + 
  	    '<div class="cc-modal-patientInfo-content">' + apt_block.apt_complete_time__c.format('h:mm a') + '</div></div>';
  	if(apt_block.Patient_Left_Time__c!=null)
  	  timestamp_info += '<div class="cc-modal-distance-row"><div class="cc-modal-patientInfo-label">Patient Left:</div>' + 
  	    '<div class="cc-modal-patientInfo-content">' + apt_block.patient_left_time__c.format('h:mm a') + '</div></div>';
  	return timestamp_info;
  }
  
  public void mark_apt_arrived() {
    apt_block = getapt_block(apt_block.id);
    String block_id = apt_block.id;
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_arrived()) {
      apt_block.Arrival_Time__c = System.now();
      apt_block.Apt_Status__c = 'Patient Arrived';
      Clinical_Note_Instance__c cn = new Clinical_note_Instance__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, IsActive__c = true, Clinical_Apt_Calendar__c = block_id, Account__c = apt_block.account__c);      
      try {
        update apt_block;
        make_history_entry('Patient Arrived','Consult status has been changed to Patient Arrived');        
        insert cn;
        //see if we need a special apt notes form
        System.debug('Clinical Notes Form : ' + apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c);
        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c!=null) {
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Surgical Notes Form')
            create_surgical_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Conversion Notes Form')
            create_conversion_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Interim Delivery Notes Form')
            create_interim_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Post Op Notes Form')
            create_post_op_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Jig Notes Form')
            create_jig_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Ty In Notes Form')
            create_try_in_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Final Notes Form')
            create_final_notes_instance(cn);
        }  
        close_calendar_modal();    
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }    
  }
  
  public void create_surgical_notes_instance(Clinical_Note_Instance__c cn) {
  	//grab the extraction field from the most recent surgical rx form tied to this POT
  	String eteeth = null;
  	try {
      Surgical_RX__c srx = [select id,extraction_teeth__c from Surgical_Rx__c where Patient_POT__c = :apt_block.patient_pot_apt__r.patient_pot__c order by createddate desc limit 1];
      //modified by cm on 2017-7-26 per request from Andy.  We no longer want all max/all mand to transfer to the surgical notes form.
      eteeth = srx.extraction_teeth__c;      
      Pattern all_max = Pattern.compile('All[^\\w]Max,');
      Pattern all_mand = Pattern.compile('All[^\\w]Mand,');
      Pattern all_max2 = Pattern.compile('All[^\\w]Max');
      Pattern all_mand2 = Pattern.compile('All[^\\w]Mand');
      eteeth = all_max.matcher(eteeth).replaceAll('');
      eteeth = all_max2.matcher(eteeth).replaceAll('');
      eteeth = all_mand.matcher(eteeth).replaceAll('');
      eteeth = all_mand2.matcher(eteeth).replaceAll('');            
  	} catch (Exception e) {
  	  //we don't have a surgical rx for this patient - go with the null value;
  	}  
    Surgical_Notes_Form__c sf = new Surgical_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, extractions__c = eteeth, 
        height_feet__c = apt_block.account__r.recent_height_feet__c, height_inches__c = apt_block.account__r.recent_height_inches__c,Clinical_Note_Instance__c = cn.id);
    insert sf;           
  }
  
  public void create_conversion_notes_instance(Clinical_Note_Instance__c cn) {
    Conversion_Notes_Form__c cnf = new Conversion_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert cnf;           
  }
  
  public void create_interim_notes_instance(Clinical_Note_Instance__c cn) {
    Interim_Delivery_Notes_Form__c idn = new Interim_Delivery_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert idn;           
  }
  
  public void create_post_op_notes_instance(Clinical_Note_Instance__c cn) {
    Post_OP_Notes_Form__c po = new Post_OP_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert po;           
  }
  
  public void create_try_in_notes_instance(Clinical_Note_Instance__c cn) {
    Try_In_Notes_Form__c ti = new Try_In_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert ti;           
  }
  
  public void create_jig_notes_instance(Clinical_Note_Instance__c cn) {  	
    JIG_Notes_Form__c jnotes = new JIG_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert jnotes;           
    //need to clone surgical implants from the most recent conversion apt for this patient
  	//grab last conversion_notes_form (make sure one exists first)
  	Integer ccount = [select count() from Conversion_Notes_Form__c where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :apt_block.patient_pot_apt__r.patient_pot__c];
  	if(ccount>0) {  	
  	  Conversion_Notes_Form__c cnf = [select id from Conversion_Notes_Form__c where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :apt_block.patient_pot_apt__r.patient_pot__c order by createddate desc limit 1];
  	  //pull surgical implants ties to this instance & clone for our new form
  	  List<Surgical_Note_Implant__c> implant_list = [select s.Unique_Placement__c, s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Ostel__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.JIG_Ostell_ISQ__c, s.JIG_Notes_Form__c, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Torque_Value__c, s.Implant_Torque_Number__c, s.Implant_System_Value__c, s.Implant_Length__c, s.Id, s.Healing_Cap_Placed__c, s.Final_Ostell_ISQ__c, s.Final_Notes_Form__c, s.CreatedDate, s.CreatedById, s.Conversion_Torque_Value__c, s.Conversion_Notes_Form__c, s.Closure_Screw_Placed__c, s.Buried_Implant__c, s.Bone_Density__c, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c 
  	  from Surgical_Note_Implant__c s
  	  where Conversion_Notes_Form__c = :cnf.id];
  	  List<Surgical_Note_Implant__c> new_implants = implant_list.deepclone();
  	  for(Surgical_note_implant__c sn : new_implants) {
  	   	sn.conversion_notes_form__c = null;
  	   	sn.jig_notes_form__c = jnotes.id;
  	  }
  	  insert new_implants;
  	}
  }
  
  public void create_final_notes_instance(Clinical_Note_Instance__c cn) {  	
    Final_Notes_Form__c fnotes = new Final_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert fnotes;           
    //need to clone surgical implants from the most recent jig apt for this patient
  	//grab last jig_notes_form (make sure one exists first)
  	Integer ccount = [select count() from JIG_Notes_Form__c where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :apt_block.patient_pot_apt__r.patient_pot__c];
  	if(ccount>0) {  	
  	  Jig_Notes_Form__c jnf = [select id from JIG_Notes_Form__c where clinical_note_instance__r.patient_pot_apt__r.patient_pot__c = :apt_block.patient_pot_apt__r.patient_pot__c order by createddate desc limit 1];
  	  //pull surgical implants ties to this instance & clone for our new form
  	  List<Surgical_Note_Implant__c> implant_list = [select s.Unique_Placement__c, s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Ostel__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.JIG_Ostell_ISQ__c, s.JIG_Notes_Form__c, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Torque_Value__c, s.Implant_Torque_Number__c, s.Implant_System_Value__c, s.Implant_Length__c, s.Id, s.Healing_Cap_Placed__c, s.Final_Ostell_ISQ__c, s.Final_Notes_Form__c, s.CreatedDate, s.CreatedById, s.Conversion_Torque_Value__c, s.Conversion_Notes_Form__c, s.Closure_Screw_Placed__c, s.Buried_Implant__c, s.Bone_Density__c, s.Abutment_Straight__c,  s.abutment_width__c, s.Abutment_Collar_Height__c 
  	  from Surgical_Note_Implant__c s
  	  where Jig_Notes_Form__c = :jnf.id];
  	  List<Surgical_Note_Implant__c> new_implants = implant_list.deepclone();
  	  for(Surgical_note_implant__c sn : new_implants) {
  	   	sn.jig_notes_form__c = null;
  	   	sn.final_notes_form__c = fnotes.id;
  	  }
  	  insert new_implants;
  	}
  }
  
  public void mark_apt_ready() {
    apt_block = getapt_block(apt_block.id);
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_ready()) {
      apt_block.Ready_Time__c = System.now();
      apt_block.Apt_Status__c = 'Patient Ready';
      try {
        update apt_block;
        make_history_entry('Patient Ready','Consult status has been changed to Patient Ready');
        close_calendar_modal();            
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }
  }
  
  public void mark_apt_started() {
    apt_block = getapt_block(apt_block.id);
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_started()) {
      apt_block.Apt_Start_Time__c = System.now();
      apt_block.Apt_Status__c = 'Appointment Started';
      try {
        update apt_block;
        make_history_entry('Appointment Started','Consult status has been changed to Appointment Started');
        close_calendar_modal();            
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }
  }
  
  public void mark_apt_completed() {
    apt_block = getapt_block(apt_block.id);
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_completed()) {
      apt_block.Apt_Complete_Time__c = System.now();
      apt_block.Apt_Status__c = 'Completed';
      try {
        update apt_block;
        make_history_entry('Completed','Consult status has been changed to Completed');
        close_calendar_modal();            
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }
  }
  
  public void mark_apt_left() {
    apt_block = getapt_block(apt_block.id);
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_patient_left()) {
      apt_block.Patient_Left_Time__c = System.now();
      apt_block.Apt_Status__c = 'Patient Left';
      try {
        update apt_block;
        make_history_entry('Patient Left','Consult status has been changed to Patient Left');
        close_calendar_modal();            
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }
  }
  
  public void mark_apt_reset() {
    apt_block = getapt_block(apt_block.id);
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_reset()) {
      apt_block.Arrival_Time__c = null;
      apt_block.Ready_Time__c = null;
      apt_block.Apt_Start_Time__c = null;
      apt_block.Apt_Complete_Time__c = null;
      apt_block.Patient_Left_Time__c = null;      
      apt_block.Apt_Status__c = null;
      try {
        update apt_block;
        make_history_entry('Reset','CA or Admin has reset this apt block');
        close_calendar_modal();            
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }
  }
  
  public void mark_apt_no_show() {
    apt_block = getapt_block(apt_block.id);
    //double check and verify that someone else hasn't hit the button already or moved them further up the stream
    if(getallow_no_show()) {     
      apt_block.Apt_Status__c = 'No Show';
      try {
        update apt_block;
        make_history_entry('No Show','Consult status has been changed to No Show');
        close_calendar_modal();            
      } catch (System.DmlException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }          
    }
  }
  
  public String getblock_formatted_date() {
  	Datetime adate = Datetime.newinstance(apt_block.apt_date__c.year(),apt_block.apt_date__c.month(),apt_block.apt_date__c.day());
  	return adate.format('M/dd/yyyy');
  }
  
  public String dec_to_time(Decimal time_val) {
  	Decimal lhours = math.floor(time_val.intvalue()/60);
  	String suffix = 'AM';
  	if(lhours==12)
  	  suffix = 'PM';
  	else if(lhours>12) {
  	  lhours = lhours - 12;
  	  suffix = 'PM';
  	}
   	Integer lminutes = math.mod(time_val.intvalue(),60);
   	String dminutes = String.valueof(lminutes);
   	if(dminutes.length()==1)
   	  dminutes = '0' + dminutes;
   	return String.valueof(lhours.intvalue()) + ':' + dminutes + ' ' + suffix;
  }
  
  public String getblock_apt_time() {
    String apt_time = '';
  	apt_time = dec_to_time(apt_block.stime__c) + ' - ' + dec_to_time(apt_block.etime__c);  	   
  	return apt_time;
  }  
  
  public Boolean getallow_apt_change() {
  	//make sure it's not in the past,  and that the status is null
  	if(apt_block.apt_status__c==null && apt_block.apt_date__c>=System.today())
  	  return true;
  	else if(test.isRunningTest())
  	  return true;
  	else
  	  return false;
  }
  
  public List<Selectoption> getdoctor_search_list() {
  	//modified by cm on 8/14/2017 - using user center assignments now
  	Set<ID> possible_users = new Set<ID>();
  	for(User_Center_Assignment__c uca : [select id,user__c,center_information__c from User_Center_Assignment__c where center_information__r.market__c = :current_center.market__c]) {
  	  possible_users.add(uca.user__c);	
  	}  	
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('Any','Any Doctor'));
  	for(User u : [select u.id,u.name from User u 
  	  //where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name]) {  		
  	  where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.id in:possible_users]) {
  	  clist.add(new Selectoption(u.id,u.name));
  	} 
	return clist;
  } 
  
  public List<Selectoption> getcancel_reason_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('NA','Select One'));
  	for(Schema.PicklistEntry Value : Clinical_Apt_History__c.cancel_reason__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  } 
  
  public List<Selectoption> getreschedule_reason_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('NA','Select One'));
  	for(Schema.PicklistEntry Value : Clinical_Apt_History__c.reschedule_reason__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  } 
  
  public void reschedule_reason_view() {
  	calendar_modal_display = 'reschedule_reason_view';
  	cancel_reason = 'NA';
  }
  
  public void cancel_reason_view() {
  	calendar_modal_display = 'cancel_reason_view';
  	cancel_reason = 'NA';
  }
  
  public void modal_go_back() {
  	calendar_modal_display = 'block_info';
  }
  
  public Pagereference quick_manual_sched() {
  	Pagereference pr;
  	try {
  	  //cancel the apt
  	  apt_block = getapt_block(apt_block.id);
  	  String ppa = apt_block.patient_pot_apt__c;
  	  cancel_scheduled_apt();
  	  //return a pagereference to manual sched
  	  pr = Page.ccare_clinical_calendar;
  	  pr.getParameters().put('ctrid',current_center.id);
  	  pr.getParameters().put('ptid',patient.id);
  	  pr.getParameters().put('maptid',ppa);     
  	  pr.setredirect(true);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to manual resched this appointment'));
      ApexPages.addMessages(e);   
  	}
  	return pr;
  }  
  
  public void cancel_scheduled_apt() {
  	Integer num_issues = 0;
  	//check cancel reason first and make sure it's not NA
  	if(cancel_reason=='NA') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid cancellation reason'));
  	}
  	//check block and make sure it still exists
  	try { //wrapping in a try,  in case the block is gone - that's a fail
  	  apt_block = getapt_block(apt_block.id);  	  
  	  if(apt_block.account__c!=null && getallow_apt_change()) {
  	    //we're okay
  	  } else {
  	    num_issues++;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This block is no longer eligible for cancellation'));
  	  }
  	} catch (Exception e) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This block is no longer eligible for cancellation'));
  	  ApexPages.addMessages(e);    
  	}  	  
  	try {  	  
  	//otherwise proceed with cancellation
  	if(num_issues==0) {  	
  	  //to reduce the number of potential DML operations here,  I'm always adding the exitsing apt block to the delete list and a new version of it to the new list 
  	  //this removes the need for a potential update call down the way.
  	  List<Clinical_Apt_Calendar__c> delete_block_list  = new List<Clinical_Apt_Calendar__c> {apt_block};
  	  List<Clinical_Apt_Calendar__c> new_room_blocks = new List<Clinical_Apt_Calendar__c> {new Clinical_Apt_Calendar__c(apt_date__c = apt_block.apt_date__c, Clinical_Room__c = apt_block.clinical_room__c, 
  	  	CR_Schedule_Block__c = apt_block.cr_schedule_block__c, DOW__c = apt_block.dow__c, end_hour__c = apt_block.end_hour__c, end_minute__c = apt_block.end_minute__c, start_hour__c = apt_block.start_hour__c,  
  	  	start_minute__c = apt_block.start_minute__c) };
  	  //System.debug('Initial New Blocks : ' + new_room_blocks);
  	  //System.debug('Remove Blocks : ' + delete_block_list);
  	  String CR_block_id = apt_block.cr_schedule_block__c;
  	  Double block_dow = apt_block.dow__c;
  	  String room_id = apt_block.clinical_room__c;
  	  Date apt_date = apt_block.apt_date__c;
  	  Integer apt_stime = apt_block.stime__c.intvalue();
  	  String apt_doctor = apt_block.doctor__c;
      
      //check to see if this apt overlaps with a room block - if there is an intersection,  we need to remove that time (possibly the entire block)
      for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Clinical_Room__c, 
        c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c 
        From Clinical_Time_Restriction__c c
        where c.clinical_room__c = :apt_block.clinical_room__c and c.block_date__c = :apt_block.apt_date__c]) {
        //work through each room block we have and see if there is an intersection
        List<Clinical_Apt_Calendar__c> revised_room_blocks = new List<Clinical_Apt_Calendar__c>();
        for(Clinical_Apt_Calendar__c ca : new_room_blocks) {        
          //calculate stime and etime here - they are technically populated on the initial apt block,  but won't be populated if we split the block on a previous pass
          Integer ca_stime = (Integer.valueof(ca.start_hour__c) * 60) + Integer.valueof(ca.start_minute__c);
          Integer ca_etime = (Integer.valueof(ca.end_hour__c) * 60) + Integer.valueof(ca.start_minute__c);	
        	
          //check for a block that contains this apt
          if(ctr.stime__c <= ca_stime && ctr.etime__c >= ca_etime) {
          	//modified by cm on 4/3/2017 - this block has no id,  so we can't delete it.  Just need to not add it to the revised room block list for it to go away
          	//this block can not be recreated - add to delete_block_list
          	//delete_block_list.add(ca);
          }  	  
  	      //check for block that has a start time between our apt times
  	      else if(ctr.stime__c >= ca_stime && ctr.stime__c < ca_etime) {
  	      	//do we need a preceeding block
  	      	if(ca_stime < ctr.stime__c) {
  	      	  //create a block using the start = start of ca block and end = start of ctr block
  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
  	  	        end_hour__c = ctr.start_hour__c, end_minute__c = ctr.start_minute__c, start_hour__c = ca.start_hour__c,  start_minute__c = ca.start_minute__c);  	  	      	
  	          revised_room_blocks.add(nca);	  	      	  
  	      	}  	      	
  	      	//do we have a trailing block
  	      	if(ca_etime > ctr.etime__c) {
  	        //create a block using the start = end of ctr block and end = end of ca block
  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
  	  	        end_hour__c = ca.end_hour__c, end_minute__c = ca.end_minute__c, start_hour__c = ctr.end_hour__c,  start_minute__c = ctr.end_minute__c);  	  	      	
  	          revised_room_blocks.add(nca);	
  	      	}
  	      }   	  
  	      //check for a block that has an end time between our apt times
  	      else if (ctr.etime__c > ca_stime && ctr.etime__c <= ca_etime) {
  	      	//check for a preceeding block - this should never actually hit,  as it would of followed the earlier if path
  	      	if(ca_stime < ctr.stime__c) {
  	      	  //create a block using the start = start of ca block and end = start of ctr block
  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
  	  	        end_hour__c = ctr.start_hour__c, end_minute__c = ctr.start_minute__c, start_hour__c = ca.start_hour__c,  start_minute__c = ca.start_minute__c);  	  	      	
  	          revised_room_blocks.add(nca);	  	      	  
  	      	}  	      	
  	      	//do we have a trailing block
  	      	if(ca_etime > ctr.etime__c) {
  	        //create a block using the start = end of ctr block and end = end of ca block
  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
  	  	        end_hour__c = ca.end_hour__c, end_minute__c = ca.end_minute__c, start_hour__c = ctr.end_hour__c,  start_minute__c = ctr.end_minute__c);  	  	      	
  	          revised_room_blocks.add(nca);	
  	      	}
  	      } else
  	        //the time block does not interset with our apt - return it to the list
  	        revised_room_blocks.add(ca);
        }
        //reset our list for the next comparison
        new_room_blocks = revised_room_blocks;    
      }  	
      //System.debug('Post Block New Blocks : ' + new_room_blocks);
  	  //System.debug('Remove Blocks : ' + delete_block_list);  
  	   
      //see if we're still creating any blocks - otherwise this is moot
      if(new_room_blocks.size()>0) {
      
        //work through revised list of new blocks and test for intersection - when detected
  	    List<Clinical_Apt_calendar__c> existing_room_inventory = [Select c.Stime__c, c.Start_Minute_Int__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.DOW__c, 
  	      c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Status__c, c.Apt_Date__c, c.start_minute__c, c.start_hour__c
  	      From Clinical_Apt_Calendar__c c
  	      where cr_schedule_block__c = :CR_block_id and apt_date__c = :apt_date and clinical_room__c = :room_id
  	      and patient_pot_apt__c = null order by stime__c];
  	    System.debug('Merge Check : ' + existing_room_inventory.size());
  	      
  	    
  	    //loop through our new blocks
  	    for(Clinical_Apt_Calendar__c ca : new_room_blocks) {  	        	    	           
  	      //loop through our existing room inventory
  	      //calculate stime and etime,  in case the block was a prior split
  	      Integer ca_stime = (Integer.valueof(ca.start_hour__c) * 60) + Integer.valueof(ca.start_minute__c);
          Integer ca_etime = (Integer.valueof(ca.end_hour__c) * 60) + Integer.valueof(ca.end_minute__c);         
  	      
  	  	  List<Clinical_Apt_Calendar__c> revised_existing = new List<Clinical_Apt_Calendar__c>();
          for(Clinical_Apt_Calendar__c eapt : existing_room_inventory) {
          	System.debug('CA Stime : ' + ca_stime + ' CA Etime : ' + ca_etime);
          	System.debug('EApt Stime : ' + eapt.stime__c + ' EApt Etime : ' + eapt.etime__c);
  	        //does the new block start time match the existing block end time and do they share a block id
  	  	  	if(ca_stime == eapt.etime__c && ca.cr_schedule_block__c==eapt.cr_schedule_block__c) {  	  	  	  
  	  	  	  //extend the new block - add the existing block to the remove list
  	  	  	  ca.start_minute__c = eapt.start_minute__c;
  	  	  	  ca.start_hour__c = eapt.start_hour__c;
  	  	  	  ca_stime = (Integer.valueof(eapt.start_hour__c) * 60) + Integer.valueof(eapt.start_minute__c); 
  	  	  	  delete_block_list.add(eapt);
  	  	  	} else if(ca_etime == eapt.stime__c && ca.cr_schedule_block__c==eapt.cr_schedule_block__c) {  	  	  	
  	  	  	  //does the new block end time match the existing block start time and do they shard a block id
  	  	  	  ca.end_minute__c = eapt.end_minute__c;
  	  	  	  ca.end_hour__c = eapt.end_hour__c;
  	  	  	  ca_etime = (Integer.valueof(eapt.end_hour__c) * 60) + Integer.valueof(eapt.end_minute__c);
  	  	  	  delete_block_list.add(eapt);
  	  	  	} else   	  	  	  	  	    	  	 
  	  	  	  //otherwise add it back to the list
  	  	  	  revised_existing.add(eapt);
  	  	  }
  	  	  //reset existing
  	  	  existing_room_inventory = revised_existing;  	    	      
        }                       
      }  	 
      //System.debug('Post Merge Check New Blocks : ' + new_room_blocks);
  	  //System.debug('Remove Blocks : ' + delete_block_list);
  	    	    	   	  
  	  //create history entry
  	  Clinical_Apt_history__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = 'Apt was cancelled', Cancel_Reason__c = cancel_reason, Action__c = 'Cancel', Account__c = apt_block.account__c);
/*  	  if(apt_block.patient_pot_apt__r.clinical_appointment__r.lab_days_before__c!=null) {
  	  	common_lab_methods clm = new common_lab_methods(current_center.id);
  	    clm.reset_lab_case(apt_block.patient_pot_apt__c);        	  	 
  	  }*/ 
  	    	  	  
  	  //first figure out if this block required doctor time
  	  //figuring out time makeup
  	  Integer time_before = 0;
  	  Integer time_dr = 0;
  	  Integer time_after = 0;
  	  String current_stage = 'before';
  	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c = :apt_block.patient_pot_apt__c order by p.sort_order__c]) {
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
      
      List<Clinical_Doctor_Inventory__c> delete_doctor_block_list  = new List<Clinical_Doctor_Inventory__c>();      
      List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();     
      
      if(time_dr>0) {      	
        //start time = apt_block stime + time_before
        //end time = apt_block_stime + time_before + time_dr
        Integer dr_stime = apt_stime + time_before;
        Integer dr_etime = dr_stime + time_dr;                
        //build our doctor inventory block for future tests        
        new_doctor_blocks.add( new Clinical_Doctor_Inventory__c(User__c = apt_doctor, Start_Minute__c = String.valueof(gettime_minutes(dr_stime)), 
          Start_Hour__c = String.valueof(gettime_hours(dr_stime)), End_Minute__c = String.valueof(gettime_minutes(dr_etime)), End_Hour__c = String.valueof(gettime_hours(dr_etime)), 
          DOW__c = block_dow, Calendar_Date__c = apt_date, center_information__c = current_center.id));
          
        //check for an intersection with existing doctor blocks
        //check to see if this time overlaps with a doctor block - if there is an intersection,  we need to remove that time (possibly the entire block)
        for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Clinical_Room__c, 
          c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c 
          From Clinical_Time_Restriction__c c
          where c.user__c = :apt_doctor and c.center_information__c = :current_center.id and c.block_date__c = :apt_date]) {
          //work through each room block we have and see if there is an intersection
          List<Clinical_Doctor_Inventory__c> revised_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
          for(Clinical_Doctor_Inventory__c cdi : new_doctor_blocks) {        
            //calculate stime and etime here
            Integer cdi_stime = (Integer.valueof(cdi.start_hour__c) * 60) + Integer.valueof(cdi.start_minute__c);
            Integer cdi_etime = (Integer.valueof(cdi.end_hour__c) * 60) + Integer.valueof(cdi.start_minute__c);	
        	
            //check for a block that contains this apt
            if(ctr.stime__c <= cdi_stime && ctr.etime__c >= cdi_etime) {
          	  //this block can not be recreated - don't add it back to the revised list and it'll go quietly into the good night          	  
            }  	  
  	        //check for block that has a start time between our apt times
  	        else if(ctr.stime__c >= cdi_stime && ctr.stime__c < cdi_etime) {
  	      	  //do we need a preceeding block
  	      	  if(cdi_stime < ctr.stime__c) {
  	      	    //create a block using the start = start of cdi block and end = start of ctr block
  	      	    Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	              End_Minute__c = ctr.start_minute__c, End_Hour__c = ctr.start_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);		  	      	  
  	      	  }  	      	
  	      	  //do we have a trailing block
  	      	  if(cdi_etime > ctr.etime__c) {
  	            //create a block using the start = end of ctr block and end = end of ca block
  	            Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = ctr.end_minute__c, Start_Hour__c = ctr.end_hour__c,
  	              End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);		  	      	  
  	      	  }
  	        }   	  
  	        //check for a block that has an end time between our apt times
  	        else if (ctr.etime__c > cdi_stime && ctr.etime__c <= cdi_etime) {
  	      	  //check for a preceeding block - this should never actually hit,  as it would of followed the earlier if path
  	      	  if(cdi_stime < ctr.stime__c) {
  	      	    //create a block using the start = start of cdi block and end = start of ctr block
  	      	    Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	              End_Minute__c = ctr.start_minute__c, End_Hour__c = ctr.start_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);	  	      	  
  	      	  }  	      	
  	      	  //do we have a trailing block
  	      	  if(cdi_etime > ctr.etime__c) {
  	            //create a block using the start = end of ctr block and end = end of ca block
  	            Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = ctr.end_minute__c, Start_Hour__c = ctr.end_hour__c,
  	              End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);	
  	      	  }
  	        } else
  	          //the time block does not interset with our apt - return it to the list
  	          revised_doctor_blocks.add(cdi);
          }
          //reset our list for the next comparison
          new_doctor_blocks = revised_doctor_blocks;    
        }
      }
      
      //do we still have a doctor block?
      if(new_doctor_blocks.size()>0) {                
        //pull a list of our existing doctor inventory for this day
  	  	List<Clinical_Doctor_Inventory__c> existing_doctor_inventory = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Etime__c, 
  	  	  c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c 
  	  	  From Clinical_Doctor_Inventory__c c where user__c = :apt_doctor and calendar_date__c = :apt_date and center_information__c = :current_center.id order by stime__c];
  	  	
  	  	//loop through our new block
  	  	for(Clinical_Doctor_Inventory__c ndi : new_doctor_blocks) {
  	  	  Integer ndi_stime = (Integer.valueof(ndi.start_hour__c) * 60) + Integer.valueof(ndi.start_minute__c); 
  	  	  Integer ndi_etime = (Integer.valueof(ndi.end_hour__c) * 60) + Integer.valueof(ndi.end_minute__c);
  	  	  
  	  	  //loop through our existing doctor inventory
  	  	  List<Clinical_Doctor_Inventory__c> revised_existing = new List<Clinical_Doctor_Inventory__c>();
  	  	  for(Clinical_Doctor_Inventory__c cdi : existing_doctor_inventory) {
  	  	  	//does the new block start time match the existing block end time
  	  	  	if(ndi_stime==cdi.etime__c) {
  	  	  	  //extend the new block - add the existing block to the remove list
  	  	  	  ndi.start_minute__c = cdi.start_minute__c;
  	  	  	  ndi.start_hour__c = cdi.start_hour__c;
  	  	  	  ndi_stime = (Integer.valueof(ndi.start_hour__c) * 60) + Integer.valueof(ndi.start_minute__c); 
  	  	  	  delete_doctor_block_list.add(cdi);
  	  	  	} else if(ndi_etime == cdi.stime__c) {  	  	  	
  	  	  	  //does the new block end time match the existing block start time
  	  	  	  ndi.end_minute__c = cdi.end_minute__c;
  	  	  	  ndi.end_hour__c = cdi.end_hour__c;
  	  	  	  ndi_etime = (Integer.valueof(ndi.end_hour__c) * 60) + Integer.valueof(ndi.end_minute__c);
  	  	  	  delete_doctor_block_list.add(cdi);
  	  	  	} else   	  	  	  	  	    	  	 
  	  	  	  //otherwise add it back to the list
  	  	  	  revised_existing.add(cdi);
  	  	  }
  	  	  //reset existing
  	  	  existing_doctor_inventory = revised_existing;
  	  	}                               	      	      	  	    	    
      }
  	  
  	  //need to store this for use in search inventory rebuild
  	  Date search_date = apt_date;
  	  
  	  //grabbing old search inventory prior to deletes,  in order to prevent orphan records
  	  List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :search_date and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :search_date
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];  	
  	    	   	   
  	  //create blocks and rebuild search inventory....or do nothing
  	  Boolean rebuild_search_inventory = false;
  	  if(new_room_blocks.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	insert new_room_blocks;
  	  	//System.debug('Inserting ' + new_room_blocks.size() + ' new room inventory blocks');
  	  	//System.debug(new_doctor_blocks);
  	  }
  	  if(delete_block_list.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	delete delete_block_list;
  	  	//System.debug('Removing ' + remove_room_blocks.size() + ' existing room blocks that were extended');
  	  	//System.debug(remove_doctor_blocks);
  	  }
  	  if(new_doctor_blocks.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	insert new_doctor_blocks;
  	  	//System.debug('Inserting ' + new_room_blocks.size() + ' new room inventory blocks');
  	  	//System.debug(new_doctor_blocks);
  	  }
  	  if(delete_doctor_block_list.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	delete delete_doctor_block_list;
  	  	//System.debug('Removing ' + remove_room_blocks.size() + ' existing room blocks that were extended');
  	  	//System.debug(remove_doctor_blocks);
  	  }
  	  
  	  //insert history
  	  insert cah;
  	    
  	  if(rebuild_search_inventory) {
  	  	System.debug('Should rebuild search inventory');
     
  	    //rebuild the search inventory for this day 
        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :search_date and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :search_date and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //bad design - query on each loop iteration - fixing it
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :search_date and user__r.clinic_calendar__c = :current_center.name]) {
  	      for(Clinical_Doctor_Inventory__c cd : day_doc_inventory) {
  	        //see if there is an overlap 
  	        //if so - create a search block
  	        if((capt.stime__c >= cd.stime__c && capt.stime__c < cd.etime__c) || (capt.etime__c > cd.stime__c && capt.etime__c <= cd.etime__c)) {
  	          Integer minutes_before = 0;
  	          Integer minutes_dr = 0;
  	          Integer minutes_after = 0;
  	          //calculate minutes before dr is available
  	          if(capt.stime__c < cd.stime__c)
  	            minutes_before = cd.stime__c.intvalue() - capt.stime__c.intvalue();
  	          if(cd.etime__c > capt.etime__c) {
  	          	//see which value is higher - block or doctor start time
  	          	if(capt.stime__c > cd.stime__c)
  	          	  minutes_dr = (capt.etime__c.intvalue() - capt.stime__c.intvalue());
  	          	else
  	              minutes_dr = (capt.etime__c.intvalue() - cd.stime__c.intvalue());
  	          }
  	          else {
  	          	//see which value is higher - block or doctor start time
  	          	if(capt.stime__c > cd.stime__c)
  	          	  minutes_dr = (cd.etime__c.intvalue() - capt.stime__c.intvalue());
  	          	else
  	              minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	          } 
  	          //calculate minutes after dr available
  	          if(capt.etime__c > cd.etime__c)
  	            minutes_after = capt.etime__c.intvalue() - cd.etime__c.intvalue();
  	          //create our search block
  	          Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = capt.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	            minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	          csi_new.add(csi);
  	        }  	      
  	        //else - no need to do anything
  	      }
  	    }        
        
        //commit changes - CSI        
        System.debug('Consult Search Inventory - Deleted Size : ' + csi_old.size());
        delete csi_old;
        if(csi_new.size()>0) {
          System.debug('Consult Search Inventory - New Size : ' + csi_new.size());
          insert csi_new; 
        }
  	  }
        
      close_calendar_modal();
  	  }
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to cancel.  Please contact IT for help ' + e.getLineNumber()));
        ApexPages.addMessages(e);                  
  	  }  	

  }  
  
  public void reschedule_search_view() {
  	//make sure we have a valid reason before continuing
  	if(cancel_reason=='NA') 
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid reschedule reason'));
  	else {
  	  sched_apt = [Select p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, p.Clinical_Appointment__c, 
  	    p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c, p.clinical_appointment__r.name, p.clinical_appointment__r.lab_days_before__c 
  	    From Patient_POT_Apt__c p
  	    where id = :apt_block.patient_pot_apt__c];
  	  calendar_modal_display = 'reschedule_search_view';
  	  search_pager = new paged_results();
  	  month_filter = 0;
  	  doctor_filter = 'Any';
  	  search_monday = false;
  	  search_tuesday = false;
  	  search_wednesday = false;
  	  search_thursday = false;
  	  search_friday = false; 
  	  search_open = false;
  	  search_morning = false;
  	  search_noon = false;
  	  search_afternoon = false;
  	  search_close = false;
  	}  	
  }
  
  public void reschedule_patient_apt() {
  	//list to store new history entries 
  	List<Clinical_Apt_History__c> new_history_list = new List<Clinical_Apt_History__c> ();	
  	//Set of search dates - going this route as I could run into issues previously if the apt is rescheduled to the same day.  That resulted in me trying to delete/create the same set of blocks
  	Set<Date> search_dates = new Set<Date>();
  	List<Clinical_Search_Inventory__c> csi_old = new List<Clinical_Search_Inventory__c>();
  	List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
  	  	
  	//run checks to make sure the reschedule can still happen
  	Integer num_issues=0;
  	//check block and make sure it still exists
  	try { //wrapping in a try,  in case the block is already deleted - that's a fail.
  	  apt_block = getapt_block(apt_block.id);
  	  if(apt_block.account__c!=null && getallow_apt_change()) {
  	    //we're okay
  	  } else {
  	    num_issues++;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This block is no longer eligible for cancellation'));
  	  }
  	} catch (Exception e) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This block is no longer eligible for cancellation'));
  	  ApexPages.addMessages(e);    
  	}  	
  	try {
  	  Clinical_Apt_Calendar__c ca = [Select c.etime__c,c.stime__c,c.Start_Minute__c, c.Start_Hour__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Status__c, c.Apt_Date__c, c.Account__c,c.confirmation_status__c From Clinical_Apt_Calendar__c c where id = :apexpages.currentpage().getparameters().get('blockid')];
  	  System.debug('Block ID : ' + apexpages.currentpage().getparameters().get('blockid'));
  	  if(ca.patient_pot_apt__c!=null) {
  	    //block was taken...we have an issue
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The block you were trying to schedule in has been scheduled for another patient.'));
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a different time.'));
  	    num_issues++;
  	  }
  	  Integer apt_stime = Integer.valueof(apexpages.currentpage().getparameters().get('stime'));
  	  //get the time makeup...we'll need it to adjust doctor inventory
  	  //figuring out time makeup
  	  Integer time_before = 0;
  	  Integer time_dr = 0;
  	  Integer time_after = 0;
  	  String current_stage = 'before';
  	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c = :sched_apt.id order by p.sort_order__c]) {
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
      Integer total_time = time_before + time_dr + time_after; 
      //verify the doctor time is also still available...if not we have a problem.
      Integer doctor_stime = apt_stime + time_before;
      Integer doctor_etime = doctor_stime + time_dr;
      Integer doctor_available = [select count() from Clinical_Doctor_Inventory__c c where user__c = :apexpages.currentpage().getparameters().get('doctorid') 
        and calendar_date__c = :ca.apt_date__c 
        and stime__c <= :doctor_stime and etime__c >= :doctor_etime
        and center_information__c = :current_center.id];
      if(doctor_available==0) {
      	num_issues++;
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The doctor is no longer available for this apt.<br /> Please select a different time'));
      }  	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to verify reschedule availability.  Please contact IT for help ' + e.getLineNumber()));
      ApexPages.addMessages(e);      	
  	}
  	
  	if(num_issues==0) {
  	  //--START CANCEL ORIGIONAL APT----------//  	  
  	  try {
	  	//to reduce the number of potential DML operations here,  I'm always adding the exitsing apt block to the delete list and a new version of it to the new list 
	  	  //this removes the need for a potential update call down the way.
	  	  List<Clinical_Apt_Calendar__c> delete_block_list  = new List<Clinical_Apt_Calendar__c> {apt_block};
	  	  List<Clinical_Apt_Calendar__c> new_room_blocks = new List<Clinical_Apt_Calendar__c> {new Clinical_Apt_Calendar__c(apt_date__c = apt_block.apt_date__c, Clinical_Room__c = apt_block.clinical_room__c, 
	  	  	CR_Schedule_Block__c = apt_block.cr_schedule_block__c, DOW__c = apt_block.dow__c, end_hour__c = apt_block.end_hour__c, end_minute__c = apt_block.end_minute__c, start_hour__c = apt_block.start_hour__c,  
	  	  	start_minute__c = apt_block.start_minute__c) };
	  	  //System.debug('Initial New Blocks : ' + new_room_blocks);
	  	  //System.debug('Remove Blocks : ' + delete_block_list);
	  	  String CR_block_id = apt_block.cr_schedule_block__c;
	  	  Double block_dow = apt_block.dow__c;
	  	  String room_id = apt_block.clinical_room__c;
	  	  Date apt_date = apt_block.apt_date__c;
	  	  Integer apt_stime = apt_block.stime__c.intvalue();
	  	  String apt_doctor = apt_block.doctor__c;
	      
	      //check to see if this apt overlaps with a room block - if there is an intersection,  we need to remove that time (possibly the entire block)
	      for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Clinical_Room__c, 
	        c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c 
	        From Clinical_Time_Restriction__c c
	        where c.clinical_room__c = :apt_block.clinical_room__c and c.block_date__c = :apt_block.apt_date__c]) {
	        //work through each room block we have and see if there is an intersection
	        List<Clinical_Apt_Calendar__c> revised_room_blocks = new List<Clinical_Apt_Calendar__c>();
	        for(Clinical_Apt_Calendar__c ca : new_room_blocks) {        
	          //calculate stime and etime here - they are technically populated on the initial apt block,  but won't be populated if we split the block on a previous pass
	          Integer ca_stime = (Integer.valueof(ca.start_hour__c) * 60) + Integer.valueof(ca.start_minute__c);
	          Integer ca_etime = (Integer.valueof(ca.end_hour__c) * 60) + Integer.valueof(ca.start_minute__c);	
	        	
	          //check for a block that contains this apt
	          if(ctr.stime__c <= ca_stime && ctr.etime__c >= ca_etime) {
	          	//modified by cm on 4/3/2017 - this block has no id,  so we can't delete it.  Just need to not add it to the revised room block list for it to go away
	          	//this block can not be recreated - add to delete_block_list
	          	//delete_block_list.add(ca);
	          }  	  
	  	      //check for block that has a start time between our apt times
	  	      else if(ctr.stime__c >= ca_stime && ctr.stime__c < ca_etime) {
	  	      	//do we need a preceeding block
	  	      	if(ca_stime < ctr.stime__c) {
	  	      	  //create a block using the start = start of ca block and end = start of ctr block
	  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
	  	  	        end_hour__c = ctr.start_hour__c, end_minute__c = ctr.start_minute__c, start_hour__c = ca.start_hour__c,  start_minute__c = ca.start_minute__c);  	  	      	
	  	          revised_room_blocks.add(nca);	  	      	  
	  	      	}  	      	
	  	      	//do we have a trailing block
	  	      	if(ca_etime > ctr.etime__c) {
	  	        //create a block using the start = end of ctr block and end = end of ca block
	  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
	  	  	        end_hour__c = ca.end_hour__c, end_minute__c = ca.end_minute__c, start_hour__c = ctr.end_hour__c,  start_minute__c = ctr.end_minute__c);  	  	      	
	  	          revised_room_blocks.add(nca);	
	  	      	}
	  	      }   	  
	  	      //check for a block that has an end time between our apt times
	  	      else if (ctr.etime__c > ca_stime && ctr.etime__c <= ca_etime) {
	  	      	//check for a preceeding block - this should never actually hit,  as it would of followed the earlier if path
	  	      	if(ca_stime < ctr.stime__c) {
	  	      	  //create a block using the start = start of ca block and end = start of ctr block
	  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
	  	  	        end_hour__c = ctr.start_hour__c, end_minute__c = ctr.start_minute__c, start_hour__c = ca.start_hour__c,  start_minute__c = ca.start_minute__c);  	  	      	
	  	          revised_room_blocks.add(nca);	  	      	  
	  	      	}  	      	
	  	      	//do we have a trailing block
	  	      	if(ca_etime > ctr.etime__c) {
	  	        //create a block using the start = end of ctr block and end = end of ca block
	  	      	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = ca.apt_date__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, DOW__c = ca.dow__c, 
	  	  	        end_hour__c = ca.end_hour__c, end_minute__c = ca.end_minute__c, start_hour__c = ctr.end_hour__c,  start_minute__c = ctr.end_minute__c);  	  	      	
	  	          revised_room_blocks.add(nca);	
	  	      	}
	  	      } else
	  	        //the time block does not interset with our apt - return it to the list
	  	        revised_room_blocks.add(ca);
	        }
	        //reset our list for the next comparison
	        new_room_blocks = revised_room_blocks;    
	      }  	
	      //System.debug('Post Block New Blocks : ' + new_room_blocks);
	  	  //System.debug('Remove Blocks : ' + delete_block_list);  
	  	   
	      //see if we're still creating any blocks - otherwise this is moot
	      if(new_room_blocks.size()>0) {
	      
	        //work through revised list of new blocks and test for intersection - when detected
	  	    List<Clinical_Apt_calendar__c> existing_room_inventory = [Select c.Stime__c, c.Start_Minute_Int__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.DOW__c, 
	  	      c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Status__c, c.Apt_Date__c, c.start_minute__c, c.start_hour__c
	  	      From Clinical_Apt_Calendar__c c
	  	      where cr_schedule_block__c = :CR_block_id and apt_date__c = :apt_date and clinical_room__c = :room_id
	  	      and patient_pot_apt__c = null order by stime__c];
	  	    System.debug('Merge Check : ' + existing_room_inventory.size());
	  	      
	  	    
	  	    //loop through our new blocks
	  	    for(Clinical_Apt_Calendar__c ca : new_room_blocks) {  	        	    	           
	  	      //loop through our existing room inventory
	  	      //calculate stime and etime,  in case the block was a prior split
	  	      Integer ca_stime = (Integer.valueof(ca.start_hour__c) * 60) + Integer.valueof(ca.start_minute__c);
	          Integer ca_etime = (Integer.valueof(ca.end_hour__c) * 60) + Integer.valueof(ca.end_minute__c);         
	  	      
	  	  	  List<Clinical_Apt_Calendar__c> revised_existing = new List<Clinical_Apt_Calendar__c>();
	          for(Clinical_Apt_Calendar__c eapt : existing_room_inventory) {
	          	System.debug('CA Stime : ' + ca_stime + ' CA Etime : ' + ca_etime);
	          	System.debug('EApt Stime : ' + eapt.stime__c + ' EApt Etime : ' + eapt.etime__c);
	  	        //does the new block start time match the existing block end time and do they share a block id
	  	  	  	if(ca_stime == eapt.etime__c && ca.cr_schedule_block__c==eapt.cr_schedule_block__c) {  	  	  	  
	  	  	  	  //extend the new block - add the existing block to the remove list
	  	  	  	  ca.start_minute__c = eapt.start_minute__c;
	  	  	  	  ca.start_hour__c = eapt.start_hour__c;
	  	  	  	  ca_stime = (Integer.valueof(eapt.start_hour__c) * 60) + Integer.valueof(eapt.start_minute__c); 
	  	  	  	  delete_block_list.add(eapt);
	  	  	  	} else if(ca_etime == eapt.stime__c && ca.cr_schedule_block__c==eapt.cr_schedule_block__c) {  	  	  	
	  	  	  	  //does the new block end time match the existing block start time and do they shard a block id
	  	  	  	  ca.end_minute__c = eapt.end_minute__c;
	  	  	  	  ca.end_hour__c = eapt.end_hour__c;
	  	  	  	  ca_etime = (Integer.valueof(eapt.end_hour__c) * 60) + Integer.valueof(eapt.end_minute__c);
	  	  	  	  delete_block_list.add(eapt);
	  	  	  	} else   	  	  	  	  	    	  	 
	  	  	  	  //otherwise add it back to the list
	  	  	  	  revised_existing.add(eapt);
	  	  	  }
	  	  	  //reset existing
	  	  	  existing_room_inventory = revised_existing;  	    	      
	        }                       
	      }  	 
	      //System.debug('Post Merge Check New Blocks : ' + new_room_blocks);
	  	  //System.debug('Remove Blocks : ' + delete_block_list);
	  	    	    	   	  
	  	  //create history entry
	  	  Clinical_Apt_history__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = 'Apt was cancelled', Cancel_Reason__c = cancel_reason, Action__c = 'Cancel', Account__c = apt_block.account__c);        	  	  
	  	    	  	  
	  	  //first figure out if this block required doctor time
	  	  //figuring out time makeup
	  	  Integer time_before = 0;
	  	  Integer time_dr = 0;
	  	  Integer time_after = 0;
	  	  String current_stage = 'before';
	  	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
	        clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
	        where isactive__c = true and patient_pot_apt__c = :apt_block.patient_pot_apt__c order by p.sort_order__c]) {
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
	      
	      List<Clinical_Doctor_Inventory__c> delete_doctor_block_list  = new List<Clinical_Doctor_Inventory__c>();      
	      List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();           
	      
	      if(time_dr>0) {      	
	        //start time = apt_block stime + time_before
	        //end time = apt_block_stime + time_before + time_dr
	        Integer dr_stime = apt_stime + time_before;
	        Integer dr_etime = dr_stime + time_dr;                
	        //build our doctor inventory block for future tests        
	        new_doctor_blocks.add( new Clinical_Doctor_Inventory__c(User__c = apt_doctor, Start_Minute__c = String.valueof(gettime_minutes(dr_stime)), 
	          Start_Hour__c = String.valueof(gettime_hours(dr_stime)), End_Minute__c = String.valueof(gettime_minutes(dr_etime)), End_Hour__c = String.valueof(gettime_hours(dr_etime)), 
	          DOW__c = block_dow, Calendar_Date__c = apt_date, center_information__c = current_center.id));
	          
	        //check for an intersection with existing doctor blocks
	        //check to see if this time overlaps with a doctor block - if there is an intersection,  we need to remove that time (possibly the entire block)
	        for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Clinical_Room__c, 
	          c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c 
	          From Clinical_Time_Restriction__c c
	          where c.user__c = :apt_doctor and c.center_information__c = :current_center.id and c.block_date__c = :apt_date]) {
	          //work through each room block we have and see if there is an intersection
	          List<Clinical_Doctor_Inventory__c> revised_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
	          for(Clinical_Doctor_Inventory__c cdi : new_doctor_blocks) {        
	            //calculate stime and etime here
	            Integer cdi_stime = (Integer.valueof(cdi.start_hour__c) * 60) + Integer.valueof(cdi.start_minute__c);
	            Integer cdi_etime = (Integer.valueof(cdi.end_hour__c) * 60) + Integer.valueof(cdi.start_minute__c);	
	        	
	            //check for a block that contains this apt
	            if(ctr.stime__c <= cdi_stime && ctr.etime__c >= cdi_etime) {
	          	  //this block can not be recreated - don't add it back to the revised list and it'll go quietly into the good night          	  
	            }  	  
	  	        //check for block that has a start time between our apt times
	  	        else if(ctr.stime__c >= cdi_stime && ctr.stime__c < cdi_etime) {
	  	      	  //do we need a preceeding block
	  	      	  if(cdi_stime < ctr.stime__c) {
	  	      	    //create a block using the start = start of cdi block and end = start of ctr block
	  	      	    Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
	  	              End_Minute__c = ctr.start_minute__c, End_Hour__c = ctr.start_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
	  	            revised_doctor_blocks.add(ndi);		  	      	  
	  	      	  }  	      	
	  	      	  //do we have a trailing block
	  	      	  if(cdi_etime > ctr.etime__c) {
	  	            //create a block using the start = end of ctr block and end = end of ca block
	  	            Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = ctr.end_minute__c, Start_Hour__c = ctr.end_hour__c,
	  	              End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
	  	            revised_doctor_blocks.add(ndi);		  	      	  
	  	      	  }
	  	        }   	  
	  	        //check for a block that has an end time between our apt times
	  	        else if (ctr.etime__c > cdi_stime && ctr.etime__c <= cdi_etime) {
	  	      	  //check for a preceeding block - this should never actually hit,  as it would of followed the earlier if path
	  	      	  if(cdi_stime < ctr.stime__c) {
	  	      	    //create a block using the start = start of cdi block and end = start of ctr block
	  	      	    Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
	  	              End_Minute__c = ctr.start_minute__c, End_Hour__c = ctr.start_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
	  	            revised_doctor_blocks.add(ndi);	  	      	  
	  	      	  }  	      	
	  	      	  //do we have a trailing block
	  	      	  if(cdi_etime > ctr.etime__c) {
	  	            //create a block using the start = end of ctr block and end = end of ca block
	  	            Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = ctr.end_minute__c, Start_Hour__c = ctr.end_hour__c,
	  	              End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
	  	            revised_doctor_blocks.add(ndi);	
	  	      	  }
	  	        } else
	  	          //the time block does not interset with our apt - return it to the list
	  	          revised_doctor_blocks.add(cdi);
	          }
	          //reset our list for the next comparison
	          new_doctor_blocks = revised_doctor_blocks;    
	        }
	      }
	      
	      //do we still have a doctor block?
	      if(new_doctor_blocks.size()>0) {                
	        //pull a list of our existing doctor inventory for this day
	  	  	List<Clinical_Doctor_Inventory__c> existing_doctor_inventory = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Etime__c, 
	  	  	  c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c 
	  	  	  From Clinical_Doctor_Inventory__c c where user__c = :apt_doctor and calendar_date__c = :apt_date 
	  	  	  and center_information__c = :current_center.id order by stime__c];
	  	  	
	  	  	//loop through our new block
	  	  	for(Clinical_Doctor_Inventory__c ndi : new_doctor_blocks) {
	  	  	  Integer ndi_stime = (Integer.valueof(ndi.start_hour__c) * 60) + Integer.valueof(ndi.start_minute__c); 
	  	  	  Integer ndi_etime = (Integer.valueof(ndi.end_hour__c) * 60) + Integer.valueof(ndi.end_minute__c);
	  	  	  
	  	  	  //loop through our existing doctor inventory
	  	  	  List<Clinical_Doctor_Inventory__c> revised_existing = new List<Clinical_Doctor_Inventory__c>();
	  	  	  for(Clinical_Doctor_Inventory__c cdi : existing_doctor_inventory) {
	  	  	  	//does the new block start time match the existing block end time
	  	  	  	if(ndi_stime==cdi.etime__c) {
	  	  	  	  //extend the new block - add the existing block to the remove list
	  	  	  	  ndi.start_minute__c = cdi.start_minute__c;
	  	  	  	  ndi.start_hour__c = cdi.start_hour__c;
	  	  	  	  ndi_stime = (Integer.valueof(ndi.start_hour__c) * 60) + Integer.valueof(ndi.start_minute__c); 
	  	  	  	  delete_doctor_block_list.add(cdi);
	  	  	  	} else if(ndi_etime == cdi.stime__c) {  	  	  	
	  	  	  	  //does the new block end time match the existing block start time
	  	  	  	  ndi.end_minute__c = cdi.end_minute__c;
	  	  	  	  ndi.end_hour__c = cdi.end_hour__c;
	  	  	  	  ndi_etime = (Integer.valueof(ndi.end_hour__c) * 60) + Integer.valueof(ndi.end_minute__c);
	  	  	  	  delete_doctor_block_list.add(cdi);
	  	  	  	} else   	  	  	  	  	    	  	 
	  	  	  	  //otherwise add it back to the list
	  	  	  	  revised_existing.add(cdi);
	  	  	  }
	  	  	  //reset existing
	  	  	  existing_doctor_inventory = revised_existing;
	  	  	}                               	      	      	  	    	    
	      }
	  	  
	  	  //need to store this for use in search inventory rebuild
	  	  Date search_date = apt_date;  	
	  	    	   	   
	  	  //create blocks and rebuild search inventory....or do nothing
	  	  Boolean rebuild_search_inventory = false;
	  	  if(new_room_blocks.size()>0) {
	  	  	rebuild_search_inventory = true;
	  	  	insert new_room_blocks;
	  	  	//System.debug('Inserting ' + new_room_blocks.size() + ' new room inventory blocks');
	  	  	//System.debug(new_doctor_blocks);
	  	  }
	  	  if(delete_block_list.size()>0) {
	  	  	rebuild_search_inventory = true;
	  	  	delete delete_block_list;
	  	  	//System.debug('Removing ' + remove_room_blocks.size() + ' existing room blocks that were extended');
	  	  	//System.debug(remove_doctor_blocks);
	  	  }
	  	  if(new_doctor_blocks.size()>0) {
	  	  	rebuild_search_inventory = true;
	  	  	insert new_doctor_blocks;
	  	  	//System.debug('Inserting ' + new_room_blocks.size() + ' new room inventory blocks');
	  	  	//System.debug(new_doctor_blocks);
	  	  }
	  	  if(delete_doctor_block_list.size()>0) {
	  	  	rebuild_search_inventory = true;
	  	  	delete delete_doctor_block_list;
	  	  	//System.debug('Removing ' + remove_room_blocks.size() + ' existing room blocks that were extended');
	  	  	//System.debug(remove_doctor_blocks);
	  	  }

  	    //rebuild the search inventory for this day - pulled
  	    //pulled search inventory rebuild from this section - it'll be handled below and work through all dates in the set of search_dates
  	    if(rebuild_search_inventory) 
          search_dates.add(search_date);  
                               
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to cancel the initial appointment.  Please contact IT for help ' + e.getLineNumber()));
        ApexPages.addMessages(e);   
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Rescheduling Error');
        message.setHtmlbody('An error occured during rescheduling - cancel origional apt.<br />' + e);
  	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','amcmullen@clearchoice.com','jreish@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });               
  	  }  	
  	  
  	  //schedule new apt 
  	  try {
  	    Clinical_Apt_Calendar__c ca = [Select c.etime__c,c.stime__c,c.Start_Minute__c, c.Start_Hour__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Status__c, c.Apt_Date__c, c.Account__c,c.confirmation_status__c From Clinical_Apt_Calendar__c c where id = :apexpages.currentpage().getparameters().get('blockid')];
  	    Integer apt_stime = Integer.valueof(apexpages.currentpage().getparameters().get('stime'));
  	    //get the time makeup...we'll need it to adjust doctor inventory
  	    //figuring out time makeup
  	    Integer time_before = 0;
  	    Integer time_dr = 0;
  	    Integer time_after = 0;
  	    String current_stage = 'before';
  	    for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
          clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
          where isactive__c = true and patient_pot_apt__c = :sched_apt.id order by p.sort_order__c]) {
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
        Integer total_time = time_before + time_dr + time_after; 
        //verify the doctor time is also still available...if not we have a problem.
        Integer doctor_stime = apt_stime + time_before;
        Integer doctor_etime = doctor_stime + time_dr;
        Integer doctor_available = [select count() from Clinical_Doctor_Inventory__c c where user__c = :apexpages.currentpage().getparameters().get('doctorid') 
          and calendar_date__c = :ca.apt_date__c 
          and stime__c <= :doctor_stime and etime__c >= :doctor_etime
          and center_information__c = :current_center.id];
  	    //time to schedule
  	  	//grab the calendar block and update it with patient,  apt,  and doctor info....also adjust the time fields to indicate the time where the apt will actually fall
  	    //if there is time left over before or after the apt shceduled,  build block as needed.
  	    //also make sure to enter an apt history record for this schedule event
  	    //list to hold new blocks if needed - will check size at the end
  	    List<Clinical_Apt_Calendar__c> new_blocks = new List<Clinical_Apt_Calendar__c> ();
  	    if(ca.stime__c<apt_stime) {
  	      //need to create a preceding block
  	      Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(apt_stime)), End_Hour__c = String.valueof(gettime_hours(apt_stime)), 
  	        DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      new_blocks.add(new_block);
  	      ca.start_minute__c = String.valueof(gettime_minutes(apt_stime));
  	      ca.start_hour__c = String.valueof(gettime_hours(apt_stime));
  	    }
  	      	    
  	    if(ca.etime__c > (apt_stime + total_time)) {
  	      //need to create a trailing block as we have some time left over
          Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(apt_stime + total_time)), Start_Hour__c =  String.valueof(gettime_hours(apt_stime + total_time)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	        DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      new_blocks.add(new_block);
  	      ca.end_minute__c = String.valueof(gettime_minutes(apt_stime + total_time));
  	      ca.end_hour__c = String.valueof(gettime_hours(apt_stime + total_time));  	      
  	    }
  	    ca.Patient_POT_Apt__c = sched_apt.id;
  	    //Patient_Pot_Apt__c pa = [Select p.Patient_POT__r.opportunity__c,p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :sched_apt.id]; 
  	    //ca.opportunity__c = pa.patient_pot__r.opportunity__c;
  	    Patient_Pot_Apt__c pa = [Select p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :sched_apt.id];
  	    ca.account__c = pa.patient_pot__r.account__c;
  	    ca.doctor__c = apexpages.currentpage().getparameters().get('doctorid');
  	    
  	    Clinical_Doctor_Inventory__c cdi; 
  	    List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	
  	    //check to see if this apt requires dr time - if not skip it
  	    if(time_dr>0) {
  	      //grab the doctor inventory - check if we have space before or after the scheduled apt (only worry about the doctor time) - create new blocks as needed
  	      cdi = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	        user__c = :apexpages.currentpage().getparameters().get('doctorid') and calendar_date__c = :ca.apt_date__c and stime__c <= :doctor_stime and etime__c >= :doctor_etime];
  	      //check if we have doctor time left over before the block
  	      if(cdi.stime__c < doctor_stime) {
  	        Clinical_Doctor_Inventory__c new_doctor_block = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c, 
  	          End_Minute__c = String.valueof(gettime_minutes(doctor_stime)), End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	        new_doctor_blocks.add(new_doctor_block);
  	      }
  	      //check if we have doctor time left over after the block
  	      if(cdi.etime__c > doctor_etime) {
  	        Clinical_Doctor_Inventory__c new_doctor_block = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)), 
  	          End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	        new_doctor_blocks.add(new_doctor_block);
  	      }
  	    }
  	    
  	    ca.confirmation_status__c = 'Not Confirmed';
  	    //commit changes - Blocks
        System.debug('Modified Apt Block : ' + ca);
        update ca;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        if(time_dr>0) {
          System.debug('Doctor Inventory Deleted : ' + cdi);
          delete cdi;
        }
        System.debug('Doctor Inventory Blocks Created : ' + new_doctor_blocks.size());
        if(new_doctor_blocks.size()>0) {
          System.debug('New Doctor Blocks : ' + new_doctor_blocks);
          insert new_doctor_blocks;     
        }
        //create a history entry
        Datetime adtime = Datetime.newinstance(ca.apt_date__c, Time.newinstance(gettime_hours(apt_stime),gettime_minutes(apt_stime),0,0));
        Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = sched_apt.id, Notes__c = 'Apt has been scheduled - ' + adtime.format('M/dd/yyyy h:mm a'), Clinical_Apt_Calendar__c = ca.id, 
          Action__c = 'Scheduled', Account__c = pa.patient_pot__r.account__c);
        new_history_list.add(cah);
        insert new_history_list; 
        
        //do we need to update/generate a lab case
        /*if(sched_apt.clinical_appointment__r.lab_days_before__c!=null) {
          common_lab_methods clm = new common_lab_methods(current_center.id);
          clm.update_lab_case(ca.id,ca.apt_date__c,sched_apt.id,pa.patient_pot__r.account__c,sched_apt.clinical_appointment__r.lab_days_before__c.intvalue());
        } */       
        
        search_dates.add(ca.apt_date__c);  
  	    //loop through all days in the set and build search inventory for them
  	    for(Date sdate : search_dates) {
          //rebuild the search inventory for this day 
          List<Clinical_Search_Inventory__c> csi_old_temp = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :sdate and 
            clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :sdate
            and clinical_doctor_inventory__r.center_information__c = :current_center.id];            
          csi_old.addall(csi_old_temp);
          List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :sdate and center_information__c = :current_center.id];
          //loop through all apts for this center/day where the block is open
          for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :sdate and
            clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	        //loop through doctor time for this center/day
  	        //bad design - query on each loop iteration - fixing it
  	        //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :sdate and user__r.clinic_calendar__c = :current_center.name]) {
  	        for(Clinical_Doctor_Inventory__c cd : day_doc_inventory) {
  	          //see if there is an overlap 
  	          //if so - create a search block
  	          if((capt.stime__c >= cd.stime__c && capt.stime__c < cd.etime__c) || (capt.etime__c > cd.stime__c && capt.etime__c <= cd.etime__c)) {
  	            Integer minutes_before = 0;
  	            Integer minutes_dr = 0;
  	            Integer minutes_after = 0;
  	            //calculate minutes before dr is available
  	            if(capt.stime__c < cd.stime__c)
  	              minutes_before = cd.stime__c.intvalue() - capt.stime__c.intvalue();
  	            if(cd.etime__c > capt.etime__c) {
  	          	  //see which value is higher - block or doctor start time
  	          	  if(capt.stime__c > cd.stime__c)
  	          	    minutes_dr = (capt.etime__c.intvalue() - capt.stime__c.intvalue());
  	          	  else
  	                minutes_dr = (capt.etime__c.intvalue() - cd.stime__c.intvalue());
  	            }
  	            else {
  	          	  //see which value is higher - block or doctor start time
  	          	  if(capt.stime__c > cd.stime__c)
  	          	    minutes_dr = (cd.etime__c.intvalue() - capt.stime__c.intvalue());
  	          	  else
  	                minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	            } 
  	            //calculate minutes after dr available
  	            if(capt.etime__c > cd.etime__c)
  	              minutes_after = capt.etime__c.intvalue() - cd.etime__c.intvalue();
  	            //create our search block
    	        Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = capt.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	              minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	            csi_new.add(csi);
  	          }  	      
  	          //else - no need to do anything
  	        }
  	      }
  	    }        
        
        //commit changes - CSI        
        System.debug('Consult Search Inventory - Deleted Size : ' + csi_old.size());
        delete csi_old;
        if(csi_new.size()>0) {
          System.debug('Consult Search Inventory - New Size : ' + csi_new.size());
          insert csi_new; 
        }                           	    
        
        //close modal
        close_calendar_modal();      	  
  	  }  catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to schedule the new appointment.  Please contact IT for help ' + e.getLineNumber()));
        ApexPages.addMessages(e); 
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Rescheduling Error');
        message.setHtmlbody('An error occured during rescheduling - reschedule new apt.<br />' + e);
  	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','amcmullen@clearchoice.com','jreish@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });   
  	  }	
  	  
  	}
  }
  
  public void update_confirmation_status() {
  	try {
  	  update apt_block;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update confirmation status.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
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
  
  public Integer getnotification_size() {
  	return getpatient_notification_list().size();
  }
  
  public List<patient_notification> getpatient_notification_list() {
  	List<patient_notification> all_notifications = new List<patient_notification> ();
  	//to-do: add in all possible patient notification messages for display here 
  	//adding medical clearances here
  	system.debug('Patient Id : ' + patient.id);
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
  	//check for a pending resched
  	for(Clinical_Apt_Calendar__c ca : [select account__r.name, patient_pot_apt__r.name,doctor__r.name,patient_pot_apt__c,account__c,apt_date__c,stime__c,etime__c,clinical_room__c, clinical_room__r.name, id, status_updates__c
  	    from clinical_apt_calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c >= today and account__c = :patient.id]) {
  	   all_notifications.add(new patient_notification('ccf-calendar cc-font-light-16','Pending reschedule for ' + ca.apt_date__c.format(),'red'));
  	}	 
  	return all_notifications;
  }
  
  
  public Integer getform_count() {
  	return [select count() from Patient_Procedure_Form__c where account__c = :patient.id];
  }
  
  public string getmanual_schedule_link() {
  	dp_clinical_common.hrx_navigation_link npage = common_header.getpage_by_name ('Calendar',current_center);
  	Pagereference pr = new Pagereference(npage.getpage_url());
  	pr.getParameters().put('ctrid',current_center.id);
  	if(patient!=null)
  	  pr.getParameters().put('ptid',patient.id);  	      
  	return pr.getURL();
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
  	    and u.dosespot_user_id__c != null]) {  		
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
  
  public void display_new_patient_form() {
  	display_pform = true;
  	new_pform = new Patient_Procedure_Form__c(isactive__c = true, account__c = patient.id, form_name__c = 'Enter Document Name', forms_category__c = 'Additional Uploads', form_status__c = 'Incomplete', patient_pot__c = apexpages.currentpage().getparameters().get('potid'));
  }
  
  public void cancel_new_patient_form() {
  	display_pform = false;
  }
  
  public void reset_new_patient_form() {
    new_pform.form_name__c = 'Enter Document Name';  	
  }
  
  public void save_new_patient_form() {
  	//check for issues first
  	Integer num_issues = 0; 
  	if(new_pform.form_name__c==null) {
      num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for form name'));
  	} 	
  	else if(new_pform.form_name__c=='' || new_pform.form_name__c=='Enter Document Name') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for form name'));
  	}  	
  	else if(new_pform.form_name__c.length()<5) {
      num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a longer value for form name'));
  	}
  	if(num_issues==0) {
  	  try {  	    
  	    insert new_pform;
  	    cancel_new_patient_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a new upload document.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
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
  
  public Boolean gethas_patient_completed_health_history() {
  	//function name is misleading now,  as this just indicates we have a haleth history file and is used to display the icon on the patient page
  	Boolean hhistory_done = false;
  	if(phhistory!=null)   	  
  	  hhistory_done = true;  	
  	return hhistory_done;
  }
  
  public void DoseSpot_allergy_search() {
  	if(new_allergy.name.length()>=3) {
      try {
        allergy_search_results = new List<Allergy__c> ();
        DoseSpotServices.Response response = DoseSpotServices.allergy_search_results(patient.ID, allergy_search_value);
        
        System.debug('Allergy Search Response : ' + response);
      
        if (response.is_ok) {
          List<Map<String, String>> found_allergies = (List<Map<String, String>>)JSON.deserialize(JSON.serialize(response.data), List<Map<String, String>>.class);
          for (Map<String, String> allergy_data : found_allergies) {
            Allergy__c allergy = new Allergy__c(patient__c = patient.id, Name = allergy_data.get('name'), Code__c = allergy_data.get('code'), Code_Type__c = allergy_data.get('code_type'), Onset_Date_simple__c = Date.newInstance(1900, 1, 1));            
            allergy_search_results.add(allergy);
          }
        }
      } catch(Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup allergy info from Dosespot.  Please contact IT for help'));
        ApexPages.addMessages(e);	
      }
  	}
    else 
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Search requires at least three letters to perform a lookup'));
  }
  
  public String gettoday_string() {
    return String.valueOf(Date.today());
  }
  
  public void add_dosespot_allergy() {
    Integer position = Integer.valueOf(apexpages.currentpage().getparameters().get('aname'));
    Allergy__c allergy = allergy_search_results[position];
    Time midnight = Time.newInstance(0, 0, 0, 0);
    allergy.Onset_Date__c = Datetime.newinstance(allergy.Onset_Date_simple__c,midnight);
    if (allergy.Reaction__c == null) {allergy.Reaction__c = '';}
    Integer num_errors = 0;    
    if (String.isBlank(allergy.Name))             {allergy.Name.addError('Required');num_errors++;}
    //removed per Andy M 10/12/2017
    //if (allergy.Reaction__c == null)              {allergy.Reaction__c.addError('Required');num_errors++;}
      //else if(allergy.Reaction__c=='')  {allergy.Reaction__c.addError('Required');num_errors++;}
    if (allergy.Reaction_Type__c == null) {allergy.Reaction_Type__c.addError('Required');num_errors++;}
    if (allergy.Onset_Date__c == null)            {allergy.Onset_Date_simple__c.addError('Required');num_errors++;}    
    if(num_errors==0) {
      
      DoseSpotServices.Response response = DoseSpotServices.add_allergy(allergy.Name, allergy.Code__c, allergy.Code_Type__c, allergy.Reaction__c, allergy.Reaction_Type__c, allergy.Onset_Date__c, patient.ID);
      if (!response.is_ok) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Encountered an error while trying to add the allergy. Please contact IT.'));
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, response.message));
      }
      DoseSpotServices.upsert_allergies(patient.ID);
      //insert allergy;
      display_allergy_form = false;
    }  	
  }
  
  public void display_new_allergy_form() {
  	System.debug('New Allergy Form Running');
  	display_allergy_form = true;
  	new_allergy = new Allergy__c(Name = 'Enter Allergy Name', No_DoseSpot__c = true, patient__c = patient.id);
  	allergy_search_results = new List<Allergy__c>();
  	allergy_search_value = 'Allergy Lookup'; 
  }
  
  public Boolean getDoseSpot_is_accessible() {
  	//return false;
    return new DoseSpot(current_center).DoseSpot_is_accessible();
  }
  
  public void cancel_new_allergy_form() {
  	display_allergy_form = false;
  	current_edit = null;
  }
  
  public void reset_allergy_form() {
  	if(new_allergy.id==null)
  	  new_allergy.name = 'Enter Allergy Name';
  	else
  	  new_allergy = [select id,name,no_dosespot__c,patient__c from Allergy__c where id = :new_allergy.id];
  }
  
  public void edit_patient_allergy() {
  	display_allergy_form = false;
  	current_edit = apexpages.currentpage().getparameters().get('alid');
  	try {new_allergy = [select id,name,patient__c,no_dosespot__c,reaction_type__c,reaction__c from Allergy__c where id = :current_edit];} catch (Exception e) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The allergy you were trying to edit,  no longer exists'));}
  }
  
  
  public void save_new_allergy() {
  	//check for issues first
  	Integer num_issues = 0; 
  	if(new_allergy.name==null) {
      num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the allergy name'));
  	} 	
  	else if(new_allergy.name=='' || new_allergy.name=='Enter Allergy Name') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the allergy name'));
  	}  	
  	//make sure this is not a duplicate record
  	Integer acount = [select count() from allergy__c where name = :new_allergy.name and patient__c = :patient.id];
  	if(acount>0 && new_allergy.id==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The allergy you are trying to add is already listed for this patient'));
  	}  	
  	if(num_issues==0) {
  	  try {  	    
  	  	System.debug('New Allergy : ' + new_allergy);
  	  	if(new_allergy.id==null)
  	      insert new_allergy;
  	    else
  	      update new_allergy;
  	    cancel_new_allergy_form();
  	    DoseSpotServices.upsert_allergies(patient.ID);
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a new allergy.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public Allergy__c[] getpatient_allergies() {
  	return [select id,name,reaction__c,reaction_type__c from Allergy__c where patient__c = :patient.id];
  }
  
  public void close_confirmation_modal() {
  	confirmation_modal_display = false;
  	confirmation_modal_type = null;
  	modal_out = null;
  }
  
  public void confirm_delete_patient_allergy() {
  	confirmation_modal_display = true;
  	confirmation_modal_type = 'allergy';
  	modal_out = 'You are about to remove the allergy - ' + new_allergy.name;
  }
  
  public void delete_patient_allergy() {
  	try {
  	  delete new_allergy;
  	  close_confirmation_modal();
  	  try {
  	  	DoseSpotServices.remove_allergy(new_allergy,patient);
  	  } catch (Exception e) {}
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the allergy.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void form_removal_modal() {
  	try {
  	  Patient_procedure_form__c ppf = [select id,form_name__c from patient_procedure_form__c where id = :form_remove_id];
  	  confirmation_modal_display = true;
  	  confirmation_modal_type = 'form';
  	  modal_out = 'Are you sure you want to remove form - ' + ppf.form_name__c + '?';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the allergy.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	} 
  }
  
  public void delete_form_confirm() {
  	try {  	
  	  Patient_procedure_form__c ppf = [select id,form_name__c,isactive__c from patient_procedure_form__c where id = :form_remove_id];
  	  ppf.isactive__c = false;
  	  update ppf;
  	  form_remove_id = null;
  	  close_confirmation_modal();
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the allergy.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public String getapt_reminder_email_footer() { 		  	      
  	String footer_html = '<div class="header_left_center_col" style="padding-top:2em;line-height:1.5em;">' +
  	  '<img class="block" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001kEC9&oid=00D400000007ZMu" alt="" width="152" height="47"><br />' +    
      '<span class="header_section_padded">' + current_center.legal_name__c + '</span><br /> ' +
      '<span class="header_section_padded">Phone: ' + current_center.Local_Front_Desk__c + '</span><br />' + 
      '<span class="header_section_padded">' +   current_center.street_1__c + (current_center.street_2__c==null?'':', ' + current_center.street_2__c) + '<br />' + current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c + '</span><br />' +                    
    '</div>';                               
  	return footer_html;
  }
  
  public String getapt_reminder_email_header() { 		  	
  	//return the header html for the account statement report - email version      
  	String header_html = '<div class="output_page" style="">';                            
  	return header_html;
  }
  
  public String getapt_reminder_header() { 		  	
  	//return the header html for the account statement report
  	//get the url for the logo 	  	
  	//StaticResource sr = [SELECT id,name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = 'CCLogo_Transparent' limit 1];
  	//String image_url = '/resource/' + sr.SystemModStamp.getTime() + '/' + (sr.namespaceprefix != null && sr.namespaceprefix != '' ? sr.namespaceprefix + '__' : '') + 'CCLogo_Transparent';      
  	String header_html = '<div class="output_page" style="flex-wrap:wrap;">' + 
      '<div class="header_section">' + 
        '<div class="header_left_col" >'; 
    header_html += '<img class="block" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001kEC9&oid=00D400000007ZMu" alt="" width="152" height="47">';    
    header_html += '<div class="header_left_center_col">' +
            '<span class="header_section_padded">' + current_center.legal_name__c + '</span><br />' +
            '<span class="header_section_padded">Phone: ' + current_center.Local_Front_Desk__c + '</span><br />' + 
            '<span class="header_section_padded">' +   current_center.street_1__c + (current_center.street_2__c==null?'':', ' + current_center.street_2__c) + '<br />' + current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c + '</span>' +                    
          '</div>' + 
        '</div>' +
        '<div class="header_right_col">' +         
          '<p class="header_section_padded">Date: &nbsp;&nbsp;' +  System.now().format('M/dd/YYYY') + '</p>' +
          //'<p class="header_section_padded">Page: &nbsp;&nbsp;' + pnum + '</p>' +  
        '</div>' +       
      '</div>';                               
  	return header_html;
  }
  
  public String getapt_reminder_output_email() {
  	String report_output = getapt_reminder_email_header();
  	try {  	
  	  List<Clinical_Apt_Calendar__c> apt_list;
  	  if(apexpages.currentpage().getparameters().get('aptid')!=null)
  	    //pull info for this specific apt
  	    apt_list = [select id,apt_date__c,stime__c,etime__c,patient_pot_apt__r.name,patient_pot_apt__r.appointment_description__c from Clinical_Apt_Calendar__c 
  	      where patient_pot_apt__c = :apexpages.currentpage().getparameters().get('aptid') order by apt_date__c,stime__c];
  	  else if(apexpages.currentpage().getparameters().get('potid')!=null)
   	    //pull info for all future apts on this pot
        apt_list = [select id,apt_date__c,stime__c,etime__c,patient_pot_apt__r.name,patient_pot_apt__r.appointment_description__c from Clinical_Apt_Calendar__c 
          where patient_pot_apt__r.patient_pot__c = :apexpages.currentpage().getparameters().get('potid') and apt_date__c >= today and apt_status__c = null order by apt_date__c,stime__c];
      String apt_text = ' appointment';
      if(apt_list.size()>1)
        apt_text = 'appointments';
      report_output += 'Your upcoming scheduled ' + apt_text + ': <br />' +
        '<div class="apt_reminder_holder" style="">';
      Date last_date;
      for(Clinical_Apt_Calendar__c ca : apt_list) {
      	if((last_date==null?System.today().adddays(-1):last_date)!=ca.apt_date__c) 
      	  report_output += '<div class="apt_reminder_row" style="width: 100%;min-width: 200px;max-width: 400px;border: 1px dotted black;margin-right: 2em;padding: 5px; color: rgba(0, 0, 0, 1);    background-color: rgba(56, 56, 56, 0.15); padding-top: 10px;    padding-bottom: 8px;    padding-right: 5px;    padding-left: 10px;    border-radius: 4px;    align-items: center;    font-weight: 400;  transition: .25s; margin-top:1.5em; ">' +
      	    '<span class="apt_datetime_span" style="font-weight:bold; padding-bottom:10px;">' + Datetime.newinstance(ca.apt_date__c.year(),ca.apt_date__c.month(),ca.apt_date__c.day()).format('M/dd/YYYY')  +
      	    ' at ' + dec_to_time(ca.stime__c) + '</span><br /><br />' +
      	    '<span class="apt_name_span" style=" padding-bottom:1em;">' + ca.patient_pot_apt__r.name + '</span>' +      	          	    
      	  '</div>';      	  
      	last_date = ca.apt_date__c;
      }
      report_output += '</div></div>';
      
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to produce the apt reminder sheet.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  
  	return report_output + '</div>' + getapt_reminder_email_footer();
  }
  
  public String getlabel_unique_id() {
  	//need to figure out the logic here....this should return either a sf id or possible a windent id.    	
  	String return_id = String.valueof(patient.warranty_id__c);
  	//pull a list of opportunities for this account and see if we have a patient id  	
  	if(current_center.Use_Windent_ID_for_Dexis_when_possible__c) {
	  for(Opportunity o : patient.opportunities) {
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
  
  public String getdymo_patient_label() {
  	String rout = '';
  	try {
  	  rout = 
  	  '<div style="display:flex;flex-direction:row;max-width:225px;min-width:225px;font-size:10pt;">' + 
        '<div style="display:flex;flex-direction:column;min-width:50%;">' +
          '<span>' + patient.lastname + ', ' + patient.firstname + '</span>' +     
          '<span>' + DateTime.newInstance(patient.date_of_birth__c.year(),patient.date_of_birth__c.month(),patient.date_of_birth__c.day()).format('M/dd/yyyy') + '</span>' +
          '<span>' + patient.billingstreet + '</span>' +
          '<span>' + patient.billingcity + ', ' + patient.billingstate + ' ' + patient.billingpostalcode + '</span>' +
          '<span>H: ' + patient.phone + '</span>' +
        '</div>' +
        '<div style="display: flex;flex-direction: column;align-items: flex-end;width:100%;">' +                 
            '<span>' + getlabel_unique_id() + '</span><br /><br /><br />' +
            '<span>W: ' + patient.business_phone__c + '</span>' + 
        '</div>' +                
      '</div>';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to produce the apt reminder label.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}       
  	return rout;
  }
  
  public String getdymo_apt_reminder() {
  	String rout = '';
  	try {
  	  Clinical_Apt_Calendar__c ca = [select id,apt_date__c,stime__c,etime__c,patient_pot_apt__r.name,patient_pot_apt__r.appointment_description__c from Clinical_Apt_Calendar__c 
  	    where patient_pot_apt__c = :apexpages.currentpage().getparameters().get('aptid') order by apt_date__c,stime__c];
  	  rout = 
  	  '<div style="display:flex;flex-direction:column;max-width:225px;">' + 
        '<div style="display:flex;flex-direction:row;width: 100%;padding-bottom:8px;">' +
          '<img class="block" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001kEC9&oid=00D400000007ZMu" alt="" width="100" height="31px">' +        
          '<span style="width: 100%;justify-self: initial;text-align: end;align-self: center;font-size: 14pt;font-weight:bold;">Reminder</span>' +                              
        '</div>' +
        '<div style="display: flex;flex-direction: column;align-items: center;font-size:12pt;">' +                 
          '<span>' + patient.name + '</span>' +  
          '<span>' + Datetime.newinstance(ca.apt_date__c.year(),ca.apt_date__c.month(),ca.apt_date__c.day()).format('M/dd/YYYY') + ' ' + dec_to_time(ca.stime__c) + '</span>' +
        '</div>' +                
      '</div>';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to produce the apt reminder label.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}       
  	return rout;
  }
  
  public String getapt_reminder_output() {
  	String report_output = '';
  	if(apexpages.currentpage().getparameters().get('plabel')!=null)
  	  report_output = getdymo_patient_label();
  	else if(apexpages.currentpage().getparameters().get('dymo')!=null)
  	  report_output = getdymo_apt_reminder();
  	else {
  	  report_output = getapt_reminder_header();  	
  	  try {  	
  	    List<Clinical_Apt_Calendar__c> apt_list;
  	    if(apexpages.currentpage().getparameters().get('aptid')!=null)
  	      //pull info for this specific apt
  	      apt_list = [select id,apt_date__c,stime__c,etime__c,patient_pot_apt__r.name,patient_pot_apt__r.appointment_description__c from Clinical_Apt_Calendar__c 
  	        where patient_pot_apt__c = :apexpages.currentpage().getparameters().get('aptid') order by apt_date__c,stime__c];
  	    else if(apexpages.currentpage().getparameters().get('potid')!=null)
   	      //pull info for all future apts on this pot
          apt_list = [select id,apt_date__c,stime__c,etime__c,patient_pot_apt__r.name,patient_pot_apt__r.appointment_description__c from Clinical_Apt_Calendar__c 
            where patient_pot_apt__r.patient_pot__c = :apexpages.currentpage().getparameters().get('potid') and apt_date__c >= today and apt_status__c = null order by apt_date__c,stime__c];
        String apt_text = ' appointment';
        if(apt_list.size()>1)
          apt_text = 'appointments';
        report_output += 'Your upcoming scheduled ' + apt_text + ': <br />' +
          '<div class="apt_reminder_holder">';
        Date last_date;
        for(Clinical_Apt_Calendar__c ca : apt_list) {
      	  if((last_date==null?System.today().adddays(-1):last_date)!=ca.apt_date__c) 
      	    report_output += '<div class="apt_reminder_row" >' +
      	      '<span class="apt_datetime_span"><span class="apt_date_span">' + Datetime.newinstance(ca.apt_date__c.year(),ca.apt_date__c.month(),ca.apt_date__c.day()).format('M/dd/YYYY') + '</span>' +
      	      '<span class="apt_time_span">' + dec_to_time(ca.stime__c) + '</span></span>' +
      	      '<span class="apt_name_span">' + ca.patient_pot_apt__r.name + '</span>' +      	          	    
      	    '</div>';      	  
      	  last_date = ca.apt_date__c;
        }
        report_output += '</div></div>';      
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to produce the apt reminder sheet.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }  
  	}
  	return report_output + '</div>';
  }
  
  public void send_health_history_form() {
  	try {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  	
	  //mail.setSenderDisplayName('ClearChoice');
	  OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where displayname = :current_center.Hope_RX_Sending_Email__c or Address = :current_center.hope_rx_sending_email__c];
	  if ( owea.size() > 0 ) {
	    mail.setOrgWideEmailAddressId(owea.get(0).Id);
	  }  
	  mail.setTargetObjectId(patient.PersonContactId); //Specify who the email should be sent to.
	  mail.setSubject('ClearChoice Dental Implant Center- Paperwork');
	  String ebody = 'Hello,<br /><br /> ' +
       '<a href="https://clearchoicecallcenter.secure.force.com/healthistory" target="__blank">CLICK HERE</a> to complete your paperwork. You will be asked to provide a Check-in Code before ' + 
       'proceeding. Please contact your Patient Education Consultant with any questions.<br /><br /><br />' + 
       'Regards,<br /><br />';
      ebody += '<img class="block" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001kEC9&oid=00D400000007ZMu" alt="" width="152" height="47"><br />' +  
       '<div>' +
          '<span >' + current_center.legal_name__c + '</span><br />' +
          '<span >Phone: ' + current_center.Local_Front_Desk__c + '</span><br />' + 
          '<span >' +   current_center.street_1__c + (current_center.street_2__c==null?'':', ' + current_center.street_2__c) + '<br />' + current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c + '</span>' +                    
        '</div>';
	  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head>' +	  
	    '</head><body>' + ebody + '</body></html>');
	  mail.setPlainTextBody(ebody);	  	  
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	  hh_email_status = '<span class="esuccess">Success - health history link was sent on ' + System.now().format('M/dd/yyyy hh:mm') + '</span>';		    			
	}  catch (Exception e) {
	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to send the email.  Please contact IT for help'));
      ApexPages.addMessages(e);
      hh_email_status = '<span class="efail">There was an error sending the email</span>';
	}  
  }
  
  public void send_apt_reminder_email() {
  	try {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  	
	  //mail.setSenderDisplayName('ClearChoice');
	  OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where displayname = :current_center.Hope_RX_Sending_Email__c or Address = :current_center.hope_rx_sending_email__c];
	  if ( owea.size() > 0 ) {
	    mail.setOrgWideEmailAddressId(owea.get(0).Id);
	  }  
	  mail.setTargetObjectId(patient.PersonContactId); //Specify who the email should be sent to.
	  mail.setSubject('Appointment Reminders');
	  String ebody = getapt_reminder_output_email();
	  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head>' +	  
	    '</head><body>' + ebody + '</body></html>');
	  mail.setPlainTextBody(ebody);
	  	  
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	  email_status = '<span class="esuccess">Success - appointment email reminder was sent on ' + System.now().format('M/dd/yyyy hh:mm') + '</span>';		    			
	}  catch (Exception e) {
	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to send the email.  Please contact IT for help'));
      ApexPages.addMessages(e);
      email_status = '<span class="efail">There was an error sending the email</span>';
	}  
	System.debug('Email Status : ' + email_status); 
  }
  
  public void toggle_quick_search() {
  	allow_quick_search = (allow_quick_search?false:true);
  	User u = [select id,Enable_Patient_Quick_Search__c from user where id = :userinfo.getuserid()];
  	u.enable_patient_quick_search__c = allow_quick_search;
  	update u;
  }
  
  public String getpatient_age() {
  	String return_age = 'N/A';
  	if(patient.date_of_birth__c != null) {
  	  Integer num_years = System.today().year() - patient.date_of_birth__c.year();
  	  //now see if this person has not had their birthday yet...if so well subtract one
  	  if(patient.date_of_birth__c.month() > System.today().month())
  	    num_years = num_years - 1;
  	  else if(patient.date_of_birth__c.month() == System.today().month() && patient.date_of_birth__c.day() > System.today().day())
  	    num_years = num_years - 1;
  	  return_age = String.valueof(num_years);  	   
  	}
  	return return_age;
  }
  
  public void add_to_clipboard() {
  	try {
  	  //Integer board_count = [select count() from clinical_clipboard__c where createdbyid = :userinfo.getuserid() and patient_pot_apt__c = :apexpages.currentpage().getparameters().get('cbid')];
  	  Integer board_count = [select count() from clinical_clipboard__c where center_information__c = :current_center.id and patient_pot_apt__c = :apexpages.currentpage().getparameters().get('cbid')];
  	  if(board_count==0) {
  	    Clinical_Clipboard__c new_item = new Clinical_Clipboard__c(account__c = patient.id, patient_pot_apt__c = apexpages.currentpage().getparameters().get('cbid'),center_information__c = current_center.id);
  	    insert new_item;
  	  }  	
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to move this apt to the clipboard.'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public List<Selectoption> getapt_sort_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	Integer max_sort = getpot_next_sort_value();
  	clist.add(new Selectoption(String.valueof(max_sort),String.valueof(max_sort)));
  	//figure out min sort and go up to max
  	Patient_POT__c p = [Select p.Treatment_Description__c, p.SystemModstamp, p.Plan_of_Treatment__c, p.plan_of_treatment__r.name, p.OwnerId, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Account__c, p.doctor_notes__c,(Select Health_Condition__c, Request_Status__c, IsActive__c, Patient_POT__c From Medical_Clearances__r where isactive__c = true) From Patient_POT__c p where id = :new_apt_form_id order by createddate desc];
  	dp_clinical_pot.pot new_plan = new dp_clinical_pot.pot(p);
  	//grab out apts
  	Patient_POT_Apt__c last_apt;
  	for(Patient_POT_Apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, p.doctor_notes__c, (Select Id, Name, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c, allow_tooth_selection__c, target_teeth__c, clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedures__r where isactive__c = true order by sort_order__c), 
  	  (Select Id, Apt_Date__c,apt_status__c,start_hour_int__c,start_minute_int__c,end_hour_int__c,end_minute_int__c From Clinical_Apt_Calendar__r order by apt_date__c desc),(Select Id From Clinical_Apt_Histories__r) From Patient_POT_Apt__c p where isactive__c = true and patient_pot__c = :new_plan.plan.id order by sort_order__c]) {
  	  Boolean on_clipboard = false;
  	  dp_clinical_pot.pot_apt new_apt = new dp_clinical_pot.pot_apt(pa,last_apt,new_plan.getneeds_medical_clearance(),on_clipboard);
  	  new_plan.apts.add(new_apt);
  	  last_apt = pa;
  	}
  	//work through apts and look for first one that allows scheduling  	  	
  	Integer min_sort = max_sort;
  	for(dp_clinical_pot.pot_apt pa : new_plan.apts) {
  	  if(pa.getallow_scheduling()) {
  	    min_sort = pa.apt.sort_order__c.intvalue();
  	    break;
  	  }
  	}
  	while(min_sort<max_sort) {
  	  clist.add(new Selectoption(String.valueof(min_sort),String.valueof(min_sort)));
      min_sort++;
  	}
	return clist;
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
  
  public Boolean getdisplay_check_in_button() {
  	if(!getdisplay_check_in_code() && patient.opportunities.size()>0)
  	  return true;
  	else
  	  return false;
  }
  
  public Boolean getdisplay_check_in_code() {
  	Boolean has_code = false;
  	for(Opportunity o : patient.opportunities) {
  	  if(o.short_code__c!=null)
  	    has_code = true;
  	}
  	return has_code;
  }
  
  public String getcheck_in_code() {
  	String ccode = '';
  	for(Opportunity o : patient.opportunities) {
  	  if(o.short_code__c!=null)
  	    ccode = o.short_code__c;
  	}
  	return ccode;
  }
   
  public void generate_check_in() {
  	try {
  	  guidGenerator.generateSignInCode(patient.opportunities[0].id);
  	  getpatient_record(patient.id,current_center.id);
  	} catch (Exception e) {
  	
  	}
  }
  
  public dp_clinical_common.hrx_navigation_link getcenter_page() {
  	return common_header.getpage_by_name ('Calendar',current_center);
  }
  
  /*public class common_lab_methods {
  	private ID lab_center;
  	
  	public common_lab_methods(ID center_id) {this.lab_center = center_id;}
  	
  	//method that updates or generates a new lab case - should be called anytime we have a schedule or cancellation event
    public void update_lab_case(ID calendar_id,Date calendar_date,ID patient_apt_id,ID patient_id,Integer days_before) {
  	  try {
  	    Integer case_count = [select count() from hrx_lab_case__c where patient_pot_apt__c = :patient_apt_id];
  	    if(case_count==0) {
          HRX_lab_case__c lab_case = new hrx_lab_case__c(center_information__c = lab_center, account__c = patient_id, patient_pot_apt__c = patient_apt_id, clinical_apt_calendar__c = calendar_id, due_date__c = calendar_date.adddays(days_before * -1), status__c = 'Not Started');          
          insert lab_case;
  	    } else {
  		  hrx_lab_case__c lab_case = [select id,clinical_apt_calendar__c,due_date__c from hrx_lab_case__c where patient_pot_apt__c = :patient_apt_id];
  		  lab_case.clinical_apt_calendar__c = calendar_id;
  		  lab_case.due_date__c = calendar_date.adddays(days_before * -1);
  		  update lab_case;
  	    }
  	  }  catch (Exception e) {
  	    ApexPages.addMessages(e);
  	  }
    }
  	
  	public void reset_lab_case(ID patient_pot_apt) {
  	  try {
        Integer case_count = [select count() from hrx_lab_case__c where patient_pot_apt__c = :patient_pot_apt];
        if(case_count>0) {
      	  hrx_lab_case__c lab_case = [select id,clinical_apt_calendar__c,due_date__c from hrx_lab_case__c where patient_pot_apt__c = :patient_pot_apt];
      	  lab_case.clinical_apt_calendar__c = null;
      	  //due date will not be cleared now - instead the case will sit on this date until it gets scheduled again
      	  //lab_case.due_date__c = null;
      	  update lab_case;
        }  		
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update lab case'));
        ApexPages.addMessages(e);
  	  }
    }
  }*/
}