trigger celigoUpdateAccount on Account(before insert, before update) {
    for (Account account: System.Trigger.new) {
            
        if (account.Celigo_Update__c) {
            account.Celigo_Update__c = false;
            continue;
        }
        
        if (Trigger.isInsert) {
            account.NetSuite_Id__c = null;
            account.NetSuite_Locked__c = false;
            account.NS_Sync__c = null;
        }
        
        if (account.NetSuite_Id__c == null || account.NetSuite_Locked__c)
            continue;
        
        account.NetSuite_Push__c = true;
        account.NetSuite_Pull__c = true;
    }
}