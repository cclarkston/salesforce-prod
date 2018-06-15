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
private class TestRunLogUpload {
   
  private static void init() {
  	Market__c m = new Market__c(Name = 'Test Market');
  	insert m;
		Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center; 
    Profile p = [select id from Profile where name = 'System Administrator'];		
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
		RecordType rt = [select id,name from RecordType where sobjecttype = 'Campaign'  and name = 'Generic Campaign' limit 1];		
    List<Campaign> clist = new List<Campaign> {new Campaign(name='Test Campaign 1', isci__c = 'ISCI001', Type = 'TV', startdate = system.today().addDays(-7), recordtypeid = rt.id),
      new Campaign(name='Test Campaign 2', isci__c = 'ISCI002', Type = 'TV', startdate = system.today().addDays(-7), recordtypeid = rt.id),
      new Campaign(name='Missing ISCI', isci__c = '', Market__c = m.id, creative_name__c = 'Deanna', media_outlet_vendor__c = 'MSNBC', recordtypeid = rt.id),
      new Campaign(name='Missing ISCI Fail', isci__c = 'HASISCI', Market__c = m.id, creative_name__c = 'Deanna2', media_outlet_vendor__c = 'MSNBC', recordtypeid = rt.id)
      };
    insert clist;
  }

  static testMethod void RunLogTest() {
  	init();
    test.startTest();
    
    Pagereference pageref = new PageReference('/apex/run_log_upload');
    Test.setCurrentPage(pageRef);      
    ctl_run_log_csv_up rlog = new ctl_run_log_csv_up();
    
    String mycontents = 'est,market,station,bc_day,bc_milltime,bc_week_of,den_day,den_milltime,lth,isci,net_cost\n';
    mycontents += 'nt12,National Cable,MSNBC,' + String.valueof(System.today()) + ',956,' + String.valueof(System.today()) + ',' + String.valueof(System.today()) + ',' + String.valueof(System.today()) + ',060,ISCI001,PAID PROGRAM\n';
    mycontents += ',,,,,,,,,,\n';
    mycontents += 'nt12,BALTIMORE,,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
    mycontents += 'nt12,DALLAS-FT. WORTH,MSNBC,A/B/C,0,A/B/C,,A/B/C,060,ISCIUNKNOWN,Paid Program\n';
    mycontents += 'nt12,MIAMI-FT. LAUDERDALE,MSNBC,,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
    mycontents += 'nt12,MINNEAPOLIS-ST. PAUL,MSNBC,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
    mycontents += 'nt12,PORTLAND OR,MSNBC,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
    mycontents += 'nt12,SACRAMENTO-STOCKTON,MSNBC,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
    mycontents += 'nt12,SAN FRANCISCO-OAKLAND-SAN JOSE,MSNBC,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
    mycontents += 'nt12,SEATTLE-TACOMA,MSNBC,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';  
    mycontents += 'nt12,Test Market,MSNBC,A/B/C,0,A/B/C,A/B/C,A/B/C,060,ISCI001,Paid Program\n';
      
    
    rlog.contentfile = Blob.valueOf(mycontents);
    
    rlog.ReadFile();
    rlog.ignore_warnings = true;
    rlog.ReadFile();
    rlog.ignore_warnings = false;
    
    for(Integer cnt=1;cnt<120;cnt++) {
    	mycontents += 'nt12,National Cable,MSNBC,10/7/2013  12:00:00 AM,956,10/7/2013  12:00:00 AM,10/7/2013  12:00:00 AM,1/25/1902  12:00:00 AM,060,ISCI001,PAID PROGRAM\n';
    }
    rlog.contentfile = Blob.valueOf(mycontents);
    
    rlog.ReadFile();
    
    mycontents = 'file to short';
    rlog.contentFile = Blob.valueOf(mycontents);
    rlog.ReadFile();
        
    test.stopTest();
  }
  
  static testMethod void RunLogISCIUPTest() {
  	init();
    test.startTest();
    
    Pagereference pageref = new PageReference('/apex/run_log_upload');
    Test.setCurrentPage(pageRef);      
    ctl_run_log_csv_up rlog = new ctl_run_log_csv_up();
    
    String mycontents = 'market,station,creative,isci\n';
    mycontents += 'Test Market,MSNBC,Deanna,ISCI0004\n';
    mycontents += 'Test Market,MSNBC,Deanna2,ISCI0005\n';
      
    
    rlog.isci_contentFile = Blob.valueOf(mycontents);
    
    rlog.Upload_ISCI();    
    
    for(Integer cnt=1;cnt<120;cnt++) {
    	mycontents += 'nt12,National Cable,MSNBC,10/7/2013  12:00:00 AM,956,10/7/2013  12:00:00 AM,10/7/2013  12:00:00 AM,1/25/1902  12:00:00 AM,060,ISCI001,PAID PROGRAM\n';
    }
    rlog.isci_contentFile = Blob.valueOf(mycontents);
       
    rlog.Upload_ISCI();
    
    mycontents = 'file to short';
    rlog.isci_contentFile = Blob.valueOf(mycontents);
    rlog.Upload_ISCI();        
        
    test.stopTest();
  }
  
  static testMethod void RunLogWebCostsTest() {
  	init();
    test.startTest();
    
    Pagereference pageref = new PageReference('/apex/run_log_upload');
    Test.setCurrentPage(pageRef);      
    ctl_run_log_csv_up rlog = new ctl_run_log_csv_up();
    
    String mycontents = 'name,date,day of week,engine,spend,impressions,clicks,ctr\n';
    mycontents += 'Clearchoice,' + String.valueof(System.today()) + ',Monday,Bing,940.86,3200,300,.10\n';
    mycontents += 'Clearchoice,' + String.valueof(System.today()) + ',Monday,Google,940.86,3200,300,.10\n';
    mycontents += 'Clearchoice,A/B/C,Monday,Google,940.86,3200,300,.10\n';
    mycontents += 'Clearchoice,' + String.valueof(System.today()) + ',Monday,Google,,3200,300,.10\n';
    mycontents += 'Clearchoice,' + String.valueof(System.today()) + ',Monday,Google,940.86,,300,.10\n';
    mycontents += 'Clearchoice,' + String.valueof(System.today()) + ',Monday,Google,940.86,3200,,.10\n';
    mycontents += ',,,,,,,,,,\n';         
    
    RecordType rt = [select id,name from RecordType where sobjecttype = 'Campaign'  and name = 'Generic Campaign' limit 1];
    Campaign Bing = new Campaign(name='Bing SEM', isci__c = '', Type = 'Web-SEM', startdate = system.today().addDays(-7), media_outlet_vendor__c = 'Bing', recordtypeid = rt.id);
    Campaign Google = new Campaign(name='Google SEM', isci__c = '', Type = 'Web-SEM', startdate = system.today().addDays(-7), media_outlet_vendor__c = 'Google', recordtypeid = rt.id);
    
    rlog.wcosts_contentfile = Blob.valueOf(mycontents);
    
    rlog.upload_web_costs();
    insert bing;
    rlog.upload_web_costs();
    insert google;
    rlog.upload_web_costs();
    
    mycontents = 'file to short';
    rlog.wcosts_contentFile = Blob.valueOf(mycontents);
    rlog.upload_web_costs();
        
    test.stopTest();
  }
}