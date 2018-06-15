public class CenterInfoExtension {
  private final Center_Information__c ci;
  public CenterInfoExtension(ApexPages.StandardController stdController) {        
    this.ci = (Center_Information__c)stdController.getRecord();    
  }
  
  public PageReference autoRun() {         
    String theId = ApexPages.currentPage().getParameters().get('id');         
    
    if (theId == null) 	// Display the Visualforce page's content if no Id is passed over                             
    	return null;        
    	
    for (Center_Information__c ci: [select id,name,Aval_Cnslts_This_Week__c,aval_cnslts_next_week__c,
      aval_cnslts_2nd_week__c,aval_cnslts_3rd_week__c,aval_cnslts_4th_week__c from center_information__c  
      where id =:theId]) {            
      ci.Aval_Cnslts_This_Week__c = ci.Aval_Cnslts_Next_Week__c;
      ci.Aval_Cnslts_Next_Week__c = ci.Aval_Cnslts_2nd_Week__c;
      ci.Aval_Cnslts_2nd_Week__c = ci.Aval_Cnslts_3rd_Week__c;
      ci.Aval_Cnslts_3rd_Week__c = ci.Aval_Cnslts_4th_Week__c;
      ci.Aval_Cnslts_4th_Week__c = 0;
      update ci;
    }         
    
    // Redirect the user back to the original page        
    PageReference pageRef = new PageReference('/' + theId);        
    pageRef.setRedirect(true);        
    return pageRef;     
  }

  
  static testMethod void LeadTest() {
  	Market__c m = new Market__c(Name = 'Test Market');
		Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,
		  Aval_Cnslts_This_Week__c = 10, Aval_Cnslts_Next_Week__c = 20, Aval_Cnslts_2nd_Week__c = 30, Aval_Cnslts_3rd_Week__c = 40, Aval_Cnslts_4th_Week__c = 50);
	  insert test_center;   
  	test.startTest();  	  
  	Apexpages.Standardcontroller st = new Apexpages.Standardcontroller(test_center);
  	CenterInfoExtension ctrl = new CenterInfoExtension(st);
  	ctrl.autoRun();
  	test.stopTest();
  }
}