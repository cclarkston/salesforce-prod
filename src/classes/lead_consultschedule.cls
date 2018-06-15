public class lead_consultschedule {
  private final Lead l;
  ApexPages.Standardcontroller con;
  public Boolean has_searched {get; set;}
  public next_consult[] search_consult_results;
  public Boolean sMonday {get;set;}
  public Boolean sTuesday {get;set;}
  public Boolean sWednesday {get;set;}
  public Boolean sThursday {get;set;}
  public Boolean sFriday {get;set;}
  public Boolean sSaturday {get;set;}
  public Boolean sSunday {get;set;}
  public Boolean seminar {get; set;}
  public Consult_Inventory__c block_form {get; set;}
  public Integer stime_filter {get;set;}
  public Integer etime_filter {get;set;}
  public String search_issues {get;set;}
  public String schedule_issues {get;set;}
  public String lead_valid_errors {get; set;}

  public lead_consultschedule(ApexPages.StandardController stdController) {
    this.l = (Lead)stdController.getRecord();
    con = stdController;
	has_searched = false;
    sMonday = true;
    sTuesday = true;
    sWednesday = true;
    sThursday = true;
    sFriday = true;
    sSaturday = true;
    sSunday = true;
    block_form = new Consult_Inventory__c(apt_date__c = System.today());
    lead_valid_errors = '';
    Integer admin_count = [select count() from Profile where name in ('Marketing Administrator Test','Marketing Administrator w/o Delete','Center Administrator') and id = :Userinfo.getProfileId()];
    if(admin_count>0)
      seminar = true;
    else
      seminar = false;
  }

  public Integer getschedule_num() {
	  return [select count() from Consult_Inventory__c where scheduled_lead__c = :l.id and active__c = true];
  }

  public Integer getcontact_num() {
  	return [select count() from Task where whoid = :l.id and activity_type__c = 'Inbound Call'];
  }

  public next_consult[] getsearch_consult_results() {
  	if(search_consult_results==null)
  	  search_consult_results = new next_consult[] {};
  	return search_consult_results;
  }

  public integer getaval_size() {
  	return search_consult_results.size();
  }

  // public String getscheduled_date() {
  // 	Lead holder = [select datetime_consult_scheduled__c from lead where id = :l.id];
  // 	String return_val;
  // 	if(holder.DateTime_Consult_Scheduled__c==null)
  // 	  return_val = '<span class="blank" style="color:red">No consult scheduled</span>';
  // 	else
  // 	  return_val = String.valueOf(holder.datetime_consult_scheduled__c.format('M/dd/yyyy hh:mm:ss'));
  // 	return return_val;
  // }

  public String getcurrent_aptid() {
  	List<Consult_Inventory__c> current_apt = [select id from Consult_Inventory__c where scheduled_lead__c = :l.id and active__c = true order by apt_date__c desc limit 1];
  	if(current_apt.size()>0)
  	  return string.valueof(current_apt[0].id);
  	else
  	  return null;
  }

	public String getscheduled_consults_string() {
		// We'd like there to only be one consult, so the join shouldn't ever actually join multiple fields.
		// However, at time of writing (3/2017), there's a bug allowing multiple consults to be scheduled for a single patient which is why this solution is necessary.
		String[] consult_strings = new String[]{};
		Consult_Inventory__c[] consults = [SELECT Apt_Date__c, Start_Hour__c, Start_Minute__c FROM Consult_Inventory__c WHERE Scheduled_Lead__c = :l.id AND Active__c = TRUE AND Apt_Date__c >= TODAY ORDER BY Scheduled_Time__c DESC];
		for (Consult_Inventory__c consult : consults) {consult_strings.add(datetime_string(consult));}
		return consult_strings.size() > 0 ? String.join(consult_strings, ' -- ') : 'None';
	}
			private String datetime_string(Consult_Inventory__c consult) {
				return String.valueOf(consult.Apt_Date__c.format()) + ' ' + time_string(consult.Start_Hour__c, consult.Start_Minute__c);
			}
					private String time_string(String hour, String minute) {
						Integer hour_value = Integer.valueOf(hour);
						if (hour_value > 12) {hour = String.valueOf(hour_value - 12);}
						if (minute.length() == 1) {minute = '0' + minute;}
						String meridiem = hour_value < 12 ? 'AM' : 'PM';
						return hour + ':' + minute + ' ' + meridiem;
					}

	public String getprevious_consult_string() {
		Consult_Inventory__c[] consults = [SELECT Apt_Date__c, Start_Hour__c, Start_Minute__c FROM Consult_Inventory__c WHERE Scheduled_Lead__c = :l.id AND Active__c = TRUE AND Apt_Date__c < TODAY ORDER BY Apt_Date__c DESC LIMIT 1];
		return !consults.isEmpty() ? datetime_string(consults[0]) : 'None';
	}

  public String getopen_schedule_test() {
    Pagereference pr = Page.sandbox_calendar;
    pr.getParameters().put('aid',getcurrent_aptid());
    pr.getParameters().put('lid',l.id);
    pr.setredirect(true);
    return pr.getUrl();
  }

	public String time_group {get; set;} {time_group = '0';}
	public List<Selectoption> gettime_group_options() {
		String[] values = new String[]{'Any', 'Morning', '10am - 2pm', 'Afternoon'};
		List<SelectOption> options = new List<SelectOption>();
		for (Integer i = 0; i < values.size(); i++) {options.add(new SelectOption(String.valueOf(i), values[i]));}
		return options;
	}
	public List<Selectoption> yes_no_options {get; set;} {yes_no_options = new List<SelectOption>{new SelectOption('Yes','Yes'), new SelectOption('No','No')};}

	private void set_start_and_end_filters() {
		// Set start and end times correlating to the four time groups - 'Any', 'Before noon', '10am - 2pm', 'After noon'
		if (time_group == null) {time_group = '0';}
		if 		  (time_group == '0') {
			stime_filter = 1;
			etime_filter = 23;
		} else if (time_group == '1') {
			stime_filter = 1;
			etime_filter = 11;
		} else if (time_group == '2') {
			stime_filter = 10;
			etime_filter = 13;
		} else if (time_group == '3') {
			stime_filter = 12;
			etime_filter = 23;
		}
	}




  public class next_consult {
  	public Consult_Inventory__c apt_block {get;set;}
  	public next_consult(Consult_Inventory__c my_block) {
  		this.apt_block = my_block;
  	}
  	public String getday_of_week() {
  		if(apt_block.dow_int__c == 1)
  		  return 'Monday';
  		else if(apt_block.dow_int__c == 2)
  		  return 'Tuesday';
  		else if(apt_block.dow_int__c == 3)
  		  return 'Wednesday';
  		else if(apt_block.dow_int__c == 4)
  		  return 'Thursday';
  		else if(apt_block.dow_int__c == 5)
  		  return 'Friday';
  		else if(apt_block.dow_int__c == 6)
  		  return 'Saturday';
  		else
  		  return 'Sunday';
  	}

  	public String getroom_name() {
  		String room_name = '';
  		if(apt_block.consult_room__r.room_type__c=='OverFlow')
  		  room_name = '<span style=\'font-weight:bold;color:red;\'>' + apt_block.consult_room__r.Name + '</span>';
  		else
  		  room_name = apt_block.consult_room__r.name;
  		return apt_block.Consult_Room__r.Name;
  	}

  	public String getstart_time() {
  		Integer sh = integer.valueof(apt_block.start_hour__c);
  		String suffix = '';
  		if(sh>12) {
  		  sh = sh - 12;
  		  suffix = 'PM';
  		}
  		else if(sh==12)
  		  suffix = 'PM';
  		else
  		  suffix = 'AM';
  		if(apt_block.start_minute__c=='0')
  		  return sh + ':00 ' + suffix;
  		else
  		  return sh + ':' + apt_block.start_minute__c + ' ' + suffix;
  	}

 //  	public String getend_time() {
 //  	  Integer sh = integer.valueof(apt_block.end_hour__c);
 //  		String suffix = '';
 //  		if(sh>12) {
 //  		  sh = sh - 12;
 //  		  suffix = 'PM';
 //  		}
 //  		else if(sh==12)
 //  		  suffix = 'PM';
 //  		else
 //  		  suffix = 'AM';
 //  		if(apt_block.end_minute__c=='0')
 //  		  return sh + ':00 ' + suffix;
 //  		else
 //  		  return sh + ':' + apt_block.end_minute__c + ' ' + suffix;
 //  	}

	public String getroom_type() {
  		return apt_block.Consult_Room__r.Room_Type__c.toLowerCase();
  	}

	public Integer gethold_minutes() {
		// Returns the number of minutes remaining on a hold (technically, the latest hold if there are more than one)
		// Returns zero if there are no holds or if the most recent hold is no longer valid.
		Consult_Holds__c[] holds = [SELECT Hold_Time__c FROM Consult_Holds__c WHERE Consult_Inventory__c = :apt_block.ID AND Active_Hold__c = TRUE
									AND Hold_By__c != :UserInfo.getUserId()
									ORDER BY Hold_Time__c DESC LIMIT 1];
		if (holds.isEmpty()) {return 0;}
		else {
			Datetime hold_end = holds[0].Hold_Time__c.addHours(2);
			return (System.now() >= hold_end) ? 0 : Integer.valueOf((hold_end.getTime() - System.now().getTime()) / 60000);
		}
	}

  }

  public Integer next_seven_count() {
  	//need to parse the filtered query and display the next five available items.
  	//search_issues = '';
  	Date sdate = System.today();
  	Date edate = sdate.adddays(7);
  	String query = '';

  	Lead my_lead = [select center__c,pre_screen__c,leadscore__c from lead where id = :l.id];
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.center_information__c = \'' + my_lead.Center__c + '\' and apt_date__c >= :sdate and apt_date__c <= :edate';
  	if(my_lead.leadscore__c=='Green' || my_lead.leadscore__c=='Yellow') {
  	  //no need to worry about the 3 day rules
  	  if(seminar==false)
        next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
      query = 'Select id From Consult_Inventory__c c ' + next_filter;
  	}
  	else {
  		Date tdate = System.today().addDays(5);
  		//this is just a cheap way to get the Green/Yellow blocks available for these 2 pre-screen types easily
  		//if(my_lead.Pre_Screen__c=='Insufficient Information')
  		//if(my_lead.leadscore__c=='Insufficient Information')
  		  //tdate = System.today().addDays(360);
  		//if(my_lead.Pre_Screen__c=='Red' || my_lead.Pre_Screen__c=='Blue (No Hit)' || my_lead.pre_screen__c=='PO Box')
  		if(my_lead.leadscore__c=='Red' || my_lead.leadscore__c=='Blue (No Hit)' || my_lead.leadscore__c=='PO Box' || my_lead.leadscore__c=='Insufficient Information' || my_lead.leadscore__c=='Website Down-No Prescreen')
	  		if(seminar==false)
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\')))';
	  		else
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\',\'Seminar\')))';
	    else
	      if(seminar==false)
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c = \'Any\'))';
	  		else
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Seminar\')))';
  		query = 'Select id From Consult_Inventory__c c ' + next_filter;
  	}
  	//System.debug('Next 7 Query : ' + query);
  	Integer apt_count = 0;
  	try {
  	  List<Consult_Inventory__c> ci_list =  database.query(query);
  	  apt_count = ci_list.size();
  	}
  	catch (Exception e) {

  	}
  	return apt_count;
  }

  public void find_next_available() {
  	//need to parse the filtered query and display the next five available items.
	has_searched = true;
  	search_issues = '';
  	Date sdate = block_form.Apt_Date__c;
  	Lead my_lead = [select center__c,pre_screen__c,leadscore__c from lead where id = :l.id];
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and scheduled_lead__c = null and scheduled_account__c = null and Scheduled_Patient__c = null and consult_room__r.center_information__c = \'' + my_lead.Center__c + '\' and apt_date__c >= :sdate and dow_int__c in (';
    Integer day_cnt = 0;
    if(sMonday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '1';
      day_cnt++;
    }
    if(sTuesday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '2';
      day_cnt++;
    }
    if(sWednesday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '3';
      day_cnt++;
    }
    if(sThursday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '4';
      day_cnt++;
    }
    if(sFriday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '5';
      day_cnt++;
    }
    if(sSaturday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '6';
      day_cnt++;
    }
    if(sSunday) {
    	if(day_cnt>0)
    	  next_filter += ',';
      next_filter += '7';
      day_cnt++;
    }
    if(day_cnt==0) {
      search_issues += '<span class="blank" style="color:red;">You did not select any days.</span>  No appointments will match your criteria<br />';
      next_filter += '9';
    }
	set_start_and_end_filters();
    next_filter += ') and start_hour_int__c >= ' + stime_filter + ' and start_hour_int__c <= ' + etime_filter;
    String user_profile_name = [Select name from Profile where id = :userinfo.getProfileId()].name;
    if(user_profile_name=='Call Center Agent Infocision' || user_profile_name=='Call Center - Supervisor Infocision')
  	  next_filter += ' and c.consult_room__r.infocision_sf_visible__c = true';
    if(stime_filter > etime_filter)
      search_issues += '<span class="blank" style="color:red;">Your starting time is greater than your ending time.</span>  No appointments will match your critera<br />';
      String query = '';
  	//if(my_lead.Pre_Screen__c=='Green' || my_lead.Pre_Screen__c=='Yellow') {
  	if(my_lead.leadscore__c=='Green' || my_lead.leadscore__c=='Yellow') {
  		//no need to worry about the 3 day rules
  		if(seminar==false)
        next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
      query = 'Select c.special_initiative__c,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c ' + next_filter;
  	}
  	else {
  		Date tdate = System.today().addDays(5);
  		//this is just a cheap way to get the Green/Yellow blocks available for these 2 pre-screen types easily
  		//if(my_lead.Pre_Screen__c=='Insufficient Information')
  		//if(my_lead.leadscore__c=='Insufficient Information')
  		  //tdate = System.today().addDays(360);
  		//if(my_lead.Pre_Screen__c=='Red' || my_lead.Pre_Screen__c=='Blue (No Hit)' || my_lead.pre_screen__c=='PO Box')
  		if(my_lead.leadscore__c=='Red' || my_lead.leadscore__c=='Blue (No Hit)' || my_lead.leadscore__c=='PO Box' || my_lead.leadscore__c=='Insufficient Information' || my_lead.leadscore__c=='Website Down-No Prescreen')
	  		if(seminar==false)
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\')))';
	  		else
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\',\'Seminar\')))';
	    else
	      if(seminar==false)
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c = \'Any\'))';
	  		else
	  		  next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Seminar\')))';
  		query = 'Select c.special_initiative__c,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c ' + next_filter;
  	}
  	query += ' order by apt_date__c,start_hour_int__c,c.consult_room__r.room_type__c limit 20';
  	System.debug('Search Query : ' + query);
  	search_consult_results = new next_consult[] {};
  	for(Consult_Inventory__c apt_matches : database.query(query)) {
  	   search_consult_results.add(new next_consult(apt_matches));
  	}
  }

  public void schedule_consult() {
  	Boolean schedule = true;
  	schedule_issues = '';
  	//make sure the patient is not already booked.
  	Integer i = [select count() from Consult_Inventory__c c where c.scheduled_lead__c = :l.id and c.active__c = true and c.apt_date__c >= today and consult_show_status__c=null];
  	if(i>0) {
  	  schedule_issues += '<span class="blank" style="color:red;">Lead is currently scheduled for a consult.</span> You will not be able to schedule this consult until the existing appointment has been removed.<br />';
  	  schedule = false;
  	}
  	//Consult_Inventory__c apt_check = [select c.special_initiative__c,c.consult_room__r.room_type__c,c.id,c.scheduled_account__c,c.start_hour_int__c,c.start_minute_int__c,c.scheduled_lead__c,c.scheduled_by__c,c.scheduled_time__c,c.consult_room__r.center_information__c,c.apt_date__c,c.pre_screen_type__c from Consult_Inventory__c c where c.id = :apexpages.currentpage().getparameters().get('aid') for update];
  	Consult_Inventory__c apt_check = [select c.consult_room__r.center_information__r.confirmation_email_address__c,c.consult_room__r.center_information__r.send_confirmation_email__c,c.consult_room__r.center_information__r.name,c.auto_reminder__c,c.send_reminder__c,c.consult_room__r.room_type__c,c.id,c.scheduled_account__c,c.start_hour_int__c,c.start_minute_int__c,c.scheduled_lead__c,c.scheduled_by__c,c.scheduled_time__c,c.consult_room__r.center_information__c,c.apt_date__c,c.pre_screen_type__c,c.consult_room__r.center_information__r.type__c, c.consult_room__r.center_information__r.Vantage_OfficeID__c,c.start_minute__c,c.start_hour__c from Consult_Inventory__c c where c.id = :apexpages.currentpage().getparameters().get('aid') for update];
  	if(apt_check.Scheduled_lead__c<>null && apt_check.scheduled_account__c<>null) {
  	  schedule = false;
  	  schedule_issues += '<span class="blank" style="color:red;">Sorry - Consult is no longer available.</span><br />';
  	}
  	if(apt_check.Pre_Screen_Type__c=='Seminar' && !seminar) {
  		schedule = false;
  	  schedule_issues += '<span class="blank" style="color:red;">Sorry - Consult was reserved for Seminar.</span><br />';
  	}
  	Lead my_lead = [select id,email,center__c,pre_screen__c,leadscore__c,center__r.name from lead where id = :l.id];
  	if(apt_check.Consult_Room__r.center_information__c!=my_lead.center__c) {
  		schedule = false;
  		schedule_issues += '<span class="blank" style="color:red;">Consult is in a different center than the one the patient has been assigned to.<br/> Please update the patient record before trying to schedule here.<br/></span>';
  	}
  	for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :apt_check.id and active_hold__c = true  and hold_by__c <> :Userinfo.getuserid()]) {
  		//see if the hold_time is less than 5 minutes old
  		Datetime h_end_time = ch.hold_time__c;
  		h_end_time = h_end_time.addHours(2);
  		if(System.now()<h_end_time) {
  			schedule = false;
  		  schedule_issues += '<span class="blank" style="color:red;">Block Held by : ' + ch.hold_by__r.name + '.<br />Hold will be released at : ' + h_end_time.format('M/dd/yyyy hh:mm:ss a') + '</span>';
  		}
  	}
	if (l.Reminder_Call__c == null || l.Reminder_Text__c == null) {
		schedule = false;
		schedule_issues += '<span class="blank" style="color:red;">Before scheduling an appointment, you must confirm whether or not we have permission to call and/or text the patient.</span>';
	}
  	if(schedule) {
  	  Integer next_seven = next_seven_count();
  	  //try and book the lead to this block
  	  apt_check.Scheduled_Lead__c = l.id;
	  	apt_check.Scheduled_by__c = Userinfo.getUserId();
	  	apt_check.scheduled_time__c = System.now();
	  	apt_check.leadscore_at_schedule_time__c = my_lead.leadscore__c;
	  	apt_check.auto_reminder__c = l.receive_auto_reminder__c;
	  	apt_check.send_reminder__c = l.receive_text_reminder__c;
  	  System.debug('Days Between : ' + System.today().daysBetween(apt_check.apt_date__c));
  	  /*10/9/2013 CM - Pulled this based on a request from Steph - Confirmation will now be a manual action
  	  if(System.today().daysBetween(apt_check.apt_date__c)<=3 && apt_check.consult_room__r.room_type__c<>'Unconfirmed')
  		  apt_check.confirmation_status__c = 'Confirmed';*/
	  	try {
	  		update apt_check;
	  		Apt_History__c history = new Apt_History__c(Consult_Inventory__c = apt_check.id, Lead__c = apt_check.scheduled_lead__c, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled',apts_in_next_seven__c = next_seven);
	  	  insert history;
	  		Time schedule_time = time.newInstance(Math.round(apt_check.Start_Hour_Int__c), math.round(apt_check.Start_Minute_Int__c), 0, 0);
  	    System.debug('My Time : ' + schedule_time);
  	    l.DateTime_Consult_Scheduled__c = datetime.newInstance(apt_check.apt_date__c, schedule_time);
  	    l.OBJECTION__c = null;
  	    l.status = 'Consult Scheduled';
  	    if(System.today().daysBetween(apt_check.apt_date__c)<=3)
	  	    l.Confirmed_Appointment__c = true;
	  	  else
				  l.Confirmed_Appointment__c = false;
				l.Could_not_Reach__c = false;
				l.Left_Message_to_Confirm__c = false;
				Date today_date = system.today();
		  	l.Call_Result__c = 'Consultation Scheduled';
  	    System.debug('Scheduled Time : ' + datetime.newInstancegmt(apt_check.apt_date__c, schedule_time));
  	    update l;
  	    try {
  	      if(apt_check.consult_room__r.center_information__r.type__c <> 'Network Center') {
  	    	Integer print_cnt = [select count() from Awaiting_Bulk_Print__c where batch_form__c = 'Welcome Letter' and lead_id__c = :l.id and status__c = 'Pending'];
  	    	if(print_cnt==0) {
			      Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Welcome Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
				    insert bulk_print;
			    	Task t2 = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Welcome Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
			    	insert t2;
  	    	}
  	    	if(my_lead.email!=null)
  	    	  //send_welcome_email(my_lead,apt_check.special_initiative__c);
  	    	  send_welcome_email(my_lead,'',apt_check.apt_date__c);
  	      }
  	      if(apt_check.consult_room__r.center_information__r.send_confirmation_email__c) {
  	      	try {
	  	      	Datetime apt_dtime = datetime.newInstance(apt_check.apt_date__c.year(), apt_check.apt_date__c.month(), apt_check.apt_date__c.day()) ;

	  	      	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();

				String[] toAddresses = new String[] {'msmith@clearchoice.com','cmcdowell@clearchoice.com','sgonzalez@clearchoice.com',apt_check.consult_room__r.center_information__r.confirmation_email_address__c};
				mail.setToAddresses(toAddresses);
				mail.setReplyTo('msmith@clearchoice.com');
				//mail.setSenderDisplayName('Mindy Smith');
				OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
				if ( owea.size() > 0 ) {
				  mail.setOrgWideEmailAddressId(owea.get(0).Id);
				}
				mail.setSubject('ClearChoice has scheduled an appointment in your center');
				String apt_minutes = apt_check.start_minute__c;
				if(apt_check.start_minute__c.length()==1)
				  apt_minutes = '0' + apt_check.start_minute__c;
				mail.setHtmlBody('<html><body>A new appointment has been scheduled on ' + apt_dtime.format('EEEE, MMMM d, yyyy') +
				  ' at ' + apt_check.start_hour__c + ':' + apt_minutes + ' for ' + l.name + '.  You can reach this patient at ' +
				  l.phone +
				  '.</body></html>');
				  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	      	}  catch (Exception e) {
  	      	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		       String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		       mail.setToAddresses(toAddresses);
		       mail.setReplyTo('cmcdowell@acme.com');
		       mail.setSenderDisplayName('Apex error message');
		       mail.setSubject('Scheduling System Error - Welcome Letter');
		       mail.setPlainTextBody(e.getMessage());
		       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	      	}
  	      }
  	   	} catch (Exception e) {
  			for (Integer i_cnt = 0; i_cnt < e.getNumDml(); i_cnt++) {
	           schedule_issues += e.getDmlMessage(i_cnt) + '<br />';
	        }
		       Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		       String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		       mail.setToAddresses(toAddresses);
		       mail.setReplyTo('cmcdowell@acme.com');
		       mail.setSenderDisplayName('Apex error message');
		       mail.setSubject('Scheduling System Error - Welcome Letter');
		       mail.setPlainTextBody(e.getMessage());
		       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	}
	  	/*if(apt_check.consult_room__r.center_information__r.type__c == 'Network Center' && apt_check.consult_room__r.center_information__r.Vantage_OfficeID__c != null) {
  	      	try {
  	      	  Lead vantage_check = [select vantage_response__c from lead where id  = :l.id];
  	      	  if(vantage_check.vantage_response__c==null)
  	            myWS.sendNetCenterInfo(l.id);
  	      	} catch (Exception e) {
  	      	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('cmcdowell@acme.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('Scheduling System Error - Call to Vantage Failed');
		      mail.setPlainTextBody(e.getMessage());
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	      	}
  	      }*/
  	    find_next_available();
  	    schedule_issues = '<span class="blank" style="color:blue;">Success</span> - Consultation has been scheduled';
	  	}
	  	catch (System.DmlException e) {
  			for (i = 0; i < e.getNumDml(); i++) {
          schedule_issues += e.getDmlMessage(i) + '<br />';
        }
  		}
  	}
  	else
  	  //update the next avaliable search
  	  find_next_available();
  	System.debug('Schedule Issues : ' + schedule_issues);
  }

   public void send_welcome_email(Lead my_lead,String initiative,Date apt_date) {
  	try {
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    EmailTemplate et;
	    Date move_date = date.newinstance(2015,12,7);
	    if(my_lead.pre_screen__c=='Green' || my_lead.pre_screen__c=='Yellow' || my_lead.pre_screen__c=='Red') {
	      if(my_lead.center__r.name=='Miami Fort Lauderdale' && apt_date >= move_date && System.today() < move_date)
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_new_FTL'];
	      else
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0'];
	    }
	    else {
	      if(my_lead.center__r.name=='Miami Fort Lauderdale' && apt_date >= move_date && System.today() < move_date)
            et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen_FTL'];
          else
	        et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen'];
	    }
	    //mail.setSenderDisplayName(Userinfo.getUserName());
	    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
		if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
	    mail.setTargetObjectId(my_lead.id); // Specify who the email should be sent to.
	    mail.setTemplateId(et.id);
 		  if(initiative=='Workshop') {
			  List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
		    System.debug('Center__c : ' + l.center__c);
	      for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: my_lead.center__c and name like 'Workshop%' order by createddate desc limit 1]) {
			    // Add to attachment file list
			    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
			    efa.setFileName(a.Name);
			    efa.setBody(a.Body);
			    fileAttachments.add(efa);
	      }
	      if(fileAttachments.size()>0)
	        mail.setFileAttachments(fileAttachments);
		  }
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    schedule_issues += '<span style="color:#5789AE;font-family:georgia;font-weight:bold;font-size:10pt;padding-left:20px;">Success - EMail Sent</span>';
  	} catch (System.Emailexception e) {
  		Apexpages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'Caught email exception: ' + e));
      schedule_issues += '<span style="color:red;font-weight:bold;font-family:georgia;font-size:10pt;padding-left:20px;">Error - Email Not Sent<br />' + e + '</span>';
  	}
  }

  public boolean getisLeadValid() {
  	lead_valid_errors = '';
  	Lead myLead = [select createddate,work__c,mobilephone,inbound_call__c, refused_to_give_email__c,email,pre_screen__c,leadscore__c,fees_quoted__c,phone,cancellation_list_notes__c,hot_list__c,center__r.type__c from Lead where id = :l.id];
  	//check to see if this is an FOA,  if so,  they should only be allowed to work on this if it happens to be a "GOLD" leadscore.  All other exception rules can probably be ignored for now
  	User u = [select center_pec__c,center_administrator__c from user where id = :Userinfo.getUserId()];
  	Integer pec_count = [select count() from Profile where name in ('PEC - NoPScreen - No Dash','PEC - TPLAN','FOA - TPLAN','FOA - No Prescreen - TPlan','PEC - No Prescreen - PPF','PEC - PPF - NoPScreen - TPlan','PEC - PPF - No Prescreen','PEC - PFF - Application Date','PEC - Exam Center','Center Administrator','FOA','FOA - No Prescreen','Patient Education Consultant','PEC - Denver','PEC - Denver - FOA','PEC - No Prescreen','PEC_VisiblePrescreen','PEC - Multiple Centers','PEC - Multiple Centers No Prescreen','PEC - Red Rally','PEC - Red Rally No Prescreen','PEC - Extended Finance','PEC - Extended Finance no prescreen','PEC - Snap No Prescreen','PEC - Snap','PEC_MultipleCenters_VisiblePrescreen','PEC - Application Date') and id = :Userinfo.getProfileId()];
  	if(u.center_administrator__c==true || pec_count>0) {
  	  if(myLead.leadscore__c=='Gold')
  	    return true;
  	  else {
  	  	lead_valid_errors = '<span style="color:red;font-weight:bold;">FOA/PEC scheduling for leads is currently only available on referrals</span><br />';
  	  	return false;
  	  }
  	}
  	Profile p = [select name from profile where id = :Userinfo.getProfileId()];
  	if(p.Name == 'Call Center Agent - No Validation' ||
  	  p.Name == 'Call Center Agent Jumpstart' ||
       p.Name == 'Outbound Call Center Agent Test' ||
       p.Name == 'Outbound Call Center Jumpstart' ||
			p.Name == 'Patient Education Consultant' ||
			p.Name == 'PEC - TPLAN' ||
			p.Name == 'PEC - Exam Center' ||
			p.Name == 'PEC - No Prescreen - PPF' ||
			p.Name == 'PEC - PPF - NoPScreen - TPlan' ||
			p.Name == 'PEC_MultipleCenters_VisiblePrescreen' ||
			p.Name == 'PEC_VisiblePrescreen' ||
			p.Name == 'PEC - Multiple Centers' ||
			p.Name == 'PEC - Red Rally' ||
			p.Name == 'PEC - Red Rally No Prescreen' ||
			p.Name == 'PEC - Snap' ||
			p.Name == 'PEC - Application Date' ||
			p.Name == 'PEC - Extended Finance' ||
			p.Name == 'PEC - Extended Finance no prescreen' ||
			p.Name == 'PEC - Snap No Prescreen' ||
			p.Name == 'PEC - No Prescreen' ||
			p.Name == 'PEC - PPF - No Prescreen' ||
			p.Name == 'PEC - PFF - Application Date' ||
			p.Name == 'PEC - Denver' ||
			p.Name == 'PEC - Denver - FOA' ||
			p.Name == 'FOA - TPLAN' ||
			p.Name == 'PEC - Multiple Centers' ||
			p.Name == 'PEC - Multiple Centers No Prescreen' ||
			p.Name == 'Outbound Call Center Agent' ||
			p.Name == 'FOA' ||
			p.Name == 'PEC - NoPScreen - No Dash' ||
			p.Name == 'FOA - No Prescreen - TPlan' ||
			p.Name == 'FOA - No Prescreen') {
			System.Debug('Valid Lead - Exempt ');
  	  return true;
			}
  	else {
  	  //check to see if the lead is valid
  	  Boolean valid_lead = true;
  	  //email check
  	  /*if(mylead.inbound_call__c=='Dental Inquiry' && mylead.Refused_to_give_email__c==false &&
  	    mylead.email == null) {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Email must be filled in,  or refused to give email must be checked</span><br />';
  	    }*/
  	  //pre-screen check
  	  //if(mylead.pre_screen__c=='Red' && mylead.Fees_Quoted__c==null)
  	  if(mylead.leadscore__c=='Red' && mylead.Fees_Quoted__c==null && mylead.center__r.type__c<>'Network Center') {
  	    valid_lead = false;
  	    lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Red prescreen must have a fee quoted</span><br />';
  	  }
  	  //lead check
  	  if(mylead.phone!=null) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(mylead.phone);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be all numeric</span><br />';
  	  	 }
  	  	 String formatted_phone = mylead.phone;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  Datetime phone_cutoff = Datetime.newinstance(2013,12,2,0,0,0);
  	  if(mylead.mobilephone!=null && mylead.createddate >= phone_cutoff ) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(mylead.mobilephone);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be all numeric</span><br />';
  	  	 }
  	  	 String formatted_phone = mylead.mobilephone;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Mobile Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  if(mylead.work__c!=null && mylead.createddate >= phone_cutoff ) {
  	  	 Pattern myPattern = pattern.compile('\\D*?(\\d\\D*?){10}');
  	  	 Matcher myMatcher = mypattern.matcher(mylead.work__c);
  	  	 if(!myMatcher.matches()) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be all numeric</span><br />';
  	  	 }
  	  	 String formatted_phone = mylead.work__c;
  	  	 formatted_phone = formatted_phone.replace('(','');
  	  	 formatted_phone = formatted_phone.replace(')','');
  	  	 formatted_phone = formatted_phone.replace(' ','');
  	  	 formatted_phone = formatted_phone.replace('-','');
  	  	 if(formatted_phone.length()>10) {
  	  	   valid_lead = false;
  	  	   lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">Work Phone number must be 10 digits or less</span><br />';
  	  	 }
  	  }
  	  if(mylead.phone==null && mylead.inbound_call__c=='Dental Inquiry' && mylead.Work__c==null && mylead.MobilePhone==null) {
  	  	valid_lead = false;
  	  	lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must enter a phone number in the phone,  mobile,  or work phone fields</span><br />';
  	  }
  	  //cancellation notes check
  	  if(mylead.Hot_List__c==true) {
  	  	if(mylead.Cancellation_List_Notes__c==null)   {
  	      valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	  	}
  	    else if(mylead.Cancellation_List_Notes__c.length() < 2) {
  	      valid_lead = false;
  	      lead_valid_errors += '<span style="color:red;font-weight:bold;">Lead Validation Error - <span style="color:black;">You must fill in the Cancellation List Notes with a valid description</span><br />';
  	    }
  	  }
  	  System.Debug('Valid Lead : ' + valid_lead);
  	  return valid_lead;
  	}
  }

	public void set_reminder_checkboxes_when_reminder_radios_change() {
		l.Receive_Auto_Reminder__c = l.Reminder_Call__c == 'Yes' ? true : false;
		l.Receive_Text_Reminder__c = l.Reminder_Text__c == 'Yes' ? true : false;
		update_lead_reminder_preference();
	}

	public void update_lead_reminder_preference() {
		try {
			System.debug('Text Reminder : ' + l.receive_text_reminder__c);
			System.debug('Call Reminder : ' + l.receive_auto_reminder__c);
			update l;
			//search for consult on the calendar that are for today or anytime in the future
			Consult_Inventory__c ci = [select id,send_reminder__c,auto_reminder__c from Consult_Inventory__c where scheduled_lead__c = :l.id and apt_date__c >= today and active__c = true limit 1];
			ci.send_reminder__c = l.receive_text_reminder__c;
			ci.auto_reminder__c = l.receive_auto_reminder__c;
			update ci;
		} catch(Exception e) {System.debug('Error ' + e.getmessage());}
 	}
}