public with sharing class ctrl_drmastery_center_admin {
  public Integer current_month {get;set;}
  public Integer current_year {get;set;}
  public List<Doctor_Mastery_Center_Snapshot__c> snap_list {get;set;}
    
  public ctrl_drmastery_center_admin() {
    current_month = System.today().month();
    current_year = System.today().year();
    refresh_snap_list();
  }
    
  public List<Selectoption> getmonth_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	//pull a list of all months we have snapshot data for,  in the current year
  	/*of course they won't let you group by month__c (nonsense)
  	for(Aggregateresult ar : [select month__c from Doctor_Mastery_Center_Snapshot__c where year__c = :current_year group by month__c order by month__c]) {
  	  //Integer ar_month = Integer.valueof((String)ar.get('month__c'));	  
  	  //clist.add(new SelectOption(String.valueof(ar_month),Datetime.newinstance(current_year,ar_month,1).format('MMMM')));
    }*/
    clist.add(new Selectoption('0','Select Month'));
    Set<Integer> query_month = new Set<Integer>(); 
  	for(Doctor_Mastery_Center_Snapshot__c csnap : [select month__c from Doctor_Mastery_Center_Snapshot__c where year__c = :current_year order by month__c]) {
  	  if(!query_month.contains(csnap.month__c.intvalue())) {
  	    Integer ar_month = csnap.month__c.intvalue();	  
  	    clist.add(new SelectOption(String.valueof(ar_month),Datetime.newinstance(current_year,ar_month,1).format('MMMM')));
  	    query_month.add(csnap.month__c.intvalue());
  	  }
  	}
	return clist;
  }
  
  public List<SelectOption> getyear_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	//pull a list of all months we have snapshot data for,  in the current year
  	/*of course you can't group by year__c....why would SOQL let you do something useful with aggregates
  	for(Aggregateresult ar : [select year__c from Doctor_Mastery_Center_Snapshot__c group by year__c order by year__c]) {  	  	 
  	  clist.add(new SelectOption((String)ar.get('year__c'),(String)ar.get('year__c')));
  	}*/
  	for(Integer syear=2017;syear<=System.today().year();syear++) {
  	  clist.add(new SelectOption(String.valueof(syear),String.valueof(syear)));
  	}
	return clist;
  }
  
  public void refresh_snap_list() {
  	try {
  	  snap_list = [Select d.Year__c, d.Surgical_Backlog_Days__c, d.NPS_Score__c, d.Month__c, d.Leadership_Impact_Assessment__c, d.Ideal_Week_Certified__c, d.Gross_Margin__c, 
        d.Center_Information__r.name, d.Battlegroup_Stars__c, d.Arches_Delivered__c From Doctor_Mastery_Center_Snapshot__c d where month__c = :current_month and year__c = :current_year order by center_information__r.name];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occured while trying to look up snapshot records'));
  	  ApexPages.addMessages(e); 
  	}
  }
  
  public void save_snap_list() {
  	try {
  	  update snap_list;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to save changes.'));
  	  ApexPages.addMessages(e); 
  	}
  }
    
    
}