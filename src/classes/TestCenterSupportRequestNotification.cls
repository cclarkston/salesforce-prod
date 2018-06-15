@isTest
private class TestCenterSupportRequestNotification {

	@TestSetup
	static void setup() {
		String validRequestType = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];

		Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

		User user = new User(FirstName = 'Test',
				LastName = 'CenterSupportUser',
				Alias = 'alias',
				UserName = 'center-support-user@clearchoice.com',
				ProfileId = standardProfile.Id,
				Email = 'donotreply@clearchoice.com',
				TimeZoneSidKey = 'America/Los_Angeles',
				EmailEncodingKey = 'UTF-8',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US');
		insert user;

		Sales_Region__c region = new Sales_Region__c(Active__c = true,
				RBD__c = user.Id);
		insert region;

		Center_Information__c center = new Center_Information__c(Name = 'Test Center',
				Region__c = region.Id,
				latlong__Longitude__s = 30,
				latlong__Latitude__s = 30);
		insert center;

		Center_Support_Request__c request = new Center_Support_Request__c(Type__c = validRequestType,
				Center_Information__c = center.Id,
				Summary__c = 'Test Summary',
				Need_by_date__c = Date.today(),
				Status__c = 'Closed',
				Legal_Compliance__c = 'No');
		insert request;

		Note note = new note(parentId = request.Id,
				Title = 'Test Title',
				Body = 'test body',
				isPrivate = false);
		insert note;
	}

	static testMethod void sendRequestCreatedEmail() {
		String validRequestType = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
		Center_Information__c center = [SELECT Id
		                                FROM Center_Information__c
		                                LIMIT 1
		                                ];

		Center_Support_Request__c request = new Center_Support_Request__c(Type__c = validRequestType,
				Center_Information__c = center.Id,
				Summary__c = 'Test Summary',
				Need_by_date__c = Date.today(),
				Status__c = 'Closed',
				Legal_Compliance__c = 'No');
		insert request;

		String requestId = request.Id;
		String requestName = request.Name;

		Test.startTest();
		CenterSupportRequestNotification.sendRequestCreatedNotification(requestId, requestName);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations, 'An email should be sent');
	}

	static testMethod void sendRequestClosedEmail() {
		User approver = [SELECT Id, FirstName, Email
		                 FROM User
		                 WHERE LastName = 'CenterSupportUser'];

		String approverName = approver.FirstName;
		String[] approverEmails = new String[] { approver.Email };
		String approverId = approver.Id;

		Center_Support_Request__c[] request = [SELECT Id, Name
		                                       FROM Center_Support_Request__c
		                                       WHERE Approver__c = :approverId];

		String requestId = request[0].Id;
		String requestName = request[0].Name;

		Test.startTest();
		CenterSupportRequestNotification.sendRequestClosedNotification(approverName, approverEmails, requestId, requestName);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations, 'An email should be sent');
	}

	static testMethod void sendApprovalReminder() {
		Center_Support_Request__c[] requests = [SELECT Id, Name,
		                                        Approval_Reminder_Count__c,
                                            Submitted_Date_Time__c,
		                                        Center_Information__r.Region__r.RBD__r.FirstName,
		                                        Center_Information__r.Region__r.RBD__r.Email
		                                        FROM Center_Support_Request__c];

		Test.startTest();
    CenterSupportRequestNotification.sendApprovalReminder(requests);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations, 'An email should be sent');
	}

	static testMethod void sendSubmitReminder() {
		Datetime target = Datetime.now().addDays(-2);
		Datetime createdDate = Datetime.now().addDays(-4);

		Id requestId = [SELECT Id FROM Center_Support_Request__c LIMIT 1].Id;
		Test.setCreatedDate(requestId, createdDate);

		Center_Support_Request__c[] requests = [SELECT Id, CreatedBy.FirstName, CreatedBy.Email,
		                                        Submit_Reminder_Count__c,
		                                        CreatedDate
		                                        FROM Center_Support_Request__c
		                                        WHERE Submitted_for_Approval__c = false
		                                        AND createdDate < :target];

		Test.startTest();
		CenterSupportRequestNotification.sendSubmitReminder(requests);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations, 'An email should be sent');
	}

	static testMethod void sendWeeklyNotes() {
		Id profileId = [SELECT Id FROM Profile WHERE Name LIKE '%RBD'].Id;
		String emailBody = '';

		String[] emailAddresses = new String[]{'donotreply@clearchoice.com'};

		Center_Support_Request__c[] requests = [SELECT Id, Name,
		                                        (SELECT Id, Title, Body, OwnerId, ParentId,
		                                        		LastModifiedDate, CreatedById, CreatedBy.Name
		                                        		FROM Notes WHERE LastModifiedDate > LAST_MONTH)
		                                        FROM Center_Support_Request__c];

		for(Center_Support_Request__c request : requests) {
			if(request.Notes.size() != 0) {
				emailBody += '<p><u> Title</u>: ';
				emailBody += request.Notes[0].Title;
				emailBody += '<p><u> From</u>: ';
				emailBody += request.Notes[0].CreatedBy.Name;
				emailBody += '<p><u>Notes</u>: ';
				emailBody += '<p>';
				emailBody += request.Notes[0].Body;
				emailBody += '</br></br><hr></br></br>';
			}
		}

		Test.startTest();
		CenterSupportRequestNotification.sendWeeklyNotes(emailAddresses, emailBody);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations, 'An email should be sent');
	}
}