public without sharing class rpt_call_center_dash {
	public Date sdate {get;set;}
	public Date edate {get;set;}
	public Consult_Inventory__c sholder {get; set;}
	public Consult_Inventory__c eholder {get; set;}
	public String error_messages {get; set;}
	public String file_header {get; set;}
	public String file_name {get; set;}
	public String schedule_file_name {get; set;}
	public Center_Stats total_cs {get; set;}
	public String report_year {get; set;}
	public String report_month {get; set;}
		
  public rpt_call_center_dash() {
  	sholder = new Consult_Inventory__c();
  	eholder = new Consult_Inventory__c();
  	sholder.apt_date__c = System.today().addDays(-1);      
    eholder.apt_date__c = System.today().addDays(-1);
    Date dtoday = date.today();
    if(apexpages.currentpage().getparameters().get('sdate')!=null) {
  	  dtoday = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
    }
    else
  	  sdate = sholder.apt_date__c;
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.apt_date__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));        	  
    file_name = 'cc_dashboard_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    schedule_file_name = 'consult_usage_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    report_year = String.valueof(dtoday.addMonths(-1).year());
    report_month = String.valueof(dtoday.addMonths(-1).month());  
  }
  
  public List<SelectOption> getyear_list() {  	
    List<SelectOption> options = new List<SelectOption>();
    for(Integer start_year = 2012;start_year<=System.today().addMonths(-1).year();start_year++) {
    	options.add(new SelectOption(String.valueof(start_year),String.valueof(start_year)));    	
    }
    return options;
  }
  
  public List<SelectOption> getmonth_list() {  	
  	Map<Integer,String> month_list = new Map<Integer,String> {1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
    List<SelectOption> options = new List<SelectOption>();
    for(Integer start_month = 1;start_month<=12;start_month++) {
    	options.add(new SelectOption(String.valueof(start_month),month_list.get(start_month)));    	
    }
    return options;
  }
  
  public string getcsv_daterange() {
  	Datetime start_time = datetime.newInstance(sdate, time.newInstance(0,0,0,0));
  	Datetime end_time = datetime.newInstance(edate, time.newInstance(0,0,0,0));
  	String return_value = 'Report for : ' + start_time.format('M/dd/yyyy') + ' - ' + end_time.format('M/dd/yyyy');
  	return return_value;
  }
  
  public class Center_Stats {
  	public Center_Information__c my_center {get; set;}
  	public Integer DI_Leads {get; set;}
  	public Integer DI_gy {get; set;}
  	public Integer DI_consults_booked {get; set;}
  	public Integer revived_leads {get; set;}
  	public Integer revived_gy {get; set;}
  	public Integer DI_consults_gy {get; set;}
  	public Integer available_consults {get; set;}
  	public Integer scheduled_consults {get; set;}
  	public Integer scheduled_consults_gy {get; set;}
  	public Integer initially_scheduled_consults {get; set;}
  	public Integer final_scheduled_consults {get; set;}
  	public Integer final_scheduled_consults_gy {get; set;}
  	public Integer consults_showed {get; set;}
  	public Integer consults_showed_gy {get; set;}
  	public Integer starts {get; set;}
  	public Integer starts_mtd {get; set;}
  	public Integer available_consults_next_week {get; set;}
  	public Integer scheduled_consults_next_week {get; set;}
  	public Integer scheduled_consults_next_week_gy {get; set;}
  	public Integer available_consults_two_week {get; set;}
  	public Integer scheduled_consults_two_week {get; set;}
  	public Integer scheduled_consults_two_week_gy {get; set;}
  	public Integer available_consults_three_week {get; set;}
  	public Integer scheduled_consults_three_week {get; set;}
  	public Integer scheduled_consults_three_week_gy {get; set;}
  	public Integer available_consults_four_week {get; set;}
  	public Integer scheduled_consults_four_week {get; set;}
  	public Integer scheduled_consults_four_week_gy {get; set;}
  	public Integer available_consults_five_week {get; set;}
  	public Integer scheduled_consults_five_week {get; set;}
  	public Integer scheduled_consults_five_week_gy {get; set;}
  	public Integer available_consults_six_week {get; set;}
  	public Integer scheduled_consults_six_week {get; set;}
  	public Integer scheduled_consults_six_week_gy {get; set;}
  	public Decimal sales_goal {get; set;}
  	public Decimal net_collections {get; set;}
  	public Decimal budgeted_consults {get; set;}
  	public Date first_rb_apt {get; set;}
  	
  	public Center_Stats(Center_Information__c c) {
  		this.my_center = c;
  		this.sales_goal = 0.00;
  		this.net_collections = 0.00;
  		this.budgeted_consults = 0.00;
  		this.di_leads = 0;
  		this.di_gy = 0;
  		this.di_consults_booked = 0;
  		this.revived_leads = 0;
  		this.revived_gy = 0;
  		this.di_consults_gy = 0;
  		this.available_consults = 0;
  		this.scheduled_consults = 0;
  		this.scheduled_consults_gy = 0;
  	  this.initially_scheduled_consults = 0; 
  	  this.final_scheduled_consults = 0;
  	  this.final_scheduled_consults_gy = 0;
  	  this.consults_showed = 0;
  	  this.consults_showed_gy = 0;
  	  this.starts = 0;
  	  this.starts_mtd = 0;
  	  this.available_consults_next_week = 0; 
  	  this.scheduled_consults_next_week = 0;
  	  this.scheduled_consults_next_week_gy = 0;
  	  this.available_consults_two_week = 0;
  	  this.scheduled_consults_two_week = 0;
  	  this.scheduled_consults_two_week_gy = 0;
  	  this.available_consults_three_week = 0;
  	  this.scheduled_consults_three_week = 0;
  	  this.scheduled_consults_three_week_gy = 0;
  	  this.available_consults_four_week = 0;
  	  this.scheduled_consults_four_week = 0;
  	  this.scheduled_consults_four_week_gy = 0;
  	  this.available_consults_five_week = 0;
  	  this.scheduled_consults_five_week = 0;
  	  this.scheduled_consults_five_week_gy = 0;
  	  this.available_consults_six_week = 0;
  	  this.scheduled_consults_six_week = 0;
  	  this.scheduled_consults_six_week_gy = 0;
  	}
  	
  	public Decimal getdi_gy_percent() {
  		if(di_leads==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((di_gy * 1.00) / (di_leads * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getcslts_gy_percent() {
  		if((di_consults_booked + revived_leads)==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((di_consults_gy + revived_gy * 1.00) / (di_consults_booked + revived_leads * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getcslts_gy_percent_alt() {
  		if(di_consults_booked==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((di_consults_gy * 1.00) / (di_consults_booked * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getrevived_gy_percent() {
  		if(revived_leads==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((revived_gy * 1.00) / (revived_leads * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getschedule_rate() {
  		if(di_leads==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((di_consults_booked * 1.00) / (di_leads * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_rate() {
  		if(available_consults==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults * 1.00) / (available_consults * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getfinal_gy_rate() {
  		if(final_scheduled_consults==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((final_scheduled_consults_gy * 1.00) / (final_scheduled_consults * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getshow_gy_rate() {
  		if(consults_showed==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((consults_showed_gy * 1.00) / (consults_showed * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getshow_rate() {
  		if(consults_showed==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((consults_showed * 1.00) / (final_scheduled_consults * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getcomplete_rate() {
  		if(consults_showed==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((consults_showed * 1.00) / (initially_scheduled_consults * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_next_rate() {
  		if(available_consults_next_week==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults_next_week * 1.00) / (available_consults_next_week * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_2_rate() {
  		if(available_consults_two_week==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults_two_week * 1.00) / (available_consults_two_week * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_3_rate() {
  		if(available_consults_three_week==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults_three_week * 1.00) / (available_consults_three_week * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_4_rate() {
  		if(available_consults_four_week==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults_four_week * 1.00) / (available_consults_four_week * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_5_rate() {
  		if(available_consults_five_week==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults_five_week * 1.00) / (available_consults_five_week * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getconsults_booked_6_rate() {
  		if(available_consults_six_week==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((scheduled_consults_six_week * 1.00) / (available_consults_six_week * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	  	
  	public Decimal getclose_rate() {
  		if(consults_showed==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = ((starts * 1.00) / (consults_showed * 1.00));
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getgoal_rate() {
  		if(sales_goal==0)
  		  return 0.00;
  		else {
  		  Decimal my_percent = (net_collections  / sales_goal);
  		  return my_percent.setscale(2);
  		}
  	}
  	
  	public Decimal getbudgeted_consults_week() {
  		if(budgeted_consults==0)
  		  return 0;
  		else {
  		  Decimal my_percent = (budgeted_consults / 4);
  		  return my_percent.setscale(0);
  		}
  	}
  	
  	public String getfirst_aval() {
  		if(first_rb_apt==null)
  		  return '<span class="blank">N/A</span>';
  		else
  		  return String.valueof(first_rb_apt);
  	}
  }
  
  public static void rerun_report() {

  }
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public String getcsv_link() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format();
  	return hyper_link;
  }
  
  public String getcsv_altlink() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '&alt=1';
  	return hyper_link;
  }
  
  public String getcsv_altlink_po() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '&alt=2';
  	return hyper_link;
  }
  
  public String getcsv_altlink_month() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '&alt=3';
  	return hyper_link;
  }
  
  public Pagereference view_month_dash() {
  	Pagereference pr = Page.cc_dashboard_month;
  	pr.setredirect(true);
  	return pr;
  }
  
  public Pagereference view_wtl_dash() {
  	Pagereference pr = Page.wtl_dashboard;
  	pr.setredirect(true);
  	return pr;
  }
  
  public Pagereference view_utilization() {
    Pagereference pr = Page.cc_schedule;
  	pr.setredirect(true);
  	return pr;
  }
  
  public Pagereference view_dashboard() {
  	Pagereference pr = Page.cc_dashboard;
  	pr.setredirect(true);
  	return pr;
  }
  
  public CSVOutput[] getcsv_output() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	if(apexpages.currentpage().getparameters().get('alt')!=null)
  	  if(apexpages.currentpage().getparameters().get('alt')=='3')
  	    csvout = getcsv_alt_month_output();
  	  else
        csvout = getcsv_altoutput();  		
  	else {  	
	  	Center_Stats[] all_centers = getcenter_numbers();
	  	file_header = '"Center","Dental Inquiry Leads","New Leads GY %","Cslts Booked","Revived Leads","GY Prescreen of cslts booked","Schedule Rate on Phone","Available Consult Chairs","Target Consults Current Week","Scheduled Consults Current Week","% Consults Booked","Initially Scheduled Consults","Final Scheduled Consults","Consults Completed","GY Prescreen Mix of Consults Showed","Show Rate","Complete Rate","Starts","Close Rate Incl All PP","Starts MTD","Actual Consult Chairs New Week","Scheduled Consults Next Week","% of Consults Scheduled Next Week","% of Consults Scheduled 2nd week","% of Consults Scheduled 3rd Week","% of Consults Scheduled 4th week"';
	  	for(Center_Stats cs : all_centers) {
	  		CSVOutput csv_line = new CSVOutput();
	  		csv_line.output_line =  cs.my_center.name + ',';
	  		csv_line.output_line += cs.di_leads + ',';
	      csv_line.output_line += cs.getdi_gy_percent() + ',';
	  		csv_line.output_line += cs.di_consults_booked + ',';
	  		csv_line.output_line += cs.revived_leads + ',';
	  		csv_line.output_line += cs.getcslts_gy_percent() + ',';
	  		csv_line.output_line += cs.getschedule_rate() + ',';
	  		if(cs.available_consults==0) 
	  			csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,';
	  		else {
		  		csv_line.output_line += cs.available_consults + ',';
		  		csv_line.output_line += cs.getbudgeted_consults_week() + ',';
		  		csv_line.output_line += cs.scheduled_consults + ',';
		  		csv_line.output_line += cs.getconsults_booked_rate() + ',';
		  		csv_line.output_line += cs.initially_scheduled_consults + ',';
		  		csv_line.output_line += cs.final_scheduled_consults + ',';
		  		csv_line.output_line += cs.consults_showed + ',';
		  		csv_line.output_line += cs.getshow_gy_rate() + ',';
		  		csv_line.output_line += cs.getshow_rate() + ',';
		  		csv_line.output_line += cs.getcomplete_rate() + ',';
		  		csv_line.output_line += cs.starts + ',';
		  		csv_line.output_line += cs.getclose_rate() + ',';
	  		}
	  		csv_line.output_line += cs.starts_mtd + ',';
	  		if(cs.available_consults_next_week==0) 
	  		  csv_line.output_line += 'Vacation,Vacation,Vacation,';
	  		else {
	  		  csv_line.output_line += cs.available_consults_next_week + ',';
	  		  csv_line.output_line += cs.scheduled_consults_next_week + ',';
	  		  csv_line.output_line += cs.getconsults_booked_next_rate() + ',';
	  		}		
	  		if(cs.available_consults_two_week==0)
	  		  csv_line.output_line += 'Vacation,';
	  		else
	  		  csv_line.output_line += cs.getconsults_booked_2_rate() + ',';
	  		if(cs.available_consults_three_week==0)
	  		  csv_line.output_line += 'Vacation,';
	  		else
	  		  csv_line.output_line += cs.getconsults_booked_3_rate() + ',';
	  		if(cs.available_consults_four_week==0)
	  		  csv_line.output_line += 'Vacation,';
	  		else    
	  		  csv_line.output_line += cs.getconsults_booked_4_rate();
	  		//csv_line.output_line += cs.getgoal_rate();
				csvout.add(csv_line);  	
	  	}  	
  	}
  	return csvout;
  }  
  
  public CSVOutput[] getcsv_alt_month_output() {
  	CSVOutput[] csvout = new CSVOutput[] {}; 
  	Center_Stats[] all_centers;
  	file_header = '"Center","Dental Inquiry Leads","New Leads GY %","Cslts Booked","Revived Leads","GY Prescreen of cslts booked","Schedule Rate on Phone","Available Consult Chairs","Target Consults Current Week","Scheduled Consults Current Week","% Consults Booked","Initially Scheduled Consults","Final Scheduled Consults","GY Final Scheduled Consults","Consults Completed","GY Prescreen Mix of Consults Showed","Show Rate","Complete Rate","Starts","Close Rate","Starts MTD"';
  	all_centers = getcenter_numbers_monthly();  	
  	
  	for(Center_Stats cs : all_centers) {
  		CSVOutput csv_line = new CSVOutput();
  		csv_line.output_line =  cs.my_center.name + ',';
  		csv_line.output_line += cs.di_leads + ',';
      csv_line.output_line += cs.getdi_gy_percent() + ',';
  		csv_line.output_line += cs.di_consults_booked + ',';
  		csv_line.output_line += cs.revived_leads + ',';
  		csv_line.output_line += cs.getcslts_gy_percent() + ',';
  		csv_line.output_line += cs.getschedule_rate() + ',';
  		if(cs.available_consults==0) 
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults + ',';
	  		csv_line.output_line += cs.budgeted_consults + ',';
	  		csv_line.output_line += cs.scheduled_consults + ',';
	  		csv_line.output_line += cs.getconsults_booked_rate() + ',';
	  		csv_line.output_line += cs.initially_scheduled_consults + ',';
	  		csv_line.output_line += cs.final_scheduled_consults + ',';
	  		csv_line.output_line += cs.getfinal_gy_rate() + ',';
	  		csv_line.output_line += cs.consults_showed + ',';
	  		csv_line.output_line += cs.getshow_gy_rate() + ',';
	  		csv_line.output_line += cs.getshow_rate() + ',';
	  		csv_line.output_line += cs.getcomplete_rate() + ',';
  		}  		
  		csv_line.output_line += cs.starts + ',';
  		csv_line.output_line += cs.getclose_rate() + ',';
  		csv_line.output_line += cs.starts_mtd + ',';
			csvout.add(csv_line);  	
  	}  	
  	return csvout;
  }
  
  public CSVOutput[] getcsv_altoutput() {
  	CSVOutput[] csvout = new CSVOutput[] {}; 
  	Center_Stats[] all_centers;
  	if(apexpages.currentpage().getparameters().get('alt')=='2') {
  	  file_header = '"Center","Dental Inquiry Leads","New Leads PO %","Cslts Booked","Revived Leads","PO Prescreen of cslts booked","Schedule Rate on Phone","Available Consult Chairs","Target Consults Current Week","Scheduled Consults Current Week","% Consults Booked","Initially Scheduled Consults","Final Scheduled Consults","PO Final Scheduled Consults","Consults Completed","PO Prescreen Mix of Consults Showed","Show Rate","Complete Rate","GY Scheduled Consults Current Week","Actual Consult Chairs Next Week","Scheduled Consults Next Week","PO % Scheduled Consults Next Week","% of Consults Scheduled Next Week","Actual Consult Chairs 2nd Week","Scheduled Consults 2nd Week","PO % Scheduled Consults 2nd Week","% of Consults Scheduled 2nd week","Actual Consult Chairs 3rd Week","Scheduled Consults 3rd Week","PO % Scheduled Consults 3rd Week","% of Consults Scheduled 3rd Week","Actual Consult Chairs 4th Week","Scheduled Consults 4th Week","PO % Scheduled Consults 4th Week","% of Consults Scheduled 4th week","Actual Consult Chairs 5th Week","Scheduled Consults 5th Week","PO % Scheduled Consults 5th Week","% of Consults Scheduled 5th week","Actual Consult Chairs 6th Week","Scheduled Consults 6th Week","PO % Scheduled Consults 6th Week","% of Consults Scheduled 6th week","GY% Booked DI","GY% Revived Leads"';
  	  all_centers = getcenter_numbers_pobox();
  	} 	
  	//if(apexpages.currentpage().getparameters().get('alt')=='1') {
  	else {
  	  file_header = '"Center","Dental Inquiry Leads","New Leads GY %","Cslts Booked","Revived Leads","GY Prescreen of cslts booked","Schedule Rate on Phone","Available Consult Chairs","Target Consults Current Week","Scheduled Consults Current Week","% Consults Booked","Initially Scheduled Consults","Final Scheduled Consults","GY Final Scheduled Consults","Consults Completed","GY Prescreen Mix of Consults Showed","Show Rate","Complete Rate","GY Scheduled Consults Current Week","Actual Consult Chairs Next Week","Scheduled Consults Next Week","GY % Scheduled Consults Next Week","% of Consults Scheduled Next Week","Actual Consult Chairs 2nd Week","Scheduled Consults 2nd Week","GY % Scheduled Consults 2nd Week","% of Consults Scheduled 2nd week","Actual Consult Chairs 3rd Week","Scheduled Consults 3rd Week","GY % Scheduled Consults 3rd Week","% of Consults Scheduled 3rd Week","Actual Consult Chairs 4th Week","Scheduled Consults 4th Week","GY % Scheduled Consults 4th Week","% of Consults Scheduled 4th week","Actual Consult Chairs 5th Week","Scheduled Consults 5th Week","GY % Scheduled Consults 5th Week","% of Consults Scheduled 5th week","Actual Consult Chairs 6th Week","Scheduled Consults 6th Week","GY % Scheduled Consults 6th Week","% of Consults Scheduled 6th week","GY% Booked DI","GY% Revived Leads","New Lead GY #","Revived Lead GY #","Consults Scheduled GY #","Final Scheduled GY #","Consults Showed GY #"';
  	  all_centers = getcenter_numbers();
  	}
  	
  	for(Center_Stats cs : all_centers) {
  		CSVOutput csv_line = new CSVOutput();
  		csv_line.output_line =  cs.my_center.name + ',';
  		csv_line.output_line += cs.di_leads + ',';
      csv_line.output_line += cs.getdi_gy_percent() + ',';
  		csv_line.output_line += cs.di_consults_booked + ',';
  		csv_line.output_line += cs.revived_leads + ',';
  		csv_line.output_line += cs.getcslts_gy_percent() + ',';
  		csv_line.output_line += cs.getschedule_rate() + ',';
  		if(cs.available_consults==0) 
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults + ',';
	  		csv_line.output_line += cs.getbudgeted_consults_week() + ',';
	  		csv_line.output_line += cs.scheduled_consults + ',';
	  		csv_line.output_line += cs.getconsults_booked_rate() + ',';
	  		csv_line.output_line += cs.initially_scheduled_consults + ',';
	  		csv_line.output_line += cs.final_scheduled_consults + ',';
	  		csv_line.output_line += cs.getfinal_gy_rate() + ',';
	  		csv_line.output_line += cs.consults_showed + ',';
	  		csv_line.output_line += cs.getshow_gy_rate() + ',';
	  		csv_line.output_line += cs.getshow_rate() + ',';
	  		csv_line.output_line += cs.getcomplete_rate() + ',';
	  		if(cs.scheduled_consults==0)
	  		  csv_line.output_line += '0,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_gy * 1.00)/cs.scheduled_consults) * 1.00 + ',';
  		}
  		if(cs.available_consults_next_week==0) 
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults_next_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_next_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_next_week_gy + ',';
	  		/*if(cs.scheduled_consults_next_week==0)
	  		  csv_line.output_line += '0,';
	  		else	  		  
	  		  csv_line.output_line += ((cs.scheduled_consults_next_week_gy * 1.00) / cs.scheduled_consults_next_week) * 1.00 + ',';*/
	  		csv_line.output_line += cs.getconsults_booked_next_rate() + ',';		
  		}
  		if(cs.available_consults_two_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
  			csv_line.output_line += cs.available_consults_two_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_two_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_two_week_gy + ',';
	  		/*if(cs.scheduled_consults_two_week==0)
	  		  csv_line.output_line += '0,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_two_week_gy * 1.00) / cs.scheduled_consults_two_week) * 1.00 + ',';*/
  		  csv_line.output_line += cs.getconsults_booked_2_rate() + ',';
  		}
  		if(cs.available_consults_three_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
  			csv_line.output_line += cs.available_consults_three_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_three_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_three_week_gy + ',';
	  	  /*if(cs.scheduled_consults_three_week==0)
	  		  csv_line.output_line += '0,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_three_week_gy * 1.00) / cs.scheduled_consults_three_week) * 1.00 + ',';*/
  		  csv_line.output_line += cs.getconsults_booked_3_rate() + ',';
  		}
  		if(cs.available_consults_four_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
  			csv_line.output_line += cs.available_consults_four_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_four_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_four_week_gy + ',';
	  		/*if(cs.scheduled_consults_four_week==0)
	  		  csv_line.output_line += '0,';
	  		else
	  			csv_line.output_line += ((cs.scheduled_consults_four_week_gy * 1.00)/ cs.scheduled_consults_four_week) * 1.00 + ',';*/
  		  csv_line.output_line += cs.getconsults_booked_4_rate() + ',';
  		}
  		if(cs.available_consults_five_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
  			csv_line.output_line += cs.available_consults_five_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_five_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_five_week_gy + ',';
	  		/*if(cs.scheduled_consults_five_week==0)
	  		  csv_line.output_line += '0,';
	  		else
	  			csv_line.output_line += ((cs.scheduled_consults_five_week_gy * 1.00)/ cs.scheduled_consults_five_week) * 1.00 + ',';*/
  		  csv_line.output_line += cs.getconsults_booked_5_rate() + ',';
  		}
  		if(cs.available_consults_six_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
  			csv_line.output_line += cs.available_consults_six_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_six_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_six_week_gy + ',';
	  		/*if(cs.scheduled_consults_six_week==0)
	  		  csv_line.output_line += '0,';
	  		else
	  			csv_line.output_line += ((cs.scheduled_consults_six_week_gy * 1.00)/ cs.scheduled_consults_six_week) * 1.00 + ',';*/
  		  csv_line.output_line += cs.getconsults_booked_6_rate() + ',';
  		}  		
  		csv_line.output_line += cs.getcslts_gy_percent_alt() + ',';
  		csv_line.output_line += cs.getrevived_gy_percent() + ',';
  		csv_line.output_line += cs.di_gy + ',';
  		csv_line.output_line += cs.revived_gy + ',';
  		csv_line.output_line += cs.di_consults_gy + ',';
  		csv_line.output_line += cs.final_scheduled_consults_gy + ',';
  		csv_line.output_line += cs.consults_showed_gy + ',';
  		//csv_line.output_line += cs.getgoal_rate();
			csvout.add(csv_line);  	
  	}  	
  	return csvout;
  }
  
  public CSVOutput[] getcsv_scheduleoutput() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	Center_Stats[] all_centers = getcenter_numbers();
  	file_header = '"Center","Next Aval R/B Consult","Current Week # Consults","Current Week Scheduled Consults","Current Week Scheduled GY %","Current Week % Consults Booked","Next Week # Consults"," Next Week Scheduled Consults","Next Week Scheduled GY %","Next Week % of Consults Booked","2nd Week # Consults"," 2nd Week Scheduled Consults","2nd Week Scheduled GY %","2nd Week % of Consults Booked","3rd Week # Consults"," 3rd Week Scheduled Consults","3rd Week Scheduled GY %","3rd Week % of Consults Booked","4th Week # Consults"," 4th Week Scheduled Consults","4th Week Scheduled GY %","4th Week % of Consults Booked","5th Week # Consults"," 5th Week Scheduled Consults","5th Week Scheduled GY %","5th Week % of Consults Booked","6th Week # Consults"," 6th Week Scheduled Consults","6th Week Scheduled GY %","6th Week % of Consults Booked"';
  	for(Center_Stats cs : all_centers) {
  		CSVOutput csv_line = new CSVOutput();
  		csv_line.output_line =  cs.my_center.name + ',';
  		String next_aval = cs.getfirst_aval();
  		if(next_aval.contains('span'))
  		  next_aval = 'N/A';
  		csv_line.output_line += next_aval + ',';
  		if(cs.available_consults==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults + ',';
	  		csv_line.output_line += cs.scheduled_consults + ',';
	  		if(cs.scheduled_consults==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_gy * 1.0)/(cs.scheduled_consults * 1.0)) + ',';
	  		csv_line.output_line += cs.getconsults_booked_rate() + ',';
  		}
  		if(cs.available_consults_next_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults_next_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_next_week + ',';
	  		if(cs.scheduled_consults_next_week==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_next_week_gy * 1.0)/(cs.scheduled_consults_next_week * 1.0)) + ',';
	  		csv_line.output_line += cs.getconsults_booked_next_rate() + ',';
  		}
  		if(cs.available_consults_two_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults_two_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_two_week + ',';    		
	  		if(cs.scheduled_consults_two_week==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_two_week_gy * 1.0)/(cs.scheduled_consults_two_week * 1.0)) + ',';
	  		csv_line.output_line += cs.getconsults_booked_2_rate() + ',';
  		}
  		if(cs.available_consults_three_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	      csv_line.output_line += cs.available_consults_three_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_three_week + ',';
	  		if(cs.scheduled_consults_three_week==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_three_week_gy * 1.0)/(cs.scheduled_consults_three_week * 1.0)) + ',';  		
	  		csv_line.output_line += cs.getconsults_booked_3_rate() + ',';
  		}
  		if(cs.available_consults_four_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	  		csv_line.output_line += cs.available_consults_four_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_four_week + ',';
	  		if(cs.scheduled_consults_four_week==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_four_week_gy * 1.0)/(cs.scheduled_consults_four_week * 1.0)) + ',';  		
	  		csv_line.output_line += cs.getconsults_booked_4_rate() + ',';
  		}
  		if(cs.available_consults_five_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	      csv_line.output_line += cs.available_consults_five_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_five_week + ',';
	  		if(cs.scheduled_consults_five_week==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_five_week_gy * 1.0)/(cs.scheduled_consults_five_week * 1.0)) + ',';  		
	  		csv_line.output_line += cs.getconsults_booked_5_rate() + ',';
  		}
  		if(cs.available_consults_six_week==0)
  		  csv_line.output_line += 'Vacation,Vacation,Vacation,Vacation,';
  		else {
	      csv_line.output_line += cs.available_consults_six_week + ',';
	  		csv_line.output_line += cs.scheduled_consults_six_week + ',';
	  		if(cs.scheduled_consults_six_week==0)
	  		  csv_line.output_line += 'N/A,';
	  		else
	  		  csv_line.output_line += ((cs.scheduled_consults_six_week_gy * 1.0)/(cs.scheduled_consults_six_week * 1.0)) + ',';  		
	  		csv_line.output_line += cs.getconsults_booked_6_rate() + ',';
  		}
			csvout.add(csv_line);  	
  	}  	
  	return csvout;
  }
  
  //alternate version of the call that filters based on po box - lame way to handle this,  but they just want a quick report
  public Center_Stats[] getcenter_numbers_pobox() {
  	if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.apt_date__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.apt_date__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),23,59,59);
  	System.debug('Sdate Time : ' + sdate_time + ' End Date Time : ' + edate_time + ' Sdate : ' + sdate + ' Edate : ' + edate);
  	error_messages = '';
  	if(sdate > edate) {
  	  error_messages = 'Starting Date must be less than or equal to ending date.<br />Please adjust and try again';
      return null;
  	}
  	List<Center_Stats> all_centers = new List<Center_Stats> {};
  	//build a map of center_stats
  	Map<Id,Center_Stats> center_map = new Map<Id,Center_Stats> {};
  	//where name not in ('Unknown')
  	List<Center_Information__c> alpha_center = [select name,id,(Select Budgeted_Consults__c,Sales_Goal__c From Center_Budgets__r where fiscal_year__c = :sdate.year() and fiscal_month__c = :sdate.month()) from Center_Information__c where name not in ('Chicago Deerfield/Northbrook','Unknown') order by name];
  	Map<String,ID> center_translation = new Map<String,ID> {};
  	for(Center_Information__c ci : alpha_center) {
  		Center_Stats cs = new Center_Stats(ci);
  		center_map.put(ci.id,cs);
  		center_translation.put(ci.name,ci.id);
  		for(Center_Budget__c cb : ci.center_budgets__r) {
  			center_map.get(ci.id).sales_goal = cb.sales_goal__c;
  			center_map.get(ci.id).budgeted_consults = cb.budgeted_consults__c;
  		}
  	} 
  	Center_Information__c total_ci = new Center_Information__c(name = 'Totals');
  	total_cs = new Center_Stats(total_ci);
  	//work through all the leads for this time period and store relevant stats
  	for(Lead l : [Select l.Pre_Screen__c, l.Inbound_Call__c, l.Center__c, 
  	  (Select Scheduled_Time__c, Active__c From Consult_Inventory__r where active__c = true) From Lead l where 
  	    createddate >= :sdate_time and createddate <= :edate_time and l.Inbound_Call__c = 'Dental Inquiry' and 
  	    Call_Result__c in ('Consultation Scheduled','Not Scheduled', 'VIP Seminar Scheduled')]) {
  	  if(center_map.get(l.center__c)!=null) {  	  
	  	  center_map.get(l.center__c).di_leads++;
	  	  total_cs.di_leads++;	  	  
	  	  if(l.pre_screen__c=='PO Box') {
	  	    center_map.get(l.center__c).di_gy++;
	  	    total_cs.di_gy++;
	  	  }
	  	  if(l.consult_Inventory__r.size()>0) {
	  	    center_map.get(l.center__c).di_consults_booked++;
	  	    total_cs.DI_consults_booked++;
	  	    if(l.pre_screen__c=='PO Box') {
	  	      center_map.get(l.center__c).di_consults_gy++;
	  	      total_cs.di_consults_gy++;
	  	    }
	  	  }  	
  	  }
  	}
  	
  	 //work through revived lead - leads created prior to the start date that were scheduled during the report period
  	for(Consult_Inventory__c c : [Select c.scheduled_lead__r.name, c.scheduled_lead__r.Pre_Screen__c, c.scheduled_lead__r.createddate, 
  	  c.scheduled_lead__c, c.scheduled_time__c, c.consult_room__r.center_information__c From Consult_Inventory__c c where 
  	  c.scheduled_lead__c != null and c.scheduled_time__c >= :sdate_time and c.scheduled_time__c <= :edate_time and 
  	  c.scheduled_lead__r.createddate < :sdate_time and c.active__c = true and c.consult_room__r.room_type__c != 'Unconfirmed']) {
  	  if(center_map.get(c.consult_room__r.center_information__c)!=null) {
	  	  center_map.get(c.consult_room__r.center_information__c).revived_leads++;
	  	  total_cs.revived_leads++;
	  	  if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	  	    center_map.get(c.consult_room__r.center_information__c).revived_gy++;
	  	    total_cs.revived_gy++;  	
	  	  }
  	  }
  	}  
  	
    //work through report interval
    for(Consult_Inventory__c c : [Select (Select Action__c From Apt_Histories__r where action__c = 'Cancel'),c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, 
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name, 
 	    c.scheduled_lead__r.pre_screen__c,c.arrival_time__c,c.scheduled_account__r.pre_screen__c
 	    From Consult_Inventory__c c where 
 	    c.apt_date__c>= :sdate and c.apt_date__c <= :edate and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) {
        if(c.scheduled_lead__c!=null || c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults++;
          total_cs.final_scheduled_consults++;
          if(c.scheduled_lead__c!=null) {
        		if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
        			center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
        	    total_cs.final_scheduled_consults_gy++;
        		}
          }
          else if(c.scheduled_account__c!=null) {
        		if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
        		  center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
        		  total_cs.final_scheduled_consults_gy++;
        		}        		 
        	}
          center_map.get(c.consult_room__r.center_information__c).initially_scheduled_consults++;
          total_cs.initially_scheduled_consults++;
        }       
        if(c.apt_histories__r.size()>0) {
        	center_map.get(c.consult_room__r.center_information__c).initially_scheduled_consults += c.apt_histories__r.size();
        	total_cs.initially_scheduled_consults += c.apt_histories__r.size();
        }
        //did they show?
        if(c.arrival_time__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).consults_showed++;
        	total_cs.consults_showed++;
        	if(c.scheduled_lead__c!=null) {
        		if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
        	    center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
        	    total_cs.consults_showed_gy++;
        		}
        	}
        	else if(c.scheduled_account__c!=null) {
        		if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
        		  center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
        		  total_cs.consults_showed_gy++;
        		}        		 
        	}
        }
 	    }
 	  }
 	  
 	  //work through report interval
    for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, 
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name, 
 	    c.scheduled_lead__r.pre_screen__c,c.arrival_time__c,c.scheduled_account__r.pre_screen__c
 	    From Consult_Inventory__c c where 
 	    c.apt_date__c>= :sdate and c.apt_date__c <= :edate and active__c=true and c.consult_room__r.room_type__c in ('Unconfirmed')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) {
	 	    if(c.scheduled_lead__c!=null || c.scheduled_account__c!=null) {
	 	      center_map.get(c.consult_room__r.center_information__c).initially_scheduled_consults++;
	        total_cs.initially_scheduled_consults++;
	 	    }
		    //did they show?
		    if(c.arrival_time__c!=null) {
		    	center_map.get(c.consult_room__r.center_information__c).consults_showed++;
		    	center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults++;
		    	total_cs.consults_showed++;
		    	total_cs.final_scheduled_consults++;
		    	if(c.scheduled_lead__c!=null) {
		    		if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
		    	    center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
		    	    total_cs.consults_showed_gy++;
		    	    center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
		    	    total_cs.final_scheduled_consults_gy++;
		    		}
		    	}
		    	else if(c.scheduled_account__c!=null) {
		    		if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
		    		  center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
		    		  total_cs.consults_showed_gy++;
		    		  center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
		    	    total_cs.final_scheduled_consults_gy++;
		    		}        		 
		    	}
		    }
 	    }
 	  }
      	
 	  //current Week
 	  Date start_week = sdate.toStartOfWeek();
 	  Date end_week = start_week.addDays(6);
 	  System.debug('Current Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults++;
        	total_cs.available_consults++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults++;
          total_cs.scheduled_consults++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_gy++;
	    	    total_cs.scheduled_consults_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults++;
          total_cs.scheduled_consults++;  
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_gy++;
	    	    total_cs.scheduled_consults_gy++;
          }        
        }
 	    }
 	  }
  	 
  	start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('Next Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults_next_week++;
        	total_cs.available_consults_next_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week++;
          total_cs.scheduled_consults_next_week++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week_gy++;
	    	    total_cs.scheduled_consults_next_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week++;
          total_cs.scheduled_consults_next_week++;
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week_gy++;
	    	    total_cs.scheduled_consults_next_week_gy++;
          }        
        }
 	    }        
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('2nd Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults_two_week++;
        	total_cs.available_consults_two_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week++;
          total_cs.scheduled_consults_two_week++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week_gy++;
	    	    total_cs.scheduled_consults_two_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week++;
          total_cs.scheduled_consults_two_week++;
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week_gy++;
	    	    total_cs.scheduled_consults_two_week_gy++;
          }        
        }
 	    }        
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('3rd Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults_three_week++;
        	total_cs.available_consults_three_week++;
        }     
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week++;
          total_cs.scheduled_consults_three_week++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week_gy++;
	    	    total_cs.scheduled_consults_three_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week++;
          total_cs.scheduled_consults_three_week++;
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week_gy++;
	    	    total_cs.scheduled_consults_three_week_gy++;
          }        
        }
 	    }
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('4th Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') {
        	center_map.get(c.consult_room__r.center_information__c).available_consults_four_week++;
        	total_cs.available_consults_four_week++;
        }  
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week++;
          total_cs.scheduled_consults_four_week++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week_gy++;
	    	    total_cs.scheduled_consults_four_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week++;
          total_cs.scheduled_consults_four_week++;
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week_gy++;
	    	    total_cs.scheduled_consults_four_week_gy++;
          }        
        }      
 	    }
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('5th Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') {
        	center_map.get(c.consult_room__r.center_information__c).available_consults_five_week++;
        	total_cs.available_consults_five_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week++;
          total_cs.scheduled_consults_five_week++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week_gy++;
	    	    total_cs.scheduled_consults_five_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week++;
          total_cs.scheduled_consults_five_week++;
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week_gy++;
	    	    total_cs.scheduled_consults_five_week_gy++;
          }        
        }    
 	    }
 	  } 
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('6th Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') {
        	center_map.get(c.consult_room__r.center_information__c).available_consults_six_week++;
        	total_cs.available_consults_six_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week++;
          total_cs.scheduled_consults_six_week++;
          if(c.scheduled_lead__r.pre_screen__c=='PO Box') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week_gy++;
	    	    total_cs.scheduled_consults_six_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week++;
          total_cs.scheduled_consults_six_week++;
          if(c.scheduled_account__r.pre_screen__c == 'PO Box') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week_gy++;
	    	    total_cs.scheduled_consults_six_week_gy++;
          }        
        }        
 	    }
 	  } 
 	   	  
 	  for(Opportunity o : [select o.account.center_location__c from opportunity o where o.CreatedDate >= :sdate_time and  
 	    o.CreatedDate < :edate_time and o.StageName in ('Scheduled','Rescheduled','Completed','Paid In Full','Scheduled for Satellite','Completed for Satellite','Paid in Full Satellite') and (o.Completed_Stage__c = null or o.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))	and o.account.Consult_Result__c in ('Prostho Exam Scheduled','Prostho Exam Scheduled Call Back')]) {
 	  	String center_id = center_translation.get(o.account.center_location__c);
 	  	if(center_map.get(center_id)!=null) { 
 	  	  center_map.get(center_id).starts++; 	  	  
 	  	  total_cs.starts++;
 	  	}
 	  }
 	  
 	  for(Opportunity o : [select o.account.center_location__c from opportunity o where o.CreatedDate = this_month and 
 	    o.StageName in ('Scheduled','Rescheduled','Completed','Paid In Full','Scheduled for Satellite','Completed for Satellite','Paid in Full Satellite') and (o.Completed_Stage__c = null or o.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))	and o.account.Consult_Result__c in ('Prostho Exam Scheduled','Prostho Exam Scheduled Call Back')]) {
 	  	String center_id = center_translation.get(o.account.center_location__c);
 	  	if(center_map.get(center_id)!=null) { 
 	  	  center_map.get(center_id).starts_mtd++;
 	  	  total_cs.starts_mtd++;
 	  	}
 	  } 	  
 	  
 	  //calculate sales target
 	  /*turned off at the request of Kathrynn (via Scott) 8/14/2012
    for (AggregateResult results : database.query('Select opportunity__r.account.center__c,sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_month group by opportunity__r.account.center__c')) {
    	if(center_map.get((String)results.get('center__c'))!=null) {
    	  center_map.get((String)results.get('center__c')).net_collections += (Decimal)results.get('total_payments');
    	  total_cs.net_collections += (Decimal)results.get('total_payments');
    	}
    }    
    for (AggregateResult results : database.query('Select opportunity__r.account.center__c,sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Refund\' and payment_date__c = this_month group by opportunity__r.account.center__c')) {
    	if(center_map.get((String)results.get('center__c'))!=null) {
    	  center_map.get((String)results.get('center__c')).net_collections = center_map.get((String)results.get('opportunity__r.account.center__c')).net_collections - (Decimal)results.get('total_payments');
    	  total_cs.net_collections = center_map.get((String)results.get('opportunity__r.account.center__c')).net_collections - (Decimal)results.get('total_payments');
    	}
    }*/
    
    //grab the first available apt for r/b (any)
    for(AggregateResult results : database.query('select consult_room__r.center_information__c,min(apt_date__c) first_aval from consult_inventory__c where pre_screen_type__c = \'Any\' and active__c = true and apt_date__c > today and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.room_type__c in (\'Normal\',\'OverFlow\') group by consult_room__r.center_information__c')) {
    	if(center_map.get((String)results.get('center_information__c'))!=null) 
    		center_map.get((String)results.get('center_information__c')).first_rb_apt = (Date)results.get('first_aval');
    }    
  	
  	for(Center_Information__c ci : alpha_center) {  		
  		all_centers.add(center_map.get(ci.id)); 
  	} 
  	all_centers.add(total_cs);
  	return all_centers;
  }
  
  public Center_Stats[] getcenter_numbers() {
  	if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.apt_date__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.apt_date__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),23,59,59);
  	System.debug('Sdate Time : ' + sdate_time + ' End Date Time : ' + edate_time + ' Sdate : ' + sdate + ' Edate : ' + edate);
  	error_messages = '';
  	if(sdate > edate) {
  	  error_messages = 'Starting Date must be less than or equal to ending date.<br />Please adjust and try again';
      return null;
  	}
  	List<Center_Stats> all_centers = new List<Center_Stats> {};
  	//build a map of center_stats
  	Map<Id,Center_Stats> center_map = new Map<Id,Center_Stats> {};
  	//where name not in ('Unknown')
  	List<Center_Information__c> alpha_center = [select name,id,(Select Budgeted_Consults__c,Sales_Goal__c From Center_Budgets__r where fiscal_year__c = :sdate.year() and fiscal_month__c = :sdate.month()) from Center_Information__c where name not in ('Chicago Deerfield/Northbrook','Unknown') order by name];
  	Map<String,ID> center_translation = new Map<String,ID> {};
  	for(Center_Information__c ci : alpha_center) {
  		Center_Stats cs = new Center_Stats(ci);
  		center_map.put(ci.id,cs);
  		center_translation.put(ci.name,ci.id);
  		for(Center_Budget__c cb : ci.center_budgets__r) {
  			center_map.get(ci.id).sales_goal = cb.sales_goal__c;
  			center_map.get(ci.id).budgeted_consults = cb.budgeted_consults__c;
  		}
  	} 
  	Center_Information__c total_ci = new Center_Information__c(name = 'Totals');
  	total_cs = new Center_Stats(total_ci);
  	//work through all the leads for this time period and store relevant stats
  	for(Lead l : [Select l.Pre_Screen_Status__c, l.Inbound_Call__c, l.Center__c, 
  	  (Select Scheduled_Time__c, Active__c From Consult_Inventory__r where active__c = true) From Lead l where 
  	    createddate >= :sdate_time and createddate <= :edate_time and l.Inbound_Call__c = 'Dental Inquiry' and 
  	    Call_Result__c in ('Consultation Scheduled','Not Scheduled', 'VIP Seminar Scheduled')]) {
  	  if(center_map.get(l.center__c)!=null){  	  
	  	  center_map.get(l.center__c).di_leads++;
	  	  total_cs.di_leads++;
	  	  if(l.pre_screen_status__c=='Green' || l.pre_screen_status__c=='Yellow') {
	  	    center_map.get(l.center__c).di_gy++;
	  	    total_cs.di_gy++;
	  	  }
	  	  if(l.consult_Inventory__r.size()>0) {
	  	    center_map.get(l.center__c).di_consults_booked++;
	  	    total_cs.DI_consults_booked++;
	  	    if(l.pre_screen_status__c=='Green' || l.pre_screen_status__c=='Yellow') {
	  	      center_map.get(l.center__c).di_consults_gy++;
	  	      total_cs.di_consults_gy++;
	  	    }
	  	  }  	
  	  }
  	}
  	
  	 //work through revived lead - leads created prior to the start date that were scheduled during the report period
  	for(Consult_Inventory__c c : [Select c.scheduled_lead__r.name, c.scheduled_lead__r.Pre_Screen_Status__c, c.scheduled_lead__r.createddate, 
  	  c.scheduled_lead__c, c.scheduled_time__c, c.consult_room__r.center_information__c From Consult_Inventory__c c where 
  	  c.scheduled_lead__c != null and c.scheduled_time__c >= :sdate_time and c.scheduled_time__c <= :edate_time and 
  	  c.scheduled_lead__r.createddate < :sdate_time and c.active__c = true and c.consult_room__r.room_type__c != 'Unconfirmed']) {
  	  if(center_map.get(c.consult_room__r.center_information__c)!=null) {
	  	  center_map.get(c.consult_room__r.center_information__c).revived_leads++;
	  	  total_cs.revived_leads++;
	  	  if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	  	    center_map.get(c.consult_room__r.center_information__c).revived_gy++;
	  	    total_cs.revived_gy++;  	
	  	  }
  	  }
  	}  
  	
    //work through report interval
    for(Consult_Inventory__c c : [Select (Select Action__c From Apt_Histories__r where action__c = 'Cancel'),c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, 
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name, 
 	    c.scheduled_lead__r.pre_screen_status__c,c.arrival_time__c,c.scheduled_account__r.pre_screen__c
 	    From Consult_Inventory__c c where 
 	    c.apt_date__c>= :sdate and c.apt_date__c <= :edate and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) {
        if(c.scheduled_lead__c!=null || c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults++;
          total_cs.final_scheduled_consults++;
          if(c.scheduled_lead__c!=null) {
        		if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
        			center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
        	    total_cs.final_scheduled_consults_gy++;
        		}
          }
          else if(c.scheduled_account__c!=null) {
        		if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
        		  center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
        		  total_cs.final_scheduled_consults_gy++;
        		}        		 
        	}
          center_map.get(c.consult_room__r.center_information__c).initially_scheduled_consults++;
          total_cs.initially_scheduled_consults++;
        }       
        if(c.apt_histories__r.size()>0) {
        	center_map.get(c.consult_room__r.center_information__c).initially_scheduled_consults += c.apt_histories__r.size();
        	total_cs.initially_scheduled_consults += c.apt_histories__r.size();
        }
        //did they show?
        if(c.arrival_time__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).consults_showed++;
        	total_cs.consults_showed++;
        	if(c.scheduled_lead__c!=null) {
        		if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
        	    center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
        	    total_cs.consults_showed_gy++;
        		}
        	}
        	else if(c.scheduled_account__c!=null) {
        		if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
        		  center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
        		  total_cs.consults_showed_gy++;
        		}        		 
        	}
        }
 	    }
 	  }
 	  
 	  //work through report interval
    for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, 
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name, 
 	    c.scheduled_lead__r.pre_screen_status__c,c.arrival_time__c,c.scheduled_account__r.pre_screen__c
 	    From Consult_Inventory__c c where 
 	    c.apt_date__c>= :sdate and c.apt_date__c <= :edate and active__c=true and c.consult_room__r.room_type__c in ('Unconfirmed')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) {
	 	    if(c.scheduled_lead__c!=null || c.scheduled_account__c!=null) {
	 	      center_map.get(c.consult_room__r.center_information__c).initially_scheduled_consults++;
	        total_cs.initially_scheduled_consults++;
	 	    }
		    //did they show?
		    if(c.arrival_time__c!=null) {
		    	center_map.get(c.consult_room__r.center_information__c).consults_showed++;
		    	center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults++;
		    	total_cs.consults_showed++;
		    	total_cs.final_scheduled_consults++;
		    	if(c.scheduled_lead__c!=null) {
		    		if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
		    	    center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
		    	    total_cs.consults_showed_gy++;
		    	    center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
		    	    total_cs.final_scheduled_consults_gy++;
		    		}
		    	}
		    	else if(c.scheduled_account__c!=null) {
		    		if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
		    		  center_map.get(c.consult_room__r.center_information__c).consults_showed_gy++;
		    		  total_cs.consults_showed_gy++;
		    		  center_map.get(c.consult_room__r.center_information__c).final_scheduled_consults_gy++;
		    	    total_cs.final_scheduled_consults_gy++;
		    		}        		 
		    	}
		    }
 	    }
 	  }
      	
 	  //current Week
 	  Date start_week = sdate.toStartOfWeek();
 	  Date end_week = start_week.addDays(6);
 	  System.debug('Current Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults++;
        	total_cs.available_consults++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults++;
          total_cs.scheduled_consults++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_gy++;
	    	    total_cs.scheduled_consults_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults++;
          total_cs.scheduled_consults++;  
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_gy++;
	    	    total_cs.scheduled_consults_gy++;
          }        
        }
 	    }
 	  }
  	 
  	start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('Next Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults_next_week++;
        	total_cs.available_consults_next_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week++;
          total_cs.scheduled_consults_next_week++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week_gy++;
	    	    total_cs.scheduled_consults_next_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week++;
          total_cs.scheduled_consults_next_week++;
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_next_week_gy++;
	    	    total_cs.scheduled_consults_next_week_gy++;
          }        
        }
 	    }        
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('2nd Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults_two_week++;
        	total_cs.available_consults_two_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week++;
          total_cs.scheduled_consults_two_week++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week_gy++;
	    	    total_cs.scheduled_consults_two_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week++;
          total_cs.scheduled_consults_two_week++;
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_two_week_gy++;
	    	    total_cs.scheduled_consults_two_week_gy++;
          }        
        }
 	    }        
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('3rd Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') { 
        	center_map.get(c.consult_room__r.center_information__c).available_consults_three_week++;
        	total_cs.available_consults_three_week++;
        }     
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week++;
          total_cs.scheduled_consults_three_week++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week_gy++;
	    	    total_cs.scheduled_consults_three_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week++;
          total_cs.scheduled_consults_three_week++;
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_three_week_gy++;
	    	    total_cs.scheduled_consults_three_week_gy++;
          }        
        }
 	    }
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('4th Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') {
        	center_map.get(c.consult_room__r.center_information__c).available_consults_four_week++;
        	total_cs.available_consults_four_week++;
        }  
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week++;
          total_cs.scheduled_consults_four_week++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week_gy++;
	    	    total_cs.scheduled_consults_four_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week++;
          total_cs.scheduled_consults_four_week++;
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_four_week_gy++;
	    	    total_cs.scheduled_consults_four_week_gy++;
          }        
        }      
 	    }
 	  } 	
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('5th Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') {
        	center_map.get(c.consult_room__r.center_information__c).available_consults_five_week++;
        	total_cs.available_consults_five_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week++;
          total_cs.scheduled_consults_five_week++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week_gy++;
	    	    total_cs.scheduled_consults_five_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week++;
          total_cs.scheduled_consults_five_week++;
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_five_week_gy++;
	    	    total_cs.scheduled_consults_five_week_gy++;
          }        
        }    
 	    }
 	  } 
 	  
 	  start_week = start_week.addDays(7);
 	  end_week = end_week.addDays(7);
 	  System.debug('6th Week : ' + start_week + ' - ' + end_week);
 	  for(Consult_Inventory__c c : [Select c.Active__c, c.consult_room__r.room_type__c, c.scheduled_lead__c, c.scheduled_lead__r.pre_screen_status__c, c.scheduled_account__r.pre_screen__c,
 	    c.scheduled_account__c, c.apt_date__c,c.consult_room__r.center_information__c From Consult_Inventory__c c where 
 	    c.apt_date__c>= :start_week and c.apt_date__c <= :end_week and active__c=true and c.consult_room__r.room_type__c in ('Normal','Overflow')]) {
 	    if(center_map.get(c.consult_room__r.center_information__c)!=null) { 
        if(c.Consult_Room__r.room_type__c == 'Normal') {
        	center_map.get(c.consult_room__r.center_information__c).available_consults_six_week++;
        	total_cs.available_consults_six_week++;
        }
        if(c.scheduled_lead__c!=null) {
        	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week++;
          total_cs.scheduled_consults_six_week++;
          if(c.scheduled_lead__r.pre_screen_status__c=='Green' || c.scheduled_lead__r.pre_screen_status__c=='Yellow') {
	    	    center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week_gy++;
	    	    total_cs.scheduled_consults_six_week_gy++;
	    		}
        } 
        else if(c.scheduled_account__c!=null) {
          center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week++;
          total_cs.scheduled_consults_six_week++;
          if(c.scheduled_account__r.pre_screen__c == 'Green' || c.scheduled_account__r.pre_screen__c == 'Yellow') {
          	center_map.get(c.consult_room__r.center_information__c).scheduled_consults_six_week_gy++;
	    	    total_cs.scheduled_consults_six_week_gy++;
          }        
        }        
 	    }
 	  } 
 	   	  
 	  for(Opportunity o : [select o.account.center_location__c from opportunity o where o.CreatedDate >= :sdate_time and  
 	    o.CreatedDate < :edate_time and o.StageName in ('Scheduled','Rescheduled','Completed','Paid In Full','Scheduled for Satellite','Completed for Satellite','Paid in Full Satellite') and (o.Completed_Stage__c = null or o.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))	and o.account.Consult_Result__c in ('Prostho Exam Scheduled','Prostho Exam Scheduled Call Back')]) {
 	  	String center_id = center_translation.get(o.account.center_location__c);
 	  	if(center_map.get(center_id)!=null) { 
 	  	  center_map.get(center_id).starts++; 	  	  
 	  	  total_cs.starts++;
 	  	}
 	  }
 	  
 	  for(Opportunity o : [select o.account.center_location__c from opportunity o where o.CreatedDate = this_month and 
 	    o.StageName in ('Scheduled','Rescheduled','Completed','Paid In Full','Scheduled for Satellite','Completed for Satellite','Paid in Full Satellite') and (o.Completed_Stage__c = null or o.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))	and o.account.Consult_Result__c in ('Prostho Exam Scheduled','Prostho Exam Scheduled Call Back')]) {
 	  	String center_id = center_translation.get(o.account.center_location__c);
 	  	if(center_map.get(center_id)!=null) { 
 	  	  center_map.get(center_id).starts_mtd++;
 	  	  total_cs.starts_mtd++;
 	  	}
 	  } 	  
 	  
 	  //calculate sales target
 	  /*turned off at the request of Kathrynn (via Scott) 8/14/2012
    for (AggregateResult results : database.query('Select opportunity__r.account.center__c,sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_month group by opportunity__r.account.center__c')) {
    	if(center_map.get((String)results.get('center__c'))!=null) {
    	  center_map.get((String)results.get('center__c')).net_collections += (Decimal)results.get('total_payments');
    	  total_cs.net_collections += (Decimal)results.get('total_payments');
    	}
    }    
    for (AggregateResult results : database.query('Select opportunity__r.account.center__c,sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Refund\' and payment_date__c = this_month group by opportunity__r.account.center__c')) {
    	if(center_map.get((String)results.get('center__c'))!=null) {
    	  center_map.get((String)results.get('center__c')).net_collections = center_map.get((String)results.get('opportunity__r.account.center__c')).net_collections - (Decimal)results.get('total_payments');
    	  total_cs.net_collections = center_map.get((String)results.get('opportunity__r.account.center__c')).net_collections - (Decimal)results.get('total_payments');
    	}
    }*/
    
    //grab the first available apt for r/b (any)
    for(AggregateResult results : database.query('select consult_room__r.center_information__c,min(apt_date__c) first_aval from consult_inventory__c where pre_screen_type__c = \'Any\' and active__c = true and apt_date__c > today and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.room_type__c in (\'Normal\',\'OverFlow\') group by consult_room__r.center_information__c')) {
    	if(center_map.get((String)results.get('center_information__c'))!=null) 
    		center_map.get((String)results.get('center_information__c')).first_rb_apt = (Date)results.get('first_aval');
    }    
  	
  	for(Center_Information__c ci : alpha_center) {  		
  		all_centers.add(center_map.get(ci.id)); 
  	} 
  	all_centers.add(total_cs);
  	return all_centers;
  }
  
  public Center_Stats[] getcenter_numbers_monthly() {
  	if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = date.newInstance(Integer.valueof(report_year), integer.valueof(report_month), 1);
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)   		
  	  edate = date.newInstance(sdate.addmonths(1).year(), sdate.addMonths(1).month(), 1);  	
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),0,0,0);
  	System.debug('Sdate Time : ' + sdate_time + ' End Date Time : ' + edate_time + ' Sdate : ' + sdate + ' Edate : ' + edate);
  	error_messages = '';
  	List<Center_Stats> all_centers = new List<Center_Stats> {};
  	//build a map of center_stats
  	Map<Id,Center_Stats> center_map = new Map<Id,Center_Stats> {};
  	//where name not in ('Unknown')
  	List<Center_Information__c> alpha_center = [select name,id,(Select Budgeted_Consults__c,Sales_Goal__c From 
  	  Center_Budgets__r where fiscal_year__c = :sdate.year() and fiscal_month__c = :sdate.month()) from Center_Information__c where name not in ('Chicago Deerfield/Northbrook','Unknown') order by name];
  	Map<String,ID> center_translation = new Map<String,ID> {};
  	for(Center_Information__c ci : alpha_center) {
  		Center_Stats cs = new Center_Stats(ci);
  		center_map.put(ci.id,cs);
  		center_translation.put(ci.name,ci.id);
  		for(Center_Budget__c cb : ci.center_budgets__r) {
  			center_map.get(ci.id).sales_goal = cb.sales_goal__c;
  			center_map.get(ci.id).budgeted_consults = cb.budgeted_consults__c;
  		}
  	}   	 
  	Center_Information__c total_ci = new Center_Information__c(name = 'Totals');
  	total_cs = new Center_Stats(total_ci);
  	
  	//revised process to work through leads.  I'm going with more queries this route but fewer script lines run due to 
  	//a different sales force limitation
  	//booked leads will be handled in a different query
  	for(AggregateResult ar : [Select l.Center__c,l.Pre_Screen_Status__c,count(id) num_leads From Lead l where 
      createddate >= :sdate_time and createddate < :edate_time and l.Inbound_Call__c = 'Dental Inquiry' and 
  	    Call_Result__c in ('Consultation Scheduled','Not Scheduled', 'VIP Seminar Scheduled') 
      group by l.Center__c,l.Pre_Screen_Status__c]) {
      if(center_map.get((string)ar.get('center__c'))!=null) {  
      	center_map.get((string)ar.get('center__c')).di_leads += (integer)ar.get('num_leads');
	  	  total_cs.di_leads += (integer)ar.get('num_leads');
	  	  if(ar.get('pre_screen_status__c')=='Green' || ar.get('pre_screen_status__c')=='Yellow') {
	  	    center_map.get((string)ar.get('center__c')).di_gy += (integer)ar.get('num_leads');
	  	    total_cs.di_gy += (integer)ar.get('num_leads');
	  	  }
      }
    }
    
    //query to handle booked leads
    for(AggregateResult ar : [Select c.consult_room__r.center_information__c,c.scheduled_lead__r.Pre_Screen_Status__c,count(c.scheduled_lead__c) num_leads
      from Consult_Inventory__c c where c.scheduled_lead__r.createddate >= :sdate_time and 
        c.scheduled_lead__r.createddate < :edate_time and c.active__c = true 
      group by c.consult_room__r.center_information__c,  c.scheduled_lead__r.Pre_Screen_Status__c]) {
      if(center_map.get((string)ar.get('center_information__c'))!=null) {  
      	center_map.get((string)ar.get('center_information__c')).di_consults_booked += (integer)ar.get('num_leads');
	  	  total_cs.di_consults_booked += (integer)ar.get('num_leads');
	  	  if(ar.get('pre_screen_status__c')=='Green' || ar.get('pre_screen_status__c')=='Yellow') {
	  	    center_map.get((string)ar.get('center_information__c')).di_consults_gy += (integer)ar.get('num_leads');
	  	    total_cs.di_consults_gy += (integer)ar.get('num_leads');
	  	  }
      }
    }      	
  	
  	//revised revived leads query - using group by to reduce load here
  	for(AggregateResult ar : [Select c.scheduled_lead__r.Pre_Screen_Status__c, c.consult_room__r.center_information__c,
      count(c.scheduled_lead__c) num_leads From Consult_Inventory__c c where c.scheduled_lead__c != null and 
      c.scheduled_time__c >= :sdate_time and c.scheduled_time__c < :edate_time and 
      c.scheduled_lead__r.createddate < :sdate_time and c.active__c = true and c.consult_room__r.room_type__c != 'Unconfirmed'
      group by c.consult_room__r.center_information__c,c.scheduled_lead__r.Pre_Screen_Status__c]) {
      if(center_map.get((string)ar.get('center_information__c'))!=null) {
	  	  center_map.get((string)ar.get('center_information__c')).revived_leads += (integer)ar.get('num_leads');
	  	  total_cs.revived_leads += (integer)ar.get('num_leads');
	  	  if(ar.get('pre_screen_status__c')=='Green' || ar.get('pre_screen_status__c')=='Yellow') {
	  	    center_map.get((string)ar.get('center_information__c')).revived_gy += (integer)ar.get('num_leads');
	  	    total_cs.revived_gy += (integer)ar.get('num_leads');  	
	  	  }
  	  }  	
    }
  	  	
  	//work through report interval - breaking this out into five queries.
  	//query 1 - grouping by leads
  	for(AggregateResult ar : [Select c.consult_room__r.center_information__c, c.scheduled_lead__r.pre_screen_status__c,
      c.consult_room__r.room_type__c,count(c.scheduled_lead__c) num_leads From Consult_Inventory__c c 
      where c.apt_date__c>= :sdate and c.apt_date__c < :edate and active__c=true and  
        c.consult_room__r.room_type__c in ('Normal','Overflow','Unconfirmed') and c.scheduled_lead__c != null
      group by c.consult_room__r.center_information__c, c.scheduled_lead__r.pre_screen_status__c,c.consult_room__r.room_type__c]) {
     	if(center_map.get((string)ar.get('center_information__c'))!=null) {
     		if((string)ar.get('room_type__c')!='Unconfirmed') {
	     		center_map.get((string)ar.get('center_information__c')).final_scheduled_consults += (integer)ar.get('num_leads');
	        total_cs.final_scheduled_consults += (integer)ar.get('num_leads');
	        center_map.get((string)ar.get('center_information__c')).scheduled_consults += (integer)ar.get('num_leads');
          total_cs.scheduled_consults += (integer)ar.get('num_leads');
	        if(ar.get('pre_screen_status__c')=='Green' || ar.get('pre_screen_status__c')=='Yellow') {
	        	center_map.get((string)ar.get('center_information__c')).final_scheduled_consults_gy += (integer)ar.get('num_leads');
	        	total_cs.final_scheduled_consults_gy += (integer)ar.get('num_leads');
	        	center_map.get((string)ar.get('center_information__c')).scheduled_consults_gy += (integer)ar.get('num_leads');
          	total_cs.scheduled_consults_gy += (integer)ar.get('num_leads');
	        }
     		}
        center_map.get((string)ar.get('center_information__c')).initially_scheduled_consults += (integer)ar.get('num_leads');
        total_cs.initially_scheduled_consults += (integer)ar.get('num_leads');
     	}
    } 
    
    //query 2 - grouping by the account records 
    for(AggregateResult ar : [Select c.consult_room__r.center_information__c, c.scheduled_account__r.pre_screen__c,
      c.consult_room__r.room_type__c,count(c.scheduled_lead__c) num_leads From Consult_Inventory__c c 
    where c.apt_date__c>= :sdate and c.apt_date__c < :edate and active__c=true and 
      c.consult_room__r.room_type__c in ('Normal','Overflow','Unconfirmed') and c.scheduled_account__c != null
    group by  c.consult_room__r.center_information__c, c.scheduled_account__r.pre_screen__c,c.consult_room__r.room_type__c]) {
    	if(center_map.get((string)ar.get('center_information__c'))!=null) {
    		if((string)ar.get('room_type__c')!='Unconfirmed') {
	     		center_map.get((string)ar.get('center_information__c')).final_scheduled_consults += (integer)ar.get('num_leads');
	        total_cs.final_scheduled_consults += (integer)ar.get('num_leads');
	        center_map.get((string)ar.get('center_information__c')).scheduled_consults += (integer)ar.get('num_leads');
          total_cs.scheduled_consults += (integer)ar.get('num_leads');
	        if(ar.get('pre_screen__c')=='Green' || ar.get('pre_screen__c')=='Yellow') {
	        	center_map.get((string)ar.get('center_information__c')).final_scheduled_consults_gy += (integer)ar.get('num_leads');
	        	total_cs.final_scheduled_consults_gy += (integer)ar.get('num_leads');
	        	center_map.get((string)ar.get('center_information__c')).scheduled_consults_gy += (integer)ar.get('num_leads');
          	total_cs.scheduled_consults_gy += (integer)ar.get('num_leads');
	        }
    		}
        center_map.get((string)ar.get('center_information__c')).initially_scheduled_consults += (integer)ar.get('num_leads');
        total_cs.initially_scheduled_consults += (integer)ar.get('num_leads');
     	}
    }
    
    //query 3 - looking at apt history to find the cancels
    for(AggregateResult ar : [select a.consult_inventory__r.consult_room__r.center_information__c, count(a.id) num_cancels
      from apt_history__c a where a.action__c = 'Cancel' and a.consult_inventory__r.apt_date__c>= :sdate and     
        a.consult_inventory__r.apt_date__c < :edate and   a.consult_inventory__r.active__c=true and   
        a.consult_inventory__r.consult_room__r.room_type__c in ('Normal','Overflow')
      group by   a.consult_inventory__r.consult_room__r.center_information__c]) {
      if(center_map.get((string)ar.get('center_information__c'))!=null) {
      	center_map.get((string)ar.get('center_information__c')).initially_scheduled_consults += (integer)ar.get('num_cancels');
        total_cs.initially_scheduled_consults += (integer)ar.get('num_cancels');
      }
    }
    
    
    //query 4 - grabbing a count of the arrival times (lead)
    for(AggregateResult ar : [Select c.consult_room__r.center_information__c, c.scheduled_lead__r.pre_screen_status__c,
       c.consult_room__r.room_type__c, count(c.scheduled_lead__c) num_leads From Consult_Inventory__c c 
    where c.apt_date__c>= :sdate and c.apt_date__c < :edate and active__c=true and 
      c.consult_room__r.room_type__c in ('Normal','Overflow','Unconfirmed') and c.scheduled_lead__c != null and c.arrival_time__c != null
    group by c.consult_room__r.center_information__c, c.scheduled_lead__r.pre_screen_status__c,  c.consult_room__r.room_type__c]) {
    	if(center_map.get((string)ar.get('center_information__c'))!=null) {
     		center_map.get((string)ar.get('center_information__c')).consults_showed += (integer)ar.get('num_leads');
        total_cs.consults_showed += (integer)ar.get('num_leads');
        if((string)ar.get('room_type__c')=='Unconfirmed') {
        	center_map.get((string)ar.get('center_information__c')).final_scheduled_consults += (integer)ar.get('num_leads');
	        total_cs.final_scheduled_consults += (integer)ar.get('num_leads');
        }
        if(ar.get('pre_screen_status__c')=='Green' || ar.get('pre_screen_status__c')=='Yellow') {
        	center_map.get((string)ar.get('center_information__c')).consults_showed_gy += (integer)ar.get('num_leads');
        	total_cs.consults_showed_gy += (integer)ar.get('num_leads');
        	if((string)ar.get('room_type__c')=='Unconfirmed') {
        	  center_map.get((string)ar.get('center_information__c')).final_scheduled_consults_gy += (integer)ar.get('num_leads');
	          total_cs.final_scheduled_consults_gy += (integer)ar.get('num_leads');
        	}
        }
     	}
    }
    
    //System.debug('Running Query 5');
    //query 5 - grabbing a count of the arrival times (account)
    for(AggregateResult ar : [Select c.consult_room__r.center_information__c, c.scheduled_account__r.pre_screen__c,
      c.consult_room__r.room_type__c,count(c.scheduled_account__c) num_leads From Consult_Inventory__c c 
    where c.apt_date__c>= :sdate and c.apt_date__c < :edate and active__c=true and 
      c.consult_room__r.room_type__c in ('Normal','Overflow','Unconfirmed') and c.scheduled_account__c != null and 
      c.arrival_time__c != null
    group by  c.consult_room__r.center_information__c, c.scheduled_account__r.pre_screen__c, c.consult_room__r.room_type__c]) {
    	if(center_map.get((string)ar.get('center_information__c'))!=null) {
     		center_map.get((string)ar.get('center_information__c')).consults_showed += (integer)ar.get('num_leads');
        total_cs.consults_showed += (integer)ar.get('num_leads');
        if((string)ar.get('room_type__c')=='Unconfirmed') {
        	center_map.get((string)ar.get('center_information__c')).final_scheduled_consults += (integer)ar.get('num_leads');
	        total_cs.final_scheduled_consults += (integer)ar.get('num_leads');
        }
        if(ar.get('pre_screen__c')=='Green' || ar.get('pre_screen__c')=='Yellow') {
        	center_map.get((string)ar.get('center_information__c')).consults_showed_gy += (integer)ar.get('num_leads');
        	total_cs.consults_showed_gy += (integer)ar.get('num_leads');
        	if((string)ar.get('room_type__c')=='Unconfirmed') {
        	  center_map.get((string)ar.get('center_information__c')).final_scheduled_consults_gy += (integer)ar.get('num_leads');
	          total_cs.final_scheduled_consults_gy += (integer)ar.get('num_leads');
        	}
        }
     	}
    }   
    
    //query 6 - grabbing a count of the arrival times where the record was merged and a lead or account id no longer exists.
    //pulled this from the system - it was not related to merge from my testing,  but people actually using the delete feature
    //I've pulled the delete button from lead forms,  so hopefully this has been solved going forward.
/*    for(AggregateResult ar : [Select c.consult_room__r.center_information__c, c.scheduled_lead__r.pre_screen_status__c,
       c.consult_room__r.room_type__c, count(c.id) num_leads From Consult_Inventory__c c 
    where c.apt_date__c>= :sdate and c.apt_date__c < :edate and active__c=true and 
      c.consult_room__r.room_type__c in ('Normal','Overflow','Unconfirmed') and c.scheduled_lead__c = null and c.scheduled_account__c = null and c.arrival_time__c != null 
    group by   c.consult_room__r.center_information__c, c.scheduled_lead__r.pre_screen_status__c,  c.consult_room__r.room_type__c]) {
    	if(center_map.get((string)ar.get('center_information__c'))!=null) {
     		center_map.get((string)ar.get('center_information__c')).consults_showed += (integer)ar.get('num_leads');
        total_cs.consults_showed =+ (integer)ar.get('num_leads');
        if((string)ar.get('room_type__c')=='Unconfirmed') {
        	center_map.get((string)ar.get('center_information__c')).final_scheduled_consults += (integer)ar.get('num_leads');
	        total_cs.final_scheduled_consults =+ (integer)ar.get('num_leads');
        }
        if(ar.get('pre_screen_status__c')=='Green' || ar.get('pre_screen_status__c')=='Yellow') {
        	center_map.get((string)ar.get('center_information__c')).consults_showed_gy += (integer)ar.get('num_leads');
        	total_cs.consults_showed_gy += (integer)ar.get('num_leads');
        	if((string)ar.get('room_type__c')=='Unconfirmed') {
        	  center_map.get((string)ar.get('center_information__c')).final_scheduled_consults_gy += (integer)ar.get('num_leads');
	          total_cs.final_scheduled_consults_gy += (integer)ar.get('num_leads');
        	}
        }
     	}
    }*/
    
    //available consults query
    for(AggregateResult ar : [Select c.consult_room__r.center_information__c, count(c.id) num_apts  
      From Consult_Inventory__c c where c.apt_date__c>= :sdate and c.apt_date__c < :edate and active__c = true and 
        c.consult_room__r.room_type__c = 'Normal' 
      group by c.consult_room__r.center_information__c]) {
	  	if(center_map.get((string)ar.get('center_information__c'))!=null) {
	  		center_map.get((string)ar.get('center_information__c')).available_consults += (integer)ar.get('num_apts');
	      total_cs.available_consults += (integer)ar.get('num_apts');
	  	}
    }
    
    //revised - grouped
    for(AggregateResult ar : [select o.account.center_location__c,count(id) num_starts from opportunity o where o.CreatedDate >= :sdate_time and  
 	      o.CreatedDate < :edate_time and o.StageName in ('Scheduled','Rescheduled','Completed','Paid In Full','Scheduled for Satellite','Completed for Satellite','Paid in Full Satellite') and (o.Completed_Stage__c = null or o.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))	
 	      and o.account.Consult_Result__c in ('Prostho Exam Scheduled','Prostho Exam Scheduled Call Back')
 	    group by o.account.center_location__c]) {
 	  	String center_id = center_translation.get((string)ar.get('center_location__c'));
 	  	if(center_map.get(center_id)!=null) { 
 	  	  center_map.get(center_id).starts += (integer)ar.get('num_starts');  	  
 	  	  total_cs.starts += (integer)ar.get('num_starts');
 	  	}
 	  }
      	
  	for(Center_Information__c ci : alpha_center) {  		
  		all_centers.add(center_map.get(ci.id)); 
  	} 
  	all_centers.add(total_cs);
  	return all_centers;
  }  
  
  private static void init() {
		Market__c m = new Market__c(Name = 'Test Market');
		Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center; 
		Schedule_Templates__c test_template = new Schedule_Templates__c(Name = 'Test Any Day Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true, 
		  Saturday__c = true,  Sunday__c = true);
		insert test_template;
		Schedule_Templates__c test_template2 = new Schedule_Templates__c(Name = 'Test Weekend Template', Monday__c = false, Tuesday__c = false, Wednesday__c = false, Thursday__c = false, Friday__c = true, 
		  Saturday__c = true,  Sunday__c = true);
		insert test_template2;
		
		Template_Apt__c test_temp_apt = new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Blue', Ending_Hour__c = '9', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '8', starting_minutes__c = '15');
		insert test_temp_apt;	
	  Template_Apt__c[] test_templates = new Template_Apt__c[] {new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Purple', Ending_Hour__c = '9', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '9', starting_minutes__c = '5'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Brown', Ending_Hour__c = '12', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Any',
		  schedule_template__c = test_template.id, start_hour__c = '11', starting_minutes__c = '10'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Red', Ending_Hour__c = '13', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow Only',
		  schedule_template__c = test_template.id, start_hour__c = '12', starting_minutes__c = '50'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Green', Ending_Hour__c = '15', Ending_Minutes__c = '40', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template.id, start_hour__c = '14', starting_minutes__c = '00')};
		Template_Apt__c[] test_templates2 = new Template_Apt__c[] {new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Grey', Ending_Hour__c = '16', Ending_Minutes__c = '45', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template2.id, start_hour__c = '15', starting_minutes__c = '45'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Yellow', Ending_Hour__c = '17', Ending_Minutes__c = '50', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template2.id, start_hour__c = '16', starting_minutes__c = '50'),
		  new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Orange', Ending_Hour__c = '18', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
		  schedule_template__c = test_template2.id, start_hour__c = '17', starting_minutes__c = '55')}; 
		insert test_templates;
		insert test_templates2;
		Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 40, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id);
		insert test_room;
		Consult_Rooms__c test_room2 = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 40, Name = 'Consult Room 2', Room_Type__c = 'Overflow', Schedule_Template__c = test_template2.id);
		insert test_room2;	
		
		
		Profile p = [select id from Profile where name = 'System Administrator'];		
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US',clinic_calendar__c = test_center.name);
		insert my_test_user;
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c = true);
	  insert test_lead;	  
	  
		
      System.runas(my_test_user) {			  	  
	    Ctrl_Consultschedule my_ext = new ctrl_consultschedule();
	    my_ext.build_room_inventory(test_room,System.today());    	     
	    my_ext.build_room_inventory(test_room2,System.today());
	    List<Consult_Inventory__c> update_lead_list = new List<Consult_Inventory__c>();
	    for(Consult_Inventory__c ci : [select id,scheduled_lead__c from Consult_Inventory__c where apt_date__c >= today and consult_room__c = :test_room.id]) {
	    	ci.scheduled_lead__c = test_lead.id;
	    	update_lead_list.add(ci);
	    }			
	    if(update_lead_list.size()>0)
	      update update_lead_list;            
      }
	}
	
  static testMethod void monthlyTest() {
		init();
  	test.startTest();
  	//rush job - need to get this out to the team to pull some numbers
  	rpt_call_center_dash rpt = new rpt_call_center_dash();
  	//rpt.sholder.apt_date__c = System.today().adddays(-1);
    //rpt.eholder.apt_date__c = System.today();
  	Center_Stats[] cs_all = rpt.getcenter_numbers_monthly();  	
  	test.stopTest();
	}
	
	static testMethod void poTest() {
		init();
  	test.startTest();
  	//rush job - need to get this out to the team to pull some numbers
  	rpt_call_center_dash rpt = new rpt_call_center_dash();
  	//rpt.sholder.apt_date__c = System.today().adddays(-1);
    //rpt.eholder.apt_date__c = System.today();
  	Center_Stats[] cs_all = rpt.getcenter_numbers_pobox();  	
  	test.stopTest();
	}
    
  static testMethod void myTest() {
  	init();
  	test.startTest();
  	//rush job - need to get this out to the team to pull some numbers
  	rpt_call_center_dash rpt = new rpt_call_center_dash();  	
    rpt.getyear_list();
    rpt.getmonth_list();
    rpt.getcsv_altlink_po();
    rpt.getcsv_altlink_month();
    rpt.view_month_dash();
    rpt.getcsv_alt_month_output();
    //rpt.sholder.apt_date__c = System.today().adddays(-1);
    //rpt.eholder.apt_date__c = System.today();
  	Center_Stats[] cs_all = rpt.getcenter_numbers();
  	for(Center_Stats cs : cs_all) {
      cs.getdi_gy_percent();
  		cs.getcslts_gy_percent();
  		cs.getschedule_rate(); 
  		cs.getconsults_booked_rate();
  	 	cs.getshow_gy_rate(); 
  	  cs.getshow_rate();
  		cs.getcomplete_rate();
  		cs.getconsults_booked_next_rate();
  	  cs.getconsults_booked_2_rate();
  	  cs.getconsults_booked_3_rate();
  		cs.getconsults_booked_4_rate();
  		cs.getconsults_booked_5_rate();
  		cs.getconsults_booked_6_rate();
  		cs.getbudgeted_consults_week();
  	  cs.getclose_rate(); 
  	  cs.getgoal_rate();	
  	  cs.getfirst_aval();
  	  cs.getfinal_gy_rate();  
  	}
  	rpt.getcsv_link();
  	rpt.getcsv_altlink();
  	rpt.getcsv_output();
  	rpt.getcsv_altoutput();
  	rpt.getcsv_scheduleoutput();
  	rpt.view_dashboard();
  	rpt.view_utilization();
  	rpt.view_wtl_dash();
  	rpt.getcsv_daterange();
  	test.stopTest();
  }
  
}