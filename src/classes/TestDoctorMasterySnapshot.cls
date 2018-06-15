/**
 * Test class for DoctorMasterSnapshot
 */
@isTest
private class TestDoctorMasterySnapshot {
	
	@testSetup static void init() {
		// Market -----------------------------------------------------------------------------------------------
		Market__c market = new Market__c(Name='TestMarket001', Market_Abbreviation__c='DEN', Region__c='West');
		insert market;
									
		// Center -----------------------------------------------------------------------------------------------
		Center_Information__c center = new Center_Information__c(Name='TestCenter005',
																 Active__c 							  = true,
																 Battlegroup_Stars__c				  = 4,
																 Ideal_Week_Certification_Date__c     = date.parse('03/02/2018'),
																 Leadership_Impact_Assessment_Date__c = date.parse('03/01/2010'),
																 Market__c 							  = market.Id,
																 latlong__Latitude__s  				  = 0.0,
																 latlong__Longitude__s 				  = 1.0);
		insert center;
		
		// User --------------------------------------------------------------------------------------------------
		/**
			User does not exist on the SandBox object.
		**/
		User user = new User(IsActive = true, UserName = 'testuser008@test.com', LastName = 'Turkey', 
							 Email = 'testuser008@test.com', Alias = 'merp',
							 TimeZoneSidKey = 'America/Denver', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
							 LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId());
		insert user;
		
		// CC Doctor
		List<ClearChoice_Doctor__c> doctorList = new List<ClearChoice_Doctor__c>();
		
		doctorList.add(new ClearChoice_Doctor__c(Active__c = true, Battlegroup_Stars__c = 3, CCE_Credits__c = 5, Center_Information__c = center.Id, Email_Address__c = 'youngdoc001@email.com',
			Employee_Start_Date__c = Date.parse('03/25/2099'), Practice_Leadership_Completed__c = false, Practice_Mastery_Completed__c = false,
			Practice_Mastery_2_Completed__c = false, Total_Arches_Delivered__c = 3, doctor_type__c = 'Prosthodontist'));
		
		doctorList.add(new ClearChoice_Doctor__c(Active__c = true, Battlegroup_Stars__c = 4, CCE_Credits__c = 8, Center_Information__c = center.Id, Email_Address__c = 'olddoc002@email.com',
			Employee_Start_Date__c = Date.parse('03/25/2010'), Practice_Leadership_Completed__c = true, Practice_Mastery_Completed__c = true,
			Practice_Mastery_2_Completed__c = true, Total_Arches_Delivered__c = 10, doctor_type__c = 'Prosthodontist'));

		insert doctorList;
		
		// Account -----------------------------------------------------------------------------------------------
		Account account = new Account(FirstName = 'Harry', LastName = 'Henderson', Center__c = center.Id);
		insert account;
		
		// Opportunity -------------------------------------------------------------------------------------------
		List<Opportunity> oppsList = new List<Opportunity>();
		oppsList.add(new Opportunity(AccountId = account.Id, Net_Promoter_Score__c = 10, CloseDate = System.today(), Name = 'promoter001', StageName = 'Bruce Lee', Center_Information__c = center.Id));
		oppsList.add(new Opportunity(AccountId = account.Id, Net_Promoter_Score__c = 7, CloseDate = System.today(), Name = 'passive001', StageName = 'Chuck Norris', Center_Information__c = center.Id));
		oppsList.add(new Opportunity(AccountId = account.Id, Net_Promoter_Score__c = 0, CloseDate = System.today(), Name = 'detractor001', StageName = 'Jean Claude', Center_Information__c = center.Id));
		insert oppsList;
	}
	
	 static testMethod void test_Driver() {
     	Test.startTest();
        //init();
        Integer idealWeekCerts        = 0;
        Integer leadershipImpactCerts = 0;
        
        DoctorMasterySnapshotDriver driver = new DoctorMasterySnapshotDriver();
        driver.drive();

		Doctor_Mastery_Center_Snapshot__c[] centerSnap = [SELECT Ideal_Week_Certified__c, Leadership_Impact_Assessment__c FROM Doctor_Mastery_Center_Snapshot__c];
		
        for(Doctor_Mastery_Center_Snapshot__c snap : centerSnap){
        	if(snap.Ideal_Week_Certified__c == true){
        		idealWeekCerts++;
        	}
        	if(snap.Leadership_Impact_Assessment__c == true){
        		leadershipImpactCerts++;
        	}
        }
        
        System.assertEquals(1, idealWeekCerts);
        System.assertEquals(1, leadershipImpactCerts);
        
        Test.stopTest();
	 }
	
	  static testMethod void test_HasTenureYears(){
	 	Test.startTest();
	 	//init();
	 	Date d = System.today().addYears(-1);
	 	DoctorMasterySnapshot dms = new DoctorMasterySnapshot();
	 	List<ClearChoice_Doctor__c> doctorList = [SELECT Id,Employee_Start_Date__c FROM ClearChoice_Doctor__c doctorList WHERE Employee_Start_Date__c < :d];
	 	System.debug('test_HasTenureYears ' + dms.calculateTenure(doctorList[0].Employee_Start_Date__c));
	 	System.assert(dms.calculateTenure(doctorList[0].Employee_Start_Date__c) > 0);
	 	Test.stopTest();
	 }
	 
	  static testMethod void test_HasNoTenureYears(){
	 	Test.startTest();
	 	//init();
	 	Date d = System.today().addDays(-364);
	 	DoctorMasterySnapshot dms = new DoctorMasterySnapshot();
	 	List<ClearChoice_Doctor__c> doctorList = [SELECT Id,Employee_Start_Date__c FROM ClearChoice_Doctor__c doctorList WHERE Employee_Start_Date__c >= :d];
	 	System.debug('test_HasNoTenureYears ' + dms.calculateTenure(doctorList[0].Employee_Start_Date__c));
	 	System.assertEquals(0, dms.calculateTenure(doctorList[0].Employee_Start_Date__c));
	 	Test.stopTest();
	 }
	 
    static testmethod void test_cron_snapshot() {  	    
      test.startTest();
      //init();    
      System.schedule('Test Take Snapshot', '0 0 1 * * ?', new run_dr_mastery_snap());             
      Test.stopTest();
            
    }
}