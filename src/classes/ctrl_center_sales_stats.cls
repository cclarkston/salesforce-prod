public with sharing class ctrl_center_sales_stats {
	public String file_header {get; set;}
	public String file_name {get; set;}
  public Center_Collections total_collections {get; set;}
  
  public ctrl_center_sales_stats() {
  	Date dtoday = date.today();
  	file_name = 'center_yearly_revenue_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
  }
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public CSVOutput[] getcsv_output() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	Center_Collections[] all_centers = getcollections_by_year();
  	String[] mname = getmonth_names();
  	file_header = '"Center","Year"';
  	for(String m : mname) {
  		file_header += ',"' + m + '"';
  	}
  	for(Center_Collections cc : all_centers) {
  		for(Yearly_Collections yc : cc.getyear_revenue()) {
  		  CSVOutput csv_line = new CSVOutput();
  		  csv_line.output_line =  cc.my_center.name + ',';
  		  csv_line.output_line +=  yc.fiscal_year + ',';
  		  for(Decimal revenue : yc.getmonth_numbers()) {
  		  	csv_line.output_line += revenue + ',';
  		  }
			  csvout.add(csv_line);
  		}
  		CSVOutput csv_blank = new CSVOutput();
  		csv_blank.output_line = ' ';
  		csvout.add(csv_blank);  	
  	}  	
  	return csvout;
  }
  
  public class Yearly_Collections {
  	public Integer fiscal_year {get; set;}
  	public Map<Integer,Decimal> monthly_collections {get; set;}
  	
  	public Yearly_Collections(Integer y) {
  		this.fiscal_year = y;
  		monthly_collections = new Map<Integer,Decimal>{};
  		for(Integer cnt = 1; cnt<=12; cnt++) {
  			monthly_collections.put(cnt,0.00);
  		}
  	}
  	
  	public List<Decimal> getmonth_numbers() {
  		List<Decimal> return_vals = new List<Decimal> {};
  		for(Integer cnt = 1;cnt<=12; cnt++) {
  			return_vals.add(monthly_collections.get(cnt));
  		}
  		return return_vals;
  	}
  }

  public class Center_Collections {
  	public Center_Information__c my_center {get; set;}
  	public Map<Integer,yearly_collections> fiscal_collections {get; set;}  	
        
    public Center_Collections(Center_Information__c ci) {
    	this.my_center = ci;
    	fiscal_collections = new Map<Integer,yearly_collections>{};
    }
    
    public List<Yearly_Collections> getyear_revenue() {
    	List<Yearly_Collections> return_vals = fiscal_collections.values();
    	return return_vals;
    }
  }
  
  public List<String> getmonth_names() {
  	List<String> mnames = new List<String> {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
  	return mnames;
  }
  
  public Center_Collections[] getcollections_by_year() {
  	List<Center_Collections> all_centers = new List<Center_Collections> {};
  	//build a map of center_stats
  	Map<Id,Center_Collections> center_map = new Map<Id,Center_Collections> {};
  	//where name not in ('Unknown')
  	List<Center_Information__c> alpha_center = [select name,id from Center_Information__c where name not in ('Unknown','Market Not Yet Open') order by name];
  	Map<String,ID> center_translation = new Map<String,ID> {};
  	for(Center_Information__c ci : alpha_center) {
  		Center_Collections cs = new Center_Collections(ci);
  		center_map.put(ci.id,cs);
  		center_translation.put(ci.name,ci.id);
  	}  	
  	Center_Information__c total_ci = new Center_Information__c(name = 'Totals');
  	Center_Collections total_cs = new Center_Collections(total_ci);  	
  	//work through the years
    for(Integer syear = (System.now().year() - 2); syear <= System.now().year(); syear++) {
    	//for each center initialize the fiscal collection
    	for(Center_Information__c ci : alpha_center) { 
    	  Yearly_Collections y = new Yearly_Collections(syear);
    	  center_map.get(ci.id).fiscal_collections.put(syear,y);
    	}
    	Yearly_Collections y = new Yearly_Collections(syear);
    	total_cs.fiscal_collections.put(syear,y);
    	//work through the months
    	for(Integer smonth = 1; smonth <= 12; smonth++) {
    		//define the date range
    		Date stime = date.newInstance(syear, smonth, 1);
    		Date etime = stime;
    		if(smonth==12)
    		  etime = date.newInstance((syear + 1),1,1);
    		else
    		  etime = date.newInstance(syear,(smonth+1),1);
    		//query the collections numbers  
    		for (AggregateResult results : database.query('Select opportunity__r.account.center__c,payment_status__c,sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c in (\'Collected\',\'Refund\',\'Collected Promise Note\') and payment_date__c >= :stime and payment_date__c < :etime group by opportunity__r.account.center__c,payment_status__c')) {
		    	if(center_map.get((String)results.get('center__c'))!=null) {
		    		if((String)results.get('payment_status__c')=='Collected' || (String)results.get('payment_status__c')=='Collected Promise Note') { 
		    		  Decimal adjusted_val = center_map.get((String)results.get('center__c')).fiscal_collections.get(syear).monthly_collections.get(smonth) + (Decimal)results.get('total_payments');
		    		  Decimal adjusted_total_val = total_cs.fiscal_collections.get(syear).monthly_collections.get(smonth) + (Decimal)results.get('total_payments');
		    		  center_map.get((String)results.get('center__c')).fiscal_collections.get(syear).monthly_collections.put(smonth,adjusted_val);
		    		  total_cs.fiscal_collections.get(syear).monthly_collections.put(smonth,adjusted_total_val);
		    		}
		    		if((String)results.get('payment_status__c')=='Refund') {
		    		  Decimal adjusted_val = center_map.get((String)results.get('center__c')).fiscal_collections.get(syear).monthly_collections.get(smonth) - (Decimal)results.get('total_payments');
		    		  Decimal adjusted_total_val = total_cs.fiscal_collections.get(syear).monthly_collections.get(smonth) - (Decimal)results.get('total_payments');
		    		  center_map.get((String)results.get('center__c')).fiscal_collections.get(syear).monthly_collections.put(smonth,adjusted_val);
		    		  total_cs.fiscal_collections.get(syear).monthly_collections.put(smonth,adjusted_total_val);
		    		}		    	  
		    	  //total_cs.net_collections += (Decimal)results.get('total_payments');
		    	}
		    }    		    		
    	}
    }
    
    for(Center_Information__c ci : alpha_center) {  		
  		all_centers.add(center_map.get(ci.id)); 
  	} 
  	all_centers.add(total_cs);
    return all_centers;
  }
 
  static testMethod void myTest() {
  	ctrl_center_sales_stats cr = new ctrl_center_sales_stats();
  	Center_Collections[] cc = cr.getcollections_by_year();
  	String[] mname = cr.getmonth_names();
  	for(Center_Collections c : cc) {
  	  List<Yearly_Collections> y = c.getyear_revenue();
  	  c.fiscal_collections.get(System.today().year()).getmonth_numbers();	
  	}
  	List<CSVOutput> lcs = cr.getcsv_output();
  } 
}