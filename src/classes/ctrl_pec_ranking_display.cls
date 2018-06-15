public without sharing class ctrl_pec_ranking_display {
  public String tab_display {get; set;}
  public String sort_order;
  public String region_filter {get; set;}
  
  public ctrl_pec_ranking_display() {      
  	region_filter = 'any';
  	if(apexpages.currentpage().getparameters().get('inittab')==null)  
  	  tab_display = 'overall';
    else  
      tab_display = apexpages.currentpage().getparameters().get('inittab');
    if(tab_display=='overall')
      sort_order = ' National_Overall_Rank__c ';
    else if(tab_display=='close_rate')
      sort_order = ' True_Close_Rate_National_Rank__c';
    else if(tab_display=='callback')
      sort_order = ' Callback_National_Rank__c';
    else if(tab_display=='rainmaker')
      sort_order = ' Rainmaker_National_Rank__c';
    else if(tab_display=='learning')
      sort_order = ' Learning_Activity_National_Rank__c';
    else if(tab_display=='finance')
      sort_order = ' Financial_Needs_National_Rank__c';      
  }
  
  public String getcurrent_user_name() {
  	return userinfo.getname();
  }
  
  public String getreport_header() {
  	String return_header = '';
  	if(tab_display=='overall')
      return_header = 'Overall';
    else if(tab_display=='close_rate')
      return_header = 'True Close Rate';
    else if(tab_display=='callback')
      return_header = 'Callbacks';
    else if(tab_display=='rainmaker')
      return_header = 'Rainmaker Score';
    else if(tab_display=='learning')
      return_header = 'Learning Activities';
    else if(tab_display=='learning')
      return_header = 'Financial Needs';      
    return return_header;
  }
  
  public List<SelectOption> getRegionOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('any','All Regions'));
    for(Sales_region__c sr : [select name from Sales_Region__c]) {
      options.add(new SelectOption(sr.name,sr.name));
    } 
    options.add(new SelectOption('Unknown','Unknown'));
    return options;
  }
  
  
  public List<PEC_Ranking_Snapshot__c> getpec_rank_list() {
    String query_filter = ' snapshot_date__c = yesterday ';
    if(region_filter!='any')
      query_filter += ' and sales_region__c = \'' + region_filter + '\'';
    List<Pec_Ranking_Snapshot__c> pec_list = database.query('Select p.user__r.name,p.User__c, p.True_Close_Rate__c, p.True_Close_Rate_Regional_Rank__c, p.True_Close_Rate_National_Rank__c, p.Total_National_Rank__c, p.SystemModstamp, p.Starts__c, p.Snapshot_Date__c, p.Sales_Region__c, p.Rainmaker_Regional_Rank__c, p.Rainmaker_National_Rank__c, p.OwnerId, p.National_Overall_Rank__c, p.Name, p.Learning_Activity_Regional_Rank__c, p.Learning_Activity_Num__c, p.Learning_Activity_National_Rank__c, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Consults__c, p.Cancels_out__c, p.Cancels_In__c, p.Callbacks_Num__c, p.Callback_Regional_Rank__c, p.Callback_National_Rank__c, p.Avg_Rainmaker_Score__c,  p.avg_financial_needs_score__c,p.financial_needs_national_rank__c,p.financial_needs_regional_rank__c  From PEC_Ranking_Snapshot__c p where ' + query_filter + ' order by ' + sort_order);
    return pec_list;
  }
  
  public void overall_sort() {
  	if(sort_order=='National_Overall_Rank__c')
  	  sort_order = 'National_Overall_Rank__c desc';
  	else
  	  sort_order = 'National_Overall_Rank__c';
  }
  
  public void pec_sort() {
  	if(sort_order=='user__r.name')
  	  sort_order = 'user__r.name desc';
  	else
  	  sort_order = 'user__r.name';
  }
  
  public void region_sort() {
  	if(sort_order=='sales_region__c')
  	  sort_order = 'sales_region__c desc';
  	else
  	  sort_order = 'sales_region__c';
  }
  
  public void tcr_rank_sort() {
  	if(sort_order=='true_close_rate_national_rank__c')
  	  sort_order = 'true_close_rate_national_rank__c desc';
  	else
  	  sort_order = 'true_close_rate_national_rank__c';
  }
  
  public void tcr_region_rank_sort() {
  	if(sort_order=='true_close_rate_regional_rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'true_close_rate_regional_rank__c';
  }
  
  public void tcr_sort() {
  	if(sort_order=='true_close_rate__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'true_close_rate__c';
  }
  
  public void fneeds_sort() {
  	if(sort_order=='avg_financial_needs_score__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'avg_financial_needs_score__c';  	
  }
  
  public void callbacks_sort() {
  	if(sort_order=='callbacks_num__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'callbacks_num__c';
  }
  
  public void callback_rank_sort() {
  	if(sort_order=='Callback_National_Rank__c')
  	  sort_order = 'Callback_national_Rank__c desc';
  	else
  	  sort_order = 'Callback_national_rank__c';
  }
  
  public void callback_region_rank_sort() {
  	if(sort_order=='Callback_Regional_Rank__c')
  	  sort_order = 'Callback_Regional_Rank__c desc';
  	else
  	  sort_order = 'Callback_Regional_rank__c';
  }
  
  public void rainmaker_sort() {
  	if(sort_order=='Avg_Rainmaker_Score__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Avg_Rainmaker_Score__c';
  }
  
  public void rainmaker_rank_sort() {
  	if(sort_order=='Rainmaker_National_Rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Rainmaker_national_rank__c';
  }
  
  public void rainmaker_region_rank_sort() {
  	if(sort_order=='Rainmaker_Regional_Rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Rainmaker_Regional_Rank__c';
  }
  
  public void learning_sort() {
  	if(sort_order=='Learning_Activity_num__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Learning_Activity_num__c';
  }
  
  public void learning_rank_sort() {
  	if(sort_order=='Learning_Activity_National_Rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Learning_Activity_National_Rank__c';
  }
  
  public void learning_region_rank_sort() {
  	if(sort_order=='Learning_Activity_Regional_Rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Learning_Activity_Regional_Rank__c';
  }
  
  public void finance_region_rank_sort() {
  	if(sort_order=='Financial_Needs_Regional_Rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Financial_Needs_Regional_Rank__c';
  }
  
  public void finance_rank_sort() {
  	if(sort_order=='Financial_Needs_National_Rank__c')
  	  sort_order += ' desc';
  	else
  	  sort_order = 'Financial_Needs_National_Rank__c';
  }
  
  public void select_overall_tab() {
  	tab_display = 'overall';
  	sort_order = ' National_Overall_Rank__c ';
  }
  
  public void select_close_rate_tab() {
  	tab_display = 'close_rate';
    sort_order = ' True_Close_Rate_National_Rank__c';
  }
  
  public void select_callback_tab() {
  	tab_display = 'callback';
    sort_order = ' Callback_National_Rank__c';
  }
  
  public void select_rainmaker_tab() {
  	tab_display = 'rainmaker';
    sort_order = ' Rainmaker_National_Rank__c';
  }
  
  public void select_learning_tab() {
  	tab_display = 'learning';
    sort_order = ' Learning_Activity_National_Rank__c';
  }
  
  public void select_finance_tab() {
  	tab_display = 'finance';
  	sort_order = ' Financial_Needs_National_Rank__c';
  }
  
  public String getcsv_download_url() {
  	Pagereference pr = Page.opsDashcsv;
  	pr.getParameters().put('format','23');  	
  	return pr.geturl();
  }
}