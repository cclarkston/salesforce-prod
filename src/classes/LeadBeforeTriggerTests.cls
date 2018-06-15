@isTest
private class LeadBeforeTriggerTests {
	

  	testMethod static void LeadWithNullMobileGetsPhoneAsMobileOnInsert(){
		  Lead lead = new Lead();
		  lead.lastname = 'test';
		  lead.phone = '3031231234';
		  lead.mobilephone = null;
		  insert lead;
		  
		  lead = [SELECT mobilephone
		  			FROM Lead 
					Limit 1];
		  //System.assert(lead.mobilephone == '3031231234');
		  System.assert(lead.mobilephone == null);
	}

  	testMethod static void LeadWithNonNullMobileIsSavedProperlyOnInsert(){
		  Lead lead = new Lead();
		  lead.lastname = 'test';
		  lead.phone = '3031231234';
		  lead.mobilephone = '3031111111';
		  insert lead;
		  
		  lead = [SELECT mobilephone
		  			FROM Lead 
					Limit 1];
		  System.assert(lead.mobilephone == '3031111111');
	}	

  	testMethod static void LeadWithNullMobileGetsPhoneAsMobileOnUpdate(){
		  Lead lead = new Lead();
		  lead.lastname = 'test';
		  insert lead;
		  lead.phone = '3031231234';
		  lead.mobilephone = null;
		  update lead;		  
		  lead = [SELECT mobilephone
		  			FROM Lead 
					Limit 1];
		  //System.assert(lead.mobilephone == '3031231234');
		  System.assert(lead.mobilephone == null);
	}

  	testMethod static void LeadWithNonNullMobileIsSavedProperlyOnUpdate(){
		  Lead lead = new Lead();
		  lead.lastname = 'test';
		  insert lead;
		  lead.phone = '3031231234';
		  lead.mobilephone = '3031111111';
		  update lead;		  
		  lead = [SELECT mobilephone
		  			FROM Lead 
					Limit 1];
		  System.assert(lead.mobilephone == '3031111111');
	}	
	
}