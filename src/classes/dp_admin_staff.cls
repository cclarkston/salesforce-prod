public with sharing class dp_admin_staff {
  public String quick_search_field {get;set;} 
  public Boolean display_qsearch {get; set;}
  public Boolean display_add_button {get; set;} 
  public Boolean display_active_nav {get; set;}
  public Center_Information__c current_center {get; set;}
  public Boolean display_corp_admin {get; set;}
  public String selected_view {get; set;}
  public User selected_staff_member {get; set;}
  public Navigation_Page__c current_page {get; set;}
  public String active_filter {get; set;}
  public Medical_License__c new_license {get; set;}
  public Boolean display_license_form {get; set;}
  public Boolean display_education_form {get; set;}
  public Boolean display_info_form {get; set;}
  public String body_header {get; set;}
  public ID current_edit {get; set;}
  public Boolean modal_display {get; set;}
  public String modal_type {get; set;}
  public String modal_out {get; set;}
  public Education__c new_education {get; set;}
  public String activation_id {get; set;}  
  public String active_type {get; set;}
  
  public Boolean display_mon_form {get; set;}
  public Boolean display_tue_form {get; set;}
  public Boolean display_wed_form {get; set;}
  public Boolean display_thu_form {get; set;}
  public Boolean display_fri_form {get; set;}
  public User_Schedule__c edit_hours {get; set;}
  public User_Schedule__c mon_hours {get; set;}
  public User_Schedule__c tue_hours {get; set;}
  public User_Schedule__c wed_hours {get; set;}
  public User_Schedule__c thu_hours {get; set;}
  public User_Schedule__c fri_hours {get; set;}
  public String appointment_filter {get;set;} 
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];  
  
  public class bendException extends Exception {} 
    	  
  public dp_admin_staff() {
  	active_type = '';
  	display_license_form = false;
  	display_education_form = false;
  	display_info_form = false;
  	modal_display = false;
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
        User u = [select clinic_calendar__c from user where id =:userinfo.getUserId()];         
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,sales_region__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,sales_region__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,sales_region__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   	  	  	  	
  	quick_search_field = '';
  	display_qsearch = true;
  	//high level add button does nothing here - new staff and clinicians are created via user accounts (IT process)
  	display_add_button = false;
  	//see if it's a corporate admin
  	Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  	selected_view = 'staff_display';
  	current_page = [Select Id, Name, Nav_Color__c, Page_URL__c From Navigation_Page__c where name = 'Staff'];
  	active_filter = 'Active';
  	display_active_nav = true;
  	body_header = current_center.name + ' Staff';
  }
  
  public List<Navigation_Page__c> getgear_menu() {
  	return [Select n.Sort_Order__c, n.Page_URL__c, n.Name, n.Image_Name__c, n.Id , n.image_name_hover__c,n.hyperlink_target__c From Navigation_Page__c n where navigation_header__r.name = 'Gear' order by sort_order__c];
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
  
  public List<dp_navigation_header.menu_item> getnavigation_menu() {
  	List<dp_navigation_header.menu_item> nav_menu = new List<dp_navigation_header.menu_item>();
  	for(Navigation_Header__c head : [Select n.Sub_System__c, n.Sort_Order__c, n.Name,  n.Id, (Select Id, Name, Nav_Color__c, Page_URL__c, css_class__c From Navigation_Pages__r order by sort_order__c) From Navigation_Header__c n where sub_system__c = 'Setup' order by sort_order__c]) {
  	  nav_menu.add(new dp_navigation_header.menu_item(head.name,'Header',null,head.id,null));
  	  for(Navigation_Page__c page : head.navigation_pages__r) {
  	  	nav_menu.add(new dp_navigation_header.menu_item(page.name,'Page',page.nav_color__c,page.id,page.css_class__c));
  	  }
  	  nav_menu.add(new dp_navigation_header.menu_item(null,'Spacer',null,null,null));
  	}
  	//remove the last spacer line from the menu - it's not needed
  	nav_menu.remove(nav_menu.size()-1);
  	return nav_menu;
  }  
  
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c,sales_region__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  quick_search_field = '';
  	  display_staff_info();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public void change_category_filter() {
  	try {
  	  appointment_filter = apexpages.currentpage().getparameters().get('cfilter');
  	  if(appointment_filter==null)
  	    throw new bendException('No category was detected');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change the category filter.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void change_active_view() {
  	try {
  	  active_filter = apexpages.currentpage().getparameters().get('afilter');
  	  if(active_filter==null)
  	    throw new bendException('No active value was detected');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change the active filter.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_staff_info() {
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'staff_display';
  	display_active_nav = true;
  	body_header = current_center.name + ' Staff';
  }
  
  public void display_general_info() {
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'info_display';
  	display_active_nav = true;
  	try {
  	  selected_staff_member= [select id,name,ssn__c,dob__c,national_provider_identifier__c,doctor_suffix__c from user where id = :apexpages.currentpage().getparameters().get('staffid')];
  	  body_header = selected_staff_member.name + ' - Info';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the info for this staff member.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  	
  }
  
  public void display_appointment_info() {
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'appointment_display';
  	display_active_nav = false;
  	appointment_filter = 'All';
  	try {
  	  selected_staff_member= [select id,name from user where id = :apexpages.currentpage().getparameters().get('staffid')];
  	  body_header = selected_staff_member.name + ' - Appointment Authorization';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the appointment authorizations for this staff member.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_calendar() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'calendar_display';
  	display_active_nav = false;
  	try {
  	  selected_staff_member= [select id,name from user where id = :apexpages.currentpage().getparameters().get('staffid')];
  	  body_header = selected_staff_member.name + ' - Hours';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the appointment authorizations for this staff member.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void copy_hours() {
  	//grab the hours record for the day we're passed
  	Integer dow = Integer.valueof(apexpages.currentpage().getparameters().get('sdow'));
  	User_Schedule__c copy_sched = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c,u.center_information__c From User_Schedule__c u where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	List<User_Schedule__c> update_scheds = new List<User_Schedule__c>();
  	List<User_Schedule__c> insert_scheds = new List<User_Schedule__c>();
  	hide_hours_forms();  	
  	//for loop through all dow
  	for(Integer cdow=1;cdow<6;cdow++) {
      //ignore if we're currently working on the day we're cloning		
  	  if(cdow!=dow) {
  	    //check for an hour record for this day
  	    Integer rcount = [select count() from User_Schedule__c where dow__c = :cdow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];  	    
  	    //if none,  create a new record using our copied values
  	    if(rcount==0) {
  	      User_Schedule__c new_sched = new User_Schedule__c(dow__c = cdow, user__c = selected_staff_member.id, Start_time__c = copy_sched.start_time__c, End_Time__c = copy_sched.end_time__c,
  	        Lunch_Start__c = copy_sched.lunch_start__c, lunch_end__c = copy_sched.lunch_end__c, center_information__c = copy_sched.center_information__c);
  	      insert_scheds.add(new_sched);
  	    } else {
  	      //else grab the record and update the fields
  	      User_Schedule__c usched = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = :cdow and user__c = :selected_staff_member.id];
  	      usched.start_time__c = copy_sched.start_time__c;
  	      usched.end_time__c = copy_sched.end_time__c;
  	      usched.lunch_start__c = copy_sched.lunch_start__c;
  	      usched.lunch_end__c = copy_sched.lunch_end__c;
  	      update_scheds.add(usched);
  	    }
  	  }
  	}
  	//update the list
  	if(update_scheds.size()>0)
  	  update update_scheds;
  	if(insert_scheds.size()>0)
  	  insert insert_scheds;
  	getuser_hours();
  }
  
  public void display_hours() {
  	hide_hours_forms();
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'hours_display';
  	display_active_nav = false;
  	try {
  	  Integer dow = Integer.valueof(apexpages.currentpage().getparameters().get('sdow'));
  	  if(dow==1)
  	    display_mon_form = true;
  	  if(dow==2)
  	    display_tue_form = true;
  	  if(dow==3)
  	    display_wed_form = true;
  	  if(dow==4)
  	    display_thu_form = true;
  	  if(dow==5)
  	    display_fri_form = true;
  	  Integer hour = Integer.valueof(apexpages.currentpage().getparameters().get('shour'));
  	  Integer minute = Integer.valueof(apexpages.currentpage().getparameters().get('sminute'));
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
  	  Integer ucount = [select count() from user_schedule__c where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	  if(ucount==0) {
  	  	//create a record and set start time
  	  	edit_hours = new User_Schedule__c(dow__c = dow, user__c = selected_staff_member.id, start_time__c = tlabel, center_information__c = current_center.id);
  	  } else {
  	    //pull our record and adjust the start time
  	    edit_hours = [Select u.dow__c, u.id, u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	    edit_hours.start_time__c = tlabel;
  	  }
  	  body_header = selected_staff_member.name + ' - Hours';
  	  getuser_hours();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the appointment authorizations for this staff member.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void reset_hours_form() {
  	Integer dow = edit_hours.dow__c.intValue();
  	Integer ucount = [select count() from user_schedule__c where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	if(ucount==0)
  	  //create a record and set start time
  	  edit_hours = new User_Schedule__c(dow__c = dow, user__c = selected_staff_member.id, center_information__c = current_center.id);
  	else
  	  //pull our record and adjust the start time
  	  edit_hours = [Select u.dow__c,u.id, u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	getuser_hours();
  }
  
  public void edit_hours_info() {
  	hide_hours_forms();
  	Integer dow = Integer.valueof(apexpages.currentpage().getparameters().get('sdow'));
  	Integer ucount = [select count() from user_schedule__c where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	if(ucount==0) {
  	  //create a record 
  	  edit_hours = new User_Schedule__c(dow__c = dow, user__c = selected_staff_member.id, center_information__c = current_center.id);
  	} else 
  	  //pull our record 
  	  edit_hours = [Select u.dow__c, u.id, u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = :dow and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
	if(dow==1)
  	  display_mon_form = true;
  	if(dow==2)
  	  display_tue_form = true;
  	if(dow==3)
  	  display_wed_form = true;
  	if(dow==4)
  	  display_thu_form = true;
  	if(dow==5)
  	  display_fri_form = true;
  	reset_hours_form();
  	getuser_hours();
  }
  
  public void getuser_hours() {
  	try {
  	  mon_hours = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = 1 and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	} catch (Exception e) {
  	  mon_hours = new User_Schedule__c(user__c = selected_staff_member.id,dow__c = 1, center_information__c = current_center.id);
  	}
  	try {
  	  tue_hours = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = 2 and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	} catch (Exception e) {
  	  tue_hours = new User_Schedule__c(user__c = selected_staff_member.id,dow__c = 2, center_information__c = current_center.id);
  	}
  	try {
  	  wed_hours = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = 3 and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	} catch (Exception e) {
  	  wed_hours = new User_Schedule__c(user__c = selected_staff_member.id,dow__c = 3, center_information__c = current_center.id);
  	}
  	try {
  	  thu_hours = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = 4 and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	} catch (Exception e) {
  	  thu_hours = new User_Schedule__c(user__c = selected_staff_member.id,dow__c = 4, center_information__c = current_center.id);
  	}
  	try {
  	  fri_hours = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where dow__c = 5 and user__c = :selected_staff_member.id and center_information__c = :current_center.id];
  	} catch (Exception e) {
  	  fri_hours = new User_Schedule__c(user__c = selected_staff_member.id,dow__c = 5, center_information__c = current_center.id);
  	}
  }
  
  public void hide_hours_forms() {
  	display_mon_form = false;
  	display_tue_form = false;
  	display_wed_form = false;
  	display_thu_form = false;
  	display_fri_form = false;
  }
    
  public PageReference navigate_to() {
  	//System.debug('Navigate to start');
  	//System.debug('Navid'  + apexpages.currentpage().getparameters().get('navid'));
  	PageReference pr;
  	if(apexpages.currentpage().getparameters().get('navid')!=null) {
  	  try {
  	  	Navigation_Page__c np = [select page_url__c from Navigation_Page__c where id = :apexpages.currentpage().getparameters().get('navid')];
  	  	System.debug('URL : ' + np.page_url__c);
  	  	if(np.page_url__c!=null) {
  	      pr = new PageReference(np.page_url__c);
  	      pr.getParameters().put('ctrid',current_center.id);     
  	      pr.setredirect(true);  	      
  	      return pr;
  	  	}
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change pages.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  	return null;
  	  }
  	}
  	return pr;
  }    
  
  public List<User> getdoctor_list() {
  	//modified by cm on 8/9/2017 - doctor list should now use user_center_assignment to build a list of eligible folks
  	Set<ID> possible_users = new Set<ID>();
  	for(User_Center_Assignment__c uca : [select id,user__c,center_information__c from User_Center_Assignment__c where center_information__r.market__c = :current_center.market__c]) {
  	  possible_users.add(uca.user__c);	
  	}  	  	
  	List<User> doctors;
  	try {  	  
  	  //String query_filter = ' and u.clinic_calendar__c = \'' + current_center.name + '\' ';
  	  String query_filter = ' and u.id in :possible_users ';
  	  if(active_filter=='Active')
  	    query_filter += ' and u.isactive = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and u.isactive = false ';
  	  if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and u.name like \'%' + quick_search_field + '%\' ';
  	  }
  	  doctors = database.query('select u.id,u.name from User u where u.Profile.name in (\'Clinical Doctor\',\'SF - Clinical Doctor\') ' + query_filter + ' order by isactive desc, name');  	  	  	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up doctors for this location.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  	return doctors;  	 
  }
  
  public List<user> getassistant_list() {
  	List<User> assistants;
  	try {
  	  String query_filter = ' and u.clinic_calendar__c = \'' + current_center.name + '\' ';  	  
  	  if(active_filter=='Active')
  	    query_filter += ' and u.isactive = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and u.isactive = false ';
  	  if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and u.name like \'%' + quick_search_field + '%\' ';
  	  }
  	  assistants = database.query('select u.id,u.name from User u where u.Profile.name in (\'Clinical Assistant\',\'SF - Clinical Assistant\') ' + query_filter + ' order by isactive desc, name');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up assistants for this location.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  	return assistants;
  }
  
  public list<Clinical_DR_Authorized_Apt__c> getall_allowed_apts() {
  	list<Clinical_DR_Authorized_Apt__c> alist = [Select Id, c.Clinical_Appointment__r.name, c.clinical_appointment__c From Clinical_DR_Authorized_Apt__c c where doctor__c = :selected_staff_member.id];
  	return alist;
  }
  
  public List<Clinical_DR_Authorized_Apt__c> getallowed_apts() {
    List<Clinical_DR_Authorized_Apt__c> apts;
    try {
      String query_filter = ' where doctor__c = \'' + selected_staff_member.id + '\'';
      //To-DO :add type filter here when clarified
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and c.clinical_appointment__r.name like \'%' + quick_search_field + '%\' ';
  	  }          	
  	  if(appointment_filter!='All')
  	    query_filter += ' and clinical_appointment__r.appointment_filter__c = \'' + appointment_filter + '\' ';
      apts = database.query('Select Id, c.Clinical_Appointment__r.name, c.clinical_appointment__c From Clinical_DR_Authorized_Apt__c c ' + query_filter + ' and clinical_appointment__r.center_information__c = \'' + current_center.id + '\' order by c.clinical_appointment__r.name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up authorized appointments.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return apts;	
  }
  
  public list<Clinical_Appointment__c> getdisallowed_apts() {  	  	
  	List<Clinical_Appointment__c> apts;
  	try {
  	  String query_filter = ' where center_information__c = \'' + current_center.id + '\' and isactive__c = true and id not in (';
  	  for(Clinical_DR_Authorized_Apt__c ca : getall_allowed_apts()) {
  	    query_filter += '\'' + ca.clinical_appointment__c + '\',';
  	  }  
  	  query_filter += '\'\') ';
  	  //TO-DO: add type filter here when clarified
  	  if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and name like \'%' + quick_search_field + '%\' ';
  	  }
  	  if(appointment_filter!='All')
  	    query_filter += ' and appointment_filter__c = \'' + appointment_filter + '\' ';
  	  apts = database.query('select id,name from Clinical_Appointment__c ' + query_filter + ' order by name');
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up non-authorized appointments.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  	return apts;
  }
   
  public Integer getall_count() {
  	Integer record_count = 0;
  	if(selected_view=='staff_display')
  	  record_count = [select count() from User where profile.name in ('Clinical Assistant','Clinical Doctor','SF - Clinical Doctor','SF - Clinical Assistant') and clinic_calendar__c = :current_center.name];
  	if(selected_view=='info_display') {
  	  record_count += [select count() from Medical_License__c where doctor__c = :selected_staff_member.id];
  	  record_count += [select count() from Education__c where user__c = :selected_staff_member.id];
  	}
  	return record_count;
  }
  
  public Integer getactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='staff_display')
  	  record_count = [select count() from User where profile.name in ('Clinical Assistant','Clinical Doctor','SF - Clinical Doctor','SF - Clinical Assistant') and clinic_calendar__c = :current_center.name and isactive = true];
  	if(selected_view=='info_display') {
  	  record_count += [select count() from Medical_License__c where doctor__c = :selected_staff_member.id and isactive__c = true];
  	  record_count += [select count() from Education__c where user__c = :selected_staff_member.id and isactive__c = true];
  	}
  	return record_count;
  }
  
  public Integer getinactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='staff_display')
  	  record_count = [select count() from User where profile.name in ('Clinical Assistant','Clinical Doctor','SF - Clinical Doctor','SF - Clinical Assistant') and clinic_calendar__c = :current_center.name and isactive = false];
  	if(selected_view=='info_display') {
  	  record_count += [select count() from Medical_License__c where doctor__c = :selected_staff_member.id and isactive__c = false];
  	  record_count += [select count() from Education__c where user__c = :selected_staff_member.id and isactive__c = false];
  	}
  	return record_count;
  }
  
  public Integer getlicense_size() {
  	List<Medical_License__c> mlist = getlicense_list();
  	return mlist.size();
  }
  
  public List<Medical_License__c> getlicense_list() {
  	List<Medical_license__c> license_list;  	
  	try {
  	  String query_filter = ' where doctor__c = \'' + selected_staff_member.id + '\' ';
  	  if(active_filter=='Active')
  	    query_filter += ' and isactive__c = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and isactive__c = false ';
  	  if((quick_search_field==null?'':quick_search_field) != '') 
  	  	query_filter += ' and (license_number__c like \'%' + quick_search_field + '%\' or license_type__c like \'%' + quick_search_field + '%\') ';
  	  //System.debug('Running Query - ' + 'Select m.isactive__c, m.State_Licensed_In__c, m.License_Type__c, m.License_Number__c, m.License_Issue_Date__c, m.License_Expiration_Date__c From Medical_License__c m ' + query_filter + ' order by isactive__c desc, license_number__c');
  	  license_list = database.query('Select m.id, m.isactive__c, m.State_Licensed_In__c, m.License_Type__c, m.License_Number__c, m.License_Issue_Date__c, m.License_Expiration_Date__c From Medical_License__c m ' + query_filter + ' order by isactive__c desc, license_number__c');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up medical license for this user. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return license_list;
  }
  
  public Integer geteducation_size() {
  	List<Education__c> elist = geteducation_list();
  	return elist.size();
  }
  
  public List<Education__c> geteducation_list() {
  	List<Education__c> ed_list;
  	try {
   	  String query_filter = ' where e.user__c = \'' + selected_staff_member.id + '\' ';
  	  if(active_filter=='Active')
  	    query_filter += ' and isactive__c = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and isactive__c = false ';
  	  if((quick_search_field==null?'':quick_search_field) != '') 
  	  	query_filter += ' and school__c like \'%' + quick_search_field + '%\' ';
//  	  System.debug('Running Query - ' + );
  	  ed_list = database.query('Select e.degree__c, e.School__c, e.Id, e.Graduation_Year__c, e.isactive__c From Education__c e ' + query_filter + ' order by isactive__c desc, school__c');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up education info for this user. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return ed_list;
  }
  
  public void new_education_form() {
  	display_education_form = true;
  	current_edit = null;
  	new_education = new Education__c(School__c = 'Enter School',isactive__c = true, user__c = selected_staff_member.id);
  }
  
  public void new_license_form() {
  	display_license_form = true;
  	current_edit = null;
  	new_license = new Medical_License__c(license_number__c = 'Enter Number', license_type__c = 'Select Type', state_licensed_in__c = 'State', isactive__c = true, doctor__c = selected_staff_member.id);
  }
  
  public void hide_education_form() {
  	display_education_form = false;
  	current_edit = null;
  }
  
  public void hide_license_form() {
  	display_license_form = false;
  	current_edit = null;
  }
  
  public void reset_license_form() {
  	new_license = new Medical_License__c(license_number__c = 'Enter Number', license_type__c = 'Select Type', state_licensed_in__c = 'State', isactive__c = true, doctor__c = selected_staff_member.id);
  }
  
  public void reset_education_form() {
  	new_education = new Education__c(School__c = 'Enter School',isactive__c = true, user__c = selected_staff_member.id, degree__c = null);
  }
  
  public void edit_medical_license() {
  	try {
  	  display_license_form = false;
  	  new_license = [select m.id, m.isactive__c, m.State_Licensed_In__c, m.License_Type__c, m.License_Number__c, m.License_Issue_Date__c, m.License_Expiration_Date__c From Medical_License__c m where id= :current_edit];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the medical license. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void edit_education() {
  	try {
  	  display_education_form = false;
  	  new_education = [select id,school__c,isactive__c,graduation_year__c,degree__c from Education__c where id = :current_edit];	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the medical license. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void edit_general_info() {
    display_info_form = true;
  }
  
  public void hide_info_form() {
  	display_info_form = false;
  }
  
  public void reset_info_form() {
  	selected_staff_member = [select id,name,ssn__c,dob__c,national_provider_identifier__c,doctor_suffix__c from user where id = :selected_staff_member.id];
  }
  
  public void save_general_info() {
  	try {
      update selected_staff_member;
      display_info_form = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving info changes. Please contact IT for help'));
      ApexPages.addMessages(e);
    }
  }
  
  public void save_hours_form() {
  	Integer num_issues = 0;
  	Integer dow = edit_hours.dow__c.intValue();
  	//check to see if all times were nulled out - if so delete the record (if it exists) and move on
  	if(edit_hours.start_time__c==null && edit_hours.end_time__c==null && edit_hours.lunch_start__c==null && edit_hours.lunch_end__c==null) {
  	  try {
  	  	if(edit_hours.id != null)
  	  	  delete edit_hours;
  	    hide_hours_forms();
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the hours for this day. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  	else {
  	  //check for record issues
  	  if((edit_hours.lunch_start__c==null && edit_hours.lunch_end__c!=null) || (edit_hours.lunch_end__c==null && edit_hours.lunch_start__c!=null)) {
  	  	num_issues++;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide a start and end time for lunch or leave both values blank'));
  	  }
  	  if(edit_hours.lunch_start__c!=null && edit_hours.lunch_end__c!=null) {
  	  	//make sure lunch start is before lunch end
  	  	Integer shour = Integer.valueof(edit_hours.lunch_start__c.left(2).replace(':',''));
  	  	if(edit_hours.lunch_start__c.right(2)=='PM' && shour!=12)
  	  	  shour+=12;
  	  	Integer sminute = Integer.valueof(edit_hours.lunch_start__c.right(5).replace(' AM','').replace(' PM',''));
  	  	Integer ehour = Integer.valueof(edit_hours.lunch_end__c.left(2).replace(':',''));
  	  	if(edit_hours.lunch_end__c.right(2)=='PM' && ehour!=12)
  	  	  ehour+=12;
  	  	Integer eminute = Integer.valueof(edit_hours.lunch_end__c.right(5).replace(' AM','').replace(' PM',''));
  	  	Integer stime = (shour*60) + sminute;
  	  	Integer etime = (ehour*60) + eminute;
  	  	if(stime > etime) {
  	  	  num_issues++;
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Lunch start time must come before lunch end time'));
  	  	}
  	  }
  	  if(edit_hours.start_time__c==null) {
  	  	num_issues++;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a start time'));
  	  }
  	  if(edit_hours.end_time__c==null) {
  	  	num_issues++;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an end time'));
  	  }
  	  if(edit_hours.start_time__c!=null && edit_hours.end_time__c!=null) {
  	  	//make sure lunch start is before lunch end
  	  	Integer shour = Integer.valueof(edit_hours.start_time__c.left(2).replace(':',''));
  	  	if(edit_hours.start_time__c.right(2)=='PM' && shour!=12)
  	  	  shour+=12;
  	  	Integer sminute = Integer.valueof(edit_hours.start_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  	Integer ehour = Integer.valueof(edit_hours.end_time__c.left(2).replace(':',''));
  	  	if(edit_hours.end_time__c.right(2)=='PM' && ehour!=12)
  	  	  ehour+=12;
  	  	Integer eminute = Integer.valueof(edit_hours.end_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  	Integer stime = (shour*60) + sminute;
  	  	Integer etime = (ehour*60) + eminute;
  	  	if(stime > etime) {
  	  	  num_issues++;
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start time must come before End time'));
  	  	}
  	  }
  	  if(num_issues==0) {
  	  	try {
  	  	  if(edit_hours.id != null)
  	  	    update edit_hours;
  	  	  else
  	  	    insert edit_hours;
  	  	  hide_hours_forms();
  	  	} catch (Exception e) {
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the hours. Please contact IT for help'));
          ApexPages.addMessages(e);
  	  	}
  	  }
  	}  
  	getuser_hours();	  	
  }
  
  
  public void save_new_education() {
  	Integer num_issues = 0;
  	if(new_education.school__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for School'));  	  
  	} else if(new_education.school__c=='Enter School') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for School'));
  	}
  	if(new_education.Graduation_Year__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for graduation year'));
  	} else if(new_education.graduation_year__c==0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for graduation year'));
  	}  	
  	if(num_issues == 0) {
  	  try {
  	  	if(current_edit==null)
  	      insert new_education;
  	    else
  	      update new_education;
  	    display_education_form = false;
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the education info for this user. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void save_new_license() {
  	Integer num_issues = 0;
  	if(new_license.license_number__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license number'));
  	} else if(new_license.license_number__c=='Enter Number') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license number'));
  	}
  	if(new_license.license_type__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license type'));
  	} else if(new_license.license_type__c=='Select Type') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license type'));
  	}
  	if(new_license.state_licensed_in__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license state'));
  	} else if(new_license.state_licensed_in__c=='State') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license state'));
  	}
  	if(new_license.license_issue_date__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license issue date'));
  	}  	
  	if(new_license.license_expiration_date__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for license expiration date'));
  	}
  	if(new_license.license_issue_date__c!=null && new_license.license_expiration_date__c!=null) {
  	  if(new_license.license_issue_date__c > new_license.license_expiration_date__c) {
  	    num_issues++;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'License Issue Date must be before the License Expiration Date'));
  	  }
  	}  	
  	if(num_issues == 0) {
  	  try {
  	  	if(current_edit==null)
  	      insert new_license;
  	    else
  	      update new_license;
  	    display_license_form = false;
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the medical license for this user. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void confim_activation_license() {
  	modal_display = true;
  	active_type = 'license';
  	Medical_License__c ml = [select id,isactive__c,license_number__c,doctor__r.name from Medical_license__c where id=:activation_id];
  	modal_out = 'You are about to ' + (ml.isactive__c==true?'deactivate':'activate') + ' license # ' + ml.license_number__c + ' for ' + ml.doctor__r.name;
  }
  
  public void confirm_activation_education() {
  	modal_display = true;
  	active_type = 'education';
  	Education__c e = [Select e.degree__c,e.School__c, e.Id, e.Graduation_Year__c,e.isactive__c,user__r.name From Education__c e where id=:activation_id];
  	modal_out = 'You are about to ' + (e.isactive__c==true?'deactivate':'activate') + ' ' + e.school__c + ' - ' + e.graduation_year__c + ' for ' + e.user__r.name;
  }
  
  public void update_activation_license() {
  	try {
  	  modal_display = false;  	  
  	  Medical_License__c ml = [select id,isactive__c,license_number__c,doctor__r.name from Medical_license__c where id=:activation_id];
  	  if(ml.isactive__c==true)
  	    ml.isactive__c = false;
  	  else
  	    ml.isactive__c = true;
  	  update ml;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this license. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void update_activation_education() {
  	try {
      modal_display = false;  	  
  	  Education__c e = [select id,isactive__c from Education__c where id=:activation_id];
  	  if(e.isactive__c==true)
  	    e.isactive__c = false;
  	  else
  	    e.isactive__c = true;
  	  update e;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this education record. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void block_apt() {
  	try {
  	  Clinical_DR_Authorized_Apt__c cda = [select id from Clinical_DR_Authorized_Apt__c where id = :activation_id];
  	  delete cda;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing access to the appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void block_all_apts() {
  	//grab the list of all apts in the authorized section
  	try {
  	  List<Clinical_DR_Authorized_Apt__c> cda_list = getallowed_apts();
  	  delete cda_list;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error authorizing access to the appointments. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void authorize_apt() {
  	try {
  	  Clinical_DR_Authorized_Apt__c cda = new Clinical_DR_Authorized_Apt__c(Clinical_Appointment__c = activation_id, Doctor__c = selected_staff_member.id);
  	  insert cda;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error authorizing access to the appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void authorize_all_apts() {
  	//grab the list of all apts in the non-authorized section
  	try {
  	  List<Clinical_DR_Authorized_apt__c> cda_list = new List<Clinical_DR_Authorized_apt__c>();
  	  for(Clinical_Appointment__c ca : getdisallowed_apts()) {
  	    Clinical_DR_Authorized_Apt__c cda = new Clinical_DR_Authorized_Apt__c(Clinical_Appointment__c = ca.id, Doctor__c = selected_staff_member.id);
  	    cda_list.add(cda);
  	  }
  	  insert cda_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error authorizing access to all appointments. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void close_modal() {
  	modal_display = false;  	
  }
  
  public class calendar_cell {
  	public String cell_css {get;set;}
  	public String cell_text {get;set;}
  	public Boolean image_display {get;set;}
  	public String image_name {get;set;}
  	public Integer dow {get;set;}
  	public Integer hour {get; set;}
  	public Integer minute {get; set;}
  	
  	public calendar_cell(String ccss, String ctext, Boolean idisplay, String iname, Integer d, Integer h, Integer m) {
  	  this.cell_css = ccss;
  	  this.cell_text = ctext;
  	  this.image_display = idisplay;
  	  this.image_name = iname;
  	  this.dow = d;
  	  this.hour = h;
  	  this.minute = m;
  	}
  }
  
  public class calendar_column {
  	public Calendar_Cell[] all_cells {get;set;}
  	
  	public calendar_column() {
      all_cells = new Calendar_Cell[] {};
  	}
  
  }
  
  public List<Calendar_cell> getlabel_column() {
  	List<calendar_cell> label_col = new List<Calendar_Cell> ();
  	Integer hour;
  	Integer minute;
  	label_col.add(new calendar_cell('col_header','',false,null,0,0,0));
  	for(hour=7;hour<20;hour++) {
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
  	  	label_col.add(new calendar_cell('time_label',tlabel,false,null,0,0,0));
  	  	minute += 10;
  	  }
  	}
  	return label_col;
  }
  
  public List<Calendar_cell> getblank_column(String col_header,Integer day_of_week) {
  	List<calendar_cell> label_col = new List<Calendar_Cell> ();
  	Integer hour;
  	Integer minute;
  	label_col.add(new calendar_cell('col_header',col_header,false,null,0,0,0));
  	for(hour=7;hour<20;hour++) {
  	  minute = 0;
  	  while(minute<60) {  	  	  	   	  	  	  	
  	  	label_col.add(new calendar_cell('open_slot c-pointer','',false,null,day_of_week,hour,minute));
  	  	minute += 10;
  	  }
  	}
  	return label_col;
  }
  
  public Integer getall_apt_count() {
  	Integer record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id];  	
  	return record_count;
  }
  
  public Integer getprosth_count() {
	Integer record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id and appointment_filter__c = 'Prosth'];  	
  	return record_count;
  }
  
  public Integer getsurgical_count() {
	Integer record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id and appointment_filter__c = 'Surgical'];  	
  	return record_count;
  }
  
  public Integer getmisc_count() {
	Integer record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id and appointment_filter__c = 'Misc'];  	
  	return record_count;
  }
  
  public calendar_column[] getcalendar_info() {
  	List<calendar_column> week_column = new List<calendar_column>();
  	Map<Integer,String> dow_name = new Map<Integer,String>();
  	dow_name.put(1,'Mon');
  	dow_name.put(2,'Tue');
  	dow_name.put(3,'Wed');
  	dow_name.put(4,'Thu');
  	dow_name.put(5,'Fri');
  	dow_name.put(6,'Sat');
  	dow_name.put(7,'Sun');
  	//build the label column
  	Calendar_Column cal_column = new calendar_column();
    cal_column.all_cells.addAll(getLabel_column());
    week_column.add(cal_column);	
  	//work through M-F
  	for(Integer dow=1;dow<6;dow++) {
  	  cal_column = new calendar_column();  	
      Boolean lunch_started = false;  
  	  //check to see if we have a user_schedule record for this staff member and day
      Integer sched_count = [Select count() From User_Schedule__c u where user__c = :selected_staff_member.id and dow__c = :dow and center_information__c = :current_center.id];  	    	    	  
  	  //if not - build a clean column
  	  if(sched_count==0) {
  	  	cal_column.all_cells.addAll(getblank_column(dow_name.get(dow),dow));
        week_column.add(cal_column);	
  	  } else { 
  	    User_Schedule__c sched = [Select u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c From User_Schedule__c u where user__c = :selected_staff_member.id and dow__c = :dow and center_information__c = :current_center.id];  	  
	  	  if(sched.start_time__c==null || sched.end_time__c==null) {
	  	    //make sure we don't have cleaned out time values for the record - if we do blank column it  	    
	  	  	cal_column.all_cells.addAll(getblank_column(dow_name.get(dow),dow));
	        week_column.add(cal_column);	
	  	  }
	  	  else {
	  	  	cal_column.all_cells.add(new calendar_cell('col_header',dow_name.get(dow),false,null,0,0,0));
	  	  	Integer shour = (sched.start_hour_int__c==null?0:sched.start_hour_int__c.intvalue());
	  	  	Integer sminute = (sched.start_minute_int__c==null?0:sched.start_minute_int__c.intvalue());
	  	  	Integer stime = (shour * 60 + sminute);
	  	  	Integer ehour = (sched.end_hour_int__c==null?0:sched.end_hour_int__c.intvalue());
	  	  	Integer eminute = (sched.end_minute_int__c==null?0:sched.end_minute_int__c.intvalue());
	  	  	Integer etime = (ehour * 60 + eminute);
	  	  	
	  	  	Integer lshour = (sched.lunch_start_hour_int__c==null?0:sched.lunch_start_hour_int__c.intvalue());
	  	  	Integer lsminute = (sched.lunch_start_minute_int__c==null?0:sched.lunch_start_minute_int__c.intvalue());
	  	  	Integer lstime = (lshour * 60 + lsminute);
	  	  	Integer lehour = (sched.lunch_end_hour_int__c==null?0:sched.lunch_end_hour_int__c.intvalue());
	  	  	Integer leminute = (sched.lunch_end_minute_int__c==null?0:sched.lunch_end_minute_int__c.intvalue());
	  	  	Integer letime = (lehour * 60 + leminute);
	  	  	
	  	    //otherwise - build a column that displays the hour info
	  	    Integer hour;
	  	    Integer minute;
	  	    for(hour=7;hour<20;hour++) {
	  	      minute = 0;
	  	      while(minute<60) {
	  	      	System.debug('Hour : ' + hour + ' Minute : ' + minute + ' DOW : ' + dow);
	  	      	Integer ctime = (hour * 60) + minute;
	  	      	
	  	      	//check to see if block matches lunch start
	  	      	if((sched.lunch_start_hour_int__c==null?0:sched.lunch_start_hour_int__c) == hour && (sched.lunch_start_minute_int__c==null?0:sched.lunch_start_minute_int__c) == minute ) {
	  	      	  cal_column.all_cells.add(new calendar_cell('lunch_head c-pointer',sched.lunch_start__c + ' - ' + sched.lunch_end__c,true,'Images/clock.png',dow,hour,minute));
	  	      	  lunch_started = true;
	  	      	}
	  	      	//check to see if block matches lunch end
	  	      	else if((sched.lunch_end_hour_int__c==null?0:sched.lunch_end_hour_int__c) == hour && (sched.lunch_end_minute_int__c==null?0:sched.lunch_end_minute_int__c) == minute) { 
	  	      	  cal_column.all_cells.add(new calendar_cell('lunch_close c-pointer','',false,null,dow,hour,minute));
	  	      	  lunch_started = false;
	  	      	}
	  	      	//check to see if block follows lunch start time 
	  	      	else if(lunch_started) {
	  	      	  cal_column.all_cells.add(new calendar_cell('lunch_slot c-pointer','Lunch',true,'Images/lunch.png',dow,hour,minute));
	  	      	  lunch_started = false;  	      	    	      	
	  	      	}  	      	
	  	      	//check to see if block is between lunch times
	  	      	else if(ctime>=lstime && ctime<=letime) {
	  	      	  cal_column.all_cells.add(new calendar_cell('lunch_slot c-pointer','',false,null,dow,hour,minute));
	  	      	}
	  	      	//check to see if this block matches start time
	  	      	else if((sched.start_hour_int__c==null?0:sched.start_hour_int__c) == hour && (sched.start_minute_int__c==null?0:sched.start_minute_int__c) == minute) {
	  	      	  //check to see if the previous cell was marked as open_clot c-pointer
	  	      	  if(cal_column.all_cells.size()>0) {
	  	      	    Integer last_position = cal_column.all_cells.size() - 1;
	  	      	    if(cal_column.all_cells.get(last_position).cell_css=='open_slot c-pointer')
	  	      	      cal_column.all_cells.get(last_position).cell_css += ' no_bottom';
	  	      	  }
	  	      	  cal_column.all_cells.add(new calendar_cell('working_head c-pointer',sched.start_time__c + ' - ' + sched.end_time__c,true,'Images/clock.png',dow,hour,minute));  	      	
	  	      	}
	  	      	//check to see if block matches end time
	  	      	else if((sched.end_hour_int__c==null?0:sched.end_hour_int__c) == hour && (sched.end_minute_int__c==null?0:sched.end_minute_int__c) == minute) { 
	  	      	  cal_column.all_cells.add(new calendar_cell('working_close c-pointer','',false,null,dow,hour,minute));  	      	
	  	      	}
	  	      	//check to see if block is between start/end times
	  	      	else if(ctime >= stime && ctime <= etime) {
	  	      	  cal_column.all_cells.add(new calendar_cell('working_slot c-pointer','',false,null,dow,hour,minute));
	  	      	}
	  	      	//otherwise,  it's just a boring block
	  	      	else  {	  	  	   	  	  	  	
	  	  	      cal_column.all_cells.add(new calendar_cell('open_slot c-pointer','',false,null,dow,hour,minute));
	  	      	}
	  	      	minute +=10;
	  	      }
	  	    }
	  	    //add the column to the week
	  	    week_column.add(cal_column);	
	  	  }
  	  }
  	}
  	return week_column;
  }
}