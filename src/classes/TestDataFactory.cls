/*
05/14/2018  CC  Inital commit
*/

@isTest
public with sharing class TestDataFactory {
	public TestDataFactory() {
	}

	public static Sales_Region__c  CreateTestRegion() {
    	Sales_Region__c region = new Sales_Region__c(Name = 'Test Region',
                                                 Active__c = true,
                                                 RBD__c = UserInfo.getUserId()
                                               );
		return region;									   
	}

	public static Center_Information__c CreateTestCenter() {
		Sales_Region__c region = CreateTestRegion();
		insert region;
    	Center_Information__c center = new Center_Information__c(Name = 'Test Center',
                                                             	Region__c = region.Id,
																Latlong__Longitude__s = 30,
																Latlong__Latitude__s = 30,
																DoseSpot_Clinic_ID__c = '596',
																DoseSpot_Clinic_Key__c = 'Dt5K6ktpZWYMFkK6tWJVhGdyR7KsjdYP'
															);
     	return center;
  	}

	public static Account CreateTestAccount() {
		Center_Information__c center = CreateTestCenter();
		insert center;
		Account account = new Account(FirstName = 'Firstname',
									LastName = 'Lastname',
									BillingStreet = '123 Main St',
									BillingCity = 'Denver',
									BillingState = 'Colorado',
									Center__c = center.Id
									);
     return account;
  }
  	
	public static List<Lead> CreateTestLeads() {
		Map<String, String> names = new Map<String, String>{
										'Michael' => 'Smith',
										'Miles' => 'Jones',
										'Kevin' => 'Michaelson',
										'Michelle' => 'Gonzalez',
										'Lewis' => 'Chen',
										'Zach' => 'Roberts',
										'Tyranosaurus' => 'Rex',
										'Zi' => 'Chang',
										'Sarah' => 'Adams',
										'Charles' => 'Seib ert',
										'Amanda' => 'Fox'
									};

		List<lead> leads = new List<lead>();
		for(String key : names.keySet()) {
			Lead lead = new Lead(FirstName = key,
								LastName = names.get(key),
								Street = '123 Main St',
								City = 'Denver',
								State = 'Colorado'
							);
			leads.add(lead);
		}
		return leads;
	}	

	public static Lead CreateTestLead() {
		Lead lead = new Lead();
		lead.lastName = 'Smith';
		lead.firstName = 'James';	
		lead.Call_Center_Agent__c = UserInfo.getUserId();	
		return lead;
	}	

	//SMS Related 
	public static void CreateSendIds() {
		//Create senderids
        List<smagicinteract__SMS_SenderId__c> senderIds = new List<smagicinteract__SMS_SenderId__c>();
        senderIds.add(new smagicinteract__SMS_SenderId__c(smagicinteract__senderId__c = '1'));
        senderIds.add(new smagicinteract__SMS_SenderId__c(smagicinteract__senderId__c = '2'));
        insert senderIds;
        smagicinteract__SMS_SenderId__c senderId = [SELECT Id, smagicinteract__senderId__c 
                                                        FROM smagicinteract__SMS_SenderId__c
                                                        WHERE smagicinteract__senderId__c = '1'
                                                        LIMIT 1];
		//Create   default senderid
        smagicinteract__SenderId_Profile_Map__c senderIdProfileMap = new smagicinteract__SenderId_Profile_Map__c();
        senderIdProfileMap.smagicinteract__SenderId_Lookup__c = senderId.Id;
        senderIdProfileMap.smagicinteract__Profile_Id__c = userinfo.getProfileId();
        insert senderIdProfileMap;
	}
									
}