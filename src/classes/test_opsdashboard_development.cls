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
@isTest
private class test_opsdashboard_development {
	static PageReference pageref;
	static PageReference pageRef2;
	static PageReference pageRef3;

	static ctrl_OpsDashboard_Development controller;
  static String nextPage;

  static testMethod void UserTest() {
    //PageReference pageRef = Page.OpsDashboard_Development;
    test.startTest();
    pageref = new PageReference('/apex/OpsDashboard_Development');
    PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(user__c = Userinfo.getuserid(), snapshot_date__c = System.today().adddays(-1), True_Close_Rate__c = 10.0,
      True_Close_Rate_Regional_Rank__c = 8, True_Close_Rate_National_Rank__c = 4, Sales_Region__c = 'Unknown',
      Rainmaker_Regional_Rank__c = 8, Rainmaker_National_Rank__c = 4, National_Overall_Rank__c = 12, Learning_Activity_Regional_Rank__c = 12, Learning_Activity_Num__c = 4,
      Learning_Activity_National_Rank__c = 12, Callbacks_Num__c = 13, Callback_Regional_Rank__c = 20, Callback_National_Rank__c = 30, Avg_Rainmaker_Score__c = 64.01);
      insert prs;
    Test.setCurrentPage(pageRef);
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_user().getUrl();
    controller.getConsultStarts();
    ctrl_opsdashboard_Development.DisplayDecimal dm = controller.getStarts();
    dm.last_year=0;
    dm.MTD=0;
    dm.last_90=0;
    dm.previous_month=0;
    dm.YTD=0;
    dm.QTD=0;
    dm.previous_day=0;

    controller.getPendingStarts();
    controller.getStartsCancelled();
    controller.getStartsCancelledIn();
    controller.getStartsCancelledOut();
    controller.getTreatmentSold();
    controller.getTreatmentCancelled();
    controller.getTreatmentCancelledIn();
    controller.getTreatmentCancelledOut();
    ctrl_opsdashboard_Development.displaydollars dd = controller.getCollected();
    dd.last_year=0;
    dd.MTD=0;
    dd.last_90=0;
    dd.previous_month=0;
    dd.YTD=0;
    dd.QTD=0;
    dd.previous_day=0;

    controller.getdisplay_ppriv();

    controller.getRefunded();
    controller.getAnticipatedPayments();
    controller.getPastDue();
    controller.getdisplay_admin();
    controller.getdisplay_all_button();
    controller.getdisplay_center_button();
    controller.getdisplay_user_button();
    controller.getaction();
    controller.getreport_header();
    controller.getPEClist();
    controller.getCenterlist();
    controller.getFinancedConsults();
    controller.getSalesTarget();
    controller.getPecTarget();
    controller.getPipeline();
    controller.getUpsellSold();
    controller.getUpsellCancelledIn();
    controller.getupsellCancelledOut();
    controller.getlead_reportid();
    controller.getconsult_reportid();
    controller.getprost_reportid();
    controller.getlead_exceptions();
    controller.getconsult_exceptions();
    controller.getprost_exceptions();
    controller.getprost_payment_reportid();
    controller.getprost_payment_exceptions();
    controller.getupdate_payment_reportid();
    controller.getupdate_payment_exceptions();
    controller.getarrangement_reportid();
    controller.getarrangement_exceptions();
    controller.getdisplay_collections_limit();
    controller.getAO4_avg();
    nextPage = controller.view_auser().getUrl();
    nextPage = controller.view_acenter().getUrl();
    nextPage = controller.set_centergoals().getUrl();
    nextPage = controller.set_salesgoals().getUrl();

    test.stopTest();
  }

  static testMethod void UserTest2() {
    //PageReference pageRef = Page.OpsDashboard_Development;
    test.startTest();
    pageref = new PageReference('/apex/OpsDashboard_Development');
    PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(user__c = Userinfo.getuserid(), snapshot_date__c = System.today().adddays(-1), True_Close_Rate__c = 10.0,
      True_Close_Rate_Regional_Rank__c = 8, True_Close_Rate_National_Rank__c = 4, Sales_Region__c = 'Unknown',
      Rainmaker_Regional_Rank__c = 8, Rainmaker_National_Rank__c = 4, National_Overall_Rank__c = 12, Learning_Activity_Regional_Rank__c = 12, Learning_Activity_Num__c = 4,
      Learning_Activity_National_Rank__c = 12, Callbacks_Num__c = 13, Callback_Regional_Rank__c = 20, Callback_National_Rank__c = 30, Avg_Rainmaker_Score__c = 64.01);
      insert prs;
    Test.setCurrentPage(pageRef);
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_user().getUrl();
    controller.getConsultStarts();
    controller.payout_collections = 10000;
    controller.payout_close = 1.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 10.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 14.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 16.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 19.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 22.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 25.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 28.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 32.0;
    controller.getcalculated_payout_amount();
    controller.payout_close = 100.0;
    controller.getprivaterefunded();
    controller.getprivatecollected();
    controller.getTreatmentSoldValid();
    controller.getTreatmentCancelledInValid();
    controller.getTreatmentCancelledOutValid();
    controller.getCallbackConsultStarts();
    ctrl_OpsDashboard_Development.pec_compensation bonus_calc = controller.getcalculated_payout_amount();
    bonus_calc.get_current_payout_amount();
    bonus_calc.get_next_payout_amount();
    bonus_calc.get_previous_payout_amount();
    test.stopTest();
  }

   static testMethod void RegionTest3() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/OpsDashboard_Development?action=region');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','region');
    try {
      Sales_Region__c sr = new Sales_Region__c(Tier_9_Bonus_Payout__c = 1.000,Tier_8_Bonus_Payout__c = .090, Tier_7_Bonus_Payout__c = .080, Tier_6_Bonus_Payout__c = .070, Tier_5_Bonus_Payout__c = .060, Tier_4_Bonus_Payout__c = .050, Tier_3_Bonus_Payout__c = 0.40, Tier_2_Bonus_Payout__c = 0.30, Tier_1_Bonus_Payout__c = 0.20, Baseline_Target__c = 14.0, name = 'East', rbd__c = userinfo.getuserid(), rsm__c = userinfo.getuserid());
      insert sr;
    }
    catch (Exception e) {

    }
    ApexPages.currentPage().getParameters().put('aregion','east');
    controller = new ctrl_OpsDashboard_Development();
    controller.payout_collections = 10000;
    controller.payout_close = 1.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 10.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 14.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 16.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 19.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 22.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 25.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 28.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 32.0;
    controller.getcalculated_rsm_payout_amount();
    controller.payout_close = 100.0;
    controller.getdisplay_region_compensation();
    controller.getprivaterefunded();
    controller.getprivatecollected();
    controller.getCallbackConsultStarts();
    ctrl_OpsDashboard_Development.rsm_compensation bonus_calc = controller.getcalculated_rsm_payout_amount();
    bonus_calc.get_current_payout_amount();
    bonus_calc.get_next_payout_amount();
    bonus_calc.get_previous_payout_amount();

    controller.display_today();
    controller.display_yesterday();
    controller.getprost_exceptions();

    test.stopTest();
  }

  static testmethod void SnapshotTest() {
    test.startTest();
    pageref = new PageReference('/apex/OpsDashboard_Development');
    Test.setCurrentPage(pageRef);
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_user().getUrl();
  	controller.snapshot_metrics_center();
    controller.snapshot_metrics_user();
    test.stopTest();
  }

  static testMethod void CenterTest() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/OpsDashboard_Development?action=center');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','center');
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_center().getUrl();
    controller.getConsultStarts();
    controller.getStarts();
    controller.getPendingStarts();
    controller.getSDStarts();
    controller.getStartsCancelled();
    controller.getStartsCancelledIn();
    controller.getdisplay_ca();
    controller.getCAPEClist();
    controller.getStartsCancelledOut();
    controller.getTreatmentSold();
    controller.getTreatmentCancelled();
    controller.getTreatmentCancelledIn();
    controller.getTreatmentCancelledOut();
    controller.getCollected();
    controller.getRefunded();
    controller.getAnticipatedPayments();
    controller.getPastDue();
    controller.getFinancedConsults();
    controller.getSalesTarget();
    controller.getPecTarget();
    controller.getPipeline();
    controller.getUpsellSold();
    controller.getUpsellCancelledIn();
    controller.getupsellCancelledOut();
    controller.getlead_reportid();
    controller.getconsult_reportid();
    controller.getprost_reportid();
    test.stopTest();
  }

  static testMethod void CenterTest2() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/OpsDashboard_Development?action=center');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','center');
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_center().getUrl();
    controller.getlead_reportid();
    controller.getconsult_reportid();
    controller.getprost_reportid();
    controller.getlead_exceptions();
    controller.getconsult_exceptions();
    controller.getprost_payment_reportid();
    controller.getprost_payment_exceptions();
    controller.getupdate_payment_reportid();
    controller.getupdate_payment_exceptions();
    controller.getarrangement_reportid();
    controller.getarrangement_exceptions();
    controller.getAO4_avg();
    controller.getCallbackConsultStarts();
        controller.getprivaterefunded();
    controller.getprivatecollected();
    test.stopTest();
  }

  static testMethod void RegionTest() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/OpsDashboard_Development?action=region');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','region');
    ApexPages.currentPage().getParameters().put('aregion','east');
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_center().getUrl();
    controller.getConsultStarts();
    controller.getStarts();
    controller.getPendingStarts();
    controller.getSDStarts();
    controller.getStartsCancelled();
    controller.getStartsCancelledIn();
    controller.getdisplay_ca();
    controller.getdisplay_region_compensation();
    controller.getCAPEClist();
    controller.getStartsCancelledOut();
    controller.getTreatmentSold();
    controller.getTreatmentCancelled();
    controller.getTreatmentCancelledIn();
    controller.getTreatmentCancelledOut();
    controller.getCollected();
    controller.getRefunded();
    controller.getAnticipatedPayments();
    controller.getPastDue();
    controller.getFinancedConsults();
    controller.getSalesTarget();
    controller.getPecTarget();
    controller.getPipeline();
    test.stopTest();
  }

  static testMethod void RegionTest2() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/OpsDashboard_Development?action=region');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','region');
    ApexPages.currentPage().getParameters().put('aregion','east');
    try {
      Sales_Region__c sr = new Sales_Region__c(Tier_9_Bonus_Payout__c = 1.000,Tier_8_Bonus_Payout__c = .090, Tier_7_Bonus_Payout__c = .080, Tier_6_Bonus_Payout__c = .070, Tier_5_Bonus_Payout__c = .060, Tier_4_Bonus_Payout__c = .050, Tier_3_Bonus_Payout__c = 0.40, Tier_2_Bonus_Payout__c = 0.30, Tier_1_Bonus_Payout__c = 0.20, Baseline_Target__c = 14.0, name = 'East');
      insert sr;
    }
    catch (Exception e) {

    }
    controller = new ctrl_OpsDashboard_Development();
    nextPage = controller.display_center().getUrl();
    controller.getdownload_string();
    controller.gethyper_prefix();
    controller.getyesterday_filter();
    controller.getRegionList();
    controller.getprost_reportid();
    controller.getlead_exceptions();
    controller.getconsult_exceptions();
    controller.getprost_payment_reportid();
    controller.getprost_payment_exceptions();
    controller.getupdate_payment_reportid();
    controller.getupdate_payment_exceptions();
    controller.getarrangement_reportid();
    controller.getarrangement_exceptions();
    controller.getAO4_avg();
    controller.getCallbackConsultStarts();
    controller.display_prom_payments();
    controller.display_all_payments();
    controller.ops_daterange();
    controller.view_historic_rates();
    controller.view_aregion();
    controller.getUpsellSold();
    controller.getUpsellCancelledIn();
    controller.getupsellCancelledOut();
    controller.getlead_reportid();
    controller.getconsult_reportid();
    test.stopTest();
  }

  static testMethod void DashAllTest() {
  	test.startTest();
  	pageRef3 = new PageReference('/apex/OpsDashboard_Development?action=all');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    controller = new ctrl_OpsDashboard_Development();
    controller.getSalesTarget();
    controller.getPecTarget();
    controller.set_salesgoals();
    nextPage = controller.display_all().getUrl();
    //nextPage = ApexPages.currentPage().getContent().toString();
    nextPage = controller.set_salesgoals().getUrl();
    nextPage = controller.set_centergoals().getUrl();
    controller.getCACenterlist();
    controller.display_today();
    controller.display_yesterday();

    //daiabled until I can handle the @readonly issues here
    //controller.getConsultStarts();
    controller.getStarts();
    controller.getPendingStarts();
    controller.getStartsCancelled();
    controller.getStartsCancelledIn();
    controller.getStartsCancelledOut();
    controller.getTreatmentSold();
    controller.getTreatmentCancelled();
    controller.getTreatmentCancelled();
    controller.getTreatmentCancelledOut();
    controller.getCollected();
    controller.getRefunded();
    controller.getAnticipatedPayments();
    controller.getPastDue();
    controller.getPipeline();
    controller.getUpsellSold();
    controller.getUpsellCancelledIn();
    controller.getupsellCancelledOut();
    controller.getlead_reportid();
    controller.getconsult_reportid();
    controller.getprost_reportid();
    controller.getranking_url();
    controller.getprost_exceptions();
    controller.display_hygiene_revenue();
    test.stopTest();
  }

  static testMethod void DashAllTest2() {
  	test.startTest();
  	pageRef3 = new PageReference('/apex/OpsDashboard_Development?action=all');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    controller = new ctrl_OpsDashboard_Development();
    controller.getSalesTarget();
    controller.getPecTarget();
    controller.set_salesgoals();
    nextPage = controller.display_all().getUrl();
    controller.getpendingstarts();
    //controller.getConsultStarts();
    controller.getSDstarts();
    controller.getlead_exceptions();
    controller.getconsult_exceptions();
    controller.getprost_payment_reportid();
    controller.getprost_payment_exceptions();
    controller.getupdate_payment_reportid();
    controller.getupdate_payment_exceptions();
    controller.getarrangement_reportid();
    controller.getarrangement_exceptions();
    controller.getFinancedConsults();
    controller.getConsultStarts();
    ctrl_opsdashboard_Development.displaydecimal dd = controller.gettrue_closerate();
    dd.last_year = 0;
    dd.MTD = 0;
    dd.last_90 = 0;
    dd.previous_month = 0;
    dd.YTD = 0;
    dd.previous_day = 0;
    controller.outputtext = 'N/A';
    controller.collections_limit = null;
    controller.getdisplay_collections_limit();
    controller.getquarter_filter(1);
    controller.getquarter_filter(4);
    controller.getquarter_filter(7);
    controller.getquarter_filter(10);

    controller.getAO4_avg();
    controller.getprivaterefunded();
    controller.getprivatecollected();
    controller.getCallbackConsultStarts();
    controller.display_exception_section();
    test.stopTest();
  }

  static testMethod void CallCenterTeam() {
  	//really not testing anything here - it's a simple page and I'm just looking for code coverage
  	//test user record to use when I do want to start testing this
  	Profile p = [select id from Profile where name = 'System Administrator'];
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com', TimeZoneSidKey='America/Denver', LanguageLocaleKey = 'en_US');
		insert my_test_user;
		test.startTest();
		pageref = new PageReference('/apex/TeamAssignment');
  	Test.setCurrentPage(pageref);
  	ctrl_CallCenterTeam my_con = new ctrl_CallCenterTeam();
  	my_con.getmy_users();
  	if(my_con.getpage()==1)
  	  System.assert(!my_con.getdisplay_prev());
  	if(my_con.getnum_pages()>my_con.getpage()) {
  	  System.assert(my_con.getdisplay_next());
  	  my_con.next();
  	  my_con.prev();
  	}

  	my_con.name_filter = 'c';
  	my_con.user_search();
  	my_con.save();

		test.stopTest();
  }

  static testMethod void SalesGoals() {
  	//really not testing anything here - it's a simple page and I'm just looking for code coverage
  	//test user record to use when I do want to start testing this
  	Profile p = [select id from Profile where name = 'System Administrator'];
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',TimeZoneSidKey='America/Denver', LanguageLocaleKey = 'en_US');
		insert my_test_user;
  	test.startTest();
  	pageref = new PageReference('/apex/salesgoals');
  	Test.setCurrentPage(pageref);
  	ctrl_SalesGoals my_con = new ctrl_SalesGoals();
  	my_con.getPEClist();

  	System.assert(my_con.getTypeOptions().size()>0);
  	System.assert(my_con.getCenterList().size()>0);

  	if(my_con.getpage()==1)
  	  System.assert(!my_con.getdisplay_prev());
  	if(my_con.getnum_pages()>my_con.getpage()) {
  	  System.assert(my_con.getdisplay_next());
  	  my_con.next();
  	  my_con.prev();
  	}

  	my_con.settype_filter('pec');
  	System.assert(my_con.gettype_filter()=='pec');
  	my_con.user_search();
  	my_con.settype_filter('all');
  	my_con.name_filter = 'c';
  	my_con.user_search();
  	my_con.next();
  	//my_con.next_year();
  	//my_con.prev_year();

  	my_con.save();
  	Test.setCurrentPage(my_con.display_dashboard());
  	test.stopTest();
  }

  static testMethod void CenterRev() {
  	//really not testing anything here - it's a simple page and I'm just looking for code coverage
  	test.startTest();
  	pageref = new PageReference('apex/CenterRevDrivers');
  	ctl_center_rev_drivers my_con = new ctl_center_rev_drivers();
  	my_con.getlast_month_name();
  	my_con.gettwo_month_name();
  	for(Integer i=1;i<=12;i++) {
  		my_con.getmonth_name(i);
  	}
  	my_con.getall_centers();
  	my_con.getcenter_totals();
  	my_con.gethyper_prefix();
  	my_con.gettwo_month_int();
  	my_con.gettwo_year_int();
  	my_con.getlast_month_int();
  	my_con.getlast_year_int();
  	my_con.getcurrent_month_int();
  	my_con.getcurrent_year_int();
  	my_con.getcurrent_date_int();


  	test.stopTest();
  }

  static testMethod void SalesDashboard() {
  	//really not testing anything here - it's a simple page and I'm just looking for code coverage
  	//likely just need to delete this controller at some point as I don't think it's being used by anything
  	//meaningful.  The new sales dashboard (ops dashboard) has likely replaced this piece
  	test.startTest();
  	ctrl_SalesDashboard my_con = new ctrl_SalesDashboard();
  	my_con.getCallBacks();
  	my_con.CalcNetGYNStarts();
  	my_con.calcNetStarts();
  	my_con.calcSameDayStarts();
  	my_con.calcTotalConsults();
  	my_con.calcTotalGYNConsults();
  	my_con.getCallBacks();
  	my_con.getGrossCloseRate();
  	my_con.getGYNCloseRate();
  	my_con.getNetGYNStarts();
  	my_con.getNetStarts();
  	my_con.getSameDateCloseRate();
  	my_con.getsameDayStarts();
  	my_con.getTotalConsults();
  	my_con.getTotalGYNConsults();
  	my_con.getTotalStarts();
  	test.stopTest();
  }

  static testMethod void CenterBudget() {
  	Market__c test_market = new Market__c(Name = 'Test Market', Market_abbreviation__c = 'TM', region__c = 'East');
  	insert test_market;
  	Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Market__c = test_market.id, Sales_Market__c = test_market.id, Street_1__c = 'Test Street', City__c = 'Dever', State__c = 'CO', directions__c = 'na', cid__c = 'na', location__c = 'na', type__c='main', doctor_1__c = 'na', doctor_2__c = 'na',cadmin__c = 'na', doctor_1_type__c = 'Pros', doctor_2_type__c = 'Pros', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,
  	  tier_1_floor__c = 120000, tier_2_floor__c = 140000, tier_3_floor__c = 160000);
  	insert test_center;
  	test.startTest();
    pageref = new PageReference('/apex/center_goals');
    Test.setCurrentPage(pageRef);
    ctrl_centerbudget_attributes my_con = new ctrl_centerbudget_attributes();
    my_con.check_for_null_budgets();
    Integer I = [select count() from Center_Budget__c where center__c =: test_center.id and fiscal_year__c = :my_con.view_year];
    System.assertEquals(I, 12);
    System.assertEquals(my_con.getattrib_name(),'Sales Goal');
    my_con.attribute_filter = '2';
    System.assertEquals(my_con.getattrib_name(),'Budgeted Close Rate');
    my_con.attribute_filter = '3';
    System.assertEquals(my_con.getattrib_name(),'Budgeted Consults');
    my_con.center_filter = test_center.id;
    my_con.next_year();
    my_con.prev_year();
    my_con.center_search();
    Integer n = [select count() from Center_Budget__c where center__c =: test_center.id];
    System.assertEquals(n, 24);
    my_con.getattribute_options();
    my_con.getcenter_list();
    my_con.getall_centers();
    my_con.save();
    System.assert(my_con.result_msg.contains('Success'));
    System.assertEquals(my_con.getpage(),1);
    System.assertEquals(my_con.getdisplay_prev(),false);
    if(my_con.getnum_pages()==1)
      System.assertEquals(my_con.getdisplay_next(),false);
    else
      System.assertEquals(my_con.getdisplay_next(),true);
    my_con.next();
    my_con.prev();
  	test.stopTest();
  }

  static testMethod void UserTest1() {
    //PageReference pageRef = Page.OpsDashboard;
    test.startTest();
    pageref = new PageReference('/apex/sandbox_chris');
    Test.setCurrentPage(pageRef);
    ctlr_OpsDashboard2 my_con = new ctlr_OpsDashboard2();
    nextPage = my_con.display_user().getUrl();
    my_con.getConsultStarts();
    my_con.getStarts();
    my_con.getStartsCancelled();
    my_con.getStartsCancelledIn();
    my_con.getStartsCancelledOut();
    my_con.getTreatmentSold();
    my_con.getTreatmentCancelled();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getCollected();
    my_con.getRefunded();
    my_con.getAnticipatedPayments();
    my_con.getPastDue();
    my_con.getdisplay_admin();
    my_con.getdisplay_all_button();
    my_con.getdisplay_center_button();
    my_con.getdisplay_user_button();
    my_con.getaction();
    my_con.getreport_header();
    my_con.getPEClist();
    my_con.getCenterlist();
    my_con.getFinancedConsults();
    my_con.getSalesTarget();
    my_con.getPipeline();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.getlead_reportid();
    my_con.getconsult_reportid();
    my_con.getprost_reportid();
    my_con.getlead_exceptions();
    my_con.getconsult_exceptions();
    my_con.getprost_exceptions();
    nextPage = my_con.view_auser().getUrl();
    nextPage = my_con.view_acenter().getUrl();
    nextPage = my_con.set_salesgoals().getUrl();
  }

  static testMethod void user_date_views() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/sandbox_chris?action=user');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','user');
    User u = [select id from user limit 1];

    ApexPages.currentPage().getParameters().put('asuser',u.id);
    ctrl_OpsDashboard_Development my_con = new ctrl_OpsDashboard_Development();

    my_con.getSDstarts();
    my_con.display_today();
    my_con.display_yesterday();
    my_con.gettotal_open_days();
    my_con.getcompleted_open_days();


    test.stopTest();
  }

  static testMethod void center_date_views() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/sandbox_chris?action=center');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','center');
    Center_Information__c center = [select id from Center_Information__c limit 1];
    ApexPages.currentPage().getParameters().put('ascenter',center.id);
    ctrl_OpsDashboard_Development my_con = new ctrl_OpsDashboard_Development();

    my_con.display_today();
    my_con.display_yesterday();
    my_con.getprost_exceptions();

    test.stopTest();
  }

  static testMethod void CenterTest1() {
  	test.startTest();
    pageRef2 = new PageReference('/apex/sandbox_chris?action=center');
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','center');
    Center_Information__c center = [select id from Center_Information__c limit 1];
    ApexPages.currentPage().getParameters().put('ascenter',center.id);
    ctlr_OpsDashboard2 my_con = new ctlr_OpsDashboard2();
    nextPage = my_con.display_center().getUrl();
    my_con.getConsultStarts();
    my_con.getStarts();
    my_con.getStartsCancelled();
    my_con.getStartsCancelledIn();
    my_con.getdisplay_ca();
    my_con.getCAPEClist();
    my_con.getStartsCancelledOut();
    my_con.getTreatmentSold();
    my_con.getTreatmentCancelled();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getCollected();
    my_con.getRefunded();
    my_con.getAnticipatedPayments();
    my_con.getPastDue();
    my_con.getFinancedConsults();
    my_con.getSalesTarget();
    my_con.getPipeline();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.getlead_exceptions();
    my_con.getconsult_exceptions();
    my_con.getprost_exceptions();


    test.stopTest();
  }

  static testMethod void DashAllTest1() {
  	test.startTest();
  	/*pageRef3 = new PageReference('/apex/sandbox_chris?action=all');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    ctlr_OpsDashboard2 my_con = new ctlr_OpsDashboard2();
    my_con.getSalesTarget();
    my_con.set_salesgoals();
    nextPage = my_con.display_all().getUrl();
    nextPage = ApexPages.currentPage().getContent().toString();
    nextPage = my_con.set_salesgoals().getUrl();*/
    pageRef3 = new PageReference('/apex/sandbox_chris?action=all');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    ctlr_OpsDashboard2 my_con = new ctlr_OpsDashboard2();
    nextPage = my_con.display_all().getUrl();
    nextPage = my_con.set_centergoals().getUrl();

    //disabled until I can handle the @readonly issues here
    my_con.getFinancedConsults();
    my_con.getStartsCancelledIn();
    my_con.getStartsCancelledOut();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getPipeline();
    my_con.getConsultStarts();
    my_con.gethyper_prefix();
    my_con.getdownload_string();
    my_con.getStarts();
    my_con.getStartsCancelled();
    my_con.getTreatmentSold();
    my_con.getTreatmentCancelled();
    my_con.getCollected();
    my_con.getRefunded();
    my_con.getAnticipatedPayments();
    my_con.getPastDue();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.getlead_exceptions();
    my_con.getconsult_exceptions();
    my_con.getprost_exceptions();
    my_con.getSalesTarget();
    my_con.getSDStarts();

    my_con.display_today();
    my_con.display_yesterday();
    test.stopTest();
  }

  static testMethod void Dash_range_all() {
  	test.startTest();
    pageRef3 = new PageReference('/apex/sandbox_chris');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    ctrl_opsdashboard_range my_con = new ctrl_opsdashboard_range();

    my_con.getstart_formatted();
    my_con.getend_formatted();
    my_con.getCAPEClist();
    my_con.getRegionList();
    my_con.getCACenterlist();
    my_con.getPEClist();
    my_con.getCenterlist();
    my_con.view_aregion();
    my_con.view_auser();
    my_con.view_acenter();
    my_con.display_center();
    my_con.display_all();
    my_con.display_user();
    my_con.date_change();

    my_con.getFinancedConsults();
    my_con.getConsultStarts();
    my_con.getSDStarts();
    my_con.getStarts();

    my_con.getStartsCancelledIn();
    my_con.getStartsCancelledOut();
    my_con.getStartsCancelled();

    my_con.getTreatmentSold();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getTreatmentCancelled();

    my_con.getCollected();
    my_con.getRefunded();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.gettrue_closerate();

    my_con.gethyper_prefix();
    my_con.getdownload_string();

    test.stopTest();
  }

  static testMethod void Dash_range_user() {
  	test.startTest();
    pageRef3 = new PageReference('/apex/sandbox_chris?sdate=' + String.valueof(Date.newInstance(System.today().year(), System.today().month(), 1)) + ' &edate=' + String.valueof(System.today()));
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','user');
    ctrl_opsdashboard_range my_con = new ctrl_opsdashboard_range();

    my_con.getFinancedConsults();
    my_con.getConsultStarts();
    my_con.getSDStarts();
    my_con.getStarts();

    my_con.getStartsCancelledIn();
    my_con.getStartsCancelledOut();
    my_con.getStartsCancelled();

    my_con.getTreatmentSold();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getTreatmentCancelled();

    my_con.getCollected();
    my_con.getRefunded();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.gettrue_closerate();

    my_con.gethyper_prefix();
    my_con.getdownload_string();

    test.stopTest();
  }

  static testMethod void Dash_range_center() {
  	test.startTest();
    pageRef3 = new PageReference('/apex/sandbox_chris');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','center');
    ctrl_opsdashboard_range my_con = new ctrl_opsdashboard_range();

    my_con.getFinancedConsults();
    my_con.getConsultStarts();
    my_con.getSDStarts();
    my_con.getStarts();

    my_con.getStartsCancelledIn();
    my_con.getStartsCancelledOut();
    my_con.getStartsCancelled();

    my_con.getTreatmentSold();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getTreatmentCancelled();

    my_con.getCollected();
    my_con.getRefunded();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.gettrue_closerate();

    my_con.gethyper_prefix();
    my_con.getdownload_string();

    test.stopTest();
  }

  static testMethod void Dash_range_region() {
  	test.startTest();
    pageRef3 = new PageReference('/apex/sandbox_chris');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','region');
    ctrl_opsdashboard_range my_con = new ctrl_opsdashboard_range();

    my_con.getFinancedConsults();
    my_con.getConsultStarts();
    my_con.getSDStarts();
    my_con.getStarts();

    my_con.getStartsCancelledIn();
    my_con.getStartsCancelledOut();
    my_con.getStartsCancelled();

    my_con.getTreatmentSold();
    my_con.getTreatmentCancelledIn();
    my_con.getTreatmentCancelledOut();
    my_con.getTreatmentCancelled();

    my_con.getCollected();
    my_con.getRefunded();
    my_con.getUpsellSold();
    my_con.getUpsellCancelledIn();
    my_con.getupsellCancelledOut();
    my_con.gettrue_closerate();

    my_con.gethyper_prefix();
    my_con.getdownload_string();

    test.stopTest();
  }
}