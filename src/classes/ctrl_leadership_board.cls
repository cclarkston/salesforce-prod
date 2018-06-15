/*modified by cm on 6/28/2017
  cancels are now defined by cancel_date__c != null
  removed references to stagename and competed stage
*/
public without sharing class ctrl_leadership_board {

  Decimal collected;
  Decimal refunded;
  public String all_filter = '';

  public ctrl_leadership_board() {
	if(test.isRunningTest())
      all_filter = ' limit 10';
  }

  public Integer getConsultStarts() {
    return database.countQuery('select count() from Consult_Inventory__c c where isvalidcallback__c = false and c.apt_date__c = this_month and consult_room__r.center_information__r.type__c not in (\'Affiliate\',\'Network Center\') and consult_room__r.room_type__c != \'Practice\' and active__c=true and arrival_time__c != null ' + all_filter);
  }

  // modified by aw 2016-06-20: For Starts and Cancelled Starts
  // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
  // Also changed value to be SUM(Start_Value__c) instead of a simple count of the records.
  public Decimal getStarts() {
 //  	return database.countQuery('select count() from opportunity where prosth_exam_paid_date__c = THIS_MONTH and negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') ' + all_filter);
	AggregateResult[] aggregate = database.query('select SUM(Start_Value__c) from opportunity where prosth_exam_paid_date__c = THIS_MONTH and is_Valid_Start__c = true and account.center__r.type__c not in (\'Affiliate\',\'Network Center\')' + ' GROUP BY is_Valid_Start__c' + all_filter);
	return aggregate_value(aggregate);
  }

  public Decimal getStartsCancelled() {
  	Decimal all_cancels = 0;
	//String base_query = 'select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and Cancel_Date__c = this_month and ignored_cancel__c = false and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))';
	String base_query = 'select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and Cancel_Date__c = this_month and ignored_cancel__c = false and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') ';
	AggregateResult[] aggregate = database.query(base_query + ' and prosth_exam_paid_date__c = this_month' + ' GROUP BY is_Valid_Start__c' + all_filter);
	all_cancels += aggregate_value(aggregate);
	aggregate = database.query(base_query + ' and prosth_exam_paid_date__c <> this_month' + ' GROUP BY is_Valid_Start__c' + all_filter);
  	all_cancels += aggregate_value(aggregate);
  	return all_cancels * -1;
  }

		  private Decimal aggregate_value(AggregateResult[] aggregate) {
			  return aggregate_has_data(aggregate) ? (Decimal)aggregate[0].get('expr0') : 0;
		  }

		  private Boolean aggregate_has_data(AggregateResult[] aggregate) {
			  return (aggregate.size() > 0 && aggregate[0].get('expr0') != null);
		  }


  public Decimal getCollected() {
  	if(collected==null) {
  	  collected = 0.00;
  	  for(AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c where payment_status_formula__c = \'Collected\' and payment_date__c = this_month')) {
        if(results.get('total_payments')==null)
          collected = 0;
        else
          collected = (Decimal)results.get('total_payments');
      }
  	}
  	return collected;
  }

  public Decimal getRefunded() {
  	if(refunded==null) {
  	  collected = 0.00;
  	  for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = this_month')) {
        if(results.get('total_payments')==null)
          refunded = 0;
        else
          refunded = (Decimal)results.get('total_payments') * -1;
      }
  	}
  	return refunded;
  }

}