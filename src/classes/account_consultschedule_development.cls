public with sharing class account_consultschedule_development {
  private final Account l;
  ApexPages.Standardcontroller con;
  public Boolean has_searched {get; set;}
  public next_consult[] search_consult_results;
  //public Schedule_Templates__c schedule_form {get; set;}
  public Consult_Inventory__c block_form {get; set;}
  public Boolean sMonday {get;set;}
  public Boolean sTuesday {get;set;}
  public Boolean sWednesday {get;set;}
  public Boolean sThursday {get;set;}
  public Boolean sFriday {get;set;}
  public Boolean sSaturday {get;set;}
  public Boolean sSunday {get;set;}
  public Integer stime_filter {get;set;}
  public Integer etime_filter {get;set;}
  public String search_issues {get;set;}
  public String schedule_issues {get;set;}
  public Boolean seminar {get; set;}

  public account_consultschedule_development(ApexPages.StandardController stdController) {
    this.l = (Account)stdController.getRecord();
    con = stdController;
	has_searched = false;
    sMonday = true;
    sTuesday = true;
    sWednesday = true;
    sThursday = true;
    sFriday = true;
    sSaturday = true;
    sSunday = true;
    //schedule_form = new Schedule_Templates__c(Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true, Saturday__c = true, Sunday__c = true);
    block_form = new Consult_Inventory__c(apt_date__c = System.today());
    stime_filter = 7;
    etime_filter = 23;
    Integer admin_count = [select count() from Profile where name in ('Center Administrator','Marketing Administrator Test','Marketing Administrator w/o Delete') and id = :Userinfo.getProfileId()];
    if(admin_count>0)
      seminar = true;
    else
      seminar = false;
  }

  public next_consult[] getsearch_consult_results() {
    if(search_consult_results==null)
      search_consult_results = new next_consult[] {};
    return search_consult_results;
  }

  public integer getaval_size() {
    return search_consult_results.size();
  }

  // public string getlead_phone() {
  //    String phone_return = '';
  //    Integer cnt = 0;
  //    for(AggregateResult ar : database.query('select phone from lead where convertedaccountid = \'' + l.id + '\' and phone <> null group by phone limit 10')) {
  //        if(cnt>0)
  //          phone_return += ' , ';
  //        phone_return += (string)ar.get('phone');
  //        cnt++;
  //    }
  //    return phone_return;
  // }

  public Pagereference record_openby() {
    //testing read recording.
    /*System.debug('Test');
    System.debug('Account : ' + l);
    //System.debug('Account : ' + (Account)stdController.getRecord());
    Account my_account = [select id,opened_by__c from Account where id = :l.id];
    my_account.Opened_By__c = Userinfo.getName() + ' ' + System.now();
    update my_account;*/
    return null;
  }

  public String getscheduled_consults_string() {
	  // We'd like there to only be one consult, so the join shouldn't ever actually join multiple fields.
	  // However, at time of writing, there's a bug allowing multiple consults to be scheduled for a single patient which is why this solution is necessary.
	  String[] consult_strings = new String[]{};
	  Consult_Inventory__c[] consults = [SELECT Apt_Date__c, Start_Hour__c, Start_Minute__c FROM Consult_Inventory__c WHERE Scheduled_Account__c = :l.id AND Active__c = TRUE AND Apt_Date__c >= TODAY ORDER BY Scheduled_Time__c DESC];
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

  // public String getscheduled_date() {
  //   List<Consult_Inventory__c> current_apt = [select apt_date__c,start_hour__c,start_hour_int__c,start_minute__c from Consult_Inventory__c where scheduled_account__c = :l.id and active__c = true order by apt_date__c desc limit 1];
  //   String return_val;
  //   if(current_apt.size()>0) {
  //       String suffix;
  //       Integer shour = math.round(current_apt[0].start_hour_int__c);
  //       if(shour>12) {
  //           shour = shour - 12;
  //           suffix = 'PM';
  //       }
  //       else if(shour==12)
  //         suffix = 'PM';
  //       else
  //           suffix = 'AM';
  // String zero_padded_minute = (!String.isBlank(current_apt[0].start_minute__c) && Integer.valueOf(current_apt[0].start_minute__c) < 10) ? ('0' + current_apt[0].start_minute__c) : current_apt[0].start_minute__c;
  //     return_val =  string.valueof(current_apt[0].apt_date__c.format()) + ' ' + shour + ':' + zero_padded_minute + ' ' + suffix;
  //   }
  //   // else
  //   //   return_val = 'none';
  //   return return_val;
  // }

  public String getcurrent_aptid() {
    List<Consult_Inventory__c> current_apt = [select id from Consult_Inventory__c where scheduled_lead__c = :l.id and active__c = true order by apt_date__c desc limit 1];
    if(current_apt.size()>0)
      return string.valueof(current_apt[0].id);
    else
      return null;
  }

  public String getopen_schedule_test() {
    Pagereference pr = Page.sandbox_calendar_development;
    pr.getParameters().put('aid',getcurrent_aptid());
    pr.getParameters().put('acntid',l.id);
    pr.setredirect(true);
    return pr.getUrl();
  }

  // public List<Selectoption> getbetween_times() {
  //    List<Selectoption> btimes = new List<Selectoption>();
  //    for(Integer i=1;i<=23;i++) {
  //        String option_label = '';
  //        if(i>12)
  //          option_label = string.valueOf((i-12)) + ' PM';
  //        else if(i==12)
  //          option_label = string.valueOf(i) + ' PM';
  //        else
  //          option_label = string.valueOf(i) + ' AM';
  //        btimes.add(new selectOption(string.valueof(i),option_label));
  //    }
  //    return btimes;
  // }

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
      if          (time_group == '0') {
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
        return room_name;
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

 //     public String getend_time() {
 //       Integer sh = integer.valueof(apt_block.end_hour__c);
 //         String suffix = '';
 //         if(sh>12) {
 //           sh = sh - 12;
 //           suffix = 'PM';
 //         }
 //         else if(sh==12)
 //           suffix = 'PM';
 //         else
 //           suffix = 'AM';
 //         if(apt_block.end_minute__c=='0')
 //           return sh + ':00 ' + suffix;
 //         else
 //           return sh + ':' + apt_block.end_minute__c + ' ' + suffix;
 //     }

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
    //need to parse the filtered query and display the next five avaliable items.
    //search_issues = '';
    Date sdate = System.today();
    Date edate = sdate.adddays(7);
    String query = '';

    Account my_account = [select center__c,pre_screen__c,LeadScore__c from Account where id = :l.id];
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c <> \'Unconfirmed\' and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.center_information__c = \'' + my_account.Center__c + '\' and apt_date__c >= :sdate and apt_date__c <= :edate';
    if(my_account.leadscore__c=='Green' || my_account.leadscore__c=='Yellow') {
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
        if(my_account.leadscore__c=='Red' || my_account.leadscore__c=='Blue (No Hit)' || my_account.leadscore__c=='PO Box' || my_account.leadscore__c=='Insufficient Information' || my_account.leadscore__c=='Website Down-No Prescreen')
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

  public List<Consult_Inventory__c> getconsult_history_list() {
    return [Select c.start_hour__c, c.start_minute__c, c.Scheduled_Lead__c, c.Scheduled_Account__c, c.Consult_Show_Status__c, c.Consult_PEC__r.name, c.Apt_Date__c From Consult_Inventory__c c where scheduled_lead__r.convertedaccountid = :l.id or scheduled_account__c = :l.id order by apt_date__c desc];
  }

  public void find_next_available() {
    //need to parse the filtered query and display the next five avaliable items.
	has_searched = true;
    search_issues = '';
    Date sdate = block_form.Apt_Date__c;
    Account my_account = [select center__c,pre_screen__c,LeadScore__c from Account where id = :l.id];
    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and scheduled_lead__c = null and scheduled_account__c = null and Scheduled_Patient__c = null and consult_room__r.center_information__c = \'' + my_account.Center__c + '\' and apt_date__c >= :sdate and dow_int__c in (';
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
    //check to see if they can look at the practice room
    if(user_profile_name!='Force.com - Patient Intake' && user_profile_name!='Force.com Clinic Calendar' && user_profile_name=='Practice Doctor')
      next_filter += ' and c.consult_room__r.room_type__c != \'Practice\'';
    if(stime_filter > etime_filter)
      search_issues += '<span class="blank" style="color:red;">Your starting time is greater than your ending time.</span>  No appointments will match your critera<br />';
      String query = '';
    if(my_account.leadscore__c=='Green' || my_account.leadscore__c=='Yellow') {
        //no need to worry about the 3 day rules
        if(seminar==false)
        next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
      query = 'Select c.special_initiative__c,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c ' + next_filter;
    }
    else {
        Date tdate = System.today().addDays(5);
        //if(my_account.Pre_Screen__c=='Insufficient Information')
          //tdate = System.today().addDays(360);
        if(my_account.leadscore__c=='Red' || my_account.leadscore__c=='Blue (No Hit)' || my_account.leadscore__c=='PO Box' || my_account.leadscore__c=='Insufficient Information' || my_account.leadscore__c=='Website Down-No Prescreen')
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
    Integer i = [select count() from Consult_Inventory__c c where c.scheduled_account__c = :l.id and c.active__c = true and c.apt_date__c >= today and consult_show_status__c=null];
    if(i>0) {
      schedule_issues += '<span class="blank" style="color:red;">Patient is currently scheduled for a consult.</span>You will not be able to schedule this consult until the existing appointment has been removed<br />';
      schedule = false;
    }
    Consult_Inventory__c apt_check = [select c.pre_screen_type__c,c.scheduled_account__c,c.start_hour_int__c,c.start_minute_int__c,c.scheduled_lead__c,c.scheduled_by__c,c.scheduled_time__c,c.consult_room__r.center_information__c,c.apt_date__c from Consult_Inventory__c c where c.id = :apexpages.currentpage().getparameters().get('aid') for update];
    if(apt_check.Scheduled_lead__c<>null && apt_check.scheduled_account__c<>null) {
      schedule = false;
      schedule_issues += '<span class="blank" style="color:red;">Sorry - Consult is no longer avaliable</span><br />';
    }
    if(apt_check.Pre_Screen_Type__c=='Seminar' && !seminar) {
        schedule = false;
      schedule_issues += '<span class="blank" style="color:red;">Sorry - Consult was reserved for Seminar</span><br />';
    }
    Account my_account = [select center__c,pre_screen__c from Account where id = :l.id];
    if(apt_check.Consult_Room__r.center_information__c!=my_account.center__c) {
        schedule = false;
        schedule_issues += '<span class="blank" style="color:red;">Consult is in a different center than the one the patient has been assigned to<br />Please update the patient record before trying to schedule here<br /></span>';
    }
    for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :apt_check.id and active_hold__c = true and hold_by__c <> :Userinfo.getuserid() ]) {
        //see if the hold_time is less than 5 minutes old
        Datetime h_end_time = ch.hold_time__c;
        h_end_time = h_end_time.addHours(2);
        if(System.now()<h_end_time) {
            schedule = false;
          schedule_issues += '<span class="blank" style="color:red;">Block Held by : ' + ch.hold_by__r.name + '.<br />Hold will be released at : ' + h_end_time.format('M/dd/yyyy hh:mm:ss a') + '</span>';
        }
    }
    if(schedule) {
        Integer next_seven = next_seven_count();
      //try and book the lead to this block
      apt_check.Scheduled_account__c = l.id;
        apt_check.Scheduled_by__c = Userinfo.getUserId();
        apt_check.scheduled_time__c = System.now();
        apt_check.Leadscore_At_Schedule_Time__c = l.Pre_Screen__c;
		apt_check.auto_reminder__c = l.receive_auto_reminder__c;
		apt_check.send_reminder__c = l.receive_text_reminder__c;
        try {
            update apt_check;
            Apt_History__c history = new Apt_History__c(Consult_Inventory__c = apt_check.id, Account__c = apt_check.scheduled_account__c, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled',apts_in_next_seven__c = next_seven);
          insert history;
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

  public void set_reminder_checkboxes_when_reminder_radios_change() {
	  l.Receive_Auto_Reminder__c = l.Reminder_Call__c == 'Yes' ? true : false;
	  l.Receive_Text_Reminder__c = l.Reminder_Text__c == 'Yes' ? true : false;
	  update_account_reminder_preference();
  }

  public void update_account_reminder_preference() {
	  try {
		  System.debug('Text Reminder : ' + l.receive_text_reminder__c);
		  System.debug('Call Reminder : ' + l.receive_auto_reminder__c);
		  update l;
		  //search for consult on the calendar that are for today or anytime in the future
		  Consult_Inventory__c ci = [select id,send_reminder__c,auto_reminder__c from Consult_Inventory__c where Scheduled_Account__c = :l.id and apt_date__c >= today and active__c = true limit 1];
		  ci.send_reminder__c = l.receive_text_reminder__c;
		  ci.auto_reminder__c = l.receive_auto_reminder__c;
		  update ci;
	  } catch(Exception e) {System.debug('Error ' + e.getmessage());}
  }

}