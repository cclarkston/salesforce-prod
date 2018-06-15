trigger UpdatePrivatePracticePayment on Private_Practice_Payment__c (before update,before insert) {
  
  if(trigger.isUpdate) {
  	
    for(Private_Practice_Payment__c my_payment : Trigger.new) {
	  Private_Practice_Payment__c beforeUpdate = System.Trigger.oldMap.get(my_payment.Id);
	  if(my_payment.private_practice_patient__c!=null && my_payment.cc_sales_order__c==null) {
	    Private_Practice_Patient__c pp = [select id,name,Practice_ID__c from Private_Practice_Patient__c where id = :my_payment.Private_Practice_Patient__c];
	    if(pp.Practice_Id__c==null) 
	      my_payment.addError('You must fill out the Windent Patient ID,  on the private pratice pratient record,  before making any changes to payment info');
	  }
	  if(my_payment.Opportunity__c!=null) {
	  	Opportunity o = [select id,name,windent_patient_id__c,account.center__r.windent_id_required__c from Opportunity where id = :my_payment.opportunity__c];
	  	if(o.Windent_Patient_Id__c==null && o.account.center__r.windent_id_required__c) 
		  my_payment.addError('You must fill out the Windent Patient ID,  on the prosth exam record,  before making any changes to payment info');
	  }
	  
		  
	  if(my_payment.service_date__c==null)
	    my_payment.service_date__c = my_payment.payment_date__c;
	    
	  if(beforeupdate.payment_date__c!=null)
		if(my_payment.payment_date__c < beforeUpdate.payment_date__c)
		  my_payment.backdated_payment__c = true;	    	  
		  
	  if(my_payment.Payment_Status__c=='Collected' && beforeUpdate.payment_status__c=='Anticipated Promise Note') {
	    my_payment.payment_status__c.adderror('You can not switch an Anticipated Promise Note to Collected.  Please use Collected Promise Note instead');
	    my_payment.addError('You can not switch an Anticipated Promise Note to Collected.  Please use Collected Promise Note instead');
	  }
	
	  //test to see if a payment status was changed to collected
	  if((my_payment.Payment_Status__c=='Collected' || my_payment.Payment_Status__c=='Collected Promise Note')  && my_payment.Payment_Status__c != beforeUpdate.payment_status__c) {
	  	my_payment.collected_date__c = System.today();
	  }
		    
	}
	 
  }
  
  if(trigger.isInsert) {
  	
  	for(Private_Practice_Payment__c my_payment : Trigger.new) {
  	  if(my_payment.private_practice_patient__c!=null) {
	    Private_Practice_Patient__c pp = [select id,name,center__r.name from Private_Practice_Patient__c where id = :my_payment.Private_Practice_Patient__c];
	    my_payment.center_location__c = pp.center__r.name;
  	  }
  	  if(my_payment.opportunity__c!=null) {
  	  	Opportunity o = [select id,name,account.center__r.name from Opportunity where id = :my_payment.opportunity__c];
  	  	my_payment.center_location__c = o.account.center__r.name;
  	  }
  	}
  }
}