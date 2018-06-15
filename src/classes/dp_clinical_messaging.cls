public with sharing class dp_clinical_messaging {
  public Center_Information__c current_center {get; set;}
  public Boolean display_corp_admin {get; set;}
  
  //for summary
  public ConnectApi.ChatterConversationPage last_conversation_page;
  public ConnectApi.ChatterConversationPage current_conversation_page;
  public String detail_header {get; set;}
  
  //for detail
  public ConnectApi.ChatterMessagePage last_message_page;
  public ConnectApi.ChatterMessagePage current_message_page;
  
  
  public String conversation_search {get;set;}
  public Boolean currently_searching {get;set;}
    
  public Boolean display_new_message_modal {get;set;}
  public Boolean display_to_error {get; set;}  
  public String message_to {get; set;}
  public String message_body {get;set;}
  public List<ConnectApi.UserDetail> message_recepients {get; set;}
  
  public String detail_view {get;set;}
  public String current_tab {get;set;}
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
    
  public dp_clinical_messaging() {  	
  	User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];     
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
            
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   
  	  	  	
  	//see if it's a corporate admin
  	Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;  	 
  	message_to = ''; 	  
  	message_recepients = new List<ConnectApi.UserDetail>();
  	display_to_error = false;
  	last_conversation_page = null;
  	current_conversation_page = ConnectApi.ChatterMessages.getConversations();
  	detail_view = 'conversation_summary';
  	current_tab = 'Messages';
  	display_new_message_modal = false;
  	conversation_search = 'Search all messages';
  	currently_searching = false;
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
  	  System.debug('Changing Center : ' + apexpages.currentpage().getparameters().get('cid'));
  	  current_center = [select id,name,market__c,number_of_lab_techs__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public List<Navigation_Page__c> getclinical_header_items() {
  	return [Select n.Sort_Order__c, n.Page_URL__c, n.Name, n.Image_Name__c, n.Id , n.image_name_hover__c,n.css_class__c From Navigation_Page__c n where navigation_header__r.name = 'Clinical Header' order by sort_order__c];
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
  	      if(apexpages.currentpage().getparameters().get('ptid')!=null)
  	        pr.getParameters().put('ptid',apexpages.currentpage().getparameters().get('ptid'));   
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
  
  public PageReference navigate_to_recent_patient() {
  	Navigation_Page__c np = [select page_url__c from Navigation_Page__c where name = 'Patient'];
  	Pagereference pr = new PageReference(np.page_url__c);
  	pr.getParameters().put('ctrid',current_center.id);
  	pr.getParameters().put('ptid',apexpages.currentpage().getparameters().get('recentid'));
  	pr.setredirect(true);  	      
  	return pr;  	
  }

  public List<RecentlyViewed> getrecent_records() {
    return [select Id, Name from RecentlyViewed where type = 'Account' order by LastViewedDate desc limit 10];
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
  	  //shouldn't happen in production,  but I'm leaving this in place here for the test environment and initial setup circumstances
  	  if(all_clinician_ids.size()==0) {
  	    DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
        Map<String,Object> amap = (Map<String,object>)dres.data;
        error_count += Integer.valueof(amap.get('refillRequestCount'));
        error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  } else {
  	  	for(Integer clinician_id : all_clinician_ids) {
  	  	  DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors_by_clinician(current_center,clinician_id);
          Map<String,Object> amap = (Map<String,object>)dres.data;
          error_count += Integer.valueof(amap.get('refillRequestCount'));
          error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  	}
  	  }  	  
      return error_count;    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return error_count;
  }
  
  public Integer getunread_message_count() {
  	ConnectApi.UnreadConversationCount unread = ConnectApi.ChatterMessages.getUnreadCount();
    return unread.unreadCount;
  }
  
  public class Conversation_detail {
  	public ConnectApi.ChatterMessage message {get;set;}
  	private String current_search_val;
  	private Boolean message_search;
  	
  	public Conversation_detail(ConnectApi.ChatterMessage cm, String csval, boolean msearch) {
      this.message = cm;
      this.current_search_val = csval;  	  
      this.message_search = msearch;
  	}
  	
  	public String getformatted_message_time() {
  	  if(message.sentdate.date()==System.today())
  	    return 'Today at ' + message.sentdate.format('h:mm a');
      else
  	    return message.sentdate.format('MMM d, yyyy') + ' at ' + message.sentdate.format('h:mm a');
  	}
  	
  	public String getbody_text_html() {
      if(message_search) {
      	return message.body.text.replaceAll('(?i)' + current_search_val,'<span class="search_text_highlight">' + current_search_val + '</span>');
      }
      else 
        return message.body.text;
  	}
  	
  	public String getMessage_name() {
  	  String cname = '';
  	  for(ConnectApi.UserSummary usum : message.recipients) {
  	  	if(usum.id!=Userinfo.getUserId()) {
  	  	  if(cname!='')
  	  	    cname += ' and ';  	  	  
  	  	  cname += usum.name;
  	  	}
  	  }  	  
  	  return cname;
  	}
  	
  	public String getConversation_photo() {
  	  String photo_url = '';
  	  for(ConnectApi.UserSummary usum : message.recipients) {
  	  	if(usum.id!=Userinfo.getUserId())
  	  	  photo_url = usum.photo.smallPhotoUrl;
  	  }
  	  return photo_url;
  	} 
  	
  }
  
  public class Conversation {
  	public ConnectApi.ChatterConversationSummary conversation_summary {get; set;}
  	private String current_search_val;
  	
  	public Conversation(ConnectApi.ChatterConversationSummary csummary, String csval) {
  	  this.conversation_summary = csummary;
  	  this.current_search_val = csval;
  	}
  	
  	public String getformatted_message_time() {
  	  if(conversation_summary.latestMessage.sentdate.date()==System.today())
  	    return 'Today at ' + conversation_summary.latestMessage.sentdate.format('h:mm a');
      else
  	    return conversation_summary.latestMessage.sentdate.format('MMM d, yyyy') + ' at ' + conversation_summary.latestMessage.sentdate.format('h:mm a');
  	}
  	
  	public String getConversation_name() {
  	  String cname = '';
  	  for(ConnectApi.UserSummary usum : conversation_summary.members) {
  	  	if(usum.id!=Userinfo.getUserId()) {
  	  	  if(cname!='')
  	  	    cname += ' and ';
  	  	  /*if(usum.firstname!=null && usum.lastname!=null)
  	  	    cname += usum.firstname + ' ' + usum.lastname;
  	  	  else
  	  	    cname += usum.displayName;*/
  	  	  cname += usum.name;
  	  	}
  	  }  	  
  	  return cname;
  	}
  	
  	public String getConversation_photo() {
  	  String photo_url = '';
  	  for(ConnectApi.UserSummary usum : conversation_summary.members) {
  	  	if(usum.id!=Userinfo.getUserId())
  	  	  photo_url = usum.photo.smallPhotoUrl;
  	  }
  	  return photo_url;
  	} 
  	
  	public String getsearch_match_text() {
  	  ConnectApi.ChatterConversation conversation = ConnectApi.ChatterMessages.getconversation(conversation_summary.id);
  	  Integer match_count = 0;
  	  for(ConnectApi.ChatterMessage message : conversation.messages.messages) {
  	  	if(message.body.text.containsignorecase(current_search_val))
  	  	  match_count++;
  	  }
  	  return match_count + ' message' + (match_count>1?'s':'');
  	}
  }
  
  public void search_all_conversations() {
  	if((conversation_search==null?'':conversation_search)!='') {
  	  current_conversation_page = ConnectApi.ChatterMessages.searchConversations(conversation_search);
  	  last_conversation_page = null;
  	  currently_searching = true;
  	}
  }
      
  public void clear_message_search() {
  	conversation_search = 'Search all messages';
  	last_conversation_page = null;
  	current_conversation_page = ConnectApi.ChatterMessages.getConversations();
  	currently_searching = false;
  }
  
  public List<Conversation> getchatter_conversations() {
  	List<Conversation> conversations = new List<Conversation>();  		  
    List<ConnectApi.ChatterConversationSummary> conversation_summary_list = current_conversation_page.conversations;
    for(ConnectApi.ChatterConversationSummary conversation_summary : conversation_summary_list) {      
      conversations.add(new Conversation(conversation_summary,conversation_search));
    }  	  	  	   
    return conversations;
  }  
  
  public List<ConnectApi.ChatterMessage> getchatter_message_list() {
    ConnectApi.ChatterMessagePage message_page = ConnectApi.ChatterMessages.getMessages();
    return message_page.messages;
  }  
  
  public void add_message_recipient() {
  	if(message_recepients.size()<9) {
  	  Set<ConnectApi.UserDetail> recipient_set = new Set<ConnectApi.UserDetail> (message_recepients);
  	  recipient_set.add(ConnectApi.ChatterUsers.getUser(Network.getNetworkId(), apexpages.currentpage().getparameters().get('srid')));  	
  	  message_recepients = new List<ConnectApi.UserDetail> (recipient_set);
  	} else 
  	  display_to_error = true;
  }
  
  public void remove_message_recipient() {
  	Set<ConnectApi.UserDetail> recipient_set = new Set<ConnectApi.UserDetail> (message_recepients);
  	recipient_set.remove(ConnectApi.ChatterUsers.getUser(Network.getNetworkId(), apexpages.currentpage().getparameters().get('srid')));
  	message_recepients = new List<ConnectApi.UserDetail> (recipient_set);
  	display_to_error = false;
  }
  
  public String[] getoverview_tab_list() {
  	return new String[] {'Messages','Feed'};
  }
  
  public void switch_tabs() {
  	current_tab = apexpages.currentpage().getparameters().get('tname');
  	if(current_tab=='Messages') {
  	  detail_view = 'conversation_summary';
  	  last_conversation_page = null;
  	  current_conversation_page = ConnectApi.ChatterMessages.getConversations();
  	}
  } 
  
  public Boolean getdisplay_detail_next() {
  	return current_message_page.nextPageToken==null?false:true;
  }
  
  public Boolean getdisplay_detail_previous() {
  	return last_message_page==null?false:true;
  }
  
  public void next_detail_page() {
  	last_message_page = current_message_page;
    current_message_page = ConnectApi.ChatterMessages.getConversation(current_message_page.messages[0].conversationid, current_message_page.nextPageToken, null).messages;
  } 
  
  public void previous_detail_page() {
  	current_message_page = last_message_page;
  	//getting the last page before the last is a pain...they really need to include the token for this
  	last_message_page = null;
  	ConnectApi.ChatterConversation step_page = ConnectApi.ChatterMessages.getConversation(current_message_page.messages[0].conversationid);
  	while(last_message_page==null) {
  	  //did we get to the current page...if so exit
  	  if(step_page.messages.currentPageToken == current_message_page.currentPageToken)
  	    break;
  	    //did we find the previous page
  	  else if(step_page.messages.nextPageToken == current_message_page.currentPageToken) {
  	    last_message_page = step_page.messages;
  	    break;
  	  }
  	  else {
  	  	if(step_page.messages.nextPageToken==null)
  	  	  break;
  	  	else
  	  	  step_page = ConnectApi.ChatterMessages.getConversation(current_message_page.messages[0].conversationid,step_page.messages.nextPageToken, null);
  	  }
  	}
  }
  
      
  public void view_conversation_detail() {
  	detail_view = 'conversation_detail';
  	ConnectApi.ChatterConversation conv = ConnectApi.ChatterMessages.getConversation(apexpages.currentpage().getparameters().get('conid'));
  	current_message_page = conv.messages;
  	ConnectApi.ChatterMessages.markConversationRead(apexpages.currentpage().getparameters().get('conid'), true);
  	last_message_page = null;
  	detail_header = '';
  	for(ConnectApi.UserSummary usum : conv.members) {
  	  if(usum.id!=Userinfo.getUserId()) {
  	    if(detail_header!='')
  	      detail_header += ' and ';
  	    detail_header += usum.name;
  	  }
  	}  	  
  }
  
  public List<Conversation_detail> getchatter_conversation_details() {
  	List<Conversation_detail> conversation_details = new List<Conversation_detail>();  		  
    for(ConnectApi.ChatterMessage msg : current_message_page.messages) {
      if(currently_searching) {
        if(msg.body.text.containsignorecase(conversation_search))
          conversation_details.add(new conversation_detail(msg,conversation_search,currently_searching));
      }
      else
        conversation_details.add(new conversation_detail(msg,conversation_search,currently_searching));	
    }
    return conversation_details;
  }  
  
  public void send_new_message() {
  	//check for errors
  	String msg_to = '';
  	for(ConnectApi.UserDetail recipient : message_recepients) {
  	  if(msg_to!='')
  	    msg_to += ',' + recipient.id;
  	  else
  	    msg_to = recipient.id;
  	}
  	ConnectApi.ChatterMessages.sendMessage(message_body, msg_to);
  	message_body = '';
  	message_recepients = new List<ConnectApi.UserDetail>();
  	display_to_error = false;
  	display_new_message_modal = false;
  	detail_view = 'conversation_summary';
  	last_conversation_page = null;
  	current_conversation_page = ConnectApi.ChatterMessages.getConversations();
  }
  
  public void display_new_message_form() {
  	display_new_message_modal = true;
  	message_body = '';
  	message_recepients = new List<ConnectApi.UserDetail>();
  	display_to_error = false;  	
  }
  
  public void hide_new_message_form() {
  	display_new_message_modal = false;  	
  }
  
  public Boolean getdisplay_summary_next() {
  	return current_conversation_page.nextPageToken==null?false:true;
  }
  
  public Boolean getdisplay_summary_previous() {
  	return last_conversation_page==null?false:true;
  }
  
  public void next_summary_page() {
  	last_conversation_page = current_conversation_page;
    current_conversation_page = ConnectApi.ChatterMessages.getConversations(current_conversation_page.nextPageToken, null);
  } 
  
  public void previous_summary_page() {
  	current_conversation_page = last_conversation_page;
  	//getting the last page before the last is a pain...they really need to include the token for this
  	last_conversation_page = null;
  	ConnectApi.ChatterConversationPage step_page = ConnectApi.ChatterMessages.getConversations();
  	while(last_conversation_page==null) {
  	  //did we get to the current page...if so exit
  	  if(step_page.currentPageToken == current_conversation_page.currentPageToken)
  	    break;
  	    //did we find the previous page
  	  else if(step_page.nextPageToken == current_conversation_page.currentPageToken) {
  	    last_conversation_page = step_page;
  	    break;
  	  }
  	  else {
  	  	if(step_page.nextPageToken==null)
  	  	  break;
  	  	else
  	  	  step_page = ConnectApi.ChatterMessages.getConversations(step_page.nextPageToken, null);
  	  }
  	}
  }
  
  public void send_message_reply() {
  	if((message_body==null?'':message_body)!='') {
  	  ConnectApi.ChatterMessages.replyToMessage(message_body,current_message_page.messages[0].id);
  	  ConnectApi.ChatterConversation conv = ConnectApi.ChatterMessages.getConversation(current_message_page.messages[0].conversationId);
  	  current_message_page = conv.messages;
  	  last_message_page = null;
  	}
  	message_body = '';
  }
  
  public List<ConnectApi.UserDetail> getrecipient_search_results() {
  	System.debug('Message to : ' + message_to);
  	if(message_to==null)
  	  return null;
  	if(message_to.trim()=='')
  	  return null;  	
  	List<ConnectApi.UserDetail> user_matches = ConnectApi.ChatterUsers.searchusers(Network.getNetworkId(),message_to).users;
  	return user_matches;
  }
}