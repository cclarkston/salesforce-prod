public with sharing class dp_admin_pot {
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
  public String modal_type {get; set;}
  public String modal_out {get; set;}
  public String activation_id {get; set;}
  
  public Boolean display_pot_form {get;set;}
  public Boolean display_apt_form {get;set;}
  public String last_insert {get;set;}
  public Plan_of_Treatment__c new_pot {get; set;}
  public String clone_id {get; set;}
  public String pot_id {get; set;}
  public Plan_Of_treatment__c selected_plan {get; set;}
  public String new_apt_name {get; set;}
  public String apt_filter {get; set;}
  public POT_Appointment__c new_apt_detail {get; set;}
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
  
  public class bendException extends Exception {}
  
  public class pot_parent {
  	public String parent_name {get;set;}
  	public List<Plan_of_Treatment__c> tplans {get;set;}
  	public Boolean is_standard_plan {get;set;}
  	
  	public pot_parent(String my_name, Boolean splan) {
  	  this.parent_name = my_name;
  	  this.is_standard_plan = splan;
  	  tplans = new List<Plan_of_Treatment__c> ();
  	}
  }
  
  public dp_admin_pot() {
  	modal_display = false;
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
  	current_page = [Select Id, Name, Nav_Color__c, Page_URL__c From Navigation_Page__c where name = 'Plans of Treatment'];  	
  	display_all_pot();  	
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
  	  display_all_pot();  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
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
  
  public void display_apt_detail() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'apt_detail_display';
  	display_active_nav = false;
  	hide_apt_form();
  	try {
      selected_plan = [Select p.Treatment_Description__c, p.Name, p.Doctor__c,p.doctor__r.name,p.Id,p.Center_Information__c,upper_arch__c,lower_arch__c From Plan_of_Treatment__c p where id = :pot_id];
  	  body_header = selected_plan.name + ' - Appointment Detail';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the info for this treatment plan.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}  	
  }  
  
  public void display_all_pot() {
  	hide_pot_form();
  	display_qsearch = true;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'pot_display';
  	display_active_nav = true;
  	body_header = '';
  	current_edit = null;
  }
  
  public void reset_apt_form() {
  	new_apt_name = 'Enter Appointment';
  	apt_filter = 'All';
  }
  
  public void hide_pot_form() { 
  	display_pot_form = false; 	
    current_edit = null;
    clone_id = null;
  }
  
  public void hide_apt_form() {
  	display_apt_form = false;
  	current_edit = null;
  	clone_id = null;
  }
  
  public Integer getall_count() {
  	Integer record_count = 0;
  	//Current plan is to display treatment plans for the center,  plus the standard treatment plans set up by corporate (identified by being under center unknown)
  	if(selected_view=='pot_display') {
  	  record_count = [select count() from Plan_of_Treatment__c where center_information__c = :current_center.id and center_information__r.name != 'Unknown'];  	  
  	  record_count += [select count() from Plan_of_Treatment__c where center_information__r.name = 'Unknown'];
  	}  	
  	return record_count;
  }
  
  public Integer getactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='pot_display') {
  	  record_count = [select count() from Plan_of_Treatment__c where center_information__c = :current_center.id and center_information__r.name != 'Unknown' and isactive__c = true];  	  
  	  record_count += [select count() from Plan_of_Treatment__c where center_information__r.name = 'Unknown' and isactive__c = true];
  	} 	
  	return record_count;
  }
  
  public Integer getinactive_count() {
  	Integer record_count = 0; 
    if(selected_view=='pot_display') {
  	  record_count = [select count() from Plan_of_Treatment__c where center_information__c = :current_center.id and center_information__r.name != 'Unknown' and isactive__c = false];  	  
  	  record_count += [select count() from Plan_of_Treatment__c where center_information__r.name = 'Unknown' and isactive__c = false];
    } 
  	return record_count;
  }
  
  public Boolean getdisplay_new_plan() {
  	//check to see if we're in center unknown and if there is an admin logged in
  	Center_Information__c ci = [select id,name from center_information__c where id = :current_center.id];
  	if(display_corp_admin && ci.name=='Unknown')
  	  return true;
  	else
  	  return false;
  }
  
  public String getdefault_plan_name(String apt_name) {
  	String pname = '';
  	if(getis_user_doctor())
  	  pname = userinfo.getname() + ' ' + apt_name;
  	else
  	  pname = apt_name;
  	return pname;
  }
  
  public Boolean getis_user_doctor() {
  	Integer dcount = [select count() from Profile where name in ('Clinical Doctor','SF - Clinical Doctor') and id = :userinfo.getprofileid()];
  	if(dcount>0)
  	  return true;
  	else
  	  return false;
  }
  
  public void clone_pot() {
  	display_pot_form = true;
  	Plan_Of_Treatment__c clone_pot = [select name,treatment_description__c,upper_arch__c,lower_arch__c from Plan_Of_Treatment__c where id = :clone_id];  	 
  	new_pot = new Plan_Of_Treatment__c(name = getdefault_plan_name(clone_pot.name), treatment_description__c = clone_pot.treatment_description__c, center_information__c = current_center.id, isactive__c = true, Cloned_Plan_of_Treatment__c  = clone_pot.id, upper_arch__c = clone_pot.upper_arch__c, lower_arch__c = clone_pot.lower_arch__c);
  	if(getis_user_doctor())
  	  new_pot.doctor__c = userinfo.getuserid();  	
  	current_edit = null;
  }
  
  public List<Selectoption> getapt_category_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('All','All'));
  	clist.add(new Selectoption('Prosth','Prosth'));
  	clist.add(new Selectoption('Surgical','Surgical'));
  	clist.add(new Selectoption('Misc','Misc'));
	return clist;
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
  
  public List<POT_Appointment__c> getappointment_details() {
  	List<POT_Appointment__c> apt_list;
  	try {
  	 apt_list = [Select p.Sort_Order__c, p.Plan_of_Treatment__c, p.Id, p.Days_Out__c, p.Clinical_Appointment__c, p.Clinical_Appointment__r.name From POT_Appointment__c p where p.Plan_of_treatment__c =:selected_plan.id order by sort_order__c];  	 
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the appointments for this treatment plan. Please contact IT for help'));
      ApexPages.addMessages(e);			
  	}
  	return apt_list;
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
  	  	Clinical_Appointment__c ca = [select id from Clinical_Appointment__c where name = :new_apt_name and center_information__c = :current_center.id and isactive__c = true];	
  	    //grab the current max sort order
  	    AggregateResult ar = database.query('select max(sort_order__c) msort from POT_Appointment__c where plan_of_treatment__c = \'' + selected_plan.id + '\'');
  	    Integer max_sort = 0;
  	    if(ar.get('msort')!=null) {
  	      Decimal msort = (decimal)ar.get('msort'); 
  	      max_sort = msort.intValue();
  	    }  	    	
  	    //create and insert record
  	    POT_Appointment__c new_pot_detail = new POT_Appointment__c(Plan_Of_Treatment__c = selected_plan.id, Clinical_Appointment__c = ca.id, days_out__c = 0, sort_order__c = (max_sort + 1));
  	    insert new_pot_detail;
  	    hide_apt_form();
  	    last_insert=new_pot_detail.id;
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the appointment. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void new_apt_form() {
  	display_apt_form = true;
  	new_apt_name = 'Enter Appointment';
  	apt_filter = 'All';
  }
  
  public void new_pot_form() {
  	display_pot_form = true;
  	new_pot = new Plan_Of_Treatment__c(name = 'Enter Plan Name', treatment_description__c = 'Enter Plan Description', center_information__c = current_center.id, isactive__c = true, upper_arch__c = 'None', lower_arch__c = 'None');
  	if(getis_user_doctor())
  	  new_pot.doctor__c = userinfo.getuserid();
  	current_edit = null;
  }
  
  public void reset_pot_form() {
  	if(clone_id!=null)
  	  clone_pot();  
  	else
  	  new_pot = new Plan_Of_Treatment__c(name = 'Enter Plan Name', treatment_description__c = 'Enter Plan Description', center_information__c = current_center.id, isactive__c = true);
  }    
  
  public pot_parent[] getpot_list() {
  	pot_parent[] pot_list = new pot_parent[] {};
    try {
      String standard_filter = ' where center_information__r.name = \'Unknown\' ';
      String query_filter = ' where center_information__c = \'' + current_center.id + '\' ';
  	  if(active_filter=='Active') {
  	    query_filter += ' and isactive__c = true ';
  	    standard_filter += ' and isactive__c = true ';
  	  }
  	  else if(active_filter=='Inactive') {
  	    query_filter += ' and isactive__c = false ';
  	    standard_filter += ' and isactive__c = false ';
  	  }
  	  if((quick_search_field==null?'':quick_search_field) != '') { 
  	  	query_filter += ' and (name like \'%' + quick_search_field + '%\' or treatment_description__c like \'%' + quick_search_field + '%\')  ';
  	  	standard_filter += ' and (name like \'%' + quick_search_field + '%\' or treatment_description__c like \'%' + quick_search_field + '%\')  ';
  	  }
  	  String doctor_name = '';
  	  pot_parent pp;
  	  //work through plans for the selected center
  	  for(Plan_of_Treatment__c pt : database.query('Select p.isActive__c, p.Treatment_Description__c, p.Name, p.Id, p.Doctor__c, p.doctor__r.name, p.Center_Information__c, p.upper_arch__c, p.lower_arch__c From Plan_of_Treatment__c p  ' + query_filter + ' order by doctor__r.name, isactive__c desc, name')) {
  	  	if(pt.doctor__r.name!=doctor_name) {
  	  	  if(doctor_name!='')
  	        pot_list.add(pp);
  	  	  pp = new pot_parent(pt.doctor__r.name==null?'Non Doctor Assigned - Plans of Treatment':pt.doctor__r.name + ' - Plans of Treatment',false);
  	      doctor_name = pt.doctor__r.name;
  	  	}
  	  	pp.tplans.add(pt);
  	  }    	
  	  pot_list.add(pp);
  	  //work through standard treatment plans
  	  pp = new pot_parent('Standard Plans',true);
  	  for(Plan_of_Treatment__c pt : database.query('Select p.isActive__c, p.Treatment_Description__c, p.Name, p.Id, p.Doctor__c, p.doctor__r.name, p.Center_Information__c, p.upper_arch__c, p.lower_arch__c From Plan_of_Treatment__c p  ' + standard_filter + ' order by isactive__c desc, name')) {
  	  	pp.tplans.add(pt);
  	  }  
  	  pot_list.add(pp);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up plans of treatment for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
    }    
    return pot_list;
  }
  
  public void save_apt_detail() {
  	Integer num_issues = 0;
  	//make sure name is not blank
  	if(new_apt_detail.days_out__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for days out'));  	  
  	} else if(new_apt_detail.days_out__c<0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a positive value for days out'));
  	}
  	if(num_issues == 0) {
  	  try {  	  	
  	    update new_apt_detail;
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error update the appointment detail. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void save_new_pot() {
  	last_insert = null;
  	Integer num_issues = 0;
  	//make sure name is not blank
  	if(new_pot.name==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a name for the plan of treatment'));  	  
  	} else if(new_pot.name=='Enter Plan Name') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a name for the plan of treatment'));
  	}
  	//make sure description is not blank
  	if(new_pot.treatment_description__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a description for the plan of treatment'));
  	} else if(new_pot.treatment_description__c=='Enter Plan Description') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a description for the plan of treatment'));
  	}  	
  	//to-do:  when we figure out filter values - test for a blank
  
  	//make sure name is not already in user at the center or at the unknown center
  	//Integer pcount = [select count() from Plan_of_treatment__c where name = :new_pot.name and (center_information__c = :new_pot.center_information__c or center_information__r.name = 'Unknown') 
  	  //and id!=:new_pot.id];
  	//adjusting this to only check the existing center...it's fine to have a pot with the same name as the standard unknown plans
  	Integer pcount = [select count() from Plan_of_treatment__c where name = :new_pot.name and (center_information__c = :new_pot.center_information__c) 
  	  and id!=:new_pot.id];
  	if(pcount>0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A plan of treatment with that name already exists.  Please use a unique name to continue'));
  	}
  	if(num_issues == 0) {
  	  try {
  	  	if(current_edit==null)
  	      insert new_pot;
  	    else
  	      update new_pot;
  	    //check if this is a clone operation - if so copy pot details
  	    if(clone_id!=null) {
  	      List<POT_Appointment__c> pat_list = new List<POT_Appointment__c> ();
  	      //figure out if this is a clone of a plan in the selected center,  or if it's from a standard plan (meaning we need to map the clinical appointment stuff over)
  	      Plan_of_treatment__c p = [select id,center_information__c from Plan_of_treatment__c where id = :clone_id];
  	      if(p.center_information__c==current_center.id) {
  	        for(POT_Appointment__c pat : [Select p.Sort_Order__c, p.Plan_of_Treatment__c, p.Name, p.Days_Out__c, p.Clinical_Appointment__c From POT_Appointment__c p where plan_of_treatment__c = :clone_id]) {
    	      	POT_Appointment__c new_pat = new POT_Appointment__c(sort_order__c = pat.sort_order__c, plan_of_treatment__c = new_pot.id, days_out__c = pat.days_out__c, clinical_appointment__c = pat.clinical_appointment__c);
    	      	pat_list.add(new_pat); 
  	        }	
  	      }
  	      else {
  	      	//build a map of appointments in the current center,  so we can handle the translation as we work through all of the appointments
  	      	Map<String,Clinical_Appointment__c> apt_map = new Map<String,Clinical_Appointment__c>();
  	      	for(Clinical_Appointment__c ca : [select id,name from Clinical_Appointment__c where center_information__c = :current_center.id]) {
  	      	  apt_map.put(ca.name,ca);
  	      	}
  	      	for(POT_Appointment__c pat : [Select p.Sort_Order__c, p.Plan_of_Treatment__c, p.Name, p.Days_Out__c, p.Clinical_Appointment__r.name From POT_Appointment__c p where plan_of_treatment__c = :clone_id]) {
    	      POT_Appointment__c new_pat = new POT_Appointment__c(sort_order__c = pat.sort_order__c, plan_of_treatment__c = new_pot.id, days_out__c = pat.days_out__c);
    	      new_pat.clinical_appointment__c = apt_map.get(pat.clinical_appointment__r.name).id;
    	      pat_list.add(new_pat); 
  	        }	  	      	
  	      }  	      
  	      if(pat_list.size()>0)
  	        insert pat_list;
  	    }
  	    last_insert = new_pot.id;
  	    hide_pot_form();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the plan of treatment. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void edit_plan_of_treatment() {
  	try {
  	  display_pot_form = false;
  	  new_pot = [Select p.isActive__c, p.Treatment_Description__c, p.Name, p.Id, p.Doctor__c, p.doctor__r.name, p.Center_Information__c, p.upper_arch__c, p.lower_arch__c From Plan_of_treatment__c p where id= :current_edit];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the plan of treatment info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void confirm_activation_pot() {
  	modal_display = true;
  	Plan_of_Treatment__c pt = [select id,isactive__c,name,treatment_description__c from Plan_of_Treatment__c where id=:activation_id];
  	modal_out = 'You are about to ' + (pt.isactive__c==true?'deactivate':'activate') + ' POT - ' + pt.name;
  }
  
  public void confirm_activation_apt_detail() {
  	modal_display = true;
  	POT_Appointment__c ad = [Select id,Clinical_Appointment__r.name,Plan_of_Treatment__r.name from POT_Appointment__c where id =:activation_id];  	  	
  	modal_out = 'You are about to remove ' + ad.clinical_appointment__r.name + ' from POT - ' + ad.plan_of_treatment__r.name;
  }
  
  public void update_activation_pot() {
  	try {
  	  modal_display = false;  	  
  	  Plan_of_Treatment__c pt = [select id,isactive__c,name,treatment_description__c from Plan_of_Treatment__c where id=:activation_id];
  	  if(pt.isactive__c==true)
  	    pt.isactive__c = false;
  	  else
  	    pt.isactive__c = true;
  	  update pt;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this Plan of Treatment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void update_activation_apt_detail() {
  	try {
  	  modal_display = false;  	  
  	  POT_Appointment__c ad = [Select id,Clinical_Appointment__r.name,Plan_of_Treatment__r.name,plan_of_treatment__c from POT_Appointment__c where id =:activation_id];
  	  String pot_id = ad.plan_of_treatment__c;
  	  delete ad;
  	  activation_id = null;
  	  modal_out = '';
  	  //need to resort the pot_appointments here
  	  List<POT_Appointment__c> apt_detail = [select id,sort_order__c from POT_Appointment__c where plan_of_treatment__c = :pot_id order by sort_order__c];
  	  Integer sorder = 1;
  	  for(POT_Appointment__c apt : apt_detail) {
  	  	apt.sort_order__c = sorder;
  	  	sorder++;
  	  } 
  	  update apt_detail;
  	  
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing the appointment from the Plan of Treatment. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void edit_apt_detail() {
  	try {
  	  new_apt_detail = [Select p.Sort_Order__c, p.Plan_of_Treatment__c, p.Id, p.Days_Out__c, p.Clinical_Appointment__c, p.Clinical_Appointment__r.name From POT_Appointment__c p where id= :current_edit];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the appointment info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void modify_sort_order() {
  	String pass_thru;
  	try {
  	  pass_thru = apexpages.currentpage().getparameters().get('pthru');
  	  pass_thru = pass_thru.replace('slist[]=','');
      //System.debug('pass thru : ' + pass_thru);
      //pass_thru = pass_thru.replace('name','');
      //System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      List<POT_Appointment__c> apt_list = new List<POT_Appointment__c>();
      for(String my_id : pass_array) {
      	POT_Appointment__c apt = [select id,sort_order__c from POT_Appointment__c where id = :my_id];
      	apt.sort_order__c = sort_order;
      	apt_list.add(apt);
      	sort_order++;
      }
      update apt_list;      
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Pass thru : ' + pass_thru + ' pthru : ' + apexpages.currentpage().getparameters().get('pthru')));
      ApexPages.addMessages(e);	
    }  
  }
  
  public void hide_apt_detail_form() {
  	current_edit = null;
  }
  
  public void close_modal() {
  	modal_display = false;  	
  }     
}