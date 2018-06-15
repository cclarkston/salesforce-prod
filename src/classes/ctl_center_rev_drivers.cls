public with sharing class ctl_center_rev_drivers {
	public Integer two_month_int = Date.today().addmonths(-2).month();
  public Integer two_year_int = Date.today().addmonths(-2).year();  
  public Integer last_month_int = Date.today().addmonths(-1).month();
  public Integer last_year_int = Date.today().addmonths(-1).year();
  public Integer current_month_int = Date.today().month();
  public Integer current_year_int = Date.today().year();
  public Integer current_date_int = Date.today().day();
  public String hyper_prefix = 'http://'+ApexPages.currentPage().getHeaders().get('Host');
  public String gethyper_prefix() { return hyper_prefix; }
  public Integer gettwo_month_int() { return last_month_int; }
  public Integer gettwo_year_int() { return last_year_int; }
  public Integer getlast_month_int() { return last_month_int; }
  public Integer getlast_year_int() { return last_year_int; }
  public Integer getcurrent_month_int() { return current_month_int; }
  public Integer getcurrent_year_int() { return current_year_int; }
  public Integer getcurrent_date_int() { return current_date_int; }
  public DateTime two_month_start = datetime.newInstance(two_year_int, two_month_int, 1, 00, 00, 1);
  
  public String getlast_month_name() {
    return getmonth_name(last_month_int);	
  }
  
  public String gettwo_month_name() {
  	return getmonth_name(two_month_int);
  }
  
  public String getmonth_name(Integer my_month) {
  	String month_name = '';
  	if(my_month==1)
  	  month_name =  'Jan';
  	if(my_month==2)
  	  month_name =  'Feb';
  	if(my_month==3)
  	  month_name =  'Mar';
  	if(my_month==4)
  	  month_name =  'Apr';
  	if(my_month==5)
  	  month_name =  'May';
  	if(my_month==6)
  	  month_name =  'Jun';
  	if(my_month==7)
  	  month_name =  'Jul';
  	if(my_month==8)
  	  month_name =  'Aug';
  	if(my_month==9)
  	  month_name =  'Sep';
  	if(my_month==10)
  	  month_name =  'Oct';
  	if(my_month==11)
  	  month_name =  'Nov';
  	if(my_month==12)
  	  month_name =  'Dec';
  	return month_name;
  }
  
  public CenterDrivers[] all_centers = new CenterDrivers[] {};  
  public class CenterDrivers {
  	public Id center_id {get; set;}
  	public String center_name {get; set;}
  	public Decimal budgeted_consults_two_month {get; set;}
  	public Decimal budgeted_consults_last_month {get; set;}
  	public Decimal budgeted_consults_current_month {get; set;}
  	public Decimal budgeted_close_rate_two_month {get; set;}
  	public Decimal budgeted_close_rate_last_month {get; set;}
  	public Decimal budgeted_close_rate_current_month {get; set;}
  	public Decimal consults_two_month {get; set;}
  	public Decimal consults_last_month {get; set;}
  	public Decimal consults_current_month {get; set;}
  	public Decimal gyb_consults_two_month {get; set;}
  	public Decimal gyb_consults_last_month {get; set;}
  	public Decimal gyb_consults_current_month {get; set;}
  	public Decimal starts_two_month {get; set;}
  	public Decimal starts_last_month {get; set;}
  	public Decimal starts_current_month {get; set;}
  	public Decimal cancels_two_month {get; set;}
  	public Decimal cancels_last_month {get; set;}
  	public Decimal cancels_current_month {get; set;} 
  	public CenterDrivers(Id cid, String cname) {
  		this.center_id = cid;
  		this.center_name = cname;
  		this.budgeted_consults_two_month = 0;
  		this.budgeted_consults_last_month = 0;
  		this.budgeted_consults_current_month = 0;
  		this.budgeted_close_rate_two_month = 0;
  		this.budgeted_close_rate_last_month = 0;
  		this.budgeted_close_rate_current_month = 0;
  		this.consults_two_month = 0;
  		this.consults_last_month = 0;
  		this.consults_current_month = 0;
  		this.starts_two_month = 0;
  		this.starts_last_month = 0;
  		this.starts_current_month = 0;
  		this.cancels_two_month = 0;
  		this.cancels_last_month = 0;
  		this.cancels_current_month = 0;
  		this.gyb_consults_two_month=0; 
  		this.gyb_consults_last_month=0;
  	  this.gyb_consults_current_month=0;
  	} 	  	
  }
  public CenterDrivers center_totals = new CenterDrivers(null,'Totals');
  
  public ctl_center_rev_drivers() {
  	//build a list of centers
  	/*for(Center_Information__c my_center : [select id,name from center_information__c order by name]) {*/
  	//switching to market roll up
  	for(AggregateResult results : [Select c.sales_market__c,c.Sales_Market__r.Name  
  	  From Center_Information__c c where sales_market__c <> '' group by c.sales_market__c,c.sales_market__r.name order by c.sales_market__r.Name]) {
  	  String market_id = String.valueOf(results.get('sales_market__c'));
      String market_name = String.valueOf(results.get('name'));    	  	
  		//CenterDrivers cdriver = new CenterDrivers(my_center.sales_market__c,my_center.Sales_Market__r.name);
  		CenterDrivers cdriver = new CenterDrivers(market_id,market_name);
  		all_centers.add(cdriver);
  	}
  	  	
  	/*Map<Id,Center_Budget__c> two_month_budgeted = new Map<Id,Center_Budget__c>();
  	Map<Id,Center_Budget__c> last_month_budgeted = new Map<Id,Center_Budget__c>();
  	Map<Id,Center_Budget__c> current_month_budgeted = new Map<Id,Center_Budget__c>();*/
  	Map<Id,AggregateResult> two_month_budgeted = new Map<Id,AggregateResult>();
  	Map<Id,AggregateResult> last_month_budgeted = new Map<Id,AggregateResult>();
  	Map<Id,AggregateResult> current_month_budgeted = new Map<Id,AggregateResult>();
  	/*Map<Id,Integer> two_month_budgeted_close = new Map<Id,Integer>();
  	Map<Id,Integer> last_month_budgeted_close = new Map<Id,Integer>();
  	Map<Id,Integer> current_month_budgeted_close = new Map<Id,Integer>();  	
  	Map<Id,Integer> two_month_budgeted_consults = new Map<Id,Integer>();
  	Map<Id,Integer> last_month_budgeted_consults = new Map<Id,Integer>();
  	Map<Id,Integer> current_month_budgeted_consults = new Map<Id,Integer>();*/
  	/*for(Center_Budget__c bconsults : database.query('select cb.center__c, cb.budgeted_close_rate__c, cb.budgeted_consults__c' +
      ' from center_budget__c  cb where cb.fiscal_month__c = ' + two_month_int + ' and cb.fiscal_year__c = ' + two_year_int)) {*/
    for(AggregateResult results : database.query('select cb.center__r.sales_market__c, sum(cb.budgeted_close_rate__c) budgeted_close_rate, sum(cb.budgeted_consults__c) budgeted_consults ' +
      ' from center_budget__c  cb where cb.fiscal_month__c = ' + two_month_int + ' and cb.fiscal_year__c = ' + two_year_int + ' group by cb.center__r.sales_market__c')) {
      two_month_budgeted.put(String.valueof(results.get('sales_market__c')),results);
      /*two_month_budgeted_close.put(String.valueof(results.get('sales_market__c')),Integer.valueOf(results.get('budgeted_close_rate')));
      two_month_budgeted_consults.put(String.valueof(results.get('sales_market__c')),Integer.valueOf(results.get('budgeted_consults')));*/
      //two_month_budgeted.put(bconsults.center__c,bconsults);
    }  	
  	/*for(Center_Budget__c bconsults : database.query('select cb.center__c, cb.budgeted_close_rate__c, cb.budgeted_consults__c' +
      ' from center_budget__c  cb where cb.fiscal_month__c = ' + last_month_int + ' and cb.fiscal_year__c = ' + last_year_int)) {*/
    for(AggregateResult results : database.query('select cb.center__r.sales_market__c, sum(cb.budgeted_close_rate__c) budgeted_close_rate, sum(cb.budgeted_consults__c) budgeted_consults ' +
      ' from center_budget__c  cb where cb.fiscal_month__c = ' + last_month_int + ' and cb.fiscal_year__c = ' + last_year_int + ' group by cb.center__r.sales_market__c')) {
      last_month_budgeted.put(String.valueof(results.get('sales_market__c')),results);
      //last_month_budgeted.put(bconsults.center__c,bconsults);
    }    
    /*for(Center_Budget__c bconsults : database.query('select cb.center__c, cb.budgeted_close_rate__c, cb.budgeted_consults__c' +
      ' from center_budget__c  cb where cb.fiscal_month__c = ' + current_month_int + ' and cb.fiscal_year__c = ' + current_year_int)) {*/
    for(AggregateResult results : database.query('select cb.center__r.sales_market__c, sum(cb.budgeted_close_rate__c) budgeted_close_rate, sum(cb.budgeted_consults__c) budgeted_consults ' +
      ' from center_budget__c  cb where cb.fiscal_month__c = ' + current_month_int + ' and cb.fiscal_year__c = ' + current_year_int + ' group by cb.center__r.sales_market__c')) {
      current_month_budgeted.put(String.valueof(results.get('sales_market__c')),results);
      //current_month_budgeted.put(bconsults.center__c,bconsults);
    }
    
    /*Map<String,Integer> two_month_starts = new Map<String,Integer>();
    Map<String,Integer> last_month_starts = new Map<String,Integer>();
    Map<String,Integer> current_month_starts = new Map<String,Integer>();
    Map<String,Integer> two_month_cancels = new Map<String,Integer>();
    Map<String,Integer> last_month_cancels = new Map<String,Integer>();
    Map<String,Integer> current_month_cancels = new Map<String,Integer>();
    Map<String,Integer> two_month_consults = new Map<String,Integer>();
    Map<String,Integer> last_month_consults = new Map<String,Integer>();
    Map<String,Integer> current_month_consults = new Map<String,Integer>();
    Map<String,Integer> two_month_gyb_consults = new Map<String,Integer>();
    Map<String,Integer> last_month_gyb_consults = new Map<String,Integer>();
    Map<String,Integer> current_month_gyb_consults = new Map<String,Integer>();*/
    Map<ID,Integer> two_month_starts = new Map<ID,Integer>();
    Map<ID,Integer> last_month_starts = new Map<ID,Integer>();
    Map<ID,Integer> current_month_starts = new Map<ID,Integer>();
    Map<ID,Integer> two_month_cancels = new Map<ID,Integer>();
    Map<ID,Integer> last_month_cancels = new Map<ID,Integer>();
    Map<ID,Integer> current_month_cancels = new Map<ID,Integer>();
    Map<ID,Integer> two_month_consults = new Map<ID,Integer>();
    Map<ID,Integer> last_month_consults = new Map<ID,Integer>();
    Map<ID,Integer> current_month_consults = new Map<ID,Integer>();
    Map<ID,Integer> two_month_gyb_consults = new Map<ID,Integer>();
    Map<ID,Integer> last_month_gyb_consults = new Map<ID,Integer>();
    Map<ID,Integer> current_month_gyb_consults = new Map<ID,Integer>();
    
    //---get starts for last month and current month     
    /*for(AggregateResult results : database.query('select account.center_location__c,count(o.id) num_starts from opportunity o  where ' +
     ' o.createddate >= :two_month_start and o.createddate < last_month group by o.account.center_location__c')) {*/
    for(AggregateResult results : database.query('select account.center__r.sales_market__c,count(o.id) num_starts from opportunity o  where ' +
     ' o.createddate >= :two_month_start and o.createddate < last_month group by o.account.center__r.sales_market__c')) {          
      //String my_id = String.valueOf(results.get('center_location__c'));
      //Integer num_starts = Integer.valueOf(results.get('num_starts'));
      //two_month_starts.put(my_id,num_starts);
      //center_totals.starts_two_month += num_starts;
    }
    /*for(AggregateResult results : [select account.center_location__c,count(o.id) num_starts 
      from opportunity o where o.createddate = last_month group by o.account.center_location__c]) {*/
    for(AggregateResult results : [select o.account.center__r.sales_market__c,count(o.id) num_starts 
      from opportunity o where o.createddate = last_month group by o.account.center__r.sales_market__c]) {      
      //System.debug('Center : ' + results.get('center_location__c') + ' ' + results.get('num_starts'));
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_starts'));
      last_month_starts.put(my_id,num_starts);
      center_totals.starts_last_month += num_starts;
    }
    /*for(AggregateResult results : [select account.center_location__c,count(o.id) num_starts 
      from opportunity o where o.createddate = this_month group by o.account.center_location__c]) {*/
    for(AggregateResult results : [select o.account.center__r.sales_market__c,count(o.id) num_starts 
      from opportunity o where o.createddate = this_month group by o.account.center__r.sales_market__c]) {
      //System.debug('Center : ' + results.get('center_location__c') + ' ' + results.get('num_starts'));
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_starts'));
      current_month_starts.put(my_id,num_starts);
      center_totals.starts_current_month += num_starts;
    }
    //--end get starts

    //--get consults for last month and this month
    /*for(AggregateResult results : database.query('select a.center_location__c,count(a.id) num_consults from account a ' + 
      ' where a.createddate >= :two_month_start and a.createddate < last_month group by a.center_location__c')) {*/
    for(AggregateResult results : database.query('select a.center__r.sales_market__c,count(a.id) num_consults from account a ' + 
      ' where a.createddate >= :two_month_start and a.createddate < last_month group by a.center__r.sales_market__c')) {
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_consults'));
      two_month_consults.put(my_id,num_starts);
      center_totals.consults_two_month += num_starts;
    }
    /*for(AggregateResult results : [select a.center_location__c,count(a.id) num_consults from account a 
      where a.createddate = last_month group by a.center_location__c]) {*/
    for(AggregateResult results : [	select a.center__r.sales_market__c,count(a.id) num_consults from account a 
      where a.createddate = last_month group by a.center__r.sales_market__c]) {  	      
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_consults'));
      last_month_consults.put(my_id,num_starts);
      center_totals.consults_last_month += num_starts;
    }
    /*for(AggregateResult results : [select a.center_location__c,count(a.id) num_consults from account a 
      where a.createddate = THIS_MONTH group by a.center_location__c]) {*/
    for(AggregateResult results : [select a.center__r.sales_market__c,count(a.id) num_consults from account a 
      where a.createddate = THIS_MONTH group by a.center__r.sales_market__c]) {
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_consults'));
      current_month_consults.put(my_id,num_starts);
      center_totals.consults_current_month += num_starts;
    }   
    //---end get consults 
    
    //--get GYB (black) consults for last month and this month
    /*for(AggregateResult results : database.query('select a.center_location__c,count(a.id) num_consults from account a ' + 
      ' where a.createddate >= :two_month_start and a.createddate < last_month and a.pre_screen_formula__c in (\'1. Green\',\'2. Yellow\',\'5. Other\') group by a.center_location__c')) {*/
    for(AggregateResult results : database.query('select a.center__r.sales_market__c,count(a.id) num_consults from account a ' + 
      ' where a.createddate >= :two_month_start and a.createddate < last_month and a.pre_screen_formula__c in (\'1. Green\',\'2. Yellow\',\'5. Other\') group by a.center__r.sales_market__c')) {
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_consults'));
      two_month_gyb_consults.put(my_id,num_starts);
      center_totals.gyb_consults_two_month += num_starts;
    }
    /*for(AggregateResult results : [select a.center_location__c,count(a.id) num_consults from account a 
      where a.createddate = last_month and a.pre_screen_formula__c in ('1. Green','2. Yellow','5. Other') group by a.center_location__c]) {*/
    for(AggregateResult results : [select a.center__r.sales_market__c,count(a.id) num_consults from account a 
      where a.createddate = last_month and a.pre_screen_formula__c in ('1. Green','2. Yellow','5. Other') group by a.center__r.sales_market__c]) {
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_consults'));
      last_month_gyb_consults.put(my_id,num_starts);
      center_totals.gyb_consults_last_month += num_starts;
    }
    /*for(AggregateResult results : [select a.center_location__c,count(a.id) num_consults from account a 
      where a.createddate = THIS_MONTH and a.pre_screen_formula__c in ('1. Green','2. Yellow','5. Other') group by a.center_location__c]) {*/
    for(AggregateResult results : [select a.center__r.sales_market__c,count(a.id) num_consults from account a 
      where a.createddate = THIS_MONTH and a.pre_screen_formula__c in ('1. Green','2. Yellow','5. Other') group by a.center__r.sales_market__c]) {
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_consults'));
      current_month_gyb_consults.put(my_id,num_starts);
      center_totals.gyb_consults_current_month += num_starts;
    }    
    //---end get consults GYB
    
    //---get cancelled starts for this month and last month
    /*Long note here - 2012-03-28
    After a long discussion with the team, it has been requested that I mimic the incorrect cancellation
    numbers that are coming from the existing consultation summary report.  That report only counts cancels
    that occur in the same month as the start date (based on them looking at it MTD),  and it doesn't have
    the filters set up right to properly include all of the cancellation states (don't even get me started
    on the fact that it's written so that it won't count any new cancel stages they add to the picklist
    going forward).  All of the correct queries to calculate the calculations properly will be commented
    out below in case someone wants the real close rate at some point in the future.  The make believe
    queries will be used in their place until that time.  I'm EXTREMELY unhappy with doing this,  and
    proceeding based on a request from Waltzer.  *more random and irrelevant grumbling here*
    */
    /* --- real query for cancels two months ago
    for(AggregateResult results : database.query('select account.center_location__c,count(o.id) num_starts ' + 
      ' from opportunity o where o.cancel_Date__c >= :two_month_start and o.cancel_Date__c < last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) ' + 
      ' group by o.account.center_location__c')) {*/
    //make believe query for cancel rate from two months back
    /*for(AggregateResult results : database.query('select account.center_location__c,count(o.id) num_starts ' + 
      ' from opportunity o where o.cancel_Date__c >= :two_month_start and o.cancel_Date__c < last_month and o.createddate >= :two_month_start and o.createddate < last_month and stagename = \'Cancelled Not Rescheduled\'  ' + 
      ' group by o.account.center_location__c')) {*/
    for(AggregateResult results : database.query('select o.account.center__r.sales_market__c,count(o.id) num_starts ' + 
      ' from opportunity o where o.cancel_Date__c >= :two_month_start and o.cancel_Date__c < last_month and o.createddate >= :two_month_start and o.createddate < last_month and stagename = \'Cancelled Not Rescheduled\'  ' + 
      ' group by o.account.center__r.sales_market__c')) {
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_starts'));
      two_month_cancels.put(my_id,num_starts);
      center_totals.cancels_two_month += num_starts;
    }
    /* --- real query for last months cancels
    for(AggregateResult results : [select account.center_location__c,count(o.id) num_starts 
      from opportunity o where o.cancel_Date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) 
      group by o.account.center_location__c]) {*/
    //make believe query for last months cancels
    /*for(AggregateResult results : [select account.center_location__c,count(o.id) num_starts 
      from opportunity o where o.cancel_Date__c = last_month and o.createddate = last_month and stagename = 'Cancelled Not Rescheduled' 
      group by o.account.center_location__c]) {*/
    for(AggregateResult results : [select o.account.center__r.sales_market__c,count(o.id) num_starts 
      from opportunity o where o.cancel_Date__c = last_month and o.createddate = last_month and stagename = 'Cancelled Not Rescheduled' 
      group by o.account.center__r.sales_market__c]) {
      //System.debug('Center : ' + results.get('center_location__c') + ' ' + results.get('num_starts'));
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_starts'));
      last_month_cancels.put(my_id,num_starts);
      center_totals.cancels_last_month += num_starts;
    }
    /* --- real query for this months cancels
    for(AggregateResult results : [select account.center_location__c,count(o.id) num_starts 
      from opportunity o where o.cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) 
      group by o.account.center_location__c]) {*/
    //make believe query for this months cancels
    /*for(AggregateResult results : [select account.center_location__c,count(o.id) num_starts 
      from opportunity o where o.cancel_Date__c = this_month and o.createddate = this_month and stagename = 'Cancelled Not Rescheduled'  
      group by o.account.center_location__c]) {*/
    for(AggregateResult results : [select o.account.center__r.sales_market__c,count(o.id) num_starts 
      from opportunity o where o.cancel_Date__c = this_month and o.createddate = this_month and stagename = 'Cancelled Not Rescheduled'  
      group by o.account.center__r.sales_market__c]) {
      //System.debug('Center : ' + results.get('center_location__c') + ' ' + results.get('num_starts'));      
      //String my_id = String.valueOf(results.get('center_location__c'));
      String my_id = String.valueOf(results.get('sales_market__c'));
      Integer num_starts = Integer.valueOf(results.get('num_starts'));
      current_month_cancels.put(my_id,num_starts);
      center_totals.cancels_current_month += num_starts;
    }
    //---end get cancelled starts
    
    Integer num_centers_two = 0;
    Integer num_centers_last = 0;
    Integer num_centers_current = 0;
    String holder = '';
    for(CenterDrivers my_center : all_centers) {
    	if(two_month_budgeted.get(my_center.center_id)<> null) {
   		  num_centers_two += 1;
    		//my_center.budgeted_consults_two_month = two_month_budgeted.get(my_center.center_id).budgeted_consults__c;
    		my_center.budgeted_consults_two_month = Integer.valueOf(two_month_budgeted.get(my_center.center_id).get('budgeted_consults'));
    		//center_totals.budgeted_consults_two_month += two_month_budgeted.get(my_center.center_id).budgeted_consults__c;
    		center_totals.budgeted_consults_two_month += Integer.valueOf(two_month_budgeted.get(my_center.center_id).get('budgeted_consults'));
    		//my_center.budgeted_close_rate_two_month = two_month_budgeted.get(my_center.center_id).budgeted_close_rate__c;
    		holder = String.valueOf(two_month_budgeted.get(my_center.center_id).get('budgeted_close_rate'));
    		my_center.budgeted_close_rate_two_month = Decimal.valueOf(holder);
    		//center_totals.budgeted_close_rate_two_month += two_month_budgeted.get(my_center.center_id).budgeted_close_rate__c;
    		center_totals.budgeted_close_rate_two_month += Decimal.valueOf(holder);
    	}
    	if(last_month_budgeted.get(my_center.center_id)<> null) {
   		  num_centers_last += 1;
    		//my_center.budgeted_consults_last_month = last_month_budgeted.get(my_center.center_id).budgeted_consults__c;
    		my_center.budgeted_consults_last_month = Integer.valueOf(last_month_budgeted.get(my_center.center_id).get('budgeted_consults'));
    		//center_totals.budgeted_consults_last_month += last_month_budgeted.get(my_center.center_id).budgeted_consults__c;
    		center_totals.budgeted_consults_last_month += Integer.valueOf(last_month_budgeted.get(my_center.center_id).get('budgeted_consults'));
    		//my_center.budgeted_close_rate_last_month = last_month_budgeted.get(my_center.center_id).budgeted_close_rate__c;
    		holder = String.valueOf(last_month_budgeted.get(my_center.center_id).get('budgeted_close_rate'));
    		my_center.budgeted_close_rate_last_month = Decimal.valueOf(holder);
    		//center_totals.budgeted_close_rate_last_month += last_month_budgeted.get(my_center.center_id).budgeted_close_rate__c;
    		center_totals.budgeted_close_rate_last_month += Decimal.valueOf(holder);
    	}
    	//System.debug('Pre Check - Current Centers : ' + num_centers_current + ' Total : ' + center_totals.budgeted_close_rate_current_month);    	 
    	if(current_month_budgeted.get(my_center.center_id)<> null) {
  		  num_centers_current += 1;
    		//my_center.budgeted_consults_current_month = current_month_budgeted.get(my_center.center_id).budgeted_consults__c;
    		//center_totals.budgeted_consults_current_month += current_month_budgeted.get(my_center.center_id).budgeted_consults__c;
    		//my_center.budgeted_close_rate_current_month = current_month_budgeted.get(my_center.center_id).budgeted_close_rate__c;
    		//center_totals.budgeted_close_rate_current_month += current_month_budgeted.get(my_center.center_id).budgeted_close_rate__c;    		
    		my_center.budgeted_consults_current_month = Integer.valueOf(current_month_budgeted.get(my_center.center_id).get('budgeted_consults'));
    		center_totals.budgeted_consults_current_month += Integer.valueOf(current_month_budgeted.get(my_center.center_id).get('budgeted_consults'));
    		holder = String.valueOf(current_month_budgeted.get(my_center.center_id).get('budgeted_close_rate'));
    		my_center.budgeted_close_rate_current_month = Decimal.valueOf(holder);
    		center_totals.budgeted_close_rate_current_month += Decimal.valueOf(holder);
    		//System.debug('Current Centers : ' + num_centers_current + ' this close rate : ' + current_month_budgeted.get(my_center.center_id).budgeted_close_rate__c + ' Total : ' + center_totals.budgeted_close_rate_current_month);    		
    	}
    	//Map Starts
    	//if(two_month_starts.get(my_center.center_name)<> null)
    	if(two_month_starts.get(my_center.center_id)<> null) 
    		my_center.starts_two_month = two_month_starts.get(my_center.center_id);
      //if(last_month_starts.get(my_center.center_name)<> null)
    	if(last_month_starts.get(my_center.center_id)<> null) 
    		my_center.starts_last_month = last_month_starts.get(my_center.center_id);
      //if(current_month_starts.get(my_center.center_name)<> null)
    	if(current_month_starts.get(my_center.center_id)<> null) 
    		my_center.starts_current_month = current_month_starts.get(my_center.center_id);
      //Map Cancels
      //if(two_month_cancels.get(my_center.center_name)<> null) 
      if(two_month_cancels.get(my_center.center_id)<> null)
    		my_center.cancels_two_month = two_month_cancels.get(my_center.center_id);
      //if(last_month_cancels.get(my_center.center_name)<> null)
      if(last_month_cancels.get(my_center.center_id)<> null) 
    		my_center.cancels_last_month = last_month_cancels.get(my_center.center_id);
    	//if(current_month_cancels.get(my_center.center_name)<> null)
    	if(current_month_cancels.get(my_center.center_id)<> null) 
    		my_center.cancels_current_month = current_month_cancels.get(my_center.center_id);
      //Map Consults
      //if(two_month_consults.get(my_center.center_name)<> null) 
      if(two_month_consults.get(my_center.center_id)<> null)
    		my_center.consults_two_month = two_month_consults.get(my_center.center_id);
      //if(last_month_consults.get(my_center.center_name)<> null)
    	if(last_month_consults.get(my_center.center_id)<> null) 
    		my_center.consults_last_month = last_month_consults.get(my_center.center_id);
    	//if(current_month_consults.get(my_center.center_name)<> null) 
    	if(current_month_consults.get(my_center.center_id)<> null)
    		my_center.consults_current_month = current_month_consults.get(my_center.center_id);
      //Map Consults GYB
      //if(two_month_consults.get(my_center.center_name)<> null)
      if(two_month_consults.get(my_center.center_id)<> null) 
    		my_center.gyb_consults_two_month = two_month_gyb_consults.get(my_center.center_id);
      //if(last_month_consults.get(my_center.center_name)<> null)
      if(last_month_consults.get(my_center.center_id)<> null) 
    		my_center.gyb_consults_last_month = last_month_gyb_consults.get(my_center.center_id);
      //if(current_month_consults.get(my_center.center_name)<> null)
    	if(current_month_consults.get(my_center.center_id)<> null) 
    		my_center.gyb_consults_current_month = current_month_gyb_consults.get(my_center.center_id);
    }
   	if(num_centers_two > 0)
   	  center_totals.budgeted_close_rate_two_month = center_totals.budgeted_close_rate_two_month/num_centers_two;
   	if(num_centers_last > 0)
  	  center_totals.budgeted_close_rate_last_month = center_totals.budgeted_close_rate_last_month/num_centers_last;
   	if(num_centers_current > 0)
  	  center_totals.budgeted_close_rate_current_month = center_totals.budgeted_close_rate_current_month/num_centers_current;
  }
    
  public CenterDrivers[] getall_centers() {
  	return all_centers;
  }
  
  public CenterDrivers getcenter_totals() {
  	return center_totals;
  }
}