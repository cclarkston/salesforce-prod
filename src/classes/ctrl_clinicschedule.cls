public without sharing class ctrl_clinicschedule {
  public Boolean testing = Test.isRunningTest();
  public CalendarMonth cmonth;
  public String calendar_view {get;set;}
  public Date selected_date {get;set;}
  public String troubleshoot_msg {get; set;}
  public String selected_center {get; set;}
  public String consult_pec {get; set;}
  public String selected_market;
  public String selected_center_name;
  public Boolean display_admin;
  public Boolean display_practice;
  public Boolean display_pec;
  public Boolean block_pec;
  public Integer row_count;
  public String hold_message {get; set;}
  public Weather__c current_weather {get; set;}

  //consult search variables
  public String search_name {get; set;}
  public String search_phone {get; set;}
  public Boolean search_past {get; set;}
  public String search_issues {get; set;}
  public Consult_Inventory__c[] search_results {get; set;}
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

  public Consult_Status[] todays_apts {get; set;}

  public String main_view {get; set;}
  //public Account scheduling_account {get; set;}
  //public Consult_Rooms__c new_room {get; set;}
  //public Lead scheduling_lead {get; set;}
  //public Consult_Room_Note__c new_note {get; set;}
  //public Consult_Room_Note__c end_note {get; set;}
  public Consult_Inventory__c view_apt {get; set;}
  //variables used to control the display of the modal-popup
  public Boolean modal_display {get; set;}
  //public Boolean reschedule {get; set;}
  //public string reschedule_notes {get; set;}
  //public string reschedule_treatment {get; set;}
  public String modal_type {get; set;}
  public String modal_out {get; set;}

  public ctrl_clinicschedule() {
        if(apexpages.currentpage().getparameters().get('aid')==null) {
          selected_date = System.today();
        }
        else {
                Consult_Inventory__c passed_block = [select apt_date__c from Consult_Inventory__c where id = :apexpages.currentpage().getparameters().get('aid')];
          selected_date = passed_block.apt_date__c;
        }
        if(apexpages.currentPage().getParameters().get('cdate')!=null)
          selected_date = Date.parse(apexpages.currentpage().getparameters().get('cdate'));
        consult_pec = '';
        System.debug('Selected Date : ' + selected_date);
        //selected_date = System.today();
        modal_display = false;
        modal_out = '';
        //today_date = today_date.addDays(7);
        calendar_view = 'calendar';
        main_view = 'consult_view';
        troubleshoot_msg = '';
        Center_Information__c user_center;
        if(apexpages.currentpage().getparameters().get('cid')==null) {
                User u = [select clinic_calendar__c from user where id =:userinfo.getUserId()];
                if(u.clinic_calendar__c==null)
                        user_center = [select id,market__c from Center_Information__c where name = 'Unknown'];
            else
              user_center = [select id,market__c from Center_Information__c where name = :u.clinic_calendar__c];
        }
        else
                user_center = [select id,market__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('cid')];
        selected_center = user_center.id;
          selected_market = user_center.market__c;
    System.debug('Start Center : ' + selected_center);
    cmonth = new CalendarMonth(selected_date,selected_center);
    if(userinfo.getName()=='Chris McDowell') {
      //display_admin = false;
    }
      refresh_inprogress();
    current_weather = getweather_info(selected_date);
  }

  public Integer getcenter_total_open_days() {
        //return the number of days the selected center is open for the current month (selected date)
        Date sdate = date.newinstance(selected_date.year(),selected_date.month(),1);
        Date edate = sdate.addmonths(1);
        edate = edate.adddays(-1);
        Integer cnt = [select count() from Center_Open_Day__c where open_status__c = 'Open' and calendar_date__c >= :sdate  and calendar_date__c <= :edate and center_information__c = :selected_center];
        return cnt;
  }

  public String getformatted_sdate() {
        Datetime sdate = datetime.newinstance(selected_date.year(),selected_date.month(),selected_date.day(),1,10,0);
        return sdate.format('M/dd/yyyy');
  }

  public boolean getnetwork_center_user() {
        //test to see if this user is a network center admin (clinic calendar is set for a center that is type = Network Center)
        User u = [select id,clinic_calendar__c from User where id =:userinfo.getUserId()];
        if(u.clinic_calendar__c==null)
          return false;
        else {
          Center_Information__c ci = [select id,name,type__c from Center_Information__c where name = :u.Clinic_Calendar__c];
          if(ci.type__c=='Network Center')
            return true;
          else
            return false;
        }
  }

  public String getconsult_link() {
        //String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
        String hyper_link = '/apex/sandbox_calendar?cdate=' + selected_date.format() + '&cid=' + selected_center;
        return hyper_link;
  }

  public void refresh_inprogress() {
    todays_apts  = new Consult_Status[] {};
    Consult_Inventory__c[] consult_inventory =  [select c.add_ons__c,c.callback_consult__c,c.Patient_name__c,c.consult_show_status__c,arrival_time__c,consult_completed__c,consult_started__c,left_time__c,ready_time__c,c.Patient_Converted__c,c.scheduled_lead__c,c.scheduled_account__c,c.scheduled_account__r.name,c.scheduled_patient__c, c.scheduled_patient__r.first_name__c,c.scheduled_patient__r.last_name__c from Consult_Inventory__c c where c.apt_date__c = :selected_date and c.active__c = true and c.consult_room__r.center_information__c = :selected_center];
    for(Consult_Inventory__c ci : consult_inventory) {
        Consult_Status this_apt = new Consult_Status(ci);
        todays_apts.add(this_apt);
    }
  }

  public class Consult_Status {
        public Consult_Inventory__c consult {get; set;}
        public Consult_Status (Consult_Inventory__c ci) {
                this.consult = ci;
        }
        public String getpname() {
          if(this.consult.patient_name__c!=null)
            return this.consult.patient_name__c;
          else if(this.consult.scheduled_account__c!=null)
            return this.consult.scheduled_account__r.name;
          else if(this.consult.scheduled_patient__c!=null)
            return this.consult.scheduled_patient__r.first_name__c + ' ' + this.consult.scheduled_patient__r.last_name__c;
          else
            return 'Name not Found';
        }
        public String gettime_label() {
                String timer = '';
                Datetime start_time;
                Integer alert_threshold = 900;
                if(this.consult.consult_show_status__c=='Arrived')
                  start_time = this.consult.arrival_time__c;
                if(this.consult.consult_show_status__c=='Ready for Consult')
                  start_time = this.consult.ready_time__c;
                if(this.consult.consult_show_status__c=='Consult Started') {
                  start_time = this.consult.consult_started__c;
                  alert_threshold = 4500;
                }
                if(start_time!=null) {
                        Long seconds = System.now().gettime() - start_time.gettime();
                        seconds = seconds / 1000;
                        Long seconds_pos = math.mod(seconds,60);
                        Decimal minutes = seconds / 60;
                        minutes = math.floor(minutes);
                        String seconds_text = '';
                        if(seconds_pos<10)
                          seconds_text = '0' + string.valueof(seconds_pos);
                        else
                          seconds_text = string.valueof(seconds_pos);
                        //System.debug('Status : ' + this.consult.consult_show_status__c + ' Threshold : ' + alert_threshold + ' Seconds : ' + seconds);
                        if(seconds >= alert_threshold)
                          timer = '<span class="timer_alert">';
                        else
                          timer += '<span class="timer">';
                        timer +=  string.valueof(minutes) + ':' + seconds_text + '</span>';
                }
                return timer;
        }
        public String getconverted_status() {
                String cstatus = '';
                if(this.consult.scheduled_account__c!=null)
                  cstatus = '<span style="color:blue;font-weight:bold;">Converted</span>';
                else if(this.consult.scheduled_patient__c!=null)
                  cstatus = '<span style="color:blue;font-weight:bold;">Patient</span>';
                else if(this.consult.scheduled_lead__c!=null) {
                        if(this.consult.patient_converted__c==1)
                          cstatus = '<span style="color:blue;font-weight:bold;">Converted</span>';
                        else
                          cstatus = '<span style="color:red;font-weight:bold;">Not Converted</span>';
                }
                return cstatus;
        }
  }

  public Consult_Status[] search_todays_apts(String status_search) {
        Consult_Status[] search_list = new Consult_Status[] {};
        for(Consult_Status ci : todays_apts) {
                if(ci.consult.consult_show_status__c == status_search)
                  search_list.add(ci);
        }
        return search_list;
  }

  public Consult_Status[] getarrived_list() {
        return search_todays_apts('Arrived');
  }

  public Integer getarrived_list_size() {
        return search_todays_apts('Arrived').size();
  }

  public Consult_Status[] getready_list() {
        return search_todays_apts('Ready for Consult');
  }

  public Integer getready_list_size() {
        return search_todays_apts('Ready for Consult').size();
  }

  public Consult_Status[] getstarted_list() {
        return search_todays_apts('Consult Started');
  }

  public Integer getstarted_list_size() {
        return search_todays_apts('Consult Started').size();
  }

  public Consult_Status[] getcompleted_list() {
        return search_todays_apts('Consult Completed');
  }

  public Integer getcompleted_list_size() {
        return search_todays_apts('Consult Completed').size();
  }

  public Consult_Status[] getleft_list() {
        return search_todays_apts('Patient Left');
  }

  public Integer getleft_list_size() {
        return search_todays_apts('Patient Left').size();
  }

  public Consult_Status[] getnoshow_list() {
        return search_todays_apts('No Show');
  }

  public Integer getnoshow_list_size() {
        return search_todays_apts('No Show').size();
  }

  public String getselected_center_name() {
        if(selected_center_name==null)
      selected_center_name = [select name from Center_information__c where id = :selected_center].name;
    return selected_center_name;
  }

  public void update_nocontact() {
        modal_out = '';
        try {
                Consult_Inventory__c old_apt = getapt_block(view_apt.id);
                String history_notes = '';
      if(view_apt.No_Show_Contacted__c<> old_apt.No_Show_Contacted__c) {
        history_notes += 'No Show contacted changed from ' + old_apt.No_Show_Contacted__c + ' to ' +  view_apt.No_Show_Contacted__c + '<br />';
        if(view_apt.No_Show_Contacted__c)
          view_apt.status_exported__c = false;
      }
      if(view_apt.No_Show_Contacted_Notes__c<> old_apt.No_Show_Contacted_Notes__c ) {
        history_notes += 'No Show Contacted Notes changed from ' + old_apt.No_Show_Contacted_Notes__c + ' to ' + view_apt.No_Show_Contacted_Notes__c + '<br />';
        try {
                FeedItem post = new FeedItem();
                if(view_apt.scheduled_account__c != null)
                                          post.ParentId = view_apt.scheduled_account__c;
                else if(view_apt.scheduled_patient__c != null)
                  post.ParentId = view_apt.scheduled_patient__c;
                else
                                          post.ParentId = view_apt.Scheduled_Lead__c;
                                        post.Body = 'No Show contact Notes : ' + view_apt.No_Show_Contacted_Notes__c;
                                        insert post;
        }
        catch (Exception e) {
                ///not really concerned if the chatter inster fails - this is just a bonus righ now that I'm testing out.
        }
      }
                //status_exported__c = false
                update view_apt;
      //compare the fields and build the history notes
                  if(history_notes.length()>255)
                    history_notes = history_notes.substring(0,253);
                  //make sure there actually was a change....if not,  don't record an entry
                  if(history_notes.length()>0) {
        Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Modify', notes__c = history_notes);
        insert history;
                  }
                view_apt = getapt_block(view_apt.id);
                modal_out = '<span style="font-weight:bold;color:blue;">Changes Saved</span>';
        }
        catch (System.DmlException e) {
          for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
    }
  }

  public void update_woreason() {
        modal_out = '';
        try {
                Consult_Inventory__c old_apt = getapt_block(view_apt.id);
                String history_notes = '';
      if(view_apt.Walk_Out_Reason__c <> old_apt.Walk_Out_Reason__c)
        history_notes += 'Walk Out Reason changed from ' + old_apt.Walk_Out_Reason__c + ' to ' +  view_apt.Walk_Out_Reason__c + '<br />';
                //status_exported__c = false
                update view_apt;
      //compare the fields and build the history notes
                  if(history_notes.length()>255)
                    history_notes = history_notes.substring(0,253);
                  //make sure there actually was a change....if not,  don't record an entry
                  if(history_notes.length()>0) {
        Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Modify', notes__c = history_notes);
        insert history;
                  }
                view_apt = getapt_block(view_apt.id);
                modal_out = '<span style="font-weight:bold;color:blue;">Changes Saved</span>';
        }
        catch (System.DmlException e) {
          for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
    }
  }

  public void display_apt_details() {
        view_apt = getapt_block(Apexpages.currentPage().getParameters().get('anum'));
        System.debug('View : ' + view_apt);
        modal_out = '';
        modal_display = true;
        modal_type = 'apt_view';
  }

  public void history_view() {
        modal_type = 'history_view';
  }

  public void apt_view() {
        modal_type = 'apt_view';
  }

  public List<Apt_History__c> getapt_history() {
        if(view_apt==null) {
      if(apexpages.currentpage().getparameters().get('anum')!=null)
            view_apt = getapt_block(Apexpages.currentPage().getParameters().get('anum'));
        }
        System.debug('View Apt : ' + view_apt);
        if(view_apt==null)
          return null;
        else {
          List<Apt_History__c> all_history = [Select a.Notes__c, a.Name, a.Lead__c, a.lead__r.name, a.CreatedDate, a.CreatedById, a.createdby.name, a.Consult_Inventory__c, a.Action__c, a.Account__c, a.account__r.name, a.private_practice_patient__c, a.private_practice_patient__r.full_name__c From Apt_History__c a where a.consult_inventory__c = :view_apt.id order by createddate];
          return all_history;
        }
  }

  public void close_modal() {
        modal_display = false;
        modal_out = '';
  }

  public Consult_Inventory__c getapt_block(String apt_id) {
    Consult_Inventory__c my_apt = [Select c.check_in_code__c,c.add_ons__c,c.scheduled_lead__c,c.scheduled_account__r.referral_location__c,c.patient_referral_office__c, c.started_by_someone_else__c,c.Patient_Work__c,c.Walk_Out_Reason__c,c.status_exported__c,c.no_show_contacted__c,c.no_show_contacted_notes__c,c.Consult_Pec__c,c.patient_mobile__c,c.patient_name__c,c.patient_phone__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.distance_to_center__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_lead__r.leadscore__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.distance_to_center__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.arrival_time__c,c.consult_started__c,c.ready_time__c,c.consult_completed__c,c.Patient_Warranty_ID__c,c.scheduled_patient__c, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__r.full_name__c From Consult_Inventory__c c where c.id =:apt_id];
    consult_pec = my_apt.consult_pec__c;
    return my_apt;
  }

  public String getCheck_in_Code() {
        //this field could update in the background,  so I'm grabbing it directly,  rather than using a value tied to the view apt variable
        return [select check_in_code__c from Consult_Inventory__c where id = :view_apt.id].check_in_code__c;
  }

  public void generate_checkin_code() {
        String my_code = guidGenerator.generateCheckCode();
        view_apt.check_in_code__c = my_code;
        try {
          update view_apt;
        } catch (System.DmlException e) {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
    }
  }

  public Boolean getdisplay_check_in_code_btn() {
        //see if this is a center currently allowed to do this
        Set<String> valid_centers = new Set<String>{'Denver','Test Center'};
        if(!valid_centers.contains(selected_center_name==null?getselected_center_name():selected_center_name)) {
          System.debug('Exiting because center was not a valid option ' + selected_center + ' ' + selected_center_name);
          return false;
        }
        //just make sure we have someone in the block
    if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null) {
      if(view_apt.check_in_code__c==null) {
        if(view_apt.consult_show_status__c==null || view_apt.consult_show_status__c=='Arrived' || view_apt.consult_show_status__c=='Ready for Consult')
          return true;
        else
          return false;
      }
      else
        return false;
    }
    else
      return false;
  }

  public Boolean getdisplay_arrived_btn() {
        if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null)
        //if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
                if(view_apt.Consult_Show_Status__c==null && (selected_date==system.today() || display_admin))
                  return true;
                else
                  return false;
          else
            return false;
  }

  public Boolean getdisplay_noshow_btn() {
        if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null)
        //if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
                if(view_apt.Consult_Show_Status__c==null && (selected_date==system.today() || display_admin))
                  return true;
                else
                  return false;
          else
            return false;
  }

  public Boolean getdisplay_ready_btn() {
        if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null)
        //if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
                if(view_apt.Consult_Show_Status__c=='Arrived' && (selected_date==system.today() || display_admin))
                  return true;
                else
                  return false;
          else
            return false;
  }

  public Boolean getdisplay_started_btn() {
        if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null)
        //if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
                if(view_apt.Consult_Show_Status__c=='Ready for Consult' && (selected_date==system.today() || display_admin))
                  return true;
                else
                  return false;
          else
            return false;
  }

  public Boolean getdisplay_completed_btn() {
        if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null)
        //if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
                if(view_apt.Consult_Show_Status__c=='Consult Started' && (selected_date==system.today() || display_admin))
                  return true;
                else
                  return false;
          else
            return false;
  }

  public Boolean getdisplay_left_btn() {
        if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null)
        //if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null)
          if((view_apt.Consult_Show_Status__c=='Arrived' || view_apt.Consult_Show_Status__c=='Ready for Consult') && (selected_date==system.today() || display_admin))
            return true;
          else
            return false;
        else
          return false;
  }

  public Boolean getdisplay_reset() {
    if(view_apt.Patient_Name__c!=null || view_apt.scheduled_account__c!=null || view_apt.scheduled_patient__c!=null) {
      Integer admin_count = [select count() from Profile where name in ('CC Schedule Admin','Data Audit Team','System Administrator','RBD','New System Administrator','System Administration - Test','Call Center - Supervisor','Call Center - Supervisor Test','CC Administrator', 'CC Administrator Development Tester', 'Call Center Admin', 'Call Center Agent Lead', 'CC - Network Center Supervisor') and id = :Userinfo.getProfileId()];
      if(admin_count>0)
        return true;
      else {
        User u = [select center_administrator__c,reset_override__c from User where id = :Userinfo.getUserId()];
        if((u.Center_Administrator__c || u.reset_override__c) && (view_apt.Consult_Show_Status__c != 'Consult Started' && view_apt.Consult_Show_Status__c != 'Consult Completed'))
          return true;
        else
          return false;
      }
    }
    else
      return false;
  }

  public void mark_patient_reset() {
        view_apt.Consult_Show_Status__c = null;
        view_apt.Arrival_Time__c = null;
        view_apt.Consult_Completed__c = null;
        view_apt.Consult_Started__c = null;
        view_apt.Left_Time__c = null;
        view_apt.Ready_Time__c = null;
        try {
                update view_apt;
          make_history_entry('Reset','CA or Admin has reset this apt block');
          view_apt = getapt_block(view_apt.id);
                modal_display = false;
        }
        catch (System.DmlException e) {
          for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
    }
    refresh_inprogress();
  }

  public void mark_patient_arrived() {
        Consult_Inventory__c check_apt = getapt_block(view_apt.id);
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(check_apt.Consult_Show_Status__c==null) {
          view_apt.Arrival_Time__c = System.now();
          view_apt.Consult_Show_Status__c = 'Arrived';
          try {
            update view_apt;
            make_history_entry('Arrived','Consult status has been changed to Arrived');
            view_apt = getapt_block(view_apt.id);
            modal_display = false;
          }
          catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
              modal_out += e.getDmlMessage(i) + '<br />';
            }
          }

        }
    refresh_inprogress();
  }

  public void mark_patient_ready() {
        Consult_Inventory__c check_apt = getapt_block(view_apt.id);
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(check_apt.Consult_Show_Status__c=='Arrived') {
                view_apt.Ready_Time__c = System.now();
                view_apt.Consult_Show_Status__c = 'Ready for Consult';
                try {
                        update view_apt;
                  make_history_entry('Ready','Consult status has been changed to Ready for Consult');
                  view_apt = getapt_block(view_apt.id);
                        modal_display = false;
                }
                catch (System.DmlException e) {
                  for (Integer i = 0; i < e.getNumDml(); i++) {
                modal_out += e.getDmlMessage(i) + '<br />';
              }
            }
        }
    refresh_inprogress();
  }

  public void mark_patient_started() {
        Consult_Inventory__c check_apt = getapt_block(view_apt.id);
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(check_apt.Consult_Show_Status__c=='Ready for Consult') {
                view_apt.Consult_Started__c = System.now();
                if(check_apt.Consult_PEC__c==null) {
                  modal_out += '<span style="color:red;font-weight:bold;">You must select a Consult PEC before continuing.</span>';
                  return;
                }
                view_apt.Consult_Show_Status__c = 'Consult Started';
                try {
                        update view_apt;
                  make_history_entry('Started','Consult status has been changed to Consult Started');
                  view_apt = getapt_block(view_apt.id);
                  //pulled this so the block would stay open for PEC selection.
                        //modal_display = false;
                }
                catch (System.DmlException e) {
                  for (Integer i = 0; i < e.getNumDml(); i++) {
                modal_out += e.getDmlMessage(i) + '<br />';
              }
            }
            //check to see if this is a Vantage Referral - if so we need to call out with a status update
          /* removed 2/22/2016 by CM - cutting ClearConnect stuff
          try {
            if(view_apt.scheduled_lead__c!=null) {
              if(view_apt.patient_referral_office__c!=null)
                if(view_apt.patient_referral_office__c!='')

                  myWS.updatereferral_consultstatus(view_apt.scheduled_leaD__c,view_apt.apt_date__c,'Consult Started',' ');
                }
          }
          catch (Exception e) {
            System.debug('Callout error: '+ e);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an Error calling Vantage API - Referral Update ');
                    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
          }*/
        }
    refresh_inprogress();
  }

  public void mark_patient_complete() {
        Consult_Inventory__c check_apt = getapt_block(view_apt.id);
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(check_apt.Consult_Show_Status__c=='Consult Started') {
                view_apt.Consult_Completed__c = System.now();
                view_apt.Consult_Show_Status__c = 'Consult Completed';
                try {
                        update view_apt;
                  make_history_entry('Completed','Consult status has been changed to Consult Completed');
                  view_apt = getapt_block(view_apt.id);
                        modal_display = false;
                }
                catch (System.DmlException e) {
                  for (Integer i = 0; i < e.getNumDml(); i++) {
                modal_out += e.getDmlMessage(i) + '<br />';
              }
            }
            //check to see if this is a Vantage Referral - if so we need to call out with a status update
          /*removed by cm on 2/22/2016 cutting clearconnect stuff
          try {
            if(view_apt.scheduled_lead__c!=null) {
              if(view_apt.patient_referral_office__c!=null)
                if(view_apt.patient_referral_office__c!='')
                  myWS.updatereferral_consultstatus(view_apt.scheduled_leaD__c,view_apt.apt_date__c,'Consult Completed',' ');
                }
          }
          catch (Exception e) {
            System.debug('Callout error: '+ e);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an Error calling Vantage API - Referral Update ');
                    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
          }*/
        }
    refresh_inprogress();
  }

  public void mark_patient_left() {
        Consult_Inventory__c check_apt = getapt_block(view_apt.id);
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(check_apt.Consult_Show_Status__c=='Arrived' || check_apt.Consult_Show_Status__c=='Ready for Consult' ) {
                view_apt.Left_Time__c = System.now();
                view_apt.Consult_Show_Status__c = 'Patient Left';
                try {
                        update view_apt;
                  make_history_entry('Left','Consult status has been changed to Patient Left');
                  view_apt = getapt_block(view_apt.id);
                        modal_display = true;
                }
                catch (System.DmlException e) {
                  for (Integer i = 0; i < e.getNumDml(); i++) {
                modal_out += e.getDmlMessage(i) + '<br />';
              }
            }
        }
    refresh_inprogress();
  }

  public void mark_patient_noshow() {
        Consult_Inventory__c check_apt = getapt_block(view_apt.id);
        //double check and verify that someone else hasn't hit the button already or moved them further up the stream
        if(check_apt.Consult_Show_Status__c==null) {
                view_apt.Consult_Show_Status__c = 'No Show';
                try {
                        update view_apt;
                  make_history_entry('No Show','Consult status has been changed to No Show');
                  view_apt = getapt_block(view_apt.id);
                        modal_display = true;
                }
                catch (System.DmlException e) {
                  for (Integer i = 0; i < e.getNumDml(); i++) {
                modal_out += e.getDmlMessage(i) + '<br />';
              }
            }
            //check to see if this is a Vantage Referral - if so we need to call out with a status update
          /*removed by cm on 2/22/2016 - removing clearconnect stuff
          try {
            if(view_apt.scheduled_lead__c!=null) {
              if(view_apt.patient_referral_office__c!=null)
                if(view_apt.patient_referral_office__c!='')
                  myWS.updatereferral_consultstatus(view_apt.scheduled_leaD__c,view_apt.apt_date__c,'No Show',' ');
                }
          }
          catch (Exception e) {
            System.debug('Callout error: '+ e);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('There was an Error calling Vantage API - Referral Update ');
                    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
          }*/
        }
        else
          modal_out += 'Patient is not eligible for this status';
    refresh_inprogress();
  }

  public String getarrival_time() {
        if(view_apt.arrival_time__c==null)
          return '';
        else
          return view_apt.Arrival_time__c.format('h:mm:ss a');
          //return view_apt.Arrival_time__c.formatLong();
  }

  public String getready_time() {
        if(view_apt.ready_time__c==null)
          return '';
        else
          return view_apt.ready_time__c.format('h:mm:ss a');
  }

  public String getstarted_time() {
        if(view_apt.consult_started__c==null)
          return '';
        else
          return view_apt.consult_started__c.format('h:mm:ss a');
  }

  public String getcompleted_time() {
        if(view_apt.consult_completed__c==null)
          return '';
        else
          return view_apt.consult_Completed__c.format('h:mm:ss a');
  }

  public void make_history_entry(String action_text, String notes_text) {
        Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_practice_Patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = action_text, notes__c = notes_text);
        try {
      insert history;
        }
        catch(Exception e) {
                //holder
        }
  }

  public Integer check_for_active_hold() {
        Integer h = 0;
        System.debug('Hold Check : ' + h);
        for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :view_apt.id and active_hold__c = true ]) {
                //see if the hold_time is less than 5 minutes old
                Datetime h_end_time = ch.hold_time__c;
                //h_end_time = h_end_time.addMinutes(5);
                h_end_time = h_end_time.addHours(2);
                if(System.now()<h_end_time) {
                  h++;
                  hold_message = 'Block Held by : ' + ch.hold_by__r.name + '.<br />Hold will be released at : <br />' + h_end_time.format('M/dd/yyyy hh:mm:ss a') ;
                }
        }
        System.debug('Hold Check : ' + h);
        return h;
  }

  public Boolean getallow_hold() {
        Boolean hold = true;
        //make sure the lead does not have an active consult on the calendar
        Integer i = 0;
        String schedule_pre_screen;
        i += check_for_active_hold();
        if(i>0)
          hold = false;
        else {
                //check the days between today and the selected date
                Date tdate = System.today();
            Integer days_diff = tdate.daysBetween(view_apt.apt_date__c);
                //if days between is negative,  then a hold is unnecessary
            if(days_diff<0)
              hold = false;
    }
        if(view_apt.Scheduled_Lead__c!=null || view_apt.Scheduled_Account__c!=null || view_apt.scheduled_patient__c!=null)
          hold = false;
        return hold;
  }

    public void place_hold() {
        Consult_Inventory__c apt_check = [select c.scheduled_patient__c, c.scheduled_account__c,c.scheduled_lead__c,c.consult_room__r.center_information__c from Consult_Inventory__c c where c.id = :view_apt.id];
        if(apt_check.Scheduled_lead__c==null && apt_check.scheduled_account__c==null && apt_check.scheduled_patient__c==null) {
                Integer h = check_for_active_hold();
                if(h==0) {
                try {
                        Consult_Holds__c ch = new Consult_Holds__c(Consult_Inventory__c = view_apt.id, Hold_by__c = Userinfo.getuserid(), hold_time__c = System.now(),Active_Hold__c = true );
                        insert ch;
                  Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Private_Practice_patient__c = view_apt.scheduled_patient__c, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Hold', notes__c = 'A Hold was placed on this apt block');
                    insert history;
                }
                catch (Exception e) {

                }
          }
        }
  }


  public void display_consults() {
        main_view='consult_view';
        modal_display = false;
  }

  public Integer getsearch_size() {
        if(search_results==null)
          return 0;
        else
         return search_results.size();
  }

  public void display_search() {
        main_view='consult_search';
        modal_display = false;
  }

  public void next_page() {
                try {
                        page++;
                        refresh_consult_matches();
                }
                catch(Exception e) {  system.debug ('error: ' + e.getMessage() );    }
        }

        public void prev_page() {
                page = page - 1;
                refresh_consult_matches();
        }

  public void refresh_consult_matches() {
        Center_Information__c cu = [select id,market__c from Center_Information__c where id = :selected_center];
        selected_market = cu.market__c;
        search_results = new Consult_Inventory__c[] {};
        Consult_Inventory__c[] temp_results = new Consult_Inventory__c[] {};
        String query_filter = ' active__c = true and consult_room__r.center_information__r.market__c = :selected_market ';
        System.debug('Search Name : ' + search_name);
        if(search_name != null && search_name<>'')
          query_filter += ' and (patient_name__c like \'%' + search_name + '%\' or scheduled_account__r.name like \'%' + search_name +  '%\' or scheduled_patient__r.full_name__c like \'%' + search_name + '%\') ';
        //System.debug('Search Phone : ' + search_phone);
        if(search_phone != null && search_phone<>'') {
          query_filter += ' and (patient_phone__c like \'%' + search_phone + '%\' or patient_mobile__c like \'%' + search_phone + '%\' or scheduled_account__r.PersonMobilePhone like \'%' + search_phone + '%\' or scheduled_account__r.PersonHomePhone like \'%' + search_phone + '%\' or scheduled_patient__r.main_phone__c like \'%' + search_phone + '%\' or scheduled_patient__r.alt_phone__c like \'%' + search_phone + '%\')  ';
        }
        System.debug('Search Past : ' + search_past);
        if(search_past==false)
          query_filter += ' and apt_date__c >= today';
        String base_query = 'Select id,consult_room__r.center_information__r.name,start_hour_int__c,start_minute_int__c,start_minute__c,apt_date__c,Patient_Name__c, Patient_Phone__c,  Patient_Mobile__c,  scheduled_account__r.name,  scheduled_account__r.PersonMobilePhone,  scheduled_account__r.PersonHomePhone, scheduled_patient__r.Main_Phone__c, scheduled_patient__r.Last_Name__c, scheduled_patient__r.First_Name__c, scheduled_patient__r.CreatedDate, scheduled_patient__r.Center__c, scheduled_patient__r.center__r.name, scheduled_patient__r.Alt_Phone__c, scheduled_patient__r.id, scheduled_patient__c, scheduled_patient__r.full_name__c from Consult_Inventory__c where ';
        if(search_name=='' && search_phone=='')
          search_issues = 'You didn\'t enter any valid search criteria.  Please try again<br />';
        else {
        //      search_issues = base_query + query_filter;
                System.debug('Search Consults : ' + base_query + query_filter);
                //search_results = database.query(base_query + query_filter + ' order by apt_date__c limit 20');
                temp_results = search_results = database.query(base_query + query_filter + ' order by apt_date__c desc limit 100');
                record_count = temp_results.size();
                  page_holder = math.ceil((record_count/records_per_page));
                  num_pages = page_holder.intvalue();
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
                        List<Consult_Inventory__c> ci2 = new List<Consult_Inventory__c>{};
                        for(Consult_Inventory__c ci : temp_results) {
                    if(cnt > low_range && cnt <= high_range)
                                ci2.add(ci);
                                cnt++;
                        }
                        search_results = ci2;
        }
  }

  public void consult_search() {
        refresh_consult_matches();
  }

  public void display_printview() {
        main_view='print_view';
        modal_display = false;
  }

  //4-14-2014
  //using this to determine if the user is in a PEC profile and shouldn't have access to view something (scheduled by and history names in this case)
  public Boolean getblock_pec() {
        if(block_pec==null) {
          Integer admin_count = [select count() from Profile where name in ('PEC - NoPScreen - No Dash','PEC - TPLAN','FOA - TPLAN','FOA - No Prescreen - TPlan','PEC - No Prescreen - PPF','PEC - PPF - NoPScreen - TPlan','PEC - Exam Center','Center Administrator','FOA','FOA - No Prescreen','Patient Education Consultant','PEC - PFF - Application Date','PEC - PPF - No Prescreen','PEC - No Prescreen','PEC - Denver','PEC - Denver - FOA','PEC_VisiblePrescreen','PEC - Multiple Centers','PEC - Multiple Centers No Prescreen','PEC - Red Rally','PEC - Red Rally No Prescreen','PEC - Extended Finance','PEC - Extended Finance no prescreen','PEC - Snap No Prescreen','PEC - Snap','PEC_MultipleCenters_VisiblePrescreen','PEC - Application Date') and id = :Userinfo.getProfileId()];
      if(admin_count>0)
        block_pec = true;
      else
        block_pec = false;
        }
    return block_pec;
  }

  public Boolean getpec_override() {
        Integer day_diff = view_apt.apt_date__c.daysbetween(System.today());
        Integer admin_count = [select count() from Profile where name in ('RBD','System Administrator') and id = :Userinfo.getProfileId()];
        System.debug('Admin count : ' + admin_count + ' Day Diff : ' + day_diff);
        //modified by cm on 2/14/2015 - adjusting this from 2 days to 14 per Scott Lawrence
    if(admin_count>0 && day_diff>=0 && day_diff<=14) {
      System.debug('Overide - true');
      return true;
    }
    else {
      System.debug('Overide - false');
      return false;
    }
  }

  public Boolean getdisplay_admin() {
        if(display_admin==null) {
                Integer admin_count = [select count() from Profile where name in ('SF - Clinical Doctor','FOA - TPLAN','FOA - No Prescreen - TPlan','CC Schedule Admin','Data Audit Team','Limited System Administrator','FOA','FOA - No Prescreen','System Administrator','RBD','New System Administrator','System Administration - Test','Call Center - Supervisor','Call Center - Supervisor Test','Outbound Call Center Agent','Outbound Call Center Agent (Test)','Outbound Call Center Agent Outsource','Outbound Call Center Jumpstart','Outbound Call Center Agent Test','PEC_MultipleCenters_VisiblePrescreen','CC Administrator', 'Call Center Admin', 'CC Administrator Development Tester', 'Call Center Agent Lead', 'Call Center Admin', 'CC - Network Center Supervisor','Refund Team') and id = :Userinfo.getProfileId()];
            if(admin_count>0)
              display_admin = true;
            else
              display_admin = false;
        }
          return display_admin;
  }

  public Boolean getdisplay_pec() {
        if(display_pec==null) {
                Integer admin_count = [select count() from Profile where name in ('PEC - NoPScreen - No Dash','PEC - TPLAN','FOA - TPLAN','FOA - No Prescreen - TPlan','PEC - No Prescreen - PPF','PEC - PPF - NoPScreen - TPlan','PEC - Exam Center','Center Administrator','FOA','FOA - No Prescreen','Patient Education Consultant','PEC - Denver','PEC - Denver - FOA','PEC - PFF - Application Date','PEC - PPF - No Prescreen','PEC - No Prescreen','PEC_VisiblePrescreen','PEC - Multiple Centers','PEC - Multiple Centers No Prescreen','PEC - Red Rally','PEC - Red Rally No Prescreen','PEC - Extended Finance','PEC - Extended Finance no prescreen','PEC - Snap No Prescreen','PEC - Snap','PEC_MultipleCenters_VisiblePrescreen','PEC - Application Date') and id = :Userinfo.getProfileId()];
            if(admin_count>0)
              display_pec = true;
            else
              display_pec = false;
        }
          return display_pec;
  }

  public Consult_Inventory__c getslead_id() {
        Consult_Inventory__c c = [select scheduled_lead__c from Consult_Inventory__c where id = :view_apt.id];
        return c;
  }

  public void change_center() {
        System.debug('Center Change : ' + selected_center);
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
        current_weather = getweather_info(selected_date);
  }

  public void display_months() {
        calendar_view = 'months';
  }

  public void display_years() {
        calendar_view = 'years';
  }

  public void lookup_apt_date() {
        Consult_Inventory__c ci = [select apt_date__c,consult_room__r.center_information__c from Consult_Inventory__c where id = :Apexpages.currentPage().getParameters().get('aid')];
        selected_date = ci.apt_date__c;
        selected_center = ci.consult_room__r.center_information__c;
        main_view='consult_view';
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
  }

  public void change_calendar_day() {
        //troubleshoot_msg = 'MDAY : ' + Apexpages.currentPage().getParameters().get('mday');
        //System.debug('MDAY : ' + Apexpages.currentPage().getParameters().get('mday'));
        selected_date = Date.newInstance(selected_date.year(), selected_date.month(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mday')));
        //troubleshoot_msg += '<br />Change Date : ' + selected_date;
        //System.debug('Change Date : ' + selected_date);
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
        current_weather = getweather_info(selected_date);
  }

  public void add_month() {
        selected_date = selected_date.addMonths(1);
        calendar_view = 'calendar';
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
        current_weather = getweather_info(selected_date);
  }

  public void subtract_month() {
        selected_date = selected_date.addMonths(-1);
        calendar_view = 'calendar';
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
        current_weather = getweather_info(selected_date);
  }

  public void change_month() {
        //check to see if the current date value is greater than the end date of the selected month,  if so swap
        Date last_day = Date.newInstance(selected_date.year(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mnum')), 1);
        last_day = last_day.addMonths(1).addDays(-1);
        if(last_day.day()<selected_date.day())
          selected_date = last_day;
        else
          selected_date = Date.newInstance(selected_date.year(), Integer.valueOf(Apexpages.currentPage().getParameters().get('mnum')), selected_date.day());
        calendar_view = 'calendar';
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
        current_weather = getweather_info(selected_date);
  }

  public void change_calendar_year() {
        Date last_day = Date.newInstance(Integer.valueOf(Apexpages.currentPage().getParameters().get('cyear')), selected_date.month(), 1);
        last_day = last_day.addMonths(1).addDays(-1);
        if(last_day.day()<selected_date.day())
          selected_date = last_day;
        else
          selected_date = Date.newInstance(Integer.valueOf(Apexpages.currentPage().getParameters().get('cyear')), selected_date.month(), selected_date.day());
        calendar_view = 'calendar';
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
        current_weather = getweather_info(selected_date);
  }

  public void change_consult_pec() {
    //modal_display = false;
    Boolean allow_change = false;
    //see if the consult was started less than 3 minutes ago - after that throw an error
    if(view_apt.consult_started__c==null)
      allow_change = true;
    else if(view_apt.consult_show_status__c=='Ready for Consult')
      allow_change = true;
    else {
      Decimal time_diff = (System.now().gettime()/1000/60 - view_apt.consult_started__c.gettime()/1000/60);
      System.debug('Time Diff : ' + time_diff);
      if(time_diff<=3)
        allow_change = true;
      //admins can change after the 3 minute time limit
      else if(getdisplay_reset())
        allow_change = true;
    }
    if(allow_change) {
            if(consult_pec=='')
              view_apt.Consult_Pec__c = null;
            else
              view_apt.Consult_PEC__c = consult_pec;
            try {
              update view_apt;
              if(consult_pec!='') {
                User u = [select id,name from User where id = :consult_pec];
                make_history_entry('Modify','Consult PEC changed to ' + u.name);
              }
              else
                make_history_entry('Modify','Consult PEC field was cleared');
            }
            catch (Exception e) {

            }
    }
    else {
      modal_out = '<span style="color:red;font-weight:bold;">Consult PEC field can no longer be changed.  Please contact your RBD if you need to reset this apt</span>';
    }
  }

  public void mark_someone_else() {
        try {
                update view_apt;
        }
        catch(Exception e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
        modal_out += e.getDmlMessage(i) + '<br />';
      }
        }
  }

  public List<Selectoption> getpec_list() {
    //TO-DO : This section needs to be rewritten to reduce the number of queries.  There's a lot of extra work being donw here right now (cm 5/3/2017)
        List<Selectoption> pec = new List<Selectoption>();
        pec.add(new Selectoption('','Select PEC'));
        System.Debug('Selected Center : ' + selected_center);

        Set<ID> list_users = new Set<ID>();

        //*** Alon's Regional Traveler code, 4/1/2016 *** Adding Sales_Region__c to queried columns
        // Center_Information__c ci = [select market__c from center_information__c where id = :selected_center];
        Center_Information__c ci = [select market__c, Sales_Region__c from center_information__c where id = :selected_center];

        System.debug('Market : ' + ci.market__c);
        Set<String> center_market_list = new Set<String>{};
        Set<String> center_market_names = new Set<String>{};
        for(Center_Information__c ci_all : [select id,name from center_information__c where market__c = :ci.market__c]) {
          center_market_list.add(ci_all.id);
          center_market_names.add(ci_all.name);
        }

        //*** Alon's Regional Traveler code, 4/1/2016 *** Collects list of centers in the selected center's region
        Set<String> center_region_list = new Set<String>{};
        for(Center_Information__c ci_all : [select ID From Center_Information__c Where Sales_Region__c = :ci.Sales_Region__c AND market__c != :ci.market__c]) {
           center_region_list.add(ci_all.id);
        }

        //pull the list of pecs assigned to the selected center (by market)
        //pulled the center_administrator__c = false filter so CA's would be on the list
        for(User u : [select id,name from user where center_pec__c in :center_market_list and isactive = true]) {
           //     pec.add(new Selectoption(u.id,u.name));
           list_users.add(u.id);
        }

        //*** Alon's Regional Traveler code, 4/1/2016 *** Pull the list of Regional Traveler PECs
        for(User u : [Select ID, Name From User Where Regional_Traveler__c = true AND Center_PEC__c IN :center_region_list AND isActive = true]) {
          //pec.add(new Selectoption(u.id,u.name));
          list_users.add(u.id);
        }

        //pull the list of traveler pecs
        Center_Information__c unknown = [select id from Center_Information__c where name = 'Unknown' ];
        for(User u : [select id,name from user where center_pec__c = :unknown.id and center_administrator__c = false and isactive = true]) {
          //pec.add(new Selectoption(u.id,u.name));
          list_users.add(u.id);
        }
        //DEC
        for(User u : [select id,name from user where Profile.Name in ('DEC_VisiblePrescreen','Doctor Education Consultant')
          and clinic_calendar__c in :center_market_names and isactive = true]) {
                //pec.add(new Selectoption(u.id,u.name));
          list_users.add(u.id);

        }
        /*pulled by cm on 2014-10-20 based on a request from Sherry/Bryce
        if(getCenterName()=='Dallas' || getCenterName()=='Kansas City') {
            for(User u : [select id,name from user where name='Bryce Burger' and isactive = true]) {
              pec.add(new Selectoption(u.id,u.name));
          }
        }*/
        if(getCenterName()=='San Antonio') {
          for(User u : [select id,name from user where name='Linda Law' and isactive = true]) {
            //pec.add(new Selectoption(u.id,u.name));
            list_users.add(u.id);
          }
        }

        for(User u : [select id,name from user where isactive = true and id in :list_users order by name]) {
          pec.add(new Selectoption(u.id,u.name));
        }

        return pec;
  }

  public List<Selectoption> getcenter_list() {
        Integer t_count = [select count() from UserRole u where name = 'Traveler - PEC' and id = :userinfo.getUserRoleId()];
        //special Exception for Doctor Wang - requested by Bryce and signed off on by Vince
        Integer doc_count = [select count() from User where email = 'twang@clearchoice.com' and id = :userinfo.getUserId()];
        List<Selectoption> centers = new List<Selectoption>();
        if(getnetwork_center_user()) {
          //only display the set user
          for(Center_Information__c my_center : [select id,name,calendar_name__c from Center_Information__c where id = :selected_center order by name]) {
                centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
          }
        }
        else if(getdisplay_admin() || t_count > 0 ) {
          for(Center_Information__c my_center : [select id,name,calendar_name__c from Center_Information__c where name not in ('Chicago Deerfield/Northbrook') order by name]) {
                if(my_center.calendar_name__c==null)
                  centers.add(new Selectoption(my_center.id,my_center.name));
                else
              centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
          }
        }
        else if(doc_count>0) {
          for(Center_Information__c my_center : [select id,name,calendar_name__c from Center_Information__c where name in ('Chicago','Chicago Naperville','Chicago Schaumburg')]) {
                if(my_center.calendar_name__c==null)
                  centers.add(new Selectoption(my_center.id,my_center.name));
                else
              centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
          }
        }
        else {
          for(Center_Information__c my_center : [select id,name,calendar_name__c from Center_Information__c where market__c = :selected_market and name not in ('Chicago Deerfield/Northbrook') order by name]) {
                centers.add(new Selectoption(my_center.id,my_center.calendar_name__c));
          }
        }
        return centers;
  }

  public String getCenterName() {
        return [select name from Center_Information__c where id = :selected_center].Name;
  }

  /*public Integer getnum_dayapt() {
        return [select count() from Consult_Inventory__c c where c.apt_date__c = :selected_date and c.consult_room__c = :new_room.id and (c.scheduled_lead__c!=null or c.scheduled_account__c!=null)];
  }*/

  public List<List<String>> getmonth_list() {
        List<String> month_names = new List<String>();
        List<List<String>> month_rows = new List<List<String>>();
        System.debug('Selected Date : ' + selected_date);
        for(Integer i=1;i<=12;i++) {
                Datetime month_start = Datetime.newInstance(selected_date.year(), i, 1,0,0,0);
                System.debug('Month Start : ' + month_start);
                month_names.add(month_start.format('MMM'));
                if(math.mod(i,4) == 0) {
                        month_rows.add(month_names);
                        month_names = new List<String>();
                }
        }
        return month_rows;
  }

  public List<List<Integer>> getyear_list() {
        List<Integer> year_values = new List<Integer>();
        List<List<Integer>> year_rows = new List<List<Integer>>();
    Date today_date = System.today();
    Integer end_limit = 2024;
    if(today_date.year() > 2024)
      end_limit = today_date.year();
        for(Integer i=2011;i<=end_limit;i++) {
                year_values.add(i);
                if(year_values.size()==4) {
                        year_rows.add(year_values);
                        year_values = new List<Integer>();
                }
        }
        if(year_values.size()>0)
          year_rows.add(year_values);
        return year_rows;
  }

  public Integer getselected_year() {
        return selected_date.year();
  }

  public String getselected_monthname() {
        Datetime my_datetime = Datetime.newInstance(selected_date.year(),selected_date.month(),selected_date.day());
        return my_datetime.format('MMM');
  }

  public CalendarMonth getcmonth() {return cmonth;}

  public class Consult_Apts {
        public Consult_Inventory__c capt {get; set;}
        public Integer crowspan {get;set;}
        public Integer cheight {get;set;}
        public String fontsize {get; set;}
        public String lheight {get;set;}
        public Integer ctop {get; set;}
        public String cclass {get;set;}

        public Consult_Apts(Consult_Inventory__c my_apt, Integer tick_minutes) {
                this.capt = my_apt;
                this.lheight = 'normal';
                this.fontsize = '10pt';
                Integer start_minutes = (Integer.valueof(my_apt.start_hour__c) * 60) + Integer.valueof(my_apt.start_minute__c);
                Integer end_minutes = (Integer.valueof(my_apt.end_hour__c) * 60) + Integer.valueof(my_apt.end_minute__c);
                Integer total_minutes = end_minutes - start_minutes;
                Boolean calc_rows = true;
                crowspan = 0;
                Integer shour = Integer.valueof(my_apt.Start_Hour__c);
                Integer sminute = tick_minutes;
                while(calc_rows) {
                        if(shour < Integer.valueof(my_apt.End_Hour__c) || (shour == Integer.valueof(my_apt.End_Hour__c) && sminute <= Integer.valueof(my_apt.End_Minute__c)))
                                crowspan++;
                        else
                                calc_rows = false;
                  System.debug('Shour : ' + shour + ' Sminute ' + sminute + ' Crowspan : ' + crowspan);
                        if(sminute==45) {
                                sminute = 0;
                                shour++;
                        }
                        else
                          sminute += 15;
                }
                crowspan--;
                Double holder = math.ceil(total_minutes / 15);
                //crowspan = holder.intValue();
                //crowspan = 6;
                cheight = total_minutes;
                cheight += (holder.intValue());
                if(cheight<60) {
                  lheight = '95%';
                  fontsize = '8pt';
                }
                ctop = Integer.valueof(my_apt.start_minute__c) - tick_minutes;
                if(my_apt.Consult_Show_Status__c==null) {
                  if((my_apt.Patient_Name__c==null || my_apt.Patient_Name__c=='') && my_apt.scheduled_account__c==null)
                    this.cclass = 'apt_blue';
                  else {
                        if(my_apt.callback_consult__c)
                          this.cclass = 'apt_teal';
                        else
                      this.cclass = 'apt_yellow';
                  }
                }
                if(my_apt.Consult_Show_Status__c=='Consult Completed')
                  this.cclass = 'apt_grey';
                if(my_apt.Consult_Show_Status__c=='No Show')
                  this.cclass = 'apt_red';
                if(my_apt.Consult_Show_Status__c=='Patient Left')
                  this.cclass = 'apt_red';
                if(my_apt.Consult_Show_Status__c=='Arrived')
                  this.cclass = 'apt_orange';
                if(my_apt.Consult_Show_Status__c=='Ready for Consult')
                  this.cclass = 'apt_brown';
                if(my_apt.Consult_Show_Status__c=='Consult Started')
                  this.cclass = 'apt_green';
        }
        public String getstart_time() {
                Integer sh = integer.valueof(capt.start_hour__c);
                String suffix = '';
                if(sh>12) {
                  sh = sh - 12;
                  suffix = 'PM';
                }
                else if(sh==12)
                  suffix = 'PM';
                else
                  suffix = 'AM';
                if(capt.start_minute__c=='0')
                  return sh + ':00 ' + suffix;
                else
                  return sh + ':' + capt.start_minute__c + ' ' + suffix;
        }

        public String getend_time() {
          Integer sh = integer.valueof(capt.end_hour__c);
                String suffix = '';
                if(sh>12) {
                  sh = sh - 12;
                  suffix = 'PM';
                }
                else if(sh==12)
                  suffix = 'PM';
                else
                  suffix = 'AM';
                if(capt.end_minute__c=='0')
                  return sh + ':00 ' + suffix;
                else
                  return sh + ':' + capt.end_minute__c + ' ' + suffix;
        }

        public String getavail_text() {
                String label = '<span class="blank">Open Apt</span><br />';
                //get the days between the apt_date and the current day
                label += this.getstart_time() + ' - ' + this.getend_time() + '<br />';
                if(capt.special_initiative__c!=null)
                  label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span><br />';
                return label;
        }

        public String getblock_text() {
                //need to set up the standard view for a block on the schedule at some point
                String label = '';
                /*if(capt.scheduled_lead__c!=null) {
                  label += '<span style="font-weight:bold;">' + capt.scheduled_lead__r.name + '<br />';
                  if(capt.scheduled_lead__r.language_spoken__c!='English')
                    label += '<span style="font-weight:bold;color:red;">' + capt.scheduled_lead__r.language_spoken__c + '</span>';
                }*/
                if(capt.scheduled_account__c!=null) {
                        label += '<span style="font-weight:bold;">' + capt.scheduled_account__r.name + '<br />';
                  if(capt.scheduled_account__r.language_spoken__c!='English' && capt.scheduled_account__r.language_spoken__c!=null)
                    label += '<span style="font-weight:bold;color:red;">' + capt.scheduled_account__r.language_spoken__c + '</span>';
                }
                else if(capt.scheduled_patient__c!=null) {
                  label += '<span style="font-weight:bold;">' + capt.scheduled_patient__r.first_name__c + ' ' + capt.scheduled_patient__r.last_name__c + '<br />';
                }
                else
                  label += '<span style="font-weight:bold;">' + capt.patient_name__c + '<br />';
                label += this.getstart_time() + ' - ' + this.getend_time() + '<br />';
                if(capt.consult_show_status__c=='Consult Started' || capt.consult_show_status__c=='Consult Completed') {
                        if(capt.consult_pec__r.name!=null)
          label += capt.consult_pec__r.name + '<br />';
          }
          else if(capt.scheduled_account__c!=null) {
                /*modified on 2016-1-5 by cm
                we're auto-converting leads now as part on the sign in process.  This means we need to do a real test for 2nd consults,  instead of assuming it's a 2nd when an account record
                is scheduled.
                */
                Set<ID> lead_ids = new Set<ID>();
                for(Lead l :[select id from lead where convertedaccountid = :capt.scheduled_account__c]) {
                  lead_ids.add(l.id);
                }
                Integer consult_count = [select count() from consult_inventory__c where (scheduled_account__c = :capt.scheduled_account__c or scheduled_lead__c = :lead_ids)
                  and apt_date__c <= :capt.apt_date__c];
                if(consult_count>1)
              label += '2nd Consult<br />';
            else {
              //test to see if this is a really old converted record - if so display 2nd consult warning.
              Account acheck = [select createddate from account where id = :capt.scheduled_account__c];
              Date acdate = date.newInstance(acheck.createddate.year(),acheck.createddate.month(),acheck.createddate.day());
              if(acdate.daysBetween(capt.apt_date__c)>14)
                label += '2nd Consult<br />';
            }
          }
          else if(capt.callback_consult__c)
            label += 'For : ' + capt.callback_consult_pec__r.name + '<br />';
          else if(capt.special_initiative__c!=null)
            label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span><br />';
          else if(capt.treatment__c!=null)
                  label += capt.treatment__c + '<br />';
                if(capt.Consult_Show_Status__c==null)
                  label += '<span>Awaiting Arrival</span>';
                else
                  label += '<span>' + capt.Consult_Show_Status__c + '</span>';
                return label;
        }
  }

  public class Consult_Rows {
        public Integer chours {get;set;}
        public Integer cminutes {get;set;}
        public String cclass {get;set;}
        public Boolean display_label {get; set;}
        public Consult_Apts[] row_apts {get; set;}
        public Consult_Rows(Integer h, Integer m, Consult_Inventory__c[] all_apts) {
                this.row_apts = new Consult_Apts[] {};
                this.chours = h;
                this.cminutes = m;
                if(cminutes==0 || cminutes==30) {
                        display_label = true;
                        cclass = 'maintick';
                }
                else {
                        display_label = false;
                        cclass = 'subtick';
                }
                //run through and build an array of calendar apts;
                Integer m_end = m+14;
                for(Consult_Inventory__c my_apt : all_apts) {
                  if(my_apt.Start_Hour_Int__c == h && my_apt.Start_Minute_Int__c >= m && my_apt.Start_Minute_Int__c <= m_end) {
                    Consult_Apts row_apt = new Consult_Apts(my_apt, m);
                    this.row_apts.add(row_apt);
                  }
                }
        }
        public String getrow_label() {
                String prefix = '';
                if(chours > 12) {
                        prefix = 'PM';
                        chours -= 12;
                }
                else if(chours==12)
                  prefix = 'PM';
                else
                  prefix = 'AM';
                String rlabel = '';
                rlabel += String.valueof(chours) + ':';
                if(cminutes < 10)
                  rlabel += '0';
                rlabel += cminutes + ' ' + prefix;
                return rlabel;
        }
  }

  public class Consult_Rooms {
        public Consult_Rooms__c room {get; set;}
        public Consult_Room_Note__c[] all_notes {get; set;}
        public Consult_Rows[] consult_view {get; set;}

        public Consult_Rooms(Consult_Rooms__c my_room,Date schedule_date, String center) {
                this.room = my_room;
                this.all_notes = [Select c.SystemModstamp, c.Note_Date__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Comment__c, c.createdby.name From Consult_Room_Note__c c where c.consult_room__c = :my_room.id and c.note_date__c = :schedule_date order by c.createddate];
        }
        public Integer getnum_notes() {
                return all_notes.size();
        }
  }

  public Consult_Rows[] getview_consults(Consult_Rooms__c consult_room, Date view_date) {
        Consult_Rows[] my_rows = new Consult_Rows[] {};
    Boolean generate_calendar = true;
    Integer shour = consult_room.Center_Information__r.Clinical_Start_Hour__c == null ? 7 : consult_room.Center_Information__r.Clinical_Start_Hour__c.intValue();
    Integer ehour = consult_room.Center_Information__r.Clinical_End_Hour__c == null ? 21 : consult_room.Center_Information__r.Clinical_End_Hour__c.intValue();
    Integer sminutes = 0;
    List<Consult_Inventory__c> all_apts = [Select c.add_ons__c,c.consult_room__r.room_type__c, c.Callback_Consult__c, c.Callback_Consult_PEC__c, c.callback_consult_pec__r.name, c.leadscore_at_schedule_time__c,c.special_initiative__c,c.confirmation_status__c,c.Template_Apt__c, c.SystemModstamp, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Minute__c, c.End_Hour__c, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.Active__c,  c.treatment__c, c.Consult_Show_Status__c, c.Patient_Mobile__c, c.Patient_Name__c, c.Patient_Phone__c, c.scheduled_account__r.Name, c.scheduled_account__r.Phone, c.scheduled_account__r.PersonMobilePhone, c.scheduled_account__r.language_spoken__c,c.consult_pec__r.name, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__c, c.scheduled_patient__r.full_name__c From Consult_Inventory__c c where c.consult_room__c = :consult_room.id and c.apt_date__c = :view_date and c.active__c = true];
    while(generate_calendar) {
        //System.debug('Hour : ' + shour + ' Minutes : ' + sminutes);
        Consult_Rows crow = new Consult_Rows(shour, sminutes, all_apts);
        if(sminutes == 45) {
                shour++;
                sminutes = 0;
        }
        else
          sminutes += 15;
        if(shour > ehour)
          generate_calendar = false;
        my_rows.add(crow);
    }
    return my_rows;
  }

  public Consult_Rooms[] getview_allrooms() {
    Consult_Rooms[] all_rooms = new Consult_Rooms[] {};
    //work through all consult rooms at this center
    for(Consult_Rooms__c room : [Select c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById,
      c.Center_Information__c,c.schedule_template__r.name, c.Center_Information__r.Clinical_Start_Hour__c, c.Center_Information__r.Clinical_End_Hour__c
      From Consult_Rooms__c c where c.center_information__c = :selected_center and c.active__c = true order by c.sort_order__c,c.createddate]) {
        Consult_Rooms new_room = new Consult_Rooms(room,selected_date,selected_center);
/*      if(scheduling_lead!=null)
          ps = scheduling_lead.pre_screen__c;
        else if(scheduling_account!=null)
          ps = scheduling_account.Pre_Screen__c;*/
      new_room.consult_view = getview_consults(new_room.room,selected_date);
        all_rooms.add(new_room);
    }
    return all_rooms;
  }

  public class Print_Consult_Inventory {
        public Consult_Inventory__c capt {get; set;}

        public Print_Consult_Inventory(Consult_Inventory__c my_apt) {
                this.capt = my_apt;
        }

        public String getstart_time() {
                Integer sh = integer.valueof(capt.start_hour__c);
                String suffix = '';
                if(sh>12) {
                  sh = sh - 12;
                  suffix = 'PM';
                }
                else if(sh==12)
                  suffix = 'PM';
                else
                  suffix = 'AM';
                if(capt.start_minute__c=='0')
                  return sh + ':00 ' + suffix;
                else
                  return sh + ':' + capt.start_minute__c + ' ' + suffix;
        }

        public String getend_time() {
          Integer sh = integer.valueof(capt.end_hour__c);
                String suffix = '';
                if(sh>12) {
                  sh = sh - 12;
                  suffix = 'PM';
                }
                else if(sh==12)
                  suffix = 'PM';
                else
                  suffix = 'AM';
                if(capt.end_minute__c=='0')
                  return sh + ':00 ' + suffix;
                else
                  return sh + ':' + capt.end_minute__c + ' ' + suffix;
        }
        public String getavail_text() {
                String label = '<span class="blank">Open Apt</span><br />';
                //get the days between the apt_date and the current day
                label += this.getstart_time() + ' - ' + this.getend_time() + '<br />';
                if(capt.special_initiative__c!=null)
                  label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span><br />';
                return label;
        }
        public String getblock_text() {
          //need to set up the standard view for a block on the schedule at some point
          String label = '';
                if(capt.scheduled_account__c!=null)
                  label += '<span style="font-weight:bold;">' + capt.scheduled_account__r.Name + '<br />';
                else if(capt.scheduled_patient__c!=null)
                  label += '<span style="font-weight:bold;">' + capt.scheduled_patient__r.first_Name__c + ' ' + capt.scheduled_patient__r.last_name__c + '<br />';
                else
                  label += '<span style="font-weight:bold;">' + capt.patient_name__c + '<br />';
                label += this.getstart_time() + ' - ' + this.getend_time() + '<br />';
                if(capt.special_initiative__c!=null)
                  label += '<span class="blank" style="color:purple;">' + capt.special_initiative__c + '</span><br />';
                else if(capt.treatment__c!=null)
                  label += capt.treatment__c + '<br /></span>';
                if(capt.add_ons__c!=null)
                  label += capt.add_ons__c.replace(';','<br />') + '<br />';
                if(capt.Callback_Consult__c)
                  label += 'For : ' + capt.callback_consult_pec__r.name + '<br />';
                if(capt.Consult_Show_Status__c==null)
                  label += '<span>Awaiting Arrival</span>';
                else
                  label += '<span>' + capt.Consult_Show_Status__c + '</span>';

                return label;
        }
  }

  public class Print_Consult_Rooms {
        public Consult_Rooms__c room {get; set;}
        public Consult_Room_Note__c[] all_notes {get; set;}
        public Print_Consult_Inventory[] all_apts {get; set;}

        public Print_Consult_Rooms(Consult_Rooms__c my_room,Date schedule_date, String center) {
                this.room = my_room;
                this.all_notes = [Select c.SystemModstamp, c.Note_Date__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted,
                  c.Id, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Comment__c, c.createdby.name From Consult_Room_Note__c c where
                  c.consult_room__c = :my_room.id and c.note_date__c = :schedule_date order by c.createddate];
        }
        public Integer getnum_notes() {
                return all_notes.size();
        }
  }

  public Print_Consult_Inventory[] getview_allprintconsults(Consult_Rooms__c consult_room, Date view_date) {
    Print_Consult_Inventory[] my_apt = new Print_Consult_Inventory[] {};
    for(Consult_Inventory__c ci : [Select c.consult_room__r.room_type__c,c.add_ons__c, c.Leadscore_At_Schedule_Time__c,c.Callback_Consult__c, c.Callback_Consult_PEC__c,c.callback_consult_pec__r.name,c.special_initiative__c,c.confirmation_status__c,c.Template_Apt__c, c.SystemModstamp, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.End_Minute__c, c.End_Hour__c, c.CreatedDate, c.CreatedById, c.Consult_Room__c, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.Active__c,  c.treatment__c, c.Consult_Show_Status__c, c.Patient_Mobile__c, c.Patient_Name__c, c.Patient_Phone__c, c.scheduled_account__r.name, c.scheduled_account__r.Phone, c.scheduled_account__r.Personmobilephone,c.scheduled_account__r.language_spoken__c, c.scheduled_account__c, c.scheduled_patient__r.Main_Phone__c, c.scheduled_patient__r.Last_Name__c, c.scheduled_patient__r.First_Name__c, c.scheduled_patient__r.CreatedDate, c.scheduled_patient__r.Center__c, c.scheduled_patient__r.center__r.name, c.scheduled_patient__r.Alt_Phone__c, c.scheduled_patient__r.id, c.scheduled_patient__c, c.scheduled_patient__r.full_name__c From Consult_Inventory__c c where c.consult_room__c = :consult_room.id and c.apt_date__c = :view_date and c.active__c = true order by c.start_hour_int__c,c.start_minute_int__c]) {
        Print_Consult_Inventory pci = new Print_Consult_Inventory(ci);
        my_apt.add(pci);
    }
    return my_apt;
  }

  public Boolean getdisplay_practice() {
        if(display_practice==null) {
              Integer admin_count = [select count() from Profile where name in ('SF - Clinical Doctor','Clinical Doctor','FOA - TPLAN','FOA - No Prescreen - TPlan','Force.com Clinic Calendar','Force.com - Patient Intake','Force.com - Denver - Patient Intake','Esthetician','FOA - No Prescreen') and id = :Userinfo.getProfileId()];
              //Integer user_count = [select count() from User where name in ('Brooke Young') and id = :Userinfo.getuserid()];
              Integer user_count = 0;
            if(admin_count>0 || user_count>0 || Test.isRunningTest()) {
              display_practice = true;
            }
            else
              display_practice = false;
        }
        return display_practice;
  }

  public Print_Consult_Rooms[] getview_allprintrooms() {
    Print_Consult_Rooms[] all_rooms = new Print_Consult_Rooms[] {};
    //work through all consult rooms at this center - Non Practice
    for(Consult_Rooms__c room : [Select c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c,c.schedule_template__r.name From Consult_Rooms__c c where c.center_information__c = :selected_center and c.active__c = true and c.room_type__c != 'Practice' order by c.createddate]) {
        Print_Consult_Rooms new_room = new Print_Consult_Rooms(room,selected_date,selected_center);
      new_room.all_apts = getview_allprintconsults(new_room.room,selected_date);
        all_rooms.add(new_room);
    }
    //work through all consult rooms at this center - Practice
    if(display_practice==null?getdisplay_practice():display_practice) {
      for(Consult_Rooms__c room : [Select c.SystemModstamp, c.Schedule_Template__c, c.Room_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c,c.schedule_template__r.name From Consult_Rooms__c c where c.center_information__c = :selected_center and c.active__c = true and c.room_type__c = 'Practice' order by c.createddate]) {
        Print_Consult_Rooms new_room = new Print_Consult_Rooms(room,selected_date,selected_center);
        new_room.all_apts = getview_allprintconsults(new_room.room,selected_date);
        all_rooms.add(new_room);
      }
    }
    return all_rooms;
  }

  public String gettoday_text() {
        String return_val = 'Today - ' + System.now().format('M/dd/yyyy');
        return return_val;
  }

  public void display_today() {
        selected_date = System.today();
        cmonth = new CalendarMonth(selected_date,selected_center);
        refresh_inprogress();
  }

  public class wu_full_response {
    public wu_response_detail response;
    public wu_forecast_full forecast;

    public wu_full_response() {}
  }

  public class wu_forecast_full {
    public wu_forecast_text txt_forecast;
    public wu_simple_forecastday simpleforecast;

    public wu_forecast_full() {}
  }

  public class wu_simple_forecastday {
    public List<wu_simple_forecastday_detail> forecastday;

    public wu_simple_forecastday() {}
  }

  public class wu_simple_forecastday_detail {
    public Map<String,String> fdate;
    public Integer period;
    public Map<String,String> high;
    public Map<String,String> low;
    public String conditions;
    public String icon;
    public String icon_url;
    public String skyicon;
    public Integer pop;
    public Map<String,String> qpf_allday;
    public Map<String,String> qpf_day;
    public Map<String,String> qpf_night;
    public Map<String,String> snow_allday;
    public Map<String,String> snow_day;
    public Map<String,String> snow_night;
    public Map<String,String> maxwind;
    public Map<String,String> avewind;
    public Decimal avehumidity;
    public Decimal maxhumidity;
    public Decimal minhumidity;

    public wu_simple_forecastday_detail() {}
  }

  public class wu_forecast_text {
    public String fdate;
    public List<wu_forecastday> forecastday;

    public wu_forecast_text() {}
  }

  public class wu_forecastday {
    public Integer period;
    public String icon;
    public String icon_url;
    public String title;
    public String fcttext;
    public String fcttext_metric;
    public String pop;
    public wu_forecastday() {}
  }

  public class wu_response_detail {
    public String version;
    public String termsofService;
    public Map<String,String> features;

    public wu_response_detail() {}
  }

  public void check_for_weather_data() {
    //method to check and see if we have weather data for the currently selected center and it was pulled today (createddate = today)
    //do we have data for today for this center...and does the center have a postal code
    Center_Information__c current_center = [select id,zip_code__c from Center_Information__c where id = :selected_center];
    Integer wcount = [select count() from Weather__c where createddate = today and center_information__c = :current_center.id];
    if(current_center.zip_code__c!=null && wcount==0) {
      System.debug('Grabbing Weather Data');
        //run an api call to grab weather data and load it in
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        //Production
        req.setEndpoint('http://api.wunderground.com/api/56a44de3711b6b71/forecast/q/' + current_center.zip_code__c + '.json');
        req.setTimeout(60000);
        req.setMethod('GET');

        try {
          res = http.send(req);
          System.debug('Response Status ' + res.getStatusCode());
          System.debug('Response Body ' + res.getBody());
          System.debug('Response Code : ' + res.getStatusCode());

          String sample_response = res.getBody();
          sample_response = sample_response.replace('"date"','"fdate"');

          wu_full_response deserializeResults = (wu_full_response)JSON.deserialize(sample_response, wu_full_response.class);

          //test weather record insert
          List<Weather__c> weather_list = new List<Weather__c>();
          //System.debug('Type : ' + deserializeResults.forecast.simpleforecast);
          for(wu_simple_forecastday_detail forecast : deserializeResults.forecast.simpleforecast.forecastday) {
            Date cdate = Date.newinstance(Integer.valueof(forecast.fdate.get('year')),Integer.valueof(forecast.fdate.get('month')),Integer.valueof(forecast.fdate.get('day')));
            String dtype = '';
            if(cdate < System.today())
              dtype = 'Past';
            else if(cdate == System.today())
              dtype = 'Current';
            else
              dtype = 'Forecast';
            Weather__c wrecord = new Weather__c(center_information__c = current_center.id, calendar_date__c = cdate,
              data_type__c = dtype, json_data__c = JSON.serialize(forecast), temp_high__c = decimal.valueof(forecast.high.get('fahrenheit')),
              temp_low__c= decimal.valueof(forecast.low.get('fahrenheit')), conditions__c = forecast.conditions, icon__c = forecast.icon,
              icon_url__c = forecast.icon_url, pop__c = forecast.pop, qpf_allday__c = decimal.valueof(forecast.qpf_allday.get('in')==null?'0':forecast.qpf_allday.get('in')),
              qpf_night__c = decimal.valueof(forecast.qpf_night.get('in')==null?'0':forecast.qpf_night.get('in')), qpf_day__c = decimal.valueof(forecast.qpf_day.get('in')==null?'0':forecast.qpf_day.get('in')),
              snow_day__c = decimal.valueof(forecast.snow_day.get('in')==null?'0':forecast.snow_day.get('in')), snow_allday__c = decimal.valueof(forecast.snow_allday.get('in')==null?'0':forecast.snow_allday.get('in')),
              snow_night__c = decimal.valueof(forecast.snow_night.get('in')==null?'0':forecast.snow_night.get('in')), max_wind__c = decimal.valueof(forecast.maxwind.get('mph')==null?'0':forecast.maxwind.get('mph')),
              avg_wind__c = decimal.valueof(forecast.avewind.get('mph')==null?'0':forecast.avewind.get('mph')), max_humidity__c = forecast.maxhumidity, min_humidity__c = forecast.minhumidity);
            weather_list.add(wrecord);
            System.debug('Weather Record : ' + wrecord);
          }
          insert weather_list;
        } catch (Exception e) {
          System.debug('Weather Data Failure');
          System.debug(e);
        }
    }
  }

  public Weather__c getweather_info(Date weather_date) {
    if(!testing) {
      try {
        return [Select w.Temp_Low__c, w.Temp_High__c, w.SystemModstamp, w.Snow_Night__c, w.Snow_Day__c, w.Snow_AllDay__c, w.Skyicon__c, w.QPF_Night__c, w.QPF_Day__c, w.QPF_Allday__c, w.POP__c, w.OwnerId, w.Name, w.Min_Humidity__c, w.Max_Wind__c, w.Max_Humidity__c, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.Icon__c, w.Icon_URL__c, w.Data_Type__c, w.CreatedDate, w.CreatedById, w.Conditions__c, w.Center_Information__c, w.Calendar_Date__c, w.Avg_Wind__c, w.Avg_Humidity__c
          From Weather__c w
          where center_information__c = :selected_center and calendar_date__c = :weather_date
          order by createddate desc limit 1];
        } catch (Exception e) {
          return null;
        }
    } else {
      return null;
    }
  }
}