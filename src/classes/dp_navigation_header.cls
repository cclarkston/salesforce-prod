public with sharing class dp_navigation_header {
  public String quick_search_field {get;set;} 
  public Boolean display_qsearch {get; set;}
  public Boolean display_add_button {get; set;} 
  public Center_Information__c current_center {get; set;}
  public Boolean display_corp_admin {get; set;}
  
	  
  public dp_navigation_header() {
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
        User u = [select clinic_calendar__c from user where id =:userinfo.getUserId()];         
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   	  	  	  	
  	quick_search_field = '';
  	display_qsearch = true;
  	display_add_button = true;
  	//see if it's a corporate admin
  	Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  }
  
  public void do_nothing() {
  	
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
  	if(display_corp_admin)
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id order by name];
  	else
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c = :current_center.market__c order by name];
  	return ci_list;
  }
  
  public List<Navigation_Page__c> getgear_menu() {
  	return [Select n.Sort_Order__c, n.Page_URL__c, n.Name, n.Image_Name__c, n.Id , n.image_name_hover__c,n.hyperlink_target__c From Navigation_Page__c n where navigation_header__r.name = 'Gear' order by sort_order__c];
  }
  
  public List<menu_item> getnavigation_menu() {
  	List<menu_item> nav_menu = new List<menu_item>();
  	for(Navigation_Header__c head : [Select n.Sub_System__c, n.Sort_Order__c, n.Name,  n.Id, (Select Id,  Name, Nav_Color__c, Page_URL__c,css_class__c From Navigation_Pages__r order by sort_order__c) From Navigation_Header__c n where sub_system__c = 'Setup' order by sort_order__c]) {
  	  nav_menu.add(new menu_item(head.name,'Header',null,head.id,null));
  	  for(Navigation_Page__c page : head.navigation_pages__r) {
  	  	nav_menu.add(new menu_item(page.name,'Page',page.nav_color__c,page.id,page.css_class__c));
  	  }
  	  nav_menu.add(new menu_item(null,'Spacer',null,null,null));
  	}
  	//remove the last spacer line from the menu - it's not needed
  	nav_menu.remove(nav_menu.size()-1);
  	return nav_menu;
  }
  
  public List<Navigation_Header__c> getmain_menu() {
    return [Select n.Sub_System__c, n.Sort_Order__c, n.Name,  n.Id, (Select Id,  Name, Nav_Color__c, Page_URL__c,css_class__c From Navigation_Pages__r order by sort_order__c) From Navigation_Header__c n where sub_system__c = 'Setup' order by sort_order__c];  	
  }
  
  public void change_center() {
  	try {
  	  current_center = [select id,name,market__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	  quick_search_field = '';
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
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
  
  public PageReference portal_entry() {
  	PageReference pr;
  	try {
  	  Navigation_Page__c np = [select name,page_url__c from Navigation_Page__c where name = 'Patient'];
  	  pr = new PageReference(np.page_url__c);
  	  pr.getParameters().put('ctrid',current_center.id);     
  	  pr.setredirect(true);  	      
  	  return pr;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change pages.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	  return null;
  	}
  	return pr;
  }
  
  /*public String[] gettime_labels() {
  	List<String> all_labels = new List<String> ();
  	Integer hour;
  	Integer minute;
  	for(hour=7;hour<20;hour++) {
  	  minute = 0;
  	  while(minute<60) {  	  	  	 
  	  	//System.debug('Hour : ' + hour + 'Minute : ' + minute);
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
  	  	all_labels.add(tlabel);
  	  	minute += 10;
  	  }
  	}
  	return all_labels;
  } */   
}