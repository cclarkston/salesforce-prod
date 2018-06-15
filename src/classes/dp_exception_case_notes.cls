public with sharing class dp_exception_case_notes {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  public Date sdate {get; set;}
  public Date edate {get; set;}
  public String filename {get;set;}
  public String file_header {get;set;}
  
  public String report_type {get; set;}
  
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
  
  public dp_exception_case_notes() {
  	//User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];     
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {           
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,Use_Alternate_Url__c,sales_region__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,Use_Alternate_Url__c,sales_region__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,Use_Alternate_Url__c,sales_region__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   
  	
  	//check for pass through values
  	try {
  	  if(apexpages.currentpage().getparameters().get('sdate')==null) {
  	    sdate = System.today().adddays(-30);
  	  } else {
  	    sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	  }
  	  if(apexpages.currentpage().getparameters().get('edate')==null) {
  	    edate = System.today();
  	  } else {
  	    edate = Date.parse(apexpages.currentpage().getparameters().get('edate'));
  	  }
  	} catch (Exception e) {
  	  sdate = System.today().adddays(-30);
  	  edate = System.today();
  	}  
  	
  	if(apexpages.currentpage().getparameters().get('rtype')!=null)
      report_type = apexpages.currentpage().getparameters().get('rtype');
    else
      report_type = 'No Notes';	
  	  
  	filename = 'apts_with_no_case_notes_' + sdate.format() + '_to_' + edate.format() + '.csv';
  	file_header = '';  	  
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
  	  System.debug('Changing Center : ' + apexpages.currentpage().getparameters().get('cid'));
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,Use_Alternate_Url__c,sales_region__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
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
  	    if(apexpages.currentpage().getparameters().get('ptid')!=null)
  	      pr.getParameters().put('ptid',apexpages.currentpage().getparameters().get('ptid'));     	      	     
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
  
  public class Clinical_Apt {
  	public Clinical_Apt_Calendar__c ca {get; set;}
  	
  	public clinical_apt(Clinical_Apt_Calendar__c c) {
  	  this.ca = c;
  	}
  	
  	public String getnotes_href() {
  	  Pagereference pr = Page.ccare_clinical_notes;
      pr.getParameters().put('ctrid',ca.clinical_room__r.center_information__c); 
      pr.getParameters().put('ptid',ca.account__c);
  	  String last_case_id;
  	  if(ca.clinical_note_instances__r.size()>0) {
  	    pr.getParameters().put('ici',ca.clinical_note_instances__r[ca.clinical_note_instances__r.size()-1].id);
  	  }
  	  return pr.getUrl();  
  	}
  } 
  
  public List<Clinical_Apt> getapts_with_no_notes_class() {
  	List<Clinical_Apt> ca_return_list = new List<Clinical_Apt>();
  	for(Clinical_Apt_Calendar__c ca : getapts_with_no_notes_display()) {
  	  ca_return_list.add(new clinical_apt(ca));
  	}
  	return ca_return_list;
  }
  
  public List<Clinical_Apt> getapts_with_no_review_class() {
  	List<Clinical_Apt> ca_return_list = new List<Clinical_Apt>();
  	for(Clinical_Apt_Calendar__c ca : getapts_with_no_review_display()) {
  	  ca_return_list.add(new clinical_apt(ca));
  	}
  	return ca_return_list;
  }
  
  public List<Clinical_Apt_Calendar__c> getapts_with_no_notes_display() {
    List<Clinical_Apt_Calendar__c> return_list = new List<Clinical_Apt_Calendar__c> ();
    //System.debug('Sdate : ' + sdate + ' Edate : ' + edate + ' current center : ' + current_center);
    for(Clinical_Apt_Calendar__c ca : [Select c.Apt_Status__c, c.Apt_Date__c, c.Account__c, c.account__r.name, patient_pot_apt__r.patient_pot__r.name, clinical_room__r.name, 
      patient_pot_apt__r.name, doctor__r.name, clinical_room__r.center_information__c,
        (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
        Account__c, Apt_Note__c, Clinical_Apt_Calendar__c, IsActive__c, Patient_POT_Apt__c, Review_Time__c, Reviewed_By__c From Clinical_Note_Instances__r) 
      From Clinical_Apt_Calendar__c c
      where
        account__c != null 
        and apt_date__c >= :sdate and apt_date__c <= :edate 
        and clinical_room__r.center_information__c = :current_center.id
        and apt_status__c != null and apt_status__c not in ('No Show','Pending Reschedule')
        and patient_pot_apt__c != null
      order by apt_date__c]) {      	
      //test the record to see if it should go in the return set 
      //anything with no notes goes in
      //Anything with just one note that has the same created/modified date goes in
      if(ca.clinical_note_instances__r.size()==0)
        return_list.add(ca);
      else if(ca.clinical_note_instances__r.size()==1 && ca.clinical_note_instances__r[0].createddate == ca.clinical_note_instances__r[0].lastmodifieddate) {
      	return_list.add(ca);
      }    	
    }    
    return return_list;
  }
  
  public CSVsets[] getapts_with_no_notes_csv() {
    csvset = new CSVSets[] {};
    CSVSets working_csvset = new CSVSets();
  	csvout = new CSVOutput[] {};
  	file_header = '"Apt Date","Patient","Appointment","Status","Doctor","Plan of Treatment","Room Name"';
  	List<Clinical_Apt_Calendar__c> ca_source_list;
  	if(report_type=='No Notes')
  	  ca_source_list = getapts_with_no_notes_display();
  	else if(report_type=='No Doctor')
  	  ca_source_list = getapts_with_no_review_display();  
  	for(Clinical_Apt_Calendar__c ca : ca_source_list) {  	  	    	        
	  CSVOutput csv_line = new CSVOutput();
	  csv_line.output_line = '';	  
	  csv_line.output_line += '"' + ca.apt_date__c  + '","' 
	    + ca.account__r.name + '","' 
	    + ca.patient_pot_apt__r.name + '","' 
	    + ca.apt_status__c + '","'
	    + ca.doctor__r.name + '","'
	    + ca.patient_pot_apt__r.patient_pot__r.name + '","'
	    + ca.clinical_room__r.name + '"';
	  csvout.add(csv_line);
	}
  	working_csvset.csvfiles = csvout;
	csvset.add(working_csvset);
  	return csvset;
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
  	  } else {
  	  	for(Integer clinician_id : all_clinician_ids) {
  	  	  DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors_by_clinician(current_center,clinician_id);
          Map<String,Object> amap = (Map<String,object>)dres.data;
          error_count += Integer.valueof(amap.get('refillRequestCount'));
          error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  	}
  	  }  	  
      return error_count;    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return error_count;
  }
  
   public transient CSVOutput[] csvout;

  public transient CSVsets[] csvset;

  public class CSVSets {
  	public CSVOutput[] csvfiles {get; set;}
  }

  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public String getcsv_download_link() {
  	Pagereference pr = Page.ccare_exception_case_notes_csv;
    pr.getParameters().put('ctrid',current_center.id); 
    pr.getParameters().put('sdate',sdate.format());
    pr.getParameters().put('edate',edate.format());     
    pr.getParameters().put('rtype',report_type);
    return pr.getUrl();  	
  }
  
  public List<Selectoption> getrtype_options() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('No Notes','Appointments with no notes'));
  	clist.add(new Selectoption('No Doctor','Awaiting doctor review'));  	  
	return clist;
  }
  
  public List<Clinical_Apt_Calendar__c> getapts_with_no_review_display() {
    List<Clinical_Apt_Calendar__c> return_list = new List<Clinical_Apt_Calendar__c> ();
    //System.debug('Sdate : ' + sdate + ' Edate : ' + edate + ' current center : ' + current_center);
    for(Clinical_Apt_Calendar__c ca : [Select c.Apt_Status__c, c.Apt_Date__c, c.Account__c, c.account__r.name, patient_pot_apt__r.patient_pot__r.name, clinical_room__r.name, 
      patient_pot_apt__r.name, doctor__r.name, clinical_room__r.center_information__c,
        (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
        Account__c, Apt_Note__c, Clinical_Apt_Calendar__c, IsActive__c, Patient_POT_Apt__c, Review_Time__c, Reviewed_By__c From Clinical_Note_Instances__r) 
      From Clinical_Apt_Calendar__c c
      where
        account__c != null 
        and apt_date__c >= :sdate and apt_date__c <= :edate 
        and clinical_room__r.center_information__c = :current_center.id
        and apt_status__c != null and apt_status__c not in ('No Show','Pending Reschedule')
      order by apt_date__c]) {      	
      //test the record to see if it should go in the return set 
      //anything with no notes goes in
      //Anything with just one note that has the same created/modified date goes in
      if(ca.clinical_note_instances__r.size()>0) {
        //check the last note and see if it has a doctor review
        if(ca.clinical_note_instances__r[ca.clinical_note_instances__r.size()-1].reviewed_by__c==null)
          return_list.add(ca);
      }    	
    }    
    return return_list;
  }
  

}