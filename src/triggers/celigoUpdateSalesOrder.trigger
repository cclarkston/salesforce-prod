trigger celigoUpdateSalesOrder on NetSuite_Sales_Order__c (before insert, before update, before delete) {
	
	if (System.Trigger.new != null) {
		List<Id> opIds = new List<Id>();
		for(NetSuite_Sales_Order__c order: System.Trigger.new) {
			if (order.Opportunity__c == null)
				continue;
			opIds.add(order.Opportunity__c);
		}
		List<Opportunity> ops = [select id, StageName, StageNameState__c from Opportunity where Id IN :opIds];
		celigo_connector__c cs = celigo_connector__c.getInstance('Opportunity Closed Stage');
        String closedStage = (cs!=null)?cs.value__c:'Closed Won';
		for (Opportunity o : ops){
			if (Trigger.isInsert) {
				if (o.StageNameState__c == null) {
					o.StageNameState__c = o.StageName;
		        	o.StageName = closedStage;
		        }
			}
			o.Celigo_Sync_Helper__c = true;
			update o;
		}
	}
    
    if (Trigger.isDelete && System.Trigger.old != null)	{
    	List<Id> opIds = new List<Id>();
    	for (NetSuite_Sales_Order__c order: System.Trigger.old) {
    		if (order.Opportunity__c == null)
				continue;
			opIds.add(order.Opportunity__c);
    	}
    	
    	List<Opportunity> ops = [select id, StageName, StageNameState__c from Opportunity where Id IN :opIds];
    	List<NetSuite_Sales_Order__c> tOrders = [select id, Opportunity__c from NetSuite_Sales_Order__c where Opportunity__c IN :opIds];
    	Map<Id,List<NetSuite_Sales_Order__c>> m = new Map<Id,List<NetSuite_Sales_Order__c>>();
    	for(NetSuite_Sales_Order__c order : tOrders){
    		if(m.get(order.Opportunity__c) == null)
    			m.put(order.Opportunity__c, new NetSuite_Sales_Order__c[]{order});
    		else{
    			List<NetSuite_Sales_Order__c> temp = m.get(order.Opportunity__c);
    			temp.add(order);
    		}	
    	}
    	Set<Id> keys = m.keySet();
    	
    	for(Id i : keys){
    		List<NetSuite_Sales_Order__c> temp = m.get(i);
    		Opportunity op;
    		for(Opportunity tempOp : ops){
    			if(tempOp.Id == i){
    				op = tempOp;
    				break;
    			}
    		}
    		if(temp.size() > 1)
    			continue;
    		if(op.StageNameState__c == null)
    			continue;
    		op.StageName = op.StageNameState__c;
    		op.StageNameState__c = null;
    		update op;
    	}
    }
}