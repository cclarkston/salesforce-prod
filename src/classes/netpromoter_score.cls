public without sharing class netpromoter_score {  
  
  public netpromoter_score() {
  	
  }
  
  public static String GetUserIPAddress() {
    string ReturnValue = '';
    try {
      ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
      if (ReturnValue == '') {
        ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
      } // get IP address when no caching (sandbox, dev, secure urls)
    } catch (Exception e) {
      //likely a test script call not coming from a site page
    }
    return ReturnValue;
  } 
  
  public void record_net_promoter_score() {
  	try {
	  	String nscore = apexpages.currentpage().getparameters().get('nps');
	  	if(nscore.isnumeric()) {
	  	  Integer nvalue = Integer.valueof(nscore);
	  	  if(nvalue<0 || nvalue >10)
	  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Score value is invalid'));
	  	  else {
	  	    try {	  	      
	          Net_Promoter_Survery__c nps = new Net_Promoter_Survery__c(NPscore__c = nvalue, opp_id__c = apexpages.currentpage().getparameters().get('oid'), patient_ip__c = GetUserIPAddress());
	          insert nps;		  		
	  	    } catch (Exception e) {
	  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error recording score'));
	  		  ApexPages.addMessages(e);
	  	    }
	  	  }
	  	} else {
	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Score value is invalid'));	
	  	}
    } catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Values likely not provided in params'));
      ApexPages.addMessages(e);
    }
  }
}