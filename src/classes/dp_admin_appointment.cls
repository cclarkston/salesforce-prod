public with sharing class dp_admin_appointment {
  /*standard backend admin fields*/
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
  //public String modal_type {get; set;}
  public String modal_out {get; set;}
  public String activation_id {get; set;}
  
  public String custom_color_selection {get;set;}
  
  /*controller specific backend fields*/  
  public Boolean display_appointment_form {get;set;}
  public String last_insert {get; set;}
  public Clinical_Appointment__c new_appointment {get; set;}  
  public Boolean display_procedure_form {get; set;}
  public String new_proc_name {get; set;}
  public Boolean display_padding_form {get; set;} 
  public Boolean display_lab_time_form {get; set;}
  public Boolean display_notes_form {get; set;}
  public Boolean display_arch_count_form {get; set;}
  public String category_filter {get; set;}
  public String procedure_filter {get; set;}
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
 
  public class bendException extends Exception {}
    
  public dp_admin_appointment() {  	
  	modal_display = false;
  	category_filter = 'All';
  	last_insert = '';
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
  	//see if it's a corporate admin
  	Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  	current_page = [Select Id, Name, Nav_Color__c, Page_URL__c From Navigation_Page__c where name = 'Appointments'];  	
  	//hide_appointment_form();
  	//hide_procedure_form();
  	display_all_appointments();  	
  	activation_id = '';
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
  
  public void change_category_filter() {
  	try {
  	  category_filter = apexpages.currentpage().getparameters().get('cfilter');
  	  if(category_filter==null)
  	     throw new bendException('No active value was detected');
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
  
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c,sales_region__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  quick_search_field = '';
  	  display_all_appointments();
  	  //hide_appointment_form();  	  
      hide_procedure_form();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public void back_to_appointments() {
  	display_all_appointments();
  	//get the procedure we were looking at,  to scroll into view
  	last_insert = new_appointment.id;
  }
  
  public void display_all_appointments() {
  	hide_appointment_form();
  	display_qsearch = true;
  	display_add_button = true;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'appointment_display';
  	display_active_nav = true;
  	body_header = '';
  	current_edit = null;
  }
  
  public Clinical_Appointment__c getcurrent_appointment_info(String apt_id) {
  	return [Select c.lab_days_before__c,c.isactive__c, c.isSurgery__c, c.isrepair__c, c.isProsth_Exam__c, c.isFinal_Delivery__c, c.SystemModstamp, c.Padding_Time__c, c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.Lab_Time__c, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Notes_Form__c, c.Center_Information__c, c.Appointment_Filter__c, c.Appointment_Description__c, c.arch_count__c, c.calendar_color__c, c.highlight_text_color__c, c.text_color__c, c.doctor_time_color__c, c.border_color__c
  	 From Clinical_Appointment__c c where id = :apt_id];
  }
  
  public void display_room_info() {
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'room_display';
  	display_active_nav = false;
  	body_header = '';
  	try {
  	  new_appointment = getcurrent_appointment_info(apexpages.currentpage().getparameters().get('aptid'));
  	  body_header = new_appointment.name + ' - Room Authorization';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the room info for this appointment.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_doctor_info() {  	
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'doctor_display';
  	display_active_nav = false;
  	body_header = '';
  	try {
  	  new_appointment = getcurrent_appointment_info(apexpages.currentpage().getparameters().get('aptid'));
  	  body_header = new_appointment.name + ' - Doctor Authorization';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the doctor info for this appointment.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }  
  
  public void display_scheduling_info() {
  	hide_procedure_form();
  	display_padding_form = false;
  	display_lab_time_form = false;
  	display_arch_count_form = false;
  	display_notes_form = false;
  	display_qsearch = true;
  	display_add_button = true;
  	quick_search_field = '';
  	display_active_nav = false;
  	selected_view = 'scheduling_display';
  	custom_color_selection = 'NA';
  	try {
  	  new_appointment = getcurrent_appointment_info(apexpages.currentpage().getparameters().get('aptid'));
  	  body_header = new_appointment.name + ' - Scheduling';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the scheduling info for this appointment.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
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
  
  public void edit_clinical_appointment() {
  	try {
  	  display_appointment_form = false;
  	  new_appointment = getcurrent_appointment_info(current_edit);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the appointment info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public integer gettotal_apt_time() {
  	Double ttime = 0;
  	for(Clinical_Apt_Procedure__c cap : getprocedure_steps()) {
  	  ttime += cap.clinical_procedure__r.time_required__c;
  	}
  	return ttime.intValue();
  }
  
  public List<Clinical_Apt_Procedure__c> getprocedure_steps() {
  	List<Clinical_Apt_Procedure__c> cap_list;
  	try {
  	 cap_list = [Select c.Sort_Order__c, c.Id, c.Clinical_Procedure__r.name, c.Clinical_Appointment__c, c.clinical_procedure__r.time_required__c From Clinical_Apt_Procedure__c c where c.Clinical_Appointment__c =:new_appointment.id order by sort_order__c];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the procedures for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);			
  	}
  	return cap_list;
  }
  
  public List<Clinical_Procedure__c> getsearch_procedures() {
  	List<Clinical_Procedure__c> cp_list;
  	try {
  	  String query_filter = ' where center_information__c = \'' + current_center.id + '\' and isactive__c = true ';
  	  if(new_proc_name!=null)
  	    if(new_proc_name != 'Enter procedure')
  	      query_filter += ' and (name like \'%' + new_proc_name + '%\' or procedure_description__c like \'%' + new_proc_name + '%\')  ';
  	  if(procedure_filter!='All')
  	    query_filter += ' and procedure_filter__c = \'' + procedure_filter + '\' ';
  	  cp_list = database.query('select id,name,procedure_description__c from clinical_procedure__c ' + query_filter + ' order by name');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical procedures for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  	return cp_list;
  }
  
  public List<Clinical_Appointment__c> getprosth_list() {
  	String qfilter = ' where center_information__c = \'' + current_center.id + '\' and c.appointment_filter__c = \'Prosth\'  ';        
    return getappointment_list(qfilter);
  }
  
  public List<Clinical_Appointment__c> getsurgical_list() {
  	String qfilter = ' where center_information__c = \'' + current_center.id + '\' and c.appointment_filter__c = \'Surgical\'  ';        
    return getappointment_list(qfilter);
  }
  
  public List<Clinical_Appointment__c> getmisc_list() {
  	String qfilter = ' where center_information__c = \'' + current_center.id + '\' and c.appointment_filter__c = \'Misc\'  ';        
    return getappointment_list(qfilter);
  }  
    
  public List<Clinical_Appointment__c> getappointment_list(String query_filter) {
    List<Clinical_Appointment__c> ca_list;
    try {
      //String query_filter = ' where center_information__c = \'' + current_center.id + '\' ';
  	  if(active_filter=='Active')
  	    query_filter += ' and isactive__c = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and isactive__c = false ';
  	  if(category_filter!='All')
  	    query_filter += ' and c.appointment_filter__c = \'' + category_filter  + '\'';
  	  if((quick_search_field==null?'':quick_search_field) != '') 
  	  	query_filter += ' and (name like \'%' + quick_search_field + '%\' or appointment_description__c like \'%' + quick_search_field + '%\')  ';
  	  ca_list = database.query('Select c.lab_time__c,c.isactive__c, c.Padding_Time__c, c.Name, c.Center_Information__c, c.Appointment_Description__c From Clinical_Appointment__c c ' + query_filter + ' order by isactive__c desc, name');    	
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical appointments for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
    }    
    return ca_list;
  }
  
  public List<Selectoption> getprocedure_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	for(Schema.PicklistEntry Value : Clinical_Procedure__c.procedure_filter__c.getDescribe().getPicklistValues() ) {
      clist.add(new Selectoption(value.getValue(),value.getLabel()));
    }  	
	return clist;
  }  
  
  public void new_procedure_form() {
  	display_procedure_form = true;
  	new_proc_name = 'Enter procedure';
  	procedure_filter = 'All';
  }
  
  public void new_appointment_form() {
  	display_appointment_form = true;
  	current_edit = null;
  	new_appointment = new Clinical_Appointment__c(name = 'Enter Apt Name', appointment_description__c = 'Enter Apt Description', isactive__c = true, center_information__c = current_center.id, padding_time__c = 0, lab_time__c = 0);
  }    
  
  public void reset_procedure_form() {
  	new_proc_name = 'Enter procedure';
  	procedure_filter = 'All';
  }
  
  public void reset_appointment_form() {
  	new_appointment = new Clinical_Appointment__c(name = 'Enter Apt Name', appointment_description__c = 'Enter Apt Description', isactive__c = true, center_information__c = current_center.id, padding_time__c = 0, lab_time__c = 0);
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
  	  	Clinical_Procedure__c cp = [select id from Clinical_Procedure__c where name = :new_proc_name and center_information__c = :current_center.id and isactive__c = true];	
  	    //grab the current max sort order
  	    AggregateResult ar = database.query('select max(sort_order__c) msort from Clinical_Apt_Procedure__c where clinical_appointment__c = \'' + new_appointment.id + '\'');
  	    Integer max_sort = 0;
  	    if(ar.get('msort')!=null) {
  	      Decimal msort = (decimal)ar.get('msort'); 
  	      max_sort = msort.intValue();
  	    }  	    	
  	    //create and insert record
  	    Clinical_Apt_Procedure__c new_cap = new Clinical_Apt_Procedure__c(Clinical_Appointment__c = new_appointment.id, Clinical_Procedure__c = cp.id, sort_order__c = (max_sort + 1));
  	    insert new_cap;
  	    hide_procedure_form();
  	    last_insert=new_cap.id;
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the procedure. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void save_new_appointment() {
  	last_insert = null;
  	Integer num_issues = 0;
  	if(new_appointment.name==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a name for the appointment'));  	  
  	} else if(new_appointment.name=='Enter Apt Name') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a name for the appointment'));
  	}
  	if(new_appointment.appointment_description__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a description for the appointment'));
  	} else if(new_appointment.appointment_description__c=='Enter Apt Description') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a description for the appointment'));
  	}  	
  	if(new_appointment.appointment_filter__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select ca category for the appointment'));
  	}
  	//check to see if a procedure with this name already exists at the center
  	Integer pcount = [select count() from Clinical_Appointment__c where name = :new_appointment.name and center_information__c = :new_appointment.center_information__c and id!=:new_appointment.id];
  	if(pcount>0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An appointment with that name already exists for this center.  Please use a unique name to continue'));
  	}
  	if(num_issues == 0) {
  	  try {
  	  	if(current_edit==null)
  	      insert new_appointment;
  	    else
  	      update new_appointment;
  	    last_insert = new_appointment.id;
  	    display_appointment_form = false;
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the appointment. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
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
  
  public Integer getall_count() {
  	Integer record_count = 0;
  	if(selected_view=='appointment_display')
  	  record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id];  	
  	return record_count;
  }
  
  public Integer getactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='appointment_display')
  	  record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id and isactive__c = true]; 	
  	return record_count;
  }
  
  public Integer getinactive_count() {
  	Integer record_count = 0; 
    if(selected_view=='appointment_display')
  	  record_count = [select count() from Clinical_Appointment__c where center_information__c = :current_center.id and isactive__c = false]; 
  	return record_count;
  }
      
  public void hide_appointment_form() { 
  	display_appointment_form = false; 	
    current_edit = null;
  }
  
  public void hide_procedure_form() {
  	display_procedure_form = false;
  	current_edit = null;
  }
  
  public void confim_activation_appointment() {
  	modal_display = true;
  	Clinical_Appointment__c a = [select id,isactive__c,name from Clinical_Appointment__c where id=:activation_id];
  	modal_out = 'You are about to ' + (a.isactive__c==true?'deactivate':'activate') + ' appointment - ' + a.name;
  }
  
  public void update_activation_appointment() {
  	try {
  	  modal_display = false;  	  
  	  Clinical_Appointment__c a = [select id,isactive__c,name from Clinical_Appointment__c where id=:activation_id];
  	  if(a.isactive__c==true)
  	    a.isactive__c = false;
  	  else
  	    a.isactive__c = true;
  	  update a;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this Appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void modify_sort_order() {
  	try {
  	  String pass_thru = apexpages.currentpage().getparameters().get('pthru');
      pass_thru = pass_thru.replace('list[]=','');
      //System.debug('pass thru : ' + pass_thru);
      pass_thru = pass_thru.replace('name','');
      //System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      //System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      List<Clinical_apt_procedure__c> cap_list = new List<Clinical_Apt_Procedure__c>();
      for(String my_id : pass_array) {
      	Clinical_Apt_Procedure__c cap = [select id,sort_order__c from Clinical_Apt_Procedure__c where id = :my_id];
      	cap.sort_order__c = sort_order;
      	cap_list.add(cap);
      	sort_order++;
      }
      update cap_list;      
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessages(e);	
    }  
  }
  
  public void confim_remove_procedure() {
  	modal_display = true;
  	Clinical_Apt_Procedure__c p = [select id,clinical_procedure__r.name from Clinical_Apt_Procedure__c where id=:activation_id];
  	modal_out = 'You are about to remove procedure - ' + p.clinical_procedure__r.name + ' from this appointment';
  }
  
  public void edit_padding() {
  	display_padding_form = true;
  }
  
  public void hide_padding_form() {
  	reset_padding_form();
  	display_padding_form = false;
  }
  
  public void reset_padding_form() {  	
    new_appointment = getcurrent_appointment_info(new_appointment.id);
  }
  
  public void save_notes_form() {
  	try {
  	  update new_appointment;
  	  hide_padding_form();
  	  hide_lab_time_form();
  	  hide_notes_form();
  	} catch (Exception e) {
  	  new_appointment.padding_time__c.adderror('There was an error updating the appointment');
  	  //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating padding info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void save_padding_form() {
  	try {
  	  update new_appointment;
  	  hide_padding_form();
  	  hide_lab_time_form();
  	  hide_notes_form();
  	  toggle_arch_count_display();
  	} catch (Exception e) {
  	  new_appointment.padding_time__c.adderror('There was an error updating the appointment');
  	  //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating padding info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void edit_lab_time() {
  	display_lab_time_form = true;
  }
  
  public void toggle_arch_count_display() {
  	display_arch_count_form = (display_arch_count_form?false:true);
  }
  
  public void edit_notes_form() {
  	display_notes_form = true;
  }
  
  public void hide_lab_time_form() {
  	reset_padding_form();
  	display_lab_time_form = false;
  }    
  
  public void hide_notes_form() {
  	reset_padding_form();
  	display_notes_form = false;
  }
  
  public List<Clinical_DR_Authorized_Apt__c> getauthorized_doctors() {
  	List<Clinical_DR_Authorized_Apt__c> docs;
    try {
      String query_filter = ' where clinical_appointment__c = \'' + new_appointment.id + '\'';
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and c.doctor__r.name like \'%' + quick_search_field + '%\' ';
  	  }          	
      docs = database.query('Select Id, c.doctor__r.name, c.doctor__c, c.clinical_appointment__c From Clinical_DR_Authorized_Apt__c c ' + query_filter + ' order by c.doctor__r.name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up authorized doctors.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return docs;
  }
  
  public List<User> getblocked_doctors() {
  	//modified by cm on 8/9/2017 - doctor list should now use user_center_assignment to build a list of eligible folks
  	Set<ID> possible_users = new Set<ID>();
  	for(User_Center_Assignment__c uca : [select id,user__c,center_information__c from User_Center_Assignment__c where center_information__r.market__c = :current_center.market__c]) {
  	  possible_users.add(uca.user__c);	
  	}  	
  	List<User> docs;
    try {
      //String query_filter = ' where u.Profile.name in (\'Clinical Doctor\',\'SF - Clinical Doctor\') and isactive = true and u.clinic_calendar__c  = \'' + current_center.name + '\' and id not in (';
      String query_filter = ' where u.Profile.name in (\'Clinical Doctor\',\'SF - Clinical Doctor\') and isactive = true and u.id in :possible_users and id not in (';
  	  for(Clinical_DR_Authorized_Apt__c ca : getauthorized_doctors()) {
  	    query_filter += '\'' + ca.doctor__c + '\',';
  	  }  
  	  query_filter += '\'\') '; 
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and u.name like \'%' + quick_search_field + '%\' ';
  	  }          	
      docs = database.query('Select Id, name From User u ' + query_filter + ' order by u.name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up non-authorized doctors.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return docs;
  }
  
  public void authorize_doctor() {
  	try {
  	  Clinical_DR_Authorized_Apt__c cda = new Clinical_DR_Authorized_Apt__c(Clinical_Appointment__c = new_appointment.id, Doctor__c = activation_id);
  	  insert cda;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error authorizing access to this doctor. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  	
  }
  
  public void block_doctor() {
  	try {
  	  Clinical_DR_Authorized_Apt__c cda = [select id from Clinical_DR_Authorized_Apt__c where id = :activation_id];
  	  delete cda;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing access for this doctor. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public List<Clinical_Room_Authorized_Apt__c> getauthorized_rooms() {
  	List<Clinical_Room_Authorized_Apt__c> rooms;
    try {
      String query_filter = ' where clinical_appointment__c = \'' + new_appointment.id + '\'';
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and c.clinical_room__r.name like \'%' + quick_search_field + '%\' ';
  	  }          	
      rooms = database.query('Select c.Id, c.Clinical_Room__c, c.clinical_room__r.name, c.Clinical_Appointment__c From Clinical_Room_Authorized_Apt__c c ' + query_filter + ' order by c.clinical_room__r.name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up authorized rooms.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return rooms;
  }
  
  public List<Clinical_Room__c> getblocked_rooms() {
  	List<Clinical_Room__c> rooms;
    try {
      String query_filter = ' where center_information__c  = \'' + current_center.id + '\' and id not in (';
  	  for(Clinical_Room_Authorized_Apt__c cr : getauthorized_rooms()) {
  	    query_filter += '\'' + cr.clinical_room__c + '\',';
  	  }  
  	  query_filter += '\'\') '; 
      if((quick_search_field==null?'':quick_search_field) != '') {
  	  	query_filter += ' and name like \'%' + quick_search_field + '%\' ';
  	  }          	
  	  System.debug('Room query : Select Id, name From Clinical_Room__c ' + query_filter + ' order by name');
      rooms = database.query('Select Id, name From Clinical_Room__c ' + query_filter + ' order by name');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up non-authorized rooms.  Please contact IT for help'));
      ApexPages.addMessages(e);
    }    
    return rooms;
  }
  
  public void authorize_room() {
  	try {
  	  Clinical_Room_Authorized_Apt__c cra = new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = new_appointment.id,Clinical_Room__c = activation_id);
  	  insert cra;
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error authorizing access to this room. Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}
  }
  
  public void block_room() {
  	try {
  	  Clinical_Room_Authorized_Apt__c cra = [select id from Clinical_Room_Authorized_Apt__c where id = :activation_id];
  	  delete cra;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing access for this room. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void authorize_all_rooms() {
  	try {
  	  List<Clinical_Room_Authorized_Apt__c> cra_list = new List<Clinical_Room_Authorized_Apt__c>();
  	  for(Clinical_Room__c cr : getblocked_rooms()) {
  	  	Clinical_Room_Authorized_Apt__c cra = new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = new_appointment.id,Clinical_Room__c = cr.id);
  	  	cra_list.add(cra);
  	  }
  	  if(cra_list.size()>0)
  	    insert cra_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding access for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void block_all_rooms() {
  	try {
  	  List<Clinical_Room_Authorized_Apt__c> cra_list = getauthorized_rooms();
  	  delete cra_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing access for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  	
  }
  
  public void delete_appointment_procedure() {
  	try {
  	  modal_display = false;  	  
  	  Clinical_Apt_Procedure__c p = [select id from Clinical_Apt_Procedure__c where id=:activation_id];
  	  delete p;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the procedure from this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void close_modal() {
  	modal_display = false;  	
  }
  
  public void toggle_repair() {
  	if(new_appointment.isrepair__c)
  	  new_appointment.isrepair__c = false;
  	else {
  	  new_appointment.isrepair__c = true;
  	  new_appointment.isfinal_delivery__c = false;
  	  new_appointment.isprosth_exam__c = false;
      new_appointment.issurgery__c = false;
  	}
  	
  	try {
  	  update new_appointment;	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the status for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void toggle_final_delivery() {
  	if(new_appointment.isfinal_delivery__c)
  	  new_appointment.isfinal_delivery__c = false;
  	else {
  	  new_appointment.isfinal_delivery__c = true;
  	  new_appointment.isprosth_exam__c = false;
      //new_appointment.issurgery__c = false;
      //new_appointment.isrepair__c = false;
  	}
  
  	try {
  	  update new_appointment;	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the status for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }      
  
  public void toggle_surgery() {
  	if(new_appointment.issurgery__c)
  	  new_appointment.issurgery__c = false;
  	else {
  	  new_appointment.issurgery__c = true;
  	  new_appointment.isprosth_exam__c = false;
      //new_appointment.isfinal_delivery__c = false;
      //new_appointment.isrepair__c = false;
  	}
  
  	try {
  	  update new_appointment;	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the status for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void toggle_prosth_exam() {  
  	if(new_appointment.isprosth_exam__c)
  	  new_appointment.isprosth_exam__c = false;
  	else {
  	  new_appointment.isprosth_exam__c = true;
  	  new_appointment.issurgery__c = false;
      new_appointment.isfinal_delivery__c = false;
      new_appointment.isrepair__c = false;
  	}
  		  	
  	try {
  	  update new_appointment;	
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the status for this appointment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public List<Selectoption> getcolor_grouping_options() {
  	List<Selectoption> color_list = new List<Selectoption>();
  	color_list.add(new Selectoption('NA','Custom Color Scheme'));
  	color_list.add(new Selectoption('0','Banana Cream'));
  	color_list.add(new Selectoption('1','Underripe Apple'));
  	color_list.add(new Selectoption('2','Ocean Wave'));
  	color_list.add(new Selectoption('3','Lawn Clippings'));
  	color_list.add(new Selectoption('4','Cool Gray'));
  	color_list.add(new Selectoption('5','Orange You Glad'));
  	color_list.add(new Selectoption('6','Rockies Purple'));
  	color_list.add(new Selectoption('7','Baseball Glove'));
  	color_list.add(new Selectoption('8','Overripe Apple'));
  	color_list.add(new Selectoption('9','Dark City'));
  	color_list.add(new Selectoption('10','Kraken'));   	
  	return color_list;
  }
  
  public class custom_color {
  	public String background_color {get;set;}
  	public String doctor_time_color {get;set;}
  	public String border_color {get;set;}
  	public String text_color {get;set;}
  	public String highlight_color {get;set;}
  	
  	public custom_color(String bg, String doc_time, String border, String textc, String hcolor) {
  	  this.background_color = bg;
  	  this.doctor_time_color = doc_time;
  	  this.border_color = border;
  	  this.text_color = textc;
  	  this.highlight_color = hcolor;
  	}  	  	
  }
  
  public static List<custom_color> custom_colors = new List<custom_color> {
    new custom_color('fcfbd4','e8e57b','000000','000000','0a66e0'),
    new custom_color('fcd4d4','ff8383','000000','000000','0a66e0'),
    new custom_color('e6fcfc','a5eff9','000000','000000','0a66e0'),
    new custom_color('d4fce7','9df1a3','000000','000000','0a66e0'),
    new custom_color('e0e0e0','c4c4c4','000000','000000','0a66e0'),
    new custom_color('f5be80','faa13c','000000','000000','0a66e0'),
    new custom_color('e7cdfc','c0abdb','000000','000000','0a66e0'),
    new custom_color('e8e8e8','dbd9ca','000000','000000','0a66e0'),
    new custom_color('eb8888','de3e3e','000000','000000','0a66e0'),
    new custom_color('474747','707070','141414','ffffff','fa8a00'),
    new custom_color('abd3fc','3968b1','141414','ffffff','0a66e0')
  };
  
  public void apply_custom_schema() {
  	if(apexpages.currentpage().getparameters().get('cschema')!='NA') {
  	  custom_color selected_schema = custom_colors[Integer.valueof(apexpages.currentpage().getparameters().get('cschema'))];
  	  new_appointment.calendar_color__c = selected_schema.background_color;
  	  new_appointment.doctor_time_color__c = selected_schema.doctor_time_color;
  	  new_appointment.border_color__c = selected_schema.border_color;
  	  new_appointment.text_color__c = selected_schema.text_color;
  	  new_appointment.highlight_text_color__c = selected_schema.highlight_color;
  	}
  }
  
  public string getdays_out_text() {
  	String output_text = 'Lab Days Before : ';
  	if(new_appointment.lab_days_before__c==null)
  	  output_text += 'N/A';
  	else
  	  output_text += new_appointment.lab_days_before__c + ' day(s)';
  	return output_text;
  }
}