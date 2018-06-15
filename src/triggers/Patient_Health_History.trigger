trigger Patient_Health_History on Patient_Health_History__c (after insert, after update) {
    
  Set<ID> account_ids = new Set<ID>();
  Map<ID,Account> account_map;
  
  for(Patient_Health_History__c phh : Trigger.new) {
  	if(phh.work_phone__c!=null)
  	  account_ids.add(phh.account__c);  	  
  }
    
  //see if we have any phone #'s to update
  if(account_ids.size()>0) {
  	account_map = new Map<ID,Account> ([select id,business_phone__c from account where id in :account_ids]);
  	
  	//cycle through trigger again and update account records 
  	for(Patient_Health_History__c phh : Trigger.new) {
  	  if(phh.work_phone__c!=null)
  	    if(account_map.get(phh.account__c).business_phone__c==null)
          account_map.get(phh.account__c).business_phone__c = phh.work_phone__c;
    }
    
    update account_map.values();
  }
  
  
    
}