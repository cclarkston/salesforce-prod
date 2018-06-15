public with sharing class dp_clinical_chart {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  
  public Account patient {get;set;}
  public Boolean display_patient_search_modal {get; set;}
  public String search_name {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public List<Account> consult_search_results {get; set;}
  public List<perio_exam> current_charts;
  
  public Boolean confirmation_modal_display {get; set;}
  public String confirmation_modal_type {get; set;}
  public String modal_out {get; set;}
  public Boolean display_medical_warnings {get; set;}
  Set<ID> market_centers;
  
  public String search_first {get;set;}
  public String search_unique {get; set;}
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
  
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();} 
  
  static User u = [select Enable_Patient_Quick_Search__c,name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];  
  
  public class bendException extends Exception {}	
  
  //see if it's a corporate admin
  static {
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;}  
  
  public Boolean start_perio {get; set;}
  
  //public Boolean allow_quick_search;
  public Boolean getallow_quick_search() {
  	//if(allow_quick_search==null)
  	  //allow_quick_search = [select id,Enable_Patient_Quick_Search__c from user where id = :userinfo.getuserid()].enable_patient_quick_search__c; 
  	return u.enable_patient_quick_search__c;
  }
  
  public dp_clinical_chart() {
  	display_medical_warnings = true;
  	//User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];       	
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
  	    start_perio = true;
  	  } else {
  	    display_patient_search_modal = true;
  	    search_name = '';
  	    search_first = '';
  	    search_unique = '';
  	    search_phone = '';
  	    search_email = ''; 
  	    consult_search_results = new List<Account>();
  	    start_perio = false;
  	  }  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up the patient record.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  	
  	num_patient_records = 20;
    display_more_search_records = false;
  	confirmation_modal_display = false;
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
  
  public void getpatient_record(String patient_id,String center_id) {
    patient = [select id,name,recent_height_feet__c,recent_height_inches__c,recent_weight__c from Account where id = :patient_id and center__c in :market_centers];
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
  	  consult_search_results = new List<Account>();
  	  display_patient_search_modal = false;
  	  display_medical_warnings = true;
      pr = Page.ccare_clinical_perio;
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
  
  public Boolean getallow_new_chart() {
  	Boolean new_chart = false;
  	if(getpatient_record_selected()) {
      Date allow_date = System.today().adddays(-2);  
  	  Integer perio_count = [select count() from perio_chart__c where account__c = :patient.id and createddate >= :allow_date];
  	  if(perio_count==0)
  	    new_chart = true;
  	}
  	return new_chart;
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
  
  public String getdefault_teeth_state() {
  	String teeth_array = '';
    if(patient!=null) {
  	  //check to see if we have any perio charts for this patient
  	  Integer perio_count = [select count() from perio_chart__c where account__c = :patient.id];
  	  if(perio_count==0) {
  	    //set the default array
  	    for(Integer i=1;i<=32;i++) {
  	  	  teeth_array += '{"tnumber":' + i + ',"typeOf":"Natural","measure":["null","null","null","null","null","null"],"endo":0,"decay":0}';
  	  	  if(i<32)
  	  	    teeth_array += ',';
  	    }
  	  }
  	  else {
  	    //grab the most recent chart and build the array
  	    Perio_Chart__c last_chart = [select id from Perio_Chart__c where account__c = :patient.id order by createddate desc limit 1];
  	    for(Perio_Chart_Tooth__c pct : [Select p.Tooth_Type__c, p.Name, p.Measurement__c, p.Endo__c, p.Decay__c From Perio_Chart_Tooth__c p where perio_chart__c = :last_chart.id order by tooth_integer__c]) {
  	  	  String measure = '';
  	  	  for(String m : pct.measurement__c.split(',')) {
  	  	    measure += '"' + m + '",';
  	  	  }
  	  	  measure = measure.left(measure.length()-1);  	  	  	  	 
  	  	  teeth_array += '{"tnumber":' + pct.name + ',"typeOf":"' + pct.tooth_type__c + '","measure":[' + measure + '],"endo":' + pct.endo__c + ',"decay":' + pct.decay__c + '},';
  	    }
  	    teeth_array = teeth_array.left(teeth_array.length()-1);
  	  }
    }
  	return teeth_array;
  }
  
  public class perio_exam {
  	public perio_chart__c pchart {get; set;}
  	public perio_exam_tooth[] upper_teeth {get; set;}
  	public perio_exam_tooth[] lower_teeth {get; set;}
  	public prosth_exam_form__c pform {get; set;}
  	
  	public perio_exam(perio_chart__c pc) {
  	  this.pchart = pc;
  	  this.upper_teeth = new perio_exam_tooth[] {};
  	  this.lower_teeth = new perio_exam_tooth[] {};
  	}
  	
  	public Boolean getperio_editable() {
  	  Boolean edit_status = false;
  	  if(pchart.createddate.date()>=System.today().adddays(-2))
  	    edit_status = true;
  	  return edit_status;
  	}
  	
  	public String getchart_date() {
  	  return pchart.createddate.format('M/dd/yyyy');
  	}
  	
  	public Boolean getdisplay_prosth_exam_form() {
  	  if(pform!=null)
  	    return true;
  	  else
  	    return false;
  	}
  }
  
  public class perio_exam_tooth {
  	public perio_chart_tooth__c tooth {get; set;}
  	
  	public perio_exam_tooth(perio_chart_tooth__c t) {
  	  this.tooth = t;
  	}
  	
  	public String grab_measurement(Integer mposition) {
  	  String mvalue = '';
  	  try {
  	  	String[] m = tooth.measurement__c.split(',');
  	    if(m[mposition]!='null')
  	      mvalue = m[mposition];
  	  } catch (Exception e) {
  	  	
  	  }
  	  return mvalue;
  	}
  	
  	public String getmeasurement_1() {
      String mvalue = grab_measurement(0);      
  	  return mvalue;
  	}
  	
  	public String grab_css(String mvalue) {  		
  	  Set<String> green_values = new Set<String> {'1','2','3'};  
      Set<String> orange_values = new Set<String> {'4','5','6'};
      Set<String> red_values = new Set<String> {'7','8','9'};
      if(green_values.contains(mvalue))
        return 'cc-perio-thumb-measure-1';
      else if(orange_values.contains(mvalue))
        return 'cc-perio-thumb-measure-3';
      else if(red_values.contains(mvalue))
        return 'cc-perio-thumb-measure-5';        
  	  else
  	    return 'cc-perio-thumb-measure-blank';  	    
  	}
  	
  	public String getmeasurement_1_css() {
      String mvalue = grab_measurement(0);
      String measure_css = grab_css(mvalue) + ' cc-perio-thumb' + tooth.name + '-1';              
  	  return measure_css;
  	}
  	
  	public String getmeasurement_2() {
      String mvalue = grab_measurement(1);
  	  return mvalue;
  	}
  	
  	public String getmeasurement_2_css() {
      String mvalue = grab_measurement(1);
      String measure_css = grab_css(mvalue) + ' cc-perio-thumb' + tooth.name + '-2';               
  	  return measure_css;
  	}  	
  	
  	public String getmeasurement_3() {
      String mvalue = grab_measurement(2);
  	  return mvalue;
  	}
  	
  	public String getmeasurement_3_css() {
      String mvalue = grab_measurement(2);
      String measure_css = grab_css(mvalue) + ' cc-perio-thumb' + tooth.name + '-3';               
  	  return measure_css;
  	}  	
  	
  	public String getmeasurement_4() {
      String mvalue = grab_measurement(3);
  	  return mvalue;
  	}
  	
  	public String getmeasurement_4_css() {
      String mvalue = grab_measurement(3);
      String measure_css = grab_css(mvalue) + ' cc-perio-thumb' + tooth.name + '-4';              
  	  return measure_css;
  	}  	
  	
  	public String getmeasurement_5() {
      String mvalue = grab_measurement(4);
  	  return mvalue;
  	}
  	
  	public String getmeasurement_5_css() {
      String mvalue = grab_measurement(4);
      String measure_css = grab_css(mvalue) + ' cc-perio-thumb' + tooth.name + '-5'; 
  	  return measure_css;
  	}  	
  	
  	public String getmeasurement_6() {
      String mvalue = grab_measurement(5);
  	  return mvalue;
  	}
  	
  	public String getmeasurement_6_css() {
      String mvalue = grab_measurement(5);
      String measure_css = grab_css(mvalue) + ' cc-perio-thumb' + tooth.name + '-6';            
  	  return measure_css;
  	}
  	
  	public String gettooth_direction() {
  	  if(tooth.tooth_integer__c>=1 && tooth.tooth_integer__c <= 16)
  	    return 'f';
  	  else
  	    return 'l';
  	}
  	
  	public String gettooth_image() {
  	  String image_css = '';
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
  	  return image_css;
  	}  	  	
  	
  	public String gettooth_label_css() {
  	  String label_css = 'cc-perio-teeth-number-label';
  	  if(tooth.decay__c)
  	    label_css += ' cc-perio-thumbToothDecay';
  	  return label_css; 
  	}
  }
  
  public void confirm_chart_reset() {  	
    confirmation_modal_display = true;
    confirmation_modal_type = 'chart_reset';
  	modal_out = 'You are about to reset all data for this perio chart';
  }
  
  public void close_confirmation_modal() {
  	confirmation_modal_display = false;
  }
  
  public void reset_perio_chart() {
  	//make sure we have a chart to reset
  	Date allowed_date = System.today().adddays(-2);
  	Integer perio_count = [select count() from Perio_Chart__c where account__c = :patient.id and createddate = :allowed_date];
  	if(perio_count>0) {
  	  try {
  	    Perio_Chart__c pchart = [select id from Perio_Chart__c where account__c = :patient.id and createddate = :allowed_date order by createddate desc limit 1];
  	    List<Perio_Chart_Tooth__c> all_teeth = [select id from Perio_Chart_Tooth__c where perio_chart__c = :pchart.id];
  	    delete all_teeth;
  	    delete pchart;
  	    create_new_perio_chart();
  	    confirmation_modal_display = false;
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the chart.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}   	 
  }
  
  //method to create a new perio chart
  public void create_new_perio_chart() {
  	//check to see if there is a perio chart for the current day...if so throw an error
  	Date allowed_date = System.today().adddays(-2);
  	Integer perio_count = [select count() from Perio_Chart__c where account__c = :patient.id and createddate >= :allowed_date];
  	if(perio_count>0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Patient already has an active perio chart for today'));
  	}  	
  	else {
  	  //create the perio chart record
  	  try {
  	    Perio_Chart__c pchart = new Perio_Chart__c(account__c = patient.id);  
  	    insert pchart;
  	    List<Perio_Chart_Tooth__c> new_teeth = new List<Perio_Chart_Tooth__c>();		
  	    //check to see if this patient has done a perio chart previously
  	    perio_count = [select count() from Perio_Chart__c where account__c = :patient.id and id != :pchart.id];
  	    if(perio_count>0) {
  	      //if they have,  copy the previous tooth types attributes (except for measurements)
  	      //get the id for the most recent perio chart
  	      Perio_Chart__c last_chart = [select id,createddate from Perio_Chart__c where id != :pchart.id and account__c = :patient.id order by createddate desc limit 1];
  	      //System.debug('Last Chart : ' + last_chart);  	      
  	      //pull the teeth for that chart and do a clone of them
  	      List<Perio_Chart_Tooth__c> last_teeth = [Select p.Tooth_Type__c, p.Name, p.Measurement__c, p.Endo__c, p.Decay__c,p.perio_chart__c From Perio_Chart_Tooth__c p where perio_chart__c = :last_chart.id];
  	      new_teeth = last_teeth.deepclone();  	        	      
  	      //work through the cloned set and put the measurements to a default state
  	      for(Perio_Chart_Tooth__c tooth : new_teeth) {
  	      	//System.debug('Cloned tooth : ' + tooth);
  	      	tooth.perio_chart__c = pchart.id;
  	      	tooth.measurement__c = 'null,null,null,null,null,null';
  	      }
  	    } else {  	    	  
  	      //otherwise load default teeth settings - Natural,  no decay/endo,  null measurements
  	      for(Integer t = 1;t<=32;t++) {
  	        Perio_Chart_Tooth__c tooth = new Perio_Chart_Tooth__c(perio_chart__c = pchart.id, name = String.valueof(t), decay__c = false, endo__c = false, measurement__c = 'null,null,null,null,null,null', tooth_type__c = 'Natural');
  	        new_teeth.add(tooth);
  	      }
  	    }  	    
  	    insert new_teeth;
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to create a new perio chart for the patient.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
    
  //method to pull array of perio charts for this patient
  public perio_exam[] getpatient_charts() {
  	Map<Id,Perio_exam> perio_map = new Map<Id,perio_exam> {};
  	//pull a list of charts
  	for(Perio_Chart__c pc : [select id,createddate,comments__c,createdbyid,createdby.name,
  	  (Select OCS_Swelling__c, OCS_Swelling_Location__c, OCS_Other__c, OCS_Other_Text__c, OCS_Lymph__c, OCS_Lymph_Location__c, OCS_Asymmetry__c, OCS_Asymmetry_Location__c, recession_notes__c,
  	    R_Upon_Opening_ROM__c, R_Upon_Closing_ROM__c, L_Upon_Opening_ROM__c, L_Upon_Closing_ROM__c, Restorative_Prognosis__c,at_rest__c,in_motion__c,lip_length__c,lip_fullness__c,tissue_color__c,
  	    tissue_consistency__c,tissue_texture__c,crepitus__c,deviations__c,muscles_of_mastication_WNL__c,chief_complaint__c,temperature__c,condition__c,TMJ_Notes__c, Height_Inches__c, 
  	    Height_Feet__c, Hard_Soft_Max_RRR__c, Hard_Soft_Mand_RRR__c, Comments__c, BMI_Calc__c, BMI__c,Existing_Prosth_Max_Type__c, Existing_Prosth_Mand_Type__c, Id, OwnerId, IsDeleted, Name, CreatedDate, 
  	    CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, BP_Systolic__c, BP_Diastolic__c, Pulse__c, Pulse_Ox__c, Weight__c, TMJ_stable_wnl__c, TMJ_pop_click_right__c, 
  	    TMJ_pop_click_left__c, TMJ_max_opening__c, Periodontal_Type__c, Tissue_Max__c, Tissue_Mand__c, Hard_Soft_WNL__c, Hard_Soft_RRR__c, Recession__c, OCS_Neg__c, OCS_Pos__c, Occlusion_Dental__c, 
  	    Occlusion_Skeletal__c, Occlusion_Plane__c, Occlusion_Hyper_Eruption__c, Occlusion_Attrition__c, Occlusion_OJ__c, Occlusion_OB__c, Existing_Pros_Max__c, Existing_Prosth_Mand__c, 
  	    Dentofacial_WNL__c, Dentofacial_Max_Direction__c, Dentofacial_Max_Amount__c, Dentofacial_Mand_Direction__c, Dentofacial_Mand_Amount__c, Smile_Line__c, Radiology_WNL__c, Radiology_Other__c,
  	     Mobility__c, AO4_Bone_Reduction_Max__c, AO4_bone_Reduction_Mand__c, Bone_Loss__c, Bone_Loss_Percent__c, Bone_Loss_Area__c, Tooth_Shade__c, Tooth_Mould__c, Account__c, Perio_Chart__c, isactive__c,
  	     Tissue_Notes__c, Mobility_Notes__c, Range_of_Motion__c, smile_line_notes__c, Surgical_Reduction_Notes__c, Bone_Loss_Notes__c, Reported_Bruxism__c, Evidence_of_Bruxism__c, dry_mouth__c, salivary_other__c,
  	     abrasion_location__c, abrasion_severity__c, attrition_location__c, attrition_severity__c, erosion_location__c, erosion_severity__c, Physiological_location__c, Physiological_severity__c,
  	     tooth_surface_notes__c, how_long_missing_teeth__c, fmx__c, icat__c, panorex__c, photographs__c, image_notes__c, impressions__c, facebow__c, Centric_Relation_Record__c, records_notes__c, Tooth_Shade_Other__c
  	    From Prosth_Exam_Forms__r where isactive__c = true)  
  	    from Perio_Chart__c where account__c = :patient.id order by createddate desc]) {
  	  perio_exam exam = new perio_exam(pc);
  	  if(pc.prosth_exam_forms__r.size()>0) {
  	    exam.pform = pc.prosth_exam_forms__r[0];
  	    System.debug('Should have a perio form');
  	  }
  	  perio_map.put(pc.id,exam);  	    	    
  	}  	
  	//pull all tooth records tied to these exams - 1-16
  	for(Perio_Chart_Tooth__c pct : [Select p.Tooth_Type__c, p.Tooth_Integer__c, p.Perio_Chart__c, p.Name, p.Measurement__c, p.Endo__c, p.Decay__c From Perio_Chart_Tooth__c p where p.perio_chart__c in :perio_map.keyset() and tooth_integer__c >=1 and tooth_integer__c <= 16 order by tooth_integer__c]) {
      perio_exam_tooth tooth = new perio_exam_tooth(pct);
      perio_map.get(pct.perio_chart__c).upper_teeth.add(tooth);  		
  	}
  	//17-32 - reverse order
  	for(Perio_Chart_Tooth__c pct : [Select p.Tooth_Type__c, p.Tooth_Integer__c, p.Perio_Chart__c, p.Name, p.Measurement__c, p.Endo__c, p.Decay__c From Perio_Chart_Tooth__c p where p.perio_chart__c in :perio_map.keyset() and tooth_integer__c >=17 and tooth_integer__c <= 32 order by tooth_integer__c desc]) {
      perio_exam_tooth tooth = new perio_exam_tooth(pct);
      perio_map.get(pct.perio_chart__c).lower_teeth.add(tooth);  		
  	}  	  	
  	current_charts = perio_map.values();
  	return perio_map.values();
  }
  
  public Integer getchart_count() {
  	Integer ccount = 0;
  	try {
      ccount = [select count() from Perio_Chart__c where  account__c = :patient.id];
  	} catch (Exception e) {
  	  
  	}
  	return ccount;
  }  
  
  public void update_perio_chart() {
  	String pass_thru = apexpages.currentpage().getparameters().get('pthru');
  	pass_thru = pass_thru.replace('"number"','"tnumber"');
  	System.debug('pthru : ' + pass_thru);  	
  	parseJSONString(pass_thru);
  	List<Perio_Chart__c> pc_list = new List<perio_Chart__c> ();
  	for(Perio_Exam pe : current_charts) {
  	  pc_list.add(pe.pchart);  	  
  	}
  	if(pc_list.size()>0) {
  	  try {
  	    update pc_list;  	    
  	  } catch (Exception e) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save the chart.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public class tooth_test {
  	public Integer tnumber;
  	public String typeOf;
  	public String[] measure;
  	public Boolean endo;
  	public Boolean decay; 
  	
  	public tooth_test(Integer t, String tof, String[] m, Boolean e, Boolean d) {
  	  tnumber = t;
  	  typeOf = tof;
  	  measure = m;
  	  endo = e;
  	  decay = d;
  	}
  }
  
  public void parseJSONString(String jsonStr) {            
    //String jsonStr = '[{"tnumber":1,"typeOf":"Natural","measure":[1,2,3,null,null,null],"endo":false,"decay":false},    {"tnumber":2,"typeOf":"Natural","measure":[4,5,6,null,null,null],"endo":false,"decay":false},    {"tnumber":3,"typeOf":"Natural","measure":[7,8,9,null,null,null],"endo":false,"decay":false},    {"tnumber":4,"typeOf":"Natural","measure":[1,2,3,null,null,null],"endo":false,"decay":false},    {"tnumber":5,"typeOf":"Natural","measure":[4,5,3,null,null,null],"endo":false,"decay":false},    {"tnumber":6,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":7,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":8,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":9,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":10,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":11,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":12,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":13,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":14,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":15,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":16,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":17,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":18,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":19,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":20,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":21,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":22,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":23,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":24,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":25,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":26,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":27,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":28,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":29,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":30,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":31,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":32,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false}]';   
    //grab the current perio chart we're working on    
    //adjusted this to support allowing edits beyond the 
    Date allowed_date = System.today().adddays(-2);
    Perio_Chart__c pc = [select id from Perio_Chart__c where account__c = :patient.id and createddate >= :allowed_date order by createddate desc limit 1];
    Map<Integer,Perio_Chart_Tooth__c> tooth_map = new Map<Integer,Perio_Chart_Tooth__c>();
    for(Perio_Chart_Tooth__c pct : [Select p.Tooth_Type__c, p.Tooth_Integer__c, p.Perio_Chart__c, p.Name, p.Measurement__c, p.Endo__c, p.Decay__c, p.id From Perio_Chart_Tooth__c p where perio_chart__c = :pc.id]) {
      tooth_map.put(pct.tooth_integer__c.intvalue(),pct);
    }            
    
    // Parse entire JSON response.
    JSONParser parser = JSON.createParser(jsonStr);
    while (parser.nextToken() != null) {
        // Start at the array of invoices.
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            while (parser.nextToken() != null) {
                // Advance to the start object marker to
                //  find next invoice statement object.
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    // Read entire invoice object, including its array of line items.
                    tooth_test t = (tooth_test)parser.readValueAs(tooth_test.class);
                    system.debug('tooth number: ' + t.tnumber);                    
                    system.debug('Measurements: ' + t.measure);
                    system.debug('Endo: ' + t.endo);
                    system.debug('Decay: ' + t.decay);   
                    system.debug('tooth number: ' + t.typeOf);
                    //grab the tooth record and update it
                    String measure_value = '';
                    for(String s : t.measure) {
                      measure_value += s + ',';
                    }
                    measure_value = measure_value.left(measure_value.length()-1);
                    system.debug('Parsed Measurements: ' + measure_value);
                    tooth_map.get(t.tnumber).tooth_type__c = t.typeof;
                    tooth_map.get(t.tnumber).measurement__c = measure_value;
                    tooth_map.get(t.tnumber).endo__c = t.endo;
                    tooth_map.get(t.tnumber).decay__c = t.decay;       
                    System.debug('Tooth : ' + tooth_map.get(t.tnumber));                                 
                    // Skip the child start array and start object markers.
                    //parser.skipChildren();
                }
            }
        }
    }
    try {
      List<Perio_Chart_Tooth__c> tlist = tooth_map.values();
      update tlist;
    } catch (Exception e) {
      	
    }
  }
  
  public void display_new_prosth_exam_form() {
  	try {
  	  Perio_Chart__c current_chart = [select id, account__c from Perio_Chart__c where id = :apexpages.currentpage().getparameters().get('pcid')];
  	  //make sure we don't already have a chart here
  	  Integer form_count = [select count() from Prosth_Exam_Form__c where isactive__c = true and perio_chart__c = :current_chart.id];
  	  if(form_count==0) {  	  
  	    Prosth_Exam_Form__c pf = new Prosth_Exam_Form__c(account__c = current_chart.account__c, perio_chart__c = current_chart.id, isactive__c = true);
  	    insert pf;
  	  }
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the Prosth Exam Info.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void reset_prosth_exam_form() {
  	try {
  	  Perio_Chart__c current_chart = [select id, account__c from Perio_Chart__c where id = :apexpages.currentpage().getparameters().get('pcid')];
  	  Prosth_Exam_Form__c old_form = [select id,isactive__c from Prosth_Exam_Form__c where isactive__c = true and perio_chart__c = :current_chart.id];
  	  old_form.isactive__c = false;
  	  update old_form;
  	  Prosth_Exam_Form__c pf = new Prosth_Exam_Form__c(account__c = current_chart.account__c, perio_chart__c = current_chart.id, isactive__c = true);
  	  insert pf;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reset the Prosth Exam Info.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  	
  }
  
  public void delete_prosth_exam_form() {
  	try {
  	  Perio_Chart__c current_chart = [select id, account__c from Perio_Chart__c where id = :apexpages.currentpage().getparameters().get('pcid')];
  	  Prosth_Exam_Form__c old_form = [select id from Prosth_Exam_Form__c where isactive__c = true and perio_chart__c = :current_chart.id];
  	  old_form.isactive__c = false;
  	  update old_form;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to delete the Prosth Exam Info.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  
  public void change_prosth_exam_boolean() {
  	/*Prosth_Exam_form__c pf = [select  p.isactive__c, p.Weight__c, p.Tooth_Shade__c, p.Tooth_Mould__c, p.Tissue_Max__c, p.Tissue_Mand__c, p.TMJ_stable_wnl__c, p.TMJ_pop_click_right__c, p.TMJ_pop_click_left__c, p.TMJ_max_opening__c, p.SystemModstamp, p.Smile_Line__c, p.Recession__c, p.Radiology_WNL__c, p.Radiology_Other__c, p.Pulse__c, p.Pulse_Ox__c, p.Periodontal_Type__c, p.Perio_Chart__c, p.OwnerId, p.Occlusion_Skeletal__c, p.Occlusion_Plane__c, p.Occlusion_OJ__c, p.Occlusion_OB__c, p.Occlusion_Hyper_Eruption__c, p.Occlusion_Dental__c, p.Occlusion_Attrition__c, p.OCS_Pos__c, p.OCS_Neg__c, p.Name, p.Mobility__c, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.Hard_Soft_WNL__c, p.Hard_Soft_RRR__c, p.Existing_Prosth_Max_Type__c, p.Existing_Prosth_Mand__c, p.Existing_Prosth_Mand_Type__c, p.Existing_Pros_Max__c, p.Dentofacial_WNL__c, p.Dentofacial_Max_Direction__c, p.Dentofacial_Max_Amount__c, p.Dentofacial_Mand_Direction__c, p.Dentofacial_Mand_Amount__c, p.CreatedDate, p.CreatedById, p.Bone_Loss__c, p.Bone_Loss_Percent__c, p.Bone_Loss_Area__c, p.BP_Systolic__c, p.BP_Diastolic__c, p.Account__c, p.AO4_bone_Reduction_Mand__c, p.AO4_Bone_Reduction_Max__c
  	  from Prosth_Exam_form__c p where id = :apexpages.currentpage().getparameters().get('pfid')];*/  	  
  	String fname = apexpages.currentpage().getparameters().get('fieldname');  	  
  	//work through current evals
  	String pe_id =  apexpages.currentpage().getparameters().get('pfid');
  	for(perio_exam pe : current_charts) {
  	  if(pe.pform!=null) {
  	  	if(pe.pform.id==pe_id && pe.getperio_editable()) {
  	  	  Boolean current_val = (Boolean)pe.pform.get(fname);
		  Boolean new_val = false;
		  if(current_val==null)
		    new_val = true;
		  else if(!current_val)
		    new_val = true;
		  else if(current_val)
		    new_val = false;
  	  	  pe.pform.put(fname,new_val);
  	  	  update pe.pform;
  	  	}
  	  }
  	}
  	//pf.put(fname,new_val);
  }
    
  public void change_prosth_exam_text() {
  	String fname = apexpages.currentpage().getparameters().get('fieldname');
  	String new_val = apexpages.currentpage().getparameters().get('fieldvalue');
  	//Prosth_Exam_form__c pf = [select id from Prosth_Exam_form__c where id = :apexpages.currentpage().getparameters().get('pfid')];
  	String pe_id =  apexpages.currentpage().getparameters().get('pfid');
  	System.debug('Field Name :' + fname);
  	System.debug('Field Value :' + new_val);
  	for(perio_exam pe : current_charts) {
  	  if(pe.pform!=null) {
  	  	if(pe.pform.id==pe_id && pe.getperio_editable()) {  	  	    	 
  	  	  pe.pform.put(fname,new_val);
  	  	  update pe.pform;
  	  	}
  	  }
  	}
  	  	
  	//pf.put(fname,new_val);
  } 
  
  public void save_prosth_exam_form() {
  	String pe_id =  apexpages.currentpage().getparameters().get('pfid');
  	for(perio_exam pe : current_charts) {
  	  if(pe.pform!=null) {
  	  	if(pe.pform.id==pe_id) {
  	  	  Prosth_exam_form__c pf = pe.pform;
  	  	  update pf;
  	  	  //update height/weight on patient record - grab the most recent set of values that were filled out
  	      if(pf.height_feet__c!=null && pf.height_inches__c!=null) {
  	        System.debug('Updating Height');
  	        Account a = [select recent_height_feet__c,recent_height_inches__c,recent_weight__c from Account where id = :patient.id];
  	        a.recent_height_feet__c = pf.height_feet__c;
  	        a.recent_height_inches__c = pf.height_inches__c;
  	        a.recent_weight__c = pf.weight__c;
  	        update a;
  	      }
  	  	}
  	  }
  	}
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
}