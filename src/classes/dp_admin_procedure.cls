public with sharing class dp_admin_procedure {
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
  
  //Fields for office form
  public Boolean display_office_form {get; set;}
  public String new_form_name {get; set;}
  
  /*controller specific backend fields*/
  public Boolean display_procedure_form {get; set;}
  public Clinical_Procedure__c new_procedure {get; set;}
  public String last_insert {get; set;}
  public String category_filter {get; set;}
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
  
  public class bendException extends Exception {}
    
  public dp_admin_procedure() {  	
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
        current_center = [select id,name,market__c,sales_region__c  from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
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
  	current_page = [Select Id, Name, Nav_Color__c, Page_URL__c From Navigation_Page__c where name = 'Procedures'];  	
  	hide_procedure_form();
  	display_all_procedures();
  	activation_id = '';
  	display_procedure_form = false;
  	new_form_name = '';
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
  
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c,sales_region__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  quick_search_field = '';
  	  display_all_procedures();
  	  hide_procedure_form();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public void back_to_procedure() {
  	display_all_procedures();
  	//get the procedure we were looking at,  to scroll into view
  	last_insert = new_procedure.id;
  }
  
  public void display_all_procedures() {
  	display_qsearch = true;
  	display_add_button = true;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'procedure_display';
  	display_active_nav = true;
  	body_header = '';
  	current_edit = null;
  }
  
  public void edit_financial_info() {
    current_edit = new_procedure.id;
  }
  
  public void save_scheduling_info() {
  	Integer num_issues = 0;
  	if(new_procedure.time_required__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the time'));  	  
  	} /* reduce by ten minutes will be negative - removing this restriction
  	else if(new_procedure.time_required__c<0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a positive value for time'));
  	} */
  	if(new_procedure.assistants_needed__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for assistants'));
  	} else if(new_procedure.assistants_needed__c<0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a positive value for assistants'));
  	} 
  	if(num_issues == 0) {
  	  try {
  	  	update new_procedure;
  	  	current_edit = null;  	    
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the scheduling info. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public void save_financial_info() {
  	Integer num_issues = 0;
  	if(new_procedure.insurance_fee__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for the insurance fee'));  	  
  	} 
  	if(new_procedure.cost__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for cost'));
  	} 
  	if(new_procedure.markup_min__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for markup minimum'));
  	} else if(new_procedure.markup_min__c<0 || new_procedure.markup_min__c>100) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value between 0 and 100 for markup minimum'));
  	}
  	if(new_procedure.markup_max__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for markup maximum'));
  	} else  if(new_procedure.markup_max__c < new_procedure.markup_min__c) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Markup maximum must be greater or equal to markup minimum'));
  	} else if(new_procedure.markup_max__c<0 || new_procedure.markup_max__c>100) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value between 0 and 100 for markup maximum'));
  	}   	
  	if(num_issues == 0) {
  	  try {
  	  	update new_procedure;
  	  	current_edit = null;  	    
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the financial info. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public List<Clinical_Procedure_Form__c> getprocedure_forms() {
  	return [select id,office_form__r.name,office_form__r.forms_category__c from Clinical_Procedure_Form__c where clinical_procedure__c = :new_procedure.id];
  }
  
  
  
  public void hide_financial_form() {
  	current_edit = null;
  	reset_financial_info();
  }
  
  public void reset_financial_info() {
    new_procedure = [Select c.isactive__c, c.Time_Required__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Id, c.Doctor_Required__c, c.Cost__c, c.Assistants_Needed__c, c.ADA_Code__c From Clinical_Procedure__c c where id = :new_procedure.id];  	
  }
  
  public void display_form_info() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	display_active_nav = false;
  	selected_view = 'form_display';
  	try {
  	  new_procedure = [Select c.Default_Teeth_Selection__c, c.allow_tooth_selection__c, c.isactive__c, c.Time_Required__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Id, c.Doctor_Required__c, c.Cost__c, c.Assistants_Needed__c, c.ADA_Code__c From Clinical_Procedure__c c where id = :apexpages.currentpage().getparameters().get('procid')];
  	  body_header = new_procedure.name + ' - Forms';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the form info for this procedure.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_financial_info() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	display_active_nav = false;
  	selected_view = 'financial_display';
  	try {
  	  new_procedure = [Select c.Default_Teeth_Selection__c, c.allow_tooth_selection__c, c.isactive__c, c.Time_Required__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Id, c.Doctor_Required__c, c.Cost__c, c.Assistants_Needed__c, c.ADA_Code__c From Clinical_Procedure__c c where id = :apexpages.currentpage().getparameters().get('procid')];
  	  body_header = new_procedure.name + ' - Financial';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the financial info for this procedure.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void display_scheduling_info() {
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	display_active_nav = false;
  	selected_view = 'scheduling_display';
  	try {
  	  new_procedure = [Select c.Default_Teeth_Selection__c, c.allow_tooth_selection__c, c.isactive__c, c.Time_Required__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Id, c.Doctor_Required__c, c.Cost__c, c.Assistants_Needed__c, c.ADA_Code__c From Clinical_Procedure__c c where id = :apexpages.currentpage().getparameters().get('procid')];
  	  body_header = new_procedure.name + ' - Scheduling';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to lookup the scheduling info for this procedure.  Please contact IT for help'));
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
  
  public List<Clinical_Procedure__c> getprosth_list() {
    String qfilter = ' where center_information__c = \'' + current_center.id + '\' and c.procedure_filter__c = \'Prosth\'  ';        
    return getprocedure_list(qfilter);
  }
  
  public List<Clinical_Procedure__c> getsurgical_list() {
    String qfilter = ' where center_information__c = \'' + current_center.id + '\' and c.procedure_filter__c = \'Surgical\'  ';        
    return getprocedure_list(qfilter);
  }
  
  public List<Clinical_Procedure__c> getmisc_list() {
    String qfilter = ' where center_information__c = \'' + current_center.id + '\' and c.procedure_filter__c = \'Misc\'  ';        
    return getprocedure_list(qfilter);
  }
    
  public List<Clinical_Procedure__c> getprocedure_list(String query_filter) {
    List<Clinical_Procedure__c> cp_list;
    try {
      //String query_filter = ' where center_information__c = \'' + current_center.id + '\' ';
  	  if(active_filter=='Active')
  	    query_filter += ' and isactive__c = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and isactive__c = false ';
  	  if(category_filter!='All')
  	    query_filter += ' and c.procedure_filter__c = \'' + category_filter  + '\'';
  	  if((quick_search_field==null?'':quick_search_field) != '') 
  	  	query_filter += ' and (name like \'%' + quick_search_field + '%\' or procedure_description__c like \'%' + quick_search_field + '%\')  ';
  	  cp_list = database.query('Select c.procedure_filter__c, c.isactive__c, c.Time_Required__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Id, c.Doctor_Required__c, c.Cost__c, c.Assistants_Needed__c, c.ADA_Code__c From Clinical_Procedure__c c ' + query_filter + ' order by isactive__c desc, name');    	
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical procedures for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
    }    
    return cp_list;
  }  
  
  public void new_procedure_form() {
  	display_procedure_form = true;
  	current_edit = null;
  	new_procedure = new Clinical_Procedure__c(name = 'Enter Procedure Name', procedure_description__c = 'Enter Procedure Description', isactive__c = true, center_information__c = current_center.id);
  }    
  
  public void edit_clinical_procedure() {
  	try {
  	  display_procedure_form = false;
  	  new_procedure = [Select c.Default_Teeth_Selection__c, c.allow_tooth_selection__c, c.center_information__c, c.procedure_filter__c, c.isactive__c, c.Time_Required__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Id, c.Doctor_Required__c, c.Cost__c, c.Assistants_Needed__c, c.ADA_Code__c From Clinical_Procedure__c c where id= :current_edit];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the procedure info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public void reset_procedure_form() {
  	new_procedure = new Clinical_Procedure__c(name = 'Enter Procedure Name', procedure_description__c = 'Enter Procedure Description', isactive__c = true, center_information__c = current_center.id);
  }  
  
  public void save_new_procedure() {
  	Integer num_issues = 0;
  	if(new_procedure.name==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a name for the procedure'));  	  
  	} else if(new_procedure.name=='Enter Procedure Name') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a name for the procedure'));
  	}
  	if(new_procedure.procedure_description__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a description for the procedure'));
  	} else if(new_procedure.procedure_description__c=='Enter Procedure Description') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a description for the procedure'));
  	}  	
  	if(new_procedure.procedure_filter__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a category for the procedure'));
  	}
  	//check to see if a procedure with this name already exists at the center
  	Integer pcount = [select count() from Clinical_Procedure__c where name = :new_procedure.name and center_information__c = :new_procedure.center_information__c and id!=:new_procedure.id];
  	if(pcount>0) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A procedure with that name already exists for this center.  Please use a unique name to continue'));
  	}
  	if(num_issues == 0) {
  	  try {
  	  	if(current_edit==null)
  	      insert new_procedure;
  	    else
  	      update new_procedure;
  	    last_insert = new_procedure.id;
  	    display_procedure_form = false;
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the procedure. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public Integer getall_count() {
  	Integer record_count = 0;
  	if(selected_view=='procedure_display')
  	  record_count = [select count() from Clinical_Procedure__c where center_information__c = :current_center.id];  	
  	return record_count;
  }
  
  public Integer getactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='procedure_display')
  	  record_count = [select count() from Clinical_Procedure__c where center_information__c = :current_center.id and isactive__c = true]; 	
  	return record_count;
  }
  
  public Integer getinactive_count() {
  	Integer record_count = 0; 
    if(selected_view=='procedure_display')
  	  record_count = [select count() from Clinical_Procedure__c where center_information__c = :current_center.id and isactive__c = false]; 
  	return record_count;
  }
  
  public Integer getprosth_count() {
	Integer record_count = [select count() from Clinical_Procedure__c where center_information__c = :current_center.id and procedure_filter__c = 'Prosth'];  	
  	return record_count;
  }
  
  public Integer getsurgical_count() {
	Integer record_count = [select count() from Clinical_Procedure__c where center_information__c = :current_center.id and procedure_filter__c = 'Surgical'];  	
  	return record_count;
  }
  
  public Integer getmisc_count() {
	Integer record_count = [select count() from Clinical_Procedure__c where center_information__c = :current_center.id and procedure_filter__c = 'Misc'];  	
  	return record_count;
  }
      
  public void hide_procedure_form() { 
  	display_procedure_form = false; 	
    current_edit = null;
  }
  
  public void confim_activation_procedure() {
  	modal_display = true;
  	Clinical_Procedure__c p = [select id,isactive__c,name from Clinical_Procedure__c where id=:activation_id];
  	modal_out = 'You are about to ' + (p.isactive__c==true?'deactivate':'activate') + ' procedure - ' + p.name;
  }
  
  public void confim_remove_form() {
  	modal_display = true;
  	Clinical_Procedure_Form__c p = [select id,office_form__r.name,clinical_procedure__r.name from Clinical_Procedure_Form__c where id=:activation_id];
  	modal_out = 'You are about to remove form - ' + p.office_form__r.name + ' from this procedure';
  }
  
  public void update_activation_procedure() {
  	try {
  	  modal_display = false;  	  
  	  Clinical_Procedure__c p = [select id,isactive__c,name from Clinical_Procedure__c where id=:activation_id];
  	  if(p.isactive__c==true)
  	    p.isactive__c = false;
  	  else
  	    p.isactive__c = true;
  	  update p;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this procedure. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void update_activation_form() {
  	try {
  	  modal_display = false;  	  
  	  Clinical_Procedure_Form__c p = [select id from Clinical_Procedure_Form__c where id=:activation_id];
  	  delete p;
  	  activation_id = null;
  	  modal_out = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing this form. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void close_modal() {
  	modal_display = false;  	
  }      
  
  public void new_office_form() {
  	display_office_form = true;
  	new_form_name = 'Enter form';
  }
  
  public void hide_office_form() {
  	display_office_form = false;
  }
  
  public void reset_office_form() {
  	new_form_name = 'Enter form';
  }
  
  public void select_office_form() {
  	new_form_name = [select name from Office_Form__c where id = :apexpages.currentpage().getparameters().get('ofid')].name;
  	add_office_form();
  }  
  
  public List<Office_Form__c> getsearch_forms() {
  	List<Office_Form__c> of_list;
  	try {
  	  String query_filter = ' where name != null ';
  	  if(new_form_name!=null)
  	    if(new_form_name != 'Enter form')
  	      query_filter += ' and (name like \'%' + new_form_name + '%\')  ';
  	  of_list = database.query('select id,name from office_form__c ' + query_filter + ' order by name');
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up office forms. Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  	return of_list;
  }
  
  public void add_office_form() {
  	//see if we have a match
  	Integer form_matches = [select count() from Office_form__c where name = :new_form_name];
  	if(form_matches==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a valid form name'));	
  	} else {
  	  try {    	  	
  	  	Office_Form__c oform = [select id from Office_Form__c where name = :new_form_name];	
  	    //create and insert record
  	    Clinical_Procedure_Form__c new_cpf = new Clinical_Procedure_Form__c(Clinical_Procedure__c = new_procedure.id, Office_Form__c = oform.id);  	    
  	    insert new_cpf;
  	    hide_office_form();
  	    last_insert=new_cpf.id;
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the form. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }
}