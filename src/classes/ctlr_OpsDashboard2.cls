public with sharing class ctlr_OpsDashboard2 {
        
  public class DisplayMetrics {
    public Integer last_year { get; set;}
    public Integer MTD { get; set;}
    public Integer last_90 { get; set;}
    public Integer previous_month { get; set;}
    public Integer YTD { get; set;}
    public Integer QTD { get; set;}
    public Integer previous_day { get; set;}
  }
  
  public class DisplayDecimal {
    public Decimal last_year { get; set;}
    public Decimal MTD { get; set;}
    public Decimal last_90 { get; set;}
    public Decimal previous_month { get; set;}
    public Decimal YTD { get; set;}
    public Decimal QTD { get; set;}
    public Decimal previous_day { get; set;}
  }
  
  ID center_id;
  Set<ID> account_id_list = new Set<ID>();
  public String download_string;
  public String getdownload_string() { return download_string; }
  public string display_pec {get; set;}
  public string display_center {get; set;}
  public String action;
  public String report_header;  
  public String outputtext {get; set;}  
  public String getaction() { return action; }
  public String getreport_header() { return report_header; }
  public String yesterday_filter = ' yesterday ';
  public String getyesterday_filter() {
  	return yesterday_filter;
  }
  User this_user = [select center_pec__c,center_administrator__c from user where id = :Userinfo.getUserId()];
  public String hyper_prefix = 'http://'+ApexPages.currentPage().getHeaders().get('Host');
  public String gethyper_prefix() { return hyper_prefix; }
  public String all_filter = '';
    
  Set<ID> user_filters = new Set<ID>();
  public boolean display_user_button = false;
  public boolean display_center_button = false;
  public boolean display_all_button = false;
  public boolean display_admin = false;
  public boolean display_ca = false;
  public boolean getdisplay_user_button() { return display_user_button; }
  public boolean getdisplay_center_button() { return display_center_button; }
  public boolean getdisplay_all_button() { return display_all_button; }
  public boolean getdisplay_admin() { return display_admin; }
  public boolean getdisplay_ca() { return display_ca; }
  
  //:Userinfo.getUserId()
  public List<SelectOption> getCAPEClist() {  	
    List<SelectOption> options = new List<SelectOption>();
    
    //list<Center_Information__C> centers = [Select c.PEC_1__c,c.PEC_2__c From Center_Information__c c];
    list<User> pec_users = [select id,name,center_pec__c from user where center_pec__c = :this_user.center_pec__c and center_administrator__c = false order by name];
    for(User my_user : pec_users) {
    	options.add(new SelectOption(my_user.id,my_user.name));
    }
    return options;
  }
  
  public List<SelectOption> getPEClist() {
  	/*  This method is pulling alist of PECs by searching for the id's tied to the pec_1 and pec_2 field 
  	  in the center information table.  Not the best way to handle it given we have traveling PECs.  I'll
  	  likely add a field to the user table at some point to track PEC assignment at some point and switch 
  	  this to pull from there	*/
    List<SelectOption> options = new List<SelectOption>();
    Map<ID,String> user_name = new Map<ID,String> ();
    list<User> all_users = [select id,name from user];
    for(User my_user : all_users) {
      user_name.put(my_user.id,my_user.name);
    }
    //list<Center_Information__C> centers = [Select c.PEC_1__c,c.PEC_2__c From Center_Information__c c];
    list<User> pec_users = [select id,name,center_pec__c from user where center_pec__c <> '' and center_administrator__c = false order by name];
    for(User my_user : pec_users) {
    	options.add(new SelectOption(my_user.id,my_user.name));
    }
    /*for(Center_Information__c center : centers) {
      if(center.PEC_1__c!=null)
        options.add(new SelectOption(center.PEC_1__c,user_name.get(center.PEC_1__c)));
      if(center.PEC_2__c!=null)
        options.add(new SelectOption(center.PEC_2__c,user_name.get(center.PEC_2__c)));
    }*/
    return options;
  }
  
  public List<SelectOption> getCenterlist() {
    List<SelectOption> options = new List<SelectOption>();
    for(AggregateResult results : [Select c.sales_market__c,c.sales_market__r.name From Center_Information__c c where c.sales_market__c <> null group by c.sales_market__c,c.sales_market__r.name order by c.sales_market__r.name]) { 
    //list<Center_Information__C> centers = [Select c.id,c.name From Center_Information__c c order by c.name];
    //for(Center_Information__c center : centers) {
      //options.add(new SelectOption(center.id,center.name));
      options.add(new SelectOption(String.valueof(results.get('sales_market__c')),String.valueof(results.get('name'))));
    }
    return options;
  }
  
  public Pagereference set_centergoals() {
  	Pagereference pr = Page.center_goals;
  	pr.setredirect(true);
  	return pr;
  }
  
  public Pagereference set_salesgoals() {
  	Pagereference pr = Page.SalesGoals;
  	pr.setredirect(true);
    return pr;          
  }
  
  public Pagereference view_historic_rates() {
  	Pagereference pr = Page.historic_run_rates;
  	pr.setredirect(true);
    return pr;          
  }
        
  public Pagereference view_auser() {
    Pagereference pr = Page.sandbox_chris; 
    pr.getParameters().put('action','user');
    pr.getParameters().put('asuser',display_pec);  
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
  	  pr.getParameters().put('tfilter','1');            
    pr.setredirect(true);
    return pr;          
  }
  
  public Pagereference view_acenter() {
    Pagereference pr = Page.sandbox_chris; 
    pr.getParameters().put('action','center');
    pr.getParameters().put('ascenter',display_center);    
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
  	  pr.getParameters().put('tfilter','1');          
    pr.setredirect(true);
    return pr;          
  }
        
  
  public Pagereference display_center() {
    Pagereference pr = Page.sandbox_chris; 
    pr.getParameters().put('action','center');  
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
  	  pr.getParameters().put('tfilter','1');            
    pr.setredirect(true);
    return pr;          
  }
  
  public Pagereference display_all() {
    Pagereference pr = Page.sandbox_chris; 
    pr.getParameters().put('action','all');  
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
  	  pr.getParameters().put('tfilter','1');            
    pr.setredirect(true);
    return pr;          
  }
  
  public Pagereference display_user() {
    Pagereference pr = Page.sandbox_chris; 
    pr.getParameters().put('action','user');     
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
  	  pr.getParameters().put('tfilter','1');         
    pr.setredirect(true);
    return pr;          
  }
  
  //should toggle to displaying today's data instead of yesterday
  public Pagereference display_today() {
  	Pagereference pr = Page.OpsDashboard;
  	pr.getParameters().put('tfilter','1');
  	if(Apexpages.currentPage().getParameters().get('action')!=null)
  	  pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('action'));
  	if(Apexpages.currentPage().getParameters().get('asuser')!=null)
  	  pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('asuser'));
  	if(Apexpages.currentPage().getParameters().get('ascenter')!=null)
  	  pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('ascenter'));
    pr.setredirect(true);
  	return pr;
  }
  
  public Pagereference display_yesterday() {
  	Pagereference pr = Page.OpsDashboard;
  	if(Apexpages.currentPage().getParameters().get('action')!=null)
  	  pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('action'));
  	if(Apexpages.currentPage().getParameters().get('asuser')!=null)
  	  pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('asuser'));
  	if(Apexpages.currentPage().getParameters().get('ascenter')!=null)
  	  pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('ascenter'));
    pr.setredirect(true);
  	return pr;
  }
  
  public ctlr_OpsDashboard2() {
    if(apexpages.currentpage().getparameters().get('action')==null)
      action = 'user';
    else
      action = apexpages.currentpage().getparameters().get('action');
    if(test.isRunningTest())
      all_filter = ' limit 10';
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
      yesterday_filter = ' today ';           
    List<Center_Information__c> center_info = new list<Center_Information__c> ();    
    if(apexpages.currentpage().getparameters().get('ascenter')==null) {
    	User this_u = [select id,center_pec__c from user where id = :Userinfo.getUserId()];
    	if(this_u.Center_PEC__c<>null) {
    	  Center_Information__c sm = [select sales_market__c from Center_Information__c where id = :this_u.center_pec__c];    	
    	  center_info = [select id,name,PEC_1__c,PEC_2__c,sales_market__c,sales_market__r.name from Center_Information__c where sales_market__c = :sm.sales_market__c];
    	}
    	//center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where id = :this_u.center_pec__c];
      //center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where PEC_1__c = :Userinfo.getUserId() or PEC_2__c = :Userinfo.getUserId()];
    }
    else 
      center_info = [select id,name,PEC_1__c,PEC_2__c,sales_market__c,sales_market__r.name from Center_Information__c where sales_market__c = :apexpages.currentpage().getparameters().get('ascenter')];
      //center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ascenter')];
    if(action=='user') {
    	download_string = '&action=user';
        display_user_button = false;   
        if(center_info.size()>0)
          display_center_button = true;
      if(apexpages.currentpage().getparameters().get('asuser')==null) {
		    report_header = Userinfo.getName();  
		    user_filters.add(Userinfo.getUserID());
		    download_string += '&asuser=' + Userinfo.getUserID();       
	    }
	    else {
	    	User view_user = [select name from user where id = :apexpages.currentpage().getparameters().get('asuser')];
	    	report_header = view_user.name;
	    	user_filters.add(apexpages.currentpage().getparameters().get('asuser'));
	    	download_string += '&asuser=' + apexpages.currentpage().getparameters().get('asuser');
	    }         
    }
    if(action=='center') {
    	download_string = '&action=center';
      //user filters was a nice option,  but I need to move to a center field as this doesn't work well
      //when people get reassigned or we have travelling PECs
      Integer cnt = 0;      
      for(Center_Information__c ci : center_info) {
      	if(cnt==0) {
      		download_string += '&ascenter=' + ci.sales_market__c;
      		//download_string += '&ascenter=' + ci.id;
      	  //make a list for account_id_list - this will be used as a filter on some of the metrics queries
      	  for(Account a : [select id from account where center__c = :ci.id]) {
      	  	account_id_list.add(a.id);
      	  }
      	  //center_id = ci.id;
      	  center_id = ci.sales_market__c;
      	}
      	cnt++;
      	//might not need to adjust this for sales market roll up
      	List<User> center_pec = [select id from user where center_pec__c = :ci.id];
      	for(User my_user : center_pec) {
      		user_filters.add(my_user.id);
      	}
      	report_header = ci.sales_market__r.Name;
      	//report_header = ci.Name;
        /*if(ci.PEC_1__c != null)
          user_filters.add(ci.PEC_1__c);
        if(ci.PEC_2__c != null)
          user_filters.add(ci.PEC_2__c);
        report_header = ci.Name;*/
      }
      
      display_user_button = true;
      display_center_button = false;
    }    
    Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Limited System Administrator','PEC_MultipleCenters_VisiblePrescreen') and id = :Userinfo.getProfileId()];
    if(admin_count>0) {
      display_all_button = true;
      display_admin = true;
    }    
	  if(userinfo.getName()=='Bryce Burger' || userinfo.getName()=='Dina Costantini' || userinfo.getName()=='Anne Sawyer')
	    display_admin = true;
    if(action=='all') {
    	download_string = '&action=all';
    	//this is here to make sure someone without the proper rights doesn't access this method by passing
    	//the action=all parameter directly via URL.
    	system.assert(admin_count>0);
    	report_header = 'All Center Info';
      display_user_button = true;
      if(center_info.size()>0)
        display_center_button = true;
      display_all_button = false;       
    }
    if(this_user.Center_Administrator__c==true) 
      display_ca = true;
  }
  
  public class DisplayDollars {
    public decimal last_year { get; set;}
    public decimal MTD { get; set;}
    public decimal last_90 { get; set;}
    public decimal previous_month { get; set;}
    public decimal YTD { get; set;}
    public decimal QTD { get; set;}
    public decimal previous_day { get; set;}                 
  }
  DisplayMetrics starts;
  DisplayMetrics sdstarts;
  DisplayMetrics starts_cancelled;
  DisplayMetrics starts_cancelled_in;
  DisplayMetrics starts_cancelled_out;
  DisplayMetrics consult_starts;
  DisplayDollars collected;
  DisplayDollars refunded;
  DisplayDollars treatment_sold;
  DisplayDollars treatment_cancelled;
  DisplayDollars treatment_cancelled_in;
  DisplayDollars treatment_cancelled_out;
  DisplayDollars anticipated_payments;
  DisplayMetrics financed_consults;
  DisplayMetrics pipeline;
  DisplayDollars sales_target;  
  DisplayDollars upsell_sold;
  DisplayDollars upsell_cancelled_in;
  DisplayDollars upsell_cancelled_out;
  DisplayDecimal true_closerate;
  
  public String getquarter_filter(Integer month) {
  	String query_filter = '';
  	if(month==1 || month==2 || month==3)
  	  query_filter = '(1,2,3)';
  	if(month==4 || month==5 || month==6)
  	  query_filter = '(4,5,6)';
  	if(month==7 || month==8 || month==9)
  	  query_filter = '(7,8,9)';
  	if(month==10 || month==11 || month==12)
  	  query_filter = '(10,11,12)';  	  
  	return query_filter;
  }
  
  public DisplayDollars getSalesTarget() {
    if(sales_target==null) {
      sales_target = new DisplayDollars();
      Integer current_year = date.today().year();
      Integer current_month = date.today().month();
      Integer current_day = date.today().day();
      if(action=='all') {
      	//Month - just grab the budget sales goal amount for current fiscal year and month
      	sales_target.MTD = 0;      	      	      
      	for(Center_Budget__c month_budget : [select sales_goal__c from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month]) {
      	  sales_target.MTD += month_budget.sales_goal__c;
      	}      	
      	//Year - need to grab the budget sales goal amounts for all completed months and then calculate how
      	//much to assign for the current month based on number of days and the current day of the month
      	sales_target.YTD = 0;
      	for(Center_Budget__c year_budget : [select sales_goal__c,fiscal_month__c from Center_Budget__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month]) {
      		if(year_budget.fiscal_month__c < current_month) 
      		  sales_target.YTD += year_budget.sales_goal__c;
      		else {
      			sales_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
      		}      		
      	}      	
      	//QTD - just grab the goals for the current year and all of the months that make up this quarter
      	String query_filter = getquarter_filter(current_month);
      	AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter);
      	if(results.get('sales_goal')==null)
      	  sales_target.QTD = 0;
      	else
      	  sales_target.QTD = (Decimal)results.get('sales_goal');
            	
        /*for (AggregateResult results : [select sum(sales_goal__c) sales_goal from center_information__c]) {
          if(results.get('sales_goal')==null) {
            sales_target.MTD = 0;
            sales_target.YTD = 0;
            sales_target.QTD = 0;
          }
          else {  
            sales_target.MTD = (Decimal)results.get('sales_goal');
            Date today_date = date.today();
            sales_target.YTD = ((Decimal)results.get('sales_goal') * 12)/365 * today_date.dayOfYear();
            //sales_target.YTD = (Decimal)results.get('sales_goal') * 12;
            sales_target.QTD = (Decimal)results.get('sales_goal') * 3;
          }
        }       */             
      }
      else if(action=='center') {
      	//Month - just grab the budget sales goal amount for current fiscal year and month      	      	      
        sales_target.MTD = 0;      	      	      
      	for(Center_Budget__c month_budget : [select sales_goal__c from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and center__r.sales_market__c = :center_id]) {
      	  sales_target.MTD += month_budget.sales_goal__c;
      	}    
      	//Year - need to grab the budget sales goal amounts for all completed months and then calculate how
      	//much to assign for the current month based on number of days and the current day of the month
      	sales_target.YTD = 0;
      	for(Center_Budget__c year_budget : [select sales_goal__c,fiscal_month__c from Center_Budget__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and center__r.sales_market__c = :center_id]) {
      		if(year_budget.fiscal_month__c < current_month) 
      		  sales_target.YTD += year_budget.sales_goal__c;
      		else {
      			sales_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
      		}      		
      	}      	
      	//QTD - just grab the goals for the current year and all of the months that make up this quarter
      	String query_filter = getquarter_filter(current_month);
      	AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter + ' and center__r.sales_market__c = :center_id');
      	if(results.get('sales_goal')==null)
      	  sales_target.QTD = 0;
      	else
      	  sales_target.QTD = (Decimal)results.get('sales_goal');
      	
      	//for (AggregateResult results : [select sum(sales_goal__c) sales_goal from center_information__c where id = :center_id]) {
      	/*for (AggregateResult results : [select sum(sales_goal__c) sales_goal from center_information__c where sales_market__c = :center_id]) {
          if(results.get('sales_goal')==null) {
            sales_target.MTD = 0;
            sales_target.YTD = 0;
            sales_target.QTD = 0;
          }
          else {  
            sales_target.MTD = (Decimal)results.get('sales_goal');
            Date today_date = date.today();
            sales_target.YTD = ((Decimal)results.get('sales_goal') * 12)/365 * today_date.dayOfYear();
            //sales_target.YTD = (Decimal)results.get('sales_goal') * 12;
            sales_target.QTD = (Decimal)results.get('sales_goal') * 3;
          }
        }*/
      }      
      else if(action=='user') {
        //Month - just grab the budget sales goal amount for current fiscal year and month      	      	      
        sales_target.MTD = 0;      	      	      
      	for(User_Goals__c month_budget : [select sales_goal__c from user_goals__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and user__c in :user_filters]) {
      	  sales_target.MTD += month_budget.sales_goal__c;
      	}
      	//Year - need to grab the budget sales goal amounts for all completed months and then calculate how
      	//much to assign for the current month based on number of days and the current day of the month
      	sales_target.YTD = 0;
      	for(User_Goals__c year_budget : [select sales_goal__c,fiscal_month__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and user__c in :user_filters]) {
      		if(year_budget.fiscal_month__c < current_month) 
      		  sales_target.YTD += year_budget.sales_goal__c;
      		else {
      			sales_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
      		}      		
      	}  
      	//QTD - just grab the goals for the current year and all of the months that make up this quarter
      	String query_filter = getquarter_filter(current_month);
      	AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter + ' and user__c in :user_filters');
      	if(results.get('sales_goal')==null)
      	  sales_target.QTD = 0;
      	else
      	  sales_target.QTD = (Decimal)results.get('sales_goal');      
      }      
    }
    return sales_target;
  }
  
  public DisplayMetrics getFinancedConsults() {
  	if(financed_consults==null) {
      financed_consults = new DisplayMetrics();        
      if(action=='all') {
      	//financed_consults.last_year = [select count() from account where createddate = LAST_YEAR and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];      					 
        financed_consults.MTD =	database.countQuery('select count() from account where createddate = THIS_MONTH and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
        //financed_consults.last_90 = database.countQuery('select count() from account where createddate = LAST_QUARTER and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
        financed_consults.previous_month = database.countQuery('select count() from account where createddate = LAST_MONTH and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
        financed_consults.YTD = database.countQuery('select count() from account where createddate = THIS_YEAR and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
        financed_consults.QTD = database.countQuery('select count() from account where createddate = THIS_QUARTER and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
        financed_consults.previous_day = database.countQuery('select count() from account where createddate = ' + yesterday_filter + ' and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
      }
      else if(action=='user') {
        //financed_consults.last_year  = [select count() from account where createddate = LAST_YEAR and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.MTD = [select count() from account where createddate = THIS_MONTH and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        //financed_consults.last_90 = [select count() from account where createddate = LAST_QUARTER and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.previous_month = [select count() from account where createddate = LAST_MONTH and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.YTD = [select count() from account where createddate = THIS_YEAR and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.QTD = [select count() from account where createddate = THIS_QUARTER and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + ' and ownerid in : user_filters and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')');
      }
      else if(action=='center'){
      	//financed_consults.last_year  = [select count() from account where createddate = LAST_YEAR and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
      	financed_consults.MTD = [select count() from account where createddate = THIS_MONTH and center__r.sales_market__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        //financed_consults.last_90 = [select count() from account where createddate = LAST_QUARTER and center__r.sales_market__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.previous_month = [select count() from account where createddate = LAST_MONTH and center__r.sales_market__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.YTD = [select count() from account where createddate = THIS_YEAR and center__r.sales_market__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.QTD = [select count() from account where createddate = THIS_QUARTER and center__r.sales_market__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + ' and center__r.sales_market__c = :center_id and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')');
        /*financed_consults.MTD = [select count() from account where createddate = THIS_MONTH and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.last_90 = [select count() from account where createddate = LAST_QUARTER and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.YTD = [select count() from account where createddate = THIS_YEAR and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.QTD = [select count() from account where createddate = THIS_QUARTER and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        financed_consults.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + ' and center__c = :center_id and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')');*/
      }
    }
    return financed_consults;
  }
  
  public DisplayMetrics getConsultStarts() {
    if(consult_starts==null) {
      consult_starts = new DisplayMetrics();        
      if(action=='all') {
      	//consult_starts.last_year = [select count() from account where createddate = LAST_YEAR];				 
        consult_starts.MTD = database.countQuery('select count() from account where createddate = THIS_MONTH' + all_filter);
        //consult_starts.last_90 = database.countQuery('select count() from account where createddate = LAST_QUARTER' + all_filter);
        consult_starts.previous_month = database.countQuery('select count() from account where createddate = LAST_MONTH' + all_filter);
        consult_starts.YTD = database.countQuery('select count() from account where createddate = THIS_YEAR' + all_filter);
        consult_starts.QTD = database.countQuery('select count() from account where createddate = THIS_QUARTER' + all_filter);
        consult_starts.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + all_filter);
      }
      else if(action=='user') {
        //consult_starts.last_year  = [select count() from account where createddate = LAST_YEAR and ownerid in : user_filters];
        consult_starts.MTD = [select count() from account where createddate = THIS_MONTH and ownerid in : user_filters];
        //consult_starts.last_90 = [select count() from account where createddate = LAST_QUARTER and ownerid in : user_filters];
        consult_starts.previous_month = [select count() from account where createddate = LAST_MONTH and ownerid in : user_filters];
        consult_starts.YTD = [select count() from account where createddate = THIS_YEAR and ownerid in : user_filters];
        consult_starts.QTD = [select count() from account where createddate = THIS_QUARTER and ownerid in : user_filters];
        consult_starts.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + ' and ownerid in : user_filters');
      }
      else if(action=='center'){
      	//consult_starts.last_year  = [select count() from account where createddate = LAST_YEAR and center__c = :center_id];
      	consult_starts.MTD = [select count() from account where createddate = THIS_MONTH and center__r.sales_market__c = :center_id];
        //consult_starts.last_90 = [select count() from account where createddate = LAST_QUARTER and center__r.sales_market__c = :center_id];
        consult_starts.previous_month = [select count() from account where createddate = LAST_MONTH and center__r.sales_market__c = :center_id];
        consult_starts.YTD = [select count() from account where createddate = THIS_YEAR and center__r.sales_market__c = :center_id];
        consult_starts.QTD = [select count() from account where createddate = THIS_QUARTER and center__r.sales_market__c = :center_id];
        consult_starts.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + ' and center__r.sales_market__c = :center_id');
        /*consult_starts.MTD = [select count() from account where createddate = THIS_MONTH and center__c = :center_id];
        consult_starts.last_90 = [select count() from account where createddate = LAST_QUARTER and center__c = :center_id];
        consult_starts.YTD = [select count() from account where createddate = THIS_YEAR and center__c = :center_id];
        consult_starts.QTD = [select count() from account where createddate = THIS_QUARTER and center__c = :center_id];
        consult_starts.previous_day = database.countquery('select count() from account where createddate = ' + yesterday_filter + ' and center__c = :center_id');*/
      }
    }
    return consult_starts;
  }   
  
  public DisplayMetrics getSDStarts() {
    if(sdstarts==null) {
      sdstarts = new DisplayMetrics();        
      if(action=='all') {
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR];
        sdstarts.MTD = database.countQuery('select count() from opportunity where createddate = THIS_MONTH and days_since_consult__c = 0' + all_filter);
        //starts.last_90 = database.countQuery('select count() from opportunity where createddate = LAST_QUARTER' + all_filter);
        sdstarts.previous_month = database.countQuery('select count() from opportunity where createddate = LAST_MONTH and days_since_consult__c = 0' + all_filter);
        sdstarts.YTD = database.countQuery('select count() from opportunity where createddate = THIS_YEAR and days_since_consult__c = 0' + all_filter);
        sdstarts.QTD = database.countQuery('select count() from opportunity where createddate = THIS_QUARTER and days_since_consult__c = 0' + all_filter);     
        sdstarts.previous_day = database.countquery('select count() from opportunity where days_since_consult__c = 0 and createddate = ' + yesterday_filter + all_filter);   
      }
      else if(action=='user'){
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR and ownerid in : user_filters];
        sdstarts.MTD = [select count() from opportunity where createddate = THIS_MONTH and days_since_consult__c = 0 and ownerid in : user_filters];
        //starts.last_90 = [select count() from opportunity where createddate = LAST_QUARTER and ownerid in : user_filters];
        sdstarts.previous_month = [select count() from opportunity where createddate = LAST_MONTH and days_since_consult__c = 0 and ownerid in : user_filters];
        sdstarts.YTD = [select count() from opportunity where createddate = THIS_YEAR and days_since_consult__c = 0 and ownerid in : user_filters];
        sdstarts.QTD = [select count() from opportunity where createddate = THIS_QUARTER and days_since_consult__c = 0 and ownerid in : user_filters];
        sdstarts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + ' and days_since_consult__c = 0 and ownerid in : user_filters');
      }
      else if(action=='center') {
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR and accountid in (select id from account where center__c = :center_id)];
        sdstarts.MTD = [select count() from opportunity where createddate = THIS_MONTH and days_since_consult__c = 0 and account.center__r.sales_market__c = :center_id];
        //starts.last_90 = [select count() from opportunity where createddate = LAST_QUARTER and account.center__r.sales_market__c = :center_id];
        sdstarts.previous_month = [select count() from opportunity where createddate = LAST_MONTH and days_since_consult__c = 0 and account.center__r.sales_market__c = :center_id];
        sdstarts.YTD = [select count() from opportunity where createddate = THIS_YEAR and days_since_consult__c = 0 and account.center__r.sales_market__c = :center_id];
        sdstarts.QTD = [select count() from opportunity where createddate = THIS_QUARTER and days_since_consult__c = 0 and account.center__r.sales_market__c = :center_id];
        sdstarts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + ' and days_since_consult__c = 0 and account.center__r.sales_market__c = :center_id');
        /*starts.MTD = [select count() from opportunity where createddate = THIS_MONTH and accountid in (select id from account where center__c = :center_id)];
        starts.last_90 = [select count() from opportunity where createddate = LAST_QUARTER and accountid in (select id from account where center__c = :center_id)];
        starts.YTD = [select count() from opportunity where createddate = THIS_YEAR and accountid in (select id from account where center__c = :center_id)];
        starts.QTD = [select count() from opportunity where createddate = THIS_QUARTER and accountid in (select id from account where center__c = :center_id)];
        starts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + ' and accountid in (select id from account where center__c = :center_id)');*/
      }
    }
    return sdstarts;
  }
  
  public DisplayMetrics getStarts() {
    if(starts==null) {
      starts = new DisplayMetrics();        
      if(action=='all') {
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR];
        starts.MTD = database.countQuery('select count() from opportunity where createddate = THIS_MONTH' + all_filter);
        //starts.last_90 = database.countQuery('select count() from opportunity where createddate = LAST_QUARTER' + all_filter);
        starts.previous_month = database.countQuery('select count() from opportunity where createddate = LAST_MONTH' + all_filter);
        starts.YTD = database.countQuery('select count() from opportunity where createddate = THIS_YEAR' + all_filter);
        starts.QTD = database.countQuery('select count() from opportunity where createddate = THIS_QUARTER' + all_filter);     
        starts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + all_filter);   
      }
      else if(action=='user'){
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR and ownerid in : user_filters];
        starts.MTD = [select count() from opportunity where createddate = THIS_MONTH and ownerid in : user_filters];
        //starts.last_90 = [select count() from opportunity where createddate = LAST_QUARTER and ownerid in : user_filters];
        starts.previous_month = [select count() from opportunity where createddate = LAST_MONTH and ownerid in : user_filters];
        starts.YTD = [select count() from opportunity where createddate = THIS_YEAR and ownerid in : user_filters];
        starts.QTD = [select count() from opportunity where createddate = THIS_QUARTER and ownerid in : user_filters];
        starts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + ' and ownerid in : user_filters');
      }
      else if(action=='center') {
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR and accountid in (select id from account where center__c = :center_id)];
        starts.MTD = [select count() from opportunity where createddate = THIS_MONTH and account.center__r.sales_market__c = :center_id];
        //starts.last_90 = [select count() from opportunity where createddate = LAST_QUARTER and account.center__r.sales_market__c = :center_id];
        starts.previous_month = [select count() from opportunity where createddate = LAST_MONTH and account.center__r.sales_market__c = :center_id];
        starts.YTD = [select count() from opportunity where createddate = THIS_YEAR and account.center__r.sales_market__c = :center_id];
        starts.QTD = [select count() from opportunity where createddate = THIS_QUARTER and account.center__r.sales_market__c = :center_id];
        starts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + ' and account.center__r.sales_market__c = :center_id');
        /*starts.MTD = [select count() from opportunity where createddate = THIS_MONTH and accountid in (select id from account where center__c = :center_id)];
        starts.last_90 = [select count() from opportunity where createddate = LAST_QUARTER and accountid in (select id from account where center__c = :center_id)];
        starts.YTD = [select count() from opportunity where createddate = THIS_YEAR and accountid in (select id from account where center__c = :center_id)];
        starts.QTD = [select count() from opportunity where createddate = THIS_QUARTER and accountid in (select id from account where center__c = :center_id)];
        starts.previous_day = database.countquery('select count() from opportunity where createddate = ' + yesterday_filter + ' and accountid in (select id from account where center__c = :center_id)');*/
      }
    }
    return starts;
  }
  
  public DisplayMetrics getStartsCancelled() {
    if(starts_cancelled==null) {
      starts_cancelled = new DisplayMetrics();
      if(starts_cancelled_in==null)
        starts_cancelled_in = getStartsCancelledIn();
      if(starts_cancelled_out==null)
        starts_cancelled_out = getStartsCancelledOut();
      starts_cancelled.MTD = starts_cancelled_in.MTD + starts_cancelled_out.MTD;
      starts_cancelled.QTD = starts_cancelled_in.QTD + starts_cancelled_out.QTD;
      starts_cancelled.YTD = starts_cancelled_in.YTD + starts_cancelled_out.YTD;
      //starts_cancelled.last_90 = starts_cancelled_in.last_90 + starts_cancelled_out.last_90;
      starts_cancelled.previous_month = starts_cancelled_in.previous_month + starts_cancelled_out.previous_month;
      starts_cancelled.previous_day = starts_cancelled_in.previous_day + starts_cancelled_out.previous_day;
      /*if(action=='all') {        
        starts_cancelled.MTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled.last_90 = database.countQuery('select count() from opportunity where Cancel_Date__c = LAST_QUARTER and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled.YTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;       
        starts_cancelled.QTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
      }
      else if(action=='user'){
        starts_cancelled.MTD = [select count() from opportunity where Cancel_Date__c = this_month 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled.YTD = [select count() from opportunity where Cancel_Date__c = this_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;       
        starts_cancelled.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters') * -1;             
      }
      else if(action=='center') {
        starts_cancelled.MTD = [select count() from opportunity where Cancel_Date__c = this_month 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled.YTD = [select count() from opportunity where Cancel_Date__c = this_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;       
        starts_cancelled.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id') * -1;          
      }*/      
    }
    return starts_cancelled;
  }
  
  public DisplayMetrics getStartsCancelledIn() {
    if(starts_cancelled_in==null) {
      starts_cancelled_in = new DisplayMetrics();
      if(action=='all') {
        /*starts_cancelled_in.last_year  = [select count() from opportunity where Cancel_Date__c = last_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;*/
        starts_cancelled_in.MTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_month and createddate = this_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        //starts_cancelled_in.last_90 = database.countQuery('select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = LAST_QUARTER and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_in.previous_month = database.countQuery('select count() from opportunity where Cancel_Date__c = LAST_MONTH and createddate = LAST_MONTH and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_in.YTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_year and createddate = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;       
        starts_cancelled_in.QTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_in.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter +  
          ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
      }
      else if(action=='user'){
        /*starts_cancelled_in.last_year  = [select count() from opportunity where Cancel_Date__c = last_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;*/
        starts_cancelled_in.MTD = [select count() from opportunity where Cancel_Date__c = this_month and createddate = this_month
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        //starts_cancelled_in.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter        and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled_in.previous_month = [select count() from opportunity where Cancel_Date__c = LAST_MONTH and createddate = last_month        and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled_in.YTD = [select count() from opportunity where Cancel_Date__c = this_year and createddate = this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;       
        starts_cancelled_in.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter and createddate = this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled_in.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters') * -1;             
      }
      else if(action=='center') {
      	/*starts_cancelled_in.last_year  = [select count() from opportunity where Cancel_Date__c = last_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;*/
        starts_cancelled_in.MTD = [select count() from opportunity where Cancel_Date__c = this_month and createddate = this_month 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        //starts_cancelled_in.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter        and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled_in.previous_month = [select count() from opportunity where Cancel_Date__c = LAST_MONTH and createddate = last_month        and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled_in.YTD = [select count() from opportunity where Cancel_Date__c = this_year and createddate = this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;       
        starts_cancelled_in.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter and createddate = this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled_in.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id') * -1;
        /*starts_cancelled_in.MTD = [select count() from opportunity where Cancel_Date__c = this_month and createddate = this_month 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled_in.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled_in.YTD = [select count() from opportunity where Cancel_Date__c = this_year and createddate = this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;       
        starts_cancelled_in.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter and createddate = this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled_in.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)') * -1;*/
      }
    }
    return starts_cancelled_in;
  }
  
  public DisplayMetrics getStartsCancelledOut() {
    if(starts_cancelled_out==null) {
      starts_cancelled_out = new DisplayMetrics();
      if(action=='all') {
        /*starts_cancelled_out.last_year  = [select count() from opportunity where Cancel_Date__c = last_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;*/
        starts_cancelled_out.MTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_month and createddate <> this_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        //starts_cancelled_out.last_90 = database.countQuery('select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> LAST_QUARTER and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_out.previous_month = database.countQuery('select count() from opportunity where Cancel_Date__c = LAST_MONTH and createddate <> LAST_Month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_out.YTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_year and createddate <> this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;       
        starts_cancelled_out.QTD = database.countQuery('select count() from opportunity where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_out.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter +  
          ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
      }
      else if(action=='user'){
        /*starts_cancelled_out.last_year  = [select count() from opportunity where Cancel_Date__c = last_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;*/
        starts_cancelled_out.MTD = [select count() from opportunity where Cancel_Date__c = this_month and createddate <> this_month
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        //starts_cancelled_out.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter      and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled_out.previous_month = [select count() from opportunity where Cancel_Date__c = LAST_MONTH and createddate <> last_month      and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled_out.YTD = [select count() from opportunity where Cancel_Date__c = this_year and createddate <> this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;       
        starts_cancelled_out.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter and createddate <> this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters] * -1;
        starts_cancelled_out.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters') * -1;             
      }
      else if(action=='center') {
      	/*starts_cancelled_out.last_year  = [select count() from opportunity where Cancel_Date__c = last_year 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;*/
        starts_cancelled_out.MTD = [select count() from opportunity where Cancel_Date__c = this_month and createddate <> this_month 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        //starts_cancelled_out.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter      and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled_out.previous_month = [select count() from opportunity where Cancel_Date__c = LAST_MONTH and createddate <> last_month      and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled_out.YTD = [select count() from opportunity where Cancel_Date__c = this_year and createddate <> this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;       
        starts_cancelled_out.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter and createddate <> this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id] * -1;
        starts_cancelled_out.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id') * -1;
        /*starts_cancelled_out.MTD = [select count() from opportunity where Cancel_Date__c = this_month and createddate <> this_month 
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled_out.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled_out.YTD = [select count() from opportunity where Cancel_Date__c = this_year and createddate <> this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;       
        starts_cancelled_out.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter and createddate <> this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled_out.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter + 
          ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)') * -1;*/
      }
    }
    return starts_cancelled_out;
  }
  
  public DisplayDollars getTreatmentSold() {
    if(treatment_sold==null) {
      treatment_sold = new DisplayDollars();
      if(action=='all') {      	
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = last_year]) {
          if(results.get('total_payments')==null)
            treatment_sold.last_year = 0;
          else  
            treatment_sold.last_year = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = this_month')) {
          if(results.get('total_payments')==null)
            treatment_sold.MTD = 0;
          else  
            treatment_sold.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = LAST_QUARTER' )) {
          if(results.get('total_payments')==null)
            treatment_sold.last_90 = 0;
          else  
            treatment_sold.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = LAST_MONTH' )) {
          if(results.get('total_payments')==null)
            treatment_sold.previous_month = 0;
          else  
            treatment_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = this_year')) {
          if(results.get('total_payments')==null)
            treatment_sold.YTD = 0;
          else  
            treatment_sold.YTD = (Decimal)results.get('total_payments');
        }    
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = this_quarter')) {
          if(results.get('total_payments')==null)
            treatment_sold.QTD = 0;
          else  
            treatment_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter)) {
          if(results.get('total_payments')==null)
            treatment_sold.previous_day = 0;
          else  
            treatment_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='user'){
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = last_year and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_sold.last_year = 0;
          else  
            treatment_sold.last_year = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_month and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_sold.MTD = 0;
          else  
            treatment_sold.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = LAST_QUARTER and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_sold.last_90 = 0;
          else  
            treatment_sold.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = LAST_MONTH and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_sold.previous_month = 0;
          else  
            treatment_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_year and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_sold.YTD = 0;
          else  
            treatment_sold.YTD = (Decimal)results.get('total_payments');
        }    
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_quarter and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_sold.QTD = 0;
          else  
            treatment_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            treatment_sold.previous_day = 0;
          else  
            treatment_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='center') {
      	/*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = last_year and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_sold.last_year = 0;
          else  
            treatment_sold.last_year = (Decimal)results.get('total_payments');
        }*/
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_month and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_month and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_sold.MTD = 0;
          else  
            treatment_sold.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = LAST_QUARTER and accountid in (select id from account where center__c = :center_id)]) {*/
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = LAST_QUARTER and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_sold.last_90 = 0;
          else  
            treatment_sold.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = LAST_MONTH and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_sold.previous_month = 0;
          else  
            treatment_sold.previous_month = (Decimal)results.get('total_payments');
        }        
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_year and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_year and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_sold.YTD = 0;
          else  
            treatment_sold.YTD = (Decimal)results.get('total_payments');
        }    
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_quarter and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where createddate = this_quarter and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_sold.QTD = 0;
          else  
            treatment_sold.QTD = (Decimal)results.get('total_payments');
        }
        //for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and accountid in (select id from account where center__c = :center_id)')) {
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            treatment_sold.previous_day = 0;
          else  
            treatment_sold.previous_day = (Decimal)results.get('total_payments');
        }
      } 
    }
    return treatment_sold;
  }
  
  public DisplayDollars getTreatmentCancelled() {
    if(treatment_cancelled==null) {
      treatment_cancelled = new DisplayDollars();
      if(treatment_cancelled_in==null)
        getTreatmentCancelledIn();
      if(treatment_cancelled_out==null)
        getTreatmentCancelledOut();
      treatment_cancelled.MTD = treatment_cancelled_in.MTD + treatment_cancelled_out.MTD;
      //treatment_cancelled.last_90 = treatment_cancelled_in.last_90 + treatment_cancelled_out.last_90;
      treatment_cancelled.previous_month = treatment_cancelled_in.previous_month + treatment_cancelled_out.previous_month;
      treatment_cancelled.QTD = treatment_cancelled_in.QTD + treatment_cancelled_out.QTD;
      treatment_cancelled.YTD = treatment_cancelled_in.YTD + treatment_cancelled_out.YTD;
      treatment_cancelled.previous_day = treatment_cancelled_in.previous_day + treatment_cancelled_out.previous_day;
      /*if(action=='all') {       
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.MTD = 0;
          else  
            treatment_cancelled.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.last_90 = 0;
          else  
            treatment_cancelled.last_90 = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.YTD = 0;
          else  
            treatment_cancelled.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.QTD = 0;
          else  
            treatment_cancelled.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.previous_day = 0;
          else  
            treatment_cancelled.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      } 
      else if(action=='user') {       
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.MTD = 0;
          else  
            treatment_cancelled.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.last_90 = 0;
          else  
            treatment_cancelled.last_90 = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.YTD = 0;
          else  
            treatment_cancelled.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.QTD = 0;
          else  
            treatment_cancelled.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.previous_day = 0;
          else  
            treatment_cancelled.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.MTD = 0;
          else  
            treatment_cancelled.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.last_90 = 0;
          else  
            treatment_cancelled.last_90 = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.YTD = 0;
          else  
            treatment_cancelled.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            treatment_cancelled.QTD = 0;
          else  
            treatment_cancelled.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.previous_day = 0;
          else  
            treatment_cancelled.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }  */    
    }
    return treatment_cancelled;
  }
  
  public DisplayDollars getTreatmentCancelledIn() {
    if(treatment_cancelled_in==null) {
      treatment_cancelled_in = new DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity  
            where lastmodifieddate = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.last_year = 0;
          else  
            treatment_cancelled_in.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and createddate = this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.MTD = 0;
          else  
            treatment_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.last_90 = 0;
          else  
            treatment_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.previous_month = 0;
          else  
            treatment_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and createddate = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.YTD = 0;
          else  
            treatment_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.QTD = 0;
          else  
            treatment_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.previous_day = 0;
          else  
            treatment_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      } 
      else if(action=='user') {
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
           where Cancel_Date__c = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.last_year = 0;
          else  
            treatment_cancelled_in.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.MTD = 0;
          else  
            treatment_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.last_90 = 0;
          else  
            treatment_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.previous_month = 0;
          else  
            treatment_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.YTD = 0;
          else  
            treatment_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.QTD = 0;
          else  
            treatment_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.previous_day = 0;
          else  
            treatment_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
      	/*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
           where Cancel_Date__c = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.last_year = 0;
          else  
            treatment_cancelled_in.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.MTD = 0;
          else  
            treatment_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.last_90 = 0;
          else  
            treatment_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
         for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.previous_month = 0;
          else  
            treatment_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.YTD = 0;
          else  
            treatment_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.QTD = 0;
          else  
            treatment_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)')) {*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
          ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_in.previous_day = 0;
          else  
            treatment_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }      
    }
    return treatment_cancelled_in;
  }
  
  public DisplayDollars getTreatmentCancelledOut() {
    if(treatment_cancelled_out==null) {
      treatment_cancelled_out = new DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity  
            where lastmodifieddate = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_year = 0;
          else  
            treatment_cancelled_out.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and createddate <> this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.MTD = 0;
          else  
            treatment_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_90 = 0;
          else  
            treatment_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_MONTH and createddate <> last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.previous_month = 0;
          else  
            treatment_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and createddate <> this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.YTD = 0;
          else  
            treatment_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.QTD = 0;
          else  
            treatment_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.previous_day = 0;
          else  
            treatment_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      } 
      else if(action=='user') {
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
           where Cancel_Date__c = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_year = 0;
          else  
            treatment_cancelled_out.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.MTD = 0;
          else  
            treatment_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_90 = 0;
          else  
            treatment_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.previous_month = 0;
          else  
            treatment_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.YTD = 0;
          else  
            treatment_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.QTD = 0;
          else  
            treatment_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.previous_day = 0;
          else  
            treatment_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
      	/*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
           where Cancel_Date__c = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_year = 0;
          else  
            treatment_cancelled_out.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.MTD = 0;
          else  
            treatment_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_90 = 0;
          else  
            treatment_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            treatment_cancelled_out.previous_month = 0;
          else  
            treatment_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.YTD = 0;
          else  
            treatment_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.QTD = 0;
          else  
            treatment_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)')) {*/
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +  
          ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.previous_day = 0;
          else  
            treatment_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }      
    }
    return treatment_cancelled_out;
  }
  
  public DisplayDollars getCollected() {
    if(collected==null) {
      collected = new DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = last_year]) {
          if(results.get('total_payments')==null)
            collected.last_year = 0;
          else  
            collected.last_year = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_month')) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = LAST_QUARTER')) {
          if(results.get('total_payments')==null)
            collected.last_90 = 0;
          else
            collected.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = LAST_MONTH')) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_year')) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments'); 
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_quarter')) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments'); 
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter)) {
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments'); 
        }
      }
      else if(action=='user') {
        /*[Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = last_year and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = last_year and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.last_year = 0;
          else  
            collected.last_year = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_QUARTER and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.last_90 = 0;
          else
            collected.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_MONTH and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_year and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments'); 
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_quarter and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments'); 
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and opportunity__c in (select id from opportunity where ownerid in : user_filters)')) {
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments'); 
        }
      }
      else if(action=='center') {
      	/*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = last_year and opportunity__c in 
          (select id from opportunity where accountid in : account_id_list)]) {
          if(results.get('total_payments')==null)
            collected.last_year = 0;
          else  
            collected.last_year = (Decimal)results.get('total_payments');
        }*/
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and opportunity__c in (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_QUARTER and opportunity__c in         (select id from opportunity where accountid in : account_id_list)]) {*/
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_QUARTER and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.last_90 = 0;
          else
            collected.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_MONTH and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_year and opportunity__c in         (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_year and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments'); 
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_quarter and opportunity__c in         (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status_formula__c = 'Collected' and payment_date__c = this_quarter and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments'); 
        }
        /*for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and opportunity__c in (select id from opportunity where accountid in : account_id_list)')) {*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and opportunity__r.account.center__r.sales_market__c = :center_id')) {        
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments'); 
        }
      }       
    }
    return collected;
  }
  
  public DisplayDollars getRefunded() {
    if(refunded==null) {
      refunded = new DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = last_year]) {
          if(results.get('total_payments')==null)
            refunded.last_year = 0;
          else  
            refunded.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c = \'Refund\' and payment_date__c = this_month')) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c = \'Refund\' and payment_date__c = LAST_QUARTER')) {
          if(results.get('total_payments')==null)
            refunded.last_90 = 0;
          else
            refunded.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c = \'Refund\' and payment_date__c = LAST_MONTH')) {
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c = \'Refund\' and payment_date__c = this_year')) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1; 
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c = \'Refund\' and payment_date__c = this_quarter')) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1; 
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status__c = \'Refund\' and payment_date__c = ' + yesterday_filter)) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1; 
        }
      }
      else if(action=='user') {
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = last_year and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.last_year = 0;
          else  
            refunded.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_month and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = LAST_QUARTER and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.last_90 = 0;
          else
            refunded.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = LAST_MONTH and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_year and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1; 
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_quarter and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1; 
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status__c = \'Refund\' and payment_date__c = ' + yesterday_filter + 'and opportunity__c in (select id from opportunity where ownerid in : user_filters)')) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1; 
        }       
      }
      else if(action=='center') {      	
      	/*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = last_year and opportunity__c in 
          (select id from opportunity where accountid in : account_id_list)]) {
          if(results.get('total_payments')==null)
            refunded.last_year = 0;
          else  
            refunded.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_month and opportunity__c in (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_month and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = LAST_QUARTER and opportunity__c in (select id from opportunity where accountid in : account_id_list)]) {*/
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = LAST_QUARTER and opportunity__r.account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            refunded.last_90 = 0;
          else
            refunded.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = LAST_MONTH and opportunity__r.account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_year and opportunity__c in (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_year and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1; 
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_quarter and opportunity__c in (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c = 'Refund' and payment_date__c = this_quarter and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1; 
        }
        /*for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status__c = \'Refund\' and payment_date__c = ' + yesterday_filter + ' and opportunity__c in (select id from opportunity where accountid in : account_id_list)')) {*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' + 
          ' payment_status__c = \'Refund\' and payment_date__c = ' + yesterday_filter + ' and opportunity__r.account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1; 
        }   
      }       
    }
    return refunded;
  }
  
  //modified by cm on 2012-11-29
  //I've added the filter to ignore all payments tied to an opportunity record that would be considered "cancelled"
  //based on a discussion with Chelsea and Vince
  public DisplayDollars getAnticipatedPayments() {
    if(anticipated_payments==null) {
      anticipated_payments = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in (\'Anticipated Promise Note\',\'Anticipated\',\'HCF in Process\') and payment_date__c = next_month')) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else  
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in (\'Anticipated Promise Note\',\'Anticipated\',\'HCF in Process\') and payment_date__c = this_month')) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in (\'Anticipated Promise Note\',\'Anticipated\',\'HCF in Process\') and payment_date__c > next_month')) {              
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in (\'Anticipated Promise Note\',\'Anticipated\',\'HCF in Process\') and payment_date__c > this_quarter')) {            
          if(results.get('total_payments')==null)
            anticipated_payments.QTD = 0;
          else
            anticipated_payments.QTD = (Decimal)results.get('total_payments');
        }       
      }
      else if(action=='user') {
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
        	opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c = next_month and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else  
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c = this_month and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c > next_month and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {              
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c > this_quarter and opportunity__c in 
          (select id from opportunity where ownerid in : user_filters)]) {            
          if(results.get('total_payments')==null)
            anticipated_payments.QTD = 0;
          else
            anticipated_payments.QTD = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='center') {
      	/*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c = next_month and opportunity__c in          (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c = next_month and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else  
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c = this_month and opportunity__c in          (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c = this_month and opportunity__r.account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c > next_month and opportunity__c in          (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c > next_month and opportunity__r.account.center__r.sales_market__c = :center_id]) {              
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c > this_quarter and opportunity__c in          (select id from opportunity where accountid in : account_id_list)]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
					opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and 
          payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c > this_quarter and opportunity__r.account.center__r.sales_market__c = :center_id]) {            
          if(results.get('total_payments')==null)
            anticipated_payments.QTD = 0;
          else
            anticipated_payments.QTD = (Decimal)results.get('total_payments');
        }
      }
    }
    return anticipated_payments;
  }  
  
  //modified by cm on 2012-11-29
  //I've added the filter to ignore all payments tied to an opportunity record that would be considered "cancelled"
  //based on a discussion with Chelsea and Vince
  public Decimal getPastDue() {
    decimal my_holder = 0.00;
    if(action=='all') {
     for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in (\'Anticipated Promise Note\',\'Anticipated\',\'HCF in Process\') and payment_date__c < today')) {
        if(results.get('total_payments')==null)
          my_holder = 0.00;
        else  
          my_holder = (Decimal)results.get('total_payments');             
      }
    }
    else if(action=='user') {
      for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
     		opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
				opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and 
        payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c < today and opportunity__c in 
        (select id from opportunity where ownerid in : user_filters)]) {
        if(results.get('total_payments')==null)
          my_holder = 0.00;
        else  
          my_holder = (Decimal)results.get('total_payments');             
      }
    }
    else if(action=='center') {
    	/*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where 
        payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c < this_month and opportunity__c in 
        (select id from opportunity where accountid in : account_id_list)]) {*/
      for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
     		opportunity__r.stagename <> 'Cancelled Not Rescheduled' and 
				opportunity__r.Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case') and
        payment_status__c in ('Anticipated Promise Note','Anticipated','HCF in Process') and payment_date__c < today and opportunity__r.account.center__r.sales_market__c = :center_id]) {
        if(results.get('total_payments')==null)
          my_holder = 0.00;
        else  
          my_holder = (Decimal)results.get('total_payments');             
      }
    }
    return my_holder;
  }  
  
  public DisplayMetrics getPipeline() {
  	if(pipeline==null) {
      pipeline = new DisplayMetrics();        
      if(action=='all') {
      	//pipeline.last_year = [select count() from account where createddate = LAST_YEAR and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
      	for(AggregateResult result : database.query('select a.consult_result__c,count(id) num_records from account a where a.consult_result__c in (\'30 Day Pipeline\',\'60 Day Pipeline\',\'90 Day Pipeline\',\'2nd Consult\') group by a.consult_result__c ' + all_filter)) {
      		if(result.get('consult_result__c')=='30 Day Pipeline')
      		  pipeline.MTD = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='60 Day Pipeline')
      		  pipeline.last_90 = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='90 Day Pipeline')
      		  pipeline.YTD = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='2nd Consult')
      		  pipeline.QTD = Integer.valueof(result.get('num_records'));
      	}      					
/*        pipeline.MTD = database.countQuery('select count() from account a where a.consult_result__c = \'30 Day Pipeline\'' + all_filter);
        pipeline.last_90 = database.countQuery('select count() from account a where a.consult_result__c = \'60 Day Pipeline\'' + all_filter);
        pipeline.YTD = database.countQuery('select count() from account a where a.consult_result__c = \'90 Day Pipeline\'' + all_filter);
        pipeline.QTD = database.countQuery('select count() from account a where a.consult_result__c = \'2nd Consult\'' + all_filter);*/
      }
      else if(action=='user') {
        //pipeline.last_year  = [select count() from account where createddate = LAST_YEAR and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        for(AggregateResult result : [select a.consult_result__c,count(id) num_records from account a where a.ownerid in : user_filters and a.consult_result__c in ('30 Day Pipeline','60 Day Pipeline','90 Day Pipeline','2nd Consult') group by a.consult_result__c]) {
      		if(result.get('consult_result__c')=='30 Day Pipeline')
      		  pipeline.MTD = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='60 Day Pipeline')
      		  pipeline.last_90 = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='90 Day Pipeline')
      		  pipeline.YTD = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='2nd Consult')
      		  pipeline.QTD = Integer.valueof(result.get('num_records'));
      	}             
        /*pipeline.MTD = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '30 Day Pipeline'];
        pipeline.last_90 = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '60 Day Pipeline'];
        pipeline.YTD = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '90 Day Pipeline'];
        pipeline.QTD = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '2nd Consult'];*/
      }
      else if(action=='center'){
      	//pipeline.last_year  = [select count() from account where createddate = LAST_YEAR and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
      	for(AggregateResult result : [select a.consult_result__c,count(id) num_records from account a where center__r.sales_market__c = : center_id and a.consult_result__c in ('30 Day Pipeline','60 Day Pipeline','90 Day Pipeline','2nd Consult') group by a.consult_result__c]) {
      		if(result.get('consult_result__c')=='30 Day Pipeline')
      		  pipeline.MTD = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='60 Day Pipeline')
      		  pipeline.last_90 = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='90 Day Pipeline')
      		  pipeline.YTD = Integer.valueof(result.get('num_records'));
      		if(result.get('consult_result__c')=='2nd Consult')
      		  pipeline.QTD = Integer.valueof(result.get('num_records'));
      	}     
      	/*pipeline.MTD = [select count() from account a where center__r.sales_market__c = : center_id and a.consult_result__c = '30 Day Pipeline'];
        pipeline.last_90 = [select count() from account a where center__r.sales_market__c = :center_id and a.consult_result__c = '60 Day Pipeline'];
        pipeline.YTD = [select count() from account a where center__r.sales_market__c = :center_id and a.consult_result__c = '90 Day Pipeline'];
        pipeline.QTD = [select count() from account a where center__r.sales_market__c = :center_id and a.consult_result__c = '2nd Consult'];*/
        /*pipeline.MTD = [select count() from account a where center__c = : center_id and a.consult_result__c = '30 Day Pipeline'];
        pipeline.last_90 = [select count() from account a where center__c = :center_id and a.consult_result__c = '60 Day Pipeline'];
        pipeline.YTD = [select count() from account a where center__c = :center_id and a.consult_result__c = '90 Day Pipeline'];
        pipeline.QTD = [select count() from account a where center__c = :center_id and a.consult_result__c = '2nd Consult'];*/
      }
    }
    return pipeline;
  }
  
  public DisplayDollars getUpsellSold() {
    if(upsell_sold==null) {
      upsell_sold = new DisplayDollars();
      if(action=='all') {      	
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = this_month' )) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else  
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = LAST_QUARTER' )) {
          if(results.get('total_payments')==null)
            upsell_sold.last_90 = 0;
          else  
            upsell_sold.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = LAST_MONTH' )) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else  
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = this_year' )) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else  
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }    
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = this_quarter' )) {
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else  
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter )) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else  
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='user'){
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_month and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else  
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = LAST_QUARTER and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.last_90 = 0;
          else  
            upsell_sold.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = LAST_MONTH and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else  
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_year and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else  
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }    
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_quarter and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else  
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else  
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='center') {
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_month and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_month and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else  
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = LAST_QUARTER and accountid in (select id from account where center__c = :center_id)]) {*/
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = LAST_QUARTER and account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            upsell_sold.last_90 = 0;
          else  
            upsell_sold.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = LAST_MONTH and account.center__r.sales_market__c = :center_id]) {          	
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else  
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_year and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_year and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else  
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }    
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_quarter and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where createddate = this_quarter and account.center__r.sales_market__c = :center_id]) {          
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else  
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        //for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and accountid in (select id from account where center__c = :center_id)')) {
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and account.center__r.sales_market__c = :center_id')) {        	
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else  
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      } 
    }
    return upsell_sold;
  }
  
  public DisplayDollars getUpsellCancelledIn() {
    if(upsell_cancelled_in==null) {
      upsell_cancelled_in = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and createddate = this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else  
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else  
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else  
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and createddate = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else  
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else  
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else  
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      } 
      else if(action=='user') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else  
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else  
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else  
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else  
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else  
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else  
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else  
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else  
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else  
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else  
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else  
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)')) {*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
          ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else  
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }      
    }
    return upsell_cancelled_in;
  }
  
  public DisplayDollars getupsellCancelledOut() {
    if(upsell_cancelled_out==null) {
      upsell_cancelled_out = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and createddate <> this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else  
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.last_90 = 0;
          else  
            upsell_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_MONTH and createddate <> last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else  
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and createddate <> this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else  
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else  
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_day = 0;
          else  
            upsell_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      } 
      else if(action=='user') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else  
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.last_90 = 0;
          else  
            upsell_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else  
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else  
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else  
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_day = 0;
          else  
            upsell_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_month and createddate <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else  
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_QUARTER and createddate <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.last_90 = 0;
          else  
            upsell_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = LAST_MONTH and createddate <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else  
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_year and createddate <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else  
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity 
          where Cancel_Date__c = this_quarter and createddate <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_market__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else  
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)')) {*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity ' +  
            ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate <> yesterday and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_market__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_day = 0;
          else  
            upsell_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }      
    }
    return upsell_cancelled_out;
  }
  
  public String getlead_reportid() {
  	List<Report> r = [Select id From Report r where developername = 'Unconverted_Consults'];  	
  	if(r.size()==0)
  	  return '';
  	else
  	  return String.valueOf(r[0].id);
  }
  
  public String getconsult_reportid() {
  	List<Report> r = [Select id,developername From Report r where developername = 'Consults_w_Fields_to_Update'];
  	if(r.size()==0)
  	  return '';
  	else
  	  return String.valueOf(r[0].id);
  }
  
  public String getprost_reportid() {  	
  	List<Report> r = [select id,name,developername from report where developername = 'Pes_to_Update_Dashboard'];
  	if(r.size()==0)
  	  return '';
  	else
  	  return String.valueOf(r[0].id);
  }
  
  public String getlead_exceptions() {
  	String return_val = '';
  	if(action=='all') {
  		Integer I = database.countQuery('select count() from lead l where l.status in (\'Consult Completed\',\'Consultation Scheduled\',\'Consult Scheduled\',\'Rescheduled Consult\') and datetime_consult_scheduled__c < today and l.convertedcontactid = null and datetime_consult_scheduled__c >= last_month' + all_filter);
  		return_val = String.valueOf(I);
  	}
  	else if(action=='center') {  		
  		//Integer I = [select count() from lead l where l.status in ('Consult Scheduled','Rescheduled Consult') and datetime_consult_scheduled__c < today and l.convertedcontactid = null and datetime_consult_scheduled__c >= last_month and l.center__c = :center_id];
  		Integer I = [select count() from lead l where l.status in ('Consult Completed','Consultation Scheduled','Consult Scheduled','Rescheduled Consult') and datetime_consult_scheduled__c < today and l.convertedcontactid = null and datetime_consult_scheduled__c >= last_month and l.center__r.sales_market__c = :center_id];
  		return_val = String.valueOf(I);
  	}
  	else if(action=='user')
  	  return_val = '<span style="font-style:italic;font-weight:bold;">N/A</span>';
  	return return_val;
  }
  
  public Integer getconsult_exceptions() {
  	Integer return_val = 0;
  	if(action=='all') 
  		return_val = database.countQuery('Select count() from account a where a.consult_result__c = null and a.createddate >= last_month' + all_filter);
  	else if(action=='center') 
  		//return_val = [Select count() from account a where a.center__c = :center_id and a.consult_result__c = null and a.createddate >= last_month ];
  		return_val = [Select count() from account a where a.center__r.sales_market__c = :center_id and a.consult_result__c = null and a.createddate >= last_month ];
  	else if(action=='user') 
  		return_val = [Select count() from account a where a.ownerid in : user_filters and a.consult_result__c = null and a.createddate >= last_month];
  	return return_val;
  }
  
  public Integer getprost_exceptions() {
    Integer return_val = 0;
    if(action=='all') 
  		return_val = database.countQuery('select count() from opportunity o where o.closedate < today and o.closedate >= last_month and stagename = \'Scheduled\'' + all_filter);
  	else if(action=='center') 
  		//return_val = [select count() from opportunity o where o.account.center__c = :center_id and o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' ];
  		return_val = [select count() from opportunity o where o.account.center__r.sales_market__c = :center_id and o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' ];
  	else if(action=='user') 
  		return_val = [select count() from opportunity o where o.ownerid in : user_filters and o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' ];
  	return return_val; 	
  }  
  
  public DisplayDecimal gettrue_closerate() {
  	gettreatmentsold();
  	gettreatmentcancelled();
  	try {
	  	if(true_closerate==null) {
	      if(treatment_sold.previous_day + treatment_cancelled.previous_day==0)
	        true_closerate.previous_day = 0;
	      else {
	        true_closerate.previous_day = (Collected.previous_day + Refunded.previous_day)/(treatment_sold.previous_day + treatment_cancelled.previous_day) * 100;
	        true_closerate.previous_day = true_closerate.previous_day.divide(1,1);
	      }      
	      if(treatment_sold.last_year + treatment_cancelled.last_year==0)
	        true_closerate.last_year = 0;
	      else {
	        true_closerate.last_year = (Collected.last_year + Refunded.last_year)/(treatment_sold.last_year + treatment_cancelled.last_year) * 100;
	        true_closerate.last_year = true_closerate.last_year.divide(1,1);
	      }      
	      if(treatment_sold.MTD + treatment_cancelled.MTD==0)
	        true_closerate.MTD = 0;
	      else {
	        true_closerate.MTD = (Collected.MTD + Refunded.MTD)/(treatment_sold.MTD + treatment_cancelled.MTD) * 100;
	        true_closerate.MTD = true_closerate.MTD.divide(1,1);
	      }      
	      /*if(treatment_sold.last_90 + treatment_cancelled.last_90==0)
	        true_closerate.last_90 = 0;
	      else {
	        true_closerate.last_90 = (Collected.last_90 + Refunded.last_90)/(treatment_sold.last_90 + treatment_cancelled.last_90) * 100;
	        true_closerate.last_90 = true_closerate.last_90.divide(1,1);
	      }*/
	      if(treatment_sold.previous_month + treatment_cancelled.previous_month==0)
	        true_closerate.previous_month = 0;
	      else {
	        true_closerate.previous_month = (Collected.previous_month + Refunded.previous_month)/(treatment_sold.previous_month + treatment_cancelled.previous_month) * 100;
	        true_closerate.previous_month = true_closerate.previous_month.divide(1,1);
	      }       
	      if(treatment_sold.YTD + treatment_cancelled.YTD==0)
	        true_closerate.YTD = 0;
	      else {
	        true_closerate.YTD = (Collected.YTD + Refunded.YTD)/(treatment_sold.YTD + treatment_cancelled.YTD) * 100;
	        true_closerate.YTD = true_closerate.YTD.divide(1,1);
	      }      
	      if(treatment_sold.QTD + treatment_cancelled.QTD==0)
	        true_closerate.QTD = 0;
	      else {
	        true_closerate.QTD = (Collected.QTD + Refunded.QTD)/(treatment_sold.QTD + treatment_cancelled.QTD) * 100;
	        true_closerate.QTD = true_closerate.QTD.divide(1,1);
	      }    		
	  	}
	  }
	  catch (Exception e) {
	  	System.debug('Debug : ' + e);
	  }
  	return true_closerate;
  }
}