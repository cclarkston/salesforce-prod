/*
modified by cm on 2014-12-18
I'm adjusting the start and cancel queries to account for our new defintion of a start (negotiated amount > 2500 and the 1000 payment required)

modified by cm on 2015-06-04
  per data governance,  the cancel in definition is changing to close the loophole
  old defintion cancel_reason__c != null
  
modified by cm on 6/28/2017
  cancel is now defined just by cancel_date__c != null  
  removed references to stagename and completed stage
*/

public without sharing class ctrl_salesranking {
    public String report_interval {get;set;}
    public Boolean center_limit {get;set;}
    public Boolean pec_limit {get;set;}
    public Boolean finance_center_limit {get;set;}
    public Boolean finance_pec_limit {get;set;}
    public Boolean collected_center_limit {get;set;}
    public Boolean collected_pec_limit {get;set;}
    private String sorting_rule;

    Decimal treatment_sold;
    Decimal cancelled_dollars;
    Decimal collected_dollars;
    Decimal refunded_dollars;
    Decimal gp_collected_fees;
    Decimal gp_refunded_fees;
    //controls the number of applying for finance results returned
    Integer finance_limit = 5;

    public ctrl_salesranking() {
        report_interval = 'this_month';
        center_limit = true;
        pec_limit = true;
        finance_center_limit = true;
        finance_pec_limit = true;
        collected_center_limit = true;
        collected_pec_limit = true;
    }

    public List<SelectOption> getIntervalOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('this_month','Current Month'));
        options.add(new SelectOption('last_month','Last Month'));
        options.add(new SelectOption('today','Today'));
        options.add(new SelectOption('yesterday','Yesterday'));
        options.add(new SelectOption('last_week','Last Week'));
        options.add(new SelectOption('this_week','Current Week'));
        options.add(new SelectOption('this_quarter','Current Quarter'));
        options.add(new SelectOption('last_quarter','Last Quarter'));
        options.add(new SelectOption('this_year','Current Year'));
        options.add(new SelectOption('last_year','Last Year'));
        options.add(new SelectOption('last_90_days','Last 90 Days'));
        return options;
    }

    public class pec_ranking implements Comparable {
        public String display_name {get;set;}
        public Decimal display_value {get; set;}
        public Decimal starts {get;set;}
        public Integer consults {get;set;}
        private String sorting_rule;

        public pec_ranking(String pec_name, Decimal ranked_value, String sorting) {
            this.display_name = pec_name;
            this.display_value = ranked_value;
            this.starts = 0;
            this.consults = 0;
            this.sorting_rule = sorting;
        }

        public Decimal getclose_rate() {
            if (this.consults==0) {return 0.00;}
            else                  {return (starts * 1.00) / (consults *1.00);}
        }

        public Decimal getrevenue_per_start() {
            return (starts != 0) ? (display_value / starts) : 0;
        }

        public Decimal getcollections_per_consult() {
            return (consults != 0) ? (display_value / consults) : 0;
        }

        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            pec_ranking compareTopec = (pec_ranking)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (sorting_rule == 'revenue_per_start') {
                if      (getrevenue_per_start() > compareTopec.getrevenue_per_start()) {returnValue = -1;}
                else if (getrevenue_per_start() < compareTopec.getrevenue_per_start()) {returnValue = 1;}
            } else if (sorting_rule == 'collections_per_consult') {
                if      (getcollections_per_consult() > compareTopec.getcollections_per_consult()) {returnValue = -1;}
                else if (getcollections_per_consult() < compareTopec.getcollections_per_consult()) {returnValue = 1;}
            } else {
                if      (display_value > compareTopec.display_value) {returnValue = -1;}
                else if (display_value < compareTopec.display_value) {returnValue = 1;}
            }
            return returnValue;
        }
    }

    public class finance_rank implements Comparable {
        public String pec_name {get;set;}
        public Integer num_consults {get;set;}
        public Integer finance_consults {get; set;}
        public Decimal finance_rate {get;set;}

        public finance_rank(String user_name,Integer user_consults) {
            this.pec_name = user_name;
            this.num_consults = user_consults;
            this.finance_consults = 0;
            this.finance_rate = 0.00;
        }

        public void update_finance_count(Integer num_financed) {
            this.finance_consults = num_financed;
            try {
                this.finance_rate = (num_financed *1.00)/(num_consults * 1.00);
            }
            catch (Exception e) {
                //we either have no consults or we divided by 0.
                this.finance_rate = 0.00;
            }
        }

        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            finance_rank compareTopec = (finance_rank)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if      (finance_rate > compareTopec.finance_rate) {returnValue = -1;}
            else if (finance_rate < compareTopec.finance_rate) {returnValue = 1;}
            return returnValue;
        }

    }

    // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
    public Decimal getsold_dollars() {
        if(treatment_sold==null) {
            treatment_sold = 0.00;
            String base_query = 'select sum(negotiated_total_amount__c) total_payments from opportunity where account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c = ' + report_interval;
            for(AggregateResult ar : database.query(base_query)) {
                treatment_sold = ar.get('total_payments')==null ? 0.00 : (Decimal)ar.get('total_payments');
            }
        }
        return treatment_sold;
    }

    public Decimal getcancelled_dollars() {
        if(cancelled_dollars==null) {
            cancelled_dollars = 0.00;
            String base_query = 'select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = ' + report_interval + ' and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') ';
            for(AggregateResult ar : database.query(base_query)) {
                cancelled_dollars = ar.get('total_payments')==null ? 0 : (Decimal)ar.get('total_payments');
            }
        }
        return cancelled_dollars;
    }

    public Decimal getcollected_dollars() {
        if(collected_dollars==null) {
            collected_dollars = 0.00;
            String base_query = 'Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c where payment_status_formula__c = \'Collected\' and payment_date__c = ' + report_interval;
            for(AggregateResult ar : database.query(base_query)) {
                collected_dollars = ar.get('total_payments')==null ? 0 : (Decimal)ar.get('total_payments');
            }
        }
        return collected_dollars;
    }

    public Decimal getrefunded_dollars() {
        if(refunded_dollars==null) {
            refunded_dollars = 0.00;
            String base_query = 'Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = ' + report_interval;
            for(AggregateResult ar : database.query(base_query)) {
                refunded_dollars = ar.get('total_payments')==null ? 0 : (Decimal)ar.get('total_payments') * -1;
            }
        }
        return refunded_dollars;
    }

    public Decimal getgp_collected_fees() {
        if(gp_collected_fees==null) {
            gp_collected_fees = 0.00;
            String base_query = 'Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c where payment_status_formula__c = \'Collected\' and payment_date__c = ' + report_interval;
            for(AggregateResult ar : database.query(base_query)) {
                gp_collected_fees = ar.get('total_gp_fee')==null ? 0 : (Decimal)ar.get('total_gp_fee') * -1;
            }
        }
        return gp_collected_fees;
    }

    public Decimal getgp_refunded_fees() {
        if(gp_refunded_fees==null) {
            gp_refunded_fees = 0.00;
            String base_query = 'Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = ' + report_interval;
            for(AggregateResult ar : database.query(base_query)) {
                gp_refunded_fees = ar.get('total_gp_fee')==null ? 0 : (Decimal)ar.get('total_gp_fee');
            }
        }
        return gp_refunded_fees;
    }

    public void change_report_interval() {
        gp_refunded_fees = null;
        gp_collected_fees = null;
        collected_dollars = null;
        refunded_dollars = null;
        treatment_sold = null;
        cancelled_dollars = null;
        center_limit = true;
        pec_limit = true;
        finance_center_limit = true;
        finance_pec_limit = true;
        collected_center_limit = true;
        collected_pec_limit = true;
    }

  public List<finance_rank> getfinance_list() {
  	//minimum number of consults in order to appear in the list
  	//per Sherry and Bryce - 10/6/2014 CM
  	Integer min_consults = 10;
  	List<finance_rank> pec_finance_ranks = new List<finance_rank>{};
  	Map<Id,finance_rank> all_ranks = new Map<ID,finance_rank>();
  	/*modified by cm on 2015-03-30
  	  the consult count is being adjusted to drive off of consult_pec__c going forward
  	*/
  	//grab consult numbers for all pecs - lead scheds first
  	/*String base_query = 'select scheduled_lead__r.convertedaccount.ownerid oid,scheduled_lead__r.convertedaccount.owner.name uname,count(c.id) num_consults from Consult_Inventory__c c where c.apt_date__c = ' + report_interval +
  	  ' and active__c=true and arrival_time__c != null and scheduled_lead__c != null group by scheduled_lead__r.convertedaccount.ownerid,scheduled_lead__r.convertedaccount.owner.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(ar.get('oid')!=null) {
  	    finance_rank new_rank = new finance_rank((String)ar.get('uname'),(Integer)ar.get('num_consults'));
  	    all_ranks.put((Id)ar.get('oid'),new_rank);
  	  }
  	}
  	//grab consult numbers for all pecs - consult scheds
  	base_query = 'select  scheduled_account__r.ownerid oid,scheduled_account__r.owner.name uname,count(c.id) num_consults from Consult_Inventory__c c where c.apt_date__c = ' + report_interval +
  	  ' and active__c=true and arrival_time__c != null and scheduled_account__c != null group by scheduled_account__r.ownerid,scheduled_account__r.owner.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(ar.get('oid')!=null) {
  	  	//do we already have this pec in the list?
  	  	if(all_ranks.get((ID)ar.get('oid'))!=null)
  	  	  all_ranks.get((ID)ar.get('oid')).num_consults += (Integer)ar.get('num_consults');
  	  	else {
  	  	  finance_rank new_rank = new finance_rank((String)ar.get('uname'),(Integer)ar.get('num_consults'));
  	      all_ranks.put((ID)ar.get('oid'),new_rank);
  	  	}
  	  }
  	}*/
  	//single query for consults now
  	String base_query = 'select consult_pec__c oid,consult_pec__r.name uname,count(c.id) num_consults ' +
                        'from Consult_Inventory__c c ' +
                        'where c.apt_date__c = ' + report_interval + ' ' +
                        'and consult_room__r.room_type__c != \'Practice\' ' +
	                    'and active__c=true ' +
                        'and arrival_time__c != null ' +
                        'group by consult_pec__c, consult_pec__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(ar.get('oid')!=null) {
  	    finance_rank new_rank = new finance_rank((String)ar.get('uname'),(Integer)ar.get('num_consults'));
  	    all_ranks.put((Id)ar.get('oid'),new_rank);
  	  }
  	}

  	//grab count of financed consults
  	base_query = 'select ownerid oid,count(id) num_finance from account where createddate = ' + report_interval + ' and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\') group by ownerid';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(ar.get('oid')!=null) {
  	  	//look for a match - if not ignore (should almost never happen)
  	  	if(all_ranks.get((ID)ar.get('oid'))!=null)
  	  	  all_ranks.get((ID)ar.get('oid')).update_finance_count((Integer)ar.get('num_finance'));
  	  }
  	}
  	List<finance_rank> temp_rank = all_ranks.values();
  	System.debug('Temp Rank : ' + temp_rank);
  	temp_rank.sort();
  	System.debug('Sorted Temp Rank : ' + temp_rank);
  	Integer cnt = 0;
  	for(finance_rank fr : temp_rank) {
  	  if(fr.num_consults >= min_consults || test.isRunningTest()) {
	  	if(cnt < finance_limit || !finance_pec_limit)
	  	  pec_finance_ranks.add(fr);
	    cnt++;
  	  }
  	}
  	return pec_finance_ranks;
  }

  //modified by Alon W on 2016-08-24 - Added filters to exclude consults where consult_room_type is 'Practice'
  public List<finance_rank> getcenter_finance_list() {
  	List<finance_rank> pec_finance_ranks = new List<finance_rank>{};
  	Map<Id,finance_rank> all_ranks = new Map<ID,finance_rank>();
  	String base_query = 'select c.consult_room__r.center_information__c oid,c.consult_room__r.center_information__r.name uname,count(c.id) num_consults ' +
                        'from Consult_Inventory__c c ' +
                        'where c.apt_date__c = ' + report_interval + ' ' +
                        'and consult_room__r.room_type__c != \'Practice\' ' +
	                    'and active__c=true ' +
                        'and arrival_time__c != null ' +
                        'group by c.consult_room__r.center_information__c,c.consult_room__r.center_information__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(ar.get('oid')!=null) {
  	    finance_rank new_rank = new finance_rank((String)ar.get('uname'),(Integer)ar.get('num_consults'));
  	    all_ranks.put((Id)ar.get('oid'),new_rank);
  	  }
  	}
  	//grab count of financed consults
  	base_query = 'select center__c oid,count(id) num_finance from account where createddate = ' + report_interval + ' and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\') group by center__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(ar.get('oid')!=null) {
  	  	//look for a match - if not ignore (should almost never happen)
  	  	if(all_ranks.get((ID)ar.get('oid'))!=null)
  	  	  all_ranks.get((ID)ar.get('oid')).update_finance_count((Integer)ar.get('num_finance'));
  	  }
  	}
  	List<finance_rank> temp_rank = all_ranks.values();
  	System.debug('Temp Rank : ' + temp_rank);
  	temp_rank.sort();
  	System.debug('Sorted Temp Rank : ' + temp_rank);
  	Integer cnt = 0;
  	for(finance_rank fr : temp_rank) {
  	  if(cnt < finance_limit || !finance_center_limit)
  	    pec_finance_ranks.add(fr);
  	  cnt++;
  	}
  	return pec_finance_ranks;
  }

  public void display_all_pec() {
  	pec_limit = false;
  }

  public void display_all_center() {
  	center_limit = false;
  }

  public void display_all_finance_pec() {
  	finance_pec_limit = false;
  }

  public void display_all_finance_center() {
  	finance_center_limit = false;
  }

  public void display_all_collected_pec() {
  	collected_pec_limit = false;
  }

  public void display_all_collected_center() {
  	collected_center_limit = false;
  }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public list<pec_ranking> getpec_start_dollars() {
  	String limit_filter = ' limit 10';
  	List<pec_ranking> pec_list = new List<pec_ranking>();
  	Map<ID,pec_ranking> pec_map = new Map<ID,pec_ranking>();
  	//grabbing count of starts and sold $
  	String base_query = 'select owner.name pec_name,ownerid,count(id) num_starts,sum(negotiated_total_amount__c) total_payments from opportunity where Prosth_Exam_Paid_Date__c = ' + report_interval + ' group by owner.name,ownerid order by sum(negotiated_total_amount__c)  desc';
  	//if(pec_limit)
  	  //base_query += ' ' + limit_filter;
  	for(AggregateResult ar : database.query(base_query)) {
  	  pec_ranking new_rank = new pec_ranking((String)ar.get('pec_name'),(Decimal)ar.get('total_payments'), sorting_rule);
  	  //not doing starts here as start definition has changed
  	  //new_rank.starts += (Integer)ar.get('num_starts');
  	  //pec_list.add(new_rank);
  	  pec_map.put((ID)ar.get('ownerid'),new_rank);
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grabbing starts
  	base_query = 'select owner.name pec_name,ownerid, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by owner.name,ownerid order by sum(negotiated_total_amount__c)  desc';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('ownerid'))==null) {
  	    pec_ranking new_rank = new pec_ranking((String)ar.get('pec_name'),0, sorting_rule);
  	    new_rank.starts += aggregate_value(ar, 'starts_value');
  	    pec_map.put((ID)ar.get('ownerid'),new_rank);
  	  }
  	  else
  	  	pec_map.get((ID)ar.get('ownerid')).starts += aggregate_value(ar, 'starts_value');
  	}
  	//grabbing cancel dollars
  	base_query = 'select Current_Prosth_Owner__r.name pec_name,Current_Prosth_Owner__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = ' + report_interval + ' and is_Valid_Start__c = true and account.center__r.type__c not in (\'Affiliate\',\'Network Center\')  group by Current_Prosth_Owner__r.name,Current_Prosth_Owner__c order by sum(negotiated_total_amount__c)  desc';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('Current_Prosth_Owner__c'))==null) {
  	    pec_ranking new_rank = new pec_ranking((String)ar.get('pec_name'),((Decimal)ar.get('total_payments') * -1), sorting_rule);
  	    pec_map.put((ID)ar.get('Current_Prosth_Owner__c'),new_rank);
  	  }
  	  else
  	  	pec_map.get((ID)ar.get('Current_Prosth_Owner__c')).display_value += ((Decimal)ar.get('total_payments') * -1);
  	}
  	/*modified by cm on 3-30-2015
  	  using consult_pec__c as teh consult owner going forward
  	*/
  	/*//working on consult number now
  	//grab consult numbers for all pecs - lead scheds first
  	base_query = 'select scheduled_lead__r.convertedaccount.ownerid oid,scheduled_lead__r.convertedaccount.owner.name uname,count(c.id) num_consults from Consult_Inventory__c c where c.apt_date__c = ' + report_interval +
  	  ' and active__c=true and arrival_time__c != null and scheduled_lead__c != null group by scheduled_lead__r.convertedaccount.ownerid,scheduled_lead__r.convertedaccount.owner.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).consults += (Integer)ar.get('num_consults');
  	}
  	//grab consult numbers for all pecs - consult scheds
  	base_query = 'select  scheduled_account__r.ownerid oid,scheduled_account__r.owner.name uname,count(c.id) num_consults from Consult_Inventory__c c where c.apt_date__c = ' + report_interval +
  	  ' and active__c=true and arrival_time__c != null and scheduled_account__c != null group by scheduled_account__r.ownerid,scheduled_account__r.owner.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).consults += (Integer)ar.get('num_consults');
  	}*/
  	//single query for consults now
    //modified by Alon W on 2016-08-24 - Added filters to exclude consults where isvalidcallback is true and consult_room_type is 'Practice'
  	base_query = 'select consult_pec__c oid,consult_pec__r.name uname,count(c.id) num_consults ' +
                    'from Consult_Inventory__c c ' +
                    'where c.apt_date__c = ' + report_interval + ' ' +
                    'and isvalidcallback__c = false ' +
                    'and consult_room__r.room_type__c != \'Practice\' ' +
  	                'and active__c=true ' +
                    'and arrival_time__c != null ' +
                    'group by consult_pec__c,consult_pec__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).consults += (Integer)ar.get('num_consults');
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grab in period cancellations
  	base_query = 'select Current_Prosth_Owner__c oid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c = ' + report_interval + '  and ignored_cancel__c = false and prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by Current_Prosth_Owner__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts -= aggregate_value(ar, 'cancelled_value');
  	}
  	//grab out of period cancellations
  	base_query = 'select Current_Prosth_Owner__c oid, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c = ' + report_interval + ' and prosth_exam_paid_date__c <> ' + report_interval + ' and ' +
  	  '  is_Valid_Start__c = true  and ignored_cancel__c = false ' +
  	  ' group by Current_Prosth_Owner__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts -= aggregate_value(ar, 'cancelled_value');
  	}

  	List<pec_ranking> temp_list = pec_map.values();
  	temp_list.sort();
  	Integer cnt = 0;
  	for(pec_ranking pr : temp_list) {
  	  if(cnt < 10 || !pec_limit)
  	    pec_list.add(pr);
  	  cnt++;
  	}
  	return pec_list;
  }

    public List<pec_ranking> getpec_revenue_per_start() {
        sorting_rule = 'revenue_per_start';
        return getpec_start_dollars();
    }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public list<pec_ranking> getcenter_start_dollars() {
  	String limit_filter = ' limit 10';
  	List<pec_ranking> pec_list = new List<pec_ranking>();
  	Map<ID,pec_ranking> pec_map = new Map<ID,pec_ranking>();

  	/*modified by cm on 2015-08-19
  	  I don't agree with this at all,  but code is being modified to combine Evanston and Chicago together.
  	  This is being done to placate a doctor and over my objections.
  	  It'll likely be an issue later when someone else operates these locations,  or when someone questions why the numbers on a different report don't match
  	*/
  	Center_Information__c chicago_center = [select id,name from Center_Information__c where name = 'Chicago'];

  	//grab sold dollars - where exam center is null
  	String base_query = 'select account.center__r.name center_name,account.center__c center_id, SUM(Start_Value__c) starts_value,sum(negotiated_total_amount__c) total_payments from opportunity where ' +
  	  ' Prosth_Exam_Paid_Date__c = ' + report_interval + ' and is_valid_start__c = true and exam_center__c = null group by account.center__r.name,account.center__c order by sum(negotiated_total_amount__c)  desc';
  	for(AggregateResult ar : database.query(base_query)) {
      if((String)ar.get('center_name')=='Chicago Evanston') {
      	if(pec_map.get(chicago_center.id)==null) {
  	      pec_ranking new_rank = new pec_ranking('Chicago',(Decimal)ar.get('total_payments'), sorting_rule);
  	      pec_map.put(chicago_center.id,new_rank);
  	    }
  	    else
  	  	  pec_map.get(chicago_center.id).display_value += (Decimal)ar.get('total_payments') ;
      }
      else {
  	    pec_ranking new_rank = new pec_ranking((String)ar.get('center_name'),(Decimal)ar.get('total_payments'), sorting_rule);
  	    pec_map.put((ID)ar.get('center_id'),new_rank);
      }
  	}
  	//grab sold dollars where exam center is not null
  	base_query = 'select exam_center__r.name center_name,exam_center__c center_id, SUM(Start_Value__c) starts_value,sum(negotiated_total_amount__c) total_payments from opportunity where ' +
  	  ' Prosth_Exam_Paid_Date__c = ' + report_interval + ' and is_valid_start__c = true and exam_center__c != null group by exam_center__r.name,exam_center__c order by sum(negotiated_total_amount__c)  desc';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('center_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('center_id');
  	  	center_name = (String)ar.get('center_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  	    pec_ranking new_rank = new pec_ranking(center_name,(Decimal)ar.get('total_payments'), sorting_rule);
  	    pec_map.put(center_id,new_rank);
  	  }
  	  else
  	  	pec_map.get(center_id).display_value += (Decimal)ar.get('total_payments') ;
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grabbing starts
  	base_query = 'select account.center__r.name center_name,account.center__c center_id, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by account.center__r.name,account.center__c order by sum(negotiated_total_amount__c)  desc';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('center_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('center_id');
  	  	center_name = (String)ar.get('center_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  	    pec_ranking new_rank = new pec_ranking(center_name, 0.00, sorting_rule);
  	    new_rank.starts += aggregate_value(ar, 'starts_value');
  	    pec_map.put(center_id,new_rank);
  	  }
  	  else
  	  	pec_map.get(center_id).starts += aggregate_value(ar, 'starts_value');
  	}

  	//grabbing cancel dollars - where exam center is null
  	base_query = 'select account.center__r.name center_name,account.center__c center_id,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = ' + report_interval + ' and is_valid_start__c = true and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') group by account.center__r.name,account.center__c order by sum(negotiated_total_amount__c)  desc';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('center_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('center_id');
  	  	center_name = (String)ar.get('center_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  	    pec_ranking new_rank = new pec_ranking(center_name,((Decimal)ar.get('total_payments') * -1), sorting_rule);
  	    pec_map.put(center_id,new_rank);
  	  }
  	  else
  	  	pec_map.get(center_id).display_value += ((Decimal)ar.get('total_payments') * -1);
  	}
  	//working on consult number now
    //modified by Alon W on 2016-08-24 - Added filters to exclude consults where isvalidcallback is true and consult_room_type is 'Practice'
  	base_query = 'select c.consult_room__r.center_information__c oid,c.consult_room__r.center_information__r.name uname,count(c.id) num_consults ' +
                    'from Consult_Inventory__c c ' +
                    'where c.apt_date__c = ' + report_interval + ' ' +
                    'and isvalidcallback__c = false ' +
                    'and consult_room__r.room_type__c != \'Practice\' ' +
  	                'and active__c=true ' +
                    'and arrival_time__c != null ' +
                    'group by c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('uname')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('oid');

  	  if(pec_map.get(center_id)!=null)
		pec_map.get(center_id).consults += (Integer)ar.get('num_consults');
  	}
    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
  	//grab in period cancellations
  	base_query = 'select account.center__c oid,account.center__r.name uname, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c = ' + report_interval + '  and ignored_cancel__c = false and prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by account.center__c,account.center__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('uname')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('oid');

  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts -= aggregate_value(ar, 'cancelled_value');
  	}
  	//grab out of period cancellations
  	base_query = 'select account.center__c oid, account.center__r.name uname, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c = ' + report_interval + ' and prosth_exam_paid_date__c <> ' + report_interval +
  	  ' and is_Valid_Start__c = true  and ignored_cancel__c = false ' +
      ' group by account.center__c,account.center__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('uname')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('oid');

  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts -= aggregate_value(ar, 'cancelled_value');
  	}

  	List<pec_ranking> temp_list = pec_map.values();
  	temp_list.sort();
  	Integer cnt = 0;
  	for(pec_ranking pr : temp_list) {
  	  if(cnt < 10 || !center_limit)
  	    pec_list.add(pr);
  	  cnt++;
  	}
  	return pec_list;
  }

          private Decimal aggregate_value(AggregateResult aggregate, String fieldname) {
              return (aggregate.get(fieldname) != null) ? (Decimal)aggregate.get(fieldname) : 0;
          }

    public List<pec_ranking> getcenter_revenue_per_start() {
        sorting_rule = 'revenue_per_start';
        return getcenter_start_dollars();
    }

  public list<pec_ranking> getpec_collected_dollars() {
  	String limit_filter = ' limit 10';
  	List<pec_ranking> pec_list = new List<pec_ranking>();
  	Map<ID,pec_ranking> pec_map = new Map<ID,pec_ranking>();
  	//grab collected dollars
  	String base_query = 'Select pec__r.name pec_name, pec__c oid,sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + report_interval + ' group by pec__r.name, pec__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  pec_ranking new_rank = new pec_ranking((String)ar.get('pec_name'), (Decimal)ar.get('total_payments'), sorting_rule);
  	  new_rank.display_value -= (Decimal)ar.get('total_gp_fee');
  	  pec_map.put((ID)ar.get('oid'),new_rank);
  	}
  	//grabbing cancel dollars
  	base_query = 'Select pec__r.name pec_name, pec__c oid,sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + report_interval + ' group by pec__r.name, pec__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))==null) {
  	    pec_ranking new_rank = new pec_ranking((String)ar.get('pec_name'), ((Decimal)ar.get('total_payments') * -1), sorting_rule);
  	    if(ar.get('total_gp_fee')!=null)
  	      new_rank.display_value += (Decimal)ar.get('total_gp_fee') ;
  	    pec_map.put((ID)ar.get('oid'),new_rank);
  	  }
  	  else {
  	  	pec_map.get((ID)ar.get('oid')).display_value += ((Decimal)ar.get('total_payments') * -1);
  	  	if(ar.get('total_gp_fee')!=null)
  	  	  pec_map.get((ID)ar.get('oid')).display_value += (Decimal)ar.get('total_gp_fee') ;
  	  }
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grabbing count of starts
  	base_query = 'select ownerid oid, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by owner.name,ownerid';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts += aggregate_value(ar, 'starts_value');
  	}
  	/*modified by cm on 3-30-1205
  	  using consult_pec__c as owner going forward
  	*/
  	//working on consult number now
  	//grab consult numbers for all pecs - lead scheds first
  	/*base_query = 'select scheduled_lead__r.convertedaccount.ownerid oid,scheduled_lead__r.convertedaccount.owner.name uname,count(c.id) num_consults from Consult_Inventory__c c where c.apt_date__c = ' + report_interval +
  	  ' and active__c=true and arrival_time__c != null and scheduled_lead__c != null group by scheduled_lead__r.convertedaccount.ownerid,scheduled_lead__r.convertedaccount.owner.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).consults += (Integer)ar.get('num_consults');
  	}
  	//grab consult numbers for all pecs - consult scheds
  	base_query = 'select  scheduled_account__r.ownerid oid,scheduled_account__r.owner.name uname,count(c.id) num_consults from Consult_Inventory__c c where c.apt_date__c = ' + report_interval +
  	  ' and active__c=true and arrival_time__c != null and scheduled_account__c != null group by scheduled_account__r.ownerid,scheduled_account__r.owner.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).consults += (Integer)ar.get('num_consults');
  	}*/
  	//single query for consults now
    /*modified by Alon W on 2016-08-24
        Uncommented filters to exclude consults where isvalidcallback is true and consult_room_type is 'Practice'
        I'm not sure why they were commented out, but they are appropriate, so I put them back in.
    */
  	base_query = 'select consult_pec__c oid,consult_pec__r.name uname,count(c.id) num_consults ' +
                    'from Consult_Inventory__c c ' +
                    'where c.apt_date__c = ' + report_interval + ' ' +
                    'and isvalidcallback__c = false ' +
                    'and consult_room__r.room_type__c != \'Practice\' ' +
                    'and active__c=true ' +
                    'and arrival_time__c != null ' +
                    'group by consult_pec__c,consult_pec__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).consults += (Integer)ar.get('num_consults');
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grab in period cancellations
  	base_query = 'select Current_Prosth_Owner__c oid, SUM(Start_Value__c) cancelled_value ' +
                    'from opportunity ' +
                    'where Cancel_Date__c = ' + report_interval + ' ' +
                    'and ignored_cancel__c = false ' +
                    'and prosth_exam_paid_date__c = ' + report_interval + ' ' +
                    'and is_Valid_Start__c = true ' +
                    'group by Current_Prosth_Owner__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts -= aggregate_value(ar, 'cancelled_value');
  	}
  	//grab out of period cancellations
  	base_query = 'select Current_Prosth_Owner__c oid, SUM(Start_Value__c) cancelled_value ' +
                    'from opportunity ' +
                    'where Cancel_Date__c = ' + report_interval + ' ' +
                    'and prosth_exam_paid_date__c <> ' + report_interval + ' ' +
                    'and is_Valid_Start__c = true  ' +
                    'and ignored_cancel__c = false ' +
  	                'group by Current_Prosth_Owner__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  if(pec_map.get((ID)ar.get('oid'))!=null)
  	    pec_map.get((ID)ar.get('oid')).starts -= aggregate_value(ar, 'cancelled_value');
  	}

  	List<pec_ranking> temp_list = pec_map.values();
  	temp_list.sort();
  	Integer cnt = 0;
  	for(pec_ranking pr : temp_list) {
  	  if(cnt < 10 || !collected_pec_limit)
  	    pec_list.add(pr);
  	  cnt++;
  	}
  	return pec_list;
  }

    public List<pec_ranking> getpec_collections_per_consult() {
        sorting_rule = 'collections_per_consult';
        return getpec_collected_dollars();
    }

  public list<pec_ranking> getcenter_collected_dollars() {
  	String limit_filter = ' limit 10';
  	List<pec_ranking> pec_list = new List<pec_ranking>();
  	Map<ID,pec_ranking> pec_map = new Map<ID,pec_ranking>();

  	/*modified by cm on 2015-08-19
  	  I don't agree with this at all,  but code is being modified to combine Evanston and Chicago together.
  	  This is being done to placate a doctor and over my objections.
  	  It'll likely be an issue later when someone else operates these locations,  or when someone questions why the numbers on a different report don't match
  	*/
  	Center_Information__c chicago_center = [select id,name from Center_Information__c where name = 'Chicago'];

  	//grab collected dollars - where exam center is null
  	String base_query = 'Select opportunity__r.account.center__r.name pec_name, opportunity__r.account.center__c oid,sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + report_interval + ' and opportunity__r.exam_center__c = null group by opportunity__r.account.center__r.name, opportunity__r.account.center__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('pec_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('oid');
  	  	center_name = (String)ar.get('pec_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  		pec_ranking new_rank = new pec_ranking(center_name, (Decimal)ar.get('total_payments'), sorting_rule);
  	    new_rank.display_value -= (Decimal)ar.get('total_gp_fee');
  	    pec_map.put(center_id,new_rank);
  	  }
  	  else {
  	    pec_map.get(center_id).display_value += (Decimal)ar.get('total_payments') ;
  	  	if(ar.get('total_gp_fee')!=null)
  	  	  pec_map.get(center_id).display_value += ((Decimal)ar.get('total_gp_fee') * -1) ;
  	  }
  	}

  	//grab collected dollars - where exam center is not null
  	base_query = 'Select opportunity__r.exam_center__r.name pec_name, opportunity__r.exam_center__c oid,sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + report_interval + ' and opportunity__r.exam_center__c != null group by opportunity__r.exam_center__r.name, opportunity__r.exam_center__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('pec_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('oid');
  	  	center_name = (String)ar.get('pec_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  	    pec_ranking new_rank = new pec_ranking(center_name, (Decimal)ar.get('total_payments'), sorting_rule);
  	    new_rank.display_value -= (Decimal)ar.get('total_gp_fee');
  	    pec_map.put(center_id,new_rank);
  	  }
  	  else {
  	  	pec_map.get(center_id).display_value += (Decimal)ar.get('total_payments') ;
  	  	if(ar.get('total_gp_fee')!=null)
  	  	  pec_map.get(center_id).display_value += ((Decimal)ar.get('total_gp_fee') * -1) ;
  	  }
  	}

  	//grabbing cancel dollars - where exam center is null
  	base_query = 'Select opportunity__r.account.center__r.name pec_name, opportunity__r.account.center__c oid,sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + report_interval + ' and opportunity__r.exam_center__c = null group by opportunity__r.account.center__r.name, opportunity__r.account.center__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('pec_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('oid');
  	  	center_name = (String)ar.get('pec_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  	  	//System.debug('AR ' + ar);
  	    pec_ranking new_rank = new pec_ranking(center_name, ((Decimal)ar.get('total_payments') * -1), sorting_rule);
  	    if(ar.get('total_gp_fee')!=null) {
  	      new_rank.display_value += (Decimal)ar.get('total_gp_fee');
  	    }
  	    pec_map.put(center_id,new_rank);
  	  }
  	  else {
  	  	pec_map.get(center_id).display_value += ((Decimal)ar.get('total_payments') * -1);
  	  	if(ar.get('total_gp_fee')!=null)
  	  	  pec_map.get(center_id).display_value += (Decimal)ar.get('total_gp_fee') ;
  	  }
  	}

  	//grabbing cancel dollars - where exam center is null
  	base_query = 'Select opportunity__r.exam_center__r.name pec_name, opportunity__r.exam_center__c oid,sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + report_interval + ' and opportunity__r.exam_center__c != null group by opportunity__r.exam_center__r.name, opportunity__r.exam_center__c';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  String center_name;
  	  if((String)ar.get('pec_name')=='Chicago Evanston') {
  	  	center_id = chicago_center.id;
  	  	center_name = 'Chicago';
  	  }
  	  else {
  	  	center_id = (ID)ar.get('oid');
  	  	center_name = (String)ar.get('pec_name');
  	  }

  	  if(pec_map.get(center_id)==null) {
  	  	//System.debug('AR ' + ar);
  	    pec_ranking new_rank = new pec_ranking(center_name, ((Decimal)ar.get('total_payments') * -1), sorting_rule);
  	    if(ar.get('total_gp_fee')!=null) {
  	      new_rank.display_value += (Decimal)ar.get('total_gp_fee');
  	    }
  	    pec_map.put(center_id,new_rank);

  	  }
  	  else {
  	  	pec_map.get(center_id).display_value += ((Decimal)ar.get('total_payments') * -1);
  	  	if(ar.get('total_gp_fee')!=null)
  	  	  pec_map.get(center_id).display_value += (Decimal)ar.get('total_gp_fee') ;
  	  }
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grab starts
  	base_query = 'select account.center__c center_id,account.center__r.name center_name, SUM(Start_Value__c) starts_value from opportunity where prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by account.center__c,account.center__r.name ';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('center_name')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('center_id');

  	  if(pec_map.get(center_id)!=null)
  	    pec_map.get(center_id).starts += aggregate_value(ar, 'starts_value');
  	}

  	//working on consult number now
    //modified by Alon W on 2016-08-24 - Added filters to exclude consults where isvalidcallback is true and consult_room_type is 'Practice'
  	base_query = 'select c.consult_room__r.center_information__c oid,c.consult_room__r.center_information__r.name uname,count(c.id) num_consults ' +
                    'from Consult_Inventory__c c ' +
                    'where c.apt_date__c = ' + report_interval + ' ' +
                    'and isvalidcallback__c = false ' +
                    'and consult_room__r.room_type__c != \'Practice\' ' +
  	                'and active__c=true ' +
                    'and arrival_time__c != null ' +
                    'group by c.consult_room__r.center_information__c, c.consult_room__r.center_information__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('uname')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('oid');

  	  if(pec_map.get(center_id)!=null)
		pec_map.get(center_id).consults += (Integer)ar.get('num_consults');
  	}

    // modified by aw 2016-06-20: For Starts and Cancelled Starts
    // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
    // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  	//grab in period cancellations
  	base_query = 'select account.center__c oid,account.center__r.name uname, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c = ' + report_interval + '  and ignored_cancel__c = false and prosth_exam_paid_date__c = ' + report_interval + ' and is_Valid_Start__c = true group by account.center__c,account.center__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('uname')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('oid');

  	  if(pec_map.get(center_id)!=null)
  	    pec_map.get(center_id).starts -= aggregate_value(ar, 'cancelled_value');
  	}
  	//grab out of period cancellations
  	base_query = 'select account.center__c oid,account.center__r.name uname, SUM(Start_Value__c) cancelled_value from opportunity where Cancel_Date__c = ' + report_interval + ' and prosth_exam_paid_date__c <> ' + report_interval +
  	  ' and is_Valid_Start__c = true  and ignored_cancel__c = false ' +
      ' group by account.center__c,account.center__r.name';
  	for(AggregateResult ar : database.query(base_query)) {
  	  ID center_id;
  	  if((String)ar.get('uname')=='Chicago Evanston')
  	  	center_id = chicago_center.id;
  	  else
  	  	center_id = (ID)ar.get('oid');

  	  if(pec_map.get(center_id)!=null)
  	    pec_map.get(center_id).starts -= aggregate_value(ar, 'cancelled_value');
  	}

  	List<pec_ranking> temp_list = pec_map.values();
  	temp_list.sort();
  	Integer cnt = 0;
  	for(pec_ranking pr : temp_list) {
  	  if(cnt < 10 || !collected_center_limit)
  	    pec_list.add(pr);
  	  cnt++;
  	}
  	return pec_list;
  }

    public List<pec_ranking> getcenter_collections_per_consult() {
        sorting_rule = 'collections_per_consult';
        return getcenter_collected_dollars();
    }

}