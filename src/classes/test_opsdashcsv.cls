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
private class test_opsdashcsv {
	static PageReference pageref;
	static PageReference pageRef2;
	static PageReference pageRef3;

	static ctrl_OpsCSV controller;

  static testMethod void Download_test1() {
  	test.startTest();
    pageref = new PageReference('/apex/OpsDashcsv');
    Test.setCurrentPage(pageRef);
    pageRef2 = new PageReference('/apex/OpsDashcsv?format=1&action=center');
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=1&action=all');

    controller = new ctrl_OpsCSV();
    controller.getfile_header();
    controller.getfilename();
    controller.getcsvout();

    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('action','center');
    ApexPages.currentPage().getParameters().put('format','1');
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    ApexPages.currentPage().getParameters().put('format','1');
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=2&action=all');
    Test.setCurrentPage(pageRef3);
    ApexPages.currentPage().getParameters().put('action','all');
    ApexPages.currentPage().getParameters().put('format','2');
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=3&action=all');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=4&action=all');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    test.stopTest();
  }

  static testMethod void Download_test2() {
    test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=6&action=all&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=6&action=center&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=6&action=user&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=7&action=all&interval=3');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=7&action=center&interval=3');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=7&action=user&interval=3');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=24&action=all&interval=3');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
  }

  static testMethod void Download_pendingstarts() {
  	test.startTest();

  	pageRef3 = new PageReference('/apex/OpsDashcsv?format=20&action=all&interval=1');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    Date sdate = Date.newInstance(System.today().year(), System.today().month(), 1);
  	Date edate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=20&action=user&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=21&action=user&interval=1');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=22&action=region&interval=1&aregion=Northeast');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

        PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(user__c = Userinfo.getuserid(), snapshot_date__c = System.today().adddays(-1), True_Close_Rate__c = 10.0,
      True_Close_Rate_Regional_Rank__c = 8, True_Close_Rate_National_Rank__c = 4, Sales_Region__c = 'Unknown',
      Rainmaker_Regional_Rank__c = 8, Rainmaker_National_Rank__c = 4, National_Overall_Rank__c = 12, Learning_Activity_Regional_Rank__c = 12, Learning_Activity_Num__c = 4,
      Learning_Activity_National_Rank__c = 12, Callbacks_Num__c = 13, Callback_Regional_Rank__c = 20, Callback_National_Rank__c = 30, Avg_Rainmaker_Score__c = 64.01);
      insert prs;

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=23');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

  	test.stopTest();
  }

  static testMethod void Download_test4() {
    test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=8&action=all&interval=4');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=8&action=user&interval=4');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=8&action=center&interval=4');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=9&action=all&interval=2');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=9&action=center&interval=2');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=10&action=user&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    test.stopTest();
  }

  static testMethod void Download_test3() {
  	test.startTest();
  	Center_Information__c test_center = [select id from Center_Information__c limit 1];
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=11&action=center&ascenter=' + test_center.id + '&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=11&action=user&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=11&action=all&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    test.stopTest();
  }

  static testMethod void Download_test6() {
    test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=15&action=all&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=15&action=center&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=15&action=user&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=16&action=all&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=17&action=center&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=17&action=user&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    test.stopTest();
	}

  static testMethod void Download_test7() {
    test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=18&rmonth=3&ryear=2012');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    test.stopTest();
  }

  static testMethod void Download_test9() {
  	test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=18&rmonth=9&ryear=2011');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=12');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=13');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=14');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    test.stopTest();
  }

  static testMethod void Download_test5() {
    test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=19&rmonth=4&ryear=2012');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    test.stopTest();
  }

  static testMethod void Download_test8() {
    test.startTest();
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=19&rmonth=12&ryear=2011');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();
    test.stopTest();
  }

  static testmethod void Download_test10() {
  	test.startTest();
  	Date sdate = Date.newInstance(System.today().year(), System.today().month(), 1);
  	Date edate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
    pageRef3 = new PageReference('/apex/OpsDashcsv?format=5&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=6&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=7&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=8&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=9&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=10&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=15&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=16&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=17&sdate=' + sdate + '&edate=' + edate + '&interval=6');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    test.stopTest();
  }

  static testmethod void Download_noncomission() {
  	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
  	Center_Information__c  test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', street_2__c = 'unit 103', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	insert test_center;
  	Private_Practice_Patient__c pp = new Private_Practice_Patient__c(practice_id__c = 'Test269',center__c = test_center.id, first_name__c = 'test', last_name__c = 'patient', street_address__c = '23125 E Testing Street, Unit 102', city__c = 'Denver', state__c = 'Colorado', postal_code__c = '12561');
	insert pp;
	List<Private_Practice_Payment__c> ppay_list = new List<Private_Practice_Payment__c>{new Private_Practice_Payment__c(payment_date__c = System.today(), payment_amount__c = 34.00, payment_status__c = 'Collected', payment_type__c = 'Cash', center_location__c = 'Test Center',private_practice_patient__c = pp.id),
	  new Private_Practice_Payment__c(payment_date__c = System.today().addmonths(-1), payment_amount__c = 20.00,payment_status__c = 'Collected', center_location__c = 'Test Center',private_practice_patient__c = pp.id)};
	insert ppay_list;
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish');
	insert test_account;
    List<Opportunity> test_ops = new List<Opportunity>{new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op',
	    StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1', prosth_exam_paid_date__c = System.today()),
	    new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Refund',
	    StageName = 'Cancelled Not Rescheduled' , Treatment_Amount__c = 22000.00, Cancel_Date__c = System.today(), Closedate = System.today(), cancel_reason__c = 'Testing', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2', prosth_exam_paid_date__c = System.today())};
	insert test_ops;
	List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 20.00),new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[0].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 8000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = test_ops[1].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 5000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = test_ops[1].id, finance_fee__c = 20.00)
	   };
	insert test_payments;
	test.startTest();

	pageRef3 = new PageReference('/apex/OpsDashcsv?format=25&interval=1&action=all');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

	pageRef3 = new PageReference('/apex/OpsDashcsv?format=25&interval=1&action=user');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=25&interval=1&action=center');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=25&interval=1&action=region');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=5&interval=5&action=all');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=5&action=all&interval=1&tfilter=1');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=5&action=all&interval=1&tfilter=2');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=5&action=all&interval=5');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=6&action=all&interval=1');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

    pageRef3 = new PageReference('/apex/OpsDashcsv?format=8&action=all&interval=1');
    Test.setCurrentPage(pageRef3);
    controller = new ctrl_OpsCSV();
    controller.getcsvout();

  	test.stopTest();
  }

}