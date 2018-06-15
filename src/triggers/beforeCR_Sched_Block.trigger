trigger beforeCR_Sched_Block on CR_Schedule_Block__c (before update, before insert) {
  if(trigger.isInsert) {
  	for(CR_Schedule_Block__c csb : Trigger.new) {
  	  if(csb.dow__c==1)
  	    csb.dow_picklist__c = 'Monday';
  	  if(csb.dow__c==2)
  	    csb.dow_picklist__c = 'Tuesday';
	  if(csb.dow__c==3)
  	    csb.dow_picklist__c = 'Wednesday';
  	  if(csb.dow__c==4)
  	    csb.dow_picklist__c = 'Thursday';
  	  if(csb.dow__c==5)
  	    csb.dow_picklist__c = 'Friday';
  	  if(csb.dow__c==6)
  	    csb.dow_picklist__c = 'Saturday';
  	  if(csb.dow__c==7)
  	    csb.dow_picklist__c = 'Sunday';
  	  Integer shour = Integer.valueof(csb.start_time__c.left(2).replace(':',''));
  	  if(csb.start_time__c.right(2)=='PM' && shour!=12)
  	    shour+=12;  	    	
  	  csb.start_hour__c = String.valueof(shour);
  	  Integer sminute = Integer.valueof(csb.start_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  csb.start_minute__c = String.valueof(sminute);  	  
  	  Integer ehour = Integer.valueof(csb.end_time__c.left(2).replace(':',''));
  	  if(csb.end_time__c.right(2)=='PM' && ehour!=12)
  	    ehour+=12;  	    	
  	  csb.end_hour__c = String.valueof(ehour);  	  
  	  Integer eminute = Integer.valueof(csb.end_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  csb.end_minute__c = String.valueof(eminute);
  	}
  }	
	
  if(trigger.isUpdate) {  	
  	for(CR_Schedule_Block__c csb : Trigger.new) {
  	  if(csb.Num_Authorized_Apts__c==0)
  	    csb.allow_all__c = true;
  	  else
  	    csb.allow_all__c = false;
  	  Integer shour = Integer.valueof(csb.start_time__c.left(2).replace(':',''));
  	  if(csb.start_time__c.right(2)=='PM' && shour!=12)
  	    shour+=12;  	    	
  	  csb.start_hour__c = String.valueof(shour);
  	  Integer sminute = Integer.valueof(csb.start_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  csb.start_minute__c = String.valueof(sminute);  	  
  	  Integer ehour = Integer.valueof(csb.end_time__c.left(2).replace(':',''));
  	  if(csb.end_time__c.right(2)=='PM' && ehour!=12)
  	    ehour+=12;  	    	
  	  csb.end_hour__c = String.valueof(ehour);  	  
  	  Integer eminute = Integer.valueof(csb.end_time__c.right(5).replace(' AM','').replace(' PM',''));
  	  csb.end_minute__c = String.valueof(eminute);
  	}
  } 
}