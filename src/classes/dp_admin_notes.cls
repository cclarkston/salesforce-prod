public with sharing class dp_admin_notes {
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
  public String confirmation_css {get; set;}
  
  /*controller specific backend fields*/  
  public Boolean display_note_form {get; set;}
  public Custom_Clinical_note__c new_note {get;set;}
  public Boolean display_apt_modal {get; set;}
  public String apt_add_id {get; set;} 
  public String category_filter {get; set;}
  public String removal_apt_id {get; set;}
  public String expand_id {get; set;}
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
 
  public class bendException extends Exception {}
    
  public dp_admin_notes() {  	
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
  	//see if it's a corporate admin
  	Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  	current_page = [Select Id, Name, Nav_Color__c, Page_URL__c From Navigation_Page__c where name = 'Click Notes'];  	
  	display_all_notes();  	
  	confirmation_css = '';
  	display_apt_modal = false;
  	expand_id = null;
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
  	  display_all_notes();  	  
      hide_note_form();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public void hide_note_form() {
  	display_note_form = false;
  	current_edit = null;
  }
  
  public void display_all_notes() {
  	hide_note_form();
  	//unable to search on note text because it's a long text field
  	display_qsearch = false;
  	display_add_button = true;
  	quick_search_field = '';
  	active_filter = 'Active';
  	selected_view = 'note_display';
  	display_active_nav = true;
  	body_header = '';
  	current_edit = null;
  }
  
  public void display_sort_view() {
  	hide_note_form();
  	display_qsearch = false;
  	display_add_button = false;
  	quick_search_field = '';
  	active_filter = 'All';
  	selected_view = 'sort_display';
  	display_active_nav = false;
  	body_header = '';
  	current_edit = null;
  }
  
  public void back_to_notes() {
  	display_all_notes();
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
    
  public List<Custom_Clinical_Note__c> getnotes_list() {
    List<Custom_Clinical_Note__c> note_list;
    try {
      String query_filter = ' where center_information__c = \'' + current_center.id + '\' ';
  	  if(active_filter=='Active')
  	    query_filter += ' and isactive__c = true ';
  	  else if(active_filter=='Inactive')
  	    query_filter += ' and isactive__c = false ';
  	  if((quick_search_field==null?'':quick_search_field) != '') 
  	  	query_filter += ' and (note_text__c like \'%' + quick_search_field + '%\')  ';
  	  note_list = database.query('Select c.id,c.isactive__c,c.note_text__c,c.createdby.name,c.createddate,(Select Clinical_Appointment__r.name From Custom_Clinical_Notes_by_Apt__r) From Custom_Clinical_Note__c c ' + query_filter + ' order by sort_order__c');    	
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up custom notes for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
    }    
    return note_list;
  }        
  
  public Integer next_sort_order() {
  	Integer last_sort = 1;
  	try {
      last_sort = [select sort_order__c from Custom_Clinical_Note__c where center_information__c = :current_center.id order by sort_order__c desc limit 1].sort_order__c.intvalue();
      last_sort++; 
  	} catch (Exception e) {
  	  //there are no notes...sort order should remain 1
  	}
  	return last_sort;
  }
  
  public void new_note_form() {
  	display_note_form = true;
  	current_edit = null;
  	new_note = new Custom_Clinical_Note__c(note_text__c = 'Enter note',isactive__c = true, center_information__c = current_center.id,sort_order__c = 0);
  }    
     
  public void reset_note_form() {
  	new_note = new Custom_Clinical_Note__c(note_text__c = 'Enter note',isactive__c = true, center_information__c = current_center.id,sort_order__c = 0);
  }  
  
  public void save_new_note() {
  	Integer num_issues = 0;
  	if(new_note.note_text__c==null) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter something for the note field'));  	  
  	} else if(new_note.note_text__c=='Enter note') {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter something for the note field'));
  	} else if(new_note.note_text__c.length()<5) {
  	  num_issues++;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a longer note'));
  	}  	
  	if(num_issues == 0) {
  	  try {  	      
  	  	if(current_edit==null) {
  	  	  new_note.sort_order__c = next_sort_order();
  	      insert new_note;
  	  	}
  	    else
  	      update new_note;
  	    display_note_form = false;
  	    current_edit = null;
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the note. Please contact IT for help'));
        ApexPages.addMessages(e);
  	  }
  	}
  }  
  
  public Integer getall_count() {
  	Integer record_count = 0;
  	if(selected_view=='note_display' || selected_view=='sort_display')
  	  record_count = [select count() from Custom_Clinical_Note__c where center_information__c = :current_center.id];  	
  	return record_count;
  }
  
  public Integer getactive_count() {
  	Integer record_count = 0;
  	if(selected_view=='note_display' || selected_view=='sort_display')
  	  record_count = [select count() from Custom_Clinical_Note__c where center_information__c = :current_center.id and isactive__c = true]; 	
  	return record_count;
  }
  
  public Integer getinactive_count() {
  	Integer record_count = 0; 
    if(selected_view=='note_display' || selected_view=='sort_display')
  	  record_count = [select count() from Custom_Clinical_Note__c where center_information__c = :current_center.id and isactive__c = false]; 
  	return record_count;
  }
  
  public void close_modal() {
  	modal_display = false;  	
  	activation_id = null;
  	current_edit = null;
  	confirmation_css = ''; 
  	removal_apt_id = null;
  }
  
  public void close_apt_modal() {
  	display_apt_modal = false;
  	apt_add_id = null;
  }
  
  public void open_apt_modal() {
  	display_apt_modal = true;
  	apt_add_id = apexpages.currentpage().getparameters().get('noteid');
  	category_filter = 'All';  	  	
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
  
  public void confirm_remove_apt() {
  	activation_id = apexpages.currentpage().getparameters().get('noteid');
  	removal_apt_id = apexpages.currentpage().getparameters().get('aptid');  	
  	Custom_Clinical_Note_by_Apt__c ca = [select id,clinical_appointment__r.name from Custom_Clinical_Note_by_Apt__c where id = :removal_apt_id];
  	confirmation_css = 'confirm_deactivate';
  	modal_display = true;
  	modal_out = 'Please confirm you wish to remove this apt :<br />' + ca.clinical_appointment__r.name;
  	modal_type = 'apt_removal';
  }
  
  public void confirm_activate_note() {
  	activation_id = apexpages.currentpage().getparameters().get('noteid');  	  	   
  	confirmation_css = ' confirm_activate';
  	modal_display = true;
  	modal_out = 'Please confirm you wish to activate this note';
  	modal_type = 'note_activation';  	
  }
  
  public void confirm_deactivate_note() {
  	activation_id = apexpages.currentpage().getparameters().get('noteid');  	  	   
  	confirmation_css = ' confirm_deactivate';
  	modal_display = true;
  	modal_out = 'Please confirm you wish to deactivate this note';
  	modal_type = 'note_deactivation';
  }
  
  public void update_note_activation() {
  	try {  	  	 
  	  Custom_Clinical_Note__c a = [select id,isactive__c,name from Custom_Clinical_Note__c where id=:activation_id];
  	  if(a.isactive__c==true)
  	    a.isactive__c = false;
  	  else
  	    a.isactive__c = true;
  	  update a;
  	  close_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating the activation status of this note. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public void remove_note_apt() {
  	try {
  	  Custom_Clinical_Note_by_Apt__c remove_record = [select id from Custom_Clinical_Note_by_Apt__c where id = :removal_apt_id];
  	  delete remove_record;
  	  close_modal();
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error removing this appointment from the list. Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
  
  public Custom_Clinical_Note__c getcurrent_note_info(String note_id) {
  	return [Select c.id,c.isactive__c,c.note_text__c,c.createdby.name,c.createddate,(Select Clinical_Appointment__r.name From Custom_Clinical_Notes_by_Apt__r) From Custom_Clinical_Note__c c where id = :note_id];
  }
  
  public void edit_custom_note() {
  	try {
  	  display_note_form = false;
  	  new_note = getcurrent_note_info(current_edit);
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the note info. Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  }
  
  public List<Clinical_Appointment__c> getappointment_list() {
    List<Clinical_Appointment__c> ca_list;
    try {
      String query_filter = ' where center_information__c = \'' + current_center.id + '\' ';
      //need a list of id's that have already been added to this custom note
      String existing_list = ' (';
      for(Custom_Clinical_note_by_Apt__c cca : [Select c.Id, c.Clinical_Appointment__c From Custom_Clinical_Note_by_Apt__c c where custom_clinical_note__c = :apt_add_id]) {
      	existing_list += '\'' + cca.clinical_appointment__c + '\',';
      }
      existing_list += 'null) ';      
      query_filter += ' and id not in ' + existing_list;
      //we only want to add active appointments 
  	  query_filter += ' and isactive__c = true ' ;  	  
  	  if(category_filter!='All')
  	    query_filter += ' and c.appointment_filter__c = \'' + category_filter  + '\'';
  	  ca_list = database.query('Select c.lab_time__c,c.isactive__c, c.Padding_Time__c, c.Name, c.Center_Information__c, c.Appointment_Description__c From Clinical_Appointment__c c ' + query_filter + ' order by isactive__c desc, name');    	
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up clinical appointments for this center. Please contact IT for help'));
      ApexPages.addMessages(e);		
    }    
    return ca_list;
  }
  
  public void add_note_by_appointment() {
  	String apt_id = apexpages.currentpage().getparameters().get('aptid');
  	try {
      Custom_Clinical_note_by_Apt__c cca = new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = apt_id, Custom_Clinical_Note__c = apt_add_id);
      insert cca;  		
  	} catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error adding the apt to the note list. Please contact IT for help'));
      ApexPages.addMessages(e);		
  	}
  }
  
  public void expand_appointment_list () {
  	expand_id = apexpages.currentpage().getparameters().get('noteid');  
  }
  
  public void collapse_appointment_list() {
  	expand_id = null;
  }
  
  public void test_notes_sort() {
  	try {
  	  String pass_thru = apexpages.currentpage().getparameters().get('pthru');      
      pass_thru = pass_thru.replace('cnote_','');
      System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      List<Custom_Clinical_Note__c> notes_list = new List<Custom_Clinical_Note__c>();
      Map<Id,Custom_Clinical_Note__c> notes_map = new Map<Id,Custom_Clinical_Note__c>([select id,sort_order__c from Custom_Clinical_Note__c]);      
      for(String my_id : pass_array) {
      	Custom_Clinical_Note__c cnote = notes_map.get(my_id);
      	cnote.sort_order__c = sort_order;
      	notes_list.add(cnote);
      	sort_order++;
      }
      update notes_list;            
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessages(e);	
    }  
  }
}