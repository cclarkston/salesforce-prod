/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

 /*
 CM - 5/28/2015 - post practice room changes
 ctrl_clinicschedule - 76%
 calendarmonth - 85%
 Alon Waisman - 4/1/2016 - added test_regional_travelers_in_pec_list, no change in coverage

 CM - 2/9/2017 - test class revised to handle too many SQL queries error and general failures after a change to call center code
 ctrl_clinicschedule - 75%
 calendarmonth - 84%
 */
@isTest
private class test_clinic_schedule {
  static ctrl_clinicschedule my_ext;
  static ctrl_consultschedule schedule_ext;

  static Center_Information__c test_center;
  static Schedule_Templates__c test_template;
  static Schedule_Templates__c test_template2;
  static Template_Apt__c test_temp_apt;
  static Consult_Rooms__c test_room;
  static Consult_Rooms__c test_room2;
  static Lead test_lead;
  static Account test_account;

  static User my_test_user;
  static Pagereference pageref;

  static {
    //generate a test user id to use below
    Profile p = [select id from Profile where name = 'System Administrator'];
    my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
      alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
      timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
    insert my_test_user;
  }

  private static void init() {
    Market__c m =  new Market__c(Name = 'Test Market');
    insert m;
    test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
      directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
      cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
      doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,calendar_name__c = 'Test',Sales_Region__c = 'Northwest' );
    insert test_center;
    test_template = new Schedule_Templates__c(Name = 'Test Any Day Template', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Friday__c = true,
      Saturday__c = true,  Sunday__c = true);
    insert test_template;
    test_template2 = new Schedule_Templates__c(Name = 'Test Weekend Template', Monday__c = false, Tuesday__c = false, Wednesday__c = false, Thursday__c = false, Friday__c = true,
      Saturday__c = true,  Sunday__c = true);
    insert test_template2;

    test_temp_apt = new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Blue', Ending_Hour__c = '9', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template.id, start_hour__c = '8', starting_minutes__c = '15');
    insert test_temp_apt;
    Template_Apt__c[] test_templates = new Template_Apt__c[] {new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Purple', Ending_Hour__c = '9', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template.id, start_hour__c = '9', starting_minutes__c = '5'),
      new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Brown', Ending_Hour__c = '12', Ending_Minutes__c = '30', Pre_Screen_Type__c = 'Any',
      schedule_template__c = test_template.id, start_hour__c = '11', starting_minutes__c = '10'),
      new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Red', Ending_Hour__c = '13', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow Only',
      schedule_template__c = test_template.id, start_hour__c = '12', starting_minutes__c = '50'),
      new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Green', Ending_Hour__c = '15', Ending_Minutes__c = '40', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template.id, start_hour__c = '14', starting_minutes__c = '00')};
    Template_Apt__c[] test_templates2 = new Template_Apt__c[] {new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Grey', Ending_Hour__c = '16', Ending_Minutes__c = '45', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template2.id, start_hour__c = '15', starting_minutes__c = '45'),
      new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Yellow', Ending_Hour__c = '17', Ending_Minutes__c = '50', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template2.id, start_hour__c = '16', starting_minutes__c = '50'),
      new Template_Apt__c (Active__c = true, Color_Code__c = 'Light Orange', Ending_Hour__c = '18', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template2.id, start_hour__c = '17', starting_minutes__c = '55'),
      new Template_Apt__c (Active__c = true, Color_Code__c = 'Network Purple', Ending_Hour__c = '19', Ending_Minutes__c = '55', Pre_Screen_Type__c = 'Green/Yellow',
      schedule_template__c = test_template2.id, start_hour__c = '18', starting_minutes__c = '55')};
    insert test_templates;
    insert test_templates2;
    test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal', Schedule_Template__c = test_template.id);
    insert test_room;
    test_room2 = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 2', Room_Type__c = 'Manual', Schedule_Template__c = test_template2.id);
    insert test_room2;

    test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV',
        Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c=true, reminder_call__c = 'Yes', reminder_text__c = 'Yes');
    insert test_lead;
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
    test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish');
    insert test_account;

    CalendarMonth cmonth = new CalendarMonth(System.today(),test_center.id);
    for(Center_Open_Day__c cd: cmonth.new_day_list) {
      cd.open_status__c = 'Open';
    }
    insert cmonth.new_day_list;

    /*Center_Open_Day__c cd = [select open_status__c from Center_open_Day__c where center_information__c = :test_center.id and calendar_date__c = today];
    cd.open_status__c = 'Open';
    update cd;*/

    Consult_Inventory__c[] ci_list = new Consult_Inventory__c[] {new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '9',Start_Minute__c = '30',End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
    new Consult_Inventory__c(Consult_Room__c = test_room2.Id, Apt_Date__c = System.today(),Start_Hour__c = '11',Start_Minute__c = '30',End_Hour__c = '12', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
    new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '12',Start_Minute__c = '30',End_Hour__c = '13', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
    new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '14',Start_Minute__c = '30',End_Hour__c = '15', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5)
    };
    insert ci_list;

    schedule_ext = new ctrl_consultschedule();
    schedule_ext.build_room_inventory(test_room,System.today());
    //schedule_ext.build_room_inventory(test_room2,System.today());


    //Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today and scheduled_lead__c = null and scheduled_account__c = null limit 1];
    pageref = new PageReference('/apex/manage_schedule_templates?anum=' + ci_list[0].Id + '&lid=' + test_lead.id);
    Test.setCurrentPage(pageref);
    schedule_ext = new ctrl_consultschedule();
    schedule_ext.getapt_history();
    schedule_ext.schedule_consult();
    //my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today and scheduled_lead__c = null and scheduled_account__c = null limit 1];
    pageref = new PageReference('/apex/manage_schedule_templates?anum=' + ci_list[1].Id + '&acntid=' + test_account.id);
    Test.setCurrentPage(pageref);
    schedule_ext = new ctrl_consultschedule();
    schedule_ext.getapt_history();
    schedule_ext.schedule_consult();

    my_ext = new ctrl_clinicschedule();
    pageref = Page.clinic_calendar;
    Test.setCurrentPage(pageref);
  }

  static testMethod void GeneralTests() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    my_ext.getselected_center_name();
    my_ext.getCenterName();
    my_ext.display_consults();
    my_ext.getdisplay_admin();

    Consult_Inventory__c future_apt = [select id,apt_date__c from Consult_Inventory__c where apt_date__c > today and consult_room__c = :test_room.id limit 1];
    pageref = new PageReference('/apex/clinic_calendar?aid=' + future_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    System.assertEquals(my_ext.selected_date, future_apt.apt_date__c);

    pageref = new PageReference('/apex/clinic_calendar?anum=' + future_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.getapt_history();
    my_ext.display_apt_details();
    System.assertEquals(my_ext.modal_type, 'apt_view');
    my_ext.history_view();
    System.assertEquals(my_ext.modal_type, 'history_view');
    my_ext.apt_view();
    System.assertEquals(my_ext.modal_type, 'apt_view');
    my_ext.close_modal();
    System.assertEquals(my_ext.modal_display, false);
    my_ext.getcenter_list();

    my_ext.getnum_pages();
    my_ext.getpage();
    my_ext.getdisplay_next();
    my_ext.getdisplay_prev();
    my_ext.getformatted_sdate();
    my_ext.getconsult_link();

    my_ext.getdisplay_pec();
    my_ext.getblock_pec();
    my_ext.getpec_list();
    my_ext.gettoday_text();
    my_ext.display_search();
    my_ext.getdisplay_reset();
    my_ext.display_printview();
    my_ext.getpec_override();
    my_ext.mark_someone_else();

    test.stopTest();
  }

  static testMethod void CalendarMobility() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    my_ext.display_months();
    System.assertequals(my_ext.calendar_view,'months');
    my_ext.display_years();
    System.assertEquals(my_ext.calendar_view, 'years');

    pageref = new PageReference('/apex/clinic_calendar?mday=1');
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.change_calendar_day();

    pageref = new PageReference('/apex/clinic_calendar?mnum=9');
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.change_month();
    System.assertEquals(my_ext.getselected_monthname(), 'Sep');

    pageref = new PageReference('/apex/clinic_calendar?cyear=2013');
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.change_calendar_year();
    System.assertEquals(my_ext.getselected_year(), 2013);

    List<List<String>> cmonths = my_ext.getmonth_list();
    System.assertEquals(cmonths.size(),3);

    List<List<Integer>> cyear = my_ext.getyear_list();
    CalendarMonth my_month = my_ext.getcmonth();
    my_ext.add_month();
    my_ext.subtract_month();

    my_ext.change_center();
    my_ext.display_today();

    my_ext.getcenter_total_open_days();

    test.stopTest();
  }

  static testMethod void Consult_Room_Class() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    pageref = new PageReference('/apex/clinic_calendar?lid=' + test_lead.id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.selected_center = test_center.id;
    ctrl_clinicschedule.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
    System.assertEquals(my_rooms.size(), 2);
    for(ctrl_clinicschedule.Consult_Rooms cr : my_rooms) {
      System.assertEquals(cr.getnum_notes(),0);
      for(ctrl_clinicschedule.Consult_Rows crow : cr.consult_view) {
        crow.getrow_label();
        for(ctrl_clinicschedule.Consult_Apts capt : crow.row_apts) {
          capt.getavail_text();
          capt.getblock_text();
          if(capt.cclass=='Light Purple') {
            System.assertequals(capt.getstart_time(),'9:05 AM');
            System.assertequals(capt.getend_time(),'9:55 AM');
          }
          if(capt.cclass=='Light Red') {
            System.assertequals(capt.getstart_time(),'12:50 AM');
            System.assertequals(capt.getend_time(),'1:55 PM');
          }
          if(capt.cclass=='Light Green') {
            System.assertequals(capt.getstart_time(),'2:00 PM');
            System.assertequals(capt.getend_time(),'3:40 PM');
          }
        }
      }
    }

    my_ext.selected_date = System.today().addDays(7);
    my_rooms = my_ext.getview_allrooms();
    System.assertEquals(my_rooms.size(), 2);
    for(ctrl_clinicschedule.Consult_Rooms cr : my_rooms) {
      System.assertEquals(cr.getnum_notes(),0);
      for(ctrl_clinicschedule.Consult_Rows crow : cr.consult_view) {
        crow.getrow_label();
        for(ctrl_clinicschedule.Consult_Apts capt : crow.row_apts) {
          capt.getavail_text();
          capt.getblock_text();
          if(capt.cclass=='Light Purple') {
            System.assertequals(capt.getstart_time(),'9:05 AM');
            System.assertequals(capt.getend_time(),'9:55 AM');
          }
          if(capt.cclass=='Light Red') {
            System.assertequals(capt.getstart_time(),'12:50 AM');
            System.assertequals(capt.getend_time(),'1:55 PM');
          }
          if(capt.cclass=='Light Green') {
            System.assertequals(capt.getstart_time(),'2:00 PM');
            System.assertequals(capt.getend_time(),'3:40 PM');
          }
        }
      }
    }
    test.stopTest();
  }

  static testMethod void Patient_Arrived_Ready_Started_Complete() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    //find an open block and verify the arrived button is not available
    Consult_Inventory__c test_apt = [select id from Consult_Inventory__c where Consult_Room__c = :test_room.id and apt_date__c=today and scheduled_lead__c = null and scheduled_account__c=null limit 1];
    pageref = new PageReference('/apex/clinic_calendar?anum=' + test_apt.Id);
    pageRef.getParameters().put('aid',test_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.selected_center = test_room.id;
    my_ext.display_apt_details();
    //System.debug('Name : ' + my_ext.view_apt.Patient_Name__c);
    System.assertEquals(my_ext.getdisplay_arrived_btn(), false);
//    System.assertEquals(my_ext.getarrived_list().size(), 0);
//    System.assertEquals(my_ext.getarrived_list_size(), 0);
    my_ext.lookup_apt_date();

    //find a scheduled block and verify the arrived button is available
    test_apt = [select id from Consult_Inventory__c where Consult_Room__c = :test_room.id and apt_date__c=today and scheduled_lead__c <> null limit 1];
    pageref = new PageReference('/apex/clinic_calendar?anum=' + test_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.display_apt_details();
    System.assertEquals(my_ext.getdisplay_arrived_btn(), true);
    System.assertEquals(my_ext.getdisplay_noshow_btn(), true);
    System.assertEquals(my_ext.getdisplay_ready_btn(), false);
    System.assertEquals(my_ext.getdisplay_started_btn(), false);
    System.assertEquals(my_ext.getdisplay_completed_btn(), false);
    System.assertEquals(my_ext.getdisplay_left_btn(), false);
    my_ext.getslead_id();

    //mark the patient as arrived and check that everything worked properly
    my_ext.mark_patient_arrived();
    System.assert(my_ext.getarrival_time()<>'');
    System.assertEquals(my_ext.getdisplay_arrived_btn(), false);
    System.assertEquals(my_ext.getdisplay_noshow_btn(), false);
    System.assertEquals(my_ext.getdisplay_ready_btn(), true);
    System.assertEquals(my_ext.getdisplay_started_btn(), false);
    System.assertEquals(my_ext.getdisplay_completed_btn(), false);
    System.assertEquals(my_ext.getdisplay_left_btn(), true);
    my_ext.selected_center = test_center.id;
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getarrived_list().size(), 1);

    my_ext.mark_patient_ready();
    System.assert(my_ext.getready_time()<>'');
    System.assertEquals(my_ext.getdisplay_arrived_btn(), false);
    System.assertEquals(my_ext.getdisplay_noshow_btn(), false);
    System.assertEquals(my_ext.getdisplay_ready_btn(), false);
    System.assertEquals(my_ext.getdisplay_started_btn(), true);
    System.assertEquals(my_ext.getdisplay_completed_btn(), false);
    System.assertEquals(my_ext.getdisplay_left_btn(), true);
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getarrived_list().size(), 0);
    System.assertEquals(my_ext.getready_list().size(), 1);
    System.assertEquals(my_ext.getready_list_size(), 1);
    test_apt.Consult_PEC__c = my_test_user.id;
    update test_apt;
    my_ext.consult_pec = my_test_user.id;
    my_ext.change_consult_pec();

    my_ext.mark_patient_started();
    System.debug('Starting Consult Block ' + my_ext.modal_out);
    System.assert(my_ext.getstarted_time()<>'');
    System.assertEquals(my_ext.getdisplay_arrived_btn(), false);
    System.assertEquals(my_ext.getdisplay_noshow_btn(), false);
    System.assertEquals(my_ext.getdisplay_ready_btn(), false);
    System.assertEquals(my_ext.getdisplay_started_btn(), false);
    System.assertEquals(my_ext.getdisplay_completed_btn(), true);
    System.assertEquals(my_ext.getdisplay_left_btn(), false);
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getready_list().size(), 0);
    System.assertEquals(my_ext.getstarted_list().size(), 1);
    System.assertEquals(my_ext.getstarted_list_size(), 1);
    my_ext.change_consult_pec();


    my_ext.mark_patient_complete();
    System.assert(my_ext.getcompleted_time()<>'');
    System.assertEquals(my_ext.getdisplay_arrived_btn(), false);
    System.assertEquals(my_ext.getdisplay_noshow_btn(), false);
    System.assertEquals(my_ext.getdisplay_ready_btn(), false);
    System.assertEquals(my_ext.getdisplay_started_btn(), false);
    System.assertEquals(my_ext.getdisplay_completed_btn(), false);
    System.assertEquals(my_ext.getdisplay_left_btn(), false);
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getstarted_list().size(), 0);
    System.assertEquals(my_ext.getcompleted_list().size(), 1);
    System.assertEquals(my_ext.getcompleted_list_size(), 1);
    for(ctrl_clinicschedule.Consult_Status cs : my_ext.todays_apts) {
      cs.getpname();
      cs.gettime_label();
      cs.getconverted_status();
    }
//    my_ext.getdisplay_reset();
    my_ext.mark_patient_reset();

    test.stopTest();
  }

  static testMethod void Patient_NoShow() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    Consult_Inventory__c test_apt = [select id from Consult_Inventory__c where Consult_Room__c = :test_room.id and apt_date__c=today and scheduled_lead__c <> null limit 1];
    pageref = new PageReference('/apex/clinic_calendar?anum=' + test_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.display_apt_details();
    my_ext.selected_center = test_center.id;
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getdisplay_noshow_btn(), true);
    System.assertEquals(my_ext.getnoshow_list().size(), 0);
    System.assertEquals(my_ext.getnoshow_list_size(), 0);

    //mark the patient as arrived and check that everything worked properly
    my_ext.mark_patient_noshow();
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getdisplay_arrived_btn(), false);
    System.assertEquals(my_ext.getdisplay_noshow_btn(), false);
    System.assertEquals(my_ext.getdisplay_ready_btn(), false);
    System.assertEquals(my_ext.getdisplay_started_btn(), false);
    System.assertEquals(my_ext.getdisplay_completed_btn(), false);
    System.assertEquals(my_ext.getdisplay_left_btn(), false);
    System.assertEquals(my_ext.getnoshow_list_size(), 1);
    test_apt.No_Show_Contacted__c = true;
    test_apt.No_Show_Contacted_Notes__c = 'Called and left a msg';
    update test_apt;
    my_ext.update_nocontact();

    test.stopTest();
  }

  static testMethod void Patient_Left() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    Consult_Inventory__c test_apt = [select id from Consult_Inventory__c where Consult_Room__c = :test_room.id and apt_date__c=today and scheduled_lead__c <> null limit 1];
    pageref = new PageReference('/apex/clinic_calendar?anum=' + test_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.display_apt_details();
    my_ext.selected_center = test_center.id;
    my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getleft_list().size(), 0);
    System.assertEquals(my_ext.getleft_list_size(), 0);
    my_ext.mark_patient_arrived();
    my_ext.mark_patient_left();
    //my_ext.refresh_inprogress();
    System.assertEquals(my_ext.getleft_list_size(), 1);
    test_apt.Walk_Out_Reason__c = 'test';
    update test_apt;
    my_ext.update_woreason();

    test.stopTest();
  }

  static testMethod void apt_hold() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    Consult_Inventory__c test_apt = [select id from Consult_Inventory__c where Consult_Room__c = :test_room.id and apt_date__c=today and scheduled_lead__c = null and scheduled_account__c = null limit 1];
    pageref = new PageReference('/apex/clinic_calendar?anum=' + test_apt.Id);
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.display_apt_details();
    System.assert(my_ext.getallow_hold()==true);
    my_ext.place_hold();

    test.stopTest();
  }

  static testMethod void print_view() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    pageref = new PageReference('/apex/clinic_calendar');
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    for(ctrl_clinicschedule.Print_Consult_Rooms pc : my_ext.getview_allprintrooms()) {
      pc.getnum_notes();
      for(ctrl_clinicschedule.Print_Consult_Inventory pci : pc.all_apts) {
        pci.getavail_text();
        pci.getblock_text();
        pci.getend_time();
        pci.getstart_time();
      }
    }

    test.stopTest();
  }

  static testMethod void search_consults() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    pageref = new PageReference('/apex/clinic_calendar');
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();
    my_ext.search_name = 'Test';
    my_ext.consult_search();
    my_ext.next_page();
    my_ext.prev_page();

    test.stopTest();
  }

  static testMethod void test_regional_travelers_in_pec_list() {
    init();

    //test_center.Sales_Region__c = 'Northwest';
    //update test_center;
    my_ext.selected_center = test_center.id;

    String[] region_center_names = new String[]{'Regional Center 1', 'Regional Center 2'};
    String[] other_region_center_names = new String[]{'Not Regional Center'};
    String region = test_center.Sales_Region__c;
    String other_region = 'Northeast';


    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    User[] pecs = regional_pecs(4);
    Map<String, Center_Information__c> centers = test_centers(region_center_names, other_region_center_names, region, other_region);
    set_pec_values(pecs[0], false, centers.get('Regional Center 1'));
    set_pec_values(pecs[1], true, centers.get('Regional Center 1'));
    set_pec_values(pecs[2], true, centers.get('Regional Center 2'));
    set_pec_values(pecs[3], true, centers.get('Not Regional Center'));
    insert pecs;

      SelectOption[] pec_options = my_ext.getpec_list();
      Set<String> pec_ids = new Set<String>{};
      for (SelectOption option : pec_options) {
        pec_ids.add(option.getValue());
      }

      // pec[0] is not a Regional Traveler... should NOT be in the list
      system.assertEquals(false, pec_ids.contains(pecs[0].id));

      // pec[0] is a Regional Traveler and in the same region as the selected center... should be in the list
      system.assertEquals(true, pec_ids.contains(pecs[1].id));

      // pec[0] is a Regional Traveler with a different home center but still in the same region as the selected center... should be in the list
      system.assertEquals(true, pec_ids.contains(pecs[2].id));

      // pec[0] is a Regional Traveler but in a different region than the selected center... should NOT be in the list
      system.assertEquals(false, pec_ids.contains(pecs[3].id));
    test.stopTest();
  }

    private static Map<String, Center_Information__c> test_centers(String[] regional_center_names, String[] other_regional_center_names, String region, String other_region) {
      Center_Information__c center;
      Center_Information__c[] centers = new Center_Information__c[]{};
      Map<String, Center_Information__c> center_map = new Map<String, Center_Information__c>{};

      Market__c m = [Select ID From Market__c Where ID != :test_center.Market__c Limit 1];

      for (String center_name : regional_center_names) {
        center = new Center_Information__c(Name = center_name, Sales_Region__c = region,
                                            Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
                                            directions__c = 'test', zip_code__c = '00000', market__c = m.id, sales_market__c = m.id,
                                            cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
                                            doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,calendar_name__c = 'Test');
        centers.add(center);
        center_map.put(center_name, center);
      }

      for (String center_name : other_regional_center_names) {
        center = new Center_Information__c(Name = center_name, Sales_Region__c = other_region,
                                            Street_1__c = 'test', city__c = 'Nashua', state__c = 'New Hampshire',
                                            directions__c = 'test', zip_code__c = '00000', market__c = m.id, sales_market__c = m.id,
                                            cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
                                            doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,calendar_name__c = 'Test' );
        centers.add(center);
        center_map.put(center_name, center);
      }

      insert centers;
      return center_map;
    }

    private static User[] regional_pecs(Integer count) {
      Profile profile = [select id from Profile where name = 'Patient Education Consultant'];
      User[] pecs = new User[]{};
      for (Integer i = 0; i < count; i++) {
        pecs.add(new User(profileid = profile.id, email = 'pec' + i + '@clearchoice.com', emailencodingkey = 'UTF-8',
                          alias = 'pecu' + i, lastname = 'PECUser' + i, localesidkey='en_US', country='United States', username='pec' + i + '@clearchoice.com',
                          timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'));
      }
      return pecs;
    }

    private static void set_pec_values(User pec, Boolean regional, Center_Information__c center) {
      pec.Regional_Traveler__c = regional;
      pec.Center_PEC__c = center.id;
    }

 static testMethod void weather_api() {
    init();
    test.startTest();
    System.assertequals(Limits.getQueries(),0);

    pageref = new PageReference('/apex/clinic_calendar');
    Test.setCurrentPage(pageref);
    my_ext = new ctrl_clinicschedule();

    my_ext.selected_center = test_center.id;
    Test.setMock(HttpCalloutMock.class, new WeatherUnderGroundMock());
    my_ext.check_for_weather_data();
    Weather__c w = my_ext.getweather_info(System.today());

    test.stopTest();
  }
}