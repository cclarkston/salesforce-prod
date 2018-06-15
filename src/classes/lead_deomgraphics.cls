public with sharing class lead_deomgraphics {
  private final Lead l;  
  ApexPages.Standardcontroller con;
  public Zip_Demographic__c demo_data {get;set;}
  
  public lead_deomgraphics(ApexPages.StandardController stdController) {
    this.l = (Lead)stdController.getRecord();
    con = stdController;    
    Lead temp_lead = [select id,zip_demographic__c from Lead where id = :l.id];
    if(temp_lead.Zip_Demographic__c != null)
      demo_data = [select averagehousevalue__c,incomeperhousehold__c from Zip_Demographic__c where id = :temp_lead.zip_demographic__c];
  }
  
  public Decimal getaverage_income() {
  	if(demo_data==null)
  	  return null;
  	else
  	  return demo_data.incomeperhousehold__c;
  }
  
  public Decimal getaverage_house_value() {
  	if(demo_data==null)
  	  return null;
  	else
  	  return demo_data.AverageHouseValue__c;
  }
}