public with sharing class dp_clinical_calendar { 
  public dp_clinical_cmonth cmonth {get;set;}
  public String modal_calendar_view {get;set;}
  public Boolean display_calendar_view {get;set;}
  public String column_override_css {get;set;}
  
  public Center_Information__c current_center {get; set;}
  public Boolean display_corp_admin {get; set;}
  
  public String room_type {get; set;}
  public String cancel_reason {get; set;}
  public Date current_date {get; set;}
  public String calendar_view {get; set;}
  public Clinical_Apt_Calendar__c apt_block {get; set;}
  
  public ID last_apt_id {get; set;}
  public String doctor_filter {get;set;}
  
  public Boolean display_calendar_modal {get; set;}
  public String calendar_modal_display {get; set;}
  //switch to a calendar apt object so info is available and updates can be done on it.
  
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
  
  //map showing valid cells for manual scheduling
  public Map<ID,Set<Integer>> possible_block_map {get; set;}  
  public Patient_POT_Apt__c manual_apt {get; set;}
  public Boolean manual_search {get; set;}
  public Set<Integer> manual_block_size {get; set;}
  
  //vars for manual scheduling process
  public String msearch_doctor {get; set;}
  public String msearch_hour {get; set;}
  public String msearch_minute {get; set;}
  public String msearch_suffix {get; set;}
  public String modal_css {get; set;}
  public Boolean display_msearch_modal {get; set;}
  public String msearch_room {get; set;}
  public List<manual_doctor_results> doc_results {get;set;}
  
  //doctor block stuff
  public Boolean display_doctor_block_modal {get; set;}
  public Clinical_Time_Restriction__c new_time_block {get; set;}
  public String block_view {get; set;}
  public String current_tab_id {get; set;}
  public String current_edit_id {get; set;}
  public String sprefix {get; set;}
  public String eprefix {get; set;}
  public Boolean display_conflicts_modal {get; set;}
  public Boolean display_room_block_modal {get; set;}
  public Boolean display_pending_resched_modal {get; set;}
  public String shour_holder {get; set;}
  public String ehour_holder {get; set;}
  public List<Clinical_Apt_Calendar__c> resched_list;
  
  public Boolean confirmation_modal_display {get; set;}    
  public Boolean display_confirmation_modal {get; set;}
  public String modal_type {get; set;}
  public String modal_out {get; set;}
  
  public Weather__c current_weather {get;set;}
  public Map<Date,Weather__c> current_week_weather_map {get; set;}
  
  //calendar note stuff
  public Boolean display_note_modal {get; set;}
  public Clinical_Calendar_Note__c cal_note {get; set;}
  
  public Patient_POT_Apt__c sched_apt {get; set;}
  
  public Boolean display_room_restrictions {get; set;}
  public Boolean display_open_blocks {get; set;}
  
  public Boolean display_clipboard {get; set;}
  
  public String new_apt_name {get; set;}
  public String apt_filter {get; set;}
  public Boolean display_apt_change {get; set;}
  
  public dp_clinical_patient.paged_results search_pager {get;set;}
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  //static User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name from user where id =:userinfo.getUserId()];
  
  static Organization org = [select id,instancename from organization limit 1];
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
    
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}   
  
  public class bendException extends Exception {}
  
  Boolean print_display;	  
	  
  public dp_clinical_calendar() {
  	display_apt_change = false;
  	display_room_restrictions = true;
  	display_open_blocks = true;
  	//User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];     
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
            
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,bypass_clipboard_confirmation__c,clinical_start_hour__c,clinical_end_hour__c,Manual_Sched_Auto_Reduction__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,bypass_clipboard_confirmation__c,clinical_start_hour__c,clinical_end_hour__c,Manual_Sched_Auto_Reduction__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,bypass_clipboard_confirmation__c,clinical_start_hour__c,clinical_end_hour__c,Manual_Sched_Auto_Reduction__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   	  	  	  	  	
  	//check to see if room type was set - else default it
  	try {
  	  if(apexpages.currentpage().getparameters().get('rtype')==null) {
  	    room_type = 'Prosth';
  	    if(u.default_calendar_room__c!=null)
  	      room_type = u.default_calendar_room__c;
  	  }
  	  else
  	    room_type = apexpages.currentpage().getparameters().get('rtype');
  	} catch (Exception e) {
  	  room_type = 'Prosth';
  	}
  	calendar_view = 'Day';
  	if(u.default_calendar_view__c!=null)
  	  calendar_view = u.default_calendar_view__c;
  	//check to see if calendar date was set - else default to today
  	current_date = System.today();
  	if(apexpages.currentPage().getParameters().get('cdate')!=null)
  	  current_date = Date.parse(apexpages.currentpage().getparameters().get('cdate'));  	  	
  	//try {
  	current_weather = getweather_info(current_date); 
  	  
  	  /*[Select w.Temp_Low__c, w.Temp_High__c, w.SystemModstamp, w.Snow_Night__c, w.Snow_Day__c, w.Snow_AllDay__c, w.Skyicon__c, w.QPF_Night__c, w.QPF_Day__c, w.QPF_Allday__c, w.POP__c, w.OwnerId, w.Name, w.Min_Humidity__c, w.Max_Wind__c, w.Max_Humidity__c, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.Icon__c, w.Icon_URL__c, w.Data_Type__c, w.CreatedDate, w.CreatedById, w.Conditions__c, w.Center_Information__c, w.Calendar_Date__c, w.Avg_Wind__c, w.Avg_Humidity__c  
  	    From Weather__c w
  	    where center_information__c = :current_center.id and calendar_date__c = today order by createddate desc limit 1];*/
  	//} catch (Exception e) {}
  	//current_date = Date.newinstance(2016,7,1);
  	
  	//see if it's a corporate admin  	
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  	//modified by cm on 2/28/2017 - Finance added for audit purposes  	
  	/*Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;*/
  	
  	manual_search = false;
  	try {
  	  if(apexpages.currentpage().getparameters().get('maptid')!=null) {
  	    manual_apt = [Select p.id, p.Sort_Order__c, p.Patient_POT__c, p.patient_pot__r.account__r.name, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, 
  	      p.Clinical_Appointment__c, p.clinical_appointment__r.name, p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c
  	    From Patient_POT_Apt__c p
  	    where id = :apexpages.currentpage().getparameters().get('maptid')];
  	 
  	   //make sure this hasn't been scheduled
  	    List<Clinical_Apt_Calendar__c> past_apts = [select id,apt_date__c,apt_status__c from Clinical_Apt_Calendar__c where Patient_POT_Apt__c = :manual_apt.id order by apt_date__c desc];  	    
  	    if(past_apts.size()>0) {
  	      //look at the last apt and see if the status was null (and in the past) or no show.  If it's not either of those,  do not allow manual sched
  	      if(past_apts[0].apt_status__c==null && past_apts[0].apt_date__c < System.today())
  	        manual_search = true;
  	      else if(past_apts[0].apt_status__c=='No Show')
  	        manual_search = true;
  	    } else
  	      manual_search = true; 	     	  
  	      
  	  
  	    //keep this from running on every refresh of the page
  	    if(possible_block_map==null) {
  	      //change current date if necessary
  	      if(manual_apt.sort_order__c!=1) {
  	        //we need to look at the apt date for the previous apt in the plan of treatment...then add days out to it to get our filter
  	        Integer prior_sort = manual_apt.sort_order__c.intValue() - 1;
  	        //modified by cm on 10/3/2017 - we're now looking for the first prior appointment that is NOT a repair
  	        //Patient_POT_Apt__c prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c
  	          //where sort_order__c = :prior_sort and patient_pot__c = :manual_apt.patient_pot__c and isactive__c = true];
  	        Patient_POT_Apt__c prior_apt;
  	        try {
  	          prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c
  	            where sort_order__c <= :prior_sort and patient_pot__c = :manual_apt.patient_pot__c and isactive__c = true
  	            and clinical_appointment__r.isrepair__c = false order by sort_order__c desc limit 1];
  	        } catch (Exception e) {
  	          //this would occur,  if all of the prior apts happen to be repair (private practice / legacy import situation)
  	          prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c
  	            where sort_order__c <= :prior_sort and patient_pot__c = :manual_apt.patient_pot__c and isactive__c = true
  	            order by sort_order__c desc limit 1];
  	        }
  	        try {
  	          current_date = prior_apt.clinical_apt_calendar__r[0].apt_date__c;
  	          current_date = current_date.addDays(manual_apt.days_out__c.intvalue());
  	          if(current_date < System.today())
  	            current_date = System.today();
  	          current_weather = getweather_info(current_date);
  	        } catch (Exception e) {
  	  	      //if this is null,  it means we had no date for the previous apt in the chain....that's an issue - use today.
  	  	    
    	    }
  	      }
  	      refresh_possible_map();
  	    }
  	  }
  	} catch (Exception e) {/*using in a non visualforce instance*/}
  	display_calendar_modal = false;
  	display_msearch_modal = false;
  	display_confirmation_modal = false;
  	confirmation_modal_display = false;
  	display_doctor_block_modal = false;
  	display_conflicts_modal = false;
  	display_room_block_modal = false;
  	display_pending_resched_modal = false;
  	display_note_modal = false;
    display_calendar_view = false;
    display_clipboard = true;
    modal_calendar_view = 'calendar';
    column_override_css = '';
    print_display = false;
    search_pager = new dp_clinical_patient.paged_results();
    if(apexpages.currentpage().getparameters().get('pdisplay')!=null)
      print_display = true;    
  }  
   
  public Weather__c getweather_info(Date weather_date) {
  	try {
      //handle week map
      current_week_weather_map = new Map<Date,Weather__c>();
      Date sdate = current_date.tostartofweek();
      Date edate = sdate.adddays(7);
      //loop through weather records for the week....map first appearance - sorted by createddate desc to get only the most recent
      for(Weather__c w : [Select w.Temp_Low__c, w.Temp_High__c, w.SystemModstamp, w.Snow_Night__c, w.Snow_Day__c, w.Snow_AllDay__c, w.Skyicon__c, w.QPF_Night__c, w.QPF_Day__c, w.QPF_Allday__c, w.POP__c, w.OwnerId, w.Name, w.Min_Humidity__c, w.Max_Wind__c, w.Max_Humidity__c, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.Icon__c, w.Icon_URL__c, w.Data_Type__c, w.CreatedDate, w.CreatedById, w.Conditions__c, w.Center_Information__c, w.Calendar_Date__c, w.Avg_Wind__c, w.Avg_Humidity__c  
  	    From Weather__c w
  	    where center_information__c = :current_center.id and calendar_date__c >= :sdate and calendar_date__c <= :edate 
  	    order by createddate desc])  {
  	    if(current_week_weather_map.get(w.calendar_date__c)==null)
  	      current_week_weather_map.put(w.calendar_date__c,w);  	
  	  }  		
  	  return [Select w.Temp_Low__c, w.Temp_High__c, w.SystemModstamp, w.Snow_Night__c, w.Snow_Day__c, w.Snow_AllDay__c, w.Skyicon__c, w.QPF_Night__c, w.QPF_Day__c, w.QPF_Allday__c, w.POP__c, w.OwnerId, w.Name, w.Min_Humidity__c, w.Max_Wind__c, w.Max_Humidity__c, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.Icon__c, w.Icon_URL__c, w.Data_Type__c, w.CreatedDate, w.CreatedById, w.Conditions__c, w.Center_Information__c, w.Calendar_Date__c, w.Avg_Wind__c, w.Avg_Humidity__c  
  	    From Weather__c w
  	    where center_information__c = :current_center.id and calendar_date__c = :weather_date 
  	    order by createddate desc limit 1];
  	} catch (Exception e) {
  	  return null;
  	}
  }
  
  public String getselected_day_of_week() {  	
  	return Datetime.newinstance(current_date,Time.newinstance(0,0,0,0)).format('EEEE');
  }
  
  public class menu_item {
  	public String menu_name {get;set;}
  	public String menu_type {get; set;}
  	public String menu_nav_color {get;set;}
  	public String menu_id {get;set;}
  	public String menu_css {get;set;}
  	
  	public menu_item(String mname, String mtype, String mcolor, String mid, String mcss) {
  	  this.menu_name = mname;
  	  this.menu_type = mtype;
  	  this.menu_nav_color = mcolor;
  	  this.menu_id = mid;
  	  this.menu_css = mcss;
  	} 
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
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,bypass_clipboard_confirmation__c,clinical_start_hour__c,clinical_end_hour__c,Manual_Sched_Auto_Reduction__c,Use_Alternate_Url__c,Use_Alternate_Calendar_URL__c  from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  manual_search = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public PageReference navigate_to_recent_patient() {  	  	
    return common_header.pref_to_patient(current_center,apexpages.currentpage().getparameters().get('recentid'));  	  	
  }  
  
  public PageReference navigate_to() {
  	PageReference pr;
  	if(apexpages.currentpage().getparameters().get('navid')!=null) {
  	  try {
  	  	pr = common_header.pref_navid(current_center,apexpages.currentpage().getparameters().get('navid'));  	  	
  	    if(last_apt_id!=null) {  	   
  	      Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Id, c.Account__c From Clinical_Apt_Calendar__c c where id=:last_apt_id];
  	      pr.getParameters().put('ptid',ca.account__c);
  	      //toss patient into recent list as well
  	      try {
  	        Account act = [select id from Account where id = :ca.account__c];
  	        PageReference aPage = new ApexPages.StandardController(act).view();
  	         if(!Test.isRunningTest())
               aPage.getContent();
  	      } catch (Exception e) {}
  	    } else {
  	      if(apexpages.currentpage().getparameters().get('ptid')!=null)
  	        pr.getParameters().put('ptid',apexpages.currentpage().getparameters().get('ptid'));   
  	    }  	      	      
  	    return pr;  	  	
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change pages.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  	return null;
  	  }
  	}
  	return pr;
  }  
  
  public List<Selectoption> getroom_type_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('Prosth','Prosth'));
  	clist.add(new Selectoption('Surgery','Surgery'));
  	clist.add(new Selectoption('Recovery','Recovery'));
  	clist.add(new Selectoption('Hygiene','Hygiene'));
  	clist.add(new Selectoption('PSCombo','Prosth + Surgery'));
	return clist;
  }
  
  public List<Selectoption> getroom_block_reason_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('Staffing','Staffing'));
  	clist.add(new Selectoption('Maintenance','Maintenance'));
  	clist.add(new Selectoption('Clean Up','Clean Up'));
  	clist.add(new Selectoption('Training','Training'));
  	clist.add(new Selectoption('Patient Hold','Patient Hold'));
  	clist.add(new Selectoption('Private Practice Patient','Private Practice Patient'));
  	clist.add(new Selectoption('Private Practice Patient LA','Private Practice Patient LA'));
  	clist.add(new Selectoption('Private Practice Patient IV','Private Practice Patient IV'));
  	clist.add(new Selectoption('Lunch','Lunch'));
  	clist.add(new Selectoption('Vacation','Vacation'));
  	clist.add(new Selectoption('Other','Other'));
	return clist;
  }
  
  public List<Selectoption> getdoctor_block_reason_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('Personal Conflict','Personal Conflict'));
  	clist.add(new Selectoption('Clinical Conflict','Clinical Conflict'));
  	clist.add(new Selectoption('Emergency','Emergency'));
  	clist.add(new Selectoption('Sick','Sick'));
  	clist.add(new Selectoption('Training','Training'));
  	clist.add(new Selectoption('Private Practice Patient','Private Practice Patient'));
  	clist.add(new Selectoption('Lunch','Lunch'));
  	clist.add(new Selectoption('Vacation','Vacation'));
  	clist.add(new Selectoption('Other','Other'));
	return clist;
  }  
  
  public void change_calendar_view() {  	
  	try {
  	  calendar_view = apexpages.currentpage().getparameters().get('cview');
  	  if(calendar_view==null)
  	     throw new bendException('No active value was detected');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change the calendar view.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public String gettotal_lab_css() {
  	String lab_css = '';
  	Decimal lab_time = 0;
  	Integer day_factor;
  	//to-do - set this up as a query
  	if(calendar_view=='Day') {
  	  AggregateResult ar = database.query('select sum(patient_pot_apt__r.lab_time__c) lab_time from clinical_apt_calendar__c where apt_date__c = :current_date and clinical_room__r.center_information__c = \'' + current_center.id + '\'');
  	  if((decimal)ar.get('lab_time')!=null)
  	    lab_time = (decimal)ar.get('lab_time');
  	  day_factor = 1;
  	}
  	if(calendar_view=='Week') {
  	  Set<Date> all_days = new Set<Date>();
  	  Date week_start = current_date.toStartOfWeek();
  	  for(Integer i=0;i<7;i++) {
  	  	all_days.add(week_start);
  	  	week_start = week_start.addDays(1);
  	  	day_factor = 4;
  	  }
  	  //go to start of the week and then work through all of it  	    	  
  	  AggregateResult ar = database.query('select sum(patient_pot_apt__r.lab_time__c) lab_time from clinical_apt_calendar__c where apt_date__c in :all_days and clinical_room__r.center_information__c = \'' + current_center.id + '\'');
  	  if((decimal)ar.get('lab_time')!=null)
  	    lab_time = (decimal)ar.get('lab_time');
  	}
  	//calculate thresholds...yellow would be 75-85% of center number of lab techs * 555
  	Decimal green_top = (current_center.number_of_lab_techs__c * 555 * day_factor) * .75;
  	Decimal yellow_top = (current_center.number_of_lab_techs__c * 555 * day_factor) * .85;
  	if(lab_time < green_top)
      lab_css = 'green';
    else if(lab_time < yellow_top)
      lab_css = 'orange';
    else
      lab_css = 'red';  	  	
   	return lab_css;
  }
  
  public String gettotal_lab_time() {
  	Decimal lab_time = 0;
  	//to-do - set this up as a query
  	if(calendar_view=='Day') {
  	  AggregateResult ar = database.query('select sum(patient_pot_apt__r.lab_time__c) lab_time from clinical_apt_calendar__c where apt_date__c = :current_date and clinical_room__r.center_information__c = \'' + current_center.id + '\'');
  	  if((decimal)ar.get('lab_time')!=null)
  	    lab_time = (decimal)ar.get('lab_time');
  	}
  	if(calendar_view=='Week') {
  	  Set<Date> all_days = new Set<Date>();
  	  Date week_start = current_date.toStartOfWeek();
  	  for(Integer i=0;i<7;i++) {
  	  	all_days.add(week_start);
  	  	week_start = week_start.addDays(1);
  	  }
  	  //go to start of the week and then work through all of it  	    	  
  	  AggregateResult ar = database.query('select sum(patient_pot_apt__r.lab_time__c) lab_time from clinical_apt_calendar__c where apt_date__c in :all_days and clinical_room__r.center_information__c = \'' + current_center.id + '\'');
  	  if((decimal)ar.get('lab_time')!=null)
  	    lab_time = (decimal)ar.get('lab_time');
  	}
  	Decimal lhours = math.floor(lab_time.intvalue()/60);
   	Integer lminutes = math.mod(lab_time.intvalue(),60);
   	return String.valueof(lhours.intvalue()) + ' hrs ' + lminutes + ' min';
  }  
  
  public class weekly_calendar_sub_cell {
  	public String cell_css {get;set;}
  	public String cell_text {get;set;}
  	public Integer hour {get; set;}
  	public Integer minute {get; set;}  	 
  	public String container_css {get; set;} 
  	public ID apt_id {get; set;}
  	
  	public weekly_calendar_sub_cell(String ccss, String ctext, Integer h, Integer m, String container, ID block_id) {
  	  this.cell_css = ccss;
  	  this.cell_text = ctext;
  	  this.hour = h;
  	  this.minute = m;
  	  this.apt_id = block_id;
  	  this.container_css = container;
  	}
  }
  
  public class weekly_calendar_cell {
  	public String cell_css {get;set;}
  	public String cell_text {get;set;}
  	public Integer hour {get; set;}
  	public Integer minute {get; set;}
  	public weekly_calendar_sub_cell[] sub_cells {get; set;}  
  	public Boolean current_time {get; set;}	  
  	
  	public weekly_calendar_cell(String ccss, String ctext, Integer h, Integer m) {
  	  this.cell_css = ccss;
  	  this.cell_text = ctext;
  	  this.hour = h;
  	  this.minute = m;
  	  this.sub_cells = new weekly_calendar_sub_cell[] {};
  	  this.current_time = false;
  	}
  }
  
  public class weekly_calendar_column {
  	public String header_name {get; set;}
  	public weekly_calendar_cell[] all_cells {get; set;}
  	public Weather__c day_weather {get; set;}
  	
  	public weekly_calendar_column() {
  	  all_cells = new weekly_calendar_cell[] {};
  	}
  }
  
  public class clinical_calendar_cell {
  	public String cell_css {get;set;}
  	public String cell_text {get;set;}
  	public Boolean image_display {get;set;}
  	public String image_name {get;set;}
  	public Integer hour {get; set;}
  	public Integer minute {get; set;}
  	public Boolean display_tooltip {get; set;}
  	public Boolean display_photo_tooltip {get; set;}
  	public String tool_type {get; set;}
  	public String tool_title {get; set;}
  	public String tool_content {get; set;}
  	public String onclick_event {get; set;}
  	public String onmouseover_event {get; set;}
  	public String onmouseout_event {get; set;}
  	public Boolean current_time {get; set;}
  	//to-do: add attributes for apt block stuff here?
  	public Clinical_Apt_Calendar__c apt {get; set;}
  	public String confirmation_html {get; set;}
  	public String cell_style {get; set;}
  	public String top_css {get; set;}
  	  	
  	public clinical_calendar_cell(String ccss, String ctext, Boolean idisplay, String iname, Integer h, Integer m) {
  	  this.cell_css = ccss;
  	  this.cell_text = ctext;
  	  this.image_display = idisplay;
  	  this.image_name = iname;
  	  this.hour = h;
  	  this.minute = m;
  	  this.display_tooltip = false;
  	  this.display_photo_tooltip = false;
  	  this.tool_type = 'none';
  	  this.tool_title = 'Click to add a block';
  	  this.tool_content = 'na';
  	  this.onclick_event = 'return false;';
  	  this.current_time = false;
  	  this.confirmation_html = '';
  	  this.onmouseover_event = 'return false;';
  	  this.onmouseout_event = 'return false';
  	  this.cell_style = '';
  	  this.top_css = '';
  	}
  	
  	public Integer getcurrent_time() {
  	  return (hour*60) + minute;
  	}
  	
  	public boolean getdisplay_mobile() {
  	  if(apt.account__r.personmobilephone!=null)
  	    return true;
      else
        return false;  	    
  	}
  	
  	public String getpatient_name() {
  	  String pname = 'No Patient';
  	  try {
  	    if(apt.account__c!=null)
  	      pname = apt.account__r.firstname + ' ' + apt.account__r.lastname.left(1);
  	      //pname = apt.account__r.firstname.left(1) + ' ' + apt.account__r.lastname;
  	  } catch (Exception e) {
  	  	
  	  }
  	  return pname;
  	}
  	
  	public String gettime_from_int(Decimal time_val) {
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
  	
  	public String getapt_time() {
  	  String apt_time = '';
  	  if(apt!=null) {
  	    apt_time = gettime_from_int(apt.stime__c) + ' - ' + gettime_from_int(apt.etime__c);  	   
  	  }
  	  return apt_time;
  	}  
  	
  	public String getapt_status() {
  	  String status_name = '';
  	  if(apt!=null) {
  	  	if(apt.apt_status__c==null)
  	  	  status_name = 'Scheduled';
  	  	else
  	  	  status_name = apt.apt_status__c;
  	  }
  	  return status_name;
  	}
  	
  	public String getapt_name() {
  	  String aname = '';
  	  try {
  	    if(apt.patient_pot_apt__c!=null)
  	      aname = apt.patient_pot_apt__r.name;
  	  } catch (Exception e) {
  	  	
  	  }
  	  return aname;
  	}
  	
  	public String getdr_name() {
  	  String dname = '';
  	  try {
  	  	dname = apt.doctor__r.name;
  	  } catch (Exception e) {
  	  	
  	  }
  	  return dname;
  	}
  	
  	public String getstaff_name() {
  	  String sname = 'Place Holder';
  	  //to-do: figure out where staff name is stored and return it
  	  return sname;
  	}
  	
  	public String getpatient_city() {
  	  String pcity = '';
  	  try {
  	  	pcity = apt.account__r.billingcity;
  	  } catch (Exception e) {
  	  	
  	  }
  	  return pcity;
  	}
  	
  	public Boolean getdisplay_picture() {
  	  try {
  	  	if(apt.account__r.main_photo_id__c!=null)
  	      return true;
  	    else
  	      return false;
  	  } catch (Exception e) {
  	  	return false;
  	  }  	  
  	}
  	
  	public String gethistory_count() {
  	  //don't think I can handle this here as it could cause an issue with too many soql queries
  	  return 'Place Holder';
  	}
  	
  	public String getapt_warnings() {
  	  //to-do:figure out where warnings come from
  	  //add medical clearance here
  	  //return 'Place Holder';
  	  //for now,  just returning the apt notes
  	  return 'Apt Note';
  	}
  }
  
  public class clinical_calendar_column {
  	public Clinical_Calendar_Cell[] all_cells {get;set;}
  	public String header_name {get; set;}
  	
  	public clinical_calendar_column() {
      all_cells = new Clinical_Calendar_Cell[] {};
  	}  
  }
  
  public Integer getstart_hour_limit() {
  	return (current_center.clinical_start_hour__c==null?7:current_center.clinical_start_hour__c.intvalue());
  }
  
  public Integer getend_hour_limit() {
  	 if(current_center.clinical_end_hour__c==null)
  	   return 20;
  	 else
  	   return current_center.clinical_end_hour__c.intvalue();  	 
  }
  
  public List<Weekly_Calendar_cell> getweekly_label_column() {
  	List<weekly_calendar_cell> label_col = new List<Weekly_Calendar_Cell> ();
  	Integer hour;
  	Integer minute;
  	Integer current_hour = system.now().hour();
  	Integer current_minute = system.now().minute();  	
  	for(hour=getstart_hour_limit();hour<getend_hour_limit();hour++) {
  	  minute = 0;
  	  while(minute<60) {  	  	  	   	  	
  	  	String tlabel = '';
  	  	String suffix = 'AM';
  	  	if(hour > 12) {
  	  	  tlabel += (hour - 12) + ':';
  	  	  suffix = 'PM';
  	  	}
  	  	else if(hour==12) {
  	  	  tlabel += hour + ':';
  	  	  suffix = 'PM';
  	  	}
  	  	else 
  	  	  tlabel += hour + ':';
  	  	if(minute==0)
  	  	  tlabel += '00 ' + suffix;
  	  	else
  	  	  tlabel += minute + ' ' + suffix;
  	  	weekly_calendar_cell wc = new weekly_calendar_cell('time_label',tlabel,0,0);
  	  	if(hour==current_hour && (current_minute >= minute && current_minute < (minute + 10)))
  	  	  wc.current_time = true;
  	  	label_col.add(wc);
  	  	minute += 10;
  	  }
  	}
  	return label_col;
  }
  
  public List<Clinical_Calendar_cell> getlabel_column() {
  	List<clinical_calendar_cell> label_col = new List<Clinical_Calendar_Cell> ();
  	Integer hour;
  	Integer minute;
  	//label_col.add(new calendar_cell('label_header','',false,null,0,0,0));
  	Integer current_hour = system.now().hour();
  	Integer current_minute = system.now().minute();  	
  	for(hour=getstart_hour_limit();hour<getend_hour_limit();hour++) {
  	//for(hour=7;hour<20;hour++) {
  	  minute = 0;
  	  while(minute<60) {  	  	  	   	  	
  	  	String tlabel = '';
  	  	String suffix = 'AM';
  	  	if(hour > 12) {
  	  	  tlabel += (hour - 12) + ':';
  	  	  suffix = 'PM';
  	  	}
  	  	else if(hour==12) {
  	  	  tlabel += hour + ':';
  	  	  suffix = 'PM';
  	  	}
  	  	else 
  	  	  tlabel += hour + ':';
  	  	if(minute==0)
  	  	  tlabel += '00 ' + suffix;
  	  	else
  	  	  tlabel += minute + ' ' + suffix;
  	  	clinical_calendar_cell cc = new clinical_calendar_cell('cc-clinical-calendar-schedule-cell-time-container time_label',tlabel,false,null,0,0);
  	  	if(hour==current_hour && (current_minute >= minute && current_minute < (minute + 10)))
  	  	  cc.current_time = true;
  	  	label_col.add(cc);
  	  	minute += 10;
  	  }
  	}
  	return label_col;
  }
  
  public List<clinical_Calendar_cell> getblank_column(String room_id,Map<Integer,String> block_map,Integer zind) {
  	List<clinical_calendar_cell> label_col = new List<clinical_Calendar_Cell> ();
  	Integer hour;
  	Integer minute;
  	Integer block_count = 0;
  	//label_col.add(new calendar_cell('col_header',col_header,false,null,0,0,0));
  	for(hour=getstart_hour_limit();hour<getend_hour_limit();hour++) {
  	//for(hour=7;hour<20;hour++) {
  	  minute = 0;
  	  while(minute<60) {
  	  	Integer ctime = (hour * 60) + minute;  	  	  	   	  	  	  	
  	  	//clinical_calendar_cell cc = new clinical_calendar_cell('open_slot c-pointer','',false,null,day_of_week,hour,minute);
  	  	clinical_calendar_cell cc = new clinical_calendar_cell('cc-clinical-calendar-schedule-cell-time-container','',false,null,hour,minute);
  	  	//to-do figure out onclick events
  	  	//cc.onclick_event = 'new_block(' + day_of_week + ',' + hour + ',' + minute + ')';
  	  	if(block_map.get(ctime)!=null) {
    	  cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-blocked ';	  	  
    	  Integer offset = block_count * 20;
    	  cc.cell_style = 'background-position: ' + offset + 'px; ';
    	  if(block_map.get(ctime).contains('End Block'))
	  	   	cc.cell_style += ' border-bottom: 1px solid black;';
	  	  if(block_count==0) { 
	  	  	String[] block_text = block_map.get(ctime).split(':');
	  	    cc.cell_text += block_text[0].replace('End Block','');
	  	    cc.top_css = 'z-index : ' + zind-- + ';'; 
	  	    if(block_text.size()>1)
	  	      if((block_text[1]=='null'?'':block_text[1])!='') {
	  	    	//honestly,  need to set up a different tooltip style for this at some point.  I've loaded it up with inline styles to get it to work for now,  but it's a bit of a mess
	  	        cc.confirmation_html = '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);" onmouseout="confirmation_display_patient_tooltip(this);"  ><i class="ccf-notes"></i><div class="cc-tooltip cc-center " style="z-index:10400;position: absolute;color: white; background: #39b17f; height: auto; top: 50%; padding-left: 10px; padding-right: 10px;padding-top: 5px;padding-bottom: 5px;border-radius: 6px;font-weight: 300;letter-spacing: 1px;font-size: 10pt;box-shadow: -1px 9px 31px -4px rgba(0,0,0,0.75);transition: 0s;">' 
	  	          + block_text[1] + '</div></div>';
	  	      }
	  	    cc.cell_css += ' top-cell '; 
	  	  }
	  	  block_count++;	  	   	  	  
	  	}  else if(manual_search) {
	  	  block_count = 0;
	  	  cc.cell_css += '-generic ';
		  cc.onmouseover_event = 'display_noncell_msched(this,\'' + room_id + '\',' + ctime + ');return false;';
		  cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container ';
		  cc.cell_text += '&nbsp;';
	  	}
	  	else
	  	  block_count = 0;
  	  	label_col.add(cc);
  	  	minute += 10;
  	  }
  	}
  	return label_col;
  }
  
  public string add_cell_footer_actions(Clinical_Apt_Calendar__c capt) {
  	String confirmation_html = '';
  	if(capt.account__c!=null) {
      Integer next_offset = 42;
      confirmation_html += '<div style="width:100%;" class="cc-cc-calendar-cell-content"><span>&nbsp;</span></div>' +
	    '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:2px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="reduce_block(\'' + capt.id + '\');"><i class="ccf-remove"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Reduce Block</p></div>' +
	  	'<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:21px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="extend_block(\'' + capt.id + '\');"><i class="ccf-add-light"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Extend Block</p></div>' ;
	  if(capt.confirmation_status__c==null)
	    confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;"  ><i class="ccf-question-circle"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Not confirmed</p></div>';
      else if(capt.confirmation_status__c=='Not Confirmed') 	   	    		  	   	    		  	   	  		  	   	    
	    confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);"  style="right:' + next_offset + 'px;"><i class="ccf-question-circle"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Not confirmed</p></div>';
      else if(capt.confirmation_status__c=='Confirmed')
	    confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-confirmed cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;"><i class="ccf-ok"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Confirmed</p></div>';
	  else if(capt.confirmation_status__c=='Left Message')
	    confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-message cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;"><i class="ccf-phone"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Left message</p></div>';
      else if(capt.confirmation_status__c=='Can\'t Reach')
		confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-noReach cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;" ><i class="ccf-warning"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Unable to reach</p></div>';
	  next_offset += 21;
	  Set<String> possible_statuses = new Set<String> {'Pending Reschedule','Patient Arrived','Patient Ready','Appointment Started'};
	  if((capt.apt_status__c == null || possible_statuses.contains(capt.apt_status__c)) && capt.apt_date__c>=System.today()) {
	  //if((capt.apt_status__c == null || capt.apt_status__c == 'Pending Reschedule') && capt.apt_date__c>=System.today()) {
	    if(current_center.bypass_clipboard_confirmation__c)
		  confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:' + next_offset + 'px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="add_to_board(\'' + capt.id + '\');" ><i class="hrxicon-clipboard"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Move to Clipboard</p></div>';
		else
		  confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:' + next_offset + 'px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="conf_add_to_board(\'' + capt.id + '\');" ><i class="hrxicon-clipboard"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Move to Clipboard</p></div>';
		next_offset += 21;	
      }
  	}
  	return confirmation_html;  	   	  	  	  	   	  	  	  	   	  	  	    
  }
  
  public clinical_calendar_column[] getday_calendar_info() {
  	List<clinical_calendar_column> week_column = new List<clinical_calendar_column>();
  	//build the label column
  	Clinical_Calendar_Column cal_column = new clinical_calendar_column();
  	cal_column.header_name = 'Time Label';
    cal_column.all_cells.addAll(getLabel_column());
    week_column.add(cal_column);
    //lets grab all of the rooms we're going to work though and build a set
    Set<String> room_set = new Set<String>();
    if(room_type=='PSCombo') {
      room_set.add('Prosth');
      room_set.add('Surgery');
      room_set.add('Hybrid');
    } else if(room_type=='Prosth' || room_type=='Surgery') {
      room_set.add(room_type);
      room_set.add('Hybrid');
    }
    else
      room_set.add(room_type);    
    List<Clinical_Room__c> displayed_rooms = [select id,name from Clinical_Room__c where center_information__c = : current_center.id and room_type__c in :room_set and isactive__c = true
      and (cut_off_date__c = null or cut_off_date__c >= :current_date)
      //and name = 'PR2'
      order by room_type__c,sort_order__c];
    Map<Id, Clinical_Room__c> room_map = new Map<Id, Clinical_Room__c>(displayed_rooms);        
    //build a map of apt blocks 
    Map<Id,List<Clinical_Apt_calendar__c>> room_apt_map = new Map<ID,List<Clinical_Apt_Calendar__c>>();
    Set<ID> apt_id_set = new Set<ID>();
    List<Clinical_Apt_Calendar__c> all_apt_blocks;
    if(display_open_blocks)
      all_apt_blocks = [Select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, ready_time__c,
  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, account__r.phone, account__r.personmobilephone,
  	    c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.cr_schedule_block__r.calendar_label__c, c.Apt_Date__c, c.Account__c, Confirmation_Status__c,
  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__r.doctor_notes__c, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c, account__r.main_photo_id__c, 
  	    (Select Id From Clinical_Apt_Histories__r) From Clinical_Apt_Calendar__c c
  	    where c.Clinical_Room__c = :room_map.keyset() and c.Apt_Date__c = :current_date order by stime__c];
  	else
  	  all_apt_blocks = [Select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, ready_time__c,
  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, account__r.phone, account__r.personmobilephone,
  	    c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.cr_schedule_block__r.calendar_label__c, c.Apt_Date__c, c.Account__c, Confirmation_Status__c,
  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__r.doctor_notes__c, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c, account__r.main_photo_id__c, 
  	    (Select Id From Clinical_Apt_Histories__r) From Clinical_Apt_Calendar__c c
  	    where c.Clinical_Room__c = :room_map.keyset() and c.Apt_Date__c = :current_date and account__c != null order by stime__c];
    Set<ID> account_set = new Set<ID> ();  	    
    for(Clinical_Apt_Calendar__c c : all_apt_blocks) {
      //check to see if this room is already in the map
      if(room_apt_map.get(c.clinical_room__c)==null) {
      	room_apt_map.put(c.clinical_room__c,new List<Clinical_Apt_Calendar__c>());
      } 
      room_apt_map.get(c.clinical_room__c).add(c);
      if(c.patient_pot_apt__c!=null)
        apt_id_set.add(c.patient_pot_apt__c);   
      if(c.account__c!=null)
        account_set.add(c.account__c);
    }    
    //build a map of all patient_pot_apt_procedures we'll need info for
    System.debug('Apt ID Set : ' + apt_id_set);
    System.debug('Apt ID Set Size : ' + apt_id_set.size());    
    Map<ID,Patient_POT_Apt_Procedure__c[]> procedure_map = new Map<ID,Patient_POT_Apt_Procedure__c[]>();
    for(Patient_POT_Apt_Procedure__c p :[Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c,p.patient_pot_apt__c From Patient_POT_Apt_Procedure__c p 
      where isactive__c = true and patient_pot_apt__c in :apt_id_set order by p.sort_order__c]) {
      if(procedure_map.get(p.patient_pot_apt__c)==null) {
       	Patient_Pot_Apt_procedure__c[] procedure_list = new Patient_POT_Apt_Procedure__c[] {p};
        procedure_map.put(p.patient_pot_apt__c,procedure_list);
      }
      else
        procedure_map.get(p.patient_pot_apt__c).add(p);
    }    
    //build a map of all pec owners we'll need
    Map<ID,String> pec_owner_map = new Map<ID,String>(); 
    for(Opportunity o : [select id, accountid, current_prosth_owner__r.name from Opportunity where accountid in : account_set order by createddate desc]) {
      if(pec_owner_map.get(o.accountid)==null)
        pec_owner_map.put(o.accountid,o.current_prosth_owner__r.name);
    }
       
    Map<ID,Integer> room_apt_count = new Map<ID,Integer>();
    if(display_open_blocks)    
      for(AggregateResult ar : [select clinical_room__c, count(id) apt_count from Clinical_Apt_Calendar__c c where c.clinical_room__c = :room_map.keyset() and c.apt_date__c = :current_date group by c.clinical_room__c]) {
        room_apt_count.put((ID)ar.get('clinical_room__c'),(Integer)ar.get('apt_count'));    	
      }
    else
      for(AggregateResult ar : [select clinical_room__c, count(id) apt_count from Clinical_Apt_Calendar__c c where c.clinical_room__c = :room_map.keyset() and c.apt_date__c = :current_date and account__c != null group by c.clinical_room__c]) {
        room_apt_count.put((ID)ar.get('clinical_room__c'),(Integer)ar.get('apt_count'));    	
      }
    
    //build a map of room block times for use later
    Map<ID,Map<Integer,String>> all_room_block_map = new Map<ID,Map<Integer,String>> ();
    if(display_room_restrictions) {
      for(Clinical_Time_Restriction__c ctr : [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Clinical_Room__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c 
        From Clinical_Time_Restriction__c c 
        where block_date__c =: current_date and clinical_room__c= :room_map.keyset() order by stime__c]) {
        if(all_room_block_map.get(ctr.clinical_room__c)==null) {
          all_room_block_map.put(ctr.clinical_room__c,new Map<Integer,String>());  	
        }
        Integer bstime = ctr.stime__c.intvalue();
        Integer betime = ctr.etime__c.intvalue();
        while(bstime < betime) { 
      	  String breason = ctr.block_reason__c + ':' + ctr.block_note__c;
      	  if((bstime+10)==betime)
      	    breason += ' End Block';
          all_room_block_map.get(ctr.clinical_room__c).put(bstime,breason);
          bstime+=10;
        }
      }
    }
    
    Integer current_z = 200;
    Integer current_top_z = 300;
    
    //work through all of the rooms that meet the current filter criteria
    for(Clinical_Room__c cr : displayed_rooms) {
  	  cal_column = new clinical_calendar_column();  	
  	  cal_column.header_name = cr.name;
  	  System.debug('Current Room : ' + cr.name);
      
              
  	  //check to see if we have any blocks defined for this day
      Integer apt_count = 0;
      //apt_count = [Select count() From Clinical_Apt_Calendar__c c where c.Clinical_Room__c = :cr.id and c.Apt_Date__c = :current_date];
      if(room_apt_count.get(cr.id)!=null)
        apt_count = room_apt_count.get(cr.id);  	    	    	    	  
  	  //if not - build a clean column
  	  if(apt_count==0) {  	  	
  	  	if(all_room_block_map.get(cr.id)!=null) {
  	  	  cal_column.all_cells.addAll(getblank_column(cr.id,all_room_block_map.get(cr.id),current_z));
  	  	  current_z = current_z - 10;
  	  	}
  	  	else
  	  	  cal_column.all_cells.addAll(getblank_column(cr.id,new Map<Integer,String>(),current_z));
        week_column.add(cal_column);	
  	  } else { 
  	    List<Clinical_Apt_Calendar__c> apt_blocks = room_apt_map.get(cr.id);  	            
        System.debug('Proc Map : ' + procedure_map);
  	      	      	            
  	    Integer sched_position = 0;    	         	    	      	    
 	  	//cal_column.all_cells.add(new calendar_cell('col_header',dow_name.get(dow),false,null,0,0,0));
 	  	Clinical_Apt_Calendar__c current_apt = apt_blocks.get(sched_position);   	  	
        System.debug('Current Apt : ' + current_apt); 	  		
	  	Integer shour = (current_apt.start_hour_int__c==null?0:current_apt.start_hour_int__c.intvalue());
	  	Integer sminute = (current_apt.start_minute_int__c==null?0:current_apt.start_minute_int__c.intvalue());
	  	Integer stime = (shour * 60 + sminute);
	  	Integer ehour = (current_apt.end_hour_int__c==null?0:current_apt.end_hour_int__c.intvalue());
	  	Integer eminute = (current_apt.end_minute_int__c==null?0:current_apt.end_minute_int__c.intvalue());
	  	Integer etime = (ehour * 60 + eminute);
	  	Integer current_cell = 0;
	  	Integer total_apt_time = etime - stime;
	  	System.debug('Total Apt Time : ' + total_apt_time);
	  	//calculate doctor start and end times for this apt	  	
	  	Integer btime = stime;
	  	Integer doctor_stime = 0;
	  	Integer doctor_etime = 0;
	  	//System.debug('Map get id : ' + current_apt.patient_pot_apt__c);
	  	//System.debug('Get Size : ' + procedure_map.get(current_apt.patient_pot_apt__c).size());
	  	if(current_apt.patient_pot_apt__c!=null)
	  	  if(procedure_map.get(current_apt.patient_pot_apt__c)!=null) {
	  	    for(Patient_POT_Apt_Procedure__c p : procedure_map.get(current_apt.patient_pot_apt__c)) {
	  	      //System.debug('Apt ID : ' + current_apt.patient_pot_apt__r.name + ' (' + current_apt.patient_pot_apt__c + ') Procedure : ' + p.procedure_description__c + ' Time_required : ' + p.time_required__c + ' Doc : ' + p.clinical_procedure__r.doctor_required__c);
	  	      //System.debug('Current Btime : ' + btime);	  	      
	  	      if(p.clinical_procedure__r.doctor_required__c && doctor_stime==0) {
	  	        doctor_stime = btime;
	  	      }
	  	      btime += p.time_required__c.intValue();
	  	      if(p.clinical_procedure__r.doctor_required__c)
	  	        doctor_etime = btime;
	  	      System.debug('Doctor Stime : ' + doctor_stime + ' Dr Etime : ' + doctor_etime);
	  	    }
	  	    System.debug('Doctor Stime : ' + doctor_stime + ' Dr Etime : ' + doctor_etime);
	  	  }
	  	  	  	
	  	//otherwise - build a column that displays the hour info
	  	Integer hour;
	  	Integer minute;
	  	Integer block_count = 0;	  	
  	    for(hour=getstart_hour_limit();hour<getend_hour_limit();hour++) {
	  	//for(hour=7;hour<20;hour++) {
	  	  minute = 0;
	  	  while(minute<60) {	  	  	
	  	   	Integer ctime = (hour * 60) + minute;	  
	  	   	Integer next_hour = hour;
	  	   	Integer next_minute = minute + 10;
	  	   	if(next_minute==60) {
	  	   	  next_hour++;
	  	   	  next_minute = 0;
	  	   	}	     		 
	  	   	clinical_calendar_cell cc = new clinical_calendar_cell('cc-clinical-calendar-schedule-cell-time-container','',false,null,hour,minute);	  	   		  	   
	  	   	
	  	    //check to make sure we still have an upcoming block - if not,  we've drawn all of them and everything else if a boring cell
	  	    if(current_apt==null) {
	  	      //calendar_cell cc = new calendar_cell('open_slot c-pointer','',false,null,dow,hour,minute);
	  	      //clinical_calendar_cell cc = new clinical_calendar_cell('cc-clinical-calendar-schedule-cell-time-container','',false,null,hour,minute);
	  	      //to-do is there an event for a blank cell
	  	      //cc.onclick_event = 'new_block(' + dow + ',' + hour + ',' + minute + ');';
	  	      //cal_column.all_cells.add(cc);
	  	      if(manual_search) {
	  	      	cc.cell_css += '-generic ';
		  	    cc.onmouseover_event = 'display_noncell_msched(this,\'' + cr.id + '\',' + ctime + ');return false;';
		  	    cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container ';
		  	    cc.cell_text += '&nbsp;';
	  	   	  }
	  	    } 	      	
	  	  	//check to see if time matches the start time for our upcoming block 
	  	   	else {
	  	   	  Boolean blank_cell = true;
	  	   	  System.debug('Current Cell : ' + current_cell + ' Print Display : ' + print_display);
	  	   	  if(current_cell==1) {
	  	   	  	if(current_apt.account__c==null) {
		  	   	  cc.top_css += ' position:relative;opacity:.98;z-index:-1;';
		  	   	} 
	  	   	  	if(current_apt.patient_pot_apt__c!=null) {
	  	   	  	  cc.cell_text = current_apt.patient_pot_apt__r.name;
	  	   	  	  if(!print_display) {
	  	   	  	    cc.image_display = true;	  	   	  	  
	  	   	  	    cc.image_name = 'ccf-tooth';
	  	   	  	  } 
	  	   	  	  //cc.display_photo_tooltip = true;
	  	   	  	}
	  	   	  	if(total_apt_time >= 20 && total_apt_time < 30)	{ 
	  	   	  	  cc.cell_style = 'opacity:.99';  	  		
	  	   	  	  cc.top_css += 'position:relative;';
	  	   	  	  cc.confirmation_html = add_cell_footer_actions(current_apt);
	  	   	  	}	
	  	   	  	current_cell++;
	  	   	  }
	  	   	  else if(current_cell==2) {
	  	   	  	//System.debug('Cell 2 - Doctor : ' + current_apt.doctor__c);
	  	   	  	if(current_apt.account__c==null) {
		  	   	  cc.top_css += ' position:relative;opacity:.98;z-index:-1;';
		  	   	} 
	  	   	  	
	  	   	  	if(print_display) {
	  	   	  	//  System.debug('Cell 2 - Notes : ' + current_apt.patient_pot_apt__r.doctor_notes__c);  	
	  	   	  	  cc.cell_text = current_apt.patient_pot_apt__r.doctor_notes__c;
	  	   	  	}
	  	   	  	else {
	  	   	  	  if(total_apt_time >= 30 && total_apt_time < 40)	{ 
	  	   	  	  	cc.cell_style = 'opacity:.99';  	  		
	  	   	  	  	cc.top_css += 'position:relative;';
	  	   	  	    cc.confirmation_html = add_cell_footer_actions(current_apt);
	  	   	  	  }	
	  	   	  	  if(current_apt.doctor__c!=null) {	
	  	   	  	    cc.cell_text = current_apt.doctor__r.name;	  	   	  	  
	  	   	  	    cc.image_display = true;
	  	   	  	    cc.image_name = 'ccf-clinical';
	  	   	  	  }
	  	   	  	}
	  	   	  	  /*if(current_apt.patient_pot_apt__r.doctor_notes__c!=null) {
	  	   	  	    cc.confirmation_html = '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);" onmouseout="confirmation_display_patient_tooltip(this);"  >' +
                      '<i class="ccf-notification-2"></i><div class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">' + current_apt.patient_pot_apt__r.doctor_notes__c + '</div></div>';
                    cc.cell_style += 'position:relative;';
	  	   	  	  }*/	  	   	  	  
	  	   	  	//}
	  	   	  	current_cell++;
	  	   	  }
	  	   	  else if(current_cell==3) {
	  	   	  	if(current_apt.account__c==null) {
		  	   	  cc.top_css += ' position:relative;opacity:.98;z-index:-1;';
		  	   	} 	  	   	  	
	  	   	  	if(print_display) {
	  	   	  	  //System.debug('Cell 3 - Doctor : ' + current_apt.doctor__r.name);
	  	   	  	  cc.cell_text = current_apt.doctor__c==null?'':current_apt.doctor__r.name;
	  	   	  	}
	  	   	  	else {	  	 	  
	  	   	  	  if(total_apt_time >= 40)	   	  		
	  	   	  	    cc.confirmation_html = add_cell_footer_actions(current_apt);
	  	   	  	  cc.cell_style = 'opacity:.99';
	  	   	  	  if(current_apt.account__c!=null) {
	  	   	  	  	cc.top_css += 'position:relative;';
	  	   	  	  	cc.apt = current_apt;
	  	   	  	  }  	  	  
	  	   	  	  /*Integer next_offset = 42;
	  	   	  	  cc.cell_style = 'opacity:.99';
	  	   	  	  	  	   	  	  	  	   	  	  	  	   	  	  
	  	   	  	  if(current_apt.account__r.main_photo_id__c!=null) {
	  	   	  	    //cc.cell_text = 'View Photo';
	  	   	  	    cc.apt = current_apt;
	  	   	  	    //cc.display_photo_tooltip = true;
	  	   	  	    //cc.image_display = true;
	  	   	  	    //cc.image_name = 'ccf-play';
	  	   	  	    //cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;" ><i class="ccf-play"></i>' +
		  	   	      //tooltip test
		  	   	      //'<p class="cc-tooltip cc-center cc-tooltip-confirmationStatus " style="z-index:600;visibility:hidden;min-width:200px;" >' +
		  	   	        //'<img src="https://c.cs12.content.force.com/servlet/servlet.FileDownload?file=' + current_apt.account__r.main_photo_id__c + '" style="max-width:200px;max-height:200px;" />&nbsp;' +     		  	   	        
                      //'</p>' +
		  	   	    //'</div>';
		  	   	    //next_offset += 21;
		  	   	    if(current_apt.apt_date__c>=System.today())
	  	   	  	      cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:21px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="reduce_block(\'' + cc.apt.id + '\');"><i class="ccf-remove"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Reduce Block</p></div>' +
	  	   	  	        '<div style="opacity:.99;" class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="extend_block(\'' + cc.apt.id + '\');"><i class="ccf-add-light"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Extend Block</p></div>';
	  	   	  	  } else if(current_apt.account__c!=null) {
	  	   	  	  	if(current_apt.apt_date__c>=System.today())
	  	   	  	  	  cc.confirmation_html += '<div style="width:100%;" class="cc-cc-calendar-cell-content"><span>&nbsp;</span></div>' +
	  	   	  	  	    '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:2px;position:relative;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="reduce_block(\'' + current_apt.id + '\');"><i class="ccf-remove"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Reduce Block</p></div>' +
	  	   	  	        '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="position:relative;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="extend_block(\'' + current_apt.id + '\');"><i class="ccf-add-light"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Extend Block</p></div>' ;
	  	   	  	  	  //'</div>';
	  	   	  	  }
	  	   	  	  if(current_apt.account__c!=null) {
	  	   	  	  	  cc.top_css += 'position:relative;';
		  	   	  	  if(current_apt.confirmation_status__c==null)
			  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;"  ><i class="ccf-question-circle"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Not confirmed</p></div>';
			  	   	  else if(current_apt.confirmation_status__c=='Not Confirmed') 	   	    		  	   	    		  	   	  		  	   	    
			  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);"  style="right:' + next_offset + 'px;"><i class="ccf-question-circle"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Not confirmed</p></div>';
			  	   	  else if(current_apt.confirmation_status__c=='Confirmed')
			  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-confirmed cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;"><i class="ccf-ok"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Confirmed</p></div>';
			  	   	  else if(current_apt.confirmation_status__c=='Left Message')
			  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-message cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;"><i class="ccf-phone"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Left message</p></div>';
			  	   	  else if(current_apt.confirmation_status__c=='Can\'t Reach')
			  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-noReach cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;" ><i class="ccf-warning"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Unable to reach</p></div>';
		  	   	  	  next_offset += 21;
		  	   	  	  if((current_apt.apt_status__c == null || current_apt.apt_status__c == 'Pending Reschedule') && current_apt.apt_date__c>=System.today()) {
		  	   	  	  	if(current_center.bypass_clipboard_confirmation__c)
		  	   	  	  	  cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:' + next_offset + 'px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="add_to_board(\'' + current_apt.id + '\');" ><i class="hrxicon-clipboard"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Move to Clipboard</p></div>';
		  	   	  	  	else
		  	   	  	  	  cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" style="right:' + next_offset + 'px;" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" onclick="conf_add_to_board(\'' + current_apt.id + '\');" ><i class="hrxicon-clipboard"></i><p style="z-index:600;visibility:hidden;transition:0s;" class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Move to Clipboard</p></div>';
		  	   	  	    next_offset += 21;	
		  	   	  	  }
	  	   	  	  }*/
	  	   	  	}
	  	   	  	
	  	   	  	current_cell++;
	  	   	  }
	  	   	  
	  	   	  //System.debug('Current Cell : ' + current_cell + ' Exit Text : ' + cc.cell_text);
	  	   	  
	  	   	  //safety check to make sure we're not trying to draw a block prior to our time here
		  	  if(((next_hour * 60) + next_minute) > ((ehour*60) + eminute)  ) {
		  	  	//iterate to the next block if we have more
		  	    sched_position++;
		  	    if(sched_position<=(apt_blocks.size()-1) ) {
		  	      current_apt = apt_blocks.get(sched_position);
		  	      System.debug('Current Apt : ' + current_apt);
		  	      shour = (current_apt.start_hour_int__c==null?0:current_apt.start_hour_int__c.intvalue());
		  	      sminute = (current_apt.start_minute_int__c==null?0:current_apt.start_minute_int__c.intvalue());
		  	      stime = (shour * 60 + sminute);
		  	      ehour = (current_apt.end_hour_int__c==null?0:current_apt.end_hour_int__c.intvalue());
		  	      eminute = (current_apt.end_minute_int__c==null?0:current_apt.end_minute_int__c.intvalue());
		  	      etime = (ehour * 60 + eminute);
		  	      total_apt_time = etime - stime;
		  	      current_cell = 0;
		  	      //calculate doctor start and end times for this apt
	  	          btime = stime;
	  	          doctor_stime = 0;
	  	          doctor_etime = 0;
	  	          if(current_apt.patient_pot_apt__c!=null)
	  	            if(procedure_map.get(current_apt.patient_pot_apt__c)!=null) {
	  	              for(Patient_POT_Apt_Procedure__c p : procedure_map.get(current_apt.patient_pot_apt__c)) {
	  	                if(p.clinical_procedure__r.doctor_required__c && doctor_stime==0)
	  	                  doctor_stime = btime;
	  	                btime += p.time_required__c.intValue();
	  	                if(p.clinical_procedure__r.doctor_required__c)
	  	                  doctor_etime = btime;
	  	              }
	  	            }
	  	          System.debug('Doctor Stime : ' + doctor_stime + ' Dr Etime : ' + doctor_etime);	  	            
		  	    }	      	
		  	    else 
		  	      current_apt = null;		  	    
		  	  }
	  	   	  
	  	   	  if(shour == hour && sminute == minute) {
	  	   	  	blank_cell = false;
	  	   	  	cc.cell_css += '-generic ';
	  	   	  	cc.top_css += 'position:relative;z-index:'+current_top_z+';';
	  	   	  	current_top_z--;
	  	   	  	current_cell = 1;	  	   	  	  
		  	   	//check to see if the previous cell was marked as open_slot c-pointer
		  	   	if(cal_column.all_cells.size()>0) {
		  	   	  Integer last_position = cal_column.all_cells.size() - 1;
		  	   	  //if(cal_column.all_cells.get(last_position).cell_css=='open_slot c-pointer')
		  	   	  if(cal_column.all_cells.get(last_position).cell_css=='cc-clinical-calendar-schedule-cell-time-container')
		  	   	    cal_column.all_cells.get(last_position).cell_css += ' no_bottom';
		  	   	}
		  	   	String cell_label = '<span style="color:black;">' + (current_apt.cr_schedule_block__r.calendar_label__c==null?'Open Block':current_apt.cr_schedule_block__r.calendar_label__c) + '</span>';
		  	   	//String base_css = 'cc-clinical-calendar-schedule-cell-time-container working_head';		 
		  	   	if(current_apt.account__c==null) {
		  	   	  cc.top_css += ' position:relative;opacity:.98;z-index:-1;';
		  	   	} 	   	
		  	   	  
		  	   	//to-do get cell label
		  	   	if(current_apt.account__c!=null) {		  	   	  
		  	   	  //cell_label = current_apt.account__r.firstname + ' ' + current_apt.account__r.lastname.left(1);
		  	   	  if(print_display) {
		  	   	    cell_label = current_apt.account__r.firstname + ' ' + current_apt.account__r.lastname;
		  	   	  }
		  	   	  else {
		  	   	    cell_label = current_apt.account__r.firstname.left(1) + ' ' + current_apt.account__r.lastname;
		  	   	    cc.image_display = true;
		  	   	    cc.image_name = 'ccf-patient';
		  	   	    
		  	   	  }
		  	   	  //cc.onmouseover_event = 'show_patient_tooltip(this);';
		  	   	  //cc.onmouseout_event = 'hide_patient_tooltip(this);';
		  	   	  
		  	   	  cc.apt = current_apt;
		  	   	  cc.display_tooltip = true;		  	   	 		  	   	  		  	   	 
		  	   	  cc.onclick_event = 'open_cmodal(\'' + current_apt.id + '\');';
		  	   	  cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container-first ';
		  	   	  if(current_apt.apt_status__c=='Patient Arrived')
		  	   	    cc.cell_css += ' cc-calendar-block-arrived-border-top cc-calendar-block-arrived-body-top cc-calendar-block-arrived-border ';
		  	   	  if(current_apt.apt_status__c=='Patient Ready') {
		  	   	  	//check to see if it's late (15 minutes after ready time)
		  	   	  	if(current_apt.apt_date__c==System.today() && ((System.now().hour() * 60 + System.now().minute()) - (current_apt.ready_time__c.hour() * 60 + current_apt.ready_time__c.minute()) ) >=15 ) {
		  	   	  	  cc.cell_css += ' cc-calendar-block-late-border-top cc-calendar-block-ready-body-top cc-calendar-block-late-border ';		  	   	  	  
		  	   	  	} else
		  	   	      cc.cell_css += ' cc-calendar-block-ready-border-top cc-calendar-block-ready-body-top cc-calendar-block-ready-border ';
		  	   	  }
		  	   	  if(current_apt.apt_status__c=='Appointment Started')
		  	   	    cc.cell_css += ' cc-calendar-block-started-border-top cc-calendar-block-started-body-top cc-calendar-block-started-border ';
		  	   	  if(current_apt.apt_status__c=='Completed' || current_apt.apt_status__c=='Incomplete')
		  	   	    cc.cell_css += ' cc-calendar-block-completed-border-top cc-calendar-block-completed-body-top cc-calendar-block-completed-border ';
		  	   	  if(current_apt.apt_status__c=='No Show')
		  	   	    cc.cell_css += ' cc-calendar-block-noShow-border-top cc-calendar-block-noShow-body-top cc-calendar-block-noShow-border ';
		  	   	  if(current_apt.apt_status__c=='Patient Left')
		  	   	    cc.cell_css += ' cc-calendar-block-patientLeft-border-top cc-calendar-block-patientLeft-body-top cc-calendar-block-patientLeft-border ';
		  	   	  if(current_apt.apt_status__c==null) {
		  	   	  	if(current_apt.apt_date__c==system.today()) {
		  	   	  	  //check to see if we're late
		  	   	  	  if(((System.now().hour() * 60 + System.now().minute()) - stime) >= 5) 
		  	   	  	    cc.cell_css += ' cc-calendar-block-late-border-top  cc-calendar-block-upcoming-body-top cc-calendar-block-late-border ';		  	   	  	  	
		  	   	  	  else
		  	   	  	    cc.cell_css += ' cc-calendar-block-upcoming-border-top cc-calendar-block-upcoming-body-top cc-calendar-block-upcoming-border ';
		  	   	  	}
		  	   	  	else if(current_apt.apt_date__c>system.today()) 
		  	   	      cc.cell_css += ' cc-calendar-block-upcoming-border-top cc-calendar-block-upcoming-body-top cc-calendar-block-upcoming-border ';
		  	   	    else
		  	   	      //assumed - no show
		  	   	      cc.cell_css += ' cc-calendar-block-noShow-border-top cc-calendar-block-noShow-body-top cc-calendar-block-noShow-border ';
		  	   	  }		 
		  	   	  
		  	   	  //confirmation status check
		  	   	  //cc.confirmation_html = '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);" onmouseout="confirmation_display_patient_tooltip(this);" style="right:21px;" ><i class="hrxicon-info_icon_inverted"><span class="path1"></span><span class="path2"></span><span class="path3"></span><span class="path4"></span></i>' +
		  	   	  cc.confirmation_html = '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="" ><i class="hrxicon-info_icon_inverted"><span class="path1"></span><span class="path2"></span><span class="path3"></span><span class="path4"></span></i>' +
		  	   	      //tooltip test
		  	   	      '<p class="cc-tooltip cc-center cc-tooltip-confirmationStatus " style="z-index:600;visibility:hidden;display:flex;flex-direction:column;align-items:flex-start;padding-left:20px;min-width:250px;transition:0s;" >' +
		  	   	        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-patient"></i></span>' +
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-patient">' + cc.getpatient_name() + '</span>' +
                        '</span>' +     
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-clock"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">' + cc.getapt_time() + '</span>' +
                        '</span>' +
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-status"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">' + cc.getapt_status() + '</span>' +
                        '</span>' +
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-tooth"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">' + cc.getapt_name() + '</span>' +
                        '</span>' +
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-clinical"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">' + cc.getdr_name() + '</span>' +
                        '</span>' +
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-clinical"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">H:&nbsp;' + cc.apt.account__r.phone + '</span>' +
                        '</span>';
                    if(cc.getdisplay_mobile())    
                      cc.confirmation_html += '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="ccf-clinical"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">M:&nbsp;' + cc.apt.account__r.personmobilephone + '</span>' +
                        '</span>';                                            
                    cc.confirmation_html +=
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="cc-cc-apptInfoHoverId-patientCity-image ccf-location"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">H:&nbsp;' + cc.getpatient_city() + '</span>' +
                        '</span>' +
                        '<span class="cc-cc-apptInfoRow cc-cc-hoverRow-link" style="display:flex;flex-direction:row;">' +
                          '<span class="cc-cc-apptInfoRow-img" style="padding-right:10px;"><i class="cc-cc-apptInfoHoverId-patientCity-image ccf-call"></i></span>' + 
                          '<span class="cc-cc-apptInfoRow-appointmentLabel cc-cc-apptInfoHoverId-time">H:&nbsp;' + pec_owner_map.get(cc.apt.account__c) + '</span>' +
                        '</span>' +
                      '</p>' +
		  	   	    '</div>';		  	   	  
		  	   	  /*if(current_apt.confirmation_status__c==null)
		  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);" onmouseout="confirmation_display_patient_tooltip(this);"  ><i class="ccf-question-circle"></i><p class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Not confirmed</p></div>';
		  	   	  else if(current_apt.confirmation_status__c=='Not Confirmed') 	   	    		  	   	    		  	   	  		  	   	    
		  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);" onmouseout="confirmation_display_patient_tooltip(this);"  ><i class="ccf-question-circle"></i><p class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Not confirmed</p></div>';
		  	   	  else if(current_apt.confirmation_status__c=='Confirmed')
		  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-confirmed cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);"  onmouseout="confirmation_display_patient_tooltip(this);" ><i class="ccf-ok"></i><p class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Confirmed</p></div>';
		  	   	  else if(current_apt.confirmation_status__c=='Left Message')
		  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-message cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);"  onmouseout="confirmation_display_patient_tooltip(this);" ><i class="ccf-phone"></i><p class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Left message</p></div>';
		  	   	  else if(current_apt.confirmation_status__c=='Can\'t Reach')
		  	   	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-noReach cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);"  onmouseout="confirmation_display_patient_tooltip(this);"  ><i class="ccf-warning"></i><p class="cc-tooltip cc-center cc-tooltip-confirmationStatus ">Unable to reach</p></div>';*/
		  	   	  Integer next_offset = 21;
		  	   	  if(current_apt.patient_pot_apt__r.doctor_notes__c!=null) {
	  	   	  	  	cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="white-space:normal;right:' + next_offset + 'px;" ><i class="ccf-warning"></i>' +
		  	   	      //tooltip test
		  	   	      '<p class="cc-tooltip cc-center cc-tooltip-confirmationStatus " style="white-space:normal;z-index:600;visibility:hidden;display:flex;flex-direction:column;align-items:flex-start;padding-left:20px;min-width:250px;height:auto;overflow:auto;max-width:250px;transition:0s;" >' +		  	   	        
                         + current_apt.patient_pot_apt__r.doctor_notes__c  +     
                      '</p>' +
		  	   	    '</div>';
		  	   	    next_offset += 21;	
	  	   	  	  }
	  	   	  	  
	  	   	  	  if(current_apt.account__r.main_photo_id__c!=null) {	  	   	  	  	  	   	  	  		  	   	  	   
	  	   	  	    cc.confirmation_html += '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="tooltip_show_test(this);" onmouseout="tooltip_hide_test(this);" style="right:' + next_offset + 'px;" ><i class="ccf-play"></i>' +
		  	   	      //tooltip test
		  	   	      '<p class="cc-tooltip cc-center cc-tooltip-confirmationStatus " style="z-index:600;visibility:hidden;min-width:200px;transition:0s;" >' +
		  	   	        '<img src="https://c.' + org.instancename + '.content.force.com/servlet/servlet.FileDownload?file=' + current_apt.account__r.main_photo_id__c + '" style="max-width:200px;max-height:200px;" />&nbsp;' +     		  	   	        
                      '</p>' +
		  	   	    '</div>';
		  	   	    next_offset += 21;
	  	   	  	  }		  	   	  
		  	   	}		  	   	 		  	   	 		
		  	   	else {
		  	   	  //first row of an open block - adjust css
		  	   	  Boolean mavail = false;
		  	   	  if(manual_search) {
		  	   	  	if(possible_block_map.get(cr.id)!=null) {
		  	   	  	  if(possible_block_map.get(cr.id).contains(ctime)) {
		  	   	        cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container cc-block-available-top cc-block-available '; 
		  	   	        cc.onmouseover_event = 'display_good_msched(this,\'' + current_apt.clinical_room__c + '\',' + ctime + ');return false;';
		  	   	        mavail = true;
		  	   	        cc.cell_text += 'Possible Slot';
		  	   	  	  } 		  	   	        		  	   	       		  	   	     
		  	   	    }
		  	   	    if(!mavail) {
		  	   	      cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container cc_calendar_block_open cc-calendar-block-open-border-top cc-calendar-block-open-body-top cc-calendar-block-open-border ';
		  	   	      cc.onmouseover_event = 'display_bad_msched(this,\'' + current_apt.clinical_room__c + '\',' + ctime + ');return false;';
		  	   	      cc.cell_text += 'Conflict';
		  	   	    } 
		  	   	  } else {
		  	   	    cc.cell_css += ' cc-calendar-block-open-border-top cc-calendar-block-open-body-top cc-calendar-block-open-border ';
		  	   	  }
		  	   	}  	   	  
		  	   	
		  	   	cc.cell_text = cell_label;		  	   	
		  	   	System.debug('Setting Current Apt on custom object');		  	   	
		  	   	//System.debug('display tooltip : ' + cc.getdisplay_tooltip());
		  	  }		  	  		  	  
		  	   
		  	  //check to see if this is a doctor block
		  	  System.debug('Step Check - ctime ' + ctime + ' doctor_stime : ' + doctor_stime + ' - doctor etime : ' + doctor_etime);
		  	  if(ctime >= doctor_stime && ctime <= doctor_etime) {
		  	  	System.debug('Set doctor block');
		  	  	blank_cell = false;
		  	  	//System.debug('Doctor Stime : ' + doctor_stime + ' Dr Etime : ' + doctor_etime);
		  	  	cc.cell_css += '-generic ';
		  	  	if(current_apt != null) {
		  	      if(current_apt.account__c!=null) {
		  	        if(current_apt.apt_status__c=='Patient Arrived')
		  	          cc.cell_css += ' cc-calendar-block-arrived-border cc-calendar-block-arrived-body-docIn  ';
		  	        if(current_apt.apt_status__c=='Patient Ready') {
		  	          //check to see if it's late (15 minutes after ready time)
		  	   	  	  if(current_apt.apt_date__c==System.today() && ((System.now().hour() * 60 + System.now().minute()) - (current_apt.ready_time__c.hour() * 60 + current_apt.ready_time__c.minute()) ) >=15 ) {
		  	   	  	    cc.cell_css += ' cc-calendar-block-late-border  cc-calendar-block-ready-body-docIn ';	   	  	  
		  	   	  	  } else
		  	   	        cc.cell_css += ' cc-calendar-block-ready-border cc-calendar-block-ready-body-docIn ';
		  	        }		  	        		  	          
		  	        if(current_apt.apt_status__c=='Appointment Started')
		  	          cc.cell_css += ' cc-calendar-block-started-border cc-calendar-block-started-body-docIn ';	
		  	        if(current_apt.apt_status__c=='Completed' || current_apt.apt_status__c=='Incomplete')
		  	   	      cc.cell_css += ' cc-calendar-block-completed-border cc-calendar-block-completed-body-docIn ';
		  	   	    if(current_apt.apt_status__c=='No Show')
		  	   	      cc.cell_css += ' cc-calendar-block-noShow-border cc-calendar-block-noShow-body-docIn ';
		  	   	    if(current_apt.apt_status__c=='Patient Left')
		  	   	      cc.cell_css += ' cc-calendar-block-patientLeft-border cc-calendar-block-patientLeft-body-docIn ';
		  	   	    if(current_apt.apt_status__c==null) {
		  	   	      if(current_apt.apt_date__c==system.today()) {
		  	   	  	    //check to see if we're late
		  	   	  	    if(((System.now().hour() * 60 + System.now().minute()) - stime) >= 5) 
		  	   	  	      cc.cell_css += ' cc-calendar-block-late-border cc-calendar-block-upcoming-body-docIn ';		  	   	  	  	
		  	   	  	    else
		  	   	  	      cc.cell_css += ' cc-calendar-block-upcoming-border cc-calendar-block-upcoming-body-docIn ';
		  	   	  	  }
		  	   	  	  else if(current_apt.apt_date__c>system.today())
		  	   	        cc.cell_css += ' cc-calendar-block-upcoming-border cc-calendar-block-upcoming-body-docIn ';
		  	   	      else
		  	   	        //assumed - no show
		  	   	        cc.cell_css += ' cc-calendar-block-noShow-border cc-calendar-block-noShow-body-docIn ';
		  	   	    }	       		  	   	       
		  	      }
		  	      else {
		  	    	//open block middle 
		  	     	cc.cell_css += ' cc-calendar-block-open-border cc-calendar-block-open-body-docIn ';
		  	      }
		  	  	}
		  	  } //check to see if block is between start/end times
		  	  else if(ctime > stime && ctime < etime) {
		  	  	blank_cell = false;
		  	    cc.cell_css += '-generic ';
		  	    if(current_apt != null) {
		  	      if(current_apt.account__c!=null) {
		  	        if(current_apt.apt_status__c=='Patient Arrived')
		  	          cc.cell_css += ' cc-calendar-block-arrived-border cc-calendar-block-arrived-body ';
		  	        if(current_apt.apt_status__c=='Patient Ready') {
		  	          //check to see if it's late (15 minutes after ready time)
		  	   	  	  if(current_apt.apt_date__c==System.today() && ((System.now().hour() * 60 + System.now().minute()) - (current_apt.ready_time__c.hour() * 60 + current_apt.ready_time__c.minute()) ) >=15 ) {
		  	   	  	    cc.cell_css += ' cc-calendar-block-late-border  cc-calendar-block-ready-body ';	   	  	  
		  	   	  	  } else
		  	   	        cc.cell_css += ' cc-calendar-block-ready-border cc-calendar-block-ready-body ';
		  	        }	
		  	        if(current_apt.apt_status__c=='Appointment Started')
		  	          cc.cell_css += ' cc-calendar-block-started-border cc-calendar-block-started-body ';	
		  	        if(current_apt.apt_status__c=='Completed' || current_apt.apt_status__c=='Incomplete')
		  	   	      cc.cell_css += ' cc-calendar-block-completed-border cc-calendar-block-completed-body ';
		  	   	    if(current_apt.apt_status__c=='No Show')
		  	   	      cc.cell_css += ' cc-calendar-block-noShow-border cc-calendar-block-noShow-body ';
		  	   	    if(current_apt.apt_status__c=='Patient Left')
		  	   	      cc.cell_css += ' cc-calendar-block-patientLeft-border cc-calendar-block-patientLeft-body ';
		  	   	    if(current_apt.apt_status__c==null) {
		  	   	      if(current_apt.apt_date__c==system.today()) {
		  	   	  	    //check to see if we're late
		  	   	  	    if(((System.now().hour() * 60 + System.now().minute()) - stime) >= 5) 
		  	   	  	      cc.cell_css += ' cc-calendar-block-late-border cc-calendar-block-upcoming-body ';		  	   	  	  	
		  	   	  	    else
		  	   	  	      cc.cell_css += ' cc-calendar-block-upcoming-border cc-calendar-block-upcoming-body ';
		  	   	  	  }
		  	   	  	  else if(current_apt.apt_date__c>system.today())
		  	   	        cc.cell_css += ' cc-calendar-block-upcoming-border cc-calendar-block-upcoming-body ';
		  	   	      else
		  	   	        //assumed - no show
		  	   	        cc.cell_css += ' cc-calendar-block-noShow-border cc-calendar-block-noShow-body ';
		  	   	    }	       		  	   	       
		  	      }
		  	      else {
		  	    	//open block middle 
		  	    	Boolean mavail = false;
		  	   	    if(manual_search) {
		  	   	  	  if(possible_block_map.get(cr.id)!=null) {
		  	   	  	    if(possible_block_map.get(cr.id).contains(ctime)) {
		  	   	  	      //check to see if this is the bottom slot
		  	   	  	      if(possible_block_map.get(cr.id).contains((ctime + 10))) 
		  	   	  	        cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container cc-block-available ';
		  	   	  	      else
		  	   	  	        cc.cell_css += 'cc-clinical-calendar-schedule-cell-time-container cc-block-available cc-block-available-bottom';
		  	   	  	      //check to see if this is teh top slot
		  	   	  	      if(!possible_block_map.get(cr.id).contains((ctime - 10)))
		  	   	  	        cc.cell_css += ' cc-block-available-top ';		  	   	  	    	 
		  	   	          cc.onmouseover_event = 'display_good_msched(this,\'' + current_apt.clinical_room__c + '\',' + ctime + ');return false;';
		  	   	          mavail = true;
		  	   	          cc.cell_text += 'Possible Slot';
		  	   	  	    } 		  	   	          		  	   	       		  	   	     
		  	   	      }
		  	   	      if(!mavail) { 
		  	   	        cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container cc_calendar_block_open cc-calendar-block-open-border cc-calendar-block-open-body ';		  	   	      
		  	   	        cc.cell_text += 'Conflict';
		  	   	        cc.onmouseover_event = 'display_bad_msched(this,\'' + current_apt.clinical_room__c + '\',' + ctime + ');return false;';
		  	   	      }	 
		  	   	    } else {		  	   	     
		  	   	      cc.cell_css += ' cc-calendar-block-open-border cc-calendar-block-open-body ';		  	   	      
		  	   	    }		  	    	
		  	      }
		  	    }
		  	    	  	      
		  	  }
		  	  
		  	  //check to see if block matches end time
		  	  if(ehour == next_hour && eminute == next_minute) {
		  	  	blank_cell = false;
		  	  	cc.cell_css += '-generic ';
		  	    if(current_apt.account__c!=null) {
		  	      if(current_apt.apt_status__c=='Patient Arrived')
		  	   	    cc.cell_css += ' cc-calendar-block-arrived-border cc-calendar-block-arrived-border-bottom cc-calendar-block-arrived-body-bottom ';
		  	      if(current_apt.apt_status__c=='Patient Ready') {
		  	        //check to see if it's late (15 minutes after ready time)
		  	   	  	if(current_apt.apt_date__c==System.today() && ((System.now().hour() * 60 + System.now().minute()) - (current_apt.ready_time__c.hour() * 60 + current_apt.ready_time__c.minute()) ) >=15 ) {
		  	   	  	  cc.cell_css += ' cc-calendar-block-late-border cc-calendar-block-late-border-bottom cc-calendar-block-ready-body-bottom ';	   	  	  
		  	   	  	} else
		  	   	      cc.cell_css += ' cc-calendar-block-ready-border cc-calendar-block-ready-border-bottom cc-calendar-block-ready-body-bottom ';		  	      		  	   	    
		  	      }
		  	      if(current_apt.apt_status__c=='Appointment Started')
		  	   	    cc.cell_css += ' cc-calendar-block-started-border cc-calendar-block-started-border-bottom cc-calendar-block-started-body-bottom ';
		  	   	  if(current_apt.apt_status__c=='Completed' || current_apt.apt_status__c=='Incomplete')
		  	   	    cc.cell_css += ' cc-calendar-block-completed-border cc-calendar-block-completed-border-bottom cc-calendar-block-completed-body-bottom ';
		  	   	  if(current_apt.apt_status__c=='No Show')
		  	   	    cc.cell_css += ' cc-calendar-block-noShow-border cc-calendar-block-noShow-border-bottom cc-calendar-block-noShow-body-bottom ';
		  	   	  if(current_apt.apt_status__c=='Patient Left')
		  	   	    cc.cell_css += ' cc-calendar-block-patientLeft-border cc-calendar-block-patientLeft-border-bottom cc-calendar-block-patientLeft-body-bottom ';
		  	   	  if(current_apt.apt_status__c==null) {
		  	   	  	if(current_apt.apt_date__c==system.today()) {
		  	   	  	  //check to see if we're late
		  	   	  	  if(((System.now().hour() * 60 + System.now().minute()) - stime) >= 5) 
		  	   	  	    cc.cell_css += ' cc-calendar-block-late-border cc-calendar-block-late-border-bottom cc-calendar-block-upcoming-body-bottom ';		  	   	  	  	
		  	   	  	  else
		  	   	  	    cc.cell_css += ' cc-calendar-block-upcoming-border cc-calendar-block-upcoming-border-bottom cc-calendar-block-upcoming-body-bottom ';
		  	   	  	}
		  	   	  	else if(current_apt.apt_date__c>system.today())
		  	   	      cc.cell_css += ' cc-calendar-block-upcoming-border cc-calendar-block-upcoming-border-bottom cc-calendar-block-upcoming-body-bottom ';
		  	   	    else
		  	   	      //assumed - no show
		  	   	      cc.cell_css += ' cc-calendar-block-noShow-border cc-calendar-block-noShow-border-bottom cc-calendar-block-noShow-body-bottom ';
		  	   	  }	    
		  	    } else {
		  	      //open block close
		  	      Boolean mavail = false;
		  	   	  if(manual_search) {
		  	   	  	if(possible_block_map.get(cr.id)!=null) {
		  	   	  	  if(possible_block_map.get(cr.id).contains(ctime)) {
		  	   	        cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container cc-block-available-bottom cc-block-available '; 
		  	   	        cc.onmouseover_event = 'display_good_msched(this,\'' + current_apt.clinical_room__c + '\',' + ctime + ');return false;';
		  	   	        mavail = true;
		  	   	        cc.cell_text += 'Possible Slot';
		  	   	  	  } 		  	   	        		  	   	       		  	   	      
		  	   	    }
		  	   	    if(!mavail) {
		  	   	      cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container cc_calendar_block_open cc-calendar-block-open-border cc-calendar-block-open-border-bottom  cc-calendar-block-open-body-bottom';
 		  	   	      cc.onmouseover_event = 'display_bad_msched(this,\'' + current_apt.clinical_room__c + '\',' + ctime + ');return false;';
		  	   	      cc.cell_text += 'Conflict';
		  	   	    }		 
		  	   	  } else {
		  	   	    cc.cell_css += ' cc-calendar-block-open-border cc-calendar-block-open-border-bottom  cc-calendar-block-open-body-bottom';
		  	   	  }		  	      		  	      
		  	    }		  	      
		  	    //iterate to the next block if we have more
		  	    sched_position++;
		  	    if(sched_position<=(apt_blocks.size()-1) ) {
		  	      current_apt = apt_blocks.get(sched_position);
		  	      System.debug('Current Apt : ' + current_apt);
		  	      shour = (current_apt.start_hour_int__c==null?0:current_apt.start_hour_int__c.intvalue());
		  	      sminute = (current_apt.start_minute_int__c==null?0:current_apt.start_minute_int__c.intvalue());
		  	      stime = (shour * 60 + sminute);
		  	      ehour = (current_apt.end_hour_int__c==null?0:current_apt.end_hour_int__c.intvalue());
		  	      eminute = (current_apt.end_minute_int__c==null?0:current_apt.end_minute_int__c.intvalue());
		  	      etime = (ehour * 60 + eminute);
		  	      total_apt_time = etime - stime;
		  	      current_cell = 0;
		  	      //calculate doctor start and end times for this apt
	  	          btime = stime;
	  	          doctor_stime = 0;
	  	          doctor_etime = 0;
	  	          if(current_apt.patient_pot_apt__c!=null)
	  	            if(procedure_map.get(current_apt.patient_pot_apt__c)!=null) {
	  	              for(Patient_POT_Apt_Procedure__c p : procedure_map.get(current_apt.patient_pot_apt__c)) {
	  	                if(p.clinical_procedure__r.doctor_required__c && doctor_stime==0)
	  	                  doctor_stime = btime;
	  	                btime += p.time_required__c.intValue();
	  	                if(p.clinical_procedure__r.doctor_required__c)
	  	                  doctor_etime = btime;
	  	              }
	  	            }
	  	          System.debug('Doctor Stime : ' + doctor_stime + ' Dr Etime : ' + doctor_etime);
		  	    }	      	
		  	    else 
		  	      current_apt = null;		  	    
		  	  }		
		  	  
		  	  //check for manual sched open block - default a mouseover so all blocks are eligible
	  	   	  if(manual_search && blank_cell) {
	  	   	  	cc.cell_css += '-generic ';
		  	    cc.onmouseover_event = 'display_noncell_msched(this,\'' + cr.id + '\',' + ctime + ');return false;';
		  	    cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-container ';
		  	    cc.cell_text += '&nbsp;';
	  	   	  }
		  	  
	  	   	}
	  	   	
	  	   	//check for an open cell - room block combination
	  	   	System.debug('Block Check - ' + all_room_block_map.get(cr.id) + ' Css : ' + cc.cell_css);
	  	   	Set<String> blank_cell_types = new Set<String> {'cc-clinical-calendar-schedule-cell-time-container-generic  cc-clinical-calendar-schedule-cell-time-container ','cc-clinical-calendar-schedule-cell-time-container'};
	  	   	if(all_room_block_map.get(cr.id)!=null && blank_cell_types.contains(cc.cell_css)) {
	  	   	  System.debug('Checking for a room block');
	  	   	  if(all_room_block_map.get(cr.id).get(ctime)!=null) {
	  	   	  	System.debug('Blocking cell - ' + ctime);
	  	   	  	cc.cell_css += ' cc-clinical-calendar-schedule-cell-time-blocked ';
	  	   	  	Integer offset = block_count * 20;
    	        cc.cell_style = 'background-position: ' + offset + 'px; ';
	  	   	  	cc.onmouseover_event = 'return false;';
	  	   	  	if(all_room_block_map.get(cr.id).get(ctime).contains('End Block'))
	  	   	  	  cc.cell_style += ' border-bottom: 1px solid black;';
	  	   	  	if(block_count==0) {
	  	   	  	  String[] block_text = all_room_block_map.get(cr.id).get(ctime).split(':');
	  	   	  	  cc.cell_text += block_text[0].replace('End Block','');
	  	   	  	  cc.top_css += ' z-index: ' + current_z-- + ';';
	  	   	  	  //cc.cell_text += all_room_block_map.get(cr.id).get(ctime).replace('End Block','');
	  	   	  	  if(block_text.size()>1)
	  	   	  	    if((block_text[1]=='null'?'':block_text[1])!='') {
		  	    	  //honestly,  need to set up a different tooltip style for this at some point.  I've loaded it up with inline styles to get it to work for now,  but it's a bit of a mess
		  	          cc.confirmation_html = '<div class="cc-calendar-block-confirmationStatus cc-calendar-block-confirmationStatus-default cc-hover-tooltips-confirmationStatus" onmouseover="confirmation_hide_patient_tooltip(this);" onmouseout="confirmation_display_patient_tooltip(this);"  ><i class="ccf-notes"></i><div class="cc-tooltip cc-center " style="z-index:10400;position: absolute;color: white; background: #39b17f; height: auto;top:50%;padding-left: 10px; padding-right: 10px;padding-top: 5px;padding-bottom: 5px;border-radius: 6px;font-weight: 300;letter-spacing: 1px;font-size: 10pt;box-shadow: -1px 9px 31px -4px rgba(0,0,0,0.75);transition: .5s;">' 
		  	            + block_text[1] + '</div></div>';
		  	        }
	  	   	  	  cc.cell_css += ' top-cell';
	  	   	  	}	  	   	  	
	  	   	  	block_count++;	  	   	  	  
	  	   	  } else
	  	   	    block_count = 0;
	  	   	}
	  	   	
	  	    cal_column.all_cells.add(cc);
	  	    minute +=10;
	  	  }
	  	}
	  	//add the column to the week
	  	week_column.add(cal_column);	
	  }
  	}
  	if(week_column.size()>7)
  	  column_override_css = 'max-width:10%;width:10%;';
  	return week_column;
  }
  
  public class room_tracker {
  	public Clinical_Room__c room {get; set;}
  	public List<Clinical_Apt_Calendar__c> all_blocks {get; set;}
  	public Integer current_position {get; set;}
  	public Integer shour {get; set;}
  	public Integer sminute {get; set;}
  	public Integer stime {get; set;}
  	public Integer ehour {get; set;}
  	public Integer eminute {get; set;}
  	public Integer etime {get; set;}
  	public Integer room_number {get; set;}
  	public Clinical_Apt_Calendar__c current_apt {get; set;} 
  	
  	public room_tracker(Clinical_Room__c cr, Integer rnum) {
  	  this.room = cr;
  	  this.room_number = rnum;
  	  reset_room();  	 
  	}
  	
  	public void reset_room() {
  	  all_blocks = new List<Clinical_Apt_Calendar__c>{};
  	  current_position = -1;  
  	  shour = 0;
  	  sminute = 0;
  	  ehour = 0;
  	  eminute = 0;	  
  	  stime = 0;
  	  etime = 0;
  	}
  	
  	public void get_next_apt() {
  	  current_position++;
  	  if(current_position<=(all_blocks.size()-1)) {
	    current_apt = all_blocks.get(current_position);
	  	shour = (current_apt.start_hour_int__c==null?0:current_apt.start_hour_int__c.intvalue());
	  	sminute = (current_apt.start_minute_int__c==null?0:current_apt.start_minute_int__c.intvalue());
	  	stime = (shour * 60 + sminute);
	  	ehour = (current_apt.end_hour_int__c==null?0:current_apt.end_hour_int__c.intvalue());
	  	eminute = (current_apt.end_minute_int__c==null?0:current_apt.end_minute_int__c.intvalue());
	  	etime = (ehour * 60 + eminute);
	  }	   
  	}
  	
  	public String getroom_num() {
  	  return String.valueof(room_number); 
  	  //return String.valueof(room.sort_order__c);
  	}
  }
  
  public weekly_calendar_column[] getweekly_calendar_info() {
  	List<weekly_calendar_column> week_column = new List<weekly_calendar_column>();
  	Map<Integer,String> dow_name = new Map<Integer,String>();
  	dow_name.put(1,'Mon ' + current_date.tostartofWeek().adddays(1).month() + '/' + current_date.tostartofWeek().adddays(1).day());
  	dow_name.put(2,'Tue ' + current_date.tostartofWeek().adddays(2).month() + '/' + current_date.tostartofWeek().adddays(2).day());
  	dow_name.put(3,'Wed ' + current_date.tostartofWeek().adddays(3).month() + '/' + current_date.tostartofWeek().adddays(3).day());
  	dow_name.put(4,'Thu ' + current_date.tostartofWeek().adddays(4).month() + '/' + current_date.tostartofWeek().adddays(4).day());
  	dow_name.put(5,'Fri ' + current_date.tostartofWeek().adddays(5).month() + '/' + current_date.tostartofWeek().adddays(5).day());
  	dow_name.put(6,'Sat ' + current_date.tostartofWeek().adddays(6).month() + '/' + current_date.tostartofWeek().adddays(6).day());
  	dow_name.put(7,'Sun ' + current_date.tostartofWeek().adddays(7).month() + '/' + current_date.tostartofWeek().adddays(7).day());
  	//build the label column
  	Weekly_Calendar_Column cal_column = new weekly_calendar_column();
  	cal_column.header_name = 'Time Label';
    cal_column.all_cells.addAll(getWeekly_Label_column());
    week_column.add(cal_column);	
    //pull a list of clinical rooms here and build a map of room tracker instances
    Map<ID,room_tracker> room_track_map = new Map<ID,room_tracker>();
    Set<ID> consult_room_id = new Set<ID>();
    Set<String> room_set = new Set<String>();
    if(room_type=='PSCombo') {
      room_set.add('Prosth');
      room_set.add('Surgery');
    }
    else
      room_set.add(room_type);  
    Integer current_room_count = 1;
    for(Clinical_Room__c cr : [select id,name,sort_order__c from Clinical_Room__c where room_type__c in :room_set and center_information__c = :current_center.id order by room_type__c,sort_order__c]) {
      consult_room_id.add(cr.id);      
      room_track_map.put(cr.id,new room_tracker(cr,current_room_count));
      current_room_count++;
    }    
  	//work through M-F
  	//set our strating date - go to start of week and add one day to get to Monday
  	Date tracking_date = current_date.tostartofWeek().adddays(1);
  	for(Integer dow=1;dow<6;dow++) {  	
  	  cal_column = new weekly_calendar_column();
  	  cal_column.header_name = dow_name.get(dow); 
  	  //check to see if we have any weather data for this date - if so load it
  	  if(current_week_weather_map.get(tracking_date)!=null)
  	    cal_column.day_weather = current_week_weather_map.get(tracking_date);  
  	   
  	  //reset all of our room trackers
  	  for(room_tracker rt : room_track_map.values()) {
  	  	rt.reset_room();
  	  }
  	  //pull a list of clinical apt blocks for this day and work through our rooms to build them out  	  
  	  for(Clinical_Apt_Calendar__c apt : [Select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.OwnerId,  c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
  	    where apt_date__c = :tracking_date and clinical_room__c in :consult_room_id and account__c != null order by stime__c]) {
  	  	room_track_map.get(apt.clinical_room__c).all_blocks.add(apt);
  	  }              
      //work through our rooms and grab the first apt if available
      for(room_tracker rt : room_track_map.values()) {
  	  	rt.get_next_apt();
  	  }
  	  //work through the day and build out our cells
  	  Integer hour;
	  Integer minute;  	
  	  for(hour=getstart_hour_limit();hour<getend_hour_limit();hour++) {
	  //for(hour=7;hour<20;hour++) {
	  	minute = 0;
	  	while(minute<60) {
	  	  System.debug('Hour : ' + hour + ' Minute : ' + minute + ' DOW : ' + dow);
	  	  Integer ctime = (hour * 60) + minute;
	  	  //create our container cell for this time block
	  	  weekly_calendar_cell holder_cell = new weekly_calendar_cell('cc-clinical-calendar-schedule-cell-time-container','',hour,minute);	  	  
	  	  //loop through our room tracker and see what kind of cell we need here
	  	  for(room_tracker rt : room_track_map.values()) {
	  	  	//if current apt is null,  we won't take action
	  	  	if(rt.current_apt!=null) {
	  	  	  //check to see if the current apt start time matches our current cell
	  	  	  if(rt.shour==hour && rt.sminute==minute) {
	  	  	  	weekly_calendar_sub_cell scell = new weekly_calendar_sub_cell('cc-cal-subCell-' + rt.getroom_num() + '-top',rt.room.name,hour,minute,'cc-cal-subCell-' + rt.getroom_num() + '-container',rt.current_apt.id);
                //to-do : build tooltip and event info here if any	  	  	  		  	  	  	
	  	  	  	holder_cell.sub_cells.add(scell);
	  	  	  }
	  	  	  //check to see if block matches end time
	  	  	  else if(rt.ehour==hour && rt.eminute==minute) {
	  	  	  	weekly_calendar_sub_cell scell = new weekly_calendar_sub_cell('cc-cal-subCell-' + rt.getroom_num() + '-bottom','',hour,minute,'cc-cal-subCell-' + rt.getroom_num() + '-container',rt.current_apt.id);
                //to-do : build tooltip and event info here if any	  	  	  		  	  	  	
	  	  	  	holder_cell.sub_cells.add(scell);
	  	  	  	//grab the next apt block for this room
	  	  	  	rt.get_next_apt();
	  	  	  }
	  	  	  //check to see if block is between start/end times
	  	  	  else if(ctime >= rt.stime && ctime <= rt.etime) {
	  	  	  	weekly_calendar_sub_cell scell = new weekly_calendar_sub_cell('cc-cal-subCell-' + rt.getroom_num(),'',hour,minute,'cc-cal-subCell-' + rt.getroom_num() + '-container',rt.current_apt.id);
                //to-do : build tooltip and event info here if any	  	  	  		  	  	  	
	  	  	  	holder_cell.sub_cells.add(scell);
	  	  	  }
	  	  	  //if none of the time conditions hit,  then don't add a cell
	  	  	}
	  	  }
	  	  //add holder cell to cal_column
	  	  cal_column.all_cells.add(holder_cell);
	  	  minute += 10;	  	  
	  	}
	  }
  	  //add the column to the week
  	  week_column.add(cal_column);  
  	  tracking_date = tracking_date.addDays(1);	  
  	}
  	return week_column;
  }
  
  public void save_default_view() {
  	try {
  	  User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];
  	  u.default_calendar_room__c = room_type;
  	  u.default_calendar_view__c = calendar_view;
  	  update u;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update default view.  Please contact IT for help'));
      ApexPages.addMessages(e);
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
  
  public String getblock_formatted_date() {
  	Datetime adate = Datetime.newinstance(apt_block.apt_date__c.year(),apt_block.apt_date__c.month(),apt_block.apt_date__c.day());
  	return adate.format('M/dd/yyyy');
  }
  
  public Clinical_Apt_Calendar__c getapt_block(String apt_id) {
  	try {
      Clinical_Apt_Calendar__c my_apt = [Select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.account__r.personmobilephone, c.account__r.phone, account__r.email__c,
  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, 
  	    c.confirmation_status__c, c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, 
  	    account__r.recent_height_feet__c, account__r.recent_height_inches__c, account__r.recent_weight__c, patient_pot_apt__r.clinical_Appointment__r.clinical_Notes_Form__c,
  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c, (Select Id From Clinical_Apt_Histories__r),
  	    account__r.distance_to_center__c, arrival_time__c, ready_time__c, Apt_Start_Time__c, Apt_Complete_Time__c, patient_left_time__c, patient_pot_apt__r.patient_pot__c, patient_pot_apt__r.doctor_notes__c,
  	    clinical_room__r.name, patient_pot_apt__r.patient_pot__r.name
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
  	last_apt_id = apt_block.id;
  	calendar_modal_display = 'block_info';
  }
  
  public void close_calendar_modal() {
  	display_calendar_modal = false;
  	apt_block = null;
  	calendar_modal_display = null;
  }
  
  public Boolean getallow_incomplete() {
  	Boolean rvalue = false;
  	Set<String> valid_status = new Set<String> {'Appointment Started','Patient Arrived','Patient Ready'};  	
  	if(valid_status.contains(apt_block.apt_status__c==null?'':apt_block.apt_status__c) && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today())
  	  rvalue = true;
  	return rvalue;
  }
  
  public Boolean getallow_arrived() {
  	Boolean rvalue = false;
  	if((apt_block.apt_status__c==null?'':apt_block.apt_status__c)=='' && apt_block.apt_date__c >= System.today().adddays(-4) && apt_block.apt_date__c <= System.today() )
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
  
  public void create_surgical_notes_instance(Clinical_Note_Instance__c cn) {
  	//grab the extraction field from the most recent surgical rx form tied to this POT
  	String eteeth = null;
  	try {
      Surgical_RX__c srx = [select id,extraction_teeth__c from Surgical_Rx__c where Patient_POT__c = :apt_block.patient_pot_apt__r.patient_pot__c order by createddate desc limit 1];
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
      //patient doesn't have a surgical rx form....this shouldn't really happen,  but with older imports and testing,  it will happen once in awhile  	  
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
  
  public void create_prosth_exam_form_notes_instance(Clinical_Note_Instance__c cn) {
    Prosth_Exam_Form__c pe = new Prosth_Exam_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
    insert pe;           
  }
  
  public void create_redo_surgery_notes_instance(Clinical_Note_Instance__c cn) {
  	Redo_Surgery_Form__c rs = new Redo_Surgery_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id);
  	insert rs;
  }
  
  public void create_repair_notes_instance(Clinical_Note_Instance__c cn, String rtype) {
  	Repair_Note_Form__c rs = new Repair_Note_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c, Clinical_Note_Instance__c = cn.id, repair_apt_type__c = rtype);
  	insert rs;
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
  	  List<Surgical_Note_Implant__c> implant_list = [select s.Unique_Placement__c, s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Ostel__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.JIG_Ostell_ISQ__c, s.JIG_Notes_Form__c, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Torque_Value__c, s.Implant_Torque_Number__c, s.Implant_System_Value__c, s.Implant_Length__c, s.Id, s.Healing_Cap_Placed__c, s.Final_Ostell_ISQ__c, s.Final_Notes_Form__c, s.CreatedDate, s.CreatedById, s.Conversion_Torque_Value__c, s.Conversion_Notes_Form__c, s.Closure_Screw_Placed__c, s.Buried_Implant__c, s.Bone_Density__c, s.Abutment_Straight__c, s.abutment_width__c, s.Abutment_Collar_Height__c 
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
  	  List<Surgical_Note_Implant__c> implant_list = [select s.Unique_Placement__c, s.SystemModstamp, s.Surgical_Notes_Form__c, s.OwnerId, s.Ostel__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.JIG_Ostell_ISQ__c, s.JIG_Notes_Form__c, s.IsDeleted, s.Implant_Width__c, s.Implant_Type__c, s.Implant_Torque_Value__c, s.Implant_Torque_Number__c, s.Implant_System_Value__c, s.Implant_Length__c, s.Id, s.Healing_Cap_Placed__c, s.Final_Ostell_ISQ__c, s.Final_Notes_Form__c, s.CreatedDate, s.CreatedById, s.Conversion_Torque_Value__c, s.Conversion_Notes_Form__c, s.Closure_Screw_Placed__c, s.Buried_Implant__c, s.Bone_Density__c, s.Abutment_Straight__c, s.abutment_width__c, s.Abutment_Collar_Height__c 
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
  
  public void mark_apt_incomplete() {
  	if(cancel_reason=='NA') 
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid incomplete reason'));
  	else {
  	  try {
  	    apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
        String block_id = apt_block.id;
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(getallow_incomplete()) {
          apt_block.Apt_Complete_Time__c = System.now();
          apt_block.Apt_Status__c = 'Incomplete';      
          //need to clone patient pot apt and shift it after this apt
          Patient_pot_apt__c current_apt = [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Doctor_Notes__c, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c 
            From Patient_POT_Apt__c p
            where id = : apt_block.patient_pot_apt__c];
          //grab all of the pot apt procedures tied to this apt
          List<Patient_POT_Apt_Procedure__c> current_apt_procs = [Select p.Time_Required__c, p.Target_Teeth__c, p.SystemModstamp, p.Sort_Order__c, p.Procedure_Description__c, p.Patient_POT_Apt__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.IsActive__c, p.Insurance_Fee__c, p.Id, p.CreatedDate, p.CreatedById, p.Cost__c, p.Clinical_Procedure__c, p.Allow_Tooth_Selection__c, p.ADA_Code__c 
            From Patient_POT_Apt_Procedure__c p
            where patient_pot_apt__c = :current_apt.id];                      
          //grab all of the apts after this event so the sort order can be incremented
          List<Patient_pot_apt__c> increment_apts = [select id,sort_order__c from Patient_pot_apt__c where patient_pot__c = :current_apt.patient_pot__c and sort_order__c > :current_apt.sort_order__c];                    
          Patient_pot_apt__c new_apt = current_apt.clone(false,true,false,false);
          new_apt.sort_order__c += 1;
          new_apt.days_out__c = 0;
          insert new_apt;
          //clone the procedures and point to the patient_pot_apt__c we inserted
          List<Patient_Pot_Apt_Procedure__c> new_apt_procs = current_apt_procs.deepclone();
          for(Patient_pot_apt_procedure__c proc : new_apt_procs) {
            proc.patient_pot_apt__c = new_apt.id; 
          }
          insert new_apt_procs;
          if(increment_apts.size()>0) {
            for(Patient_pot_apt__c ppa : increment_apts) {
              ppa.sort_order__c += 1;
            }        
            update increment_apts;
          }              
          update apt_block;
          make_history_entry('Incomplete','Consult status has been changed to Incomplete');
          close_calendar_modal();                    
        }
      } catch (Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
      }	
    }
  }
  
  
    
  public void mark_apt_arrived() {
  	try {
  	  apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      String block_id = apt_block.id;
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_arrived()) {
        apt_block.Arrival_Time__c = System.now();
        apt_block.Apt_Status__c = 'Patient Arrived';
        Clinical_Note_Instance__c cn = new Clinical_note_Instance__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, IsActive__c = true, Clinical_Apt_Calendar__c = block_id, Account__c = apt_block.account__c);      

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
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Try In Notes Form')
            create_try_in_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Prosth Exam Form')
            create_prosth_exam_form_notes_instance(cn);            
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Final Notes Form')
            create_final_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Redo Surgery Form')
            create_redo_surgery_notes_instance(cn);
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='General Repair Notes')
            create_repair_notes_instance(cn,'Unknown');
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Rework Repair Notes')
            create_repair_notes_instance(cn,'Rework');
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Redeliver Notes')
            create_repair_notes_instance(cn,'Redeliver');
          if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Repair Work Notes')
            create_repair_notes_instance(cn,'Repair');
        } 
        //modified by cm on 11/1/2016 - Andy requested window stay open when choosing this status 
        //close_calendar_modal();    
      }
    } catch (Exception e) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
        ApexPages.addMessages(e);                  
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('HRx Notes Generation Error ');
        message.setHtmlbody('An error was encountered during notes creation.<br />' + e);
  	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','amcmullen@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });  
    }              
  }
  
  public void mark_apt_ready() {
  	try {
      apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_ready()) {
        apt_block.Ready_Time__c = System.now();
        apt_block.Apt_Status__c = 'Patient Ready';
        update apt_block;
        make_history_entry('Patient Ready','Consult status has been changed to Patient Ready');
        //modified by cm on 11/1/2016 - Andy requested window stay open when choosing this status
        //close_calendar_modal();
      }                     
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
      ApexPages.addMessages(e);                  
    } 
  }
  
  public void mark_apt_started() {
  	try {
      apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_started()) {
        apt_block.Apt_Start_Time__c = System.now();
        apt_block.Apt_Status__c = 'Appointment Started';
        update apt_block;
        make_history_entry('Appointment Started','Consult status has been changed to Appointment Started');
        //modified by cm on 11/1/2016 - Andy requested window stay open when choosing this status
        //close_calendar_modal();            
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
      ApexPages.addMessages(e);                  
    }          
  }
  
  public void mark_apt_completed() {
  	try {
      apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_completed()) {
        apt_block.Apt_Complete_Time__c = System.now();
        apt_block.Apt_Status__c = 'Completed';
        update apt_block;
        make_history_entry('Completed','Consult status has been changed to Completed');
        close_calendar_modal();            
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
      ApexPages.addMessages(e);                  
    }          
  }
  
  public void mark_apt_left() {
  	try {
      apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_patient_left()) {
        apt_block.Patient_Left_Time__c = System.now();
        apt_block.Apt_Status__c = 'Patient Left';
        update apt_block;
        make_history_entry('Patient Left','Consult status has been changed to Patient Left');
        close_calendar_modal();                  
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
      ApexPages.addMessages(e);                  
    }          
  }
  
  public void mark_apt_reset() {
  	try {
      apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_reset()) {
        apt_block.Arrival_Time__c = null;
        apt_block.Ready_Time__c = null;
        apt_block.Apt_Start_Time__c = null;
        apt_block.Apt_Complete_Time__c = null;
        apt_block.Patient_Left_Time__c = null;      
        apt_block.Apt_Status__c = null;
        update apt_block;
        //check to see if we need to remove the clinical note instance and surgery form - should
        //removed this per a discussion with Andy - loss of the note has been deemed more critical than keeping the notes page clean.  Some centers have used reset incorrectly
        /*List<Clinical_Note_Instance__c> cn_list = [select id from Clinical_note_Instance__c where clinical_apt_calendar__c = :apt_block.id and reviewed_by__c = null];           
        
        update apt_block;
        make_history_entry('Reset','CA or Admin has reset this apt block');
        if(cn_list.size()>0) {          
          List<Surgical_Notes_Form__c> sf_list = [select id from Surgical_Notes_Form__c where clinical_apt_calendar__c = :apt_block.id and clinical_note_instance__c in :cn_list];
          if(sf_list.size()>0) {
          	List<Surgical_Note_Implant__c> sni_list = [select id from Surgical_Note_Implant__c where Surgical_Notes_Form__c in :sf_list];
          	if(sni_list.size()>0)
          	  delete sni_list;
          	delete sf_list;
          }          
          delete cn_list;
        } */       
        close_calendar_modal();                  
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
      ApexPages.addMessages(e);                  
    }          
  }
  
  public void mark_apt_no_show() {
  	try {
      apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      //double check and verify that someone else hasn't hit the button already or moved them further up the stream
      if(getallow_no_show()) {     
        apt_block.Apt_Status__c = 'No Show';
      
        update apt_block;
        make_history_entry('No Show','Consult status has been changed to No Show');
        close_calendar_modal();                  
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update the apt status.  Please contact IT for help'));
      ApexPages.addMessages(e);                  
    }          
  }
  
  public void pending_reschedule_search_view() {
  	//make sure we have a valid reason before continuing
  	block_view = 'Reschedule';
  	current_edit_id = apexpages.currentpage().getparameters().get('prid');
  	apt_block = getapt_block(current_edit_id);
  	set_pending_cancel_reason(); 
  	sched_apt = [Select p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, p.Clinical_Appointment__c,
  	  p.Appointment_Description__c, name, p.clinical_appointment__r.center_information__c, p.clinical_appointment__r.name
  	  From Patient_POT_Apt__c p
  	  where id = :apt_block.patient_pot_apt__c];
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
  	search_pager = new dp_clinical_patient.paged_results();
  }
  
  public void reschedule_search_view() {
  	//make sure we have a valid reason before continuing
  	if(cancel_reason=='NA') 
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid reschedule reason'));
  	else {
  	  sched_apt = [Select p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, p.Clinical_Appointment__c, 
  	    p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c, p.clinical_appointment__r.name
  	    From Patient_POT_Apt__c p
  	    where id = :apt_block.patient_pot_apt__c];
  	  calendar_modal_display = 'reschedule_search_view';
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
  	  search_pager = new dp_clinical_patient.paged_results();
  	}  	
  }
  
  public void reschedule_reason_view() {
  	calendar_modal_display = 'reschedule_reason_view';
  	cancel_reason = 'NA';
  }
  
  public void incomplete_reason_view() {
  	calendar_modal_display = 'incomplete_reason_view';
  	cancel_reason = 'NA';
  }
  
  public void cancel_reason_view() {
  	calendar_modal_display = 'cancel_reason_view';
  	cancel_reason = 'NA';
  }
  
  public void switch_room_view() {
  	calendar_modal_display = 'switch_room_view';
  	apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  }
  
  public void switch_doctor_view() {
  	calendar_modal_display = 'switch_doctor_view';
  	apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  	manual_apt = [Select p.id, p.Sort_Order__c, p.Patient_POT__c, p.patient_pot__r.account__r.name, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, 
  	      p.Clinical_Appointment__c, p.clinical_appointment__r.name, p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c
  	    From Patient_POT_Apt__c p
  	    where id = :apt_block.patient_pot_apt__c];  	
  	msearch_minute = apt_block.start_minute__c;
  	Integer mhour = apt_block.start_hour_int__c.intvalue();
  	msearch_suffix = 'AM';
  	if(mhour==12) {
  	  msearch_suffix = 'PM';
  	}
  	else if(mhour>12) {
  	  mhour = mhour - 12;
  	  msearch_suffix = 'PM';
  	}   	  	
  	msearch_hour = String.valueof(mhour);
  	calculate_doctor_results();
  }
  
  public void modal_go_back() {
  	calendar_modal_display = 'block_info';
  }
  
  public Boolean getallow_apt_change() {
  	//make sure it's not in the past,  and that the status is null
  	//see if we have moved this to clipboard...that changes the check 
  	Integer clip_count = [select count() from clinical_clipboard__c where patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	if(clip_count>0) {
  	  Set<String> possible_statuses = new Set<String> {'Pending Reschedule','Patient Arrived','Patient Ready','Appointment Started'};
  	  if((apt_block.apt_status__c==null || possible_statuses.contains(apt_block.apt_status__c)) && apt_block.apt_date__c>=System.today())
  	    return true;
  	  else
  	    return false;
  	}  	
  	else if((apt_block.apt_status__c==null || apt_block.apt_status__c == 'Pending Reschedule') && apt_block.apt_date__c>=System.today())
  	  return true;
  	else
  	  return false;
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
  
  public List<Selectoption> getincomplete_reason_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('NA','Select One'));
  	for(Schema.PicklistEntry Value : Clinical_Apt_History__c.Incomplete_Reason__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  }
  
  public Integer gettime_minutes(Integer my_time) {
  	Integer my_minutes = math.mod(my_time,60);
  	return my_minutes;
  }
  
  public Integer gettime_hours(Integer my_time) {
  	Decimal my_hours = math.floor(my_time/60);
  	return my_hours.intValue();
  }
  
  public void set_pending_cancel_reason() {  	
  	//grab our apt block
  	Clinical_Apt_Calendar__c ca = [Select c.Stime__c, c.Id, c.Etime__c, c.apt_date__c From Clinical_Apt_Calendar__c c where id = :current_edit_id];
  	Boolean doctor_block = false;
  	Boolean room_block = false;
  	
  	Set<ID> block_id = new Set<ID>();
  	//pull a list of blocks that contain our apt
  	for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Etime__c, c.Clinical_Room__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c
  	  From Clinical_Time_Restriction__c c
  	  where block_date__c = :ca.apt_date__c
  	  and stime__c <= :ca.stime__c and etime__c >= :ca.etime__c
  	  and (clinical_room__r.center_information__c = :current_center.id or center_information__c = :current_center.id)]) {
  	  block_id.add(ctr.id);
  	  if(ctr.block_type__c=='Doctor')
  	    doctor_block = true;
  	  if(ctr.block_type__c=='Room')
  	    room_block = true;
  	}  	
  	//pull a list of blocks that have a start time during our apt
  	for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Etime__c, c.Clinical_Room__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c 
  	  From Clinical_Time_Restriction__c c
  	  where block_date__c = :ca.apt_date__c
  	  and id not in :block_id
  	  and stime__c >= :ca.stime__c and stime__c < :ca.etime__c
  	  and (clinical_room__r.center_information__c = :current_center.id or center_information__c = :current_center.id)]) {
  	  block_id.add(ctr.id);
  	  if(ctr.block_type__c=='Doctor')
  	    doctor_block = true;
  	  if(ctr.block_type__c=='Room')
  	    room_block = true;
  	}  	  	
  	//pull a list of blocks that have an end time during our apt
  	for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Etime__c, c.Clinical_Room__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c 
  	  From Clinical_Time_Restriction__c c
  	  where block_date__c = :ca.apt_date__c
  	  and id not in :block_id
  	  and etime__c >= :ca.stime__c and etime__c < :ca.etime__c
  	  and (clinical_room__r.center_information__c = :current_center.id or center_information__c = :current_center.id)]) {
  	  block_id.add(ctr.id);
  	  if(ctr.block_type__c=='Doctor')
  	    doctor_block = true;
  	  if(ctr.block_type__c=='Room')
  	    room_block = true;
  	}  	  	
  	if(doctor_block && room_block)
  	  //this should be rare,  and yes Andy and I had fun with this one (CM 6/22/2016)
  	  cancel_reason = 'Roctor Block';
  	else if(doctor_block)
  	  cancel_reason = 'Doctor Block';
  	else if(room_block)
  	  cancel_reason = 'Room Block';
  }
  
  public void cancel_pending_reschedule_apt() {
  	//set our cancel reason
  	set_pending_cancel_reason();
  	//call the cancel action
  	apt_block = getapt_block(current_edit_id);
  	cancel_scheduled_apt();
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
  	  last_apt_id = null;
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
          	//modified by cm on 4/3/2017 - The block we're looking at here is not in the database,  so we can't delete it.  
          	//Instead,  we just don't add it to the revised room blocks list and it'll be removed
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
  	  /*Integer time_before = 0;
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
      } */
      apt_time_makeup apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
      Integer time_before = apt_time.time_before;
      Integer time_dr = apt_time.time_dr;
      Integer time_after = apt_time.time_after;
      
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
          where c.user__c = :apt_doctor and c.block_date__c = :apt_date and c.center_information__c = :current_center.id]) {
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
  	              End_Minute__c = ctr.start_minute__c, End_Hour__c = ctr.start_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id );
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
  	  
  	  //grabbing old search inventory prior to deletes,  so we don't have orphaned records
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
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :search_date and center_information__r.name = :current_center.name];
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
  
  public dp_clinical_patient.search_date[] getapt_search_results() {
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
  	//Map<ID,CR_Schedule_Block__c> block_map = new Map<ID,CR_Schedule_block__c> ([Select id from CR_Schedule_Block__c where id in 
//      (Select c.CR_Schedule_Block__c From CR_Sched_Block_Authorized_Apt__c c where clinical_appointment__c = :sched_apt.clinical_appointment__c)]);
  //  Set<ID> block_ids = block_map.keySet();
    Set<ID> block_ids = new Set<ID>();
    for(CR_Schedule_Block__c csb : [Select id from CR_Schedule_Block__c where id in 
      (Select c.CR_Schedule_Block__c From CR_Sched_Block_Authorized_Apt__c c where clinical_appointment__c = :clinical_apt_id)]) {
      	block_ids.add(csb.id);
      } 
    
    //query 2 - blocks that allow anything
//    block_map = new Map<ID,CR_Schedule_Block__c> ([select id from CR_Schedule_Block__c where allow_all__c = true and clinical_room__r.center_information__r.name = 'Denver']);
  //  block_ids.addAll(block_map.keySet());
    for(CR_Schedule_Block__c csb : [select id from CR_Schedule_Block__c where allow_all__c = true and clinical_room__r.center_information__c = :current_center.id]) {
  	  block_ids.add(csb.id);
    }
    
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
  	if(sched_apt.sort_order__c==1)
  	  earliest_apt_date = System.today();
  	else {
  	  //we need to look at the apt date for the previous apt in the plan of treatment...then add days out to it to get our filter
  	  Integer prior_sort = sched_apt.sort_order__c.intValue() - 1;
  	  //modified by cm on 10/3/2017 - now looking for the first prior appointment that is NOT a repair appointment
  	  //Patient_POT_Apt__c prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c 
  	  //where sort_order__c = :prior_sort and patient_pot__c = :sched_apt.patient_pot__c and isactive__c = true];
  	  Patient_POT_Apt__c prior_apt ;
  	  try {
       prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c
         where sort_order__c <= :prior_sort and patient_pot__c = :manual_apt.patient_pot__c and isactive__c = true
         and clinical_appointment__r.isrepair__c = false order by sort_order__c desc limit 1];
      } catch (Exception e) {
      	try {
          //this would occur,  if all of the prior apts happen to be repair (private practice / legacy import situation)
          prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c
            where sort_order__c <= :prior_sort and patient_pot__c = :manual_apt.patient_pot__c and isactive__c = true
            order by sort_order__c desc limit 1];
      	} catch (Exception e2) {
      	  //mostly here to handle odd data deletions etc
      	}
      }
  	  try {
  	    earliest_apt_date = prior_apt.clinical_apt_calendar__r[0].apt_date__c;
  	    earliest_apt_date = earliest_apt_date.addDays(sched_apt.days_out__c.intvalue());
  	  } catch (Exception e) {
  	  	//if this is null,  it means we had no date for the previous apt in the chain....that's an issue - use today.
  	  	earliest_apt_date = System.today();  
  	  }
  	}
  	if(earliest_apt_date<System.today())
  	  earliest_apt_date = System.today();
  	

    apt_time_makeup apt_time = new apt_time_makeup(sched_apt.id);
    Integer time_before = apt_time.time_before;
    Integer time_dr = apt_time.time_dr;
    Integer time_after = apt_time.time_after;
    
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
  	
  	//new paging stuff
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
  	  	
  	Map<Date,dp_clinical_patient.search_date> search_map = new Map<Date,dp_clinical_patient.search_date>(); 
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
  	  	  	dp_clinical_patient.search_date search_result = new dp_clinical_patient.search_date(csi.clinical_apt_calendar__r.apt_date__c, sched_apt,current_center.id);
  	  	  	search_result.green_top = green_top;
  	  	  	search_result.yellow_top = yellow_top;
  	  	  	search_map.put(csi.clinical_apt_calendar__r.apt_date__c,search_result);
  	  	  }
  	  	  //add this block to the match list
  	  	  dp_clinical_patient.possible_match m = new dp_clinical_patient.possible_match(csi,block_time);
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
  
  public void apt_search_next_page() {
    search_pager.next_page();
  }
  
  public void apt_search_prev_page() {
  	search_pager.prev_page();
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
  	  /*Integer time_before = 0;
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
      }*/
      apt_time_makeup apt_time = new apt_time_makeup(sched_apt.id);
      Integer time_before = apt_time.time_before;
      Integer time_dr = apt_time.time_dr;
      Integer time_after = apt_time.time_after;
      Integer total_time = time_before + time_dr + time_after; 
      //verify the doctor time is also still available...if not we have a problem.
      Integer doctor_stime = apt_stime + time_before;
      Integer doctor_etime = doctor_stime + time_dr;
      Integer doctor_available = [select count() from Clinical_Doctor_Inventory__c c where user__c = :apexpages.currentpage().getparameters().get('doctorid') and calendar_date__c = :ca.apt_date__c and
        stime__c <= :doctor_stime and etime__c >= :doctor_etime and center_information__c = :current_center.id];
      if(doctor_available==0) {
      	num_issues++;
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The doctor is no longer available for this apt.<br /> Please select a different time'));
      }  	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to verify reschedule availability.  Please contact IT for help ' + e.getLineNumber() + e.getCause()));
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
	  	  /*Integer time_before = 0;
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
	      }*/ 
	      apt_time_makeup apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
          Integer time_before = apt_time.time_before;
          Integer time_dr = apt_time.time_dr;
          Integer time_after = apt_time.time_after;
	      
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
  	    /*Integer time_before = 0;
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
        }*/
        apt_time_makeup apt_time = new apt_time_makeup(sched_apt.id);
        Integer time_before = apt_time.time_before;
        Integer time_dr = apt_time.time_dr;
        Integer time_after = apt_time.time_after;
        
        Integer total_time = time_before + time_dr + time_after; 
        //verify the doctor time is also still available...if not we have a problem.
        Integer doctor_stime = apt_stime + time_before;
        Integer doctor_etime = doctor_stime + time_dr;
        //this check is already done above...no need to run it here
        //Integer doctor_available = [select count() from Clinical_Doctor_Inventory__c c where user__c = :apexpages.currentpage().getparameters().get('doctorid') and calendar_date__c = :ca.apt_date__c and
          //stime__c <= :doctor_stime and etime__c >= :doctor_etime];
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
  	    Patient_Pot_Apt__c pa = [Select p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :sched_apt.id];
  	    //Patient_Pot_Apt__c pa = [Select p.Patient_POT__r.opportunity__c,p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :sched_apt.id]; 
  	    //ca.opportunity__c = pa.patient_pot__r.opportunity__c;
  	    ca.account__c = pa.patient_pot__r.account__c;
  	    ca.doctor__c = apexpages.currentpage().getparameters().get('doctorid'); 
  	
  	    //grab the doctor inventory - check if we have space before or after the scheduled apt (only worry about the doctor time) - create new blocks as needed
  	    List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    Clinical_Doctor_Inventory__c cdi = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
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
  	    
  	    ca.confirmation_status__c = 'Not Confirmed';
  	    //commit changes - Blocks
        System.debug('Modified Apt Block : ' + ca);
        update ca;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        System.debug('Doctor Inventory Deleted : ' + cdi);
        delete cdi;
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
        
        search_dates.add(ca.apt_date__c);  
  	    //loop through all days in the set and build search inventory for them
  	    for(Date sdate : search_dates) {
          //rebuild the search inventory for this day 
          List<Clinical_Search_Inventory__c> csi_old_temp = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :sdate and 
            clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :sdate
            and clinical_doctor_inventory__r.center_information__c = :current_center.id];
          csi_old.addall(csi_old_temp);
          //loop through all apts for this center/day where the block is open
          List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :sdate and center_information__r.name = :current_center.name];
          
          for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :sdate and
            clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	        //loop through doctor time for this center/day
  	        //modified this to pull from a list so it doesn't waste queries....this was running once for every block on the calendar which was ridiculous
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
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to schedule the new appointment.  Please contact IT for help ' + e.getLineNumber() + e.getcause()));
        ApexPages.addMessages(e);               
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('Rescheduling Error');
        message.setHtmlbody('An error occured during rescheduling - Schedule new apt.<br />' + e);
  	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com','amcmullen@clearchoice.com','jreish@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
  	  }	
  	  
  	}
  }
  
  public void calendar_date_change() {
  	if(manual_search)
  	  refresh_possible_map();
    current_weather = getweather_info(current_date);
  }
  
  public void refresh_possible_map() {
  	//calculate thresholds...yellow would be 75-85% of center number of lab techs * 555
  	Decimal green_top = (current_center.number_of_lab_techs__c * 555) * .75;
  	Decimal yellow_top = (current_center.number_of_lab_techs__c * 555) * .85;
  	manual_block_size = new Set<Integer>();
  	
  	//since we can now schedule in different centers,  first we need to check and see if the apt we're using is the correct one
  	String clinical_apt_id;
  	if(manual_apt.clinical_appointment__r.center_information__c==current_center.id)
  	  clinical_apt_id = manual_apt.clinical_appointment__c;
  	else {
      try { 
      	System.debug('Translating apt for schedule center');
  	    clinical_apt_id = [select id from clinical_appointment__c where name = :manual_apt.clinical_appointment__r.name and center_information__c = :current_center.id limit 1].id;
      } catch (Exception e) {
      	
      }
  	}
  	if(clinical_apt_id==null)
  	  clinical_apt_id = manual_apt.clinical_appointment__c;
  	
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
  	  doctor_ids.add(cd.doctor__c);
  	} 
  	
  	//Eligible Rooms
  	Map<ID,Clinical_Room__c> room_map = new Map<ID,Clinical_Room__C> ([select id,name from clinical_room__c where id in 
  	  (select clinical_room__c from Clinical_Room_Authorized_Apt__c where clinical_appointment__c = :clinical_apt_id)]);
  	Set<ID>room_ids = room_map.keySet();
  	    	
  	//figuring out time makeup
  	/*Integer time_before = 0;
  	Integer time_dr = 0;
  	Integer time_after = 0;
  	String current_stage = 'before';
  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
      where isactive__c = true and patient_pot_apt__c = :manual_apt.id order by sort_order__c]) {
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
    } */
    apt_time_makeup apt_time = new apt_time_makeup(manual_apt.id);
    Integer time_before = apt_time.time_before;
    Integer time_dr = apt_time.time_dr;
    Integer time_after = apt_time.time_after;
        
    Integer total_time = time_before + time_dr + time_after;    
    Integer loop_iterations = (total_time / 10) - 2;
  	System.debug('Loop iterations : ' + loop_iterations);
  	for(Integer loop_cnt = 0; loop_cnt < loop_iterations; loop_cnt++) {
  	  System.debug('loop cnt ' + loop_cnt);
  	  manual_block_size.add(loop_cnt);
  	}
    Integer total_before_dr =  time_before + time_dr;
    Integer total_after_dr = time_after + time_dr;     
    System.debug('Total Before + dr : ' + total_before_dr);
    System.debug('Total After + dr : ' + total_after_dr);    
  	
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
  	  c.clinical_apt_calendar__r.clinical_room__c,
  	  clinical_apt_calendar__r.apt_date__c
  	From 
  	  Clinical_Search_Inventory__c c
  	where 
  	  c.clinical_apt_calendar__r.cr_schedule_block__c in :block_ids
  	  and c.clinical_doctor_inventory__r.user__c in :doctor_ids
  	  and c.clinical_doctor_inventory__r.center_information__c = :current_center.id
  	  and c.clinical_apt_calendar__r.clinical_room__c in :room_ids
  	  and c.clinical_apt_calendar__r.apt_date__c = :current_date
  	  and c.total_minutes__c  >= :total_time
  	  and c.minutes_before_and_dr__c >=  :total_before_dr
  	  and c.minutes_after_and_dr__c >= :total_after_dr
  	  and c.minutes_dr_avail__c >= :time_dr
  	order by c.clinical_apt_calendar__r.clinical_room__c, c.clinical_apt_calendar__r.stime__c];  	  
  	     	  
  	System.debug('Possible Options : ' + possible_apts.size());
  	  	
  	possible_block_map = new Map<ID,Set<Integer>>();  	
  	//work through possible options and identify every 10 minute possibility.  If possibility would meet hour selection criteria,  add an entry for it into the custom objects
  	for(Clinical_Search_Inventory__c csi : possible_apts) {  		  		
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
  	  	//check to see if we have an entry in the map for this date yet  	  	
  	  	if(possible_block_map.get(csi.clinical_apt_calendar__r.clinical_room__c)!=null) {
  	  	  //if so,  add the block time to the set
  	  	  possible_block_map.get(csi.clinical_apt_calendar__r.clinical_room__c).add(block_time);
  	  	  System.debug('Added ' + block_time + ' to room : ' + csi.clinical_apt_calendar__r.clinical_room__c);
  	  	} else {
  	  	  //else build a new map entry
  	  	  Set<Integer> new_set = new Set<Integer>();
  	  	  new_set.add(block_time);
  	  	  possible_block_map.put(csi.clinical_apt_calendar__r.clinical_room__c,new_set);
  	  	  System.debug('New room added to map : ' + csi.clinical_apt_calendar__r.clinical_room__c + ' initial block ' + block_time);
  	  	}   	  	  	  
  	  	current_interval += 10;
  	  }
  	}  	
  }
  
  public void cancel_manual_schedule() {
  	manual_search = false;
  	manual_apt = null;
  }
  
  public void open_msearch_modal() {  	
  	Boolean allow_sched = true;
  	//see if this is a clipboard item with a note instance
  	Integer board_count = [select count() from clinical_clipboard__c where patient_pot_apt__c = :manual_apt.id and clinical_note_instance__c != null];
  	System.debug('Board Count = ' + board_count);
  	if(board_count>0 && current_date!=System.today()) {
  	  allow_sched = false;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Appointments marked in an arrived,  ready,  or started state can only be scheduled for the current day.'));
  	}
  	
  	if(allow_sched) { 
  	  display_msearch_modal = true;
  	  msearch_doctor = 'Any';
  	  Integer ctime = Integer.valueof(apexpages.currentpage().getparameters().get('ctime'));
  	  Integer mhour = ctime / 60;
  	  Integer mminute = Math.mod(ctime,60);
  	  msearch_suffix = 'AM';
  	  if(mhour==12) {
  	    msearch_suffix = 'PM';
  	  }
  	  else if(mhour>12) {
  	    mhour = mhour - 12;
  	    msearch_suffix = 'PM';
  	  } 
  	  	
  	  msearch_hour = String.valueof(mhour);
      msearch_minute = String.valueof(Math.mod(ctime,60));
  	
  	  modal_css = '';
      msearch_room = apexpages.currentpage().getparameters().get('rid');     
      calculate_doctor_results();
  	}    
  }
  
  //check map
  public Boolean getmsearch_possible_conflict() {
  	Boolean conflict = true;  	
  	Integer mhour = Integer.valueof(msearch_hour);
  	Integer mminute = Integer.valueof(msearch_minute);
  	if(mhour!=12 && msearch_suffix=='PM') 
  	  mhour += 12;
  	Integer ctime = (mhour*60) + mminute;  	

    if(possible_block_map.get(msearch_room)!=null)
      if(possible_block_map.get(msearch_room).contains(ctime))
        conflict = false;
    return conflict;  
  }
   
  public void close_msearch_modal() {
  	display_msearch_modal = false;  	
  } 
  
  public void switch_doctor() {
  	msearch_doctor = apexpages.currentpage().getparameters().get('docid');
  	if(msearch_doctor=='Any')
  	  calculate_doctor_results();
  }
  
  /*public List<Selectoption> getactive_doctor_option() {
    List<Selectoption> doc_list = new List<Selectoption>();
    doc_list.add(new Selectoption('Any','Any Doctor'));
  	for(User doctor : [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name order by isactive desc, name]) {
  	  doc_list.add(new Selectoption(doctor.name,doctor.name));
  	}
  	return doc_list;
  }*/
  
  public List<User> getactive_doctor_list() {
  	//since we can now schedule in different centers,  first we need to check and see if the apt we're using is the correct one
  	String clinical_apt_id;
  	if(manual_apt.clinical_appointment__r.center_information__c==current_center.id)
  	  clinical_apt_id = manual_apt.clinical_appointment__c;
  	else {
      try { 
      	System.debug('Translating apt for schedule center');
  	    clinical_apt_id = [select id from clinical_appointment__c where name = :manual_apt.clinical_appointment__r.name and center_information__c = :current_center.id limit 1].id;
      } catch (Exception e) {
      	
      }
  	}
  	if(clinical_apt_id==null)
  	  clinical_apt_id = manual_apt.clinical_appointment__c;  	    	  
  	
  	//adjusting this so it only pulls doctors who are eligible to work on this apt  	 	  	
  	/*modified by cm on 8/14/2017 - removing the calendar requirement since we can use any doctor authorized for this appointment 
  	return [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name 
  	 and id in (select doctor__c from Clinical_DR_Authorized_APT__c where clinical_appointment__c = :clinical_apt_id and doctor__r.isactive = true)  	
  	 order by isactive desc, name];*/
  	return [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor')  
  	  and id in (select doctor__c from Clinical_DR_Authorized_APT__c where clinical_appointment__c = :clinical_apt_id and doctor__r.isactive = true)  	
  	  order by isactive desc, name];
  }
  
  public List<Selectoption> gethour_options() {
  	List<Selectoption> hour_list = new List<SelectOption>();
  	for(Integer h = 1; h<=12; h++) {
  	  hour_list.add(new SelectOption(String.valueof(h),String.valueof(h)));
  	}
  	return hour_list;
  }
  
  public String getmsearch_end_time() {
  	String etime = '';
  	//convert the hour and minute to a start time
  	Integer mhour = Integer.valueof(msearch_hour);
  	Integer mminute = Integer.valueof(msearch_minute);
  	if(mhour!=12 && msearch_suffix=='PM') 
  	  mhour += 12;
  	Integer ctime = (mhour*60) + mminute;  	
  	//grab info from apt to calculate apt time
  	AggregateResult ar = [select sum(time_required__c) ttime From Patient_POT_Apt_Procedure__c p where isactive__c = true and patient_pot_apt__c = :manual_apt.id];
  	Decimal hold_time = ar.get('ttime')==null?0:(Decimal)ar.get('ttime');
  	Integer total_time = hold_time.intvalue();
  	total_time += ctime;  	 
  	Integer fhour = total_time / 60;
  	Integer fminute = math.mod(total_time,60);  	
  	String fsuffix = 'AM';
  	if(fhour==12)
  	  fsuffix = 'PM';
  	else if(fhour>12) {
  	  fhour = fhour - 12;
  	  fsuffix = 'PM';
  	}   	
   	String dminutes = String.valueof(fminute);
   	if(dminutes.length()==1)
   	  dminutes = '0' + dminutes;  	
  	//return result in an hour minute am/pm format  	
  	etime = String.valueof(fhour) + ':' + dminutes + ' ' + fsuffix;  	
  	return etime;
  }
  
  public List<SelectOption> getminute_options() {
  	List<Selectoption> minute_list = new List<SelectOption>();
	minute_list.add(new SelectOption('0','00'));
	minute_list.add(new SelectOption('10','10'));
	minute_list.add(new SelectOption('20','20'));
	minute_list.add(new SelectOption('30','30'));
	minute_list.add(new SelectOption('40','40'));
	minute_list.add(new SelectOption('50','50'));
  	return minute_list;
  }
  
  public List<SelectOption> getsuffix_options() {
  	List<Selectoption> suffix_list = new List<SelectOption>();
	suffix_list.add(new SelectOption('AM','AM'));
	suffix_list.add(new SelectOption('PM','PM'));
  	return suffix_list;
  }
  
  public class manual_doctor_results {
  	public User doctor {get; set;}
  	public List<Clinical_Apt_Calendar__c> conflicts {get; set;}  	
  	public List<Clinical_Time_Restriction__c> blocks {get; set;}
  	Center_information__c ci {get;set;}
  	Date sched_date {get; set;}
  	Integer doc_start {get; set;}
  	Integer doc_end {get; set;}
  	
  	public manual_doctor_results(User u, Date sdate, Integer dstart, Integer dend, Center_Information__c center) {
  	  this.doctor = u;
  	  conflicts = new List<Clinical_Apt_Calendar__c>();
  	  blocks  = new List<Clinical_Time_Restriction__c>();
  	  this.sched_date = sdate;
  	  this.doc_start = dstart;
  	  this.doc_end = dend;
  	  this.ci = center;
  	}
  	
  	public Boolean gethas_inventory() {
  	  Integer block_count = [select count() from Clinical_Doctor_Inventory__c where user__c = :doctor.id and calendar_date__c = :sched_date
  	    and stime__c <= :doc_start and etime__c >= :doc_end and center_information__c = :ci.id];
  	  if(block_count==0)
  	    return false;
  	  else 
  	    return true;
  	}
  	
  	public Boolean gethas_conflicts() {
  	  if(conflicts.size()==0 && blocks.size()==0)
  	    return false;
  	  else
  	    return true;
  	}
  	
  	public Integer getnum_conflicts() {
  	  return conflicts.size() + blocks.size();
  	}  	
  }
  
  public void calculate_doctor_results() {
  	doc_results = new List<manual_doctor_results>();
  	Map<Id,manual_doctor_results> doc_map = new Map<ID,manual_doctor_results>();
  	Set<ID> relevent_docs = new Set<ID>();
  	//get starting and ending doctor times
  	Integer mhour = Integer.valueof(msearch_hour);
  	Integer mminute = Integer.valueof(msearch_minute);
  	if(mhour!=12 && msearch_suffix=='PM') 
  	  mhour += 12;
  	Integer ctime = (mhour*60) + mminute;  	
  	//figuring out time makeup
  	/*
  	Integer time_before = 0;
  	Integer time_dr = 0;
  	Integer time_after = 0;
  	String current_stage = 'before';
  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
      where isactive__c = true and patient_pot_apt__c = :manual_apt.id order by sort_order__c]) {
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
          	//this means we had a non-doctor required procedure in between some required ones.  for now we handle this by building a continuous block of dr time
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
    } */
    apt_time_makeup apt_time = new apt_time_makeup(manual_apt.id);
    Integer time_before = apt_time.time_before;
    Integer time_dr = apt_time.time_dr;
    Integer time_after = apt_time.time_after;
    
    Integer doctor_start_time = ctime + time_before;
    Integer doctor_end_time = doctor_start_time + time_dr;
    System.debug('Doctor Range : ' + doctor_start_time + ' - ' + doctor_end_time);
  	
  	
  	//build a list of doctors we're working with
  	for(User u : getactive_doctor_list()) {
  	  manual_doctor_results mdr = new manual_doctor_results(u,current_date,doctor_start_time,doctor_end_time,current_center);
  	  doc_map.put(u.id,mdr);
  	  relevent_docs.add(u.id);
  	}
  	
    
    //check all doctor time blocks for this day and see if there is an overlap
    for(Clinical_Time_Restriction__c ctr : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, 
      c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c
      From Clinical_Time_Restriction__c c
      where block_date__c = :current_date
        and user__c in :relevent_docs
        and center_information__c = :current_center.id
        and block_type__c = 'Doctor']) {
      //check for a time overlap
      if(ctr.stime__c>=doctor_start_time && ctr.stime__c<doctor_end_time) 
        doc_map.get(ctr.user__c).blocks.add(ctr);  	
      else if(ctr.etime__c>=doctor_start_time && ctr.etime__c<doctor_end_time) 
        doc_map.get(ctr.user__c).blocks.add(ctr);
      else if(ctr.stime__c<=doctor_start_time && ctr.etime__c>=doctor_end_time)
        doc_map.get(ctr.user__c).blocks.add(ctr);
    }
    
  	  	
  	//pull a list of apts from the center that have a doctor assigned and occur during this time range
  	Set<ID> current_ids = new Set<ID>();
  	List<Clinical_Apt_Calendar__c> possible_conflicts = new List<Clinical_Apt_Calendar__c>(); 
  	
  	for(Clinical_Apt_calendar__c cap : [Select c.id,c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.appointment_description__c, c.Etime__c, c.Doctor__c, c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c
  	  where apt_date__c = :current_date 
  	    and clinical_room__r.center_information__c = :current_center.id 
  	    and doctor__c in :relevent_docs
  	    and patient_pot_apt__c != null
  	    and (stime__c >= :doctor_start_time and stime__c < :doctor_end_time)]) {
  	  current_ids.add(cap.id);
  	  possible_conflicts.add(cap);    	
  	}
  	for(Clinical_Apt_calendar__c cap : [Select c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.appointment_description__c,  c.Etime__c, c.Doctor__c, c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c
  	  where apt_date__c = :current_date 
  	    and clinical_room__r.center_information__c = :current_center.id 
  	    and doctor__c in :relevent_docs 
  	    and patient_pot_apt__c != null
  	    and id not in :current_ids
  	    and (etime__c >= :doctor_start_time and etime__c < :doctor_end_time)]) {
  	  current_ids.add(cap.id);
  	  possible_conflicts.add(cap);  	
  	}
  	for(Clinical_Apt_calendar__c cap : [Select c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.appointment_description__c,  c.Etime__c, c.Doctor__c, c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c
  	  where apt_date__c = :current_date 
  	    and clinical_room__r.center_information__c = :current_center.id 
  	    and doctor__c in :relevent_docs 
  	    and patient_pot_apt__c != null
  	    and id not in :current_ids
  	    and (stime__c <= :doctor_start_time and etime__c >= :doctor_end_time)]) {
  	  current_ids.add(cap.id);
  	  possible_conflicts.add(cap);  	
  	}
  	      	  	
  	//build a set of patient apts
  	Set<ID> all_apts = new Set<ID>();
  	for(Clinical_Apt_Calendar__c ca : possible_conflicts) {
  	  all_apts.add(ca.patient_pot_apt__c);
  	}
  	
  	//pull the details for procedure tied to those apts
  	Map<ID,List<Patient_POT_Apt_Procedure__c>> apt_proc_map = new Map<ID,List<Patient_POT_Apt_Procedure__c>>();
  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c, patient_pot_apt__c From Patient_POT_Apt_Procedure__c p 
      where isactive__c = true and patient_pot_apt__c in :all_apts order by sort_order__c]) {
      if(apt_proc_map.get(pa.patient_pot_apt__c)==null)
        apt_proc_map.put(pa.patient_pot_apt__c,new List<Patient_POT_Apt_Procedure__c>());
      apt_proc_map.get(pa.patient_pot_apt__c).add(pa);
    }
  	
  	//loop through apts again and calculate when the doctor will be in the apt
  	for(Clinical_Apt_Calendar__c ca : possible_conflicts) {
  	  //figuring out time makeup
  	  time_before = 0;
  	  time_dr = 0;
  	  time_after = 0;
  	  String current_stage = 'before';
  	  for(Patient_POT_Apt_Procedure__c pa : apt_proc_map.get(ca.patient_pot_apt__c)) {
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
      Integer block_doctor_start_time = ca.stime__c.intvalue() + time_before;
      Integer block_doctor_end_time = block_doctor_start_time + time_dr;
      
  	  //if there is an overlap with out time,  then we have a conflict....add it to the doctor result conflict list
  	  Boolean overlap_conflict = false;
  	  //check to see if start time is between our time
  	  if(block_doctor_start_time >= doctor_start_time && block_doctor_start_time < doctor_end_time) {
  	  	overlap_conflict = true;
  	  }
  	  //check to see if end time falls between our times
  	  if(block_doctor_end_time >= doctor_start_time && block_doctor_end_time < doctor_end_time) {
  	  	overlap_conflict = true;
  	  }  	  
  	  //check to see if it swallows our needed block
  	  if(block_doctor_start_time <= doctor_start_time && block_doctor_end_time >= doctor_end_time) {
  	  	overlap_conflict = true;
  	  }
  	  if(overlap_conflict) { 
  	    doc_map.get(ca.doctor__c).conflicts.add(ca); 	  
  	  }
  	}
  	  	
  	doc_results = doc_map.values();
  }
  
  public void view_conflict_detail() {
  	display_confirmation_modal = true;
  	modal_type = 'report_conflicts';
  	modal_out = 'Conflicts : <br /><br />';
  	//work through the conflicts list for the doctor they identified
  	for(manual_doctor_results mdr : doc_results) {
  	  if(mdr.doctor.id==apexpages.currentpage().getparameters().get('docid')) {
  	  	//work through conflicts
  	  	for(Clinical_Apt_Calendar__c ca : mdr.conflicts) {
  	  	  modal_out += '<div class="cc-manualTime-warning">' + ca.patient_pot_apt__r.appointment_description__c + ' in room ' + ca.clinical_room__r.name + '</div>';
  	  	}  	  	
  	  	for(Clinical_Time_Restriction__c ctr : mdr.blocks) {
  	  	  modal_out += '<div class="cc-manualTime-warning">Doctor block from ' + string_time_from_int(ctr.stime__c) + ' to ' + string_time_from_int(ctr.etime__c) + ' - ' + ctr.block_reason__c + '</div>';
  	  	}
  	  }
  	}
  }
  
  public void view_room_switch_conflict_detail() {
  	display_confirmation_modal = true;
  	modal_type = 'report_conflicts';
  	modal_out = 'Conflicts : <br /><br />';
  	//work through the conflicts list for the doctor they identified
  	for(Room_Change rc : getpossible_switch_rooms()) {
  	  if(rc.room.id==apexpages.currentpage().getparameters().get('roomid')) {
  	  	//work through conflicts
  	  	for(Clinical_Apt_Calendar__c ca : rc.apt_conflicts) {
  	  	  modal_out += '<div class="cc-manualTime-warning">' + ca.patient_pot_apt__r.appointment_description__c + ' in room ' + ca.clinical_room__r.name + '</div>';
  	  	}  	  	
  	  	for(Clinical_Time_Restriction__c ctr : rc.block_conflicts) {
  	  	  modal_out += '<div class="cc-manualTime-warning">Doctor block from ' + string_time_from_int(ctr.stime__c) + ' to ' + string_time_from_int(ctr.etime__c) + ' - ' + ctr.block_reason__c + '</div>';
  	  	}
  	  }	
  	}
  }
  
  public void close_confirmation_modal() {
  	display_confirmation_modal = false;
  	confirmation_modal_display = false;
  	modal_out = '';
  	modal_type = '';
  }
  
  public class suggested_time {
  	public Integer int_time {get; set;}
  	public Boolean has_conflict {get; set;}
  	
  	public suggested_time(Integer stime) {
  	  int_time = stime;
  	  has_conflict = false;
  	}
  	
  	public String getbutton_style() {
  	  String css = '';
  	  if(has_conflict)
  	    css = 'background-color:rgb(252,176,187);border: 1px solid #b71125;';
  	  else
  	    css = 'background-color:rgb(239,248,254);border: 1px solid #7ac9fc;';
  	  return css;
  	}
  	
  	public String getdisplay_time() {
  	  Decimal lhours = math.floor(int_time/60);
  	  String suffix = 'AM';
  	  if(lhours==12)
  	    suffix = 'PM';
  	  else if(lhours>12) {
  	  	lhours = lhours - 12;
  	  	suffix = 'PM';
  	  }
   	  Integer lminutes = math.mod(int_time,60);
   	  String dminutes = String.valueof(lminutes);
   	  if(dminutes.length()==1)
   	    dminutes = '0' + dminutes;
   	  return String.valueof(lhours.intvalue()) + ':' + dminutes + ' ' + suffix;
  	}
  }
  
  public List<suggested_time> getmsearch_suggested_times() {
  	Map<Integer,suggested_time> valid_times = new map<Integer,suggested_time> ();
    //start at 7 (420) and go through 6 (1080)
    Integer ctime = 420;
    while(ctime<1080) {
      valid_times.put(ctime,new suggested_time(ctime));
      ctime+=10;
    }       
    
    //build a set of existing blocks so we can check for overlaps later
    Set<Integer> blocked_times = new Set<Integer>();
    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Patient_POT_Apt__c, c.Etime__c, c.Doctor__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c 
      From Clinical_Apt_Calendar__c c where clinical_room__c = :msearch_room and account__c != null and patient_pot_apt__c != null and apt_date__c = :current_date]) {
      Integer block_start = ca.stime__c.intvalue();
      while(block_start < ca.etime__c.intvalue() ) {
      	blocked_times.add(block_start);
      	block_start+=10;
      }
    }
    
    //build a map of available doctor time
    Set<Integer> doctor_times = new Set<Integer>();
    for(Clinical_Doctor_Inventory__c cd : [Select c.User__c, c.Stime__c, c.Etime__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c
      where calendar_date__c = :current_date
      and user__c = :msearch_doctor
      and center_information__c = :current_center.id]) {
      Integer block_start = cd.stime__c.intvalue();
      while(block_start < cd.etime__c.intvalue()) {
      	doctor_times.add(block_start);
      	block_start+=10;
      }
    }
        
    //figuring out time makeup
  	/*Integer time_before = 0;
  	Integer time_dr = 0;
  	Integer time_after = 0;
  	String current_stage = 'before';
  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
      where isactive__c = true and patient_pot_apt__c = :manual_apt.id order by sort_order__c]) {
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
    } */
    apt_time_makeup apt_time = new apt_time_makeup(manual_apt.id);
    Integer time_before = apt_time.time_before;
    Integer time_dr = apt_time.time_dr;
    Integer time_after = apt_time.time_after;
    
    Integer total_time = time_before + time_dr + time_after;
    
    //look for overlaps and remove entry from valid times
    ctime = 420;
    while(ctime<1080) {    	
      //make sure all entries from this point through ctime + total_time are not in blocked_times set....if any of them are,  remove the entry
      Integer start_apt = ctime;
      Integer end_apt = ctime + total_time;
      while(start_apt < end_apt) {
      	if(blocked_times.contains(start_apt)) {
      	  valid_times.remove(ctime);
      	  break;
      	}
      	start_apt += 10;
      }      
      ctime += 10;
    } 
    
    //check for any conflicts with doctor time
    for(Integer check_time : valid_times.keyset()) {    	
      //make sure all entries from this point through ctime + total_time are not in blocked_times set....if any of them are,  remove the entry
      Integer start_dr = check_time + time_before;
      Integer end_dr = start_dr + time_dr;
      System.debug('Looking for Doctor time between ' + start_dr + ' - ' + end_dr);
      while(start_dr < end_dr) {
      	if(!doctor_times.contains(start_dr)) {
      	  System.debug('Dr time conflict at ' + start_dr);
      	  valid_times.get(check_time).has_conflict = true;
      	}  
      	start_dr += 10;
      }      
    }
  	
  	return valid_times.values();
  }
  
  public String getsearch_doctor_name() {
  	return [select name from user where id = :msearch_doctor].name;
  }
  
  public void manually_schedule_by_time() {
  	Integer mhour = Integer.valueof(msearch_hour);
  	Integer mminute = Integer.valueof(msearch_minute);
  	if(mhour!=12 && msearch_suffix=='PM') 
  	  mhour += 12;
  	Integer ctime = (mhour*60) + mminute; 
  	manual_schedule_block(ctime,msearch_doctor);
  }
  
  public void manuall_schedule_by_suggestion() {
  	Integer ctime = Integer.valueof(apexpages.currentpage().getparameters().get('sgtime')); 
  	manual_schedule_block(ctime,msearch_doctor);
  }
  
  public void manually_schedule_by_doctor() {
  	Integer mhour = Integer.valueof(msearch_hour);
  	Integer mminute = Integer.valueof(msearch_minute);
  	if(mhour!=12 && msearch_suffix=='PM') 
  	  mhour += 12;
  	Integer ctime = (mhour*60) + mminute; 
  	manual_schedule_block(ctime,apexpages.currentpage().getparameters().get('docid'));
  }
  
  public class apt_time_makeup {
  	public Integer time_before {get;set;}
  	public Integer time_after {get;set;}
  	public Integer time_dr {get;set;}  	
  	
  	public apt_time_makeup(String sched_apt_id) {
  	  time_before = 0;
	  time_dr = 0;
	  time_after = 0;
	  String current_stage = 'before';
	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
	    clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
	    where isactive__c = true and patient_pot_apt__c = :sched_apt_id order by sort_order__c]) {
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
	  //system.debug('Before reduction - time before : ' + time_before + ' time_dr : ' + time_dr + ' time_after : ' + time_after);
	  //check to see if reductions made any of these go below 0 due to reductions
	  if(time_after < 0) {
	    time_dr = time_dr + time_after;
	    time_after = 0;	      
	  }
	  if(time_dr <0) {
	    time_before = time_before + time_dr;
	    time_dr = 0;
	  } 
  	}
  }
  
  public Integer getcurrent_dow() {
  	Integer dow;
  	Datetime current_datetime = DateTime.newInstance(current_date.year(),current_date.month(),current_date.day());
  	//rewriting this to make it easier for code coverage
  	Map<String,Integer> dow_map = new Map<String,Integer>();
  	dow_map.put('Monday',1);
  	dow_map.put('Tuesday',2);
  	dow_map.put('Wednesday',3);
  	dow_map.put('Thursday',4);
  	dow_map.put('Friday',5);
  	dow_map.put('Saturday',6);
  	dow_map.put('Sunday',7);
  	dow = dow_map.get(current_datetime.format('EEEE'));  	
	/*if(current_datetime.format('EEEE')=='Monday') 
	  dow = 1;
	if(current_datetime.format('EEEE')=='Tuesday')
	  dow = 2;	  
	if(current_datetime.format('EEEE')=='Wednesday') 
	  dow = 3;	  
	if(current_datetime.format('EEEE')=='Thursday') 
	  dow = 4;
	if(current_datetime.format('EEEE')=='Friday') 
	  dow = 5;
	if(current_datetime.format('EEEE')=='Saturday') 
	  dow = 6;
	if(current_datetime.format('EEEE')=='Sunday') 
	  dow = 7;*/
	return dow;	 
  }
    
  public void manual_schedule_block(Integer stime, String doc_id) {
  	System.debug('Stime : ' + stime);
    //check for an apt overlap - stime or etime between this apt start time and end time
    AggregateResult ar = [select sum(time_required__c) ttime From Patient_POT_Apt_Procedure__c p where isactive__c = true and patient_pot_apt__c = :manual_apt.id];
    Decimal required_time = (Decimal)ar.get('ttime');
    Integer etime = stime + required_time.intvalue();
    
    Integer overlap_count = 0;
    Integer overlap_at_start_ignore = 0;
    Integer overlap_at_end = [select count() from Clinical_Apt_Calendar__c where clinical_room__c = :msearch_room and account__c != null and patient_pot_apt__c != null and apt_date__c = :current_date and
      stime__c >= :stime and stime__c < :etime];
    Integer overlap_at_start = [select count() from Clinical_Apt_Calendar__c where clinical_room__c = :msearch_room and account__c != null and patient_pot_apt__c != null and apt_date__c = :current_date and
      etime__c > :stime and etime__c <= :etime];
    if(overlap_at_start>0) {
      //check to see if this overlap would cause issues for manual sched auto reduction
      overlap_at_start_ignore = [select count() from Clinical_Apt_Calendar__c where clinical_room__c = :msearch_room and account__c != null and patient_pot_apt__c != null and apt_date__c = :current_date and
      etime__c > :stime and etime__c <= :etime and stime__c > :stime];
    }      
    Integer overlap_all = [select count() from Clinical_Apt_Calendar__c where clinical_room__c = :msearch_room and account__c != null and patient_pot_apt__c != null and apt_date__c = :current_date and
      stime__c <= :stime and etime__c >= :etime];
    overlap_count = overlap_at_end + overlap_at_start + overlap_all;
    System.debug('Overlap Count : ' + overlap_count);
    Boolean attempt_sched = true;
    
    if(overlap_count>0) {
      //centers with this flag will be allowed to schedule anywhere that can support a 10 minute block of time - meaning only overlap at end should be > 0
      if(current_Center.Manual_Sched_Auto_Reduction__c && (overlap_at_start - overlap_at_start_ignore)==0 && overlap_all==0) {        
        //find the next block start time 
        Clinical_Apt_Calendar__c next_block = [select stime__c from clinical_apt_calendar__c where clinical_room__c = :msearch_room and account__c != null and patient_pot_apt__c != null and apt_date__c = :current_date and
          stime__c >= :stime and stime__c < :etime];
        Integer avail_time = next_block.stime__c.intvalue() - stime;
        Integer num_reductions = (required_time.intvalue() - avail_time) / 10;
        System.debug('Number of reductions : ' + num_reductions);
        Clinical_Procedure__c extension_proc = [Select c.center_information__r.name, c.Time_Required__c, c.Procedure_Filter__c, c.Procedure_Description__c, c.Name,
	  	  c.Insurance_Fee__c, c.Id, c.Default_Teeth_Selection__c, c.Cost__c, c.Allow_Tooth_Selection__c, c.ADA_Code__c 
	  	  From Clinical_Procedure__c c 
	  	  where name = 'Reduce 10 Minutes' and center_information__c = :current_center.id];
	  	Integer current_sort_order = [select sort_order__c from patient_pot_apt_procedure__c where patient_pot_apt__c = :manual_apt.id and isactive__c = true order by sort_order__c desc limit 1].sort_order__c.intvalue() + 1;
	  	List<Patient_pot_apt_procedure__c> reduction_list = new List<Patient_pot_apt_procedure__c>();
	    for(Integer loop_cnt = 1;loop_cnt<=num_reductions;loop_cnt++) {  	     	   
	  	  Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = extension_proc.ADA_Code__c, Clinical_Procedure__c = extension_proc.id,
	  	    Cost__c = extension_proc.Cost__c, Insurance_Fee__c = extension_proc.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = manual_apt.id,
	  	    Sort_Order__c = current_sort_order, Time_Required__c = extension_proc.Time_Required__c, name = extension_proc.name, allow_tooth_selection__c = extension_proc.allow_tooth_selection__c,
	  	    target_teeth__c = extension_proc.default_teeth_selection__c, procedure_description__c = extension_proc.Procedure_Description__c);
	  	  reduction_list.add(new_procedure);
	  	  current_sort_order++;
	    }
        insert reduction_list;          
      } else {
        display_confirmation_modal = true;
 	    modal_type = 'Sched Issue';
	    modal_out = 'Unable to schedule - there is an existing block in this room that would overlap this apt<br />';
	    //modal_out += 'Overlap at start : ' + overlap_at_start + '<br />'; 
        //modal_out += 'Overlap at start ignore : ' + overlap_at_start_ignore + '<br />';
	    attempt_sched = false;
      }		  	 
    }
            
    if(attempt_sched) {
      //do the scheduling thing
      //figuring out time makeup
	  	/*Integer time_before = 0;
	  	Integer time_dr = 0;
	  	Integer time_after = 0;
	  	String current_stage = 'before';
	  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
	      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
	      where isactive__c = true and patient_pot_apt__c = :manual_apt.id order by sort_order__c]) {
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
	    system.debug('Before reduction - time before : ' + time_before + ' time_dr : ' + time_dr + ' time_after : ' + time_after);
	    //check to see if reductions made any of these go below 0
	    if(time_after < 0) {
	      time_dr = time_dr + time_after;
	      time_after = 0;	      
	    }
	    if(time_dr <0) {
	      time_before = time_before + time_dr;
	      time_dr = 0;
	    }
	    system.debug('After reduction - time before : ' + time_before + ' time_dr : ' + time_dr + ' time_after : ' + time_after);*/

	    apt_time_makeup apt_time = new apt_time_makeup(manual_apt.id);
	    etime = stime + apt_time.time_before + apt_time.time_dr + apt_time.time_after;
	    Integer total_time = apt_time.time_before + apt_time.time_dr + apt_time.time_after;
	    Integer doctor_stime = stime + apt_time.time_before;
	    Integer doctor_etime = doctor_stime + apt_time.time_dr;
      
      try {
      	if(current_date < System.today())
      	  throw new bendException('Manually Scheduling in the past is currently unavailable.  Contact the HopeRx Support team if you feel this is in error');
        //use same logic as possible conflicts code
        //identify if this block falls inside an existing open block - set CR Block value in a var
        //otherwise CR Block would be empty
        String block_id = null; //will store the first open block id we store here      
        List<Clinical_Apt_Calendar__c> new_blocks = new List<Clinical_Apt_Calendar__c> (); //list to store new blocks created
        List<Clinical_Apt_Calendar__c> delete_blocks = new List<Clinical_Apt_Calendar__c>(); //list to store deleted blocks 
        Clinical_Apt_Calendar__c manual_block; //block for the manual sched - could be inserted or just an update.....
        Set<ID> reviewed_ids = new Set<ID>();
      
        //check for block that covers our entire manual sched time
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c, id
           
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
  	      and clinical_room__r.center_information__c = :current_center.id 
  	      and clinical_room__c = :msearch_room 
  	      and (stime__c <= :stime and etime__c >= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null)
      	    throw new bendException('You attempted to manually schedule over an existing block');
      	  reviewed_ids.add(ca.id);
      	  //by definition,  you can only have one row here (or something went really wrong)
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  }
      	  
      	  if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	        Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	        new_blocks.add(new_block);
  	        manual_block.start_minute__c = String.valueof(gettime_minutes(stime));
  	        manual_block.start_hour__c = String.valueof(gettime_hours(stime));
  	      }
  	        
  	      if(ca.etime__c > etime) {
  	        //need to create a trailing block as we have some time left over
            Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	    new_blocks.add(new_block);
    	    manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  	      
  	      }
      	  	      	 
        }      
        //check for blocks that contain the stime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c,
           c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
          and id not in :reviewed_ids
          and clinical_room__c = :msearch_room
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (stime__c >= :stime and stime__c < :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null)
      	    throw new bendException('You attempted to manually schedule over an existing block');
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//adjust start time
      	  	manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));      	  	
      	  	  	        
  	        if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);    	      	      
  	        }
  	        manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  
      	  }
      	  else {
      	  	//just need to check if it extends beyond our end time (create a new block with the extra)
      	  	if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        }      
        //else a block that contains the etime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c,  c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
          and id not in :reviewed_ids
          and clinical_room__c = :msearch_room
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (etime__c > :stime and etime__c <= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null)
      	    throw new bendException('You attempted to manually schedule over an existing block');
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//make end time
      	  	manual_block.End_Minute__c = String.valueof(gettime_minutes(etime));
      	  	manual_block.End_Hour__c =  String.valueof(gettime_hours(etime));      	  	
      	  	  	        
  	        if(ca.stime__c < (stime)) {
  	          //need to create a preceeding block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);   	      	      
  	        }
  	        manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));       	  	 
      	  }
      	  else {
      	  	//just need to check if it extends beyond our start time (create a new block with the extra)
      	  	if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	          Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        } 
               
        //if block_id is still null,  then create a blank block from scratch (no existing blocks covered this period of time in any way)
        if(block_id==null) {
          manual_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(gettime_minutes(stime)), Start_Hour__c = String.valueof(gettime_hours(stime)), End_Minute__c = String.valueof(gettime_minutes(etime)), End_Hour__c = String.valueof(gettime_hours(etime)), 
  	        DOW__c = getcurrent_dow(), Clinical_Room__c = msearch_room, Apt_Date__c = current_date);
        }                 
        //set fields on our manual block
        manual_block.Patient_POT_Apt__c = manual_apt.id;
  	    //Patient_Pot_Apt__c pa = [Select p.Patient_POT__r.opportunity__c, p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :manual_apt.id]; 
  	    //manual_block.opportunity__c = pa.patient_pot__r.opportunity__c;
  	    Patient_Pot_Apt__c pa = [Select p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :manual_apt.id];
  	    manual_block.account__c = pa.patient_pot__r.account__c;
  	    manual_block.doctor__c = doc_id;
  	    manual_block.confirmation_status__c = 'Not Confirmed';
  	    
  	    //doctor inventory stuff
  	    //same process as blocks....since we allow overrides we need to check for doctor blocks that cover the area of time in question
  	    List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    List<Clinical_Doctor_Inventory__c> delete_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    reviewed_ids = new Set<ID>();  	    
  	    
  	    //search inventory stuff     
  	    //check for a block of doctor time that contains the whole time in question
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :doc_id and calendar_date__c = :current_date and stime__c <= :doctor_stime and etime__c >= :doctor_etime and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	      
  	      //do we need to create a preceeding block
  	      if(cdi.stime__c < doctor_stime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	      	  End_Minute__c = String.valueof(gettime_minutes(doctor_stime)) , End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }  	      
  	      //do we need to create a trailing block
  	      if(cdi.etime__c > doctor_etime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)),
  	      	  End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }
  	    //check for a block that contains the start time
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :doc_id and calendar_date__c = :current_date and stime__c >= :doctor_stime and stime__c < :doctor_etime and id not in :reviewed_ids and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	    	           
  	      //do we need to create a trailing block
  	      if(cdi.etime__c > doctor_etime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)),
  	      	  End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }  	    
  	    //check for a block that contains the end time
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :doc_id and calendar_date__c = :current_date and etime__c > :doctor_stime and etime__c <= :doctor_etime and id not in :reviewed_ids and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	    	           
  	      //do we need to create a preceeding block
  	      if(cdi.stime__c < doctor_stime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	      	  End_Minute__c = String.valueof(gettime_minutes(doctor_stime)) , End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }  
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }  	    
  	    
  	    //grabbing search inventory prior to deleting stuff,  so that we don't have orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :current_date and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :current_date
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
  	    
  	    //create apt history
  	    //commit changes - Blocks
        System.debug('Manual Block : ' + manual_block);
        if(manual_block.id==null) {
          System.debug('Inserting Block');
          insert manual_block;
        }
        else {
          System.debug('Updating Existing Block');
          update manual_block;
        }  
        last_apt_id = manual_block.id;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        System.debug('Deleted Blocks size : ' + delete_blocks.size());
        if(delete_blocks.size()>0) {
          System.debug('Deleted Blocks : ' + delete_blocks);
          delete delete_blocks;
        }
  	     
        System.debug('Doctor Inventory Delete size : ' + delete_doctor_blocks.size());
        if(delete_doctor_blocks.size()>0) {
          System.debug('Doctor Inventory Deleted : ' + delete_doctor_blocks);
          delete delete_doctor_blocks;
        }
        System.debug('Doctor Inventory Blocks Created : ' + new_doctor_blocks.size());
        if(new_doctor_blocks.size()>0) {
          System.debug('New Doctor Blocks : ' + new_doctor_blocks);
          insert new_doctor_blocks;     
        }
        
        //create a history entry
        Datetime adtime = Datetime.newinstance(manual_block.apt_date__c, Time.newinstance(gettime_hours(stime),gettime_minutes(stime),0,0));
        Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = manual_apt.id, Notes__c = 'Apt has been manually scheduled - ' + adtime.format('M/dd/yyyy h:mm a'), Clinical_Apt_Calendar__c = manual_block.id, 
          Action__c = 'Scheduled', Account__c = pa.patient_pot__r.account__c);
        System.debug('Apt History : ' + cah);
        insert cah; 
  	    
  	    //consult search inventory fun times
  	    //rebuild the search inventory for this day 

        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :current_date 
          and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :current_date and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //bad design here - it queries for every iteration of the loop - switching to use a list now
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :current_date 
  	        //and user__r.clinic_calendar__c = :current_center.name]) {
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
          	    
  	    //if all went well - close the modal.
  	    display_msearch_modal = false;
  	    //check for a clipboard entry
  	    try {
  	      //should only be 1 now,  but this is here just in case.  All matches will be pulled
  	      //List<Clinical_Clipboard__c> clip = [select id from clinical_clipboard__c where patient_pot_apt__c = :manual_apt.id and createdbyid = :userinfo.getuserid()];
  	      Integer clip_cnt = [select count() from clinical_clipboard__c where patient_pot_apt__c = :manual_apt.id and center_information__c = :current_center.id];
  	      if(clip_cnt>0) {  	      	
  	        List<Clinical_Clipboard__c> clip = [select id,arrival_time__c,ready_time__c,apt_start_time__c,clinical_note_instance__c 
  	          from clinical_clipboard__c where patient_pot_apt__c = :manual_apt.id and center_information__c = :current_center.id];
  	        if(clip[0].clinical_note_instance__c!=null) {
  	          Clinical_note_Instance__c cni = [select id,clinical_apt_calendar__c,
  	            (Select id,clinical_apt_calendar__c From Surgical_Notes_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Final_Notes_Forms__r),  
  	            (Select Id, Clinical_Apt_Calendar__c From Conversion_Notes_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Interim_Delivery_Notes_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From JIG_Notes_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Post_OP_Notes_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Try_In_Notes_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Prosth_Exam_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Redo_Surgery_Forms__r),
  	            (Select Id, Clinical_Apt_Calendar__c From Repair_Note_Forms__r)   	          
  	          from clinical_note_instance__c where id = :clip[0].clinical_note_instance__c];
  	          //check for forms to update
  	          if(cni.surgical_notes_forms__r.size()>0) {
  	          	for(Surgical_notes_form__c snf : cni.surgical_notes_forms__r) {
  	          	  snf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.surgical_notes_forms__r;
  	          }
  	          if(cni.final_notes_forms__r.size()>0) {
  	          	for(Final_Notes_Form__c fnf : cni.final_notes_forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.final_notes_forms__r;
  	          }
  	          if(cni.Conversion_Notes_Forms__r.size()>0) {
  	          	for(Conversion_Notes_Form__c fnf : cni.Conversion_Notes_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Conversion_Notes_Forms__r;
  	          }
  	          if(cni.Interim_Delivery_Notes_Forms__r.size()>0) {
  	          	for(Interim_Delivery_Notes_Form__c fnf : cni.Interim_Delivery_Notes_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Interim_Delivery_Notes_Forms__r;
  	          }
  	          if(cni.JIG_Notes_Forms__r.size()>0) {
  	          	for(JIG_Notes_Form__c fnf : cni.JIG_Notes_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.JIG_Notes_Forms__r;
  	          }
  	          if(cni.Post_OP_Notes_Forms__r.size()>0) {
  	          	for(Post_OP_Notes_Form__c fnf : cni.Post_OP_Notes_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Post_OP_Notes_Forms__r;
  	          }
  	          if(cni.Try_In_Notes_Forms__r.size()>0) {
  	          	for(Try_In_Notes_Form__c fnf : cni.Try_In_Notes_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Try_In_Notes_Forms__r;
  	          }
  	          if(cni.Prosth_Exam_Forms__r.size()>0) {
  	          	for(Prosth_Exam_Form__c fnf : cni.Prosth_Exam_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Prosth_Exam_Forms__r;
  	          }
  	          if(cni.Redo_Surgery_Forms__r.size()>0) {
  	          	for(Redo_Surgery_Form__c fnf : cni.Redo_Surgery_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Redo_Surgery_Forms__r;
  	          }
  	          if(cni.Repair_Note_Forms__r.size()>0) {
  	          	for(Repair_Note_Form__c fnf : cni.Repair_Note_Forms__r) {
  	          	  fnf.clinical_apt_calendar__c = manual_block.id;
  	          	}
  	          	update cni.Repair_Note_Forms__r;
  	          }
  	          cni.clinical_apt_calendar__c = manual_block.id;
  	          update cni;
  	        }  	        
  	        if(clip[0].arrival_time__c!=null) {
  	          manual_block.arrival_time__c = clip[0].arrival_time__c;
  	          manual_block.apt_status__c = 'Patient Arrived';
  	        }
  	        if(clip[0].ready_time__c!=null) {
  	          manual_block.ready_time__c = clip[0].ready_time__c;
  	          manual_block.apt_status__c = 'Patient Ready';
  	        }
  	        if(clip[0].apt_start_time__c!=null) {
  	          manual_block.apt_start_time__c = clip[0].apt_start_time__c;
  	          manual_block.apt_status__c = 'Appointment Started';
  	        }  	          	        
  	        delete clip;
  	        update manual_block;  	        
  	      }
  	    } catch (Exception e) {
  	    }
  	    //and cancel manual scheduling mode   	
  	    cancel_manual_schedule();  
  	    
      } catch (Exception e) {
      	display_confirmation_modal = true;
      	modal_type = 'Sched Issue';
	    modal_out = 'Unable to schedule - there was an error during the scheduling process<br />' + e ;
      }    
    }          	
    
  }
  
  public Integer getroom_block_count() {
  	Integer rcount = 0;
  	if(calendar_view=='Day')
  	  rcount= [select count() from Clinical_Time_Restriction__c where block_type__c = 'Room' and block_date__c = :current_date
  	    and clinical_room__r.center_information__r.market__c = :current_center.market__c];
  	else if(calendar_view=='Week') {
  	  //get the start of this week and next week
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  rcount = [select count() from Clinical_Time_Restriction__c where block_type__c = 'Room' and block_date__c >= :start_this_week and block_date__c < :start_of_next_week
  	    and clinical_room__r.center_information__r.market__c = :current_center.market__c];
  	}
  	return rcount;
  }
  
  public Set<String> getcenter_market_names() {
  	Set<String> market_names = new Set<String> ();
  	for(Center_Information__c ci : [select id,name from Center_Information__c where market__c = :current_center.market__c]) {
  	  market_names.add(ci.name);
  	}
  	return market_names;
  }
  
  public Integer getdoctor_block_count() {
  	Integer rcount = 0;
  	if(calendar_view=='Day')
  	  rcount= [select count() from Clinical_Time_Restriction__c where block_type__c = 'Doctor' and block_date__c = :current_date
  	    //and user__r.clinic_calendar__c in :getcenter_market_names()];
  	    and center_information__c = :current_center.id];
  	else if(calendar_view=='Week') {
  	  //get the start of this week and next week
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  rcount = [select count() from Clinical_Time_Restriction__c where block_type__c = 'Doctor' and block_date__c >= :start_this_week and block_date__c < :start_of_next_week
  	    //and user__r.clinic_calendar__c in :getcenter_market_names()];
  	    and center_information__c = :current_center.id];
  	}
  	return rcount;
  }
  
  public List<Clinical_Apt_Calendar__c> getpending_resched_apts() {
  	//modified by cm on 2/7/2017
  	//pulling alist of all forward facing pending rescheds to make it easier to find them
  	resched_list = [select account__r.personmobilephone, account__r.phone, account__r.email__c, account__r.name, patient_pot_apt__r.name,doctor__r.name,patient_pot_apt__c,account__c,apt_date__c,stime__c,etime__c,clinical_room__c, clinical_room__r.name, id, status_updates__c
  	    from clinical_apt_calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c >= today and clinical_room__r.center_information__c = :current_center.id];
  	/*if(calendar_view=='Day')
  	  resched_list = [select account__r.name, patient_pot_apt__r.name,doctor__r.name,patient_pot_apt__c,account__c,apt_date__c,stime__c,etime__c,clinical_room__c, clinical_room__r.name, id, status_updates__c
  	    from clinical_apt_calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c = :current_date];
  	else if(calendar_view=='Week') {
  	  //get the start of this week and next week
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  resched_list = [select account__r.name, patient_pot_apt__r.name,doctor__r.name,patient_pot_apt__c,account__c,apt_date__c,stime__c,etime__c,clinical_room__c, clinical_room__r.name, id 
  	    from Clinical_Apt_Calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c >= :start_this_week and apt_date__c < :start_of_next_week];
  	}*/
  	return resched_list;
  }
  
  public Integer getpending_resched_count() {
  	Integer rcount = 0;
  	//modified by cm on 2/7/2017 
  	//we're no displaying reschedules for any time (forward facing),  so they are easier to find and handle.
  	rcount = [Select count() From Clinical_Apt_Calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c >= today and clinical_room__r.center_information__c = :current_center.id];
  	/*if(calendar_view=='Day')
  	  rcount= [Select count() From Clinical_Apt_Calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c = :current_date];
  	else if(calendar_view=='Week') {
  	  //get the start of this week and next week
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  rcount = [select count() from Clinical_Apt_Calendar__c where apt_status__c = 'Pending Reschedule' and apt_date__c >= :start_this_week and apt_date__c < :start_of_next_week];
  	}*/
  	return rcount;
  }
  
  public void update_resched_status() {
  	try {
  	  update resched_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the status. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  
  public void open_resched_cancel_confirmation() {
  	current_edit_id = apexpages.currentpage().getparameters().get('prid');
  	block_view = 'Cancel'; 
  } 
  
  public void open_note_modal() {
  	display_note_modal = true;
  	cal_note = new Clinical_Calendar_Note__c(note_date__c = current_date, calendar_note__c = 'Enter Note Here', center_information__c = current_center.id);   	
  } 
  
  public void save_calendar_note() {
  	//check for issues first
  	Integer num_issues = 0; 
  	if((cal_note.calendar_note__c==null?'':cal_note.calendar_note__c)==''||cal_note.calendar_note__c=='Enter Note Here') {
      num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the calendar note'));
  	} 	
  	else if(cal_note.calendar_note__c.length()<3) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a longer value for the calendar note'));
  	}  	
  	if(num_issues==0) {
  	  try {
  	  	if(cal_note.id==null)  	    
  	      insert cal_note;
  	    else
  	      update cal_note;
  	    close_note_modal();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add a new upload document.  Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void edit_calendar_note() {
  	cal_note = [select id,name,note_date__c,calendar_note__c from Clinical_Calendar_Note__c where id = :apexpages.currentpage().getparameters().get('cnid')];
  	current_edit_id = cal_note.id;
  }
  
  public void reset_calendar_note() {
  	cal_note = [select id,name,note_date__c,calendar_note__c from Clinical_Calendar_Note__c where id = :current_edit_id];
  }
  
  public void delete_calendar_note() {
  	try {
  	  delete cal_note;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove the calendar note.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  	current_edit_id = null;
  }
  
  public Clinical_Calendar_Note__c[] getcalendar_notes() {
    List<Clinical_Calendar_Note__c> cnote_list = new List<Clinical_Calendar_Note__c>();
  	if(calendar_view=='Day') {
  	  cnote_list = [select id,name,note_date__c,calendar_note__c from Clinical_Calendar_Note__c where note_date__c = :current_date and center_information__c = :current_center.id];
  	} else {
  	  //note sure how we want to handle weekly notes (if at all) yet
  	}
  	return cnote_list;
  }
  
  public void close_note_modal() {
  	display_note_modal = false;
  	current_edit_id = null;
  }
  
  public void  open_pending_resched_modal() {
  	display_pending_resched_modal = true;
  	current_edit_id = null;
  	block_view = '';
  	resched_list = new List<Clinical_Apt_Calendar__c>();
  }
  
  public void close_pending_resched_modal() {
  	display_pending_resched_modal = false;
  }
  
  public void open_room_block_modal() {
  	display_room_block_modal = true;
  	block_view = '';
  	current_tab_id = null;
  	current_edit_id = null;
    if(getroom_block_count()>0)  	 {
      block_view = 'Room';
      if(calendar_view=='Day')
        current_tab_id = [select clinical_room__c from clinical_time_restriction__c where block_type__c = 'Room' and block_date__c = :current_date 
        and clinical_room__r.center_information__r.market__c = :current_center.market__c
        order by clinical_room__r.name limit 1].clinical_room__c;      
      else if(calendar_view=='Week') {
      	Date start_this_week = current_date.toStartOfWeek();
  	    Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	    current_tab_id = [select clinical_room__c from clinical_time_restriction__c where block_type__c = 'Room' and block_date__c >= :start_this_week and block_date__c <: start_of_next_week 
  	    and clinical_room__r.center_information__r.market__c = :current_center.market__c  limit 1].clinical_room__c;  	    
      }
    }
    display_conflicts_modal = false;
  }
  
  public void open_doctor_block_modal() {
  	display_doctor_block_modal = true;
  	block_view = '';
  	current_tab_id = null;
  	current_edit_id = null;
  	//check to see if we have any blocks on the day - if so it's current.  Otherwise leave it as blank
  	Integer dbcount = getdoctor_block_count();
  	if(dbcount>0) {
  	  block_view = 'Current';
  	  //grab the first doctor in the sequence
  	  if(calendar_view=='Day')
  	    current_tab_id = [select user__c from clinical_time_restriction__c where block_type__c = 'Doctor' and block_date__c = :current_date 
  	    //and user__r.clinic_calendar__c in :getcenter_market_names()
  	    and center_information__c = :current_center.id
  	    order by user__r.name limit 1].user__c;
  	  else if(calendar_view=='Week') {
  	    //get the start of this week and next week
  	    Date start_this_week = current_date.toStartOfWeek();
  	    Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	    current_tab_id = [select user__c from Clinical_Time_Restriction__c where block_type__c = 'Doctor' and block_date__c >= :start_this_week 
  	    and block_date__c < :start_of_next_week 
  	    //and user__r.clinic_calendar__c in :getcenter_market_names()
  	    and center_information__c = :current_center.id
  	     limit 1].user__c;
  	  }  	  
  	}  	
  	display_conflicts_modal = false;
  }
  
  public void open_conflicts_modal() {
  	display_conflicts_modal = true;  	
  }
  
  public void close_conflicts_modal() {
  	display_conflicts_modal = false;
  }
  
  public void close_doctor_block_modal() {
  	display_doctor_block_modal = false;
  }
  
  public void close_room_block_modal() {
  	display_room_block_modal = false;
  }
  
  public List<User> getdoctors_with_blocks() {  	
    List<User> current_block_doctors; 
  	if(calendar_view=='Day')
  	  current_block_doctors = [select id,name from user where id in (select user__c from Clinical_time_restriction__c where block_type__c = 'Doctor' and block_date__c = :current_date
  	  //and user__r.clinic_calendar__c in :getcenter_market_names()
  	  and center_information__c = :current_center.id 
  	  ) order by name];
  	else if(calendar_view=='Week') {
      //get the start of this week and next week
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  current_block_doctors = [select id,name from user where id in (select user__c from Clinical_time_restriction__c where block_type__c = 'Doctor' 
  	    and block_date__c >= :start_this_week and block_date__c < :start_of_next_week 
  	    //and user__r.clinic_calendar__c in :getcenter_market_names()
  	    and center_information__c = :current_center.id
  	    ) order by name];
  	}
  	return current_block_doctors;
  }
  
  public class time_blocks {
  	public Clinical_time_Restriction__c block;
  	public List<Clinical_Apt_Calendar__c> apt_conflicts;
  	
  	public time_blocks(Clinical_time_restriction__c ct) {
  	  this.block = ct;
  	}
  }
  
  public String getcurrent_block_doctor_name() {
  	return [select name from user where id = :current_tab_id].name;
  }
  
  public String getcurrent_block_room_name() {
  	return [select name from Clinical_Room__c where id = :current_tab_id].name;
  }
  
  public List<Clinical_Time_Restriction__c> getcurrent_room_time_blocks() {
  	List<Clinical_Time_Restriction__c> block_list;
  	if(calendar_view=='Day')
  	  block_list = [Select c.start_hour_int__c, c.end_hour_int__c, c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, block_note__c
  	    From Clinical_Time_Restriction__c c
  	    where block_date__c = :current_date  	    
  	    and clinical_room__c = :current_tab_id];
  	else if(calendar_view=='Week') {
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  block_list = [Select c.start_hour_int__c, c.end_hour_int__c, c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, block_note__c 
  	    From Clinical_Time_Restriction__c c
  	    where block_date__c >= :start_this_week
  	    and block_date__c < :start_of_next_week
  	    and clinical_room__c = :current_tab_id];
  	}
  	return block_list;
  }
  
  public List<Clinical_Time_Restriction__c> getcurrent_doctor_time_blocks() {
  	List<Clinical_Time_Restriction__c> block_list;
  	if(calendar_view=='Day')
  	  block_list = [Select c.start_hour_int__c, c.end_hour_int__c, c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c
  	    From Clinical_Time_Restriction__c c
  	    where block_date__c = :current_date
  	    and user__c = :current_tab_id
  	    and center_information__c = :current_center.id];
  	else if(calendar_view=='Week') {
  	  Date start_this_week = current_date.toStartOfWeek();
  	  Date start_of_next_week = current_date.addDays(7).toStartOfWeek();
  	  block_list = [Select c.start_hour_int__c, c.end_hour_int__c, c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c , c.block_note__c
  	    From Clinical_Time_Restriction__c c
  	    where block_date__c >= :start_this_week
  	    and block_date__c < :start_of_next_week
  	    and user__c = :current_tab_id
  	    and center_information__c = :current_center.id];
  	}
  	return block_list;
  }
  
  public void view_room_blocks() {
  	current_tab_id = apexpages.currentpage().getparameters().get('rid');
  	block_view = 'Detail';
  	current_edit_id = null;
  }
  
  public void new_room_block_form() {
  	block_view = 'New';
  	new_time_block = new Clinical_Time_Restriction__c(Clinical_Room__c = current_tab_id, block_date__c = current_date, block_type__c = 'Room', Start_Hour__c = '7', Start_Minute__c = '00',
  	  End_Hour__c = '5', End_Minute__c = '00');
  	sprefix = 'AM';
  	eprefix = 'PM';
  	current_edit_id = null;  
  }
  
  public void view_doctor_new_block() {
  	current_tab_id = apexpages.currentpage().getparameters().get('docid');
  	block_view = 'New';
  	new_time_block = new Clinical_Time_Restriction__c(center_information__c = current_center.id, user__c = current_tab_id, block_date__c = current_date, block_type__c = 'Doctor', Start_Hour__c = '7', Start_Minute__c = '00',
  	  End_Hour__c = '5', End_Minute__c = '00');
  	sprefix = 'AM';
  	eprefix = 'PM';
  	current_edit_id = null;
  }
  
  public void view_doctor_current_blocks() {
  	current_tab_id = apexpages.currentpage().getparameters().get('docid');
  	block_view = 'Current';
  	current_edit_id = null;
  }
  
  public List<User> getdoctor_tab_list() {
  	//adjusting this so it only pulls doctors who are eligible to work on this apt 
  	//modified by cm on 8/14/2017 - pulling list of doctors based on user center assignment now
  	Set<ID> possible_users = new Set<ID>();
  	for(User_Center_Assignment__c uca : [select id,user__c,center_information__c from User_Center_Assignment__c where center_information__r.market__c = :current_center.market__c]) {
  	  possible_users.add(uca.user__c);	
  	}  	  	 	  
  	//return [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name and isactive = true 
  	  //order by isactive desc, name];
  	return [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.id in :possible_users and isactive = true 
  	  order by isactive desc, name];
  }
  
  public List<Clinical_Room__c> getroom_tab_list() {
  	return [select id,name, (Select id From Clinical_Time_Restrictions__r where block_date__c = :current_date) from Clinical_Room__c where center_information__c = :current_center.id and isactive__c = true order by name];
  }
  
  public List<Clinical_Apt_Calendar__c> getdisplay_conflicts() {
  	List<Clinical_Apt_Calendar__c> conflicts = new List<Clinical_Apt_Calendar__c> ();
    if(block_view=='New') {
      conflicts = getestimated_appointment_conflicts();
    }  	  
    else if(block_view=='Current') {
      Integer block_stime = calculate_time_int_from_ampm (shour_holder,new_time_block.start_minute__c,sprefix);
      Integer block_etime = calculate_time_int_from_ampm (ehour_holder,new_time_block.end_minute__c,eprefix);
    
      conflicts = getexisting_apt_conflicts(block_stime,block_etime,new_time_block.block_date__c);  
    }  
  	return conflicts;
  }
      
  public List<Clinical_Apt_Calendar__c> getexisting_apt_conflicts(Integer stime, Integer etime, Date block_date) {
  	System.debug('PC Check Stime : ' + stime + ' Etime : ' + etime);
  	List<Clinical_Apt_Calendar__c> possible_conflicts = new list<Clinical_Apt_Calendar__c>();
  	Set<ID> current_ids = new Set<ID>();  	
  	String query_filter = ' apt_date__c = :block_date and patient_pot_apt__c != null and id not in :current_ids ';
  	if(display_doctor_block_modal) 
  	  query_filter += ' and doctor__c = :current_tab_id ';
  	if(display_room_block_modal)
  	  query_filter += ' and clinical_room__c = :current_tab_id ';
  	for(Clinical_Apt_calendar__c cap : database.query('Select c.end_hour__c, c.end_minute__c, c.end_hour_int__c, c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.id,c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name, c.Etime__c, c.Doctor__c, ' + 
  	  ' c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, c.account__r.name From Clinical_Apt_Calendar__c c where ' + query_filter + ' and (stime__c >= :stime and stime__c < :etime) ')) {
  	  current_ids.add(cap.id);
  	  possible_conflicts.add(cap);    	
  	}
  	//System.debug('Possible Conflicts Size 1 : ' + possible_conflicts.size());
  	for(Clinical_Apt_calendar__c cap : database.query('Select c.end_hour__c, c.end_minute__c, c.end_hour_int__c, c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.id,c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name, c.Etime__c, c.Doctor__c, ' + 
  	  ' c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, c.account__r.name From Clinical_Apt_Calendar__c c where ' + query_filter + ' and (etime__c > :stime and etime__c <= :etime) ')) {
  	  current_ids.add(cap.id);
  	  possible_conflicts.add(cap);  	
  	}
  	//System.debug('Possible Conflicts Size 2 : ' + possible_conflicts.size());
  	for(Clinical_Apt_calendar__c cap : database.query('Select c.end_hour__c, c.end_minute__c, c.end_hour_int__c, c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.id,c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name, c.Etime__c, c.Doctor__c, ' + 
  	  ' c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, c.account__r.name From Clinical_Apt_Calendar__c c where ' + query_filter + ' and (stime__c <= :stime and etime__c >= :etime) ')) {
  	  current_ids.add(cap.id);
  	  possible_conflicts.add(cap);  	
  	}  	
  	//System.debug('Possible Conflicts Size 3 : ' + possible_conflicts.size());  	  	
  	return possible_conflicts;
  }
  
  
  public List<room_change> getpossible_switch_rooms() {
  	List<room_change> all_possible_rooms = new List<room_change>();
  	Map<ID,room_change> room_map = new Map<ID,room_change>();
  	apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  	//Eligible Rooms
  	System.debug('Clinical Appointment : ' + apt_block.patient_pot_apt__r.clinical_appointment__c);
  	System.debug('Current Room ID : ' + apt_block.clinical_room__c);
  	for(Clinical_Room__c cr : [select id,name from clinical_room__c where id in 
  	  (select clinical_room__c from Clinical_Room_Authorized_Apt__c where clinical_appointment__c = :apt_block.patient_pot_apt__r.clinical_appointment__c) and id != :apt_block.clinical_room__c and center_information__c = :current_center.id] ) {
  	  Room_Change matched_room = new Room_Change(cr);
  	  room_map.put(cr.id,matched_room);  	
  	  all_possible_rooms.add(matched_room);   	
  	} 
  	System.debug('Possible Room Size : ' + all_possible_rooms.size());
  	//check for apt conflicts here
  	//grab all blocks in the rooms map for this day,  that have apts scheduled in them
  	for(Clinical_Apt_Calendar__c day_apts : [Select c.end_hour__c, c.end_minute__c, c.end_hour_int__c, c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.id,c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name, c.Etime__c, c.Doctor__c,  
  	   c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, c.account__r.name ,c.patient_pot_apt__r.appointment_description__c
  	  From Clinical_Apt_Calendar__c c 
  	  where account__c != null and clinical_room__c in :room_map.keyset() and apt_date__c = :apt_block.apt_date__c]) {
  	  //block contains our entrie apt
  	  if(day_apts.stime__c <= apt_block.stime__c && day_apts.etime__c >= apt_block.etime__c)
  	    room_map.get(day_apts.clinical_room__c).apt_conflicts.add(day_apts);  	  
  	  //block contains our start time
  	  else if(day_apts.stime__c >= apt_block.stime__c && day_apts.stime__c < apt_block.etime__c)
  	    room_map.get(day_apts.clinical_room__c).apt_conflicts.add(day_apts);  	  
  	  //block contains our end time
  	  else if(day_apts.etime__c > apt_block.stime__c && day_apts.etime__c < apt_block.etime__c) 
  	    room_map.get(day_apts.clinical_room__c).apt_conflicts.add(day_apts);
  	}
  	//check for block conflicts here
  	for(Clinical_Time_Restriction__c ctr : [Select c.clinical_Room__c,c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c
  	  from Clinical_time_Restriction__c  c
  	  where block_type__c = 'Room' and clinical_Room__c in :room_map.keyset() and block_date__c = :apt_block.apt_date__c]) {
  	  //block contains our entrie apt
  	  if(ctr.stime__c <= apt_block.stime__c && ctr.etime__c >= apt_block.etime__c)
  	    room_map.get(ctr.clinical_room__c).block_conflicts.add(ctr);  	  
  	  //block contains our start time
  	  else if(ctr.stime__c >= apt_block.stime__c && ctr.stime__c < apt_block.etime__c)
  	    room_map.get(ctr.clinical_room__c).block_conflicts.add(ctr);  	  
  	  //block contains our end time
  	  else if(ctr.etime__c > apt_block.stime__c && ctr.etime__c < apt_block.etime__c) 
  	    room_map.get(ctr.clinical_room__c).block_conflicts.add(ctr);
  	}  	 	
  	return all_possible_rooms;
  }
  
  
  public class room_change {
  	public Clinical_Room__c room {get; set;}
  	public List<Clinical_Apt_Calendar__c> apt_conflicts {get;set;}
  	public List<Clinical_Time_Restriction__c> block_conflicts {get;set;}
  	
  	public room_change(Clinical_Room__c cr) {
  	  this.room = cr;
  	  this.apt_conflicts = new List<Clinical_Apt_Calendar__c>();
  	  this.block_conflicts = new List<Clinical_Time_Restriction__c>();
  	}
  	
  	public Integer gettotal_conflicts() {
  	  return apt_conflicts.size() + block_conflicts.size();
  	}
  }
  
  public void perform_doctor_switch() {
  	//make sure the change is still allowed
  	Boolean allow_change = false;
  	String new_doc_id = apexpages.currentpage().getparameters().get('docid');
  	apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  	manual_apt = [Select p.id, p.Sort_Order__c, p.Patient_POT__c, p.patient_pot__r.account__r.name, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, 
  	      p.Clinical_Appointment__c, p.clinical_appointment__r.name, p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c
  	    From Patient_POT_Apt__c p
  	    where id = :apt_block.patient_pot_apt__c]; 
  	calculate_doctor_results();
  	for(manual_doctor_results dr : doc_results) {
  	  if(dr.doctor.id == new_doc_id) {
  	  	if(dr.getnum_conflicts()==0)
  	  	  allow_change = true;
  	  }
  	}
  	if(allow_change) {
  	  //figuring out time makeup
      Integer stime = apt_block.stime__c.intvalue();
      Integer etime = apt_block.etime__c.intvalue();
      /*
  	  Integer time_before = 0;
  	  Integer time_dr = 0;
  	  Integer time_after = 0;
  	  String current_stage = 'before';
  	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c = :apt_block.patient_pot_apt__c order by sort_order__c]) {
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
      } */
      apt_time_makeup apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
      Integer time_before = apt_time.time_before;
      Integer time_dr = apt_time.time_dr;
      Integer time_after = apt_time.time_after;
      Integer total_time = time_before + time_dr + time_after;
      Integer dr_stime = stime + time_before;
      Integer dr_etime = dr_stime + time_dr;
      Integer doctor_stime = stime + time_before;
      Integer doctor_etime = doctor_stime + time_dr;
  	  
  	try {
      	//grabbing search inventory prior to deleting stuff,  so that we don't have orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :current_date and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :current_date
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
                    
        Date apt_date = apt_block.apt_date__c;
        Integer sched_dow = apt_block.dow__c.intvalue();
        String account_id = apt_block.account__c;
        String patient_pot_apt_id = apt_block.patient_pot_apt__c;
        String apt_doctor = apt_block.doctor__c;
        
        //cancel the old doctor now - return doctor time   
        List<Clinical_Doctor_Inventory__c> delete_doctor_block_list  = new List<Clinical_Doctor_Inventory__c>();      
	    List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();          
	      
	    if(time_dr>0) {      		            
	      //build our doctor inventory block for future tests        
	      new_doctor_blocks.add( new Clinical_Doctor_Inventory__c(User__c = apt_doctor, Start_Minute__c = String.valueof(gettime_minutes(dr_stime)), 
	        Start_Hour__c = String.valueof(gettime_hours(dr_stime)), End_Minute__c = String.valueof(gettime_minutes(dr_etime)), End_Hour__c = String.valueof(gettime_hours(dr_etime)), 
	        DOW__c = apt_block.dow__c, Calendar_Date__c = apt_block.apt_date__c, center_information__c = current_center.id));
	          
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
	  	    c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c , c.center_information__c
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
	  	   		  	    	   	   
	  	if(new_doctor_blocks.size()>0) 	  	  
	  	  insert new_doctor_blocks;
	  	if(delete_doctor_block_list.size()>0)
	  	  delete delete_doctor_block_list;	  	  
        
        //handle the reschedule to the new doctor now          	
        //grab the doctor inventory - check if we have space before or after the scheduled apt (only worry about the doctor time) - create new blocks as needed
  	    new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    Clinical_Doctor_Inventory__c cdi = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :new_doc_id and calendar_date__c = :apt_date and stime__c <= :doctor_stime and etime__c >= :doctor_etime and center_information__c = :current_center.id];
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
  	      	    
        System.debug('Doctor Inventory Deleted : ' + cdi);
        delete cdi;
        System.debug('Doctor Inventory Blocks Created : ' + new_doctor_blocks.size());
        if(new_doctor_blocks.size()>0) {
          System.debug('New Doctor Blocks : ' + new_doctor_blocks);
          insert new_doctor_blocks;     
        }
      	
  	             
        //create a history entry
        Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = 'Apt has been switched to a new doctor', 
          Clinical_Apt_Calendar__c = apt_block.id, Action__c = 'Change Doctor', Account__c = apt_block.account__c, cancel_reason__c = 'Change Doctor');
        insert cah; 
        
        //update the doctor field on the apt block
        apt_block.doctor__c = new_doc_id;
        update apt_block;                
        apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
        
        rebuild_sinv(csi_old,apt_date);
        display_calendar_modal = false;
        
      } catch (Exception e) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to switch doctors' + e.getlineNumber()));
      	ApexPages.addMessages(e);
      }    

  	} else 
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The doctor you are trying to switch to,  is no longer a valid option'));
  }
  
  public void perform_room_switch() {
  	//make sure the change is still allowed
  	apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  	Boolean allow_change = false;
  	String new_room_id = apexpages.currentpage().getparameters().get('roomid');
  	for(room_change rc : getpossible_switch_rooms()) {
  	  if(rc.room.id == new_room_id) {
  	  	if(rc.gettotal_conflicts()==0)
  	  	  allow_change = true;
  	  }
  	}
  	if(allow_change) {
      //figuring out time makeup
      Integer stime = apt_block.stime__c.intvalue();
      Integer etime = apt_block.etime__c.intvalue();
  	  /*Integer time_before = 0;
  	  Integer time_dr = 0;
  	  Integer time_after = 0;
  	  String current_stage = 'before';
  	  for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c = :apt_block.patient_pot_apt__c order by sort_order__c]) {
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
      } */
      apt_time_makeup apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
      Integer time_before = apt_time.time_before;
      Integer time_dr = apt_time.time_dr;
      Integer time_after = apt_time.time_after;
      Integer total_time = time_before + time_dr + time_after;
      Integer doctor_stime = stime + time_before;
      Integer doctor_etime = doctor_stime + time_dr;
      
      try {
      	//grabbing search inventory prior to deleting stuff,  so that we don't have orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :current_date and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :current_date
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
                    

        Date sched_date = apt_block.apt_date__c;
        Integer sched_dow = apt_block.dow__c.intvalue();
        String account_id = apt_block.account__c;
        String patient_pot_apt_id = apt_block.patient_pot_apt__c;
        String doctor_id = apt_block.doctor__c;
        
        
        //cancel the old appointment now      
	  	//to reduce the number of potential DML operations here,  I'm always adding the exitsing apt block to the delete list and a new version of it to the new list 
	  	//this removes the need for a potential update call down the way.
	  	List<Clinical_Apt_Calendar__c> delete_block_list  = new List<Clinical_Apt_Calendar__c> {apt_block};
	  	List<Clinical_Apt_Calendar__c> new_room_blocks = new List<Clinical_Apt_Calendar__c> {new Clinical_Apt_Calendar__c(apt_date__c = apt_block.apt_date__c, Clinical_Room__c = apt_block.clinical_room__c, 
	  	  CR_Schedule_Block__c = apt_block.cr_schedule_block__c, DOW__c = apt_block.dow__c, end_hour__c = apt_block.end_hour__c, end_minute__c = apt_block.end_minute__c, start_hour__c = apt_block.start_hour__c,  
	  	  start_minute__c = apt_block.start_minute__c) };

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
	  	Clinical_Apt_history__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = 'Apt was cancelled for same day room move', Cancel_Reason__c = 'Change Room', Action__c = 'Cancel', Account__c = apt_block.account__c);        	  	  
	  	    	  	  
	  	if(new_room_blocks.size()>0) 
	  	  insert new_room_blocks;
	  	if(delete_block_list.size()>0)
	  	  delete delete_block_list;
        
        //handle the reschedule in the new room now              	
      	//use same logic as possible conflicts code
        //identify if this block falls inside an existing open block - set CR Block value in a var
        //otherwise CR Block would be empty
        String block_id = null; //will store the first open block id we store here      
        List<Clinical_Apt_Calendar__c> new_blocks = new List<Clinical_Apt_Calendar__c> (); //list to store new blocks created
        List<Clinical_Apt_Calendar__c> delete_blocks = new List<Clinical_Apt_Calendar__c>(); //list to store deleted blocks 
        Clinical_Apt_Calendar__c manual_block; //block for the manual sched - could be inserted or just an update.....
        Set<ID> reviewed_ids = new Set<ID>();
      
        //check for block that covers our entire manual sched time
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c, id           
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :sched_date
  	      and clinical_room__r.center_information__c = :current_center.id 
  	      and clinical_room__c = :new_room_id 
  	      and (stime__c <= :stime and etime__c >= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null)
      	    throw new bendException('You attempted to manually schedule over an existing block');
      	  reviewed_ids.add(ca.id);
      	  //by definition,  you can only have one row here (or something went really wrong)
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  }
      	  
      	  if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	        Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	        new_blocks.add(new_block);
  	        manual_block.start_minute__c = String.valueof(gettime_minutes(stime));
  	        manual_block.start_hour__c = String.valueof(gettime_hours(stime));
  	      }
  	        
  	      if(ca.etime__c > etime) {
  	        //need to create a trailing block as we have some time left over
            Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	    new_blocks.add(new_block);
    	    manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  	      
  	      }
      	  	      	 
        }      
        //check for blocks that contain the stime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c,
           c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :sched_date
          and id not in :reviewed_ids
          and clinical_room__c = :new_room_id
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (stime__c >= :stime and stime__c < :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null)
      	    throw new bendException('You attempted to manually schedule over an existing block');
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//adjust start time
      	  	manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));      	  	
      	  	  	        
  	        if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);    	      	      
  	        }
  	        manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  
      	  }
      	  else {
      	  	//just need to check if it extends beyond our end time (create a new block with the extra)
      	  	if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        }      
        //else a block that contains the etime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c,  c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :sched_date
          and id not in :reviewed_ids
          and clinical_room__c = :new_room_id
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (etime__c > :stime and etime__c <= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null)
      	    throw new bendException('You attempted to manually schedule over an existing block');
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//make end time
      	  	manual_block.End_Minute__c = String.valueof(gettime_minutes(etime));
      	  	manual_block.End_Hour__c =  String.valueof(gettime_hours(etime));      	  	
      	  	  	        
  	        if(ca.stime__c < (stime)) {
  	          //need to create a preceeding block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);   	      	      
  	        }
  	        manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));       	  	 
      	  }
      	  else {
      	  	//just need to check if it extends beyond our start time (create a new block with the extra)
      	  	if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	          Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        } 
               
        //if block_id is still null,  then create a blank block from scratch (no existing blocks covered this period of time in any way)
        if(block_id==null) {
          manual_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(gettime_minutes(stime)), Start_Hour__c = String.valueof(gettime_hours(stime)), End_Minute__c = String.valueof(gettime_minutes(etime)), End_Hour__c = String.valueof(gettime_hours(etime)), 
  	        DOW__c = sched_dow, Clinical_Room__c = new_room_id, Apt_Date__c = sched_date);
        }                 
        //set fields on our manual block
        manual_block.Patient_POT_Apt__c = patient_pot_apt_id;
  	    //Patient_Pot_Apt__c pa = [Select p.Patient_POT__r.opportunity__c, p.patient_pot__r.account__c From Patient_POT_Apt__c p where id = :manual_apt.id]; 
  	    //manual_block.opportunity__c = pa.patient_pot__r.opportunity__c;
  	    manual_block.account__c = account_id;
  	    manual_block.doctor__c = doctor_id;
  	    manual_block.confirmation_status__c = 'Not Confirmed';
  	      	    
  	    //create apt history
  	    //commit changes - Blocks
        System.debug('Manual Block : ' + manual_block);
        if(manual_block.id==null) {
          System.debug('Inserting Block');
          insert manual_block;
        }
        else {
          System.debug('Updating Existing Block');
          update manual_block;
        }  
        apt_block = manual_block;
        last_apt_id = manual_block.id;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        System.debug('Deleted Blocks size : ' + delete_blocks.size());
        if(delete_blocks.size()>0) {
          System.debug('Deleted Blocks : ' + delete_blocks);
          delete delete_blocks;
        }
  	             
        //create a history entry
        Datetime adtime = Datetime.newinstance(manual_block.apt_date__c, Time.newinstance(gettime_hours(stime),gettime_minutes(stime),0,0));        
        cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = manual_block.patient_pot_apt__c, Notes__c = 'Apt has been scheduled - ' + adtime.format('M/dd/yyyy h:mm a'), 
          Clinical_Apt_Calendar__c = manual_block.id, Action__c = 'Scheduled', Account__c = manual_block.account__c);
        //System.debug('Apt History : ' + cah);
        insert cah; 
        
        rebuild_sinv(csi_old,sched_date);
        display_calendar_modal = false;
        
      } catch (Exception e) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to switch rooms'));
      	ApexPages.addMessages(e);
      }    

  	} else 
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The room you are trying to switch to,  is no longer a valid destination'));
  }
  
  public List<Clinical_Apt_Calendar__c> getestimated_appointment_conflicts() {
  	List<Clinical_Apt_Calendar__c> possible_conflicts = new list<Clinical_Apt_Calendar__c>();
  	Integer block_stime = calculate_time_int_from_ampm (new_time_block.start_hour__c,new_time_block.start_minute__c,sprefix);
  	Integer block_etime = calculate_time_int_from_ampm (new_time_block.end_hour__c,new_time_block.end_minute__c,eprefix);
  	
  	possible_conflicts = getexisting_apt_conflicts(block_stime,block_etime,new_time_block.block_date__c);  	
  	return possible_conflicts;
  }
  
  public void edit_doctor_block() {
  	current_edit_id = apexpages.currentpage().getparameters().get('trid');
  	block_view = 'Current';
  	new_time_block = [Select c.center_information__c, c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c 
  	  From Clinical_Time_Restriction__c c
  	  where id = :current_edit_id];
  	//set time holders for the form
  	sprefix = 'AM';
  	eprefix = 'AM';
  	shour_holder = new_time_block.start_hour__c;
  	ehour_holder = new_time_block.end_hour__c; 
  	if(new_time_block.start_hour_int__c==12)
  	  sprefix = 'PM';
  	else if(new_time_block.start_hour_int__c>12) {
  	  shour_holder = String.valueof(new_time_block.start_hour_int__c-12);
  	  sprefix = 'PM';
  	}  	  	
  	if(new_time_block.end_hour_int__c==12)
  	  eprefix = 'PM';
  	else if(new_time_block.end_hour_int__c>12) {
  	  ehour_holder = String.valueof(new_time_block.end_hour_int__c-12);
  	  eprefix = 'PM';
  	}  	  	
  	 
  }
  
  public class schedule_block {
  	public Integer stime;
  	public Integer shour;
  	public Integer sminute;
  	public Integer etime;
  	public Integer ehour;
  	public Integer eminute;
  	public ID sched_block_id {get; set;}
  	
  	public schedule_block(Integer sh, Integer sm, Integer eh, Integer em) {
  	  this.stime = (sh*60) + sm;
  	  this.shour = sh;
  	  this.sminute = sm;
  	  this.etime = (eh*60) + em;
  	  this.ehour = eh;
  	  this.eminute = em;
  	}
  }
  
  public void remove_room_block() {
  	try {
      Clinical_time_Restriction__c remove_block = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, 
        c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.Clinical_Room__c , block_note__c
  	    From Clinical_Time_Restriction__c c
  	    where id = :apexpages.currentpage().getparameters().get('trid')];
  	  Integer block_stime = remove_block.stime__c.intvalue();
  	  Integer block_etime = remove_block.etime__c.intvalue();
  	  String remove_room_id = remove_block.clinical_room__c;  	  
  	  Date bdate = remove_block.block_date__c;       
      Date tdate = System.today();
      Date weekStart = tdate.toStartofWeek();
      Integer dayOfWeek = weekStart.daysBetween(tDate);      
      String block_dow = String.valueof(dayOfWeek);  	
  	  delete remove_block;  
  	  
  	  recover_pending_rescheds(block_stime,block_etime);
  	  //to-do: check to see if we can add room time back to inventory - rebuild search inventory
  	  //grab the rooms current schedule for this dow
  	  List<schedule_block> sched_block_list = new List<schedule_block> ();
  	  for(CR_Schedule_Block__c cb : [Select c.isActive__c, c.Start_Time__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.End_Time__c, 
  	    c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Clinical_Room__c 
  	    From CR_Schedule_Block__c c 
  	    where clinical_room__c = :remove_room_id
	        and isactive__c = true 
	        and dow__c = :Integer.valueof(block_dow)]) {
	    schedule_block sb = new schedule_block(cb.start_hour_int__c.intvalue(), cb.start_minute_int__c.intvalue(), cb.end_hour_int__c.intvalue(), cb.end_minute_int__c.intvalue());
	    sb.sched_block_id = cb.id;
	    sched_block_list.add(sb);
	  }
  	  
  	  List<Clinical_Apt_Calendar__c> new_room_blocks = new List<Clinical_Apt_Calendar__c>();
  	  List<Clinical_Apt_Calendar__c> remove_room_blocks = new List<Clinical_Apt_Calendar__c>();
  	  Set<ID> reviewed_ids = new Set<ID>();
  	 
  	  //System.debug('Checking to see if any time can be recovered from the removed block');
  	  //work through each of these blocks and see if it has an overlap with the time block that was removed.
  	  for(schedule_block sb : sched_block_list) {  	    	  	
  	  	//does block time contain sched block
  	  	if(block_stime <= sb.stime && block_etime >= sb.etime) {
  	  	  //the sb becomes the new room block
  	  	  Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = bdate, Clinical_Room__c = remove_room_id, CR_Schedule_Block__c = sb.sched_block_id, DOW__c = Integer.valueof(block_dow), 
  	  	    end_hour__c = String.valueof(sb.ehour), end_minute__c = String.valueof(sb.eminute), start_hour__c = String.valueof(sb.shour),  start_minute__c = String.valueof(sb.sminute));  	  	  
  	      new_room_blocks.add(nca);  	  	  
  	  	} else if (block_stime>= sb.stime && block_stime < sb.etime) {  	  	
  	  	  //does block start fall inside sched block
  	  	  Clinical_Apt_Calendar__c nca;
  	  	  //check which block ends first
  	  	  if(block_etime <= sb.etime)
  	  	    //use block start time and block end time
  	  	    nca = new Clinical_Apt_Calendar__c(apt_date__c = bdate, Clinical_Room__c = remove_room_id, CR_Schedule_Block__c = sb.sched_block_id, DOW__c = Integer.valueof(block_dow), 
  	  	      end_hour__c = String.valueof(gettime_hours(block_etime)), end_minute__c = String.valueof(gettime_minutes(block_etime)), start_hour__c = String.valueof(gettime_hours(block_stime)), 
  	  	      start_minute__c = String.valueof(gettime_minutes(block_stime)));  	  	    	  	    	
  	  	  else
  	  	    //use block start time and sched end time
  	  	    nca = new Clinical_Apt_Calendar__c(apt_date__c = bdate, Clinical_Room__c = remove_room_id, CR_Schedule_Block__c = sb.sched_block_id, DOW__c = Integer.valueof(block_dow), 
  	  	      end_hour__c = String.valueof(sb.ehour), end_minute__c = String.valueof(sb.eminute), start_hour__c = String.valueof(gettime_hours(block_stime)),  
  	  	      start_minute__c = String.valueof(gettime_minutes(block_stime)));
  	  	  new_room_blocks.add(nca);
  	  	} else if(block_etime > sb.stime && block_etime <= sb.etime) {
  	      //does block end fall inside sched block
  	  	  Clinical_Apt_Calendar__c nca;
  	  	  //check which block starts first
  	  	  if(block_stime>=sb.stime) {  
  	  	    //use block start time and block end time
  	  	    nca = new Clinical_Apt_Calendar__c(apt_date__c = bdate, Clinical_Room__c = remove_room_id, CR_Schedule_Block__c = sb.sched_block_id, DOW__c = Integer.valueof(block_dow), 
  	  	      end_hour__c = String.valueof(gettime_hours(block_etime)), end_minute__c = String.valueof(gettime_minutes(block_etime)), start_hour__c = String.valueof(gettime_hours(block_stime)),  
  	  	      start_minute__c = String.valueof(gettime_minutes(block_stime)));
  	  	  } else {  	  	   
  	  	    //use sched start time and block end time
  	  	    nca = new Clinical_Apt_Calendar__c(apt_date__c = bdate, Clinical_Room__c = remove_room_id, CR_Schedule_Block__c = sb.sched_block_id, DOW__c = Integer.valueof(block_dow), 
  	  	      end_hour__c = String.valueof(gettime_hours(block_etime)), end_minute__c = String.valueof(gettime_minutes(block_etime)), start_hour__c = String.valueof(sb.shour),  
  	  	      start_minute__c = String.valueof(sb.sminute));
  	  	  } 
  	  	  new_room_blocks.add(nca);
  	  	}  	  	  	  	  	     	  
  	  }
  	  //System.debug('End Check - ' + new_room_blocks.size() + ' new block(s) will be created at this point');
  	  //System.debug(new_room_blocks);
  	  
  	  //System.debug('Checking to see if any new blocks overlap with existing apts');
  	  if(new_room_blocks.size()>0) {
  	  	Map<ID,Clinical_Apt_Calendar__c> apt_map = new Map<ID,Clinical_Apt_Calendar__c>();
  	  	List<Clinical_Apt_Calendar__c> all_conflicts = new List<Clinical_Apt_Calendar__c>();
  	    for(Clinical_Apt_Calendar__c ca : new_room_blocks) {
  	  	  //need to pull a list of all clinical apts with people scheduled in them and in this room,  
  	  	  //that intersect with our new room blocks - maintain a set of the apts
  	  	  Integer ca_stime = (Integer.valueof(ca.start_hour__c) * 60) + Integer.valueof(ca.start_minute__c); 
  	  	  Integer ca_etime = (Integer.valueof(ca.end_hour__c) * 60) + Integer.valueof(ca.end_minute__c);
  	  	  for(Clinical_Apt_Calendar__c cac :  getexisting_apt_conflicts(ca_stime,ca_etime,bdate)) {
  	  	  	//make sure this is a new conflict - otherwise we're not interested in it
  	  	  	if(apt_map.get(cac.id)==null) {
  	  	  	  all_conflicts.add(cac);
  	  	  	  apt_map.put(cac.id,cac);
  	  	  	}
  	  	  }  	  	    	  	    	  	    	  	  	      	        	      	       	      	        	    
  	    }
  	    
  	    //work through our conflicts,  and adjust the new blocks as necessary
  	    for(Clinical_Apt_Calendar__c ca : all_conflicts) {
  	      Integer con_stime = (Integer.valueof(ca.start_hour__c) * 60) + Integer.valueof(ca.start_minute__c); 
  	  	  Integer con_etime = (Integer.valueof(ca.end_hour__c) * 60) + Integer.valueof(ca.end_minute__c);	    
	  	    	  	    
	  	  List<Clinical_Apt_Calendar__c> revised_room_blocks = new List<Clinical_Apt_Calendar__c>();
  	      //loop through new_room_blocks
  	      for(Clinical_Apt_Calendar__c nrb : new_room_blocks) {
  	      	Integer nrb_stime = (Integer.valueof(nrb.start_hour__c) * 60) + Integer.valueof(nrb.start_minute__c); 
  	  	    Integer nrb_etime = (Integer.valueof(nrb.end_hour__c) * 60) + Integer.valueof(nrb.end_minute__c);
  	  	    System.debug('Block Time : ' + nrb_stime + ' - ' + nrb_etime + ' Conflict time : ' + con_stime + ' - ' + con_etime);  	      	
  	      	//does the apt dr time contain the clinical doctor inventory block
  	      	if(con_stime <= nrb_stime && con_etime >= nrb_etime) {
  	  	      //this one is easy....the entire block is reserved so we won't add anything to the list
  	  	      //System.debug('Entire block contained - not adding to revised room blocks list');
  	  	    } 
  	  	    //does the apt dr time start fall inside the doctor inventory block
  	  	    else if (con_stime >= nrb_stime && con_stime < nrb_etime) {
  	  	      //System.debug('doctor start time is in block');
  	  	      //do we need a preceeding block
  	  	      if(nrb_stime < con_stime) {
  	  	      	//System.debug('creating a preceeding block');
  	  	      	Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = nrb.apt_date__c, Clinical_Room__c = nrb.clinical_room__c, CR_Schedule_Block__c = nrb.cr_schedule_block__c, DOW__c = nrb.dow__c, 
  	  	      	  end_hour__c = String.valueof(gettime_hours(con_stime)), end_minute__c = String.valueof(gettime_minutes(con_stime)), start_hour__c = nrb.start_hour__c,  start_minute__c = nrb.start_minute__c);  	  	      	
  	            revised_room_blocks.add(nca);	
  	  	      }  	  	      
  	  	      //do we need a trailing block
  	  	      if(nrb_etime > con_etime) {
  	  	      	Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = nrb.apt_date__c, Clinical_Room__c = nrb.clinical_room__c, CR_Schedule_Block__c = nrb.cr_schedule_block__c, DOW__c = nrb.dow__c, 
  	  	      	  end_hour__c = nrb.end_hour__c, end_minute__c = nrb.end_minute__c, start_hour__c = String.valueof(gettime_hours(con_etime)), start_minute__c = String.valueof(gettime_minutes(con_etime)));
  	            revised_room_blocks.add(nca);	
  	  	      }  	  	    	 
  	  	    }  	      	    	      	  
  	      	//does the apt dr time end fall inside the doctor inventory block
  	      	else if (con_etime > nrb_stime && con_etime <= nrb_etime) { 
  	      	  //do we need a preceeding block (probably not at this point since the prevuious check would of caught it,  but better safe than sorry)
  	      	  if(nrb_stime < con_stime) {
  	      	  	Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = nrb.apt_date__c, Clinical_Room__c = nrb.clinical_room__c, CR_Schedule_Block__c = nrb.cr_schedule_block__c, DOW__c = nrb.dow__c, 
  	  	      	  end_hour__c = String.valueof(gettime_hours(con_stime)), end_minute__c = String.valueof(gettime_minutes(con_stime)), start_hour__c = nrb.start_hour__c,  start_minute__c = nrb.start_minute__c);  	  	      	
  	            revised_room_blocks.add(nca);  	      	  	  	  	        
  	  	      }  	  	      
  	      	  //do we need a trailing block - this is the only scenario we're still testing for 
  	      	  if(nrb_etime > con_etime) {
  	      	  	Clinical_Apt_Calendar__c nca = new Clinical_Apt_Calendar__c(apt_date__c = nrb.apt_date__c, Clinical_Room__c = nrb.clinical_room__c, CR_Schedule_Block__c = nrb.cr_schedule_block__c, DOW__c = nrb.dow__c, 
  	  	      	  end_hour__c = nrb.end_hour__c, end_minute__c = nrb.end_minute__c, start_hour__c = String.valueof(gettime_hours(con_etime)), start_minute__c = String.valueof(gettime_minutes(con_etime)));
  	            revised_room_blocks.add(nca);
  	  	      }  	  	    	 	
  	  	    }
  	  	    else 
  	  	      //conflict does not intersect with this room block - return it to the list
  	  	      revised_room_blocks.add(nrb);  	      	
  	      }
  	      //set new doctor blocks to revised doctor blocks
  	      new_room_blocks = revised_room_blocks;
  	    }         	      	    	    
  	  }
  	  //System.debug('End Check - ' + new_room_blocks.size() + ' new block(s) will be created at this point');
  	  //System.debug(new_room_blocks);
  	  
  	  //System.debug('Checking to see if any new blocks overlap with existing time blocks - merge opportunity');	     	    
  	  //if we still have new time blocks, run them against existing time blocks to see if we can extend any of them  
  	  if(new_room_blocks.size()>0) {
  	  	
  	  	//pull a list of our existing open blocks for this day/room
  	  	List<Clinical_Apt_Calendar__c> existing_room_inventory = [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, 
  	  	  c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Apt_Date__c,CR_Schedule_Block__c
  	  	  From Clinical_Apt_Calendar__c c 
  	  	  where clinical_room__c = :remove_room_id and apt_date__c = :bdate and patient_pot_apt__c = null order by stime__c];
  	  	
  	  	//loop through our new block
  	  	for(Clinical_Apt_Calendar__c nrb : new_room_blocks) {
  	  	  Integer nrb_stime = (Integer.valueof(nrb.start_hour__c) * 60) + Integer.valueof(nrb.start_minute__c); 
  	  	  Integer nrb_etime = (Integer.valueof(nrb.end_hour__c) * 60) + Integer.valueof(nrb.end_minute__c);
  	  	  
  	  	  //loop through our existing room inventory
  	  	  List<Clinical_Apt_Calendar__c> revised_existing = new List<Clinical_Apt_Calendar__c>();
  	  	  for(Clinical_Apt_Calendar__c ca : existing_room_inventory) {
  	  	  	//does the new block start time match the existing block end time and do the share a block id
  	  	  	if(nrb_stime==ca.etime__c && nrb.cr_schedule_block__c==ca.cr_schedule_block__c) {
  	  	  	  //extend the new block - add the existing block to the remove list
  	  	  	  nrb.start_minute__c = ca.start_minute__c;
  	  	  	  nrb.start_hour__c = ca.start_hour__c;
  	  	  	  nrb_stime = (Integer.valueof(nrb.start_hour__c) * 60) + Integer.valueof(nrb.start_minute__c); 
  	  	  	  remove_room_blocks.add(ca);
  	  	  	} else if(nrb_etime == ca.stime__c && nrb.cr_schedule_block__c==ca.cr_schedule_block__c) {  	  	  	
  	  	  	  //does the new block end time match the existing block start time and do they shard a block id
  	  	  	  nrb.end_minute__c = ca.end_minute__c;
  	  	  	  nrb.end_hour__c = ca.end_hour__c;
  	  	  	  nrb_etime = (Integer.valueof(nrb.end_hour__c) * 60) + Integer.valueof(nrb.end_minute__c);
  	  	  	  remove_room_blocks.add(ca);
  	  	  	} else   	  	  	  	  	    	  	 
  	  	  	  //otherwise add it back to the list
  	  	  	  revised_existing.add(ca);
  	  	  }
  	  	  //reset existing
  	  	  existing_room_inventory = revised_existing;
  	  	}
  	  }
  	  System.debug('End Check - ' + new_room_blocks.size() + ' new block(s) will be created at this point');
  	  System.debug(new_room_blocks);
  	  
  	  //grabbing old search inventory before we delete stuff,  so we don't end up with orphaned records
  	  List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :bdate and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :bdate
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
  	    	    	   
  	  //create blocks and rebuild search inventory....or do nothing
  	  Boolean rebuild_search_inventory = false;
  	  if(new_room_blocks.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	insert new_room_blocks;
  	  	//System.debug('Inserting ' + new_room_blocks.size() + ' new room inventory blocks');
  	  	//System.debug(new_doctor_blocks);
  	  }
  	  if(remove_room_blocks.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	delete remove_room_blocks;
  	  	//System.debug('Removing ' + remove_room_blocks.size() + ' existing room blocks that were extended');
  	  	//System.debug(remove_doctor_blocks);
  	  }
  	  
  	  //search inventory.....
  	  if(rebuild_search_inventory) {
  	  	System.debug('Should rebuild search inventory');
  	  	//rebuild the search inventory for this day 
        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :bdate and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :bdate and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //bad design here - it queried for each iteration of the loop - switching to use a set list now
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :bdate and user__r.clinic_calendar__c = :current_center.name]) {
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
  	    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the room block. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void remove_doctor_block() {
  	try {
  	  Clinical_time_Restriction__c remove_block = [Select c.center_information__c,c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c 
  	    From Clinical_Time_Restriction__c c
  	    where id = :apexpages.currentpage().getparameters().get('trid')];
  	  Integer block_stime = remove_block.stime__c.intvalue();
  	  Integer block_etime = remove_block.etime__c.intvalue();
  	  String remove_doctor_id = remove_block.user__c;  	  
  	  Date bdate = remove_block.block_date__c;       
      Date tdate = System.today();
      Date weekStart = tdate.toStartofWeek();
      Integer dayOfWeek = weekStart.daysBetween(tDate);      
      String block_dow = String.valueof(dayOfWeek);  	
  	  delete remove_block;

  	  recover_pending_rescheds(block_stime,block_etime);  	  
  	  //to-do: check to see if we can add doctor time back to inventory - rebuild search inventory
  	  //grab the doctors current schedule for this dow
  	  User_Schedule__c us = [Select u.User__c, u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, 
  	    u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c, u.DOW__c 
  	    From User_Schedule__c u
  	    where user__c = :remove_doctor_id
  	    and dow__c = :Integer.valueof(block_dow)
  	    and center_information__c = :current_center.id];
  	  
  	  List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	  List<Clinical_Doctor_Inventory__c> remove_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	  Set<ID> reviewed_ids = new Set<ID>();
  	  
  	  List<schedule_block> sched_block_list = new List<schedule_block> ();
  	  //build blocks based on start time,  lunch time,  end time...either 1 or two blocks are possible (or 0...that makes life easy)
  	  if(us.lunch_start__c!=null) {
  	  	sched_block_list.add(new schedule_block(us.start_hour_int__c.intvalue(), us.start_minute_int__c.intvalue(), us.lunch_start_hour_int__c.intvalue(), us.lunch_start_minute_int__c.intvalue()));
  	  	sched_block_list.add(new schedule_block(us.lunch_end_hour_int__c.intvalue(), us.lunch_end_minute_int__c.intvalue(), us.end_hour_int__c.intvalue(), us.end_minute_int__c.intvalue()));
  	  } else {
  	  	sched_block_list.add(new schedule_block(us.start_hour_int__c.intvalue(), us.start_minute_int__c.intvalue(), us.end_hour_int__c.intvalue(), us.end_minute_int__c.intvalue()));
  	  }
  	  
  	  //System.debug('Checking to see if any time can be recovered from the removed block');
  	  //work through each of these blocks and see if it has an overlap with the time block that was removed.
  	  for(schedule_block sb : sched_block_list) {  	    	  	
  	  	//does block time contain sched block
  	  	if(block_stime <= sb.stime && block_etime >= sb.etime) {
  	  	  //the sb becomes the new doctor block
  	  	  Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(sb.sminute), Start_Hour__c = String.valueof(sb.shour),
  	        End_Minute__c = String.valueof(sb.eminute) , End_Hour__c = String.valueof(sb.ehour), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	      new_doctor_blocks.add(ndi);  	  	  
  	  	} else if (block_stime>= sb.stime && block_stime < sb.etime) {  	  	
  	  	  //does block start fall inside sched block
  	  	  Clinical_Doctor_Inventory__c ndi;
  	  	  //check which block ends first
  	  	  if(block_etime <= sb.etime)
  	  	    //use block start time and block end time
  	  	    ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(gettime_minutes(block_stime)), Start_Hour__c = String.valueof(gettime_hours(block_stime)),
  	          End_Minute__c = String.valueof(gettime_minutes(block_etime)) , End_Hour__c = String.valueof(gettime_hours(block_etime)), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);	
  	  	  else
  	  	    //use block start time and sched end time
  	  	    ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(gettime_minutes(block_stime)), Start_Hour__c = String.valueof(gettime_hours(block_stime)),
  	          End_Minute__c = String.valueof(sb.eminute) , End_Hour__c = String.valueof(sb.ehour), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	  	  new_doctor_blocks.add(ndi);
  	  	} else if(block_etime > sb.stime && block_etime <= sb.etime) {
  	      //does block end fall inside sched block
  	  	  Clinical_Doctor_Inventory__c ndi;
  	  	  //check which block starts first
  	  	  if(block_stime>=sb.stime) {  
  	  	    //use block start time and block end time
  	  	    ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(gettime_minutes(block_stime)), Start_Hour__c = String.valueof(gettime_hours(block_stime)),
  	          End_Minute__c = String.valueof(gettime_minutes(block_etime)) , End_Hour__c = String.valueof(gettime_hours(block_etime)), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	  	  } else {  	  	   
  	  	    //use sched start time and block end time
  	  	    ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(sb.sminute), Start_Hour__c = String.valueof(sb.shour),
  	          End_Minute__c = String.valueof(gettime_minutes(block_etime)) , End_Hour__c = String.valueof(gettime_hours(block_etime)), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	  	  } 
  	  	  new_doctor_blocks.add(ndi);
  	  	}  	  	  	  	  	     	  
  	  }
  	  //System.debug('End Check - ' + new_doctor_blocks.size() + ' new block(s) will be created at this point');
  	  //System.debug(new_doctor_blocks);
  	  
  	  //System.debug('Checking to see if any new blocks overlap with existing apts');
  	  if(new_doctor_blocks.size()>0) {
  	  	Map<ID,Patient_POT_Apt_Procedure__c[]> procedure_map = new Map<ID,Patient_POT_Apt_Procedure__c[]>();
  	  	Map<ID,Clinical_Apt_Calendar__c> apt_map = new Map<ID,Clinical_Apt_Calendar__c>();
  	  	List<Clinical_Apt_Calendar__c> all_conflicts = new List<Clinical_Apt_Calendar__c>();
  	    for(Clinical_Doctor_Inventory__c cdi : new_doctor_blocks) {
  	  	  //need to pull a list of all clinical apts with people scheduled in them and our doctor assigned to it,  
  	  	  //that intersect with our new doctor blocks - maintain a set of the apts and patient pot_apt__c so we can pull procedures
  	  	  Integer cdi_stime = (Integer.valueof(cdi.start_hour__c) * 60) + Integer.valueof(cdi.start_minute__c); 
  	  	  Integer cdi_etime = (Integer.valueof(cdi.end_hour__c) * 60) + Integer.valueof(cdi.end_minute__c);
  	  	  List<Clinical_Apt_Calendar__c> apt_conflicts = getexisting_apt_conflicts(cdi_stime,cdi_etime,bdate);  	  	    	  	  
  	  	  //build a set of our patient_pot_apt__c
  	  	  Set<ID> apt_id_set = new Set<ID>();
  	  	  for(Clinical_Apt_Calendar__c ca : apt_conflicts) {
  	  	  	//make sure this is a new conflict - otherwise we're not interested in it
  	  	  	if(apt_map.get(ca.id)==null) {
  	  	  	  apt_id_set.add(ca.patient_pot_apt__c);
  	  	  	  apt_map.put(ca.id,ca);
  	  	  	  all_conflicts.add(ca);
  	  	  	}
  	  	  }  	  	    	  	    	  	    	  	
  	      //build a map of the procedures tied to these apts so we can calculate doctor time          
          for(Patient_POT_Apt_Procedure__c p : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
            clinical_procedure__r.doctor_required__c,p.patient_pot_apt__c From Patient_POT_Apt_Procedure__c p 
            where isactive__c = true and patient_pot_apt__c in :apt_id_set order by p.sort_order__c]) {
            if(procedure_map.get(p.patient_pot_apt__c)==null) {
          	  Patient_Pot_Apt_procedure__c[] procedure_list = new Patient_POT_Apt_Procedure__c[] {p};
              procedure_map.put(p.patient_pot_apt__c,procedure_list);
            }
            else
              procedure_map.get(p.patient_pot_apt__c).add(p);
          }  	        	      	       	      	        	    
  	    }
  	    
  	    //check to see if any of these apts will have doctor time that overlaps with a new time block we are potentially creating
  	    for(Clinical_Apt_Calendar__c ca : all_conflicts) {
  	      //determine doctor start and end time
	  	  //calculate doctor start and end times for this apt	  	
	  	  Integer btime = ca.stime__c.intvalue();
	  	  Integer doctor_stime = 0;
	  	  Integer doctor_etime = 0;
	  	  if(procedure_map.get(ca.patient_pot_apt__c)!=null) {
	  	    for(Patient_POT_Apt_Procedure__c p : procedure_map.get(ca.patient_pot_apt__c)) {	  	      
	  	      if(p.clinical_procedure__r.doctor_required__c && doctor_stime==0)
	  	        doctor_stime = btime;
	  	      btime += p.time_required__c.intValue();
	  	      if(p.clinical_procedure__r.doctor_required__c)
	  	        doctor_etime = btime;
	  	    }
	  	  }  	    
	  	    	  	    
	  	  List<Clinical_Doctor_Inventory__c> revised_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	      //loop through new_doctor_blocks
  	      for(Clinical_Doctor_Inventory__c cdi : new_doctor_blocks) {
  	      	Integer cdi_stime = (Integer.valueof(cdi.start_hour__c) * 60) + Integer.valueof(cdi.start_minute__c); 
  	  	    Integer cdi_etime = (Integer.valueof(cdi.end_hour__c) * 60) + Integer.valueof(cdi.end_minute__c);
  	  	    System.debug('Block Time : ' + cdi_stime + ' - ' + cdi_etime + ' Dr time : ' + doctor_stime + ' - ' + doctor_etime);
  	      	//does the apt dr time contain the clinical doctor inventory block
  	      	if(doctor_stime <= cdi_stime && doctor_etime >= cdi_etime) {
  	  	      //this one is easy....the entire block is reserved so we won't add anything to the list
  	  	      //System.debug('Entire block contained - not adding to revised doctor list');
  	  	    } 
  	  	    //does the apt dr time start fall inside the doctor inventory block
  	  	    else if (doctor_stime >= cdi_stime && doctor_stime < cdi_etime) {
  	  	      //System.debug('doctor start time is in block');
  	  	      //do we need a preceeding block
  	  	      if(cdi_stime < doctor_stime) {
  	  	      	//System.debug('creating a preceeding block');
  	  	        Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	              End_Minute__c = String.valueof(gettime_minutes(doctor_stime)), End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);	
  	  	      }  	  	      
  	  	      //do we need a trailing block
  	  	      if(cdi_etime > doctor_etime) {
  	  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)),
  	              End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);	
  	  	      }  	  	    	 
  	  	    }  	      	    	      	  
  	      	//does the apt dr time end fall inside the doctor inventory block
  	      	else if (doctor_etime > cdi_stime && doctor_etime <= cdi_etime) { 
  	      	  //do we need a preceeding block (probably not at this point since the prevuious check would of caught it,  but better safe than sorry)
  	      	  if(cdi_stime < doctor_stime) {
  	  	        Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	              End_Minute__c = String.valueof(gettime_minutes(doctor_stime)), End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);	
  	  	      }  	  	      
  	      	  //do we need a trailing block 
  	      	  if(cdi_etime > doctor_etime) {
  	  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = remove_doctor_id, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)),
  	              End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = Integer.valueof(block_dow), Calendar_Date__c = bdate, center_information__c = current_center.id);
  	            revised_doctor_blocks.add(ndi);	
  	  	      }  	  	    	 	
  	  	    }
  	  	    else 
  	  	      //doctor time does not intersect with the doctor inventory block - the block is fine as it is
  	  	      revised_doctor_blocks.add(cdi);  	      	
  	      }
  	      //set new doctor blocks to revised doctor blocks
  	      new_doctor_blocks = revised_doctor_blocks;
  	    }         	      	    	    
  	  }
  	  //System.debug('End Check - ' + new_doctor_blocks.size() + ' new block(s) will be created at this point');
  	  //System.debug(new_doctor_blocks);
  	    	  
  	  //System.debug('Checking to see if any new blocks overlap with existing time blocks - merge opportunity');	     	    
  	  //if we still have new time blocks, run them against existing time blocks to see if we can extend any of them  
  	  if(new_doctor_blocks.size()>0) {
  	  	//pull alist of our existing doctor inventory for this day
  	  	List<Clinical_Doctor_Inventory__c> existing_doctor_inventory = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c 
  	  	  From Clinical_Doctor_Inventory__c c where user__c = :remove_doctor_id and calendar_date__c = :bdate and center_information__c = :current_center.id order by stime__c];
  	  	
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
  	  	  	  remove_doctor_blocks.add(cdi);
  	  	  	} else if(ndi_etime == cdi.stime__c) {  	  	  	
  	  	  	  //does the new block end time match the existing block start time
  	  	  	  ndi.end_minute__c = cdi.end_minute__c;
  	  	  	  ndi.end_hour__c = cdi.end_hour__c;
  	  	  	  ndi_etime = (Integer.valueof(ndi.end_hour__c) * 60) + Integer.valueof(ndi.end_minute__c);
  	  	  	  remove_doctor_blocks.add(cdi);
  	  	  	} else   	  	  	  	  	    	  	 
  	  	  	  //otherwise add it back to the list
  	  	  	  revised_existing.add(cdi);
  	  	  }
  	  	  //reset existing
  	  	  existing_doctor_inventory = revised_existing;
  	  	}
  	  }
  	  //System.debug('End Check - ' + new_doctor_blocks.size() + ' new block(s) will be created at this point');
  	  //System.debug(new_doctor_blocks);
  	  
  	  //grabbing old search inventory before we delete things,  so that we don't end up with orphaned records
  	  List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :bdate and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :bdate
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
  	    
  	  //create blocks and rebuild search inventory....or do nothing
  	  Boolean rebuild_search_inventory = false;
  	  if(new_doctor_blocks.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	insert new_doctor_blocks;
  	  	System.debug('Inserting ' + new_doctor_blocks.size() + ' new doctor inventory blocks');
  	  	//System.debug(new_doctor_blocks);
  	  }
  	  if(remove_doctor_blocks.size()>0) {
  	  	rebuild_search_inventory = true;
  	  	delete remove_doctor_blocks;
  	  	System.debug('Removing ' + remove_doctor_blocks.size() + ' existing doctor blocks that were extended');
  	  	//System.debug(remove_doctor_blocks);
  	  }
  	  
  	  //search inventory.....
  	  if(rebuild_search_inventory) {
  	  	System.debug('Should rebuild search inventory');
  	  	//rebuild the search inventory for this day 
        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :bdate and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :bdate and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //bad design - query was running on each iteration of the loop.  Fixing it
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :bdate and user__r.clinic_calendar__c = :current_center.name]) {
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
  	  
  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the doctor block. Please contact IT for help - ' + e.getlinenumber() + ' ' + e.getcause()));
      ApexPages.addMessages(e);
  	}   	
  }
  
  public Integer calculate_time_int_from_ampm (String hours,String minutes,String prefix) {
  	Integer block_shour = Integer.valueof(hours);
  	if(prefix=='PM' && block_shour!=12)
  	  block_shour += 12; 
  	Integer block_sminute = Integer.valueof(minutes);  	
  	Integer block_stime = (block_shour*60) + block_sminute;
  	return block_stime;
  }
  
  public void recover_pending_rescheds(Integer block_stime,Integer block_etime) {  	
  	System.debug('Recover Pending Stime : ' + block_stime + ' Etime : ' + block_etime);
  	
  	//pull list of pending rescheds that overlap this time
  	List<Clinical_Apt_Calendar__c> pending_list = new List<Clinical_Apt_Calendar__c>();
  	Set<ID> current_ids = new Set<ID>();
  	for(Clinical_Apt_calendar__c cap : [Select c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.id,c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name, c.Etime__c, c.Doctor__c, 
  	  c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, c.account__r.name From Clinical_Apt_Calendar__c c
  	    where apt_date__c = :new_time_block.block_date__c 
  	    and doctor__c = :current_tab_id
  	    and patient_pot_apt__c != null
  	    and apt_status__c = 'Pending Reschedule'
  	    and (stime__c >= :block_stime and stime__c < :block_etime)]) {
  	  current_ids.add(cap.id);
  	  pending_list.add(cap);    	
  	}
  	for(Clinical_Apt_calendar__c cap : [Select c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.account__r.name, c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name,  c.Etime__c, c.Doctor__c, 
  	  c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c
  	  where apt_date__c = :new_time_block.block_date__c
  	    and doctor__c = :current_tab_id
  	    and patient_pot_apt__c != null
  	    and id not in :current_ids
  	    and apt_status__c = 'Pending Reschedule'
  	    and (etime__c > :block_stime and etime__c <= :block_etime)]) {
  	  current_ids.add(cap.id);
  	  pending_list.add(cap);  	
  	}
  	for(Clinical_Apt_calendar__c cap : [Select c.Apt_Status__c, c.Start_Hour__c, c.start_minute__c, c.Start_Hour_Int__c,c.account__r.name, c.Stime__c, c.Patient_POT_Apt__c, c.patient_pot_apt__r.name,  
  	  c.Etime__c, c.Doctor__c, c.Clinical_Room__c, c.clinical_room__r.name, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c
  	  where apt_date__c = :new_time_block.block_date__c
  	    and doctor__c = :current_tab_id 
  	    and patient_pot_apt__c != null
  	    and id not in :current_ids
  	    and apt_status__c = 'Pending Reschedule'
  	    and (stime__c <= :block_stime and etime__c >= :block_etime)]) {
  	  current_ids.add(cap.id);
  	  pending_list.add(cap);  	
  	}
  	
  	//work through this list and test if any of these can be recovered (reset back to an apt_status__c of blank/null)
  	for(Clinical_Apt_Calendar__c ca : pending_list) {  	
  	  Integer block_coverage = 0;
  	  //check for blocks that encompass this apt
  	  block_coverage += [select count() from Clinical_Time_Restriction__c 
  	    where block_date__c = :ca.apt_date__c
  	      and stime__c <= :ca.stime__c and etime__c >= :ca.etime__c
  	      and (clinical_room__r.center_information__c = :current_center.id or center_information__c = :current_center.id)];  	    	  
  	  //check for block that stime falls in this apt
  	  block_coverage += [select count() from Clinical_Time_Restriction__c
  	    where block_date__c = :ca.apt_date__c
  	      and stime__c >= :ca.stime__c and stime__c < :ca.etime__c
  	      and (clinical_room__r.center_information__c = :current_center.id or center_information__c = :current_center.id)];  	    	  
  	  //check for block that etime falls in this apt
  	  block_coverage += [select count() from Clinical_Time_Restriction__c
  	    where block_date__c = :ca.apt_date__c
  	      and etime__c > :ca.stime__c and etime__c < :ca.etime__c
  	      and (clinical_room__r.center_information__c = :current_center.id or center_information__c = :current_center.id)];
  	  if(block_coverage==0) {
  	    ca.apt_status__c = null;
  	  }   	    	  
  	}
  	try {
      update pending_list;
  	}  catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to check for cleared pending status. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void save_room_block() {
  	Integer num_issues = 0;
  	Integer block_shour;
  	Integer block_sminute;
  	Integer block_stime;
  	Integer block_ehour;
  	Integer block_eminute;
  	Integer block_etime;
  	
  	if(block_view=='New') {  	  	
  	  block_shour = Integer.valueof(new_time_block.start_hour__c);
  	  if(sprefix=='PM' && block_shour!=12)
  	    block_shour += 12; 
  	  block_sminute = Integer.valueof(new_time_block.start_minute__c);  	
  	  block_stime = (block_shour*60) + block_sminute;
  	  block_ehour = Integer.valueof(new_time_block.end_hour__c);
  	  if(eprefix=='PM' && block_ehour!=12)
  	    block_ehour += 12; 
  	  block_eminute = Integer.valueof(new_time_block.end_minute__c);
  	  block_etime = (block_ehour * 60) + block_eminute;  	  
  	}
  	else if(block_view=='Current') {
  	  block_shour = Integer.valueof(shour_holder);
  	  if(sprefix=='PM' && block_shour!=12)
  	    block_shour += 12; 
  	  block_sminute = Integer.valueof(new_time_block.start_minute__c);  	
  	  block_stime = (block_shour*60) + block_sminute;
  	  new_time_block.start_hour__c = String.valueof(block_shour);
  	  block_ehour = Integer.valueof(ehour_holder);
  	  if(eprefix=='PM' && block_ehour!=12)
  	    block_ehour += 12; 
  	  block_eminute = Integer.valueof(new_time_block.end_minute__c);
  	  block_etime = (block_ehour * 60) + block_eminute;
  	  new_time_block.end_hour__c = String.valueof(block_ehour);
  	}
  	
  	//trying to block some null entries that managed to sneak in somehow.
  	if((block_shour==null?0:block_shour)==0 || (block_ehour==null?0:block_ehour)==0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid value for start and end hour'));
  	}  	
  	if(new_time_block.block_reason__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a reason for the doctor block'));
  	}  	  
  	if(block_stime>=block_etime) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Starting time must be before ending time'));
    }  	
  	if(num_issues == 0) {
  	  try {
  	  	if(new_time_block.id==null) {
  	  	  //resetting hours to handle AM/PM 
  	  	  new_time_block.start_hour__c = String.valueof(block_shour);
  	  	  new_time_block.end_hour__c = String.valueof(block_ehour);
  	  	  insert new_time_block;
  	      block_view = 'Current';  	      
  	  	}
  	    else {  	      
  	      Clinical_Time_Restriction__c old_block = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c 
  	        From Clinical_Time_Restriction__c c where id = :new_time_block.id];
  	      Integer old_stime = old_block.stime__c.intvalue();
  	      Integer old_etime = old_block.etime__c.intvalue();
          ///check to see if any pending rescheds from the origional time could be marked back in a blank state
          update new_time_block;  	        
          recover_pending_rescheds(old_stime,old_etime);      	        	      
  	      current_edit_id = null;  	     	        	         
  	    }
  	    
  	    List<Clinical_Apt_Calendar__c> pending_list = getexisting_apt_conflicts(block_stime,block_etime,new_time_block.block_date__c);
  	  	for(Clinical_Apt_Calendar__c ca : pending_list) {
  	  	  ca.apt_status__c = 'Pending Reschedule';
  	  	} 
  	  	update pending_list;
  	    
  	    //get current time coverage
  	    new_time_block = [select block_date__c,stime__c,etime__c from Clinical_Time_Restriction__c where id = :new_time_block.id];  	    
  	    
  	    //need to remove room time
  	    //check for any blocks that fall in this time,  or that contain this time
  	    List<Clinical_Apt_Calendar__c> new_room_blocks = new List<Clinical_Apt_Calendar__c>();
  	    List<Clinical_Apt_Calendar__c> delete_room_blocks = new List<Clinical_Apt_Calendar__c>();
  	    
  	    Set<ID> reviewed_ids = new Set<ID>();  	    
  	      	      	        
  	    //check for a block of room time that contains the whole block in question
  	    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, 
  	      c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Apt_Date__c, c.CR_Schedule_Block__c, c.Clinical_Room__c From Clinical_Apt_Calendar__c c where
  	      clinical_room__c = :current_tab_id and apt_date__c = :new_time_block.block_date__c and stime__c <= :new_time_block.stime__c and etime__c >= :new_time_block.etime__c
  	      and Patient_POT_Apt__c = null]) {
  	      reviewed_ids.add(ca.id);
  	      
  	      //do we need to create a preceeding block?
  	      if(ca.stime__c < new_time_block.stime__c) {
  	      	//create the new block
  	      	Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, 
  	      	  End_Minute__c = String.valueof(gettime_minutes(new_time_block.stime__c.intvalue())) , End_Hour__c = String.valueof(gettime_hours(new_time_block.stime__c.intvalue())), 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      	new_room_blocks.add(new_block);
  	      }  	      
  	      //do we need to create a trailing block?
  	      if(ca.etime__c > new_time_block.etime__c) {
  	      	//create the new block
  	      	Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(gettime_minutes(new_time_block.etime__c.intvalue())), Start_Hour__c = String.valueof(gettime_hours(new_time_block.etime__c.intvalue())), 
  	      	  End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      	new_room_blocks.add(new_block);
  	      }
  	      
  	      //delete this block
  	      delete_room_blocks.add(ca);
  	    }
  	    //check for a block that contains the start time
  	    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, 
  	      c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Apt_Date__c, c.CR_Schedule_Block__c, c.Clinical_Room__c From Clinical_Apt_Calendar__c c 
  	      where clinical_room__c = :current_tab_id and apt_date__c = :new_time_block.block_date__c and stime__c >= :new_time_block.stime__c and stime__c < :new_time_block.etime__c
  	      and id not in :reviewed_ids and Patient_POT_Apt__c = null]) {
  	      reviewed_ids.add(ca.id);
  	    	           
  	      //do we need to create a trailing block
  	      if(ca.etime__c > new_time_block.etime__c) {
  	      	//create the new block
  	      	Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(gettime_minutes(new_time_block.etime__c.intvalue())), Start_Hour__c = String.valueof(gettime_hours(new_time_block.etime__c.intvalue())), 
  	      	  End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      	new_room_blocks.add(new_block);
  	      }
  	      
  	      //delete this block
  	      delete_room_blocks.add(ca);
  	    }  	  
  	    //check for a block that contains the end time
  	    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, 
  	      c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Apt_Date__c, c.CR_Schedule_Block__c, c.Clinical_Room__c From Clinical_Apt_Calendar__c c where
  	      clinical_room__c = :current_tab_id and apt_date__c = :new_time_block.block_date__c and etime__c > :new_time_block.stime__c and etime__c <= :new_time_block.etime__c 
  	      and id not in :reviewed_ids and Patient_POT_Apt__c = null]) {
  	      reviewed_ids.add(ca.id);
  	    	           
  	      //do we need to create a preceeding block
  	      if(ca.stime__c < new_time_block.stime__c) {
  	      	//create the new block
  	      	Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, 
  	      	  End_Minute__c = String.valueof(gettime_minutes(new_time_block.stime__c.intvalue())) , End_Hour__c = String.valueof(gettime_hours(new_time_block.stime__c.intvalue())), 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	      	new_room_blocks.add(new_block);  	      	
  	      }  	        	        
  	      
  	      //delete this block
  	      delete_room_blocks.add(ca);
  	    }
  	    
  	    //grabbing search inventory before we delete stuff,  so that we don't end up with a orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :new_time_block.block_date__c and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :new_time_block.block_date__c
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];  	 
  	    
  	    System.debug('Calendar Inventory Delete size : ' + delete_room_blocks.size());
        if(delete_room_blocks.size()>0) {
          System.debug('Calendar Inventory Deleted : ' + delete_room_blocks);
          delete delete_room_blocks;
        }
        System.debug('Calendar Inventory Blocks Created : ' + new_room_blocks.size());
        if(new_room_blocks.size()>0) {
          System.debug('New Room Blocks : ' + new_room_blocks);
          insert new_room_blocks;     
        }  	    
  	    
  	    //rebuild the search inventory for this day 

        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :new_time_block.block_date__c and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :new_time_block.block_date__c and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :new_time_block.block_date__c and user__r.clinic_calendar__c = :current_center.name]) {
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
  	    
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the room block. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void save_doctor_block() {
  	Integer num_issues = 0;
  	Integer block_shour;
  	Integer block_sminute;
  	Integer block_stime;
  	Integer block_ehour;
  	Integer block_eminute;
  	Integer block_etime;
  	
  	if(block_view=='New') {  	  	
  	  block_shour = Integer.valueof(new_time_block.start_hour__c);
  	  if(sprefix=='PM' && block_shour!=12)
  	    block_shour += 12; 
  	  block_sminute = Integer.valueof(new_time_block.start_minute__c);  	
  	  block_stime = (block_shour*60) + block_sminute;
  	  block_ehour = Integer.valueof(new_time_block.end_hour__c);
  	  if(eprefix=='PM' && block_ehour!=12)
  	    block_ehour += 12; 
  	  block_eminute = Integer.valueof(new_time_block.end_minute__c);
  	  block_etime = (block_ehour * 60) + block_eminute;
  	}
  	else if(block_view=='Current') {
  	  block_shour = Integer.valueof(shour_holder);
  	  if(sprefix=='PM' && block_shour!=12)
  	    block_shour += 12; 
  	  block_sminute = Integer.valueof(new_time_block.start_minute__c);  	
  	  block_stime = (block_shour*60) + block_sminute;
  	  new_time_block.start_hour__c = String.valueof(block_shour);
  	  block_ehour = Integer.valueof(ehour_holder);
  	  if(eprefix=='PM' && block_ehour!=12)
  	    block_ehour += 12; 
  	  block_eminute = Integer.valueof(new_time_block.end_minute__c);
  	  block_etime = (block_ehour * 60) + block_eminute;
  	  new_time_block.end_hour__c = String.valueof(block_ehour);
  	}
  	
  	//trying to block some null entries that managed to sneak in somehow.
  	if((block_shour==null?0:block_shour)==0 || (block_ehour==null?0:block_ehour)==0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid value for start and end hour'));
  	}  	  	
  	if(new_time_block.block_reason__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a reason for the doctor block'));
  	}  	  
  	if(block_stime>=block_etime) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Starting time must be before ending time'));
    }  	
  	if(num_issues == 0) {
  	  try {
  	  	if(new_time_block.id==null) {
  	  	  //resetting hours to handle AM/PM 
  	  	  new_time_block.start_hour__c = String.valueof(block_shour);
  	  	  new_time_block.end_hour__c = String.valueof(block_ehour);
  	  	  insert new_time_block;
  	      block_view = 'Current';  	      
  	  	}
  	    else {
  	      
  	      Clinical_Time_Restriction__c old_block = [Select c.center_information__c, c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c 
  	        From Clinical_Time_Restriction__c c where id = :new_time_block.id];
  	      Integer old_stime = old_block.stime__c.intvalue();
  	      Integer old_etime = old_block.etime__c.intvalue();
          ///check to see if any pending rescheds from the origional time could be marked bank in a blank state
          update new_time_block;  	        
          recover_pending_rescheds(old_stime,old_etime);      	        	      
  	      current_edit_id = null;  	     	        	         
  	    }
  	    
  	    List<Clinical_Apt_Calendar__c> pending_list = getexisting_apt_conflicts(block_stime,block_etime,new_time_block.block_date__c);
  	  	for(Clinical_Apt_Calendar__c ca : pending_list) {
  	  	  ca.apt_status__c = 'Pending Reschedule';
  	  	} 
  	  	update pending_list;
  	    
  	    //get current time coverage
  	    new_time_block = [select block_date__c,stime__c,etime__c,user__c from Clinical_Time_Restriction__c where id = :new_time_block.id];  	    
  	    
  	    //need to remove doctor time
  	    //check for any blocks that fall in this time,  or that contain this time
        List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    List<Clinical_Doctor_Inventory__c> delete_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    Set<ID> reviewed_ids = new Set<ID>();  	    
  	      	      	        
  	    //check for a block of doctor time that contains the whole block in question
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, 
  	      c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :current_tab_id and calendar_date__c = :new_time_block.block_date__c and stime__c <= :new_time_block.stime__c and etime__c >= :new_time_block.etime__c
  	      and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	      
  	      //do we need to create a preceeding block?
  	      if(cdi.stime__c < new_time_block.stime__c) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	      	  End_Minute__c = String.valueof(gettime_minutes(new_time_block.stime__c.intvalue())) , End_Hour__c = String.valueof(gettime_hours(new_time_block.stime__c.intvalue())), 
  	      	  DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }  	      
  	      //do we need to create a trailing block?
  	      if(cdi.etime__c > new_time_block.etime__c) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(new_time_block.etime__c.intvalue())), Start_Hour__c = String.valueof(gettime_hours(new_time_block.etime__c.intvalue())),
  	      	  End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }
  	    //check for a block that contains the start time
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :current_tab_id and calendar_date__c = :new_time_block.block_date__c and stime__c >= :new_time_block.stime__c and stime__c < :new_time_block.etime__c and id not in :reviewed_ids
  	      and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	    	           
  	      //do we need to create a trailing block
  	      if(cdi.etime__c > new_time_block.etime__c) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(new_time_block.etime__c.intvalue())), Start_Hour__c = String.valueof(gettime_hours(new_time_block.etime__c.intvalue())),
  	      	  End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }  	  
  	    //check for a block that contains the end time
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :current_tab_id and calendar_date__c = :new_time_block.block_date__c and etime__c > :new_time_block.stime__c and etime__c <= :new_time_block.etime__c and id not in :reviewed_ids
  	      and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	    	           
  	      //do we need to create a preceeding block
  	      if(cdi.stime__c < new_time_block.stime__c) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	      	  End_Minute__c = String.valueof(gettime_minutes(new_time_block.stime__c.intvalue())) , End_Hour__c = String.valueof(gettime_hours(new_time_block.stime__c.intvalue())), 
  	      	  DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }  	        	        
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }  	 
  	    
  	    //grabbing search inventory before we delete stuff,  so that we don't end up with orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :new_time_block.block_date__c and 
          clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :new_time_block.block_date__c
          and clinical_doctor_inventory__r.center_information__c = :current_center.id];
  	    
  	    System.debug('Doctor Inventory Delete size : ' + delete_doctor_blocks.size());
        if(delete_doctor_blocks.size()>0) {
          System.debug('Doctor Inventory Deleted : ' + delete_doctor_blocks);
          delete delete_doctor_blocks;
        }
        System.debug('Doctor Inventory Blocks Created : ' + new_doctor_blocks.size());
        if(new_doctor_blocks.size()>0) {
          System.debug('New Doctor Blocks : ' + new_doctor_blocks);
          insert new_doctor_blocks;     
        }  	    
  	    
  	    //rebuild the search inventory for this day 
        List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
        List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :new_time_block.block_date__c and center_information__c = :current_center.id];
        //loop through all apts for this center/day where the block is open
        for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :new_time_block.block_date__c and
          clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	      //loop through doctor time for this center/day
  	      //bad design - query running on each loop iteration - fixing it
  	      //for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :new_time_block.block_date__c
  	        //and user__r.clinic_calendar__c = :current_center.name]) {
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
        
        //create an auto calendar note reflecting the block          
        //get doctor name
        User block_doc = [select id,name,lastname from User where id = : new_time_block.user__c];
        //clander note text
        String block_note = 'Dr. ' + block_doc.lastname + ' not available from ' + string_time_from_int(new_time_block.stime__c) + ' to ' + string_time_from_int(new_time_block.etime__c);
        Clinical_Calendar_Note__c cnote = new Clinical_Calendar_Note__c(note_date__c = new_time_block.block_date__c, center_information__c = current_center.id, calendar_note__c = block_note);
        insert cnote;            
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the doctor block. Please contact IT for help'));
        ApexPages.addMessages(e);
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','amcmullen@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('cmcdowell@clearchoice.com');
		mail.setSenderDisplayName('Hope Rx - code exception');
		mail.setSubject('Scheduling System - Dr Block Failure');
		mail.setPlainTextBody(e.getMessage());
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	      
  	  }
  	}
  }
  
  public String string_time_from_int(Decimal time_val) {
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
  
  public String getselected_week_label() {
  	String week_label = '';
  	Date sdate = current_date.tostartofweek();
    Date edate = sdate.adddays(6);
    week_label += Datetime.newinstance(sdate,Time.newinstance(0,0,0,0)).format('M/d/yyyy') + ' - ' + Datetime.newinstance(edate,Time.newinstance(0,0,0,0)).format('M/d/yyyy'); 
  	return week_label;
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
  
  public class wu_full_response {
  	public wu_response_detail response;
  	public wu_forecast_full forecast;
  	
  	public wu_full_response() {}
  }
  
  public class wu_forecast_full {
  	public wu_forecast_text txt_forecast;
  	public wu_simple_forecastday simpleforecast;
  	
  	public wu_forecast_full() {}
  }
  
  public class wu_simple_forecastday {
  	public List<wu_simple_forecastday_detail> forecastday;
  	
  	public wu_simple_forecastday() {}
  }
  
  public class wu_simple_forecastday_detail {
  	public Map<String,String> fdate;
  	public Integer period;
  	public Map<String,String> high;
  	public Map<String,String> low;
  	public String conditions;
  	public String icon;
  	public String icon_url;
  	public String skyicon;
  	public Integer pop;
  	public Map<String,String> qpf_allday;
  	public Map<String,String> qpf_day;
  	public Map<String,String> qpf_night;
  	public Map<String,String> snow_allday;
  	public Map<String,String> snow_day;
  	public Map<String,String> snow_night;
  	public Map<String,String> maxwind;
  	public Map<String,String> avewind;
  	public Decimal avehumidity;
  	public Decimal maxhumidity;
  	public Decimal minhumidity;
  	
  	public wu_simple_forecastday_detail() {}
  }
  
  public class wu_forecast_text {
  	public String fdate;
  	public List<wu_forecastday> forecastday;
  	
  	public wu_forecast_text() {}
  }
  
  public class wu_forecastday {
  	public Integer period;
  	public String icon;
  	public String icon_url;
  	public String title;
  	public String fcttext;
  	public String fcttext_metric;
  	public String pop;
  	public wu_forecastday() {}
  }

  public class wu_response_detail {
  	public String version;
  	public String termsofService;
  	public Map<String,String> features;
  	  
  	public wu_response_detail() {} 
  }
    
  public void check_for_weather_data() {
  	//method to check and see if we have weather data for the currently selected center and it was pulled today (createddate = today)
  	//do we have data for today for this center...and does the center have a postal code 
  	Integer wcount = [select count() from Weather__c where createddate = today and center_information__c = :current_center.id];
  	if(current_Center.zip_code__c!=null && wcount==0) {
  	  System.debug('Grabbing Weather Data');
  	    //run an api call to grab weather data and load it in
  	    HttpRequest req = new HttpRequest();
	  	HttpResponse res = new HttpResponse();
	    Http http = new Http();
	    
	    //Production
	    req.setEndpoint('http://api.wunderground.com/api/56a44de3711b6b71/forecast/q/' + current_center.zip_code__c + '.json');
	    req.setTimeout(60000);
	    req.setMethod('GET');
	    
	    try {
	      res = http.send(req);
	      System.debug('Response Status ' + res.getStatusCode());
	      System.debug('Response Body ' + res.getBody());
	      System.debug('Response Code : ' + res.getStatusCode());
	                
		  String sample_response = res.getBody();	       
	      sample_response = sample_response.replace('"date"','"fdate"');
	    
	      wu_full_response deserializeResults = (wu_full_response)JSON.deserialize(sample_response, wu_full_response.class);
	    
	      //test weather record insert
	      List<Weather__c> weather_list = new List<Weather__c>();
	      //System.debug('Type : ' + deserializeResults.forecast.simpleforecast);
	      for(wu_simple_forecastday_detail forecast : deserializeResults.forecast.simpleforecast.forecastday) {
	        Date cdate = Date.newinstance(Integer.valueof(forecast.fdate.get('year')),Integer.valueof(forecast.fdate.get('month')),Integer.valueof(forecast.fdate.get('day')));
	        String dtype = '';
	        if(cdate < System.today())
	          dtype = 'Past';
	        else if(cdate == System.today())
	          dtype = 'Current';
	        else 
	          dtype = 'Forecast'; 	
	        Weather__c wrecord = new Weather__c(center_information__c = current_center.id, calendar_date__c = cdate,
	          data_type__c = dtype, json_data__c = JSON.serialize(forecast), temp_high__c = decimal.valueof(forecast.high.get('fahrenheit')),
	          temp_low__c= decimal.valueof(forecast.low.get('fahrenheit')), conditions__c = forecast.conditions, icon__c = forecast.icon,
	          icon_url__c = forecast.icon_url, pop__c = forecast.pop, qpf_allday__c = decimal.valueof(forecast.qpf_allday.get('in')==null?'0':forecast.qpf_allday.get('in')),
	          qpf_night__c = decimal.valueof(forecast.qpf_night.get('in')==null?'0':forecast.qpf_night.get('in')), qpf_day__c = decimal.valueof(forecast.qpf_day.get('in')==null?'0':forecast.qpf_day.get('in')), 
	          snow_day__c = decimal.valueof(forecast.snow_day.get('in')==null?'0':forecast.snow_day.get('in')), snow_allday__c = decimal.valueof(forecast.snow_allday.get('in')==null?'0':forecast.snow_allday.get('in')), 
	          snow_night__c = decimal.valueof(forecast.snow_night.get('in')==null?'0':forecast.snow_night.get('in')), max_wind__c = decimal.valueof(forecast.maxwind.get('mph')==null?'0':forecast.maxwind.get('mph')), 
	          avg_wind__c = decimal.valueof(forecast.avewind.get('mph')==null?'0':forecast.avewind.get('mph')), max_humidity__c = forecast.maxhumidity, min_humidity__c = forecast.minhumidity);
	        weather_list.add(wrecord);
	        System.debug('Weather Record : ' + wrecord);
	      }
	      insert weather_list;
	    } catch (Exception e) {
	      System.debug('Weather Data Failure');
	      System.debug(e);
	    }
  	}
  }
  
  public void display_calendar_navigation() {
  	display_calendar_view = true;
  	modal_calendar_view = 'calendar';
  	cmonth = new dp_clinical_cmonth(current_date,current_center);
  }
  
  public void close_calendar_navigation() {
  	display_calendar_view = false;
  }
  
  public void next_calendar_month() {
  	cmonth = new dp_clinical_cmonth(cmonth.idate.addmonths(1),current_center);
  }
  
  public void prev_calendar_month() {
  	cmonth = new dp_clinical_cmonth(cmonth.idate.addmonths(-1),current_center);
  }
  
  public void select_calendar_month() {
  	cmonth = new dp_clinical_cmonth(Date.newinstance(cmonth.idate.year(),Integer.valueof(apexpages.currentpage().getparameters().get('mnum')),cmonth.idate.day()),current_center);
  	modal_calendar_view = 'calendar';
  }
  
  public void display_calendar_month_navigation() {
  	modal_calendar_view = 'month';
  }
  
  public void display_calendar_year_navigation() {
  	modal_calendar_view = 'year';
  }
  
  public void select_calendar_year() {
  	cmonth = new dp_clinical_cmonth(Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('myear')),cmonth.idate.month(),cmonth.idate.day()),current_center);
  	modal_calendar_view = 'calendar';
  }
  
  public List<List<String>> getmonth_list() {
  	List<String> month_names = new List<String>();
  	List<List<String>> month_rows = new List<List<String>>();
  	for(Integer i=1;i<=12;i++) {
  	  Datetime month_start = Datetime.newInstance(current_date.year(), i, 1,0,0,0);
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
  	for(Integer i=2011;i<=end_limit;i++) {
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
  
  public void next_calendar_day() {
  	if(calendar_view=='Day')
  	  current_date = current_date.adddays(1);
  	if(calendar_view=='Week')
  	  current_date = current_date.adddays(7);
  	cmonth = new dp_clinical_cmonth(current_date,current_center);
  	if(manual_search)
  	  refresh_possible_map();
  	current_weather = getweather_info(current_date);
  }
  
  public void prev_calendar_day() {
  	if(calendar_view=='Day')
  	  current_date = current_date.adddays(-1);
  	if(calendar_view=='Week')
  	  current_date = current_date.adddays(-7);
  	cmonth = new dp_clinical_cmonth(current_date,current_center);
  	if(manual_search)
  	  refresh_possible_map();
  	current_weather = getweather_info(current_date);
  }
  
  public void select_calendar_day() {
  	current_date = Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('cyear')),Integer.valueof(apexpages.currentpage().getparameters().get('cmonth')),Integer.valueof(apexpages.currentpage().getparameters().get('cday')));
  	cmonth = new dp_clinical_cmonth(current_date,current_center);
  	if(manual_search)
  	  refresh_possible_map();
  	current_weather = getweather_info(current_date);
  }
  
  public void calendar_select_today() {
  	current_date = system.today();
  	display_calendar_view = false;
  	if(manual_search)
  	  refresh_possible_map();
  	current_weather = getweather_info(current_date);
  }
  
  public String getselected_monthname() {
  	Datetime my_datetime = Datetime.newInstance(current_date.year(),current_date.month(),current_date.day());
  	return my_datetime.format('MMM');
  }
  
  public Integer getselected_year() {
  	return current_date.year();
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
  
  public List<Selectoption> getdoctor_search_list() {
  	//modified by cm on 8/14/2017 - using user center assignments to pull list of docs now
  	Set<ID> possible_users = new Set<ID>();
  	for(User_Center_Assignment__c uca : [select id,user__c,center_information__c from User_Center_Assignment__c where center_information__r.market__c = :current_center.market__c]) {
  	  possible_users.add(uca.user__c);	
  	}  	
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('Any','Any Doctor'));
  	for(User u : [select u.id,u.name from User u 
  	  //where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name]) {
  	  where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.id in :possible_users]) {  		
  	  clist.add(new Selectoption(u.id,u.name));
  	} 
	return clist;
  } 
  
  public Boolean getallow_apt_reduction() {
  	//make sure the apt is more than 10 minutes long and that it's on the current date or in the future
  	Boolean allow_reduction = true; 	
  	if((apt_block.etime__c - apt_block.stime__c) <= 10 || apt_block.apt_date__c < system.today())
  	  allow_reduction = false;
  	return allow_reduction;
  }
  
  public Boolean getallow_apt_extension() {
  	//grab the next block in this room and see if it is open or more than 10 minutes out
  	Boolean allow_extension = false;
  	//make sure this is a current/future block
  	if(apt_block.apt_date__c >= system.today()) {
	  	try {
	  	  Clinical_Apt_calendar__c next_apt_block = [select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.account__r.personmobilephone, c.account__r.phone, account__r.email__c,
	  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, 
	  	    c.confirmation_status__c, c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, 
	  	    account__r.recent_height_feet__c, account__r.recent_height_inches__c, account__r.recent_weight__c, patient_pot_apt__r.clinical_Appointment__r.clinical_Notes_Form__c,
	  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c 
	  	    from Clinical_Apt_Calendar__c  c
	  	    where clinical_room__c = :apt_block.clinical_room__c and apt_date__c = :apt_block.apt_date__c and stime__c >= :apt_block.etime__c order by stime__c limit 1];
	  	  //see if this block is open or if it's more than 10 minutes out....if it is,  then we can extend the current block
	  	  if(next_apt_block.account__c==null || next_apt_block.stime__c >= (apt_block.etime__c + 10))
	  	    allow_extension = true;	
	  	  //make sure there are no room block issues
	  	  for(Clinical_Time_Restriction__c ctr : [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Clinical_Room__c, c.Block_Type__c, c.Block_Reason__c, c.Block_Date__c, c.block_note__c 
            From Clinical_Time_Restriction__c c 
            where block_date__c =: apt_block.apt_date__c and clinical_room__c= :apt_block.clinical_room__c order by stime__c]) {
            //check if room block contains our target
            if(ctr.stime__c < (apt_block.etime__c + 10) && ctr.etime__c >= (apt_block.etime__c + 10)) 
              allow_extension = false;         
          }  	  	  
	  	} catch (Exception e) {
	  	  //there is no future block in this room - we can extend the current block safely  	  
	      allow_extension = true;  		
	  	}  	
  	}
  	return allow_extension;
  }
  
  public void rebuild_sinv(List<Clinical_Search_Inventory__c> csi_old, Date search_date) {
  	//rebuild the search inventory for this day 
    List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
    List<Clinical_Doctor_Inventory__c> day_doc_inventory = [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :search_date
      and center_information__c = :current_center.id];
    //loop through all apts for this center/day where the block is open
    for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :search_date and
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
  }  
  
  public void reduce_apt_block() {
  	try {
  	  //adjusting this so it uses the id when available - for the quick buttons
  	  //apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  	  if(apexpages.currentpage().getparameters().get('aptid')!=null)  	  
  	    apt_block = getapt_block(apexpages.currentpage().getparameters().get('aptid'));
      //make sure we can still extend this block
      if(getallow_apt_reduction()) {      	
      	List<Clinical_Apt_Calendar__c> update_block_list = new List<Clinical_Apt_Calendar__c> ();
      	//grabbing search inventory before any changes occur - in order to prevent orphaned records
  	    List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :apt_block.apt_date__c and 
            clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :apt_block.apt_date__c
            and clinical_doctor_inventory__r.center_information__c = :current_center.id];
      	 
      	Integer new_etime = apt_block.etime__c.intvalue() - 10;
      	Clinical_Apt_Calendar__c next_apt_block;
      	try {
          next_apt_block = [select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.account__r.personmobilephone, c.account__r.phone, account__r.email__c,
	  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, 
	  	    c.confirmation_status__c, c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, 
	  	    account__r.recent_height_feet__c, account__r.recent_height_inches__c, account__r.recent_weight__c, patient_pot_apt__r.clinical_Appointment__r.clinical_Notes_Form__c,
	  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c 
	  	    from Clinical_Apt_Calendar__c  c
	  	    where clinical_room__c = :apt_block.clinical_room__c and apt_date__c = :apt_block.apt_date__c and stime__c = :apt_block.etime__c order by stime__c limit 1];
      	} catch (Exception e) {
      		//there is no follow up block
      	}	  	
	    if(next_apt_block!=null) {
	      //check to see if we have an open block following this apt
	  	  //if so,  return the time to it....else create a new 10 minute block.
	  	  if(next_apt_block.account__c==null) {
	  	  	//we can extend this block
	  	  	next_apt_block.start_hour__c = String.valueof(gettime_hours(new_etime));
	  	  	next_apt_block.start_minute__c = String.valueof(gettime_minutes(new_etime));
	  	  	update_block_list.add(next_apt_block);	  	  	
	  	  } else {
	  	  	//make sure there is no room block here - since it's only a 10 minute block,  we're looking for a room block that contains this chunk of time...no need to detect for a split
	  	  	Integer rblock_count = [select count() from Clinical_Time_Restriction__c 
	  	  	  where clinical_room__c = :apt_block.clinical_room__c and block_date__c = :apt_block.apt_date__c and stime__c <= :new_etime and etime__c >= :apt_block.etime__c];
	  	  	//if no room blocks exist - create a new block
	  	  	if(rblock_count==0) {	  	  	
	  	  	  Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(apt_date__c = apt_block.apt_date__c, Clinical_Room__c = apt_block.clinical_room__c, 
	            CR_Schedule_Block__c = apt_block.cr_schedule_block__c, DOW__c = apt_block.dow__c, end_hour__c = apt_block.end_hour__c, end_minute__c = apt_block.end_minute__c, 
	            start_hour__c = String.valueof(gettime_hours(new_etime)),  start_minute__c = String.valueof(gettime_minutes(new_etime)));
	          update_block_list.add(new_block);
	  	  	}
	  	  }
	    } else {
	      //no block following this one
	      //make sure there is no room block here - since it's only a 10 minute block,  we're looking for a room block that contains this chunk of time...no need to detect for a split
	  	  Integer rblock_count = [select count() from Clinical_Time_Restriction__c 
	  	    where clinical_room__c = :apt_block.clinical_room__c and block_date__c = :apt_block.apt_date__c and stime__c <= :new_etime and etime__c >= :apt_block.etime__c];
	  	  //if no room blocks exist - create a new block
	  	  if(rblock_count==0) {
	        Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(apt_date__c = apt_block.apt_date__c, Clinical_Room__c = apt_block.clinical_room__c, 
	          CR_Schedule_Block__c = apt_block.cr_schedule_block__c, DOW__c = apt_block.dow__c, end_hour__c = apt_block.end_hour__c, end_minute__c = apt_block.end_minute__c, 
	          start_hour__c = String.valueof(gettime_hours(new_etime)),  start_minute__c = String.valueof(gettime_minutes(new_etime)));
	        update_block_list.add(new_block);
	  	  }
	    }      	  
      	      	 	   	    
  	    //see if this block required doctor time - specifically we're checking to see if the doctor time occurs during the period we're reducting the apt by
  	    /*Integer time_before = 0;
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
        }*/
        apt_time_makeup apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
        Integer time_before = apt_time.time_before;
        Integer time_dr = apt_time.time_dr;
        Integer time_after = apt_time.time_after;
        
        //see if the doctor time covers the reduction area - otherwise there is no dr time to return to the system
        if((apt_block.stime__c.intvalue() + time_before + time_dr) > new_etime) {
          //see if we have a doctor time block here
          Integer dblock_count = [select count() from Clinical_Time_Restriction__c 
	  	  	  where user__c = :apt_block.doctor__c and block_date__c = :apt_block.apt_date__c and stime__c <= :new_etime and etime__c >= :apt_block.etime__c
	  	  	  and block_type__c = 'Doctor' and center_information__c = :current_center.id];
	  	  //if not,  then return doctor time
	  	  if(dblock_count==0) {            
            //check for the next doctor time slot on this day that would be possible to extend (it should have a start time set at the existing end time of the block that is shrinking)
            List<Clinical_Doctor_Inventory__c> updated_doc_inv = new List<Clinical_Doctor_Inventory__c>();
            Clinical_Doctor_Inventory__c next_dinv;
              try {
                next_dinv = [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Etime__c, 
  	  	          c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c 
  	  	          From Clinical_Doctor_Inventory__c c where user__c = :apt_block.doctor__c and calendar_date__c = :apt_block.apt_date__c 
  	  	          and stime__c = :apt_block.etime__c and center_information__c = :current_center.id order by stime__c limit 1];
              } catch (Exception e) {//there is no block---that's fine
              }
            if(next_dinv!=null) {
              next_dinv.start_hour__c = String.valueof(gettime_hours(new_etime));
              next_dinv.start_minute__c = String.valueof(gettime_minutes(new_etime));
              updated_doc_inv.add(next_dinv);
            } else {
              //if not...add a new doctor time block
              Clinical_Doctor_Inventory__c new_doc_block =  new Clinical_Doctor_Inventory__c(User__c = apt_block.doctor__c, Start_Minute__c = String.valueof(gettime_minutes(new_etime)) , Start_Hour__c = String.valueof(gettime_hours(new_etime)),
  	            End_Minute__c = apt_block.end_minute__c, End_Hour__c = apt_block.end_hour__c, DOW__c = apt_block.dow__c, Calendar_Date__c = apt_block.apt_date__c, center_information__c = current_center.id);
              updated_doc_inv.add(new_doc_block);
            }
            upsert updated_doc_inv;
	  	  }          
        }           	      	    
  	    
  	    //always reduce the size of our block by 10 minutes and record a history entry, and try to add a procedure to the apt
  	    //always extend the size of our block by 10 minutes,  record a history entry,  and add a procedure to the apt
  	    try {
	  	    Clinical_Procedure__c extension_proc = [Select c.center_information__r.name, c.Time_Required__c, c.Procedure_Filter__c, c.Procedure_Description__c, c.Name,
	  	         c.Insurance_Fee__c, c.Id, c.Default_Teeth_Selection__c, c.Cost__c, c.Allow_Tooth_Selection__c, c.ADA_Code__c 
	  	       From Clinical_Procedure__c c 
	  	       where name = 'Reduce 10 Minutes' and center_information__c = :current_center.id];
	  	    Integer current_sort_order = [select sort_order__c from patient_pot_apt_procedure__c where patient_pot_apt__c = :apt_block.patient_pot_apt__c order by sort_order__c desc limit 1].sort_order__c.intvalue() + 1;  	     	   
	  	    Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = extension_proc.ADA_Code__c, Clinical_Procedure__c = extension_proc.id,
	  	      Cost__c = extension_proc.Cost__c, Insurance_Fee__c = extension_proc.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = apt_block.patient_pot_apt__c,
	  	      Sort_Order__c = current_sort_order, Time_Required__c = extension_proc.Time_Required__c, name = extension_proc.name, allow_tooth_selection__c = extension_proc.allow_tooth_selection__c,
	  	      target_teeth__c = extension_proc.default_teeth_selection__c, procedure_description__c = extension_proc.Procedure_Description__c);
	  	    insert new_procedure;
  	    } catch (Exception e) {
  	       //center is likely missing the procedure - not overly concerned about this
  	    }
  	    	      	      	    
  	    apt_block.end_minute__c = String.valueof(gettime_minutes(new_etime));
  	    apt_block.end_hour__c = String.valueof(gettime_hours(new_etime));
  	    update_block_list.add(apt_block);
  	    upsert update_block_list;
  	    Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = 'Apt has been reduced 10 minutes', Clinical_Apt_Calendar__c = apt_block.id, 
          Action__c = 'Reduced', Account__c = apt_block.account__c);
        insert cah; 
        rebuild_sinv(csi_old,apt_block.apt_date__c);
        apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);   
      } else
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This block is no longer eligible for a reduction.'));
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to reduce this block.'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public String getdate_parse_out() {
    return current_date.format(); 
  }
  
  public void extend_apt_block() {
  	try {
  	  //adjusting this so it uses the id when available - for the quick buttons
  	  //apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
  	  if(apexpages.currentpage().getparameters().get('aptid')!=null)  	  
  	    apt_block = getapt_block(apexpages.currentpage().getparameters().get('aptid'));
      //make sure we can still extend this block
      if(getallow_apt_extension()) {      	 	  
  	    //grab the next block in this room....if there is one and it's start time matches out end time,  then reduce the size of that block and rebuild search inventory
  	    Clinical_Apt_calendar__c next_apt_block;
  	    try {
  	      next_apt_block = [select c.SystemModstamp, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.account__r.personmobilephone, c.account__r.phone, account__r.email__c,
	  	    c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, 
	  	    c.confirmation_status__c, c.End_Hour_Int__c, c.Doctor__c, c.DOW__c, c.CreatedDate, c.CreatedById, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, 
	  	    account__r.recent_height_feet__c, account__r.recent_height_inches__c, account__r.recent_weight__c, patient_pot_apt__r.clinical_Appointment__r.clinical_Notes_Form__c,
	  	    account__r.firstname, account__r.lastname, account__r.name, patient_pot_apt__r.name, patient_pot_apt__c, doctor__r.name, account__r.billingcity, apt_status__c 
	  	    from Clinical_Apt_Calendar__c  c
	  	    where clinical_room__c = :apt_block.clinical_room__c and apt_date__c = :apt_block.apt_date__c and stime__c >= :apt_block.etime__c order by stime__c limit 1];
  	    } catch (Exception e) {}
	    if(next_apt_block!=null) {
	      System.debug('Next Apt Block : ' + next_apt_block);
	      if(next_apt_block.stime__c==apt_block.etime__c) {
	      	System.debug('Next Apt Block : ' + next_apt_block);
	      	//blocks are back to back - shrink the next block
	      	//grabbing search inventory before any deletions occur - in order to prevent orphaned records
  	        List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :apt_block.apt_date__c and 
              clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :apt_block.apt_date__c
              and clinical_doctor_inventory__r.center_information__c = :current_center.id];
	      	//is the next block more than 10 minutes long?
	      	if((next_apt_block.etime__c - next_apt_block.stime__c)>10) {
	      	  System.debug('Change Start Time on next block');
	      	  Integer new_stime = next_apt_block.stime__c.intvalue() + 10;
	      	  next_apt_block.start_minute__c = String.valueof(gettime_minutes(new_stime));           
	      	  next_apt_block.start_hour__c = String.valueof(gettime_hours(new_stime));
	      	  update next_apt_block; 
	      	}
	      	else {
	      	  //it's only a 10 minute block - just delete it
	      	  System.debug('Next Block is 10 minutes - delete it');
	      	  delete next_apt_block;
	      	}
	      	rebuild_sinv(csi_old,apt_block.apt_date__c);
	      }	
	    }
  	  
  	    //always extend the size of our block by 10 minutes,  record a history entry,  and add a procedure to the apt
  	    Clinical_Procedure__c extension_proc = [Select c.center_information__r.name, c.Time_Required__c, c.Procedure_Filter__c, c.Procedure_Description__c, c.Name,
  	         c.Insurance_Fee__c, c.Id, c.Default_Teeth_Selection__c, c.Cost__c, c.Allow_Tooth_Selection__c, c.ADA_Code__c 
  	       From Clinical_Procedure__c c 
  	       where name = 'Add 10 Minutes' and center_information__c = :current_center.id];
  	    Integer current_sort_order = [select sort_order__c from patient_pot_apt_procedure__c where patient_pot_apt__c = :apt_block.patient_pot_apt__c order by sort_order__c desc limit 1].sort_order__c.intvalue() + 1;  	     	   
  	    Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = extension_proc.ADA_Code__c, Clinical_Procedure__c = extension_proc.id,
  	      Cost__c = extension_proc.Cost__c, Insurance_Fee__c = extension_proc.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = apt_block.patient_pot_apt__c,
  	      Sort_Order__c = current_sort_order, Time_Required__c = extension_proc.Time_Required__c, name = extension_proc.name, allow_tooth_selection__c = extension_proc.allow_tooth_selection__c,
  	      target_teeth__c = extension_proc.default_teeth_selection__c, procedure_description__c = extension_proc.Procedure_Description__c);
  	    insert new_procedure;
  	    Integer new_etime = apt_block.etime__c.intvalue() + 10;  	    
  	    apt_block.end_minute__c = String.valueof(gettime_minutes(new_etime));
  	    apt_block.end_hour__c = String.valueof(gettime_hours(new_etime));
  	    update apt_block;
  	    Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, Notes__c = 'Apt has been extended 10 minutes', Clinical_Apt_Calendar__c = apt_block.id, 
          Action__c = 'Extended', Account__c = apt_block.account__c);
        insert cah; 
        apt_block = getapt_block(apt_block==null?apexpages.currentpage().getparameters().get('aptid'):apt_block.id);
      } else
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This block is no longer eligible for an extension.'));
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to extend this block.'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public String getblock_health_history_status() {
  	String hhistory_status = 'Not Started';
  	try {
      if(apt_block.account__c!=null) {
      	Patient_Health_History__c phh = [select id,is_complete__c from Patient_Health_History__c where account__c = :apt_block.account__c];
      	if(phh.is_complete__c)
      	  hhistory_status = 'Completed';
      	else
      	  hhistory_status = 'Partially Complete';
      }
  	} catch (Exception e) {
  		
  	}
  	return hhistory_status;  	
  }
  
  public void quick_sd_resched() {
  	cancel_reason = 'Schedule Management';
  	quick_manual_resched();
  }
  
  public void quick_manual_resched() {  	
  	apt_block = getapt_block(apexpages.currentpage().getparameters().get('mrid'));
  	manual_apt = [Select p.id, p.Sort_Order__c, p.Patient_POT__c, p.patient_pot__r.account__r.name, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, 
  	    p.Clinical_Appointment__c, p.clinical_appointment__r.name, p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c
  	  From Patient_POT_Apt__c p
  	  where id = :apt_block.patient_pot_apt__c];
  	try {
  	  //Integer board_count = [select count() from clinical_clipboard__c where createdbyid = :userinfo.getuserid() and patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	  Integer board_count = [select count() from clinical_clipboard__c where center_information__c = :current_center.id and patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	  if(board_count==0) {  	  	
  	    Clinical_Clipboard__c new_item = new Clinical_Clipboard__c(account__c = apt_block.account__c, arrival_time__c = apt_block.arrival_time__c, ready_time__c = apt_block.ready_time__c,
  	      apt_start_time__c = apt_block.apt_start_time__c, patient_pot_apt__c = apt_block.patient_pot_apt__c, center_information__c = current_center.id);
  	    Integer cni_count = [select count() from clinical_note_instance__c where clinical_apt_calendar__c = :apt_block.id and patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	    if(cni_count>0) 
  	      new_item.clinical_note_instance__c = [select id from clinical_note_instance__c where clinical_apt_calendar__c = :apt_block.id and patient_pot_apt__c = :apt_block.patient_pot_apt__c].id;
  	    insert new_item;
  	  }
  	} catch (Exception e) {
  	  //not too concerned if this fails
  	}
  	cancel_scheduled_apt();
  	manual_search = true;
  	refresh_possible_map();  	
  }
  
  public Boolean getallow_sd_resched_option() {
  	if(apt_block.apt_date__c==System.today())
  	  return true;
  	else
  	  return false;      	
  }
  
  public Boolean getallow_sd_apt_change() {
  	Set<String> completed_status = new Set<String> {'Completed','Incomplete','No Show','Patient Left'};
  	if(apt_block.apt_date__c==System.today() && !completed_status.contains(apt_block.apt_status__c))
  	  return true;
  	else
  	  return false;
  }
  
  public void add_to_clipboard() {
  	try {
  	  apt_block = getapt_block(apexpages.currentpage().getparameters().get('cbid'));
  	  //make sure this apt is not already on the clipboard
  	  //Integer board_count = [select count() from clinical_clipboard__c where createdbyid = :userinfo.getuserid() and patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	  Integer board_count = [select count() from clinical_clipboard__c where center_information__c = :current_center.id and patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	  if(board_count==0) {
  	    Clinical_Clipboard__c new_item = new Clinical_Clipboard__c(account__c = apt_block.account__c, arrival_time__c = apt_block.arrival_time__c, ready_time__c = apt_block.ready_time__c,
  	      apt_start_time__c = apt_block.apt_start_time__c, patient_pot_apt__c = apt_block.patient_pot_apt__c, center_information__c = current_center.id);
  	    Integer cni_count = [select count() from clinical_note_instance__c where clinical_apt_calendar__c = :apt_block.id and patient_pot_apt__c = :apt_block.patient_pot_apt__c];
  	    if(cni_count>0) 
  	      new_item.clinical_note_instance__c = [select id from clinical_note_instance__c where clinical_apt_calendar__c = :apt_block.id and patient_pot_apt__c = :apt_block.patient_pot_apt__c].id;  
  	    insert new_item;
  	  }  	
  	  cancel_reason = 'Schedule Management';
  	  cancel_scheduled_apt();
  	  close_confirmation_modal();
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to move this block to the clipboard.'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void toggle_clipboard_display() {
  	display_clipboard = (display_clipboard?false:true);  	
  }
  
  public class clipboard_item {
  	public Clinical_Clipboard__c board {get; set;}
  	public Patient_Pot_Apt__c apt {get; set;}
  	
  	public clipboard_item(Clinical_clipboard__c clip, Patient_pot_apt__c ppa) {
  	  this.board = clip;
  	  this.apt = ppa;
  	}
  	
  	public String gethippa_name() {
  	  //andy actually wants full name here....
  	  return board.account__r.firstname + ' ' + board.account__r.lastname;
      //return board.account__r.firstname + ' ' + board.account__r.lastname.left(1);
  	}
  	
  	//methods for history stuff - pull from apt history entries
  	
  	public Boolean getallow_delete() {
  	  //only allow them to remove clipboard items that have not been marked into a state
  	  if(board.clinical_note_instance__c==null)
  	    return true;
  	  else
  	    return false;
  	} 
  	
  }
  
  public String getclipboard_header() {
  	//Integer clip_count = [select count() from clinical_clipboard__c where createdbyid = :userinfo.getuserid()];
  	Integer clip_count = [select count() from clinical_clipboard__c where center_information__c = :current_center.id];
  	String clip_header = '';
  	//if(display_clipboard)
  	  //clip_header = 'Clipboard ';
  	clip_header += '(' + String.valueof(clip_count) +  ')';
  	return clip_header;
  }
  
  public List<clipboard_item> getclipboard() {
  	List<clipboard_item> clipboard = new List<clipboard_item> ();
  	Set<Id> apt_ids = new Set<ID>();
  	
  	//List<Clinical_Clipboard__c> clip = [select id,account__c,account__r.name,account__r.firstname,account__r.lastname,patient_pot_apt__c,patient_pot_apt__r.name,createddate,center_information__c from clinical_clipboard__c where createdbyid = :userinfo.getuserid()];
  	List<Clinical_Clipboard__c> clip = [select id,account__c,account__r.name,account__r.firstname,account__r.lastname,patient_pot_apt__c,patient_pot_apt__r.name,createddate,center_information__c,clinical_note_instance__c 
  	  from clinical_clipboard__c where center_information__c = :current_center.id];
  	for(Clinical_Clipboard__c cc : clip) {
      apt_ids.add(cc.patient_pot_apt__c);
  	}
  	
  	Map<Id,Patient_Pot_Apt__c> apt_map = new Map<Id,Patient_Pot_Apt__c> ([Select p.name,p.Sort_Order__c, p.patient_pot__r.name, p.Patient_POT__c, p.Lab_Time__c, p.Id, p.Days_Out__c, p.Clinical_Appointment__c, p.Appointment_Description__c, 
  	  (Select Action__c, Clinical_Apt_Calendar__c, Reschedule_Reason__c, Cancel_Reason__c, Delete_Reason__c, Notes__c, Action_Reason__c, Incomplete_Reason__c From Clinical_Apt_Histories__r) 
  	  From Patient_POT_Apt__c p
  	  where id in :apt_ids]);
  	for(Clinical_Clipboard__c cc : clip) {
  	  clipboard_item clip_item = new clipboard_item(cc,apt_map.get(cc.patient_pot_apt__c));
  	  clipboard.add(clip_item);
  	}

  	return clipboard;
  }
  
  public void remove_from_clipboard() {
  	try {
  	  Clinical_Clipboard__c cb = [select id from clinical_clipboard__c where id = :apexpages.currentpage().getparameters().get('cbid')];
  	  delete cb;
  	}  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to remove an item from the clipboard.'));
      ApexPages.addMessages(e);	
  	}
  }  
  
  public void sched_from_clipboard() {  	  	
  	manual_apt = [Select p.id, p.Sort_Order__c, p.Patient_POT__c, p.patient_pot__r.account__r.name, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, 
  	    p.Clinical_Appointment__c, p.clinical_appointment__r.name, p.Appointment_Description__c,name, p.clinical_appointment__r.center_information__c
  	  From Patient_POT_Apt__c p
  	  where id = :apexpages.currentpage().getparameters().get('cbid')];
  	manual_search = true;
  	refresh_possible_map();
  	display_clipboard = false;
  }
  
  public void confirm_add_to_clipboard() {
  	confirmation_modal_display = true;
  	modal_type = 'clipboard';
  	apt_block = apt_block = getapt_block(apexpages.currentpage().getparameters().get('cbid'));
  	modal_out = 'Are you sure you want to move ' + apt_block.patient_pot_apt__r.name + ' to the clipboard?';
  }
  
  public String getpatient_status_output() {
  	Integer arrived_num = 0;
  	Integer ready_num = 0;
  	Integer started_num = 0;
  	for(Clinical_Apt_Calendar__c ca : [select id,apt_status__c from Clinical_Apt_Calendar__c where apt_date__c = :current_date and
      clinical_room__r.center_information__c = :current_center.id and apt_status__c != null]) {
      if(ca.apt_status__c=='Patient Arrived')
        arrived_num++;
      else if(ca.apt_status__c=='Patient Ready')
        ready_num++;
      else if(ca.apt_status__c=='Appointment Started')
        started_num++;
  	}
  	return 'Arrived : ' + arrived_num + '&nbsp;&nbsp;Ready : ' + ready_num + '&nbsp;&nbsp;Started : ' + started_num;
  }
  
  public void display_appointment_change_form() {
  	apt_filter = 'All';
  	new_apt_name = 'Enter Appointment';
  	display_apt_change = true;
  }
  
  public void reset_apt_form() {
  	new_apt_name = 'Enter Appointment';
  	apt_filter = 'All'; 
  }
  
  public void hide_apt_form() {
  	display_apt_change = false;
  }
  
  public void select_appointment() {
  	new_apt_name = [select name from Clinical_Appointment__c where id = :apexpages.currentpage().getparameters().get('aptid')].name;
  	add_appointment_step();
  }
  
  public void add_appointment_step() {
  	//see if we have a match
  	Integer apt_matches = [select count() from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	if(apt_matches==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid appointment name'));	
  	} else {
  	  try {    	  	
  	  	Clinical_Appointment__c ca = [select id, appointment_description__c,lab_time__c,padding_time__c,name from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	  	
  	  	//grab the old procedure entries
  	    List<Patient_POT_Apt_Procedure__c> old_procedure_list = [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
	      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
	      where isactive__c = true and patient_pot_apt__c = :apt_block.patient_pot_apt__c order by sort_order__c];	    
        apt_time_makeup old_apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
  	  	  	    
  	  	//update existing pot apt record
  	  	Patient_POT_Apt__c existing_apt = [select appointment_description__c,clinical_appointment__c,isactive__c,lab_time__c,padding_time__c,name from Patient_Pot_Apt__c where id = :apt_block.patient_pot_apt__c];
        existing_apt.appointment_description__c = ca.appointment_description__c;
        existing_apt.clinical_appointment__c = ca.id;
        existing_apt.lab_time__c = ca.lab_time__c;
        existing_apt.padding_time__c = ca.padding_time__c;
        existing_apt.name = ca.name;
  	    update existing_apt;
  	    
  	    //mark old entries as inactive
  	    for(Patient_POT_Apt_Procedure__c pap : old_procedure_list) {
  	      pap.isactive__c = false;
  	    }
  	    update old_procedure_list;  	            
  	    
  	    //create procedure entries
  	    List<Patient_POT_Apt_Procedure__c> new_procedure_list = new List<Patient_POT_Apt_Procedure__c>();
  	    //work through all of the procedures
  	    for(Clinical_Apt_Procedure__c cap : [Select c.SystemModstamp, c.Sort_Order__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Procedure__r.Insurance_Fee__c,
  	      c.Clinical_Procedure__r.Cost__c, c.Clinical_Procedure__r.ADA_Code__c, c.Clinical_Procedure__r.Assistants_Needed__c, c.Clinical_Procedure__r.Doctor_Required__c, 
  	      c.Clinical_Procedure__r.Time_Required__c, c.Clinical_Procedure__r.Procedure_Description__c, c.Clinical_Procedure__c, c.Clinical_Appointment__c, c.clinical_procedure__r.name,
  	      c.clinical_procedure__r.allow_tooth_selection__c,c.clinical_procedure__r.default_teeth_selection__c
  	      From Clinical_Apt_Procedure__c c where c.Clinical_Appointment__c = :ca.id]) {
  	      Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cap.Clinical_Procedure__r.ADA_Code__c, Clinical_Procedure__c = cap.clinical_procedure__c,
  	        Cost__c = cap.Clinical_Procedure__r.Cost__c, Insurance_Fee__c = cap.Clinical_Procedure__r.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = existing_apt.id,
  	        Sort_Order__c = cap.sort_order__c, Time_Required__c = cap.Clinical_Procedure__r.Time_Required__c, name = cap.clinical_procedure__r.name,
  	        allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c, target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c);
  	      new_procedure_list.add(new_procedure);
  	    }  	  
  	    insert new_procedure_list;  
  	    apt_time_makeup new_apt_time = new apt_time_makeup(apt_block.patient_pot_apt__c);
  	    
  	    //figure out if we need to add or reduce time
  	    Integer old_time = old_apt_time.time_before + old_apt_time.time_dr + old_apt_time.time_after;
  	    Integer new_time = new_apt_time.time_before + new_apt_time.time_dr + new_apt_time.time_after;
  	    
  	    if((new_time-old_time)<0) {
  	      Integer num_reductions = (old_time - new_time) / 10;
          System.debug('Number of reductions : ' + num_reductions);
          Clinical_Procedure__c extension_proc = [Select c.center_information__r.name, c.Time_Required__c, c.Procedure_Filter__c, c.Procedure_Description__c, c.Name,
	  	    c.Insurance_Fee__c, c.Id, c.Default_Teeth_Selection__c, c.Cost__c, c.Allow_Tooth_Selection__c, c.ADA_Code__c 
	  	    From Clinical_Procedure__c c 
	  	    where name = 'Reduce 10 Minutes' and center_information__c = :current_center.id];
	  	  Integer current_sort_order;
	  	  try {
	  	  	current_sort_order = [select sort_order__c from patient_pot_apt_procedure__c where patient_pot_apt__c = :existing_apt.id and isactive__c = true order by sort_order__c desc limit 1].sort_order__c.intvalue() + 1;
	  	  } catch (Exception e) {current_sort_order = 1;}
	  	  List<Patient_pot_apt_procedure__c> reduction_list = new List<Patient_pot_apt_procedure__c>();
	      for(Integer loop_cnt = 1;loop_cnt<=num_reductions;loop_cnt++) {  	     	   
	  	    Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = extension_proc.ADA_Code__c, Clinical_Procedure__c = extension_proc.id,
	  	      Cost__c = extension_proc.Cost__c, Insurance_Fee__c = extension_proc.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = existing_apt.id,
	  	      Sort_Order__c = current_sort_order, Time_Required__c = extension_proc.Time_Required__c, name = extension_proc.name, allow_tooth_selection__c = extension_proc.allow_tooth_selection__c,
	  	      target_teeth__c = extension_proc.default_teeth_selection__c, procedure_description__c = extension_proc.Procedure_Description__c);
	  	    reduction_list.add(new_procedure);
	  	    current_sort_order++;
	      }
          insert reduction_list;   
  	    } else if((new_time-old_time)>0) {
  	      Integer num_additions = (new_time-old_time) / 10;
          System.debug('Number of additions : ' + num_additions);
          Clinical_Procedure__c extension_proc = [Select c.center_information__r.name, c.Time_Required__c, c.Procedure_Filter__c, c.Procedure_Description__c, c.Name,
	  	    c.Insurance_Fee__c, c.Id, c.Default_Teeth_Selection__c, c.Cost__c, c.Allow_Tooth_Selection__c, c.ADA_Code__c 
	  	    From Clinical_Procedure__c c 
	  	    where name = 'Add 10 Minutes' and center_information__c = :current_center.id];
	  	  Integer current_sort_order;
	  	  try {
	  	  	current_sort_order = [select sort_order__c from patient_pot_apt_procedure__c where patient_pot_apt__c = :existing_apt.id and isactive__c = true order by sort_order__c desc limit 1].sort_order__c.intvalue() + 1;
	  	  } catch (Exception e) {current_sort_order = 1;} 
	  	  List<Patient_pot_apt_procedure__c> reduction_list = new List<Patient_pot_apt_procedure__c>();
	      for(Integer loop_cnt = 1;loop_cnt<=num_additions;loop_cnt++) {  	     	   
	  	    Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = extension_proc.ADA_Code__c, Clinical_Procedure__c = extension_proc.id,
	  	      Cost__c = extension_proc.Cost__c, Insurance_Fee__c = extension_proc.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = existing_apt.id,
	  	      Sort_Order__c = current_sort_order, Time_Required__c = extension_proc.Time_Required__c, name = extension_proc.name, allow_tooth_selection__c = extension_proc.allow_tooth_selection__c,
	  	      target_teeth__c = extension_proc.default_teeth_selection__c, procedure_description__c = extension_proc.Procedure_Description__c);
	  	    reduction_list.add(new_procedure);
	  	    current_sort_order++;
	      }
          insert reduction_list; 	
  	    
  	    } //if it's 0,  then great - no more work to do
  	    
        apt_block = getapt_block(apt_block.id);  	
        //see if we need to create a new note instance
        Set<String> note_status = new Set<String>{'Completed','Patient Left','Patient Arrived','Patient Ready','Appointment Started','Incomplete'};
        if(note_status.contains(apt_block.apt_status__c)) {
          //new note instance needed
          Clinical_Note_Instance__c cn = new Clinical_note_Instance__c(Patient_POT_Apt__c = apt_block.patient_pot_apt__c, IsActive__c = true, Clinical_Apt_Calendar__c = apt_block.id, Account__c = apt_block.account__c);                      
          insert cn;
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
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Try In Notes Form')
	          create_try_in_notes_instance(cn);
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Prosth Exam Form')
	          create_prosth_exam_form_notes_instance(cn);            
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Final Notes Form')
	          create_final_notes_instance(cn);
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Redo Surgery Form')
	          create_redo_surgery_notes_instance(cn);
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='General Repair Notes')
	          create_repair_notes_instance(cn,'Unknown');
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Rework Repair Notes')
	          create_repair_notes_instance(cn,'Rework');
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Redeliver Notes')
	          create_repair_notes_instance(cn,'Redeliver');
	        if(apt_block.patient_pot_apt__r.clinical_appointment__r.clinical_notes_form__c=='Repair Work Notes')
	          create_repair_notes_instance(cn,'Repair');
	      }          	
        }
                    	   
  	    hide_apt_form();  	   
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error changing the appointment. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
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
  
  public List<Selectoption> getapt_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	for(Schema.PicklistEntry Value : Clinical_Appointment__c.appointment_filter__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  } 
  
  public Boolean getallow_doctor_adjustment() {
  	Set<String> allowed_status = new Set<String>{'Completed','Incomplete','Patient Arrived','Patient Ready','Appointment Started'};
  	if(allowed_status.contains(apt_block.apt_status__c))
  	  return true;
  	else 
  	  return false; 
  }
  
  public List<Selectoption> getall_doctor_list() {
  	Set<ID> user_ids = new Set<ID> {};
  	List<Selectoption> doc_list = new List<Selectoption> {};
  	try {
  	  if(apt_block.doctor__c!=null) {
  	    doc_list.add(new selectoption(apt_block.doctor__c,apt_block.doctor__r.name));
  	    user_ids.add(apt_block.doctor__c);
  	  }
  	} catch (Exception e) {}  	
  	for(User doctor : [select u.id,u.name from User u where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name and isactive = true  
  	  and id not in :user_ids order by isactive desc, name]) {
  	  doc_list.add(new Selectoption(doctor.id,doctor.name));
  	  user_ids.add(doctor.id);
  	}  	
  	for(User_Center_Assignment__c doctor : [select id,user__c,user__r.name from user_center_assignment__c where center_information__r.name = :current_center.name  and user__r.isactive = true
  	  and user__r.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and user__c not in :user_ids]) {
  	  doc_list.add(new Selectoption(doctor.user__c,doctor.user__r.name));	
  	}
  	return doc_list;
  }
}