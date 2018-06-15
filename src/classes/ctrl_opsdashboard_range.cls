/*modified by cm on 2015-06-04
  per data governance,  the cancel in definition is changing to close the loophole
  old defintion cancel_reason__c != null
*/

/*modified by cm on 6/28/2017
  cancels are now defined by just the cancel_date__c field not being null
  removed references to stage name and completed stage
*/
public without sharing class ctrl_opsdashboard_range {
  ID center_id;
  String Sales_Region;
  public String download_string;
  public String getdownload_string() {return download_string;}
  public string display_pec {get; set;}
  public string display_center {get; set;}
  public string display_region {get; set;}
  public String action;
  public String report_header;
  public String outputtext {get; set;}
  public String getaction() { return action; }
  public String getreport_header() { return report_header;}

  User this_user = [select center_pec__c,center_administrator__c from user where id = :Userinfo.getUserId()];
  public String hyper_prefix;
  public String gethyper_prefix() { return hyper_prefix; }
  public String all_filter = '';
  public Set<String> action_set = new Set<String>{'all', 'user', 'center', 'region'};

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
  public List<Center_Information__c> all_centers;
  public Consult_Room_Note__c sdate_note {get; set;}
  public Consult_Room_Note__c edate_note {get; set;}
  Consult_Rooms__c cr_holder;
  Date sdate {get; set;}
  Date edate {get; set;}
  Datetime sdate_time {get; set;}
  Datetime edate_time {get; set;}

  Decimal sdstarts = 0;
  Decimal starts = 0;
  Decimal pendingstarts = 0;
  Decimal starts_cancelled = 0;
  Decimal starts_cancelled_in = 0;
  Decimal starts_cancelled_out = 0;
  Integer consult_starts = 0;
  Decimal collected = 0.00;
  Decimal refunded = 0.00;
  Decimal treatment_sold = 0.00;
  Decimal treatment_sold_valid = 0.00;
  Decimal treatment_sold_small = 0.00;
  Decimal treatment_sold_valid_start_value_1 = 0.00;
  Decimal pending_treatment_sold = 0.00;
  Decimal treatment_cancelled = 0.00;
  Decimal treatment_cancelled_in = 0.00;
  Decimal treatment_cancelled_in_valid = 0.00;
  Decimal treatment_cancelled_in_valid_start_value_1 = 0.00;
  Decimal treatment_cancelled_out = 0.00;
  Decimal treatment_cancelled_out_valid = 0.00;
  Decimal anticipated_payments = 0.00;
  Integer financed_consults = 0;
  Integer pipeline = 0;
  Decimal sales_target = 0.00;
  Decimal pec_target = 0.00;
  Decimal upsell_sold = 0.00;
  Decimal upsell_cancelled_in = 0.00;
  Decimal upsell_cancelled_out = 0.00;
  Decimal true_closerate = 0.00;
  Decimal ao4_avg = 0.00;

  public ctrl_opsdashboard_range() {
    Date initial_start = date.newInstance(System.today().year(), System.today().month(), 1);
    if(Apexpages.currentPage().getParameters().get('sdate')!=null)
      initial_start = date.valueof(Apexpages.currentPage().getParameters().get('sdate'));
    Date initial_end = date.newInstance(System.today().year(), System.today().month(), System.today().day());
    if(Apexpages.currentPage().getParameters().get('edate')!=null)
      initial_end = date.valueof(Apexpages.currentPage().getParameters().get('edate'));

    all_centers = [Select c.id,c.name,c.PEC_1__c,c.PEC_2__c From Center_Information__c c order by c.name];
    cr_holder = new Consult_Rooms__c(center_information__c = all_centers[0].id);
    sdate_note = new Consult_Room_Note__c(consult_room__c = cr_holder.id, note_date__c = initial_start);
    sdate = initial_start;
    sdate_time = datetime.newInstance(sdate.year(),sdate.month(), sdate.day(), 0, 0, 0);
    edate_note = new Consult_Room_Note__c(consult_room__c = cr_holder.id, note_date__c = initial_end);
    edate = initial_end;
    edate_time = datetime.newInstance(edate.year(), edate.month(), edate.day(),23,59,59);

    if(test.isRunningTest())
      all_filter = ' limit 10';
    if(Apexpages.currentPage()<>null) {
        if(ApexPages.currentPage().getHeaders()==null)
          hyper_prefix = '';
        else
          hyper_prefix = 'http://'+ApexPages.currentPage().getHeaders().get('Host');
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
        }
        else {
            for(Center_Information__c center : all_centers) {
                if(center.id==apexpages.currentpage().getparameters().get('ascenter'))
                    center_info.add(center);
            }
        }
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
                download_string += '&ascenter=' + ci.id;
              center_id = ci.id;
            }
            cnt++;
            List<User> center_pec = [select id from user where center_pec__c = :ci.id];
            for(User my_user : center_pec) {
                user_filters.add(my_user.id);
            }
            report_header = ci.Name;
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
        Integer admin_count = [select count() from Profile where name in ('Data Audit Team','Practice Privileges - Sys Admin','System Administrator','RBD','New System Administrator','Limited System Administrator','PEC_MultipleCenters_VisiblePrescreen') and id = :Userinfo.getProfileId()];
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
    download_string = download_string + '&sdate=' + sdate + '&edate='+edate;
  }

  public String getstart_formatted() {
    return sdate_note.note_date__c.format();
  }

  public String getend_formatted() {
    return edate_note.note_date__c.format();
  }

  public List<SelectOption> getCAPEClist() {
    List<SelectOption> options = new List<SelectOption>();
    Set<ID> all_market_centers = new Set<ID>();
    if(this_user.Center_PEC__c!=null) {
        Center_Information__c sm = [select sales_market__c from Center_Information__c where id = :this_user.center_pec__c];
        for(Center_Information__c ci : [select id from Center_Information__c where sales_market__c = :sm.sales_market__c]) {
            all_market_centers.add(ci.id);
        }
    }
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
    for(Center_Information__c center : [select id,name from Center_Information__c where sales_market__c = :sm.sales_market__c]) {
      options.add(new SelectOption(center.id,center.name));
    }
    return options;
  }

  public List<SelectOption> getPEClist() {
    /*This method is pulling alist of PECs by searching for the id's tied to the pec_1 and pec_2 field
      in the center information table.  Not the best way to handle it given we have traveling PECs.  I'll
      likely add a field to the user table at some point to track PEC assignment at some point and switch
      this to pull from there   */
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

  public Pagereference view_aregion() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action','region');
    pr.getParameters().put('aregion',display_region);
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    pr.setredirect(true);
    return pr;
  }

  public Pagereference view_auser() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action','user');
    pr.getParameters().put('asuser',display_pec);
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    pr.setredirect(true);
    return pr;
  }

  public Pagereference view_acenter() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action','center');
    pr.getParameters().put('ascenter',display_center);
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    pr.setredirect(true);
    return pr;
  }

  public Pagereference display_center() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action','center');
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    pr.setredirect(true);
    return pr;
  }

  public Pagereference display_all() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action','all');
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    pr.setredirect(true);
    return pr;
  }

  public Pagereference display_user() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action','user');
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    pr.setredirect(true);
    return pr;
  }

  public Pagereference date_change() {
    Pagereference pr = Page.OpsDashboard_range;
    pr.getParameters().put('action',action);
    pr.getParameters().put('sdate',String.valueOf(sdate_note.note_date__c));
    pr.getParameters().put('edate',String.valueof(edate_note.note_date__c));
    if(apexpages.currentpage().getparameters().get('ascenter')!=null)
      pr.getParameters().put('ascenter',apexpages.currentpage().getparameters().get('ascenter'));
    if(apexpages.currentpage().getparameters().get('asuser')!=null)
      pr.getParameters().put('asuser',apexpages.currentpage().getparameters().get('asuser'));
    pr.setredirect(true);
    return pr;
  }

  public Integer getFinancedConsults() {
      if(action=='all')
        financed_consults = database.countQuery('select count() from account where createddate >= :sdate_time and createddate <= :edate_time and center__r.type__c not in (\'Affiliate\',\'Network Center\') and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')' + all_filter);
      else if(action=='user')
        financed_consults = database.countquery('select count() from account where createddate >= :sdate_time and createddate <= :edate_time and ownerid in : user_filters and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')');
      else if(action=='center')
        financed_consults = database.countquery('select count() from account where createddate >= :sdate_time and createddate <= :edate_time and center__c = :center_id and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')');
      else if(action=='region')
        financed_consults = database.countquery('select count() from account where createddate >= :sdate_time and createddate <= :edate_time and center__r.sales_region__c = :sales_region and financing_result__c in (\'Approved Less Than 50%\',\'Approved Greater or Equal to 50%\',\'Approved Full Amount\',\'Declined\')');
    return financed_consults;
  }

  public Integer getConsultStarts() {
      if(action=='all')
        consult_starts = database.countquery('select count() from Consult_Inventory__c where isvalidcallback__c = false and active__c = true and consult_room__r.room_type__c != \'Practice\' and consult_room__r.center_information__r.type__c not in (\'Affiliate\',\'Network Center\') and arrival_time__c != null and apt_date__c >= :sdate and apt_date__c <= :edate ' + all_filter);
      else if(action=='user') {
        /*modified by cm on 3-30-2015
        adjusting this section to handle the change in consult defintion.  From 4-1-2015 on we're using consult_pec__c as the owner
        */
        //consult_starts = database.countquery('select count() from Consult_Inventory__c where active__c = true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid in :user_filters or scheduled_account__r.ownerid in :user_filters) and apt_date__c >= :sdate and apt_date__c <= :edate');
        consult_starts = 0;
        consult_starts += database.countquery('select count() from Consult_Inventory__c where isvalidcallback__c = false and  active__c = true and consult_room__r.room_type__c != \'Practice\' and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid in :user_filters or scheduled_account__r.ownerid in :user_filters) and apt_date__c >= :sdate and apt_date__c <= :edate and apt_date__c < 2015-04-01');
        consult_starts += database.countquery('select count() from Consult_Inventory__c where isvalidcallback__c = false and  active__c = true and consult_room__r.room_type__c != \'Practice\' and arrival_time__c != null and consult_pec__c in :user_filters  and apt_date__c >= :sdate and apt_date__c <= :edate and apt_date__c >= 2015-04-01');
      }
      else if(action=='center')
        consult_starts = database.countquery('select count() from Consult_Inventory__c c where isvalidcallback__c = false and  active__c = true and consult_room__r.room_type__c != \'Practice\' and arrival_time__c != null and c.consult_room__r.center_information__c = :center_id and apt_date__c >= :sdate and apt_date__c <= :edate');
      else if(action=='region')
        consult_starts = database.countquery('select count() from Consult_Inventory__c c where isvalidcallback__c = false and active__c = true and consult_room__r.room_type__c != \'Practice\' and arrival_time__c != null and c.consult_room__r.center_information__r.sales_region__c = :sales_region and apt_date__c >= :sdate and apt_date__c <= :edate');
    return consult_starts;
  }


    private Map<String, String> starts_action_filters = new Map<String, String>{'all'    => ' AND Account.Center__r.Type__c not in (\'Affiliate\',\'Network Center\')' + ' GROUP BY is_Valid_Start__c' + all_filter,
                                                                                'user'   => ' AND ownerid in : user_filters',
                                                                                'center' => ' AND Account.Center__c = :center_id',
                                                                                'region' => ' AND Account.Center__r.Sales_Region__c = :sales_region'};

    public Decimal getPendingStarts() {
        if(action_set.contains(action)) {pendingstarts = pending_starts_count();}
        return pendingstarts;
    }

            private Decimal pending_starts_count() {
            	//String base_query = 'SELECT count(ID) pending_starts_count FROM Opportunity WHERE is_Minimum_Negotiated_Total_Amount__c = true AND is_Requirement_Met__c = false AND CreatedDate >= :sdate_time AND CreatedDate <= :edate_time AND (stagename != \'Cancelled Not Rescheduled\' AND Completed_Stage__c NOT IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))';
            	//modified by cm on 6/28/2017 - cancel_date__c change
                String base_query = 'SELECT count(ID) pending_starts_count FROM Opportunity WHERE is_Minimum_Negotiated_Total_Amount__c = true AND is_Requirement_Met__c = false AND CreatedDate >= :sdate_time AND CreatedDate <= :edate_time AND cancel_date__c = null';
                AggregateResult[] aggregate = database.query(base_query + starts_action_filters.get(action));
                return aggregate_value(aggregate, 'pending_starts_count');
            }

  /*modified by cm on 2014-12-16
    adjusting the cancellation,  so it will only count on records that have recieved the $1000 payment (the new start definition)
    modified by aw on 2016-06-20
    DRY'd up the code and changed start definition to 'is_Valid_Start__c' which now also includes a test for the Opportunity having a Treatment Option attached
  */
  public Decimal getSDStarts() {
    if(action_set.contains(action)) {
      String start_type_filter = ' AND Days_Since_Consult__c = 0';
      sdstarts = starts_value(start_type_filter);}
    return sdstarts;
  }

  /*modified by cm on 2014-12-16
    adjusting the cancellation,  so it will only count on records that have recieved the $1000 payment (the new start definition)
    modified by aw on 2016-06-20
    DRY'd up the code and changed start definition to 'is_Valid_Start__c' which now also includes a test for the Opportunity having a Treatment Option attached
  */
  public Decimal getStarts() {
    if(action_set.contains(action)) {
      String start_type_filter = '';
      starts = starts_value(start_type_filter);}
    return starts;
  }

          private Decimal starts_value(String start_type_filter) {
              String base_query = 'SELECT SUM(Start_Value__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND Prosth_Exam_Paid_Date__c >= :sdate AND Prosth_Exam_Paid_Date__c <= :edate';
              AggregateResult[] aggregate = database.query(base_query + start_type_filter + starts_action_filters.get(action));
              return aggregate_value(aggregate, 'total_payments');
          }


  /*modified by cm on 2014-12-16
    adjusting the cancellation,  so it will only count on records that have recieved the $1000 payment (the new start definition)
  */
  public Decimal getStartsCancelledIn() {
    /*2013-03-11
    Adjusting this to match the definition on the Consultation Summary.  This will only count records where the cancel_reason__c is not null.  I'll have to figure out later how to get the
    missed ones back in to the true close rate.
    modified by cm on 2015-06-04
    per data governance,  the cancel in definition is changing to close the loophole
    old definition cancel_reason__c != null
    modified by aw on 2016-06-20
    DRY'd up the code and, adhering to new start definition, now using is_Valid_Start__c instead of 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true'. is_Valid_Start__c includes a requirement that the Opportunity be connected to a Treatment Option through a Treatment Plan
    */
    if(action_set.contains(action)) {
      String start_type_filter = ' AND Prosth_Exam_Paid_Date__c >= :sdate AND Prosth_Exam_Paid_Date__c <= :edate';
      starts_cancelled_in = starts_cancelled_value(start_type_filter);}
    return starts_cancelled_in;
  }

  /*modified by cm on 2014-12-16
    adjusting the cancellation,  so it will only count on records that have recieved the $1000 payment (the new start definition)
    modified by aw on 2016-06-20
    DRY'd up the code and, adhering to new start definition, now using is_Valid_Start__c instead of 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true'. is_Valid_Start__c includes a requirement that the Opportunity be connected to a Treatment Option through a Treatment Plan
  */
  public Decimal getStartsCancelledOut() {
    if(action_set.contains(action)) {
      String start_type_filter = ' AND (Prosth_Exam_Paid_Date__c < :sdate OR Prosth_Exam_Paid_Date__c > :edate)';
      starts_cancelled_out = starts_cancelled_value(start_type_filter);}
    return starts_cancelled_out;
  }

          private Decimal starts_cancelled_value(String start_type_filter) {
          	  //String base_query = 'SELECT SUM(Start_Value__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND ignored_cancel__c = false AND Cancel_Date__c >= :sdate_time AND Cancel_Date__c <= :edate_time AND (stagename = \'Cancelled Not Rescheduled\' OR Completed_Stage__c IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))';
          	  //modified by cm on 6/28/2017 - cancel date change
              String base_query = 'SELECT SUM(Start_Value__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND ignored_cancel__c = false AND Cancel_Date__c >= :sdate_time AND Cancel_Date__c <= :edate_time ';
              AggregateResult[] aggregate = database.query(base_query + start_type_filter + starts_cancelled_action_filters().get(action));
              return aggregate_value(aggregate, 'total_payments') * -1;
          }

          private Map<String, String> starts_cancelled_action_filters() {
              return new Map<String, String>{'all'    => ' AND Account.Center__r.Type__c not in (\'Affiliate\',\'Network Center\')' + ' GROUP BY is_Valid_Start__c' + all_filter,
                                             'user'   => ' AND Current_Prosth_Owner__c in : user_filters',
                                             'center' => ' AND Account.Center__c = :center_id',
                                             'region' => ' AND Account.Center__r.Sales_Region__c = :sales_region'};
          }

          private Decimal aggregate_value(AggregateResult[] aggregate, String fieldname) {
              return aggregate_has_data(aggregate, fieldname) ? (Decimal)aggregate[0].get(fieldname) : 0;
          }

          private Boolean aggregate_has_data(AggregateResult[] aggregate, String fieldname) {
              return (aggregate.size() > 0 && aggregate[0].get(fieldname) != null);
          }

   public Decimal getStartsCancelled() {
      if(starts_cancelled_in==null)
        starts_cancelled_in = getStartsCancelledIn();
      if(starts_cancelled_out==null)
        starts_cancelled_out = getStartsCancelledOut();
      try {
        starts_cancelled = starts_cancelled_in + starts_cancelled_out;
      }
      catch (Exception e) {
        starts_cancelled = 0;
      }
    return starts_cancelled;
  }

    public Decimal getTreatmentSold() {
        if(action_set.contains(action)) {
            Map<String, Decimal> totals;
            totals = revenue_totals();
            treatment_sold       = totals.get('all');
            treatment_sold_valid = totals.get('valid');
            treatment_sold_small = totals.get('small');
        }
        //   if(action=='all') {
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and createddate >= :sdate_time and createddate <= :edate_time')) {
        //       if(results.get('total_payments')==null)
        //         treatment_sold = 0;
        //       else
        //         treatment_sold = (Decimal)results.get('total_payments');
        //     }
        //   }
        //   else if(action=='user') {
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate >= :sdate_time and createddate <= :edate_time and ownerid in : user_filters')) {
        //       if(results.get('total_payments')==null)
        //         treatment_sold = 0;
        //       else
        //         treatment_sold = (Decimal)results.get('total_payments');
        //     }
        //   }
        //   else if(action=='center') {
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate >= :sdate_time and createddate <= :edate_time and account.center__c = :center_id')) {
        //       if(results.get('total_payments')==null)
        //         treatment_sold = 0;
        //       else
        //         treatment_sold = (Decimal)results.get('total_payments');
        //     }
        //   }
        //   else if(action=='region') {
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where createddate >= :sdate_time and createddate <= :edate_time and account.center__r.sales_region__c = :sales_region')) {
        //       if(results.get('total_payments')==null)
        //         treatment_sold = 0;
        //       else
        //         treatment_sold = (Decimal)results.get('total_payments');
        //     }
        //   }
        return treatment_sold;
    }

          // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
          private Map<String, Decimal> revenue_totals() {
              Map<String, Decimal> totals = new Map<String, Decimal>{'all' => 0, 'valid' => 0, 'small' => 0};
              String query = 'SELECT is_valid_start__c, is_Requirement_Met__c, sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE Prosth_Exam_Paid_Date__c >= :sdate AND Prosth_Exam_Paid_Date__c <= :edate' + revenue_action_filters.get(action) + ' GROUP BY is_valid_start__c, is_Requirement_Met__c';
              for (AggregateResult results : database.query(query)) {
                  if(results.get('total_payments') != null) {
                      totals.put('all', totals.get('all') + (Decimal)results.get('total_payments'));
                      if((boolean)results.get('is_valid_start__c')) {totals.put('valid', totals.get('valid') + (Decimal)results.get('total_payments'));}
                      else if((boolean)results.get('is_Requirement_Met__c')) {totals.put('small', totals.get('small') + (Decimal)results.get('total_payments'));}
                  }
              }
              return totals;
          }

          private Map<String, String> revenue_action_filters = new Map<String, String>{'all'    => ' AND Account.Center__r.Type__c not in (\'Affiliate\',\'Network Center\')',
                                                                                       'user'   => ' AND ownerid in : user_filters',
                                                                                       'center' => ' AND Account.Center__c = :center_id',
                                                                                       'region' => ' AND Account.Center__r.Sales_Region__c = :sales_region'};

    public Decimal getTreatmentSoldValid() {
       if(treatment_sold_valid == null) {getTreatmentSold();}
       return treatment_sold_valid;
    }

    public Decimal getTreatmentSold_Small() {
       if(treatment_sold_small == null) {getTreatmentSold();}
       return treatment_sold_small;
    }

    public Decimal getTreatmentSoldValid_StartValue1() {
        if(action_set.contains(action)) {treatment_sold_valid_start_value_1 = valid_revenue_start_value_1();}
        return treatment_sold_valid_start_value_1;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Decimal valid_revenue_start_value_1() {
                AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND Start_Value__c = 1.0 AND Prosth_Exam_Paid_Date__c >= :sdate AND Prosth_Exam_Paid_Date__c <= :edate' + revenue_action_filters.get(action));
                return aggregate_value(aggregate, 'total_payments');
            }

    private Map<String, String> cancelled_revenue_query_filters = new Map<String, String>{'all'    => ' AND account.Center__r.Type__c NOT IN (\'Affiliate\',\'Network Center\')',
                                                                                          'user'   => ' AND Current_Prosth_Owner__c IN :user_filters',
                                                                                          'center' => ' AND account.Center__c = :center_id',
                                                                                          'region' => ' AND account.Center__r.Sales_Region__c = :sales_region'};

    public Decimal getPendingTreatmentSold() {
        if(action_set.contains(action)) {pending_treatment_sold = pending_revenue();}
        return pending_treatment_sold;
    }

            private Decimal pending_revenue() {
            	//AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Minimum_Negotiated_Total_Amount__c = true AND is_Requirement_Met__c = false AND CreatedDate >= :sdate_time AND CreatedDate <= :edate_time AND (stagename != \'Cancelled Not Rescheduled\' AND Completed_Stage__c NOT IN (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))' + revenue_action_filters.get(action));
            	//modified by cm on 6/28/2017 - cancel date change
                AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Minimum_Negotiated_Total_Amount__c = true AND is_Requirement_Met__c = false AND CreatedDate >= :sdate_time AND CreatedDate <= :edate_time AND cancel_date__c = null ' + revenue_action_filters.get(action));
                return aggregate_value(aggregate, 'total_payments');
            }

    public Decimal getTreatmentCancelledIn() {
        if(action_set.contains(action)) {
            Map<String, Decimal> totals;
            totals = cancelled_in_revenue_totals();
            treatment_cancelled_in       = totals.get('all');
            treatment_cancelled_in_valid = totals.get('valid');
        }
        //   if(action=='all')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and createddate >= :sdate_time and createddate <= :edate_time and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_in = 0;
        //       else
        //         treatment_cancelled_in = (Decimal)results.get('total_payments') * -1;
        //     }
        //   else if(action=='user')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and createddate >= :sdate_time and createddate <= :edate_time and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and Current_Prosth_Owner__c in : user_filters')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_in = 0;
        //       else
        //         treatment_cancelled_in = (Decimal)results.get('total_payments') * -1;
        //     }
        //   else if(action=='center')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and createddate >= :sdate_time and createddate <= :edate_time and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__c = :center_id')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_in = 0;
        //       else
        //         treatment_cancelled_in = (Decimal)results.get('total_payments') * -1;
        //     }
        //   else if(action=='region')
        //    for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and createddate >= :sdate_time and createddate <= :edate_time  and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_region__c = :sales_region')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_in = 0;
        //       else
        //         treatment_cancelled_in = (Decimal)results.get('total_payments') * -1;
        //     }
        return treatment_cancelled_in;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Map<String, Decimal> cancelled_in_revenue_totals() {
                Map<String, Decimal> totals = new Map<String, Decimal>{'all' => 0, 'valid' => 0, 'small' => 0};
                String query = 'SELECT is_Valid_Start__c, sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate  ' + cancelled_revenue_query_filters.get(action) + ' GROUP BY is_Valid_Start__c';
                for (AggregateResult results : database.query(query)) {
                    if(results.get('total_payments') != null) {
                        totals.put('all', totals.get('all') + ((Decimal)results.get('total_payments') * -1));
                        if((boolean)results.get('is_valid_start__c')) {totals.put('valid', totals.get('valid') + ((Decimal)results.get('total_payments') * -1));}
                    }
                }
                return totals;
            }

    public Decimal getTreatmentCancelledInValid() {
        if(treatment_cancelled_in_valid == null) {getTreatmentCancelledIn();}
        return treatment_cancelled_in_valid;
    }

    public Decimal getTreatmentCancelledInValid_StartValue1() {
        if(action_set.contains(action)) {treatment_cancelled_in_valid_start_value_1 = valid_cancelled_in_revenue_start_value_1();}
        return treatment_cancelled_in_valid_start_value_1;
    }

          // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
          private Decimal valid_cancelled_in_revenue_start_value_1() {
              AggregateResult[] aggregate = database.query('SELECT sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE is_Valid_Start__c = true AND Start_Value__c = 1.0 AND Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate ' + cancelled_revenue_query_filters.get(action));
              return aggregate_value(aggregate, 'total_payments') * -1;
          }

    public Decimal getTreatmentCancelledOut() {
        if(action_set.contains(action)) {
            Map<String, Decimal> totals;
            totals = cancelled_out_revenue_totals();
            treatment_cancelled_out       = totals.get('all');
            treatment_cancelled_out_valid = totals.get('valid');
        }
        //   if(action=='all')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and (createddate < :sdate_time  or createddate > :edate_time) and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\'))')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_out = 0;
        //       else
        //         treatment_cancelled_out = (Decimal)results.get('total_payments') * -1;
        //     }
        //   else if(action=='user')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and (createddate < :sdate_time  or createddate > :edate_time) and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and Current_Prosth_Owner__c in : user_filters')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_out = 0;
        //       else
        //         treatment_cancelled_out = (Decimal)results.get('total_payments') * -1;
        //     }
        //   else if(action=='center')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and (createddate < :sdate_time  or createddate > :edate_time) and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and accountid in (select id from account where center__c = :center_id)')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_out = 0;
        //       else
        //         treatment_cancelled_out = (Decimal)results.get('total_payments') * -1;
        //     }
        //   else if(action=='region')
        //     for (AggregateResult results : database.query('select sum(negotiated_total_amount__c) total_payments from opportunity where Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and (createddate < :sdate_time  or createddate > :edate_time) and (stagename = \'Cancelled Not Rescheduled\' or Completed_Stage__c in (\'Not Moving Forward\',\'Financing Difficulty\',\'Patient Non Responsive\',\'Non Candidate\',\'Doctor Declined Case\')) and account.center__r.sales_region__c = :sales_region')) {
        //       if(results.get('total_payments')==null)
        //         treatment_cancelled_out = 0;
        //       else
        //         treatment_cancelled_out = (Decimal)results.get('total_payments') * -1;
        //     }
        return treatment_cancelled_out;
    }

            // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
            private Map<String, Decimal> cancelled_out_revenue_totals() {
                Map<String, Decimal> totals = new Map<String, Decimal>{'all' => 0, 'valid' => 0, 'small' => 0};
                String query = 'SELECT is_Valid_Start__c, sum(Negotiated_Total_Amount__c) total_payments FROM Opportunity WHERE Cancel_Date__c >= :sdate_time and cancel_date__c <= :edate_time and (Prosth_Exam_Paid_Date__c < :sdate or Prosth_Exam_Paid_Date__c > :edate) ' + cancelled_revenue_query_filters.get(action) + ' GROUP BY is_Valid_Start__c';
                for (AggregateResult results : database.query(query)) {
                    if(results.get('total_payments') != null) {
                        totals.put('all', totals.get('all') + ((Decimal)results.get('total_payments') * -1));
                        if((boolean)results.get('is_valid_start__c')) {totals.put('valid', totals.get('valid') + ((Decimal)results.get('total_payments') * -1));}
                    }
                }
                return totals;
            }

    public Decimal getTreatmentCancelledOutValid() {
        if(treatment_cancelled_out_valid == null) {getTreatmentCancelledOut();}
        return treatment_cancelled_out_valid;
    }

  public Decimal getTreatmentCancelled() {
      if(treatment_cancelled_in==null)
        getTreatmentCancelledIn();
      if(treatment_cancelled_out==null)
        getTreatmentCancelledOut();
      try {
        treatment_cancelled = treatment_cancelled_in + treatment_cancelled_out;
      }
      catch (Exception e) {
        treatment_cancelled = 0;
      }
    return treatment_cancelled;
  }

  public Decimal getCollected() {
      if(action=='all')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c >= :sdate and payment_date__c <= :edate')) {
          if(results.get('total_payments')==null)
            collected = 0;
          else
            collected = (Decimal)results.get('total_payments');
        }
      else if(action=='user')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c >= :sdate and payment_date__c <= :edate  and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            collected = 0;
          else
            collected = (Decimal)results.get('total_payments');
         }
      else if(action=='center')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c >= :sdate and payment_date__c <= :edate and opportunity__r.account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            collected = 0;
          else
            collected = (Decimal)results.get('total_payments');
        }
      else if(action=='region')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Collected\' and payment_date__c >= :sdate and payment_date__c <= :edate and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            collected = 0;
          else
            collected = (Decimal)results.get('total_payments');
        }
    return collected;
  }

  public Decimal getRefunded() {
      if(action=='all')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c >= :sdate and payment_date__c <= :edate')) {
          if(results.get('total_payments')==null)
            refunded = 0;
          else
            refunded = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='user')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c >= :sdate and payment_date__c <= :edate  and pec__c in :user_filters')) {
          if(results.get('total_payments')==null)
            refunded = 0;
          else
            refunded = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='center')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c >= :sdate and payment_date__c <= :edate and opportunity__r.account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            refunded = 0;
          else
            refunded = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='region')
        for (AggregateResult results : database.query('Select sum(net_collection_amount__c) total_payments  From CCPayment__c  where ' +
          ' payment_status_formula__c = \'Refunded\' and payment_date__c >= :sdate and payment_date__c <= :edate and opportunity__r.account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            refunded = 0;
          else
            refunded = (Decimal)results.get('total_payments') * -1;
        }
    return refunded;
  }

  public Decimal getUpsellSold() {
      // AW - 2016-08-30 - Per Scott L, adding is_Requirement_Met__c = true to maintain consistency with recent changes to the main portion of the report (above)
      if(action=='all')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND account.center__r.type__c not in (\'Affiliate\',\'Network Center\') and closedate >= :sdate and closedate <= :edate')) {
          if(results.get('total_payments')==null)
            upsell_sold = 0;
          else
            upsell_sold = (Decimal)results.get('total_payments');
        }
      else if(action=='user')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND closedate >= :sdate and closedate <= :edate and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_sold = 0;
          else
            upsell_sold = (Decimal)results.get('total_payments');
        }
      else if(action=='center')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND closedate >= :sdate and closedate <= :edate and account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_sold = 0;
          else
            upsell_sold = (Decimal)results.get('total_payments');
        }
      else if(action=='region')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND closedate >= :sdate and closedate <= :edate and account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            upsell_sold = 0;
          else
            upsell_sold = (Decimal)results.get('total_payments');
        }
    return upsell_sold;
  }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public Decimal getUpsellCancelledIn() {
      if(action=='all')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate  and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') ')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in = 0;
          else
            upsell_cancelled_in = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='user')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate  and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate  and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in = 0;
          else
            upsell_cancelled_in = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='center')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate  and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate  and account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in = 0;
          else
            upsell_cancelled_in = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='region')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate  and Prosth_Exam_Paid_Date__c >= :sdate and Prosth_Exam_Paid_Date__c <= :edate and account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_in = 0;
          else
            upsell_cancelled_in = (Decimal)results.get('total_payments') * -1;
        }
    return upsell_cancelled_in;
  }

  // AW 2016-09-21 Per Scott L - changing date filter from CreatedDate to Prosth_Exam_Paid_Date__c
  public Decimal getupsellCancelledOut() {
      if(action=='all')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate and (Prosth_Exam_Paid_Date__c < :sdate and Prosth_Exam_Paid_Date__c > :edate) and account.center__r.type__c not in (\'Affiliate\',\'Network Center\') ')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out = 0;
          else
            upsell_cancelled_out = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='user')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate and (Prosth_Exam_Paid_Date__c < :sdate and Prosth_Exam_Paid_Date__c > :edate)  and ownerid in : user_filters')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out = 0;
          else
            upsell_cancelled_out = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='center')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate and (Prosth_Exam_Paid_Date__c < :sdate and Prosth_Exam_Paid_Date__c > :edate)  and account.center__c = :center_id')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out = 0;
          else
            upsell_cancelled_out = (Decimal)results.get('total_payments') * -1;
        }
      else if(action=='region')
        for (AggregateResult results : database.query('select sum(additional_treatment_amount__c) total_payments from opportunity where is_Requirement_Met__c = true AND Cancel_Date__c >= :sdate and cancel_date__c <= :edate and (Prosth_Exam_Paid_Date__c < :sdate and Prosth_Exam_Paid_Date__c > :edate)  and account.center__r.sales_region__c = :sales_region')) {
          if(results.get('total_payments')==null)
            upsell_cancelled_out = 0;
          else
            upsell_cancelled_out = (Decimal)results.get('total_payments') * -1;
        }
    return upsell_cancelled_out;
  }

  public Decimal gettrue_closerate() {
    gettreatmentsold();
    gettreatmentcancelled();
      if(treatment_sold + treatment_cancelled==0)
        true_closerate = 0.00;
      else {
        true_closerate = (Collected + Refunded)/(treatment_sold + treatment_cancelled) * 100;
        true_closerate = true_closerate.divide(1,1);
      }
    return true_closerate;
  }
}