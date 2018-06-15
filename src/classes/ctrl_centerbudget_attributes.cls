public without sharing class ctrl_centerbudget_attributes {
  public Integer view_year {get; set;}
  public String attribute_filter {get; set;}
  public String center_filter {get; set;}
  public String result_msg {get; set;}
  public Integer page = 1;
  public Integer num_pages = 0;
  Integer record_count;
  Double page_holder;
  Integer records_per_page = 10;
  public boolean display_next = true;
  public boolean display_prev = false;
  public boolean getdisplay_next() { return display_next; }
	public boolean getdisplay_prev() { return display_prev; }
	public Integer getpage() {return page;}
	public Integer getnum_pages() {return num_pages;}
	public String hyper_prefix;
  public String gethyper_prefix() { return hyper_prefix; }
  
  public CenterBudget[] all_centers = new CenterBudget[] {};
  public class CenterBudget {
  	public Center_Information__c centerinfo {get; set;}
  	public List<Center_Budget__c> budget_months {get; set;}
  	public CenterBudget (Center_Information__c ci) {
  		this.centerinfo = ci;
  	}
  }
  
  public Pagereference next() {
		try {
			page++;
			result_msg = '';
			refresh_results();
		}
		catch(Exception e) {  system.debug ('error: ' + e.getMessage() );    }
		return null;
	}
	
  public Pagereference prev() {
		page = page - 1;
		result_msg = '';
		refresh_results();
		return null;
	}
  
  public String getattrib_name() {
  	String return_val = '';
  	if(attribute_filter=='1')
  	  return_val = 'Sales Goal';
  	else if(attribute_filter=='2')
  	  return_val = 'Budgeted Close Rate';
  	else if(attribute_filter=='3')
  	  return_val = 'Budgeted Consults';
  	return return_val;  	  
  }
  
  public List<Selectoption> getattribute_options() {
  	List<Selectoption> radio_buttons = new List<Selectoption>();
  	radio_buttons.add(new Selectoption('1','Sales Goal'));
  	radio_buttons.add(new Selectoption('2','Budgeted Close Rate'));
  	radio_buttons.add(new Selectoption('3','Budgeted Consults'));
  	return radio_buttons;
  }
  
  public List<Selectoption> getcenter_list() {
  	List<Selectoption> centers = new List<Selectoption>();
  	centers.add(new Selectoption('n/a','All Centers'));
  	for(Center_Information__c my_center : [select id,name from Center_Information__c order by name]) {
  		centers.add(new Selectoption(my_center.id,my_center.name));
  	}
  	return centers;
  }
  
  public ctrl_centerbudget_attributes() {
  	view_year = Date.today().year();
  	attribute_filter = '1';
  	center_filter = 'n/a';
  	if(ApexPages.currentPage().getHeaders()==null)
	    hyper_prefix = '';
	  else
	    hyper_prefix = 'http://'+ApexPages.currentPage().getHeaders().get('Host');  
  }
  
  public Pagereference prev_year() {
  	view_year = view_year - 1;
  	check_for_null_budgets();
  	return null;
  }
  
  public Pagereference next_year() {
  	view_year = view_year + 1;
  	check_for_null_budgets();
  	return null;
  }
  
  public Pagereference center_search() {
  	//refresh_results();
  	return null;
  }
   
  public Pagereference check_for_null_budgets() {
  	//build a list of center budgets for the current year/center
  	String query = 'Select c.Fiscal_Month__c, c.Budgeted_Consults__c, c.Sales_Goal__c, c.Id, c.Budgeted_Close_Rate__c, c.Center__c, c.Center__r.Name From Center_Budget__c c where fiscal_year__c = ' + view_year;
  	if(center_filter<>'n/a')
  	  query += ' and center__c =: center_filter';  	
  	query += ' order by center__c';
  	Map<ID, Map<Integer,Center_Budget__c>> budget_map = new Map<ID, Map<Integer,Center_Budget__c>> ();
  	Map<Integer,Center_Budget__c> m1 = new Map<Integer,Center_Budget__c> ();
  	List<Center_Budget__c> center_attributes = database.query(query);
  	String last_id; 
  	for(Center_Budget__c center_attribute : center_attributes) {
  		if(last_id==null)
  		  last_id = center_attribute.center__c;
  		if(last_id<>center_attribute.center__c) {
  			last_id = center_attribute.center__c;
  			m1 = new Map<Integer,Center_Budget__c> ();  			
  		} 		  		
  		m1.put(Integer.ValueOf(center_attribute.fiscal_month__c),center_attribute);
  		budget_map.put(center_attribute.center__c,m1);  		
  	}
  	List<Center_Budget__c> insert_budgets = new List<Center_Budget__c> {};
  	String query_filter = '';
  	if(center_filter<>'n/a')
  	  query_filter += ' where id =: center_filter ';  	
  	query = 'select id,name,sales_goal__c from center_information__c ' + query_filter + ' order by name';
  	Center_Budget__c new_budget = new Center_Budget__c();  	
  	for(Center_Information__c center : database.query(query)) {
  		Decimal default_sales_goal = 0;
  		if(center.Sales_Goal__c<>null)
  		  default_sales_goal = center.Sales_Goal__c;
  		for(Integer my_month = 1;my_month<=12;my_month++) {  			
  			if(budget_map.get(center.id) == null) {
  				new_budget = new Center_Budget__c(fiscal_month__c = my_month, fiscal_year__c = view_year, center__c = center.id, sales_goal__c = default_sales_goal, budgeted_consults__c = 0, budgeted_close_rate__c = 0);
          insert_budgets.add(new_budget);  		
  			} 
  			else if(budget_map.get(center.id).get(my_month)==null) {
  				new_budget = new Center_Budget__c(fiscal_month__c = my_month, fiscal_year__c = view_year, center__c = center.id, sales_goal__c = default_sales_goal, budgeted_consults__c = 0, budgeted_close_rate__c = 0);
          insert_budgets.add(new_budget);
  			} 
  		}
  	}
  	if(insert_budgets.size()>0)
  	  insert insert_budgets;
  	return null;
  }
  
  public PageReference save() {
  	list<Center_Budget__c> update_budget_list = new List<Center_Budget__c>();
  	for(CenterBudget my_center : all_centers) {
  		System.debug('Start All centers');
  		for(Center_Budget__c my_budget : my_center.budget_months) {
  			System.debug('Getting Budget Numbers');
  			update_budget_list.add(my_budget);
  		}
  	}	  	  
  	if(update_budget_list.size()>0) {
  	  //build a try catch here and set a variable to display the results....
  	  try {
  	    update update_budget_list;
  	    result_msg = '<span style="font-style:italic;color:blue;font-weight:bold;">Success - </span> Metrics have been updated';  	    
  	  } catch(System.DmlException e) {
  	  	result_msg = '<span style="font-style:italic;color:red;font-weight:bold;">Failure - </span> Unable to save data<br />';
  	  	for(Integer i = 0;i<=e.getNumDml();i++) {
  	  		result_msg += e.getDmlFieldNames(i) + ' ' + e.getDmlFields(i) + ' ' + e.getDmlMessage(i) + '<br />';
  	  	}
  	  	return null;
  	  }  	 
  	}
  	return null;
  }
  
  public String refresh_results() {      	
  	String query = 'Select id,name,(Select Id, Center__c, Fiscal_Year__c, Fiscal_Month__c, Budgeted_Consults__c, Budgeted_Close_Rate__c, Sales_Goal__c From Center_Budgets__r where fiscal_year__c = ' + view_year + 
  	  ' order by fiscal_month__c) From Center_Information__c c';
    if(center_filter<>'n/a')
  	  query += ' where id =: center_filter ';
  	all_centers = new CenterBudget[] {};	  	  	 
  	//System.debug('Query : ' + query); 	  
  	query += ' order by c.name';
  	List<Center_Information__c> my_centers = database.query(query);
  	record_count = my_centers.size();
    page_holder = math.ceil((record_count/records_per_page));  		  		
  	num_pages = page_holder.intvalue();
    //only here because for some reason ceil is rounding down!  		
  	if(math.mod(record_count, records_per_page)>0)
  	  num_pages++;
  	Integer low_range = (page - 1) * records_per_page;
  	Integer high_range = page * records_per_page;
  	Integer cnt = 1;
  	if(page > 1)
  	  display_prev = true;
  	else
  	  display_prev = false;
  	if(num_pages > 1 && page < num_pages)
  	  display_next = true;
  	else
  	  display_next = false;  		
  	for(Center_Information__c center : my_centers) {
  		if(cnt > low_range && cnt <= high_range) {
	  		CenterBudget my_center = new CenterBudget(center);
	  		my_center.budget_months = center.center_budgets__r;
	  		all_centers.add(my_center);
  		}
  		cnt++;
  	}
  	return null;
  }
  
  public CenterBudget[] getall_centers() {
  	//if(all_centers==null)
 	    refresh_results();
  	return all_centers;  	
  }
    
}