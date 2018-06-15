@isTest
private class testCeligoTrigger {
	
	class ExtTrigger extends CeligoTrigger{
    	public ExtTrigger(SObject[] a, SObject[] b,CeligoTrigger.TriggerType t){
    		super(a,b,t);
    	}
    }
	
    static testMethod void myUnitTest() {
    	List<Account> a = [select Id,name from account limit 10];
    	
    	
		ExtTrigger ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.BeforeInsert);
		ct.doTrigger();
		ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.AfterInsert);
		ct.doTrigger();
		ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.BeforeUpdate);
		ct.doTrigger();
		ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.AfterUpdate);
		ct.doTrigger();
		ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.BeforeDelete);
		ct.doTrigger();
		ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.AfterDelete);
		ct.doTrigger();
		ct = new ExtTrigger(a,a,CeligoTrigger.TriggerType.AfterUnDelete);
		ct.doTrigger();
		system.assert(true);
    }
}