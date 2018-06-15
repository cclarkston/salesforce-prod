/*modified by cm on 2015-06-04
  per data governance,  the cancel in definition is changing to close the loophole
  old defintion cancel_reason__c != null
*/

/*modified by cm on 6/28/2017
  cancel definition has changed again - sole field to determine a cancel is now cancel_date__c
*/
public without sharing class ctrl_OpsCSV {
  public String format;
  public String filename;
  public String action;
  public String Interval;
  public String Interval_filter;
  String all_filter = '';
  public Date sdate,edate;
  public Datetime sdate_time,edate_time;

  ID center_id;
  String sales_region;
  public String file_header = 'test';
  //Set<ID> account_id_list = new Set<ID>();
  Set<ID> user_filters = new Set<ID>();

  public ctrl_OpsCSV() {
  	if(test.isRunningTest())
      all_filter = ' limit 100';
  	if(apexpages.currentpage().getparameters().get('format')==null)
      format = '1';
    else
      format = apexpages.currentpage().getparameters().get('format');
    if(apexpages.currentpage().getparameters().get('action')==null)
      action = 'user';
    else
      action = apexpages.currentpage().getparameters().get('action');
    if(apexpages.currentpage().getparameters().get('interval')==null)
      interval = '1';
    else
      interval = apexpages.currentpage().getparameters().get('interval');
    Date dtoday = Date.today();
    if(format=='1')
      filename = 'past_due_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='2')
      filename = 'anticipated_payment_60_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='3')
      filename = 'anticipated_payment_next_month_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='4')
      filename = 'anticipated_payment_current_month_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='5')
      filename = 'collected_dollars_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='6')
      filename = 'refunded_dollars_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='7')
      filename = 'consults_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='8')
      filename = 'new_starts_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='9')
      filename = 'cancelled_starts_in_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='10')
      filename = 'cancelled_starts_out_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='11')
      filename = 'pipeline_30day_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='12')
      filename = 'pipeline_60day_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='13')
      filename = 'pipeline_90day_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='14')
      filename = 'pipeline_2ndconsult_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='15')
      filename = 'upsell_sold_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='16')
      filename = 'upsell_cancelled_in_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='17')
      filename = 'upsell_cancelled_out_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='18')
      filename = 'user_comission_report_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='19')
      filename = 'center_comission_report_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='20')
      filename = 'pending_starts_report_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='21')
      filename = 'bonus_tiers_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='22')
      filename = 'RSM_bonus_tiers_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='23')
      filename = 'PEC_Ranking_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='24')
      filename = 'callback_consults_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(format=='25')
      filename = 'non_comission_details_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(interval=='1') {
      if(apexpages.currentpage().getparameters().get('tfilter')==null)
        interval_filter = ' yesterday';
      else if(apexpages.currentpage().getparameters().get('tfilter')=='1')
        interval_filter = 'yesterday';
      else if(apexpages.currentpage().getparameters().get('tfilter')=='2')
        interval_filter = 'today';
    }
    if(interval=='2')
      interval_filter = ' this_month';
    if(interval=='3')
      interval_filter = ' this_quarter';
    if(interval=='4')
      //interval_filter = ' last_quarter';
      interval_filter = ' last_month';
    if(interval=='5')
      interval_filter = ' this_year';
    if(interval=='6') {
    	if(apexpages.currentpage().getparameters().get('sdate')==null) {
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Missing start date parameter');
        ApexPages.addMessage(myMsg);
		    System.assert(1==2);
    	}
	    else
	    	sdate = Date.valueof(apexpages.currentpage().getparameters().get('sdate'));
	    if(apexpages.currentpage().getparameters().get('edate')==null) {
	    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Missing end date parameter');
        ApexPages.addMessage(myMsg);
		    System.assert(1==2);
	    }
	    else
	    	edate = Date.valueof(apexpages.currentpage().getparameters().get('edate'));
	    sdate_time = Datetime.newInstance(sdate.year(), sdate.month(), sdate.day(), 0, 0, 0);
	    edate_time = Datetime.newInstance(edate.year(), edate.month(), edate.day(), 23, 59, 59);
    }
    if(action=='user') {
    	if(apexpages.currentpage().getparameters().get('asuser')==null)
		    user_filters.add(Userinfo.getUserID());
	    else
	    	user_filters.add(apexpages.currentpage().getparameters().get('asuser'));
    }
    if(action=='center') {
    	List<Center_Information__c> center_info = new list<Center_Information__c> ();
	    if(apexpages.currentpage().getparameters().get('ascenter')==null)
	      center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where PEC_1__c = :Userinfo.getUserId() or PEC_2__c = :Userinfo.getUserId()];
	    else
	      center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ascenter')];
	    System.debug('##Center - ASCENTER : ' + apexpages.currentpage().getparameters().get('ascenter'));
	    Integer cnt = 0;
	    for(Center_Information__c ci : center_info) {
      	if(cnt==0) {
      	  //make a list for account_id_list - this will be used as a filter on some of the metrics queries
      	  /*for(Account a : [select id from account where center__c = :ci.id]) {
      	  	account_id_list.add(a.id);
      	  }*/
      	  center_id = ci.id;
      	}
      	cnt++;
      	List<User> center_pec = [select id from user where center_pec__c = :ci.id];
      	for(User my_user : center_pec) {
      		user_filters.add(my_user.id);
      	}
      }
	  }
	  if(action=='region')
	  	sales_region = apexpages.currentpage().getparameters().get('aregion');
  }

  public transient CSVOutput[] csvout;

  public transient CSVsets[] csvset;

  public class CSVSets {
  	public CSVOutput[] csvfiles {get; set;}
  }

  public class CSVOutput {
  	public String output_line { get; set; }
  }

  public String getfilename() {
  	/*if(filename==null)
  	  filename = 'test.csv';*/
  	return filename;
  }

  public String getfile_header() {
  	return file_header;
  }

  /*public String ToString(Decimal Value) {
  	return Value.format();
  }*/

  public Comission_Line[] comission_report;
  public class Comission_Line {
  	public User userinfo {get; set;}
  	public List<User_Goals__c> budget_months {get; set;}
  	Integer report_month;
  	String center_name {get; set;}
  	ID Sales_Market {get; set;}
  	public Decimal monthly_collections {get;set;}
    public Integer num_months {get;set;}
  	public Decimal qtr_goal {get;set;}
  	public Decimal monthly_bonus {get; set;}
  	public Decimal monthly_goal {get; set;}
  	public Decimal individual_qtr_bonus {get; set;}
  	public Decimal center_qtr_bonus {get; set;}
  	public Decimal center_qtr_goal {get; set;}
  	public Decimal tier_1_floor {get; set;}
  	public Decimal tier_2_floor {get; set;}
  	public Decimal tier_3_floor {get; set;}
  	public Decimal tier_1_amount {get; set;}
  	public Decimal tier_2_amount {get; set;}
  	public Decimal tier_3_amount {get; set;}
  	public Decimal tier_3_qtr_amount {get; set;}
  	public Decimal tier_3_store {get; set;}
  	public Decimal tier_2_store {get; set;}
  	public Decimal true_close_rate {get; set;}
  	public Integer payout_tier {get; set;}
  	public Decimal current_payout {get; set;}
  	public Decimal current_payout_amount {get; set;}
  	public Decimal baseline_target {get; set;}

  	Decimal tier_1_rate = 0.01;
  	Decimal tier_2_rate = 0.035;
  	Decimal tier_3_rate = 0.035;
  	Decimal tier_3_qtr_rate = 0.01;

  	public Comission_Line(User my_user, List<User_Goals__c> my_budget, Integer rmonth) {

  		Map <Integer,Decimal> payout_map = new Map<Integer,Decimal>();
        payout_map.put(0,0.0000);
        payout_map.put(1,0.0025);
        payout_map.put(2,0.0050);
        payout_map.put(3,0.0100);
        payout_map.put(4,0.0127);
        payout_map.put(5,0.0154);
        payout_map.put(6,0.0182);
        payout_map.put(7,0.0225);
        payout_map.put(8,0.0268);
        payout_map.put(9,0.0325);


        this.true_close_rate = 0;
        this.payout_tier = 0;
        this.current_payout_amount = 0;
  		this.tier_1_floor = 0;
  		this.tier_2_floor = 0;
  		this.tier_3_floor = 0;
  		this.tier_1_amount = 0;
  		this.tier_2_amount = 0;
  		this.tier_3_amount = 0;
  		this.tier_3_qtr_amount = 0;
  		this.monthly_bonus = 0;
  		this.center_qtr_bonus = 0;
  		this.individual_qtr_bonus = 0;
  		this.userinfo = my_user;
  		this.budget_months = my_budget;
  		this.report_month = rmonth;
  		monthly_collections = 0;
  		num_months = 0;
  		qtr_goal = 0;
  		//work through the budget months
  		for(User_Goals__c bmonth : this.budget_months) {
  			if(bmonth.target_dollars__c<>null)
  			  if(bmonth.target_dollars__c>0)
  			    qtr_goal += bmonth.target_dollars__c;
  			  else
  			    qtr_goal += bmonth.sales_goal__c;
  			else
  			  qtr_goal += bmonth.sales_goal__c;
  		  //if the budget month = report month then calculate the monthly bonus
  		  if(bmonth.fiscal_month__c == rmonth) {
  		  	//new comp plan stuff - 2/24/2015 CM
            //don't divide by zero
            if(bmonth.consults__c!=null) {
              if(bmonth.consults__c > 0) {
                true_close_rate = (bmonth.starts__c==null?0:bmonth.starts__c) - (bmonth.Cancelled_Starts_Out__c==null?0:bmonth.cancelled_starts_out__c) - (bmonth.Cancelled_Starts_in__c==null?0:bmonth.cancelled_starts_in__c);
                true_close_rate = true_close_rate.divide(bmonth.consults__c,4, System.roundingmode.DOWN) * 100.00;
              }
  		    }
            baseline_target = bmonth.baseline_target__c==null?0:bmonth.baseline_target__c;
          	Decimal net_collections = 0;
  		  	if(bmonth.Collected_Dollars__c!=null)
			  net_collections += bmonth.Collected_Dollars__c;
			if(bmonth.GP_Collected_Fees__c!=null)
			  net_collections -= bmonth.GP_Collected_Fees__c;
			if(bmonth.Refunded_Dollars__c!=null)
			  net_collections -= bmonth.Refunded_Dollars__c;
		    if(bmonth.GP_Refunded_Fees__c!=null)
			  net_collections += bmonth.GP_Refunded_Fees__c;
			if(true_close_rate < (baseline_target-3.0) || baseline_target==0)
          	  this.payout_tier = 0;
          	else if(true_close_rate < (baseline_target-1.5))
          	  this.payout_tier = 1;
          	else if(true_close_rate < (baseline_target))
          	  this.payout_tier = 2;
          	else if(true_close_rate < (baseline_target+2))
          	  this.payout_tier = 3;
          	else if(true_close_rate < (baseline_target+4))
          	  this.payout_tier = 4;
          	else if(true_close_rate < (baseline_target+6))
          	  this.payout_tier = 5;
          	else if(true_close_rate < (baseline_target+9))
          	  this.payout_tier = 6;
          	else if(true_close_rate < (baseline_target+12))
          	  this.payout_tier = 7;
          	else if(true_close_rate < (baseline_target+16))
          	  this.payout_tier = 8;
          	else
          	  this.payout_tier = 9;
          	this.current_payout = payout_map.get(payout_tier);
          	this.current_payout_amount = current_payout * net_collections;

            //new comp plan stuff end
  		  	if(bmonth.target_dollars__c<>null)
  		  	  if(bmonth.target_dollars__c>0)
  			  	  this.monthly_goal = bmonth.target_dollars__c;
  			  	else
  			  	  this.monthly_goal = bmonth.sales_goal__c;
  				else
  			  	  this.monthly_goal = bmonth.sales_goal__c;
  		  	Integer individual_bonus = 1850;
  		  	if(this.userinfo.name=='Kelley Peterson')
  		  	  individual_bonus = 1250;
  		  	//10/11/2012 Cm - commenting this out per Ken.  Kim is now splitting wuith someone else
  		  	//if(this.userinfo.name=='Kim Middleton')
  		  	  //individual_bonus = 3085;
  		  	//did they qualify for the bonus
  		  	if(bmonth.target_rate__c > 85) {
  		  		//using 16.0 instead of 16 because it rounds otherwise.  interesting behavior
  		  		if(bmonth.target_rate__c > 100)
  		  		  this.monthly_bonus = (100-84) * (individual_bonus / 16.0);
  		  		else
  		  		  this.monthly_bonus = (bmonth.target_rate__c - 84) * (individual_bonus / 16.0);
  		  	}
  		  	else
  		  	  this.monthly_bonus = 0;
  		  	//new tier stuff
  		  	if(bmonth.tier_1_floor__c!=null) {
  		  	  this.tier_1_floor = bmonth.tier_1_floor__c;
  		  	  this.tier_2_floor = bmonth.tier_2_floor__c;
  		  	  this.tier_3_floor = bmonth.tier_3_floor__c;

			   //calculate tier 1 bonus
		  	  tier_1_amount = net_collections - tier_1_floor;
		  	  if(tier_1_amount > (tier_2_floor - tier_1_floor))
		  	    tier_1_amount = (tier_2_floor - tier_1_floor);
		  	  if(tier_1_amount <= 0)
		  	    tier_1_amount = 0;
		  	  tier_1_amount = tier_1_amount * tier_1_rate;

		  	  //calculate tier 2 bonus
		  	  Decimal tier_2_amount = net_collections - tier_2_floor;
		  	  /*if(tier_2_amount > (tier_3_floor - tier_2_floor))
		  	    tier_2_amount = (tier_3_floor - tier_2_floor);*/
		  	  if(tier_2_amount <= 0)
		  	    tier_2_amount = 0;
		  	  tier_2_amount = tier_2_amount * tier_2_rate;
		  	  if(tier_2_amount>0)
		  	    tier_2_store = tier_2_amount;

		  	  //calculate tier 3 bonus
		  	  /*Decimal tier_3_amount = net_collections - tier_3_floor;
		  	  if(tier_3_amount <= 0)
		  	    tier_3_amount = 0;
		  	  tier_3_qtr_amount = tier_3_amount * tier_3_qtr_rate;
		  	  tier_3_amount = tier_3_amount * tier_3_rate;
		  	  if(tier_3_amount>0)
		  	    tier_3_store = tier_3_amount;*/
  		  	}

  		  }
  		  //if the budget month <= report month then add towards the quarterly bonus calculation
  		  if(bmonth.fiscal_month__c <= rmonth) {
  		  	Decimal collections = 0;
  		  	Decimal gp_collections = 0;
  		  	Decimal refunded = 0;
  		  	Decimal gp_refunded = 0;

  		  	if(bmonth.collected_dollars__c<>null)
  		  	  collections = bmonth.collected_dollars__c;
  		  	if(bmonth.gp_collected_fees__c<>null)
  		  	  gp_collections = bmonth.gp_collected_fees__c;
  		  	if(bmonth.refunded_dollars__c<>null)
  		  	  refunded = bmonth.refunded_dollars__c;
  		  	if(bmonth.gp_refunded_fees__c<>null)
  		  	  gp_refunded = bmonth.gp_refunded_fees__c;
  		  	monthly_collections += collections - gp_collections - refunded + gp_refunded;
  		  	num_months++;
  		  }
  		}
  		if(this.tier_3_floor > 0 && monthly_collections > tier_3_floor)
  		  tier_3_qtr_amount = (monthly_collections - tier_3_floor) * tier_3_qtr_rate;


  		//calculation the revenue collected for the quarter
  		Decimal projected_revenue = 0;
  		if(num_months>0)
  		  projected_revenue = (monthly_collections/num_months) * 3;
  		if(projected_revenue > qtr_goal)
  		  //modified by cm on 2012-4-27
  		  //Based on a quick discussion with Waltzer,  we will only be accruing for the portion of the
  		  //quarterly bonus that they have earned so far versus a projection for the full 3 months.
  		  this.individual_qtr_bonus = (((projected_revenue - qtr_goal) *.04)/3.0) * num_months;
  		else
  		  this.individual_qtr_bonus = 0;
  	}
  }

  public String check_for_null(String initial_val) {
  	String return_val;
  	if(initial_val==null)
  	  return_val = '';
  	else
  	  return_val = initial_val;
  	return return_val;
  }

  public Integer getstart_month(Integer report_month) {
  	Integer smonth = 0;
  	if(report_month>=1 && report_month<=3)
  	  smonth = 1;
  	else if(report_month>=4 && report_month<=6)
  	  smonth = 4;
  	else if(report_month>=7 && report_month<=9)
  	  smonth = 7;
  	if(report_month>=10 && report_month<=12)
  	  smonth = 10;
  	return smonth;
  }

  public Integer getend_month(Integer report_month) {
  	Integer emonth = 0;
  	if(report_month>=1 && report_month<=3)
  	  emonth = 3;
  	else if(report_month>=4 && report_month<=6)
  	  emonth = 6;
  	else if(report_month>=7 && report_month<=9)
  	  emonth = 9;
  	if(report_month>=10 && report_month<=12)
  	  emonth = 12;
  	return emonth;
  }

  public CSVsets[] getcsvout() {
    csvset = new CSVSets[] {};
    CSVSets working_csvset = new CSVSets();
  	csvout = new CSVOutput[] {};
  	String anticipated_query_filter;
  	if(apexpages.currentpage().getparameters().get('pfilter')==null)
  	  anticipated_query_filter = '(\'Anticipated\',\'HCF in Process\')';
		if(apexpages.currentpage().getparameters().get('pfilter')=='all')
		  anticipated_query_filter = '(\'Anticipated\',\'HCF in Process\')';
		if(apexpages.currentpage().getparameters().get('pfilter')=='prom')
		  anticipated_query_filter = '(\'Anticipated Promise Note\')';
    //modified by cm on 2012-11-29
    //I've added the filter to ignore all payments tied to an opportunity record that would be considered "cancelled"
    //based on a discussion with Chelsea and Vince
  	if(format=='1') {
  		//old user filter opportunity__r.ownerid
  		file_header = '"Prost Exam : Name","Payment Date","Payment_Amount","Finance Fee","Net Collection Amount","Payment Status","Payment Type","Prost Exam Date","Center Location","Created By","Prost Exam : Total Amount","Prost Exam : Total Payments","Prost Owner"';
  	  List<CCPayment__c> my_rs = new list<CCPayment__c> ();
  	  String base_query = 'Select c.payment_status__c, c.payment_type__c, c.payment_amount__c, c.finance_fee__c, ' +
				' c.Net_Collection_Amount__c, c.opportunity__r.Name, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
				' c.opportunity__r.createddate, c.opportunity__r.closedate, c.opportunity__r.negotiated_total_amount__c, c.payment_date__c, ' +
				' c.opportunity__r.total_payments__c, c.opportunity__r.owner.name From CCPayment__c c where ' +
				' opportunity__r.cancel_date__c = null and ' +
				' c.payment_status__c in ' + anticipated_query_filter + ' and c.payment_date__c < today';
			if(action=='center')
        base_query += ' and opportunity__r.account.center__c = :center_id';
      if(action=='region')
        base_query += ' and opportunity__r.account.center__r.sales_region__c = :sales_region';
			if(action=='user')
			  base_query += ' and pec__c in : user_filters';
			System.debug('Running Query : ' + base_query + all_filter);

  		for(CCPayment__c my_payments : database.query(base_query + all_filter)) {
				CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = '"' + my_payments.opportunity__r.name  + '",';
				csv_line.output_line += '"' + my_payments.payment_date__c + '",';
				csv_line.output_line += '"' + my_payments.Payment_Amount__c  + '",';
				if(my_payments.Finance_Fee__c==null)
				  csv_line.output_line += '"0",';
				else
				  csv_line.output_line += '"' + my_payments.Finance_Fee__c  + '",';
				csv_line.output_line += '"' + my_payments.Net_Collection_Amount__c  + '",';
				csv_line.output_line += '"' + my_payments.payment_status__c  + '",';
				csv_line.output_line += '"' + my_payments.payment_type__c  + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.closedate  + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.account.center_location__c + '",';
				csv_line.output_line += '"' + my_payments.createdby.name + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.negotiated_total_amount__c + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.total_payments__c + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.owner.name + '"';
				csvout.add(csv_line);
			}
  	}
  	//modified by cm on 2012-11-29
    //I've added the filter to ignore all payments tied to an opportunity record that would be considered "cancelled"
    //based on a discussion with Chelsea and Vince
  	if(format=='2' || format=='3' || format=='4') {
  		file_header = '"Prost Exam : Name","Payment Date","Payment_Amount","Finance Fee","Net Collection Amount","Payment Status","Payment Type","Prost Exam Date","Center Location","Created By","Prost Exam : Total Amount","Prost Exam : Total Payments","Prost Owner"';
  		String base_query = 'Select c.payment_status__c, c.payment_type__c, c.payment_amount__c, c.finance_fee__c, ' +
			  ' c.Net_Collection_Amount__c, c.opportunity__r.Name, c.opportunity__r.account.center_location__c, c.createdby.name,' +
				' c.opportunity__r.createddate, c.opportunity__r.negotiated_total_amount__c, c.opportunity__r.owner.name, c.payment_date__c, c.opportunity__r.closedate,' +
				' c.opportunity__r.total_payments__c  From CCPayment__c c  where ' +
				' opportunity__r.cancel_date__c = null and ' +
        ' c.payment_status__c in ' + anticipated_query_filter + ' and c.payment_date__c ';
      if(format=='2')
        base_query += ' > next_month';
      if(format=='3')
        base_query += ' = next_month';
      if(format=='4')
        base_query += ' = this_month';
      if(action=='center')
        base_query += ' and opportunity__r.account.center__c = :center_id';
      if(action=='region')
        base_query += ' and opportunity__r.account.center__r.sales_region__c = :sales_region';
      if(action=='user')
        base_query += ' and pec__c in : user_filters';
      for(CCPayment__c my_payments : database.query(base_query + all_filter)) {
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = '"' + my_payments.opportunity__r.name  + '",';
				csv_line.output_line += '"' + my_payments.payment_date__c + '",';
				csv_line.output_line += '"' + my_payments.Payment_Amount__c  + '",';
				if(my_payments.Finance_Fee__c==null)
				  csv_line.output_line += '"0",';
				else
				  csv_line.output_line += '"' + my_payments.Finance_Fee__c  + '",';
				csv_line.output_line += '"' + my_payments.Net_Collection_Amount__c  + '",';
				csv_line.output_line += '"' + my_payments.payment_status__c  + '",';
				csv_line.output_line += '"' + my_payments.payment_type__c  + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.closedate  + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.account.center_location__c + '",';
				csv_line.output_line += '"' + my_payments.createdby.name + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.negotiated_total_amount__c + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.total_payments__c + '",';
				csv_line.output_line += '"' + my_payments.opportunity__r.owner.name + '"';
				csvout.add(csv_line);
      }
  	}

  	if(format=='25') {
  	  file_header = 'Patient ID, Patient Name, Payment Date, Payment Amount, Payment Type, Payment Status, Finance Fee, Net Collection Amount, Center, Created By, Sales Order';
  	  String base_query = 'Select p.cc_sales_order__c, p.cc_sales_order__r.name, p.Private_Practice_Patient__c, p.Opportunity__c, p.Account__c, p.private_practice_patient__r.full_name__c,p.opportunity__r.name, p.account__r.name, ' +
  	    'payment_date__c,payment_amount__c, finance_fee__c, net_collection_amount__c, payment_type__c,payment_status__c, center_location__c, createdby.name From Private_Practice_Payment__c p where p.payment_status_formula__c in (\'Collected\',\'Refunded\')' +
  	    ' and payment_date__c = ' + interval_filter;
  	  if(action=='center')
  	    base_query += ' and p.center_id__c = :center_id';
  	  if(action=='region')
  	    base_query += ' and (p.private_practice_patient__r.center__r.sales_region__c = :sales_region or p.account__r.center__r.sales_region__c = :sales_region or p.opportunity__r.account.center__r.sales_region__c = :sales_region)';
  	  if(action=='user')
  	    base_query += ' and p.createdbyid in :user_filters';
  	  for(Private_Practice_Payment__c my_payment : database.query(base_query + all_filter)) {
  	  	String patient_id = '';
  	  	String patient_name = '';
  	  	if(my_payment.private_practice_patient__c!=null) {
  	  	  patient_name =  my_payment.private_practice_patient__r.full_name__c;
  	  	  patient_id = my_payment.private_practice_patient__c;
  	  	}
  	  	if(my_payment.account__c!=null) {
  	  	  patient_name = my_payment.account__r.name;
  	  	  patient_id = my_payment.account__c;
  	  	}
  	  	if(my_payment.opportunity__c!=null) {
  	  	  patient_name = my_payment.opportunity__r.name;
  	  	  patient_id = my_payment.opportunity__c;
  	  	}
	    CSVOutput csv_line = new CSVOutput();
		csv_line.output_line = patient_id  + ',';
		csv_line.output_line += '"' + patient_name + '",';
		csv_line.output_line += my_payment.Payment_date__c  + ',';
		csv_line.output_line += my_payment.payment_amount__c  + ',';
	    csv_line.output_line += my_payment.payment_type__c  + ',';
		csv_line.output_line += my_payment.payment_status__c  + ',';
		csv_line.output_line += (my_payment.finance_fee__c==null?'0':String.valueof(my_payment.finance_fee__c))  + ',';
		csv_line.output_line += my_payment.net_collection_amount__c  + ',';
		csv_line.output_line += (my_payment.center_location__c==null?' ':my_payment.center_location__c)  + ',';
		csv_line.output_line += '"' + my_payment.createdby.name + '",';
		csv_line.output_line += (my_payment.cc_sales_order__c==null?'':my_payment.cc_sales_order__r.name);
    	csvout.add(csv_line);
	  }
  	}

  	if(format=='5') {
  		file_header = 'Prost Exam : Name,Payment Date,Payment_Amount,Finance Fee,GP Fee Amount,Net Collection Amount,Net Collection minus GP Fee,Payment Type,Prost Exam Date,Center Location,Created By,Prost Owner,Payment Status,Prefered Track,Final Track,GP Fee Rate';
  		if(interval_filter==' this_year') {
  			for(Integer month_cnt=1;month_cnt<=12;month_cnt++) {
  				Date start_date = date.newinstance(System.today().year(),month_cnt,1);
  			  Date end_date = start_date.addMonths(1);
	  			String base_query = 'Select c.opportunity__r.Name, c.payment_date__c, c.payment_type__c, c.payment_amount__c,' +
		        ' c.finance_fee__c, c.Net_Collection_Amount__c, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
		        ' c.opportunity__r.closedate, c.opportunity__r.owner.name, c.payment_status__c,c.Net_Collection_Amount_minus_GP__c, c.GP_Fee_Amount__c, ' +
		        ' c.opportunity__r.Referral_track__c, c.opportunity__r.GP_Fee_Rate__c, c.opportunity__r.Final_Referral_Track__c ' +
		        ' From CCPayment__c  c where c.payment_status_formula__c = \'Collected\' ' +
		        ' and c.payment_date__c >= :start_date and c.payment_date__c < :end_date' ;
		      if(action=='center')
		        base_query += ' and opportunity__r.account.center__c = :center_id';
		      if(action=='region')
		        base_query += ' and opportunity__r.account.center__r.sales_region__c = :sales_region';
		      if(action=='user')
		        base_query += ' and pec__c in : user_filters';
		      for(CCPayment__c my_payments : database.query(base_query + all_filter)) {
		      	CSVOutput csv_line = new CSVOutput();
						csv_line.output_line = my_payments.opportunity__r.name  + ',';
						csv_line.output_line += my_payments.payment_date__c + ',';
						csv_line.output_line += my_payments.Payment_Amount__c  + ',';
						csv_line.output_line += (my_payments.Finance_Fee__c==null ? '0' : String.valueof(my_payments.Finance_Fee__c))  + ',';
					    csv_line.output_line += my_payments.gp_fee_amount__c  + ',';
						csv_line.output_line += my_payments.Net_Collection_Amount__c  + ',';
						csv_line.output_line += my_payments.Net_Collection_Amount_minus_GP__c  + ',';
						csv_line.output_line += my_payments.payment_type__c  + ',';
						csv_line.output_line += my_payments.opportunity__r.closedate  + ',';
						csv_line.output_line += my_payments.opportunity__r.account.center_location__c + ',';
						csv_line.output_line += my_payments.createdby.name + ',';
						csv_line.output_line += my_payments.opportunity__r.owner.name + ',';
						csv_line.output_line += my_payments.payment_status__c + ',';
						csv_line.output_line += (my_payments.opportunity__r.Referral_track__c==null ? '' : my_payments.opportunity__r.Referral_track__c) + ',';
						csv_line.output_line += (my_payments.opportunity__r.Final_Referral_Track__c==null ? '' : my_payments.opportunity__r.Final_Referral_Track__c) + ',';
						csv_line.output_line += (my_payments.opportunity__r.GP_Fee_Rate__c==null ? '0' : String.valueof(my_payments.opportunity__r.GP_Fee_Rate__c));
						csvout.add(csv_line);
						if(csvout.size()>20) {
							working_csvset.csvfiles = csvout;
	            csvset.add(working_csvset);
	            working_csvset = new CSVSets();
  						csvout = new CSVOutput[] {};
						}
		      }
	      }
  		}
  		else {
	  		String base_query = 'Select c.opportunity__r.Name, c.payment_date__c, c.payment_type__c, c.payment_amount__c,' +
	        ' c.finance_fee__c, c.Net_Collection_Amount__c, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
	        ' c.opportunity__r.closedate, c.opportunity__r.owner.name, c.payment_status__c,c.Net_Collection_Amount_minus_GP__c, c.GP_Fee_Amount__c, ' +
		        ' c.opportunity__r.Referral_track__c, c.opportunity__r.GP_Fee_Rate__c, c.opportunity__r.Final_Referral_Track__c ' +
		        ' From CCPayment__c  c where c.payment_status_formula__c = \'Collected\' and c.payment_date__c = ' + interval_filter;
	      if(interval=='6')
		      base_query = 'Select c.opportunity__r.Name, c.payment_date__c, c.payment_type__c, c.payment_amount__c,' +
		        ' c.finance_fee__c, c.Net_Collection_Amount__c, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
		        ' c.opportunity__r.closedate, c.opportunity__r.owner.name, c.payment_status__c ,c.Net_Collection_Amount_minus_GP__c, c.GP_Fee_Amount__c, ' +
		        ' c.opportunity__r.Referral_track__c, c.opportunity__r.GP_Fee_Rate__c, c.opportunity__r.Final_Referral_Track__c ' +
		        ' From CCPayment__c  c where c.payment_status_formula__c = \'Collected\'' +
		        ' and c.payment_date__c >= :sdate and c.payment_date__c < :edate';
	      if(action=='center')
	        base_query += ' and opportunity__r.account.center__c = :center_id';
	      if(action=='region')
	        base_query += ' and opportunity__r.account.center__r.sales_region__c = :sales_region';
	      if(action=='user')
	        base_query += ' and pec__c in : user_filters';
	      for(CCPayment__c my_payments : database.query(base_query + all_filter)) {
	      	CSVOutput csv_line = new CSVOutput();
					csv_line.output_line = my_payments.opportunity__r.name  + ',';
						csv_line.output_line += my_payments.payment_date__c + ',';
						csv_line.output_line += my_payments.Payment_Amount__c  + ',';
						csv_line.output_line += (my_payments.Finance_Fee__c==null ? '0' : String.valueof(my_payments.Finance_Fee__c))  + ',';
					    csv_line.output_line += my_payments.gp_fee_amount__c  + ',';
						csv_line.output_line += my_payments.Net_Collection_Amount__c  + ',';
						csv_line.output_line += my_payments.Net_Collection_Amount_minus_GP__c  + ',';
						csv_line.output_line += my_payments.payment_type__c  + ',';
						csv_line.output_line += my_payments.opportunity__r.closedate  + ',';
						csv_line.output_line += my_payments.opportunity__r.account.center_location__c + ',';
						csv_line.output_line += my_payments.createdby.name + ',';
						csv_line.output_line += my_payments.opportunity__r.owner.name + ',';
						csv_line.output_line += my_payments.payment_status__c + ',';
						csv_line.output_line += (my_payments.opportunity__r.Referral_track__c==null ? '' : my_payments.opportunity__r.Referral_track__c) + ',';
						csv_line.output_line += (my_payments.opportunity__r.Final_Referral_Track__c==null ? '' : my_payments.opportunity__r.Final_Referral_Track__c) + ',';
						csv_line.output_line += (my_payments.opportunity__r.GP_Fee_Rate__c==null ? '0' : String.valueof(my_payments.opportunity__r.GP_Fee_Rate__c));
					csvout.add(csv_line);
	      }
  		}
  	}

  	if(format=='6') {
  		file_header = 'Prost Exam : Name,Payment Date,Payment_Amount,Finance Fee,GP Fee Amount,Net Collection Amount,Net Collection minus GP Fee,Payment Type,Prost Exam Date,Center Location,Created By,Prost Owner,Payment Status,Prefered Track,Final Track,GP Fee Rate,Refund Reason';
  		if(interval_filter==' this_year') {
  			for(Integer month_cnt=1;month_cnt<=12;month_cnt++) {
  				Date start_date = date.newinstance(System.today().year(),month_cnt,1);
  			  Date end_date = start_date.addMonths(1);
  			  String base_query = 'Select c.opportunity__r.Name, c.payment_date__c, c.payment_type__c, c.payment_amount__c, c.refund_reason__c, ' +
		        ' c.finance_fee__c, c.Net_Collection_Amount__c, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
		        ' c.opportunity__r.closedate, c.opportunity__r.owner.name,c.payment_status__c,c.Net_Collection_Amount_minus_GP__c, c.GP_Fee_Amount__c, ' +
		        ' c.opportunity__r.Referral_track__c, c.opportunity__r.GP_Fee_Rate__c, c.opportunity__r.Final_Referral_Track__c ' +
		        ' From CCPayment__c  c where c.payment_status_formula__c = \'Refunded\' and ' +
		        ' c.payment_date__c >= :start_date and c.payment_date__c < :end_date';
		      if(action=='center')
		        base_query += ' and opportunity__r.account.center__c = :center_id';
		      if(action=='region')
		        base_query += ' and opportunity__r.account.center__r.sales_region__c = :sales_region';
		      if(action=='user')
		        base_query += ' and pec__c in : user_filters';
		      for(CCPayment__c my_payments : database.query(base_query + all_filter)) {
		      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = my_payments.opportunity__r.name  + ',';
				csv_line.output_line += my_payments.payment_date__c + ',';
				csv_line.output_line += my_payments.Payment_Amount__c  + ',';
				csv_line.output_line += (my_payments.Finance_Fee__c==null ? '0' : String.valueof(my_payments.Finance_Fee__c))  + ',';
				csv_line.output_line += my_payments.gp_fee_amount__c  + ',';
				csv_line.output_line += my_payments.Net_Collection_Amount__c  + ',';
				csv_line.output_line += my_payments.Net_Collection_Amount_minus_GP__c  + ',';
				csv_line.output_line += my_payments.payment_type__c  + ',';
				csv_line.output_line += my_payments.opportunity__r.closedate  + ',';
				csv_line.output_line += my_payments.opportunity__r.account.center_location__c + ',';
				csv_line.output_line += my_payments.createdby.name + ',';
				csv_line.output_line += my_payments.opportunity__r.owner.name + ',';
				csv_line.output_line += my_payments.payment_status__c + ',';
				csv_line.output_line += (my_payments.opportunity__r.Referral_track__c==null ? '' : my_payments.opportunity__r.Referral_track__c) + ',';
				csv_line.output_line += (my_payments.opportunity__r.Final_Referral_Track__c==null ? '' : my_payments.opportunity__r.Final_Referral_Track__c) + ',';
				csv_line.output_line += (my_payments.opportunity__r.GP_Fee_Rate__c==null ? '0' : String.valueof(my_payments.opportunity__r.GP_Fee_Rate__c)) + ',';
				csv_line.output_line += my_payments.refund_reason__c;
				csvout.add(csv_line);
		      }
  			}
  		}
  	  else {
	  	  String base_query = 'Select c.opportunity__r.Name, c.payment_date__c, c.payment_type__c, c.payment_amount__c, c.refund_reason__c, ' +
	        ' c.finance_fee__c, c.Net_Collection_Amount__c, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
	        ' c.opportunity__r.closedate, c.opportunity__r.owner.name,c.payment_status__c,c.Net_Collection_Amount_minus_GP__c, c.GP_Fee_Amount__c, ' +
		    ' c.opportunity__r.Referral_track__c, c.opportunity__r.GP_Fee_Rate__c, c.opportunity__r.Final_Referral_Track__c ' +
		    ' From CCPayment__c  c where c.payment_status_formula__c = \'Refunded\' and c.payment_date__c = ' + interval_filter;
	      if(interval=='6')
		      base_query = 'Select c.opportunity__r.Name, c.payment_date__c, c.payment_type__c, c.payment_amount__c, c.refund_reason__c, ' +
		        ' c.finance_fee__c, c.Net_Collection_Amount__c, c.opportunity__r.account.center_location__c, c.createdby.name, ' +
		        ' c.opportunity__r.closedate, c.opportunity__r.owner.name,c.payment_status__c,c.Net_Collection_Amount_minus_GP__c, c.GP_Fee_Amount__c, ' +
		        ' c.opportunity__r.Referral_track__c, c.opportunity__r.GP_Fee_Rate__c, c.opportunity__r.Final_Referral_Track__c  ' +
		        ' From CCPayment__c  c where c.payment_status_formula__c = \'Refunded\'' +
		        ' and c.payment_date__c >= :sdate and c.payment_date__c < :edate';
	      if(action=='center')
	        base_query += ' and opportunity__r.account.center__c = :center_id';
		    if(action=='region')
		      base_query += ' and opportunity__r.account.center__r.sales_region__c = :sales_region';
	      if(action=='user')
	        base_query += ' and pec__c in : user_filters';
	      for(CCPayment__c my_payments : database.query(base_query + all_filter)) {
	      	CSVOutput csv_line = new CSVOutput();
			csv_line.output_line = my_payments.opportunity__r.name  + ',';
			csv_line.output_line += my_payments.payment_date__c + ',';
			csv_line.output_line += my_payments.Payment_Amount__c  + ',';
			csv_line.output_line += (my_payments.Finance_Fee__c==null ? '0' : String.valueof(my_payments.Finance_Fee__c))  + ',';
			csv_line.output_line += my_payments.gp_fee_amount__c  + ',';
			csv_line.output_line += my_payments.Net_Collection_Amount__c  + ',';
			csv_line.output_line += my_payments.Net_Collection_Amount_minus_GP__c  + ',';
			csv_line.output_line += my_payments.payment_type__c  + ',';
			csv_line.output_line += my_payments.opportunity__r.closedate  + ',';
			csv_line.output_line += my_payments.opportunity__r.account.center_location__c + ',';
			csv_line.output_line += my_payments.createdby.name + ',';
			csv_line.output_line += my_payments.opportunity__r.owner.name + ',';
			csv_line.output_line += my_payments.payment_status__c + ',';
			csv_line.output_line += (my_payments.opportunity__r.Referral_track__c==null ? '' : my_payments.opportunity__r.Referral_track__c) + ',';
			csv_line.output_line += (my_payments.opportunity__r.Final_Referral_Track__c==null ? '' : my_payments.opportunity__r.Final_Referral_Track__c) + ',';
			csv_line.output_line += (my_payments.opportunity__r.GP_Fee_Rate__c==null ? '0' : String.valueof(my_payments.opportunity__r.GP_Fee_Rate__c)) + ',';
			csv_line.output_line += my_payments.refund_reason__c;
			csvout.add(csv_line);
	      }
  	  }
  	}

  	if(format=='7' || format=='24') {
  	  String callback_check = 'false';
  	  if(format=='24')
  	    callback_check = 'true';
  	  String user_filter = '';
  	  String base_query = 'select ' +
			  'scheduled_lead__r.name, ' +
			  'scheduled_account__r.name, ' +
			  'consult_room__r.center_information__r.name, ' +
			  'apt_date__c, ' +
			  'start_hour__c, ' +
			  'start_minute__c, ' +
			  'consult_pec__r.name, ' +
			  'consult_show_status__c, ' +
			  'scheduled_lead__r.pre_screen__c, ' +
			  'scheduled_account__r.pre_screen__c, ' +
			  'scheduled_lead__r.convertedaccount.owner.name, ' +
			  'scheduled_lead__r.convertedaccount.financing_result__c, ' +
			  'scheduled_lead__r.convertedaccount.consult_result__c,' +
			  'scheduled_account__r.owner.name, ' +
			  'scheduled_account__r.financing_result__c, ' +
			  'scheduled_account__r.consult_result__c, ' +
			  'scheduled_account__c, ' +
			  'scheduled_lead__c, ' +
			  'consult_room__r.name, ' +
			  'scheduled_lead__r.convertedaccount.createddate, ' +
			  'scheduled_account__r.createddate ' +
			'from  ' +
			  'Consult_Inventory__c c ' +
			'where ' +
			  'isvalidcallback__c = ' + callback_check + ' and consult_room__r.room_type__c != \'Practice\' and active__c = true ' +
			  'and arrival_time__c != null ' +
			  'and c.apt_date__c = ' + interval_filter;
			if(interval=='6')
			  base_query = 'select ' +
				  'scheduled_lead__r.name, ' +
				  'scheduled_account__r.name, ' +
				  'consult_room__r.center_information__r.name, ' +
				  'apt_date__c, ' +
				  'start_hour__c, ' +
				  'start_minute__c, ' +
				  'consult_pec__r.name, ' +
				  'consult_show_status__c, ' +
				  'scheduled_lead__r.pre_screen__c, ' +
				  'scheduled_account__r.pre_screen__c, ' +
				  'scheduled_lead__r.convertedaccount.owner.name, ' +
				  'scheduled_lead__r.convertedaccount.financing_result__c, ' +
				  'scheduled_lead__r.convertedaccount.consult_result__c,' +
				  'scheduled_account__r.owner.name, ' +
				  'scheduled_account__r.financing_result__c, ' +
				  'scheduled_account__r.consult_result__c, ' +
				  'scheduled_account__c, ' +
				  'scheduled_lead__c, ' +
				  'consult_room__r.name, ' +
				  'scheduled_lead__r.convertedaccount.createddate, ' +
				  'scheduled_account__r.createddate ' +
				'from  ' +
				  'Consult_Inventory__c c ' +
				'where ' +
				  'isvalidcallback__c = ' + callback_check + ' and consult_room__r.room_type__c != \'Practice\' and active__c = true ' +
				  'and arrival_time__c != null ' +
				  'and c.apt_date__c >= :sdate and c.apt_date__c <= :edate' ;
      if(action=='center')
        base_query += ' and c.consult_room__r.center_information__c = :center_id ';
      else if(action=='region')
        base_query += ' and c.consult_room__r.center_information__r.sales_region__c = :sales_region ';
      /*modified by cm on 2015-03-30
      Consult Inventory is being adjusted at the user level to go with the person assigned as the consult PEC.  Change will be effective from 4/1/2015.
       I'll have to update the piece for last month (interval 4),  on 5/1
      */
      else if(action=='user' && (interval=='4' || interval=='5'))
        user_filter = ' and ((apt_date__c < 2015-04-01 and (scheduled_lead__r.convertedaccount.ownerid in :user_filters or scheduled_account__r.ownerid in :user_filters)) or (apt_date__c >= 2015-04-01 and consult_pec__c in :user_filters)) ';
      else if(action=='user')
        user_filter = ' and consult_pec__c in :user_filters ';
      else
        base_query += ' and c.consult_room__r.center_information__r.type__c not in (\'Affiliate\') ';
      file_header = '"Consult Name","Center Location","Consult Date","Consult Time","Consult Room","Consult PEC","Consult Status","Financed","Account Owner","Consult Result"';
      List<Consult_Inventory__c> all_consults;
      //this shouldn't matter now - I revised the filter to handle it both ways.
      /*if(action=='user' && interval=='5') {
      	all_consults = database.query(base_query  + user_filter + all_filter);
      	System.debug('All Consults ' + all_consults.size());
      	user_filter = ' and consult_pec__c in :user_filters ';
      	for(Consult_Inventory__c extra_consults : database.query(base_query + user_filter + ' and apt_date__c >= 2015-04-01' + all_filter )) {
      	  all_consults.add(extra_consults);
      	}
      	System.debug('All Consults ' + all_consults.size());
      }
      else */
        all_consults = database.query(base_query + user_filter + all_filter );
      for(Consult_Inventory__c my_consult : all_consults) {
      	CSVOutput csv_line = new CSVOutput();
      	if(my_consult.scheduled_lead__c==null)
				  csv_line.output_line = '"' + my_consult.scheduled_account__r.name  + '",';
				else
				  csv_line.output_line = '"' + my_consult.scheduled_lead__r.name  + '",';
				csv_line.output_line += '"' + my_consult.consult_room__r.center_information__r.name + '",';
				csv_line.output_line += '"' + my_consult.apt_date__c + '",';
				csv_line.output_line += '"' + my_consult.start_hour__c + ':' + my_consult.start_minute__c + '",';
				csv_line.output_line += '"' + my_consult.consult_room__r.name + '",';
				csv_line.output_line += '"' + my_consult.consult_pec__r.name + '",';
				csv_line.output_line += '"' + my_consult.consult_show_status__c + '",';
				//removing this to keep colors hidden - 12/9/2014
				/*if(my_consult.scheduled_lead__c==null)
				  csv_line.output_line += '"' + my_consult.scheduled_account__r.pre_screen__c + '",';
				else
				  csv_line.output_line += '"' + my_consult.scheduled_lead__r.pre_screen__c + '",';*/
			  String finance_result = '';
				if(my_consult.scheduled_lead__c==null)
				  finance_result = my_consult.scheduled_account__r.financing_result__c;
				else
				  finance_result = my_consult.scheduled_lead__r.convertedaccount.financing_result__c;
				if(finance_result == 'Approved Less Than 50%' || finance_result == 'Approved Greater or Equal to 50%' || finance_result == 'Approved Full Amount' || finance_result == 'Declined')
				  csv_line.output_line += '"Yes",';
				else
				  csv_line.output_line += '"No",';
				if(my_consult.scheduled_lead__c==null)
				  csv_line.output_line += '"' + my_consult.scheduled_account__r.owner.name + '",';
				else
				  csv_line.output_line += '"' + my_consult.scheduled_lead__r.convertedaccount.owner.name + '",';
				/*if(my_consult.scheduled_lead__c==null)
				  csv_line.output_line += '"' + my_consult.scheduled_account__r.createddate + '",';
				else
				  csv_line.output_line += '"' + my_consult.scheduled_lead__r.convertedaccount.createddate + '",';*/
				if(my_consult.scheduled_lead__c==null)
				  csv_line.output_line += '"' + my_consult.scheduled_account__r.consult_result__c + '"';
				else
				  csv_line.output_line += '"' + my_consult.scheduled_lead__r.convertedaccount.consult_result__c + '"';
				csvout.add(csv_line);
      }
  	}

  	/*
  	modified by cm on 2014-12-22
  	Adjusting for the starts definiton changes
  	*/
  	if(format=='8') {
  	  file_header = '"Prost Name","Owner","Created By","Created Date","Start Date","Center","Stage","Completed Stage","Treatment Plan","Negotiated Amount","Total Payments","Total Refund","Outstanding Balance","Value in TCR"';
  	  String base_query = 'select o.Name, o.owner.name, o.createdby.name, o.createddate, o.account.pre_screen__c, ' +
        ' o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c, o.prosth_exam_paid_date__c, ' +
        ' o.outstanding_balance__c, o.preliminary_treatment_plan__c, o.completed_stage__c, o.account.center_location__c, o.Start_Value__c from opportunity o ' +
        ' where o.is_Valid_Start__c = true and o.prosth_exam_paid_date__c = ' + interval_filter;
      if(interval=='6')
        base_query = 'select o.Name, o.owner.name, o.createdby.name, o.createddate, o.account.pre_screen__c, ' +
	        ' o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c, o.prosth_exam_paid_date__c, ' +
	        ' o.outstanding_balance__c, o.preliminary_treatment_plan__c, o.completed_stage__c, o.account.center_location__c, o.Start_Value__c from opportunity o ' +
	        ' where o.is_Valid_Start__c = true and o.prosth_exam_paid_date__c >= :sdate and o.prosth_exam_paid_date__c <= :edate ' ;
      if(action=='center')
        base_query += ' and o.account.center__c = :center_id';
      else if(action=='region')
        base_query += ' and o.account.center__r.sales_region__c = :sales_region';
      else if(action=='user')
        base_query += ' and o.ownerid in : user_filters';
      else
        base_query += ' and account.center__r.type__c not in (\'Affiliate\')';
      for(Opportunity my_ops : database.query(base_query + all_filter)) {
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = '"' + my_ops.name  + '",';
				csv_line.output_line += '"' + my_ops.owner.name  + '",';
				csv_line.output_line += '"' + my_ops.createdby.name  + '",';
				csv_line.output_line += '"' + my_ops.createddate  + '",';
			    csv_line.output_line += '"' + my_ops.prosth_exam_paid_date__c  + '",';
				csv_line.output_line += '"' + my_ops.account.center_location__c + '",';
				//removing the colors - 12/9/2014 CM
				//csv_line.output_line += '"' + my_ops.account.pre_screen__c  + '",';
				csv_line.output_line += '"' + my_ops.stagename  + '",';
				if(my_ops.completed_stage__c==null)
				  csv_line.output_line += '"",';
				else
				  csv_line.output_line += '"' + my_ops.completed_stage__c  + '",';
				csv_line.output_line += '"' + my_ops.preliminary_treatment_plan__c  + '",';
				csv_line.output_line += '"' + my_ops.negotiated_total_amount__c  + '",';
				csv_line.output_line += '"' + my_ops.total_payments__c  + '",';
				if(my_ops.refund_amount__c==null)
				  csv_line.output_line += '"0",';
				else
				  csv_line.output_line += '"' + my_ops.refund_amount__c  + '",';
				csv_line.output_line += '"' + my_ops.outstanding_balance__c  + '",';
                csv_line.output_line += '"' + my_ops.Start_Value__c  + '"';
				csvout.add(csv_line);
      }
  	}

  	if(format=='21') {
      User u = [select goal_type__c, tier_1_floor__c, tier_2_floor__c, tier_3_floor__c, center_pec__c,baseline_target__c, Baseline_Target_CPC__c from user where id in :user_filters];
      Center_Information__c ci;
      if(u.center_pec__c!=null)
        ci = [select baseline_target__c, Baseline_Target_CPC__c from Center_Information__c where id = :u.center_pec__c];
      else
        ci = new Center_Information__c(tier_1_floor__c = 0, tier_2_floor__c = 0, tier_3_floor__c = 0);
      file_header = '"Tier","TCR Target","TCR Payout %","CPC Target","CPC Payout %"';

	  Decimal baseline_target;
      try {
        if      (u.goal_type__c == 'None' || u.goal_type__c == null) {baseline_target = null;}
        else if (u.goal_type__c == 'User') {baseline_target = u.baseline_target__c;}
        else                               {baseline_target = ci.baseline_target__c;}
      }
      catch(Exception e) {baseline_target = null;}

	  Decimal baseline_target_cpc;
	  try {
        if      (u.goal_type__c == 'None' || u.goal_type__c == null) {baseline_target_cpc = null;}
        else if (u.goal_type__c == 'User')                           {baseline_target_cpc = u.baseline_target_cpc__c;}
        else                                                         {baseline_target_cpc = ci.baseline_target_cpc__c;}
      }
      catch(Exception e) {baseline_target_cpc = null;}


      CSVOutput csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 1,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target - 4.5)) + ',0.063,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc - 2100)) + ',0.063';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 2,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target - 3.0)) + ',0.125,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc - 1300)) + ',0.125';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 3,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target - 1.5)) + ',0.250,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc - 530))  + ',0.250';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 4,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target))       +  ',0.500,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc))       + ',0.500';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 5,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 1.0)) + ',0.565,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 400)) + ',0.567';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 6,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 2.0)) + ',0.635,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 800)) + ',0.634';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 7,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 3.0)) + ',0.700,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 1200)) + ',0.701';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 8,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 4.0)) + ',0.770,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 1600)) + ',0.768';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 9,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 5.0)) + ',0.845,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 2200)) + ',0.880';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 10,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 6.0)) + ',0.915,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 2800)) + ',0.992';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 11,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 7.5)) + ',1.015,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 3400)) + ',1.104';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 12,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 9.0)) + ',1.125,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 4000)) + ',1.215';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 13,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 10.5)) + ',1.230,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 4800)) + ',1.372';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 14,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 12.0)) + ',1.340,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 5600)) + ',1.528';
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 15,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 14.0)) + ',1.485,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 6700)) + ',1.729';
      csvout.add(csv_line);
	  csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 16,' + (baseline_target == null ? 'No Target Set' : String.valueOf(baseline_target + 16.0)) + ',1.625,' + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 7800)) + ',1.931';
      csvout.add(csv_line);
	  csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 17,,,'                                                                                                  + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 9000)) + ',2.154';
      csvout.add(csv_line);
	  csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 18,,,'                                                                                                  + (baseline_target_cpc == null ? 'No Target Set' : String.valueOf(baseline_target_cpc + 10300)) + ',2.400';
      csvout.add(csv_line);

  	}

  	if(format=='22') {
      Sales_Region__c sr = [Select s.Tier_9_Bonus_Payout__c, s.Tier_8_Bonus_Payout__c, s.Tier_7_Bonus_Payout__c, s.Tier_6_Bonus_Payout__c, s.Tier_5_Bonus_Payout__c, s.Tier_4_Bonus_Payout__c, s.Tier_3_Bonus_Payout__c, s.Tier_2_Bonus_Payout__c, s.Tier_1_Bonus_Payout__c, s.Baseline_Target__c From Sales_Region__c s where s.name = :sales_region];
      file_header = '"Tier","TCR Target","Payout %"';
      Decimal baseline_target;
      try {
        baseline_target = sr.baseline_target__c;
      }
      catch(Exception e) {
        baseline_target = 99.0;
      }
      CSVOutput csv_line = new CSVOutput();
     // csv_line.output_line = 'Tier 1,' + (baseline_target - 3.0) + ',' + sr.tier_1_bonus_payout__c;
      //csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 2,' + (baseline_target - 1.5) + ',' + sr.tier_2_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 3,' + baseline_target + ',' + sr.tier_3_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 4,' + (baseline_target + 2.0) + ','  + sr.tier_4_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 5,' + (baseline_target + 4.0) + ',' + sr.tier_5_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 6,' + (baseline_target + 6.0) + ',' + sr.tier_6_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 7,' + (baseline_target + 9.0) + ',' + sr.tier_7_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 8,' + (baseline_target + 12.0) + ',' + sr.tier_8_bonus_payout__c;
      csvout.add(csv_line);
      csv_line = new CSVOutput();
      csv_line.output_line = 'Tier 9,' + (baseline_target + 16.0) + ',' + sr.tier_9_bonus_payout__c;
      csvout.add(csv_line);
  	}

  	//PEC RANKING SNAPSHOT//
  	if(format=='23') {
  	  file_header = '"Overall Ranking","PEC","Region","True Close Rate","TCR National Rank","TCR Regional Rank","Callbacks","Callback National Rank","Callback Regional Rank","Avg Rainmaker Score","Rainmaker National Rank","Rainmaker Regional Rank","Learning Activities","Learning Activities National Rank","Learning Activities Regional Rank"';
  	  String base_query = 'Select p.user__r.name,p.User__c, p.True_Close_Rate__c, p.True_Close_Rate_Regional_Rank__c, p.True_Close_Rate_National_Rank__c, p.Total_National_Rank__c, p.SystemModstamp, p.Starts__c, p.Snapshot_Date__c, p.Sales_Region__c, p.Rainmaker_Regional_Rank__c, p.Rainmaker_National_Rank__c, p.OwnerId, p.National_Overall_Rank__c, p.Name, p.Learning_Activity_Regional_Rank__c, p.Learning_Activity_Num__c, p.Learning_Activity_National_Rank__c, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Consults__c, p.Cancels_out__c, p.Cancels_In__c, p.Callbacks_Num__c, p.Callback_Regional_Rank__c, p.Callback_National_Rank__c, p.Avg_Rainmaker_Score__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = yesterday order by national_overall_rank__c';
  	  for(Pec_Ranking_Snapshot__c prs : database.query(base_query)) {
  	  	CSVOutput csv_line = new CSVOutput();
  	  	csv_line.output_line = prs.National_Overall_Rank__c + ',"' + prs.user__r.name + '","' + prs.sales_region__c + '",' + prs.true_close_rate__c + ',' + prs.true_close_rate_national_rank__c + ','
  	  	  + prs.true_close_rate_regional_rank__c + ',' + prs.callbacks_num__c + ',' + prs.callback_national_rank__c + ',' + prs.callback_national_rank__c + ',' +
  	  	  prs.avg_rainmaker_score__c + ',' + prs.rainmaker_national_rank__c + ',' + prs.rainmaker_regional_rank__c + ',' + prs.learning_activity_num__c + ',' +
  	  	  prs.learning_activity_national_rank__c + ',' + prs.learning_activity_regional_Rank__c;
  	  	csvout.add(csv_line);
  	  }
  	}

  	//Pending Starts//
  	if(format=='20') {
  	  file_header = '"Prost Name","Owner","Created By","Created Date","Center","Stage","Completed Stage","Treatment Plan","Negotiated Amount","Total Payments","Total Refund","Outstanding Balance (minus Anticipated)","Prosth Exam Date","Value in TCR", "Pending Reason"';
  	  String base_query = 'select o.Name, o.owner.name, o.createdby.name, o.createddate, o.account.pre_screen__c, ' +
        ' o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c,' +
        ' o.outstanding_balance__c, o.Outstanding_Balance_incl_anticipated__c, o.preliminary_treatment_plan__c,  o.completed_stage__c,o.account.center_location__c, o.closedate, o.Start_Value__c, o.Prosth_Exam_Paid__c, o.Has_Treatment_Option__c from opportunity o ' +
        'where o.is_Requirement_Met__c = false and o.is_Minimum_Negotiated_Total_Amount__c = true and o.cancel_date__c = null and o.createddate = ' + interval_filter;
      if(interval=='6')
        base_query = 'select o.Name, o.owner.name, o.createdby.name, o.createddate, o.account.pre_screen__c, ' +
	        ' o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c,' +
	        ' o.outstanding_balance__c, o.Outstanding_Balance_incl_anticipated__c, o.preliminary_treatment_plan__c,  o.completed_stage__c,o.account.center_location__c,o.closedate, o.Start_Value__c from opportunity o ' +
	        ' where o.is_Requirement_Met__c = false and o.is_Minimum_Negotiated_Total_Amount__c = true and o.createddate >= :sdate and o.createddate <= :edate and o.cancel_date__c = null ' ;
      if(action=='center')
        base_query += ' and o.account.center__c = :center_id';
      else if(action=='region')
        base_query += ' and o.account.center__r.sales_region__c = :sales_region';
      else if(action=='user')
        base_query += ' and o.ownerid in : user_filters';
      else
        base_query += ' and account.center__r.type__c not in (\'Affiliate\')';
      String[] pending_reasons = new String[]{};
      for(Opportunity my_ops : database.query(base_query + all_filter)) {
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = '"' + my_ops.name  + '",';
				csv_line.output_line += '"' + my_ops.owner.name  + '",';
				csv_line.output_line += '"' + my_ops.createdby.name  + '",';
				csv_line.output_line += '"' + my_ops.createddate  + '",';
				csv_line.output_line += '"' + my_ops.account.center_location__c + '",';
				//removing the colors - 12/9/2014 CM
				//csv_line.output_line += '"' + my_ops.account.pre_screen__c  + '",';
				csv_line.output_line += '"' + my_ops.stagename  + '",';
				if(my_ops.completed_stage__c==null)
				  csv_line.output_line += '"",';
				else
				  csv_line.output_line += '"' + my_ops.completed_stage__c  + '",';
				csv_line.output_line += '"' + my_ops.preliminary_treatment_plan__c  + '",';
				csv_line.output_line += '"' + my_ops.negotiated_total_amount__c  + '",';
				csv_line.output_line += '"' + my_ops.total_payments__c  + '",';
				if(my_ops.refund_amount__c==null)
				  csv_line.output_line += '"0",';
				else
				  csv_line.output_line += '"' + my_ops.refund_amount__c  + '",';
				csv_line.output_line += '"' + my_ops.Outstanding_Balance_incl_anticipated__c  + '",';
				csv_line.output_line += '"' + my_ops.closedate  + '",';
                csv_line.output_line += '"' + my_ops.Start_Value__c  + '",';

                pending_reasons.clear();
                if (!my_ops.Prosth_Exam_Paid__c)     {pending_reasons.add('Total payments are under $1,000 (or there\'s an outstanding balance)');}
                if (!my_ops.Has_Treatment_Option__c) {pending_reasons.add('No treatment option is selected');}
                csv_line.output_line += '"' + String.join(pending_reasons, ' & ') + '"';
				csvout.add(csv_line);
      }
  	}

  	/*
  	modified by cm on 2014-12-22
  	Adjusting for the starts definiton changes
  	*/
  	if(format=='9' || format=='10') {
  		file_header = '"Prost Name","Owner","Created By","Created Date","Start Date","Cancel Date","Center","Stage","Completed Stage","Treatment Plan","Negotiated Amount","Total Payments","Total Refund","Outstanding Balance","Value in TCR"';
  		String inout_filter = '';
  		if(format=='9')
  		  inout_filter = '=';
  		if(format=='10')
  		  inout_filter = '<>';
  	  String base_query = '';

  	  if(format=='10')
  	    base_query = 'select o.Name, o.owner.name, o.createdby.name, o.cancel_date__c, o.createddate, o.account.pre_screen__c, ' +
        'o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c,' +
        'o.outstanding_balance__c, o.preliminary_treatment_plan__c,  o.completed_stage__c,o.account.center_location__c, o.prosth_exam_paid_date__c, o.Start_Value__c ' +
        'from opportunity o where o.is_Valid_Start__c = true and ignored_cancel__c = false and o.cancel_date__c != null ' +
        ' and o.Cancel_Date__c = ' + interval_filter + ' and o.prosth_exam_paid_date__c ' + inout_filter + ' ' + interval_filter;
      if(format=='9')
  	    base_query = 'select o.Name, o.owner.name, o.createdby.name, o.cancel_date__c, o.createddate, o.account.pre_screen__c, ' +
        'o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c,' +
        'o.outstanding_balance__c, o.preliminary_treatment_plan__c,  o.completed_stage__c,o.account.center_location__c, o.prosth_exam_paid_date__c, o.Start_Value__c ' +
        'from opportunity o where  o.is_Valid_Start__c = true and ignored_cancel__c = false and o.cancel_date__c != null ' +
        ' and o.Cancel_Date__c = ' + interval_filter + ' and o.prosth_exam_paid_date__c ' + inout_filter + ' ' + interval_filter;
      if(interval=='6') {
      	base_query = 'select o.Name, o.owner.name, o.createdby.name, o.cancel_date__c, o.createddate, o.account.pre_screen__c, ' +
	        'o.stagename, o.cancel_reason__c, o.refund_amount__c, o.negotiated_total_amount__c, o.total_payments__c,' +
	        'o.outstanding_balance__c, o.preliminary_treatment_plan__c,  o.completed_stage__c,o.account.center_location__c, o.prosth_exam_paid_date__c, o.Start_Value__c ' +
	        'from opportunity o where o.is_Valid_Start__c = true and ignored_cancel__c = false and o.cancel_date__c != null ' +
	        ' and o.Cancel_Date__c >= :sdate and o.cancel_date__c <= :edate ';
	      if(format=='9')
	        base_query = base_query + ' and o.prosth_exam_paid_date__c >= :sdate and o.prosth_exam_paid_date__c <= :edate';
	      if(format=='10')
	        base_query = base_query + ' and (o.prosth_exam_paid_date__c < :sdate or o.prosth_exam_paid_date__c > :edate)';
      }
      if(action=='center')
        base_query += ' and o.account.center__c = :center_id';
      else if(action=='region')
        base_query += ' and o.account.center__r.sales_region__c = :sales_region';
      else if(action=='user')
        base_query += ' and o.Current_Prosth_Owner__c in : user_filters';
      else
        base_query += ' and account.center__r.type__c not in (\'Affiliate\')';
      for(Opportunity my_ops : database.query(base_query + all_filter)) {
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = '"' + my_ops.name  + '",';
				csv_line.output_line += '"' + my_ops.owner.name  + '",';
				csv_line.output_line += '"' + my_ops.createdby.name  + '",';
				csv_line.output_line += '"' + my_ops.createddate  + '",';
				csv_line.output_line += '"' + my_ops.prosth_exam_paid_date__c  + '",';
				csv_line.output_line += '"' + my_ops.cancel_date__c  + '",';
				csv_line.output_line += '"' + my_ops.account.center_location__c + '",';
				//removing colors - 12/9/2014 CM
				//csv_line.output_line += '"' + my_ops.account.pre_screen__c  + '",';
				csv_line.output_line += '"' + my_ops.stagename  + '",';
				if(my_ops.completed_stage__c==null)
				  csv_line.output_line += '"",';
				else
				  csv_line.output_line += '"' + my_ops.completed_stage__c  + '",';
				csv_line.output_line += '"' + my_ops.preliminary_treatment_plan__c  + '",';
				csv_line.output_line += '"' + my_ops.negotiated_total_amount__c  + '",';
				csv_line.output_line += '"' + my_ops.total_payments__c  + '",';
			  if(my_ops.refund_amount__c==null)
				  csv_line.output_line += '"0",';
				else
				  csv_line.output_line += '"' + my_ops.refund_amount__c  + '",';
				csv_line.output_line += '"' + my_ops.outstanding_balance__c  + '",';
                csv_line.output_line += '"' + my_ops.Start_Value__c  + '"';
				csvout.add(csv_line);
      }
  	}

  	//pipeline download
  	if(format=='11' || format=='12' || format=='13' || format=='14') {
  		file_header = '"Center","Consult Owner","Consult Name","Consult Result","Preliminary Treatment Plan","General Notes","Premliminary Treatment Fee Quoted","PreScreen"';
  		/*//not using this for now - per my discussion with the team,  we'll provide all pipeline
  		//info when they click on any of the items here
  		if(format=='11')
  		  result_filter = '30 Day Pipeline';
  		if(format=='12')
  		  result_filter = '60 Day Pipeline';
  		if(format=='13')
  		  result_filter = '90 Day Pipeline';
  		if(format=='14')
  		  result_filter = '2nd Consult';*/
  		Map<String,String> center_names = new Map<String,String>();
  		Map<String,String> user_name = new Map<String,String>();
  		for(Center_Information__c all_center : [select id,name from Center_Information__c]) {
  			center_names.put(all_center.id,all_center.name);
  		}
  		for(User all_users : [select id,name from User]) {
  			user_name.put(all_users.id,all_users.name);
  		}

  		for(Integer i = 1;i<=4;i++) {
  			String pipe_filter = '';
  			if(i==1)
  			  pipe_filter = '30 Day Pipeline';
  			if(i==2)
  			  pipe_filter = '60 Day Pipeline';
  			if(i==3)
  			  pipe_filter = '90 Day Pipeline';
  			if(i==4)
  			  pipe_filter = '2nd Consult';
	  		String base_query = 'select a.center__c,a.ownerid,a.name,a.preliminary_treatment_plan__c, ' +
	  		' a.general_notes__c, a.preliminary_treatment_fee_quoted__c,a.pre_screen__c,a.consult_result__c from ' +
	  		' account a where a.consult_result__c = \'' + pipe_filter + '\'';
	      if(action=='center')
	        base_query += ' and a.center__c = :center_id';
	      else if(action=='region')
	        base_query += ' and a.center__r.sales_region__c = :sales_region';
	      else if(action=='user')
	        base_query += ' and a.ownerid in : user_filters';
	      else
          base_query += ' and center__r.type__c not in (\'Affiliate\')';
	      System.debug('Query : ' + base_query);
	      System.debug(user_filters);
	      for(Account my_ops : database.query(base_query  + all_filter)) {
	      	CSVOutput csv_line = new CSVOutput();
					csv_line.output_line = '"' + center_names.get(my_ops.center__c) + '",';
					csv_line.output_line += '"' + user_name.get(my_ops.ownerid) + '",';
					csv_line.output_line += '"' + my_ops.name  + '",';
					csv_line.output_line += '"' + my_ops.consult_result__c  + '",';
					csv_line.output_line += '"' + my_ops.preliminary_treatment_plan__c + '",';
					if(my_ops.General_Notes__c==null)
					  csv_line.output_line += '"",';
					else {
					  String my_notes = String.valueOf(my_ops.general_notes__c);
					  csv_line.output_line += '"' + my_notes.replace('"',' ')  + '",';
					}
					csv_line.output_line += my_ops.preliminary_treatment_fee_quoted__c  + ',';
					//removing colors - 12/9/2014
					//turned colors back on per Sherry and Bryce 12/11/2014
					csv_line.output_line += '"' + my_ops.pre_screen__c  + '"';
					csvout.add(csv_line);
	  	  }
  		}
  		center_names.clear();
  		user_name.clear();
  	}

  	//upsell sold
    // 2016-08-30 -- AW -- Per Scott L/Brandon T, adding is_Requirement_Met__c = true to all queries for Hygienist revenue
  	if(format=='15') {
  		file_header = '"Prost Exam : Name","Prost Exam Date","Treatment Added at Prostho Exam","Prost Exam Adjustment Amount","Center Location","Created By"';
  		String base_query = 'select o.additional_treatment_amount__c, o.name, o.treatment_added_at_prostho_exam__c, ' +
  		  ' o.account.prostho_exam_date__c, o.account.center__r.name, o.createdby.name, o.closedate from opportunity o where ' +
  		  //' o.createddate = ' + interval_filter + ' and o.additional_treatment_amount__c <> null';
  		  ' is_Requirement_Met__c = true AND o.closedate = ' + interval_filter + ' and o.additional_treatment_amount__c <> null';
  		if(interval=='6')
	  		base_query = 'select o.additional_treatment_amount__c, o.name, o.treatment_added_at_prostho_exam__c, ' +
	  		  ' o.account.prostho_exam_date__c, o.account.center__r.name, o.createdby.name, o.closedate from opportunity o where ' +
	  		  ' is_Requirement_Met__c = true AND o.closedate >= :sdate and o.closedate <= :edate and o.additional_treatment_amount__c <> null';
  		if(action=='center')
        base_query += ' and o.account.center__c = :center_id';
      else if(action=='region')
        base_query += ' and o.account.center__r.sales_region__c = :sales_region';
      else if(action=='user')
        base_query += ' and o.ownerid in : user_filters';
      else
        base_query += ' and account.center__r.type__c not in (\'Affiliate\')';
      for(Opportunity my_ops : database.query(base_query  + all_filter)) {
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line =  my_ops.name  + ',';
				//csv_line.output_line += '"' + my_ops.account.prostho_exam_date__c  + '",';
				csv_line.output_line += '"' + my_ops.closedate  + '",';
				csv_line.output_line += '"' + my_ops.treatment_added_at_prostho_exam__c  + '",';
				csv_line.output_line += my_ops.additional_treatment_amount__c  + ',';
				csv_line.output_line += '"' + my_ops.account.center__r.name  + '",';
				csv_line.output_line += '"' + my_ops.createdby.name  + '",';
				csvout.add(csv_line);
  	  }
  	}

  	//upsell cancelled in or out of period
    // 2016-08-30 -- AW -- Per Scott L/Brandon T, adding is_Requirement_Met__c = true to all queries for Hygienist revenue
    // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  	if(format=='16' || format=='17') {
  		String inout_filter = '';
  		if(format=='16')
  		  inout_filter = '=';
  		if(format=='17')
  		  inout_filter = '<>';
  		file_header = '"Prost Exam : Name","Prost Exam Date","Treatment Added at Prostho Exam","Prost Exam Adjustment Amount","Center Location","Created By"';
  		String base_query = 'select o.additional_treatment_amount__c, o.name, o.treatment_added_at_prostho_exam__c, ' +
  		  ' o.account.prostho_exam_date__c, o.account.center__r.name, o.createdby.name, o.closedate from opportunity o where ' +
  		  ' is_Requirement_Met__c = true AND Cancel_Date__c = ' + interval_filter + ' and Prosth_Exam_Paid_Date__c ' + inout_filter + ' ' + interval_filter + '  and o.cancel_date__c != null ';
  		if(interval=='6') {
	  		base_query = 'select o.additional_treatment_amount__c, o.name, o.treatment_added_at_prostho_exam__c, ' +
	  		  ' o.account.prostho_exam_date__c, o.account.center__r.name, o.createdby.name, o.closedate from opportunity o where is_Requirement_Met__c = true AND ';
	  		if(format=='16')
	  		  base_query += ' Cancel_Date__c >= :sdate and cancel_date__c <= :edate and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate ';
	  		if(format=='17')
	  		  base_query += ' Cancel_Date__c >= :sdate and cancel_date__c <= :edate and (Prosth_Exam_Paid_Date__c < :sdate and Prosth_Exam_Paid_Date__c > :edate) ';
	  		base_query += '  and o.cancel_date__c != null ';
  		}
  		if(action=='center')
        base_query += ' and o.account.center__c = :center_id';
      else if(action=='region')
        base_query += ' and o.account.center__r.sales_region__c = :sales_region';
      else if(action=='user')
        base_query += ' and o.Current_Prosth_Owner__c in : user_filters';
      else
        base_query += ' and account.center__r.type__c not in (\'Affiliate\')';
      for(Opportunity my_ops : database.query(base_query  + all_filter)) {
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line =  my_ops.name  + ',';
				//csv_line.output_line += '"' + my_ops.account.prostho_exam_date__c  + '",';
				csv_line.output_line += '"' + my_ops.closedate  + '",';
				csv_line.output_line += '"' + my_ops.treatment_added_at_prostho_exam__c  + '",';
				csv_line.output_line += my_ops.additional_treatment_amount__c  + ',';
				csv_line.output_line += '"' + my_ops.account.center__r.name  + '",';
				csv_line.output_line += '"' + my_ops.createdby.name  + '",';
				csvout.add(csv_line);
  	  }
  	}

  	//user comission report
  	if(format=='18') {
  		Integer report_month = Integer.valueof(apexpages.currentpage().getparameters().get('rmonth'));
  		Integer report_year = Integer.valueof(apexpages.currentpage().getparameters().get('ryear'));
  	  Integer individual_bonus = 1850;
  	  //build a list of pecs for the previous month and their results
  	  comission_report = new Comission_Line[] {};
  	  Integer start_month = getstart_month(report_month);
  	  Integer end_month = getend_month(report_month);
  	  System.debug('Start Month : ' + start_month + ' End Month : ' + end_month + ' Report Month : ' + report_month);

  	  //modified by cm on 2014-10-31 - removed and center_administrator__c = false so we would have FOA's in the details again
  	  List<User> pec_list = [Select u.baseline_target__c, u.Name, u.Center_PEC__c, u.id,(Select baseline_target__c,Fiscal_month__c, Refunded_Dollars__c, Collected_Dollars__c,
  	    Sales_Goal__c, Target_Rate__c, Target_Dollars__c, Cancelled_Dollars_In__c, Cancelled_Dollars_Out__c,Cancelled_Starts_In__c,
  	    Cancelled_Starts_Out__c,Consults__c,Financed_Consults__c,Sold__c,Starts__c,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,
  	    gp_collected_fees__c,gp_refunded_fees__c  From User_Goals__r where
  	    fiscal_year__c = :report_year and (fiscal_month__c >= :start_month and fiscal_month__c <= :end_month))
  	    From User u where center_pec__c <> null  and remove_from_comission_report__c = false];
  	  for(User pec : pec_list) {
  	  	comission_report.add(new Comission_Line(pec,pec.user_goals__r,report_month));
  	  }
  	  //work through all the centers and update the object with the center name and sales market`
  	  for(Center_Information__c center : [Select c.Sales_Market__r.Name, c.Sales_Market__c, c.Name, c.Id From Center_Information__c c]) {
  	  	//match up the users tied to this center
  	  	for(Comission_Line cuser : comission_report) {
  	  		if(cuser.userinfo.center_pec__c == center.id) {
  	  			cuser.center_name = center.name;
  	  			//travelers base their qtr bonus for the center off their personal goals
  	  			if(center.name=='Unknown') {
  	  				Decimal projected_revenue = 0;
  	  				cuser.center_qtr_goal = cuser.qtr_goal;
  	  				if(cuser.num_months>0)
  	  				  projected_revenue = (cuser.monthly_collections/cuser.num_months) * 3;
				  		if(projected_revenue > cuser.qtr_goal)
				  		  //modified by cm on 2012-4-27
  		          //Based on a quick discussion with Waltzer,  we will only be accruing for the portion of the
  		          //quarterly bonus that they have earned so far versus a projection for the full 3 months.
				  		  cuser.center_qtr_bonus = (2000.00/3.0) * cuser.num_months;
				  		else
				  		  cuser.center_qtr_bonus = 0;
  	  			}
  	  			else
  	  			  cuser.Sales_Market = center.sales_market__c;
  	  		}
  	  	}
  	  }
  	  //work through the center budgets and calculate qtr results at the sales market level
  	  for(Market__c market : [select id from Market__c]) {
  	  	Decimal center_goal = 0;
  	  	Decimal revenue = 0;
  	  	Decimal center_bonus = 0;
  	  	Integer num_months = report_month - start_month + 1;

  	  	for(Center_Budget__c budget : [select collected_dollars__c, refunded_dollars__c,sales_goal__c,fiscal_month__c from Center_Budget__c where center__r.sales_market__c = :market.id and fiscal_year__c = :report_year and (fiscal_month__c >= :start_month and fiscal_month__c <= :end_month)]) {
  	  		center_goal += budget.sales_goal__c;
  	  		if(budget.fiscal_month__c <= report_month) {
  	  			Decimal collected = 0;
  	  			Decimal refunded = 0;
  	  			if(budget.collected_dollars__c<> null)
  	  			  collected = budget.collected_dollars__c;
  	  			if(budget.refunded_dollars__c<>null)
  	  			  refunded = budget.refunded_dollars__c;
  	  	    revenue += (collected - refunded);
  	  		}
  	  	}

  	  	Decimal projected_rev = revenue/num_months * 3;
  	  	if(projected_rev>center_goal)
  	      //modified by cm on 2012-4-27
  		    //Based on a quick discussion with Waltzer,  we will only be accruing for the portion of the
  		    //quarterly bonus that they have earned so far versus a projection for the full 3 months.
  	  	  center_bonus = (2000.00/3.0) * num_months;
  	  	else
  	  	  center_bonus = 0.00;
  	  	for(Comission_Line cuser : comission_report) {
  	  		if(cuser.Sales_Market == market.id) {
  	  		  cuser.center_qtr_bonus = center_bonus;
  	  		  cuser.center_qtr_goal = center_goal;
  	  		}
  	  	}
  	  }
  	  //output the results
  	  file_header = '"Comission Report for ' + report_month + '/' + report_year + '"\r\n';
  	  //file_header += '"Name","Center","Monthly Individual Bonus","Individual QTR Bonus","Center QTR Bonus","Target $","% Target Achieved","Net Collected $","Collected $","Refunded Dollars $","Consults","Financed Consults","Starts","Cancelled Starts In","Cancelled Starts Out","Sold $","Cancelled $ In","Cancelled Dollars Out","Center QTR Target","User QTR Target","Net Collections for QTR","Tier 1 Floor","Tier 1 Bonus","Tier 2 Floor","Tier 2 Bonus","Tier 3 Floor","Tier 3 Bonus","Tier 3 QTR Bonus"';
  	  file_header += '"Name","Center","Net Collected $","Net Collected $ minus Fees","Collected $","Collected $ GP Fees","Refunded Dollars $","Refunded Dollars $ GP Fees","Consults","Financed Consults","Starts","Cancelled Starts In","Cancelled Starts Out","Sold $","Cancelled $ In","Cancelled Dollars Out","Net Collections for QTR","Tier 1 Floor","Tier 1 Bonus","Tier 2 Floor","Tier 2 Bonus","QTR Goal","QTR Bonus","Baseline Target","Payout Tier","Payout %","Payout Amount"';
 	  	for(Comission_Line cuser : comission_report) {
 	  	System.debug('Tier 3 QTR Amount : ' + cuser.tier_3_qtr_amount);
 	  	System.debug('Tier 3 Amount : ' + cuser.tier_3_amount);
 	  	System.debug('Tier 3 Store : ' + cuser.tier_3_store);
 	  	System.debug('Tier 2 Amount : ' + cuser.tier_2_amount);
 	  	System.debug('Tier 2 Store : ' + cuser.tier_2_store);
 	  	System.debug('Tier 1 Amount : ' + cuser.tier_1_amount);
      	CSVOutput csv_line = new CSVOutput();
				csv_line.output_line = cuser.userinfo.name  + ',';
				csv_line.output_line += cuser.center_name  + ',';
				//csv_line.output_line += cuser.monthly_bonus.setscale(2)  + ',';
				//csv_line.output_line += cuser.individual_qtr_bonus.setscale(2)  + ',';
				//csv_line.output_line += cuser.center_qtr_bonus.setscale(2) + ',';
				for(User_Goals__c my_goals : cuser.budget_months) {
					if(my_goals.fiscal_month__c == report_month) {
				    //csv_line.output_line += check_for_null(String.valueof(my_goals.Target_Dollars__c)) + ',';
				    //csv_line.output_line += check_for_null(String.valueof(my_goals.Target_Rate__c)) + ',';
				    Decimal net_collected = 0;
				    Decimal net_collected_wo_fees = 0;
				    if(my_goals.Collected_Dollars__c!=null) {
				      net_collected += my_goals.Collected_Dollars__c;
				      net_collected_wo_fees += my_goals.Collected_Dollars__c;
				    }
				    if(my_goals.Refunded_Dollars__c!=null) {
				      net_collected -= my_goals.Refunded_Dollars__c;
				      net_collected_wo_fees -= my_goals.Refunded_Dollars__c;
				    }
				    if(my_goals.GP_Collected_Fees__c!=null)
				      net_collected_wo_fees -= my_goals.GP_Collected_Fees__c;
				    if(my_goals.GP_Refunded_Fees__c!=null)
				      net_collected_wo_fees += my_goals.GP_Refunded_Fees__c;

				    csv_line.output_line += check_for_null(String.valueof(net_collected)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(net_collected_wo_fees)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Collected_Dollars__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.GP_Collected_Fees__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Refunded_Dollars__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.GP_Refunded_Fees__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Consults__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Financed_Consults__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Starts__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Cancelled_Starts_In__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Cancelled_Starts_Out__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Sold__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Cancelled_Dollars_In__c)) + ',';
				    csv_line.output_line += check_for_null(String.valueof(my_goals.Cancelled_Dollars_Out__c)) + ',';
					}
				}
				/*if(cuser.center_qtr_goal==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.center_qtr_goal.setscale(2) + ',';
				if(cuser.qtr_goal==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.qtr_goal.setscale(2) + ',';*/
				if(cuser.monthly_collections==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.monthly_collections.setscale(2) + ',';
				if(cuser.tier_1_floor==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.tier_1_floor.setscale(2) + ',';
				if(cuser.tier_1_amount==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.tier_1_amount.setscale(2) + ',';
			    if(cuser.tier_2_floor==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.tier_2_floor.setscale(2) + ',';
				if(cuser.tier_2_store==null)
				  csv_line.output_line += '0,';
				else
				  csv_line.output_line += cuser.tier_2_store.setscale(2) + ',';
				if(cuser.tier_3_floor==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.tier_3_floor.setscale(2) + ',';
				/*if(cuser.tier_3_store==null)
				  csv_line.output_line += '0,';
				else
				  csv_line.output_line += cuser.tier_3_store.setscale(2) + ',';*/
				if(cuser.tier_3_qtr_amount==null)
				  csv_line.output_line += ',';
				else
				  csv_line.output_line += cuser.tier_3_qtr_amount.setscale(2) + ',';
				csv_line.output_line += (cuser.baseline_target==null?0:cuser.baseline_target) + ',';
				csv_line.output_line += (cuser.payout_tier==null?0:cuser.payout_tier) + ',';
				csv_line.output_line += (cuser.current_payout==null?0:cuser.current_payout) + ',';
				csv_line.output_line += (cuser.current_payout_amount==null?0:cuser.current_payout_amount) + ',';
				csvout.add(csv_line);
  	  }
  	}

  	//center comission report
	  if(format=='19') {
	    Integer report_month = Integer.valueof(apexpages.currentpage().getparameters().get('rmonth'));
	  	Integer report_year = Integer.valueof(apexpages.currentpage().getparameters().get('ryear'));
	  	file_header = '"Comission Report for ' + report_month + '/' + report_year + '"\r\nCenter Rollup\r\n\r\n';
	  	file_header += '"Center Name","Sales Market","Target $","% Target Achieved","Net Collected $","Collected $","Refunded Dollars $","Consults","Financed Consults","Starts","Cancelled Starts In","Cancelled Starts Out","Sold $","Cancelled $ In","Cancelled Dollars Out"';
	  	//build a list of centers and display the budget results
	  	for(Center_Information__c center : [Select c.Name, c.Id, c.market__r.name, (Select Sales_Goal__c, Target_Dollars__c, Collected_Dollars__c, Refunded_Dollars__c, Consults__c, Starts__c, Cancelled_Starts_In__c, Cancelled_Starts_Out__c, Sold__c, Cancelled_Dollars_In__c, Cancelled_Dollars_Out__c, Financed_Consults__c, Target_Rate__c From Center_Budgets__r where fiscal_month__c = :report_month and fiscal_year__c = :report_year) From Center_Information__c c]) {
	  	  CSVOutput csv_line = new CSVOutput();
				csv_line.output_line =  center.name  + ',';
				csv_line.output_line +=  center.market__r.name  + ',';
				for(Center_Budget__c cbudget : center.center_budgets__r) {
					csv_line.output_line += check_for_null(String.valueof(cbudget.Target_Dollars__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Target_Rate__c)) + ',';
			    Decimal net_collected = 0;
			    if(cbudget.Collected_Dollars__c!=null)
			      net_collected += cbudget.Collected_Dollars__c;
			    if(cbudget.Refunded_Dollars__c!=null)
			      net_collected -= cbudget.Refunded_Dollars__c;
			    csv_line.output_line += String.valueof(net_collected) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Collected_Dollars__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Refunded_Dollars__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Consults__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Financed_Consults__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Starts__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Cancelled_Starts_In__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Cancelled_Starts_Out__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Sold__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Cancelled_Dollars_In__c)) + ',';
			    csv_line.output_line += check_for_null(String.valueof(cbudget.Cancelled_Dollars_Out__c)) + ',';
				}
				csvout.add(csv_line);
	  	}
	  	CSVOutput header_line = new CSVOutput();
	  	header_line.output_line = '\r\nSales Market Rollup\r\n';
	  	header_line.output_line += '"Sales Market","Center Bonus","Target $","% Target Achieved","Collected $","Refunded Dollars $","Consults","Financed Consults","Starts","Cancelled Starts In","Cancelled Starts Out","Sold $","Cancelled $ In","Cancelled Dollars Out"';
	  	csvout.add(header_line);
	  	Integer start_month = getstart_month(report_month);
	  	for(AggregateResult market : [select market__r.name,market__c from Center_Information__c group by market__c, market__r.name]) {
	      CSVOutput csv_line = new CSVOutput();
	      if(market.get('name')==null)
	        csv_line.output_line = 'Unknown,';
	      else
	        csv_line.output_line =  market.get('name')  + ',';
	      Decimal center_goal = 0;
  	  	Decimal revenue = 0;
  	  	Decimal center_bonus = 0;
  	  	String market_id = String.valueof(market.get('market__c'));
  	  	Integer num_months = report_month-start_month + 1;
  	  	for(Center_Budget__c budget : [Select Fiscal_Month__c,Sales_Goal__c, Target_Dollars__c, Collected_Dollars__c, Refunded_Dollars__c, Consults__c, Starts__c, Cancelled_Starts_In__c, Cancelled_Starts_Out__c, Sold__c, Cancelled_Dollars_In__c, Cancelled_Dollars_Out__c, Financed_Consults__c, Target_Rate__c From Center_Budget__c where (fiscal_month__c >= :start_month and fiscal_month__c <= :report_month) and fiscal_year__c = :report_year and center__r.market__c = :market_id]) {
  	  		center_goal += budget.sales_goal__c;
  	  		if(budget.fiscal_month__c <= report_month) {
  	  			Decimal collected = 0;
  	  			Decimal refunded = 0;
  	  			if(budget.collected_dollars__c<> null)
  	  			  collected = budget.collected_dollars__c;
  	  			if(budget.refunded_dollars__c<>null)
  	  			  refunded = budget.refunded_dollars__c;
  	  	    revenue += (collected - refunded);
  	  		}
  	  	}
  	  	Decimal projected_rev = revenue/num_months * 3;
  	    if(projected_rev >= center_goal)
  	      csv_line.output_line += '2000,';
  	    else
  	      csv_line.output_line += '0,';
  	    System.debug('Query : select sum(target_dollars__c) target_dollars,  sum(collected_dollars__c) collected_dollars, sum(refunded_dollars__c) refunded_dollars, sum(consults__c) consults, sum(starts__c) starts , sum(cancelled_starts_in__c) cancelled_starts_in, sum(cancelled_starts_out__c) cancelled_starts_out, sum(sold__c) sold, sum(cancelled_dollars_in__c) cancelled_dollars_in, sum(cancelled_dollars_out__c) cancelled_dollars_out, sum(financed_consults__c) financed_consults from center_budget__c where  fiscal_month__c = :report_month and fiscal_year__c = :report_year and center__r.market__c = :market.id group by center__r.market__c');
  	    System.debug(market_id + ' ' + report_month + ' ' + report_year);
  	    for(AggregateResult result : [select sum(target_dollars__c) target_dollars,  sum(collected_dollars__c) collected_dollars, sum(refunded_dollars__c) refunded_dollars, sum(consults__c) consults, sum(starts__c) starts , sum(cancelled_starts_in__c) cancelled_starts_in, sum(cancelled_starts_out__c) cancelled_starts_out, sum(sold__c) sold, sum(cancelled_dollars_in__c) cancelled_dollars_in, sum(cancelled_dollars_out__c) cancelled_dollars_out, sum(financed_consults__c) financed_consults from center_budget__c where  fiscal_month__c = :report_month and fiscal_year__c = :report_year and center__r.market__c = :market_id group by center__r.market__c]) {
          csv_line.output_line += result.get('Target_Dollars') + ',';
          Decimal Collected_Dollars;
          Decimal Refunded_Dollars;
          Decimal Target;
          if(result.get('Collected_Dollars')==null)
            Collected_Dollars = 0;
          else
            Collected_Dollars = (decimal) result.get('Collected_Dollars');
          if(result.get('Refunded_Dollars')==null)
            Refunded_Dollars = 0;
          else
            Refunded_Dollars = (decimal) result.get('Refunded_Dollars');
          if(result.get('Target_Dollars')==null)
            Target = 0;
          else
            Target = (decimal) result.get('Target_Dollars');
          if(target==0)
            csv_line.output_line +=  '"na",';
          else {
          	Decimal target_rate = ((Collected_Dollars - Refunded_Dollars) / Target) * 100;
			      csv_line.output_line += target_rate.round() + ',';
          }
          Decimal net_collected = 0;
			    if(result.get('Collected_Dollars')!=null)
			      net_collected += (decimal)result.get('Collected_Dollars');
			    if(result.get('Refunded_Dollars')!=null)
			      net_collected -= (decimal)result.get('Refunded_Dollars');
			    csv_line.output_line += String.valueof(net_collected) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Collected_Dollars'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Refunded_Dollars'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Consults'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Financed_Consults'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Starts'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Cancelled_Starts_In'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Cancelled_Starts_Out'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Sold'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Cancelled_Dollars_In'))) + ',';
			    csv_line.output_line += check_for_null(String.valueof(result.get('Cancelled_Dollars_Out'))) + ',';
  	    }
  	    csvout.add(csv_line);
	  	}
	  }
	  working_csvset.csvfiles = csvout;
	  csvset.add(working_csvset);
  	return csvset;
  }



}