public without sharing class rpt_center_stretch_stats {
	public String file_header {get; set;}
	public String file_name {get; set;}
	List<Center_Stats> center_numbers {get; set;}
	
  public rpt_center_stretch_stats() {
  	center_numbers = null;
  	Date dtoday = System.today();
  	file_name = 'center_stretch_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  }
  
  public String getcsv_link() {
  	String hyper_link = '/apex/center_stats_stretch_csv';
  	return hyper_link;
  }
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public CSVOutput[] getcsv_historic_cr_output() {
  	CSVOutput[] csvout = new CSVOutput[] {};  	
  	Center_Stats[] all_centers = run_center_numbers();    	
  	file_header = '"Center"';
  	for(center_stats cs : all_centers) {
  		file_header += ',"' + cs.my_center.name + '"';
  	}
  	  	  	
    CSVOutput csv_line = new CSVOutput();
    csv_line = new CSVOutput();
    csv_line.output_line = 'Net Collections';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getnet_collections();  		  	
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Target $';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.sales_goal;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Variance';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getVariance();  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Variance LY';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',NA';  		  		  
  	}
    csvout.add(csv_line);
  	
    csv_line = new CSVOutput();
    csv_line.output_line = 'Consults Scheduled';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.scheduled_consults;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.scheduled_consults_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Consults Showed';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.consults_showed;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.consults_showed_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Sold';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_sold;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_sold_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Net Starts';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_starts;  		  		  
  	}
    csvout.add(csv_line);
   
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_starts_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Sold';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_sold;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_sold_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Net Starts';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_starts;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_starts_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Close %';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getclose_rate();  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getclose_rate_ly();  		  		  
  	}
    csvout.add(csv_line);
  	
  	csv_line = new CSVOutput();
    csv_line.output_line = 'Refunds';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.refunded;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.refunded_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Finance %';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getfinance_rate();  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getfinance_rate_ly();  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Net AO4 Sold';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_ao4_sold;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.net_ao4_sold_ly;  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Avg AO4 Sold';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getavg_ao4_fee();  		  		  
  	}
    csvout.add(csv_line);
    
    csv_line = new CSVOutput();
    csv_line.output_line = 'Last Year';
  	for(Center_Stats cs : all_centers) {
  		csv_line.output_line += ',' + cs.getavg_ao4_fee_ly();  		  		  
  	}
    csvout.add(csv_line);
  	
  	return csvout;
  }  
  
  public class center_stats {
  	public Center_Information__c my_center {get; set;}
  	public Integer scheduled_consults {get; set;}
  	public Integer scheduled_consults_ly {get; set;}
  	public Integer consults_showed {get; set;}
  	public Integer consults_showed_ly {get; set;}
  	public Integer net_starts {get; set;}
  	public Integer net_starts_ly {get; set;}
  	public Decimal net_sold {get; set;}
  	public Decimal net_sold_ly {get; set;}
  	public Decimal sales_goal {get; set;}
  	public Decimal sales_goal_ly {get; set;}
  	public Decimal collected {get; set;}
  	public Decimal collected_ly {get; set;}
  	public Decimal refunded {get; set;}
  	public Decimal refunded_ly {get; set;}
  	public Decimal budgeted_consults {get; set;}
  	public Decimal budgeted_consults_ly {get; set;}
  	public Integer consults_financed {get; set;}
  	public Integer consults_financed_ly {get; set;}
  	public Integer num_ao4_sold {get; set;} 
  	public Integer num_ao4_sold_ly {get; set;}	
  	public Decimal net_ao4_sold {get; set;} 
  	public Decimal net_ao4_sold_ly {get; set;}   	
  	
  	
  	public center_stats(Center_Information__c ci) {
  		this.my_center = ci;
  		this.scheduled_consults = 0;
  		this.consults_showed = 0;
  		this.net_starts = 0;
  		this.net_sold = 0;
  		this.sales_goal = 0;
  		this.collected = 0;
  		this.refunded = 0;
  		this.budgeted_consults = 0;
  		this.consults_financed = 0;
  		this.scheduled_consults_ly = 0;
  		this.consults_showed_ly = 0;
  		this.net_starts_ly = 0;
  		this.net_sold_ly = 0;
  		this.sales_goal_ly = 0;
  		this.collected_ly = 0;
  		this.refunded_ly = 0;
  		this.budgeted_consults_ly = 0;
  		this.consults_financed_ly = 0;
  		this.net_ao4_sold = 0;
  		this.net_ao4_sold_ly = 0;
  		this.num_ao4_sold = 0;
  		this.num_ao4_sold_ly = 0;
    }
    
    public Decimal getavg_ao4_fee() {
   		if(num_ao4_sold==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((net_ao4_sold) * 1.00)/(num_ao4_sold * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
   	
   	public Decimal getavg_ao4_fee_ly() {
   		if(num_ao4_sold_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((net_ao4_sold_ly) * 1.00)/(num_ao4_sold_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  	
  	public Decimal getclose_rate() {
   		if(consults_showed==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((net_starts) * 1.00)/(consults_showed * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
   	
   	public Decimal getfinance_rate() {
   		if(consults_showed==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed * 1.00)/(consults_showed * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  	
  	public Decimal getnet_collections() {
  		return collected - refunded;
  	}
  	
  	public Decimal getVariance() {
  		return (collected - refunded) - sales_goal;
  	}
  	
  	public Decimal getclose_rate_ly() {
   		if(consults_showed_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = ((net_starts_ly) * 1.00)/(consults_showed_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
   	
   	public Decimal getfinance_rate_ly() {
   		if(consults_showed_ly==0)
   		  return 0.00;
   		else {
   		  Decimal my_percent = (consults_financed_ly * 1.00)/(consults_showed_ly * 1.00);
   		  return my_percent.setscale(3);
   		}
   	}
  	
  	public Decimal getnet_collections_ly() {
  		return collected_ly - refunded_ly;
  	}
  	
  }

  public List<Center_Stats> getall_center_numbers() {
  	if(center_numbers==null) {
  		center_numbers = new List<Center_Stats> {};
  		center_numbers = run_center_numbers();
  	}
  	return center_numbers;  	 
  }
 
  public List<Center_Stats> run_center_numbers() {
  	List<Center_Stats> all_centers = new List<Center_Stats> {};
  	//build a map of center_stats
  	Map<Id,Center_Stats> center_map = new Map<Id,Center_Stats> {};
  	//where name not in ('Unknown')
  	List<Center_Information__c> alpha_center = [select name,id,(Select Budgeted_Consults__c,Sales_Goal__c From Center_Budgets__r where fiscal_year__c = :system.today().year() and fiscal_month__c = :system.today().month()) from Center_Information__c where name not in ('Chicago Deerfield/Northbrook','Unknown') order by name];
  	//Map<String,ID> center_translation = new Map<String,ID> {};
  	for(Center_Information__c ci : alpha_center) {
  		Center_Stats cs = new Center_Stats(ci);
  		center_map.put(ci.id,cs);
  		//center_translation.put(ci.name,ci.id);
  		for(Center_Budget__c cb : ci.center_budgets__r) {
  			center_map.get(ci.id).sales_goal = cb.sales_goal__c;
  			center_map.get(ci.id).budgeted_consults = cb.budgeted_consults__c;
  		}
  	}
  	
  	Datetime start_filter = Datetime.newInstance(System.today().year(),System.today().month(),1);
  	Datetime end_filter = start_filter.addMonths(1);
  	Date start_date = Date.newInstance(System.today().year(),System.today().month(),1);
  	Date end_date = start_date.addMOnths(1);  
  	  	
  	//String center_id = center_translation.get(o.account.center_location__c);
  	//Starts
    for(AggregateResult ar : [select account.center__c,count(id) num_starts from opportunity where createddate >= this_month group by account.center__c]) {
    	String center_id = (String)ar.get('center__c');
    	if(center_map.get(center_id)!=null) 
 	  	  center_map.get(center_id).net_starts = (Integer)ar.get('num_starts'); 
    }
    for(AggregateResult ar : [select account.center__c,count(id) num_starts from opportunity 
    where createddate >= :start_filter and createddate < :end_filter group by account.center__c]) {
    	String center_id = (String)ar.get('center__c');
    	if(center_map.get(center_id)!=null) 
 	  	  center_map.get(center_id).net_starts_ly = (Integer)ar.get('num_starts'); 
    }
    //Cancelled Starts
    for(AggregateResult ar : [select account.center__c,count(id) num_cancel from opportunity where Cancel_Date__c >= this_month
      and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in 
      ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
      group by account.center__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) 
 	  	  center_map.get(center_id).net_starts = center_map.get(center_id).net_starts - (Integer)ar.get('num_cancel');  	  	  
    }
    for(AggregateResult ar : [select account.center__c,count(id) num_cancel from opportunity 
      where Cancel_Date__c >= :start_filter and Cancel_Date__c < :end_filter
      and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in 
      ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
      group by account.center__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) 
 	  	  center_map.get(center_id).net_starts_ly = center_map.get(center_id).net_starts - (Integer)ar.get('num_cancel');  	  	  
    }    
   
    //Collected/Refunded
    for(AggregateResult ar : [Select opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments  
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund') and payment_date__c >= this_month 
      group by opportunity__r.account.center__c,payment_status__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) { 
        if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') 
        	center_map.get(center_id).collected += (Decimal)ar.get('total_payments');
        else if((String)ar.get('payment_status__c')=='Refund') 
        	center_map.get(center_id).refunded += (Decimal)ar.get('total_payments');       
      }    	
    }  
    for(AggregateResult ar : [Select opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments  
      From CCPayment__c
      where payment_status__c in ('Collected','Collected Promise Note','Refund') and payment_date__c >= :start_date and
      payment_date__c < :end_date 
      group by opportunity__r.account.center__c,payment_status__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) { 
        if((String)ar.get('payment_status__c')=='Collected' || (String)ar.get('payment_status__c')=='Collected Promise Note') 
        	center_map.get(center_id).collected_ly += (Decimal)ar.get('total_payments');
        else if((String)ar.get('payment_status__c')=='Refund') 
        	center_map.get(center_id).refunded_ly += (Decimal)ar.get('total_payments');       
      }    	
    }
    
    //sold
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity 
      where createddate = this_month group by account.center__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) 
        center_map.get(center_id).net_sold += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity 
      where createddate >= :start_filter and createddate < :end_filter group by account.center__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) 
        center_map.get(center_id).net_sold_ly += (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity 
      where Cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or 
      Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) 
      group by account.center__c]) {
    	String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) 
       	center_map.get(center_id).net_sold = center_map.get(center_id).net_sold - (Decimal)ar.get('total_payments');
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments from opportunity 
      where Cancel_Date__c >= :start_filter and cancel_date__c < :end_filter and (stagename = 'Cancelled Not Rescheduled' or 
      Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) 
      group by account.center__c]) {
    	String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) 
       	center_map.get(center_id).net_sold_ly = center_map.get(center_id).net_sold - (Decimal)ar.get('total_payments');
    }
    
    //sold AO4
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments,count(id) num_ao4 from opportunity 
      where createddate = this_month and preliminary_treatment_plan__c includes ('AO4 Upper',
			'AO4 Lower',
			'AO4 Edentulous Upper',
			'AO4 Edentulous Lower',
			'DBL AO4',
			'DBL AO4 Edentulous',
			'Upper AO4 Interim Bridge Only',
			'Lower AO4 Interim Bridge Only',
			'DBL AO4 Interim Bridges Only',
			'Edentulous Upper AO4 Interim Bridge Only',
			'Edentulous Lower AO4 Interim Bridge Only',
			'Edentulous DBL AO4 Interim Bridges Only',
			'Transitional DBL AO4')
      group by account.center__c]) {
      String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) { 
        center_map.get(center_id).net_ao4_sold += (Decimal)ar.get('total_payments');
        center_map.get(center_id).num_ao4_sold += (Integer)ar.get('num_ao4');
      }
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments,count(id) num_ao4 from opportunity 
      where createddate >= :start_filter and createddate < :end_filter and preliminary_treatment_plan__c includes ('AO4 Upper',
			'AO4 Lower',
			'AO4 Edentulous Upper',
			'AO4 Edentulous Lower',
			'DBL AO4',
			'DBL AO4 Edentulous',
			'Upper AO4 Interim Bridge Only',
			'Lower AO4 Interim Bridge Only',
			'DBL AO4 Interim Bridges Only',
			'Edentulous Upper AO4 Interim Bridge Only',
			'Edentulous Lower AO4 Interim Bridge Only',
			'Edentulous DBL AO4 Interim Bridges Only',
			'Transitional DBL AO4') group by account.center__c]) {
      String center_id = (String)ar.get('center__c');
			if(center_map.get(center_id)!=null) { 
        center_map.get(center_id).net_ao4_sold_ly += (Decimal)ar.get('total_payments');
        center_map.get(center_id).num_ao4_sold_ly += (Integer)ar.get('num_ao4');
      }
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments,count(id) num_ao4 from opportunity 
      where Cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or 
      Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) 
      and preliminary_treatment_plan__c includes ('AO4 Upper',
			'AO4 Lower',
			'AO4 Edentulous Upper',
			'AO4 Edentulous Lower',
			'DBL AO4',
			'DBL AO4 Edentulous',
			'Upper AO4 Interim Bridge Only',
			'Lower AO4 Interim Bridge Only',
			'DBL AO4 Interim Bridges Only',
			'Edentulous Upper AO4 Interim Bridge Only',
			'Edentulous Lower AO4 Interim Bridge Only',
			'Edentulous DBL AO4 Interim Bridges Only',
			'Transitional DBL AO4') 
      group by account.center__c]) {
    	String center_id = (String)ar.get('center__c');
      if(center_map.get(center_id)!=null) {
       	center_map.get(center_id).net_ao4_sold = center_map.get(center_id).net_ao4_sold - (Decimal)ar.get('total_payments');
       	center_map.get(center_id).num_ao4_sold = center_map.get(center_id).num_ao4_sold - (Integer)ar.get('num_ao4');       	
      }
    }
    for(AggregateResult ar : [select account.center__c,sum(negotiated_total_amount__c) total_payments,count(id) num_ao4 from opportunity 
      where Cancel_Date__c >= :start_filter and cancel_date__c < :end_filter and (stagename = 'Cancelled Not Rescheduled' or 
      Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
      and preliminary_treatment_plan__c includes ('AO4 Upper',
			'AO4 Lower',
			'AO4 Edentulous Upper',
			'AO4 Edentulous Lower',
			'DBL AO4',
			'DBL AO4 Edentulous',
			'Upper AO4 Interim Bridge Only',
			'Lower AO4 Interim Bridge Only',
			'DBL AO4 Interim Bridges Only',
			'Edentulous Upper AO4 Interim Bridge Only',
			'Edentulous Lower AO4 Interim Bridge Only',
			'Edentulous DBL AO4 Interim Bridges Only',
			'Transitional DBL AO4') 
      group by account.center__c]) {
    	String center_id = (String)ar.get('center__c');
			if(center_map.get(center_id)!=null) {
       	center_map.get(center_id).net_ao4_sold_ly = center_map.get(center_id).net_ao4_sold_ly - (Decimal)ar.get('total_payments');
       	center_map.get(center_id).num_ao4_sold_ly = center_map.get(center_id).num_ao4_sold_ly - (Integer)ar.get('num_ao4');       	
      }
    }
    
    //consults scheduled
    for(AggregateResult ar : [Select c.consult_room__r.center_information__c,c.consult_room__r.room_type__c,count(c.id) num_consults
 	    From Consult_Inventory__c c where 
 	    c.apt_date__c = this_month and consult_room__r.room_type__c != 'Practice' and active__c=true and (c.scheduled_lead__c != null or c.scheduled_account__c != null)  
 	    group by c.consult_room__r.center_information__c,c.consult_room__r.room_type__c ]) {
      if(center_map.get((String)ar.get('center_information__c'))!=null) {
      	if(ar.get('room_type__c')=='Normal' || ar.get('room_type__c')=='Overflow')
      	  center_map.get((String)ar.get('center_information__c')).scheduled_consults += (Integer)ar.get('num_consults');
      } 	    
 	  }
 	  
 	  //consults showed
 	  /*for(AggregateResult ar : [Select c.consult_room__r.center_information__c,c.consult_room__r.room_type__c,count(c.id) num_consults
 	    From Consult_Inventory__c c where 
 	    c.apt_date__c = this_month and active__c=true and arrival_time__c != null  
 	    group by c.consult_room__r.center_information__c,c.consult_room__r.room_type__c ]) {
      if(center_map.get((String)ar.get('center_information__c'))!=null) {
     	  center_map.get((String)ar.get('center_information__c')).consults_showed += (Integer)ar.get('num_consults');
      	if(ar.get('room_type__c')=='Unconfirmed') 
      		center_map.get((String)ar.get('center_information__c')).scheduled_consults += (Integer)ar.get('num_consults');
      }
 	  } */
 	  //last year consults showed
 	  for(AggregateResult ar : [select center__c,financing_result__c,count(id) num_consults from account where createddate >= :start_filter 
      and createddate <= :end_filter group by center__c,financing_result__c]) {
   	  if(center_map.get((String)ar.get('center__c'))!=null) {
      	center_map.get((String)ar.get('center__c')).consults_showed_ly += (Integer)ar.get('num_consults');
    	  if((String)ar.get('financing_result__c')=='Approved Less Than 50%' || (String)ar.get('financing_result__c')=='Approved Greater or Equal to 50%' ||
    	    (String)ar.get('financing_result__c')=='Approved Full Amount' || (String)ar.get('financing_result__c')=='Declined') {
          center_map.get((String)ar.get('center__c')).consults_financed_ly += (Integer)ar.get('num_consults');                              	    	
    	  }
      }
    }
    //last year consults scheduled - can't use the consult inventory for this
    for(AggregateResult ar : [select center__c,count(id) num_scheduled from lead 
      where datetime_consult_scheduled__c >=: start_date and  datetime_consult_scheduled__c <=: end_date
      group by center__c]) {
      if(center_map.get((String)ar.get('center__c'))!=null) 
      	center_map.get((String)ar.get('center__c')).scheduled_consults_ly += (Integer)ar.get('num_scheduled');
    }
    
 	  //modified this so we can build a map of all account ids that showed over the report interval.  This set will
 	  //then be used to pull the financing results so we can calculate HCF utilization
 	  Set<Id> consults_showed = new Set<Id> {};
 	  for(Consult_Inventory__c ci : [select c.consult_room__r.center_information__c,c.consult_room__r.room_type__c,
 	    c.Scheduled_Lead__r.ConvertedAccountId, c.scheduled_account__c, c.scheduled_lead__c from Consult_Inventory__c c where 
 	    c.apt_date__c = this_month and active__c=true and arrival_time__c != null and consult_room__r.room_type__c != 'Practice']) {
 	    if(center_map.get(ci.consult_room__r.center_information__c)!=null) {
 	    	center_map.get(ci.consult_room__r.center_information__c).consults_showed++;
 	    	if(ci.Scheduled_lead__c!=null)
 	    	  consults_showed.add(ci.scheduled_lead__r.convertedaccountid);
 	    	if(ci.scheduled_account__c!=null)
 	    	  consults_showed.add(ci.scheduled_account__c); 	    	
 	    	if(ci.consult_room__r.room_type__c=='Unconfirmed')
 	    	  center_map.get(ci.consult_room__r.center_information__c).scheduled_consults++;
 	    }
 	  }

    ////grabbing the finance rate for our map
    for(AggregateResult ar : [select center__c,count(id) num_consults 
      from account 
      where createddate >= this_month and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined') 
      and id in :consults_showed
      group by center__c]) {
      if(center_map.get((String)ar.get('center__c'))!=null) {
        center_map.get((String)ar.get('center__c')).consults_financed += (Integer)ar.get('num_consults');
      }
    }
 	  
 	  for(Center_Information__c ci : alpha_center) {  		
  		all_centers.add(center_map.get(ci.id)); 
  	} 
    return all_centers;
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
	    StageName = 'Cancelled Not Rescheduled' , Cancel_Date__c = System.today(), Closedate = System.today(), preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2');
	  insert test_op_refund;	 
	  CCPayment__c test_cc_refund = new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_op_refund.id, finance_fee__c = 20.00, refund_reason__c = 'Random Reason');
	  insert test_cc_refund;
  }
  	
  static testMethod void Rpt_test() {
  	init();
  	test.startTest();
  	
  	Pagereference pageref = new PageReference('/apex/center_stats_stretch');
    Test.setCurrentPage(pageRef);     
    rpt_center_stretch_stats rcs = new rpt_center_stretch_stats();
    List<Center_Stats> cs = rcs.getall_center_numbers();
    rcs.getcsv_historic_cr_output();
    rcs.getcsv_link();
  	for(Center_Stats my_cs : cs) {
  	  my_cs.getavg_ao4_fee();
  	  my_cs.getavg_ao4_fee_ly();
  	  my_cs.getclose_rate();
  	  my_cs.getfinance_rate();
  	  my_cs.getfinance_rate_ly();
  	  my_cs.getnet_collections();
  	  my_cs.getnet_collections_ly();
  	  my_cs.getVariance();
  	}
  	test.stopTest();
  }
}