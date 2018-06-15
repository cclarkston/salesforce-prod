@isTest
private class TestCenterSupportRequestSubmitReminder {
	private static String CRON_EXP = '0 0 6 * * ?';

	@testSetup
	static void setup() {
		ID profileId = [SELECT ID FROM Profile WHERE Name = 'System Administrator'].ID;
		User user = new User(Username = 'csrtest@email.com', LastName = 'User',
				Email = 'csrtest@email.com', alias = 'csr',
				CommunityNickname = 'csruser', TimeZoneSidKey = 'America/Denver',
				EmailEncodingKey = 'UTF-8', ProfileId = profileId,
				LanguageLocaleKey = 'en_US', LocaleSidKey='en_US');
		insert user;

		String validRequestType = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
		Date needByDate = Date.today();

		List<Center_Support_Request__c> requests = new List<Center_Support_Request__c>();

		Sales_Region__c region = new Sales_Region__c(Name = 'Test Region', RBD__c = UserInfo.getUserId());
		insert region;

		Center_Information__c center = new Center_Information__c(Name = 'Test Center',
				Region__c = region.Id,
				latlong__Longitude__s = 30,
				latlong__Latitude__s = 30);
		insert center;

		System.runAs(user){
			for(Integer i=0; i<10; i++) {

				Center_Support_Request__c request = new Center_Support_Request__c(
						Center_Information__c = center.Id,
						Type__c = validRequestType,
						Summary__c = 'Test Summary',
						Need_by_date__c = needByDate,
						Submit_Reminder_Count__c = 1,
						Status__c = 'Open',
						Legal_Compliance__c = 'No'
						);
				requests.add(request);
			}
			insert requests;
		}
	}


	static testMethod void centerSupportRequestSubmitReminderHandlesNoRequests() {
		Test.StartTest();
		String jobId = System.schedule('Center Support Request Submit Reminder',
				CRON_EXP,
				new CenterSupportRequestSubmitReminder());
		Test.StopTest();

		Datetime target = Datetime.now().addDays(-2);

		Center_Support_Request__c[] requests = [SELECT Id
		                                        FROM Center_Support_Request__c
		                                        WHERE Submitted_for_Approval__c = false
		                                        AND createdDate < :target];

		System.assertEquals(0, requests.size());
	}


	static testMethod void centerSupportRequestSubmitReminder() {
		Datetime createdDate = Datetime.now().addDays(-2); // 

		Id requestId = [SELECT Id FROM Center_Support_Request__c LIMIT 1].Id;
		Test.setCreatedDate(requestId, createdDate);

		Test.StartTest();
		String jobId = System.schedule('Center Support Request Submit Reminder',
				CRON_EXP,
				new CenterSupportRequestSubmitReminder());
		Test.StopTest();

		Center_Support_Request__c request = [SELECT Submit_Reminder_Count__c
		                                     FROM Center_Support_Request__c
		                                     WHERE Id = :requestId];

		System.assertEquals(2, request.Submit_Reminder_Count__c);
	}


	static testMethod void centerSupportRequestSubmitReminderHandlesNoManagerEmail() {
		Datetime createdDate = Datetime.now().addDays(-4);

		Id requestId = [SELECT Id FROM Center_Support_Request__c LIMIT 1].Id;
		Test.setCreatedDate(requestId, createdDate);

		User user = [SELECT Email
		             FROM User
		             WHERE Email = 'csrtest@email.com'];
		user.Email = 'bademail@email.com';
		update user;

		Test.StartTest();
		String jobId = System.schedule('Center Support Request Submit Reminder',
				CRON_EXP,
				new CenterSupportRequestSubmitReminder());
		Test.StopTest();

		Center_Support_Request__c request = [SELECT Submit_Reminder_Count__c
		                                     FROM Center_Support_Request__c
		                                     WHERE Id = :requestId];

		System.assertEquals(2, request.Submit_Reminder_Count__c);
	}
}