public with sharing class rpt_revenue_trending {
	public Date sdate {get;set;}
	public Date edate {get;set;}
	public Consult_Inventory__c sholder {get; set;}
	public Consult_Inventory__c eholder {get; set;}
	public String error_messages {get; set;}
	public String file_header {get; set;}
	public String file_name {get; set;}  

  public rpt_revenue_trending() {
    sholder = new Consult_Inventory__c();
  	eholder = new Consult_Inventory__c();
  	sholder.apt_date__c = Date.newInstance(System.today().year(),System.today().month(),1);      
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
  	file_name = 'revenue_trending_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  }
  
  public class daily_revenue implements Comparable {
  	public Date reporting_date {get;set;}
  	public decimal collected {get; set;}
  	public decimal refunded {get; set;}
  	public decimal sold {get; set;}
  	public decimal cancelled {get; set;}
  	public monthly_stats mstats {get; set;}
  	
  	public daily_revenue(Date my_date, Monthly_Stats month_stat) {
  		this.reporting_date = my_date;
  		this.collected = 0;
  		this.refunded = 0;
  		this.sold = 0;
  		this.cancelled = 0;
  		this.mstats = month_stat;
  	}
  	
  	// Compare opportunities based on the opportunity amount.     
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper     
      Daily_Revenue compareToRevenue = (Daily_Revenue)compareTo;        
      // The return value of 0 indicates that both elements are equal.     
      Integer returnValue = 0;
      if (this.reporting_date > compareToRevenue.reporting_date) {
        // Set return value to a positive value.     
        returnValue = 1;
      } else if (this.reporting_date < compareToRevenue.reporting_date) 
        // Set return value to a negative value. 
        returnValue = -1;
      return returnValue;       
    }
  	
  	public decimal getnet_collections() {
  		return this.collected - this.refunded;
  	} 
  	
  	public decimal getnet_sales() {
  		return this.sold - this.cancelled;
  	}
  	
  	public decimal getmonthly_collection_percent() {
  		if(this.mstats.getnet_collections()==0)
  		  return 0.00;
  		else {
  			Decimal my_percent = (this.getnet_collections() * 1.00)/(this.mstats.getnet_collections() * 1.00);
   		  return my_percent.setscale(3);
  		}
  	}
  	
  	public decimal getrunning_collection_percent() {
  		if(this.mstats.getnet_collections()==0)
  		  return 0.00;
  		else {
  			Decimal my_percent = (this.mstats.running_collections.get(this.reporting_date.day()) * 1.00)/(this.mstats.getnet_collections() * 1.00);
   		  return my_percent.setscale(3);
  		}
  	}
  	
  	public decimal getmonthly_sold_percent() {
  		if(this.mstats.getnet_sales()==0)
  		  return 0.00;
  		else {
  			Decimal my_percent = (this.getnet_sales() * 1.00)/(this.mstats.getnet_sales() * 1.00);
   		  return my_percent.setscale(3);
  		}
  	}
  	
  	public decimal getrunning_sold_percent() {
  		if(this.mstats.getnet_sales()==0)
  		  return 0.00;
  		else {
  			Decimal my_percent = (this.mstats.running_sales.get(this.reporting_date.day()) * 1.00)/(this.mstats.getnet_sales() * 1.00);
   		  return my_percent.setscale(3);
  		}
  	}
  }
  
  public class monthly_stats {
  	public decimal collected;
  	public decimal refunded;
  	public decimal sold;
  	public decimal cancelled;
  	public Map<Integer,Decimal> running_collections = new Map<Integer,Decimal> {};
  	public Map<Integer,Decimal> running_sales = new Map<Integer,Decimal> {};
  	
  	public monthly_stats(Integer report_month,Integer report_year) {
  		this.collected = 0;
  		this.refunded = 0;
  		this.sold = 0;
  		this.cancelled = 0;
  		//create a start and end date for the report and then pull the key pieces of info we're looking for.
  		Datetime start_filter = Datetime.newInstance(report_year,report_month,1);
  		Datetime end_filter = start_filter.addMonths(1);  		
  		Date start_date = Date.newInstance(report_year,report_month,1);
  	  Date end_date = start_date.addMOnths(1);
  	  Date last_date = end_date.adddays(-1);
  	  Map<Integer,Decimal> daily_collections = new Map<Integer,Decimal> {};  	    	  
  	  //grab collections and refunds  
  	  for(AggregateResult ar : [Select payment_date__c,payment_status__c,sum(net_collection_amount__c) total_payments  
	      From CCPayment__c
	      where payment_status__c in ('Collected','Collected Promise Note','Refund') and 
	        payment_date__c >= :start_date and payment_date__c < :end_date
	      group by payment_date__c,payment_status__c]) {
	      Date pay_date = (Date)ar.get('payment_date__c');	      
	      if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') { 
	        this.collected += (Decimal)ar.get('total_payments');
	        if(daily_collections.get(pay_date.day())==null)
	          daily_collections.put(pay_date.day(),(Decimal)ar.get('total_payments'));
	        else 
	          daily_collections.put(pay_date.day(),(daily_collections.get(pay_date.day()) + (Decimal)ar.get('total_payments')));	        
	      }
	      else if((String)ar.get('payment_status__c')=='Refund') { 
	       	this.refunded += (Decimal)ar.get('total_payments');
          if(daily_collections.get(pay_date.day())==null)
	          daily_collections.put(pay_date.day(),((Decimal)ar.get('total_payments') * -1));
	        else 
	          daily_collections.put(pay_date.day(),(daily_collections.get(pay_date.day()) - (Decimal)ar.get('total_payments')));
	      }    	          	
	    }  
	    Map<Integer,Decimal> daily_sales = new Map<Integer,Decimal> {};
	    //grab sold revenue
	    for(AggregateResult ar : [select cdate__c,sum(negotiated_total_amount__c) total_payments from opportunity 
      where createddate >= :start_filter and createddate < :end_filter
      group by cdate__c]) {
      	Date pay_date = (Date)ar.get('cdate__c');
      	if((Decimal)ar.get('total_payments')!=null) {
          this.sold += (Decimal)ar.get('total_payments');
          daily_sales.put(pay_date.day(),(Decimal)ar.get('total_payments'));
      	}
    	}    	   
	    //grab cancelled revenue
	    for(AggregateResult ar : [select cancel_simple_date__c,sum(negotiated_total_amount__c) total_payments from opportunity 
	      where Cancel_Date__c >= :start_filter and cancel_date__c < :end_filter group by cancel_simple_date__c]) {
	      Date pay_date = (Date)ar.get('cancel_simple_date__c');
	      if((Decimal)ar.get('total_payments')!=null) {        
       	  this.cancelled += (Decimal)ar.get('total_payments');
       	  if(daily_sales.get(pay_date.day())==null)
       	    daily_sales.put(pay_date.day(),((Decimal)ar.get('total_payments') * -1));
       	  else
       	    daily_sales.put(pay_date.day(),(daily_sales.get(pay_date.day()) - (Decimal)ar.get('total_payments')));       	  
	      }
      }
      Decimal tot_collection = 0;
      Decimal tot_sales = 0;
      //build a map that has the running totals for the month
      for(Integer i=start_date.day();i<=last_date.day();i++) {
      	if(daily_collections.get(i)!=null) {
      		System.debug('Collection total before : ' + tot_collection + ' After : ' + (tot_collection + daily_collections.get(i)));
      	  tot_collection += daily_collections.get(i);
      	}
      	running_collections.put(i,tot_collection);
      	if(daily_sales.get(i)!=null) {
      		System.debug('Sales total before : ' + tot_sales + ' After : ' + (tot_sales + daily_sales.get(i))); 
      	  tot_sales += daily_sales.get(i);
      	}
      	running_sales.put(i,tot_sales);
      }	    
  	}
  	
  	public decimal getnet_collections() {
  		return this.collected - this.refunded;
  	} 
  	
  	public decimal getnet_sales() {
  		return this.sold - this.cancelled;
  	}
  }
  
  public string getcsv_daterange() {
  	Datetime start_time = datetime.newInstance(sdate, time.newInstance(0,0,0,0));
  	Datetime end_time = datetime.newInstance(edate, time.newInstance(0,0,0,0));
  	String return_value = 'Report for : ' + start_time.format('M/dd/yyyy') + ' - ' + end_time.format('M/dd/yyyy');
  	return return_value;
  }
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public String getcsv_link() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/revenue_trend_csv?sdate=' + sdate.format() + '&edate=' + edate.format();
  	return hyper_link;
  }
  
  public CSVOutput[] getcsv_output() {
  	CSVOutput[] csvout = new CSVOutput[] {};	
  	Daily_Revenue[] all_days = getrevenue_trend();
  	file_header = '"Date","Collected","Refunded","Net Collections","Month Collections","% of Monthly Collections","Running Total","","Net Sold Revenue","Month Net Revenue","% of Monthly Sold","Running Total"';
  	for(Daily_Revenue rt : all_days) {
  		CSVOutput csv_line = new CSVOutput();
  		csv_line.output_line =  rt.reporting_date + ',';
  		csv_line.output_line += rt.collected + ',';
      csv_line.output_line += rt.refunded + ',';
  		csv_line.output_line += rt.getnet_collections() + ',';
  		csv_line.output_line += rt.mstats.getnet_collections() + ',';
  		if(rt.mstats.getnet_collections()>0)
  			csv_line.output_line += rt.getmonthly_collection_percent() + ',';
  	  else 
  	    csv_line.output_line += 'N/A';  	   
  	  if(rt.mstats.getnet_collections()>0)
  			csv_line.output_line += rt.getrunning_collection_percent() + ',';
  	  else 
  	    csv_line.output_line += 'N/A';   
  		csv_line.output_line += ',' + rt.getnet_sales() + ',';
  		csv_line.output_line += rt.mstats.getnet_sales() + ',';
  		if(rt.mstats.getnet_sales()>0)
  			csv_line.output_line += rt.getmonthly_sold_percent() + ',';
  	  else 
  	    csv_line.output_line += 'N/A';  	   
  	  if(rt.mstats.getnet_sales()>0)
  			csv_line.output_line += rt.getrunning_sold_percent() + ',';
  	  else 
  	    csv_line.output_line += 'N/A';
			csvout.add(csv_line);  	
  	}  	
  	return csvout;
  }  
  
  public Daily_revenue[] getrevenue_trend() {
  	List<Daily_Revenue> revenue_trends = new List<Daily_Revenue> {};
  	Map<String,Monthly_Stats> monthly_numbers = new Map<String,Monthly_Stats> {};
  	Map<Date,Daily_Revenue> revenue_map = new Map<Date,Daily_Revenue> {};
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
  	//run a query to pull the collections and refunds
  	for(AggregateResult ar : [Select payment_date__c,payment_status__c,sum(net_collection_amount__c) total_payments  
	    From CCPayment__c
	    where payment_status__c in ('Collected','Collected Promise Note','Refund') and 
	      payment_date__c >= :sdate and payment_date__c < :edate
	    group by payment_date__c,payment_status__c]) {
	    //check to see if we have this month & date combination
	    Date pay_date = (Date)ar.get('payment_date__c');
	    String month_key = pay_date.month() + '-' + pay_date.year();
	    if(monthly_numbers.get(month_key)==null) {
	    	Monthly_Stats this_myear = new Monthly_Stats(pay_date.month(),pay_date.year());
	    	monthly_numbers.put(month_key,this_myear);
	    } 
	    //check to see if we have this date yet
	    if(revenue_map.get((Date)ar.get('payment_date__c'))==null) {
	    	Daily_Revenue this_day = new Daily_Revenue((date)ar.get('payment_date__c'),monthly_numbers.get(month_key));
	    	revenue_trends.add(this_day);
        revenue_map.put((Date)ar.get('payment_date__c'),this_day);	    	
	    }
	       	    	
	    if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') 
	      revenue_map.get((Date)ar.get('payment_date__c')).collected += (Decimal)ar.get('total_payments');
	    else if((String)ar.get('payment_status__c')=='Refund') 
	     	revenue_map.get((Date)ar.get('payment_date__c')).refunded += (Decimal)ar.get('total_payments');       	          	
	  }  
  	//grab sold revenue
	  for(AggregateResult ar : [select cdate__c,sum(negotiated_total_amount__c) total_payments from opportunity 
      where createddate >= :sdate_time and createddate < :edate_time
      group by cdate__c]) {      
      Date index_date = (Date)ar.get('cdate__c');
	    String month_key = index_date.month() + '-' + index_date.year();
	    if(monthly_numbers.get(month_key)==null) {
	    	Monthly_Stats this_myear = new Monthly_Stats(index_date.month(),index_date.year());
	    	monthly_numbers.put(month_key,this_myear);
	    } 
	    //check to see if we have this date yet
	    if(revenue_map.get(index_date)==null) {	    	
	    	Daily_Revenue this_day = new Daily_Revenue(index_date,monthly_numbers.get(month_key));
	    	revenue_trends.add(this_day);
        revenue_map.put(index_date,this_day);	    	
	    }      	     
      revenue_map.get(index_date).sold += (Decimal)ar.get('total_payments');
    }    	   
	  //grab cancelled revenue
	  for(AggregateResult ar : [select cancel_simple_date__c,sum(negotiated_total_amount__c) total_payments from opportunity 
	    where Cancel_Date__c >= :sdate_time and cancel_date__c < :edate_time group by cancel_simple_date__c]) {       
      Date index_date = (Date)ar.get('cancel_simple_date__c');
	    String month_key = index_date.month() + '-' + index_date.year();
	    if(monthly_numbers.get(month_key)==null) {
	    	Monthly_Stats this_myear = new Monthly_Stats(index_date.month(),index_date.year());
	    	monthly_numbers.put(month_key,this_myear);
	    } 
	    //check to see if we have this date yet
	    if(revenue_map.get(index_date)==null) {	    	
	    	Daily_Revenue this_day = new Daily_Revenue(index_date,monthly_numbers.get(month_key));
	    	revenue_trends.add(this_day);
        revenue_map.put(index_date,this_day);	    	
	    }      	     		    	  
     	revenue_map.get(index_date).cancelled += (Decimal)ar.get('total_payments');
    }	  
  	//System.debug('Revenue Size : ' + revenue_trends.size());
  	//System.debug('Rtrends : ' + revenue_trends);
  	revenue_trends.sort();
  	return revenue_trends;  	
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
	  Account test_account = new Account(billingcity = 'Test city', billingstate = 'CO', firstname = 'test', lastname = 'Account',recordtypeid = rt.id, center__c = test_center.id);
	  insert test_account;
	  Opportunity test_op = new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op',
	    StageName = 'Scheduled', Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1');
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
  	Pagereference pageref = new PageReference('/apex/revenue_trends');
    Test.setCurrentPage(pageRef);  	
  	
  	rpt_revenue_trending rpt = new rpt_revenue_trending();
  	rpt.sdate = System.today().addDays(-7);
  	rpt.edate = System.today().addDays(1);
  	rpt.sholder.apt_date__c = System.today().addDays(-7);
  	rpt.eholder.apt_date__c = System.today().addDays(7);
  	Daily_Revenue[] dr = rpt.getrevenue_trend();
  	for(Daily_Revenue my_dr : dr) {
  		my_dr.getmonthly_collection_percent();
  		my_dr.getmonthly_sold_percent();
  		my_dr.getnet_collections();
  		my_dr.getnet_sales();
  		my_dr.getrunning_collection_percent();
  		my_dr.getrunning_sold_percent();
  	}
  	rpt.getcsv_daterange();
  	rpt.getcsv_link();
  	List<CSVOutput> cs = rpt.getcsv_output();
  	//pageRef.getParameters().put('sdate',String.valueOf(System.now().));
  	//pageRef.getParameters().put('edate',String.valueof(System.today().addDays(1)));
  	rpt = new rpt_revenue_trending();
  	dr = rpt.getrevenue_trend();
  	for(Daily_Revenue my_dr : dr) {
  		my_dr.getmonthly_collection_percent();
  		my_dr.getmonthly_sold_percent();
  		my_dr.getnet_collections();
  		my_dr.getnet_sales();
  		my_dr.getrunning_collection_percent();
  		my_dr.getrunning_sold_percent();
  	}
  	
  	test.stopTest();
	}
}