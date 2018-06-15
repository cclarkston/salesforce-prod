public with sharing class ctrl_treatmentplan {
  private Treatment_Plan__c tp;  
  ApexPages.Standardcontroller con;
  
  public ctrl_treatmentplan(ApexPages.StandardController stdController) {
        this.tp = (Treatment_Plan__c)stdController.getRecord();
    con = stdController;
  }
  
  //grab doctor list
  public List<SelectOption> getdoctor_list() {
        //figure out the center and grab a list of doctors for it
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','No Doctor Selected'));
        Treatment_Plan__c tpc = [select id,account__r.center__c from Treatment_Plan__c where id  = :tp.id];
        for(ClearChoice_Doctor__c cd : [Select c.id,c.Name From ClearChoice_Doctor__c c where c.center_information__c = :tpc.account__r.center__c]) {
          options.add(new SelectOption(cd.id,cd.name));  
        }
        return options;
  }
  
  //quick save on doctor change 
  public void quick_save() {
        con.save();
        this.tp = (Treatment_Plan__c)con.getRecord();
  }
}