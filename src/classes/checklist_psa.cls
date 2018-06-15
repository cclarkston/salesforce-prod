public without sharing class checklist_psa {
  private final Implementation_Checklist__c ic;
  public Dental_Practice__c dp {get; set;}  
  ApexPages.Standardcontroller con;
  
  public checklist_psa(ApexPages.StandardController stdController) {
    this.ic = (Implementation_Checklist__c)stdController.getRecord();
    con = stdController;    
    dp = [select id,PSA_Effective_Date__c,PSA_Contract_Completed__c from Dental_Practice__c where id = :ic.dental_practice__c];
  }
  
  public void psa_updated() {
  	update dp;
  }
}