public with sharing class dp_admin_rooms {
  public String quick_search_field {get;set;} 
  public Boolean display_qsearch {get; set;}
  public Boolean display_add_button {get; set;} 
  public Boolean display_active_nav {get; set;}
  public Center_Information__c current_center {get; set;}
  public Boolean display_corp_admin {get; set;}
  public String selected_view {get; set;}
  public Navigation_Page__c current_page {get; set;}
  public String active_filter {get; set;}
  public String body_header {get; set;}
  public ID current_edit {get; set;}
  public Boolean modal_display {get; set;}
  public String modal_type {get; set;}
  public String modal_out {get; set;}
  public String activation_id {get; set;}
  public String new_room_type {get; set;}
  public Boolean display_prosth_room_form {get; set;}
  public Boolean display_surgery_room_form {get; set;}
  public Boolean display_recovery_room_form {get; set;}
  public Boolean display_hygiene_room_form {get; set;}  
  public Boolean display_hybrid_room_form {get; set;}
  public Clinical_Room__c new_room {get; set;}
  public String last_insert_id {get;set;}
  
  public CR_Schedule_Block__c new_block {get; set;}
  public String initial_shour {get; set;}
  public String initial_sminute {get; set;}
  public Boolean display_block_form {get; set;}
  public Boolean display_apt_form {get; set;}
  public String selected_form_type {get;set;}
  
  public String appointment_filter {get;set;} 
  public String new_apt_name {get; set;}
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
  static User current_user = [Select u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.ProfileId, u.Name, u.Id, u.Email, clinic_calendar__c, regional_traveler__c From User u where id = :userinfo.getUserid()];
  
  public class bendException extends Exception {}
    
  public dp_admin_rooms() {  	
  	modal_display = false;
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
        //User u = [select clinic_calendar__c from user where id =:userinfo.getUserId()];         
        if(current_user.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,sales_region__c,clinical_start_hour__c,clinical_end_hour__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,sales_region__c,clinical_start_hour__c,clinical_end_hour__c from Center_Information__c where name = :current_user.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,sales_region__c,clinical_start_hour__c,clinical_end_hour__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   	  	  	  	  	
  	//see if it's a corporate admin
  	Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team'};
  	//Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team') and id = :Userinfo.getProfileId()];
  	//if(admin_count>0)
  	if(admin_profiles.contains(current_user.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  	current_page = [Select Id, Name, Nav_Color__c, Page_URL__c From Navigation_Page__c where name = 'Rooms'];
  	hide_room_form();
  	display_all_rooms();
  }  
  
  public List<Navigation_Page__c> getgear_menu() {
  	return [Select n.Sort_Order__c, n.Page_URL__c, n.Name, n.Image_Name__c, n.Id , n.image_name_hover__c,n.hyperlink_target__c From Navigation_Page__c n where navigation_header__r.name = 'Gear' order by sort_order__c];
  }
  
  public List<Center_Information__c> getcenter_list() {
    List<Center_Information__c> ci_list;
    //to-do: need to modify this so it display all centers relevant to the user
  	//User current_user = [Select u.Name, u.Id,userrole.name, clinic_calendar__c, regional_traveler__c From User u where id = :userinfo.getuserid()];
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
  
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c,sales_region__c,clinical_start_hour__c,clinical_end_hour__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  quick_search_field = '';
  	  display_all_rooms();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public void change_category_filter() {
  	try {
  	  appointment_filter = apexpages.currentpage().getparameters().get('cfilter');
  	  if(appointment_filter==null)
  	    throw new bendException('No active value was detected');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change the category filter.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_all_rooms() {
  	display_qsearch = true;
  	display_add_button = true;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'all_room_display';
  	display_active_nav = true;
  	body_header = current_center.name + ' Rooms';
  }
  
  public void display_appointment_info() {
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'appointment_display';
  	display_active_nav = false;
  	body_header = '';
  	appointment_filter = 'All';
  	try {
  	  new_room = [Select id, Name, Center_Information__c, Room_Type__c, Sort_Order__c From Clinical_Room__c c where id = :apexpages.currentpage().getparameters().get('rid')];
  	  body_header = new_room.name + ' - Appointment Authorization';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the apt info for this room.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_schedule_info() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'calendar_display';
  	display_active_nav = true;
  	body_header = '';
  	appointment_filter = 'All';
  	try {
  	  new_room = [Select id, Name, Center_Information__c, Room_Type__c, Sort_Order__c From Clinical_Room__c c where id = :apexpages.currentpage().getparameters().get('rid')];
  	  body_header = new_room.name + ' - Weekly Schedule';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the schedule info for this room.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public String getdow_label(Integer dow) {
  	String dlabel = 'Unknown';
  	if(dow==1)
  	  dlabel = 'Monday';
  	if(dow==2)
  	  dlabel = 'Tuesday';
	if(dow==3)
  	  dlabel = 'Wednesday';
  	if(dow==4)
  	  dlabel = 'Thursday';
  	if(dow==5)
  	  dlabel = 'Friday';
  	if(dow==6)
  	  dlabel = 'Saturday';
  	if(dow==7)
  	  dlabel = 'Sunday';
  	return dlabel;  	
  }
  
  public String gettime_label(Integer hour, Integer minute) {
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
  	return tlabel;
  }
  
  public void display_existing_block_form() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'block_display';
  	display_active_nav = false;
  	body_header = '';
  	display_block_form = false;
  	display_apt_form = false;
  	selected_form_type = '';
  	try {
  	  new_block = [Select c.calendar_label__c, c.isActive__c, c.Start_Time__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Num_Authorized_Apts__c, c.End_Time__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Clinical_Room__c, c.Allow_All__c From CR_Schedule_Block__c c where id = :apexpages.currentpage().getparameters().get('bid')];  	  
  	  body_header = new_room.name + ' - Appointment Block - ' + new_block.dow_picklist__c + ' from ' + new_block.start_time__c + ' to ' + new_block.end_time__c;  	    	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the schedule info for this room.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_new_block_form() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'block_display';
  	display_active_nav = false;
  	body_header = '';
  	display_block_form = true;
  	display_apt_form = false;
  	try {
  	  Integer ehour = Integer.valueof(apexpages.currentpage().getparameters().get('shour')) + 1;
  	  initial_sminute = apexpages.currentpage().getparameters().get('sminute');
  	  if(initial_sminute == '0')
  	    initial_sminute = '00';
  	  new_block = new CR_Schedule_Block__c(calendar_label__c = 'Open Block', allow_all__c = true, clinical_room__c = new_room.id, dow__c = Integer.valueof(apexpages.currentpage().getparameters().get('dow')), 
  	    end_hour__c = String.valueof(ehour), end_minute__c = initial_sminute, start_hour__c = apexpages.currentpage().getparameters().get('shour'), 
  	    start_minute__c = initial_sminute, isactive__c = true, start_time__c = gettime_label(Integer.valueof(apexpages.currentpage().getparameters().get('shour')),Integer.valueof(apexpages.currentpage().getparameters().get('sminute'))),
  	    end_time__c = gettime_label(ehour,Integer.valueof(apexpages.currentpage().getparameters().get('sminute'))));
  	  body_header = new_room.name + ' - New Appointment Block - ' + getdow_label(new_block.dow__c.intValue()) + ' from ' + gettime_label(Integer.valueof(new_block.start_hour__c),Integer.valueof(new_block.start_minute__c)) + ' to ' + gettime_label(Integer.valueof(new_block.end_hour__c),Integer.valueof(new_block.end_minute__c));
  	  initial_shour = apexpages.currentpage().getparameters().get('shour');  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the schedule info for this room.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }  
  
  public void show_block_form() {
  	display_block_form = true;
  }
  
  public boolean getworking_on_new_block() {
  	if(new_block.id==null)
  	  return true;
  	else
  	  return false;
  }
  
  public void save_block_form() {
  	//error checking here
  	Integer num_issues = 0;
  	//pattern to check for numeric values
  	Pattern all_numbers = Pattern.Compile('^[0-9]+$');
    
    //make sure we have valid values for all the time fields
    /*No longer necessary - switched to use having picklist options*/
  	/*if(new_block.start_hour__c==null || new_block.start_minute__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the starting time'));
  	  //new_room.name.addError('You must enter a room label');  	  
  	} else if(!all_numbers.matcher(new_block.start_hour__c).matches() || !all_numbers.matcher(new_block.start_minute__c).matches()) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a numeric value for the starting time'));
  	} else if(Integer.valueof(new_block.start_hour__c)<0 || Integer.valueof(new_block.start_hour__c)>23 || Integer.valueof(new_block.start_minute__c)<0 || Integer.valueof(new_block.start_minute__c)>59) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid range for starting time.  Hour must be between 0 and 23 while minutes range from 0 to 59'));
  	}
  	if(new_block.end_hour__c==null || new_block.end_minute__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the ending time'));
  	  //new_room.name.addError('You must enter a room label');  	  
  	} else if(!all_numbers.matcher(new_block.end_hour__c).matches() || !all_numbers.matcher(new_block.end_minute__c).matches()) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a numeric value for the ending time'));
  	} else if(Integer.valueof(new_block.end_hour__c)<0 || Integer.valueof(new_block.end_hour__c)>23 || Integer.valueof(new_block.end_minute__c)<0 || Integer.valueof(new_block.end_minute__c)>59) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid range for ending time.  Hour must be between 0 and 23 while minutes range from 0 to 59'));
  	} */ 	
  	//make sure end time is after start time
  	Integer shour = Integer.valueof(new_block.start_time__c.left(2).replace(':',''));
  	if(new_block.start_time__c.right(2)=='PM' && shour!=12)
  	  shour+=12;  	    	
  	Integer sminute = Integer.valueof(new_block.start_time__c.right(5).replace(' AM','').replace(' PM','')); 	  
  	Integer ehour = Integer.valueof(new_block.end_time__c.left(2).replace(':',''));
  	if(new_block.end_time__c.right(2)=='PM' && ehour!=12)
  	  ehour+=12;  	    	 	  
  	Integer eminute = Integer.valueof(new_block.end_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  	
  	Integer stime = (shour * 60) + (sminute);
  	Integer etime = (ehour * 60) + (eminute);
  	if(etime <= stime) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Ending Time must come after start time'));
  	} else if (etime-stime <30) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Block must be at least 30 minutes in length'));
  	}  	
  	//make sure calendar label is between 2 and 100 characters
  	if(new_block.calendar_label__c.length()<2) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Calendar Label must be at least 2 characters in length'));
  	}
  	else if(new_block.calendar_label__c.length()>100) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Calendar Label is too long.  Current Size is ' + new_block.calendar_label__c.length() + '.  Max allowed is 100 characters.'));
  	}  	
  	//make sure we don't have an active existing block on the schedule that overlaps with this one
  	//check for a start time between our times
  	Integer block_count = 0;
  	if(new_block.id==null)
  	  block_count += [Select count() From CR_Schedule_Block__c where (start_hour_int__c > :shour or (start_hour_int__c = :shour and start_minute_int__c > :sminute)) and (start_hour_int__c < :ehour or (start_hour_int__c = :ehour and start_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and isactive__c = true];
  	else
  	  block_count += [Select count() From CR_Schedule_Block__c where (start_hour_int__c > :shour or (start_hour_int__c = :shour and start_minute_int__c > :sminute)) and (start_hour_int__c < :ehour or (start_hour_int__c = :ehour and start_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and id != :new_block.id and isactive__c = true];
  	//check for an end time between out times
  	if(new_block.id==null)
  	  block_count += [Select count() From CR_Schedule_Block__c where (end_hour_int__c > :shour or (end_hour_int__c = :shour and end_minute_int__c > :sminute)) and (end_hour_int__c < :ehour or (end_hour_int__c = :ehour and end_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and isactive__c = true];
  	else
  	  block_count += [Select count() From CR_Schedule_Block__c where (end_hour_int__c > :shour or (end_hour_int__c = :shour and end_minute_int__c > :sminute)) and (end_hour_int__c < :ehour or (end_hour_int__c = :ehour and end_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and id != :new_block.id and isactive__c = true];
  	if(block_count>0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is already a block on the schedule that covers part of this time.  Blocks are not allowed to overlap.'));
  	}
  	if(num_issues == 0) {
  	  try {
  	  	new_block.end_hour__c = String.valueOf(ehour);
  	  	new_block.end_minute__c = String.valueOf(eminute);
  	  	new_block.start_hour__c = String.valueOf(shour);
  	  	new_block.start_minute__c = String.valueof(sminute);
  	  	if(new_block.id==null)
  	      insert new_block;
  	    else
  	      update new_block;
  	    last_insert_id = new_block.id;
  	    display_block_form = false;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the scheduling block. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void reset_block_form() {
  	//are we working on an existing or new block
  	if(new_block.id==null) {
  	  new_block.start_hour__c = initial_shour;
  	  new_block.start_minute__c = initial_sminute;
  	  new_block.end_hour__c = String.valueof((Integer.valueof(initial_shour) + 1));
  	  new_block.end_minute__c = initial_sminute;
  	  new_block.start_time__c = gettime_label(Integer.valueOf(new_block.start_hour__c),Integer.valueof(new_block.start_minute__c));
  	  new_block.end_time__c = gettime_label(Integer.valueof(new_block.end_hour__c),Integer.valueof(new_block.end_minute__c));
  	}
  	else 
  	  new_block = [Select c.calendar_label__c,c.isActive__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Num_Authorized_Apts__c, c.Id, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Allow_All__c, (Select Id, Clinical_Appointment__c, Clinical_Appointment__r.Name From CR_Sched_Block_Authorized_Apts__r) From CR_Schedule_Block__c c where id = :new_block.id];
  }
  
  public void hide_block_form() {
  	//are we working on an existing or new block
  	if(new_block.id==null) {
  	  //new block - just go back to calendar display  	  
  	  apexpages.currentpage().getparameters().put('rid',new_room.id);
  	  display_schedule_info();
  	} else 
  	  display_block_form = false;
  }
  
  public PageReference navigate_to() {
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
  
  public void new_apt_form() {
  	display_apt_form = true;
  	new_apt_name = 'Enter Appointment';
  	appointment_filter = 'All';
  }
  
  public void hide_apt_form() {
  	display_apt_form = false;
  }
  
  public void reset_apt_form() {
  	new_apt_name = 'Enter Appointment';
  	appointment_filter = 'All';
  }
  
  public void select_appointment() {
  	new_apt_name = [select name from Clinical_Appointment__c where id = :apexpages.currentpage().getparameters().get('aptid')].name;
  	add_block_apt_authorization();
  }
  
  public void add_block_apt_authorization() {
  	//see if we have a match
  	Integer proc_matches = [select count() from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];
  	if(proc_matches==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid appointment name'));	
  	} else {
  	  try {    	  	
  	  	Clinical_Appointment__c ca = [select id from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];	  	    
  	    //create and insert record
  	    CR_Sched_Block_Authorized_Apt__c csba = new CR_Sched_Block_Authorized_Apt__c(CR_Schedule_Block__c = new_block.id, Clinical_Appointment__c = ca.id);
  	    insert csba;  	      	    
  	    hide_apt_form();
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the appointment. Please contact IT for help'));
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
  	  if(appointment_filter!='All')
  	    query_filter += ' and appointment_filter__c = \'' + appointment_filter + '\' ';
  	  //block any apts that have already been marked as allowed
  	  query_filter += 'and id not in (';
  	  for(CR_Sched_Block_Authorized_Apt__c cb : [Select c.Clinical_Appointment__c From CR_Sched_Block_Authorized_Apt__c c where CR_schedule_block__c = :new_block.id]) {
  	    query_filter += '\'' + cb.clinical_appointment__c + '\',';
  	  }    	  
  	  query_filter += '\'\') ';
  	  ca_list = database.query('select id,name,appointment_description__c from clinical_appointment__c ' + query_filter + ' order by name');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical appointments for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  	return ca_list;
  }

  public List<Clinical_Room__c> getall_rooms() {
    List<Clinical_Room__c> cr_list;
    try {
      String query_filter = ' where center_information__c = \'' + current_center.id + '\' ';
  	  if(active_filter=='Active')
  	    query_filter += ' and isactive__c = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and isactive__c = false ';
  	  if((quick_search_field==null?'':quick_search_field) != '') 
  	  	query_filter += ' and name like \'%' + quick_search_field + '%\'  ';
  	  cr_list = database.query('Select c.id,c.isactive__c, c.Room_Type__c, c.Name, c.Center_Information__c From Clinical_Room__c c ' + query_filter + ' order by isactive__c desc, sort_order__c');    	
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical rooms for this center. Please contact IT for help'));      
      ApexPages.addMessages(e);		
    }    
    return cr_list;
  }
  
  public List<Clinical_Room__c> getprosth_rooms() {
  	List<Clinical_Room__c> prosth_list = new List<Clinical_Room__c>();
  	for(Clinical_Room__c cr : getall_rooms()) {
  	  if(cr.room_type__c=='Prosth')
  	    prosth_list.add(cr);
  	}
  	return prosth_list;
  }
  
  public List<Clinical_Room__c> getsurgery_rooms() {
  	List<Clinical_Room__c> room_list = new List<Clinical_Room__c>();
  	for(Clinical_Room__c cr : getall_rooms()) {
  	  if(cr.room_type__c=='Surgery')
  	    room_list.add(cr);
  	}
  	return room_list;
  }
  
  public List<Clinical_Room__c> getrecovery_rooms() {
  	List<Clinical_Room__c> room_list = new List<Clinical_Room__c>();
  	for(Clinical_Room__c cr : getall_rooms()) {
  	  if(cr.room_type__c=='Recovery')
  	    room_list.add(cr);
  	}
  	return room_list;
  }
  
  public List<Clinical_Room__c> gethygiene_rooms() {
  	List<Clinical_Room__c> room_list = new List<Clinical_Room__c>();
  	for(Clinical_Room__c cr : getall_rooms()) {
  	  if(cr.room_type__c=='Hygiene')
  	    room_list.add(cr);
  	}
  	return room_list;
  }
  
  public List<Clinical_Room__c> gethybrid_rooms() {
  	List<Clinical_Room__c> room_list = new List<Clinical_Room__c>();
  	for(Clinical_Room__c cr : getall_rooms()) {
  	  if(cr.room_type__c=='Hybrid')
  	    room_list.add(cr);
  	}
  	return room_list;  	
  }
  
  public Integer getall_count() {
  	Integer record_count = 0;
  	if(selected_view=='all_room_display')
  	  record_count = [select count() from Clinical_Room__c where center_information__c = :current_center.id];  	
  	if(selected_view=='calendar_display')
  	   record_count = [select count() from CR_Schedule_Block__c where clinical_room__c = :new_room.id];
  	return record_count;
  }
  
  public Integer getactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='all_room_display')
  	  record_count = [select count() from Clinical_Room__c where center_information__c = :current_center.id and isactive__c = true];
  	if(selected_view=='calendar_display')
  	   record_count = [select count() from CR_Schedule_Block__c where clinical_room__c = :new_room.id and isactive__c = true];  	
  	return record_count;
  }
  
  public Integer getinactive_count() {
  	Integer record_count = 0;
 	if(selected_view=='all_room_display')
  	  record_count = [select count() from Clinical_Room__c where center_information__c = :current_center.id and isactive__c = false];
  	if(selected_view=='calendar_display')
  	   record_count = [select count() from CR_Schedule_Block__c where clinical_room__c = :new_room.id and isactive__c = false];  	
  	return record_count;
  }
  
  public void new_room_form() {  	
  	hide_room_form();
    if(new_room_type=='Prosth')
      display_prosth_room_form = true;
    if(new_room_type=='Surgery')
      display_surgery_room_form = true;
    if(new_room_type=='Recovery')
      display_recovery_room_form = true;
    if(new_room_type=='Hygiene')
      display_hygiene_room_form = true;
    if(new_room_type=='Hybrid')
      display_hybrid_room_form = true;      
  	current_edit = null;
  	new_room = new Clinical_Room__c(name='Enter room label',Room_Type__c = new_room_type, isactive__c=true, center_information__c = current_center.id);
  	//figure out the sort order for this record
  	//grab the current max sort order
  	AggregateResult ar = database.query('select max(sort_order__c) msort from Clinical_Room__c where room_type__c = \'' + new_room_type + '\' and center_information__c = \'' + current_center.id + '\'');
  	Integer max_sort = 0;
  	if(ar.get('msort')!=null) {
  	  Decimal msort = (decimal)ar.get('msort'); 
  	  max_sort = msort.intValue();
  	}  
  	new_room.sort_order__c = (max_sort + 1);
  }
  
  public void edit_room() {
  	try {
  	  new_room = [select id,name,isactive__c,room_type__c from Clinical_Room__c where id = :current_edit];
      display_prosth_room_form = false;
      display_surgery_room_form = false;
      display_recovery_room_form = false;
      display_hygiene_room_form = false;	
      display_hybrid_room_form = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the room. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void hide_room_form() {
  	display_prosth_room_form = false;
    display_surgery_room_form = false;
    display_recovery_room_form = false;
    display_hygiene_room_form = false;
    display_hybrid_room_form = false;
    current_edit = null;
  }
  
  public void reset_room_form() {
  	new_room = new Clinical_Room__c(name='Enter room label',Room_Type__c = new_room_type, isactive__c=true, center_information__c = current_center.id);
  }
  
  public void save_new_room() {
  	Integer num_issues = 0;
  	if(new_room.name==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for room label'));
  	  //new_room.name.addError('You must enter a room label');  	  
  	} else if(new_room.name=='Enter room label') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for room label'));
  	}  	
  	Integer dupe_count = [select count() from Clinical_Room__c where center_information__c = :current_center.id and name = :new_room.name and id != :new_room.id];
  	if(dupe_count>0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Room label ' + new_room.name + ' is already in use'));
  	}
  	if(num_issues == 0) {
  	  try {
  	  	if(current_edit==null)
  	      insert new_room;
  	    else
  	      update new_room;
  	    last_insert_id = new_room.id;
  	    hide_room_form();
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the room. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void modify_sort_order() {
  	String pass_thru;
  	try {
  	  pass_thru = apexpages.currentpage().getparameters().get('pthru');
  	  //String rtype = apexpages.currentpage().getparameters().get('room_type');
  	  //System.debug('String : ' + pass_thru);
  	  pass_thru = pass_thru.replace('prosth_room[]=','');
  	  pass_thru = pass_thru.replace('surgery_room[]=','');
  	  pass_thru = pass_thru.replace('recovery_room[]=','');
  	  pass_thru = pass_thru.replace('hygiene_room[]=','');
  	  pass_thru = pass_thru.replace('hybrid_room[]=','');
      //System.debug('pass thru : ' + pass_thru);
      //pass_thru = pass_thru.replace('name','');
      //System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      List<Clinical_Room__c> cr_list = new List<Clinical_Room__c>();
      for(String my_id : pass_array) {
      	Clinical_Room__c cr = [select id,sort_order__c from Clinical_Room__c where id = :my_id];
      	cr.sort_order__c = sort_order;
      	cr_list.add(cr);
      	sort_order++;
      }
      update cr_list;      
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Pass thru : ' + pass_thru + ' pthru : ' + apexpages.currentpage().getparameters().get('pthru')));
      ApexPages.addMessages(e);	
    }  
  }
  
  public List<Clinical_Room_Authorized_Apt__c> getauthorized_apts() {
  	List<Clinical_Room_Authorized_Apt__c> apts;
    try {
      String query_filter = ' where clinical_room__c = \'' + new_room.id + '\'';
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and (c.clinical_appointment__r.name like \'%' + quick_search_field + '%\' or c.clinical_appointment__r.Appointment_Description__c like \'%' + '%\') ';
  	  }          	
	  if(appointment_filter!='All')
  	    query_filter += ' and clinical_appointment__r.appointment_filter__c = \'' + appointment_filter + '\' ';  	  
      apts = database.query('Select c.Id, c.Clinical_Room__c, c.clinical_room__r.name, c.Clinical_Appointment__c, c.clinical_appointment__r.name, c.clinical_appointment__r.Appointment_Description__c From Clinical_Room_Authorized_Apt__c c ' + query_filter + ' order by c.clinical_appointment__r.name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up authorized appointments.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return apts;
  }
  
  public List<Clinical_Appointment__c> getblocked_appointments() {
  	List<Clinical_Appointment__c> apts;
    try {
      String query_filter = ' where center_information__c  = \'' + current_center.id + '\' and id not in (';
  	  for(Clinical_Room_Authorized_Apt__c cr : getauthorized_apts()) {
  	    query_filter += '\'' + cr.clinical_appointment__c + '\',';
  	  }  
  	  query_filter += '\'\') '; 
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and (name like \'%' + quick_search_field + '%\' or Appointment_Description__c like \'%' + '%\') ';
  	  }          	
  	  if(appointment_filter!='All')
  	    query_filter += ' and appointment_filter__c = \'' + appointment_filter + '\' ';
      apts = database.query('Select Id, name From Clinical_Appointment__c ' + query_filter + ' order by name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up non-authorized appointments.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return apts;
  }
  
  public void authorize_appointment() {
  	try {
  	  Clinical_Room_Authorized_Apt__c cra = new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = activation_id,Clinical_Room__c = new_room.id);
  	  insert cra;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error authorizing access to this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}
  }
  
  public void block_appointment() {
  	try {
  	  Clinical_Room_Authorized_Apt__c cra = [select id from Clinical_Room_Authorized_Apt__c where id = :activation_id];
  	  delete cra;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing access for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void authorize_all_appointments() {
  	try {
  	  List<Clinical_Room_Authorized_Apt__c> cra_list = new List<Clinical_Room_Authorized_Apt__c>();
  	  for(Clinical_Appointment__c ca : getblocked_appointments()) {
  	  	Clinical_Room_Authorized_Apt__c cra = new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca.id,Clinical_Room__c = new_room.id);
  	  	cra_list.add(cra);
  	  }
  	  if(cra_list.size()>0)
  	    insert cra_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding access for this room. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void block_all_appointments() {
  	try {
  	  List<Clinical_Room_Authorized_Apt__c> cra_list = getauthorized_apts();
  	  delete cra_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing access for this room. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  	
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
  
  public List<Selectoption> getapt_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	clist.add(new Selectoption('Prosth','Prosth'));
  	clist.add(new Selectoption('Surgical','Surgical'));
  	clist.add(new Selectoption('Misc','Misc'));
	return clist;
  }  
  
  public class calendar_cell {
  	public String cell_css {get;set;}
  	public String cell_text {get;set;}
  	public Boolean image_display {get;set;}
  	public String image_name {get;set;}
  	public Integer dow {get;set;}
  	public Integer hour {get; set;}
  	public Integer minute {get; set;}
  	public Boolean display_tooltip {get; set;}
  	public String tool_type {get; set;}
  	public String tool_title {get; set;}
  	public String tool_content {get; set;}
  	public String onclick_event {get; set;}
  	
  	public calendar_cell(String ccss, String ctext, Boolean idisplay, String iname, Integer d, Integer h, Integer m) {
  	  this.cell_css = ccss;
  	  this.cell_text = ctext;
  	  this.image_display = idisplay;
  	  this.image_name = iname;
  	  this.dow = d;
  	  this.hour = h;
  	  this.minute = m;
  	  this.display_tooltip = false;
  	  this.tool_type = 'none';
  	  this.tool_title = 'Click to add a block';
  	  this.tool_content = 'na';
  	  this.onclick_event = 'return false;';
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
  	Integer start_hour = (current_center.clinical_start_hour__c==null?7:current_center.clinical_start_hour__c.intvalue());
  	Integer end_hour = current_center.clinical_end_hour__c==null ? 20 : current_center.clinical_end_hour__c.intvalue();
  	for(hour=start_hour;hour<end_hour;hour++) {
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
  	Integer start_hour = (current_center.clinical_start_hour__c==null?7:current_center.clinical_start_hour__c.intvalue());
    Integer end_hour = current_center.clinical_end_hour__c==null ? 20 : current_center.clinical_end_hour__c.intvalue();
  	for(hour=start_hour;hour<end_hour;hour++) {
  	  minute = 0;
  	  while(minute<60) {  	  	  	   	  	  	  	
  	  	calendar_cell cc = new calendar_cell('open_slot c-pointer','',false,null,day_of_week,hour,minute);
  	  	cc.onclick_event = 'new_block(' + day_of_week + ',' + hour + ',' + minute + ')';
  	  	label_col.add(cc);
  	  	minute += 10;
  	  }
  	}
  	return label_col;
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
  	  //check to see if we have any blocks defined for this day
      Integer sched_count = 0;
      if(active_filter == 'Active') 
        sched_count = [Select count() From CR_Schedule_Block__c  where clinical_room__c = :new_room.id and dow__c = :dow and isactive__c = true];
      else if(active_filter == 'Inactive')
        sched_count = [Select count() From CR_Schedule_Block__c  where clinical_room__c = :new_room.id and dow__c = :dow and isactive__c = false];
      else if(active_filter == 'All')
         sched_count = [Select count() From CR_Schedule_Block__c  where clinical_room__c = :new_room.id and dow__c = :dow];  	    	    	  
  	  //if not - build a clean column
  	  if(sched_count==0) {
  	  	cal_column.all_cells.addAll(getblank_column(dow_name.get(dow),dow));
        week_column.add(cal_column);	
  	  } else { 
  	    List<CR_Schedule_Block__c> sched_blocks;
  	    
        if(active_filter == 'All')
  	      sched_blocks = [Select c.calendar_label__c, c.isActive__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Num_Authorized_Apts__c, c.Id, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Allow_All__c, (Select Id, Clinical_Appointment__c, Clinical_Appointment__r.Name From CR_Sched_Block_Authorized_Apts__r)  From CR_Schedule_Block__c c where c.clinical_room__c = :new_room.id and dow__c = :dow order by start_hour_int__c, start_minute_int__c,isactive__c desc];
  	    else if(active_filter == 'Active')
  	      sched_blocks = [Select c.calendar_label__c, c.isActive__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Num_Authorized_Apts__c, c.Id, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Allow_All__c, (Select Id, Clinical_Appointment__c, Clinical_Appointment__r.Name From CR_Sched_Block_Authorized_Apts__r)  From CR_Schedule_Block__c c where c.clinical_room__c = :new_room.id and dow__c = :dow and isactive__c = true order by start_hour_int__c, start_minute_int__c];
  	    else if(active_filter == 'Inactive')
  	      sched_blocks = [Select c.calendar_label__c, c.isActive__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Num_Authorized_Apts__c, c.Id, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Allow_All__c, (Select Id, Clinical_Appointment__c, Clinical_Appointment__r.Name From CR_Sched_Block_Authorized_Apts__r)  From CR_Schedule_Block__c c where c.clinical_room__c = :new_room.id and dow__c = :dow and isactive__c = false order by start_hour_int__c, start_minute_int__c];
  	    Integer sched_position = 0;  	    	  
 	  	cal_column.all_cells.add(new calendar_cell('col_header',dow_name.get(dow),false,null,0,0,0));
 	  	CR_Schedule_Block__c current_block = sched_blocks.get(sched_position);
 	  	
	  	Integer shour = (current_block.start_hour_int__c==null?0:current_block.start_hour_int__c.intvalue());
	  	Integer sminute = (current_block.start_minute_int__c==null?0:current_block.start_minute_int__c.intvalue());
	  	Integer stime = (shour * 60 + sminute);
	  	Integer ehour = (current_block.end_hour_int__c==null?0:current_block.end_hour_int__c.intvalue());
	  	Integer eminute = (current_block.end_minute_int__c==null?0:current_block.end_minute_int__c.intvalue());
	  	Integer etime = (ehour * 60 + eminute);
	  	  	
	  	//otherwise - build a column that displays the hour info
	  	Integer hour;
	  	Integer minute;
	  	Integer start_hour = (current_center.clinical_start_hour__c==null?7:current_center.clinical_start_hour__c.intvalue());
	  	Integer end_hour = current_center.clinical_end_hour__c==null ? 20 : current_center.clinical_end_hour__c.intvalue();
	  	for(hour=start_hour;hour<end_hour;hour++) {
	  	  minute = 0;
	  	  while(minute<60) {
	  	   	System.debug('Hour : ' + hour + ' Minute : ' + minute + ' DOW : ' + dow);
	  	   	Integer ctime = (hour * 60) + minute;	  	     		 
	  	    //check to make sure we still have an upcoming block - if not,  we've drawn all of them and everything else if a boring cell
	  	    if(current_block==null) {
	  	      calendar_cell cc = new calendar_cell('open_slot c-pointer','',false,null,dow,hour,minute);
	  	      cc.onclick_event = 'new_block(' + dow + ',' + hour + ',' + minute + ');';
	  	      cal_column.all_cells.add(cc);
	  	    } 	      	
	  	  	//check to see if time matches the start time for our upcoming block 
	  	   	else if((current_block.start_hour_int__c==null?0:current_block.start_hour_int__c) == hour && (current_block.start_minute_int__c==null?0:current_block.start_minute_int__c) == minute) {
	  	   	  //check to see if the previous cell was marked as open_clot c-pointer
	  	   	  if(cal_column.all_cells.size()>0) {
	  	   	    Integer last_position = cal_column.all_cells.size() - 1;
	  	   	    if(cal_column.all_cells.get(last_position).cell_css=='open_slot c-pointer')
	  	   	      cal_column.all_cells.get(last_position).cell_css += ' no_bottom';
	  	   	  }
	  	   	 /* if(current_block.allow_all__c)
	  	   	    cell_label = current_block.calendar_label__c + ' - Any';
	  	   	  else if(current_block.num_authorized_apts__c==1) {
	  	   	  	//display the one authorized apt type
	  	   	  	cell_label = current_block.calendar_label__c + ' - ' + current_block.CR_Sched_Block_Authorized_Apts__r[0].clinical_appointment__r.name;
	  	   	  }
	  	   	  else {
	  	   	  	//display first apt and total count
	  	   	  	cell_label = current_block.calendar_label__c + ' - ' + current_block.CR_Sched_Block_Authorized_Apts__r[0].clinical_appointment__r.name + '(' + 
	  	   	  	  current_block.CR_Sched_Block_Authorized_Apts__r.size() + ')';
	  	   	  }*/
	  	   	  String cell_label = '';
	  	      if(current_block.allow_all__c)
	  	   	    cell_label = 'Any';
	  	   	  else if(current_block.num_authorized_apts__c==1) {
	  	   	  	//display the one authorized apt type
	  	   	  	cell_label = current_block.CR_Sched_Block_Authorized_Apts__r[0].clinical_appointment__r.name;
	  	   	  }
	  	   	  else {
	  	   	  	//display first apt and total count
	  	   	  	cell_label = current_block.CR_Sched_Block_Authorized_Apts__r[0].clinical_appointment__r.name + '(' + 
	  	   	  	  current_block.CR_Sched_Block_Authorized_Apts__r.size() + ')';
	  	   	  }
	  	   	  String base_css = '';
	  	      if(current_block.isactive__c)
	  	        base_css = 'working_head ';
	  	      else
	  	        base_css = 'inactive_head ';
	  	   	  calendar_cell cc = new calendar_cell(base_css + 'c-pointer',cell_label,true,'Images/clinical.png',dow,hour,minute);
	  	   	  cc.onclick_event = 'close_pops();modify_block(\'' + current_block.id + '\');';
	  	   	  cc.display_tooltip = true;
	  	   	  cc.tool_type = 'popover';
	  	   	  cc.tool_title = '<p class=\'tool_head\'>Allowed Apts</p><ul style=\'padding-left:2px;\'>';	  	   	  
	  	   	  cc.tool_content = '';
	  	   	  for(CR_Sched_Block_Authorized_Apt__c csb : current_block.CR_Sched_Block_Authorized_Apts__r) {
	  	   	  	cc.tool_content += csb.clinical_appointment__r.name + '<br />';
	  	   	  	cc.tool_title += '<li style=\'color:#189BEB;\'>' + csb.clinical_appointment__r.name + '</li>';
	  	   	  }
	  	   	  cc.tool_title += '</ul>';
	  	      cal_column.all_cells.add(cc);  	      	
	  	    }	  	    
	  	    //check to see if block matches end time
	  	    else if((current_block.end_hour_int__c==null?0:current_block.end_hour_int__c) == hour && (current_block.end_minute_int__c==null?0:current_block.end_minute_int__c) == minute) {
	  	      String cell_label = current_block.calendar_label__c;
	  	      /*String cell_label = '';
	  	      if(current_block.allow_all__c)
	  	   	    cell_label = 'Any';
	  	   	  else if(current_block.num_authorized_apts__c==1) {
	  	   	  	//display the one authorized apt type
	  	   	  	cell_label = current_block.CR_Sched_Block_Authorized_Apts__r[0].clinical_appointment__r.name;
	  	   	  }
	  	   	  else {
	  	   	  	//display first apt and total count
	  	   	  	cell_label = current_block.CR_Sched_Block_Authorized_Apts__r[0].clinical_appointment__r.name + '(' + 
	  	   	  	  current_block.CR_Sched_Block_Authorized_Apts__r.size() + ')';
	  	   	  }*/
	  	      String base_css = '';
	  	      if(current_block.isactive__c)
	  	        base_css = 'working_close ';
	  	      else
	  	        base_css = 'inactive_close ';
	  	      calendar_cell cc = new calendar_cell(base_css + ' c-pointer',cell_label,false,null,dow,hour,minute);
	  	   	  cc.onclick_event = 'close_pops();modify_block(\'' + current_block.id + '\');';
	  	   	  cc.display_tooltip = true;
	  	   	  cc.tool_type = 'popover';
	  	   	  cc.tool_title = '<p class=\'tool_head\'>Allowed Apts</p><ul style=\'padding-left:2px;\'>';  	   	  
	  	   	  cc.tool_content = '';
	  	   	  for(CR_Sched_Block_Authorized_Apt__c csb : current_block.CR_Sched_Block_Authorized_Apts__r) {
	  	   	  	cc.tool_content += csb.clinical_appointment__r.name + '<br />';
	  	   	  	cc.tool_title += '<li style=\'color:#189BEB;\'>' + csb.clinical_appointment__r.name + '</li>';
	  	   	  }
	  	   	  cc.tool_title += '</ul>';
	  	      cal_column.all_cells.add(cc);  
	  	      //iterate to the next block if we have more
	  	      sched_position++;
	  	      if(sched_position<=(sched_blocks.size()-1) ) {
	  	      	current_block = sched_blocks.get(sched_position);
	  	      	shour = (current_block.start_hour_int__c==null?0:current_block.start_hour_int__c.intvalue());
	  	        sminute = (current_block.start_minute_int__c==null?0:current_block.start_minute_int__c.intvalue());
	  	        stime = (shour * 60 + sminute);
	  	        ehour = (current_block.end_hour_int__c==null?0:current_block.end_hour_int__c.intvalue());
	  	        eminute = (current_block.end_minute_int__c==null?0:current_block.end_minute_int__c.intvalue());
	  	        etime = (ehour * 60 + eminute);
	  	      }	      	
	  	      else 
	  	        current_block = null;
	  	    }
	  	    //check to see if block is between start/end times
	  	    else if(ctime >= stime && ctime <= etime) {
	  	      String base_css = '';
	  	      if(current_block.isactive__c)
	  	        base_css = 'working_slot ';
	  	      else
	  	        base_css = 'inactive_slot ';
	  	      calendar_cell cc = new calendar_cell(base_css + 'c-pointer','',false,null,dow,hour,minute);
	  	   	  cc.onclick_event = 'close_pops();modify_block(\'' + current_block.id + '\');';
	  	   	  cc.display_tooltip = true;
	  	   	  cc.tool_type = 'popover';
	  	   	  cc.tool_title = '<p class=\'tool_head\'>Allowed Apts</p><ul style=\'padding-left:2px;\'>'; 	  	   	  
	  	   	  cc.tool_content = '';
	  	   	  for(CR_Sched_Block_Authorized_Apt__c csb : current_block.CR_Sched_Block_Authorized_Apts__r) {
	  	   	  	cc.tool_content += csb.clinical_appointment__r.name + '<br />';
	  	   	  	cc.tool_title += '<li style=\'color:#189BEB;\'>' + csb.clinical_appointment__r.name + '</li>';
	  	   	  }
	  	   	  cc.tool_title += '</ul>';
	  	      cal_column.all_cells.add(cc);	
	  	    }
	  	    //otherwise,  it's just a boring block
	  	    else  {	  	    		  	  	   	  	  	  
	  	  	  calendar_cell cc = new calendar_cell('open_slot c-pointer','',false,null,dow,hour,minute);
	  	      cc.onclick_event = 'new_block(' + dow + ',' + hour + ',' + minute + ');';
	  	      cal_column.all_cells.add(cc);
	  	    }
	  	    minute +=10;
	  	  }
	  	}
	  	//add the column to the week
	  	week_column.add(cal_column);	
	  }
  	}
  	return week_column;
  }
  
  public List<Clinical_Appointment__c> getapt_by_type_list(String apt_type) {
  	Set<ID> existing_ca_list = new Set<ID>();
  	for(CR_Sched_Block_Authorized_Apt__c csb : getblock_apts()) {
  	  existing_ca_list.add(csb.clinical_appointment__c);  	  
  	}
  	return [select id,name from Clinical_Appointment__c where appointment_filter__c = :apt_type and center_information__c = :current_center.id and isactive__c = true
  	  and id not in :existing_ca_list];
  }
  
  public void add_all_prosth_appointments() {  	
  	List<CR_Sched_Block_Authorized_Apt__c> new_authorized_apt_list = new List<CR_Sched_Block_Authorized_Apt__c>();
  	for(Clinical_Appointment__c ca : getapt_by_type_list('Prosth')) {
  	  CR_Sched_Block_Authorized_Apt__c csba = new CR_Sched_Block_Authorized_Apt__c(CR_Schedule_Block__c = new_block.id, Clinical_Appointment__c = ca.id);
  	  //System.debug('Add Apt ' + ca.name + ' - ' + ca.id);
  	  new_authorized_apt_list.add(csba);	
  	}
  	if(new_authorized_apt_list.size()>0) {
  	  try {
  	  	insert new_authorized_apt_list;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding prosth apts for this block. Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}  	
  }
  
  public void add_all_surgical_appointments() {
  	List<CR_Sched_Block_Authorized_Apt__c> new_authorized_apt_list = new List<CR_Sched_Block_Authorized_Apt__c>();
  	for(Clinical_Appointment__c ca : getapt_by_type_list('Surgical')) {
  	  CR_Sched_Block_Authorized_Apt__c csba = new CR_Sched_Block_Authorized_Apt__c(CR_Schedule_Block__c = new_block.id, Clinical_Appointment__c = ca.id);
  	  //System.debug('Add Apt ' + ca.name + ' - ' + ca.id);
  	  new_authorized_apt_list.add(csba);	
  	}
  	if(new_authorized_apt_list.size()>0) {
  	  try {
  	  	insert new_authorized_apt_list;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding surgical apts for this block. Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public void add_all_misc_appointments() {
  	List<CR_Sched_Block_Authorized_Apt__c> new_authorized_apt_list = new List<CR_Sched_Block_Authorized_Apt__c>();
  	for(Clinical_Appointment__c ca : getapt_by_type_list('Misc')) {
  	  CR_Sched_Block_Authorized_Apt__c csba = new CR_Sched_Block_Authorized_Apt__c(CR_Schedule_Block__c = new_block.id, Clinical_Appointment__c = ca.id);
  	  //System.debug('Add Apt ' + ca.name + ' - ' + ca.id);
  	  new_authorized_apt_list.add(csba);	
  	}
  	if(new_authorized_apt_list.size()>0) {
  	  try {
  	  	insert new_authorized_apt_list;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding misc apts for this block. Please contact IT for help'));
        ApexPages.addMessages(e);	
  	  }
  	}
  }
  
  public List<CR_Sched_Block_Authorized_Apt__c> getblock_apts() {
  	return [Select c.Clinical_Appointment__c, c.CR_Schedule_Block__c,c.clinical_appointment__r.name From CR_Sched_Block_Authorized_Apt__c c 
  	  where CR_schedule_block__c = :new_block.id order by clinical_appointment__r.name];
  }
  
  public void remove_apt_authorization() {
  	try {
  	  CR_Sched_Block_Authorized_Apt__c remove_apt = [select id from CR_Sched_Block_Authorized_Apt__c where id = :activation_id];
  	  delete remove_apt;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the appointment authorization. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void confim_activation_block() {
  	modal_display = true;
  	CR_Schedule_Block__c cb = [select id,isactive__c,name from CR_Schedule_Block__c where id=:activation_id];
  	modal_out = 'You are about to ' + (cb.isactive__c==true?'deactivate':'activate') + ' this scheduling block.';
  }
  
  public void update_activation_block() {
  	try {  	  
  	  CR_Schedule_Block__c cb = [select calendar_label__c,id,isactive__c,name,start_time__c,end_time__c from CR_Schedule_Block__c where id=:activation_id];
  	  Integer num_issues = 0;  	  
  	  if(cb.isactive__c==true)
  	  //no need to check for a dupe here 
  	    cb.isactive__c = false;  	    
  	  else {
  	    cb.isactive__c = true;
  	    Integer shour = Integer.valueof(cb.start_time__c.left(2).replace(':',''));
	  	if(cb.start_time__c.right(2)=='PM' && shour!=12)
	  	  shour+=12;  	    	
	  	Integer sminute = Integer.valueof(cb.start_time__c.right(5).replace(' AM','').replace(' PM','')); 	  
	  	Integer ehour = Integer.valueof(cb.end_time__c.left(2).replace(':',''));
	  	if(cb.end_time__c.right(2)=='PM' && ehour!=12)
	  	  ehour+=12;  	    	 	  
	  	Integer eminute = Integer.valueof(cb.end_time__c.right(5).replace(' AM','').replace(' PM',''));
  	    //make sure we don't have an active existing block on the schedule that overlaps with this one
  	    //check for a start time between our times
  	    Integer block_count = 0;  	    
  	    if(new_block.id==null)
  	      block_count += [Select count() From CR_Schedule_Block__c where (start_hour_int__c > :shour or (start_hour_int__c = :shour and start_minute_int__c > :sminute)) and (start_hour_int__c < :ehour or (start_hour_int__c = :ehour and start_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and isactive__c = true];
  	    else
  	      block_count += [Select count() From CR_Schedule_Block__c where (start_hour_int__c > :shour or (start_hour_int__c = :shour and start_minute_int__c > :sminute)) and (start_hour_int__c < :ehour or (start_hour_int__c = :ehour and start_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and id != :new_block.id and isactive__c = true];
  	    //check for an end time between out times
  	    if(new_block.id==null)
  	      block_count += [Select count() From CR_Schedule_Block__c where (end_hour_int__c > :shour or (end_hour_int__c = :shour and end_minute_int__c > :sminute)) and (end_hour_int__c < :ehour or (end_hour_int__c = :ehour and end_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and isactive__c = true];
  	    else
  	      block_count += [Select count() From CR_Schedule_Block__c where (end_hour_int__c > :shour or (end_hour_int__c = :shour and end_minute_int__c > :sminute)) and (end_hour_int__c < :ehour or (end_hour_int__c = :ehour and end_minute_int__c < :eminute)) and dow__c = :new_block.dow__c and clinical_room__c = :new_block.clinical_room__c and id != :new_block.id and isactive__c = true];
  	    if(block_count>0) {
  	      num_issues++;
  	      modal_out += '<br /><span style="color:red;font-style:italic;">There is already a block on the schedule that covers part of this time.  Blocks are not allowed to overlap.</span>';
  	    }
  	  }
  	  if(num_issues==0) {
  	  	modal_display = false;  	   	  	      
  	    update cb;
  	    activation_id = null;
  	    modal_out = '';
  	  }
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this scheduling block. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void close_modal() {
  	modal_display = false;  	
  }  
  
  public List<Selectoption> getform_type_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('na','Select One'));
  	for(Schema.PicklistEntry Value : Clinical_Appointment__c.clinical_notes_form__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }
	return clist;
  }      
  
  public void add_all_form_appointments() {
  	System.debug('Form Type : ' + apexpages.currentpage().getparameters().get('ftype'));
  	if((apexpages.currentpage().getparameters().get('ftype')==null?'na':apexpages.currentpage().getparameters().get('ftype'))=='na')
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a form type in order to add appointments to this block'));
  	else {
  	  Set<ID> existing_ca_list = new Set<ID>();
  	  for(CR_Sched_Block_Authorized_Apt__c csb : getblock_apts()) {
  	    existing_ca_list.add(csb.clinical_appointment__c);  	  
  	  }
  	  List<Clinical_Appointment__c> new_appointments = [select id,name from Clinical_Appointment__c where clinical_notes_form__c = :apexpages.currentpage().getparameters().get('ftype') and isactive__c = true
  	    and center_information__c = :current_center.id and id not in :existing_ca_list];
  	  List<CR_Sched_Block_Authorized_Apt__c> new_authorized_apt_list = new List<CR_Sched_Block_Authorized_Apt__c>();
  	  for(Clinical_Appointment__c ca : new_appointments) {
  	    CR_Sched_Block_Authorized_Apt__c csba = new CR_Sched_Block_Authorized_Apt__c(CR_Schedule_Block__c = new_block.id, Clinical_Appointment__c = ca.id);
  	    new_authorized_apt_list.add(csba);  	
  	  }
  	  if(new_authorized_apt_list.size()>0) {
  	    try {
  	  	  insert new_authorized_apt_list;
  	  	  selected_form_type = '';
  	    } catch (Exception e) {
  	      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding apts for this block. Please contact IT for help'));
          ApexPages.addMessages(e);	
  	    }
  	  }     	
  	}
  }
  
}