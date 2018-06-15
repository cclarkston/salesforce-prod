public with sharing class ctrl_centerdays {
  public CalendarMonth cmonth;
  public String calendar_view {get;set;}
  public Date selected_date {get;set;}
  public String troubleshoot_msg {get; set;}
  public String selected_center {get; set;}
  public String selected_center_name;
  public Boolean display_foa;
  public Boolean display_admin;
  public String main_view {get; set;}
  public Boolean modal_display {get; set;}
  public String modal_type {get; set;}
  public String modal_out {get; set;}
  public Center_Day current_date {get; set;}
  public Center_Open_Quarter__c current_qtr {get; set;}
  public Center_Open_Quarter__c deny_holder {get;set;}
  List<Close_Request__c> cr_list;

  public ctrl_centerdays() {
  	selected_date = System.today();
  	modal_display = false;
  	modal_out = '';
  	calendar_view = 'calendar';
  	main_view = 'consult_view';
  	troubleshoot_msg = '';
  	deny_holder = new Center_Open_Quarter__c(denied_reason__c = '');
  	if(apexpages.currentpage().getparameters().get('crid')!=null) {
  	  Close_Request__c cr = [select center_open_day__r.center_information__c, center_open_day__r.calendar_date__c from Close_Request__c where id= :apexpages.currentpage().getparameters().get('crid')];
  	  selected_center = cr.center_open_day__r.center_information__c;
  	  selected_date = cr.center_open_day__r.calendar_date__c;
  	  System.debug('Selected Date : ' + selected_date);
  	}
  	else if(apexpages.currentpage().getparameters().get('cdid')!=null) {
  	  Center_Open_Day__c temp_cd = [select calendar_date__c,center_information__c from Center_Open_Day__c where id= :apexpages.currentpage().getparameters().get('cdid')];
  	  selected_center = temp_cd.center_information__c;
  	  selected_date = temp_cd.calendar_date__c;
  	  System.debug('Selected Date : ' + selected_date);
  	}
  	else if(apexpages.currentpage().getparameters().get('cid')==null)  {
      User u = [select clinic_calendar__c,Center_PEC__c from user where id =:userinfo.getUserId()];
      if(u.clinic_calendar__c==null) {
      	if(u.Center_PEC__c==null) {
      	  try {
            selected_center = [select id from Center_Information__c where name = 'Unknown'].id;
      	  }
      	  catch (Exception e) {
      	    selected_center = [select id from Center_Information__c order by name limit 1].id;
      	  }
      	}
      	else
      	  selected_center = [select id from Center_Information__c where id = :u.center_pec__c].id;
      }
      else
        selected_center = [select id from Center_Information__c where name = :u.clinic_calendar__c].id;
  	}
    else {
      //seems redundant,  but I'm throwing this in to handle some issues around short versions of the id field in URLS
      //this should keep the selected list and the calendar on the same page
      Integer count = [select count() from Center_Information__c where id = :apexpages.currentpage().getparameters().get('cid') limit 1];
      if(count>0)
        selected_center = [select id from Center_Information__c where id = :apexpages.currentpage().getparameters().get('cid') limit 1].id;
      else
        selected_center = apexpages.currentpage().getparameters().get('cid');
    }
    cmonth = new CalendarMonth(selected_date,selected_center);
  }

  public class Center_Day {
  	public Center_Open_Day__c cd {get; set;}
  	public String room_breakout {get; set;}
  	public Integer total_blocks {get; set;}
  	public Integer total_scheds {get; set;}

  	public Center_Day(String center_id, Date selected_date) {
  	  try {
  	  	room_breakout = '';
  	  	total_blocks = 0;
  	  	total_scheds = 0;
  	    cd = [Select c.Pending_Close_Requests__c, c.Open_Status__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.Closed_Reason__c, c.Closed_Note__c, c.Center_Information__c, c.Calendar_Date__c, c.id From Center_Open_Day__c c where
  	      center_information__c = :center_id and calendar_date__c = :selected_date];
  	    //work through all of the consult rooms at this center and build the room breakout block as well as the total
  	    for(Consult_Rooms__c cr : [select id,name from Consult_Rooms__c where Center_Information__c = :center_id and active__c = true]) {
  	      Integer num_blocks = [select count() from Consult_Inventory__c where consult_room__c = :cr.id and apt_date__c = :selected_date and active__c = true];
  	      Integer num_scheds = [select count() from Consult_Inventory__c where (scheduled_lead__c != null or scheduled_account__c!=null) and consult_room__c = :cr.id and apt_date__c = :selected_date and active__c = true];
  	      room_breakout += '<tr><td>' + cr.name + '</td><td style="text-align:right;padding-right:5px;">' + num_blocks + '</td><td style="text-align:right;padding-right:5px;">' + num_scheds + '</td></tr>';
  	      total_blocks += num_blocks;
  	      total_scheds += num_scheds;
  	    }
  	    room_breakout += '<tr><td>Totals</td><td style="text-align:right;padding-right:5px;">' + total_blocks + '</td><td style="text-align:right;padding-right:5px;">' + total_scheds + '</td></tr>';
  	    System.debug('Center Day - Selected Date : ' + selected_date);
  	  }
  	  catch (Exception e) {
  	  	System.debug('Error grabbing consult room info ' + e);
  	  }
  	}

  	public String getformatted_status_text() {
  	  String return_html = '<span style="color:purple;">Unknown Status</span>';
  	  if(cd!=null) {
  	    if(cd.open_status__c=='Open')
  	      return_html =  '<span style="color:#5789AE;">Open</span>';
  	    else if(cd.open_status__c=='Closed')
  	      return_html = '<span style="color:red;">Closed</span>';
  	    else if(cd.open_status__c=='Holiday')
  	      return_html = '<span style="color:green;">Holiday</span>';
  	  }
  	  return return_html;
  	}
  }

  public string getformatted_qtr_date() {
  	DateTime dt = Datetime.newinstance(current_qtr.handled_time__c.year(),current_qtr.handled_time__c.month(),current_qtr.handled_time__c.day());
    return dt.format('M/dd/yyyy');
  }

  public void create_new_center_days() {
  	try {
	  	System.debug('Cmonth New Day List Size : ' + cmonth.new_day_list.size());
	  	if(cmonth.new_day_list.size()>0) {
	  	  try {
	  	  	insert cmonth.new_day_list;
	  	  }
	  	  catch (Exception e) {
	  	  	System.debug('Error inserting Center Open Days : ' + e);
	  	  }
	  	}
	  	current_date = new Center_Day(selected_center,selected_date);
	  	Integer selected_year = selected_date.year();
	  	Integer selected_qtr = 1;
	  	if(selected_date.month()==4 || selected_date.month()==5 || selected_date.month()==6)
	  	  selected_qtr = 2;
	  	if(selected_date.month()==7 || selected_date.month()==8 || selected_date.month()==9)
	  	  selected_qtr = 3;
	  	if(selected_date.month()==10 || selected_date.month()==11 || selected_date.month()==12)
	  	  selected_qtr = 4;
	  	Integer qtr_cnt = [select count() from Center_Open_Quarter__c c where c.calendar_quarter__c = :selected_qtr and c.center_year__c = :selected_year and c.center_information__c = :selected_center];
	  	if(qtr_cnt==0) {
	  	  try {
	  	  	System.debug('Creating Qtr');
	  	  	Center_Open_Quarter__c new_qtr = new Center_Open_Quarter__c(center_information__c = selected_center, calendar_quarter__c = selected_qtr, center_year__c = selected_year, open_status__c = 'Build Out');
	  	  	System.debug('Qtr : ' + new_qtr);
	  	  	insert new_qtr;
	  	  }
	  	  catch(Exception e) {
	  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to insert a quarter record for this center'));
	  	    ApexPages.addMessages(e);
	  	  }
	  	}
	    refresh_current_qtr();
  	}
  	catch(Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to initialize process'));
  	  ApexPages.addMessages(e);
  	}
  }

  public String getstatus_color() {
  	String scolor = 'blue';
  	if(current_qtr.open_status__c=='Build Out')
  	  return 'red';
  	else if(current_qtr.open_status__c=='Pending Approval')
  	  return 'grey';
  	return scolor;
  }

  public void refresh_current_qtr() {
  	Integer selected_year = selected_date.year();
  	Integer selected_qtr = 1;
  	if(selected_date.month()==4 || selected_date.month()==5 || selected_date.month()==6)
  	  selected_qtr = 2;
  	if(selected_date.month()==7 || selected_date.month()==8 || selected_date.month()==9)
  	  selected_qtr = 3;
  	if(selected_date.month()==10 || selected_date.month()==11 || selected_date.month()==12)
  	  selected_qtr = 4;
  	try {
  	  current_qtr = [Select c.Open_Status__c, c.Handled_Time__c, c.Handled_By__c, c.handled_by__r.name, c.Denied_Reason__c, c.Closed_Time__c, c.Closed_By__c, c.closed_by__r.name, c.closed_by__r.email, c.Center_Year__c, c.Center_Information__c, c.Calendar_Quarter__c From Center_Open_Quarter__c c where center_information__c = :selected_center and center_year__c = :selected_year and calendar_quarter__c = :selected_qtr];
  	} catch (Exception e) {

  	}
  }

  public Integer getcenter_total_open_days() {
  	//return the number of days the selected center is open for the current month (selected date)
  	Date sdate = date.newinstance(selected_date.year(),selected_date.month(),1);
  	Date edate = sdate.addmonths(1);
  	edate = edate.adddays(-1);
  	Integer cnt = [select count() from Center_Open_Day__c where open_status__c = 'Open' and calendar_date__c >= :sdate  and calendar_date__c <= :edate and center_information__c = :selected_center];
  	return cnt;
  }

  public List<String> getRBD_email() {
  	List<String> remail = new List<String> {'cmcdowell@clearchoice.com', 'mvelasquez@clearchoice.com'};
  	try {
  	  Center_Information__c ci = [select sales_region__c from Center_Information__c where id = :selected_center];
  	  if(ci.sales_region__c!=null) {
  	    Sales_region__c sr = [select RBD__r.Email, RBD__c, rsm__r.email, rsm__c from Sales_Region__c where name = :ci.sales_region__c];
  	    if(sr.rbd__r.email!=null)
  	      remail.add(sr.rbd__r.email);
  	    if(sr.rsm__r.email!=null)
  	      remail.add(sr.rsm__r.email);
  	  	/*if(ci.sales_region__c=='Midwest')
  	  	  remail = 'bburger@clearchoice.com';
  	  	else if(ci.sales_region__c=='Northeast')
  	  	  remail = 'hali@clearchoice.com';
  	  	else if(ci.sales_region__c=='Northwest')
  	  	  remail = 'smccarthy@clearchoice.com';
  	  	else if(ci.sales_region__c=='Southeast')
  	  	  remail = 'hali@clearchoice.com';
  	  	  //remail = 'elogan@clearchoice.com';
  	  	else if(ci.sales_region__c=='Southwest')
  	  	  remail = 'klombardo@clearchoice.com';
  	  	else if(ci.sales_region__c=='Texas')
  	  	  remail = 'jmerandi@clearchoice.com';*/
  	  }
  	}
  	catch(Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to determine RBD'));
  	  ApexPages.addMessages(e);
  	}
  	return remail;
  }

  public Boolean getdisplay_admin() {
  	if(display_admin==null) {
      Integer admin_count = [select count() from Profile where name in ('CC Schedule Admin','Data Audit Team','System Administrator','RBD','New System Administrator','System Administration - Test','CC Administrator','CC - Network Center Supervisor') and id = :Userinfo.getProfileId()];
	  if(admin_count>0 || Test.isRunningTest()) {
	    display_admin = true;
	    display_foa = false;
      }
	  else
	    display_admin = false;
  	}
	return display_admin;
  }

  public Boolean getdisplay_foa() {
  	if(display_foa==null) {
      Integer foa_count = [select count() from User where center_administrator__c = true and id = :Userinfo.getUserId()];
	  if(foa_count>0 || Test.isRunningTest()) {
	    display_admin = false;
	    display_foa = true;
      }
	  else
	    display_foa = false;
  	}
	return display_foa;
  }

  public List<List<String>> getmonth_list() {
  	List<String> month_names = new List<String>();
  	List<List<String>> month_rows = new List<List<String>>();
  	System.debug('Selected Date : ' + selected_date);
  	for(Integer i=1;i<=12;i++) {
  		Datetime month_start = Datetime.newInstance(selected_date.year(), i, 1,0,0,0);
  		System.debug('Month Start : ' + month_start);
  		month_names.add(month_start.format('MMM'));
  		if(math.mod(i,4) == 0) {
  			month_rows.add(month_names);
  			month_names = new List<String>();
  		}
  	}
  	return month_rows;
  }

  public List<List<Integer>> getyear_list() {
  	List<Integer> year_values = new List<Integer>();
  	List<List<Integer>> year_rows = new List<List<Integer>>();
    Date today_date = System.today();
    Integer end_limit = 2024;
    if(today_date.year() > 2024)
      end_limit = today_date.year();
  	for(Integer i=2011;i<=end_limit;i++) {
  		year_values.add(i);
  		if(year_values.size()==4) {
  			year_rows.add(year_values);
  			year_values = new List<Integer>();
  		}
  	}
  	if(year_values.size()>0)
  	  year_rows.add(year_values);
  	return year_rows;
  }

  public Integer getselected_year() {
  	return selected_date.year();
  }

  public String getselected_monthname() {
  	Datetime my_datetime = Datetime.newInstance(selected_date.year(),selected_date.month(),selected_date.day());
  	return my_datetime.format('MMM');
  }

  public CalendarMonth getcmonth() {return cmonth;}

  public void display_months() {
  	calendar_view = 'months';
  }

  public void display_years() {
  	calendar_view = 'years';
  }

  public void add_month() {
  	selected_date = selected_date.addMonths(1);
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	create_new_center_days();
  }

  public void subtract_month() {
  	selected_date = selected_date.addMonths(-1);
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	create_new_center_days();
  }

  public void change_month() {
  	//check to see if the current date value is greater than the end date of the selected month,  if so swap
  	Date last_day = Date.newInstance(selected_date.year(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mnum')), 1);
  	last_day = last_day.addMonths(1).addDays(-1);
  	if(last_day.day()<selected_date.day())
  	  selected_date = last_day;
  	else
  	  selected_date = Date.newInstance(selected_date.year(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mnum')), selected_date.day());
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	create_new_center_days();
  }

  public void change_calendar_day() {
  	selected_date = Date.newInstance(selected_date.year(), selected_date.month(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mday')));
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	create_new_center_days();
  }

  public void change_calendar_year() {
  	Date last_day = Date.newInstance(Integer.valueOf(Apexpages.currentPage().getParameters().get('cyear')), selected_date.month(), 1);
  	last_day = last_day.addMonths(1).addDays(-1);
  	if(last_day.day()<selected_date.day())
  	  selected_date = last_day;
  	else
  	  selected_date = Date.newInstance(Integer.valueOf(Apexpages.currentPage().getParameters().get('cyear')), selected_date.month(), selected_date.day());
  	calendar_view = 'calendar';
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	create_new_center_days();
  }

  public void change_center() {
  	System.debug('Center Change : ' + selected_center);
  	cmonth = new CalendarMonth(selected_date,selected_center);
  	create_new_center_days();
  }

  public List<Selectoption> getfoa_center_list() {
    List<Selectoption> centers = new List<Selectoption>();
    Center_Information__c ci = [select sales_market__c from Center_Information__c where id = :selected_center];
  	for(Center_Information__c my_center : [select id,name,calendar_name__c from Center_Information__c where sales_market__c = :ci.Sales_Market__c order by name]) {
  	  if(my_center.calendar_name__c!=null)
        centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
      else
        centers.add(new Selectoption(my_center.id,my_center.name));
  	}
  	return centers;
  }

  public List<Selectoption> getcenter_list() {
  	List<Selectoption> centers = new List<Selectoption>();
  	for(Center_Information__c my_center : [select id,name,calendar_name__c from Center_Information__c order by name]) {
  	  if(my_center.calendar_name__c!=null)
        centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
      else
        centers.add(new Selectoption(my_center.id,my_center.name));
  	}
  	return centers;
  }

  public String getselected_center_calendar_name() {
  	return [select name,calendar_name__c from Center_information__c where id = :selected_center].calendar_name__c;
  }

  public void close_modal() {
  	modal_display = false;
  	modal_out = '';
  }

  public void display_close_form() {
  	refresh_current_qtr();
  	if(current_qtr.open_status__c=='Build Out') {
  	  //bypass close form and just auto close the day
  	  try {
  	    current_date.cd.open_status__c = 'Closed';
  	    current_date.cd.closed_reason__c = 'Initial Build Out';
  	    current_date.cd.closed_note__c = 'Marked as closed during initial build out';
  	    update current_date.cd;
  	    current_date = new Center_Day(selected_center,selected_date);
  	  }
  	  catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to open day'));
  	    ApexPages.addMessages(e);
  	  }
  	}
  	else {
  	  modal_out = '';
  	  modal_display = true;
  	  modal_type = 'close_form';
  	}
  }

  public void open_center() {
  	try {
  	  current_date.cd.open_status__c = 'Open';
  	  update current_date.cd;
  	  refresh_current_qtr();
  	  if(current_qtr.open_status__c=='Completed') {
  	  	//send an email to Steph/CC team notifying them that a date has been opened up on the calendar
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','callcenter@clearchoice.com','daysworked@clearchoice.com'};
	    mail.setToAddresses(toAddresses);
	    mail.setReplyTo('no-replysf@clearchoice.com');
        mail.setSenderDisplayName('Center Open Days');
        DateTime dt = Datetime.newinstance(selected_date.year(),selected_date.month(),selected_date.day());
        String subject_line = getselected_center_calendar_name() + ' ' + dt.format('M/dd/yyyy') + ' has just been marked as Open';
	    mail.setSubject(subject_line);
	    mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		  '<title>New Date Opened</title>' +
		  '<style type="text/css">' +
		  '</style>' +
		  '</head><body>' +
		    getselected_center_calendar_name() + ' has just been marked as open on ' + dt.format('M/dd/yyyy') + '<br /><br />' +
		 '<p style="padding-left:20px;">' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Current # Blocks :</span>' + current_date.total_blocks +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Current # Consults :</span>' + current_date.total_scheds +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;"># Open days for the month :</span>' + getcenter_total_open_days() +
		  '</span><br /><br />' +
		  '</p>' +
		  '</body></html>');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  }
  	}
  	catch (Exception e) {
  	  System.debug('Unable to save center open day : ' + e);
  	}
  }

  public List<Close_Request__c> getclose_requests() {
  	try {
	  	cr_list = [Select c.Denied_Reason__c,c.Handled_Time__c, c.Handled_Status__c, c.Handled_By__r.name, c.Close_Reason__c, c.Close_Notes__c, c.Center_Open_Day__c,createdby.name,createddate,createdbyid From Close_Request__c c where center_open_day__c = :current_date.cd.id order by createddate desc];
	  	return cr_list;
  	}
  	catch (Exception e) {
  	  return null;
  	}
  }

  public void update_center_day() {
  	boolean display_error = false;
  	String error_message = '';
  	Center_Open_Day__c cd = [Select c.id,c.Open_Status__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.Closed_Reason__c, c.Closed_Note__c, c.Center_Information__c, c.Calendar_Date__c From Center_Open_Day__c c where
  	  center_information__c = :selected_center and calendar_date__c = :selected_date];
  	if(current_date.cd.closed_reason__c==null) {
  	  display_error = true;
  	  error_message += '<span style="color:red;font-weight:bold;">You must select a closed reason before saving</span><br />';
    }
    if(current_date.cd.closed_note__c==null) {
  	  display_error = true;
  	  error_message += '<span style="color:red;font-weight:bold;">You must enter a short note when trying to mark a day as closed</span><br />';
    }
    else if(current_date.cd.closed_note__c.length()<3) {
      display_error = true;
  	  error_message += '<span style="color:red;font-weight:bold;">You must enter a short note when trying to mark a day as closed</span><br />';
    }
    if(display_error) {
      modal_out = error_message;
      return;
    }
    else {
      try {
      	//flagging this as open.  When the request for closing is approved,  then the day will be marked correctly
      	current_date.cd.open_status__c='Open';
      	//generate a new close request to track this event
      	Close_Request__c cr = new Close_Request__c(Close_Reason__c = current_date.cd.closed_reason__c, Close_Notes__c = current_date.cd.closed_note__c, Center_Open_Day__c = cd.id);
      	update current_date.cd;
      	insert cr;
      	//now fire off an email to the manager (for now hardcoded to me)
      	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      	//String rbd_email = getRBD_email();
		//String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',rbd_email};
		String[] toAddresses = getRBD_email();
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('no-replysf@clearchoice.com');
        mail.setSenderDisplayName('Center Open Days');
        DateTime dt = Datetime.newinstance(selected_date.year(),selected_date.month(),selected_date.day());
        String subject_line = getselected_center_calendar_name() + ' ' + dt.format('M/dd/yyyy') + ' Close Request';
		mail.setSubject(subject_line);
		mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		  '<title>New Close Request</title>' +
		  '<style type="text/css">' +
		  '</style>' +
		  '</head><body>' +
		  getselected_center_calendar_name() + ' has submitted a request to close on ' + dt.format('M/dd/yyyy') + '<br /><br />' +
		  '<p style="padding-left:20px;">' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Current # Blocks :</span>' + current_date.total_blocks +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Current # Consults :</span>' + current_date.total_scheds +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;"># Open days for the month :</span>' + getcenter_total_open_days() +
		  '</span><br /><br />' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Reason for Closing :</span>' + current_date.cd.closed_reason__c +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Notes :</span>' + current_date.cd.closed_note__c +
		  '</span><br /><br />' +
		  '<span style="font-style:italic;font-size:12pt;">To approve or deny the request,  please click <a href="' + gethyper_prefix() + '/apex/center_days?crid=' + cr.id  + '" target="__blank" style=color:blue;">here</a>' +
		  '</p>' +
		  '</body></html>');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

      	/*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      	Center_Information__c ci = [select id,name from Center_Information__c where id = :selected_center];
      	req1.setComments('Submitting a request to close center - ' + ci.name + ' for ' + selected_date);
      	req1.setObjectId(current_date.cd.id);
      	Approval.processResult result = Approval.process(req1);
      	System.debug('Approval Info : ' + result + ' Success : ' + result.issuccess());
      	modal_display = false;*/
      	modal_display = false;
      }
      catch (Exception e) {
      	modal_out = '<span style="color:red;font-weight:bold;">There was an error saving the record ' + e + '</span><br />';
      }
    }
  }

  public void approve_close_request() {
  	try {
      //grab the close request we are tryign to work on
  	  Close_Request__c cr = [Select c.Handled_Time__c, c.Handled_Status__c, c.Handled_By__c,center_open_day__c From Close_Request__c c where id = :apexpages.currentpage().getparameters().get('crid')];
  	  cr.handled_time__c = system.now();
  	  cr.handled_by__c = userinfo.getUserId();
  	  cr.handled_status__c = 'Approved';
  	  update cr;
  	  //mark the day as closed
  	  current_date.cd.open_status__c = 'Closed';
  	  update current_date.cd;
  	  //email the call center with info
  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','callcenter@clearchoice.com','daysworked@clearchoice.com'};
	  mail.setToAddresses(toAddresses);
	  mail.setReplyTo('no-replysf@clearchoice.com');
      mail.setSenderDisplayName('Center Open Days');
      DateTime dt = Datetime.newinstance(selected_date.year(),selected_date.month(),selected_date.day());
      String subject_line = getselected_center_calendar_name() + ' ' + dt.format('M/dd/yyyy') + ' Close Request Approved';
	  mail.setSubject(subject_line);
	  mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		'<title>New Close Request</title>' +
		'<style type="text/css">' +
		'</style>' +
		'</head><body>' +
		getselected_center_calendar_name() + ' has been approved to close on ' + dt.format('M/dd/yyyy') + '<br /><br />' +
		 '<p style="padding-left:20px;">' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Current # Blocks :</span>' + current_date.total_blocks +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Current # Consults :</span>' + current_date.total_scheds +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;"># Open days for the month :</span>' + getcenter_total_open_days() +
		  '</span><br /><br />' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Reason for Closing :</span>' + current_date.cd.closed_reason__c +
		  '</span>' +
		  '<span style="display:block;padding-bottom:7px;">' +
		    '<span style="display:inline-block; width:225px;font-weight:bold;">Notes :</span>' + current_date.cd.closed_note__c +
		  '</span>' +
		  '</p>' +
		  '</body></html>');
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  cmonth = new CalendarMonth(selected_date,selected_center);
	  current_date = new Center_Day(selected_center,selected_date);
	  cr_list = [Select c.Denied_Reason__c,c.Handled_Time__c, c.Handled_Status__c, c.Handled_By__r.name, c.Close_Reason__c, c.Close_Notes__c, c.Center_Open_Day__c,createdby.name,createddate From Close_Request__c c where center_open_day__c = :current_date.cd.id order by createddate desc];
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to process approval'));
  	  ApexPages.addMessages(e);
  	}

  }

  public void deny_close_request() {
  	try {
  	  //find the close request that was adjusted
  	  for(Close_Request__c cr : cr_list) {
  	  	if(cr.id==apexpages.currentpage().getparameters().get('crid')) {
  	  	  if(cr.denied_reason__c==null)
  	  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter something in the reason field before processing a denial'));
  	  	  else if(cr.denied_reason__c.length()<2)
  	  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter more text in the reason field before processing a denial'));
  	  	  //we have a valid denial - process it
  	  	  else {
  	  	  	cr.handled_time__c = system.now();
  	        cr.handled_by__c = userinfo.getUserId();
  	        cr.handled_status__c = 'Denied';
  	        update cr;
  	        //email the requester and let them know that the request was denied
  	        User denied_user = [Select u.Email From User u where id = :cr.createdbyid];
  	        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',denied_user.email};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo('no-replysf@clearchoice.com');
		    mail.setSenderDisplayName('Center Open Days');
		    DateTime dt = Datetime.newinstance(selected_date.year(),selected_date.month(),selected_date.day());
		    String subject_line = getselected_center_calendar_name() + ' ' + dt.format('M/dd/yyyy') + ' Close Request Denied';
			mail.setSubject(subject_line);
			mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
			  '<title>New Close Request</title>' +
			  '<style type="text/css">' +
			  '</style>' +
			  '</head><body>' +
			  'Your request to close on ' + dt.format('M/dd/yyyy') + ' has been denied<br /><br />' +
				 '<p style="padding-left:20px;">' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:225px;font-weight:bold;">Close Reason :</span>' + cr.Close_Reason__c +
				  '</span>' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:225px;font-weight:bold;">Close Notes :</span>' + cr.Close_Notes__c +
				  '</span>' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:225px;font-weight:bold;">Denied By :</span>' + userinfo.getname() +
				  '</span><br /><br />' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:225px;font-weight:bold;">Denied Time :</span>' + System.now().format('M/dd/yyyy hh:mm:ss') +
				  '</span>' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:225px;font-weight:bold;">Denied Notes :</span>' + cr.denied_reason__c +
				  '</span>' +
				  '</p>' +
				  '</body></html>');
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  	  }
  	  	}
  	  }
  	  cr_list = [Select c.Denied_Reason__c,c.Handled_Time__c, c.Handled_Status__c, c.Handled_By__r.name, c.Close_Reason__c, c.Close_Notes__c, c.Center_Open_Day__c,createdby.name,createddate From Close_Request__c c where center_open_day__c = :current_date.cd.id order by createddate desc];
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to process denial'));
  	  ApexPages.addMessages(e);
  	}
  }

  public void reset_build_out() {
  	try {
  	  refresh_current_qtr();
  	  if(current_qtr.open_status__c=='Completed') {
  	  	current_qtr.open_status__c = 'Build Out';
  	  	current_qtr.handled_by__c = userinfo.getuserid();
  	  	current_qtr.handled_time__c = system.now();
  	  	current_qtr.denied_reason__c = 'Status was reset by admin';
  	  	update current_qtr;
  	  	refresh_current_qtr();
  	  	//fire off an email to the FOA who submitted the build out and the cc
  	  	//currently email just goes to me
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
  	  	//String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		String[] toAddresses = new String[] {'callcenter@clearchoice.com','sgonzales@clearchoice.com','daysworked@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('no-replysf@clearchoice.com');
        mail.setSenderDisplayName('Center Open Days');
        Integer selected_qtr = 1;
	  	if(selected_date.month()==4 || selected_date.month()==5 || selected_date.month()==6)
	  	  selected_qtr = 2;
	  	if(selected_date.month()==7 || selected_date.month()==8 || selected_date.month()==9)
	  	  selected_qtr = 3;
	  	if(selected_date.month()==10 || selected_date.month()==11 || selected_date.month()==12)
	  	  selected_qtr = 4;
        String subject_line = getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' Build Out Reset';
		mail.setSubject(subject_line);
		mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		  '<title>Build Out Reset</title>' +
		  '<style type="text/css">' +
		  '</style>' +
		  '</head><body>' +
		  getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' build out has been reset by an admin.  Center will resubmit when finished<br /><br />' +
		  '</body></html>');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  }
  	}
  	catch(Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to process approval'));
  	  ApexPages.addMessages(e);
  	}
  }

  public void approve_build_out() {
  	try {
  	  refresh_current_qtr();
  	  if(current_qtr.open_status__c=='Pending Approval') {
  	  	current_qtr.open_status__c = 'Completed';
  	  	current_qtr.handled_by__c = userinfo.getuserid();
  	  	current_qtr.handled_time__c = system.now();
  	  	current_qtr.denied_reason__c = '';
  	  	update current_qtr;
  	  	refresh_current_qtr();
  	  	//fire off an email to the FOA who submitted the build out and the cc
  	  	//currently email just goes to me
  	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',current_qtr.closed_by__r.email,'callcenter@clearchoice.com','daysworked@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('no-replysf@clearchoice.com');
        mail.setSenderDisplayName('Center Open Days');
        Integer selected_qtr = 1;
	  	if(selected_date.month()==4 || selected_date.month()==5 || selected_date.month()==6)
	  	  selected_qtr = 2;
	  	if(selected_date.month()==7 || selected_date.month()==8 || selected_date.month()==9)
	  	  selected_qtr = 3;
	  	if(selected_date.month()==10 || selected_date.month()==11 || selected_date.month()==12)
	  	  selected_qtr = 4;
        String subject_line = getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' Build Out Approved';
		mail.setSubject(subject_line);
		mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		  '<title>Build Out Approved</title>' +
		  '<style type="text/css">' +
		  '</style>' +
		  '</head><body>' +
		  getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' build out has been approved<br /><br />' +
		  '</body></html>');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  }
  	}
  	catch(Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to process approval'));
  	  ApexPages.addMessages(e);
  	}
  }

  public void deny_build_out() {
  	try {
  	  if(current_qtr.open_status__c=='Pending Approval') {
  	  	if(deny_holder.denied_reason__c==null)
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter something for the denial reason'));
  	    else if(deny_holder.denied_reason__c.length()<2)
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter more text in the reason field before processing a denial'));
  	  	else {
  	  	  current_qtr.open_status__c = 'Build Out';
  	  	  current_qtr.handled_by__c = userinfo.getuserid();
  	  	  current_qtr.handled_time__c = system.now();
  	  	  current_qtr.denied_reason__c = deny_holder.denied_reason__c;
  	  	  deny_holder.denied_reason__c = '';
  	  	  update current_qtr;
  	  	  //send an email to the user who submitted the request
  	  	  //currently hardcoded to me
  	  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',current_qtr.closed_by__r.email};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('no-replysf@clearchoice.com');
        mail.setSenderDisplayName('Center Open Days');
        Integer selected_qtr = 1;
	  	if(selected_date.month()==4 || selected_date.month()==5 || selected_date.month()==6)
	  	  selected_qtr = 2;
	  	if(selected_date.month()==7 || selected_date.month()==8 || selected_date.month()==9)
	  	  selected_qtr = 3;
	  	if(selected_date.month()==10 || selected_date.month()==11 || selected_date.month()==12)
	  	  selected_qtr = 4;
        String subject_line = getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' Build Out Denied';
		mail.setSubject(subject_line);
		mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		  '<title>Build Out Denied</title>' +
		  '<style type="text/css">' +
		  '</style>' +
		  '</head><body>' +
		  getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' build out has been denied<br /><br />' +
		  '<p style="padding-left:20px;">' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:150px;font-weight:bold;">Denied By :</span>' + userinfo.getname() +
				  '</span><br /><br />' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:150px;font-weight:bold;">Denied Time :</span>' + System.now().format('M/dd/yyyy hh:mm:ss') +
				  '</span>' +
				  '<span style="display:block;padding-bottom:7px;">' +
				    '<span style="display:inline-block; width:150px;font-weight:bold;">Denied Notes :</span>' + current_qtr.denied_reason__c +
				  '</span>' +
				  '</p>' +
		  '</p>' +
		  '</body></html>');
  	  	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  	}
  	  }
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to process denial'));
  	  ApexPages.addMessages(e);
  	}
  }

  public void submit_build_out() {
  	try {
  	  refresh_current_qtr();
  	  if(current_qtr.open_status__c=='Build Out') {
  	  	current_qtr.open_status__c='Pending Approval';
  	  	current_qtr.closed_by__c = userinfo.getuserid();
  	  	current_qtr.closed_time__c = system.now();
  	  	update current_qtr;
  	    //now fire off an email to the manager (for now hardcoded to me)
      	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      	//String rbd_email = getRBD_email();
		//String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',rbd_email};
		String[] toAddresses = getRBD_email();
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('no-replysf@clearchoice.com');
        mail.setSenderDisplayName('Center Open Days');
        Integer selected_qtr = 1;
	  	if(selected_date.month()==4 || selected_date.month()==5 || selected_date.month()==6)
	  	  selected_qtr = 2;
	  	if(selected_date.month()==7 || selected_date.month()==8 || selected_date.month()==9)
	  	  selected_qtr = 3;
	  	if(selected_date.month()==10 || selected_date.month()==11 || selected_date.month()==12)
	  	  selected_qtr = 4;
        String subject_line = getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' Build Out Submitted for Approval';
		mail.setSubject(subject_line);
		mail.setHtmlBody('<html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		  '<title>Build Out Submitted for Approval</title>' +
		  '<style type="text/css">' +
		  '</style>' +
		  '</head><body>' +
		  getselected_center_calendar_name() + ' QTR ' + selected_qtr + ', ' + selected_date.year() + ' build out has been submitted for approval<br /><br />' +
		  '<span style="font-style:italic;font-size:12pt;">To review the quarter and approve or deny the build out,  please click <a href="' + gethyper_prefix() + '/apex/center_days?cdid=' + current_date.cd.id  + '" target="__blank" style=color:blue;">here</a>' +
		  '</p>' +
		  '</body></html>');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  }
  	}
  	catch(Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to submit for approval'));
  	  ApexPages.addMessages(e);
  	  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an error submitting a qtr build out for approval');
 	  message.setPlainTextBody('Line: '+ e.getLineNumber() + ' - '+e.getMessage()+'\r'+e.getStackTraceString());
      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
  	}
  }

  public String gethyper_prefix() {
  	String hyper_prefix = '';
    if(Apexpages.currentPage()<>null) {
      hyper_prefix = (ApexPages.currentPage().getHeaders()==null ? 'https://cs12.salesforce.com' : 'https://'+ApexPages.currentPage().getHeaders().get('Host'));
    }
    else
      hyper_prefix = 'https://cs12.salesforce.com';
    return hyper_prefix;
  }
}