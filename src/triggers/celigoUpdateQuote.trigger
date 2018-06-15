trigger celigoUpdateQuote on NetSuite_Estimate__c (before insert, before update) {
	List<Id> quoteIds = new List<Id>();
	for (NetSuite_Estimate__c quote: System.Trigger.new) {
        if (quote.Opportunity__c == null)
			continue;
		quoteIds.add(quote.Opportunity__c);
	}
	
	List<Opportunity> ops = [select id, Celigo_Sync_Helper__c from Opportunity where Id IN :quoteIds];
	
	for (Opportunity o : ops)
        o.Celigo_Sync_Helper__c = true;
    
    update ops; 
}