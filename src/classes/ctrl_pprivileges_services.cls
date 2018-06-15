public with sharing class ctrl_pprivileges_services {
  public Boolean display_clearviewtv {get;set;}
  public Boolean display_cleartrain {get;set;}
  public Boolean display_clearweb {get;set;}
  public Boolean display_clearvantage {get; set;}
  public Boolean display_clearconnect {get;set;}  
  public Boolean display_admin {get; set;} 
  public Dental_Practice__c dp {get;set;}
  public Boolean display_search {get;set;}
  public Boolean display_update_form {get; set;}
  public Boolean display_completed {get; set;}  
  public List<ClearTV_Campaign__c> current_campaigns;
  public ClearTV_Campaign__c new_campaign {get; set;}
  public Note new_note {get; set;}
  public List<Note> current_notes;
  public List<Task> current_tasks;
  public String pprovider;
    
  public ctrl_pprivileges_services() {
  	dp = null;
  	display_completed = false;
  	display_search = true;
  	display_update_form = false;
  	display_clearviewtv = false;
  	display_cleartrain = false;
  	display_clearweb = false;
  	display_clearvantage = false;
  	display_clearconnect = false;
  	display_admin = false;  	 
  	//grab provider field from user record
  	if(apexpages.currentpage().getparameters().get('ppid')==null) {
  	  pprovider = [select Practice_Privileges_Provider__c from User where id = :Userinfo.getUserId()].Practice_Privileges_Provider__c;
  	  if(pprovider!=null) {
	  	if(pprovider.toLowerCase()=='clearviewtv') 
	  	  display_clearviewtv = true;
	  	if(pprovider.toLowerCase()=='cleartrain')
	  	  display_cleartrain = true;
	  	if(pprovider.toLowerCase()=='clearweb')
	  	  display_clearweb = true;
	  	if(pprovider.toLowerCase()=='clearvantage')
	  	  display_clearvantage = true;
	  	if(pprovider.toLowerCase()=='clearconnect')
	  	  display_clearconnect = true;
  	  }
  	  else {
  	  	pprovider = 'Admin';
  	    display_admin = true;
  	  }
  	}
  	//parameter override - just for testing purposes
  	else {
  	  pprovider = 'Admin';
  	  display_admin = true;
  	  if(apexpages.currentpage().getparameters().get('ppid')=='1') {
  	  	display_clearviewtv = true;
  	  }
  	  else if(apexpages.currentpage().getparameters().get('ppid')=='2') {
  	  	display_cleartrain = true;
  	  }
  	  else if(apexpages.currentpage().getparameters().get('ppid')=='3') {
  	  	display_clearweb = true;
  	  }
  	  else if(apexpages.currentpage().getparameters().get('ppid')=='4') {
  	  	display_clearvantage = true;
  	  }
  	  else if(apexpages.currentpage().getparameters().get('ppid')=='5') {
  	  	display_clearconnect = true;
  	  }
  	}    	  	
  }
  
  public class merge_note implements Comparable {
  	public String note_title {get;set;}
  	public String note_detail {get;set;}
  	public datetime cdate {get; set;}
  	
  	public merge_note(String in_title,String in_detail,Datetime in_date) {
  	  this.note_title = in_title;
  	  this.note_detail = in_detail;
  	  this.cdate = in_date;
  	}
  	
  	public String getformated_cdate() {
  	  return cdate.format('M/d/YYYY h:mm:ss');
  	}
  	
  	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      merge_note compareTonote = (merge_note)compareTo;
        
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (cdate > compareTonote.cdate) {
        // Set return value to a positive value.
        returnValue = -1;
      } else if (cdate < compareTonote.cdate) {
        // Set return value to a negative value.
        returnValue = 1;
      }        
      return returnValue;       
    }
  }
  
  public Pagereference display_image_page() {
  	Pagereference pr = Page.practice_images;
  	pr.getParameters().put('dpid',dp.id);     
    pr.setredirect(true);
    return pr;
  }
  
  public List<SelectOption> getCompany_Options() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('false','Show Uncompleted Companies')); 
    options.add(new SelectOption('true','Show Completed Companies')); 
    return options; 
  }
  
  public class pmember {
  	public Dental_Practice__c practice {get; set;}
  	public Practice_Doctor__c doctor {get; set;}
  	List<Note> notes_list {get; set;}
  	public pmember(Dental_Practice__c dp, Practice_Doctor__c pd, List<Note> note_list) {
  	  this.practice = dp;
  	  this.doctor = pd;
  	  this.notes_list = note_list;
  	}
  	
  	public String geteffective_date() {
  	  try {
  	    return practice.effective_date__c.format();
  	  }
  	  catch (Exception e) {
  	  	return null;
  	  }
  	}
  	
  	public String getfirst_note_date() {
  	  try {
  	    return notes_list[0].createddate.format('M/d/yyyy h:mm');
  	  }
  	  catch (Exception e) {
  	  	System.debug('Notes Issue : ' + e);
  	  	return null;
  	  }
  	}
  	
  	public String getlast_note_date() {
  	  try {
  	    Integer i = notes_list.size() - 1;
  	    return notes_list[i].createddate.format('M/d/yyyy h:mm');
  	  }
  	  catch (Exception e) {
  	  	System.debug('Notes Issue : ' + e);
  	  	return null;
  	  }  	  
  	}
  	
  	public String getfirst_note_text() {
  	  try {
  	  	return notes_list[0].body;
  	  }
  	  catch(exception e) {
  	  	System.debug('Notes Issue : ' + e);
  	  	return null;
  	  }  	  
  	}
  	
  	public String getlast_note_text() {
  	  try {
  	  	Integer i = notes_list.size() - 1;
  	  	return notes_list[i].body;
  	  }
  	  catch(exception e) {
  	  	System.debug('Notes Issue : ' + e);
  	  	return null;
  	  }  	  
  	}
  	  	
  	public Integer getnum_notes() {
  	  return notes_list.size();
  	}
  }
  
  /*public List<Dental_Practice__c> getpractice_list() {
  	List<Dental_Practice__c> dp_list;
  	String query_filter = 'where refer_to_this_practice__c = true';
  	String boolean_val = '';
  	if(display_completed==false) 
  	  boolean_val = 'false';  	  
  	else 
  	  boolean_val = 'true';  	
  	if(display_clearviewtv) 
  	  query_filter += ' and ClearViewTV_complete__c = ' + boolean_val;
  	if(display_cleartrain)
  	  query_filter += ' and ClearTrain_Complete__c = ' + boolean_val;
  	if(display_clearweb)
  	  query_filter += ' and ClearWeb_Complete__c = ' + boolean_val;
  	if(display_clearvantage)
  	  query_filter += ' and ClearVantage_Complete__c = ' + boolean_val;
  	if(display_clearconnect)
  	  query_filter += ' and ClearConnect_Complete__c = ' + boolean_val;
  	//pull the dental practice list to display     
  	dp_list = database.query('Select d.id, d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Primary_Contact_Email__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.City__c, d.Alt_Phone__c,(Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c From Practice_Doctors__r),(Select Id, Title, Body From Notes where createdby = :Userinfo.getUserId() order by createddate) From Dental_Practice__c d ' + query_filter);  	  
  	return dp_list;
  }*/
  
  public List<pmember> getpractice_list() {
  	List<Dental_Practice__c> dp_list;  
  	String query_filter = 'where display_to_vendor__c = true and psa_effective_date__c <= 2015-06-20 ';
  	if(test.isRunningTest())
  	  query_filter = 'where display_to_vendor__c = true ';
  	String boolean_val = '';
  	if(display_completed==false) 
  	  boolean_val = 'false';  	  
  	else 
  	  boolean_val = 'true';  	
  	if(display_clearviewtv) 
  	  query_filter += ' and ClearViewTV_complete__c = ' + boolean_val;
  	if(display_cleartrain)
  	  query_filter += ' and ClearTrain_Complete__c = ' + boolean_val;
  	if(display_clearweb)
  	  query_filter += ' and ClearWeb_Complete__c = ' + boolean_val;
  	if(display_clearvantage)
  	  query_filter += ' and ClearVantage_Complete__c = ' + boolean_val;
  	if(display_clearconnect)
  	  query_filter += ' and ClearConnect_Complete__c = ' + boolean_val;
  	//pull the dental practice list to display     
  	dp_list = database.query('Select d.effective_date__c,d.id, d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Primary_Contact_Email__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.City__c, d.Alt_Phone__c,(Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c From Practice_Doctors__r),(Select Id, Title, Body,createddate From Notes where CreatedById = \'' + Userinfo.getUserId() + '\' order by createddate) From Dental_Practice__c d ' + query_filter + ' order by d.effective_date__c');
  	List<pmember> return_list = new List<pmember>();
  	for(Dental_Practice__c dp : dp_list) {
  	  pmember p = new pmember(dp,dp.practice_doctors__r[0],dp.notes);
  	  return_list.add(p);
  	}
  	return return_list;
  }
    
  public void update_practice() {
  	try {
  	  update dp;
  	  display_search = true;
  	  display_update_form = false;
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Record has been updated'));  	  	
    } catch(Exception e) {    	
      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error during update: ' + e));
    }	
  }
  
  public void cancel_update() {
  	display_search = true;
  	display_update_form = false;
  }
  
  public void select_practice() {
  	try {
  	  dp = [Select d.ClearWeb_Sample_URL__c,d.ClearWeb_Username__c, d.ClearWeb_Primary_Contact__c, d.ClearWeb_Password__c,d.Center_Information__r.name,d.Vantage_OfficeID__c,d.Why_was_it_rescheduled__c, 
  	    d.When_did_the_site_go_live__c, d.Serial_of_the_media_player__c, d.Serial_of_the_TV__c, d.Seats_in_the_office__c, d.Scheduled_ghost_call__c, 
  	    d.Does_the_practice_have_a_TV__c, d.Completed_Ghost_Call__c, d.ClearWeb_Domain_Name__c, d.ClearWeb_Complete__c, d.ClearViewTV_site_installation_date__c, d.ClearViewTV_order__c, 
  	    d.ClearViewTV_installation_Type__c, d.ClearViewTV_complete__c, d.ClearVantage_Live_Date__c, d.ClearVantage_Complete__c, d.ClearTrain_live_training_date__c, d.ClearTrain_Complete__c, 
  	    d.ClearConnect_Live_Date__c, d.Services_Offered__c, d.ClearConnect_Complete__c, d.Best_Buy_site_service_date__c, d.Best_Buy_rescheduled_date__c, d.Best_Buy_date_of_service__c, d.Best_Buy_Completed_Date__c ,
  	    d.id,d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Primary_Contact_Email__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.City__c, d.Alt_Phone__c,
  	    d.Practice_Management_Software__c, d.Is_your_tv_mounted_to_the_wall__c, d.Is_your_TV_mounted_to_the_ceiling__c, d.Is_it_HDMI_compatible__c, d.Do_you_have_a_TV__c,d.Windows_server_type__c, (Select First_Name__c, Last_Name__c, Email__c, Phone__c, Alt_Phone__c From Practice_Doctors__r) From Dental_Practice__c d
  	     where id = :apexpages.currentpage().getparameters().get('pid')];
	  new_campaign = new ClearTV_Campaign__c(dental_practice__c = dp.id);
	  String note_title = pprovider + ' Note';  
	  new_note = new Note(title=note_title, parentid = dp.id);	     
  	  display_search = false;
  	  display_update_form = true;
  	} catch(Exception e) {    	
      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error during practice lookup : ' + e));
    }	  	
  }
  
  public void delete_practice() {
  	try {
  	  ClearTV_Campaign__c remove_campaign = [select id from ClearTV_Campaign__c where id = :apexpages.currentpage().getparameters().get('cid')];
  	  delete remove_campaign;
  	  current_campaigns = [select id,name,start_date__c,end_date__c from ClearTV_Campaign__c where dental_practice__c = :dp.id order by start_date__c desc];
  	} catch (Exception e) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error removing the campaign : ' + e));
  	}
  	
  }
  
  public List<ClearTV_Campaign__c> getcurrent_campaigns() {
  	if(current_campaigns==null) {
  	  current_campaigns = [select id,name,start_date__c,end_date__c from ClearTV_Campaign__c where dental_practice__c = :dp.id order by start_date__c desc];
  	}
  	return current_campaigns;  	
  }
  
  /*public List<Note> getcurrent_notes() {
  	if(current_notes==null) {
  	  if(display_clearvantage || display_clearweb)
  	    current_notes = [Select n.Title, n.ParentId, n.CreatedDate, n.Body From Note n where n.parentid = :dp.id order by createddate desc];
  	  else
  	    current_notes = [Select n.Title, n.ParentId, n.CreatedDate, n.Body From Note n where n.parentid = :dp.id and n.ownerid = :userinfo.getUserId() order by createddate desc];
  	}
  	return current_notes;
  }
  
  public List<Task> getcurrent_tasks() {
  	if(current_tasks==null) {
  	  if(display_clearvantage || display_clearweb)
  	    current_tasks = [Select t.Type, t.Subject, t.Description, t.CreatedDate From Task t where t.whatid = :dp.id order by createddate desc];
  	  else
  	    current_tasks = [Select t.Type, t.Subject, t.Description, t.CreatedDate From Task t where t.whatid = :dp.id and t.ownerid = :userinfo.getUserId() order by createddate desc];
  	}
  	return current_tasks;
  }*/
  
  public merge_note[] getall_notes() {  	
  	System.debug('Display Admin : ' + display_admin);
  	List<merge_note> merge_notes = new List<merge_note>();
  	//pull the note list
  	List<Note> all_notes;
  	if(display_clearvantage || display_clearweb || display_admin)
  	  all_notes = [Select n.Title, n.ParentId, n.CreatedDate, n.Body From Note n where n.parentid = :dp.id order by createddate desc];
  	else
  	  all_notes = [Select n.Title, n.ParentId, n.CreatedDate, n.Body From Note n where n.parentid = :dp.id and n.ownerid = :userinfo.getUserId() order by createddate desc];
  	for(Note n : all_notes) {
  	  merge_note mn = new merge_note(n.title,n.body,n.createddate);
  	  merge_notes.add(mn);
  	}
  	//pull the task list
  	List<Task> all_tasks = new List<Task>();
  	if(display_clearvantage || display_clearweb || display_admin) {
  	  all_tasks = [Select t.Type, t.Subject, t.Description, t.CreatedDate From Task t where t.whatid = :dp.id order by createddate desc];
  	//else
  	  //current_tasks = [Select t.Type, t.Subject, t.Description, t.CreatedDate From Task t where t.whatid = :dp.id and t.ownerid = :userinfo.getUserId() order by createddate desc];
	  for(Task t: all_tasks) {
	  	merge_note mn = new merge_note(t.subject,t.description,t.createddate);
	    merge_notes.add(mn);	
	  }
  	}
  	merge_notes.sort();
  	return merge_notes;
  }
  
  public void add_campaign() {
  	if(new_campaign.start_date__c==null) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must enter a starting date for a new campaign'));
  	  return;
  	}
  	if(new_campaign.end_date__c==null) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must enter an ending date for a new campaign'));
  	  return;
  	}
  	if(new_campaign.name==null) {  	
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must enter a name for a new campaign'));
  	  return;
  	}  	  
  	try {
  	  insert new_campaign;
  	  new_campaign = new ClearTV_Campaign__c(dental_practice__c = dp.id);
  	  current_campaigns = [select id,name,start_date__c,end_date__c from ClearTV_Campaign__c where dental_practice__c = :dp.id order by start_date__c desc];
  	}
  	catch (Exception e) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error during campaign creation : ' + e));
  	}
  }
  
  public void add_note() {
  	if(new_note.body==null) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not add a blank note'));
  	  return;
  	}
  	if(new_note.body.trim()=='') {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not add a blank note'));
  	  return;
  	}
  	try {
  	  insert new_note;
  	  String note_title = pprovider + ' Note';  
	  
	  //current_notes = [Select n.Title, n.ParentId, n.CreatedDate, n.Body From Note n where n.parentid = :dp.id and n.ownerid = :userinfo.getUserId() order by createddate desc];
	  //send an email out to the team with details on the notes for now (this might get pulled later)
	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  //String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	  String[] toAddresses = new String[] {'pburns@clearchoice.com','selterich@clearchoice.com','rballi@clearchoice.com','nambos@clearchoice.com','cmcdowell@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com'};
	  mail.setToAddresses(toAddresses);
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
      if ( owea.size() > 0 ) {
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
      }
	  mail.setReplyTo('practicedevelopment@clearchoice.com');
	  //mail.setSenderDisplayName('Practice Privileges');
	  mail.setSubject('New Note for ' + dp.name);
	  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		'<title>New Note added by ' + pprovider + '</title><style type="text/css">' + 
		'@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	} ' +
		'.column { width:200px;     float:left;		 padding-left:10px;		}	h2 {	font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;	color:#075094;	font-size:18px;		line-height:7px;	text-align:left;		}	</style>' +
        '</head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table--><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">' + 
		'<tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
		'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
		'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" width="175" style="width: 175px; height: auto;"  alt="" border="0"></a>' + 
		'</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;"><tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' + 
		'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--> </td></tr><tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;">' +
		'</td>' + 
		'</tr>						<tr valign="top">									<td>					<!-- Wrapper 2 (Banner 1) -->		<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">									<tr>' + 
		'<td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' + 
		'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text -->' + 
        '<table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' + 
        '</td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --> </td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">' + 
        '<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:36px; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">' + 
         + dp.Name + '</div>' +
		'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">' +   
        '<p style="padding-left:20px;color:#075094; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;">' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name</span>' + dp.practice_doctors__r[0].first_name__c + ' ' + dp.practice_doctors__r[0].last_name__c + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Doctor Phone</span>' + dp.practice_doctors__r[0].phone__c  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Doctor Email</span>' + dp.practice_doctors__r[0].email__c  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Primary Contact</span>' + dp.primary_contact_name__c  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Contact Email</span>' + dp.primary_contact_email__c  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Contact Phone</span>' + dp.phone__c  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">City</span>' + dp.city__c  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">CC Center</span>' + dp.Center_Information__r.name  + '<br />' +
		'<span style="font-weight:bold;width:150px;display:inline-block;">Website</span>' + dp.Practice_Website__c  + '<br />' +
		'</p>' +
		'<p>Note added by ' + pprovider + '</p>' + 
		'<p><b>Note</b> - <span style="font-style:italics">' + new_note.body + '</span></p>' +		
		'</td></tr></tbody></table></td></tr>	<tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody>' + 
		'<tr valign="top"><td width="375" style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />' + 
		'888-808-7033</td><td width="325" style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /> <span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Privileges" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright ClearChoice. All rights reserved.</span></td>' + 
		'</tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		new_note = new Note(title=note_title, parentid = dp.id);
  	}
  	catch (Exception e) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error during note creation : ' + e));
  	}
  }
  
}