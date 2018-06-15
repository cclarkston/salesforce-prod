trigger CeligoTrigger_ProductGroup_c on Product_Group__c (before insert,before update) {
    //null check
    if(Trigger.new.size()<1)return;
    
    //trigger context
    if(Trigger.isInsert&&Trigger.isBefore){
        new CeligoTrigger_ProductGroup_c(Trigger.new,Trigger.old,CeligoTrigger.TriggerType.BeforeInsert).doTrigger();
    }
    else if(Trigger.isUpdate&&Trigger.isBefore){
        new CeligoTrigger_ProductGroup_c(Trigger.new,Trigger.old,CeligoTrigger.TriggerType.BeforeUpdate).doTrigger();
    }
}