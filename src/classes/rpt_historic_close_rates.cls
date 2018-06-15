/*
modified by cm on 6/28/2017
cancels are now defined by cancel_date__c != null
removing references to stagename and completed stage
*/

global without sharing class rpt_historic_close_rates {
	public String file_header {get; set;}
	public String file_name {get; set;}
	public Integer run_days {get; set;}
	public String show_region {get; set;}
	public String csv_type {get; set;}

  public rpt_historic_close_rates() {
  	Date dtoday = System.today();
  	if(Apexpages.currentPage().getParameters().get('region')==null)
  	  show_region = 'All';
  	else
  	  show_region = Apexpages.currentPage().getParameters().get('region');
  	if(Apexpages.currentPage().getParameters().get('run_days')==null)
  	  run_days = 90;
  	else
  	  run_days = integer.valueof(Apexpages.currentPage().getParameters().get('run_days'));
  	if(Apexpages.currentPage().getParameters().get('csv_type')!=null) {
  	  csv_type = Apexpages.currentPage().getParameters().get('csv_type');
  	  if(csv_type=='1')
  	    file_name = 'historic_close_rates_region_center_pec_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  	  else if(csv_type=='2')
  	    file_name = 'historic_close_rates_pec_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  	  else if(csv_type=='3')
  	    file_name = 'historic_close_rates_center_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  	}
  	else
  	  file_name = 'historic_close_rates_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  }

  public List<SelectOption> getregion_list() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('All','All Regions'));
    for(Schema.PicklistEntry Value : Center_Information__c.Sales_Region__c.getDescribe().getPicklistValues()) {
    	options.add(new SelectOption(value.getvalue(),value.getlabel() + ' Region'));
		}
    return options;
  }

  public String getcsv_link() {
  	String hyper_link = '/apex/historic_run_rates_csv';
  	return hyper_link;
  }

  public class CSVOutput {
  	public String output_line { get; set; }
  }

  public Pagereference download_details() {
  	Pagereference pr = Page.historic_run_rates_csv;
  	pr.getParameters().put('run_days',string.valueof(run_days));
  	pr.getParameters().put('region',show_region);
  	pr.getParameters().put('csv_type',csv_type);
  	pr.setredirect(true);
  	return pr;
  }

  public CSVOutput[] getcsv_historic_cr_output() {
  	/*CSVOutput[] csvout = new CSVOutput[] {};
  	Close_Rates[] all_pecs = getclose_trends();
  	file_header = 'PEC,"","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %","","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %"';

    CSVOutput csv_line = new CSVOutput();
  	for(Close_Rates cr : all_pecs) {
  		csv_line = new CSVOutput();
  		csv_line.output_line = cr.pec.firstname + ' ' + cr.pec.lastname + ',"",';
  		csv_line.output_line += cr.gettrue_close_rate_90() + ',';
  		csv_line.output_line += cr.consults_90 + ',';
  		csv_line.output_line += cr.getfinance_percent_90() + ',';
      csv_line.output_line += cr.starts_90 + ',';
  		csv_line.output_line += cr.gettotal_cancels_90() + ',';
  		csv_line.output_line += cr.net_sold_90 + ',';
  		csv_line.output_line += cr.net_collected_90 + ',';
  		csv_line.output_line += cr.getcollection_percent_90() + ',';
  		csv_line.output_line += cr.getrefund_percent_90() + ',"",';

  		csv_line.output_line += cr.gettrue_close_rate_ly() + ',';
  		csv_line.output_line += cr.consults_ly + ',';
  		csv_line.output_line += cr.getfinance_percent_ly() + ',';
      csv_line.output_line += cr.starts_ly + ',';
  		csv_line.output_line += cr.gettotal_cancels_ly() + ',';
  		csv_line.output_line += cr.net_sold_ly + ',';
  		csv_line.output_line += cr.net_collected_ly + ',';
  		csv_line.output_line += cr.getcollection_percent_ly() + ',';
  		csv_line.output_line += cr.getrefund_percent_ly();
			csvout.add(csv_line);
  	}
  	csv_line = new CSVOutput();
  	csv_line.output_line = '';
  	csvout.add(csv_line);
  	csvout.add(csv_line);
  	csv_line = new CSVOutput();
  	csv_line.output_line = 'Center,"","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %","","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %"';
  	csvout.add(csv_line);

  	Center_Close_Rates[] all_centers = getcenter_trends();
  	for(Center_Close_Rates cr : all_centers) {
  		csv_line = new CSVOutput();
  		csv_line.output_line =  cr.ci.name + ',"",';
  		csv_line.output_line += cr.gettrue_close_rate_90() + ',';
			csv_line.output_line += cr.consults_90 + ',';
  		csv_line.output_line += cr.getfinance_percent_90() + ',';
      csv_line.output_line += cr.starts_90 + ',';
  		csv_line.output_line += cr.gettotal_cancels_90() + ',';
  		csv_line.output_line += cr.net_sold_90 + ',';
  		csv_line.output_line += cr.net_collected_90 + ',';
  		csv_line.output_line += cr.getcollection_percent_90() + ',';
  		csv_line.output_line += cr.getrefund_percent_90() + ',"",';

  		csv_line.output_line += cr.gettrue_close_rate_ly() + ',';
  		csv_line.output_line += cr.consults_ly + ',';
  		csv_line.output_line += cr.getfinance_percent_ly() + ',';
      csv_line.output_line += cr.starts_ly + ',';
  		csv_line.output_line += cr.gettotal_cancels_ly() + ',';
  		csv_line.output_line += cr.net_sold_ly + ',';
  		csv_line.output_line += cr.net_collected_ly + ',';
  		csv_line.output_line += cr.getcollection_percent_ly() + ',';
  		csv_line.output_line += cr.getrefund_percent_ly();
			csvout.add(csv_line);
  	}
  	return csvout;*/


  	CSVOutput[] csvout = new CSVOutput[] {};

  	CSVOutput csv_line = new CSVOutput();
  	if(csv_type=='1') {
  		file_header = ',,,,Last ' + run_days + ' Days,,,,,,,,,,Previous Year, Last ' + run_days + ' Days,\r\n' +
  	  'Center,PEC,"Region/Center CR"," PEC Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %","","Region/Center CR","PEC Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %"';
	    for(Region_CR region : getregion_trends()) {
	    	csv_line = new CSVOutput();
		  	csv_line.output_line = region.region + ' Region,"",';
		  	csv_line.output_line += region.gettrue_close_rate_90() + ',"",';
		  	csv_line.output_line += region.getconsults_90() + ',';
		  	csv_line.output_line += region.getfinance_percent_90() + ',';
	      csv_line.output_line += region.getstarts_90() + ',';
		  	csv_line.output_line += region.gettotal_cancels_90() + ',';
		  	csv_line.output_line += region.getnet_sold_90() + ',';
		  	csv_line.output_line += region.getnet_collected_90() + ',';
		  	csv_line.output_line += region.getcollection_percent_90() + ',';
		  	csv_line.output_line += region.getrefund_percent_90() + ',"",';

		  	csv_line.output_line += region.gettrue_close_rate_ly() + ',"",';
		  	csv_line.output_line += region.getconsults_ly() + ',';
		  	csv_line.output_line += region.getfinance_percent_ly() + ',';
		    csv_line.output_line += region.getstarts_ly() + ',';
		  	csv_line.output_line += region.gettotal_cancels_ly() + ',';
		  	csv_line.output_line += region.getnet_sold_ly() + ',';
		  	csv_line.output_line += region.getnet_collected_ly() + ',';
		  	csv_line.output_line += region.getcollection_percent_ly() + ',';
		  	csv_line.output_line += region.getrefund_percent_ly();
				csvout.add(csv_line);
	    	csv_line = new CSVOutput();
			  csv_line.output_line = '';
		  	csvout.add(csv_line);

		    Center_Agent_CR[] all_centers = region.getcenter_list();
		  	for(Center_Agent_CR center : all_centers) {
		  		csv_line = new CSVOutput();
		  		csv_line.output_line = center.ci.name + ',"",';
		  		csv_line.output_line += center.gettrue_close_rate_90() + ',"",';
		  		csv_line.output_line += center.getconsults_90() + ',';
		  		csv_line.output_line += center.getfinance_percent_90() + ',';
		      csv_line.output_line += center.getstarts_90() + ',';
		  		csv_line.output_line += center.gettotal_cancels_90() + ',';
		  		csv_line.output_line += center.getnet_sold_90() + ',';
		  		csv_line.output_line += center.getnet_collected_90() + ',';
		  		csv_line.output_line += center.getcollection_percent_90() + ',';
		  		csv_line.output_line += center.getrefund_percent_90() + ',"",';

		  		csv_line.output_line += center.gettrue_close_rate_ly() + ',"",';
		  		csv_line.output_line += center.getconsults_ly() + ',';
		  		csv_line.output_line += center.getfinance_percent_ly() + ',';
		      csv_line.output_line += center.getstarts_ly() + ',';
		  		csv_line.output_line += center.gettotal_cancels_ly() + ',';
		  		csv_line.output_line += center.getnet_sold_ly() + ',';
		  		csv_line.output_line += center.getnet_collected_ly() + ',';
		  		csv_line.output_line += center.getcollection_percent_ly() + ',';
		  		csv_line.output_line += center.getrefund_percent_ly();
					csvout.add(csv_line);
					for(Close_Rates cr : center.getpec_list()) {
					  csv_line = new CSVOutput();
			  		csv_line.output_line = ',' + cr.pec.firstname + ' ' + cr.pec.lastname + ',"",';
			  		csv_line.output_line += cr.gettrue_close_rate_90() + ',';
			  		csv_line.output_line += cr.consults_90 + ',';
			  		csv_line.output_line += cr.getfinance_percent_90() + ',';
			      csv_line.output_line += cr.starts_90 + ',';
			  		csv_line.output_line += cr.gettotal_cancels_90() + ',';
			  		csv_line.output_line += cr.net_sold_90 + ',';
			  		csv_line.output_line += cr.net_collected_90 + ',';
			  		csv_line.output_line += cr.getcollection_percent_90() + ',';
			  		csv_line.output_line += cr.getrefund_percent_90() + ',"","",';

			  		csv_line.output_line += cr.gettrue_close_rate_ly() + ',';
			  		csv_line.output_line += cr.consults_ly + ',';
			  		csv_line.output_line += cr.getfinance_percent_ly() + ',';
			      csv_line.output_line += cr.starts_ly + ',';
			  		csv_line.output_line += cr.gettotal_cancels_ly() + ',';
			  		csv_line.output_line += cr.net_sold_ly + ',';
			  		csv_line.output_line += cr.net_collected_ly + ',';
			  		csv_line.output_line += cr.getcollection_percent_ly() + ',';
			  		csv_line.output_line += cr.getrefund_percent_ly();
						csvout.add(csv_line);
					}
					csv_line = new CSVOutput();
					csv_line.output_line = '';
		  	  csvout.add(csv_line);
		  	  csvout.add(csv_line);
		  	}
	    }
  	}
  	else if(csv_type=='2') {
  		file_header = ',,,,Last ' + run_days + ' Days,,,,,,,,,,Previous Year, Last ' + run_days + ' Days,\r\n' +
  	  'PEC,"","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %","","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %"';
  		Close_Rates[] all_pecs = getclose_trends();
	  	for(Close_Rates cr : all_pecs) {
	  		csv_line = new CSVOutput();
	  		csv_line.output_line = cr.pec.firstname + ' ' + cr.pec.lastname + ',"",';
	  		csv_line.output_line += cr.gettrue_close_rate_90() + ',';
	  		csv_line.output_line += cr.consults_90 + ',';
	  		csv_line.output_line += cr.getfinance_percent_90() + ',';
	      csv_line.output_line += cr.starts_90 + ',';
	  		csv_line.output_line += cr.gettotal_cancels_90() + ',';
	  		csv_line.output_line += cr.net_sold_90 + ',';
	  		csv_line.output_line += cr.net_collected_90 + ',';
	  		csv_line.output_line += cr.getcollection_percent_90() + ',';
	  		csv_line.output_line += cr.getrefund_percent_90() + ',"",';

	  		csv_line.output_line += cr.gettrue_close_rate_ly() + ',';
	  		csv_line.output_line += cr.consults_ly + ',';
	  		csv_line.output_line += cr.getfinance_percent_ly() + ',';
	      csv_line.output_line += cr.starts_ly + ',';
	  		csv_line.output_line += cr.gettotal_cancels_ly() + ',';
	  		csv_line.output_line += cr.net_sold_ly + ',';
	  		csv_line.output_line += cr.net_collected_ly + ',';
	  		csv_line.output_line += cr.getcollection_percent_ly() + ',';
	  		csv_line.output_line += cr.getrefund_percent_ly();
				csvout.add(csv_line);
	  	}
	  	csv_line = new CSVOutput();
	  	csv_line.output_line = '';
	  	csvout.add(csv_line);
	  	csvout.add(csv_line);
  	}
  	else if(csv_type=='3') {
  		file_header = ',,,,Last ' + run_days + ' Days,,,,,,,,,,Previous Year, Last ' + run_days + ' Days,\r\n' +
  		'Center,"","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %","","Close Rate","Consults","Finance %","Starts","Cancels","Net Sold","Net Collected","Collection %","Refund %"';

	  	Center_Close_Rates[] all_centers = getcenter_trends();
	  	for(Center_Close_Rates cr : all_centers) {
	  		csv_line = new CSVOutput();
	  		csv_line.output_line =  cr.ci.name + ',"",';
	  		csv_line.output_line += cr.gettrue_close_rate_90() + ',';
				csv_line.output_line += cr.consults_90 + ',';
	  		csv_line.output_line += cr.getfinance_percent_90() + ',';
	      csv_line.output_line += cr.starts_90 + ',';
	  		csv_line.output_line += cr.gettotal_cancels_90() + ',';
	  		csv_line.output_line += cr.net_sold_90 + ',';
	  		csv_line.output_line += cr.net_collected_90 + ',';
	  		csv_line.output_line += cr.getcollection_percent_90() + ',';
	  		csv_line.output_line += cr.getrefund_percent_90() + ',"",';

	  		csv_line.output_line += cr.gettrue_close_rate_ly() + ',';
	  		csv_line.output_line += cr.consults_ly + ',';
	  		csv_line.output_line += cr.getfinance_percent_ly() + ',';
	      csv_line.output_line += cr.starts_ly + ',';
	  		csv_line.output_line += cr.gettotal_cancels_ly() + ',';
	  		csv_line.output_line += cr.net_sold_ly + ',';
	  		csv_line.output_line += cr.net_collected_ly + ',';
	  		csv_line.output_line += cr.getcollection_percent_ly() + ',';
	  		csv_line.output_line += cr.getrefund_percent_ly();
				csvout.add(csv_line);
	  	}
  	}
  	return csvout;
  }

  public class Close_Rates implements Comparable {
    public User pec {get; set;}
  	public Decimal starts_90 {get; set;}
   	public Integer consults_90 {get; set;}
   	public Decimal cancels_in_90 {get; set;}
   	public Decimal cancels_out_90 {get; set;}
   	public Decimal refunded_90 {get; set;}
   	public Decimal net_collected_90 {get; set;}
   	public Decimal net_sold_90 {get; set;}
   	public Decimal starts_ly {get; set;}
   	public Integer consults_ly {get; set;}
   	public Decimal cancels_in_ly {get; set;}
   	public Decimal cancels_out_ly {get; set;}
   	public Decimal refunded_ly {get; set;}
   	public Decimal net_collected_ly {get; set;}
   	public Decimal net_sold_ly {get; set;}
   	public Integer consults_financed_90 {get; set;}
   	public Integer consults_financed_ly {get; set;}

   	public Close_Rates(User u) {
   	  this.pec = u;
   	 	this.starts_90 = 0;
   	 	this.consults_90 = 0;
   	 	this.cancels_in_90 = 0;
   	 	this.cancels_out_90 = 0;
   	 	this.net_collected_90 = 0;
   	 	this.net_sold_90 = 0;
   	 	this.starts_ly = 0;
   	 	this.consults_ly = 0;
   	 	this.cancels_in_ly = 0;
   	 	this.cancels_out_ly = 0;
   	 	this.net_collected_ly = 0;
   	 	this.net_sold_ly = 0;
   	 	this.consults_financed_90 = 0;
   	 	this.consults_financed_ly = 0;
   	 	this.refunded_90 = 0;
   	 	this.refunded_ly = 0;
   	}

   	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      Close_rates compareToCloseRate = (Close_Rates)compareTo;
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (this.gettrue_close_rate_90() > compareToCloseRate.gettrue_close_rate_90()) {
        // Set return value to a positive value.
        returnValue = -1;
      } else if (this.gettrue_close_rate_90() < compareToCloseRate.gettrue_close_rate_90())
        // Set return value to a negative value.
        returnValue = 1;
      return returnValue;
    }


   	public Decimal getclose_rate_90() {
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_90() {
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90 - cancels_out_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getclose_rate_ly() {
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_ly() {
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly - cancels_out_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_90() {
   		if(net_sold_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_90 * 1.00)/(net_sold_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_ly() {
   		if(net_sold_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_ly * 1.00)/(net_sold_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_90() {
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_90 * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_ly() {
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_ly * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettotal_cancels_90() {
   		return cancels_in_90 + cancels_out_90;
   	}

   	public Decimal gettotal_cancels_ly() {
   		return cancels_in_ly + cancels_out_ly;
   	}

   	public Decimal getrefund_percent_90() {
   		if(net_collected_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_90 * 1.00)/(net_collected_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getrefund_percent_ly() {
   		if(net_collected_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_ly * 1.00)/(net_collected_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  }

  public Close_Rates[] getclose_trends() {
    Close_Rates[] return_rates = new Close_Rates[] {};
    User total_user = new User(FirstName= '',LastName = 'Totals');
    Close_Rates total_cr = new Close_Rates(total_user);

    Map<Id,Close_Rates> all_cr = new Map<Id,Close_Rates>{};
    Map<String,User> all_users = new Map<String,User> {};
    for(User u : [select id,name,firstname,lastname from User]) {
    	all_users.put(u.id,u);
    }
    //last 90 consults
    for(AggregateResult ar : [select ownerid,financing_result__c,count(id) num_consults from account where createddate >= last_90_days group by ownerid,financing_result__c]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).consults_90 += (Integer)ar.get('num_consults');
    	if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	  (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
    	  total_cr.consults_financed_90 += (Integer)ar.get('num_consults');
        all_cr.get((String)ar.get('ownerid')).consults_financed_90 += (Integer)ar.get('num_consults');
    	}
    	total_cr.consults_90 += (Integer)ar.get('num_consults');
    }
	// modified by aw 2016-06-20: For all Starts and Cancelled Starts
	// Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
	// Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
    //last 90 starts
    for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c >= last_90_days and is_Valid_Start__c = true group by ownerid]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).starts_90 = aggregate_value(ar, 'starts_value');
    	total_cr.starts_90 += aggregate_value(ar, 'starts_value');
    }
    //Last 90 Cancelled In period
    for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >= last_90_days and is_Valid_Start__c = true and
      prosth_exam_paid_date__c >= last_90_days group by ownerid]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).cancels_in_90 = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_in_90 += aggregate_value(ar, 'cancelled_value');
    }
    //Last 90 Cancelled Out of period
    for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >= last_90_days and is_Valid_Start__c = true and
      prosth_exam_paid_date__c <> last_90_days group by ownerid]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).cancels_out_90 = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_out_90 += aggregate_value(ar, 'cancelled_value');
    }
    //last 90 Collected
    for(AggregateResult ar : [Select opportunity__r.ownerid,payment_status__c,sum(net_collection_amount__c) total_payments
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund','NSF') and payment_date__c >= last_90_days
      group by opportunity__r.ownerid,payment_status__c]) {
      if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') {
    	  all_cr.get((String)ar.get('ownerid')).net_collected_90 += (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_90 += (Decimal)ar.get('total_payments');
    	}
    	else if((String)ar.get('payment_status__c')=='Refund' || (String)ar.get('payment_status__c')=='NSF') {
    		all_cr.get((String)ar.get('ownerid')).refunded_90 += (Decimal)ar.get('total_payments');
    	  all_cr.get((String)ar.get('ownerid')).net_collected_90 = all_cr.get((String)ar.get('ownerid')).net_collected_90 - (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_90 = total_cr.net_collected_90 - (Decimal)ar.get('total_payments');
    	  total_cr.refunded_90 += (Decimal)ar.get('total_payments');
    	}
    }
    //last 90 Sold
    for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity
      where createddate = LAST_90_DAYS group by ownerid]) {
      if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).net_sold_90 += (Decimal)ar.get('total_payments');
    	total_cr.net_sold_90 += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity
      where Cancel_Date__c = last_90_days group by ownerid]) {
      if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).net_sold_90 = all_cr.get((String)ar.get('ownerid')).net_sold_90 - (Decimal)ar.get('total_payments');
    	total_cr.net_sold_90 = total_cr.net_sold_90 - (Decimal)ar.get('total_payments');
    }


    //get the date range for the previous year
    //switching this to hard code the time values - otherwise numbers shift during the same day as the time progresses
    //Datetime end_filter = System.now().addYears(-1);
    //Datetime start_filter = end_filter.addDays(-90);
    Date edate_filter = System.today().addYears(-1);
    Date sdate_filter = edate_filter.addDays(-90);
    Datetime end_filter = datetime.newInstance(edate_filter.year(), edate_filter.month(), edate_filter.day(), 0, 0, 0);
    Datetime start_filter = datetime.newInstance(sdate_filter.year(), sdate_filter.month(), sdate_filter.day(), 0, 0, 0);
    //test workaround - since I can't create records in the past during test,  this uses current filters when running a test script
    if(Test.isRunningTest()) {
    	edate_filter = System.today().adddays(7);
    	sdate_filter = edate_filter.addDays(-90);
    	end_filter = datetime.newInstance(edate_filter.year(), edate_filter.month(), edate_filter.day(), 0, 0, 0);
    	start_filter = datetime.newInstance(sdate_filter.year(), sdate_filter.month(), sdate_filter.day(), 0, 0, 0);
    }

    //last year consults
    for(AggregateResult ar : [select ownerid,financing_result__c,count(id) num_consults from account where createddate >= :start_filter
      and createddate <= :end_filter group by ownerid,financing_result__c]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).consults_ly += (Integer)ar.get('num_consults');
    	if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	  (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
        all_cr.get((String)ar.get('ownerid')).consults_financed_ly += (Integer)ar.get('num_consults');
        total_cr.consults_financed_ly += (Integer)ar.get('num_consults');
    	}
    	total_cr.consults_ly += (Integer)ar.get('num_consults');
    }
	// modified by aw 2016-06-20: For all Starts and Cancelled Starts
	// Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
	// Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
    //last year starts
    for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c >= :sdate_filter
      and prosth_exam_paid_date__c <= :edate_filter and is_Valid_Start__c = true group by ownerid]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).starts_ly = aggregate_value(ar, 'starts_value');
    	total_cr.starts_ly += aggregate_value(ar, 'starts_value');
    }
    //Last year Cancelled In period
    for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >=  :start_filter and
      cancel_date__c <= :end_filter and is_Valid_Start__c = true and prosth_exam_paid_date__c >= :sdate_filter and prosth_exam_paid_date__c <= :edate_filter      
      group by ownerid]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).cancels_in_ly = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_in_ly += aggregate_value(ar, 'cancelled_value');
    }
    //Last year Cancelled Out of period
    for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >=  :start_filter and
      cancel_date__c <= :end_filter and prosth_exam_paid_date__c < :sdate_filter and is_Valid_Start__c = true 
      group by ownerid]) {
    	if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).cancels_out_ly = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_out_ly += aggregate_value(ar, 'cancelled_value');
    }
    //last year Collected
    for(AggregateResult ar : [Select opportunity__r.ownerid,payment_status__c,sum(net_collection_amount__c) total_payments
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund','NSF') and payment_date__c >= :sdate_filter and payment_date__c <= : edate_filter
      group by opportunity__r.ownerid,payment_status__c]) {
      if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') {
    	  all_cr.get((String)ar.get('ownerid')).net_collected_ly += (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_ly += (Decimal)ar.get('total_payments');
    	}
    	else if((String)ar.get('payment_status__c')=='Refund' || (String)ar.get('payment_status__c')=='NSF') {
    		all_cr.get((String)ar.get('ownerid')).refunded_ly += (Decimal)ar.get('total_payments');
    	  all_cr.get((String)ar.get('ownerid')).net_collected_ly = all_cr.get((String)ar.get('ownerid')).net_collected_ly - (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_ly = total_cr.net_collected_ly - (Decimal)ar.get('total_payments');
    	  total_cr.refunded_ly += (Decimal)ar.get('total_payments');
    	}
    }
    //last year Sold
    for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity
      where createddate >= :start_filter and createddate <= :end_filter group by ownerid]) {
      if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).net_sold_ly += (Decimal)ar.get('total_payments');
    	total_cr.net_sold_ly += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity
      where Cancel_Date__c >= :start_filter and createddate <= :end_filter group by ownerid]) {
      if(all_cr.get((String)ar.get('ownerid'))==null) {
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('ownerid')).net_sold_ly = all_cr.get((String)ar.get('ownerid')).net_sold_ly - (Decimal)ar.get('total_payments');
    	total_cr.net_sold_ly = total_cr.net_sold_ly - (Decimal)ar.get('total_payments');
    }

    return_rates = all_cr.values();
    return_rates.sort();

    return_rates.add(total_cr);
    return return_rates;
  }

		private Decimal aggregate_value(AggregateResult aggregate, String fieldname) {
			return (aggregate.get(fieldname) != null) ? (Decimal)aggregate.get(fieldname) : 0;
		}




  //center level stats
  public class Center_Close_Rates implements Comparable {
    public Center_Information__c ci {get; set;}
  	public Decimal starts_90 {get; set;}
   	public Integer consults_90 {get; set;}
   	public Decimal cancels_in_90 {get; set;}
   	public Decimal cancels_out_90 {get; set;}
   	public Decimal refunded_90 {get; set;}
   	public Decimal net_collected_90 {get; set;}
   	public Decimal net_sold_90 {get; set;}
   	public Decimal starts_ly {get; set;}
   	public Integer consults_ly {get; set;}
   	public Decimal cancels_in_ly {get; set;}
   	public Decimal cancels_out_ly {get; set;}
   	public Decimal refunded_ly {get; set;}
   	public Decimal net_collected_ly {get; set;}
   	public Decimal net_sold_ly {get; set;}
   	public Integer consults_financed_90 {get; set;}
   	public Integer consults_financed_ly {get; set;}

   	public Center_Close_Rates(Center_Information__c c) {
   	  this.ci = c;
   	 	this.starts_90 = 0;
   	 	this.consults_90 = 0;
   	 	this.cancels_in_90 = 0;
   	 	this.cancels_out_90 = 0;
   	 	this.net_collected_90 = 0;
   	 	this.net_sold_90 = 0;
   	 	this.starts_ly = 0;
   	 	this.consults_ly = 0;
   	 	this.cancels_in_ly = 0;
   	 	this.cancels_out_ly = 0;
   	 	this.net_collected_ly = 0;
   	 	this.net_sold_ly = 0;
   	 	this.consults_financed_90 = 0;
   	 	this.consults_financed_ly = 0;
   	 	this.refunded_90 = 0;
   	 	this.refunded_ly = 0;
   	}

   	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      Center_Close_Rates compareToCloseRate = (Center_Close_Rates)compareTo;
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (this.gettrue_close_rate_90() > compareToCloseRate.gettrue_close_rate_90()) {
        // Set return value to a positive value.
        returnValue = 1;
      } else if (this.gettrue_close_rate_90() < compareToCloseRate.gettrue_close_rate_90())
        // Set return value to a negative value.
        returnValue = -1;
      return returnValue;
    }


   	public Decimal getclose_rate_90() {
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_90() {
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90 - cancels_out_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getclose_rate_ly() {
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_ly() {
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly - cancels_out_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_90() {
   		if(net_sold_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_90 * 1.00)/(net_sold_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_ly() {
   		if(net_sold_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_ly * 1.00)/(net_sold_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_90() {
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_90 * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_ly() {
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_ly * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettotal_cancels_90() {
   		return cancels_in_90 + cancels_out_90;
   	}

   	public Decimal gettotal_cancels_ly() {
   		return cancels_in_ly + cancels_out_ly;
   	}

   	public Decimal getrefund_percent_90() {
   		if(net_collected_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_90 * 1.00)/(net_collected_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getrefund_percent_ly() {
   		if(net_collected_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_ly * 1.00)/(net_collected_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  }

  public Center_Close_Rates[] getcenter_trends() {
    Center_Close_Rates[] return_rates = new Center_Close_Rates[] {};
    Center_Information__c total_center = new Center_Information__c(Name='Totals');
    Center_Close_Rates total_cr = new Center_Close_Rates(total_center);

    Map<Id,Center_Close_Rates> all_cr = new Map<Id,Center_Close_Rates>{};
    Map<String,Center_Information__c> all_centers = new Map<String,Center_Information__c> {};
    for(Center_Information__c ci : [select id,name from Center_Information__c]) {
    	all_centers.put(ci.id,ci);
    }
    //last 90 consults
    for(AggregateResult ar : [select center__c,financing_result__c,count(id) num_consults from account where createddate >= last_90_days group by center__c,financing_result__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).consults_90 += (Integer)ar.get('num_consults');
    	if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	  (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
    	  total_cr.consults_financed_90 += (Integer)ar.get('num_consults');
        all_cr.get((String)ar.get('center__c')).consults_financed_90 += (Integer)ar.get('num_consults');
    	}
    	total_cr.consults_90 += (Integer)ar.get('num_consults');
    }
	// modified by aw 2016-06-20: For all Starts and Cancelled Starts
	// Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
	// Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
    //last 90 starts
    for(AggregateResult ar : [select account.center__c, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c >= last_90_days and is_Valid_Start__c = true group by account.center__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).starts_90 = aggregate_value(ar, 'starts_value');
    	total_cr.starts_90 += aggregate_value(ar, 'starts_value');
    }
    //Last 90 Cancelled In period
    for(AggregateResult ar : [select account.center__c, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >= last_90_days and is_Valid_Start__c = true and
      prosth_exam_paid_date__c >= last_90_days 
      group by account.center__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).cancels_in_90 = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_in_90 += aggregate_value(ar, 'cancelled_value');
    }
    //Last 90 Cancelled Out of period
    for(AggregateResult ar : [select account.center__c, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >= last_90_days and is_Valid_Start__c = true and
      prosth_exam_paid_date__c <> last_90_days 
      group by account.Center__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).cancels_out_90 = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_out_90 += aggregate_value(ar, 'cancelled_value');
    }
    //last 90 Collected
    for(AggregateResult ar : [Select opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments
      from CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund','NSF') and payment_date__c >= last_90_days
      group by opportunity__r.account.center__c,payment_status__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') {
    	  all_cr.get((String)ar.get('center__c')).net_collected_90 += (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_90 += (Decimal)ar.get('total_payments');
    	}
    	else if((String)ar.get('payment_status__c')=='Refund' || (String)ar.get('payment_status__c')=='NSF') {
    		all_cr.get((String)ar.get('center__c')).refunded_90 += (Decimal)ar.get('total_payments');
    	  all_cr.get((String)ar.get('center__c')).net_collected_90 = all_cr.get((String)ar.get('center__c')).net_collected_90 - (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_90 = total_cr.net_collected_90 - (Decimal)ar.get('total_payments');
    	  total_cr.refunded_90 += (Decimal)ar.get('total_payments');
    	}
    }
    //last 90 Sold
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity
      where createddate = LAST_90_DAYS group by account.center__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).net_sold_90 += (Decimal)ar.get('total_payments');
    	total_cr.net_sold_90 += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity
      where Cancel_Date__c = last_90_days 
      group by account.center__c]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).net_sold_90 = all_cr.get((String)ar.get('center__c')).net_sold_90 - (Decimal)ar.get('total_payments');
    	total_cr.net_sold_90 = total_cr.net_sold_90 - (Decimal)ar.get('total_payments');
    }

    //get the date range for the previous year
    //switching this to hard code the time values - otherwise numbers shift during the same day as the time progresses
    //Datetime end_filter = System.now().addYears(-1);
    //Datetime start_filter = end_filter.addDays(-90);
    Date edate_filter = System.today().addYears(-1);
    Date sdate_filter = edate_filter.addDays(-90);
    Datetime end_filter = datetime.newInstance(edate_filter.year(), edate_filter.month(), edate_filter.day(), 0, 0, 0);
    Datetime start_filter = datetime.newInstance(sdate_filter.year(), sdate_filter.month(), sdate_filter.day(), 0, 0, 0);

    //last year consults
    for(AggregateResult ar : [select center__c,financing_result__c,count(id) num_consults from account where createddate >= :start_filter
      and createddate <= :end_filter group by center__c,financing_result__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).consults_ly += (Integer)ar.get('num_consults');
    	if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	  (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
    	  total_cr.consults_financed_ly += (Integer)ar.get('num_consults');
        all_cr.get((String)ar.get('center__c')).consults_financed_ly += (Integer)ar.get('num_consults');
    	}
    	total_cr.consults_ly += (Integer)ar.get('num_consults');
    }
	// modified by aw 2016-06-20: For all Starts and Cancelled Starts
	// Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
	// Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
    //last year starts
    for(AggregateResult ar : [select account.center__c, SUM(Start_Value__c) starts_value from opportunity
      where prosth_exam_paid_date__c >= :sdate_filter and is_Valid_Start__c = true
      and prosth_exam_paid_date__c <= :edate_filter group by account.center__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).starts_ly = aggregate_value(ar, 'starts_value');
    	total_cr.starts_ly += aggregate_value(ar, 'starts_value');
    }
    //Last year Cancelled In period
    for(AggregateResult ar : [select account.center__c, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >=  :start_filter and is_Valid_Start__c = true
      and cancel_date__c <= :end_filter and prosth_exam_paid_date__c >= :sdate_filter and prosth_exam_paid_date__c <= :edate_filter
      
      group by account.center__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).cancels_in_ly = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_in_ly += aggregate_value(ar, 'cancelled_value');
    }
    //Last year Cancelled Out of period
    for(AggregateResult ar : [select account.center__c, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >=  :start_filter and is_Valid_Start__c = true
      and cancel_date__c <= :end_filter and prosth_exam_paid_date__c < :sdate_filter 
      group by account.center__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).cancels_out_ly = aggregate_value(ar, 'cancelled_value');
    	total_cr.cancels_out_ly += aggregate_value(ar, 'cancelled_value');
    }
    //last 90 Collected
    for(AggregateResult ar : [Select opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund','NSF') and payment_date__c >= :sdate_filter and payment_date__c <= : edate_filter
      group by opportunity__r.account.center__c,payment_status__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') {
    	  all_cr.get((String)ar.get('center__c')).net_collected_ly += (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_ly += (Decimal)ar.get('total_payments');
    	}
    	else if((String)ar.get('payment_status__c')=='Refund' || (String)ar.get('payment_status__c')=='NSF') {
    		all_cr.get((String)ar.get('center__c')).refunded_ly += (Decimal)ar.get('total_payments');
    	  all_cr.get((String)ar.get('center__c')).net_collected_ly = all_cr.get((String)ar.get('center__c')).net_collected_ly - (Decimal)ar.get('total_payments');
    	  total_cr.net_collected_ly = total_cr.net_collected_ly - (Decimal)ar.get('total_payments');
    	  total_cr.refunded_ly += (Decimal)ar.get('total_payments');
    	}
    }
    //last year Sold
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity
      where createddate >= :start_filter and createddate <= :end_filter group by account.center__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).net_sold_ly += (Decimal)ar.get('total_payments');
    	total_cr.net_sold_ly += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity
      where Cancel_Date__c >= :start_filter and createddate <= :end_filter 
      group by account.center__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Close_Rates cr = new Center_Close_Rates(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).net_sold_ly = all_cr.get((String)ar.get('center__c')).net_sold_ly - (Decimal)ar.get('total_payments');
    	total_cr.net_sold_ly = total_cr.net_sold_ly - (Decimal)ar.get('total_payments');
    }

    return_rates = all_cr.values();
    return_rates.sort();

    return_rates.add(total_cr);
    return return_rates;
  }

  //center level stats -w/agents
  public class Center_Agent_CR {
    public Center_Information__c ci {get; set;}
    public Map<Id,Close_Rates> center_cr_map {get; set;}

   	public Center_Agent_CR(Center_Information__c c) {
   	  this.ci = c;
   	  center_cr_map = new Map<Id,Close_Rates> ();
   	}

    public Close_rates[] getpec_list() {
    	Close_rates[] cr_list = center_cr_map.values();
    	cr_list.sort();
    	return cr_list;
    }

    public Decimal getstarts_ly() {
   		Decimal starts_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			starts_ly += cr.starts_ly;
   		}
   		return starts_ly;
   	}

   	public Integer getconsults_ly() {
   		Integer consults_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			consults_ly += cr.consults_ly;
   		}
   		return consults_ly;
   	}

   	public Decimal getcancels_in_ly() {
   		Decimal cancels_in_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			cancels_in_ly += cr.cancels_in_ly;
   		}
   		return cancels_in_ly;
   	}

   	public Decimal getcancels_out_ly() {
   		Decimal cancels_out_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			cancels_out_ly += cr.cancels_out_ly;
   		}
   		return cancels_out_ly;
   	}

   	public Decimal getnet_collected_ly() {
   		Decimal net_collected_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			net_collected_ly += cr.net_collected_ly;
   		}
   		if(net_collected_ly==0)
   		  return 0.00;
   		else
   		  return net_collected_ly;
   	}

   	public Decimal getnet_sold_ly() {
   		Decimal net_sold_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			net_sold_ly += cr.net_sold_ly;
   		}
   		if(net_sold_ly==0)
   		  return 0.00;
   		else
   		  return net_sold_ly;
   	}

   	public Integer getconsult_financed_ly() {
   		Integer consult_financed_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			consult_financed_ly += cr.consults_financed_ly;
   		}
   		return consult_financed_ly;
   	}

   	public Decimal getrefunded_ly() {
   		Decimal refunded_ly = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			refunded_ly += cr.refunded_ly;
   		}
   		if(refunded_ly==0)
   		  return 0.00;
   		else
   		  return refunded_ly;
   	}

   	public Decimal getstarts_90() {
   		Decimal starts_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			starts_90 += cr.starts_90;
   		}
   		return starts_90;
   	}

   	public Integer getconsults_90() {
   		Integer consults_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			consults_90 += cr.consults_90;
   		}
   		return consults_90;
   	}

   	public Decimal getcancels_in_90() {
   		Decimal cancels_in_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			cancels_in_90 += cr.cancels_in_90;
   		}
   		return cancels_in_90;
   	}

   	public Decimal getcancels_out_90() {
   		Decimal cancels_out_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			cancels_out_90 += cr.cancels_out_90;
   		}
   		return cancels_out_90;
   	}

   	public Decimal getnet_collected_90() {
   		Decimal net_collected_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			net_collected_90 += cr.net_collected_90;
   		}
   		if(net_collected_90==0)
   		  return 0.00;
   		else
   		  return net_collected_90;
   	}

   	public Decimal getnet_sold_90() {
   		Decimal net_sold_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			net_sold_90 += cr.net_sold_90;
   		}
   		if(net_sold_90==0)
   		  return 0.00;
   		else
   		  return net_sold_90;
   	}

   	public Integer getconsult_financed_90() {
   		Integer consult_financed_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			consult_financed_90 += cr.consults_financed_90;
   		}
   		return consult_financed_90;
   	}

   	public Decimal getrefunded_90() {
   		Decimal refunded_90 = 0;
   	  for(Close_Rates cr : center_cr_map.values()) {
   			refunded_90 += cr.refunded_90;
   		}
   		if(refunded_90==0)
   		  return 0.00;
   		else
   		  return refunded_90;
   	}

   	public Decimal getclose_rate_90() {
   		Integer consults_90 = 0;
   		Decimal starts_90 = 0;
   		Decimal cancels_in_90 = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			consults_90 += cr.consults_90;
   			starts_90 += cr.starts_90;
   			cancels_in_90 += cr.cancels_in_90;
   		}
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_90() {
   		Integer consults_90 = 0;
   		Decimal starts_90 = 0;
   		Decimal cancels_in_90 = 0;
   		Decimal cancels_out_90 = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			consults_90 += cr.consults_90;
   			starts_90 += cr.starts_90;
   			cancels_in_90 += cr.cancels_in_90;
   			cancels_out_90 += cr.cancels_out_90;
   		}
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90 - cancels_out_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getclose_rate_ly() {
   		Integer consults_ly = 0;
   		Decimal starts_ly = 0;
   		Decimal cancels_in_ly = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			consults_ly += cr.consults_ly;
   			starts_ly += cr.starts_ly;
   			cancels_in_ly += cr.cancels_in_ly;
   		}
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_ly() {
   		Integer consults_ly = 0;
   		Decimal starts_ly = 0;
   		Decimal cancels_in_ly = 0;
   		Decimal cancels_out_ly = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			consults_ly += cr.consults_ly;
   			starts_ly += cr.starts_ly;
   			cancels_in_ly += cr.cancels_in_ly;
   			cancels_out_ly += cr.cancels_out_ly;
   		}
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly - cancels_out_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_90() {
   		Decimal net_sold_90 = 0;
   		Decimal net_collected_90 = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			net_sold_90 += cr.net_sold_90;
   			net_collected_90 += cr.net_collected_90;
   		}
   		if(net_sold_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_90 * 1.00)/(net_sold_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_ly() {
   		Decimal net_sold_ly = 0;
   		Decimal net_collected_ly = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			net_sold_ly += cr.net_sold_ly;
   			net_collected_ly += cr.net_collected_ly;
   		}
   		if(net_sold_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_ly * 1.00)/(net_sold_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_90() {
   		Integer consults_90 = 0;
   		Integer consults_financed_90 = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			consults_90 += cr.consults_90;
   			consults_financed_90 += cr.consults_financed_90;
   		}
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_90 * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_ly() {
   		Integer consults_ly = 0;
   		Integer consults_financed_ly = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			consults_ly += cr.consults_ly;
   			consults_financed_ly += cr.consults_financed_ly;
   		}
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_ly * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettotal_cancels_90() {
   		Decimal cancels_in_90 = 0;
   		Decimal cancels_out_90 = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			cancels_in_90 += cr.cancels_in_90;
   			cancels_out_90 += cr.cancels_out_90;
   		}
   		return cancels_in_90 + cancels_out_90;
   	}

   	public Decimal gettotal_cancels_ly() {
   		Decimal cancels_in_ly = 0;
   		Decimal cancels_out_ly = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			cancels_in_ly += cr.cancels_in_ly;
   			cancels_out_ly += cr.cancels_out_ly;
   		}
   		return cancels_in_ly + cancels_out_ly;
   	}

   	public Decimal getrefund_percent_90() {
   		Decimal net_collected_90 = 0;
   		Decimal refunded_90 = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			net_collected_90 += cr.net_collected_90;
   			refunded_90 += cr.refunded_90;
   		}
   		if(net_collected_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_90 * 1.00)/(net_collected_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getrefund_percent_ly() {
   		Decimal net_collected_ly = 0;
   		Decimal refunded_ly = 0;
   		for(Close_Rates cr : center_cr_map.values()) {
   			net_collected_ly += cr.net_collected_ly;
   			refunded_ly += cr.refunded_ly;
   		}
   		if(net_collected_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_ly * 1.00)/(net_collected_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  }


 public Center_Agent_CR[] getcenter_agent_trends() {
    Center_Agent_CR[] return_rates = new Center_Agent_CR[] {};
    Center_Information__c total_center = new Center_Information__c(Name='All Centers',sales_region__c = 'Unknown');
    Center_Agent_CR total_cr = new Center_Agent_CR(total_center);
    User total_user = new User(FirstName = 'All PECS',lastname = '');
    Close_Rates total_pec = new Close_Rates(total_user);
    total_cr.center_cr_map.put(total_user.id,total_pec);

    Map<Id,Center_Agent_CR> all_cr = new Map<Id,Center_Agent_CR>{};
    Map<String,Center_Information__c> all_centers = new Map<String,Center_Information__c> {};
    for(Center_Information__c ci : [select id,name,sales_region__c from Center_Information__c]) {
    	all_centers.put(ci.id,ci);
    }
    Map<String,User> all_users = new Map<String,User> {};
    for(User u : [select id,name,firstname,lastname from User]) {
    	all_users.put(u.id,u);
    }

    //last 90 consults
    for(AggregateResult ar : database.query('select ownerid,center__c,financing_result__c,count(id) num_consults from account where createddate >= LAST_N_DAYS:' + run_days + ' group by center__c,financing_result__c,ownerid')) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).consults_90 += (Integer)ar.get('num_consults');
    	if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	  (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
    	  total_cr.center_cr_map.get(total_user.id).consults_financed_90 += (Integer)ar.get('num_consults');
        all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).consults_financed_90 += (Integer)ar.get('num_consults');
    	}
    	total_cr.center_cr_map.get(total_user.id).consults_90 += (Integer)ar.get('num_consults');
    }
	// modified by aw 2016-06-20: For all Starts and Cancelled Starts
	// Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
	// Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
     //last 90 starts
     for(AggregateResult ar : database.query('select ownerid,account.center__c, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c >= last_n_days:' + run_days + ' and is_Valid_Start__c = true group by account.center__c,ownerid')) {
    //for(AggregateResult ar : [select ownerid,account.center__c,count(id) num_starts from opportunity where createddate >= last_90_days group by account.center__c,ownerid]) {
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}

    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).starts_90 = aggregate_value(ar, 'starts_value');
    	total_cr.center_cr_map.get(total_user.id).starts_90 += aggregate_value(ar, 'starts_value');
    }
    //Last 90 Cancelled In period
    for(AggregateResult ar : database.query('select ownerid,account.center__c, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >= last_n_days:' + run_days + ' and is_Valid_Start__c = true and prosth_exam_paid_date__c >= last_n_days: ' + run_days + '  group by account.center__c,ownerid')) {
    /*for(AggregateResult ar : [select ownerid,account.center__c,count(id) num_cancel from opportunity where Cancel_Date__c >= last_90_days and
      createddate >= last_90_days and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in
      ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
      group by account.center__c,ownerid]) {*/
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).cancels_in_90 = aggregate_value(ar, 'cancelled_value');
    	total_cr.center_cr_map.get(total_user.id).cancels_in_90 += aggregate_value(ar, 'cancelled_value');
    }
    //Last 90 Cancelled Out of period
    for(AggregateResult ar : database.query('select ownerid,account.center__c, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >= last_n_days:' + run_days + ' and is_Valid_Start__c = true and prosth_exam_paid_date__c <> last_n_days:' + run_days + '  group by account.Center__c,ownerid')) {
    /*for(AggregateResult ar : [select ownerid,account.center__c,count(id) num_cancel from opportunity where Cancel_Date__c >= last_90_days and
      createddate <> last_90_days and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in
      ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
      group by account.Center__c,ownerid]) {*/
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).cancels_out_90 = aggregate_value(ar, 'cancelled_value');
    	total_cr.center_cr_map.get(total_user.id).cancels_out_90 += aggregate_value(ar, 'cancelled_value');
    }
    //last 90 Collected
    for(AggregateResult ar : database.query('Select opportunity__r.ownerid,opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments  From CCPayment__c ' +
      ' where payment_status__c in (\'Collected\',\'Collected Promise Note\',\'Refund\',\'NSF\') and payment_date__c >= last_n_days: ' + run_days +
      ' group by opportunity__r.account.center__c,opportunity__r.ownerid,payment_status__c')) {
    /*for(AggregateResult ar : [Select opportunity__r.ownerid,opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund','NSF') and payment_date__c >= last_90_days
      group by opportunity__r.account.center__c,opportunity__r.ownerid,payment_status__c]) {*/
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') {
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_collected_90 += (Decimal)ar.get('total_payments');
    	  total_cr.center_cr_map.get(total_user.id).net_collected_90 += (Decimal)ar.get('total_payments');
    	}
    	else if((String)ar.get('payment_status__c')=='Refund' || (String)ar.get('payment_status__c')=='NSF') {
    		all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).refunded_90 += (Decimal)ar.get('total_payments');
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_collected_90 = all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_collected_90 - (Decimal)ar.get('total_payments');
    	  total_cr.center_cr_map.get(total_user.id).net_collected_90 = total_cr.center_cr_map.get(total_user.id).net_collected_90 - (Decimal)ar.get('total_payments');
    	  total_cr.center_cr_map.get(total_user.id).refunded_90 += (Decimal)ar.get('total_payments');
    	}
    }
    //last 90 Sold
    for(AggregateResult ar : database.query('select account.center__c,ownerid,sum(negotiated_total_amount__c) total_payments from opportunity ' +
      ' where createddate = LAST_n_DAYS:' + run_days + ' group by account.center__c,ownerid')) {
    /*for(AggregateResult ar : [select account.center__c,ownerid,sum(negotiated_total_amount__c) total_payments from opportunity
      where createddate = LAST_90_DAYS group by account.center__c,ownerid]) {*/
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_sold_90 += (Decimal)ar.get('total_payments');
    	total_cr.center_cr_map.get(total_user.id).net_sold_90 += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : database.query('select ownerid,account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
      ' where Cancel_Date__c = last_n_days:' + run_days + ' ' +
      ' group by account.center__c,ownerid')) {
    /*for(AggregateResult ar : [select ownerid,account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity
      where Cancel_Date__c = last_90_days and (stagename = 'Cancelled Not Rescheduled' or
      Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
      group by account.center__c,ownerid]) {*/
    	if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_sold_90 = all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_sold_90 - (Decimal)ar.get('total_payments');
    	total_cr.center_cr_map.get(total_user.id).net_sold_90 = total_cr.center_cr_map.get(total_user.id).net_sold_90 - (Decimal)ar.get('total_payments');
    }

    //get the date range for the previous year
    //switching this to hard code the time values - otherwise numbers shift during the same day as the time progresses
    //Datetime end_filter = System.now().addYears(-1);
    //Datetime start_filter = end_filter.addDays(-90);
    Date edate_filter = System.today().addYears(-1);
    Date sdate_filter = edate_filter.addDays(-run_days);
    Datetime end_filter = datetime.newInstance(edate_filter.year(), edate_filter.month(), edate_filter.day(), 0, 0, 0);
    Datetime start_filter = datetime.newInstance(sdate_filter.year(), sdate_filter.month(), sdate_filter.day(), 0, 0, 0);

    //last year consults
    for(AggregateResult ar : [select center__c,ownerid,financing_result__c,count(id) num_consults from account where createddate >= :start_filter
      and createddate <= :end_filter group by center__c,ownerid,financing_result__c]) {
    /*for(AggregateResult ar : [select center__c,ownerid,financing_result__c,count(id) num_consults from account where createddate >= :start_filter
      and createddate <= :end_filter group by center__c,ownerid,financing_result__c]) {*/
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}

    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).consults_ly += (Integer)ar.get('num_consults');
    	if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	  (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
    	  total_cr.center_cr_map.get(total_user.id).consults_financed_ly += (Integer)ar.get('num_consults');
        all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).consults_financed_ly += (Integer)ar.get('num_consults');
    	}
    	total_cr.center_cr_map.get(total_user.id).consults_ly += (Integer)ar.get('num_consults');
    }
	// modified by aw 2016-06-20: For all Starts and Cancelled Starts
	// Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
	// Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
    //last year starts
    for(AggregateResult ar : [select account.center__c,ownerid, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c >= :sdate_filter and is_Valid_Start__c = true
      and prosth_exam_paid_date__c <= :edate_filter group by account.center__c,ownerid]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).starts_ly = aggregate_value(ar, 'starts_value');
    	total_cr.center_cr_map.get(total_user.id).starts_ly += aggregate_value(ar, 'starts_value');
    }
    //Last year Cancelled In period
    for(AggregateResult ar : [select account.center__c,ownerid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >=  :start_filter and is_Valid_Start__c = true
      and cancel_date__c <= :end_filter and prosth_exam_paid_date__c >= :sdate_filter and prosth_exam_paid_date__c <= :edate_filter
      
      group by account.center__c,ownerid]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).cancels_in_ly = aggregate_value(ar, 'cancelled_value');
    	total_cr.center_cr_map.get(total_user.id).cancels_in_ly += aggregate_value(ar, 'cancelled_value');
    }
    //Last year Cancelled Out of period
    for(AggregateResult ar : [select account.center__c,ownerid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c >=  :start_filter and is_Valid_Start__c = true
      and cancel_date__c <= :end_filter and prosth_exam_paid_date__c < :sdate_filter 
      group by account.center__c,ownerid]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).cancels_out_ly = aggregate_value(ar, 'cancelled_value');
    	total_cr.center_cr_map.get(total_user.id).cancels_out_ly += aggregate_value(ar, 'cancelled_value');
    }
    //last 90 Collected
    for(AggregateResult ar : [Select opportunity__r.account.center__c,opportunity__r.ownerid,payment_status__c,sum(net_collection_amount__c) total_payments
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund','NSF') and payment_date__c >= :sdate_filter and payment_date__c <= : edate_filter
      group by opportunity__r.account.center__c,opportunity__r.ownerid,payment_status__c]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') {
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_collected_ly += (Decimal)ar.get('total_payments');
    	  total_cr.center_cr_map.get(total_user.id).net_collected_ly += (Decimal)ar.get('total_payments');
    	}
    	else if((String)ar.get('payment_status__c')=='Refund' || (String)ar.get('payment_status__c')=='NSF') {
    		all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).refunded_ly += (Decimal)ar.get('total_payments');
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_collected_ly = all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_collected_ly - (Decimal)ar.get('total_payments');
    	  total_cr.center_cr_map.get(total_user.id).net_collected_ly = total_cr.center_cr_map.get(total_user.id).net_collected_ly - (Decimal)ar.get('total_payments');
    	  total_cr.center_cr_map.get(total_user.id).refunded_ly += (Decimal)ar.get('total_payments');
    	}
    }
    //last year Sold
    for(AggregateResult ar : [select ownerid,account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity
      where createddate >= :start_filter and createddate <= :end_filter group by account.center__c,ownerid]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_sold_ly += (Decimal)ar.get('total_payments');
    	total_cr.center_cr_map.get(total_user.id).net_sold_ly += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select account.center__c,ownerid,sum(negotiated_total_amount__c) total_payments from opportunity
      where Cancel_Date__c >= :start_filter and createddate <= :end_filter 
      group by account.center__c,ownerid]) {
   	  if(all_cr.get((String)ar.get('center__c'))==null) {
    		Center_Information__c ci = all_centers.get((String)ar.get('center__c'));
    	  Center_Agent_CR cr = new Center_Agent_CR(ci);
    	  all_cr.put((String)ar.get('center__c'),cr);
    	}
    	if(all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid'))==null) {
    		//create the pec here
    		User u = all_users.get((String)ar.get('ownerid'));
    	  Close_Rates cr = new Close_Rates(u);
    	  all_cr.get((String)ar.get('center__c')).center_cr_map.put((String)ar.get('ownerid'),cr);
    	}
    	all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_sold_ly = all_cr.get((String)ar.get('center__c')).center_cr_map.get((String)ar.get('ownerid')).net_sold_ly - (Decimal)ar.get('total_payments');
    	total_cr.center_cr_map.get(total_user.id).net_sold_ly = total_cr.center_cr_map.get(total_user.id).net_sold_ly - (Decimal)ar.get('total_payments');
    }

    return_rates = all_cr.values();
    //return_rates.sort();

    return_rates.add(total_cr);
    return return_rates;
 }

 //center level stats -w/agents
  public class Region_CR implements Comparable {
    public String region {get; set;}
    public Map<Id,Center_Agent_CR> center_cr_map {get; set;}

   	public Region_CR(String my_region) {
   	  this.region = my_region;
   	  center_cr_map = new Map<Id,Center_Agent_CR> ();
   	}

    // Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      Region_CR compareToCloseRate = (Region_CR)compareTo;
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if(this.region=='Unknown')
        returnValue = 1;
      else if (this.region > compareToCloseRate.region) {
        // Set return value to a positive value.
        returnValue = 1;
      } else if (this.region < compareToCloseRate.region)
        // Set return value to a negative value.
        returnValue = -1;
      return returnValue;
    }

    public Center_Agent_CR[] getcenter_list() {
    	Center_Agent_CR[] center_list = center_cr_map.values();
    	//center_list.sort();
    	return center_list;
    }

    public Decimal getstarts_ly() {
   		Decimal starts_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			starts_ly += cr.getstarts_ly();
   		}
   		return starts_ly;
   	}

   	public Integer getconsults_ly() {
   		Integer consults_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_ly += cr.getconsults_ly();
   		}
   		return consults_ly;
   	}

   	public Decimal getcancels_in_ly() {
   		Decimal cancels_in_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			cancels_in_ly += cr.getcancels_in_ly();
   		}
   		return cancels_in_ly;
   	}

   	public Decimal getcancels_out_ly() {
   		Decimal cancels_out_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			cancels_out_ly += cr.getcancels_out_ly();
   		}
   		return cancels_out_ly;
   	}

   	public Decimal getnet_collected_ly() {
   		Decimal net_collected_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_collected_ly += cr.getnet_collected_ly();
   		}
   		if(net_collected_ly==0)
   		  return 0.00;
   		else
   		  return net_collected_ly;
   	}

   	public Decimal getnet_sold_ly() {
   		Decimal net_sold_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_sold_ly += cr.getnet_sold_ly();
   		}
   		if(net_sold_ly==0)
   		  return 0.00;
   		else
   		  return net_sold_ly;
   	}

   	public Integer getconsult_financed_ly() {
   		Integer consult_financed_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			consult_financed_ly += cr.getconsult_financed_ly();
   		}
   		return consult_financed_ly;
   	}

   	public Decimal getrefunded_ly() {
   		Decimal refunded_ly = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			refunded_ly += cr.getrefunded_ly();
   		}
   		if(refunded_ly==0)
   		  return 0.00;
   		else
   		  return refunded_ly;
   	}

   	public Decimal getstarts_90() {
   		Decimal starts_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			starts_90 += cr.getstarts_90();
   		}
   		return starts_90;
   	}

   	public Integer getconsults_90() {
   		Integer consults_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_90 += cr.getconsults_90();
   		}
   		return consults_90;
   	}

   	public Decimal getcancels_in_90() {
   		Decimal cancels_in_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			cancels_in_90 += cr.getcancels_in_90();
   		}
   		return cancels_in_90;
   	}

   	public Decimal getcancels_out_90() {
   		Decimal cancels_out_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			cancels_out_90 += cr.getcancels_out_90();
   		}
   		return cancels_out_90;
   	}

   	public Decimal getnet_collected_90() {
   		Decimal net_collected_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_collected_90 += cr.getnet_collected_90();
   		}
   		if(net_collected_90==0)
   		  return 0.00;
   		else
   		  return net_collected_90;
   	}

   	public Decimal getnet_sold_90() {
   		Decimal net_sold_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_sold_90 += cr.getnet_sold_90();
   		}
   		if(net_sold_90==0)
   		  return 0.00;
   		else
   		  return net_sold_90;
   	}

   	public Integer getconsult_financed_90() {
   		Integer consult_financed_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			consult_financed_90 += cr.getconsult_financed_90();
   		}
   		return consult_financed_90;
   	}

   	public Decimal getrefunded_90() {
   		Decimal refunded_90 = 0;
   	  for(Center_Agent_CR cr : center_cr_map.values()) {
   			refunded_90 += cr.getrefunded_90();
   		}
   		if(refunded_90==0)
   		  return 0.00;
   		else
   		  return refunded_90;
   	}

   	public Decimal getclose_rate_90() {
   		Integer consults_90 = 0;
   		Decimal starts_90 = 0;
   		Decimal cancels_in_90 = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_90 += cr.getconsults_90();
   			starts_90 += cr.getstarts_90();
   			cancels_in_90 += cr.getcancels_in_90();
   		}
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_90() {
   		Integer consults_90 = 0;
   		Decimal starts_90 = 0;
   		Decimal cancels_in_90 = 0;
   		Decimal cancels_out_90 = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_90 += cr.getconsults_90();
   			starts_90 += cr.getstarts_90();
   			cancels_in_90 += cr.getcancels_in_90();
   			cancels_out_90 += cr.getcancels_out_90();
   		}
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_90 - cancels_in_90 - cancels_out_90) * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getclose_rate_ly() {
   		Integer consults_ly = 0;
   		Decimal starts_ly = 0;
   		Decimal cancels_in_ly = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_ly += cr.getconsults_ly();
   			starts_ly += cr.getstarts_ly();
   			cancels_in_ly += cr.getcancels_in_ly();
   		}
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettrue_close_rate_ly() {
   		Integer consults_ly = 0;
   		Decimal starts_ly = 0;
   		Decimal cancels_in_ly = 0;
   		Decimal cancels_out_ly = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_ly += cr.getconsults_ly();
   			starts_ly += cr.getstarts_ly();
   			cancels_in_ly += cr.getcancels_in_ly();
   			cancels_out_ly += cr.getcancels_out_ly();
   		}
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((starts_ly - cancels_in_ly - cancels_out_ly) * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_90() {
   		Decimal net_sold_90 = 0;
   		Decimal net_collected_90 = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_sold_90 += cr.getnet_sold_90();
   			net_collected_90 += cr.getnet_collected_90();
   		}
   		if(net_sold_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_90 * 1.00)/(net_sold_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getcollection_percent_ly() {
   		Decimal net_sold_ly = 0;
   		Decimal net_collected_ly = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_sold_ly += cr.getnet_sold_ly();
   			net_collected_ly += cr.getnet_collected_ly();
   		}
   		if(net_sold_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (net_collected_ly * 1.00)/(net_sold_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_90() {
   		Integer consults_90 = 0;
   		Integer consults_financed_90 = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_90 += cr.getconsults_90();
   			consults_financed_90 += cr.getconsult_financed_90();
   		}
   		if(consults_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_90 * 1.00)/(consults_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getfinance_percent_ly() {
   		Integer consults_ly = 0;
   		Integer consults_financed_ly = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			consults_ly += cr.getconsults_ly();
   			consults_financed_ly += cr.getconsult_financed_ly();
   		}
   		if(consults_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_ly * 1.00)/(consults_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal gettotal_cancels_90() {
   		Decimal cancels_in_90 = 0;
   		Decimal cancels_out_90 = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			cancels_in_90 += cr.getcancels_in_90();
   			cancels_out_90 += cr.getcancels_out_90();
   		}
   		return cancels_in_90 + cancels_out_90;
   	}

   	public Decimal gettotal_cancels_ly() {
   		Decimal cancels_in_ly = 0;
   		Decimal cancels_out_ly = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			cancels_in_ly += cr.getcancels_in_ly();
   			cancels_out_ly += cr.getcancels_out_ly();
   		}
   		return cancels_in_ly + cancels_out_ly;
   	}

   	public Decimal getrefund_percent_90() {
   		Decimal net_collected_90 = 0;
   		Decimal refunded_90 = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_collected_90 += cr.getnet_collected_90();
   			refunded_90 += cr.getrefunded_90();
   		}
   		if(net_collected_90==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_90 * 1.00)/(net_collected_90 * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}

   	public Decimal getrefund_percent_ly() {
   		Decimal net_collected_ly = 0;
   		Decimal refunded_ly = 0;
   		for(Center_Agent_CR cr : center_cr_map.values()) {
   			net_collected_ly += cr.getnet_collected_ly();
   			refunded_ly += cr.getrefunded_ly();
   		}
   		if(net_collected_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (refunded_ly * 1.00)/(net_collected_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  }

   public Region_CR[] getregion_trends() {
   	Region_CR[] return_rates = new Region_CR[] {};

    Map<String,Region_CR> all_regions = new Map<String,Region_CR>{};
    String region_filter = 'sales_region__c != null';
    if(show_region!='All')
      region_filter += ' and sales_region__c = \'' + show_region + '\'';
    System.debug('Show_region : ' + show_region);
    System.debug('Region Filter : ' + region_filter);
    System.debug('Query : ' + 'select sales_region__c from center_information__c where ' + region_filter + ' group by sales_region__c');
    //grab all Sales Regions
    for(AggregateResult ar : database.query('select sales_region__c from center_information__c where ' + region_filter + ' group by sales_region__c') ) {
    	String region = (String)ar.get('sales_region__c');
    	Region_CR center_cr = new Region_CR(region);
    	all_regions.put(region,center_cr);
    }
    if(show_region=='All') {
      Region_CR center_cr = new Region_CR('Unknown');
      all_regions.put('Unknown',center_cr);
    }

    //work through all of the centers and assign them to a region map
    Center_Agent_CR[] center_rates = getcenter_agent_trends();
    for(Center_Agent_cr center : center_rates) {
    	String region = center.ci.sales_region__c;
    	if(region=='' || region==' ' || region==null)
    	  region = 'Unknown';
    	try {
    	  all_regions.get(region).center_cr_map.put(center.ci.id,center);
    	}
    	catch (Exception e) {
    		//need to send email
    	}
    }

    return_rates = all_regions.values();
    return_rates.sort();
    return return_rates;

  }

  private static void init() {
  	Market__c m = new Market__c(Name = 'Test Market');
		Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center;
    Profile p = [select id from Profile where name = 'System Administrator'];
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV',
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c = true);
	  insert test_lead;
	  	  RecordType rt = [select id from RecordType where sobjecttype = 'Account' and name = 'Prospective Patients' limit 1];
	  Account test_account = new Account(financing_result__c='Approved Less Than 50%',billingcity = 'Test city', billingstate = 'CO', firstname = 'test', lastname = 'Account',recordtypeid = rt.id, center__c = test_center.id);
	  insert test_account;
	  Opportunity test_op = new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2');
	  insert test_op;
	  CCPayment__c test_cc = new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_op.id, finance_fee__c = 20.00);
	  insert test_cc;
	  Opportunity test_op_refund = new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Refund',
	    StageName = 'Cancelled Not Rescheduled' , Cancel_Date__c = System.today(), Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1');
	  insert test_op_refund;
	  CCPayment__c test_cc_refund = new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_op_refund.id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason');
	  insert test_cc_refund;
  }

  static testMethod void myTest() {
  	init();
  	test.startTest();
  	//rush job - need to get this out to the team to pull some numbers
  	Pagereference pageref = new PageReference('/apex/historic_run_rates');
    Test.setCurrentPage(pageRef);
  	rpt_historic_close_rates rpt = new rpt_historic_close_rates();
  	rpt.getregion_list();
  	Close_Rates[] all_pecs = rpt.getclose_trends();
  	for(Close_Rates cr : all_pecs) {
  		String s = '' + cr.starts_90;
      s += cr.pec.firstname;
  		s += cr.consults_90;
      s += cr.starts_90;
  		s += cr.cancels_in_90;
  		s += cr.getclose_rate_90();
  		s += cr.cancels_out_90;
  		s += cr.gettrue_close_rate_90();
  		s += cr.net_sold_90;
  		s += cr.net_collected_90;
  		s += cr.consults_ly;
      s += cr.starts_ly;
  		s += cr.cancels_in_ly;
  		s += cr.getclose_rate_ly();
  		s += cr.cancels_out_ly;
  		s += cr.gettrue_close_rate_ly();
  		s += cr.net_sold_ly;
  		s += cr.net_collected_ly;
  		s += cr.refunded_90;
  		s += cr.refunded_ly;
  		s += cr.gettotal_cancels_90();
  		s += cr.gettotal_cancels_ly();
  		s += cr.getrefund_percent_90();
  		s += cr.getrefund_percent_ly();
  		s += cr.getcollection_percent_90();
  		s += cr.getcollection_percent_ly();
  		s += cr.getfinance_percent_90();
  		s += cr.getfinance_percent_ly();
  	}
  	Center_Close_Rates[] all_centers = rpt.getcenter_trends();
  	for(Center_Close_Rates cr : all_centers) {
  		String s = '' + cr.starts_90;
      s += cr.ci.name;
  		s += cr.consults_90;
      s += cr.starts_90;
  		s += cr.cancels_in_90;
  		s += cr.getclose_rate_90();
  		s += cr.cancels_out_90;
  		s += cr.gettrue_close_rate_90();
  		s += cr.net_sold_90;
  		s += cr.net_collected_90;
  		s += cr.consults_ly;
      s += cr.starts_ly;
  		s += cr.cancels_in_ly;
  		s += cr.getclose_rate_ly();
  		s += cr.cancels_out_ly;
  		s += cr.gettrue_close_rate_ly();
  		s += cr.net_sold_ly;
  		s += cr.net_collected_ly;
  		s += cr.refunded_90;
  		s += cr.refunded_ly;
  		s += cr.gettotal_cancels_90();
  		s += cr.gettotal_cancels_ly();
  		s += cr.getrefund_percent_90();
  		s += cr.getrefund_percent_ly();
  		s += cr.getcollection_percent_90();
  		s += cr.getcollection_percent_ly();
  		s += cr.getfinance_percent_90();
  		s += cr.getfinance_percent_ly();
  	}
  	rpt.getcsv_link();
  	rpt.csv_type = '1';
  	rpt.getcsv_historic_cr_output();
  	rpt.csv_type = '2';
  	rpt.getcsv_historic_cr_output();
  	rpt.csv_type = '3';
  	rpt.getcsv_historic_cr_output();
  	pageref = rpt.download_details();
  	ApexPages.currentPage().getParameters().put('region','East');
  	ApexPages.currentPage().getParameters().put('run_days','120');
  	ApexPages.currentPage().getParameters().put('csv_type','1');
  	rpt = new rpt_historic_close_rates();
    ApexPages.currentPage().getParameters().put('region','Center');
  	ApexPages.currentPage().getParameters().put('run_days','100');
  	ApexPages.currentPage().getParameters().put('csv_type','2');
  	rpt = new rpt_historic_close_rates();
  	ApexPages.currentPage().getParameters().put('region','West');
  	ApexPages.currentPage().getParameters().put('run_days','30');
  	ApexPages.currentPage().getParameters().put('csv_type','3');
  	rpt = new rpt_historic_close_rates();
  	test.stopTest();
  }


}