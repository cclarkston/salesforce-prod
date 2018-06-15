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
 CM - 5/28/2015 - Post Practice room changes
 ctrl_consultscheduled 75% coverage
 CalendarMonth - 95%
 Consult_Inventory_Builder 99% covered
 lead_consultschedule - 75% covered
 account_consultschedule - 77% covered

 AW - 2017-02-02
 CalendarMonth - 92%
 Consult_Inventory_Builder - 98%
 ctrl_consultschedule_development - 76%
 lead_consultschedule_development - 76%
 account_consultschedule_development - 78%
 */
@isTest
private class test_consult_schedule_development {
  static ctrl_consultschedule_development my_ext;

  static Center_Information__c test_center;
  static Schedule_Templates__c test_template;
  static Schedule_Templates__c test_template2;
  static Template_Apt__c test_temp_apt;
  static Consult_Rooms__c test_room;
  static Consult_Rooms__c test_room2;
  static Lead test_lead;
  static Account test_account;
  static Private_Practice_Patient__c test_pp;

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
    Market__c m = [select id from Market__c limit 1];
    test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
      directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
      cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
      doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
      send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',allow_center_selection__c = true);
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
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
        //Refused_to_give_email__c=true
    insert test_lead;
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
    test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish');
    insert test_account;
    CalendarMonth cmonth = new CalendarMonth(System.today(),test_center.id);
    insert cmonth.new_day_list;
    cmonth = new CalendarMonth(System.today().addmonths(1),test_center.id);
    insert cmonth.new_day_list;

    my_ext = new ctrl_consultschedule_development();
    my_ext.build_room_inventory(test_room,System.today());
    my_ext.build_room_inventory(test_room2,System.today());

    Consult_Inventory__c[] ci_list = new Consult_Inventory__c[] {new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '9',Start_Minute__c = '30',End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
															    new Consult_Inventory__c(Consult_Room__c = test_room2.Id, Apt_Date__c = System.today(),Start_Hour__c = '11',Start_Minute__c = '30',End_Hour__c = '12', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
															    new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '12',Start_Minute__c = '30',End_Hour__c = '13', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
															    new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '14',Start_Minute__c = '30',End_Hour__c = '15', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
															    new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today().adddays(9),Start_Hour__c = '14',Start_Minute__c = '30',End_Hour__c = '15', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5),
															    new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = System.today().adddays(10),Start_Hour__c = '14',Start_Minute__c = '30',End_Hour__c = '15', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5)
    };
    insert ci_list;

    pageref = Page.sandbox_calendar_development;
    Test.setCurrentPage(pageref);
  }

	static testMethod void BuildInventory() {
		// init();
		// test.startTest();
		//
		// Integer apt_count = [select count() from Consult_Inventory__c where consult_room__c = :test_room2.id];
		// CalendarMonth cmonth = new CalendarMonth(System.today().addmonths(1),test_center.id);
		// insert cmonth.new_day_list;
		// my_ext.build_room_inventory(test_room2,System.today().addDays(7));
		// Integer apt_count2 = [select count() from Consult_Inventory__c where consult_room__c = :test_room2.id];
		// System.debug('Apt Counts : ' + apt_count + ' ' + apt_count2);
		// System.assert(apt_count2 > apt_count);
		//
		// test.stopTest();
	}

	static testMethod void ParameterCheck() {
		init();
		test.startTest();

		//grab an appointment in the future
		Consult_Inventory__c future_apt = [select id,apt_date__c from Consult_Inventory__c where apt_date__c > today and consult_room__c = :test_room.id limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?aid=' + future_apt.Id + '&cid=' + test_center.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		System.assertEquals(my_ext.selected_date, future_apt.apt_date__c);
		System.assertEquals(my_ext.selected_center, test_center.id);
		System.assertEquals(my_ext.getselected_center_name(), test_center.name);
		System.assertEquals(my_ext.getCenterName(), test_center.name);

		pageref = new PageReference('/apex/manage_schedule_templates?lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		System.assertEquals(my_ext.scheduling_lead.id, test_lead.id);
		System.assertEquals(my_ext.selected_center, test_lead.center__c);
		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();

		pageref = new PageReference('/apex/manage_schedule_templates?acntid=' + test_account.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		System.assertEquals(my_ext.scheduling_account.id, test_account.id);
		System.assertEquals(my_ext.selected_center, test_account.center__c);
		my_rooms = my_ext.getview_allrooms();

		List<SelectOption> all_centers = my_ext.getcenter_list();
		//Integer c_count = [select count() from Center_Information__c where name not in ('Chicago Deerfield/Northbrook')];
		Integer c_count = [select count() from Center_Information__c where allow_center_selection__c = true];
		System.assertequals(all_centers.size(),c_count);

		List<SelectOption> all_templates = my_ext.getTemplatelist();
		Integer t_count = [select count() from Schedule_Templates__c where active__c = true];
		System.assertequals(all_templates.size(),(t_count + 1));

		my_ext.clear_schedule_leadaccount();
		my_ext.getcancel_reason_list();
		my_ext.cancel_consult_view();
		my_ext.getformatted_status_text();
		my_ext.getselected_center_calendar_name();
		my_ext.getdelete_reason_list();
		my_ext.getallow_sd_sched();

		// Adding this line just for code coverage
		my_ext.getPIQ_Score(test_account.id);

		test.stopTest();
	}

	static testMethod void Consult_Room_Class() {
		init();
		test.startTest();

		pageref = new PageReference('/apex/manage_schedule_templates?lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.selected_center = test_center.id;
		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

			  system.assertEquals(capt.note_statuses[1], 'none');
		    }
		  }
		}

		my_ext.selected_date = System.today().addDays(7);
		my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

	static testMethod void CalendarMobility() {
		init();
		test.startTest();

		my_ext.display_months();
		System.assertequals(my_ext.calendar_view,'months');
		my_ext.display_years();
		System.assertEquals(my_ext.calendar_view, 'years');

		pageref = new PageReference('/apex/manage_schedule_templates?mday=1');
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.change_calendar_day();

		pageref = new PageReference('/apex/manage_schedule_templates?mnum=9');
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.change_month();
		System.assertEquals(my_ext.getselected_monthname(), 'Sep');

		pageref = new PageReference('/apex/manage_schedule_templates?cyear=2013');
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.change_calendar_year();
		System.assertEquals(my_ext.getselected_year(), 2013);

		List<List<String>> cmonths = my_ext.getmonth_list();
		System.assertEquals(cmonths.size(),3);

		List<List<Integer>> cyear = my_ext.getyear_list();
		CalendarMonth my_month = my_ext.getcmonth();
		my_month.getMonthName();
		my_month.getYearNum();
		my_month.getweeks();

		List<CalendarMonth.CalendarWeek> all_weeks = my_month.getweeks();
		for(CalendarMonth.CalendarWeek my_week : all_weeks) {
		  List<CalendarMonth.CalendarDay> week_days = my_week.getdays();
		  for(CalendarMonth.CalendarDay cd : week_days) {
		    cd.getdate_num();
		    cd.getdisplay_date();
		    cd.getcss_style();
		  }
		}

		my_ext.add_month();
		my_ext.subtract_month();
		my_ext.display_today();
		System.assertequals(my_ext.selected_date,system.today());

		my_ext.gettoday_text();
		my_ext.getformatted_sdate();

		test.stopTest();
	}

	static testMethod void NewConsultRoom() {
		init();
		test.startTest();

		my_ext.display_room_form();
		my_ext.new_room.Days_Built_Out__c = 190;
		my_ext.create_new_room();
		System.assert(my_ext.new_room_issues.contains('You need to enter a value for the consult room name'));
		System.assert(my_ext.new_room_issues.contains('You must select a scheduling template for this room'));
		System.assert(my_ext.new_room_issues.contains('You can currently only build the calendar out as far as 180 days'));

		my_ext.new_room.name = '123';
		my_ext.new_room.Days_Built_Out__c = null;
		my_ext.create_new_room();
		System.assert(my_ext.new_room_issues.contains('Room Name must be at least 5 characters long'));
		System.assert(my_ext.new_room_issues.contains('You must enter a value for the days built out'));

		my_ext.new_room.sort_order__c = null;
		my_ext.create_new_room();
		System.assert(my_ext.new_room_issues.contains('You must enter a value for the sort order'));
		my_ext.new_room.sort_order__c = -1;
		my_ext.create_new_room();
		System.assert(my_ext.new_room_issues.contains('You must enter a value between 0 and 9 for the sort order'));

		my_ext.new_room.sort_order__c = 6;
		my_ext.new_room.name = 'Test Build Room';
		my_ext.new_room.Schedule_Template__c = test_template.id;
		my_ext.new_room.Days_Built_Out__c = 7;
		my_ext.new_room.Room_Type__c = 'Normal';
		my_ext.create_new_room();
		Integer c = [select count() from Consult_Rooms__c where name = 'Test Build Room'];
		System.assertEquals(c, 1);

		my_ext.display_room_form();
		my_ext.new_room.name = 'Test Build Room 2';
		my_ext.new_room.Schedule_Template__c = test_template2.id;
		my_ext.new_room.Days_Built_Out__c = 7;
		my_ext.new_room.Room_Type__c = 'Manual';
		my_ext.create_new_room();
		c = [select count() from Consult_Rooms__c where name = 'Test Build Room 2'];
		System.assertEquals(c, 1);
		Consult_Rooms__c troom = [select id from Consult_Rooms__c where name = 'Test Build Room 2'];

		my_ext.new_room.name = null;
		my_ext.new_room.Schedule_Template__c = null;
		my_ext.new_room.Days_Built_Out__c = 191;
		my_ext.new_room.sort_order__c = null;
		my_ext.update_consult_room();
		System.assert(my_ext.new_room_issues.contains('You need to enter a value for the consult room name'));
		System.assert(my_ext.new_room_issues.contains('You must select a scheduling template for this room'));
		System.assert(my_ext.new_room_issues.contains('You can currently only build the calendar out as far as 180 days'));
		System.assert(my_ext.new_room_issues.contains('You must enter a value for the sort order'));

		my_ext.new_room.name = '123';
		my_ext.new_room.Days_Built_Out__c = null;
		my_ext.new_room.sort_order__c = -1;
		my_ext.update_consult_room();
		System.assert(my_ext.new_room_issues.contains('Room Name must be at least 5 characters long'));
		System.assert(my_ext.new_room_issues.contains('You must enter a value for the days built out'));
		System.assert(my_ext.new_room_issues.contains('You must enter a value between 0 and 9 for the sort order'));
		my_ext.display_room_form();

		pageref = new PageReference('/apex/manage_schedule_templates?rnum=' + troom.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.modify_room_form();

		my_ext.new_room.name = 'Test Build Room 3';
		my_ext.new_room.Schedule_Template__c = test_template2.id;
		my_ext.new_room.Days_Built_Out__c = 1;
		my_ext.new_room.Room_Type__c = 'Manual';
		my_ext.new_room.sort_order__c = 3;
		my_ext.update_consult_room();
		//c = [select count() from Consult_Rooms__c where name = 'Test Build Room 2'];
		//System.assertEquals(c, 0);
		c = [select count() from Consult_Rooms__c where name = 'Test Build Room 3'];
		System.assertEquals(c, 1);

		my_ext.new_room.Room_Type__c = 'Normal';
		my_ext.new_room.Days_Built_Out__c = 11;
		my_ext.update_consult_room();

		test.stopTest();
	}

	static testMethod void NewApt_Hist() {
		init();
		test.startTest();

		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();

		my_ext.display_apt_details();
		my_ext.getapt_starttime();
		my_ext.getapt_endtime();
		System.assert(my_ext.modal_display);

		my_ext.history_view();
		system.assert(my_ext.modal_type=='history_view');

		my_ext.apt_view();
		system.assert(my_ext.modal_type=='apt_view');

		my_ext.close_modal();
		system.assert(!my_ext.modal_display);

		Consult_Inventory__c bad_apt = new Consult_Inventory__c(Consult_room__c = test_room.id,start_hour__c = 'A',start_minute__c = 'B',end_hour__c = 'A', end_minute__c = 'B');
		Integer num_errors = my_ext.apt_validation(bad_apt);
		System.assertEquals(num_errors, 6);

		bad_apt.start_hour__c = '26';
		bad_apt.start_minute__c = '90';
		bad_apt.End_Hour__c = '26';
		bad_apt.End_Minute__c = '90';
		num_errors = my_ext.apt_validation(bad_apt);
		System.assertEquals(num_errors, 6);

		bad_apt.start_hour__c = '13';
		bad_apt.Start_Minute__c = '10';
		bad_apt.end_hour__c = '13';
		bad_apt.end_minute__c = '1';
		bad_apt.Pre_Screen_Type__c = 'Any';
		bad_apt.color__c = 'Light Blue';
		num_errors = my_ext.apt_validation(bad_apt);
		System.assertEquals(num_errors, 1);

		bad_apt.End_Minute__c = '50';
		//testing catch block - this will fail
		my_ext.create_new_aptblock();

		pageref = new PageReference('/apex/manage_schedule_templates?rid=' + test_room.Id + '&shour=7&smin=10');
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.display_new_apt_form();
		system.assertEquals(my_ext.view_apt.start_hour__c, '7');
		my_ext.view_apt.End_Hour__c = '8';
		my_ext.view_apt.end_minute__c = '30';
		my_ext.view_apt.Pre_Screen_Type__c = 'Any';
		my_ext.view_apt.color__c = 'light Blue';
		//this should work
		my_ext.create_new_aptblock();

		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		List<Apt_History__c> apt_hist = my_ext.getapt_history();
		//System.assertEquals(apt_hist.size(), 1);

		my_ext.view_apt.start_hour__c = '9';
		my_ext.view_apt.Start_Minute__c = '20';
		my_ext.view_apt.End_Hour__c = '10';
		my_ext.view_apt.End_Minute__c = '40';
		my_ext.view_apt.color__c = 'Light Orange';
		my_ext.view_apt.Pre_Screen_Type__c = 'Seminar';
		my_ext.view_apt.Apt_Notes__c = 'Test Change';
		my_ext.view_apt.Treatment__c = 'Single';
		my_ext.view_apt.Consult_show_status__c = 'No Show';
		my_ext.view_apt.Confirmation_Status__c = 'Confirmed';
		my_ext.view_apt.Send_Reminder__c = false;
		my_ext.view_apt.GC_Offered__c = true;
		my_ext.view_apt.Special_Initiative__c = 'test';
		my_ext.view_apt.Will_Patient_Show__c = 'Yes';
		my_ext.view_apt.Will_Patient_Start__c = 'yes';
		my_ext.modify_aptblock();
		apt_hist = my_ext.getapt_history();
		//    System.assertEquals(apt_hist.size(), 2);
		my_ext.getallow_cancel();
		my_ext.getallow_reschedule();

		test.stopTest();
	}

	static testMethod void DeleteApt() {
		init();
		test.startTest();

		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.delete_aptblock();
		my_ext.delete_reason = 'Test';
		my_ext.delete_aptblock();
		Integer c = [select count() from Consult_Inventory__c where id = :my_apt.id and active__c = false];
		System.assertEquals(c,1);
		List<Apt_History__c> apt_hist = my_ext.getapt_history();
		//System.assertEquals(apt_hist.size(), 2);

		pageref = new PageReference('/apex/manage_schedule_templates?rnum=' + test_room.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.modify_room_form();
		my_ext.clear_dayapts();
		my_ext.delete_reason = 'Testing';
		my_ext.clear_dayapts();

		test.stopTest();
	}

	static testMethod void Callback_Sched() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();

		my_ext.getapt_history();
		my_ext.getallow_callback_consult();
		my_ext.callback_consult_view();
		my_ext.schedule_callback();
		my_ext.view_apt.callback_consult_pec__c = userinfo.getuserid();
		my_ext.schedule_callback();
		my_ext.delete_consult_view();
		my_ext.getpec_list();

		test.stoptest();
	}

	static testMethod void schedule_modify_block() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_lead.Reminder_Call__c = 'Yes';
		my_ext.scheduling_lead.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		my_ext.modify_aptblock();
		my_ext.modify_aptblock();

		my_ext.getage_of_ticket();

		String[] pre_screens = new String[]{null, 'Green', 'Yellow', 'Red', 'Blue (No Hit)', 'Insufficient Information', 'Not Checked', 'PO Box'};
		for (String pre_screen : pre_screens) {
			my_ext.view_apt.Scheduled_Lead__r.Pre_Screen__c = pre_screen;
			my_ext.view_apt.Scheduled_Lead__r.Prospect_All_Score__c = '0';
			my_ext.getStar_url();
			my_ext.view_apt.Scheduled_Lead__r.Prospect_All_Score__c = '-5';
			my_ext.getStar_url();
		}
		test.stopTest();
	}

	static testMethod void ScheduleApt_Reschedule() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_lead.Reminder_Call__c = 'Yes';
		my_ext.scheduling_lead.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();

		//my_ext.delete_aptblock();
		//my_ext.scheduling_lead = test_lead;
		//my_ext.getschedule_warnings();
		my_ext.send_confirmation_sms();

		my_ext.getapt_history();
		my_ext.schedule_consult();
		System.assert(my_ext.modal_out.contains('Consult is no longer available'));
		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

		my_ext.reschedule_reason = 'Testing';

		my_ext.reschedule_consult();
		my_ext.schedule_consult();

		test.stopTest();
	}

	static testMethod void ScheduleApt_Cancel() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_lead.Reminder_Call__c = 'Yes';
		my_ext.scheduling_lead.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();

		my_ext.delete_aptblock();
		my_ext.scheduling_lead = test_lead;
		my_ext.getschedule_warnings();
		my_ext.send_confirmation_sms();

		my_ext.getapt_history();
		my_ext.schedule_consult();
		System.assert(my_ext.modal_out.contains('Consult is no longer available'));
		my_ext.cancel_consult();

		my_ext.cancel_reason = null;
		my_ext.cancel_consult();

		my_ext.cancel_reason = 'Travel Issues';
		my_ext.cancel_consult();

		test.stopTest();
	}

	static testMethod void ScheduleApt_Reschedule_Cancel2() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today and scheduled_lead__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&acntid=' + test_account.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_account.Reminder_Call__c = 'Yes';
		my_ext.scheduling_account.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		my_ext.send_confirmation_sms();

		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

		my_ext.reschedule_consult();
		my_ext.schedule_consult();
		my_ext.view_apt.Confirmation_Status__c = 'Not Confirmed';
		my_ext.modify_aptblock();
		my_ext.view_apt.Treatment__c = 'Multiple';
		my_ext.modify_aptblock();
		test.stoptest();
	}

	static testMethod void ScheduleApt_Reschedule_tomorrow() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c > today limit 1];

		test_pp = new Private_Practice_Patient__c(center__c = test_center.id, first_name__c = 'test', last_name__c = 'patient', street_address__c = '23125 E Testing Street, Unit 102', city__c = 'Denver', state__c = 'Colorado', postal_code__c = '12561');
		insert test_pp;

		//pageref = new PageReference('/apex/sandbox_calendar_development?anum=' + my_apt.Id + '&ppid=' + test_pp.id);
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&acntid=' + test_account.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_account.Reminder_Call__c = 'Yes';
		my_ext.scheduling_account.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		my_ext.delete_reason = 'Test';
		my_ext.delete_aptblock();
		my_ext.scheduling_lead = test_lead;
		my_ext.getschedule_warnings();
		my_ext.send_confirmation_sms();

		my_ext.getapt_history();
		my_ext.schedule_consult();
		System.assert(my_ext.modal_out.contains('Consult is no longer available'));
		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

		my_ext.view_apt.Treatment__c = 'Single';
		my_ext.modify_aptblock();
		my_ext.view_apt.Confirmation_Status__c = 'LVM';
		my_ext.modify_aptblock();
		my_ext.view_apt.Apt_Notes__c = 'Test';
		my_ext.modify_aptblock();
		my_ext.reschedule_consult();
		my_ext.schedule_consult();

		test.stopTest();
	}

	static testMethod void test_sms_tomorrow() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c > today and scheduled_lead__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&acntid=' + test_account.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_account.Reminder_Call__c = 'Yes';
		my_ext.scheduling_account.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		my_ext.send_confirmation_sms();
		test.stopTest();
	}

	static testMethod void ScheduleApt_Reschedule_Cancel_tomorrow2() {
		 init();
		test.startTest();

		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c > today and scheduled_lead__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&acntid=' + test_account.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_account.Reminder_Call__c = 'Yes';
		my_ext.scheduling_account.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

		my_ext.reschedule_consult();
		my_ext.schedule_consult();
		my_ext.view_apt.Treatment__c = 'Multiple';
		my_ext.modify_aptblock();
		my_ext.view_apt.Treatment__c = 'Single';
		my_ext.modify_aptblock();
		my_ext.view_apt.Confirmation_Status__c = 'LVM';
		my_ext.modify_aptblock();
		my_ext.view_apt.Confirmation_Status__c = 'Not Confirmed';
		my_ext.modify_aptblock();
		my_ext.cancel_consult();
		my_ext.update_initiative();

		test.stopTest();
	}

	static testMethod void ScheduleApt_Reschedule_Cancel_future() {
		init();
		test.startTest();
		Date fdate = system.today().addDays(7);
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c >=:fdate limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_lead.Reminder_Call__c = 'Yes';
		my_ext.scheduling_lead.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		my_ext.seminar_reserve();
		System.assert(my_ext.modal_out.contains('Consult is no longer available'));
		my_ext.delete_reason = 'Test';
		my_ext.delete_aptblock();

		my_ext.scheduling_lead = test_lead;
		my_ext.getschedule_warnings();
		my_ext.send_confirmation_sms();

		my_ext.getapt_history();
		my_ext.schedule_consult();
		System.assert(my_ext.modal_out.contains('Consult is no longer available'));
		ctrl_consultschedule_development.Consult_Rooms[] my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

		my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c >= :fdate and scheduled_lead__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&acntid=' + test_account.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.getallow_scheduling();
		my_ext.scheduling_account.Reminder_Call__c = 'Yes';
		my_ext.scheduling_account.Reminder_Text__c = 'Yes';
		my_ext.schedule_consult();
		my_ext.send_confirmation_sms();

		my_rooms = my_ext.getview_allrooms();
		System.assertEquals(my_rooms.size(), 2);
		for(ctrl_consultschedule_development.Consult_Rooms cr : my_rooms) {
		  System.assertEquals(cr.getnum_notes(),0);
		  for(ctrl_consultschedule_development.Consult_Rows crow : cr.consult_view) {
		    crow.getrow_label();
		    for(ctrl_consultschedule_development.Consult_Apts capt : crow.row_apts) {
		      capt.getprescreen_label();
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

	static testMethod void test_hold() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id  and scheduled_lead__c = null and scheduled_account__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();
		my_ext.place_hold();
		Integer i = [select count() from Consult_Holds__c where consult_inventory__c = :my_apt.id and active_hold__c = true];
		System.assert(i >0);
		my_ext.remove_hold();
		i = [select count() from Consult_Holds__c where consult_inventory__c = :my_apt.id and active_hold__c = true];
		System.assert(i == 0);

		test.stopTest();
	}

	static testMethod void room_notes() {
		init();
		test.startTest();

		pageref = new PageReference('/apex/manage_schedule_templates?rnum=' + test_room.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.modify_room_form();

		my_ext.new_note.Comment__c = '1';
		my_ext.new_note.Note_Date__c = system.today().addDays(1);
		my_ext.end_note.Note_Date__c = system.today();
		my_ext.add_room_note();
		System.assert(my_ext.new_room_issues.contains('End Date must be after the start date for the note'));
		System.assert(my_ext.new_room_issues.contains('Note must be more than three characters long'));

		my_ext.new_note.Note_date__c = system.today();
		my_ext.new_note.Comment__c = 'Test.  This note should work';
		my_ext.add_room_note();

		Consult_Room_Note__c my_note = [select id from COnsult_Room_Note__c where consult_room__c = :test_room.id limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?nnum=' + my_note.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.modify_note_form();
		my_ext.new_note.Comment__c = 'Test Changing note';
		my_ext.modify_room_note();
		Integer ncount = [select count() from Consult_Room_Note__c where consult_room__c = :test_room.id];
		System.assertequals(ncount,1);

		pageref = new PageReference('/apex/manage_schedule_templates?nnum=' + my_note.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.modify_note_form();
		my_ext.new_note.Comment__c = '';
		my_ext.modify_room_note();
		ncount = [select count() from Consult_Room_Note__c where consult_room__c = :test_room.id];
		System.assertequals(ncount,0);

		test.stopTest();
	}

	static testMethod void print_view() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id  and scheduled_lead__c = null and scheduled_account__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		for(ctrl_clinicschedule.Print_Consult_Rooms pc : my_ext.getview_allprintrooms()) {
		  pc.getnum_notes();
		  for(ctrl_clinicschedule.Print_Consult_Inventory pci : pc.all_apts) {
		    System.debug('Callback Consult : ' + pci.capt.callback_consult__c);
		    pci.getavail_text();
		    pci.getblock_text();
		    pci.getend_time();
		    pci.getstart_time();
		  }
		}
		my_ext.display_printview();

		test.stopTest();
	}

	static testMethod void misc_actions() {
		init();
		test.startTest();
		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id  and scheduled_lead__c = null and scheduled_account__c = null limit 1];
		pageref = new PageReference('/apex/manage_schedule_templates?anum=' + my_apt.Id + '&lid=' + test_lead.id);
		Test.setCurrentPage(pageref);
		my_ext = new ctrl_consultschedule_development();
		my_ext.getapt_history();

		my_ext.display_consults();
		// my_ext.display_admin = null;
		// my_ext.getdisplay_admin();
		// my_ext.display_cc = null;
		// my_ext.getdisplay_cc();
		// my_ext.display_confirmation = null;
		// my_ext.getdisplay_confirmation();
		// my_ext.display_cc_sup = null;
		// my_ext.getdisplay_cc_sup();
		// my_ext.display_seminar = null;
		// my_ext.getdisplay_seminar();
		// my_ext.display_cc_lead = null;
		// my_ext.getdisplay_cc_lead();
		my_ext.change_center();
		my_ext.getclinic_link();
		my_ext.display_ca = null;
		my_ext.getdisplay_ca();
		my_ext.getallow_history();
		my_ext.getallow_delete();
		my_ext.getallow_remove_hold();
		my_ext.getallow_hold();
		my_ext.getisLeadValid();
		my_ext.getallow_clone();
		my_ext.clone_block();
		my_ext.getreschedule_reason_list();
		my_ext.reschedule_consult_view();
		my_ext.reschedule_cancel();
		my_ext.change_mass_dates();
		my_ext.mass_start = new Consult_Room_Note__c(Note_Date__c = system.today(), Consult_Room__c = test_room.id);
		my_ext.mass_end = new Consult_Room_Note__c(Note_Date__c = system.today(), Consult_Room__c = test_room.id);
		my_ext.new_room = test_room;
		my_ext.mass_delete_reason = 'cuz';
		my_ext.verify_mass_clear();
		my_ext.check_mass_clear();
		my_ext.mass_start.note_date__c = System.today().adddays(-1);
		my_ext.mass_end.note_date__c = System.today().adddays(-5);
		my_ext.check_mass_clear();
		my_ext.deactivate_room();

		//my_ext.deactivate_room();
		//my_ext.getnum_futureapts();

		test.stoptest();
	}

	static testMethod void lead_consultschedule_development() {
		init();
		test.startTest();

		ApexPages.StandardController con = new ApexPages.StandardController(test_lead);
		lead_consultschedule_development lead_ext = new lead_consultschedule_development(con);
		String sdate = lead_ext.getscheduled_consults_string();
		System.assertEquals('None', sdate);
		String aid = lead_ext.getcurrent_aptid();
		System.assert(aid==null);
		lead_ext.getsearch_consult_results();
		lead_ext.getopen_schedule_test();
		// List<Selectoption> btimes = lead_ext.getbetween_times();
		lead_ext.find_next_available();
		lead_consultschedule_development.next_consult[] consult_list = lead_ext.getsearch_consult_results();
		lead_ext.getaval_size();
		for(lead_consultschedule_development.next_consult nc : consult_list) {
		  nc.getday_of_week();
		//   nc.getend_time();
		  nc.getstart_time();
		  nc.getroom_name();
		  nc.getroom_type();
		}


		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c >=today limit 1];
		pageref = new PageReference('/apex/lead_consult_search_development?aid=' + my_apt.id);
		Test.setCurrentPage(pageref);
		lead_ext = new lead_consultschedule_development(con);
		lead_ext.schedule_consult();
		sdate = lead_ext.getscheduled_consults_string();
		System.assert(sdate!=null);

		lead_ext.getcontact_num();
		lead_ext.getschedule_num();
		lead_ext.getisLeadValid();

		test.stopTest();
	}

	static testMethod void lead_consultschedule2_development() {
		init();
		test.startTest();

		ApexPages.StandardController con = new ApexPages.StandardController(test_lead);
		lead_consultschedule_development lead_ext = new lead_consultschedule_development(con);
		// test_lead.receive_text_reminder__c = true;
		// test_lead.receive_auto_reminder__c = true;
		// lead_ext.update_lead_reminder_preference();
		lead_ext.l.Reminder_Call__c = 'Yes';
		lead_ext.l.Reminder_Text__c = 'Yes';
		lead_ext.set_reminder_checkboxes_when_reminder_radios_change();

		SelectOption[] time_groups = lead_ext.gettime_group_options();
		for (SelectOption time_group : time_groups) {
		    lead_ext.time_group = time_group.getValue();
		    lead_ext.find_next_available();
		}

		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c >=today limit 1];
		pageref = new PageReference('/apex/lead_consult_search_development?aid=' + my_apt.id);
		Test.setCurrentPage(pageref);
		lead_ext = new lead_consultschedule_development(con);
		lead_ext.schedule_consult();

		test_lead.pre_screen__c = 'Red';
		test_lead.phone = 'ABCDEFGHIJKLMNOPQRST';
		test_lead.mobilephone = '7913321582';
		test_lead.Hot_List__c =  true;
		test_lead.ignoreValidation__c = true;
		update test_lead;
		lead_ext.getisLeadValid();

		lead_ext.set_reminder_checkboxes_when_reminder_radios_change();

		test.stopTest();
	}

	static testMethod void account_consultschedule_development() {
		init();
		test.startTest();

		ApexPages.StandardController con = new ApexPages.StandardController(test_account);
		account_consultschedule_development account_ext = new account_consultschedule_development(con);
		String sdate = account_ext.getscheduled_consults_string();
		System.assertEquals('None', sdate);
		String aid = account_ext.getcurrent_aptid();
		System.assert(aid==null);
		account_ext.getsearch_consult_results();
		account_ext.getopen_schedule_test();
		// List<Selectoption> btimes = account_ext.getbetween_times();
		account_ext.find_next_available();
		account_consultschedule_development.next_consult[] consult_list = account_ext.getsearch_consult_results();
		account_ext.getaval_size();
		for(account_consultschedule_development.next_consult nc : consult_list) {
		  nc.getday_of_week();
		//   nc.getend_time();
		  nc.getstart_time();
		  nc.getroom_name();
		  nc.getroom_type();
		}
		account_ext.seminar = true;
		account_ext.find_next_available();

		SelectOption[] time_groups = account_ext.gettime_group_options();
		for (SelectOption time_group : time_groups) {
		    account_ext.time_group = time_group.getValue();
		    account_ext.find_next_available();
		}

		Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c >=today limit 1];
		pageref = new PageReference('/apex/account_consult_search?aid=' + my_apt.id);
		Test.setCurrentPage(pageref);
		account_ext = new account_consultschedule_development(con);
		account_ext.schedule_consult();
		sdate = account_ext.getscheduled_consults_string();
		System.assert(sdate!=null);
		account_ext.getconsult_history_list();

		// account_ext.getlead_phone();
		account_ext.record_openby();

		test.stopTest();
	}

	static testMethod void test_Consultbuilder() {
		init();
		test.startTest();
		Consult_Inventory_Builder.build_room_inventory();
		test.stopTest();
	}

	static testMethod void test_WeatherApi() {
		init();
		test.startTest();
		my_ext = new ctrl_consultschedule_development();
		Center_Information__c ci = [select id,name,zip_code__c from Center_Information__c where name = 'Test Center'];
		my_ext.selected_center = ci.id;
		Test.setMock(HttpCalloutMock.class, new WeatherUnderGroundMock());
		my_ext.check_for_weather_data();
		Weather__c w = my_ext.getweather_info(System.today());
		test.stopTest();
	}

	static testMethod void test_Confirmation_Assignment_with_no_existing_notes() {
		my_ext = new ctrl_consultschedule_development();
		my_ext.view_apt = new Consult_Inventory__c();
		my_ext.view_apt.Confirmation_Status__c = 'Not Confirmed';

		test.startTest();
			// Set confirmation attempt 1 to 'Skeptical', Confirmation Status should stay as it was
			my_ext.notes_number = 1;
			my_ext.notes_selection_index = 3;
			my_ext.set_notes();
			system.assertEquals('Not Confirmed', my_ext.view_apt.Confirmation_Status__c);
			system.assertEquals('*1. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Skeptical', my_ext.view_apt.Apt_Notes__c);

			// Set confirmation attempt 2 to 'Message', Confirmation Status should change to 'Message'
			my_ext.notes_number = 2;
			my_ext.notes_selection_index = 2;
			my_ext.set_notes();
			system.assertEquals('LVM', my_ext.view_apt.Confirmation_Status__c);
			system.assertEquals('*1. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Skeptical' + '; ' + '*2. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Message', my_ext.view_apt.Apt_Notes__c);

			// Set confirmation attempt 3 to 'Confirmed', Confirmation Status should change to 'Confirmed'
			my_ext.notes_number = 3;
			my_ext.notes_selection_index = 0;
			my_ext.set_notes();
			system.assertEquals('Confirmed', my_ext.view_apt.Confirmation_Status__c);
			system.assertEquals('*1. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Skeptical' + '; ' + '*2. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Message' + '; ' + '*3. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Confirmed', my_ext.view_apt.Apt_Notes__c);

			system.assertEquals(true, my_ext.getfirst_confirmation_complete());
			system.assertEquals(false, my_ext.getconfirmed_on_first_call());
			system.assert(my_ext.getuser_initials() != null);
		test.stopTest();
	}

	static testMethod void test_Confirmation_Assignment_with_existing_note() {
		my_ext = new ctrl_consultschedule_development();
		my_ext.view_apt = new Consult_Inventory__c();
		system.assertEquals(null, my_ext.view_apt.Confirmation_Status__c);
		String original_note = '*1. ' + Date.newInstance(2000, 1, 1).format() + ' Test Username: Not Confirmed';
		my_ext.view_apt.Apt_Notes__c = original_note;

		test.startTest();
			// Set confirmation attempt 2 to 'Confirmed'
			my_ext.notes_number = 2;
			my_ext.notes_selection_index = 0;
			my_ext.set_notes();
			system.assertEquals('Confirmed', my_ext.view_apt.Confirmation_Status__c);
			system.assertEquals(original_note + '; ' + '*2. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Confirmed', my_ext.view_apt.Apt_Notes__c);
		test.stopTest();
	}

	static testMethod void test_Confirmation_Assignment_with_starter_note() {
		my_ext = new ctrl_consultschedule_development();
		my_ext.view_apt = new Consult_Inventory__c();
		system.assertEquals(null, my_ext.view_apt.Confirmation_Status__c);
		String starter_note = 'Test starter note';
		my_ext.view_apt.Apt_Notes__c = starter_note;

		test.startTest();
			// Set confirmation attempt 1 to 'Confirmed'
			my_ext.notes_number = 1;
			my_ext.notes_selection_index = 0;
			my_ext.set_notes();
			system.assertEquals(starter_note + '; ' + '*1. ' + Date.today().format() + ' ' + UserInfo.getName() + ': Confirmed', my_ext.view_apt.Apt_Notes__c);
		test.stopTest();
	}

	static testMethod void test_confirmation_conflict() {
		my_ext = new ctrl_consultschedule_development();
		my_ext.view_apt = new Consult_Inventory__c();
		my_ext.view_apt.Confirmation_Status__c = 'Not Confirmed';

		test.startTest();
			// Set confirmation attempt 1 to 'Skeptical', Confirmation Status should stay as it was
			my_ext.notes_number = 1;
			my_ext.notes_selection_index = 3;
			my_ext.set_notes();
			system.assertEquals('Not Confirmed', my_ext.view_apt.Confirmation_Status__c);
			system.assertEquals(false, my_ext.getconfirmation_conflict());

			my_ext.view_apt.Confirmation_Status__c = 'Confirmed';
			system.assertEquals(true, my_ext.getconfirmation_conflict());
		test.stopTest();
	}

	static testMethod void test_getdouble_consult_options_are_correct() {
		init();
		my_ext = new ctrl_consultschedule_development();
		my_ext.selected_center = test_center.ID;
		my_ext.selected_date = system.today();
		Consult_Inventory__c[] todays_consults = [SELECT ID, Apt_Date__c, Patient_Name__c FROM Consult_Inventory__c WHERE Apt_Date__c = :my_ext.selected_date AND Consult_Room__r.Center_Information__c = :my_ext.selected_center LIMIT 10];
		Lead[] leads = [SELECT ID, Full_Name__c FROM Lead WHERE isConverted = false LIMIT 10];
		system.assert(todays_consults.size() > 0);
		system.assert(leads.size() > 0);

		for (Integer i = 0; i < (todays_consults.size() < leads.size() ? todays_consults.size() : leads.size()); i++) {todays_consults[i].Scheduled_Lead__c = leads[i].ID;}
		update todays_consults;

		Consult_Inventory__c[] todays_appointments = [SELECT ID, Apt_Date__c, Patient_Name__c FROM Consult_Inventory__c WHERE (Scheduled_Lead__c != null OR Scheduled_Account__c != null) AND Apt_Date__c = :my_ext.selected_date AND Consult_Room__r.Center_Information__c = :my_ext.selected_center LIMIT 10];
		Set<String> todays_patients = new Set<String>();
		for (Consult_Inventory__c appointment : todays_appointments) {todays_patients.add(appointment.Patient_Name__c);}

		Lead lead_to_link_to_double_consult = leads[0];
		my_ext.view_apt = [SELECT ID FROM Consult_Inventory__c WHERE Apt_Date__c = :my_ext.selected_date AND Consult_Room__r.Center_Information__c = :my_ext.selected_center AND Scheduled_Lead__c = :lead_to_link_to_double_consult.ID];
		selectOption[] double_consult_options = my_ext.getdouble_consult_options();
		Set<String> double_consult_candidates = new Set<String>();
		for (SelectOption option : double_consult_options) {double_consult_candidates.add(option.getLabel());}

		// Test the lead we're connecting to a double consult is not listed as a potential double consult since you don't want to connect the consult to itself
		system.assertEquals(false, double_consult_candidates.contains(lead_to_link_to_double_consult.Full_Name__c));

		// Confirm 'None' is in the set, then remove it
		system.assertEquals(true, double_consult_candidates.contains('None'));
		double_consult_candidates.remove('None');

		// Confirm all real names in the list of candidates come from the original list of today's patients
		for (String double_consult_candidate : double_consult_candidates) {
			system.assertEquals(true, todays_patients.contains(double_consult_candidate));
		}
	}

	static testMethod void test_bulk_permanent_hold() {
		init();
		test.startTest();
			Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
			pageref = new PageReference('/apex/sandbox_calendar_development?anum=' + my_apt.Id + '&lid=' + test_lead.id);
			Test.setCurrentPage(pageref);
			ctrl_consultschedule_development controller = new ctrl_consultschedule_development();
			controller.getroom_options_with_all();
			controller.getscheduled_status_options();
			controller.gethour_options();
			controller.getminute_options();
			ctrl_consultschedule_development.Consult_Rooms[] consult_rooms = controller.getview_allrooms();
			ID[] room_IDs = new ID[]{};
			for (ctrl_consultschedule_development.Consult_Rooms room : consult_rooms) {room_IDs.add(room.room.id);}
			Consult_Inventory__c[] consults = [SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c
												FROM Consult_Inventory__c
												WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
												AND Consult_Room__c IN :room_IDs
												AND Active__c = true];
			system.assert(consults.size() > 0);
			for (Consult_Inventory__c consult : consults) {
				system.assert(consult.Pre_Screen_Type__c != 'Seminar');
			}

			controller.bulk_change_room_filter      = 'all';
			controller.bulk_change_scheduled_status = 'any';
			controller.bulk_change_start_hour       = 7;
			controller.bulk_change_start_minute     = 0;
			controller.bulk_change_end_hour         = 21;
			controller.bulk_change_end_minute       = 0;
			controller.bulk_add_permanent_hold();

			Consult_Inventory__c[] consults_permanent_hold_added = [SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c
																	FROM Consult_Inventory__c
																	WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
																	AND Consult_Room__c IN :room_IDs
																	AND Active__c = true];
			system.assert(consults_permanent_hold_added.size() > 0);
			system.debug('Consult count: ' + consults_permanent_hold_added.size());
			for (Consult_Inventory__c consult : consults_permanent_hold_added) {
				system.assertEquals('Seminar', consult.Pre_Screen_Type__c);
			}

			controller.bulk_remove_permanent_hold();
			Consult_Inventory__c[] consults_permanent_hold_removed = [SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c, Color__c
																		FROM Consult_Inventory__c
																		WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
																		AND Consult_Room__c IN :room_IDs
																		AND Active__c = true];
			system.assert(consults_permanent_hold_removed.size() > 0);
			system.debug('Consult count: ' + consults_permanent_hold_removed.size());
			for (Consult_Inventory__c consult : consults_permanent_hold_removed) {
				// 'Green' consults should have Pre_Screen_Type__c of 'Green/Yellow' - 'Purple' consults should be 'Any'
				if (consult.Color__c == 'Green'  || consult.Color__c == 'Light Green')  {system.assertEquals('Green/Yellow', consult.Pre_Screen_Type__c);}
				if (consult.Color__c == 'Purple' || consult.Color__c == 'Light Purple') {system.assertEquals('Any',          consult.Pre_Screen_Type__c);}
			}

		test.stopTest();
	}

	static testMethod void test_bulk_delete_unscheduled() {
		// Should remove all unscheduled appointments and keep scheduled appointments, even if the filters would normally catch scheduled appointments.
		init();
		test.startTest();
			Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
			pageref = new PageReference('/apex/sandbox_calendar_development?anum=' + my_apt.Id + '&lid=' + test_lead.id);
			Test.setCurrentPage(pageref);
			ctrl_consultschedule_development controller = new ctrl_consultschedule_development();
			controller.getapt_history();
			controller.scheduling_lead.Reminder_Call__c = 'Yes';
			controller.scheduling_lead.Reminder_Text__c = 'Yes';
			controller.schedule_consult();

			ctrl_consultschedule_development.Consult_Rooms[] consult_rooms = controller.getview_allrooms();
			ID[] room_IDs = new ID[]{};
			for (ctrl_consultschedule_development.Consult_Rooms room : consult_rooms) {room_IDs.add(room.room.id);}
			Consult_Inventory__c[] consults = [SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c, Scheduled_Lead__c, Scheduled_Account__c, Scheduled_Patient__c
												FROM Consult_Inventory__c
												WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
												AND Consult_Room__c IN :room_IDs
												AND Active__c = true];

			Integer not_scheduled = 0;
			Integer     scheduled = 0;
			for (Consult_Inventory__c consult : consults) {
				Boolean is_scheduled = consult.Scheduled_Lead__c != null || consult.Scheduled_Account__c != null || consult.Scheduled_Patient__c != null;
				if (is_scheduled) {scheduled++;}
				else              {not_scheduled++;}
			}

			system.assert(consults.size() > 1);
			system.assert(not_scheduled > 0);
			system.assert(scheduled > 0);

			controller.bulk_change_room_filter      = 'all';
			controller.bulk_change_scheduled_status = 'any';
			controller.bulk_change_start_hour       = 7;
			controller.bulk_change_start_minute     = 0;
			controller.bulk_change_end_hour         = 21;
			controller.bulk_change_end_minute       = 0;
			controller.bulk_remove_unscheduled_appointments();

			Integer consults_remaining = [SELECT count()
											FROM Consult_Inventory__c
											WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
											AND Consult_Room__c IN :room_IDs
											AND Active__c = true];

			system.assertEquals(consults.size() - not_scheduled, consults_remaining);
			system.assertEquals(1, consults_remaining);
		test.stopTest();
	}

	static testMethod void test_bulk_time_shift() {
		init();
		test.startTest();
			Consult_Inventory__c my_apt = [select id from Consult_Inventory__c where consult_room__c = :test_room.id and apt_date__c = today limit 1];
			pageref = new PageReference('/apex/sandbox_calendar_development?anum=' + my_apt.Id + '&lid=' + test_lead.id);
			Test.setCurrentPage(pageref);
			ctrl_consultschedule_development controller = new ctrl_consultschedule_development();
			ctrl_consultschedule_development.Consult_Rooms[] consult_rooms = controller.getview_allrooms();
			ID[] room_IDs = new ID[]{};
			for (ctrl_consultschedule_development.Consult_Rooms room : consult_rooms) {room_IDs.add(room.room.id);}
			Time start_time;
			Time end_time;

			Consult_Inventory__c[] consults = [SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c
												FROM Consult_Inventory__c
												WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
												AND Consult_Room__c IN :room_IDs
												AND Active__c = true];
			system.assert(consults.size() > 0);

			Map<ID, Map<String, Time>> original_times_by_consult = new Map<ID, Map<String, Time>>{};
			for (Consult_Inventory__c consult : consults) {
				start_time = Time.newInstance(Integer.valueOf(consult.Start_Hour__c), Integer.valueOf(consult.Start_Minute__c), 0, 0);
				end_time   = Time.newInstance(Integer.valueOf(consult.End_Hour__c),   Integer.valueOf(consult.End_Minute__c),   0, 0);
				original_times_by_consult.put(consult.id, new Map<String, Time>{'start' => start_time, 'end' => end_time});
			}

			controller.bulk_change_room_filter      = 'all';
			controller.bulk_change_scheduled_status = 'any';
			controller.bulk_change_start_hour       = 7;
			controller.bulk_change_start_minute     = 0;
			controller.bulk_change_end_hour         = 21;
			controller.bulk_change_end_minute       = 0;
			controller.bulk_change_time_shift       = 15;
			controller.bulk_time_shift();

			Consult_Inventory__c[] updated_consults = [SELECT ID, Pre_Screen_Type__c, Start_Hour__c, Start_Minute__c, End_Hour__c, End_Minute__c
														FROM Consult_Inventory__c
														WHERE Apt_Date__c >= :controller.selected_date AND Apt_Date__c <= :controller.bulk_change_end_date
														AND Consult_Room__c IN :room_IDs
														AND Active__c = true];
			system.assert(consults.size() > 0);

			Map<ID, Map<String, Time>> shifted_times_by_consult = new Map<ID, Map<String, Time>>{};
			for (Consult_Inventory__c consult : updated_consults) {
				start_time = Time.newInstance(Integer.valueOf(consult.Start_Hour__c), Integer.valueOf(consult.Start_Minute__c), 0, 0);
				end_time   = Time.newInstance(Integer.valueOf(consult.End_Hour__c),   Integer.valueOf(consult.End_Minute__c),   0, 0);
				shifted_times_by_consult.put(consult.id, new Map<String, Time>{'start' => start_time, 'end' => end_time});
			}
			system.debug('Consult count: ' + consults.size());

			for (Consult_Inventory__c consult : updated_consults) {
				system.assertEquals(original_times_by_consult.get(consult.id).get('start').addMinutes(controller.bulk_change_time_shift), shifted_times_by_consult.get(consult.id).get('start'));
				system.assertEquals(original_times_by_consult.get(consult.id).get('end').addMinutes(controller.bulk_change_time_shift),   shifted_times_by_consult.get(consult.id).get('end'));
			}
		test.stopTest();
	}

}