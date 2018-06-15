/*
Created by CM on 10/3/2013 
This trigger is going to be used to prevent people from switching a payment from Anticipated Promise Note to Collected

modified by cm on 5/4/2016
removed the soql queries from the for loops to prevent limit issues
*/
trigger UpdateCCPayment on CCPayment__c (before update, before insert) {

  //pull a map of opportunity records for the payments we're working on here
  Set<ID> opp_id = new Set<ID>();
  for(CCPayment__c my_payment : Trigger.new) {
  	opp_id.add(my_payment.opportunity__c);
  }
  List<Opportunity> olist = [select id,name,windent_patient_id__c,account.referral_office__c,account.referral_office__r.name,account.center__c,current_Prosth_Owner__c,account.center__r.windent_id_required__c from Opportunity where id in :opp_id];
  Map<ID,Opportunity> opp_map = new Map<Id,Opportunity> (olist);	
	
  if(trigger.isBefore && trigger.isinsert) {
	for(CCPayment__c my_payment : Trigger.new) {
	  //Opportunity o = [select id,name,current_Prosth_Owner__c from Opportunity where id = :my_payment.opportunity__c];
	  Opportunity o = opp_map.get(my_payment.opportunity__c);
	  my_payment.pec__c = o.current_prosth_owner__c;
	}
  }
	

  if(trigger.isBefore && trigger.isupdate) {
		for(CCPayment__c my_payment : Trigger.new) {
		  CCPayment__c beforeUpdate = System.Trigger.oldMap.get(my_payment.Id);
		  //Opportunity o = [select id,name,windent_patient_id__c from Opportunity where id = :my_payment.opportunity__c];
		  Opportunity o = opp_map.get(my_payment.opportunity__c);
		  
		  if(my_payment.service_date__c==null)
		    my_payment.service_date__c = my_payment.payment_date__c;
		  
		  if(beforeupdate.payment_date__c!=null)
		    if(my_payment.payment_date__c < beforeUpdate.payment_date__c)
		      my_payment.backdated_payment__c = true;
		    
		  if(o.Windent_Patient_Id__c==null && o.account.center__r.windent_id_required__c) {
		    my_payment.addError('You must fill out the Windent Patient ID,  on the prosth exam record,  before making any changes to payment info');
		  }
		  
		  
		  if(my_payment.Payment_Status__c=='Collected' && beforeUpdate.payment_status__c=='Anticipated Promise Note') {
		    my_payment.payment_status__c.adderror('You can not switch an Anticipated Promise Note to Collected.  Please use Collected Promise Note instead');
		    my_payment.addError('You can not switch an Anticipated Promise Note to Collected.  Please use Collected Promise Note instead');
		  }
		  
		  //test to see if a payment status was changed to collected
		  if((my_payment.Payment_Status__c=='Collected' || my_payment.Payment_Status__c=='Collected Promise Note')  && (my_payment.Payment_Status__c != beforeUpdate.payment_status__c || my_payment.collected_date__c==null)) {
		  	my_payment.collected_date__c = System.today();
		  }
		    
		} 
	
  }
 
}