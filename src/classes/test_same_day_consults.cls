/*
2017-02-13
	ctrl_same_day_consults - 100%
*/

@isTest

private class test_same_day_consults {
	private static void init() {
		Lead pacific_lead      = new Lead(FirstName = 'Pacific',    LastName = 'Lead');
		Lead mountain_lead     = new Lead(FirstName = 'Mountain',   LastName = 'Lead');
		Lead not_same_day_lead = new Lead(FirstName = 'NotSameDay', LastName = 'Lead');
		insert new Lead[]{pacific_lead, mountain_lead, not_same_day_lead};

		Center_Information__c pacific_center = new Center_Information__c(Name = 'Pacific Center', latlong__Longitude__s = 30, latlong__Latitude__s = 30,
																		Time_Zone__c = 'PST');
		Center_Information__c mountain_center = new Center_Information__c(Name = 'Mountain Center', latlong__Longitude__s = 30, latlong__Latitude__s = 30,
																		Time_Zone__c = 'MST');
		Center_Information__c bad_center      = new Center_Information__c(Name = 'Bad Center', latlong__Longitude__s = 30, latlong__Latitude__s = 30,
																		Time_Zone__c = 'Bad Timezone');
		insert new Center_Information__c[]{pacific_center, mountain_center, bad_center};

		Consult_Rooms__c pacific_room  = new Consult_Rooms__c(Name = 'Pacific Room',  Center_Information__c = pacific_center.ID);
		Consult_Rooms__c mountain_room = new Consult_Rooms__c(Name = 'Mountain Room', Center_Information__c = mountain_center.ID);
		Consult_Rooms__c bad_room      = new Consult_Rooms__c(Name = 'Bad Room',      Center_Information__c = bad_center.ID);
		insert new Consult_Rooms__c[]{pacific_room, mountain_room, bad_room};

		insert new Consult_Inventory__c[]{new_consult('Pacific Consult',      pacific_room.ID,  Datetime.now().dateGMT(),     9, 30, pacific_lead.ID),
		 								  new_consult('Mountain Consult',     mountain_room.ID, Datetime.now().dateGMT(),     10, 0,  mountain_lead.ID),
										  new_consult('Not Same Day Consult', mountain_room.ID, Datetime.now().dateGMT() - 1, 9, 0,  not_same_day_lead.ID)};
	}

	private static Consult_Inventory__c new_consult(String name, ID room_ID, Date scheduled_date, Integer start_hour, Integer start_minute, ID lead_ID) {
		return new Consult_Inventory__c(Name = name,
										External_Agent__c = 'Online Schedule',
										Consult_Room__c = room_ID,
										Scheduled_Time__c = Datetime.newInstance(scheduled_date, Time.newInstance(12, 0, 0 , 0)),
										Apt_Date__c = Date.today(),
										Start_Hour__c = String.valueOf(start_hour),
										Start_Minute__c = String.valueOf(start_minute),
										End_Hour__c = String.valueOf(start_hour + 1),
										End_Minute__c = String.valueOf(start_minute),
										Active__c = true,
										Scheduled_Lead__c = lead_ID);
	}

	static testMethod void test_it_catches_only_same_day_consults_and_knows_local_appointment_time_and_sorts_correctly() {
		init();
		ctrl_same_day_consults controller = new ctrl_same_day_consults();

		Test.startTest();
			ctrl_same_day_consults.Consult[] consults = controller.getsame_day_consults();
		Test.stopTest();

		// There are three consults, but only two scheduled today
		System.assertEquals(3, [SELECT count() FROM Consult_Inventory__c]);
		System.assertEquals(2, consults.size());

		// Even though the Mountain Consult's local start time (10am) is later than the Mountain Consult (9:30am), it should be first since it actually starts earlier
		System.assertEquals('M.L.', consults[0].patient_initials);
		System.assertEquals('P.L.',  consults[1].patient_initials);

		// Local time is adjusted properly... pacific consult's local appointment time is one hour earlier than its Denver time, mountain consult's local and denver times are the same
		ctrl_same_day_consults.Consult mountain_consult = consults[0];
		ctrl_same_day_consults.Consult pacific_consult = consults[1];
		System.assertEquals(pacific_consult.start_time_denver.addHours(-1), pacific_consult.start_time_local);
		System.assertEquals(mountain_consult.start_time_denver, mountain_consult.start_time_local);
	}

	static testMethod void test_it_sets_an_unrecognized_timezone_to_question_mark() {
		init();
		Consult_Rooms__c bad_room = [SELECT ID FROM Consult_Rooms__c WHERE Name = 'Bad Room'];
		insert new_consult('Bad Consult', bad_room.ID, Datetime.now().dateGMT(), 9, 0, [SELECT ID FROM Lead WHERE Name = 'Mountain Lead'].ID);
		ctrl_same_day_consults controller = new ctrl_same_day_consults();

		Test.startTest();
			ctrl_same_day_consults.Consult[] consults = controller.getsame_day_consults();
		Test.stopTest();

		ctrl_same_day_consults.Consult consult_with_bad_time_zone;
		for (ctrl_same_day_consults.Consult consult : consults) {
			if (consult.center == 'Bad Center') {consult_with_bad_time_zone = consult;}
		}

		System.assertEquals('?', consult_with_bad_time_zone.time_zone);
	}

}