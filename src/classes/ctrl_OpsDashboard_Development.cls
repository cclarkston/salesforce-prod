public without sharing class ctrl_OpsDashboard_Development {
        /*modified by cm on 2013-04-07
        Modifying the all queries so they don't include numbers from the Affiliate centers.  This is to preserve the reporting for the sales and ops teams as much as possible.
        The majority of items have been adjusted,  but I did not touch items hitting the CC_Payments table (we're not collecting money in SF for this program yet) and I didn't touch the user_goals
        stuff.  If the program adjust,  this might need to be tweaked down the road
        */

    /*modified by cm on 2014-02-14
    New comission program required some changes.  I've added a new class to handle the commission calc.  Some of the methods in here might not be called anymore - target % and goals.
    Still working through all the necessary adjustments
    */

    /*modified by cm on 2015-6-4
    per data governance,  we're closing the in period cancellation loop-hole.

    */
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
  String Sales_Region;
  //Set<ID> account_id_list = new Set<ID>();
  Map<String,ID> report_mapping;
  public String download_string;
  public String getdownload_string() { return download_string; }
  public string display_pec {get; set;}
  public string display_center {get; set;}
  public string display_region {get; set;}
  public String action {get; set;}
  public String report_header;
  public String outputtext {get; set;}
  public String getaction() { return action; }
  public String getreport_header() { return report_header; }
  public String yesterday_filter = ' yesterday ';
  public String getyesterday_filter() {
        return yesterday_filter;
  }
  User this_user = [select center_pec__c,center_administrator__c from user where id = :Userinfo.getUserId()];
  public String hyper_prefix;
  public String gethyper_prefix() { return hyper_prefix; }
  public String all_filter = '';
  public Set<String> action_set = new Set<String>{'all', 'user', 'center', 'region'};
  public Map<String, String> ranges = new Map<String, String>{'MTD'            => 'THIS_MONTH',
                                                              'previous_month' => 'LAST_MONTH',
                                                              'YTD'            => 'THIS_YEAR',
                                                              'QTD'            => 'THIS_QUARTER',
                                                              'previous_day'   => yesterday_filter};

  Set<ID> user_filters = new Set<ID>();
  public boolean display_user_button = false;
  public boolean display_center_button = false;
  public boolean display_all_button = false;
  public boolean display_admin = false;
  public boolean display_ppriv = false;
  public boolean display_ca = false;
  public boolean display_dashboard {get; set;}
  public boolean display_hygiene {get; set;}
  public boolean display_exception {get; set;}

  public String anticipated_filter {get; set;}
  public boolean getdisplay_user_button() { return display_user_button; }
  public boolean getdisplay_center_button() { return display_center_button; }
  public boolean getdisplay_all_button() { return display_all_button; }
  public boolean getdisplay_admin() { return display_admin; }
  public boolean getdisplay_ppriv() {return display_ppriv;}
  public boolean getdisplay_ca() { return display_ca; }
  public List<Center_Information__c> all_centers;
  public Map<ID,Center_Information__c> all_centers_map;

  //new bonus stuff - not used
  /*public Decimal bonus_1_floor {get; set;}
  public Decimal bonus_2_floor {get; set;}
  public Decimal bonus_3_floor {get; set;}
  public Decimal bonus_3_qtr_floor {get; set;}
  public Decimal bonus_1_amount {get; set;}
  public Decimal bonus_2_amount {get; set;}
  public Decimal bonus_3_amount {get; set;}
  public Decimal bonus_3_qtr_amount {get; set;}
  public Decimal bonus_all_amount {get; set;}*/

  //even newer bonus stuff - 1/27/2015
  /*public Integer current_tier {get; set;}
  public Integer previous_tier {get; set;}
  public Integer next_tier {get; set;}
  public Decimal current_payout {get; set;}
  public Decimal previous_payout {get; set;}
  public Decimal next_payout {get; set;}
  public Decimal current_payout_amount {get; set;}
  public Decimal previous_payout_amount {get; set;}
  public Decimal next_payout_amount {get; set;}*/
  public pec_compensation bonus_calc {get; set;}
  public rsm_compensation rsm_bonus_calc {get; set;}
  public Decimal payout_collections {get; set;}
  public Decimal payout_close {get; set;}
  public Decimal payout_cpc   {get; set;}
  public Integer total_open_days;
  public Integer completed_open_days;
  public Decimal collections_limit {get; set;}
  public String getdisplay_collections_limit() {
        if(collections_limit==null)
          return 'N/A';
        else {
          Decimal climit = collections_limit==null?0:collections_limit;
      return String.valueof(climit);
        }
  }

  //PEC RANKING SNAPSHOT
  public String national_overall_ribbon {get; set;}
  public String tcr_national_ribbon {get; set;}
  public String tcr_regional_ribbon {get; set;}
  public String callback_national_ribbon {get; set;}
  public String callback_regional_ribbon {get; set;}
  public String rainmaker_national_ribbon {get; set;}
  public String rainmaker_regional_ribbon {get; set;}
  public String learning_national_ribbon {get; set;}
  public String learning_regional_ribbon {get; set;}
  public String national_overall_ribbon_font {get; set;}
  public String tcr_national_ribbon_font {get; set;}
  public String tcr_regional_ribbon_font {get; set;}
  public String callback_national_ribbon_font {get; set;}
  public String callback_regional_ribbon_font {get; set;}
  public String rainmaker_national_ribbon_font {get; set;}
  public String rainmaker_regional_ribbon_font {get; set;}
  public String learning_national_ribbon_font {get; set;}
  public String learning_regional_ribbon_font {get; set;}
  public String financial_national_ribbon {get; set;}
  public String financial_regional_ribbon {get; set;}
  public String financial_national_ribbon_font {get; set;}
  public String financial_regional_ribbon_font {get; set;}


  public PEC_Ranking_Snapshot__c user_rank {get;set;}
  public boolean display_ribbons {get; set;}



  //:Userinfo.getUserId()
  public List<SelectOption> getCAPEClist() {
    List<SelectOption> options = new List<SelectOption>();
    Set<ID> all_market_centers = new Set<ID>();
    if(this_user.Center_PEC__c!=null) {
        Center_Information__c sm = [select sales_market__c from Center_Information__c where id = :this_user.center_pec__c];
        for(Center_Information__c ci : [select id from Center_Information__c where sales_market__c = :sm.sales_market__c]) {
                all_market_centers.add(ci.id);
        }
    }
    //list<Center_Information__C> centers = [Select c.PEC_1__c,c.PEC_2__c From Center_Information__c c];
    //list<User> pec_users = [select id,name,center_pec__c from user where center_pec__c = :this_user.center_pec__c and center_administrator__c = false order by name];
    //2014-04-07 with the new changes,  CA's don't exist in quite the same role anymore.  I'm pulling the filter that excluded them,  so someone in a ca role can pull their own dashboard up.
    //and center_administrator__c = false
    list<User> pec_users = [select id,name,center_pec__c from user where center_pec__c in :all_market_centers order by name];
    for(User my_user : pec_users) {
      options.add(new SelectOption(my_user.id,my_user.name));
    }
    return options;
  }

  public List<SelectOption> getRegionList() {
        Schema.DescribeFieldResult RegionList = Center_information__c.Sales_Region__c.getDescribe();
                List<Schema.PicklistEntry> RegionPickVals = RegionList.getPicklistValues();
    List<SelectOption> options = new List<SelectOption>();
                for(Schema.PicklistEntry Value : RegionPickVals ) {
                        options.add(new SelectOption(Value.getValue(),Value.getLabel()));
                }
                return options;
  }

  public List<SelectOption> getCACenterlist() {
    List<SelectOption> options = new List<SelectOption>();
    Center_Information__c sm = new Center_Information__c();
    if(this_user.Center_PEC__c!=null)
      sm = [select sales_market__c from Center_Information__c where id = :this_user.center_pec__c];
    else
      return null;
    //list<Center_Information__C> centers = [Select c.id,c.name From Center_Information__c c order by c.name];
    for(Center_Information__c center : [select id,name from Center_Information__c where sales_market__c = :sm.sales_market__c]) {
      options.add(new SelectOption(center.id,center.name));
    }
    return options;
  }

  public void display_prom_payments() {
        anticipated_filter = 'prom';
        anticipated_payments = null;
        getAnticipatedPayments();
  }

  public void display_all_payments() {
        anticipated_filter = 'all';
        anticipated_payments = null;
        getAnticipatedPayments();
  }

  public List<SelectOption> getPEClist() {
        /*This method is pulling alist of PECs by searching for the id's tied to the pec_1 and pec_2 field
          in the center information table.  Not the best way to handle it given we have traveling PECs.  I'll
          likely add a field to the user table at some point to track PEC assignment at some point and switch
          this to pull from there       */
    List<SelectOption> options = new List<SelectOption>();
    Map<ID,String> user_name = new Map<ID,String> ();
    list<User> all_users = [select id,name from user];
    for(User my_user : all_users) {
      user_name.put(my_user.id,my_user.name);
    }
    //list<Center_Information__C> centers = [Select c.PEC_1__c,c.PEC_2__c From Center_Information__c c];
    list<User> pec_users = [select id,name,center_pec__c from user where center_pec__c <> ''  order by name];
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
    //list<Center_Information__C> centers = [Select c.id,c.name From Center_Information__c c order by c.name];
    for(Center_Information__c center : all_centers) {
      options.add(new SelectOption(center.id,center.name));
    }
    return options;
  }

  public Pagereference set_centergoals() {
        Pagereference pr = Page.center_goals;
        pr.setredirect(true);
        return pr;
  }

  public Pagereference ops_daterange() {
        Pagereference pr = Page.OpsDashboard_range;
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

  public String getranking_url() {
        Pagereference pr = Page.pec_ranking_display;
        return pr.geturl();
  }

  public Pagereference view_aregion() {
    Pagereference pr = Page.OpsDashboard_Development;
    pr.getParameters().put('action','region');
    pr.getParameters().put('aregion',display_region);
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
          pr.getParameters().put('tfilter','1');
    pr.setredirect(true);
    return pr;
  }

  public Pagereference view_auser() {
    Pagereference pr = Page.OpsDashboard_Development;
    pr.getParameters().put('action','user');
    pr.getParameters().put('asuser',display_pec);
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
          pr.getParameters().put('tfilter','1');
    pr.setredirect(true);
    return pr;
  }

  public Pagereference view_acenter() {
    Pagereference pr = Page.OpsDashboard_Development;
    pr.getParameters().put('action','center');
    pr.getParameters().put('ascenter',display_center);
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
          pr.getParameters().put('tfilter','1');
    pr.setredirect(true);
    return pr;
  }

  public Pagereference display_center() {
    Pagereference pr = Page.OpsDashboard_Development;
    pr.getParameters().put('action','center');
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
          pr.getParameters().put('tfilter','1');
    pr.setredirect(true);
    return pr;
  }

  public Pagereference display_all() {
    Pagereference pr = Page.OpsDashboard_Development;
    pr.getParameters().put('action','all');
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
          pr.getParameters().put('tfilter','1');
    pr.setredirect(true);
    return pr;
  }

  public Pagereference display_user() {
    Pagereference pr = Page.OpsDashboard_Development;
    pr.getParameters().put('action','user');
    if(Apexpages.currentPage().getParameters().get('tfilter')!=null)
          pr.getParameters().put('tfilter','1');
    pr.setredirect(true);
    return pr;
  }

  //should toggle to displaying today's data instead of yesterday
  public Pagereference display_today() {
        Pagereference pr = Page.OpsDashboard_Development;
        pr.getParameters().put('tfilter','1');
        if(Apexpages.currentPage().getParameters().get('action')!=null)
          pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('action'));
        if(Apexpages.currentPage().getParameters().get('asuser')!=null)
          pr.getParameters().put('asuser',Apexpages.currentPage().getParameters().get('asuser'));
        if(Apexpages.currentPage().getParameters().get('ascenter')!=null)
          pr.getParameters().put('ascenter',Apexpages.currentPage().getParameters().get('ascenter'));
        if(Apexpages.currentPage().getParameters().get('aregion')!=null)
          pr.getParameters().put('aregion',Apexpages.currentPage().getParameters().get('aregion'));
    pr.setredirect(true);
        return pr;
  }

  public Pagereference display_yesterday() {
        Pagereference pr = Page.OpsDashboard_Development;
        if(Apexpages.currentPage().getParameters().get('action')!=null)
          pr.getParameters().put('action',Apexpages.currentPage().getParameters().get('action'));
        if(Apexpages.currentPage().getParameters().get('asuser')!=null)
          pr.getParameters().put('asuser',Apexpages.currentPage().getParameters().get('asuser'));
        if(Apexpages.currentPage().getParameters().get('ascenter')!=null)
          pr.getParameters().put('ascenter',Apexpages.currentPage().getParameters().get('ascenter'));
        if(Apexpages.currentPage().getParameters().get('aregion')!=null)
          pr.getParameters().put('aregion',Apexpages.currentPage().getParameters().get('aregion'));
    pr.setredirect(true);
        return pr;
  }

  public String get_ribbon_type(Decimal my_rank, Integer total_ranks) {
        if(my_rank==null || total_ranks==null)
          return 'large_ribbon_150_red.png';
        else if(my_rank/total_ranks <= .250)
          return 'large_ribbon_150_blue.png';
        else if(my_rank/total_ranks <= .50)
          return 'large_ribbon_150_green.png';
        else if(my_rank/total_ranks <= .75)
          return 'large_ribbon_150_yellow.png';
        else
          return 'large_ribbon_150_red.png';
  }

  public String get_ribbon_font(Decimal my_rank, Integer total_ranks) {
        if(my_rank==null || total_ranks         ==null)
          return 'ribbon_rank_large_dark';
        else if(my_rank/total_ranks <= .250)
          return 'ribbon_rank_large';
        else if(my_rank/total_ranks <= .50)
          return 'ribbon_rank_large_dark';
        else if(my_rank/total_ranks <= .75)
          return 'ribbon_rank_large_dark';
        else
          return 'ribbon_rank_large';
  }

  public void display_exception_section() {
        display_exception = true;
  }

  public ctrl_OpsDashboard_Development() {
    display_ribbons = false;
    report_mapping = new Map<String,Id>();
    anticipated_filter = 'all';
    display_dashboard = true;
    display_hygiene = false;
    display_exception = false;
    payout_collections = 0.00;
    payout_close = 0.00;
    for(Report r : [select id,name,developername from report where developername in ('Payment_Arrangements_Made_Past_Due','Payments_To_Update','New_Unconverted_Consults','Unconverted_Consults','Consults_w_Fields_to_Update','Pes_to_Update_Dashboard','Prosth_Exams_with_No_Payments')]) {
      report_mapping.put(r.developername,r.id);
    }
        all_centers = [Select c.id,c.name,c.PEC_1__c,c.PEC_2__c,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,Baseline_Target__c, Baseline_Target_CPC__c From Center_Information__c c where type__c not in ('Network Center') order by c.name];
        all_centers_map = new Map<Id,Center_Information__c>();
        for(Center_Information__c ci : all_centers) {
          all_centers_map.put(ci.id,ci);
        }
        if(test.isRunningTest())
            all_filter = ' LIMIT 10';
        if(Apexpages.currentPage()<>null) {
            if(ApexPages.currentPage().getHeaders()==null)
              hyper_prefix = '';
            else
              hyper_prefix = 'https://'+ApexPages.currentPage().getHeaders().get('Host');
            if(Apexpages.currentPage().getParameters().get('tfilter')==null)
                yesterday_filter = ' yesterday ';
            else
                yesterday_filter = ' today ';
            // Alon - Ideally, we would completely remove yesterday_filter from this controller in place of the newer ranges map solution for handling date ranges, but that would require many changes to the existing code.
            // For now, both solutions will live in harmony, requiring the line below to keep the map updated when the Today filter is applied.
            ranges.put('previous_day', yesterday_filter);
            if(apexpages.currentpage().getparameters().get('action')==null)
              action = 'user';
            else
              action = apexpages.currentpage().getparameters().get('action');
            List<Center_Information__c> center_info = new list<Center_Information__c> ();
            if(apexpages.currentpage().getparameters().get('ascenter')==null) {
                User this_u = [select id,center_pec__c from user where id = :Userinfo.getUserId()];
                for(Center_Information__c center : all_centers) {
                        if(center.id==this_u.Center_PEC__c)
                                center_info.add(center);
                }
                //center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where id = :this_u.center_pec__c];
              //center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where PEC_1__c = :Userinfo.getUserId() or PEC_2__c = :Userinfo.getUserId()];
            }
            else {
                for(Center_Information__c center : all_centers) {
                        if(center.id==apexpages.currentpage().getparameters().get('ascenter'))
                                center_info.add(center);
                }
              //center_info = [select id,name,PEC_1__c,PEC_2__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ascenter')];
            }
            if(action=='user') {
                download_string = '&action=user';
                display_user_button = false;
                if(center_info.size()>0)
                  display_center_button = true;
              ID rank_match = null;
              if(apexpages.currentpage().getparameters().get('asuser')==null) {
                            report_header = Userinfo.getName();
                            user_filters.add(Userinfo.getUserID());
                            rank_match = userinfo.getUserID();
                            download_string += '&asuser=' + Userinfo.getUserID();
                    }
                    else {
                        User view_user = [select id,name from user where id = :apexpages.currentpage().getparameters().get('asuser')];
                        rank_match = view_user.id;
                        report_header = view_user.name;
                        user_filters.add(apexpages.currentpage().getparameters().get('asuser'));
                        download_string += '&asuser=' + apexpages.currentpage().getparameters().get('asuser');
                    }
              //grab sales rankings
              List<PEC_Ranking_Snapshot__c> prs_list = [Select p.User__c, p.True_Close_Rate__c, p.True_Close_Rate_Regional_Rank__c, p.True_Close_Rate_National_Rank__c, p.Total_National_Rank__c, p.SystemModstamp, p.Starts__c, p.Snapshot_Date__c, p.Sales_Region__c, p.Rainmaker_Regional_Rank__c, p.Rainmaker_National_Rank__c, p.OwnerId, p.National_Overall_Rank__c, p.Name, p.Learning_Activity_Regional_Rank__c, p.Learning_Activity_Num__c, p.Learning_Activity_National_Rank__c, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Consults__c, p.Cancels_out__c, p.Cancels_In__c, p.Callbacks_Num__c, p.Callback_Regional_Rank__c, p.Callback_National_Rank__c, p.Avg_Rainmaker_Score__c, p.avg_financial_needs_score__c,p.financial_needs_national_rank__c,p.financial_needs_regional_rank__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = yesterday];
              Integer total_ranks = prs_list.size();
              Integer region_ranks = 0;
              for(PEC_Ranking_Snapshot__c pr : prs_list) {
                if(pr.user__c==rank_match) {
                  display_ribbons = true;
                  user_rank = pr;
                }
              }
              //if we have a rank,  we need to figure out the region divisor - pass through again
              if(display_ribbons) {
                for(PEC_Ranking_Snapshot__c pr : prs_list) {
                  if(pr.sales_region__c==user_rank.sales_region__c && pr.True_Close_Rate_Regional_Rank__c > region_ranks)
                    region_ranks = pr.True_Close_Rate_Regional_Rank__c.intvalue();
                }
                //now determine which ribbon to use for each stat
                national_overall_ribbon = get_ribbon_type(user_rank.national_overall_rank__c,total_ranks);
                national_overall_ribbon_font = get_ribbon_font(user_rank.national_overall_rank__c,total_ranks);
                                tcr_national_ribbon = get_ribbon_type(user_rank.true_close_rate_national_rank__c,total_ranks);
                                tcr_regional_ribbon = get_ribbon_type(user_rank.true_close_rate_regional_rank__c,region_ranks);
                                tcr_national_ribbon_font = get_ribbon_font(user_rank.true_close_rate_national_rank__c,total_ranks);
                                tcr_regional_ribbon_font = get_ribbon_font(user_rank.true_close_rate_regional_rank__c,region_ranks);
                                callback_national_ribbon = get_ribbon_type(user_rank.callback_national_rank__c,total_ranks);
                                callback_regional_ribbon = get_ribbon_type(user_rank.callback_regional_rank__c,region_ranks);
                                callback_national_ribbon_font = get_ribbon_font(user_rank.callback_national_rank__c,total_ranks);
                                callback_regional_ribbon_font = get_ribbon_font(user_rank.callback_regional_rank__c,region_ranks);
                                rainmaker_national_ribbon = get_ribbon_type(user_rank.rainmaker_national_rank__c,total_ranks);
                                rainmaker_regional_ribbon = get_ribbon_type(user_rank.rainmaker_regional_rank__c,region_ranks);
                                rainmaker_national_ribbon_font = get_ribbon_font(user_rank.rainmaker_national_rank__c,total_ranks);
                                rainmaker_regional_ribbon_font = get_ribbon_font(user_rank.rainmaker_regional_rank__c,region_ranks);
                                learning_national_ribbon = get_ribbon_type(user_rank.learning_activity_national_rank__c,total_ranks);
                                learning_regional_ribbon = get_ribbon_type(user_rank.learning_activity_regional_rank__c,region_ranks);
                                learning_national_ribbon_font = get_ribbon_font(user_rank.learning_activity_national_rank__c,total_ranks);
                                learning_regional_ribbon_font = get_ribbon_font(user_rank.learning_activity_regional_rank__c,region_ranks);
                                financial_national_ribbon = get_ribbon_type(user_rank.financial_needs_national_rank__c,total_ranks);
                                financial_regional_ribbon = get_ribbon_type(user_rank.financial_needs_regional_rank__c,region_ranks);
                                financial_national_ribbon_font = get_ribbon_font(user_rank.financial_needs_national_rank__c,total_ranks);
                                financial_regional_ribbon_font = get_ribbon_font(user_rank.financial_needs_regional_rank__c,region_ranks);
              }

            }
            if(action=='center') {
                download_string = '&action=center';
              //user filters was a nice option,  but I need to move to a center field as this doesn't work well
              //when people get reassigned or we have travelling PECs
              Integer cnt = 0;
              for(Center_Information__c ci : center_info) {
                if(cnt==0) {
                        download_string += '&ascenter=' + ci.id;
                  //make a list for account_id_list - this will be used as a filter on some of the metrics queries
                  /*for(Account a : [select id from account where center__c = :ci.id]) {
                        account_id_list.add(a.id);
                  }*/
                  center_id = ci.id;
                }
                cnt++;
                List<User> center_pec = [select id from user where center_pec__c = :ci.id];
                for(User my_user : center_pec) {
                        user_filters.add(my_user.id);
                }
                report_header = ci.Name;
                /*if(ci.PEC_1__c != null)
                  user_filters.add(ci.PEC_1__c);
                if(ci.PEC_2__c != null)
                  user_filters.add(ci.PEC_2__c);
                report_header = ci.Name;*/
              }

              display_user_button = true;
              display_center_button = false;
            }
            if(action=='region') {
                download_string = '&action=region';
              Integer cnt = 0;
              download_string += '&aregion=' + apexpages.currentpage().getparameters().get('aregion');
              sales_region = apexpages.currentpage().getparameters().get('aregion');
              display_user_button = true;
              display_center_button = true;
              report_header = sales_region + ' Region';
            }
            Profile user_profile = [select id,name from profile where id = :Userinfo.getProfileId()];
            Set<String> admin_profiles = new Set<String> {'Data Audit Team','Practice Privileges - Sys Admin','System Administrator','RBD','New System Administrator','Limited System Administrator','PEC_MultipleCenters_VisiblePrescreen','Finance'};


            //Integer admin_count = [select count() from Profile where name in ('Data Audit Team','Practice Privileges - Sys Admin','System Administrator','RBD','New System Administrator','Limited System Administrator','PEC_MultipleCenters_VisiblePrescreen','Finance') and id = :Userinfo.getProfileId()];
            //if(admin_count>0) {
            if(admin_profiles.contains(user_profile.name)) {
              display_all_button = true;
              display_admin = true;
            }
            /*
            added by cm on 2015-08-25
            per Stephan,  the Practice Privileges team will have access to the dashboard,  and will only be blocked from seeing comission numbers.
            */
            Set<String> ppriv_profiles = new Set<String> {'Practice Privileges Admin','Practice Privileges Field Workers'};

            //Integer ppriv_count = [select count() from Profile where name in ('Practice Privileges Admin','Practice Privileges Field Workers') and id = :Userinfo.getProfileId()];
            //if(ppriv_count>0) {
            if(ppriv_profiles.contains(user_profile.name)) {
              display_ppriv = true;
              display_all_button = true;
              display_admin = true;
            }
            Set<String> user_exceptions = new Set<String> {'Bryce Burger','Dina Costantini','Anne Sawyer'};
            if(user_exceptions.contains(userinfo.getName()))
            //if(userinfo.getName()=='Bryce Burger' || userinfo.getName()=='Dina Costantini' || userinfo.getName()=='Anne Sawyer')
              display_admin = true;
            if(action=='all') {
                download_string = '&action=all';
                //this is here to make sure someone without the proper rights doesn't access this method by passing
                //the action=all parameter directly via URL.
                system.assert(display_all_button);
                report_header = 'All Center Info';
              display_user_button = true;
              if(center_info.size()>0)
                display_center_button = true;
              display_all_button = false;
            }
            if(user_profile.name=='SF - Clinical Doctor')
              display_ca = true;
            if(this_user.Center_Administrator__c==true)
              display_ca = true;
            if(yesterday_filter.trim()=='today')
              download_string += '&tfilter=2';
             else
              download_string += '&tfilter=1';
        }
        System.debug('Display PPriv : ' + display_ppriv);
        System.debug('Display Admin : ' + display_admin);
        calculate_bonus();
  }


  /*modified by cm on 2014-08-05
    QTR bonus calculation will now be entered as the full amount and not by a per month basis.  Adjusting the calculations below to handle this.  Tier 3 will be removed
    modified by cm on 2015-01-28
    This is the old method that is no longer being used starting in Feb 2015
  */
  /*public class pec_compensation {
        public Decimal tier_1_floor {get; set;}
        public Decimal tier_2_floor {get; set;}
        public Decimal tier_3_floor {get; set;}
        public Decimal tier_3_qtr_floor {get; set;}
        public Decimal tier_1_amount {get; set;}
        public Decimal tier_2_amount {get; set;}
        public Decimal tier_3_amount {get; set;}
        public Decimal tier_3_qtr_amount {get; set;}

        Decimal tier_1_rate = 0.01;
        Decimal tier_2_rate = 0.035;
        Decimal tier_3_rate = 0.035;
        Decimal tier_3_qtr_rate = 0.01;

        public pec_compensation(User u,Center_Information__c ci,Decimal Net_Collections, decimal qtr_collections) {
          try {
                  if(u.goal_type__c=='User') {
                        tier_1_floor = u.Tier_1_Floor__c;
                        tier_2_floor = u.tier_2_floor__c;
                        tier_3_floor = u.tier_3_floor__c;
                  }
                  else if(u.goal_type__c=='None' || u.goal_type__c==null) {
                        tier_1_floor = 0.00;
                        tier_2_floor = 0.00;
                        tier_3_floor = 0.00;
                  }
                  else {
                        tier_1_floor = ci.tier_1_floor__c;
                        tier_2_floor = ci.tier_2_floor__c;
                        tier_3_floor = ci.tier_3_floor__c;
                  }
                  tier_3_qtr_floor = tier_3_floor;
                  //tier_3_qtr_floor = tier_3_floor * 3;

          }
          catch(Exception e) {
                //most likely center or user floors are not set - default to 0
                tier_1_floor = 0.00;
                tier_2_floor = 0.00;
                tier_3_floor = 0.00;
                tier_3_qtr_floor = 0.00;
          }
          if(net_collections==null)
            net_collections = 0.00;
          //calculate tier 1 bonus
          System.debug('Tier 1 Floor ' + tier_1_floor);
          System.debug('Net Collections ' + net_collections);
          tier_1_amount = net_collections - tier_1_floor;
          if(tier_1_amount > (tier_2_floor - tier_1_floor))
            tier_1_amount = (tier_2_floor - tier_1_floor);
          if(tier_1_amount <= 0)
            tier_1_amount = 0;
          tier_1_amount = tier_1_amount * tier_1_rate;

          //calculate tier 2 bonus
          tier_2_amount = net_collections - tier_2_floor;
          //pulling this out - tier 3 is going away,  and will just be rolled into tier 2
          //if(tier_2_amount > (tier_3_floor - tier_2_floor))
            //tier_2_amount = (tier_3_floor - tier_2_floor);
          if(tier_2_amount <= 0)
            tier_2_amount = 0;
          tier_2_amount = tier_2_amount * tier_2_rate;

          //calculate tier 3 bonus
          //tier_3_amount = net_collections - tier_3_floor;
          //if(tier_3_amount <= 0)
            //tier_3_amount = 0;
          //tier_3_amount = tier_3_amount * tier_3_rate;

          //calculate QTR bonus
          //System.debug('Tier 3 QTR floor : ' + tier_3_qtr_floor + ' QTR Collections ' + qtr_collections);
          if(qtr_collections>tier_3_qtr_floor) {
            tier_3_qtr_amount = (qtr_collections - tier_3_qtr_floor) * tier_3_qtr_rate;
          }
          else
            tier_3_qtr_amount = 0;
        }
  }*/

  //add by cm on 2015-02-10 - New calculation for Feb 2015 on
  public class rsm_compensation {
        public Integer current_tier {get; set;}
        public Integer previous_tier {get; set;}
        public Integer next_tier {get; set;}
        public Decimal current_payout {get; set;}
        public Decimal previous_payout {get; set;}
        public Decimal next_payout {get; set;}
        public Decimal current_payout_amount {get; set;}
        public Decimal previous_payout_amount {get; set;}
        public Decimal next_payout_amount {get; set;}

        public rsm_compensation(Sales_Region__c sr ,decimal Net_Collections, decimal close_rate) {
          Decimal baseline_target;
          Map <Integer,Decimal> payout_map = new Map<Integer,Decimal>();
          payout_map.put(0,0.0000);
          payout_map.put(1,sr.tier_1_bonus_payout__c);
          payout_map.put(2,sr.tier_2_bonus_payout__c);
          payout_map.put(3,sr.tier_3_bonus_payout__c);
          payout_map.put(4,sr.tier_4_bonus_payout__c);
          payout_map.put(5,sr.tier_5_bonus_payout__c);
          payout_map.put(6,sr.tier_6_bonus_payout__c);
          payout_map.put(7,sr.tier_7_bonus_payout__c);
          payout_map.put(8,sr.tier_8_bonus_payout__c);
          payout_map.put(9,sr.tier_9_bonus_payout__c);

          try {
                if(sr.baseline_target__c==null)
                  baseline_target = 99.0;
                else
                  baseline_target = sr.baseline_target__c;
          }
          catch(Exception e) {
            baseline_target = 99.0;
          }
          //System.debug('Baseline Target : ' + baseline_target + ' Close Rate ' + close_rate);
          if(net_collections==null)
            net_collections = 0.00;
          if(close_rate==null)
            close_rate = 0.00;
          //work through tiers and see if they meet the criteria
          //tier 0 check
          if(close_rate < (baseline_target-3.0) ) {
                current_tier = 0;
                previous_tier = 0;
                next_tier = 1;
          }
          //tier 1 check
          else if(close_rate < (baseline_target-1.5)) {
                current_tier = 1;
                previous_tier = 0;
                next_tier = 2;
          }
          //tier 2 check
          else if(close_rate < (baseline_target)) {
                current_tier = 2;
                previous_tier = 1;
                next_tier = 3;
          }
          //tier 3 check
          else if(close_rate < (baseline_target+2)) {
                current_tier = 3;
                previous_tier = 2;
                next_tier = 4;
          }
          //tier 4 check
          else if(close_rate < (baseline_target+4)) {
                current_tier = 4;
                previous_tier = 3;
                next_tier = 5;
          }
          //tier 5 check
          else if(close_rate < (baseline_target+6)) {
                current_tier = 5;
                previous_tier = 4;
                next_tier = 6;
          }
          //tier 6 check
          else if(close_rate < (baseline_target+9)) {
                current_tier = 6;
                previous_tier = 5;
                next_tier = 7;
          }
          //tier 7 check
          else if(close_rate < (baseline_target+12)) {
                current_tier = 7;
                previous_tier = 6;
                next_tier = 8;
          }
          //tier 8 check
          else if(close_rate < (baseline_target+16)) {
                current_tier = 8;
                previous_tier = 7;
                next_tier = 9;
          }
          //tier 9 check
          else {
                current_tier = 9;
                previous_tier = 8;
                next_tier = 9;
          }
          current_payout = payout_map.get(current_tier);
          previous_payout = payout_map.get(previous_tier);
          next_payout = payout_map.get(next_tier);

          current_payout_amount = current_payout * net_collections;
          previous_payout_amount = previous_payout * net_collections;
          next_payout_amount = next_payout * net_collections;
       }

       public decimal get_current_payout_amount() {
         return current_payout_amount==null?0.00:current_payout_amount.setscale(2);
       }

       public decimal get_previous_payout_amount() {
         return previous_payout_amount==null?0.00:previous_payout_amount.setscale(2);
       }

       public decimal get_next_payout_amount() {
         return next_payout_amount==null?0.00:next_payout_amount.setscale(2);
       }
  }

    //modified by cm on 2015-01-28 - New calculation for Feb 2015 on
    public class pec_compensation {
        public Integer current_tier           {get; set;}
        public Integer previous_tier          {get; set;}
        public Integer next_tier              {get; set;}
        public Decimal current_payout         {get; set;}
        public Decimal previous_payout        {get; set;}
        public Decimal next_payout            {get; set;}
        public Decimal current_payout_amount  {get; set;}
        public Decimal previous_payout_amount {get; set;}
        public Decimal next_payout_amount     {get; set;}

        public Integer current_tier_cpc           {get; set;}
        public Integer previous_tier_cpc          {get; set;}
        public Integer next_tier_cpc              {get; set;}
        public Decimal current_payout_cpc         {get; set;}
        public Decimal previous_payout_cpc        {get; set;}
        public Decimal next_payout_cpc            {get; set;}
        public Decimal current_payout_amount_cpc  {get; set;}
        public Decimal previous_payout_amount_cpc {get; set;}
        public Decimal next_payout_amount_cpc     {get; set;}
        // public Decimal payout_modifier {get; set;}

        public pec_compensation(User u,Center_Information__c ci,decimal Net_Collections, decimal close_rate, Decimal cpc, decimal collections_threshold) {
            set_tcr_compensation_values(u, ci, Net_Collections, close_rate, collections_threshold);
            set_cpc_compensation_values(u, ci, Net_Collections, cpc);
        }

                private void set_tcr_compensation_values(User u,Center_Information__c ci,decimal Net_Collections, decimal close_rate, decimal collections_threshold) {
                    Decimal baseline_target;
                    Map <Integer,Decimal> payout_map = new Map<Integer,Decimal>{0  => 0.00000,
                                                                                1  => 0.00063,
                                                                                2  => 0.00125,
                                                                                3  => 0.00250,
                                                                                4  => 0.00500,
                                                                                5  => 0.00565,
                                                                                6  => 0.00635,
                                                                                7  => 0.00700,
                                                                                8  => 0.00770,
                                                                                9  => 0.00845,
                                                                                10 => 0.00915,
                                                                                11 => 0.01015,
                                                                                12 => 0.01125,
                                                                                13 => 0.01230,
                                                                                14 => 0.01340,
                                                                                15 => 0.01485,
                                                                                16 => 0.01625};

                    // 2017-03-23 Alon Waisman: Per Scott L, payout modifier is no longer in practice, so I'm taking it out
                    // if ((collections_threshold==null ? 0 : collections_threshold) == 0) {payout_modifier = 1.00;}
                    // else if (collections_threshold > net_collections)                   {payout_modifier = 0.80;}
                    // else                                                                {payout_modifier = 1.00;}
                    // else                                                                {payout_modifier = 1.10;}

                    try {
                        if      (u.goal_type__c == null || u.goal_type__c == 'None')   {baseline_target = 99.0;}
                        else if (u.goal_type__c == 'User') {baseline_target = u.baseline_target__c == null ? 0.00 : u.baseline_target__c;}
                        else                               {baseline_target = ci.baseline_target__c;}
                        if (baseline_target == null)       {baseline_target = 99999;}
                    }
                    catch(Exception e) {baseline_target = 99.0;}

                    System.debug('Baseline Target (TCR): ' + baseline_target + ' Close Rate ' + close_rate);
                    if (net_collections == null) {net_collections = 0.00;}
                    if (close_rate == null)      {close_rate = 0.00;}

                    // Determine appropriate tier from 0 - 16. Fourth tier is standard, add or subtract from there.
                    if      (close_rate < (baseline_target - 4.5))  {current_tier = 0;}
                    else if (close_rate < (baseline_target - 3.0))  {current_tier = 1;}
                    else if (close_rate < (baseline_target - 1.50)) {current_tier = 2;}
                    else if (close_rate < (baseline_target))        {current_tier = 3;}
                    else if (close_rate < (baseline_target + 1))    {current_tier = 4;}
                    else if (close_rate < (baseline_target + 2))    {current_tier = 5;}
                    else if (close_rate < (baseline_target + 3))    {current_tier = 6;}
                    else if (close_rate < (baseline_target + 4))    {current_tier = 7;}
                    else if (close_rate < (baseline_target + 5))    {current_tier = 8;}
                    else if (close_rate < (baseline_target + 6))    {current_tier = 9;}
                    else if (close_rate < (baseline_target + 7.5))  {current_tier = 10;}
                    else if (close_rate < (baseline_target + 9))    {current_tier = 11;}
                    else if (close_rate < (baseline_target + 10.5)) {current_tier = 12;}
                    else if (close_rate < (baseline_target + 12))   {current_tier = 13;}
                    else if (close_rate < (baseline_target + 14))   {current_tier = 14;}
                    else if (close_rate < (baseline_target + 16))   {current_tier = 15;}
                    else                                            {current_tier = 16;}

                    // Define previous and next tiers based on current_tier
                    previous_tier = Math.max(current_tier - 1, 0);
                    next_tier     = Math.min(current_tier + 1, 16);

                    // Use tier to identify the payout
                    current_payout  = payout_map.get(current_tier);
                    previous_payout = payout_map.get(previous_tier);
                    next_payout     = payout_map.get(next_tier);

                    // Calculate final TCR payout amount as a percentage (x_payout) of net collections
                    current_payout_amount  = current_payout  * net_collections;
                    previous_payout_amount = previous_payout * net_collections;
                    next_payout_amount     = next_payout     * net_collections;
                }

                private void set_cpc_compensation_values(User u, Center_Information__c ci, decimal Net_Collections, decimal cpc) {
                    Decimal baseline_target;
                    Map <Integer,Decimal> payout_map = new Map<Integer,Decimal>{0  => 0.00000,
                                                                                1  => 0.00063,
                                                                                2  => 0.00125,
                                                                                3  => 0.00250,
                                                                                4  => 0.00500,
                                                                                5  => 0.00567,
                                                                                6  => 0.00634,
                                                                                7  => 0.00701,
                                                                                8  => 0.00768,
                                                                                9  => 0.00880,
                                                                                10 => 0.00992,
                                                                                11 => 0.01104,
                                                                                12 => 0.01215,
                                                                                13 => 0.01372,
                                                                                14 => 0.01528,
                                                                                15 => 0.01729,
                                                                                16 => 0.01931,
                                                                                17 => 0.02154,
                                                                                18 => 0.02400};

                    try {
                        if      (u.goal_type__c == null || u.goal_type__c == 'None')  {baseline_target = 99999;}
                        else if (u.goal_type__c == 'User') {baseline_target = u.Baseline_Target_CPC__c;}
                        else                               {baseline_target = ci.Baseline_Target_CPC__c;}
                        if (baseline_target == null)       {baseline_target = 99999;}
                    }
                    catch(Exception e) {baseline_target = 99999;}

                    System.debug('Baseline Target (TCR): ' + baseline_target + ' Close Rate ' + cpc);
                    if (net_collections == null) {net_collections = 0.00;}
                    if (cpc == null)             {cpc = 0.00;}

                    // Determine appropriate tier from 0 - 16. Fourth tier is standard, add or subtract from there.
                    if      (cpc < (baseline_target - 2100))    {current_tier_cpc = 0;}
                    else if (cpc < (baseline_target - 1300))    {current_tier_cpc = 1;}
                    else if (cpc < (baseline_target - 530))     {current_tier_cpc = 2;}
                    else if (cpc < (baseline_target))           {current_tier_cpc = 3;}
                    else if (cpc < (baseline_target + 400))     {current_tier_cpc = 4;}
                    else if (cpc < (baseline_target + 800))     {current_tier_cpc = 5;}
                    else if (cpc < (baseline_target + 1200))    {current_tier_cpc = 6;}
                    else if (cpc < (baseline_target + 1600))    {current_tier_cpc = 7;}
                    else if (cpc < (baseline_target + 2200))    {current_tier_cpc = 8;}
                    else if (cpc < (baseline_target + 2800))    {current_tier_cpc = 9;}
                    else if (cpc < (baseline_target + 3400))    {current_tier_cpc = 10;}
                    else if (cpc < (baseline_target + 4000))    {current_tier_cpc = 11;}
                    else if (cpc < (baseline_target + 4800))    {current_tier_cpc = 12;}
                    else if (cpc < (baseline_target + 5600))    {current_tier_cpc = 13;}
                    else if (cpc < (baseline_target + 6700))    {current_tier_cpc = 14;}
                    else if (cpc < (baseline_target + 7800))    {current_tier_cpc = 15;}
                    else if (cpc < (baseline_target + 9000))    {current_tier_cpc = 16;}
                    else if (cpc < (baseline_target + 10300))   {current_tier_cpc = 17;}
                    else                                        {current_tier_cpc = 18;}

                    // Define previous and next tiers based on current_tier
                    previous_tier_cpc = Math.max(current_tier_cpc - 1, 0);
                    next_tier_cpc     = Math.min(current_tier_cpc + 1, 18);

                    // Use tier to identify the payout
                    current_payout_cpc  = payout_map.get(current_tier_cpc);
                    previous_payout_cpc = payout_map.get(previous_tier_cpc);
                    next_payout_cpc     = payout_map.get(next_tier_cpc);

                    // Calculate final TCR payout amount as a percentage (x_payout) of net collections
                    current_payout_amount_cpc  = current_payout_cpc  * net_collections;
                    previous_payout_amount_cpc = previous_payout_cpc * net_collections;
                    next_payout_amount_cpc     = next_payout_cpc     * net_collections;
                }

       public decimal get_current_payout_amount() {
         return current_payout_amount==null?0.00:current_payout_amount.setscale(2);
       }

       public decimal get_previous_payout_amount() {
         return previous_payout_amount==null?0.00:previous_payout_amount.setscale(2);
       }

       public decimal get_next_payout_amount() {
         return next_payout_amount==null?0.00:next_payout_amount.setscale(2);
       }
  }










  //modified by cm on 2015-01-28
  //Old version of the bonus calculation that is no longer used going forward
  /*public void calculate_bonus() {
    if(action=='all' || action=='center' || action=='region') {
      //not enabled at this point - I'd have to figure out the compensation value for every pec which would require their net collections info as well.
      //I'm not sure I can stuff all of that in to the page right now due to the Salesforce limits.  Will review this down the road
      bonus_1_floor = 0.00;
      bonus_2_floor = 0.00;
      bonus_3_floor = 0.00;
      bonus_3_qtr_floor = 0.00;
      bonus_1_amount = 0.00;
      bonus_2_amount = 0.00;
      bonus_3_amount = 0.00;
      bonus_3_qtr_amount = 0.00;
      bonus_all_amount = 0.00;
    }
    else if(action=='user') {
          //calculate the numbers for this pec
          User u = [select goal_type__c, tier_1_floor__c, tier_2_floor__c, tier_3_floor__c, center_pec__c,baseline_target__c from user where id in :user_filters];
          Center_Information__c ci;
          if(all_centers_map.containskey(u.center_pec__c))
            ci = all_centers_map.get(u.center_pec__c);
          else
            ci = new Center_Information__c(tier_1_floor__c = 0, tier_2_floor__c = 0, tier_3_floor__c = 0);
          DisplayDollars refunded = getRefunded();
          DisplayDollars collected = getCollected();
          Decimal net_collections = collected.mtd + gp_collected_fees.mtd + refunded.mtd + gp_refunded_fees.mtd;
          Decimal qtr_collections = collected.qtd + gp_collected_fees.qtd + refunded.qtd + gp_refunded_fees.mtd;
         // System.debug('QTR Collected ' + collected.qtd + ' Refunded : ' + refunded.qtd + ' Net : ' + qtr_collections);
          pec_compensation bonus_calc = new pec_compensation(u,ci,net_collections,qtr_collections);
          bonus_1_floor = bonus_calc.tier_1_floor.setscale(2);
          bonus_2_floor = bonus_calc.tier_2_floor.setscale(2);
          //bonus_3_floor = bonus_calc.tier_3_floor.setscale(2);
          bonus_3_qtr_floor = bonus_calc.tier_3_qtr_floor.setscale(2);
          bonus_1_amount = bonus_calc.tier_1_amount.setscale(2);
          bonus_2_amount = bonus_calc.tier_2_amount.setscale(2);
          //bonus_3_amount = bonus_calc.tier_3_amount.setscale(2);
          bonus_3_qtr_amount = bonus_calc.tier_3_qtr_amount.setscale(2);
          //bonus_all_amount = bonus_calc.tier_3_qtr_amount.setscale(2) + bonus_calc.tier_3_amount.setscale(2) + bonus_calc.tier_2_amount.setscale(2) + bonus_calc.tier_1_amount.setscale(2);
          bonus_all_amount = bonus_calc.tier_3_qtr_amount.setscale(2) + bonus_calc.tier_2_amount.setscale(2) + bonus_calc.tier_1_amount.setscale(2);
    }
  }*/

  public boolean getdisplay_region_compensation() {
        Integer region_count = [select count() from Sales_Region__c where name = :sales_region and (rsm__c = :Userinfo.getuserid() or rbd__c = :userinfo.getuserid())];
        if(region_count>0)
          return true;
        else
          return false;
  }

  public rsm_compensation getcalculated_rsm_payout_amount() {
        Sales_Region__c sr = [Select  s.Tier_9_Bonus_Payout__c, s.Tier_8_Bonus_Payout__c, s.Tier_7_Bonus_Payout__c, s.Tier_6_Bonus_Payout__c, s.Tier_5_Bonus_Payout__c, s.Tier_4_Bonus_Payout__c, s.Tier_3_Bonus_Payout__c, s.Tier_2_Bonus_Payout__c, s.Tier_1_Bonus_Payout__c, s.Baseline_Target__c From Sales_Region__c s where s.name = :sales_region];
    rsm_compensation quick_bonus_calc = new rsm_compensation(sr,payout_collections,payout_close);
    return quick_bonus_calc;
  }

  public pec_compensation getcalculated_payout_amount() {
    User u = [select goal_type__c, tier_1_floor__c, tier_2_floor__c, tier_3_floor__c, center_pec__c,baseline_target__c, Baseline_Target_CPC__c, collections_threshold__c from user where id in :user_filters];
    collections_limit = u.collections_threshold__c;
    Center_Information__c ci;
    if(all_centers_map.containskey(u.center_pec__c))
      ci = all_centers_map.get(u.center_pec__c);
    else
      ci = new Center_Information__c(tier_1_floor__c = 0, tier_2_floor__c = 0, tier_3_floor__c = 0);
    pec_compensation quick_bonus_calc = new pec_compensation(u, ci, payout_collections, payout_close, payout_cpc, u.collections_threshold__c);
    return quick_bonus_calc;
  }

   public void calculate_bonus() {
    if(action=='all' || action=='center') {
      //not enabled at this point - I'd have to figure out the compensation value for every pec which would require their net collections info as well.
      //I'm not sure I can stuff all of that in to the page right now due to the Salesforce limits.  Will review this down the road
      //don't need this - not displaying it anyways.
      /*current_tier = 1;
      previous_tier = 1;
      next_tier = 1;
      current_payout = 0.00;
      next_payout = 0.00;
      previous_payout = 0.00;
      current_payout_amount = 0.00;
      previous_payout_amount = 0.00;
      next_payout_amount = 0.00;*/
    }
    else if(action=='region') {
      Sales_Region__c sr;
      try {
        sr = [Select s.Tier_9_Bonus_Payout__c, s.Tier_8_Bonus_Payout__c, s.Tier_7_Bonus_Payout__c, s.Tier_6_Bonus_Payout__c, s.Tier_5_Bonus_Payout__c, s.Tier_4_Bonus_Payout__c, s.Tier_3_Bonus_Payout__c, s.Tier_2_Bonus_Payout__c, s.Tier_1_Bonus_Payout__c, s.Baseline_Target__c From Sales_Region__c s where s.name = :sales_region];
      }
      catch (Exception e) {
        sr = new Sales_Region__c(Tier_9_Bonus_Payout__c = 0,Tier_8_Bonus_Payout__c = 0, Tier_7_Bonus_Payout__c = 0, Tier_6_Bonus_Payout__c = 0, Tier_5_Bonus_Payout__c = 0, Tier_4_Bonus_Payout__c = 0, Tier_3_Bonus_Payout__c = 0, Tier_2_Bonus_Payout__c = 0, Tier_1_Bonus_Payout__c = 0, Baseline_Target__c = 0.0, name = sales_region);
      }
      DisplayDollars refunded = getRefunded();
      DisplayDollars collected = getCollected();
      DisplayDecimal mystarts = getStarts();
      DisplayMetrics myconsults = getConsultStarts();
      DisplayDecimal mycancels = getStartsCancelled();

      Decimal net_collections = collected.mtd + gp_collected_fees.mtd + refunded.mtd + gp_refunded_fees.mtd;
      payout_collections = net_collections;

      Decimal true_close_rate = 0.00;
      //don't divide by zero
      System.debug('mystarts.MTD ' + mystarts.MTD + ' Cancels ' + mycancels.MTD + ' Consults ' + myconsults.MTD);
      if(myconsults.MTD > 0) {
        true_close_rate = mystarts.MTD + mycancels.MTD;
        /*turning off rounding mode per Dan M - 5/11/2015*/
        //true_close_rate = true_close_rate.divide(myconsults.MTD,4, System.roundingmode.DOWN) * 100.00;
        true_close_rate = true_close_rate.divide(myconsults.MTD,3) * 100.00;
      }
      payout_close = true_close_rate;

      System.debug('True Close Rate ' + true_close_rate);
      // System.debug('QTR Collected ' + collected.qtd + ' Refunded : ' + refunded.qtd + ' Net : ' + qtr_collections);
      rsm_bonus_calc = new rsm_compensation(sr,net_collections,true_close_rate);
    }
    else if(action=='user') {
      //calculate the numbers for this pec
      User u = [select goal_type__c, tier_1_floor__c, tier_2_floor__c, tier_3_floor__c, center_pec__c,baseline_target__c, Baseline_Target_CPC__c, collections_threshold__c from user where id in :user_filters];
      collections_limit = u.collections_threshold__c;
      Center_Information__c ci;
      if(all_centers_map.containskey(u.center_pec__c))
        ci = all_centers_map.get(u.center_pec__c);
      else
        ci = new Center_Information__c(tier_1_floor__c = 0, tier_2_floor__c = 0, tier_3_floor__c = 0);
      DisplayDollars refunded = getRefunded();
      DisplayDollars collected = getCollected();
      DisplayDecimal mystarts = getStarts();
      DisplayMetrics myconsults = getConsultStarts();
      DisplayDecimal mycancels = getStartsCancelled();

      Decimal net_collections = collected.mtd + gp_collected_fees.mtd + refunded.mtd + gp_refunded_fees.mtd;
      payout_collections = net_collections;

      // Determine True Close Rate
      Decimal true_close_rate = 0.00;
      //don't divide by zero
      System.debug('mystarts.MTD ' + mystarts.MTD + ' Cancels ' + mycancels.MTD + ' Consults ' + myconsults.MTD);
      if(myconsults.MTD > 0) {
        true_close_rate = mystarts.MTD + mycancels.MTD;
        /*turning off rounding mode per Dan M - 5/11/2015*/
        //true_close_rate = true_close_rate.divide(myconsults.MTD,4, System.roundingmode.DOWN) * 100.00;
        true_close_rate = true_close_rate.divide(myconsults.MTD,3) * 100.00;
      }
      payout_close = true_close_rate;

      // Determine Collection Per Consult
      Decimal collection_per_consult = 0;
      collection_per_consult = myconsults.MTD > 0 ? payout_collections.divide(myconsults.MTD,2) : 0;
      payout_cpc = collection_per_consult;

      System.debug('True Close Rate ' + true_close_rate);
      System.debug('Collection Per Consult ' + collection_per_consult);
      // System.debug('QTR Collected ' + collected.qtd + ' Refunded : ' + refunded.qtd + ' Net : ' + qtr_collections);
      bonus_calc = new pec_compensation(u, ci, net_collections, true_close_rate, collection_per_consult, u.collections_threshold__c);
      /*current_tier = pec_compensation.current_tier;
      next_tier = pec_compensation.next_tier;
      previous_tier = pec_compensation.previous_tier;
      current_payout = pec_compensation.current_payout;
      next_payout = pec_compensation.next_payout;
      previous_payout = pec_compensation.previous_payout;
      current_payout_amount = pec_compensation.get_current_payout_amount;*/
    }
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
          private DisplayDollars zeroed_DisplayDollars() {
              DisplayDollars display_dollars = new DisplayDollars();
              display_dollars.MTD = 0;
              display_dollars.previous_month = 0;
              display_dollars.YTD = 0;
              display_dollars.QTD = 0;
              display_dollars.previous_day = 0;
              return display_dollars;
          }

  DisplayDecimal sdstarts;
  DisplayDecimal starts;
  DisplayDecimal pendingstarts;
  DisplayDecimal starts_cancelled;
  DisplayDecimal starts_cancelled_in;
  DisplayDecimal starts_cancelled_out;
  DisplayMetrics consult_starts;
  DisplayMetrics callback_consult_starts;
  DisplayDollars collected;
  DisplayDollars gp_collected_fees;
  DisplayDollars gp_refunded_fees;
  DisplayDollars refunded;
  DisplayDollars private_refunded;
  DisplayDollars private_collected;
  DisplayDollars treatment_sold;
  DisplayDollars treatment_cancelled;
  DisplayDollars treatment_cancelled_in;
  DisplayDollars treatment_cancelled_out;
  DisplayDollars treatment_sold_valid;
  DisplayDollars treatment_cancelled_in_valid;
  DisplayDollars treatment_cancelled_out_valid;

  DisplayDollars pending_treatment_sold;

  DisplayDollars treatment_sold_valid_start_value_1;
  DisplayDollars treatment_cancelled_in_valid_start_value_1;
  DisplayDollars treatment_cancelled_out_valid_start_value_1;
  DisplayDollars treatment_sold_small;

  DisplayDollars anticipated_payments;
  DisplayMetrics financed_consults;
  DisplayMetrics pipeline;
  DisplayDollars sales_target;
  DisplayDollars pec_target;
  DisplayDollars upsell_sold;
  DisplayDollars upsell_cancelled_in;
  DisplayDollars upsell_cancelled_out;
  DisplayDecimal true_closerate;
  DisplayDollars ao4_avg;

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

  public DisplayDollars getPecTarget() {
    if(pec_target==null) {
      pec_target = new DisplayDollars();
      Integer current_year = date.today().year();
      Integer current_month = date.today().month();
      Integer current_day = date.today().day();
      if(action=='all') {
        //Month - just grab the budget sales goal amount for current fiscal year and month
        pec_target.MTD = 0;
        for(User_Goals__c month_budget : [select sales_goal__c from user_goals__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and user__r.isactive = true]) {
          pec_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        pec_target.YTD = 0;
        for(User_Goals__c year_budget : [select sales_goal__c,fiscal_month__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and user__r.isactive = true]) {
                if(year_budget.fiscal_month__c < current_month)
                  pec_target.YTD += year_budget.sales_goal__c;
                else {
                        pec_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from user_goals__c where fiscal_year__c = :current_year and user__r.isactive = true and fiscal_month__c in ' + query_filter);
        if(results.get('sales_goal')==null)
          pec_target.QTD = 0;
        else
          pec_target.QTD = (Decimal)results.get('sales_goal');
      }
      else if(action=='center') {
        //Month - just grab the budget sales goal amount for current fiscal year and month
        pec_target.MTD = 0;
        for(User_Goals__c month_budget : [select sales_goal__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and user__r.isactive = true and user__r.center_pec__c = :center_id]) {
          pec_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        pec_target.YTD = 0;
        for(User_Goals__c year_budget : [select sales_goal__c,fiscal_month__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and user__r.isactive = true and user__r.center_pec__c = :center_id]) {
                if(year_budget.fiscal_month__c < current_month)
                  pec_target.YTD += year_budget.sales_goal__c;
                else {
                        pec_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from User_Goals__c where fiscal_year__c = :current_year and user__r.isactive = true and fiscal_month__c in ' + query_filter + ' and user__r.center_pec__c = :center_id');
        if(results.get('sales_goal')==null)
          pec_target.QTD = 0;
        else
          pec_target.QTD = (Decimal)results.get('sales_goal');

      }
       else if(action=='region') {
        //Month - just grab the budget sales goal amount for current fiscal year and month
        pec_target.MTD = 0;
        for(User_Goals__c month_budget : [select sales_goal__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and user__r.isactive = true and user__r.region_pec__c = :sales_region]) {
          pec_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        pec_target.YTD = 0;
        for(User_Goals__c year_budget : [select sales_goal__c,fiscal_month__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and user__r.isactive = true and user__r.region_pec__c = :sales_region]) {
                if(year_budget.fiscal_month__c < current_month)
                  pec_target.YTD += year_budget.sales_goal__c;
                else {
                        pec_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter + ' and user__r.isactive = true and user__r.region_pec__c = :sales_region');
        if(results.get('sales_goal')==null)
          pec_target.QTD = 0;
        else
          pec_target.QTD = (Decimal)results.get('sales_goal');
      }
      else if(action=='user') {
        //Month - just grab the budget sales goal amount for current fiscal year and month
        pec_target.MTD = 0;
        for(User_Goals__c month_budget : [select sales_goal__c from user_goals__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and user__c in :user_filters]) {
          pec_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        pec_target.YTD = 0;
        for(User_Goals__c year_budget : [select sales_goal__c,fiscal_month__c from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and user__c in :user_filters]) {
                if(year_budget.fiscal_month__c < current_month)
                  pec_target.YTD += year_budget.sales_goal__c;
                else {
                        pec_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from User_Goals__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter + ' and user__c in :user_filters');
        if(results.get('sales_goal')==null)
          pec_target.QTD = 0;
        else
          pec_target.QTD = (Decimal)results.get('sales_goal');
      }
    }
    return pec_target;
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
        for(Center_Budget__c month_budget : [select sales_goal__c from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and
          center__r.type__c not in ('Affiliate','Network Center')]) {
          sales_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        sales_target.YTD = 0;
        for(Center_Budget__c year_budget : [select sales_goal__c,fiscal_month__c from Center_Budget__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month
          and center__r.type__c not in ('Affiliate','Network Center')]) {
                if(year_budget.fiscal_month__c < current_month)
                  sales_target.YTD += year_budget.sales_goal__c;
                else {
                        sales_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from center_budget__c where fiscal_year__c = :current_year and center__r.type__c not in (\'Affiliate\',\'Network Center\') and fiscal_month__c in ' + query_filter);
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
        for(Center_Budget__c month_budget : [select sales_goal__c from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and center__c = :center_id]) {
          sales_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        sales_target.YTD = 0;
        for(Center_Budget__c year_budget : [select sales_goal__c,fiscal_month__c from Center_Budget__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and center__c = :center_id]) {
                if(year_budget.fiscal_month__c < current_month)
                  sales_target.YTD += year_budget.sales_goal__c;
                else {
                        sales_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter + ' and center__c = :center_id');
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
       else if(action=='region') {
        //Month - just grab the budget sales goal amount for current fiscal year and month
        sales_target.MTD = 0;
        for(Center_Budget__c month_budget : [select sales_goal__c from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c = :current_month and center__r.sales_region__c = :sales_region]) {
          sales_target.MTD += month_budget.sales_goal__c;
        }
        //Year - need to grab the budget sales goal amounts for all completed months and then calculate how
        //much to assign for the current month based on number of days and the current day of the month
        sales_target.YTD = 0;
        for(Center_Budget__c year_budget : [select sales_goal__c,fiscal_month__c from Center_Budget__c where fiscal_year__c = :current_year and fiscal_month__c <= :current_month and center__r.sales_region__c = :sales_region]) {
                if(year_budget.fiscal_month__c < current_month)
                  sales_target.YTD += year_budget.sales_goal__c;
                else {
                        sales_target.YTD += (year_budget.sales_goal__c/date.daysInMonth(current_year,current_month) * date.today().day());
                }
        }
        //QTD - just grab the goals for the current year and all of the months that make up this quarter
        String query_filter = getquarter_filter(current_month);
        AggregateResult results = database.query('select sum(sales_goal__c) sales_goal from center_budget__c where fiscal_year__c = :current_year and fiscal_month__c in ' + query_filter + ' and center__r.sales_region__c = :sales_region');
        if(results.get('sales_goal')==null)
          sales_target.QTD = 0;
        else
          sales_target.QTD = (Decimal)results.get('sales_goal');
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
        /*for (AggregateResult results : [select sum(sales_goal__c) sales_goal from user where IsActive = true and id in : user_filters]) {
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
    }
    return sales_target;
  }

  public DisplayMetrics getFinancedConsults() {
    if(financed_consults==null)  {
      financed_consults = new DisplayMetrics();
      if(action_set.contains(action)) {
        financed_consults.MTD              = financed_consults_count('MTD');
        financed_consults.previous_month   = financed_consults_count('previous_month');
        financed_consults.YTD              = financed_consults_count('YTD');
        financed_consults.QTD              = financed_consults_count('QTD');
        financed_consults.previous_day     = financed_consults_count('previous_day');
      }
    }
    return financed_consults;
  }

    public DisplayMetrics getConsultStarts() {
        if(consult_starts == null) {
            consult_starts = new DisplayMetrics();
            callback_consult_starts = new DisplayMetrics();
            if(action_set.contains(action)) {
                Map<String, Integer> consult_counts;
                consult_counts = consults_starts_counts('MTD');
                consult_starts.MTD          = consult_counts.get('not_valid_callbacks');
                callback_consult_starts.MTD = consult_counts.get('valid_callbacks');

                consult_counts = consults_starts_counts('previous_month');
                consult_starts.previous_month          = consult_counts.get('not_valid_callbacks');
                callback_consult_starts.previous_month = consult_counts.get('valid_callbacks');

                consult_counts = (action == 'user') ? consults_starts_counts_userytd() : consults_starts_counts('YTD');
                consult_starts.YTD          = consult_counts.get('not_valid_callbacks');
                callback_consult_starts.YTD = consult_counts.get('valid_callbacks');

                consult_counts = consults_starts_counts('QTD');
                consult_starts.QTD          = consult_counts.get('not_valid_callbacks');
                callback_consult_starts.QTD = consult_counts.get('valid_callbacks');

                consult_counts = consults_starts_counts('previous_day');
                consult_starts.previous_day          = consult_counts.get('not_valid_callbacks');
                callback_consult_starts.previous_day = consult_counts.get('valid_callbacks');
            }
        }
        return consult_starts;
    }

    public DisplayMetrics getCallbackConsultStarts() {
        if(callback_consult_starts == null) {getConsultStarts();}
        return callback_consult_starts;
    }

          private Integer financed_consults_count(String range) {
              String base_query = 'select count() from account where financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\') and createddate = ' + ranges.get(range);
              return database.countQuery(base_query + financed_consults_action_filters().get(action));
          }

          private Map<String, String> financed_consults_action_filters() {
              return new Map<String, String>{'all'    => ' and center__r.type__c not in (\'Affiliate\',\'Network Center\')' + all_filter,
                                             'user'   => ' and ownerid in : user_filters',
                                             'center' => ' and center__c = :center_id',
                                             'region' => ' and center__r.sales_region__c = :sales_region'};
          }

          private Map<String, Integer> consults_starts_counts(String range) {
              Map<String, Integer> consult_counts = new Map<String, Integer>{'valid_callbacks' => 0, 'not_valid_callbacks' => 0};
              String base_query = 'SELECT isValidCallBack__c, COUNT(ID) consults FROM Consult_Inventory__c WHERE Active__c = true AND Arrival_Time__c != null AND Consult_Room__r.Room_Type__c != \'Practice\' AND Apt_Date__c = ' + ranges.get(range);
              String full_query = base_query + consults_action_filters().get(action) + ' GROUP BY isValidCallBack__c';
              if(action == 'all') {full_query += all_filter;}
              for (AggregateResult results: database.query(full_query)) {
                  if(results.get('consults') != null) {
                      if((Boolean)results.get('isValidCallBack__c'))       {consult_counts.put('valid_callbacks', consult_counts.get('valid_callbacks') + (Integer)results.get('consults'));}
                      else if(!(Boolean)results.get('isValidCallBack__c')) {consult_counts.put('not_valid_callbacks', consult_counts.get('not_valid_callbacks') + (Integer)results.get('consults'));}
                  }
              }
              return consult_counts;
          }

          private Map<String, String> consults_action_filters() {
              return new Map<String, String>{'all'    => ' and consult_room__r.center_information__r.type__c not in (\'Affiliate\',\'Network Center\')',
                                             'user'   => ' and consult_pec__c in :user_filters',
                                             'center' => ' and consult_room__r.center_information__c = :center_id',
                                             'region' => ' and consult_room__r.center_information__r.sales_region__c = :sales_region'};
          }

        private Map<String, Integer> consults_starts_counts_userytd() {
            Map<String, Integer> before_Q2_consult_counts = new Map<String, Integer>{'valid_callbacks' => 0, 'not_valid_callbacks' => 0};
            Map<String, Integer> after_Q1_consult_counts  = new Map<String, Integer>{'valid_callbacks' => 0, 'not_valid_callbacks' => 0};
            Map<String, Integer> userytd_consult_counts   = new Map<String, Integer>{'valid_callbacks' => 0, 'not_valid_callbacks' => 0};
            String base_query            = 'SELECT isValidCallBack__c, COUNT(ID) consults FROM Consult_Inventory__c WHERE Active__c = true AND Arrival_Time__c != null AND Consult_Room__r.Room_Type__c != \'Practice\' AND Apt_Date__c = ' + ranges.get('YTD');
            String before_Q2_2015_filter = ' AND Apt_Date__c  < 2015-04-01 AND (Scheduled_Lead__r.ConvertedAccount.OwnerId IN :user_filters OR Scheduled_Account__r.OwnerId in :user_filters)';
            String after_Q1_2015_filter  = ' AND Apt_Date__c >= 2015-04-01 AND Consult_PEC__c IN :user_filters';
            String before_Q2_query = base_query + before_Q2_2015_filter + ' GROUP BY isValidCallBack__c';
            String after_Q1_query  = base_query + after_Q1_2015_filter + ' GROUP BY isValidCallBack__c';
            before_Q2_consult_counts = userytd_consult_counts(before_Q2_query);
            after_Q1_consult_counts  = userytd_consult_counts(after_Q1_query);

            userytd_consult_counts.put('valid_callbacks', before_Q2_consult_counts.get('valid_callbacks') + after_Q1_consult_counts.get('valid_callbacks'));
            userytd_consult_counts.put('not_valid_callbacks', before_Q2_consult_counts.get('not_valid_callbacks') + after_Q1_consult_counts.get('not_valid_callbacks'));
            return userytd_consult_counts;
        }

        private Map<String, Integer> userytd_consult_counts(String query) {
            Map<String, Integer> consult_counts = new Map<String, Integer>{'valid_callbacks' => 0, 'not_valid_callbacks' => 0};
            for (AggregateResult results: database.query(query)) {
                if(results.get('consults') != null) {
                    if((Boolean)results.get('isValidCallBack__c'))       {consult_counts.put('valid_callbacks', (Integer)results.get('consults'));}
                    else if(!(Boolean)results.get('isValidCallBack__c')) {consult_counts.put('not_valid_callbacks', (Integer)results.get('consults'));}
                }
            }
            return consult_counts;
        }

  /*modified by cm on 12-16-2014
  Starts will now use prosth_exam_paid_date__c instead of created date based on a definition change.  An opportunity record is now a start when we collect $1000
  modified by aw 2016-06-20
  New start definition now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
  Removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c'
  Also, Starts are now given a value from zero to one, so we must sum these values rather than simply counting the number of Opportunity records  */

    private Map<String, String> starts_action_filters = new Map<String, String>{'all'    => ' AND Account.Center__r.Type__c not in (\'Affiliate\',\'Network Center\')',
                                                                                'user'   => ' AND ownerid in : user_filters',
                                                                                'center' => ' AND Account.Center__c = :center_id',
                                                                                'region' => ' AND Account.Center__r.Sales_Region__c = :sales_region'};

    // public DisplayDecimal getStarts() {
    //     if(starts == null) {
    //         starts = new DisplayDecimal();
    //         String start_type_filter = '';
    //         if(action_set.contains(action)) {
    //             starts.MTD            = starts_value('MTD', start_type_filter);
    //             starts.previous_month = starts_value('previous_month', start_type_filter);
    //             starts.YTD            = starts_value('YTD', start_type_filter);
    //             starts.QTD            = starts_value('QTD', start_type_filter);
    //             starts.previous_day   = starts_value('previous_day', start_type_filter);
    //         }
    //     }
    //     return starts;
    // }

    public DisplayDecimal getStarts() {
        if(starts == null) {
            starts   = new DisplayDecimal();
            sdstarts = new DisplayDecimal();
            //   String start_type_filter = '';
            if(action_set.contains(action)) {
                Map<String, Decimal> starts_values;
                starts_values = starts_values('MTD');
                starts.MTD    = starts_values.get('all');
                sdstarts.MTD  = starts_values.get('same_day');

                starts_values = starts_values('YTD');
                starts.YTD    = starts_values.get('all');
                sdstarts.YTD  = starts_values.get('same_day');

                starts_values = starts_values('QTD');
                starts.QTD    = starts_values.get('all');
                sdstarts.QTD  = starts_values.get('same_day');

                starts_values         = starts_values('previous_day');
                starts.previous_day   = starts_values.get('all');
                sdstarts.previous_day = starts_values.get('same_day');

                starts_values           = starts_values('previous_month');
                starts.previous_month   = starts_values.get('all');
                sdstarts.previous_month = starts_values.get('same_day');
            }
        }
        return starts;
    }

            private Map<String, Decimal> starts_values(String range) {
                Map<String, Decimal> values = new Map<String, Decimal>{'all' => 0, 'same_day' => 0};
                String base_query = 'SELECT Is_Same_Day_Start__c, SUM(Start_Value__c) starts_value FROM Opportunity WHERE is_Valid_Start__c = true AND Prosth_Exam_Paid_Date__c = ' + ranges.get(range);
                String full_query = base_query + starts_action_filters.get(action) + ' GROUP BY Is_Same_Day_Start__c';
                if(action == 'all') {full_query += all_filter;}
                for (AggregateResult results : database.query(full_query)) {
                    if(results.get('starts_value') != null) {
                        values.put('all', values.get('all') + (Decimal)results.get('starts_value'));
                        if((Boolean)results.get('Is_Same_Day_Start__c')) {values.put('same_day', values.get('same_day') + (Decimal)results.get('starts_value'));}
                    }
                }
                return values;
            }

          // public DisplayDecimal getSDStarts() {
          //   if(sdstarts==null) {
          //     sdstarts = new DisplayDecimal();
          //     String start_type_filter = ' AND Is_Same_Day_Start__c = true';
          //     if(action_set.contains(action)) {
          //       sdstarts.MTD              = starts_value('MTD', start_type_filter);
          //       sdstarts.previous_month   = starts_value('previous_month', start_type_filter);
          //       sdstarts.YTD              = starts_value('YTD', start_type_filter);
          //       sdstarts.QTD              = starts_value('QTD', start_type_filter);
          //       sdstarts.previous_day     = starts_value('previous_day', start_type_filter);
          //     }
          //   }
          //   return sdstarts;
          // }

    public DisplayDecimal getSDStarts() {
        if(sdstarts == null) {getStarts();}
        return sdstarts;
    }

  /*modified by cm on 12-16-2014
    Pending starts are defined as prosth exam records that have not been marked as paid (prosth_exam_paid__c)
    modified by aw on 2016-06-20
    A pending start is now defined as having the minimum Negotiated_Total_Amount but missing either of the other requirements for is_Valid_Start (paid prost exam and related treatment option)
  */
  // Per Scott Lawrence, using the COUNT of Pending Starts so PEC's/RBD's know there are pending starts that need to be dealt with even when the start value of those starts is zero. Code for pending starts by value is included below.
    public DisplayDecimal getPendingStarts() {
        if(pendingstarts==null) {
            pendingstarts = new DisplayDecimal();
            String start_type_filter = '';
            if(action_set.contains(action)) {
                pendingstarts.MTD            = pending_starts_count('MTD', start_type_filter);
                pendingstarts.previous_month = pending_starts_count('previous_month', start_type_filter);
                pendingstarts.YTD            = pending_starts_count('YTD', start_type_filter);
                pendingstarts.QTD            = pending_starts_count('QTD', start_type_filter);
                pendingstarts.previous_day   = pending_starts_count('previous_day', start_type_filter);
            }
        }
        return pendingstarts;
    }

            private Decimal pending_starts_count(String range, String start_type_filter) {
                String base_query = 'SELECT count(ID) pending_starts_count FROM Opportunity WHERE is_Valid_Start__c = false AND Negotiated_Total_Amount__c >= 2500 AND CreatedDate = ' + ranges.get(range) + ' AND (stagename != \'Cancelled Not Rescheduled\' AND Completed_Stage__c NOT IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))';
                AggregateResult[] aggregate = database.query(base_query + start_type_filter + starts_action_filters.get(action));
                return aggregate_value(aggregate, 'pending_starts_count');
            }

  // public DisplayDecimal getPendingStarts_value() {
  //   if(pendingstarts==null) {
  //     pendingstarts = new DisplayDecimal();
  //     String start_type_filter = '';
  //     if(action_set.contains(action)) {
  //       pendingstarts.MTD              = pending_starts_value('MTD', start_type_filter);
  //       pendingstarts.previous_month   = pending_starts_value('previous_month', start_type_filter);
  //       pendingstarts.YTD              = pending_starts_value('YTD', start_type_filter);
  //       pendingstarts.QTD              = pending_starts_value('QTD', start_type_filter);
  //       pendingstarts.previous_day     = pending_starts_value('previous_day', start_type_filter);
  //     }
  //   }
  //   return pendingstarts;
  // }

  //   private Decimal pending_starts_value(String range, String start_type_filter) {
  //       String base_query = 'SELECT SUM(Start_Value__c) starts_value FROM Opportunity WHERE is_Valid_Start__c = false AND Negotiated_Total_Amount__c >= 2500 AND CreatedDate = ' + ranges.get(range) + ' AND (stagename != \'Cancelled Not Rescheduled\' AND Completed_Stage__c NOT IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))';
  //       AggregateResult[] aggregate = database.query(base_query + start_type_filter + starts_action_filters().get(action));
  //       return aggregate_value(aggregate, 'starts_value');
  //   }

  public DisplayDecimal getStartsCancelled() {
    if(starts_cancelled==null) {
      starts_cancelled = new DisplayDecimal();
      if(starts_cancelled_in==null)
        starts_cancelled_in = getStartsCancelledIn();
      if(starts_cancelled_out==null)
        starts_cancelled_out = getStartsCancelledOut();
      try {starts_cancelled.MTD = starts_cancelled_in.MTD + starts_cancelled_out.MTD;} catch (Exception e) {starts_cancelled.MTD = 0;}
      try {starts_cancelled.QTD = starts_cancelled_in.QTD + starts_cancelled_out.QTD;} catch (Exception e) {starts_cancelled.QTD = 0;}
      try {starts_cancelled.YTD = starts_cancelled_in.YTD + starts_cancelled_out.YTD;} catch (Exception e) {starts_cancelled.YTD = 0;}
      try {starts_cancelled.previous_month = starts_cancelled_in.previous_month + starts_cancelled_out.previous_month;} catch (Exception e) {starts_cancelled.previous_month = 0;}
      try {starts_cancelled.previous_day = starts_cancelled_in.previous_day + starts_cancelled_out.previous_day;} catch (Exception e) {starts_cancelled.previous_day = 0;}
      //starts_cancelled.last_90 = starts_cancelled_in.last_90 + starts_cancelled_out.last_90;
      /*if(action=='all') {
        starts_cancelled.MTD = [select count() from opportunity where Cancel_Date__c = this_month
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;
        starts_cancelled.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;
        starts_cancelled.YTD = [select count() from opportunity where Cancel_Date__c = this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;
        starts_cancelled.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;
        starts_cancelled.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter +
          ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))') * -1;
      }
      else if(action=='user') {
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
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled.last_90 = [select count() from opportunity where Cancel_Date__c = LAST_QUARTER
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled.YTD = [select count() from opportunity where Cancel_Date__c = this_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled.QTD = [select count() from opportunity where Cancel_Date__c = this_quarter
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)] * -1;
        starts_cancelled.previous_day = database.countQuery('select count() from opportunity where Cancel_Date__c = ' + yesterday_filter +
          ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)') * -1;
      }*/
    }
    return starts_cancelled;
  }

  /*2013-03-11
    Adjusting this to match the definition on the Consultation Summary.  This will only count records where the cancel_reason__c is not null.  I'll have to figure out later how to get the
    missed ones back in to the true close rate.
    modified by cm on 2014-12-16
    adjusting the cancellation,  so it will only count on records that have recieved the $1000 payment (the new start definition)
    modified by cm on 2015-06-04
    per data governance,  I'm removing the loop hole that allows for certain in-period cancellations to be ignored
    old defintion was just cancel_reason__c != null
    new version is (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))
    modified by aw 2016-06-20
    Starts are now given a value from zero to one, so we must sum these values rather than simply counting the number of Opportunity records
  */
  public DisplayDecimal getStartsCancelledIn() {
    if(starts_cancelled_in==null) {
      starts_cancelled_in = new DisplayDecimal();
      if(action_set.contains(action)) {
        starts_cancelled_in.MTD            = starts_cancelled_value('MTD', 'in');
        starts_cancelled_in.previous_month = starts_cancelled_value('previous_month', 'in');
        starts_cancelled_in.YTD            = starts_cancelled_value('YTD', 'in');
        starts_cancelled_in.QTD            = starts_cancelled_value('QTD', 'in');
        starts_cancelled_in.previous_day   = starts_cancelled_value('previous_day', 'in');
      }
    }
    return starts_cancelled_in;
  }

  /*modified by cm on 2014-12-16
    adjusting the cancellation,  so it will only count on records that have recieved the $1000 payment (the new start definition)
  */
  public DisplayDecimal getStartsCancelledOut() {
    if(starts_cancelled_out==null) {
      starts_cancelled_out = new DisplayDecimal();
      if(action_set.contains(action)) {
        /*starts_cancelled_out.last_year  = [select count() from opportunity where Cancel_Date__c = last_year
          and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))] * -1;*/
          //starts_cancelled_out.last_90 = database.countQuery('select count() from opportunity where Cancel_Date__c = LAST_QUARTER and createddate <> LAST_QUARTER and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + all_filter) * -1;
        starts_cancelled_out.MTD            = starts_cancelled_value('MTD', 'out');
        starts_cancelled_out.previous_month = starts_cancelled_value('previous_month', 'out');
        starts_cancelled_out.YTD            = starts_cancelled_value('YTD', 'out');
        starts_cancelled_out.QTD            = starts_cancelled_value('QTD', 'out');
        starts_cancelled_out.previous_day   = starts_cancelled_value('previous_day', 'out');
      }
    }
    return starts_cancelled_out;
  }

          private Decimal starts_cancelled_value(String range, String type) {
              String base_query = 'SELECT SUM(Start_Value__c) cancelled_value FROM Opportunity WHERE Cancel_Date__c = ' + ranges.get(range) + ' AND ignored_cancel__c = false AND is_Valid_Start__c = true AND (stagename = \'Cancelled Not Rescheduled\' OR Completed_Stage__c IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))';
              if      (type == 'in')  {base_query += ' AND Prosth_Exam_Paid_Date__c  = ' + ranges.get(range);}
              else if (type == 'out') {base_query += ' AND Prosth_Exam_Paid_Date__c <> ' + ranges.get(range);}
              else                    {return null;}
              AggregateResult[] aggregate = database.query(base_query + starts_cancelled_action_filters().get(action));
              return aggregate_value(aggregate, 'cancelled_value') * -1;
          }

          private Map<String, String> starts_cancelled_action_filters() {
              return new Map<String, String>{'all'    => ' AND Account.Center__r.Type__c not in (\'Affiliate\',\'Network Center\')' + ' GROUP BY is_Valid_Start__c' + all_filter,
                                             'user'   => ' AND Current_Prosth_Owner__c in :user_filters',
                                             'center' => ' AND Account.Center__c = :center_id',
                                             'region' => ' AND Account.Center__r.Sales_Region__c = :sales_region'};
          }

          private Decimal aggregate_value(AggregateResult[] aggregate, String fieldname) {
              return aggregate_has_data(aggregate, fieldname) ? (Decimal)aggregate[0].get(fieldname) : 0;
          }

          private Boolean aggregate_has_data(AggregateResult[] aggregate, String fieldname) {
              return (aggregate.size() > 0 && aggregate[0].get(fieldname) != null);
          }

  public Integer gettotal_open_days() {
      if(total_open_days==null) {
          total_open_days = 0;
          if(action=='all') {
              total_open_days = [Select count() From Center_Open_Day__c c where calendar_date__c = this_month and open_status__c = 'Open' and center_information__r.name not in ('Unknown','Market Not Yet Open','Miami','Chicago Deerfield/Northbrook','Tucson') and center_information__r.type__c not in ('Affiliate','Network Center')];
          }
          else if(action=='center') {
              total_open_days = [Select count() From Center_Open_Day__c c where calendar_date__c = this_month and open_status__c = 'Open' and center_information__r.name not in ('Unknown','Market Not Yet Open','Miami','Chicago Deerfield/Northbrook','Tucson') and center_information__r.type__c not in ('Affiliate','Network Center') and center_information__c = :center_id];
          }
          else if(action=='region') {
              total_open_days = [Select count() From Center_Open_Day__c c where calendar_date__c = this_month and open_status__c = 'Open' and center_information__r.name not in ('Unknown','Market Not Yet Open','Miami','Chicago Deerfield/Northbrook','Tucson') and center_information__r.type__c not in ('Affiliate','Network Center') and center_information__r.sales_region__c = :sales_region];
          }
      }
      return total_open_days;
  }

  public Integer getcompleted_open_days() {
      if(completed_open_days==null) {
          completed_open_days = 0;
          if(action=='all') {
              completed_open_days = [Select count() From Center_Open_Day__c c where calendar_date__c < today and calendar_date__c = this_month and open_status__c = 'Open' and center_information__r.name not in ('Unknown','Market Not Yet Open','Miami','Chicago Deerfield/Northbrook','Tucson') and center_information__r.type__c not in ('Affiliate','Network Center')];
          }
          else if(action=='center') {
              completed_open_days = [Select count() From Center_Open_Day__c c where calendar_date__c < today and calendar_date__c = this_month and open_status__c = 'Open' and center_information__r.name not in ('Unknown','Market Not Yet Open','Miami','Chicago Deerfield/Northbrook','Tucson') and center_information__r.type__c not in ('Affiliate','Network Center') and center_information__c = :center_id];
          }
          else if(action=='region')  {
              completed_open_days = [Select count() From Center_Open_Day__c c where calendar_date__c < today and calendar_date__c = this_month and open_status__c = 'Open' and center_information__r.name not in ('Unknown','Market Not Yet Open','Miami','Chicago Deerfield/Northbrook','Tucson') and center_information__r.type__c not in ('Affiliate','Network Center') and center_information__r.sales_region__c = :sales_region];
          }
      }
      return completed_open_days;
  }

  /*modified by cm on 3-31-2015
    pulling out dollars for items that do not meet the start guideline - this was based on a request from Tod.  It should bring the avg revenue per start number back in line
    modified by AW on 8-2-2016
    Refactored to newer version below. Should be functionally equivalent.
  */
  // public DisplayDollars getTreatmentSold() {
  //   if(treatment_sold==null) {
  //     treatment_sold = new DisplayDollars();
  //     treatment_sold.MTD = 0;
  //     treatment_sold.previous_month = 0;
  //     treatment_sold.YTD = 0;
  //     treatment_sold.QTD = 0;
  //     treatment_sold.previous_day = 0;
  //     treatment_sold_valid = new DisplayDollars();
  //     treatment_sold_valid.MTD = 0;
  //     treatment_sold_valid.previous_month = 0;
  //     treatment_sold_valid.YTD = 0;
  //     treatment_sold_valid.QTD = 0;
  //     treatment_sold_valid.previous_day = 0;
  //     if(action=='all') {
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = last_year]) {
  //         if(results.get('total_payments')==null)
  //           treatment_sold.last_year = 0;
  //         else
  //           treatment_sold.last_year = (Decimal)results.get('total_payments');
  //       }*/
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = this_month and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') group by is_valid_start__c ')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.MTD = 0;
  //         //else
  //           treatment_sold.MTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.MTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate = LAST_QUARTER' )) {
  //         if(results.get('total_payments')==null)
  //           treatment_sold.last_90 = 0;
  //         else
  //           treatment_sold.last_90 = (Decimal)results.get('total_payments');
  //       }*/
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = LAST_MONTH and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') group by is_valid_start__c ' )) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.previous_month = 0;
  //         //else
  //           treatment_sold.previous_month += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_month += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = this_year and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.YTD = 0;
  //         //else
  //           treatment_sold.YTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.YTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = this_quarter and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.QTD = 0;
  //         //else
  //           treatment_sold.QTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.QTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and createddate = ' + yesterday_filter + ' group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.previous_day = 0;
  //         //else
  //           treatment_sold.previous_day += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_day += (Decimal)results.get('total_payments');
  //         }
  //       }
  //     }
  //     else if(action=='user') {
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = last_year and ownerid in : user_filters]) {
  //         if(results.get('total_payments')==null)
  //           treatment_sold.last_year = 0;
  //         else
  //           treatment_sold.last_year = (Decimal)results.get('total_payments');
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_month and ownerid in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.MTD = 0;
  //         //else
  //           treatment_sold.MTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.MTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = LAST_QUARTER and ownerid in : user_filters]) {
  //         if(results.get('total_payments')==null)
  //           treatment_sold.last_90 = 0;
  //         else
  //           treatment_sold.last_90 = (Decimal)results.get('total_payments');
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = LAST_MONTH and ownerid in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.previous_month = 0;
  //         //else
  //           treatment_sold.previous_month += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_month += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_year and ownerid in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.YTD = 0;
  //         //else
  //           treatment_sold.YTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.YTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_quarter and ownerid in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.QTD = 0;
  //         //else
  //           treatment_sold.QTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.QTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and ownerid in : user_filters group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_sold.previous_day = 0;
  //         //else
  //           treatment_sold.previous_day += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_day += (Decimal)results.get('total_payments');
  //         }
  //       }
  //     }
  //     else if(action=='center') {
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = last_year and accountid in (select id from account where center__c = :center_id)]) {
  //         if(results.get('total_payments')==null)
  //           treatment_sold.last_year = 0;
  //         else
  //           treatment_sold.last_year = (Decimal)results.get('total_payments');
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_month and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.MTD = 0;
  //         //else
  //           treatment_sold.MTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.MTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = LAST_QUARTER and accountid in (select id from account where center__c = :center_id)]) {
  //         if(results.get('total_payments')==null)
  //           treatment_sold.last_90 = 0;
  //         else
  //           treatment_sold.last_90 = (Decimal)results.get('total_payments');
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = LAST_MONTH and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.previous_month = 0;
  //         //else
  //           treatment_sold.previous_month += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_month += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_year and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.YTD = 0;
  //         //else
  //           treatment_sold.YTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.YTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_quarter and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.QTD = 0;
  //         //else
  //           treatment_sold.QTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.QTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and account.center__c = :center_id group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.previous_day = 0;
  //         //else
  //           treatment_sold.previous_day += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_day += (Decimal)results.get('total_payments');
  //         }
  //       }
  //     }
  //     else if(action=='region') {
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_month and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.MTD = 0;
  //         //else
  //           treatment_sold.MTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.MTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = LAST_MONTH and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.previous_month = 0;
  //         //else
  //           treatment_sold.previous_month += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_month += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_year and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.YTD = 0;
  //         //else
  //           treatment_sold.YTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.YTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where createddate = this_quarter and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_sold.QTD = 0;
  //         //else
  //           treatment_sold.QTD += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.QTD += (Decimal)results.get('total_payments');
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where createddate = ' + yesterday_filter + ' and account.center__r.sales_region__c = :sales_region group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_sold.previous_day = 0;
  //         //else
  //           treatment_sold.previous_day += (Decimal)results.get('total_payments');
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_sold_valid.previous_day += (Decimal)results.get('total_payments');
  //         }
  //       }
  //     }
  //   }
  //   return treatment_sold;
  // }

    private Map<String, String> revenue_query_filters = new Map<String, String>{'all'    => ' AND Account.Center__r.Type__c not in (\'Affiliate\',\'Network Center\')',
                                                                                'user'   => ' AND ownerid in : user_filters',
                                                                                'center' => ' AND Account.Center__c = :center_id',
                                                                                'region' => ' AND Account.Center__r.Sales_Region__c = :sales_region'};

    public DisplayDollars getTreatmentSold() {
        if(treatment_sold == null) {
            treatment_sold       = zeroed_DisplayDollars();
            treatment_sold_valid = zeroed_DisplayDollars();
            // 'Small' revenue is from sales with a negotiated_total_amount less than the defined minimum but which otherwise meets the valid start requirements
            treatment_sold_small = zeroed_DisplayDollars();

            if(action_set.contains(action)) {
                Map<String, Decimal> totals;
                totals = revenue_totals('MTD');
                treatment_sold.MTD       = totals.get('all');
                treatment_sold_valid.MTD = totals.get('valid');
                treatment_sold_small.MTD = totals.get('small');

                totals = revenue_totals('previous_month');
                treatment_sold.previous_month       = totals.get('all');
                treatment_sold_valid.previous_month = totals.get('valid');
                treatment_sold_small.previous_month = totals.get('small');

                totals = revenue_totals('YTD');
                treatment_sold.YTD       = totals.get('all');
                treatment_sold_valid.YTD = totals.get('valid');
                treatment_sold_small.YTD = totals.get('small');

                totals = revenue_totals('QTD');
                treatment_sold.QTD       = totals.get('all');
                treatment_sold_valid.QTD = totals.get('valid');
                treatment_sold_small.QTD = totals.get('small');

                totals = revenue_totals('previous_day');
                treatment_sold.previous_day       = totals.get('all');
                treatment_sold_valid.previous_day = totals.get('valid');
                treatment_sold_small.previous_day = totals.get('small');
            }
        }
        return treatment_sold;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Map<String, Decimal> revenue_totals(String range) {
                Map<String, Decimal> totals = new Map<String, Decimal>{'all' => 0, 'valid' => 0, 'small' => 0};
                String query = 'SELECT is_valid_start__c, is_Requirement_Met__c, sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE Prosth_Exam_Paid_Date__c = ' + ranges.get(range) + revenue_query_filters.get(action) + ' GROUP BY is_valid_start__c, is_Requirement_Met__c';
                for (AggregateResult results : database.query(query)) {
                    if(results.get('total_payments') != null) {
                        totals.put('all', totals.get('all') + (Decimal)results.get('total_payments'));
                        if((boolean)results.get('is_valid_start__c')) {totals.put('valid', totals.get('valid') + (Decimal)results.get('total_payments'));}
                        else if((boolean)results.get('is_Requirement_Met__c')) {totals.put('small', totals.get('small') + (Decimal)results.get('total_payments'));}
                    }
                }
                return totals;
            }

    public displayDollars getTreatmentSoldValid() {
        if(treatment_sold_valid == null)
            getTreatmentSold();
        return treatment_sold_valid;
    }

    public displayDollars getTreatmentSold_Small() {
        if(treatment_sold_small == null)
            getTreatmentSold();
        return treatment_sold_small;
    }

    public DisplayDollars getTreatmentSoldValid_StartValue1() {
        if(treatment_sold_valid_start_value_1 == null) {
            treatment_sold_valid_start_value_1 = zeroed_DisplayDollars();

            if(action_set.contains(action)) {
                treatment_sold_valid_start_value_1.MTD              = valid_revenue_start_value_1('MTD');
                treatment_sold_valid_start_value_1.previous_month   = valid_revenue_start_value_1('previous_month');
                treatment_sold_valid_start_value_1.YTD              = valid_revenue_start_value_1('YTD');
                treatment_sold_valid_start_value_1.QTD              = valid_revenue_start_value_1('QTD');
                treatment_sold_valid_start_value_1.previous_day     = valid_revenue_start_value_1('previous_day');
            }
        }
        return treatment_sold_valid_start_value_1;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Decimal valid_revenue_start_value_1(String range) {
                AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND Start_Value__c = 1.0 AND Prosth_Exam_Paid_Date__c = ' + ranges.get(range) + revenue_query_filters.get(action));
                return aggregate_value(aggregate, 'total_payments');
            }

    // public DisplayDollars getTreatmentSold_Small() {
    //     // Revenue for sales with a negotiated_total_amount less than the defined minimum but which otherwise meets the valid start requirements
    //     if(treatment_sold_small == null) {
    //         treatment_sold_small = zeroed_DisplayDollars();
    //
    //         if(action_set.contains(action)) {
    //          treatment_sold_small.MTD = small_revenue('MTD');
    //          treatment_sold_small.previous_month = small_revenue('previous_month');
    //          treatment_sold_small.YTD = small_revenue('YTD');
    //          treatment_sold_small.QTD = small_revenue('QTD');
    //          treatment_sold_small.previous_day = small_revenue('previous_day');
    //         }
    //     }
    //     return treatment_sold_small;
    // }
    //
    //         private Decimal small_revenue(String range) {
    //             AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Minimum_Negotiated_Total_Amount__c = false AND is_Requirement_Met__c = true AND CreatedDate = ' + ranges.get(range) + revenue_query_filters.get(action));
    //             return aggregate_value(aggregate, 'total_payments');
    //         }

    public DisplayDollars getPendingTreatmentSold() {
        if(pending_treatment_sold == null) {
            pending_treatment_sold = zeroed_DisplayDollars();

            if(action_set.contains(action)) {
                pending_treatment_sold.MTD = pending_revenue('MTD');
                pending_treatment_sold.YTD = pending_revenue('YTD');
                pending_treatment_sold.QTD = pending_revenue('QTD');
                pending_treatment_sold.previous_day = pending_revenue('previous_day');
                pending_treatment_sold.previous_month = pending_revenue('previous_month');
            }
        }
        return pending_treatment_sold;
    }

            private Decimal pending_revenue(String range) {
                AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = false AND Negotiated_Total_Amount__c >= 2500 AND CreatedDate = ' + ranges.get(range) + ' AND (stagename != \'Cancelled Not Rescheduled\' AND Completed_Stage__c NOT IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + revenue_query_filters.get(action));
                return aggregate_value(aggregate, 'total_payments');
            }

  public DisplayDollars getTreatmentCancelled() {
    if(treatment_cancelled==null) {
      treatment_cancelled = new DisplayDollars();
      if(treatment_cancelled_in==null)
        getTreatmentCancelledIn();
      if(treatment_cancelled_out==null)
        getTreatmentCancelledOut();
      try {treatment_cancelled.MTD = treatment_cancelled_in.MTD + treatment_cancelled_out.MTD;} catch (Exception e) {treatment_cancelled.MTD = 0;}
      try {treatment_cancelled.QTD = treatment_cancelled_in.QTD + treatment_cancelled_out.QTD;} catch (Exception e) {treatment_cancelled.QTD = 0;}
      try {treatment_cancelled.YTD = treatment_cancelled_in.YTD + treatment_cancelled_out.YTD;} catch (Exception e) {treatment_cancelled.YTD = 0;}
      //treatment_cancelled.last_90 = treatment_cancelled_in.last_90 + treatment_cancelled_out.last_90;
      try {treatment_cancelled.previous_month = treatment_cancelled_in.previous_month + treatment_cancelled_out.previous_month;} catch (Exception e) {treatment_cancelled.previous_month = 0;}
      try {treatment_cancelled.previous_day = treatment_cancelled_in.previous_day + treatment_cancelled_out.previous_day;} catch (Exception e) {treatment_cancelled.previous_day = 0;}
      /*if(action=='all') {
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
            where Cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.MTD = 0;
          else
            treatment_cancelled.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
            where Cancel_Date__c = LAST_QUARTER and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.last_90 = 0;
          else
            treatment_cancelled.last_90 = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
            where Cancel_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.YTD = 0;
          else
            treatment_cancelled.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
            where Cancel_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
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
          where Cancel_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.MTD = 0;
          else
            treatment_cancelled.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = LAST_QUARTER and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.last_90 = 0;
          else
            treatment_cancelled.last_90 = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.YTD = 0;
          else
            treatment_cancelled.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled.QTD = 0;
          else
            treatment_cancelled.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity ' +
            ' where Cancel_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)')) {
          if(results.get('total_payments')==null)
            treatment_cancelled.previous_day = 0;
          else
            treatment_cancelled.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }      */
    }
    return treatment_cancelled;
  }

  /* modified by AW 8-2-2016 - refactored to new version below. Should be functionally equivalent.*/

  // public DisplayDollars getTreatmentCancelledIn() {
  //   if(treatment_cancelled_in==null) {
  //     treatment_cancelled_in = new DisplayDollars();
  //     treatment_cancelled_in.MTD = 0;
  //     treatment_cancelled_in.previous_month = 0;
  //     treatment_cancelled_in.QTD = 0;
  //     treatment_cancelled_in.previous_day = 0;
  //     treatment_cancelled_in.YTD = 0;
  //     treatment_cancelled_in_valid = new DisplayDollars();
  //     treatment_cancelled_in_valid.MTD = 0;
  //     treatment_cancelled_in_valid.previous_month = 0;
  //     treatment_cancelled_in_valid.QTD = 0;
  //     treatment_cancelled_in_valid.previous_day = 0;
  //     treatment_cancelled_in_valid.YTD = 0;
  //
  //     if(action=='all') {
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //           where lastmodifieddate = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
  //         if(results.get('total_payments')==null)
  //           treatment_cancelled_in.last_year = 0;
  //         else
  //           treatment_cancelled_in.last_year = (Decimal)results.get('total_payments') * -1;
  //       }*/
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and account.center__r.type__c not in (\'Affiliate\',\'Network Center\')  and createddate = this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //             //            treatment_cancelled_in.MTD = 0;
  //         //else
  //           treatment_cancelled_in.MTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.MTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
  //         if(results.get('total_payments')==null)
  //           treatment_cancelled_in.last_90 = 0;
  //         else
  //           treatment_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
  //       }*/
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_MONTH and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and createddate = last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //         //  treatment_cancelled_in.previous_month = 0;
  //         //else
  //           treatment_cancelled_in.previous_month += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_month += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and createddate = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.YTD = 0;
  //         //else
  //           treatment_cancelled_in.YTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.YTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and createddate = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_cancelled_in.QTD = 0;
  //         //else
  //           treatment_cancelled_in.QTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.QTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
  //           ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = ' + yesterday_filter + ' and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_cancelled_in.previous_day = 0;
  //         //else
  //           treatment_cancelled_in.previous_day += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_day += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //     }
  //     else if(action=='user') {
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //          where Cancel_Date__c = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
  //         if(results.get('total_payments')==null)
  //           treatment_cancelled_in.last_year = 0;
  //         else
  //           treatment_cancelled_in.last_year = (Decimal)results.get('total_payments') * -1;
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.MTD = 0;
  //         //else
  //           treatment_cancelled_in.MTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.MTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
  //         if(results.get('total_payments')==null)
  //           treatment_cancelled_in.last_90 = 0;
  //         else
  //           treatment_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_cancelled_in.previous_month = 0;
  //         //else
  //           treatment_cancelled_in.previous_month += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_month += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.YTD = 0;
  //         //else
  //           treatment_cancelled_in.YTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.YTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_cancelled_in.QTD = 0;
  //         //else
  //           treatment_cancelled_in.QTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.QTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
  //           ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.previous_day = 0;
  //         //else
  //           treatment_cancelled_in.previous_day += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_day += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //     }
  //     else if(action=='center') {
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //          where Cancel_Date__c = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
  //         if(results.get('total_payments')==null)
  //           treatment_cancelled_in.last_year = 0;
  //         else
  //           treatment_cancelled_in.last_year = (Decimal)results.get('total_payments') * -1;
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_cancelled_in.MTD = 0;
  //         //else
  //           treatment_cancelled_in.MTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.MTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = LAST_QUARTER and createddate = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
  //         if(results.get('total_payments')==null)
  //           treatment_cancelled_in.last_90 = 0;
  //         else
  //           treatment_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
  //       }*/
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.previous_month = 0;
  //         //else
  //           treatment_cancelled_in.previous_month += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_month += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //           //treatment_cancelled_in.YTD = 0;
  //         //else
  //           treatment_cancelled_in.YTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.YTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.QTD = 0;
  //         //else
  //           treatment_cancelled_in.QTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.QTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
  //           ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__c = :center_id group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.previous_day = 0;
  //         //else
  //           treatment_cancelled_in.previous_day += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_day += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //     }
  //     else if(action=='region') {
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_month and createddate = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.MTD = 0;
  //         //else
  //           treatment_cancelled_in.MTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.MTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = LAST_MONTH and createddate = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.previous_month = 0;
  //         //else
  //           treatment_cancelled_in.previous_month += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_month += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_year and createddate = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.YTD = 0;
  //         //else
  //           treatment_cancelled_in.YTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.YTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
  //         where Cancel_Date__c = this_quarter and createddate = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.QTD = 0;
  //         //else
  //           treatment_cancelled_in.QTD += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.QTD += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //       for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
  //           ' where Cancel_Date__c = ' + yesterday_filter + ' and createddate = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c')) {
  //         if(results.get('total_payments')!=null) {
  //          // treatment_cancelled_in.previous_day = 0;
  //         //else
  //           treatment_cancelled_in.previous_day += (Decimal)results.get('total_payments') * -1;
  //           if((boolean)results.get('is_valid_start__c'))
  //             treatment_cancelled_in_valid.previous_day += (Decimal)results.get('total_payments') * -1;
  //         }
  //       }
  //     }
  //   }
  //   return treatment_cancelled_in;
  // }

    private Map<String, String> cancelled_revenue_query_filters = new Map<String, String>{'all'    => ' AND account.Center__r.Type__c NOT IN (\'Affiliate\',\'Network Center\')',
                                                                                          'user'   => ' AND Current_Prosth_Owner__c IN :user_filters',
                                                                                          'center' => ' AND account.Center__c = :center_id',
                                                                                          'region' => ' AND account.Center__r.Sales_Region__c = :sales_region'};

    public DisplayDollars getTreatmentCancelledIn() {
        if(treatment_cancelled_in == null) {
            treatment_cancelled_in = zeroed_DisplayDollars();
            treatment_cancelled_in_valid = zeroed_DisplayDollars();

            if(action_set.contains(action)) {
                Decimal[] totals;
                totals = cancelled_in_revenue_totals('MTD');
                treatment_cancelled_in.MTD = totals[0];
                treatment_cancelled_in_valid.MTD = totals[1];
                totals = cancelled_in_revenue_totals('previous_month');
                treatment_cancelled_in.previous_month = totals[0];
                treatment_cancelled_in_valid.previous_month = totals[1];
                totals = cancelled_in_revenue_totals('YTD');
                treatment_cancelled_in.YTD = totals[0];
                treatment_cancelled_in_valid.YTD = totals[1];
                totals = cancelled_in_revenue_totals('QTD');
                treatment_cancelled_in.QTD = totals[0];
                treatment_cancelled_in_valid.QTD = totals[1];
                totals = cancelled_in_revenue_totals('previous_day');
                treatment_cancelled_in.previous_day = totals[0];
                treatment_cancelled_in_valid.previous_day = totals[1];
            }
        }
        return treatment_cancelled_in;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Decimal[] cancelled_in_revenue_totals(String range) {
                Decimal cancelled = 0;
                Decimal cancelled_valid = 0;
                String query = 'SELECT is_Valid_Start__c, sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE Cancel_Date__c = ' + ranges.get(range) + ' AND Prosth_Exam_Paid_Date__c = ' + ranges.get(range) + ' AND (stagename = \'Cancelled Not Rescheduled\' OR Completed_Stage__c IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + cancelled_revenue_query_filters.get(action) + ' GROUP BY is_Valid_Start__c';
                for (AggregateResult results : database.query(query)) {
                    if(results.get('total_payments') != null) {
                        cancelled += (Decimal)results.get('total_payments') * -1;
                        if((boolean)results.get('is_valid_start__c')) {cancelled_valid += (Decimal)results.get('total_payments') * -1;}
                    }
                }
                return new Decimal[]{cancelled, cancelled_valid};
            }

    public DisplayDollars getTreatmentCancelledInValid() {
        if(treatment_cancelled_in_valid == null)
            getTreatmentCancelledIn();
        return treatment_cancelled_in_valid;
    }

    public DisplayDollars getTreatmentCancelledInValid_StartValue1() {
        if(treatment_cancelled_in_valid_start_value_1 == null) {
            treatment_cancelled_in_valid_start_value_1 = zeroed_DisplayDollars();

            if(action_set.contains(action)) {
                treatment_cancelled_in_valid_start_value_1.MTD              = valid_cancelled_in_revenue_start_value_1('MTD');
                treatment_cancelled_in_valid_start_value_1.previous_month   = valid_cancelled_in_revenue_start_value_1('previous_month');
                treatment_cancelled_in_valid_start_value_1.YTD              = valid_cancelled_in_revenue_start_value_1('YTD');
                treatment_cancelled_in_valid_start_value_1.QTD              = valid_cancelled_in_revenue_start_value_1('QTD');
                treatment_cancelled_in_valid_start_value_1.previous_day     = valid_cancelled_in_revenue_start_value_1('previous_day');
            }
        }
        return treatment_cancelled_in_valid_start_value_1;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Decimal valid_cancelled_in_revenue_start_value_1(String range) {
                AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND Start_Value__c = 1.0 AND Cancel_Date__c = ' + ranges.get(range) + ' AND Prosth_Exam_Paid_Date__c = ' + ranges.get(range) + ' AND (stagename = \'Cancelled Not Rescheduled\' OR Completed_Stage__c IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + cancelled_revenue_query_filters.get(action));
                return aggregate_value(aggregate, 'total_payments') * -1;
            }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public DisplayDollars getTreatmentCancelledOut() {
    if(treatment_cancelled_out==null) {
      treatment_cancelled_out = zeroed_DisplayDollars();
      treatment_cancelled_out_valid = zeroed_DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
            where lastmodifieddate = last_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_year = 0;
          else
            treatment_cancelled_out.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_month and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.MTD = 0;
          //else
            treatment_cancelled_out.MTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.MTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        /*for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c <> last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_90 = 0;
          else
            treatment_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = LAST_MONTH and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.previous_month = 0;
          //else
            treatment_cancelled_out.previous_month += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_month += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : database.query('select is_valid_start__c, sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_year and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.YTD = 0;
          //else
            treatment_cancelled_out.YTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.YTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = this_quarter and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.QTD = 0;
          //else
            treatment_cancelled_out.QTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.QTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
            ' where Cancel_Date__c = ' + yesterday_filter + ' and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.previous_day = 0;
          //else
            treatment_cancelled_out.previous_day += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_day += (Decimal)results.get('total_payments') * -1;
          }
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
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.MTD = 0;
          //else
            treatment_cancelled_out.MTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.MTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_90 = 0;
          else
            treatment_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.previous_month = 0;
          //else
            treatment_cancelled_out.previous_month += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_month += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.YTD = 0;
          //else
            treatment_cancelled_out.YTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.YTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.QTD = 0;
          //else
            treatment_cancelled_out.QTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.QTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
            ' where Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and Current_Prosth_Owner__c in : user_filters group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.previous_day = 0;
          //else
            treatment_cancelled_out.previous_day += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_day += (Decimal)results.get('total_payments') * -1;
          }
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
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id) group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.MTD = 0;
          //else
            treatment_cancelled_out.MTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.MTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        /*for (AggregateResult results : [select sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id)]) {
          if(results.get('total_payments')==null)
            treatment_cancelled_out.last_90 = 0;
          else
            treatment_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id) group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.previous_month = 0;
          //else
            treatment_cancelled_out.previous_month += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_month += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id) group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.YTD = 0;
          //else
            treatment_cancelled_out.YTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.YTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and accountid in (select id from account where center__c = :center_id) group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.QTD = 0;
          //else
            treatment_cancelled_out.QTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.QTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : database.query('select is_valid_start__c, sum(negotiated_total_amount__c) total_payments from opportunity ' +
            ' where Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id) group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.previous_day = 0;
          //else
            treatment_cancelled_out.previous_day += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_day += (Decimal)results.get('total_payments') * -1;
          }
        }
      }
      else if(action=='region') {
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.MTD = 0;
          //else
            treatment_cancelled_out.MTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.MTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.previous_month = 0;
          //else
            treatment_cancelled_out.previous_month += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_month += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
            //treatment_cancelled_out.YTD = 0;
          //else
            treatment_cancelled_out.YTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.YTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : [select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity
          where Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c]) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.QTD = 0;
          //else
            treatment_cancelled_out.QTD += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.QTD += (Decimal)results.get('total_payments') * -1;
          }
        }
        for (AggregateResult results : database.query('select is_valid_start__c,sum(negotiated_total_amount__c) total_payments from opportunity ' +
            ' where Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_region__c = :sales_region group by is_valid_start__c')) {
          if(results.get('total_payments')!=null) {
           // treatment_cancelled_out.previous_day = 0;
          //else
            treatment_cancelled_out.previous_day += (Decimal)results.get('total_payments') * -1;
            if((boolean)results.get('is_valid_start__c'))
              treatment_cancelled_out_valid.previous_day += (Decimal)results.get('total_payments') * -1;
          }
        }
      }
    }
    return treatment_cancelled_out;
  }

    public DisplayDollars getTreatmentCancelledOutValid() {
        if(treatment_cancelled_out_valid == null)
            getTreatmentCancelledOut();
        return treatment_cancelled_out_valid;
    }

  public DisplayDollars getGPCollectedFees() {
        return gp_collected_fees;
  }

  public DisplayDollars getPrivateCollected() {
        if(private_collected==null) {
          private_collected = zeroed_DisplayDollars();
          if(action=='all') {
                for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = this_month')) {
          if(results.get('total_payments')!=null)
            private_collected.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = last_month')) {
          if(results.get('total_payments')!=null)
            private_collected.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = this_year')) {
          if(results.get('total_payments')!=null)
            private_collected.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = this_quarter')) {
          if(results.get('total_payments')!=null)
            private_collected.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter)) {
          if(results.get('total_payments')!=null)
            private_collected.previous_day = (Decimal)results.get('total_payments');
        }

          }
          if(action=='user') {
                for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_month and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_collected.MTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = last_month and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_collected.previous_month = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_year and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_collected.YTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_quarter and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_collected.QTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and parent_owner__c in  : user_filters')) {
          if(results.get('total_payments')!=null)
            private_collected.previous_day = (Decimal)results.get('total_payments');
        }
          }
          if(action=='center') {
                for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_month and center_id__c =  :center_id]) {
          if(results.get('total_payments')!=null)
            private_collected.MTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = last_month and center_id__c =  : center_id]) {
          if(results.get('total_payments')!=null)
            private_collected.previous_month = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_year and center_id__c =  : center_id]) {
          if(results.get('total_payments')!=null)
            private_collected.YTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_quarter and center_id__c =  : center_id]) {
          if(results.get('total_payments')!=null)
            private_collected.QTD = (Decimal)results.get('total_payments');
        }
                for(AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and center_id__c =  : center_id')) {
          if(results.get('total_payments')!=null)
            private_collected.previous_day = (Decimal)results.get('total_payments');
        }
          }
          if(action=='region') {
                for(AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and (opportunity__r.account.center__r.sales_region__c = :sales_region or private_practice_patient__r.center__r.sales_region__c = :sales_region)')) {
          if(results.get('total_payments')!=null)
            private_collected.previous_day = (Decimal)results.get('total_payments');
        }
                for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_quarter and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_collected.QTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_year and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_collected.YTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = this_month and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_collected.MTD = (Decimal)results.get('total_payments');
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'Collected'
                  and payment_date__c = last_month and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_collected.previous_month = (Decimal)results.get('total_payments');
        }
          }
        }
        return private_collected;
  }

  public DisplayDollars getCollected() {
    if(collected==null) {
      collected = new DisplayDollars();
      gp_collected_fees = new DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = last_year]) {
          if(results.get('total_payments')==null)
            collected.last_year = 0;
          else
            collected.last_year = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c where payment_status_formula__c = \'Collected\' and payment_date__c = this_month')) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.MTD = 0;
          else
            gp_collected_fees.MTD = (Decimal)results.get('total_gp_fee')  * -1;
        }
        /*for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = LAST_QUARTER')) {
          if(results.get('total_payments')==null)
            collected.last_90 = 0;
          else
            collected.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = LAST_MONTH')) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_month = 0;
          else
            gp_collected_fees.previous_month = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_year')) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.YTD = 0;
          else
            gp_collected_fees.YTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Collected\' and payment_date__c = this_quarter')) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.QTD = 0;
          else
            gp_collected_fees.QTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter)) {
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_day = 0;
          else
            gp_collected_fees.previous_day = (Decimal)results.get('total_gp_fee') * -1;
        }
      }
      else if(action=='user') {
        /*modified by cm on 2015-06-19
        changing payment ownership to the pec__c field in the table.
        old filter = and opportunity__c in (select id from opportunity where ownerid in : user_filters)
        new filter = and pec__c in :user_filters
        */
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
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.MTD = 0;
          else
            gp_collected_fees.MTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_QUARTER and opportunity__c in
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            collected.last_90 = 0;
          else
            collected.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_MONTH and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_month = 0;
          else
            gp_collected_fees.previous_month = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_year and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.YTD = 0;
          else
            gp_collected_fees.YTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_quarter and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.QTD = 0;
          else
            gp_collected_fees.QTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_day = 0;
          else
            gp_collected_fees.previous_day = (Decimal)results.get('total_gp_fee') * -1;
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
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and
          opportunity__r.account.center__c = :center_id]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and
          opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.MTD = 0;
          else
            gp_collected_fees.MTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_QUARTER and opportunity__r.account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.last_90 = 0;
          else
            collected.last_90 = (Decimal)results.get('total_payments');
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_MONTH and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_month = 0;
          else
            gp_collected_fees.previous_month = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_year and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.YTD = 0;
          else
            gp_collected_fees.YTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_quarter and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.QTD = 0;
          else
            gp_collected_fees.QTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and opportunity__r.Roll_Up_Center__c = :center_id')) {
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_day = 0;
          else
            gp_collected_fees.previous_day = (Decimal)results.get('total_gp_fee') * -1;
        }
      }
      else if(action=='region') {
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_month and
          opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            collected.MTD = 0;
          else
            collected.MTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.MTD = 0;
          else
            gp_collected_fees.MTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = LAST_MONTH and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            collected.previous_month = 0;
          else
            collected.previous_month = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_month = 0;
          else
            gp_collected_fees.previous_month = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_year and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            collected.YTD = 0;
          else
            collected.YTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.YTD = 0;
          else
            gp_collected_fees.YTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Collected' and payment_date__c = this_quarter and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            collected.QTD = 0;
          else
            collected.QTD = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.QTD = 0;
          else
            gp_collected_fees.QTD = (Decimal)results.get('total_gp_fee') * -1;
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + yesterday_filter + ' and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            collected.previous_day = 0;
          else
            collected.previous_day = (Decimal)results.get('total_payments');
          if(results.get('total_gp_fee')==null)
            gp_collected_fees.previous_day = 0;
          else
            gp_collected_fees.previous_day = (Decimal)results.get('total_gp_fee') * -1;
        }
      }
    }
    return collected;
  }

  public DisplayDollars getGPRefundedFees() {
        return gp_refunded_fees;
  }

  public DisplayDollars getPrivateRefunded() {
        if(private_refunded==null) {
          private_refunded = zeroed_DisplayDollars();
          if(action=='all') {
                for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = this_month')) {
          if(results.get('total_payments')!=null)
            private_refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = last_month')) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = this_year')) {
          if(results.get('total_payments')!=null)
            private_refunded.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = this_quarter')) {
          if(results.get('total_payments')!=null)
            private_refunded.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = ' + yesterday_filter)) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_day = (Decimal)results.get('total_payments') * -1;
        }

          }
          if(action=='user') {
                for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_month and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = last_month and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_year and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_refunded.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_quarter and parent_owner__c in  : user_filters]) {
          if(results.get('total_payments')!=null)
            private_refunded.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = ' + yesterday_filter + ' and parent_owner__c in  : user_filters')) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_day = (Decimal)results.get('total_payments') * -1;
        }
          }
          if(action=='center') {
                for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_month and center_id__c =  :center_id]) {
          if(results.get('total_payments')!=null)
            private_refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = last_month and center_id__c =  : center_id]) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_year and center_id__c =  : center_id]) {
          if(results.get('total_payments')!=null)
            private_refunded.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_quarter and center_id__c =  : center_id]) {
          if(results.get('total_payments')!=null)
            private_refunded.QTD = (Decimal)results.get('total_payments') * -1;
        }
                for(AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = ' + yesterday_filter + ' and center_id__c =  : center_id')) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_day = (Decimal)results.get('total_payments') * -1;
        }
          }
          if(action=='region') {
                for(AggregateResult results : database.query('select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = \'refunded\' and payment_date__c = ' + yesterday_filter + ' and (opportunity__r.account.center__r.sales_region__c = :sales_region or private_practice_patient__r.center__r.sales_region__c = :sales_region)')) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_day = (Decimal)results.get('total_payments');
        }
                for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_quarter and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_refunded.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_year and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_refunded.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = this_month and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_refunded.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for(AggregateResult results : [select sum(net_collection_amount__c) total_payments from private_practice_payment__c where payment_status_formula__c = 'refunded'
                  and payment_date__c = last_month and (opportunity__r.account.center__r.sales_region__c = :sales_region  or private_practice_patient__r.center__r.sales_region__c = :sales_region)]) {
          if(results.get('total_payments')!=null)
            private_refunded.previous_month = (Decimal)results.get('total_payments') * -1;
        }
          }
        }
        return private_refunded;
  }

  public DisplayDollars getRefunded() {
    if(refunded==null) {
      refunded = new DisplayDollars();
      gp_refunded_fees = new DisplayDollars();
      if(action=='all') {
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status__c = 'Refund' and payment_date__c = last_year]) {
          if(results.get('total_payments')==null)
            refunded.last_year = 0;
          else
            refunded.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = this_month')) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.MTD = 0;
          else
            gp_refunded_fees.MTD = (Decimal)results.get('total_gp_fee');
        }
        /*for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where payment_status__c = \'Refund\' and payment_date__c = LAST_QUARTER')) {
          if(results.get('total_payments')==null)
            refunded.last_90 = 0;
          else
            refunded.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = LAST_MONTH')) {
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
           if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_month = 0;
          else
            gp_refunded_fees.previous_month = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = this_year')) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1;
           if(results.get('total_gp_fee')==null)
            gp_refunded_fees.YTD = 0;
          else
            gp_refunded_fees.YTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where payment_status_formula__c = \'Refunded\' and payment_date__c = this_quarter')) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.QTD = 0;
          else
            gp_refunded_fees.QTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + yesterday_filter)) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_day = 0;
          else
            gp_refunded_fees.previous_day = (Decimal)results.get('total_gp_fee');
        }
      }
      else if(action=='user') {
        /*modified by cm on 2015-06-19
        changing payment ownership to the pec__c field in the table.
        old filter = and opportunity__c in (select id from opportunity where ownerid in : user_filters)
        new filter = and pec__c in :user_filters
        */
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status__c = 'Refund' and payment_date__c = last_year and opportunity__c in
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.last_year = 0;
          else
            refunded.last_year = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_month and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.MTD = 0;
          else
            gp_refunded_fees.MTD = (Decimal)results.get('total_gp_fee');
        }
        /*        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status__c = 'Refund' and payment_date__c = LAST_QUARTER and opportunity__c in
          (select id from opportunity where ownerid in : user_filters)]) {
          if(results.get('total_payments')==null)
            refunded.last_90 = 0;
          else
            refunded.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = LAST_MONTH and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_month = 0;
          else
            gp_refunded_fees.previous_month = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_year and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.YTD = 0;
          else
            gp_refunded_fees.YTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_quarter and pec__c in :user_filters]) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.QTD = 0;
          else
            gp_refunded_fees.QTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + yesterday_filter + ' and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_day = 0;
          else
            gp_refunded_fees.previous_day = (Decimal)results.get('total_gp_fee');
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
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_month and opportunity__r.account.center__c = :center_id]) {*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_month and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.MTD = 0;
          else
            gp_refunded_fees.MTD = (Decimal)results.get('total_gp_fee');
        }
        /*for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where
          payment_status__c = 'Refund' and payment_date__c = LAST_QUARTER and opportunity__r.account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.last_90 = 0;
          else
            refunded.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = LAST_MONTH and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_month = 0;
          else
            gp_refunded_fees.previous_month = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_year and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.YTD = 0;
          else
            gp_refunded_fees.YTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_quarter and opportunity__r.Roll_Up_Center__c = :center_id]) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.QTD = 0;
          else
            gp_refunded_fees.QTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + yesterday_filter + ' and opportunity__r.Roll_Up_Center__c = :center_id')) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_day = 0;
          else
            gp_refunded_fees.previous_day = (Decimal)results.get('total_gp_fee');
        }
      }
      else if(action=='region') {
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_month and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            refunded.MTD = 0;
          else
            refunded.MTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.MTD = 0;
          else
            gp_refunded_fees.MTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = LAST_MONTH and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            refunded.previous_month = 0;
          else
            refunded.previous_month = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_month = 0;
          else
            gp_refunded_fees.previous_month = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_year and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            refunded.YTD = 0;
          else
            refunded.YTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.YTD = 0;
          else
            gp_refunded_fees.YTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : [Select sum(net_collection_amount__c) total_payments ,sum(gp_fee_amount__c) total_gp_fee From CCPayment__c  where
          payment_status_formula__c = 'Refunded' and payment_date__c = this_quarter and opportunity__r.account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            refunded.QTD = 0;
          else
            refunded.QTD = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.QTD = 0;
          else
            gp_refunded_fees.QTD = (Decimal)results.get('total_gp_fee');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + yesterday_filter + ' and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            refunded.previous_day = 0;
          else
            refunded.previous_day = (Decimal)results.get('total_payments') * -1;
          if(results.get('total_gp_fee')==null)
            gp_refunded_fees.previous_day = 0;
          else
            gp_refunded_fees.previous_day = (Decimal)results.get('total_gp_fee');
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
        String anticipated_query_filter;
        if(anticipated_filter=='all')
          anticipated_query_filter = '(\'Anticipated\',\'HCF in Process\')';
        else if(anticipated_filter=='prom')
          anticipated_query_filter = '(\'Anticipated Promise Note\',\'Anticipated PPF\')';
        System.debug('Anticipated Filter : ' + anticipated_query_filter);

      anticipated_payments = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in ' + anticipated_query_filter + ' and payment_date__c = next_month')) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in ' + anticipated_query_filter + ' and payment_date__c = this_month')) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in ' + anticipated_query_filter + ' and payment_date__c > next_month')) {
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in ' + anticipated_query_filter + ' and payment_date__c > this_quarter')) {
          if(results.get('total_payments')==null)
            anticipated_payments.QTD = 0;
          else
            anticipated_payments.QTD = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='user') {
        /*modified by cm on 2015-06-19
        changing payment ownership to the pec__c field in the table.
        old filter = and opportunity__c in (select id from opportunity where ownerid in : user_filters)
        new filter = and pec__c in :user_filters
        */
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c = next_month and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
                                        //System.debug('Anticipated Filter : ' + anticipated_query_filter + ' anticipated_payment.last_year : ' + anticipated_payments.last_year);
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c = this_month and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
          //System.debug('Anticipated Filter : ' + anticipated_query_filter + ' anticipated_payment.MTD : ' + anticipated_payments.MTD);
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c > next_month and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
          //System.debug('Anticipated Filter : ' + anticipated_query_filter + ' anticipated_payment.YTD : ' + anticipated_payments.YTD);
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c > this_quarter and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            anticipated_payments.QTD = 0;
          else
            anticipated_payments.QTD = (Decimal)results.get('total_payments');
          //System.debug('Anticipated Filter : ' + anticipated_query_filter + ' anticipated_payment.QTD : ' + anticipated_payments.QTD);
        }
      }
      else if(action=='center') {
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and   opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c = next_month and opportunity__r.account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and   opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c = this_month and opportunity__r.account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and   opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c > next_month and opportunity__r.account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and   opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c > this_quarter and opportunity__r.account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            anticipated_payments.QTD = 0;
          else
            anticipated_payments.QTD = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='region') {
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter +  ' and payment_date__c = next_month and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            anticipated_payments.last_year = 0;
          else
            anticipated_payments.last_year = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter +  ' and payment_date__c = this_month and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            anticipated_payments.MTD = 0;
          else
            anticipated_payments.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter +  ' and payment_date__c > next_month and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            anticipated_payments.YTD = 0;
          else
            anticipated_payments.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
          ' payment_status__c in ' + anticipated_query_filter +  ' and payment_date__c > this_quarter and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
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
    String anticipated_query_filter;
    if(anticipated_filter=='all')
      anticipated_query_filter = '(\'Anticipated\',\'HCF in Process\')';
    else if(anticipated_filter=='prom')
        anticipated_query_filter = '(\'Anticipated Promise Note\',\'Anticipated PPF\')';
    if(action=='all') {
      for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c where opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and payment_status__c in ' + anticipated_query_filter + ' and payment_date__c < today')) {
        if(results.get('total_payments')==null)
          my_holder = 0.00;
        else
          my_holder = (Decimal)results.get('total_payments');
      }
    }
    else if(action=='user') {
    /*modified by cm on 2015-06-19
        changing payment ownership to the pec__c field in the table.
        old filter = and opportunity__c in (select id from opportunity where ownerid in : user_filters)
        new filter = and pec__c in :user_filters
        */
      for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and ' +
                                ' opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
        ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c < today and pec__c in :user_filters')) {
        if(results.get('total_payments')==null)
          my_holder = 0.00;
        else
          my_holder = (Decimal)results.get('total_payments');
      }
    }
    else if(action=='center') {
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and ' +
                                ' opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
        ' payment_status__c in ' + anticipated_query_filter + ' and payment_date__c < today and opportunity__r.account.center__c = :center_id')) {
        if(results.get('total_payments')==null)
          my_holder = 0.00;
        else
          my_holder = (Decimal)results.get('total_payments');
      }
    }
    else if(action=='region') {
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
                ' opportunity__r.stagename <> \'Cancelled Not Rescheduled\' and ' +
                                ' opportunity__r.Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\') and ' +
        'payment_status__c in ' + anticipated_query_filter + ' and payment_date__c < today and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
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
      System.debug('Pipeline');
      if(action=='all') {
        pipeline.MTD = database.countQuery('select count() from account a where center__r.type__c not in (\'Affiliate\',\'Network Center\') and a.consult_result__c = \'30 Day Pipeline\'  ' + all_filter);
        pipeline.last_90 = database.countQuery('select count() from account a where center__r.type__c not in (\'Affiliate\',\'Network Center\') and a.consult_result__c = \'60 Day Pipeline\'  ' + all_filter);
        pipeline.YTD = database.countQuery('select count() from account a where center__r.type__c not in (\'Affiliate\',\'Network Center\') and a.consult_result__c = \'90 Day Pipeline\'  ' + all_filter);
        pipeline.QTD = database.countQuery('select count() from account a where center__r.type__c not in (\'Affiliate\',\'Network Center\') and a.consult_result__c = \'2nd Consult\'  ' + all_filter);

        //breaking this out due to query size
        /*for(AggregateResult result : database.query('select a.consult_result__c,count(id) num_records from account a where center__r.type__c not in (\'Affiliate\',\'Network Center\') and a.consult_result__c in (\'30 Day Pipeline\',\'60 Day Pipeline\',\'90 Day Pipeline\',\'2nd Consult\') group by a.consult_result__c ' + all_filter)) {
                if(result.get('consult_result__c')=='30 Day Pipeline')
                  pipeline.MTD = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='60 Day Pipeline')
                  pipeline.last_90 = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='90 Day Pipeline')
                  pipeline.YTD = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='2nd Consult')
                  pipeline.QTD = Integer.valueof(result.get('num_records'));
        }*/
        //pipeline.last_year = [select count() from account where createddate = LAST_YEAR and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        /*pipeline.MTD = [select count() from account a where a.consult_result__c = '30 Day Pipeline'];
        pipeline.last_90 = [select count() from account a where a.consult_result__c = '60 Day Pipeline'];
        pipeline.YTD = [select count() from account a where a.consult_result__c = '90 Day Pipeline'];
        pipeline.QTD = [select count() from account a where a.consult_result__c = '2nd Consult'];*/
      }
      else if(action=='user') {
        //pipeline.last_year  = [select count() from account where createddate = LAST_YEAR and ownerid in : user_filters and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        //System.debug('Query : select count() from account a where a.ownerid in : user_filters and a.consult_result__c = \'30 Day Pipeline\'');
        //System.debug(user_filters);
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
        /*        pipeline.MTD = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '30 Day Pipeline'];
        pipeline.last_90 = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '60 Day Pipeline'];
        pipeline.YTD = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '90 Day Pipeline'];
        pipeline.QTD = [select count() from account a where a.ownerid in : user_filters and a.consult_result__c = '2nd Consult'];*/
      }
      else if(action=='center'){
        //pipeline.last_year  = [select count() from account where createddate = LAST_YEAR and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        for(AggregateResult result : [select a.consult_result__c,count(id) num_records from account a where center__c = : center_id and a.consult_result__c in ('30 Day Pipeline','60 Day Pipeline','90 Day Pipeline','2nd Consult') group by a.consult_result__c]) {
                if(result.get('consult_result__c')=='30 Day Pipeline')
                  pipeline.MTD = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='60 Day Pipeline')
                  pipeline.last_90 = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='90 Day Pipeline')
                  pipeline.YTD = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='2nd Consult')
                  pipeline.QTD = Integer.valueof(result.get('num_records'));
        }
        /*ipeline.MTD = [select count() from account a where center__c = : center_id and a.consult_result__c = '30 Day Pipeline'];
        pipeline.last_90 = [select count() from account a where center__c = :center_id and a.consult_result__c = '60 Day Pipeline'];
        pipeline.YTD = [select count() from account a where center__c = :center_id and a.consult_result__c = '90 Day Pipeline'];
        pipeline.QTD = [select count() from account a where center__c = :center_id and a.consult_result__c = '2nd Consult'];*/
      }
      else if(action=='region'){
        //pipeline.last_year  = [select count() from account where createddate = LAST_YEAR and center__c = :center_id and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined')];
        pipeline.MTD = database.countQuery('select count() from account a where center__r.sales_region__c = :sales_region and a.consult_result__c = \'30 Day Pipeline\'');
        pipeline.last_90 = database.countQuery('select count() from account a where center__r.sales_region__c = :sales_region and a.consult_result__c = \'60 Day Pipeline\'');
        pipeline.YTD = database.countQuery('select count() from account a where center__r.sales_region__c = :sales_region and a.consult_result__c = \'90 Day Pipeline\'');
        pipeline.QTD = database.countQuery('select count() from account a where center__r.sales_region__c = :sales_region and a.consult_result__c = \'2nd Consult\'');
        /*for(AggregateResult result : [select count(id) num_records from account a where center__r.sales_region__c = :sales_region and a.consult_result__c in ('30 Day Pipeline','60 Day Pipeline','90 Day Pipeline','2nd Consult') group by a.consult_result__c]) {
                if(result.get('consult_result__c')=='30 Day Pipeline')
                  pipeline.MTD = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='60 Day Pipeline')
                  pipeline.last_90 = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='90 Day Pipeline')
                  pipeline.YTD = Integer.valueof(result.get('num_records'));
                if(result.get('consult_result__c')=='2nd Consult')
                  pipeline.QTD = Integer.valueof(result.get('num_records'));
        }*/
      }
    }
    return pipeline;
  }

  public DisplayDollars getUpsellSold() {
      // AW - 2016-08-30 - Per Scott L, adding is_Requirement_Met__c = true to maintain consistency with recent changes to the main portion of the report (above)
    if(upsell_sold==null) {
      upsell_sold = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_month AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\')' )) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = LAST_MONTH AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\')' )) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_year AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\')' )) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_quarter AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\')' )) {
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\') AND closedate = ' + yesterday_filter )) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='user'){
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_month AND ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = LAST_MONTH AND ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_year AND ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_quarter AND ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = ' + yesterday_filter + ' AND ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='center') {
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_month AND account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = LAST_MONTH AND account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_year AND account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_quarter AND account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = ' + yesterday_filter + ' AND account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
      else if(action=='region') {
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_month AND account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_sold.MTD = 0;
          else
            upsell_sold.MTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = LAST_MONTH AND account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_month = 0;
          else
            upsell_sold.previous_month = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_year AND account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_sold.YTD = 0;
          else
            upsell_sold.YTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : [SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = this_quarter AND account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_sold.QTD = 0;
          else
            upsell_sold.QTD = (Decimal)results.get('total_payments');
        }
        for (AggregateResult results : database.query('SELECT sum(additional_treatment_amount__c) total_payments FROM Opportunity WHERE is_Requirement_Met__c = true AND closedate = ' + yesterday_filter + ' AND account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            upsell_sold.previous_day = 0;
          else
            upsell_sold.previous_day = (Decimal)results.get('total_payments');
        }
      }
    }
    return upsell_sold;
  }

  // AW - 2016-08-30 - Per Scott L, adding is_Requirement_Met__c = true to maintain consistency with recent changes to the main portion of the report (above)
  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public DisplayDollars getUpsellCancelledIn() {
    if(upsell_cancelled_in==null) {
      upsell_cancelled_in = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\') AND Prosth_Exam_Paid_Date__c = this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c = last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c = last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c = this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c = this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' )) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c = ' + yesterday_filter + ' and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='user') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and Current_Prosth_Owner__c in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='region') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c = this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.MTD = 0;
          else
            upsell_cancelled_in.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c = last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.last_90 = 0;
          else
            upsell_cancelled_in.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_month = 0;
          else
            upsell_cancelled_in.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c = this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.YTD = 0;
          else
            upsell_cancelled_in.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c = this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.QTD = 0;
          else
            upsell_cancelled_in.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c = ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in.previous_day = 0;
          else
            upsell_cancelled_in.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
    }
    return upsell_cancelled_in;
  }

  // AW - 2016-08-30 - Per Scott L, adding is_Requirement_Met__c = true to maintain consistency with recent changes to the main portion of the report (above)
  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public DisplayDollars getupsellCancelledOut() {
    if(upsell_cancelled_out==null) {
      upsell_cancelled_out = new DisplayDollars();
      if(action=='all') {
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> this_month  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c <> last_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.last_90 = 0;
          else
            upsell_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> last_month and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> this_year and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_day = 0;
          else
            upsell_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='user') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and ownerid in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.last_90 = 0;
          else
            upsell_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : user_filters]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and Current_Prosth_Owner__c in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_day = 0;
          else
            upsell_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='center') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        /*for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_QUARTER and Prosth_Exam_Paid_Date__c <> last_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.last_90 = 0;
          else
            upsell_cancelled_out.last_90 = (Decimal)results.get('total_payments') * -1;
        }*/
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c = :center_id]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_day = 0;
          else
            upsell_cancelled_out.previous_day = (Decimal)results.get('total_payments') * -1;
        }
      }
      else if(action=='region') {
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_month and Prosth_Exam_Paid_Date__c <> this_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.MTD = 0;
          else
            upsell_cancelled_out.MTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = LAST_MONTH and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.previous_month = 0;
          else
            upsell_cancelled_out.previous_month = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_year and Prosth_Exam_Paid_Date__c <> this_year and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.YTD = 0;
          else
            upsell_cancelled_out.YTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : [select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = this_quarter and Prosth_Exam_Paid_Date__c <> this_quarter and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__r.sales_region__c = :sales_region]) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out.QTD = 0;
          else
            upsell_cancelled_out.QTD = (Decimal)results.get('total_payments') * -1;
        }
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c = ' + yesterday_filter + ' and Prosth_Exam_Paid_Date__c <> ' + yesterday_filter + ' and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_region__c = :sales_region')) {
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
        /*List<Report> r = [Select id From Report r where developername = 'Unconverted_Consults'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('Unconverted_Consults');
  }

  public String getconsult_reportid() {
        /*List<Report> r = [Select id,developername From Report r where developername = 'Consults_w_Fields_to_Update'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('Consults_w_Fields_to_Update');
  }

  public String getprost_reportid() {
        /*List<Report> r = [select id,name,developername from report where developername = 'Pes_to_Update_Dashboard'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('Pes_to_Update_Dashboard');
  }

  public String getprost_payment_reportid() {
        /*List<Report> r = [select id,name,developername from report where developername = 'Prosth_Exams_with_No_Payments'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('Prosth_Exams_with_No_Payments');
  }

  public String getunconverted_reportid() {
        /*List<Report> r = [select id,name,developername from report where developername = 'New_Unconverted_Consults'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('New_Unconverted_Consults');
  }

  public String getupdate_payment_reportid() {
        /*List<Report> r = [select id,name,developername from report where developername = 'Payments_To_Update'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('Payments_To_Update');
  }

  public String getarrangement_reportid() {
        /*List<Report> r = [select id,name,developername from report where developername = 'Payment_Arrangements_Made_Past_Due'];
        if(r.size()==0)
          return '';
        else
          return String.valueOf(r[0].id);*/
        return report_mapping.get('Payment_Arrangements_Made_Past_Due');
  }

  public String getlead_exceptions() {

        String return_val = '';
        if(action=='all') {
                Integer I = [select count() from Consult_Inventory__c
          where apt_date__c >= 2012-08-01 and apt_date__c < today and consult_show_status__c in  ('Consult Completed','Arrived','Ready for Consult','Consult Started')
          and scheduled_lead__c != null and scheduled_lead__r.isconverted = false and consult_room__r.room_type__c != 'Practice' and consult_room__r.center_information__r.type__c not in ('Affiliate','Network Center')];
          //updating this to be an accurate count
                //Integer I = [select count() from lead l where l.status in ('Consult Completed','Consultation Scheduled','Consult Scheduled','Rescheduled Consult') and datetime_consult_scheduled__c < today and l.convertedcontactid = null and datetime_consult_scheduled__c >= last_month];
                return_val = String.valueOf(I);
        }
        else if(action=='center') {
                Integer I = [select count() from Consult_Inventory__c
          where apt_date__c >= 2012-08-01 and apt_date__c < today and consult_show_status__c in
          ('Consult Completed','Arrived','Ready for Consult','Consult Started') and consult_room__r.room_type__c != 'Practice' and scheduled_lead__c != null
          and scheduled_lead__r.isconverted = false and consult_room__r.center_information__c =:center_id];
                //Integer I = [select count() from lead l where l.status in ('Consult Completed','Consultation Scheduled','Consult Scheduled','Rescheduled Consult') and datetime_consult_scheduled__c < today and l.convertedcontactid = null and datetime_consult_scheduled__c >= last_month and l.center__c = :center_id];
                return_val = String.valueOf(I);
        }
        else if(action=='region') {
                Integer I = [select count() from Consult_Inventory__c
          where apt_date__c >= 2012-08-01 and apt_date__c < today and consult_show_status__c in
          ('Consult Completed','Arrived','Ready for Consult','Consult Started') and consult_room__r.room_type__c != 'Practice' and scheduled_lead__c != null
          and scheduled_lead__r.isconverted = false and consult_room__r.center_information__r.sales_region__c =:sales_region];
                //Integer I = [select count() from lead l where l.status in ('Consult Completed','Consultation Scheduled','Consult Scheduled','Rescheduled Consult') and datetime_consult_scheduled__c < today and l.convertedcontactid = null and datetime_consult_scheduled__c >= last_month and l.center__c = :center_id];
                return_val = String.valueOf(I);
        }
        else if(action=='user')
          return_val = '<span style="font-style:italic;font-weight:bold;">N/A</span>';
        return return_val;
  }

  public Integer getconsult_exceptions() {
        Integer return_val = 0;
        if(action=='all')
                return_val = [Select count() from account a where a.consult_result__c = null and a.createddate >= last_month and center__r.type__c not in ('Affiliate','Network Center')];
        else if(action=='center')
                return_val = [Select count() from account a where a.center__c = :center_id and a.consult_result__c = null and a.createddate >= last_month ];
     else if(action=='region')
                return_val = [Select count() from account a where a.center__r.sales_region__c = :sales_region and a.consult_result__c = null and a.createddate >= last_month ];
        else if(action=='user')
                return_val = [Select count() from account a where a.ownerid in : user_filters and a.consult_result__c = null and a.createddate >= last_month];
        return return_val;
  }

  public Integer getprost_exceptions() {
    Integer return_val = 0;
    if(action=='all')
                return_val = [select count() from opportunity o where o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' and account.center__r.type__c not in ('Affiliate','Network Center')];
        else if(action=='center')
                return_val = [select count() from opportunity o where o.account.center__c = :center_id and o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' ];
        else if(action=='region')
                return_val = [select count() from opportunity o where o.account.center__r.sales_region__c = :sales_region and o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' ];
        else if(action=='user')
                return_val = [select count() from opportunity o where o.ownerid in : user_filters and o.closedate < today and o.closedate >= last_month and stagename = 'Scheduled' ];
        return return_val;
  }

  public Integer getprost_payment_exceptions() {
        Integer return_val = 0;
        if(action=='all')
          return_val = [select count() from opportunity o where  o.closedate = this_month and o.total_payments__c <= 0 and account.center__r.type__c not in ('Affiliate','Network Center') and o.anticipated_payments__c <= 0 and o.stagename <> 'Cancelled Not Rescheduled' and
        o.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        else if(action=='center')
          return_val = [select count() from opportunity o where o.account.center__c = :center_id and o.closedate = this_month and o.total_payments__c <= 0 and o.anticipated_payments__c <= 0 and o.stagename <> 'Cancelled Not Rescheduled' and
        o.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        else if(action=='region')
          return_val = [select count() from opportunity o where o.account.center__r.sales_region__c = :sales_region and o.closedate = this_month and o.total_payments__c <= 0 and o.anticipated_payments__c <= 0 and o.stagename <> 'Cancelled Not Rescheduled' and
        o.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        else if(action=='user')
                  return_val = [select count() from opportunity o where o.ownerid in : user_filters and o.closedate = this_month and o.total_payments__c <= 0 and o.anticipated_payments__c <= 0 and o.stagename <> 'Cancelled Not Rescheduled' and
        o.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        return return_val;
  }

  public Decimal getupdate_payment_exceptions() {
        AggregateResult ar = null;
        Set<String> refund_options = new Set<String>{'Refund Cash','Refund Check','Refund CreditCard','Refund MedChoice','Refund Citi','Refund CareCredit','Refund Springstone','Refund Alphaeon'};
        if(action=='all')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c
            where opportunity__r.closedate >= last_month and opportunity__r.closedate < today
            and payment_date__c < today
            and Payment_Status__c in ('Anticipated','Anticipated Promise Note','Anticipated PPF')
            and Payment_Type__c not in :refund_options
            and opportunity__r.stagename <> 'Cancelled Not Rescheduled'
            and opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        else if(action=='center')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c
            where opportunity__r.account.center__c = :center_id
            and opportunity__r.closedate >= last_month and opportunity__r.closedate < today
            and payment_date__c < today
            and Payment_Status__c in ('Anticipated','Anticipated Promise Note','Anticipated PPF')
            and Payment_Type__c not in :refund_options
            and opportunity__r.stagename <> 'Cancelled Not Rescheduled'
            and opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        else if(action=='region')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c
            where opportunity__r.account.center__r.sales_region__c = :sales_region
            and opportunity__r.closedate >= last_month and opportunity__r.closedate < today
            and payment_date__c < today
            and Payment_Status__c in ('Anticipated','Anticipated Promise Note','Anticipated PPF')
            and Payment_Type__c not in :refund_options
            and opportunity__r.stagename <> 'Cancelled Not Rescheduled'
            and opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
        else if(action=='user')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c
            where opportunity__r.ownerid in : user_filters
            and opportunity__r.closedate >= last_month and opportunity__r.closedate < today
            and payment_date__c < today
            and Payment_Status__c in ('Anticipated','Anticipated Promise Note','Anticipated PPF')
            and Payment_Type__c not in :refund_options
            and opportunity__r.stagename <> 'Cancelled Not Rescheduled'
            and opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case')];
    if(ar==null)
      return 0.00;
    else
          return (Decimal)ar.get('total_payments');
  }

  public Decimal getarrangement_exceptions() {
        AggregateResult ar = null;
        if(action=='all')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c where
            payment_date__c >= last_year and
        opportunity__r.stagename = 'Completed' and
        opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case') and
        payment_status__c = 'Anticipated' and payment_date__c < today];
        else if(action=='center')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c where opportunity__r.account.center__c = :center_id and
            payment_date__c >= last_year and
        opportunity__r.stagename = 'Completed' and
        opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case') and
        payment_status__c = 'Anticipated' and payment_date__c < today];
        else if(action=='region')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c where opportunity__r.account.center__r.sales_region__c = :sales_region and
            payment_date__c >= last_year and
        opportunity__r.stagename = 'Completed' and
        opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case') and
        payment_status__c = 'Anticipated' and payment_date__c < today];
        else if(action=='user')
          ar = [select sum(payment_amount__c) total_payments from ccpayment__c where opportunity__r.ownerid in : user_filters and
            payment_date__c >= last_year and
        opportunity__r.stagename = 'Completed' and
        opportunity__r.Completed_Stage__c not in ('Financing Difficulty','Patient Non Responsive','Not Moving Forward','Non Candidate','Doctor Declined Case') and
        payment_status__c = 'Anticipated' and payment_date__c < today];
                if(ar==null)
      return 0.00;
    else
          return (Decimal)ar.get('total_payments');
  }

  public DisplayDecimal gettrue_closerate() {
        gettreatmentsold();
        gettreatmentcancelled();
        if(true_closerate==null) {
                true_closerate = new DisplayDecimal();
    try {
      if(treatment_sold.previous_day + treatment_cancelled.previous_day==0)
        true_closerate.previous_day = 0;
      else {
        true_closerate.previous_day = (Collected.previous_day + Refunded.previous_day)/(treatment_sold.previous_day + treatment_cancelled.previous_day) * 100;
        true_closerate.previous_day = true_closerate.previous_day.divide(1,1);
      }
      /*      if(treatment_sold.last_year + treatment_cancelled.last_year==0)
        true_closerate.last_year = 0;
      else {
        true_closerate.last_year = (Collected.last_year + Refunded.last_year)/(treatment_sold.last_year + treatment_cancelled.last_year) * 100;
        true_closerate.last_year = true_closerate.last_year.divide(1,1);
      }*/
      if(treatment_sold.MTD + treatment_cancelled.MTD==0)
        true_closerate.MTD = 0;
      else {
        true_closerate.MTD = (Collected.MTD==null?0.00:Collected.MTD + Refunded.MTD==null?0.00:Refunded.MTD)/(treatment_sold.MTD + treatment_cancelled.MTD) * 100;
        true_closerate.MTD = true_closerate.MTD.divide(1,1);
      }
      /*if(treatment_sold.last_90 + treatment_cancelled.last_90==0)
        true_closerate.last_90 = 0;
      else {
        true_closerate.last_90 = (Collected.last_90 + Refunded.last_90)/(treatment_sold.last_90 + treatment_cancelled.last_90) * 100;
        true_closerate.last_90 = true_closerate.last_90.divide(1,1);
      } */
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
    catch(Exception e) {
      true_closerate.QTD = 0;
      true_closerate.MTD = 0;
      true_closerate.YTD = 0;
      true_closerate.previous_month = 0;
      true_closerate.previous_day = 0;
    }
        }
        return true_closerate;
  }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c for numbers related to revenue (sold, cancelled in, cancelled out)
  public String snapshot_metrics_user() {
        Integer lyear = date.today().year();
        Integer lmonth = date.today().month();
        if(lmonth==1) {
                lmonth = 12;
                lyear = lyear - 1;
        }
        else
          lmonth = lmonth - 1;

         //wipe any existing records in the table
        list<User_Goals__c> goal_list = [Select id from User_Goals__c u where u.fiscal_month__c = :lmonth and u.fiscal_year__c = :lyear ];
        delete goal_list;

        //figure out who needs a record for this time period
        List<User> missing_list = [select id,name,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,goal_type__c,center_pec__c,baseline_target__c from user where goal_type__c in ('Center','User') or center_pec__c <> null];
        List<User_Goals__c> ug_missing = new List<User_Goals__c>();
        for(User u : missing_list) {
          //create a user_goals__c record for each user
          User_Goals__c new_budget = new User_Goals__c(fiscal_month__c = lmonth, fiscal_year__c = lyear, user__c = u.id, sales_goal__c = 0, consults__c = 0);
          ug_missing.add(new_budget);
        }

        //insert the list if we did have missing members,  and then repull our list of records.  Redo Map and Set
        if(ug_missing.size()>0) {
          insert ug_missing;
        }


        goal_list = [Select u.Baseline_Target__c,u.goal_type__c,u.tier_1_floor__c,u.tier_2_floor__c,u.tier_3_floor__c,u.User__c, u.Financed_Consults__c,u.Target_Dollars__c, u.SystemModstamp, u.Starts__c, u.Sold__c, u.Sales_Goal__c, u.Refunded_Dollars__c, u.OwnerId, u.Name, u.LastModifiedDate, u.LastModifiedById, u.IsDeleted, u.Id, u.Fiscal_Year__c, u.Fiscal_Month__c, u.CreatedDate, u.CreatedById, u.Consults__c, u.Collected_Dollars__c, u.Cancelled_Starts_Out__c, u.Cancelled_Starts_In__c, u.Cancelled_Dollars_Out__c, u.Cancelled_Dollars_In__c From User_Goals__c u where (u.user__r.center_pec__c <> null or u.user__r.center_pec__c <> '') and u.fiscal_month__c = :lmonth and u.fiscal_year__c = :lyear and user__r.isactive = true];
        Map<ID,user_goals__c> goal_map = new Map<Id,user_goals__c> {};
        Set<ID> pec_ids = new Set<ID> ();
        for(User_Goals__c goal : goal_list) {
                goal_map.put(goal.user__c,goal);
                pec_ids.add(goal.user__c);
        }


        //grab tiers & goal type
        for(User u : [select id,name,tier_1_floor__c,tier_2_floor__c,tier_3_floor__c,goal_type__c,center_pec__c,Baseline_Target__c from user where id in : pec_ids]) {
          goal_map.get(u.id).goal_type__c = u.goal_type__c;
          if(u.goal_type__c=='user') {
                //store the user tiers
                goal_map.get(u.id).tier_1_floor__c = u.tier_1_floor__c;
                goal_map.get(u.id).tier_2_floor__c = u.tier_2_floor__c;
                goal_map.get(u.id).tier_3_floor__c = u.tier_3_floor__c;
                goal_map.get(u.id).Baseline_Target__c = u.baseline_target__c;
          }
          else {
                //store the center tiers
                try {
                        goal_map.get(u.id).tier_1_floor__c = all_centers_map.get(u.center_pec__c).tier_1_floor__c;
                        goal_map.get(u.id).tier_2_floor__c = all_centers_map.get(u.center_pec__c).tier_2_floor__c;
                        goal_map.get(u.id).tier_3_floor__c = all_centers_map.get(u.center_pec__c).tier_3_floor__c;
                        goal_map.get(u.id).baseline_target__c = all_centers_map.get(u.center_pec__c).baseline_target__c;
                } catch(Exception e) {
                        goal_map.get(u.id).tier_1_floor__c = 0;
                        goal_map.get(u.id).tier_2_floor__c = 0;
                        goal_map.get(u.id).tier_3_floor__c = 0;
                        goal_map.get(u.id).baseline_target__c = 0;
                }
          }
        }

        //grab consults
        /*
        modified by cm on 3-30-2015
        Adjusting this to reflect the changes going live on 4-1 and fixing the old query that wasn't counting properly regardless
        */
        /*for(AggregateResult ar : [select ownerid,count(id) num_starts from account where createddate = LAST_MONTH and ownerid in : pec_ids group by ownerid]) {
                String my_ownerid = string.valueof(ar.get('ownerid'));
          goal_map.get(my_ownerid).Consults__c = Integer.valueOf(ar.get('num_starts'));
        }*/
        //pre 4-1 path - 2 queries - one for scheduled lead,  one for scheduled account
        for(AggregateResult ar : [select scheduled_lead__r.convertedaccount.ownerid owner,count(id) num_consult from Consult_Inventory__c c
          where c.apt_date__c = last_month and active__c=true and arrival_time__c != null and consult_room__r.room_type__c != 'Practice' and scheduled_lead__c != null and scheduled_lead__r.convertedaccount.ownerid in :pec_ids
          group by scheduled_lead__r.convertedaccount.ownerid]) {
          String my_ownerid = string.valueof(ar.get('owner'));
          goal_map.get(my_ownerid).Consults__c = Integer.valueOf(ar.get('num_consult'));
        }

        for(AggregateResult ar : [select scheduled_account__r.ownerid owner,count(id) num_consult from Consult_Inventory__c c
          where c.apt_date__c = last_month and active__c=true and arrival_time__c != null and consult_room__r.room_type__c != 'Practice' and scheduled_account__c != null and scheduled_account__r.ownerid in :pec_ids
          group by scheduled_account__r.ownerid]) {
          String my_ownerid = string.valueof(ar.get('owner'));
          goal_map.get(my_ownerid).Consults__c += Integer.valueOf(ar.get('num_consult'));
        }

        //for 4-1-2015 forward - will go live after we finish recording the final 3/2015 snapshot.
        /*for(AggregateResult ar : [select consult_pec__c,count(id) num_consult from Consult_Inventory__c c
          where c.apt_date__c = last_month and active__c=true and arrival_time__c != null and consult_pec__c in :pec_ids
          group by consult_pec__c]) {
          String my_ownerid = string.valueof(ar.get('consult_pec__c'));
          goal_map.get(my_ownerid).Consults__c = Integer.valueOf(ar.get('num_consult'));
        }*/


        //grab financed consults
        for(AggregateResult ar : [select ownerid,count(id) num_starts from account where createddate = LAST_MONTH and ownerid in : pec_ids and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined') group by ownerid]) {
                String my_ownerid = string.valueof(ar.get('ownerid'));
      goal_map.get(my_ownerid).Financed_Consults__c = Integer.valueOf(ar.get('num_starts'));
        }
        /*
          modified by cm on 2014-12-18
          Adjusting the next few lines (starts,  cancelled starts in, cancelled starts out) to account for the changes in our start definition
          modified by aw on 2016-06-20
          Adhering to new start definition, which requires a Treatment Option be connected to the Opportunity, switching 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' to 'is_Valid_Start__c = true' which now incorporates this requirement
          Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
        */
        //grab starts
        for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) starts_value from opportunity where is_Valid_Start__c = true and prosth_exam_paid_date__c = LAST_MONTH and ownerid in : pec_ids group by ownerid]) {
                String my_ownerid = string.valueof(ar.get('ownerid'));
                goal_map.get(my_ownerid).Starts__c = aggregate_value(ar, 'starts_value');
        }
        //grab cancelled starts in
        /*modified by cm on 2015-6-4
          changing definition to remove the in period cancellation loop hole
          old filter - cancel_reason__c != null
        */
        for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) cancelled_value from opportunity where is_Valid_Start__c = true and Cancel_Date__c = last_month and prosth_exam_paid_date__c = last_month
        and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
                String my_ownerid = string.valueof(ar.get('ownerid'));
                goal_map.get(my_ownerid).Cancelled_Starts_In__c = aggregate_value(ar, 'cancelled_value');
        }
        //grab cancelled starts out
        for(AggregateResult ar : [select ownerid, SUM(Start_Value__c) cancelled_value from opportunity where is_Valid_Start__c = true and Cancel_Date__c = last_month and prosth_exam_paid_date__c <> last_month
        and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
                String my_ownerid = string.valueof(ar.get('ownerid'));
                goal_map.get(my_ownerid).Cancelled_Starts_Out__c = aggregate_value(ar, 'cancelled_value');
        }
        //grab sold
        for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity where Prosth_Exam_Paid_Date__c = last_month and ownerid in : pec_ids group by ownerid]) {
                String my_ownerid = string.valueof(ar.get('ownerid'));
                goal_map.get(my_ownerid).Sold__c = (Decimal)ar.get('total_payments');
        }
        //grab cancelled dollars in
    for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = last_month and Prosth_Exam_Paid_Date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))  and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
                  String my_ownerid = string.valueof(ar.get('ownerid'));
                  goal_map.get(my_ownerid).Cancelled_Dollars_In__c = (Decimal)ar.get('total_payments');
        }
        //grab cancelled dollars out
        for(AggregateResult ar : [select ownerid,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = last_month and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))  and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
          String my_ownerid = string.valueof(ar.get('ownerid'));
          if(goal_map.get(my_ownerid)!=null) {
                if(ar.get('total_payments')!=null)
              goal_map.get(my_ownerid).Cancelled_Dollars_Out__c = (Decimal)ar.get('total_payments');
          }
        }
        //grab collected dollars
    for (AggregateResult ar : [Select opportunity__r.ownerid owner,sum(net_collection_amount__c) total_payments, sum(gp_fee_amount__c) total_gp_fee From CCPayment__c where
        payment_status_formula__c = 'Collected' and payment_date__c = last_month and pec__c in : pec_ids group by opportunity__r.ownerid]) {
          String my_ownerid = string.valueof(ar.get('owner'));
          if(goal_map.get(my_ownerid)!=null) {
                  if(ar.get('total_payments')!=null)
                    goal_map.get(my_ownerid).Collected_Dollars__c = (Decimal)ar.get('total_payments');
                  if(ar.get('total_gp_fee')!=null)
                    goal_map.get(my_ownerid).GP_Collected_Fees__c = (Decimal)ar.get('total_gp_fee');
          }
        }
        //grab refunded dollars
    for (AggregateResult ar : [Select pec__c owner,sum(net_collection_amount__c) total_payments, sum(gp_fee_amount__c) total_gp_fee From CCPayment__c where
        payment_status_formula__c = 'Refunded' and payment_date__c = last_month and pec__c in : pec_ids group by pec__c]) {
        String my_ownerid = string.valueof(ar.get('owner'));
        goal_map.get(my_ownerid).Refunded_Dollars__c = (Decimal)ar.get('total_payments');
        if(ar.get('total_gp_fee')!=null)
          goal_map.get(my_ownerid).GP_Refunded_Fees__c = (Decimal)ar.get('total_gp_fee');
        }
        //calculate target dollars and target achieved
        for(User_Goals__c goal : goal_list) {
                if(goal.sales_goal__c<>null) {
                        if(goal.sales_goal__c > 0) {
                                System.debug('Sales Goal : ' + goal.sales_goal__c);
                    goal.target_dollars__c = goal.sales_goal__c;
                        }
                }
        }
        update goal_list;
        return null;
  }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c for numbers related to revenue (sold, cancelled in, cancelled out)
  public String snapshot_metrics_center() {
        Integer lyear = date.today().year();
        Integer lmonth = date.today().month();
        if(lmonth==1) {
                lmonth = 12;
                lyear = lyear - 1;
        }
        else
          lmonth = lmonth - 1;

        list<Center_Budget__c> goal_list = [Select c.tier_1_floor__c,c.tier_2_floor__c,c.tier_3_floor__c,c.Target_Rate__c, c.Target_Dollars__c, c.SystemModstamp, c.Starts__c, c.Sold__c, c.Sales_Goal__c, c.Refunded_Dollars__c, c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Fiscal_Year__c, c.Fiscal_Month__c, c.Financed_Consults__c, c.CreatedDate, c.CreatedById, c.Consults__c, c.Collected_Dollars__c, c.Center__c, c.Cancelled_Starts_Out__c, c.Cancelled_Starts_In__c, c.Cancelled_Dollars_Out__c, c.Cancelled_Dollars_In__c, c.Budgeted_Consults__c, c.Budgeted_Close_Rate__c From Center_Budget__c c where c.fiscal_month__c = :lmonth and c.fiscal_year__c = :lyear];
        System.debug('Goal List size : ' + goal_list.size());
        Map<ID,Center_Budget__c> goal_map = new Map<Id,Center_Budget__c> {};
        Set<ID> center_ids = new Set<ID> ();
        for(Center_Budget__c goal : goal_list) {
                goal_map.put(goal.center__c,goal);
                center_ids.add(goal.center__c);
        }
        //to-do - search for missing center goal records
        for(Center_Information__c ci : all_centers) {
          if(goal_map.get(ci.id)==null) {
                Center_Budget__c new_budget = new Center_Budget__c(fiscal_month__c = lmonth,fiscal_year__c = lyear,center__c = ci.id);
                goal_list.add(new_budget);
                goal_map.put(ci.id,new_budget);
                center_ids.add(ci.id);
          }
        }


        //update tiers
        for(Center_Information__c ci : all_centers) {
          if(ci.tier_1_floor__c!=null)
            goal_map.get(ci.id).tier_1_floor__c = ci.tier_1_floor__c;
          if(ci.tier_2_floor__c!=null)
            goal_map.get(ci.id).tier_2_floor__c = ci.tier_2_floor__c;
          if(ci.tier_3_floor__c!=null)
            goal_map.get(ci.id).tier_3_floor__c = ci.tier_3_floor__c;
        }


        //grab consults
        /*adjusted by com on 3-30-2015
        fixing this to take a proper count of consults
        */
        /*for(AggregateResult ar : [select center__c,count(id) num_starts from account where createddate = LAST_MONTH and center__c in : center_ids group by center__c]) {
          String my_center = string.valueof(ar.get('center__c'));
          goal_map.get(my_center).Consults__c = Integer.valueOf(ar.get('num_starts'));
        }*/
        for(AggregateResult ar : [select c.consult_room__r.center_information__c center,count(id) num_consults from Consult_Inventory__c c
          where c.apt_date__c = last_month and active__c=true and arrival_time__c != null and consult_room__r.room_type__c != 'Practice' group by c.consult_room__r.center_information__c]) {
          String my_center = string.valueof(ar.get('center'));
          goal_map.get(my_center).Consults__c = Integer.valueOf(ar.get('num_consults'));
        }

        //grab financed consults
        for(AggregateResult ar : [select center__c,count(id) num_starts from account where createddate = LAST_MONTH and center__c in : center_ids and financing_result__c in ('Approved Less Than 50%','Approved Greater or Equal to 50%','Approved Full Amount','Declined') group by center__c]) {
         String my_center = string.valueof(ar.get('center__c'));
         goal_map.get(my_center).Financed_Consults__c = Integer.valueOf(ar.get('num_starts'));
        }
        /*
          modified by cm on 2014-12-18
          Adjusting the next few lines (starts,  cancelled starts in, cancelled starts out) to account for the changes in our start definition
          modified by aw on 2016-06-20
          Adhering to new start definition, which requires a Treatment Option be connected to the Opportunity, switching 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' to 'is_Valid_Start__c = true' which now incorporates this requirement
          Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
        */
        //grab starts
        for(AggregateResult ar : [select account.center__c center, SUM(Start_Value__c) starts_value from opportunity where is_Valid_Start__c = true and prosth_exam_paid_date__c = LAST_MONTH and account.center__c in : center_ids group by account.center__c]) {
          String my_center = string.valueof(ar.get('center'));
          goal_map.get(my_center).Starts__c = aggregate_value(ar, 'starts_value');
        }
        //grab cancelled starts in
        for(AggregateResult ar : [select account.center__c center, SUM(Start_Value__c) cancelled_value from opportunity where is_Valid_Start__c = true and Cancel_Date__c = last_month and prosth_exam_paid_date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c in : center_ids group by account.center__c]) {
                String my_center = string.valueof(ar.get('center'));
        goal_map.get(my_center).Cancelled_Starts_In__c = aggregate_value(ar, 'cancelled_value');
        }
        //grab cancelled starts out
        for(AggregateResult ar : [select account.center__c center, SUM(Start_Value__c) cancelled_value from opportunity where is_Valid_Start__c = true and Cancel_Date__c = last_month and prosth_exam_paid_date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c in : center_ids group by account.center__c]) {
                String my_center = string.valueof(ar.get('center'));
      goal_map.get(my_center).Cancelled_Starts_Out__c = aggregate_value(ar, 'cancelled_value');
        }
        //grab sold
    for (AggregateResult results : [select account.center__c center,sum(negotiated_total_amount__c) total_payments from opportunity where Prosth_Exam_Paid_Date__c = last_month and account.center__c in : center_ids group by account.center__c]) {
                        String my_center = string.valueof(results.get('center'));
      goal_map.get(my_center).Sold__c = Integer.valueOf(results.get('total_payments'));
        }
        //grab cancelled dollars in
    for (AggregateResult results : [select account.center__c center,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = last_month and Prosth_Exam_Paid_Date__c = last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c in : center_ids group by account.center__c]) {
                        String my_center = string.valueof(results.get('center'));
      goal_map.get(my_center).Cancelled_Dollars_In__c = Integer.valueOf(results.get('total_payments'));
        }
        //grab cancelled dollars out
    for (AggregateResult results : [select account.center__c center,sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c = last_month and Prosth_Exam_Paid_Date__c <> last_month and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and account.center__c in : center_ids group by account.center__c]) {
                        String my_center = string.valueof(results.get('center'));
      goal_map.get(my_center).Cancelled_Dollars_Out__c = Integer.valueOf(results.get('total_payments'));
        }
        //grab collected dollars
    for (AggregateResult results : [Select opportunity__r.account.center__c center,sum(net_collection_amount__c) total_payments, sum(gp_fee_amount__c) total_gp_fee   From CCPayment__c  where
      payment_status_formula__c = 'Collected' and payment_date__c = last_month and opportunity__r.account.center__c in :center_ids group by opportunity__r.account.center__c]) {
                        String my_center = string.valueof(results.get('center'));
      goal_map.get(my_center).Collected_Dollars__c = Integer.valueOf(results.get('total_payments'));
      if(results.get('total_gp_fee')!=null)
        goal_map.get(my_center).GP_Collected_Fees__c = (Decimal)results.get('total_gp_fee');
    }
        //grab refunded dollars
    for (AggregateResult results : [Select opportunity__r.account.center__c center,sum(net_collection_amount__c) total_payments, sum(gp_fee_amount__c) total_gp_fee   From CCPayment__c  where
      payment_status_formula__c = 'Refunded' and payment_date__c = last_month and opportunity__r.account.center__c in :center_ids group by opportunity__r.account.center__c]) {
      String my_center = string.valueof(results.get('center'));
      goal_map.get(my_center).Refunded_Dollars__c = Integer.valueOf(results.get('total_payments'));
      if(results.get('total_gp_fee')!=null)
        goal_map.get(my_center).GP_Refund_Fees__c = (Decimal)results.get('total_gp_fee');
    }
        //calculate target dollars and target achieved
        for(Center_Budget__c goal : goal_list) {
                if(goal.sales_goal__c<>null) {
                        if(goal.sales_goal__c > 0) {
                                System.debug('Sales Goal : ' + goal.sales_goal__c);
                    goal.target_dollars__c = goal.sales_goal__c;
                        }
                }
        }
        upsert goal_list;

        return null;
  }

          private Decimal aggregate_value(AggregateResult aggregate, String fieldname) {
              return (aggregate.get(fieldname) != null) ? (Decimal)aggregate.get(fieldname) : 0;
          }

  public void display_hygiene_revenue() {
        display_hygiene = true;
  }

  public DisplayDollars getAO4_avg() {
    /*if(ao4_avg==null) {
      ao4_avg = new DisplayDollars();
      if(action=='all') {
        //starts.last_year  = [select count() from opportunity where createddate = LAST_YEAR];
        //and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))
        AggregateResult ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           'createddate = THIS_MONTH and (stagename != \'Cancelled Not Rescheduled\' ' +
           'and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.MTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.MTD = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           'createddate = LAST_MONTH and (stagename != \'Cancelled Not Rescheduled\' ' +
           'and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_month = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_month = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           'createddate = THIS_YEAR and (stagename != \'Cancelled Not Rescheduled\' ' +
           'and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.YTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.YTD = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           'createddate = THIS_QUARTER and (stagename != \'Cancelled Not Rescheduled\' ' +
           'and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.QTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.QTD = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           'createddate = ' + yesterday_filter + ' and (stagename != \'Cancelled Not Rescheduled\' ' +
           'and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_day = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_day = 0;
      }
      else if(action=='user'){
        AggregateResult ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_MONTH and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and ownerid in : user_filters];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.MTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.MTD = 0;
        ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = LAST_MONTH and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and ownerid in : user_filters];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_month = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_month = 0;
        ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_YEAR and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and ownerid in : user_filters];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.YTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.YTD = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_QUARTER and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and ownerid in : user_filters];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.QTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.QTD = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           ' createddate = ' + yesterday_filter + ' and (stagename != \'Cancelled Not Rescheduled\' ' +
           ' and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' +
           ' and ownerid in : user_filters');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_day = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_day = 0;
      }
      else if(action=='center') {
        AggregateResult ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_MONTH and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__c = :center_id];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.MTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.MTD = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = LAST_MONTH and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__c = :center_id];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_month = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_month = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_YEAR and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__c = :center_id];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.YTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.YTD = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_QUARTER and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__c = :center_id];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.QTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.QTD = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           ' createddate = ' + yesterday_filter + ' and (stagename != \'Cancelled Not Rescheduled\' ' +
           ' and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' +
           ' and account.center__c = :center_id');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_day = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_day = 0;
      }
      else if(action=='region') {
        AggregateResult ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_MONTH and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__r.sales_region__c = :sales_region];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.MTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.MTD = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = LAST_MONTH and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__r.sales_region__c = :sales_region];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_month = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_month = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_YEAR and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__r.sales_region__c = :sales_region];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.YTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.YTD = 0;
                                ar = [select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where
           createddate = THIS_QUARTER and
          (stagename != 'Cancelled Not Rescheduled' and Completed_Stage__c not in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case'))
          and account.center__r.sales_region__c = :sales_region];
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.QTD = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.QTD = 0;
        ar = database.query('select sum(ao4_count__c) num_ao4,sum(AO_4_amount__c) dollars_ao4 from opportunity where ' +
           ' createddate = ' + yesterday_filter + ' and (stagename != \'Cancelled Not Rescheduled\' ' +
           ' and Completed_Stage__c not in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' +
           ' and account.center__r.sales_region__c = :sales_region');
        if((Decimal)ar.get('num_ao4')>0)
          ao4_avg.previous_day = (Decimal)ar.get('dollars_ao4')/(Decimal)ar.get('num_ao4');
        else
          ao4_avg.previous_day = 0;
      }
    }
    return ao4_avg;*/
    return null;
  }

}