public with sharing class ctrl_schedule_template {
  public Schedule_Templates__c my_template {get;set;}
  public Template_Apt__c new_apt {get; set;}
  public String name_filter {get;set;}
  public String center_filter {get;set;}
  public String room_filter {get; set;}
  public String active_errors {get; set;} 
  public Boolean display_active {get; set;}
  public Boolean display_template {get; set;}
  public Boolean display_apt {get; set;}  
  public String update_errors {get; set;}
  public String newapt_errors {get; set;}   
  public String no_template_matches {get; set;}
  public String template_header {get; set;}  
  public Template_Apt__c[] existing_apts;
  public Boolean display_admin;
  public Boolean display_cc_sup;
  public Boolean display_confirmation; 
  String error_holder;
  public String update_msg {get; set;}
    
  public ctrl_schedule_template () {
  	name_filter = '';
  	center_filter = '';
  	room_filter = '';
  	update_errors = '';
  	newapt_errors = '';
  	template_header = '';
  	display_template = false;  	
  	display_apt = false;  	
  	display_active = true;
  	my_template = new Schedule_Templates__c();
  	  	
  	/*my_template = [Select s.Wednesday__c, s.Tuesday__c, s.Thursday__c, s.SystemModstamp, s.Sunday__c, s.Saturday__c, s.OwnerId, s.Name, s.Monday__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Friday__c, s.CreatedDate, s.CreatedById From Schedule_Templates__c s where id = 'a0fV000000148YFIAY'];
  	display_template = true;
  	display_apt = true;
  	template_header = 'Template Details';
  	new_apt = new Template_Apt__c();*/
  }
  
  public Pagereference deactivate_apt() {
  	//System.debug('Deactivate ID : ' + Apexpages.currentPage().getParameters().get('did'));
  	try {
  	  Template_Apt__c apt_delete = [select id,active__c from Template_Apt__c where id = :Apexpages.currentPage().getParameters().get('did')];
  	  apt_delete.active__c = false;
  	  update apt_delete;
  	}
  	catch (Exception e) {
  		update_errors = '<span class="blank" style="color:red;">Unable to deactivate appointment - Please see IT for help</span>';
  	}
  	return null;
  }
  
  public Pagereference modify_apts() {
  	Integer num_errors = 0;
  	error_holder = '';
  	System.debug('Working through : ' + existing_apts.size());
  	for(Template_Apt__c my_apt : existing_apts) {
  		System.debug('Existing Apt : ' + my_apt);
  		num_errors += apt_validation(my_apt);
  	}
  	if(num_errors==0) {
  	  update existing_apts;
  	  update_errors = '';
  	}
  	else
  	  update_errors = error_holder; 
  	return null;
  }
  
  public Boolean getdisplay_admin() {
  	if(display_admin==null) {
  		Integer admin_count = [select count() from Profile where name in ('CC Schedule Admin','Data Audit Team','System Administrator','RBD','New System Administrator') and id = :Userinfo.getProfileId()];  		
	    if(admin_count>0) 
	      display_admin = true;
	    else
	      display_admin = false;
  	}  	
	  return display_admin;
  }
  
  public Boolean getdisplay_confirmation() {
  	if(display_confirmation==null) {
  		Integer admin_count = [select count() from Profile where name in ('Outbound Call Center Agent','Outbound Call Center Agent (Test)','Outbound Call Center Agent Outsource','Outbound Call Center Jumpstart','Outbound Call Center Agent Test') and id = :Userinfo.getProfileId()];
	    if(admin_count>0) 
	      display_confirmation = true;
	    else
	      display_confirmation = false;
  	}
  	return display_confirmation;
  }
  
  public Boolean getdisplay_cc_sup() {
  	if(display_cc_sup==null) {
  		Integer admin_count = [select count() from Profile where name in ('Call Center - Supervisor','Call Center - Supervisor Test','CC Administrator') and id = :Userinfo.getProfileId()];
	    if(admin_count>0) 
	      display_cc_sup = true;
	    else
	      display_cc_sup = false;
  	}
  	return display_cc_sup;
  }
  
  public Integer apt_validation(Template_Apt__c test_apt) {
  	Integer num_errors = 0;
  	Integer shour, ehour, sminute, eminute;  	
  	try {
  		shour = Integer.valueOf(test_apt.Start_Hour__c);
  		if(shour<0 || shour>23) {
  		  error_holder += '<span class=\'blank\' style=\'color:red;\'>Starting Hour must be a number between 0 and 23</span><br />';
  		  num_errors++;
  	  }
  	}
  	catch (Exception e) {
  		error_holder += '<span class=\'blank\' style=\'color:red;\'>Starting Hour must be a number between 0 and 23</span><br />';
  		num_errors++;
  	}
  	try {
  		sminute = Integer.valueOf(test_apt.Starting_Minutes__c);
  		if(sminute<0 || sminute>59) {
  		  error_holder += '<span class=\'blank\' style=\'color:red;\'>Starting Minutes must be a number between 0 and 59</span><br />';
  		  num_errors++;
  	  }  	
  	}
  	catch (Exception e) {
  		error_holder += '<span class=\'blank\' style=\'color:red;\'>Starting Minutes must be a number between 0 and 59</span><br />';
  		num_errors++;
  	}
  	try {
  		ehour = Integer.valueOf(test_apt.Ending_Hour__c);
  		if(ehour<0 || ehour>23) {  
    		error_holder += '<span class=\'blank\' style=\'color:red;\'>Ending Hour must be a number between 0 and 23</span><br />';
  		  num_errors++;
  	  }
  	}
  	catch (Exception e) {
  		error_holder += '<span class=\'blank\' style=\'color:red;\'>Ending Hour must be a number between 0 and 23</span><br />';
  		num_errors++;
  	}  	
  	try {
  		eminute = Integer.valueOf(test_apt.Ending_Minutes__c);
  		if(eminute<0 || eminute>59) {
  		  error_holder += '<span class=\'blank\' style=\'color:red;\'>Ending Minutes must be a number between 0 and 59</span><br />';
  		  num_errors++;
  	  }
  	}
  	catch (Exception e) {
  		error_holder += '<span class=\'blank\' style=\'color:red;\'>Ending Minutes must be a number between 0 and 59</span><br />';
  		num_errors++;
  	}
  	  	
  	if(test_apt.Pre_Screen_Type__c==null) { 
  	  error_holder += '<span class=\'blank\' style=\'color:red;\'>You must select a Pre-Screen type</span><br />';
  	  num_errors++;
  	}
  	if(test_apt.Color_Code__c==null) { 
  	  error_holder += '<span class=\'blank\' style=\'color:red;\'>You must select a Color Code</span><br />';
  	  num_errors++;
  	}
  	if(num_errors==0) {
  	  Integer start_minutes = (shour * 60) + sminute;
  	  Integer end_minutes = (ehour * 60) + eminute;
  	  if(end_minutes < start_minutes) {
  	  	num_errors++;
  	  	error_holder += '<span class=\'blank\' style=\'color:red;\'>End Time must be greater than Start Time</span><br />';
  	  }  	    
  	}
  	return num_errors;
  }
  
  public Pagereference new_apt() {
  	error_holder = '';
  	System.debug('New Apt : ' + new_apt);
  	Integer num_errors = apt_validation(new_apt);  	
  	if(num_errors==0) {
  		new_apt.Schedule_Template__c = my_template.id;
  		new_apt.Active__c = true;
  	  insert new_apt;  
  	  new_apt = new Template_Apt__c();
  	  newapt_errors = '';
  	}
  	else
  	  newapt_errors = error_holder;
  	return null;
  }
  
  public Pagereference new_template_form() {
  	my_template = new Schedule_Templates__c(active__c = true);
  	template_header = 'New Template';
    display_template = true;	
    display_apt = false;    
    active_errors = '';
  	return null;
  }
  
  public Pagereference template_search() {
  	//action to handle a search on the template list
  	
  	return null;
  }
  
  public Pagereference template_view() {
  	String my_template_id = Apexpages.currentPage().getParameters().get('tid');
  	my_template = [Select s.active__c,s.Wednesday__c, s.Tuesday__c, s.Thursday__c, s.SystemModstamp, s.Sunday__c, s.Saturday__c, s.OwnerId, s.Name, s.Monday__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Friday__c, s.CreatedDate, s.CreatedById From Schedule_Templates__c s where id = :my_template_id];
  	display_template = true;
  	display_apt = true;
  	template_header = 'Template Details';
  	new_apt = new Template_Apt__c();
  	active_errors = '';
  	return null;
  }
  
  public void deactivate_template() {
  	Integer room_count = [select count() from Consult_Rooms__c where schedule_template__c = :my_template.id];
  	if(room_count==0) {
	    try {
	    	my_template.active__c = false;
	    	update my_template;
	    	active_errors = '<span class="blank" style="color:blue;font-weight:bold;">Success</span> - Template has been deactivated';
	    }
	    catch(Exception e) {
	    	active_errors = '<Span class="blank" style="color:red;font-weight:bold;">Error</span> - ' + e;
	    }
  	}
  	else
  	  active_errors = '<span class="blank" style="color:red;font-weight:bold;">Error - The template is currently assigned to ' + room_count + ' consult room(s).  Template can not be deactivated until it is not in use';
  }
  
  public void activate_template() {
  	try {
	  	my_template.active__c = true;
	  	update my_template;
	  	active_errors = '<span class="blank" style="color:blue;font-weight:bold;">Success</span> - Template has been marked as active';
  	}
  	catch (Exception e) {
  		active_errors = '<Span class="blank" style="color:red;font-weight:bold;">Error</span> - ' + e;
  	}
  }
  
  public Pagereference update_template() {
  	System.debug('My Template : ' + my_template);
  	update my_template;
  	my_template = [Select s.active__c,s.Wednesday__c, s.Tuesday__c, s.Thursday__c, s.SystemModstamp, s.Sunday__c, s.Saturday__c, s.OwnerId, s.Name, s.Monday__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Friday__c, s.CreatedDate, s.CreatedById From Schedule_Templates__c s where id = :my_template.id];
  	display_template = true;
  	display_apt = true;
  	template_header = 'Template Details';
  	update_msg = 'Done.  Update Complete';
  	active_errors = '';
    return null;	
  }
  
  public Pagereference new_template() {
  	System.debug('My Template : ' + my_template);
  	insert my_template;    
  	display_template = true;
  	display_apt = true;
  	template_header = 'Template Details';
    new_apt = new Template_Apt__c();
  	return null;
  }
  
  public list<Schedule_Templates__c> getTemplateList() {
  	//based on the search filter,  this function retuns a list of possible templates that can be viewed and modified
  	String query_filter = '';  	
  	if(name_filter!='' && name_filter!=null)
  	  query_filter += ' and name like \'%' + name_filter + '%\'';
  	if(center_filter!='' && center_filter!=null) {
  		Set<ID> center_template_id = new Set<Id>();
  		System.debug('Center : ' + center_filter);
  		for(Consult_Rooms__c room : [select schedule_template__c from Consult_Rooms__c where center_information__c = :center_filter]) {
  			center_template_id.add(room.schedule_template__c);
  		}
  		query_filter += ' and id in :center_template_id';
  	}
  	if(display_active)
  	  query_filter += ' and active__c = true';
  	else
  	  query_filter += ' and active__c = false';
  	List<Schedule_Templates__c> template_matches = new List<Schedule_Templates__c>();
  	System.debug('Template Query : ' + 'select id,name from Schedule_Templates__c where createdbyid!=null' + query_filter);
  	template_matches = database.query('select id,name from Schedule_Templates__c where createdbyid!=null' + query_filter + ' order by name');  	
    if(template_matches.size()==0)
      no_template_matches = '<span class="blank" style="color:red;">There are no templates that match your search criteria</span>';
    else
      no_template_matches = '';
  	return template_matches;
  } 
  
  public List<SelectOption> getCenterlist() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','None'));
    User u = [select id,clinic_calendar__c from User where id =:userinfo.getUserId()];
    if(u.clinic_calendar__c!=null) {	
  	  Center_Information__c ci = [select id,name,type__c,calendar_name__c from Center_Information__c where name = :u.Clinic_Calendar__c];
      if(ci.type__c=='Network Center') {
        options.add(new SelectOption(ci.id,ci.calendar_name__c));
      }
      else {
        list<Center_Information__C> centers = [Select c.id,c.name,calendar_name__c From Center_Information__c c order by c.name];  	  
        for(Center_Information__c center : centers) {
          options.add(new SelectOption(center.id,(center.calendar_name__c==null?center.name:center.calendar_name__c)));
        }
  	  }
    }
    else {
        list<Center_Information__C> centers = [Select c.id,c.name,c.calendar_name__c From Center_Information__c c order by c.name];  	  
        for(Center_Information__c center : centers) {
          options.add(new SelectOption(center.id,(center.calendar_name__c==null?center.name:center.calendar_name__c)));
        }
  	  }
    return options;
  }
  
  public Template_Apt__c[] getexisting_apts() {
  	if(update_errors=='') {
  	  existing_apts = [Select t.SystemModstamp, t.Starting_Minutes__c, t.Start_Hour__c, t.Schedule_Template__c, t.Pre_Screen_Type__c, t.Name, t.LastModifiedDate, t.LastModifiedById, t.IsDeleted, t.Id, t.Ending_Minutes__c, t.Ending_Hour__c, t.CreatedDate, t.CreatedById, t.Color_Code__c,t.Starting_Hour_Int__c,t.Start_Min_Int__c, t.special_initiative__c From Template_Apt__c t where active__c = true and schedule_template__c = :my_template.id order by t.Starting_Hour_Int__c];
  	}
  	return existing_apts;
  }
  
  public class Calendar_Apts {
  	public Template_Apt__c capt {get; set;}
  	public Integer crowspan {get;set;}
  	public Integer cheight {get;set;}
  	public Integer ctop {get; set;}  	
  	public String cclass {get;set;}
  	public Calendar_Apts(Template_Apt__c my_apt, Integer tick_minutes) {
  		this.capt = my_apt;
  		Integer start_minutes = (Integer.valueof(my_apt.start_hour__c) * 60) + Integer.valueof(my_apt.starting_minutes__c);
  		Integer end_minutes = (Integer.valueof(my_apt.ending_hour__c) * 60) + Integer.valueof(my_apt.ending_minutes__c);
  		Integer total_minutes = end_minutes - start_minutes;
  		Boolean calc_rows = true;
  		crowspan = 0;
  		Integer shour = Integer.valueof(my_apt.Start_Hour__c);
  		Integer sminute = tick_minutes;
  		while(calc_rows) {  			
  			if(shour < Integer.valueof(my_apt.Ending_Hour__c) || (shour == Integer.valueof(my_apt.Ending_Hour__c) && sminute <= Integer.valueof(my_apt.Ending_Minutes__c))) 
  				crowspan++;
  			else {
  				if(Integer.valueof(my_apt.Ending_Minutes__c)>(sminute-15))
  				  crowspan++;
  				calc_rows = false;
  			}
  		  System.debug('Apt : ' + my_apt.name + ' Shour : ' + shour + ' Sminute ' + sminute + ' Crowspan : ' + crowspan);
  			if(sminute==45) {
  				sminute = 0;
  				shour++;
  			}
  			else
  			  sminute += 15;  			 
  		}  		  		  
  		crowspan--;		  
  		Double holder = math.ceil(total_minutes / 15);
  		//crowspan = holder.intValue();
  		//crowspan = 6;
  		cheight = total_minutes;
  		cheight += (holder.intValue());
  		ctop = Integer.valueof(my_apt.starting_minutes__c) - tick_minutes;
  		if(my_apt.color_code__c=='Light Blue')
  		  this.cclass = 'apt_blue';
  		if(my_apt.color_code__c=='Light Purple')
  		  this.cclass = 'apt_purple';	
  		if(my_apt.color_code__c=='Light Brown')
  		  this.cclass = 'apt_brown';	
  		if(my_apt.color_code__c=='Light Red')
  		  this.cclass = 'apt_red';
  		if(my_apt.color_code__c=='Light Green')
  		  this.cclass = 'apt_green';
  		if(my_apt.color_code__c=='Light Grey')
  		  this.cclass = 'apt_grey';
  		if(my_apt.color_code__c=='Light Yellow')
  		  this.cclass = 'apt_yellow';
  		if(my_apt.color_code__c=='Light Orange')
  		  this.cclass = 'apt_orange'; 
  	    if(my_apt.color_code__c=='Network Purple')
  		  this.cclass = 'apt_barney';    
  	}
  	public String getstart_time() {
  		String label = capt.start_hour__c + ':' + capt.starting_minutes__c;
  		return label;
  	}
  	public String getend_time() {
  		String label = capt.ending_hour__c + ':' + capt.ending_minutes__c;
  		return label;
  	}
  	public String getprescreen_label() {
  	  String label = '';
  	  if(capt.pre_screen_type__c=='Green/Yellow')
  	    label = 'Green/Yellow';
  	  if(capt.pre_screen_type__c=='Green/Yellow Only')
  	    label = 'G/Y Only';
  	  if(capt.pre_screen_type__c=='Any')
  	    label = 'Any';
  	  if(capt.pre_screen_type__c=='Red/Blue Only')
  	    label = 'R/B Only';
  	  return label;	
  	} 
  }
  
  public class Calendar_Rows {
  	Integer chours, cminutes;
  	public String cclass {get;set;}
  	public Boolean display_label {get; set;} 
  	public Calendar_Apts[] row_apts {get; set;}
  	public Calendar_Rows(Integer h, Integer m, Template_Apt__c[] all_apts) {
  		this.row_apts = new Calendar_Apts[] {};
  		this.chours = h;
  		this.cminutes = m;  	
  		if(cminutes==0 || cminutes==30) {
  			display_label = true;
  			cclass = 'maintick';
  		}
  		else {
  			display_label = false;
  			cclass = 'subtick';
  		}
  		//run through and build an array of calendar apts;
  		Integer m_end = m+14;  		
 		  System.debug('Select t.Starting_Minutes__c, t.Start_Hour__c, t.Schedule_Template__c, t.Pre_Screen_Type__c, t.Ending_Minutes__c, t.Ending_Hour__c, t.Color_Code__c,t.special_initiative__C From Template_Apt__c t where active__c = true and t.Starting_Hour_Int__c = ' + h + ' and t.Start_Min_Int__c >= ' + m + ' and t.Start_Min_Int__c < ' + m_end);
  		for(Template_Apt__c my_apt : all_apts) {
  		  if(my_apt.Starting_Hour_Int__c == h && my_apt.Start_Min_Int__c >= m && my_apt.Start_Min_Int__c <= m_end) {
  		    Calendar_Apts row_apt = new Calendar_Apts(my_apt, m);
  		    this.row_apts.add(row_apt);
  		  }  	
  		}
  	}  	
  	public String getrow_label() {
  		String prefix = '';
  		if(chours > 12) {
  			prefix = 'PM';
  			chours -= 12;
  		}
  		else
  		  prefix = 'AM';
  		String rlabel = String.valueof(chours) + ':';
  		if(cminutes < 10)
  		  rlabel += '0';
  		rlabel += cminutes + ' ' + prefix;
  		return rlabel;
  	}
  }
  
  public Calendar_Rows[] getview_calendar() {
  	Calendar_Rows[] my_rows = new Calendar_Rows[] {};
    Boolean generate_calendar = true;
    Integer shour = 7;
    Integer sminutes = 0;
    while(generate_calendar) {
    	System.debug('Hour : ' + shour + ' Minutes : ' + sminutes);
    	Calendar_Rows crow = new Calendar_Rows(shour, sminutes, existing_apts);
    	if(sminutes == 45) {
    		shour++;
    		sminutes = 0;
    	}
    	else
    	  sminutes += 15;    	
    	if(shour > 19)
    	  generate_calendar = false;
    	my_rows.add(crow);
    } 	
    return my_rows;
  }
}