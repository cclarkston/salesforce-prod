trigger CeligoTrigger_OpportunityLineItem on OpportunityLineItem (after insert, before insert, after update, after delete) {
    //null check for the trigger input
    if(Trigger.size<0)return;
    
    //context check
    if(Trigger.isBefore && Trigger.isInsert){
        new CeligoTrigger_OpportunityLineItem(Trigger.new,Trigger.old, CeligoTrigger.TriggerType.BeforeInsert).doTrigger();
    //context check
    }else if(Trigger.isAfter && Trigger.isInsert){
        new CeligoTrigger_OpportunityLineItem(Trigger.new,Trigger.old, CeligoTrigger.TriggerType.AfterInsert).doTrigger();
    }else if(Trigger.isAfter && Trigger.isUpdate){
        new CeligoTrigger_OpportunityLineItem(Trigger.new,Trigger.old, CeligoTrigger.TriggerType.AfterUpdate).doTrigger();
    }else if(Trigger.isAfter && Trigger.isDelete){
        new CeligoTrigger_OpportunityLineItem(Trigger.new,Trigger.old, CeligoTrigger.TriggerType.AfterDelete).doTrigger();
    }
}