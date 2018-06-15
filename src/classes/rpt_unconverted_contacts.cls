public with sharing class rpt_unconverted_contacts {
	public Date sdate {get;set;}
	public Date edate {get;set;}
	public Lead sholder {get; set;}
	public Lead eholder {get; set;}
	public String error_messages {get; set;}
	public String file_header {get; set;}
	public String file_name {get; set;}
    public String user_filter {get; set;}
    public String center_filter {get; set;}
    public String region_filter {get; set;}
	
  public rpt_unconverted_contacts() {
  	sholder = new Lead();
  	eholder = new Lead();
  	sholder.Date_of_Birth__c = Date.newInstance(2012, 8, 1);      
    eholder.Date_of_Birth__c = System.today().addDays(-1);
    Date dtoday = date.today();
    if(apexpages.currentpage().getparameters().get('asuser')!=null) 
      user_filter = apexpages.currentpage().getparameters().get('asuser');
    else
      user_filter = 'na';
    if(apexpages.currentpage().getparameters().get('ascenter')!=null) 
      center_filter = apexpages.currentpage().getparameters().get('ascenter');
    else
      center_filter = 'na';
    if(apexpages.currentpage().getparameters().get('aregion')!=null) 
      region_filter = apexpages.currentpage().getparameters().get('aregion');
    else
      region_filter = 'na';
    if(apexpages.currentpage().getparameters().get('sdate')!=null) {
  	  dtoday = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
    }
    else
  	  sdate = sholder.date_of_birth__c;
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));        	  
    file_name = 'unconverted_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';  
  }	
  
  public List<SelectOption> getRegionList() {
    Schema.DescribeFieldResult RegionList = Center_information__c.Sales_Region__c.getDescribe();
    List<Schema.PicklistEntry> RegionPickVals = RegionList.getPicklistValues();
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('na','All Regions'));
    for(Schema.PicklistEntry Value : RegionPickVals ) {
      options.add(new SelectOption(Value.getValue(),Value.getLabel()));
    }
    return options;
  }
  
  public List<SelectOption> getCenterList() {
  	List<SelectOption> options = new List<SelectOption>();
  	options.add(new SelectOption('na','All Centers'));
    for(Center_Information__c center : [Select c.id,c.name From Center_Information__c c order by c.name]) {
      options.add(new SelectOption(center.id,center.name));
    }
    return options;
  }
  
  public List<SelectOption> getUserList() {
  	List<SelectOption> options = new List<SelectOption>();
  	options.add(new SelectOption('na','All Users'));
    for(User u : [Select u.id,u.name From User u where u.isactive = true order by u.name]) {
      options.add(new SelectOption(u.id,u.name));
    }
    return options;
  }
  
  public string getcsv_daterange() {
  	Datetime start_time = datetime.newInstance(sdate, time.newInstance(0,0,0,0));
  	Datetime end_time = datetime.newInstance(edate, time.newInstance(0,0,0,0));
  	String return_value = 'Report for : ' + start_time.format('M/dd/yyyy') + ' - ' + end_time.format('M/dd/yyyy');
  	return return_value;
  }
  
  public String getdownload_link() {
  	String hyper_link;
    if(Apexpages.currentPage()<>null) {
	  if(ApexPages.currentPage().getHeaders()==null)
	    hyper_link = '';
	  else
	    hyper_link = 'https://'+ApexPages.currentPage().getHeaders().get('Host');
    }
    if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.date_of_birth__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  
    hyper_link += '/apex/unconverted_consultscsv?sdate=' + sdate.format() + '&edate=' + edate.format();
    if(user_filter!='na')
  	  hyper_link += '&asuser=' + user_filter;
  	if(center_filter!='na')
  	  hyper_link += '&ascenter=' + center_filter;
  	if(region_filter!='na')
  	  hyper_link += '&aregion=' + region_filter;
    return hyper_link;  
  }
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public String getcsv_link() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/consult_exceptions_csv?sdate=' + sdate.format() + '&edate=' + edate.format();
  	if(user_filter!='na')
  	  hyper_link += '&asuser=' + user_filter;
  	if(center_filter!='na')
  	  hyper_link += '&ascenter=' + center_filter;
  	if(region_filter!='na')
  	  hyper_link += '&aregion=' + region_filter;
  	return hyper_link;
  }
  
  public CSVOutput[] getcsv_output() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	CSVOutput csv_line;
   	file_header = '"Name","Apt Date","Consult Status","Center","Consult PEC","Exception Type","Converted Date","Converted By","Last Consult","Region"';
  	//for(Consult_Inventory__c ci : getunconverted_consults_full()) {
  	for(Consult_Inventory__c ci : getunconverted_consults()) {
	    csv_line = new CSVOutput();
	  	csv_line.output_line =  ci.scheduled_lead__r.name + ',';
	  	csv_line.output_line += ci.apt_date__c + ',';
	  	csv_line.output_line += ci.consult_show_status__c + ',';
	  	csv_line.output_line += ci.consult_room__r.center_information__r.name + ',';
	  	csv_line.output_line += ci.consult_pec__r.name + ',';
	  	csv_line.output_line += 'Unconverted Consults,';
	  	csv_line.output_line += ci.Consult_Room__r.center_information__r.sales_region__c;
	    csvout.add(csv_line);  	
	  }
	  /*for(Consult_Inventory__c ci : getsecond_consults()) {
	  	csv_line = new CSVOutput();
	  	csv_line.output_line =  ci.scheduled_account__r.name + ',';
	  	csv_line.output_line += ci.apt_date__c + ',';
	  	csv_line.output_line += ci.consult_show_status__c + ',';
	  	csv_line.output_line += ci.consult_room__r.center_information__r.name + ',';
	  	csv_line.output_line += ci.consult_pec__r.name + ',';
	  	csv_line.output_line += '2nd Consults,';
	  	csv_line.output_line += ci.Consult_Room__r.center_information__r.sales_region__c;
	    csvout.add(csv_line); 
	  }*/
	  /*for(Lead l : getconversion_exceptions()) {
	  	csv_line = new CSVOutput();
	  	csv_line.output_line =  l.name + ',';	  	
	  	csv_line.output_line += ',';
	  	csv_line.output_line += ',';
	  	csv_line.output_line += l.center__r.name + ',';
	  	csv_line.output_line += ',';
	  	csv_line.output_line += 'Converted Leads,';
	  	csv_line.output_line += l.convertedaccount.createddate + ',';
	  	csv_line.output_line += l.convertedaccount.owner.name + ',';
	  	for(Consult_Inventory__c ci : l.consult_inventory__r) {
	  		csv_line.output_line += ci.apt_date__c + ',';
	  	}
	  	csv_line.output_line += ',';
	    csvout.add(csv_line); 
	  }*/
	 /* for(Lead l : getpostconversion_exceptions()) {
	  	csv_line = new CSVOutput();
	  	csv_line.output_line =  l.name + ',';	  	
	  	csv_line.output_line += ',';
	  	csv_line.output_line += ',';
	  	csv_line.output_line += l.center__r.name + ',';
	  	csv_line.output_line += ',';
	  	csv_line.output_line += 'Post Converted Leads,';
	  	csv_line.output_line += l.convertedaccount.createddate + ',';
	  	csv_line.output_line += l.convertedaccount.owner.name + ',';
	  	for(Consult_Inventory__c ci : l.consult_inventory__r) {
	  		csv_line.output_line += ci.apt_date__c + ',';
	  	}
	  	csv_line.output_line += ',';
	    csvout.add(csv_line); 
	  }  	*/
  	return csvout;
  }
  
  public static void rerun_report() {

  }
  
  public Consult_Inventory__c[] getunconverted_consults_full() {
  	//this method includes Patients Left status.  I'm producing a quick exception report for Scott Lawrence
  	//that shows the differences between the existing consults report and the cc dashboard
    if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.date_of_birth__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	
  	error_messages = '';
  	if(sdate > edate) {
  	  error_messages = 'Starting Date must be less than or equal to ending date.<br />Please adjust and try again';
      return null;
  	}	
  	List<Consult_Inventory__c> ci = [select consult_pec__r.name,id,apt_date__c,consult_show_status__c,scheduled_lead__c,scheduled_lead__r.id,scheduled_lead__r.name,consult_room__r.center_information__c,consult_room__r.center_information__r.name,consult_pec__c,consult_room__r.center_information__r.sales_region__c from Consult_Inventory__c where apt_date__c >= :sdate and apt_date__c <= :edate and consult_show_status__c in ('Consult Completed','Arrived','Ready for Consult','Consult Started','Patient Left') and scheduled_lead__c != null and scheduled_lead__r.isconverted = false order by consult_room__r.center_information__c];
  	return ci; 
  }  
  
  public Consult_Inventory__c[] getsecond_consults() {
  	//for Scott's exception report,  I'm also pulling a list of the consults seen during the report period that happen to be
  	//2nd consults
  	if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.date_of_birth__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));
  	List<Consult_Inventory__c> second_consults = [select consult_pec__r.name,id,apt_date__c,consult_show_status__c,scheduled_account__c,scheduled_account__r.id,scheduled_account__r.name,scheduled_lead__r.id,consult_room__r.center_information__c,consult_pec__c,consult_room__r.center_information__r.name, consult_room__r.center_information__r.sales_region__c from Consult_Inventory__c  where apt_date__c >= :sdate and apt_date__c <= :edate and arrival_time__c != null and scheduled_account__c != null order by consult_room__r.center_information__c];
  	return second_consults;
  } 
  
  public Lead[] getconversion_exceptions() {
  	//for Scott's exception report,  I'm pulling a list of account records created during the report period that were
  	//not on the consult calendar during that period of time.  These would be accounts that were cleaned up by the PEC's at a 
  	//later time that throw off the numbers between the two reports
  	if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.date_of_birth__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),23,59,59);
  	Set<Id> all_scheduled_leads = new Set<Id>();
  	for(Consult_Inventory__c ci : [select scheduled_lead__c from Consult_Inventory__c where apt_date__c >= :sdate and apt_date__c <= :edate and arrival_time__c != null and scheduled_lead__c != null]) {
  		all_scheduled_leads.add(ci.scheduled_lead__c);
  	}
  	List<Lead> conversion_exceptions = [select l.id,l.name,l.convertedaccount.createddate,l.convertedaccount.owner.name,l.center__r.name,(select apt_date__c from consult_inventory__r where active__c = true order by apt_date__c desc limit 1) from lead l where l.isconverted = true and l.convertedaccount.createddate >= :sdate_time and l.convertedaccount.createddate <= :edate_time and l.id not in :all_scheduled_leads];
  	return conversion_exceptions;
  }
  
  public Lead[] getpostconversion_exceptions() {
  	//for Scott's exception report,  I'm pulling a list of account records seen during the report period that were
  	//converted to consults outside of the reporting period
  	if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.date_of_birth__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),23,59,59);
  	Set<Id> all_scheduled_leads = new Set<Id>();
  	for(Consult_Inventory__c ci : [select scheduled_lead__c from Consult_Inventory__c where apt_date__c >= :sdate and apt_date__c <= :edate and arrival_time__c != null and scheduled_lead__c != null]) {
  		all_scheduled_leads.add(ci.scheduled_lead__c);
  	}
  	List<Lead> conversion_exceptions = [select l.id,l.name,l.convertedaccount.createddate,l.convertedaccount.owner.name,l.center__r.name,(select apt_date__c from consult_inventory__r where active__c = true order by apt_date__c desc limit 1) from lead l where l.isconverted = true and l.convertedaccount.createddate > :edate_time and l.id in :all_scheduled_leads];
  	return conversion_exceptions;
  }
	
  public Consult_Inventory__c[] getunconverted_consults() {
    if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.date_of_birth__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.date_of_birth__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),23,59,59);
  	error_messages = '';
  	if(sdate > edate) {
  	  error_messages = 'Starting Date must be less than or equal to ending date.<br />Please adjust and try again';
      return null;
  	}	
  	String query_filter = ' and scheduled_lead__c != null and scheduled_lead__r.isconverted = false and apt_date__c >= ' + sdate_time.format('YYYY-MM-dd') + ' and apt_date__c <= ' + edate_time.format('YYYY-MM-dd');  
  	if(user_filter != 'na')
  	  query_filter += ' and consult_pec__c = \'' + user_filter + '\'';
  	if(center_filter != 'na')
  	  query_filter += ' and consult_room__r.center_information__c = \'' + center_filter + '\'';
  	if(region_filter != 'na')
  	  query_filter += ' and consult_room__r.center_information__r.sales_region__c = \'' + region_filter + '\'';
  	System.debug('Filter : ' + query_filter); 	
  	List<Consult_Inventory__c> ci = database.query('select consult_pec__r.name,consult_room__r.center_information__r.name,scheduled_lead__r.name,id,apt_date__c,consult_show_status__c,scheduled_lead__c,scheduled_lead__r.id,consult_room__r.center_information__c,consult_pec__C, consult_room__r.center_information__r.sales_region__c from Consult_Inventory__c where consult_show_status__c in (\'Consult Completed\',\'Arrived\',\'Ready for Consult\',\'Consult Started\') ' + query_filter + ' order by consult_room__r.center_information__c');
  	return ci; 
  }   
  

  	
}