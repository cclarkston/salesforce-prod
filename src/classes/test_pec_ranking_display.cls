@isTest
/*
created by cm on 3/27/2015
initial pass at test class for ctrl_pec_ranking_display
code coverage rates

ctrl_pec_ranking_display - 98%
*/
private class test_pec_ranking_display {


  static testMethod void test_pec_rank() {
  	PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(user__c = Userinfo.getuserid(), snapshot_date__c = System.today().adddays(-1), True_Close_Rate__c = 10.0, 
      True_Close_Rate_Regional_Rank__c = 8, True_Close_Rate_National_Rank__c = 4, Sales_Region__c = 'Unknown', 
      Rainmaker_Regional_Rank__c = 8, Rainmaker_National_Rank__c = 4, National_Overall_Rank__c = 12, Learning_Activity_Regional_Rank__c = 12, Learning_Activity_Num__c = 4, 
      Learning_Activity_National_Rank__c = 12, Callbacks_Num__c = 13, Callback_Regional_Rank__c = 20, Callback_National_Rank__c = 30, Avg_Rainmaker_Score__c = 64.01,
      avg_financial_needs_score__c = 51.34, financial_needs_national_rank__c = 3, financial_needs_regional_rank__c = 2);
    insert prs;
    Sales_Region__c sr = new Sales_Region__c(name = 'Test Region');
    insert sr;
    test.starttest();
    PageReference pageRef = new PageReference('/apex/pec_ranking_display');    
    Test.setCurrentPage(pageRef);
    ctrl_pec_ranking_display controller = new ctrl_pec_ranking_display();
    controller.getcurrent_user_name();
    controller.getreport_header();
    controller.getRegionOptions();
    List<Pec_Ranking_Snapshot__C> prs_list = controller.getpec_rank_list();
    controller.tcr_region_rank_sort();
    controller.tcr_region_rank_sort();
    controller.overall_sort();
    controller.overall_sort();
    controller.pec_sort();
    controller.pec_sort();
    controller.region_sort();
    controller.region_sort();
    controller.tcr_rank_sort();
    controller.tcr_rank_sort();
    controller.tcr_sort();
    controller.tcr_sort();
    controller.callbacks_sort();
    controller.callbacks_sort();
    controller.callback_rank_sort();
    controller.callback_rank_sort();
    controller.callback_region_rank_sort();
    controller.callback_region_rank_sort();
    controller.rainmaker_sort();
    controller.rainmaker_sort();
    controller.rainmaker_rank_sort();
    controller.rainmaker_rank_sort();
    controller.rainmaker_region_rank_sort();
    controller.rainmaker_region_rank_sort();
    controller.learning_sort();
    controller.learning_sort();
    controller.learning_rank_sort();
    controller.learning_rank_sort();
    controller.learning_region_rank_sort();
    controller.learning_region_rank_sort();
    controller.select_overall_tab();
    controller.select_close_rate_tab();
    controller.select_callback_tab();
    controller.select_rainmaker_tab();
    controller.select_learning_tab();
    controller.select_finance_tab();
    controller.getcsv_download_url();
    
    controller.fneeds_sort();
    controller.fneeds_sort();
    controller.finance_region_rank_sort();
    controller.finance_region_rank_sort();
    controller.finance_rank_sort();
    controller.finance_rank_sort();
    
    ApexPages.currentPage().getParameters().put('inittab','overall');
    controller = new ctrl_pec_ranking_display();
    controller.getreport_header();
    
    ApexPages.currentPage().getParameters().put('inittab','close_rate');
    controller = new ctrl_pec_ranking_display();
    controller.getreport_header();
    
    ApexPages.currentPage().getParameters().put('inittab','callback');
    controller = new ctrl_pec_ranking_display();
    controller.getreport_header();
    
    ApexPages.currentPage().getParameters().put('inittab','rainmaker');
    controller = new ctrl_pec_ranking_display();
    controller.getreport_header();
    
    ApexPages.currentPage().getParameters().put('inittab','learning');
    controller = new ctrl_pec_ranking_display();
    controller.getreport_header();
    
    ApexPages.currentPage().getParameters().put('inittab','finance');
    controller = new ctrl_pec_ranking_display();
    controller.getreport_header();
    
    ctl_canceldatebulk new_con = new ctl_canceldatebulk();
    
    test.stoptest();
  }
}