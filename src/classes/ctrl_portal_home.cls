public without sharing class ctrl_portal_home {
  public Boolean display_admin {get;set;}
  public Boolean display_partner {get; set;}
  public Boolean display_center_view {get; set;}
  public Boolean display_practice_view {get; set;}

  public Boolean display_error {get; set;}
  public String referral_partner_id {get; set;}
  public String referral_partner_name {get;set;}
  public String center_id {get; set;}
  public String center_name {get;set;}
  public String name_filter {get; set;}

  public String clinical_status_filter {get; set;}
  public String current_sort_direction {get; set;}
  public String current_sort_field {get; set;}
  public String track_filter {get; set;}

  public Base_Target__c sdate_holder {get; set;}
  public Base_Target__c edate_holder {get; set;}


  public Integer page {get;set;}
  public Integer num_pages {get;set;}
  Integer record_count;
  Double page_holder;
  public Integer records_per_page {get; set;}
  public boolean display_next {get;set;}
  public boolean display_prev  {get;set;}

  public List<referral_lead> referral_list {get; set;}
  public Integer getreferral_list_size() {return referral_list.size();}

  public class referral_lead implements Comparable {
    public Lead l {get; set;}
    public Account a {get; set;}
    public List<Opportunity> starts {get; set;}
    public List<Consult_Inventory__c> consults {get;set;}
    public List<CCPayment__c> payments {get;set;}
    public List<Task> all_tasks {get; set;}

    // default sorting would be ascending
    public String SORT_DIR = 'descending';
    // default sorting would be on name
    public String SORT_FIELD = 'name';

    public referral_lead(String current_sort_direction, String current_sort_field) {
      sort_dir = current_sort_direction;
      sort_field = current_sort_field;
      starts = new List<Opportunity>();
      consults = new List<Consult_Inventory__c>();
      payments = new List<CCPayment__c>();
      all_tasks = new List<Task>();
    }

    public String getreferral_practice_name() {
      if(l!=null) {
        if(a!=null)
          return l.referral_office__r.name==null?a.referral_office__r.name:l.referral_office__r.name;
        else
          return l.referral_office__r.name;
      } else if(a!=null)
        return a.referral_office__r.name;
      else
        return 'N/A';
    }

    public String getreferral_name() {
      if(l!=null)
        return l.name;
      else if(a!=null)
        return a.name;
      else
        return 'N/A';
    }

    public String getlink_id() {
      if(a!=null)
        return a.id;
      else if(l!=null)
        return l.id;
      else
        return 'N/A';
    }

    public String getReferral_track() {
      String track = 'N/A';
      for(opportunity o : starts) {
        if(o.final_referral_track__c!=null)
          track = o.final_referral_track__c;
      }
      return track;
    }

    public String getSurgery_date() {
        return getDate('Windent_Surgery_Date__c');
    }

    public String getFinal_date() {
        return getDate('Windent_Final_Date__c');
    }

            private String getDate(String fieldname) {
                Date datevalue = null;
                for(opportunity o : starts) {
                  if(o.get(fieldname) != null)
                    datevalue = Date.valueOf(o.get(fieldname));
                }
                return (datevalue != null) ? datevalue.format() : '-';
            }

    public String getreferral_date() {
      if(l!=null)
        return l.createddate.format('M/dd/yyyy');
      else if(a!=null)
        return a.createddate.format('M/dd/yyyy');
      else
        return 'N/A';
    }

    public Datetime getcreate_date() {
      if(l!=null)
        return l.createddate;
      else if(a!=null)
        return a.createddate;
      else
        return (Datetime.newinstance(1980,1,1));
    }

    public String gettreatment_plan() {
      String treatment_plan = 'N/A';
      if(starts.size()>0) {
        treatment_plan = '';
        Integer cnt = 1;
        for(Opportunity o : starts) {
          if(cnt>1)
            treatment_plan += ',';
          treatment_plan += o.preliminary_treatment_plan__c;
          cnt++;
        }
      }
      else if(a!=null)
        treatment_plan = a.preliminary_treatment_plan__c==null?'N/A':a.preliminary_treatment_plan__c;
      return treatment_plan;
    }

    public Decimal getsold_amount() {
      Decimal sold = 0;
      for(Opportunity o : starts) {
        //removing this restriction for now
    //      if(o.is_valid_start__c)
          sold += o.negotiated_total_amount__c;
      }
      return sold;
    }

    public Decimal getcollected_amount() {
      Decimal collected = 0;
      for(CCPayment__c cc : payments) {
        if(cc.payment_status_formula__c=='Collected')
          collected += cc.net_collection_amount__c;
        else if(cc.payment_status_formula__c=='Refunded')
          collected -= cc.net_collection_amount__c;
      }
      return collected;
    }

    public Decimal getgp_amount() {
      Decimal gp = 0;
      for(CCPayment__c cc : payments) {
        if(cc.payment_status_formula__c=='Collected')
          gp += (cc.payment_amount__c - (cc.finance_fee__c==null?0:cc.finance_fee__c)) * (cc.opportunity__r.gp_fee_rate__c==null?0:cc.opportunity__r.gp_fee_rate__c);
        else if(cc.payment_status_formula__c=='Refunded')
          gp -= (cc.payment_amount__c - (cc.finance_fee__c==null?0:cc.finance_fee__c)) * (cc.opportunity__r.gp_fee_rate__c==null?0:cc.opportunity__r.gp_fee_rate__c);
      }
      return gp;
    }

    public String getclinical_status() {
      String cstatus = 'Lead Referred';
      for(Consult_Inventory__c ci : consults) {
        if(ci.apt_date__c>System.today()) {
          cstatus = 'Consult Scheduled (' + ci.apt_date__c.month() + '/' + ci.apt_date__c.day() + '/' + ci.apt_date__c.year() + ')';
        }
        else {
          if(ci.arrival_time__c==null)
            cstatus = 'Consult - No Show';
          else if(ci.consult_show_status__c=='Patient Left')
            cstatus = 'Consult Incomplete';
          else
            cstatus = 'Consult Completed';
        }
      }
      for(Opportunity o : starts) {
        if(o.windent_prosth_date__c!=null) {
          if(o.windent_prosth_date__c<=System.today())
            cstatus = 'Prosth Exam Done';
        }
        if(o.windent_surgery_date__c!=null) {
          if(o.windent_surgery_date__c<=System.today())
            cstatus = 'Surgery Done';
        }
        if(o.windent_final_date__c!=null) {
          if(o.windent_final_date__c<=System.today())
            cstatus = 'Final Delivery Done';
        }
      }
      return cstatus;
    }

    public Integer getnum_contacts() {
      Integer contact_cnt = 0;
      for(Task t : all_tasks) {
        contact_cnt++;
      }
      return contact_cnt;
    }

    public String getfirst_contact() {
      Datetime first_date;
      for(Task t : all_tasks) {
        if(first_date==null)
          first_date = t.createddate;
        else if(t.createddate < first_date)
          first_date = t.createddate;
      }
      if(first_date==null)
        return 'N/A';
      else
        return first_date.format('M/dd/YYYY');
    }

    public String getlast_contact() {
      Datetime last_date;
      for(Task t : all_tasks) {
        if(last_date==null)
          last_date = t.createddate;
        else if(t.createddate > last_date)
          last_date = t.createddate;
      }
      if(last_date==null)
        return 'N/A';
      else
        return last_date.format('M/dd/YYYY');
    }

    public Integer compareTo(Object other) {
      if (SORT_FIELD == 'name') {
        return compareToName(other);
      } else if (SORT_FIELD == 'rdate') {
        return compareToDate(other);
      } else if (SORT_FIELD == 'cstatus') {
        return compareToStatus(other);
      } else if (SORT_FIELD == 'treatment') {
        return compareToTreatment(other);
      } else if (SORT_FIELD == 'track') {
        return compareToTrack(other);
      } else if (SORT_FIELD == 'sold') {
        return compareToSold(other);
      } else if (SORT_FIELD == 'collected') {
        return compareToCollected(other);
      } else if (SORT_FIELD == 'gp_fee') {
        return compareToGP(other);
      }
      return 0;
    }

    Integer compareToGP(Object other) {
      Decimal compare_gp = other!=null?((referral_lead)other).getgp_amount() : 0.00;
      if(SORT_DIR=='ascending')
        return (this.getgp_amount() - compare_gp).intValue();
      else
        return (compare_gp - this.getgp_amount()).intValue();
    }

    Integer compareToCollected(Object other) {
      Decimal compare_collected = other!=null?((referral_lead)other).getcollected_amount() : 0.00;
      if(SORT_DIR=='ascending')
        return (this.getcollected_amount() - compare_collected).intValue();
      else
        return (compare_collected - this.getcollected_amount()).intValue();
    }

    Integer compareToSold(Object other) {
      Decimal compare_sold = other!=null?((referral_lead)other).getsold_amount() : 0.00;
      if(SORT_DIR=='ascending')
        return (this.getsold_amount() - compare_sold).intValue();
      else
        return (compare_sold - this.getsold_amount()).intValue();
    }

    Integer compareToTrack(Object other) {
      String compare_track = other!=null?((referral_lead)other).getreferral_track().toLowercase() : '';
      if(SORT_DIR=='ascending')
        return this.getreferral_track().toLowerCase().compareTo(compare_track);
      else
        return compare_track.compareTo(this.getreferral_track().toLowerCase());
    }

    Integer compareToTreatment(Object other) {
      String compare_treatment = other!=null?((referral_lead)other).gettreatment_plan().toLowercase() : '';
      if(SORT_DIR=='ascending')
        return this.gettreatment_plan().toLowerCase().compareTo(compare_treatment);
      else
        return compare_treatment.compareTo(this.gettreatment_plan().toLowerCase());
    }

    Integer compareToStatus(Object other) {
      String compare_status = other!=null?((referral_lead)other).getclinical_status().toLowerCase() : '';
      if(SORT_DIR=='ascending')
        return this.getclinical_status().toLowerCase().compareTo(compare_status);
      else
        return compare_status.compareTo(this.getclinical_status().toLowerCase());
    }

    Integer compareToName(Object other) {
      String compare_name = other!=null?((referral_lead)other).getreferral_name().toLowerCase() : '';
      if (SORT_DIR == 'ascending')
       return this.getreferral_name().toLowerCase().compareTo(compare_name);
      else
       return compare_name.compareTo(this.getreferral_name().toLowerCase());
    }

    Integer compareToDate(Object other) {
      //Datetime compare_date = other!=null?((referral_lead)other).l.createddate : System.now();
      Datetime compare_date = other!=null?((referral_lead)other).getcreate_date() : System.now();
      if (SORT_DIR == 'ascending')
       // return (this.l.createddate.getTime() - compare_date.getTime()).intValue();
        return (this.getcreate_date().getTime() - compare_date.getTime()).intValue();
      else
        //return (compare_date.getTime() - this.l.createddate.getTime()).intValue();
        return (compare_date.getTime() - this.getcreate_date().getTime()).intValue();
    }
  }

  public ctrl_portal_home() {
    name_filter = '';
    clinical_status_filter = 'Any';
    display_center_view = false;
    display_practice_view = true;
    sdate_holder = new Base_Target__c(effective_date__c=Date.newinstance(2011,01,01));
    edate_holder = new Base_Target__c(effective_date__c=System.today().adddays(1));
    track_filter = 'Any';
    reset_page_defaults();
    records_per_page = 25;
    current_sort_direction = 'descending';
    current_sort_field = 'rdate';
    display_admin = false;
    display_partner = false;
    display_error = false;
    //check to see if the user is tied to an admin profile
    Integer admin_count = [select count() from Profile where name in ('System Administrator','Practice Privileges Admin','Practice Privileges Field Workers','Practice Privileges Legal','Practice Privileges - Sys Admin','Practice Privileges Users') and id = :Userinfo.getProfileId()];
    Integer sales_count = [select count() from Profile where name in ('FOA - No Prescreen - TPlan','FOA - TPLAN','RBD','FOA','FOA - No Prescreen','Patient Education Consultant','PEC - Application Date','PEC - Denver','PEC - Exam Center','PEC - Extended Finance','PEC - Extended Finance no prescreen','PEC - Multiple Centers','PEC - Multiple Centers No Prescreen','PEC - No Prescreen','PEC - No Prescreen - PPF','PEC - PFF - Application Date','PEC - PPF - No Prescreen','PEC - PPF - NoPScreen - TPlan','PEC - Red Rally No Prescreen','PEC - Snap No Prescreen','PEC - TPLAN') and id = :Userinfo.getProfileId()];
    if(admin_count>0) {
      display_admin = true;
      referral_partner_id = 'All';
      referral_partner_name = 'All Partner Practices';
      center_id = 'All';
          center_name = 'All Centers';
    }
    //check to see if the user is an RBD/FOA/PEC
    else if(sales_count>0) {
      display_center_view = true;
      display_practice_view = false;
      User u = [select Center_PEC__c from User where id = :Userinfo.getuserid()];
      if(u.Center_Pec__c==null)
        display_error = true;
      else {
        Center_information__c ci = [select id,name from Center_Information__c where id = :u.center_pec__c];
        center_id = ci.id;
        center_name = ci.name;
      }
    }
    //check to see if the user has a portal account with an office tied to it
    else {
      User u = [select id, contact.account.dental_practice_partner__c, contact.account.dental_practice_partner__r.name from User where id = :userinfo.getuserid()];
      if(u.contact.account.dental_practice_partner__c!=null) {
        display_partner = true;
        referral_partner_id = u.contact.account.dental_practice_partner__c;
        referral_partner_name = u.contact.account.dental_practice_partner__r.name;
      }
      else {
        //otherwise we need to display an error message - the user has been set up improperly,  or should not have hit this page
        display_error = true;
      }
    }
    if(display_center_view)
      referral_list = refresh_referral_list(center_id);
    else
      referral_list = refresh_referral_list(referral_partner_id);
    referral_list.sort();
    calculate_page_info();
  }

  public void run_filtered_search() {
        current_sort_direction = 'descending';
    current_sort_field = 'rdate';
    if(records_per_page>100) {
      records_per_page = 100;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You can only display a maximum of 100 records per page'));
    }
    reset_page_defaults();
    if(display_center_view)
      referral_list = refresh_referral_list(center_id);
    else
      referral_list = refresh_referral_list(referral_partner_id);
    referral_list.sort();
    calculate_page_info();
  }

  public List<referral_lead> getpaged_referrals() {
        List<referral_lead> rl_list = new List<referral_lead>();
        Integer low_range = (page - 1) * records_per_page;
        Integer high_range = page * records_per_page;
        Integer cnt = 1;
        for(referral_lead rl : referral_list) {
          if(cnt > low_range && cnt <= high_range)
            rl_list.add(rl);
          cnt++;
        }
        return rl_list;
  }

  public void next() {
    page++;
    calculate_page_info();
  }

  public void prev() {
    page = page - 1;
    calculate_page_info();
  }

  public void calculate_page_info() {
    record_count = referral_list.size();
        page_holder = math.ceil((record_count/records_per_page));
        num_pages = page_holder.intvalue();
        //only here because for some reason ceil is rounding down!
        if(math.mod(record_count, records_per_page)>0)
          num_pages++;
        if(page > 1)
          display_prev = true;
        else
          display_prev = false;
        if(num_pages > 1 && page < num_pages)
          display_next = true;
        else
          display_next = false;
  }

  public void reset_page_defaults() {
        page = 1;
    num_pages = 0;
    display_next = true;
    display_prev = false;
  }

  public void change_practice() {
    reset_page_defaults();
    if(display_center_view)
      referral_list = refresh_referral_list(center_id);
    else
      referral_list = refresh_referral_list(referral_partner_id);
    referral_list.sort();
    calculate_page_info();
  }

  public Integer getYTD_patients() {
        Integer patients = 0;
        Date ytd_start = Date.newinstance(System.today().year(),1,1);
        for(Referral_lead rl : referral_list) {
          if(rl.l.createddate >= ytd_start)
            patients++;
        }
        return patients;
  }

  public Integer getlifetime_patients() {
        return referral_list.size();
  }

  public Decimal getYTD_gpfee() {
        Decimal gp = 0.00;
        Date ytd_start = Date.newinstance(System.today().year(),1,1);
        for(Referral_lead rl : referral_list) {
          for(CCPayment__c cc : rl.payments) {
        if(cc.payment_status_formula__c=='Collected' && cc.payment_date__c >= ytd_start)
          gp += (cc.payment_amount__c - (cc.finance_fee__c==null?0:cc.finance_fee__c)) * (cc.opportunity__r.gp_fee_rate__c==null?0:cc.opportunity__r.gp_fee_rate__c);
        else if(cc.payment_status_formula__c=='Refunded' && cc.payment_date__c >= ytd_start)
          gp -= (cc.payment_amount__c - (cc.finance_fee__c==null?0:cc.finance_fee__c)) * (cc.opportunity__r.gp_fee_rate__c==null?0:cc.opportunity__r.gp_fee_rate__c);
      }
        }
        return gp;
  }

  public Decimal getlifetime_gpfee() {
        Decimal gp = 0.00;
        for(Referral_lead rl : referral_list) {
          for(CCPayment__c cc : rl.payments) {
        if(cc.payment_status_formula__c=='Collected')
          gp += (cc.payment_amount__c - (cc.finance_fee__c==null?0:cc.finance_fee__c)) * (cc.opportunity__r.gp_fee_rate__c==null?0:cc.opportunity__r.gp_fee_rate__c);
        else if(cc.payment_status_formula__c=='Refunded')
          gp -= (cc.payment_amount__c - (cc.finance_fee__c==null?0:cc.finance_fee__c)) * (cc.opportunity__r.gp_fee_rate__c==null?0:cc.opportunity__r.gp_fee_rate__c);
      }
        }
        return gp;
  }

  public Decimal getYTD_close_rate() {
    Decimal num_consults = 0.00;
    Decimal num_starts = 0.00;
    Date ytd_start = Date.newinstance(System.today().year(),1,1);
    for(referral_lead rl : referral_list) {
      for(Consult_Inventory__c ci : rl.consults) {
        if(ci.apt_date__c>= ytd_start && !ci.isvalidcallback__c && ci.arrival_time__c!=null)
          num_consults++;
      }
      for(Opportunity o : rl.starts) {
        if(o.prosth_exam_paid_date__c >= ytd_start && o.is_valid_start__c)
          num_starts++;
      }
    }

    if(num_consults==0)
      return 0.00;
    else
      return (num_starts * 1.00)/(num_consults * 1.00);
  }

  public Decimal getlifetime_close_rate() {
    Decimal num_consults = 0.00;
    Decimal num_starts = 0.00;
    for(referral_lead rl : referral_list) {
      for(Consult_Inventory__c ci : rl.consults) {
        if(!ci.isvalidcallback__c && ci.arrival_time__c!=null)
          num_consults++;
      }
      for(Opportunity o : rl.starts) {
        if(o.is_valid_start__c)
          num_starts++;
      }
    }
    System.debug('Num Consults : ' + num_consults);
    System.debug('Num Starts : ' + num_starts);
    if(num_consults==0)
      return 0.00;
    else
      return (num_starts * 1.00)/(num_consults * 1.00);
  }

  public Decimal getYTD_lead_consult_rate() {
        Integer num_patients = getYTD_patients();
        Integer num_patients_w_consults = 0;
        Date ytd_start = Date.newinstance(System.today().year(),1,1);
        for(referral_lead rl : referral_list) {
          Boolean has_valid_consult = false;
          for(Consult_Inventory__c ci: rl.consults) {
                if(ci.apt_date__c>= ytd_start && !ci.isvalidcallback__c && ci.arrival_time__c!=null)
                  has_valid_consult = true;
          }
          if(has_valid_consult)
            num_patients_w_consults++;
        }
        if(num_patients==0)
          return 0.00;
        else
          return (num_patients_w_consults * 1.00)/(num_patients * 1.00);
  }

  public Decimal getlifetime_lead_consult_rate() {
        Integer num_patients = getlifetime_patients();
        Integer num_patients_w_consults = 0;
        for(referral_lead rl : referral_list) {
          Boolean has_valid_consult = false;
          for(Consult_Inventory__c ci: rl.consults) {
                if(!ci.isvalidcallback__c && ci.arrival_time__c!=null)
                  has_valid_consult = true;
          }
          if(has_valid_consult)
            num_patients_w_consults++;
        }
        if(num_patients==0)
          return 0.00;
        else
          return (num_patients_w_consults * 1.00)/(num_patients * 1.00);
  }

  public void show_center_view() {
        display_center_view = true;
        display_practice_view = false;
        referral_list = refresh_referral_list(center_id);
    referral_list.sort();
    calculate_page_info();
  }

  public void show_practice_view() {
        display_center_view = false;
        display_practice_view = true;
        referral_list = refresh_referral_list(referral_partner_id);
    referral_list.sort();
    calculate_page_info();
  }

  public List<referral_lead> refresh_referral_list(String rid) {
    Map<Id,referral_lead> lead_map = new Map<ID,referral_lead>();
    Map<Id,referral_lead> account_map = new Map<ID,referral_lead>();
    Set<Id> all_lead_ids = new Set<ID>();
    Set<Id> all_account_ids = new Set<ID>();
    Set<Id> all_opps_ids = new Set<ID>();
    String Lead_filter = ' (inbound_call__c != null and inbound_call__c != \'Non-Sales Call\') and ';
    String account_filter = ' ';
    List<referral_lead>rlist = new List<referral_lead>();
    if(display_practice_view) {
            if(rid=='All') {
              lead_filter += '  (referral_office__c != null  or convertedaccount.referral_office__c != null) ';
              account_filter += '  referral_office__c != null ';
            } else {
              lead_filter += ' (referral_office__c = \'' + rid + '\'  or convertedaccount.referral_office__c = \'' + rid + '\') ';
              account_filter += ' referral_office__c = \'' + rid + '\' ';
            }
    }
    if(display_center_view) {
      if(rid=='All') {
        lead_filter += '  (referral_office__c != null  or convertedaccount.referral_office__c != null) ';
            account_filter += '  referral_office__c != null ';
      } else {
        lead_filter += ' (referral_office__r.center_information__c = \'' + rid + '\'  or convertedaccount.referral_office__r.center_information__c = \'' + rid + '\') ';
            account_filter += ' referral_office__r.center_information__c = \'' + rid + '\' ';
      }
    }
    //check for filters
    if(name_filter!='') {
      lead_filter += ' and name like \'%' + name_filter + '%\' ';
      account_filter += ' and name like \'%' + name_filter + '%\' ';
    }
    Datetime sdate = Datetime.newinstance(sdate_holder.effective_date__c.year(),sdate_holder.effective_date__c.month(),sdate_holder.effective_date__c.day(),0,0,0);
    Datetime edate = Datetime.newinstance(edate_holder.effective_date__c.year(),edate_holder.effective_date__c.month(),edate_holder.effective_date__c.day(),0,0,0);
    lead_filter += ' and createddate >= ' + sdate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ';
    lead_filter += ' and createddate <= ' + edate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ';
    String sort_filter = ' order by createddate desc';
    //pull list of lead records and add to the map
    System.debug('Full Query ' + 'select id,name,convertedaccountid,objection__c,createddate from lead where ' + lead_filter + sort_filter);
    try {
    for(Lead l : database.query('select id,name,convertedaccountid,objection__c,createddate,referral_office__r.name from lead where ' + lead_filter  + sort_filter)) {
      all_lead_ids.add(l.id);
      referral_lead new_referral = new referral_lead(current_sort_direction,current_sort_field);
      new_referral.l = l;
      rlist.add(new_referral);
      lead_map.put(l.id,new_referral);
      if(l.convertedaccountid!=null)
        account_map.put(l.convertedaccountid,new_referral);
    }
    //pull list of lead records,  where the account was assigned to the partner
    /*for(Lead l : database.query('Select Id, Name,referral_office__c,convertedaccountid,convertedaccount.referral_office__c,objection__c,createddate FROM lead where convertedaccountid != null and referral_office__c = null ' + exception_filter)) {
      all_lead_ids.add(l.id);
      referral_lead new_referral = new referral_lead();
      new_referral.l = l;
      rlist.add(new_referral);
      lead_map.put(l.id,new_referral);
      account_map.put(l.convertedaccountid,new_referral);
    }*/
    //pull list of account records
    System.debug('Full Query ' + 'select id,name,createddate,Preliminary_Treatment_Plan__c  from account where ' + account_filter);
    for(Account a : database.query('select id,name,createddate,Preliminary_Treatment_Plan__c,referral_office__r.name  from account where ' + account_filter)) {
      all_account_ids.add(a.id);
      //we should always have a match here,  but doublecheck
      if(account_map.get(a.id)!=null) {
        account_map.get(a.id).a = a;
      }
      //commenting this out - the lead query should capture these already,  and it prevents me from having to maintain multiple filters.  Referral Date filter in particular is hard,
      //because lead created date and account created date will be very different fields.
      /*else {
        referral_lead new_referral = new referral_lead(current_sort_direction,current_sort_field);
        rlist.add(new_referral);
        new_referral.a = a;
        account_map.put(a.id,new_referral);
      }*/
    }
    //pull list of prosth exams
    for(Opportunity o : [select prosth_exam_paid_date__c,Final_Referral_Track__c,windent_prosth_date__c,windent_surgery_date__c,windent_final_date__c,is_valid_start__c,id,name,accountid,preliminary_treatment_plan__c,treatment_amount__c,negotiated_total_amount__c from Opportunity where accountid in :all_account_ids]) {
      all_opps_ids.add(o.id);
      if(account_map.get(o.accountid)!=null) {
        account_map.get(o.accountid).starts.add(o);
      }
    }
    //pull  all payments
    for(CCPayment__c cc : [select payment_date__c,payment_amount__c,opportunity__r.accountid,id,net_collection_amount__c,finance_fee__c,payment_status__c,payment_status_formula__c,opportunity__r.gp_fee_rate__c from CCPayment__c where opportunity__r.accountid in :all_account_ids]) {
      if(account_map.get(cc.opportunity__r.accountid)!=null) {
        account_map.get(cc.opportunity__r.accountid).payments.add(cc);
      }
    }
    //pull list of consults
    for(Consult_Inventory__c ci : [select isvalidcallback__c,arrival_time__c,id,apt_date__c,consult_show_status__c,scheduled_lead__c,scheduled_account__c from Consult_Inventory__c where scheduled_lead__c in :all_lead_ids or scheduled_account__c in : all_account_ids order by apt_date__c]) {
      if(ci.scheduled_lead__c!=null) {
        if(lead_map.get(ci.scheduled_lead__c)!=null)
          lead_map.get(ci.scheduled_lead__c).consults.add(ci);
      }
      else if(ci.scheduled_account__c!=null) {
        if(account_map.get(ci.scheduled_account__c)!=null)
          account_map.get(ci.scheduled_account__c).consults.add(ci);
      }
    }
    //pull list of tasks
    for(Task t : [select id,createddate,whoid,whatid,accountid from task where whoid in :all_lead_ids or whatid in :all_account_ids or whatid in :all_opps_ids or accountid in :all_account_ids]) {
      if(lead_map.get(t.whoid)!=null) {
        lead_map.get(t.whoid).all_tasks.add(t);
      }
      else if(account_map.get(t.whatid)!=null) {
        account_map.get(t.whatid).all_tasks.add(t);
      }
      else if(account_map.get(t.accountid)!=null) {
        account_map.get(t.accountid).all_tasks.add(t);
      }
      else
        System.debug('Unable to match task : ' + t);
    }
    //apply clinical or referral track filter
    if(clinical_status_filter!='Any' || track_filter!='Any') {
      List<referral_lead> filtered_list = new List<referral_lead>();
      for(referral_lead rl : rlist) {
        Boolean meets_criteria = true;
        if(clinical_status_filter!='Any') {
          if(!rl.getclinical_status().contains(clinical_status_filter))
            meets_criteria = false;
        }
        if(track_filter!='Any') {
          if(!rl.getreferral_track().contains(track_filter))
            meets_criteria = false;
        }
        if(meets_criteria)
          filtered_list.add(rl);
      }
      rlist = filtered_list;
    }
    return rlist;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error was encountered while trying to look up your referrals.  Please contact your rep for more assistance'));
      ApexPages.addMessages(e);
      return rlist;
    }
  }


  public String getJSON_practice_mix(){
    GoogleViz gv = new GoogleViz();

    gv.cols = new list<GoogleViz.col> {
      new GoogleViz.Col('col1','Treatment Plan','string'),
      new GoogleViz.Col('col2', 'Plan Count', 'number')
    };

    Integer single_count = 0;
    Integer multiple_count = 0;
    Integer ao4_count = 0;
    Integer dbl_count = 0;
    //System.debug('Treatment Plan JSON');
    for(referral_lead rl : referral_list) {
      //System.debug('Referral Lead : ' + rl.l.name + ' - ' + rl.gettreatment_plan());
      String tp = rl.gettreatment_plan();
      if(tp.contains('DBL') || tp.contains('Double AO4'))
        dbl_count++;
      else {
        Integer lower_count = 0;
        Integer upper_count = 0;
        if(tp.contains('AO4 Upper') || tp.contains('AO4 Edentulous Upper') || tp.contains('Upper AO4'))
          upper_count++;
        if(tp.contains('AO4 Lower') || tp.contains('AO4 Edentulous Lower') || tp.contains('Lower AO4'))
          lower_count++;
        if(lower_count>0 && upper_count>0)
          dbl_count++;
        else if(upper_count>0 || lower_count>0)
          ao4_count++;
        else if(tp.contains('Mulitple'))
          multiple_count++;
        else if(tp.contains('Single'))
          single_count++;
      }
    }

    GoogleViz.row r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('Single') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(single_count) ); // Quantity column
    gv.addRow( r );
    r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('Multiple') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(multiple_count) ); // Quantity column
    gv.addRow( r );
    r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('AO4') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(ao4_count) ); // Quantity column
    gv.addRow( r );
    r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('DBL AO4') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(dbl_count) ); // Quantity column
    gv.addRow( r );

    return gv.toJsonString();
  }

  public String getJSON_national_mix(){
    GoogleViz gv = new GoogleViz();

    gv.cols = new list<GoogleViz.col> {
      new GoogleViz.Col('col1','Treatment Plan','string'),
      new GoogleViz.Col('col2', 'Plan Count', 'number')
    };

    Integer single_count = 0;
    Integer multiple_count = 0;
    Integer ao4_count = 0;
    Integer dbl_count = 0;
    //System.debug('Treatment Plan JSON');
    for(referral_lead rl : refresh_referral_list('All')) {
      //System.debug('Referral Lead : ' + rl.l.name + ' - ' + rl.gettreatment_plan());
      String tp = rl.gettreatment_plan();
      if(tp.contains('DBL') || tp.contains('Double AO4'))
        dbl_count++;
      else {
        Integer lower_count = 0;
        Integer upper_count = 0;
        if(tp.contains('AO4 Upper') || tp.contains('AO4 Edentulous Upper') || tp.contains('Upper AO4'))
          upper_count++;
        if(tp.contains('AO4 Lower') || tp.contains('AO4 Edentulous Lower') || tp.contains('Lower AO4'))
          lower_count++;
        if(lower_count>0 && upper_count>0)
          dbl_count++;
        else if(upper_count>0 || lower_count>0)
          ao4_count++;
        else if(tp.contains('Mulitple'))
          multiple_count++;
        else if(tp.contains('Single'))
          single_count++;
      }
    }

    GoogleViz.row r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('Single') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(single_count) ); // Quantity column
    gv.addRow( r );
    r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('Multiple') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(multiple_count) ); // Quantity column
    gv.addRow( r );
    r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('AO4') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(ao4_count) ); // Quantity column
    gv.addRow( r );
    r = new GoogleViz.row();
    r.cells.add ( new GoogleViz.cell('DBL AO4') ); // TP Name column
    r.cells.add ( new GoogleViz.cell(dbl_count) ); // Quantity column
    gv.addRow( r );

    return gv.toJsonString();
  }

  public void resort_list() {
    for(referral_lead rl : referral_list) {
      rl.sort_dir = current_sort_direction;
      rl.sort_field = current_sort_field;
    }
    referral_list.sort();
  }

  public void reverse_sort_direction() {
        if(current_sort_direction=='ascending')
          current_sort_direction = 'descending';
        else
          current_sort_direction = 'ascending';
  }

  public void gp_sort() {
        if(current_sort_field=='gp_fee')
          reverse_sort_direction();
        else {
          current_sort_field = 'gp_fee';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void collected_sort() {
        if(current_sort_field=='collected')
          reverse_sort_direction();
        else {
          current_sort_field = 'collected';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void sold_sort() {
        if(current_sort_field=='sold')
          reverse_sort_direction();
        else {
          current_sort_field = 'sold';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void track_sort() {
        if(current_sort_field=='track')
          reverse_sort_direction();
        else {
          current_sort_field = 'track';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void treatment_sort() {
        if(current_sort_field=='treatment')
          reverse_sort_direction();
        else {
          current_sort_field = 'treatment';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void cstatus_sort() {
        if(current_sort_field=='cstatus')
          reverse_sort_direction();
        else {
          current_sort_field = 'cstatus';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void name_sort() {
        if(current_sort_field=='name')
          reverse_sort_direction();
        else {
          current_sort_field = 'name';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public void date_sort() {
        if(current_sort_field=='rdate')
          reverse_sort_direction();
        else {
          current_sort_field = 'rdate';
          current_sort_direction = 'ascending';
        }
        resort_list();
  }

  public List<Selectoption> getclinical_status_list() {
        List<selectoption> option_list = new List<SelectOption>();
        option_list.add(new SelectOption('Any','Any Status'));
        option_list.add(new SelectOption('Lead Referred','Lead Referred'));
        option_list.add(new SelectOption('Consult Scheduled','Consult Scheduled'));
        option_list.add(new SelectOption('No Show','Consult - No Show'));
        option_list.add(new SelectOption('Consult Incomplete','Consult Incomplete'));
        option_list.add(new SelectOption('Consult Completed','Consult Completed'));
        option_list.add(new SelectOption('Prosth Exam','Prosth Exam Done'));
        option_list.add(new SelectOption('Surgery','Surgery Done'));
        option_list.add(new SelectOption('Final Delivery','Final Delivery Done'));
        return option_list;
  }

  public List<Selectoption> getreferral_track_list() {
        List<selectoption> option_list = new List<SelectOption>();
        option_list.add(new SelectOption('Any','Any Track'));
    for(Schema.PicklistEntry Value : Opportunity.Final_Referral_Track__c.getDescribe().getPicklistValues()) {
      option_list.add(new SelectOption(Value.getValue(),Value.getLabel()));
        }
        return option_list;
  }

  public List<Selectoption> getPractice_List() {
    //return a list of all practices in the program (figure out filter with Nat)
    List<Selectoption> plist = new List<Selectoption>();
    plist.add(new Selectoption('All','All Partner Practices'));
    for(Dental_Practice__c dp :[select id,name from Dental_practice__c order by name]) {
      plist.add(new Selectoption(dp.id,dp.name));
    }
    return plist;
  }

  public List<Selectoption> getCenter_List() {
    //return a list of all practices in the program (figure out filter with Nat)
    List<Selectoption> plist = new List<Selectoption>();
    plist.add(new Selectoption('All','All Centers'));
    for(Center_Information__c ci :[select id,name,calendar_name__c from Center_Information__c where name not in ('Chicago Deerfield/Northbrook') order by name]) {
      plist.add(new Selectoption(ci.id,ci.name));
    }
    return plist;
  }
}