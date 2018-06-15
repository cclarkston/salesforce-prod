global class zip_cleanup {
  @future(callout=true)
  public static void clean_zips() {       
    List<Lead> update_list = new List<Lead>();
	  List<Zip_Demographic__c> update_zips = [select id,zipcode__c,leads_updated__c from Zip_Demographic__c where leads_updated__c = false limit 99];
    for(Zip_Demographic__c zip : update_zips) {   
 	    System.debug('Zip Code : ' + zip.zipcode__c);
 	    String lead_query = 'select id,zip_demographic__c from lead where isconverted = false and postalcode like \'' + zip.zipcode__c + '%\'';
 	    System.debug('Lead lookup Query : ' + lead_query);
 	    for(Lead l : database.query(lead_query)) {
 	    	l.Zip_Demographic__c = zip.id;
 	    	update_list.add(l);
 	    }
 	    System.debug('Update Leads Size : ' + update_list.size());
 	    zip.leads_updated__c = true; 	    
    }
    update update_zips; 
    if(update_list.size()>0) {
      Util_TriggerContext.setalreadyProcessed();
      update update_list;      
    }
  }
}