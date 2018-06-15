public class dp_clinical_cmonth {
  public List<dp_clinical_cweek> weeks;
  public Date first_day;
  public Date idate {get;set;} 
  
  public dp_clinical_cmonth(Date init_date) {
  	standard_controller_calls(init_date);
  }
    
  public dp_clinical_cmonth(Date init_date, Center_Information__c center) {  	
  	first_day = init_date.toStartOfMonth();
  	idate = init_date;
  	Date first_day_of_week = first_day.toStartOfWeek();
  	Date first_day_safety = first_day.addDays(-7);
  	Date last_day = first_day.addMonths(1).addDays(-1);
  	Date last_day_safety = last_day.addDays(7);
  	Integer work_thru = 1;
  	Integer safety_valve = 0;
  	weeks = new List<dp_clinical_cweek>();
  	//make sure we have lab tech #
  	center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where id=:center.id];
  	//add mapping stuff here
  	Map<Date,Decimal> lab_map = new Map<Date,Decimal>();
  	String query_str = 'select apt_date__c,sum(patient_pot_apt__r.lab_time__c) lab_time from clinical_apt_calendar__c ' + 
    ' where clinical_room__r.center_information__c = \'' + center.id + '\'' + 
    ' and apt_date__c >= ' + Datetime.newinstance(first_day_safety.year(),first_day_safety.month(),first_day_safety.day()).format('yyyy-MM-dd') + 
    ' and apt_date__c <= ' + Datetime.newinstance(last_day_safety.year(),last_day_safety.month(),last_day_safety.day()).format('yyyy-MM-dd') + 
    ' group by apt_date__c';
  	for(AggregateResult ar : database.query(query_str)) {
  	  lab_map.put((Date)ar.get('apt_date__c'),(Decimal)ar.get('lab_time'));	
  	}
  	while(work_thru==1) {
      dp_clinical_cweek my_week = new dp_clinical_cweek(first_day_of_week, first_day.month(), init_date.day(), center.number_of_lab_techs__c, lab_map);
      weeks.add(my_week);  		
  	  first_day_of_week = first_day_of_week.addDays(7);
  	  //check to see if the first day of the week is in the next month - if so we're stopping
  	  if(first_day_of_week.month() > first_day.month() || first_day_of_week.year() > first_day.year())
  		work_thru=0;
  	  Safety_valve++;
  	  System.assert(safety_valve <= 7);
  	}
  	//
  }
  
  public void standard_controller_calls(Date init_date) {
  	first_day = init_date.toStartOfMonth();
  	idate = init_date;
  	Date first_day_of_week = first_day.toStartOfWeek();
  	Date first_day_safety = first_day.addDays(-7);
  	Date last_day = first_day.addMonths(1).addDays(-1);
  	Date last_day_safety = last_day.addDays(7);
  	Integer work_thru = 1;
  	Integer safety_valve = 0;
  	weeks = new List<dp_clinical_cweek>();
  	//work through weeks until we get to the end of the month
  	while(work_thru==1) {
      dp_clinical_cweek my_week = new dp_clinical_cweek(first_day_of_week, first_day.month(), init_date.day());
      weeks.add(my_week);  		
  	  first_day_of_week = first_day_of_week.addDays(7);
  	  //check to see if the first day of the week is in the next month - if so we're stopping
  	  if(first_day_of_week.month() > first_day.month() || first_day_of_week.year() > first_day.year())
  		work_thru=0;
  	  Safety_valve++;
  	  System.assert(safety_valve <= 7);
  	}
  }
  
  public class dp_clinical_cweek {
  	public List<dp_clinical_cday> days;
  	public Map<Date,Decimal> lab_time_map;
  	
  	public dp_clinical_cweek(Date first_day, Integer display_month,  Integer selected_date) {
  	  days = new List<dp_clinical_cday>();
  	  for(Integer i=0;i<7;i++) {
  	  	dp_clinical_cday my_date = new dp_clinical_cday(first_day, display_month, selected_date, 0, null);
  	  	days.add(my_date);  	  	
  	  	first_day = first_day.addDays(1);
  	  }
  	  lab_time_map = null;
  	}
  	
  	public dp_clinical_cweek(Date first_day, Integer display_month,  Integer selected_date, Decimal lab_techs, Map<Date,Decimal> lmap) {
  	  days = new List<dp_clinical_cday>();
  	  for(Integer i=0;i<7;i++) {
  	  	Decimal lab_time = 0;
  	  	if(lmap.get(first_day)!=null)
  	  	  lab_time = lmap.get(first_day);
  	  	dp_clinical_cday my_date = new dp_clinical_cday(first_day, display_month, selected_date, lab_techs, lab_time);
  	  	days.add(my_date);  	  	
  	  	first_day = first_day.addDays(1);
  	  }
  	  this.lab_time_map = lmap;
  	}
  	
  	public List<dp_clinical_cday> getdays() {return this.days;}
  }
  
  public class dp_clinical_cday {
  	//need to return a day,  number of consults,  avaliable consults,  possibly subset of overflow counts
  	public Date thisdate;
  	public Integer month_num, year_num;  	
  	public Boolean display_date = false;
  	public String css_style = 'unselected';
  	public Decimal lab_time;
  	public Decimal lab_techs;
  	  	
  	public dp_clinical_cday(Date init_date, Integer display_month, Integer selected_date, Decimal ltechs, Decimal ltime) {	
  	  thisdate = init_date;
  	  month_num = thisdate.month();
  	  year_num = thisdate.year();  	
  	  if(month_num==display_month)
  	    display_date = true;
  	  if(thisdate.day()==selected_date && thisdate.month()==display_month) {
  	    css_style = 'selected';
  	  }  	  
  	  this.lab_techs = ltechs;
  	  this.lab_time = ltime;
  	}
  	
  	public Integer getdate_num() { return thisdate.day();	}
  	public Boolean getdisplay_date() {return display_date;}
  	public String getcss_style() {return css_style;}
  	public String getlab_color() {
  	  String lab_css = 'black';
  	  Decimal green_top = (lab_techs * 555) * .75;
  	  Decimal yellow_top = (lab_techs * 555) * .85;
  	  if(lab_time!=null)
  	    if(lab_time < green_top)
          lab_css = 'green';
        else if(lab_time < yellow_top)
          lab_css = 'orange';
        else
          lab_css = 'red';
      return lab_css;  
  	}
  }
  
  public String getMonthName() {return DateTime.newInstance(first_day.year(),first_day.month(),first_day.day()).format('MMMM');}
  public String getShortMonthName() {return DateTime.newInstance(first_day.year(),first_day.month(),first_day.day()).format('MMM');}  	 	
  
  public Integer getYearNum() {return first_day.year();}
  public Integer getMonthNum() {return first_day.month();}
  public Integer getDayNum() {return first_day.day();}
  
  public List<dp_clinical_cweek> getweeks() {return this.weeks;}    
}