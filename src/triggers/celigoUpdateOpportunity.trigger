trigger celigoUpdateOpportunity on Opportunity (before insert, before update) {
    for (Opportunity opportunity: System.Trigger.new) {
        if (opportunity.Celigo_Update__c) {
            opportunity.Celigo_Update__c = false;
            continue;
        }
        
        if (Trigger.isInsert) {
            opportunity.StageNameState__c = null;
            opportunity.Send_to_NetSuite__c = false;
            opportunity.Generate_Estimate__c = false;
            opportunity.Generate_Sales_Order__c = false;
            opportunity.NetSuite_Quote__c = null;
            opportunity.NS_Sync__c = null;
        }
    }
}