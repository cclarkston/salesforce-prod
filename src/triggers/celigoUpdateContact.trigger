trigger celigoUpdateContact on Contact (before insert, before update) {
  
    /*List<Id> ids = new List<Id>();
    for (Contact contact: System.Trigger.new) {
        if (contact.AccountId != null && !contact.NetSuite_Locked__c && !contact.Celigo_Update__c)        
            ids.add(contact.AccountId);
    }
    List<Account> acs = new List<Account>();
    
    if(!ids.isEmpty())acs = [select Id, NetSuite_Id__c from account where id IN :ids];
  
    for (Contact contact: System.Trigger.new) {
        
        if (contact.AccountId == null  || contact.NetSuite_Locked__c)
            continue; 
        
        if (contact.Celigo_Update__c) {
            contact.Celigo_Update__c = false;
            continue;
        }
        
        if (Trigger.isInsert) {
            contact.NetSuite_Id__c = null;
            contact.NetSuite_Locked__c = false;
            contact.NS_Sync__c = null;
        }
        
        if (contact.NetSuite_Id__c == null && contact.Email == null) {
            contact.NetSuite_Push__c = false;
            contact.NetSuite_Pull__c = false; 
            continue;
        }
        
        Integer index = -1;
        for(Integer i = 0; i< acs.size(); i++){
          if(acs[i].Id == contact.AccountId){
            index=i;
            break;
          }
        }
        
        if (index == -1 || acs[index].NetSuite_Id__c == null){
            continue; 
        }
        
        contact.NetSuite_Push__c = true;
        contact.NetSuite_Pull__c = true;   
    }*/
}