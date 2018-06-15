public class CalendarMonth {
  public List<CalendarWeek> weeks;
  public Date first_day;
  public Date init_date;
  public List<Center_Open_Day__c> new_day_list;
  map<date,integer> aval_apt_info;
  map<date,integer> total_apt_info;
  map<date,Center_Open_Day__c> open_day_status;

  public CalendarMonth(Date init_date, String center_id) {
  	open_day_status = new map<date,Center_Open_Day__c>();
  	new_day_list = new List<Center_Open_Day__c>();
  	first_day = init_date.toStartOfMonth();
  	Date first_day_of_week = first_day.toStartOfWeek();
  	Date first_day_safety = first_day.addDays(-7);
  	Date last_day = first_day.addMonths(1).addDays(-1);
  	Date last_day_safety = last_day.addDays(7);
  	aval_apt_info = new map<date,integer>{};
  	for(Center_Open_Day__c cd : [select calendar_date__c,open_status__c,Pending_Close_Requests__c from Center_Open_Day__c where calendar_date__c >= :first_day_safety and calendar_date__c <= : last_day_safety and center_information__c = :center_id]) {
  	  // System.debug('Adding Calendar Date : ' + cd.calendar_date__c + ' CD ' + cd);
      open_day_status.put(cd.calendar_date__c,cd);
  	}
  	// System.debug('Open Day Status Size ' + open_day_status.size());
    for(AggregateResult ar : [select apt_date__c,count(id) num_aval_consults from Consult_Inventory__c c where c.active__c = true and c.apt_date__c >= :first_day and c.apt_date__c <= :last_day and c.consult_room__r.center_information__c = :center_id and c.consult_room__r.room_type__c<> 'Unconfirmed' and c.scheduled_lead__c = null and c.scheduled_account__c = null group by apt_date__c]) {
       aval_apt_info.put((Date)ar.get('apt_date__c'),Integer.valueOf(ar.get('num_aval_consults')));
    }
    total_apt_info = new map<date,integer>{};
    //might need to add this - and c.consult_room__r.room_type__c <> 'OverFlow'
    for(AggregateResult ar : [select apt_date__c,count(id) num_aval_consults from Consult_Inventory__c c where c.active__c = true and c.apt_date__c >= :first_day and c.apt_date__c <= :last_day and c.consult_room__r.center_information__c = :center_id  and c.consult_room__r.room_type__c <> 'Unconfirmed' group by apt_date__c]) {
      total_apt_info.put((Date)ar.get('apt_date__c'),Integer.valueOf(ar.get('num_aval_consults')));
    }
  	// System.debug('Last Day of the month : ' + last_day);
  	Integer work_thru = 1;
  	Integer safety_valve = 0;
  	weeks = new List<CalendarWeek>();
  	//work through weeks until we get to the end of the month
  	while(work_thru==1) {
  		CalendarWeek my_week = new CalendarWeek(first_day_of_week, first_day.month(), init_date.day(), aval_apt_info, total_apt_info, open_day_status, center_id);
  		if(my_week.new_week_days.size()>0) {
  		  for(Center_Open_Day__c cd : my_week.new_week_days) {
  		  	new_day_list.add(cd);
  		  }
  		}
  		weeks.add(my_week);
  		first_day_of_week = first_day_of_week.addDays(7);
  		//check to see if the first day of the week is in the next month - if so we're stopping
  		if(first_day_of_week.month() > first_day.month() || first_day_of_week.year() > first_day.year())
  		  work_thru=0;
  		// System.debug('First of week : ' + first_day_of_week);
  		Safety_valve++;
  		System.assert(safety_valve <= 7);
  	}
  	// System.debug('New Open Days : ' + new_day_list.size());
  	if(new_day_list.size()>0) {
  	  try {
  	  	// System.Debug('New Days : ' + new_day_list);
  	  	//insert new_day_list;
  	  }
  	  catch (Exception e) {
  	  	// System.debug('Error inserting open calendar days : ' + e);
  	  }
  	}
  }

  public class CalendarWeek {
  	public List<CalendarDay> days;
  	public List<Center_Open_Day__c> new_week_days {get;set;}

  	public CalendarWeek(Date first_day, Integer display_month,  Integer selected_date, map<date,integer> aval_apt_info, map<date,integer> total_apt_info, map<date,Center_Open_Day__c> open_day_status, String center_id) {
  	  // System.debug('Open Day Status Size ' + open_day_status.size());
  	  new_week_days = new List<Center_Open_Day__c>();
  	  days = new List<CalendarDay>();
  	  for(Integer i=0;i<7;i++) {
  	  	CalendarDay my_date = new CalendarDay(first_day, display_month, selected_date, aval_apt_info, total_apt_info, open_day_status, center_id);
  	  	if(my_date.new_days.size()>0) {
  	  	  for(Center_Open_Day__c cd : my_date.new_days) {
  	  	  	new_week_days.add(cd);
  	  	  }
  	  	}
  	  	first_day = first_day.addDays(1);
  	  	days.add(my_date);
  	  	// System.debug('Adding Date : ' + my_date.thisdate + ' ' + my_date.display_date);
  	  }
  	}

  	public List<CalendarDay> getdays() {
  	  return this.days;
  	}
  }

  public class CalendarDay {
  	//need to return a day,  number of consults,  avaliable consults,  possibly subset of overflow counts
  	public Date thisdate;
  	public Integer month_num, year_num;
  	public Boolean display_date = false;
  	public String css_style = 'no_consults';
  	public String css_open_style = 'full';
  	public List<Center_Open_Day__c> new_days {get;set;}
  	public Center_Open_Day__c cd {get; set;}

  	public CalendarDay(Date init_date, Integer display_month, Integer selected_date, map<date,integer> aval_apt_info, map<date,integer> total_apt_info, map<date,Center_Open_Day__c> open_day_status, String center_id) {
  	  // System.debug('Open Day Status Size ' + open_day_status.size());
  	  new_days = new List<Center_Open_Day__c>();
  		thisdate = init_date;
  		month_num = thisdate.month();
  		year_num = thisdate.year();
  	  if(month_num==display_month)
  	    display_date = true;
  	  if(thisdate.day()==selected_date && thisdate.month()==display_month) {
  	    css_open_style = 'selected';
  	    css_style = 'selected';
  	  }
  	  else {
  	  	Integer total_apts;
  	  	Integer aval_apts;
  	  	Decimal aval_per;
  	  	if(total_apt_info.get(thisdate)==null)
  	  	  total_apts = 0;
  	  	else
  	  	  total_apts = total_apt_info.get(thisdate);
  	  	if(aval_apt_info.get(thisdate)==null)
  	  	  aval_apts = 0;
  	  	else
  	  	  aval_apts = aval_apt_info.get(thisdate);

  	  	if(total_apts==0)
  	  	  css_style = 'no_apt';
  	  	else {
  	  	  aval_per = aval_apts;
  	  	  aval_per = aval_per.divide(total_apts,3) * 100;
  	  	  //System.debug('Date : ' + thisdate + ' Avl % : ' + aval_per + ' Aval Apts : ' + aval_apts + ' Total Apts : ' + total_apts);
  	  	  if(aval_per > 50)
  	  	    css_style = 'empty';
  	  	  else if(aval_per > 5  && aval_per <= 50)
  	  	    css_style = 'near_full';
  	  	  else if(aval_per <= 5)
  	  	    css_style = 'full';
  	  	}
  	  	// System.debug('This Date ' + thisdate + ' Open Day lookup ' + open_day_status.get(thisdate));
  	  	if(open_day_status.get(thisdate)==null) {
  	  	  cd = new Center_Open_Day__c(calendar_date__c = thisdate, center_information__c = center_id);
  	  	  if(DateTime.newInstance(thisdate.year(),thisdate.month(),thisdate.day()).format('EEEE')=='Monday' || DateTime.newInstance(thisdate.year(),thisdate.month(),thisdate.day()).format('EEEE')=='Tuesday'
  	  	    || DateTime.newInstance(thisdate.year(),thisdate.month(),thisdate.day()).format('EEEE')=='Wednesday' || DateTime.newInstance(thisdate.year(),thisdate.month(),thisdate.day()).format('EEEE')=='Thursday') {
  	  	     cd.open_status__c = 'Open';
  	  	     css_open_style = 'near_full';
  	  	  }
  	  	  else {
  	  	    cd.open_status__c = 'Closed';
  	  	  }
  	  	  new_days.add(cd);
  	  	}
  	  	else {
  	  	  cd = open_day_status.get(thisdate);
  	  	  if(cd.Pending_Close_Requests__c > 0)
  	  	    css_open_style = 'pending';
  	  	  else if(cd.open_status__c == 'Open')
  	  	    css_open_style = 'near_full';
  	  	  else if(cd.open_status__c == 'Holiday')
  	  	    css_open_style = 'full';
  	  	}
  	  }
  	}

  	public Integer getdate_num() { return thisdate.day();	}
  	public Boolean getdisplay_date() {return display_date;}
  	public String getcss_style() {return css_style;}
  	public String getcss_open_style() {return css_open_style;}
  }

  public String getMonthName() {
 		return DateTime.newInstance(first_day.year(),first_day.month(),first_day.day()).format('MMMM');
  }

  public Integer getYearNum() {
  	return first_day.year();
  }

  public List<CalendarWeek> getweeks() {
  	return this.weeks;
  }
}