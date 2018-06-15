public with sharing class ctrl_SalesGoals {
  /* Modified by cm on 2014-02-14
  Reworking this to handle the changes for the new commission program.  A lot of the budget stuff is going to be placed on hold for the moment as it's not currently relevant.
  At some point,  I might have to integrate some of that stuff back in,  as we do need a way to track the commission floors by point in time (otherwise the snapshot process will be a major hassle,
  especially if they change a lot of the tiers)
  */

  //modified by cm on 2016/12/5 - added paycheck id and field deployment date to the screen

  public Integer view_year {get; set;}
  public Integer view_month {get; set;}
  public Integer page = 1;
  public Integer num_pages = 0;
  public String result_msg {get; set;}
  Integer record_count;
  Double page_holder;
  Integer records_per_page = 10;
  public boolean display_next = true;
  public boolean display_prev = false;
  public String name_filter {get; set;}
  public String type_filter = 'all';
  public boolean getdisplay_next() { return display_next; }
  public boolean getdisplay_prev() { return display_prev; }
  public Integer getpage() {return page;}
  public Integer getnum_pages() {return num_pages;}
  public String hyper_prefix;
  public String gethyper_prefix() { return hyper_prefix; }
  public String download_link {get; set;}
  public Map<ID,Center_Information__c> all_centers {get; set;}

  public ctrl_SalesGoals() {
        view_year = Date.today().year();
        view_month = Date.today().month();
        name_filter = '';
    if(ApexPages.currentPage().getHeaders()==null)
            hyper_prefix = '';
          else
            hyper_prefix = 'https://'+ApexPages.currentPage().getHeaders().get('Host');
        download_link = hyper_prefix + '/apex/opsDashcsv?format=18&rmonth=' + view_month + '&ryear=' + view_year;
        all_centers = new Map<Id,Center_Information__c>([select id,name,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,Baseline_Target__c,Baseline_Target_CPC__c from Center_Information__c]);
  }

  DisplayUser[] pec_list;
  public class DisplayUser {
        public User userinfo {get; set;}
        public Decimal center_1_floor {get; set;}
        public Decimal center_2_floor {get; set;}
        public Decimal center_3_floor {get; set;}
        public Decimal center_base {get; set;}
        public Decimal center_base_cpc {get; set;}

        public DisplayUser(User my_user, Decimal t1, Decimal t2, Decimal t3, Decimal t4, Decimal t5) {
          this.userinfo = my_user;
          this.center_1_floor = t1;
          this.center_2_floor = t2;
          this.center_3_floor = t3;
          this.center_base = t4;
          this.center_base_cpc = t5;
          System.debug('Center base : ' + t4);
        }
  }

  public List<SelectOption> getGoalOptions() {
        List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('None','None'));
    options.add(new SelectOption('User','User'));
    options.add(new SelectOption('Center','Center'));
    return options;
  }

  public List<SelectOption> getTypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('all','All Users'));
    options.add(new SelectOption('pec','Assigned CA/PEC'));
    return options;
  }

  public List<SelectOption> getYearOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(Integer cnt=2013; cnt<= view_year; cnt++) {
          options.add(new SelectOption(String.valueof(cnt),String.valueof(cnt)));
        }
    return options;
  }

  public List<SelectOption> getMonthOptions() {
        Map<Integer,String> month_list = new Map<Integer,String> {1=>'January',2=>'February',3=>'March',4=>'April',5=>'May',6=>'June',7=>'July',8=>'August',9=>'September',10=>'October',11=>'November',12=>'December'};
        List<SelectOption> options = new List<SelectOption>();
        for(Integer cnt=1;cnt<=12;cnt++) {
          options.add(new SelectOption(String.valueof(cnt),month_list.get(cnt)));
        }
        return options;
  }

  public void refresh_link() {
        download_link = hyper_prefix + '/apex/opsDashcsv?format=18&rmonth=' + view_month + '&ryear=' + view_year;
  }

  public String gettype_filter() {return type_filter; }
  public void settype_filter(String type_filter) { this.type_filter = type_filter;}

  public List<SelectOption> getCenterlist() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','None'));
    list<Center_Information__C> centers = [Select c.id,c.name From Center_Information__c c where c.type__c not in ('Affiliate','Network Center')  order by c.name];
    for(Center_Information__c center : centers) {
      options.add(new SelectOption(center.id,center.name));
    }
    return options;
  }

  public void center_change() {
        save();
        refreshresults();
  }

  public void refreshresults() {
        String query_filter = '%' + name_filter + '%';
        pec_list = new DisplayUser[] {};
        /*List<User> pec_users =[select name,email,lastname,firstname,id,user_role__c,Sales_Goal__c,Center_PEC__c from User
         where IsActive = true and profileid in (select id from profile where name in ('Patient Education Consultant','PEC - Multiple Centers','PEC_VisiblePrescreen'))
         and name like :query_filter order by name];*/
          List<User> pec_users;
        if(type_filter=='all')
          pec_users = [select Field_Deploy_Date__c, Ultipro_Id__c, region_pec__c,name,email,lastname,firstname,id,user_role__c,Sales_Goal__c,Center_PEC__c,Center_Administrator__c,Regional_Traveler__c,goal_type__c,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,isactive,Baseline_Target__c, Baseline_Target_CPC__c from User
            where name like :query_filter order by name];
        else
          pec_users = [select Field_Deploy_Date__c, Ultipro_Id__c, region_pec__c,name,email,lastname,firstname,id,user_role__c,Sales_Goal__c,Center_PEC__c,Center_Administrator__c,Regional_Traveler__c,goal_type__c,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,isactive,Baseline_Target__c, Baseline_Target_CPC__c from User
            where Center_PEC__c != null and name like :query_filter order by name];
        record_count = pec_users.size();
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
        for(User my_user : pec_users) {
          if(cnt > low_range && cnt <= high_range) {
            String positions = '';
                DisplayUser duser;
                if(all_centers.containskey(my_user.center_PEC__c))
              duser = new DisplayUser(my_user,all_centers.get(my_user.center_PEC__c).tier_1_floor__c,all_centers.get(my_user.center_PEC__c).tier_2_floor__c,all_centers.get(my_user.center_PEC__c).tier_3_floor__c,all_centers.get(my_user.center_PEC__c).Baseline_Target__c,all_centers.get(my_user.center_PEC__c).Baseline_Target_CPC__c);
            else
              duser = new DisplayUser(my_user,0.00,0.00,0.00,0.00,0);
                pec_list.add(duser);
          }
          cnt++;
        }
  }

 /* public Pagereference prev_year() {
        view_year = view_year - 1;
        result_msg = '';
        check_for_null_budgets();
        return null;
  }*/

  /*public Pagereference next_year() {
        view_year = view_year + 1;
        result_msg = '';
        check_for_null_budgets();
        return null;
  }*/

  /*public Pagereference check_for_null_budgets() {
        //build a list of center budgets for the current year/center
    String query_filter = ' and user__r.name like \'%' + name_filter + '%\' and user__r.center_pec__c != null';
        String query = 'Select u.Sales_Goal__c, u.Id, u.Fiscal_Month__c,u.user__r.name,u.user__c  From User_Goals__c u where u.fiscal_year__c =  ' + view_year + query_filter + ' order by u.user__c';
        Map<ID, Map<Integer,User_Goals__c>> budget_map = new Map<ID, Map<Integer,User_Goals__c>> ();
        Map<Integer,User_Goals__c> m1 = new Map<Integer,User_Goals__c> ();
        System.debug('Query : ' + query);
        List<User_Goals__c> center_attributes = database.query(query);
        String last_id;
        for(User_Goals__c user_attribute : center_attributes) {
                if(last_id==null)
                  last_id = user_attribute.user__c;
                if(last_id<>user_attribute.user__c) {
                        last_id = user_attribute.user__c;
                        m1 = new Map<Integer,User_Goals__c> ();
                }
                m1.put(Integer.ValueOf(user_attribute.fiscal_month__c),user_attribute);
                budget_map.put(user_attribute.user__c,m1);
        }
        List<User_Goals__c> insert_budgets = new List<User_Goals__c> {};
        query = 'select id,name,sales_goal__c from user where name like \'%' + name_filter + '%\' and center_pec__c != null order by name';
        System.debug('Query : ' + query);
        User_Goals__c new_budget = new User_Goals__c();
        for(User my_user : database.query(query)) {
                Decimal default_sales_goal = 0;
                if(my_user.Sales_Goal__c<>null)
                  default_sales_goal = my_user.Sales_Goal__c;
                for(Integer my_month = 1;my_month<=12;my_month++) {
                        if(budget_map.get(my_user.id) == null) {
                                new_budget = new User_Goals__c(fiscal_month__c = my_month, fiscal_year__c = view_year, user__c = my_user.id, sales_goal__c = default_sales_goal);
          insert_budgets.add(new_budget);
                        }
                        else if(budget_map.get(my_user.id).get(my_month)==null) {
                                new_budget = new User_Goals__c(fiscal_month__c = my_month, fiscal_year__c = view_year, user__c = my_user.id, sales_goal__c = default_sales_goal);
          insert_budgets.add(new_budget);
                        }
                }
        }
        if(insert_budgets.size()>0)
          insert insert_budgets;
        return null;
  }*/


  public Pagereference user_search() {
    page = 1;
    refreshresults();
        return null;
  }

  public Pagereference display_dashboard() {
        Pagereference pr = new PageReference('/apex/OpsDashboard');
        pr.getParameters().put('action','user');
        pr.setredirect(true);
    return pr;
  }

  public void save() {
        /*Map<ID,String> region_map = new Map<ID,String>();
        //build a list of the centers and the regions they map to
        For(Center_Information__c ci : [select id,sales_region__c from Center_Information__c]) {
                region_map.put(ci.id,ci.sales_region__c);
        }
        list<User> user_update_list = new List<User>{};
                list<User_Goals__c> goal_update_list = new List<User_Goals__c>{};
                for(DisplayUser my_user : pec_list) {
                        //User u = my_user.userinfo;
                        if(region_map.get(my_user.userinfo.center_pec__c)!=null) {
                                my_user.userinfo.region_pec__c = region_map.get(my_user.userinfo.center_pec__c);
                        }
                        user_update_list.add(my_user.userinfo);

                        for(User_Goals__c bmonth : my_user.budget_months) {
                          goal_update_list.add(bmonth);
                        }
                }
                if(goal_update_list.size()>0)
                  update goal_update_list;
                if(user_update_list.size()>0) {
                  update user_update_list;
                  check_for_null_budgets();
                  refreshresults();
                }
                result_msg = '<span style="font-style:italic;color:blue;font-weight:bold;">Success - </span> Metrics have been updated';
                return null;*/
          List <User> user_list = new List<User>();
          for(DisplayUser my_user : pec_list) {
                user_list.add(my_user.userinfo);
          }
          try {
                update user_list;
          }
          catch (Exception e) {

          }
        }

        public Pagereference next() {
          try {
                page++;
                result_msg = '';
                refreshresults();
          }
          catch(Exception e) {  system.debug ('error: ' + e.getMessage() );    }
          return null;
        }

        public Pagereference prev() {
                page = page - 1;
                result_msg = '';
                refreshresults();
                return null;
        }

  public DisplayUser[] getPEClist() {
        try {
          Integer user_match = 0;
          for(User allowed_users : [select id from user where name in ('Todd DeYoung','Scott Lawrence','Erica Logan','Vince Larson','Bryce Burger','Brooke Young','Steve DeWeese','John Merandi','Houmam Ali','Kathy Michaelson','Kym Lombardo','Shane McCarthy','Marco Gonzalez','Dan McKelvey','Mindy Smith')]) {
          if(Userinfo.getUserId()==allowed_users.id)
            user_match++;
          }
          //new catch all for RBDs,  that will get me out of maintaining the list as much
          Integer admin_count = [select count() from Profile where name in ('RBD','Data Audit Team', 'System Administrator') and id = :Userinfo.getProfileId()];
          user_match += admin_count;
          if(!test.isRunningTest())
            System.assert(user_match > 0);
        }
        catch(exception e) {
          System.debug('You are not authorized to view this page');
        }
        refreshresults();
        return pec_list;
  }
}