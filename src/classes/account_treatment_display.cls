public with sharing class account_treatment_display {
  private final Account a;  
  ApexPages.Standardcontroller con;
    
  public account_treatment_display(ApexPages.StandardController stdController) {
    this.a = (Account)stdController.getRecord();
    con = stdController;
  }
  
  //method to return current treatment plans for this consult
  public List<Treatment_Plan__c> getcurrent_treatment_plans() {
  	return [select id,account__c,ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c,Final_Cost__c,recommended__c,treatment_option__r.name,
  	  bleaching_tray__c,nightguard__c,bone_grafting__c,immediate_load__c,total_cost__c from Treatment_Plan__c where account__c = :a.id order by recommended__c desc];
  }
}