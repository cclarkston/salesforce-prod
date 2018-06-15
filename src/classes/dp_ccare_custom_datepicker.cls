public with sharing class dp_ccare_custom_datepicker {    
  public final dp_clinical_pot main_controller;
  
  public Boolean display_calendar_view_start {get; set;}
  public Boolean display_calendar_view_end {get; set;}
  public dp_clinical_cmonth cmonth_start {get;set;}
  public dp_clinical_cmonth cmonth_end {get;set;}
  public String modal_calendar_view_start {get; set;}
  public String modal_calendar_view_end {get; set;}
    
  public dp_ccare_custom_datepicker(dp_clinical_pot mcontroller) {
    this.main_controller = mcontroller;
    display_calendar_view_start = false;
    display_calendar_view_end = false;
  }
    
  public void calendar_select_today() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  main_controller.report_sdate = system.today();
  	  display_calendar_view_start = false;
  	  cmonth_start = new dp_clinical_cmonth(main_controller.report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  main_controller.report_edate = system.today();
  	  display_calendar_view_end = false;
  	  cmonth_end = new dp_clinical_cmonth(main_controller.report_edate);
  	}
  }
  
  public void prev_calendar_day() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  main_controller.report_sdate = main_controller.report_sdate.adddays(-1);
  	  cmonth_start = new dp_clinical_cmonth(main_controller.report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  main_controller.report_edate = main_controller.report_edate.adddays(-1);
  	  cmonth_end = new dp_clinical_cmonth(main_controller.report_edate);
  	}
  }  
    
  public void next_calendar_day() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  main_controller.report_sdate = main_controller.report_sdate.adddays(1);
  	  cmonth_start = new dp_clinical_cmonth(main_controller.report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  main_controller.report_edate = main_controller.report_edate.adddays(1);
  	  cmonth_end = new dp_clinical_cmonth(main_controller.report_edate);
  	}
  }
  
  public void display_calendar_navigation() {  	
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  display_calendar_view_start = true;
  	  modal_calendar_view_start = 'calendar';
  	  cmonth_start = new dp_clinical_cmonth(main_controller.report_sdate);
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  display_calendar_view_end = true;
  	  modal_calendar_view_end = 'calendar';
  	  cmonth_end = new dp_clinical_cmonth(main_controller.report_edate);
  	}
  }
  
  public void next_calendar_month() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') 
  	  cmonth_start = new dp_clinical_cmonth(cmonth_start.idate.addmonths(1));
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') 
  	  cmonth_end = new dp_clinical_cmonth(cmonth_end.idate.addmonths(1));
  }
  
  public void prev_calendar_month() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') 
  	  cmonth_start = new dp_clinical_cmonth(cmonth_start.idate.addmonths(-1));
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') 
  	  cmonth_end = new dp_clinical_cmonth(cmonth_end.idate.addmonths(-1));
  }
  
  public void close_calendar_navigation() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start')
  	  display_calendar_view_start = false;
  	if(apexpages.currentpage().getparameters().get('dtype')=='end')
  	  display_calendar_view_end = false;
  }
  
  public void select_calendar_day() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  main_controller.report_sdate = Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('cyear')),Integer.valueof(apexpages.currentpage().getparameters().get('cmonth')),Integer.valueof(apexpages.currentpage().getparameters().get('cday')));
  	  cmonth_start = new dp_clinical_cmonth(main_controller.report_sdate);
  	  display_calendar_view_start = false;
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  main_controller.report_edate = Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('cyear')),Integer.valueof(apexpages.currentpage().getparameters().get('cmonth')),Integer.valueof(apexpages.currentpage().getparameters().get('cday')));
  	  cmonth_end = new dp_clinical_cmonth(main_controller.report_edate);
  	  display_calendar_view_end = false;
  	}  	
  }
  
  public void display_calendar_month_navigation() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start')
  	  modal_calendar_view_start = 'month';
  	if(apexpages.currentpage().getparameters().get('dtype')=='end')
  	  modal_calendar_view_end = 'month';
  }
  
  public void display_calendar_year_navigation() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start')
  	  modal_calendar_view_start = 'year';
  	if(apexpages.currentpage().getparameters().get('dtype')=='end')
  	  modal_calendar_view_end = 'year';
  } 
  
  public void select_calendar_month() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  cmonth_start = new dp_clinical_cmonth(Date.newinstance(cmonth_start.idate.year(),Integer.valueof(apexpages.currentpage().getparameters().get('mnum')),cmonth_start.idate.day()));
  	  modal_calendar_view_start = 'calendar';
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  cmonth_end = new dp_clinical_cmonth(Date.newinstance(cmonth_end.idate.year(),Integer.valueof(apexpages.currentpage().getparameters().get('mnum')),cmonth_end.idate.day()));
  	  modal_calendar_view_end = 'calendar';
  	}
  }
  
  public void select_calendar_year() {
  	if(apexpages.currentpage().getparameters().get('dtype')=='start') {
  	  cmonth_start = new dp_clinical_cmonth(Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('myear')),cmonth_start.idate.month(),cmonth_start.idate.day()));
  	  modal_calendar_view_start = 'calendar';
  	}
  	if(apexpages.currentpage().getparameters().get('dtype')=='end') {
  	  cmonth_end = new dp_clinical_cmonth(Date.newinstance(Integer.valueof(apexpages.currentpage().getparameters().get('myear')),cmonth_end.idate.month(),cmonth_end.idate.day()));
  	  modal_calendar_view_end = 'calendar';
  	}
  }
  
  public List<List<String>> getmonth_list() {
  	List<String> month_names = new List<String>();
  	List<List<String>> month_rows = new List<List<String>>();
  	for(Integer i=1;i<=12;i++) {
  	  Datetime month_start = Datetime.newInstance(System.today().year(), i, 1,0,0,0);
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
    Integer end_limit = today_date.year()+1;
  	for(Integer i=2010;i<=end_limit;i++) {
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
  
  
}