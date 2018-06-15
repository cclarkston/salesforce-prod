// KS 04-20-2017 CenterSupportRequest.trigger - 100%

@isTest

private class Test_trigger_CenterSupportRequest {
	static User test_user = [SELECT Name FROM User WHERE ID = :UserInfo.getUserId()];

	private static void init() {
		System.assert(test_user.Name != null);

		String validRequestType = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];

		ID test_profile_id = [SELECT ID FROM Profile WHERE Name = 'System Administrator'].ID;

		User test_RBD = new User(Username = 'rbd@clearchoice.com', LastName = 'RBD', Email = 'rbd@clearchoice.com', alias = 'rbd', CommunityNickname = 'rbd', TimeZoneSidKey = 'America/Denver', EmailEncodingKey = 'UTF-8', ProfileId = test_profile_id, LanguageLocaleKey = 'en_US', LocaleSidKey='en_US');

		User test_traveler = new User(Username = 'traveler@clearchoice.com', LastName = 'Traveler', Email = 'traveler@clearchoice.com', alias = 'traveler', CommunityNickname = 'traveler', TimeZoneSidKey = 'America/Denver', EmailEncodingKey = 'UTF-8', ProfileId = test_profile_id, LanguageLocaleKey = 'en_US', LocaleSidKey='en_US');

		User new_traveler = new User(Username = 'newtraveler@clearchoice.com', LastName = 'NewTraveler', Email = 'newtraveler@clearchoice.com', alias = 'newtrave', CommunityNickname = 'newtraveler', TimeZoneSidKey = 'America/Denver', EmailEncodingKey = 'UTF-8', ProfileId = test_profile_id, LanguageLocaleKey = 'en_US', LocaleSidKey='en_US');

		insert new User[]{test_RBD, test_traveler, new_traveler};

		Sales_Region__c test_region =  new Sales_Region__c(Name = 'Test Region', RBD__c = test_RBD.ID);
    insert test_region;

		insert new Center_Information__c(Name = 'Test Center', Region__c = test_region.ID, latlong__Longitude__s = 30, latlong__Latitude__s = 30);

	}

			private static Center_Support_Request__c the_one_request() {
				Center_Support_Request__c[] requests = [SELECT ID, OwnerId, Center_Information__c, Calendar_Event_ID__c, Travel_Departure__c, Travel_Return__c FROM Center_Support_Request__c];
				System.assertEquals(1, requests.size());
				return requests[0];
			}

	static testMethod void test_a_new_event_record_is_created_correctly_when_travel_info_is_included_in_a_new_record() {
		init();
		Center_Information__c test_center = [SELECT ID FROM Center_Information__c WHERE Name = 'Test Center'];
		User traveler = [SELECT ID, Name FROM User WHERE LastName = 'Traveler'];
		String valid_request_type = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
		Center_Support_Request__c request;

		System.assertEquals(0, [SELECT count() FROM Center_Support_Request__c]);
		System.assertEquals(0, [SELECT count() FROM Event]);

		System.runAs(test_user) {
			Test.startTest();
				request = new Center_Support_Request__c(Center_Information__c = test_center.ID,
																								Type__c               = valid_request_type,
                            										Status__c             = 'Closed',
																								Summary__c            = 'Test Summary',
																								Need_By_Date__c       = Date.today(),
																								Traveler__c           = traveler.ID,
																								Travel_Departure__c   = Date.today(),
																								Travel_Return__c      = Date.today(),
																								Legal_Compliance__c   = 'No');
				insert request;
			Test.stopTest();
		}

		System.assertEquals(1, [SELECT count() FROM Center_Support_Request__c]);
		System.assertEquals(1, [SELECT count() FROM Event]);

		request = the_one_request();
		Event test_event = [SELECT ID, OwnerId, Subject, WhatId, IsAllDayEvent, IsReminderSet, StartDateTime, EndDateTime FROM Event LIMIT 1];

		// '023' is the prefix of the hidden Public Calendar object. I'm choosing not to test for an exact ID... only that it was given one for the appropriate object.
		System.assertEquals('023', String.valueOf(test_event.OwnerId).substring(0,3));
		System.assert(test_event.Subject != null);
		System.assertEquals(traveler.Name, test_event.Subject);
		System.assertEquals(request.Center_Information__c, test_event.WhatId);
		System.assertEquals(true,  test_event.IsAllDayEvent);
		System.assertEquals(false, test_event.IsReminderSet);
		System.assertEquals(request.Travel_Departure__c, test_event.StartDateTime.dateGMT());
		System.assertEquals(request.Travel_Return__c,    test_event.EndDateTime.dateGMT());

		System.assertEquals(test_event.ID, request.Calendar_Event_ID__c);
	}

	static testMethod void test_a_new_event_record_is_created_correctly_when_travel_info_is_added_to_an_existing_record() {
		init();
		Center_Information__c test_center = [SELECT ID FROM Center_Information__c WHERE Name = 'Test Center'];
		User traveler = [SELECT ID, Name FROM User WHERE LastName = 'Traveler'];
		String valid_request_type = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
		Center_Support_Request__c request = new Center_Support_Request__c(Center_Information__c = test_center.ID,
                                																			Type__c               = valid_request_type,
                                																			Summary__c            = 'Test Summary',
                                																			Need_By_Date__c       = Date.today(),
                                                                      Status__c             = 'Open',
                                                                      Legal_Compliance__c   = 'No');
		insert request;
		Util_TriggerContext.alreadyProcessed = false;

		System.assertEquals(1, [SELECT count() FROM Center_Support_Request__c]);
		System.assertEquals(0, [SELECT count() FROM Event]);

		request = the_one_request();

		System.runAs(test_user) {
			Test.startTest();
				request.Traveler__c         = traveler.ID;
				request.Travel_Departure__c = Date.today();
				request.Travel_Return__c    = Date.today() + 1;
				update request;
			Test.stopTest();
		}

		request = the_one_request();
		System.assertEquals(1, [SELECT count() FROM Event]);
		Event test_event = [SELECT ID, OwnerId, Subject, WhatId, IsAllDayEvent, IsReminderSet, StartDateTime, EndDateTime FROM Event LIMIT 1];
		// '023' is the prefix of the hidden Public Calendar object. I'm choosing not to test for an exact ID... only that it was given one for the appropriate object.
		System.assertEquals('023', String.valueOf(test_event.OwnerId).substring(0,3));
		System.assert(test_event.Subject != null);
		System.assertEquals(traveler.Name, test_event.Subject);
		System.assertEquals(request.Center_Information__c, test_event.WhatId);
		System.assertEquals(true,  test_event.IsAllDayEvent);
		System.assertEquals(false, test_event.IsReminderSet);
		System.assertEquals(request.Travel_Departure__c, test_event.StartDateTime.dateGMT());
		System.assertEquals(request.Travel_Return__c,    test_event.EndDateTime.dateGMT());

		System.assertEquals(test_event.ID, request.Calendar_Event_ID__c);
	}

	static testMethod void test_an_existing_event_is_updated_correctly_when_existing_travel_dates_change() {
		init();
		System.runAs(test_user) {
			Center_Information__c test_center = [SELECT ID FROM Center_Information__c WHERE Name = 'Test Center'];
			User traveler = [SELECT ID, Name FROM User WHERE LastName = 'Traveler'];
			String valid_request_type = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
			Center_Support_Request__c request = new Center_Support_Request__c(Center_Information__c = test_center.ID,
																																				Type__c             = valid_request_type,
																																				Status__c           = 'Closed',
																																				Summary__c          = 'Test Summary',
																																				Need_By_Date__c     = Date.today(),
                                                                        Legal_Compliance__c = 'No');
			insert request;
			Util_TriggerContext.alreadyProcessed = false;

			System.assertEquals(1, [SELECT count() FROM Center_Support_Request__c]);
			System.assertEquals(0, [SELECT count() FROM Event]);

			request = the_one_request();
			request.Traveler__c         = traveler.ID;
			request.Travel_Departure__c = Date.today();
			request.Travel_Return__c    = Date.today() + 1;
			update request;
			request = the_one_request();
			System.assertEquals(1, [SELECT count() FROM Event]);

			User new_traveler = [SELECT ID, Name FROM User WHERE LastName = 'NewTraveler'];

			Test.startTest();
				request.Traveler__c         = new_traveler.ID;
				request.Travel_Departure__c = Date.today() + 2;
				request.Travel_Return__c    = Date.today() + 3;
				update request;

				Event test_event = [SELECT ID, Subject, WhatId, IsAllDayEvent, IsReminderSet, StartDateTime, EndDateTime FROM Event LIMIT 1];
				System.assertEquals(new_traveler.Name, test_event.Subject);
				System.assertEquals(Date.today() + 2, test_event.StartDateTime.dateGMT());
				System.assertEquals(Date.today() + 3, test_event.EndDateTime.dateGMT());
				Test.stopTest();
		}
	}

	static testMethod void test_an_event_record_is_deleted() {
		init();
		Center_Information__c test_center = [SELECT ID FROM Center_Information__c WHERE Name = 'Test Center'];
		User traveler = [SELECT ID, Name FROM User WHERE LastName = 'Traveler'];
		String valid_request_type = Utilities.picklist_values('Center_Support_Request__c', 'Type__c')[0];
		Center_Support_Request__c request;

		request = new Center_Support_Request__c(Center_Information__c = test_center.ID,
                                      			Type__c               = valid_request_type,
                                      			Status__c             = 'Closed',
                                      			Summary__c            = 'Test Summary',
                                      			Need_By_Date__c       = Date.today(),
                                      			Traveler__c           = traveler.ID,
                                      			Travel_Departure__c   = Date.today(),
                                      			Travel_Return__c      = Date.today(),
                                            Legal_Compliance__c   = 'No');

			insert request;

		System.assertEquals(1, [SELECT count() FROM Center_Support_Request__c]);
		System.assertEquals(1, [SELECT count() FROM Event]);

		System.runAs(test_user) {
			Test.startTest();

			delete request;

			Test.stopTest();
		}

		System.assertEquals(0, [SELECT count() FROM Center_Support_Request__c]);
	}
}