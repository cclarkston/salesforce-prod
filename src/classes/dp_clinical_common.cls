public with sharing class dp_clinical_common {
	
  static List<Navigation_Header__c> nav_header = [Select n.Sub_System__c, n.Sort_Order__c, n.Name,  n.Id, (Select css_class__c, Page_URL__c, Nav_Color__c, Name, Image_Name__c, Image_Name_Hover__c, Id, Hyperlink_Target__c, Alt_Page_URL__c From Navigation_Pages__r order by sort_order__c) From Navigation_Header__c n order by sort_order__c];
  static Map<String,List<Navigation_Header__c>> nav_header_map_subsystem;
  static Map<String,Navigation_Header__c> nav_header_map_name; 
  
  static {
  	nav_header_map_subsystem = new map<String,List<Navigation_Header__c>> ();
    nav_header_map_name = new Map<String,Navigation_Header__c>();
    for(Navigation_Header__c header : nav_header) {
      if(nav_header_map_subsystem.get(header.sub_system__c)==null)
        nav_header_map_subsystem.put(header.sub_system__c,new List<Navigation_Header__c> ());
      nav_header_map_subsystem.get(header.sub_system__c).add(header);
      nav_header_map_name.put(header.name,header);
    } 
  }
  
  public hrx_navigation_link getpage_by_name (String pname,Center_Information__c current_center) {
  	hrx_navigation_link nav_page = new hrx_navigation_link([select alt_page_url__c, page_url__c, name from Navigation_Page__c where name = :pname],current_center.use_alternate_url__c,current_center.use_alternate_calendar_url__c);
  	return nav_page;
  }
  
  public List<hrx_navigation_link> getnav_pages_by_subheader(String sname,Center_Information__c center) {
  	List<hrx_navigation_link> nav_links = new List<hrx_navigation_link>();
  	for(Navigation_Header__c nheader : nav_header_map_subsystem.get(sname)) {
  	  for(Navigation_Page__c npage : nheader.navigation_pages__r) {
  	    nav_links.add(new hrx_navigation_link(npage,center.Use_Alternate_url__c,center.Use_Alternate_Calendar_URL__c));
  	  }
  	}
  	return nav_links;
  }
  
  public PageReference pref_to_patient(Center_Information__c current_center, String patient_id) {  	
  	hrx_navigation_link nav_link = new hrx_navigation_link([select alt_page_url__c, page_url__c, name from Navigation_Page__c where name = 'Patient'],current_center.use_alternate_url__c,current_center.use_alternate_calendar_url__c);  	
  	Pagereference pr = new PageReference(nav_link.getpage_url());
  	pr.getParameters().put('ctrid',current_center.id);
  	pr.getParameters().put('ptid',patient_id);
  	pr.setredirect(true);  	      
  	return pr;  	  	
  }
  
  public PageReference pref_navid(Center_Information__c current_center, String navid) {
  	PageReference pr;
  	hrx_navigation_link nav_link = new hrx_navigation_link([select alt_page_url__c, page_url__c, name from Navigation_Page__c where id = :navid],current_center.use_alternate_url__c,current_center.use_alternate_calendar_url__c);
  	pr = new PageReference(nav_link.getpage_url());
  	pr.getParameters().put('ctrid',current_center.id);   
  	pr.setredirect(true); 
  	return pr;
  }
  
  public List<RecentlyViewed> getrecent_records() {
    return [select Id, Name from RecentlyViewed where type = 'Account' order by LastViewedDate desc limit 10];
  }     
  
  public List<Navigation_Page__c> getclinical_header_items() {
    return nav_header_map_name.get('Clinical Header').navigation_pages__r;
  }
  
  public List<hrx_navigation_link> getnav_pages_by_name(String hname,Center_Information__c center) {
  	List<hrx_navigation_link> nav_links = new List<hrx_navigation_link>();
  	for(Navigation_Page__c npage : nav_header_map_name.get(hname).navigation_pages__r) {
  	  nav_links.add(new hrx_navigation_link(npage,center.Use_Alternate_url__c,center.Use_Alternate_Calendar_URL__c));
  	}
  	return nav_links;
  }  
  
  public class hrx_navigation_link {
  	public navigation_page__c nav_page {get;set;}
  	private Boolean alternative_notes;
  	private Boolean alternative_calendar;
  	
  	public hrx_navigation_link(Navigation_Page__c np, Boolean anotes, Boolean acalendar) {
  	  this.nav_page = np;
  	  this.alternative_notes = anotes;
  	  this.alternative_calendar = acalendar;	
  	}
  	
  	public String getpage_url() {
  	  if(nav_page.page_url__c=='/apex/ccare_clinical_calendar')
  	  	return (alternative_calendar?nav_page.Alt_Page_URL__c:nav_page.page_url__c);
      else if(nav_page.name=='Notes')
        return (alternative_notes?nav_page.Alt_Page_URL__c:nav_page.page_url__c);
      else
        return nav_page.page_url__c;
  	} 
  }
}